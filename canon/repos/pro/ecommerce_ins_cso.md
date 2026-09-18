# E-commerce EC — INS/CSO (source de vérité + surfaces UX)

Date: 2026-02-23

## Source of truth INS/CSO
- Colonne client:
  - `clients.id_pipeline_etat`
- Référentiel:
  - `referentiels_clients_pipeline_etats` (`id`, `nom`)
- Résolution côté code:
  - `pro/web/ec/ec.php:60`
    - `$client_pipeline_etat_nom = client_pipeline_etat_get_nom($client_detail['id_pipeline_etat']);`
  - `global/web/app/modules/entites/clients/app_clients_functions.php:676`
    - `client_pipeline_etat_get_nom(...)`
    - SQL: `SELECT nom FROM referentiels_clients_pipeline_etats WHERE id = ...`
  - `global/web/app/modules/entites/clients/app_clients_functions.php:664`
    - `client_pipeline_etat_get_id(...)`
    - SQL: `SELECT id FROM referentiels_clients_pipeline_etats WHERE nom = ...`

Conclusion: INS/CSO n'est pas un champ texte direct dans `clients`; c'est la valeur du référentiel pipeline pointée par `id_pipeline_etat`.

## Comment le code sait qu'un client est CHR
- Segmentation via `clients.id_typologie`.
- Dans l'EC, le parcours CHR/lieu public est traité explicitement pour les typologies `1` et `8` (ex: `pro/web/ec/ec.php:75`, `pro/web/ec/modules/widget/ec_widget_ecommerce_cta.php:2`).
- Le regroupement CHR historique est aussi documenté dans `global/web/app/modules/entites/clients/app_clients_functions.php:95` (typologies CHR: 1/4/5/6).

## Surfaces UX INS/CSO
- Home widget EC (no-offer):
  - `pro/web/ec/modules/communication/home/ec_home_index.php`
  - widgets:
    - essai: `pro/web/ec/modules/widget/ec_widget_ecommerce_abonnement.php`
    - réactivation CSO: `pro/web/ec/modules/widget/ec_widget_ecommerce_abonnement_cso.php`
- Page offers (ABN CTA):
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - règles UX CHR:
    - INS: `Essayer gratuitement`
    - CSO: `S'abonner` + note essai réservé aux nouveaux clients
