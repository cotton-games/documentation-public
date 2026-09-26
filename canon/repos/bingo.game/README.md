<!-- AUTO-UPDATE:BEGIN id="hub-suspend-20260910-bingo.game-readme" owner="codex" -->

**25/09 — Robustesse d’exécution Hub, patch local non déployé.** Organizer seul publie le runtime ; consommateurs Bingo sans restore, candidats Quiz/BT provisoires et writers réservés au primaire. Retries bornés même E/joueur/event_id avec fence serveur ; probes concurrentes terminées/nettoyées. Pregame, reveal Remote, reprises et reset au départ conservés. Analyse main/develop/pregame : sous-lots isolables, adaptations Bingo/PHP/Player WS nécessaires, aucun main modifié. [Détail, tests, limites et backport](../../../notes/hub-execution-robustness-backport-2026-09-25.md).

**25/09 — C révisé, local non déployé : retrait Hub durable immédiat ; cleanup runtime non bloquant.** Tombstone + membership inactive + slot closed/removed + focus/présentation libérés dans la demande PHP, réponse removed/already_removed ; aucun moteur requis. Le moteur vivant observe le tombstone puis détache/ferme les sockets sans finaliser le Hub. Read retiré explicite, lifecycle/START/Player tardifs refusés, cleanup tardif sans mutation ; gameplay sain protégé. Ancien removing finalisable en retentant le retrait, sans réconciliateur. A/B, ensure, auto-start5s/10s/5s/90s, compteur et UI pregame conservés. Tests :20 suites principales,26 scénarios retrait moteur/retour,300 vérifications retrait PHP ; compléments admission/publics/Pro/fallback verts, effets externes simulés. [Contrat, fichiers et rollback C : section AC](../../../notes/hub-open-players-foundations-2026-09-24.md). Markers25-09-2026/02 préparés ; aucun deploy/restart.


**Contrat courant pregame (24/09, local non déployé) :** départ automatique demandé, minimum5s / grâce sans bind10s / calme WS5s / watchdog exceptionnel90s, sans plafond normal. Remplace le départ exclusivement humain décrit dans les entrées historiques ci-dessous. Binds WS effectifs seuls ; compteur numérique regroupé sur250ms, sans effet sur le timer serveur. Signal HUB_PREGAME_AUTO_START au primary → ui/play → START/ACK existant, guards préservés. Aucun quorum ; zéro valide. Ensure/mappings/papier/démo inchangés. Tests auto37/37, UI20/20 ; vagues de5000 sockets simulés par moteur, charge DEV réelle et navigateur restant à qualifier. Détails, fichiers et rollback : section T de la note V2. Aucun déploiement/restart. Minimum depuis open accepté, indépendance de l’animation250ms ; CTA Démarrer le jeu et styles dédiés supprimés sur Master/Remote, seul retour volontaire conservé. Textes adaptés au départ automatique. Retry ACK avec request_id stable par E et reprise du même START en starting ; watchdog demandé/accepté tracé distinctement.


## 24/09/2026 — Open Players V2, local non déployé

**25/09 — Hub-native livré en DEV selon l’opérateur ; correctif Remote/reprise local, non déployé.** Remote : `client_routing` canonique de même session/E/génération redevient l’autorité ; aucun ACK Remote attendu, iframe masquée tant que son écran opérationnel n’est pas rendu. Reprise : preuve first_start existante → aucune préparation Open Players, même E/runtime ; Master premier lancement toujours révélé à l’ACK. Moteur5/10/5/90, instrumentation, trois contrôleurs WS et markers inchangés. [Audit, tests et recette ciblée](../../../notes/hub-open-players-foundations-2026-09-24.md#ah-correctif-ciblé-remote-et-reprise-après-recette-dev--25092026).

Contrôleur `hubPregame` relié aux handlers réels : preuve d’initialisation serveur, mutations interdites avant Lancer, snapshot Player neutre, compteur distinct lié à identité/participation/socket/E, abandon sans suspension ni résultat. Premier départ consommé après preuve gameplay ; incarnation perdue pendant Open entraîne fermeture, jamais création E2. Bingo : aucun reset Open/Abandon ; operation_id stable au premier Lancer, reset canonique idempotent et grilles conservées. [Contrat et recette](../../../notes/hub-open-players-foundations-2026-09-24.md).


## 23/09/2026 — Hotfix minimal depuis hub_soiree

**Hotfix `hub_soiree` : livraison/essai PROD signalés par l’opérateur le 23/09 ; parité exacte des fichiers serveur non vérifiée.** Incident Player Bingo cloclo toujours ouvert ; les pistes de correction du rapport ne sont pas appliquées. Admission WS ciblée des Players Hub officiels numériques déjà admis et reprise de la même intention après timeout technique organisateur. Aucun sas Player, readiness composite, roster/délai/compteur nouveau, protocole `HUB_PLAYER_READY`, runner ou optimisation de charge. Git en lecture seule : aucun nouveau commit ni branche.

`auth_player` utilise le contrôle ciblé lorsque le lifecycle fournit une exécution officielle. Mapping/participation sont relus ; ID participation comparé au Player authentifié par grille/secret. Auth, grille individuelle, queue reset/versionnement et payload state historiques conservés. [Fichiers, dépendances, tests et limites](../../../notes/hub-soiree-hotfix-2026-09-23.md). Les sections readiness ci-dessous décrivent la branche `hub_session_readiness`, pas ce hotfix.


## 23/09/2026 — Préparation Hub E1

**Branche `hub_session_readiness` : NON DÉPLOYÉE EN PROD, exclue du hotfix `hub_soiree`.** Les recettes DEV et tests locaux ci-dessous ne valent pas livraison PROD. Préparation reset durable avant preuve finale, contrôle génération/post-reset, admission ciblée et pipeline optimisé ; aucun reset implicite de partie démarrée. [Contrat, reprise sélective, fichiers, validations et limites](../../../notes/hub-session-readiness-2026-09-23.md). Les descriptions sas_players antérieures ne constituent pas le contrat de lancement de cette branche.


## Hub Browser Bingo — baseline locale prête

[Contrat, fichiers, AVANT/APRÈS et recettes](../../../notes/hub-bingo-browser-baseline-2026-09-22.md). Même noyau Browser que Quiz ; N1–200 prepared, session officielle numérique du même Hub, grilles réelles avant launch, aucune auth anticipée. Ready exige grille exploitable, state corrélé et post-reset terminé. Gameplay off, stop/cleanup communs sans désallocation. 66 tests Games +27 Bingo +4 AVANT verts ; qualification DEV50/200 à faire. DEV Bingo/BT attesté `hub_soiree`, aucun snapshot requis. Bundle AVANT séparé, pas de performance ni sas ; marker Bingo `/05` préparé, APRÈS `/06`, aucun restart/déploiement réalisé. Les sections précédentes ci-dessous restent l'historique de leurs lots.

### 22/09/2026 — Harnais WS A/B instrumenté, non déployé

[Contrat, schéma, livraison instrumentation seule et rollback](../../../notes/ws-loadtest-ab-instrumentation-2026-09-22.md). Runs explicites cold/profiles, plafond 5 000 tentatives, session exclusive jusqu’au stop/drain, ACK réel Quiz/BT puis state ; premier state Bingo et queue serveur distingués. Résumé INFO unique, B/N capacité, publication BT, I/O/queue Bingo, bytes et process. Aucun algorithme métier/Hub modifié. Outils moteurs préparés sur `sas_players` ; export AVANT sur références `hub_soiree` figées. Markers AVANT réservés Quiz/BT22/09 /02, Bingo /03 ; APRÈS dans les worktrees Quiz/BT /03, Bingo /04. Aucun restart/déploiement exécuté ; aucune qualification de charge réelle déduite des tests synthétiques.


### Statut de livraison — 23/09/2026

`hub_soiree` : **déployé en PROD selon confirmation opérateur**. `sas_players`, `hub_session_readiness` et `cast` : **évolutions propres NON DÉPLOYÉES EN PROD**, même si leurs descriptions sont reprises dans la documentation `main`. Les anciens statuts datés restent l’historique des interventions, pas l’état courant. [Périmètres, références et limites](../../deployment-status.md).


## 22/09/2026 — Auth numérique : routage allégé, state Player sans roster

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](../../deployment-status.md).

