<!-- AUTO-UPDATE:BEGIN id="hub-suspend-20260910-bingo.game-tasks" owner="codex" -->

## 23/09/2026 — Hotfix minimal hub_soiree

- [x] Base propre `hub_soiree` vérifiée ; extraction minimale, sans merge/cherry-pick. `auth_player` utilise le contrôle ciblé lorsque le lifecycle fournit une exécution officielle. Mapping/participation sont relus ; ID participation comparé au Player authentifié par grille/secret. Auth, grille individuelle, queue reset/versionnement et payload state historiques conservés.
- [x] Tests ciblés et comparaison des échecs historiques à la base ; [commandes/résultats](../../../notes/hub-soiree-hotfix-2026-09-23.md).
- [x] Audit recette DEV compte442/Hub349 : gameplay observé sur les trois jeux ; lenteur Bingo quantifiée,59 refus de grilles du harnais préexistant et29 binds uniques BT. [Preuves et limites](../../../notes/hub-soiree-hotfix-2026-09-23.md#i-recette-dev-compte-442--hub-349--audit-des-logs-du-2309). Audit/doc uniquement. Complément affichage Master : masque CSS lié au lancement et attente du reset Bingo avant intro, préexistants ; environ18,5 s entre HTML servi et reset accepté, paint non horodaté.
- [x] Procédure opérateur de qualification prête dans la section J du rapport : retard ready15 s via overrides locaux, critères de continuation unique/annulation et trace DEV ciblée proposée ; non exécutée.
- [x] Audit PROD client10 : cloclo sans bind initial sur Bingo18008/18009, connecté à la reprise ; défaut d’erreur masquée dans le front Hub repéré. [Rapport K](../../../notes/hub-soiree-hotfix-2026-09-23.md#k-prod-client10--player-cloclo-bloqué-le-2309-vers1800).
- [x] Exploration des courses : deux défauts préexistants reproduits (reprise perdue après échec tardif à gate stable ; sonde concurrente sur promesse jamais résolue), six cas isolés avec témoins. [Diagnostic L](../../../notes/hub-soiree-hotfix-2026-09-23.md#l-exploration-des-courses-du-bootstrap-player-bingo). Aucun correctif applicatif appliqué.
- [ ] Identifier l’échec initial cloclo : copies Games actives vides et archives arrêtées vers03:12, réponses inscription/assignation/hydratation manquantes ; capture front nécessaire à la prochaine reproduction. Aucun correctif applicatif appliqué par cet audit.
- [ ] Compléter la recette : ready volontairement >10 s, preuve du chemin ciblé, timings Master/WS Bingo avec/sans bots et génération des grilles du harnais ; branche/commit par opérateur lorsque Git est inscriptible. **Aucun déploiement ni restart exécuté par Codex.**


## 23/09/2026 — Hub session readiness

- [x] Préflight propre, branche opérateur `hub_session_readiness` depuis `hub_soiree`, reprise sélective sans merge. Préparation reset durable avant preuve finale, contrôle génération/post-reset, admission ciblée et pipeline optimisé ; aucun reset implicite de partie démarrée.
- [x] Tests isolés du nouveau protocole et comparaison des échecs à la base ; détail actualisé dans le [rapport](../../../notes/hub-session-readiness-2026-09-23.md).
- [ ] Commits cohérents dès Git inscriptible ; revue/recette distribuée 10/30/50/100, qualification de la fenêtre et charge réelle. Aucun déploiement autorisé par ce lot.


### Statut de livraison — 23/09/2026

`hub_soiree` : **déployé en PROD selon confirmation opérateur**. `sas_players`, `hub_session_readiness` et `cast` : **évolutions propres NON DÉPLOYÉES EN PROD**, même si leurs descriptions sont reprises dans la documentation `main`. Les anciens statuts datés restent l’historique des interventions, pas l’état courant. [Périmètres, références et limites](../../deployment-status.md).

- [x] Cohérence documentaire avant promotion : livraison `hub_soiree` consignée, exclusions `sas_players`/`hub_session_readiness`/`cast` explicites (vérifiées le 23/09) ; recettes restantes conservées.


## 22/09/2026 — Audit pipeline numérique Hub et convergence

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](../../deployment-status.md).

- [x] [Audit des outils natifs WS](../../../notes/ws-native-loadtools-audit-2026-09-22.md) : vraies admissions/sockets ; Quiz/BT limité à 5 000 tentatives, branche profils bloquée et arrêt de rampe incomplet ; Bingo profils prêts distinct du générateur froid Canvas (concurrence 8). Baseline DEV avant patch partielle, harnais à compléter ; commandes futures, métriques manquantes et matrice A/B consignées. Aucun outil/test exécuté ni patch/marker/restart/déploiement dans cette passe.
- [x] Harnais et instrumentation A/B préparés : [contrat, bundles séparés, commandes et tests](../../../notes/ws-loadtest-ab-instrumentation-2026-09-22.md). ACK/state, stop/drain borné, résumés, capacité B/N, publication BT, queue/I/O Bingo et process ; algorithmes métier conservés. Aucun déploiement/restart/charge réelle.
- [x] Conception du [Hub Load Test unique](../../../notes/hub-loadtest-unified-design-2026-09-22.md) : Browser/Server comme générateurs du même parcours, définition ready, retries runtime, convergence/gameplay, horloges et replay sas offline borné. Audit/documentation seuls ; aucun patch, marker, restart ou charge.
- [ ] Migration unifiée : [adaptateur Browser Bingo et AVANT/APRÈS prêts localement](../../../notes/hub-bingo-browser-baseline-2026-09-22.md), grilles prepared, ready après post-reset, off et cleanup commun ; 66 Games/27 Bingo/4 AVANT passent, SHA A/B et rollback vérifiés. DEV `hub_soiree` attesté, aucun snapshot requis. Restent livraison AVANT et recettes50 puis200 sur sessions fraîches ; Server5000, performance puis sas ultérieurs. Moteur direct réservé au diagnostic.

- [x] [Patch capacité](../../../notes/hub-capacity-publication-patch-2026-09-22.md) : transport par cohortes fermées et Set partagé, tests locaux verts ; stock/locks/auth inchangés, marker22/09 /01.
- [x] Auth numérique : routage DB allégé + suppression reset_state de routage ;5→4 HTTP,6→5 SELECT directs nominaux ; premier state Hub sans roster trié, compteur identique. [Rapport](../../../notes/bingo-digital-auth-performance-2026-09-22.md).14 scénarios locaux dont5 000 tentatives simulées,41 régressions WS et suites PHP/capacité/papier vertes ; marker Bingo22/09 /02, aucun restart/déploiement.
- [ ] Goulet restant : queue complète, lifecycle et capacité par joueur. Concevoir le protocole de validation reset/lifecycle avant parallélisation, puis qualifier réellement5 000 avant sas.

- [x] [Audit commun charge/convergence](../../../notes/hub-player-registration-pipeline-audit-2026-09-22.md) : coûts capacité/roster, scans et files, frontière in-flight, watcher et plan 50/500/5 000. Aucun patch applicatif/marker ; tests/probe I/O simulées seulement.
- [x] Ecommerce rechargé par l’utilisateur, non modifié ; qualification réelle toujours ouverte.


## 21/09/2026 — Conception future du mode équipe transverse

- [x] Principes produit/architecture consignés dans la [note unique de conception](../../../notes/hub-team-model-future.md) : identité Hub individuelle, équipes EP réutilisées, choix solo/équipe verrouillé par session, meilleur résultat par item. Modèle envisagé, non implémenté ; migration QR papier et questions de scope/persistance/classements encore ouvertes.
- [ ] Arbitrages produit et conception détaillée avant tout patch. Aucun changement applicatif dans cette passe ; équipes Blind Test toujours désactivées, contrats et PATCH1/1B/2/3 distincts.


## PATCH1B — validation de convergence (21/09/2026)

- [x] Maintenance PATCH1 réelle sous VM alimentée par les participations produites par le vrai flux Global avec I/O simulées :18→20 sans socket joueur, retry sans doublon ; scores Quiz/BT et association Bingo conservés. Aucun changement moteur/marker dans ce lot. [Rapport](../../../notes/paper-resume-patch1b-2026-09-21.md).


## 21/09/2026 — PATCH 3 association papier facultative (local)

- [x] Prouver le lookup D-only limité aux sockets ; résoudre dans le roster PATCH1 actif scoped session/exécution ; projeter le nom canonique et conserver le chemin sans joueur.
- [x] Respecter l’ACK HTTP sans seconde avance même si l’association échoue ; garder les règles Bingo et usages numériques.
- [x] 24 scénarios serveur, corrections UI sans joueur et rendu Master/Remote, 10 résultats TAP Bingo ; suites PATCH2/PATCH1 vertes. Documentation et marker `restart 21-09-2026/03` préparés.
- [ ] Recette réseau/navigateur après éventuelle livraison autorisée séparément. Aucun accès service/DB, déploiement ou restart.

[Rapport PATCH3](../../../notes/bingo-paper-association-patch3-2026-09-21.md).


## 21/09/2026 — PATCH 1 inscription et roster papier (local)

- [x] Bind utilise le même lecteur actif que l’hydratation ; K prioritaire, D secondaire, grilles mémorisées conservées. Réconciliation papier5s, publication num_connected_players réconciliée explicite, state partiel, conservation du terminal vide. Marker21/09 /02 ; aucun restart exécuté.

[Contrat canonique](../../interfaces/paper-roster.md) · [Rapport et validation](../../../notes/paper-roster-patch1-2026-09-21.md). Tests isolés, sans DB réelle ; aucun déploiement.


## Update 2026-09-21 — Jauge Hub et upsell (local, non déployé)

Probe/auth numérique et papier relisent la capacité serveur ; hydratation live filtrée sur le roster Hub actif. Stock de grilles complété par le générateur Global, avec offset de numérotation et sans supprimer les affectations. Démo à 2 et garde WS maintenues.

Offre effective = autorité commerciale. Maximum N Hub actifs ; probable sans place ; left libère une place et sa réactivation en nécessite une. Snapshots techniques synchronisés uniquement vers le haut ; downsell hors périmètre. [Contrat, tests et limites](../../../notes/hub-capacity-upsell-2026-09-21.md).


- [x] 19/09 — Diagnostic test Hub329/source27887 : console WSS en échec, logs Nginx Bingo DEV confirment HTTP502 et connexion refusée aux listeners IPv4/IPv6 port3030. Création de démo et GET Master réussis ; aucune preuve d’arrivée au moteur. Aucun patch/restart.
- [x] Cause confirmée par l’utilisateur : `ws/runtime_expiry.js` manquant sur le serveur. Aucun patch ni redémarrage exécuté par Codex.


- [x] 17/09 — Auditer copie initiale vs reset : suppression du reset redondant dans le producteur Global uniquement ; préparation Master/Remote testée, reset historique et génération Bingo conservés. [Rapport](../../../notes/hub-demo-lifecycle-patch-2026-09-17.md).
- [ ] Recette DEV de la copie Bingo, retry et sortie démo ; aucun patch WS, restart ni DB réelle.


## Suspension officielle Hub — 10/09/2026

- [x] Patch local : `ws/hub_lifecycle.js` et les handlers Bingo gèlent les commandes/vérifications/winners. Les Maps restent en mémoire ; collision `idPlaylistClient` refusée pour un runtime conservé. Le registre existant accepte une Remote courante par jeu ; toutes les surfaces encore attachées reçoivent le signal. Complément18/09 : génération publiée exacte, continuité Remote distincte du takeover et diagnostic corrélé selon le périmètre du repo ; [rapport et tests](../../../notes/bingo-hub-resume-robustness-2026-09-18.md). Complément18/09, expiration involontaire confirmée : identité moteur figée, événement `hub_runtime_expired` idempotent, focus CAS, refus `HUB_RUNTIME_EXPIRED`, aucun CTA/recréation officielle ; tests grâce valide, suspension >1 h et papier/numérique. [Rapport](../../../notes/hub-runtime-expired-2026-09-18.md).
- [x] Contrat et tests hors connexion consignés dans le [rapport de validation](../../../notes/hub-suspend-patch-2026-09-10.md).
- [ ] Recette sur services réels après livraison autorisée : matrice papier/numérique, perte involontaire puis reprise active2→3, double suspension/reprise, socket zombie, deux onglets/appareils, diagnostics, cutoff. Validation locale18/09 verte ; aucun déploiement ni redémarrage exécuté. Audit logs client10 du18/09 : session27867/runtime17080 ouverte historiquement, expirée à15:11, puis contexte officiel créé à15:45 ; refus4001 répétés. Cette séquence ne valide pas la recette officielle neuve ; voir HANDOFF (audit session27867).

Les tâches anciennes de quit Hub terminal restent historiques ; leur recette terminale ne s’applique plus à une exécution officielle orchestrée suspendable.

- [x] 11/09/2026 — Correction du timeout observé en DEV Blind Test : Les refus WS `HUB_SOCKET_UNAUTHORIZED` incluent `execution_id` et `runtime_session_id` avec `request_id`, pour que le Master traite le refus immédiatement au lieu d’attendre le timeout. Marker préparé : `restart 11-09-2026/01`, aucun restart exécuté. Tests et preuves dans le rapport lié ci-dessus. Recette DEV après diffusion du correctif restante.

- [x] 11/09/2026 — Retour Play immédiat autorisé : Quiz/Blind Test/Bingo incluent désormais les sockets Players de la session dans les destinataires de `HUB_SESSION_SUSPENDED`, émis uniquement après succès de release/clear focus. Le handler Play valide contexte officiel, execution_id, runtime_session_id, token sessionId et request_id non vide ; il bloque les reconnects et revient directement au Hub Play, une seule fois, sans flux terminal. Les démos et signaux obsolètes sont ignorés. Le polling15s corrigé reste en secours ; une réponse HTTP déjà en vol ne provoque pas de seconde navigation.
- [x] Tests locaux verts : suites suspension Games/Bingo, grâce Quiz/Blind Test, isolation Player démo (133 résultats TAP).
- [ ] Recette DEV après diffusion Games et activation du code WS : retour des Players à réception du signal, roster conservé à la reprise. Markers WS Quiz/Blind Test/Bingo préparés `restart 11-09-2026/02` ; aucun restart exécuté.

- [x] 11/09/2026 — Audit Continuer/Recommencer : arrêt avant patch, car mappings et résultats ne distinguent pas les tentatives officielles. Reset Bingo complet conservant les grilles identifié ; reset ordinaire insuffisant pour winners/Maps. [Diagnostic et recette obligatoire](../../../notes/hub-restart-from-zero-audit-2026-09-11.md).
- [ ] Définir l’autorité des tentatives et son application aux résultats/fallbacks avant le futur patch de restart Hub.

- [x] 11/09/2026 — Patch préparatoire strictement Bingo : primitive historique réutilisée, génération persistée dans `game_events`, reset des gains dérivés, garde des anciens writes et mémoire WS/Player réinitialisée avec les mêmes grilles. Tests isolés et contrats mis à jour : [livrable/recette](../../../notes/bingo-reset-generation-patch-2026-09-11.md).
- [ ] Recette DEV du reset historique avec Player absent, concurrents et nouveaux joueurs ; mesurer les lectures WS et verrous MySQL. Aucun déploiement, restart ou accès DB réel. La conception du futur `Recommencer` Hub reste distincte.


- [x] 16/09/2026 — Wording winner Bingo unifié live/reprise par formatter WS commun, lecture structurée scoppée session, déduplication et fallback historique. Tests phases 1/2/3/5, Remote, overlay, reset/génération et suspension verts. Aucun runtime Games modifié pour cette passe.
- [ ] Recette DEV du wording après diffusion : même phrase et grille avant/après reload, une notification par victoire, anciens historiques et Remote. Aucun déploiement/restart exécuté.

<!-- AUTO-UPDATE:END id="hub-suspend-20260910-bingo.game-tasks" -->

## Migration du code Hub vers main — 2026-09-09

- [x] [Audit branches/code et manifeste candidat](../../../notes/hub-prod-code-migration-2026-09-09.md) : Fast-forward simulé, 3 suites vertes ; sequencer cherry-pick préexistant bloque le switch. Ne pas quitter/annuler arbitrairement. 6 fichiers applicatifs candidats.
- [x] Vérification distante read-only des SHA, syntaxe/contrats ciblés, inventaire des dépendances et fichiers main-only ; aucun fichier applicatif ni SQL modifié.
- [ ] Lever les blocages Git (profil .git lecture seule ; Bingo cherry-pick ; Pro conflit), terminer les merges autorisés puis refaire validation sur main et figer les sources finales. Aucun merge, push, déploiement ou restart effectué.

# Repo `bingo.game` — Tasks
- Reprise09/09 : [vérification AI Studio fraîche](../../../tmp/hub-prod-code-2026-09-09/REPRISE-AI-STUDIO.md) et refs contrôlées. main propre, ancien sequencer Bingo clos ; merge Bingo refusé ORIG_HEAD.lock en lecture seule. Global/WWW demandent des copies serveur avant merge. Aucun nouveau merge ; validation finale et manifeste FINAL en attente. Les contrôles précédents restent historiques.

## PATCH 2026-08-27 — Index de phase papier sans joueur
- [x] Prouver que `phases_liste` inclut le sentinelle `0` et que `phase_courante` indexe la liste complète.
- [x] Remplacer le filtrage `> 0` de `advancePhaseWithoutWinner` par le helper pur `bingo_phase_progress.js`, sans modifier les utilitaires numériques historiques.
- [x] Journaliser `BINGO_MANUAL_PHASE_ADVANCE` avec grille/lignes, liste et index avant/après.
- [x] Couvrir `0,1,2,5`, `0,1,5`, phase 1, phase intermédiaire et terminal par `ws/tests/bingo_phase_progress.test.js`.
- [x] Bump marker WS `version.txt` à `restart 27-08-2026/01`.
- [ ] Recette runtime avec DB réelle sur correction sans joueur puis gagnant identifié.

## PATCH 2026-08-25 — Réarmement du guard quit volontaire sur reprise Organizer
- [x] Confirmer la cause: `sessionEndedGames.add(gameID)` posé au premier `quitGame forced=false` n'était jamais supprimé lors d'une reprise Hub du même `game_id`/sid.
- [x] Conserver `sessionEndedGames` comme idempotence d'un cycle de quit volontaire: un double quit sans reprise reste ignoré.
- [x] Ajouter `bingo_quit_guard.js` pour réarmer le guard uniquement sur reprise Organizer prouvée, avec garde `naturalEndCompletedByGame` / `hubNaturalTransitionByGame`.
- [x] Brancher le reset seulement dans `auth_client` quand le timer `primaryReconnectTimers` est annulé (`ORGANIZER_RECONNECTED` / `GAME_RESUMED_SENT`), jamais sur `auth_remote` ni `auth_player`.
- [x] Ajouter les logs `BINGO_QUIT_GUARD_RESET` et `BINGO_QUIT_ALREADY_HANDLED`.
- [x] Couvrir par `ws/tests/bingo_quit_guard.test.js` les trois cycles, la conservation hors reprise Organizer et la non-réactivation après fin naturelle.
- [x] Bump marker WS `version.txt` a `restart 25-08-2026/01`.
- [ ] Recette navigateur dev: sur une même session Hub Bingo, exécuter `quit -> reprise -> quit -> reprise -> quit`; chaque quit doit produire `SESSION_END` et `hub_remote_bingo_terminal_delivery`, chaque reprise doit produire `BINGO_QUIT_GUARD_RESET reset=true`.
- [ ] Recette fin naturelle: après une ou plusieurs reprises, vérifier que `bingo:end_game` / `hub_session_natural_ended` / `HUB_SESSION_FINISHED` restent définitivement terminaux et ne réarment pas le guard.

## PATCH 2026-08-24 — Quit volontaire Hub Remote
- [x] Auditer le registre Remote Bingo: `remotesByGame` est clé par `gameID = idPlaylistClient`, `auth_remote` remplace l'ancienne socket pour cette clé, et le quit Organizer utilise le même `gameID`.
- [x] Relayer le `sessionId` de `remote_action=remote_quit_request` vers l'Organizer afin que `endSession()` puisse construire `quitGame` même si le store local est incomplet.
- [x] Journaliser `quitGame_received` dès l'entrée du handler serveur Bingo, avant la branche `forced`, pour prouver la rupture ou la réussite Organizer -> Bingo WS.
- [x] Instrumenter `sendMsgToRemote()` pour le terminal volontaire Hub Remote avec `hub_remote_bingo_terminal_delivery`, sans token, URL ni payload complet.
- [x] Distinguer registre absent, socket absente, socket non OPEN, tentative d'envoi, succès et exception d'envoi.
- [x] Marquer le `SESSION_ENDED` volontaire avec `reason=organizer_quit` / `terminal_reason=organizer_quit`.
- [x] Couvrir le diagnostic par `ws/tests/bingo_terminal_delivery.test.js` et les assertions de contrat Games.
- [x] Bump marker WS `version.txt` a `restart 24-08-2026/03`.
- [ ] Recette navigateur dev: Remote Bingo connectée depuis Hub Remote, clic `Quitter`, logs `quitGame_received`, `SESSION_END`, `hub_remote_bingo_terminal_delivery` avec `remote_socket_state=OPEN` et `send_success=true`, puis retour Remote vers Hub Remote.

## PATCH 2026-07-15 — Validation papier puis fin naturelle vers Hub
- [x] Déclencher `bingo:end_game` depuis le WS après la dernière phase persistée, même sans Master.
- [x] Coalescer les demandes terminales Remote/Master, conserver l'`event_id` et rejouer la transition Hub confirmée.
- [x] Ne plus engager la barrière sur `phase_over=-1`; en échec du write terminal, conserver la revue et ne diffuser aucun podium/redirect.
- [x] Attendre le succès de `bingo:end_game` avant la transition Hub.
- [x] Appeler l'action dédiée puis diffuser le retour collectif vers Master, Remote et Players uniquement pour une exécution Hub confirmée.
- [x] Transporter la provenance `runtimeMode=demo` dans `HUB_SESSION_FINISHED` sans remplacer la fenêtre finale Bingo de 8 secondes; conserver la démo Dashboard hors transition Hub.
- [x] Ajouter des `event_id` browser stables et coalescer les appels register simultanés; conserver les résultats utiles sur replay bridge.
- [x] Conserver les gagnants `bingo_phase_winners` et la fin historique hors Hub/fallback.
- [ ] Recette WS/DB/navigateur réelle: phases incomplètes, dernier gagnant avec/sans Master, double validation, reload, signal perdu, session suivante et hors Hub.

## PATCH 2026-07-12 — Expiration définitive de grâce Hub
- [x] Revalider timer et token de session au callback 1 h.
- [x] Clear Hub avant `SESSION_ENDED`, sans bloquer la fin sur erreur HTTP.
- [ ] Recette Bingo réelle avec contrôle de conservation de grille.

## PATCH 2026-06-26 — Format court Bingo 3x3

### Objectif
- faire reconnaitre `id_jeu_bingo_musical_format=5` comme grille 3x3 cote WS;
- conserver les formats 2, 3 et 4 existants.

### Modifie
- `../bingo.game/ws/repository/db/utils.js`
  - `getLineToBoxNumbersMapping(format)` applique le mapping 3x3 aux formats `3`, `4` et `5`.
- `../bingo.game/version.txt`
  - marker WS `restart 26-06-2026/01`.

### Verification
- `node --check /home/romain/Cotton/bingo.game/ws/repository/db/utils.js` OK.

## PATCH 2026-06-12 — Remote papier phase winner: persisted before WS

### Objectif
- corriger le seul pattern critique Bingo identifie: succes remote papier sur gagnant de phase avec joueur avant persistance fiable;
- conserver le WS comme refresh best-effort;
- ne pas modifier les sessions numeriques.

### Diagnostic
- `admin_phase_winner` persistait deja via Canvas avant broadcast une fois le WS recu.
- La remote papier emettait cependant `admin_phase_winner` seule et affichait le succes localement; une coupure WS avant reception serveur pouvait perdre l'action.

### Modifie
- `../bingo.game/ws/bingo_server.js`
  - accepte `admin_phase_winner` avec `persisted=true` comme write deja confirme par HTTP;
  - journalise `WS_REMOTE_PAPER_WRITE_RX`, `WS_REMOTE_PAPER_WRITE_ACK` et `WS_REMOTE_PAPER_RESYNC_APPLIED`;
  - conserve les broadcasts `phase_over` / notification comme rafraichissement des sockets connectees.
- `../bingo.game/version.txt`
  - marker WS `restart 12-06-2026/02`.

### Verification
- `node --check /home/romain/Cotton/bingo.game/ws/bingo_server.js`

## PATCH 2026-06-12 — Observability WS roles targeted sends

### Objectif
- verifier et completer l'observabilite WS Bingo pour comparer les incidents papier avec Quiz et Blind Test;
- conserver les flows metier papier inchanges.

### Diagnostic
- Bingo distinguait deja organizer / remote / player via `clients`, `remotesByGame`, `players.connections` et `attachContext`.
- Le manque principal etait l'absence de tag direct `wsRole` / `role` sur la socket et l'absence de log quand un envoi cible organizer/remote etait ignore faute de socket ouverte.

### Modifie
- `../bingo.game/ws/bingo_server.js`
  - tag explicite `ws.wsRole` / `ws.role` pour `auth_client`, `auth_remote`, `auth_player` et `auth_player_paper`;
  - contexte metadata ajoute pour `auth_player_paper`;
  - classification `organizer_background` sur fermeture involontaire apres signal background;
  - ajout `meta.ws_type="close"` sur `WS_CLIENT_DISCONNECTED`;
  - logs throttles `WS_SEND_NO_PRIMARY_ORGANIZER` lors des envois organizer sans socket ouverte et `WS_SEND_NO_REMOTE` seulement si une remote referencee n'est plus ouverte.
- `../bingo.game/version.txt`
  - bump marker WS.

### Verification
- `node --check /home/romain/Cotton/bingo.game/ws/bingo_server.js`

## PATCH 2026-05-04 — Demo participant dans quota

### Objectif
- faire compter `Joueur démo` dans `maxPlayers` sur les demos Bingo;
- conserver sa vraie grille et sa visibilite organizer/remote.

### Modifie
- `../bingo.game/ws/lib/lib.js`
  - `PlayerConnectionsTracker` incremente/decremente de nouveau `playlistCounts` pour tous les players, y compris `demoParticipant`.
- `../bingo.game/version.txt`
  - bump marker WS.

### Verification
- `node --check /home/romain/Cotton/bingo.game/ws/lib/lib.js`
- `node --check /home/romain/Cotton/bingo.game/ws/bingo_server.js`

## PATCH 2026-05-04 — Demo desktop Bingo: Joueur demo hors quota

### Objectif
- permettre au participant automatique `Joueur démo` de la preview desktop Bingo de rejoindre le WS avec une vraie grille sans consommer une place demo;
- conserver sa visibilite organizer/remote et ne pas modifier les sessions Bingo normales.

### Audit
- Le player Bingo existant s'authentifie via `auth_player` apres `player_register` + `grid_assign`.
- Le quota WS Bingo s'appuyait sur `PlayerConnectionsTracker.playlistCounts`, incremente par tous les sockets players.
- Les snapshots joueurs (`getPlayersSnapshot`) lisent les connexions, donc un participant peut rester visible meme s'il n'incremente pas le compteur de capacite.

### Modifie
- `../bingo.game/ws/bingo_server.js`
  - lit `demoParticipant:true` sur `auth_player`;
  - expose ce flag dans les logs `AUTH_OK` / `PLAYER_WS_BOUND`.
- `../bingo.game/ws/lib/lib.js`
  - n'incremente/decremente plus `playlistCounts` pour les players `demoParticipant`;
  - conserve ces players dans `connections` pour les snapshots et diffusions.
- `../bingo.game/version.txt`
  - bump marker WS.

### Verification
- `node --check /home/romain/Cotton/bingo.game/ws/lib/lib.js`
- `node --check /home/romain/Cotton/bingo.game/ws/bingo_server.js`

## PATCH 2026-03-24 — Logs prod cibles reprise joueur Bingo

### Objectif
- ajouter une preuve `info` serveur compacte quand un joueur Bingo se rattache a nouveau au WS de session, pour recouper demain les `WS_CLIENT_DISCONNECTED` / `WS_HEARTBEAT_TERMINATE` avec de vraies reprises reussies.

### Correctif livre
- `../bingo.game/ws/bingo_server.js`
  - ajout du log `PLAYER_WS_BOUND` (niveau `info`) sur `auth_player`, avec `{ player_id, player_db_id, player_name, game_id, is_reconnect }`.

### Effet attendu
- les sessions Bingo prod remontent une preuve serveur explicite de rattachement WS joueur;
- le point de demain peut distinguer plus proprement “transport coupe” et “session rejouee correctement”.

## PATCH 2026-03-20 — Force flush distant Bingo (viewer/player/remote)

### Objectif
- Aligner Bingo sur blindtest/quiz pour le flush distant de logs front, sans refonte du viewer ni du transport WS.

### Audit confirmé
- `../bingo.game/ws/server.js`
  - exposait uniquement `GET /logs`;
  - aucune route `/force_flush`.
- `../bingo.game/ws/bingo_server.js`
  - ingérait déjà `log_event` / `log_batch`;
  - ne traitait pas encore `type:"force_flush"`;
  - disposait déjà de toutes les tables mémoire nécessaires pour retrouver organizer / remote / players d’une session (`sessionIdByGame`, `clients`, `remotesByGame`, `players.connections`).

### Correctif minimal
- `../bingo.game/ws/bingo_server.js`
  - ajout de `collectForceFlushTargetsBySid(sessionId)`;
  - ajout de `forceFlushSession(...)` avec logs `FORCE_FLUSH_RX` / `FORCE_FLUSH_BROADCAST`;
  - ajout du traitement WS `type:"force_flush"`.
- `../bingo.game/ws/server.js`
  - ajout de `GET|POST /force_flush?sid=<sid>`;
  - réponse: `{ ok, sid, targets_count }`.

### Impact attendu
- Le viewer `games` peut maintenant déclencher un flush distant Bingo sur un player/remote mobile situé sur un autre device/origin.
- Aucun changement sur le contrat de flush: toujours pas d’auto-flush continu en cours de session.

## Todo
- Exécuter smoke test complet en environnement intégré: multi-onglets `SESSION_REPLACED` (close 4005), reboot WS + `PLAYERS_HYDRATE_*`, puis vérification DB anti-doublons `(session_id, player_id)`.
- Vérifier les clients legacy et le loadtest: tous les `auth_player` / `auth_player_paper` et `phase_winner` doivent envoyer/résoudre `player_id` canon (`p:<uuid>`), sinon rejet/skip instrumenté.
- Exécuter smoke test loadtest bingo (20s, 3 bots) et confirmer `PLAYER_ID_MISSING_OR_INVALID=0`.

## Quick checks (Patch 6)
- Syntaxe WS:
  - `node --check ../bingo.game/ws/bingo_loadtest.js`
  - `node --check ../bingo.game/ws/bingo_server.js`
- Smoke test bots:
  - `rg -n "BOT_IDENTITY|PLAYER_ID_MISSING_OR_INVALID|LEGACY_REGISTER_USED|auth_player envoyé" ../bingo.game/ws/server-logs.log`
  - Relance à paramètres identiques (`sid` + bot range) et vérifier `player_id` identiques dans `BOT_IDENTITY`.

## Note preload winners (games, 2026-02-11)
- Le preload Bingo exposé par `games` a été enrichi avec `phase_winners[]` lu depuis `bingo_phase_winners` (ordre par `phase`, puis `event_id`) et `players.players[]` (shape compat organizer) lu via `players_get`.
- Shape preload winners:
  - `phase` (int),
  - `player_id` (canon),
  - `player_db_id` (si résolu via `bingo_players`),
  - `player_name`,
  - `event_id`.
- Flag terminal ajouté aussi côté preload:
  - `preload.isTerminated`,
  - `preload.session.isTerminated`.
- Objectif: permettre un rendu statique de fin de session côté front `games` sans connexion WS.

## AUDIT fin de session (2026-02-11, NO PATCH)

### Fichiers inspectés
- `../bingo.game/ws/bingo_server.js`
- `../bingo.game/ws/envUtils.js`
- `../bingo.game/ws/bingo_service.js`
- `../bingo.game/ws/repository/db/db_game_repository.js`

### Constats factuels
- End detection: trois chemins runtime visibles.
- `quitGame` organizer volontaire: émission `SESSION_ENDED`, fermeture joueurs, marquage `sessionEndedGames` (`../bingo.game/ws/bingo_server.js:1460`, `../bingo.game/ws/bingo_server.js:1498`, `../bingo.game/ws/bingo_server.js:1508`).
- `end_game` explicite: write Canvas `bingo:end_game` puis WS `endGame` et fermeture joueurs (sans `SESSION_ENDED`) (`../bingo.game/ws/bingo_server.js:1515`, `../bingo.game/ws/bingo_server.js:1548`, `../bingo.game/ws/bingo_server.js:1619`, `../bingo.game/ws/bingo_server.js:1625`).
- timeout reconnexion organizer: émission `SESSION_ENDED` + fermeture joueurs + marquage `sessionEndedGames` (`../bingo.game/ws/bingo_server.js:2486`, `../bingo.game/ws/bingo_server.js:2504`, `../bingo.game/ws/bingo_server.js:2511`).
- Persistance DB à la fin: `bingo:end_game` payload `{ game:'bingo', sessionId, reason, ended_at, event_id }` (`../bingo.game/ws/bingo_server.js:1549`, `../bingo.game/ws/bingo_server.js:1555`).
- Persistance winners phase: write `phase_winner` payload `{ game:'bingo', sessionId, player_id, playerId?, phase, event_id }` (admin et player flow) (`../bingo.game/ws/bingo_server.js:1894`, `../bingo.game/ws/bingo_server.js:1901`, `../bingo.game/ws/bingo_server.js:2225`, `../bingo.game/ws/bingo_server.js:2232`).
- `event_id` write requis/injecté dans `canvasWrite` (`../bingo.game/ws/envUtils.js:239`, `../bingo.game/ws/envUtils.js:258`).
- Hydratation DB reload organizer: only `players_get` sur session (`{ game:'bingo', sessionId }`) puis mapping dans `paperPlayersByGame` (joueurs fusionnés dans snapshot) (`../bingo.game/ws/bingo_server.js:2754`, `../bingo.game/ws/bingo_server.js:2787`, `../bingo.game/ws/bingo_server.js:2897`, `../bingo.game/ws/bingo_server.js:3098`).
- Payloads WS reload: en `auth_client`/`auth_remote`, snapshot `state` construit via `buildStateFor(...getPlayersSnapshot)`; pas de payload winners/podium dédié (`../bingo.game/ws/bingo_server.js:871`, `../bingo.game/ws/bingo_server.js:1051`, `../bingo.game/ws/bingo_server.js:3137`).

### Gaps identifiés (sans patch)
- Aucune lecture DB de winners de phase au reload (`phase_winner` est write-only côté WS): aucun `winners_get`/`phase_winner_get`/mapping winners trouvé (`../bingo.game/ws/bingo_server.js`, recherche code sur actions read).
- Le snapshot de reprise reconstruit la liste joueurs (`num_connected_players`, `players`) mais pas une liste historique des gagnants de phase; l’UI reçoit les winners uniquement via messages live `phase_over` au moment où ils surviennent (`../bingo.game/ws/bingo_server.js:2287`, `../bingo.game/ws/bingo_server.js:3130`).

## Done
- [x] 2026-02-13 — WS bingo observability: ajout d’un log `WS_CLIENT_DISCONNECTED` enrichi (`sid`, `role`, `meta.ws_client_id`, `meta.ws_role`, `closeCode`, `closeReason`, `intent`, `involuntary`) pour corréler les coupures WS avec les erreurs front de support/hydratation.
- [x] 2026-02-12 — Bingo WS `update_session_infos` hardening: ne diffuse plus de `prizes` implicites vides quand aucune info lots n’est fournie; conservation de l’état lots existant et protection contre effacement UI des lots côté player.
- [x] 2026-02-10 — Audit avant modif (NO PATCH) du cycle joueur WS (auth/reconnect/disconnect) et du lien DB.
- [x] 2026-02-10 — Constat: serveur WS bingo ne reconstruit pas la liste joueurs depuis DB au boot; snapshot basé mémoire/socket (+ papier).
- [x] 2026-02-10 — Constat: `auth_player` remplace une connexion existante même `idPlayer` (anti multi-onglet par socket).
- [x] 2026-02-10 — Constat: disconnect passif => `markInactive` mémoire; désactivation DB seulement sur quit volontaire.
- [x] 2026-02-10 — Constat SQL bridge: `bingo_api_player_register` fait INSERT simple, check idempotence commenté => risque doublons actifs.
- [x] 2026-02-11 — Patch Bingo compat quiz/blindtest: hydratation players DB à la connexion organizer (`PLAYERS_HYDRATE_*` best-effort + dedup déterministe), replacement WS player “last connection wins” (`SESSION_REPLACED` + close `4005` + cleanup `player-replaced`), instrumentation write unifiée `CANVAS_WRITE_OK/ERR` incluant `event_id`.
- [x] 2026-02-11 — Harmonisation identité joueur Bingo: `player_id` canonique (`p:<uuid>`) propagé sur register/assign/hydrate/sync, séparation explicite `player_id` (stable) vs `playerId` (id DB), bridge Bingo durci (résolution identité canonique + fallback legacy numeric -> canonical, `LEGACY_API_NOTE`) et réponses API enrichies (`player_id`, `playerId`, `legacy_identity`, `already_assigned`).
- [x] 2026-02-11 — WS bingo strict: `auth_player`/`auth_player_paper` refusent désormais les connexions sans `player_id` canonique valide (`PLAYER_ID_MISSING_OR_INVALID`), replacement `last connection wins` basé sur `player_id` canon, et logs lifecycle enrichis avec `player_id` + `player_db_id`.
- [x] 2026-02-11 — Hydrate bingo key-first: `PLAYERS_HYDRATE` conserve uniquement les rows avec `player_id` canon, stocke `player_id` + `player_db_id`, et la snapshot WS expose ces deux identités (canon primaire, numérique secondaire).
- [x] 2026-02-11 — Patch 4 WS→PHP glue: `canvasWrite` valide les payloads player-scoped (`phase_winner`, `deactivate_player`) via normalisation canon (`WS_API_PAYLOAD_VALIDATED`), `phase_winner` envoie désormais `player_id` canon key-first (avec fallback lookup local par `playerId`), et `bingo_api_deactivate_player` passe sur `_bingo_resolve_identity` avec retours `identity_mode` + `legacy_identity`.
- [x] 2026-02-11 — Patch 6 loadtest bingo: génération déterministe `player_id` (`p:<uuid>`) par bot (`cotton-bot-player-id-v1|bingo|sid|botId`), envoi `player_id` sur `player_register`/`auth_player` et writes gameplay (`grid_cells_sync`, `deactivate_player`), avec `playerId` numérique envoyé uniquement si connu.
- [x] 2026-02-11 — Reconnect terminal sync: sur `auth_client` et `auth_remote`, si la phase WS est terminale (`-1` ou `>=4`), le serveur renvoie désormais un `endGame` de resynchronisation (payload `{type,endGame,gameStatus,message,players,totalPlayers}`) après le snapshot `state`, sans write DB supplémentaire.
- [x] 2026-02-12 — Uniformisation `admin_player_register` bingo: acceptation key-first (`player_id` canon) avec fallback `playerId` numérique, refresh/diffusion `num_connected_players` enrichi (`player_id` + `playerId`), digest aligné canon-first, et fallback DB pré-migration si colonne `bingo_players.player_id` absente.
- [x] 2026-02-12 — Bingo papier admin (phase manuelle): correction du décalage `next_phase` (calcul basé sur `requestedPhase` quand valide dans `phases_liste`) et restauration des notifs victoire en format historique `PlayerWin` (`log_type=3`, message `"<PHASE> gagnée : Bravo ..."`).
- [x] 2026-02-12 — Bingo fin de session (fallback UI): `endGame` WS enrichi avec `players/totalPlayers`; `phase_over` manuel sans identité envoie `winner_name` fallback; snapshot players durci (`player_id` -> `player_db_id` -> `playerName`) pour éviter la perte de la liste joueurs remote.
