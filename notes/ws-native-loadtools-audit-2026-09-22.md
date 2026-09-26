# Outils natifs de charge WS — audit du 22/09/2026

**OUTILS NATIFS INSUFFISANTS — HARNAIS À COMPLÉTER**

**BASELINE DEV AVANT PATCH PARTIELLE**

Les trois moteurs possèdent des générateurs de **vraies sockets**, réutilisables sans inventer un nouveau système. Une baseline partielle avant les patches performance est possible sous les prérequis ci-dessous. Mais les outils actuels ne suffisent pas à une qualification objective5 000 : branche profils Quiz/BT cassée localement, arrêt de rampe Quiz/BT incomplet, absence de suivi ACK/auth/queues/bytes, et générateur Bingo ancien pour le gameplay versionné. Les corrections nécessaires dépassent la seule instrumentation. **Aucun correctif ni test exécuté dans cette passe.**

## 1. Sources et limites de l’audit

Navigation relue : [START, Parcours/Discipline](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), [SITEMAP develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), [Manifest, routing documentaire](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md). Relus : [pipeline](hub-player-registration-pipeline-audit-2026-09-22.md), [capacité/BT](hub-capacity-publication-patch-2026-09-22.md), [auth Bingo](bingo-digital-auth-performance-2026-09-22.md), [bots Hub](hub-bots-2026-09-21.md), [ordre admission bots](bot-admission-order-2026-09-21.md), cartes des trois repos et logs canon.

Journal AI Studio RAW rechargé/décodé avant conclusion : aucune mention des scripts loadtest, dispatchers WS ou test_bots ciblés imposant un rechargement. L’ancienne mention ecommerce ne concerne pas une analyse interne ecommerce dans cet audit. **Absence de mention ≠ preuve de parité DEV.** L’état DEV avant patches est déclaré par l’utilisateur ; aucun fichier ni processus déployé n’a été inspecté ici.

Inventaire des checkouts accessibles, fichiers tests/scripts/ops visibles, recherches de symboles et historique Git disponible via `--all` ; pas de fetch, SSH, DB, navigateur ni accès aux serveurs applicatifs. Aucun autre outil autonome de création massive de sessions, CLI stress, k6/artillery/autocannon, mesure de percentile ou reconnexion massive retrouvé dans ce périmètre. D’éventuels fichiers d’exploitation seulement présents sur le serveur restent hors observation.

## 2. Inventaire actuel et historique

| Outil / fichier | Entrée et paramètres | Limite / dépendances / environnement |
|---|---|---|
| Quiz `quiz/web/server/actions/loadtest.js` | `startLoadtest({sessionId,nbBots,wsUrl,origin,configOverride})`, exposé par WS `startLoadtest` ; `stopLoadtest(sessionId)` | SAFE_MAX5000 **par lancement**, cadence fixe2ms ; `ws` dans `quiz/ws/node_modules`, crypto, globals/logger/sessions du serveur et Canvas réel |
| Blind Test `blindtest/web/server/actions/loadtest.js` | Même interface, copie autonome adaptée à BT | Même plafond/cadence ; dépendances sous `blindtest/ws` ; oracle tiré de la playlist mémoire BT |
| Quiz/BT, mêmes modules | `attachPreRegisteredBot({sessionId,wsUrl,origin,profile,configOverride})`, `stopAllLoadtests()` | Aucun SAFE_MAX dans attach ; mais branche WS profils actuellement interrompue par `profilesNames` non défini |
| Bingo `bingo.game/ws/bingo_loadtest.js` | Export `startLoadtest({sessionId,nbBots,wsUrl,configOverride})`, appel Node explicite | Pas de plafond numérique ; vagues10/400ms par défaut ; `ws`, `knex`, mysql, `knexfile.development`, logger, HTTP(S), service Canvas |
| Bingo, même module | `attachPreRegisteredBot`, `stopLoadtest({sessionId})`, `stopAll()` ; WS `startLoadtest` accepte `bot`/`profiles` | Aucun plafond attach ; handler exige playerId + gridId + gridSecret ; la commande WS ne raccorde **pas** l’export froid `startLoadtest(nbBots)` |
| Games `games/web/test_bots.php`, mode session | Page DEV `/test_bots.php` ; sessionId, nombre, presets/config ; factories navigateur `createBot`/`createBingoBot` | Champ HTML max200 ; code comporte pourtant une branche **>200** qui prépare des profils HTTP puis délègue aux serveurs par lots |
| Games, helpers gros volume dans la même page | `startServerSideBtQzBots`, `startServerSideBingoBots`, `startServerSideBots` | Préparation HTTP concurrence50 par défaut, lots50 ; pas de cap5000 interne à ces helpers ; branche profils Quiz/BT bloquée côté serveur |
| Hub `games/web/includes/bots/hub_bots.js` + page test_bots | `create({token,count,storage,request,attach,...})`, start/stop ; mode Hub | **1–200 imposé en JS**, identité sessionStorage, inscription/polling séquentiels ; intervalle5000ms après boucle, pas watcher réel3,5s |
| Tests Quiz/BT | `tests/primary-grace.test.cjs`, `tests/remote-continuity.test.cjs`, BT `tests/teams-disabled.test.cjs`, `web/tests/ranking_publication_index_test.cjs` | Tests locaux sous doubles/VM, dont classement synthétique5 000 ; pas un générateur réseau DEV |
| Tests Bingo | `ws/tests/bingo_auth_pipeline.test.js`, `bingo_reset.test.js`, `remote_continuity.test.js`, `runtime_expiry.test.js`, autres tests phase/quit/terminal | Tests de fonctions avec I/O simulées ;5 000 tentatives simulées dans le test auth, pas de preuve réseau/DB5 000 |
| Tests Games transverses | `web/tests/hub_capacity_{cohort,runtime,transport}_test.cjs`, `hub_bots{,_runtime}_test.cjs`, `bot_admission_order_test.cjs` | Vérification synthétique admission/cohortes ; pas des commandes de charge réelle |
| Bingo `ws/test.Dockerfile`, `ws/tests/demo.test.js` | Lanceur de tests Jest / validation historique de messages | Pas un outil de charge, ni provisionneur de sessions |

