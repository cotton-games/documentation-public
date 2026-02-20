# Repo `blindtest` — Carte IA d’intervention (canon)

## Doc discipline
- `canon/repos/blindtest/TASKS.md` à mettre à jour à chaque action significative (update-not-append si une tâche existe déjà).
- `canon/repos/blindtest/README.md` à mettre à jour dès qu’un changement impacte le fonctionnel (flux/actions inter-repos, endpoints, env vars, idempotence/event_id, jalons logs, writes DB, etc.).
- En cas de divergence, le code fait foi ; corriger la doc immédiatement.

## Scope & entrypoints (confirmés)
- WS + HTTP unique : `web/server/server.js` lève un serveur HTTP (port `WS_PORT`, défaut 3031) avec endpoint `GET /logs?sid=<sid>[&limit=&page=]` (alias legacy `sessionId` accepté ; pagination, max 5000) et attache `WebSocketServer` (ping 30s, terminate si pas de pong).
- PM2 : `web/server/pm2-ws.ecosystem.config.cjs` (app `server`, cwd=`web/server`, commande `bash -lc 'set -a; [ -f ./.env ] && source ./.env; set +a; exec node ./server.js'`, env `{WS_PORT=3031, NODE_ENV, LOG_DEBUG=0}` pour dev/prod).
- Déps Node : réutilise `web/ws/node_modules` (dossier `../ws`), scripts NPM uniquement dans `ws/package.json` (`npm test` avec Jest).

## Runtime surfaces
- WebSocket : gestion dans `web/server/actions/wsHandler.js` + `messaging.js` (routing commandes/état, throttle log, detection primary obsolète). Heartbeat côté serveur toutes 30s ; message client `heartbeat` remet `isAlive` sans log.
- Reveal remote/options: les payloads de session propagent `correctOptionKey` (en plus de `correctOption`) pour permettre un matching key-first côté remote; les options blindtest transportent une `key` stable (`optionType:keyOf(song)`).
- Reveal player: la bonne réponse est désormais envoyée via `answerReveal` (post-verrou/finale timer) avec `{correctOption, correctOptionKey, currentSongIndex}` uniquement pour joueurs en erreur; `answerResult` ne transporte plus la solution avant reveal.
- HTTP /logs : lecture JSONL depuis `web/server/server-logs.log` + rotations (`server-logs.N.log`), tri décroissant, retour `statusSeed` pour diagnostiquer l’état.
- HTTP `/force_flush` : endpoint legacy présent côté WS (non requis pour le flux Bingo-like actuel du viewer `games`).
- Logging : `web/server/logger_ws.js` écrit JSONL (`ts, level, source=BT_WS, sessionId, msg, data...`) → rotation 10 Mo / 5 backups / purge 15j ; `LOG_DEBUG` explicite est prioritaire (`1`=on, `0`=off), sinon fallback sur `NODE_ENV/APP_ENV`.
- Canvas bridge : `web/server/actions/envUtils.js` fournit `CanvasAPI` (actions write auditées : `update_score`, `session_update`, `deactivate_player`, `player_register` ; autres calls ex: `session_primary_id`, `players_get`). Endpoint fallback `https://games.{dev|prod}.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas` sauf override `CANVAS_API_URL`. Service token via `CANVAS_SERVICE_TOKEN` ou alias `CANVAS_API_SERVICE_TOKEN`; `event_id` ajouté automatiquement pour les writes ; timeout 3s (`CANVAS_HTTP_TIMEOUT_MS`). Les writes player-scoped (`update_score`, `deactivate_player`) valident désormais côté WS un scope canon key-first (`player_id` obligatoire, `playerId` numeric-only) avec log `WS_API_PAYLOAD_VALIDATED`.
- Env loader : `web/server/localEnvLoader.js` charge une seule fois les clés whitelisted avec `preferLocal: true` (source de vérité locale). Si une clé whitelistée est présente dans `.env`, elle écrase `process.env` ; si elle est absente de `.env`, fallback sur la valeur process (ex: PM2).

## Surfaces & URLs
- HTTP : `curl "http://127.0.0.1:${WS_PORT}/logs?sid=<sid>&limit=200"` (alias `sessionId` toujours accepté ; JSON, limite par défaut 500, max 5000). Source: web/server/server.js:56-150.
- WS : `ws://127.0.0.1:${WS_PORT}/` (aucun path dédié passé à `WebSocket.Server`). Source: web/server/server.js:190-214.
- Domaines dev/prod : UNVERIFIED (aucun host codé en dur). How to verify: `rg -n "cotton-quiz|\\.dev\\.|\\.prod\\." web/server`.

