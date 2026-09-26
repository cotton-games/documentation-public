# Hub Browser Bingo numérique — livraison et baseline du 22/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-bingo-browser-baseline-20260922" owner="codex" -->

**HARNAIS HUB BROWSER BINGO PRÊT — BASELINE BINGO AVANT PRÉSERVÉE.** Qualification locale ; livraison, redémarrage et charges DEV restent à effectuer par l'opérateur. Aucun sas ajouté. [Contrat commun](../canon/interfaces/hub-bot-test-runner.md).

## État et base exacte

| Élément | Bingo DEV attesté opérateur | Local `sas_players` | Bundle AVANT |
| --- | --- | --- | --- |
| Métier | `hub_soiree` | performance déjà préparée | `hub_soiree` |
| Référence | `9788e31db012dd01c2b67d354e6f9731693c5c29` | `06b96758580b05291f0701ec481cdf46dd07afed` + non commités | référence DEV + instrumentation |
| Auth/reset/state | ancienne auth de routage, reset externe, state complet | optimisations locales | anciennes frontières conservées |
| Cohortes capacité | absentes | présentes | absentes |
| Instrumentation Hub Browser | absente | nouvelle, prête localement | identique APRÈS |
| Marker | branche attestée, pas de lecture distante dans ce lot | `restart 22-09-2026/06` préparé | `restart 22-09-2026/05` préparé |

Blind Test DEV est également attesté `hub_soiree`. Le journal AI Studio relu ne démontre aucune contradiction ciblée : **aucun snapshot préalable nécessaire**. Quiz DEV reste sur sa variante AVANT opérationnelle ; aucun fichier Quiz, aucun envUtils Quiz ni marker Quiz ne fait partie de cette livraison. Ne pas copier les fichiers Bingo locaux `sas_players` vers DEV pour la baseline.

## Architecture et fichiers

Même `HubTestRun`, UUID, sujets, scénario `hub_to_session_hydration`, backend Browser, machine et résumé. Extension générique `prepareSubject`, sélection moteur et détails de métriques injectés au scénario ; aucun scheduler Bingo. La préparation incomplète interdit maintenant l'armement, y compris si toutes les inscriptions Hub ont réussi.

**Games — six fichiers de livraison incrémentale :**

- `web/test_bots.php` : métadonnées de la session Bingo, champ de session numérique cible, chargement adaptateur et hash UI.
- `web/includes/bots/hub_test_core.js` : version3, détails moteur, alias `first_player_ready`, refus de préparation incomplète.
- `web/includes/bots/hub_test_browser.js` : préparation spécifique injectée, moteur/cible sélectionnés ; polling, retry, drain communs.
- `web/includes/bots/hub_test_bingo.js` : nouvel adaptateur et métriques Bingo.
- `web/includes/bots/hub_test_ui.js` : routage Quiz/Bingo, observateur, grilles/auth, garde de démarrage et annulation.
- `web/includes/canvas/php/bingo_adapter_glue.php` : écho diagnostic `hub_test_grid` à `grid_hydrate`, uniquement sur requête marquée ; valeurs déjà lues, aucune lecture supplémentaire.

**Bingo — modifications propres à ce lot :** `ws/bingo_server.js`, `ws/bingo_reset.js`, nouvel `ws/hub_test_observer.js`, `version.txt`. Le delta DEV AVANT inclut aussi les dépendances de l'instrumentation native préparée précédemment : `ws/bingo_loadtest.js`, `ws/loadtest_metrics.js`, `ws/envUtils.js`, `ws/websocket_server.js`, `ws/repository/db/db_player_repository.js`. Ces variantes AVANT sont exportées depuis la base pré-performance, jamais copiées depuis leur version locale optimisée.

**Outils/tests locaux, non destinés au serveur web :** Games `web/tests/hub_test_bingo_test.cjs`, `tools/hub_bingo_instrumentation.py`, `tools/build_hub_bingo_ab.py` ; Bingo `ws/tests/bingo_auth_pipeline.test.js`. Documentation : cette note, contrat, README/TASKS Games/Bingo, tâche Blind Test, runbook, HANDOFF, manifest et index.

## Préparation et readiness

Choisir dans Hub Load Test le Hub, le token d'une **session Bingo officielle numérique du même Hub**, `prepared`, gameplay `off`. Champ cible vide conserve Quiz. Papier, démo, autre Hub et gameplay legacy Bingo sont refusés. L'observateur moteur doit être disponible en `NODE_ENV=development` ou `HUB_TEST_ENABLED=1`, comme Quiz.

