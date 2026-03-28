# Repo `play` — Carte IA d’intervention (canon)

## Update 2026-03-27 — Espace joueur: home recentré sur l'historique réel
- le dashboard joueur (`/extranet/dashboard`) affiche maintenant:
  - un simple titre `Hello {prenom}` sans sous-titre;
  - une ligne de KPIs mixant:
    - `Prochaines sessions`;
    - `Sessions jouées`;
    - `Top organisateur`;
    - `Top jeu`;
  - chaque KPI est cliquable via son footer:
    - `Ajouter depuis l'agenda`;
    - `Voir l'historique`;
    - `Voir son agenda`;
    - `Voir l'agenda de ce jeu`;
  - le bloc visuel des cartes de participations probables à venir sous le titre `Tes prochaines sessions de jeu :`.
- un nouvel écran de détail est disponible:
  - `/extranet/dashboard/history`
- l'agenda joueur (`/extranet/games`) expose maintenant 3 filtres alignés sur la même ligne:
  - `Département / pays`;
  - `Organisateur`;
  - `Jeu`.
- comportement agenda attendu:
  - par défaut, les 3 filtres sont sur `Tous`;
  - l'utilisateur peut ensuite restreindre l'agenda par département, organisateur ou jeu;
  - la liste `Département / pays` est limitée aux zones réellement représentées par des organisateurs ayant des sessions dans l'agenda:
    - départements français si le client est en `FR`;
    - pays étrangers (`Suisse`, `Espagne`, etc.) si des organisateurs hors France sont réellement présents;
  - le filtre `Jeu` est normalisé sur les 3 familles visibles côté joueur: `Cotton Quiz`, `Blind Test`, `Bingo Musical`;
  - l'UI des filtres utilise des labels au-dessus des selects, sans mode `floating`, pour éviter tout chevauchement label/valeur;
  - en environnement `dev`, la lecture agenda ne re-filtre plus sur `c.online=1`, afin que `Tous` corresponde bien à l'ensemble des sessions configurées disponibles pour la recette.
- l'objectif produit est d'enrichir l'espace joueur par la mémoire des participations réelles, sans confondre cet historique avec les simples signalisations à l'organisateur.
- sur `signin/public/{token}/session_join` et `signup/public/{token}/session_join`, le visuel de tête est maintenant aligné sur la cascade `games` en contexte session:
  - branding récupéré via la même API `global_ajax ... action=get&token=...` que `games`;
  - puis branding session local `visuel.img_src`;
  - puis `place_bandeau_1`;
  - puis le visuel par défaut du portail `games` selon le jeu (`branding-qz`, `branding-bm`, `branding-bt`).
- la présentation des informations de session sur ces écrans EP suit maintenant le modèle `games`:
  - titre jeu stable (`COTTON QUIZ`, `COTTON BINGO`, `COTTON BLINDTEST`);
  - sous-titre unique `thème • date • heure|Démo`;
  - suppression du découpage ancien `date/lieu` puis `jeu/format/thème`.
- le visuel de tête reprend aussi le format `games`:
  - pleine largeur;
  - hauteur plafonnée à `240px`;
  - `object-fit: contain`.
- le signup joueur EP expose maintenant un champ `Pseudo` facultatif, positionné à droite de `Prénom`;
  - s'il est renseigné à la création de compte et valide (`1` à `20` caractères), il est écrit immédiatement sur `equipes_joueurs.pseudo`;
  - cela permet au premier flux de session `EP -> games` d'utiliser le pseudo sans attendre une édition ultérieure dans `Pseudo / Equipes`.
- le mail de bienvenue du signup joueur EP est maintenant envoyé via le template AI Studio `PLAYER_ALL_J0`, au lieu des anciens templates Brevo `403/426`.

## Update 2026-03-26 — Espace joueur: les CTA de session écrivent maintenant une participation probable dédiée
- repositionnement produit consolidé côté `play`:
  - les CTA et messages de session parlent de participation probable côté joueur (`Je participe`, `Mon équipe participe`) plutôt que d'inscription ferme;
  - les write paths `play` n'affectent plus de grille Bingo et ne créent plus d'accès jeu depuis l'espace joueur;
  - le support de persistance passe désormais par `championnats_sessions_participations_probables`.
