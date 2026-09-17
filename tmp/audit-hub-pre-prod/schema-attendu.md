# Inventaire du schéma Hub attendu (code local, aucune preuve PROD)

Source : global/web/app/modules/jeux/hubs/app_games_hubs_functions.php, app_games_hub_schema_ensure(), lignes 176–539.

## games_hubs

Définition embarquée à la ligne 184. Les anciennes tables existantes ne sont pas entièrement réalignées par CREATE IF NOT EXISTS.

```sql
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
        PRIMARY KEY (`id`),
        UNIQUE KEY `uniq_games_hubs_token` (`id_securite`),
        UNIQUE KEY `uniq_games_hubs_context` (`id_client`,`hub_date`,`context_type`,`id_operation_evenement`),
        KEY `idx_games_hubs_client_date` (`id_client`,`hub_date`),
        KEY `idx_games_hubs_active_session` (`active_session_id`),
        KEY `idx_games_hubs_presentation_session` (`presentation_session_id`),
        KEY `idx_games_hubs_operation` (`id_operation_evenement`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
```

## games_hubs_sessions

Définition embarquée à la ligne 275. Les anciennes tables existantes ne sont pas entièrement réalignées par CREATE IF NOT EXISTS.

```sql
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
```

## games_hubs_players

Définition embarquée à la ligne 292. Les anciennes tables existantes ne sont pas entièrement réalignées par CREATE IF NOT EXISTS.

```sql
CREATE TABLE IF NOT EXISTS `games_hubs_players` (
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
            PRIMARY KEY (`id`),
            UNIQUE KEY `uniq_games_hubs_players_identity` (`id_hub`,`auth_identity_key`),
            KEY `idx_games_hubs_players_hub_status` (`id_hub`,`status`),
            KEY `idx_games_hubs_players_pseudo` (`id_hub`,`pseudo_normalized`),
            KEY `idx_games_hubs_players_return` (`return_token`)
        ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
```

## games_hubs_participations_probables

Définition embarquée à la ligne 325. Les anciennes tables existantes ne sont pas entièrement réalignées par CREATE IF NOT EXISTS.

```sql
CREATE TABLE IF NOT EXISTS `games_hubs_participations_probables` (
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
        ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
```

## games_hubs_players_sessions

Définition embarquée à la ligne 365. Les anciennes tables existantes ne sont pas entièrement réalignées par CREATE IF NOT EXISTS.

```sql
CREATE TABLE IF NOT EXISTS `games_hubs_players_sessions` (
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
        ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
```

## games_hubs_publication

Définition embarquée à la ligne 414. Les anciennes tables existantes ne sont pas entièrement réalignées par CREATE IF NOT EXISTS.

```sql
CREATE TABLE IF NOT EXISTS `games_hubs_publication` (
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
        ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
```

## games_hubs_prizes

Définition embarquée à la ligne 437. Les anciennes tables existantes ne sont pas entièrement réalignées par CREATE IF NOT EXISTS.

```sql
CREATE TABLE IF NOT EXISTS `games_hubs_prizes` (
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
        ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
```

## games_hubs_remote_access

Définition embarquée à la ligne 453. Les anciennes tables existantes ne sont pas entièrement réalignées par CREATE IF NOT EXISTS.

```sql
CREATE TABLE IF NOT EXISTS `games_hubs_remote_access` (
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
        ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
```

## games_hubs_remote_master_presence

Définition embarquée à la ligne 476. Les anciennes tables existantes ne sont pas entièrement réalignées par CREATE IF NOT EXISTS.

```sql
CREATE TABLE IF NOT EXISTS `games_hubs_remote_master_presence` (
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
        ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
```

## games_hubs_remote_runtime_presence

Définition embarquée à la ligne 495. Les anciennes tables existantes ne sont pas entièrement réalignées par CREATE IF NOT EXISTS.

```sql
CREATE TABLE IF NOT EXISTS `games_hubs_remote_runtime_presence` (
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
        ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
```

## games_hubs_remote_commands

Définition embarquée à la ligne 514. Les anciennes tables existantes ne sont pas entièrement réalignées par CREATE IF NOT EXISTS.

```sql
CREATE TABLE IF NOT EXISTS `games_hubs_remote_commands` (
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
        ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
```

## Compléments manuels

Stats joueurs : games/web/includes/canvas/sql/2026-07-30_games_hubs_players_stats_projection.sql (10 colonnes stats_*).

QR : documentation/migrations/hub_player_qr_dev.sql (4 colonnes, script autorisé DEV uniquement, ne pas importer en PROD).

Les définitions ci-dessus sont des preuves, pas un script de migration à exécuter.