**Les trois fichiers loadtest sont des modules, pas des CLI.** `node actions/loadtest.js` ou `node bingo_loadtest.js` ne lance pas automatiquement N bots : pas de bloc main/lecture argv. Pour Quiz/BT, charger le module hors serveur perdrait en plus les globals et la playlist mémoire servant d’oracle.

Historique pertinent consulté :

- Quiz `cf0a719` (02/12/2025, big sessions), `596c706` (11/02/2026, identité canonique), `3e3e988` (21/09/2026, état actuel). BT `c936ba1`, `b7f1482`, `40ce99b` : évolutions homologues.
- Anciens `quiz/web/test_bots.html` et `blindtest/web/test_bots.html` retrouvés dans Git, supprimés le13/11/2025 (`fdec578`, `b70bf67`). Pages navigateur historiques, pas deux outils serveur supplémentaires à restaurer pour la baseline ; la page Games actuelle couvre leur famille d’usage.
- Bingo ancien chemin `src/ws/bingo_loadtest.js` puis déplacement vers `ws/bingo_loadtest.js` (`27a6266`,20/01/2026). Dernier changement de ce fichier : `8f66a32`,11/02/2026. Ce sont deux chemins historiques du même outil.
- `profilesNames` introduit dans les handlers le06/02/2026 (Quiz `4eef617`, BT `33e76be`), références actuelles lignes640/671. Recherche globale dans les repos : aucune déclaration trouvée. Ce défaut n’est pas introduit par les patches performance locaux.


Repères de preuve dans les sources locales (numéros au jour de l’audit) :

- `quiz/web/server/actions/loadtest.js:41–70, 170–220, 507–638` et `blindtest/web/server/actions/loadtest.js:41–70, 165–214, 503–634` : admission HTTP, envoi registration, stop, SAFE_MAX, rampe et attach.
- `quiz/web/server/actions/wsHandler.js:610–665` / `blindtest/web/server/actions/wsHandler.js:641–696` : dispatch numérique/profils ; `profilesNames` aux lignes 640/671.
- `bingo.game/ws/bingo_loadtest.js:118–175, 527–600, 1017–1150` : endpoint, file Canvas, timeout/hydratation, vagues, stop et attach.
- `bingo.game/ws/bingo_server.js:630–705, 836–1010` : entrée profils/ACK, vraie auth et position du bind dans le pipeline.
- `games/web/test_bots.php:307–490, 2209–2255` et `games/web/includes/bots/hub_bots.js:10–12` : délégation des gros lots et plafond Hub distinct.

## 3. Plafonds et comportement réel

### Quiz / Blind Test

`startLoadtest` borne `nbBots` à5000, crée un bot immédiatement puis programme les suivants toutes les2ms. À5 000, cela représente **9 998ms de délais programmés minimum**, hors event-loop/handshake/HTTP ; ce n’est pas un burst5 000. La fréquence n’est pas un paramètre du message. `configOverride` configure surtout réponses/précision/délai de réponse, pas la cadence de connexion.

Chaque bot ouvre une vraie WebSocket immédiatement et prépare son inscription HTTP en parallèle. L’envoi `registerPlayer` attend HTTP + WS open. Pas de limite de concurrence HTTP dédiée dans ce module ; le cache5min de `resolveSessionPrimaryId` ne mutualise pas les requêtes déjà en vol à froid. Le nombre5000 désigne des **tentatives créées**, pas5000 admissions ni5000 connexions confirmées : jauge, Hub actif, erreurs, FD/mémoire et capacité infra limitent le résultat. Une socket refusée peut rester ouverte ; le tableau bots garde des handles fermés. Aucun compteur fiable de bots effectivement admis n’est exporté.

