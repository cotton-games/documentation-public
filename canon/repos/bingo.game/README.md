# Repo `bingo.game` — Carte IA d’intervention (canon)

## Doc discipline
- `canon/repos/bingo.game/TASKS.md` à mettre à jour à chaque action significative (update-not-append si une tâche existe déjà).
- `canon/repos/bingo.game/README.md` à mettre à jour dès qu’un changement impacte le fonctionnel (flux/actions inter-repos, endpoints, env vars, idempotence/event_id, jalons logs, writes DB, etc.).
- En cas de divergence, le code fait foi ; corriger la doc immédiatement.

## Scope & entrypoints (confirmés)
- WS + HTTP unique : `ws/server.js` démarre un serveur HTTP (port `WS_PORT`, défaut 3030) avec endpoint `GET /logs` et attache `WebSocketServer` via `BingoServer` (`ws/bingo_server.js`).
- Logs HTTP : `GET /logs?sid=<sid>[&limit=&page=]` lit `ws/server-logs.log` + backups (`server-logs.N.log`), limite max 5000, 404 si aucun fichier, 405 hors GET/OPTIONS.
- PM2 (DEV confirmé) : `ws/pm2-ws.ecosystem.config.cjs` déclare l’app `bingo-ws` (cwd=`ws`), commande `node server.js` via `bash -lc` en important `/var/www/bingo.game.dev.cotton-quiz.com/ws/.env`, `WS_PORT=3030`, `NODE_ENV` {development|production}. Config PROD non trouvée (voir UNVERIFIED).
- DB : `ws/knexfile.js` configure MySQL (client `mysql`, connexion hardcodée en dev). `bingo_server.js` instancie `knex(knexConfig.development)`.
- Tests/scripts : `ws/package.json` → `npm test` (jest), `npm run test:coverage`; pas de script start, l’exécution runtime passe par PM2/`node ws/server.js`.
- Docker/compose : non présent dans le repo (voir UNVERIFIED si infra externe).

## Runtime surfaces
- WebSocket : `ws/websocket_server.js` gère connexions/heartbeat; instancié avec `heartbeatInterval: 15000` ms depuis `server.js`. Métadonnées connexions (origin, role, sid) exposées via `getMetadata`. Les logs WS passent par `logV1` (wrapper `ws/logger.js`) qui enrichit systématiquement `role` (fallback `server`) + `sid/game/src/v/ts`.
- Canvas bridge : `ws/envUtils.js` choisit l’endpoint (override `CANVAS_API_URL` sinon fallback `https://games.{dev|prod}.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas` selon `WS_SERVER_URL`/origin). Écritures autorisées uniquement pour `bingo:reset|session_update|bingo:end_game|phase_winner`; ajoute `event_id` UUID; header `X-Service-Token` pris de `CANVAS_SERVICE_TOKEN` ou alias `CANVAS_API_SERVICE_TOKEN`.  
  **TODO migration** : si la cible produit est `global_ajax.php`, planifier un switch + tests CORS/auth (doc transverse en décalage).
- Logging : `ws/logger.js` écrit des JSON lignes (`v=1`, `ts`, `lvl`, `src=BINGO_WS`, `evt`, `sid/eid/meta…`) vers `ws/server-logs.log`, rotation 10 Mo / 5 backups, purge >15j. `logger.debug` toujours actif (`DEBUG_ON='1'`, indifférent à `LOG_DEBUG`).

## Variables d’environnement lues (via code)
- `WS_PORT` (défaut 3030) — `ws/server.js`.
- `CANVAS_SERVICE_TOKEN` (service token) / `CANVAS_API_SERVICE_TOKEN` (alias accepté).
- `CANVAS_API_URL` (override endpoint), `WS_SERVER_URL` | `CANVAS_ORIGIN` | `ORIGIN` (hint dev/prod), `APP_ENV`, `NODE_ENV` — `ws/bingo_server.js`, `ws/envUtils.js`.
- `LOG_DEBUG` présent dans PM2 mais non pris en compte par `logger.js` (debug forcé).
- `.env` loader : `ws/localEnvLoader.js` charge une seule fois les clés whitelisted ci-dessus depuis `ws/.env` ou `cwd/.env` si variables absentes du process.

## Interactions (résumé)
- Clients WebSocket se connectent à `ws/server.js` ; messages routés par `BingoServer` → `websocket_server.js` → handlers métier.
- Bridge HTTP `/logs` sert uniquement à la lecture des logs JSONL générés par `logger.js`.
- Écritures Canvas déclenchées depuis le WS via `envUtils.canvasWrite` (actions limitées) vers `games_ajax.php`.

