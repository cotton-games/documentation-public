# Dashboard Pro mobile — Master individuel — 16/09/2026

Correctif local non déployé. Audit autorisé sans journal AI Studio par l'utilisateur après le HTTP403 constaté. Preuves locales Git ; date de déploiement serveur non établie.

## Cause exacte et historique

La substitution par `$hub_master_url` dans Pro est infirmée. Le helper `ec_start_day_session_individual_access_get` produit toujours le launcher individuel via `app_session_get_link(..., flag_direct_launcher=1)`. Son bloc de construction est attribué par `git blame` à Pro `f6ac3f9a` du31/08. Dernier commit du fichier avant notre intervention : `eaca08277ecf46ad884955798b7b8264bfd93b2f`, 08/09/2026 à13:19:02+02:00. Le diff Pro du10/09 au HEAD16/09 ne remplace pas ce lien ; il concerne ici le Programme vide et le maintien du polling.

**Responsable : Games `71eb3c713e395aff269e5ebb73976362d8d5381b`, 08/09/2026 à13:19:32+02:00**, fichier `web/modules/app_orga_ajax.php:161–173`. Pas un changement du11/09. `git log -p`, `git blame -L 155,200` et `git show 71eb3c71^:web/modules/app_orga_ajax.php` concordent.

Avant ce commit, la résolution du membership était immédiatement suivie de :

```php
$organizer_individual_master_view_requested = trim((string) ($_GET['master_view'] ?? '')) === 'individual';
$organizer_individual_terminal_master_view = false;
```

Seules les sessions naturellement terminées entraient dans la redirection historique située ensuite. Le commit ajoute avant ces lignes :

```php
// Bare legacy bookmarks enter the Hub; explicit runtime and historical views retain their routes.
if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'GET'
    && !empty($ORGANIZER_HUB)
    && (int) ($ORGANIZER_HUB['flag_active'] ?? 0) === 1
    && ($ORGANIZER_HUB['hub_status'] ?? '') !== 'deleting'
    && (int) ($ORGANIZER_SESSION['flag_session_demo'] ?? 0) === 0
    && empty($_GET['hub_launch']) && empty($_GET['hub_execution'])
    && (!function_exists('app_session_edit_state_get') || empty(app_session_edit_state_get((int) $ORGANIZER_SESSION['id'], $ORGANIZER_SESSION)['is_terminated']))
    && (string) ($_GET['master_view'] ?? '') !== 'individual'
    && !headers_sent()) {
    header('Location: /hub/' . rawurlencode((string) $ORGANIZER_HUB['id_securite']) . '/master');
    exit;
}
```

Intention vérifiable dans le commentaire et `games/web/tests/hub_legacy_entry_routes_test.php` : orienter les anciens favoris vers leur Hub canonique tout en conservant les vues individuelles explicites. Le lien mobile ne portait ni `hub_launch`, ni `hub_execution`, ni `master_view`. `return_url` ne participe pas à ce garde. Une session officielle non terminée membre d'un Hub actif remplissait donc toutes les conditions : HTTP302 vers Hub Master, avant le rendu du Master individuel. Aucune information de viewport n'intervient dans cette branche.

Le commit Games `389cbe26` du11/09 modifie notamment la reprise dans `organizer_canvas.php` ; ce garde antérieur dans `app_orga_ajax.php` reste inchangé depuis le08/09. L'historique prouve l'introduction du défaut au08/09, pas sa date de mise en production ni celle de sa première observation.

## Chaîne complète du clic

1. Pro `ec_start_sessions_day.php:175–196` charge les membres canoniques du Hub et construit séparément `$day_hub_master_url=/hub/{token}/master`.
2. `ec_start_sessions_day_dashboard_view.php:329–349` appelle le helper individuel avec session, jeu, URL Hub, offre, fenêtre et chronologie ; ajoute seulement le `return_url` à son résultat officiel.
3. `ec_start_sessions_day_helpers.php:1924–2023` : résultats terminés d'abord ; démo commerciale via producteur historique ; gardes de fenêtre, contenu et lancement ; puis URL Global directe. Global `app_sessions_functions.php:3964` et branches des types4/5/6 produisent `/master/{id_securite}`.
4. Template Pro `dashboard_view.php:1010` : vrai `<a href=individual_access_url target=_blank data-dashboard-mobile-session-access ...>`. La démo utilise séparément un POST `session_duplicate`, avec contexte de retour/branding ; aucun formulaire officiel orchestré.
5. CSS `dashboard_v2_style.php:51`, media max991.98px vers602/682/701 : lien individuel caché par défaut puis visible sur mobile ; actions Hub desktop masquées sur mobile. À992px et plus, le header `dashboard_view.php:898` garde `/hub/{token}/master`.
6. JS `dashboard_view.php:1402` intercepte exclusivement `[data-dashboard-master-access-check]`, attribut absent du CTA mobile. `pro/web/ec/ec.php:1377–1398` trace le clic par beacon/fetch sans `preventDefault`, substitution de `href` ou navigation. Les refreshs thème, Format/Mode, Quick Add et retour/poll relisent la même page canonique et remplacent la carte/le Programme issu du serveur (`:2458`, `:2807`, `:2975`, `:3123`).
7. Games `.htaccess:7` route `/master/{id}` vers `global_ajax.php?t=jeux&m=orga&sessionId=...`, qui atteint `app_orga_ajax.php`. Son garde du08/09 transforme le GET mobile en302 `/hub/{token}/master`. Le desktop arrive directement sur cette surface par la route Hub (`.htaccess:2`).

## Correctif minimal

