# Audit — sas initial des sessions numériques Hub — 22/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-initial-session-sas-audit" owner="codex" -->

**SAS SESSION FAISABLE SANS CHANGER LE PIPELINE WS.** Cette conclusion porte sur la séparation ouverture/enregistrement/démarrage, prouvée dans le code local. Elle ne signifie ni « 5 000 joueurs validés en charge », ni « fin de vague détectable avec les signaux actuels ». Le mécanisme de convergence reste à décider. Aucun patch applicatif, marker, déploiement, redémarrage ou accès DB/service réel.

Complément du 22/09 : [audit détaillé du pipeline](hub-player-registration-pipeline-audit-2026-09-22.md). La faisabilité du sas ne qualifie pas la charge : wrappers Bingo sérialisant l'auth (5 HTTP nominaux et snapshot complet), publication BT quadratique, roster capacité répété. Le nouveau périmètre inclut une dépendance ecommerce signalée au journal, à recharger ; son coût interne n'est pas audité. Les chronologies ci-dessous décrivent les jalons fonctionnels, le complément explicite les opérations intermédiaires.

## 1. Chronologie commune : deux branches concurrentes

Le clic Master desktop/mobile poste `launch_session`, `launch_intent_id`, `master_instance_id` ; `hubMasterNavigateToLaunch()` ouvre `redirect_url`. Preuves : `games/web/modules/app_hub_view_helpers.php:2951,9648,10310`.

Depuis Remote, `app_hub_remote_ajax.php:1236,2848` crée une commande `launch_session`. Le Master la réclame dans `games_hub_handle_master_remote_control_poll()` (`app_hub_view_helpers.php:3502`) et traite le lancement ; la Remote ne devient pas le moteur gameplay. Le résultat et la readiness sont corrélés à l'exécution/génération de routage.

Le producteur commun est `app_games_hub_session_launch_from_master[_locked]()` dans `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:10191` : validations/intention → focus officiel → contexte d'exécution → génération de routage → URL Master. **Créer ce contexte Hub n'est pas créer la session mémoire WS.** Le premier Master Quiz/BT la crée lors de `registerOrganizer` ; Bingo restaure son contexte depuis les données persistées à l'authentification.

**Pas d'injection massive numérique aujourd'hui.** La branche officielle numérique saute `app_games_hub_session_inject_active_players()` (`:10549–10570`, motif `digital_presence_runtime`). La formule documentaire ancienne « injection + redirection + auto-start » ne décrit donc plus exactement cette branche. Papier et démo ont leurs traitements distincts.

Dès le focus, indépendamment du boot Master : Hub Play → watcher `active_launched_session` (tick immédiat puis 3,5 s après chaque réponse) → `app_games_hub_get_active_launched_session_for_player()` → `app_hub_player_resolve_session_access()` → ensure participation/mapping individuel → `play_url` → `location.replace()` → bootstrap Player. Preuves Global `:9239,9253,9435,10608,10720`, Games `app_hub_view_helpers.php:12690–12717`.

`app_games_hub_session_is_auto_joinable()` vérifie focus, non-terminal et non-expiré, **pas `running`** : le Player peut donc arriver en attente, voire avant la session WS Quiz/BT ; cette dernière répond alors `registrationError`. Aucun ordre global n'impose « ACK organizer puis ouverture Player », et aucun ACK Player ne conditionne l'auto-start. Un ensure PHP réussi prouve une participation persistée, pas un socket enregistré.

## 2. Chronologie et déclencheur par moteur

| Moteur | Master / runtime disponible | Player réellement rattaché | Déclenchement gameplay |
|---|---|---|---|
| Quiz | Boot Canvas/préchargement → `session/init` → `registerOrganizer(isPrimary:true)` → création `sessions[sid]` en `En attente` → `registrationSuccess(role:primary)` → `initializeOrUpdateSession` → `startAutoSync()` → `organizer/runtime-ready` | Bootstrap HTTP historique `player_register` ou restauration → `player/ready` → `authenticatePlayer()` → `registerPlayer` → bind socket → `registrationSuccess` → `getGameState` | Auto-start attend seulement `organizer/runtime-ready`, puis `beginPlayFlow({source:'hub'})` → intro → `Game.handleUI({type:'play'})` → `displaySupport()` → état local `En cours` / `game/started` → `initializeOrUpdateSession` WS. Après intro, `intro/ended` → `ui/next` → première question. |
| Blind Test | Même séquence WS que Quiz, serveur propre | Même handshake et ACK ; `registerPlayer()` propre au serveur BT | Même lecteur commun et événements ; options/morceaux BT propres. Après intro, premier morceau ; timer lié à `support/started`, hors mode manuel. |
| Bingo | Boot → `auth_client` → restauration/hydratation → premier `state` authentifié ; le connecteur publie l'état WS ouvert → `startAutoSync()` → `organizer/runtime-ready`. **Pas de `registerOrganizer` / `registrationSuccess` natif.** | Ensure Hub `player_register` → après navigation `grid_assign`/`grid_hydrate` → `player/ready` → `auth_player` avec grille/token et clé joueur → bind → `state` authentifié. **Pas de `registerPlayer` / ACK Quiz natif.** | `beginPlayFlow()` → `ensureBingoStartReset()` : `reset(target_phase:1, clear_players:false)` et `reset_ack` corrélé → intro/`game/init` → lecteur commun `play`/`game/started` → `playing_state(true)` ; `question/rendered` produit `song_start` pour la progression morceau. |

