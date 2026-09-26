<!-- AUTO-UPDATE:BEGIN id="hub-participation-cta-20260920" owner="codex" -->
# CTA de participation Hub — patch local du 20/09/2026

> **Révision du21/09 :** le contrat et les résultats ci-dessous décrivent la passe historique du20/09. Les branches `ep_join`, join depuis page EP Hub et intention WWW `join` sont remplacées par [le contrat probable-only](hub-access-probable-only-2026-09-21.md). Contexte, temporalité, probables et exception QR permanent sont conservés.


## Préparation et sources

Arrêt initial sur les écarts WWW signalés par le journal ; reprise après confirmation utilisateur « fichiers rechargés ». Le diff WWW `.htaccess` rechargé n’est pas modifié par ce lot.

- [START RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), « Discipline de génération ».
- [Manifest RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers » et « Routing rules » ; ajout local de R22 pour ce contrat partagé.
- [Journal AI Studio RAW](https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb&raw=1), « Septembre 2026 », épisode `.htaccess`, et interconnexion des pages features.
- [README Play RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/play/README.md), « Update 2026-07-31 — EP auth: intention probable Hub ».
- [README Global RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Update 2026-07-31 - Participations probables Hub et présence runtime ».

## Contrat

Global expose un contexte de présentation sans inscription : Hub résolu, actif, contexte soirée/événement, temporalité canonique, probable EP et action. Le Hub inactif/expiré reste distingué d’une session autonome, pour ne pas retomber vers une inscription session.

EP fiche et carte partagent le renderer et les actions POST. Avant fenêtre : probable individuelle Hub, état annoncé, annulation logique. Pendant : join EP sans probable préalable ; le token source ne désigne pas la destination runtime. Les actions revalident le membership depuis la session, la fenêtre, l’identité EP et un jeton CSRF. Le GET génère uniquement le jeton de formulaire local, jamais de joueur Hub.

WWW classique conserve signin/signup avec intention Hub. Un compte déjà authentifié arrivant par GET est envoyé vers la page EP Hub ; le join est explicite. L’authentification POST conserve le contrat Global existant. Avant fenêtre, cette page EP permet la déclaration probable.

QR permanent : accès Hub Play direct sans compte obligatoire seulement si `app_games_hub_temporal_state` retourne `open`. Le marqueur de navigation public `qr_place=1` conserve cette intention jusqu’aux pages Hub/session/événement ; ce n’est pas une autorisation. Aucune interprétation du focus de la session source. Le programme établissement inclut les Hubs de J/J-1 encore ouverts et publiables, même si les sessions sources sont archivées, et retire leurs doublons de la liste ordinaire. Les autres critères de visibilité publique sont conservés.

## Fichiers applicatifs de ce lot

Global :
- `web/app/modules/jeux/hubs/app_games_hub_participation_cta.php` (nouveau).
- `web/app/modules/jeux/hubs/app_games_hubs_functions.php` (chargement du helper).

Play :
- `web/ep/includes/ep_session_hub_cta.php` (nouveau : rendu et action).
- `web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`.
- `web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`.
- `web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`.
- `web/ep/ep_signin.php`, `web/ep/ep_signup.php` (GET déjà authentifié).
- `web/tests/ep_session_hub_cta_test.php` (nouveau).

WWW :
- `web/fo/includes/fo_hub_participation_cta.php` (nouveau).
- `web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`.
- `web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`.
- `web/fo/modules/entites/clients/fr/fo_clients_view_shared.php` (cartes session, Hub, événement et QR ouvert).
- `web/fo/modules/operations/hubs/fr/fo_hubs_view_shared.php` (également utilisé par la page événement).

Le prefetch legacy de l’agenda EP est conservé pour les parcours autonomes ; le renderer Hub ignore ses flags. `ep_sessions_list.php` et `ep_perf_debug.php` ne nécessitent donc pas de changement.

## Vérification locale

Depuis la racine du workspace :

```bash
php play/web/tests/ep_session_hub_cta_test.php
php play/web/tests/ep_session_routing_contract_test.php
php play/web/tests/ep_hub_detail_contract_test.php
php global/web/tests/hub_ep_return_intent_test.php
php global/web/tests/hub_probable_participations_contract_test.php
php global/web/tests/hub_player_roster_registration_state_test.php
```

259 contrôles du nouveau test : contexte réel, temporalité et retour EP réels chargés sans bootstrap, actions et renderers réels ; données/persistance explicitement simulées. Couverture soirée/événement, probables absentes/déclarées/annulées/confirmées, limite J+1 midi, source terminée indépendante, WWW compte, QR invité, dédoublonnage événement, GET sans write, POST/CSRF, annulation/reload, destinations Hub et standalone. Contrats d’intégration des templates EP et position du CTA WWW ; pas de rendu navigateur complet. Les suites existantes ciblées passent. Lint PHP des fichiers modifiés et diff-check vérifiés ; sitemap/index générés.

## Limites et recette restante

Aucune DB réelle, aucun accès DEV/PROD/SSH, navigateur, déploiement ou restart. La persistance réelle et l’intégration HTTP interdomaines restent à recetter après livraison coordonnée Global/Play/WWW. Les tests de reactivation existants complètent les doubles du nouveau test.

Les probables équipe Quiz restent session legacy : aucune conversion automatique, aucun changement de modèle équipe. Pour une session Hub, le CTA individuel partagé précède les branches équipe. Les sessions autonomes gardent leurs actions historiques. Les anciens compteurs/prefetch legacy ne sont pas refondus dans ce lot.

Rollback : retirer uniquement les fichiers et hunks de ce lot, conserver le patch de routage Play, le `.htaccess` WWW rechargé et les travaux Games préexistants. Aucun changement de schéma ou de protocole WS ; aucun marker de restart.
<!-- AUTO-UPDATE:END id="hub-participation-cta-20260920" -->
