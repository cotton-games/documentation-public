# Repo `blindtest` — Tasks

## PATCH 2026-07-15 — Validation papier puis fin naturelle vers Hub
- [x] Remplacer le relais local `paper_finalize_end` par `finalizePaperScores()` avec états monotones et `event_id` stable côté Remote.
- [x] Persister le classement équipe/solo avant `endGame`/completion Hub; restaurer la revue sans podium sur échec.
- [x] Persister podium/classement avant toute transition Hub.
- [x] Forcer le statut terminal dans le `session_update` papier, après constat live `hub_natural_end_results_unavailable: session_not_terminated`; restaurer le statut de revue sur échec.
- [x] Appeler l'action dédiée et notifier Master/Players seulement pour une exécution Hub durable confirmée; journaliser le nombre de sockets avant fermeture différée.
- [x] Conserver l'écran final historique hors Hub et en fallback Canvas.
- [x] En démo Hub canonique, envoyer le résultat historique équipe/solo avant `HUB_SESSION_FINISHED` et transporter `runtimeMode=demo`; ne pas armer ce retour pour une démo Dashboard sans exécution Hub.
- [ ] Recette WS/DB/navigateur réelle: attente, correction, validation vierge, double clic, reload, Master absent, A tardif/B actif, équipe/solo à égalité et hors Hub.

## PATCH 2026-07-12 — Expiration définitive de grâce Hub
- [x] Stocker/annuler le timer 1 h et protéger timer/incarnation concurrents.
- [x] Clear Hub avant `SESSION_ENDED`, sans bloquer la fin sur erreur HTTP.
- [ ] Recette réelle grâce/reconnexion/expiration/A→B/hors Hub.

## PATCH 2026-07-07 — Equipes runtime: conserver les préparations à 1 membre

### Objectif
- ne plus dissoudre automatiquement une equipe préparée qui retombe à 1 membre avant lancement;
- supprimer uniquement les equipes vides après départ volontaire du dernier membre;
- conserver la règle de classement runtime: 2+ membres = equipe active, moins de 2 = joueur solo.

### Modifie
- `../blindtest/web/server/actions/teams.js`
  - `leaveCurrentTeam()` retire seulement le joueur courant de son equipe;
  - remplacement de la dissolution des equipes à 1 membre par `pruneEmptyTeams()`;
  - log `TEAM_REMOVED_EMPTY` quand une equipe n'a plus aucun membre.
- `../blindtest/web/server/restart_serveur.txt`
  - marker `restart 07-07-2026/02`.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/teams.js`
- Harness Node avec mocks `messaging/logger`: creation A, B rejoint, B quitte, A reste dans l'equipe; equipe vide supprimée seulement au départ du dernier membre.
- `git -C /home/romain/Cotton/blindtest diff --check`

## PATCH 2026-07-07 — Equipes runtime solo: reclassement joueur

### Objectif
- ne considérer une équipe runtime Blind Test comme participant de classement que si au moins 2 membres sont réellement rattachés au runtime;
- traiter une équipe préparée restée seule au démarrage comme un joueur solo dans les payloads live, fin de partie et snapshots rejoués;
- éviter `isTeam=true`, `teamId` ou `teamName` publics pour les lignes à 1 membre.

### Modifie
- `../blindtest/web/server/actions/gameplay.js`
  - filtre les équipes runtime via les membres présents dans `session.players`;
  - normalise les entrées de classement avant émission WS (`updatePlayers`, `endGame`, snapshots terminés);
  - transmet `teamMemberCount` et restaure le pseudo du membre unique quand un snapshot ancien porte encore des métadonnées équipe.
- `../blindtest/web/server/restart_serveur.txt`
  - marker `restart 07-07-2026/01`.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/gameplay.js`
- `git -C /home/romain/Cotton/blindtest diff --check`

## PATCH 2026-07-06 — Equipes runtime: nom brut dans les payloads

### Objectif
- ne plus exposer `Nom equipe (n)` comme libelle public;
- conserver `teamMemberCount` / `members` pour les besoins techniques;
- faire porter l'information equipe par les champs `isTeam/teamId/teamName`.

### Modifie
- `../blindtest/web/server/actions/gameplay.js`
  - `teamDisplayName()` renvoie le nom equipe brut;
  - les entrees de classement/podium gardent `teamMemberCount` separement.
