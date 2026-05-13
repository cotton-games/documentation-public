# Offer lifecycle hooks (2026-03-06)

## Scope
- Repos audités: `www` + `global` (focus).
- Table cible: `ecommerce_offres_to_clients`.
- Objectif: localiser les points OFF (inactivation), les jobs cron/batch associés, et proposer le meilleur hook pour la cascade délégation Lot 3B.

## Offer lifecycle hooks

| Cause OFF | Entrypoint (file:line) | DB update exact (query) | Best hook for delegation cascade 3B |
|---|---|---|---|
| Impayé > 30 jours (annulation) | `www/web/bo/cron_routine_bdd_maj.php:36` + `:47` | `UPDATE ecommerce_offres_to_clients SET id_etat=10 WHERE id=<id_offre_client>` | Juste après `query($sql_upd_6)` dans le cron (`:49`) |
| Expiration PAK (`id_offre_type=1`) | `www/web/bo/cron_routine_bdd_maj.php:62` + `:73` | `UPDATE ecommerce_offres_to_clients SET id_etat=4 WHERE id=<id_offre_client>` | Juste après `query($sql_upd_7)` (`:75`) |
| Expiration ABN ONE SHOT (`id_offre=2`) | `www/web/bo/cron_routine_bdd_maj.php:89` + `:100` | `UPDATE ecommerce_offres_to_clients SET id_etat=4 WHERE id=<id_offre_client>` | Juste après `query($sql_upd_8)` (`:102`) |
| Expiration ABN sans engagement (`id_offre_type=2 AND flag_engagement=0`) | `www/web/bo/cron_routine_bdd_maj.php:127` + `:140` | `UPDATE ecommerce_offres_to_clients SET id_etat=4 WHERE id=<id_offre_client>` | Juste après `query($sql_upd_8)` (`:142`) |
| Résiliation ABN sans engagement (pré-OFF: stop à fin de période) | `global/web/app/modules/ecommerce/app_ecommerce_functions.php:1254` + `:1266` | `UPDATE ecommerce_offres_to_clients SET date_fin='<fin_periode>' WHERE id=<id_offre_client>` | Dans `app_ecommerce_offre_client_abonnement_sans_engagement_resilier` après l’UPDATE (`:1267`) pour préparer la cascade différée |
| Changement manuel BO (état éditable) | `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:15` + `:299` + `www/web/bo/master/bo_master_script.php:19` + `global/web/lib/core/lib_core_module_functions.php:736` | `UPDATE ecommerce_offres_to_clients SET ... id_etat='<valeur BO>' ..., date_maj=NOW() WHERE id=<id>` (SQL générique de `module_modifier`) | Dans `module_modifier` (`global/.../lib_core_module_functions.php:736`) avec garde `if ($bdd_table==='ecommerce_offres_to_clients')` |
| Suppression manuelle BO d’une offre | `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:302` + `www/web/bo/master/bo_master_script.php:43` + `global/web/lib/core/lib_core_module_functions.php:833` | `DELETE FROM ecommerce_offres_to_clients WHERE id=<id>` | Dans `module_supprimer` (`:833`) avec garde `bdd_table` |
| Suppression client BO (effacement en cascade) | `www/web/bo/www/modules/entites/clients/bo_clients_functions.php:53` | `DELETE FROM ecommerce_offres_to_clients WHERE id_client=<id_client>` | Dans `bo_client_supprimer_specifique` juste après la requête (`:55`) |

## ON hooks observés (activation)

| Cause ON | Entrypoint (file:line) | DB update |
|---|---|---|
| Validation d’offre (commande validée) | `global/web/app/modules/ecommerce/app_ecommerce_functions.php:835` + `:850` | `UPDATE ecommerce_offres_to_clients SET id_etat=3, online=1, ... WHERE id=<id_offre_client> AND id_client=<id_client>` |
| Offre affiliée événementielle | `global/web/app/modules/operations/evenements/app_evenements_functions.php:238` + `:260` | `UPDATE ecommerce_offres_to_clients SET id_etat=3, id_operation_evenement=..., date_debut=..., date_fin=..., ... WHERE id=<id_offre_client>` |
| Activation offre remise 100% (PAK) | `global/web/app/modules/ecommerce/app_ecommerce_functions.php:546` + `:561` | `UPDATE ecommerce_offres_to_clients SET id_etat=3, date_fin=..., flag_offert=1, prix_ht=0 WHERE id=<id_offre_client>` |

## Cron / batch / billing handling (focus www+global)
- Job principal d’inactivation: `www/web/bo/cron_routine_bdd_maj.php` (sections 1 à 4, lignes `24..155`).
- Aucun webhook paiement Stripe dans `www`/`global` pour OFF immédiat trouvé dans ce périmètre; l’inactivation est principalement pilotée par ce cron (ou par action BO manuelle).
- La "suspension" explicite dédiée (statut distinct) n’a pas été trouvée comme cause OFF implémentée dans `www`/`global`.
