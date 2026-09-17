-- Cotton Hub QR : migration manuelle DEV uniquement, 2026-09-07.
-- Cible : MariaDB 10.3.39 / MyISAM / utf8_general_ci. Pas pour PROD.
-- Importer CE FICHIER ENTIER dans la base DEV sélectionnée dans phpMyAdmin.
-- Aucun USE, aucune donnée métier, aucune procédure et aucun ensure applicatif.
-- Lire canon/runbooks/hub-player-qr-migration.md avant import.
-- Sauvegarde préalable ; une seule migration à la fois, créneau sans écritures Hub.
-- COPY / SHARED : écritures bloquées, copie physique ; WAIT 10 borne l'attente
-- de verrou, PAS la durée totale. ALTER TABLE ne s'annule pas par ROLLBACK.
-- Une incompatibilité rend tout DDL inopérant : lire le statut final, et non
-- seulement « requête exécutée ». BLOQUE/INCOMPLET ne sont jamais un succès.

SET @cotton_qr_schema = DATABASE();
SET @cotton_qr_allowed = 0;
SET @cotton_qr_bad = 4;
SET @cotton_qr_add = NULL;
SET @cotton_qr_sql = 'SELECT ''BLOQUE : precontrole incomplet'' AS migration_status';
SET @cotton_qr_server_ok = (
  VERSION() LIKE '10.3.39-MariaDB%'
);
SET @cotton_qr_table_ok = (
  SELECT COUNT(*) = 1 FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = @cotton_qr_schema AND TABLE_NAME = 'games_hubs'
    AND TABLE_TYPE = 'BASE TABLE' AND ENGINE = 'MyISAM'
    AND TABLE_COLLATION IN ('utf8_general_ci', 'utf8mb3_general_ci')
);

SELECT @cotton_qr_schema AS selected_database, VERSION() AS server_version,
       @cotton_qr_server_ok AS server_supported, @cotton_qr_table_ok AS table_supported;

-- Précontrôle de toutes les colonnes, avant tout ALTER.
SELECT q.name AS colonne, q.etat FROM (
SELECT e.pos, e.name, e.ddl,
       CASE WHEN c.COLUMN_NAME IS NULL THEN 'ABSENTE'
            WHEN COALESCE(c.EXTRA, '') = ''
             AND c.IS_GENERATED = 'NEVER'
             AND COALESCE(c.GENERATION_EXPRESSION, '') = ''
             AND c.COLUMN_KEY = ''
             AND CASE e.pos
               WHEN 1 THEN c.DATA_TYPE = 'varchar' AND c.CHARACTER_MAXIMUM_LENGTH = 8
                 AND c.CHARACTER_SET_NAME IN ('utf8', 'utf8mb3')
                 AND c.COLLATION_NAME IN ('utf8_general_ci', 'utf8mb3_general_ci')
                 AND c.IS_NULLABLE = 'YES'
                 AND (c.COLUMN_DEFAULT IS NULL OR BINARY c.COLUMN_DEFAULT = BINARY 'NULL')
               WHEN 2 THEN c.DATA_TYPE = 'bigint' AND c.NUMERIC_PRECISION = 20
                 AND c.COLUMN_TYPE LIKE '% unsigned' AND c.COLUMN_TYPE NOT LIKE '%zerofill%'
                 AND c.IS_NULLABLE = 'NO' AND BINARY c.COLUMN_DEFAULT = BINARY '0'
               WHEN 3 THEN c.DATA_TYPE = 'text'
                 AND c.CHARACTER_SET_NAME IN ('utf8', 'utf8mb3')
                 AND c.COLLATION_NAME IN ('utf8_general_ci', 'utf8mb3_general_ci')
                 AND c.IS_NULLABLE = 'YES'
                 AND (c.COLUMN_DEFAULT IS NULL OR BINARY c.COLUMN_DEFAULT = BINARY 'NULL')
               WHEN 4 THEN c.DATA_TYPE = 'datetime' AND c.DATETIME_PRECISION = 0
                 AND c.IS_NULLABLE = 'YES'
                 AND (c.COLUMN_DEFAULT IS NULL OR BINARY c.COLUMN_DEFAULT = BINARY 'NULL')
             END THEN 'CONFORME'
            ELSE 'INCOMPATIBLE' END AS etat
FROM (
SELECT 1 AS pos, 'player_qr_display_mode' AS name,
           'ADD COLUMN `player_qr_display_mode` varchar(8) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL' AS ddl
    UNION ALL SELECT 2, 'player_qr_display_revision',
           'ADD COLUMN `player_qr_display_revision` bigint unsigned NOT NULL DEFAULT 0'
    UNION ALL SELECT 3, 'player_qr_display_confirmation_json',
           'ADD COLUMN `player_qr_display_confirmation_json` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL'
    UNION ALL SELECT 4, 'player_qr_official_started_at',
           'ADD COLUMN `player_qr_official_started_at` datetime NULL DEFAULT NULL'
) AS e
LEFT JOIN information_schema.COLUMNS AS c
  ON c.TABLE_SCHEMA = @cotton_qr_schema
 AND c.TABLE_NAME = 'games_hubs' AND c.COLUMN_NAME = e.name
) AS q ORDER BY q.pos;