## Handshake & rôles
- Identifiant de session : champ `sessionId` dans les messages clients (`registerOrganizer`, `registerPlayer`, `checkSession`, `remoteGameState`, etc.). Source: web/server/actions/registration.js:9-126,320-384; wsHandler.js:23-186.
- Organizer : message `registerOrganizer` avec `sessionId`, `isPrimary` (true/false), `maxPlayers?`, `sessionDemo?`; promotion du primary et émission `registrationSuccess {role:"primary", primaryInstanceId}`. Source: registration.js:27-126.
- Secondary (télécommande) : même message `registerOrganizer` mais `isPrimary=false`; refus si session inexistante. Source: registration.js:19-55.
- Player : message `registerPlayer` avec `sessionId`, `player_id` canon obligatoire (`p:<uuid>`), `playerName`, et `playerId` numérique optionnel (`player_db_id` compat). Socket taggé `isPlayer`, `playerId=<player_id canon>`, `playerDbId=<db id?>`. Source: registration.js; wsHandler.js.
- Politique player: **last connection wins** par clé canon `(sid, player_id)`; un nouveau `registerPlayer` remplace l’ancien socket joueur actif.
- Signal replacement: le socket remplacé reçoit `SESSION_REPLACED` puis fermeture WS `4005` (`player replaced`), mappée en intent `player-replaced` au disconnect handler.
- Admin papier : `admin_player_register` routé vers `registerPlayer` avec `isAdminPaper=true`. Source: wsHandler.js:66-83.
- Heartbeat : serveur ping toutes 30s, `pong` remet `isAlive`; message client `heartbeat` accepté et loggé. Source: server.js:195-221; wsHandler.js:170-191.

## Canvas bridge — writes (payload minimal)
> `event_id` auto-ajouté dans `canvasWrite` pour chaque action write. Source: web/server/actions/envUtils.js:107-205.
- `update_score`  
  ```json
  { "game": "blindtest", "sessionPrimaryId": 123, "player_id": "p:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "playerId": 1, "score": 10 }
  ```  
  Note: `player_id` canon est prioritaire; `playerId` est optionnel et strictement numérique (compat).
  Source: web/server/actions/gameplay.js:883-910.
- `session_update`  
  ```json
  { "game": "blindtest", "sessionId": "S1", "currentSongIndex": 3, "gameStatus": 2, "totalPlayers": 12, "podium": [] }
  ```  
  Source: web/server/actions/gameplay.js:909-946.
- `deactivate_player`  
  ```json
  { "game": "blindtest", "playerId": 1, "player_id": "p:uuid-or-stable-key", "sessionPrimaryId": 123 }
  ```  
  Note: côté glue, retour enrichi avec `identity_mode` (`canon|legacy`) et `legacy_identity` (bool).
  Source: web/server/actions/connection.js:61-83.
- `player_register`  
  ```json
  { "game": "blindtest", "sessionPrimaryId": 123, "username": "Alice", "player_id": "p:uuid-session-scoped" }
  ```  
  Note: côté WS `registerPlayer`, `player_id` est désormais strictement requis (reject `PLAYER_ID_MISSING_OR_INVALID` sinon). Côté bridge Canvas, `playerId` numérique reste optionnel.
  Source: web/server/actions/loadtest.js + `../games/web/includes/canvas/play/register.js`.
- Loadtest bots (`web/server/actions/loadtest.js`) : `player_id` est généré de manière déterministe par bot/session (`p:uuidv5-ish( "cotton-bot-player-id-v1|blindtest|<sid>|<botId>" )`), envoyé sur `registerPlayer` et `checkAnswer`; `playerId` n’est joint que s’il est connu et numérique.

## Variables d’environnement (synthèse)
| Key | Required | Used in | Note |
| --- | --- | --- | --- |
| `WS_PORT` | Optionnel (def 3031) | `server.js` | Port HTTP/WS |
| `CANVAS_SERVICE_TOKEN` | Recommandé (writes) | `actions/envUtils.js` | Header `X-Service-Token` |
| `CANVAS_API_SERVICE_TOKEN` | Optionnel (alias) | `actions/envUtils.js` | Alias du token |
| `CANVAS_API_URL` | Optionnel | `actions/envUtils.js` | Override endpoint Canvas |
| `WS_SERVER_URL` / `CANVAS_ORIGIN` / `ORIGIN` | Optionnel | `envUtils.js` | Hint dev/prod pour choisir host |
| `APP_ENV` / `NODE_ENV` | Optionnel | `envUtils.js` | Influence choix dev/prod |
| `CANVAS_HTTP_TIMEOUT_MS` | Optionnel (def 3000) | `envUtils.js` | Timeout HTTP + abort si dispo |
| `LOG_DEBUG` | Optionnel | `logger_ws.js` | Override explicite debug (`1`=on, `0`=off) |