Les sockets restent ouvertes jusqu’au stop, à la déconnexion serveur ou à `endGame` (close1000). Ping/pong protocolaire pris en charge par la bibliothèque ws. Pas de reconnexion automatique ni de durée de test. Identités déterministes par jeu/session/index : relancer le même lot n’est pas une vague froide neuve et ne reprend pas naturellement les identités d’un autre jeu du Hub.

**Défauts bloquant une qualification complète, conservés sans patch :**

1. Branche WS `profiles` : construction du log avec `profilesNames` non défini avant la boucle attach. Erreur capturée en `WS_MSG_PARSE_ERROR` ; aucun bot attaché par cette branche. Désactiver debug ne contourne pas l’évaluation de la variable.
2. `stopLoadtest` ferme les handles existants et supprime la Map, mais ne conserve/n’annule pas le timer `spawnNext`. Ce dernier ne vérifie aucun drapeau d’arrêt. Un stop en pleine rampe peut laisser créer des bots ensuite, devenus non suivis par la Map ; relancer n’assure pas un plafond global5000. Aucun contournement autorisé ici.
3. Le bot positionne `registered=true` après **envoi**, ignore `registrationSuccess` et demande immédiatement `getGameState`. Le serveur `registerPlayer` attend la capacité ; `getGameState` peut arriver avant bind et renvoyer `gameStateError` (« Joueur introuvable »), que le bot ignore. Pas de demande post-ACK comme le vrai Player.
4. `registrationError` est loggé avec le message, sans suivi complet du code, sans retry ni compteur de refus fiable. Le refus ne remet pas `registered` à faux.

### Bingo

Export froid : **aucun SAFE_MAX** ; `concurrency=10`, `waveDelay=400` par défaut. Ce sont des créations par vague, **pas une limite de bots actifs** : jusqu’à N sockets peuvent rester ouvertes.5000 correspond à500 vagues,199 600ms de délais programmés hors travail, avant même de garantir la fin des admissions. Les paramètres ne sont pas strictement bornés/validés ; des valeurs nulles/négatives/non finies peuvent empêcher le drainage ou provoquer un lancement excessif. Utiliser uniquement des entiers validés lors d’une future exécution.

File Canvas du générateur : `BINGO_CANVAS_CONCURRENCY`, défaut8, globale au processus ; `canvasQueue` + `inFlightCanvas`. Les deux étapes `player_register` puis `grid_assign` y passent. Les retries HTTP504 occupent le slot pendant l’attente (register :2 retries ; assign :3). **Pas de timeout socket HTTP dans `httpPostForm`** : un appel bloqué peut immobiliser un slot. Ni longueur de file ni temps d’attente/drainage n’est exporté.

Entrée WS `startLoadtest` : exige des profils, boucle d’attach synchrone, pas de plafond5000 ni de cadence. Un message avec seulement `nbBots:5000` reçoit `INVALID_STARTLOADTEST`. L’ACK `bingoServerBot_ack.nbBots` compte les profils soumis, y compris des profils éventuellement refusés/skippés : ce n’est pas un ACK d’auth de chaque bot.

Avec profils prêts, ouverture WS + `auth_player` **sans Canvas préparatoire du générateur**. La queue8 ne limite donc pas ce chemin d’auth nominale. Elle peut réapparaître au gameplay/nettoyage, tandis que les requêtes propres au serveur continuent normalement. `playerId` numérique/grille/secret nécessaires ; conserver aussi le `player_id` canonique exact du Hub, sans fabriquer une nouvelle identité à partir du simple numéro.

Le timeout5s porte sur l’impossibilité d’**envoyer** l’auth ; il est annulé dès `authSent=true`, pas à réception d’un premier state. Le handler de close prend `(ev)` puis lit `ev.code`, alors que ws transmet un code numérique : le log générateur perd ce code. Le serveur dispose de ses propres logs close corrects. Pas de retry/reconnexion automatique ; pas de traitement explicite endGame dans le bot, fermeture éventuelle par le serveur ou stop.

Enfin, `scheduleHydrateAfterAuth` est commenté et retourne directement ; aucun `bingo_reset_generation` n’est mémorisé/transmis par ce générateur sur `verification`/`grid_cells_sync`/quit. Le gameplay après reset versionné ne représente donc pas fidèlement le Player actuel (guards stale possibles). **Qualifier d’abord l’auth en attente avec `answerRate:0`**, pas ses wins/clics.

## 4. Quel pipeline est réellement traversé ?

R = RÉELLE, S = SIMULÉE, C = CONTOURNÉE, NA = NON APPLICABLE. « Préparée » signifie étape déjà réalisée avant le lot, donc C dans la mesure du lot. Les lignes ci-dessous décrivent le code lorsque l’entrée atteint la factory ; la branche profils Quiz/BT est actuellement bloquée avant cela.

