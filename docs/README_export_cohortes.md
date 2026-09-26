# Export cohortes Cotton 2025-09 a 2026-05

## Livrables

- `cotton_cohortes_reporting_2025_09_2026_05_READONLY.sql`
- `README_export_cohortes.md`

Le produit n'a pas ete modifie. Les fichiers ajoutes sont des livrables d'audit/export.

## Execution phpMyAdmin

1. Ouvrir phpMyAdmin sur la base Cotton concernee.
2. Coller le contenu de `cotton_cohortes_reporting_2025_09_2026_05_READONLY.sql` dans l'onglet SQL.
3. Lancer les requetes une par une si phpMyAdmin limite les exports multi-resultats.
4. Exporter en CSV les resultats des blocs utiles :
   - `B export client mois` pour le dataset client x mois.
   - `C agregation cohortes` pour la retention par cohorte.
   - `D usage entree et retention` pour l'analyse usage -> retention.
   - `E segment` pour l'analyse par segment.
   - `F rapprochement mai 2026` pour le controle face au reporting mai 2026.
   - `H diagnostic nouveaux clients reporting-like vs repere 74` pour relire les clients expliquant l'ecart 85 vs 74.
   - `G feedbacks et churn qualitatif` pour l'analyse qualitative feedback/resiliation.
   - `J essais gratuits CHR/reseaux et conversion facture` pour analyser le tunnel essai -> usage -> facture -> pause et rapprocher chaque ligne de la regle BO.
   - `J2 synthese essais gratuits CHR/reseaux` pour comparer l'audit large et les lignes incluses dans le reporting BO.
   - `J3 rapprochement essais gratuits BO vs audit large` pour relire les volumes mensuels attendus du BO et les motifs d'ecart.

## Verification lecture seule

Le fichier SQL ne contient que des instructions `SELECT` et des commentaires. Controle possible avant execution :

```powershell
Select-String -Path cotton_cohortes_reporting_2025_09_2026_05_READONLY.sql -Pattern "\b(CREATE|DROP|ALTER|INSERT|UPDATE|DELETE|TRUNCATE|REPLACE|WITH|CALL|SET|LOCK|LOAD)\b|INTO\s+OUTFILE|INTO\s+DUMPFILE"
```

La commande doit ne rien retourner.

## Hypotheses metier retenues

- Periode d'observation : septembre 2025 a mai 2026 inclus.
- Nouveau client reporting-like : premiere facture reelle du client, pas premiere offre theorique.
- Premiere facture reelle : `ecommerce_commandes.numero_facture <> ''`, `ecommerce_commandes.total_ht > 0`, date normalisee `date_facture` sinon `annee/mois`.
- Premiere offre payante theorique : premier `ecommerce_offres_to_clients.date_debut` avec `flag_offert = 0` et `prix_ht > 0`; conservee pour diagnostic seulement.
- Client actif payant historique mensuel : offre couvrant le mois par `date_debut/date_fin`, non offerte, prix HT positif, et statut courant compatible historique `id_etat IN (3,4)`.
- Client actif payant courant mai : offre couvrant mai 2026 avec `id_etat = 3`, non offerte, prix HT positif.
- MRR HT : `prix_ht` si periodicite mensuelle, `prix_ht / 12` si `id_paiement_frequence = 2` annuel.
- Churn logo historique : client payant actif historique au mois precedent et non actif payant historique au mois courant.
- Churn valeur historique : baisse positive entre MRR historique du mois precedent et MRR historique du mois courant.
- Reprise CSO : client deja facture avant le mois observe, redevenant actif apres un mois precedent sans MRR historique.
- Expansion CSO : hausse de MRR historique pour un client deja facture avant le mois observe; ce cas ne compte pas comme nouveau client.
- Remises : lecture du snapshot de l'offre client (`remise_nom`, `remise_pourcentage`, `prix_ht`).
- Gratuit/test : `flag_offert = 1`, `prix_ht <= 0`, ou `trial_period_days > 0`.
- Reseau/affilie : detecte via `clients.flag_client_reseau_siege`, `clients.id_client_reseau`, ou champs reseau des offres client.
- Sessions/joueurs : lecture prioritaire des agregats `reporting_games_sessions_monthly` et `reporting_games_players_monthly`.
- Usage brut : comptage direct dans `championnats_sessions`, sans appliquer les filtres reporting.
- Usage significatif reporting : comptage des caches `reporting_games_sessions_monthly` / `reporting_games_players_monthly`, qui reprennent les filtres du cron BO.