Preuves communes : `games/web/includes/canvas/core/ws_effects.js:326–410`, `boot_organizer.js:1598–1744,1795–1810`, `core/player/index.js:1690–1745`, `core/session_sync.js:79–112,130–174,186–235,263–287`, `play/play-ws.js:966–1073`, `play/register.js:1241–1334,2602–2946`.

Preuves serveurs : Quiz `web/server/actions/registration.js:66–110,450–683`, `gameplay.js:208–344` ; BT `registration.js:70–111,450–690`, `gameplay.js` fonction `initializeOrUpdateSession` ; Bingo `ws/bingo_server.js:855–996,1078–1174,1456–1558,1561,1708` et `ws/repository/db/db_player_repository.js:12`.

**Position de « En cours ».** Quiz/BT : l'appel `displaySupport()` précède immédiatement l'affectation locale, sans attendre le démarrage effectif du média ; l'état WS arrive ensuite par snapshot. Avec le jingle initial, `En cours` précède la première vraie question/chanson. Ce n'est donc pas une preuve que le premier média joue déjà. Sans intro, ne pas inventer un ordre réseau absolu entre rendu/support et snapshot. Bingo : phase 1 dès le reset, puis lecture via `playing_state`, puis progression via `song_start` ; ces trois jalons sont distincts. Le mapping Player considère la phase 0 comme attente (`play-ws.js:1037`).

## 3. Preuve du sas avant gameplay et lobby historique

Quiz/BT créent explicitement le runtime en `En attente`. `checkSessionStatus()` déclare la session active si elle existe, n'est pas pleine/suspendue/en échec ; il n'exige pas `En cours`. `registerPlayer()` n'exige pas non plus ce statut, mais vérifie identité/admission/capacité. Les guards de suspension/expiration restent applicables. Le Master et la Remote secondaire peuvent s'enregistrer avant Play. Preuves : `registration.js:31–110,450` ; dispatch `actions/wsHandler.js:414–433`.

Bingo : authentification organisateur/joueur et lecture d'état existent en phase 0, sans reset ni lecture. Le repository d'authentification contrôle grille/token/joueur et ne conditionne pas l'auth à une phase commencée. Phase 0 + `is_playing:false` est le sas naturel. L'état `Pause` doit rester une reprise d'une partie déjà démarrée.

Historique encore observable dans le code : accès `/master/{token}` sans `hub_launch` → ouverture/enregistrement en attente → lobby Player `checkSession` → formulaire → HTTP `player_register` → événement `player/ready` → handshake WS → Play explicite organisateur. L'auto-start est conditionné par `hubLaunchAutoStart` (`organizer_canvas.php:142–156`, `boot_organizer.js:1795`). Hub remplace la saisie par mapping/auto-submit et ajoute ensure+routage ; `bootHubAutoRegister()` réutilise le submit historique et peut contourner sa sonde initiale. **Même handler WS final, parcours d'entrée différent.**

Optimisations retrouvées dans le code et son histoire Git :

- Quiz `c2a96b3` et Blind Test `077c245`, 28/11/2025 : `PLAYER_LIST_INTERVAL_MS=1000`, une publication immédiate puis au plus un timer différé par session. Toujours présent dans `registration.js:402` / BT `:408`. C'est un throttle, pas une détection de silence.
- `updatePlayerListNow()` : déduplication par identité, tri/rangs partagés, top 50 organisateur en jeu ; liste complète en attente/Pause ; chaque Player reçoit score/rang/total, pas toute la liste (`quiz/.../gameplay.js:1043`, BT `:1257`).
- Bingo : dès le commit `27a6266` du 20/01/2026, auth en deux étapes, parties marquées dirty, flush périodique 1 s, digest pour éviter les doublons, liste organisateur/Remote et compteur seul pour Players. Toujours actif (`bingo_server.js:238–248,875,979,3891`). Auth DB par requêtes simples sans transaction (`db_player_repository.js:12`).

