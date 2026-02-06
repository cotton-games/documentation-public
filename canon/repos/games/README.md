# Repo `games` — Carte IA d’intervention (canon)

> **But**: permettre à un agent IA “web” (sans accès direct au runtime) de comprendre rapidement :
> - **ce que fait le repo**, **comment ça circule** (WS/HTTP/Bus),
> - **où intervenir** pour coder une évolution ou corriger un bug.
>
> **Règle**: ce fichier est une **source de vérité** (update-not-append).  
> L’historique et les changements vont dans `TASKS.md`.  
> Le point d’entrée public reste `SITEMAP.md`.

## Doc discipline
- `canon/repos/games/TASKS.md` à mettre à jour à chaque action significative (update-not-append si une tâche existe déjà).
- `canon/repos/games/README.md` à mettre à jour dès qu’un changement impacte le fonctionnel (flux/actions inter-repos, endpoints, env vars, idempotence/event_id, jalons logs, writes DB, etc.).
- En cas de divergence, le code fait foi ; corriger la doc immédiatement.

## Terminologie (anti-confusion)
- **WS frame** : objet JSON envoyé sur socket, champ obligatoire `type`.
- **HTTP bridge** : “action” dispatchée côté PHP (bridge `t=jeux&m=canvas`).
- **Bus event** : `Bus.emit/on(...)` côté front (Bus-first).

---

## Scope & entrypoints
### Pages (HTML)
- Organizer : `web/organizer_canvas.php`
- Player : `web/player_canvas.php`
- Remote : `web/remote_canvas.php`

### Bridge HTTP (Canvas API)
- `web/games_ajax.php` (alias possible : `web/global_ajax.php` selon routage global/branding)

---

## Actors & flows (vue mentale)
### Actors
- **Organizer** : maître de session (démarre/pause/next/prev, options, fin de partie). UI + WS + persistance.
- **Remote** : écran secondaire / télécommande (reçoit l’état, envoie des commandes).
- **Player** : client mobile (register/auth, reçoit l’état, joue).

### Flows principaux
1) Organizer ↔ **WS** ↔ Players  
2) Organizer ↔ **WS** ↔ Remote  
3) Organizer ↔ **HTTP (PHP)** ↔ DB (persistance `session_update`, options, etc.)

### Backend surfaces (résumé)
- `web/games_ajax.php` : bridge JSON (CORS + auth optionnelle + idempotence) → dispatch
- Dispatch côté PHP vers : `web/includes/canvas/php/*_adapter_glue.php` (quiz / blindtest / bingo)

---

## Runtime & I/O

## WebSocket (front)
### Format des frames sortantes (canon)
- **Chaque frame WS** est un objet JSON : `{ type: string, ...fields }`
- Corrélation reply possible : ajout `"_cid"` (optionnel)
- Sérialisation/queue : `web/includes/canvas/core/ws_connector.js` (Bus `game:ws:send`)  
  Réf : `ws_connector.js:300-327`

### Handshake / reconnection (std vs bingo)
- **Non-bingo (std)** : `ws/open` émis dès `onopen`, heartbeat client toutes ~25s, flush queue.
- **Bingo** : à l’ouverture socket, envoie auth (`auth_*`), **attend un premier message serveur `type:"state"`** comme ACK avant d’émettre `ws/open`. Pas de heartbeat client ; répond aux `ping` serveur par `pong`.

