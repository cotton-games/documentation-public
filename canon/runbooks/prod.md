> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Runbook – Prod

> Deployment / reverse proxy / wss.

<!-- AUTO-UPDATE:BEGIN id="prod-steps" owner="codex" -->
# Contexte rapide (workspace apps + documentation)

Le workspace “apps” regroupe plusieurs sous-projets (PHP + Node) utilisés pour le site Cotton (`www/`, `pro/`, `global/`, `games/`) et des serveurs WebSocket temps réel pour certains jeux (`bingo.game/`, `blindtest/`, `quiz/`).

## Lancer en dev (pistes “factuelles”)
- PHP (`www/`, `pro/`, `global/`, `games/`): servir les dossiers web via Apache/Nginx/PHP-FPM, avec les réécritures `.htaccess` actives et un `SERVER_NAME` cohérent avec les configs (`*/web/config.php`, `global/web/global_config.php`, `games/web/config.php`).
- WebSocket Bingo: `bingo.game/ws/server.js` (port via `WS_PORT`, défaut 3030) après installation des dépendances Node dans `bingo.game/ws/`.
- WebSocket Blindtest/Quiz: `blindtest/web/server/server.js` et `quiz/web/server/server.js` (ports via `WS_PORT`, défaut 3031/3032) — ces serveurs référencent des `node_modules` via un chemin `../../ws/node_modules/...` (pré-requis côté environnement de déploiement).

## Lancer en prod (pistes “factuelles”)
- PHP: déploiement type “vhost” par sous-domaine (`www`, `pro`, `global`, `games`) + base MySQL configurée dans les fichiers `config.php`/`global_config.php`.
- WebSocket: exposer en `wss://` derrière un reverse proxy (ports `WS_PORT`), et autoriser l’accès au endpoint HTTP `/logs` si utilisé.

## Variables d’environnement repérées (Node)
- `WS_PORT` (ports WS/HTTP logs)
- `WS_SERVER_URL` (hint env “prod/dev” via présence de `.dev.`)
- `LOG_DEBUG` (niveau de logs)
- `CANVAS_API_URL` (optionnel, endpoint Canvas `.../games_ajax.php?t=jeux&m=canvas` ; alias historique: `.../global_ajax.php?t=jeux&m=canvas`)
- `CANVAS_SERVICE_TOKEN` (requis pour les writes idempotents: envoyé en header `X-Service-Token` quand un `event_id` est présent)
- `CANVAS_ORIGIN`, `ORIGIN`, `BINGO_CANVAS_CONCURRENCY` (hints / load-test / intégration Canvas côté `bingo.game/ws/`)
- `CANVAS_HTTP_TIMEOUT_MS`
- `CANVAS_UPDATE_SCORE_CONCURRENCY` (quiz/blindtest)
- `ROLE_AUDIT_TICK_MS`, `LOG_ROLE_AUDIT` (bingo)

## Priorité de config (WS)
- Les WS chargent `.env` local avec priorité (`preferLocal: true`) sur les clés whitelistées.
- Si une clé whitelistée est présente dans `.env`, elle écrase `process.env` (PM2).
- Si une clé whitelistée est absente de `.env`, fallback vers `process.env`/PM2.
- En prod, définir explicitement `LOG_DEBUG=0` dans `.env` pour couper les logs debug de manière déterministe.
<!-- AUTO-UPDATE:END id="prod-steps" -->
