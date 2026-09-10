# Audit « Lancer un test » — clients actifs — 2026-09-07

## Statut et portée des conclusions

La passe d’audit initiale n’a modifié aucun code applicatif, schéma, donnée ou déploiement. **Le correctif local a ensuite été autorisé et réalisé ; voir « Correctif local autorisé » en fin de note.** Les mécanismes décrits dans les sections d’audit ci-dessous désignent le code avant ce correctif. Aucun accès SSH, DB, DEV/PROD authentifié ou navigateur utilisé. Les sondes ont exécuté des fonctions locales avec dépendances simulées, sans connexion DB.

Deux défauts distincts sont démontrés dans le code local :

1. **Remote : readiness impossible pour la démo de contrôle.** La nouvelle politique attend un événement de readiness, mais son validateur rejette le type de transition du test Master et le résultat incomplet du test Remote. Les heartbeats ne débloquent pas cette attente.
2. **Player intégré : retour erroné piloté par la présentation officielle.** Le Play historique démo est bien chargé ; son poll peut ensuite le renvoyer au Hub lorsque la présentation officielle diffère de la source du test. La différence de présentation explique une réussite et un échec observés du même jeu et du même Hub.

**Complément Hub 292 intégré : les deux origines du CTA sont maintenant couvertes par les logs et les lectures DB fournies.** La synchronisation DEV annoncée est retenue comme hypothèse de travail ; aucun écart concret n'est identifié et aucun rechargement global n'est demandé. Les mécanismes locaux et leur corroboration serveur sont distingués de l'identité binaire de la version servie, non vérifiée indépendamment. Voir le complément E5 ci-dessous.

## Sources documentaires et contrat attendu

Lecture effectuée depuis [START main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), sections « Statut actuel », « Parcours », « Règle preuve d'abord » et « Discipline de génération », puis [SITEMAP.txt develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), rubriques « Repos », « Project status » et « Indexes », cartes/index référencés et [DOCS_MANIFEST](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), sections « Update triggers », « Routing rules », « Canon documentation ». README général et HANDOFF consultés. Les lectures HTTP directes ont évité les versions compactées/périmées renvoyées par le lecteur web.

Références contractuelles, à lire avec leurs sections :

