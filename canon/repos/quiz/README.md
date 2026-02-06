# Repo `quiz` — Carte IA d’intervention (canon)

## Doc discipline
- `canon/repos/quiz/TASKS.md` à mettre à jour à chaque action significative (update-not-append si une tâche existe déjà).
- `canon/repos/quiz/README.md` à mettre à jour dès qu’un changement impacte le fonctionnel (flux/actions inter-repos, endpoints, env vars, idempotence/event_id, jalons logs, writes DB, etc.).
- En cas de divergence, le code fait foi ; corriger la doc immédiatement.

## Scope & entrypoints (confirmés)
- WS + HTTP unique : `web/server/server.js` monte un HTTP server (port `WS_PORT`, défaut 3032) avec `GET /logs?sid=<sid>[&limit=&page=]` (accepte aussi l’alias legacy `sessionId` ; pagination, max 5000) et attache `WebSocketServer` (ping 30s, terminate si pas de pong).
- PM2 : `web/server/pm2-ws.ecosystem.config.cjs` (app `server`, cwd=`web/server`, commande `bash -lc 'set -a; [ -f ./.env ] && source ./.env; set +a; exec node ./server.js'`, env `{WS_PORT=3032, NODE_ENV, LOG_DEBUG=0}` dev/prod).
- Déps Node : réutilise `web/ws/node_modules` (dossier `../ws`), scripts NPM dans `ws/package.json` (`npm test` via Jest, pas de start script).

## Runtime surfaces
- WebSocket : orchestration dans `web/server/actions/wsHandler.js` + `messaging.js` (logging `WS_IN/WS_OUT` throttle, gestion primary obsolète, loadtest, log_event/log_batch). Heartbeat serveur 30s ; message client `heartbeat` remet juste `isAlive` (pas de log).
- HTTP /logs : lecture `server-logs.log` + rotations ; tri décroissant + `statusSeed` pour contextualiser la page retournée.
- Logging : `web/server/logger_ws.js` génère JSONL (`ts, level, source=CQ_WS, sessionId, msg, data...`), rotation 10 Mo / 5 backups / purge 15j ; DEBUG_ON actif hors prod ou `LOG_DEBUG=1`.
- Canvas bridge : `web/server/actions/envUtils.js` (quiz) expose `CanvasAPI` (write auditée : `update_score`, `session_update`, `deactivate_player`, `player_register`; read: `session_primary_id`, `players_get`). Endpoint fallback `https://games.{dev|prod}.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas` (override `CANVAS_API_URL`), service-token `CANVAS_SERVICE_TOKEN` ou alias `CANVAS_API_SERVICE_TOKEN`, `event_id` auto pour writes, timeout 3s (`CANVAS_HTTP_TIMEOUT_MS`).
- Env loader : `web/server/localEnvLoader.js` charge une seule fois les clés whitelisted (`CANVAS_*`, `WS_SERVER_URL`, `CANVAS_ORIGIN`, `ORIGIN`, `APP_ENV`, `NODE_ENV`) depuis `.env` si absentes.

## Surfaces & URLs
- HTTP : `curl "http://127.0.0.1:${WS_PORT}/logs?sid=<sid>&limit=200"` (alias legacy `sessionId` accepté ; JSON, limite par défaut 500, max 5000). Source: web/server/server.js:56-150.
- WS : `ws://127.0.0.1:${WS_PORT}/` (aucun path custom passé à `WebSocket.Server`). Source: web/server/server.js:190-214.
- Domaines dev/prod : UNVERIFIED (pas d’host codé en dur). How to verify: `rg -n "cotton-quiz|\\.dev\\.|\\.prod\\." web/server`.

