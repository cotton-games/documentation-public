# Hub Master mobile : podium sous la session — 20/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-mobile-session-podium-20260920" owner="codex" -->

Complément20/09 : Quick Add sans exception dans la règle de visibilité au focus ; ancien CTA mobile de type `presentation` refusé au renderer et masqué en CSS. Le code local ne le produisait déjà plus ; origine de l’affichage observé non confirmée (version servie à vérifier). Fichiers : renderer, CSS mobile, tests cartes/UI. Tests cartes/actions/UI/settings, PHP lint et diff-check verts. Non déployé ; diffuser ensemble renderer et CSS, puis vérifier visuellement Quick Add au focus et absence de Résultats.

Complément du20/09 : sur mobile, seul le footer de la carte de partie sélectionnée expose ses CTA/indications. Focus initial et restauration après refresh réutilisent `.is-selected` sans nouvelle logique JS ; la carte Ajouter suit également le focus (complément utilisateur). Modification limitée à `hub_master_mobile.css`, assertion ajoutée dans `hub_mobile_ui_test.mjs`. Suites UI mobile, actions, podium et settings vertes ; diff-check OK. Non déployé, recette visuelle restante. Rollback limité à cette règle CSS et son assertion.
Sur Hub Master mobile, les résultats/podium d’une session terminée sont présentés directement sous sa carte. Le podium agrégé Hub reste séparé.

Méthode : déplacement du nœud `data-hub-central-podium` existant après la carte sélectionnée terminée portant le même `data-hub-session-id`. Un commentaire DOM conserve sa place exacte dans la zone centrale desktop. Aucune duplication, aucun calcul ou mode de présentation modifié. Sans correspondance, le podium revient masqué à sa place initiale sur mobile. Complément demandé le20/09 : CTA mobile Résultats supprimé ; toucher/focus de la carte terminée pilote seul les résultats, comme sur desktop. Handler spécial présentation retiré, footer vide masqué en mobile. Gardes et sélection partagées conservées.

Le renderer de sélection repositionne les podiums ; le refresh existant remplace Programme et centre puis réinitialise le carousel. Un listener matchMedia unique appelle le renderer courant, remplacé à chaque refresh : pas de capture d’anciens nœuds. 991 → 992 → 991 restaure/repositionne sans reload. CSS mobile uniquement : largeur100%, espacement compact, aucun cadre ajouté. Podium Hub exclu du déplacement.

Fichiers Games de cette passe : `web/modules/app_hub_view_helpers.php`, `web/includes/canvas/css/hub_master_mobile.css`, nouveau `web/tests/hub_mobile_session_podium_test.mjs`, adaptations `hub_master_mobile_cards_test.php` et mocks `hub_master_mobile_actions_test.mjs`, `hub_player_qr_test.mjs`, `hub_session_settings_dom_test.mjs`. Dernier mock réparé : `querySelector` manquant depuis le compteur mobile, cause de l’échec préexistant, aucune logique compteur changée.

Tests exécutés depuis Games :
- `node --test web/tests/hub_mobile_session_podium_test.mjs` : 5 tests verts (DOM simulé, sélection, résultat orphelin, session prête, deux terminées, desktop/global, resize et hooks refresh).
- `node web/tests/hub_master_mobile_actions_test.mjs`, `node web/tests/hub_mobile_ui_test.mjs` : verts.
- `php web/tests/hub_master_mobile_cards_test.php`, `php web/tests/hub_master_mobile_post_test.php` : verts, dont21 checks POST simulés.
- `node web/tests/hub_player_qr_test.mjs`, `node web/tests/hub_session_settings_dom_test.mjs`, `php web/tests/hub_session_settings_test.php`, `node web/tests/hub_launch_confirmation_test.mjs` : verts.
- `php -l web/modules/app_hub_view_helpers.php`, `git diff --check` : verts.

Git Games : branche `hub_soiree`, HEAD `855c25a4f8a29d65e0381f1e8333f8b02fd3c4f2`. État initial déjà modifié (responsive, QR et marqueurs de départ) conservé ; aucun commit. Status final capturé ci-dessous. Pas de Pro/Global/moteur/DB, déploiement ou restart. Responsive antérieur validé en recette par l’utilisateur ; nouveau placement validé seulement en simulation. Recette visuelle restante : deux sessions terminées, session prête, refresh et resize sans reload ; vérifier rangs/photos et podium global. Rollback : retirer seulement les ajouts de cette passe, préserver les diffs préexistants.
```text
 M web/includes/canvas/core/canvas_display.js
 M web/includes/canvas/core/hub_player_qr.js
 M web/includes/canvas/play/play-ui.js
 M web/includes/canvas/play/player_identity.js
 M web/includes/canvas/play/register.js
 M web/modules/app_hub_view_helpers.php
 M web/tests/hub_launch_confirmation_test.mjs
 M web/tests/hub_player_qr_test.mjs
 M web/tests/hub_session_settings_dom_test.mjs
 M web/tests/hub_session_settings_test.php
?? web/includes/canvas/css/hub_master_mobile.css
?? web/tests/hub_master_mobile_actions_test.mjs
?? web/tests/hub_master_mobile_cards_test.php
?? web/tests/hub_master_mobile_post_test.php
?? web/tests/hub_mobile_session_podium_test.mjs
?? web/tests/hub_mobile_ui_test.mjs
?? web/tests/player_voluntary_leave_test.mjs
```

<!-- AUTO-UPDATE:END id="hub-mobile-session-podium-20260920" -->
