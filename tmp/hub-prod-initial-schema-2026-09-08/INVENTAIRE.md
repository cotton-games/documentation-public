> Statut final : DDL PROD PRÊT À EXÉCUTER — 13 créations InnoDB, aucun ALTER legacy. Voir README et PROD-DECISIONS.md.

# Inventaire DB Hub — code local hub_soiree

Inventaire du périmètre Hub et des tables partagées consommées par ses parcours. PRECHECK PROD reçus : les 13 objets à créer sont absents ; les dépendances partagées existent sauf blindtest_session_teams, exclue (mode équipe désactivé et gardes d’absence). Aucun ALTER legacy autorisé par cet inventaire. Définitions exactes et index dans schema-contract.json ; occurrences SQL sourcées dans sql-evidence.json.

## Objets Hub et programmation

| Objet | Type | Consommateurs | Existe PROD | Action envisagée |
|---|---|---|---|---|
| `games_hubs` | Table | global, pro ; `app_games_hub_get_or_create_for_context` | Non (PRECHECK PROD) | Créer vide |
| `games_hubs_sessions` | Table | games, global, pro ; `app_games_hub_session_membership_ensure` | Non (PRECHECK PROD) | Créer vide |
| `games_hubs_players` | Table | games, global ; `app_games_hub_player_upsert` | Non (PRECHECK PROD) | Créer vide |
| `games_hubs_participations_probables` | Table | global ; `app_games_hub_probable_declare_ep` | Non (PRECHECK PROD) | Créer vide |
| `games_hubs_players_sessions` | Table | global ; `app_games_hub_session_mapping_upsert` | Non (PRECHECK PROD) | Créer vide |
| `games_hubs_publication` | Table | global ; `app_games_hub_publication_save` | Non (PRECHECK PROD) | Créer vide |
| `games_hubs_prizes` | Table | global ; `app_games_hub_prizes_bootstrap_from_sessions` | Non (PRECHECK PROD) | Créer vide |
| `games_hubs_remote_access` | Table | global ; `app_games_hub_remote_access_generate` | Non (PRECHECK PROD) | Créer vide |
| `games_hubs_remote_master_presence` | Table | global ; `app_games_hub_remote_master_presence_touch` | Non (PRECHECK PROD) | Créer vide |
| `games_hubs_remote_runtime_presence` | Table | global ; `app_games_hub_remote_runtime_presence_touch` | Non (PRECHECK PROD) | Créer vide |
| `games_hubs_remote_commands` | Table | global ; `app_games_hub_player_qr_after_launch` | Non (PRECHECK PROD) | Créer vide |
| `programming_quick_operations` | Table | global ; `app_programming_quick_idempotency_begin` | Non (PRECHECK PROD) | Créer vide, prérequis associé programmation |
| `programming_quick_series_operations` | Table | global ; `app_programming_quick_series_begin` | Non (PRECHECK PROD) | Créer vide, prérequis associé programmation |

Les colonnes routing/focus/présentation/exclusivité/suppression et QR sont dans games_hubs ; photos et agrégats dans games_hubs_players. Aucune table supplémentaire dédiée à ces catégories. Exécutions, démo et readiness : game_events et sessions legacy ; intent de routing : games_hubs ; commandes/idempotence Remote : games_hubs_remote_commands. Branding : general_branding type 5 (Hub), cascades événement/client/réseau et medias_images. Aucune FK, trigger, colonne générée ou CHECK Hub défini par les CREATE actuels ; aucun à inventer.

## Contrat détaillé : toutes colonnes et tous index

### games_hubs

Engine source MyISAM ; charset utf8 ; collation utf8_general_ci. Choix phase 1 : InnoDB.

| Colonne | Définition | Source définition | Lecteur/writer (fonction contenant SQL sur cette table) |
|---|---|---|---|
| `id` | `int(10) UNSIGNED NOT NULL AUTO_INCREMENT` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:185` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:45` → `app_games_hub_player_qr_row` |
| `id_securite` | `varchar(64) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:186` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:577` → `app_games_hub_token_exists` |
| `id_client` | `mediumint(9) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:187` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `hub_date` | `date NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:188` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `context_type` | `varchar(16) NOT NULL DEFAULT 'day'` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:189` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `id_operation_evenement` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:190` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `hub_label` | `varchar(255) DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:191` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `flag_active` | `tinyint(1) UNSIGNED NOT NULL DEFAULT 1` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:192` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `hub_status` | `varchar(32) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:193` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `active_session_id` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:194` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:233` → `app_games_hub_player_qr_set` |
| `active_session_activated_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:195` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `remote_routing_generation` | `bigint(20) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:196` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `remote_routing_intent_id` | `varchar(80) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:197` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `remote_transition_type` | `varchar(32) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:198` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:146` → `app_games_hub_player_qr_recover_launch` |
| `remote_transition_payload_json` | `text DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:199` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:146` → `app_games_hub_player_qr_recover_launch` |
| `remote_transition_started_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:200` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:146` → `app_games_hub_player_qr_recover_launch` |
| `presentation_session_id` | `int(10) UNSIGNED DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:201` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:233` → `app_games_hub_player_qr_set` |
| `presentation_mode` | `varchar(24) NOT NULL DEFAULT 'session'` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:202` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:233` → `app_games_hub_player_qr_set` |
| `presentation_updated_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:203` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `hub_master_instance_id` | `varchar(80) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:204` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:233` → `app_games_hub_player_qr_set` |
| `hub_master_instance_seen_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:205` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `hub_remote_instance_id` | `varchar(80) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:206` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `hub_remote_instance_seen_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:207` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `prizes_initialized_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:208` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `delete_operation_token` | `varchar(80) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:209` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3930` → `app_games_hub_delete_complete` |
| `delete_step` | `varchar(48) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:210` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3833` → `app_games_hub_delete_step_set` |
| `delete_started_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:211` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3930` → `app_games_hub_delete_complete` |
| `delete_error_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:212` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3833` → `app_games_hub_delete_step_set` |
| `date_ajout` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:213` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `date_maj` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:214` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:691` → `app_games_hub_remote_access_validate_token` |
| `player_qr_display_mode` | `varchar(8) NULL DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:10` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:10` → `app_games_hub_player_qr_schema_check` |
| `player_qr_display_revision` | `bigint(20) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:10` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:10` → `app_games_hub_player_qr_schema_check` |
| `player_qr_display_confirmation_json` | `text NULL DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:10` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:10` → `app_games_hub_player_qr_schema_check` |
| `player_qr_official_started_at` | `datetime NULL DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:10` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:10` → `app_games_hub_player_qr_schema_check` |

Index/contraintes attendus (ordre des colonnes significatif) :

