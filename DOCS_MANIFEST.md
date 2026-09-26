# Docs Manifest (Codex maintenance rules)

<!-- NOTE TO CODEX:
1) Only edit inside AUTO-UPDATE blocks.
2) If code changes impact an interface / DB write / entrypoint, update the matching canon doc blocks.
3) Keep IDs stable. Do not rename files without updating README.md index block.
4) Prefer short diffs: update only relevant blocks.
-->

## Update triggers (mapping)
<!-- AUTO-UPDATE:BEGIN id="manifest-triggers" owner="codex" -->

### Capacités agent DEV contrôlées

Évolution du contrat d’exécution Codex DEV (`/home/romain/Cotton/AGENTS.md`, capacités approuvées de `tools/dev/deploy-dev.sh`, `tools/dev/fetch-dev.sh`, `tools/e2e` et états d’authentification hors Git) → `canon/runbooks/dev.md` (bloc `dev-steps`, contrat central), `canon/runbooks/security.md` (`security-rules`), contraintes de `START.md`, `README.md` (`docs-index`), README/TASKS `canon/repos/documentation/` et `HANDOFF.md` ; régénérer les trois sitemaps et les INDEX via `DOCS_BRANCH=main npm run docs:sitemap`. Cette règle documente les capacités ; elle n’autorise aucune modification des wrappers, des secrets ou d’AGENTS.md. Aucune nouvelle page dédiée nécessaire. README/TASKS applicatifs seulement si ces dépôts sont réellement modifiés ; aucune livraison produit ni entrée CHANGELOG produit déduite de cette mise à jour documentaire.



Report ciblé sur `main` : conserver les statuts de livraison et les divergences fonctionnelles ; aucun merge ni script de promotion globale. Le suivi `canon/repos/documentation/{README,TASKS,INDEX}.md`, absent de main avant ce lot (404 API), est créé au minimum requis par la discipline repo-first, sans importer son historique develop. Le runbook existant couvre le contrat : aucune page dédiée au tooling. Régénérer avec le générateur main existant, sans importer le format privé de develop ; la dérogation de non-régénération du lot d’accès privé du 24/09 reste limitée à cet ancien lot.


Correction ciblée du contrat d’accès privé sur `main` (24/09/2026) → START, bloc `docs-index` du README, présent manifest et entrée dédiée HANDOFF (suivi de tâche inclus). Aucun ajout/déplacement de page : pour ce lot limité au contrat, conserver les index legacy et leur générateur sans régénération ; leur navigation est régie par START. Ne pas appliquer la promotion globale ni importer de contenu fonctionnel de develop. Cette exception de périmètre ne change pas la discipline de génération des autres chantiers.


Statuts de livraison et promotion documentaire → `canon/deployment-status.md`, START/README, README/TASKS des dépôts concernés et procédure de promotion. Conserver explicitement les exclusions PROD `sas_players`, `hub_session_readiness` et `cast` tant qu’aucune livraison de ces chantiers n’est confirmée ; une recette DEV ou une copie documentaire vers `main` ne vaut pas déploiement.

Hotfix minimal `hub_soiree` (`games/web/includes/canvas/core/hub_runtime_wait.js`, branche ciblée de `boot_organizer.js`/`ws_effects.js`, `php/hub_capacity.php`, fence dans `app_hub_view_helpers.php`, attente de `app_hub_remote_ajax.php`, register/auth des trois moteurs et tests associés) → `notes/hub-soiree-hotfix-2026-09-23.md`, README/TASKS Games/Bingo/BT/Quiz, bridge/actions/write-map/entrypoints, runbook DEV/markers, HANDOFF/CHANGELOG et état de livraison ; sitemap/index via générateur. Ce lot est distinct du sas `hub_session_readiness` : ne pas actualiser le contrat du sas comme s’il était livré. Audits de recette et reproductions associées (`scripts/diagnostics/bingo-player-init-race.mjs`) → même note, HANDOFF et TASKS des dépôts examinés ; distinguer défaut reproduit, cause PROD attribuée et correctif appliqué.


