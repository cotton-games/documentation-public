# Parité DEV/PROD des parcours Hub — 09/09/2026

## Résultat et périmètre

Correctif local sur `pro:hub_soiree`, non commité, non déployé : trois gardes DEV du parcours Agenda supprimées. La carte événement CSO emprunte désormais quick-schedule en PROD comme en DEV. Aucun SQL exécuté, aucune DB modifiée, aucun merge/push/transfert. Documentation sur `develop`, branche déjà courante ; manifeste de migration historique inchangé.

Audit statique des 150 fichiers runtime du manifeste final, complété par les répertoires Hub/programmation Global, tunnel Start/widgets Pro et pages Hub Play/WWW : recherche des conditions `dev/prod`, `APP_ENV`, `NODE_ENV`, helpers d'environnement et noms d'hôtes DEV, puis lecture des blocs concernés. Premier relevé : 118 occurrences dans 28 fichiers du manifeste (avant patch). Les différences de configuration, de données et les octets actuellement servis en PROD ne sont pas vérifiés par cet audit ; il ne garantit pas l'absence de toute divergence indirecte dans l'application entière.

## Correctif Pro

| Fichier sous `pro/web/ec/modules/` | Avant | Après |
| --- | --- | --- |
| `widget/ec_widget_jeux_sessions_cta.php:29` | Carte événement : modale date en PROD, quick-schedule en DEV | Quick-schedule `source=agenda` dans les deux environnements ; garde tête de réseau et URL explicite conservées |
| `tunnel/start/ec_start_agenda_mode.php:231` | Marqueur formulaire `quick_schedule_entry=1` uniquement DEV | Marqueur dans les deux environnements |
| `tunnel/start/ec_start_script.php:4229` | Redirection marquée vers quick-schedule uniquement DEV | Même redirection dans les deux environnements, uniquement date valide aujourd'hui/future ; sans marqueur, chemin historique conservé |

Livraison future : ces trois fichiers ensemble, après recette puis intégration décidée par l'opérateur. Aucun nouveau script runtime, rewrite ou redémarrage WS nécessaire. Ne pas transférer le test. Rollback : rétablir ensemble les trois versions antérieures au patch ; cela réintroduit la divergence connue.

## Autres différences examinées

| Source | Différence | Conclusion |
| --- | --- | --- |
| `games/web/includes/canvas/remote/remote-ui.js:5818` | Remote Bingo Hub : hors DEV, retour local après 800 ms avec notice `SESSION_ENDED` synthétique ; DEV attend les événements serveur | **Écart fonctionnel restant**, filet temporaire documenté le 24/08. Peut masquer un défaut du flux terminal en PROD. Non modifié dans le correctif Agenda ; vérifier Quitter → réception terminale WS → retour Hub, puis harmoniser sur ce contrat. Le test `hub_remote_contract_test.php:421` exige encore explicitement cette différence. |
| `games/web/modules/app_hub_view_helpers.php:10`, `games/web/includes/canvas/core/qrcode-svg.js:129`, `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php:16` | QR cliquables dans le navigateur DEV ; QR à scanner en PROD | Confort de recette explicite, couvert par les tests ; conservé. Pas de restriction CSO ni de changement de contenu du QR. |
| `pro/web/ec/modules/widget/ec_widget_jeux_sessions_form_mode_calendrier_V3.php:84` | Ancien choix support Bingo masqué en PROD si version différente de 3.1 | Garde historique datée 2023 ; aucune référence au nom du widget trouvée dans les sources EC. Non identifié comme entrée Hub active ; ne pas modifier sans établir son appel. |
| `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:34`, `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php:418`, `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php:58` | Traces plus détaillées DEV ou flag debug explicite | Diagnostics, pas de branche métier à aligner |
| Helpers Hub Games, `boot_lib.php`, `logger.global.js`, `organizer_canvas.php` | Profiling, logs, console Eruda DEV | Instrumentation conservée |
| `global/web/global_ajax.php`, `games/web/games_ajax.php` | Origines/headers debug et détail des erreurs selon environnement | Configuration/debug conservés ; aucun nouveau refus Hub démontré. Gestion CORS déléguée au serveur dans Global. |
| `games/web/modules/app_orga_ajax.php`, `app_play_ajax.php`, `remote_canvas.php`, `*/ws/envUtils.js` | Hôtes, endpoints et configuration des WS selon environnement | Isolation d'environnement conservée |
| `global/web/app/modules/jeux/sessions/app_sessions_functions.php:1427` (et blocs voisins) | Fallback médias PROD depuis DEV | Réutilisation de fichiers, pas d'écriture PROD ajoutée ; conservée |
| `global/web/app/modules/entites/clients/app_clients_functions.php:1543`, `pro/web/ec/modules/compte/client/ec_client_script.php`, helpers Bingo | CRM/mails de production ou destinataires/sujets de test | Isolation des effets externes conservée ; ne pas activer les envois PROD en DEV |
| `pro/web/ec/ec.php:445`, `:491`, `:551` | Chat Brevo / tracking PROD | Intégrations externes, hors routage Hub |
| `play/web/ep/modules/compte/joueur/ep_joueur_script.php` | Traces DEV supplémentaires | Diagnostic, pas de changement de parcours |
| `play/web/ep/modules/jeux/hubs/`, `www/web/fo/modules/operations/hubs/` | Aucune condition d'environnement repérée par la recherche ciblée | Aucun autre écart direct établi sur ces pages |

