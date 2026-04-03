# Audit Étape 2 — BO contrat cadre réseau (2026-03-06)

## Sources de preuve
- START (règles preuve/navigation):
  - https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md
  - sections `Parcours (sans supposition)` et `Règle preuve d’abord (obligatoire)`
- Plan migration:
  - https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/notes/plan_migration_reseau_branding_contenu.md
  - sections `Contrat “contrat cadre réseau”`, `Règles complémentaires du contrat cadre réseau`, `Étape 2 — BO : support du contrat cadre réseau`, `Étape 2A — PRO : pilotage des activations affiliés`
- Discipline docs/routing:
  - https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md
  - section `Update triggers (mapping)`

## Périmètre technique audité
- BO:
  - `www/web/bo/www/modules/entites/clients/bo_module_parametres.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`
  - `www/web/bo/master/bo_master_script.php`
  - `www/web/bo/do_script.php`
  - `www/web/bo/cron_routine_bdd_maj.php`
- Global:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/lib/core/lib_core_module_functions.php`
- PRO (points de lecture métier + Stripe):
  - `pro/web/ec/ec.php`
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_step_0_offres_client.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
- Schéma:
  - `documentation/dev_cotton_global_0.sql`

## Mini-cartographie du modèle actuel
- Affiliation canonique:
  - `clients.id_client_reseau`.
- Siège réseau:
  - `clients.flag_client_reseau_siege`.
- Support commercial d’offre:
  - `ecommerce_offres_to_clients` (`id_client`, `id_offre`, `id_etat`, `date_debut`, `date_fin`, `id_erp_jauge`, `asset_stripe_productId`).
- Délégation affilié existante:
  - même table, via `id_client_delegation`.
- BO actuel:
  - module table-driven CRUD `offres_clients` expose déjà `id_etat`, `id_client_delegation`, `id_erp_jauge`, `asset_stripe_productId`.
- Étape 1 déjà en place:
  - resolver global `app_ecommerce_offre_effective_get_context(...)` qui distingue `own_offer | network | inactive` et mappe `id_etat=2` -> `pending_payment`.

## Réponses question par question

### 1) Support métier le plus crédible pour le contrat cadre réseau
- **Réponse**: une ligne `ecommerce_offres_to_clients` dédiée au siège est le support commercial le plus crédible (cycle offre/Stripe/état/validité déjà natifs).
- **Mais**: pas suffisant seul pour porter les capacités réseau et l’activation explicite affilié de manière auditable.
- **Conclusion**: base = `ecommerce_offres_to_clients` + surcouche dédiée minimale pour capacités/activations.

### 2) Gestion BO actuelle (rattachement offre, statuts, validité, reprises/arrêts/résiliations, Stripe)
- Rattachement offre à client:
  - CRUD générique BO via `offres_clients` (`bo_master_script.php` -> `module_ajouter/module_modifier`).
- Statuts offre:
  - champ `id_etat` dans `ecommerce_offres_to_clients`, exposé BO via `referentiels_offres_clients_etats`.
- Validité:
  - `date_debut/date_fin` + transitions CRON (`id_etat=4/10` selon cas).
- Résiliation/reprise:
  - Stripe `customer.subscription.updated` met `date_fin` (résiliation) ou réactive (`date_fin='0000-00-00', id_etat=3`).
  - Legacy non-Stripe: fonctions `app_ecommerce_offre_client_abonnement_sans_engagement_resilier/reactiver`.
- Lecture Stripe:
  - `asset_stripe_productId` au niveau offre client, `asset_stripe_customerId` côté client, portail Stripe via `ec_offres_include_detail.php`.

### 3) Modèle actuel vs besoins (offre siège Mon offre, capacités, délégation pilotable, `pending_payment`)
- Offre dédiée siège visible `Mon offre`:
  - **Oui** (si c’est une offre client standard du siège).
- Capacités réseau:
  - **Partiel**: jauge joueurs existe (`id_erp_jauge`), quota affiliés activables absent.
- Délégation affilié pilotable:
  - **Partiel**: champ `id_client_delegation` existe, mais pas de workflow métier dédié de pilotage/traçabilité par affilié.
- `pending_payment`:
  - **Oui**: représentable via `id_etat=2`, déjà interprété dans le resolver Étape 1.

### 4) Où stocker les capacités réseau
- `nb max affiliés activables`:
  - absent du modèle actuel -> **nouvelle persistance nécessaire**.
- `nb max joueurs / affilié`:
  - base possible via `id_erp_jauge`, mais si valeur contractuelle indépendante de l’offre déléguée: **champ dédié recommandé**.
- `offre de délégation cible`:
  - non portée explicitement aujourd’hui -> **champ dédié recommandé**.

### 5) Où stocker l’activation/désactivation affilié par le siège
- Existant délégation (`id_client_delegation`) insuffisant pour audit complet (qui/quand/pourquoi/état distinct).
- **Recommandé**: table dédiée d’activation affilié liée au contrat réseau, avec pointeur optionnel vers la ligne d’offre déléguée.

### 6) Modules BO réellement concernés
- Confirmés minimaux:
  - `www/web/bo/www/modules/entites/clients/bo_module_parametres.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`
  - `www/web/bo/master/bo_master_script.php`
  - `www/web/bo/do_script.php`
  - `global/web/lib/core/lib_core_module_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- Écrans BO connexes utiles:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php` (aside offres + délégation visible)
  - `www/web/bo/www/modules/entites/clients/bo_module_aside.php`.

### 7) Hooks/synchronisations Stripe existants et raccord possible contrat réseau
- Activation initiale:
  - `invoice.paid` (`billing_reason=subscription_create`) -> set `asset_stripe_productId`, validation offre.
- Résiliation:
  - `customer.subscription.updated` avec `cancel_at_period_end=true` -> `date_fin`.
- Reprise:
  - `customer.subscription.updated` (retour cancel false) -> `date_fin='0000-00-00', id_etat=3`.
- Suspension:
  - **non trouvé dans la documentation/code audité** comme statut dédié persistant côté SI.
- Changement d’offre:
  - `customer.subscription.updated` -> MAJ `id_erp_jauge`, `id_paiement_frequence`, `prix_ht`.
- Raccord contrat réseau:
  - propre si le contrat cadre est une offre client dédiée du siège (même mécanique Stripe).

### 8) Stratégie recommandée Étape 2 (A/B/C)
- Option A (réutiliser totalement l’existant):
  - + rapide
  - - dette forte, capacités et activation affilié non auditables proprement.
- Option B (étendre légèrement l’existant):
  - + conserve la base commerciale/Stripe existante
  - + ajoute seulement la persistance manquante (capacités + activation affilié)
  - + compatible Étape 1
  - - nécessite 2 petites tables et un BO ciblé.
- Option C (support dédié minimal complet, hors modèle existant):
  - + lisible théoriquement
  - - risque de doublonner le cycle Stripe/offres et complexifier la maintenance.
- **Verdict tranché**: **Option B**.

## Modèle de persistance recommandé (Étape 2, sans implémenter)

### Réutiliser tel quel
- `ecommerce_offres_to_clients` pour le contrat commercial siège:
  - état (`id_etat`), validité (`date_debut/date_fin`), rattachement Stripe (`asset_stripe_productId`).

### Ajouter minimalement
- Table `ecommerce_reseau_contrats` (1 ligne active max par siège):
  - `id_client_siege`
  - `id_offre_client_contrat` (FK logique vers `ecommerce_offres_to_clients.id`)
  - `max_affiliates_activables`
  - `max_players_per_affiliate`
  - `id_offre_delegation_cible` (nullable)
  - `online`, `date_ajout`, `date_maj`, `id_entite_utilisateur`.
- Table `ecommerce_reseau_affiliations_activation`:
  - `id_contrat_reseau`
  - `id_client_affilie`
  - `activation_state` (`active|inactive|pending_payment_blocked`)
  - `id_offre_client_deleguee` (nullable)
  - `activation_source` (`bo|pro|cron|webhook`)
  - `commentaire`, timestamps, `id_entite_utilisateur`.

## Risques / collisions identifiés
- Collision offre propre vs offre réseau si on ne distingue pas explicitement la ligne “contrat cadre”.
- Résiliation Stripe: met souvent `date_fin` avant bascule `id_etat` (cron), donc lecture instantanée à harmoniser.
- `id_client_delegation` peut être édité via CRUD BO générique: risque d’écriture non contextualisée sans garde-fous.
- Données legacy (`''` vs `0000-00-00`) sur dates de fin à normaliser dans le resolver réseau.

## Plan technique concret du patch Étape 2 (proposé, non implémenté)
1. Ajouter persistance réseau dédiée (2 tables + index).
2. Ajouter API/fonctions globales:
   - lecture/écriture contrat réseau,
   - lecture/écriture activation affilié,
   - compteur capacité utilisée/restante,
   - journalisation explicite.
3. BO: ajouter entrée “Gestion contrat réseau / délégation” depuis fiche client siège.
4. BO: écran contrat réseau (capacité, validité, offre cible, compteur activés).
5. BO: actions affilié (activer/désactiver) avec contrôle capacité.
6. Intégrer resolver Étape 1 pour lire la nouvelle surcouche (sans casser priorité offre propre).
7. Prévoir hooks post-webhook/cron pour recalcul état contrat réseau si nécessaire.

## Liste précise des fichiers à patcher ensuite (Étape 2)
- BO:
  - `www/web/bo/www/modules/entites/clients/bo_module_parametres.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`
  - nouveau module BO dédié (ex. `www/web/bo/www/modules/ecommerce/reseau_contrats/*`)
- Global:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/lib/core/lib_core_module_functions.php` (encadrement write path ciblé)
- PRO (Étape 2 uniquement, pas 2A):
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` (affichage contrat siège)
  - `pro/web/ec/ec.php` (si besoin d’état/CTA cohérent contrat)
- SQL:
  - migration schéma (nouvelles tables + index)

## Limites / points à confirmer avant patch
- Valeurs exactes du référentiel `referentiels_offres_clients_etats` en prod (la structure est trouvée, pas le dictionnaire détaillé dans les sources ouvertes ici).
- Règle métier exacte quand Stripe est `past_due`/`unpaid` (non matérialisée comme état SI dédié actuellement).
- Politique d’unicité: 1 contrat réseau actif max par siège (à figer).
- Gouvernance de `id_offre_delegation_cible` si le catalogue évolue.
