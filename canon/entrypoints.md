> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Entrypoints

> Ports, servers, and key web entrypoints.

<!-- AUTO-UPDATE:BEGIN id="entrypoints-table" owner="codex" -->
# Points d’entrée (par sous-projet)

## `bingo.game/`
- Serveur WS + HTTP: `bingo.game/ws/server.js` (WS + endpoint HTTP `/logs`).
- Serveur “métier” Bingo: `bingo.game/ws/bingo_server.js` (routeur des messages WS par `type`).
- Scripts Node: `bingo.game/ws/package.json` (`test`, `test:coverage`).
- Docker: `bingo.game/ws/ws.Dockerfile`, `bingo.game/ws/test.Dockerfile`.
- Détails WS/Canvas/PM2 : voir `canon/repos/bingo.game/README.md` (facts confirmés repo-first).

## `blindtest/` (Blind Test)
- Serveur WS + HTTP: `blindtest/web/server/server.js` (WS + endpoint HTTP `/logs`).
- Routage messages WS: `blindtest/web/server/actions/wsHandler.js`.

## `quiz/` (Cotton Quiz)
- Serveur WS + HTTP: `quiz/web/server/server.js` (WS + endpoint HTTP `/logs`).
- Routage messages WS: `quiz/web/server/actions/wsHandler.js`.

## `games/` (fronts “canvas” jeux)
- Pages principales: `games/web/organizer_canvas.php`, `games/web/player_canvas.php`, `games/web/remote_canvas.php`.
- Audit structurel (UI organizer/remote, hooks DOM, `id_client`): `notes/canvas-organizer-structure.md`.
- Viewer logs (par session): `games/web/logs_session.html` (UI) + `games/web/includes/canvas/php/logs_proxy.php` (backend JSON).
  - URL: `/logs_session.html?sessionId=SESSION_ID`
  - Query params (UI): `sessionId` (pré-remplit et déclenche le chargement)
  - Backend: `games/web/includes/canvas/php/logs_proxy.php?game=GAME&sessionId=SESSION_ID&limit=N&page=P`
    - Paramètres principaux supportés : `sessionId`, `game`, `limit`, `page`. Les options `show_debug`/`min_level` ne sont plus actives (rollback).
  - Résumé : affichage brut des logs retournés par le backend `/logs` (pas de compteur/agrégats côté UI).
  - Source = `server-logs.log via endpoint /logs des serveurs WS`
  - Schéma canon recommandé (JSONL): `canon/logging.md`
- Endpoint AJAX: `games/web/games_ajax.php` (dispatch via paramètres, ex. `t=...&m=...`).
  - Alias historique (compat): `games/web/global_ajax.php` (shim vers `games_ajax.php`).
  - WS (ex: bingo.game) : fallback par défaut sur `games_ajax.php` ; `global_ajax.php` reste un alias côté PHP, pas la cible principale WS.
  - Canvas bridge: `games/web/games_ajax.php?t=jeux&m=canvas` (alias: `games/web/global_ajax.php?t=jeux&m=canvas`; writes idempotents via `event_id`, auth inter-service via header `X-Service-Token`, bypass dev possible uniquement si `CANVAS_DEV_ALLOW_UNAUTH_WRITES=1` + env dev détecté).
- Config runtime: `games/web/config.php` + réécritures `games/web/.htaccess`.
- Endpoints AJAX dédiés: `games/web/modules/app_orga_ajax.php`, `games/web/modules/app_play_ajax.php`, `games/web/modules/app_remote_ajax.php`.

## `global/` (bibliothèque / backoffice “global”)
- Endpoint AJAX central: `global/web/global_ajax.php`.
- Config runtime: `global/web/global_config.php` + réécritures `global/web/.htaccess`.
- Modules fonctionnels: `global/web/app/modules/` (ex. jeux, ecommerce, entités, opérations).
- Note: legacy canvas UI sous `global/web/*/canvas/` supprimée (obsolète).

## `www/` (site www)
- Front office: `www/web/fo/fo.php` (+ `www/web/fo/fo_ajax.php`, `www/web/fo/do_script.php`).
- Back office: `www/web/bo/bo.php` (+ `www/web/bo/do_script.php`, crons `www/bo/cron_*.php`).
- API PHP: `www/web/api/*.php`.
- Config runtime: `www/web/config.php` + réécritures `www/web/.htaccess`.

## `pro/` (site pro)
- Espace “ec”: `pro/web/ec/ec.php` (+ `pro/web/ec/ec_ajax.php`, `pro/web/ec/do_script*.php`).
- Auth: `pro/web/ec/ec_signin.php`, `pro/web/ec/ec_signup.php`, `pro/web/ec/ec_sign.php`.
- Webhooks: `pro/web/ec/ec_webhook_stripe_handler.php`.
- Front office: `pro/web/fo/fo.php` (+ `pro/web/fo/do_script.php`).
- Config runtime: `pro/web/config.php` + réécritures `pro/web/.htaccess`.

## Deployment layout / paths (evidence-based)
- PHP vhosts use an explicit `/var/www/<vhost>/web/` convention in config (examples, not exhaustive):
  - `games/web/config.php` (`$conf['public']`): `/var/www/games.cotton-quiz.com/web/`, `/var/www/games.dev.cotton-quiz.com/web/`
  - `global/web/global_config.php` (`$conf['public']`): `/var/www/global.cotton-quiz.com/web/`, `/var/www/global.dev.cotton-quiz.com/web/`
  - `www/web/config.php` (`$conf['public']`): `/var/www/www.cotton-quiz.com/web/`, `/var/www/www.dev.cotton-quiz.com/web/`
  - `pro/web/config.php` (`$conf['public']`): `/var/www/pro.cotton-quiz.com/web/`, `/var/www/pro.dev.cotton-quiz.com/web/`
- Some vhosts also define a `private/` directory (evidence: `www/web/config.php` → `/var/www/www.<env>.cotton-quiz.com/private/`).
- Some local files are resolved relative to the deployed PHP file via `__DIR__` (evidence: `games/web/games_ajax.php` loads `games/web/secrets.env` from `__DIR__`; alias `games/web/global_ajax.php` shims to it).
<!-- AUTO-UPDATE:END id="entrypoints-table" -->
