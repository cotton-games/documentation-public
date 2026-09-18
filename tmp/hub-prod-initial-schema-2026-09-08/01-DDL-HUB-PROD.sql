-- Phase 1 Hub PROD : 13 nouvelles tables, aucune donnée métier.
-- Cible explicite : prod_cotton_global_0 ; MariaDB 10.3.39.
-- PRECHECK fourni et analysé ; sauvegarde requise avant exécution opérateur.
-- InnoDB / utf8 / utf8_general_ci explicitement choisis, indépendants du défaut latin1 de la base.
-- Lire README : IF NOT EXISTS ne valide pas un objet déjà présent.
-- Arrêter sur erreur ; ne rejouer aucune migration historique après ce fichier.
-- Aucun ALTER legacy, INSERT, trigger, routine, événement ni conversion de table existante.

-- Étape 01/13 : games_hubs
-- Objet : Identité/contexte, routing/intent/transition, activation, présentation, instances, lots, suppression et QR (4 champs dédiés).
-- Source : global/web/app/modules/jeux/hubs/app_games_hubs_functions.php::app_games_hub_schema_ensure
-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.
-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.
-- QR : app_games_hub_player_qr_functions.php::app_games_hub_player_qr_schema_check.
SELECT '01/13 games_hubs BEGIN' AS ddl_step;
CREATE TABLE IF NOT EXISTS `prod_cotton_global_0`.`games_hubs` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_securite` varchar(64) NOT NULL DEFAULT '',
  `id_client` mediumint(9) UNSIGNED NOT NULL DEFAULT 0,
  `hub_date` date NOT NULL,
  `context_type` varchar(16) NOT NULL DEFAULT 'day',
  `id_operation_evenement` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `hub_label` varchar(255) DEFAULT NULL,
  `flag_active` tinyint(1) UNSIGNED NOT NULL DEFAULT 1,
  `hub_status` varchar(32) NOT NULL DEFAULT '',
  `active_session_id` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `active_session_activated_at` datetime DEFAULT NULL,
  `remote_routing_generation` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `remote_routing_intent_id` varchar(80) NOT NULL DEFAULT '',
  `remote_transition_type` varchar(32) NOT NULL DEFAULT '',
  `remote_transition_payload_json` text DEFAULT NULL,
  `remote_transition_started_at` datetime DEFAULT NULL,
  `presentation_session_id` int(10) UNSIGNED DEFAULT NULL,
  `presentation_mode` varchar(24) NOT NULL DEFAULT 'session',
  `presentation_updated_at` datetime DEFAULT NULL,
  `hub_master_instance_id` varchar(80) NOT NULL DEFAULT '',
  `hub_master_instance_seen_at` datetime DEFAULT NULL,
  `hub_remote_instance_id` varchar(80) NOT NULL DEFAULT '',
  `hub_remote_instance_seen_at` datetime DEFAULT NULL,
  `prizes_initialized_at` datetime DEFAULT NULL,
  `delete_operation_token` varchar(80) NOT NULL DEFAULT '',
  `delete_step` varchar(48) NOT NULL DEFAULT '',
  `delete_started_at` datetime DEFAULT NULL,
  `delete_error_at` datetime DEFAULT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime DEFAULT NULL,
  `player_qr_display_mode` varchar(8) NULL DEFAULT NULL,
  `player_qr_display_revision` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `player_qr_display_confirmation_json` text NULL DEFAULT NULL,
  `player_qr_official_started_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_games_hubs_token` (`id_securite`),
  UNIQUE KEY `uniq_games_hubs_context` (`id_client`,`hub_date`,`context_type`,`id_operation_evenement`),
  KEY `idx_games_hubs_client_date` (`id_client`,`hub_date`),
  KEY `idx_games_hubs_active_session` (`active_session_id`),
  KEY `idx_games_hubs_presentation_session` (`presentation_session_id`),
  KEY `idx_games_hubs_operation` (`id_operation_evenement`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SHOW WARNINGS;
SELECT '01/13 games_hubs END - contrôler WARNINGS et POSTCHECK' AS ddl_step;

-- Étape 02/13 : games_hubs_sessions
-- Objet : Membership canonique explicite Hub/session, unicité du couple et état.
-- Source : global/web/app/modules/jeux/hubs/app_games_hubs_functions.php::app_games_hub_schema_ensure
-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.
-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.
SELECT '02/13 games_hubs_sessions BEGIN' AS ddl_step;
CREATE TABLE IF NOT EXISTS `prod_cotton_global_0`.`games_hubs_sessions` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_hub` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `id_session` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `membership_source` varchar(32) NOT NULL DEFAULT 'legacy_reconciled',
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_games_hubs_sessions_hub_session` (`id_hub`,`id_session`),
  KEY `idx_games_hubs_sessions_hub_status` (`id_hub`,`status`),
  KEY `idx_games_hubs_sessions_session` (`id_session`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SHOW WARNINGS;
SELECT '02/13 games_hubs_sessions END - contrôler WARNINGS et POSTCHECK' AS ddl_step;

-- Étape 03/13 : games_hubs_players
-- Objet : Identités Hub, roster, photo active et dix agrégats stats persistés.
-- Source : global/web/app/modules/jeux/hubs/app_games_hubs_functions.php::app_games_hub_schema_ensure
-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.
-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.
-- Stats : migration 2026-07-30 + app_games_hub_players_stats_columns/_rebuild ; photo : ensure courant.
SELECT '03/13 games_hubs_players BEGIN' AS ddl_step;
CREATE TABLE IF NOT EXISTS `prod_cotton_global_0`.`games_hubs_players` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_hub` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `id_client` mediumint(9) UNSIGNED NOT NULL DEFAULT 0,
  `id_operation_evenement` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `hub_token` varchar(64) NOT NULL DEFAULT '',
  `player_token` varchar(96) NOT NULL DEFAULT '',
  `auth_identity_key` varchar(128) NOT NULL DEFAULT '',
  `id_ep_player` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `auth_type` enum('guest','ep') NOT NULL DEFAULT 'guest',
  `pseudo` varchar(80) NOT NULL DEFAULT '',
  `pseudo_normalized` varchar(80) NOT NULL DEFAULT '',
  `status` enum('active','left') NOT NULL DEFAULT 'active',
  `return_token` varchar(64) NOT NULL DEFAULT '',
  `return_expires_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_seen_at` datetime DEFAULT NULL,
  `last_ip` varchar(45) NOT NULL DEFAULT '',
  `user_agent_hash` char(40) NOT NULL DEFAULT '',
  `hub_photo_media_id` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `hub_photo_game_key` varchar(32) NOT NULL DEFAULT '',
  `hub_photo_source` varchar(32) NOT NULL DEFAULT '',
  `hub_photo_updated_at` datetime DEFAULT NULL,
  `stats_aggregate_score` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `stats_wins_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `stats_second_places_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `stats_third_places_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `stats_parties_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `stats_last_result_at` datetime DEFAULT NULL,
  `stats_source_revision` char(40) DEFAULT NULL,
  `stats_computed_at` datetime DEFAULT NULL,
  `stats_dirty_at` datetime DEFAULT NULL,
  `stats_error` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_games_hubs_players_identity` (`id_hub`,`auth_identity_key`),
  KEY `idx_games_hubs_players_hub_status` (`id_hub`,`status`),
  KEY `idx_games_hubs_players_pseudo` (`id_hub`,`pseudo_normalized`),
  KEY `idx_games_hubs_players_return` (`return_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SHOW WARNINGS;
