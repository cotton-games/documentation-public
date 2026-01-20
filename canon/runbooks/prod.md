> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Runbook – Prod

> Deployment / reverse proxy / wss.

<!-- AUTO-UPDATE:BEGIN id="prod-steps" owner="codex" -->
# Contexte rapide du dépôt `Cotton/`

Ce répertoire regroupe plusieurs sous-projets (PHP + Node) utilisés pour le site Cotton (www/pro/global/games) et des serveurs WebSocket temps réel pour certains jeux.

## Lancer en dev (pistes “factuelles”)
- PHP (`website/`, `PRO/web/`, `Global/`, `GAMES/`): servir les dossiers web via Apache/Nginx/PHP-FPM, avec les réécritures `.htaccess` actives et un `SERVER_NAME` cohérent avec les configs (`*/config.php`, `Global/global_config.php`, `GAMES/config.php`).
- WebSocket Bingo: `bingo-musical/src/ws/server.js` (port via `WS_PORT`, défaut 3030) après installation des dépendances Node dans `bingo-musical/src/ws/`.
- WebSocket BT/CQ: `BT_Global/web/server/server.js` et `CQ_Global/web/server/server.js` (ports via `WS_PORT`, défaut 3031/3032) — ces serveurs référencent des `node_modules` via un chemin `../../ws/node_modules/...` (pré-requis côté environnement de déploiement).

## Lancer en prod (pistes “factuelles”)
- PHP: déploiement type “vhost” par sous-domaine (`www`, `pro`, `global`, `games`) + base MySQL configurée dans les fichiers `config.php`/`global_config.php`.
- WebSocket: exposer en `wss://` derrière un reverse proxy (ports `WS_PORT`), et autoriser l’accès au endpoint HTTP `/logs` si utilisé.

## Variables d’environnement repérées (Node)
- `WS_PORT` (ports WS/HTTP logs)
- `WS_SERVER_URL` (hint env “prod/dev” via présence de `.dev.`)
- `LOG_DEBUG` (niveau de logs)
- `CANVAS_API_URL` (optionnel, endpoint Canvas `.../global_ajax.php?t=jeux&m=canvas`)
- `CANVAS_SERVICE_TOKEN` (optionnel, header `X-Service-Token` vers Canvas)
- `CANVAS_ORIGIN`, `ORIGIN`, `BINGO_CANVAS_CONCURRENCY` (hints / load-test / intégration Canvas côté `bingo-musical/src/ws/`)
<!-- AUTO-UPDATE:END id="prod-steps" -->
