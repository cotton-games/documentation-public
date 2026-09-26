# Audit — pipeline d'inscription numérique Hub et convergence — 22/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-registration-pipeline-audit-20260922" owner="codex" -->

**PIPELINE ACTUEL PRÉSENTE UN RISQUE DE CHARGE À TRAITER AVANT LE SAS.**
**PIPELINE ACTUEL COMPATIBLE MAIS SIGNAL DE CONVERGENCE NÉCESSITE UNE ÉVOLUTION WS.**

La séparation ouverture/Play reste faisable. En revanche, impossible de qualifier aujourd'hui le pipeline à 5 000 : roster complet par admission, sérialisation Bingo et coût quadratique de publication Blind Test sont prouvés. Un compteur WS peut coûter O(1) par tentative, mais n'observe pas les joueurs encore dans les étapes HTTP/navigateur. Ni durée finale, ni cache/batch, ni patch décidés.

Audit du code local, sans accès applicatif DEV/PROD, DB, SSH ou navigateur. Un probe utilise de vraies fonctions avec HTTP/repositories/sockets simulés ; ce n'est pas un benchmark. **Limite de source : le journal AI Studio cite `global/app/modules/ecommerce/app_ecommerce_functions.php` (25/03/2026). Recharger sa correspondance locale `global/web/app/modules/ecommerce/app_ecommerce_functions.php` avant d'analyser le résolveur d'offre. Son contenu local n'a pas été utilisé.** Les décomptes SQL ci-dessous excluent explicitement ses opérations internes. L'ancien audit n'avait pas besoin de cette dépendance ; cet audit de coût, oui.

## 1. Entrée commune : l'HTTP précède généralement `player/ready`

Hub Play : `active_launched_session` → `app_hub_player_resolve_session_access()` → `app_games_hub_session_participation_ensure()` → synchronisation capacité → verrou SQL **par Hub/session/joueur** `hub_participation_*` (5 s) → mapping → preload numérique → dispatch PHP `player_register` → upsert participation/mapping → libération verrou → URL Player. Il ne s'agit pas d'une injection collective ni nécessairement d'un HTTP interne : `game_api_dispatch()` est appelé dans le processus PHP. Preuves : Global `web/app/modules/jeux/hubs/app_games_hubs_functions.php:8915–9247`, notamment `8951,8990,9010,9100`.

Après navigation : `register.js:1241` auto-submit avec la clé Hub ; les handlers historiques font `player_register`/restauration, puis `player/ready` (`2859–2946` Quiz/BT ; `2632–2818` Bingo). `canvas_hub_player_admission()` est appelé avant upsert par les trois glues (`quiz_adapter_glue.php:1546`, `blindtest_adapter_glue.php:1569`, `bingo_adapter_glue.php:1551`) : **la lecture du roster/capacité n'est donc pas limitée au seul handshake WS**. Le nombre exact dépend des branches restauration, preload, replay et identité existante ; aucun total universel HTTP/SQL pré-WS annoncé.

Bingo numérique : `player_register` → `grid_assign` → hydratation de grille/secret valide → **ensuite** `player/ready`. `grid_assign` retrouve une grille existante ou fait transaction + `UPDATE ... id_joueur=0 ORDER BY id LIMIT 1` + relecture ; `grid_hydrate` contrôle identité/propriétaire puis lit les cellules. Le dispatcher Bingo entoure ces actions du verrou playlist de reset. Preuves : `bingo_adapter_glue.php:2142–2280,2285`, `php/bingo_reset.php:67`, `boot_lib.php:171`.

## 2. Quiz : chemin après `player/ready`

`play/play-ws.js:1624–1734` mémorise l'identité, ouvre WS/attend open, puis `authenticatePlayer()` (`968–1010`) envoie `registerPlayer(sessionId, player_id, playerId DB, playerName)`. Pas d'admission HTTP navigateur ajoutée entre cet événement et cet envoi sur le chemin nominal.

`quiz/web/server/actions/wsHandler.js:363,414–435` applique les guards, puis appelle le handler async **sans await ni file d'inscriptions**. `registration.js:450–683` :

