# Audit - Content Library + Liaison session/demo (preuve d'abord)

Date: 2026-02-12
Périmètre audité: `pro/web` (+ schéma SQL local `canon/data/schema/DDL.sql`)
Contraintes: audit only, aucune implémentation feature.

## 1) Cartographie `pro/web` (entrypoints, routing, dispatch)

### Entrypoints applicatifs
- `ec` (espace client/pro):
  - Page entrypoint: `pro/web/ec/ec.php` (`session_start`, lecture `t/m/p`, rendu module dynamique). Preuves: `/home/romain/Cotton/pro/web/ec/ec.php:9`, `/home/romain/Cotton/pro/web/ec/ec.php:25`, `/home/romain/Cotton/pro/web/ec/ec.php:301`, `/home/romain/Cotton/pro/web/ec/ec.php:875`.
  - Script POST dispatcher: `pro/web/ec/do_script.php` (dispatch sur `modules/$t/$m/ec_${m}_${p}.php`). Preuves: `/home/romain/Cotton/pro/web/ec/do_script.php:24`, `/home/romain/Cotton/pro/web/ec/do_script.php:40`.
  - Script spécifique: `pro/web/ec/do_script_specifique.php` (dispatch direct même convention). Preuves: `/home/romain/Cotton/pro/web/ec/do_script_specifique.php:22`, `/home/romain/Cotton/pro/web/ec/do_script_specifique.php:28`.
  - AJAX générique: `pro/web/ec/ec_ajax.php` (dispatch vers `ec_${m}_${p}_ajax.php`). Preuves: `/home/romain/Cotton/pro/web/ec/ec_ajax.php:22`, `/home/romain/Cotton/pro/web/ec/ec_ajax.php:29`.
- `fo` (front pro/public):
  - Page entrypoint: `pro/web/fo/fo.php` (lecture `t/m/p`, rendu via headers/footers + module). Preuves: `/home/romain/Cotton/pro/web/fo/fo.php:27`, `/home/romain/Cotton/pro/web/fo/fo.php:127`.
  - Script POST dispatcher: `pro/web/fo/do_script.php` (dispatch `fo_${m}_${p}.php` + redir). Preuves: `/home/romain/Cotton/pro/web/fo/do_script.php:26`, `/home/romain/Cotton/pro/web/fo/do_script.php:33`, `/home/romain/Cotton/pro/web/fo/do_script.php:40`.

### Routing URL -> modules (interne)
- Le routing principal est dans `pro/web/.htaccess` (format Nginx rewrite/location). Preuves: `/home/romain/Cotton/pro/web/.htaccess:69`, `/home/romain/Cotton/pro/web/.htaccess:88`, `/home/romain/Cotton/pro/web/.htaccess:168`, `/home/romain/Cotton/pro/web/.htaccess:176`, `/home/romain/Cotton/pro/web/.htaccess:185`.
- Flux session/démo actuels:
  - Choix démo: `/extranet/start/game/choose/demo` -> `ec.php?t=tunnel&m=start&p=step_1_game&flag_session_demo=1`. Preuve: `/home/romain/Cotton/pro/web/.htaccess:176`.
  - Choix session client: `/extranet/start/game/choose/{id_securite_offre_client}` -> `flag_session_demo=0`. Preuve: `/home/romain/Cotton/pro/web/.htaccess:179`.
  - Paramètres session: `/extranet/start/game/setting/{id_securite_session}`. Preuve: `/home/romain/Cotton/pro/web/.htaccess:182`.
  - Choix thématique: `/extranet/start/game/theme/{seo_slug_catalogue_rubrique}/{id_securite_session}`. Preuve: `/home/romain/Cotton/pro/web/.htaccess:185`.
  - Résumé: `/extranet/start/game/resume/{id_securite_session}`. Preuve: `/home/romain/Cotton/pro/web/.htaccess:188`.