| Étape | Q/BT natif froid | Q/BT profils | Bingo froid export | Bingo profils WS | Hub bots200 |
|---|---|---|---|---|---|
| Création identité | S clé déterministe + R persistance | C préparée | S clé + R persistance | C préparée | R register_guest, identités distinctes conservées |
| Admission Hub | R via guard PHP **si session Hub**, pas watcher | C préparée, contrôle actif WS R | R via PHP si Hub | C préparée, contrôle WS R | R via entrée Hub |
| `hub_capacity_get` WS | R | R si entrée réparée | R | R | R quand factory numérique attachée |
| Navigation/DOM Player | C | C | C | C | S attachement factory ; pas navigation/DOM réels |
| Ouverture WS | R | R si entrée réparée | R | R | R |
| `registerPlayer` | R | R si entrée réparée | NA | NA | R Q/BT |
| `auth_player` / performAuthentication | NA | NA | R | R | R Bingo |
| Repository / PHP | R HTTP, pas repository Node joueur | R serveur normal | R, pas mock | R, pas mock | R |
| Reset/lifecycle Bingo | NA | NA | R | R | R Bingo |
| Bind | R si admis | R si entrée réparée/admis | R si admis | R si admis | R si admis |
| État initial | Serveur R, demande prématurée possible | Même réserve | R state, log debug seulement | R state, log debug seulement | R via factories, pas UI réelle |
| Publication joueurs | R envoyée, bot ignore classement | R si entrée réparée | R serveur | R serveur | R serveur |
| Gameplay | R messages avec décisions S/oracle | Même chose | R I/O, décisions S et génération non alignée | Même réserve | R messages des factories, décisions S |

Les scripts natifs ne font **pas** de `sessions.players.push` pour court-circuiter la registration : ce push reste dans le véritable handler. Ils ne créent pas de Master ni de session de charge. Dans Q/BT, un runtime organizer préalable est obligatoire ; dans Bingo, repository/restore peuvent travailler avant Master, mais une session/playlist cohérente, les prérequis capacité et un état de jeu contrôlé restent indispensables.

Admission froide Q/BT : `httpRegisterPlayer` → résolution ID primaire → `CanvasAPI.playerRegister` (event_id ajouté par wrapper) → glue PHP qui retrouve le token session et appelle `canvas_hub_player_admission` avant UPSERT. Donc il est incorrect de classer toute admission Hub native comme contournée. Ce qui est contourné est **le parcours Hub Play/ensure/navigation**. Sur un Hub déjà rempli par d’autres identités, ces bots session peuvent être refusés.

## 5. Scénarios disponibles sans modifier les outils

| Scénario | Quiz / BT | Bingo |
|---|---|---|
| Vague froide | Oui, commande numérique native ; vrai HTTP + WS, pas Hub E2E | Oui, export Node froid ; grille attribuée via API canonique, générateur limité par sa queue8 |
| Reconnexion WS seule de profils existants | Factory existante, **entrée WS bloquée** ; relancer le mode numérique refait HTTP et n’est pas une reconnexion pure | Oui via profils préexistants ; nouveau lancement/attach, pas de replay automatique |
| Burst | Pas avec mode numérique2ms ; branche profils théorique bloquée | Oui profils attachés en boucle, sous réserve FD/charge ; pas une promesse de simultanéité exacte |
| Ramp-up | Oui fixe2ms ; plus lente par lots numériques non sûre car start remplace/stoppe le lot précédent | Oui froid10/400ms ou paramètres ; profils par messages espacés possibles, mais pas de scheduler de profils natif |
| Attente | Oui si runtime déjà En attente/Pause ; `answerRate:0`, aucun auto-start du générateur | Oui session/playlist phase0 ou Pause contrôlée ; `answerRate:0` |
| Gameplay | Oui sur le vrai moteur si playlist disponible ; réponses simulées | Partiel/non fidèle après reset versionné ; génération et hydratation à compléter |

BT : les inscriptions normales déclenchent la publication throttlée1s, y compris en attente. Les bots ignorent le classement reçu, mais le serveur effectue réellement son calcul et l’envoi. Cela sollicite le code O(R²) avant patch / indexation après patch. Il manque une durée de publication et un scénario reproductible à roster fixe ; le nombre de publications seul ne mesure pas le gain.

## 6. Métriques présentes et absentes

| Mesure | Disponibilité actuelle |
|---|---|
| Bots demandés/créés | Logs start et handles ; aucune preuve d’admission |
| WS ouvertes/fermées | Événements générateur Q/BT et Bingo ; pas de compteur actif fiable exporté ; codes close Bingo générateur incorrects |
| Succès HTTP préparation | Logs Q/BT `LOADTEST_HTTP_REGISTER_OK`, Bingo inscription ; pas succès bind |
| Succès bind | Logs serveur `PLAYER_WS_BOUND` ; jalon partiel, voir ci-dessous |
| Refus/erreurs | Q/BT registrationError/message, erreurs HTTP/WS ; Bingo logs génériques/retries et serveur AUTH_FAIL ; pas tableau exhaustif de codes par tentative |
| Latence connexion | Pas calculée ; timestamps partiels à corréler si debug, sans identifiant de tentative robuste |
| Latence auth / jusqu’au bind / ACK | Pas mesurée ; `registered`/`authSent` signifient « envoyé » |
| Premier state | Q/BT pas de suivi post-ACK, Bingo texte debug sans durée ni bytes |
| p50/p95/p99, throughput | Aucun agrégateur natif ; débit apparent de logs possible mais non équivalent au débit d’auth complet |
| Event-loop, CPU, mémoire, bufferedAmount | Aucun collecteur dans ces outils ; PM2/OS seraient des mesures externes, à distinguer |
| Queues générateur/serveur | Structures internes présentes, pas profondeur/temps/drainage publiés |
| HTTP Canvas | Préparation/logs erreurs et retries ; pas décompte complet des reads source serveur |
| Repository | Pas compteur/durée par auth ; éventuel debug Knex n’est pas une métrique corrélée |
| Durée totale | Helpers navigateur gros volume : temps de préparation HTTP + envoi des batches, **pas fin des binds/queues** ; pas bilan terminal natif |