- `../blindtest/web/server/restart_serveur.txt`
  - marker `restart 06-07-2026/07`.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/gameplay.js`
- `git -C /home/romain/Cotton/blindtest diff --check`

## PATCH 2026-07-06 — Reprise session terminee: equipes runtime

### Objectif
- conserver les equipes runtime dans les podiums/classements quand une interface master ou remote ouvre une session Blind Test deja terminee;
- separer `totalPlayers` (joueurs inscrits/connectes pour badges) de `rankingEntriesTotal` (participants classes: equipes + solos).

### Modifie
- `../blindtest/web/server/actions/gameplay.js`
  - `getGameStateForRemote()` reutilise `buildEndGamePayloadFromSession()` pour les sessions terminees;
  - payload `endGame` expose `totalPlayers` joueurs et `rankingEntriesTotal` classement;
  - lookup joueur reconnecte en fin de session compare les IDs en string et transmet `isTeam/teamMode`.
- `../blindtest/web/server/actions/registration.js`
  - reprise orga terminee tente d'hydrater `finalRankings/finalPodium` depuis `blindtest_session_teams`;
  - fallback historique conserve si aucune equipe runtime persistee n'existe.
- `../blindtest/web/server/actions/envUtils.js`
  - ajout `CanvasAPI.sessionTeamsGet()`.
- `../blindtest/web/server/restart_serveur.txt`
  - marker `restart 06-07-2026/05`.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/gameplay.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/envUtils.js`
- Harness Node `getGameStateForRemote()` sur session terminee: podium `LES REMOS (2)` + solo, `totalPlayers=3`, `rankingEntriesTotal=2`.

## PATCH 2026-07-06 — EndGame player: anti-crash et IDs classement

### Objectif
- eviter qu'une erreur asynchrone de fin de partie ferme le process WS sans log exploitable;
- garantir le mapping des rangs player quand les entrees finales utilisent des IDs string/canon;
- conserver le total classement mixte equipes + solos pour l'ecran de fin player.

### Modifie
- `../blindtest/web/server/actions/gameplay.js`
  - ajout `runEndGame()` avec `catch` journalise `WS_GAME_ENDGAME_FAILED`;
  - `initializeOrUpdateSession()` passe par ce wrapper;
  - les maps `rankById` / `scoreById` / `entryById` utilisent des cles string.
- `../blindtest/web/server/actions/registration.js`
  - reprise orga / hydratation session terminee passe par `runEndGame()`.
- `../blindtest/web/server/restart_serveur.txt`
  - marker `restart 06-07-2026/04`.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/gameplay.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/registration.js`
- Harness Node local avec mock `ws`: session mixte `team:les_remos` + solo, 3 joueurs connectes, 2 participants classes; les membres equipe recoivent `finalRank=1`, `rankingEntriesTotal=2`, `isTeam=true`, `teamId=team:les_remos`.

## PATCH 2026-07-06 — Player payload: participants classement equipe

### Objectif
- transmettre au player le total de participants de classement distinct du total joueurs connectes;
- indiquer si l'entree finale du joueur est une equipe.

### Modifie
- `../blindtest/web/server/actions/gameplay.js`
  - `updatePlayers` player porte `rankingEntriesTotal` et `isTeam`;
  - `endGame` player porte `totalPlayers` = joueurs connectes reels, `rankingEntriesTotal` = equipes + solos, et `isTeam`;
  - `buildEndGamePayloadFromSession()` expose `teamMode`.
- `../blindtest/web/server/restart_serveur.txt`
  - marker `restart 06-07-2026/03`.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/gameplay.js`

## PATCH 2026-07-06 — Equipes runtime: persistance du classement final

### Objectif
- envoyer le classement final mixte complet au bridge Canvas;
- permettre la persistance dediee des equipes Blind Test hors podium;
- refuser une collision visible entre nom d'equipe et pseudo joueur.

### Modifie
- `../blindtest/web/server/actions/gameplay.js`
  - `persistPodium()` transmet aussi `players` depuis le payload final `endGame`;
  - les equipes restent dans le classement mixte, les membres ne sont pas promus en entrees de classement.
- `../blindtest/web/server/actions/teams.js`
  - normalisation forte des noms d'equipe proche du dashboard;
  - refus `TEAM_NAME_PLAYER_COLLISION` quand le nom d'equipe normalise existe deja comme pseudo joueur;
  - correction du log `TEAM_FULL`.
