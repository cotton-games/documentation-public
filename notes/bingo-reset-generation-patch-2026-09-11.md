# Reset historique Bingo — patch local du 11/09/2026

<!-- AUTO-UPDATE:BEGIN id="bingo-reset-generation-20260911" owner="codex" -->

Statut : **patch local, non déployé**. Aucun restart, aucune DB réelle consultée ou modifiée. Le journal AI Studio raw, START, SITEMAP/NDJSON, manifest et les contrats locaux ont été consultés avant patch ; aucune modification distante ciblée n’a nécessité de remplacement de fichier. Le futur bouton Hub `Recommencer` et l’isolation des tentatives officielles restent hors de ce patch.

## Contrat et stockage

`_bingo_reset_demo_state()` reste la primitive SQL. `resetdemo` la réutilise en phase 0 ; le reset WS historique de lancement `reset` la réutilise en phase 1 par défaut. Même session, même playlist client, mêmes lignes `bingo_players`, mêmes `id_joueur`, numéros, secrets et contenus de grilles. Aucun `removePlayer`, aucune désassignation, aucune redistribution dans ces resets. `clear_players` ne vide plus le roster du reset WS.

Les timestamps de cases, bonus, morceaux écoutés, position, winners, logs et lots attribués sont remis à zéro. Les joueurs gardent leur identité et leur statut d’activité ; `gain_phase=''`, `phase_wins_count=0`, `last_won_phase=NULL`, `last_won_at=NULL`. Les vérifications historiques de phase/position/morceaux sont conservées avant publication du résultat.

La génération autoritaire est persistée dans **`game_events`**, `game=bingo`, `action=bingo_reset_operation`, pour le token `session_id`. Le dernier événement par `id` donne la génération ; absence d’événement = 0. Aucune table ni migration nouvelle. Le `payload_json` porte `status`, `generation`, `request_id`, `action`, phase cible et résultat terminé ; l’`event_id` interne est un hash déterministe session/opération.

Le schéma historique comprend des tables **MyISAM**. Une transaction seule ne garantit donc pas le rollback de tout le reset. Le coordinateur écrit un marqueur durable `pending` **avant** la primitive ; il ne passe à `completed` qu’après succès et vérifications. En cas d’erreur partielle, les writes, attributions et hydratations runtime restent refusés. Le même `event_id` rejoué reprend la remise à zéro et publie une seule génération. `preload` et `reset_state` restent lisibles pour permettre la reprise ; le preload porte alors la dernière génération terminée, et `reset_state.reset_pending=true` interdit le gameplay WS. Seule l’authentification Master reste admise pour réessayer la même opération ; Players et Remote attendent sa clôture.

Conserver ces événements tant que la session existe : leur suppression ferait perdre l’autorité de génération. Aucune purge de `game_events` n’a été trouvée dans les sources Games/Global/Bingo examinées. En cas de perte du stockage navigateur pendant un reset partiel, une reprise opérateur doit réutiliser `payload_json.request_id` ; ne pas supprimer le marqueur pending pour débloquer arbitrairement le gameplay.

## Concurrence et clients

Un verrou MySQL nommé `bingo-playlist-<id>` sérialise les accès Canvas Bingo concernés : reset, inscription, attribution, lectures/hydratation et écritures. Le contexte playlist est relu sous verrou. Un propriétaire est recherché par playlist/support/joueur avant attribution ; `grid_assign` retourne sa même grille avec `already_assigned=true`. Les nouveaux joueurs peuvent toujours rejoindre et recevoir une grille libre selon les règles existantes. Le vieux corps `grid_get_or_assign` présent en commentaire reste désactivé.

`grid_cells_sync` porte `bingo_reset_generation`. Égalité exacte = write autorisé, même si un snapshot inchangé affecte zéro ligne. Ancienne génération = `BINGO_RESET_STALE` (HTTP 409), sans écriture. Champ absent/vide accepté uniquement en génération 0 ; après le premier reset il est refusé. La garde précède aussi le replay des writes de progression/winners. Les erreurs `BINGO_RESET_BUSY`, `BINGO_RESET_IN_PROGRESS`, `BINGO_RESET_FAILED` ne valent pas succès.

