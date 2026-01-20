# PM2 (WS Bingo / BT / Quiz)

## Constat
Les WS ne chargent pas automatiquement de fichier `.env` (pas de `dotenv`). Les variables sont lues via `process.env.*`.

## Variables attendues (convention)
- `WS_PORT` (number): port d’écoute du WS.
- `WS_SERVER_URL` (string): hint dev/prod (utilisé par le logger + fallback Canvas via présence de `.dev.`).
- `CANVAS_API_URL` (string, optionnel): override de l’endpoint Canvas.
- `CANVAS_SERVICE_TOKEN` (string, requis pour les “writes” Canvas): envoyé en header `X-Service-Token` (ne jamais logger).
- `LOG_DEBUG` (string `"1"`/`"0"`, optionnel): debug serveur (si implémenté côté logger).
- `NODE_ENV` (string, optionnel): `production`/`development`.

## Exemple PM2 (3 process)
- Fichier: `docs/pm2-ws.ecosystem.config.cjs`
- Lancement depuis la racine: `pm2 start docs/pm2-ws.ecosystem.config.cjs`
- Appliquer un profil: `pm2 start docs/pm2-ws.ecosystem.config.cjs --env production`
- Prendre en compte une modif `.env`: `pm2 restart <app> --update-env`

## Charger les secrets via `.env` (sans `dotenv`)
Le fichier PM2 source automatiquement `./.env` (si présent) dans chaque `cwd` avant `node`.

À faire 1 seule fois par repo (copier le template → `.env`) :
- Bingo WS: `cp bingo-musical/src/ws/.env.template bingo-musical/src/ws/.env`
- BT WS: `cp BT_Global/web/server/.env.template BT_Global/web/server/.env`
- Quiz WS: `cp CQ_Global/web/server/.env.template CQ_Global/web/server/.env`

Format requis (compatible `bash source`) : `KEY=value` (pas d’espaces).

## PHP Canvas (token serveur)
Le token est lu côté Canvas via `getenv('CANVAS_SERVICE_TOKEN')` (ex: `GAMES/global_ajax.php`), donc il doit être présent dans l’environnement du runtime PHP (apache/php-fpm).

Template:
- `cp GAMES/secrets.env.template GAMES/secrets.env`

Exemples d’injection (à adapter à votre infra):
- systemd (php-fpm): `EnvironmentFile=/path/to/GAMES/secrets.env`
- wrapper de déploiement: `set -a; source /path/to/GAMES/secrets.env; set +a; ...`