- **D1** — [Games README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Update 2026-08-31 - Diagnostic Hub : démo de contrôle » : CTA de contrôle pour client actif, avant premier lancement officiel ; deux origines, même producteur ; isolation du focus, présentation et membership ; retours démo sans statistiques officielles.
- **D2** — [Global README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Update 2026-08-31 - Démo de contrôle Hub » : première session officielle dans l'ordre du Programme, copie isolée, suggestion numérique, reset vérifié avant contexte d'exécution, source/runtime distincts. La Remote retrouve la démo par source lorsque le focus actif est vide.
- **D3** — [Global README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Update 2026-09-04 - Hub: génération canonique de routage Remote », et [Games README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Update 2026-09-04 - Hub Remote: routage canonique générationnel » : seul control_poll.client_routing autorise la navigation ; new/recreated exigent readiness, existing validé n'en exige pas ; génération durable et anti-rebond du couple exact. La présence runtime devient diagnostique.
- **D4** — [Games README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Update 2026-05-04 — Demo desktop Bingo: Vue joueur integree », « Update 2026-05-05 — Organizer iframe: postMessage et iframe active » et « Update 2026-08-31 - Master/Remote en runtime démo Hub » : iframe historique embed=gm et demo_player=1, identité automatique propre au jeu, capacité démo partagée avec un joueur réel supplémentaire ; aucune inscription de ces joueurs dans le roster Hub par ce parcours.
- **D5** — [Global README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Update 2026-08-31 - Mode démo Hub canonique » : focus et présentation restent officiels ; démo prospect, test annexe actif et démo Dashboard historique ne sont pas interchangeables.
- **D6** — [Games README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Update 2026-09-04 - Hub Play: fondation UX/UI de l'entrée joueur » : Hub Play consomme la présentation canonique en lecture seule. D1 décrit séparément le retour terminal du Player historique, armé par le couple source/exécution validé.

Conséquence : le joueur de test doit rester dans le runtime démo indépendamment de la carte officielle présentée ; changer le focus officiel ou le routage des joueurs ordinaires n'est pas un correctif compatible avec D1/D2/D5/D6. **Règle autorisant l'expulsion d'une démo ouverte par un changement de présentation officielle : non trouvé dans la documentation.** Règle faisant d'une démo annexe une session membre officielle : non trouvé.

Comparaison des mêmes chemins main/develop effectuée pour Games README, Global README, Play README et canvas-bridge : contenus différents, **écart develop > main**. Les sections Hub récentes ci-dessus ne constituent pas une preuve de livraison PROD. Les mêmes chemins sont consultables dans [Games main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/games/README.md), [Global main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/global/README.md), [Play main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/play/README.md) et [canvas-bridge main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/interfaces/canvas-bridge.md). L'audit des traces porte sur DEV.

## Fraîcheur : journal externe et périmètre de comparaison

[Journal AI Studio fourni, URL raw publique](https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb), sections « EN COURS », « TODO », « Fait, livré en PROD » : HTTP 200 obtenu par lecture directe ; l'endpoint retourne une enveloppe HTML avec le Markdown dans la variable JSON raw, extrait et lu sans exécuter le JavaScript. Dernière mise à jour annoncée : 28/08/2026.

Le journal mentionne notamment des modifications externes de pages www/lp, emails et outils AI Studio, et global/app/modules/ecommerce/app_ecommerce_functions.php au 25/03. Il mentionne aussi le widget tarifaire app_ecommerce_bloc_offre_tarifaire_abn.php comme travail à faire, pas comme changement livré. **Aucun changement explicite du pipeline Games/Hub étudié n'y est trouvé.** L'absence d'entrée n'atteste pas la fraîcheur. Le module ecommerce est une dépendance commerciale à comparer si sa version a changé hors Git ; aucune causalité commerciale n'est établie par ce journal.

Bases locales, propres au début de l'audit :

- Games : c8c306b254198e88a3152376ccd5417d55e6d173.
- Global : 3b123b10371703014b2bf86e2fa5e127f3e6e463.
- Documentation : 18c736b288334833bd0920fd7037bf58dd920e8a.

**Inventaire de comparaison de la passe initiale, pas une demande de rechargement en cours.** Le complément utilisateur indique les fichiers supposés synchronisés avec DEV. Aucun doute concret issu des nouvelles traces ne justifie de comparer cet ensemble. Les chemins ci-dessous restent une carte du périmètre ; seule une contradiction future justifierait une comparaison ciblée.

| Repo | Fichiers nécessaires à la comparaison |
|---|---|
| Games | web/modules/app_hub_view_helpers.php |
| Games | web/modules/app_hub_remote_ajax.php |
| Games | web/modules/app_hub_master_ajax.php |
| Games | web/modules/app_hub_play_ajax.php |
| Games | web/modules/app_orga_ajax.php |
| Games | web/organizer_canvas.php |
| Games | web/player_canvas.php |
| Games | web/remote_canvas.php |
| Games | web/includes/canvas/core/boot_organizer.js |
| Games | web/includes/canvas/core/canvas_display.js |
| Games | web/includes/canvas/core/hub_transition.js |
| Games | web/includes/canvas/core/end_game.js |
| Games | web/includes/canvas/play/play-ws.js |
| Games | web/includes/canvas/play/register.js |
| Global | web/app/modules/jeux/hubs/app_games_hubs_functions.php |
| Global | web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php |
| Global | web/app/modules/jeux/sessions/app_sessions_functions.php |

Pour étendre la comparaison à toute la préparation et aux guards commerciaux : Global web/app/modules/jeux/programmation/app_programming_recommendations_functions.php et web/app/modules/ecommerce/app_ecommerce_functions.php ; Games web/includes/canvas/php/boot_lib.php et web/includes/canvas/php/bingo_adapter_glue.php, blindtest_adapter_glue.php, quiz_adapter_glue.php. Ces chemins existent et sont référencés par la chaîne inspectée. Aucun défaut de préparation ou de reset n'est démontré ici.

Pas de demande de rechargement aveugle de play/ : le Hub Play et le Player historiques concernés sont servis par Games. Les serveurs WS des jeux ne sont pas nécessaires pour confirmer les deux défauts locaux identifiés ; ils le deviendraient si les événements terminaux ou la disponibilité réelle contredisaient les captures.

## Parcours réel dans le code local

### Identités à ne pas confondre

Le Hub H porte Programme, roster, présentation et focus actif. La session officielle source S appartient à H. La copie D a son propre id et token ; elle n'est pas membre du Programme. L'exécution E est un événement hub_execution_started lié à S, dont le payload porte H, source_session_id=S, runtime_session_id=D et runtime_mode=demo. Une éventuelle exécution officielle de S est une autre identité métier. remote_routing_generation appartient à H et distingue les intentions de navigation ; ce n'est ni l'id de D ni celui de E.

Le champ session_id des lignes game_events est un **token texte**, contrairement aux identifiants numériques de sessions. Les requêtes SQL ci-dessous en tiennent compte.

### Départ Hub Master

1. Le handler data-hub-master-demo-launch poste launch_hub_demo avec master_instance_id et une intention preflight-* : Games app_hub_view_helpers.php:9410.
2. Le handler serveur vérifie l'instance Master courante puis appelle app_games_hub_demo_representative_create : même fichier:2877.
3. Global app_games_hub_demo_control_eligibility_get vérifie Hub actif, fenêtre before/open, official_access et absence de hub_has_started officiel ; app_games_hub_demo_representative_create choisit la première session canonique, pas la carte présentée : app_games_hubs_functions.php:9655 et 9740.
4. Suggestion force_numeric + isolated_demo via app_programming_quick_hub_suggestion_build ; app_games_hub_demo_execution_prepare appelle app_session_demo_create_from_source. Le registre hub_demo_launch_intent retrouve la copie pour la même intention sous verrou ; une nouvelle intention produit une copie distincte. Une exécution démo ouverte de la même intention est réutilisée ; une ancienne intention est complétée. Sources : Global hubs:9787, sessions/app_sessions_functions.php:366.
5. Le thème est appliqué à D, resetdemo est vérifié via app_games_hub_demo_runtime_reset, puis création E avec transition_type=preflight_demo_launch et readiness_required=true. Pas d'injection du roster Hub. Sources : Global hubs:9780–9860 et 4255.
6. Publication de la génération ; URL /master/{token-D}?hub_launch=1&hub_source_session=S&hub_execution=E&hub_runtime_mode=demo via app_games_hub_session_master_url. Games publie master_demo_launch avec la transition de E, puis le navigateur navigue vers redirect_url.
7. app_orga_ajax.php:145 et organizer_canvas.php:101 résolvent le couple S/E, le runtime D et le Hub ; hubOrganizer et hubLaunchAutoStart arment le démarrage. boot_organizer.js:890–1018 attend organizer/runtime-ready, poste source=ready puis les heartbeats toutes les 3 secondes. La préparation serveur n'est donc pas la preuve de readiness navigateur.

### Départ Hub Remote

1. app_hub_remote_ajax.php:1089 et 2965 : launch_hub_demo crée une commande persistée, avec contrôle de présence et instance Remote ; la Remote n'exécute pas elle-même le runtime.
2. Le poll Master claim la commande et games_hub_handle_master_remote_demo_command appelle le même producteur avec remote-command-{id} : app_hub_view_helpers.php:3426.
3. Le résultat completed stocke S, D, E, génération, runtime_kind=new et readiness_required=true. **Il omet transition_type.** L'Organizer reçoit aussi hub_remote_command et hub_remote_execution.
4. Le Master navigue depuis handled_commands ; la Remote poursuit command_status et control_poll. completed accélère le contrôle, sans autoriser lui-même une navigation.
5. Global app_games_hub_remote_client_routing_state_get:2015 relit H. Si active_session_id=0, il cherche une exécution démo ouverte par session source, sans exiger que D appartienne à H. Il construit remote_url avec D, S, E et la génération, puis décide joinable.
6. Games routeFromControlState:2769 exige target=session et joinable/client_joinable, rejette le couple exact quitté, vérifie l'URL interne puis appelle location.replace. Présence Master et état visuel ne remplacent pas cette autorité.

Limite supplémentaire du resolver : si active_session_id est positif, la recherche de démo annexe n'est pas effectuée ; il suit d'abord ce focus officiel. Les essais exploitables ci-dessus montrent un focus vide, donc ce cas ne démontre pas leur cause. En présence d'un ancien focus pollué, collecter l'état et l'intention sans déplacer le focus pour contourner le problème. Le contrat D2 décrit explicitement la résolution annexe lorsque le focus est vide.

### Joueur démo cohabitant avec le Master

organizer_canvas.php:242 construit gameUrl sur /play/{jeu}/{token-D}, avec S/E. canvas_display.js:4011 ajoute embed=gm, gm_demo=1, demo_player=1 pour la preview desktop, et les identifiants de provenance. L'iframe est chargée une fois avec __loaded ; la preview desktop est aussi déclenchée par requestAnimationFrame. Le mode papier désactive/vide le panneau ; changement de contexte ou reset peuvent reconfigurer son URL.

register.js:2015 tente la réutilisation d'une identité scoppée à la session, puis une sonde WS et player_register. L'identité est Équipe démo en Quiz, Joueur démo en Bingo/Blind Test ; Bingo poursuit avec grid_assign et auth_player. Les logs d'accès ne permettent pas de lire les réponses player_register ni le détail de l'auth WS.

player_canvas.php:164–185 valide S/E et arme hubPresentation.enabled=true, runtimeMode=demo, currentSessionId=S, runtimeSessionId=D et pollUrl vers Hub Play. **Cette configuration de retour terminal active aussi le poll de présentation officielle préexistant.** play-ws.js:77 compare uniquement presentation.session_id à S, sans tenir compte de runtimeMode ni E. Un autre id, hub_idle ou hub_podium déclenche location.replace(hubPlayUrl).

Une arrivée dans le Hub ne garantit pas que l'identité affichée soit celle de l'iframe : le handler active_launched_session peut résoudre les cookies du joueur Hub. À 10:40:39, il retrouve id_hub_player=419 ; aucune preuve ne relie cette identité à la participation démo. Même sans identité Hub, il retourne presentation avec ok=true et reason=player_unresolved : le mauvais routage peut donc se produire également sans cookie.

## Chronologie corrélée

Horaires du 07/09/2026, Europe/Paris : access_log porte +0200 ; les error_log sont corrélés aux mêmes requêtes et secondes. Games : 03:55:53–13:27:46, 24 290 lignes d'accès et 5 829 lignes d'erreur. Global : 03:52:49–13:23:55, 103 lignes de chaque type. Les « error » nginx contiennent aussi des traces applicatives normales PHP.

Abréviations E1–E4 ci-dessous : identifiants complets fournis pour la corrélation DB, tokens d'accès et IP exclus du rapport.

| Essai | Origine / contexte | Source → démo / exécution | Événements observés |
|---|---|---|---|
| E1 | Remote, Hub 288, commande 458, Bingo | 27683 → 27689 ; hubexec-f031a960a426b50b823f95c3f1ea905c | 10:25:53 commande ; 10:25:55 création ; Master HTTP 200 à 10:25:58 ; Play historique HTTP 200 et présence ready à 10:26:01 ; POST Master 400 à la même seconde ; polls Player à 10:26:02/17/32/47 ; Hub Play à 10:26:48, Hub Master à 10:26:50. Aucun GET Remote historique de cette démo. |
| E2 | Master, Hub 289, lancement de session démo distinct du CTA annexe, Blind Test | 27686 → 27690 ; hubexec-9e4be7947de9909fbe39b0131ebb618a | 10:27:38 lancement de session, focus inchangé ; Master 200 à 10:27:39 ; Player 200 à 10:27:42 ; ready à 10:27:43 ; Remote historique 200 à 10:27:45, génération 1 ; retour Remote avec E/génération à 10:27:53, Master à 10:27:54. |
| E3 | Remote, Hub 288, commande 461, Bingo | 27683 → 27691 ; hubexec-83df7dbbfc44221a2ae27fe266efec58 | Sélections 459/460 : présentation 27684 à 10:40:18 puis 27685 à 10:40:25. Commande test à 10:40:32 ; création à 10:40:34 ; Master 200 à 10:40:36 ; Play historique 200, présence ready, POST Master 400 et premier poll Player à 10:40:39 ; Hub Play à 10:40:40 ; Master reste historique jusqu'à 10:41:05. Aucun GET Remote historique de cette démo. |
| E4 | Remote, Hub 291, commande 510, Blind Test | 27695 → 27696 ; hubexec-cf9d18bfdf5b18752854d901a1415007 | 13:23:43 commande ; 13:23:46 création ; Master 200 à 13:23:50 ; Play historique 200 et présence ready à 13:23:55, POST Master 400 ; polls Player à 13:23:57 et 13:24:12 ; retour Master à 13:24:14. Aucun GET Remote historique de cette démo, aucun retour Player au Hub observé dans cette fenêtre. |

Preuves locales principales :

- Games error_log:2713–2729 et access_log:10786–10884 : E1. Présentation 27683 déjà confirmée avant lancement.
- Games error_log:2790–2817 et access_log:10976–11021 : E2. C'est launch_session en mode démo, pas hub_preflight_demo_create ; son statut commercial exact demande vérification DB. offer_ok=1 dans l'Organizer démo ne prouve pas une offre active, car le code force ce booléen pour les démos.
- Games error_log:3012–3065 ; spécialement **3040** : le poll Player résout presentation_session_id=27685, active_session_id=0 et le cookie Hub 419. access_log:12040, 12044, 12049, 12050, 12099 : navigation historique, 400, poll, retour Player et retour Master.
- Games error_log:5777–5797 ; access_log:23971, 23982, 23989, 23995, 24015, 24020 : E4.
- Global access_log:95–103 : hydratations branding HTTP 200 avec les mêmes S/E pour les Master/Player et la Remote E2. Global error_log correspondant : source membre retrouvée. Aucun refus branding démontré.
- Les demos D sont journalisées membership_not_found, alors que leurs sources S sont retrouvées : c'est compatible avec l'isolation documentée, pas une anomalie à réparer.

**Premier lot : aucun CTA annexe Master identifiable**, pas de hub_preflight_demo_launch retrouvé ; les trois CTA annexes étaient Remote et E2 restait un lancement de carte distinct. **Complément : E5 fournit désormais cette preuve directe Master**, avec l'intention preflight, hub_preflight_demo_launch et les lectures DB corrélées.

## Causes, classifications et historique Git

### Remote

Le signal source=ready accepté par l'endpoint de présence n'est pas une preuve d'insertion de hub_remote_runtime_ready. Global app_games_hubs_functions.php:1495 appelle un matcher qui exige, à la ligne 1089, transition_type dans resume_existing_runtime, launch_new_runtime, resume_recreated_runtime.

- CTA Master : le producteur écrit preflight_demo_launch ; le relais master_demo_launch le propage. Ce type est refusé.
- CTA Remote : games_hub_handle_master_remote_demo_command omet transition_type dans result_json ; le matcher lit une chaîne vide et refuse.
- Le second callback remote_launch_readiness ne sauve pas ce cas : app_games_hub_remote_launch_readiness_mark:1925 n'accepte que command_type=launch_session. Une commande launch_hub_demo est refusée avant la validation du payload ; son payload ne porte d'ailleurs pas la session source attendue par ce chemin.
- Les heartbeats portent source=heartbeat et ne produisent pas de readiness. L'endpoint de présence retourne néanmoins ok=true. Les trois POST 400 sont compatibles avec le second callback, mais leur action et leur erreur exactes restent à confirmer : les access logs ne contiennent ni corps POST ni JSON de réponse.

**Classification locale : URL historique produite, navigation non autorisée, attente de readiness non résolue.** Ce n'est pas une absence de construction d'URL. Dans les traces : absence de GET Remote historique pour E1/E3/E4, malgré présence runtime. Le JSON control_poll manque pour prouver directement son contenu servi. Une navigation exécutée puis annulée n'est pas observée pour ces essais.

**Changement introducteur local prouvé : Global 365c8542, 04/09/2026 19:46:11 +0200.** Le diff remplace le gate de présence runtime par la politique de readiness et ajoute le matcher restrictif. Son parent acceptait cette démo avec présence fraîche, même sans événement ready. Une sonde sur les fonctions exactes avant/après, avec les mêmes dépendances simulées, retourne :

~~~text
parent : target=session, source=27683, runtime=27691, remote_url produit,
         client_joinable=true, routing_reason=launch_ready
365c854 et code actuel : même destination,
         client_joinable=false, routing_reason=runtime_readiness_waiting
~~~

L'omission de transition_type côté Games est une incompatibilité du producteur avec ce nouveau contrat. Les ajustements UI Remote du 06/09 ne créent ni ce matcher ni la readiness et ne sont pas établis comme cause.

### Joueur intégré

**Classification observée E3 : destination historique produite et chargée, puis navigation vers Hub Play après le premier poll.** Aucun HTTP 302 du Play initial : il retourne 200. À 10:40:39 le poll projette S'=27685 ; le contexte démo conserve S=27683. La comparaison du client déclenche le retour une seconde plus tard, bien avant le retour du Master. La confusion porte sur **la présentation officielle utilisée pour contrôler le runtime démo**, pas sur l'id numérique du runtime envoyé à l'iframe.

**Changement introducteur local : Games 247b1f98437cc775455842e6d5a502498484b64a, 01/09/2026 16:09:08 +0200**, qui arme hubPresentation pour la démo dans player_canvas.php:164–185 afin de permettre le retour terminal. Le poll générique existait depuis d06eb4e8 du 12/07 ; il n'a pas reçu de distinction runtimeMode=demo. Il s'agit de l'interaction de ce nouvel armement avec le consommateur ancien, indépendante de la régression Remote du 04/09.

La sonde exécute checkHubPresentation réellement extrait du fichier, avec une réponse simulée :

| Présentation retournée / contexte démo source 27683 | Résultat local |
|---|---|
| session 27683 | Pas de retour |
| session 27685 | location.replace vers Hub Play |
| hub / id 0 | location.replace vers Hub Play |
| Aucun joueur Hub, mais ok=true et présentation différente | Même retour : l'identité Hub n'est pas requise |

E1 et E3 distinguent concrètement ces conditions avec le même Hub et le même jeu. Le retour E1 à 10:26:48, proche du retour Master, n'est pas classé comme erreur : sans trace WS terminale on ne tranche pas entre fin/quit et autre signal. E4 n'est qu'un maintien historique observé pendant 17 secondes après le premier poll, pas une recette complète réussie.

### Réponses obsolètes et cycle iframe

Remote : controlInFlight sérialise les polls, latestAppliedSequence protège leur application ; commandStatusRequestToken et commandId filtrent les anciennes réponses de commande. remoteRoutingStarted empêche une seconde navigation. Le filtre de retour compare E/génération ; la séparation runtimeTransitionPending/serverAccessTransitionPending du 06/09 pilote l'UI. Aucun de ces mécanismes ne crée l'événement ready manquant.

Player : checkHubPresentation sérialise les requêtes et verrouille le premier redirect, mais ne revalide ni E, ni runtimeMode, ni génération/contexte après await. Une réponse retardée d'une ancienne présentation peut donc provoquer le même défaut ; **condition supplémentaire plausible, non démontrée dans les logs**. La protection HubTransition diffère le retour pendant un terminal visuel déjà armé ; elle ne protège pas une démo ouverte contre une présentation officielle différente.

L'iframe compare son attribut src à sa destination calculée. Une navigation interne du Player vers Hub Play ne modifie pas nécessairement cet attribut ni __loaded. Reconfigurer le même src ne garantit donc pas sa récupération. Ce mécanisme explique la persistance possible du mauvais écran, mais aucune trace DOM n'en prouve le détail lors d'E3. Pas d'évidence d'iframe jamais chargée : les GET historiques sont présents pour les quatre essais.

## Complément — essai Master du Hub 292 à 14h10

### Preuves et niveau de vérification

L'utilisateur confirme la synchronisation supposée des fichiers locaux avec DEV et fournit les lectures DB suivantes : H=292, active_session_id=0, presentation_session_id=27698, presentation_mode=session, génération 1, intention preflight-mtr78a7i-k07pmc6ww0g, relais master_demo_launch commencé à 14:10:30. L'événement 365401 à 14:10:29 lie la source 27697 à la copie 27699 ; l'événement 365402 à 14:10:30 porte runtime_mode=demo, transition_type=preflight_demo_launch et E=hubexec-6904e710b6c90c63b640f74fcb1a702e. Aucun hub_remote_runtime_ready ni hub_execution_completed dans la lecture des 30 dernières minutes au moment où elle a été exécutée.

Les commandes Remote 458/461/510 sont confirmées completed, readiness_required=true, transition_type=NULL, générations 1/2/1. Ce sont des résultats fournis par l'utilisateur, pas des requêtes exécutées par l'agent.

Les fichiers fonctionnels locaux sont toujours propres aux mêmes HEAD Games c8c306b2 / Global 3b123b10. **Aucun écart concret entre les nouveaux comportements serveur et ces fonctions locales n'est identifié. Aucun rechargement global ni comparaison de fichiers n'est demandé.** Le mécanisme local est démontré ; les requêtes et événements persistants serveur sont corroborés ; l'identité binaire de la version servie n'a pas été vérifiée indépendamment. Cette réserve n'est plus un blocage de l'audit ni de sa proposition.

Le journal AI Studio raw fourni a été relu pendant ce complément : HTTP 200, Markdown extrait de l'enveloppe raw, dernière mise à jour toujours 28/08/2026 ; aucun nouveau chemin ciblé identifié. Les références raw D1/D2/D3 ont été relues. Le contrat de test isolé relève de [Games README raw, « Update 2026-08-31 - Diagnostic Hub : démo de contrôle »](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md) et de [Global README raw, « Update 2026-08-31 - Démo de contrôle Hub »](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md). La readiness des runtimes neufs relève de ce même Global README, section « Update 2026-09-04 - Hub: génération canonique de routage Remote ». Aucun droit de routage du Player démo par la présentation officielle n'y est trouvé.

### Chronologie E5 — Bingo, source 27697 / démo 27699

| Heure +0200 | Observation | Preuve |
|---|---|---|
| 14:10:27 | Master sélectionne la présentation officielle 27698 ; active_session_id reste 0. | Games error_log:5858, reason=master_program_select. |
| 14:10:29–30 | Copie démo 27699 puis exécution E5 ; le CTA est bien launch_hub_demo depuis Master, pas un lancement de carte prospect. | DB utilisateur 365401/365402 ; error_log:5859, hub_preflight_demo_create et hub_preflight_demo_launch, intention exacte, redirect_ready=1. |
| 14:10:30–32 | Résolution Master de D et S, puis chargement /master/{token-27699} HTTP 200. URL avec hub_launch=1, source=27697, E5, runtime_mode=demo ; aucun hub_remote_command. | error_log:5860–5861 ; access_log:24505. Branding Global 200, access/error_log:104. |
| 14:10:34 | /play/bingo/{token-27699} HTTP 200 avec embed=gm, gm_demo=1, demo_player=1, source/E5. | Games access_log:24512 ; error_log:5863 ; branding Global 200 access/error_log:105. |
| 14:10:34 | Signal de présence source=ready reçu pour H292/S27697/E5 ; POST Master HTTP 200. | Games error_log:5864 ; access_log:24514. |
| 14:10:35 | player_register « Joueur démo » insère le participant de D ; appel grid_assign. | error_log:5866–5867 ; access_log:24517–24518, HTTP 200. Le détail de la réponse grille et l'acquittement WS ne sont pas journalisés. |
| 14:10:35 | Premier GET active_launched_session depuis le Play historique : présentation 27698, focus actif 0, aucun cookie Hub/joueur. | access_log:24519 ; error_log:5868. |
| 14:10:35 | GET Hub Play HTTP 200 immédiatement après, même referrer Play démo ; identité Hub non résolue, interface d'entrée. | access_log:24520–24521 ; error_log:5869–5870, COOKIE_MISSING et id_hub_player=0. |
| 14:10:37–14:11:25 | Présence historique Master maintenue : 17 heartbeats espacés de 3 secondes, visibilité visible. La Remote reste sur son endpoint Hub. | error_log:5872–5890 pour les heartbeats ; Remote identifiée par le token de la requête error_log:5871, access_log:24522–24523, 24535, 24544, 24556. |
| 14:11:26 | Retour du Master au Hub, 51 secondes après le Player ; présentation 27698, focus actif 0 ; nouveau takeover à 14:11:27. | access_log:24558–24559 ; error_log:5891–5895. Origine utilisateur/WS de ce retour tardif non démontrée. |

La Remote exacte de H292 poursuit ses requêtes depuis le Hub à 14:11:41 et 14:11:57 (access_log:24569/24572). Aucun GET Remote historique de D/E5 n'est trouvé dans les logs rechargés, dont Games access_log va jusqu'à 14:13:13. Les actions POST Remote ne sont pas dans l'access_log : leur classement individuel control_poll/business_snapshot reste non observé ; il ne faut pas inventer leur JSON.

Les trois réponses 499 à 14:10:32 (access_log:24506–24508) concernent des requêtes de l'ancien Hub Master autour du départ historique. Elles ne sont ni un 400 de readiness, ni une redirection HTTP du Player ; aucune causalité avec les deux symptômes n'est démontrée.

### Ready reçu, validation silencieusement non acquise

Pour le CTA Master, le second callback commandé n'est **pas attendu** : hubRemoteLaunchContext exige hub_remote_command ; l'URL historique n'en contient pas. markHubRemoteLaunchReadiness retourne localement sans POST, après son diagnostic de contexte. L'absence de commande/id de commande n'est donc pas un défaut.

La voie utilisée est postHubRemoteRuntimePresence(source=ready). Dans le code local, app_games_hub_remote_runtime_presence_touch enregistre la présence puis consulte app_games_hub_remote_routing_intent_context_get et app_games_hub_remote_runtime_ready_signal_matches. Le type preflight_demo_launch est exclu du matcher. Cette branche peut donc retourner true et produire HTTP 200 sans insérer hub_remote_runtime_ready : **succès HTTP de présence ≠ succès de readiness**. Aucun message de refus métier interne n'est enregistré dans ce flux.

La DB fournie confirme le signal discriminant : exécution démo créée, mais marqueur ready absent dans la fenêtre lue. Les 17 heartbeats n'y remédient pas, car seul source=ready tente cette validation. Le runtime est classé new et reste non joinable localement ; la Remote ne quitte effectivement pas le Hub.

Conclusion : **absence de bascule Remote corroborée serveur, mécanisme de validation incompatible prouvé localement et cohérent avec la DB**. Aucun refus HTTP n'est constaté sur E5. Le motif exact appliqué dans la requête serveur n'est pas directement journalisé, ni le payload JSON du relais fourni ; il n'est pas revendiqué comme une trace de rejet explicitement capturée.

### Player : un retour de présentation, pas un retour terminal attesté

Le Player ne reste pas initialement sur Hub Play : il charge D, s'inscrit, demande sa grille puis quitte le runtime après le premier poll. Dans le code local, ce poll compare currentSessionId=27697 à presentation.session_id=27698 ; il appelle location.replace(hubPlayUrl) sans tenir compte du mode démo.

La chronologie et les marqueurs recoupent ce mécanisme : inscription et poll suivis du retour dans la même seconde, pas de cookies Hub, aucune exécution complétée dans la lecture DB, Master encore présent et actif dans ses échanges pendant 50 secondes supplémentaires. Le changement de présentation existait avant le clic : **une course entre deux réponses obsolètes n'est pas nécessaire pour reproduire cet essai**.

Le retour de 14:10:35 est classé comme intempestif par présentation, et non comme fin naturelle/quit démontré. Aucune trace de quit ou de fin naturelle de D n'est identifiée à cet instant. La présence seule ne prouve pas l'état interne du jeu et les messages WS ne sont pas disponibles : on ne prétend pas exclure mathématiquement tout signal terminal non journalisé. Le retour Master de 14:11:26 est un événement distinct dont l'origine reste inconnue. L'absence d'un événement completed dans la lecture fournie reste bornée à sa fenêtre et à son heure d'exécution.

### Contrat des NULL et portée causale

| Champ/absence | Qualification après contrôle du code |
|---|---|
| transition_type=NULL dans result_json des commandes 458/461/510 | Discriminant pour le matcher local : le consommateur lit ce champ, convertit absence/NULL en chaîne vide et le refuse. Confirme l'incompatibilité producteur/consommateur déjà identifiée ; ce n'est pas un troisième défaut indépendant. La projection SQL fournie ne distingue pas clé absente de JSON null, distinction inutile à ce rejet. |
| session_id absent du payload d'une commande launch_hub_demo | Normal pour un CTA global : le serveur choisit la source. La source est disponible dans result_json après traitement ; ne pas remplir le payload artificiellement. |
| hub_remote_command absent lors du CTA Master | Normal : lancement direct, hors commande Remote ; la présence source=ready doit suffire à produire la readiness canonique validée. |
| Colonnes JSON non communes aux actions hub_demo_launch_intent, hub_execution_started, readiness ou completed | Ne pas assimiler leurs NULL à des défauts : les schémas de payload diffèrent. |
| hub_execution_completed absent dans la fenêtre fournie | Pas un défaut supplémentaire établi ; ne pas créer une réparation de fin sur cette seule absence. |

Remplir seulement transition_type dans la commande avec preflight_demo_launch ne suffit pas : le matcher doit aussi reconnaître cette création démo. Inversement, élargir seulement le matcher laisse le résultat Remote vide. Aucune correction des champs non discriminants n'est proposée.

### Preuve ciblée possible, sans blocage général

Aucune nouvelle capture n'est indispensable pour maintenir les deux diagnostics et préciser le patch. Pour identifier le motif exact du matcher Master au-delà de la corroboration, la seule lecture complémentaire utile est celle du relais JSON courant, si l'intention est encore la même :

~~~sql
SELECT id, remote_routing_generation, remote_routing_intent_id,
       remote_transition_type, remote_transition_started_at,
       remote_transition_payload_json
FROM games_hubs
WHERE id = 292
  AND remote_routing_intent_id = 'preflight-mtr78a7i-k07pmc6ww0g';
~~~

Une ligne vide indiquerait une intention remplacée, pas une anomalie. Pour observer le routage côté navigateur lors d'une reproduction, capturer uniquement la réponse control_poll après source=ready (S/D/E, génération, joinable, readiness.reason, URL), et au besoin l'événement player/hub:presentation_redirect avec les signaux terminaux WS de cette seconde. Aucune comparaison globale de fichiers n'est requise par les faits présents.


## Proposition de correctif minimal — précisée après E5, non appliquée

Trois fichiers fonctionnels suffisent pour traiter les deux mécanismes ; aucun rechargement préalable général n'est requis en l'absence d'écart identifié.

1. **Global web/app/modules/jeux/hubs/app_games_hubs_functions.php** : reconnaître preflight_demo_launch comme un runtime neuf démo dans la validation canonique de readiness, en conservant les gardes Hub/source/exécution/intention/génération et en validant sa provenance démo ouverte/runtime exact. Ne pas transformer une présence en readiness, accepter un type vide ou enlever la garde sur la génération. Le mode existing officiel garde son contrat distinct.
2. **Games web/modules/app_hub_view_helpers.php** : inclure le transition_type réellement renvoyé par l'exécution dans le résultat persistant de games_hub_handle_master_remote_demo_command. Ne pas ajouter de source imposée par le navigateur au payload du CTA global. Avec le point 1, la voie commune source=ready peut produire le marqueur requis pour les deux origines.
3. **Games web/includes/canvas/play/play-ws.js** : exclure le contexte démo annexe validé du routage fondé sur la présentation officielle, avant le poll et avant toute navigation après await. Conserver hubPresentation dans player_canvas.php pour le retour terminal HubTransition ; ne modifier ni currentSessionId pour le faire artificiellement coïncider avec la carte, ni le focus, ni le routage des joueurs ordinaires. Aucun rechargement forcé de l'iframe n'est nécessaire pour traiter la cause.

Le callback additionnel remote_launch_readiness des commandes Remote doit être évalué séparément : son guard historique launch_session explique pourquoi il ne fournit pas de secours aux tests, mais la voie commune source=ready corrigée rend ce secours inutile pour la navigation. Éviter d'étendre d'office le contrat de ce callback, d'ajouter une boucle de retry, un write DB ou un patch boot_organizer.js à partir du seul HTTP 400 des essais antérieurs. L'acquittement de présence ne doit pas être annoncé comme preuve de readiness dans la recette.

Tests à compléter dans une passe de patch autorisée : partir des résultats réels produits par Master/Remote, vérifier preflight accepté avec identité exacte, chaîne vide et identité/génération discordantes refusées, ready persistant puis client_routing joinable ; vérifier le Player démo avec même/autre présentation, sans cookies, réponse retardée et fin naturelle/quit. Conserver témoins new/recreated/existing officiels et prospect. Les fichiers de test ciblés restent Global hub_client_routing_canonical_test.php / hub_demo_mode_contract_test.php, Games hub_demo_runtime_surfaces_test.php / hub_remote_polling_test.mjs et une sonde dynamique du poll réel Player.

Les changements introducteurs locaux restent **Global 365c8542 (04/09)** pour la readiness et **Games 247b1f98 (01/09)** pour l'activation du poll officiel sur le Player démo. Les nouvelles données ne prouvent pas la date de déploiement de ces commits. Aucun troisième défaut déduit des NULL, aucune migration, réparation de focus, membership démo ou purge de joueurs proposés.

## Lectures phpMyAdmin de la passe initiale — conservées pour référence

Les résultats fournis pour ce complément sont intégrés ci-dessus ; cette liste initiale ne constitue pas une nouvelle demande de lecture.

Base attendue d'après les traces : dev_cotton_global_0. Requêtes de lecture uniquement, à lancer sur la base choisie ; ne pas appeler le bootstrap PHP, dont les helpers de schema peuvent écrire. Les colonnes sont vérifiées dans le code Global local (définitions hubs:184–540) ; l'état réel du serveur peut différer. Les lignes de commande et événements apportent une preuve persistante ; l'état courant du Hub ne reconstitue pas rétroactivement sa présentation à chaque seconde.

### 1. Vérifier la base, l'horloge et les colonnes disponibles

~~~sql
SELECT DATABASE() AS db_name, NOW() AS db_now,
       @@session.time_zone AS session_timezone,
       @@system_time_zone AS system_timezone;
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('games_hubs', 'games_hubs_remote_commands',
                     'games_hubs_remote_runtime_presence', 'game_events',
                     'games_hubs_sessions', 'games_hubs_players_sessions')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
~~~

Permet de vérifier les noms/colonnes avant les requêtes suivantes et de comparer les timestamps DB aux logs +0200.

### 2. Focus, présentation et intention courants

~~~sql
SELECT id, id_client, hub_date, flag_active, active_session_id,
       presentation_session_id, presentation_mode,
       remote_routing_generation, remote_routing_intent_id,
       remote_transition_type, remote_transition_started_at,
       remote_transition_payload_json
FROM games_hubs
WHERE id IN (288, 289, 291);
~~~

Tranche sur l'état courant, la présence des colonnes générationnelles et la transition Master persistée. Aucune mutation ne doit être faite à partir de cette lecture.

### 3. Résultats des commandes de test

~~~sql
SELECT id, id_hub, command_type, status, created_at, claimed_at,
       completed_at, expires_at, error_code,
       JSON_UNQUOTE(JSON_EXTRACT(payload_json, '$.session_id')) AS requested_session,
       JSON_UNQUOTE(JSON_EXTRACT(result_json, '$.source_session_id')) AS source_session,
       JSON_UNQUOTE(JSON_EXTRACT(result_json, '$.runtime_session_id')) AS runtime_session,
       JSON_UNQUOTE(JSON_EXTRACT(result_json, '$.execution_id')) AS execution_id,
       JSON_UNQUOTE(JSON_EXTRACT(result_json, '$.runtime_mode')) AS runtime_mode,
       JSON_UNQUOTE(JSON_EXTRACT(result_json, '$.transition_type')) AS transition_type,
       JSON_UNQUOTE(JSON_EXTRACT(result_json, '$.routing_generation')) AS generation,
       JSON_UNQUOTE(JSON_EXTRACT(result_json, '$.readiness_required')) AS readiness_required
FROM games_hubs_remote_commands
WHERE id IN (458, 461, 510)
ORDER BY id;
~~~

Confirme completed, S/D/E/génération et l'absence présumée de transition_type. Un autre résultat impose de réévaluer la version serveur. Ne pas confondre completed de la commande avec disponibilité du runtime.

### 4. Exécutions, readiness et fins

~~~sql
SELECT s.id AS source_session_id, e.id, e.event_id, e.action, e.created_at,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json, '$.hub_id')) AS hub_id,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json, '$.execution_id')) AS execution_id,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json, '$.source_session_id')) AS source_id,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json, '$.runtime_session_id')) AS runtime_id,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json, '$.runtime_mode')) AS runtime_mode,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json, '$.transition_type')) AS transition_type,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json, '$.routing_generation')) AS generation,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json, '$.launch_intent_id')) AS launch_intent_id
FROM game_events e
JOIN championnats_sessions s ON s.id_securite = e.session_id
WHERE s.id IN (27683, 27686, 27695, 27689, 27690, 27691, 27696)
  AND e.action IN ('hub_demo_launch_intent', 'hub_execution_started',
                   'hub_remote_runtime_ready', 'hub_execution_completed')
  AND e.created_at >= '2026-09-07 00:00:00'
  AND e.created_at < '2026-09-08 00:00:00'
