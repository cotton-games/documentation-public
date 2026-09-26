# Reprise Master numérique active — 09/09/2026

Patch local `games:hub_soiree` + `global:hub_soiree`, sans déploiement ni redémarrage. Historique Git utilisé pour comparer les sources, jamais comme preuve de livraison PROD.

## Préalables et cause

START et SITEMAP raw develop relus, README/manifest/HANDOFF et contrats repo develop consultés ; journal AI Studio raw relu avant patch, aucune mention des fichiers Hub concernés. Entrée : https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/START.md ; contrats Games « Reprise Hub en Pause » et « En cours / Suspendue » dans https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md .

Les logs DEV rechargés montrent Hub307/session27758 (Blind Test numérique), clics17:16:28/17:16:39/17:17:04 : `/master/<session>`302 puis `/hub/<hub>/master`200. Le resolver `games_hub_master_card_action_resolve` choisissait un lien pour le focus actif, construit par `games_hub_session_master_url` sans contexte. `app_orga_ajax.php`, bloc « Bare legacy bookmarks », renvoie ces URL nues au Hub. Pas de fatal PHP requis pour expliquer le rebond.

## Chaîne auditée et corrigée

1. `games/web/modules/app_hub_view_helpers.php` : le renderer transmet désormais le runtime running au resolver. Seulement numérique officiel actif/running → action `launch_session` étiquetée Reprendre, avec ID d’exécution attendu provenant du contexte ouvert. Le POST garde le Master instance guard et `launch_intent_id`. Session suspendue → Relancer, premier lancement et démo gardent leurs branches ; papier officiel reste Remote-only. Un double clic de reprise est bloqué pendant la requête ; les erreurs de cette reprise sont visibles.
2. `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`, `app_games_hub_session_launch_from_master` : même service canonique, quatrième argument optionnel `expected_execution_id`. En actif numérique officiel, exécution ouverte réutilisable et session commencée sont obligatoires. Contexte périmé, exécution absente/différente, session terminée ou devenue suspendue → refus, aucune création de secours. Cette branche reprend directement l’exécution lue (`created=false`), ne réécrit pas le focus et n’appelle ni création d’exécution ni injection de joueurs.
3. Publication existante `app_games_hub_remote_routing_generation_publish` : même intention = même génération ; nouvelle intention = nouvelle génération, même execution_id. C’est la publication canonique existante, pas une seconde notion de reprise.
4. L’URL transporte le token session, `hub_execution`, `hub_transition=resume_existing_runtime`, `hub_routing_generation`. Le Hub est résolu par le membership existant. Aucun `hub_launch=1` dans cette reprise active. Le résultat conserve `transition_type=resume_existing_runtime`, `runtime_kind=existing` et la génération. Le Master navigue directement vers ce résultat sans validation Remote et sans attendre une commande Remote.
5. `games/web/organizer_canvas.php` valide le contexte contre l’exécution ouverte, le focus, le runtime courant (`organizer_state.runtime_status`), le format numérique officiel et la génération courante. Une intention de reprise périmée renvoie au Hub. La garde générale des anciens liens et les routes terminales ne sont pas modifiées. La config `hubResumeExisting` est une projection de cette intention existante, pas un nouveau type d’exécution.
6. `games/web/includes/canvas/core/boot_organizer.js` rattache ce contexte au mécanisme existant de restauration en Pause : le snapshot et l’index viennent du preload ; la Pause est republiée après registration. Cette intention interdit l’auto-start, même si `hub_launch` est aussi fourni. Le lancement réel passe toujours par le clic Play utilisateur. Les chemins premier lancement et suspendu restent inchangés.

## Registration Organizer / limites

Quiz et Blind Test : `web/server/actions/registration.js::registerOrganizer` réutilise `sessions[sessionId]` lorsqu’il existe, conserve joueurs/index et rattache le socket primaire ; la création ne concerne que l’absence de runtime. Bingo : `ws/bingo_service.js::authenticateClient` réauthentifie le même compte/jeu et relit son état, puis `bingo_server.js` traite la reconnexion/grâce existante. Aucun fichier WS, logique P0/grâce ou reset modifié.

Le test vérifie les portions d’identification/réutilisation et le bootstrap Pause avec stockage/transport simulés. Il ne prouve pas une reprise réseau complète ni la survie mémoire après destruction effective du runtime ou expiration de grâce. Cette passe ne crée pas de politique de récupération pour ces cas ; elle refuse une exécution Hub absente et ne change pas la registration WS.

## Hub Remote

