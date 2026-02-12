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
- Correctif 2026-02-12 (anti-régression lots Bingo): le hook `Bus.on('options/updated')` n’envoie plus `update_session_infos` pour toute option; l’envoi est limité aux champs de contrôle de session (`paperMode`, plus `manualAdvance` pour quiz), afin d’éviter des updates session inutiles sur simples options gameplay (`songDuration`, etc.).

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

### Service-token auth (compat front + service)
- **Auth service-token** appliquée quand le header `HTTP_X_SERVICE_TOKEN` est fourni (canal inter-service).
- Secret attendu : env `CANVAS_SERVICE_TOKEN`.
- En cas de header invalide : 403 JSON `{ ok:false, error:{code,...}, ... }`.
- Les clients browser (sans header service) restent compatibles en mode public.

### Idempotence `game_events`
- Les actions mutatrices passent par une liste centrale bridge (`MUTATING_ACTIONS`), avec résolution `getOrCreateEventId(...)`.
- Si `event_id` est absent/invalide, le bridge génère un UUID v4 et loggue `MISSING_EVENT_ID` (warning structuré).
- Si `event_id` est présent/valide, le bridge loggue `EVENT_ID_RX`.
- Ensuite insertion préalable dans `game_events` pour ces actions mutatrices.
- Dédup : duplication détectée par SQLSTATE 23000 → on répond `ok` avec `already_processed:true` et on **court-circuite** le handler.
- En pratique, l’unicité repose sur `event_id` (pas de composite référencé dans le code).  
  Réf : `web/games_ajax.php:155-175`
- Côté front `games`, les appels mutateurs passent désormais avec `event_id` (`canvasCall` et flux player register/deactivate/grid_assign).
- Remote paper register (`remote-ui.js`): `player_register` envoie aussi `event_id`, conservé en localStorage pour retry idempotent tant que la tentative n’est pas confirmée.

### Identité joueur (key-first)
- Les payloads WS/API player-scoped doivent être key-first: `player_id` canon (`p:<uuid>`) prioritaire, `playerId` numérique optionnel (compat).
- `playerId` ne doit jamais transporter un `p:<uuid>`; la validation est faite côté wrappers WS et côté glue PHP.
- Les actions player-scoped des glues quiz/blindtest/bingo exposent `identity_mode` (`canon|legacy`) et `legacy_identity` (bool) pour piloter la suppression du fallback legacy.
- Persistance front canon (session-scoped):
  - `${game}:session_id`
  - `${game}:player_stable_id:${sid}` -> `p:<uuid>` (source de vérité)
  - `${game}:player_db_id:${sid}` -> numeric optionnel
- Helper front: `web/includes/canvas/play/player_identity.js`:
  - `getOrCreatePlayerId({game,sid})` avec migration legacy (`${game}:player_stable_id`, `${game}:player_id`, `player_id`)
    - si une session a déjà une origine d’identité (`${game}:player_id_origin:${sid}`), la suppression de la clé scoped force une régénération `p:<uuid>` (pas de "résurrection" depuis une clé globale legacy)
  - `persistServerPlayerIdIfAbsent(...)` pour ne jamais écraser le scoped canon avec une valeur non canonique
  - log debug contractuel: `PLAYER_ID_STORAGE_RESOLVED {game,sid,source:'scoped|migrated|generated'}`
- Remote (organisateur, ajout joueur papier): `remote-ui.js` maintient aussi une identité canonique locale par clé `game + session + username normalisé` et l’envoie en key-first sur `player_register`.

### Bingo — persistance `phase_winner` (Canvas API)
- Handler : `web/includes/canvas/php/bingo_adapter_glue.php::bingo_api_phase_winner`.
- Schéma : table `bingo_phase_winners` (UNIQUE `event_id` + `(session_id, phase)`, source de vérité), colonnes dénormalisées sur `bingo_players` (`phase_wins_count`, `last_won_phase`, `last_won_at`).
- Migration 2026-02-12 : ajout progressif `bingo_phase_winners.player_id_key` (canonique `p:*`) via script SQL idempotent, avec fallback compat legacy si colonne absente.
- Logique : transaction ; identité gagnant résolue key-first (`player_id` canonique -> `player_db_id`) ; insert historique ; si `event_id` déjà vu ou même joueur sur la même phase -> `already_processed=true`; si autre joueur sur phase existante -> `ok=false`, `error=phase_winner_conflict` + `reason=phase_winner_conflict`; sinon avance `phase_courante`, incrémente dénorm, log `PHASE_WINNER_PERSISTED`.

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
  - alias sync: `initializeOrUpdateSession` est traité comme `sessionUpdate` côté remote.
