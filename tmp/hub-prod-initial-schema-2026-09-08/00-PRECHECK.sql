-- PRECHECK Hub PROD : READ-ONLY uniquement, aucune donnée métier lue.
-- Résultats complets nécessaires avant production du DDL/POSTCHECK.
-- TABLE_ROWS = estimation, jamais une preuve de vacuité.
SELECT VERSION() AS db_version, @@sql_mode AS sql_mode,
       @@character_set_server AS server_charset, @@collation_server AS server_collation;
SELECT SCHEMA_NAME, DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME
FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = 'prod_cotton_global_0';
SHOW ENGINES;

-- Absence explicite de chaque dépendance : les lignes absentes ont TABLE_TYPE NULL.
SELECT e.expected_table, t.TABLE_TYPE, t.ENGINE, t.TABLE_COLLATION, t.TABLE_ROWS, t.DATA_LENGTH, t.INDEX_LENGTH
FROM (SELECT 'bingo_phase_winners' AS expected_table
UNION ALL SELECT 'bingo_players' AS expected_table
UNION ALL SELECT 'blindtest_players' AS expected_table
UNION ALL SELECT 'blindtest_session_teams' AS expected_table
UNION ALL SELECT 'blindtest_sessions' AS expected_table
UNION ALL SELECT 'championnats_resultats' AS expected_table
UNION ALL SELECT 'championnats_saisons' AS expected_table
UNION ALL SELECT 'championnats_sessions' AS expected_table
UNION ALL SELECT 'championnats_sessions_lots' AS expected_table
UNION ALL SELECT 'championnats_sessions_lots_to_entites_joueurs' AS expected_table
UNION ALL SELECT 'championnats_sessions_participations_games_connectees' AS expected_table
UNION ALL SELECT 'championnats_sessions_participations_probables' AS expected_table
UNION ALL SELECT 'championnats_sessions_podium_photos_consents' AS expected_table
UNION ALL SELECT 'clients' AS expected_table
UNION ALL SELECT 'clients_contacts_to_clients' AS expected_table
UNION ALL SELECT 'community_items' AS expected_table
UNION ALL SELECT 'content_links_check_results' AS expected_table
UNION ALL SELECT 'cotton_quiz_players' AS expected_table
UNION ALL SELECT 'cotton_quiz_sessions' AS expected_table
UNION ALL SELECT 'ecommerce_offres' AS expected_table
UNION ALL SELECT 'ecommerce_offres_to_clients' AS expected_table
UNION ALL SELECT 'ecommerce_reseau_content_shares' AS expected_table
UNION ALL SELECT 'ecommerce_reseau_contrats' AS expected_table
UNION ALL SELECT 'ecommerce_reseau_contrats_affilies' AS expected_table
UNION ALL SELECT 'equipes' AS expected_table
UNION ALL SELECT 'equipes_championnats_sessions_reponses' AS expected_table
UNION ALL SELECT 'equipes_joueurs' AS expected_table
UNION ALL SELECT 'equipes_joueurs_to_equipes' AS expected_table
UNION ALL SELECT 'equipes_to_championnats_sessions' AS expected_table
UNION ALL SELECT 'game_events' AS expected_table
UNION ALL SELECT 'games_hubs' AS expected_table
UNION ALL SELECT 'games_hubs_participations_probables' AS expected_table
UNION ALL SELECT 'games_hubs_players' AS expected_table
UNION ALL SELECT 'games_hubs_players_sessions' AS expected_table
UNION ALL SELECT 'games_hubs_prizes' AS expected_table
UNION ALL SELECT 'games_hubs_publication' AS expected_table
UNION ALL SELECT 'games_hubs_remote_access' AS expected_table
UNION ALL SELECT 'games_hubs_remote_commands' AS expected_table
UNION ALL SELECT 'games_hubs_remote_master_presence' AS expected_table
UNION ALL SELECT 'games_hubs_remote_runtime_presence' AS expected_table
UNION ALL SELECT 'games_hubs_sessions' AS expected_table
UNION ALL SELECT 'general_branding' AS expected_table
UNION ALL SELECT 'jeux_bingo_musical_artistes' AS expected_table
UNION ALL SELECT 'jeux_bingo_musical_grids' AS expected_table
UNION ALL SELECT 'jeux_bingo_musical_grids_clients' AS expected_table
UNION ALL SELECT 'jeux_bingo_musical_morceaux' AS expected_table
UNION ALL SELECT 'jeux_bingo_musical_morceaux_to_playlists' AS expected_table
UNION ALL SELECT 'jeux_bingo_musical_morceaux_to_playlists_clients' AS expected_table
UNION ALL SELECT 'jeux_bingo_musical_playlists' AS expected_table
UNION ALL SELECT 'jeux_bingo_musical_playlists_clients' AS expected_table
UNION ALL SELECT 'jeux_bingo_musical_playlists_clients_logs' AS expected_table
UNION ALL SELECT 'medias_images' AS expected_table
UNION ALL SELECT 'operations_evenements' AS expected_table
UNION ALL SELECT 'programming_quick_operations' AS expected_table
UNION ALL SELECT 'programming_quick_series_operations' AS expected_table
UNION ALL SELECT 'questions' AS expected_table
UNION ALL SELECT 'questions_bonus' AS expected_table
UNION ALL SELECT 'questions_bonus_to_tags' AS expected_table
UNION ALL SELECT 'questions_lots' AS expected_table
UNION ALL SELECT 'questions_lots_num_temp' AS expected_table
UNION ALL SELECT 'questions_lots_rubriques' AS expected_table
UNION ALL SELECT 'questions_lots_temp' AS expected_table
UNION ALL SELECT 'questions_lots_univers' AS expected_table
UNION ALL SELECT 'questions_propositions' AS expected_table
UNION ALL SELECT 'questions_rubriques' AS expected_table
UNION ALL SELECT 'questions_tags' AS expected_table
UNION ALL SELECT 'questions_to_tags' AS expected_table
UNION ALL SELECT 'questions_univers' AS expected_table
UNION ALL SELECT 'quizs' AS expected_table
UNION ALL SELECT 'quizs_series' AS expected_table
UNION ALL SELECT 'quizs_series_to_questions' AS expected_table
UNION ALL SELECT 'referentiels_clients_erp_jauges' AS expected_table
UNION ALL SELECT 'referentiels_clients_pipeline_etats' AS expected_table) e
LEFT JOIN information_schema.TABLES t ON t.TABLE_SCHEMA = 'prod_cotton_global_0' AND t.TABLE_NAME = e.expected_table
ORDER BY e.expected_table;