ORDER BY e.created_at, e.id;
~~~

Tranche sur la présence effective du marqueur ready pour chaque E, son type et la chronologie terminale. L'absence n'est probante qu'en l'absence de purge des événements. Une readiness E2 avec transition launch_new_runtime étayerait le témoin distinct ; elle ne valide pas le CTA annexe.

### 5. Isolation des copies et absence de mappings Hub démo

~~~sql
SELECT s.id, s.id_client, s.id_type_produit, s.flag_session_demo,
       s.flag_controle_numerique, s.date,
       hs.id_hub, hs.status AS membership_status
FROM championnats_sessions s
LEFT JOIN games_hubs_sessions hs ON hs.id_session = s.id
WHERE s.id IN (27683, 27686, 27695, 27689, 27690, 27691, 27696)
ORDER BY s.id, hs.id_hub;

SELECT id, id_hub, id_hub_player, id_session, game_type,
       id_participation, status, created_at, updated_at
FROM games_hubs_players_sessions
WHERE id_session IN (27689, 27690, 27691, 27696)
   OR (id_hub = 288 AND id_hub_player = 419)
ORDER BY id_session, id;
~~~

Les copies ne doivent pas être ajoutées au Programme pour résoudre le défaut. La seconde lecture distingue l'identité Hub 419 d'une éventuelle participation de test ; elle ne suffit pas à prouver l'identité WS du joueur automatique.

