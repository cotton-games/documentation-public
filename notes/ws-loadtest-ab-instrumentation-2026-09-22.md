# Harnais WS et instrumentation A/B — 22/09/2026

<!-- AUTO-UPDATE:BEGIN id="ws-loadtest-ab-20260922" owner="codex" -->

**Orientation suivante, audit uniquement :** [Hub Load Test unique](hub-loadtest-unified-design-2026-09-22.md). Le harnais natif décrit ici reste un diagnostic moteur ; la qualification produit cible un scénario Hub commun Browser/Server. Préserver les bundles comme références, prendre une nouvelle baseline Hub avant performance/sas ; aucun outil unifié implémenté à ce stade.

**HARNAIS PRÊT POUR BASELINE A/B 50/500/5000**

**INSTRUMENTATION SÉPARABLE DES PATCHES MÉTIER**

Prêt désigne le harnais vérifié hors réseau, **pas une capacité réelle de 5 000 joueurs démontrée**. Monter 50 → 500 → 5 000 après contrôle de chaque palier. Aucun déploiement, restart, accès DEV/PROD/DB ou charge réelle effectué. Les modifications moteurs sont dans les worktrees `sas_players` ; elles ne sont pas livrées. Games reste sur `hub_soiree`, avec uniquement outils d’export et tests locaux modifiés dans cette passe.

## Incident Quiz DEV après copie des fichiers non commités

Complément opérateur du22/09 : seuls les fichiers Quiz non commités du worktree ont été copiés sur DEV, avec l’intention de conserver le métier AVANT. **Une liste de fichiers non commités n’isole pas leurs hunks : `envUtils.js` sur `sas_players` contient aussi les lignes performance déjà commitées.** La livraison AVANT doit provenir de l’overlay exporté, pas de ces fichiers complets.

Preuves locales rechargées : `quiz/logs/error_log` contient32 refus de connexion vers3032 entre14:50:45 et14:53:09 (horodatage brut Nginx), puis des messages `no live upstreams`. Dernier événement du `quiz/web/server/server-logs.log` : `2026-09-22T10:00:08.700Z` ; aucune exception de démarrage Node dans cette capture. Games/Global ne montrent pas de PHP fatal dans la fenêtre14h examinée. Le journal applicatif n’établit donc pas directement l’exception fatale ; le stderr Node n’est pas fourni.

Cause reproduite exactement selon la combinaison déclarée : `envUtils.js` du worktree exige `./capacity_reads` dès son chargement. Ce module appartient au commit performance et n’est pas dans les fichiers non commités à copier. Résultat CommonJS local : `MODULE_NOT_FOUND`. La version AVANT instrumentée se charge, expose `CanvasAPI.hubCapacity` et n’exige pas ce module. Nouveau test : `games/web/tests/ws_loadtest_baseline_install_test.cjs`, avec vraie résolution des dépendances diagnostiques et aucun réseau/service. Cela étaye fortement la cause de l’incident ; aucun accès serveur ni rétablissement distant vérifié.

Correction préparée **sans retirer les patches de `sas_players` ni ajouter de fallback métier** : overlay Quiz AVANT dans `/tmp/quiz-ws-baseline-recovery-2026-09-22/`, six fichiers et `SHA256SUMS`. La différence requise si les cinq autres fichiers sont bien ceux déclarés est `web/server/actions/envUtils.js`. Le fichier `actions/loadtest_metrics.js` doit aussi être présent. Pour éviter un nouvel assemblage partiel, les six fichiers cohérents sont disponibles. Aucun `capacity_reads.js` inclus : l’ajouter activerait le regroupement performance et invaliderait la baseline.

Marker de récupération dans cet overlay : `restart 22-09-2026/04`, à livrer après les autres fichiers selon le mécanisme d’activation existant. Ce marker est propre à la récupération ; les anciens numéros réservés dans la procédure initiale ci-dessous sont désormais historiques pour Quiz DEV. Réserver un numéro supérieur à la dernière activation réelle pour une livraison suivante. Aucun marker du worktree APRÈS modifié dans cette passe, aucun restart/déploiement exécuté par Codex.

