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
- Loadtest bots : `ws/bingo_loadtest.js` génère un `player_id` canon déterministe par bot/session (`p:uuidv5-ish("cotton-bot-player-id-v1|bingo|<sid>|<botId>")`), l’envoie dès `player_register` + `auth_player`, et propage `player_id` sur writes gameplay (`grid_cells_sync`, `deactivate_player`); `playerId` numérique reste optionnel et uniquement s’il est connu.
- Docker/compose : non présent dans le repo (voir UNVERIFIED si infra externe).

## Runtime surfaces
- WebSocket : `ws/websocket_server.js` gère connexions/heartbeat; instancié avec `heartbeatInterval: 15000` ms depuis `server.js`. Métadonnées connexions (origin, role, sid) exposées via `getMetadata`. Les logs WS passent par `logV1` (wrapper `ws/logger.js`) qui enrichit systématiquement `role` (fallback `server`) + `sid/game/src/v/ts`.
- Auth player bingo: `player_id` canon (`p:<uuid>`) est obligatoire sur `auth_player` et `auth_player_paper`; si absent/invalide, rejet `PLAYER_ID_MISSING_OR_INVALID`. Politique `last connection wins` basée sur `(sid, player_id)`; l’ancienne socket reçoit `SESSION_REPLACED` puis fermeture `4005` (`player replaced`), avec cleanup dédié `player-replaced`.
- Identité joueur Bingo (canon): `player_id` string (`p:<uuid>`) est la clé primaire WS; `playerId` numérique devient secondaire `player_db_id` (compat/auth DB, logs séparés).
- Canvas bridge : `ws/envUtils.js` choisit l’endpoint (override `CANVAS_API_URL` sinon fallback `https://games.{dev|prod}.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas` selon `WS_SERVER_URL`/origin). Écritures autorisées pour `bingo:reset|session_update|bingo:end_game|phase_winner|deactivate_player`; ajoute `event_id` UUID; header `X-Service-Token` pris de `CANVAS_SERVICE_TOKEN` ou alias `CANVAS_API_SERVICE_TOKEN`. Les writes player-scoped (`phase_winner`, `deactivate_player`) valident désormais côté WS un scope canon key-first (`player_id` obligatoire, `playerId` numeric-only) avec log `WS_API_PAYLOAD_VALIDATED`.
  **TODO migration** : si la cible produit est `global_ajax.php`, planifier un switch + tests CORS/auth (doc transverse en décalage).
- Hydratation players WS bingo : à la connexion organizer (boot/reprise), le serveur appelle `bingo:players_get` puis reconstruit `paperPlayersByGame` avec dédup déterministe (`updated_at DESC`, `id DESC`) et logs `PLAYERS_HYDRATE_START/ROW_SKIPPED/DEDUPED/DONE`.
- Bridge Bingo (`games`): `player_register` en UPSERT sur `(session_id, player_id)`; `grid_assign/grid_hydrate/grid_cells_sync` résolvent d’abord `player_id` canonique, puis fallback legacy via `playerId` numérique avec log `LEGACY_API_NOTE`.
- Remote admin register (`admin_player_register`) : le WS accepte désormais soit `player_id` canonique soit `playerId` numérique (compat), puis rediffuse `num_connected_players.players[]` avec `player_id` (si présent en DB) + `playerId` (legacy). Compat pré-migration conservée si colonne DB `player_id` absente.
- `update_session_infos` durci (2026-02-12): si aucune info lots n’est fournie, le WS n’émet plus de `prizes` vides implicites (`first/second/third`), ce qui évite l’effacement accidentel des lots côté UI player/remote.
- Admin phase winner (papier manuel, sans joueur) : `advancePhaseWithoutWinner` calcule `next_phase` depuis la phase explicitement demandée (`requestedPhase`) quand elle existe dans `phases_liste`; fallback conservé sur la phase DB courante sinon.
- Notifs victoire admin manuel : retour au format historique `PlayerWin` (`log_type=3`, message `"<PHASE> gagnée : Bravo ..."`), pour conserver l’affichage `bingo-notif-list` et la logique médailles/podium.
- End-game payload Bingo WS : `endGame` transporte désormais `players[]` + `totalPlayers` (snapshot final), afin de stabiliser l’hydratation UI de fin côté organizer/remote.
- Snapshot players Bingo : `getPlayersSnapshot` accepte un fallback de clé (canon `player_id` -> `player_db_id` -> `playerName`) pour conserver les joueurs papier même si l’identité canonique est absente/incomplète sur des données legacy.
- Logging : `ws/logger.js` écrit des JSON lignes (`v=1`, `ts`, `lvl`, `src=BINGO_WS`, `evt`, `sid/eid/meta…`) vers `ws/server-logs.log`, rotation 10 Mo / 5 backups, purge >15j. `LOG_DEBUG` explicite est prioritaire (`1`=on, `0`=off), sinon fallback sur `NODE_ENV/APP_ENV`.