`games_hub_remote_session_action` propose déjà Reprendre avec `command_type=launch_session` et `transition_type=resume_existing_runtime`. Il n’utilise pas l’URL historique nue, donc pas le même défaut de lien. `games_hub_handle_master_remote_launch_command` appelle le même service avec l’intention stable `remote-command-<id>` ; il conserve les paramètres de reprise de l’URL et ajoute les identifiants de commande. Il bénéficie donc symétriquement de la branche active stricte et du bootstrap Pause, sans nouveau patch de son handler.

La Remote revenue volontairement au Hub reste protégée pour le tuple quitté. Le poll canonique continue à refuser la même execution/generation ; une nouvelle intention Master publie une génération supérieure pour la même exécution, permettant au poll de rejoindre la bonne Remote historique selon ses gardes de présence. Aucun routage depuis `command_status`, aucun changement du routage terminal, de Hub Play ou du secours Bingo800ms.

## Preuves et tests

`games/web/tests/hub_active_resume_test.php` valide 42 contrôles et exécute les fonctions PHP réelles avec dépendances isolées. L’exécution `exec-existing` reste identique sur deux appels de la même intention puis sur une nouvelle intention ; générations simulées8/8/9. Création d’exécution, mutation de focus et injection lèvent une exception si atteintes dans le cas actif. La même reprise est vérifiée via le service appelé par Remote et via sa projection réelle. Les cas absents/périmés/suspendus/non commencés/terminés sont refusés pour une demande de reprise active. Les chemins Relancer et premier lancement sont vérifiés séparément avec leurs appels historiques autorisés. La garde legacy et la validation Organizer sont exécutées sur fixtures.

`games/web/tests/hub_active_resume_test.mjs` exécute les décisions réelles de restauration/autostart : Pause pour session commencée, zéro auto-start en reprise explicite, premier lancement conservé. Deux registrations Quiz/BT sur le même runtime conservent son identité, les joueurs/score et l’index ; deux authentifications Bingo gardent le même jeu/état. Transport et repository simulés, pas de connexion DB/WS.

Commandes depuis Games :

```sh
php web/tests/hub_active_resume_test.php
node web/tests/hub_active_resume_test.mjs
node web/tests/hub_remote_return_execution_test.mjs
node web/tests/hub_remote_paper_recovery_test.mjs
node web/tests/hub_transition_remote_test.mjs
php web/tests/hub_launch_confirmation_contract_test.php
node web/tests/hub_launch_confirmation_test.mjs
php web/tests/hub_individual_terminal_master_test.php
php web/tests/hub_presentation_runtime_separation_test.php
node web/tests/hub_demo_reentry_runtime_test.mjs
```

Suites ci-dessus vertes après reprise de la passe interrompue ; la simulation DOM de confirmation a été complétée pour fournir setAttribute/removeAttribute, présents sur les vrais boutons. Le test couvre maintenant aussi un unique POST au double clic, le refus visible et la nouvelle tentative. 46 scénarios de récupération papier/numérique. Global : `hub_legacy_runtime_compatibility_test.php` et `hub_paper_cold_runtime_bootstrap_contract_test.php` verts. Lint PHP/JS et diff checks réalisés. L’assertion statique de signature du test démo a été adaptée au quatrième argument optionnel, sans retirer ses assertions de comportement démo.

Échec préexistant confirmé : `hub_remote_master_ux_test.php`, assertion « SSR demo CTA eligibility » ligne80. Même échec sur copies HEAD avant patch dans `/tmp`, donc non introduit ici ; test laissé intact.

## Fichiers / livraison future / recette

Runtime Global : `web/app/modules/jeux/hubs/app_games_hubs_functions.php`.
Runtime Games : `web/modules/app_hub_view_helpers.php`, `web/organizer_canvas.php`, `web/includes/canvas/core/boot_organizer.js`.
Tests Games : deux nouveaux `hub_active_resume_test.php/.mjs`, assertion de signature adaptée dans `hub_demo_reentry_runtime_test.mjs`, simulation DOM complétée dans `hub_launch_confirmation_test.mjs` avec vérification du double clic, du contexte transmis, du refus visible et de la nouvelle tentative.

Livraison future coordonnée de ces quatre sources, Global avant les appelants Games ; pas de restart WS nécessaire pour ce patch de sources PHP/front. Aucun transfert effectué. Rollback : retirer ces changements ciblés ensemble, ce qui réintroduit le rebond ; conserver les patches de récupération Remote et P0 préexistants.

Recette DEV restante : session numérique officielle commencée → perte Master → retour Remote Hub → ouvrir Hub Master → Reprendre. Vérifier même execution_id, nouvelle génération, Master en Pause, index/joueurs conservés, aucune lecture automatique, Remote qui rejoint ensuite la session ; Play reprend uniquement après action utilisateur Master. Répéter avec Master reconnecté avant le clic, programme mixte papier/numérique, double clic et contexte devenu périmé. Aucun déploiement, redémarrage, SQL réel, commit ou push par cette passe.