Après copie/activation opérateur, attendre `WS_SERVER_LISTENING`, une connexion `/ws/` acceptée et la disparition des refus3032. Si le chargement échoue encore, récupérer le stderr de démarrage du processus Node exact : le journal applicatif fourni ne contient pas ces exceptions. Rollback immédiat possible : restaurer les fichiers sauvegardés avant instrumentation et activer cette restauration ; aucun patch performance ni modification DB requis.

Test exécuté :

```sh
LOADTEST_AB_BEFORE=/tmp/ws-loadtest-ab-2026-09-22-ready/before node games/web/tests/ws_loadtest_baseline_install_test.cjs
```

Résultat : panne du mélange reproduite, chargement AVANT instrumenté réussi ; syntaxe et empreintes du pack de récupération vérifiées. L’annonce précédente aurait dû davantage insister sur la différence entre fichiers modifiés et patch d’instrumentation seul.

## Contrôle terrain Hub346 — 50 bots, 22/09/2026

Logs rechargés par l’opérateur, sans arrêt volontaire des bots. Le WS écoute de nouveau3032 à13:27:05.475Z (15:27:05 Paris), preuve `quiz/web/server/server-logs.log:17662`. La dernière session montre50 identités distinctes `PLAYER_WS_BOUND` entre13:31:16.277Z et13:31:34.955Z (lignes18480–19350),50 `WS_GAME_STATE_SENT_PLAYER` et50 réponses traitées. Games relie Hub346/session27950 dans sa fenêtre15:31 (ligne21821). Neuf refus `WS_REG_SESSION_NOT_FOUND` précèdent la création runtime à13:31:15.942Z ; les inscriptions suivantes réussissent. La fenêtre entre première et dernière admission est18,678s, **pas une latence individuelle ni un percentile**. Quiz Nginx : dernières erreurs15:27:06, au redémarrage ; aucun PHP fatal dans les logs Games/Global de la fenêtre15h examinée. Le journal WS finit13:31:41.095Z : aucune conclusion sur la suite.

**Instrumentation non validée par ce test Hub** : zéro événement `LOADTEST_*`, zéro commande `startLoadtest` dans la capture. `games/web/test_bots.php` branche Hub (`CottonHubBots.create`) attache les bots navigateur ; leur `registerPlayer` ne transporte pas les identifiants du run natif. `quiz/web/server/actions/loadtest_metrics.js:52` exige un run actif et une tentative connue, sinon exécute le métier sans mesures de run. L’absence de résumé est donc cohérente avec ce chemin ; arrêter les bots ne créera pas rétroactivement un résumé. Elle ne prouve pas un défaut de chargement du collecteur.

Seuil confirmé dans `games/web/test_bots.php:2244` : en mode session Quiz/BT, plus de200 bots déclenche le générateur serveur (Bingo même seuil ligne2209). Le mode Hub bifurque avant cette logique et reste plafonné à200 dans `hub_bots.js:12`. Tous les bots navigateur utilisent déjà le WS métier ; le seuil concerne le lieu de génération, pas l’utilisation du WS. Ne pas augmenter le volume Hub pour espérer activer le harnais. Le helper session historique envoie par lots50, incompatibles avec le verrou de run unique instrumenté : employer la commande explicite du protocole.

La réponse préalable demandant ces logs aurait dû préciser que les résumés concernent le générateur moteur et ne couvrent pas encore le mode Hub navigateur. Pour qualifier l’instrumentation existante : lancer explicitement le harnais natif selon la procédure ci-dessous, puis attendre `LOADTEST_RUN_START` et `LOADTEST_RUN_SUMMARY`. Pour mesurer ce parcours Hub exact : extension de corrélation/collecte à réaliser, sans patch performance. Sources déployées et absence de performance non attestées par ces seuls logs. Audit seul ; aucun code, marker, restart ou déploiement modifié.

## Sources et séparation des versions

**Complément DEV confirmé :** [envUtils DEV identique à AVANT et base figée](quiz-dev-envutils-baseline-2026-09-22.md). Autres fichiers du lot attestés identiques aux non commités locaux ; aucune nouvelle demande de snapshot Quiz. Le marker /04 du pack était préparé, la dernière attestation fixe /03 comme contenu du lot déployé.