SELECT SUM(q.etat = 'INCOMPATIBLE'),
       GROUP_CONCAT(CASE WHEN q.etat = 'ABSENTE' THEN q.ddl END ORDER BY q.pos SEPARATOR ', ')
INTO @cotton_qr_bad, @cotton_qr_add
FROM (
SELECT e.pos, e.name, e.ddl,
       CASE WHEN c.COLUMN_NAME IS NULL THEN 'ABSENTE'
            WHEN COALESCE(c.EXTRA, '') = ''
             AND c.IS_GENERATED = 'NEVER'
             AND COALESCE(c.GENERATION_EXPRESSION, '') = ''
             AND c.COLUMN_KEY = ''
             AND CASE e.pos
               WHEN 1 THEN c.DATA_TYPE = 'varchar' AND c.CHARACTER_MAXIMUM_LENGTH = 8
                 AND c.CHARACTER_SET_NAME IN ('utf8', 'utf8mb3')
                 AND c.COLLATION_NAME IN ('utf8_general_ci', 'utf8mb3_general_ci')
                 AND c.IS_NULLABLE = 'YES'
                 AND (c.COLUMN_DEFAULT IS NULL OR BINARY c.COLUMN_DEFAULT = BINARY 'NULL')
               WHEN 2 THEN c.DATA_TYPE = 'bigint' AND c.NUMERIC_PRECISION = 20
                 AND c.COLUMN_TYPE LIKE '% unsigned' AND c.COLUMN_TYPE NOT LIKE '%zerofill%'
                 AND c.IS_NULLABLE = 'NO' AND BINARY c.COLUMN_DEFAULT = BINARY '0'
               WHEN 3 THEN c.DATA_TYPE = 'text'
                 AND c.CHARACTER_SET_NAME IN ('utf8', 'utf8mb3')
                 AND c.COLLATION_NAME IN ('utf8_general_ci', 'utf8mb3_general_ci')
                 AND c.IS_NULLABLE = 'YES'
                 AND (c.COLUMN_DEFAULT IS NULL OR BINARY c.COLUMN_DEFAULT = BINARY 'NULL')
               WHEN 4 THEN c.DATA_TYPE = 'datetime' AND c.DATETIME_PRECISION = 0
                 AND c.IS_NULLABLE = 'YES'
                 AND (c.COLUMN_DEFAULT IS NULL OR BINARY c.COLUMN_DEFAULT = BINARY 'NULL')
             END THEN 'CONFORME'
            ELSE 'INCOMPATIBLE' END AS etat
FROM (
SELECT 1 AS pos, 'player_qr_display_mode' AS name,
           'ADD COLUMN `player_qr_display_mode` varchar(8) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL' AS ddl
    UNION ALL SELECT 2, 'player_qr_display_revision',
           'ADD COLUMN `player_qr_display_revision` bigint unsigned NOT NULL DEFAULT 0'
    UNION ALL SELECT 3, 'player_qr_display_confirmation_json',
           'ADD COLUMN `player_qr_display_confirmation_json` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL'
    UNION ALL SELECT 4, 'player_qr_official_started_at',
           'ADD COLUMN `player_qr_official_started_at` datetime NULL DEFAULT NULL'
) AS e
LEFT JOIN information_schema.COLUMNS AS c
  ON c.TABLE_SCHEMA = @cotton_qr_schema
 AND c.TABLE_NAME = 'games_hubs' AND c.COLUMN_NAME = e.name
) AS q;

