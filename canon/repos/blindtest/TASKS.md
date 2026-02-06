# Repo `blindtest` — Tasks

## Facts confirmed
- Entrypoint `web/server/server.js` : HTTP `GET /logs?sessionId=` (limit def 500, max 5000, retourne `statusSeed`) + WebSocketServer attaché (port `WS_PORT` def 3031, ping/pong 30s, terminate si pas de pong) ; dépendances `ws`/`node-fetch` via `../ws/node_modules`.
- PM2 runtime `web/server/pm2-ws.ecosystem.config.cjs` : app `server`, cwd=`web/server`, commande `bash -lc 'set -a; [ -f ./.env ] && source ./.env; set +a; exec node ./server.js'`, env `{NODE_ENV, WS_PORT=3031, LOG_DEBUG=0}` pour dev/prod.
- Logging pipeline `web/server/logger_ws.js` : JSONL `ts, level, source=BT_WS, sessionId, msg, data...` → `web/server/server-logs.log`, rotation 10 Mo / 5 backups / purge 15j ; DEBUG_ON actif si `!WS_SERVER_URL.includes('.dev.')` est faux ou `LOG_DEBUG=1`.
- Canvas bridge `web/server/actions/envUtils.js` : endpoint fallback `https://games.{dev|prod}.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas` (override `CANVAS_API_URL`), actions write auditées `update_score|session_update|deactivate_player|player_register` avec `event_id` auto, header `X-Service-Token` via `CANVAS_SERVICE_TOKEN` ou alias `CANVAS_API_SERVICE_TOKEN`, timeout 3s (`CANVAS_HTTP_TIMEOUT_MS`).
- Env loader `web/server/localEnvLoader.js` : charge une fois les clés whitelisted (`CANVAS_*`, `WS_SERVER_URL`, `CANVAS_ORIGIN`, `ORIGIN`, `APP_ENV`, `NODE_ENV`) depuis `.env` si absentes du process ; métadonnées loggées via `envUtils`.
- WS logging in/out : `wsHandler` et `messaging` loggent `WS_IN/WS_OUT` sur un set de types whitelisted avec throttle ; `log_event`/`log_batch` injectent les logs front dans le même fichier.
- NPM scripts disponibles via `ws/package.json` (nommé `bingo_ws_server`) : `npm test` (jest) ; aucune commande start, runtime via PM2/`node web/server/server.js`.

## UNVERIFIED / TODO verify
- Config PM2 production dédiée (chemin ou host prod) non trouvée ; à vérifier côté serveur cible.
- Présence éventuelle d’un watcher/deploy externe (systemd, supervisor) pour le WS au-delà de PM2 (non vu dans repo).
- Couverture tests Jest : suites inexistantes dans repo ; confirmer si tests vivent ailleurs ou peuvent être ajoutés.

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
- PM2 prod : `find /var/www/blindtest* -maxdepth 3 -type f -name "pm2-*.config*"` sur hôte cible.
- Déploiement alternatif : `ps aux | grep server.js` ou inspection CI/CD ; rechercher service systemd `blindtest-ws`.
- Tests : `cd ../blindtest/ws && npm test` (vérifier présence de suites) ; si vide, ajouter tests ciblés.

## Doc debt
- Nom package `ws/package.json` resté `bingo_ws_server` (héritage) → décider si renommage requis et ajuster docs/PM2 si modifié.
- Aucun README runtime dans repo d’app (stub) : ce fichier canon devient source de vérité ; propager lien dans `../blindtest/README.md` si besoin.
