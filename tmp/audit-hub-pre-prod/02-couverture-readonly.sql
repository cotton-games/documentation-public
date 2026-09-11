-- CONDITION : tables games_hubs et games_hubs_sessions et colonnes confirmees par 00.
-- Si elles sont absentes, ne pas executer : couverture Hub/membership = 0 par absence
-- de table ; les programmations de 01 restent a reprendre. Aucun CREATE ici.
-- Tous les candidats sont comptes, jamais choisis.
SELECT cs.id,cs.id_client,cs.date,cs.id_operation_evenement,cs.id_offre_client,
 cs.flag_configuration_complete,
 (SELECT COUNT(*) FROM games_hubs h WHERE h.id_client=cs.id_client AND h.hub_date=cs.date
   AND h.flag_active=1 AND h.hub_status<>'deleting') AS candidats_php_jour,
 (SELECT COUNT(*) FROM games_hubs h WHERE h.id_client=cs.id_client AND h.hub_date=cs.date
   AND h.flag_active=1
   AND (h.id_operation_evenement=0 OR h.id_operation_evenement=cs.id_operation_evenement))
 AS candidats_sql_backfill,
 (SELECT COUNT(*) FROM games_hubs h WHERE h.id_client=cs.id_client AND h.hub_date=cs.date
   AND h.flag_active=1 AND h.id_operation_evenement=CASE WHEN cs.id_operation_evenement>0 THEN cs.id_operation_evenement ELSE 0 END)
 AS candidats_helper_operation,
 (SELECT COUNT(*) FROM games_hubs h WHERE h.id_client=cs.id_client AND h.hub_date=cs.date
   AND h.flag_active<>1) AS hubs_inactifs_jour,
 (SELECT COUNT(*) FROM games_hubs_sessions m WHERE m.id_session=cs.id AND m.status='active')
 AS memberships_actifs_bruts,
 (SELECT COUNT(*) FROM games_hubs_sessions m JOIN games_hubs h ON h.id=m.id_hub
   WHERE m.id_session=cs.id AND m.status='active' AND h.flag_active=1
     AND h.hub_status<>'deleting') AS memberships_actifs_vers_hub_utilisable,
 (SELECT COUNT(*) FROM games_hubs_sessions m WHERE m.id_session=cs.id AND m.status='inactive')
 AS memberships_inactifs
FROM championnats_sessions cs WHERE cs.flag_session_demo=0 AND cs.date >= '2026-09-08'
ORDER BY cs.id;
-- Repartition 0 / 1 / plusieurs candidats PHP, et nombre de memberships actifs.
SELECT x.candidats_php,x.memberships_actifs,COUNT(*) AS sessions
FROM (SELECT cs.id,
 (SELECT COUNT(*) FROM games_hubs h WHERE h.id_client=cs.id_client AND h.hub_date=cs.date
  AND h.flag_active=1 AND h.hub_status<>'deleting') AS candidats_php,
 (SELECT COUNT(*) FROM games_hubs_sessions m WHERE m.id_session=cs.id AND m.status='active')
 AS memberships_actifs
 FROM championnats_sessions cs WHERE cs.flag_session_demo=0 AND cs.date >= '2026-09-08') x
GROUP BY x.candidats_php,x.memberships_actifs ORDER BY x.candidats_php,x.memberships_actifs;
-- Detail de TOUS les candidats : indispensable a une decision explicite.
SELECT cs.id AS session_id,h.id AS hub_id,h.id_client,h.hub_date,h.context_type,
 h.id_operation_evenement,h.flag_active,h.hub_status,
 (SELECT COUNT(*) FROM games_hubs_sessions m WHERE m.id_hub=h.id AND m.status='active')
 AS memberships_deja_actifs_du_hub