## Colonnes usage ajoutees

Dans le bloc `B export client mois` :

- `mois_premiere_offre_payante_theorique` et `date_premiere_offre_payante` : entree theorique par premiere offre payante.
- `mois_premiere_facture_reelle` et `date_premiere_facture_reelle` : entree reporting-like par premiere facture reelle.
- `statut_offre_courant` : libelle du statut courant de l'offre de reference, pour diagnostic.
- `actif_payant_historique_mois` : activite historique reconstruite par dates et `id_etat IN (3,4)`.
- `actif_payant_courant_mai` : activite courante fin mai avec `id_etat = 3`.
- `nouveau_client_offre_theorique_mois` : entree par premiere offre payante theorique.
- `nouveau_client_reporting_like_mois` : entree par premiere facture reelle.
- `reprise_apres_pause_mois` : retour actif apres pause pour un client deja facture.
- `cso_expansion_mois` : hausse de MRR historique d'un client deja facture avant le mois.
- `nb_sessions_brutes_mois` : toutes les sessions `championnats_sessions` du client sur le mois.
- `nb_sessions_significatives_reporting_mois` : sessions retenues par le reporting BO via `reporting_games_sessions_monthly`.
- `nb_sessions_reelles_mois` : sessions brutes avec `flag_session_demo = 0`.
- `nb_sessions_demo_mois` : sessions brutes avec `flag_session_demo = 1`.
- `nb_sessions_sans_joueur_mois` : sessions brutes dont le total joueurs calcule vaut 0.
- `nb_sessions_incompletes_mois` : sessions brutes avec `flag_configuration_complete <> 1`.
- `nb_sessions_test_ou_techniques_mois` : detection indicative par libelles `nom`, `nom_court`, `code_session` contenant `test` ou `tech`.
- `nb_joueurs_bruts_mois` : somme directe joueurs equipes + bingo + blindtest + quiz par session brute.
- `nb_joueurs_significatifs_reporting_mois` : joueurs retenus par `reporting_games_players_monthly`.
- `taux_sessions_significatives_sur_brut` : sessions significatives / sessions brutes.
- `commentaire_usage_diagnostic` : signaux utiles si brut sans significatif, demos, sans joueur, incomplet, test/technique.

Dans le bloc `C agregation cohortes`, les cohortes sont basees sur `mois_premiere_facture_reelle` et la retention utilise l'actif payant historique :

- ajout des moyennes `sessions_brutes_moyennes_M0/M1/M2`;
- ajout des moyennes `sessions_significatives_moyennes_M0/M1/M2`;
- ajout des parts `part_clients_avec_session_significative_M0/M1/M2`.
- correction V4 : `mrr_initial_cohorte` est additionne une seule fois par client, sur la ligne M0, et non plus multiplie par le nombre de mois observables;
- correction V4 : `retention_mrr_M1/M2/M3/M6` divise le MRR restant par le MRR initial corrige;
- correction V4 : les horizons non observables dans la periode septembre 2025 -> mai 2026 retournent `NULL`, pas `0`, pour les clients actifs, retentions logo, MRR restant et retentions MRR.

Dans le bloc `D usage entree et retention`, les groupes sont bases sur l'usage du mois de premiere facture reelle, avec distinction du brut :

- `0 session brute`;
- `brut > 0 mais 0 session significative`;
- `1 session significative`;
- `2 a 3 sessions significatives`;
- `4+ sessions significatives`.

Correction V5 du bloc `D usage entree et retention` :

- `clients_total_groupe` : tous les clients du groupe d'usage;
- `clients_observables_M1` et `clients_observables_M3` : clients dont l'horizon M+1 ou M+3 est observable dans la periode;
- `clients_actifs_M1` et `clients_actifs_M3` : clients observables encore actifs a l'horizon;
- `mrr_initial_total_groupe` : MRR initial total du groupe;
- `mrr_initial_observable_M1` et `mrr_initial_observable_M3` : MRR initial limite aux clients observables;
- `mrr_restant_M1` et `mrr_restant_M3` : MRR actif restant aux horizons observables;
- `retention_logo_M1/M3` : actifs / observables, et `NULL` si aucun client observable;
- `retention_mrr_M1/M3` : MRR restant / MRR initial observable, et `NULL` si le MRR initial observable vaut 0 ou est absent.

