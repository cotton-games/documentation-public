-- A1 moteur SQL
SELECT
  VERSION() AS version_sql,
  @@version_comment AS commentaire_moteur;

-- A2 objets utiles reperes
SELECT
  t.TABLE_NAME AS table_nom,
  t.ENGINE AS moteur,
  t.TABLE_ROWS AS lignes_estimees
FROM INFORMATION_SCHEMA.TABLES t
WHERE t.TABLE_SCHEMA = DATABASE()
  AND t.TABLE_NAME IN (
    'clients',
    'referentiels_clients_typologies',
    'referentiels_clients_types',
    'referentiels_clients_acquisitions_canaux',
    'ecommerce_offres',
    'ecommerce_offres_to_clients',
    'referentiels_offres_clients_etats',
    'referentiels_paiements_frequences',
    'ecommerce_commandes',
    'ecommerce_commandes_lignes',
    'reporting_games_sessions_monthly',
    'reporting_games_players_monthly',
    'reporting_games_sessions_detail',
    'user_feedback_events'
  )
ORDER BY t.TABLE_NAME;

-- A3 colonnes utiles reperes
SELECT
  c.TABLE_NAME AS table_nom,
  c.COLUMN_NAME AS colonne_nom,
  c.COLUMN_TYPE AS colonne_type
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME IN (
    'clients',
    'ecommerce_offres_to_clients',
    'ecommerce_offres',
    'ecommerce_commandes',
    'ecommerce_commandes_lignes',
    'reporting_games_sessions_monthly',
    'reporting_games_players_monthly',
    'user_feedback_events'
  )
ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION;

-- A4 controle periode offres et usage
SELECT
  '2025-09_2026-05' AS periode,
  COUNT(DISTINCT c.id) AS clients_total,
  COUNT(DISTINCT CASE WHEN eotc.id IS NOT NULL THEN c.id END) AS clients_avec_offre_sur_periode,
  COUNT(DISTINCT CASE WHEN eotc.flag_offert = 0 AND eotc.prix_ht > 0 THEN c.id END) AS clients_avec_offre_payante_sur_periode,
  COUNT(DISTINCT CASE WHEN eotc.id_etat IN (3,4) AND eotc.flag_offert = 0 AND eotc.prix_ht > 0 THEN c.id END) AS clients_offre_payante_historique_sur_periode,
  COUNT(DISTINCT CASE WHEN eotc.id_etat = 3 AND eotc.flag_offert = 0 AND eotc.prix_ht > 0 AND eotc.date_debut <= '2026-05-31' AND (eotc.date_fin IS NULL OR eotc.date_fin = '0000-00-00' OR eotc.date_fin >= '2026-05-01') THEN c.id END) AS clients_offre_payante_courante_mai,
  COALESCE(SUM(rgsm.sessions), 0) AS sessions_reporting_sur_periode,
  COALESCE(SUM(rgpm.players), 0) AS joueurs_reporting_sur_periode
FROM clients c
LEFT JOIN ecommerce_offres_to_clients eotc
  ON eotc.id_client = c.id
  AND eotc.date_debut <= '2026-05-31'
  AND (eotc.date_fin IS NULL OR eotc.date_fin = '0000-00-00' OR eotc.date_fin >= '2025-09-01')
LEFT JOIN (
  SELECT id_client, SUM(sessions) AS sessions
  FROM reporting_games_sessions_monthly
  WHERE month_key BETWEEN '2025-09' AND '2026-05'
  GROUP BY id_client
) rgsm ON rgsm.id_client = c.id
LEFT JOIN (
  SELECT id_client, SUM(players) AS players
  FROM reporting_games_players_monthly
  WHERE month_key BETWEEN '2025-09' AND '2026-05'
  GROUP BY id_client
) rgpm ON rgpm.id_client = c.id;

-- B export client mois
SELECT
  m.month_key AS mois_observation,
  c.id AS id_client,
  COALESCE(NULLIF(c.nom_social, ''), NULLIF(c.nom, ''), CONCAT('client ', c.id)) AS nom_client,
  CASE
    WHEN c.flag_client_reseau_siege = 1 OR c.id_client_reseau > 0 THEN 'reseau / affilie'
    WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%particulier%' THEN 'particulier'
    WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%entreprise%' THEN 'entreprise'
    WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%event%' OR c.flag_activite_evenements = 1 THEN 'event'
    WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%chr%' OR c.flag_activite_restauration = 1 THEN 'CHR'
    ELSE 'autre / inconnu'
  END AS segment_client,
  COALESCE(rac.nom, '') AS canal_origine,
  fo.mois_premiere_offre_payante_theorique,
  fo.date_premiere_offre_payante AS date_premiere_offre_payante,
  fr.mois_premiere_facture_reelle,
  fr.date_premiere_facture_reelle,
  (
    SELECT e2.id
    FROM ecommerce_offres_to_clients e2
    WHERE e2.id_client = c.id
      AND e2.date_debut <= LAST_DAY(CONCAT(m.month_key, '-01'))
      AND (e2.date_fin IS NULL OR e2.date_fin = '0000-00-00' OR e2.date_fin >= CONCAT(m.month_key, '-01'))
    ORDER BY CASE WHEN e2.id_etat = 3 THEN 0 ELSE 1 END, e2.date_debut DESC, e2.id DESC
    LIMIT 1
  ) AS id_offre_client_active_ou_reference,
  (
    SELECT COALESCE(rot.nom, eo.nom, '')
    FROM ecommerce_offres_to_clients e2
    LEFT JOIN ecommerce_offres eo ON eo.id = e2.id_offre
    LEFT JOIN referentiels_offres_types rot ON rot.id = eo.id_offre_type
    WHERE e2.id_client = c.id
      AND e2.date_debut <= LAST_DAY(CONCAT(m.month_key, '-01'))
      AND (e2.date_fin IS NULL OR e2.date_fin = '0000-00-00' OR e2.date_fin >= CONCAT(m.month_key, '-01'))
    ORDER BY CASE WHEN e2.id_etat = 3 THEN 0 ELSE 1 END, e2.date_debut DESC, e2.id DESC
    LIMIT 1
  ) AS type_offre,
  (
    SELECT COALESCE(roce.nom, CONCAT('etat ', e2.id_etat))
    FROM ecommerce_offres_to_clients e2
    LEFT JOIN referentiels_offres_clients_etats roce ON roce.id = e2.id_etat
    WHERE e2.id_client = c.id
      AND e2.date_debut <= LAST_DAY(CONCAT(m.month_key, '-01'))
      AND (e2.date_fin IS NULL OR e2.date_fin = '0000-00-00' OR e2.date_fin >= CONCAT(m.month_key, '-01'))
    ORDER BY CASE WHEN e2.id_etat = 3 THEN 0 ELSE 1 END, e2.date_debut DESC, e2.id DESC
    LIMIT 1
  ) AS statut_offre_courant,
  CASE WHEN COALESCE(cur.mrr_ht_mois, 0) > 0 THEN 1 ELSE 0 END AS actif_payant_historique_mois,
  CASE WHEN COALESCE(curmay.mrr_ht_mois, 0) > 0 THEN 1 ELSE 0 END AS actif_payant_courant_mai,
  CASE WHEN fo.mois_premiere_offre_payante_theorique = m.month_key THEN 1 ELSE 0 END AS nouveau_client_offre_theorique_mois,
  CASE WHEN fr.mois_premiere_facture_reelle = m.month_key THEN 1 ELSE 0 END AS nouveau_client_reporting_like_mois,
  CASE WHEN COALESCE(prev.mrr_ht_mois, 0) = 0 AND COALESCE(cur.mrr_ht_mois, 0) > 0 AND fr.date_premiere_facture_reelle < CONCAT(m.month_key, '-01') THEN 1 ELSE 0 END AS reprise_apres_pause_mois,
  CASE WHEN COALESCE(cur.mrr_ht_mois, 0) > COALESCE(prev.mrr_ht_mois, 0) AND fr.date_premiere_facture_reelle < CONCAT(m.month_key, '-01') THEN 1 ELSE 0 END AS cso_expansion_mois,
  CASE WHEN COALESCE(cur.mrr_ht_mois, 0) > 0 THEN 1 ELSE 0 END AS actif_payant_mois,
  COALESCE(cur.mrr_ht_mois, 0) AS mrr_ht_mois,
  COALESCE(init.mrr_ht_initial, 0) AS mrr_ht_initial,
  CASE WHEN COALESCE(prev.mrr_ht_mois, 0) > 0 AND COALESCE(cur.mrr_ht_mois, 0) = 0 THEN 1 ELSE 0 END AS churn_logo_mois,
  CASE WHEN COALESCE(prev.mrr_ht_mois, 0) > COALESCE(cur.mrr_ht_mois, 0) THEN ROUND(COALESCE(prev.mrr_ht_mois, 0) - COALESCE(cur.mrr_ht_mois, 0), 2) ELSE 0 END AS churn_valeur_mois,
  CASE WHEN COALESCE(cur.mrr_ht_mois, 0) > COALESCE(prev.mrr_ht_mois, 0) THEN ROUND(COALESCE(cur.mrr_ht_mois, 0) - COALESCE(prev.mrr_ht_mois, 0), 2) ELSE 0 END AS expansion_mrr_mois,
  CASE WHEN COALESCE(prev.mrr_ht_mois, 0) > COALESCE(cur.mrr_ht_mois, 0) AND COALESCE(cur.mrr_ht_mois, 0) > 0 THEN ROUND(COALESCE(prev.mrr_ht_mois, 0) - COALESCE(cur.mrr_ht_mois, 0), 2) ELSE 0 END AS contraction_mrr_mois,
  COALESCE(sess.sessions, 0) AS nb_sessions_mois,
  COALESCE(usage_raw.sessions_brutes, 0) AS nb_sessions_brutes_mois,
  COALESCE(sess.sessions, 0) AS nb_sessions_significatives_reporting_mois,
  COALESCE(usage_raw.sessions_reelles, 0) AS nb_sessions_reelles_mois,
  COALESCE(usage_raw.sessions_demo, 0) AS nb_sessions_demo_mois,
  COALESCE(usage_raw.sessions_sans_joueur, 0) AS nb_sessions_sans_joueur_mois,
  COALESCE(usage_raw.sessions_incompletes, 0) AS nb_sessions_incompletes_mois,
  COALESCE(usage_raw.sessions_test_ou_techniques, 0) AS nb_sessions_test_ou_techniques_mois,
  COALESCE(play.players, 0) AS nb_joueurs_mois,
  COALESCE(usage_raw.joueurs_bruts, 0) AS nb_joueurs_bruts_mois,
  COALESCE(play.players, 0) AS nb_joueurs_significatifs_reporting_mois,
  ROUND(COALESCE(sess.sessions, 0) / NULLIF(COALESCE(usage_raw.sessions_brutes, 0), 0), 4) AS taux_sessions_significatives_sur_brut,
  TRIM(CONCAT(
    CASE WHEN COALESCE(usage_raw.sessions_brutes, 0) = 0 THEN 'aucune session brute; ' ELSE '' END,
    CASE WHEN COALESCE(usage_raw.sessions_brutes, 0) > 0 AND COALESCE(sess.sessions, 0) = 0 THEN 'usage brut sans session significative reporting; ' ELSE '' END,
    CASE WHEN COALESCE(usage_raw.sessions_demo, 0) > 0 THEN 'demos detectees; ' ELSE '' END,
    CASE WHEN COALESCE(usage_raw.sessions_sans_joueur, 0) > 0 THEN 'sessions sans joueur; ' ELSE '' END,
    CASE WHEN COALESCE(usage_raw.sessions_incompletes, 0) > 0 THEN 'sessions incompletes; ' ELSE '' END,
    CASE WHEN COALESCE(usage_raw.sessions_test_ou_techniques, 0) > 0 THEN 'sessions test/techniques detectees par libelle; ' ELSE '' END
  )) AS commentaire_usage_diagnostic,
  COALESCE(fb_mois.nb_feedbacks_mois, 0) AS nb_feedbacks_mois,
  COALESCE(fb_mois.nb_feedbacks_negatifs_mois, 0) AS nb_feedbacks_negatifs_mois,
  fb_last.dernier_feedback_date,
  fb_last.dernier_feedback_type,
  fb_last.dernier_feedback_note,
  fb_last.dernier_feedback_categorie,
  fb_last.dernier_feedback_message,
  stripe_last.raison_resiliation_stripe,
  stripe_last.date_raison_resiliation_stripe,
  stripe_last.commentaire_resiliation_stripe,
  CASE WHEN COALESCE(prev.mrr_ht_mois, 0) > 0 AND COALESCE(cur.mrr_ht_mois, 0) = 0 AND EXISTS (
    SELECT 1
    FROM user_feedback_events ufe30
    WHERE ufe30.id_client = c.id
      AND ufe30.context_key <> 'stripe_subscription_cancellation'
      AND ufe30.created_at >= DATE_SUB(CONCAT(m.month_key, '-01'), INTERVAL 30 DAY)
      AND ufe30.created_at < DATE_ADD(LAST_DAY(CONCAT(m.month_key, '-01')), INTERVAL 1 DAY)
  ) THEN 1 ELSE 0 END AS feedback_avant_churn_30j,
  CASE WHEN COALESCE(prev.mrr_ht_mois, 0) > 0 AND COALESCE(cur.mrr_ht_mois, 0) = 0 AND EXISTS (
    SELECT 1
    FROM user_feedback_events ufe60
    WHERE ufe60.id_client = c.id
      AND ufe60.context_key <> 'stripe_subscription_cancellation'
      AND ufe60.created_at >= DATE_SUB(CONCAT(m.month_key, '-01'), INTERVAL 60 DAY)
      AND ufe60.created_at < DATE_ADD(LAST_DAY(CONCAT(m.month_key, '-01')), INTERVAL 1 DAY)
  ) THEN 1 ELSE 0 END AS feedback_avant_churn_60j,
  CASE
    WHEN stripe_last.raison_resiliation_stripe IS NOT NULL AND stripe_last.raison_resiliation_stripe <> '' THEN stripe_last.raison_resiliation_stripe
    WHEN COALESCE(fb_mois.nb_feedbacks_negatifs_mois, 0) > 0 THEN COALESCE(fb_last.dernier_feedback_categorie, fb_last.dernier_feedback_note, 'feedback negatif')
    WHEN COALESCE(prev.mrr_ht_mois, 0) > 0 AND COALESCE(cur.mrr_ht_mois, 0) = 0 THEN 'churn sans raison qualitative detectee'
    ELSE ''
  END AS raison_churn_qualitative,
  TRIM(CONCAT(
    CASE WHEN COALESCE(prev.mrr_ht_mois, 0) > 0 AND COALESCE(cur.mrr_ht_mois, 0) = 0 AND stripe_last.raison_resiliation_stripe IS NULL AND COALESCE(fb_mois.nb_feedbacks_mois, 0) = 0 THEN 'churn sans feedback ni raison Stripe dans user_feedback_events; ' ELSE '' END,
    CASE WHEN COALESCE(fb_mois.nb_feedbacks_mois, 0) > 0 THEN 'feedback EC detecte; ' ELSE '' END,
    CASE WHEN stripe_last.raison_resiliation_stripe IS NOT NULL THEN 'raison Stripe detectee; ' ELSE '' END,
    'table user_feedback_events recente, couverture partielle possible'
  )) AS commentaire_feedback_diagnostic,
  (
    SELECT COALESCE(SUM(s2.sessions), 0)
    FROM reporting_games_sessions_monthly s2
    WHERE s2.id_client = c.id
      AND s2.month_key >= fr.mois_premiere_facture_reelle
      AND s2.month_key <= m.month_key
  ) AS nb_sessions_cumulees_depuis_entree,
  (
    SELECT COALESCE(SUM(p2.players), 0)
    FROM reporting_games_players_monthly p2
    WHERE p2.id_client = c.id
      AND p2.month_key >= fr.mois_premiere_facture_reelle
      AND p2.month_key <= m.month_key
  ) AS nb_joueurs_cumules_depuis_entree,
  (
    SELECT TRIM(CONCAT(COALESCE(NULLIF(e2.remise_nom, ''), ''), CASE WHEN COALESCE(e2.remise_pourcentage, 0) > 0 THEN CONCAT(' ', e2.remise_pourcentage, '%') ELSE '' END))
    FROM ecommerce_offres_to_clients e2
    WHERE e2.id_client = c.id
      AND e2.date_debut <= LAST_DAY(CONCAT(m.month_key, '-01'))
      AND (e2.date_fin IS NULL OR e2.date_fin = '0000-00-00' OR e2.date_fin >= CONCAT(m.month_key, '-01'))
    ORDER BY CASE WHEN e2.id_etat = 3 THEN 0 ELSE 1 END, e2.date_debut DESC, e2.id DESC
    LIMIT 1
  ) AS remise_appliquee,
  CASE WHEN EXISTS (
    SELECT 1
    FROM ecommerce_offres_to_clients e3
    WHERE e3.id_client = c.id
      AND e3.date_debut <= LAST_DAY(CONCAT(m.month_key, '-01'))
      AND (e3.date_fin IS NULL OR e3.date_fin = '0000-00-00' OR e3.date_fin >= CONCAT(m.month_key, '-01'))
      AND (e3.flag_offert = 1 OR e3.prix_ht <= 0 OR e3.trial_period_days > 0)
  ) THEN 1 ELSE 0 END AS gratuit_ou_test,
  CASE
    WHEN c.flag_client_reseau_siege = 1 THEN c.id
    WHEN c.id_client_reseau > 0 THEN c.id_client_reseau
    ELSE NULL
  END AS reseau_id,
  TRIM(CONCAT(
    CASE WHEN fo.date_premiere_offre_payante IS NULL THEN 'aucune offre payante detectee; ' ELSE '' END,
    CASE WHEN fr.date_premiere_facture_reelle IS NULL THEN 'aucune facture reelle detectee; ' ELSE '' END,
    CASE WHEN c.flag_sans_commande = 1 THEN 'flag_sans_commande client; ' ELSE '' END,
    CASE WHEN EXISTS (
      SELECT 1 FROM ecommerce_offres_to_clients e4
      WHERE e4.id_client = c.id
        AND e4.date_debut <= LAST_DAY(CONCAT(m.month_key, '-01'))
        AND (e4.date_fin IS NULL OR e4.date_fin = '0000-00-00' OR e4.date_fin >= CONCAT(m.month_key, '-01'))
        AND (e4.id_client_delegation > 0 OR e4.reseau_id_offre_delegation_cible > 0 OR e4.reseau_id_offre_client_support_source > 0)
    ) THEN 'contexte reseau detecte; ' ELSE '' END
  )) AS commentaire_diagnostic
