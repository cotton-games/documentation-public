# Delegation write path (id_client_delegation) — 2026-03-06

## Verdict
- Écriture métier dédiée `id_client_delegation` dans `global`: **non trouvée**.
- Écriture existante trouvée: **CRUD générique BO** sur `ecommerce_offres_to_clients`.

## Preuves (file:line)

### A) Recherches SQL explicites
- Aucun `UPDATE ecommerce_offres_to_clients SET id_client_delegation=...` trouvé.
- Aucun `INSERT ... id_client_delegation ...` explicite trouvé dans les fonctions métier `global`.

### B) Chemin existant qui peut écrire `id_client_delegation` (indirect, générique BO)
1. Le module BO `offres_clients` expose le champ:
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:39`
  - `bdd_champ_nom => 'id_client_delegation'`
- Le module autorise ajout/modification:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:299`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:300`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:301`

2. Le routage script BO utilise le moteur master:
- `www/web/bo/do_script.php:87` (fallback `master/bo_master_<p>.php`)
- `www/web/bo/master/bo_master_script.php:15` (mode `ajouter` -> `module_ajouter`)
- `www/web/bo/master/bo_master_script.php:20` (mode `modifier` -> `module_modifier`)

3. Le moteur générique construit l’INSERT/UPDATE à partir des champs module:
- `global/web/lib/core/lib_core_module_functions.php:504` (`module_ajouter`)
- `global/web/lib/core/lib_core_module_functions.php:515` (lit les champs postés)
- `global/web/lib/core/lib_core_module_functions.php:632` (`module_modifier`)
- `global/web/lib/core/lib_core_module_functions.php:644` (lit les champs postés)
- `global/web/lib/core/lib_core_module_functions.php:736` (SQL `UPDATE <table> SET ...`)

### C) Fonctions métier `global` autour des offres (lecture + ON/OFF) sans écriture delegation
- Lecture delegation:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php:947`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php:1024`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php:1053`
- Ecritures offre connues mais sans `id_client_delegation`:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php:752`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php:772`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php:850`

## Conclusion opérationnelle
- Le write path actuel de `id_client_delegation` repose sur un formulaire BO générique (table-driven), pas sur une action métier explicite "déléguer une offre".
- Cela explique l’absence de point de hook dédié (audit/logique cascade).

## Minimal path proposé (Lot 2) si on veut un write path métier explicite

### UI BO minimale
- Ajouter un bouton/action sur la fiche offre client BO:
  - `?a=www&t=ecommerce&m=offres_clients&p=delegate&id=<id_offre_client>`
- Formulaire minimal:
  - `id_client_delegation` (select client cible),
  - option `mode` (`set` / `clear`).

### Fonction serveur minimale (`global`)
- Nouvelle fonction dédiée, ex:
  - `app_ecommerce_offre_client_set_delegation($id_offre_client, $id_client_delegation, $id_entite_utilisateur)`
- SQL attendu:
  - `UPDATE ecommerce_offres_to_clients SET id_client_delegation=?, date_maj=NOW(), id_entite_utilisateur=? WHERE id=?`
- Garde-fous:
  - refuser `id_client_delegation == id_client` (auto-délégation),
  - vérifier existence client cible,
  - journaliser `old_value -> new_value`.
