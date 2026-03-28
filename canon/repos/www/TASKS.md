# Repo `www` — Tasks

## PATCH 2026-03-24 — BO clients: copie du lien EC temporaire au lieu de l'ouverture
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- [x] Cause confirmée:
  - apres generation, l'URL du lien EC temporaire etait affichee comme une ancre cliquable;
  - l'usage BO attendu est plutot de partager l'URL, pas de la suivre depuis la fiche client.
- [x] Correctif livré:
  - l'URL est maintenant associee a une action de copie presse-papiers;
  - un bouton `Copier le lien` et un feedback `Lien copié.` sont ajoutes;
  - un fallback `execCommand('copy')` couvre les navigateurs BO sans `navigator.clipboard`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK

## PATCH 2026-03-20 — BO `facturation_pivot`: allègement du reporting SaaS sans perte des KPI sessions
- [x] Audit ciblé:
  - `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
- [x] Cause confirmée:
  - la page `?t=syntheses&m=facturation_pivot&p=saas` recalculait les sessions jeux via un premier scan lourd sur `championnats_sessions`;
  - un second scan quasi identique recalculait ensuite les seules sessions numériques pour les ratios joueurs/session et joueurs/client;
  - ce double passage SQL a été introduit dans le correctif `fix calcul sessions reporting`.
- [x] Correctif livré:
  - l’agrégation principale des sessions remonte maintenant aussi `sessions_numeric` dans la même requête SQL;
  - le second balayage `sql_sessions_numeric` est supprimé;
  - les métriques métiers conservées:
    - sessions finies par mois / client / jeu
    - ventilation par type de jeu
    - comptage séparé des sessions numériques pour les ratios.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK

## PATCH 2026-03-13 — BO réseau: remplacements délégués différés persistés en base dédiée
- [x] Audit ciblé:
  - `www/web/bo/cron_routine_bdd_maj.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le cron BO des remplacements différés relisait encore directement les marqueurs `[reseau_replace:*]` et `[reseau_replace_timing:*]` dans `ecommerce_offres_to_clients.commentaire`;
  - la base importée via phpMyAdmin ne portait pas encore de table métier dédiée pour cet ordonnancement.
- [x] Correctif livré:
  - ajout de la table `ecommerce_reseau_delegated_replacements` dans `bdd_ecommerce_reseau_contrats.sql`;
  - ajout d’un backfill best-effort depuis les anciens marqueurs pour rapatrier les remplacements déjà planifiés lors de l’import SQL;
  - le cron BO s’appuie désormais d’abord sur cette table dédiée, puis conserve un fallback legacy sur les anciens marqueurs tant que des lignes historiques peuvent subsister.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/cron_routine_bdd_maj.php` OK

## PATCH 2026-03-13 — BO réseau: liens croisés vers la TdR et l'offre support
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Cause confirmée:
  - la fiche BO d'un `Abonnement réseau` n'affichait pas explicitement le compte TdR dans le bloc haut;
  - la synthèse `Affiliés du réseau` indiquait `Abonnement réseau actif : oui` sans lien rapide vers la fiche de l'offre support.
- [x] Correctif livré:
  - la vue haute `offres_clients` affiche maintenant une ligne `CLIENT` au-dessus de `Objet`, avec lien vers la fiche client de la TdR;
  - dans `reseau_contrats`, le libellé `Abonnement réseau actif` devient cliquable quand l'offre support est résolue;
  - aucun write path ni recalcul réseau n'est modifié.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-13 — BO `reseau_contrats`: affichage de l'`Offre incluse cible`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Cause confirmée:
  - le bloc `Affiliés du réseau` exposait déjà `Abonnement réseau actif`, `Nb affiliés limite` et `Nb de places dispo`;
  - l'offre déléguée incluse cible restait pourtant absente de cette synthèse BO, alors que l'identifiant canonique `id_offre_delegation_cible` est déjà disponible dans la couverture réseau.
- [x] Correctif livré:
  - la synthèse affiche maintenant `Offre incluse cible` sous la ligne d'état/quota quand l'abonnement réseau est actif;
  - le libellé est résolu en priorité depuis le catalogue déjà chargé par la vue, avec fallback sur `module_get_detail('ecommerce_offres', ...)`;
  - aucun recalcul métier ni write path réseau n'est ajouté.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `offres_clients`: respect du passage explicite à `Terminée` pour l'`Abonnement réseau`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - dépendances relues:
    - `global/web/lib/core/lib_core_module_functions.php`
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le flux BO de clôture passait encore par une transition runtime intermédiaire avant la fermeture effective de la ligne support;
  - surtout, une fois le runtime archivé, le resolver support réseau continuait d'autoriser un fallback automatique vers une autre offre support `id_etat IN (2,3)` du même siège;
  - ce fallback pouvait réouvrir la lecture réseau en `En attente` après une clôture BO pourtant explicite.
  - la fiche client TdR appelait aussi `app_ecommerce_reseau_facturation_get_detail(...)` en mode par défaut;
  - ce helper de lecture relançait encore `app_ecommerce_reseau_contrat_sync_legacy_delegations(...)`, puis `app_ecommerce_reseau_facturation_refresh(...)`, donc une réécriture possible du statut support au simple rechargement BO.
- [x] Correctif livré:
  - la clôture BO immédiate s'appuie désormais directement sur la fermeture explicite de l'offre support et l'archivage runtime final;
  - un garde-fou final réapplique aussi `id_etat=4` sur la ligne support après la rotation runtime pour empêcher tout retour parasite en `En attente`;
  - un contrat runtime archivé retourne désormais `cloture` comme état canonique;
  - tant que ce runtime archivé n'est pas explicitement rerattaché par une réactivation BO/Stripe, aucun fallback automatique ne peut réélire une offre support `En attente` ou `Active`;
  - le recalcul réseau canonique ne fabrique plus non plus lui-même un passage de l'offre support vers `En attente` ou `Active`; ces transitions restent réservées aux write paths explicites BO / Stripe, tandis que le refresh conserve l'état courant sauf clôture runtime;
  - la fiche client TdR lit désormais la synthèse réseau en mode `skip_legacy_sync=1`, donc sans sync legacy implicite au chargement de la vue;
  - le correctif ne rouvre ni auto-création, ni suppression brute, ni write path concurrent.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: remise synthèse alignée sur la prochaine commande TdR
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - la synthèse `Remise réseau courante` affichait le palier des offres `hors abonnement réseau` déjà actives;
  - pour le front PRO, le besoin utile est la remise qui s’appliquerait à la prochaine offre commandée par la TdR.
- [x] Correctif livré:
  - la synthèse calcule désormais la remise sur `volume actif courant + 1`;
  - l’affichage rappelle explicitement qu’il s’agit de la `prochaine commande TdR`;
  - aucune modification du calcul tarifaire réellement appliqué aux lignes déjà actives.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: historique terminé et couverture stabilisés
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le tableau du bas de page exposait un titre devenu faux après ouverture de l’historique `incluse`;
  - la qualification de couverture pouvait encore reclasser des lignes historiques via un fallback legacy trop agressif;
  - le libellé `Incluse à l'abonnement réseau` suggérait à tort l’offre support courante.