Les fonctions `startLoadtest` reviennent après programmation des créations ; await ne signifie pas N bots prêts. La fin de la boucle ou `nbBots` d’ACK n’est jamais une mesure de drainage.

## 7. Logs exploitables AVANT/APRÈS et manques

Les loggers écrivent des timestamps ISO (`ts`). Conservation locale : rotation10Mo,5 backups, âge15jours ; les vues `/logs?sid=...&limit=...&page=...` sont paginées, max5000 **entrées**, ce n’est pas une limite de sockets. Conserver les fichiers complets pour un comparatif, sans supposer le viewer exhaustif.

**Quiz/BT** :

- `LOADTEST_START`, `LOADTEST_WS_CONNECTED`, `LOADTEST_HTTP_REGISTER_OK`, `LOADTEST_REGISTER_PLAYER`, refus/close/error : jalons, pas durées. `logger_v1.normalizeLevel` rétrograde beaucoup d’événements info en **debug**, car absents de `INFO_ALLOWED_EVENTS`.
- `PLAYER_WS_BOUND` reste info. Pour un nouveau joueur il suit le push/attachement du player ; sur reconnexion il précède une partie du remplacement/attachement. Ce n’est pas un reçu client ni un point universel « auth terminée ».
- `WS_IN/WS_OUT` debug et compacts ; sorties updatePlayers/gameState/sessionUpdate throttlées. `WS_GAME_PLAYERS_UPDATE_SENT` est également soumis au niveau effectif. Pas de temps début/fin publication.
- `envUtils` calcule `latencyMs` mais ne l’émet que pour certaines erreurs d’écriture ; reads capacité réussis et cohortes B ne sont pas journalisés. Les timeouts/erreurs capacité ne donnent pas une trace source complète.

**Bingo** :

- `WS_CONNECT`, `WS_DISCONNECT`, `AUTH_OK` debug, `PLAYER_WS_BOUND` info, `AUTH_FAIL`, `AUTH_MAX_PLAYERS` disponibles selon niveau. `PLAYER_WS_BOUND` est écrit **avant** `players.addPlayer`, avant lecture DB de state et avant post-reset : ce n’est pas la fin du job.
- Route début/fin, queue enter/start/end/profondeur, reset pré/post par auth : absents. Pas de compteur de drainage.
- `CANVAS_WRITE_OK` debug / `CANVAS_WRITE_ERR` warn donnent action/event_id/duration pour lifecycle et autres writes ; les reads `reset_state`/`hub_capacity_get` ne passent pas par ces métriques. Le texte `state reçu` côté bot est debug, sans taille/latence.
- Des timings reset gameplay/phase verification existent, **pas** des timings du pipeline auth. `websocket_server.sendTo` sérialise/envoie sans métrique bytes/bufferedAmount.

`LOG_DEBUG` effectif doit être enregistré pour chaque mesure. Les configs PM2 locales peuvent imposer0 ; les fichiers actuels seuls ne disent pas quel niveau utilise le processus DEV. On ne propose pas un restart pour changer cela dans cette passe. Activer debug d’un seul côté du comparatif fausserait la charge : écritures de logs synchrones, coût et rotation significatifs.

## 8. Baseline DEV : commandes futures, pas exécutées

Ces commandes sont des contrôleurs des outils existants, pas un nouveau générateur. Les chemins `<racine_..._deployee>` et tokens/profils doivent être renseignés par l’opérateur ; leur valeur serveur n’est pas connue ici.5000 est un palier conditionnel, pas une recommandation de lancement immédiat.

Avant tout essai : relever SHA/contenu réellement déployé des loadtest/handlers/wrappers, marker et version du processus chargé, cible WS/Canvas, niveau de logs, jauge et identité de la fixture. Par exemple, depuis la racine déployée, `sha256sum web/server/actions/loadtest.js web/server/actions/wsHandler.js web/server/actions/envUtils.js web/server/restart_serveur.txt` pour Q/BT ; équivalents `ws/bingo_loadtest.js ws/bingo_server.js ws/bingo_reset.js ws/envUtils.js version.txt` pour Bingo. Lire les fichiers n’établit pas à lui seul que PM2 a chargé cette version. Aucun de ces relevés distants effectué ici.

### Quiz / Blind Test : mode numérique natif