Relus : [audit outils](ws-native-loadtools-audit-2026-09-22.md), [pipeline](hub-player-registration-pipeline-audit-2026-09-22.md), [capacité/publication](hub-capacity-publication-patch-2026-09-22.md), [auth Bingo](bingo-digital-auth-performance-2026-09-22.md). Navigation [START — Parcours/Discipline](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), [SITEMAP develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), [Manifest — routing/markers](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md). Journal AI Studio RAW récupéré et décodé avant modification : aucun fichier loadtest/handler/transport/queue/repository ciblé signalé comme modifié hors workspace. Aucun rechargement supplémentaire imposé par ce contrôle ; aucune parité serveur déduite du journal.

Références **figées**, indépendantes d’un déplacement ultérieur des branches :

| Moteur | Métier AVANT (`hub_soiree` local) | Métier APRÈS (`sas_players` initial) |
|---|---|---|
| Quiz | `69192a2f4e3a45557c6b6f88421969623828c68f` | `74b99c90a69d9c94de98e69b9abb79b5c1e7e3ea` |
| BT | `ef1c18067d6928cacea928a9e7eb65a600e9a0a5` | `1a76a66983c0527092d0c75fc5b475a5c09f4896` |
| Bingo | `9788e31db012dd01c2b67d354e6f9731693c5c29` | `06b96758580b05291f0701ec481cdf46dd07afed` |

L’exporteur local produit les fichiers et patchs AVANT instrumentés, APRÈS instrumentés, ainsi que le delta métier entre ces deux états. Il n’effectue aucun checkout, commit ou write dans `.git`. Les générateurs et `loadtest_metrics.js` sont identiques dans les deux livraisons. Les hooks AVANT restent autour de l’ancien lecteur direct, du classement quadratique et de l’ancienne double authentification Bingo. Aucun `capacity_reads.js`, routage optimisé ou state allégé n’est introduit dans AVANT.

Vérification effectuée sur copies temporaires : application `before.patch`, puis `performance.patch` ; résultat identique, SHA-256 par SHA-256, aux fichiers APRÈS et aux fichiers métier inchangés par l’instrumentation. Deux adaptations d’insertion sont explicites dans l’exporteur : lecteur direct AVANT sans cohorte ; absence de `resolvePlayerPlaylist` AVANT. Elles ne changent pas les mesures communes. Tout conflit nouveau hors ces adaptations arrête l’export.

## Fichiers et limites du patch

- Quiz et BT : `web/server/actions/loadtest.js`, nouveau `loadtest_metrics.js`, `wsHandler.js`, `envUtils.js`, `web/server/logger_v1.js`, marker. BT ajoute des hooks dans `actions/gameplay.js` et `messaging.js`, plus adaptation du test de parité classement.
- Bingo : `ws/bingo_loadtest.js`, nouveau `loadtest_metrics.js`, branche loadtest/corrélation/bind de `bingo_server.js`, hooks de `bingo_reset.js`, `envUtils.js`, `repository/db/db_player_repository.js`, `websocket_server.js`, marker et adaptation du test auth.
- Games : `tools/build_ws_loadtest_ab.py`, `tools/verify_ws_loadtest_ab.py`, tests `web/tests/ws_loadtest_{harness,instrumentation}_test.cjs`, adaptation du double de l’ancien test d’ordre admission.

Aucune règle d’admission, algorithme capacité/publication/auth/reset, allocation, SQL, sas, watcher ou orchestration Hub modifié. `capacity_reads.js` et les index capacité restent exactement ceux du commit performance initial. Les hooks sont inactifs en l’absence d’un run local corrélé. Pas de cache ni nouvel `await` métier : les promesses sont observées et rendues telles quelles par le collecteur. Les séquences de requêtes et la queue restent inchangées.

## Contrat des runs

WS `startLoadtest` accepte `sessionId`, `mode: "cold" | "profiles"`, `nbBots` pour cold, `profiles` (ou ancien `bot`) pour profiles, `wsUrl`, `configOverride`. Le serveur répond `loadtest_started` avec `run_id`, `requested`, `mode` ; **ce n’est pas un reçu de N admissions**. Une erreur de lancement donne `loadtest_error` avec un code contrôlé. Les anciens helpers navigateur qui envoient plusieurs batches indépendants sur la même session ne constituent plus une commande de run unique : utiliser le contrôleur ci-dessous et un seul tableau de profils.

Un seul run par session, tous modes confondus. `LOADTEST_SESSION_BUSY` tant que le précédent n’a pas été stoppé et drainé. Pas de remplacement implicite. Les exports `attachPreRegisteredBot` restent disponibles pour un run unitaire, pas pour ajouter silencieusement des bots à un lot en cours.