- [x] Correctif livré:
  - renommage du tableau en `Offres déléguées terminées`;
  - affichage de tout l’historique des offres déléguées terminées rattachées à la TdR;
  - priorité au rattachement explicite `reseau_id_offre_client_support_source` pour qualifier l’historique;
  - libellé ajusté en `Incluse à un abonnement réseau`.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: remise réseau réintroduite dans `Tarif`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livré:
  - la colonne `Tarif` des affiliés réaffiche la remise réseau appliquée sur les délégations `hors abonnement réseau`;
  - le rendu détaille désormais brut HT, pourcentage de remise et net appliqué;
  - aucune tarification n’est ajoutée aux offres incluses à l’abonnement réseau.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: synthèse affiliés reformulée
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livré:
  - la synthèse du bloc `Affiliés du réseau` est réécrite en structure métier plus lisible;
  - affichage distinct de:
    - `Abonnement réseau actif`
    - `Tarif négocié` si actif
    - `Affiliés actifs`
    - `Offres propres`
    - `Offres déléguées`
    - `Offres incluses abn` si actif
    - `Affiliés inactifs`
    - `Remise réseau courante`
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: filtre rapide par type de couverture
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livré:
  - le tableau `Affiliés du réseau` est maintenant regroupé par type de couverture;
  - des filtres rapides permettent de n’afficher que:
    - `Tous`
    - `Incluses abn`
    - `Déléguées`
    - `Offres propres`
    - `Inactifs`
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-11 — Réseau: rattachement explicite des offres incluses à l'abonnement source
- [x] Audit ciblé:
  - `documentation/canon/data/schema/DDL.sql`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - aucune offre déléguée incluse ne portait l'id de l'offre support `Abonnement réseau` source;
  - l'historique devait donc être reconstruit par heuristique.
- [x] Correctif livré:
  - ajout du champ facultatif `reseau_id_offre_client_support_source` au schéma canonique `ecommerce_offres_to_clients`;
  - alimentation de ce champ sur les write-paths `cadre`;
  - remise à `0` sur les flux `hors abonnement réseau`.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-11 — BO `offres_clients`: `Offres incluses` figées par offre support
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_aside.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - la fiche `Abonnement réseau` lisait encore le contrat/support réseau courant du client pour le bloc `Offres incluses`;
  - la jointure sur `ecommerce_reseau_contrats_affilies.id_offre_client_deleguee` relisait un pointeur courant par affilié, pas un historique par offre support;
  - une offre support terminée pouvait donc ne pas afficher ses propres offres déléguées incluses.
- [x] Correctif livré:
  - ajout d’un helper global dédié pour relire les offres incluses rattachées à une offre support donnée;
  - le support actif repart désormais de la couverture canonique runtime;
  - une archive repart des offres déléguées du siège sur la période de l’offre support affichée;
  - aside, vue haute et formulaire BO utilisent désormais cette lecture figée par offre support;
  - les offres `Terminées` continuent d’exposer leurs délégations reliées dans cette section.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_aside.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php` OK

## PATCH 2026-03-11 — BO `offres_clients`: abonnement réseau terminé non réactivable par édition
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - la synchro BO `Abonnement réseau` restait exécutée même pour une offre support déjà `Terminée`;
  - ce passage pouvait rerattacher l'offre historique au runtime canonique.
- [x] Correctif livré:
  - skip de la synchro runtime tant que l'offre reste `Terminée`;
  - garde-fou de persistance sur `id_etat=4` pour une simple modification d'archive;
  - restauration explicite de `date_debut` / `date_facturation_debut` si ces champs reviennent vides dans ce flux.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-11 — BO `reseau_contrats`: séparation stable abonnement réseau / hors abonnement
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - la vue classait encore une ligne en `hors cadre` dès qu'un pricing hors cadre existait, même si `mode_facturation='cadre'`;
  - un affilié sans offre pouvait exposer à la fois l'action `Activer` via abonnement réseau et la commande hors abonnement.
- [x] Correctif livré:
  - priorité à `mode_facturation` pour empêcher le double comptage `cadre` vs `hors abonnement`;
  - synthèse métier remontée dans `Affiliés du réseau`;
  - action BO exclusive:
    - quota disponible => activation via abonnement réseau
    - sinon => attribution d'une offre déléguée hors abonnement réseau;
  - suppression des blocs redondants:
    - `Synthèse hors cadre`
    - `Commander une offre hors cadre`
    - `Offres affiliées hors cadre`
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - contrôle texte: plus de libellés/blocs BO redondants OK

## PATCH 2026-03-11 — BO `reseau_contrats`: offres terminées réseau explicites
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Cause confirmée:
  - le sous-compteur `dont offres terminées (CSO)` lisait encore le pipeline affilié au lieu des offres déléguées réellement terminées;
  - le formulaire d'attribution hors abonnement étendait trop la colonne `Actions`.
- [x] Correctif livré:
  - le sous-compteur est maintenant branché sur les offres déléguées réseau terminées;
  - ajout d'une table en bas de page listant ces offres terminées;
  - suppression du paragraphe `Activation`;
  - formulaire d'attribution hors abonnement passé en champs verticaux.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-11 — BO `reseau_contrats`: `Offre` + `Tarif` réalignés
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livré:
  - la colonne `Offre` réaffiche la jauge de l'offre active;
  - la colonne `Offre` affiche aussi la période en cours de l'offre active;
  - la colonne `Tarif` est ajoutée sur la liste `Affiliés du réseau`;
  - exception métier:
    - aucune tarification affichée pour les offres incluses à l'abonnement réseau;
  - la synthèse remonte aussi le tarif négocié du socle `Abonnement réseau` quand l'abonnement est actif.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-11 — Convergence d'activation `Abonnement réseau` entre BO et Stripe
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - dépendances relues:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - `pro/web/ec/ec_webhook_stripe_handler.php`
- [x] Correctif livré:
  - le BO réutilise maintenant le helper partagé d'activation support réseau déjà employé par le write path Stripe;
  - les deux chemins convergent vers le même ordre métier sans double logique divergente.
- [x] Effet attendu:
  - `Etat offre=active` puis `Etat contractuel=actif`
  - lecture cohérente dans `reseau_contrats` après activation BO ou paiement Stripe.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `npm run docs:sitemap` OK

## PATCH 2026-03-11 — BO `offres_clients`: override admin réel `pending_payment -> active`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `global/web/lib/core/lib_core_module_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le form BO postait déjà `id_etat=3`;
  - le rollback venait du refresh réseau générique déclenché par `module_modifier(...)` avant la synchro du contrat vers `actif`.
