<!-- AUTO-UPDATE:BEGIN id="play-unified-hub-auth-20260921" owner="codex" -->

Complément style logo : signin/signup reprennent le traitement de `games/web/modules/app_hub_view_helpers.php`, `.hub-player-branding-logo` (register Hub) : logo centré sous formulaire, largeur maximale `min(150px,48vw)`, hauteur42px, opacité.72 et ombre légère. Marge basse du formulaire réduite à1rem uniquement lorsqu’un logo est présent. Fichiers Play à déployer : `web/ep/ep_signin.php`, `web/ep/ep_signup.php`, `web/ep/includes/css/ep_custom.css`. Journal relu inchangé ; lint PHP, suite de régression et diff-check vérifiés ; validation visuelle navigateur non exécutée. Aucun déploiement. Rollback ciblé : `/tmp/cotton-auth-logo-style-baseline/`.

# Signin/signup Play — branding et présentation Hub unifiés

## Preuves et cause

[Play README RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/play/README.md), « Update 2026-07-31 — EP auth: intention probable Hub » : contexte Hub conservé dans le parcours compte. [Global README RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Update 2026-07-26 - Branding Canvas Hub: fallback Cotton complet hors logo » : cascade et fallback branding existants. [Pro README RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/README.md), « Etat 2026-07-21 - Dashboard soirée/événement après quick-schedule » : début de programme et nombre de parties.

[Journal AI Studio RAW](https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb&raw=1), Septembre/Mars2026 : reconsulté avant patch, identique à la lecture précédente. Rechargements WWW déjà consignés ; aucun nouveau chemin ciblé signalé hors workspace.

Preuve locale : les pages ne chargeaient le branding que dans `if (!empty($id_securite_championnat_session))`. Le lien Games contient `id_securite_games_hub` ; son contexte servait uniquement au retour auth. Le correctif initial Hub a été étendu au complément utilisateur avant livraison de cette passe.

## Résultat

### Correctif médias et UI après captures — 21/09/2026

Le branding Hub est maintenant hydraté depuis Global via `global_ajax.php?t=general&m=branding&action=get&format=json&hub_token=…` : résolution des fichiers sur Global, cascade Hub sans surcharge session, URL versionnées conservées. Le paramètre Hub est prioritaire sur le token session ; Hub inconnu/inactif/en suppression retourne un échec sans résolution session. Les appels historiques sans `hub_token` restent inchangés. Play normalise les champs logo/visuel, utilise un timeout borné et conserve le fallback existant si Global est indisponible. Logo centré sous le formulaire, visuel non recadré arrondi à12px. Signin/signup uniquement : titre avec son style gras précédent, puis « · organisateur » secondaire (`client.nom_social`, sinon `client.nom`, pour une soirée ; `event.naming_nom` pour un événement ; aucun séparateur si absent). WWW soirée/événement : sous-titre sombre et URL organisateur complète en lien texte, avec retour à la ligne mobile.

Journal relu et inchangé avant patch. Le précédent helper contournait l’hydratation distante ; la détection des médias repose sur `is_file` et le `www_root` du processus appelant. Logo absent du rendu et arrondi absent du CSS confirmés localement.


Include commun en lecture seule :
- Hub explicite depuis Games, ou appartenance de la session WWW via `app_games_hub_get_for_session`.
- Hub actif : hydratation HTTP du branding Hub depuis Global, qui appelle `app_games_hub_branding_get($hub, 0)` ; fallback local existant si échec. Fallback couleur secondaire du texte si absente. Pas de branding propre à S2.
- En-tête SOIRÉE/ÉVÉNEMENT et titre COTTON + nom organisateur (Cotton non dupliqué, anciens noms génériques reconnus neutralisés), données échappées. Métadonnées en gras avec `app_games_hub_schedule_label_get`, comme Games : date, À partir de, nombre de parties.
- Probable : connexion/création pour annoncer et partager sa participation, accès au jeu par QR sur place.
- Join : connexion/création pour participer à cette soirée/cet événement 🔥.
- Contexte inconnu/inactif : pas d’hydratation Hub ; session autonome : branche historique conservée.

Aucune modification de `hub_account_action`, `hub_account_join`, token Hub, token source, liens croisés ou paramètres POST par le helper de présentation. WWW revient à sa fiche EP probable ; Games join reprend l’admission canonique dans sa fenêtre et sa jauge. Le branding ne crée aucune participation ni joueur.

## Fichiers

Play :
- `web/ep/ep_signin.php`.
- `web/ep/ep_signup.php`.
- `web/ep/includes/ep_hub_auth_branding.php` (nouveau).
- `web/tests/ep_session_hub_cta_test.php`.

Docs : README/TASKS Play/WWW/Global ; bridge ; manifest R22 ; HANDOFF ; CHANGELOG ; cette note ; sitemap/index générés. Complément médias : Global `web/app/modules/general/branding/app_branding_ajax.php` ; WWW `web/fo/modules/operations/hubs/fr/fo_hubs_view_shared.php` ; Play `web/ep/includes/css/ep_custom.css` et nouveau `web/tests/ep_hub_auth_media_test.php`. Games inchangé.

## Validation

Complément médias : `php play/web/tests/ep_hub_auth_media_test.php` —15 contrôles HTTP sur serveur local éphémère utilisant le routeur Global réel avec données simulées ; URL plates/structurées et versionnées, logo absent, Hub invalide/inactif/deleting, priorité Hub/session, JSON invalide, HTTP503 et serveur indisponible. Suite partagée389 contrôles (dont noms organisateurs échappés), probable/capacité16, contrats page Hub/auth Global/Games verts. Aucun serveur distant interrogé. Lint PHP et diff-check valides. Recette visuelle desktop/mobile à effectuer manuellement.


`php play/web/tests/ep_session_hub_cta_test.php` :387 contrôles verts. Include réel, helper canonique de métadonnées réel, introductions des templates signin/signup évaluées ; données et admission simulées. Couverture identique WWW/Games, contexte soirée/événement, branding/couleurs, titre échappé, S2→horaire global et3 parties, probable/direct, tokens conservés, cas inconnu/inactif/autonome. Régressions partage, auth et QR de la suite conservées. Lint4 PHP et diff-check ; `npm run docs:sitemap` exécuté.

Aucune recette navigateur/HTTP interdomaines/DB réelle ; pas de déploiement/restart. Reste vérifier visuellement une soirée et un événement avec branding personnalisé dans les deux parcours.

Rollback du complément : snapshot `/tmp/cotton-branding-media-baseline/`, inverser uniquement ses hunks et retirer le nouveau test HTTP.

Rollback initial : inverser uniquement les hunks de cette passe et retirer le nouvel include ; baseline initiale avant branding dans `/tmp/cotton-auth-branding-baseline/`, puis snapshot du complément dans `/tmp/cotton-auth-unified-baseline/`. Préserver les patches précédents non committés. Régénérer les index documentaires.
<!-- AUTO-UPDATE:END id="play-unified-hub-auth-20260921" -->