### 6. Présence runtime persistée

~~~sql
SELECT id_hub, id_session, execution_id, last_seen_at,
       created_at, updated_at, visibility
FROM games_hubs_remote_runtime_presence
WHERE id_hub IN (288, 289, 291)
  AND execution_id IN (
    'hubexec-f031a960a426b50b823f95c3f1ea905c',
    'hubexec-9e4be7947de9909fbe39b0131ebb618a',
    'hubexec-83df7dbbfc44221a2ae27fe266efec58',
    'hubexec-cf9d18bfdf5b18752854d901a1415007'
  )
ORDER BY id_hub, id_session, execution_id;
~~~

Cette table expose la dernière présence, pas tous les heartbeats ni leur acceptation comme readiness. Les logs prouvent déjà plusieurs touches ; le marqueur game_events reste la donnée discriminante.

## Recette et instrumentation minimale restante

Les logs couvrent maintenant les deux origines. Lors de la recette du patch : capturer un essai de CTA Master et un de CTA Remote avec logs réseau conservés. Pour l'intermittence, utiliser un Hub actif sans départ officiel, avec au moins deux sessions A/B ; le test conserve A comme première source. Faire un essai avec A présentée, puis B présentée, sans toucher au focus actif. Attendre au moins deux polls Player (30 secondes), puis tester quit et fin naturelle.