SELECT '03/13 games_hubs_players END - contrôler WARNINGS et POSTCHECK' AS ddl_step;

-- Étape 04/13 : games_hubs_participations_probables
-- Objet : Déclaration probable Hub distincte du roster et des participations legacy.
-- Source : global/web/app/modules/jeux/hubs/app_games_hubs_functions.php::app_games_hub_schema_ensure
-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.
-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.
SELECT '04/13 games_hubs_participations_probables BEGIN' AS ddl_step;
CREATE TABLE IF NOT EXISTS `prod_cotton_global_0`.`games_hubs_participations_probables` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_hub` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `id_client` mediumint(9) UNSIGNED NOT NULL DEFAULT 0,
  `id_operation_evenement` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `hub_token` varchar(64) NOT NULL DEFAULT '',
  `auth_identity_key` varchar(128) NOT NULL DEFAULT '',
  `id_ep_player` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `source` varchar(32) NOT NULL DEFAULT 'hub_play',
  `status` enum('declared','cancelled','confirmed') NOT NULL DEFAULT 'declared',
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime DEFAULT NULL,
  `declared_at` datetime DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `ip` varchar(45) NOT NULL DEFAULT '',
  `id_user_ajout` mediumint(9) UNSIGNED NOT NULL DEFAULT 0,
  `id_user_maj` mediumint(9) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_games_hubs_probables_identity` (`id_hub`,`auth_identity_key`),
  KEY `idx_games_hubs_probables_hub_status` (`id_hub`,`status`),
  KEY `idx_games_hubs_probables_ep` (`id_ep_player`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SHOW WARNINGS;
SELECT '04/13 games_hubs_participations_probables END - contrôler WARNINGS et POSTCHECK' AS ddl_step;

-- Étape 05/13 : games_hubs_players_sessions
-- Objet : Mapping joueur/session, identité runtime et cycle accès incluant left.
-- Source : global/web/app/modules/jeux/hubs/app_games_hubs_functions.php::app_games_hub_schema_ensure
-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.
-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.
SELECT '05/13 games_hubs_players_sessions BEGIN' AS ddl_step;
CREATE TABLE IF NOT EXISTS `prod_cotton_global_0`.`games_hubs_players_sessions` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_hub` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `id_hub_player` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `id_session` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `session_token` varchar(64) NOT NULL DEFAULT '',
  `game_type` varchar(32) NOT NULL DEFAULT '',
  `id_participation` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `participant_key` varchar(128) NOT NULL DEFAULT '',
  `id_ep_player` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `status` enum('created','active','left','completed','failed') NOT NULL DEFAULT 'created',
  `auto_joined_at` datetime DEFAULT NULL,
  `manual_joined_at` datetime DEFAULT NULL,
  `last_joined_at` datetime DEFAULT NULL,
  `left_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `join_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `last_action` varchar(32) NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_error` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_games_hubs_players_sessions_player_session` (`id_hub_player`,`id_session`),
  KEY `idx_games_hubs_players_sessions_hub_session` (`id_hub`,`id_session`),
  KEY `idx_games_hubs_players_sessions_session` (`id_session`),
  KEY `idx_games_hubs_players_sessions_participant` (`game_type`,`participant_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SHOW WARNINGS;
SELECT '05/13 games_hubs_players_sessions END - contrôler WARNINGS et POSTCHECK' AS ddl_step;

-- Étape 06/13 : games_hubs_publication
-- Objet : Publication éditoriale et informations pratiques du Hub.
-- Source : global/web/app/modules/jeux/hubs/app_games_hubs_functions.php::app_games_hub_schema_ensure
-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.
-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.
SELECT '06/13 games_hubs_publication BEGIN' AS ddl_step;
CREATE TABLE IF NOT EXISTS `prod_cotton_global_0`.`games_hubs_publication` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_hub` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `title` varchar(150) NOT NULL DEFAULT '',
  `tagline` varchar(255) NOT NULL DEFAULT '',
  `description` text,
  `location_name` varchar(150) NOT NULL DEFAULT '',
  `address` varchar(180) NOT NULL DEFAULT '',
  `postal_code` varchar(20) NOT NULL DEFAULT '',
  `city` varchar(120) NOT NULL DEFAULT '',
  `country` varchar(80) NOT NULL DEFAULT '',
  `website_url` varchar(255) NOT NULL DEFAULT '',
  `cta_label` varchar(150) NOT NULL DEFAULT '',
  `publication_status` varchar(32) NOT NULL DEFAULT '',
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_games_hubs_publication_hub` (`id_hub`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SHOW WARNINGS;
SELECT '06/13 games_hubs_publication END - contrôler WARNINGS et POSTCHECK' AS ddl_step;

-- Étape 07/13 : games_hubs_prizes
-- Objet : Lots globaux par rang, indépendants des lots session historiques.
-- Source : global/web/app/modules/jeux/hubs/app_games_hubs_functions.php::app_games_hub_schema_ensure
-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.
-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.
SELECT '07/13 games_hubs_prizes BEGIN' AS ddl_step;
CREATE TABLE IF NOT EXISTS `prod_cotton_global_0`.`games_hubs_prizes` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_hub` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `rank` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `label` varchar(120) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_games_hubs_prizes_hub_rank` (`id_hub`,`rank`),
  KEY `idx_games_hubs_prizes_hub` (`id_hub`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SHOW WARNINGS;
SELECT '07/13 games_hubs_prizes END - contrôler WARNINGS et POSTCHECK' AS ddl_step;

-- Étape 08/13 : games_hubs_remote_access
-- Objet : Accès Remote, tokens et révocation.
-- Source : global/web/app/modules/jeux/hubs/app_games_hubs_functions.php::app_games_hub_schema_ensure
-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.
-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.
SELECT '08/13 games_hubs_remote_access BEGIN' AS ddl_step;
CREATE TABLE IF NOT EXISTS `prod_cotton_global_0`.`games_hubs_remote_access` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_hub` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `id_client` mediumint(9) UNSIGNED NOT NULL DEFAULT 0,
  `remote_token` varchar(96) NOT NULL DEFAULT '',
  `remote_token_hash` char(64) NOT NULL DEFAULT '',
  `session_token_hash` char(64) NOT NULL DEFAULT '',
  `status` enum('active','revoked') NOT NULL DEFAULT 'active',
  `label` varchar(80) NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `last_seen_at` datetime DEFAULT NULL,
  `last_ip` varchar(45) NOT NULL DEFAULT '',
  `user_agent_hash` char(40) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_games_hubs_remote_token_hash` (`remote_token_hash`),
  KEY `idx_games_hubs_remote_hub_status` (`id_hub`,`status`),
  KEY `idx_games_hubs_remote_session_hash` (`session_token_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SHOW WARNINGS;
SELECT '08/13 games_hubs_remote_access END - contrôler WARNINGS et POSTCHECK' AS ddl_step;

-- Étape 09/13 : games_hubs_remote_master_presence
-- Objet : Présence/lease Master et révisions appliquées.
-- Source : global/web/app/modules/jeux/hubs/app_games_hubs_functions.php::app_games_hub_schema_ensure
-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.
-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.
SELECT '09/13 games_hubs_remote_master_presence BEGIN' AS ddl_step;
CREATE TABLE IF NOT EXISTS `prod_cotton_global_0`.`games_hubs_remote_master_presence` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_hub` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `master_instance_id` varchar(80) NOT NULL DEFAULT '',
  `last_seen_at` datetime NOT NULL,
  `last_applied_preparation_revision` varchar(64) NOT NULL DEFAULT '',
  `last_control_revision` varchar(64) NOT NULL DEFAULT '',
  `visibility` varchar(16) NOT NULL DEFAULT '',
  `user_agent_hash` char(40) NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_games_hubs_remote_presence_master` (`id_hub`,`master_instance_id`),
  KEY `idx_games_hubs_remote_presence_seen` (`id_hub`,`last_seen_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SHOW WARNINGS;
SELECT '09/13 games_hubs_remote_master_presence END - contrôler WARNINGS et POSTCHECK' AS ddl_step;

-- Étape 10/13 : games_hubs_remote_runtime_presence
-- Objet : Présence runtime corrélée à session/exécution/instance.
-- Source : global/web/app/modules/jeux/hubs/app_games_hubs_functions.php::app_games_hub_schema_ensure
-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.
-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.
SELECT '10/13 games_hubs_remote_runtime_presence BEGIN' AS ddl_step;
CREATE TABLE IF NOT EXISTS `prod_cotton_global_0`.`games_hubs_remote_runtime_presence` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_hub` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `id_session` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `execution_id` varchar(80) NOT NULL DEFAULT '',
  `master_instance_id` varchar(80) NOT NULL DEFAULT '',
  `last_seen_at` datetime NOT NULL,
  `visibility` varchar(16) NOT NULL DEFAULT '',
  `user_agent_hash` char(40) NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_games_hubs_remote_runtime_master` (`id_hub`,`id_session`,`execution_id`,`master_instance_id`),
  KEY `idx_games_hubs_remote_runtime_seen` (`id_hub`,`id_session`,`execution_id`,`last_seen_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SHOW WARNINGS;
SELECT '10/13 games_hubs_remote_runtime_presence END - contrôler WARNINGS et POSTCHECK' AS ddl_step;

-- Étape 11/13 : games_hubs_remote_commands
-- Objet : Queue Remote, idempotence, claim, résultat et reçus QR.
-- Source : global/web/app/modules/jeux/hubs/app_games_hubs_functions.php::app_games_hub_schema_ensure
-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.
-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.
SELECT '11/13 games_hubs_remote_commands BEGIN' AS ddl_step;
CREATE TABLE IF NOT EXISTS `prod_cotton_global_0`.`games_hubs_remote_commands` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_hub` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `id_remote_access` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `command_type` varchar(32) NOT NULL DEFAULT '',
  `payload_json` text,
  `status` enum('pending','claimed','processing','completed','failed','expired','cancelled') NOT NULL DEFAULT 'pending',
  `remote_command_key` varchar(96) NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  `claimed_by` varchar(80) NOT NULL DEFAULT '',
  `claimed_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `result_json` text,
  `error_code` varchar(64) NOT NULL DEFAULT '',
  `date_maj` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_games_hubs_remote_command_key` (`id_hub`,`remote_command_key`),
  KEY `idx_games_hubs_remote_commands_pending` (`id_hub`,`status`,`expires_at`,`id`),
  KEY `idx_games_hubs_remote_commands_access` (`id_remote_access`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SHOW WARNINGS;
SELECT '11/13 games_hubs_remote_commands END - contrôler WARNINGS et POSTCHECK' AS ddl_step;

-- Étape 12/13 : programming_quick_operations
-- Objet : Prérequis associé Quick Schedule : commande idempotente, étapes de reprise, Hub/session et résultat.
-- Source : documentation/programming_quick_operations_phpmyadmin.sql
-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.
-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.
SELECT '12/13 programming_quick_operations BEGIN' AS ddl_step;
CREATE TABLE IF NOT EXISTS `prod_cotton_global_0`.`programming_quick_operations` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_client` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `idempotency_key` varchar(80) NOT NULL DEFAULT '',
  `command_hash` char(64) NOT NULL DEFAULT '',
  `status` varchar(24) NOT NULL DEFAULT 'pending',
  `operation_step` varchar(32) NOT NULL DEFAULT 'pending',
  `session_ids_json` text,
  `session_security_ids_json` text,
  `hub_id` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `dashboard_url` varchar(255) NOT NULL DEFAULT '',
  `result_json` text,
  `error_code` varchar(80) NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_programming_quick_client_key` (`id_client`,`idempotency_key`),
  KEY `idx_programming_quick_expires_at` (`expires_at`),
  KEY `idx_programming_quick_client_status` (`id_client`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SHOW WARNINGS;
SELECT '12/13 programming_quick_operations END - contrôler WARNINGS et POSTCHECK' AS ddl_step;

-- Étape 13/13 : programming_quick_series_operations
-- Objet : Prérequis associé Quick Schedule récurrent : template, occurrences, thèmes et résultat.
-- Source : documentation/programming_quick_series_operations_phpmyadmin.sql
-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.
-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.
SELECT '13/13 programming_quick_series_operations BEGIN' AS ddl_step;
CREATE TABLE IF NOT EXISTS `prod_cotton_global_0`.`programming_quick_series_operations` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_client` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `idempotency_key` varchar(80) NOT NULL DEFAULT '',
  `command_hash` char(64) NOT NULL DEFAULT '',
  `status` varchar(24) NOT NULL DEFAULT 'pending',
  `operation_step` varchar(32) NOT NULL DEFAULT 'pending',
  `template_json` mediumtext,
  `recurrence_json` mediumtext,
  `occurrences_json` mediumtext,
  `themes_json` mediumtext,
  `result_json` mediumtext,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_programming_quick_series_client_key` (`id_client`,`idempotency_key`),
  KEY `idx_programming_quick_series_expires_at` (`expires_at`),
  KEY `idx_programming_quick_series_client_status` (`id_client`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SHOW WARNINGS;
SELECT '13/13 programming_quick_series_operations END - contrôler WARNINGS et POSTCHECK' AS ddl_step;

SELECT 'DDL terminé : exécuter 02-POSTCHECK-SCHEMA.sql ; aucun backfill/code maintenant' AS next_step;