FROM (
  SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL
  SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL
  SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05'
) m
INNER JOIN (
  SELECT
    ec.id_client,
    MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)) AS date_premiere_facture_reelle,
    DATE_FORMAT(MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)), '%Y-%m') AS mois_premiere_facture_reelle
  FROM ecommerce_commandes ec
  WHERE ec.numero_facture <> ''
    AND ec.total_ht > 0
  GROUP BY ec.id_client
) fr ON fr.mois_premiere_facture_reelle <= m.month_key
LEFT JOIN (
  SELECT
    e.id_client,
    MIN(e.date_debut) AS date_premiere_offre_payante,
    DATE_FORMAT(MIN(e.date_debut), '%Y-%m') AS mois_premiere_offre_payante_theorique
  FROM ecommerce_offres_to_clients e
  WHERE e.flag_offert = 0
    AND e.prix_ht > 0
  GROUP BY e.id_client
) fo ON fo.id_client = fr.id_client
INNER JOIN clients c ON c.id = fr.id_client
LEFT JOIN referentiels_clients_typologies rct ON rct.id = c.id_typologie
LEFT JOIN referentiels_clients_types rt ON rt.id = c.id_type
LEFT JOIN referentiels_clients_acquisitions_canaux rac ON rac.id = c.id_acquisition_canal
LEFT JOIN (
  SELECT
    e.id_client,
    x.month_key,
    ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
  FROM ecommerce_offres_to_clients e
  INNER JOIN (
    SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL
    SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL
    SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05'
  ) x ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01'))
    AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
  WHERE e.id_etat IN (3,4)
    AND e.flag_offert = 0
    AND e.prix_ht > 0
  GROUP BY e.id_client, x.month_key
) cur ON cur.id_client = c.id AND cur.month_key = m.month_key
LEFT JOIN (
  SELECT
    e.id_client,
    x.month_key,
    ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
  FROM ecommerce_offres_to_clients e
  INNER JOIN (
    SELECT '2025-08' AS month_key UNION ALL SELECT '2025-09' UNION ALL SELECT '2025-10' UNION ALL
    SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL
    SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04'
  ) x ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01'))
    AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
  WHERE e.id_etat IN (3,4)
    AND e.flag_offert = 0
    AND e.prix_ht > 0
  GROUP BY e.id_client, x.month_key
) prev ON prev.id_client = c.id AND prev.month_key = DATE_FORMAT(DATE_SUB(CONCAT(m.month_key, '-01'), INTERVAL 1 MONTH), '%Y-%m')
LEFT JOIN (
  SELECT
    e.id_client,
    ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
  FROM ecommerce_offres_to_clients e
  WHERE e.id_etat = 3
    AND e.flag_offert = 0
    AND e.prix_ht > 0
    AND e.date_debut <= '2026-05-31'
    AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= '2026-05-01')
  GROUP BY e.id_client
) curmay ON curmay.id_client = c.id
LEFT JOIN (
  SELECT
    f.id_client,
    ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_initial
  FROM (
    SELECT ec.id_client,
      MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)) AS first_date
    FROM ecommerce_commandes ec
    WHERE ec.numero_facture <> ''
      AND ec.total_ht > 0
    GROUP BY ec.id_client
  ) f
  INNER JOIN ecommerce_offres_to_clients e
    ON e.id_client = f.id_client
    AND e.date_debut <= LAST_DAY(f.first_date)
    AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= DATE_FORMAT(f.first_date, '%Y-%m-01'))
    AND e.id_etat IN (3,4)
    AND e.flag_offert = 0
    AND e.prix_ht > 0
  GROUP BY f.id_client
) init ON init.id_client = c.id
LEFT JOIN (
  SELECT id_client, month_key, SUM(sessions) AS sessions
  FROM reporting_games_sessions_monthly
  WHERE month_key BETWEEN '2025-09' AND '2026-05'
  GROUP BY id_client, month_key
) sess ON sess.id_client = c.id AND sess.month_key = m.month_key
LEFT JOIN (
  SELECT id_client, month_key, SUM(players) AS players
  FROM reporting_games_players_monthly
  WHERE month_key BETWEEN '2025-09' AND '2026-05'
  GROUP BY id_client, month_key
) play ON play.id_client = c.id AND play.month_key = m.month_key
LEFT JOIN (
  SELECT
    u.month_key,
    u.id_client,
    COUNT(*) AS sessions_brutes,
    SUM(CASE WHEN u.flag_session_demo = 0 THEN 1 ELSE 0 END) AS sessions_reelles,
    SUM(CASE WHEN u.flag_session_demo = 1 THEN 1 ELSE 0 END) AS sessions_demo,
    SUM(CASE WHEN u.players_count = 0 THEN 1 ELSE 0 END) AS sessions_sans_joueur,
    SUM(CASE WHEN u.flag_configuration_complete <> 1 THEN 1 ELSE 0 END) AS sessions_incompletes,
    SUM(CASE WHEN LOWER(CONCAT(u.nom, ' ', u.nom_court, ' ', u.code_session)) LIKE '%test%' OR LOWER(CONCAT(u.nom, ' ', u.nom_court, ' ', u.code_session)) LIKE '%tech%' THEN 1 ELSE 0 END) AS sessions_test_ou_techniques,
    SUM(u.players_count) AS joueurs_bruts
  FROM (
    SELECT
      DATE_FORMAT(cs.date, '%Y-%m') AS month_key,
      cs.id_client,
      cs.flag_session_demo,
      cs.flag_configuration_complete,
      cs.nom,
      cs.nom_court,
      cs.code_session,
      COALESCE(tp.team_players, 0) + COALESCE(bp.bingo_players, 0) + COALESCE(bt.bt_players, 0) + COALESCE(qz.quiz_players, 0) AS players_count
    FROM championnats_sessions cs
    LEFT JOIN (SELECT etcs.id_championnat_session AS session_pk, COUNT(DISTINCT ej.id) AS team_players FROM equipes_to_championnats_sessions etcs INNER JOIN equipes_joueurs ej ON ej.id = etcs.id_equipe GROUP BY etcs.id_championnat_session) tp ON tp.session_pk = cs.id
    LEFT JOIN (SELECT session_id, COUNT(DISTINCT id) AS bingo_players FROM bingo_players GROUP BY session_id) bp ON bp.session_id = cs.id_securite
    LEFT JOIN (SELECT bs.session_id, COUNT(DISTINCT btp.id) AS bt_players FROM blindtest_sessions bs INNER JOIN blindtest_players btp ON btp.session_id = bs.id GROUP BY bs.session_id) bt ON bt.session_id = cs.id_securite
    LEFT JOIN (SELECT cqs.session_id, COUNT(DISTINCT cqp.id) AS quiz_players FROM cotton_quiz_sessions cqs INNER JOIN cotton_quiz_players cqp ON cqp.session_id = cqs.id GROUP BY cqs.session_id) qz ON qz.session_id = cs.id_securite
    WHERE cs.date BETWEEN '2025-09-01' AND '2026-05-31'
  ) u
  GROUP BY u.month_key, u.id_client
) usage_raw ON usage_raw.id_client = c.id AND usage_raw.month_key = m.month_key
LEFT JOIN (
  SELECT
    id_client,
    DATE_FORMAT(created_at, '%Y-%m') AS month_key,
    COUNT(*) AS nb_feedbacks_mois,
    SUM(CASE WHEN rating_value IN ('no', 'improve') THEN 1 ELSE 0 END) AS nb_feedbacks_negatifs_mois
  FROM user_feedback_events
  WHERE context_key <> 'stripe_subscription_cancellation'
    AND created_at BETWEEN '2025-09-01' AND '2026-05-31 23:59:59'
  GROUP BY id_client, DATE_FORMAT(created_at, '%Y-%m')
) fb_mois ON fb_mois.id_client = c.id AND fb_mois.month_key = m.month_key
LEFT JOIN (
  SELECT
    f.id_client,
    last_ids.month_key,
    f.created_at AS dernier_feedback_date,
    f.context_key AS dernier_feedback_type,
    f.rating_label AS dernier_feedback_note,
    f.tags_json AS dernier_feedback_categorie,
    f.comment AS dernier_feedback_message
  FROM (
    SELECT id_client, DATE_FORMAT(created_at, '%Y-%m') AS month_key, MAX(id_feedback) AS id_feedback
    FROM user_feedback_events
    WHERE context_key <> 'stripe_subscription_cancellation'
      AND created_at BETWEEN '2025-09-01' AND '2026-05-31 23:59:59'
    GROUP BY id_client, DATE_FORMAT(created_at, '%Y-%m')
  ) last_ids
  INNER JOIN user_feedback_events f ON f.id_feedback = last_ids.id_feedback
) fb_last ON fb_last.id_client = c.id AND fb_last.month_key = m.month_key
LEFT JOIN (
  SELECT
    s.id_client,
    stripe_ids.month_key,
    s.rating_label AS raison_resiliation_stripe,
    CASE WHEN s.tags_json LIKE '%"cancellation_effective_at":"%' THEN SUBSTRING_INDEX(SUBSTRING_INDEX(s.tags_json, '"cancellation_effective_at":"', -1), '"', 1) ELSE s.created_at END AS date_raison_resiliation_stripe,
    s.comment AS commentaire_resiliation_stripe
  FROM (
    SELECT id_client, DATE_FORMAT(created_at, '%Y-%m') AS month_key, MAX(id_feedback) AS id_feedback
    FROM user_feedback_events
    WHERE context_key = 'stripe_subscription_cancellation'
      AND created_at BETWEEN '2025-09-01' AND '2026-05-31 23:59:59'
    GROUP BY id_client, DATE_FORMAT(created_at, '%Y-%m')
  ) stripe_ids
  INNER JOIN user_feedback_events s ON s.id_feedback = stripe_ids.id_feedback
) stripe_last ON stripe_last.id_client = c.id AND stripe_last.month_key = m.month_key
ORDER BY m.month_key, c.id;

-- C agregation cohortes
SELECT
  coh.mois_premiere_facture_reelle,
  COUNT(DISTINCT coh.id_client) AS clients_entres,
  ROUND(SUM(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 0 THEN coh.mrr_initial ELSE 0 END), 2) AS mrr_initial_cohorte,
  COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 0 AND act.mrr_ht_mois > 0 THEN coh.id_client END) AS clients_actifs_M0,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' THEN COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 1 AND act.mrr_ht_mois > 0 THEN coh.id_client END) ELSE NULL END AS clients_actifs_M1,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 2 MONTH) <= '2026-05-01' THEN COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 2 AND act.mrr_ht_mois > 0 THEN coh.id_client END) ELSE NULL END AS clients_actifs_M2,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' THEN COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 3 AND act.mrr_ht_mois > 0 THEN coh.id_client END) ELSE NULL END AS clients_actifs_M3,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 6 MONTH) <= '2026-05-01' THEN COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 6 AND act.mrr_ht_mois > 0 THEN coh.id_client END) ELSE NULL END AS clients_actifs_M6,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' THEN ROUND(COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 1 AND act.mrr_ht_mois > 0 THEN coh.id_client END) / COUNT(DISTINCT coh.id_client), 4) ELSE NULL END AS retention_logo_M1,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 2 MONTH) <= '2026-05-01' THEN ROUND(COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 2 AND act.mrr_ht_mois > 0 THEN coh.id_client END) / COUNT(DISTINCT coh.id_client), 4) ELSE NULL END AS retention_logo_M2,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' THEN ROUND(COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 3 AND act.mrr_ht_mois > 0 THEN coh.id_client END) / COUNT(DISTINCT coh.id_client), 4) ELSE NULL END AS retention_logo_M3,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 6 MONTH) <= '2026-05-01' THEN ROUND(COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 6 AND act.mrr_ht_mois > 0 THEN coh.id_client END) / COUNT(DISTINCT coh.id_client), 4) ELSE NULL END AS retention_logo_M6,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' THEN ROUND(SUM(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 1 THEN act.mrr_ht_mois ELSE 0 END), 2) ELSE NULL END AS mrr_restant_M1,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 2 MONTH) <= '2026-05-01' THEN ROUND(SUM(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 2 THEN act.mrr_ht_mois ELSE 0 END), 2) ELSE NULL END AS mrr_restant_M2,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' THEN ROUND(SUM(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 3 THEN act.mrr_ht_mois ELSE 0 END), 2) ELSE NULL END AS mrr_restant_M3,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 6 MONTH) <= '2026-05-01' THEN ROUND(SUM(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 6 THEN act.mrr_ht_mois ELSE 0 END), 2) ELSE NULL END AS mrr_restant_M6,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' THEN ROUND(SUM(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 1 THEN act.mrr_ht_mois ELSE 0 END) / NULLIF(SUM(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 0 THEN coh.mrr_initial ELSE 0 END), 0), 4) ELSE NULL END AS retention_mrr_M1,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 2 MONTH) <= '2026-05-01' THEN ROUND(SUM(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 2 THEN act.mrr_ht_mois ELSE 0 END) / NULLIF(SUM(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 0 THEN coh.mrr_initial ELSE 0 END), 0), 4) ELSE NULL END AS retention_mrr_M2,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' THEN ROUND(SUM(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 3 THEN act.mrr_ht_mois ELSE 0 END) / NULLIF(SUM(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 0 THEN coh.mrr_initial ELSE 0 END), 0), 4) ELSE NULL END AS retention_mrr_M3,
  CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 6 MONTH) <= '2026-05-01' THEN ROUND(SUM(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 6 THEN act.mrr_ht_mois ELSE 0 END) / NULLIF(SUM(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 0 THEN coh.mrr_initial ELSE 0 END), 0), 4) ELSE NULL END AS retention_mrr_M6,
  ROUND(AVG(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 0 THEN act.sessions_mois END), 2) AS sessions_moyennes_M0,
  ROUND(AVG(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 1 THEN act.sessions_mois END), 2) AS sessions_moyennes_M1,
  ROUND(AVG(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 2 THEN act.sessions_mois END), 2) AS sessions_moyennes_M2,
  ROUND(AVG(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 0 THEN act.sessions_brutes_mois END), 2) AS sessions_brutes_moyennes_M0,
  ROUND(AVG(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 1 THEN act.sessions_brutes_mois END), 2) AS sessions_brutes_moyennes_M1,
  ROUND(AVG(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 2 THEN act.sessions_brutes_mois END), 2) AS sessions_brutes_moyennes_M2,
  ROUND(AVG(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 0 THEN act.sessions_mois END), 2) AS sessions_significatives_moyennes_M0,
  ROUND(AVG(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 1 THEN act.sessions_mois END), 2) AS sessions_significatives_moyennes_M1,
  ROUND(AVG(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 2 THEN act.sessions_mois END), 2) AS sessions_significatives_moyennes_M2,
  ROUND(COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 0 AND act.sessions_mois > 0 THEN coh.id_client END) / COUNT(DISTINCT coh.id_client), 4) AS part_clients_avec_session_significative_M0,
  ROUND(COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 1 AND act.sessions_mois > 0 THEN coh.id_client END) / COUNT(DISTINCT coh.id_client), 4) AS part_clients_avec_session_significative_M1,
  ROUND(COUNT(DISTINCT CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 2 AND act.sessions_mois > 0 THEN coh.id_client END) / COUNT(DISTINCT coh.id_client), 4) AS part_clients_avec_session_significative_M2,
  ROUND(AVG(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 0 THEN act.joueurs_mois END), 2) AS joueurs_moyens_M0,
  ROUND(AVG(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 1 THEN act.joueurs_mois END), 2) AS joueurs_moyens_M1,
  ROUND(AVG(CASE WHEN TIMESTAMPDIFF(MONTH, CONCAT(coh.mois_premiere_facture_reelle, '-01'), CONCAT(act.month_key, '-01')) = 2 THEN act.joueurs_mois END), 2) AS joueurs_moyens_M2