Le bloc D mesure l'association entre l'usage au mois d'entree et la retention observee. Les horizons non observables sont exclus du denominateur; les petits effectifs imposent une lecture prudente, et le volume de sessions n'est pas necessairement un predicteur lineaire.

Dans le bloc `F rapprochement mai 2026` :

- `sessions_brutes` et `joueurs_bruts` viennent du calcul brut direct;
- `sessions_significatives_reporting_periode_global` et `joueurs_significatifs_reporting_periode_global` viennent directement des caches reporting sur la periode de la ligne F;
- la ligne `mai_2026_courant` compare seulement les KPI courants mensuels disposant d'un repere mensuel clair (`clients_actifs_courant_mai_reporting`, `MRR_courant_mai_reporting_approx`);
- la ligne `cumul_2025_09_2026_05` compare les reperes `74` nouveaux clients, `2 956` sessions et `34 445` joueurs au cumul exercice, sauf preuve contraire issue du reporting;
- `nouveaux_clients_offre_theorique_cumul` est expose pour expliquer l'ecart V2;
- `nouveaux_clients_reporting_like_cumul` est la mesure a comparer au repere `74`;
- `reprises_cso_cumul` et `expansion_mrr_cumul` isolent les retours/hausses de clients deja factures.
- la table `user_feedback_events` est recente et probablement partielle sur septembre 2025 -> mai 2026; elle qualifie les causes possibles de churn, sans recalculer le reporting financier.

## Perimetres sessions et joueurs

Les exports ne portent pas tous sur le meme perimetre :

- bloc B : client x mois, uniquement pour les clients ayant une premiere facture reelle deja intervenue au mois observe;
- bloc E : segment, perimetre des clients retenus par le segment (`sessions_significatives_reporting_segment_perimetre`, `joueurs_significatifs_reporting_segment_perimetre`);
- bloc F : controle global de la periode, lecture directe des caches `reporting_games_sessions_monthly` et `reporting_games_players_monthly` sans restriction au perimetre cohortes ou segments.

Les ecarts constates entre B, E et F peuvent donc etre normaux si les exports ne sont pas additionnes sur le meme champ de population. Pour verifier les caches globaux, utiliser F. Pour analyser les cohortes facturees, utiliser B/C/D. Pour comparer par segment, utiliser E.

## Bloc H diagnostic

Le bloc `H diagnostic nouveaux clients reporting-like vs repere 74` liste les clients dont la premiere facture reelle est detectee entre septembre 2025 et mai 2026.

Colonnes principales :

- `id_client`, `nom_client`;
- `mois_premiere_facture_reelle`, `date_premiere_facture_reelle`;
- `numero_facture`, `total_ht_facture_initiale`, `id_commande`, `id_etat_commande`;
- `id_offre_client`, `id_offre_type`, `typologie_offre`;
- `id_etat_client`, `id_etat_offre`, `flag_offert`, `prix_ht`, `id_paiement_frequence`;
- segment detecte et indicateurs reseau/delegation;
- `commentaire_diagnostic` pour identifier les cas potentiellement excluables du reporting officiel.

Interpretation :

- `74` reste le repere reporting officiel communique;
- `85` est la lecture audit par premiere facture reelle (`numero_facture <> ''`, `total_ht > 0`);
- l'ecart de 11 clients doit etre arbitre apres revue du bloc H, sans forcer le SQL a 74 sans preuve metier supplementaire.

## Bloc J — essais gratuits CHR/reseaux

Les blocs `B`, `C`, `D` et `H` mesurent surtout l'entree par premiere facture reelle. Le bloc `J essais gratuits CHR/reseaux et conversion facture` mesure l'entree plus amont dans le tunnel d'abonnement, avant facture. Pour reproduire le volume BO officiel, J/J2/J3 ne filtrent pas uniquement les comptes CHR/reseaux; ils exposent `est_chr`, `est_reseau_affilie` et `perimetre_chr_reseau` pour isoler ensuite CHR direct, reseau/affilie et autres comptes.

