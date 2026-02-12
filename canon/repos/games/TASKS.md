# Repo `games` — Tasks (journal bref)

## Terminated Static Mode (2026-02-11)

### Objectif
- Si `window.Preload` indique une session terminée, ne pas ouvrir de WebSocket côté front (`organizer`, `remote`, `player` si preload dispo) et afficher l’état final depuis preload.

### Implémentation
- Garde preload terminée ajoutée dans:
  - `../games/web/includes/canvas/core/ws_effects.js`
  - `../games/web/includes/canvas/remote/remote-ws.js`
  - `../games/web/includes/canvas/play/play-ws.js`
- En mode statique:
  - pas de boot WS
  - pas d’envoi `registerOrganizer` / `remoteGameState` / `auth_*` / `registerPlayer`
  - `remote` émet l’état final local depuis preload (`remote/state`, `remote/end`, `remote/players:update` et winners bingo preload)
  - `organizer` hydrate aussi les scores/joueurs depuis preload (plus dépendance WS pour l’écran final)
- Bascule live -> static:
  - à réception WS `endGame`, passage en mode static + reload HTTP (`location.replace` avec `_tsm=*`) pour recharger un preload terminal.

### Preload attendu côté front
- quiz/blindtest:
  - `preload.session.isTerminated` (bool)
  - `preload.isTerminated` (bool)
  - `preload.players.players[]` (déjà présent)
- bingo:
  - `preload.session.isTerminated` (bool)
  - `preload.isTerminated` (bool)
  - `preload.players.players[]` (ajouté pour réhydrater organizer en mode terminal)
  - `preload.phase_winners[]` (phase winners ordonnés)

