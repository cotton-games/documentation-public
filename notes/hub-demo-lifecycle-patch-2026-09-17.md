# Correctif du cycle des démos Hub — 17 septembre 2026

<!-- AUTO-UPDATE:BEGIN id="hub-demo-lifecycle-patch-20260917" owner="codex" -->

## Statut

Patch local, non déployé. Aucun service redémarré, aucune DB réelle consultée ou modifiée. Journal AI Studio raw, START, sitemap et manifest consultés avant patch. Ce compte rendu complète le [test ciblé](hub-session-targeted-test-2026-09-17.md) et remplace ses anciennes descriptions du reset systématique et de la réentrée démo.

## Audit et corrections

1. **Sélection Remote.** Le resolver parcourait les membres et prenait la première démo ouverte, puis refusait éventuellement cette candidate sans chercher celle de la publication. Il sélectionne désormais exclusivement la source/exécution de l'intention publiée et de la génération courante ; identité d'intention, état ouvert, lifecycle et readiness sont requis. Aucun fallback sur une ancienne démo. Les publications prospect `master_launch` / `launch_session` restent prises en charge, séparément des publications de test client actif.
2. **Retour Hub.** La démo restait ouverte et sa présence/readiness permettait de la rejoindre après retour. Un droit de routage durable et irréversible est désormais fermé au retour, à la fin, aux signaux de déconnexion et au changement d'intention. Une barrière locale par exécution empêche aussi le rebond du navigateur avant confirmation serveur. Aucune réutilisation du contrat officiel `hub_suspend`.
3. **Bingo.** Le reset post-copie appelé sans identité était refusé (`BINGO_RESET_REQUEST_REQUIRED`). Il est redondant : `global/web/app/modules/jeux/bingo_musical/app_bingo_musical_functions.php:464` duplique la playlist courante en phase zéro, copie uniquement identité/position/numéro des morceaux et produit des grilles non attribuées. Aucun historique joueurs/gagnants n'est copié. Une récupération de copie partielle réinitialise phase/morceau et reconstruit morceaux/grilles. Le service Hub saute donc ce reset pour Bingo. Les autres resets et le runtime Bingo restent inchangés.

Les logs audités associaient le rebond à la même exécution/génération Blind Test (source 27831, copie 27841), les lancements Quiz à 27842/27843 et les échecs Bingo à la source 27844. Ils expliquent le défaut initial, sans constituer une validation du patch en production.

Points d'entrée : Global `app_games_hub_remote_routing_published_context_get`, `app_games_hub_remote_client_routing_state_get`, `app_games_hub_demo_execution_prepare` ; nouveau `app_games_hub_demo_lifecycle.php` ; Games `hub_demo_lifecycle.js`, `hub_transition.js` et gestionnaires Master/Remote.

## Contrat final

- Prospect : CTA de carte « Faire la démo », source propre à chaque carte, gardes commerciales et wording existants. Aucune dépendance à la nouvelle confirmation client actif.
- Client actif : aucun CTA global de test. Test ciblé depuis la confirmation du premier lancement officiel ou « Paramétrer la partie ». Les réglages dépendent de l'absence de démarrage de la cible ; la confirmation dépend de l'absence d'officielle actuellement présente ayant démarré.
- Contenu courant de la source, numérique et deux joueurs maximum ; substitution seulement pour Quiz papier incompatible. Tests papier accessibles sur Master et Remote.
- Lifecycle `preparing` → `active` → `closed`, fermeture définitive pour cette intention. Aucune reprise automatique, même avec un heartbeat retardé ou un retry après fermeture.
- Stockage dans `game_events`, action `hub_demo_lifecycle`, clé déterministe Hub/source/intention, verrou MySQL, sans migration. Échec de lecture/écriture : routage refusé.
- POST authentifié existant, action `demo_lifecycle`, source/runtime/exécution et CSRF ; heartbeat toutes les 3 s. Une surface déjà vue absente plus de 12 s ferme le droit à la prochaine observation ; démarrage Master absent après 45 s ferme la préparation. Remote n'est obligatoire qu'après sa première présence.
- Retour volontaire : fermeture demandée avant navigation (attente plafonnée à 2 s), keepalive à la fermeture de page. Les signaux WS/offline et fin naturelle utilisent le même droit démo. L'exécution/runtime peut subsister pour nettoyage ultérieur mais ne redevient pas candidate.

## Idempotence et erreurs partielles

L'intention est réservée avant duplication ; une identité stable permet de retrouver la copie après panne entre création et mise à jour du registre. Même intention en cours de préparation : même copie et même préparation ; nouvelle action : nouvelle intention et nouvelle copie. Une intention fermée ou une exécution déjà terminée ne peut pas être relancée par retry. Les commandes Remote conservent leur identité au retry. Double clic bloqué côté UI et verrouillage serveur conservé.

Les erreurs post-copie propagent `demo_session_id` (normalisation, registre, reset, exécution, lifecycle, publication) pour conserver une référence diagnostique. Pas de suppression des anciennes copies dans ce patch.

## Fichiers applicatifs modifiés

État local cumulé du patch ciblé et du présent correctif ; les modifications précédentes n'ont pas été annulées.

### games

