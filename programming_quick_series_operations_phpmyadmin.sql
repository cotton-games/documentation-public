-- Cotton - Programmation rapide récurrente
-- Installation canonique de l'opération persistée de série.
-- À appliquer hors requête HTTP avant activation de la récurrence quick-schedule.

CREATE TABLE IF NOT EXISTS `programming_quick_series_operations` (
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
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