### Priorité de configuration (`.env` vs PM2)
- Mode en place : `.env` local prioritaire pour les clés whitelistées.
- Clés whitelistées côté bootstrap WS (`server.js`) : `CANVAS_SERVICE_TOKEN`, `CANVAS_API_SERVICE_TOKEN`, `CANVAS_API_URL`, `CANVAS_ORIGIN`, `ORIGIN`, `WS_SERVER_URL`, `WS_PORT`, `CANVAS_HTTP_TIMEOUT_MS`, `CANVAS_UPDATE_SCORE_CONCURRENCY`, `LOG_DEBUG`, `APP_ENV`, `NODE_ENV`.
- Clé additionnelle whitelistée côté bridge (`actions/envUtils.js`) : `CANVAS_HTTP_TIMEOUT_MS`.
- Conséquence: tu peux omettre des clés dans `.env` pour conserver les defaults PM2/process ; seules les clés présentes dans `.env` sont forcées.

## Interactions (résumé)
- Clients Canvas ↔ WebSocket (`wsHandler`/`messaging`) : routing des commandes `register*`, gameplay, options, loadtest, log_event/log_batch (logs front injectées dans pipeline serveur).
- Bridge HTTP `/logs` sert uniquement à lire les JSONL générés par `logger_ws.js`.
- Viewer “Forcer flush” (Bingo-like) : `logs_session.html` écrit `localStorage.LOG_FLUSH_REQUEST` ; `logger.global.js` (front) écoute `storage` et exécute `flushBufferToWS()` qui envoie `log_batch` sur la WS de session.
- Flush auto fin de session (Bingo-like) : `logger.global.js` déclenche `flushBufferToWS()` quand `gameStatus === "Partie terminée"`.
- Writes Canvas via `CanvasAPI` (service-token, `event_id` auto) → PHP `games_ajax.php` (repo `games`).
- Quit volontaire player: `quitGame` est traité côté WS serveur (`handleDisconnect`), qui déclenche `deactivate_player` via Canvas bridge (pas d’appel API front direct).

## Actions clés (runbook court)
- Lancer WS (dev/prod) : `pm2 startOrReload web/server/pm2-ws.ecosystem.config.cjs --update-env` (cwd repo `blindtest`).
- Consulter logs d’une session : `curl "http://127.0.0.1:${WS_PORT}/logs?sessionId=<sid>&limit=200"` (adapter host si distant).
- Tester Canvas write : `node -e "require('./web/server/actions/envUtils').CanvasAPI.updateScore({ sessionPrimaryId:1, playerId:1, score:10 }, '')"` (token requis).
- Tests unitaires (deps partagées) : `cd ws && npm test`.

## Happy path / diag rapide
1) Installer deps si absentes : `cd ws && npm install` (utilisé par `web/server`).
2) Copier `web/server/.env.template` → `.env`, renseigner token Canvas/WS_PORT si besoin.
3) Démarrer PM2 (cf. Actions clés) ; vérifier log `CONFIG` initial dans `server-logs.log` (endpoint, tokenPresent, envPathUsed).
4) Ouvrir un client organizer/player ; vérifier messages `WS_IN/WS_OUT` dans logs.
5) `/logs?sessionId=<sid>` retourne des entrées triées + `statusSeed` (état le plus récent).

## Scénarios d’échec fréquents
- `/logs` renvoie 404/LOG_FILE_NOT_FOUND : aucun `server-logs*.log` encore créé → générer du trafic WS puis relire.
- Canvas write 403 / timeout : token manquant (`CANVAS_SERVICE_TOKEN` absent) ou timeout >3s → définir le token, augmenter `CANVAS_HTTP_TIMEOUT_MS` si besoin.
- Clients drop pour inactivité : absence de `pong` → vérifier heartbeat client ou firewall websockets.