- options : `gameOptionsUpdate`, `GAME_OPTIONS_UPDATED`, `STATE_SYNC` (appliqués côté remote) + patchs provenant aussi de `gameState`/`sessionUpdate`/`remote_sync`.
- garde historique corrigée : le refresh des propositions n’est plus bloqué quand `currentSongIndex` logique reste identique pendant la transition jingle -> round #1.
- reveal remote (quiz/blindtest) stabilisé : la correction n’est plus effacée sur chaque `remote/options:proposals`, la classe visuelle canon `option-reveal` est appliquée avec compat legacy `.reveal`, `remote/options:correct` transporte `{text,key}`, et le patch DOM applique la correction par `data-option-key` (key-first, fallback texte uniquement).
- observability remote options : logs v1 `REMOTE_OPTIONS_RX` (réception), `REMOTE_OPTIONS_RENDER` (rendu), `REMOTE_OPTIONS_GUARD_BLOCK` (blocage guard), avec contexte `phase/isJingle/started`, émis en bus-first via `ui/remote:action` (pas de `window.Logger.debug` direct).
- remote add-player (`handleAddPlayerLive`) : payload `player_register` = `{ username, player_id, event_id, sessionId|sessionPrimaryId }` ; `player_id` canonique persisté localement ; `event_id` conservé jusqu’au succès pour retry idempotent.
- remote actions joueur/phase (`remote-ui.js`) : `admin_player_register`, `admin_set_score`, `admin_phase_winner`, `admin_phase_fail` transportent `event_id`, `player_id` canonique si dispo, et `playerId` numérique en compat.
- remote listing joueurs (quiz/blindtest) : fusion key-first sur identité canonique (`player_id` si dispo, sinon id numérique) pour éviter les doublons d’affichage lors des snapshots mixtes (`playerId` legacy + `player_id` canonique).
- bridge PHP quiz/blindtest (`quiz_adapter_glue.php` / `blindtest_adapter_glue.php`) : `players_get` et preload `players` renvoient aussi `player_id` (et `updated_at` si disponible), avec fallback safe pré-migration si la colonne n’existe pas encore.
- mode historique (session terminée) : `players_get` accepte `includeInactive` pour inclure les participants déconnectés; la remote l’active automatiquement en vue terminée pour éviter de “sortir” des joueurs du classement final.
- WS quiz/blindtest (reconnexion orga sur session terminée) : réhydratation DB forcée + reconstruction du snapshot `endGame` pour réaligner l’affichage final avec les participants persistés.
- WS bingo (auth orga) : à l’authentification, si la phase courante est terminale, l’hydratation joueurs DB active `includeInactive` pour reconstruire un snapshot historique cohérent.
- exception Bingo (papier animateur) : `admin_phase_winner` peut être envoyé sans `player_id/playerId`; le WS Bingo applique alors un avancement manuel de phase (sans persistance `phase_winner` DB), pour permettre la progression même sans joueur sélectionné.
- organizer Bingo (`core/ws_effects.js`) : sur `phase_over`, la phase gagnée utilise désormais `won_phase` en priorité (fallback legacy via `next_phase` si absent) pour éviter les décalages d’annonce en correction manuelle papier.
- notifs Bingo admin manuel : les victoires forcées réutilisent le format historique `PlayerWin` (même canal/UI que les victoires standards), au lieu d’un message `Info` spécifique.
- fallback podium Bingo (orga + remote) : en absence de gagnants hydratés, affichage cohérent papier avec `Joueur inconnu` par phase gagnée (Bingo / Double ligne / Ligne), au lieu d’un fallback score-driven ou placeholders génériques.
- remote Bingo fin de partie : la liste joueurs est conservée en `Partie terminée` (ignore snapshots vides tardifs) et fallback `players_get` est déclenché si `endGame.players` est absent/vide.