## Actions clés (runbook court)
- Lancer WS (dev/pm2) : `pm2 startOrReload ws/pm2-ws.ecosystem.config.cjs --update-env` (cwd `ws/`).
- Tests unitaires : `cd ws && npm test`.
- Vérifier logs pour une session : `curl "http://<host>:WS_PORT/logs?sid=<sid>&limit=200"`.
- Forcer bump déploiement (si watcher) : éditer `../bingo.game/version.txt` (pattern `restart DD-MM-YYYY/NN`).

## Variables d’environnement (synthèse)
| Key | Required | Used in | Note |
| --- | --- | --- | --- |
| `WS_PORT` | Optionnel (def 3030) | `ws/server.js` | Port HTTP/WS |
| `CANVAS_SERVICE_TOKEN` | Recommandé (writes) | `ws/envUtils.js` | Header `X-Service-Token` |
| `CANVAS_API_SERVICE_TOKEN` | Optionnel (alias) | `ws/envUtils.js` | Compat, même usage |
| `CANVAS_API_URL` | Optionnel | `ws/envUtils.js` | Override endpoint |
| `WS_SERVER_URL` / `CANVAS_ORIGIN` / `ORIGIN` | Optionnel | `ws/bingo_server.js`, `ws/envUtils.js` | Hint dev/prod pour fallback URL |
| `APP_ENV` / `NODE_ENV` | Optionnel | `ws/envUtils.js` | Hint dev/prod si aucun host |
| `LOG_DEBUG` | Ignoré | `ws/logger.js` | Debug forcé `DEBUG_ON='1'` |

## Happy path (diag rapide)
1) Installer deps WS si besoin : `cd ws && npm install` (si node_modules manquant).
2) Copier variables locales : `cp ws/.env.template ws/.env` puis renseigner token si usage Canvas write.
3) Démarrer via PM2 dev : `pm2 startOrReload ws/pm2-ws.ecosystem.config.cjs --update-env`.
4) Vérifier log de démarrage dans `ws/server-logs.log` (evt `CONFIG` affiche endpoint/tokenPresent).
5) Ouvrir un client (organizer/player) et établir la connexion WS.
6) Observer traffic : messages `state` / `remote_action` transitent ; aucun 4xx sur Canvas writes.
7) Consulter `/logs?sid=<sid>` pour confirmer traces par session.
8) Arrêt : `pm2 stop bingo-ws` ou `pm2 delete bingo-ws`.

## Scénarios d’échec fréquents
- Symptôme : `/logs` retourne 404 — Cause probable : aucun fichier `server-logs*.log` encore créé — Fix : générer trafic WS pour créer le log puis relire.
- Symptôme : Writes Canvas échouent 403 — Cause : token manquant (log `CONFIG_MISSING_TOKEN`) — Fix : définir `CANVAS_SERVICE_TOKEN` (ou alias) et relancer PM2 avec `--update-env`.
- Symptôme : Debug silencieux — Cause : lecture de `LOG_DEBUG` supposée mais ignorée — Fix : se baser sur `logger.debug` toujours actif ; filtrer côté viewer si besoin.

## Observability (viewer-first)
- Source unique : fichiers `ws/server-logs.log` (+ rotations) produits par `ws/logger.js` (`logV1` injecte `role` pour tous les niveaux info|warn|error).
- Accès HTTP : `GET /logs?sid=<sid>[&limit=&page=]` depuis `ws/server.js` (CORS `*`, GET/OPTIONS).
- Entrées JSONL `v=1` avec `ts,lvl,src=BINGO_WS,evt,role,sid,eid,meta…` ; debug toujours présent ; compteur DEBUG `ROLE_AUDIT` (env `ROLE_AUDIT_TICK_MS` optionnel) surveille les entrées reçues sans role avant enrichissement (fallback `server`).
- Pour config runtime, chercher `evt:"CONFIG"` au démarrage (endpoint Canvas, tokenPresent, envPathUsed).

## UNVERIFIED (à vérifier avant usage)
- Déploiement Docker/compose : absent du repo ; vérifier s’il existe dans une infra externe (`ls ../bingo.game/docker*` ou repo d’infra).
- Prod ecosystem PM2 : seul fichier `ws/pm2-ws.ecosystem.config.cjs` pointe vers `/var/www/bingo.game.dev.cotton-quiz.com`; vérifier s’il existe un config prod distinct ou un path prod (`find /var/www/bingo.game* -name "pm2-*.config*"`).
- Endpoint Canvas : code fallback `games_ajax.php`, doc transverse mentionne `global_ajax.php` → confirmer la cible côté PHP/routeur et planifier migration si besoin.