| Paramètre | Défaut | Bornes strictes |
|---|---:|---|
| Nombre demandé, ou longueur profiles | requis | entier 1–5 000, hors bornes refusé, pas de clamp silencieux |
| Q/BT `spawnIntervalMs` | 2 ms | entier 0–60 000 ; 0 reste soumis au scheduler Node |
| Bingo `concurrency` | cold 10 ; profiles 50 | entier 1–500, créations par vague, pas sockets actives |
| Bingo `waveDelay` | 400 ms | entier 1–60 000 |
| `authTimeoutMs` | 30 000 ms | entier 10–600 000 |
| `runTimeoutMs` | 120 000 ms | entier 100–1 800 000 |
| `drainTimeoutMs` | 10 000 ms | entier 10–120 000 |
| `settleMs` | 1 500 ms | entier 0–10 000, observe notamment la publication throttlée finale |
| `BINGO_CANVAS_CONCURRENCY` | 8 | entier 1–64, file préparatoire globale du processus |

Les chaînes numériques ne sont pas admises pour les paramètres JSON numériques. Le contrôleur convertit explicitement ses variables d’environnement. À 5 000, le mode froid Bingo dépasse déjà trois minutes de rampe par défaut : augmenter explicitement la borne globale pour le scénario, avec la même valeur AVANT/APRÈS.

Q/BT : un seul register envoyé après HTTP réussi et WS open ; `registrationSuccess` est le vrai ACK, puis seulement `getGameState`. `registrationError` termine l’attempt sans demander le state. Les profils invalides donnent un échec par `attempt_id` et n’empêchent pas les profils suivants. Référence `profilesNames` supprimée.

Bingo : premier `state` après envoi auth = succès complet **côté client**, distinct du post-reset/queue_end serveur. Close Node `(code, reason)` correctement reçu ; code conservé, raison libre non exportée. Le timeout d’auth couvre l’attente du résultat, sans retry WS automatique. Le sampler unique par run vérifie les deadlines toutes les secondes : précision jusqu’à environ une seconde plus retard event-loop. Les retries HTTP 504 historiques du préparateur froid restent inchangés et inclus dans les durées par action.

Le mode froid ouvre toujours WS et prépare HTTP en parallèle. `preparation_to_open_ms` est donc signé : négatif si WS était déjà ouvert lorsque la préparation a fini. Il ne faut pas lire ce champ comme une étape séquentielle. Les métriques de préparation des profils ne représentent pas leur admission HTTP antérieure.

## Résumé et mesures

Événements INFO : `LOADTEST_RUN_START`, `LOADTEST_RUN_STOP`, **un seul `LOADTEST_RUN_SUMMARY`**. `LOADTEST_FATAL` signale aussi une erreur fatale du générateur. Q/BT les autorisent explicitement sans `LOG_DEBUG=1`. Le JSON utile se trouve dans `meta` du journal structuré. Les anciens logs de détail du générateur sont remplacés par la collecte en mémoire ; pas de INFO par profil. Les logs métier existants ne sont pas supprimés.

Champs du résumé schema 1 :

- Corrélation : `run_id`, `game`, `session`, `mode`, identifiants techniques `attempt_id` ; aucun nom, player_id, gridSecret, contenu de profil ou réponse HTTP libre.
- Compteurs : `requested`, `scheduled` (taille du plan accepté), `created`, `ws_open`, `auth_sent`, `ack_success`, `auth_error`, `ws_error`, `closed`, `pending`, `completed` (nombre d’attempts terminés, succès ou erreur), `successes`, `uncreated`, `in_flight_io`. `stopped` et `terminal_complete` sont des booléens.
- Q/BT : `registration_success`, `registration_error`, `game_state_received`. Bingo : `first_state_received`, `auth_timeout`. Les timestamps monotones de chaque attempt distinguent spawn/open/prepared/auth/ACK/game_state_send/state ; aucune horloge interprocessus n’est soustraite.
- Refus : `error_codes`, `failed_attempts[{attempt_id,code,message}]`, `close_codes`. Le message libre est remplacé par une explication fixe pour éviter de réimprimer des secrets dans un refus ; le code technique valide est conservé. L’index final de l’attempt permet de retrouver le profil local sans l’exporter.
- `percentiles` : `{count,min,p50,p95,p99,max,mean}` par série, rang supérieur simple. Durées successful uniquement pour connect/préparation/auth/ACK→state/total ; les séries I/O, queue et publication décrivent toutes les opérations observées, y compris celles d’attempts qui échouent ensuite.
- `duration_ms` : première création → dernier attempt terminé ; `wall_ms` inclut initialisation et fenêtre de drainage/settle. `rates` = créations, ACK, succès complets par seconde sur la fenêtre `duration_ms`, **pas un débit instantané de spawn**.
- Stop/drain : `stopRequestedAt`, `drainCompletedAt`, `pending_at_stop`, `remainingAtTimeout`, `incomplete`. Les dates de drainage indiquent la fin de la mesure, pas une suppression de données métier.