- `PRIMARY KEY (`id`)`
- `UNIQUE KEY `uniq_games_hubs_token` (`id_securite`)`
- `UNIQUE KEY `uniq_games_hubs_context` (`id_client`,`hub_date`,`context_type`,`id_operation_evenement`)`
- `KEY `idx_games_hubs_client_date` (`id_client`,`hub_date`)`
- `KEY `idx_games_hubs_active_session` (`active_session_id`)`
- `KEY `idx_games_hubs_presentation_session` (`presentation_session_id`)`
- `KEY `idx_games_hubs_operation` (`id_operation_evenement`)`

### games_hubs_sessions

Engine source MyISAM ; charset utf8 ; collation utf8_general_ci. Choix phase 1 : InnoDB.

| Colonne | Définition | Source définition | Lecteur/writer (fonction contenant SQL sur cette table) |
|---|---|---|---|
| `id` | `int(10) UNSIGNED NOT NULL AUTO_INCREMENT` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:276` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `id_hub` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:277` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `id_session` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:278` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `membership_source` | `varchar(32) NOT NULL DEFAULT 'legacy_reconciled'` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:279` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `status` | `enum('active','inactive') NOT NULL DEFAULT 'active'` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:280` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `created_at` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:281` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `updated_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:282` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |

Index/contraintes attendus (ordre des colonnes significatif) :

- `PRIMARY KEY (`id`)`
- `UNIQUE KEY `uniq_games_hubs_sessions_hub_session` (`id_hub`,`id_session`)`
- `KEY `idx_games_hubs_sessions_hub_status` (`id_hub`,`status`)`
- `KEY `idx_games_hubs_sessions_session` (`id_session`)`

### games_hubs_players

Engine source MyISAM ; charset utf8 ; collation utf8_general_ci. Choix phase 1 : InnoDB.

| Colonne | Définition | Source définition | Lecteur/writer (fonction contenant SQL sur cette table) |
|---|---|---|---|
| `id` | `int(10) UNSIGNED NOT NULL AUTO_INCREMENT` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:293` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `id_hub` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:294` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `id_client` | `mediumint(9) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:295` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `id_operation_evenement` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:296` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `hub_token` | `varchar(64) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:297` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5462` → `app_games_hub_player_upsert` |
| `player_token` | `varchar(96) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:298` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5415` → `app_games_hub_player_get_current` |
| `auth_identity_key` | `varchar(128) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:299` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `id_ep_player` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:300` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `auth_type` | `enum('guest','ep') NOT NULL DEFAULT 'guest'` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:301` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `pseudo` | `varchar(80) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:302` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `pseudo_normalized` | `varchar(80) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:303` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5443` → `app_games_hub_player_find_active_pseudo_owner` |
| `status` | `enum('active','left') NOT NULL DEFAULT 'active'` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:304` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `return_token` | `varchar(64) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:305` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5415` → `app_games_hub_player_get_current` |
| `return_expires_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:306` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5415` → `app_games_hub_player_get_current` |
| `created_at` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:307` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `updated_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:308` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `last_seen_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:309` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `last_ip` | `varchar(45) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:310` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5462` → `app_games_hub_player_upsert` |
| `user_agent_hash` | `char(40) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:311` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5462` → `app_games_hub_player_upsert` |
| `hub_photo_media_id` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:312` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:7545` → `app_games_hub_players_stats_ranking_get` |
| `hub_photo_game_key` | `varchar(32) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:313` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:7545` → `app_games_hub_players_stats_ranking_get` |
| `hub_photo_source` | `varchar(32) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:314` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:7545` → `app_games_hub_players_stats_ranking_get` |
| `hub_photo_updated_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:315` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:7545` → `app_games_hub_players_stats_ranking_get` |
| `stats_aggregate_score` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `games/web/includes/canvas/sql/2026-07-30_games_hubs_players_stats_projection.sql:60` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:6769` → `app_games_hub_players_stats_rebuild` |
| `stats_wins_count` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `games/web/includes/canvas/sql/2026-07-30_games_hubs_players_stats_projection.sql:76` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:6769` → `app_games_hub_players_stats_rebuild` |
| `stats_second_places_count` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `games/web/includes/canvas/sql/2026-07-30_games_hubs_players_stats_projection.sql:92` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:6769` → `app_games_hub_players_stats_rebuild` |
| `stats_third_places_count` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `games/web/includes/canvas/sql/2026-07-30_games_hubs_players_stats_projection.sql:108` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:6769` → `app_games_hub_players_stats_rebuild` |
| `stats_parties_count` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `games/web/includes/canvas/sql/2026-07-30_games_hubs_players_stats_projection.sql:124` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:6769` → `app_games_hub_players_stats_rebuild` |
| `stats_last_result_at` | `datetime DEFAULT NULL` | `games/web/includes/canvas/sql/2026-07-30_games_hubs_players_stats_projection.sql:140` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:6769` → `app_games_hub_players_stats_rebuild` |
| `stats_source_revision` | `char(40) DEFAULT NULL` | `games/web/includes/canvas/sql/2026-07-30_games_hubs_players_stats_projection.sql:156` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:6769` → `app_games_hub_players_stats_rebuild` |
| `stats_computed_at` | `datetime DEFAULT NULL` | `games/web/includes/canvas/sql/2026-07-30_games_hubs_players_stats_projection.sql:172` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `stats_dirty_at` | `datetime DEFAULT NULL` | `games/web/includes/canvas/sql/2026-07-30_games_hubs_players_stats_projection.sql:188` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `stats_error` | `varchar(255) DEFAULT NULL` | `games/web/includes/canvas/sql/2026-07-30_games_hubs_players_stats_projection.sql:204` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:6769` → `app_games_hub_players_stats_rebuild` |

Index/contraintes attendus (ordre des colonnes significatif) :

- `PRIMARY KEY (`id`)`
- `UNIQUE KEY `uniq_games_hubs_players_identity` (`id_hub`,`auth_identity_key`)`
- `KEY `idx_games_hubs_players_hub_status` (`id_hub`,`status`)`
- `KEY `idx_games_hubs_players_pseudo` (`id_hub`,`pseudo_normalized`)`
- `KEY `idx_games_hubs_players_return` (`return_token`)`

### games_hubs_participations_probables

Engine source MyISAM ; charset utf8 ; collation utf8_general_ci. Choix phase 1 : InnoDB.

| Colonne | Définition | Source définition | Lecteur/writer (fonction contenant SQL sur cette table) |
|---|---|---|---|
| `id` | `int(10) UNSIGNED NOT NULL AUTO_INCREMENT` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:326` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5789` → `app_games_hub_probable_get_by_ep` |
| `id_hub` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:327` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5789` → `app_games_hub_probable_get_by_ep` |
| `id_client` | `mediumint(9) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:328` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5809` → `app_games_hub_probable_declare_ep` |
| `id_operation_evenement` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:329` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5809` → `app_games_hub_probable_declare_ep` |
| `hub_token` | `varchar(64) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:330` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5809` → `app_games_hub_probable_declare_ep` |
| `auth_identity_key` | `varchar(128) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:331` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5789` → `app_games_hub_probable_get_by_ep` |
| `id_ep_player` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:332` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5789` → `app_games_hub_probable_get_by_ep` |
| `source` | `varchar(32) NOT NULL DEFAULT 'hub_play'` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:333` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5809` → `app_games_hub_probable_declare_ep` |
| `status` | `enum('declared','cancelled','confirmed') NOT NULL DEFAULT 'declared'` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:334` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5809` → `app_games_hub_probable_declare_ep` |
| `date_ajout` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:335` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5809` → `app_games_hub_probable_declare_ep` |
| `date_maj` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:336` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5809` → `app_games_hub_probable_declare_ep` |
| `declared_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:337` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5809` → `app_games_hub_probable_declare_ep` |
| `cancelled_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:338` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5809` → `app_games_hub_probable_declare_ep` |
| `confirmed_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:339` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5884` → `app_games_hub_probable_confirm_ep` |
| `ip` | `varchar(45) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:340` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5809` → `app_games_hub_probable_declare_ep` |
| `id_user_ajout` | `mediumint(9) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:341` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5809` → `app_games_hub_probable_declare_ep` |
| `id_user_maj` | `mediumint(9) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:342` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5809` → `app_games_hub_probable_declare_ep` |

