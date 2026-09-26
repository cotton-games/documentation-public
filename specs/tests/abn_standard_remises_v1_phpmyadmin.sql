ALTER TABLE ecommerce_remises
  ADD COLUMN date_debut_commande DATE DEFAULT NULL,
  ADD COLUMN date_fin_commande DATE DEFAULT NULL;

CREATE TABLE ecommerce_remises_to_clients (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_remise SMALLINT(5) UNSIGNED NOT NULL,
  id_client MEDIUMINT(9) UNSIGNED NOT NULL,
  date_ajout DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_maj DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_remise_client (id_remise, id_client),
  KEY idx_client_remise (id_client, id_remise)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

ALTER TABLE ecommerce_offres_to_clients
  ADD COLUMN id_remise SMALLINT(5) UNSIGNED NULL DEFAULT NULL,
  ADD COLUMN prix_reference_ht DECIMAL(8,2) NOT NULL DEFAULT 0.00;

ALTER TABLE ecommerce_commandes_lignes
  ADD COLUMN id_remise SMALLINT(5) UNSIGNED NULL DEFAULT NULL,
  ADD COLUMN prix_reference_ht DECIMAL(8,2) NOT NULL DEFAULT 0.00;