`auth_player` : prélecture DB grille+secret → playlist, puis queue reset avec validation playlist et authentification complète fraîche. Le `reset_state` initial de routage est supprimé ; pré/post guards conservés. Nominal DB :4 HTTP/5 SELECT directs (6 legacy), contre5/6 (8 legacy). Le premier `state` Hub non-démo ne contient plus `players`, conserve le compteur exact et tous les autres champs ; papier/démo/hors Hub et organisateur/Remote gardent leurs payloads. Le tri disparaît de ce chemin, le merge et les scans restent.

Queue couvrant encore toute l’auth et lifecycle frais par joueur : aucun gain capacité nominal, aucune qualification5 000. Attribution/stock/grilles/locks, reset/reprise et guards inchangés. Marker Bingo `restart 22-09-2026/02`, restart futur requis, non exécuté. [Audit, patch et qualification](../../../notes/bingo-digital-auth-performance-2026-09-22.md).


## 22/09/2026 — Capacité Hub mutualisée au transport

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](../../deployment-status.md).

[Contrat et limites](../../../notes/hub-capacity-publication-patch-2026-09-22.md) : cohortes fermées avant fetch, sans cache réutilisé ensuite ; stock/verrou/allocation/auth inchangés. Auth séquentielle : pas de gain nominal attendu. Marker22/09 /01, restart futur requis, non exécuté.


## 21/09/2026 — PATCH 3 association papier facultative (local)

`admin_phase_winner` papier résout K/D depuis le roster actif/admis PATCH1 (`paperPlayersByGame`), après relecture partagée. K exclusive ; D facultatif doit correspondre ; D seul retrouve K et nom même sans socket. Token/game/exécution contrôlés, aucun pseudo lookup ni création. Sans joueur : aucune recherche. Inconnu/inactif/conflit/lecture échouée : aucune identité visuelle, chemin de validation sans joueur conservé.

Master et Remote reçoivent le D et le nom résolus. Un ACK HTTP déjà persisté reste prioritaire même si l’association est introuvable : pas de seconde avance. Grilles, validation manuelle/automatique, score/podium et fin naturelle inchangés. `bingo_paper_player_association_resolve` journalise le résultat sans pseudo. Autres usages numériques du resolver conservés. Marker Bingo `/03` ; aucun restart. [Rapport PATCH3](../../../notes/bingo-paper-association-patch3-2026-09-21.md).


## 21/09/2026 — PATCH 1 inscription et roster papier (local)

Bind utilise le même lecteur actif que l’hydratation ; K prioritaire, D secondaire, grilles mémorisées conservées. Réconciliation papier5s, publication num_connected_players réconciliée explicite, state partiel, conservation du terminal vide. Marker21/09 /02 ; aucun restart exécuté.

[Contrat canonique](../../interfaces/paper-roster.md) · [Rapport et validation](../../../notes/paper-roster-patch1-2026-09-21.md). Tests isolés, sans DB réelle ; aucun déploiement.


## Update 2026-09-21 — Jauge Hub et upsell (local, non déployé)

Probe/auth numérique et papier relisent la capacité serveur ; hydratation live filtrée sur le roster Hub actif. Stock de grilles complété par le générateur Global, avec offset de numérotation et sans supprimer les affectations. Démo à 2 et garde WS maintenues.