SELECT TABLE_NAME, TABLE_TYPE, ENGINE, TABLE_COLLATION, TABLE_ROWS, DATA_LENGTH, INDEX_LENGTH
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND (LEFT(TABLE_NAME, 10) = 'games_hubs' OR TABLE_NAME IN ('bingo_phase_winners', 'bingo_players', 'blindtest_players', 'blindtest_session_teams', 'blindtest_sessions', 'championnats_resultats', 'championnats_saisons', 'championnats_sessions', 'championnats_sessions_lots', 'championnats_sessions_lots_to_entites_joueurs', 'championnats_sessions_participations_games_connectees', 'championnats_sessions_participations_probables', 'championnats_sessions_podium_photos_consents', 'clients', 'clients_contacts_to_clients', 'community_items', 'content_links_check_results', 'cotton_quiz_players', 'cotton_quiz_sessions', 'ecommerce_offres', 'ecommerce_offres_to_clients', 'ecommerce_reseau_content_shares', 'ecommerce_reseau_contrats', 'ecommerce_reseau_contrats_affilies', 'equipes', 'equipes_championnats_sessions_reponses', 'equipes_joueurs', 'equipes_joueurs_to_equipes', 'equipes_to_championnats_sessions', 'game_events', 'general_branding', 'jeux_bingo_musical_artistes', 'jeux_bingo_musical_grids', 'jeux_bingo_musical_grids_clients', 'jeux_bingo_musical_morceaux', 'jeux_bingo_musical_morceaux_to_playlists', 'jeux_bingo_musical_morceaux_to_playlists_clients', 'jeux_bingo_musical_playlists', 'jeux_bingo_musical_playlists_clients', 'jeux_bingo_musical_playlists_clients_logs', 'medias_images', 'operations_evenements', 'programming_quick_operations', 'programming_quick_series_operations', 'questions', 'questions_bonus', 'questions_bonus_to_tags', 'questions_lots', 'questions_lots_num_temp', 'questions_lots_rubriques', 'questions_lots_temp', 'questions_lots_univers', 'questions_propositions', 'questions_rubriques', 'questions_tags', 'questions_to_tags', 'questions_univers', 'quizs', 'quizs_series', 'quizs_series_to_questions', 'referentiels_clients_erp_jauges', 'referentiels_clients_pipeline_etats'))
ORDER BY TABLE_NAME;

