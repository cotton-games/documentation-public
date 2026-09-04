# Content model map — playlists/séries + scopes (2026-03-06)

## 1) Modèles de données trouvés (PRO + GLOBAL)

### A. Playlists (Blind Test / Bingo)
- **Table catalogue source**: `jeux_bingo_musical_playlists`
  - sélection/filtrage legacy catalogue: `pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlists_list.php:136-138`
  - source table côté bibliothèque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php:302-307`
  - création/édition source (métadonnées): `pro/web/ec/modules/jeux/bibliotheque/sources/playlists.php:29-31`, `:106`, `:176`
- **Table client runtime/session**: `jeux_bingo_musical_playlists_clients`
  - création playlist client depuis la source catalogue: `global/web/app/modules/jeux/bingo_musical/app_bingo_musical_functions.php:178`, `:266`, `:281`

### B. Séries Quiz
- **Table catalogue source**: `questions_lots`
  - sélection/filtrage legacy catalogue: `pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_list.php:118-120`
  - source table côté bibliothèque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php:302-307`
  - création/édition source (métadonnées): `pro/web/ec/modules/jeux/bibliotheque/sources/quiz_series.php:57-59`, `:96`, `:167`
- **Usage session quiz**:
  - remplacement de lot dans une session quiz client: `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php:1461`, `:1494`

### C. Couche communauté/publication
- **Table**: `community_items`
  - schéma + index + lien session: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php:838-863`, `:872-873`
  - sert de publication/modération entre source catalogue et vues `cotton/community`.

## 2) Scopes/filtres existants (`cotton/community/mine`)

### A. Où c’est codé
- normalisation du type depuis query string: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php:17-27`
- resolver liste principal: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php:3277`
- mapping SQL du scope:
  - `cotton => id_client_auteur=0`
  - `community => id_client_auteur>0 et != client courant`
  - `mine => id_client_auteur=client courant`
  - preuve: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php:2558-2573`
- visibilité communauté (consentement + publication): `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php:2580-2627`
- files admin `community`:
  - unpublished: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php:2632-2655`
  - private: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php:2660-2677`

### B. Legacy catalogue/tunnel (toujours présent)
- playlists legacy: `pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlists_list.php:140-199`
- séries legacy: `pro/web/ec/modules/jeux/catalogue_series/ec_catalogue_series_list.php:122-191`
- filtre “mes contenus” legacy via `id_client_auteur`: 
  - playlists `.../ec_catalogue_playlists_list.php:184`
  - séries `.../ec_catalogue_series_list.php:175`

## 3) Notion de partage privé réutilisable

### Existant réutilisable confirmé
- consentement explicite de partage communauté sur les tables source:
  - playlists: `flag_share_community` (write): `pro/web/ec/modules/jeux/bibliotheque/sources/playlists.php:152-173`
  - séries: `flag_share_community` (write): `pro/web/ec/modules/jeux/bibliotheque/sources/quiz_series.php:143-164`
- file d’attente / privé déjà modélisée côté admin via `community_state=unpublished|private`:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php:63-66`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php:3338-3347`, `:3561-3570`

### Non trouvé
- aucune notion explicite de scope `network` (siège/affiliés) dans le modèle bibliothèque actuel.
- aucun filtre `cotton/community/mine` détecté dans `global` (scan regex sans match):
  - `rg "community_items|flag_share_community|cotton_state|community_state|perso_state|search_scope|type==='community'|type==='cotton'|type==='mine'" /home/romain/Cotton/global/web`.

## 4) Endpoints/pages PRO (catalogue + tunnel/prog)

### Bibliothèque (nouveau flux)
- liste: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- vue détail: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- actions backend: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- éditeurs: 
  - `pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_create.php`
  - `pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_edit.php`
  - `pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_content.php`
  - `pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_save.php`
  - `pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_content_ajax.php`

### Tunnel/prog
- entrée legacy choix thème (catalogues legacy): `pro/web/ec/modules/tunnel/start/ec_start_step_3_theme.php:23-37`
- validation serveur du choix de contenu: `pro/web/ec/modules/tunnel/start/ec_start_script.php:12-56`, `:87-118`
- redirection agenda vers bibliothèque: `pro/web/ec/modules/tunnel/start/ec_start_script.php:903-904`, `:933`
- changement de thème depuis session view vers bibliothèque: `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php:30-33`

### WWW (optionnel)
- pas de BO de gestion “catalogue pro” trouvé dans le périmètre scanné.
- présence FO/API marketing utilisant playlists/séries (ex: timeline/API), hors scope permissions PRO:
  - `www/web/fo/modules/specifique/timeline/fr/fo_timeline_list.php:39-48`
  - `www/web/api/ai_studio_cotton_workflow_writing_social_media_posts_general_mix_data_input.php:201-206`

## 5) Recommandation d’évolution `network`

### Approche A — Ajouter un champ `scope` sur les tables source (`questions_lots`, `jeux_bingo_musical_playlists`)
- Avantage: simple en lecture.
- Limites dans ce codebase:
  - ne couvre pas bien le cas “un contenu partagé à plusieurs cibles” (réseau + éventuellement autres scopes).
  - mélange l’état de publication et la politique de partage dans les tables source déjà chargées en colonnes métier.

### Approche B — Table de partage dédiée (recommandée)
- Recommandation: **Approche B**.
- Justification factuelle:
  - le système actuel a déjà une table de projection/partage (`community_items`) séparée des tables source (`questions_lots` / `jeux_bingo_musical_playlists`), avec historique/statut/origine (`pro/.../ec_bibliotheque_lib.php:838-863`).
  - ajouter `network` s’aligne mieux sur ce pattern (projection/visibilité séparée) que sur un champ unique de scope.
- Conséquence: garder les tables source centrées contenu, et externaliser la visibilité réseau dans une table `shares` (ou extension stricte de la couche projection actuelle).

## 6) Fichiers PRO/GLOBAL à modifier pour ajouter `network` (si Approche B)

### PRO (bibliothèque + tunnel)
1. `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
2. `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
3. `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
4. `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
5. `pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_edit.php`
6. `pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_save.php`
7. `pro/web/ec/modules/jeux/bibliotheque/sources/playlists.php`
8. `pro/web/ec/modules/jeux/bibliotheque/sources/quiz_series.php`
9. `pro/web/ec/modules/tunnel/start/ec_start_script.php`
10. `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

### GLOBAL (relations réseau + contrat de lecture partages)
1. `global/web/app/modules/entites/clients/app_clients_functions.php` (source lien siège/affiliés)
2. `global/web/app/modules/jeux/bingo_musical/app_bingo_musical_functions.php` (consommation playlists en session)
3. `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php` (consommation lots en session)
4. `global/web/app/modules/jeux/sessions/app_sessions_functions.php` (garde-fous lancement/session)

> Note: la couche “share network” n’existe pas encore dans `global`; il faudra créer un module/table dédiée et brancher PRO sur cette API/DAO plutôt que du SQL direct dispersé.