Offre effective = autorité commerciale. Maximum N Hub actifs ; probable sans place ; left libère une place et sa réactivation en nécessite une. Snapshots techniques synchronisés uniquement vers le haut ; downsell hors périmètre. [Contrat, tests et limites](../../../notes/hub-capacity-upsell-2026-09-21.md).


### Expiration confirmée du runtime officiel — 18/09/2026, patch local non déployé

Perte involontaire du Master → grâce moteur de 1 h, runtime exact encore reprenable. Au callback réel, invalidation locale puis notification service-only `hub_session_grace_expired` avec identité mémorisée lors de `hub_lifecycle/read`. Le journal `game_events` reçoit `hub_runtime_expired`, idempotent par exécution, avant cleanup final. L’exécution reste ouverte et la phase persistante reste inchangée : ce n’est pas une fin naturelle.

Global refuse la réutilisation, les commandes de reprise et la création officielle de remplacement (`HUB_RUNTIME_EXPIRED`), y compris `force_new`. Clear du focus conditionné à la session, génération et activation ; autre exécution protégée sous verrou Hub. Master/Remote : « Suspendue », sans Reprendre/Relancer ; Play non joignable, résultats et présentation historique conservés. Suspension explicite : aucun marqueur d’expiration, reprise disponible après plus d’une heure tant que le cutoff est ouvert. Aucun changement ownership Remote, présence/génération Master, démos, fin naturelle ou cutoff.

En cas d’échec de livraison, le moteur garde ce runtime invalidé et réessaie (2/4/8/16/30 s puis 30 s). Crash avant persistance : aucune mort inférée du heartbeat ou du focus ; la notification en mémoire n’est pas durable. Identité officielle absente/obsolète : aucun marquage d’une exécution choisie a posteriori. [Contrat, tests et livraison](../../../notes/hub-runtime-expired-2026-09-18.md).


### Robustesse suspension/reprise — 18/09/2026, patch local non déployé

Bingo `forcedDisconnect` porte `replacement_reason=same_continuity_reconnect|takeover`. Même navigateur **et** même `remotePageId` éphémère : reconnexion de page. Après suspension, une autre page du même navigateur peut remplacer silencieusement l’ancienne socket si celle-ci a été retirée par le serveur après release et si son couple exécution/request correspond au lifecycle désormais repris. C’est une preuve de retrait, pas une barrière de reprise : aucune attente Remote ni ACK ajouté. Deux pages actives distinctes, autre appareil ou identité insuffisante : takeover explicite. Le registre installe le nouveau propriétaire avant fermeture ; anciennes commandes refusées, cleanup par socket, terminaison après500ms si nécessaire. Front : arrêt des reconnects/timers/envois, close explicite après suspension, aucune modale ni navigation pour le motif de continuité ; événements d’une ancienne socket ignorés par le transport.

`HUB_SUSPEND_REQUESTED` précède l’envoi front et la persistance serveur ; `trigger=master_button|remote_button|session_not_found`, surface, request_id, Hub, exécution, source/runtime numériques, génération/intention et page éphémère. Le relais Bingo conserve ces diagnostics ; PHP relit les identités et la publication canoniques, puis garde le même request_id dans `hub_suspended` et `hub_suspend_released`. Liste explicite de champs, aucun token de session/reprise/accès ajouté au diagnostic. Les anciens clients sans diagnostic produisent `unspecified` ; aucune causalité rétrospective inventée pour Hub120/session30700/runtime17898.

[Tests, limites multi-onglet et rollback](../../../notes/bingo-hub-resume-robustness-2026-09-18.md).


### Préparation d’un test Hub — 17/09/2026, local non déployé

Le producteur Global copie la playlist courante dans une playlist démo isolée, phase0, morceaux/grilles neufs pour deux joueurs numériques. La préparation Hub n’appelle plus `resetdemo` sur cette copie : cet appel redondant sans `event_id` causait `BINGO_RESET_REQUEST_REQUIRED`. Le reset historique Bingo, sa génération, ses gardes et le service WS ne changent pas. Retry d’intention = même copie ; nouvelle action Hub = nouvelle copie. [Audit et tests](../../../notes/hub-demo-lifecycle-patch-2026-09-17.md).


## Suspension officielle Hub — patch local du 10/09/2026

En exécution Hub officielle prouvée, « Suspendre » remplace le quit destructeur : Pause, runtime/roster/scores/progression conservés, focus libéré conditionnellement, retour Master/Remote au Hub. La déconnexion involontaire conserve la grâce Santeuil ; le quit historique et les démos conservent leur contrat terminal. Ces règles remplacent, pour ce seul contexte, les descriptions anciennes de quit Hub terminal.

La reprise `existing` conserve l’exécution et le runtime vivant, sans injection, avec une autorisation explicite à usage de génération et un retour en Pause. Une autre session active bloque la reprise. Après fermeture de la fenêtre `hub_date` (J+1 midi Europe/Paris), aucune activation officielle n’est autorisée. Les boucles de maintenance existantes libèrent les suspensions expirées sans fin naturelle. Après restart : restauration existante best-effort, sans snapshot durable complet ; le marqueur persistant continue de bloquer une reconnexion non autorisée.

[Contrat, limites et validation locale](../../../notes/hub-suspend-patch-2026-09-10.md). Patch non déployé, aucun service redémarré, aucune DB réelle sollicitée.

`ws/hub_lifecycle.js` et les handlers Bingo gèlent les commandes/vérifications/winners. Les Maps restent en mémoire ; collision `idPlaylistClient` refusée pour un runtime conservé. Le registre existant accepte une Remote courante par jeu ; toutes les surfaces encore attachées reçoivent le signal.

Correctif local du 11/09/2026 : Les refus WS `HUB_SOCKET_UNAUTHORIZED` incluent `execution_id` et `runtime_session_id` avec `request_id`, pour que le Master traite le refus immédiatement au lieu d’attendre le timeout. Marker préparé : `restart 11-09-2026/01`, aucun restart exécuté.