SET @cotton_qr_allowed = COALESCE(
  @cotton_qr_schema IS NOT NULL AND @cotton_qr_server_ok = 1
  AND @cotton_qr_table_ok = 1 AND @cotton_qr_bad = 0
  -- Le plan complet fait moins de 1024 octets ; refuser une limite abaissée.
  AND @@SESSION.group_concat_max_len >= 1024, 0);
SET @cotton_qr_sql = CASE
  WHEN @cotton_qr_allowed <> 1 THEN
    'SELECT ''BLOQUE : base, serveur, moteur, collation, limite ou definition incompatible ; aucun ajout'' AS migration_status'
  WHEN @cotton_qr_add IS NULL THEN
    'SELECT ''DEJA_CONFORME : aucun ALTER necessaire'' AS migration_status'
  ELSE CONCAT('ALTER TABLE `', REPLACE(@cotton_qr_schema, '`', '``'),
              '`.`games_hubs` WAIT 10 ', @cotton_qr_add, ', ALGORITHM=COPY, LOCK=SHARED')
END;
SELECT @cotton_qr_sql AS planned_statement;
PREPARE cotton_qr_migration FROM @cotton_qr_sql;
EXECUTE cotton_qr_migration;
DEALLOCATE PREPARE cotton_qr_migration;

-- Relire le schéma réel ; ne jamais annoncer la réussite sur la seule intention.
SELECT q.name AS colonne, q.etat FROM (
SELECT e.pos, e.name, e.ddl,
       CASE WHEN c.COLUMN_NAME IS NULL THEN 'ABSENTE'
            WHEN COALESCE(c.EXTRA, '') = ''
             AND c.IS_GENERATED = 'NEVER'
             AND COALESCE(c.GENERATION_EXPRESSION, '') = ''
             AND c.COLUMN_KEY = ''
             AND CASE e.pos
               WHEN 1 THEN c.DATA_TYPE = 'varchar' AND c.CHARACTER_MAXIMUM_LENGTH = 8
                 AND c.CHARACTER_SET_NAME IN ('utf8', 'utf8mb3')
                 AND c.COLLATION_NAME IN ('utf8_general_ci', 'utf8mb3_general_ci')
                 AND c.IS_NULLABLE = 'YES'
                 AND (c.COLUMN_DEFAULT IS NULL OR BINARY c.COLUMN_DEFAULT = BINARY 'NULL')
               WHEN 2 THEN c.DATA_TYPE = 'bigint' AND c.NUMERIC_PRECISION = 20
                 AND c.COLUMN_TYPE LIKE '% unsigned' AND c.COLUMN_TYPE NOT LIKE '%zerofill%'
                 AND c.IS_NULLABLE = 'NO' AND BINARY c.COLUMN_DEFAULT = BINARY '0'
               WHEN 3 THEN c.DATA_TYPE = 'text'
                 AND c.CHARACTER_SET_NAME IN ('utf8', 'utf8mb3')
                 AND c.COLLATION_NAME IN ('utf8_general_ci', 'utf8mb3_general_ci')
                 AND c.IS_NULLABLE = 'YES'
                 AND (c.COLUMN_DEFAULT IS NULL OR BINARY c.COLUMN_DEFAULT = BINARY 'NULL')
               WHEN 4 THEN c.DATA_TYPE = 'datetime' AND c.DATETIME_PRECISION = 0
                 AND c.IS_NULLABLE = 'YES'
                 AND (c.COLUMN_DEFAULT IS NULL OR BINARY c.COLUMN_DEFAULT = BINARY 'NULL')
             END THEN 'CONFORME'
            ELSE 'INCOMPATIBLE' END AS etat
FROM (
SELECT 1 AS pos, 'player_qr_display_mode' AS name,
           'ADD COLUMN `player_qr_display_mode` varchar(8) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL' AS ddl
    UNION ALL SELECT 2, 'player_qr_display_revision',
           'ADD COLUMN `player_qr_display_revision` bigint unsigned NOT NULL DEFAULT 0'
    UNION ALL SELECT 3, 'player_qr_display_confirmation_json',
           'ADD COLUMN `player_qr_display_confirmation_json` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL'
    UNION ALL SELECT 4, 'player_qr_official_started_at',
           'ADD COLUMN `player_qr_official_started_at` datetime NULL DEFAULT NULL'
) AS e
LEFT JOIN information_schema.COLUMNS AS c
  ON c.TABLE_SCHEMA = @cotton_qr_schema
 AND c.TABLE_NAME = 'games_hubs' AND c.COLUMN_NAME = e.name
) AS q ORDER BY q.pos;
SELECT CASE WHEN @cotton_qr_allowed <> 1 THEN 'BLOQUE'
            WHEN SUM(q.etat = 'CONFORME') = 4 THEN 'OK_SCHEMA_QR'
            ELSE 'INCOMPLET : relire les erreurs et le schema avant reprise'
       END AS migration_status
