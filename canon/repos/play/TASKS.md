# Repo `play` — Tasks

## PATCH 2026-03-28 — Signup joueur: mail de bienvenue aligné sur `PLAYER_ALL_J0`

- [x] Audit confirmé:
  - `play/web/ep/modules/compte/joueur/ep_joueur_script.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`
- [x] Correctif livré:
  - remplacement des appels `sendMailFromTemplate(...)` du signup joueur EP par `app_ai_studio_email_transactional_send_by_code('PLAYER_ALL_J0', ...)`;
  - alignement des deux chemins de création (`signup` standard et `signup` en contexte session) sur le même template de bienvenue joueur;
  - ajout d'un log `dev` `[ep_joueur_script][signup_email_fail]` si le webhook AI Studio refuse l'envoi.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/joueur/ep_joueur_script.php`

## PATCH 2026-03-27 — Equipes EP: invitation joueur par email V1

- [x] Audit confirmé:
  - `play/web/ep/modules/compte/equipe/ep_equipe_form.php`
  - `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - `play/web/ep/ep_signin.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`
- [x] Correctif livré:
  - activation du formulaire d'invitation dans la vue dédiée équipe tant que l'équipe compte moins de `5` joueurs;
  - ajout du write path `equipe_inviter_joueur`;
  - création/réutilisation d'un `equipes_joueurs` par email, ajout à l'équipe, puis envoi d'un email transactionnel dédié;
  - pour un joueur déjà existant, le CTA mail pointe vers `signin`;
  - pour un nouveau joueur, le CTA mail pointe vers `signin/reset/{token}` avec `flag_invitation=1`;
  - ajout d'un template AI Studio provisoire `ALL_ALL_PLAYER_TEAM_INVITATION`;
  - correction du wording invitation sur `ep_signin.php` (`espace joueur` au lieu de `espace pro`).
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_form.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - `php -l /home/romain/Cotton/play/web/ep/ep_signin.php`
  - `php -l /home/romain/Cotton/global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`

## PATCH 2026-03-27 — Equipes EP: vue dédiée de gestion après création

- [x] Audit confirmé:
  - `play/web/ep/modules/compte/equipe/ep_equipe_view.php`
  - `play/web/ep/modules/compte/equipe/ep_equipe_form.php`
  - `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - la liste `Pseudo / Equipes` devient une vue d'entrée simple:
    - noms d'équipe cliquables vers `/extranet/team/profile/manage?id_equipe=...`;
    - suppression inline retirée;
    - modale listant les joueurs retirée;
  - après création d'équipe, la redirection cible maintenant la vue dédiée de gestion de cette équipe;
  - la vue dédiée réutilise `manage` pour afficher:
    - la liste des joueurs liés;
    - l'action `Quitter l'équipe` ou `Supprimer l'équipe` selon qu'il reste d'autres joueurs;
    - un bloc `Inviter un joueur` visible seulement si l'équipe compte moins de `5` joueurs.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_view.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_form.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`

## PATCH 2026-03-27 — Signin / signup publics: visuel session aligné `games`

- [x] Audit confirmé:
  - `play/web/ep/ep_signin.php`
  - `play/web/ep/ep_signup.php`
  - `global/web/app/modules/jeux/sessions_branding/app_sessions_branding_functions.php`
  - `global/web/app/modules/general/branding/app_branding_functions.php`
- [x] Correctif livré:
  - lecture prioritaire du visuel via la même API `global_ajax ... action=get&token=...` que le portail `games`;
  - correction de l'appel `app_session_branding_get_detail(...)` avec la signature complète incluant l'id de session;
  - harmonisation de la présentation des informations de session avec `games`:
    - titre jeu stable;
    - ligne unique `thème • date • heure|Démo`;
    - visuel de tête affiché dans le même format (`width:100%`, `max-height:240px`, `object-fit:contain`);
  - en contexte session uniquement, le visuel de tête des pages `signin/signup` suit maintenant la cascade:
    - branding `global_ajax` par token;
    - puis `visuel.img_src`;
    - puis `place_bandeau_1`;
    - puis le visuel par défaut du portail `games` selon le jeu.
