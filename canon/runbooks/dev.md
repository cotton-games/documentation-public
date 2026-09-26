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

## Capacités DEV contrôlées de Codex — 26/09/2026

Contrat issu des capacités locales validées manuellement et confirmées par l’opérateur, aligné avec `/home/romain/Cotton/AGENTS.md` (§7–20). Leur disponibilité ne prouve aucun déploiement applicatif ni aucune recette de ce chantier documentaire. Les procédures humaines et historiques ci-dessous ne donnent pas d’autorisation supplémentaire à Codex.

### Déploiement DEV via wrapper

Seul wrapper approuvé : `/home/romain/Cotton/tools/dev/deploy-dev.sh`. DEV uniquement, host imposé par le wrapper, upload fichier par fichier, sans SSH ni suppression distante ; vérification post-upload par taille distante. Rapporter les fichiers exacts et le résultat de cette vérification ; une vérification échouée interdit d’annoncer un déploiement réussi.

Repos autorisés : `games`, `pro`, `www`, `play`, `quiz`, `bingo`, `blindtest`, `global`. Leurs racines sont `/home/romain/Cotton/<repo>`, sauf `bingo` → `/home/romain/Cotton/bingo.game`. Le wrapper fait autorité sur ces mappings ; ne pas les reconstruire dans une commande de transfert directe.

`--dry-run` est disponible ; l’utiliser si le scope est incertain, si plusieurs fichiers nécessitent une revue du mapping, pour un nouveau motif de chemin/repo ou sur demande explicite. Déterminer le scope depuis les besoins runtime et les preuves, jamais uniquement depuis `git diff`. `games/web/config.php` est l’unique exception Git-ignored actuellement connue et explicitement déployable si nécessaire ; elle reste interdite au commit et n’autorise aucune autre exception.

Uploads refusés : catégories sensibles, `.git/**`, secrets, `.env*`, clés, certificats, DB locales, `node_modules/**`, logs et `*.log`, ainsi que tout chemin refusé par le wrapper. Ne jamais contourner un refus ni modifier le wrapper pour terminer une tâche.

### Lecture des logs DEV

Seul wrapper approuvé : `/home/romain/Cotton/tools/dev/fetch-dev.sh`. Lecture uniquement, listing et téléchargement contrôlés, option `--tail <N>` ; choisir le plus petit extrait utile. Artefacts stockés hors Git sous `/home/romain/.cotton-dev-artifacts/`, jamais committés.

Allowlist approuvée (le wrapper reste l’autorité) :

- `{repo}/logs/**`
- `quiz/web/server/server-logs.log` et `quiz/web/server/server-logs.N.log`
- `blindtest/web/server/server-logs.log` et `blindtest/web/server/server-logs.N.log`
- `bingo.game/ws/server-logs.log` et `bingo.game/ws/server-logs.N.log`

Aucun autre chemin autorisé sans preuve ; la visibilité dans un listing ne donne pas droit à une lecture arbitraire.

### Recettes navigateur et authentification

Playwright approuvé : `/home/romain/Cotton/tools/e2e` ; Chromium système validé : `/usr/bin/chromium`. Surfaces DEV validées :

- `https://games.dev.cotton-quiz.com/`
- `https://pro.dev.cotton-quiz.com/` et `https://pro.dev.cotton-quiz.com/signin`
- `https://play.dev.cotton-quiz.com/` et `https://play.dev.cotton-quiz.com/signin`
- `https://www.dev.cotton-quiz.com/`
- `https://www.dev.cotton-quiz.com/bo/`, `https://www.dev.cotton-quiz.com/bo/bo.php` et `https://www.dev.cotton-quiz.com/bo/signin`

`quiz`, `blindtest` et `bingo.game` hébergent les runtimes/serveurs WS ; ce ne sont pas des surfaces navigateur autonomes ordinaires. Les exercer via les flux Games/PRO/PLAY et les preuves réseau/WS/logs.

États persistants PRO, PLAY et BO validés, stockés hors Git sous `/home/romain/.cotton-playwright/`. Le BO nécessite HTTP Basic puis authentification applicative BO. Ces états et credentials sont sensibles : ne jamais afficher leurs valeurs, les copier dans un repo, les committer ou les inclure dans captures/rapports. Utiliser uniquement les outils approuvés.

