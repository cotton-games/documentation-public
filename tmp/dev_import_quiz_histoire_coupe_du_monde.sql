-- Cotton Quiz DEV import - Histoire de la Coupe du monde
-- Generated for manual phpMyAdmin DEV import only.
-- Do not run on production. Do not import without editorial validation.
--
-- Evidence summary:
-- - Cotton certified direct import runbook:
--   https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/cotton-certified-direct-import.md
--   Sections: "Series Cotton Quiz", "community_items", "Structure recommandee d'un SQL d'import".
-- - Local code confirms:
--   questions.reponse is the correct answer; questions_propositions stores false propositions.
--   Runtime combines the correct answer with false propositions.
--
-- Transaction note:
-- questions_lots / questions / questions_propositions are MyISAM in the local DDL export.
-- START TRANSACTION / COMMIT are kept for phpMyAdmin readability and InnoDB tables
-- such as community_items, but rollback is not guaranteed for MyISAM writes.
--
-- Image support note:
-- The application upload flow stores image binaries on the web filesystem
-- (/upload/quiz/images/questions/question/) and stores only public URLs/metadata
-- in the DB. phpMyAdmin SQL cannot upload those files by itself.
-- If external URLs are rejected by DEV rendering, import the quiz first and
-- upload Q1/Q2/Q6 images via the application UI, or pre-place files on the
-- server then update questions.lien_support + medias_images metadata.

SET NAMES utf8mb4;
START TRANSACTION;

SET @series_title := 'Histoire de la Coupe du monde';
SET @series_slug := 'histoire-coupe-du-monde';
SET @series_description := 'Une serie accessible pour tester ses connaissances sur les grands reperes de la Coupe du monde de football : premieres editions, trophees, records, grandes nations et moments marquants.';
SET @cotton_author_id := 0;
SET @difficulty_easy := 1;
SET @lot_univers_id := NULL;
SET @lot_rubrique_id := NULL;
SET @question_univers_id := NULL;
SET @question_rubrique_id := NULL;
SET @existing_lot_id := NULL;
SET @existing_lot_author_id := NULL;

-- Resolve taxonomy from the target DB rather than hardcoding undocumented IDs.
-- The catalogue-series UI confirms Sport as 1_1 in one admin flow, but this
-- import still asks the DB for the active labels to avoid relying on that flow.
SELECT id INTO @lot_univers_id
FROM questions_lots_univers
WHERE online = 1
  AND LOWER(nom) LIKE '%sport%'
ORDER BY id ASC
LIMIT 1;

SELECT id INTO @lot_rubrique_id
FROM questions_lots_rubriques
WHERE online = 1
  AND id_univers = @lot_univers_id
  AND (LOWER(nom) LIKE '%football%' OR LOWER(nom) LIKE '%sport%')
ORDER BY CASE WHEN LOWER(nom) LIKE '%football%' THEN 0 ELSE 1 END, id ASC
LIMIT 1;

SELECT id INTO @question_univers_id
FROM questions_univers
WHERE online = 1
  AND LOWER(nom) LIKE '%sport%'
ORDER BY id ASC
LIMIT 1;

SELECT id INTO @question_rubrique_id
FROM questions_rubriques
WHERE online = 1
  AND id_univers = @question_univers_id
  AND (LOWER(nom) LIKE '%football%' OR LOWER(nom) LIKE '%sport%')
ORDER BY CASE WHEN LOWER(nom) LIKE '%football%' THEN 0 ELSE 1 END, id ASC
LIMIT 1;

SET @lot_univers_id := COALESCE(@lot_univers_id, 0);
SET @lot_rubrique_id := COALESCE(@lot_rubrique_id, 0);
SET @question_univers_id := COALESCE(@question_univers_id, @lot_univers_id, 0);
SET @question_rubrique_id := COALESCE(@question_rubrique_id, @lot_rubrique_id, 0);

SET @has_flag_validated := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'questions_lots'
    AND COLUMN_NAME = 'flag_validated'
);
SET @has_validated_at := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'questions_lots'
    AND COLUMN_NAME = 'validated_at'
);
SET @has_flag_share_community := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'questions_lots'
    AND COLUMN_NAME = 'flag_share_community'
);
SET @has_community_items := (
  SELECT COUNT(*)
  FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'community_items'
);

SELECT id, id_client_auteur INTO @existing_lot_id, @existing_lot_author_id
FROM questions_lots
WHERE seo_slug = @series_slug
   OR (nom = @series_title AND id_client_auteur = @cotton_author_id)
