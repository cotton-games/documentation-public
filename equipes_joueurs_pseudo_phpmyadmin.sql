ALTER TABLE `equipes_joueurs`
ADD COLUMN `pseudo` varchar(20) NOT NULL DEFAULT '' AFTER `prenom`;