Capture minimale, sans changer le serveur :

- Réponses launch_hub_demo, command_status et control_poll : commande, S/D/E, génération, transition_type, joinable, readiness.reason et remote_url. Relever l'origine du CTA.
- Corps/réponse des POST remote_runtime_presence(source=ready) et remote_launch_readiness ; distinguer le 200 de présence du 400 de readiness.
- Dans l'iframe : AppConfig.hubPresentation, URL effective, attribut src, dataset.src et __loaded ; réponse active_launched_session et événement player/hub:presentation_redirect ; horodatages player/ready, chargement iframe, quit/fin WS et navigation.
- Réponses player_register / grid_assign et acquittement WS, en ne conservant que les identifiants nécessaires, aucun secret de grille ni token d'accès.
- État présentation avant chaque clic et après chaque réponse ; présence/absence d'identité Hub et reprise d'identité démo notées séparément.

Si une instrumentation temporaire devient nécessaire dans une passe autorisée, un log à chaque décision de readiness (accepté/refusé + motif, S/D/E/génération/type) et un log avant chaque navigation Player (runtimeMode, E, présentation cible, origine du signal) suffisent en première intention. Ne pas journaliser tous les polls ni des tokens.

| Cas de recette après correctif | Résultat attendu |
|---|---|
| CTA Master / CTA Remote, Quiz / Blind Test / Bingo, client actif | Même chaîne canonique ; nouvelle démo par nouvelle intention, Master et Remote sur D/E ; Remote attend readiness exacte. |
| Présentation A puis B, source de test toujours A | Joueur automatique reste dans D dans les deux cas ; focus et présentation officiels inchangés. |
| Retour fin naturelle / quit, puis second test | Retour des rôles au Hub, pas de rebond E/génération quittés ; nouvelle intention routable ; aucun résultat/stat Hub produit par la démo. |
| Réponse Player retardée, foreground/pageshow, changement A→B pendant le poll | Aucune réponse officielle ancienne n'expulse la démo ; retour terminal conservé. |
| Sans cookies Hub / avec cookie Hub 419 ou autre identité ; reload ; identité démo existante | Pas de contamination des identités, auto-register/réutilisation correcte, pas de mapping Hub pour D. |
| Desktop cohabitant / onglet Jouer mobile ; resize et reload | Une seule iframe active ; URL et identité de D ; panneau et limites historiques conservés. |
| Official numérique neuf/reprise, officiel papier Remote | Règles officielles de focus, injection, readiness new/recreated et absence de readiness existing inchangées. Joueurs ordinaires suivent leur contrat. |
| Prospect, source numérique / papier compatible / papier incompatible | Démo prospect distincte, garde numérique conservé ; refus incompatible ; aucun CTA annexe forgé accepté sans official_access. |
| Démo Dashboard Pro historique hors Hub | Pas de contexte Hub acquis par le seul branding ; fin et retour historiques conservés. |
| Master absent/remplacé, commande expirée, génération obsolète, mauvais E/S | Refus/terminal explicite, pas de readiness ou routage accordé à une autre intention. |