## Observability — logging canon (blindtest)
- Format : LogEntry v1 `{v,ts,lvl,src=BT_WS,evt,sid?,role?,eid?,msg?,meta?}` (par défaut). Fallback v0 JSONL seulement si `WS_LOG_V1` absent.
- Timeline INFO attendue (business) :
  - `TRACK_START_SIGNAL_RX` (info) — dedup sid+item_index ; meta `{item_index, remainingTime}`.
  - `SESSION_PLAYER_COUNT` (info) — change-only, throttle 2s/sid ; meta `{count, prev_count, delta, reason, ...}`.
  - `GAME_ENDED` (info) — meta `{reason?, podium_size?, top3_player_ids?}`.
  - Notes : `PLAYER_REGISTERED` est debug ; `TRACK_ENDED` est debug.
- Garde niveau viewer-first :
  - INFO whitelist uniquement (lifecycle utile + timeline business ci-dessus + `WS_LIVE`/`AUTH_OK` si présents).
  - Tous les événements `info` hors whitelist sont downgradés en `debug` par `logger_v1` (ex: `WS_GAME_*`, updates fréquents, trafic interne).
- Tech canon (niveaux) :
  - Lifecycle serveur : `WS_SERVER_LISTENING` (info), `WS_SERVER_CRITICAL_ERROR` (error), `WS_CLIENT_CONNECTED` / `WS_CLIENT_IDLE_DISCONNECTED` (info).
  - Messaging/protocol : `WS_MSG_PARSE_ERROR`/`WS_ERROR` (error), `WS_MSG_MISSING_SESSION_ID` (warn), `WS_MSG_UNKNOWN_TYPE` (warn), `WS_MSG_REJECTED_STALE_PRIMARY` (warn), `WS_SEND_*` erreurs/warn, `WS_IN` / `WS_OUT` (debug, throttle).
- Registration / session : `WS_REG_*` (info/warn/error), `PLAYER_REGISTERED` (debug), `SESSION_PLAYER_COUNT` (info).
- Hydratation players (boot/reprise organizer) : `PLAYERS_HYDRATE_START` (info), `PLAYERS_HYDRATE_ROW_SKIPPED` (warn/debug), `PLAYERS_HYDRATE_DEDUPED` (debug), `PLAYERS_HYDRATE_DONE` (info, compteurs `rows_read/rows_kept/rows_skipped/rows_deduped`).
- Déconnexion player : `WS_CONN_PLAYER_MARK_INACTIVE` (info) avec `sid` lors d’une désactivation DB `deactivate_player` réussie (quit volontaire).
- Déconnexion player (Patch 2): `PLAYER_DEACTIVATE_BY_KEY_OK` (info) et `PLAYER_DEACTIVATE_BY_KEY_ERR` (error) pour tracer la désactivation par clé stable `player_id` avec fallback legacy.
- Correctif disconnect organizer (2026-02-12): `disconnectPlayers` reconstruit explicitement `deactivations` avant `Promise.allSettled`; évite le crash runtime `ReferenceError: deactivations is not defined` et garantit la séquence deactivate DB + fermeture sockets en fin de session.
- Gameplay : `TRACK_START_SIGNAL_RX` (info), `TRACK_ENDED` (debug), `GAME_ENDED` (info), autres `WS_GAME_*` conservés.
- Réponses player (debug): `PLAYER_ANSWER_RX` (`has_key`, `selectedKey?`, `selectedTextHash?`) puis `PLAYER_ANSWER_EVAL` (`ok`, `method:key|legacy`, `mismatch_reason?`).
- Canvas/infra : `CONFIG`, `CANVAS_HTTP_NO_ABORT_CONTROLLER`, `CANVAS_WRITE_TIMEOUT`, `CANVAS_WRITE_FAIL`, `CANVAS_WRITE_NO_TOKEN` (warn/error).
- Front ingestion : `log_event`/`log_batch` valident une entrée v1 minimale (`v, ts, lvl, src, evt, sid` avec compat sid `sid|sessionId|session_id`) puis append l’entrée front elle-même en JSONL (plus de wrapper `evt=FRONT_LOG`).
- Front ingestion : `LOG_BATCH_RX` reste l’unique log batch WS (debug, msg=`Front log batch received`, meta `{sid,count,srcs,first_ts,last_ts}`), rejets en `FRONT_ENTRY_REJECTED` et batch vide en `FRONT_BATCH_EMPTY`.
- Compat sid front : `sid = entry.sid || entry.sessionId || entry.session_id`; si absent, logs warn sans dump (`entry_keys/src/evt` seulement).
- Enrichissement front ingéré : `entry.game` forcé à `blindtest` si absent, `meta.ingested_by="BT_WS"` + `meta.ws_role/ws_client_id` si dispo, `msg` fallback `evt`, `src` compat `entry.src || entry.source`, `meta` aplatie (pas de `meta.meta`).
- Préservation temporelle front : `entry.ts` ISO valide est conservé (pas d’écrasement à l’ingestion). Si `entry.ts` absent/invalide, fallback `entry.ts=now` + `meta.ts_fallback=true`. `meta.ingested_at` (ISO) trace l’instant d’ingestion.
- Compat flush-time élargie : si un timestamp source est présent (`entry.client_ts`, `entry.clientTs`, `meta.client_ts`, `meta.clientTs`, `meta.event_ts`, `meta.eventTs`, `meta.original_ts`, `meta.originalTs`, `meta.ts`, `meta.time`) et que `entry.ts` ressemble à un flush-time (écart <2s avec now ou timestamp massif dans le batch), `entry.ts` est restauré depuis ce timestamp source (et `client_ts/clientTs` est nettoyé de la meta).
- Front `games` (2026-02-09) : `logger.global.js` normalise désormais chaque entrée avant `log_batch/log_event` et embarque systématiquement `meta.client_ts` + `meta.event_ts` (timestamp source), ce qui permet au WS de corriger les flush-time sur les sessions nouvellement émises.
- Correctif writer WS (2026-02-09) : `web/server/logger_ws.js` préserve désormais `payload.ts` (ISO) au lieu de réécrire systématiquement `ts` à l’instant d’append JSONL.
  - `FORCE_FLUSH_RX` et `FORCE_FLUSH_BROADCAST` restent disponibles en debug pour l’endpoint legacy `/force_flush`.
