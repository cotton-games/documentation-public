# Repo `play` — Tasks

## PATCH 2026-03-26 — Espace joueur: sécurisation des CTA + support dédié de participation probable
- [x] Audit confirmé:
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'une table dédiée `championnats_sessions_participations_probables`;
  - remplacement des write paths legacy `equipe_to_session_*` et `bingo_musical_joueur_grille_*` par un simple lien `joueur|équipe -> session`;
  - suppression des reliquats d'accès jeu depuis les écrans `play` (grille Bingo, indice web, web live);
  - agenda joueur aligné sur la notion de participation probable.
- [x] Vérification:
  - `php -l` sur les fichiers `play` et `global` modifiés

## PATCH 2026-03-26 — Espace joueur: remplacer la promesse d'inscription par `Prévenir l'organisateur`
- [x] Audit ciblé:
  - `play/web/ep/modules/communication/home/ep_home_index.php`
  - `play/web/ep/modules/compte/equipe/ep_equipe_view.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- [x] Correctif livré:
  - reformulation des CTA et messages session côté espace joueur pour parler de participation probable / information organisateur;
  - suppression de la promesse d'inscription ferme dans l'UI;
  - conservation du backend legacy et des write paths existants en attendant le futur affichage côté `pro`.
- [x] Vérification:
  - revue manuelle des libellés PHP modifiés

## PATCH 2026-03-26 — Ajout de la documentation canon du repo `play`
- [x] Audit ciblé:
  - `play/web/.htaccess`
  - `play/web/ep/ep.php`
  - `play/web/ep/do_script.php`
  - `play/web/ep/ep_ajax.php`
  - `play/web/ep/do_script_specifique.php`
  - `play/.gitignore`
- [x] Résultat livré:
  - création de `canon/repos/play/README.md`;
  - création de `canon/repos/play/TASKS.md`;
  - documentation du scope applicatif, des entrypoints, des dépendances `global` et des conventions locales de sécurité;
  - ajout du repo `play` au sitemap et aux index générés.
- [x] Vérification:
  - `npm run docs:sitemap` OK