FROM (
  SELECT fr.id_client, fr.mois_premiere_facture_reelle, COALESCE(init.mrr_ht_mois, 0) AS mrr_initial
  FROM (
    SELECT ec.id_client,
      MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)) AS date_premiere_facture_reelle,
      DATE_FORMAT(MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)), '%Y-%m') AS mois_premiere_facture_reelle
    FROM ecommerce_commandes ec
    WHERE ec.numero_facture <> '' AND ec.total_ht > 0
    GROUP BY ec.id_client
  ) fr
  LEFT JOIN (
    SELECT e.id_client, x.month_key, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
    FROM ecommerce_offres_to_clients e
    INNER JOIN (SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') x
      ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
    WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
    GROUP BY e.id_client, x.month_key
  ) init ON init.id_client = fr.id_client AND init.month_key = fr.mois_premiere_facture_reelle
  WHERE fr.date_premiere_facture_reelle >= '2025-09-01'
    AND fr.date_premiere_facture_reelle < '2026-06-01'
) coh
LEFT JOIN (
  SELECT m.month_key, c.id AS id_client,
    COALESCE(mrr.mrr_ht_mois, 0) AS mrr_ht_mois,
    COALESCE(sess.sessions, 0) AS sessions_mois,
    COALESCE(raw.sessions_brutes, 0) AS sessions_brutes_mois,
    COALESCE(play.players, 0) AS joueurs_mois
  FROM (SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') m
  CROSS JOIN clients c
  LEFT JOIN (
    SELECT e.id_client, x.month_key, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
    FROM ecommerce_offres_to_clients e
    INNER JOIN (SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') x
      ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
    WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
    GROUP BY e.id_client, x.month_key
  ) mrr ON mrr.id_client = c.id AND mrr.month_key = m.month_key
  LEFT JOIN (SELECT id_client, month_key, SUM(sessions) AS sessions FROM reporting_games_sessions_monthly WHERE month_key BETWEEN '2025-09' AND '2026-05' GROUP BY id_client, month_key) sess ON sess.id_client = c.id AND sess.month_key = m.month_key
  LEFT JOIN (SELECT id_client, month_key, SUM(players) AS players FROM reporting_games_players_monthly WHERE month_key BETWEEN '2025-09' AND '2026-05' GROUP BY id_client, month_key) play ON play.id_client = c.id AND play.month_key = m.month_key
  LEFT JOIN (SELECT DATE_FORMAT(date, '%Y-%m') AS month_key, id_client, COUNT(*) AS sessions_brutes FROM championnats_sessions WHERE date BETWEEN '2025-09-01' AND '2026-05-31' GROUP BY DATE_FORMAT(date, '%Y-%m'), id_client) raw ON raw.id_client = c.id AND raw.month_key = m.month_key
) act ON act.id_client = coh.id_client AND act.month_key >= coh.mois_premiere_facture_reelle
GROUP BY coh.mois_premiere_facture_reelle
ORDER BY coh.mois_premiere_facture_reelle;

-- D usage entree et retention
SELECT
  CASE
    WHEN COALESCE(m0.sessions_brutes_mois, 0) = 0 THEN '0 session brute'
    WHEN COALESCE(m0.sessions_brutes_mois, 0) > 0 AND COALESCE(m0.sessions_mois, 0) = 0 THEN 'brut > 0 mais 0 session significative'
    WHEN COALESCE(m0.sessions_mois, 0) = 1 THEN '1 session significative'
    WHEN COALESCE(m0.sessions_mois, 0) BETWEEN 2 AND 3 THEN '2 a 3 sessions significatives'
    ELSE '4+ sessions significatives'
  END AS groupe_usage_mois_premiere_facture,
  COUNT(DISTINCT coh.id_client) AS clients_total_groupe,
  COUNT(DISTINCT CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' THEN coh.id_client END) AS clients_observables_M1,
  COUNT(DISTINCT CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' AND m1.mrr_ht_mois > 0 THEN coh.id_client END) AS clients_actifs_M1,
  COUNT(DISTINCT CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' THEN coh.id_client END) AS clients_observables_M3,
  COUNT(DISTINCT CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' AND m3.mrr_ht_mois > 0 THEN coh.id_client END) AS clients_actifs_M3,
  ROUND(SUM(coh.mrr_initial), 2) AS mrr_initial_total_groupe,
  ROUND(SUM(CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' THEN coh.mrr_initial ELSE 0 END), 2) AS mrr_initial_observable_M1,
  ROUND(SUM(CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' THEN COALESCE(m1.mrr_ht_mois, 0) ELSE 0 END), 2) AS mrr_restant_M1,
  ROUND(SUM(CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' THEN coh.mrr_initial ELSE 0 END), 2) AS mrr_initial_observable_M3,
  ROUND(SUM(CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' THEN COALESCE(m3.mrr_ht_mois, 0) ELSE 0 END), 2) AS mrr_restant_M3,
  CASE WHEN COUNT(DISTINCT CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' THEN coh.id_client END) > 0 THEN ROUND(COUNT(DISTINCT CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' AND m1.mrr_ht_mois > 0 THEN coh.id_client END) / COUNT(DISTINCT CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' THEN coh.id_client END), 4) ELSE NULL END AS retention_logo_M1,
  CASE WHEN COUNT(DISTINCT CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' THEN coh.id_client END) > 0 THEN ROUND(COUNT(DISTINCT CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' AND m3.mrr_ht_mois > 0 THEN coh.id_client END) / COUNT(DISTINCT CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' THEN coh.id_client END), 4) ELSE NULL END AS retention_logo_M3,
  CASE WHEN SUM(CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' THEN coh.mrr_initial ELSE 0 END) > 0 THEN ROUND(SUM(CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' THEN COALESCE(m1.mrr_ht_mois, 0) ELSE 0 END) / SUM(CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH) <= '2026-05-01' THEN coh.mrr_initial ELSE 0 END), 4) ELSE NULL END AS retention_mrr_M1,
  CASE WHEN SUM(CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' THEN coh.mrr_initial ELSE 0 END) > 0 THEN ROUND(SUM(CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' THEN COALESCE(m3.mrr_ht_mois, 0) ELSE 0 END) / SUM(CASE WHEN DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH) <= '2026-05-01' THEN coh.mrr_initial ELSE 0 END), 4) ELSE NULL END AS retention_mrr_M3,
  ROUND(AVG(coh.mrr_initial), 2) AS MRR_moyen,
  ROUND(AVG(COALESCE(m0.sessions_brutes_mois, 0)), 2) AS sessions_brutes_moyennes,
  ROUND(AVG(COALESCE(m0.sessions_mois, 0)), 2) AS sessions_significatives_moyennes,
  ROUND(AVG(COALESCE(m0.joueurs_mois, 0)), 2) AS joueurs_moyens
FROM (
  SELECT fr.id_client, fr.mois_premiere_facture_reelle, COALESCE(init.mrr_ht_mois, 0) AS mrr_initial
  FROM (
    SELECT ec.id_client,
      MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)) AS date_premiere_facture_reelle,
      DATE_FORMAT(MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)), '%Y-%m') AS mois_premiere_facture_reelle
    FROM ecommerce_commandes ec
    WHERE ec.numero_facture <> '' AND ec.total_ht > 0
    GROUP BY ec.id_client
  ) fr
  LEFT JOIN (
    SELECT e.id_client, x.month_key, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
    FROM ecommerce_offres_to_clients e
    INNER JOIN (SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') x
      ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
    WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
    GROUP BY e.id_client, x.month_key
  ) init ON init.id_client = fr.id_client AND init.month_key = fr.mois_premiere_facture_reelle
  WHERE fr.date_premiere_facture_reelle >= '2025-09-01'
    AND fr.date_premiere_facture_reelle < '2026-06-01'
) coh
LEFT JOIN (SELECT id_client, month_key, SUM(sessions) AS sessions_mois FROM reporting_games_sessions_monthly WHERE month_key BETWEEN '2025-09' AND '2026-05' GROUP BY id_client, month_key) s0 ON s0.id_client = coh.id_client AND s0.month_key = coh.mois_premiere_facture_reelle
LEFT JOIN (SELECT id_client, month_key, SUM(players) AS joueurs_mois FROM reporting_games_players_monthly WHERE month_key BETWEEN '2025-09' AND '2026-05' GROUP BY id_client, month_key) p0 ON p0.id_client = coh.id_client AND p0.month_key = coh.mois_premiere_facture_reelle
LEFT JOIN (
  SELECT c.id_client, c.mois_premiere_facture_reelle, COALESCE(raw.sessions_brutes_mois, 0) AS sessions_brutes_mois, COALESCE(s.sessions_mois, 0) AS sessions_mois, COALESCE(p.joueurs_mois, 0) AS joueurs_mois
  FROM (
    SELECT ec.id_client, DATE_FORMAT(MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)), '%Y-%m') AS mois_premiere_facture_reelle
    FROM ecommerce_commandes ec
    WHERE ec.numero_facture <> '' AND ec.total_ht > 0
    GROUP BY ec.id_client
  ) c
  LEFT JOIN (SELECT id_client, DATE_FORMAT(date, '%Y-%m') AS month_key, COUNT(*) AS sessions_brutes_mois FROM championnats_sessions GROUP BY id_client, DATE_FORMAT(date, '%Y-%m')) raw ON raw.id_client = c.id_client AND raw.month_key = c.mois_premiere_facture_reelle
  LEFT JOIN (SELECT id_client, month_key, SUM(sessions) AS sessions_mois FROM reporting_games_sessions_monthly GROUP BY id_client, month_key) s ON s.id_client = c.id_client AND s.month_key = c.mois_premiere_facture_reelle
  LEFT JOIN (SELECT id_client, month_key, SUM(players) AS joueurs_mois FROM reporting_games_players_monthly GROUP BY id_client, month_key) p ON p.id_client = c.id_client AND p.month_key = c.mois_premiere_facture_reelle
) m0 ON m0.id_client = coh.id_client
LEFT JOIN (
  SELECT e.id_client, x.month_key, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
  FROM ecommerce_offres_to_clients e
  INNER JOIN (SELECT '2025-10' AS month_key UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') x
    ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
  WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
  GROUP BY e.id_client, x.month_key
) m1 ON m1.id_client = coh.id_client AND m1.month_key = DATE_FORMAT(DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 1 MONTH), '%Y-%m')
LEFT JOIN (
  SELECT e.id_client, x.month_key, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
  FROM ecommerce_offres_to_clients e
  INNER JOIN (SELECT '2025-12' AS month_key UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') x
    ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
  WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
  GROUP BY e.id_client, x.month_key
) m3 ON m3.id_client = coh.id_client AND m3.month_key = DATE_FORMAT(DATE_ADD(CONCAT(coh.mois_premiere_facture_reelle, '-01'), INTERVAL 3 MONTH), '%Y-%m')
GROUP BY groupe_usage_mois_premiere_facture
ORDER BY CASE groupe_usage_mois_premiere_facture WHEN '0 session brute' THEN 1 WHEN 'brut > 0 mais 0 session significative' THEN 2 WHEN '1 session significative' THEN 3 WHEN '2 a 3 sessions significatives' THEN 4 ELSE 5 END;

-- E segment
SELECT
  seg.segment_client,
  COUNT(DISTINCT CASE WHEN first_invoice.mois_premiere_facture_reelle BETWEEN '2025-09' AND '2026-05' THEN seg.id_client END) AS nouveaux_clients_reporting_like,
  COUNT(DISTINCT CASE WHEN pause.id_client IS NOT NULL THEN seg.id_client END) AS reprises_cso,
  COUNT(DISTINCT CASE WHEN maym.mrr_ht_mois > 0 THEN seg.id_client END) AS parc_actif_courant_mai,
  ROUND(SUM(COALESCE(maym.mrr_ht_mois, 0)), 2) AS MRR_courant_mai,
  ROUND(SUM(CASE WHEN histcur.mrr_ht_mois > COALESCE(histprev.mrr_ht_mois, 0) AND first_invoice.date_premiere_facture_reelle < '2025-09-01' THEN histcur.mrr_ht_mois - COALESCE(histprev.mrr_ht_mois, 0) ELSE 0 END), 2) AS expansion_mrr,
  COUNT(DISTINCT CASE WHEN histprev.mrr_ht_mois > 0 AND COALESCE(histcur.mrr_ht_mois, 0) = 0 THEN seg.id_client END) AS churn_logo_historique,
  ROUND(SUM(CASE WHEN histprev.mrr_ht_mois > COALESCE(histcur.mrr_ht_mois, 0) THEN histprev.mrr_ht_mois - COALESCE(histcur.mrr_ht_mois, 0) ELSE 0 END), 2) AS churn_valeur_historique,
  COALESCE(SUM(raw.sessions_brutes), 0) AS sessions_brutes,
  COALESCE(SUM(s.sessions), 0) AS sessions_significatives_reporting_segment_perimetre,
  COALESCE(SUM(raw.sessions_reelles), 0) AS sessions_reelles,
  COALESCE(SUM(raw.sessions_demo), 0) AS sessions_demo,
  COALESCE(SUM(raw.sessions_sans_joueur), 0) AS sessions_sans_joueur,
  COALESCE(SUM(raw.sessions_incompletes), 0) AS sessions_incompletes,
  COALESCE(SUM(raw.sessions_test_ou_techniques), 0) AS sessions_test_ou_techniques,
  COALESCE(SUM(raw.joueurs_bruts), 0) AS joueurs_bruts,
  COALESCE(SUM(p.players), 0) AS joueurs_significatifs_reporting_segment_perimetre,
  ROUND(SUM(COALESCE(maym.mrr_ht_mois, 0)) / NULLIF(COUNT(DISTINCT CASE WHEN maym.mrr_ht_mois > 0 THEN seg.id_client END), 0), 2) AS ARPA,
  ROUND(COALESCE(SUM(s.sessions), 0) / NULLIF(COUNT(DISTINCT CASE WHEN maym.mrr_ht_mois > 0 THEN seg.id_client END), 0), 2) AS sessions_par_client_actif
FROM (
  SELECT c.id AS id_client,
    CASE
      WHEN c.flag_client_reseau_siege = 1 OR c.id_client_reseau > 0 THEN 'reseau / affilie'
      WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%particulier%' THEN 'particulier'
      WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%entreprise%' THEN 'entreprise'
      WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%event%' OR c.flag_activite_evenements = 1 THEN 'event'
      WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%chr%' OR c.flag_activite_restauration = 1 THEN 'CHR'
      ELSE 'autre / inconnu'
    END AS segment_client
  FROM clients c
  LEFT JOIN referentiels_clients_typologies rct ON rct.id = c.id_typologie
  LEFT JOIN referentiels_clients_types rt ON rt.id = c.id_type
  WHERE EXISTS (SELECT 1 FROM ecommerce_offres_to_clients e WHERE e.id_client = c.id AND e.flag_offert = 0 AND e.prix_ht > 0 AND e.date_debut <= '2026-05-31')
     OR EXISTS (SELECT 1 FROM ecommerce_commandes ec WHERE ec.id_client = c.id AND ec.numero_facture <> '' AND ec.total_ht > 0)
) seg
LEFT JOIN (
  SELECT ec.id_client,
    MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)) AS date_premiere_facture_reelle,
    DATE_FORMAT(MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)), '%Y-%m') AS mois_premiere_facture_reelle
  FROM ecommerce_commandes ec
  WHERE ec.numero_facture <> '' AND ec.total_ht > 0
  GROUP BY ec.id_client
) first_invoice ON first_invoice.id_client = seg.id_client
LEFT JOIN (
  SELECT DISTINCT cur.id_client
  FROM (
    SELECT e.id_client, x.month_key
    FROM ecommerce_offres_to_clients e
    INNER JOIN (SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') x
      ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
    WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
    GROUP BY e.id_client, x.month_key
  ) cur
  LEFT JOIN (
    SELECT e.id_client, x.month_key
    FROM ecommerce_offres_to_clients e
    INNER JOIN (SELECT '2025-08' AS month_key UNION ALL SELECT '2025-09' UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04') x
      ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
    WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
    GROUP BY e.id_client, x.month_key
  ) prev ON prev.id_client = cur.id_client AND prev.month_key = DATE_FORMAT(DATE_SUB(CONCAT(cur.month_key, '-01'), INTERVAL 1 MONTH), '%Y-%m')
  INNER JOIN (
    SELECT ec.id_client, MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)) AS first_date
    FROM ecommerce_commandes ec
    WHERE ec.numero_facture <> '' AND ec.total_ht > 0
    GROUP BY ec.id_client
  ) fi ON fi.id_client = cur.id_client AND fi.first_date < CONCAT(cur.month_key, '-01')
  WHERE prev.id_client IS NULL
) pause ON pause.id_client = seg.id_client
LEFT JOIN (
  SELECT e.id_client, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
  FROM ecommerce_offres_to_clients e
  WHERE e.id_etat = 3 AND e.flag_offert = 0 AND e.prix_ht > 0 AND e.date_debut <= '2026-05-31' AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= '2026-05-01')
  GROUP BY e.id_client
) maym ON maym.id_client = seg.id_client
LEFT JOIN (
  SELECT e.id_client, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
  FROM ecommerce_offres_to_clients e
  WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0 AND e.date_debut <= '2026-05-31' AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= '2026-05-01')
  GROUP BY e.id_client
) histcur ON histcur.id_client = seg.id_client
LEFT JOIN (
  SELECT e.id_client, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
  FROM ecommerce_offres_to_clients e
  WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0 AND e.date_debut <= '2026-04-30' AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= '2026-04-01')
  GROUP BY e.id_client
) histprev ON histprev.id_client = seg.id_client
LEFT JOIN (SELECT id_client, SUM(sessions) AS sessions FROM reporting_games_sessions_monthly WHERE month_key BETWEEN '2025-09' AND '2026-05' GROUP BY id_client) s ON s.id_client = seg.id_client
LEFT JOIN (SELECT id_client, SUM(players) AS players FROM reporting_games_players_monthly WHERE month_key BETWEEN '2025-09' AND '2026-05' GROUP BY id_client) p ON p.id_client = seg.id_client
LEFT JOIN (
  SELECT u.id_client, COUNT(*) AS sessions_brutes, SUM(CASE WHEN u.flag_session_demo = 0 THEN 1 ELSE 0 END) AS sessions_reelles, SUM(CASE WHEN u.flag_session_demo = 1 THEN 1 ELSE 0 END) AS sessions_demo, SUM(CASE WHEN u.players_count = 0 THEN 1 ELSE 0 END) AS sessions_sans_joueur, SUM(CASE WHEN u.flag_configuration_complete <> 1 THEN 1 ELSE 0 END) AS sessions_incompletes, SUM(CASE WHEN LOWER(CONCAT(u.nom, ' ', u.nom_court, ' ', u.code_session)) LIKE '%test%' OR LOWER(CONCAT(u.nom, ' ', u.nom_court, ' ', u.code_session)) LIKE '%tech%' THEN 1 ELSE 0 END) AS sessions_test_ou_techniques, SUM(u.players_count) AS joueurs_bruts
  FROM (
    SELECT cs.id_client, cs.flag_session_demo, cs.flag_configuration_complete, cs.nom, cs.nom_court, cs.code_session, COALESCE(tp.team_players, 0) + COALESCE(bp.bingo_players, 0) + COALESCE(bt.bt_players, 0) + COALESCE(qz.quiz_players, 0) AS players_count
    FROM championnats_sessions cs
    LEFT JOIN (SELECT etcs.id_championnat_session AS session_pk, COUNT(DISTINCT ej.id) AS team_players FROM equipes_to_championnats_sessions etcs INNER JOIN equipes_joueurs ej ON ej.id = etcs.id_equipe GROUP BY etcs.id_championnat_session) tp ON tp.session_pk = cs.id
    LEFT JOIN (SELECT session_id, COUNT(DISTINCT id) AS bingo_players FROM bingo_players GROUP BY session_id) bp ON bp.session_id = cs.id_securite
    LEFT JOIN (SELECT bs.session_id, COUNT(DISTINCT btp.id) AS bt_players FROM blindtest_sessions bs INNER JOIN blindtest_players btp ON btp.session_id = bs.id GROUP BY bs.session_id) bt ON bt.session_id = cs.id_securite
    LEFT JOIN (SELECT cqs.session_id, COUNT(DISTINCT cqp.id) AS quiz_players FROM cotton_quiz_sessions cqs INNER JOIN cotton_quiz_players cqp ON cqp.session_id = cqs.id GROUP BY cqs.session_id) qz ON qz.session_id = cs.id_securite
    WHERE cs.date BETWEEN '2025-09-01' AND '2026-05-31'
  ) u
  GROUP BY u.id_client
) raw ON raw.id_client = seg.id_client
GROUP BY seg.segment_client
ORDER BY seg.segment_client;

-- F rapprochement mai 2026
SELECT
  'mai_2026_courant' AS periode_controle,
  (SELECT COUNT(DISTINCT e.id_client) FROM ecommerce_offres_to_clients e WHERE e.id_etat = 3 AND e.flag_offert = 0 AND e.prix_ht > 0 AND e.date_debut <= '2026-05-31' AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= '2026-05-01')) AS clients_actifs_courant_mai_extrait,
  85 AS clients_actifs_courant_mai_reporting,
  (SELECT ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) FROM ecommerce_offres_to_clients e WHERE e.id_etat = 3 AND e.flag_offert = 0 AND e.prix_ht > 0 AND e.date_debut <= '2026-05-31' AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= '2026-05-01')) AS MRR_courant_mai_extrait,
  5800 AS MRR_courant_mai_reporting_approx,
  NULL AS nouveaux_clients_offre_theorique_cumul,
  NULL AS nouveaux_clients_reporting_like_cumul,
  NULL AS nouveaux_clients_reporting,
  NULL AS reprises_cso_cumul,
  NULL AS expansion_mrr_cumul,
  COALESCE((SELECT COUNT(*) FROM championnats_sessions cs WHERE cs.date BETWEEN '2026-05-01' AND '2026-05-31'), 0) AS sessions_brutes,
  COALESCE((SELECT SUM(sessions) FROM reporting_games_sessions_monthly WHERE month_key = '2026-05'), 0) AS sessions_significatives_reporting_periode_global,
  NULL AS sessions_reporting_attendu,
  COALESCE((SELECT SUM(u.players_count) FROM (SELECT cs.id_client, COALESCE(tp.team_players, 0) + COALESCE(bp.bingo_players, 0) + COALESCE(bt.bt_players, 0) + COALESCE(qz.quiz_players, 0) AS players_count FROM championnats_sessions cs LEFT JOIN (SELECT etcs.id_championnat_session AS session_pk, COUNT(DISTINCT ej.id) AS team_players FROM equipes_to_championnats_sessions etcs INNER JOIN equipes_joueurs ej ON ej.id = etcs.id_equipe GROUP BY etcs.id_championnat_session) tp ON tp.session_pk = cs.id LEFT JOIN (SELECT session_id, COUNT(DISTINCT id) AS bingo_players FROM bingo_players GROUP BY session_id) bp ON bp.session_id = cs.id_securite LEFT JOIN (SELECT bs.session_id, COUNT(DISTINCT btp.id) AS bt_players FROM blindtest_sessions bs INNER JOIN blindtest_players btp ON btp.session_id = bs.id GROUP BY bs.session_id) bt ON bt.session_id = cs.id_securite LEFT JOIN (SELECT cqs.session_id, COUNT(DISTINCT cqp.id) AS quiz_players FROM cotton_quiz_sessions cqs INNER JOIN cotton_quiz_players cqp ON cqp.session_id = cqs.id GROUP BY cqs.session_id) qz ON qz.session_id = cs.id_securite WHERE cs.date BETWEEN '2026-05-01' AND '2026-05-31') u), 0) AS joueurs_bruts,
  COALESCE((SELECT SUM(players) FROM reporting_games_players_monthly WHERE month_key = '2026-05'), 0) AS joueurs_significatifs_reporting_periode_global,
  NULL AS joueurs_reporting_attendu,
  'mai courant: compare uniquement clients actifs et MRR au repere mensuel; nouveaux clients, sessions et joueurs sont controles en cumul exercice' AS commentaire
