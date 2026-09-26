# Hub Browser — gameplay Quiz et stop/cleanup par run, 22/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-gameplay-cleanup-20260922" owner="codex" -->

**GAMEPLAY QUIZ RÉINTÉGRÉ AU HARNAIS HUB GÉNÉRIQUE. STOP + CLEANUP HUB PRÊTS POUR RECETTES RÉPÉTÉES. BASELINE QUIZ AVANT PRÉSERVÉE.** Patch local sur sas_players ; aucun déploiement, restart ou charge DEV. Aucun fichier serveur Quiz/BT/Bingo/Global, aucune règle métier ni marker modifié par ce lot.

## Retour terrain et audit préalable

Selon le retour opérateur, Quiz DEV utilise le premier bundle AVANT, sans cohortes. Run Hub346/session27951 : N=50, 50 inscrits/accès/tentatives WS/bound/ready, zéro failure ; gameplay avant tout ready, puis hydratation complète. Le fichier `hub-loadtest-run.json` n'a pas été retrouvé localement : ces valeurs sont le relevé utilisateur, pas une nouvelle analyse du JSON. Le défaut est confirmé par le code : l'adaptateur v1 ne contenait aucune action après ready et le backend arrêtait le run après convergence.

Journal AI Studio RAW et canon public relus avant modifications ; aucune mention ciblée de rechargement pour test_bots/hub_test/hub_bots. Les autres modifications préexistantes du workspace sont conservées.

| Moteur historique Browser Hub/session | Écoute / arrivée En cours | Choix / cadence | Émission réelle et dépendances |
|---|---|---|---|
| Quiz | `createBot` dans Games `web/test_bots.php` : ACK → getGameState, `gameState` et `sessionUpdate` ; initial state avec index/options suffit à planifier | answerRate par occasion de planifier ; précision via Oracle de playlist ; fallback aléatoire sous 100 %, retry oracle 150 ms à 100 % ; min/maxDelay, minStartDelay, pointsThreshold, responseSkew, timingBias early/normal/late et jitter | WS `checkAnswer` avec sessionId, player_id, playerId, selectedOption, selectedOptionKey ; answerResult ; arrêt sur endGame. Oracle lit `botSessionData.playlist.songs` obtenu par `test_bots.php?ajax=session_meta`, aucune socket oracle |
| Blind Test | Même fonction `createBot`, mêmes états et arrivée en cours | Même scheduler ; Oracle normalise titre/artiste et leurs combinaisons, au lieu de `answer/reponse` Quiz | Même checkAnswer ; dépend des globals gameSlug/BOT_SONGS/SERVER_URL et du bootstrap historique. Adaptateur nouveau non implémenté |
| Bingo | `createBingoBot` : state pour phase, passed_song pour num_passed_songs ; reset_game et phase_over ; un state initial seul ne restaure pas tout le cycle de clic d'un morceau déjà passé | answerRate ; choix case correcte/incorrecte selon accuracy et mapping playlist position→numero ; randBetween(minDelay,maxDelay), une case par morceau, exclusion cases cochées/verrouillées ; contrôle lignes selon phase | HTTP `grid_cells_sync`, puis WS `verification {completed_lines}` ; vraies inscription/grille/auth/hydratation nécessaires. Dépend des helpers de grille, BINGO_SONG_NUMBERS et API historique ; pas réutilisable comme checkAnswer Quiz |

Les bots session Browser et les anciens bots Hub utilisent ces mêmes fabriques. Les générateurs natifs serveur demeurent distincts et ne sont pas utilisés comme substitution. L'ancien code est conservé inchangé. Réutilisation dans le nouvel adaptateur : algorithme Quiz de planning, normalisation options/réponse et payload métier ; retrait des dépendances UI/globales par injection socket, playlist, horloge/aléatoire et configuration. Tests de parité exécutent directement l'ancien `createBot` extrait du PHP, sans en réécrire une imitation.

Audit stop/leave historique : `hub_bots.js` stocke les identités dans `cotton-hub-bots-v1:<Hub>`, les réutilise entre runs et génère une nouvelle identité pour un sujet déjà left ou un conflit de nom. `stop(false,false)` détache ; `stop(false,true)` appelle le stop volontaire moteur ; `stop(true)` appelle aussi `leave_player`. L'ancien bouton Stop pouvait donc envoyer quitGame/player_quit, contrairement au contrat du nouveau runner. Le nouveau stop utilise exclusivement detach. Aucun changement de ces comportements legacy.