Le reporting BO `Visiteurs / prospects / clients` reste la source officielle de volume pour la colonne `Essais gratuits`. Le volume officiel communique pour septembre 2025 -> mai 2026 est `27` essais gratuits : septembre `0`, octobre `0`, novembre `0`, decembre `3`, janvier `3`, fevrier `6`, mars `7`, avril `6`, mai `2`.

Risque analytique vise :

- les "nouveaux clients" du reporting sont lus comme clients factures (`numero_facture <> ''`, `total_ht > 0`);
- le churn ou la pause peuvent inclure des offres d'abonnement en essai gratuit non facturees;
- comparer directement `74` nouveaux factures et `69` en pause peut donc melanger deux perimetres : entrees facturees d'un cote, offres/trials en pause de l'autre.

Regle BO officielle auditee :

- preuve code : `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`, bloc `$sql_trial_clients`, compte les essais via `ecommerce_offres_to_clients`, `ecommerce_offres`, `clients`;
- inclusion BO : `eo.id_offre_type = 2`, `eotc.id_etat IN (3,4)`, `eotc.flag_offert = 0`, `eotc.prix_ht > 0`, `eotc.trial_period_days > 0`, `eotc.date_debut` dans la periode, client non archive, et absence de facture le meme jour que `date_debut`;
- periode mensuelle : `DATE_FORMAT(eotc.date_debut, '%Y-%m')`, puis dedoublonnage BO par client et par mois dans le tableau;
- fin affichee par le BO : `DATE_ADD(eotc.date_debut, INTERVAL 15 DAY)`, avec `trial_period_days > 0` comme signal d'inclusion;
- le bloc J garde une detection d'audit large : `trial_period_days > 0` prioritaire; `flag_offert = 1` et `prix_ht <= 0` restent des indicateurs secondaires;
- les cas gratuit/offert/prix nul peuvent inclure gratuit, test ou interne : ils sont marques dans `commentaire_detection_essai` et doivent etre relus via `typologie_offre`, `id_etat_offre`, `statut_offre_courant`, `flag_offert`, `prix_ht`, `trial_period_days` et les dates.

Colonnes principales du bloc J :

- identification et segment : client, offre, type d'offre, etats client/offre, `segment_detecte`, `est_chr`, `est_reseau_affilie`;
- essai : `date_debut_essai`, `mois_debut_essai`, `date_fin_offre`, `date_fin_essai_calculee`, `etat_temporel_essai_selon_dates`, `trial_period_days`, `flag_offert`, `prix_ht`, `commentaire_detection_essai`;
- rapprochement BO : `inclus_reporting_bo_essai_gratuit` et `motif_ecart_reporting_bo`;
- facture : `converti_facture_reelle`, facture reelle apres debut d'essai, numero, total HT, commande, delai avant facture;
- tunnel : essai converti, non converti, encore en cours, pause avant facture, pause apres facture, reprise CSO;
- usage pendant essai : sessions brutes, sessions significatives, sessions demo, sans joueur, incompletes, joueurs bruts/significatifs, premiere session significative;
- pause/retour : date de pause approximative, delais, retour payant detecte apres pause.

Le bloc `J2 synthese essais gratuits CHR/reseaux` agrege par `mois_debut_essai`, segment, perimetre `CHR direct` / `reseau / affilie` / `autre`, et type d'essai (`trial explicite`, `gratuit-offert`, `prix nul`, `ambigu`). Il donne notamment `essais_detectes_audit_large`, `essais_inclus_reporting_bo`, `ecart_vs_reporting_bo`, conversions facture, taux de conversion sur le perimetre BO, activation usage significatif sur le perimetre BO, pauses avant/apres facture et motifs d'ecart.

Le bloc `J3 rapprochement essais gratuits BO vs audit large` liste les volumes officiels attendus mois par mois, le volume reproduit par la regle SQL BO, le volume d'audit large et les principaux motifs hors BO. Si `essais_reproduits_regle_bo` ne vaut pas `27` en total, relire les lignes J dont `motif_ecart_reporting_bo` vaut `hors_bo_autre_a_revoir` ou les mois ou `ecart_reproduction_bo` n'est pas nul.