Le Master conserve l’opération en `sessionStorage`, partage une promesse entre doubles clics, réutilise l’ID après erreur et ne navigue après succès que lorsque le reset a répondu OK. Un reset obsolète concurrent recharge l’état courant sans rejouer une nouvelle opération. Le reset WS de lancement dispose d’une clé stable par playlist/génération si le message historique n’a pas d’`event_id`. Le Master mis à jour conserve aussi son opération de lancement en sessionStorage et attend le `reset_ack` corrélé avant le jingle et la lecture : les premières commandes ne partent pas avec la génération précédente. L’ACK d’un retry ne redéclenche pas un reset ; une authentification Master reste possible pendant pending pour la récupération.

Une file WS par partie sérialise authentifications et commandes. Les générations sont relues par `reset_state` ; les lectures indisponibles ou pending bloquent le runtime. Le contexte asynchrone conserve la génération d’origine des writes HTTP retardés et des trames sortantes. Les commandes périmées sont rejetées. Les intentions de départ volontaire datant d’avant le reset sont effacées ; une désactivation différée conserve la génération connue de sa socket. Avant `demo_reset_ack`, playback/position, caches de durée/hydratation, déduplis et gardes de fin sont nettoyés ; roster et configuration des lots sont conservés. Players, Master et Remote reçoivent la nouvelle génération et l’état neutre. Les surfaces actives rechargent après `demo_reset`/refus stale ; une notification répétée ne remet pas à zéro une progression déjà reprise.

Le preload et les réponses Canvas/WS exposent la génération. Le Player namespace coches, locks et médaille par `server-<g>`. Un changement purge les états précédents et l’état AppConfig, conserve identité/grille, puis hydrate l’état serveur. Un Player absent n’a pas besoin d’avoir reçu le WS de reset. Un document ancien ne reprend pas silencieusement la génération stockée par un autre onglet. Les snapshots différés et beacons conservent la version de leur état ; les anciennes réponses ne peuvent pas écraser la version actuelle. En génération 0, les anciennes clés scoppées sont migrées pour préserver la reprise historique avant tout reset.

La génération Bingo est indépendante des générations Hub. Le gel Hub existant reste prioritaire : ce patch ne permet pas de reset une session Hub suspendue à travers le futur CTA non implémenté.

## Fichiers applicatifs et tests

- Games, `web/` : `games_ajax.php`, `includes/canvas/php/{boot_lib.php,bingo_adapter_glue.php,bingo_reset.php}` ; `includes/canvas/core/{bingo_reset_generation.js,api/api_client.js,api_provider.js,boot_organizer.js,session_persist.js,session_sync.js,ws_connector.js}` ; `includes/canvas/play/{play-ui.js,play-ws.js}`.
- Games, `web/tests/` : nouveaux `bingo_reset_test.php`, `bingo_reset_generation_test.mjs` ; fixture `hub_suspend_test.mjs` adaptée au protocole explicite du connecteur.
- Bingo : `ws/{bingo_reset.js,bingo_server.js,envUtils.js}`, nouveau `ws/tests/bingo_reset.test.js`, marker `version.txt` préparé `restart 11-09-2026/03` sans restart exécuté.

## Validation sans services

Les tests PHP exécutent les vraies fonctions de reset/attribution/sync avec un double PDO en mémoire. Les scénarios concurrents utilisent des Fibers aux frontières du verrou ; cela vérifie les entrelacements applicatifs, pas le moteur MySQL réel. Les tests JS exécutent les helpers réels et les fonctions front extraites en VM avec stockage/transport simulés. Aucun test navigateur connecté aux services n’est revendiqué.