L'écart Remote Bingo empêche de déclarer une parité fonctionnelle totale. Aucun autre verrou DEV/PROD abusif établi dans le périmètre inspecté. Les QR cliquables restent une différence UI volontaire.

## Remote Bingo — décision et reprise lors d’un prochain patch

**Décision utilisateur du 09/09/2026 : conserver le comportement actuel, sans modification du code Remote Bingo pour le moment.** L’utilisateur ne constate aucune différence visible entre DEV et PROD pendant sa recette. Ce constat ne démontre ni une panne ni la nécessité d’un correctif urgent.

Le périmètre est le bouton « Quitter le jeu » de la Remote Bingo liée à un Hub (`requestOrganizerQuit`, `HUB_REMOTE_RETURN.enabled`). Dans les deux environnements, la demande est envoyée au serveur. En DEV, le retour dépend du flux terminal serveur. Hors DEV, un délai de secours de 800 ms peut également déclencher localement le traitement de retour avec une notice `SESSION_ENDED` synthétique ; cette notice locale n’est pas une confirmation serveur.

| Situation | DEV | PROD |
| --- | --- | --- |
| Signal terminal reçu rapidement | Retour par le flux normal | Retour par le flux normal ; différence potentiellement invisible |
| Signal retardé ou perdu | Peut rester en attente | Le secours local peut engager le retour après 800 ms |

Les 800 ms désignent le déclenchement du secours, pas une garantie que la navigation visible est terminée à cet instant. Un retour visuellement réussi en PROD ne suffit donc pas à prouver que la fin de partie a été confirmée côté serveur. Le secours peut masquer une latence ou un défaut de livraison terminale ; aucun incident de ce type n’est établi dans la recette rapportée.

Pour reprendre ce sujet lors d’un prochain patch :

1. Reproduire « Quitter » sur une Remote Bingo Hub et corréler demande, traitement serveur, réception de `SESSION_ENDED` / `HUB_SESSION_FINISHED` et navigation. Examiner notamment `hub_remote_bingo_quit`, `hub_remote_bingo_terminal_delivery`, `hub_remote_remote_ws`, `navigation_triggered` et la raison `remote_quit_request` pour distinguer le secours du flux normal.
2. Vérifier en environnement de recette les cas nominal, réponse retardée/perdue et double signal : retour unique, état serveur effectivement terminé, cohérence Master/Play/Remote et absence d’attente indéfinie.
3. Décider ensuite de supprimer le secours dans tous les environnements, ou de conserver un secours explicite et cohérent partout. La suppression seule risquerait de rendre visible une attente aujourd’hui masquée ; ne pas la déduire automatiquement d’une recette visuelle réussie.
4. Si le contrat change, adapter `games/web/includes/canvas/remote/remote-ui.js` et `games/web/tests/hub_remote_contract_test.php` (qui exige actuellement la divergence), puis documenter et valider le nouveau contrat avant livraison.

Suivi canonique : tâche existante « PATCH 2026-08-24 - Remote Bingo Hub: fallback local désactivé en dev » dans [TASKS Games](../canon/repos/games/TASKS.md). Aucun patch ni déploiement Remote Bingo autorisé par cette décision documentaire.

## Vérifications

Depuis `pro` :

```sh
php web/ec/modules/tunnel/start/ec_programming_environment_parity_test.php
php web/ec/modules/tunnel/start/ec_start_quick_schedule_ui_test.php
php web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php
git diff --check
```

Résultats : 40 contrôles de parité réussis ; Quick Schedule et Dashboard réussis ; lint des trois sources et du test réussi ; diff sans erreur. Test neuf exécutant les décisions PHP réelles sans bootstrap applicatif ni DB : événements/soirées, CSO/INS/ABN, tête de réseau, URL explicite, formulaire, date aujourd'hui/future/passée/invalide, marqueur absent. Contre-épreuve sur copies des sources HEAD avant patch : échec attendu `prod usage=2 pipeline=CSO : quick-schedule sans modale`.

Recette authentifiée restante sur DEV puis après livraison : carte Agenda événement CSO → quick-schedule `source=agenda` ; formulaire date → même page avec date choisie ; programmation effective, retour Agenda et contrôle des garde-fous. Les tests isolés ne remplacent pas cette recette navigateur.

Journal AI Studio relu avant patch : aucune entrée pour les trois fichiers modifiés ni `remote-ui.js`. Empreinte du relevé : `8d01c84f0a62420eb3cc8f205308e512a403224cd4ba6e935ec94abdd5dfadd3`.

## Références Git examinées

Tous les dépôts applicatifs ci-dessous étaient sur `hub_soiree` ; les trois modifications Pro sont au-dessus de ces références.

| Repo | HEAD |
| --- | --- |
| global | `68ee426aca0ef86f2a7e03b980d72764ef683767` |
| games | `71eb3c713e395aff269e5ebb73976362d8d5381b` |
| bingo.game | `42b829e63fc79675841b069ada2ceb293abef786` |
| blindtest | `67f6cb0e3aac44832e9743cb83ed6dac87ab1e10` |
| quiz | `cabfdb16fe31ed9b34dde5b7832a2d751a838111` |
| play | `4a7c22623ca2e8f0eef6dc176c51a4ed1876e733` |
| www | `6966c2edb4f0e6b0eab55964c3db001fc7f12581` |
| pro | `a7b596570d99c64ecb768f9b84339e712146f7a4` |