### Endpoints AJAX + convention
- Convention centrale: `ec_ajax.php` lit `t/m/p` et inclut `modules/$t/$m/ec_${m}_${p}_ajax.php`. Preuve: `/home/romain/Cotton/pro/web/ec/ec_ajax.php:29`.
- Constat sur ce repo: aucun fichier `*_ajax.php` trouvé sous `pro/web/ec/modules` et `pro/web/fo`. Vérification locale: `find ... -name '*_ajax.php'` renvoie vide.
- Endpoints asynchrones actifs observés (sans `ec_ajax.php`): endpoints directs du form-manager séries via `fetch(...)`:
  - `/ec/modules/jeux/catalogue_series/catalogue_series_form_manager/ec_catalogue_series_form_manager_serie_create_or_update.php`
  - `/ec/modules/jeux/catalogue_series/catalogue_series_form_manager/ec_catalogue_series_form_manager_questions_get.php`
  - `/ec/modules/jeux/catalogue_series/catalogue_series_form_manager/ec_catalogue_series_form_manager_questions_image_save.php`
  - `/ec/modules/jeux/catalogue_series/catalogue_series_form_manager/ec_catalogue_series_form_manager_questions_create_or_update.php`
  - `/ec/modules/jeux/catalogue_series/catalogue_series_form_manager/ec_catalogue_series_form_manager_serie_delete.php`
  Preuves: `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_form.php:507`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_form.php:531`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_form.php:584`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_form.php:634`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_form.php:660`.
- Les appels jQuery vers `ec_ajax.php` existent mais sont commentés/désactivés. Preuves: `/home/romain/Cotton/pro/web/ec/includes/js/ec.js:63`, `/home/romain/Cotton/pro/web/ec/includes/js/ec.js:75`, `/home/romain/Cotton/pro/web/ec/includes/js/ec.js:108`.

## 2) Tenant/client et contrôles d'accès

### Détermination du tenant (client courant)
- Le tenant courant est tenu en session PHP:
  - `$_SESSION['id_client']`
  - `$_SESSION['id_client_contact']`
  - `$_SESSION['id_client_contact_type']`
  Preuves: `/home/romain/Cotton/pro/web/ec/modules/compte/authentification/ec_authentification_script.php:209`, `/home/romain/Cotton/pro/web/ec/modules/compte/authentification/ec_authentification_script.php:215`, `/home/romain/Cotton/pro/web/ec/modules/compte/authentification/ec_authentification_script.php:222`.
- La relation contact<->client est modélisée par `clients_contacts_to_clients(id_client_contact,id_client,id_type)`. Preuve table: `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:673`.

### Contrôles d'accès
- Garde d'entrée principale: si `$_SESSION['id_client_contact']` vide, redirection `signin`. Preuves: `/home/romain/Cotton/pro/web/ec/ec.php:17`, `/home/romain/Cotton/pro/web/ec/ec.php:1051`.
- Garde scripts POST: `do_script.php` autorise seulement certains modes non authentifiés, sinon exige session (`id_client_contact`) ou cookie gate BO. Preuves: `/home/romain/Cotton/pro/web/ec/do_script.php:29`, `/home/romain/Cotton/pro/web/ec/do_script.php:34`, `/home/romain/Cotton/pro/web/ec/do_script.php:35`.
- Restrictions rôle animateur (`id_client_contact_type==3`) sur certains modules. Preuves: `/home/romain/Cotton/pro/web/ec/ec.php:863`, `/home/romain/Cotton/pro/web/ec/ec.php:865`, `/home/romain/Cotton/pro/web/ec/ec.php:875`.
- Scoping données session côté agenda: requêtes sur `championnats_sessions` filtrées par `id_client=$_SESSION['id_client']`. Preuves: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php:43`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php:104`.

