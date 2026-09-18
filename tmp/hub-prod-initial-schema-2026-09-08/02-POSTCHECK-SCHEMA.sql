-- READ-ONLY pour les données et le schéma. Variables de session + PREPARE d'un SELECT uniquement.

-- Exécuter le fichier entier dans la même session phpMyAdmin. Aucun DDL/DML/routine/table temporaire.

-- Le SELECT de comptage exact n'est préparé que si toutes les structures sont conformes.

-- Une erreur SQL invalide toute validation ; le seul verdict final est SCHEMA_READY_FOR_BACKFILL.

-- Les alias utf8mb3/utf8 des versions de test sont équivalents ; types, valeurs et défauts restent exacts.

SET @cotton_hub_schema_issues = NULL;

WITH
expected_tables(table_name) AS (
SELECT 'games_hubs'
UNION ALL
SELECT 'games_hubs_sessions'
UNION ALL
SELECT 'games_hubs_players'
UNION ALL
SELECT 'games_hubs_participations_probables'
UNION ALL
SELECT 'games_hubs_players_sessions'
UNION ALL
SELECT 'games_hubs_publication'
UNION ALL
SELECT 'games_hubs_prizes'
UNION ALL
SELECT 'games_hubs_remote_access'
UNION ALL
SELECT 'games_hubs_remote_master_presence'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence'
UNION ALL
SELECT 'games_hubs_remote_commands'
UNION ALL
SELECT 'programming_quick_operations'
UNION ALL
SELECT 'programming_quick_series_operations'
),
expected_columns(table_name,column_name,ordinal_position,column_type,is_nullable,column_default,extra,character_set_name,collation_name) AS (
SELECT 'games_hubs', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'id_securite', 2, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'id_client', 3, 'mediumint(9) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'hub_date', 4, 'date', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'context_type', 5, 'varchar(16)', 'NO', '''day''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'id_operation_evenement', 6, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'hub_label', 7, 'varchar(255)', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'flag_active', 8, 'tinyint(1) unsigned', 'NO', '1', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'hub_status', 9, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'active_session_id', 10, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'active_session_activated_at', 11, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'remote_routing_generation', 12, 'bigint(20) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'remote_routing_intent_id', 13, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'remote_transition_type', 14, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'remote_transition_payload_json', 15, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'remote_transition_started_at', 16, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'presentation_session_id', 17, 'int(10) unsigned', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'presentation_mode', 18, 'varchar(24)', 'NO', '''session''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'presentation_updated_at', 19, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'hub_master_instance_id', 20, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'hub_master_instance_seen_at', 21, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'hub_remote_instance_id', 22, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'hub_remote_instance_seen_at', 23, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'prizes_initialized_at', 24, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'delete_operation_token', 25, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'delete_step', 26, 'varchar(48)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'delete_started_at', 27, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'delete_error_at', 28, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'date_ajout', 29, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'date_maj', 30, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'player_qr_display_mode', 31, 'varchar(8)', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'player_qr_display_revision', 32, 'bigint(20) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'player_qr_display_confirmation_json', 33, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'player_qr_official_started_at', 34, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_sessions', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_sessions', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_sessions', 'id_session', 3, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_sessions', 'membership_source', 4, 'varchar(32)', 'NO', '''legacy_reconciled''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_sessions', 'status', 5, 'enum(''active'',''inactive'')', 'NO', '''active''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_sessions', 'created_at', 6, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_sessions', 'updated_at', 7, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'id_client', 3, 'mediumint(9) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'id_operation_evenement', 4, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'hub_token', 5, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'player_token', 6, 'varchar(96)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'auth_identity_key', 7, 'varchar(128)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'id_ep_player', 8, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'auth_type', 9, 'enum(''guest'',''ep'')', 'NO', '''guest''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'pseudo', 10, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'pseudo_normalized', 11, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'status', 12, 'enum(''active'',''left'')', 'NO', '''active''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'return_token', 13, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'return_expires_at', 14, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'created_at', 15, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'updated_at', 16, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'last_seen_at', 17, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'last_ip', 18, 'varchar(45)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'user_agent_hash', 19, 'char(40)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'hub_photo_media_id', 20, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'hub_photo_game_key', 21, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'hub_photo_source', 22, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'hub_photo_updated_at', 23, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_aggregate_score', 24, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_wins_count', 25, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_second_places_count', 26, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_third_places_count', 27, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_parties_count', 28, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_last_result_at', 29, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_source_revision', 30, 'char(40)', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'stats_computed_at', 31, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_dirty_at', 32, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_error', 33, 'varchar(255)', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_participations_probables', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'id_client', 3, 'mediumint(9) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'id_operation_evenement', 4, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'hub_token', 5, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_participations_probables', 'auth_identity_key', 6, 'varchar(128)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_participations_probables', 'id_ep_player', 7, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'source', 8, 'varchar(32)', 'NO', '''hub_play''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_participations_probables', 'status', 9, 'enum(''declared'',''cancelled'',''confirmed'')', 'NO', '''declared''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_participations_probables', 'date_ajout', 10, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'date_maj', 11, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'declared_at', 12, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'cancelled_at', 13, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'confirmed_at', 14, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'ip', 15, 'varchar(45)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_participations_probables', 'id_user_ajout', 16, 'mediumint(9) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'id_user_maj', 17, 'mediumint(9) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'id_hub_player', 3, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'id_session', 4, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'session_token', 5, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players_sessions', 'game_type', 6, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players_sessions', 'id_participation', 7, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'participant_key', 8, 'varchar(128)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players_sessions', 'id_ep_player', 9, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'status', 10, 'enum(''created'',''active'',''left'',''completed'',''failed'')', 'NO', '''created''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players_sessions', 'auto_joined_at', 11, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'manual_joined_at', 12, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'last_joined_at', 13, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'left_at', 14, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'completed_at', 15, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'join_count', 16, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'last_action', 17, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players_sessions', 'created_at', 18, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'updated_at', 19, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'last_error', 20, 'varchar(255)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_publication', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_publication', 'title', 3, 'varchar(150)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'tagline', 4, 'varchar(255)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'description', 5, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'location_name', 6, 'varchar(150)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'address', 7, 'varchar(180)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'postal_code', 8, 'varchar(20)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'city', 9, 'varchar(120)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'country', 10, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'website_url', 11, 'varchar(255)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'cta_label', 12, 'varchar(150)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'publication_status', 13, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'date_ajout', 14, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_publication', 'date_maj', 15, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_prizes', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_prizes', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_prizes', 'rank', 3, 'tinyint(3) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_prizes', 'label', 4, 'varchar(120)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_prizes', 'description', 5, 'varchar(255)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_prizes', 'date_ajout', 6, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_prizes', 'date_maj', 7, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'id_client', 3, 'mediumint(9) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'remote_token', 4, 'varchar(96)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_access', 'remote_token_hash', 5, 'char(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_access', 'session_token_hash', 6, 'char(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_access', 'status', 7, 'enum(''active'',''revoked'')', 'NO', '''active''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_access', 'label', 8, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_access', 'created_at', 9, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'revoked_at', 10, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'last_seen_at', 11, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'last_ip', 12, 'varchar(45)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_access', 'user_agent_hash', 13, 'char(40)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'master_instance_id', 3, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'last_seen_at', 4, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'last_applied_preparation_revision', 5, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'last_control_revision', 6, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'visibility', 7, 'varchar(16)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'user_agent_hash', 8, 'char(40)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'created_at', 9, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'updated_at', 10, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'id_session', 3, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'execution_id', 4, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'master_instance_id', 5, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'last_seen_at', 6, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'visibility', 7, 'varchar(16)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'user_agent_hash', 8, 'char(40)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'created_at', 9, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'updated_at', 10, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'id_remote_access', 3, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'command_type', 4, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'payload_json', 5, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'status', 6, 'enum(''pending'',''claimed'',''processing'',''completed'',''failed'',''expired'',''cancelled'')', 'NO', '''pending''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'remote_command_key', 7, 'varchar(96)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'created_at', 8, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'expires_at', 9, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'claimed_by', 10, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'claimed_at', 11, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'completed_at', 12, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'result_json', 13, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'error_code', 14, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'date_maj', 15, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'programming_quick_operations', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'programming_quick_operations', 'id_client', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'programming_quick_operations', 'idempotency_key', 3, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'command_hash', 4, 'char(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'status', 5, 'varchar(24)', 'NO', '''pending''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'operation_step', 6, 'varchar(32)', 'NO', '''pending''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'session_ids_json', 7, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'session_security_ids_json', 8, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'hub_id', 9, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'programming_quick_operations', 'dashboard_url', 10, 'varchar(255)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'result_json', 11, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'error_code', 12, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'created_at', 13, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'programming_quick_operations', 'updated_at', 14, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'programming_quick_operations', 'expires_at', 15, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'programming_quick_series_operations', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'programming_quick_series_operations', 'id_client', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'programming_quick_series_operations', 'idempotency_key', 3, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'command_hash', 4, 'char(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'status', 5, 'varchar(24)', 'NO', '''pending''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'operation_step', 6, 'varchar(32)', 'NO', '''pending''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'template_json', 7, 'mediumtext', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'recurrence_json', 8, 'mediumtext', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'occurrences_json', 9, 'mediumtext', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'themes_json', 10, 'mediumtext', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'result_json', 11, 'mediumtext', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'created_at', 12, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'programming_quick_series_operations', 'updated_at', 13, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'programming_quick_series_operations', 'expires_at', 14, 'datetime', 'NO', NULL, '', NULL, NULL
),
expected_indexes(table_name,index_name,non_unique,seq_in_index,column_name) AS (
SELECT 'games_hubs', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_token', 0, 1, 'id_securite'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_context', 0, 1, 'id_client'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_context', 0, 2, 'hub_date'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_context', 0, 3, 'context_type'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_context', 0, 4, 'id_operation_evenement'
UNION ALL
SELECT 'games_hubs', 'idx_games_hubs_client_date', 1, 1, 'id_client'
UNION ALL
SELECT 'games_hubs', 'idx_games_hubs_client_date', 1, 2, 'hub_date'
UNION ALL
SELECT 'games_hubs', 'idx_games_hubs_active_session', 1, 1, 'active_session_id'
UNION ALL
SELECT 'games_hubs', 'idx_games_hubs_presentation_session', 1, 1, 'presentation_session_id'
UNION ALL
SELECT 'games_hubs', 'idx_games_hubs_operation', 1, 1, 'id_operation_evenement'
UNION ALL
SELECT 'games_hubs_sessions', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_sessions', 'uniq_games_hubs_sessions_hub_session', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_sessions', 'uniq_games_hubs_sessions_hub_session', 0, 2, 'id_session'
UNION ALL
SELECT 'games_hubs_sessions', 'idx_games_hubs_sessions_hub_status', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_sessions', 'idx_games_hubs_sessions_hub_status', 1, 2, 'status'
UNION ALL
SELECT 'games_hubs_sessions', 'idx_games_hubs_sessions_session', 1, 1, 'id_session'
UNION ALL
SELECT 'games_hubs_players', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_players', 'uniq_games_hubs_players_identity', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_players', 'uniq_games_hubs_players_identity', 0, 2, 'auth_identity_key'
UNION ALL
SELECT 'games_hubs_players', 'idx_games_hubs_players_hub_status', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_players', 'idx_games_hubs_players_hub_status', 1, 2, 'status'
UNION ALL
SELECT 'games_hubs_players', 'idx_games_hubs_players_pseudo', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_players', 'idx_games_hubs_players_pseudo', 1, 2, 'pseudo_normalized'
UNION ALL
SELECT 'games_hubs_players', 'idx_games_hubs_players_return', 1, 1, 'return_token'
UNION ALL
SELECT 'games_hubs_participations_probables', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_participations_probables', 'uniq_games_hubs_probables_identity', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_participations_probables', 'uniq_games_hubs_probables_identity', 0, 2, 'auth_identity_key'
UNION ALL
SELECT 'games_hubs_participations_probables', 'idx_games_hubs_probables_hub_status', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_participations_probables', 'idx_games_hubs_probables_hub_status', 1, 2, 'status'
UNION ALL
SELECT 'games_hubs_participations_probables', 'idx_games_hubs_probables_ep', 1, 1, 'id_ep_player'
UNION ALL
SELECT 'games_hubs_players_sessions', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_players_sessions', 'uniq_games_hubs_players_sessions_player_session', 0, 1, 'id_hub_player'
UNION ALL
SELECT 'games_hubs_players_sessions', 'uniq_games_hubs_players_sessions_player_session', 0, 2, 'id_session'
UNION ALL
SELECT 'games_hubs_players_sessions', 'idx_games_hubs_players_sessions_hub_session', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_players_sessions', 'idx_games_hubs_players_sessions_hub_session', 1, 2, 'id_session'
UNION ALL
SELECT 'games_hubs_players_sessions', 'idx_games_hubs_players_sessions_session', 1, 1, 'id_session'
UNION ALL
SELECT 'games_hubs_players_sessions', 'idx_games_hubs_players_sessions_participant', 1, 1, 'game_type'
UNION ALL
SELECT 'games_hubs_players_sessions', 'idx_games_hubs_players_sessions_participant', 1, 2, 'participant_key'
UNION ALL
SELECT 'games_hubs_publication', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_publication', 'uniq_games_hubs_publication_hub', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_prizes', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_prizes', 'uniq_games_hubs_prizes_hub_rank', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_prizes', 'uniq_games_hubs_prizes_hub_rank', 0, 2, 'rank'
UNION ALL
SELECT 'games_hubs_prizes', 'idx_games_hubs_prizes_hub', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_access', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_remote_access', 'uniq_games_hubs_remote_token_hash', 0, 1, 'remote_token_hash'
UNION ALL
SELECT 'games_hubs_remote_access', 'idx_games_hubs_remote_hub_status', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_access', 'idx_games_hubs_remote_hub_status', 1, 2, 'status'
UNION ALL
SELECT 'games_hubs_remote_access', 'idx_games_hubs_remote_session_hash', 1, 1, 'session_token_hash'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'uniq_games_hubs_remote_presence_master', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'uniq_games_hubs_remote_presence_master', 0, 2, 'master_instance_id'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'idx_games_hubs_remote_presence_seen', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'idx_games_hubs_remote_presence_seen', 1, 2, 'last_seen_at'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'uniq_games_hubs_remote_runtime_master', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'uniq_games_hubs_remote_runtime_master', 0, 2, 'id_session'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'uniq_games_hubs_remote_runtime_master', 0, 3, 'execution_id'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'uniq_games_hubs_remote_runtime_master', 0, 4, 'master_instance_id'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'idx_games_hubs_remote_runtime_seen', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'idx_games_hubs_remote_runtime_seen', 1, 2, 'id_session'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'idx_games_hubs_remote_runtime_seen', 1, 3, 'execution_id'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'idx_games_hubs_remote_runtime_seen', 1, 4, 'last_seen_at'
UNION ALL
SELECT 'games_hubs_remote_commands', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_remote_commands', 'uniq_games_hubs_remote_command_key', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_commands', 'uniq_games_hubs_remote_command_key', 0, 2, 'remote_command_key'
UNION ALL
SELECT 'games_hubs_remote_commands', 'idx_games_hubs_remote_commands_pending', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_commands', 'idx_games_hubs_remote_commands_pending', 1, 2, 'status'
UNION ALL
SELECT 'games_hubs_remote_commands', 'idx_games_hubs_remote_commands_pending', 1, 3, 'expires_at'
UNION ALL
SELECT 'games_hubs_remote_commands', 'idx_games_hubs_remote_commands_pending', 1, 4, 'id'
UNION ALL
SELECT 'games_hubs_remote_commands', 'idx_games_hubs_remote_commands_access', 1, 1, 'id_remote_access'
UNION ALL
SELECT 'games_hubs_remote_commands', 'idx_games_hubs_remote_commands_access', 1, 2, 'created_at'
UNION ALL
SELECT 'programming_quick_operations', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'programming_quick_operations', 'uniq_programming_quick_client_key', 0, 1, 'id_client'
UNION ALL
SELECT 'programming_quick_operations', 'uniq_programming_quick_client_key', 0, 2, 'idempotency_key'
UNION ALL
SELECT 'programming_quick_operations', 'idx_programming_quick_expires_at', 1, 1, 'expires_at'
UNION ALL
SELECT 'programming_quick_operations', 'idx_programming_quick_client_status', 1, 1, 'id_client'
UNION ALL
SELECT 'programming_quick_operations', 'idx_programming_quick_client_status', 1, 2, 'status'
UNION ALL
SELECT 'programming_quick_series_operations', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'programming_quick_series_operations', 'uniq_programming_quick_series_client_key', 0, 1, 'id_client'
UNION ALL
SELECT 'programming_quick_series_operations', 'uniq_programming_quick_series_client_key', 0, 2, 'idempotency_key'
UNION ALL
SELECT 'programming_quick_series_operations', 'idx_programming_quick_series_expires_at', 1, 1, 'expires_at'
UNION ALL
SELECT 'programming_quick_series_operations', 'idx_programming_quick_series_client_status', 1, 1, 'id_client'
UNION ALL
SELECT 'programming_quick_series_operations', 'idx_programming_quick_series_client_status', 1, 2, 'status'
),
expected_constraints(table_name,constraint_name,constraint_type) AS (
SELECT 'games_hubs', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_token', 'UNIQUE'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_context', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_sessions', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_sessions', 'uniq_games_hubs_sessions_hub_session', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_players', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_players', 'uniq_games_hubs_players_identity', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_participations_probables', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_participations_probables', 'uniq_games_hubs_probables_identity', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_players_sessions', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_players_sessions', 'uniq_games_hubs_players_sessions_player_session', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_publication', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_publication', 'uniq_games_hubs_publication_hub', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_prizes', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_prizes', 'uniq_games_hubs_prizes_hub_rank', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_remote_access', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_remote_access', 'uniq_games_hubs_remote_token_hash', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'uniq_games_hubs_remote_presence_master', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'uniq_games_hubs_remote_runtime_master', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_remote_commands', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_remote_commands', 'uniq_games_hubs_remote_command_key', 'UNIQUE'
UNION ALL
SELECT 'programming_quick_operations', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'programming_quick_operations', 'uniq_programming_quick_client_key', 'UNIQUE'
UNION ALL
SELECT 'programming_quick_series_operations', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'programming_quick_series_operations', 'uniq_programming_quick_series_client_key', 'UNIQUE'
),
actual_tables AS (SELECT * FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND TABLE_NAME IN (SELECT table_name FROM expected_tables)),
actual_columns AS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND TABLE_NAME IN (SELECT table_name FROM expected_tables)),
actual_indexes AS (SELECT * FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND TABLE_NAME IN (SELECT table_name FROM expected_tables)),
actual_constraints AS (SELECT * FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND TABLE_NAME IN (SELECT table_name FROM expected_tables)),
issues AS (
SELECT e.table_name AS object_name, 'TABLE_ABSENTE_OU_ENGINE_COLLATION_TYPE' AS problem
FROM expected_tables e LEFT JOIN actual_tables a ON a.TABLE_NAME=e.table_name
WHERE a.TABLE_NAME IS NULL OR a.TABLE_TYPE <> 'BASE TABLE' OR a.ENGINE <> 'InnoDB'
   OR REPLACE(a.TABLE_COLLATION,'utf8mb3','utf8') <> 'utf8_general_ci'
UNION ALL
SELECT CONCAT(e.table_name,'.',e.column_name), 'COLONNE_ABSENTE_OU_DEFINITION'
FROM expected_columns e LEFT JOIN actual_columns a ON a.TABLE_NAME=e.table_name AND a.COLUMN_NAME=e.column_name
WHERE a.COLUMN_NAME IS NULL OR a.ORDINAL_POSITION <> e.ordinal_position
   OR NOT (BINARY a.COLUMN_TYPE <=> BINARY e.column_type)
   OR NOT (a.IS_NULLABLE <=> e.is_nullable)
   OR NOT (BINARY a.COLUMN_DEFAULT <=> BINARY e.column_default)
   OR NOT (BINARY a.EXTRA <=> BINARY e.extra)
   OR NOT (REPLACE(a.CHARACTER_SET_NAME,'utf8mb3','utf8') <=> e.character_set_name)
   OR NOT (REPLACE(a.COLLATION_NAME,'utf8mb3','utf8') <=> e.collation_name)
UNION ALL
SELECT CONCAT(a.TABLE_NAME,'.',a.COLUMN_NAME), 'COLONNE_INATTENDUE'
FROM actual_columns a LEFT JOIN expected_columns e ON a.TABLE_NAME=e.table_name AND a.COLUMN_NAME=e.column_name
WHERE e.column_name IS NULL
UNION ALL
SELECT CONCAT(e.table_name,'.',e.index_name,'#',e.seq_in_index), 'INDEX_ABSENT_OU_DEFINITION'
FROM expected_indexes e LEFT JOIN actual_indexes a ON a.TABLE_NAME=e.table_name AND a.INDEX_NAME=e.index_name AND a.SEQ_IN_INDEX=e.seq_in_index
WHERE a.INDEX_NAME IS NULL OR a.NON_UNIQUE<>e.non_unique OR a.COLUMN_NAME<>e.column_name
   OR a.SUB_PART IS NOT NULL OR a.INDEX_TYPE<>'BTREE' OR NOT(a.COLLATION <=> 'A')
UNION ALL
SELECT CONCAT(a.TABLE_NAME,'.',a.INDEX_NAME,'#',a.SEQ_IN_INDEX), 'INDEX_INATTENDU'
FROM actual_indexes a LEFT JOIN expected_indexes e ON a.TABLE_NAME=e.table_name AND a.INDEX_NAME=e.index_name AND a.SEQ_IN_INDEX=e.seq_in_index
WHERE e.index_name IS NULL
UNION ALL
SELECT CONCAT(e.table_name,'.',e.constraint_name), 'CONTRAINTE_ABSENTE_OU_TYPE'
FROM expected_constraints e LEFT JOIN actual_constraints a ON a.TABLE_NAME=e.table_name AND a.CONSTRAINT_NAME=e.constraint_name
WHERE a.CONSTRAINT_NAME IS NULL OR a.CONSTRAINT_TYPE<>e.constraint_type
UNION ALL
SELECT CONCAT(a.TABLE_NAME,'.',a.CONSTRAINT_NAME), 'CONTRAINTE_INATTENDUE'
FROM actual_constraints a LEFT JOIN expected_constraints e ON a.TABLE_NAME=e.table_name AND a.CONSTRAINT_NAME=e.constraint_name
WHERE e.constraint_name IS NULL
UNION ALL
SELECT CONCAT(EVENT_OBJECT_TABLE,'.',TRIGGER_NAME), 'TRIGGER_INATTENDU'
FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'prod_cotton_global_0'
UNION ALL
SELECT TABLE_NAME, 'TABLE_HUB_INATTENDUE'
FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'prod_cotton_global_0'
AND LEFT(TABLE_NAME,10)='games_hubs' AND TABLE_NAME NOT IN (SELECT table_name FROM expected_tables)
)
SELECT COUNT(*) INTO @cotton_hub_schema_issues FROM issues;

SELECT @cotton_hub_schema_issues AS SCHEMA_ISSUE_COUNT;

WITH
expected_tables(table_name) AS (
SELECT 'games_hubs'
UNION ALL
SELECT 'games_hubs_sessions'
UNION ALL
SELECT 'games_hubs_players'
UNION ALL
SELECT 'games_hubs_participations_probables'
UNION ALL
SELECT 'games_hubs_players_sessions'
UNION ALL
SELECT 'games_hubs_publication'
UNION ALL
SELECT 'games_hubs_prizes'
UNION ALL
SELECT 'games_hubs_remote_access'
UNION ALL
SELECT 'games_hubs_remote_master_presence'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence'
UNION ALL
SELECT 'games_hubs_remote_commands'
UNION ALL
SELECT 'programming_quick_operations'
UNION ALL
SELECT 'programming_quick_series_operations'
),
expected_columns(table_name,column_name,ordinal_position,column_type,is_nullable,column_default,extra,character_set_name,collation_name) AS (
SELECT 'games_hubs', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'id_securite', 2, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'id_client', 3, 'mediumint(9) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'hub_date', 4, 'date', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'context_type', 5, 'varchar(16)', 'NO', '''day''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'id_operation_evenement', 6, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'hub_label', 7, 'varchar(255)', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'flag_active', 8, 'tinyint(1) unsigned', 'NO', '1', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'hub_status', 9, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'active_session_id', 10, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'active_session_activated_at', 11, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'remote_routing_generation', 12, 'bigint(20) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'remote_routing_intent_id', 13, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'remote_transition_type', 14, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'remote_transition_payload_json', 15, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'remote_transition_started_at', 16, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'presentation_session_id', 17, 'int(10) unsigned', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'presentation_mode', 18, 'varchar(24)', 'NO', '''session''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'presentation_updated_at', 19, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'hub_master_instance_id', 20, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'hub_master_instance_seen_at', 21, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'hub_remote_instance_id', 22, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'hub_remote_instance_seen_at', 23, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'prizes_initialized_at', 24, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'delete_operation_token', 25, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'delete_step', 26, 'varchar(48)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'delete_started_at', 27, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'delete_error_at', 28, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'date_ajout', 29, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'date_maj', 30, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'player_qr_display_mode', 31, 'varchar(8)', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'player_qr_display_revision', 32, 'bigint(20) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs', 'player_qr_display_confirmation_json', 33, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs', 'player_qr_official_started_at', 34, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_sessions', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_sessions', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_sessions', 'id_session', 3, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_sessions', 'membership_source', 4, 'varchar(32)', 'NO', '''legacy_reconciled''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_sessions', 'status', 5, 'enum(''active'',''inactive'')', 'NO', '''active''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_sessions', 'created_at', 6, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_sessions', 'updated_at', 7, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'id_client', 3, 'mediumint(9) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'id_operation_evenement', 4, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'hub_token', 5, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'player_token', 6, 'varchar(96)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'auth_identity_key', 7, 'varchar(128)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'id_ep_player', 8, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'auth_type', 9, 'enum(''guest'',''ep'')', 'NO', '''guest''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'pseudo', 10, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'pseudo_normalized', 11, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'status', 12, 'enum(''active'',''left'')', 'NO', '''active''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'return_token', 13, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'return_expires_at', 14, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'created_at', 15, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'updated_at', 16, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'last_seen_at', 17, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'last_ip', 18, 'varchar(45)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'user_agent_hash', 19, 'char(40)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'hub_photo_media_id', 20, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'hub_photo_game_key', 21, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'hub_photo_source', 22, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'hub_photo_updated_at', 23, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_aggregate_score', 24, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_wins_count', 25, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_second_places_count', 26, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_third_places_count', 27, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_parties_count', 28, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_last_result_at', 29, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_source_revision', 30, 'char(40)', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players', 'stats_computed_at', 31, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_dirty_at', 32, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players', 'stats_error', 33, 'varchar(255)', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_participations_probables', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'id_client', 3, 'mediumint(9) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'id_operation_evenement', 4, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'hub_token', 5, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_participations_probables', 'auth_identity_key', 6, 'varchar(128)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_participations_probables', 'id_ep_player', 7, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'source', 8, 'varchar(32)', 'NO', '''hub_play''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_participations_probables', 'status', 9, 'enum(''declared'',''cancelled'',''confirmed'')', 'NO', '''declared''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_participations_probables', 'date_ajout', 10, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'date_maj', 11, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'declared_at', 12, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'cancelled_at', 13, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'confirmed_at', 14, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'ip', 15, 'varchar(45)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_participations_probables', 'id_user_ajout', 16, 'mediumint(9) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_participations_probables', 'id_user_maj', 17, 'mediumint(9) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'id_hub_player', 3, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'id_session', 4, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'session_token', 5, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players_sessions', 'game_type', 6, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players_sessions', 'id_participation', 7, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'participant_key', 8, 'varchar(128)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players_sessions', 'id_ep_player', 9, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'status', 10, 'enum(''created'',''active'',''left'',''completed'',''failed'')', 'NO', '''created''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players_sessions', 'auto_joined_at', 11, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'manual_joined_at', 12, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'last_joined_at', 13, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'left_at', 14, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'completed_at', 15, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'join_count', 16, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'last_action', 17, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_players_sessions', 'created_at', 18, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'updated_at', 19, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_players_sessions', 'last_error', 20, 'varchar(255)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_publication', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_publication', 'title', 3, 'varchar(150)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'tagline', 4, 'varchar(255)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'description', 5, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'location_name', 6, 'varchar(150)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'address', 7, 'varchar(180)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'postal_code', 8, 'varchar(20)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'city', 9, 'varchar(120)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'country', 10, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'website_url', 11, 'varchar(255)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'cta_label', 12, 'varchar(150)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'publication_status', 13, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_publication', 'date_ajout', 14, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_publication', 'date_maj', 15, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_prizes', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_prizes', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_prizes', 'rank', 3, 'tinyint(3) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_prizes', 'label', 4, 'varchar(120)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_prizes', 'description', 5, 'varchar(255)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_prizes', 'date_ajout', 6, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_prizes', 'date_maj', 7, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'id_client', 3, 'mediumint(9) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'remote_token', 4, 'varchar(96)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_access', 'remote_token_hash', 5, 'char(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_access', 'session_token_hash', 6, 'char(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_access', 'status', 7, 'enum(''active'',''revoked'')', 'NO', '''active''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_access', 'label', 8, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_access', 'created_at', 9, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'revoked_at', 10, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'last_seen_at', 11, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_access', 'last_ip', 12, 'varchar(45)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_access', 'user_agent_hash', 13, 'char(40)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'master_instance_id', 3, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'last_seen_at', 4, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'last_applied_preparation_revision', 5, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'last_control_revision', 6, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'visibility', 7, 'varchar(16)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'user_agent_hash', 8, 'char(40)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'created_at', 9, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'updated_at', 10, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'id_session', 3, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'execution_id', 4, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'master_instance_id', 5, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'last_seen_at', 6, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'visibility', 7, 'varchar(16)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'user_agent_hash', 8, 'char(40)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'created_at', 9, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'updated_at', 10, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'id_hub', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'id_remote_access', 3, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'command_type', 4, 'varchar(32)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'payload_json', 5, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'status', 6, 'enum(''pending'',''claimed'',''processing'',''completed'',''failed'',''expired'',''cancelled'')', 'NO', '''pending''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'remote_command_key', 7, 'varchar(96)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'created_at', 8, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'expires_at', 9, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'claimed_by', 10, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'claimed_at', 11, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'completed_at', 12, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'games_hubs_remote_commands', 'result_json', 13, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'error_code', 14, 'varchar(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'games_hubs_remote_commands', 'date_maj', 15, 'datetime', 'YES', 'NULL', '', NULL, NULL
UNION ALL
SELECT 'programming_quick_operations', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'programming_quick_operations', 'id_client', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'programming_quick_operations', 'idempotency_key', 3, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'command_hash', 4, 'char(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'status', 5, 'varchar(24)', 'NO', '''pending''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'operation_step', 6, 'varchar(32)', 'NO', '''pending''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'session_ids_json', 7, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'session_security_ids_json', 8, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'hub_id', 9, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'programming_quick_operations', 'dashboard_url', 10, 'varchar(255)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'result_json', 11, 'text', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'error_code', 12, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_operations', 'created_at', 13, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'programming_quick_operations', 'updated_at', 14, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'programming_quick_operations', 'expires_at', 15, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'programming_quick_series_operations', 'id', 1, 'int(10) unsigned', 'NO', NULL, 'auto_increment', NULL, NULL
UNION ALL
SELECT 'programming_quick_series_operations', 'id_client', 2, 'int(10) unsigned', 'NO', '0', '', NULL, NULL
UNION ALL
SELECT 'programming_quick_series_operations', 'idempotency_key', 3, 'varchar(80)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'command_hash', 4, 'char(64)', 'NO', '''''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'status', 5, 'varchar(24)', 'NO', '''pending''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'operation_step', 6, 'varchar(32)', 'NO', '''pending''', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'template_json', 7, 'mediumtext', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'recurrence_json', 8, 'mediumtext', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'occurrences_json', 9, 'mediumtext', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'themes_json', 10, 'mediumtext', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'result_json', 11, 'mediumtext', 'YES', 'NULL', '', 'utf8', 'utf8_general_ci'
UNION ALL
SELECT 'programming_quick_series_operations', 'created_at', 12, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'programming_quick_series_operations', 'updated_at', 13, 'datetime', 'NO', NULL, '', NULL, NULL
UNION ALL
SELECT 'programming_quick_series_operations', 'expires_at', 14, 'datetime', 'NO', NULL, '', NULL, NULL
),
expected_indexes(table_name,index_name,non_unique,seq_in_index,column_name) AS (
SELECT 'games_hubs', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_token', 0, 1, 'id_securite'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_context', 0, 1, 'id_client'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_context', 0, 2, 'hub_date'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_context', 0, 3, 'context_type'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_context', 0, 4, 'id_operation_evenement'
UNION ALL
SELECT 'games_hubs', 'idx_games_hubs_client_date', 1, 1, 'id_client'
UNION ALL
SELECT 'games_hubs', 'idx_games_hubs_client_date', 1, 2, 'hub_date'
UNION ALL
SELECT 'games_hubs', 'idx_games_hubs_active_session', 1, 1, 'active_session_id'
UNION ALL
SELECT 'games_hubs', 'idx_games_hubs_presentation_session', 1, 1, 'presentation_session_id'
UNION ALL
SELECT 'games_hubs', 'idx_games_hubs_operation', 1, 1, 'id_operation_evenement'
UNION ALL
SELECT 'games_hubs_sessions', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_sessions', 'uniq_games_hubs_sessions_hub_session', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_sessions', 'uniq_games_hubs_sessions_hub_session', 0, 2, 'id_session'
UNION ALL
SELECT 'games_hubs_sessions', 'idx_games_hubs_sessions_hub_status', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_sessions', 'idx_games_hubs_sessions_hub_status', 1, 2, 'status'
UNION ALL
SELECT 'games_hubs_sessions', 'idx_games_hubs_sessions_session', 1, 1, 'id_session'
UNION ALL
SELECT 'games_hubs_players', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_players', 'uniq_games_hubs_players_identity', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_players', 'uniq_games_hubs_players_identity', 0, 2, 'auth_identity_key'
UNION ALL
SELECT 'games_hubs_players', 'idx_games_hubs_players_hub_status', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_players', 'idx_games_hubs_players_hub_status', 1, 2, 'status'
UNION ALL
SELECT 'games_hubs_players', 'idx_games_hubs_players_pseudo', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_players', 'idx_games_hubs_players_pseudo', 1, 2, 'pseudo_normalized'
UNION ALL
SELECT 'games_hubs_players', 'idx_games_hubs_players_return', 1, 1, 'return_token'
UNION ALL
SELECT 'games_hubs_participations_probables', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_participations_probables', 'uniq_games_hubs_probables_identity', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_participations_probables', 'uniq_games_hubs_probables_identity', 0, 2, 'auth_identity_key'
UNION ALL
SELECT 'games_hubs_participations_probables', 'idx_games_hubs_probables_hub_status', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_participations_probables', 'idx_games_hubs_probables_hub_status', 1, 2, 'status'
UNION ALL
SELECT 'games_hubs_participations_probables', 'idx_games_hubs_probables_ep', 1, 1, 'id_ep_player'
UNION ALL
SELECT 'games_hubs_players_sessions', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_players_sessions', 'uniq_games_hubs_players_sessions_player_session', 0, 1, 'id_hub_player'
UNION ALL
SELECT 'games_hubs_players_sessions', 'uniq_games_hubs_players_sessions_player_session', 0, 2, 'id_session'
UNION ALL
SELECT 'games_hubs_players_sessions', 'idx_games_hubs_players_sessions_hub_session', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_players_sessions', 'idx_games_hubs_players_sessions_hub_session', 1, 2, 'id_session'
UNION ALL
SELECT 'games_hubs_players_sessions', 'idx_games_hubs_players_sessions_session', 1, 1, 'id_session'
UNION ALL
SELECT 'games_hubs_players_sessions', 'idx_games_hubs_players_sessions_participant', 1, 1, 'game_type'
UNION ALL
SELECT 'games_hubs_players_sessions', 'idx_games_hubs_players_sessions_participant', 1, 2, 'participant_key'
UNION ALL
SELECT 'games_hubs_publication', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_publication', 'uniq_games_hubs_publication_hub', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_prizes', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_prizes', 'uniq_games_hubs_prizes_hub_rank', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_prizes', 'uniq_games_hubs_prizes_hub_rank', 0, 2, 'rank'
UNION ALL
SELECT 'games_hubs_prizes', 'idx_games_hubs_prizes_hub', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_access', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_remote_access', 'uniq_games_hubs_remote_token_hash', 0, 1, 'remote_token_hash'
UNION ALL
SELECT 'games_hubs_remote_access', 'idx_games_hubs_remote_hub_status', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_access', 'idx_games_hubs_remote_hub_status', 1, 2, 'status'
UNION ALL
SELECT 'games_hubs_remote_access', 'idx_games_hubs_remote_session_hash', 1, 1, 'session_token_hash'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'uniq_games_hubs_remote_presence_master', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'uniq_games_hubs_remote_presence_master', 0, 2, 'master_instance_id'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'idx_games_hubs_remote_presence_seen', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'idx_games_hubs_remote_presence_seen', 1, 2, 'last_seen_at'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'uniq_games_hubs_remote_runtime_master', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'uniq_games_hubs_remote_runtime_master', 0, 2, 'id_session'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'uniq_games_hubs_remote_runtime_master', 0, 3, 'execution_id'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'uniq_games_hubs_remote_runtime_master', 0, 4, 'master_instance_id'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'idx_games_hubs_remote_runtime_seen', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'idx_games_hubs_remote_runtime_seen', 1, 2, 'id_session'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'idx_games_hubs_remote_runtime_seen', 1, 3, 'execution_id'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'idx_games_hubs_remote_runtime_seen', 1, 4, 'last_seen_at'
UNION ALL
SELECT 'games_hubs_remote_commands', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'games_hubs_remote_commands', 'uniq_games_hubs_remote_command_key', 0, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_commands', 'uniq_games_hubs_remote_command_key', 0, 2, 'remote_command_key'
UNION ALL
SELECT 'games_hubs_remote_commands', 'idx_games_hubs_remote_commands_pending', 1, 1, 'id_hub'
UNION ALL
SELECT 'games_hubs_remote_commands', 'idx_games_hubs_remote_commands_pending', 1, 2, 'status'
UNION ALL
SELECT 'games_hubs_remote_commands', 'idx_games_hubs_remote_commands_pending', 1, 3, 'expires_at'
UNION ALL
SELECT 'games_hubs_remote_commands', 'idx_games_hubs_remote_commands_pending', 1, 4, 'id'
UNION ALL
SELECT 'games_hubs_remote_commands', 'idx_games_hubs_remote_commands_access', 1, 1, 'id_remote_access'
UNION ALL
SELECT 'games_hubs_remote_commands', 'idx_games_hubs_remote_commands_access', 1, 2, 'created_at'
UNION ALL
SELECT 'programming_quick_operations', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'programming_quick_operations', 'uniq_programming_quick_client_key', 0, 1, 'id_client'
UNION ALL
SELECT 'programming_quick_operations', 'uniq_programming_quick_client_key', 0, 2, 'idempotency_key'
UNION ALL
SELECT 'programming_quick_operations', 'idx_programming_quick_expires_at', 1, 1, 'expires_at'
UNION ALL
SELECT 'programming_quick_operations', 'idx_programming_quick_client_status', 1, 1, 'id_client'
UNION ALL
SELECT 'programming_quick_operations', 'idx_programming_quick_client_status', 1, 2, 'status'
UNION ALL
SELECT 'programming_quick_series_operations', 'PRIMARY', 0, 1, 'id'
UNION ALL
SELECT 'programming_quick_series_operations', 'uniq_programming_quick_series_client_key', 0, 1, 'id_client'
UNION ALL
SELECT 'programming_quick_series_operations', 'uniq_programming_quick_series_client_key', 0, 2, 'idempotency_key'
UNION ALL
SELECT 'programming_quick_series_operations', 'idx_programming_quick_series_expires_at', 1, 1, 'expires_at'
UNION ALL
SELECT 'programming_quick_series_operations', 'idx_programming_quick_series_client_status', 1, 1, 'id_client'
UNION ALL
SELECT 'programming_quick_series_operations', 'idx_programming_quick_series_client_status', 1, 2, 'status'
),
expected_constraints(table_name,constraint_name,constraint_type) AS (
SELECT 'games_hubs', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_token', 'UNIQUE'
UNION ALL
SELECT 'games_hubs', 'uniq_games_hubs_context', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_sessions', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_sessions', 'uniq_games_hubs_sessions_hub_session', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_players', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_players', 'uniq_games_hubs_players_identity', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_participations_probables', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_participations_probables', 'uniq_games_hubs_probables_identity', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_players_sessions', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_players_sessions', 'uniq_games_hubs_players_sessions_player_session', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_publication', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_publication', 'uniq_games_hubs_publication_hub', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_prizes', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_prizes', 'uniq_games_hubs_prizes_hub_rank', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_remote_access', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_remote_access', 'uniq_games_hubs_remote_token_hash', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_remote_master_presence', 'uniq_games_hubs_remote_presence_master', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_remote_runtime_presence', 'uniq_games_hubs_remote_runtime_master', 'UNIQUE'
UNION ALL
SELECT 'games_hubs_remote_commands', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'games_hubs_remote_commands', 'uniq_games_hubs_remote_command_key', 'UNIQUE'
UNION ALL
SELECT 'programming_quick_operations', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'programming_quick_operations', 'uniq_programming_quick_client_key', 'UNIQUE'
UNION ALL
SELECT 'programming_quick_series_operations', 'PRIMARY', 'PRIMARY KEY'
UNION ALL
SELECT 'programming_quick_series_operations', 'uniq_programming_quick_series_client_key', 'UNIQUE'
),
actual_tables AS (SELECT * FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND TABLE_NAME IN (SELECT table_name FROM expected_tables)),
actual_columns AS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND TABLE_NAME IN (SELECT table_name FROM expected_tables)),
actual_indexes AS (SELECT * FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND TABLE_NAME IN (SELECT table_name FROM expected_tables)),
actual_constraints AS (SELECT * FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND TABLE_NAME IN (SELECT table_name FROM expected_tables)),
issues AS (
SELECT e.table_name AS object_name, 'TABLE_ABSENTE_OU_ENGINE_COLLATION_TYPE' AS problem
FROM expected_tables e LEFT JOIN actual_tables a ON a.TABLE_NAME=e.table_name
WHERE a.TABLE_NAME IS NULL OR a.TABLE_TYPE <> 'BASE TABLE' OR a.ENGINE <> 'InnoDB'
   OR REPLACE(a.TABLE_COLLATION,'utf8mb3','utf8') <> 'utf8_general_ci'
UNION ALL
SELECT CONCAT(e.table_name,'.',e.column_name), 'COLONNE_ABSENTE_OU_DEFINITION'
FROM expected_columns e LEFT JOIN actual_columns a ON a.TABLE_NAME=e.table_name AND a.COLUMN_NAME=e.column_name
WHERE a.COLUMN_NAME IS NULL OR a.ORDINAL_POSITION <> e.ordinal_position
   OR NOT (BINARY a.COLUMN_TYPE <=> BINARY e.column_type)
   OR NOT (a.IS_NULLABLE <=> e.is_nullable)
   OR NOT (BINARY a.COLUMN_DEFAULT <=> BINARY e.column_default)
   OR NOT (BINARY a.EXTRA <=> BINARY e.extra)
   OR NOT (REPLACE(a.CHARACTER_SET_NAME,'utf8mb3','utf8') <=> e.character_set_name)
   OR NOT (REPLACE(a.COLLATION_NAME,'utf8mb3','utf8') <=> e.collation_name)
UNION ALL
SELECT CONCAT(a.TABLE_NAME,'.',a.COLUMN_NAME), 'COLONNE_INATTENDUE'
FROM actual_columns a LEFT JOIN expected_columns e ON a.TABLE_NAME=e.table_name AND a.COLUMN_NAME=e.column_name
WHERE e.column_name IS NULL
UNION ALL
SELECT CONCAT(e.table_name,'.',e.index_name,'#',e.seq_in_index), 'INDEX_ABSENT_OU_DEFINITION'
FROM expected_indexes e LEFT JOIN actual_indexes a ON a.TABLE_NAME=e.table_name AND a.INDEX_NAME=e.index_name AND a.SEQ_IN_INDEX=e.seq_in_index
WHERE a.INDEX_NAME IS NULL OR a.NON_UNIQUE<>e.non_unique OR a.COLUMN_NAME<>e.column_name
   OR a.SUB_PART IS NOT NULL OR a.INDEX_TYPE<>'BTREE' OR NOT(a.COLLATION <=> 'A')
UNION ALL
SELECT CONCAT(a.TABLE_NAME,'.',a.INDEX_NAME,'#',a.SEQ_IN_INDEX), 'INDEX_INATTENDU'
FROM actual_indexes a LEFT JOIN expected_indexes e ON a.TABLE_NAME=e.table_name AND a.INDEX_NAME=e.index_name AND a.SEQ_IN_INDEX=e.seq_in_index
WHERE e.index_name IS NULL
UNION ALL
SELECT CONCAT(e.table_name,'.',e.constraint_name), 'CONTRAINTE_ABSENTE_OU_TYPE'
FROM expected_constraints e LEFT JOIN actual_constraints a ON a.TABLE_NAME=e.table_name AND a.CONSTRAINT_NAME=e.constraint_name
WHERE a.CONSTRAINT_NAME IS NULL OR a.CONSTRAINT_TYPE<>e.constraint_type
UNION ALL
SELECT CONCAT(a.TABLE_NAME,'.',a.CONSTRAINT_NAME), 'CONTRAINTE_INATTENDUE'
FROM actual_constraints a LEFT JOIN expected_constraints e ON a.TABLE_NAME=e.table_name AND a.CONSTRAINT_NAME=e.constraint_name
WHERE e.constraint_name IS NULL
UNION ALL
SELECT CONCAT(EVENT_OBJECT_TABLE,'.',TRIGGER_NAME), 'TRIGGER_INATTENDU'
FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'prod_cotton_global_0'
UNION ALL
SELECT TABLE_NAME, 'TABLE_HUB_INATTENDUE'
FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'prod_cotton_global_0'
AND LEFT(TABLE_NAME,10)='games_hubs' AND TABLE_NAME NOT IN (SELECT table_name FROM expected_tables)
)
SELECT object_name, problem FROM issues ORDER BY object_name, problem;

-- Aucun nom fourni par l'utilisateur : deux chaînes SELECT fixes, aucun DDL dynamique.

SET @cotton_hub_count_sql = IF(@cotton_hub_schema_issues = 0,
'WITH counts AS (SELECT ''games_hubs'' AS table_name, COUNT(*) AS row_count FROM `prod_cotton_global_0`.`games_hubs` UNION ALL SELECT ''games_hubs_sessions'' AS table_name, COUNT(*) AS row_count FROM `prod_cotton_global_0`.`games_hubs_sessions` UNION ALL SELECT ''games_hubs_players'' AS table_name, COUNT(*) AS row_count FROM `prod_cotton_global_0`.`games_hubs_players` UNION ALL SELECT ''games_hubs_participations_probables'' AS table_name, COUNT(*) AS row_count FROM `prod_cotton_global_0`.`games_hubs_participations_probables` UNION ALL SELECT ''games_hubs_players_sessions'' AS table_name, COUNT(*) AS row_count FROM `prod_cotton_global_0`.`games_hubs_players_sessions` UNION ALL SELECT ''games_hubs_publication'' AS table_name, COUNT(*) AS row_count FROM `prod_cotton_global_0`.`games_hubs_publication` UNION ALL SELECT ''games_hubs_prizes'' AS table_name, COUNT(*) AS row_count FROM `prod_cotton_global_0`.`games_hubs_prizes` UNION ALL SELECT ''games_hubs_remote_access'' AS table_name, COUNT(*) AS row_count FROM `prod_cotton_global_0`.`games_hubs_remote_access` UNION ALL SELECT ''games_hubs_remote_master_presence'' AS table_name, COUNT(*) AS row_count FROM `prod_cotton_global_0`.`games_hubs_remote_master_presence` UNION ALL SELECT ''games_hubs_remote_runtime_presence'' AS table_name, COUNT(*) AS row_count FROM `prod_cotton_global_0`.`games_hubs_remote_runtime_presence` UNION ALL SELECT ''games_hubs_remote_commands'' AS table_name, COUNT(*) AS row_count FROM `prod_cotton_global_0`.`games_hubs_remote_commands` UNION ALL SELECT ''programming_quick_operations'' AS table_name, COUNT(*) AS row_count FROM `prod_cotton_global_0`.`programming_quick_operations` UNION ALL SELECT ''programming_quick_series_operations'' AS table_name, COUNT(*) AS row_count FROM `prod_cotton_global_0`.`programming_quick_series_operations`) SELECT table_name, row_count, ''-'' AS SCHEMA_READY_FOR_BACKFILL FROM counts UNION ALL SELECT ''#TOTAL_13_TABLES'', SUM(row_count), IF(SUM(row_count)=0,''YES'',''NO'') FROM counts',
'SELECT ''NO'' AS SCHEMA_READY_FOR_BACKFILL, ''Structure non conforme ou contrôle incomplet ; comptages non exécutés'' AS reason');

PREPARE cotton_hub_count_stmt FROM @cotton_hub_count_sql;

EXECUTE cotton_hub_count_stmt;

DEALLOCATE PREPARE cotton_hub_count_stmt;
