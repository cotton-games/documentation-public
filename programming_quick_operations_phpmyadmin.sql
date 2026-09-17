-- Cotton - Programmation rapide
-- Installation canonique de la table d'idempotence/reprise.
-- À appliquer hors requête HTTP avant activation du programmateur rapide.

CREATE TABLE IF NOT EXISTS `programming_quick_operations` (
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
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Mise à niveau si la table avait été créée par la première version HTTP.
ALTER TABLE `programming_quick_operations`
  ADD COLUMN IF NOT EXISTS `operation_step` varchar(32) NOT NULL DEFAULT 'pending' AFTER `status`,
  ADD COLUMN IF NOT EXISTS `session_ids_json` text AFTER `operation_step`,
  ADD COLUMN IF NOT EXISTS `session_security_ids_json` text AFTER `session_ids_json`,
  ADD COLUMN IF NOT EXISTS `hub_id` int(10) UNSIGNED NOT NULL DEFAULT 0 AFTER `session_security_ids_json`,
  ADD COLUMN IF NOT EXISTS `dashboard_url` varchar(255) NOT NULL DEFAULT '' AFTER `hub_id`;