Depuis `<racine_quiz_deployee>/ws` (dépendance ws installée), le processus moteur doit déjà tourner :

```sh
LT_SID='<token_session_de_test>' LT_N=50 LT_WS='ws://127.0.0.1:3032/' node -i -e '
const WebSocket = require("ws");
global.ltControl = new WebSocket(process.env.LT_WS, {origin:"https://games.dev.cotton-quiz.com"});
ltControl.on("error", console.error);
ltControl.on("message", raw => console.log(String(raw)));
ltControl.on("open", () => ltControl.send(JSON.stringify({
  type:"startLoadtest", sessionId:process.env.LT_SID,
  nbBots:Number(process.env.LT_N), wsUrl:process.env.LT_WS,
  configOverride:{answerRate:0}
})));
'
```

BT : même commande depuis `<racine_blindtest_deployee>/ws`, port **3031** au lieu de3032. Pour les paliers suivants, `LT_N=500`, puis `LT_N=5000`, **après arrêt vérifié du lot précédent et validation du palier**. Vérifier les ports effectifs s’ils divergent des défauts. Le message ne crée pas le Master ; il ne reçoit pas d’ACK de N admissions.

Arrêt dans le REPL encore ouvert :

```js
ltControl.send(JSON.stringify({type:"stopLoadtest", sessionId:process.env.LT_SID}));
```

**Limite importante : arrêt pendant la rampe non fiable** (timer non annulé). Ne pas lancer5000 sur un DEV partagé en supposant ce bouton suffisant comme coupe-circuit. Attendre la fin des créations n’est pas une solution à un incident de charge pendant la rampe ; un arrêt fiable du générateur doit être corrigé avant cette qualification. Aucun restart/kill proposé ou exécuté ici.

Préconditions : runtime primaire existant En attente ou Pause stable, session non expirée/suspendue, jauge≥N, Canvas DEV et service token déjà configurés dans le processus. Pour mesurer la capacité **Hub**, session Hub réelle avec places/identités actives appropriées ; hors Hub on ne qualifie pas le coût du roster Hub. En lancement Hub normal, l’auto-start peut précéder la vague : les outils natifs ne savent pas créer un sas ni imposer l’attente. Préparer une fixture par un parcours existant contrôlé, sans changement applicatif.

La reconnexion par message `profiles` n’a pas de commande fiable à recommander avec ce handler local : la corriger serait un patch distinct. Une relance numérique identique refait la préparation HTTP et le stop précédent, donc ne pas la labelliser « WS seule ».

### Bingo : profils/grilles prêts, voie recommandée pour isoler l’auth

Préparer un fichier privé local `profiles.json` de **N identités distinctes déjà admises et mappées dans la session**. Chaque objet doit contenir `player_id` canonique exact, `playerId` DB, `gridId`, `gridSecret`, éventuellement username/playerName/gridNumber. Ne pas imprimer/publier les secrets. Aucun exporteur de profils prêts réutilisable n’a été retrouvé dans le module natif ; l’existence de ce fichier est un prérequis, pas un livrable produit par l’audit.

Depuis `<racine_bingo_deployee>/ws` :

```sh
LT_SID='<token_session_de_test>' LT_N=50 LT_WS='ws://127.0.0.1:3030/' LT_PROFILES='/chemin/prive/profiles.json' node -i -e '
const fs = require("fs"), WebSocket = require("ws");
const profiles = JSON.parse(fs.readFileSync(process.env.LT_PROFILES,"utf8"));
const n = Number(process.env.LT_N);
if (!Number.isInteger(n) || n < 1 || profiles.length < n) throw Error("Profils insuffisants ou nombre invalide");
global.ltControl = new WebSocket(process.env.LT_WS, {origin:"https://games.dev.cotton-quiz.com"});
ltControl.on("error", console.error);
ltControl.on("message", raw => {
  const m = JSON.parse(String(raw));
  if (m.type === "ping") ltControl.send(JSON.stringify({type:"pong"}));
  else console.log(m.type, m.nbBots ?? m.code ?? "");
});
ltControl.on("open", () => ltControl.send(JSON.stringify({
  type:"startLoadtest", sessionId:process.env.LT_SID, wsUrl:process.env.LT_WS,
  profiles:profiles.slice(0,n), configOverride:{answerRate:0}
})));
'
```

Même arrêt WS que Q/BT. Paliers `LT_N=50/500/5000` et même fichier/version de profils cohérents pour chaque paire AVANT/APRÈS, après contrôle des effets du stop. Cette commande lance un attach groupé ; une rampe de profils exigerait d’espacer les messages de commande (fonction disponible, pas scheduler fourni). N ne garantit pas N states ; l’ACK ne les compte pas.

Préconditions : grilles attribuées/secret actuel/bonne playlist, jauge≥N, stock cohérent, Hub actif si comparaison des patches Hub, phase0 ou pause maîtrisée, aucune suspension/expiration. Master pas créé par la commande ; pour un scénario reproductible le garder ouvert et stable. La liste ne doit pas mélanger des profils d’autres sessions.

