> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Entrypoints

> Ports, servers, and key web entrypoints.

<!-- AUTO-UPDATE:BEGIN id="entrypoints-table" owner="codex" -->

**25/09 — Robustesse WS locale non déployée.** Aucun port, endpoint ou variable d’environnement ajouté. Les entrées Organizer/Player/Remote restent identiques ; les contrôles de rôle/E et la fin des probes sont renforcés. [Contrat et backport](../notes/hub-execution-robustness-backport-2026-09-25.md).

**25/09 — Hub-native DEV local :** `games/web/modules/app_hub_embed_native.php` est partagé via view_helpers ; `hub_embed_state` reste sur `/hub/<token>/master|remote`, soumis à l’ownership existante. Assets `hub_embed_host.js`, `hub_embed_child.js`, `hub_embed_poc.css` communs aux deux surfaces. `hub_native=0` choisit le mode session uniquement pour les nouveaux E ; mode journalisé prioritaire. Retours natifs rendent un document léger sans second bootstrap Hub. Voir note V2 AG.


**25/09 — Instrumentation Hub-native préalable, locale.** Routes/ports/env inchangés ; `hub_pregame/read` service-only porte une projection population optionnelle pour diagnostic. Markers Quiz/BT/Bingo `restart 25-09-2026/03`, aucun déploiement/restart. [Fichiers et recette](../notes/hub-open-players-foundations-2026-09-24.md#af-hub-native--audit-du-delta-et-instrumentation-préalable-start--25092026).


**25/09 — POC DEV opt-in uniquement :** route Hub Master existante, lecture `hub_embed_poc_state` réservée Organizer/Master courant ; iframe même origine `/master/<token>`, aucun nouvel endpoint/port/WS. Activation A/B et retour enfant léger : [section AD](../notes/hub-open-players-foundations-2026-09-24.md). Recette DEV confirmée ensuite (section AE), aucun nouveau patch/restart lors de son analyse.

**25/09 — C révisé, local non déployé :** session_remove finalise le retrait sans moteur ; hub_pregame/read expose removed, cleanup tardif sans mutation ; lifecycle interdit la réactivation. Routes existantes, aucun worker. [Contrat/recette/markers02, section AC](../notes/hub-open-players-foundations-2026-09-24.md).


Auto-start pregame local24/09 : aucun nouvel endpoint, port ou env. Message WS HUB_PREGAME_AUTO_START server→primary, reprise du START/ACK existant ; section T de la note V2.


### 24/09/2026 — Open Players V2 (local)

Action Master existante étendue `open_players` ; Organizer reçoit `hub_transition=open_players` + `hub_execution`. Bridge Canvas existant étendu `hub_pregame`, service-only. WS et ports existants ; aucun WS Hub ni nouvelle variable d’environnement. [Lot cohérent et recette](../notes/hub-open-players-foundations-2026-09-24.md).


### Hotfix hub_soiree — 23/09, préparation locale

**NON DÉPLOYÉ ; aucun restart effectué.** Markers préparés : Bingo `restart 23-09-2026/011` (base `/010`), Quiz/BT `restart 23-09-2026/01`. Aucun nouvel endpoint/env/port/module WS. Games PHP doit connaître `stage=admit` avant activation des WS modifiés ; ne pas livrer les fichiers complets de `hub_session_readiness`. [Liste exhaustive, commandes de test, recette et rollback](../notes/hub-soiree-hotfix-2026-09-23.md).


### 22/09/2026 — Patch auth Bingo numérique, local

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](deployment-status.md).

Bingo `version.txt` : **`restart 22-09-2026/02`**. Livrer ensemble `ws/bingo_server.js`, `ws/bingo_reset.js`, `ws/repository/base/player_repository.js` et `ws/repository/db/db_player_repository.js`, sur la base du lot capacité précédent. Restart WS Bingo requis après livraison autorisée, aucun exécuté. Quiz/BT inchangés, markers22/09 /01. Aucun nouvel endpoint/env/SQL/reload PHP. [Rapport, tests et rollback](../notes/bingo-digital-auth-performance-2026-09-22.md).


### 22/09/2026 — Capacité WS / publication BT (local)

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](deployment-status.md).

Cohortes fermées avant fetch de `hub_capacity_get` : aucun cache de réponse réutilisé par une admission ultérieure, contrat API/stock/verrou Bingo inchangé. Modules `capacity_reads.js` à livrer avec `envUtils` et helpers capacité. BT indexe le lookup Player. Markers Quiz/BT/Bingo : `restart 22-09-2026/01` ; redémarrage des trois WS nécessaire après livraison future autorisée, aucun effectué. Pas de nouvel endpoint/env/SQL ni reload PHP. [Contrat, tests et limites](../notes/hub-capacity-publication-patch-2026-09-22.md).


## 21/09/2026 — PATCH3 Bingo papier

Aucun endpoint, port ni variable ajouté. Seul le WS Bingo change pour l’association facultative ; marker `bingo.game/version.txt` préparé `restart 21-09-2026/03`, sans restart. [Rapport](../notes/bingo-paper-association-patch3-2026-09-21.md).


## 21/09/2026 — PATCH2 papier

Mêmes endpoints/ports/env. Intentions `paper_score_update` et `paper_score_read` via `update_score`, réponse WS corrélée `paper_score_correction_result`, snapshot terminal `paper_score_snapshot`. [Contrat](interfaces/paper-score-corrections.md).