Avant armement : créer N identités Hub privées du run ; pour chacune, appeler les vrais `player_register`, `grid_assign` (support2) puis `grid_hydrate`. La propriété de grille, son secret renvoyé, le Player, la session/playlist/support/génération, dimensions, nombres et cellules sont vérifiés. Le flux métier attribue ou retrouve la grille déjà possédée ; le cache du run évite une deuxième attribution après préparation réussie. Pas de SQL du générateur, pas d'auth WS, pas de création artificielle de runtime. Les identités et secrets restent privés dans l'onglet.

Après vrai lancement Master : même `active_launched_session` et ensure/mapping/access, un poll actif par sujet, cadence 3,5 s après réponse. Relecture réelle `grid_hydrate`, puis WS `auth_player`, avec la vraie queue playlist, génération et auth. Une reprise conserve sujet/Player/grille et relit la grille ; elle ne fabrique pas de nouvel inscrit. Un changement de génération passe par le métier réel.

Ready exige **grille exploitable + state authentifié concordant + confirmation de fin du travail post-reset**. L'écho WS doit correspondre à la session, playlist, identité Hub, Player, grille, exécution Master, nonce de tentative et génération. Le premier state peut arriver avant la dernière lecture reset : il ne suffit donc pas. `hub_test_auth_complete` n'est envoyé qu'après cette lecture et les vérifications de génération. Un reset reçu invalide la tentative ; le retry commun réhydrate avant de réauthentifier. Bind seul, état arbitraire, nonce ancien, contexte invalide ou génération obsolète ne donnent pas ready.

`grid_ready` précède `auth_state_ready` ; celui-ci partage son timestamp client avec `player_ready`, donc `player_ready = max(grid_ready, auth_state_ready)`. Les compteurs sont les premiers succès uniques ; `ready_current` tient compte des déconnexions. En off, maintien des états et ping/pong uniquement, aucun clic, `grid_cells_sync`, vérification de ligne ou réponse générée. L'interface générique `gameplayAdapter` reste disponible pour un futur lot ; aucun legacy Bingo activé.

## Observateurs, résumé et limites

L'observateur couvre arrivée auth, routage, entrée/début/fin queue, bind, lecture/envoi state, pré/post-reset, reset observé, restauration Hub, gameplay accepté et premier `passed_song`. Les hooks enveloppent les opérations existantes : aucune nouvelle I/O de mesure, aucun reset supplémentaire. Les racines auth englobent route, queue, capacité, lifecycle, state et post-reset ; le drain ne les confond pas avec leurs sous-appels. Le canal est diagnostic, borné, avec calibration et TTL15min ; sans observateur actif, aucun écho/completion ajouté au Player ordinaire.

`runtime_created/accepting` désignent l'installation du contexte Hub dans le moteur, pas la création SQL d'une playlist. `runtime_ready` fait autorité à la fin de `restoreHubRuntime` ; un Player peut provoquer cette restauration. Ce n'est pas l'ACK/bootstrap organisateur Quiz. `gameplay_start` observe l'acceptation de playback réel. L'absence d'ACK organisateur Quiz ne bloque pas Bingo. Ensure PHP reste non instrumenté ; sa date n'est pas inventée.

Le résumé commun `HUB_LOADTEST_RUN_SUMMARY` schema1/version `hub-browser-3` conserve launch/focus/access/runtime/WS/bind/first_player_ready, nearest-rank50/90/95/99/all, prêts au gameplay, pending et tail, racines, validité et timeline. À 49/50, all-ready et tail complète restent null. Export dans le navigateur, pas dans les anciens logs native loadtest.

`engines.bingo` ajoute grille préparée/support2, générations de préparation et observées, `already_assigned`, auth jobs, queue wait/service/depth max, route/auth, lifecycle/state/capacité, pré/post-reset started/completed, génération stale, erreurs auth et retries. Les refus de contexte invalide sont dans les erreurs auth ; les discordances de génération WS/reset dans `generation_stale`. Chaque timing expose count/total_ms/max_ms. Les timings API register/assign/hydrate comprennent la préparation et la réhydratation au lancement ; ils ne sont pas tous dans la fenêtre KPI.