### Bootstrap environnement (MAJ après ajout `pro/web/config.php`)
- Détection d'environnement:
  - `localhost` => `local`
  - `pro.dev.cotton-quiz.com` => `dev`
  - sinon => `prod`
  Preuve: `/home/romain/Cotton/pro/web/config.php:6`.
- Variables de socle confirmées:
  - `site_url`, `site_root`, `public` (racines web),
  - `global_root`, `global_url`, `www_root`, `www_url`,
  - `games_url`, `quiz_game_url`, `bingo_game_url`, `blindtest_game_url`.
  Preuves: `/home/romain/Cotton/pro/web/config.php:15`, `/home/romain/Cotton/pro/web/config.php:22`, `/home/romain/Cotton/pro/web/config.php:31`, `/home/romain/Cotton/pro/web/config.php:75`, `/home/romain/Cotton/pro/web/config.php:82`, `/home/romain/Cotton/pro/web/config.php:103`, `/home/romain/Cotton/pro/web/config.php:110`, `/home/romain/Cotton/pro/web/config.php:118`, `/home/romain/Cotton/pro/web/config.php:128`, `/home/romain/Cotton/pro/web/config.php:161`, `/home/romain/Cotton/pro/web/config.php:168`, `/home/romain/Cotton/pro/web/config.php:176`.

## 3) Modèle actuel “thématiques / contenus”

### Cotton Quiz (séries thématiques)
- Source catalogue: table `questions_lots`. Preuve code: `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_list.php:118`.
- Colonnes utiles (thématique/auteur/état): `id_rubrique`, `id_univers`, `id_client_auteur`, `id_etat`, `nom`, `descriptif_court`, `date_ajout`, etc. Preuve table: `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:2546`.
- Rubriques de filtre: table `questions_lots_rubriques`. Preuve code: `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_list.php:52`; preuve table: `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:2582`.
- Filtres actuels implémentés: `home`, `new`, `my-series`, `all`, puis par rubrique (`seo_slug_catalogue_rubrique`). Preuves: `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_list.php:44`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_list.php:46`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_list.php:47`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_list.php:172`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_list.php:182`.

### Bingo/Blind (playlists thématiques)
- Source catalogue: table `jeux_bingo_musical_playlists`. Preuve code: `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlists_list.php:136`.
- Colonnes utiles: `id_rubrique`, `id_client_auteur`, `online`, `nom`, `descriptif_court`, `date_ajout`. Preuve table: `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:2162`.
- Rubriques de filtre: table `jeux_bingo_musical_playlists_rubriques`. Preuve code: `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlists_list.php:20`; preuve table: `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:2258`.
- Filtres actuels implémentés: `home`, `new`, `my-playlists`, `all`, puis par rubrique. Preuves: `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlists_list.php:12`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlists_list.php:14`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlists_list.php:15`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlists_list.php:181`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlists_list.php:191`.

## 4) Session depuis le pro: tables, endpoints, payload minimal

### Endpoint + dispatch
- Formulaires de programmation postent vers `/extranet/start/script` avec `frm_mode`. Preuves:
  - init session: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php:52`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php:54`
  - settings: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php:107`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php:108`
  - choix thématique: `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlists_list_bloc.php:74`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlists_list_bloc.php:75`
- Route `/extranet/start/script` -> `ec_start_script.php`. Preuve: `/home/romain/Cotton/pro/web/.htaccess:168`.

### Payload minimal constaté
- Initialisation session (`frm_mode=session_init`):
  - requis côté UI: `seo_slug_jeu`
  - optionnels: `id_securite_offre_client`, `id_securite_operation_evenement`
  Preuves: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php:53`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php:55`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php:56`.
- Paramétrage session (`frm_mode=session_setting`):
  - `id_securite_session`, `session_date`, `session_heure` (+ format/controle selon jeu)
  Preuves: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php:109`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php:124`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php:128`.
- Choix thématique (`frm_mode=session_theme`):
  - `id_securite_session`, `id_catalogue_produit`
  Preuves: `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_list_bloc.php:106`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_list_bloc.php:107`.

