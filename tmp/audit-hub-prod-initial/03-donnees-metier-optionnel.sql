-- Audit initial legacy uniquement. Lecture seule. MariaDB 10.3.
-- Date de reference FIGEE : 2026-09-08 inclus. Adapter toutes ses occurrences
-- une seule fois si la date de migration change. Aucun filtre commercial.
-- Executer 00 d'abord ; executer les autres fichiers seulement apres validation
-- des tables/colonnes. Une erreur de schema ne signifie PAS un parc vide.

-- Executer chaque bloc uniquement si sa table ET ses colonnes existent.

-- M01 Publication, descriptions, lots integres, produit : valeurs source par session
SELECT s.id,s.id_client,s.date,s.id_operation_evenement,s.online,s.flag_session_privee,s.flag_configuration_complete,s.nom,s.nom_court,s.descriptif_court,s.descriptif_long,s.nb_joueurs_max,s.lot_1,s.lot_2,s.lot_3,s.lot_ids,s.id_type_produit,s.id_produit,s.id_format,s.flag_controle_numerique,s.lien_url,s.lien_libelle,s.lien_target,s.diffusion_message,s.diffusion_evenement_nom,s.diffusion_evenement_date,s.diffusion_evenement_heure
FROM prod_cotton_global_0.championnats_sessions s WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08' ORDER BY s.id;

-- M02 Lots normalises : toutes les lignes
SELECT l.* FROM prod_cotton_global_0.championnats_sessions_lots l WHERE EXISTS(SELECT 1 FROM prod_cotton_global_0.championnats_sessions s WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08' AND s.id=l.id_championnat_session) ORDER BY l.id_championnat_session,l.id;

-- M03 Participations probables : comptes par session/source sans donnees personnelles
SELECT p.id_championnat_session,p.source,COUNT(*) AS lignes,COUNT(DISTINCT NULLIF(p.id_joueur,0)) AS joueurs,COUNT(DISTINCT NULLIF(p.id_equipe,0)) AS equipes,
SUM(CASE WHEN p.id_joueur=0 AND p.id_equipe=0 THEN 1 ELSE 0 END) AS sans_joueur_ni_equipe
FROM prod_cotton_global_0.championnats_sessions_participations_probables p WHERE EXISTS(SELECT 1 FROM prod_cotton_global_0.championnats_sessions s WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08' AND s.id=p.id_championnat_session) GROUP BY p.id_championnat_session,p.source;

-- M04 Branding source par scope : pas de reduction a une seule ligne
SELECT b.* FROM prod_cotton_global_0.general_branding b WHERE EXISTS(
SELECT 1 FROM prod_cotton_global_0.championnats_sessions s LEFT JOIN prod_cotton_global_0.clients c ON c.id=s.id_client WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08' AND
((b.id_type_branding=1 AND b.id_related=s.id) OR (b.id_type_branding=2 AND b.id_related=s.id_operation_evenement AND s.id_operation_evenement>0) OR (b.id_type_branding=3 AND b.id_related=c.id_client_reseau AND c.id_client_reseau>0) OR (b.id_type_branding=4 AND b.id_related=s.id_client))) ORDER BY b.id_type_branding,b.id_related,b.id;

-- M05 Ancien branding client/evenement
SELECT b.* FROM prod_cotton_global_0.clients_branding b WHERE EXISTS(SELECT 1 FROM prod_cotton_global_0.championnats_sessions s WHERE s.flag_session_demo = 0 AND s.date >= '2026-09-08' AND (b.id_client=s.id_client OR (s.id_operation_evenement>0 AND b.id_operation_evenement=s.id_operation_evenement))) ORDER BY b.id;