## Handshake & rôles
- Identifiant de session : champ `sessionId` dans les messages clients (`registerOrganizer`, `registerPlayer`, `checkSession`, etc.). Sources: web/server/actions/registration.js, web/server/actions/wsHandler.js:22-186.
- Organizer : message `registerOrganizer` avec `sessionId`, `isPrimary`, `maxPlayers?`, `sessionDemo?`; promotion du primary et ACK `registrationSuccess {role:"primary", primaryInstanceId}`. Source: registration.js (same structure que blindtest).
- Secondary : même message `registerOrganizer` avec `isPrimary=false`; refus si session inexistante. Source: registration.js.
- Player : message `registerPlayer` avec `sessionId`, `playerId`, `playerName`, option `isAdminPaper`; socket taggé `isPlayer`. Sources: registration.js; wsHandler.js:66-83.
- Admin papier : message `admin_player_register` routé vers `registerPlayer` avec `isAdminPaper=true`. Source: wsHandler.js:66-83.
- Heartbeat : serveur ping toutes 30s, clients doivent répondre `pong`; message client `heartbeat` remet `isAlive`. Sources: server.js:195-221; wsHandler.js:170-191.

## Canvas bridge — writes (payload minimal)
> `event_id` auto-ajouté dans `canvasWrite` pour les actions write. Source: web/server/actions/envUtils.js:107-205.
- `update_score`  
  ```json
  { "game": "quiz", "sessionPrimaryId": 123, "playerId": 1, "score": 10 }
  ```  
  Source: web/server/actions/gameplay.js:978-1011.
- `session_update`  
  ```json
  { "game": "quiz", "sessionId": "S1", "currentSongIndex": 3, "gameStatus": 2, "totalPlayers": 12, "podium": [] }
  ```  
  Source: web/server/actions/gameplay.js:1011-1044.
- `deactivate_player`  
  ```json
  { "game": "quiz", "playerId": 1, "sessionPrimaryId": 123 }
  ```  
  Source: web/server/actions/connection.js:60-83.
- `player_register`  
  ```json
  { "game": "quiz", "sessionPrimaryId": 123, "username": "Alice" }
  ```  
  Source: web/server/actions/loadtest.js (structure identique blindtest).

## Variables d’environnement (synthèse)
| Key | Required | Used in | Note |
| --- | --- | --- | --- |
| `WS_PORT` | Optionnel (def 3032) | `server.js` | Port HTTP/WS |
| `CANVAS_SERVICE_TOKEN` | Recommandé (writes) | `actions/envUtils.js` | Header `X-Service-Token` |
| `CANVAS_API_SERVICE_TOKEN` | Optionnel (alias) | `actions/envUtils.js` | Alias du token |
| `CANVAS_API_URL` | Optionnel | `actions/envUtils.js` | Override endpoint |
| `WS_SERVER_URL` / `CANVAS_ORIGIN` / `ORIGIN` | Optionnel | `envUtils.js` | Hint env pour host dev/prod |
| `APP_ENV` / `NODE_ENV` | Optionnel | `envUtils.js` | Influence choix env |
| `CANVAS_HTTP_TIMEOUT_MS` | Optionnel (def 3000) | `envUtils.js` | Timeout HTTP, abort si dispo |
| `LOG_DEBUG` | Optionnel | `logger_ws.js` | Force debug si ="1" |

## Interactions (résumé)
- WebSocket centralise les flux organizer/remote/player (commandes gameplay, options, loadtest) ; `log_event/log_batch` permettent d’ingérer les logs front dans la pipeline serveur.
- HTTP `/logs` fournit la lecture des traces JSONL produites par le WS ; aucune écriture HTTP en dehors de Canvas bridge.
- Canvas writes (service-token + `event_id`) dispatchées vers `games_ajax.php` (repo `games`).

## Actions clés (runbook court)
- Démarrer/relancer WS : `pm2 startOrReload web/server/pm2-ws.ecosystem.config.cjs --update-env` (repo `quiz`).
- Lire les logs : `curl "http://127.0.0.1:${WS_PORT}/logs?sessionId=<sid>&limit=200"` (adapter host si distant).
- Tester Canvas write : `node -e "require('./web/server/actions/envUtils').CanvasAPI.updateScore({ sessionPrimaryId:1, playerId:1, score:10 }, '')"` (token requis).
- Tests unitaires : `cd ws && npm test`.