- `../blindtest/web/server/restart_serveur.txt`
  - marker `restart 06-07-2026/02`.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/gameplay.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/teams.js`

## PATCH 2026-07-06 — Equipes runtime: code court et messages de verrouillage

### Objectif
- ajouter un code equipe runtime de 4 caracteres, dicible et unique dans la session;
- permettre de rejoindre une equipe par code apres inscription joueur;
- enrichir le message de verrouillage equipe avec le resultat connu quand il existe.

### Modifie
- `../blindtest/web/server/actions/teams.js`
  - generation `teamCode` avec alphabet lisible `ACDEFGHJKMNPQRTUVWXYZ234679`;
  - exposition du code dans `teamState` seulement pour les membres de l'equipe;
  - nouvelle action `teamJoinByCode`;
  - refus explicite si le joueur appartient deja a une autre equipe.
- `../blindtest/web/server/actions/wsHandler.js`
  - routing et log allow pour `teamJoinByCode`.
- `../blindtest/web/server/actions/gameplay.js`
  - `teamItemAnswers` conserve `resultKnown`;
  - les messages `teamAlreadyAnswered` transportent `teamAnswerScore`, `teamAnswerCorrect`, `teamAnswerResultKnown` et un wording bonne/mauvaise reponse quand le resultat est connu.
- `../blindtest/web/server/restart_serveur.txt`
  - marker `restart 06-07-2026/01`.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/teams.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/wsHandler.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/gameplay.js`

### Recette manuelle restante
- P1 cree une equipe: code affiche cote membre.
- P2 rejoint avec le code correct: succes et compteur 2/6.
- Code faux: message `Code équipe introuvable.`.
- P7 sur equipe pleine: message `Cette équipe est complète.`.
- Joueur deja membre d'une autre equipe: message `Tu fais déjà partie d’une équipe.`.
- En cours de jeu: le deuxieme membre voit le verrouillage avec le membre repondant et, resultat connu, points ou aucun point.

## PATCH 2026-07-03 — Equipes runtime: libelle compatible classements agrégés

### Objectif
- rendre les noms d'equipes runtime lisibles dans les classements agreges Pro qui ne savent pas encore agreger les membres;
- afficher le nombre de membres dans le libelle persiste, par exemple `Les winners (4)`.

### Modifie
- `../blindtest/web/server/actions/gameplay.js`
  - ajoute `teamDisplayName(teamName, memberCount)`;
  - les entrees de classement equipe utilisent `playerName = "{teamName} ({memberCount})"`;
  - conserve `teamName` brut et les `members` pour les clients runtime capables de lire les metadonnees equipe.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/gameplay.js`

## PATCH 2026-07-03 — Equipes runtime: une seule reponse par morceau

### Objectif
- empecher une equipe de tenter plusieurs propositions sur un meme morceau;
- faire compter la premiere reponse envoyee par un membre pour toute l'equipe;
- verrouiller immediatement les autres membres jusqu'au morceau suivant;
- conserver le comportement solo et le comportement sans equipe strictement inchanges.

### Modifie
- `../blindtest/web/server/actions/registration.js`
  - initialise `session.teamItemAnswers`.
- `../blindtest/web/server/actions/gameplay.js`
  - ajoute la source canonique runtime `session.teamItemAnswers[teamId][currentSongIndex]`;
  - sur `checkAnswer`, refuse les reponses d'une equipe ayant deja repondu au morceau avec `teamAlreadyAnswered`;
  - stocke la premiere reponse `{playerId, answer, score, answeredAt}`;
  - marque tous les membres de l'equipe en `hasAnswered` pour le morceau;
  - diffuse aux coequipiers le message de verrouillage;
  - remplace le scoring equipe "meilleur score par morceau" par "score de la premiere reponse d'equipe par morceau".

### Logs ajoutes
- `TEAM_ANSWER_LOCKED`
- `TEAM_SCORE_FIRST_SELECTED`

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/gameplay.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/teams.js`

### Recette manuelle restante
- Equipe P1/P2/P3.
- P2 repond en premier correctement: P1/P3 sont verrouilles, score equipe = score P2.
- P2 repond en premier faux: P1/P3 ne peuvent pas retenter.
- Morceau suivant: P1/P2/P3 peuvent de nouveau repondre.
- Joueur solo inchange.
- Sans equipe creee: comportement strictement identique a l'existant.
- Reconnexion d'un membre apres reponse equipe: il voit l'etat verrouille si l'equipe a deja repondu au morceau.