### Fichiers touchés (code)
- `../games/web/includes/canvas/core/ws_effects.js`
- `../games/web/includes/canvas/core/boot_organizer.js`
- `../games/web/includes/canvas/remote/remote-ws.js`
- `../games/web/includes/canvas/remote/remote-ui.js`
- `../games/web/includes/canvas/play/play-ws.js`
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`

### Correctif bingo reload terminé (2026-02-11)
- Symptôme observé: après `endGame` en live, l’UI organizer bingo affichait bien joueurs + gagnants; après refresh/reload, liste vide et podium fallback.
- Cause racine confirmée: `ws_effects.js` coupe le WS en mode preload terminé, mais `bingo_resolve_token` n’injectait pas `preload.players` (contrairement à quiz/blindtest).
- Correctif appliqué: `bingo_resolve_token` injecte désormais `players` (shape compat `{ players: [...] }`) via lecture DB (`bingo_api_players_get`) en plus de `phase_winners`.

### Ajustement UX live endGame (2026-02-11)
- Constat: bascule statique immédiate à réception WS `endGame` trop agressive pour l’écran de fin live (organizer/remote/player).
- Nouveau comportement:
  - à `endGame`, on marque une fenêtre de grâce WS de 20 min en `sessionStorage` (clé session-scoped),
  - on ne force plus de reload `_tsm` immédiat,
  - au boot/reload, si preload est "Partie terminée" mais grâce active, la connexion WS reste autorisée.
- Portée:
  - organizer: `../games/web/includes/canvas/core/ws_effects.js`
  - remote: `../games/web/includes/canvas/remote/remote-ws.js`
  - player: `../games/web/includes/canvas/play/play-ws.js`

### Correctif Bingo play reload gagnant (2026-02-11)
- Symptôme: en fin de partie Bingo, un joueur gagnant voyait bien le message/lot en live, mais après reload retombait sur un écran "non gagnant".
- Correctif: persistance de `bingo_best_phase` en clé session-scoped (`bingo_best_phase:<sessionId>`) avec fallback legacy global.
- Effet: l’écran de fin joueur recharge correctement la meilleure phase gagnée et le lot associé depuis `window.AppSessionLots`.
- Fichier: `../games/web/includes/canvas/play/play-ui.js`

## Audit remote paper register (2026-02-12)

### Objectif
- Garantir la compatibilité migrations `player_id` (UPSERT/UNIQUE) pour l’ajout joueur depuis remote (session papier), sans doublon et idempotent au retry.

### Résultat
- Gap confirmé avant patch:
  - `remote-ui.js` envoyait `player_register` sans `event_id`.
  - `player_id` était généré en format non canonique (`remote:*`) et non persistant.
- Correctif appliqué:
  - `player_id` canonique (`p:<uuid>`) généré/persisté en localStorage, scope `game + session + username normalisé`.
  - `event_id` UUID généré/persisté par tentative d’inscription, réutilisé au retry tant que la tentative n’est pas confirmée.
  - purge de la tentative pending uniquement après succès `player_register`.
  - payload `player_register` key-first sur les 3 jeux: `username`, `player_id`, `event_id`, puis `sessionId` (bingo) ou `sessionPrimaryId` (quiz/blindtest).
  - `playerId` numérique reste optionnel (uniquement retour serveur / compat), pas utilisé comme identité canonique.
  - actions remote joueur/phase harmonisées (`admin_player_register`, `admin_set_score`, `admin_phase_winner`, `admin_phase_fail`): envoi `event_id` + `player_id` canonique quand disponible, `playerId` numérique en compat.
  - listing remote quiz/blindtest dédupliqué key-first (`player_id` canonique prioritaire, fallback numérique) pour éviter les doubles entrées visuelles sur snapshots mixtes.
  - exception Bingo validée (session papier animateur): `admin_phase_winner` sans joueur est autorisé côté WS (`bingo_server.js`) et déclenche un avancement manuel de phase sans write `phase_winner` DB.
  - organizer Bingo: `phase_over` exploite `won_phase` en source de vérité (fallback `next_phase` conservé), ce qui corrige le décalage d’annonce de phase gagnée en mode manuel.
  - mode manuel Bingo sans joueur: calcul de `next_phase` aligné sur la phase explicitement validée par l’admin (si présente dans `phases_liste`), et notifs victoire rétablies en `PlayerWin` (format historique, plus de `"... validée manuellement"`).
  - fallback podium Bingo harmonisé (orga + remote): sans gagnants hydratés, rendu `Joueur inconnu` par phase (Bingo / Double ligne / Ligne), sans fallback classement par score.
  - liste joueurs remote Bingo fin de session: protection contre écrasement par snapshots vides post-`endGame` + fallback `players_get` si nécessaire.
  - quiz/blindtest hydratation alignée: `players_get` et preload `players` exposent désormais `player_id` canonique (et `updated_at` si présent), avec fallback legacy safe si colonne absente (introspection schéma).
  - effet: les hydrations WS quiz/blindtest qui dédupliquent key-first sur `player_id` ne perdent plus de lignes valides quand la DB contient des identités canoniques.
  - sessions terminées: `players_get` supporte `includeInactive` (quiz/blindtest/bingo) pour récupérer aussi les participants déconnectés/inactifs, afin de conserver un classement final cohérent avec la participation réelle.
  - WS quiz/blindtest: à la reconnexion orga d’une session terminée, hydratation DB forcée (incluant inactifs), invalidation du snapshot final en mémoire, puis reconstruction/renvoi `endGame` depuis l’état hydraté.
  - WS bingo: hydratation DB au login orga (`auth_client`) passe désormais `includeInactive=true` quand la phase est terminale (`current_phase=-1`), pour réaligner le snapshot joueurs avec l’historique de participation.

### Fichier touché
- `../games/web/includes/canvas/remote/remote-ui.js`
- `../bingo.game/ws/bingo_server.js`
- `../games/web/includes/canvas/core/ws_effects.js`
- `../games/web/includes/canvas/core/games/bingo_ui.js`
- `../games/web/includes/canvas/core/canvas_display.js`
- `../games/web/includes/canvas/remote/remote-ws.js`
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
- `../quiz/web/server/actions/registration.js`
- `../blindtest/web/server/actions/registration.js`
- `../bingo.game/ws/bingo_server.js`

## Bingo lots regression fix (2026-02-12)

### Objectif
- Éviter la disparition du bloc “lots à gagner” côté player Bingo quand l’organizer modifie des options en phase d’attente (ex: `songDuration`).

### Correctif appliqué
- `ws_effects.js`: `options/updated` ne pousse plus systématiquement `update_session_infos`; envoi limité aux changements de contrôle de session (`paperMode`, et `manualAdvance` pour quiz).
- Effet attendu: un changement d’option gameplay (`songDuration`) ne déclenche plus de diffusion `sessionInfos` inutile.

### Fichiers touchés
- `../games/web/includes/canvas/core/ws_effects.js`

## Logs viewer chips sync fix (2026-02-12)

### Objectif
- Éliminer l’écart temporaire entre chips globales (`total/debug/info/warn/error`) et tableau après flush front (`log_batch`), tout en conservant des chips basées sur l’ensemble des logs.

### Correctif appliqué
- `logs_proxy.php`: ajout du paramètre `force=1` pour bypass cache sur `stats=1`.
- `logs_session.html`: requête stats passée en `stats=1&force=1` pour recalcul global immédiat.
- `visibles` reste inchangé (toujours calculé côté client sur les entrées chargées).

### Fichiers touchés
- `../games/web/includes/canvas/php/logs_proxy.php`
- `../games/web/logs_session.html`

## Bingo phase winners canonical key migration (2026-02-12)

### Objectif
- Finaliser la migration identity key-first pour les gagnants de phase Bingo, tout en restant compatible avec le schéma legacy (`player_id` numérique) durant la transition.

### Correctif appliqué
- `bingo_api_phase_winner` résout désormais l’identité gagnant via `_bingo_resolve_identity` (source de vérité: `player_id` canonique), puis persiste l’ID DB legacy pour compat table.
- Ajout du code d’erreur explicite `error=phase_winner_conflict` sur conflit inter-joueurs d’une même phase (en plus de `reason`).
- Lecture winners (`_bingo_fetch_phase_winners`) basculée key-first:
  - priorise `bingo_phase_winners.player_id_key` si la colonne existe,
  - fallback sur jointure `bingo_players` sinon.
- Écriture winners rétrocompatible:
  - si `player_id_key` existe, insertion `(session_id, phase, player_id, player_id_key, event_id)`,
  - sinon insertion legacy `(session_id, phase, player_id, event_id)`.
- Correctif post-migration: résolution d’une ambiguïté SQL `session_id/phase` dans la requête de conflit (`WHERE w.session_id = :sid AND w.phase = :phase`).

### Migration DB ajoutée
- Nouveau script idempotent:
  - `../games/web/includes/canvas/sql/2026-02-12_bingo_phase_winners_player_id_key.sql`
- Contenu:
  - ajoute `player_id_key VARCHAR(64) NULL` si absente,
  - backfill depuis `bingo_players` via relation legacy (`session_id + id`),
  - ajoute index `idx_bpw_session_phase_player_key`,
  - post-check `missing_player_id_key`.

### Fichiers touchés
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
- `../games/web/includes/canvas/sql/2026-02-12_bingo_phase_winners_player_id_key.sql`

## AUDIT data results (DB reads): current pipeline (2026-02-11)

### Scope audité
- Données: players (identité), scores, podium/leaderboard final (quiz/blindtest), winners de phase bingo.
- Front surfaces: organizer, remote, player register.
- Contraintes: audit only, zéro patch runtime.

### Call-sites front qui lisent DB (résultats)
- `../games/web/includes/canvas/play/register.js:835` -> `session_primary_id` (HTTP bridge) pour résoudre `sessionPrimaryId` avant contrôle d’existence joueur.
- `../games/web/includes/canvas/play/register.js:845` -> `players_get { sessionPrimaryId }` (quiz/blindtest), utilisé en auto-resume (`playerExistsInSession`), retourne `players[]` avec score.
- `../games/web/includes/canvas/play/register.js:861` -> `players_get { sessionId }` (bingo), utilisé en auto-resume (`bingoPlayerExists`), retourne `players[]`.
- `../games/web/includes/canvas/remote/remote-ui.js:417` -> `session_primary_id` (HTTP bridge), prérequis pour read joueurs côté remote.
- `../games/web/includes/canvas/remote/remote-ui.js:3211` -> `players_get { sessionId }` (bingo) via `fetchPlayersSnapshot()`.
- `../games/web/includes/canvas/remote/remote-ui.js:3215` -> `players_get { sessionPrimaryId }` (quiz/blindtest) via `fetchPlayersSnapshot()`.
- `../games/web/includes/canvas/remote/remote-ui.js:3260` -> `fetchPlayersSnapshot()` appelé après `player_register` remote (rafraîchissement manuel liste joueurs).
- `../games/web/organizer_canvas.php:51` + `../games/web/remote_canvas.php:50` -> preload HTTP serveur (`build_preload_for_game`) injecté dans `window.Preload` (lecture DB au rendu page, sans fetch JS direct).

### Reads DB preload (HTTP direct, page load)
- Quiz: `../games/web/includes/canvas/php/quiz_adapter_glue.php:508` lit état session + players (`_qz_fetch_players`) et injecte `preload.players` (`...:539`, `...:564`).
- Blindtest: `../games/web/includes/canvas/php/blindtest_adapter_glue.php:396` lit état session + players (`_bt_fetch_players`) et injecte `preload.players` (`...:427`, `...:455`).
- Bingo: `../games/web/includes/canvas/php/bingo_adapter_glue.php:134` lit état session + playlist uniquement; pas de `preload.players/podium/winners` (`...:173-182`).

### Pipeline par jeu (constat actuel)
| Donnée | Quiz | Blindtest | Bingo |
| --- | --- | --- | --- |
| Players | Mix preload HTTP (`quiz_resolve_token`) + WS (`gameState/sessionUpdate/updatePlayers/endGame`) + read HTTP ponctuel (`players_get`) pour register/remote add-player | Mix preload HTTP (`blindtest_resolve_token`) + WS (`gameState/sessionUpdate/updatePlayers/endGame`) + read HTTP ponctuel (`players_get`) pour register/remote add-player | WS snapshot principal (`state`, `num_connected_players`) + read HTTP ponctuel `players_get` (register/remote add-player). Preload bingo ne contient pas players |
| Scores | Transportés dans `players` (preload quiz/bt + WS). Pas de read `session_get` dédié trouvé côté front | Idem quiz | Pas de score podium final dédié côté front; leaderboard bingo affiché surtout via players + winners mémoire |
| Podium / leaderboard final | Affiché depuis WS `endGame` (`m.podium` sinon `m.players`) `remote-ui.js:4822`; fallback tri front dans `renderEndPodium` `...:2812-2824` | Idem quiz | Podium construit depuis map `bingoWinners` mémoire (`remote-ui.js:2767`, `...:2845`), pas de read DB winners dédié |
| Winners phase | N/A | N/A | Reçus en live via WS `phase_over` (`remote-ws.js:709`) ou notifications WS parsées (`remote-ws.js:657-677`), stockés en mémoire (`remote-ui.js:4621-4635`) |
| Qui calcule | WS calcule et pousse; front peut retraiter/ordonner podium pour rendu (`remote-ui.js:2818`) | WS calcule et pousse; front peut retraiter/ordonner podium pour rendu | Front remote reconstruit podium depuis winners mémoire; organizer render peut fallback depuis store/players (`canvas_display.js:1177-1250`) |

### Focus reload session terminée
- Organizer: hydrate preload sans players (`boot_organizer.js:383-391`, `...:463-476`), puis attend WS pour résultats (`ws_effects.js:450-467`, `...:563-635`).
- Remote quiz/blindtest: peut afficher players preload immédiat (`remote-ui.js:231`, `...:458-464`), puis WS `remoteGameState` (`remote-ws.js:299`, `...:515-560`) et/ou `endGame` (`...:601-607`) pilote le rendu final.
- Remote bingo: pas de preload winners/podium; rendu fin dépend des messages WS reçus (`state/phase_over/notifications`). Aucun read front de `bingo_phase_winners` trouvé.

### Réponses factuelles demandées
- Quiz, reload terminé: rendu résultats vient principalement du snapshot WS (`endGame`), avec fallback visuel possible sur players preload/WS.
- Blindtest, reload terminé: idem quiz.
- Bingo, reload terminé: rendu résultats vient du snapshot WS `state` + événements live winners; pas de fetch HTTP front dédié winners.

### Gaps identifiés (sans patch)
- Aucun call-site front trouvé pour lire un podium DB stocké (`podium_json`) au reload.
- Aucun call-site front trouvé pour lire `bingo_phase_winners` (ni action read dédiée winners).
- Fallback `remote/state` en “Partie terminée” côté quiz/blindtest attend `m.podium/m.players` (`remote-ui.js:4716-4720`), alors que `remote-ws.js` n’injecte pas ces champs dans l’event `remote/state` (`remote-ws.js:520`, `...:542`).

- 2026-02-11 — code+doc — Patch 5 front identity persistence (bingo/blindtest/quiz): helper session-scoped `getOrCreatePlayerId({game,sid})` + migration legacy (`${game}:player_stable_id`, `${game}:player_id`, `player_id`) + logs `PLAYER_ID_STORAGE_RESOLVED {game,sid,source}`; wiring `register.js` + `play-ws.js` pour stabilité reload/changement d’onglet, et comportement attendu après suppression de clé scoped (nouvel ID généré au prochain register/auth de session).
- 2026-02-11 — code+doc — WS player registration canon strict: `play-ws.js` envoie désormais `registerPlayer { sessionId, player_id, playerId? (db) }` pour quiz/blindtest, envoie aussi `player_id` canon sur `auth_player` / `auth_player_paper` Bingo, et passe `checkAnswer` en `player_id` (plus de dépendance protocolaire au champ legacy `playerId` comme identifiant canon).
- 2026-02-11 — bugfix bingo/front — `player_register` ne part plus jamais avec un `player_id` numérique: normalisation stricte pré-appel (`preparePlayerIdPreRegister`) vers `p:<uuid>`, migration douce legacy (`player_id` numeric -> `player_db_id`), et log debug `PLAYER_ID_PRE_REGISTER` `{sessionId,pid_sent,pid_source,legacy_db_id_if_any}`.
- 2026-02-11 — code+doc — Player replacement UX (last connection wins): `play-ws.js` gère `SESSION_REPLACED` (mode read-only, blocage des envois WS, API `resumeAfterReplacement`), `ws_connector.js` stoppe la reconnexion auto après close code `4005` (`__WS_SUPPRESS_RECONNECT__` + event `ws/session_replaced`), `play-ui.js` affiche une bannière persistante + toast + bouton “Reprendre ici” (reload), force `Pause`, stoppe timers/reveal, et désactive réponses/grille locale (quiz/blindtest/bingo côté front commun).
- 2026-02-11 — code+doc — Register/identity front session-scoped (quiz/blindtest/bingo): `play/register.js` utilise `${slug}:player_stable_id:${sessionId}` comme source de vérité du `player_id` canonique (`p:<uuid>`), conserve `${slug}:player_stable_id` en compat legacy (migration douce si `keySid` match), et sépare désormais `player_id` (stable) de `player_db_id` (numérique legacy). Bingo envoie explicitement `player_id` sur `player_register/grid_assign/grid_hydrate/grid_cells_sync`, persiste `grid_id` aussi en clé session-scoped `${slug}:grid_id:${sessionId}`, et n’utilise plus la clé globale legacy comme vérité. Instrumentation debug `register/debug` maintenue (`*_tx`, `*_ok`, `*_fail`) avec `{sessionId, stable_key, player_id, player_id_origin, username}`.
- 2026-02-10 — code+doc — Patch Point 1 “event_id partout” (mode progressif, non-bloquant): `games_ajax.php` introduit une liste centrale d’actions mutatrices + helper `getOrCreateEventId` (UUID v4 serveur si absent/invalide), logs `EVENT_ID_RX` (info bridge) et warning structuré `MISSING_EVENT_ID`; idempotence `game_events` activée pour ces actions même sans `event_id` client initial. Front `canvasCall` injecte `event_id` pour actions mutatrices; `play/register.js` et `play/play-ui.js` propagent aussi `event_id` (`player_register`, `grid_assign`, `deactivate_player`). Compat maintenue: aucune requête rejetée pour `event_id` manquant.
- 2026-02-09 — code+doc — Reveal player key-first: `play-ws.js` consomme `answerReveal`; `play-ui.js` applique désormais le reveal par `data-option-key` (`applyRevealByKey`) avec fallback legacy texte/index, et émet les logs v1 debug `PLAYER_REVEAL_RX` / `PLAYER_REVEAL_APPLY` via `logger.global.js`.
- 2026-02-10 — audit+doc — Audit transversal `event_id + *_players` (`games_ajax.php`, `includes/canvas/php/*`, `play/*`, WS repos): confirmation que l’idempotence bridge dépend strictement de la présence de `event_id`; writes WS via `canvasWrite` injectent `event_id`, mais plusieurs writes front/organizer restent sans `event_id` (`player_register`, `deactivate_player`, `grid_assign`, `resetdemo`, `prizes_save`). Côté `*_players`, rôle observé = registre de participation/session + `is_active` partiel (déconnexion involontaire souvent mémoire seulement). Rapports: `notes/audit-event-id-players-2026-02-10.md` + `notes/audit-bingo-player-register-reinscription-2026-02-10.md`.
- 2026-02-09 — code+doc — Bots answer payload durci (`games/web/test_bots.php`): sélection désormais par objet option (et non par texte), envoi WS explicite `selectedOption=opt.raw` + `selectedOptionKey=opt.key` quand disponible; fallback texte conservé seulement si options legacy sans objet.
- 2026-02-09 — code+doc — Bots submit key compat: correction du payload `checkAnswer` dans `games/web/test_bots.php` (virgule manquante entre `selectedOption` et `selectedOptionKey`) pour éviter les envois sans clé menant à `PLAYER_ANSWER_EVAL method=\"legacy\"`.
- 2026-02-09 — code+doc — Player answers compat key-first: `play-ui.js` expose désormais `data-option-key=<option.key>` (si disponible) et `play-ws.js` envoie `checkAnswer { selectedOption, selectedOptionKey }` en conservant `selectedOption` pour compat legacy WS.
- 2026-02-09 — code+doc — Remote options jingle fix: `remote-ws.js` ne gate plus le refresh des propositions sur le seul changement d’index logique (cas jingle→round1, index logique inchangé), applique aussi les updates via `remote_sync` / `GAME_OPTIONS_UPDATED` / `STATE_SYNC`, et ajoute les logs v1 `REMOTE_OPTIONS_RX` + `REMOTE_OPTIONS_GUARD_BLOCK`; `remote-ui.js` ajoute `optionsLive` + log `REMOTE_OPTIONS_RENDER`. Compat convention logs: émission via bus `ui/remote:action` (suppression des `window.Logger.debug` directs pour `REMOTE_OPTIONS_*`). Stabilité reveal (quiz/blindtest): conservation de la correction sur `remote/options:proposals` + alias CSS `option-reveal` (compat `.reveal`) + reveal key-first strict (`data-option-key`) avec logs debug `BT_REMOTE_REVEAL_RX`/`BT_REMOTE_REVEAL_APPLY`; propagation `correctOptionKey` depuis `session_sync` vers WS quiz/blindtest.
- 2026-02-09 — code+doc — Front logger: ajout `ensureEntrySourceTs` dans `logger.global.js` pour garantir un timestamp source par entrée (`meta.client_ts` + `meta.event_ts`) avant `log_batch`/`log_event`; compat ISO conservée (`entry.ts` préservé si valide, fallback ISO sinon).
- 2026-02-08 — code+doc — Flush logs front harmonisé viewer-first: `LOG_FLUSH_TRY` (debug), `LOG_FLUSH_OK` (info), `LOG_FLUSH_FAIL` (warn) avec meta `{count, ws_ready_state, ws_url?}`; objectif: preuve d’ingestion front côté WS (`LOG_BATCH_RX`) et lisibilité timeline.
- 2026-02-09 — code+doc — Rollback Bingo flush: suppression de la voie `logs_proxy.php?flush=1`/`force_flush` (non native Bingo), retour au trigger viewer `localStorage.LOG_FLUSH_REQUEST` consommé par `logger.global.js` (`storage` -> `flushBufferToWS` -> `log_batch`).
- 2026-02-05 — code+doc — Bingo Canvas `phase_winner` persisté : ajout table `bingo_phase_winners`, colonnes de dénormalisation `phase_wins_count/last_won_*` sur `bingo_players`, handler PHP transactionnel (idempotence `event_id`, conflit inter-joueur, update phase_courante, logs PHASE_WINNER_*); doc canon synchronisée (DDL/OVERVIEW/MAP/write-map/HANDOFF).
- 2026-02-05 — code — Remote options diagnostics : instrumentation Bus-first (INTENT/SEND/ACK/OVERRIDDEN avec corrélation seq/latence) pour `updateGameOptions` (remote-ui/remote-ws, logger.global).
- 2026-02-05 — code — Diagnostics songDuration (organizer): logs Bus-first REMOTE_ACTION_RX/BLOCKED, ORG_TO_SERVER_SEND, ORG_OPTIONS_OBSERVED/OVERRIDDEN avec séquencement et latence (ws_effects, logger.global).
- 2026-02-05 — code — Remote_action guard split: les actions options (set_duration/choices/pause/option_type/manual) bypass le guard organizerCanControlSync; seules les commandes player restent bloquées si player_not_ready; log classification `remote_action_classified`.
- 2026-02-05 — doc — ajout contrats WS/HTTP, idempotence, paper-mode, glossaire états; README restructuré; TASKS mis à jour
- 2026-02-05 — doc — création du parcours repo-first (INDEX/README/TASKS) + intégration “surfaces d’intervention” (script map 20/80)
