# Interface EP / Hub

## Participation probable Hub

`runtime_mode=demo` ne ferme pas Hub Play et ne neutralise pas son QR dans ce contrat. Les participations probables et identités Hub suivent le parcours historique de la source officielle. Elles ne sont toutefois jamais injectées automatiquement dans le runtime démo: le participant automatique et les joueurs ayant scanné le QR propre à la démo restent des participants directs de cette session, sans création/réactivation dans `games_hubs_players`, `games_hubs_players_sessions` ou `games_hubs_participations_probables`.

Hub Play avant le jour J réutilise le parcours EP historique de connexion/création de compte. Les liens compte joueur transportent:

- `hub_account_join=1`;
- `id_securite_games_hub={hub_token}`;
- `hub_account_action=probable`.

Play conserve ces champs dans `ep_signin.php`, `ep_signup.php`, `ep_authentification_script.php` et `ep_joueur_script.php`, puis appelle le helper Global `app_joueur_session_inscription_get_link(...)`.

Global résout le Hub côté serveur depuis `id_securite_games_hub`; aucun `id_hub` client n'est accepté comme autorité. `app_games_hub_player_prepare_ep_return(...)` distingue:

- état temporel `before`: retour vers la page EP Hub `/extranet/games/hub/{hub_token}` avec `hub_participation=pending`, sans écriture automatique; la page permet ensuite de valider ou retirer `games_hubs_participations_probables`;
- état `expired`: retour vers la page EP Hub avec `hub_participation=closed`, sans création de joueur Hub;
- état `open`: création/réactivation normale de `games_hubs_players`, confirmation d'une probable existante le cas échéant, puis retour Hub Play avec `ep_connect_token`.

La page EP Hub reprend le principe de la page EP session: état non annoncé avec CTA `Je participe`, état annoncé avec message de confirmation et lien `J'annule ma participation`, puis CTA `J'accède au jeu` quand la fenêtre Hub est active. Les sessions autonomes continuent d'utiliser `championnats_sessions_participations_probables`. Une session rattachée à un Hub route les helpers historiques `app_session_participation_probable_*` vers la source Hub, sans double écriture session/Hub.

Fichiers de référence:
- `play/web/ep/ep_signin.php`;
- `play/web/ep/ep_signup.php`;
- `play/web/ep/modules/compte/authentification/ep_authentification_script.php`;
- `play/web/ep/modules/compte/joueur/ep_joueur_script.php`;
- `play/web/ep/modules/jeux/hubs/ep_hubs_detail.php`;
- `play/web/.htaccess`;
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `games/web/modules/app_hub_view_helpers.php`.