## PATCH 2026-07-03 — Equipes runtime: quit volontaire vs fermeture socket

### Objectif
- retirer un joueur de son equipe uniquement sur quit volontaire;
- conserver son appartenance equipe sur fermeture d'onglet / deconnexion socket;
- diffuser un `teamState` complet apres quit ou disconnect pour garder les compteurs joueurs coherents.
- dissoudre avant demarrage une equipe qui retombe a un seul membre, le joueur restant redevient solo.

### Diagnostic
- Le bouton player `Quitter` envoie `quitGame` depuis `games/web/includes/canvas/play/play-ui.js`.
- `blindtest/web/server/actions/wsHandler.js` route `quitGame` vers `handleDisconnect(..., true)`.
- `connection.js` retirait deja le joueur de `session.players` et declenchait `deactivate_player`, mais ne retirait pas `player_id` de `session.teams`.
- Les fermetures socket involontaires conservent le joueur en memoire avec `isConnected=false`, ce qui doit aussi conserver l'appartenance equipe.

### Modifie
- `../blindtest/web/server/actions/teams.js`
  - export `removePlayerFromRuntimeTeam(...)`, sans garde de verrouillage, reserve aux sorties serveur.
  - dissout les equipes a membre unique avant demarrage apres un depart/changement d'equipe.
- `../blindtest/web/server/actions/connection.js`
  - sur quit volontaire: retire le `player_id` de son equipe runtime avant de retirer le joueur de `session.players`;
  - sur fermeture socket / remplacement: conserve l'equipe;
  - diffuse `teamState` apres quit volontaire, remplacement et disconnect involontaire.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/teams.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/connection.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/wsHandler.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/gameplay.js`

### Recette manuelle restante
- P1 cree equipe => 1/6.
- P2 rejoint => P1/P2 voient 2/6.
- P1 clique `Quitter` avant demarrage => l'equipe est dissoute; P2 redevient solo.
- P3 rejoint ensuite une equipe existante seulement si une nouvelle equipe a ete formee.
- P1 ferme l'onglet au lieu de quitter => P2 voit toujours 2/6.
- P3 rejoint => P2/P3 voient 3/6.
- P1 reconnecte avec le meme `player_id` apres fermeture onglet => il retrouve l'equipe.

## PATCH 2026-07-03 — Blind Test runtime teams V1

### Objectif
- ajouter une surcouche d'equipes runtime limitee au Blind Test numerique;
- conserver l'inscription joueur existante et les scores/ecritures Canvas individuels;
- afficher un classement equipe quand au moins une equipe runtime existe, avec joueurs solo traites comme equipes de 1.

### Diagnostic
- L'etat pret/non demarre est porte par `session.gameStatus === "En attente"` et `session.mainPlayerStarted !== true`.
- L'interface master ouverte est detectable via `session.primarySocket` ouverte.
- Le rattachement reconnectable peut s'appuyer sur `player_id` canonique deja obligatoire dans `registerPlayer`.
- Aucune persistance DB n'est indispensable pour la V1: `session.teams` et `session.teamPlayers` restent en memoire pour la session WS.

### Modifie
- `../blindtest/web/server/actions/teams.js`
  - nouveau module runtime-only `teamCreate`, `teamJoin`, `teamLeave`, `teamList`;
  - modele `session.teams[]` + `session.teamPlayers[player_id]`;
  - limite 6 membres, verrou apres demarrage, un joueur dans une seule equipe.
- `../blindtest/web/server/actions/wsHandler.js`
  - routing WS des actions equipe.
- `../blindtest/web/server/actions/registration.js`
  - init des structures equipe et emission `teamState` apres inscription/reconnexion joueur.
- `../blindtest/web/server/actions/gameplay.js`
  - conservation du score individuel;
  - stockage `player.itemScores[currentSongIndex]`;
  - projection de classement equipe par somme des premieres reponses d'equipe par morceau;
  - podium/fin de session bases sur cette projection quand une equipe existe.
- `../blindtest/web/server/messaging.js`
  - logs WS OUT autorises pour `teamState` / `teamError`.
- `../blindtest/web/server/restart_serveur.txt`
  - marker WS `restart 03-07-2026/01`.

### Logs ajoutes
- `TEAM_CREATED`
- `TEAM_JOINED`
- `TEAM_FULL`
- `TEAM_LOCKED_AFTER_START`
- `TEAM_SCORE_FIRST_SELECTED`

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/teams.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/wsHandler.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/gameplay.js`
- `node --check /home/romain/Cotton/blindtest/web/server/messaging.js`