Readiness Hub (`**/hub*preparation*`, `**/hub*readiness*`, hooks Player/Master/Remote, admission ciblée et harnais) → `notes/hub-session-readiness-2026-09-23.md`, README/TASKS des cinq dépôts + audit Play, `canon/interfaces/canvas-bridge.md`, `canon/interfaces/hub-bot-test-runner.md`, `canon/data/bingo-write-map.md`, runbook DEV, HANDOFF/CHANGELOG, sitemap et index générés. Séparer protocole produit, limites diagnostiques, résultats simulés et recette réelle.


Adaptateur Hub Browser Bingo (`hub_test_bingo.js`, backend/scénario/UI communs, écho grid_hydrate, `bingo.game/ws/hub_test_observer.js` et hooks serveur/reset) → `notes/hub-bingo-browser-baseline-2026-09-22.md`, contrat Hub Bot Test Runner, README/TASKS Games/Bingo, tâche suivante Blind Test, runbook DEV, HANDOFF et index. Base AVANT `hub_soiree` attestée opérateur ; préserver preuve SHA AVANT+performance=APRÈS, vrais flux grille/queue/post-reset et différencier préparation hors KPI de première allocation.

Gameplay post-ready/stop/cleanup du Hub Bot Test Runner → `notes/hub-gameplay-cleanup-2026-09-22.md`, `canon/interfaces/hub-bot-test-runner.md`, README/TASKS Games/Quiz, runbook DEV, HANDOFF et index. Séparer propriété privée des sujets, résumé hydration immuable et bilan de retrait ; jamais déduire propriété d’un ancien stockage Hub partagé.

Harnais Hub unifié (`games/web/includes/bots/hub_test_*`, test_bots, pont Master, `quiz/web/server/actions/hub_test_observer.js` et hooks) → `canon/interfaces/hub-bot-test-runner.md`, `notes/hub-test-browser-delivery-2026-09-22.md`, README/TASKS Games/Quiz, runbook DEV, HANDOFF et index générés. Préserver les variantes instrumentation AVANT / performance APRÈS et distinguer tests synthétiques de recette réelle.

### Harnais et télémétrie WS A/B

Relevé DEV partiel et séparation envUtils AVANT/APRÈS Quiz → `notes/quiz-dev-envutils-baseline-2026-09-22.md`, compléments de la conception Hub et note A/B, README/TASKS Quiz, TASKS Games, HANDOFF. Distinguer copie vérifiée et attestation opérateur ; ne pas redemander les snapshots attestés sans contradiction.

Conception du scénario canonique Hub et migration des générateurs → `notes/hub-loadtest-unified-design-2026-09-22.md`, TASKS Games/Quiz/BT/Bingo, HANDOFF. Cette conception remplace la qualification produit par moteurs séparés ; les diagnostics directs restent avancés. Audit sans modification des contrats applicatifs actifs.

`*/loadtest.js`, `bingo_loadtest.js`, `loadtest_metrics.js`, handlers spécifiques loadtest, hooks diagnostiques capacité/publication/auth/queue et `games/tools/*ws_loadtest_ab.py` → README/TASKS Quiz/BT/Bingo/Games, runbook DEV, note `notes/ws-loadtest-ab-instrumentation-2026-09-22.md`, HANDOFF et markers WS si code moteur. Pas de modification de contrat métier par ces hooks ; CHANGELOG produit uniquement si un changement visible hors outils est introduit.


### Statuts de livraison et promotion documentaire

Toute annonce de déploiement ou évolution de périmètre de branche → `canon/deployment-status.md`, README général, HANDOFF, CHANGELOG, README/TASKS des repos concernés et sections/rapports propres aux branches exclues. La promotion vers main conserve les statuts non déployés ; ne pas déduire une activation applicative de la présence documentaire. Procédure : `notes/documentation-promotion-main.md`.


### Routing PATCH2 papier

| ID | Match | Docs |
|---|---|---|
| R25 | `games/web/includes/canvas/php/paper_score.php`, score/finalisation dans glues Quiz/BT, `games/web/includes/canvas/remote/paper_score_sync.js`, `*/web/server/actions/paperScore.js`, `games/web/tests/paper_score*`, `games/web/tests/paper_podium*`, priorité podium dans `app_hub_view_helpers.php` | `canon/interfaces/paper-score-corrections.md`, `canon/interfaces/actions.md`, `canon/interfaces/canvas-bridge.md`, README/TASKS Games/Quiz/Blind Test, HANDOFF, CHANGELOG, rapport PATCH2 ; markers/runbooks si WS |



