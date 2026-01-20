> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Entrypoints

> Ports, servers, and key web entrypoints.

<!-- AUTO-UPDATE:BEGIN id="entrypoints-table" owner="codex" -->
# Points d’entrée (par sous-projet)

## `bingo-musical/`
- Serveur WS + HTTP: `bingo-musical/src/ws/server.js` (WS + endpoint HTTP `/logs`).
- Serveur “métier” Bingo: `bingo-musical/src/ws/bingo_server.js` (routeur des messages WS par `type`).
- Scripts Node: `bingo-musical/src/ws/package.json` (`test`, `test:coverage`).
- Docker: `bingo-musical/src/ws/ws.Dockerfile`, `bingo-musical/src/ws/test.Dockerfile`.

## `BT_Global/` (Blind Test)
- Serveur WS + HTTP: `BT_Global/web/server/server.js` (WS + endpoint HTTP `/logs`).
- Routage messages WS: `BT_Global/web/server/actions/wsHandler.js`.

## `CQ_Global/` (Cotton Quiz)
- Serveur WS + HTTP: `CQ_Global/web/server/server.js` (WS + endpoint HTTP `/logs`).
- Routage messages WS: `CQ_Global/web/server/actions/wsHandler.js`.

## `GAMES/` (fronts “canvas” jeux)
- Pages principales: `GAMES/organizer_canvas.php`, `GAMES/player_canvas.php`, `GAMES/remote_canvas.php`.
- Viewer logs (par session): `GAMES/logs_session.html` (UI) + `GAMES/includes/canvas/php/logs_proxy.php` (backend JSON).
  - URL: `GAMES/logs_session.html?sessionId=SESSION_ID`
  - Query params (UI): `sessionId` (pré-remplit et déclenche le chargement)
  - Backend: `GAMES/includes/canvas/php/logs_proxy.php?game=GAME&sessionId=SESSION_ID&limit=N&page=P`
  - Source = `server-logs.log via endpoint /logs des serveurs WS`
- Endpoint AJAX: `GAMES/global_ajax.php` (dispatch via paramètres, ex. `t=...&m=...`).
- Config runtime: `GAMES/config.php` + réécritures `GAMES/.htaccess`.
- Endpoints AJAX dédiés: `GAMES/modules/app_orga_ajax.php`, `GAMES/modules/app_play_ajax.php`, `GAMES/modules/app_remote_ajax.php`.

## `Global/` (bibliothèque / backoffice “global”)
- Endpoint AJAX central: `Global/global_ajax.php`.
- Config runtime: `Global/global_config.php` + réécritures `Global/.htaccess`.
- Modules fonctionnels: `Global/app/modules/` (ex. jeux, ecommerce, entités, opérations).

## `website/` (site www)
- Front office: `website/fo/fo.php` (+ `website/fo/fo_ajax.php`, `website/fo/do_script.php`).
- Back office: `website/bo/bo.php` (+ `website/bo/do_script.php`, crons `website/bo/cron_*.php`).
- API PHP: `website/api/*.php`.
- Config runtime: `website/config.php` + réécritures `website/.htaccess`.

## `PRO/` (site pro)
- Espace “ec”: `PRO/web/ec/ec.php` (+ `PRO/web/ec/ec_ajax.php`, `PRO/web/ec/do_script*.php`).
- Auth: `PRO/web/ec/ec_signin.php`, `PRO/web/ec/ec_signup.php`, `PRO/web/ec/ec_sign.php`.
- Webhooks: `PRO/web/ec/ec_webhook_stripe_handler.php`.
- Front office: `PRO/web/fo/fo.php` (+ `PRO/web/fo/do_script.php`).
- Config runtime: `PRO/web/config.php` + réécritures `PRO/web/.htaccess`.
<!-- AUTO-UPDATE:END id="entrypoints-table" -->
