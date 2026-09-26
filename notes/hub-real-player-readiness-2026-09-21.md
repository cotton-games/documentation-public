# Disponibilité des joueurs réels au démarrage — audit local 21/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-real-player-readiness-20260921" owner="codex" -->
## Verdict

Aucune garantie que tous les joueurs Hub soient prêts au premier extrait. Admission commerciale, présence runtime et interface prête sont trois états distincts. Le parcours numérique prépare les participations à la demande ; il ne matérialise pas tous les actifs au lancement. Le départ du morceau Bingo ne vérifie pas que tous les joueurs attendus ont chargé leur interface/grille.

## Preuves code

- Global `app_games_hubs_functions.php:10434` : injection des actifs seulement en papier officiel ; numérique `digital_presence_runtime` / `hub_session_digital_launch_injection_skipped`.
- Games `app_hub_view_helpers.php:12668` : watcher Hub Play réel, prochain poll 3500 ms après le cycle précédent ; `active_launched_session`, préparation d’accès puis navigation Player. Ce délai n’est pas un plafond de disponibilité (réseau, onglet en arrière-plan, HTTP, grille, WS).
- Bingo `ws/bingo_server.js:1562` : `song_start`, garde d’idempotence puis mise à jour/passage au morceau, sans attente du roster Hub prêt.
- Bingo `ws/bingo_server.js:974` : ajout au tracker et diffusion du compteur avant la lecture/envoi de l’état de jeu ; compteur 100 ne prouve donc pas 100 interfaces/grilles prêtes.
- Bingo `ws/bingo_server.js:978` : authentification tardive envoie l’état courant (`current_phase`, `num_passed_songs`, `is_playing`), ne rejoue pas les premiers extraits.

## Logs rechargés

Hub 337, client 2288, session 27915, playlist runtime 17100. Horaires Paris (logs WS UTC + 2 h).

- 10:45:18.323 : hydratation 3 lignes.
- 10:45:30.959 : dernier compteur avant premier extrait = 27 (journal Bingo ligne 3864).
- 10:45:31.459 : premier TRACK_START (ligne 3867).
- 10:46:19.206 : dernière AUTH_OK joueur observée, HubBot-099.
- 10:46:20.070 : compteur 100 (ligne 4335), environ 49 s après le premier extrait et après le départ du troisième.

Cette montée provient d’un test avec bots, pas d’une mesure de 100 téléphones indépendants ; elle ne permet pas de prédire leur latence. En revanche, elle prouve que le runtime peut démarrer avec un effectif incomplet. Aucun refus d’authentification n’est nécessaire pour produire ce problème.

373 lignes Games `bingo_reset_stale` pour cette session portent le referrer `test_bots.php` : des écritures de coches bots sont refusées HTTP 409. Le test ne valide donc pas que les 100 bots jouent correctement une fois comptés. Ne pas extrapoler ces erreurs aux vrais téléphones : le Player réel possède une gestion de génération/reset distincte.

## Recommandation

Introduire un état « prêt pour cette exécution » (connexion WS + grille/état chargé et acquitté), afficher prêts/attendus et séparer préparation/accueil du premier extrait. Une politique explicite doit couvrir les absents et un démarrage forcé par l’organisateur ; bloquer sans limite sur tous les actifs Hub serait incorrect (joueurs partis/onglets fermés). La jauge seule n’est pas une barrière de synchronisation. Aucun patch fonctionnel dans cet audit, aucune DB/SSH/action distante. Les logs actuels suffisent pour ce verdict ; un test avec vrais navigateurs reste nécessaire pour quantifier les latences réelles.
<!-- AUTO-UPDATE:END id="hub-real-player-readiness-20260921" -->