### Tables impactées à la création
- Session pivot: `championnats_sessions` (client, type jeu, id_produit, flag_session_demo, lot_ids, etc.). Preuve table: `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:405`.
- Lots de session: `championnats_sessions_lots` via `app_session_lots_ajouter(...)`. Preuves: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:412`; table `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:466`.

## 5) Flux prouvés (schémas)

### Flux A - Voir thématique -> Programmer session
1. URL entrée (démo): `GET /extranet/start/game/choose/demo`.
2. Carte jeu -> `POST /extranet/start/script` (`frm_mode=session_init`, `seo_slug_jeu`).
3. `ec_start_script.php` crée `championnats_sessions` via `app_session_ajouter(...)` avec `flag_session_demo=1` par défaut, puis redirige `.../start/game/theme/home/{id_securite_session}`.
4. Liste thématiques (séries/playlists) -> `POST /extranet/start/script` (`frm_mode=session_theme`, `id_catalogue_produit`).
5. `ec_start_script.php` renseigne `id_produit` (et `lot_ids` pour CQ v2) + `flag_configuration_complete=1`, puis redirige `.../start/game/resume/{id_securite_session}`.

Preuves clés:
- Route démo: `/home/romain/Cotton/pro/web/.htaccess:176`
- Form init: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php:54`
- Default démo + redir theme: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:21`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:24`
- Ajout session: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:108`
- Form choix thème: `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlists_list_bloc.php:75`
- MAJ session avec produit: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:281`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:319`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:395`
- Redir résumé: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:527`

### Flux B - Voir thématique -> Lancer démo
1. Après sélection thématique, écran résumé `GET /extranet/start/game/resume/{id_securite_session}` charge la carte session.
2. La carte calcule URL launcher (`app_session_get_link(...)` ou URL play classique) puis CTA `Ouvrir le jeu`.
3. Alternative “depuis fiche session”: bouton `Tester` -> `frm_mode=session_duplicate`, crée une copie `flag_session_demo=1`, `nb_joueurs_max=2`, date/heure now, puis redirige vers le résumé de la copie.

Preuves clés:
- Résumé inclut carte session: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_4_resume.php:20`
- URL launcher/classic: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:15`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:385`
- CTA lancer: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:492`
- “Tester” (duplication): `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php:576`
- Duplication en démo 2 joueurs: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:605`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:606`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:669`

## 6) Tableau “facts prouvés” (obligatoire)