**Limite importante à l'hypothèse « pipeline historique éprouvé inchangé ».** Aujourd'hui chaque `registerPlayer` Quiz/BT appelle `CanvasAPI.hubCapacity()`, et chaque `auth_player` Bingo appelle `hub_capacity_get` (`Quiz/BT registration.js:489`, Bingo `:903`). `envUtils.js` effectue un POST HTTP ; pas de mutualisation de cet appel trouvée dans ce chemin. La réponse Hub contient notamment les clés actives utilisées pour reconstruire le Set d'admission (`actions/hubCapacity.js`). S'ajoutent les scans d'identité/comptage. Les optimisations de diffusion persistent, mais ne prouvent pas le débit du pipeline actuel à 5 000. Aucun nouveau cache/batch proposé dans cet audit.

## 4. Faisabilité et emplacement recommandé

1. **Oui**, runtime/Master enregistré/joueurs enregistrables avant gameplay existe déjà dans les trois moteurs.
2. **Oui**, retarder uniquement le départ dans `boot_organizer.js`, après `waitForOrganizerRuntimeReady()` et avant `beginPlayFlow()`, laisse ouverture/WS/routage fonctionner.
3. **Oui**, les Players s'inscrivent pendant ce délai, sous réserve des gates existantes et de leurs propres latences HTTP/WS.
4. **Oui au niveau protocole** pour Master/Remote. Le code publie déjà présence/readiness avant `beginPlayFlow`. Le futur patch doit rendre le sas visible/opérable, traiter les commandes Play concurrentes, annulation/remplacement et les délais des voiles de transition ; insérer seulement un timer ne suffit pas à valider l'UX.
5. **Pas de modification WS nécessaire pour cette séparation.** Un éventuel nouveau signal serveur de stabilisation exigerait une évolution WS distincte ; il n'est pas décidé ici.
6. Couche commune la plus basse qui conserve le contexte Hub et précède les effets des trois jeux : **boot du Master session**, frontière `organizer/runtime-ready` → `beginPlayFlow`, pas PHP Hub ni handler d'inscription. Ne pas attendre après `runIntroIfNeeded()` : Bingo a alors déjà lancé son reset/phase.
7. **Oui**, le sas peut rester indépendant du nombre de joueurs. Aucune attente séquentielle d'ACK, égalité de populations, durée proportionnelle, nouvelle requête par joueur ou polling de liste n'est nécessaire pour ouvrir cette fenêtre.

Les signaux existants (`updatePlayers`, `num_connected_players`, dirty/timers/digest, `lastSeenAt` individuel, logs `PLAYER_WS_BOUND`) ne constituent pas un contrat de fin de vague : hydratation sans socket, reconnexions, roster papier et requêtes encore en vol les rendent ambigus. L'ACK est individuel, et le Master ne reçoit pas une preuve exhaustive des ACK Player. **Aucun signal robuste agrégé de silence d'inscription avec travaux en vol trouvé dans les chemins audités.** Ne pas choisir ici un seuil final. Le watcher Hub attend déjà 3,5 s entre réponses : une fenêtre trop courte peut expirer avant le prochain poll, même sans forte charge. Un délai borné peut atténuer la course, jamais garantir tous les joueurs.

## 5. Cas à préserver, risques et futur périmètre

| Cas | Contrainte pour un futur patch |
|---|---|
| Premier officiel numérique | Sas unique avant intro/reset/Play ; contexte exécution/génération encore courant au déclenchement. |
| Reprise officielle existing | Conserver `hubResumeExisting`, `hubResumedSessionPaused`, snapshot Pause, aucun auto-start. |
| Suspension / recréation | Conserver grant/ACK de reprise et restauration ; ne pas assimiler `runtime_kind=recreated` à « première partie ». Préchargement déjà commencé implique Pause. |
| Démo | Exécution annexe sans injection joueurs Hub ; exclure du nouveau sas officiel, conserver reset et réentrée démo terminale. |
| Papier | Injection/réconciliation et parcours papier actuels ; exclure du sas numérique. |
| Hub Master / Hub Remote | Même boot session final ; Remote garde corrélation commande/exécution et readiness, pas de deuxième moteur de démarrage. |
| Master mobile | Même POST et navigation, `master_surface=mobile` ; tester les gestes audio/autoplay après attente. |
| `/master/{token}` direct | Sans opt-in Hub valide : lobby et Play explicite inchangés. |

Preuves reprise : `organizer_canvas.php:142–156`, `boot_organizer.js:1199–1225,1795–1850`, Global `app_games_hubs_functions.php:10438–10541`. Risques : Play Remote/UI contournant le sas, double départ après reconnexion, timeout/écran masqué, focus changé pendant attente, démarrage d'une ancienne exécution, mobile/autoplay, charge pré-game des listes complètes.

