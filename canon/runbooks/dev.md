> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Runbook – Dev

> How to run locally / in dev.

## Checklist “5 minutes” (humain)
1. **Identifier le jeu / périmètre** : Bingo (WS `bingo.game/ws/server.js`) ou BT/CQ.
2. **Vérifier l’endpoint Canvas** : `.../global_ajax.php?t=jeux&m=canvas` répond et `players_get` fonctionne.
3. **Vérifier l’auth inter-service** (writes): définir `CANVAS_SERVICE_TOKEN` côté serveur PHP (validation) **et** côté WS (header `X-Service-Token`), puis faire un smoke `session_update` avec `event_id`.
4. **Observer les logs WS** : endpoint HTTP `/logs` si activé, sinon stdout/pm2.
5. **En cas de 403** : voir `canon/runbooks/troubleshooting.md` (souvent `event_id` envoyé côté front ou token absent/incorrect côté WS).

## Noms de dossiers (mise à jour)
Les chemins ci-dessous supposent un workspace “apps” à la racine (ex: `/home/romain/Cotton/`) et ce dépôt documentation dans `documentation/`.

- Ancien nom → Nouveau nom:
  - `website/` → `www/`
  - `PRO/` → `pro/`
  - `Global/` → `global/`
  - `GAMES/` → `games/` (Canvas bridge: `games/web/global_ajax.php`)
  - `bingo-musical/` → `bingo.game/` (WS: `bingo.game/ws/server.js`)
  - `BT_Global/` → `blindtest/` (WS: `blindtest/web/server/server.js`)
  - `CQ_Global/` → `quiz/` (WS: `quiz/web/server/server.js`)

Note: le troubleshooting est maintenant dans ce repo documentation: `canon/runbooks/troubleshooting.md`.

<!-- AUTO-UPDATE:BEGIN id="dev-steps" owner="codex" -->
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
- `WS_SERVER_URL` (hint env “prod/dev” via présence de `.dev.`; evidence: code checks `process.env.WS_SERVER_URL?.includes('.dev.')` in WS servers)
- `LOG_DEBUG` (niveau de logs)
- `CANVAS_API_URL` (optionnel, endpoint Canvas `.../games_ajax.php?t=jeux&m=canvas` ; alias historique: `.../global_ajax.php?t=jeux&m=canvas`)
- `CANVAS_SERVICE_TOKEN` (requis pour les writes idempotents: envoyé en header `X-Service-Token` quand un `event_id` est présent)
- `CANVAS_DEV_ALLOW_UNAUTH_WRITES=1` (dev-only, **bypass temporaire** : autorise les writes Canvas sans `X-Service-Token` uniquement si env dev détecté via `APP_ENV=dev` ou host contenant `.dev.`)
- `CANVAS_ORIGIN`, `ORIGIN`, `BINGO_CANVAS_CONCURRENCY` (hints / load-test / intégration Canvas côté `bingo.game/ws/`)

## Priorité de config (WS)
- Les WS chargent `.env` local avec priorité (`preferLocal: true`) sur les clés whitelistées.
- Si une clé whitelistée est présente dans `.env`, elle écrase `process.env` (PM2).
- Si une clé whitelistée est absente de `.env`, fallback vers `process.env`/PM2.
- Règle pratique: mettre dans `.env` uniquement ce que tu veux forcer localement.
<!-- AUTO-UPDATE:END id="dev-steps" -->

<!-- AUTO-UPDATE:BEGIN id="dev-env" owner="codex" -->
## Env vars (auto)
- `WS_PORT`
- `WS_SERVER_URL`
- `LOG_DEBUG`
- `CANVAS_API_URL`
- `CANVAS_SERVICE_TOKEN`
- `CANVAS_DEV_ALLOW_UNAUTH_WRITES`
- `CANVAS_ORIGIN`, `ORIGIN`, `BINGO_CANVAS_CONCURRENCY`
- `CANVAS_HTTP_TIMEOUT_MS`
- `CANVAS_UPDATE_SCORE_CONCURRENCY` (quiz/blindtest)
- `ROLE_AUDIT_TICK_MS`, `LOG_ROLE_AUDIT` (bingo)
<!-- AUTO-UPDATE:END id="dev-env" -->