Capacité : `capacity.requests`, `cohorts`, `source_fetches`, `source_successes/errors/timeouts`, `B_over_N`, `cohort_size` ; temps source et bytes réponse issus du buffer déjà lu. `cohorts` = nombre de fetches B ; taille de cohorte observée par identité de la réponse/erreur partagée, sans retenir un résultat pour un appel ultérieur. N et B comptent seulement le contexte diagnostique du run : isoler la session de joueurs/probes concurrents pour une mesure attribuable. Le protocole n’instrumente pas les lectures PHP effectuées en amont du lecteur WS.

BT : `publication`, `publication_ms`, roster moyen/max via `publication_roster`, nombre de destinataires Players via `publication_player_recipients`, lignes organisateur, compte attente/pause/live. L’algorithme réel est exécuté ; mesures mémoire puis agrégation. Le temps inclut le travail synchrone et les envois/logs déjà présents, pas leur livraison réseau distante.

Bingo : `queue_enter/start/end`, profondeur courante/max, distributions wait/service/total_job, date et durée `queue.drain_ms`. Le `first_state` peut précéder `queue_end` ; le résumé attend aussi les jobs serveur corrélés. `pre_reset`, `post_reset`, `server_http_reset_state`, `server_http_hub_lifecycle`, `capacity_source_fetches`, `repository_authenticate`, `repository_route`, `state_reads`, `bind` distinguent les I/O. Nominal AVANT attendu : 3 reset + 1 lifecycle + 1 capacité, 2 auth complètes ; APRÈS : 2 reset + 1 lifecycle + 1 capacité, 1 auth + 1 route. Les compteurs vérifient les appels réels, pas `game_events`. `state_reads_ms` mesure le repository d’état ; pas de timer fin autour du seul bind synchrone.

Bingo froid : séries **séparées** `generator_queue_wait_ms`, `generator_queue_depth`, `generator_player_register_ms`, `generator_grid_assign_ms`, `generator_preparation_ms`, puis auth/state et queue serveur. Lancer ce mode par la commande WS sur le moteur instrumenté permet la corrélation dans le même processus. Un export Node autonome a son propre registre ; il ne permet pas à lui seul d’agréger la télémétrie du moteur distant dans son résumé.

Bytes : premier state reçu et sorties auth côté bot ; publication BT et state Bingo mesurés sur la sérialisation déjà nécessaire. Pas de double stringify pour mesurer. Il s’agit de payloads applicatifs, pas d’octets TCP/TLS, ni d’un export exhaustif des buffers entrants. Les sorties BT sont ventilées par type (`out_updatePlayers_bytes`), avec compte/taille min/max/moyenne ; somme déductible count×mean.

Process : heap/RSS début/max/fin, CPU delta utilisateur/système en µs, lag p95/max ; échantillon une seconde par run. Serveur et générateur intégrés partagent le processus (`shared_process:true`) : ce coût n’est pas CPU serveur isolé. `buffered` sonde au plus 64 sockets par seconde, rotation, seuil 1 Mio ; le nombre au-dessus du seuil compte des **observations**, pas des sockets uniques. Pas de promesse de pic non échantillonné.

## Stop et nettoyage

`stopLoadtest(sessionId)` Q/BT et `stopLoadtest({sessionId})` Bingo annulent le timer, empêchent les créations futures, marquent les attempts interrompus, ferment les handles et attendent les événements close ainsi que les I/O observées pendant la fenêtre bornée. La commande WS utilise `sessionId` pour les trois moteurs. Quiz/BT traite stop avant le refus des mutations d’une fixture suspendue ; les commandes métier conservent leur garde. Les jobs HTTP déjà engagés ne sont pas annulés ; les jobs préparatoires Bingo encore en file sont refusés au départ après stop, y compris après un résumé incomplet.

