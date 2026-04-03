# Repo `play` — Tasks

## PATCH 2026-04-02 — `Historique`: sessions reellement terminees seulement

- [x] Audit confirme:
  - `play/web/ep/modules/communication/home/ep_home_history.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livre:
  - la page `Historique` continue de relire `app_joueur_participations_reelles_get_liste(...)`, mais ce helper est maintenant borne a des sessions eligibles metier:
    - `Cotton Quiz` legacy: `date < aujourd'hui`;
    - jeux modernes: `date <= aujourd'hui` et `is_terminated = 1`;
  - la fenetre glissante par defaut reste ancree sur la derniere activite reelle, mais cette activite est maintenant elle aussi recalculee sur le meme perimetre filtré.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-02 — `Mes classements`: recap podium avec fallback emoji

- [x] Audit confirme:
  - `play/web/ep/modules/communication/home/ep_home_leaderboards.php`
  - `play/web/ep/includes/css/ep_custom.css`
- [x] Cause racine:
  - les emojis `🏆 / 🥈 / 🥉` etaient inclus directement dans la meme chaine que le texte du recap;
  - l'encodage de la vue et l'echappement PHP etaient corrects, mais la police EP `Poppins` ne garantissait pas leur rendu dans l'UI.
- [x] Correctif livre:
  - `ep_home_leaderboards_summary_bits()` retourne maintenant une structure `emoji + label` au lieu d'une simple chaine plate;
  - la boucle de rendu separe le pictogramme du texte dans un span dedie;
  - ajout d'une stack de polices emoji de fallback dans `ep_custom.css` pour ce recap uniquement.
  - update UI 2026-04-02:
    - le recap est maintenant affiche sous forme de capsules `flex-wrap`;
    - `Participations` utilise une capsule froide type progression;
    - les lignes podium utilisent une capsule plus chaude type recompense.
- [x] Verification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_leaderboards.php`

## PATCH 2026-04-02 — `games -> play` sessionnel: branding absent non bloquant

- [x] Audit confirme:
  - `play/web/ep/ep_signin.php`
  - `play/web/ep/ep_signup.php`
  - `global/web/app/modules/jeux/sessions_branding/app_sessions_branding_functions.php`
- [x] Cause racine:
  - `app_session_branding_get_detail(...)` peut encore renvoyer `''` quand aucun branding n'existe;
  - `ep_signin.php` / `ep_signup.php` lisaient ensuite `['visuel']` ou `['parameters']` sans normalisation;
  - sur PHP 8, ce cas faisait tomber les routes sessionnelles `signin/signup` en `500`.
- [x] Correctif livre:
  - normalisation defensive du branding en tableau vide juste apres `app_session_branding_get_detail(...)` dans `ep_signin.php` et `ep_signup.php`;
  - garde `!empty(...)` alignee sur `parameters` cote signup.
- [x] Verification:
  - `php -l /home/romain/Cotton/play/web/ep/ep_signin.php`
  - `php -l /home/romain/Cotton/play/web/ep/ep_signup.php`

## PATCH 2026-04-02 — Espace joueur: page `Mes classements`

- [x] Audit confirme:
  - `play/web/.htaccess`
  - `play/web/ep/ep.php`
  - `play/web/ep/modules/communication/home/ep_home_leaderboards.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livre:
  - ajout de la route `/extranet/dashboard/leaderboards`;
  - ajout d'une entree de navigation `Mes classements` dans le menu lateral EP;
  - ajout d'une page dediee cote `play`, avec une section par organisateur triee du plus frequente au moins frequente;
  - chaque section affiche les classements de l'organisateur pour le trimestre courant si le joueur y a des participations reelles, sinon pour le trimestre precedent;
  - le calcul des sections est maintenant borne par defaut aux `12 derniers mois` ancres sur la derniere activite reelle du joueur/equipe;
  - la selection des organisateurs relies au joueur est maintenant decouplee de l'historique detaille et repose sur une liste legere d'organisateurs lies sur la periode;
  - compromis retenu: cette liste legere reste bornee aux tables stables reliees au joueur, tandis que les tableaux affiches continuent de reutiliser la consolidation organisateur complete moderne / legacy / runtime;
  - les jeux affiches par organisateur sont limites a ceux sur lesquels le joueur a effectivement joue dans le trimestre retenu;
  - la page reexpose les classements organisateur existants:
    - `Blind Test` / `Bingo Musical`: classements joueurs;
    - `Cotton Quiz`: classement equipes;
  - sous la ligne `Saison affichee`, la synthese est maintenant detaillee sur des lignes distinctes:
    - `Participations`;
    - puis, si present, `🏆 victoire(s)`, `🥈 2eme place(s)`, `🥉 3eme place(s)`;
  - les compteurs podium affiches dans ce recap sont maintenant repris depuis la ligne joueur/equipe surlignee dans les leaderboards organisateur canoniques, ce qui les aligne avec le moteur `Mes joueurs`;
  - l'ecran `Historique` affiche maintenant explicitement la participation equipe pour les cartes `Cotton Quiz` quand une equipe est rattachee a la session;
  - l'ecran `Historique` est borne par defaut aux `12 derniers mois` d'activite reelle du joueur/equipe, ancres sur la derniere participation retrouvee;
  - si des donnees plus anciennes sont exclues, un CTA `Charger plus` etend la fenetre de `12 mois` supplementaires a chaque clic.
  - la home joueur relit maintenant ses KPI sur cette meme fenetre glissante `12 derniers mois` ancree sur la derniere activite reelle, pour ne plus recalculer tout l'historique a chaque chargement.
  - chaque section propose aussi un CTA simple vers l'agenda filtre de l'organisateur.
  - durcissement 2026-04-02: les CTA `J'accede au jeu` rendus par `play` passent maintenant par un lien differe vers `ep_sessions_inscription_script.php?mode=joueur_games_connect_finaliser`, ce qui evite de creer des lignes `games_connectees` au simple rendu des cartes ou fiches.