- Correctif debug gate (2026-02-10) : `web/server/logger_ws.js` applique désormais le filtre debug aussi sur `Logger.logV1(...)` ; avec `LOG_DEBUG=0`, les entrées `lvl=debug` (y compris issues de `logger_v1`) ne sont plus écrites.
- Correctif chargement env (2026-02-10) : `web/server/server.js` inclut `LOG_DEBUG` dans la whitelist de `loadLocalEnvOnce(...)`, pour éviter les faux positifs debug quand le process n’est pas lancé via PM2 `source .env`.
- Règles anti-spam : heartbeat non loggé, `SESSION_PLAYER_COUNT` change-only + throttle 2s, `WS_IN/WS_OUT` debug-only throttlés, pas de dump podium complet en info (top3 ids seulement dans GAME_ENDED).
- Alignement Bingo disconnect : `WS_CLIENT_DISCONNECTED` est désormais `debug` pour `role=player` en fermeture volontaire, et `info` sinon (`player` involontaire + `organizer/remote/server`).
- Enrichissement disconnect (2026-02-13) : `WS_CLIENT_DISCONNECTED` embarque aussi `meta.ws_client_id`, `meta.ws_role` et `meta.closeReason` (en plus de `closeCode/intent/involuntary`) pour améliorer la corrélation front (`SUPPORT_*`) ↔ coupures WS.
- Qualité viewer : `msg` toujours non vide (fallback `msg=evt`) et `meta` aplatie (pas de `meta.meta`) avec noyau timeline `{game, ws_role, ingested_by, ...}`.
- Stockage/accès : JSONL dans `web/server/server-logs.log` (+ rotation), lecture via `GET /logs?sid=<sid>&limit=&page=` (alias `sessionId` supporté).

## Role derivation (WS logs)
- Principe : `role` (champ top-level LogEntry v1) est dérivé côté WS via une heuristique type Bingo, avec priorité `role explicite` > `meta.ws_role/meta.role/...` > endpoint/event hints > fallback `server`.
- Normalisation canonique : `organizer | player | remote | server` (pas de `unknown`, `secondary`, `primary`, `viewer` en sortie finale).
- `WS_IN/WS_OUT` injectent désormais le contexte socket/cible (`ws_role`, `ws_client_id`) pour permettre un `role` top-level correct côté viewer.
- Garde-fou ingestion front (`src=GAMES`) : les entrées front gardent leur `entry.role` d’origine; le WS enrichit uniquement la meta (`ingested_by`, `ws_role`, `ws_client_id`) sans écraser le rôle front.
- Viewer-first : le viewer doit lire `role` (champ top-level), pas `meta.ws_role`.