## 21/09/2026 — PATCH1 papier local

Endpoints et ports existants conservés. `admin_player_register` et `paper_player_bound` sont décrits dans [le contrat roster](interfaces/paper-roster.md). Maintenance des runtimes papier vivants toutes les5s, sans nouvelle variable d’environnement.


## Play — tokens de session (20/09/2026)

`play/web/.htaccess` utilise des directives Nginx. Les huit routes signup/signin, inscription `manage/s1` et `manage/s2`, et `player-connect` transportant `id_securite_championnat_session` acceptent désormais `_` en plus des lettres/chiffres/tirets (`[a-zA-Z0-9_-]+`). Les tokens `scheduleplan_…` conservent leur valeur jusqu’aux contrôleurs PHP existants. Patch local non déployé.



## Blind Test — coupe-circuit produit (08/09/2026)

`blindtest/web/server/features.js` : `BLINDTEST_TEAMS_ENABLED=false`, constante versionnée lue au boot WS ; pas de surcharge environnement/client. Protège les mutations, notifications runtime et scoring/classements ; Games cache la carte Player jusqu’à capacité WS explicite. Lecture historique conservée. Marker `restart 08-09-2026/01`. Aucun port/endpoint modifié.
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
- Routes Hub: `/hub/{hub_token}/master`, `/hub/{hub_token}/play` et `/hub/{remote_token}/remote` -> `games/web/games_ajax.php?t=jeux&m=hub_master|hub_play|hub_remote` via `games/web/.htaccess`. Le token Remote est dédié et distinct du token Hub public Master/Play.
- Routes runtime historiques utilisées après lancement Hub Remote: `/master/{session_token}` -> Organizer, `/remote/{game}/{session_token}` -> Remote jeu, `/play/{game}/{session_token}` -> Player. Une commande Hub Remote `launch_session` ne fournit pas ces URLs; Global les reconstruit depuis la session canonique, puis Hub Master navigue vers Organizer et Hub Remote vers la Remote historique après `completed`.
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
  - Les routes Hub Master/Play n'utilisent plus cet alias; il reste disponible pour les parcours historiques.
  - WS (ex: bingo.game) : fallback par défaut sur `games_ajax.php` ; `global_ajax.php` reste un alias côté PHP, pas la cible principale WS.
  - Canvas bridge: `games/web/games_ajax.php?t=jeux&m=canvas` (alias: `games/web/global_ajax.php?t=jeux&m=canvas`; writes idempotents via `event_id`, auth inter-service via header `X-Service-Token`, bypass dev possible uniquement si `CANVAS_DEV_ALLOW_UNAUTH_WRITES=1` + env dev détecté).
- Config runtime: `games/web/config.php` + réécritures `games/web/.htaccess`.
- Endpoints AJAX dédiés: `games/web/modules/app_orga_ajax.php`, `games/web/modules/app_play_ajax.php`, `games/web/modules/app_remote_ajax.php`.
  - Hub read-only: `games/web/modules/app_hub_master_ajax.php`, `games/web/modules/app_hub_play_ajax.php`, `games/web/modules/app_hub_remote_ajax.php`.

## `global/` (bibliothèque / backoffice “global”)
- Endpoint AJAX central: `global/web/global_ajax.php`.
- Config runtime: `global/web/global_config.php` + réécritures `global/web/.htaccess`.
- Modules fonctionnels: `global/web/app/modules/` (ex. jeux, ecommerce, entités, opérations).
- Note: legacy canvas UI sous `global/web/*/canvas/` supprimée (obsolète).

## `www/` (site www)
- Front office: `www/web/fo/fo.php` (+ `www/web/fo/fo_ajax.php`, `www/web/fo/do_script.php`).
- Back office: `www/web/bo/bo.php` (+ `www/web/bo/do_script.php`, crons `www/bo/cron_*.php`).
- API PHP: `www/web/api/*.php`.
- Landings reseau publiques: `/lp/reseau/{slug}` -> `www/web/lp/lp.php?utm_source=reseau&utm_campaign=affiliation&utm_term={slug}&utm_medium=landing-reseau`; compatibilite `/lp/operation/{slug}` -> meme LP avec `utm_medium=landing-operation`. Source de donnees: TdR (`clients.seo_slug`) + abonnement reseau actif le plus recent pour personnalisation optionnelle; CTA public vers `/utm/reseau/{slug}`; lien compte existant vers `/utm/reseau/{slug}/signin`.
- Config runtime: `www/web/config.php` + réécritures `www/web/.htaccess`.

## `pro/` (site pro)
- Espace “ec”: `pro/web/ec/ec.php` (+ `pro/web/ec/ec_ajax.php`, `pro/web/ec/do_script*.php`).
- Auth: `pro/web/ec/ec_signin.php`, `pro/web/ec/ec_signup.php`, `pro/web/ec/ec_sign.php`; affiliation reseau: `/utm/reseau/{slug}` -> signup, `/utm/reseau/{slug}/signin` -> signin, avec resolution du contexte par `ec_sign.php`.
- Pivot gamification: `/extranet/start/games/day/YYYY-MM-DD` -> page pivot; `/extranet/start/games/day/event/modal/YYYY-MM-DD` -> fragment HTML de modale page evenement; `/extranet/start/games/day/event/script` -> sauvegarde JSON via `do_script.php`.
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
