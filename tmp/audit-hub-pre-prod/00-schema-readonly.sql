-- Executer EN PREMIER dans la base Global PROD selectionnee dans phpMyAdmin.
-- SELECT / SHOW seulement. Aucun appel applicatif (les helpers peuvent faire du DDL).
SELECT DATABASE() AS selected_database, VERSION() AS server_version,
       NOW() AS sql_now, UTC_TIMESTAMP() AS utc_now, CURDATE() AS sql_today,
       @@session.time_zone AS session_timezone, @@system_time_zone AS system_timezone,
       @@sql_mode AS sql_mode;
SELECT TABLE_NAME, ENGINE, TABLE_COLLATION, TABLE_ROWS AS estimated_rows,
       DATA_LENGTH, INDEX_LENGTH, AUTO_INCREMENT
FROM information_schema.TABLES
WHERE TABLE_SCHEMA=DATABASE()
  AND (TABLE_NAME LIKE 'games!_hubs%' ESCAPE '!'
    OR TABLE_NAME IN ('championnats_sessions','operations_evenements','clients',
    'ecommerce_offres_to_clients','ecommerce_reseau_contrats','ecommerce_reseau_contrats_affilies',
    'ecommerce_offres','general_branding','referentiels_branding_types','clients_branding',
    'game_events','championnats_sessions_lots','championnats_sessions_participations_probables',
    'championnats_sessions_participations_games_connectees','quizs','quizs_series','questions_lots',
    'jeux_bingo_musical_playlists','jeux_bingo_musical_playlists_clients',
    'jeux_bingo_musical_morceaux_to_playlists_clients','cotton_quiz_sessions',
    'cotton_quiz_players','blindtest_sessions','blindtest_players','bingo_players'))
ORDER BY TABLE_NAME;
SELECT TABLE_NAME, ORDINAL_POSITION, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE,
       COLUMN_DEFAULT, EXTRA, COLLATION_NAME
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA=DATABASE()
  AND (TABLE_NAME LIKE 'games!_hubs%' ESCAPE '!'
    OR TABLE_NAME IN ('championnats_sessions','operations_evenements','clients',
    'ecommerce_offres_to_clients','ecommerce_reseau_contrats','ecommerce_reseau_contrats_affilies',
    'ecommerce_offres','general_branding','referentiels_branding_types','clients_branding',
    'game_events','championnats_sessions_lots','championnats_sessions_participations_probables',
    'championnats_sessions_participations_games_connectees','quizs','quizs_series','questions_lots',
    'jeux_bingo_musical_playlists','jeux_bingo_musical_playlists_clients',
    'jeux_bingo_musical_morceaux_to_playlists_clients','cotton_quiz_sessions',
    'cotton_quiz_players','blindtest_sessions','blindtest_players','bingo_players'))
ORDER BY TABLE_NAME, ORDINAL_POSITION;
SELECT TABLE_NAME, INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME, SUB_PART, INDEX_TYPE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA=DATABASE()
  AND (TABLE_NAME LIKE 'games!_hubs%' ESCAPE '!'
    OR TABLE_NAME IN ('championnats_sessions','operations_evenements','general_branding',
      'ecommerce_offres_to_clients','game_events'))
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
-- Fournit une instruction par table EXISTANTE, sans concatenation tronquee.
-- Executer ensuite les SHOW CREATE TABLE produits et retourner leurs resultats.
SELECT CONCAT('SHOW CREATE TABLE `', REPLACE(TABLE_NAME,'`','``'), '`;') AS diagnostic_to_execute
FROM information_schema.TABLES
WHERE TABLE_SCHEMA=DATABASE()
  AND (TABLE_NAME LIKE 'games!_hubs%' ESCAPE '!'
    OR TABLE_NAME IN ('championnats_sessions','operations_evenements','clients',
      'ecommerce_offres_to_clients','ecommerce_reseau_contrats','ecommerce_reseau_contrats_affilies',
      'ecommerce_offres','general_branding','referentiels_branding_types',
      'championnats_sessions_participations_probables','game_events'))
ORDER BY TABLE_NAME;