Index/contraintes attendus (ordre des colonnes significatif) :

- `PRIMARY KEY (`id`)`
- `UNIQUE KEY `uniq_games_hubs_probables_identity` (`id_hub`,`auth_identity_key`)`
- `KEY `idx_games_hubs_probables_hub_status` (`id_hub`,`status`)`
- `KEY `idx_games_hubs_probables_ep` (`id_ep_player`)`

### games_hubs_players_sessions

Engine source MyISAM ; charset utf8 ; collation utf8_general_ci. Choix phase 1 : InnoDB.

| Colonne | Définition | Source définition | Lecteur/writer (fonction contenant SQL sur cette table) |
|---|---|---|---|
| `id` | `int(10) UNSIGNED NOT NULL AUTO_INCREMENT` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:366` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `id_hub` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:367` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `id_hub_player` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:368` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `id_session` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:369` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `session_token` | `varchar(64) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:370` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:8391` → `app_games_hub_session_mapping_upsert` |
| `game_type` | `varchar(32) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:371` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `id_participation` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:372` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `participant_key` | `varchar(128) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:373` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `id_ep_player` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:374` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `status` | `enum('created','active','left','completed','failed') NOT NULL DEFAULT 'created'` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:375` | `global/web/app/modules/entites/clients/app_clients_functions.php:3875` → `app_client_joueurs_dashboard_context_compute` |
| `auto_joined_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:376` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:8391` → `app_games_hub_session_mapping_upsert` |
| `manual_joined_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:377` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:8391` → `app_games_hub_session_mapping_upsert` |
| `last_joined_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:378` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `left_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:379` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `completed_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:380` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `join_count` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:381` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:8370` → `app_games_hub_session_mapping_get` |
| `last_action` | `varchar(32) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:382` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:8391` → `app_games_hub_session_mapping_upsert` |
| `created_at` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:383` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `updated_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:384` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `last_error` | `varchar(255) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:385` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:8391` → `app_games_hub_session_mapping_upsert` |

Index/contraintes attendus (ordre des colonnes significatif) :

- `PRIMARY KEY (`id`)`
- `UNIQUE KEY `uniq_games_hubs_players_sessions_player_session` (`id_hub_player`,`id_session`)`
- `KEY `idx_games_hubs_players_sessions_hub_session` (`id_hub`,`id_session`)`
- `KEY `idx_games_hubs_players_sessions_session` (`id_session`)`
- `KEY `idx_games_hubs_players_sessions_participant` (`game_type`,`participant_key`)`

### games_hubs_publication

Engine source MyISAM ; charset utf8 ; collation utf8_general_ci. Choix phase 1 : InnoDB.

| Colonne | Définition | Source définition | Lecteur/writer (fonction contenant SQL sur cette table) |
|---|---|---|---|
| `id` | `int(10) UNSIGNED NOT NULL AUTO_INCREMENT` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:426` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:2385` → `app_games_hub_inactive_context_release_if_empty` |
| `id_hub` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:427` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:2385` → `app_games_hub_inactive_context_release_if_empty` |
| `title` | `varchar(150) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:428` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3160` → `app_games_hub_publication_save` |
| `tagline` | `varchar(255) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:429` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3160` → `app_games_hub_publication_save` |
| `description` | `text` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:430` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3160` → `app_games_hub_publication_save` |
| `location_name` | `varchar(150) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:431` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3160` → `app_games_hub_publication_save` |
| `address` | `varchar(180) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:432` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3160` → `app_games_hub_publication_save` |
| `postal_code` | `varchar(20) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:433` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3160` → `app_games_hub_publication_save` |
| `city` | `varchar(120) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:434` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3160` → `app_games_hub_publication_save` |
| `country` | `varchar(80) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:435` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3160` → `app_games_hub_publication_save` |
| `website_url` | `varchar(255) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:436` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3160` → `app_games_hub_publication_save` |
| `cta_label` | `varchar(150) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:437` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3160` → `app_games_hub_publication_save` |
| `publication_status` | `varchar(32) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:438` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3160` → `app_games_hub_publication_save` |
| `date_ajout` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:439` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3160` → `app_games_hub_publication_save` |
| `date_maj` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:440` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3160` → `app_games_hub_publication_save` |

Index/contraintes attendus (ordre des colonnes significatif) :

- `PRIMARY KEY (`id`)`
- `UNIQUE KEY `uniq_games_hubs_publication_hub` (`id_hub`)`

### games_hubs_prizes

Engine source MyISAM ; charset utf8 ; collation utf8_general_ci. Choix phase 1 : InnoDB.

| Colonne | Définition | Source définition | Lecteur/writer (fonction contenant SQL sur cette table) |
|---|---|---|---|
| `id` | `int(10) UNSIGNED NOT NULL AUTO_INCREMENT` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:449` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `id_hub` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:450` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `rank` | `tinyint(3) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:451` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3539` → `app_games_hub_prizes_rows_get` |
| `label` | `varchar(120) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:452` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3539` → `app_games_hub_prizes_rows_get` |
| `description` | `varchar(255) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:453` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3539` → `app_games_hub_prizes_rows_get` |
| `date_ajout` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:454` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |
| `date_maj` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:455` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:889` → `app_games_hub_remote_business_revisions_get` |

Index/contraintes attendus (ordre des colonnes significatif) :

- `PRIMARY KEY (`id`)`
- `UNIQUE KEY `uniq_games_hubs_prizes_hub_rank` (`id_hub`,`rank`)`
- `KEY `idx_games_hubs_prizes_hub` (`id_hub`)`

### games_hubs_remote_access

Engine source MyISAM ; charset utf8 ; collation utf8_general_ci. Choix phase 1 : InnoDB.

| Colonne | Définition | Source définition | Lecteur/writer (fonction contenant SQL sur cette table) |
|---|---|---|---|
| `id` | `int(10) UNSIGNED NOT NULL AUTO_INCREMENT` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:465` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:626` → `app_games_hub_remote_access_get_active` |
| `id_hub` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:466` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:626` → `app_games_hub_remote_access_get_active` |
| `id_client` | `mediumint(9) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:467` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:657` → `app_games_hub_remote_access_generate` |
| `remote_token` | `varchar(96) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:468` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:657` → `app_games_hub_remote_access_generate` |
| `remote_token_hash` | `char(64) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:469` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:657` → `app_games_hub_remote_access_generate` |
| `session_token_hash` | `char(64) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:470` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:741` → `app_games_hub_remote_access_validate_session` |
| `status` | `enum('active','revoked') NOT NULL DEFAULT 'active'` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:471` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:626` → `app_games_hub_remote_access_get_active` |
| `label` | `varchar(80) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:472` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:657` → `app_games_hub_remote_access_generate` |
| `created_at` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:473` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:657` → `app_games_hub_remote_access_generate` |
| `revoked_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:474` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:657` → `app_games_hub_remote_access_generate` |
| `last_seen_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:475` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:776` → `app_games_hub_remote_access_touch` |
| `last_ip` | `varchar(45) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:476` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:776` → `app_games_hub_remote_access_touch` |
| `user_agent_hash` | `char(40) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:477` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:776` → `app_games_hub_remote_access_touch` |

