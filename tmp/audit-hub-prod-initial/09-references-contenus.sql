-- Lecture seule. References de contenus, sans interpretation de leur validite.
SELECT id_type_produit, id_produit, id_format,
       flag_controle_numerique, lot_ids, COUNT(*) AS nb_sessions
FROM prod_cotton_global_0.championnats_sessions
WHERE flag_session_demo = 0 AND date >= '2026-09-08'
GROUP BY id_type_produit, id_produit, id_format,
         flag_controle_numerique, lot_ids
ORDER BY id_type_produit, id_produit, id_format,
         flag_controle_numerique, lot_ids;