11/09/2026 — Retour Play immédiat autorisé : Quiz/Blind Test/Bingo incluent désormais les sockets Players de la session dans les destinataires de `HUB_SESSION_SUSPENDED`, émis uniquement après succès de release/clear focus. Le handler Play valide contexte officiel, execution_id, runtime_session_id, token sessionId et request_id non vide ; il bloque les reconnects et revient directement au Hub Play, une seule fois, sans flux terminal. Les démos et signaux obsolètes sont ignorés. Le polling15s corrigé reste en secours ; une réponse HTTP déjà en vol ne provoque pas de seconde navigation.

### Reset Bingo historique — 11/09/2026, local non déployé

`resetdemo` et le reset WS de lancement réutilisent `_bingo_reset_demo_state` en conservant session, joueurs et grilles. `game_events.bingo_reset_operation` porte une génération persistée et un journal pending/completed récupérable ; les tables historiques MyISAM interdisent de supposer un rollback intégral. Verrou par playlist, garde `bingo_reset_generation` avant écritures/replays, purge des caches WS et localStorage versionné. Les nouveaux joueurs restent autorisés à prendre une grille libre ; un propriétaire retrouve la sienne sans consommer le stock. [Contrat, fichiers, tests, limites et recette](../../../notes/bingo-reset-generation-patch-2026-09-11.md). Marker Bingo préparé `restart 11-09-2026/03`, aucun restart exécuté.


### Notifications gagnantes Bingo — 16/09/2026, patch local

Live numérique et déclarations administratives utilisent `ws/bingo_winner_notification.js` : `1 → LIGNE`, `2 → DOUBLE LIGNE`, `3/5 → BINGO`, accord gagné/gagnée, nom et grille optionnels. À l’authentification Master/Remote, le repository lit `bingo_phase_winners` pour le token authentifié et la playlist, joint joueur/grille, puis reconstruit `state.notifications` avec le même formatter. La phase gagnée fait autorité, jamais la phase courante avancée.

Déduplication par event_id (sinon phase normalisée + joueur) ; remplacement des logs gagnants correspondants à leur emplacement. Les anciens logs génériques sans event_id sont rapprochés par phase, dont le winner est unique dans l’API canonique ; les anciens textes live par phase/nom. Les autres logs et les phases sans winner exploitable restent inchangés. Un `id` stable dérivé de l’event_id empêche aussi le rejeu du buffer Master. La phrase générique reste stockée, sans migration ni nouveau write. Schéma ancien sans table/champ requis : fallback logs ; les autres erreurs SQL restent propagées.

Master/Remote gardent leur flux et leur UI ; parser Remote vérifié sur les quatre codes. Overlay `phase_over` inchangé. Noms lus à l’hydratation depuis le joueur actuel : aucune archive du nom au moment de la victoire n’est ajoutée. Une jointure sans joueur exploitable conserve le log historique.

<!-- AUTO-UPDATE:END id="hub-suspend-20260910-bingo.game-readme" -->

# Repo `bingo.game` — Carte IA d’intervention (canon)

## Update 2026-08-27 — Index de phase papier aligné
- Contrat confirmé: `phases_liste` contient le sentinelle initial `0`; `phase_courante` est l'index 0-based dans cette liste complète, pas dans une liste filtrée de phases jouables.
- `advancePhaseWithoutWinner` réutilise ce contrat via `bingo_phase_progress.js`. Une phase 1 sans joueur sur `0,1,2,5` écrit l'index `2`, de sorte que la victoire identifiée suivante persiste bien la phase 2 sans décalage.
- Le log `BINGO_MANUAL_PHASE_ADVANCE` expose grille, lignes 0-based, phase demandée, index avant/après, liste complète et résultat. Aucun write `phase_winner` n'est ajouté au cas sans joueur.
- Les chemins numériques, l'idempotence HTTP-first des gagnants identifiés et l'état terminal `nextPhase=-1` restent inchangés. Marker: `restart 27-08-2026/01`.

## Update 2026-08-25 — Quit volontaire Hub reprenable
- `sessionEndedGames` reste un guard mémoire d'idempotence du terminal `SESSION_ENDED` volontaire, pas la source de vérité d'une fin définitive métier.
- Lors d'un `quitGame forced=false`, Bingo WS émet au plus un `SESSION_ENDED organizer_quit` par cycle actif, déconnecte les Players et pose `sessionEndedGames.add(gameID)`.
- Lors d'une reprise Organizer réellement prouvée (`auth_client` qui annule `primaryReconnectTimers`, puis `ORGANIZER_RECONNECTED` / `GAME_RESUMED_SENT`), Bingo WS réarme ce guard via `sessionEndedGames.delete(gameID)`, sauf si `naturalEndCompletedByGame` ou `hubNaturalTransitionByGame` indique une fin naturelle définitive.
- Les reconnects Remote/Player seuls ne réarment pas le guard. Un double quit sans reprise reste idempotent et loggué `BINGO_QUIT_ALREADY_HANDLED`.
- Logs de recette: `BINGO_QUIT_GUARD_RESET` expose `reason=organizer_resume`, `was_guarded`, `natural_end_completed`, `hub_natural_transition_present` et `reset`.
- La fin naturelle reste séparée: `bingo:end_game` -> `hub_session_natural_ended` -> `HUB_SESSION_FINISHED` demeure le seul chemin de persistance terminale Hub/résultats.
- Marker: `restart 25-08-2026/01`.

