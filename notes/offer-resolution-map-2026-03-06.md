# Offer Resolution Map (2026-03-06)

## Scope
- Repos audités: `global`, `pro`, `www`, `games`.
- Objectif: localiser la source de vérité "offre active client", callsites, règles de priorité/filtrage, délégation.

## Resolvers (source of truth)

1. `app_ecommerce_offres_client_get_count($id_client, $bdd_filtre, $bdd_ordre, $bdd_limite)`
- Définition effective: `global/web/app/modules/ecommerce/app_ecommerce_functions.php:1011`
- Table: `ecommerce_offres_to_clients`
- Logique:
  - query primaire: `WHERE id_client = <id_client>` + filtres appelant.
  - fallback délégation uniquement si résultat primaire `= 0`: `WHERE id_client_delegation = <id_client>`.
  - retourne un `COUNT`.

2. `app_ecommerce_offres_client_get_liste($id_client, $bdd_filtre, $bdd_ordre, $bdd_limite)`
- Définition effective: `global/web/app/modules/ecommerce/app_ecommerce_functions.php:1037`
- Table: `ecommerce_offres_to_clients` (+ `ecommerce_offres` join)
- Logique:
  - query primaire: `WHERE eotc.id_client = <id_client>`.
  - fallback délégation uniquement si liste primaire vide: `WHERE eotc.id_client_delegation = <id_client>`.
  - retourne `id`, `id_client_delegation`, `id_securite`, `id_offre_type`.

3. `app_session_launch_guard_get($id_championnat_session)` (source de vérité lancement session)
- Définition: `global/web/app/modules/jeux/sessions/app_sessions_functions.php:803`
- Utilise `app_ecommerce_offres_client_get_count(..., "id_etat=3")` (`:863`) + contrôle état de l’offre liée à la session via `app_ecommerce_offre_client_get_detail(...)` (`:859`, `:864`).
- Bloque lancement si:
  - aucune offre active client (`count <= 0`),
  - et offre liée à la session non active.

4. Wrapper local `pro` (résolution d’un `id_securite` d’offre active)
- `clib_active_offer_security_id_get($id_client)`:
  - définition: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php:3659`
  - filtre: `id_etat=3 AND ((id_client_delegation=0) OR (id_client_delegation=<id_client>))` (`:3663`)
  - ordre: `id_client_delegation ASC` (`:3664`)
  - limite: `1` (`:3665`)
  - appelle `app_ecommerce_offres_client_get_liste(...)` (`:3667`).

## Callsites par resolver

### A. `app_ecommerce_offres_client_get_count(...)`
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php:863`
- `pro/web/ec/ec.php:64`
- `pro/web/ec/ec.php:68`
- `pro/web/ec/modules/tunnel/start/ec_start_script.php:1663`
- `games/web/organizer_canvas.php:168` (fallback local si guard indisponible)
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php:2286` (dans fonction commentée/legacy, non active en runtime)

### B. `app_ecommerce_offres_client_get_liste(...)`
- `pro/web/ec/ec.php:107`
- `pro/web/ec/ec.php:1497`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php:3667`
- `pro/web/ec/modules/tunnel/start/ec_start_step_0_offres_client.php:8`
- `pro/web/ec/modules/communication/home/ec_home_index.php:167`
- `pro/web/ec/modules/communication/home/ec_home_index.php:570`
- `pro/web/ec/modules/communication/home/ec_home_index.php:972`
- `pro/web/ec/modules/widget/ec_widget_ecommerce_offre_client_bloc.php:191`
- `pro/web/ec/modules/widget/ec_widget_jeux_sessions_form_mode_calendrier_V3.php:6`
- `pro/web/ec/modules/widget/ec_widget_jeux_sessions_form_mode_calendrier_V3.php:40`
- `pro/web/ec/modules/widget/ec_widget_jeux_sessions_form_mode_calendrier_V3.php:409`
- `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php:241`
- `pro/web/ec/modules/compte/offres/ec_offres_include_list.php:7`
- `pro/web/ec/modules/compte/offres/ec_offres_view.php:48`
- `pro/web/ec/modules/compte/client/ec_client_script.php:630`
- `pro/web/ec/modules/compte/client/ec_client_list.php:61`
- `www/web/bo/www/modules/entites/clients/bo_clients_list.php:61`
- `www/web/bo/www/modules/syntheses/resumes/bo_resumes_list.php:1315`

### C. `app_session_launch_guard_get(...)`
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_play_classic.php:14`
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:294`
- `games/web/organizer_canvas.php:218`

### D. `clib_active_offer_security_id_get(...)`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php:1131`

## Current rules (priority + filters + dates + délégation)

1. Priorité de résolution (compte/liste)
- Priorité 1: offres portées par le client (`id_client`).
- Priorité 2 (fallback): offres déléguées (`id_client_delegation`) uniquement si aucun résultat en priorité 1.
- Conséquence: pas de fusion des deux sources; une présence en priorité 1 masque la délégation.

2. Filtre "offre active"
- Convention dominante: `id_etat=3`.
- Implémentée dans la majorité des callsites (`pro/ec.php`, `global/app_session_launch_guard_get`, `games` fallback).

3. Dates
- Les fonctions resolver n’appliquent pas de filtre date natif (`date_debut`/`date_fin` non utilisés dans `get_count/get_liste`).
- La temporalité est surtout externalisée:
  - gestion d’état par cron BO (ex. bascule `id_etat` selon `date_fin`): `www/web/bo/cron_routine_bdd_maj.php:62`, `:73`, `:89`, `:100`.

4. Délégation (état actuel)
- Support structurel présent:
  - colonne `ecommerce_offres_to_clients.id_client_delegation`.
  - fallback délégation dans resolvers globaux (`get_count/get_liste`).
- Dans `pro`, certains écrans ajoutent un filtrage explicite de délégation:
  - `id_client_delegation=0` ou `id_client_delegation=<session id_client>` (`pro/web/ec/ec.php:111`, `pro/web/ec/modules/tunnel/start/ec_start_step_0_offres_client.php:47`).
- Dans le guard lancement session (`app_session_launch_guard_get`), la délégation est indirectement prise via `get_count` fallback; pas de filtre additionnel dédié.

## Lot 1 TODO (audit)
- Normaliser un resolver unique "active offer" (éviter divergences `get_count` vs `get_liste` + filtres locaux).
- Clarifier la règle délégation:
  - fallback-only (actuel) vs fusion explicite,
  - priorité contractualisée documentée.
- Ajouter un filtre temporel explicite côté resolver si requis métier (au lieu de dépendre uniquement de `id_etat`).
- Centraliser la sélection d’`id_securite` active (éviter wrappers locaux divergents).