## Vérifications locales et limites

Sondes temporaires dans /tmp, sans édition du code audité ; sondes readiness et Player réexécutées au complément avec les mêmes résultats :

- hub-audit-readiness.php : fonctions exactes de matching/politique extraites ; refus test Master et Remote, acceptation témoin launch_new_runtime et resume_existing_runtime.
- hub-audit-route-before.php / hub-audit-route-after.php : resolver exact extrait du parent de 365c854 et du code courant, dépendances simulées identiques ; URL produite des deux côtés, joinable true → false.
- hub-audit-player.mjs : fonction réelle checkHubPresentation exécutée dans une VM Node ; présentation A → maintien, B/Hub → redirection.

Suites existantes exécutées :

~~~text
Global : php web/tests/hub_client_routing_canonical_test.php — OK
Global : php web/tests/hub_demo_mode_contract_test.php — OK
Games  : node web/tests/hub_remote_polling_test.mjs — OK
Games  : node web/tests/hub_transition_remote_test.mjs — OK
Games  : php web/tests/hub_demo_runtime_surfaces_test.php — ÉCHEC
~~~

La dernière suite échoue sur trois assertions du QR/notice commerciale Master : QR visible indisponible, texte deux joueurs, notice sous QR. Aucun changement fonctionnel apporté pour les faire passer. Ces assertions sont distinctes des sondes readiness/Player ; leur échec n'est pas présenté comme cause de la régression. Les suites vertes n'exercent pas la chaîne producteur réel launch_hub_demo → readiness ni le poll réel Player dans une démo avec une autre présentation.

Documentation : cette note, HANDOFF et TASKS Games/Global ; pas de README fonctionnel modifié puisque l'audit ne change pas le contrat. npm run docs:sitemap exécuté ; sitemap et index générés relus, lien de la note vérifié dans notes/INDEX.md, git diff --check réussi. La régénération actualise aussi les suffixes de version des index au HEAD documentaire courant. Aucun rollback applicatif nécessaire ; seules les modifications documentaires de cette passe peuvent être retirées.


## Correctif local autorisé — 2026-09-07, après le complément Hub 292

### Contrats et fraîcheur relus avant édition

START main, SITEMAP/README/manifest/HANDOFF develop et les README Games/Global raw ont été relus, ainsi que le journal AI Studio raw cité dans la section fraîcheur (HTTP 200, Markdown extrait ; dernière entrée 28/08). Aucun écart concret affectant ce patch n’a été identifié ; aucune comparaison globale demandée. Cette vérification ne constitue pas une validation de la version servie DEV.

- Isolation du test et deux CTA : [Games README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), section « Update 2026-08-31 - Diagnostic Hub : démo de contrôle » ; source et copie distinctes : [Global README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), section « Update 2026-08-31 - Démo de contrôle Hub ».
- Readiness des runtimes neufs, autorité canonique et générations : même Global README raw, section « Update 2026-09-04 - Hub: génération canonique de routage Remote » ; anti-rebond : même Games README raw, section « Update 2026-09-04 - Hub Remote: routage canonique générationnel ». Ces sections récentes remplacent l’ancienne formulation « présence » du paragraphe du 31/08, corrigée dans le README local.
- Retour terminal de la démo validée : Games README raw, section « Update 2026-08-31 - Diagnostic Hub : démo de contrôle ». Règle d’expulsion par présentation officielle : **non trouvé**. Contrat raw préexistant détaillant la compatibilité du callback commandé avec `launch_hub_demo` et le nouveau champ runtime du relais Master : **non trouvé** ; ce sont les adaptations locales décrites ci-dessous, nécessaires à la validation exacte, pas des règles prétendument déjà publiées.

### Changements réalisés

**Global — `web/app/modules/jeux/hubs/app_games_hubs_functions.php`**

Le type `preflight_demo_launch` devient compatible avec le matcher. La résolution canonique exige toutefois sa provenance réelle (`launch_hub_demo` ou relais `master_demo_launch`), la correspondance Hub/source/exécution/intention/génération, une exécution toujours ouverte de type preflight et mode démo, et un runtime démo distinct dont l’identifiant est identique dans la session, l’exécution et le résultat persistant. Type absent ou remplacé par un autre type pourtant connu : refus. Le relais Master sérialise maintenant `runtime_session_id` ; son filtrage explicite des champs est exécuté par le test, pas simulé par une copie libre du payload.

La politique interdit aussi la navigation d’un preflight dont le contexte canonique ne correspond plus, même si un ancien marqueur ready subsiste. `control_poll.client_routing` reste l’autorité, `new` exige le marqueur ; aucun heartbeat ne l’écrit.

Le callback `remote_launch_readiness` traite explicitement `launch_hub_demo` : commande exacte et contexte canonique vérifiés, appel de la voie commune `source=ready`, puis lecture du marqueur réellement enregistré. Les deux callbacks sont idempotents sur le même event_id. Un échec d’écriture sans marqueur renvoie `READINESS_WRITE_FAILED` ; le succès de présence ne masque pas cet échec. La branche historique `launch_session` est conservée.

**Games — `web/modules/app_hub_view_helpers.php`**

La commande Remote persiste le `transition_type` réel de l’exécution, sans fallback fabriqué. Le CTA Master transmet le runtime exact au relais Global. Le CTA ne choisit pas artificiellement une session fournie par le navigateur ; focus, présentation, Programme et roster restent inchangés.

**Games — `web/includes/canvas/play/play-ws.js`**

Le contexte démo validé côté serveur (enabled, source/runtime distincts, mode et exécution) court-circuite le poll de présentation officielle. Après les deux awaits, une réponse en vol est ignorée si le contexte a été remplacé ou est devenu démo. Un simple drapeau démo incomplet ne désactive pas le routage officiel. `hubPresentation` reste armé : les handlers réels de fin naturelle et de sortie continuent d’appeler HubTransition, délai de résultat inclus.

### Vérification locale

Deux nouveaux tests Games exécutent les fonctions de production :

- `php web/tests/hub_demo_readiness_flow_test.php` — **OK**. CTA Master réel et handler Remote réel → producteur Global et préparation/exécution → sérialisation effective du relais/résultat et publication générationnelle → présence ready → INSERT du marqueur → lecture et résolution canonique de navigation. Stockage SQL en mémoire ; limites externes (droits, thématique, duplication/reset jeu, HTTP) simulées. Aucun champ n’est ajouté au résultat du producteur par le test. Cas négatifs : Hub, source, exécution, runtime, mode, type absent/autre, intention, génération, exécution clôturée ; heartbeat seul, ancien marqueur et callback obsolète ; idempotence et échec d’écriture.
- `node web/tests/hub_demo_player_presentation_test.mjs` — **OK**. Poll réel, présentations A/B/Hub, deux passages, réponse fetch ou JSON retardée, contexte remplacé ou muté, joueur officiel et contexte démo incomplet. Handlers réels `HUB_SESSION_FINISHED` et `SESSION_ENDED:organizer_quit` exécutés avec le vrai HubTransition, timers contrôlés.

Preuve de régression : avec Global HEAD antérieur, le test échoue sur le marqueur Master absent ; avec Games HEAD antérieur et Global corrigé, il échoue sur le marqueur Remote absent ; avec le Player HEAD antérieur, il constate la redirection de la démo vers Hub Play. Les mêmes tests passent avec le patch. Le test du relais persistant a aussi reproduit son omission du runtime avant ajout du champ.

Suites existantes :

~~~text
Global php web/tests/hub_client_routing_canonical_test.php — OK
Global php web/tests/hub_demo_mode_contract_test.php — OK
Games node web/tests/hub_remote_polling_test.mjs — OK
Games node web/tests/hub_transition_remote_test.mjs — OK
Games node web/tests/hub_remote_return_execution_test.mjs — OK
Games php web/tests/hub_presentation_runtime_separation_test.php — OK
Games node web/tests/hub_demo_reentry_runtime_test.mjs — OK
Games php web/tests/hub_demo_runtime_surfaces_test.php — mêmes 3 ÉCHECS QR/notice préexistants
~~~