## Update 2026-08-24 — Quit volontaire Hub Remote
- La Remote Bingo historique s'enregistre dans `remotesByGame` avec la clé canonique `gameID = idPlaylistClient`. Une reprise/relance `auth_remote` remplace l'ancienne socket enregistrée pour cette même clé avant d'accepter la nouvelle.
- Le quit volontaire lancé depuis la Remote reste relayé à l'Organizer par `remote_action=remote_quit_request`; Bingo transmet aussi `sessionId` dans ce relais. L'Organizer exécute le contrat Master, puis Bingo reçoit `quitGame forced=false`.
- Bingo WS journalise désormais `quitGame_received` dès l'entrée du handler, avant la branche `forced`, pour prouver l'arrivée effective du maillon Organizer -> serveur.
- Le terminal volontaire Bingo est maintenant `SESSION_ENDED` avec `reason=organizer_quit` et `terminal_reason=organizer_quit`. Ce marqueur distingue le quit volontaire de la grâce organizer et de la fin naturelle `phase_over` / `HUB_SESSION_FINISHED`.
- L'envoi Remote du terminal volontaire passe par `sendMsgToRemote(..., { traceHubRemoteBingoTerminal:true })` et journalise `hub_remote_bingo_terminal_delivery` sans secret ni payload complet: `game_id`, `message_type`, présence registre/socket, état socket, tentative, succès et raison d'échec.
- Les logs hors contexte Hub du 2026-08-24 prouvent que le serveur produit correctement `SESSION_END` puis `hub_remote_bingo_terminal_delivery send_success=true` quand `quitGame` arrive; la correction Hub porte donc sur la garantie d'envoi Organizer avant redirection.
- Marker: `restart 24-08-2026/03`.

## Update 2026-07-15 — Validation papier et fin naturelle Hub
- La dernière victoire papier est d'abord persistée par `phase_winner`; `next_phase=-1` déclenche ensuite côté WS `bingo:end_game`, sans dépendre de la présence du Master.
- `phase_over=-1` n'engage plus directement la barrière Hub. Le Canvas peut émettre `game/ended` pour demander le write, mais seul le succès de `bingo:end_game` autorise `hub_session_natural_ended` puis `HUB_SESSION_FINISHED`.
- Un verrou `naturalEndInFlightByGame` coalesce Remote et Master; l'`event_id` terminal est stable. En erreur, `paper_score_finalization_state=awaiting_score_validation` conserve l'UI et aucun podium terminal n'est diffusé.
- La transition Hub réussie est mémorisée pour rejouer le signal à un Master reconnecté. Marker: `restart 15-07-2026/01`.
- Après `bingo:end_game` réussi, le WS demande `hub_session_natural_ended`; il diffuse `HUB_SESSION_FINISHED` aux clients, Remote et Players seulement si Canvas confirme `hub_execution=true`.
- Le signal transporte désormais `runtimeMode=demo` lorsqu'il clôt une exécution annexe Hub. La fenêtre finale Bingo existante de 8 secondes reste prioritaire sur le délai commun des autres jeux; une démo Dashboard sans exécution Hub conserve la fin historique. Marker: `restart 01-09-2026/01`.
- Le navigateur fournit des `event_id` stables à `player_register`, `grid_assign` et `grid_cells_sync`; un retry réseau réutilise l'ID et le bridge restitue le résultat métier idempotent.
- Les gagnants de phases restent la source persistée du podium. Hors Hub ou sur erreur Canvas, la fin historique est conservée.
- `quitGame` et grâce expirée restent séparés. Marker: `restart 13-07-2026/02`.

## Update 2026-07-12 — Expiration de grâce organisateur
- Le callback du timer mémoire 1 h revalide référence du timer et token de session.
- Expiration: clear Hub, `SESSION_ENDED`, déconnexion Players, marquage de fin mémoire.
- Callback Hub non bloquant; grilles, sortie volontaire et fin naturelle inchangées. Marker `restart 13-07-2026/02`.

## Doc discipline
- `canon/repos/bingo.game/TASKS.md` à mettre à jour à chaque action significative (update-not-append si une tâche existe déjà).
- `canon/repos/bingo.game/README.md` à mettre à jour dès qu’un changement impacte le fonctionnel (flux/actions inter-repos, endpoints, env vars, idempotence/event_id, jalons logs, writes DB, etc.).
- En cas de divergence, le code fait foi ; corriger la doc immédiatement.

## Update 2026-06-26 — Format court Bingo 3x3
- Le format Bingo `5` est traite comme une grille 3x3 dans `getLineToBoxNumbersMapping(format)`.
- Les formats historiques restent inchanges: `2` = 5 lignes x 4 colonnes, `3/4` = 3x3.
- Le nombre de cases joueur reste compatible avec la logique existante: tout format different de `2` utilise 9 cases dans `db_player_repository.js`.
- Le marker `version.txt` est passe a `restart 26-06-2026/01`.

## Update 2026-06-12 — Remote papier phase winner HTTP-first
- Pour les attributions gagnantes Bingo papier avec joueur, la remote `games` appelle `bingo:phase_winner` via HTTP Canvas avant `admin_phase_winner`.
- Le WS `admin_phase_winner` avec `persisted=true` ne repersiste pas; il applique le refresh sur organizer/remote/players presents et logge `WS_REMOTE_PAPER_WRITE_RX`, `WS_REMOTE_PAPER_WRITE_ACK`, `WS_REMOTE_PAPER_RESYNC_APPLIED`.
- Si aucun organizer/master n'est ouvert au moment du broadcast, le gagnant reste conserve dans la source persistante et rehydratable depuis l'etat Canvas.
- Les sessions numeriques et les actions de notification `admin_phase_fail` ne sont pas modifiees.

## Update 2026-03-24 — Observability prod reprise joueur Bingo
- `bingo_server.js` publie maintenant `PLAYER_WS_BOUND` en `info` a chaque rattachement player WS, avec `player_id`, `player_db_id`, `player_name`, `game_id` et `is_reconnect`.
- cette preuve serveur complete les logs de coupure (`WS_CLIENT_DISCONNECTED`, `WS_HEARTBEAT_TERMINATE`) pour verifier demain si les sessions Bingo se recollent correctement apres suspension mobile.

