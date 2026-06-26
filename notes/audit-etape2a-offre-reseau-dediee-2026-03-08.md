# Audit + patch Étape 2A — offre réseau dédiée (2026-03-08)

## Sources documentaires consultées (preuve)
- START (main): `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md`
  - sections: `Parcours (sans supposition)`, `Règle preuve d’abord (obligatoire)`.
- SITEMAP agent-first: `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt`
- DOCS_MANIFEST: `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md`
  - section: `Update triggers (mapping)`.
- Plan migration: `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/notes/plan_migration_reseau_branding_contenu.md`
  - sections: `Étape 2`, `Étape 2A`, règles produit offre réseau dédiée.

## Repos/fichiers audités (code)
- SI/global:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/lib/core/lib_core_module_functions.php`
- PRO:
  - `pro/web/ec/ec.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_view.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_list.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_step_0_offres_client.php`
  - `pro/web/ec/modules/compte/client/ec_client_script.php`
- BO/www:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`

## État initial (avant patch 2A)
- Contrat réseau BO/global déjà en place (Étape 2): persistance `ecommerce_reseau_contrats*`, activation affilié, resolver centralisé.
- Manque principal 2A: pas de brique SI explicite qui garantit l’offre réseau dédiée pour chaque siège (création auto + rattrapage legacy).
- `Mon offre` ne portait pas encore la règle “masquée à 0€ / visible si signal commercial réseau”.

## Patch plan proposé
1. Ajouter un socle global d’ensure offre dédiée (catalogue + offre client siège + contrat réseau dédié).
2. Brancher cet ensure dans le resolver métier pour création auto et backfill progressif.
3. Exclure explicitement l’offre dédiée du calcul d’accès jeu siège.
4. Ajouter le calcul de montant mensuel réseau agrégé et un helper barème remise volume (préparation 2B).
5. Adapter `Mon offre` PRO à la règle de visibilité 2A.
6. Ajouter un levier BO de backfill siège par siège.

## Implémentation réalisée
- Global:
  - helpers `app_ecommerce_reseau_offre_dediee_*` + ensure/backfill.
  - exclusion offre dédiée du resolver `app_ecommerce_offre_effective_get_context`.
  - calcul agrégé mensuel réseau + helper remise volume paliers 2A.
- PRO:
  - `Mon offre` filtrée par visibilité métier 2A.
  - détail offre dédiée enrichi (support contrat, montant réseau agrégé).
  - exclusion de l’offre dédiée des offres lançables tunnel start.
- BO:
  - backfill explicite par siège (`Créer / rattraper offre réseau dédiée`).

## Risques/régressions surveillés
- Régression accès jeu siège: mitigée par exclusion explicite offre dédiée dans le resolver.
- Régression affichage Mon offre: mitigée par filtre dédié appliqué uniquement à l’offre réseau dédiée.
- Compatibilité Étape 2B: préservée (pas d’implémentation commande affiliée/paiement 2B, seulement helpers préparatoires).

## Addendum correctif (2026-03-08) — point d’entrée BO réel + legacy délégué

### Sources documentaires consultées (preuve)
- `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md`  
  Sections consultées: `Parcours (sans supposition)`, `Règle preuve d’abord (obligatoire)`.
- `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt`  
  Section consultée: index de navigation agent-first (repérage des entrées canon/notes).
- `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.ndjson`  
  Section consultée: mapping des chemins docs versionnés.
- `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md`  
  Section consultée: discipline de mise à jour (`HANDOFF`, `TASKS`, `README`, régénération sitemap/index).
- `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/notes/plan_migration_reseau_branding_contenu.md`  
  Sections consultées: règles Étape 2A (offre réseau dédiée, non-accès jeu, visibilité Mon offre, traçabilité affilié par affilié).

### Audit ciblé complémentaire (code)
- Point d’entrée réel bascule TdR BO:
  - `www/web/bo/www/modules/entites/clients/bo_module_parametres.php` (champ `flag_client_reseau_siege`).
  - `www/web/bo/www/modules/entites/clients/bo_clients_script.php` (mode `modifier` = point d’écriture).
- Ensure/backfill 2A existant:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php` (`app_ecommerce_reseau_offre_dediee_ensure_for_client`, `..._backfill_all_sieges`).
- Contrat cadre BO + lecture lignes:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- Donnée de délégation legacy:
  - `ecommerce_offres_to_clients.id_client_delegation` (lecture dans `app_ecommerce_functions.php`).
- Affichage PRO “Mon offre” siège:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_list.php`

### Constat de gap
- Le patch 2A créait l’offre dédiée via ensure/backfill, mais pas branché explicitement sur le vrai événement BO de bascule TdR.
- Des offres déléguées legacy actives pouvaient rester hors table d’activation contrat (`ecommerce_reseau_contrats_affilies`), donc lisibles comme lignes siège “autonomes”.
- L’agrégat mensuel réseau reposait sur les lignes déléguées actives directes, sans garantie de rattachement contrat cadre.

### Correctif appliqué
- BO `clients` (mode `modifier`):
  - quand le client est TdR après modification, exécution systématique et idempotente:
    - `app_ecommerce_reseau_offre_dediee_ensure_for_client(...)`
    - `app_ecommerce_reseau_contrat_sync_legacy_delegations(...)`
- Global:
  - ajout `app_ecommerce_reseau_contrat_sync_legacy_delegations(...)`:
    - détecte offres déléguées legacy actives du siège,
    - upsert dans `ecommerce_reseau_contrats_affilies` (état `active`, offre liée),
    - désactive les activations devenues sans offre active.
  - agrégat montant réseau (`app_ecommerce_reseau_montant_mensuel_agrege_get`):
    - priorité au périmètre contrat (`ecommerce_reseau_contrats_affilies` actifs + offre déléguée active),
    - fallback legacy si contrat/table indisponible.
- BO contrat réseau:
  - sync legacy déclenché au chargement de la page.
  - ajout action explicite “Raccrocher offres déléguées legacy”.
- PRO “Mon offre” siège:
  - exclusion des lignes déléguées (`id_client_delegation>0`) de la lecture “offres standard siège”.

### Points non trouvés dans la documentation
- Process BO exact “bascule client en TdR depuis la fiche client” détaillé étape par étape: **non trouvé dans la documentation**.
- Règle explicite de migration automatique des délégations legacy vers `ecommerce_reseau_contrats_affilies`: **non trouvé dans la documentation**.