UNION ALL
SELECT
  'cumul_2025_09_2026_05' AS periode_controle,
  NULL AS clients_actifs_courant_mai_extrait,
  NULL AS clients_actifs_courant_mai_reporting,
  NULL AS MRR_courant_mai_extrait,
  NULL AS MRR_courant_mai_reporting_approx,
  (SELECT COUNT(DISTINCT firstp.id_client) FROM (SELECT id_client, DATE_FORMAT(MIN(date_debut), '%Y-%m') AS first_month FROM ecommerce_offres_to_clients WHERE flag_offert = 0 AND prix_ht > 0 GROUP BY id_client) firstp WHERE firstp.first_month BETWEEN '2025-09' AND '2026-05') AS nouveaux_clients_offre_theorique_cumul,
  (SELECT COUNT(DISTINCT firsti.id_client) FROM (SELECT ec.id_client, DATE_FORMAT(MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)), '%Y-%m') AS first_invoice_month FROM ecommerce_commandes ec WHERE ec.numero_facture <> '' AND ec.total_ht > 0 GROUP BY ec.id_client) firsti WHERE firsti.first_invoice_month BETWEEN '2025-09' AND '2026-05') AS nouveaux_clients_reporting_like_cumul,
  74 AS nouveaux_clients_reporting,
  (SELECT COUNT(DISTINCT cur.id_client) FROM (SELECT e.id_client, x.month_key FROM ecommerce_offres_to_clients e INNER JOIN (SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') x ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01')) WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0 GROUP BY e.id_client, x.month_key) cur LEFT JOIN (SELECT e.id_client, x.month_key FROM ecommerce_offres_to_clients e INNER JOIN (SELECT '2025-08' AS month_key UNION ALL SELECT '2025-09' UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04') x ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01')) WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0 GROUP BY e.id_client, x.month_key) prev ON prev.id_client = cur.id_client AND prev.month_key = DATE_FORMAT(DATE_SUB(CONCAT(cur.month_key, '-01'), INTERVAL 1 MONTH), '%Y-%m') INNER JOIN (SELECT ec.id_client, MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)) AS first_date FROM ecommerce_commandes ec WHERE ec.numero_facture <> '' AND ec.total_ht > 0 GROUP BY ec.id_client) fi ON fi.id_client = cur.id_client AND fi.first_date < CONCAT(cur.month_key, '-01') WHERE prev.id_client IS NULL) AS reprises_cso_cumul,
  (SELECT ROUND(SUM(CASE WHEN cur.mrr_ht_mois > COALESCE(prev.mrr_ht_mois, 0) AND fi.first_date < CONCAT(cur.month_key, '-01') THEN cur.mrr_ht_mois - COALESCE(prev.mrr_ht_mois, 0) ELSE 0 END), 2) FROM (SELECT e.id_client, x.month_key, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois FROM ecommerce_offres_to_clients e INNER JOIN (SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') x ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01')) WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0 GROUP BY e.id_client, x.month_key) cur LEFT JOIN (SELECT e.id_client, x.month_key, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois FROM ecommerce_offres_to_clients e INNER JOIN (SELECT '2025-08' AS month_key UNION ALL SELECT '2025-09' UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04') x ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01')) WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0 GROUP BY e.id_client, x.month_key) prev ON prev.id_client = cur.id_client AND prev.month_key = DATE_FORMAT(DATE_SUB(CONCAT(cur.month_key, '-01'), INTERVAL 1 MONTH), '%Y-%m') INNER JOIN (SELECT ec.id_client, MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)) AS first_date FROM ecommerce_commandes ec WHERE ec.numero_facture <> '' AND ec.total_ht > 0 GROUP BY ec.id_client) fi ON fi.id_client = cur.id_client) AS expansion_mrr_cumul,
  COALESCE((SELECT COUNT(*) FROM championnats_sessions cs WHERE cs.date BETWEEN '2025-09-01' AND '2026-05-31'), 0) AS sessions_brutes,
  COALESCE((SELECT SUM(sessions) FROM reporting_games_sessions_monthly WHERE month_key BETWEEN '2025-09' AND '2026-05'), 0) AS sessions_significatives_reporting_periode_global,
  2956 AS sessions_reporting_attendu,
  COALESCE((SELECT SUM(u.players_count) FROM (SELECT cs.id_client, COALESCE(tp.team_players, 0) + COALESCE(bp.bingo_players, 0) + COALESCE(bt.bt_players, 0) + COALESCE(qz.quiz_players, 0) AS players_count FROM championnats_sessions cs LEFT JOIN (SELECT etcs.id_championnat_session AS session_pk, COUNT(DISTINCT ej.id) AS team_players FROM equipes_to_championnats_sessions etcs INNER JOIN equipes_joueurs ej ON ej.id = etcs.id_equipe GROUP BY etcs.id_championnat_session) tp ON tp.session_pk = cs.id LEFT JOIN (SELECT session_id, COUNT(DISTINCT id) AS bingo_players FROM bingo_players GROUP BY session_id) bp ON bp.session_id = cs.id_securite LEFT JOIN (SELECT bs.session_id, COUNT(DISTINCT btp.id) AS bt_players FROM blindtest_sessions bs INNER JOIN blindtest_players btp ON btp.session_id = bs.id GROUP BY bs.session_id) bt ON bt.session_id = cs.id_securite LEFT JOIN (SELECT cqs.session_id, COUNT(DISTINCT cqp.id) AS quiz_players FROM cotton_quiz_sessions cqs INNER JOIN cotton_quiz_players cqp ON cqp.session_id = cqs.id GROUP BY cqs.session_id) qz ON qz.session_id = cs.id_securite WHERE cs.date BETWEEN '2025-09-01' AND '2026-05-31') u), 0) AS joueurs_bruts,
  COALESCE((SELECT SUM(players) FROM reporting_games_players_monthly WHERE month_key BETWEEN '2025-09' AND '2026-05'), 0) AS joueurs_significatifs_reporting_periode_global,
  34445 AS joueurs_reporting_attendu,
  'cumul exercice: 74 nouveaux clients, 2956 sessions et 34445 joueurs compares au cumul; nouveaux clients bases sur premiere facture reelle numero_facture non vide et total HT positif' AS commentaire;

-- H diagnostic nouveaux clients reporting-like vs repere 74
SELECT
  c.id AS id_client,
  COALESCE(NULLIF(c.nom_social, ''), NULLIF(c.nom, ''), CONCAT('client ', c.id)) AS nom_client,
  fi.mois_premiere_facture_reelle,
  fi.date_premiere_facture_reelle,
  ec.numero_facture,
  ec.total_ht AS total_ht_facture_initiale,
  ec.id AS id_commande,
  ec.id_etat AS id_etat_commande,
  ec.id_offre_client,
  eo.id_offre_type,
  COALESCE(rot.nom, '') AS typologie_offre,
  c.id_etat AS id_etat_client,
  eotc.id_etat AS id_etat_offre,
  eotc.flag_offert,
  eotc.prix_ht,
  eotc.id_paiement_frequence,
  CASE
    WHEN c.flag_client_reseau_siege = 1 OR c.id_client_reseau > 0 THEN 'reseau / affilie'
    WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%particulier%' THEN 'particulier'
    WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%entreprise%' THEN 'entreprise'
    WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%event%' OR c.flag_activite_evenements = 1 THEN 'event'
    WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%chr%' OR c.flag_activite_restauration = 1 THEN 'CHR'
    ELSE 'autre / inconnu'
  END AS segment_detecte,
  c.flag_client_reseau_siege,
  c.id_client_reseau,
  eotc.id_client_delegation,
  eotc.reseau_id_offre_delegation_cible,
  eotc.reseau_id_offre_client_support_source,
  TRIM(CONCAT(
    CASE WHEN c.id_etat = 4 THEN 'client archive; ' ELSE '' END,
    CASE WHEN c.flag_sans_commande = 1 THEN 'flag_sans_commande client; ' ELSE '' END,
    CASE WHEN eo.id_offre_type IS NULL THEN 'offre introuvable; ' ELSE '' END,
    CASE WHEN eo.id_offre_type IS NOT NULL AND eo.id_offre_type <> 2 THEN 'type offre potentiellement hors abonnement SaaS; ' ELSE '' END,
    CASE WHEN eotc.id_etat IS NULL THEN 'commande sans offre client rattachee; ' ELSE '' END,
    CASE WHEN eotc.id_etat IS NOT NULL AND eotc.id_etat NOT IN (3,4) THEN 'etat offre hors actif/termine historique; ' ELSE '' END,
    CASE WHEN eotc.flag_offert = 1 THEN 'offre marquee offerte malgre facture; ' ELSE '' END,
    CASE WHEN eotc.id_client_delegation > 0 OR eotc.reseau_id_offre_delegation_cible > 0 OR eotc.reseau_id_offre_client_support_source > 0 OR c.flag_client_reseau_siege = 1 OR c.id_client_reseau > 0 THEN 'contexte reseau ou delegation; ' ELSE '' END,
    CASE WHEN ec.id_etat IS NOT NULL AND ec.id_etat <> 2 THEN 'etat commande a verifier; ' ELSE '' END
  )) AS commentaire_diagnostic
FROM (
  SELECT
    ec.id_client,
    MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)) AS date_premiere_facture_reelle,
    DATE_FORMAT(MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)), '%Y-%m') AS mois_premiere_facture_reelle
  FROM ecommerce_commandes ec
  WHERE ec.numero_facture <> ''
    AND ec.total_ht > 0
  GROUP BY ec.id_client
) fi
INNER JOIN ecommerce_commandes ec
  ON ec.id_client = fi.id_client
  AND ec.numero_facture <> ''
  AND ec.total_ht > 0
  AND IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture) = fi.date_premiere_facture_reelle
  AND ec.id = (
    SELECT MIN(ec2.id)
    FROM ecommerce_commandes ec2
    WHERE ec2.id_client = fi.id_client
      AND ec2.numero_facture <> ''
      AND ec2.total_ht > 0
      AND IF(ec2.date_facture IS NULL OR ec2.date_facture = '' OR ec2.date_facture = '0000-00-00' OR ec2.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec2.annee, '-', LPAD(ec2.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec2.date_facture) = fi.date_premiere_facture_reelle
  )
INNER JOIN clients c ON c.id = fi.id_client
LEFT JOIN ecommerce_offres_to_clients eotc ON eotc.id = ec.id_offre_client
LEFT JOIN ecommerce_offres eo ON eo.id = eotc.id_offre
LEFT JOIN referentiels_offres_types rot ON rot.id = eo.id_offre_type
LEFT JOIN referentiels_clients_typologies rct ON rct.id = c.id_typologie
LEFT JOIN referentiels_clients_types rt ON rt.id = c.id_type
WHERE fi.date_premiere_facture_reelle >= '2025-09-01'
  AND fi.date_premiere_facture_reelle < '2026-06-01'
ORDER BY fi.date_premiere_facture_reelle, c.id;

-- G feedbacks et churn qualitatif
SELECT
  'clients_avec_feedback' AS indicateur,
  'tous_feedbacks_non_stripe' AS groupe,
  COUNT(DISTINCT id_client) AS valeur_1,
  NULL AS valeur_2,
  NULL AS valeur_3,
  '' AS commentaire
FROM user_feedback_events
WHERE context_key <> 'stripe_subscription_cancellation'
  AND created_at BETWEEN '2025-09-01' AND '2026-05-31 23:59:59'
UNION ALL
SELECT
  'clients_churnes_avec_feedback_avant_churn_60j' AS indicateur,
  'feedback_non_stripe' AS groupe,
  COUNT(DISTINCT churns.id_client) AS valeur_1,
  NULL AS valeur_2,
  NULL AS valeur_3,
  'churn logo mensuel: M-1 payant, M courant non payant' AS commentaire
FROM (
  SELECT curm.month_key, curm.id_client, COALESCE(prevm.mrr_ht_mois, 0) AS prev_mrr, COALESCE(curm.mrr_ht_mois, 0) AS cur_mrr
  FROM (
    SELECT m.month_key, c.id AS id_client, COALESCE(mrr.mrr_ht_mois, 0) AS mrr_ht_mois
    FROM (SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') m
    CROSS JOIN clients c
    LEFT JOIN (
      SELECT e.id_client, x.month_key, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
      FROM ecommerce_offres_to_clients e
      INNER JOIN (SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') x
        ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
      WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
      GROUP BY e.id_client, x.month_key
    ) mrr ON mrr.id_client = c.id AND mrr.month_key = m.month_key
  ) curm
  LEFT JOIN (
    SELECT e.id_client, x.month_key, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
    FROM ecommerce_offres_to_clients e
    INNER JOIN (SELECT '2025-08' AS month_key UNION ALL SELECT '2025-09' UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04') x
      ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
    WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
    GROUP BY e.id_client, x.month_key
  ) prevm ON prevm.id_client = curm.id_client AND prevm.month_key = DATE_FORMAT(DATE_SUB(CONCAT(curm.month_key, '-01'), INTERVAL 1 MONTH), '%Y-%m')
) churns
WHERE churns.prev_mrr > 0 AND churns.cur_mrr = 0
  AND EXISTS (
    SELECT 1 FROM user_feedback_events ufe
    WHERE ufe.id_client = churns.id_client
      AND ufe.context_key <> 'stripe_subscription_cancellation'
      AND ufe.created_at >= DATE_SUB(CONCAT(churns.month_key, '-01'), INTERVAL 60 DAY)
      AND ufe.created_at < DATE_ADD(LAST_DAY(CONCAT(churns.month_key, '-01')), INTERVAL 1 DAY)
  )
UNION ALL
SELECT
  'repartition_raisons_stripe' AS indicateur,
  COALESCE(NULLIF(rating_label, ''), NULLIF(rating_value, ''), 'non renseigne') AS groupe,
  COUNT(*) AS valeur_1,
  COUNT(DISTINCT id_client) AS valeur_2,
  NULL AS valeur_3,
  'context_key=stripe_subscription_cancellation' AS commentaire
FROM user_feedback_events
WHERE context_key = 'stripe_subscription_cancellation'
  AND created_at BETWEEN '2025-09-01' AND '2026-05-31 23:59:59'
GROUP BY COALESCE(NULLIF(rating_label, ''), NULLIF(rating_value, ''), 'non renseigne')
UNION ALL
SELECT
  'resiliations_stripe_cycle_client' AS indicateur,
  CASE
    WHEN fi.first_invoice_month = DATE_FORMAT(ufe.created_at, '%Y-%m') THEN 'client_nouveau_reporting_like'
    WHEN pause.id_client IS NOT NULL THEN 'reprise_cso_detectee'
    WHEN fi.first_invoice_date < CONCAT(DATE_FORMAT(ufe.created_at, '%Y-%m'), '-01') THEN 'client_ancien_deja_facture'
    ELSE 'cycle_inconnu'
  END AS groupe,
  COUNT(*) AS valeur_1,
  COUNT(DISTINCT ufe.id_client) AS valeur_2,
  NULL AS valeur_3,
  'classement qualitatif des resiliations Stripe selon premiere facture reelle et reprise CSO' AS commentaire
FROM user_feedback_events ufe
LEFT JOIN (
  SELECT ec.id_client,
    MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)) AS first_invoice_date,
    DATE_FORMAT(MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)), '%Y-%m') AS first_invoice_month
  FROM ecommerce_commandes ec
  WHERE ec.numero_facture <> '' AND ec.total_ht > 0
  GROUP BY ec.id_client
) fi ON fi.id_client = ufe.id_client
LEFT JOIN (
  SELECT DISTINCT cur.id_client
  FROM (
    SELECT e.id_client, x.month_key
    FROM ecommerce_offres_to_clients e
    INNER JOIN (SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') x
      ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
    WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
    GROUP BY e.id_client, x.month_key
  ) cur
  LEFT JOIN (
    SELECT e.id_client, x.month_key
    FROM ecommerce_offres_to_clients e
    INNER JOIN (SELECT '2025-08' AS month_key UNION ALL SELECT '2025-09' UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04') x
      ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
    WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
    GROUP BY e.id_client, x.month_key
  ) prev ON prev.id_client = cur.id_client AND prev.month_key = DATE_FORMAT(DATE_SUB(CONCAT(cur.month_key, '-01'), INTERVAL 1 MONTH), '%Y-%m')
  INNER JOIN (
    SELECT ec.id_client, MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)) AS first_date
    FROM ecommerce_commandes ec
    WHERE ec.numero_facture <> '' AND ec.total_ht > 0
    GROUP BY ec.id_client
  ) first_invoice ON first_invoice.id_client = cur.id_client AND first_invoice.first_date < CONCAT(cur.month_key, '-01')
  WHERE prev.id_client IS NULL
) pause ON pause.id_client = ufe.id_client
WHERE ufe.context_key = 'stripe_subscription_cancellation'
  AND ufe.created_at BETWEEN '2025-09-01' AND '2026-05-31 23:59:59'