| Cas demandés | Vérification automatisée |
| --- | --- |
| 1, 2 | Reset de 1 puis 3 joueurs dans le double PDO |
| 3, 4, 5 | IDs, numéros, secrets, contenus et stock libre identiques |
| 6, 7 | Cases vides, bonus zéro |
| 8, 9 | Phase initiale, position zéro, postconditions conservées |
| 10 | Winners, logs/lots et morceaux remis à zéro |
| 11, 12, 13 | Compteur de victoires nul, dernière phase/date nulles |
| 14 | Maps/caches/gardes dérivés nettoyés, autre partie inchangée |
| 15 | Nouvelle génération diffusée aux Players, Remote, Master avant ACK |
| 16 | Retour absent : purge coches/locks/médaille et AppConfig |
| 17 | Rejoin/reload simulé : même grille retrouvée |
| 18, 19 | Ancien/missing sync refusé après reset ; version courante acceptée |
| 20 | Deux rejoins simultanés attendent le verrou et retrouvent la même grille |
| 21, 22 | Nouveau joueur pendant/après reset : grille libre, propriétaires inchangés |
| 23 | Même opération rejouée, double clic et erreur partielle : une génération |
| 24 | Master/Remote concurrents et ancien contexte asynchrone restent versionnés |
| 25 | Restart démo front, migration génération 0, postconditions historiques et suites existantes |

Commandes depuis Games :

```sh
php web/tests/bingo_reset_test.php
php web/tests/bingo_phase_winner_contract_test.php
php web/tests/hub_suspend_test.php
php web/tests/hub_demo_readiness_flow_test.php
php web/tests/hub_demo_runtime_surfaces_test.php
php web/tests/hub_launch_confirmation_contract_test.php
node --test web/tests/bingo_reset_generation_test.mjs web/tests/bingo_paper_correction_test.mjs web/tests/hub_demo_reentry_runtime_test.mjs web/tests/hub_suspend_test.mjs web/tests/hub_launch_confirmation_test.mjs
```

Depuis Bingo :

```sh
node --test ws/tests/bingo_reset.test.js ws/tests/bingo_phase_progress.test.js ws/tests/bingo_quit_guard.test.js ws/tests/bingo_terminal_delivery.test.js ws/tests/hub_suspend.test.js
```

Résultats finaux : **6 suites PHP vertes, 47/47 résultats TAP Games, 15/15 Bingo, 20 contrôles de syntaxe PHP/JS et `git diff --check` applicatif verts**. `DOCS_BRANCH=develop npm run docs:sitemap` exécuté avec succès. La fixture Hub a été adaptée pour définir le protocole du connecteur ; les postconditions historiques du reset ont été replacées dans la primitive canonique avant finalisation du journal.

## Réserves et recette restante

Recette DEV réelle à effectuer après une diffusion coordonnée Games/Bingo : noter les joueurs et grilles, avancer/cocher/gagner, interrompre un Player, reset historique, vérifier les mêmes identités/grilles et stock inchangé, état vidé, retour du Player absent, refus d’un ancien beacon, nouveau joueur accepté. Vérifier également latence/contention des verrous, échec partiel et retry avec le même ID, et déconnexion juste après réponse SQL avant notification WS.

La recette **Suspendre Bingo → noter joueurs/grilles → Recommencer → mêmes joueurs/grilles, zéro nouvelle attribution** reste obligatoire pour le futur parcours Hub ; son CTA n’est pas livré ici et le garde de suspension n’a pas été contourné. Les invariants de sa primitive historique sont couverts hors Hub par les tests ci-dessus.

Pas de preuve de charge ni de comportement d’un serveur MySQL réel dans cette session. Le contrôle WS ajoute des lectures HTTP d’autorité ; leur coût reste à mesurer. Les vieux clients sans génération doivent recharger après le premier reset. En cas de rollback ultérieur, restaurer ensemble les fichiers applicatifs Games/Bingo concernés, sans effacer les événements de génération ; revenir à des writers non gardés ferait perdre la protection contre les snapshots anciens. Ce patch ne crée pas d’archive indépendante des tentatives officielles.