### Player (`web/includes/canvas/play/play-ws.js`)
- **Outbound** :
  - quiz/blindtest : `registerPlayer { sessionId, player_id, playerId? }` (canon strict + db optionnel), gameplay `checkAnswer { player_id, ... }`, fin `quitGame`
  - bingo : auth auto `auth_player` / `auth_player_paper` avec `player_id` canon obligatoire (+ `id_player` db pour compat auth), fin `player_quit`
- Register API front (`web/includes/canvas/play/register.js`) :
  - quiz/blindtest/bingo envoient `player_register` avec `player_id` session-scoped (`${slug}:player_stable_id:${sessionId}`),
  - migration douce legacy: si `${slug}:session_id === sessionId` et `${slug}:player_stable_id` existe, copie vers la clé session-scoped,
  - la clé legacy est conservée pour compat mais n’est plus la source de vérité,
  - pour Bingo, séparation explicite front: `player_id` (canon `p:<uuid>`) vs `player_db_id` (id DB numérique legacy pour auth WS papier/numérique).
- Bingo APIs player côté front (`play/register.js` + `play/play-ui.js`) :
  - `grid_assign`, `grid_hydrate`, `grid_cells_sync` envoient `player_id` canonique en premier, avec `playerId` numérique seulement en fallback compat,
  - `grid_id` est persisté en clé session-scoped `${slug}:grid_id:${sessionId}` (fallback lecture legacy `bingo_grid_id`),
  - juste avant `player_register` Bingo, `player_id` est normalisé strictement (jamais numérique) via `preparePlayerIdPreRegister`, avec migration legacy numeric vers `player_db_id` et log debug `PLAYER_ID_PRE_REGISTER`.
- **Inbound** :
  - commun : `gameState`, `sessionUpdate`, `updatePlayers`, `registrationSuccess`, `SESSION_ENDED`, `answerResult`, `answerReveal`, `update_session_infos`, `update_branding`
  - bingo : `state`, `passed_song`, `phase_over`, `remote_sync`, `notifications`, `demo_reset`
  - replacement: `SESSION_REPLACED` (last connection wins) -> onglet remplacé passe en read-only, bannière persistante, et reconnect manuel via “Reprendre ici”.
- Close code WS dédié replacement player : `4005` (`player replaced`) ; le transport front stoppe la reconnexion auto tant que la reprise n’est pas explicitement demandée.

### Note cross-origin (register)
- `localStorage` reste borné à l’origin (sous-domaine/protocole): un `player_id` session-scoped n’est pas partagé entre origins distinctes.
- Résilience actuelle: fallback serveur (`MISSING_PLAYER_ID` + UPSERT `(session_id, player_id)`), mais continuité inter-origins non garantie sans transport explicite du `player_id` (token/URL/postMessage côté produit).

### Quit player & `deactivate_player` (cross-game, canon 2026-02-10)
- `quiz` / `blindtest` : `quitGame` (front -> WS) puis désactivation Canvas (`deactivate_player`) côté WS serveur.
- `bingo` : `player_quit` (front -> WS) puis désactivation Canvas (`deactivate_player`) côté WS serveur.
- Conséquence: plus d’appel API front direct `deactivate_player` dans `games` pour bingo; responsabilité unifiée côté serveurs WS.

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

### Terminated Static Mode (2026-02-11)
- Si `window.Preload` indique une session terminée (`preload.isTerminated` ou `preload.session.isTerminated` ou `preload.session.gameStatus === "Partie terminée"`), le front ne boot pas de WS.
- Conséquences:
  - pas de `auth_client` / `registerOrganizer` côté organizer,
  - pas de `registerOrganizer` / `remoteGameState` côté remote,
  - pas de `auth_player*` / `registerPlayer` côté player si preload terminal dispo.
- Source de vérité en mode statique: `window.Preload` injecté serveur.
- Bascule live -> static:
  - à réception de `endGame`, le front conserve désormais le WS en live et ouvre une fenêtre de grâce de 20 min (session-scoped, `sessionStorage`),
  - au boot/reload, si preload est terminal mais qu’une grâce active existe, le WS reste autorisé,
  - hors grâce, le comportement statique preload s’applique (pas de boot WS).