1. Session et clé canonique validées ; refus immédiat sinon.
2. **await** `CanvasAPI.hubCapacity({game:'quiz',sessionId}, origin)` ; réponse appliquée, Set reconstruit ; `allowsPlayer`.
3. **Synchrone après cet await** : comptage actifs, `players.find` ; pour nouveau joueur, `hasRuntimeIdentity` puis second comptage éventuel ; création mémoire/avatar URL et `push`, ou réactivation/remplacement socket (timer de fermeture ancien socket 500 ms).
4. Bind identité/socket, `registrationSuccess` individuel score/rang courant ; `schedulePlayerListUpdate(sessionId,1000)`.
5. Client ACK → `getGameState` ; serveur refait `players.find(p.socket===socket)` (`gameplay.js:680`), répond état individuel. Ce scan s'ajoute à ceux du register.

Aucun INSERT joueur dans ce handler WS : la persistance est en amont. Un échec capacité renvoie `registrationError`, sans bind. Pas de retry dans `hubCapacity`; `play-ws.js:1464` affiche l'erreur, ne garantit pas une nouvelle tentative. Les reconnexions/reauth sont des tentatives supplémentaires.

## 3. Blind Test : même admission, publication plus coûteuse

Même ordre, HTTP et structures que Quiz : `blindtest/web/server/actions/registration.js:450–688`, `envUtils.js`, `hubCapacity.js`. Après ACK, `sendTeamStateToPlayer()` ajoute un message individuel (`teams.js:150–170`) ; feature locale équipes désactivée (`features.js`), payload borné `enabled:false`.

**Différence significative** : `gameplay.js:1109,1188,1257–1336` construit le classement puis, pour **chaque** joueur connecté, fait `sorted.find(...memberIds.includes(playerId))`, puis fallback `find`. Même en solo, `memberIds=[playerId]` : **O(R²) par publication**, en plus du tri O(R log R). Le top 50 limite le message organisateur en jeu, pas ce calcul complet. ACK puis `getGameState()` (`:588`) ajoutent aussi une recherche individuelle. Ne pas attribuer à BT le coût linéaire de la distribution des rangs Quiz.

## 4. Bingo : chemin réel complet, incluant les wrappers

`play-ws.js:1680–1726` ouvre WS avec `auth_player(id_grid, token grille, player_id, id_player)` ; pas de `registrationSuccess` natif. `bingo_server.js:560,700,836–855,855–1006` :

1. `performAuthentication()` attend `repository.authenticatePlayer()` ; 2 SELECT nominaux grille/profil (3 avec fallback legacy). Résout le token session via Map, sinon SELECT (`ensureSessionIdForGame:3294`).
2. HTTP `reset_state` pour résoudre playlist/génération.
3. `createBingoResetCoordinator()` (`ws/bingo_reset.js:47–98`) **met toute l'opération dans une file de promesses séquentielle par playlist**, partagée avec les commandes. À son tour : **deuxième HTTP `reset_state`** puis opération.
4. `performBingoAuthentication()` revalide la clé et **répète `authenticatePlayer()`**. `restoreHubRuntime()` → `hubLifecycle.restore()` → HTTP `hub_lifecycle(stage:read)` ; sérialisation lifecycle supplémentaire, pas de cache de résultat.
5. Scan des connexions pour remplacement ; **ensuite** HTTP `hub_capacity_get` → Set → admission/comptage/limite. Un ancien socket peut donc déjà être remplacé avant un refus capacité.
6. Contexte socket + `players.addPlayer()` : bind effectif ; marquage dirty en O(1).
7. **Deux SELECT parallèles** `getPlayerGameState()` : phase et nombre de morceaux passés. `buildStateFor()` → **snapshot intégral trié des joueurs**, envoyé immédiatement au nouveau Player dans `state` (`:3999–4074`). Ce travail n'attend pas le flush 1 s.
8. Après l'envoi du `state`, retour dans le coordinateur : **troisième HTTP `reset_state`**, puis fin du job/file.

Nominal, Master déjà prêt, hors suspension/erreur : **5 HTTP serveur par auth** = 3 reset + 1 lifecycle + 1 capacité ; **6 requêtes repository directes** = 2×2 auth + 2 état (8 si les deux auth prennent le fallback legacy). Cache `sessionIdByGame` peut éviter son SELECT ; il ne mutualise pas capacité/reset/lifecycle. Le log `PLAYER_WS_BOUND` précède `addPlayer` dans ce chemin : ce n'est pas un point de fin suffisant.