- [x] Verification:
  - `php -l /home/romain/Cotton/play/web/ep/ep.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_leaderboards.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_history.php`
  - `php -l /home/romain/Cotton/play/web/.htaccess`

## PATCH 2026-03-30 — Agenda/home EP: harmonisation visuelle des cartes session

- [x] Audit confirmé:
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - `play/web/ep/includes/css/ep_custom.css`
- [x] Correctif livré:
  - uniformisation du format visuel des images dans les cartes session EP via un cadrage fixe partagé;
  - resserrage des espacements internes entre date, badge jeu, méta session, lieu et footer;
  - ajout d'une marge basse `mb-2` sur le bloc d'actions des cartes signalées;
  - assouplissement des messages de confirmation:
    - joueur: `Ta participation a bien été transmise à l'organisateur.`
    - quiz: variantes plus douces pour équipe simple, équipe nommée et plusieurs équipes;
  - allègement du CTA `J'accède au jeu` sur les cartes:
    - rendu secondaire plus léger;
    - taille rapprochée de `Je participe`;
    - couleur pilotée par le jeu courant;
    - lisibilité légèrement renforcée via taille et graisse de texte.
  - ajustement visuel complémentaire:
    - le texte et la flèche du CTA secondaire `J'accède au jeu` passent en `#240445` sur cartes et détail.
  - harmonisation complémentaire:
    - les boutons d'inscription (`Je participe` / `Mon équipe participe`) reprennent maintenant le même langage visuel secondaire sur cartes et détail.
  - correctif complémentaire:
    - la flèche vers le bas de la vue détail utilise maintenant aussi les couleurs dédiées `Cotton Quiz` et `Bingo Musical`, et ne tombe plus sur le fallback.
  - ajout UX complémentaire:
    - la fiche détail de session expose maintenant un lien léger de retour, adapté au référent interne (`Accueil` ou `Agenda`) avec fallback agenda.
    - ce lien reprend la logique visuelle inspirée de `pro`, tout en conservant la palette `play`: rouge au repos, bleu au hover.
    - son emplacement est maintenant porté par le shell `ep.php`, dans la vraie ligne du header, à gauche sur la même rangée que l'avatar de compte.
    - les cartes de la home injectent maintenant un contexte explicite `back_to=home` vers la fiche détail, ce qui fiabilise le retour vers l'accueil;
    - les cartes de l'agenda injectent maintenant aussi les filtres actifs dans l'URL de détail, pour reconstituer un retour agenda cohérent;
    - le CTA de retour est masqué sur mobile.
  - consolidation du suivi de chemin:
    - les CTA `Je participe` / `Mon équipe participe` des cartes continuent d'ouvrir la fiche détail, pas la liste;
    - ces CTA réembarquent toutefois un `return_url` pointant vers la fiche détail enrichie du contexte `back_to=...`;
    - sur la fiche détail, tous les formulaires POST locaux (`ajouter`, `supprimer`, signalement équipe) renvoient maintenant vers l'URL courante complète de la session;
    - le lien de retour du header reste ainsi stable après une inscription, désinscription ou changement d'équipe, sans rebascule parasite vers l'agenda par défaut.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - `php -l /home/romain/Cotton/play/web/ep/ep.php`

