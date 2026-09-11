-- CONDITION : confirmer les colonnes avec 00-schema-readonly.sql avant execution.
-- Date de reference FIXE : 2026-09-08, Europe/Paris. A ajuster au PRE reel puis
-- conserver la MEME date pour POST. Ne pas remplacer par CURDATE() au POST.
-- Officielle = flag_session_demo=0. On conserve les incompletes dans le parc.
SELECT COUNT(*) AS total_officielles_futures,
 SUM(flag_configuration_complete=1) AS eligibles_bootstrap,
 SUM(flag_configuration_complete<>1 OR flag_configuration_complete IS NULL) AS incompletes
FROM championnats_sessions WHERE flag_session_demo=0 AND date >= '2026-09-08';
SELECT id_client,date,COUNT(*) AS sessions,
 SUM(flag_configuration_complete=1) AS completes
FROM championnats_sessions WHERE flag_session_demo=0 AND date >= '2026-09-08'
GROUP BY id_client,date ORDER BY id_client,date;
SELECT id_client,COUNT(*) AS sessions FROM championnats_sessions
WHERE flag_session_demo=0 AND date >= '2026-09-08' GROUP BY id_client ORDER BY id_client;
SELECT date,COUNT(*) AS sessions FROM championnats_sessions
WHERE flag_session_demo=0 AND date >= '2026-09-08' GROUP BY date ORDER BY date;
SELECT CASE WHEN id_operation_evenement>0 THEN 'operation_positive'
 WHEN id_operation_evenement=0 THEN 'operation_zero'
 ELSE 'operation_NULL_ou_negative' END AS contexte_historique,
 flag_controle_numerique,id_format,id_type_produit,id_produit,
 flag_configuration_complete,COUNT(*) AS sessions
FROM championnats_sessions WHERE flag_session_demo=0 AND date >= '2026-09-08'
GROUP BY contexte_historique,flag_controle_numerique,id_format,id_type_produit,id_produit,
 flag_configuration_complete ORDER BY contexte_historique,id_type_produit,id_produit;
-- Le contexte courant client n'est pas la preuve du contexte lors de creation.
SELECT cs.id_client,c.id_solution_usage,c.id_typologie,c.id_client_reseau,
 c.flag_client_reseau_siege,cs.id_operation_evenement,COUNT(*) AS sessions
FROM championnats_sessions cs LEFT JOIN clients c ON c.id=cs.id_client
WHERE cs.flag_session_demo=0 AND cs.date >= '2026-09-08'
GROUP BY cs.id_client,c.id_solution_usage,c.id_typologie,c.id_client_reseau,
 c.flag_client_reseau_siege,cs.id_operation_evenement ORDER BY cs.id_client;
-- id_etat=3 = etat brut actif de la ligne d'offre, PAS offre effective du compte.
SELECT CASE WHEN cs.id_offre_client IS NULL THEN 'NULL'
 WHEN cs.id_offre_client=0 THEN 'ZERO'
 WHEN o.id IS NULL THEN 'REFERENCE_ORPHELINE'
 WHEN o.id_etat=3 THEN 'REFERENCE_ETAT_3'
 ELSE 'REFERENCE_AUTRE_ETAT' END AS offre_historique,
 o.id_etat,COUNT(*) AS sessions
FROM championnats_sessions cs LEFT JOIN ecommerce_offres_to_clients o ON o.id=cs.id_offre_client
WHERE cs.flag_session_demo=0 AND cs.date >= '2026-09-08'
GROUP BY offre_historique,o.id_etat ORDER BY offre_historique,o.id_etat;
SELECT cs.id,cs.id_client,cs.date,cs.id_offre_client,
 o.id_client AS offre_owner,o.id_client_delegation,o.id_etat,o.date_debut,o.date_fin,
 (SELECT COUNT(*) FROM ecommerce_offres_to_clients a
  WHERE a.id_etat=3 AND (a.id_client=cs.id_client OR a.id_client_delegation=cs.id_client))
 AS lignes_offre_etat_3_compte_ou_delegation
FROM championnats_sessions cs LEFT JOIN ecommerce_offres_to_clients o ON o.id=cs.id_offre_client
WHERE cs.flag_session_demo=0 AND cs.date >= '2026-09-08' ORDER BY cs.id;
-- Lignes utiles pour appliquer ensuite exactement le resolver own_offer/network,
-- apres confirmation du schema reseau et des IDs catalogue support (pas de MIN(id)).
SELECT o.id,o.id_client,o.id_client_delegation,o.id_offre,o.id_etat,
 o.flag_offert,o.date_debut,o.date_fin