Échecs : capacité/repository dans l'inner ferment 1008 ; outer ferme 1013 ; reset pending ferme/refuse selon le coordinateur. `state` et bind peuvent déjà être effectués quand la dernière lecture reset échoue. Un compteur doit distinguer bind, envoi état et fin effective du travail.

**Probe local** : vraies méthodes `performAuthentication`, `performBingoAuthentication`, `restoreHubRuntime`, `getPlayersSnapshot`, `buildStateFor`, vrais coordinateurs reset/lifecycle ; I/O simulées. Pour 3 joueurs : 6 appels authenticate repository, 15 HTTP simulés (9 reset/3 lifecycle/3 capacité), listes initiales de tailles 1, 2, 3. Script temporaire `/tmp/hub-pipeline-audit/probe.cjs` ; aucune application modifiée.

## 5. `hub_capacity_get` : coût, sémantique et mutualisation

Transport Quiz/BT `web/server/actions/envUtils.js:17,185–285,322` ; Bingo `ws/envUtils.js:24,130–214`. POST form vers `CANVAS_API_URL`, sinon `/games_ajax.php?t=jeux&m=canvas` sur Games choisi par environnement/origin. Payload `{action:hub_capacity_get, game, sessionId}`, **aucune identité joueur**, header service. `games_ajax.php:246,378` vérifie le token ; dispatcher → `canvas_api_hub_capacity_get()` (`php/hub_capacity.php:4–82`).

| Étape serveur capacité Hub officielle | SQL/traitement nominal |
|---|---|
| Session | SELECT `championnats_sessions` par token |
| Membership | SELECT `games_hubs_sessions JOIN games_hubs` ; également `SELECT DATABASE()` et `SHOW TABLES` ; `schema_ensure` vérifie tables/colonnes une fois **par requête PHP**, pas une fois pour tous les joueurs |
| Offre/jauge | appel résolveur **non audité jusqu'au rechargement**, puis SELECT `referentiels_clients_erp_jauges` |
| Snapshot capacité | UPDATE conditionnel `GREATEST(...)` sur `championnats_sessions`, puis SELECT de confirmation ; UPDATE exécuté même si aucune valeur ne change |
| Stock Bingo seulement | GET_LOCK `hub_grid_capacity_<playlist>` (5 s), COUNT/MAX grilles par playlist/support, RELEASE_LOCK ; génération/recompte si manque |
| Roster | SELECT complet `games_hubs_players WHERE id_hub=? AND status='active'`, puis SELECT clés mappings avec JOIN pour la session |
| Réponse | capacité courante/snapshot, `active_count`, `active_keys`, `active_identities` ; déduplication des clés/identités côté PHP |

**Noyau SQL Quiz/BT : 7 instructions + 2 diagnostics membership**, plus schema/bootstrap/résolveur. Bingo : **+3 instructions** lock/count/unlock si stock suffisant. Ce ne sont ni les totaux de la requête HTTP entière, ni des mesures serveur. DDL/index déployés et coût du résolveur restent inconnus. La réponse quasi identique pour deux joueurs au même instant contient le roster Hub actif et ses alias session, pas seulement les connectés WS. Sa taille est O(H+M), H actifs Hub, M mappings actifs joints ; les alias peuvent augmenter le nombre de clés K.

**Oui, un HTTP capacité par tentative valide atteignant cette étape. Non, deux tentatives ne partagent ni promesse ni résultat.** Quiz/BT écrasent le Set de session à chaque réponse (`actions/hubCapacity.js:2–26`) ; Bingo crée un Set local (`ws/hub_capacity.js`). Les structures mémoire partagées ne sont pas un cache HTTP. Aucun cache applicatif/réponse ni retry de cette action trouvé ; rien ne permet de supposer un cache proxy. Le verrou stock sérialise, il ne mutualise pas les calculs.

Timeouts : Quiz/BT 3 s par défaut, configurable 250–60 000 ms ; timer annulé après réception de la réponse fetch, avant lecture complète du body. Bingo timeout socket HTTP 5 s, **pas deadline absolue de toute la file**. Pas de retry interne capacité ; erreurs fail-closed. PHP démarre une session ; les appels WS n'envoient pas de cookie commun : pas de preuve d'un verrou PHP partagé entre les 5 000.