## Snippet à coller dans tous les prompts Codex (Docs obligatoire)

0) Mettre à jour `canon/repos/<repo>/TASKS.md` (obligatoire, update-not-append).
0bis) Si changement fonctionnel : mettre à jour `canon/repos/<repo>/README.md`.
0ter-bis) Toute évolution sur les offres, la facturation réseau ou une périodicité (`id_paiement_frequence`, `montant_socle_ht`, agrégats mensuel/annuel) doit déclencher une mise à jour de la doc produit et des notes métier concernées.
0ter) Après toute modification de documentation : exécuter `npm run docs:sitemap` pour régénérer `SITEMAP.md` (version publique).
0quater) Source canonique : `cotton-games/documentation` privé. Entrée : `START.md` sur `main`, puis `SITEMAP.ndjson` → `README.md` → `DOCS_MANIFEST.md` → `HANDOFF.md` → pages ciblées. Pour la préparation, basculer explicitement sur `develop` après START ; pour la référence publiée PROD avec exclusions, rester sur `main`. Comparaison d’écart : même chemin sur les deux branches. API Contents authentifiée, headers de START et `COTTON_DOCS_TOKEN` dédié uniquement aux lectures GitHub ; aucune valeur de token enregistrée. Accès AI Studio indépendant.
0quinquies) Avant tout patch évolutif, consulter le journal global AI Studio public pour identifier les scripts, pages, workflows ou dossiers potentiellement modifiés hors workspace local, afin de recharger depuis les serveurs les éléments concernés avant audit/patch : `https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb`
1) Déterminer `changed files` via `git diff --name-only`.
2) Appliquer les “Routing rules” de ce fichier (`DOCS_MANIFEST.md`) et ouvrir uniquement les docs ciblés (pas de scan global).
3) Mettre à jour uniquement les blocs `AUTO-UPDATE` des docs ciblés (si pertinents).
4) Mettre à jour `HANDOFF.md` (toujours) : résumé + fichiers modifiés + docs touchées + TODO.
5) Si aucune règle ne match et que la zone est nouvelle → ajouter une règle au manifest (pas de scan global).