FROM championnats_sessions cs JOIN games_hubs h ON h.id_client=cs.id_client AND h.hub_date=cs.date
WHERE cs.flag_session_demo=0 AND cs.date >= '2026-09-08' ORDER BY cs.id,h.id;
-- Toutes les liaisons futures, y compris orphelines ; les divergences ne sont pas reparees.
SELECT cs.id AS session_id,cs.id_client AS session_client,cs.date AS session_date,
 cs.id_operation_evenement AS session_operation,m.id AS membership_id,m.id_hub,m.status,
 m.membership_source,h.flag_active,h.hub_status,h.id_client AS hub_client,h.hub_date,
 h.id_operation_evenement AS hub_operation,
 (h.id IS NULL) AS hub_absent,
 (h.id IS NOT NULL AND NOT(h.id_client <=> cs.id_client)) AS divergence_client,
 (h.id IS NOT NULL AND NOT(h.hub_date <=> cs.date)) AS divergence_date,
 (h.id IS NOT NULL AND NOT(h.id_operation_evenement <=> cs.id_operation_evenement)) AS divergence_operation
FROM championnats_sessions cs LEFT JOIN games_hubs_sessions m ON m.id_session=cs.id
LEFT JOIN games_hubs h ON h.id=m.id_hub
WHERE cs.flag_session_demo=0 AND cs.date >= '2026-09-08' ORDER BY cs.id,m.id;
SELECT id_session,COUNT(*) AS memberships_actifs FROM games_hubs_sessions
WHERE status='active' GROUP BY id_session HAVING COUNT(*)>1;
SELECT m.id,m.id_session,m.id_hub,m.status,h.flag_active,h.hub_status,
 (cs.id IS NULL) AS session_absente,(h.id IS NULL) AS hub_absent
FROM games_hubs_sessions m LEFT JOIN championnats_sessions cs ON cs.id=m.id_session
LEFT JOIN games_hubs h ON h.id=m.id_hub
WHERE cs.id IS NULL OR h.id IS NULL OR (m.status='active' AND (h.flag_active<>1 OR h.hub_status='deleting'))
ORDER BY m.id;
SELECT id_client,hub_date,context_type,id_operation_evenement,COUNT(*) AS doublons
FROM games_hubs GROUP BY id_client,hub_date,context_type,id_operation_evenement HAVING COUNT(*)>1;
SELECT id_client,hub_date,COUNT(*) AS hubs_actifs_meme_jour
FROM games_hubs WHERE flag_active=1 AND hub_status<>'deleting'
GROUP BY id_client,hub_date HAVING COUNT(*)>1;
-- Cas bloquant : le Hub a deja au moins un lien actif -> reconcile fait early-return.
SELECT cs.id AS session_sans_membership,h.id AS hub_partiellement_lie
FROM championnats_sessions cs JOIN games_hubs h ON h.id_client=cs.id_client AND h.hub_date=cs.date
WHERE cs.flag_session_demo=0 AND cs.date >= '2026-09-08'
AND cs.flag_configuration_complete=1 AND h.flag_active=1 AND h.hub_status<>'deleting'
AND NOT EXISTS (SELECT 1 FROM games_hubs_sessions m WHERE m.id_session=cs.id AND m.status='active')
AND EXISTS (SELECT 1 FROM games_hubs_sessions m WHERE m.id_hub=h.id AND m.status='active')
ORDER BY cs.id,h.id;
-- OPTIONNEL : uniquement si les deux tables de participations sont confirmees.
SELECT cs.id,cs.id_client,cs.date,m.id_hub,
 (SELECT COUNT(*) FROM championnats_sessions_participations_probables p
  WHERE p.id_championnat_session=cs.id) AS probables_historiques,
 (SELECT COUNT(*) FROM games_hubs_participations_probables p
  WHERE p.id_hub=m.id_hub AND p.status='declared') AS probables_hub_declares
FROM championnats_sessions cs LEFT JOIN games_hubs_sessions m ON m.id_session=cs.id AND m.status='active'
WHERE cs.flag_session_demo=0 AND cs.date >= '2026-09-08'
AND EXISTS(SELECT 1 FROM championnats_sessions_participations_probables p WHERE p.id_championnat_session=cs.id)
ORDER BY cs.id,m.id_hub;