Autres SQL Bingo : chaque `reset_state` traverse `bingo_reset_dispatch` → **2 SELECT metadata + GET_LOCK playlist + 2 SELECT journal reset + RELEASE_LOCK**, soit 6 instructions hors bootstrap. Trois appels = 18 ; avec 6 repository et noyau capacité 12, **36 instructions identifiées par auth nominale, avant coût lifecycle/résolveur/schema/bootstrap**. `hub_lifecycle(stage:read)` passe par `canvasWrite`, reçoit un event_id et le bridge l'inscrit dans `game_events` (`games_ajax.php:407–435`) : ce nom de lecture n'implique pas zéro écriture de journal. Allocation/hydratation pré-WS sont encore en sus.

## 6. Complexités et optimisations réellement actives

Notation : R joueurs en mémoire de la session, H actifs Hub, K clés capacité, C connexions conservées toutes parties Bingo. Coûts JS Map/Set moyens/amortis ; performances DB dépendent des index.

| Opération | Coût et fréquence |
|---|---|
| Set capacité, parse JSON, PHP roster | O(K)/O(H+M), **chaque tentative** |
| Quiz/BT `allowsPlayer`, bind/push | O(1) moyen/amorti |
| Quiz/BT count/filter/map/Set, `find`, `some` | O(R) ; nouveau : jusqu'à deux comptages + recherche + identité ; ACK→getGameState ajoute une recherche |
| Quiz publication | O(R log R) tri + O(R) parcours/messages ; throttle 1 s |
| BT publication solo | O(R log R) + **O(R²)** association rangs→Players ; throttle 1 s |
| Bingo recherche doublon et `getPlaylistPlayers` | O(C), même si les Map sont indexées par socket ; pas de Map identité→socket |
| Bingo compteur brut `playlistCounts`, ajout, dirty | O(1) ; compteur admission Hub utilise toutefois filtre/Set O(R) après scan O(C) |
| Bingo snapshot initial | O(C + R log R), O(R) données, **chaque auth** ; seed roster hydraté en sus |
| Bingo flush | même reconstruction/tri puis digest O(R), au plus flush 1 s dirty ; digest évite l'envoi, pas le calcul du snapshot |

Quiz/BT `schedulePlayerListUpdate` (`registration.js:402/408`) : première publication immédiate, au plus un timer différé par session ; pas de contournement spécifique Hub dans le register. ACK et état individuel restent unitaires. Les appels de maintenance/organizer/hydratation peuvent aussi publier ; la borne 1 s n'est pas un plafond global de tous les chemins. Bingo conserve dirty/flush et compteur seul dans `num_connected_players` vers Players, mais **son `state` initial contient la liste complète**. Ces exceptions corrigent une lecture trop générale de l'optimisation historique.

Pour un scan intégral répété à chaque arrivée d'une population croissante : 50 → 1 225 visites ; 500 → 124 750 ; 5 000 → 12 497 500. Pour le `find` BT solo avec tous connectés : **1 275 / 125 250 / 12 502 500 visites par publication**, indépendamment de l'ordre du classement unique. Ce sont des décomptes algorithmiques, pas des millisecondes. Le roster Hub H peut déjà être complet dès la première auth : N copies de H clés, donc O(NH), **O(N²) si H=N**. Les tris Bingo répétés ajoutent jusqu'à O(N² log N) dans le modèle de tri général.

## 7. Jobs en vol et signal possible

**Aucun compteur d'inscriptions complet déjà exposé.** Quiz/BT ont timers de liste, `lastSeenAt` individuel et logs, mais pas de compteur de leurs promesses capacité. Les queues `scoreWriteQueue` gèrent les scores, pas l'inscription. Bingo a la Map privée `queues` du reset et `hubLifecycleOperation` ; une promesse de queue ne donne pas sa longueur et ignore la pré-auth en cours. `inFlightCanvas` dans `bingo_loadtest.js` appartient aux bots, pas au serveur receveur. Aucune de ces primitives n'est une preuve de convergence.

Frontières instrumentables sans I/O supplémentaire :