### Bingo : export froid, pour mesurer aussi le générateur et l’API

Depuis `<racine_bingo_deployee>/ws`, avec configuration et service token existants correctement chargés dans l’environnement de ce nouveau processus :

```sh
NODE_ENV=development CANVAS_ENDPOINT='https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' BINGO_CANVAS_CONCURRENCY=8 LT_SID='<token_session_de_test>' LT_N=50 LT_WS='ws://127.0.0.1:3030/' node -i -e '
global.ltGenerator = require("./bingo_loadtest");
ltGenerator.startLoadtest({sessionId:process.env.LT_SID, nbBots:Number(process.env.LT_N),
 wsUrl:process.env.LT_WS, configOverride:{concurrency:10,waveDelay:400,answerRate:0}}).catch(console.error);
'
```

Arrêt dans ce REPL : `ltGenerator.stopLoadtest({sessionId:process.env.LT_SID})` ou `ltGenerator.stopAll()`. Le WS stop d’un autre processus ne pilote pas cette Map. Le module ouvre son propre pool Knex développement (min2/max10), ne crée pas de session, appelle réellement player_register/grid_assign. Le générateur et le moteur sont des processus distincts ici, mais peuvent partager la machine et le fichier logger du module. Pas de promesse de drainage des HTTP déjà engagés au stop.

**Ciblage impératif à vérifier** : le générateur utilise `CANVAS_ENDPOINT`, et sa valeur par défaut peut être **PROD** si `CANVAS_ORIGIN` ne contient pas `.dev.` ; `NODE_ENV=development` seul ne suffit pas. Le moteur utilise de son côté `CANVAS_API_URL`. Les deux doivent viser DEV ; la configuration Knex développement du module doit correspondre. Aucun secret ni configuration n’est modifié ici.

## 9. Comparabilité AVANT/APRÈS

Rejouer les **mêmes commandes et versions d’outils**, même niveau de logs, même rythme, même population/roster, même jauge, même état froid/chaud des caches et mêmes conditions CPU/DB. Les patches performance locaux ne changent pas les fichiers générateurs ; ils changent leurs cibles serveur. Vérifier séparément la présence du correctif admission-ready du21/09 et des versions réellement chargées : ne pas comparer une ancienne course d’inscription avec une version réparée en l’attribuant au patch capacité.

| Patch | Ce que l’outil sollicite | Ce qui est observable actuellement / manque |
|---|---|---|
| Capacité Q/BT | Vraies admissions et `hubCapacity` | Succès/refus partiels ; **B/N non observable directement**, reads source/cohortes non comptés.2ms + attente HTTP peut limiter le regroupement ; ce résultat caractérise ce scénario, pas un burst arbitraire |
| BT indexation | Vraies publications normales | Nombre/total via logs selon niveau, pas duréeCPU ni percentile publication. Comparer attente à attente, pas top50 En cours à liste complète En attente |
| Bingo auth | Vrais repository/reset/lifecycle/capacité/state | Qualitativement atteint le code5→4 HTTP,2→1 auth complète et payload réduit ; outils ne mesurent pas ces comptes/bytes/drainage par tentative. `PLAYER_WS_BOUND` n’est pas queue_end |
| Bingo froid | Même serveur plus préparation Canvas8 | Débit générateur/API et auth imbriqués ; aucune attribution causale à la queue serveur sans jauges de ces deux files |

Le journal `game_events` n’est pas un compteur de tous les HTTP : capacité/reset_state sont des reads ; ne pas reconstituer5N/4N depuis les seules écritures lifecycle. Les access logs d’un endpoint Canvas partagé sans action corrélée ne suffisent pas non plus à mesurer B.

## 10. Matrice minimale recommandée

| Jeu / outil | Population future | Scénario | Statut avant tout patch outils |
|---|---:|---|---|
| Quiz natif numérique | 50 puis500 ;5000 conditionnel | Rampe fixe, attente, zéro réponse | Baseline partielle possible ; arrêt de rampe et métriques à compléter avant qualification5 000 |
| BT natif numérique | 50 puis500 ;5000 conditionnel | Même rampe/attente, publications normales | Sollicite le changement O(R²), ne mesure pas sa durée ; mêmes réserves |
| Q/BT natif profils | 50/500/5000 | Burst/reconnexion pure | **Bloqué localement par profilesNames**, pas une baseline pure disponible sans correction préalable |
| Bingo profils prêts | 50→500→5000 | Auth groupée, phase0, answerRate0 | Meilleur isolement de la queue serveur ; baseline partielle possible avec profils, compte de states et métriques manquants |
| Bingo natif froid | 50 puis500 ;5000 après contrôle | Rampe10/400ms, queue Canvas8 | Mesure séparée du générateur+API ; ne pas l’utiliser seule pour diagnostiquer la queue serveur |
| Hub bots | ≤200/context | register_guest → polling → ensure → factory WS | Parcours backend Hub réel, **pas navigation/DOM ni watcher individuel3,5s** ; utile comme recette fonctionnelle séparée |

