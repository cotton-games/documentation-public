-- Audit initial legacy uniquement. Lecture seule. MariaDB 10.3.
-- Date de reference FIGEE : 2026-09-08 inclus. Adapter toutes ses occurrences
-- une seule fois si la date de migration change. Aucun filtre commercial.
-- Executer 00 d'abord ; executer les autres fichiers seulement apres validation
-- des tables/colonnes. Une erreur de schema ne signifie PAS un parc vide.

-- O01 Etat de loffre REFERENCEE : ne prouve pas les droits effectifs du compte
SELECT CASE WHEN s.id_offre_client IS NULL THEN 'reference_null' WHEN s.id_offre_client=0 THEN 'reference_zero' WHEN s.id_offre_client<0 THEN 'reference_negative' WHEN o.id IS NULL THEN 'reference_positive_absente' WHEN o.id_etat=3 THEN 'reference_positive_etat_3' ELSE 'reference_positive_autre_etat' END AS classe,
COUNT(*) AS sessions,COUNT(DISTINCT s.id_client) AS clients_non_additifs
FROM prod_cotton_global_0.championnats_sessions s LEFT JOIN prod_cotton_global_0.ecommerce_offres_to_clients o ON o.id=s.id_offre_client WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08' GROUP BY classe;

-- O02 Offres liees aux clients ou explicitement referencees, actives ou non
SELECT o.id,o.id_client,o.id_client_delegation,o.id_offre,o.id_etat,o.date_debut,o.date_fin,o.id_operation_evenement,o.online,eo.id_offre_type,eo.nom,eo.seo_slug
FROM prod_cotton_global_0.ecommerce_offres_to_clients o LEFT JOIN prod_cotton_global_0.ecommerce_offres eo ON eo.id=o.id_offre
WHERE EXISTS(SELECT 1 FROM prod_cotton_global_0.championnats_sessions s WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08' AND (s.id_offre_client=o.id OR s.id_client=o.id_client OR s.id_client=o.id_client_delegation)) ORDER BY o.id;

-- O03 Comptes : etat 3 brut, pas encore calcul reseau des droits effectifs
SELECT x.classe,COUNT(*) AS clients FROM (
SELECT c.id,CASE WHEN EXISTS(SELECT 1 FROM prod_cotton_global_0.ecommerce_offres_to_clients o WHERE o.id_etat=3 AND (o.id_client=c.id OR o.id_client_delegation=c.id)) THEN 'au_moins_une_offre_liee_etat_3' ELSE 'aucune_offre_liee_etat_3' END AS classe
FROM prod_cotton_global_0.clients c WHERE EXISTS(SELECT 1 FROM prod_cotton_global_0.championnats_sessions s WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08' AND s.id_client=c.id)) x GROUP BY x.classe;

-- O04 Catalogue support reseau : toutes les correspondances, aucun choix automatique
SELECT id,nom,seo_slug,id_offre_type FROM prod_cotton_global_0.ecommerce_offres WHERE seo_slug IN ('contrat-cadre-reseau','abonnement-reseau') OR nom='Abonnement réseau';