## Contrat gameplay générique

`HubTestRun` reçoit `gameplayAdapter`, indépendant de `HubHydrationScenario`, avec `mode`, `config`, `create(context)`, `summary()` et `stop()`. Le contexte privé fournit session, identité, numeric playerId, send et isOpen ; le handle reçoit `message` et `stop`. Le backend transmet la stratégie au transport moteur, sans dupliquer population/polling. BT/Bingo pourront fournir leurs fabriques ; scripted n'est pas implémenté.

`off` est le défaut explicite. Zéro réponse et zéro chargement oracle ; le transport continue à synchroniser son état jusqu'à l'arrêt normal du run. La fin automatique après convergence hydration reste celle de v1. `legacy` active la stratégie seulement après émission du ready validé ; lui transmet ce même initial state, puis les vrais événements. Le chargement de playlist est mutualisé par session/run, lancé après le premier ready, via l'endpoint existant, sans modifier l'admission. Aucun contenu de playlist ni identité dans l'export.

Paramètres UI propres au runner, valeurs historiques medium : answerRate90, accuracy82, minDelay400 ms, maxDelay2500 ms, minStartDelay600 ms, skew0,35, jitter180 ms, pointsThreshold1. Configuration validée puis figée/exportée pour le run. Accuracy est une probabilité de consulter l'oracle, pas une garantie de taux de bonnes réponses : le fallback peut tomber juste ; à 100 %, l'oracle manquant attend/reteste comme l'ancien bot. Les timers d'oracle sont désormais suivis/annulés au stop et au changement d'item. answerRate0 interdit strictement l'envoi, même avec tirage aléatoire nul.

Reconnexion : même identité/slot ; nouvelle barrière ACK/state, aucune double première-readiness ; mémorisation privée des questions déjà envoyées dans ce run pour éviter un nouvel envoi de la même réponse. Une réponse programmée mais annulée avant émission reste possible sur reconnexion. Pause/changement de question/stop/endGame annulent les timers ; le serveur reste seul autoritaire pour score et acceptation.

En legacy, la convergence ne ferme plus les sockets. Fin lorsque tous les sujets prêts ont reçu endGame, Stop opérateur ou limite existante de 10 minutes préparation incluse (TIMEOUT/incomplete). Une session plus longue nécessite une future extension explicite de ce budget et de l'observateur, pas un timeout masqué. Arrêter le runner ferme les bots sans arrêter la partie réelle.

## Mesures séparées

Schema1, version `hub-browser-2`, `gameplay_mode`, `gameplay_config` et `gameplay_activity` séparés de convergence/gameplay_start. Compteurs : answer_opportunities (questions distinctes avec options/en cours), answers_sent (send réussi), answer_results, answers_correct, answer_errors (transport/chargement ou refus machine connu).

`answers_accepted=null` : Quiz ne distingue pas de manière fiable, sans parser un texte, une réponse fausse traitée d'un refus générique `isCorrect:false`. Ne pas confondre send, résultat et acceptation. `alreadyAnswered` est un refus machine identifiable ; un résultat négatif ambigu reste un answer_result. Aucun changement du protocole moteur pour ajouter une métrique.

Le ready est horodaté avant la création de la stratégie. Tests : mêmes convergence/tail/ready/bound/timeline pour une même trace off/legacy jusqu'au ready. Les calculs sont inchangés ; les durées réelles peuvent néanmoins varier parce que les premiers sujets prêts jouent pendant que les autres s'hydratent. Conserver off pour la baseline d'hydratation isolée ; ne pas comparer sans qualification off et legacy comme charge équivalente.

## Stop et cleanup opérateur

`Arrêter les bots` reste disponible après scellement (idempotent), ferme sockets et futurs polls/retries, annule gameplay, draine les opérations selon les fenêtres existantes. N'envoie ni quitGame, ni leave, ni arrêt du gameplay réel. Un run naturellement terminé a déjà exécuté ce même stop/drain.