Controles phpMyAdmin recommandes :

1. Verifier dans J3 que `essais_reproduits_regle_bo` se rapproche du volume officiel `27`.
2. Verifier le nombre d'essais CHR/reseaux detectes avec `J2.essais_detectes_audit_large`, puis ouvrir J pour relire les lignes.
3. Verifier combien sont inclus dans la regle BO avec `J2.essais_inclus_reporting_bo` et `J.inclus_reporting_bo_essai_gratuit`.
4. Verifier les motifs hors BO via `J.motif_ecart_reporting_bo` et les colonnes de ventilation de J2/J3.
5. Verifier combien ont une facture reelle apres essai avec `J2.essais_convertis_facture` et les colonnes facture de J.
6. Verifier combien ont au moins une session significative pendant essai avec `J2.essais_avec_session_significative`.
7. Croiser `CHR direct` vs `reseau / affilie` via `J2.perimetre_chr_reseau` et comparer `taux_conversion_facture_sur_bo` / `taux_activation_session_significative_sur_bo`.

Limites d'interpretation du bloc J :

- J sert a analyser le tunnel trial, pas a remplacer le reporting financier.
- Le volume officiel a retenir pour `Essais gratuits` reste le BO; J/J2/J3 servent a rapprocher ce volume avec une detection plus large.
- L'etat `en cours` / `termine` est qualifie par les dates de debut/fin d'offre ou la fin calculee de l'essai, pas par la presence d'une facture.
- La facture sert a mesurer la conversion premiere facture reelle (`numero_facture <> ''`, `total_ht > 0`).
- Les nouveaux clients restent definis par la premiere facture reelle; les essais gratuits ne remplacent pas le reporting financier ni le churn facture.
- Les offres `flag_offert = 1` ou `prix_ht <= 0` ne sont pas automatiquement de vrais essais commerciaux.
- La pause/churn est une approximation : `date_fin` ou `id_etat = 4` de l'offre, puis detection d'un retour par offre payante ulterieure.
- L'usage significatif vient de `reporting_games_sessions_detail`; l'usage brut vient de `championnats_sessions`.
- Le rapprochement usage est fait au client et aux dates de l'essai; il n'impose pas que chaque session soit rattachee a l'offre d'essai.

## Feedbacks et resiliations Stripe

Table detectee : `user_feedback_events`.

Schema local : `pro/sql/user_feedback_events_phpmyadmin.sql`.

Colonnes utilisees :

- identifiants et dates : `id_feedback`, `id_client`, `id_user`, `id_session`, `created_at`, `resolved_at`;
- contexte/source : `context_key`, `display_surface`, `page_url`, `user_agent`, `internal_status`, `internal_note`;
- contenu qualitatif : `rating_value`, `rating_label`, `comment`, `tags_json`.

Conventions retenues dans le SQL :

- feedback espace client : `context_key <> 'stripe_subscription_cancellation'`;
- feedback negatif : `rating_value IN ('no', 'improve')`;
- resiliation Stripe : `context_key = 'stripe_subscription_cancellation'` et `display_surface = 'stripe_billing_portal'`;
- raison Stripe : `rating_value` / `rating_label`;
- commentaire Stripe : `comment`;
- date effective Stripe : extraction indicative de `cancellation_effective_at` dans `tags_json`, sinon `created_at`;
- lien offre/client Stripe : `id_offre_client`, `id_client_payeur`, `id_client_delegation`, `stripe_subscription_id` sont dans `tags_json`, pas dans des colonnes dediees.

Colonnes ajoutees au bloc `B export client mois` :

- `nb_feedbacks_mois` et `nb_feedbacks_negatifs_mois`;
- `dernier_feedback_date`, `dernier_feedback_type`, `dernier_feedback_note`, `dernier_feedback_categorie`, `dernier_feedback_message`;
- `raison_resiliation_stripe`, `date_raison_resiliation_stripe`, `commentaire_resiliation_stripe`;
- `feedback_avant_churn_30j`, `feedback_avant_churn_60j`;
- `raison_churn_qualitative`, `commentaire_feedback_diagnostic`.