- Quiz/BT : entrée `registerPlayer` avant await capacité ; sorties de validation/admission ; bind + ACK ; retour après programmation/publication. Encadrer par `try/finally`, succès/échec séparés. Compter les jobs, pas seulement les sockets, car des messages concurrents existent.
- Bingo : entrée `performAuthentication` **avant repository et mise en file**, fin après lecture reset finale ; jalons repository/capacité/bind/state facultatifs. Compter le temps en queue. Une fermeture socket ne doit pas décrémenter un job toujours en cours.
- Portée par session/exécution/génération, remise à zéro lors de disposition, pas lors d'une simple reconnexion. Attention Bingo : le token initial est celui de la grille ; le gameID n'est connu qu'après la première lecture. Le futur contrat doit traiter cette phase non encore attribuée (contexte vérifié ou suivi conservateur de pré-auth), sans fausse déclaration « zéro ».

Incrément/décrément + derniers horodatages + quelques compteurs de résultat : **O(1) par job**, sans liste/HTTP/DB ajouté. Diffusion agrégée bornée uniquement au Master primaire, dédiée ou adossée à un tick : pas un événement par joueur, pas un scan de roster. **Évolution WS nécessaire** pour ce contrat ; ni polling PHP ni nouvelles admissions requis. Une fin serveur n'est pas la réception de l'ACK par le navigateur. Des échecs massifs ne doivent pas être présentés comme une vague réussie.

## 8. Comparaison des libérations et watcher

| Option | Coût / fiabilité / 5 000 / changements |
|---|---|
| A — délai fixe | O(1) Games, aucun WS ; n'attend pas offline, mais peut précéder polls/HTTP/queues. Réduit une course sans prouver la convergence ; aucune durée arrêtée. |
| B — silence d'arrivée | O(1) mesure par tentative + publication agrégée ; nouveaux timestamps WS requis. Trompé par HTTP/repositories encore en vol, queue Bingo, joueurs pré-WS, reconnexions/tardifs. |
| C — zéro jobs + fenêtre calme + minimum + plafond absolu | Compteurs O(1), WS requis dans les trois moteurs. Meilleure mesure des travaux **observés** ; jamais preuve de toute la population. Inclure files, erreurs, pré-auth Bingo et horodatages arrivée/fin. Offline ne bloque pas ; arrivées continues déclenchent le plafond, avec sortie distincte « timeout ». |
| D — connectés / roster attendu | Roster persistant ≠ sockets ; offline, onglets remplacés, départs, bots, alias, hydratation. Bloque ou trompe ; polling/comptage ajoute du coût. **À exclure** comme condition de libération. |
| E — primitive existante | runtime-ready = Master ; listes/digest = publications ; queues = travaux partiels. Aucune primitive existante meilleure ne couvre la vague. Réutiliser un transport agrégé reste possible avec évolution WS. |

Watcher réel `app_hub_view_helpers.php:11783,12688–12797` : tick immédiat au démarrage, puis **3,5 s après fin de chaque réponse**, une requête en vol par Player, pas de jitter explicite. Les clients ont des phases différentes selon leur arrivée/latence, mais aucune garantie de désynchronisation : entrée collective/reprise réseau peut produire une vague. Réponse sans focus juste avant activation → presque 3,5 s avant la prochaine requête, **puis** durée serveur ensure + navigation + chargement + inscription/grille + WS. Une requête déjà en vol peut ajouter son temps restant ; pas de timeout absolu dans cet `api()` ; onglet ralenti/réseau lent : aucun maximum fini prouvé.

Un sas de 1/2/3 s peut finir avant le prochain poll d'un Player présent. 5 s dépasse un intervalle, mais pas nécessairement toute la chaîne, notamment Bingo séquentiel. L'origine runtime-ready peut survenir après le focus : le délai relatif varie. **Une convergence garantie très courte de tous les Players présents est impossible avec ce seul watcher** ; C doit garder une période minimale informée par les mesures et un plafond, pas attendre une population théorique.

## 9. Carte de charge 5 000

Sous hypothèse 5 000 tentatives nominales, hors retry/checkSession/pré-WS :