## Incident DEV du 16/09/2026 — TDZ au restart historique

Verdict : régression front locale confirmée et reproduite avant correction. Le boot attend `maybeResetDemo`, qui appelle une fonction hoistée lisant `bingoResetInFlight` avant son initialisation. Cette invocation échoue avant toute requête de reset, création d’opération ou notification WS. Le correctif déplace uniquement l’initialisation au niveau module avant le boot ; aucun contrat, stockage, grille ou moteur WS modifié pour cet incident.

### Sources et timeline

Logs locaux rechargés lus sans checkout : Games branche `hub_soiree`, HEAD `389cbe26bb367d501aa85d9e5dab812360936617` ; ref locale main `1f6707da616f2049e1246d05dee9dc34e44f3b0e`. Les logs sont ignorés par Git : leur présence n’atteste pas un SHA déployé. Documentation locale sur develop. START, documentation canonique et journal AI Studio raw relus ; aucun changement distant ciblé trouvé.

Heures du 16 septembre en Europe/Paris (WS UTC + 2 h), partie 17065 / session 27807 :

| Heure | Surface / preuve | Événement | Résultat |
| --- | --- | --- | --- |
| 09:16:52 | `games/logs/access_log:2` | GET Master | HTTP 200 |
| 09:17:51.229–231 | `bingo.game/ws/server-logs.log:28033–28035` | `bingo:reset`, cible phase 1, `SESSION_RESET` | Reset de lancement réussi, antérieur au restart en échec |
| 09:18:04–12 | WS lignes 28052, 28056, 28064, 28089 | `mainPlayerStarted` inconnu | Warnings distincts du défaut TDZ |
| 09:18:19 | WS 28093–28097 ; Games `error_log:17` | Winner phase 1 persisté | Progression effective après le reset de lancement |
| 09:18:42–43 | WS 28099, 28105–28106 | Quit Player puis `deactivate_player` | Write antérieur réussi |
| 09:18:52–53 | Games `error_log:18–19` ; WS 28111–28116 | Rechargement Master, déconnexion, pause piste 12 | Attente reconnexion |
| 09:18:55.089–299 | WS 28117–28126 ; Games `error_log:20` | Connexion, `hub_lifecycle`, hydrate 1 joueur, `AUTH_OK`, reprise | Serveur atteint par le boot ; quit guard `reset:false`, phase 2 |
| 09:18:55 | Games `access_log:155–162` | Huit POST Canvas | HTTP 200, corps/action non journalisés |
| Jusqu’à 09:20:39.592 | Fin du log WS | Audits de rôles | Aucun nouveau reset identifiable après reconnexion |

Heure exacte du clic et stack navigateur DEV : **non trouvé**. La dernière séquence de reconnexion est compatible avec le signalement, mais ne date pas le clic. Aucun `resetdemo`, `demo_reset`, `bingo_reset_operation`, `reset_state` ni message JS exact trouvé dans ces logs. Les POST Canvas sans corps ne prouvent pas à eux seuls l’absence de reset. Aucune erreur PHP fatale concomitante trouvée. La preuve du blocage avant reset vient du code et du test rouge ; le reset réussi de 09:17:51 ne doit pas être attribué au clic ultérieur.

### Cause et comparaison

Références après micro-correctif dans `games/web/includes/canvas/core/boot_organizer.js` :