Un run naturellement terminé conserve ses sockets pour observer la population en attente. **Stop explicite obligatoire ensuite.** Son résumé déjà émis est un instantané et ne sera pas réécrit lors du nettoyage tardif ; STOP reste distinct. Une borne globale atteinte ferme le générateur et produit `incomplete:true`. Tant que des I/O restent bloquées, le verrou de session est conservé ; il est libéré lorsque les callbacks finissent et les sockets sont fermées. Les tableaux de bots/attempts et les échantillons bruts sont alors libérés ; un callback tardif d’un ancien run ne peut pas supprimer un nouveau run. Aucun restart utilisé comme coupe-circuit.

Pas de suppression SQL, de désallocation de grille ou de purge de roster Hub. Bingo stop propage la génération connue sur quit ; la déactivation cachée après timeout pré-auth de l’ancien générateur est retirée. Vérifier les joueurs, sockets et places réellement restants par les moyens opérateur autorisés. Les effets persistants du mode cold exigent des fixtures distinctes ou une remise à l’état initial contrôlée pour A/B.

## Livraison future : instrumentation seule AVANT, puis métier APRÈS

Ces opérations sont une procédure opérateur **non exécutée sur serveur**. Les racines DEV absolues et le processus réellement chargé restent à identifier sur l’environnement opérateur ; ne pas les déduire des chemins locaux. Les scripts vérifient les sources, pas les processus en mémoire.

Préparer le bundle depuis Cotton, vers un répertoire vide :

```sh
python3 games/tools/build_ws_loadtest_ab.py /tmp/ws-loadtest-ab-2026-09-22-ready
```

Il contient `before/<repo>/`, `after/<repo>/`, `<repo>.before.patch`, `<repo>.after.patch`, `<repo>.performance.patch` et `manifest.json`. Conserver ce bundle immuable pour toute la paire A/B. **Ne pas copier les fichiers du worktree `sas_players` pour préparer AVANT.** Les fichiers de l’overlay AVANT et le patch `before` sont la livraison instrumentation seule.

Dans une copie de travail de la source DEV, après sauvegarde des fichiers listés dans le manifest :

```sh
# Exemple Quiz ; répéter avec blindtest puis bingo.game et leur racine vérifiée.
python3 games/tools/verify_ws_loadtest_ab.py /tmp/ws-loadtest-ab-2026-09-22-ready/manifest.json quiz "$DEV_QUIZ_SOURCE" base
cd "$DEV_QUIZ_SOURCE"
git apply --check /tmp/ws-loadtest-ab-2026-09-22-ready/quiz.before.patch
git apply /tmp/ws-loadtest-ab-2026-09-22-ready/quiz.before.patch
```

Le vérificateur est exécuté depuis Cotton, ou avec son chemin absolu ; ces chemins de bundle devront être adaptés lors d’un transfert opérateur. **Tout mismatch impose de recharger/analyser les sources concernées**, sans application forcée. Faire ensuite la vérification `before`, contrôler syntaxe, puis livrer uniquement les fichiers du manifest AVANT selon le mécanisme de livraison existant. Vérifier l’environnement effectif : WS/Canvas DEV, service token déjà installé, Knex DEV, logs, limites FD, jauge et version Node compatible avec les primitives Node déjà utilisées par ces moteurs.

Markers réservés AVANT : Quiz/BT `restart 22-09-2026/02`, Bingo `restart 22-09-2026/03`. L’activation du processus précis est nécessaire pour charger les hooks ; **aucun restart exécuté ici**. Un marker peut déclencher l’automatisation existante : ne le livrer qu’en fenêtre d’activation autorisée, après les autres fichiers. Avant chaque run, enregistrer les empreintes du bundle et la version effectivement chargée.

Après capture et sauvegarde de la baseline, appliquer dans la même copie de source, encore vérifiée `before` :

```sh
git apply --check /tmp/ws-loadtest-ab-2026-09-22-ready/quiz.performance.patch
git apply /tmp/ws-loadtest-ab-2026-09-22-ready/quiz.performance.patch
```