Index/contraintes attendus (ordre des colonnes significatif) :

- `PRIMARY KEY (`id`)`
- `UNIQUE KEY `uniq_games_hubs_remote_token_hash` (`remote_token_hash`)`
- `KEY `idx_games_hubs_remote_hub_status` (`id_hub`,`status`)`
- `KEY `idx_games_hubs_remote_session_hash` (`session_token_hash`)`

### games_hubs_remote_master_presence

Engine source MyISAM ; charset utf8 ; collation utf8_general_ci. Choix phase 1 : InnoDB.

| Colonne | Définition | Source définition | Lecteur/writer (fonction contenant SQL sur cette table) |
|---|---|---|---|
| `id` | `int(10) UNSIGNED NOT NULL AUTO_INCREMENT` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:488` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1370` → `app_games_hub_remote_master_presence_gate_get` |
| `id_hub` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:489` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1370` → `app_games_hub_remote_master_presence_gate_get` |
| `master_instance_id` | `varchar(80) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:490` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1370` → `app_games_hub_remote_master_presence_gate_get` |
| `last_seen_at` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:491` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1370` → `app_games_hub_remote_master_presence_gate_get` |
| `last_applied_preparation_revision` | `varchar(64) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:492` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1450` → `app_games_hub_remote_master_presence_touch` |
| `last_control_revision` | `varchar(64) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:493` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1450` → `app_games_hub_remote_master_presence_touch` |
| `visibility` | `varchar(16) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:494` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1370` → `app_games_hub_remote_master_presence_gate_get` |
| `user_agent_hash` | `char(40) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:495` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1450` → `app_games_hub_remote_master_presence_touch` |
| `created_at` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:496` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1450` → `app_games_hub_remote_master_presence_touch` |
| `updated_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:497` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1450` → `app_games_hub_remote_master_presence_touch` |

Index/contraintes attendus (ordre des colonnes significatif) :

- `PRIMARY KEY (`id`)`
- `UNIQUE KEY `uniq_games_hubs_remote_presence_master` (`id_hub`,`master_instance_id`)`
- `KEY `idx_games_hubs_remote_presence_seen` (`id_hub`,`last_seen_at`)`

### games_hubs_remote_runtime_presence

Engine source MyISAM ; charset utf8 ; collation utf8_general_ci. Choix phase 1 : InnoDB.

