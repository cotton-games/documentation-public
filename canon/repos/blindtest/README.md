# Repo `blindtest` — Carte IA d’intervention (canon)

## Doc discipline
- `canon/repos/blindtest/TASKS.md` à mettre à jour à chaque action significative (update-not-append si une tâche existe déjà).
- `canon/repos/blindtest/README.md` à mettre à jour dès qu’un changement impacte le fonctionnel (flux/actions inter-repos, endpoints, env vars, idempotence/event_id, jalons logs, writes DB, etc.).
- En cas de divergence, le code fait foi ; corriger la doc immédiatement.

## Scope & entrypoints (confirmés)
- WS + HTTP unique : `web/server/server.js` lève un serveur HTTP (port `WS_PORT`, défaut 3031) avec endpoint `GET /logs?sessionId=<sid>[&limit=&page=]` (pagination, max 5000) et attache `WebSocketServer` (ping 30s, terminate si pas de pong).
- PM2 : `web/server/pm2-ws.ecosystem.config.cjs` (app `server`, cwd=`web/server`, commande `bash -lc 'set -a; [ -f ./.env ] && source ./.env; set +a; exec node ./server.js'`, env `{WS_PORT=3031, NODE_ENV, LOG_DEBUG=0}` pour dev/prod).
- Déps Node : réutilise `web/ws/node_modules` (dossier `../ws`), scripts NPM uniquement dans `ws/package.json` (`npm test` avec Jest).

## Runtime surfaces
- WebSocket : gestion dans `web/server/actions/wsHandler.js` + `messaging.js` (routing commandes/état, throttle log, detection primary obsolète). Heartbeat côté serveur toutes 30s ; message `heartbeat` côté client remet `isAlive`.
- HTTP /logs : lecture JSONL depuis `web/server/server-logs.log` + rotations (`server-logs.N.log`), tri décroissant, retour `statusSeed` pour diagnostiquer l’état.
- Logging : `web/server/logger_ws.js` écrit JSONL (`ts, level, source=BT_WS, sessionId, msg, data...`) → rotation 10 Mo / 5 backups / purge 15j ; DEBUG_ON actif hors prod ou si `LOG_DEBUG=1`.
- Canvas bridge : `web/server/actions/envUtils.js` fournit `CanvasAPI` (actions write auditées : `update_score`, `session_update`, `deactivate_player`, `player_register` ; autres calls ex: `session_primary_id`, `players_get`). Endpoint fallback `https://games.{dev|prod}.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas` sauf override `CANVAS_API_URL`. Service token via `CANVAS_SERVICE_TOKEN` ou alias `CANVAS_API_SERVICE_TOKEN`; `event_id` ajouté automatiquement pour les writes ; timeout 3s (`CANVAS_HTTP_TIMEOUT_MS`).
- Env loader : `web/server/localEnvLoader.js` charge une seule fois les clés whitelisted (`CANVAS_*`, `WS_SERVER_URL`, `ORIGIN`, `APP_ENV`, `NODE_ENV`) depuis `.env` si absentes du process.

## Surfaces & URLs
- HTTP : `curl "http://127.0.0.1:${WS_PORT}/logs?sessionId=<sid>&limit=200"` (JSON, limite par défaut 500, max 5000). Source: web/server/server.js:56-150.
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

## Observability (viewer-first) — signaux à chercher
- `CONFIG` au boot (endpoint Canvas résolu, tokenPresent, envPathUsed). Source: web/server/actions/envUtils.js:150-205.
- `WS_IN` / `WS_OUT` sur types whitelisted (payload compact) + throttle. Sources: wsHandler.js:22-186; messaging.js:10-88.
- Connexions/déconnexions joueurs/organizers (log.info/warn). Sources: wsHandler.js:22-186; connection.js:1-120.
- Heartbeat/ping manqué → terminate. Source: server.js:195-221.
- `log_event` / `log_batch` (logs front injectées avec `event`, `ns`, `data`). Source: wsHandler.js:132-199.
- Canvas writes OK/KO : `CANVAS_WRITE_NO_TOKEN`, `Canvas API write failed`, timeouts. Source: actions/envUtils.js:150-205.
- Filtres utiles : `source=BT_WS`, `sessionId=<sid>`, `event` in (`CONFIG`,`WS_IN`,`WS_OUT`,`CANVAS_*`); debug activable via `LOG_DEBUG=1`.
- Accès HTTP : `GET /logs?sessionId=<sid>[&limit=&page=]` (CORS `*`, GET/OPTIONS) retourne `entries` triées + `statusSeed`. Source: server.js:56-150.
- Stockage : fichiers `web/server/server-logs.log` + rotations `server-logs.N.log`. Source: logger_ws.js:6-52.