Répéter par moteur, vérifier `after`, livrer/activer séparément. Ce delta conserve exactement le même générateur/collecteur et ajoute uniquement le métier isolé initial, ses fichiers dépendants/tests et les markers APRÈS réservés : Quiz/BT `/03`, Bingo `/04`. Les markers présents dans les worktrees reflètent APRÈS. `<repo>.after.patch` sert uniquement à instrumenter une source déjà au commit métier APRÈS pristine ; **ne pas l’appliquer après `before.patch`**.

## Commandes de mesure identiques AVANT/APRÈS

Depuis le dossier `ws` déployé du moteur (module `ws` installé), moteur déjà actif, session numérique dédiée et non expirée/suspendue, runtime/Master stable En attente ou Pause, jauge ≥ N. Pour mesurer capacité Hub, utiliser un vrai Hub et des identités admissibles. `profiles.json` reste privé, hors dépôt/documentation ; objets Q/BT avec identité canonique et/ou playerId préparés, Bingo avec identité canonique, playerId, gridId et secret valides de cette session. Aucun profil réel fourni ici.

```sh
LT_SID='<session_dediee>' LT_N=50 LT_MODE=profiles LT_WS='ws://127.0.0.1:3032/' LT_PROFILES='/chemin/prive/profiles.json' node -i -e '
const fs = require("fs"), WS = require("ws");
const n = Number(process.env.LT_N), mode = process.env.LT_MODE;
if (!Number.isInteger(n) || n < 1 || n > 5000) throw Error("INVALID_COUNT");
const profiles = mode === "profiles" ? JSON.parse(fs.readFileSync(process.env.LT_PROFILES,"utf8")) : undefined;
if (profiles && profiles.length < n) throw Error("INSUFFICIENT_PROFILES");
global.lt = new WS(process.env.LT_WS,{origin:"https://games.dev.cotton-quiz.com"});
lt.on("error",()=>console.error("CONTROL_WS_ERROR"));
lt.on("message",raw=>{const m=JSON.parse(String(raw)); if(m.type==="ping")lt.send(JSON.stringify({type:"pong"}));else console.log(m.type,m.run_id||m.code||"");});
lt.on("open",()=>lt.send(JSON.stringify({type:"startLoadtest",sessionId:process.env.LT_SID,mode,nbBots:n,
 profiles:profiles?.slice(0,n),wsUrl:process.env.LT_WS,
 configOverride:{answerRate:0,spawnIntervalMs:2,concurrency:10,waveDelay:400,authTimeoutMs:600000,runTimeoutMs:900000,drainTimeoutMs:30000,settleMs:1500}})));
'
```

BT : port3031 ; Bingo : port3030. Valider les ports réels. Rejouer avec `LT_N=500` puis `LT_N=5000`, après stop/drain et contrôle du palier précédent. Cold : `LT_MODE=cold`, aucun fichier profils lu ; Q/BT HTTP réel, Bingo préparation Canvas réelle. Pour Bingo froid, vérifier **dans le processus moteur** `CANVAS_ENDPOINT` explicitement DEV : `NODE_ENV` seul ne garantit pas la cible du générateur. Son endpoint est distinct de `CANVAS_API_URL` utilisé par le moteur.

Arrêt dans le même REPL :

```js
lt.send(JSON.stringify({type:"stopLoadtest",sessionId:process.env.LT_SID}));
```

La réponse de commande stop n’est pas le bilan de drainage : collecter le résumé dans les logs du moteur. Lecture hors ligne des fichiers JSONL complets (après copie opérateur) :

```sh
jq -c 'select(.evt == "LOADTEST_RUN_SUMMARY") | .meta' ws-log-copie.jsonl
```

Même outil, même configuration, profils/stock/jauge/roster équivalents, même période de settle, mêmes niveaux de logs et ressources pour chaque paire. Ne pas comparer cold AVANT à profils APRÈS. Pour des profils déjà connectés, stop et vérifier leur état réel ; `profiles` n’affirme pas une « reconnexion pure ».

## Matrice et critères d’arrêt