- [x] Correctif livré:
  - bypass du refresh prématuré étendu au cas admin `2 -> 3` sur l'offre support réseau canonique;
  - ordre retenu:
    - écriture BO de l'offre
    - sync des paramètres réseau de l'offre canonique
    - synchro contrat vers `actif`
    - refresh réseau explicite après mise à jour du contrat;
  - flow spécial `id_etat=4` conservé.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `npm run docs:sitemap` OK
- [ ] Hors périmètre:
  - aucun changement Stripe
  - aucune réintroduction de `save_contrat`, `activate_contract`, `close_contract`

## PATCH 2026-03-11 — BO réseau durable: CTA visible + pilotage affiliés
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constats confirmés:
  - le CTA méta TdR existait mais comme lien discret;
  - `save_contrat`, `activate_contract`, `close_contract` restent neutralisées dans le script BO;
  - l'activation BO réutilise déjà les write paths existants d'offre déléguée.
- [x] Correctif livré:
  - `Voir / gérer les affiliés` devient un vrai bouton visible sous `Tête de réseau`;
  - `reseau_contrats` expose la liste des affiliés avec actions d'activation, désactivation et attribution hors cadre;
  - la règle métier est conservée:
    - abonnement réseau actif + quota disponible => activation via l'offre cible du contrat
    - sinon => choix d'une offre du SI en hors cadre;
  - aucune action contrat neutralisée n'est réintroduite.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `npm run docs:sitemap` OK
- [ ] Hors périmètre:
  - aucune réactivation du pilotage BO du contrat négocié
  - aucun changement PRO requis dans ce lot

## PATCH 2026-03-11 — Régression UI du `+` TdR sur fiche client
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le gating backend continuait à reposer sur `clients.flag_client_reseau_siege = 1`;
  - le lien ciblé `offres_clients` vers `Abonnement réseau` restait valide;
  - la régression était strictement UI:
    - le `+` documenté avait été remplacé par des boutons fixes;
    - puis un correctif intermédiaire laissait le clic sur `+` partir vers le flux standard, le menu restant sur le chevron split.
- [x] Correctif livré:
  - la fiche client TdR réaffiche un `+` avec dropdown Bootstrap 5 porté par le bouton `+` lui-même;
  - le menu rapide propose `Offre propre` / `Offre réseau`;
  - `Offre réseau` ouvre toujours `offres_clients` prérempli sur `Abonnement réseau`;
  - `Affiliés / hors cadre` reste exposé séparément.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
- [ ] Hors périmètre:
  - aucun changement moteur global
  - aucune refonte de `reseau_contrats`

## PATCH 2026-03-11 — CTA standard `Ajouter` sur `offres_clients` filtré TdR
- [x] Audit ciblé:
  - `www/web/bo/master/bo_master_header.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le CTA `Ajouter` venait du core et ne proposait qu’un lien standard vers le formulaire;
  - le contexte `id_client` filtré existait déjà, mais aucun CTA ne préremplissait `id_offre=Abonnement réseau`.
- [x] Correctif livré:
  - sur la liste `offres_clients` filtrée par une TdR, `Ajouter` devient un dropdown Bootstrap 5;
  - le menu propose `Offre propre` / `Offre réseau`;
  - `Offre réseau` pointe vers `offres_clients` avec `id_client` et `id_offre=<catalogue Abonnement réseau>`.
- [x] Vérification:
  - `php -l www/web/bo/master/bo_master_header.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-11 — Résolution helper `Abonnement réseau` vs catalogue BO
- [x] Audit ciblé:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/lib/core/lib_core_module_functions.php`
  - `www/web/bo/master/bo_master_header.php`
- [x] Cause confirmée:
  - le helper `app_ecommerce_reseau_abonnement_get_catalog_id()` ne lisait que `seo_slug='abonnement-reseau'`;
  - le filtre/select BO `Offre` lisait toute la table `ecommerce_offres` par `nom`, donc l’offre restait visible même si le `seo_slug` était absent.
- [x] Correctif livré:
  - fallback helper par `nom='Abonnement réseau'`;
  - mise à niveau opportuniste du `seo_slug` canonique sur la ligne existante;
  - CTA dropdown BO conservé avec attribut Bootstrap 4 `data-toggle="dropdown"`.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l www/web/bo/master/bo_master_header.php` OK

## PATCH 2026-03-11 — Fiche client TdR `+` sur section `Offres`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le `+` était déjà un vrai bouton dropdown unique;
  - le runtime BO est Bootstrap 4 alors que le bouton portait encore `data-bs-toggle="dropdown"`.
- [x] Correctif livré:
  - passage du bouton `+` en `data-toggle="dropdown"`;
  - conservation des URLs `Offre propre` / `Offre réseau`;
  - `Offre réseau` continue d’utiliser la résolution catalogue fiabilisée `Abonnement réseau`.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK

## PATCH 2026-03-11 — Fiche client TdR: déplacement du CTA réseau dans le bloc meta
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- [x] Correctif livré:
  - hoist de l’URL `reseau_contrats` pour réutilisation dans le bloc meta;
  - ajout du CTA `Voir / gérer les affiliés` juste sous `Tête de réseau`;
  - suppression du bouton `Affiliés / hors cadre` dans la section `Offres`;
  - aucun changement sur le dropdown `Offre propre` / `Offre réseau`.
- [x] Réalignement doc livré:
  - `reseau_contrats` est désormais décrit comme vue BO transverse interne durable de pilotage réseau;
  - l’ancien wording transitoire est corrigé dans les sections de synthèse courantes.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - `npm run docs:sitemap` OK

## PATCH 2026-03-11 — Dépendance moteur global stabilisée
- [x] Dépendance relue:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Effet de dépendance intégré:
  - le moteur ne crée plus de nouveau support legacy `contrat-cadre-reseau`
  - un éventuel post legacy depuis le BO standard est remappé vers `Abonnement réseau`.
- [ ] Suites ouvertes côté `www`:
  - poursuivre le nettoyage des wording historiques autour de la vue BO `reseau_contrats`
  - conserver les neutralisations de write paths contrat sur la vue BO réseau durable.

## PATCH 2026-03-11 — Stabilisation BO minimale des points d’entrée réseau
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Clarification de la fiche client TdR:
  - le libellé BO `Offre réseau` n’est plus utilisé pour ouvrir `Abonnement réseau`;
  - la fiche client distingue maintenant:
    - `Abonnement réseau`
    - `Voir / gérer les affiliés`.
- [x] Requalification de `reseau_contrats`:
  - titre, texte d’aide et wording recentrés sur la vue BO transverse interne durable de pilotage réseau;
  - l’écran ne se présente plus comme le lieu canonique du cadre négocié.
- [x] Neutralisation défensive des write paths contrat:
  - `save_contrat`
  - `activate_contract`
  - `close_contract`
  - ces actions renvoient désormais un message explicite de désactivation.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK
- [ ] Suites ouvertes:
  - lot moteur global pour supprimer le bi-catalogue support et l’auto-création legacy
  - lot BO transverse pour préparer `Gestion des affiliés`
  - lot PRO pour réaligner `Mon offre` et la page réseau TdR.

## RE-BASELINE 2026-03-11 — Cible canonique réseau
- [x] Audit relu sur:
  - `www/web/bo/master/bo_master_form.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Vérité canonique retenue:
  - une seule offre métier TdR cible: `Abonnement réseau`
  - `reseau_contrats` ne doit plus être lu comme second objet métier stable
  - la cible BO est la vue transverse `Gestion des affiliés`, portée à ce stade par `reseau_contrats`.
- [ ] Suites ouvertes:
  - supprimer les write paths contrat encore présents dans `reseau_contrats`
  - poursuivre le nettoyage des wording historiques autour de `reseau_contrats`
  - préparer une éventuelle extraction future si la vue BO réseau change de route, sans changer sa fonction durable.

## PATCH 2026-03-10 — Hotfix Étape 2: entrée TdR `+` vers `Abonnement réseau`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - audit logique relu:
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif BO livré:
  - le `+` de la fiche client TdR propose désormais `Offre propre` / `Offre réseau`;
  - `Offre propre` conserve le comportement historique inchangé;
  - `Offre réseau` ouvre directement le formulaire `offres_clients` prérempli sur `Abonnement réseau`;
  - le bloc de paramétrage interne `Abonnement réseau` est désormais visible dès l’ajout ciblé, pas seulement en édition.
  - ajustement de robustesse:
    - la fiche client assure le catalogue `Abonnement réseau` avant gating de l’UI;
    - le dropdown est migré vers `data-bs-toggle="dropdown"` pour correspondre au BO Bootstrap 5.
- [x] Garde-fou conservé:
  - pour un client non TdR, le `+` conserve le flux historique standard.
- [x] Tests / recette:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php` OK
  - test manuel ajouté: `documentation/specs/tests/reseau-abonnement-reseau-hotfix-tdr-plus-pending-payment.md`

## PATCH 2026-03-10 — Étape 2 BO `Abonnement réseau`: offre distincte via `Ajouter une offre`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_aside.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Création nouvelle offre:
  - nouvelle entrée catalogue `Abonnement réseau` assurée par helper global;
  - reconnaissance support réseau élargie au nouveau catalogue avec fallback legacy.
- [x] Intégration au parcours `Ajouter une offre`:
  - le formulaire standard `offres_clients` reste inchangé à l’ajout;
  - l’option `Abonnement réseau` n’est visible que pour une TdR sélectionnée dans le champ `Client`;
  - choisir `Abonnement réseau` crée la ligne en `En attente`, la rattache au contrat réseau existant et renvoie ensuite vers l’édition dédiée pour le paramétrage.
- [x] Reprise du paramétrage négocié:
  - sync BO du montant négocié, de la périodicité, du quota inclus, de l’offre cible et de la jauge cible;
  - passage `En attente -> Active -> Terminée` via l’édition standard de l’offre.
- [x] Affichage des offres incluses:
  - la vue détail `offres_clients` de l’abonnement affiche uniquement les lignes incluses `cadre`, avec statut, période, périodicité et prix.
- [x] Tests / recette:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l www/web/bo/master/bo_master_form.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_aside.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - test manuel ajouté: `documentation/specs/tests/reseau-abonnement-reseau-etape2.md`

## PATCH 2026-03-10 — Étape 1 BO `Offre réseau`: recentrage hors cadre
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Retrait du contrat cadre de la page actuelle:
  - suppression des blocs, CTA et formulaires BO liés au contrat cadre / négocié dans `reseau_contrats`.
- [x] Recentrage hors cadre:
  - la vue BO n'affiche plus que les offres affiliées hors cadre, avec statut, période, périodicité, remise et tarif.
  - la création directe hors cadre reste possible depuis un bloc dédié pour les affiliés sans offre active.
- [x] Renommage fonctionnel:
  - titre BO `Gestion de l'offre réseau`;
  - CTA fiche client `Gérer l'offre réseau`.
- [x] Tests / recette:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - test manuel ajouté: `documentation/specs/tests/reseau-offre-reseau-etape1.md`

## PATCH 2026-03-10 — BO `offres_clients`: `Terminer` une offre réseau = clôture réelle
- [x] Surface BO ajustée:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Règle appliquée:
  - sur une offre réseau support, un passage BO à `id_etat=4` déclenche la clôture réelle du réseau;
  - la ligne support passe en historique immédiatement;
  - les offres déléguées actives liées sont terminées et les activations affiliés désactivées;
  - une nouvelle offre support `En attente` est recréée pour la suite.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-09 — BO contrat cadre: formulaire masqué hors activation/édition
- [x] Surfaces BO ajustées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Flux livré:
  - `inactif` / `cloture`:
    - champs masqués par défaut;
    - `Activer un contrat cadre` ouvre le formulaire;
    - validation unique des paramètres puis activation.
  - `actif`:
    - champs visibles en lecture seule par défaut;
    - CTA `Modifier` pour réouvrir l'édition;
    - CTA `Clôturer ce contrat cadre` masqué pendant l'édition;
    - sauvegarde puis retour à la vue lecture seule.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK

## PATCH 2026-03-09 — migration SQL canonique `contract_state` du module BO réseau
- [x] Surface BO / schéma ajustée:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Migration idempotente ajoutée:
  - ajout de la colonne `contract_state enum('inactif','actif','cloture') not null default 'inactif'`;
  - normalisation d’anciennes valeurs texte éventuelles:
    - `active`
    - `inactive`
    - `closed`
- [x] Backfill prudent:
  - état par défaut `inactif`;
  - promotion en `actif` uniquement si `id_offre_client_contrat` pointe une offre support active `id_etat=3`;
  - pas d’inférence automatique vers `cloture`.
- [x] Risque documenté:
  - exécution automatique de ce SQL depuis `cron_routine_bdd_maj.php`: non trouvé dans le code audité.

## PATCH Étape 2A — lisibilité BO de la part variable affiliés après remise réseau (2026-03-09)
- [x] Surface BO ajustée:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Lecture BO ajoutée:
  - la synthèse `Part variable affilies` rappelle le taux de remise réseau appliqué au calcul courant;
  - l’assiette de remise affichée est le nombre d’affiliés détenant une délégation active, `cadre` ou `hors_cadre`;
  - la colonne `Offre` affiche désormais aussi la jauge de l’offre active;
  - nouvelle colonne `Tarif`:
    - `offre déléguée incluse contrat cadre` -> `montant cadre négocié`, `nb d’offres incluses actives`, puis `HT / mois`;
    - `offre déléguée hors cadre` -> `HT`, `remise réseau`, puis `HT appliqué / mois`;
    - `offre propre` -> `HT / mois`;
    - `aucune offre` -> `-`.
