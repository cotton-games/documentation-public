-- Lecture seule. Une ligne par session ; pas de multiplication lots/participants.
SELECT
    s.id AS id_session, s.id_client, s.date, s.id_operation_evenement,
    s.lot_1, s.lot_2, s.lot_3,
    (SELECT COUNT(*)
     FROM prod_cotton_global_0.championnats_sessions_lots l
     WHERE l.id_championnat_session = s.id) AS nb_lots_normalises,
    (SELECT COUNT(*)
     FROM prod_cotton_global_0.championnats_sessions_participations_probables p
     WHERE p.id_championnat_session = s.id) AS nb_participations_probables
FROM prod_cotton_global_0.championnats_sessions s
WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08'
ORDER BY s.id_client, s.date, s.id;

-- Branding de chaque scope applicable au parc. Toutes les lignes, y compris
-- offline ou expirees ; pas de choix automatique par ID ni de filtre de validite.
SELECT b.*
FROM prod_cotton_global_0.general_branding b
WHERE EXISTS (
    SELECT 1
    FROM prod_cotton_global_0.championnats_sessions s
    LEFT JOIN prod_cotton_global_0.clients c ON c.id = s.id_client
    WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08'
      AND (
          (b.id_type_branding = 1 AND b.id_related = s.id)
          OR (b.id_type_branding = 2 AND b.id_related = s.id_operation_evenement
              AND s.id_operation_evenement > 0)
          OR (b.id_type_branding = 3 AND b.id_related = c.id_client_reseau
              AND c.id_client_reseau > 0)
          OR (b.id_type_branding = 3 AND b.id_related = c.id
              AND c.flag_client_reseau_siege = 1)
          OR (b.id_type_branding = 4 AND b.id_related = s.id_client)
      )
)
ORDER BY b.id_type_branding, b.id_related, b.id;