Les recettes ciblées peuvent employer des contextes indépendants clairement nommés (Organizer/Master, Remote, Players, PRO/PLAY/BO), inspecter URL finale, HTTP, console, exceptions JS, WS, réseau, DOM, captures, traces et timings. Distinguer bruit console et échec fonctionnel ; une UI visible ne prouve pas la persistance DB.

### Boucle autonome bornée au scope demandé

Quand la tâche demande explicitement **implémentation + validation DEV**, Codex peut, sans confirmation à chaque étape : lire le canon et le journal AI Studio, auditer et résoudre les écarts serveur/workspace, patcher localement, tester, faire un dry-run si utile, déployer les fichiers ciblés via `deploy-dev.sh`, lancer la recette Playwright, récupérer les logs approuvés si nécessaire, diagnostiquer, corriger si l’échec est imputable au patch, retester, redéployer et rejouer la recette. Mettre à jour TASKS/README concernés, HANDOFF et les index selon le manifest.

Conserver une boucle bornée, réversible et fondée sur les preuves. Capturer l’étape en échec et distinguer régression du patch, problème préexistant, environnement, session/auth, runtime/WS, données, preuve DB manquante ou drift. Ne pas étendre le patch pour faire passer une recette. Signaler le blocage si accès, dépendance, contrat, drift ou preuve DB manquent, ou si le problème sort du scope. Un besoin de restart/infrastructure reste à transmettre à l’opérateur.

### Restrictions inchangées et DB

Toujours interdits : SSH, accès/déploiement PROD, suppression distante, infrastructure (dont restart direct, PM2/systemd/nginx/apache, DNS/firewall), accès DB direct automatisé, écriture DB automatisée, usage direct de credentials hors outils approuvés, contournement via FTP/lftp brut, SCP/SFTP/rsync ou shell serveur. Un secret, binaire ou accès techniquement disponible n’est jamais une permission. Voir aussi le [contrat sécurité](security.md).

**Aucun mécanisme DB read-only automatisé n’est approuvé.** Ne pas connecter MySQL/MariaDB, ni automatiser phpMyAdmin. Si une donnée DB est nécessaire, produire la requête SQL exacte et la décision qu’elle permettra de vérifier, puis attendre le résultat fourni manuellement avant de conclure sur l’état DB. Ne pas présenter l’UI comme preuve de persistance. Aucun write DB automatisé ni migration/DDL/réparation n’est autorisé par ce contrat.

Le compte rendu distingue tests locaux, fichiers déployés et vérification par taille, recette réellement exécutée, logs/traces consultés et preuve de persistance lorsqu’elle est nécessaire. Ne jamais convertir une validation manuelle antérieure en test exécuté pendant la tâche courante.


**25/09 — Recette robustesse à effectuer après livraison autorisée.** Markers locaux trois moteurs /05, aucun restart. Rejouer Player/Remote avant Master, orphelin E1→E2, E1 actif protégé, erreurs admission/hydrate, abandon/left/stale et probes concurrentes/reconnexion ; vérifier même E, reset Bingo au départ seulement et reveal Remote/reprise inchangés. [Commandes locales, matrice, rollback et proposition main](../../notes/hub-execution-robustness-backport-2026-09-25.md). Tests simulés verts, aucune qualification navigateur/charge réelle de ce patch.

**25/09 — Recette corrective Hub-native à effectuer après livraison autorisée (aucun deploy/restart ici) :** 1) nouvel E Blind Test : Master ACK → gameplay ; Remote compteur puis suivi client_routing, écran opérationnel sans lobby ni ACK Remote ; 2) suspendre puis Reprendre : même E, aucun écran Open Players/compteur/nouveau premier START, Remote reste Hub jusqu’à joinabilité ; 3) reload Remote en open, runtime actif puis suspendu : même E, transition correcte ou attente Hub. Répéter Quiz/Bingo ensuite. Contrôleurs/markers et5/10/5/90 inchangés. Sources, limites des tests locaux et rollback : note V2 AH.


**25/09 — Recette Hub-native à réaliser après déploiement autorisé :** code local prêt, aucun déploiement/restart effectué. Nouveau E numérique officiel DEV → natif par défaut ; `?hub_native=0` sur la surface qui demande le lancement → session pour nouvel E seulement. Préserver les E déjà ouvertes et leur mode. Tester Master puis Remote initiateur, secondary unique, Annuler opening/open, ACK sur même iframe/E, reprise/reload/takeover, suspension starting, retrait, papier/démo et late join. Collecter `hub_pregame_wave` pour la décision de stabilité ; 5/10/5/90 inchangé. Tests et rollback précis : note V2 AG. Markers locaux Quiz/Blindtest/Bingo25-09-2026/04.