- [x] Garde-fou de lisibilité:
  - la colonne `Offre` reste focalisée sur le lien et le libellé BO;
  - les montants sont isolés dans `Tarif`.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH Étape 2A — vitrine tarifaire alignée sur le référentiel tarifaire global (2026-03-09)
- [x] Surfaces WWW concernées:
  - `www/web/fo/modules/ecommerce/tarifs/fr/fo_tarifs_offre_detail.php`
  - `www/web/fo/modules/ecommerce/offres_paniers/fr/fo_offres_paniers_form_script.php`
- [x] Effet fonctionnel:
  - la vitrine continue d’utiliser le widget partagé abonnement;
  - le write path panier se recale désormais côté `global` sur le référentiel unique pour les cas couverts.
- [x] Audit parallèle BO réseau:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - création hors cadre confirmée via le helper global de prix, sans refonte de l’écran BO.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` OK

## PATCH Étape 2A — CTA BO `Activer` hors cadre unifié (2026-03-09)
- [x] Surfaces BO ajustées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Correction d’affichage:
  - ancienne condition erronée:
    - CTA affiché seulement si quota cadre dispo
    - ou offre cible présente
    - ou délégation legacy déjà réactivable
  - nouvelle condition:
    - CTA affiché pour tout affilié sans offre active, sauf `Offre propre`.
- [x] Flux BO livrés:
  - cas cadre exploitable:
    - activation auto avec l’offre cible du cadre
  - cas hors cadre unifiés:
    - pas de contrat exploitable
    - pas d’offre cible cadre
    - quota cadre atteint
  - dans ces cas:
    - choix BO de l’offre
    - choix BO de la jauge / capacité
    - création d’une nouvelle délégation hors cadre.
- [x] Simplification UI:
  - le select de réactivation d’une délégation existante est retiré de la colonne `Action`;
  - le formulaire poste désormais systématiquement `id_offre_client_deleguee=0`.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK

## PATCH Étape 2A — fermeture BO contrat cadre réseau (2026-03-09)
- [x] Surfaces BO finalisées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Évolutions livrées:
  - rechargement du reclassement quota/historique à l’ouverture de la page;
  - affichage explicite des champs métier:
    - `Montant cadre négocié (HT)`
    - `Nombre max d'affiliés inclus dans le cadre`
    - `Offre SI dédiée cible pour les affiliés couverts`
  - synthèse BO alignée sur le moteur global:
    - délégations actives résolues
    - quota absorbé
    - places incluses restantes
    - offre cible auto
  - table affiliés branchée sur le statut commercial effectif:
    - `offre propre`
    - `offre déléguée incluse contrat cadre`
    - `offre déléguée hors cadre`
    - `aucune offre`
- [x] Décision UX:
  - retrait du pilotage manuel `cadre / hors_cadre` dans cette vue pour éviter une contradiction avec le reclassement automatique.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH Étape 2A — refonte du tableau BO “Affiliés du siège” (2026-03-09)
- [x] Surface BO ajustée:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Recomposition du rendu:
  - suppression des colonnes:
    - `Activation réseau`
    - `Offre déléguée résolue`
  - nouvelles colonnes:
    - `Statut commercial`
    - `Offre`
  - libellés harmonisés:
    - `Offre propre`
    - `Déléguée incluse contrat cadre`
    - `Déléguée hors cadre`
    - `Aucune offre`
  - offre active désormais affichée comme objet BO manipulable avec lien direct `offres_clients`.
- [x] Colonne action clarifiée:
  - `Non pilotable ici`
  - `Désactiver`
  - `Activer`
- [x] CTA désormais câblés de bout en bout:
  - `Activer`:
    - write path BO dédié
    - création de l’offre cible si nécessaire
    - ou activation d’une offre déléguée existante
    - puis reclassement cadre/hors cadre
  - `Désactiver`:
    - termine la ligne `ecommerce_offres_to_clients` déléguée active
    - puis refresh facturation + reclassement
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK

## PATCH Étape 2A — triggers BO de désaffiliation / suppression affilié (2026-03-09)
- [x] Surfaces BO complétées:
  - `www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_functions.php`
- [x] Correction appliquée:
  - toute modification BO de `clients.id_client_reseau` rejoue désormais le reclassement sur l’ancien et le nouveau siège;
  - la suppression BO d’un affilié rattaché rejoue le reclassement du siège d’origine.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_script.php` OK
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_functions.php` OK

## AUDIT Étape 2A — lien réseau historique et remise associée (2026-03-09)
- [x] Audit ciblé du routing public/proxy:
  - `pro/web/.htaccess`
- [x] Constat:
  - le lien réseau historique existe toujours sous deux formes:
    - `/utm/reseau/{slug}`
    - `/utm/reseau/{slug}/{CODE}`
  - la variante avec `CODE` ne pilote pas un contrat cadre;
  - elle ne fait que transporter un code remise en plus du rattachement réseau.
- [x] Conséquence:
  - côté routing, il n’existe pas d’ancienne route dédiée “activation contrat cadre” à réutiliser;
  - le futur flux automatique devra rester branché sur cette entrée UTM réseau existante, mais avec une décision métier portée par un helper global.

## AUDIT Étape 2A — contrat cadre automatique (2026-03-09)
- [x] Audit ciblé de la surface BO `reseau_contrats`:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Constat BO:
  - la page sait déjà persister:
    - `montant_socle_ht`
    - `max_affilies_activables`
    - `id_offre_delegation_cible`
  - mais elle pilote encore explicitement les affiliés un par un via:
    - activation manuelle
    - `mode_facturation` manuel.
- [x] Décision d’audit:
  - pas de patch BO sûr tant que le moteur automatique global n’existe pas;
  - supprimer maintenant le pilotage manuel du BO sans nouveau moteur créerait une incohérence immédiate entre UI, agrégateur et flux d’affiliation.
- [x] Cible documentée:
  - recentrer le premier écran sur:
    - montant cadre négocié
    - affiliés inclus / activables
    - offre incluse par affilié
  - puis faire dériver automatiquement la synthèse affilié/cadre/hors cadre depuis le moteur global.

## PATCH Étape 2A — simplification finale BO `mode_facturation` (2026-03-09)
- [x] Surfaces BO + migration:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Donnée ajoutée:
  - `ecommerce_reseau_contrats_affilies.mode_facturation`
  - valeurs:
    - `cadre`
    - `hors_cadre`
- [x] UI minimale ajoutée:
  - nouvelle colonne `Facturation` dans la liste des affiliés du siège;
  - select léger pilotable par affilié:
    - `Inclus dans le cadre`
    - `Facturé en plus`
  - rappel visuel de l’effet facture courant.
- [x] Migration de simplification:
  - les anciennes délégations actives issues TdR sont converties en `hors_cadre`;
  - le BO permet ensuite de reclasser explicitement un affilié en `cadre` quand il est absorbé par la négociation.