### Recette manuelle restante
- 1 joueur solo: classement identique a l'existant.
- Equipe de 2: score equipe = somme des premieres reponses d'equipe par morceau.
- Equipe de 6: creation/join OK jusqu'a 6.
- Tentative 7e joueur: refus `TEAM_FULL`.
- Joueur deja dans une equipe: bascule vers la nouvelle equipe, sans double appartenance.
- Reconnexion joueur: rattachement equipe conserve via `player_id` canon.
- Demarrage session puis join/create/leave: refus `TEAM_LOCKED_AFTER_START`.

## PATCH 2026-06-12 — Primary organizer: recovery apres remplacement device

### Objectif
- appliquer le meme garde-fou que Quiz, car Blind Test partage le modele `session.primarySocket`;
- eviter une perte de primary si une socket organizer valide existe encore;
- ne modifier aucun flow papier/numerique.

### Diagnostic
- Blind Test a le meme modele que Quiz: primary dans `session.primarySocket`, remote dans `secondarySockets`.
- `registerOrganizer()` promeut deja si aucun primary ouvert n'existe, mais `sendMessageToPrimary()` ne recuperait pas de socket organizer candidate en cas de reference absente/fermee.
- Le handler de fermeture testait la deconnexion volontaire avant de sortir sur une fermeture stale.

### Modifie
- `../blindtest/web/server/messaging.js`
  - recovery primary depuis une socket organizer ouverte connue;
  - logs `PRIMARY_ORGANIZER_RECOVERED` et `WS_SEND_NO_PRIMARY_ORGANIZER` enrichi.
- `../blindtest/web/server/actions/connection.js`
  - log `PRIMARY_ORGANIZER_CLOSE_IGNORED_STALE` et sortie immediate sur fermeture d'ancien primary.
- `../blindtest/web/server/restart_serveur.txt`
  - marker WS `restart 12-06-2026/03`.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/messaging.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/connection.js`

## PATCH 2026-06-12 — Remote papier score: ACK HTTP et logs resync

### Objectif
- verifier que la correction papier Blind Test ne depend pas du primary organizer WS;
- conserver le flow metier existant;
- ajouter les preuves WS/bridge manquantes et eviter la double persistance apres ACK HTTP.

### Diagnostic
- La remote commune `games` persiste le score via `blindtest:update_score` avant d'emettre `admin_set_score`.
- Le serveur WS Blind Test appliquait ensuite le score en memoire mais persistait encore via `persistScore`, meme quand le payload portait `persisted=true`.

### Modifie
- `../blindtest/web/server/actions/gameplay.js`
  - journalise `WS_REMOTE_PAPER_WRITE_RX`, `WS_REMOTE_PAPER_RESYNC_APPLIED` et `WS_REMOTE_PAPER_WRITE_ACK`;
  - saute la persistance WS quand le write remote papier est deja confirme par HTTP;
  - conserve le refresh memoire et organizer.
- `../blindtest/web/server/restart_serveur.txt`
  - marker WS `restart 12-06-2026/02`.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/gameplay.js`

## PATCH 2026-06-12 — Observability WS roles organizer/remote

### Objectif
- aligner l'observabilite WS Blind Test avec Quiz pour comparer les incidents papier entre jeux;
- distinguer clairement organizer, remote et player dans les fermetures `1006`;
- ne modifier aucun flow metier papier.

### Modifie
- `../blindtest/web/server/actions/registration.js`
  - tag explicite `socket.wsRole` / `socket.role` pour primary organizer, remote secondary et player.
- `../blindtest/web/server/actions/wsHandler.js`
  - classification `organizer_background` si un organizer se deconnecte peu apres un signal `client_background`;
  - ajout `meta.ws_type="close"` sur `WS_CLIENT_DISCONNECTED`.
- `../blindtest/web/server/messaging.js`
  - enrichissement de `WS_SEND_NO_PRIMARY_ORGANIZER` avec `message_type`, presence/readyState primary et nombre de secondary.