- Quiz/BT : ~5 000 POST capacité ; Bingo : ~5 000 capacité + 15 000 reset_state + 5 000 lifecycle, soit **25 000 HTTP serveur**, plus 30 000 SELECT repository directs nominaux. Les SQL des endpoints s'ajoutent.
- Capacité : 5 000 relectures/reconstructions du roster, synchronisations conditionnelles de la même session ; Bingo ajoute 5 000 prises de verrou stock et 15 000 prises de verrou reset. Contention API/DB possible même stock déjà rempli.
- **Illustration déterministe, pas trafic mesuré** : JSON compact avec N clés `p:<UUID>` uniques et identités 1..N : 4 352 octets à 50, 43 004 à 500, 434 006 à 5 000. N réponses identiques : 0,218 MB / 21,502 MB / **2,170 GB** non compressés à 5 000, hors enveloppe HTTP, alias, autres lectures et états Bingo.
- Quiz/BT : promesses HTTP concurrentes, timer timeout par appel, allocations temporaires Set/filter/map, GC ; un timer liste par session, timer 500 ms uniquement sur remplacement. Coût BT quadratique au flush.
- Bingo : pré-auth concurrente puis queue séquentielle sans deadline globale ; snapshots/réponses volumineux par auth, jobs et sockets retenus en mémoire. Au moins quatre échanges HTTP du chemin nominal (reset avant opération, lifecycle, capacité, reset après) et des accès DB restent dans chaque tour sérialisé. Aucun débit en joueurs/s déduit sans mesure.
- Herd du polling, preload/admission/grilles avant WS et métadonnées schema renforcent la charge. **`hubCapacity` est un candidat sérieux, pas un goulet principal mesuré** ; ne pas masquer les autres coûts avec un nouveau timer ou compteur.

## 10. Recette de charge à préparer, sans l'exécuter ici

Réutiliser `games/web/test_bots.php` et `includes/bots/hub_bots.js` : mêmes actions Hub et factories WS. **Limites de l'outil actuel** : 200 bots/context, admission puis polling séquentiels, intervalle 5 s après boucle ; ce n'est pas le watcher indépendant 3,5 s des vrais Players. Profils/navigateurs isolés pour identités distinctes : 50 = 1 contexte, 500 = 3, 5 000 = 25×200. Vérifier que les générateurs eux-mêmes ne saturent pas. Quiz/BT `actions/loadtest.js` a SAFE_MAX 5 000 et création toutes les 2 ms, mais c'est un parcours session, pas une mesure fidèle du watcher Hub. Bingo loadtest a sa propre queue Canvas : ne pas la confondre avec le serveur.

Plan sur environnement ultérieurement autorisé, avec jauge réellement suffisante et runtime en attente/phase 0 :

1. Pré-admettre les identités sans gameplay ; ouvrir le Master historique sans auto-start, avec focus officiel contrôlé par la fixture de test. L'outil ne fournit pas aujourd'hui un bouton garantissant ce scénario Hub exact : prévoir un harnais de test séparé, pas lancer le flux Hub auto-start en production.
2. Paliers 50/500/5 000, régime stable puis rafale ; séparer vague froide (ensure/grilles) et reconnexion WS sur participations/grilles prêtes.
3. Avec les factories existantes, futur harnais : distribution étalée sur 30 s, sur 3,5 s, puis simultanée ; cas défavorable poll juste avant focus. Les contextes 200 actuels donnent seulement une base séquentielle ; le harnais doit reproduire les polls indépendants avant de qualifier le parcours réel.
4. Mesurer t_focus/poll/ensure/navigation/ready/register/bind/state/fin-job ; distributions p50/p95/p99/max, refus par code, bytes HTTP/WS, appels SQL/actions, temps attente/verrous, profondeur queue Bingo, event-loop/CPU/heap/GC, bufferedAmount et charge du générateur. Jeux au repos : zéro reset/start/song/question pendant cette mesure.
5. Échec immédiat : gameplay prématuré, perte d'identité/grille/score, admission illégale, doublon, queue qui ne se vide pas, erreurs/timeouts nominalement absents. Latences acceptables : **budget à fixer avant test**, pas seuil inventé ici. Comparer croissance 50→500→5 000, répétitions et retour au repos ; scénarios erreurs, offline et tardifs distincts.