| Change in codebase | Match (paths/globs) | Update this documentation | Block IDs |
|---|---|---|---|
| POC expérimental Cast DEV (hors Hub/métier) | `pro/tools/cast-dev/**`, `games/tools/cast-dev/**`, `pro/web/cast/dev/**`, `games/web/cast/dev/**`, include Cast du Dashboard Pro | `notes/cast-dev-poc-2026-09-17.md` + README/TASKS Pro/Games + HANDOFF + CHANGELOG ; garde/config/URL/recette centralisés dans la note | blocs AUTO-UPDATE existants |
| Toute action (code ou doc) | *(règle transversale, sans glob)* | `canon/repos/<repo>/TASKS.md` (update-not-append) | n/a |
| Changement fonctionnel (flux/actions/contracts/env/log/DB writes) | *(règle transversale, sans glob)* | `canon/repos/<repo>/README.md` | n/a |
| Changement offre / périodicité / facturation réseau | `global/web/app/modules/ecommerce/app_ecommerce_functions.php`, `pro/web/ec/modules/compte/offres/**`, `www/web/bo/www/modules/ecommerce/reseau_contrats/**`, `www/web/bo/www/modules/ecommerce/offres_clients/**` | `notes/plan_migration_reseau_branding_contenu.md` + `canon/repos/global/TASKS.md` + `canon/repos/pro/README.md` + `canon/repos/pro/TASKS.md` | n/a |
| Changement d'offre client en propre / Customer Portal commercial | `global/web/app/modules/ecommerce/**`, `pro/web/ec/modules/compte/offres/**`, `pro/web/ec/modules/ecommerce/**`, configuration portail Stripe | `canon/interfaces/ecommerce-offer-change.md` + `canon/repos/global/README.md` + `canon/repos/global/TASKS.md` + `canon/repos/pro/README.md` + `canon/repos/pro/TASKS.md` + `canon/repos/www/README.md` + `canon/repos/www/TASKS.md` | n/a |
| Add/modify Canvas bridge payload/response or auth/idempotence behavior | `games/web/games_ajax.php`, `games/web/global_ajax.php`, `games/web/includes/canvas/php/**` | `canon/interfaces/canvas-bridge.md` | `bridge-contract`, `bridge-examples` |
| Add/modify an action / handler mapping (WS ↔ Canvas API ↔ PHP glue) | `games/web/includes/canvas/php/*_adapter_glue.php`, `games/web/includes/canvas/php/prizes_glue.php`, `bingo.game/ws/**`, `blindtest/web/server/**`, `quiz/web/server/**` | `canon/interfaces/actions.md` | `actions-list`, `actions-matrix` |
| New env var / port / endpoint / rewrite (PM2, WS, vhosts) | `**/.htaccess`, `**/pm2-*.ecosystem.config.cjs`, `**/version.txt`, `**/.env*`, `bingo.game/ws/**`, `blindtest/web/server/**`, `quiz/web/server/**` | `canon/entrypoints.md` + `canon/runbooks/dev.md` + `pm2-ws.md` | `entrypoints-table`, `dev-env` |
| Git hygiene / secrets / templates (private → public mirroring risk) | `**/.gitignore`, `**/config.php`, `**/config.local.php`, `**/global_config.php`, `**/global_config.local.php`, `**/*secrets*.env*`, `**/*.env*`, `**/*.pem`, `**/*.key`, `**/*.sql`, `**/*.log`, `**/_ops_local/**`, `**/_local/**` | `canon/runbooks/security.md` + `canon/runbooks/mirroring.md` + `HANDOFF.md` | `security-rules`, `handoff-status` |
| WS Bingo changes | `bingo.game/ws/**` | `canon/interfaces/actions.md` + `canon/interfaces/canvas-bridge.md` (+ `canon/data/bingo-write-map.md` si writes) | `actions-list`, `actions-matrix`, `bridge-contract`, `bridge-examples`, `write-map`, `write-sources` |
| User-facing change likely (UI/assets) | `games/web/**`, `www/web/**`, `pro/web/**`, `global/web/**` | `CHANGELOG.md` (+ `HANDOFF.md` si changement notable) | `changelog-latest`, `handoff-status` |

## Procédure anti-rescan (Codex)

But : mettre à jour la doc sans rescanner l’ensemble du dépôt.

1) Déterminer les fichiers modifiés : `changed = git diff --name-only <base>`
2) Appliquer les règles de routing ci-dessous (match par `paths/globs`) pour obtenir `targets.docs`
3) Ouvrir **uniquement** les documents listés dans `targets.docs` (pas de scan global)
4) Éditer **uniquement** les sections marquées `AUTO-UPDATE` dans ces documents
5) Si aucune règle ne match, **ajouter une règle** (paths/globs → docs), puis mettre à jour la doc correspondante
6) Log obligatoire : consigner dans `HANDOFF.md` (Actions réalisées + docs touchées + next steps)

---

## Routing rules (paths/globs → docs)

> Chaque règle est déterministe : un fichier modifié match un glob → ouvre les docs indiqués.

