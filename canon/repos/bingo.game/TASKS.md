# Repo `bingo.game` — Tasks

## Facts confirmed
- Entrypoint `ws/server.js` : HTTP `GET /logs` + WebSocket via `BingoServer` ; port `WS_PORT` (def 3030) ; heartbeat 15s ; logs paginées depuis `ws/server-logs*.log`.
- PM2 runtime `ws/pm2-ws.ecosystem.config.cjs` : app `bingo-ws`, cwd=`ws`, commande `bash -lc '... node .../ws/server.js'`, env `{NODE_ENV, WS_PORT=3030, LOG_DEBUG=0}`.
- Logging pipeline `ws/logger.js` : JSONL `v=1` → `ws/server-logs.log`, rotation 10 Mo / 5 backups / purge 15j, `debug` toujours actif (ignore `LOG_DEBUG`).
- Logging WS enrichi (06 fév 2026) : wrapper `logV1` centralise l’injection `v/ts/src=BINGO_WS/game=bingo/role/sid`, helper `deriveRole` (priorité ctx.role > client.wsRole > ws.wsRole > endpoint hint > `server`), audit compteur `missingBeforeEnrich` émis en DEBUG (`ROLE_AUDIT`). `websocket_server.js` et logs WS utilisent désormais `logV1` ; tous les logs info|warn|error portent `role` (fallback `server`).
- Canvas bridge `ws/envUtils.js` : endpoint override `CANVAS_API_URL` sinon fallback `https://games.{dev|prod}.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas`; actions write limitées (`bingo:reset`, `session_update`, `bingo:end_game`, `phase_winner`), header `X-Service-Token` via `CANVAS_SERVICE_TOKEN` ou `CANVAS_API_SERVICE_TOKEN` alias ; `event_id` auto.
- Env loader `ws/localEnvLoader.js` : charge une fois les clés whitelisted (CANVAS_* , WS_SERVER_URL, ORIGIN, APP_ENV, NODE_ENV) depuis `ws/.env`/`cwd/.env` si absentes du process.
- DB client `ws/knexfile.js` : configuration MySQL `knexConfig.development` utilisée par `ws/bingo_server.js` (connexion hardcodée en repo).
- NPM scripts `ws/package.json` : `npm test`, `npm run test:coverage` (jest). Pas de script start ; runtime via PM2/`node ws/server.js`.

## UNVERIFIED / TODO verify
- Déploiement Docker/compose annoncé dans `../bingo.game/README.md` sans fichier compose présent → confirmer infra (ex: `ls ../bingo.game/docker*` ou vérifier repo déploiement).
- Config PM2 production : seul config pointant vers `/var/www/bingo.game.dev.cotton-quiz.com`; vérifier éventuel config prod (`find /var/www/bingo.game* -name "pm2-*.config*"`).
- Route PHP effective : doc README mentionne `global_ajax.php` mais code cible `games_ajax.php`; vérifier routage côté PHP/Apache (ouvrir `web/games_ajax.php` dans repo front `games` ou prod host).

## How to verify
- Docker/compose : `ls ../bingo.game/docker* ../bingo.game/compose* 2>/dev/null` (ou consulter repo infra si séparé).
- PM2 prod : `find /var/www/bingo.game* -maxdepth 3 -type f -name \"pm2-*.config*\"` (sur cible) ; vérifier si un chemin prod existe.
- Endpoint PHP : ouvrir `games/web/games_ajax.php` dans repo `games` (ou prod host) et confirmer la route utilisée (`games_ajax.php` vs `global_ajax.php`).

## Doc debt (repo != docs transverses)
- `../bingo.game/README.md` affirme suppression de `CANVAS_API_SERVICE_TOKEN` mais le code accepte encore l’alias (envUtils.js). Décision : code = source ; doc à corriger.
- README annonce fallback Canvas `global_ajax.php` et mention docker compose ; code utilise `games_ajax.php` et aucun compose présent. Marquer ces écarts dans README cross-repo.
- Doc transverse (pm2-ws / entrypoints) mentionne `global_ajax.php` alors que le code fallback `games_ajax.php` (tenir à jour si migration décidée).
- TODO vérif : capturer une session WS en dev et vérifier via viewer/export JSONL que 0 log info|warn|error sort sans `role` (compteur DEBUG `ROLE_AUDIT` doit rester à 0 après enrichissement).
- Docs navigation : entrypoint public unique `START.md` → `SITEMAP.md` (raw complet) → carte repo (raw) → manifest/doc ciblée ; générateur/CI bloquent toute URL contenant `...` dans SITEMAP/INDEX.