| Colonne | Définition | Source définition | Lecteur/writer (fonction contenant SQL sur cette table) |
|---|---|---|---|
| `id` | `int(10) UNSIGNED NOT NULL AUTO_INCREMENT` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:507` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1507` → `app_games_hub_remote_runtime_presence_touch` |
| `id_hub` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:508` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1507` → `app_games_hub_remote_runtime_presence_touch` |
| `id_session` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:509` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1507` → `app_games_hub_remote_runtime_presence_touch` |
| `execution_id` | `varchar(80) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:510` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1507` → `app_games_hub_remote_runtime_presence_touch` |
| `master_instance_id` | `varchar(80) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:511` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1507` → `app_games_hub_remote_runtime_presence_touch` |
| `last_seen_at` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:512` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1507` → `app_games_hub_remote_runtime_presence_touch` |
| `visibility` | `varchar(16) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:513` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1507` → `app_games_hub_remote_runtime_presence_touch` |
| `user_agent_hash` | `char(40) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:514` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1507` → `app_games_hub_remote_runtime_presence_touch` |
| `created_at` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:515` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1507` → `app_games_hub_remote_runtime_presence_touch` |
| `updated_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:516` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1507` → `app_games_hub_remote_runtime_presence_touch` |

Index/contraintes attendus (ordre des colonnes significatif) :

- `PRIMARY KEY (`id`)`
- `UNIQUE KEY `uniq_games_hubs_remote_runtime_master` (`id_hub`,`id_session`,`execution_id`,`master_instance_id`)`
- `KEY `idx_games_hubs_remote_runtime_seen` (`id_hub`,`id_session`,`execution_id`,`last_seen_at`)`

### games_hubs_remote_commands

Engine source MyISAM ; charset utf8 ; collation utf8_general_ci. Choix phase 1 : InnoDB.

| Colonne | Définition | Source définition | Lecteur/writer (fonction contenant SQL sur cette table) |
|---|---|---|---|
| `id` | `int(10) UNSIGNED NOT NULL AUTO_INCREMENT` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:526` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:130` → `app_games_hub_player_qr_display_mode` |
| `id_hub` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:527` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:130` → `app_games_hub_player_qr_display_mode` |
| `id_remote_access` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:528` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:250` → `app_games_hub_player_qr_after_launch` |
| `command_type` | `varchar(32) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:529` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:130` → `app_games_hub_player_qr_display_mode` |
| `payload_json` | `text` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:530` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:130` → `app_games_hub_player_qr_display_mode` |
| `status` | `enum('pending','claimed','processing','completed','failed','expired','cancelled') NOT NULL DEFAULT 'pending'` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:531` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:130` → `app_games_hub_player_qr_display_mode` |
| `remote_command_key` | `varchar(96) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:532` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:146` → `app_games_hub_player_qr_recover_launch` |
| `created_at` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:533` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:250` → `app_games_hub_player_qr_after_launch` |
| `expires_at` | `datetime NOT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:534` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:250` → `app_games_hub_player_qr_after_launch` |
| `claimed_by` | `varchar(80) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:535` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1848` → `app_games_hub_remote_command_mark_processing` |
| `claimed_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:536` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:1864` → `app_games_hub_remote_command_claim_next` |
| `completed_at` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:537` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:146` → `app_games_hub_player_qr_recover_launch` |
| `result_json` | `text` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:538` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:130` → `app_games_hub_player_qr_display_mode` |
| `error_code` | `varchar(64) NOT NULL DEFAULT ''` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:539` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:304` → `app_games_hub_player_qr_command` |
| `date_maj` | `datetime DEFAULT NULL` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:540` | `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php:250` → `app_games_hub_player_qr_after_launch` |

Index/contraintes attendus (ordre des colonnes significatif) :

- `PRIMARY KEY (`id`)`
- `UNIQUE KEY `uniq_games_hubs_remote_command_key` (`id_hub`,`remote_command_key`)`
- `KEY `idx_games_hubs_remote_commands_pending` (`id_hub`,`status`,`expires_at`,`id`)`
- `KEY `idx_games_hubs_remote_commands_access` (`id_remote_access`,`created_at`)`

### programming_quick_operations

Engine source MyISAM ; charset utf8 ; collation utf8_general_ci. Choix phase 1 : InnoDB.

| Colonne | Définition | Source définition | Lecteur/writer (fonction contenant SQL sur cette table) |
|---|---|---|---|
| `id` | `int(10) UNSIGNED NOT NULL AUTO_INCREMENT` | `documentation/programming_quick_operations_phpmyadmin.sql:6` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `id_client` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `documentation/programming_quick_operations_phpmyadmin.sql:7` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `idempotency_key` | `varchar(80) NOT NULL DEFAULT ''` | `documentation/programming_quick_operations_phpmyadmin.sql:8` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `command_hash` | `char(64) NOT NULL DEFAULT ''` | `documentation/programming_quick_operations_phpmyadmin.sql:9` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `status` | `varchar(24) NOT NULL DEFAULT 'pending'` | `documentation/programming_quick_operations_phpmyadmin.sql:10` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `operation_step` | `varchar(32) NOT NULL DEFAULT 'pending'` | `documentation/programming_quick_operations_phpmyadmin.sql:11` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `session_ids_json` | `text` | `documentation/programming_quick_operations_phpmyadmin.sql:12` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `session_security_ids_json` | `text` | `documentation/programming_quick_operations_phpmyadmin.sql:13` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `hub_id` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `documentation/programming_quick_operations_phpmyadmin.sql:14` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `dashboard_url` | `varchar(255) NOT NULL DEFAULT ''` | `documentation/programming_quick_operations_phpmyadmin.sql:15` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `result_json` | `text` | `documentation/programming_quick_operations_phpmyadmin.sql:16` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `error_code` | `varchar(80) NOT NULL DEFAULT ''` | `documentation/programming_quick_operations_phpmyadmin.sql:17` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `created_at` | `datetime NOT NULL` | `documentation/programming_quick_operations_phpmyadmin.sql:18` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `updated_at` | `datetime NOT NULL` | `documentation/programming_quick_operations_phpmyadmin.sql:19` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |
| `expires_at` | `datetime NOT NULL` | `documentation/programming_quick_operations_phpmyadmin.sql:20` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:864` → `app_programming_quick_idempotency_schema_ensure` |

Index/contraintes attendus (ordre des colonnes significatif) :

- `PRIMARY KEY (`id`)`
- `UNIQUE KEY `uniq_programming_quick_client_key` (`id_client`,`idempotency_key`)`
- `KEY `idx_programming_quick_expires_at` (`expires_at`)`
- `KEY `idx_programming_quick_client_status` (`id_client`,`status`)`

### programming_quick_series_operations

Engine source MyISAM ; charset utf8 ; collation utf8_general_ci. Choix phase 1 : InnoDB.