Il n’est pas nécessaire de fusionner moteur et Hub. Des outils moteur corrigés/instrumentés pourront qualifier les patches WS à grande population ; une recette Hub à population moindre valide le raccordement. Mais elle ne certifiera pas la charge5 000 de l’ensure/watcher/navigation. Pour cette revendication E2E future, il faudra une mesure dédiée du parcours complet, avec clients/polling représentatifs.

## 11. Risques DEV, arrêt et nettoyage

Ordre50→500→5000, session/client de test isolés, budgets d’arrêt convenus avant essai. Arrêter la montée si erreurs/timeouts croissants, mauvais routage, saturation FD/CPU/mémoire/DB, effets sur d’autres utilisateurs, croissance de file sans drainage, ou nombre de binds inférieur aux tentatives sans explication. Aucun seuil arbitraire de latence n’est inventé ici. L’absence de coupe-circuit fiable Q/BT pendant la rampe doit être traitée avant un gros palier partagé.

Véritables effets : connexions serveur+clients sur la même machine dans les modes attach/natifs intégrés ; HTTP et écritures joueurs/journal/attributions ; génération de grilles possible via les guards canoniques ; scores/gameplay si réponses non désactivées ; logs synchrones et rotation. Un token de session et un wsUrl sont des cibles effectives, pas un sandbox DEV automatique. Aucun garde « DEV seulement » retrouvé sur les commandes de lancement ; une nouvelle socket de contrôle peut atteindre ces branches sans être un Master déjà authentifié (guards contexte existants conservés).

Nettoyage :

- Q/BT stop envoie quitGame + close1000 aux handles connus ; ne purge pas les lignes DB, ni le roster Hub. La rampe/les inscriptions en vol peuvent continuer après stop. Ne pas annoncer un nettoyage complet sur la seule suppression de `botsBySession`.
- Bingo stop marque le lot arrêté et ferme les sockets connues ; la boucle de nouvelles vagues vérifie stopped. Les HTTP en vol/queue ne sont pas annulés. `player_quit` sans génération peut être refusé après reset ; la socket ferme quand même. La désactivation systématique à stop est commentée ; grilles et propriétaires sont conservés. Réutilisation des profils à vérifier avant reconnexion.
- Hub bots distingue stop/detach, départ de session et `leave` Hub. Les identities/participations restent conservées selon le mode ; utiliser les actions métier prévues pour libérer les places.
- Pas de suppression SQL globale, pas de reset des grilles pour « nettoyer », pas de kill/restart automatique. Contrôler les données persistantes du lot et les sockets restantes via moyens autorisés avant le palier suivant. Les outils n’exportent pas un registre complet de tout ce qui doit être supprimé.

## 12. Compléments minimaux identifiés, non implémentés

1. Corriger `profilesNames` Q/BT et l’annulation/drainage de spawn ; confirmer ACK d’admission et demander getGameState après registrationSuccess. Cela constitue des correctifs outils, pas seulement de la télémétrie.
2. Ajouter un run_id/attempt_id et des compteurs demandés/créés/open/ACK/refus/fermés/pending ; durées connect→auth/state, codes réels, bytes et résumé de fin fiable. Bingo : corriger close(code,reason), timeout d’auth réelle et conservation de génération si gameplay/reconnexion testés.
3. Instrumenter sans changer l’algorithme cible : capacité demande/cohorte/source/durée/taille ; BT début/fin publication/taille R ; Bingo route/queue enter-start-end/profondeur, reset pré/post, auth repository, lifecycle, capacité, bind effectif/state. Séparer explicitement queue du générateur et queue moteur.
4. Échantillonner CPU/mémoire/event-loop/bufferedAmount et fixer le niveau de logs identique pour A/B ; éviter que les logs deviennent le principal coût.
5. Préparer/exporter des profils privés réutilisables et une recette d’arrêt/cleanup. Pas besoin de réécrire un système complet ni d’augmenter automatiquement la limite Hub200.

Si l’on instrumente le serveur avant de prendre la baseline, celle-ci ne sera plus « strictement aucun déploiement préalable ». Conserver d’abord une capture partielle non instrumentée, puis un A/B instrumenté équitable sur l’ancien et le nouveau code, ou utiliser une collecte externe explicitement autorisée. Ne pas présenter la baseline partielle actuelle comme la preuve chiffrée de tous les gains.

## 13. Travail réalisé dans cette passe

Lecture/recherche statique uniquement, historique Git et documentation publique/journal. **Aucun outil chargé/exécuté, aucun test synthétique ou réel, aucun patch applicatif, marker, restart, déploiement, DB ou requête de charge.** Les modifications applicatives visibles dans les repos sont celles des lots antérieurs, conservées.

Documentation : cette note dédiée, HANDOFF, TASKS existants des trois moteurs et Games enrichis ; sitemap/index régénérés, `git diff --check` documentaire. Aucun README/CHANGELOG fonctionnel ajouté : l’audit ne change aucun contrat exécuté. Retour arrière documentaire : retirer les ajouts de cette passe et régénérer les index, sans toucher aux patches performance locaux.