### Router inbound partagé
- `web/includes/canvas/core/ws_effects.js` écoute `Bus.on('game:ws:message')` **une fois** et route des types WS vers des events Bus “srv/*” (et bingo-specific).  
  Il ignore les types heartbeat.  
  Réf : `ws_effects.js:450-664`

### Types inbound traités par `ws_effects.js` (canon, extraits)
- `endGame` → `srv/endGame` (hydration scores) (`ws_effects.js:450-466`)
- `paper_finalize_end` → `srv/paper/finalizeEnd` (`ws_effects.js:468-470`)
- `togglePlayPause` → `srv/togglePlayPause` (`ws_effects.js:472-478`)
- `togglePause` → `srv/toggleInterseriesPause` (`ws_effects.js:479-480`)
- `nextSong` / `prevSong` → `srv/nextSong` / `srv/prevSong` (`ws_effects.js:480-493`)
- `skipPause` → `quiz/interseries/end` (`ws_effects.js:494`)
- `forcedDisconnect` → notice + end session (`ws_effects.js:495-510`)
- `gameOptionsUpdate` → persist options + `options/updated` (`ws_effects.js:512-547`)
- `force_full_current` → `srv/forceFullCurrent` (`ws_effects.js:540-544`)
- `start_support` → `srv/startSupport` (`ws_effects.js:545-547`)
- `support_ended` → `srv/supportEnded` (`ws_effects.js:548-550`)
- Bingo :
  - `state` → patch store + `bingo/stateSnapshot` + `srv/phaseUpdate` / `srv/playerUpdate` / `srv/notifications` (`ws_effects.js:552-611`)
  - `remote_action` → map vers `srv/*` ou `options/updated` (`ws_effects.js:612-653`)

> Note : `canvas_display.js` ne consomme pas WS directement (wiring UI/Bus uniquement).

---

## HTTP / PHP bridge (Canvas)
### Endpoint
- Bridge JSON : `web/games_ajax.php` (route `t=jeux&m=canvas`)

### Service-token auth (écritures idempotentes)
- **Auth service-token** appliquée **seulement si `event_id`/`eventId` est présent** dans le payload.
- Header attendu : `HTTP_X_SERVICE_TOKEN`
- Secret : env `CANVAS_SERVICE_TOKEN`
- Dev bypass : `CANVAS_DEV_ALLOW_UNAUTH_WRITES=1` (sous conditions dev)
- En cas d’échec : 403 JSON `{ ok:false, error:{code,...}, ... }`

### Idempotence `game_events`
- Pour les writes avec `event_id` : insertion préalable dans `game_events`.
- Dédup : duplication détectée par SQLSTATE 23000 → on répond `ok` avec `already_processed:true` et on **court-circuite** le handler.
- En pratique, l’unicité repose sur `event_id` (pas de composite référencé dans le code).  
  Réf : `web/games_ajax.php:155-175`

### Bingo — persistance `phase_winner` (Canvas API)
- Handler : `web/includes/canvas/php/bingo_adapter_glue.php::bingo_api_phase_winner`.
- Schéma : table `bingo_phase_winners` (UNIQUE `event_id` + `(session_id, phase)`, source de vérité), colonnes dénormalisées sur `bingo_players` (`phase_wins_count`, `last_won_phase`, `last_won_at`).
- Logique : transaction ; insert historique ; si `event_id` déjà vu ou même joueur sur la même phase → `already_processed=true`; si autre joueur sur phase existante → `ok=false`, `reason=phase_winner_conflict`; sinon avance `phase_courante`, incrémente dénorm, log `PHASE_WINNER_PERSISTED`.

### CORS / origins (résumé)
- Origins **https only**.
- Dev : `*.dev.cotton-quiz.com` (exclut `global.dev.cotton-quiz.com`)
- Prod : `*.cotton-quiz.com` (exclut `global.cotton-quiz.com`)  
  Réf : `games_ajax.php:71-90`

---

## WS contracts (canon, par rôle)
> Objectif : distinguer **commandes sortantes** (frames envoyées) et **messages entrants** (types reçus).

### Organizer
- **Outbound (commands)** : typiquement `registerOrganizer`, `remoteGameState`, `togglePlayPause`, `togglePause`, `nextSong`, `prevSong`, `skipPause`, `force_full_current`, `endGame`  
  (émis via `Bus.emit('game:ws:send', ...)` depuis `boot_organizer.js` / `end_game.js` et modules de contrôle)
- **Inbound** : messages de présence/état (ex : `SECONDARY_PRESENT`, `SCORES_EDITING`) gérés dans `boot_organizer.js`, et messages gameplay “généraux” routés via `ws_effects.js`.

### Remote (`web/includes/canvas/remote/remote-ws.js`)
- **Outbound** (RemoteAPI → `game:ws:send`) :
  - contrôles : `togglePlayPause`, `nextSong`, `prevSong`, `skipPause`, `togglePause`
  - options : `updateGameOptions`
  - bingo : `remote_action` (`start_game|play_song|pause|next_song|set_duration|force_full_current`)
  - fin : `quitGame`, `paper_finalize_end`
- **Inbound** (handlers map) :
  - commun : `gameState`, `sessionUpdate`, `state`, `endGame`, `SESSION_ENDED`, `notification`, `remote_sync`, `updatePlayers`, `update_session_infos`, `update_branding`, `forcedDisconnect`, etc.

### Player (`web/includes/canvas/play/play-ws.js`)
- **Outbound** :
  - quiz/blindtest : `registerPlayer` ; gameplay `checkAnswer` ; fin `quitGame`
  - bingo : auth auto `auth_player` / `auth_player_paper`, fin `player_quit`
- **Inbound** :
  - commun : `gameState`, `sessionUpdate`, `updatePlayers`, `registrationSuccess`, `SESSION_ENDED`, `answerResult`, `update_session_infos`, `update_branding`
  - bingo : `state`, `passed_song`, `phase_over`, `remote_sync`, `notifications`, `demo_reset`

---

## Gameplay concepts & transitions (compact)
### Index & statuts (glossaire minimal)
- `currentSongIndex` (front) / `current_song_index` (DB) : position **0-based**
- Bingo : `num_passed_songs` sert à dériver l’index logique
- `item_index` : index **humain** “contenu” (1-based, sans jingles) utilisé pour logs (`core/player/index.js`, `emitRoundStarted`)
- `gameStatus` : libellé humain (0 En attente / 1 En cours / 2 Pause / 3 Partie terminée) via maps côté adapters
- Bingo phases : `current_phase` ∈ {0,1,2,3/5,-1} avec labels (En attente/Ligne/Double ligne/Bingo/Terminé) + `is_playing` pour En cours/Pause

### End-of-game (vue mentale)
- Déclencheur possible : commande `endGame` ou message `SESSION_ENDED` / phase bingo -1
- `ws_effects.js` route `endGame` vers `srv/endGame` (podium, scores)
- `end_game.js` (organizer) stop timers + `Bus.emit('session/end')` + cleanup UI (et persistance finale si branchée)

---

## Paper mode
- Flags : `paperMode` (WS payload), DB `flag_controle_numerique` (0 papier / 1 digital)
- Override : `localStorage paperModeOverride_<sid>`
- Player paper : si déjà “paper registered”, ignore la majorité des WS sauf `update_session_infos`
- Bingo paper : auth `auth_player_paper`, quit via `player_quit`
- Templates : `quiz_support_paper.php`, `blindtest_support_paper.php`, `bingo_grids_paper.php`
- Grids bingo : via HTTP APIs côté `bingo_adapter_glue.php` (assign/sync)

---

## Script map 20/80 (why / risk / validate)
- `core/ws_connector.js` — **why**: transport WS unique / auth / queue / reconnect ; **risk**: plus de live, boucle reconnect ; **validate**: `ws/status`→open + messages passent + (std) heartbeat ~25s.
- `core/ws_effects.js` — **why**: router inbound WS→Bus + effets gameplay ; **risk**: commandes/états non répercutés ; **validate**: recevoir `gameOptionsUpdate` → `options/updated`.
- `play/play-ws.js` — **why**: auth/register player + réponses ; **risk**: player muet / answer jamais envoyée ; **validate**: `checkAnswer` → `game:ws:send`.
- `remote/remote-ws.js` — **why**: télécommande + mapping handlers ; **risk**: next/pause ignorés ; **validate**: action remote → état serveur revient.
- `core/session_persist.js` — **why**: push `session_update` ; **risk**: désynchro/persistance cassée ; **validate**: une action gameplay produit 1 write attendu.
- `web/games_ajax.php` — **why**: CORS/auth/idempotence/dispatch ; **risk**: 403, CORS, already_processed mal compris ; **validate**: POST avec/sans `event_id`.
- `php/*_adapter_glue.php` — **why**: accès DB par jeu ; **risk**: état/podium faux ; **validate**: preload session cohérent.
- `core/logger.global.js` — **why**: writer logs Bus→LogEntry ; **risk**: viewer illisible/silencieux ; **validate**: `game:ws:send` + `game:ws:message` loggués.

---

## Bus hooks for logging (liste courte)
Le writer central écoute typiquement :
- Transport : `ws/status`, `ws/open`, `ws/close`
- WS payloads : `game:ws:send`, `game:ws:message`
- HTTP : `api/call`, `api/ok`, `api/fail`
- Gameplay : `timer/*`, `support/*`, `session/*`, `player/*`, `remote/*`
Writer : `web/includes/canvas/core/logger.global.js`

---

## Interactions (vue rapide)
- Clients canvas ↔ WebSocket (transport unique géré par `web/includes/canvas/core/ws_connector.js`), routing inbound via `ws_effects.js`.
- HTTP bridge `web/games_ajax.php` reçoit les writes/reads Canvas et appelle les adapters PHP par jeu.
- Logs front centralisés via `web/includes/canvas/core/logger.global.js` (Bus-first).

## Actions clés (runbook court)
- Lancer front (serveur PHP) : vhost cible `games/web/` (cf. `games/web/config.php`).
- Tester bridge : POST sur `games/web/games_ajax.php?t=jeux&m=canvas` avec/ sans `event_id`.
- Ouvrir viewer logs front : `games/web/logs_session.html?sessionId=<sid>`.

## Variables d’environnement (bridge PHP)
| Key | Required | Used in | Note |
| --- | --- | --- | --- |
| `CANVAS_SERVICE_TOKEN` | Requis pour writes avec `event_id` | `games/web/games_ajax.php` | Header `HTTP_X_SERVICE_TOKEN` |
| `CANVAS_DEV_ALLOW_UNAUTH_WRITES` | Optionnel (dev) | `games/web/games_ajax.php` | Bypass token si env dev détecté |

## Happy path (front/bridge)
1) Vhost pointe vers `games/web/` (config.php OK).
2) Token service présent dans l’env PHP (`CANVAS_SERVICE_TOKEN`).
3) Client front init WS via `ws_connector.js`, reçoit `state` (bingo) ou handshake std.
4) Actions gameplay émettent writes HTTP via `games_ajax.php` (avec `event_id`).
5) Bridge accepte, insère dans `game_events` (idempotence) et renvoie payload JSON `ok:true`.
6) Logs viewer (`logs_session.html`) affiche les entrées `/logs` WS pour le `sessionId`.

## Scénarios d’échec
- Symptôme : 403 sur `games_ajax.php` lors d’un write — Cause : token manquant/incorrect — Fix : exporter `CANVAS_SERVICE_TOKEN` côté PHP, relancer service.
- Symptôme : pas de logs dans viewer — Cause : endpoint WS `/logs` ne renvoie rien (sid erroné ou pas de log) — Fix : vérifier sid, générer trafic, relire.
- Symptôme : déjà traité (`already_processed:true`) — Cause : même `event_id` réutilisé — Fix : générer un nouvel `event_id` côté appelant.

## Observability (viewer-first)
- Logs front : `games/web/logs_session.html` consomme `logs_proxy.php` → lit `/logs` du WS ciblé (JSONL).
- WS debug côté front : hooks `logger.global.js` sur Bus (`ws/status`, `game:ws:send`, `game:ws:message`).
- HTTP bridge : réponses JSON explicites (`ok`, `error`, `already_processed`, `code`), CORS selon règles dans `games_ajax.php`.