- [x] Effet attendu:
  - depuis `games`, les pages EP de connexion / création de compte reprennent un visuel de tête plus proche du portail joueur;
  - hors contexte session, aucun changement.

## PATCH 2026-03-27 — Signup EP: pseudo facultatif dès la création de compte

- [x] Audit confirmé:
  - `play/web/ep/ep_signup.php`
  - `play/web/ep/modules/compte/joueur/ep_joueur_script.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'un champ `Pseudo` facultatif dans le signup EP, positionné à droite de `Prénom`;
  - conservation de la valeur en cas de retour formulaire;
  - si le compte est nouvellement créé et que le pseudo est valide (`1` à `20` caractères), écriture immédiate dans `equipes_joueurs.pseudo`.
- [x] Effet attendu:
  - un joueur peut renseigner son pseudo dès l'inscription EP;
  - le premier flux de session `EP -> games` peut ainsi utiliser ce pseudo sans étape supplémentaire.

## PATCH 2026-03-27 — Espace joueur: home historique réel + page détail

- [x] Audit confirmé:
  - `play/web/.htaccess`
  - `play/web/ep/modules/communication/home/ep_home_index.php`
  - `play/web/ep/modules/communication/home/ep_home_history.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - le home joueur affiche maintenant une ligne de KPIs mixant `Prochaines sessions`, `Sessions jouées`, `Top organisateur` et `Top jeu`;
  - chaque carte KPI est maintenant cliquable avec un footer d'action:
    - `Ajouter depuis l'agenda`;
    - `Voir l'historique`;
    - `Voir son agenda`;
    - `Voir l'agenda de ce jeu`;
  - le bloc des participations probables à venir reste présent sous le titre `Tes prochaines sessions de jeu :`;
  - l'agenda joueur expose maintenant sur une même ligne les filtres `Département / pays`, `Organisateur` et `Jeu`;
  - par défaut, les 3 filtres agenda sont sur `Tous`;
  - la lecture agenda est ensuite restreinte uniquement par les choix explicites de l'utilisateur;
  - le filtre géographique ne propose plus le référentiel complet mais seulement les zones réellement présentes dans l'agenda:
    - départements français représentés;
    - pays étrangers représentés pour les organisateurs hors France;
  - le filtre `Jeu` regroupe désormais les variantes techniques sous 3 familles lisibles: `Cotton Quiz`, `Blind Test`, `Bingo Musical`;
  - l'UI des filtres n'utilise plus de labels flottants afin d'éviter le chevauchement du libellé avec la valeur sélectionnée;
  - en `dev`, le chargement agenda n'ajoute plus la contrainte `c.online=1`, pour que `Tous` reflète bien l'ensemble des sessions configurées visibles en recette;
  - ajout de la route `/extranet/dashboard/history`;
  - ajout d'une page détail dédiée à l'historique joueur;
  - compat legacy ajoutée pour remonter les anciennes participations réelles Quiz et Bingo sans utiliser les participations probables.
  - suppression du bloc dédié `Mon historique Cotton` au profit de cette ligne de KPIs.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_index.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_history.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list.php`

## PATCH 2026-03-27 — New_EJ: second passage, residuel `play` reduit au strict EP

- objectif:
  - finir le realignement `develop + EP only` en supprimant les derniers ecarts UI/session encore presents dans `play`;
- correctifs:
  - `web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
    - retour a l'ecran `develop` de participation probable;
  - `web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
    - restauration des types `4` et `5` comme dans `develop`;
  - `web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
    - retour exact au rendu `develop`;
- resultat:
  - residuel `play` limite aux seuls fichiers strictement EP:
    - `.htaccess`
    - `ep_signin.php`
    - `ep_signup.php`
    - `ep_authentification_script.php`
    - `ep_joueur_script.php`
    - `ep_sessions_inscription_script.php`
    - `ep_sessions_player_connect.php`