- [x] Vérification:
  - `php -l` OK sur `bo_reseau_contrats_list.php`, `bo_reseau_contrats_script.php`.

## PATCH 2026-03-09 — BO contrat cadre: CTA état explicite + synthèse agrégat
- [x] Surfaces BO ajustées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] CTA métier ajoutés:
  - `Activer un contrat cadre`
  - `Modifier le contrat cadre`
  - `Clôturer ce contrat cadre`
- [x] Effet attendu:
  - `Activer` -> `contract_state=actif`
  - `Clôturer` -> `contract_state=cloture`
  - refresh immédiat de l’agrégat réseau et du reclassement cadre / hors cadre
- [x] Synthèse BO ajustée:
  - affiche l’état explicite du contrat cadre;
  - sépare `Cadre négocié` et `Socle appliqué à l’agrégat`;
  - n’autorise l’activation dans le cadre que si le contrat est `actif`.
- [ ] Migration requise:
  - ajouter la colonne SQL `ecommerce_reseau_contrats.contract_state`;
  - sans cette colonne, la page n’a qu’un fallback legacy de lecture et affiche un warning opérateur.

## PATCH Étape 2A — simplification BO contrat cadre réseau TdR (2026-03-09)
- [x] Surfaces BO ajustées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] UI simplifiée:
  - suppression des CTA de maintenance `Créer / rattraper offre réseau dédiée` et `Raccrocher offres déléguées legacy` de la page courante;
  - affichage en lecture seule de la ligne support du contrat réseau, avec lien discret vers la ligne `offres_clients`;
  - renommage métier:
    - `Montant socle réseau HT / mois` -> `Montant cadre négocié (HT)`;
    - `Socle réseau` -> `Cadre négocié`;
  - masquage du premier écran pour les champs legacy / techniques:
    - `Jauge cible (référentiel)`
    - `Offre cible de délégation (catalogue)`
  - conservation des paramètres encore utilisés par l’activation réseau:
    - `max_affilies_activables`
    - `max_joueurs_par_affilie`
- [x] Garde-fou script:
  - `save_contrat` réutilise désormais les valeurs déjà persistées si certains champs ne sont plus postés par l’écran simplifié.
- [x] Audit métier associé:
  - la formule actuelle reste:
    - `montant facturable TdR = montant_socle_ht + somme des offres déléguées legacy actives`;
  - aucune donnée existante ne distingue en code / DB:
    - affilié déjà couvert par le cadre négocié;
    - affilié réellement hors cadre.
- [ ] TODO:
  - introduire une donnée explicite de couverture cadre avant toute correction sûre de double comptabilisation.

## PATCH Étape 2B — filtre BO TdR sur les offres déléguées legacy (2026-03-09)
- [x] Surface BO corrigée:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- [x] Règle retenue:
  - sur une fiche client TdR (`flag_client_reseau_siege=1`), une ligne legacy déléguée est identifiée par:
    - `ecommerce_offres_to_clients.id_client = siège`
    - `ecommerce_offres_to_clients.id_client_delegation > 0`
- [x] Correction appliquée:
  - exclusion de ces lignes de la section `Offres` de la fiche client TdR;
  - conservation des offres propres TdR et de la ligne support `Contrat cadre réseau`;
  - correction complémentaire fiche client affilié:
    - inclusion des lignes legacy où `id_client_delegation = affilié` et `id_client <> affilié`;
    - affichage simple du nom du compte TdR dans la colonne `Délégation`;
  - aucun ajout de section dédiée “Offres déléguées”.
- [x] Vérification attendue:
  - la synthèse métier reste portée par `reseau_contrats`;
  - aucun impact sur la persistance, la facturation réseau ou le resolver d’accès jeu.

## AUDIT Étape 2B — portage des offres déléguées réseau sur l’affilié (2026-03-09)
- [x] Audit ciblé surfaces BO / write path:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`
- [x] Constat vérifié:
  - la fiche client BO du siège liste encore brut `ecommerce_offres_to_clients.id_client = siège`, donc inclut les lignes déléguées legacy;
  - le module BO `reseau_contrats` n’engendre pas encore une ligne d’offre portée par l’affilié: il sélectionne / active une ligne legacy existante du siège via `id_offre_client_deleguee`;
  - le seul write path générique exposant `id_client_delegation` reste le CRUD table-driven `offres_clients`, explicitement étiqueté legacy.
- [x] Conséquence:
  - le BO n’a pas encore de chemin métier complet “créer une offre affiliée portée par l’affilié avec origine TdR”.
- [x] Décision:
  - pas de patch UI-only sur la fiche client TdR;
  - la correction sûre passe par un write path métier dédié + migration de lecture BO pour séparer offres propres TdR et offres issues TdR portées par affilié.

## PATCH Étape 2A — facturation persistée de l’offre réseau TdR (2026-03-09)
- [x] Surfaces BO alignées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
  - `www/web/bo/cron_routine_bdd_maj.php`
- [x] Correction appliquée:
  - le BO `reseau_contrats` édite désormais le `montant_socle_ht` et affiche le montant facturable total de la TdR;
  - le prix persistant de la ligne support suit le recalcul métier centralisé;
  - les écrans BO lisant `ecommerce_offres_to_clients.prix_ht` restent cohérents sans patch UI dispersé.
- [x] Migration SQL:
  - ajout du champ `ecommerce_reseau_contrats.montant_socle_ht`;
  - script rendu idempotent par garde `INFORMATION_SCHEMA`.
- [x] Vérification:
  - `php -l` OK sur `bo_reseau_contrats_list.php`, `bo_reseau_contrats_script.php`, `cron_routine_bdd_maj.php`.
- [x] Ajustement BO complémentaire:
  - suppression des warnings d’affichage dus à un appel invalide de `montant(...)` dans la synthèse BO;
  - répercussion du montant facturable TdR dans la section `Offres` de la fiche client siège, sur la ligne `Contrat cadre réseau`.

## AUDIT Étape 2A — affichage BO offres TdR + montant contrat réseau legacy (2026-03-09)
- [x] Audit ciblé BO fiche client siège:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Constat vérifié:
  - la section `Offres` de la fiche client TdR liste brut les lignes `ecommerce_offres_to_clients` du siège, sans filtre excluant `id_client_delegation>0`;
  - le prix affiché dans cette section lit `eotc.prix_ht` brut, pas le montant réseau agrégé;
  - la vue BO `reseau_contrats` synchronise bien les délégations legacy dans le contrat dédié, mais n’affiche pas le montant agrégé.
- [ ] TODO hors périmètre:
  - décider si la fiche client BO legacy `Offres` doit masquer ou distinguer les lignes déléguées.

## PATCH Étape 2A — BO backfill offre réseau dédiée (2026-03-08)
- [x] Module BO réseau renforcé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Actions ajoutées:
  - auto-ensure de l’offre réseau dédiée à l’ouverture de la page contrat réseau siège.
  - bouton BO `Créer / rattraper offre réseau dédiée`.
  - action script `mode=backfill_siege` avec retour `backfill_ok`.
- [x] Vérification:
  - `php -l` OK sur les fichiers BO `reseau_contrats`.

## PATCH Étape 2 — Contrat cadre réseau BO (2026-03-06)
- [x] Nouveau module BO dédié (pilotage siège):
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_module_parametres.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - migration: `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Entrée fiche client siège:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php` (CTA `Gestion contrat réseau / délégation`).
- [x] UX de transition clarifiée:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`
  - champ délégation étiqueté legacy pour orienter vers le module métier dédié.