Validation locale effectuée : probe ci-dessus ; `node games/web/tests/hub_bots_runtime_test.cjs` PASS ; `node games/web/tests/bot_admission_order_test.cjs` PASS (12 scénarios). HTTP/DB simulés, aucune preuve de capacité 5 000.

## 11. Périmètres futurs et invariants

A : `games/web/includes/canvas/core/boot_organizer.js`, éventuellement contexte `organizer_canvas.php` et présentation de transition. B/C : mêmes fichiers + `quiz`/`blindtest` `web/server/actions/registration.js`/dispatch `wsHandler.js`, Bingo `ws/bingo_server.js` et `ws/bingo_reset.js` si instrumentation queue ; transport agrégé vers `core/ws_effects.js`. Aucun patch de ces fichiers réalisé. D déconseillée ; E ne dispense pas d'un contrat nouveau. Si évolution WS décidée, markers seulement avec modification réelle.

Surfaces de risque à approfondir avant optimisation, **sans proposer encore cache/batch** : capacité Games `php/hub_capacity.php`, Global `app_games_hub_capacity.php` et dépendance ecommerce à recharger ; BT `actions/gameplay.js` ; Bingo auth/reset/snapshots. Toute évolution doit conserver admission fail-closed, jauge vers le haut, suspension et génération/reset ; ne pas supprimer leurs gardes pour gagner du débit.

Sas seulement premier officiel numérique Hub, un seul départ Master/Remote, pas de Play concurrent ; existing et recréé déjà commencé → Pause/Play explicite ; démo/papier/direct hors Hub inchangés. Bingo auto-sync avant readiness, sas **avant reset phase 1**, idempotence préservée. Compteur de jobs jamais conditionné au roster total ; lifecycle/exécution remplacée invalide tout timer ou signal ancien.

## 12. Données manquantes, SQL READ-ONLY et documentation

Pas de donnée DB nécessaire pour constater les risques algorithmiques. Pour qualifier les coûts DB/index/moteurs réels, demander dans phpMyAdmin (aucune exécution ici) :

```sql
SELECT TABLE_NAME, ENGINE, TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('championnats_sessions','games_hubs','games_hubs_sessions',
    'games_hubs_players','games_hubs_players_sessions','referentiels_clients_erp_jauges',
    'game_events','jeux_bingo_musical_grids_clients',
    'jeux_bingo_musical_playlists_clients','jeux_bingo_musical_morceaux_to_playlists_clients',
    'bingo_players','cotton_quiz_players','blindtest_players');
SELECT TABLE_NAME, INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME, CARDINALITY
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('championnats_sessions','games_hubs_sessions','games_hubs_players',
    'games_hubs_players_sessions','game_events','jeux_bingo_musical_grids_clients',
    'jeux_bingo_musical_morceaux_to_playlists_clients','bingo_players',
    'cotton_quiz_players','blindtest_players')
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
```

TABLE_ROWS peut être estimé. Vérifier couverture token session ; Hub/status ; membership session ; mapping session/joueur ; grilles playlist/support/propriétaire ; morceaux playlist/timestamp ; journal game/action/session/id. Ce ne sont pas des recommandations d'index à créer sans EXPLAIN. Les clés exactes déployées, le coût ecommerce et les métriques réelles restent ouverts ; ne pas inventer un total SQL complet.

Sources agent-first relues : [START, Parcours](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), [SITEMAP](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), [Manifest, R23 et discipline](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md). [Audit précédent](hub-initial-session-sas-audit-2026-09-22.md), [bots Hub, Contrat technique](hub-bots-2026-09-21.md), [admission bots, Changements et validation](bot-admission-order-2026-09-21.md). Journal RAW demandé relu/décodé : entrée « Professionnalisation & Intégration des Emails Transactionnels », 25/03/2026, fichier ecommerce cité plus haut ; autres fichiers ciblés ici non signalés. Aucune parité serveur déduite.

Documentation seulement : note, complément de l'audit précédent, suivi TASKS et HANDOFF ; index/sitemaps générés, `git diff --check`. Pas de README fonctionnel identifié comme incorrect nécessitant réécriture, pas de CHANGELOG ni marker. Rollback documentaire limité à ces entrées et régénération ; préserver les travaux documentaires concurrents.

<!-- AUTO-UPDATE:END id="hub-registration-pipeline-audit-20260922" -->