**25/09 — Recette à préparer : vagues pregame.** Instrumentation locale, aucun serveur touché. Après livraison opérateur cohérente Global/Games/WS (markers25-09-2026/03), capturer INFO `HUB_PREGAME_WAVE` et rotations sur nouvelles E : arrivée irrégulière, scan QR en cours, left/reconnect, zéro connu, population inconnue, START/ACK. Rejouer `python3 scripts/diagnostics/hub-pregame-waves.py --telemetry <logs>` depuis documentation. `ack_sent` ne prouve pas réception/reveal.5/10/5/90 reste actif ; ne pas annoncer Hub-native livré. [Recette détaillée, coûts à mesurer et rollback](../../notes/hub-open-players-foundations-2026-09-24.md#af-hub-native--audit-du-delta-et-instrumentation-préalable-start--25092026).


**25/09 — C révisé, local non déployé : retrait Hub durable immédiat ; cleanup runtime non bloquant.** Tombstone + membership inactive + slot closed/removed + focus/présentation libérés dans la demande PHP, réponse removed/already_removed ; aucun moteur requis. Le moteur vivant observe le tombstone puis détache/ferme les sockets sans finaliser le Hub. Read retiré explicite, lifecycle/START/Player tardifs refusés, cleanup tardif sans mutation ; gameplay sain protégé. Ancien removing finalisable en retentant le retrait, sans réconciliateur. A/B, ensure, auto-start5s/10s/5s/90s, compteur et UI pregame conservés. Tests :20 suites principales,26 scénarios retrait moteur/retour,300 vérifications retrait PHP ; compléments admission/publics/Pro/fallback verts, effets externes simulés. [Contrat, fichiers et rollback C : section AC](../../notes/hub-open-players-foundations-2026-09-24.md). Markers25-09-2026/02 préparés ; aucun deploy/restart.


### 24/09/2026 — Qualification Open Players V2 après déploiement opérateur

Lot courant local non déployé : auto-start5s minimum / grâce sans bind10s / calme WS5s / watchdog exceptionnel90s, sans quorum (zéro valide). Exécuter `node /home/romain/Cotton/games/web/tests/hub_first_launch_contract_suite.mjs` (17 suites). Livrer de façon cohérente Games core/hub_pregame.js, hub_pregame_view.js et remote/remote-ws.js, les contrôleurs pregame Quiz/BT/Bingo et leurs markers24-09-2026/04. Le chargement des contrôleurs WS nécessite un redémarrage ultérieurement autorisé par l’opérateur ; aucune action serveur faite ici. Sur chaque moteur : zéro, fortes vagues de bots réels, vagues dépassant30s sans départ intermédiaire, calme5s après dernier bind ; watchdog90s tracé, aucun START double, rebind/reload même E, perte/retour primary, abandon avant START. Vérifier compteur central/légende et viewport Master ; aucun x/y. Les tests5000 sockets simulés ne qualifient pas une charge réelle. Rejouer suspension/papier/démo. [Contrat, limites et rollback, section T](../../notes/hub-open-players-foundations-2026-09-24.md).


## Recette Hub session readiness — 23/09/2026

**Non déployé ; aucune action serveur effectuée.** [Liste des cinq branches, protocole, tests locaux, SQL lecture seule et recette](../../notes/hub-session-readiness-2026-09-23.md). Qualifier 10/30/50/100 par jeu, Bingo froid/prepared et stock disponible/à compléter, double onglet/reload/Remote/retardataires. Vérifier le même E1 et la même deadline après erreurs. Ne pas qualifier les 15 s temporaires à partir des tests simulés ; collecter E1_start→ready et coût depuis le clic Master.


## Hub Browser Bingo — livraison AVANT et recettes50/200

Suivre [matrice, fichiers, recette et rollback](../../notes/hub-bingo-browser-baseline-2026-09-22.md). FileZilla local `/tmp/hub-bingo-ab-2026-09-22-ready/update-before/` :6 Games +8 JS Bingo puis marker Bingo `/05` en dernier, activation WS ultérieure par l'opérateur. Aucune copie Quiz/BT ni APRÈS. DEV Bingo/BT `hub_soiree` attesté, pas de snapshot préalable requis. Session cible officielle numérique du même Hub, prepared/off, grille hors KPI ; attendre post-reset pour ready. Export, Stop et cleanup du run, puis nouvelle session fraîche pour200. Aucun déploiement/restart/charge DEV effectué dans ce lot.

### Correctif Runner Hub gameplay/cleanup — Games seul

[Procédure et recette répétée](../../notes/hub-gameplay-cleanup-2026-09-22.md). Site local FileZilla : `/tmp/hub-test-quiz-gameplay-cleanup-ab-2026-09-22-ready/update-before/games/` (7 fichiers). Aucun Quiz/envUtils/marker à copier, aucun restart pour ce correctif. Off par défaut ; legacy Quiz après ready pour jouer. Arrêter les bots puis Retirer les bots du Hub après drain ; exporter les deux bilans distincts, garder l'onglet jusqu'au cleanup. Nouvelle session fraîche du même Hub pour le palier200. Identités v1/onglets perdus non importées automatiquement.

### Hub Load Test Browser / Quiz — lot préparé, non déployé

Suivre [livraison AVANT, premier Hub50 et rollback](../../notes/hub-test-browser-delivery-2026-09-22.md) et [contrat](../interfaces/hub-bot-test-runner.md). FileZilla local = `/tmp/hub-test-quiz-ab-2026-09-22-ready/before/`, jamais copie des non commités sas_players pour la baseline. Quiz envUtils DEV exact, ancien hubCapacity, marker /05 en dernier ; APRÈS /06 séparé. Observateur seulement DEV ou HUB_TEST_ENABLED=1. Même profil/origine Browser, vrai bouton Master, export JSON après drain. Aucun restart/charge réelle effectué ; arrêter le runner ne termine pas la partie et ne retire pas les joueurs Hub.

### 22/09/2026 — Baseline WS A/B instrumentée, à exécuter par l’opérateur

[Procédure complète : bundles AVANT/APRÈS, empreintes, commandes et rollback](../../notes/ws-loadtest-ab-instrumentation-2026-09-22.md). Ne pas copier les worktrees `sas_players` pour prendre AVANT : exporter l’overlay instrumentation seule sur refs `hub_soiree` figées, vérifier les fichiers DEV et le processus chargé, puis activer dans une fenêtre prévue. Aucun restart/charge réelle exécuté par Codex. 50→500→5 000 conditionnel, profils/grilles privés, jauge/fixture isolée, attente et answerRate0. Résumé INFO, stop/drain puis contrôle des effets persistants ; source Canvas du générateur Bingo à vérifier séparément de celle du moteur. Markers AVANT Quiz/BT /02, Bingo /03 ; APRÈS /03 et /04, tous datés22/09/2026. Les anciens markers ci-dessous décrivent les lots performance antérieurs.


### 22/09/2026 — Patch auth Bingo numérique, local

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](../deployment-status.md).

