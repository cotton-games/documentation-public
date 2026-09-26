-- Audit initial legacy uniquement. Lecture seule. MariaDB 10.3.
-- Date de reference FIGEE : 2026-09-08 inclus. Adapter toutes ses occurrences
-- une seule fois si la date de migration change. Aucun filtre commercial.
-- Executer 00 d'abord ; executer les autres fichiers seulement apres validation
-- des tables/colonnes. Une erreur de schema ne signifie PAS un parc vide.

-- I01 Totaux officiels futurs : configuration incomplete incluse
SELECT COUNT(*) AS sessions_officielles_futures, COUNT(DISTINCT s.id_client) AS ids_clients,
SUM(CASE WHEN s.flag_configuration_complete=1 THEN 1 ELSE 0 END) AS sessions_completes,
SUM(CASE WHEN s.flag_configuration_complete=1 THEN 0 ELSE 1 END) AS sessions_a_classifier,
COUNT(DISTINCT CASE WHEN s.id_operation_evenement>0 THEN s.id_operation_evenement END) AS operations_referencees
FROM prod_cotton_global_0.championnats_sessions s WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08';

-- I02 Partitions candidates, PAS encore nombre de Hubs validables
SELECT x.categorie, COUNT(*) AS partitions_candidates, SUM(x.nb) AS sessions
FROM (SELECT s.id_client, s.date, s.id_operation_evenement,
CASE WHEN s.id_operation_evenement=0 THEN 'sans_operation' WHEN s.id_operation_evenement>0 THEN 'avec_operation' ELSE 'operation_invalide_ou_null' END AS categorie, COUNT(*) AS nb
FROM prod_cotton_global_0.championnats_sessions s WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08'
GROUP BY s.id_client,s.date,s.id_operation_evenement) x GROUP BY x.categorie;

-- I03 Sessions par partition et signaux de contexte
SELECT s.id_client,s.date,s.id_operation_evenement,c.id_solution_usage,c.id_typologie,
COUNT(*) AS sessions, SUM(CASE WHEN s.flag_configuration_complete=1 THEN 1 ELSE 0 END) AS completes,
COUNT(DISTINCT s.flag_session_privee) AS variantes_prive,
COUNT(DISTINCT s.online) AS variantes_publication,
COUNT(DISTINCT s.nom) AS variantes_nom
FROM prod_cotton_global_0.championnats_sessions s LEFT JOIN prod_cotton_global_0.clients c ON c.id=s.id_client
WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08' GROUP BY s.id_client,s.date,s.id_operation_evenement,c.id_solution_usage,c.id_typologie
ORDER BY s.id_client,s.date,s.id_operation_evenement;

-- I04 Dates avec plusieurs sessions : normal pour une soiree, a lire par operation
SELECT s.id_client,s.date,COUNT(*) AS sessions,COUNT(DISTINCT s.id_operation_evenement) AS operations_distinctes_zero_inclus,
SUM(CASE WHEN s.id_operation_evenement IS NULL THEN 1 ELSE 0 END) AS operations_null
FROM prod_cotton_global_0.championnats_sessions s WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08' GROUP BY s.id_client,s.date HAVING COUNT(*)>1
ORDER BY s.id_client,s.date;

-- I05 Detail de chaque session : aucune selection arbitraire
SELECT s.id,s.id_client,s.date,s.heure_debut,s.heure_fin,s.id_operation_evenement,s.id_evenement,
s.id_offre_client,s.flag_configuration_complete,s.id_type_produit,s.id_format,s.id_produit,s.flag_controle_numerique,
s.flag_session_privee,s.flag_session_weblive,s.online,s.nom,s.nom_court,s.nb_joueurs_max,
c.id_solution_usage,c.id_typologie,c.id_client_reseau,c.flag_client_reseau_siege,
e.id AS evenement_trouve,e.id_client AS proprietaire_evenement,e.date_debut,e.date_fin,e.flag_evenement_demo,e.seo_slug,
CASE WHEN c.id IS NULL OR s.id_client<=0 THEN 1 ELSE 0 END AS client_invalide,
CASE WHEN s.id_operation_evenement>0 AND e.id IS NULL THEN 1 ELSE 0 END AS operation_absente,
CASE WHEN e.id_client<>s.id_client THEN 1 ELSE 0 END AS client_different_affiliation_a_verifier,
CASE WHEN e.id IS NOT NULL AND (DATE(e.date_debut)>s.date OR DATE(e.date_fin)<s.date) THEN 1 ELSE 0 END AS hors_periode,
CASE WHEN e.seo_slug REGEXP '^cotton-event-[0-9]+-[0-9]{8}-*$' THEN 1 ELSE 0 END AS forme_pivot_manage,
CASE WHEN e.seo_slug=CONCAT('cotton-event-',s.id_client,'-',DATE_FORMAT(s.date,'%Y%m%d')) THEN 1 ELSE 0 END AS slug_exact_client_date
FROM prod_cotton_global_0.championnats_sessions s LEFT JOIN prod_cotton_global_0.clients c ON c.id=s.id_client
LEFT JOIN prod_cotton_global_0.operations_evenements e ON e.id=s.id_operation_evenement WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08' ORDER BY s.id_client,s.date,s.id;