- [ ] TODO post-lot (`www`):
  - compléter la visibilité BO du journal d’actions réseau (liste/filtre dédié).
  - intégrer un contrôle explicite sur la résolution d’offre déléguée au moment de l’activation (si aucune ligne n’existe).

## AUDIT #4 — Delegation write path (id_client_delegation) (2026-03-06)
- [x] Write path confirmé côté BO:
  - le module `offres_clients` expose `id_client_delegation`:
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:39`
  - ajout/modification activés sur ce module:
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:299`
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:300`
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:301`
  - exécution via script master générique:
    - `www/web/bo/master/bo_master_script.php:15`
    - `www/web/bo/master/bo_master_script.php:20`
    - `global/web/lib/core/lib_core_module_functions.php:736`
- [x] Résultat audit:
  - pas de chemin métier dédié "déléguer offre" dans `www`; write possible via CRUD table-driven.
  - note détaillée: `notes/delegation-write-path-2026-03-06.md`
- [x] Next steps Lot 2 (`www`) réalisés:
  - ajout d’un entrypoint BO explicite via module `ecommerce/reseau_contrats`.
  - restriction du pilotage réseau par CRUD brut (module dédié + verrouillage générique côté socle).
- [ ] Next step restant:
  - afficher un audit trail métier BO plus complet (vue dédiée des actions historiques).

## AUDIT #2 — Offer lifecycle hooks (OFF/ON) (2026-03-06)
- [x] Hooks OFF confirmés (scope `www`):
  - cron principal d’inactivation:
    - impayé > 30 jours: `www/web/bo/cron_routine_bdd_maj.php:47` (`id_etat=10`)
    - expiration PAK: `www/web/bo/cron_routine_bdd_maj.php:73` (`id_etat=4`)
    - expiration ABN one-shot: `www/web/bo/cron_routine_bdd_maj.php:100` (`id_etat=4`)
    - expiration ABN sans engagement: `www/web/bo/cron_routine_bdd_maj.php:140` (`id_etat=4`)
  - BO manuel:
    - module `offres_clients` expose `id_etat` et autorise `modifier/supprimer`:
      - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:15`
      - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:299`
    - update SQL générique:
      - `global/web/lib/core/lib_core_module_functions.php:736`
    - delete SQL générique:
      - `global/web/lib/core/lib_core_module_functions.php:833`
- [x] Cartographie consolidée:
  - voir note: `notes/offer-lifecycle-hooks-2026-03-06.md`
- [ ] TODO Lot 3B (`www`):
  - ajouter un point de hook post-update/post-delete dans le cron `cron_routine_bdd_maj.php` pour déclencher la cascade délégation après chaque OFF.
  - cadrer le mode manuel BO: forcer une route dédiée (ou hook table-aware) pour ne pas rater la cascade quand `id_etat` est changé depuis le CRUD générique.
  - distinguer les causes OFF dans le cron (`UNPAID_TIMEOUT`, `EXPIRED_PAK`, `EXPIRED_ABN_ONESHOT`, `EXPIRED_ABN_NO_COMMITMENT`) pour propagation et audit.

## AUDIT #1 — Offer resolution (source of truth) (2026-03-06)
- [x] Constat scope `www`:
  - aucun resolver principal "offre active" défini dans ce repo.
  - usages observés: reporting/BO via `app_ecommerce_offres_client_get_liste(...)` (`www/web/bo/www/modules/entites/clients/bo_clients_list.php:61`, `www/web/bo/www/modules/syntheses/resumes/bo_resumes_list.php:1315`).
  - gestion des dates portée surtout par cron de transition d’état (`www/web/bo/cron_routine_bdd_maj.php:62`, `:73`, `:89`, `:100`).
- [ ] TODO Lot 1 (`www`):
  - éviter d’ajouter de nouvelles règles de résolution locale côté BO.
  - documenter explicitement que la source de vérité runtime réside dans `global`.

## AUDIT Réseau / Affiliation / Branding / Contenus partagés (2026-03-06)
- [x] Cartographie confirmée (preuves code):
  - Réécriture publique lien affiliation réseau:
    - `www/web/.htaccess:118` (`/utm/reseau/{seo_slug}` -> `/fo/fo.php?utm_source=reseau&utm_campaign=affiliation&utm_term=...`)
    - `www/web/.htaccess:121` (variante avec code remise)
  - Passage vers `pro`:
    - `www/web/fo/fo.php:64`
    - `www/web/fo/fo.php:67`
    - `www/web/fo/fo.php:71`
  - Flag réseau dans BO:
    - `www/web/bo/www/modules/entites/clients/bo_module_parametres.php:96` (`flag_client_reseau_siege`)
    - `www/web/bo/www/modules/entites/clients/bo_module_parametres.php:107` (`id_client_reseau`)
  - Lien d’affiliation affiché en BO:
    - `www/web/bo/www/modules/entites/clients/bo_clients_list.php:144`
- [x] Existant confirmé:
  - Le BO permet de marquer un client “tête de réseau” et de renseigner l’appartenance réseau (champs `clients.flag_client_reseau_siege` / `clients.id_client_reseau`).
  - Le lien d’affiliation affiché est de type slug (`/utm/reseau/{seo_slug}`), sans token dédié.
  - La landing publique `www` consomme les paramètres UTM puis redirige vers `pro` avec ces mêmes paramètres.
- [ ] Manques identifiés (scope `www`):
  - Pas de génération/rotation/révocation de token d’affiliation réseau dans BO.
  - Pas de TTL/signature/HMAC spécifique au lien d’affiliation réseau.
  - Pas de journal d’audit dédié “création/rotation/révocation lien affiliation réseau”.
- [ ] Risques:
  - Lien basé sur slug prédictible.
  - Paramètres UTM manipulables côté URL.
  - Absence de mécanisme d’expiration pour le lien d’affiliation réseau.