Bingo `version.txt` : **`restart 22-09-2026/02`**. Livrer ensemble `ws/bingo_server.js`, `ws/bingo_reset.js`, `ws/repository/base/player_repository.js` et `ws/repository/db/db_player_repository.js`, sur la base du lot capacité précédent. Restart WS Bingo requis après livraison autorisée, aucun exécuté. Quiz/BT inchangés, markers22/09 /01. Aucun nouvel endpoint/env/SQL/reload PHP. [Rapport, tests et rollback](../../notes/bingo-digital-auth-performance-2026-09-22.md).


### 22/09/2026 — Capacité WS / publication BT (local)

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](../deployment-status.md).

Cohortes fermées avant fetch de `hub_capacity_get` : aucun cache de réponse réutilisé par une admission ultérieure, contrat API/stock/verrou Bingo inchangé. Modules `capacity_reads.js` à livrer avec `envUtils` et helpers capacité. BT indexe le lookup Player. Markers Quiz/BT/Bingo : `restart 22-09-2026/01` ; redémarrage des trois WS nécessaire après livraison future autorisée, aucun effectué. Pas de nouvel endpoint/env/SQL ni reload PHP. [Contrat, tests et limites](../../notes/hub-capacity-publication-patch-2026-09-22.md).


## 21/09/2026 — Vérification locale PATCH3 Bingo papier