## Scope & entrypoints (confirmés)
- WS + HTTP unique : `ws/server.js` démarre un serveur HTTP (port `WS_PORT`, défaut 3030) avec endpoints:
  - `GET /logs`
  - `GET|POST /force_flush`
  puis attache `WebSocketServer` via `BingoServer` (`ws/bingo_server.js`).
- Logs HTTP : `GET /logs?sid=<sid>[&limit=&page=]` lit `ws/server-logs.log` + backups (`server-logs.N.log`), limite max 5000, 404 si aucun fichier, 405 hors GET/OPTIONS.
- Force flush HTTP : `GET|POST /force_flush?sid=<sid>` broadcast une frame WS `{ type:"force_flush", sid, reason:"viewer" }` aux sockets organizer/remote/player de la session et répond `{ ok, sid, targets_count }`.
- PM2 (DEV confirmé) : `ws/pm2-ws.ecosystem.config.cjs` déclare l’app `bingo-ws` (cwd=`ws`), commande `node server.js` via `bash -lc` en important `/var/www/bingo.game.dev.cotton-quiz.com/ws/.env`, `WS_PORT=3030`, `NODE_ENV` {development|production}. Config PROD non trouvée (voir UNVERIFIED).
- DB : `ws/knexfile.js` configure MySQL (client `mysql`, connexion hardcodée en dev). `bingo_server.js` instancie `knex(knexConfig.development)`.
- Tests/scripts : `ws/package.json` → `npm test` (jest), `npm run test:coverage`; pas de script start, l’exécution runtime passe par PM2/`node ws/server.js`.
- Loadtest bots : `ws/bingo_loadtest.js` génère un `player_id` canon déterministe par bot/session (`p:uuidv5-ish("cotton-bot-player-id-v1|bingo|<sid>|<botId>")`), l’envoie dès `player_register` + `auth_player`, et propage `player_id` sur writes gameplay (`grid_cells_sync`, `deactivate_player`); `playerId` numérique reste optionnel et uniquement s’il est connu.
- Docker/compose : non présent dans le repo (voir UNVERIFIED si infra externe).

## Runtime surfaces
- WebSocket : `ws/websocket_server.js` gère connexions/heartbeat; instancié avec `heartbeatInterval: 15000` ms depuis `server.js`. Métadonnées connexions (origin, role, sid) exposées via `getMetadata`. Les logs WS passent par `logV1` (wrapper `ws/logger.js`) qui enrichit systématiquement `role` (fallback `server`) + `sid/game/src/v/ts`. Depuis 2026-06-12, les sockets auth (`auth_client`, `auth_remote`, `auth_player`, `auth_player_paper`) portent aussi `ws.wsRole` / `ws.role` pour faciliter la correlation directe.
- Auth player bingo: `player_id` canon (`p:<uuid>`) est obligatoire sur `auth_player` et `auth_player_paper`; si absent/invalide, rejet `PLAYER_ID_MISSING_OR_INVALID`. Politique `last connection wins` basée sur `(sid, player_id)`; l’ancienne socket reçoit `SESSION_REPLACED` puis fermeture `4005` (`player replaced`), avec cleanup dédié `player-replaced`.
- Demo desktop Bingo (2026-05-04): l'iframe player `embed=gm&demo_player=1` envoyee par `games` s'authentifie en `auth_player` avec `demoParticipant:true`; `PlayerConnectionsTracker` compte ce socket dans `playlistCounts`, donc `Joueur démo` consomme 1 place de la limite demo comme un joueur mobile. Le joueur demo reste dans les connexions et snapshots (`num_connected_players.players[]`) pour l'affichage organizer/remote, les phases et classements.
- Identité joueur Bingo (canon): `player_id` string (`p:<uuid>`) est la clé primaire WS; `playerId` numérique devient secondaire `player_db_id` (compat/auth DB, logs séparés).
- Canvas bridge : `ws/envUtils.js` choisit l’endpoint (override `CANVAS_API_URL` sinon fallback `https://games.{dev|prod}.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas` selon `WS_SERVER_URL`/origin). Écritures autorisées pour `bingo:reset|session_update|bingo:end_game|phase_winner|deactivate_player`; ajoute `event_id` UUID; header `X-Service-Token` pris de `CANVAS_SERVICE_TOKEN` ou alias `CANVAS_API_SERVICE_TOKEN`. Les writes player-scoped (`phase_winner`, `deactivate_player`) valident désormais côté WS un scope canon key-first (`player_id` obligatoire, `playerId` numeric-only) avec log `WS_API_PAYLOAD_VALIDATED`.
  **TODO migration** : si la cible produit est `global_ajax.php`, planifier un switch + tests CORS/auth (doc transverse en décalage).