Lint PHP des fichiers applicatifs et vérification syntaxique module JS : OK. Les trois assertions QR/notice n’ont pas été modifiées. Ces tests ne constituent ni un accès SQL réel, ni une recette navigateur DEV, ni une validation des serveurs WS. Aucun schéma, accès DB ou déploiement effectué.

### Recette DEV courte restante

1. Client actif, Hub avant premier lancement officiel : noter la première source A du Programme et présenter une autre carte B. Ouvrir Hub Master et Hub Remote ; noter focus, présentation et génération.
2. Depuis le CTA annexe **Master**, lancer un test. Relever S/D/E/génération, chargement historique Master/Player, signal ready, marqueur `hub_remote_runtime_ready`, puis `control_poll.client_routing.joinable=true` et URL Remote du même D/E. Un HTTP 200 de présence seul ne valide pas cette étape.
3. Vérifier « Joueur démo » dans le Play historique pendant au moins **35 secondes**, soit deux cadences de poll de 15 secondes. Pour cette démo validée, aucun appel de présentation officielle ne doit être nécessaire ; la vue doit rester historique malgré B.
4. Sortir : retours au Hub, aucun rebond vers le couple quitté. Relancer un nouveau test et vérifier la nouvelle intention/génération et la nouvelle disponibilité. Refaire une passe jusqu’à la fin naturelle.
5. Refaire les étapes 2–4 depuis le CTA annexe **Remote**, Master présent. Vérifier aussi le callback `remote_launch_readiness` : succès ready confirmé, plus de 400 de type de commande ; refus conservé pour contexte obsolète.
6. Témoins : joueur officiel suivant sa présentation, lancement neuf/recréé et reprise officielle existante, puis démo prospect. Focus et présentation de B, Programme, roster et statistiques officiels ne sont pas modifiés par le test annexe.

### Livraison et limites

Patch **local uniquement**, trois fichiers fonctionnels et deux nouveaux tests. La future livraison doit coordonner le helper Games et Global (type et runtime persistés) avec le JS Player ; les anciens résultats incomplets ne sont ni réécrits ni acceptés par défaut. Recetter avec une nouvelle intention de test. Les données DB déjà fournies suffisent à ce patch ; aucune nouvelle requête demandée.

README/TASKS Games/Global, Handoff, Changelog et cette note actualisés ; sitemap/index régénérés et relus. Pour annuler le patch, retirer uniquement les hunks de cette passe dans les trois fichiers et les deux nouveaux tests, en préservant les travaux préexistants. Aucun rollback DB nécessaire.


## Recette navigateur DEV validée — essais après 14h40, 2026-09-07

L’utilisateur confirme « Recette OK sur navigateur ». Les logs Games/Global rechargés corroborent deux essais Bingo du Hub 292, source officielle **27697**, présentation officielle **27698**, focus actif **0**. Aucun changement fonctionnel supplémentaire, accès DB ou déploiement effectué pendant cette passe. Les conclusions d’audit et le statut « DEV restant » des sections précédentes sont historiques ; cette section actualise la validation.

| Origine | Contexte | Chronologie +0200 et preuves Games |
|---|---|---|
| Master | D=27702 ; E=hubexec-b419238726fe67823852f7d7cb518be6 ; intention preflight-mtr8eg3a-0z04r04wpxoq ; génération 2 | Création 14:43:16 (error_log:5944), Master historique 200 à 14:43:19 (access_log:25071), Player historique et ready à 14:43:21 (25078 / error_log:5949), inscription Joueur démo à 14:43:22 (error_log:5951), Remote historique 200 à 14:43:22 (25085). Player revient au Hub à 14:44:06 (25121), Remote à 14:44:07 avec E/génération 2 (25122), Master à 14:44:08 (25126). |
| Remote | Commande 511 ; D=27703 ; E=hubexec-2fffc6bb35b2eecdd464b7d243ba42a9 ; intention remote-command-511 ; génération 3 | Commande 14:44:22, création 14:44:24 (error_log:5983–5984), Master historique 200 à 14:44:26 (access_log:25148), Player historique et deux touches ready à 14:44:29 (25156 / error_log:5990–5991), deux POST Master 200 (25161–25162), Remote historique 200 à 14:44:33 (25170). Fin naturelle à 14:45:39, runtime 27703, result=completed (error_log:6068), Player revient à 14:45:42 (25265), Remote puis Master à 14:45:43 (25266–25267). |

Le Player reste dans l’intervalle historique **45 s** puis **73 s**, au-delà des deux cadences de 15 s demandées. Aucun GET `active_launched_session` avec referrer de ces Players historiques n’est retrouvé dans la fenêtre. La présentation 27698 et le focus 0 sont encore résolus aux retours (error_log:5974–5978 et 6070–6072) : pas d’alignement artificiel de la présentation sur la source. Le maintien visible est confirmé par la recette utilisateur ; les logs seuls ne sont pas une capture DOM continue.

La Remote quitte désormais effectivement le Hub pour chaque D/E/génération. Les deux touches ready du second essai et les deux POST 200 sont cohérents avec la présence ready et le callback commandé corrigé ; l’access_log ne contient pas leurs corps. Aucun 400 n’apparaît sur ces deux requêtes. Le marqueur SQL ready et le JSON `control_poll.client_routing` ne sont pas capturés directement par ce lot : leur chaîne est validée localement, et la navigation réelle la corrobore, sans prétendre avoir effectué une nouvelle lecture DB.

Le retour du second Player suit la fin naturelle confirmée de trois secondes : c’est un retour terminal légitime, contrairement au retour intempestif de 14:10:35. Le premier retour est groupé avec ceux de Remote/Master ; son déclencheur exact (quit/fin) n’est pas explicitement journalisé, donc pas requalifié arbitrairement. Aucun nouveau GET vers la première Remote historique après son retour ; le nouveau test part avec génération 3. Après le second retour, la Remote reste au Hub dans la fenêtre disponible jusqu’à 14:46:07 : aucun rebond historique observé.

**Statut : les deux régressions sont validées en recette navigateur DEV sur les essais Master et Remote retrouvés.** Les témoins officiels/prospects et les autres jeux conservent leur validation locale déjà consignée ; ce lot ne prouve pas à lui seul une recette navigateur exhaustive de cette matrice. Aucun nouvel essai ou SQL n’est demandé pour clôturer ces deux symptômes.

Handoff et TASKS actualisés, statut README précisé ; sitemap/index régénérés puis relus. Aucun nouveau test automatisé exécuté : cette passe ne modifie que la documentation et corrèle la recette réelle.


## Clôture des trois assertions QR/notice — audit documentaire et tests uniquement

Les trois échecs préexistants de `games/web/tests/hub_demo_runtime_surfaces_test.php` ont été confrontés au renderer actuel et aux décisions UX. **Tous trois sont obsolètes ; aucun défaut fonctionnel n’est établi sur ces écarts.** Aucun code d’interface, démo ou branding n’est modifié dans cette passe.

Navigation documentaire : START main rechargé, SITEMAP.txt develop puis index Games et README raw référencés ; Handoff raw et note UX liée depuis ce README consultés. Sources :

