# Repo `quiz` — Tasks

## Facts confirmed
- Entrypoint `web/server/server.js` : HTTP `GET /logs?sessionId=` (limit def 500, max 5000, renvoie `statusSeed`) + WebSocketServer (port `WS_PORT` def 3032, ping/pong 30s, terminate si pas de pong) utilisant `ws`/`node-fetch` depuis `../ws/node_modules`.
- PM2 runtime `web/server/pm2-ws.ecosystem.config.cjs` : app `server`, cwd=`web/server`, script `bash -lc 'set -a; [ -f ./.env ] && source ./.env; set +a; exec node ./server.js'`, env `{NODE_ENV, WS_PORT=3032, LOG_DEBUG=0}` en dev/prod.
- Logging pipeline `web/server/logger_ws.js` : JSONL `ts, level, source=CQ_WS, sessionId, msg, data...` → `server-logs.log`, rotation 10 Mo / 5 backups / purge 15j ; DEBUG_ON actif en dev ou si `LOG_DEBUG=1`.
- Canvas bridge `web/server/actions/envUtils.js` : endpoint fallback `https://games.{dev|prod}.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas` (override `CANVAS_API_URL`), actions write `update_score|session_update|deactivate_player|player_register` (ajoute `event_id` auto), headers token `CANVAS_SERVICE_TOKEN` ou alias `CANVAS_API_SERVICE_TOKEN`, timeout 3s (`CANVAS_HTTP_TIMEOUT_MS`), read helpers `session_primary_id` / `players_get`.
- Env loader `web/server/localEnvLoader.js` : charge une fois les clés whitelisted (`CANVAS_*`, `WS_SERVER_URL`, `CANVAS_ORIGIN`, `ORIGIN`, `APP_ENV`, `NODE_ENV`) depuis `.env` si absentes.
- WS logging & relay : `wsHandler`/`messaging` loggent `WS_IN/WS_OUT` avec throttle; `log_event`/`log_batch` insèrent les logs front ; routes gameplay/options/loadtest gérées côté WS.
- NPM scripts via `ws/package.json` (nommé `bingo_ws_server`) : `npm test` (jest); runtime via PM2/`node web/server/server.js` (pas de script start).

## UNVERIFIED / TODO verify
- Config PM2/host production spécifique non identifiée (seul fichier générique) ; vérifier déploiement réel.
- Existence d’un watcher/deploy externe (systemd/CI) non documentée.
- Couverture tests Jest : suites absentes dans repo ; confirmer localisation ou besoin de créer.

## How to verify
- ### Repo-local quick checks
  - Handshake/auth : `rg -n "registerOrganizer|registerPlayer|sessionId" web/server`
  - WS routing / message types : `rg -n "case '\\w+'|WS_IN|WS_OUT" web/server/actions/wsHandler.js web/server/messaging.js`
  - Logs front (proxy) : `rg -n "log_event|log_batch" web/server`
  - CanvasAPI writes : `rg -n "update_score|session_update|deactivate_player|player_register" web/server/actions`
  - /logs endpoint : `rg -n "/logs" web/server/server.js`
  - PM2 : `rg -n "pm2|ecosystem" web/server`
  - Ports/env : `rg -n "WS_PORT|PORT|CANVAS_|ORIGIN|NODE_ENV" web/server`
  - WS server binding : `rg -n "WebSocket\\.Server|createServer\\(" web/server/server.js`
  - Bridge smoke test : `node -e "require('./web/server/actions/envUtils').CanvasAPI.updateScore({ sessionPrimaryId:1, playerId:1, score:1 }, '')"` (token requis)
- PM2 prod : `find /var/www/quiz* -maxdepth 3 -type f -name "pm2-*.config*"` sur hôte cible.
- Déploiement alternatif : `ps aux | grep quiz/web/server/server.js` ou inspection CI/CD.
- Tests : `cd ../quiz/ws && npm test` pour constater l’état des suites.

## Doc debt
- Package `ws/package.json` porte encore le nom `bingo_ws_server` (héritage) → décider si renommage/alignement nécessaire.
- README runtime du repo applicatif est un stub ; cette doc canon devient la source ; prévoir de pointer les contributeurs vers ce fichier.