- `web/includes/canvas/core/boot_organizer.js`
- `web/includes/canvas/core/hub_transition.js`
- `web/includes/canvas/core/launch_confirmation.js`
- `web/includes/canvas/css/hub_launch_confirmation.css`
- `web/includes/canvas/remote/remote-ui.js`
- `web/modules/app_hub_remote_ajax.php`
- `web/modules/app_hub_view_helpers.php`
- `web/organizer_canvas.php`
- `web/remote_canvas.php`
- `web/tests/hub_demo_error_feedback_test.mjs`
- `web/tests/hub_demo_readiness_flow_test.php`
- `web/tests/hub_demo_runtime_surfaces_test.php`
- `web/tests/hub_launch_confirmation_contract_test.php`
- `web/tests/hub_launch_demo_shortcut_test.mjs`
- `web/tests/hub_remote_contract_test.php`
- `web/tests/hub_remote_polling_test.mjs`
- `web/tests/hub_session_removal_dom_test.mjs`
- `web/tests/hub_session_settings_dom_test.mjs`
- `web/tests/hub_session_settings_test.php`
- `web/includes/canvas/core/hub_demo_lifecycle.js`
- `web/tests/hub_demo_lifecycle_test.mjs`
- `web/tests/hub_demo_ux_contract_test.php`
- `web/tests/hub_master_test_visibility_test.php`

### global

- `web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- `web/app/modules/jeux/sessions/app_sessions_functions.php`
- `web/tests/hub_demo_mode_contract_test.php`
- `web/tests/hub_quiz_demo_substitution_test.php`
- `web/tests/hub_remote_control_contract_test.php`
- `web/app/modules/jeux/hubs/app_games_hub_demo_lifecycle.php`
- `web/tests/hub_demo_intent_recovery_test.php`
- `web/tests/hub_demo_lifecycle_test.php`
- `web/tests/hub_session_test_remote_retry_test.php`

### Documentation

HANDOFF, CHANGELOG, DOCS_MANIFEST, README/TASKS Games/Global/Bingo, bridge Canvas, présente note et note du test ciblé ; sitemap et index régénérés. Aucun fichier applicatif Pro ou Bingo.game modifié.

## Validation locale

30 suites terminées avec code 0. Commandes à exécuter depuis le dépôt indiqué ; résultat attendu : assertions OK, sortie 0. Les deux cas supplémentaires de publications prospect Master/Remote dans le test Global lifecycle ont également été rejoués avec succès.

### games

```sh
node web/tests/hub_demo_lifecycle_test.mjs
php web/tests/hub_demo_ux_contract_test.php
php web/tests/hub_demo_readiness_flow_test.php
php web/tests/hub_prospect_card_action_test.php
php web/tests/hub_remote_contract_test.php
node web/tests/hub_remote_polling_test.mjs
node web/tests/hub_launch_demo_shortcut_test.mjs
php web/tests/hub_demo_runtime_surfaces_test.php
node web/tests/hub_demo_reentry_runtime_test.mjs
php web/tests/hub_demo_qr_reentry_contract_test.php
node web/tests/hub_demo_player_presentation_test.mjs
php web/tests/hub_session_settings_test.php
php web/tests/hub_launch_confirmation_contract_test.php
node web/tests/hub_session_removal_dom_test.mjs
php web/tests/hub_suspend_test.php
node web/tests/hub_suspend_test.mjs
php web/tests/bingo_reset_test.php
node web/tests/bingo_reset_generation_test.mjs
node web/tests/hub_demo_error_feedback_test.mjs
node web/tests/hub_session_settings_dom_test.mjs
php web/tests/hub_master_test_visibility_test.php
```

### global

```sh
php web/tests/hub_demo_lifecycle_test.php
php web/tests/hub_quiz_demo_substitution_test.php
php web/tests/hub_demo_mode_contract_test.php
php web/tests/hub_remote_control_contract_test.php
php web/tests/hub_session_removal_test.php
php web/tests/hub_suspend_contract_test.php
php web/tests/hub_demo_intent_recovery_test.php
php web/tests/hub_session_test_remote_retry_test.php
```

### pro

```sh
php web/ec/modules/tunnel/start/ec_start_hub_demo_dashboard_test.php
```

Contrôles supplémentaires : `php -l` de tous les PHP modifiés ; `node --input-type=module --check` sur stdin de tous les JS/MJS modifiés ; `git diff --check` Games/Global/Pro. Tous passent. Le mode module est nécessaire pour vérifier les imports ES des scripts Canvas. Documentation : `npm run docs:sitemap` puis `git diff --check`.

Les contre-épreuves UX couvrent séparément les huit exigences prospect/client actif, cartes Master/Remote, absence de CTA global actif, voies modales et wording. Les tests de routage utilisent le resolver réel avec frontières simulées ; lifecycle utilise un faux stockage MySQL, navigateur utilise VM/faux fetch/horloge. Les tests de copie et panne partielle n'utilisent aucune DB réelle.

## Réserves et rollback

Pas de validation navigateur/WS/MySQL de bout en bout sur environnement déployé. À rejouer : ancien Blind Test puis test Quiz papier, retour Hub, fin naturelle, fermeture/rupture réseau et nouveau test, Bingo puis retry après panne. Vérifier aussi les parcours prospect et officiels sur les deux surfaces.

Une perte sans signal ne peut pas être détectée instantanément : expiration 12 s et prochaine observation. Le throttling d'un onglet en arrière-plan peut faire expirer la présence et fermer la démo ; le contrat choisit alors une nouvelle action utilisateur, jamais une reprise. Plusieurs surfaces partagent le droit : la sortie de l'une ferme la démo pour toutes. Le coût des écritures périodiques/verrous et les comportements mobiles restent à observer en intégration.

Rollback coordonné Games + Global : retirer les changements applicatifs du présent correctif ensemble, en conservant les autres travaux locaux. Aucun rollback de schéma ; les événements lifecycle restants sont inertes pour l'ancien code. Revenir à l'ancien resolver réintroduit les défauts documentés.

<!-- AUTO-UPDATE:END id="hub-demo-lifecycle-patch-20260917" -->