| ID | Match (paths/globs) | Docs à ouvrir (ordre) | Notes |
|---:|---|---|---|
| R26 | `global/web/app/modules/jeux/hubs/app_games_hub_pro_navigation.php`, `global/web/tests/hub_pro_navigation_test.py`, lecteurs publics Global/WWW/Play (listes, pagination, compteur établissement, SEO) et `global/web/tests/hub_public_navigation_test.py`, signal visibilité client, lecteurs Pro Home/Agenda/first-party/Dashboard/dates occupées, réconciliation des sessions retirées | README/TASKS Pro/Global (WWW/Play si lecteurs publics touchés), HANDOFF, CHANGELOG, `notes/hub-empty-pro-navigation-2026-09-22.md`, `notes/hub-public-removed-sessions-2026-09-22.md` ; README/TASKS Games si test/surface Games touché | Existence technique distincte de visibilité ; provenance durable après disparition de membership ; Quick Add explicite conservé |
| R24 | `games/web/includes/canvas/core/roster_snapshot.js` `games/web/tests/paper_roster*` et changements inscription/roster papier Hub/PHP/WS | `canon/interfaces/paper-roster.md` + README/TASKS Games/Global/moteurs touchés + HANDOFF + CHANGELOG | Population active, provenance historique, bind et autorité Remote/Master ; rapport PATCH1 |
| R1 | `**/games_ajax.php` `**/global_ajax.php` `**/*canvas*` | `canon/interfaces/canvas-bridge.md` | Contrat bridge Canvas / exemples |
| R2 | `**/ws/**` `**/*actions*` `**/*adapter*` `**/*glue*` | `canon/interfaces/actions.md` | Mapping actions/handlers |
| R3 | `**/.env*` `**/secrets*.env*` | `canon/entrypoints.md` `canon/runbooks/dev.md` | Variables d’env, setup local/dev |
| R4 | `**/pm2-*.ecosystem.config.*` `**/version.txt` | `pm2-ws.md` `canon/runbooks/prod.md` | Runbook PM2 / WS |
| R5 | `**/*.sql` `**/migrations/**` `**/*schema*` (hors migration QR Hub R12, lectures legacy R15 et pack Hub R16) | `canon/data/bingo-write-map.md` | Writes DB / schémas / migrations |
| R6 | `**/bingo*/**` | `canon/data/bingo-write-map.md` `canon/interfaces/actions.md` | Bingo = actions + writes |
| R7 | `**/*service-token*` `**/*auth*` `**/*token*` `**/*header*` | `canon/runbooks/security.md` | Tokens, headers sensibles, logs safe |
| R8 | `**/.gitignore` `**/config.php` `**/config.local.php` `**/secrets*.env*` `**/*.pem` `**/*.key` `**/*.sql` `**/*.log` `**/_ops_local/**` | `canon/runbooks/security.md` | Hygiène git / fuites / artefacts |
| R9 | `www/**` `**/ui/**` `**/assets/**` `**/*.css` `**/*.html` | `CHANGELOG.md` | User-facing changes |
| R19 | `pro/web/ec/ec.php` (styles CTA découverte) | `canon/repos/pro/README.md` `canon/repos/pro/TASKS.md` `CHANGELOG.md` `HANDOFF.md` | États hover/focus du CTA de commande ; aucune modification des autres liens |
| R20 | `global/web/tests/schedule_plan*` `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php` (SchedulePlan) `global/web/app/modules/jeux/sessions/app_sessions_functions.php` (suppression individuelle) `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` `pro/web/ec/modules/tunnel/start/ec_start_schedule_draft_helpers.php` `pro/web/ec/modules/tunnel/start/ec_start_script.php` (programmation) | `canon/repos/global/README.md` `canon/repos/global/TASKS.md` `canon/repos/pro/README.md` `canon/repos/pro/TASKS.md` `CHANGELOG.md` `HANDOFF.md` | Réconciliation Hub actif vide et compensation des brouillons ; aucune modification Master/Remote/Play ou rendu Agenda : les cibles runtime R11/R13 sont à ouvrir mais à modifier seulement si leur contrat change |
| R21 | `documentation/notes/hub-main-promotion-2026-09-09*` | `HANDOFF.md` `canon/runbooks/prod.md` `canon/repos/blindtest/TASKS.md` `canon/repos/quiz/TASKS.md` | Procédure de promotion incrémentale Games/Pro/Global et extension WS Blindtest/Quiz, manifestes ; fusion locale distincte de la copie manuelle, aucune garantie de copie à chaud |
| R10 | `**/SITEMAP.md` `**/DOCS_MANIFEST.md` `**/README.md` | `HANDOFF.md` | Gouvernance + cohérence doc |
| R11 | `global/web/app/modules/jeux/hubs/app_games_hub_demo_lifecycle.php` `global/web/tests/hub_demo_lifecycle_test.php` `games/web/includes/canvas/core/hub_demo_lifecycle.js` `games/web/tests/hub_demo_lifecycle_test.mjs` `games/web/tests/hub_demo_ux_contract_test.php` `games/web/tests/hub_master_test_visibility_test.php` `global/web/tests/hub_demo_intent_recovery_test.php` `global/web/tests/hub_session_test_remote_retry_test.php` `games/web/includes/canvas/core/launch_confirmation.js` `games/web/includes/canvas/css/hub_launch_confirmation.css` `global/web/app/modules/jeux/hubs/app_games_hub_removal.php` `global/web/tests/hub_session_removal_test.php` `games/web/modules/app_hub_removal_helpers.php` `games/web/tests/hub_session_removal_dom_test.mjs` `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php` `global/web/tests/hub_quiz_demo_substitution_test.php` `games/web/tests/hub_demo_error_feedback_test.mjs` `games/web/includes/canvas/core/hub_player_qr.js` `games/web/tests/hub_player_qr_test.mjs` `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php` `global/web/tests/hub_player_qr_storage_test.*` `global/web/tests/hub_player_qr_temporal_test.php` `global/web/tests/hub_player_qr_continuation_test.php` `global/web/tests/hub_player_qr_master_command_test.php` `games/web/modules/app_hub_view_helpers.php` `games/web/modules/app_hub_remote_ajax.php` `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php` | `canon/repos/games/README.md` `canon/repos/games/TASKS.md` `canon/repos/global/README.md` `canon/repos/global/TASKS.md` `canon/interfaces/canvas-bridge.md` `canon/repos/bingo.game/README.md` `canon/repos/bingo.game/TASKS.md` (si cycle démo Bingo concerné) | Contrats Hub Master/Remote/Play et projections UI ; bridge-contract |

