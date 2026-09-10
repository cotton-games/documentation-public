-- Lecture seule : clients du parc, siege reseau92 et operations601/618.
-- Inventaire de candidats ; ne prouve pas leur utilisation par un lecteur actif.
SELECT b.*
FROM prod_cotton_global_0.clients_branding b
WHERE b.id_client IN (
    3, 92, 154, 567, 571, 780, 802, 824, 940, 947,
    1909, 1958, 1959, 2170, 2436, 2437, 2454, 2455, 2459
)
OR b.id_operation_evenement IN (601, 618)
ORDER BY b.id_client, b.id_operation_evenement, b.id;