GROUP BY CASE
    WHEN fi.first_invoice_month = DATE_FORMAT(ufe.created_at, '%Y-%m') THEN 'client_nouveau_reporting_like'
    WHEN pause.id_client IS NOT NULL THEN 'reprise_cso_detectee'
    WHEN fi.first_invoice_date < CONCAT(DATE_FORMAT(ufe.created_at, '%Y-%m'), '-01') THEN 'client_ancien_deja_facture'
    ELSE 'cycle_inconnu'
  END
UNION ALL
SELECT
  'repartition_categories_feedback' AS indicateur,
  COALESCE(NULLIF(tags_json, ''), 'sans categorie') AS groupe,
  COUNT(*) AS valeur_1,
  COUNT(DISTINCT id_client) AS valeur_2,
  NULL AS valeur_3,
  'categories stockees dans tags_json, souvent tableau JSON cote espace client' AS commentaire
FROM user_feedback_events
WHERE context_key <> 'stripe_subscription_cancellation'
  AND created_at BETWEEN '2025-09-01' AND '2026-05-31 23:59:59'
GROUP BY COALESCE(NULLIF(tags_json, ''), 'sans categorie')
UNION ALL
SELECT
  'retention_feedback_vs_sans_feedback' AS indicateur,
  CASE WHEN fb.id_client IS NOT NULL THEN 'avec_feedback' ELSE 'sans_feedback' END AS groupe,
  ROUND(COUNT(DISTINCT CASE WHEN m1.mrr_ht_mois > 0 THEN coh.id_client END) / COUNT(DISTINCT coh.id_client), 4) AS valeur_1,
  ROUND(COUNT(DISTINCT CASE WHEN m3.mrr_ht_mois > 0 THEN coh.id_client END) / COUNT(DISTINCT coh.id_client), 4) AS valeur_2,
  COUNT(DISTINCT coh.id_client) AS valeur_3,
  'valeur_1=retention M+1, valeur_2=retention M+3, valeur_3=clients cohorte' AS commentaire
