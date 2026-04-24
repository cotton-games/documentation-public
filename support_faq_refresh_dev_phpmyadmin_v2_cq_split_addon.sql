-- support_faq Cotton Quiz split add-on / phpMyAdmin import
-- A importer avec le script principal support_faq_refresh_dev_phpmyadmin_v2_bt_split.sql
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO `support_faq` (`id`, `id_sous_domaine`, `id_type_produit`, `zoning_code`, `position`, `online`, `nom`, `descriptif_long`, `date_ajout`, `date_maj`, `id_user_ajout`, `id_user_maj`) VALUES
(53, 4, 5, 'cotton-quiz-classique', 49, 0, 'Principe du Cotton Quiz', '<p>Le Cotton Quiz classique est un jeu de questions-réponses organisé en séries, sur des thématiques variées. Les joueurs répondent sur papier pendant la session.</p><p>Dans son format standard complet, une session dure <b>environ 30 minutes</b>. Chaque bonne réponse rapporte <b>10 points</b>.</p>', NOW(), NOW(), 0, 0),
(54, 4, 5, 'cotton-quiz-classique', 50, 0, 'Règles du jeu', '<p>Les joueurs répondent sur <b>papier</b>. Tu peux composer ton quiz avec plusieurs séries, dans la limite de <b>4 séries</b>.</p><p>Tu peux régler la durée des questions entre <b>30 secondes</b> et <b>1 minute</b>, et définir un temps de pause entre les séries, de <b>0 à 15 minutes</b>.</p>', NOW(), NOW(), 0, 0),
(55, 4, 5, 'cotton-quiz-classique', 51, 0, 'Conseils d\'animation', '<p><b>Présente le nombre de séries et le rythme de la partie avant de commencer.</b></p><p>Distribue les supports avant le départ, rappelle comment noter clairement les réponses et annonce les pauses à l\'avance si tu en utilises.</p>', NOW(), NOW(), 0, 0),
(56, 4, 5, 'cotton-quiz-numerique', 52, 0, 'Principe du Cotton Quiz', '<p>Le Cotton Quiz numérique est un jeu de questions-réponses organisé en séries, sur des thématiques variées. Les joueurs répondent sur smartphone pendant la session.</p><p>Dans son format standard complet, une session dure <b>environ 30 minutes</b>. Chaque bonne réponse rapporte <b>10 points</b>.</p>', NOW(), NOW(), 0, 0),
(57, 4, 5, 'cotton-quiz-numerique', 53, 0, 'Règles du jeu', '<p>Les joueurs répondent sur <b>smartphone</b>. Tu peux composer ton quiz avec plusieurs séries, dans la limite de <b>4 séries</b>.</p><p>Tu peux régler la durée des questions entre <b>30 secondes</b> et <b>1 minute</b>. En version numérique, tu peux afficher de <b>2 à 4 propositions de réponse</b> aux joueurs. Tu peux aussi définir un temps de pause entre les séries, de <b>0 à 15 minutes</b>.</p>', NOW(), NOW(), 0, 0),
(58, 4, 5, 'cotton-quiz-numerique', 54, 0, 'Conseils d\'animation', '<p><b>Présente le nombre de séries et le rythme de la partie avant de commencer.</b></p><p>Pour une animation plus fluide, rappelle le fonctionnement des réponses sur smartphone et annonce les pauses à l\'avance si tu en utilises.</p>', NOW(), NOW(), 0, 0)
ON DUPLICATE KEY UPDATE
`id_sous_domaine` = VALUES(`id_sous_domaine`),
`id_type_produit` = VALUES(`id_type_produit`),
`zoning_code` = VALUES(`zoning_code`),
`position` = VALUES(`position`),
`online` = VALUES(`online`),
`nom` = VALUES(`nom`),
`descriptif_long` = VALUES(`descriptif_long`),
`date_maj` = NOW(),
`id_user_maj` = VALUES(`id_user_maj`);

COMMIT;