- `../blindtest/web/server/restart_serveur.txt`
  - marker WS mis a jour.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/wsHandler.js`
- `node --check /home/romain/Cotton/blindtest/web/server/messaging.js`

## PATCH 2026-05-04 — Reprise demo: score joueur avant bind WS

### Objectif
- comprendre et corriger la remise a zero du score quand l'iframe joueur se reconnecte apres une reprise de demo numerique;
- borner le correctif aux demos numeriques deja lancees.

### Cause racine
- sur reprise demo, la vue organizer pouvait deja afficher le score depuis `players_get`;
- au passage sur `Jouer`, `registerPlayer` pouvait chercher le joueur dans `session.players` avant que le cache WS ait ete hydrate depuis la DB;
- si le joueur n'etait pas trouve en memoire, le WS recreait/bindait un joueur runtime a `playerScore: 0`, puis renvoyait cet etat a l'iframe.

### Modifie
- `../blindtest/web/server/actions/registration.js`
  - `registerPlayer(...)` devient asynchrone;
  - avant le bind joueur, hydrate `session.players` depuis `players_get` uniquement si `session.isDemo === true`, `session.paperMode !== true`, `!isAdminPaper`, et session deja lancee.
- `../blindtest/web/server/actions/wsHandler.js`
  - attend `registerPlayer(...)` pour garantir l'ordre hydrate -> bind.
- `../blindtest/web/server/restart_serveur.txt`
  - marker WS mis a jour.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/wsHandler.js`
- `git diff --check`

## PATCH 2026-05-04 — Demo participant dans quota

### Objectif
- aligner la limite demo affichee avec le nombre de joueurs connectes;
- faire compter `Joueur démo` dans `maxPlayers`.

### Modifie
- `../blindtest/web/server/actions/registration.js`
  - `countQuotaPlayers(...)` compte maintenant tous les joueurs memoire;
  - le blocage session pleine s'applique aussi au joueur demo si la limite est deja atteinte.
- `../blindtest/web/server/actions/connection.js`
  - retour sous limite recalcule sur tous les joueurs.
