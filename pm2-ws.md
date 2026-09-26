<!-- AUTO-UPDATE:BEGIN id="hub-suspend-20260910-markers" owner="codex" -->

### Hotfix hub_soiree — 23/09, préparation locale

**NON DÉPLOYÉ ; aucun restart effectué.** Markers préparés : Bingo `restart 23-09-2026/011` (base `/010`), Quiz/BT `restart 23-09-2026/01`. Aucun nouvel endpoint/env/port/module WS. Games PHP doit connaître `stage=admit` avant activation des WS modifiés ; ne pas livrer les fichiers complets de `hub_session_readiness`. [Liste exhaustive, commandes de test, recette et rollback](notes/hub-soiree-hotfix-2026-09-23.md).


### 22/09/2026 — Patch auth Bingo numérique, local

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](canon/deployment-status.md).

Bingo `version.txt` : **`restart 22-09-2026/02`**. Livrer ensemble `ws/bingo_server.js`, `ws/bingo_reset.js`, `ws/repository/base/player_repository.js` et `ws/repository/db/db_player_repository.js`, sur la base du lot capacité précédent. Restart WS Bingo requis après livraison autorisée, aucun exécuté. Quiz/BT inchangés, markers22/09 /01. Aucun nouvel endpoint/env/SQL/reload PHP. [Rapport, tests et rollback](notes/bingo-digital-auth-performance-2026-09-22.md).


### 22/09/2026 — Capacité WS / publication BT (local)

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](canon/deployment-status.md).

Cohortes fermées avant fetch de `hub_capacity_get` : aucun cache de réponse réutilisé par une admission ultérieure, contrat API/stock/verrou Bingo inchangé. Modules `capacity_reads.js` à livrer avec `envUtils` et helpers capacité. BT indexe le lookup Player. Markers Quiz/BT/Bingo : `restart 22-09-2026/01` ; redémarrage des trois WS nécessaire après livraison future autorisée, aucun effectué. Pas de nouvel endpoint/env/SQL ni reload PHP. [Contrat, tests et limites](notes/hub-capacity-publication-patch-2026-09-22.md).


## 21/09/2026 — PATCH3 Bingo papier, local

Marker Bingo `version.txt` : `restart 21-09-2026/03`, association facultative K/D depuis le roster papier. Quiz/Blind Test conservent leurs markers PATCH2. Aucun PM2 ni restart exécuté. [Rapport](notes/bingo-paper-association-patch3-2026-09-21.md).


## 21/09/2026 — PATCH2 score papier, local

Markers Quiz et Blind Test : `restart 21-09-2026/04`. Bingo conserve `/02` du PATCH1. Aucun restart exécuté, aucune modification PM2. Livraison éventuelle coordonnée Games/Quiz/BT : ancien finalizer papier sans snapshot refusé. [Rapport](notes/paper-score-patch2-2026-09-21.md).


## 21/09/2026 — PATCH1 inscription/roster, local

Markers Quiz et Blind Test : `restart 21-09-2026/03` ; Bingo : `restart 21-09-2026/02`. Marqueurs modifiés uniquement ; aucun redémarrage ni déploiement. [Rapport](notes/paper-roster-patch1-2026-09-21.md).


20/09/2026 — Réécritures Play : prise en charge de `_` dans les tokens de session (`scheduleplan_…`). Changement HTTP/PHP uniquement, sans modification de processus, marker ou configuration WS/PM2. Aucun déploiement ni redémarrage effectué.



18/09/2026 — Runtime officiel expiré : markers locaux Quiz/Blind Test `restart 18-09-2026/03`, Bingo `restart 18-09-2026/02`. Aucun restart ni copie serveur. Livraison coordonnée à prévoir : Global (nouveau helper inclus), Games (bridge/projections), puis les trois packages WS avec leur helper de retry. Le contexte exact est capturé lors du read lifecycle : ne pas considérer d’anciens processus sans cette capture comme instrumentés. Aucun changement PM2/ports/env. [Rapport](notes/hub-runtime-expired-2026-09-18.md).


18/09/2026 — Robustesse reprise Bingo : seul marker Bingo `version.txt` préparé à `restart 18-09-2026/01`. Aucun restart exécuté. Contrat coordonné Global/Games/Bingo : heartbeat avec intention/instance Hub, page ID et motif structuré WS ; anciennes pages ouvertes à recharger lors d’une future livraison. Aucun changement de port, endpoint ou configuration ; Quiz/Blind Test WS inchangés.


## Markers WS — suspension Hub, préparation locale 10/09/2026

Quiz `web/server/restart_serveur.txt`, Blind Test `web/server/restart_serveur.txt` et Bingo `version.txt` passent à `restart 10-09-2026/01`, conformément au manifest. Ce sont des fichiers préparés dans le workspace, pas une preuve de copie ou de redémarrage. Aucun service, PM2, configuration, réseau de production ou DB réelle modifié. Le protocole nécessite la cohérence Global/Games/trois moteurs ; aucun rollout partiel n’a été effectué. [Patch et réserves](notes/hub-suspend-patch-2026-09-10.md).

<!-- AUTO-UPDATE:END id="hub-suspend-20260910-markers" -->

# PM2 (WS Bingo / BT / Quiz)

## Quiz / Blind Test — grâce primary, correctif local 09/09/2026

Markers préparés : Quiz `restart 01-09-2026/01` → `restart 09-09-2026/01`; Blind Test `restart 08-09-2026/01` → `restart 09-09-2026/01`. Seul `web/server/actions/connection.js` change côté runtime dans chaque moteur : les secondary ne court-circuitent plus la grâce ni le cleanup d'expiration engagé. Tests locaux dans `tests/primary-grace.test.cjs`. Aucun changement de configuration PM2, aucun déploiement DEV/PROD ni redémarrage exécuté; le marker n'est pas une preuve de livraison. Bingo inchangé.


## Blind Test — stand-by équipes, 08/09/2026

Le booléen `BLINDTEST_TEAMS_ENABLED=false` dans `blindtest/web/server/features.js` est chargé au boot ; aucune configuration PM2/env ajoutée. Marker préparé `restart 01-09-2026/01` → `restart 08-09-2026/01`. La livraison autorisée devra inclure le nouveau module, les handlers et les changements Games ; le marker ne prouve pas un redémarrage effectif. Aucun restart ni déploiement exécuté ici. Réactivation produit via chantier dédié, puis nouvelle validation et marker selon discipline existante.


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
