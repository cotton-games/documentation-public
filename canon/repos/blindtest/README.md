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
- HTTP /logs : lecture JSONL depuis `web/server/server-logs.log` + rotations (`server-logs.N.log`), tri décroissant, retour `statusSeed` pour diagnostiquer l’état.
- Logging : `web/server/logger_ws.js` écrit JSONL (`ts, level, source=BT_WS, sessionId, msg, data...`) → rotation 10 Mo / 5 backups / purge 15j ; DEBUG_ON actif hors prod ou si `LOG_DEBUG=1`.
- Canvas bridge : `web/server/actions/envUtils.js` fournit `CanvasAPI` (actions write auditées : `update_score`, `session_update`, `deactivate_player`, `player_register` ; autres calls ex: `session_primary_id`, `players_get`). Endpoint fallback `https://games.{dev|prod}.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas` sauf override `CANVAS_API_URL`. Service token via `CANVAS_SERVICE_TOKEN` ou alias `CANVAS_API_SERVICE_TOKEN`; `event_id` ajouté automatiquement pour les writes ; timeout 3s (`CANVAS_HTTP_TIMEOUT_MS`).
- Env loader : `web/server/localEnvLoader.js` charge une seule fois les clés whitelisted (`CANVAS_*`, `WS_SERVER_URL`, `ORIGIN`, `APP_ENV`, `NODE_ENV`) depuis `.env` si absentes du process.

## Surfaces & URLs
- HTTP : `curl "http://127.0.0.1:${WS_PORT}/logs?sid=<sid>&limit=200"` (alias `sessionId` toujours accepté ; JSON, limite par défaut 500, max 5000). Source: web/server/server.js:56-150.
- WS : `ws://127.0.0.1:${WS_PORT}/` (aucun path dédié passé à `WebSocket.Server`). Source: web/server/server.js:190-214.
- Domaines dev/prod : UNVERIFIED (aucun host codé en dur). How to verify: `rg -n "cotton-quiz|\\.dev\\.|\\.prod\\." web/server`.

## Handshake & rôles
- Identifiant de session : champ `sessionId` dans les messages clients (`registerOrganizer`, `registerPlayer`, `checkSession`, `remoteGameState`, etc.). Source: web/server/actions/registration.js:9-126,320-384; wsHandler.js:23-186.
- Organizer : message `registerOrganizer` avec `sessionId`, `isPrimary` (true/false), `maxPlayers?`, `sessionDemo?`; promotion du primary et émission `registrationSuccess {role:"primary", primaryInstanceId}`. Source: registration.js:27-126.
- Secondary (télécommande) : même message `registerOrganizer` mais `isPrimary=false`; refus si session inexistante. Source: registration.js:19-55.
- Player : message `registerPlayer` avec `sessionId`, `playerId`, `playerName`, option `isAdminPaper`; socket taggé `isPlayer` et `playerId`. Source: registration.js:320-384; wsHandler.js:66-83.
- Admin papier : `admin_player_register` routé vers `registerPlayer` avec `isAdminPaper=true`. Source: wsHandler.js:66-83.
- Heartbeat : serveur ping toutes 30s, `pong` remet `isAlive`; message client `heartbeat` accepté et loggé. Source: server.js:195-221; wsHandler.js:170-191.

## Canvas bridge — writes (payload minimal)
> `event_id` auto-ajouté dans `canvasWrite` pour chaque action write. Source: web/server/actions/envUtils.js:107-205.
- `update_score`  
  ```json
  { "game": "blindtest", "sessionPrimaryId": 123, "playerId": 1, "score": 10 }
  ```  
  Source: web/server/actions/gameplay.js:883-910.
- `session_update`  
  ```json
  { "game": "blindtest", "sessionId": "S1", "currentSongIndex": 3, "gameStatus": 2, "totalPlayers": 12, "podium": [] }
  ```  
  Source: web/server/actions/gameplay.js:909-946.
- `deactivate_player`  
  ```json
  { "game": "blindtest", "playerId": 1, "sessionPrimaryId": 123 }
  ```  
  Source: web/server/actions/connection.js:61-83.
- `player_register`  
  ```json
  { "game": "blindtest", "sessionPrimaryId": 123, "username": "Alice" }
  ```  
  Source: web/server/actions/loadtest.js:14-24.

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
| `LOG_DEBUG` | Optionnel | `logger_ws.js` | Force debug si ="1" |

## Interactions (résumé)
- Clients Canvas ↔ WebSocket (`wsHandler`/`messaging`) : routing des commandes `register*`, gameplay, options, loadtest, log_event/log_batch (logs front injectées dans pipeline serveur).
- Bridge HTTP `/logs` sert uniquement à lire les JSONL générés par `logger_ws.js`.
- Writes Canvas via `CanvasAPI` (service-token, `event_id` auto) → PHP `games_ajax.php` (repo `games`).

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
- Tech canon (niveaux) :
  - Lifecycle serveur : `WS_SERVER_LISTENING` (info), `WS_SERVER_CRITICAL_ERROR` (error), `WS_CLIENT_CONNECTED` / `WS_CLIENT_IDLE_DISCONNECTED` (info).
  - Messaging/protocol : `WS_MSG_PARSE_ERROR`/`WS_ERROR` (error), `WS_MSG_MISSING_SESSION_ID` (warn), `WS_MSG_UNKNOWN_TYPE` (warn), `WS_MSG_REJECTED_STALE_PRIMARY` (warn), `WS_SEND_*` erreurs/warn, `WS_IN` / `WS_OUT` (debug, throttle).
  - Registration / session : `WS_REG_*` (info/warn/error), `PLAYER_REGISTERED` (debug), `SESSION_PLAYER_COUNT` (info).
  - Gameplay : `TRACK_START_SIGNAL_RX` (info), `TRACK_ENDED` (debug), `GAME_ENDED` (info), autres `WS_GAME_*` conservés.
  - Canvas/infra : `CONFIG`, `CANVAS_HTTP_NO_ABORT_CONTROLLER`, `CANVAS_WRITE_TIMEOUT`, `CANVAS_WRITE_FAIL`, `CANVAS_WRITE_NO_TOKEN` (warn/error).
  - Front ingestion : `FRONT_LOG` / `FRONT_LOG_BATCH_EMPTY` / `FRONT_LOG_MISSING_SESSION_ID` (warn/info), routes `log_event`/`log_batch` converties en v1.
- Règles anti-spam : heartbeat non loggé, `SESSION_PLAYER_COUNT` change-only + throttle 2s, `WS_IN/WS_OUT` debug-only throttlés, pas de dump podium complet en info (top3 ids seulement dans GAME_ENDED).
- Stockage/accès : JSONL dans `web/server/server-logs.log` (+ rotation), lecture via `GET /logs?sid=<sid>&limit=&page=` (alias `sessionId` supporté).
