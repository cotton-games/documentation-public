# Test Hub lié à une session — 17 septembre 2026

<!-- AUTO-UPDATE:BEGIN id="hub-session-targeted-test-20260917" owner="codex" -->

Suite du 17/09 : le [correctif de cycle démo](hub-demo-lifecycle-patch-2026-09-17.md) remplace les descriptions de reset systématique et de réentrée dans une ancienne démo. UX prospect et client actif restent séparées.


## Statut et audit final

Patch local autorisé après audit, non déployé. Journal AI Studio, START, sitemap texte/NDJSON et manifest consultés avant modification. Aucun accès DB réel, redémarrage de service ou déploiement.

L'ancien producteur choisissait la première officielle et pouvait remplacer son contenu par une proposition indépendante. Le service commun retenu est désormais `app_games_hub_session_test_launch(hub, session_id, intent)` : source explicite, verrou partagé Hub, relecture des membres actifs et de la session, contrôle du propriétaire, source officielle prête, type supporté, disponibilité commerciale/temporelle et absence de démarrage de la source ciblée. Aucun fallback vers une autre session si la source a disparu.

Preuves applicatives (lignes de cette version locale) :

- Global `web/app/modules/jeux/hubs/app_games_hubs_functions.php:9734` : éligibilité de la source exacte ; `:9753` : verrou et relecture Hub ; `:9765` : producteur ciblé, garde numérique, substitution Quiz puis préparation/readiness/routage conservés.
- Global `web/app/modules/jeux/sessions/app_sessions_functions.php:189` : copie et synchronisation de la source, duplication Bingo ; `:366` : registre d'intention et reprise de copie.
- Games `web/modules/app_hub_view_helpers.php:1254` : état des réglages ; `:8773` : test dans la modale ; `:9551` : transport Master ciblé.
- Games `web/modules/app_hub_remote_ajax.php:566` : éligibilité des réglages ; `:1428` : test dans la modale ; `:3201` : commande Remote ciblée.
- Games `web/includes/canvas/core/launch_confirmation.js:40` : confirmation partagée, identité capturée avant attente et invocation du transport commun.

## Comportements et UX

Master appelle directement le backend autorisé avec session et intention. Remote transmet une commande contenant la session ; le consommateur Master appelle le même service. Les deux surfaces revalident droits/instance/CSRF et l'état métier ; Remote ne crée aucune démo directement.

Le test est accessible dans la première confirmation officielle et dans « Paramétrer la partie » tant que la cible n’a pas démarré, même après démarrage d’une autre officielle. La confirmation dépend des membres actuels : supprimer la dernière officielle démarrée peut la réactiver. Les réglages permettent de tester avant ouverture si les autres gardes autorisent la préparation. Les CTA globaux permanents ont été supprimés. Le test d'une session papier est disponible sur **Master et Remote**, puisque la démo est toujours numérique ; le lancement officiel papier reste régi par ses capacités existantes.

Contenu : playlist courante Blind Test, séries/lot_ids courants Quiz, playlist et contenu courant Bingo. Aucune suggestion indépendante pour une source compatible. Seul le Quiz papier incompatible conserve la substitution numérique existante. Limite deux joueurs, reset, readiness, routage et branding Hub/client/réseau/Cotton existants conservés. Prospect « Faire la démo » et producteur Pro historique restent distincts.

Hiérarchie commune : identité jeu/format/thème, nombre et aperçu des séries Quiz selon le view-model existant ; test secondaire puis renouvellement tertiaire ; options ; suppression danger en bas ; footer limité à Annuler/Enregistrer. Les options non enregistrées ne sont pas appliquées par le test : le contenu enregistré fait foi.

La confirmation capture la session avant attente. Double clic bloqué ; erreurs visibles ; suppression ou démarrage externe de la cible invalide le test. Un changement de contenu externe est relu au traitement. Une commande Remote retardée ne peut choisir la première session en remplacement de celle demandée.

## Idempotence

Le registre `game_events/hub_demo_launch_intent` réserve le token de copie avant sa création. Sous verrou d'intention, un retry retrouve la copie par ce token et peut réparer une synchronisation partielle ; la validation ready du registre vient après. Le même intent réutilise le runtime ; une nouvelle action volontaire crée un autre intent. Dans les réglages, les erreurs conservent l'intention jusqu'à une nouvelle ouverture volontaire.