FROM (
SELECT e.pos, e.name, e.ddl,
       CASE WHEN c.COLUMN_NAME IS NULL THEN 'ABSENTE'
            WHEN COALESCE(c.EXTRA, '') = ''
             AND c.IS_GENERATED = 'NEVER'
             AND COALESCE(c.GENERATION_EXPRESSION, '') = ''
             AND c.COLUMN_KEY = ''
             AND CASE e.pos
               WHEN 1 THEN c.DATA_TYPE = 'varchar' AND c.CHARACTER_MAXIMUM_LENGTH = 8
                 AND c.CHARACTER_SET_NAME IN ('utf8', 'utf8mb3')
                 AND c.COLLATION_NAME IN ('utf8_general_ci', 'utf8mb3_general_ci')
                 AND c.IS_NULLABLE = 'YES'
                 AND (c.COLUMN_DEFAULT IS NULL OR BINARY c.COLUMN_DEFAULT = BINARY 'NULL')
               WHEN 2 THEN c.DATA_TYPE = 'bigint' AND c.NUMERIC_PRECISION = 20
                 AND c.COLUMN_TYPE LIKE '% unsigned' AND c.COLUMN_TYPE NOT LIKE '%zerofill%'
                 AND c.IS_NULLABLE = 'NO' AND BINARY c.COLUMN_DEFAULT = BINARY '0'
               WHEN 3 THEN c.DATA_TYPE = 'text'
                 AND c.CHARACTER_SET_NAME IN ('utf8', 'utf8mb3')
                 AND c.COLLATION_NAME IN ('utf8_general_ci', 'utf8mb3_general_ci')
                 AND c.IS_NULLABLE = 'YES'
                 AND (c.COLUMN_DEFAULT IS NULL OR BINARY c.COLUMN_DEFAULT = BINARY 'NULL')
               WHEN 4 THEN c.DATA_TYPE = 'datetime' AND c.DATETIME_PRECISION = 0
                 AND c.IS_NULLABLE = 'YES'
                 AND (c.COLUMN_DEFAULT IS NULL OR BINARY c.COLUMN_DEFAULT = BINARY 'NULL')
             END THEN 'CONFORME'
            ELSE 'INCOMPATIBLE' END AS etat
FROM (
SELECT 1 AS pos, 'player_qr_display_mode' AS name,
           'ADD COLUMN `player_qr_display_mode` varchar(8) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL' AS ddl
    UNION ALL SELECT 2, 'player_qr_display_revision',
           'ADD COLUMN `player_qr_display_revision` bigint unsigned NOT NULL DEFAULT 0'
    UNION ALL SELECT 3, 'player_qr_display_confirmation_json',
           'ADD COLUMN `player_qr_display_confirmation_json` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL'
    UNION ALL SELECT 4, 'player_qr_official_started_at',
           'ADD COLUMN `player_qr_official_started_at` datetime NULL DEFAULT NULL'
) AS e
LEFT JOIN information_schema.COLUMNS AS c
  ON c.TABLE_SCHEMA = @cotton_qr_schema
 AND c.TABLE_NAME = 'games_hubs' AND c.COLUMN_NAME = e.name
) AS q;
