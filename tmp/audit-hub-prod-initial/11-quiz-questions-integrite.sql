-- Lecture seule, MariaDB10.3. Les42 tableaux reçus contiennent chacun6 IDs.
SELECT
    COUNT(*) AS references_attendues,
    COUNT(q.id) AS references_trouvees,
    SUM(CASE WHEN q.id IS NULL THEN 1 ELSE 0 END) AS references_absentes,
    COUNT(DISTINCT q.id) AS questions_distinctes_trouvees
FROM prod_cotton_global_0.questions_lots_temp t
CROSS JOIN (
    SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2
    UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
) rang
LEFT JOIN prod_cotton_global_0.questions q
    ON q.id = CAST(JSON_UNQUOTE(JSON_EXTRACT(
        t.question_ids, CONCAT('$[', rang.n, ']')
    )) AS UNSIGNED)
WHERE t.id BETWEEN 209 AND 250;

SELECT l.id AS id_serie, l.nom, COUNT(q.id) AS nb_questions
FROM prod_cotton_global_0.questions_lots l
LEFT JOIN prod_cotton_global_0.questions q ON q.id_lot = l.id
WHERE l.id IN (
    3, 5, 8, 9, 17, 20, 22, 25, 32, 42, 43, 45, 48,
    49, 50, 54, 55, 58, 59, 87, 175, 212, 244, 245, 246, 450
)
GROUP BY l.id, l.nom
ORDER BY l.id;