## PATCH 2026-03-27 — New_EJ: realignement `develop + EP only` des ecrans joueur
- [x] Audit confirme:
  - `play/web/ep/modules/communication/home/ep_home_index.php`
  - `play/web/ep/modules/compte/equipe/ep_equipe_view.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
- [x] Correctif livre:
  - retour a la semantique et aux wording `develop` pour la home joueur, la vue equipe et les ecrans agenda / participations;
  - realignement complet de "Mes participations" sur `develop`, y compris le maintien des types `4/5`;
  - conservation du seul delta EP necessaire dans le script d'inscription (`joueur_games_connect_finaliser` + compat legacy).
- [x] Verification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_index.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_view.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`

## PATCH 2026-03-26 — Compte joueur: retour `games` moderne + sélecteur d'équipe EP
- [x] Audit confirmé:
  - `play/web/.htaccess`
  - `play/web/ep/ep_signin.php`
  - `play/web/ep/ep_signup.php`
  - `play/web/ep/modules/compte/authentification/ep_authentification_script.php`
  - `play/web/ep/modules/compte/joueur/ep_joueur_script.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
- [x] Correctif livré:
  - ajout du contexte `games_account_join=1` sur les flux signin/signup publics;
  - ajout d'un écran EP dédié pour choisir l'équipe avant retour `games` quand le quiz numérique rattache plusieurs équipes au joueur;
  - ajout du nouveau point d'entrée `/extranet/games/session/player-connect/{session}`;
  - redirection finale bornée à un jeton court créé côté `global`.
- [x] Vérification:
  - `php -l` à lancer sur les fichiers `play` modifiés

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

## PATCH 2026-03-26 — New_EJ: compat descendante des modes session conservée
- [x] Audit ciblé:
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - restauration des modes legacy `session_participation_probable_ajouter` et `session_participation_probable_supprimer`;
  - conservation du nouveau mode `joueur_games_connect_finaliser` pour le retour `EP -> games`;
  - le script session redevient additif par rapport à `develop` au lieu de remplacer le contrat historique.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`

## PATCH 2026-03-26 — New_EJ: compat fonctionnelle des ecrans agenda / participations joueur restauree
- [x] Audit ciblé:
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - retour des types `4` et `5` dans "Mes participations";
  - restauration du wording legacy "participation probable" sur l'agenda joueur;
  - restauration du fallback dev qui elargit l'agenda quand les filtres le vident;
  - restauration des CTA / messages legacy dans les cartes session.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`

## PATCH 2026-03-27 — Home joueur: KPI cliquables stylés + masquage du bloc prochaines sessions vide
- [x] Audit ciblé:
  - `play/web/ep/modules/communication/home/ep_home_index.php`
  - `play/web/ep/includes/css/ep_custom.css`
- [x] Correctif livré:
  - transformation des KPI home en cartes cliquables avec footer d'action inspiré des blocs du pro;
  - accent visuel joueur rouge sur les valeurs et le footer d'action;
  - suppression du bloc `Tes prochaines sessions de jeu :` quand aucune participation probable n'est disponible.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_index.php`

## PATCH 2026-03-27 — Signup joueur: restauration du fallback quand le département n'est pas saisi
- [x] Audit ciblé:
  - `play/web/ep/ep_signup.php`
- [x] Correctif livré:
  - sécurisation du rechargement du formulaire signup quand `id_zone_departement` est absent des données stockées en session;
  - compat conservée avec le département optionnel du signup public.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/ep_signup.php`

## PATCH 2026-03-27 — Signup joueur: retrait du champ département du signup public
- [x] Audit ciblé:
  - `play/web/ep/ep_signup.php`
- [x] Correctif livré:
  - suppression du select département du signup public;
  - conservation du `id_zone_departement` hidden uniquement dans les parcours de join de session quand la session/client le fournit déjà.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/ep_signup.php`

## PATCH 2026-03-27 — Navigation EP: ajout de l'entrée `Historique`
- [x] Audit ciblé:
  - `play/web/ep/ep.php`
