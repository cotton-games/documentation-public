ALTER TABLE clients
  ADD COLUMN lp_reseau_couleur_principale CHAR(7) NOT NULL DEFAULT '';

ALTER TABLE clients
  ADD COLUMN lp_reseau_couleur_secondaire CHAR(7) NOT NULL DEFAULT '';