| Moteur | Paliers | Scénario A/B prioritaire | Mesures |
|---|---|---|---|
| Quiz | 50 / 500 / 5 000 | profiles attente, rampe2ms ; cold séparé | ACK/state, B/N, source ms/bytes, erreurs, process |
| BT | 50 / 500 / 5 000 | profiles attente, même cadence/roster/publication | idem + publication ms, R, destinataires, bytes |
| Bingo | 50 / 500 / 5 000 | grilles prêtes, phase0, vagues contrôlées | queue wait/service/drain, I/O auth, state bytes |
| Bingo froid | 50, puis500/5 000 si préparation maîtrisée | file Canvas8, vagues10/400ms | générateur et moteur mesurés séparément |
| Hub | ≤200, recette distincte | parcours fonctionnel Hub | ne certifie pas navigation/watcher/ensure à5 000 |

Pour une arrivée plus groupée : Q/BT `spawnIntervalMs:0` ; Bingo `concurrency:500,waveDelay:1`. Le scheduler/CPU reste une limite générateur ; ce n’est pas une simultanéité exacte. Conserver impérativement ces valeurs dans les deux membres de la paire.

Ne pas monter si `incomplete`, `uncreated`, refus inattendus, IO/queue non drainée, baisse de succès ou hausse de latence inexpliquée, saturation CPU/FD/mémoire/DB/HTTP ou impact sur d’autres utilisateurs DEV. Aucun seuil arbitraire universel annoncé. Prévoir budgets d’arrêt et fixtures avec l’opérateur. `LOADTEST_RUN_SUMMARY` n’est pas une preuve de purge des données persistantes.

## Tests et rollback

Tests uniquement locaux, transport/DB remplacés par doubles. Vrais modules générateurs, véritables lecteurs Canvas sous transport simulé, vraies frontières publication/queue/repository. Les suites vérifient ACK avant demande state, profils invalides individuels, refus, timeout, arrêt de rampe, aucun spawn tardif, drainage HTTP, fermeture, exactitude du résumé, confidentialité et 5 000 attempts synthétiques. Mesures capacité vérifiées sur AVANT et APRÈS :50/50 puis1/50 pour une cohorte simultanée de50 ; résultats métier identiques. Ces nombres décrivent la fixture de test, pas DEV.

```sh
node --test games/web/tests/ws_loadtest_harness_test.cjs
LOADTEST_AB_BEFORE=/tmp/ws-loadtest-ab-2026-09-22-ready/before node --test games/web/tests/ws_loadtest_instrumentation_test.cjs
node games/web/tests/bot_admission_order_test.cjs
node blindtest/web/tests/ranking_publication_index_test.cjs
node --test bingo.game/ws/tests/bingo_auth_pipeline.test.js bingo.game/ws/tests/bingo_reset.test.js
```

Résultats locaux : 24 scénarios harnais ; 10 vérifications instrumentation AVANT/APRÈS ; 12 scénarios historiques d’ordre admission ; parité publication BT jusqu’à 5 000 ; 20 régressions auth/reset Bingo, puis 5 contrôles ciblés des hooks finaux et 3 contrôles sur l’auth AVANT instrumentée. Aucun échec résiduel. Node local `v18.20.4`.

Vérifications complémentaires : syntaxe JS/Python, apply-check des deux couches et identité SHA APRÈS, tests de parité hors diagnostic, sitemap/index et diff-check. Pas de nouvelle dépendance npm.

Rollback après AVANT seul : sur source vérifiée `before`, `git apply --check -R <repo>.before.patch`, puis application inverse et activation opérateur contrôlée. Après APRÈS : retirer d’abord `performance.patch` pour revenir à la baseline instrumentée, puis éventuellement `before.patch`. Une nouvelle valeur de marker est à préparer pour l’activation du rollback selon la discipline existante, plutôt que compter sur le retour à une ancienne valeur. Restaurer seulement les fichiers du lot ; ne pas écraser d’autres changements du serveur ni les branches performance locales. Aucun état DB n’est créé par l’instrumentation elle-même ; les données générées par un futur cold run ne sont pas annulées par ce rollback de code.

Limites assumées : gameplay Bingo historique non remis à niveau dans cette passe (utiliser `answerRate:0`), collecte CPU intégrée, tailles applicatives sans TLS, raisons libres de refus masquées, fixtures/profils à fournir, parité DEV et processus chargés à vérifier par l’opérateur. Aucun parcours Hub modifié.

<!-- AUTO-UPDATE:END id="ws-loadtest-ab-20260922" -->