| Sujet demandé | Fait prouvé | Preuves |
|---|---|---|
| Où stocker une thématique | Déjà stocké en base, séparé par jeu: `questions_lots` (quiz) et `jeux_bingo_musical_playlists` (playlist), avec auteur `id_client_auteur` pour “mes thématiques”. | table `questions_lots` (`id`, `id_client_auteur`, `id_rubrique`, `id_univers`, `id_etat`, `nom`, `date_ajout`): `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:2546`; table `jeux_bingo_musical_playlists` (`id`, `id_rubrique`, `id_client_auteur`, `online`, `nom`, `date_ajout`): `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:2162`; filtres “my-*”: `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_list.php:172`, `/home/romain/Cotton/pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlists_list.php:181` |
| Comment relier thématique ↔ session | Le pivot est `championnats_sessions`: `id_produit` (produit sélectionné) et `lot_ids` (CQ v2 multi-lots). `session_theme` met à jour ces colonnes. | table `championnats_sessions` colonnes `id_produit`, `lot_ids`: `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:422`, `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:457`; MAJ via script: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:281`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:319`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:395` |
| Comment calculer les métas d’usage (nb utilisations / dernière utilisation) | Aucun champ “usage_count/last_used_at” natif dans tables catalogues (`questions_lots`, `jeux_bingo_musical_playlists`). Calcul faisable par agrégation des sessions (`championnats_sessions`) + jeu: `id_produit` (playlists/BT/CQv1) et parsing `lot_ids` pour CQv2. | absence dans structures: `questions_lots` `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:2546`, `jeux_bingo_musical_playlists` `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:2162`; présence de `date` côté sessions: `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:412`; lien session->produit: `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:422`, `/home/romain/Cotton/documentation/canon/data/schema/DDL.sql:457` |
| Comment lancer une démo (paramètres/URL/fichiers) | Entrée standard: `GET /extranet/start/game/choose/demo` -> création session démo (`flag_session_demo=1`) par `frm_mode=session_init`, puis choix thème et CTA `Ouvrir le jeu`. Alternative “tester depuis fiche session”: `frm_mode=session_duplicate` -> copie démo 2 joueurs. Redirection externe jeux observée via `ec_sign.php` (`utm_source=espace-pro`) vers URLs quiz/bingo. | route: `/home/romain/Cotton/pro/web/.htaccess:176`; init démo: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:21`; redir thème: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:24`; CTA launcher: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:492`; duplication test: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php:576`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:605`; redirections externes: quiz `/home/romain/Cotton/pro/web/ec/ec_sign.php:124`, bingo `/home/romain/Cotton/pro/web/ec/ec_sign.php:213`, avec paramètres auth `/home/romain/Cotton/pro/web/ec/ec_sign.php:45`, `/home/romain/Cotton/pro/web/ec/ec_sign.php:47`, `/home/romain/Cotton/pro/web/ec/ec_sign.php:133`, `/home/romain/Cotton/pro/web/ec/ec_sign.php:135` |

## 7) Inconnues restantes

1. La fonction `app_session_get_link(...)` est appelée partout pour construire les URLs de lancement, mais son implémentation est dans `global_root` (hors repo), donc format final exact des URLs launcher par jeu non prouvé ici. Appels: `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:385`, `/home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php:539`.
2. Le dispatch `ec_ajax.php` existe, mais aucun `*_ajax.php` actif local n’a été trouvé sous `ec/modules`; les flux asynchrones actifs passent par endpoints directs form-manager.

## 8) Options d’implémentation (basées uniquement sur preuves)

### Option MVP
- Réutiliser les tables existantes (`questions_lots` / `jeux_bingo_musical_playlists`) comme “content library” avec segmentation:
  - Cotton certifiées: `id_client_auteur=0` + état/publication (`id_etat=2` pour quiz, `online=1` pour playlists).
  - Mes thématiques: `id_client_auteur=$_SESSION['id_client']`.
  - Communauté: thématiques client non propriétaire (règle explicite à définir, ex. `id_client_auteur>0` et `id_client_auteur!=current`).
- Lier au lancement de session sans nouveau pivot: conserver `session_theme` -> `championnats_sessions.id_produit` / `lot_ids`.
- Métas usage calculées à la volée via agrégation sur `championnats_sessions` (`COUNT`, `MAX(date)`), sans migration.
- Avantage: zéro refonte du tunnel existant (`/extranet/start/...`).
- Limite: CQ v2 nécessite parser `lot_ids` pour usage multi-lots; pas de métrique matérialisée.

### Option Clean
- Introduire une couche unifiée “bibliothèque de contenus” (table canonique inter-jeux + table de liaison vers `questions_lots`/`playlists`), puis un mapping explicite session<->contenus (1..n) au lieu de `id_produit`/`lot_ids` ambigu.
- Ajouter des colonnes matérialisées de stats d’usage (ou table d’analytics dérivée) pour `usage_count`, `last_used_at`, recalculées par job.
- Conserver compatibilité avec tunnel actuel via adaptateur dans `session_theme` puis migration progressive des lectures (`ec_start_sessions_*`).
- Avantage: modèle propre multi-jeux, filtres thème/sous-thème/rubrique extensibles, métas fiables.
- Limite: chantier DB + compat ascendante plus long.