## PATCH 2026-03-30 — Espace joueur: style des KPI home + partage s2 simplifié + badges d'historique

- [x] Audit confirmé:
  - `play/web/ep/modules/communication/home/ep_home_index.php`
  - `play/web/ep/modules/communication/home/ep_home_history.php`
  - `play/web/ep/includes/css/ep_custom.css`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `games/web/includes/canvas/php/ep_account_bridge.php`
  - `games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `games/web/includes/canvas/php/bingo_adapter_glue.php`
- [x] Correctif livré:
  - la home joueur garde ses 4 KPI, mais leurs footers sont maintenant restylés dans un rendu plus proche des footers `ec` avec accent rouge EP;
  - chaque carte KPI home est maintenant entièrement cliquable, pas seulement le CTA du footer;
  - les messages de participation probable EP sont maintenant contextualisés par type de session:
    - `Blindtest` / `Bingo`: `Merci, l'organisateur est prévenu de ta participation`;
    - `Quiz`: `Merci, l'organisateur est prévenu de la participation de ton équipe : {nom_equipe}` quand l'équipe est identifiable;
    - `Quiz`: le CTA d'annulation parle maintenant de la participation de l'équipe et s'affiche comme un lien texte;
  - l'étape `s2` de confirmation de participation EP expose maintenant un bloc de partage simplifié:
    - une mention légère rappelle `Rendez-vous sur place le {date} ...` juste sous le message de confirmation;
    - un vrai bouton `Invite tes amis` avec icône intégrée remplace l'ancien duo `label + bouton rond`;
    - le bouton est légèrement réduit et sa couleur suit maintenant le jeu courant;
    - sur mobile compatible: clic direct pour ouvrir le partage natif du téléphone;
    - sur mobile: le bouton est légèrement agrandi pour garder le libellé lisible;
    - sur desktop: menu compact `Facebook`, `WhatsApp`, `Mail`, `Copier le lien`;
    - l'option `Mail` s'ouvre dans un nouvel onglet;
    - si le partage natif échoue: fallback automatique vers la copie du lien;
    - l'annulation de participation s'affiche maintenant comme un simple lien, sans changer son POST de soumission.
  - dans un parcours `games_account_join=1`, `play` ne reboucle plus vers `games` quand la session n'est pas ouverte:
    - session future non ouverte: retour vers `manage/s1/{token}`;
    - session expirée/non ouverte: retour vers l'agenda joueur.
  - règle temporelle explicitée pour ce parcours:
    - `jour J` = accès direct encore autorisé;
    - `lendemain de session` = accès direct encore autorisé strictement avant `12:00`;
    - au-delà = plus de rebouclage vers `games`.
  - la page historique `/extranet/dashboard/history` affiche maintenant des badges contextuels par session:
    - `Quiz` / `Blindtest`: uniquement `🏆 Gagnant`, `🥈 2ème place`, `🥉 3ème place`;
    - `Bingo`: badges des phases gagnées uniquement (`🥉 Ligne`, `🥈 Double ligne`, `🏆 Bingo`);
  - aucun badge n'est affiché si aucune donnée de podium / phase gagnée n'est retrouvée pour la session.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_history.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

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

## PATCH 2026-03-30 — Agenda sessions: rendu `Cotton Quiz` V2 par séries
- [x] Audit ciblé:
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
- [x] Correctif livré:
  - ajout d'un helper `app_cotton_quiz_get_series_meta(...)` basé sur `quizs_series`;
  - ajout d'un fallback session basé sur `championnats_sessions.lot_ids` pour couvrir les lots classiques `L...` et temporaires `T...`;
  - enrichissement de `app_jeu_get_detail()` pour `Cotton Quiz` V2 avec `quiz_series_count`, `quiz_series_label`, `quiz_series_names`;
  - cartes agenda `play`: affichage `Cotton Quiz` puis `1 série` / `x séries` via les champs remontés par `global`;
  - cartes agenda `play`: alignement final sur `app_session_detail['quiz_series_label']` pour garantir le même nombre de séries que dans le détail;
  - détail d'inscription `play`: affichage `Cotton Quiz : 1 série` / `x séries` puis noms de séries ligne à ligne, sans bloc legacy `4 séries [ ~ 2h ]`, y compris pour les lots classiques `L...`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