Remote conserve la clé et donc l'identifiant de commande/intent `remote-command-ID`. Un retry explicite réarme seulement failed/expired, pour la même source. Pending/claimed/processing/completed/cancelled ne sont pas réouverts. Aucune migration SQL introduite.

## Fichiers applicatifs et tests modifiés

### games

- `web/tests/hub_master_test_visibility_test.php` (ajout du complément)
- `web/tests/hub_launch_confirmation_contract_test.php` (adaptation du complément)

- `web/includes/canvas/core/launch_confirmation.js`
- `web/includes/canvas/css/hub_launch_confirmation.css`
- `web/modules/app_hub_remote_ajax.php`
- `web/modules/app_hub_view_helpers.php`
- `web/tests/hub_demo_error_feedback_test.mjs`
- `web/tests/hub_demo_readiness_flow_test.php`
- `web/tests/hub_demo_runtime_surfaces_test.php`
- `web/tests/hub_launch_demo_shortcut_test.mjs`
- `web/tests/hub_remote_contract_test.php`
- `web/tests/hub_remote_polling_test.mjs`
- `web/tests/hub_session_removal_dom_test.mjs`
- `web/tests/hub_session_settings_dom_test.mjs`
- `web/tests/hub_session_settings_test.php`

### global

- `web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- `web/app/modules/jeux/sessions/app_sessions_functions.php`
- `web/tests/hub_demo_mode_contract_test.php`
- `web/tests/hub_quiz_demo_substitution_test.php`
- `web/tests/hub_demo_intent_recovery_test.php`
- `web/tests/hub_session_test_remote_retry_test.php`

### documentation

`HANDOFF.md`, `CHANGELOG.md`, `DOCS_MANIFEST.md`, README/TASKS Games et Global, `canon/interfaces/canvas-bridge.md`, présente note et index/sitemaps générés. Les descriptions antérieures du test global sont historiques ; les nouvelles sections du17/09 font foi.

## Complément après retour utilisateur

Deux règles distinctes remplacent la restriction initiale au premier lancement : test autorisé pour une cible non démarrée même si une autre a joué ; confirmation seulement si aucun membre officiel actuel n’a démarré. La suppression de la dernière officielle jouée peut rétablir la confirmation. Aucun effacement de trace QR.

Bug d’affichage reproduit dans le vrai renderer Master : `today` donnait `can_test=false`, contrairement à `before`/`open`. État accepté désormais. Remote utilise le garde général sans restriction globale de démarrage, puis le garde de la cible. Le backend conserve les validations de source, droits et contenu.

Test supplémentaire `games/web/tests/hub_master_test_visibility_test.php` : 48 combinaisons trois jeux, papier/numérique, dates, historique QR ; tests A jouée/B pending puis A supprimée dans les vrais rendus/projections Master et Remote. `hub_launch_confirmation_contract_test.php` et `global/web/tests/hub_quiz_demo_substitution_test.php` adaptés aux nouvelles règles. Exécuter `php web/tests/hub_master_test_visibility_test.php` depuis Games ; résultat attendu OK.

Validation du complément : 16 suites ciblées réussies (11 Games, 5 Global), comprenant visibilité, confirmation PHP/JS, raccourci démo, réglages PHP/DOM, contrat/poll Remote, readiness, renouvellement, suppression DOM, substitution Quiz, contrat démo, retry Remote, reprise d’intention et temporalité QR. Les résultats ci-dessous décrivent la campagne initiale ; aucun test avec DB réelle exécuté.

## Tests hors connexion

Résultat : **33 suites réussies sur 34** (12 Global, 21 Games, 1 Pro). Les anciens tests qui cherchaient le bouton global ont été adaptés au contrat ciblé. Les tests exercent les fonctions applicatives avec les frontières SQL/runtime simulées ; ils ne constituent pas une validation MySQL ou navigateur authentifié.

Commandes, depuis la racine du repo indiqué :

### Global

```sh
php web/tests/hub_demo_intent_recovery_test.php
php web/tests/hub_session_test_remote_retry_test.php
php web/tests/hub_quiz_demo_substitution_test.php
php web/tests/hub_demo_mode_contract_test.php
php web/tests/hub_remote_control_contract_test.php
php web/tests/hub_session_removal_test.php
php web/tests/hub_theme_renewal_guard_test.php
php web/tests/session_theme_renewal_planner_test.php
php web/tests/session_theme_renewal_apply_test.php
php web/tests/programming_quick_hub_service_contract_test.php
php web/tests/programming_quick_idempotency_contract_test.php
php web/tests/hub_suspend_contract_test.php
```

### Games

```sh
node web/tests/hub_launch_demo_shortcut_test.mjs
node web/tests/hub_demo_error_feedback_test.mjs
node web/tests/hub_remote_polling_test.mjs
php web/tests/hub_session_settings_test.php
node web/tests/hub_session_settings_dom_test.mjs
php web/tests/hub_remote_contract_test.php
node web/tests/hub_launch_confirmation_test.mjs
php web/tests/hub_launch_confirmation_contract_test.php
node web/tests/hub_session_removal_dom_test.mjs
php web/tests/hub_demo_readiness_flow_test.php
node web/tests/hub_demo_reentry_runtime_test.mjs
php web/tests/hub_demo_runtime_surfaces_test.php
php web/tests/hub_demo_qr_reentry_contract_test.php
node web/tests/hub_demo_player_presentation_test.mjs
php web/tests/hub_prospect_card_action_test.php
php web/tests/hub_theme_renewal_display_test.php
node web/tests/hub_theme_renewal_display_dom_test.mjs
node web/tests/hub_theme_renewal_dom_test.mjs
node web/tests/hub_quick_add_refresh_test.mjs
php web/tests/hub_suspend_test.php
node web/tests/hub_suspend_test.mjs
```

### Pro

```sh
php web/ec/modules/tunnel/start/ec_start_hub_demo_dashboard_test.php
```

Attendu : toutes les suites réussissent, sauf l'assertion préexistante de `programming_quick_hub_service_contract_test.php:228`. Elle interdit toute occurrence de `active_session_id` dans le fichier de recommandations, alors que le garde de renouvellement préexistant le lit. Le test et `app_programming_recommendations_functions.php` sont tous deux identiques à HEAD ; ce patch ne les modifie pas. Quick Add DOM et idempotence passent.

Couverture : cible B alors que A est première, contenu changé pour les trois jeux, Quiz incompatible, papier Master/Remote, fenêtre before/open et refus après clôture, source supprimée/étrangère/démo/démarrée, trace historique indépendante de la disponibilité de la cible, commandes retardées, double clic, erreurs visibles, retry stable et nouvelle intention. Injection de panne après copie et avant validation du registre : même copie récupérée ; échec de lookup traité sans recréer. Régressions prospect, Pro, remplacement, suppression, suspension et readiness/routing vérifiées.

Vérification complémentaire : syntaxe PHP des quatre fichiers applicatifs modifiés, `node --check web/includes/canvas/core/launch_confirmation.js` dans Games, syntaxe JS inline via les suites DOM, `git diff --check` dans les trois repos. Documentation : `npm run docs:sitemap`.

## Réserves et rollback

Recette navigateur authentifiée, rendu visuel sur mobile et concurrence/interruptions MySQL réelles restent à exécuter en environnement autorisé. La réservation et les pannes sont vérifiées par doubles SQL en mémoire ; aucune garantie supplémentaire de transaction multi-table n'est revendiquée. Les remplacements canoniques sont sérialisés par le verrou Hub ; les écritures historiques externes à ce verrou ne deviennent pas atomiques par ce patch.

La trace historique `player_qr_official_started_at` reste intacte pour son contrat QR. Elle ne bloque plus les tests ni la confirmation : les tests dépendent de la cible, la confirmation des officielles encore présentes.

Rollback : retirer ensemble les modifications applicatives Games/Global et leurs tests/contrats documentaires, en préservant les autres changements locaux. Ne pas effacer de données ; les entrées réservées restent dans le registre existant. Aucun rollback DB ou migration n'est requis pour ce patch local non exécuté sur une DB réelle. Après une éventuelle diffusion, examiner les intentions réservées avant un retour à l'ancien producteur.

<!-- AUTO-UPDATE:END id="hub-session-targeted-test-20260917" -->
