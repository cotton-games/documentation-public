# Implémentation Étape 2 — BO contrat cadre réseau (2026-03-06)

## Références de cadrage
- START (navigation + preuve):
  - https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md
  - sections `Parcours (sans supposition)` et `Règle preuve d’abord (obligatoire)`
- Plan migration:
  - https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/notes/plan_migration_reseau_branding_contenu.md
  - sections `Contrat “contrat cadre réseau”`, `Règles complémentaires du contrat cadre réseau`, `Étape 2 — BO : support du contrat cadre réseau`, `Étape 2A — PRO : pilotage des activations affiliés`
- Audit Étape 2:
  - `notes/audit-etape2-bo-contrat-cadre-reseau-2026-03-06.md`

## Périmètre livré
- Oui:
  - persistance dédiée minimale contrat réseau + activation affilié,
  - helpers globaux lecture/écriture/trace,
  - branchement resolver Étape 1 sur la nouvelle surcouche avec fallback,
  - écran BO dédié de pilotage siège,
  - entrée BO depuis fiche client siège,
  - garde-fou minimal contre écriture brute générique de `id_client_delegation`.
- Non:
  - Étape 2A (pilotage PRO affilié),
  - nouveau tunnel Stripe,
  - création produit Stripe.

## Modifications code

### 1) Persistance SQL (2 structures)
- `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
  - table `ecommerce_reseau_contrats`:
    - `id_offre_client_contrat` (support commercial `ecommerce_offres_to_clients`),
    - `id_client_siege`,
    - capacités: `max_affilies_activables`, `max_joueurs_par_affilie`,
    - cibles: `id_offre_delegation_cible`, `id_erp_jauge_cible`,
    - audit: `id_entite_utilisateur`, `date_ajout`, `date_maj`,
    - contraintes: `UNIQUE(id_offre_client_contrat)`, `UNIQUE(id_client_siege)`.
  - table `ecommerce_reseau_contrats_affilies`:
    - `id_contrat_reseau`, `id_client_affilie`,
    - état `activation_state` (`active|inactive`),
    - `date_activation`, `date_desactivation`,
    - `id_offre_client_deleguee` (résolution délégation),
    - audit: `id_entite_utilisateur`, `note`, `date_ajout`, `date_maj`,
    - contraintes: `UNIQUE(id_contrat_reseau,id_client_affilie)` + index ciblés.

### 2) Helpers globaux ecommerce
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - ajout helpers réseau:
    - disponibilité tables: `app_ecommerce_reseau_tables_available()`
    - contrat: lecture par offre/siège + upsert + capacités
    - activations: lecture/count/liste + write + `set_active`/`set_inactive`
    - traçabilité: `app_ecommerce_reseau_log_action(...)` (clients_logs)
  - resolver Étape 1 (`app_ecommerce_offre_effective_get_context`) étendu:
    - consommation prioritaire de la surcouche dédiée si contrat réseau existe,
    - fallback legacy conservé si surcouche absente,
    - maintien des règles de priorité d’accès:
      - offre propre > réseau actif > inactif,
      - `pending_payment` bloque l’accès,
      - délégation résolue requise pour accès réseau effectif.

### 3) BO dédié minimal (siège)
- Nouveau module:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_module_parametres.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- Capacités livrées:
  - sélection de la ligne commerciale support,
  - édition des capacités réseau,
  - sélection jauge/offre cible,
  - listing affiliés du siège,
  - activation/désactivation affilié via write path dédié,
  - affichage minimal de l’état d’activation et de la délégation résolue.

### 4) Entrée BO fiche client
- `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - ajout CTA `Gestion contrat réseau / délégation`
  - visible uniquement si `flag_client_reseau_siege=1`.

### 5) Sécurisation CRUD générique
- `global/web/lib/core/lib_core_module_functions.php`
  - dans `module_ajouter` et `module_modifier`:
    - blocage par défaut de l’écriture brute de `ecommerce_offres_to_clients.id_client_delegation`,
    - bypass possible uniquement via flag explicite `allow_delegation_raw_write=1`.
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`
  - libellé champ délégation clarifié (`legacy - pilotage réseau via module dédié`).

## Règles métier réellement implémentées
- `ecommerce_offres_to_clients` reste support commercial/Stripe du contrat siège.
- Affiliation canonique (`clients.id_client_reseau`) reste séparée de l’activation réseau.
- Activation affilié explicitement portée dans la table dédiée (auditable).
- `pending_payment` contrat réseau bloque l’accès effectif.
- L’accès réseau effectif exige une délégation résolue active.
- Fallback legacy maintenu pendant transition si la persistance dédiée n’existe pas.

## Limites / TODO Étape 2A (non inclus)
- Aucun pilotage PRO affilié implémenté dans ce lot.
- Pas d’UX PRO d’activation/désactivation siège sur `/extranet/account/network`.
- Pas de création automatique de ligne offre déléguée au moment de l’activation BO.
- Le mode `allow_delegation_raw_write=1` reste réservé aux usages legacy contrôlés.