- [x] Correctif livré:
  - ajout de l'entrée de navigation `Historique` sous `Agenda`, liée à `/extranet/dashboard/history`;
  - renommage de `Mon équipe` en `Pseudo / Equipes`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/ep.php`

## PATCH 2026-03-27 — EP `Pseudo / Equipes`: premier bloc `Pseudo`
- [x] Audit ciblé:
  - `play/web/ep/modules/compte/equipe/ep_equipe_view.php`
  - `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - `play/web/ep/includes/menus/ep_menus_compte_equipe.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_player_connect.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'un bloc `Pseudo` au-dessus des équipes avec wording dédié Blind Test / Bingo Musical;
  - actions `Ajouter`, `Modifier`, `Supprimer` côté EP;
  - validation alignée `games` sur `1–20` caractères;
  - fallback sur `prenom` tant qu'aucun pseudo n'est renseigné;
  - préparation du support DB via `documentation/equipes_joueurs_pseudo_phpmyadmin.sql`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_view.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_player_connect.php`
  - `php -l /home/romain/Cotton/play/web/ep/includes/menus/ep_menus_compte_equipe.php`

## PATCH 2026-03-27 — EP `Pseudo / Equipes`: CTA `Equipes` réalignés + suppression par ligne
- [x] Audit ciblé:
  - `play/web/ep/modules/compte/equipe/ep_equipe_view.php`
  - `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - déplacement du CTA `Ajouter` du bloc `Equipes` dans le corps de carte pour l'aligner avec le bloc `Pseudo`;
  - ajout du sous-titre `Les noms d'équipe sont utilisés pour les sessions de Cotton Quiz. Tu peux en gérer plusieurs.`;
  - ajout d'un CTA de suppression par ligne avec icône croix rouge;
  - suppression côté runtime bornée au détachement joueur-équipe.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_view.php`

## PATCH 2026-03-27 — EP `Pseudo / Equipes`: modale joueurs liés + suppression contextuelle
- [x] Audit ciblé:
  - `play/web/ep/modules/compte/equipe/ep_equipe_view.php`
  - `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - clic sur le nom d'équipe pour ouvrir une modale listant les joueurs liés;
  - libellé et confirmation de suppression adaptés entre `Quitter l'équipe` et `Supprimer l'équipe`;
  - si aucun autre joueur ne reste lié après le retrait courant, suppression réelle de l'équipe.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_view.php`

## PATCH 2026-03-27 — EP menu compte: email + CTA suppression RGPD
- [x] Audit ciblé:
  - `play/web/ep/ep.php`
  - `play/web/ep/includes/css/ep_custom.css`
  - `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - enrichissement du dropdown avatar avec l'adresse email du joueur;
  - ajout d'un CTA discret `Supprimer mon compte joueur` avec confirmation native;
  - ajout d'un helper de suppression compte joueur côté `global`;
  - suppression des liaisons directes (`équipes`, participations probables, bridge games, logs, lots joueur, grilles bingo) et neutralisation des références legacy de contribution en `id_equipe_joueur=0`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - `php -l /home/romain/Cotton/play/web/ep/ep.php`

## PATCH 2026-03-28 — EP invitation équipe: prénom invité + nouveau code AI Studio
- [x] Audit ciblé:
  - `play/web/ep/modules/compte/equipe/ep_equipe_form.php`
  - `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`
- [x] Correctif livré:
  - ajout d'un champ `Prénom` requis dans le formulaire d'invitation équipe;
  - passage du prénom invité dans le script EP et validation dédiée;
  - réalignement de l'appel transactionnel sur `PLAYER_ALL_TEAM_INVITATION` via `ai_studio_email_transactional_send('PLAYER','ALL','TEAM_INVITATION', ...)`;
  - mapping des variables du template:
    - `CONTACT_PRENOM` = invitant
    - `CONTACT_PRENOM_INVITE` = invité
    - `EQUIPE_NOM`, `CONTACT_EMAIL`, `CTA_URL_SPECIFIQUE_1`
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_form.php`
