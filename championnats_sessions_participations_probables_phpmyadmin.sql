CREATE TABLE IF NOT EXISTS `championnats_sessions_participations_probables` (
  `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_championnat_session` mediumint(9) NOT NULL DEFAULT 0,
  `id_joueur` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `id_equipe` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `source` varchar(32) NOT NULL DEFAULT 'play',
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `id_user_ajout` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `id_user_maj` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_session_joueur_equipe` (`id_championnat_session`,`id_joueur`,`id_equipe`),
  KEY `idx_cssp_session` (`id_championnat_session`),
  KEY `idx_cssp_joueur` (`id_joueur`),
  KEY `idx_cssp_equipe` (`id_equipe`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