Depuis Cotton : `node games/web/tests/bingo_paper_patch3_suite.mjs`. Inclut PATCH2/PATCH1, corrections sans joueur et HTML Master/Remote simulés. Aucun service/DB réelle. [Matrice et limites](../../notes/bingo-paper-association-patch3-2026-09-21.md).


## 21/09/2026 — Vérification locale PATCH2 papier

Depuis Cotton : `node games/web/tests/paper_score_patch2_suite.mjs`. Transport/stockage simulés ; inclut la suite PATCH1 et les cas de présentation Hub341. [Rapport et limites](../../notes/paper-score-patch2-2026-09-21.md). Aucun accès applicatif DEV.


## 21/09/2026 — Vérification locale papier

Depuis Cotton : `node games/web/tests/paper_roster_patch1_suite.mjs`. Stockage/transport simulés uniquement. [Rapport](../../notes/paper-roster-patch1-2026-09-21.md), incluant échecs historiques comparés à HEAD. Aucune recette sur service DEV exécutée.


## Recette Play — tokens SchedulePlan (20/09/2026)

Après livraison des réécritures Play, ouvrir depuis l’agenda une session existante dont le token commence par `scheduleplan_`, avec `?back_to=agenda` : la route `manage/s1` doit atteindre le formulaire/authentification, sans 404 de routage. Vérifier ensuite s2, player-connect et signup/signin (public, session_join et signup privé), puis un token historique. Le fichier `.htaccess` contient des directives Nginx : sa prise en compte dépend de la configuration du vhost. Les 75 contrôles du test contractuel de routage local passent ; aucune recette distante ni action serveur effectuée.


# Contexte rapide (workspace apps + documentation)

Le workspace “apps” regroupe plusieurs sous-projets (PHP + Node) utilisés pour le site Cotton (`www/`, `pro/`, `global/`, `games/`) et des serveurs WebSocket temps réel pour certains jeux (`bingo.game/`, `blindtest/`, `quiz/`).

## Lancer en dev (pistes “factuelles”)
- PHP (`www/`, `pro/`, `global/`, `games/`): servir les dossiers web via Apache/Nginx/PHP-FPM, avec les réécritures `.htaccess` actives et un `SERVER_NAME` cohérent avec les configs (`*/web/config.php`, `global/web/global_config.php`, `games/web/config.php`).
- Landings reseau `www`: la route recommandee `/lp/reseau/{slug}` depend des reecritures `www/web/.htaccess`; `/lp/operation/{slug}` reste un alias compatible. La LP est alimentee par la TdR (`clients.seo_slug`) et, si disponible, par l'abonnement reseau actif le plus recent pour les champs de personnalisation. L'abonnement actif ne conditionne pas l'existence de la LP: sans support actif, la page sert seulement a rejoindre le reseau. Cote `pro`, `/utm/reseau/{slug}` garde l'arrivee signup et `/utm/reseau/{slug}/signin` pose le meme contexte avant d'ouvrir signin.
- Pivot gamification `pro`: les routes `/extranet/start/games/day/YYYY-MM-DD`, `/extranet/start/games/day/event/modal/YYYY-MM-DD` et `/extranet/start/games/day/event/script` dependent des reecritures `pro/web/.htaccess` et du runtime PHP/DB standard, sans service PM2/WS dedie.
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

### Hotfix hub_soiree — 23/09, préparation locale

**NON DÉPLOYÉ ; aucun restart effectué.** Markers préparés : Bingo `restart 23-09-2026/011` (base `/010`), Quiz/BT `restart 23-09-2026/01`. Aucun nouvel endpoint/env/port/module WS. Games PHP doit connaître `stage=admit` avant activation des WS modifiés ; ne pas livrer les fichiers complets de `hub_session_readiness`. [Liste exhaustive, commandes de test, recette et rollback](../../notes/hub-soiree-hotfix-2026-09-23.md).


Blind Test équipes : le flag métier `BLINDTEST_TEAMS_ENABLED=false` est versionné dans `blindtest/web/server/features.js`, **pas** une variable `.env`/PM2. Test autonome : `node --test ../blindtest/tests/teams-disabled.test.cjs` depuis documentation. Réactivation réservée à un chantier dédié ; ne pas modifier les secrets pour ce correctif.
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