- Hydratation players WS bingo : à la connexion organizer (boot/reprise), le serveur appelle `bingo:players_get` puis reconstruit `paperPlayersByGame` avec dédup déterministe (`updated_at DESC`, `id DESC`) et logs `PLAYERS_HYDRATE_START/ROW_SKIPPED/DEDUPED/DONE`.
- Bridge Bingo (`games`): `player_register` en UPSERT sur `(session_id, player_id)`; `grid_assign/grid_hydrate/grid_cells_sync` résolvent d’abord `player_id` canonique, puis fallback legacy via `playerId` numérique avec log `LEGACY_API_NOTE`.
- Remote admin register (`admin_player_register`) : le WS accepte désormais soit `player_id` canonique soit `playerId` numérique (compat), puis rediffuse `num_connected_players.players[]` avec `player_id` (si présent en DB) + `playerId` (legacy). Compat pré-migration conservée si colonne DB `player_id` absente.
- `update_session_infos` durci (2026-02-12): si aucune info lots n’est fournie, le WS n’émet plus de `prizes` vides implicites (`first/second/third`), ce qui évite l’effacement accidentel des lots côté UI player/remote.
- Admin phase winner (papier manuel, sans joueur) : `advancePhaseWithoutWinner` calcule `next_phase` depuis la phase explicitement demandée (`requestedPhase`) quand elle existe dans `phases_liste`; fallback conservé sur la phase DB courante sinon.
- Notifs victoire admin manuel : retour au format historique `PlayerWin` (`log_type=3`, message `"<PHASE> gagnée : Bravo ..."`), pour conserver l’affichage `bingo-notif-list` et la logique médailles/podium.
- End-game payload Bingo WS : `endGame` transporte désormais `players[]` + `totalPlayers` (snapshot final), afin de stabiliser l’hydratation UI de fin côté organizer/remote.
- Snapshot players Bingo : `getPlayersSnapshot` accepte un fallback de clé (canon `player_id` -> `player_db_id` -> `playerName`) pour conserver les joueurs papier même si l’identité canonique est absente/incomplète sur des données legacy.
- Résultats archivés côté `global`: dès que des lignes `bingo_players` existent pour le `session_id` exact, elles définissent seules l'appartenance affichée. Les anciennes grilles de playlist ne servent plus à ajouter des joueurs modernes; elles restent un fallback borné pour archives sans runtime.
- Logging : `ws/logger.js` écrit des JSON lignes (`v=1`, `ts`, `lvl`, `src=BINGO_WS`, `evt`, `sid/eid/meta…`) vers `ws/server-logs.log`, rotation 10 Mo / 5 backups, purge >15j. `LOG_DEBUG` explicite est prioritaire (`1`=on, `0`=off), sinon fallback sur `NODE_ENV/APP_ENV`.

## Variables d’environnement lues (via code)
- `WS_PORT` (défaut 3030) — `ws/server.js`.
- `CANVAS_SERVICE_TOKEN` (service token) / `CANVAS_API_SERVICE_TOKEN` (alias accepté).
- `CANVAS_API_URL` (override endpoint), `WS_SERVER_URL` | `CANVAS_ORIGIN` | `ORIGIN` (hint dev/prod), `APP_ENV`, `NODE_ENV` — `ws/bingo_server.js`, `ws/envUtils.js`.
- `LOG_DEBUG` pris en compte par `logger.js` (`1` force debug, `0` force no-debug).
- `.env` loader : `ws/localEnvLoader.js` charge une seule fois les clés whitelisted avec `preferLocal: true` (source de vérité locale). Si une clé whitelistée est présente dans `ws/.env` (ou `cwd/.env`), elle écrase `process.env` ; si absente, fallback process (ex: PM2).
- Correctif ordre d’initialisation (2026-02-10) : `ws/bingo_server.js` charge `.env` avant l’initialisation effective du logger, pour fiabiliser la lecture de `LOG_DEBUG`.

## Interactions (résumé)
- Clients WebSocket se connectent à `ws/server.js` ; messages routés par `BingoServer` → `websocket_server.js` → handlers métier.
- Bridge HTTP `/logs` sert uniquement à la lecture des logs JSONL générés par `logger.js`.
- Écritures Canvas déclenchées depuis le WS via `envUtils.canvasWrite` (actions limitées) vers `games_ajax.php`.
- `phase_winner` envoie `player_id` canon en priorité; `playerId` numérique reste secondaire (lookup local compat si payload organizer legacy).
- Audit writes WS Bingo: toutes les écritures Canvas WS passent par `canvasWrite` (avec `event_id` injecté + token service), et loggent `CANVAS_WRITE_OK` / `CANVAS_WRITE_ERR`.
- Quit volontaire joueur bingo : `player_quit` -> `handleDisconnection` -> `canvasWrite('deactivate_player', { sessionId, player_id, playerId?, event_id })`.
- Observabilité du quit bingo : `PLAYER_DEACTIVATED` (info), `PLAYER_DEACTIVATE_FAILED` (warn), `PLAYER_DEACTIVATE_SKIP` (warn).
- Replacement observability : `PLAYER_REPLACEMENT` (info), `PLAYER_SOCKET_REPLACED_CLEANUP` (info), close `4005` mappé en intent `player-replaced`.
- Disconnect observability (2026-02-13, completee 2026-06-12) : `WS_CLIENT_DISCONNECTED` est loggé avec `sid/role` + `meta.ws_client_id`, `meta.ws_role`, `meta.ws_type="close"`, `closeCode`, `closeReason`, `intent`, `involuntary`; les coupures organizer avec signal background recent sont classees `organizer_background`. Les envois organizer sans socket ouverte sont traces par `WS_SEND_NO_PRIMARY_ORGANIZER`; les remotes referencees mais non ouvertes par `WS_SEND_NO_REMOTE`, avec `message_type`, `organizer_open_count`, `remote_present` et `remote_ready_state` (throttle 5s par jeu/type).

## Actions clés (runbook court)
- Lancer WS (dev/pm2) : `pm2 startOrReload ws/pm2-ws.ecosystem.config.cjs --update-env` (cwd `ws/`).
- Tests unitaires : `cd ws && npm test`.
- Vérifier logs pour une session : `curl "http://<host>:WS_PORT/logs?sid=<sid>&limit=200"`.
- Forcer bump déploiement (si watcher) : éditer `../bingo.game/version.txt` (pattern `restart DD-MM-YYYY/NN`).

## Variables d’environnement (synthèse)
| Key | Required | Used in | Note |
| --- | --- | --- | --- |
| `WS_PORT` | Optionnel (def 3030) | `ws/server.js` | Port HTTP/WS |
| `CANVAS_SERVICE_TOKEN` | Recommandé (writes) | `ws/envUtils.js` | Header `X-Service-Token` |
| `CANVAS_API_SERVICE_TOKEN` | Optionnel (alias) | `ws/envUtils.js` | Compat, même usage |
| `CANVAS_API_URL` | Optionnel | `ws/envUtils.js` | Override endpoint |
| `WS_SERVER_URL` / `CANVAS_ORIGIN` / `ORIGIN` | Optionnel | `ws/bingo_server.js`, `ws/envUtils.js` | Hint dev/prod pour fallback URL |
| `APP_ENV` / `NODE_ENV` | Optionnel | `ws/envUtils.js` | Hint dev/prod si aucun host |
| `LOG_DEBUG` | Optionnel | `ws/logger.js` | Override explicite debug (`1`=on, `0`=off) |