Cinq lignes ajoutées uniquement au helper Pro, après les gardes et le producteur Global : quand URL Hub et URL individuelle sont non vides, ajouter `master_view=individual` avec le helper de query existant. URL mobile finale : `/master/{id_securite}?master_view=individual&return_url=...`.

Ce choix utilise une exception déjà implémentée et testée dans Games. Il ne supprime pas le garde de migration des favoris : il neutralise son extension involontaire au CTA mobile, explicitement individuel. Pas de détection User-Agent, viewport serveur, nouvelle route ou nouvelle autorisation. Le membership et les bridges restent lisibles ; aucun appel à `app_games_hub_session_launch_from_master` n'est ajouté. Pro ne remplaçait pas l'URL : on complète ici son intention de surface pour le contrat Games existant.

Desktop, démos et résultats retournent par leurs branches existantes. Hors Hub, URL strictement identique. Papier : même Master historique qu'avant le garde du08/09, sans toucher à son masquage mobile, sa Remote, son impression, son diagnostic ou ses confirmations. Aucun code Games/Global, CSS ou JS de production modifié. Focus, injection, suspension/reprise orchestrée, quick-add, Hub Play/Remote et guards commerciaux restent inchangés.

## Tests et résultats

Test nouveau `pro/web/ec/modules/tunnel/start/ec_start_dashboard_mobile_routing_test.php` : vrais producteurs Global/Pro, vrai template du CTA, vraie branche de redirection Games ; seuls états DB et sorties HTTP sont simulés. Avant patch : **59 contrôles, 12 échecs** sur destination finale. Après : **59 contrôles, zéro échec**. Le seul contrôle de href aurait passé malgré la régression : le test vérifie aussi le redirect Games.

| Cas | Avant patch | Après patch | Résultat |
|---|---|---|---|
| Hub officiel numérique mobile, types4/5/6, pending/running | href individuel puis302 Hub | Master individuel explicite | OK |
| Même Hub desktop | Hub Master | Hub Master | OK, vrai CTA rendu |
| Mobile démo commerciale | POST duplication historique | Identique | OK |
| Mobile hors Hub | Master individuel | URL strictement identique | OK |
| Refresh Programme | Reproduisait le lien sans intention individuelle | Conserve le href individuel explicite | OK, fonction JS réelle |
| Session terminée | Résultats individuels | Identique | OK |
| Offre refusée / fenêtre fermée / avant / après | Aucun CTA officiel | Identique | OK |
| Papier mobile | Garde302 identique au numérique | Surface individuelle historique restaurée | OK routage ; UI papier inchangée |
| Favori nu / runtime explicite Hub | Hub / runtime | Identique | OK |

Test nouveau `ec_start_dashboard_mobile_refresh_test.mjs` : HTML issu du test PHP injecté dans le vrai `replaceProgramFromHtml` ; garde de clic desktop exécuté pour une cible mobile ; règles CSS max991.98px vérifiées. Adaptateur DOM minimal : les valeurs375/991/992/1366 sont des cas de contrat, pas une mesure de layout navigateur. Aucun navigateur authentifié ni serveur/DB réel utilisé.

Commandes depuis `pro/web/ec/modules/tunnel/start` :

```sh
php ec_start_dashboard_mobile_routing_test.php
node ec_start_dashboard_mobile_refresh_test.mjs
php ec_start_sessions_day_dashboard_test.php
php ec_start_hub_demo_dashboard_test.php
php ec_start_dashboard_program_helpers_test.php
php ec_start_dashboard_quick_source_hub_test.php
php ec_start_dashboard_quick_parameters_test.php
php ec_start_session_theme_renewal_ajax_test.php
php -l ec_start_sessions_day_helpers.php
php -l ec_start_dashboard_mobile_routing_test.php
node --check ec_start_dashboard_mobile_refresh_test.mjs
```

Depuis Games : `php web/tests/hub_legacy_entry_routes_test.php`, `php web/tests/hub_active_resume_test.php` (56 contrôles), `php web/tests/hub_remote_contract_test.php` : tous verts. `git diff --check` Pro et documentation : OK. Inspection statique du HTML réel via `php ec_start_dashboard_mobile_routing_test.php --html` : href individuel, `master_view`, `return_url`, aucun `hub_launch`.

Recette restante après diffusion autorisée : navigateur connecté client actif à375/991/992/1366px, numérique/papier/démo, refresh Programme puis clic ; vérifier le réseau et la surface effectivement visible. Rollback : retirer seulement les cinq lignes du helper Pro (réintroduirait le défaut) ; tests/docs associés identifiés. Aucun commit, push, déploiement ou restart.

## Journal AI Studio et documentation

Journal client : HTTP403. Journal général : HTTP200, dernières entrées09/09. Inventaire hors workspace depuis11/09 non certifié ; aucun fichier rechargé depuis serveur. L'utilisateur a explicitement autorisé la poursuite sans journal sur la base Git. Ne pas interpréter cet état comme « aucun fichier ciblé signalé ».

Routage documentaire : `DOCS_MANIFEST.md`, R13 et règles transversales. TASKS/README Pro, clarification du contrat README Games et TASKS Games, HANDOFF et CHANGELOG mis à jour dans les blocs existants ; cette note porte l'audit détaillé. Global/bridge consultés, contrats inchangés. Sitemap/index générés via `npm run docs:sitemap` et relus.

Entrées documentaires : [START main, « Discipline de génération »](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), manifeste local R13 ; invariant Games « Update2026-09-08 — Confirmation locale et reprise officielle Hub » : mobile sans exécution Hub et historique autonome conservés.