## PATCH BO Reporting — Sessions papier dans `Jeux et joueurs` (2026-02-28)
- [x] Audit ciblé:
  - entrée: `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - constats:
    - le total `Sessions` excluait des sessions papier via un filtre “has players” sur certains chemins.
    - les ratios `joueurs/client` et `joueurs/session` utilisaient les mêmes agrégats de sessions.
- [x] Correctifs appliqués:
  - `Sessions` (table + totals + série N-1): comptage des sessions terminées et configurées, papier + numérique (toujours hors démo).
  - ajout d’un agrégat dédié `sessions numériques` (sessions avec joueurs) utilisé uniquement pour les ratios joueurs:
    - `Moy. joueurs / client`
    - `Moy. joueurs / session` (global + par jeu).
  - note UI explicite mise à jour dans le bloc `Jeux et joueurs`.
- [x] Vérification technique:
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] QA manuelle BO:
  - une session papier terminée sans joueurs doit incrémenter `Sessions` (mois + total).
  - cette session ne doit pas augmenter les ratios `joueurs/client` et `joueurs/session`.
  - une session numérique avec joueurs doit continuer d’alimenter `Joueurs` + ratios.

## PATCH BO Reporting — Démos période de référence (2026-02-28)
- [x] Audit ciblé:
  - Entrée reporting: `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - Zones impactées:
    - endpoint AJAX détail démos (`bo_facturation_pivot_saas_handle_games_demo_detail_ajax`)
    - agrégations mensuelles (`$demo_sessions`, métrique démos nouveaux inscrits)
    - section `Objectifs`
    - tableau `Visiteurs / prospects / clients`
    - libellés modal JS
- [x] Correctifs appliqués:
  - `Objectifs > Demos`: ajout des démos des nouveaux inscrits de la période de référence.
## Done (2026-03-23)
- [x] BO clients: ajout d'une action `Generer un lien EC temporaire` par contact sur la fiche client `www/web/bo/www/modules/entites/clients/bo_clients_view.php`.
- [x] BO clients: ajout du mode `generer_lien_ec_temporaire` dans `www/web/bo/www/modules/entites/clients/bo_clients_script.php`, avec verification que le contact est bien rattache au client avant generation.
- [x] BO clients: retour sur la meme fiche avec l'URL complete prete a copier, sans exposition cote front EC standard.
- [x] Verification technique:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php`

  - Tableau: renommage `Demos inscrits` -> `Démos nvx inscrits`.
  - Recalcul colonne: client inscrit dans la période ET session démo dans la période.
  - Détail modal `scope=users`: aligné sur le même filtre de période (pour cohérence clic/agrégat).
- [x] Sémantique vérifiée:
  - colonne historique conservée en volume de **sessions démo** (pas distinct inscrits).
- [x] Vérification technique:
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] QA manuelle BO:
  - ancien inscrit + démo période => non compté dans `Démos nvx inscrits`.
  - nouvel inscrit sans démo => non compté.
  - nouvel inscrit + démo période => compté.

## Done (2026-03-08)
- [x] Étape 2A fix ciblé: branchement du vrai point d’entrée BO de création/rattrapage offre réseau dédiée dans `bo_clients_script.php` au moment des modifications client avec `flag_client_reseau_siege=1`.
- [x] Étape 2A fix ciblé: module BO `reseau_contrats` enrichi d’une action explicite de sync legacy des offres déléguées et auto-sync au chargement de la fiche contrat.
- [x] 2026-03-08 — UX BO fiche client TdR: suppression du CTA d’intro `Gestion contrat réseau / délégation`; ajout du CTA `Gérer le contrat` uniquement sur la ligne d’offre `Contrat cadre réseau` (slug `contrat-cadre-reseau`) vers la même vue `?a=www&t=ecommerce&m=reseau_contrats&p=list&id_client_siege=<id>`.
- [x] 2026-03-10 — Audit runtime BO `offres_clients`: le vrai write path du passage manuel à `Terminée` reste `do_script.php -> bo_offres_clients_script.php -> mode=modifier`; fix appliqué sur la garde métier pour reconnaître aussi les lignes support legacy déjà liées au contrat réseau (`id_offre_client_contrat`).
- [x] 2026-03-10 — Audit runtime BO `offres_clients`: le `id_etat=4` du save était réécrit par le refresh générique post-`module_modifier(...)`; bypass ciblé ajouté uniquement pour le cas explicite `offre support réseau -> Terminée`, afin de laisser le hook de clôture réelle s’exécuter.
- [x] 2026-03-11 — BO `offres_clients`: abandon du patch opportuniste dans le form générique; ajout d’un renderer dédié `Abonnement réseau` via hook minimal dans `bo_master_form.php`, et retour du form classique `offres_clients` au comportement historique hors contexte réseau.
- [x] 2026-03-11 — BO `offres_clients` view: ajout d’un hook minimal `bo_module_view_flags.php` pour masquer le bloc historique `Informations` uniquement sur le support canonique `Abonnement réseau`.
- [x] 2026-03-11 — BO réseau: `date_debut` et `date_facturation_debut` sont désormais transmises par `bo_offres_clients_script.php` et persistées explicitement par `app_ecommerce_reseau_abonnement_bo_sync_offer_client(...)`, ce qui réaligne l’affichage `Début` / `Début fact.` sur la fiche client TdR.
- [x] 2026-03-11 — BO `offres_clients` view: ajout d’un hook minimal `bo_module_view_top.php` pour rendre le bloc `Abonnement réseau` en haut de la colonne de gauche avant `Caractéristiques`, avec affichage lecture seule de `date_debut` et `date_facturation_debut`.
- 2026-03-09: bo/reseau_contrats
  - faire retourner `activate_contract` sur un état `en attente de paiement` au lieu d'une activation commerciale immédiate;
  - exposer le lien Stripe de l'offre réseau support dans l'écran BO quand l'offre reste `pending_payment`.

## Done (2026-03-13)
- [x] Routine BO `cron_routine_bdd_maj.php`: ajout de l'execution des remplacements differes d'offres deleguees hors cadre. La routine scanne les cibles planifiees (`id_etat=2` + marqueur de remplacement differe), puis active la cible apres terminaison effective de la source.

## Done (2026-03-20)
- [x] BO reporting jeux: extraction du bloc `Reporting jeux (agregats)` hors de `www/web/bo/cron_routine_bdd_maj.php` vers un helper reutilisable `www/web/bo/includes/bo_reporting_games_aggregates.php`.
- [x] BO reporting jeux: ajout du cron dedie `www/web/bo/cron_reporting_games_aggregates.php` pour permettre un lancement isole des agregats jeux sans executer toute la routine BDD.
- [x] BO `facturation_pivot`: branchement preferentiel des sessions mensuelles sur `reporting_games_sessions_monthly` et des sessions numeriques sur `reporting_games_sessions_detail`.
- [x] BO `facturation_pivot`: branchement preferentiel de la serie N-1 jeux sur `reporting_games_sessions_monthly` quand le cache cron est disponible.
- [x] Portage separe sur `main` du meme correctif BO reporting jeux, sans merge `develop` vers `main`, pour un test/prod isole.
- [x] Verification technique:
  - `php -l www/web/bo/includes/bo_reporting_games_aggregates.php`
  - `php -l www/web/bo/cron_reporting_games_aggregates.php`
  - `php -l www/web/bo/cron_routine_bdd_maj.php`
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