| R12 | `migrations/hub_player_qr_dev.sql` `specs/tests/hub_player_qr_migration_test.py` | `canon/runbooks/hub-player-qr-migration.md` `canon/data/schema/OVERVIEW.md` `canon/repos/global/README.md` `canon/repos/global/TASKS.md` `canon/repos/games/README.md` `canon/repos/games/TASKS.md` `canon/runbooks/security.md` | Migration QR manuelle DEV ; DDL snapshot non déclaré migré ; sans données ni secret |

| R23 | `**/*hub*capacity*` `quiz/web/server/actions/registration.js` `blindtest/web/server/actions/registration.js` `bingo.game/ws/bingo_server.js` `games/web/includes/canvas/php/*adapter_glue.php` (jauge) | README/TASKS Global, Games, Quiz, Blindtest, Bingo, Play ; `canon/interfaces/canvas-bridge.md` ; `canon/data/bingo-write-map.md` ; HANDOFF/CHANGELOG | Offre effective, admission Hub atomique et snapshots ascendants ; note `notes/hub-capacity-upsell-2026-09-21.md` |
| R22 | `global/web/app/modules/general/branding/app_branding_ajax.php` (GET branding Hub) `play/web/tests/ep_hub_auth_media_test.php` `global/web/app/modules/jeux/hubs/app_games_hub_participation_cta.php` `play/web/ep/includes/ep_session_hub_cta.php` `play/web/ep/includes/ep_hub_auth_branding.php` `play/web/ep/modules/jeux/sessions/**` (CTA Hub) `play/web/ep/ep_signin.php` `play/web/ep/ep_signup.php` `play/web/ep/modules/compte/{authentification,joueur}/**` `play/web/ep/modules/jeux/hubs/ep_hubs_detail.php` `global/web/app/modules/entites/joueurs/app_joueurs_functions.php` (retours auth Hub) `www/web/fo/includes/fo_hub_participation_cta.php` `www/web/fo/modules/{jeux/sessions,entites/clients,operations/hubs}/**` (CTA Hub) | `canon/repos/play/README.md` `canon/repos/play/TASKS.md` `canon/repos/www/README.md` `canon/repos/www/TASKS.md` `canon/repos/global/README.md` `canon/repos/global/TASKS.md` `canon/interfaces/canvas-bridge.md` `CHANGELOG.md` `HANDOFF.md` | Participation Hub individuelle, compte EP depuis WWW et accès QR direct borné par fenêtre canonique ; aucune modification moteurs/équipes |
| R13 | `global/web/app/modules/operations/evenements/app_evenements_functions.php` `global/web/app/modules/jeux/sessions/app_sessions_functions.php` `pro/web/ec/modules/tunnel/start/**` `pro/web/.htaccess` (routes Start/supports papier) `games/web/modules/app_orga_ajax.php` `games/web/player_canvas.php` `games/web/remote_canvas.php` `**/hub_legacy*test.php` | `canon/repos/global/README.md` `canon/repos/global/TASKS.md` `canon/repos/pro/README.md` `canon/repos/pro/TASKS.md` `canon/repos/games/README.md` `canon/repos/games/TASKS.md` `canon/interfaces/canvas-bridge.md` `CHANGELOG.md` `HANDOFF.md` | Compatibilité runtime legacy Hub : lecture, réparation explicite, anciennes routes, portée des données et préparation sans offre ; audit détaillé dans notes, sitemap/index générés |
| R14 | `documentation/tmp/hub-prod-initial-schema-2026-09-08/**` `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php` (guard schema status) | `canon/repos/global/README.md` `canon/repos/global/TASKS.md` `canon/repos/pro/TASKS.md` `canon/repos/blindtest/TASKS.md` `HANDOFF.md` | Paquet schéma Hub PROD initial (13 CREATE InnoDB), PRE/POST contrôles et garde status ciblée ; aucune donnée/backfill/déploiement |
| R15 | `/tmp/cotton-hub-audit/10-prod-refresh-readonly.sql` `/tmp/cotton-hub-audit/11-prod-refresh-complement-readonly.sql` `/tmp/cotton-hub-audit/12-runtime-explain-readonly.sql` `/tmp/cotton-hub-audit/13-runtime-source-hashes-readonly.sql` `/tmp/cotton-hub-audit/REFRESH.md` `/tmp/cotton-hub-audit/RETOUR-REFRESH.md` | `canon/repos/global/TASKS.md` `HANDOFF.md` | Actualisation opérateur des sources legacy du backfill initial ; uniquement lectures, volumes datés, schéma manquant explicite, aucune migration déclarée exécutée ; artefacts locaux hors versionnement |
| R16 | `documentation/tmp/hub-prod-backfill-2026-09-08/**` `documentation/tmp/hub-prod-backfill-2026-09-09/**` | `canon/repos/global/TASKS.md` `HANDOFF.md` | Préparation locale backfill Hub59/70 : attributs, manifeste, SQL19 diagnostic et20–23 avec sorties hors bloc pour phpMyAdmin, captures PRE/POST ; révision FIXED_70 avec ajouts hors lot différés ; aucune exécution par l’agent, retours opérateur distingués ; batch09/09 et verrous sources/cibles, tokens hors versionnement, publication au compte |