ORDER BY id ASC
LIMIT 1;

SET @existing_lot_id := COALESCE(@existing_lot_id, 0);
SET @existing_lot_author_id := COALESCE(@existing_lot_author_id, 0);

SET @guard_error := '';
SET @guard_error := IF(@lot_univers_id <= 0, 'Taxonomie lot Sport introuvable dans questions_lots_univers.', @guard_error);
SET @guard_error := IF(@lot_rubrique_id <= 0, 'Taxonomie lot Football/Sport introuvable dans questions_lots_rubriques.', @guard_error);
SET @guard_error := IF(@question_univers_id <= 0, 'Taxonomie question Sport introuvable dans questions_univers.', @guard_error);
SET @guard_error := IF(@question_rubrique_id <= 0, 'Taxonomie question Football/Sport introuvable dans questions_rubriques.', @guard_error);
SET @guard_error := IF(@existing_lot_id > 0 AND @existing_lot_author_id <> @cotton_author_id, 'Slug existant porte par un auteur non Cotton: import bloque.', @guard_error);

SELECT IF(@guard_error = '', 'Guard OK', @guard_error) AS import_guard;
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_cq_import_guard_abort (
  guard_ok TINYINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO tmp_cq_import_guard_abort (guard_ok)
SELECT NULL
FROM DUAL
WHERE @guard_error <> '';

-- Create the lot only when it does not already exist.
SET @lot_columns := 'id_client_auteur, nom_auteur, id_equipe_joueur, id_etat, id_univers, id_rubrique, nom, descriptif_court, descriptif_long, difficulte, jour_associe_debut, jour_associe_fin, date_annee, flag_generateur, flag_begin, flag_droits, flag_une, commentaire, online, seo_slug, seo_meta_title, seo_meta_description, date_ajout, date_maj, id_user_ajout, id_user_maj';
SET @lot_values := '0, '''', 0, 2, @lot_univers_id, @lot_rubrique_id, @series_title, @series_description, '''', @difficulty_easy, '''', '''', NULL, 0, 1, 0, 0, '''', 1, @series_slug, @series_title, @series_description, CURDATE(), CURDATE(), 0, 0';

SET @lot_columns := IF(@has_flag_validated > 0, CONCAT(@lot_columns, ', flag_validated'), @lot_columns);
SET @lot_values := IF(@has_flag_validated > 0, CONCAT(@lot_values, ', 1'), @lot_values);
SET @lot_columns := IF(@has_validated_at > 0, CONCAT(@lot_columns, ', validated_at'), @lot_columns);
SET @lot_values := IF(@has_validated_at > 0, CONCAT(@lot_values, ', NOW()'), @lot_values);
SET @lot_columns := IF(@has_flag_share_community > 0, CONCAT(@lot_columns, ', flag_share_community'), @lot_columns);
SET @lot_values := IF(@has_flag_share_community > 0, CONCAT(@lot_values, ', 0'), @lot_values);

SET @insert_lot_sql := CONCAT(
  'INSERT INTO questions_lots (', @lot_columns, ') SELECT ', @lot_values,
  ' FROM DUAL WHERE @existing_lot_id = 0'
);
PREPARE insert_lot_stmt FROM @insert_lot_sql;
EXECUTE insert_lot_stmt;
DEALLOCATE PREPARE insert_lot_stmt;

SET @lot_id := IF(@existing_lot_id > 0, @existing_lot_id, LAST_INSERT_ID());

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_cq_import_questions (
  position TINYINT UNSIGNED NOT NULL,
  question_text TEXT NOT NULL,
  correct_answer TEXT NOT NULL,
  explanation TEXT NOT NULL,
  support_type TINYINT UNSIGNED NOT NULL DEFAULT 0,
  support_url VARCHAR(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELETE FROM tmp_cq_import_questions;

INSERT INTO tmp_cq_import_questions
  (position, question_text, correct_answer, explanation, support_type, support_url)
VALUES
  (1, 'Dans quel pays a eu lieu la premiere Coupe du monde de football, jouee en 1930 ?', 'Uruguay', 'La premiere Coupe du monde s''est jouee en Uruguay en 1930. Le pays hote a egalement remporte cette premiere edition.', 1, 'https://upload.wikimedia.org/wikipedia/commons/4/43/Estadio_Centenario_1930.jpg'),
  (2, 'Avant le trophee actuel de la Coupe du monde, les vainqueurs recevaient le trophee Jules Rimet, nomme d''apres un ancien president de la FIFA. Quelle nation l''a conserve definitivement apres son troisieme titre mondial ?', 'Bresil', 'Le Bresil a remporte son troisieme titre mondial en 1970, ce qui lui a permis de conserver definitivement le trophee Jules Rimet.', 1, 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Jules_Rimet_trophy_replica.jpg/500px-Jules_Rimet_trophy_replica.jpg'),
  (3, 'Quel joueur allemand detient le record du nombre de buts marques en Coupe du monde masculine ?', 'Miroslav Klose', 'Miroslav Klose est le meilleur buteur de l''histoire de la Coupe du monde masculine, avec 16 buts.', 0, ''),
  (4, 'Quelle equipe a ete la premiere nation africaine a atteindre les demi-finales d''une Coupe du monde, lors de l''edition 2022 ?', 'Maroc', 'Le Maroc est devenu la premiere equipe africaine a atteindre les demi-finales d''une Coupe du monde en 2022.', 0, ''),
  (5, 'Dans le football, quelle equipe nationale est mondialement associee a la "Selecao Canarinho", un surnom lie notamment a son maillot jaune ?', 'Bresil', 'La "Selecao Canarinho" designe l''equipe nationale du Bresil. Le terme "canarinho" renvoie au jaune emblematique de son maillot.', 0, ''),
  (6, 'Lors d''un match a elimination directe en Coupe du monde, que se passe-t-il si les deux equipes sont encore a egalite apres le temps reglementaire ?', 'Une prolongation peut etre jouee avant une eventuelle seance de tirs au but', 'En phase a elimination directe, une egalite apres le temps reglementaire peut mener a une prolongation, puis a une seance de tirs au but si l''egalite persiste.', 1, 'https://upload.wikimedia.org/wikipedia/commons/f/f1/Eduardo_Delani_-_Penalty_kick.jpg');

SET @existing_total_questions := (
  SELECT COUNT(*)
  FROM questions
  WHERE id_lot = @lot_id
);
SET @existing_target_questions := (
  SELECT COUNT(*)
  FROM questions q
  JOIN tmp_cq_import_questions iq ON iq.question_text = q.question
  WHERE q.id_lot = @lot_id
);
SET @question_guard_error := IF(
  @existing_total_questions > 0 AND @existing_target_questions <> 6,
  'Le lot existe deja avec un contenu different ou incomplet: ajout de questions bloque.',
  ''
);
SELECT IF(@question_guard_error = '', 'Question guard OK', @question_guard_error) AS import_guard;
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_cq_import_question_guard_abort (
  guard_ok TINYINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO tmp_cq_import_question_guard_abort (guard_ok)
SELECT NULL
FROM DUAL
WHERE @question_guard_error <> '';

INSERT INTO questions (
  id_client_auteur, nom_auteur, id_equipe_joueur, id_etat, id_univers, id_rubrique, id_lot,
  id_theme, id_type, id_type_support, lien_support, flag_support_indispensable,
  id_type_support_reponse, lien_support_reponse, id_points,
  serie_1, serie_2, serie_3, serie_4,
  introduction, question, propositions, reponse, conclusion, commentaire,
  jour_associe, jour_associe_v1, date_fin_validite, difficulte,
  flag_droits, online, position, date_ajout, date_maj, id_securite, id_user_ajout, id_user_maj
)
SELECT
  @cotton_author_id, '', 0, 2, @question_univers_id, @question_rubrique_id, @lot_id,
  0, 0, iq.support_type, iq.support_url, 0,
  0, '', 1,
  0, 0, 0, 0,
  '', iq.question_text, '', iq.correct_answer, '', iq.explanation,
  '', '', '0000-00-00', @difficulty_easy,
  0, 1, iq.position, NOW(), NOW(), '', 0, 0
FROM tmp_cq_import_questions iq
WHERE NOT EXISTS (
  SELECT 1
  FROM questions q
  WHERE q.id_lot = @lot_id
    AND q.question = iq.question_text
  LIMIT 1
);

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_cq_import_false_props (
  position TINYINT UNSIGNED NOT NULL,
  ordre TINYINT UNSIGNED NOT NULL,
  proposition_text TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELETE FROM tmp_cq_import_false_props;

INSERT INTO tmp_cq_import_false_props (position, ordre, proposition_text)
VALUES
  (1, 1, 'Bresil'), (1, 2, 'Italie'), (1, 3, 'France'),
  (2, 1, 'Allemagne'), (2, 2, 'Argentine'), (2, 3, 'Italie'),
  (3, 1, 'Gerd Muller'), (3, 2, 'Jurgen Klinsmann'), (3, 3, 'Thomas Muller'),
  (4, 1, 'Cameroun'), (4, 2, 'Senegal'), (4, 3, 'Ghana'),
  (5, 1, 'Portugal'), (5, 2, 'Espagne'), (5, 3, 'Argentine'),
  (6, 1, 'Le match est rejoue le lendemain'), (6, 2, 'L''equipe la mieux classee se qualifie'), (6, 3, 'Le capitaine choisit entre prolongation et tirs au but');

INSERT INTO questions_propositions (question_id, proposition_text, ordre)
SELECT q.id, fp.proposition_text, fp.ordre
FROM tmp_cq_import_false_props fp
JOIN tmp_cq_import_questions iq ON iq.position = fp.position
JOIN questions q ON q.id_lot = @lot_id AND q.question = iq.question_text
WHERE NOT EXISTS (
  SELECT 1
  FROM questions_propositions qp
  WHERE qp.question_id = q.id
    AND qp.ordre = fp.ordre
    AND qp.proposition_text = fp.proposition_text
  LIMIT 1
);

-- Modern community projection, only when the table exists.
-- No update is performed on an existing row: this script avoids modifying existing data.
SET @community_family_id := CRC32(CONCAT('quiz|series|catalogue|', @lot_id));
SET @snapshot_json := CONCAT(
  '{"import_dev":1,',
  '"game":"quiz",',
  '"content_type":"series",',
  '"source_type":"catalogue",',
  '"source_id":', @lot_id, ',',
  '"title":"Histoire de la Coupe du monde",',
  '"snapshot_at":"', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'), '"}'
);

SET @community_insert_sql := IF(
  @has_community_items > 0,
  'INSERT INTO community_items (community_family_id, game, content_type, source_type, source_id, origin, source_item_id, source_client_id, item_id, status, snapshot_json, published_at, archived_at)
   SELECT @community_family_id, ''quiz'', ''series'', ''catalogue'', @lot_id, ''cotton'', @lot_id, 0, @lot_id, ''published'', @snapshot_json, NOW(), NULL
   FROM DUAL
   WHERE NOT EXISTS (
     SELECT 1 FROM community_items
     WHERE game=''quiz'' AND content_type=''series'' AND source_type=''catalogue'' AND source_id=@lot_id AND status=''published''
     LIMIT 1
   )',
  'SELECT ''community_items absent: projection moderne ignoree'' AS community_items_status'
);
PREPARE community_insert_stmt FROM @community_insert_sql;
EXECUTE community_insert_stmt;
DEALLOCATE PREPARE community_insert_stmt;

COMMIT;

-- Verification block.
SELECT @lot_id AS lot_id, @series_slug AS seo_slug, @lot_univers_id AS lot_univers_id, @lot_rubrique_id AS lot_rubrique_id, @question_univers_id AS question_univers_id, @question_rubrique_id AS question_rubrique_id;

SELECT *
FROM questions_lots
WHERE id = @lot_id;

SELECT COUNT(*) AS nb_questions
FROM questions
WHERE id_lot = @lot_id;

SELECT COUNT(*) AS nb_false_propositions_in_table
FROM questions_propositions qp
JOIN questions q ON q.id = qp.question_id
WHERE q.id_lot = @lot_id;

SELECT
  COUNT(*) AS nb_questions,
  COUNT(*) AS nb_correct_answers_from_questions_reponse,
  (SELECT COUNT(*)
   FROM questions_propositions qp
   JOIN questions q ON q.id = qp.question_id
   WHERE q.id_lot = @lot_id) AS nb_false_propositions,
  COUNT(*) + (SELECT COUNT(*)
              FROM questions_propositions qp
              JOIN questions q ON q.id = qp.question_id
              WHERE q.id_lot = @lot_id) AS nb_qcm_choices_runtime
FROM questions
WHERE id_lot = @lot_id;

SELECT COUNT(*) AS nb_supports_renseignes
FROM questions
WHERE id_lot = @lot_id
  AND id_type_support > 0
  AND lien_support <> '';

SET @community_check_sql := IF(
  @has_community_items > 0,
  'SELECT * FROM community_items WHERE game=''quiz'' AND content_type=''series'' AND source_type=''catalogue'' AND source_id=@lot_id',
  'SELECT ''community_items absent sur cet environnement'' AS community_items_status'
);
PREPARE community_check_stmt FROM @community_check_sql;
EXECUTE community_check_stmt;
DEALLOCATE PREPARE community_check_stmt;
