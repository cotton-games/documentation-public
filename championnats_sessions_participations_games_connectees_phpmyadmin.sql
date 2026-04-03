-- phpMyAdmin import
-- Table de liaison EP -> games pour les inscriptions joueur connectées

CREATE TABLE IF NOT EXISTS `championnats_sessions_participations_games_connectees` (
  `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_championnat_session` mediumint(9) NOT NULL DEFAULT 0,
  `id_type_produit` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `game_slug` varchar(16) NOT NULL DEFAULT '',
  `return_token` varchar(64) NOT NULL DEFAULT '',
  `return_expires_at` datetime DEFAULT NULL,
  `game_player_id` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `game_player_key` varchar(64) NOT NULL DEFAULT '',
  `id_joueur` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `id_equipe` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `source` varchar(32) NOT NULL DEFAULT 'play_ep_account',
  `date_consumed` datetime DEFAULT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `id_user_ajout` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `id_user_maj` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_return_token` (`return_token`),
  KEY `idx_session_joueur_equipe` (`id_championnat_session`,`id_joueur`,`id_equipe`),
  KEY `idx_game_player` (`game_slug`,`game_player_id`),
  KEY `idx_game_player_key` (`game_slug`,`game_player_key`),
  KEY `idx_id_joueur` (`id_joueur`),
  KEY `idx_id_equipe` (`id_equipe`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