## Variables d’environnement lues (via code)
- `WS_PORT` (défaut 3030) — `ws/server.js`.
- `CANVAS_SERVICE_TOKEN` (service token) / `CANVAS_API_SERVICE_TOKEN` (alias accepté).
- `CANVAS_API_URL` (override endpoint), `WS_SERVER_URL` | `CANVAS_ORIGIN` | `ORIGIN` (hint dev/prod), `APP_ENV`, `NODE_ENV` — `ws/bingo_server.js`, `ws/envUtils.js`.
- `LOG_DEBUG` pris en compte par `logger.js` (`1` force debug, `0` force no-debug).
- `.env` loader : `ws/localEnvLoader.js` charge une seule fois les clés whitelisted avec `preferLocal: true` (source de vérité locale). Si une clé whitelistée est présente dans `ws/.env` (ou `cwd/.env`), elle écrase `process.env` ; si absente, fallback process (ex: PM2).
- Correctif ordre d’initialisation (2026-02-10) : `ws/bingo_server.js` charge `.env` avant l’initialisation effective du logger, pour fiabiliser la lecture de `LOG_DEBUG`.

## Interactions (résumé)
- Clients WebSocket se connectent à `ws/server.js` ; messages routés par `BingoServer` → `websocket_server.js` → handlers métier.
- Bridge HTTP `/logs` sert uniquement à la lecture des logs JSONL générés par `logger.js`.
- Écritures Canvas déclenchées depuis le WS via `envUtils.canvasWrite` (actions limitées) vers `games_ajax.php`.
- `phase_winner` envoie `player_id` canon en priorité; `playerId` numérique reste secondaire (lookup local compat si payload organizer legacy).
- Audit writes WS Bingo: toutes les écritures Canvas WS passent par `canvasWrite` (avec `event_id` injecté + token service), et loggent `CANVAS_WRITE_OK` / `CANVAS_WRITE_ERR`.
- Quit volontaire joueur bingo : `player_quit` -> `handleDisconnection` -> `canvasWrite('deactivate_player', { sessionId, player_id, playerId?, event_id })`.
- Observabilité du quit bingo : `PLAYER_DEACTIVATED` (info), `PLAYER_DEACTIVATE_FAILED` (warn), `PLAYER_DEACTIVATE_SKIP` (warn).
- Replacement observability : `PLAYER_REPLACEMENT` (info), `PLAYER_SOCKET_REPLACED_CLEANUP` (info), close `4005` mappé en intent `player-replaced`.
- Disconnect observability (2026-02-13) : `WS_CLIENT_DISCONNECTED` est maintenant loggé avec `sid/role` + `meta.ws_client_id`, `meta.ws_role`, `closeCode`, `closeReason`, `intent`, `involuntary`.

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
| `LOG_DEBUG` | Optionnel | `ws/logger.js` | Override explicite debug (`1`=on, `0`=off) |