FROM ecommerce_offres_to_clients o
WHERE EXISTS (SELECT 1 FROM championnats_sessions cs
 WHERE cs.flag_session_demo=0 AND cs.date >= '2026-09-08'
 AND (cs.id_client=o.id_client OR cs.id_client=o.id_client_delegation OR cs.id_offre_client=o.id))
ORDER BY o.id;
-- Exceptions que le filtre "futur" ordinaire ne doit pas faire disparaitre.
SELECT id,id_client,date,flag_session_demo,flag_configuration_complete,id_type_produit,
 id_produit,id_offre_client,id_operation_evenement,heure_debut,heure_fin
FROM championnats_sessions
WHERE date IS NULL OR date='0000-00-00' OR id_client<=0
 OR (date >= '2026-09-08' AND (flag_session_demo IS NULL OR flag_session_demo NOT IN (0,1)
 OR flag_configuration_complete<>1 OR flag_configuration_complete IS NULL
 OR id_type_produit NOT IN (1,2,3,4,5,6))) ORDER BY id;
-- Jour precedent : potentiellement encore ouvert jusqu'a J+1 12:00 Europe/Paris.
SELECT id,id_client,date,heure_debut,heure_fin,flag_configuration_complete,id_type_produit
FROM championnats_sessions WHERE flag_session_demo=0 AND date='2026-09-07' ORDER BY id;
SELECT id_client,date,COUNT(DISTINCT CASE WHEN id_operation_evenement>0 THEN id_operation_evenement END)
 AS operations_positives,SUM(COALESCE(id_operation_evenement,0)=0) AS sans_operation,
 COUNT(*) AS sessions
FROM championnats_sessions WHERE flag_session_demo=0 AND date >= '2026-09-08'
GROUP BY id_client,date HAVING operations_positives>1 OR (operations_positives>0 AND sans_operation>0);
-- Metadonnees operation : exporter les lignes existantes sans reinterpreter leur date.
SELECT e.* FROM operations_evenements e WHERE EXISTS
 (SELECT 1 FROM championnats_sessions cs WHERE cs.flag_session_demo=0
 AND cs.date >= '2026-09-08' AND cs.id_operation_evenement=e.id) ORDER BY e.id;
SELECT cs.id,cs.id_client,cs.date,cs.id_operation_evenement,e.id_client AS operation_client
FROM championnats_sessions cs LEFT JOIN operations_evenements e ON e.id=cs.id_operation_evenement
WHERE cs.flag_session_demo=0 AND cs.date >= '2026-09-08' AND cs.id_operation_evenement>0
 AND (e.id IS NULL OR NOT(e.id_client <=> cs.id_client)) ORDER BY cs.id;
-- Lots divergents BRUTS = diagnostic conservateur, pas decision de fusion.
SELECT id_client,date,COUNT(DISTINCT SHA2(CAST(JSON_ARRAY(lot_1,lot_2,lot_3) AS BINARY),256))
 AS variantes_lots_bruts FROM championnats_sessions
WHERE flag_session_demo=0 AND date >= '2026-09-08' GROUP BY id_client,date
HAVING variantes_lots_bruts>1;
-- OPTIONNEL CONTENU : seulement si les tables catalogue de 00 sont confirmees.
-- Une liste de tokens Quiz non vide n'est PAS une preuve que tous ses tokens existent.
SELECT cs.id,cs.id_type_produit,cs.id_produit,cs.lot_ids,cs.id_format,
 cs.flag_controle_numerique,cs.flag_configuration_complete,
 CASE
 WHEN cs.id_type_produit=2 THEN 'BINGO_ARCHIVE_A_EXAMINER'
 WHEN cs.id_type_produit=5 AND TRIM(COALESCE(cs.lot_ids,''))<>'' THEN 'TOKENS_QUIZ_A_VALIDER'
 WHEN cs.id_type_produit IN (1,5) AND EXISTS(SELECT 1 FROM quizs q WHERE q.id=cs.id_produit)
 THEN 'REFERENCE_QUIZ_PRESENTE'
 WHEN cs.id_type_produit IN (3,6) AND EXISTS
 (SELECT 1 FROM jeux_bingo_musical_playlists_clients p WHERE p.id=cs.id_produit)
 THEN 'REFERENCE_PLAYLIST_CLIENT_PRESENTE'
 WHEN cs.id_type_produit=4 AND EXISTS
 (SELECT 1 FROM jeux_bingo_musical_playlists p WHERE p.id=cs.id_produit)
 THEN 'REFERENCE_PLAYLIST_CATALOGUE_PRESENTE'
 ELSE 'REFERENCE_MANQUANTE_OU_TYPE_NON_SUPPORTE' END AS contenu_diagnostic
FROM championnats_sessions cs
WHERE cs.flag_session_demo=0 AND cs.date >= '2026-09-08' ORDER BY cs.id;
