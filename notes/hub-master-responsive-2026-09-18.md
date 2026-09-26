# Hub Master responsive — 18 septembre 2026

Patch local non déployé. Hub Master est la surface organisateur Hub sur desktop et mobile. Aucun patch « individual launch » réintroduit.

## Preuves et périmètre

Relecture RAW : START main, SITEMAP.txt/ndjson et DOCS_MANIFEST develop ; README Games (Hub Master, QR, papier Remote-only du 01/09, test ciblé du 17/09, expiration confirmée du 18/09), README Pro (Master individuel du 16/09, parcours Master/Remote du 27/08), HANDOFF et journal AI Studio. Aucun fichier ciblé signalé hors workspace. Les mentions historiques de Master individuel sont remplacées par cette décision produit.

État initial propre (`git status --short` vide) :

| Repo | Branche | HEAD initial |
|---|---|---|
| Games | hub_soiree | 855c25a4f8a29d65e0381f1e8333f8b02fd3c4f2 |
| Pro | hub_soiree | 234deaef30e311ea31cd68871391688ea800bbfa |
| Global | hub_soiree | 0fbb78cfb868a3c996a6036c77d20811649a6401 |
| documentation | develop | ca89215e5a0585f0415fda2a96d13c86e0ec9ab1 |

## Contrat livré

Pro : le CTA mobile « Lancer la soirée » / « Lancer l’événement » ouvre le Hub Master existant dans le même onglet après contrôle d’accès frais. Les CTA individuels historiques du Programme Hub (lancement, résultats, duplication de démo) ne sont plus générés. Hors Hub inchangé. Les démos Hub passent par leur contrat canonique dans Hub Master. Le parcours desktop conserve sa décision Remote et son nouvel onglet. Un changement de breakpoint ferme les modales d’accès/Remote en cours.

Games : DOM partagé, feuille `web/includes/canvas/css/hub_master_mobile.css` limitée à `max-width:991.98px`. Ordre visuel : retour Dashboard, identité, QR/compteur confirmé, Programme vertical, inscrits/classement, résultats, lots, utilitaires. Chaque carte reçoit une action issue du même resolver PHP ; desktop garde son CTA partagé. Les actions mobile/desktop passent par le même handler, avec vérification du viewport et de la connexion du bouton après confirmation. Les résultats affichent la présentation existante. Le refresh ne recentre pas le Programme mobile, réinitialise les nouveaux boutons une seule fois et actualise identité/retour. Aucun changement des cadences.

Papier officiel : `master_surface=mobile` autorise uniquement la variante de surface du POST `launch_session`. Absence, valeur desktop ou valeur invalide conservent `PAPER_LAUNCH_REMOTE_ONLY`. Ce champ n’est ni une authentification ni une capacité persistante. Instance Master, contexte/token Hub et service `app_games_hub_session_launch_from_master` restent obligatoires. Le service conserve membership, offre, fenêtre, terminal, suspension, expiration, génération et exécution. Aucun changement Global/moteurs/DB/injection. `expected_execution_id` reste celui du contrat de reprise numérique ; la reprise papier n’ajoute pas cette garde numérique.

À 991 → 992 → 991, CSS et lecture courante de matchMedia changent immédiatement les actions, hints et surface transmise. Aucun stockage du viewport. Pas de Remote dans le parcours mobile. Aucun Cast ajouté.

QR : même URL/token/image serveur et règles prospect ; géométrie mobile issue du viewport, fermeture tactile/clavier, body bloqué pendant overlay puis libéré, focus/inert conservés. Compteur miroir des inscrits actifs Hub, tiret si donnée non confirmée. Classement et podium conservent sources/rangs/ex æquo/photos/presentation_mode ; podium Hub mobile sans scène imposée en 16:9. Lots déplacés sans nouveau contrat.

Navigation : Dashboard Pro → Hub Master → Master session contextualisé → Hub Master → lien explicite Dashboard. Le retour session canonique et les corrections papier existantes ne sont pas modifiés.

## Vérifications locales exécutées

Depuis Games :

```sh
php -l web/modules/app_hub_view_helpers.php
node --check web/includes/canvas/core/hub_player_qr.js
php web/tests/hub_master_mobile_cards_test.php
php web/tests/hub_master_mobile_post_test.php
node web/tests/hub_master_mobile_actions_test.mjs
node web/tests/hub_player_qr_test.mjs
php web/tests/hub_prospect_card_action_test.php
node web/tests/hub_transition_remote_test.mjs
php web/tests/hub_individual_terminal_master_test.php
node web/tests/hub_quick_add_refresh_test.mjs
php web/tests/hub_program_mutation_revision_test.php
node web/tests/hub_launch_demo_shortcut_test.mjs
node web/tests/hub_launch_confirmation_test.mjs
php web/tests/hub_launch_confirmation_contract_test.php
```