- **Q1** — [Games README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Update 2026-09-07 — Remote UX, Master découverte, panneau droit et grand QR » : Mode découverte, QR à sa place désactivé avec verrou, seule phrase « Tes joueurs rejoindront la partie ici. », aucun CTA commercial ; QR actif « SCANNE POUR JOUER ».
- **Q2** — même Games README raw, « Update 2026-09-01 - Mode démo Hub Master : information sans CTA commercial », complément explicite du 07/09 : remplace la notice du 01/09 ; la limite de deux joueurs ne change pas, sa mention dans cette notice n’est plus requise.
- **Q3** — [note UX raw référencée par le README](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/notes/hub-remote-master-ux-audit-2026-09-07.md), « Changements appliqués » : confirme le verrou, aria-disabled, la phrase exacte et le retrait des anciennes notices.

| Assertion initiale | Rendu actuel constaté dans le SSR | Décision et preuve |
|---|---|---|
| Présence des classes QR/pastille et du texte `Non disponible en démo` | Classes conservées, QR visible ; en découverte `aria-disabled=true`, `data-hub-qr-clickable=0`, wrapper is-demo-disabled, cadenas bi-lock-fill et libellé accessible `Participation indisponible`. Le texte ancien n’est plus rendu. | Obsolète pour la copie attendue, pas pour l’indisponibilité. Q1/Q3 décrivent précisément le remplacement. |
| Texte `Teste le déroulé de ta soirée. La version complète est disponible après abonnement.`, absence de `.hub-demo-notice a`, déclaration CSS littérale | `Mode découverte` puis unique paragraphe `Tes joueurs rejoindront la partie ici.` ; aucun lien dans ce paragraphe. Le libellé du test annonçait une limite de deux joueurs, mais son expression ne vérifiait aucun nombre ni plafond runtime. | Obsolète : Q2 remplace explicitement cette notice et conserve séparément la limite runtime. Règle actuelle imposant de mentionner deux joueurs dans ce paragraphe : **non trouvé**. Aucun test de plafond runtime n’a été retiré. |
| Position d’un `<aside class="hub-demo-notice"` après `data-hub-qr-container` dans le fichier source | Un `<p class="hub-demo-notice">` est réellement rendu sous la section QR, avant les commandes utilitaires ; absence de cette notice pour client actif. | Obsolète pour la balise et la méthode de contrôle. Q1/Q2/Q3 imposent la phrase pédagogique, pas un aside commercial. Règle imposant la balise aside : **non trouvé**. Position sous QR conservée et testée sur HTML produit. |

Expressions exactes avant correction :

~~~php
$expect(strpos($helpers, 'hub-master-join-box__qr') !== false && strpos($helpers, 'hub-master-join-box__demo-unavailable') !== false && strpos($helpers, 'Non disponible en démo') !== false, 'Hub Master keeps the player QR visible but marks it unavailable during demo testing');
$expect(strpos($helpers, 'Teste le déroulé de ta soirée. La version complète est disponible après abonnement.') !== false && strpos($helpers, 'hub-demo-notice a') === false && strpos($helpers, 'background: var(--secondary-bg); color: var(--secondary-text);') !== false, 'Hub Master demo notice explains the two-player limit without an ecommerce CTA');
$expect(strrpos($helpers, '<aside class="hub-demo-notice"') > strpos($helpers, 'data-hub-qr-container'), 'Hub Master commercial demo notice is rendered below the player QR');

~~~

Le README raw comportait encore dans « Update 2026-08-31 - Diagnostic Hub : démo de contrôle » une description ancienne de pastille textuelle/notice commerciale avec lien. Elle est explicitement remplacée par Q1/Q2, plus récents, et par Q3. Ce passage contradictoire du README local a été harmonisé ; aucune règle métier nouvelle ni modification d’interface.

### Couverture remplacée, non supprimée

Le test modifié appelle le vrai `games_hub_render_page(..., 'master')` sur deux contextes commerciaux, prospect et actif. Le seul fournisseur commercial est isolé ; aucun accès DB/navigateur requis. Il vérifie QR présent/non masqué, état désactivé et cadenas uniquement prospect, libellé accessible, absence de clic/agrandissement prospect, contrôle d’agrandissement actif, titres exacts selon le contexte, unicité et contenu exact de la notice, placement après QR et avant utilitaires, absence des anciennes copies. Les autres assertions de la suite sont conservées.

Résultats :

~~~text
Games php web/tests/hub_demo_runtime_surfaces_test.php — OK
Games php web/tests/hub_remote_master_ux_test.php — OK
Games php -l web/tests/hub_demo_runtime_surfaces_test.php — OK
git diff --check — OK
~~~

Les résultats rouges des sections d’audit antérieures restent l’historique de la passe initiale ; ils ne représentent plus un point ouvert. La validation DEV des correctifs démo et branding confirmée par l’utilisateur est préservée. Cette passe ne prétend pas refaire une recette navigateur.

Handoff/TASKS actualisés, README harmonisé, sitemap/index régénérés et relus. Aucun patch fonctionnel nécessaire, donc aucune nouvelle lecture DB ou recherche de fichier serveur requise. Aucun déploiement. **Les trois écarts sont clos.**


## Complément UX — QR joueurs prospect réellement neutralisé — 2026-09-07

Nouvelle demande utilisateur après clôture, capture `Screenshot 2026-09-07 15.12.45.png` : le vrai QR demeurait physiquement scannable sous le verrou. Ce complément ne rouvre pas l'audit des trois assertions ; il remplace explicitement leur ancien attendu visuel. Correctifs démo et branding validés en DEV conservés. Patch de ce complément local uniquement, sans déploiement ni nouvelle recette DEV revendiquée.

### Preuves et fraîcheur

- [START raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), « Discipline de génération » ; SITEMAP texte/markdown et DOCS_MANIFEST raw rechargés, README général et Handoff raw consultés. [DOCS_MANIFEST raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers (mapping) » : README/TASKS Games, Handoff, Changelog puis génération des index.
- [README Games raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Update 2026-07-27 — Hub Master: podium agrégé de soirée/événement » : usage courant client prioritaire, contexte historique Hub en fallback. Le code utilise `games_hub_master_wording_labels_get` et son `noun_with_article`, jamais le titre libre.
- Même URL raw, « Update 2026-09-01 - Mode démo Hub Master : information sans CTA commercial » : information fonctionnelle sans CTA commercial Games. Nouveau dessin non scannable et deux formulations exactes : **non trouvé dans la documentation raw préexistante** ; décision utilisateur explicite de ce complément.
- [Journal AI Studio raw](https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb) consulté avant patch par HTTP après échec du lecteur web ; dernière entrée « 28/08/2026 > dev (ai_studio + www) > Campagne Rentrée ». Aucun chemin touchant les deux sources Games concernées identifié. Pas de demande de rechargement global ; mécanisme local démontré, version serveur de ce complément non vérifiée. Aucune DB nécessaire.

### Cause et changement local

`app_hub_view_helpers.php` rendait en découverte un `data-hub-qr-container` portant la vraie URL Play. `hubMasterRenderQrCodes` l'encodait même avec clic désactivé ; le CSS réduisait seulement l'opacité sous le cadenas. Le refresh réexécutait le générateur. Le dialogue agrandi actif, extérieur au fragment prizes, pouvait aussi survivre à un changement de contexte commercial.

La branche prospect rend maintenant un SVG statique de cadre de scan et cadenas, sans matrice QR, URL, lien ni attribut de génération. Une seule carte contient le badge, l'illustration et les deux paragraphes. Copie contextuelle : `Tes joueurs s’inscriront à la soirée en scannant ce QR code.` / `Tes joueurs s’inscriront à l’événement en scannant ce QR code.` ; état secondaire : `Inscription indisponible en mode découverte.` Illustration bornée à la largeur disponible et à 180px/28vh, texte sans hauteur fixe, fond et couleurs existants.

Le renderer QR s'arrête en découverte. Le refresh réconcilie le dialogue après remplacement de la carte : fermeture par le contrôleur pour libérer le fond inert/restaurer le focus, puis retrait de l'ancien dialogue. En actif, insertion depuis le HTML frais seulement si le dialogue manque ; aucune reconstruction de celui déjà présent. L'adaptateur Master de `hub_player_qr.js` refuse affichage/commandes en découverte même avec un poll disponible retardé. L'illustration n'accuse jamais réception d'un vrai QR affiché. Aucun changement Global, droits serveur, routage, API, schéma, commandes Remote ou interfaces historiques.

Fichiers de ce complément : Games `web/modules/app_hub_view_helpers.php`, `web/includes/canvas/core/hub_player_qr.js` ; tests `hub_demo_runtime_surfaces_test.php`, `hub_remote_master_ux_test.php`, `hub_player_qr_test.mjs`, `hub_demo_qr_reentry_contract_test.php`. Les autres modifications du workspace sont préservées.

### Validation locale

- Vrai renderer PHP : huit combinaisons prospect/actif et contexte client/Hub ; priorité usage client sur contexte contradictoire, fallback et titre libre trompeur. Prospect sans cible QR réelle ni dialogue, carte unique et textes exacts ; actif avec URL canonique et agrandissement.
- JS : exécution des fonctions réelles de génération/réconciliation extraites du PHP ; QR actif encodé, aucun encodage prospect même avec cibles résiduelles ; suppression du dialogue, focus/inert, contrôle retardé, absence de confirmation QR, clic refusé, retour actif et conservation du dialogue ouvert aux refresh actifs.
- Onze suites **OK** : `hub_demo_runtime_surfaces_test.php`, `hub_remote_master_ux_test.php`, `hub_demo_qr_reentry_contract_test.php`, `hub_demo_readiness_flow_test.php`, `hub_branding_sync_test.php`, `hub_player_qr_test.mjs`, `hub_demo_player_presentation_test.mjs`, `hub_demo_reentry_runtime_test.mjs`, `hub_branding_sync_test.mjs`, `hub_remote_polling_test.mjs`, `hub_remote_return_execution_test.mjs`. Commandes depuis Games : `php web/tests/<nom>.php` ou `node web/tests/<nom>.mjs`.
- Lints PHP des quatre fichiers PHP touchés, `node --check` des deux fichiers JS touchés et `git diff --check` : **OK**. Les contrats historiques de QR démo et le générateur dédié de QR télécommande restent couverts ; aucune preuve de scan navigateur n'est revendiquée.

### Recette DEV restante et retour arrière

1. Ouvrir un Master prospect soirée puis événement, avec un titre libre trompeur. Vérifier badge/illustration/explication réunis, contexte exact, statut d'indisponibilité, absence de CTA commercial ; desktop et format étroit supporté.
2. Scanner l'illustration au téléphone : aucune donnée QR. Cliquer, tenter d'agrandir, attendre au moins deux polls, provoquer un refresh de branding puis recharger : aucun vrai QR joueurs révélé.
3. Sur un client actif, vérifier scan vers Hub Play, agrandir/réduire et refresh pendant agrandissement. Vérifier séparément appairage télécommande découverte et scan de participation à une démo historique.
4. Si un changement commercial est disponible en recette, passer d'un Master actif agrandi à découverte : fermeture, fond utilisable, aucun retour du QR malgré une réponse retardée ; retour actif fonctionnel.

Livrer ultérieurement ensemble les deux sources Games après recette autorisée. Aucun déploiement dans cette passe. Retour arrière : retirer uniquement les hunks de ce complément (vue, adaptateur et tests), jamais restaurer globalement les fichiers déjà modifiés pour démo/branding. Cela rétablirait le défaut de QR prospect scannable.