- objectif produit:
  - permettre au joueur ou à son équipe de prévenir l'organisateur;
  - préparer la restitution côté `pro`;
  - ne plus promettre ni réservation ni accès garanti au jeu.

## Update 2026-03-26 — Compte joueur: retour moderne vers `games` pour auto-inscription
- les pages `signin/public/{session}` et `signup/public/{session}` acceptent maintenant un contexte `games_account_join=1`.
- après login/signup:
  - Blindtest / Bingo numérique: `play` prépare directement un retour vers `games`;
  - Quiz numérique: si le joueur a plusieurs équipes, `play` affiche un sélecteur dédié avant le retour.
- `play` ne crée toujours pas l'inscription runtime du jeu lui-même; il prépare un jeton de retour court consommé ensuite par `games`.
- nouveau point d'entrée connecté:
  - `/extranet/games/session/player-connect/{id_securite_championnat_session}`
- la persistance transversale du lien EP -> games repose sur `championnats_sessions_participations_games_connectees`.

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
  - le signup public ne demande plus le département; seul le flux de join de session conserve un `id_zone_departement` prérempli en hidden quand il est connu côté session/client.
- espace joueur connecté:
  - dashboard `communication/home`
  - historique joueur `communication/home/history`
  - compte joueur / équipe
    - page `Pseudo / Equipes` avec bloc `Pseudo` distinct du bloc équipes
  - agenda et inscription aux sessions de jeux
  - contributions `cotton_quiz`:
    - questions
    - lots
    - bonus
    - gains
- navigation latérale:
  - `Accueil`
  - `Agenda`
  - `Historique`
  - `Pseudo / Equipes`
- pseudo joueur:
  - destiné aux usages `Blind Test` / `Bingo Musical`;
  - validation alignée `games`: `1` à `20` caractères;
  - fallback sur `prenom` tant que le pseudo n'est pas renseigné;
  - support DB attendu via `documentation/equipes_joueurs_pseudo_phpmyadmin.sql`.
- equipes joueur:
  - les noms d'équipe sont utilisés pour les sessions `Cotton Quiz`;
  - la page `Pseudo / Equipes` liste les équipes du joueur et renvoie vers une vue dédiée de gestion par équipe;
  - après création, l'utilisateur est redirigé vers cette vue dédiée (`/extranet/team/profile/manage?id_equipe=...`);
  - cette vue dédiée affiche les joueurs liés, porte l'action `Quitter l'équipe` / `Supprimer l'équipe` selon le contexte, et expose un bloc d'invitation par email si l'équipe compte moins de `5` joueurs;
  - l'invitation équipe envoie maintenant un email transactionnel dédié; pour un joueur déjà existant, le CTA mail renvoie vers `signin`, et pour un nouveau joueur vers `signin/reset/{token}` afin de créer son mot de passe.

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
  - table `championnats_sessions_participations_games_connectees` pour le pont compte joueur -> games
  - compat legacy historique via `equipes_to_championnats_sessions` (Quiz) et `jeux_bingo_musical_grids_clients` (Bingo)
  - lecture/écriture via `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - lecture côté joueur et préparation du retour `games` via `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- invariants:
  - aucun CTA `play` ne doit affecter une ressource de jeu runtime;
  - aucun CTA `play` ne doit promettre une réservation;
  - les seuls retours directs vers `games` doivent être explicitement demandés par le flux `compte joueur` moderne (`games_account_join=1`) et bornés par un jeton court.
  - l'historique visible dans l'espace joueur ne doit jamais réutiliser `championnats_sessions_participations_probables` comme source de vérité.
- home joueur:
  - les KPI de synthèse du dashboard sont des blocs cliquables complets avec footer d'action;
  - le bloc `Tes prochaines sessions de jeu :` ne doit être affiché que si au moins une participation probable existe.
- page `Pseudo / Equipes`:
  - la liste principale ne montre plus ni modale joueurs ni suppression inline;
  - les noms d'équipe ouvrent maintenant une vue dédiée de gestion;
  - depuis cette vue, l'action devient un `quitter` si d'autres joueurs restent liés, et une suppression réelle de l'équipe si elle devient vide.
- menu compte avatar:
  - le dropdown affiche le `prenom` et l'adresse email du joueur;
  - il expose un CTA discret `Supprimer mon compte joueur` avec confirmation;
  - l'action de suppression doit rester irréversible côté expérience utilisateur.

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