Résultats : suites ci-dessus vertes. 21 cas du dispatcher POST réel en processus PHP isolés, service métier simulé à sa frontière (pas de DB). Resolver/rendu PHP réels ; handlers JavaScript réels dans adaptateurs DOM/VM. Annulation pendant confirmation/resize, bouton détaché après refresh, identité de la carte, reprise numérique/papier, résultats sans lancement et géométrie QR testés. Ces tests ne prouvent pas un rendu navigateur ni une intégration DB/moteur.

Depuis Pro :

```sh
php web/ec/modules/tunnel/start/ec_start_dashboard_mobile_routing_test.php
node web/ec/modules/tunnel/start/ec_start_dashboard_mobile_refresh_test.mjs
php web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php
```

154 contrôles routage réussis (jeux 4/5/6, papier/numérique, offre active/absente, avant/pendant/après, terminal, soirée/événement et hors Hub) ; refresh et décisions fraîches 991 ↔ 992 verts. Suite canonique Dashboard verte.

Depuis Global (lecture seule) : `php web/tests/hub_paper_cold_runtime_bootstrap_contract_test.php` vert. Contrat statique de bootstrap papier, pas une exécution réelle d’injection.

## Recette navigateur / appareils restante

Aucun navigateur intégré, SSH, DB ou accès DEV/PROD. Aucun déploiement/restart.

| Largeurs | Orientations / cas |
|---|---|
| 360, 430, 991, 992, desktop large | 1, 3 et nombreuses sessions ; noms longs ; actif/prospect ; offre absente ; avant/pendant/après fenêtre |
| 390, 768 | Portrait et paysage, mêmes cas |
| 991 ↔ 992 sans reload | Layout, Programme, QR, Remote, actions papier, scroll, sélection, refresh et dialogs ouverts |

À vérifier : absence de débordement horizontal, QR réellement scannable, cibles tactiles, dialogues scrollables, classement avant/après première fin, podium/ex æquo et lots. Exécuter un papier officiel de chaque moteur sur mobile : injection canonique, arrivée contextualisée, corrections existantes, fin/retour Hub puis Dashboard. Sur desktop vérifier refus du POST direct et lancement Remote habituel. Vérifier numériquement reprise, expiration, suspension et démo isolée. Ces validations nécessitent l’environnement et restent ouvertes ; aucun résultat visuel ou DB n’est prétendu.

## Risques et rollback

Risque principal restant : rendu réel et parcours moteur sur téléphone. Revenir uniquement sur les fichiers de ce patch Pro/Games et la feuille CSS ajoutée rétablit le contrat précédent ; aucune migration ni donnée à annuler. Documentation à réaligner avec le code retenu. Ne pas revenir globalement sur les travaux antérieurs de la branche.

## Fichiers et contrôle Git final

`git diff --check` : code 0 sur les neuf repos. HEAD et branches inchangés. `git status --short` : seuls Games, Pro et documentation ont des modifications ; Global, Bingo, Blind Test, Quiz, Play et WWW propres. Aucun commit/push.

Fichiers applicatifs et tests (`M` modifié, `??` nouveau) :

games :

```text
 M web/includes/canvas/core/hub_player_qr.js
 M web/modules/app_hub_view_helpers.php
 M web/tests/hub_launch_confirmation_test.mjs
 M web/tests/hub_player_qr_test.mjs
?? web/includes/canvas/css/hub_master_mobile.css
?? web/tests/hub_master_mobile_actions_test.mjs
?? web/tests/hub_master_mobile_cards_test.php
?? web/tests/hub_master_mobile_post_test.php
```

pro :

```text
 M web/ec/modules/tunnel/start/ec_start_dashboard_mobile_refresh_test.mjs
 M web/ec/modules/tunnel/start/ec_start_dashboard_mobile_routing_test.php
 M web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php
 M web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_v2_style.php
 M web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php
 M web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php
```

Documentation : HANDOFF, CHANGELOG, README/TASKS Games et Pro, contrats actions/Canvas, ce rapport. `npm run docs:sitemap` a régénéré les trois SITEMAP et les INDEX, avec mise à jour des versions RAW au HEAD courant ; les INDEX des autres repos sont des fichiers documentaires générés.