| R17 | `documentation/tmp/hub-prod-code-2026-09-09/**` `documentation/notes/hub-prod-code-migration-2026-09-09.md` | `canon/repos/{global,games,pro,play,www,bingo.game,blindtest,quiz}/TASKS.md` `HANDOFF.md` | Audit migration code Hub vers main, conflits/séquences Git et validation candidate ; manifeste applicatif ordonné sans déploiement, aucune mutation du pack DB ; README seulement si comportement modifié |

| R18 | `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php` `pro/web/ec/modules/tunnel/start/ec_start_agenda_mode.php` `pro/web/ec/modules/tunnel/start/ec_start_script.php` `pro/web/ec/modules/tunnel/start/ec_programming_environment_parity_test.php` `documentation/notes/hub-dev-prod-parity-2026-09-09.md` | `canon/repos/pro/README.md` `canon/repos/pro/TASKS.md` `canon/repos/games/TASKS.md` `HANDOFF.md` | Parité des entrées Agenda Hub DEV/PROD ; audit des différences métier et environnement, suivi séparé du fallback Remote Bingo ; aucune activation PROD implicite |

## Server restart markers

But : rendre les relances WS **déterministes** et ne pas oublier de bump le “marker de restart”.

| Service | Match (paths/globs) | Marker à bump |
|---|---|---|
| WS Bingo | `bingo.game/**` | `bingo.game/version.txt` |
| WS Blindtest | `blindtest/web/server/**` | `blindtest/web/server/restart_serveur.txt` |
| WS Quiz | `quiz/web/server/**` | `quiz/web/server/restart_serveur.txt` |