FROM (
  SELECT ec.id_client,
    DATE_FORMAT(MIN(IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture)), '%Y-%m') AS mois_entree_payante
  FROM ecommerce_commandes ec
  WHERE ec.numero_facture <> '' AND ec.total_ht > 0
  GROUP BY id_client
  HAVING mois_entree_payante BETWEEN '2025-09' AND '2026-05'
) coh
LEFT JOIN (SELECT DISTINCT id_client FROM user_feedback_events WHERE context_key <> 'stripe_subscription_cancellation' AND created_at BETWEEN '2025-09-01' AND '2026-05-31 23:59:59') fb ON fb.id_client = coh.id_client
LEFT JOIN (
  SELECT e.id_client, x.month_key, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
  FROM ecommerce_offres_to_clients e
  INNER JOIN (SELECT '2025-10' AS month_key UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') x
    ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
  WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
  GROUP BY e.id_client, x.month_key
) m1 ON m1.id_client = coh.id_client AND m1.month_key = DATE_FORMAT(DATE_ADD(CONCAT(coh.mois_entree_payante, '-01'), INTERVAL 1 MONTH), '%Y-%m')
LEFT JOIN (
  SELECT e.id_client, x.month_key, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
  FROM ecommerce_offres_to_clients e
  INNER JOIN (SELECT '2025-12' AS month_key UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') x
    ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
  WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
  GROUP BY e.id_client, x.month_key
) m3 ON m3.id_client = coh.id_client AND m3.month_key = DATE_FORMAT(DATE_ADD(CONCAT(coh.mois_entree_payante, '-01'), INTERVAL 3 MONTH), '%Y-%m')
GROUP BY CASE WHEN fb.id_client IS NOT NULL THEN 'avec_feedback' ELSE 'sans_feedback' END
UNION ALL
SELECT
  'churn_logo_feedback_negatif_vs_autres' AS indicateur,
  CASE WHEN neg.id_client IS NOT NULL THEN 'feedback_negatif' ELSE 'autres_clients' END AS groupe,
  COUNT(DISTINCT CASE WHEN churns.prev_mrr > 0 AND churns.cur_mrr = 0 THEN churns.id_client END) AS valeur_1,
  COUNT(DISTINCT churns.id_client) AS valeur_2,
  ROUND(COUNT(DISTINCT CASE WHEN churns.prev_mrr > 0 AND churns.cur_mrr = 0 THEN churns.id_client END) / COUNT(DISTINCT churns.id_client), 4) AS valeur_3,
  'valeur_1=clients churn logo, valeur_2=clients observes, valeur_3=taux' AS commentaire
FROM (
  SELECT curm.month_key, curm.id_client, COALESCE(prevm.mrr_ht_mois, 0) AS prev_mrr, COALESCE(curm.mrr_ht_mois, 0) AS cur_mrr
  FROM (
    SELECT m.month_key, c.id AS id_client, COALESCE(mrr.mrr_ht_mois, 0) AS mrr_ht_mois
    FROM (SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') m
    CROSS JOIN clients c
    LEFT JOIN (
      SELECT e.id_client, x.month_key, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
      FROM ecommerce_offres_to_clients e
      INNER JOIN (SELECT '2025-09' AS month_key UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04' UNION ALL SELECT '2026-05') x
        ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
      WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
      GROUP BY e.id_client, x.month_key
    ) mrr ON mrr.id_client = c.id AND mrr.month_key = m.month_key
  ) curm
  LEFT JOIN (
    SELECT e.id_client, x.month_key, ROUND(SUM(CASE WHEN e.id_paiement_frequence = 2 THEN e.prix_ht / 12 ELSE e.prix_ht END), 2) AS mrr_ht_mois
    FROM ecommerce_offres_to_clients e
    INNER JOIN (SELECT '2025-08' AS month_key UNION ALL SELECT '2025-09' UNION ALL SELECT '2025-10' UNION ALL SELECT '2025-11' UNION ALL SELECT '2025-12' UNION ALL SELECT '2026-01' UNION ALL SELECT '2026-02' UNION ALL SELECT '2026-03' UNION ALL SELECT '2026-04') x
      ON e.date_debut <= LAST_DAY(CONCAT(x.month_key, '-01')) AND (e.date_fin IS NULL OR e.date_fin = '0000-00-00' OR e.date_fin >= CONCAT(x.month_key, '-01'))
    WHERE e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0
    GROUP BY e.id_client, x.month_key
  ) prevm ON prevm.id_client = curm.id_client AND prevm.month_key = DATE_FORMAT(DATE_SUB(CONCAT(curm.month_key, '-01'), INTERVAL 1 MONTH), '%Y-%m')
) churns
LEFT JOIN (SELECT DISTINCT id_client FROM user_feedback_events WHERE context_key <> 'stripe_subscription_cancellation' AND rating_value IN ('no', 'improve') AND created_at BETWEEN '2025-09-01' AND '2026-05-31 23:59:59') neg ON neg.id_client = churns.id_client
WHERE churns.prev_mrr > 0 OR churns.cur_mrr > 0
GROUP BY CASE WHEN neg.id_client IS NOT NULL THEN 'feedback_negatif' ELSE 'autres_clients' END
UNION ALL
SELECT
  'usage_moyen_feedback_vs_sans_feedback' AS indicateur,
  CASE WHEN fb.id_client IS NOT NULL THEN 'avec_feedback' ELSE 'sans_feedback' END AS groupe,
  ROUND(AVG(COALESCE(s.sessions, 0)), 2) AS valeur_1,
  ROUND(AVG(COALESCE(raw.sessions_brutes, 0)), 2) AS valeur_2,
  ROUND(AVG(COALESCE(p.players, 0)), 2) AS valeur_3,
  'valeur_1=sessions significatives moyennes, valeur_2=sessions brutes moyennes, valeur_3=joueurs significatifs moyens' AS commentaire
FROM clients c
LEFT JOIN (SELECT DISTINCT id_client FROM user_feedback_events WHERE context_key <> 'stripe_subscription_cancellation' AND created_at BETWEEN '2025-09-01' AND '2026-05-31 23:59:59') fb ON fb.id_client = c.id
LEFT JOIN (SELECT id_client, SUM(sessions) AS sessions FROM reporting_games_sessions_monthly WHERE month_key BETWEEN '2025-09' AND '2026-05' GROUP BY id_client) s ON s.id_client = c.id
LEFT JOIN (SELECT id_client, SUM(players) AS players FROM reporting_games_players_monthly WHERE month_key BETWEEN '2025-09' AND '2026-05' GROUP BY id_client) p ON p.id_client = c.id
LEFT JOIN (SELECT id_client, COUNT(*) AS sessions_brutes FROM championnats_sessions WHERE date BETWEEN '2025-09-01' AND '2026-05-31' GROUP BY id_client) raw ON raw.id_client = c.id
WHERE EXISTS (SELECT 1 FROM ecommerce_offres_to_clients e WHERE e.id_client = c.id AND e.flag_offert = 0 AND e.prix_ht > 0 AND e.date_debut <= '2026-05-31')
GROUP BY CASE WHEN fb.id_client IS NOT NULL THEN 'avec_feedback' ELSE 'sans_feedback' END
UNION ALL
SELECT
  'top_messages_feedback' AS indicateur,
  CONCAT(COALESCE(NULLIF(tags_json, ''), 'sans categorie'), ' | ', LEFT(COALESCE(comment, ''), 180)) AS groupe,
  COUNT(*) AS valeur_1,
  COUNT(DISTINCT id_client) AS valeur_2,
  NULL AS valeur_3,
  'messages non vides a lire manuellement' AS commentaire
FROM user_feedback_events
WHERE context_key <> 'stripe_subscription_cancellation'
  AND comment IS NOT NULL
  AND comment <> ''
  AND created_at BETWEEN '2025-09-01' AND '2026-05-31 23:59:59'
GROUP BY CONCAT(COALESCE(NULLIF(tags_json, ''), 'sans categorie'), ' | ', LEFT(COALESCE(comment, ''), 180))
ORDER BY indicateur, valeur_1 DESC, groupe;

-- J essais gratuits CHR/reseaux et conversion facture
SELECT
  tr.id_client,
  tr.nom_client,
  tr.segment_detecte,
  tr.est_chr,
  tr.est_reseau_affilie,
  tr.id_offre_client,
  tr.id_offre_type,
  tr.typologie_offre,
  tr.id_etat_client,
  tr.id_etat_offre,
  tr.statut_offre_courant,
  tr.date_debut_essai,
  tr.mois_debut_essai,
  tr.date_fin_offre,
  tr.date_fin_essai_calculee,
  CASE
    WHEN tr.date_fin_essai_calculee IS NULL THEN 'date_fin_absente_a_revoir'
    WHEN tr.id_etat_offre = 4 OR tr.date_fin_essai_calculee <= '2026-05-31' THEN 'essai_termine_selon_dates'
    ELSE 'essai_en_cours_selon_dates'
  END AS etat_temporel_essai_selon_dates,
  tr.trial_period_days,
  tr.flag_offert,
  tr.prix_ht,
  tr.id_paiement_frequence,
  tr.commentaire_detection_essai,
  CASE WHEN tr.eligible_bo_avant_dedoublonnage = 1 AND tr.id_offre_client = tr.id_offre_client_reporting_bo THEN 1 ELSE 0 END AS inclus_reporting_bo_essai_gratuit,
  CASE
    WHEN tr.eligible_bo_avant_dedoublonnage = 1 AND tr.id_offre_client = tr.id_offre_client_reporting_bo THEN 'inclus_bo'
    WHEN tr.eligible_bo_avant_dedoublonnage = 1 AND tr.id_offre_client <> tr.id_offre_client_reporting_bo THEN 'hors_bo_offre_multiple_meme_client'
    WHEN tr.est_chr = 0 AND tr.est_reseau_affilie = 0 THEN 'hors_bo_client_non_chr_reseau'
    WHEN tr.date_debut_essai < '2025-09-01' OR tr.date_debut_essai >= '2026-06-01' THEN 'hors_bo_date_hors_periode'
    WHEN tr.id_offre_type <> 2 OR tr.id_offre_type IS NULL THEN 'hors_bo_offre_gratuite_non_trial'
    WHEN tr.id_etat_offre NOT IN (3,4) THEN 'hors_bo_statut_non_retenu'
    WHEN tr.facture_meme_jour_essai = 1 THEN 'hors_bo_facture_meme_jour'
    WHEN tr.trial_period_days <= 0 AND tr.flag_offert = 1 THEN 'hors_bo_offre_gratuite_non_trial'
    WHEN tr.trial_period_days <= 0 AND tr.prix_ht <= 0 THEN 'hors_bo_prix_nul_ou_offert_ambigu'
    WHEN tr.flag_offert = 1 OR tr.prix_ht <= 0 THEN 'hors_bo_prix_nul_ou_offert_ambigu'
    WHEN tr.est_deja_facture_avant_essai = 1 THEN 'hors_bo_reactivation_cso'
    ELSE 'hors_bo_autre_a_revoir'
  END AS motif_ecart_reporting_bo,
  CASE WHEN conv.date_premiere_facture_reelle_apres_essai IS NOT NULL THEN 1 ELSE 0 END AS converti_facture_reelle,
  CASE WHEN conv.date_premiere_facture_reelle_apres_essai IS NOT NULL THEN 1 ELSE 0 END AS a_facture_reelle_apres_essai,
  conv.date_premiere_facture_reelle_apres_essai,
  DATE_FORMAT(conv.date_premiere_facture_reelle_apres_essai, '%Y-%m') AS mois_premiere_facture_reelle_apres_essai,
  conv.numero_facture,
  conv.total_ht_facture_initiale,
  conv.id_commande,
  CASE WHEN conv.date_premiere_facture_reelle_apres_essai IS NOT NULL THEN DATEDIFF(conv.date_premiere_facture_reelle_apres_essai, tr.date_debut_essai) ELSE NULL END AS delai_jours_essai_vers_facture,
  CASE WHEN conv.date_premiere_facture_reelle_apres_essai IS NOT NULL THEN DATEDIFF(conv.date_premiere_facture_reelle_apres_essai, tr.date_debut_essai) ELSE NULL END AS jours_essai_avant_facture,
  CASE
    WHEN tr.est_deja_facture_avant_essai = 1 AND conv.date_premiere_facture_reelle_apres_essai IS NOT NULL THEN 'reprise_cso_via_essai'
    WHEN pause.date_pause_detectee IS NOT NULL AND conv.date_premiere_facture_reelle_apres_essai IS NOT NULL AND pause.date_pause_detectee >= conv.date_premiere_facture_reelle_apres_essai THEN 'essai_converti_puis_pause'
    WHEN pause.date_pause_detectee IS NOT NULL AND conv.date_premiere_facture_reelle_apres_essai IS NULL THEN 'essai_non_converti_puis_pause'
    WHEN conv.date_premiere_facture_reelle_apres_essai IS NOT NULL THEN 'essai_converti_facture'
    WHEN tr.date_fin_essai_calculee > '2026-05-31' AND tr.id_etat_offre = 3 THEN 'essai_encore_en_cours'
    WHEN tr.trial_period_days = 0 AND tr.flag_offert = 0 AND tr.prix_ht <= 0 THEN 'cas_ambigu'
    ELSE 'essai_non_converti'
  END AS statut_tunnel,
  tr.est_deja_facture_avant_essai,
  CASE WHEN tr.est_deja_facture_avant_essai = 0 THEN 1 ELSE 0 END AS est_nouveau_trial_pur,
  CASE WHEN tr.est_deja_facture_avant_essai = 1 OR tr.a_offre_payante_avant_essai = 1 THEN 1 ELSE 0 END AS est_reactivation_trial,
  COALESCE(usage_essai.nb_sessions_brutes_essai, 0) AS nb_sessions_brutes_essai,
  COALESCE(usage_sig.nb_sessions_significatives_essai, 0) AS nb_sessions_significatives_essai,
  COALESCE(usage_sig.nb_sessions_significatives_essai, 0) AS nb_sessions_significatives_pendant_essai,
  COALESCE(usage_essai.nb_sessions_reelles_essai, 0) AS nb_sessions_reelles_essai,
  COALESCE(usage_essai.nb_sessions_demo_essai, 0) AS nb_sessions_demo_essai,
  COALESCE(usage_essai.nb_sessions_sans_joueur_essai, 0) AS nb_sessions_sans_joueur_essai,
  COALESCE(usage_essai.nb_sessions_incompletes_essai, 0) AS nb_sessions_incompletes_essai,
  COALESCE(usage_essai.nb_joueurs_bruts_essai, 0) AS nb_joueurs_bruts_essai,
  COALESCE(usage_sig.nb_joueurs_significatifs_essai, 0) AS nb_joueurs_significatifs_essai,
  CASE WHEN COALESCE(usage_essai.nb_sessions_brutes_essai, 0) > 0 THEN 1 ELSE 0 END AS a_session_brute_essai,
  CASE WHEN COALESCE(usage_sig.nb_sessions_significatives_essai, 0) > 0 THEN 1 ELSE 0 END AS a_session_significative_essai,
  CASE WHEN COALESCE(usage_sig.nb_sessions_significatives_essai, 0) > 0 THEN 1 ELSE 0 END AS a_session_significative_pendant_essai,
  usage_sig.date_premiere_session_significative_essai,
  CASE WHEN usage_sig.date_premiere_session_significative_essai IS NOT NULL THEN DATEDIFF(usage_sig.date_premiere_session_significative_essai, tr.date_debut_essai) ELSE NULL END AS jours_essai_avant_premiere_session_significative,
  CASE WHEN pause.date_pause_detectee IS NOT NULL AND (conv.date_premiere_facture_reelle_apres_essai IS NULL OR pause.date_pause_detectee < conv.date_premiere_facture_reelle_apres_essai) THEN 1 ELSE 0 END AS a_pause_avant_facture,
  CASE WHEN pause.date_pause_detectee IS NOT NULL AND conv.date_premiere_facture_reelle_apres_essai IS NOT NULL AND pause.date_pause_detectee >= conv.date_premiere_facture_reelle_apres_essai THEN 1 ELSE 0 END AS a_pause_apres_facture,
  pause.date_pause_detectee,
  DATE_FORMAT(pause.date_pause_detectee, '%Y-%m') AS mois_pause_detectee,
  CASE WHEN pause.date_pause_detectee IS NOT NULL THEN DATEDIFF(pause.date_pause_detectee, tr.date_debut_essai) ELSE NULL END AS jours_essai_avant_pause,
  CASE WHEN pause.date_pause_detectee IS NOT NULL AND conv.date_premiere_facture_reelle_apres_essai IS NOT NULL THEN DATEDIFF(pause.date_pause_detectee, conv.date_premiere_facture_reelle_apres_essai) ELSE NULL END AS jours_facture_avant_pause,
  CASE WHEN retour.date_retour_apres_pause IS NOT NULL THEN 1 ELSE 0 END AS est_revenu_apres_pause,
  retour.date_retour_apres_pause,
  CASE WHEN retour.date_retour_apres_pause IS NOT NULL AND pause.date_pause_detectee IS NOT NULL THEN DATEDIFF(retour.date_retour_apres_pause, pause.date_pause_detectee) ELSE NULL END AS jours_pause_avant_retour
FROM (
  SELECT
    c.id AS id_client,
    COALESCE(NULLIF(c.nom_social, ''), NULLIF(c.nom, ''), CONCAT('client ', c.id)) AS nom_client,
    CASE
      WHEN c.flag_client_reseau_siege = 1 OR c.id_client_reseau > 0 OR e.id_client_delegation > 0 OR e.reseau_id_offre_delegation_cible > 0 OR e.reseau_id_offre_client_support_source > 0 THEN 'reseau / affilie'
      WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%chr%' OR c.flag_activite_restauration = 1 THEN 'CHR'
      ELSE 'autre / inconnu'
    END AS segment_detecte,
    CASE WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%chr%' OR c.flag_activite_restauration = 1 THEN 1 ELSE 0 END AS est_chr,
    CASE WHEN c.flag_client_reseau_siege = 1 OR c.id_client_reseau > 0 OR e.id_client_delegation > 0 OR e.reseau_id_offre_delegation_cible > 0 OR e.reseau_id_offre_client_support_source > 0 THEN 1 ELSE 0 END AS est_reseau_affilie,
    e.id AS id_offre_client,
    eo.id_offre_type,
    COALESCE(rot.nom, eo.nom, '') AS typologie_offre,
    c.id_etat AS id_etat_client,
    e.id_etat AS id_etat_offre,
    COALESCE(roce.nom, CONCAT('etat ', e.id_etat)) AS statut_offre_courant,
    e.date_debut AS date_debut_essai,
    DATE_FORMAT(e.date_debut, '%Y-%m') AS mois_debut_essai,
    e.date_fin AS date_fin_offre,
    CASE
      WHEN e.trial_period_days > 0 AND e.trial_period_days = 15 THEN DATE_ADD(e.date_debut, INTERVAL 15 DAY)
      WHEN e.trial_period_days > 0 THEN DATE_ADD(e.date_debut, INTERVAL e.trial_period_days DAY)
      WHEN e.date_fin IS NOT NULL AND e.date_fin <> '0000-00-00' THEN e.date_fin
      ELSE NULL
    END AS date_fin_essai_calculee,
    e.trial_period_days,
    e.flag_offert,
    e.prix_ht,
    e.id_paiement_frequence,
    TRIM(CONCAT(
      CASE WHEN e.trial_period_days > 0 THEN 'trial_period_days explicite; ' ELSE '' END,
      CASE WHEN e.flag_offert = 1 THEN 'flag_offert; ' ELSE '' END,
      CASE WHEN e.prix_ht <= 0 THEN 'prix_ht nul; ' ELSE '' END,
      CASE WHEN e.trial_period_days = 0 AND (e.flag_offert = 1 OR e.prix_ht <= 0) THEN 'cas ambigu a relire; ' ELSE '' END,
      CASE WHEN LOWER(CONCAT(COALESCE(eo.nom, ''), ' ', COALESCE(e.commentaire, ''), ' ', COALESCE(c.nom_social, ''), ' ', COALESCE(c.nom, ''))) LIKE '%test%' OR LOWER(CONCAT(COALESCE(eo.nom, ''), ' ', COALESCE(e.commentaire, ''), ' ', COALESCE(c.nom_social, ''), ' ', COALESCE(c.nom, ''))) LIKE '%tech%' OR LOWER(CONCAT(COALESCE(eo.nom, ''), ' ', COALESCE(e.commentaire, ''), ' ', COALESCE(c.nom_social, ''), ' ', COALESCE(c.nom, ''))) LIKE '%interne%' THEN 'test/technique potentiel; ' ELSE '' END
    )) AS commentaire_detection_essai,
    CASE WHEN EXISTS (
      SELECT 1 FROM ecommerce_commandes ec_same
      WHERE ec_same.id_offre_client = e.id
        AND ec_same.id_client = e.id_client
        AND ec_same.numero_facture <> ''
        AND IF(ec_same.date_facture IS NULL OR ec_same.date_facture = '' OR ec_same.date_facture = '0000-00-00' OR ec_same.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec_same.annee, '-', LPAD(ec_same.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_same.date_facture) = DATE(e.date_debut)
    ) THEN 1 ELSE 0 END AS facture_meme_jour_essai,
    CASE WHEN EXISTS (
      SELECT 1 FROM ecommerce_commandes ec_before
      WHERE ec_before.id_client = c.id
        AND ec_before.numero_facture <> ''
        AND ec_before.total_ht > 0
        AND IF(ec_before.date_facture IS NULL OR ec_before.date_facture = '' OR ec_before.date_facture = '0000-00-00' OR ec_before.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec_before.annee, '-', LPAD(ec_before.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_before.date_facture) < e.date_debut
    ) THEN 1 ELSE 0 END AS est_deja_facture_avant_essai,
    CASE WHEN EXISTS (
      SELECT 1 FROM ecommerce_offres_to_clients ep_before
      WHERE ep_before.id_client = c.id
        AND ep_before.flag_offert = 0
        AND ep_before.prix_ht > 0
        AND ep_before.date_debut < e.date_debut
    ) THEN 1 ELSE 0 END AS a_offre_payante_avant_essai,
    CASE
      WHEN eo.id_offre_type = 2
        AND e.id_etat IN (3,4)
        AND e.flag_offert = 0
        AND e.prix_ht > 0
        AND e.trial_period_days > 0
        AND e.date_debut IS NOT NULL AND e.date_debut <> '' AND e.date_debut <> '0000-00-00'
        AND e.date_debut >= '2025-09-01' AND e.date_debut < '2026-06-01'
        AND (c.id_etat IS NULL OR c.id_etat <> 4)
        AND NOT EXISTS (SELECT 1 FROM ecommerce_commandes ec_trial WHERE ec_trial.id_offre_client = e.id AND ec_trial.id_client = e.id_client AND ec_trial.numero_facture <> '' AND IF(ec_trial.date_facture IS NULL OR ec_trial.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_trial.annee, '-', LPAD(ec_trial.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_trial.date_facture) = DATE(e.date_debut))
      THEN 1 ELSE 0
    END AS eligible_bo_avant_dedoublonnage,
    (
      SELECT MIN(e_same.id)
      FROM ecommerce_offres_to_clients e_same
      INNER JOIN ecommerce_offres eo_same ON eo_same.id = e_same.id_offre
      INNER JOIN clients c_same ON c_same.id = e_same.id_client
      WHERE e_same.id_client = e.id_client
        AND DATE_FORMAT(e_same.date_debut, '%Y-%m') = DATE_FORMAT(e.date_debut, '%Y-%m')
        AND eo_same.id_offre_type = 2
        AND e_same.id_etat IN (3,4)
        AND e_same.flag_offert = 0
        AND e_same.prix_ht > 0
        AND e_same.trial_period_days > 0
        AND e_same.date_debut IS NOT NULL AND e_same.date_debut <> '' AND e_same.date_debut <> '0000-00-00'
        AND e_same.date_debut >= '2025-09-01' AND e_same.date_debut < '2026-06-01'
        AND (c_same.id_etat IS NULL OR c_same.id_etat <> 4)
        AND NOT EXISTS (SELECT 1 FROM ecommerce_commandes ec_same_day WHERE ec_same_day.id_offre_client = e_same.id AND ec_same_day.id_client = e_same.id_client AND ec_same_day.numero_facture <> '' AND IF(ec_same_day.date_facture IS NULL OR ec_same_day.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_same_day.annee, '-', LPAD(ec_same_day.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_same_day.date_facture) = DATE(e_same.date_debut))
    ) AS id_offre_client_reporting_bo
  FROM ecommerce_offres_to_clients e
  INNER JOIN clients c ON c.id = e.id_client
  LEFT JOIN ecommerce_offres eo ON eo.id = e.id_offre
  LEFT JOIN referentiels_offres_types rot ON rot.id = eo.id_offre_type
  LEFT JOIN referentiels_offres_clients_etats roce ON roce.id = e.id_etat
  LEFT JOIN referentiels_clients_typologies rct ON rct.id = c.id_typologie
  LEFT JOIN referentiels_clients_types rt ON rt.id = c.id_type
  WHERE e.date_debut >= '2025-09-01'
    AND e.date_debut < '2026-06-01'
    AND e.id_etat IN (3,4)
    AND (e.trial_period_days > 0 OR e.flag_offert = 1 OR e.prix_ht <= 0)
) tr
LEFT JOIN (
  SELECT x.id AS id_offre_client, ec.id AS id_commande, ec.numero_facture, ec.total_ht AS total_ht_facture_initiale,
    IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture) AS date_premiere_facture_reelle_apres_essai
  FROM ecommerce_offres_to_clients x
  INNER JOIN ecommerce_commandes ec ON ec.id = (
    SELECT MIN(ec2.id)
    FROM ecommerce_commandes ec2
    WHERE ec2.id_client = x.id_client
      AND ec2.numero_facture <> ''
      AND ec2.total_ht > 0
      AND IF(ec2.date_facture IS NULL OR ec2.date_facture = '' OR ec2.date_facture = '0000-00-00' OR ec2.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec2.annee, '-', LPAD(ec2.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec2.date_facture) > x.date_debut
  )
) conv ON conv.id_offre_client = tr.id_offre_client
LEFT JOIN (
  SELECT e.id AS id_offre_client,
    CASE
      WHEN e.date_fin IS NOT NULL AND e.date_fin <> '0000-00-00' THEN e.date_fin
      WHEN e.id_etat = 4 THEN e.date_maj
      ELSE NULL
    END AS date_pause_detectee
  FROM ecommerce_offres_to_clients e
  WHERE e.id_etat = 4
    OR (e.date_fin IS NOT NULL AND e.date_fin <> '0000-00-00' AND e.date_fin <= '2026-05-31')
) pause ON pause.id_offre_client = tr.id_offre_client
LEFT JOIN (
  SELECT r.id_offre_client_source AS id_offre_client, MIN(r.date_debut) AS date_retour_apres_pause
  FROM (
    SELECT e0.id AS id_offre_client_source, e1.date_debut
    FROM ecommerce_offres_to_clients e0
    INNER JOIN ecommerce_offres_to_clients e1 ON e1.id_client = e0.id_client
      AND e1.id <> e0.id
      AND e1.flag_offert = 0
      AND e1.prix_ht > 0
      AND e1.id_etat IN (3,4)
      AND e1.date_debut > CASE WHEN e0.date_fin IS NOT NULL AND e0.date_fin <> '0000-00-00' THEN e0.date_fin ELSE e0.date_maj END
  ) r
  GROUP BY r.id_offre_client_source
) retour ON retour.id_offre_client = tr.id_offre_client
LEFT JOIN (
  SELECT
    u.id_offre_client,
    COUNT(*) AS nb_sessions_brutes_essai,
    SUM(CASE WHEN u.flag_session_demo = 0 THEN 1 ELSE 0 END) AS nb_sessions_reelles_essai,
    SUM(CASE WHEN u.flag_session_demo = 1 THEN 1 ELSE 0 END) AS nb_sessions_demo_essai,
    SUM(CASE WHEN u.players_count = 0 THEN 1 ELSE 0 END) AS nb_sessions_sans_joueur_essai,
    SUM(CASE WHEN u.flag_configuration_complete <> 1 THEN 1 ELSE 0 END) AS nb_sessions_incompletes_essai,
    SUM(u.players_count) AS nb_joueurs_bruts_essai
  FROM (
    SELECT
      e.id AS id_offre_client,
      cs.flag_session_demo,
      cs.flag_configuration_complete,
      COALESCE(tp.team_players, 0) + COALESCE(bp.bingo_players, 0) + COALESCE(bt.bt_players, 0) + COALESCE(qz.quiz_players, 0) AS players_count
    FROM ecommerce_offres_to_clients e
    INNER JOIN championnats_sessions cs ON cs.id_client = e.id_client
      AND cs.date >= e.date_debut
      AND cs.date <= CASE WHEN e.trial_period_days > 0 AND e.trial_period_days = 15 THEN DATE_ADD(e.date_debut, INTERVAL 15 DAY) WHEN e.trial_period_days > 0 THEN DATE_ADD(e.date_debut, INTERVAL e.trial_period_days DAY) WHEN e.date_fin IS NOT NULL AND e.date_fin <> '0000-00-00' THEN e.date_fin ELSE '2026-05-31' END
    LEFT JOIN (SELECT etcs.id_championnat_session AS session_pk, COUNT(DISTINCT ej.id) AS team_players FROM equipes_to_championnats_sessions etcs INNER JOIN equipes_joueurs ej ON ej.id = etcs.id_equipe GROUP BY etcs.id_championnat_session) tp ON tp.session_pk = cs.id
    LEFT JOIN (SELECT session_id, COUNT(DISTINCT id) AS bingo_players FROM bingo_players GROUP BY session_id) bp ON bp.session_id = cs.id_securite
    LEFT JOIN (SELECT bs.session_id, COUNT(DISTINCT btp.id) AS bt_players FROM blindtest_sessions bs INNER JOIN blindtest_players btp ON btp.session_id = bs.id GROUP BY bs.session_id) bt ON bt.session_id = cs.id_securite
    LEFT JOIN (SELECT cqs.session_id, COUNT(DISTINCT cqp.id) AS quiz_players FROM cotton_quiz_sessions cqs INNER JOIN cotton_quiz_players cqp ON cqp.session_id = cqs.id GROUP BY cqs.session_id) qz ON qz.session_id = cs.id_securite
    WHERE e.date_debut >= '2025-09-01'
      AND e.date_debut < '2026-06-01'
      AND (e.trial_period_days > 0 OR e.flag_offert = 1 OR e.prix_ht <= 0)
  ) u
  GROUP BY u.id_offre_client
) usage_essai ON usage_essai.id_offre_client = tr.id_offre_client
LEFT JOIN (
  SELECT
    e.id AS id_offre_client,
    COUNT(*) AS nb_sessions_significatives_essai,
    SUM(rgd.players_count) AS nb_joueurs_significatifs_essai,
    MIN(rgd.session_date) AS date_premiere_session_significative_essai
  FROM ecommerce_offres_to_clients e
  INNER JOIN reporting_games_sessions_detail rgd ON rgd.id_client = e.id_client
    AND rgd.session_date >= e.date_debut
    AND rgd.session_date < DATE_ADD(CASE WHEN e.trial_period_days > 0 AND e.trial_period_days = 15 THEN DATE_ADD(e.date_debut, INTERVAL 15 DAY) WHEN e.trial_period_days > 0 THEN DATE_ADD(e.date_debut, INTERVAL e.trial_period_days DAY) WHEN e.date_fin IS NOT NULL AND e.date_fin <> '0000-00-00' THEN e.date_fin ELSE '2026-05-31' END, INTERVAL 1 DAY)
  WHERE e.date_debut >= '2025-09-01'
    AND e.date_debut < '2026-06-01'
    AND (e.trial_period_days > 0 OR e.flag_offert = 1 OR e.prix_ht <= 0)
  GROUP BY e.id
) usage_sig ON usage_sig.id_offre_client = tr.id_offre_client
ORDER BY tr.date_debut_essai, tr.segment_detecte, tr.id_client, tr.id_offre_client;

-- J2 synthese essais gratuits CHR/reseaux
SELECT
  j.mois_debut_essai,
  j.segment_detecte,
  CASE
    WHEN j.est_reseau_affilie = 1 THEN 'reseau / affilie'
    WHEN j.est_chr = 1 THEN 'CHR direct'
    ELSE 'autre / inconnu'
  END AS perimetre_chr_reseau,
  j.type_essai,
  COUNT(*) AS essais_detectes_audit_large,
  SUM(j.inclus_reporting_bo_essai_gratuit) AS essais_inclus_reporting_bo,
  COUNT(*) - SUM(j.inclus_reporting_bo_essai_gratuit) AS ecart_vs_reporting_bo,
  COUNT(*) - SUM(j.inclus_reporting_bo_essai_gratuit) AS essais_hors_bo,
  COUNT(*) AS essais_total,
  SUM(CASE WHEN j.trial_period_days > 0 THEN 1 ELSE 0 END) AS essais_trial_explicit,
  SUM(CASE WHEN j.trial_period_days = 0 AND (j.flag_offert = 1 OR j.prix_ht <= 0) THEN 1 ELSE 0 END) AS essais_gratuit_offert_ou_prix_nul,
  SUM(CASE WHEN j.est_deja_facture_avant_essai = 0 THEN 1 ELSE 0 END) AS essais_nouveaux_purs,
  SUM(CASE WHEN j.est_deja_facture_avant_essai = 1 OR j.a_offre_payante_avant_essai = 1 THEN 1 ELSE 0 END) AS essais_reactivation_cso,
  SUM(CASE WHEN j.date_premiere_facture_reelle_apres_essai IS NOT NULL THEN 1 ELSE 0 END) AS essais_convertis_facture,
  ROUND(SUM(CASE WHEN j.inclus_reporting_bo_essai_gratuit = 1 AND j.date_premiere_facture_reelle_apres_essai IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(SUM(j.inclus_reporting_bo_essai_gratuit), 0), 4) AS taux_conversion_facture_sur_bo,
  ROUND(SUM(CASE WHEN j.date_premiere_facture_reelle_apres_essai IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 4) AS taux_conversion_facture,
  SUM(CASE WHEN j.date_premiere_facture_reelle_apres_essai IS NULL AND j.etat_temporel_essai_selon_dates = 'essai_termine_selon_dates' THEN 1 ELSE 0 END) AS essais_non_convertis,
  SUM(CASE WHEN j.etat_temporel_essai_selon_dates = 'essai_en_cours_selon_dates' THEN 1 ELSE 0 END) AS essais_en_cours_selon_dates,
  SUM(CASE WHEN j.etat_temporel_essai_selon_dates = 'essai_termine_selon_dates' THEN 1 ELSE 0 END) AS essais_termines_selon_dates,
  SUM(CASE WHEN COALESCE(j.nb_sessions_brutes_essai, 0) > 0 THEN 1 ELSE 0 END) AS essais_avec_session_brute,
  SUM(CASE WHEN COALESCE(j.nb_sessions_significatives_essai, 0) > 0 THEN 1 ELSE 0 END) AS essais_avec_session_significative,
  ROUND(SUM(CASE WHEN j.inclus_reporting_bo_essai_gratuit = 1 AND COALESCE(j.nb_sessions_significatives_essai, 0) > 0 THEN 1 ELSE 0 END) / NULLIF(SUM(j.inclus_reporting_bo_essai_gratuit), 0), 4) AS taux_activation_session_significative_sur_bo,
  ROUND(SUM(CASE WHEN COALESCE(j.nb_sessions_significatives_essai, 0) > 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 4) AS taux_activation_session_significative,
  SUM(CASE WHEN j.date_premiere_facture_reelle_apres_essai IS NULL AND COALESCE(j.nb_sessions_significatives_essai, 0) > 0 THEN 1 ELSE 0 END) AS essais_non_convertis_avec_session_significative,
  SUM(CASE WHEN j.date_pause_detectee IS NOT NULL AND (j.date_premiere_facture_reelle_apres_essai IS NULL OR j.date_pause_detectee < j.date_premiere_facture_reelle_apres_essai) THEN 1 ELSE 0 END) AS essais_pause_avant_facture,
  SUM(CASE WHEN j.date_pause_detectee IS NOT NULL AND j.date_premiere_facture_reelle_apres_essai IS NOT NULL AND j.date_pause_detectee >= j.date_premiere_facture_reelle_apres_essai THEN 1 ELSE 0 END) AS essais_pause_apres_facture,
  SUM(CASE WHEN j.date_retour_apres_pause IS NOT NULL THEN 1 ELSE 0 END) AS retours_apres_pause,
  SUM(CASE WHEN j.motif_ecart_reporting_bo = 'hors_bo_reactivation_cso' THEN 1 ELSE 0 END) AS hors_bo_reactivation_cso,
  SUM(CASE WHEN j.motif_ecart_reporting_bo = 'hors_bo_offre_multiple_meme_client' THEN 1 ELSE 0 END) AS hors_bo_offre_multiple_meme_client,
  SUM(CASE WHEN j.motif_ecart_reporting_bo = 'hors_bo_offre_gratuite_non_trial' THEN 1 ELSE 0 END) AS hors_bo_gratuit_non_trial,
  SUM(CASE WHEN j.motif_ecart_reporting_bo = 'hors_bo_prix_nul_ou_offert_ambigu' THEN 1 ELSE 0 END) AS hors_bo_prix_nul_ou_offert_ambigu,
  SUM(CASE WHEN j.motif_ecart_reporting_bo = 'hors_bo_facture_meme_jour' THEN 1 ELSE 0 END) AS hors_bo_facture_meme_jour,
  SUM(CASE WHEN j.motif_ecart_reporting_bo = 'hors_bo_statut_non_retenu' THEN 1 ELSE 0 END) AS hors_bo_statut_non_retenu,
  SUM(CASE WHEN j.motif_ecart_reporting_bo = 'hors_bo_autre_a_revoir' THEN 1 ELSE 0 END) AS hors_bo_autre_a_revoir,
  ROUND(AVG(CASE WHEN j.date_premiere_facture_reelle_apres_essai IS NOT NULL THEN DATEDIFF(j.date_premiere_facture_reelle_apres_essai, j.date_debut_essai) ELSE NULL END), 2) AS delai_moyen_essai_avant_facture,
  ROUND(AVG(CASE WHEN j.date_premiere_session_significative_essai IS NOT NULL THEN DATEDIFF(j.date_premiere_session_significative_essai, j.date_debut_essai) ELSE NULL END), 2) AS delai_moyen_essai_avant_premiere_session_significative,
  ROUND(AVG(CASE WHEN j.date_pause_detectee IS NOT NULL THEN DATEDIFF(j.date_pause_detectee, j.date_debut_essai) ELSE NULL END), 2) AS delai_moyen_essai_avant_pause
FROM (
  SELECT
    tr.*,
    conv.date_premiere_facture_reelle_apres_essai,
    pause.date_pause_detectee,
    retour.date_retour_apres_pause,
    COALESCE(usage_sig.nb_sessions_significatives_essai, 0) AS nb_sessions_significatives_essai,
    COALESCE(usage_essai.nb_sessions_brutes_essai, 0) AS nb_sessions_brutes_essai,
    usage_sig.date_premiere_session_significative_essai,
    CASE
      WHEN tr.trial_period_days > 0 THEN 'trial explicite'
      WHEN tr.flag_offert = 1 THEN 'gratuit-offert'
      WHEN tr.prix_ht <= 0 THEN 'prix nul'
      ELSE 'ambigu'
    END AS type_essai,
    CASE
      WHEN tr.date_fin_essai_calculee IS NULL THEN 'date_fin_absente_a_revoir'
      WHEN tr.id_etat_offre = 4 OR tr.date_fin_essai_calculee <= '2026-05-31' THEN 'essai_termine_selon_dates'
      ELSE 'essai_en_cours_selon_dates'
    END AS etat_temporel_essai_selon_dates,
    CASE WHEN tr.eligible_bo_avant_dedoublonnage = 1 AND tr.id_offre_client = tr.id_offre_client_reporting_bo THEN 1 ELSE 0 END AS inclus_reporting_bo_essai_gratuit,
    CASE
      WHEN tr.eligible_bo_avant_dedoublonnage = 1 AND tr.id_offre_client = tr.id_offre_client_reporting_bo THEN 'inclus_bo'
      WHEN tr.eligible_bo_avant_dedoublonnage = 1 AND tr.id_offre_client <> tr.id_offre_client_reporting_bo THEN 'hors_bo_offre_multiple_meme_client'
      WHEN tr.id_offre_type <> 2 OR tr.id_offre_type IS NULL THEN 'hors_bo_offre_gratuite_non_trial'
      WHEN tr.id_etat_offre NOT IN (3,4) THEN 'hors_bo_statut_non_retenu'
      WHEN tr.facture_meme_jour_essai = 1 THEN 'hors_bo_facture_meme_jour'
      WHEN tr.trial_period_days <= 0 AND tr.flag_offert = 1 THEN 'hors_bo_offre_gratuite_non_trial'
      WHEN tr.trial_period_days <= 0 AND tr.prix_ht <= 0 THEN 'hors_bo_prix_nul_ou_offert_ambigu'
      WHEN tr.flag_offert = 1 OR tr.prix_ht <= 0 THEN 'hors_bo_prix_nul_ou_offert_ambigu'
      WHEN tr.est_deja_facture_avant_essai = 1 THEN 'hors_bo_reactivation_cso'
      ELSE 'hors_bo_autre_a_revoir'
    END AS motif_ecart_reporting_bo
  FROM (
    SELECT
      c.id AS id_client,
      CASE
        WHEN c.flag_client_reseau_siege = 1 OR c.id_client_reseau > 0 OR e.id_client_delegation > 0 OR e.reseau_id_offre_delegation_cible > 0 OR e.reseau_id_offre_client_support_source > 0 THEN 'reseau / affilie'
        WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%chr%' OR c.flag_activite_restauration = 1 THEN 'CHR'
        ELSE 'autre / inconnu'
      END AS segment_detecte,
      CASE WHEN LOWER(COALESCE(rct.nom_court, rct.nom, rt.nom, '')) LIKE '%chr%' OR c.flag_activite_restauration = 1 THEN 1 ELSE 0 END AS est_chr,
      CASE WHEN c.flag_client_reseau_siege = 1 OR c.id_client_reseau > 0 OR e.id_client_delegation > 0 OR e.reseau_id_offre_delegation_cible > 0 OR e.reseau_id_offre_client_support_source > 0 THEN 1 ELSE 0 END AS est_reseau_affilie,
      e.id AS id_offre_client,
      eo.id_offre_type,
      e.date_debut AS date_debut_essai,
      DATE_FORMAT(e.date_debut, '%Y-%m') AS mois_debut_essai,
      e.date_fin AS date_fin_offre,
      e.id_etat AS id_etat_offre,
      CASE WHEN e.trial_period_days > 0 AND e.trial_period_days = 15 THEN DATE_ADD(e.date_debut, INTERVAL 15 DAY) WHEN e.trial_period_days > 0 THEN DATE_ADD(e.date_debut, INTERVAL e.trial_period_days DAY) WHEN e.date_fin IS NOT NULL AND e.date_fin <> '0000-00-00' THEN e.date_fin ELSE NULL END AS date_fin_essai_calculee,
      e.trial_period_days,
      e.flag_offert,
      e.prix_ht,
      CASE WHEN EXISTS (SELECT 1 FROM ecommerce_commandes ec_same WHERE ec_same.id_offre_client = e.id AND ec_same.id_client = e.id_client AND ec_same.numero_facture <> '' AND IF(ec_same.date_facture IS NULL OR ec_same.date_facture = '' OR ec_same.date_facture = '0000-00-00' OR ec_same.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec_same.annee, '-', LPAD(ec_same.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_same.date_facture) = DATE(e.date_debut)) THEN 1 ELSE 0 END AS facture_meme_jour_essai,
      CASE WHEN EXISTS (SELECT 1 FROM ecommerce_commandes ec_before WHERE ec_before.id_client = c.id AND ec_before.numero_facture <> '' AND ec_before.total_ht > 0 AND IF(ec_before.date_facture IS NULL OR ec_before.date_facture = '' OR ec_before.date_facture = '0000-00-00' OR ec_before.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec_before.annee, '-', LPAD(ec_before.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_before.date_facture) < e.date_debut) THEN 1 ELSE 0 END AS est_deja_facture_avant_essai,
      CASE WHEN EXISTS (SELECT 1 FROM ecommerce_offres_to_clients ep_before WHERE ep_before.id_client = c.id AND ep_before.flag_offert = 0 AND ep_before.prix_ht > 0 AND ep_before.date_debut < e.date_debut) THEN 1 ELSE 0 END AS a_offre_payante_avant_essai,
      CASE WHEN eo.id_offre_type = 2 AND e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0 AND e.trial_period_days > 0 AND e.date_debut >= '2025-09-01' AND e.date_debut < '2026-06-01' AND (c.id_etat IS NULL OR c.id_etat <> 4) AND NOT EXISTS (SELECT 1 FROM ecommerce_commandes ec_trial WHERE ec_trial.id_offre_client = e.id AND ec_trial.id_client = e.id_client AND ec_trial.numero_facture <> '' AND IF(ec_trial.date_facture IS NULL OR ec_trial.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_trial.annee, '-', LPAD(ec_trial.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_trial.date_facture) = DATE(e.date_debut)) THEN 1 ELSE 0 END AS eligible_bo_avant_dedoublonnage,
      (SELECT MIN(e_same.id) FROM ecommerce_offres_to_clients e_same INNER JOIN ecommerce_offres eo_same ON eo_same.id = e_same.id_offre INNER JOIN clients c_same ON c_same.id = e_same.id_client WHERE e_same.id_client = e.id_client AND DATE_FORMAT(e_same.date_debut, '%Y-%m') = DATE_FORMAT(e.date_debut, '%Y-%m') AND eo_same.id_offre_type = 2 AND e_same.id_etat IN (3,4) AND e_same.flag_offert = 0 AND e_same.prix_ht > 0 AND e_same.trial_period_days > 0 AND e_same.date_debut >= '2025-09-01' AND e_same.date_debut < '2026-06-01' AND (c_same.id_etat IS NULL OR c_same.id_etat <> 4) AND NOT EXISTS (SELECT 1 FROM ecommerce_commandes ec_same_day WHERE ec_same_day.id_offre_client = e_same.id AND ec_same_day.id_client = e_same.id_client AND ec_same_day.numero_facture <> '' AND IF(ec_same_day.date_facture IS NULL OR ec_same_day.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_same_day.annee, '-', LPAD(ec_same_day.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_same_day.date_facture) = DATE(e_same.date_debut))) AS id_offre_client_reporting_bo
    FROM ecommerce_offres_to_clients e
    INNER JOIN clients c ON c.id = e.id_client
    LEFT JOIN ecommerce_offres eo ON eo.id = e.id_offre
    LEFT JOIN referentiels_clients_typologies rct ON rct.id = c.id_typologie
    LEFT JOIN referentiels_clients_types rt ON rt.id = c.id_type
    WHERE e.date_debut >= '2025-09-01'
      AND e.date_debut < '2026-06-01'
      AND e.id_etat IN (3,4)
      AND (e.trial_period_days > 0 OR e.flag_offert = 1 OR e.prix_ht <= 0)
  ) tr
  LEFT JOIN (
    SELECT x.id AS id_offre_client, IF(ec.date_facture IS NULL OR ec.date_facture = '' OR ec.date_facture = '0000-00-00' OR ec.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec.annee, '-', LPAD(ec.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec.date_facture) AS date_premiere_facture_reelle_apres_essai
    FROM ecommerce_offres_to_clients x
    INNER JOIN ecommerce_commandes ec ON ec.id = (SELECT MIN(ec2.id) FROM ecommerce_commandes ec2 WHERE ec2.id_client = x.id_client AND ec2.numero_facture <> '' AND ec2.total_ht > 0 AND IF(ec2.date_facture IS NULL OR ec2.date_facture = '' OR ec2.date_facture = '0000-00-00' OR ec2.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec2.annee, '-', LPAD(ec2.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec2.date_facture) > x.date_debut)
  ) conv ON conv.id_offre_client = tr.id_offre_client
  LEFT JOIN (SELECT e.id AS id_offre_client, CASE WHEN e.date_fin IS NOT NULL AND e.date_fin <> '0000-00-00' THEN e.date_fin WHEN e.id_etat = 4 THEN e.date_maj ELSE NULL END AS date_pause_detectee FROM ecommerce_offres_to_clients e WHERE e.id_etat = 4 OR (e.date_fin IS NOT NULL AND e.date_fin <> '0000-00-00' AND e.date_fin <= '2026-05-31')) pause ON pause.id_offre_client = tr.id_offre_client
  LEFT JOIN (SELECT r.id_offre_client_source AS id_offre_client, MIN(r.date_debut) AS date_retour_apres_pause FROM (SELECT e0.id AS id_offre_client_source, e1.date_debut FROM ecommerce_offres_to_clients e0 INNER JOIN ecommerce_offres_to_clients e1 ON e1.id_client = e0.id_client AND e1.id <> e0.id AND e1.flag_offert = 0 AND e1.prix_ht > 0 AND e1.id_etat IN (3,4) AND e1.date_debut > CASE WHEN e0.date_fin IS NOT NULL AND e0.date_fin <> '0000-00-00' THEN e0.date_fin ELSE e0.date_maj END) r GROUP BY r.id_offre_client_source) retour ON retour.id_offre_client = tr.id_offre_client
  LEFT JOIN (SELECT e.id AS id_offre_client, COUNT(*) AS nb_sessions_brutes_essai FROM ecommerce_offres_to_clients e INNER JOIN championnats_sessions cs ON cs.id_client = e.id_client AND cs.date >= e.date_debut AND cs.date <= CASE WHEN e.trial_period_days > 0 AND e.trial_period_days = 15 THEN DATE_ADD(e.date_debut, INTERVAL 15 DAY) WHEN e.trial_period_days > 0 THEN DATE_ADD(e.date_debut, INTERVAL e.trial_period_days DAY) WHEN e.date_fin IS NOT NULL AND e.date_fin <> '0000-00-00' THEN e.date_fin ELSE '2026-05-31' END WHERE e.date_debut >= '2025-09-01' AND e.date_debut < '2026-06-01' AND (e.trial_period_days > 0 OR e.flag_offert = 1 OR e.prix_ht <= 0) GROUP BY e.id) usage_essai ON usage_essai.id_offre_client = tr.id_offre_client
  LEFT JOIN (SELECT e.id AS id_offre_client, COUNT(*) AS nb_sessions_significatives_essai, MIN(rgd.session_date) AS date_premiere_session_significative_essai FROM ecommerce_offres_to_clients e INNER JOIN reporting_games_sessions_detail rgd ON rgd.id_client = e.id_client AND rgd.session_date >= e.date_debut AND rgd.session_date < DATE_ADD(CASE WHEN e.trial_period_days > 0 AND e.trial_period_days = 15 THEN DATE_ADD(e.date_debut, INTERVAL 15 DAY) WHEN e.trial_period_days > 0 THEN DATE_ADD(e.date_debut, INTERVAL e.trial_period_days DAY) WHEN e.date_fin IS NOT NULL AND e.date_fin <> '0000-00-00' THEN e.date_fin ELSE '2026-05-31' END, INTERVAL 1 DAY) WHERE e.date_debut >= '2025-09-01' AND e.date_debut < '2026-06-01' AND (e.trial_period_days > 0 OR e.flag_offert = 1 OR e.prix_ht <= 0) GROUP BY e.id) usage_sig ON usage_sig.id_offre_client = tr.id_offre_client
) j
GROUP BY j.mois_debut_essai, j.segment_detecte, perimetre_chr_reseau, j.type_essai
ORDER BY j.mois_debut_essai, j.segment_detecte, perimetre_chr_reseau, j.type_essai;

-- J3 rapprochement essais gratuits BO vs audit large
SELECT
  m.mois,
  m.essais_reporting_bo_attendu,
  COALESCE(bo.essais_reproduits_regle_bo, 0) AS essais_reproduits_regle_bo,
  COALESCE(audit.essais_detectes_audit_large, 0) AS essais_detectes_audit_large,
  m.essais_reporting_bo_attendu - COALESCE(bo.essais_reproduits_regle_bo, 0) AS ecart_reproduction_bo,
  COALESCE(audit.hors_bo_reactivation_cso, 0) AS hors_bo_reactivation_cso,
  COALESCE(audit.hors_bo_offre_multiple_meme_client, 0) AS hors_bo_offre_multiple_meme_client,
  COALESCE(audit.hors_bo_gratuit_non_trial, 0) AS hors_bo_gratuit_non_trial,
  COALESCE(audit.hors_bo_prix_nul_ou_offert_ambigu, 0) AS hors_bo_prix_nul_ou_offert_ambigu,
  COALESCE(audit.hors_bo_facture_meme_jour, 0) AS hors_bo_facture_meme_jour,
  COALESCE(audit.hors_bo_statut_non_retenu, 0) AS hors_bo_statut_non_retenu,
  COALESCE(audit.hors_bo_autre_a_revoir, 0) AS hors_bo_autre_a_revoir,
  CASE
    WHEN m.essais_reporting_bo_attendu = COALESCE(bo.essais_reproduits_regle_bo, 0) THEN 'regle_bo_reproduite'
    ELSE 'ecart_bo_a_relire'
  END AS commentaire_lecture
FROM (
  SELECT '2025-09' AS mois, 0 AS essais_reporting_bo_attendu UNION ALL SELECT '2025-10', 0 UNION ALL SELECT '2025-11', 0 UNION ALL SELECT '2025-12', 3 UNION ALL SELECT '2026-01', 3 UNION ALL SELECT '2026-02', 6 UNION ALL SELECT '2026-03', 7 UNION ALL SELECT '2026-04', 6 UNION ALL SELECT '2026-05', 2
) m
LEFT JOIN (
  SELECT DATE_FORMAT(e.date_debut, '%Y-%m') AS mois, COUNT(DISTINCT e.id_client) AS essais_reproduits_regle_bo
  FROM ecommerce_offres_to_clients e
  INNER JOIN ecommerce_offres eo ON eo.id = e.id_offre
  INNER JOIN clients c ON c.id = e.id_client
  WHERE e.date_debut >= '2025-09-01'
    AND e.date_debut < '2026-06-01'
    AND eo.id_offre_type = 2
    AND e.id_etat IN (3,4)
    AND e.flag_offert = 0
    AND e.prix_ht > 0
    AND e.trial_period_days > 0
    AND e.date_debut IS NOT NULL AND e.date_debut <> '' AND e.date_debut <> '0000-00-00'
    AND (c.id_etat IS NULL OR c.id_etat <> 4)
    AND NOT EXISTS (SELECT 1 FROM ecommerce_commandes ec_trial WHERE ec_trial.id_offre_client = e.id AND ec_trial.id_client = e.id_client AND ec_trial.numero_facture <> '' AND IF(ec_trial.date_facture IS NULL OR ec_trial.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_trial.annee, '-', LPAD(ec_trial.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_trial.date_facture) = DATE(e.date_debut))
  GROUP BY DATE_FORMAT(e.date_debut, '%Y-%m')
) bo ON bo.mois = m.mois
LEFT JOIN (
  SELECT x.mois,
    COUNT(*) AS essais_detectes_audit_large,
    SUM(CASE WHEN x.motif = 'hors_bo_reactivation_cso' THEN 1 ELSE 0 END) AS hors_bo_reactivation_cso,
    SUM(CASE WHEN x.motif = 'hors_bo_offre_multiple_meme_client' THEN 1 ELSE 0 END) AS hors_bo_offre_multiple_meme_client,
    SUM(CASE WHEN x.motif = 'hors_bo_offre_gratuite_non_trial' THEN 1 ELSE 0 END) AS hors_bo_gratuit_non_trial,
    SUM(CASE WHEN x.motif = 'hors_bo_prix_nul_ou_offert_ambigu' THEN 1 ELSE 0 END) AS hors_bo_prix_nul_ou_offert_ambigu,
    SUM(CASE WHEN x.motif = 'hors_bo_facture_meme_jour' THEN 1 ELSE 0 END) AS hors_bo_facture_meme_jour,
    SUM(CASE WHEN x.motif = 'hors_bo_statut_non_retenu' THEN 1 ELSE 0 END) AS hors_bo_statut_non_retenu,
    SUM(CASE WHEN x.motif = 'hors_bo_autre_a_revoir' THEN 1 ELSE 0 END) AS hors_bo_autre_a_revoir
  FROM (
    SELECT DATE_FORMAT(e.date_debut, '%Y-%m') AS mois,
      CASE
        WHEN eo.id_offre_type = 2 AND e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0 AND e.trial_period_days > 0 AND (c.id_etat IS NULL OR c.id_etat <> 4) AND NOT EXISTS (SELECT 1 FROM ecommerce_commandes ec_trial WHERE ec_trial.id_offre_client = e.id AND ec_trial.id_client = e.id_client AND ec_trial.numero_facture <> '' AND IF(ec_trial.date_facture IS NULL OR ec_trial.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_trial.annee, '-', LPAD(ec_trial.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_trial.date_facture) = DATE(e.date_debut)) AND e.id = (SELECT MIN(e_same.id) FROM ecommerce_offres_to_clients e_same INNER JOIN ecommerce_offres eo_same ON eo_same.id = e_same.id_offre INNER JOIN clients c_same ON c_same.id = e_same.id_client WHERE e_same.id_client = e.id_client AND DATE_FORMAT(e_same.date_debut, '%Y-%m') = DATE_FORMAT(e.date_debut, '%Y-%m') AND eo_same.id_offre_type = 2 AND e_same.id_etat IN (3,4) AND e_same.flag_offert = 0 AND e_same.prix_ht > 0 AND e_same.trial_period_days > 0 AND (c_same.id_etat IS NULL OR c_same.id_etat <> 4) AND NOT EXISTS (SELECT 1 FROM ecommerce_commandes ec_same_day WHERE ec_same_day.id_offre_client = e_same.id AND ec_same_day.id_client = e_same.id_client AND ec_same_day.numero_facture <> '' AND IF(ec_same_day.date_facture IS NULL OR ec_same_day.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_same_day.annee, '-', LPAD(ec_same_day.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_same_day.date_facture) = DATE(e_same.date_debut))) THEN 'inclus_bo'
        WHEN eo.id_offre_type = 2 AND e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0 AND e.trial_period_days > 0 AND (c.id_etat IS NULL OR c.id_etat <> 4) AND NOT EXISTS (SELECT 1 FROM ecommerce_commandes ec_trial WHERE ec_trial.id_offre_client = e.id AND ec_trial.id_client = e.id_client AND ec_trial.numero_facture <> '' AND IF(ec_trial.date_facture IS NULL OR ec_trial.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_trial.annee, '-', LPAD(ec_trial.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_trial.date_facture) = DATE(e.date_debut)) AND e.id <> (SELECT MIN(e_same.id) FROM ecommerce_offres_to_clients e_same INNER JOIN ecommerce_offres eo_same ON eo_same.id = e_same.id_offre INNER JOIN clients c_same ON c_same.id = e_same.id_client WHERE e_same.id_client = e.id_client AND DATE_FORMAT(e_same.date_debut, '%Y-%m') = DATE_FORMAT(e.date_debut, '%Y-%m') AND eo_same.id_offre_type = 2 AND e_same.id_etat IN (3,4) AND e_same.flag_offert = 0 AND e_same.prix_ht > 0 AND e_same.trial_period_days > 0 AND (c_same.id_etat IS NULL OR c_same.id_etat <> 4) AND NOT EXISTS (SELECT 1 FROM ecommerce_commandes ec_same_day WHERE ec_same_day.id_offre_client = e_same.id AND ec_same_day.id_client = e_same.id_client AND ec_same_day.numero_facture <> '' AND IF(ec_same_day.date_facture IS NULL OR ec_same_day.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_same_day.annee, '-', LPAD(ec_same_day.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_same_day.date_facture) = DATE(e_same.date_debut))) THEN 'hors_bo_offre_multiple_meme_client'
        WHEN eo.id_offre_type <> 2 OR eo.id_offre_type IS NULL THEN 'hors_bo_offre_gratuite_non_trial'
        WHEN e.id_etat NOT IN (3,4) THEN 'hors_bo_statut_non_retenu'
        WHEN EXISTS (SELECT 1 FROM ecommerce_commandes ec_same WHERE ec_same.id_offre_client = e.id AND ec_same.id_client = e.id_client AND ec_same.numero_facture <> '' AND IF(ec_same.date_facture IS NULL OR ec_same.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_same.annee, '-', LPAD(ec_same.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_same.date_facture) = DATE(e.date_debut)) THEN 'hors_bo_facture_meme_jour'
        WHEN e.trial_period_days <= 0 AND e.flag_offert = 1 THEN 'hors_bo_offre_gratuite_non_trial'
        WHEN e.trial_period_days <= 0 AND e.prix_ht <= 0 THEN 'hors_bo_prix_nul_ou_offert_ambigu'
        WHEN e.flag_offert = 1 OR e.prix_ht <= 0 THEN 'hors_bo_prix_nul_ou_offert_ambigu'
        WHEN EXISTS (SELECT 1 FROM ecommerce_commandes ec_before WHERE ec_before.id_client = c.id AND ec_before.numero_facture <> '' AND ec_before.total_ht > 0 AND IF(ec_before.date_facture IS NULL OR ec_before.date_facture = '' OR ec_before.date_facture = '0000-00-00' OR ec_before.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec_before.annee, '-', LPAD(ec_before.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_before.date_facture) < e.date_debut) THEN 'hors_bo_reactivation_cso'
        ELSE 'hors_bo_autre_a_revoir'
      END AS motif
    FROM ecommerce_offres_to_clients e
    INNER JOIN clients c ON c.id = e.id_client
    LEFT JOIN ecommerce_offres eo ON eo.id = e.id_offre
    LEFT JOIN referentiels_clients_typologies rct ON rct.id = c.id_typologie
    LEFT JOIN referentiels_clients_types rt ON rt.id = c.id_type
    WHERE e.date_debut >= '2025-09-01'
      AND e.date_debut < '2026-06-01'
      AND e.id_etat IN (3,4)
      AND (e.trial_period_days > 0 OR e.flag_offert = 1 OR e.prix_ht <= 0)
  ) x
  GROUP BY x.mois
) audit ON audit.mois = m.mois
UNION ALL
SELECT
  'TOTAL 2025-09_2026-05' AS mois,
  27 AS essais_reporting_bo_attendu,
  COALESCE(bo.total_bo, 0) AS essais_reproduits_regle_bo,
  COALESCE(audit.total_audit, 0) AS essais_detectes_audit_large,
  27 - COALESCE(bo.total_bo, 0) AS ecart_reproduction_bo,
  COALESCE(audit.hors_bo_reactivation_cso, 0) AS hors_bo_reactivation_cso,
  COALESCE(audit.hors_bo_offre_multiple_meme_client, 0) AS hors_bo_offre_multiple_meme_client,
  COALESCE(audit.hors_bo_gratuit_non_trial, 0) AS hors_bo_gratuit_non_trial,
  COALESCE(audit.hors_bo_prix_nul_ou_offert_ambigu, 0) AS hors_bo_prix_nul_ou_offert_ambigu,
  COALESCE(audit.hors_bo_facture_meme_jour, 0) AS hors_bo_facture_meme_jour,
  COALESCE(audit.hors_bo_statut_non_retenu, 0) AS hors_bo_statut_non_retenu,
  COALESCE(audit.hors_bo_autre_a_revoir, 0) AS hors_bo_autre_a_revoir,
  CASE WHEN 27 = COALESCE(bo.total_bo, 0) THEN 'regle_bo_reproduite' ELSE 'ecart_bo_a_relire' END AS commentaire_lecture
FROM (SELECT COUNT(*) AS anchor_count) anchor
LEFT JOIN (
  SELECT COUNT(*) AS total_bo FROM (
    SELECT DATE_FORMAT(e.date_debut, '%Y-%m') AS mois, e.id_client
    FROM ecommerce_offres_to_clients e
    INNER JOIN ecommerce_offres eo ON eo.id = e.id_offre
    INNER JOIN clients c ON c.id = e.id_client
    WHERE e.date_debut >= '2025-09-01' AND e.date_debut < '2026-06-01' AND eo.id_offre_type = 2 AND e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0 AND e.trial_period_days > 0 AND (c.id_etat IS NULL OR c.id_etat <> 4) AND NOT EXISTS (SELECT 1 FROM ecommerce_commandes ec_trial WHERE ec_trial.id_offre_client = e.id AND ec_trial.id_client = e.id_client AND ec_trial.numero_facture <> '' AND IF(ec_trial.date_facture IS NULL OR ec_trial.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_trial.annee, '-', LPAD(ec_trial.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_trial.date_facture) = DATE(e.date_debut))
    GROUP BY DATE_FORMAT(e.date_debut, '%Y-%m'), e.id_client
  ) bo_clients
) bo ON 1 = 1
LEFT JOIN (
  SELECT COUNT(*) AS total_audit,
    SUM(CASE WHEN x.motif = 'hors_bo_reactivation_cso' THEN 1 ELSE 0 END) AS hors_bo_reactivation_cso,
    SUM(CASE WHEN x.motif = 'hors_bo_offre_multiple_meme_client' THEN 1 ELSE 0 END) AS hors_bo_offre_multiple_meme_client,
    SUM(CASE WHEN x.motif = 'hors_bo_offre_gratuite_non_trial' THEN 1 ELSE 0 END) AS hors_bo_gratuit_non_trial,
    SUM(CASE WHEN x.motif = 'hors_bo_prix_nul_ou_offert_ambigu' THEN 1 ELSE 0 END) AS hors_bo_prix_nul_ou_offert_ambigu,
    SUM(CASE WHEN x.motif = 'hors_bo_facture_meme_jour' THEN 1 ELSE 0 END) AS hors_bo_facture_meme_jour,
    SUM(CASE WHEN x.motif = 'hors_bo_statut_non_retenu' THEN 1 ELSE 0 END) AS hors_bo_statut_non_retenu,
    SUM(CASE WHEN x.motif = 'hors_bo_autre_a_revoir' THEN 1 ELSE 0 END) AS hors_bo_autre_a_revoir
  FROM (
    SELECT CASE
      WHEN eo.id_offre_type = 2 AND e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0 AND e.trial_period_days > 0 AND (c.id_etat IS NULL OR c.id_etat <> 4) AND NOT EXISTS (SELECT 1 FROM ecommerce_commandes ec_trial WHERE ec_trial.id_offre_client = e.id AND ec_trial.id_client = e.id_client AND ec_trial.numero_facture <> '' AND IF(ec_trial.date_facture IS NULL OR ec_trial.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_trial.annee, '-', LPAD(ec_trial.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_trial.date_facture) = DATE(e.date_debut)) AND e.id = (SELECT MIN(e_same.id) FROM ecommerce_offres_to_clients e_same INNER JOIN ecommerce_offres eo_same ON eo_same.id = e_same.id_offre INNER JOIN clients c_same ON c_same.id = e_same.id_client WHERE e_same.id_client = e.id_client AND DATE_FORMAT(e_same.date_debut, '%Y-%m') = DATE_FORMAT(e.date_debut, '%Y-%m') AND eo_same.id_offre_type = 2 AND e_same.id_etat IN (3,4) AND e_same.flag_offert = 0 AND e_same.prix_ht > 0 AND e_same.trial_period_days > 0 AND (c_same.id_etat IS NULL OR c_same.id_etat <> 4) AND NOT EXISTS (SELECT 1 FROM ecommerce_commandes ec_same_day WHERE ec_same_day.id_offre_client = e_same.id AND ec_same_day.id_client = e_same.id_client AND ec_same_day.numero_facture <> '' AND IF(ec_same_day.date_facture IS NULL OR ec_same_day.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_same_day.annee, '-', LPAD(ec_same_day.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_same_day.date_facture) = DATE(e_same.date_debut))) THEN 'inclus_bo'
      WHEN eo.id_offre_type = 2 AND e.id_etat IN (3,4) AND e.flag_offert = 0 AND e.prix_ht > 0 AND e.trial_period_days > 0 AND (c.id_etat IS NULL OR c.id_etat <> 4) AND NOT EXISTS (SELECT 1 FROM ecommerce_commandes ec_trial WHERE ec_trial.id_offre_client = e.id AND ec_trial.id_client = e.id_client AND ec_trial.numero_facture <> '' AND IF(ec_trial.date_facture IS NULL OR ec_trial.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_trial.annee, '-', LPAD(ec_trial.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_trial.date_facture) = DATE(e.date_debut)) THEN 'hors_bo_offre_multiple_meme_client'
      WHEN eo.id_offre_type <> 2 OR eo.id_offre_type IS NULL THEN 'hors_bo_offre_gratuite_non_trial'
      WHEN e.id_etat NOT IN (3,4) THEN 'hors_bo_statut_non_retenu'
      WHEN EXISTS (SELECT 1 FROM ecommerce_commandes ec_same WHERE ec_same.id_offre_client = e.id AND ec_same.id_client = e.id_client AND ec_same.numero_facture <> '' AND IF(ec_same.date_facture IS NULL OR ec_same.date_facture = '0000-00-00', STR_TO_DATE(CONCAT(ec_same.annee, '-', LPAD(ec_same.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_same.date_facture) = DATE(e.date_debut)) THEN 'hors_bo_facture_meme_jour'
      WHEN e.trial_period_days <= 0 AND e.flag_offert = 1 THEN 'hors_bo_offre_gratuite_non_trial'
      WHEN e.trial_period_days <= 0 AND e.prix_ht <= 0 THEN 'hors_bo_prix_nul_ou_offert_ambigu'
      WHEN e.flag_offert = 1 OR e.prix_ht <= 0 THEN 'hors_bo_prix_nul_ou_offert_ambigu'
      WHEN EXISTS (SELECT 1 FROM ecommerce_commandes ec_before WHERE ec_before.id_client = c.id AND ec_before.numero_facture <> '' AND ec_before.total_ht > 0 AND IF(ec_before.date_facture IS NULL OR ec_before.date_facture = '' OR ec_before.date_facture = '0000-00-00' OR ec_before.date_facture = '0000-00-00 00:00:00', STR_TO_DATE(CONCAT(ec_before.annee, '-', LPAD(ec_before.mois, 2, '0'), '-01'), '%Y-%m-%d'), ec_before.date_facture) < e.date_debut) THEN 'hors_bo_reactivation_cso'
      ELSE 'hors_bo_autre_a_revoir'
    END AS motif
    FROM ecommerce_offres_to_clients e
    INNER JOIN clients c ON c.id = e.id_client
    LEFT JOIN ecommerce_offres eo ON eo.id = e.id_offre
    LEFT JOIN referentiels_clients_typologies rct ON rct.id = c.id_typologie
    LEFT JOIN referentiels_clients_types rt ON rt.id = c.id_type
    WHERE e.date_debut >= '2025-09-01'
      AND e.date_debut < '2026-06-01'
      AND e.id_etat IN (3,4)
      AND (e.trial_period_days > 0 OR e.flag_offert = 1 OR e.prix_ht <= 0)
  ) x
) audit ON 1 = 1;