`Retirer les bots du Hub` exige run sealed **et** backend réellement drainé. DRAIN_INCOMPLETE seul n'autorise pas le retrait ; si le drainage finit ensuite, sélectionner de nouveau le run ou cliquer Arrêter rafraîchit l'éligibilité. Les identités finales privées et l'objet du run restent en mémoire, avec un sélecteur de runs, pendant la vie de l'onglet. Garder l'onglet ouvert jusqu'aux cleanups voulus. Les résumés et bilans n'exportent jamais de player_token/Hub token.

Le nouveau backend crée des identités neuves par run : ne lit plus le stockage partagé historique par Hub ; écrit dans un espace localStorage préfixé par run_id ; tient l'ensemble des UUID qu'il a lui-même générés. Les réponses d'admission portant une autre identité ne permettent pas d'armer. Cleanup = uniquement les identités finales appartenant à cet ensemble, jamais un scan de roster/nom HubBot. Les identités abandonnées pour conflit de pseudo avant admission ne sont pas des sujets inscrits. Les recettes précédentes de v1 et les runs d'un onglet déjà fermé ne sont **pas importés automatiquement** : leur propriété ne serait pas démontrée par le seul stockage partagé. Le JSON sans secrets ne permet pas de reconstituer cette propriété.

Chaque sujet : `current_player` vérifie l'identité exacte ; null/left → already_absent ; active → `leave_player` puis nouvelle lecture, impérativement inactive. La route leave_player enveloppe actuellement l'appel métier sans propager tous ses échecs ; la relecture évite donc de déclarer un succès sur son seul ok. Un refus/timeout/mismatch compte failure et le suivant continue. Recliquer est idempotent et permet de reprendre les échecs, les sujets déjà sortis étant classés already_absent.

Bilan distinct `HUB_LOADTEST_CLEANUP_SUMMARY` exportable : requested_to_remove, removed, already_absent, failures, verified_inactive, run_id, sans secrets. Progression Retrait X/N et bilan final UI. Aucune mutation du résumé d'hydratation après cleanup. `verified_inactive=N` confirme ces sujets, pas un total Hub nul : les joueurs réels et les autres runs doivent rester actifs.

Le métier existant `app_games_hub_player_leave` fait un UPDATE status=left de la seule identité sous verrou d'admission. Aucun DELETE, compte supprimé, purge globale, reset session, désallocation Bingo ni mutation directe de mapping ajoutés par le runner. `current_player` peut toucher last_seen selon le métier normal.

## Fichiers et vérifications

Games, 7 fichiers déployables modifiés/nouveaux :

- `web/test_bots.php` : choix gameplay/configuration, Stop, sélection du run, cleanup et export séparé.
- `web/includes/bots/hub_test_core.js` : stratégie générique et résumé version2.
- `web/includes/bots/hub_test_browser.js` : transport de stratégie, fin legacy, identités par run et frontière de cleanup après drain.
- `web/includes/bots/hub_test_quiz.js` : initial state après ready, événements suivants, synchronisation off, cycle de stratégie.
- `web/includes/bots/hub_test_quiz_gameplay.js` : nouvelle stratégie Quiz legacy.
- `web/includes/bots/hub_test_cleanup.js` : nouvelle orchestration read/leave/read par identité.
- `web/includes/bots/hub_test_ui.js` : transports, configuration, historique privé, actions et exports.

Outillage : `tools/build_hub_test_quiz_ab.py`. Tests nouveaux : `web/tests/hub_test_gameplay_test.cjs`, `web/tests/hub_test_cleanup_test.cjs`. Aucun nouveau diff dans les autres fichiers applicatifs hérités du lot précédent.

```sh
node --test web/tests/hub_test_gameplay_test.cjs web/tests/hub_test_cleanup_test.cjs web/tests/hub_test_runner_test.cjs web/tests/hub_bots_test.cjs web/tests/hub_bots_runtime_test.cjs web/tests/bot_admission_order_test.cjs
php -l web/test_bots.php
```

