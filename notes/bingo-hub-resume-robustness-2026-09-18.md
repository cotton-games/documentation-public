<!-- AUTO-UPDATE:BEGIN id="bingo-hub-resume-robustness-20260918" owner="codex" -->
# Robustesse suspension/reprise Bingo — 18/09/2026

Statut : patch local, non déployé. CTA Relancer après expiration de grâce exclu.

## A. Contrôle préalable et preuves RAW

- [START RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), sections « Règle preuve d’abord » et « Discipline de génération ».
- [SITEMAP texte RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), sections Repos / Project status ; [NDJSON RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.ndjson), entrées repo/status, rechargés directement avant finalisation.
- [SITEMAP Markdown RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md), « How to use » ; [README RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md), « Doc discipline » / « Automatisation des index docs ».
- [Manifest RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers », « Routing rules » R1/R2/R4/R6/R10/R11 et « Server restart markers ».
- [HANDOFF RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md), travaux suspension/reprise10–11/09 et démos17/09.
- [Games RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Reprise numérique active » / « Suspension officielle Hub » ; [Bingo RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/bingo.game/README.md), « Suspension officielle Hub » ; [Global RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), contrat de suspension. TASKS de ces trois repos consultés en RAW également.
- [Actions RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/actions.md), « Suspension Hub officielle » ; [Bridge RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/canvas-bridge.md), « hub_lifecycle » ; [Write map RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/bingo-write-map.md), « Suspension Hub officielle ».
- Journal AI Studio : URL publique fournie par l’utilisateur, fichier `documentation/general/0_ROADMAP.md`, sections EN COURS / TODO / Fait livré en PROD. Markdown brut intégral extrait de `const raw` sans exécuter le HTML ; `raw=1` renvoie aussi du HTML. Modifications externes des fichiers visés : **non trouvé dans le journal**. Les chemins signalés concernent notamment WWW/AI Studio/ecommerce/global_librairies, hors patch. Aucun rechargement serveur nécessaire identifié, aucune parité serveur certifiée. Le token d’accès du lecteur n’est pas recopié dans ce rapport.

## B. Causes corrigées

1. La génération du dernier `hub_resumed` survivait à une reprise active ultérieure. Le heartbeat légitime3 était comparé au lifecycle2.
2. Le serveur identifiait « same instance » mais envoyait le message générique de takeover. Le localStorage ne distingue pas deux pages. Le transport utilisait aussi la socket mutable dans les callbacks d’une ancienne connexion.
3. Le request_id existait dans le lifecycle, mais la cause initiale n’était pas conservée : Master, Remote et branche session_not_found étaient indifférenciables.

## C. Fichiers applicatifs et tests modifiés

### global — Validation canonique et matrice présence.

- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- `global/web/tests/hub_runtime_presence_generation_test.php`

### games — Contrat HTTP de présence, contexte bootstrap, diagnostic, client Remote/transport et tests.

- `games/web/includes/canvas/core/boot_organizer.js`
- `games/web/includes/canvas/core/end_game.js`
- `games/web/includes/canvas/core/hub_runtime_authority.js`
- `games/web/includes/canvas/core/ws_connector.js`
- `games/web/includes/canvas/php/hub_lifecycle.php`
- `games/web/includes/canvas/remote/remote-ui.js`
- `games/web/includes/canvas/remote/remote-ws.js`
- `games/web/modules/app_hub_view_helpers.php`
- `games/web/organizer_canvas.php`
- `games/web/remote_canvas.php`
- `games/web/tests/hub_demo_readiness_flow_test.php`
- `games/web/tests/hub_launch_confirmation_test.mjs`
- `games/web/tests/hub_remote_continuity_test.mjs`
- `games/web/tests/hub_suspend_test.mjs`
- `games/web/tests/hub_suspend_test.php`

### bingo.game — Remplacement exclusif, retirement serveur, propagation lifecycle, tests et marker local.

- `bingo.game/version.txt`
- `bingo.game/ws/bingo_server.js`
- `bingo.game/ws/hub_lifecycle.js`
- `bingo.game/ws/tests/hub_suspend.test.js`
- `bingo.game/ws/tests/remote_continuity.test.js`

## D. Nouveau contrat technique

La présence runtime utilise la publication Hub courante via `app_games_hub_remote_routing_intent_context_get` : génération et intention exactes, source et exécution ouverte du même Hub, focus officiel et instance Hub Master courante. `hub_master_instance_id` est distinct de l’identité runtime `master_instance_id`. Le bootstrap transmet l’identité Hub et l’intention ; aucun nouvel identifiant durable. Le lifecycle continue de bloquer une suspension effective, mais sa dernière génération de dégel ne remplace plus la publication. Après reprise génération2 puis perte involontaire du Master, une reprise active publiée en3 accepte uniquement3. Les démos gardent leur validation isolée existante et leur readiness.

Bingo `forcedDisconnect` porte `replacement_reason=same_continuity_reconnect|takeover`. Même navigateur **et** même `remotePageId` éphémère : reconnexion de page. Après suspension, une autre page du même navigateur peut remplacer silencieusement l’ancienne socket si celle-ci a été retirée par le serveur après release et si son couple exécution/request correspond au lifecycle désormais repris. C’est une preuve de retrait, pas une barrière de reprise : aucune attente Remote ni ACK ajouté. Deux pages actives distinctes, autre appareil ou identité insuffisante : takeover explicite. Le registre installe le nouveau propriétaire avant fermeture ; anciennes commandes refusées, cleanup par socket, terminaison après500ms si nécessaire. Front : arrêt des reconnects/timers/envois, close explicite après suspension, aucune modale ni navigation pour le motif de continuité ; événements d’une ancienne socket ignorés par le transport.

`HUB_SUSPEND_REQUESTED` précède l’envoi front et la persistance serveur ; `trigger=master_button|remote_button|session_not_found`, surface, request_id, Hub, exécution, source/runtime numériques, génération/intention et page éphémère. Le relais Bingo conserve ces diagnostics ; PHP relit les identités et la publication canoniques, puis garde le même request_id dans `hub_suspended` et `hub_suspend_released`. Liste explicite de champs, aucun token de session/reprise/accès ajouté au diagnostic. Les anciens clients sans diagnostic produisent `unspecified` ; aucune causalité rétrospective inventée pour Hub120/session30700/runtime17898.

L’identité Hub Remote (`hub_remote_instance_id`) reste l’autorité de la surface Hub et n’est pas assimilée au `remote_instance_id` historique Bingo. Le nouveau `remotePageId` est en mémoire du document partagé par ses reconnects, jamais en localStorage/sessionStorage : une duplication d’onglet exécutant le JS reçoit un autre ID. Génération/intention de routage ne servent pas à décider un takeover. La preuve de suspension ne sert qu’à établir que l’ancien document avait déjà été retiré ; le registre exclusif demeure indépendant.

## E. Tests et résultats

Toutes les vérifications ci-dessous sont locales, avec stockage et transport simulés. Aucun bootstrap applicatif connecté ni DB réelle.

- Global `php web/tests/hub_runtime_presence_generation_test.php` : **21 cas** A1–A8, génération future, champs manquants, ancien propriétaire Hub Master, session étrangère, mode invalide et deux producteurs de publication (Master / commande Remote terminée).
- Games `php web/tests/hub_suspend_test.php` : **77 contrôles**, dont diagnostic/request_id conservés et secrets exclus.
- Games `node --test web/tests/hub_suspend_test.mjs web/tests/hub_remote_continuity_test.mjs web/tests/hub_remote_ws_retry_test.mjs web/tests/hub_remote_presence_test.mjs web/tests/hub_remote_automatic_return_test.mjs web/tests/hub_active_resume_test.mjs web/tests/hub_launch_confirmation_test.mjs web/tests/hub_demo_reentry_runtime_test.mjs` : **47 résultats TAP verts**.
- Bingo `node --test ws/tests/hub_suspend.test.js ws/tests/remote_continuity.test.js ws/tests/bingo_reset.test.js ws/tests/bingo_quit_guard.test.js ws/tests/bingo_terminal_delivery.test.js` : **25 tests verts**.
- PHP Global : `hub_suspend_contract_test.php`, `hub_remote_control_contract_test.php`, `hub_demo_lifecycle_test.php`, `hub_demo_intent_recovery_test.php` passent.
- PHP Games : `hub_active_resume_test.php` (56 contrôles), `hub_remote_presence_read_test.php`, `hub_demo_readiness_flow_test.php`, `hub_demo_runtime_surfaces_test.php`, `hub_launch_confirmation_contract_test.php` passent. Fixtures readiness et chargement ESM adaptées au nouveau contrat.
- Syntaxe PHP/JS et `git diff --check` passent sur les fichiers modifiés.

La matrice Remote couvre reconnexion réseau, deux cycles suspend/reprise, zombie OPEN/CLOSING, autre téléphone, deux pages actives du même navigateur, identité legacy, mauvais request/exécution, socket fermée pendant auth, close synchrone/tardif, commande déjà en file, timer de reconnect déjà planifié, événements d’ancienne socket et perte de la frame avant4004. Le test instrumentation suit chaque trigger jusqu’aux payloads validate/suspend/release ; le test PHP contrôle sa persistance.

## F. Documentation

HANDOFF, README/TASKS Games/Global/Bingo, actions, bridge, write map, CHANGELOG et notes markers/runbook mis à jour dans les blocs AUTO-UPDATE. TASKS : entrées suspension existantes mises à jour. `npm run docs:sitemap` régénère sitemap texte/NDJSON/Markdown et index ; aucun index édité à la main. Pas de nouveau port, endpoint, schéma ou variable d’environnement : entrypoints/dev consultés, sans changement nécessaire.

## G. Risques résiduels et rollback

- Recette réelle mobile/multi-onglet et concurrence MySQL non exécutée. Les tests simulés ne prouvent pas les délais effectifs du navigateur ni une atomicité multi-requêtes SQL.
- Un reload actif sans signal de suspension perd son page ID ; si l’ancienne socket reste OPEN, takeover conservateur. Sans localStorage disponible, l’absence d’identité navigateur interdit la classification silencieuse.
- Après suspension confirmée, une page différente du même navigateur peut être qualifiée de continuité : l’ancien propriétaire est déjà retiré, donc aucun conflit entre deux pages actives n’est masqué. Deux nouvelles pages simultanées se départagent toujours par takeover, une seule propriétaire.
- Les IDs de page/navigateur sont des diagnostics de continuité, pas de nouveaux secrets d’authentification. L’auth Remote existante demeure obligatoire.
- Livrer ultérieurement Global/Games/Bingo ensemble et recharger les anciens Masters : les nouveaux champs HTTP sont obligatoires. Ancien client Remote sans motif structuré garde son comportement historique ; aucune garantie lors d’une livraison partielle.
- Rollback coordonné des seuls diffs applicatifs/tests/marker de cette passe. Aucun rollback de données ; les champs additionnels de diagnostic restent compatibles avec les lecteurs historiques.

## H. Aucun déploiement

Aucun déploiement, restart, SSH, accès DB réel, accès applicatif PROD/DEV, navigateur intégré ou modification serveur. Seuls les documents publics explicitement demandés ont été lus en réseau. Aucun commit ni push.
<!-- AUTO-UPDATE:END id="bingo-hub-resume-robustness-20260918" -->