Le manifest et le résumé déclarent `grid_state=prepared`, génération réelle, support numérique, warm grids / WS non authentifié, `allocation_in_kpi=false`. **Cette baseline ne mesure pas la première allocation de grille.** La capacité est mesurée par requête ; le collecteur Hub n'attribue pas les counts source/cohorte, les hooks natifs existants restent conservés. CPU/heap/RSS concernent le processus Bingo entier, qui peut servir d'autres Players ; utiliser une session isolée. L'incertitude d'horloge reste la demi-RTT du contrat commun, pas une précision absolue.

Browser limité à200 et budget10min préparation incluse ; le backend Server5000 reste hors lot. Débordement des collecteurs, timeout ou drain non terminé rendent le run incomplet. Garder l'onglet ouvert pour exporter et nettoyer. Stop/cleanup sont exactement ceux de Games : arrêt polls/sockets sans arrêt de partie, retrait explicite uniquement des sujets du run après drain, relecture d'inactivité, aucune purge/reset/désallocation de grille. Le bilan cleanup ne modifie pas le résumé hydration.

## Tests locaux exécutés

Depuis Games :

```sh
node --test web/tests/hub_test_bingo_test.cjs web/tests/hub_test_runner_test.cjs web/tests/hub_test_gameplay_test.cjs web/tests/hub_test_cleanup_test.cjs web/tests/hub_bots_test.cjs web/tests/hub_bots_runtime_test.cjs web/tests/bot_admission_order_test.cjs
```

**66/66 passent**, dont20 nouveaux Bingo : parcours1/10/50, prepared incomplet, already-assigned/idempotence côté adaptateur, absence/retard de hydrate, grille inexploitable, playlist/support/secret/identité erronés, first state sans post-reset, reset avant/pendant/après ready, génération/nonce/exécution obsolètes, reconnexion, arrivée gameplay déjà commencé, stop auth/hydrate, timeout, convergence49/50, export sans secrets et off sans commandes de jeu. HTTP/WS simulés ; l'idempotence DB réelle reste celle du flux métier audité et doit être constatée en recette.

Depuis Bingo :

```sh
BINGO_HUB_TEST=1 node --test ws/tests/bingo_auth_pipeline.test.js ws/tests/bingo_reset.test.js ws/tests/hub_suspend.test.js
BINGO_AUTH_BASELINE=/tmp/hub-bingo-ab-2026-09-22-ready/before/bingo.game/ws/bingo_server.js node --test ws/tests/bingo_auth_pipeline.test.js
```

**27/27 APRÈS, 4/4 AVANT passent**. Le test utilise les handlers réels avec dépendances simulées, bloque le post-reset après le premier state et prouve que completion/drain attendent sa fin. À50, AVANT conserve100 authentifications,150 lectures reset et300 lectures SQL comptées par la fixture ; APRÈS50/100/250. Ces comptes sont des preuves de chemins, pas une mesure de débit DEV. Lints JS/PHP et `git diff --check` requis ; aucun test réel DEV ni charge5000 revendiqués.

## Livraison explicite et preuve A/B

Artifact local : `/tmp/hub-bingo-ab-2026-09-22-ready/`.

- `manifest.json` : SHA256 base/AVANT/APRÈS par fichier, références, markers et profil.
- `before/` et `after/` : Games13 fichiers identiques ; Bingo11 fichiers AVANT,12 APRÈS.
- `update-before/` : delta livrable6 Games +9 Bingo, marker compris.
- `*.dev-to-before.patch`, `*.before-to-dev.patch`, `*.performance.patch` : livraison, retour et performance séparés.
- `verification.txt` : applications réelles en répertoires temporaires et comparaison SHA de chaque fichier : base + instrumentation = AVANT ; rollback = base ; **AVANT + performance = APRÈS**. Sources actuelles égales à APRÈS.

Delta performance restreint aux huit chemins déjà optimisés : marker, bingo_server, bingo_reset, envUtils, db_player_repository, base/player_repository, hub_capacity, capacity_reads. Le patch performance Games est vide ; nouveau harnais et observateur identiques. AVANT n'importe pas capacity_reads, n'utilise pas resolvePlayerPlaylist à la place de l'auth de routage et ne demande pas le state Hub allégé. Son test conserve auth externe/reset externe/roster. Les scripts d'export vérifient les références gelées et refusent de réécrire un répertoire existant ; ils dépendent des précédents artifacts `/tmp`, à archiver avec cette livraison avant nettoyage des temporaires.