## Happy path / diag rapide
1) `cd ws && npm install` si deps absentes (utilisées par `web/server`).
2) Copier `web/server/.env.template` → `.env`, définir token Canvas / WS_PORT.
3) Lancer PM2 ; vérifier log `CONFIG` dans `server-logs.log` (endpoint résolu, tokenPresent, envPathUsed).
4) Ouvrir clients ; observer `WS_IN/WS_OUT` dans logs.
5) Vérifier `/logs?sessionId=<sid>` pour la session cible.

## Scénarios d’échec fréquents
- `/logs` renvoie 404/LOG_FILE_NOT_FOUND : aucun fichier de log encore produit → générer trafic WS.
- Canvas write échoue (403/timeout) : service-token manquant ou timeout trop court → définir `CANVAS_SERVICE_TOKEN` ou augmenter `CANVAS_HTTP_TIMEOUT_MS`.
- Socket drop (inactivité) : absence de pong client → vérifier heartbeat côté front.

## Observability — logging canon (quiz)
- Format : LogEntry v1 `{v,ts,lvl,src=CQ_WS,evt,sid?,role?,eid?,msg?,meta?}` quand `WS_LOG_V1=1` (par défaut). Fallback v0 JSONL seulement si flag absent.
- Timeline INFO attendue (business) :
  - `QUESTION_START_SIGNAL_RX` (info) — dedup sid+item_index ; meta `{item_index, remainingTime}`.
  - `SESSION_PLAYER_COUNT` (info) — change-only, throttle 2s/sid ; meta `{count, prev_count, delta, reason, ...}`.
  - `GAME_ENDED` (info) — meta `{reason?, podium_size?, top3_player_ids?}`.
  - Notes : `PLAYER_REGISTERED` est debug ; `QUESTION_ENDED` est debug.
- Tech canon (niveaux) :
  - Lifecycle serveur : `WS_SERVER_LISTENING` (info), `WS_SERVER_CRITICAL_ERROR` (error), `WS_CLIENT_CONNECTED` / `WS_CLIENT_IDLE_DISCONNECTED` (info).
  - Messaging/protocol : `WS_MSG_PARSE_ERROR`/`WS_ERROR` (error), `WS_MSG_MISSING_SESSION_ID` (warn), `WS_MSG_UNKNOWN_TYPE` (warn), `WS_MSG_REJECTED_STALE_PRIMARY` (warn), `WS_SEND_*` erreurs/ warn, `WS_IN` / `WS_OUT` (debug, throttle).
  - Registration / session : `WS_REG_*` (info/warn/error), `PLAYER_REGISTERED` (debug), `SESSION_PLAYER_COUNT` (info).
  - Gameplay : `QUESTION_START_SIGNAL_RX` (info), `QUESTION_ENDED` (debug), `GAME_ENDED` (info), reste des `WS_GAME_*` inchangés.
  - Canvas/infra : `CONFIG` (info), `CANVAS_HTTP_NO_ABORT_CONTROLLER`, `CANVAS_WRITE_TIMEOUT`, `CANVAS_WRITE_FAIL`, `CANVAS_WRITE_NO_TOKEN` (warn/error).
  - Front ingestion : `FRONT_LOG` / `FRONT_LOG_BATCH_EMPTY` / `FRONT_LOG_MISSING_SESSION_ID` (warn/info), routes `log_event`/`log_batch` convertissent en v1.
- Règles anti-spam : heartbeat non loggé (message client mute), `SESSION_PLAYER_COUNT` change-only + throttle 2s, `WS_IN/WS_OUT` debug-only throttle, pas de dump podium complet en info (seulement top3 ids en GAME_ENDED).
- Stockage/accès : JSONL dans `web/server/server-logs.log` (+ rotation), lecture via `GET /logs?sid=<sid>&limit=&page=` (alias `sessionId` supporté).
