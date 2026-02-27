# PM2 (WS Bingo / BT / Quiz)

## Constat
Les WS ne chargent pas automatiquement de fichier `.env` (pas de `dotenv`). Les variables sont lues via `process.env.*`.

## Chargement local `.env` (boot-only, whitelist)
Pour éviter les 403 “token missing” (PM2/cwd/symlink + `.env` server-only/gitignored), les WS chargent localement un `.env` **au boot** :
- **Priorité PM2** : si `process.env.KEY` existe déjà, il n’est jamais écrasé.
- Sinon, le WS lit un fichier `.env` (1 seule fois) et ne copie que des clés autorisées dans `process.env`.

Ordre de recherche:
1) `path.join(__dirname, '.env')`
2) `path.join(process.cwd(), '.env')`

Whitelist (minimum):
- `CANVAS_SERVICE_TOKEN` (canon) / `CANVAS_API_SERVICE_TOKEN` (compat)
- `CANVAS_API_URL`
- `WS_SERVER_URL`, `CANVAS_ORIGIN`, `ORIGIN`
- `APP_ENV`, `NODE_ENV`

## Variables attendues (convention)
- `WS_PORT` (number): port d’écoute du WS.
- `WS_SERVER_URL` (string): hint dev/prod (utilisé par le logger + fallback Canvas via présence de `.dev.`).
- `CANVAS_API_URL` (string, optionnel): override de l’endpoint Canvas.
- `CANVAS_SERVICE_TOKEN` (string, requis pour les “writes” Canvas): envoyé en header `X-Service-Token` (ne jamais logger).
  - Compat: `CANVAS_API_SERVICE_TOKEN` est accepté côté WS, mais `CANVAS_SERVICE_TOKEN` reste le nom canon.
- `LOG_DEBUG` (string `"1"`/`"0"`, optionnel): debug serveur (si implémenté côté logger). **Bingo WS : ignoré** car `logger.js` force `DEBUG_ON='1'` (debug toujours actif).
- `NODE_ENV` (string, optionnel): `production`/`development`.

## Sélection de l’endpoint Canvas (règles)
- Priorité: si `CANVAS_API_URL` est défini → il est utilisé tel quel (dev/prod explicit).
- Sinon: fallback sur le hint d’URL (`WS_SERVER_URL` / `CANVAS_ORIGIN` / `ORIGIN`) :
  - hint contient `.dev.` → `https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas`
  - sinon → `https://games.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas`
- Sans hint (vide): fallback “safe” basé sur l’environnement (`NODE_ENV`/`APP_ENV`) :
  - env non-prod → host `.dev.`
  - env prod → host prod
- Alias `global_ajax.php` : c’est un shim côté PHP (`games/web/global_ajax.php` redirige vers `games_ajax.php`), mais le fallback WS confirmé (ex bingo.game) reste `games_ajax.php` tant que `CANVAS_API_URL` n’override pas. **Migration éventuelle** vers `global_ajax.php` à planifier/tester si décidé côté prod.

Important: un token DEV ne fonctionnera pas contre un host PROD (et inversement) → en cas de 403, vérifier **host + présence token** (sans jamais logger la valeur).

## Logs safe (diagnostic WS)
Pour diagnostiquer sans SSH “où on tape” et si le token est chargé:
- Au démarrage, chercher `tags:["config"]` → `canvasEndpointResolved`, `canvasHost`, `tokenPresent`, `tokenSource`.
- Le log boot inclut aussi `envFileLoaded`, `envFilePathUsed`, `envKeysLoaded` (liste des clés chargées, sans valeurs).
- En cas d’échec write, chercher `tags:["api_write_failed"]` (au moins Blindtest) → `action`, `statusCode`, `canvasHost`, `event_id`, `latencyMs`.

## Exemple PM2 (3 process)
- Fichier: `pm2-ws.ecosystem.config.cjs`
- Lancement depuis la racine: `pm2 start pm2-ws.ecosystem.config.cjs`
- Appliquer un profil: `pm2 start pm2-ws.ecosystem.config.cjs --env production`
- Prendre en compte une modif `.env` (recommandé): `pm2 startOrReload <path>/pm2-ws.ecosystem.config.cjs --update-env`
  - Pourquoi: `startOrReload` met à jour le process existant **si** `apps[].name` match exactement le nom du process PM2 déjà en place.

## Charger les secrets via `.env` (sans `dotenv`)
Le fichier PM2 source automatiquement `./.env` (si présent) dans chaque `cwd` avant `node`.

À faire 1 seule fois par repo (copier le template → `.env`) :
- Bingo WS: `cp bingo.game/ws/.env.template bingo.game/ws/.env`
- BT WS: `cp blindtest/web/server/.env.template blindtest/web/server/.env`
- Quiz WS: `cp quiz/web/server/.env.template quiz/web/server/.env`

Format requis (compatible `bash source`) : `KEY=value` (pas d’espaces).

## Preuves runtime PM2 (DEV, evidence-based — PROD might differ) (à consigner)
Ces valeurs doivent être utilisées comme référence pour aligner `apps[].name` et `apps[].cwd` afin que `pm2 startOrReload ... --update-env` mette bien à jour l’existant.

- Bingo
  - PM2 name: `bingo-ws` (id `1`)
  - Exec cwd: `/home/bingo_game`
  - Script path: `/home/bingo_game/bingo-ws` (symlink → `/var/www/bingo.game.dev.cotton-quiz.com/ws/server.js`)
  - Code réel: `/var/www/bingo.game.dev.cotton-quiz.com/ws/`
- Blindtest
  - PM2 name: `server` (id `39`)
  - Exec cwd: `/var/www/blindtest.dev.cotton-quiz.com/web/server`
  - Script: `server.js`
- Quiz
  - PM2 name: `server` (id `0`)
  - Exec cwd: `/var/www/quiz.dev.cotton-quiz.com/web/server`
  - Script: `server.js`

## Commandes admin (DEV)
```bash
pm2 startOrReload /var/www/blindtest.dev.cotton-quiz.com/web/server/pm2-ws.ecosystem.config.cjs --update-env
pm2 startOrReload /var/www/quiz.dev.cotton-quiz.com/web/server/pm2-ws.ecosystem.config.cjs --update-env
pm2 startOrReload /var/www/bingo.game.dev.cotton-quiz.com/ws/pm2-ws.ecosystem.config.cjs --update-env
```

## PHP Canvas (token serveur)
Le token est lu côté Canvas via `getenv('CANVAS_SERVICE_TOKEN')` (ex: `games/web/games_ajax.php`, alias `games/web/global_ajax.php`), donc il doit être présent dans l’environnement du runtime PHP (apache/php-fpm).

Template:
- `cp games/web/secrets.env.template games/web/secrets.env`

Exemples d’injection (à adapter à votre infra):
- systemd (php-fpm): `EnvironmentFile=/path/to/games/secrets.env`
- wrapper de déploiement: `set -a; source /path/to/games/secrets.env; set +a; ...`
