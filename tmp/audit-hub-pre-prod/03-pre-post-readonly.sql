-- CONDITION : 00 doit confirmer la liste de colonnes attendue ci-dessous.
-- Si PROD comporte des colonnes supplementaires, regenerer l empreinte avec ces
-- colonnes AVANT le PRE. Ne pas qualifier ce hash de complet sinon.
-- Pour les exports : CSV UTF-8 avec en-tetes ; conserver PRE et POST separement.
-- Geler les ecritures applicatives durant chaque releve coherent (MyISAM).
-- 1. Export PRE de la cohorte : cohort-pre.csv ; ne jamais recalculer sa composition au POST.
SELECT id FROM championnats_sessions
WHERE flag_session_demo=0 AND date >= '2026-09-08' ORDER BY id;
-- 2. Export PRE puis POST : sessions-pre.csv / sessions-post.csv.
-- AUCUN filtre futur au POST : une date changee ou un flag change doit etre detecte.
SELECT cs.id, SHA2(CAST(JSON_ARRAY(
  cs.`id`,
  cs.`id_championnat_saison`,
  cs.`id_client`,
  cs.`id_offre_client`,
  cs.`id_operation_evenement`,
  cs.`id_evenement`,
  cs.`date`,
  cs.`heure_debut`,
  cs.`heure_fin`,
  cs.`flag_session_demo`,
  cs.`flag_controle_numerique`,
  cs.`flag_session_privee`,
  cs.`flag_session_weblive`,
  cs.`flag_session_finale`,
  cs.`id_type_produit`,
  cs.`id_format`,
  cs.`id_produit`,
  cs.`code_session`,
  cs.`nb_joueurs_max`,
  cs.`nom`,
  cs.`nom_court`,
  cs.`descriptif_court`,
  cs.`descriptif_long`,
  cs.`lot_1`,
  cs.`lot_2`,
  cs.`lot_3`,
  cs.`diffusion_message`,
  cs.`diffusion_evenement_nom`,
  cs.`diffusion_evenement_date`,
  cs.`diffusion_evenement_heure`,
  cs.`lien_url_sortie_app_1`,
  cs.`lien_url_sortie_app_2`,
  cs.`lien_url`,
  cs.`lien_libelle`,
  cs.`lien_target`,
  cs.`video_code`,
  cs.`flag_configuration_complete`,
  cs.`online`,
  cs.`position`,
  cs.`flag_une`,
  cs.`seo_slug`,
  cs.`seo_meta_title`,
  cs.`seo_meta_description`,
  cs.`design_icone`,
  cs.`design_css_class`,
  cs.`date_ajout`,
  cs.`date_maj`,
  cs.`id_securite`,
  cs.`id_user_ajout`,
  cs.`id_user_maj`,
  cs.`ip`,
  cs.`lot_ids`
) AS BINARY),256) AS row_hash
FROM championnats_sessions cs ORDER BY cs.id;
-- 3. Export complet PRE puis POST pour investiguer les champs differents.
SELECT cs.* FROM championnats_sessions cs ORDER BY cs.id;
-- 4. Export PRE puis POST : memberships-pre.csv / memberships-post.csv.
-- PRE : si table absente, enregistrer explicitement son absence ; POST : elle est requise.
SELECT m.id,m.id_session,m.id_hub,m.status,m.membership_source,
 h.id AS existing_hub_id,h.id_client AS hub_client,h.hub_date,h.context_type,
 h.id_operation_evenement AS hub_operation,h.flag_active,h.hub_status,
 cs.id_client AS session_client,cs.date AS session_date,
 cs.id_operation_evenement AS session_operation,cs.flag_configuration_complete,cs.flag_session_demo
FROM games_hubs_sessions m LEFT JOIN games_hubs h ON h.id=m.id_hub
LEFT JOIN championnats_sessions cs ON cs.id=m.id_session ORDER BY m.id;
-- 5. Inventaire Hub PRE puis POST ; ne pas regenerer les tokens ni les racines existantes.
SELECT h.* FROM games_hubs h ORDER BY h.id;
-- 6. Rejouer 02 (diagnostics) au POST avec date fixe, MAIS le controle d absence
-- de perte repose sur les IDs PRE et les exports de TOUTES les lignes ci-dessus.
-- SQL universel : aucune officielle complete future sans exactement un lien actif
-- vers une racine active et non deleting, pour le parc courant (pas seul controle).
SELECT cs.id FROM championnats_sessions cs
WHERE cs.flag_session_demo=0 AND cs.date >= '2026-09-08' AND cs.flag_configuration_complete=1
AND ((SELECT COUNT(*) FROM games_hubs_sessions m WHERE m.id_session=cs.id AND m.status='active')<>1
 OR (SELECT COUNT(*) FROM games_hubs_sessions m JOIN games_hubs h ON h.id=m.id_hub
 WHERE m.id_session=cs.id AND m.status='active' AND h.flag_active=1 AND h.hub_status<>'deleting')<>1)
ORDER BY cs.id;
-- 7. Tables metier annexes : exporter PRE/POST les lignes completes dans phpMyAdmin,
-- seulement APRES confirmation de leur existence par 00. A minima :
-- operations_evenements, general_branding, clients_branding, championnats_sessions_lots,
-- championnats_sessions_participations_probables, quizs, quizs_series, questions_lots,
-- jeux_bingo_musical_playlists_clients, jeux_bingo_musical_morceaux_to_playlists_clients.
-- Ne pas pretendre que le hash championnats_sessions couvre leur contenu.