## Post-edit required actions (si un glob match)

Si `changed files` match une règle ci-dessus, alors **Codex doit aussi bump le marker correspondant** (même si la modif est “mineure”).

Format de bump (une ligne unique) :
- `restart DD-MM-YYYY/NN`
- `DD-MM-YYYY` = date du jour
- `NN` = compteur (2 chiffres recommandé, 2–3 acceptés), incrémenté si on bump plusieurs fois le même jour
- Si le fichier est vide / absent / hors format : le réinitialiser à `restart <date_du_jour>/01`

Règle générale : pour toute modification, `HANDOFF.md` doit être mis à jour (au minimum : résumé + docs touchées).

### AI agent usage rules (quick)
- Start from private `cotton-games/documentation`, `START.md?ref=main` via GitHub Contents API. For preparation, switch explicitly to `develop` for sitemap, README, manifest, handoff and working docs; for published production documentation, keep `main` and its undeployed-work exclusions.
- Public mirror `documentation-public` references and old index entrypoint wording are **legacy / transition**. Resolve their documented paths via the private API as specified in START; do not use the mirror for primary navigation.
- Cite exact API URL (no secret), path, branch and heading; missing information: `non trouvé`. Compare the same path on both branches for drift audits.
- Trust hierarchy: `canon/` (source of truth) > `notes/` (non-canon context); use `HANDOFF.md` for current status and `CHANGELOG.md` for user-facing changes.
- Editing rule: only change canon content inside `AUTO-UPDATE` blocks; keep block IDs stable. Humans edit outside blocks.

### AI workflow rule (roles)
- Web AI agent (ex: ChatGPT web) = orchestrator only (plan + prompts + validation).
  - **Does not write code** and does not provide patches/diffs in chat.
  - **Chooses the strategy** and compiles the available information (canon + evidence) to implement it.
  - If **structural information is missing** (entrypoints, file locations, data flow, DB writes, WS/API contracts, env vars, side effects),
    the agent must request a **Codex audit** to retrieve verified details and avoid regressions.
  - Deliverable: **one or more clear, actionable prompts** for **Codex in VS Code** to apply the changes
    (scope, files to touch, acceptance checks, and any required doc updates).
- Codex (or IDE agent) = executor for all code/doc edits in the repo; apply update triggers to keep canon docs aligned.
- Consignation obligatoire: log every change in `HANDOFF.md` (“Actions réalisées”).

### No guessing / Evidence required
- Web agent orchestrates; do not infer missing facts.
- Any prod/deploy recommendation must cite proof (canon doc link, captured command output, or a Codex audit result).
- Accepted sources of truth: `canon/*`, output of commands run by the user/admin, and server config snapshots (env/PM2/reverse-proxy) pasted or captured.
<!-- AUTO-UPDATE:END id="manifest-triggers" -->

## Canon documentation (do not bloat)
- Canon documentation should be contractual, short, and link to code paths.
- Historical analysis goes to `notes/` (never canon).

## Snippet "documentation" à inclure dans tes prompts Codex
Colle ce bloc en fin de prompt pour forcer une mise à jour de doc cohérente.

> **Docs (obligatoire)**
> - Met à jour `canon/repos/<repo>/TASKS.md` (obligatoire, update-not-append).
> - Si changement fonctionnel : `canon/repos/<repo>/README.md`.
> - Mets à jour la documentation canon concernée **uniquement** dans les blocs `AUTO-UPDATE` (IDs stables).
> - Applique le mapping “Update triggers” ci-dessus :
>   - Interface Canvas (payload/response) → `canon/interfaces/canvas-bridge.md`
>   - Actions/handlers → `canon/interfaces/actions.md`
>   - Env vars / ports / endpoints → `canon/entrypoints.md` (+ `canon/runbooks/dev.md` si présent)
>   - DB writes / tables → `canon/data/bingo-write-map.md` (+ usage si besoin)
> - Si changement visible pour l’utilisateur : mets à jour `CHANGELOG.md` (bloc `changelog-latest`).
> - Si tu ajoutes une nouvelle surface (nouveau type de changement), complète le tableau “Update triggers”.