### Priorité de configuration (`.env` vs PM2)
- Mode en place : `.env` local prioritaire pour les clés whitelistées.
- Clés whitelistées côté bootstrap WS (`ws/bingo_server.js`) : `CANVAS_SERVICE_TOKEN`, `CANVAS_API_SERVICE_TOKEN`, `CANVAS_API_URL`, `CANVAS_ORIGIN`, `ORIGIN`, `WS_SERVER_URL`, `WS_PORT`, `ROLE_AUDIT_TICK_MS`, `LOG_ROLE_AUDIT`, `LOG_DEBUG`, `APP_ENV`, `NODE_ENV`.
- Conséquence: tu peux omettre des clés dans `.env` pour conserver les defaults PM2/process ; seules les clés présentes dans `.env` sont forcées.

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
- Symptôme : Trop de debug en prod — Cause : `LOG_DEBUG` ou env de démarrage incohérents — Fix : définir `LOG_DEBUG=0` + redémarrer PM2 avec `--update-env`.

## Observability (viewer-first)
- Source unique : fichiers `ws/server-logs.log` (+ rotations) produits par `ws/logger.js` (`logV1` injecte `role` pour tous les niveaux info|warn|error).
- Accès HTTP : `GET /logs?sid=<sid>[&limit=&page=]` depuis `ws/server.js` (CORS `*`, GET/OPTIONS).
- Entrées JSONL `v=1` avec `ts,lvl,src=BINGO_WS,evt,role,sid,eid,meta…` ; debug piloté par `LOG_DEBUG` ; compteur DEBUG `ROLE_AUDIT` (env `ROLE_AUDIT_TICK_MS` optionnel) surveille les entrées reçues sans role avant enrichissement (fallback `server`).
- Pour config runtime, chercher `evt:"CONFIG"` au démarrage (endpoint Canvas, tokenPresent, envPathUsed).

## Forcer flush (Bingo)
- Trigger viewer : `games/web/logs_session.html` bouton "Forcer flush" -> `localStorage.setItem('LOG_FLUSH_REQUEST', Date.now())`.
- Réaction front (organizer/player) : `games/web/includes/canvas/core/logger.global.js` écoute `window.storage` sur la clé `LOG_FLUSH_REQUEST` puis appelle `flushBufferToWS()`.
- Flush automatique fin de session : `logger.global.js` appelle aussi `flushBufferToWS()` quand le statut devient exactement `Partie terminée` (`maybeFlushFromStatus`).
- Transport WS front -> Bingo WS : message `{ type: "log_batch", payload: { entries: [...] } }` (ou `log_event` unitaire) sur la socket de session déjà ouverte.
- Ingestion WS Bingo : `ws/bingo_server.js` traite `log_batch|log_event`, valide chaque entrée, enrichit `meta.ingested_by = "BINGO_WS"` (+ `ws_role`, `ws_client_id` si dispo), puis réécrit en JSONL via `logV1`.
- Critère de validation : `GET /logs?sid=<sid>` renvoie des entrées `src:"GAMES"` (avec `meta.ingested_by:"BINGO_WS"` attendu sur les logs ingérés front).

## UNVERIFIED (à vérifier avant usage)
- Déploiement Docker/compose : absent du repo ; vérifier s’il existe dans une infra externe (`ls ../bingo.game/docker*` ou repo d’infra).
- Prod ecosystem PM2 : seul fichier `ws/pm2-ws.ecosystem.config.cjs` pointe vers `/var/www/bingo.game.dev.cotton-quiz.com`; vérifier s’il existe un config prod distinct ou un path prod (`find /var/www/bingo.game* -name "pm2-*.config*"`).
- Endpoint Canvas : code fallback `games_ajax.php`, doc transverse mentionne `global_ajax.php` → confirmer la cible côté PHP/routeur et planifier migration si besoin.