-- I06 Repartition jeux et support : conserver valeurs inattendues
SELECT s.id_type_produit,s.flag_controle_numerique,s.id_format,s.flag_configuration_complete,COUNT(*) AS sessions
FROM prod_cotton_global_0.championnats_sessions s WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08' GROUP BY s.id_type_produit,s.flag_controle_numerique,s.id_format,s.flag_configuration_complete;

-- I07 Dates invalides et demos hors cible : ne pas les perdre dans le filtre futur
SELECT s.flag_session_demo,s.flag_configuration_complete,
CASE WHEN s.date IS NULL THEN 'date_null' WHEN s.date='0000-00-00' THEN 'date_zero' WHEN MONTH(s.date)=0 OR DAYOFMONTH(s.date)=0 THEN 'date_incomplete' WHEN s.date<'2026-09-08' THEN 'avant_reference' ELSE 'depuis_reference' END AS periode,COUNT(*) AS sessions
FROM prod_cotton_global_0.championnats_sessions s GROUP BY s.flag_session_demo,s.flag_configuration_complete,periode;

-- I08 Veille : examiner les sessions pouvant encore etre actives au basculement
SELECT s.id,s.id_client,s.date,s.heure_debut,s.heure_fin,s.id_operation_evenement,s.flag_configuration_complete FROM prod_cotton_global_0.championnats_sessions s WHERE s.flag_session_demo=0 AND s.date=DATE_SUB('2026-09-08',INTERVAL 1 DAY);

-- I09 Evenements futurs OU references : inclut programmations sans session
SELECT e.id,e.id_client,e.date_debut,e.date_fin,e.nom,e.nom_court,e.seo_slug,e.online,e.flag_evenement_demo,e.flag_evenement_prive,
(SELECT COUNT(*) FROM prod_cotton_global_0.championnats_sessions a WHERE a.id_operation_evenement=e.id) AS sessions_toutes_dates_tous_statuts,
(SELECT COUNT(*) FROM prod_cotton_global_0.championnats_sessions s WHERE s.id_operation_evenement=e.id AND s.flag_session_demo = 0 AND s.date >= '2026-09-08') AS sessions_officielles_futures,
(SELECT COUNT(DISTINCT s.id_client) FROM prod_cotton_global_0.championnats_sessions s WHERE s.id_operation_evenement=e.id AND s.flag_session_demo = 0 AND s.date >= '2026-09-08') AS clients_futurs,
(SELECT COUNT(DISTINCT s.date) FROM prod_cotton_global_0.championnats_sessions s WHERE s.id_operation_evenement=e.id AND s.flag_session_demo = 0 AND s.date >= '2026-09-08') AS dates_futures
FROM prod_cotton_global_0.operations_evenements e
WHERE e.date_debut>='2026-09-08' OR e.date_fin>='2026-09-08' OR EXISTS(SELECT 1 FROM prod_cotton_global_0.championnats_sessions s WHERE s.id_operation_evenement=e.id AND s.flag_session_demo = 0 AND s.date >= '2026-09-08')
ORDER BY e.id;

-- I10 Sessions sans operation, mais operations compatibles par client/periode : candidats sans choix
SELECT s.id AS session_id,s.id_client,s.date,e.id AS operation_candidate,e.date_debut,e.date_fin,e.seo_slug,e.flag_evenement_demo
FROM prod_cotton_global_0.championnats_sessions s JOIN prod_cotton_global_0.operations_evenements e ON e.id_client=s.id_client AND DATE(e.date_debut)<=s.date AND DATE(e.date_fin)>=s.date
WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08' AND (s.id_operation_evenement=0 OR s.id_operation_evenement IS NULL) ORDER BY s.id,e.id;