## Procédure opérateur DEV AVANT (à effectuer ultérieurement)

1. Conserver l'artifact complet et le manifest. Vérifier que le contexte DEV est toujours celui attesté, sans copier APRÈS. Aucun snapshot supplémentaire demandé pour cet état connu.
2. Dans FileZilla, utiliser comme **site local** `/tmp/hub-bingo-ab-2026-09-22-ready/update-before/`, indépendamment de la branche active. Copier les6 fichiers sous `games/` à leurs chemins Games. Le helper PHP et le nouvel adaptateur doivent être disponibles avant utilisation de l'UI.
3. Copier les8 fichiers JS sous `bingo.game/ws/` à leurs chemins Bingo, puis `bingo.game/version.txt` AVANT `/05` **en dernier**. Ce lot requiert ensuite l'activation/restart WS Bingo selon la procédure habituelle du projet ; aucun restart n'est effectué par ce travail. Ne rien copier vers Quiz ou Blind Test.
4. Vérifier observer disponible, recharger Hub Load Test et Hub Master dans le même profil/origine, vérifier hash/version du bundle. Ne pas lancer avant que tous les fichiers soient cohérents.

## Recettes Hub50 puis Hub200

1. Hub de recette isolé, session Bingo officielle **fraîche**, numérique et rattachée au même Hub. Entrer son token dans Hub Load Test ; N50, prepared, off, paramètres standard. Garder Master ouvert dans le même profil/origine.
2. Préparer : `registered_hub=50`, `engines.bingo.grid_prepared=50`, N figé, aucun Player WS ni runtime artificiellement lancé. L'UI atteint Prêt uniquement après toutes les grilles exploitables.
3. Lancer cette session avec le vrai Master ; auto-start conservé. Observer Hydratation, Grilles/Auth et partie démarrée avec X/N prêts ; zéro doublon d'identité, zéro génération incohérente silencieuse, aucun reset supplémentaire du harnais.
4. Attendre fin/drain, exporter JSON + manifest, conserver logs Bingo/Games utiles. Exiger `grid_ready=50`, `auth_state_ready=50`, ready50 et validité complète ; sinon conserver explicitement incomplete/null et diagnostiquer. Comparer génération, refus/retries, queue/post-reset, racines et contexte réel, pas seulement un state reçu.
5. Arrêter les bots si sockets conservées, puis Retirer les bots du Hub après drain. Vérifier requested_to_remove50, removed+already_absent50, failures0 et verified_inactive50. Une répétition est idempotente ; conserver export cleanup séparé. Les grilles restent soumises au comportement métier normal.
6. Sur le même Hub, créer une **nouvelle session officielle fraîche** pour N200. Répéter exactement prepared/off et les mêmes paramètres autant que possible ; exporter les différences de session/playlist/génération et les mêmes critères à200. Ne pas présenter une session officielle déjà jouée comme baseline équivalente. Aucun passage APRÈS avant qualification AVANT.

## Rollback et suite Blind Test

Le rollback `*.before-to-dev.patch` rétablit exactement la base attestée Bingo `hub_soiree` et le harnais Games v2 utilisé pour construire ce delta (helper Bingo sauvegardé avant ce lot). Préparer les fichiers de retour hors serveur et vérifier leurs SHA base ; rétablir les dépendances avant activation du marker de retour, retirer les nouveaux modules seulement quand ils ne sont plus référencés. Ne pas restaurer aveuglément tout un répertoire `sas_players`. La vérification locale a testé ce retour sur copies temporaires. Le rollback de code ne supprime ni identités ni grilles : cleanup métier du run avant fermeture de l'onglet, jamais DELETE/reset forcé.

Blind Test n'est pas implémenté. Lot suivant : adaptateur sur vrais register/restore/session/access, auth et state utilisable avec corrélation session/exécution/tentative, autorité génération/reset propre au jeu, hooks queue/lifecycle/capacité/post-travail si présents, gameplay/first-content, racines/drain, séparation avant/après depuis `hub_soiree` attesté. Réutiliser prepareSubject, gameplayAdapter, backend et cleanup communs ; ne pas inventer un ACK ou une grille Bingo pour ce moteur.

<!-- AUTO-UPDATE:END id="hub-bingo-browser-baseline-20260922" -->