Bloc `G feedbacks et churn qualitatif` :

- compte les clients avec feedback;
- isole les clients churnes avec feedback avant churn;
- repartit les raisons Stripe et categories feedback;
- classe les resiliations Stripe par cycle client (`client_nouveau_reporting_like`, `reprise_cso_detectee`, `client_ancien_deja_facture`, `cycle_inconnu`);
- compare retention M+1/M+3 avec feedback vs sans feedback;
- compare churn logo des feedbacks negatifs vs autres;
- compare usage moyen avec feedback vs sans feedback;
- liste les principaux messages/categories a relire manuellement.

Limites d'interpretation :

- `user_feedback_events` est une table recente, referencee dans le HANDOFF 2026-05-22; elle ne couvre probablement pas tout l'historique septembre 2025 -> mai 2026.
- Les resiliations Stripe sans feedback explicite peuvent etre journalisees avec `rating_value = 'cancellation_requested'`.
- Les resiliations historiques hors Stripe ou hors backfill ne sont pas garanties.
- Les categories feedback espace client ne forment pas un referentiel stable; le SQL expose `context_key`, `rating_value`, `rating_label` et `comment` pour revue prudente.
- Les donnees qualitatives servent a expliquer des churns possibles, pas a modifier les KPI financiers.

## Limites et ambiguites

- Les definitions exactes "nouveau client", "client actif", "MRR", "churn valeur", "impayes" ne sont pas trouvees comme contrat KPI unique dans la documentation ouverte. La V3 applique la clarification metier fournie et les conventions observees dans le pivot facturation.
- Les impayes ne sont pas integres au MRR, faute de convention stable detectee reliant etat de commande/facture et etat d'offre pour l'exclusion MRR.
- Les offres terminees (`id_etat = 4` observe dans le code) sont incluses dans l'activite historique quand les dates couvrent le mois; elles ne comptent pas dans le parc courant mai, qui reste en `id_etat = 3`.
- Les factures reelles sont identifiees par `numero_facture <> ''` et `total_ht > 0`; les statuts de commande ne sont pas ajoutes au filtre faute de preuve plus stricte que le pivot SaaS les impose systematiquement.
- Les commandes sans numero de facture, devis/paniers ou montants nuls ne servent pas a definir un nouveau client reporting-like.
- Les sessions et joueurs dependent de la fraicheur des caches `reporting_games_*`.
- Les compteurs bruts peuvent inclure demos, sessions sans joueur, sessions incompletes et clients archives; ils servent a expliquer l'ecart avec le reporting, pas a remplacer les KPI reporting.
- La detection test/technique est seulement lexicale (`test` / `tech` dans les libelles disponibles). Aucun champ canon dedie n'a ete trouve dans `championnats_sessions`.
- Le lien exact usage -> offre n'est pas fige dans `reporting_games_sessions_detail`; le rapprochement est client/mois, pas offre/session.
- Les segments sont derives des referentiels clients et flags reseau/evenement/restauration. Si les libelles de referentiel different, verifier l'export `A3 colonnes utiles reperes` et les donnees de referentiel.
- Pour les essais gratuits, la duree d'observation utilise `trial_period_days` quand il est renseigne, sinon `date_fin` si disponible, sinon la fin de periode d'audit au 31 mai 2026. Aucun delai fixe de 15 jours n'est force sans preuve.

## Preuves documentation

- `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md`, section `Règle preuve d’abord`: obligation de citer URL raw + heading, sinon "non trouve dans la documentation".
- `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md`, section `Discipline de génération`: consulter le journal AI Studio avant patch evolutif.
- `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt`, section `DB schema`: expose `canon/data/schema/OVERVIEW.md`, `MAP.md`, `DDL.sql`.
- `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md`, section `Update triggers (mapping)`: changements offres/facturation reseau lies a `global/web/app/modules/ecommerce/app_ecommerce_functions.php`, `pro/web/ec/modules/compte/offres/**`, `www/web/bo/www/modules/ecommerce/reseau_contrats/**`, `www/web/bo/www/modules/ecommerce/offres_clients/**`.
- `https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation/client/0_ROADMAP_journal_travaux.md&mode=raw&token=C4BOQcmxkXAT0JfWajhb`, section `Travaux Effectués`: fichiers hors workspace local a surveiller avant audit, notamment `global/ai_studio/...`, `global/global_librairies.php`, `global/app/modules/ecommerce/app_ecommerce_functions.php`.
- `documentation/canon/data/games-reporting.md`, section `Tables`: les agregats `reporting_games_sessions_monthly`, `reporting_games_players_monthly`, `reporting_games_players_by_type_monthly` et `reporting_games_sessions_detail`.
- `documentation/canon/data/games-reporting.md`, section `Règle joueurs (par session)`: `players_count` est l'addition des sources equipes, bingo, blindtest, quiz.

