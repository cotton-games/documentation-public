-- Lecture seule : état 3 lié aux clients du parc, sans sélection arbitraire.
SELECT c.id AS id_client, c.id_client_reseau, c.flag_client_reseau_siege,
       o.id AS id_offre_client, o.id_client AS proprietaire_offre,
       o.id_client_delegation, o.id_offre, e.id AS catalogue_trouve,
       e.nom, e.seo_slug, e.id_offre_type
FROM prod_cotton_global_0.clients c
LEFT JOIN prod_cotton_global_0.ecommerce_offres_to_clients o
    ON (o.id_client = c.id OR o.id_client_delegation = c.id)
    AND o.id_etat = 3
LEFT JOIN prod_cotton_global_0.ecommerce_offres e ON e.id = o.id_offre
WHERE EXISTS (
    SELECT 1 FROM prod_cotton_global_0.championnats_sessions s
    WHERE s.id_client = c.id AND s.flag_session_demo = 0
      AND s.date >= '2026-09-08'
)
ORDER BY c.id, o.id;

-- Tous les candidats support réseau, y compris recherche historique par nom.
SELECT id, nom, seo_slug, id_offre_type
FROM prod_cotton_global_0.ecommerce_offres
WHERE seo_slug IN ('contrat-cadre-reseau', 'abonnement-reseau')
   OR nom = 'Abonnement réseau'
ORDER BY id;
