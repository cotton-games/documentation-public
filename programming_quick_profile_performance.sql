-- Programmateur rapide: diagnostic du profil historique.
-- A executer hors requete HTTP depuis un environnement ayant acces a la base.

-- Constat logs 2026-07-20:
-- client_id=10  : history_fetch_ms=12501.16, sessions_examined=381
-- client_id=499 : history_fetch_ms=8377.69 puis 7858.26, sessions_examined=438
-- Le cout etait dans les EXISTS correles de la requete de fetch, pas dans la
-- construction du profil ni dans la recommandation.

-- 1. Requete candidate actuelle: champs strictement necessaires + runtime Bingo.
-- Les statuts Quiz/Blindtest sont lus en batch pour eviter les Block Nested
-- Loop vus sur blindtest_sessions et cotton_quiz_sessions.
EXPLAIN FORMAT=JSON
SELECT
	cs.id,
	cs.id_client,
	cs.id_operation_evenement,
	cs.id_type_produit,
	cs.id_produit,
	cs.date,
	cs.heure_debut,
	cs.flag_controle_numerique,
	cs.id_format,
	cs.id_securite,
	cs.flag_session_demo,
	cs.flag_configuration_complete,
	CASE
		WHEN cs.id_type_produit=1 AND cs.date < CURDATE() THEN 1
		WHEN cs.id_type_produit IN (2,3,6) AND COALESCE(jbmpc.phase_courante, 0) > 0 THEN 1
		ELSE 0
	END AS quick_history_is_reliably_started,
	COALESCE(jbmpc.id, 0) AS quick_history_bingo_runtime_id,
	COALESCE(jbmpc.phase_courante, 0) AS quick_history_bingo_phase,
	0 AS quick_history_blindtest_status,
	0 AS quick_history_quiz_status
FROM championnats_sessions cs
LEFT JOIN jeux_bingo_musical_playlists_clients jbmpc ON jbmpc.id=cs.id_produit AND cs.id_type_produit IN (2,3,6)
WHERE cs.id_client = :client_id
AND cs.flag_session_demo = 0
AND cs.flag_configuration_complete = 1
AND cs.date < CURDATE()
AND cs.date >= DATE_SUB(CURDATE(), INTERVAL 730 DAY)
ORDER BY cs.date DESC, cs.heure_debut ASC, cs.id ASC;

-- 2. Requetes batch participantes a expliquer avec les listes issues de la
-- requete candidate. Remplacer :session_ids, :security_ids et :product_ids
-- par les listes IN concretes du compte mesure.

EXPLAIN FORMAT=JSON
SELECT session_id, MAX(game_status) AS game_status
FROM cotton_quiz_sessions
WHERE session_id IN (:security_ids)
GROUP BY session_id;

EXPLAIN FORMAT=JSON
SELECT session_id, MAX(game_status) AS game_status
FROM blindtest_sessions
WHERE session_id IN (:security_ids)
GROUP BY session_id;

EXPLAIN FORMAT=JSON
SELECT DISTINCT id_championnat_session AS id
FROM equipes_to_championnats_sessions
WHERE id_championnat_session IN (:session_ids);

EXPLAIN FORMAT=JSON
SELECT DISTINCT id_championnat_session AS id
FROM championnats_resultats
WHERE id_championnat_session IN (:session_ids);

EXPLAIN FORMAT=JSON
SELECT DISTINCT id_championnat_session AS id
FROM championnats_sessions_participations_games_connectees
WHERE id_championnat_session IN (:session_ids)
AND id_joueur > 0
AND date_consumed IS NOT NULL;

EXPLAIN FORMAT=JSON
SELECT DISTINCT cqs.session_id AS session_id
FROM cotton_quiz_sessions cqs
INNER JOIN cotton_quiz_players cqp ON cqp.session_id=cqs.id
WHERE cqs.session_id IN (:security_ids);

EXPLAIN FORMAT=JSON
SELECT DISTINCT bs.session_id AS session_id
FROM blindtest_sessions bs
INNER JOIN blindtest_players bp ON bp.session_id=bs.id
WHERE bs.session_id IN (:security_ids);

EXPLAIN FORMAT=JSON
SELECT DISTINCT session_id
FROM bingo_players
WHERE session_id IN (:security_ids);

EXPLAIN FORMAT=JSON
SELECT DISTINCT id_playlist_client AS id
FROM jeux_bingo_musical_grids_clients
WHERE id_playlist_client IN (:product_ids)
AND id_grid_support = 2
AND flag_demo = 0
AND id_joueur > 0;

-- 3. Instrumentation HTTP: les logs sont prefixes par:
-- [programming_quick_profile]