## Audit local

- `documentation/canon/data/schema/OVERVIEW.md`: base transverse, dump structure-only, domaines CRM/ecommerce/reporting.
- `documentation/canon/data/schema/MAP.md`: FKs logiques clients, ecommerce, championnats, reporting.
- `documentation/canon/data/schema/DDL.sql`:
  - `clients` autour de la ligne 513 : segment/canal/reseau/date client.
  - `ecommerce_commandes` autour de la ligne 1113 : commandes/factures, etats, dates, totaux HT/TTC.
  - `ecommerce_commandes_lignes` autour de la ligne 1217 : lignes facture, prix/remises/totaux.
  - `ecommerce_offres_to_clients` autour de la ligne 1431 : client, offre, periodicite, etat, dates, prix HT, remise, gratuit, reseau.
  - `referentiels_clients_typologies`, `referentiels_clients_acquisitions_canaux`, `referentiels_offres_clients_etats`, `referentiels_paiements_frequences` autour des lignes 2874-3279.
  - `reporting_games_sessions_monthly` et `reporting_games_players_monthly` autour des lignes 3591-3620.
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`:
  - ligne 122 et 2072 : creation d'offre en etat `2` annote "En attente".
  - ligne 2253 : validation d'offre qui passe `id_etat = 3`.
  - ligne 2497 : commentaire indiquant offre active `id_etat = 3`, non offerte, date de fin future.
  - lignes 2972-2988 : offre support reseau active la plus recente, `id_etat = 3` et date de fin non depassee.
  - lignes 3953-3992 : periodicite, suffixes `/ mois` et `/ an`.
  - lignes 10911+ : remise volume reseau.
  - ligne 14611 : filtre historique `(id_etat=3 OR id_etat=4) AND flag_offert=0`.
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_functions.php`:
  - lignes 39-40 : offres de test/trial actives non offertes.
  - ligne 66 : resiliation regardant `id_etat IN(3,4)`.
  - lignes 99 et 273-320 : detection et affichage de remises.
- `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php`:
  - lignes 144-188 : conditions des sessions detaillees, client non archive, presence de joueurs.
  - lignes 155-181 : calcul `players_count`.
  - lignes 237-251 : agregation sessions mensuelles.
  - lignes 277-330 : agregation joueurs mensuels.
- Definition exacte des sessions retenues dans le reporting mai 2026 : `flag_session_demo=0`, `flag_configuration_complete=1`, presence d'au moins un joueur, session terminee selon jeu (`phase_courante >= 4` pour Bingo, `game_status = 3` pour Blind Test et Quiz), et client non archive (`clients.id_etat <> 4` ou NULL). Source : `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php`, lignes 144-188 et 237-251.
- `www/web/bo/www/modules/syntheses/facturation_pivot/facturation_pivot_factures.php`:
  - ligne 27 : filtre pivot factures `ec.numero_facture<>''`.
  - lignes 75-85 : lecture `ec.total_ht`, `ec.total_ttc`, `ec.id_client`, offre et periodicite.
  - lignes 101-108 : calcul MRR facture par `total_ht / 12` pour annuel, sinon `total_ht`.
- `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`:
  - lignes 315-317 : premiere facture lue par date facture normalisee.
  - lignes 372-378 : date facture normalisee et filtre `ec.numero_facture<>''`.
- `www/web/bo/www/modules/syntheses/resumes/bo_resumes_list.php`:
  - lignes 190-191 : CA HT mensuel base sur `ec.numero_facture<>''` et date facture normalisee.
  - lignes 259-260 du HANDOFF : KPI `CA HT mensuel` somme les factures editees du mois courant.
