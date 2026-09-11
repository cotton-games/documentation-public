-- Cotton games - Hub/session structural membership
-- Import phpMyAdmin / MySQL.
-- Idempotent: creates the table if missing and backfills only unambiguous legacy memberships.

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

-- Backfill borne: seules les sessions ayant exactement un Hub actif candidat
-- selon les anciennes regles client+date / operation sont materialisees.
INSERT IGNORE INTO `games_hubs_sessions`
  (`id_hub`, `id_session`, `membership_source`, `status`, `created_at`, `updated_at`)
SELECT
  h.id,
  cs.id,
  'legacy_reconciled',
  'active',
  NOW(),
  NOW()
FROM `championnats_sessions` cs
INNER JOIN `games_hubs` h
  ON h.id_client = cs.id_client
  AND h.hub_date = cs.date
  AND h.flag_active = 1
  AND (h.id_operation_evenement = 0 OR h.id_operation_evenement = cs.id_operation_evenement)
WHERE cs.flag_session_demo = 0
  AND cs.flag_configuration_complete = 1
  AND (
    SELECT COUNT(*)
    FROM `games_hubs` h2
    WHERE h2.id_client = cs.id_client
      AND h2.hub_date = cs.date
      AND h2.flag_active = 1
      AND (h2.id_operation_evenement = 0 OR h2.id_operation_evenement = cs.id_operation_evenement)
  ) = 1
  AND NOT EXISTS (
    SELECT 1
    FROM `games_hubs_sessions` ghs
    WHERE ghs.id_session = cs.id
      AND ghs.status = 'active'
      AND ghs.id_hub <> h.id
  );

-- Controle avant/apres: liaisons actives par Hub.
SELECT id_hub, COUNT(*) AS active_sessions
FROM `games_hubs_sessions`
WHERE status = 'active'
GROUP BY id_hub
ORDER BY id_hub;

-- Controle ambiguite: sessions qui restent volontairement non backfillees
-- car plusieurs Hubs actifs peuvent les revendiquer via les regles legacy.
SELECT
  cs.id AS id_session,
  cs.id_client,
  cs.date AS session_date,
  GROUP_CONCAT(h.id ORDER BY h.id) AS matching_hub_ids
FROM `championnats_sessions` cs
INNER JOIN `games_hubs` h
  ON h.id_client = cs.id_client
  AND h.hub_date = cs.date
  AND h.flag_active = 1
  AND (h.id_operation_evenement = 0 OR h.id_operation_evenement = cs.id_operation_evenement)
LEFT JOIN `games_hubs_sessions` ghs
  ON ghs.id_session = cs.id
  AND ghs.status = 'active'
WHERE cs.flag_session_demo = 0
  AND cs.flag_configuration_complete = 1
  AND ghs.id IS NULL
GROUP BY cs.id, cs.id_client, cs.date
HAVING COUNT(h.id) > 1
ORDER BY cs.date DESC, cs.id DESC;

-- Rollback non destructif:
-- UPDATE `games_hubs_sessions`
-- SET status = 'inactive', updated_at = NOW()
-- WHERE membership_source = 'legacy_reconciled' AND status = 'active';