- Bingo preload enrichi:
  - `preload.players.players[]` (issus de `bingo_players` via `players_get`, shape compat organizer),
  - `preload.phase_winners[]` (issus de `bingo_phase_winners`, ordonnés par phase),
  - utilisé en statique pour reconstruire le podium winners sans WS live.

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
| `CANVAS_SERVICE_TOKEN` | Requis pour valider les appels inter-service signés | `games/web/games_ajax.php` | Comparé au header `HTTP_X_SERVICE_TOKEN` |

## Happy path (front/bridge)
1) Vhost pointe vers `games/web/` (config.php OK).
2) Token service présent dans l’env PHP (`CANVAS_SERVICE_TOKEN`) pour les appels WS→bridge signés.
3) Client front init WS via `ws_connector.js`, reçoit `state` (bingo) ou handshake std.
4) Actions mutatrices émettent writes HTTP via `games_ajax.php` avec `event_id` (client ou bridge compat).
5) Bridge accepte, insère dans `game_events` (idempotence) et renvoie payload JSON `ok:true`.
6) Logs viewer (`logs_session.html`) affiche les entrées `/logs` WS pour le `sessionId`.

## Scénarios d’échec
- Symptôme : 403 sur `games_ajax.php` lors d’un write WS — Cause : header `X_SERVICE_TOKEN` invalide vs `CANVAS_SERVICE_TOKEN` — Fix : aligner les secrets côté WS/PHP.
- Symptôme : pas de logs dans viewer — Cause : endpoint WS `/logs` ne renvoie rien (sid erroné ou pas de log) — Fix : vérifier sid, générer trafic, relire.
- Symptôme : déjà traité (`already_processed:true`) — Cause : même `event_id` réutilisé — Fix : générer un nouvel `event_id` côté appelant.

## Observability (viewer-first)
- Logs front : `games/web/logs_session.html` consomme `logs_proxy.php` → lit `/logs` du WS ciblé (JSONL).
- Chips viewer (`total/debug/info/warn/error`) : stats globales obtenues via `logs_proxy.php?stats=1&force=1` (recalcul forcé, sans cache) pour éviter les écarts temporaires après flush front; la chip `visibles` reste calculée localement sur les entrées chargées.
- WS debug côté front : hooks `logger.global.js` sur Bus (`ws/status`, `game:ws:send`, `game:ws:message`).
- HTTP bridge : réponses JSON explicites (`ok`, `error`, `already_processed`, `code`), CORS selon règles dans `games_ajax.php`.
- Flush front vers WS :
  - `LOG_FLUSH_TRIGGER` (debug) avec `source="viewer"` ou `source="session_end"` et meta `{sid, game, source, queued_count}`.
  - `LOG_FLUSH_TRY` (debug), `LOG_FLUSH_OK` (info), `LOG_FLUSH_FAIL` (warn).
  - Meta flush attendue: `{count, ws_ready_state, ws_url?}` (URL seulement si non sensible/disponible).
- Viewer “Forcer flush” :
  - `logs_session.html` écrit `localStorage.LOG_FLUSH_REQUEST` (pas d’appel réseau direct).
  - `logger.global.js` écoute l’événement `storage` sur `LOG_FLUSH_REQUEST` puis exécute `flushBufferToWS()`.
  - `logger.global.js` normalise chaque entrée avant envoi (`ensureEntrySourceTs`) : conservation de `entry.ts` si valide, fallback ISO sinon, et ajout systématique `meta.client_ts` + `meta.event_ts` (timestamps source d’émission front).
  - Le flush envoie `type:"log_batch"` sur la WS déjà ouverte de la session active.
  - Le même chemin émet aussi un flush auto à la fin de session (`gameStatus === "Partie terminée"`).
- Attendu côté WS ingest (`log_batch`/`log_event`) : ingestion visible dans les logs WS (ex: marqueur `LOG_BATCH_RX` si implémenté, ou entrées enrichies `meta.ingested_by`) puis entrées `src=GAMES` visibles dans `/logs` avec `msg` non vide et `meta` utile.
- Reveal player (quiz/blindtest) :
  - le reveal arrive via `answerReveal` (post-verrou / fin timer), avec payload `{correctOption, correctOptionKey?, currentSongIndex}`.
  - logs front debug associés : `PLAYER_REVEAL_RX` (`game,sid,itemIndex,has_correct_key,correctKey?`) puis `PLAYER_REVEAL_APPLY` (`found,method:key|legacy`).
