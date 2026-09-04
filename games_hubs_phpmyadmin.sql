-- Cotton games - hub soiree/evenement Lot 1
-- Import phpMyAdmin / MySQL.
-- Idempotent: creation only, no destructive statement.

CREATE TABLE IF NOT EXISTS `games_hubs` (
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
  `prizes_initialized_at` datetime DEFAULT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_games_hubs_token` (`id_securite`),
  UNIQUE KEY `uniq_games_hubs_context` (`id_client`,`hub_date`,`context_type`,`id_operation_evenement`),
  KEY `idx_games_hubs_client_date` (`id_client`,`hub_date`),
  KEY `idx_games_hubs_active_session` (`active_session_id`),
  KEY `idx_games_hubs_operation` (`id_operation_evenement`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE TABLE IF NOT EXISTS `games_hubs_sessions` (
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
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
