-- phpMyAdmin SQL Dump
-- version 5.2.1-1.el8.remi
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost
-- Généré le : jeu. 05 fév. 2026 à 15:57
-- Version du serveur : 10.3.39-MariaDB-log
-- Version de PHP : 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `dev_cotton_global_0`
--

-- --------------------------------------------------------

--
-- Structure de la table `ai_pilot_agents`
--

CREATE TABLE `ai_pilot_agents` (
  `id` int(10) UNSIGNED NOT NULL,
  `tenant_id` int(10) UNSIGNED NOT NULL COMMENT 'ID du tenant',
  `name` varchar(50) NOT NULL COMMENT 'Nom de l''agent (ex: writing, prospecting)',
  `description` text DEFAULT NULL COMMENT 'Description de l''agent',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ai_pilot_api_usage`
--

CREATE TABLE `ai_pilot_api_usage` (
  `id` int(10) UNSIGNED NOT NULL,
  `tenant_id` int(10) UNSIGNED NOT NULL COMMENT 'ID du tenant',
  `service_id` int(10) UNSIGNED NOT NULL COMMENT 'ID du service IA',
  `content_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'ID du contenu généré (NULL si autre usage)',
  `request_count` int(10) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Nombre de tokens ou requêtes',
  `cost` decimal(10,4) DEFAULT NULL COMMENT 'Coût estimé',
  `api_request_id` varchar(100) DEFAULT NULL COMMENT 'ID de la requête API (pour traçabilité)',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ai_pilot_client_preferences`
--

CREATE TABLE `ai_pilot_client_preferences` (
  `id` int(10) UNSIGNED NOT NULL,
  `tenant_id` int(10) UNSIGNED NOT NULL COMMENT 'ID du tenant',
  `client_id` varchar(50) NOT NULL COMMENT 'ID du client (ex: email, ID externe)',
  `preferred_tone` enum('décontracté','professionnel','enthousiaste','humoristique') DEFAULT NULL COMMENT 'Ton préféré',
  `preferred_emojis` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Emojis préférés',
  `preferred_platforms` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Plateformes préférées',
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ai_pilot_generated_contents`
--

CREATE TABLE `ai_pilot_generated_contents` (
  `id` int(10) UNSIGNED NOT NULL,
  `tenant_agent_id` int(10) UNSIGNED NOT NULL COMMENT 'ID de la liaison tenant/agent',
  `platform_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'ID de la plateforme (NULL si générique)',
  `content_type` enum('post','article','email','other') NOT NULL COMMENT 'Type de contenu',
  `content` text NOT NULL COMMENT 'Contenu généré',
  `status` enum('draft','approved','rejected','published') NOT NULL DEFAULT 'draft',
  `scheduled_at` datetime DEFAULT NULL COMMENT 'Date de publication planifiée',
  `published_at` datetime DEFAULT NULL COMMENT 'Date de publication réelle',
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Métadonnées (ex: emojis, images, etc.)',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ai_pilot_ia_services`
--

CREATE TABLE `ai_pilot_ia_services` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(50) NOT NULL COMMENT 'Nom du service (ex: mistral, openai)',
  `description` text DEFAULT NULL COMMENT 'Description du service',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ai_pilot_media_assets`
--

CREATE TABLE `ai_pilot_media_assets` (
  `id` int(10) UNSIGNED NOT NULL,
  `content_id` int(10) UNSIGNED NOT NULL COMMENT 'ID du contenu généré',
  `type` enum('image','overlay','video','audio') NOT NULL COMMENT 'Type de média',
  `url` varchar(255) NOT NULL COMMENT 'URL du média',
  `path` varchar(255) DEFAULT NULL COMMENT 'Chemin local si stocké sur le serveur',
  `alt_text` varchar(255) DEFAULT NULL COMMENT 'Texte alternatif',
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Métadonnées (ex: dimensions, format)',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ai_pilot_platforms`
--

CREATE TABLE `ai_pilot_platforms` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(50) NOT NULL COMMENT 'Nom de la plateforme (ex: facebook, instagram)',
  `description` text DEFAULT NULL COMMENT 'Description de la plateforme',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ai_pilot_scheduled_tasks`
--

CREATE TABLE `ai_pilot_scheduled_tasks` (
  `id` int(10) UNSIGNED NOT NULL,
  `tenant_agent_id` int(10) UNSIGNED NOT NULL COMMENT 'ID de la liaison tenant/agent',
  `platform_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'ID de la plateforme (NULL si générique)',
  `action_type` varchar(50) NOT NULL COMMENT 'Type d''action (ex: new_member, agenda_week)',
  `day_of_week` tinyint(4) DEFAULT NULL COMMENT '1 (lundi) à 7 (dimanche), NULL si non applicable',
  `hour` tinyint(4) DEFAULT NULL COMMENT 'Heure (0-23), NULL si non applicable',
  `frequency` enum('weekly','monthly','once','daily') NOT NULL DEFAULT 'weekly',
  `start_date` date DEFAULT NULL COMMENT 'Date de début',
  `end_date` date DEFAULT NULL COMMENT 'Date de fin',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_run_at` datetime DEFAULT NULL COMMENT 'Dernière exécution',
  `next_run_at` datetime DEFAULT NULL COMMENT 'Prochaine exécution planifiée',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ai_pilot_system_logs`
--

CREATE TABLE `ai_pilot_system_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `tenant_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'ID du tenant (NULL pour les logs système)',
  `level` enum('debug','info','warning','error','critical') NOT NULL,
  `message` text NOT NULL,
  `context` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Contexte additionnel (ex: stack trace, données)',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ai_pilot_tenants`
--

CREATE TABLE `ai_pilot_tenants` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL COMMENT 'Nom du tenant (ex: Cotton)',
  `slug` varchar(50) NOT NULL COMMENT 'Slug pour les URLs (ex: cotton-quiz)',
  `environment` enum('dev','prod','local') NOT NULL DEFAULT 'dev',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ai_pilot_tenant_agents`
--

CREATE TABLE `ai_pilot_tenant_agents` (
  `id` int(10) UNSIGNED NOT NULL,
  `tenant_id` int(10) UNSIGNED NOT NULL COMMENT 'ID du tenant',
  `agent_id` int(10) UNSIGNED NOT NULL COMMENT 'ID de l''agent',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Agent actif pour ce tenant',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ai_pilot_tenant_agent_configs`
--

CREATE TABLE `ai_pilot_tenant_agent_configs` (
  `id` int(10) UNSIGNED NOT NULL,
  `tenant_agent_id` int(10) UNSIGNED NOT NULL COMMENT 'ID de la liaison tenant/agent',
  `platform_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'ID de la plateforme (NULL si générique)',
  `config_key` varchar(50) NOT NULL COMMENT 'Clé de configuration (ex: prompt_versions, validation_rules)',
  `config_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Valeur de configuration (JSON)',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `bingo_players`
--

CREATE TABLE `bingo_players` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `gain_phase` tinyint(3) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1,
  `phase_wins_count` int(11) NOT NULL DEFAULT 0,
  `last_won_phase` int(11) DEFAULT NULL,
  `last_won_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Structure de la table `bingo_phase_winners`
--

CREATE TABLE `bingo_phase_winners` (
  `id` int(10) UNSIGNED NOT NULL,
  `session_id` varchar(255) NOT NULL,
  `phase` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `event_id` varchar(64) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `blindtest_players`
--

CREATE TABLE `blindtest_players` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `score` int(11) DEFAULT 0,
  `current_song_index` int(11) DEFAULT NULL,
  `is_answered` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Structure de la table `blindtest_sessions`
--

CREATE TABLE `blindtest_sessions` (
  `id` int(11) NOT NULL,
  `session_id` varchar(64) DEFAULT NULL,
  `playlist_id` varchar(255) DEFAULT NULL,
  `current_song_index` int(11) DEFAULT 0,
  `game_status` tinyint(4) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_reset` datetime DEFAULT NULL,
  `image_data` blob DEFAULT NULL,
  `podium_json` text DEFAULT NULL,
  `total_players` int(5) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Structure de la table `championnats_contributions_points`
--

CREATE TABLE `championnats_contributions_points` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_championnat_saison` smallint(5) UNSIGNED NOT NULL,
  `id_equipe_joueur` mediumint(8) UNSIGNED NOT NULL,
  `id_equipe` smallint(5) UNSIGNED NOT NULL,
  `date` text NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `contribution_points` varchar(255) NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `championnats_resultats`
--

CREATE TABLE `championnats_resultats` (
  `id` int(10) UNSIGNED NOT NULL,
  `id_championnat_session` smallint(5) UNSIGNED NOT NULL,
  `id_equipe` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `nom_court` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `equipe_session_points` smallint(5) UNSIGNED NOT NULL,
  `equipe_quiz_serie_1_points` smallint(5) NOT NULL DEFAULT -1,
  `equipe_quiz_serie_2_points` smallint(5) NOT NULL DEFAULT -1,
  `equipe_quiz_serie_3_points` smallint(5) NOT NULL DEFAULT -1,
  `equipe_quiz_serie_4_points` smallint(5) NOT NULL DEFAULT -1,
  `equipe_quiz_bonus_points` smallint(5) NOT NULL DEFAULT -1,
  `equipe_quiz_points` smallint(5) NOT NULL DEFAULT -1,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `championnats_saisons`
--

CREATE TABLE `championnats_saisons` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `nom_court` varchar(255) NOT NULL,
  `geo_nom` text NOT NULL,
  `date_debut` datetime NOT NULL,
  `date_fin` datetime NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `championnats_sessions`
--

CREATE TABLE `championnats_sessions` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_championnat_saison` smallint(5) UNSIGNED NOT NULL,
  `id_client` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `id_offre_client` int(11) NOT NULL,
  `id_operation_evenement` smallint(5) NOT NULL,
  `id_evenement` smallint(5) NOT NULL,
  `date` date NOT NULL,
  `heure_debut` text NOT NULL,
  `heure_fin` text NOT NULL,
  `flag_session_demo` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `flag_controle_numerique` tinyint(1) NOT NULL,
  `flag_session_privee` tinyint(1) NOT NULL DEFAULT 0,
  `flag_session_weblive` tinyint(1) NOT NULL DEFAULT 0,
  `flag_session_finale` tinyint(1) NOT NULL DEFAULT 0,
  `id_type_produit` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `id_format` tinyint(1) UNSIGNED NOT NULL,
  `id_produit` mediumint(8) NOT NULL,
  `code_session` varchar(255) NOT NULL,
  `nb_joueurs_max` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `nom_court` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lot_1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lot_2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lot_3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `diffusion_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `diffusion_evenement_nom` text NOT NULL,
  `diffusion_evenement_date` text NOT NULL,
  `diffusion_evenement_heure` text NOT NULL,
  `lien_url_sortie_app_1` varchar(255) NOT NULL,
  `lien_url_sortie_app_2` varchar(255) NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `flag_configuration_complete` tinyint(1) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL,
  `ip` varchar(15) NOT NULL,
  `lot_ids` text DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `championnats_sessions_lots`
--

CREATE TABLE `championnats_sessions_lots` (
  `id` mediumint(9) UNSIGNED NOT NULL,
  `id_championnat_session` mediumint(9) UNSIGNED NOT NULL,
  `phase_numero` smallint(4) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `championnats_sessions_lots_to_entites_joueurs`
--

CREATE TABLE `championnats_sessions_lots_to_entites_joueurs` (
  `id` mediumint(9) UNSIGNED NOT NULL,
  `id_lot` mediumint(9) UNSIGNED NOT NULL,
  `id_joueur` mediumint(9) UNSIGNED NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `clients`
--

CREATE TABLE `clients` (
  `id` mediumint(9) UNSIGNED NOT NULL,
  `flag_client_reseau_siege` tinyint(1) NOT NULL,
  `id_client_reseau` mediumint(9) NOT NULL,
  `numero` varchar(12) NOT NULL DEFAULT '0',
  `code_client` varchar(255) NOT NULL,
  `id_solution_usage` tinyint(2) UNSIGNED NOT NULL,
  `id_type` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `id_typologie` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `id_acquisition_canal` tinyint(2) NOT NULL,
  `id_zone_pays` smallint(5) UNSIGNED NOT NULL,
  `id_zone_departement` smallint(5) NOT NULL,
  `id_quiz_frequence` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `id_etat` tinyint(2) UNSIGNED NOT NULL DEFAULT 1,
  `id_pipeline_etat` tinyint(2) UNSIGNED NOT NULL DEFAULT 1,
  `code_langue` char(2) NOT NULL DEFAULT 'FR',
  `nom_social` varchar(255) NOT NULL,
  `nom` varchar(255) DEFAULT NULL,
  `adresse` varchar(255) NOT NULL,
  `adresse_2` varchar(255) NOT NULL,
  `cp` varchar(255) DEFAULT NULL,
  `ville` varchar(255) DEFAULT NULL,
  `pays` varchar(255) DEFAULT NULL,
  `code_pays` char(2) DEFAULT 'FR',
  `tel` varchar(255) NOT NULL,
  `heure_preference_appel` text NOT NULL,
  `fax` varchar(255) NOT NULL,
  `siret` varchar(255) NOT NULL,
  `tva_intracommunautaire` varchar(255) NOT NULL,
  `horaires_ouvertures` varchar(255) NOT NULL,
  `id_erp_jauges` smallint(5) NOT NULL,
  `id_reservation` tinyint(1) NOT NULL,
  `flag_activite_evenements` tinyint(1) NOT NULL,
  `flag_activite_jeux` tinyint(1) NOT NULL,
  `flag_activite_restauration` tinyint(1) NOT NULL,
  `commentaire_interne` text NOT NULL,
  `flag_sans_commande` tinyint(1) NOT NULL,
  `flag_non_assujetti_tva` tinyint(1) NOT NULL,
  `flag_offre_lancement` tinyint(1) UNSIGNED ZEROFILL NOT NULL DEFAULT 1,
  `flag_espace_client_aide` tinyint(1) UNSIGNED NOT NULL DEFAULT 1,
  `remise_pourcentage` tinyint(3) UNSIGNED NOT NULL,
  `commandes_payees_nb` smallint(5) NOT NULL,
  `commandes_payees_montant` decimal(8,2) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL,
  `lien_url_site_web` varchar(255) NOT NULL,
  `lien_url_site_web_reservation` varchar(255) NOT NULL,
  `lien_url_fb` varchar(255) NOT NULL,
  `lien_url_instagram` varchar(255) NOT NULL,
  `lien_url_tiktok` varchar(255) NOT NULL,
  `lien_url_linkedin` varchar(255) NOT NULL,
  `lien_url_youtube` varchar(255) NOT NULL,
  `flag_support_1` tinyint(1) NOT NULL,
  `flag_support_2` tinyint(1) NOT NULL,
  `flag_support_3` tinyint(1) NOT NULL,
  `flag_streaming_apple_music` tinyint(1) NOT NULL,
  `flag_streaming_deezer` tinyint(1) NOT NULL,
  `flag_streaming_qobuz` tinyint(1) NOT NULL,
  `flag_streaming_spotify` tinyint(1) NOT NULL,
  `flag_streaming_youtube_music` tinyint(1) NOT NULL,
  `flag_streaming_autre` tinyint(1) NOT NULL,
  `flag_adherent_bar_bars` tinyint(1) NOT NULL,
  `video_code` varchar(255) NOT NULL,
  `flag_mandat_sepa_acceptation` tinyint(1) NOT NULL,
  `mandat_sepa_acceptation_date` datetime NOT NULL,
  `mandat_sepa_raison_sociale` varchar(255) NOT NULL,
  `mandat_sepa_adresse` varchar(255) NOT NULL,
  `mandat_sepa_iban` varchar(255) NOT NULL,
  `mandat_sepa_bic` varchar(255) NOT NULL,
  `mandat_sepa_banque_nom` varchar(255) NOT NULL,
  `mandat_sepa_rum` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(3) DEFAULT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `commentaire` text NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL,
  `asset_recurseeve_customerId` varchar(255) DEFAULT NULL,
  `asset_recurseeve_billingContactId` varchar(255) DEFAULT NULL,
  `asset_recurseeve_usageReferenceId` varchar(255) DEFAULT NULL,
  `asset_stripe_customerId` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `clients_branding`
--

CREATE TABLE `clients_branding` (
  `id` int(11) NOT NULL,
  `id_client` int(11) NOT NULL,
  `id_operation_evenement` int(11) DEFAULT NULL,
  `color_background_1` varchar(7) DEFAULT NULL,
  `color_font_1` varchar(7) DEFAULT NULL,
  `color_background_2` varchar(7) DEFAULT NULL,
  `color_font_2` varchar(7) DEFAULT NULL,
  `fonction_bonus_flag` tinyint(1) DEFAULT 0,
  `fonction_bonus_title` varchar(255) DEFAULT NULL,
  `fonction_bonus_text` text DEFAULT NULL,
  `rs_flag` tinyint(1) DEFAULT 0,
  `rs_facebook_url` varchar(255) DEFAULT NULL,
  `rs_facebook_title` varchar(255) DEFAULT NULL,
  `rs_instagram_url` varchar(255) DEFAULT NULL,
  `rs_instagram_title` varchar(255) DEFAULT NULL,
  `rs_website_url` varchar(255) DEFAULT NULL,
  `rs_website_title` varchar(255) DEFAULT NULL,
  `rs_google_review_url` varchar(255) DEFAULT NULL,
  `rs_google_review_title` varchar(255) DEFAULT NULL,
  `fonction_agenda_flag` tinyint(1) DEFAULT 0,
  `font_family_name` varchar(255) DEFAULT NULL,
  `font_family_url` varchar(255) DEFAULT NULL,
  `online` tinyint(1) NOT NULL,
  `date_ajout` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `clients_contacts`
--

CREATE TABLE `clients_contacts` (
  `id` mediumint(9) UNSIGNED NOT NULL,
  `code_langue` char(2) NOT NULL DEFAULT '0',
  `civilite` varchar(5) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `tel` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `pwd` varchar(255) NOT NULL,
  `pwd_token` varchar(23) NOT NULL,
  `pwd_token_date` datetime NOT NULL,
  `flag_invitation` tinyint(1) NOT NULL,
  `flag_email_verifie` tinyint(1) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `clients_contacts_to_clients`
--

CREATE TABLE `clients_contacts_to_clients` (
  `id_client_contact` mediumint(9) NOT NULL,
  `id_client` mediumint(9) NOT NULL,
  `id_type` tinyint(2) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=FIXED;

-- --------------------------------------------------------

--
-- Structure de la table `clients_emails_transactionnels_logs`
--

CREATE TABLE `clients_emails_transactionnels_logs` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_client` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `id_client_contact` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `id_email_transactionnel` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `code_email_transactionnel` varchar(255) NOT NULL,
  `a` varchar(255) NOT NULL,
  `id_log_type` tinyint(1) NOT NULL DEFAULT 1,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `date_ajout` datetime NOT NULL,
  `ip` varchar(15) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `clients_logs`
--

CREATE TABLE `clients_logs` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_client` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `id_client_contact` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `a` varchar(255) NOT NULL,
  `id_log_type` tinyint(1) NOT NULL DEFAULT 1,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `date_ajout` datetime NOT NULL,
  `ip` varchar(15) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `clients_logs_onboarding`
--

CREATE TABLE `clients_logs_onboarding` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_sous_domaine` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `flag_creation_interne` tinyint(1) NOT NULL,
  `ob_version` text NOT NULL,
  `ob_step_acces` tinyint(1) NOT NULL,
  `ob_page_origine` varchar(255) NOT NULL,
  `ob_type` tinyint(3) UNSIGNED NOT NULL,
  `id_type_produit` tinyint(1) NOT NULL,
  `id_catalogue_theme` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `lots` varchar(255) NOT NULL,
  `id_support` tinyint(1) NOT NULL,
  `id_securite_championnat_session` varchar(255) NOT NULL,
  `session_date` date NOT NULL,
  `session_heure_debut` text NOT NULL,
  `client_heure_preference_appel` text NOT NULL,
  `client_nom` varchar(255) NOT NULL,
  `client_ville` varchar(255) NOT NULL,
  `client_contact_prenom` varchar(255) NOT NULL,
  `client_contact_tel` varchar(255) NOT NULL,
  `client_contact_email` varchar(255) NOT NULL,
  `client_contact_pwd` varchar(255) NOT NULL,
  `client_note` tinyint(1) NOT NULL,
  `client_commentaire` blob NOT NULL,
  `id_client` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `id_client_contact` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `utm_source` varchar(255) NOT NULL,
  `utm_medium` varchar(255) NOT NULL,
  `utm_campaign` varchar(255) NOT NULL,
  `utm_term` varchar(255) NOT NULL,
  `utm_content` varchar(255) NOT NULL,
  `session_id` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `ip` varchar(15) NOT NULL,
  `parcours` blob NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `clients_logs_utm`
--

CREATE TABLE `clients_logs_utm` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_client` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `id_client_contact` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `id_sous_domaine` tinyint(1) NOT NULL,
  `email` varchar(255) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `utm_source` varchar(255) NOT NULL,
  `utm_medium` varchar(255) NOT NULL,
  `utm_campaign` varchar(255) NOT NULL,
  `utm_term` varchar(255) NOT NULL,
  `utm_content` varchar(255) NOT NULL,
  `ad` varchar(255) NOT NULL,
  `ad_pos` varchar(255) NOT NULL,
  `parametres` varchar(255) NOT NULL,
  `page` varchar(255) NOT NULL,
  `session_id` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `ip` varchar(15) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `clients_temoignages`
--

CREATE TABLE `clients_temoignages` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_client_contact` mediumint(9) UNSIGNED NOT NULL DEFAULT 0,
  `id_client` mediumint(9) UNSIGNED NOT NULL DEFAULT 0,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `date` datetime NOT NULL,
  `fonction` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `communication_actualites`
--

CREATE TABLE `communication_actualites` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_sous_domaine` tinyint(1) NOT NULL,
  `id_communication_actualites_rubrique` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `date` varchar(255) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `nom_paragraphe_1` varchar(255) NOT NULL,
  `descriptif_long_paragraphe_1` text NOT NULL,
  `video_code_paragraphe_1` varchar(255) NOT NULL,
  `externe_code_paragraphe_1` text NOT NULL,
  `nom_paragraphe_2` varchar(255) NOT NULL,
  `descriptif_long_paragraphe_2` text NOT NULL,
  `video_code_paragraphe_2` varchar(255) NOT NULL,
  `externe_code_paragraphe_2` text NOT NULL,
  `nom_paragraphe_3` varchar(255) NOT NULL,
  `descriptif_long_paragraphe_3` text NOT NULL,
  `video_code_paragraphe_3` varchar(255) NOT NULL,
  `externe_code_paragraphe_3` text NOT NULL,
  `nom_paragraphe_4` varchar(255) NOT NULL,
  `descriptif_long_paragraphe_4` text NOT NULL,
  `video_code_paragraphe_4` varchar(255) NOT NULL,
  `externe_code_paragraphe_4` text NOT NULL,
  `nom_paragraphe_5` varchar(255) NOT NULL,
  `descriptif_long_paragraphe_5` text NOT NULL,
  `video_code_paragraphe_5` varchar(255) NOT NULL,
  `externe_code_paragraphe_5` text NOT NULL,
  `nom_paragraphe_6` varchar(255) NOT NULL,
  `descriptif_long_paragraphe_6` text NOT NULL,
  `video_code_paragraphe_6` varchar(255) NOT NULL,
  `externe_code_paragraphe_6` text NOT NULL,
  `nom_paragraphe_7` varchar(255) NOT NULL,
  `descriptif_long_paragraphe_7` text NOT NULL,
  `video_code_paragraphe_7` varchar(255) NOT NULL,
  `externe_code_paragraphe_7` text NOT NULL,
  `nom_paragraphe_8` varchar(255) NOT NULL,
  `descriptif_long_paragraphe_8` text NOT NULL,
  `video_code_paragraphe_8` varchar(255) NOT NULL,
  `externe_code_paragraphe_8` text NOT NULL,
  `nom_paragraphe_9` varchar(255) NOT NULL,
  `descriptif_long_paragraphe_9` text NOT NULL,
  `video_code_paragraphe_9` varchar(255) NOT NULL,
  `externe_code_paragraphe_9` text NOT NULL,
  `nom_paragraphe_10` varchar(255) NOT NULL,
  `descriptif_long_paragraphe_10` text NOT NULL,
  `video_code_paragraphe_10` varchar(255) NOT NULL,
  `externe_code_paragraphe_10` text NOT NULL,
  `faq_question_1` varchar(255) DEFAULT NULL,
  `faq_reponse_1` text DEFAULT NULL,
  `faq_question_2` varchar(255) DEFAULT NULL,
  `faq_reponse_2` text DEFAULT NULL,
  `faq_question_3` varchar(255) DEFAULT NULL,
  `faq_reponse_3` text DEFAULT NULL,
  `faq_question_4` varchar(255) DEFAULT NULL,
  `faq_reponse_4` text DEFAULT NULL,
  `faq_question_5` varchar(255) DEFAULT NULL,
  `faq_reponse_5` text DEFAULT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `communication_actualites_rubriques`
--

CREATE TABLE `communication_actualites_rubriques` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom_court` text NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `communication_focus`
--

CREATE TABLE `communication_focus` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `communication_slides`
--

CREATE TABLE `communication_slides` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `cotton_quiz_players`
--

CREATE TABLE `cotton_quiz_players` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `score` int(11) DEFAULT 0,
  `current_song_index` int(11) DEFAULT NULL,
  `is_answered` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Structure de la table `cotton_quiz_sessions`
--

CREATE TABLE `cotton_quiz_sessions` (
  `id` int(11) NOT NULL,
  `session_id` varchar(64) DEFAULT NULL,
  `playlist_id` varchar(255) DEFAULT NULL,
  `current_song_index` int(11) DEFAULT 0,
  `game_status` tinyint(4) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_reset` datetime DEFAULT NULL,
  `image_data` blob DEFAULT NULL,
  `podium_json` text DEFAULT NULL,
  `total_players` int(5) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Structure de la table `crm_abonnes`
--

CREATE TABLE `crm_abonnes` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_sous_domaine` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `civilite` varchar(5) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `societe` varchar(255) NOT NULL,
  `adresse` varchar(255) NOT NULL,
  `cp` varchar(255) NOT NULL,
  `ville` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `tel` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `crm_contacts`
--

CREATE TABLE `crm_contacts` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_sous_domaine` tinyint(1) NOT NULL,
  `id_utilisateur` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `civilite` varchar(5) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `societe` varchar(255) NOT NULL,
  `adresse` varchar(255) NOT NULL,
  `cp` varchar(255) NOT NULL,
  `ville` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `tel` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `crm_parrainages`
--

CREATE TABLE `crm_parrainages` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_type_parrain` tinyint(2) UNSIGNED NOT NULL,
  `id_parrain` mediumint(9) UNSIGNED NOT NULL,
  `id_parrain_contact` mediumint(9) UNSIGNED NOT NULL,
  `prenom_filleul` varchar(50) NOT NULL,
  `email_filleul` varchar(150) NOT NULL,
  `nb_invitation` tinyint(3) UNSIGNED NOT NULL,
  `message` text NOT NULL,
  `flag_NA` tinyint(1) NOT NULL,
  `flag_converti` tinyint(1) NOT NULL,
  `id_client_filleul` mediumint(9) UNSIGNED NOT NULL,
  `id_offre_client_filleul` mediumint(9) UNSIGNED NOT NULL,
  `online` tinyint(1) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ecommerce_commandes`
--

CREATE TABLE `ecommerce_commandes` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_client` mediumint(8) UNSIGNED NOT NULL,
  `id_offre_client` mediumint(8) UNSIGNED NOT NULL,
  `id_etat` tinyint(1) NOT NULL,
  `id_paiement_mode` tinyint(1) UNSIGNED NOT NULL,
  `id_type_envoi` tinyint(3) UNSIGNED NOT NULL,
  `annee` smallint(4) UNSIGNED NOT NULL,
  `mois` tinyint(2) UNSIGNED NOT NULL,
  `numero_commande` varchar(255) NOT NULL,
  `numero_facture` varchar(255) NOT NULL,
  `commentaire_facture` blob NOT NULL,
  `numero_client` varchar(255) NOT NULL,
  `date_creation` datetime NOT NULL,
  `date_facture` datetime NOT NULL,
  `date_paiement` datetime NOT NULL,
  `date_envoi_mail_confirmation` datetime NOT NULL,
  `date_expedition` date NOT NULL,
  `numero_suivi_expedition` varchar(255) NOT NULL,
  `flag_maj_stock_produits` tinyint(1) NOT NULL,
  `poids_total` mediumint(8) UNSIGNED NOT NULL,
  `remise_code` varchar(255) NOT NULL,
  `remise_type` varchar(255) NOT NULL,
  `remise_nom` varchar(255) NOT NULL,
  `remise_pourcentage` decimal(5,2) UNSIGNED NOT NULL,
  `remise_ht` decimal(9,2) UNSIGNED NOT NULL,
  `remise_ttc` decimal(9,2) UNSIGNED NOT NULL,
  `id_avoir` smallint(5) UNSIGNED NOT NULL,
  `montant_avoir` decimal(9,2) UNSIGNED NOT NULL,
  `numero_avoir` varchar(255) NOT NULL,
  `flag_colis_signature` tinyint(1) NOT NULL,
  `flag_colis_bonus` tinyint(1) NOT NULL,
  `frais_port_offert` tinyint(1) NOT NULL,
  `frais_port_ht` decimal(9,2) UNSIGNED NOT NULL,
  `frais_port_ttc` decimal(9,2) UNSIGNED NOT NULL,
  `eco_participation_ht` decimal(9,2) UNSIGNED NOT NULL,
  `eco_participation_ttc` decimal(9,2) UNSIGNED NOT NULL,
  `total_ht` decimal(9,2) UNSIGNED NOT NULL,
  `total_ttc` decimal(9,2) UNSIGNED NOT NULL,
  `societe` varchar(255) NOT NULL,
  `siret` varchar(255) NOT NULL,
  `tva_intracommunautaire` varchar(255) NOT NULL,
  `civilite` varchar(255) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `adresse` text NOT NULL,
  `adresse_2` text NOT NULL,
  `cp` varchar(255) NOT NULL,
  `ville` varchar(255) NOT NULL,
  `pays` varchar(255) NOT NULL,
  `code_pays` char(2) NOT NULL,
  `email` varchar(255) NOT NULL,
  `tel` varchar(255) NOT NULL,
  `portable` varchar(255) NOT NULL,
  `fax` varchar(255) NOT NULL,
  `adresse_livraison_differente` tinyint(1) NOT NULL,
  `societe_livraison` varchar(255) NOT NULL,
  `civilite_livraison` varchar(255) NOT NULL,
  `nom_livraison` varchar(255) NOT NULL,
  `prenom_livraison` varchar(255) NOT NULL,
  `adresse_livraison` text NOT NULL,
  `adresse_livraison_2` text NOT NULL,
  `cp_livraison` varchar(255) NOT NULL,
  `ville_livraison` varchar(255) NOT NULL,
  `pays_livraison` varchar(255) NOT NULL,
  `code_pays_livraison` char(2) NOT NULL,
  `email_livraison` varchar(255) NOT NULL,
  `tel_livraison` varchar(255) NOT NULL,
  `portable_livraison` varchar(255) NOT NULL,
  `fax_livraison` varchar(255) NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `commentaire` text NOT NULL,
  `quantite_produit_distinct` tinyint(3) UNSIGNED NOT NULL,
  `quantite_produit` smallint(5) UNSIGNED NOT NULL,
  `etat_litige` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `commentaire_litige` text NOT NULL,
  `temp_nb_produits` smallint(5) UNSIGNED NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `ecommerce_commandes_lignes`
--

CREATE TABLE `ecommerce_commandes_lignes` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_commande` mediumint(8) UNSIGNED NOT NULL,
  `id_offre_client` mediumint(8) UNSIGNED NOT NULL,
  `id_type_produit` tinyint(1) UNSIGNED NOT NULL,
  `id_produit` smallint(5) UNSIGNED NOT NULL,
  `nom` tinytext NOT NULL,
  `date` date NOT NULL,
  `poids_unitaire` mediumint(8) UNSIGNED NOT NULL,
  `eco_participation_ht` decimal(8,2) NOT NULL,
  `eco_participation_ttc` decimal(8,2) NOT NULL,
  `tva` decimal(5,2) NOT NULL,
  `prix_unitaire_ht` decimal(8,2) NOT NULL,
  `prix_unitaire_ttc` decimal(8,2) NOT NULL,
  `quantite` smallint(5) UNSIGNED NOT NULL,
  `poids_total` mediumint(8) UNSIGNED NOT NULL,
  `remise_nom` varchar(255) NOT NULL,
  `remise_pourcentage` decimal(5,2) NOT NULL,
  `remise_ht` decimal(8,2) NOT NULL,
  `remise_ttc` decimal(8,2) NOT NULL,
  `total_ht` decimal(8,2) NOT NULL,
  `total_ttc` decimal(8,2) NOT NULL,
  `flag_une` tinyint(1) NOT NULL,
  `flag_coup_coeur` tinyint(1) NOT NULL,
  `flag_nouveaute` tinyint(1) NOT NULL,
  `flag_top_ventes` tinyint(1) NOT NULL,
  `flag_bonne_affaire` tinyint(1) NOT NULL,
  `flag_promo` tinyint(1) NOT NULL,
  `flag_solde` tinyint(1) NOT NULL,
  `note` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(3) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_securite` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ecommerce_formules`
--

CREATE TABLE `ecommerce_formules` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL,
  `asset_recurseeve_billedComponentsProductId` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `ecommerce_formules_declinaisons`
--

CREATE TABLE `ecommerce_formules_declinaisons` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `numero` varchar(255) NOT NULL DEFAULT '0',
  `id_formule` smallint(5) UNSIGNED NOT NULL,
  `id_erp_jauge` smallint(5) UNSIGNED NOT NULL,
  `id_engagement` smallint(5) UNSIGNED NOT NULL,
  `id_paiement_frequence` smallint(5) UNSIGNED NOT NULL,
  `prix_ht` decimal(8,2) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ecommerce_formules_declinaisons_to_clients`
--

CREATE TABLE `ecommerce_formules_declinaisons_to_clients` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_client` mediumint(9) UNSIGNED NOT NULL,
  `id_formule_declinaison` smallint(5) UNSIGNED NOT NULL,
  `id_etat` smallint(5) UNSIGNED NOT NULL,
  `periode_essai_animations_nb` tinyint(1) UNSIGNED NOT NULL,
  `date_debut` date NOT NULL,
  `date_fin` date NOT NULL,
  `prix_ht` decimal(8,2) NOT NULL,
  `flag_cgu_acceptation` tinyint(1) NOT NULL,
  `cgu_acceptation_date` datetime NOT NULL,
  `iban` varchar(255) NOT NULL,
  `bic` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ecommerce_offres`
--

CREATE TABLE `ecommerce_offres` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `nb_animation` tinyint(3) UNSIGNED NOT NULL,
  `id_offre_type` tinyint(1) DEFAULT NULL,
  `id_paiement_type` tinyint(4) NOT NULL,
  `flag_prix_a_partir_de` tinyint(1) NOT NULL,
  `flag_engagement` tinyint(1) NOT NULL,
  `prix_ht` decimal(8,2) NOT NULL,
  `prix_remise_ht` decimal(8,2) NOT NULL,
  `produit_additionnel_prix_ht` decimal(8,2) NOT NULL,
  `lien_url_paiement_CB` text NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `ecommerce_offres_paniers`
--

CREATE TABLE `ecommerce_offres_paniers` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_client` mediumint(9) UNSIGNED NOT NULL,
  `id_offre` smallint(5) UNSIGNED NOT NULL,
  `id_client_typologie` tinyint(2) NOT NULL,
  `id_erp_jauge` tinyint(3) UNSIGNED NOT NULL,
  `id_paiement_frequence` tinyint(3) UNSIGNED NOT NULL,
  `id_etat` tinyint(4) NOT NULL,
  `id_commande` smallint(5) UNSIGNED NOT NULL,
  `id_operation_evenement` smallint(5) UNSIGNED NOT NULL,
  `date_debut` date NOT NULL,
  `date_fin` date NOT NULL,
  `date_facturation_debut` date NOT NULL,
  `date_facturation_fin` date NOT NULL,
  `nb_animation` smallint(5) UNSIGNED NOT NULL,
  `remise_nom` varchar(255) NOT NULL,
  `remise_pourcentage` tinyint(3) UNSIGNED NOT NULL,
  `prix_ht` decimal(8,2) NOT NULL,
  `produit_additionnel_prix_ht` decimal(8,2) NOT NULL,
  `trial_period_days` tinyint(3) NOT NULL DEFAULT 0,
  `lien_url_paiement_CB` text NOT NULL,
  `flag_offert` tinyint(1) NOT NULL,
  `flag_cgu_acceptation` tinyint(1) NOT NULL,
  `cgu_acceptation_date` datetime NOT NULL,
  `iban` varchar(255) NOT NULL,
  `bic` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `id_entite_utilisateur` smallint(5) NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ecommerce_offres_to_clients`
--

CREATE TABLE `ecommerce_offres_to_clients` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_client` mediumint(9) UNSIGNED NOT NULL,
  `id_client_delegation` mediumint(9) NOT NULL,
  `id_offre` smallint(5) UNSIGNED NOT NULL,
  `id_erp_jauge` tinyint(3) UNSIGNED NOT NULL,
  `id_paiement_frequence` tinyint(3) UNSIGNED NOT NULL,
  `id_etat` tinyint(4) NOT NULL,
  `id_commande` smallint(5) UNSIGNED NOT NULL,
  `id_operation_evenement` smallint(5) UNSIGNED NOT NULL,
  `date_debut` date NOT NULL,
  `date_fin` date NOT NULL,
  `flag_facturation_debut_periode` tinyint(1) NOT NULL,
  `date_facturation_debut` date NOT NULL,
  `date_facturation_fin` date NOT NULL,
  `nb_animation` smallint(5) UNSIGNED NOT NULL,
  `remise_nom` varchar(255) NOT NULL,
  `remise_pourcentage` tinyint(3) UNSIGNED NOT NULL,
  `prix_ht` decimal(8,2) NOT NULL,
  `produit_additionnel_prix_ht` decimal(8,2) NOT NULL,
  `lien_url_paiement_CB` text NOT NULL,
  `trial_period_days` tinyint(3) NOT NULL DEFAULT 0,
  `flag_offert` tinyint(1) NOT NULL,
  `flag_cgu_acceptation` tinyint(1) NOT NULL,
  `cgu_acceptation_date` datetime NOT NULL,
  `iban` varchar(255) NOT NULL,
  `bic` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `commentaire` blob NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `id_entite_utilisateur` smallint(5) NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL,
  `asset_stripe_productId` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ecommerce_produits_types`
--

CREATE TABLE `ecommerce_produits_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `reference` tinytext DEFAULT NULL,
  `bdd_table` tinytext DEFAULT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `poids` smallint(5) UNSIGNED DEFAULT NULL,
  `prix_ht` decimal(8,2) UNSIGNED DEFAULT NULL,
  `prix_avant_remise_ht` decimal(8,2) UNSIGNED DEFAULT NULL,
  `eco_participation_ht` decimal(8,2) UNSIGNED DEFAULT NULL,
  `tva_taux` smallint(5) UNSIGNED DEFAULT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `flag_nouveaute` tinyint(1) NOT NULL DEFAULT 0,
  `flag_edition_limitee` tinyint(1) NOT NULL DEFAULT 0,
  `flag_bonne_affaire` tinyint(1) NOT NULL DEFAULT 0,
  `flag_made_in_france` tinyint(1) NOT NULL DEFAULT 0,
  `flag_frais_port_offert` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `ecommerce_remises`
--

CREATE TABLE `ecommerce_remises` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_remise_type` tinyint(1) UNSIGNED NOT NULL,
  `id_solution_usage` tinyint(2) UNSIGNED NOT NULL,
  `id_typologie` tinyint(2) UNSIGNED NOT NULL,
  `id_pipeline_etat` tinyint(2) NOT NULL,
  `code` varchar(255) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL,
  `id_securite` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `ecommerce_remises_clients`
--

CREATE TABLE `ecommerce_remises_clients` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_client` mediumint(9) UNSIGNED NOT NULL,
  `id_remise` smallint(5) NOT NULL,
  `id_remise_type` tinyint(1) UNSIGNED NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `ecommerce_remises_to_offres`
--

CREATE TABLE `ecommerce_remises_to_offres` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_remise` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `id_offre` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `nom` varchar(255) NOT NULL,
  `remise_montant` decimal(8,2) UNSIGNED NOT NULL,
  `remise_pourcentage` decimal(5,2) UNSIGNED NOT NULL,
  `periode_offerte_nb_jours` tinyint(15) NOT NULL,
  `produit_additionnel_prix_ht` decimal(8,2) NOT NULL,
  `date_debut` date DEFAULT NULL,
  `date_fin` date DEFAULT NULL,
  `flag_usage_unique` tinyint(1) NOT NULL,
  `duree_validite_jours` smallint(1) NOT NULL,
  `montant_minimum_commande` decimal(8,2) UNSIGNED NOT NULL,
  `lien_url_paiement_CB` text NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `ecommerce_remises_to_offres_clients`
--

CREATE TABLE `ecommerce_remises_to_offres_clients` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_remise_client` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `id_offre` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `nom` varchar(255) NOT NULL,
  `remise_montant` decimal(8,2) UNSIGNED NOT NULL,
  `remise_pourcentage` decimal(5,2) UNSIGNED NOT NULL,
  `produit_additionnel_prix_ht` decimal(8,2) NOT NULL,
  `date_debut` date DEFAULT NULL,
  `date_fin` date DEFAULT NULL,
  `flag_usage_unique` tinyint(1) NOT NULL,
  `duree_validite_jours` smallint(1) NOT NULL,
  `montant_minimum_commande` decimal(8,2) UNSIGNED NOT NULL,
  `lien_url_paiement_CB` text NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `entites_joueurs_emails_transactionnels_logs`
--

CREATE TABLE `entites_joueurs_emails_transactionnels_logs` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_joueur` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `id_email_transactionnel` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `a` varchar(255) NOT NULL,
  `id_log_type` tinyint(1) NOT NULL DEFAULT 1,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `date_ajout` datetime NOT NULL,
  `ip` varchar(15) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `entites_joueurs_logs`
--

CREATE TABLE `entites_joueurs_logs` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_joueur` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `a` varchar(255) NOT NULL,
  `id_log_type` tinyint(1) NOT NULL DEFAULT 1,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `date_ajout` datetime NOT NULL,
  `ip` varchar(15) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `entites_utilisateurs`
--

CREATE TABLE `entites_utilisateurs` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_type` tinyint(5) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `tel` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url_site_web` varchar(255) NOT NULL,
  `lien_url_fb` varchar(255) NOT NULL,
  `lien_url_instagram` varchar(255) NOT NULL,
  `lien_url_linkedin` varchar(255) NOT NULL,
  `lien_url_youtube` varchar(255) NOT NULL,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `pwd` varchar(255) NOT NULL,
  `pwd_token` varchar(23) NOT NULL,
  `pwd_token_date` datetime NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `entites_utilisateurs_logs`
--

CREATE TABLE `entites_utilisateurs_logs` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_utilisateur` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `a` varchar(255) NOT NULL,
  `id_log_type` tinyint(1) NOT NULL DEFAULT 1,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `date_ajout` datetime NOT NULL,
  `ip` varchar(15) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `equipes`
--

CREATE TABLE `equipes` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_zone_departement` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `id_client` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `numero` varchar(12) NOT NULL DEFAULT '0',
  `code_langue` char(2) NOT NULL DEFAULT '0',
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `flag_equipe_passage` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `equipes_championnats_sessions_reponses`
--

CREATE TABLE `equipes_championnats_sessions_reponses` (
  `id_equipe` smallint(5) UNSIGNED NOT NULL,
  `id_championnat_session` smallint(5) UNSIGNED NOT NULL,
  `numero_serie` tinyint(1) NOT NULL,
  `numero_question` tinyint(1) NOT NULL,
  `reponse` text NOT NULL,
  `flag_correction` tinyint(1) NOT NULL DEFAULT 0,
  `points` tinyint(1) UNSIGNED ZEROFILL DEFAULT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `equipes_joueurs`
--

CREATE TABLE `equipes_joueurs` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_zone_departement` smallint(5) NOT NULL,
  `code_langue` char(2) NOT NULL,
  `civilite` tinyint(4) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `tel` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `pwd` varchar(255) NOT NULL,
  `pwd_token` varchar(23) NOT NULL,
  `pwd_token_date` datetime NOT NULL,
  `flag_invitation` tinyint(1) NOT NULL,
  `flag_email_verifie` tinyint(1) NOT NULL,
  `flag_alerte_equipe_session_inscription` tinyint(1) NOT NULL,
  `flag_joueur_session_privee` tinyint(1) NOT NULL DEFAULT 0,
  `lien_url_fb` varchar(255) NOT NULL,
  `rgpd_consentement_cgu` tinyint(1) NOT NULL,
  `rgpd_consentement_cgu_date` datetime NOT NULL,
  `rgpd_consentement_offres_partenaires` tinyint(1) NOT NULL,
  `rgpd_consentement_offres_partenaires_date` datetime NOT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(1) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_securite` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `equipes_joueurs_to_equipes`
--

CREATE TABLE `equipes_joueurs_to_equipes` (
  `id_equipe_joueur` mediumint(9) NOT NULL,
  `id_equipe` mediumint(9) NOT NULL,
  `id_type` tinyint(2) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=FIXED;

-- --------------------------------------------------------

--
-- Structure de la table `equipes_logs`
--

CREATE TABLE `equipes_logs` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_equipe` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `id_equipe_joueur` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `a` varchar(255) NOT NULL,
  `id_log_type` tinyint(1) NOT NULL DEFAULT 1,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `date_ajout` datetime NOT NULL,
  `ip` varchar(15) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `equipes_to_championnats_sessions`
--

CREATE TABLE `equipes_to_championnats_sessions` (
  `id_equipe` mediumint(9) NOT NULL,
  `id_championnat_session` mediumint(9) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `ip` varchar(15) DEFAULT NULL,
  `id_user_ajout` mediumint(8) NOT NULL,
  `id_user_maj` mediumint(8) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `game_events`
--

CREATE TABLE `game_events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `event_id` varchar(64) NOT NULL,
  `game` varchar(16) NOT NULL,
  `action` varchar(64) NOT NULL,
  `session_id` varchar(128) DEFAULT NULL,
  `player_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `payload_json` mediumtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `general_branding`
--

CREATE TABLE `general_branding` (
  `id` int(11) NOT NULL,
  `id_type_branding` tinyint(1) NOT NULL,
  `id_related` int(11) NOT NULL,
  `color_background_1` varchar(7) DEFAULT NULL,
  `color_font_1` varchar(7) DEFAULT NULL,
  `color_background_2` varchar(7) DEFAULT NULL,
  `color_font_2` varchar(7) DEFAULT NULL,
  `fonction_bonus_flag` tinyint(1) DEFAULT 0,
  `fonction_bonus_title` varchar(255) DEFAULT NULL,
  `fonction_bonus_text` text DEFAULT NULL,
  `rs_flag` tinyint(1) DEFAULT 0,
  `rs_facebook_url` varchar(255) DEFAULT NULL,
  `rs_facebook_title` varchar(255) DEFAULT NULL,
  `rs_instagram_url` varchar(255) DEFAULT NULL,
  `rs_instagram_title` varchar(255) DEFAULT NULL,
  `rs_website_url` varchar(255) DEFAULT NULL,
  `rs_website_title` varchar(255) DEFAULT NULL,
  `rs_google_review_url` varchar(255) DEFAULT NULL,
  `rs_google_review_title` varchar(255) DEFAULT NULL,
  `fonction_agenda_flag` tinyint(1) DEFAULT 0,
  `font_family_name` varchar(255) DEFAULT NULL,
  `font_family_url` varchar(255) DEFAULT NULL,
  `online` tinyint(1) NOT NULL,
  `date_ajout` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Structure de la table `general_parametres`
--

CREATE TABLE `general_parametres` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `valeur` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `general_univers`
--

CREATE TABLE `general_univers` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `jeux_bingo_musical_artistes`
--

CREATE TABLE `jeux_bingo_musical_artistes` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `jeux_bingo_musical_grids`
--

CREATE TABLE `jeux_bingo_musical_grids` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `box_1_number` tinyint(1) UNSIGNED NOT NULL,
  `box_2_number` tinyint(1) UNSIGNED NOT NULL,
  `box_3_number` tinyint(1) UNSIGNED NOT NULL,
  `box_4_number` tinyint(1) UNSIGNED NOT NULL,
  `box_5_number` tinyint(1) UNSIGNED NOT NULL,
  `box_6_number` tinyint(1) UNSIGNED NOT NULL,
  `box_7_number` tinyint(1) UNSIGNED NOT NULL,
  `box_8_number` tinyint(1) UNSIGNED NOT NULL,
  `box_9_number` tinyint(1) UNSIGNED NOT NULL,
  `box_10_number` tinyint(1) UNSIGNED NOT NULL,
  `box_11_number` tinyint(1) UNSIGNED NOT NULL,
  `box_12_number` tinyint(1) UNSIGNED NOT NULL,
  `box_13_number` tinyint(1) UNSIGNED NOT NULL,
  `box_14_number` tinyint(1) UNSIGNED NOT NULL,
  `box_15_number` tinyint(1) UNSIGNED NOT NULL,
  `box_16_number` tinyint(1) UNSIGNED NOT NULL,
  `box_17_number` tinyint(1) UNSIGNED NOT NULL,
  `box_18_number` tinyint(1) UNSIGNED NOT NULL,
  `box_19_number` tinyint(1) UNSIGNED NOT NULL,
  `box_20_number` tinyint(1) UNSIGNED NOT NULL,
  `box_21_number` tinyint(1) UNSIGNED NOT NULL,
  `box_22_number` tinyint(1) UNSIGNED NOT NULL,
  `box_23_number` tinyint(1) UNSIGNED NOT NULL,
  `box_24_number` tinyint(1) UNSIGNED NOT NULL,
  `box_25_number` tinyint(1) NOT NULL,
  `grid_hash` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `jeux_bingo_musical_grids_clients`
--

CREATE TABLE `jeux_bingo_musical_grids_clients` (
  `id` mediumint(9) UNSIGNED NOT NULL,
  `id_playlist_client` mediumint(9) UNSIGNED NOT NULL,
  `id_joueur` mediumint(9) UNSIGNED DEFAULT 0,
  `flag_demo` tinyint(1) NOT NULL,
  `id_joueur_demo` mediumint(9) UNSIGNED DEFAULT 0,
  `id_grid_support` tinyint(1) UNSIGNED NOT NULL,
  `numero` smallint(5) UNSIGNED NOT NULL,
  `box_1_number` tinyint(1) UNSIGNED NOT NULL,
  `box_1_timestamp` datetime NOT NULL,
  `box_2_number` tinyint(1) UNSIGNED NOT NULL,
  `box_2_timestamp` datetime NOT NULL,
  `box_3_number` tinyint(1) UNSIGNED NOT NULL,
  `box_3_timestamp` datetime NOT NULL,
  `box_4_number` tinyint(1) UNSIGNED NOT NULL,
  `box_4_timestamp` datetime NOT NULL,
  `box_5_number` tinyint(1) UNSIGNED NOT NULL,
  `box_5_timestamp` datetime NOT NULL,
  `box_6_number` tinyint(1) UNSIGNED NOT NULL,
  `box_6_timestamp` datetime NOT NULL,
  `box_7_number` tinyint(1) UNSIGNED NOT NULL,
  `box_7_timestamp` datetime NOT NULL,
  `box_8_number` tinyint(1) UNSIGNED NOT NULL,
  `box_8_timestamp` datetime NOT NULL,
  `box_9_number` tinyint(1) UNSIGNED NOT NULL,
  `box_9_timestamp` datetime NOT NULL,
  `box_10_number` tinyint(1) UNSIGNED NOT NULL,
  `box_10_timestamp` datetime NOT NULL,
  `box_11_number` tinyint(1) UNSIGNED NOT NULL,
  `box_11_timestamp` datetime NOT NULL,
  `box_12_number` tinyint(1) UNSIGNED NOT NULL,
  `box_12_timestamp` datetime NOT NULL,
  `box_13_number` tinyint(1) UNSIGNED NOT NULL,
  `box_13_timestamp` datetime NOT NULL,
  `box_14_number` tinyint(1) UNSIGNED NOT NULL,
  `box_14_timestamp` datetime NOT NULL,
  `box_15_number` tinyint(1) UNSIGNED NOT NULL,
  `box_15_timestamp` datetime NOT NULL,
  `box_16_number` tinyint(1) UNSIGNED NOT NULL,
  `box_16_timestamp` datetime NOT NULL,
  `box_17_number` tinyint(1) UNSIGNED NOT NULL,
  `box_17_timestamp` datetime NOT NULL,
  `box_18_number` tinyint(1) UNSIGNED NOT NULL,
  `box_18_timestamp` datetime NOT NULL,
  `box_19_number` tinyint(1) UNSIGNED NOT NULL,
  `box_19_timestamp` datetime NOT NULL,
  `box_20_number` tinyint(1) UNSIGNED NOT NULL,
  `box_20_timestamp` datetime NOT NULL,
  `box_21_number` tinyint(1) UNSIGNED NOT NULL,
  `box_21_timestamp` datetime NOT NULL,
  `box_22_number` tinyint(1) UNSIGNED NOT NULL,
  `box_22_timestamp` datetime NOT NULL,
  `box_23_number` tinyint(1) UNSIGNED NOT NULL,
  `box_23_timestamp` datetime NOT NULL,
  `box_24_number` tinyint(1) UNSIGNED NOT NULL,
  `box_24_timestamp` datetime NOT NULL,
  `box_25_number` tinyint(1) NOT NULL,
  `box_25_timestamp` datetime NOT NULL,
  `flag_bonus` tinyint(1) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `grid_hash` varchar(255) NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `jeux_bingo_musical_morceaux`
--

CREATE TABLE `jeux_bingo_musical_morceaux` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_artiste` smallint(5) UNSIGNED NOT NULL,
  `id_style` tinyint(1) NOT NULL,
  `id_popularite` tinyint(1) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `lien_url_applemusic` varchar(255) NOT NULL,
  `lien_url_deezer` varchar(255) NOT NULL,
  `lien_url_qobuz` varchar(255) NOT NULL,
  `lien_url_spotify` varchar(255) NOT NULL,
  `lien_url_youtube` varchar(255) NOT NULL,
  `lien_url_mp3` varchar(255) NOT NULL,
  `duree` smallint(5) UNSIGNED NOT NULL,
  `video_parametre_start` int(10) UNSIGNED NOT NULL,
  `video_parametre_end` int(10) UNSIGNED NOT NULL,
  `flag_diffusion_internationale` tinyint(1) NOT NULL,
  `youtube_info_region_allowed` text NOT NULL,
  `youtube_info_region_blocked` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_creation_annee` smallint(5) UNSIGNED NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `jeux_bingo_musical_morceaux_to_playlists`
--

CREATE TABLE `jeux_bingo_musical_morceaux_to_playlists` (
  `id_morceau` mediumint(9) NOT NULL,
  `id_playlist` mediumint(9) NOT NULL,
  `position` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=FIXED;

-- --------------------------------------------------------

--
-- Structure de la table `jeux_bingo_musical_morceaux_to_playlists_clients`
--

CREATE TABLE `jeux_bingo_musical_morceaux_to_playlists_clients` (
  `id_morceau` mediumint(9) NOT NULL,
  `id_playlist_client` mediumint(9) NOT NULL,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `numero` tinyint(3) UNSIGNED NOT NULL,
  `flag_listening` tinyint(1) NOT NULL,
  `listening_timestamp` datetime(3) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=FIXED;

-- --------------------------------------------------------

--
-- Structure de la table `jeux_bingo_musical_playlists`
--

CREATE TABLE `jeux_bingo_musical_playlists` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_rubrique` smallint(5) UNSIGNED NOT NULL,
  `id_difficulte` tinyint(3) UNSIGNED NOT NULL,
  `id_client_auteur` smallint(5) NOT NULL,
  `nom_auteur` varchar(255) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url_applemusic` varchar(255) NOT NULL,
  `lien_url_deezer` varchar(255) NOT NULL,
  `lien_url_qobuz` varchar(255) NOT NULL,
  `lien_url_spotify` varchar(255) NOT NULL,
  `lien_url_youtubemusic` varchar(255) NOT NULL,
  `flag_caracteristique_international` tinyint(4) NOT NULL,
  `jour_associe_debut` char(5) NOT NULL,
  `jour_associe_fin` char(5) NOT NULL,
  `date_annee` smallint(5) NOT NULL,
  `online` tinyint(1) UNSIGNED ZEROFILL NOT NULL DEFAULT 1,
  `position` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `flag_begin` tinyint(1) NOT NULL,
  `flag_une` tinyint(4) NOT NULL,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `date_ajout` date NOT NULL,
  `date_maj` date NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `jeux_bingo_musical_playlists_clients`
--

CREATE TABLE `jeux_bingo_musical_playlists_clients` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_playlist` smallint(5) UNSIGNED NOT NULL,
  `id_client` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL DEFAULT '0',
  `id_jeu_bingo_musical_format` tinyint(1) UNSIGNED NOT NULL,
  `nb_grilles_support_papier` smallint(5) UNSIGNED NOT NULL,
  `nb_grilles_support_digital` smallint(5) UNSIGNED NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url_applemusic` varchar(255) NOT NULL,
  `lien_url_deezer` varchar(255) NOT NULL,
  `lien_url_qobuz` varchar(255) NOT NULL,
  `lien_url_spotify` varchar(255) NOT NULL,
  `lien_url_youtubemusic` varchar(255) NOT NULL,
  `ecoute_limite` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `flag_controle_numerique` tinyint(1) NOT NULL,
  `flag_modifiable` tinyint(1) NOT NULL,
  `phases_liste` varchar(255) NOT NULL DEFAULT '0,1,5',
  `phase_courante` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `morceau_courant` tinyint(1) UNSIGNED NOT NULL,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `date_ajout` date NOT NULL,
  `date_maj` date NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL,
  `online` tinyint(1) UNSIGNED ZEROFILL NOT NULL DEFAULT 1,
  `position` tinyint(3) UNSIGNED NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `jeux_bingo_musical_playlists_clients_logs`
--

CREATE TABLE `jeux_bingo_musical_playlists_clients_logs` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_playlist_client` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `a` varchar(255) NOT NULL,
  `id_log_type` tinyint(1) NOT NULL DEFAULT 1,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `date_ajout` datetime NOT NULL,
  `ip` varchar(15) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `jeux_bingo_musical_playlists_rubriques`
--

CREATE TABLE `jeux_bingo_musical_playlists_rubriques` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `learning_quizs_questions`
--

CREATE TABLE `learning_quizs_questions` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_quiz` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `id_image` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `question` text NOT NULL,
  `choix_1` varchar(255) NOT NULL,
  `choix_2` varchar(255) NOT NULL,
  `choix_3` varchar(255) NOT NULL,
  `numero_reponse` tinyint(1) UNSIGNED NOT NULL,
  `commentaire_reponse` text NOT NULL,
  `slug` varchar(255) NOT NULL,
  `meta_titre` varchar(255) NOT NULL,
  `meta_description` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(1) NOT NULL,
  `date_ajout` date NOT NULL,
  `date_maj` date NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `medias_audios`
--

CREATE TABLE `medias_audios` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `a` varchar(255) DEFAULT NULL,
  `u` varchar(255) DEFAULT NULL,
  `t` varchar(255) DEFAULT NULL,
  `m` varchar(255) DEFAULT NULL,
  `id_module` smallint(5) DEFAULT NULL,
  `nom` varchar(255) NOT NULL DEFAULT '0',
  `titre` varchar(255) NOT NULL DEFAULT '0',
  `descriptif_court` varchar(255) DEFAULT NULL,
  `descriptif_long` varchar(255) DEFAULT NULL,
  `credits` varchar(255) DEFAULT NULL,
  `extension` varchar(4) DEFAULT NULL,
  `poids_ko` smallint(5) UNSIGNED DEFAULT NULL,
  `online` tinyint(1) UNSIGNED DEFAULT NULL,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `medias_documents`
--

CREATE TABLE `medias_documents` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `a` varchar(255) DEFAULT NULL,
  `u` varchar(255) DEFAULT NULL,
  `t` varchar(255) DEFAULT NULL,
  `m` varchar(255) DEFAULT NULL,
  `id_module` smallint(5) DEFAULT NULL,
  `nom` varchar(255) NOT NULL,
  `titre` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `credits` varchar(255) DEFAULT NULL,
  `extension` varchar(4) DEFAULT NULL,
  `poids_ko` smallint(5) UNSIGNED DEFAULT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 1,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `medias_images`
--

CREATE TABLE `medias_images` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `a` varchar(255) DEFAULT NULL,
  `u` varchar(255) DEFAULT NULL,
  `t` varchar(255) DEFAULT NULL,
  `m` varchar(255) DEFAULT NULL,
  `id_module` smallint(5) DEFAULT NULL,
  `nom` varchar(255) NOT NULL DEFAULT '0',
  `titre` varchar(255) NOT NULL DEFAULT '0',
  `descriptif_court` varchar(255) DEFAULT NULL,
  `descriptif_long` varchar(255) DEFAULT NULL,
  `credits` varchar(255) DEFAULT NULL,
  `extension` varchar(4) DEFAULT NULL,
  `poids_ko` smallint(5) UNSIGNED DEFAULT NULL,
  `online` tinyint(1) UNSIGNED DEFAULT NULL,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `operations_evenements`
--

CREATE TABLE `operations_evenements` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_operation_evenement_rubrique` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `id_client` mediumint(9) UNSIGNED NOT NULL DEFAULT 0,
  `id_ecommerce_offre` smallint(5) UNSIGNED NOT NULL,
  `id_erp_jauge` tinyint(3) UNSIGNED NOT NULL,
  `nb_animation` tinyint(5) UNSIGNED NOT NULL,
  `nom_court` varchar(255) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `date_debut` datetime NOT NULL,
  `date_fin` datetime NOT NULL,
  `flag_produit_cotton_quiz` tinyint(1) UNSIGNED NOT NULL,
  `flag_produit_bingo_musical` tinyint(1) UNSIGNED NOT NULL,
  `flag_evenement_demo` tinyint(1) NOT NULL,
  `flag_evenement_prive` tinyint(1) UNSIGNED NOT NULL,
  `flag_connexion_joueur_pseudo` tinyint(1) NOT NULL,
  `naming_lieu` varchar(255) NOT NULL,
  `naming_adresse` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `code_operation_evenement` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `questions`
--

CREATE TABLE `questions` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_client_auteur` smallint(5) NOT NULL,
  `nom_auteur` varchar(255) NOT NULL,
  `id_equipe_joueur` mediumint(8) UNSIGNED NOT NULL,
  `id_etat` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `id_univers` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `id_rubrique` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `id_lot` mediumint(8) UNSIGNED NOT NULL,
  `id_theme` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `id_type` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `id_type_support` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `lien_support` varchar(255) NOT NULL,
  `flag_support_indispensable` tinyint(1) NOT NULL,
  `id_type_support_reponse` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `lien_support_reponse` varchar(255) NOT NULL,
  `id_points` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `serie_1` tinyint(1) UNSIGNED NOT NULL,
  `serie_2` tinyint(1) UNSIGNED NOT NULL,
  `serie_3` tinyint(1) UNSIGNED NOT NULL,
  `serie_4` tinyint(1) UNSIGNED NOT NULL,
  `introduction` text NOT NULL,
  `question` text NOT NULL,
  `propositions` text NOT NULL,
  `reponse` text NOT NULL,
  `conclusion` text NOT NULL,
  `commentaire` text NOT NULL,
  `jour_associe` char(5) NOT NULL,
  `jour_associe_v1` char(5) NOT NULL,
  `date_fin_validite` date NOT NULL,
  `difficulte` tinyint(4) NOT NULL,
  `flag_droits` tinyint(1) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(1) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `questions_bonus`
--

CREATE TABLE `questions_bonus` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_equipe_joueur` mediumint(8) UNSIGNED NOT NULL,
  `id_etat` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `indice_0` varchar(255) NOT NULL,
  `indice_1` varchar(255) NOT NULL,
  `indice_2` varchar(255) NOT NULL,
  `indice_3` varchar(255) NOT NULL,
  `indice_4` varchar(255) NOT NULL,
  `reponse` text NOT NULL,
  `online` tinyint(1) NOT NULL,
  `commentaire` text NOT NULL,
  `date_ajout` date NOT NULL,
  `date_maj` date NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `questions_bonus_to_tags`
--

CREATE TABLE `questions_bonus_to_tags` (
  `id_question` mediumint(9) NOT NULL,
  `id_tag` mediumint(9) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `questions_feedback`
--

CREATE TABLE `questions_feedback` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_client` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `id_question` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `flag_feedback_plus` tinyint(1) UNSIGNED NOT NULL,
  `flag_feedback_moins` tinyint(1) UNSIGNED NOT NULL,
  `id_reload_type` tinyint(1) UNSIGNED NOT NULL,
  `online` tinyint(1) UNSIGNED NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `questions_lots`
--

CREATE TABLE `questions_lots` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_client_auteur` smallint(5) NOT NULL,
  `nom_auteur` varchar(255) NOT NULL,
  `id_equipe_joueur` mediumint(8) UNSIGNED NOT NULL,
  `id_etat` tinyint(3) UNSIGNED NOT NULL,
  `id_univers` tinyint(3) UNSIGNED NOT NULL,
  `id_rubrique` tinyint(3) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `difficulte` tinyint(4) UNSIGNED NOT NULL,
  `jour_associe_debut` char(5) NOT NULL,
  `jour_associe_fin` char(5) NOT NULL,
  `date_annee` smallint(5) UNSIGNED DEFAULT NULL,
  `flag_generateur` tinyint(1) NOT NULL,
  `flag_begin` tinyint(1) NOT NULL,
  `flag_droits` tinyint(1) NOT NULL,
  `flag_une` tinyint(1) NOT NULL,
  `commentaire` text NOT NULL,
  `online` tinyint(1) NOT NULL,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `date_ajout` date NOT NULL,
  `date_maj` date NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `questions_lots_rubriques`
--

CREATE TABLE `questions_lots_rubriques` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_univers` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `nom` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `date_ajout` date NOT NULL,
  `date_maj` date NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `questions_lots_temp`
--

CREATE TABLE `questions_lots_temp` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `question_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '[]',
  `date_ajout` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `questions_lots_to_tags`
--

CREATE TABLE `questions_lots_to_tags` (
  `id_lot` mediumint(9) NOT NULL,
  `id_tag` mediumint(9) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=FIXED;

-- --------------------------------------------------------

--
-- Structure de la table `questions_lots_univers`
--

CREATE TABLE `questions_lots_univers` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `date_ajout` date NOT NULL,
  `date_maj` date NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `questions_propositions`
--

CREATE TABLE `questions_propositions` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `question_id` mediumint(8) UNSIGNED NOT NULL,
  `proposition_text` text NOT NULL,
  `ordre` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `questions_rubriques`
--

CREATE TABLE `questions_rubriques` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_univers` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `nom` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `date_ajout` date NOT NULL,
  `date_maj` date NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `questions_tags`
--

CREATE TABLE `questions_tags` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_image` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `date_ajout` date NOT NULL,
  `date_maj` date NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `questions_to_tags`
--

CREATE TABLE `questions_to_tags` (
  `id_question` mediumint(9) NOT NULL,
  `id_tag` mediumint(9) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `questions_univers`
--

CREATE TABLE `questions_univers` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `date_ajout` date NOT NULL,
  `date_maj` date NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `quizs`
--

CREATE TABLE `quizs` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_client` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `id_lot` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `id_bonus` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `id_origine` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `date` date NOT NULL,
  `flag_controle_numerique` tinyint(1) NOT NULL,
  `flag_lot_modifiable` tinyint(1) NOT NULL,
  `date_ajout` date NOT NULL,
  `date_maj` date NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL,
  `online` tinyint(1) UNSIGNED ZEROFILL NOT NULL DEFAULT 1,
  `client_note` tinyint(1) UNSIGNED DEFAULT NULL,
  `client_feedback` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `quizs_series`
--

CREATE TABLE `quizs_series` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_quiz` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `id_lot` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `nom` varchar(255) NOT NULL,
  `numero` tinyint(3) UNSIGNED NOT NULL,
  `online` tinyint(1) NOT NULL,
  `date_ajout` date NOT NULL,
  `date_maj` date NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `quizs_series_to_questions`
--

CREATE TABLE `quizs_series_to_questions` (
  `id_serie` mediumint(9) UNSIGNED NOT NULL,
  `id_question` mediumint(9) UNSIGNED NOT NULL,
  `numero` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_bingo_musical_playlists_clients_logs_types`
--

CREATE TABLE `referentiels_bingo_musical_playlists_clients_logs_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_branding_types`
--

CREATE TABLE `referentiels_branding_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `seo_slug` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_clients_acquisitions_canaux`
--

CREATE TABLE `referentiels_clients_acquisitions_canaux` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_clients_contacts_types`
--

CREATE TABLE `referentiels_clients_contacts_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_clients_erp_jauges`
--

CREATE TABLE `referentiels_clients_erp_jauges` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `nb_joueurs_max` smallint(5) UNSIGNED NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_clients_etats`
--

CREATE TABLE `referentiels_clients_etats` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_clients_pipeline_etats`
--

CREATE TABLE `referentiels_clients_pipeline_etats` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_clients_reservations`
--

CREATE TABLE `referentiels_clients_reservations` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_clients_solution_usages`
--

CREATE TABLE `referentiels_clients_solution_usages` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_clients_types`
--

CREATE TABLE `referentiels_clients_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_clients_typologies`
--

CREATE TABLE `referentiels_clients_typologies` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_solution_usage` smallint(5) NOT NULL,
  `id_type` smallint(5) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `nom_court` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_commandes_etats`
--

CREATE TABLE `referentiels_commandes_etats` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_commercial_actions_types`
--

CREATE TABLE `referentiels_commercial_actions_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_emails_transactionnels`
--

CREATE TABLE `referentiels_emails_transactionnels` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_email_transactionnel_template` smallint(5) UNSIGNED NOT NULL,
  `id_pipeline_etat` tinyint(2) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_equipes_joueurs_types`
--

CREATE TABLE `referentiels_equipes_joueurs_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_formules_etats`
--

CREATE TABLE `referentiels_formules_etats` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_logs_types`
--

CREATE TABLE `referentiels_logs_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_morceaux_popularites`
--

CREATE TABLE `referentiels_morceaux_popularites` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_morceaux_styles`
--

CREATE TABLE `referentiels_morceaux_styles` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_offres_clients_etats`
--

CREATE TABLE `referentiels_offres_clients_etats` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_offres_types`
--

CREATE TABLE `referentiels_offres_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_paiements_frequences`
--

CREATE TABLE `referentiels_paiements_frequences` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_paiements_modes`
--

CREATE TABLE `referentiels_paiements_modes` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_paiements_types`
--

CREATE TABLE `referentiels_paiements_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_playlists_difficultes`
--

CREATE TABLE `referentiels_playlists_difficultes` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_produits_quiz_frequences`
--

CREATE TABLE `referentiels_produits_quiz_frequences` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_produits_types`
--

CREATE TABLE `referentiels_produits_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_questions_feedback_reload_types`
--

CREATE TABLE `referentiels_questions_feedback_reload_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_remises_types`
--

CREATE TABLE `referentiels_remises_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_sessions_evenements`
--

CREATE TABLE `referentiels_sessions_evenements` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_sous_domaines`
--

CREATE TABLE `referentiels_sous_domaines` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_utilisateurs_types`
--

CREATE TABLE `referentiels_utilisateurs_types` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_zones_departements`
--

CREATE TABLE `referentiels_zones_departements` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_zone_pays` smallint(5) NOT NULL,
  `code` varchar(5) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `referentiels_zones_pays`
--

CREATE TABLE `referentiels_zones_pays` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `code` varchar(5) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `reporting_games_demos_detail`
--

CREATE TABLE `reporting_games_demos_detail` (
  `month_key` varchar(7) NOT NULL,
  `session_id` varchar(64) NOT NULL,
  `session_date` datetime NOT NULL,
  `id_client` int(11) NOT NULL,
  `id_type_produit` int(11) NOT NULL,
  `players_count` int(11) NOT NULL DEFAULT 0,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `reporting_games_players_by_type_monthly`
--

CREATE TABLE `reporting_games_players_by_type_monthly` (
  `month_key` char(7) NOT NULL,
  `id_client` int(11) NOT NULL,
  `type_group` varchar(20) NOT NULL,
  `players` int(11) NOT NULL DEFAULT 0,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `reporting_games_players_monthly`
--

CREATE TABLE `reporting_games_players_monthly` (
  `month_key` char(7) NOT NULL,
  `id_client` int(11) NOT NULL,
  `players` int(11) NOT NULL DEFAULT 0,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `reporting_games_sessions_detail`
--

CREATE TABLE `reporting_games_sessions_detail` (
  `month_key` varchar(7) NOT NULL,
  `session_id` varchar(64) NOT NULL,
  `session_date` datetime NOT NULL,
  `id_client` int(11) NOT NULL,
  `id_type_produit` int(11) NOT NULL,
  `players_count` int(11) NOT NULL DEFAULT 0,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `reporting_games_sessions_monthly`
--

CREATE TABLE `reporting_games_sessions_monthly` (
  `month_key` char(7) NOT NULL,
  `id_client` int(11) NOT NULL,
  `type_group` varchar(20) NOT NULL,
  `sessions` int(11) NOT NULL DEFAULT 0,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `reporting_shares`
--

CREATE TABLE `reporting_shares` (
  `id` int(10) UNSIGNED NOT NULL,
  `token` varchar(128) NOT NULL,
  `created_at` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `scope` varchar(32) NOT NULL DEFAULT 'reporting',
  `payload_json` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `support_conseils`
--

CREATE TABLE `support_conseils` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `domaine` varchar(255) DEFAULT NULL,
  `id_sous_domaine` tinyint(1) DEFAULT NULL,
  `id_type_produit` tinyint(1) DEFAULT NULL,
  `a` varchar(255) DEFAULT NULL,
  `u` varchar(255) DEFAULT NULL,
  `t` varchar(255) DEFAULT NULL,
  `m` varchar(255) DEFAULT NULL,
  `zoning_code` varchar(255) DEFAULT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` varchar(255) DEFAULT NULL,
  `descriptif_long` text DEFAULT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(3) DEFAULT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `commentaire` text NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `support_contacts`
--

CREATE TABLE `support_contacts` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `domaine` varchar(255) DEFAULT NULL,
  `id_sous_domaine` tinyint(1) DEFAULT NULL,
  `id_type_produit` tinyint(1) DEFAULT NULL,
  `a` varchar(255) DEFAULT NULL,
  `u` varchar(255) DEFAULT NULL,
  `t` varchar(255) DEFAULT NULL,
  `m` varchar(255) DEFAULT NULL,
  `zoning_code` varchar(255) DEFAULT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` varchar(255) DEFAULT NULL,
  `descriptif_long` text DEFAULT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(3) DEFAULT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `commentaire` text NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `support_faq`
--

CREATE TABLE `support_faq` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `domaine` varchar(255) DEFAULT NULL,
  `id_sous_domaine` tinyint(1) DEFAULT NULL,
  `id_type_produit` tinyint(1) DEFAULT NULL,
  `a` varchar(255) DEFAULT NULL,
  `u` varchar(255) DEFAULT NULL,
  `t` varchar(255) DEFAULT NULL,
  `m` varchar(255) DEFAULT NULL,
  `zoning_code` varchar(255) DEFAULT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` varchar(255) DEFAULT NULL,
  `descriptif_long` text DEFAULT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(3) DEFAULT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `commentaire` text NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `support_installations`
--

CREATE TABLE `support_installations` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `domaine` varchar(255) DEFAULT NULL,
  `id_sous_domaine` tinyint(1) DEFAULT NULL,
  `id_type_produit` tinyint(1) DEFAULT NULL,
  `a` varchar(255) DEFAULT NULL,
  `u` varchar(255) DEFAULT NULL,
  `t` varchar(255) DEFAULT NULL,
  `m` varchar(255) DEFAULT NULL,
  `zoning_code` varchar(255) DEFAULT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` varchar(255) DEFAULT NULL,
  `descriptif_long` text DEFAULT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(3) DEFAULT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `commentaire` text NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `support_regles`
--

CREATE TABLE `support_regles` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `domaine` varchar(255) DEFAULT NULL,
  `id_sous_domaine` tinyint(1) DEFAULT NULL,
  `id_type_produit` tinyint(1) DEFAULT NULL,
  `a` varchar(255) DEFAULT NULL,
  `u` varchar(255) DEFAULT NULL,
  `t` varchar(255) DEFAULT NULL,
  `m` varchar(255) DEFAULT NULL,
  `zoning_code` varchar(255) DEFAULT NULL,
  `nom` varchar(255) NOT NULL,
  `descriptif_court` varchar(255) DEFAULT NULL,
  `descriptif_long` text DEFAULT NULL,
  `online` tinyint(1) NOT NULL,
  `position` tinyint(3) DEFAULT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `commentaire` text NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `x-archive-bingos-2025-02`
--

CREATE TABLE `x-archive-bingos-2025-02` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL DEFAULT '0',
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url_applemusic` varchar(255) NOT NULL,
  `lien_url_deezer` varchar(255) NOT NULL,
  `lien_url_qobuz` varchar(255) NOT NULL,
  `lien_url_spotify` varchar(255) NOT NULL,
  `lien_url_youtubemusic` varchar(255) NOT NULL,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `date_ajout` date NOT NULL,
  `date_maj` date NOT NULL,
  `id_securite` varchar(255) NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL,
  `online` tinyint(1) UNSIGNED ZEROFILL NOT NULL DEFAULT 1,
  `position` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `tmp_nb_cartes` smallint(5) UNSIGNED NOT NULL DEFAULT 1,
  `tmp_date` varchar(255) NOT NULL,
  `tmp_nom_etablissement` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `x-archive-equipes-2020-03`
--

CREATE TABLE `x-archive-equipes-2020-03` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `id_client` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `nom` varchar(255) NOT NULL,
  `nom_court` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `x-archive-joueurs-2020-03`
--

CREATE TABLE `x-archive-joueurs-2020-03` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `id_equipe` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `email` varchar(255) NOT NULL,
  `pwd` varchar(255) NOT NULL,
  `pwd_token` varchar(23) NOT NULL,
  `pwd_token_date` datetime NOT NULL,
  `code_langue` char(2) NOT NULL,
  `civilite` tinyint(4) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `adresse` varchar(255) NOT NULL,
  `adresse_2` varchar(255) NOT NULL,
  `cp` varchar(255) NOT NULL,
  `ville` varchar(255) NOT NULL,
  `pays` varchar(255) NOT NULL,
  `code_pays` char(2) NOT NULL,
  `tel` varchar(255) NOT NULL,
  `fax` varchar(255) NOT NULL,
  `equipe` varchar(255) NOT NULL,
  `lien_url_fb` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `commentaire` text NOT NULL,
  `ip` varchar(15) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `x-archive-morceaux-2025-02`
--

CREATE TABLE `x-archive-morceaux-2025-02` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `nom_artiste` varchar(255) NOT NULL,
  `nom_morceau` varchar(255) NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `x-archive-morceaux_to_bingos-2025-02`
--

CREATE TABLE `x-archive-morceaux_to_bingos-2025-02` (
  `id_morceau` mediumint(9) NOT NULL,
  `id_bingo` mediumint(9) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=FIXED;

-- --------------------------------------------------------

--
-- Structure de la table `x-archive-resultats-2020-03`
--

CREATE TABLE `x-archive-resultats-2020-03` (
  `id` int(10) UNSIGNED NOT NULL,
  `id_championnats_session` smallint(5) UNSIGNED NOT NULL,
  `id_equipe` smallint(5) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `nom_court` varchar(255) NOT NULL,
  `descriptif_court` text NOT NULL,
  `descriptif_long` text NOT NULL,
  `equipe_session_points` smallint(5) UNSIGNED NOT NULL,
  `equipe_quiz_points` smallint(5) UNSIGNED NOT NULL,
  `lien_url` varchar(255) NOT NULL,
  `lien_libelle` varchar(255) NOT NULL,
  `lien_target` tinyint(1) NOT NULL DEFAULT 0,
  `video_code` varchar(255) NOT NULL,
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `position` tinyint(3) UNSIGNED NOT NULL,
  `flag_une` tinyint(1) NOT NULL DEFAULT 0,
  `seo_slug` varchar(255) NOT NULL,
  `seo_meta_title` varchar(255) NOT NULL,
  `seo_meta_description` varchar(255) NOT NULL,
  `design_icone` varchar(255) NOT NULL,
  `design_css_class` varchar(255) NOT NULL,
  `date_ajout` datetime NOT NULL,
  `date_maj` datetime NOT NULL,
  `id_user_ajout` tinyint(3) UNSIGNED NOT NULL,
  `id_user_maj` tinyint(3) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `ai_pilot_agents`
--
ALTER TABLE `ai_pilot_agents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tenant_agent_idx` (`tenant_id`,`name`);

--
-- Index pour la table `ai_pilot_api_usage`
--
ALTER TABLE `ai_pilot_api_usage`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tenant_service_idx` (`tenant_id`,`service_id`),
  ADD KEY `content_idx` (`content_id`),
  ADD KEY `fk_api_usage_service` (`service_id`);

--
-- Index pour la table `ai_pilot_client_preferences`
--
ALTER TABLE `ai_pilot_client_preferences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tenant_client_unique` (`tenant_id`,`client_id`);

--
-- Index pour la table `ai_pilot_generated_contents`
--
ALTER TABLE `ai_pilot_generated_contents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tenant_agent_idx` (`tenant_agent_id`),
  ADD KEY `status_idx` (`status`),
  ADD KEY `scheduled_idx` (`scheduled_at`),
  ADD KEY `fk_content_platform` (`platform_id`);

--
-- Index pour la table `ai_pilot_ia_services`
--
ALTER TABLE `ai_pilot_ia_services`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `service_name_unique` (`name`);

--
-- Index pour la table `ai_pilot_media_assets`
--
ALTER TABLE `ai_pilot_media_assets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `content_media_idx` (`content_id`);

--
-- Index pour la table `ai_pilot_platforms`
--
ALTER TABLE `ai_pilot_platforms`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `platform_name_unique` (`name`);

--
-- Index pour la table `ai_pilot_scheduled_tasks`
--
ALTER TABLE `ai_pilot_scheduled_tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tenant_agent_idx` (`tenant_agent_id`),
  ADD KEY `schedule_idx` (`day_of_week`,`hour`,`is_active`),
  ADD KEY `fk_task_platform` (`platform_id`);

--
-- Index pour la table `ai_pilot_system_logs`
--
ALTER TABLE `ai_pilot_system_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tenant_level_idx` (`tenant_id`,`level`,`created_at`);

--
-- Index pour la table `ai_pilot_tenants`
--
ALTER TABLE `ai_pilot_tenants`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug_unique` (`slug`);

--
-- Index pour la table `ai_pilot_tenant_agents`
--
ALTER TABLE `ai_pilot_tenant_agents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tenant_agent_unique` (`tenant_id`,`agent_id`),
  ADD KEY `fk_tenant_agent_agent` (`agent_id`);

--
-- Index pour la table `ai_pilot_tenant_agent_configs`
--
ALTER TABLE `ai_pilot_tenant_agent_configs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tenant_agent_platform_key` (`tenant_agent_id`,`platform_id`,`config_key`),
  ADD KEY `fk_config_platform` (`platform_id`);

--
-- Index pour la table `bingo_players`
--
ALTER TABLE `bingo_players`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `bingo_phase_winners`
--
ALTER TABLE `bingo_phase_winners`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_session_phase` (`session_id`,`phase`),
  ADD UNIQUE KEY `uniq_event_id` (`event_id`);

--
-- Index pour la table `blindtest_players`
--
ALTER TABLE `blindtest_players`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `blindtest_sessions`
--
ALTER TABLE `blindtest_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_id` (`session_id`);

--
-- Index pour la table `championnats_contributions_points`
--
ALTER TABLE `championnats_contributions_points`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `championnats_resultats`
--
ALTER TABLE `championnats_resultats`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `championnats_saisons`
--
ALTER TABLE `championnats_saisons`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `championnats_sessions`
--
ALTER TABLE `championnats_sessions`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `championnats_sessions_lots`
--
ALTER TABLE `championnats_sessions_lots`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `championnats_sessions_lots_to_entites_joueurs`
--
ALTER TABLE `championnats_sessions_lots_to_entites_joueurs`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `clients_branding`
--
ALTER TABLE `clients_branding`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_client` (`id_client`),
  ADD KEY `id_operation_evenement` (`id_operation_evenement`);

--
-- Index pour la table `clients_contacts`
--
ALTER TABLE `clients_contacts`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `clients_emails_transactionnels_logs`
--
ALTER TABLE `clients_emails_transactionnels_logs`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `clients_logs`
--
ALTER TABLE `clients_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_client` (`id_client`);

--
-- Index pour la table `clients_logs_onboarding`
--
ALTER TABLE `clients_logs_onboarding`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `clients_logs_utm`
--
ALTER TABLE `clients_logs_utm`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `contrainte_tuple` (`session_id`);

--
-- Index pour la table `clients_temoignages`
--
ALTER TABLE `clients_temoignages`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `communication_actualites`
--
ALTER TABLE `communication_actualites`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `communication_actualites_rubriques`
--
ALTER TABLE `communication_actualites_rubriques`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `communication_focus`
--
ALTER TABLE `communication_focus`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `communication_slides`
--
ALTER TABLE `communication_slides`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `cotton_quiz_players`
--
ALTER TABLE `cotton_quiz_players`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `cotton_quiz_sessions`
--
ALTER TABLE `cotton_quiz_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `session_id` (`session_id`);

--
-- Index pour la table `crm_abonnes`
--
ALTER TABLE `crm_abonnes`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `crm_contacts`
--
ALTER TABLE `crm_contacts`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `crm_parrainages`
--
ALTER TABLE `crm_parrainages`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `ecommerce_commandes`
--
ALTER TABLE `ecommerce_commandes`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `ecommerce_commandes_lignes`
--
ALTER TABLE `ecommerce_commandes_lignes`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `ecommerce_formules`
--
ALTER TABLE `ecommerce_formules`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `ecommerce_formules_declinaisons`
--
ALTER TABLE `ecommerce_formules_declinaisons`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `ecommerce_formules_declinaisons_to_clients`
--
ALTER TABLE `ecommerce_formules_declinaisons_to_clients`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `ecommerce_offres`
--
ALTER TABLE `ecommerce_offres`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `ecommerce_offres_paniers`
--
ALTER TABLE `ecommerce_offres_paniers`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `ecommerce_offres_to_clients`
--
ALTER TABLE `ecommerce_offres_to_clients`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `ecommerce_produits_types`
--
ALTER TABLE `ecommerce_produits_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `ecommerce_remises`
--
ALTER TABLE `ecommerce_remises`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `ecommerce_remises_clients`
--
ALTER TABLE `ecommerce_remises_clients`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `ecommerce_remises_to_offres`
--
ALTER TABLE `ecommerce_remises_to_offres`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `ecommerce_remises_to_offres_clients`
--
ALTER TABLE `ecommerce_remises_to_offres_clients`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `entites_joueurs_emails_transactionnels_logs`
--
ALTER TABLE `entites_joueurs_emails_transactionnels_logs`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `entites_joueurs_logs`
--
ALTER TABLE `entites_joueurs_logs`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `entites_utilisateurs`
--
ALTER TABLE `entites_utilisateurs`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `entites_utilisateurs_logs`
--
ALTER TABLE `entites_utilisateurs_logs`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `equipes`
--
ALTER TABLE `equipes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nom` (`nom`);

--
-- Index pour la table `equipes_joueurs`
--
ALTER TABLE `equipes_joueurs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nom` (`email`);

--
-- Index pour la table `equipes_logs`
--
ALTER TABLE `equipes_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_joueur` (`id_equipe`);

--
-- Index pour la table `equipes_to_championnats_sessions`
--
ALTER TABLE `equipes_to_championnats_sessions`
  ADD PRIMARY KEY (`id_equipe`,`id_championnat_session`);

--
-- Index pour la table `game_events`
--
ALTER TABLE `game_events`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_event_id` (`event_id`),
  ADD KEY `idx_game_action_created` (`game`,`action`,`created_at`),
  ADD KEY `idx_session_id` (`session_id`),
  ADD KEY `idx_player_id` (`player_id`);

--
-- Index pour la table `general_branding`
--
ALTER TABLE `general_branding`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_branding_type` (`id_type_branding`),
  ADD KEY `id_related` (`id_related`);

--
-- Index pour la table `general_parametres`
--
ALTER TABLE `general_parametres`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `general_univers`
--
ALTER TABLE `general_univers`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `jeux_bingo_musical_artistes`
--
ALTER TABLE `jeux_bingo_musical_artistes`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `jeux_bingo_musical_grids`
--
ALTER TABLE `jeux_bingo_musical_grids`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `jeux_bingo_musical_grids_clients`
--
ALTER TABLE `jeux_bingo_musical_grids_clients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `index_id_playlist_client` (`id_playlist_client`),
  ADD KEY `idx_playlist_support_player` (`id_playlist_client`,`id_grid_support`,`id_joueur`,`id`);

--
-- Index pour la table `jeux_bingo_musical_morceaux`
--
ALTER TABLE `jeux_bingo_musical_morceaux`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `jeux_bingo_musical_playlists`
--
ALTER TABLE `jeux_bingo_musical_playlists`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `jeux_bingo_musical_playlists_clients`
--
ALTER TABLE `jeux_bingo_musical_playlists_clients`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `jeux_bingo_musical_playlists_clients_logs`
--
ALTER TABLE `jeux_bingo_musical_playlists_clients_logs`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `jeux_bingo_musical_playlists_rubriques`
--
ALTER TABLE `jeux_bingo_musical_playlists_rubriques`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `medias_audios`
--
ALTER TABLE `medias_audios`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `medias_documents`
--
ALTER TABLE `medias_documents`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `medias_images`
--
ALTER TABLE `medias_images`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `operations_evenements`
--
ALTER TABLE `operations_evenements`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_lot` (`id_lot`),
  ADD KEY `id_theme` (`id_theme`),
  ADD KEY `id_joueur` (`id_equipe_joueur`);

--
-- Index pour la table `questions_bonus`
--
ALTER TABLE `questions_bonus`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_joueur` (`id_equipe_joueur`);

--
-- Index pour la table `questions_bonus_to_tags`
--
ALTER TABLE `questions_bonus_to_tags`
  ADD PRIMARY KEY (`id_question`,`id_tag`);

--
-- Index pour la table `questions_feedback`
--
ALTER TABLE `questions_feedback`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_client` (`id_client`);

--
-- Index pour la table `questions_lots`
--
ALTER TABLE `questions_lots`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `questions_lots_rubriques`
--
ALTER TABLE `questions_lots_rubriques`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_univers` (`id_univers`);

--
-- Index pour la table `questions_lots_temp`
--
ALTER TABLE `questions_lots_temp`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `questions_lots_to_tags`
--
ALTER TABLE `questions_lots_to_tags`
  ADD PRIMARY KEY (`id_lot`,`id_tag`);

--
-- Index pour la table `questions_lots_univers`
--
ALTER TABLE `questions_lots_univers`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `questions_propositions`
--
ALTER TABLE `questions_propositions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_question_id` (`question_id`);

--
-- Index pour la table `questions_rubriques`
--
ALTER TABLE `questions_rubriques`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_univers` (`id_univers`);

--
-- Index pour la table `questions_tags`
--
ALTER TABLE `questions_tags`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `questions_to_tags`
--
ALTER TABLE `questions_to_tags`
  ADD PRIMARY KEY (`id_question`,`id_tag`);

--
-- Index pour la table `questions_univers`
--
ALTER TABLE `questions_univers`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `quizs`
--
ALTER TABLE `quizs`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `quizs_series`
--
ALTER TABLE `quizs_series`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_quiz` (`id_quiz`);

--
-- Index pour la table `quizs_series_to_questions`
--
ALTER TABLE `quizs_series_to_questions`
  ADD PRIMARY KEY (`id_serie`,`id_question`);

--
-- Index pour la table `referentiels_bingo_musical_playlists_clients_logs_types`
--
ALTER TABLE `referentiels_bingo_musical_playlists_clients_logs_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_branding_types`
--
ALTER TABLE `referentiels_branding_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_clients_acquisitions_canaux`
--
ALTER TABLE `referentiels_clients_acquisitions_canaux`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_clients_contacts_types`
--
ALTER TABLE `referentiels_clients_contacts_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_clients_erp_jauges`
--
ALTER TABLE `referentiels_clients_erp_jauges`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_clients_etats`
--
ALTER TABLE `referentiels_clients_etats`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_clients_pipeline_etats`
--
ALTER TABLE `referentiels_clients_pipeline_etats`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_clients_reservations`
--
ALTER TABLE `referentiels_clients_reservations`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_clients_solution_usages`
--
ALTER TABLE `referentiels_clients_solution_usages`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_clients_types`
--
ALTER TABLE `referentiels_clients_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_clients_typologies`
--
ALTER TABLE `referentiels_clients_typologies`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_commandes_etats`
--
ALTER TABLE `referentiels_commandes_etats`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_commercial_actions_types`
--
ALTER TABLE `referentiels_commercial_actions_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_emails_transactionnels`
--
ALTER TABLE `referentiels_emails_transactionnels`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_equipes_joueurs_types`
--
ALTER TABLE `referentiels_equipes_joueurs_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_formules_etats`
--
ALTER TABLE `referentiels_formules_etats`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_logs_types`
--
ALTER TABLE `referentiels_logs_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_morceaux_popularites`
--
ALTER TABLE `referentiels_morceaux_popularites`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_morceaux_styles`
--
ALTER TABLE `referentiels_morceaux_styles`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_offres_clients_etats`
--
ALTER TABLE `referentiels_offres_clients_etats`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_offres_types`
--
ALTER TABLE `referentiels_offres_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_paiements_frequences`
--
ALTER TABLE `referentiels_paiements_frequences`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_paiements_modes`
--
ALTER TABLE `referentiels_paiements_modes`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_paiements_types`
--
ALTER TABLE `referentiels_paiements_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_playlists_difficultes`
--
ALTER TABLE `referentiels_playlists_difficultes`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_produits_quiz_frequences`
--
ALTER TABLE `referentiels_produits_quiz_frequences`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_produits_types`
--
ALTER TABLE `referentiels_produits_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_questions_feedback_reload_types`
--
ALTER TABLE `referentiels_questions_feedback_reload_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_remises_types`
--
ALTER TABLE `referentiels_remises_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_sessions_evenements`
--
ALTER TABLE `referentiels_sessions_evenements`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_sous_domaines`
--
ALTER TABLE `referentiels_sous_domaines`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_utilisateurs_types`
--
ALTER TABLE `referentiels_utilisateurs_types`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_zones_departements`
--
ALTER TABLE `referentiels_zones_departements`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `referentiels_zones_pays`
--
ALTER TABLE `referentiels_zones_pays`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `reporting_games_demos_detail`
--
ALTER TABLE `reporting_games_demos_detail`
  ADD UNIQUE KEY `uniq_session_id` (`session_id`),
  ADD KEY `idx_month_client` (`month_key`,`id_client`),
  ADD KEY `idx_month_type` (`month_key`,`id_type_produit`),
  ADD KEY `idx_month_date` (`month_key`,`session_date`);

--
-- Index pour la table `reporting_games_players_by_type_monthly`
--
ALTER TABLE `reporting_games_players_by_type_monthly`
  ADD PRIMARY KEY (`month_key`,`id_client`,`type_group`),
  ADD KEY `idx_month_key` (`month_key`),
  ADD KEY `idx_id_client` (`id_client`);

--
-- Index pour la table `reporting_games_players_monthly`
--
ALTER TABLE `reporting_games_players_monthly`
  ADD PRIMARY KEY (`month_key`,`id_client`),
  ADD KEY `idx_month_key` (`month_key`),
  ADD KEY `idx_id_client` (`id_client`);

--
-- Index pour la table `reporting_games_sessions_detail`
--
ALTER TABLE `reporting_games_sessions_detail`
  ADD UNIQUE KEY `uniq_session_id` (`session_id`),
  ADD KEY `idx_month_client` (`month_key`,`id_client`),
  ADD KEY `idx_month_type` (`month_key`,`id_type_produit`),
  ADD KEY `idx_month_date` (`month_key`,`session_date`);

--
-- Index pour la table `reporting_games_sessions_monthly`
--
ALTER TABLE `reporting_games_sessions_monthly`
  ADD PRIMARY KEY (`month_key`,`id_client`,`type_group`),
  ADD KEY `idx_month_key` (`month_key`),
  ADD KEY `idx_id_client` (`id_client`);

--
-- Index pour la table `reporting_shares`
--
ALTER TABLE `reporting_shares`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_token` (`token`),
  ADD KEY `idx_expires` (`expires_at`),
  ADD KEY `idx_scope` (`scope`);

--
-- Index pour la table `support_conseils`
--
ALTER TABLE `support_conseils`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `support_contacts`
--
ALTER TABLE `support_contacts`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `support_faq`
--
ALTER TABLE `support_faq`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `support_installations`
--
ALTER TABLE `support_installations`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `support_regles`
--
ALTER TABLE `support_regles`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `x-archive-bingos-2025-02`
--
ALTER TABLE `x-archive-bingos-2025-02`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `x-archive-equipes-2020-03`
--
ALTER TABLE `x-archive-equipes-2020-03`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `x-archive-joueurs-2020-03`
--
ALTER TABLE `x-archive-joueurs-2020-03`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nom` (`email`),
  ADD KEY `id_equipe` (`id_equipe`);

--
-- Index pour la table `x-archive-morceaux-2025-02`
--
ALTER TABLE `x-archive-morceaux-2025-02`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `x-archive-resultats-2020-03`
--
ALTER TABLE `x-archive-resultats-2020-03`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `ai_pilot_agents`
--
ALTER TABLE `ai_pilot_agents`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ai_pilot_api_usage`
--
ALTER TABLE `ai_pilot_api_usage`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ai_pilot_client_preferences`
--
ALTER TABLE `ai_pilot_client_preferences`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ai_pilot_generated_contents`
--
ALTER TABLE `ai_pilot_generated_contents`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ai_pilot_ia_services`
--
ALTER TABLE `ai_pilot_ia_services`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ai_pilot_media_assets`
--
ALTER TABLE `ai_pilot_media_assets`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ai_pilot_platforms`
--
ALTER TABLE `ai_pilot_platforms`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ai_pilot_scheduled_tasks`
--
ALTER TABLE `ai_pilot_scheduled_tasks`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ai_pilot_system_logs`
--
ALTER TABLE `ai_pilot_system_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ai_pilot_tenants`
--
ALTER TABLE `ai_pilot_tenants`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ai_pilot_tenant_agents`
--
ALTER TABLE `ai_pilot_tenant_agents`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ai_pilot_tenant_agent_configs`
--
ALTER TABLE `ai_pilot_tenant_agent_configs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `bingo_players`
--
ALTER TABLE `bingo_players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `bingo_phase_winners`
--
ALTER TABLE `bingo_phase_winners`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `blindtest_players`
--
ALTER TABLE `blindtest_players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `blindtest_sessions`
--
ALTER TABLE `blindtest_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `championnats_contributions_points`
--
ALTER TABLE `championnats_contributions_points`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `championnats_resultats`
--
ALTER TABLE `championnats_resultats`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `championnats_saisons`
--
ALTER TABLE `championnats_saisons`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `championnats_sessions`
--
ALTER TABLE `championnats_sessions`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `championnats_sessions_lots`
--
ALTER TABLE `championnats_sessions_lots`
  MODIFY `id` mediumint(9) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `championnats_sessions_lots_to_entites_joueurs`
--
ALTER TABLE `championnats_sessions_lots_to_entites_joueurs`
  MODIFY `id` mediumint(9) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `clients`
--
ALTER TABLE `clients`
  MODIFY `id` mediumint(9) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `clients_branding`
--
ALTER TABLE `clients_branding`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `clients_contacts`
--
ALTER TABLE `clients_contacts`
  MODIFY `id` mediumint(9) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `clients_emails_transactionnels_logs`
--
ALTER TABLE `clients_emails_transactionnels_logs`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `clients_logs`
--
ALTER TABLE `clients_logs`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `clients_logs_onboarding`
--
ALTER TABLE `clients_logs_onboarding`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `clients_logs_utm`
--
ALTER TABLE `clients_logs_utm`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `clients_temoignages`
--
ALTER TABLE `clients_temoignages`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `communication_actualites`
--
ALTER TABLE `communication_actualites`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `communication_actualites_rubriques`
--
ALTER TABLE `communication_actualites_rubriques`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `communication_focus`
--
ALTER TABLE `communication_focus`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `communication_slides`
--
ALTER TABLE `communication_slides`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `cotton_quiz_players`
--
ALTER TABLE `cotton_quiz_players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `cotton_quiz_sessions`
--
ALTER TABLE `cotton_quiz_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `crm_abonnes`
--
ALTER TABLE `crm_abonnes`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `crm_contacts`
--
ALTER TABLE `crm_contacts`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `crm_parrainages`
--
ALTER TABLE `crm_parrainages`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ecommerce_commandes`
--
ALTER TABLE `ecommerce_commandes`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ecommerce_commandes_lignes`
--
ALTER TABLE `ecommerce_commandes_lignes`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ecommerce_formules`
--
ALTER TABLE `ecommerce_formules`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ecommerce_formules_declinaisons`
--
ALTER TABLE `ecommerce_formules_declinaisons`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ecommerce_formules_declinaisons_to_clients`
--
ALTER TABLE `ecommerce_formules_declinaisons_to_clients`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ecommerce_offres`
--
ALTER TABLE `ecommerce_offres`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ecommerce_offres_paniers`
--
ALTER TABLE `ecommerce_offres_paniers`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ecommerce_offres_to_clients`
--
ALTER TABLE `ecommerce_offres_to_clients`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ecommerce_produits_types`
--
ALTER TABLE `ecommerce_produits_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ecommerce_remises`
--
ALTER TABLE `ecommerce_remises`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ecommerce_remises_clients`
--
ALTER TABLE `ecommerce_remises_clients`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ecommerce_remises_to_offres`
--
ALTER TABLE `ecommerce_remises_to_offres`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ecommerce_remises_to_offres_clients`
--
ALTER TABLE `ecommerce_remises_to_offres_clients`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `entites_joueurs_emails_transactionnels_logs`
--
ALTER TABLE `entites_joueurs_emails_transactionnels_logs`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `entites_joueurs_logs`
--
ALTER TABLE `entites_joueurs_logs`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `entites_utilisateurs`
--
ALTER TABLE `entites_utilisateurs`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `entites_utilisateurs_logs`
--
ALTER TABLE `entites_utilisateurs_logs`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `equipes`
--
ALTER TABLE `equipes`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `equipes_joueurs`
--
ALTER TABLE `equipes_joueurs`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `equipes_logs`
--
ALTER TABLE `equipes_logs`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `game_events`
--
ALTER TABLE `game_events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `general_branding`
--
ALTER TABLE `general_branding`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `general_parametres`
--
ALTER TABLE `general_parametres`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `general_univers`
--
ALTER TABLE `general_univers`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `jeux_bingo_musical_artistes`
--
ALTER TABLE `jeux_bingo_musical_artistes`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `jeux_bingo_musical_grids`
--
ALTER TABLE `jeux_bingo_musical_grids`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `jeux_bingo_musical_grids_clients`
--
ALTER TABLE `jeux_bingo_musical_grids_clients`
  MODIFY `id` mediumint(9) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `jeux_bingo_musical_morceaux`
--
ALTER TABLE `jeux_bingo_musical_morceaux`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `jeux_bingo_musical_playlists`
--
ALTER TABLE `jeux_bingo_musical_playlists`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `jeux_bingo_musical_playlists_clients`
--
ALTER TABLE `jeux_bingo_musical_playlists_clients`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `jeux_bingo_musical_playlists_clients_logs`
--
ALTER TABLE `jeux_bingo_musical_playlists_clients_logs`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `jeux_bingo_musical_playlists_rubriques`
--
ALTER TABLE `jeux_bingo_musical_playlists_rubriques`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `medias_audios`
--
ALTER TABLE `medias_audios`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `medias_documents`
--
ALTER TABLE `medias_documents`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `medias_images`
--
ALTER TABLE `medias_images`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `operations_evenements`
--
ALTER TABLE `operations_evenements`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `questions`
--
ALTER TABLE `questions`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `questions_bonus`
--
ALTER TABLE `questions_bonus`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `questions_feedback`
--
ALTER TABLE `questions_feedback`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `questions_lots`
--
ALTER TABLE `questions_lots`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `questions_lots_rubriques`
--
ALTER TABLE `questions_lots_rubriques`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `questions_lots_temp`
--
ALTER TABLE `questions_lots_temp`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `questions_lots_univers`
--
ALTER TABLE `questions_lots_univers`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `questions_propositions`
--
ALTER TABLE `questions_propositions`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `questions_rubriques`
--
ALTER TABLE `questions_rubriques`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `questions_tags`
--
ALTER TABLE `questions_tags`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `questions_univers`
--
ALTER TABLE `questions_univers`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `quizs`
--
ALTER TABLE `quizs`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `quizs_series`
--
ALTER TABLE `quizs_series`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_bingo_musical_playlists_clients_logs_types`
--
ALTER TABLE `referentiels_bingo_musical_playlists_clients_logs_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_branding_types`
--
ALTER TABLE `referentiels_branding_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_clients_acquisitions_canaux`
--
ALTER TABLE `referentiels_clients_acquisitions_canaux`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_clients_contacts_types`
--
ALTER TABLE `referentiels_clients_contacts_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_clients_erp_jauges`
--
ALTER TABLE `referentiels_clients_erp_jauges`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_clients_etats`
--
ALTER TABLE `referentiels_clients_etats`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_clients_pipeline_etats`
--
ALTER TABLE `referentiels_clients_pipeline_etats`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_clients_reservations`
--
ALTER TABLE `referentiels_clients_reservations`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_clients_solution_usages`
--
ALTER TABLE `referentiels_clients_solution_usages`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_clients_types`
--
ALTER TABLE `referentiels_clients_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_clients_typologies`
--
ALTER TABLE `referentiels_clients_typologies`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_commandes_etats`
--
ALTER TABLE `referentiels_commandes_etats`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_commercial_actions_types`
--
ALTER TABLE `referentiels_commercial_actions_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_emails_transactionnels`
--
ALTER TABLE `referentiels_emails_transactionnels`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_equipes_joueurs_types`
--
ALTER TABLE `referentiels_equipes_joueurs_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_formules_etats`
--
ALTER TABLE `referentiels_formules_etats`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_logs_types`
--
ALTER TABLE `referentiels_logs_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_morceaux_popularites`
--
ALTER TABLE `referentiels_morceaux_popularites`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_morceaux_styles`
--
ALTER TABLE `referentiels_morceaux_styles`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_offres_clients_etats`
--
ALTER TABLE `referentiels_offres_clients_etats`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_offres_types`
--
ALTER TABLE `referentiels_offres_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_paiements_frequences`
--
ALTER TABLE `referentiels_paiements_frequences`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_paiements_modes`
--
ALTER TABLE `referentiels_paiements_modes`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_paiements_types`
--
ALTER TABLE `referentiels_paiements_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_playlists_difficultes`
--
ALTER TABLE `referentiels_playlists_difficultes`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_produits_quiz_frequences`
--
ALTER TABLE `referentiels_produits_quiz_frequences`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_produits_types`
--
ALTER TABLE `referentiels_produits_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_questions_feedback_reload_types`
--
ALTER TABLE `referentiels_questions_feedback_reload_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_remises_types`
--
ALTER TABLE `referentiels_remises_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_sessions_evenements`
--
ALTER TABLE `referentiels_sessions_evenements`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_sous_domaines`
--
ALTER TABLE `referentiels_sous_domaines`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_utilisateurs_types`
--
ALTER TABLE `referentiels_utilisateurs_types`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_zones_departements`
--
ALTER TABLE `referentiels_zones_departements`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `referentiels_zones_pays`
--
ALTER TABLE `referentiels_zones_pays`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `reporting_shares`
--
ALTER TABLE `reporting_shares`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `support_conseils`
--
ALTER TABLE `support_conseils`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `support_contacts`
--
ALTER TABLE `support_contacts`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `support_faq`
--
ALTER TABLE `support_faq`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `support_installations`
--
ALTER TABLE `support_installations`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `support_regles`
--
ALTER TABLE `support_regles`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `x-archive-bingos-2025-02`
--
ALTER TABLE `x-archive-bingos-2025-02`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `x-archive-equipes-2020-03`
--
ALTER TABLE `x-archive-equipes-2020-03`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `x-archive-joueurs-2020-03`
--
ALTER TABLE `x-archive-joueurs-2020-03`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `x-archive-morceaux-2025-02`
--
ALTER TABLE `x-archive-morceaux-2025-02`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `x-archive-resultats-2020-03`
--
ALTER TABLE `x-archive-resultats-2020-03`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `ai_pilot_agents`
--
ALTER TABLE `ai_pilot_agents`
  ADD CONSTRAINT `fk_agent_tenant` FOREIGN KEY (`tenant_id`) REFERENCES `ai_pilot_tenants` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `ai_pilot_api_usage`
--
ALTER TABLE `ai_pilot_api_usage`
  ADD CONSTRAINT `fk_api_usage_content` FOREIGN KEY (`content_id`) REFERENCES `ai_pilot_generated_contents` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_api_usage_service` FOREIGN KEY (`service_id`) REFERENCES `ai_pilot_ia_services` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_api_usage_tenant` FOREIGN KEY (`tenant_id`) REFERENCES `ai_pilot_tenants` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `ai_pilot_client_preferences`
--
ALTER TABLE `ai_pilot_client_preferences`
  ADD CONSTRAINT `fk_pref_tenant` FOREIGN KEY (`tenant_id`) REFERENCES `ai_pilot_tenants` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `ai_pilot_generated_contents`
--
ALTER TABLE `ai_pilot_generated_contents`
  ADD CONSTRAINT `fk_content_platform` FOREIGN KEY (`platform_id`) REFERENCES `ai_pilot_platforms` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_content_tenant_agent` FOREIGN KEY (`tenant_agent_id`) REFERENCES `ai_pilot_tenant_agents` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `ai_pilot_media_assets`
--
ALTER TABLE `ai_pilot_media_assets`
  ADD CONSTRAINT `fk_media_content` FOREIGN KEY (`content_id`) REFERENCES `ai_pilot_generated_contents` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `ai_pilot_scheduled_tasks`
--
ALTER TABLE `ai_pilot_scheduled_tasks`
  ADD CONSTRAINT `fk_task_platform` FOREIGN KEY (`platform_id`) REFERENCES `ai_pilot_platforms` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_task_tenant_agent` FOREIGN KEY (`tenant_agent_id`) REFERENCES `ai_pilot_tenant_agents` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `ai_pilot_tenant_agents`
--
ALTER TABLE `ai_pilot_tenant_agents`
  ADD CONSTRAINT `fk_tenant_agent_agent` FOREIGN KEY (`agent_id`) REFERENCES `ai_pilot_agents` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tenant_agent_tenant` FOREIGN KEY (`tenant_id`) REFERENCES `ai_pilot_tenants` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `ai_pilot_tenant_agent_configs`
--
ALTER TABLE `ai_pilot_tenant_agent_configs`
  ADD CONSTRAINT `fk_config_platform` FOREIGN KEY (`platform_id`) REFERENCES `ai_pilot_platforms` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_config_tenant_agent` FOREIGN KEY (`tenant_agent_id`) REFERENCES `ai_pilot_tenant_agents` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