### Priorité de configuration (`.env` vs PM2)
- Mode en place : `.env` local prioritaire pour les clés whitelistées.
- Clés whitelistées côté bootstrap WS (`ws/bingo_server.js`) : `CANVAS_SERVICE_TOKEN`, `CANVAS_API_SERVICE_TOKEN`, `CANVAS_API_URL`, `CANVAS_ORIGIN`, `ORIGIN`, `WS_SERVER_URL`, `WS_PORT`, `ROLE_AUDIT_TICK_MS`, `LOG_ROLE_AUDIT`, `LOG_DEBUG`, `APP_ENV`, `NODE_ENV`.
- Conséquence: tu peux omettre des clés dans `.env` pour conserver les defaults PM2/process ; seules les clés présentes dans `.env` sont forcées.

## Happy path (diag rapide)
1) Installer deps WS si besoin : `cd ws && npm install` (si node_modules manquant).
2) Copier variables locales : `cp ws/.env.template ws/.env` puis renseigner token si usage Canvas write.
3) Démarrer via PM2 dev : `pm2 startOrReload ws/pm2-ws.ecosystem.config.cjs --update-env`.
4) Vérifier log de démarrage dans `ws/server-logs.log` (evt `CONFIG` affiche endpoint/tokenPresent).
5) Ouvrir un client (organizer/player) et établir la connexion WS.
6) Observer traffic : messages `state` / `remote_action` transitent ; aucun 4xx sur Canvas writes.
7) Consulter `/logs?sid=<sid>` pour confirmer traces par session.
8) Arrêt : `pm2 stop bingo-ws` ou `pm2 delete bingo-ws`.

## Scénarios d’échec fréquents
- Symptôme : `/logs` retourne 404 — Cause probable : aucun fichier `server-logs*.log` encore créé — Fix : générer trafic WS pour créer le log puis relire.
- Symptôme : Writes Canvas échouent 403 — Cause : token manquant (log `CONFIG_MISSING_TOKEN`) — Fix : définir `CANVAS_SERVICE_TOKEN` (ou alias) et relancer PM2 avec `--update-env`.
- Symptôme : Trop de debug en prod — Cause : `LOG_DEBUG` ou env de démarrage incohérents — Fix : définir `LOG_DEBUG=0` + redémarrer PM2 avec `--update-env`.

## Observability (viewer-first)
- Source unique : fichiers `ws/server-logs.log` (+ rotations) produits par `ws/logger.js` (`logV1` injecte `role` pour tous les niveaux info|warn|error).
- Accès HTTP : `GET /logs?sid=<sid>[&limit=&page=]` depuis `ws/server.js` (CORS `*`, GET/OPTIONS).
- Entrées JSONL `v=1` avec `ts,lvl,src=BINGO_WS,evt,role,sid,eid,meta…` ; debug piloté par `LOG_DEBUG` ; compteur DEBUG `ROLE_AUDIT` (env `ROLE_AUDIT_TICK_MS` optionnel) surveille les entrées reçues sans role avant enrichissement (fallback `server`).
- Pour config runtime, chercher `evt:"CONFIG"` au démarrage (endpoint Canvas, tokenPresent, envPathUsed).

## Forcer flush (Bingo)
- Trigger viewer :
  - local : `games/web/logs_session.html` garde `localStorage.setItem('LOG_FLUSH_REQUEST', Date.now())`;
  - distant : le même bouton appelle aussi `games/web/includes/canvas/php/logs_proxy.php?action=force_flush`, relayé vers `GET /force_flush?sid=<sid>`.
- Réaction front (player/remote) : `games/web/includes/canvas/core/logger.global.js` exécute `flushBufferToWS()` à réception d’une frame WS `force_flush`, ou sur `window.storage` pour le cas local.
- Flush automatique fin de session : `logger.global.js` appelle aussi `flushBufferToWS()` quand le statut devient exactement `Partie terminée` (`maybeFlushFromStatus`).
- Transport WS front -> Bingo WS : message `{ type: "log_batch", payload: { entries: [...] } }` (ou `log_event` unitaire) sur la socket de session déjà ouverte.
- Ingestion WS Bingo : `ws/bingo_server.js` traite `log_batch|log_event`, valide chaque entrée, enrichit `meta.ingested_by = "BINGO_WS"` (+ `ws_role`, `ws_client_id` si dispo), puis réécrit en JSONL via `logV1`.
- Observability force flush :
  - côté serveur : `FORCE_FLUSH_RX`, `FORCE_FLUSH_BROADCAST`;
  - côté front distant patché `games` : `PLAYER_FRONT_LOG_FLUSH_TRY|OK|FAIL` avec `role:"player"` ou `role:"remote"`.
- Critère de validation : `GET /logs?sid=<sid>` renvoie des entrées `src:"GAMES"` (avec `meta.ingested_by:"BINGO_WS"` attendu sur les logs ingérés front).

## UNVERIFIED (à vérifier avant usage)
- Déploiement Docker/compose : absent du repo ; vérifier s’il existe dans une infra externe (`ls ../bingo.game/docker*` ou repo d’infra).
- Prod ecosystem PM2 : seul fichier `ws/pm2-ws.ecosystem.config.cjs` pointe vers `/var/www/bingo.game.dev.cotton-quiz.com`; vérifier s’il existe un config prod distinct ou un path prod (`find /var/www/bingo.game* -name "pm2-*.config*"`).
- Endpoint Canvas : code fallback `games_ajax.php`, doc transverse mentionne `global_ajax.php` → confirmer la cible côté PHP/routeur et planifier migration si besoin.
