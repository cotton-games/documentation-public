-- Lecture seule, références issues du résultat PROD transmis.
SELECT id, nom, JSON_VALID(question_ids) AS json_valide,
       CONVERT(question_ids USING utf8mb4) AS question_ids
FROM prod_cotton_global_0.questions_lots_temp
WHERE id BETWEEN 209 AND 250
ORDER BY id;

SELECT id, nom, id_etat, online
FROM prod_cotton_global_0.questions_lots
WHERE id IN (3, 5, 8, 9, 17, 20, 22, 25, 32, 42, 43, 45, 48, 49, 50, 54, 55, 58, 59, 87, 175, 212, 244, 245, 246, 450)
ORDER BY id;
