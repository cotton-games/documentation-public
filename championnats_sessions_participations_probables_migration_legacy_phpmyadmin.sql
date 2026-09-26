-- Migration legacy -> championnats_sessions_participations_probables
-- Usage : import via phpMyAdmin après création de la table cible.
-- Effet : reprend les anciennes inscriptions `play` encore visibles dans les
-- supports legacy Quiz et Bingo pour les convertir en "participations probables".
-- Idempotence : INSERT IGNORE s'appuie sur la clé unique
-- (id_championnat_session, id_joueur, id_equipe).


-- -----------------------------------------------------------------------------
-- QUIZ LEGACY
-- -----------------------------------------------------------------------------
-- Source historique : equipes_to_championnats_sessions
-- Interprétation : une équipe rattachée à une session Quiz devient une
-- participation probable d'équipe.

INSERT IGNORE INTO championnats_sessions_participations_probables
(
  id_championnat_session,
  id_joueur,
  id_equipe,
  source,
  date_ajout,
  date_maj,
  ip,
  id_user_ajout,
  id_user_maj
)
SELECT
  etcs.id_championnat_session,
  0,
  etcs.id_equipe,
  'play_migration_quiz',
  etcs.date_ajout,
  NULL,
  etcs.ip,
  COALESCE(etcs.id_user_ajout, 0),
  0
FROM equipes_to_championnats_sessions etcs
INNER JOIN championnats_sessions cs
  ON cs.id = etcs.id_championnat_session
WHERE cs.id_type_produit IN (1, 5)
  AND cs.date >= CURDATE();


-- -----------------------------------------------------------------------------
-- BINGO LEGACY
-- -----------------------------------------------------------------------------
-- Source historique : jeux_bingo_musical_grids_clients
-- Interprétation : une grille numerique Bingo affectée à un joueur depuis
-- `play` est convertie en participation probable joueur.
--
-- Limites :
-- - cette migration ne couvre pas Blind Test ;
-- - elle ne couvre pas les anciens parcours qui n'ont jamais écrit de lien
--   joueur/session ;
-- - elle suppose qu'une affectation de grille numérique (id_grid_support = 2)
--   reflète bien une ancienne inscription `play`.

INSERT IGNORE INTO championnats_sessions_participations_probables
(
  id_championnat_session,
  id_joueur,
  id_equipe,
  source,
  date_ajout,
  date_maj,
  ip,
  id_user_ajout,
  id_user_maj
)
SELECT DISTINCT
  cs.id AS id_championnat_session,
  jbmgc.id_joueur,
  0 AS id_equipe,
  'play_migration_bingo',
  jbmgc.date_ajout,
  NULL,
  NULL,
  COALESCE(jbmgc.id_user_ajout, 0),
  0
FROM jeux_bingo_musical_grids_clients jbmgc
INNER JOIN championnats_sessions cs
  ON cs.id_produit = jbmgc.id_playlist_client
WHERE cs.id_type_produit IN (3, 6)
  AND jbmgc.id_grid_support = 2
  AND jbmgc.id_joueur > 0
  AND jbmgc.flag_demo = 0
  AND cs.date >= CURDATE();
