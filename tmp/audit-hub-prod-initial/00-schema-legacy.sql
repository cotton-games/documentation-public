-- Audit initial legacy uniquement. Lecture seule. MariaDB 10.3.
-- Date de reference FIGEE : 2026-09-08 inclus. Adapter toutes ses occurrences
-- une seule fois si la date de migration change. Aucun filtre commercial.
-- Executer 00 d'abord ; executer les autres fichiers seulement apres validation
-- des tables/colonnes. Une erreur de schema ne signifie PAS un parc vide.

SELECT VERSION() AS version_serveur, NOW() AS horloge_serveur, UTC_TIMESTAMP() AS horloge_utc, @@session.time_zone AS fuseau_session, @@system_time_zone AS fuseau_systeme, @@sql_mode AS sql_mode;

SELECT TABLE_NAME, ENGINE, TABLE_COLLATION FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND TABLE_NAME IN ('championnats_sessions', 'operations_evenements', 'clients', 'ecommerce_offres_to_clients', 'ecommerce_offres', 'championnats_sessions_lots', 'championnats_sessions_participations_probables', 'general_branding', 'clients_branding', 'ecommerce_reseau_contrats', 'ecommerce_reseau_contrats_affilies', 'quizs', 'questions_lots', 'jeux_bingo_musical_playlists_clients', 'jeux_bingo_musical_morceaux_to_playlists_clients', 'jeux_bingo_musical_playlists') ORDER BY TABLE_NAME;

SELECT TABLE_NAME, ORDINAL_POSITION, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_KEY, EXTRA FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND TABLE_NAME IN ('championnats_sessions', 'operations_evenements', 'clients', 'ecommerce_offres_to_clients', 'ecommerce_offres', 'championnats_sessions_lots', 'championnats_sessions_participations_probables', 'general_branding', 'clients_branding', 'ecommerce_reseau_contrats', 'ecommerce_reseau_contrats_affilies', 'quizs', 'questions_lots', 'jeux_bingo_musical_playlists_clients', 'jeux_bingo_musical_morceaux_to_playlists_clients', 'jeux_bingo_musical_playlists') ORDER BY TABLE_NAME, ORDINAL_POSITION;

SELECT TABLE_NAME, INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND TABLE_NAME IN ('championnats_sessions', 'operations_evenements', 'clients', 'ecommerce_offres_to_clients', 'ecommerce_offres', 'championnats_sessions_lots', 'championnats_sessions_participations_probables', 'general_branding', 'clients_branding', 'ecommerce_reseau_contrats', 'ecommerce_reseau_contrats_affilies', 'quizs', 'questions_lots', 'jeux_bingo_musical_playlists_clients', 'jeux_bingo_musical_morceaux_to_playlists_clients', 'jeux_bingo_musical_playlists') ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

SHOW CREATE TABLE `prod_cotton_global_0`.`championnats_sessions`;
SHOW CREATE TABLE `prod_cotton_global_0`.`operations_evenements`;
SHOW CREATE TABLE `prod_cotton_global_0`.`clients`;
SHOW CREATE TABLE `prod_cotton_global_0`.`ecommerce_offres_to_clients`;
SHOW CREATE TABLE `prod_cotton_global_0`.`ecommerce_offres`;

-- Ces lignes sont du TEXTE a copier ensuite pour les seules tables presentes.
SELECT TABLE_NAME, CONCAT('SHOW CREATE TABLE `prod_cotton_global_0`.`', TABLE_NAME, '`;') AS requete_a_copier FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'prod_cotton_global_0' AND TABLE_NAME IN ('championnats_sessions', 'operations_evenements', 'clients', 'ecommerce_offres_to_clients', 'ecommerce_offres', 'championnats_sessions_lots', 'championnats_sessions_participations_probables', 'general_branding', 'clients_branding', 'ecommerce_reseau_contrats', 'ecommerce_reseau_contrats_affilies', 'quizs', 'questions_lots', 'jeux_bingo_musical_playlists_clients', 'jeux_bingo_musical_morceaux_to_playlists_clients', 'jeux_bingo_musical_playlists') ORDER BY TABLE_NAME;