- `../blindtest/web/server/restart_serveur.txt`
  - marker WS mis a jour.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/connection.js`

## PATCH 2026-04-30 — Demo participant hors quota

### Objectif
- permettre au participant automatique `Joueur démo` des demos desktop de rester visible cote organizer;
- garantir que ce participant ne consomme pas une place dans `maxPlayers`;
- laisser les vrais joueurs mobiles rejoindre via QR code en plus du joueur demo.

### Modifie
- `../blindtest/web/server/actions/registration.js`
  - detection `demoParticipant:true` uniquement si la session WS est marquee demo;
  - stockage `isDemoParticipant` sur le joueur en memoire;
  - calcul de quota via joueurs hors demo pour `checkSessionStatus`, reset `limitReached` et blocage session pleine.
- `../blindtest/web/server/actions/connection.js`
  - retour sous limite recalcule hors participants demo.
- `../blindtest/web/server/restart_serveur.txt`
  - marker WS mis a jour.

### Verification
- `node --check /home/romain/Cotton/blindtest/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/connection.js`

## PATCH 2026-03-24 — Logs prod cibles reprise joueur Blindtest

### Objectif
- ajouter une preuve `info` serveur compacte a chaque rattachement player WS, afin de verifier demain si les coupures mobiles se traduisent bien par une reprise fonctionnelle de session.

### Correctif livre
- `../blindtest/web/server/actions/registration.js`
  - ajout du log `PLAYER_WS_BOUND` (niveau `info`) sur les deux chemins `registerPlayer`:
    - nouveau joueur,
    - joueur reconnecte.
  - meta: `{ player_id, player_db_id, player_name, is_reconnect, is_admin_paper }`.

### Effet attendu
- les sessions Blindtest prod montrent maintenant explicitement les rattachements WS joueur reussis, au lieu de ne laisser visibles que les coupures.

## Todo
- Vérifier en intégration que tous les writes WS player-scoped passent en `identity_mode=canon` (blindtest `update_score` + `deactivate_player`).
- Surveiller `LEGACY_REGISTER_USED`; retirer définitivement le fallback `playerId` dès compteur=0 côté WS register.
- Planifier retrait du fallback legacy côté glue (`identity_mode=legacy`) dès extinction des usages.
- Exécuter un smoke test loadtest WS (20s, 3 bots) et confirmer `PLAYER_ID_MISSING_OR_INVALID=0`.

## Quick checks (Patch 6)
- Syntaxe WS:
  - `node --check ../blindtest/web/server/actions/loadtest.js`
  - `node --check ../blindtest/web/server/actions/envUtils.js`
  - `node --check ../blindtest/web/server/actions/connection.js`
  - `node --check ../blindtest/web/server/actions/gameplay.js`
- Smoke test bots:
  - `rg -n "BOT_IDENTITY|PLAYER_ID_MISSING_OR_INVALID|LEGACY_REGISTER_USED" ../blindtest/web/server/server-logs.log`
  - Relance à paramètres identiques (`sid` + bot range) et vérifier `player_id` identiques dans `BOT_IDENTITY`.
- Contrat bridge blindtest:
  - `php -l ../games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `rg -n "identity_mode|legacy_identity|BAD_PLAYER_ID|PLAYER_NOT_FOUND|_blindtest_is_canonical_player_id" ../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- Contrat front register (games):
  - `rg -n "player_stable_id:|getSessionScopedStableKey|getOrCreateStablePlayerRef|player_register_tx|register/debug" ../games/web/includes/canvas/play/register.js`
- Migration SQL présente:
  - `rg -n "uq_bt_players_session_player|idx_bt_players_session_active|player_id" ../games/web/includes/canvas/sql/2026-02-10_players_player_id_upsert.sql`
- Logs runtime:
  - `rg -n "PLAYER_REGISTER_UPSERT_(OK|ERR)|MISSING_PLAYER_ID|PLAYER_DEACTIVATE_BY_KEY_(OK|ERR)" ../blindtest/web/server/server-logs.log`
- Replacement WS player:
  - `rg -n "PLAYER_REPLACEMENT|PLAYER_SOCKET_REPLACED_CLEANUP|WS_CLIENT_DISCONNECTED" ../blindtest/web/server/server-logs.log`
  - `rg -n "SESSION_REPLACED|4005|player-replaced" ../blindtest/web/server/actions/registration.js ../blindtest/web/server/actions/wsHandler.js ../blindtest/web/server/actions/connection.js`

## AUDIT fin de session (2026-02-11, NO PATCH)

### Fichiers inspectés
- `../blindtest/web/server/actions/gameplay.js`
- `../blindtest/web/server/actions/registration.js`
- `../blindtest/web/server/actions/sessionUtils.js`
- `../blindtest/web/server/actions/envUtils.js`
- `../blindtest/web/server/actions/wsHandler.js`
- `../blindtest/web/server/actions/connection.js`
- `../blindtest/web/server/resources/sessions.js`

### Constats factuels
- End detection: bascule par `initializeOrUpdateSession` quand `gameStatus === "Partie terminée"` puis `endGame(sessionId)` (`../blindtest/web/server/actions/gameplay.js:202`, `../blindtest/web/server/actions/gameplay.js:205`, `../blindtest/web/server/actions/gameplay.js:868`).
- Persistance DB à la fin: write `session_update` via `persistPodium` avec payload `{ sessionId, currentSongIndex, gameStatus, totalPlayers, podium, game:'blindtest' }` (`../blindtest/web/server/actions/gameplay.js:1092`, `../blindtest/web/server/actions/gameplay.js:1112`, `../blindtest/web/server/actions/gameplay.js:1122`). `event_id` injecté/obligatoire (`../blindtest/web/server/actions/envUtils.js:302`, `../blindtest/web/server/actions/envUtils.js:319`).
- Hydratation DB au reload organizer: `ensureSessionPrimaryId` (`session_primary_id`) puis `players_get`, mapping dans `session.players` (`../blindtest/web/server/actions/sessionUtils.js:19`, `../blindtest/web/server/actions/registration.js:618`, `../blindtest/web/server/actions/registration.js:642`, `../blindtest/web/server/actions/registration.js:726`).
- Payloads WS envoyés après reload: snapshot players `updatePlayers` puis, en session terminée, payload `endGame` (orga via `sendMessageToOrganizers`, players reconnect via `getGameState`) (`../blindtest/web/server/actions/gameplay.js:840`, `../blindtest/web/server/actions/gameplay.js:895`, `../blindtest/web/server/actions/gameplay.js:453`, `../blindtest/web/server/actions/gameplay.js:525`).
- Reconstruction podium/classement: tri score desc + tie-break `playerId` alpha, ranking compétition, podium rang 1..3; snapshot mémoire `finalPodium/finalRankings` prioritaire si présent (`../blindtest/web/server/actions/gameplay.js:783`, `../blindtest/web/server/actions/gameplay.js:794`, `../blindtest/web/server/actions/gameplay.js:933`, `../blindtest/web/server/actions/gameplay.js:991`).

### Gaps identifiés (sans patch)
- Pas de read DB podium dédié au reload: only `players_get`; podium reload dépend snapshot mémoire ou recalcul joueurs (`../blindtest/web/server/actions/registration.js:642`, `../blindtest/web/server/actions/gameplay.js:940`, `../blindtest/web/server/actions/gameplay.js:991`).
- `getGameStateForRemote` en session terminée lit `playerRank` sur `finalRankings` alors que le snapshot figé stocke `finalRank`; risque de `playerRank` nul sur ce chemin (`../blindtest/web/server/actions/gameplay.js:464`, `../blindtest/web/server/actions/gameplay.js:468`, `../blindtest/web/server/actions/gameplay.js:885`).

## Done
- [x] 2026-02-13 — WS blindtest observability: `WS_CLIENT_DISCONNECTED` enrichi avec `meta.ws_client_id`, `meta.ws_role` et `closeReason` (en plus de `closeCode/intent/involuntary`) pour faciliter la corrélation avec incidents front.
- [x] 2026-02-12 — WS blindtest: fix `disconnectPlayers` crash (`deactivations is not defined`) en réintroduisant la collecte `deactivations` avant `Promise.allSettled`; fin de session organizer (volontaire) validée sans erreur runtime.
- [x] 2026-02-10 — Patch 2: `blindtest_api_player_register` passé en UPSERT par `(session_id, player_id)`.
- [x] 2026-02-10 — Patch 2: fallback `player_id` serveur si absent (compat vieux client) + trace `MISSING_PLAYER_ID` côté bridge.
- [x] 2026-02-10 — Patch 2: `blindtest_api_deactivate_player` priorise `(session_id, player_id)` puis fallback legacy `(id, session_id)`.
- [x] 2026-02-10 — WS blindtest: logs `PLAYER_DEACTIVATE_BY_KEY_OK/ERR` ajoutés dans `web/server/actions/connection.js`.
- [x] 2026-02-10 — Front register (games): envoi `player_id` stable sur `player_register` pour quiz/blindtest.
- [x] 2026-02-11 — Front register (games): `player_id` désormais stable par session via clé `${slug}:player_stable_id:${sessionId}` + migration douce depuis la clé legacy.
- [x] 2026-02-10 — Patch 2b: `persistScore` envoie explicitement `player_id` dans `web/server/actions/gameplay.js`.
- [x] 2026-02-10 — Patch 2c: suppression de la dépendance `created_at/updated_at` dans les writes `blindtest_players` (`player_register`, fallback `update_score`, `deactivate_player`) pour éviter les `SQL_ERROR` si schéma partiel.
- [x] 2026-02-11 — WS blindtest: politique player “last connection wins” sur `registerPlayer` (event `SESSION_REPLACED`, close code `4005`, intent `player-replaced`, cleanup mémoire sans `deactivate_player` DB).
- [x] 2026-02-11 — WS blindtest: `registerPlayer` strict `player_id` canon (`p:<uuid>`) obligatoire; reject + log `PLAYER_ID_MISSING_OR_INVALID` si absent/invalide; instrumentation `LEGACY_REGISTER_USED` si payload legacy numeric reçu.
- [x] 2026-02-11 — WS blindtest: `player_db_id` devient secondaire (`player.playerDbId`, `socket.playerDbId`, `registrationSuccess.playerId`), `deactivate_player` envoyé en mode key-first (`player_id` canon + `playerId` seulement si connu).
- [x] 2026-02-11 — Patch 4 WS→PHP glue: normalisation payload player-scoped dans `envUtils.canvasWrite` (`WS_API_PAYLOAD_VALIDATED`, `player_id` canon obligatoire, `playerId` numeric-only), `persistScore` corrigé key-first (`player_id` canon + `playerId?`), et bridge `blindtest_api_update_score`/`blindtest_api_deactivate_player` aligné key-first avec `identity_mode` + `legacy_identity`.
- [x] 2026-02-11 — Patch 6 loadtest blindtest: génération déterministe `player_id` (`p:<uuid>`) par bot (`cotton-bot-player-id-v1|blindtest|sid|botId`), register WS strict (`player_id` obligatoire, `playerId` seulement si numérique connu) et `checkAnswer` key-first (`player_id` + `playerId?`).