| Colonne | Définition | Source définition | Lecteur/writer (fonction contenant SQL sur cette table) |
|---|---|---|---|
| `id` | `int(10) UNSIGNED NOT NULL AUTO_INCREMENT` | `documentation/programming_quick_series_operations_phpmyadmin.sql:6` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |
| `id_client` | `int(10) UNSIGNED NOT NULL DEFAULT 0` | `documentation/programming_quick_series_operations_phpmyadmin.sql:7` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |
| `idempotency_key` | `varchar(80) NOT NULL DEFAULT ''` | `documentation/programming_quick_series_operations_phpmyadmin.sql:8` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |
| `command_hash` | `char(64) NOT NULL DEFAULT ''` | `documentation/programming_quick_series_operations_phpmyadmin.sql:9` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |
| `status` | `varchar(24) NOT NULL DEFAULT 'pending'` | `documentation/programming_quick_series_operations_phpmyadmin.sql:10` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |
| `operation_step` | `varchar(32) NOT NULL DEFAULT 'pending'` | `documentation/programming_quick_series_operations_phpmyadmin.sql:11` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |
| `template_json` | `mediumtext` | `documentation/programming_quick_series_operations_phpmyadmin.sql:12` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |
| `recurrence_json` | `mediumtext` | `documentation/programming_quick_series_operations_phpmyadmin.sql:13` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |
| `occurrences_json` | `mediumtext` | `documentation/programming_quick_series_operations_phpmyadmin.sql:14` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |
| `themes_json` | `mediumtext` | `documentation/programming_quick_series_operations_phpmyadmin.sql:15` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |
| `result_json` | `mediumtext` | `documentation/programming_quick_series_operations_phpmyadmin.sql:16` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |
| `created_at` | `datetime NOT NULL` | `documentation/programming_quick_series_operations_phpmyadmin.sql:17` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |
| `updated_at` | `datetime NOT NULL` | `documentation/programming_quick_series_operations_phpmyadmin.sql:18` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |
| `expires_at` | `datetime NOT NULL` | `documentation/programming_quick_series_operations_phpmyadmin.sql:19` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:747` → `app_programming_quick_series_schema_ensure` |

Index/contraintes attendus (ordre des colonnes significatif) :

- `PRIMARY KEY (`id`)`
- `UNIQUE KEY `uniq_programming_quick_series_client_key` (`id_client`,`idempotency_key`)`
- `KEY `idx_programming_quick_series_expires_at` (`expires_at`)`
- `KEY `idx_programming_quick_series_client_status` (`id_client`,`status`)`

## Tables partagées : inventaire des dépendances SQL

Tables partagées identifiées : existence confirmée par PRECHECK sauf blindtest_session_teams (option désactivée, exclue du paquet). Ce tableau n’est pas une liste de créations ; aucune modification legacy retenue. Le second export ne contient pas le jeu COLUMNS complet : ne pas assimiler existence à certification de toutes les définitions legacy. Les usages conditionnels/fallbacks sont détaillés dans les fonctions citées ; les contenus historiques ne sont jamais importés dans cette phase. Un objet absent ou incompatible déclenche une analyse avant tout ALTER.

| Table | Preuve fichier → fonction → SQL | Action phase 1 |
|---|---|---|
| `bingo_phase_winners` | `games/web/includes/canvas/php/bingo_adapter_glue.php:211` → `_bingo_fetch_phase_winners` → `FROM bingo_phase_winners` | Réutilisée ; aucun DDL legacy |
| `bingo_players` | `games/web/includes/canvas/php/bingo_adapter_glue.php:212` → `_bingo_fetch_phase_winners` → `JOIN bingo_players` | Réutilisée ; aucun DDL legacy |
| `blindtest_players` | `games/web/includes/canvas/php/blindtest_adapter_glue.php:374` → `_bt_fetch_players` → `FROM blindtest_players` | Réutilisée ; aucun DDL legacy |
| `blindtest_session_teams` | `games/web/includes/canvas/php/blindtest_adapter_glue.php:286` → `_bt_persist_session_teams` → `FROM blindtest_session_teams` | Absence acceptable ; exclue, gardes et mode équipe OFF |
| `blindtest_sessions` | `games/web/includes/canvas/php/blindtest_adapter_glue.php:90` → `_bt_ensure_session_exists` → `FROM blindtest_sessions` | Réutilisée ; aucun DDL legacy |
| `championnats_resultats` | `global/web/app/modules/entites/clients/app_clients_functions.php:5419` → `app_client_joueurs_dashboard_context_compute` → `JOIN championnats_resultats` | Réutilisée ; aucun DDL legacy |
| `championnats_saisons` | `global/web/app/modules/jeux/sessions/app_sessions_functions.php:9` → `app_saison_get_id` → `FROM championnats_saisons` | Réutilisée ; aucun DDL legacy |
| `championnats_sessions` | `games/web/includes/canvas/php/bingo_adapter_glue.php:68` → `_bingo_get_session_meta_by_token` → `FROM championnats_sessions` | Réutilisée ; aucun DDL legacy |
| `championnats_sessions_lots` | `games/web/includes/canvas/php/bingo_adapter_glue.php:837` → `_bingo_reset_demo_state` → `JOIN championnats_sessions_lots` | Réutilisée ; aucun DDL legacy |
| `championnats_sessions_lots_to_entites_joueurs` | `games/web/includes/canvas/php/bingo_adapter_glue.php:836` → `_bingo_reset_demo_state` → `FROM championnats_sessions_lots_to_entites_joueurs` | Réutilisée ; aucun DDL legacy |
| `championnats_sessions_participations_games_connectees` | `global/web/app/modules/entites/clients/app_clients_functions.php:4641` → `app_client_joueurs_dashboard_context_compute` → `FROM championnats_sessions_participations_games_connectees` | Réutilisée ; aucun DDL legacy |
| `championnats_sessions_participations_probables` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:5956` → `app_games_hub_probable_list` → `FROM championnats_sessions_participations_probables` | Réutilisée ; aucun DDL legacy |
| `championnats_sessions_podium_photos_consents` | `global/web/app/modules/jeux/sessions/app_sessions_functions.php:1944` → `app_session_results_podium_photo_consent_save` → `INTO (nom résolu) championnats_sessions_podium_photos_consents` | Réutilisée ; aucun DDL legacy |
| `clients` | `games/web/includes/canvas/php/bingo_adapter_glue.php:69` → `_bingo_get_session_meta_by_token` → `JOIN clients` | Réutilisée ; aucun DDL legacy |
| `clients_contacts_to_clients` | `global/web/app/modules/entites/clients/app_clients_functions.php:1545` → `app_client_pipeline_etat_modifier` → `FROM clients_contacts_to_clients` | Réutilisée ; aucun DDL legacy |
| `community_items` | `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:2255` → `app_programming_theme_renewal_catalog_candidates_get` → `JOIN community_items` | Réutilisée ; aucun DDL legacy |
| `content_links_check_results` | `games/web/includes/canvas/php/boot_lib.php:860` → `canvas_api_youtube_catalog_diagnostics_get` → `FROM content_links_check_results` | Réutilisée ; aucun DDL legacy |
| `cotton_quiz_players` | `games/web/includes/canvas/php/quiz_adapter_glue.php:213` → `_qz_fetch_players` → `FROM cotton_quiz_players` | Réutilisée ; aucun DDL legacy |
| `cotton_quiz_sessions` | `games/web/includes/canvas/php/quiz_adapter_glue.php:93` → `_qz_ensure_session_exists` → `FROM cotton_quiz_sessions` | Réutilisée ; aucun DDL legacy |
| `ecommerce_offres` | `global/web/app/modules/ecommerce/app_ecommerce_functions.php:343` → `app_ecommerce_offre_get_detail` → `FROM ecommerce_offres` | Réutilisée ; aucun DDL legacy |
| `ecommerce_offres_to_clients` | `global/web/app/modules/entites/clients/app_clients_functions.php:2353` → `app_client_joueurs_dashboard_member_since_get` → `FROM ecommerce_offres_to_clients` | Réutilisée ; aucun DDL legacy |
| `ecommerce_reseau_content_shares` | `global/web/app/modules/ecommerce/app_ecommerce_functions.php:3265` → `app_ecommerce_reseau_content_share_ids_get` → `FROM ecommerce_reseau_content_shares` | Réutilisée ; aucun DDL legacy |
| `ecommerce_reseau_contrats` | `global/web/app/modules/ecommerce/app_ecommerce_functions.php:2766` → `app_ecommerce_reseau_billing_columns_available` → `FROM ecommerce_reseau_contrats` | Réutilisée ; aucun DDL legacy |
| `ecommerce_reseau_contrats_affilies` | `global/web/app/modules/ecommerce/app_ecommerce_functions.php:2790` → `app_ecommerce_reseau_activation_billing_mode_available` → `FROM ecommerce_reseau_contrats_affilies` | Réutilisée ; aucun DDL legacy |
| `equipes` | `global/web/app/modules/entites/clients/app_clients_functions.php:4643` → `app_client_joueurs_dashboard_context_compute` → `JOIN equipes` | Réutilisée ; aucun DDL legacy |
| `equipes_championnats_sessions_reponses` | `global/web/app/modules/jeux/sessions/app_sessions_functions.php:5650` → `app_equipes_session_supprimer` → `FROM equipes_championnats_sessions_reponses` | Réutilisée ; aucun DDL legacy |
| `equipes_joueurs` | `global/web/app/modules/entites/clients/app_clients_functions.php:4642` → `app_client_joueurs_dashboard_context_compute` → `JOIN equipes_joueurs` | Réutilisée ; aucun DDL legacy |
| `equipes_joueurs_to_equipes` | `games/web/includes/canvas/php/boot_lib.php:1193` → `canvas_api_participant_lookup` → `FROM equipes_joueurs_to_equipes` | Réutilisée ; aucun DDL legacy |
| `equipes_to_championnats_sessions` | `global/web/app/modules/entites/clients/app_clients_functions.php:4755` → `app_client_joueurs_dashboard_context_compute` → `JOIN equipes_to_championnats_sessions` | Réutilisée ; aucun DDL legacy |
| `game_events` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:4531` → `app_games_hub_execution_context_complete` → `INTO game_events` | Réutilisée ; aucun DDL legacy |
| `general_branding` | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:3914` → `app_games_hub_delete_branding_ids_get` → `FROM general_branding` | Réutilisée ; aucun DDL legacy |
| `jeux_bingo_musical_artistes` | `games/web/includes/canvas/php/bingo_adapter_glue.php:144` → `svc_fetch_playlist_bingo` → `JOIN jeux_bingo_musical_artistes` | Réutilisée ; aucun DDL legacy |
| `jeux_bingo_musical_grids` | `global/web/app/modules/jeux/bingo_musical/app_bingo_musical_functions.php:1158` → `app_bingo_musical_playlist_client_grilles_ajouter` → `FROM jeux_bingo_musical_grids` | Réutilisée ; aucun DDL legacy |
| `jeux_bingo_musical_grids_clients` | `games/web/includes/canvas/php/bingo_adapter_glue.php:2136` → `_bingo_fetch_numbers_and_cells` → `FROM jeux_bingo_musical_grids_clients` | Réutilisée ; aucun DDL legacy |
| `jeux_bingo_musical_morceaux` | `games/web/includes/canvas/php/bingo_adapter_glue.php:143` → `svc_fetch_playlist_bingo` → `JOIN jeux_bingo_musical_morceaux` | Réutilisée ; aucun DDL legacy |
| `jeux_bingo_musical_morceaux_to_playlists` | `global/web/app/modules/jeux/bingo_musical/app_bingo_musical_functions.php:397` → `app_bingo_musical_playlist_client_ajouter` → `FROM jeux_bingo_musical_morceaux_to_playlists` | Réutilisée ; aucun DDL legacy |
| `jeux_bingo_musical_morceaux_to_playlists_clients` | `games/web/includes/canvas/php/bingo_adapter_glue.php:818` → `_bingo_reset_demo_state` → `UPDATE jeux_bingo_musical_morceaux_to_playlists_clients` | Réutilisée ; aucun DDL legacy |
| `jeux_bingo_musical_playlists` | `games/web/includes/canvas/php/blindtest_adapter_glue.php:53` → `_bt_get_session_meta_by_token` → `JOIN jeux_bingo_musical_playlists` | Réutilisée ; aucun DDL legacy |
| `jeux_bingo_musical_playlists_clients` | `games/web/includes/canvas/php/bingo_adapter_glue.php:70` → `_bingo_get_session_meta_by_token` → `JOIN jeux_bingo_musical_playlists_clients` | Réutilisée ; aucun DDL legacy |
| `jeux_bingo_musical_playlists_clients_logs` | `games/web/includes/canvas/php/bingo_adapter_glue.php:828` → `_bingo_reset_demo_state` → `FROM jeux_bingo_musical_playlists_clients_logs` | Réutilisée ; aucun DDL legacy |
| `medias_images` | `global/web/app/modules/entites/clients/app_clients_functions.php:162` → `app_client_get_photo_src` → `FROM medias_images` | Réutilisée ; aucun DDL legacy |
| `operations_evenements` | `global/web/app/modules/operations/evenements/app_evenements_functions.php:717` → `app_evenement_ajouter` → `FROM operations_evenements` | Réutilisée ; aucun DDL legacy |
| `questions` | `games/web/includes/canvas/php/quiz_adapter_glue.php:268` → `_qz_fetch_questions` → `FROM questions` | Réutilisée ; aucun DDL legacy |
| `questions_bonus` | `global/web/lib/gq/global/classes/modules/quizs/Quiz.php:520` → `genereQuestionBonus` → `FROM questions_bonus` | Réutilisée ; aucun DDL legacy |
| `questions_bonus_to_tags` | `global/web/lib/gq/global/classes/modules/questions/Questions.php:352` → `getNbBonusTag` → `FROM questions_bonus_to_tags` | Réutilisée ; aucun DDL legacy |
| `questions_lots` | `games/web/includes/canvas/php/quiz_adapter_glue.php:269` → `_qz_fetch_questions` → `JOIN questions_lots` | Réutilisée ; aucun DDL legacy |
| `questions_lots_num_temp` | `games/web/includes/canvas/php/quiz_adapter_glue.php:341` → `_qz_fetch_questions` → `FROM questions_lots_num_temp` | Réutilisée ; aucun DDL legacy |
| `questions_lots_rubriques` | `global/web/lib/gq/global/classes/modules/questions/Lots.php:71` → `getRubriques` → `FROM questions_lots_rubriques` | Réutilisée ; aucun DDL legacy |
| `questions_lots_temp` | `games/web/includes/canvas/php/quiz_adapter_glue.php:301` → `_qz_fetch_questions` → `FROM questions_lots_temp` | Réutilisée ; aucun DDL legacy |
| `questions_lots_univers` | `global/web/lib/gq/global/classes/modules/questions/Lots.php:40` → `setUnivers` → `FROM questions_lots_univers` | Réutilisée ; aucun DDL legacy |
| `questions_propositions` | `games/web/includes/canvas/php/quiz_adapter_glue.php:408` → `_qz_fetch_questions` → `FROM questions_propositions` | Réutilisée ; aucun DDL legacy |
| `questions_rubriques` | `global/web/lib/gq/global/classes/modules/questions/Questions.php:99` → `getRubriques` → `FROM questions_rubriques` | Réutilisée ; aucun DDL legacy |
| `questions_tags` | `global/web/lib/gq/global/classes/modules/questions/Question.php:51` → `setTags` → `FROM questions_tags` | Réutilisée ; aucun DDL legacy |
| `questions_to_tags` | `global/web/lib/gq/global/classes/modules/questions/Question.php:106` → `addTag` → `INTO questions_to_tags` | Réutilisée ; aucun DDL legacy |
| `questions_univers` | `global/web/lib/gq/global/classes/modules/questions/Lot.php:226` → `setClassification` → `FROM questions_univers` | Réutilisée ; aucun DDL legacy |
| `quizs` | `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php:3336` → `app_cotton_quiz_supprimer` → `FROM quizs` | Réutilisée ; aucun DDL legacy |
| `quizs_series` | `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php:2838` → `app_cotton_quiz_get_series_meta` → `FROM quizs_series` | Réutilisée ; aucun DDL legacy |
| `quizs_series_to_questions` | `global/web/lib/gq/global/classes/modules/quizs/Serie.php:115` → `addQuestion` → `INTO quizs_series_to_questions` | Réutilisée ; aucun DDL legacy |
| `referentiels_clients_erp_jauges` | `global/web/app/modules/ecommerce/app_ecommerce_functions.php:10096` → `app_ecommerce_reseau_contrat_resolve_target_erp_jauge` → `FROM referentiels_clients_erp_jauges` | Réutilisée ; aucun DDL legacy |
| `referentiels_clients_pipeline_etats` | `global/web/app/modules/entites/clients/app_clients_functions.php:1412` → `app_client_pipeline_etat_get_id` → `FROM referentiels_clients_pipeline_etats` | Réutilisée ; aucun DDL legacy |

