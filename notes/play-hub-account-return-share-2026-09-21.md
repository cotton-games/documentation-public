<!-- AUTO-UPDATE:BEGIN id="play-hub-account-return-share-20260921" owner="codex" -->
# Play — partage probable Hub et retour compte depuis Hub Play

## Preuves et périmètre

[Play README RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/play/README.md), « Update 2026-07-31 — EP auth: intention probable Hub » : intention conservée dans signin/signup et scripts auth, retour partagé Global. [Journal AI Studio RAW](https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb&raw=1), Septembre/Mars2026 : identique à la relecture précédente ; aucun nouvel écart ciblé signalé.

Preuve code : Games `app_hub_view_helpers.php` produit `hub_account_action=join` pour le parcours compte en fenêtre ouverte. Les formulaires et scripts POST le conservent déjà. En revanche, les branches finales signin/signup déjà authentifiées imposaient `app_games_hub_ep_detail_url_get` indépendamment de cette intention. C’est la cause locale établie ; pas de reproduction distante ni de garantie sur la version déployée.

## Correctif

- GET signin/signup déjà connecté, `join` explicite : helper historique `app_joueur_session_inscription_get_link` puis admission `app_games_hub_player_prepare_ep_return`, retour Hub Play avec token de connexion si succès.
- GET probable et retours WWW : EP sans admission ; intention absente/invalide reste probable. POST d’authentification inchangé. Les paramètres sont une intention de parcours, pas une preuve cryptographique d’origine.
- Avant/après fenêtre : garde historique du helper, aucun joueur créé. Capacité : garde existante conservée, aucun contournement ou modification de jauge.
- Fiche session Hub, probable déclarée/confirmée : appel du renderer `$render_share_block` existant, titre/texte soirée ou événement et lien de consultation WWW. Aucun argument d’accès au jeu. Placé après l’état de participation et avant les résultats d’une éventuelle S2 terminée. Sans probable ou après annulation : masqué. Parcours autonomes inchangés.

## Fichiers de ce complément

Play uniquement, code/tests :
- `web/ep/ep_signin.php`.
- `web/ep/ep_signup.php`.
- `web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`.
- `web/tests/ep_session_hub_cta_test.php`.

Docs : README/TASKS Play/Global/WWW, bridge, HANDOFF, CHANGELOG, annotations des deux notes précédentes, cette note et index générés. Aucun fichier applicatif Games, Global ou WWW modifié.

## Validation

Depuis `/home/romain/Cotton` :

```bash
php play/web/tests/ep_session_hub_cta_test.php
php play/web/tests/ep_hub_probable_capacity_test.php
php games/web/tests/hub_probable_play_contract_test.php
php global/web/tests/hub_ep_return_intent_test.php
```

339 contrôles du test partagé : expressions de redirection réelles des deux pages, helper retour réel, renderer et branche de partage réels ; DB/admission simulées. Cas connecté join/probable, conservation des paramètres liens/formulaires, retour POST partagé, fenêtre future/expirée sans admission, partage annoncé/annulé soirée/événement, canaux historiques et URL WWW sans runtime. Probable à50/50 :16 contrôles verts ; contrats Games/Global verts. Lint4 fichiers PHP et diff-check ; sitemap généré par `npm run docs:sitemap`.

Aucun navigateur ni parcours HTTP complet signin/signup interdomaines exécuté. Reste recette réelle avec compte connecté, connexion et création de compte, Hub ouvert et jauge applicable. Aucun accès DB/SSH, déploiement ou restart.

Rollback : retirer uniquement ces hunks, baseline incrémentale `/tmp/cotton-share-auth-baseline/` ; préserver les patches précédents non committés et régénérer les index documentaires.
<!-- AUTO-UPDATE:END id="play-hub-account-return-share-20260921" -->
