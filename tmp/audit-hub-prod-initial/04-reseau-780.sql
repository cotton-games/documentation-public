-- Lecture seule. Structures PROD reçues. Aucun choix de contrat implicite.
-- R01 Tous les contrats du siège 92, y compris inactifs.
SELECT r.id AS id_contrat, r.id_client_siege, r.online AS contrat_online,
       r.id_offre_client_contrat, o.id AS offre_trouvee,
       o.id_client AS proprietaire_offre, o.id_offre, o.id_etat,
       o.date_debut, o.date_fin, r.id_offre_delegation_cible
FROM prod_cotton_global_0.ecommerce_reseau_contrats r
LEFT JOIN prod_cotton_global_0.ecommerce_offres_to_clients o
    ON o.id = r.id_offre_client_contrat
WHERE r.id_client_siege = 92
ORDER BY r.id;

-- R02 Toutes les affiliations du client 780, quel que soit le siège.
SELECT a.id AS id_affiliation, a.id_contrat_reseau,
       r.id AS contrat_trouve, r.id_client_siege, r.online AS contrat_online,
       a.activation_state, a.mode_facturation,
       a.id_offre_client_deleguee, o.id AS offre_deleguee_trouvee,
       o.id_client AS proprietaire_offre, o.id_client_delegation,
       o.id_offre, o.id_etat, o.date_debut, o.date_fin
FROM prod_cotton_global_0.ecommerce_reseau_contrats_affilies a
LEFT JOIN prod_cotton_global_0.ecommerce_reseau_contrats r
    ON r.id = a.id_contrat_reseau
LEFT JOIN prod_cotton_global_0.ecommerce_offres_to_clients o
    ON o.id = a.id_offre_client_deleguee
WHERE a.id_client_affilie = 780
ORDER BY a.id;