## Couverture et limites probatoires

Recherche sur les huit dépôts, fichiers PHP/SQL/JS et WS/server, exclusion des dépendances vendor/node_modules et tests. Analyse lexicale PHP de 919 fonctions racines (Hub, Pro journée, programmation, Play Hub, adaptateurs Canvas pour dispatch dynamique), puis appels nommés vers 1971 fonctions ; 73 noms de tables SQL retenus après filtrage des mots SQL/colonnes. Les fonctions partagées peuvent couvrir des branches commerciales ou éditoriales non systématiques : leur présence ne justifie pas un CREATE.

Résolution manuelle ajoutée pour la table de consentement construite par helper. La recherche statique n’est pas une exécution de tous les flux ni une certification du serveur ; dépendances réseau/API ne sont pas transformées en tables fictives. Quiz/Blind Test/Bingo WS relaient les actions Hub via Canvas, leurs sessions/scores restent dans les tables runtime existantes. Play appelle Global et ne crée pas de stockage Hub supplémentaire.

## Comparaison des CREATE historiques et des ajouts ultérieurs

| Source | Table | Colonnes du contrat actuel absentes de ce CREATE |
|---|---|---|
| `games_hubs_phpmyadmin.sql` | `games_hubs` | `remote_routing_generation`, `remote_routing_intent_id`, `remote_transition_type`, `remote_transition_payload_json`, `remote_transition_started_at`, `presentation_session_id`, `presentation_mode`, `presentation_updated_at`, `hub_master_instance_id`, `hub_master_instance_seen_at`, `hub_remote_instance_id`, `hub_remote_instance_seen_at`, `delete_operation_token`, `delete_step`, `delete_started_at`, `delete_error_at`, `player_qr_display_mode`, `player_qr_display_revision`, `player_qr_display_confirmation_json`, `player_qr_official_started_at` |
| `games_hubs_phpmyadmin.sql` | `games_hubs_sessions` | Aucune |
| `games_hubs_sessions_phpmyadmin.sql` | `games_hubs_sessions` | Aucune |
| `canon/data/schema/DDL.sql` | `games_hubs` | `remote_routing_generation`, `remote_routing_intent_id`, `remote_transition_type`, `remote_transition_payload_json`, `remote_transition_started_at`, `presentation_mode`, `presentation_updated_at`, `hub_master_instance_id`, `hub_master_instance_seen_at`, `hub_remote_instance_id`, `hub_remote_instance_seen_at`, `player_qr_display_mode`, `player_qr_display_revision`, `player_qr_display_confirmation_json`, `player_qr_official_started_at` |
| `canon/data/schema/DDL.sql` | `games_hubs_publication` | Aucune |
| `canon/data/schema/DDL.sql` | `games_hubs_prizes` | Aucune |
| `canon/data/schema/DDL.sql` | `games_hubs_sessions` | Aucune |
| `canon/data/schema/DDL.sql` | `games_hubs_participations_probables` | Aucune |
| `../games/web/includes/canvas/sql/2026-07-08_games_hubs_players.sql` | `games_hubs_players` | `hub_photo_media_id`, `hub_photo_game_key`, `hub_photo_source`, `hub_photo_updated_at`, `stats_aggregate_score`, `stats_wins_count`, `stats_second_places_count`, `stats_third_places_count`, `stats_parties_count`, `stats_last_result_at`, `stats_source_revision`, `stats_computed_at`, `stats_dirty_at`, `stats_error` |
| `../games/web/includes/canvas/sql/2026-07-08_games_hubs_players_sessions.sql` | `games_hubs_players_sessions` | `auto_joined_at`, `manual_joined_at`, `last_joined_at`, `left_at`, `completed_at`, `join_count`, `last_action` |
| `../games/web/includes/canvas/sql/2026-07-17_games_hubs_publication_prizes.sql` | `games_hubs_publication` | Aucune |
| `../games/web/includes/canvas/sql/2026-07-17_games_hubs_publication_prizes.sql` | `games_hubs_prizes` | Aucune |
| `../games/web/includes/canvas/sql/2026-07-31_games_hubs_participations_probables.sql` | `games_hubs_participations_probables` | Aucune |

Les migrations 2026-07-09 (focus/access_state), 2026-07-17 (publication/prizes/initialisation), 2026-07-30 (stats), 2026-07-31 (probables/photo) et 2026-08-25 (presentation_session) ont été croisées avec le helper actuel. Elles ne sont pas à rejouer séparément après un CREATE complet. Les quatre champs QR proviennent du contrat dédié récent. Les dix champs stats ne sont ni créés ni ajoutés par l’ensure : leur garde ne fait que lire le schéma.