46 tests verts (15 gameplay, 5 cleanup, 23 runner, 3 suites legacy Hub/admission). Parité réelle ancien createBot : payloads/checkAnswer et horaires identiques pour précision0/100 et preset medium, initial state et question suivante. Off sans réponse/I/O oracle, avant question/en cours, délai, précision/answerRate, résultat ambigu/refus, reconnexion, pause/changement/stop, arrivée metadata tardive, fin sur tous les sujets et métriques hydration identiques. Stop50 : 50 sockets closes, aucun poll/leave ultérieur ; cleanup50 vérifié, double cleanup, absent, échec individuel malgré ok trompeur, réel/second run inchangés, résumé figé et garde avant drain. Lints JS/PHP, diff-check et preuves A/B validés. Aucun test navigateur/charge DEV effectué pour ce nouveau lot.

## Nouvelle livraison AVANT, sans restart

Bundle `/tmp/hub-test-quiz-gameplay-cleanup-ab-2026-09-22-ready/` ; exporteur depuis Games : `python3 tools/build_hub_test_quiz_ab.py /tmp/nouveau-dossier`. Base incrémentale figée = précédent bundle `/tmp/hub-test-quiz-ab-2026-09-22-ready/`, inchangé. Le manifest déclare version2/modes/default, refs et hashes ; configuration effective dans chaque export de run.

- `update-before/games/` : **uniquement les 7 fichiers à copier** sur Games DEV actuellement au premier lot.
- `update-after/games/` : exactement les mêmes 7 fichiers, mêmes SHA256.
- `before/` et `after/` : ensembles complets de référence, 11 Games, 11/12 Quiz ; ne pas recopier Quiz pour ce correctif Browser.
- patches dev-to-before/before-to-dev, performance et verification.txt ; SHA vérifiés : base + lot = AVANT ; rollback = base ; AVANT + performance = APRÈS.

Le patch incrémental Quiz est vide. Aucun dossier update-before/quiz ni update-after/quiz. envUtils AVANT conserve SHA256 `ca7fca8edc8c8fe67cbcd29aa62dac7d20c0f26f5dea51d393443fba9014c366`, aucun capacity_reads et ancien hubCapacity. Les markers de référence /05 AVANT et /06 APRÈS ne changent pas. Aucun restart nécessaire pour ce lot Games.

Procédure future : archiver les 5 fichiers Games remplacés ; sélectionner dans FileZilla le site local `/tmp/hub-test-quiz-gameplay-cleanup-ab-2026-09-22-ready/update-before/games/`, copier les 7 fichiers en respectant les chemins, recharger test_bots entièrement. **Ne pas copier envUtils local, Quiz ni marker.** Avant de fermer/recharger l'ancien onglet, conserver ses exports ; le nouveau registre de propriété ne pourra pas reconstruire automatiquement les anciens sujets v1.

## Recette répétée Hub50 → Hub200

1. Sur un Hub de recette, session Quiz fraîche, choisir 50. Off pour baseline isolée, ou Jouer automatiquement pour observer une partie ; paramètres explicitement exportés.
2. Start, attendre prepared50 puis lancer avec le vrai Master. En legacy, vérifier réponse à la question courante même si gameplay a déjà commencé, puis aux questions suivantes. La partie réelle continue indépendamment du runner.
3. Arrêter les bots ou attendre fin naturelle/timeout ; exporter le résumé. Vérifier drainage et fermeture des sockets. Cliquer Retirer les bots du Hub pour le run50 sélectionné ; attendre Retrait50/50 et verified_inactive50, zéro failure ; exporter le bilan.
4. Si échecs, conserver le bilan et réessayer le cleanup. Les succès antérieurs deviennent already_absent. Ne pas interpréter le total Hub incluant les joueurs réels comme un défaut de cleanup.
5. Préparer une **nouvelle session fraîche** du même Hub, population200 ; nouvelles identités propres à ce run. Ne pas présenter la reprise de la session officielle déjà jouée comme baseline équivalente. Le sélecteur permet aussi de nettoyer un ancien run drainé tant que l'onglet reste ouvert.

Rollback code : remettre les 5 anciens fichiers Games depuis le bundle v1/sauvegarde et retirer les deux nouveaux scripts devenus inutilisés, ou appliquer le patch ciblé before-to-dev. Ne pas toucher Quiz. Les retraits métier déjà demandés ne sont pas annulés par un rollback de code ; pas de réparation SQL automatique. Avant rollback/reload, arrêter, exporter et nettoyer les runs concernés si souhaité.

<!-- AUTO-UPDATE:END id="hub-gameplay-cleanup-20260922" -->
