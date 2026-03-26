# Repo `play` — Carte IA d’intervention (canon)

## Update 2026-03-26 — Espace joueur: les CTA de session écrivent maintenant une participation probable dédiée
- repositionnement produit consolidé côté `play`:
  - les CTA et messages de session parlent de participation probable côté joueur (`Je participe`, `Mon équipe participe`) plutôt que d'inscription ferme;
  - les write paths `play` n'affectent plus de grille Bingo et ne créent plus d'accès jeu depuis l'espace joueur;
  - le support de persistance passe désormais par `championnats_sessions_participations_probables`.
- objectif produit:
  - permettre au joueur ou à son équipe de prévenir l'organisateur;
  - préparer la restitution côté `pro`;
  - ne plus promettre ni réservation ni accès garanti au jeu.

## Doc discipline
- `canon/repos/play/TASKS.md` à mettre à jour à chaque action significative sur le repo.
- Mettre à jour ce `README.md` dès qu'un changement impacte le fonctionnel, les entrypoints, les dépendances inter-repos, la sécurité locale ou les conventions d'environnement.
- En cas de divergence, le code fait foi ; corriger la doc immédiatement.

## Etat 2026-03-26 — Initialisation du repo `play`
- repo local dédié désormais présent dans le workspace Cotton, avec remote GitHub `cotton-games/play`.
- code importé depuis la prod et nettoyé côté git pour ne plus suivre:
  - `web/config.php`
  - `web/info.php`
  - `logs/`
- les secrets déjà présents dans un historique antérieur doivent être considérés comme exposés si cet historique a été poussé avant nettoyage.

## Scope & entrypoints (confirmés)
- application PHP front unique servie depuis `play/web/`.
- rewrite principal: `play/web/.htaccess`
  - `/` et `/fr/` redirigent vers `ep/ep.php`;
  - `signup`, `signin`, `signin/reset`, `extranet/...` sont tous routés vers les entrypoints `ep`.
- entrypoints applicatifs:
  - `play/web/ep/ep.php`: shell principal de l'espace joueur connecté;
  - `play/web/ep/do_script.php`: write path PHP des formulaires/action handlers;
  - `play/web/ep/ep_ajax.php`: entrypoint AJAX modulaire;
  - `play/web/ep/do_script_specifique.php`: point d'entrée spécifique, branché directement sur certaines libs `global`.

## Surfaces fonctionnelles visibles
- authentification / réinitialisation mot de passe:
  - `play/web/ep/ep_signin.php`
  - `play/web/ep/modules/compte/authentification/**`
- inscription joueur:
  - `play/web/ep/ep_signup.php`
  - `play/web/ep/ep_signup_private.php`
- espace joueur connecté:
  - dashboard `communication/home`
  - compte joueur / équipe
  - agenda et inscription aux sessions de jeux
  - contributions `cotton_quiz`:
    - questions
    - lots
    - bonus
    - gains

## Dépendances inter-repos
- dépendance runtime forte vers `global`:
  - `play/web/config.php` résout `global_root` et `global_url`;
  - `play/web/ep/ep.php`, `do_script.php`, `ep_ajax.php` et `do_script_specifique.php` chargent des librairies et helpers depuis `global`.
- dépendance fonctionnelle vers les briques jeux Cotton:
  - `cotton_quiz`
  - sessions publiques / privées
  - bingo musical, mais sans accès direct à la grille depuis `play`

## Sessions / participations probables
- les CTA `play` doivent rester bornés à un signalement de participation probable.
- support courant:
  - table `championnats_sessions_participations_probables`
  - lecture/écriture via `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - lecture côté joueur via `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- invariants:
  - aucun CTA `play` ne doit affecter une ressource de jeu runtime;
  - aucun CTA `play` ne doit promettre une réservation;
  - aucun CTA `play` ne doit rediriger directement vers un runtime de jeu.

## Conventions locales / sécurité
- `play/.gitignore` ignore actuellement:
  - `logs/`
  - `web/config.php`
  - `web/info.php`
- `web/config.php` est requis au runtime mais ne doit pas être versionné si il contient les accès d'environnement.
- `web/info.php` ne doit pas être remis dans git ni exposé en prod.
- les logs serveur restent hors git.

## Points d’attention connus
- plusieurs requêtes SQL d'authentification et de reset sont encore construites par concaténation dans `play/web/ep/modules/compte/authentification/ep_authentification_functions.php`.
- un fichier historique `ep_authentification_script__20240229.php` est encore présent dans le tree applicatif.
- `ep.php` active `display_errors=1`; vérifier que ce réglage est bien maîtrisé selon l'environnement servi.