SELECT TABLE_NAME, ORDINAL_POSITION, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT, EXTRA, CHARACTER_SET_NAME, COLLATION_NAME
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND (LEFT(TABLE_NAME, 10) = 'games_hubs' OR TABLE_NAME IN ('bingo_phase_winners', 'bingo_players', 'blindtest_players', 'blindtest_session_teams', 'blindtest_sessions', 'championnats_resultats', 'championnats_saisons', 'championnats_sessions', 'championnats_sessions_lots', 'championnats_sessions_lots_to_entites_joueurs', 'championnats_sessions_participations_games_connectees', 'championnats_sessions_participations_probables', 'championnats_sessions_podium_photos_consents', 'clients', 'clients_contacts_to_clients', 'community_items', 'content_links_check_results', 'cotton_quiz_players', 'cotton_quiz_sessions', 'ecommerce_offres', 'ecommerce_offres_to_clients', 'ecommerce_reseau_content_shares', 'ecommerce_reseau_contrats', 'ecommerce_reseau_contrats_affilies', 'equipes', 'equipes_championnats_sessions_reponses', 'equipes_joueurs', 'equipes_joueurs_to_equipes', 'equipes_to_championnats_sessions', 'game_events', 'general_branding', 'jeux_bingo_musical_artistes', 'jeux_bingo_musical_grids', 'jeux_bingo_musical_grids_clients', 'jeux_bingo_musical_morceaux', 'jeux_bingo_musical_morceaux_to_playlists', 'jeux_bingo_musical_morceaux_to_playlists_clients', 'jeux_bingo_musical_playlists', 'jeux_bingo_musical_playlists_clients', 'jeux_bingo_musical_playlists_clients_logs', 'medias_images', 'operations_evenements', 'programming_quick_operations', 'programming_quick_series_operations', 'questions', 'questions_bonus', 'questions_bonus_to_tags', 'questions_lots', 'questions_lots_num_temp', 'questions_lots_rubriques', 'questions_lots_temp', 'questions_lots_univers', 'questions_propositions', 'questions_rubriques', 'questions_tags', 'questions_to_tags', 'questions_univers', 'quizs', 'quizs_series', 'quizs_series_to_questions', 'referentiels_clients_erp_jauges', 'referentiels_clients_pipeline_etats'))
ORDER BY TABLE_NAME, ORDINAL_POSITION;

SELECT TABLE_NAME, INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME, SUB_PART, INDEX_TYPE, COLLATION
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND (LEFT(TABLE_NAME, 10) = 'games_hubs' OR TABLE_NAME IN ('bingo_phase_winners', 'bingo_players', 'blindtest_players', 'blindtest_session_teams', 'blindtest_sessions', 'championnats_resultats', 'championnats_saisons', 'championnats_sessions', 'championnats_sessions_lots', 'championnats_sessions_lots_to_entites_joueurs', 'championnats_sessions_participations_games_connectees', 'championnats_sessions_participations_probables', 'championnats_sessions_podium_photos_consents', 'clients', 'clients_contacts_to_clients', 'community_items', 'content_links_check_results', 'cotton_quiz_players', 'cotton_quiz_sessions', 'ecommerce_offres', 'ecommerce_offres_to_clients', 'ecommerce_reseau_content_shares', 'ecommerce_reseau_contrats', 'ecommerce_reseau_contrats_affilies', 'equipes', 'equipes_championnats_sessions_reponses', 'equipes_joueurs', 'equipes_joueurs_to_equipes', 'equipes_to_championnats_sessions', 'game_events', 'general_branding', 'jeux_bingo_musical_artistes', 'jeux_bingo_musical_grids', 'jeux_bingo_musical_grids_clients', 'jeux_bingo_musical_morceaux', 'jeux_bingo_musical_morceaux_to_playlists', 'jeux_bingo_musical_morceaux_to_playlists_clients', 'jeux_bingo_musical_playlists', 'jeux_bingo_musical_playlists_clients', 'jeux_bingo_musical_playlists_clients_logs', 'medias_images', 'operations_evenements', 'programming_quick_operations', 'programming_quick_series_operations', 'questions', 'questions_bonus', 'questions_bonus_to_tags', 'questions_lots', 'questions_lots_num_temp', 'questions_lots_rubriques', 'questions_lots_temp', 'questions_lots_univers', 'questions_propositions', 'questions_rubriques', 'questions_tags', 'questions_to_tags', 'questions_univers', 'quizs', 'quizs_series', 'quizs_series_to_questions', 'referentiels_clients_erp_jauges', 'referentiels_clients_pipeline_etats'))
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND (LEFT(TABLE_NAME, 10) = 'games_hubs' OR TABLE_NAME IN ('bingo_phase_winners', 'bingo_players', 'blindtest_players', 'blindtest_session_teams', 'blindtest_sessions', 'championnats_resultats', 'championnats_saisons', 'championnats_sessions', 'championnats_sessions_lots', 'championnats_sessions_lots_to_entites_joueurs', 'championnats_sessions_participations_games_connectees', 'championnats_sessions_participations_probables', 'championnats_sessions_podium_photos_consents', 'clients', 'clients_contacts_to_clients', 'community_items', 'content_links_check_results', 'cotton_quiz_players', 'cotton_quiz_sessions', 'ecommerce_offres', 'ecommerce_offres_to_clients', 'ecommerce_reseau_content_shares', 'ecommerce_reseau_contrats', 'ecommerce_reseau_contrats_affilies', 'equipes', 'equipes_championnats_sessions_reponses', 'equipes_joueurs', 'equipes_joueurs_to_equipes', 'equipes_to_championnats_sessions', 'game_events', 'general_branding', 'jeux_bingo_musical_artistes', 'jeux_bingo_musical_grids', 'jeux_bingo_musical_grids_clients', 'jeux_bingo_musical_morceaux', 'jeux_bingo_musical_morceaux_to_playlists', 'jeux_bingo_musical_morceaux_to_playlists_clients', 'jeux_bingo_musical_playlists', 'jeux_bingo_musical_playlists_clients', 'jeux_bingo_musical_playlists_clients_logs', 'medias_images', 'operations_evenements', 'programming_quick_operations', 'programming_quick_series_operations', 'questions', 'questions_bonus', 'questions_bonus_to_tags', 'questions_lots', 'questions_lots_num_temp', 'questions_lots_rubriques', 'questions_lots_temp', 'questions_lots_univers', 'questions_propositions', 'questions_rubriques', 'questions_tags', 'questions_to_tags', 'questions_univers', 'quizs', 'quizs_series', 'quizs_series_to_questions', 'referentiels_clients_erp_jauges', 'referentiels_clients_pipeline_etats'))
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

SELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND (LEFT(TABLE_NAME, 10) = 'games_hubs' OR TABLE_NAME IN ('bingo_phase_winners', 'bingo_players', 'blindtest_players', 'blindtest_session_teams', 'blindtest_sessions', 'championnats_resultats', 'championnats_saisons', 'championnats_sessions', 'championnats_sessions_lots', 'championnats_sessions_lots_to_entites_joueurs', 'championnats_sessions_participations_games_connectees', 'championnats_sessions_participations_probables', 'championnats_sessions_podium_photos_consents', 'clients', 'clients_contacts_to_clients', 'community_items', 'content_links_check_results', 'cotton_quiz_players', 'cotton_quiz_sessions', 'ecommerce_offres', 'ecommerce_offres_to_clients', 'ecommerce_reseau_content_shares', 'ecommerce_reseau_contrats', 'ecommerce_reseau_contrats_affilies', 'equipes', 'equipes_championnats_sessions_reponses', 'equipes_joueurs', 'equipes_joueurs_to_equipes', 'equipes_to_championnats_sessions', 'game_events', 'general_branding', 'jeux_bingo_musical_artistes', 'jeux_bingo_musical_grids', 'jeux_bingo_musical_grids_clients', 'jeux_bingo_musical_morceaux', 'jeux_bingo_musical_morceaux_to_playlists', 'jeux_bingo_musical_morceaux_to_playlists_clients', 'jeux_bingo_musical_playlists', 'jeux_bingo_musical_playlists_clients', 'jeux_bingo_musical_playlists_clients_logs', 'medias_images', 'operations_evenements', 'programming_quick_operations', 'programming_quick_series_operations', 'questions', 'questions_bonus', 'questions_bonus_to_tags', 'questions_lots', 'questions_lots_num_temp', 'questions_lots_rubriques', 'questions_lots_temp', 'questions_lots_univers', 'questions_propositions', 'questions_rubriques', 'questions_tags', 'questions_to_tags', 'questions_univers', 'quizs', 'quizs_series', 'quizs_series_to_questions', 'referentiels_clients_erp_jauges', 'referentiels_clients_pipeline_etats'))
ORDER BY TABLE_NAME, CONSTRAINT_NAME, ORDINAL_POSITION;

SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE, ACTION_TIMING, EVENT_MANIPULATION, ACTION_STATEMENT
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'prod_cotton_global_0'
ORDER BY EVENT_OBJECT_TABLE, TRIGGER_NAME;

-- Tables legacy déjà déclarées présentes ; ne pas exécuter SHOW CREATE sur les objets inconnus absents.
SHOW CREATE TABLE `prod_cotton_global_0`.`operations_evenements`;
SHOW CREATE TABLE `prod_cotton_global_0`.`championnats_sessions`;