- Ligne 796 : unique déclaration `let bingoResetInFlight = null`, scope module, déplacée de l’ancienne ligne 2174. Elle était après la fin du bloc de boot (ancienne ligne 2076), donc pas une variable conditionnelle.
- Ligne 1308 : `await maybeResetDemo(...)` pendant l’évaluation du module ; ligne 1298, `session/init` peut déjà provoquer une authentification réseau.
- `maybeResetDemo` ligne 2275 : retry pending direct ou confirmation par `confirmResetDemo` ligne 2330, puis appel du wrapper.
- Ligne 2180 : première lecture dans `resetDemoAndReload`, point exact du ReferenceError avant correction. Ligne 2181 : première affectation de promesse et closure `.finally` qui remet à null ; ligne 2182 : retour de la promesse. Ce sont toutes les références runtime au symbole.
- `performDemoResetAndReload` ligne 2184 : création/persistance de l’opération puis `API.resetDemo` ligne 2210, inaccessibles lors du TDZ.

Pas de doublon/shadowing trouvé. Le helper `bingo_reset_generation.js` ne référence pas ce symbole et n’a aucun import ; pas de cycle nécessaire pour expliquer ce défaut. Les déclarations de fonctions sont hoistées, contrairement à l’initialisation du `let` : le `await` de boot empêche précisément d’atteindre l’initialisation située plus bas.

Dans HEAD prépatch (blob boot `943b0d64440d658928a996c3ac917cfd522ff884`), le même boot attend déjà `maybeResetDemo`, qui appelle directement la fonction async de reset. Le symbole est absent de HEAD et de main (blob `52b54ced7f4f775386c60a2b80a6e6adcc4fcd46`), ainsi que de l’historique recherché avec `git log --all -S`. Son introduction appartient au patch local non commité. Le nouveau wrapper de déduplication n’avance pas l’appel : il ajoute une dépendance à une initialisation trop tardive. L’absence de ce défaut dans l’ancien code est établie ; une recette navigateur historique réussie n’est pas disponible.

### Microdiff, tests et suites

Seul changement applicatif de cet incident : déplacer `let bingoResetInFlight = null;` avant l’anti-double-boot, en conservant son scope module, avec un commentaire. Rollback technique : inverser ce déplacement, ce qui réintroduirait le défaut ; aucune migration ou récupération de données associée.

`web/tests/bingo_reset_generation_test.mjs` couvre désormais deux chemins : boot avec confirmation Recommencer et boot avec retry pending. Les fonctions réelles et l’appel attendu du boot sont extraits en VM en conservant l’ordre source de la déclaration et de l’appel. Il s’agit d’un harnais de boot réduit, pas d’un navigateur complet. Avant déplacement : **2 échecs avec le ReferenceError exact**, stack `resetDemoAndReload` → `maybeResetDemo` → boot, zéro appel reset API et zéro notification WS. Après : les deux passent, une seule API, ID conservé au retry, une notification et une navigation. Le test isolé de double clic conserve son initialisation explicite ; il ne prouvait pas l’ordre de boot et masquait auparavant ce cas.

Exécuté après correction : commande Node Games ci-dessus **49/49**, commande Node Bingo **15/15** ; PHP `bingo_reset_test.php`, `bingo_phase_winner_contract_test.php`, `hub_demo_runtime_surfaces_test.php`, `hub_demo_readiness_flow_test.php` verts. Syntaxe : `node --input-type=module --check < web/includes/canvas/core/boot_organizer.js` et `node --check web/tests/bingo_reset_generation_test.mjs`. `git diff --check` Games/Bingo/documentation et régénération `DOCS_BRANCH=develop npm run docs:sitemap` vérifiés.

Cette invocation fautive ne touche ni DB/génération ni état WS de reset et ne crée pas de pending. Cela ne certifie pas l’absence d’un marqueur antérieur : le chemin de retry lit justement une opération déjà stockée. Aucun marqueur supprimé, aucune DB consultée, aucun service redémarré, aucun déploiement. Retester le restart historique en DEV après diffusion/rechargement ; recette complète de conservation des grilles toujours requise. Documentation limitée au présent rapport, TASKS Games, HANDOFF et index générés ; README fonctionnel inchangé pour ce micro-correctif.

<!-- AUTO-UPDATE:END id="bingo-reset-generation-20260911" -->