- `pro/sql/user_feedback_events_phpmyadmin.sql`:
  - ligne 5 : table `user_feedback_events`.
  - colonnes `id_client`, `id_user`, `id_session`, `context_key`, `display_surface`, `rating_value`, `rating_label`, `comment`, `tags_json`, `internal_status`, `internal_note`, `created_at`, `resolved_at`.
- `pro/web/ec/modules/general/feedback/ec_feedback_submit_ajax.php`:
  - debut du fichier : endpoint AJAX espace client.
  - contextes `session_programmed_summary` et `session_finished_experience`.
  - valeurs feedback `yes`, `neutral`, `no`, `great`, `improve`, `ignored`.
  - validation session client, non demo et complete/utile pour l'experience finie.
- `pro/web/ec/modules/general/feedback/ec_feedback_lib.php`:
  - insertion dans `user_feedback_events` par `ec_feedback_event_insert`.
  - dedoublonnage par client/session/contexte.
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`:
  - mapping des raisons Stripe vers libelles lisibles.
  - capture de `cancellation_details.feedback`, `comment`, `reason`.
  - stockage dans `user_feedback_events` avec `context_key='stripe_subscription_cancellation'`.
  - enrichissement `tags_json` avec `stripe_subscription_id`, `id_offre_client`, `id_client_payeur`, `id_client_delegation`, dates de resiliation.
- `pro/web/ec/ec_webhook_stripe_handler.php`:
  - appels de capture sur `customer.subscription.updated` et `customer.subscription.deleted`.
- `global/web/assets/stripe/sdk/tools/backfill_cancellation_feedback.php`:
  - outil CLI de rattrapage Stripe, avec mode dry-run et option d'ecriture.
- `www/web/bo/www/modules/tracking/clients_feedback_events/bo_module_parametres.php` et fichiers voisins :
  - module BO lecture/liste des feedbacks, sans creation ni edition via le module.
- `documentation/HANDOFF.md`:
  - sections 2026-05-22 : table recente pour resiliations Stripe sans feedback/comment, couverture legacy non garantie, BO Feedbacks EP/Stripe.

## Rapprochement reporting mai 2026

Le bloc `F rapprochement mai 2026` separe deux niveaux de controle :

- ligne `mai_2026_courant` : clients actifs `85` et MRR environ `5,8 kEUR`, sur statut courant `id_etat = 3`;
- ligne `cumul_2025_09_2026_05` : nouveaux clients `74`, sessions environ `2 956`, joueurs environ `34 445`, sur le cumul exercice.

Le cumul expose deux lectures des nouveaux clients :

- `nouveaux_clients_offre_theorique_cumul` : premiere offre payante theorique, conservee pour expliquer l'ecart V2;
- `nouveaux_clients_reporting_like_cumul` : premiere facture reelle, lecture a comparer au repere reporting `74`.

## Controles phpMyAdmin V4

Apres execution, verifier :

- bloc F, ligne `mai_2026_courant` : `clients_actifs_courant_mai_extrait = 85` et `MRR_courant_mai_extrait` proche de `5797.26`;
- bloc F, ligne `cumul_2025_09_2026_05` : comparer `nouveaux_clients_reporting_like_cumul` au repere `74`, puis relire le bloc H;
- bloc C : pour les cohortes `2025-09`, `2025-10`, `2025-11`, `mrr_initial_cohorte` doit etre proche des agregats mensuels attendus, environ `623.06`, `1103.92`, `524.91`;
- bloc C : `clients_actifs_M6`, `retention_logo_M6`, `mrr_restant_M6`, `retention_mrr_M6` doivent etre `NULL` pour les cohortes dont M+6 depasse mai 2026, par exemple `2026-03`, `2026-04`, `2026-05`;
- bloc H : le nombre de lignes doit correspondre aux clients premiere facture reelle detectes par l'audit sur septembre 2025 -> mai 2026.

Les ecarts probables viennent de quatre zones : offres gratuites/test, offres en etat non actif mais encore visibles metier, facturation commande/facture non alignee avec l'offre active, et fraicheur des caches de reporting jeux.