## PATCH 2026-03-30 — Confirmation session: CTA jour J `Accède au jeu`
- [x] Audit ciblé:
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - `play/web/ep/includes/css/ep_custom.css`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'un CTA `Accède au jeu` à côté de `Invite tes amis !` sur la page de confirmation `play`, visible le jour J uniquement;
  - le CTA réutilise `app_joueur_session_inscription_get_link(..., games_account_join=1)` pour conserver le bridge `EP -> games` existant;
  - la mention d'accompagnement devient uniforme autour du message "rejoindre la partie depuis cette page ou grâce au QR code diffusé par l'organisateur";
  - le CTA `Accède au jeu` est rendu comme un bouton plein rouge, texte blanc, avec flèche droite.
  - réglage responsive final: CTA en colonne sur mobile avec espacement cohérent et largeur identique, et hauteur harmonisée sur desktop entre `Invite tes amis !` et `Accède au jeu`.
  - wording final de la mention:
    - avant le jour J: `Rendez-vous sur place le {date}, un bouton d'accès au jeu sera proposé sur cette page.`
    - le jour J: `Sur le lieu de la session, utilise le bouton d'accès au jeu ou scanne le QR code diffusé par l'organisateur pour rejoindre la session de jeu !`
  - détail d'inscription `Blind Test` / `Bingo Musical`: suppression de la ligne legacy `40 titres [ ~ ... ]`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

## PATCH 2026-03-30 — Agenda cards: clic carte + CTA directs
- [x] Audit ciblé:
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
  - `play/web/ep/includes/css/ep_custom.css`
- [x] Correctif livré:
  - carte agenda entièrement cliquable vers le détail hors CTA;
  - `Je participe` / `Mon équipe participe` conservent un flux action + redirection détail;
  - le jour J, ajout d'un CTA direct `J'accède au jeu` sur les cartes déjà annoncées;
  - correctif complémentaire: clic carte géré explicitement par `onclick`, et fallback sur l'unique équipe joueur quand le mapping des participations quiz ne remonte pas de nom.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`

## PATCH 2026-03-30 — Agenda quiz: equipe unique par session
- [x] Audit ciblé:
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- [x] Correctif livré:
  - la carte agenda quiz relit maintenant l'equipe inscrite via `app_joueur_session_participations_probables_get_liste(...)` pour afficher un message coherent avec la home;
  - un joueur ne peut plus annoncer plusieurs equipes a la meme session quiz: s'il en a deja une, il doit d'abord la desinscrire avant d'en choisir une autre;
  - l'annulation et le changement d'equipe restent centralises sur la fiche detail.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

## PATCH 2026-03-30 — Compatibilite fallback quiz sans helper global
- [x] Audit ciblé:
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- [x] Correctif livré:
  - ajout d'un fallback local sur les trois points d'usage du helper `app_joueur_session_participations_probables_get_liste(...)`;
  - si le helper n'est pas encore disponible sur l'environnement, `play` recalcule les equipes deja annoncees a partir des equipes du joueur et des participations probables de session;
  - suppression du fatal sur les listes agenda, le detail d'inscription et le script d'action.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

## PATCH 2026-03-30 — Source commune equipe quiz home/agendas
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- [x] Correctif livré:
  - `app_joueur_sessions_inscriptions_get_liste(...)` remonte maintenant l'equipe quiz inscrite et le nombre d'equipes associees a la session;
  - quand le bloc agenda est rendu depuis la liste des inscriptions joueur, il consomme ces champs en priorite pour afficher le bon nom d'equipe;
  - les autres contextes agenda conservent un fallback local.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`

## PATCH 2026-03-30 — Detail quiz: equipe inscrite seule visible
- [x] Audit ciblé:
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- [x] Correctif livré:
  - si une equipe quiz est deja inscrite a la session, la fiche detail masque les autres equipes du joueur;
  - les autres equipes restent visibles uniquement avant l'inscription, au moment du choix;
  - suppression du separateur visuel inutile apres le dernier bloc affiche.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

## PATCH 2026-03-30 — Cartes agenda: CTA unique jour J
- [x] Audit ciblé:
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- [x] Correctif livré:
  - suppression des liens d'annulation sur les cartes agenda;
  - conservation du seul CTA `J'accède au jeu` pour les participations deja annoncees le jour J;
  - alignement de ce CTA sur le style rouge plein avec fleche utilise sur la fiche detail.
- [x] Vérification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`

## PATCH 2026-03-30 — Cartes agenda: fix couleur CTA acces au jeu
- [x] Audit ciblé:
  - `play/web/ep/includes/css/ep_custom.css`
- [x] Correctif livré:
  - ajout d'une exception CSS pour `a.ep-session-share-btn-secondary` dans le footer des cartes;
  - le texte et la fleche du CTA `J'accède au jeu` restent blancs malgre la règle générique `.card-footer a, .card-footer span`.
- [x] Correctif complémentaire:
  - au hover, `svg path` est lui aussi forcé en blanc pour neutraliser toute ancienne règle de `fill`.