**Bingo : course handlers déjà corrigée dans le code local.** `ws_effects.js` attache `startAutoSync()` avant `publishOrganizerRuntimeReady()`, attendu par l'auto-start. Un délai arbitraire ne remplace pas cette barrière déterministe. Conserver aussi `reset_ack` et idempotence du reset ; le sas doit être placé avant `ensureBingoStartReset()`. Le défaut historique documenté n'est pas à déclarer encore présent sans preuve d'un serveur différent.

Fichiers candidats, sans patch : `games/web/includes/canvas/core/boot_organizer.js` (principal), `games/web/organizer_canvas.php` si exposition explicite du contexte premier/officiel/numérique nécessaire ; présentation/transition Games si nécessaire pour le sas visible. `core/ws_effects.js`, `core/session_sync.js`, Remote et `app_hub_view_helpers.php` sont des frontières à protéger, pas des modifications imposées. **Aucun fichier WS, glue d'inscription, Global ou marker requis par la seule séparation.** Si signal nouveau retenu ultérieurement : cadrer séparément `quiz`/`blindtest` `web/server/actions/registration.js` et Bingo `ws/bingo_server.js` avec leurs markers.

## 6. Vérification et tests à ajouter

Exécuté sans réseau applicatif : `node /home/romain/Cotton/games/web/tests/hub_active_resume_test.mjs` → OK, première ouverture auto-start / reprises Pause sans auto-start ; identité Quiz/BT et auth Bingo avec repository simulé. Ce test ne mesure pas une vague réelle. Inspection statique et historique Git pour le reste ; aucun test de charge ou navigateur annoncé.

Tests futurs :

- Pour chaque moteur : runtime prêt et Player ACK pendant attente, zéro support/timer/item avant libération ; un seul départ après libération.
- Retards organisateur, auto-sync et ACK ; Players avant Master, pendant sas, après départ ; échec HTTP individuel et reconnexion.
- Bingo : auth `state` rapide, handlers liés avant événements, zéro reset pendant sas, reset une fois/ACK corrélé, puis phase/lecture/morceau cohérents ; grilles conservées.
- Reprises existing, suspendue et recréée : index/temps/scores conservés, Pause puis seul Play explicite ; papier/démo/hors Hub inchangés.
- Master/Remote/mobile : commandes concurrentes, annulation, focus/remplacement, expiration, double clic/reload, audio bloqué, visibilité et sortie d'erreur du sas.
- Charge jusqu'à 5 000 sur environnement autorisé : mesurer latences ensure/admission/grille/ACK, event-loop et premier item ; vérifier zéro appel ajouté par le sas, pas d'attente de population, publications regroupées. Inclure la capacité Hub actuelle dans la mesure.

**DB : aucune requête nécessaire pour la décision architecturale.** Les mesures de performance et la parité des fichiers déployés restent non établies ; aucun SQL inventé.

## 7. Sources documentaires, journal et traçabilité

Lecture agent-first effectuée : [START, « Parcours » et « Règle preuve d'abord »](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), [SITEMAP texte](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), [README, « Doc discipline »](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md), [Manifest, « Update triggers »](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), [HANDOFF, actions du 21/09](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md).

[Games README develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), sections « Update 2026-07-08 — Hub master: lancement direct depuis programme » et « Update 2026-07-15 — Hub: validation papier puis retour après fin naturelle » : historique du lancement et correction Bingo. La description du 08/07 est historique, la branche numérique actuelle saute l'injection.

Cartes consultées : [Quiz](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/quiz/README.md), [Blind Test](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/blindtest/README.md), [Bingo](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/bingo.game/README.md). Comparaison des mêmes README RAW sur `main` : **écart develop/main pour les quatre cartes**, donc ne pas annoncer la parité PROD ; aucune datation de déploiement déduite de cet audit.

Journal AI Studio demandé consulté le 22/09 (réponse HTML contenant `const raw`, contenu décodé pour lecture). **Aucun fichier du lancement Games, des fonctions Hub Global ou des trois serveurs WS audités n'y est signalé modifié hors workspace.** Les modifications signalées concernent notamment WWW/communication/backoffice, authentification Pro et ecommerce Global, hors périmètre du sas. Aucun rechargement ciblé imposé identifié à ce jour ; ce n'est pas une preuve de synchronisation serveur. Avant tout patch futur, relire ce journal et recharger les fichiers ciblés si une nouvelle entrée les concerne.

Seuls le présent rapport, les TASKS Games et HANDOFF sont modifiés pour consigner l'audit ; index/sitemap régénérés. Pas de README fonctionnel ni CHANGELOG : aucun comportement modifié. Rollback : retrait de cette note/entrées puis régénération documentaire ; aucun rollback applicatif.

<!-- AUTO-UPDATE:END id="hub-initial-session-sas-audit" -->
