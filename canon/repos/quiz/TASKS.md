<!-- AUTO-UPDATE:BEGIN id="hub-suspend-20260910-quiz-tasks" owner="codex" -->

**25/09 — Robustesse d’exécution Hub, patch local non déployé.** Organizer seul publie le runtime ; consommateurs Bingo sans restore, candidats Quiz/BT provisoires et writers réservés au primaire. Retries bornés même E/joueur/event_id avec fence serveur ; probes concurrentes terminées/nettoyées. Pregame, reveal Remote, reprises et reset au départ conservés. Analyse main/develop/pregame : sous-lots isolables, adaptations Bingo/PHP/Player WS nécessaires, aucun main modifié. [Détail, tests, limites et backport](../../../notes/hub-execution-robustness-backport-2026-09-25.md). Recette réelle du nouveau patch et adaptation main restent à effectuer après autorisation.


**25/09 — Recette DEV du POC iframe analysée, sans nouveau patch.** Client1018/Hub354 : six E réussies, BT27986 ack/27987 started/27992 ack, Bingo27989 started/27990 ack, Quiz27991 ack. Primary/Organizer unique pertinent par E, même E publish→started→retour ; deux ouvertures27992 antérieures abandonnées et distinctes. ACK/reveal/request_id START non capturés : ne pas inventer leurs latences. BT27987 :13,874s entre premier En cours et mainPlayerStarted, cohérent avec reveal started trop tardif. Message POC issu du bridge HUB_PREGAME_ERROR, pas du catch polling ; code exact non conservé/non retrouvé. Six retours par suspension ; fullscreen/continuité DOM attestés par l’opérateur, pas par le serveur. Règle candidate ACK UI / started métier compatible, non implémentée. [Preuves, chronologies et limites : section AE](../../../notes/hub-open-players-foundations-2026-09-24.md). Aucun code/deploy/restart.


**25/09 — C révisé, local non déployé : retrait Hub durable immédiat ; cleanup runtime non bloquant.** Tombstone + membership inactive + slot closed/removed + focus/présentation libérés dans la demande PHP, réponse removed/already_removed ; aucun moteur requis. Le moteur vivant observe le tombstone puis détache/ferme les sockets sans finaliser le Hub. Read retiré explicite, lifecycle/START/Player tardifs refusés, cleanup tardif sans mutation ; gameplay sain protégé. Ancien removing finalisable en retentant le retrait, sans réconciliateur. A/B, ensure, auto-start5s/10s/5s/90s, compteur et UI pregame conservés. Tests :20 suites principales,26 scénarios retrait moteur/retour,300 vérifications retrait PHP ; compléments admission/publics/Pro/fallback verts, effets externes simulés. [Contrat, fichiers et rollback C : section AC](../../../notes/hub-open-players-foundations-2026-09-24.md). Markers25-09-2026/02 préparés ; aucun deploy/restart.


## 24/09/2026 — Open Players V2, local non déployé

**25/09 — Hub-native livré en DEV selon l’opérateur ; correctif Remote/reprise local, non déployé.** Remote : `client_routing` canonique de même session/E/génération redevient l’autorité ; aucun ACK Remote attendu, iframe masquée tant que son écran opérationnel n’est pas rendu. Reprise : preuve first_start existante → aucune préparation Open Players, même E/runtime ; Master premier lancement toujours révélé à l’ACK. Moteur5/10/5/90, instrumentation, trois contrôleurs WS et markers inchangés. [Audit, tests et recette ciblée](../../../notes/hub-open-players-foundations-2026-09-24.md#ah-correctif-ciblé-remote-et-reprise-après-recette-dev--25092026).

- [x] Audit des six vagues, projection population et instrumentation observationnelle (AF).
- [ ] Recette instrumentée, puis moteur de convergence/full-ready qualifié.
- [x] Migration Hub-native Master/Remote locale : CTA, ACK/relecture, takeover, mode stable par E.
- [ ] Recette DEV réelle Master/Remote et collecte instrumentée avant changement du moteur START.

- [x] Contrat courant : auto-start5s minimum / grâce sans bind10s / calme5s / watchdog exceptionnel90s, compteur WS inchangé et affichage regroupé250ms. Tests auto37/37 et UI20/20, vagues simulées5000 ; section T de la note V2. Global : aucun nouveau delta PHP. Minimum depuis open accepté, indépendance de l’animation250ms ; CTA Démarrer le jeu et styles dédiés supprimés sur Master/Remote, seul retour volontaire conservé. Textes adaptés au départ automatique. Retry ACK avec request_id stable par E et reprise du même START en starting ; watchdog demandé/accepté tracé distinctement.
- [ ] Recette navigateur et bots réels sur les trois moteurs ; livraison cohérente front/WS/markers par opérateur. Aucun déploiement ni restart effectué.

- [x] Contrôleur serveur et hooks init/register/state/play/cleanup raccordés ; tests offline du bridge/contrôleur et non-régression historique.
- [ ] Qualification DEV par opérateur (Open, reload, rebind, Lancer, Abandon) puis UI finale. [Recette](../../../notes/hub-open-players-foundations-2026-09-24.md).


## 23/09/2026 — Hotfix minimal hub_soiree

- [x] Base propre `hub_soiree` vérifiée ; extraction minimale, sans merge/cherry-pick. `registerPlayer` utilise la preuve ciblée avec exécution officielle fiable, hors papier ; contrôle lifecycle après await. Capacité historique conservée en contexte incomplet, papier/démo/autonome. Course bootstrap Quiz du chantier complet non traitée.
- [x] Tests ciblés et comparaison des échecs historiques à la base ; [commandes/résultats](../../../notes/hub-soiree-hotfix-2026-09-23.md).
- [x] Audit recette DEV compte442/Hub349 : gameplay observé sur les trois jeux ; lenteur Bingo quantifiée,59 refus de grilles du harnais préexistant et29 binds uniques BT. [Preuves et limites](../../../notes/hub-soiree-hotfix-2026-09-23.md#i-recette-dev-compte-442--hub-349--audit-des-logs-du-2309). Audit/doc uniquement.
- [x] Procédure opérateur de qualification prête dans la section J du rapport : retard ready15 s via overrides locaux, critères de continuation unique/annulation et trace DEV ciblée proposée ; non exécutée.
- [ ] Compléter la recette : ready volontairement >10 s, preuve du chemin ciblé, timings Master/WS Bingo avec/sans bots et génération des grilles du harnais ; branche/commit par opérateur lorsque Git est inscriptible. **Aucun déploiement ni restart exécuté par Codex.**


## 23/09/2026 — Hub session readiness

- [x] Préflight propre, branche opérateur `hub_session_readiness` depuis `hub_soiree`, reprise sélective sans merge. Preuve liée au bind/E1/incarnation, coordinateur de départ commun, admission WS ciblée, cohortes capacité et instrumentation.
- [x] Tests isolés du nouveau protocole et comparaison des échecs à la base ; détail actualisé dans le [rapport](../../../notes/hub-session-readiness-2026-09-23.md).
- [x] Après rechargement DEV : `connection.js` remis en conformité E1, 61/61 tests readiness/grâce ; dépendance `runtimeExpiry.js` absente DEV selon opérateur incluse explicitement dans la livraison avec les reprises `sas_players` non déployées. Aucun déploiement/restart ; liste de livraison et limites de parité dans le rapport.
- [x] Audit des logs de recette compte 10/Hub348 : trois binds Quiz mais aucun départ avant suspension ; course poll/retry bootstrap/init fortement probable. Bingo/BT démarrent via `window_elapsed` à 1/3 prêt, donc validation seulement partielle. Preuves et limites ajoutées au rapport ; aucun correctif applicatif dans cet audit.
- [ ] Résoudre l’ordonnancement bootstrap Quiz et qualifier les trois ACK Player avec trois surfaces visibles (deux onglets en arrière-plan confirmés pour ce run) avant validation globale de readiness.
- [ ] Commits cohérents dès Git inscriptible ; revue/recette distribuée 10/30/50/100, qualification de la fenêtre et charge réelle. Aucun déploiement autorisé par ce lot.


### Statut de livraison — 23/09/2026

`hub_soiree` : **déployé en PROD selon confirmation opérateur**. `sas_players`, `hub_session_readiness` et `cast` : **évolutions propres NON DÉPLOYÉES EN PROD**, même si leurs descriptions sont reprises dans la documentation `main`. Les anciens statuts datés restent l’historique des interventions, pas l’état courant. [Périmètres, références et limites](../../deployment-status.md).

- [x] Cohérence documentaire avant promotion : livraison `hub_soiree` consignée, exclusions `sas_players`/`hub_session_readiness`/`cast` explicites (vérifiées le 23/09) ; recettes restantes conservées.


## 22/09/2026 — Audit pipeline numérique Hub et convergence

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](../../deployment-status.md).

- [x] [Audit des outils natifs WS](../../../notes/ws-native-loadtools-audit-2026-09-22.md) : vraies admissions/sockets ; Quiz/BT limité à 5 000 tentatives, branche profils bloquée et arrêt de rampe incomplet ; Bingo profils prêts distinct du générateur froid Canvas (concurrence 8). Baseline DEV avant patch partielle, harnais à compléter ; commandes futures, métriques manquantes et matrice A/B consignées. Aucun outil/test exécuté ni patch/marker/restart/déploiement dans cette passe.
- [x] Harnais et instrumentation A/B préparés : [contrat, bundles séparés, commandes et tests](../../../notes/ws-loadtest-ab-instrumentation-2026-09-22.md). ACK/state, stop/drain borné, résumés, capacité B/N, publication BT, queue/I/O Bingo et process ; algorithmes métier conservés. Aucun déploiement/restart/charge réelle.
- [x] Incident Quiz DEV : copie des fichiers complets non commités sur baseline → dépendance performance `capacity_reads` absente, panne de chargement reproduite. Test d’installation sans réseau ajouté dans Games ; pack Quiz AVANT de récupération et marker exporté /04 préparés. [Preuves et fichiers corrects](../../../notes/ws-loadtest-ab-instrumentation-2026-09-22.md#incident-quiz-dev-après-copie-des-fichiers-non-commités).
- [x] Logs rechargés : Quiz écoute3032 à15:27:05 Paris ; test Hub346 avec50 joueurs distincts connectés et50 états envoyés. Aucun `LOADTEST_*` : le chemin navigateur Hub ne crée pas de run moteur. [Contrôle terrain](../../../notes/ws-loadtest-ab-instrumentation-2026-09-22.md#contrôle-terrain-hub346--50-bots-22092026).
- [x] [État Quiz DEV figé](../../../notes/quiz-dev-envutils-baseline-2026-09-22.md) : snapshot envUtils identique à AVANT/récupération, cohortes absentes, hooks présents ; autres fichiers du lot identiques au local et processus redémarré selon opérateur. Marker /03 par cette attestation ; /04 était préparé, pas réputé déployé. Deux tests capacité sur snapshot sans réseau réussis. Aucun autre snapshot Quiz requis ; BT/Bingo n’ont pas reçu ce lot.
- [x] Conception du [Hub Load Test unique](../../../notes/hub-loadtest-unified-design-2026-09-22.md) : Browser/Server comme générateurs du même parcours, définition ready, retries runtime, convergence/gameplay, horloges et replay sas offline borné. Audit/documentation seuls ; aucun patch, marker, restart ou charge.
- [x] Migration unifiée, socle Browser Quiz local : [contrat](../../interfaces/hub-bot-test-runner.md), population prepared, polling individuel, ACK/state, timeline/résumé, retries/drain et hooks moteur ; 23 tests runner + régressions verts. [Bundle AVANT/APRÈS](../../../notes/hub-test-browser-delivery-2026-09-22.md) et rollback vérifiés par SHA, envUtils DEV conservé, pas de cohortes AVANT.
- [x] Suite migration, premier Hub50 AVANT concluant sur hydration selon opérateur (Hub346/session27951). [Correctif gameplay/cleanup local](../../../notes/hub-gameplay-cleanup-2026-09-22.md) : stratégie générique off/legacy Quiz, parité ancien bot, stop/détachement puis retrait explicite des seules identités du run et vérification inactifs ; 46 tests verts, résumé hydration figé, bundle Games seul identique AVANT/APRÈS, Quiz/markers inchangés.
- [ ] Livrer ces 7 fichiers Games puis recette gameplay + stop/cleanup50 → session fraîche du même Hub → 200 ; conserver l'onglet jusqu'au cleanup, anciens runs v1 non importés automatiquement. Backend Server500/5000 et adaptateurs BT/Bingo restent futurs. Aucun déploiement/restart/charge réelle effectué pour ce correctif.

- [x] Étape capacité/publication locale : [Patch capacité/publication](../../../notes/hub-capacity-publication-patch-2026-09-22.md) ; cohortes fermées, index par réponse, lookup BT linéaire ; tests locaux verts. Ecommerce rechargé par l’utilisateur, non modifié.
- [ ] Mesurer B/N et qualifier5 000 ; capacité Bingo séquentielle toujours sans gain nominal. Aucun sas/restart/déploiement.

- [x] [Audit commun charge/convergence](../../../notes/hub-player-registration-pipeline-audit-2026-09-22.md) : coûts capacité/roster, scans et files, frontière in-flight, watcher et plan 50/500/5 000. Aucun patch applicatif/marker ; tests/probe I/O simulées seulement.
- [x] Dépendance ecommerce rechargée par l’utilisateur ; analyse autorisée sans modification. Qualification de charge toujours ouverte avant sas.


## 21/09/2026 — Conception future du mode équipe transverse

- [x] Principes produit/architecture consignés dans la [note unique de conception](../../../notes/hub-team-model-future.md) : identité Hub individuelle, équipes EP réutilisées, choix solo/équipe verrouillé par session, meilleur résultat par item. Modèle envisagé, non implémenté ; migration QR papier et questions de scope/persistance/classements encore ouvertes.
- [ ] Arbitrages produit et conception détaillée avant tout patch. Aucun changement applicatif dans cette passe ; équipes Blind Test toujours désactivées, contrats et PATCH1/1B/2/3 distincts.


## PATCH1B — validation de convergence (21/09/2026)

- [x] Maintenance PATCH1 réelle sous VM alimentée par les participations produites par le vrai flux Global avec I/O simulées :18→20 sans socket joueur, retry sans doublon ; scores Quiz/BT et association Bingo conservés. Aucun changement moteur/marker dans ce lot. [Rapport](../../../notes/paper-resume-patch1b-2026-09-21.md).


## 21/09/2026 — PATCH 2 corrections de score papier (local)

- [x] Identité K/D, correction exacte et reçus atomiques, distinction HTTP/live, réconciliation scores et fin confirmée ; podium de session Hub vérifié séparément pour Quiz/BT/Bingo et priorité de présentation corrigée dans Games.
- [x] 8/8 groupes de tests locaux, incluant14/14 suites PATCH1 ; lint/diff et génération des index. Aucun service ni DB réelle.
- [ ] Recette réseau/SQL/navigateur après une éventuelle livraison coordonnée autorisée séparément.

[Contrat](../../interfaces/paper-score-corrections.md) · [Rapport et rollback](../../../notes/paper-score-patch2-2026-09-21.md).


## 21/09/2026 — PATCH 1 inscription et roster papier (local)

- [x] Bind papier idempotent sur participation persistée, réconciliation active au bootstrap/reconnexion et toutes les5s en papier vivant ; scores existants conservés. Seule la publication réconciliée couvrante peut supprimer par absence. Marker21/09 /03 ; aucun restart exécuté.

[Contrat canonique](../../interfaces/paper-roster.md) · [Rapport et validation](../../../notes/paper-roster-patch1-2026-09-21.md). Tests isolés, sans DB réelle ; aucun déploiement.


## 2026-09-21 — Bots : admission HTTP avant inscription WebSocket (local)

Le client bots navigateur et les bots serveur Quiz/Blind Test attendent désormais le succès HTTP avant `registerPlayer` WS. Une ancienne identité locale ne dispense plus du contrôle HTTP. Le bot serveur transmet la même clé canonique au HTTP et au WS ; une identité renvoyée par le serveur est conservée. Refus HTTP ou arrêt pendant l’attente : aucune inscription WS. Les gardes Hub/runtime restent inchangés.

Vérification : `node games/web/tests/bot_admission_order_test.cjs` depuis Cotton (12 scénarios isolés, aucun réseau), plus `node games/web/tests/hub_capacity_runtime_test.cjs`. [Audit, limites et rollback](../../../notes/bot-admission-order-2026-09-21.md).


## Update 2026-09-21 — Jauge Hub et upsell (local, non déployé)

Probe/register WS relisent la capacité serveur Canvas ; le 51e joueur admis au Hub passe après upsell 50→100. Hydratation non historique filtrée et compte des identités Hub actives ; scores historiques conservés. Garde WS maintenue, démo à 2.

Offre effective = autorité commerciale. Maximum N Hub actifs ; probable sans place ; left libère une place et sa réactivation en nécessite une. Snapshots techniques synchronisés uniquement vers le haut ; downsell hors périmètre. [Contrat, tests et limites](../../../notes/hub-capacity-upsell-2026-09-21.md).


## Suspension officielle Hub — 10/09/2026

- [x] Patch local : `actions/hubLifecycle.js` et `hubSuspension.js` pilotent Pause/gel et reprise explicite. Les closes suspendus détachent les sockets sans désactivation DB ni grâce. Le snapshot vivant de progression prime sur le preload. Complément Remote18/09 repris après régressions DEV : séparation candidate/propriétaire/révoquée, réinscription standard, cache ESM versionné et bootstrap de génération absente depuis la publication exacte. Validateurs Global et serveur Bingo inchangés ; takeover/rattachement tardif validés en DEV par l’utilisateur. Complément UX local commun Games : ancienne Remote remplacée vers fermeture/about:blank, sans retour Hub ni clôture de démo ; quit volontaire inchangé. [Correctif de sortie takeover](../../../notes/remote-takeover-exit-2026-09-18.md). [Preuves, fichiers et recette restante](../../../notes/remote-bootstrap-regressions-2026-09-18.md). Complément18/09, expiration involontaire confirmée : identité moteur figée, événement `hub_runtime_expired` idempotent, focus CAS, refus `HUB_RUNTIME_EXPIRED`, aucun CTA/recréation officielle ; tests grâce valide, suspension >1 h et papier/numérique. [Rapport](../../../notes/hub-runtime-expired-2026-09-18.md).
- [x] Contrat et tests hors connexion consignés dans le [rapport de validation](../../../notes/hub-suspend-patch-2026-09-10.md).
- [ ] Recette sur services réels : matrice papier/numérique, Master/Remote, reprise/concurrence/cutoff/restart. Aucun déploiement ni redémarrage exécuté.

Les tâches anciennes de quit Hub terminal restent historiques ; leur recette terminale ne s’applique plus à une exécution officielle orchestrée suspendable.

- [x] 11/09/2026 — Correction du timeout observé en DEV Blind Test : Les refus WS `HUB_SOCKET_UNAUTHORIZED` incluent `execution_id` et `runtime_session_id` avec `request_id`, pour que le Master traite le refus immédiatement au lieu d’attendre le timeout. Marker préparé : `restart 11-09-2026/01`, aucun restart exécuté. Tests et preuves dans le rapport lié ci-dessus. Recette DEV après diffusion du correctif restante.

- [x] 11/09/2026 — Retour Play immédiat autorisé : Quiz/Blind Test/Bingo incluent désormais les sockets Players de la session dans les destinataires de `HUB_SESSION_SUSPENDED`, émis uniquement après succès de release/clear focus. Le handler Play valide contexte officiel, execution_id, runtime_session_id, token sessionId et request_id non vide ; il bloque les reconnects et revient directement au Hub Play, une seule fois, sans flux terminal. Les démos et signaux obsolètes sont ignorés. Le polling15s corrigé reste en secours ; une réponse HTTP déjà en vol ne provoque pas de seconde navigation.
- [x] Tests locaux verts : suites suspension Games/Bingo, grâce Quiz/Blind Test, isolation Player démo (133 résultats TAP).
- [ ] Recette DEV après diffusion Games et activation du code WS : retour des Players à réception du signal, roster conservé à la reprise. Markers WS Quiz/Blind Test/Bingo préparés `restart 11-09-2026/02` ; aucun restart exécuté.

<!-- AUTO-UPDATE:END id="hub-suspend-20260910-quiz-tasks" -->

<!-- AUTO-UPDATE:BEGIN id="hub-main-ws-copy-20260910-quiz" owner="codex" -->

## Copie PROD prévue le10/09 — dernier correctif de grâce

- [x] main=hub_soiree, worktree propre ; fusion réalisée par l’opérateur, sans synch ni copie serveur. Le reste est confirmé à jour en PROD par l’opérateur.
- [x] Lot retenu : `web/server/actions/connection.js` et `web/server/restart_serveur.txt` ; empreintes vérifiées sur main. Suite primary-grace44/44 verte ; Blindtest teams-disabled15/15 également verte.
- [ ] Copier demain dans une fenêtre sans sessions ni grâce/commandes, puis activer le processus WS précis avec le mécanisme PROD vérifié. Aucun restart exécuté. [Procédure section7 et manifeste WS](../../../notes/hub-main-promotion-2026-09-09.md).

<!-- AUTO-UPDATE:END id="hub-main-ws-copy-20260910-quiz" -->

## Migration du code Hub vers main — 2026-09-09

- [x] [Audit branches/code et manifeste candidat](../../../notes/hub-prod-code-migration-2026-09-09.md) : Fast-forward simulé, sept JS syntaxiquement valides ; pas de suite Quiz dédiée trouvée. 8 fichiers applicatifs candidats, nouveaux callbacks nécessitent Games/Global avant restart.
- [x] Vérification distante read-only des SHA, syntaxe/contrats ciblés, inventaire des dépendances et fichiers main-only ; aucun fichier applicatif ni SQL modifié.
- [ ] Lever les blocages Git (profil .git lecture seule ; Bingo cherry-pick ; Pro conflit), terminer les merges autorisés puis refaire validation sur main et figer les sources finales. Aucun merge, push, déploiement ou restart effectué.
- Reprise09/09 : [vérification AI Studio fraîche](../../../tmp/hub-prod-code-2026-09-09/REPRISE-AI-STUDIO.md) et refs contrôlées. main propre, ancien sequencer Bingo clos ; merge Bingo refusé ORIG_HEAD.lock en lecture seule. Global/WWW demandent des copies serveur avant merge. Aucun nouveau merge ; validation finale et manifeste FINAL en attente. Les contrôles précédents restent historiques.

## Audit / correctif résultats Play historique — Hub 291 — 07–08/09/2026

- [x] [Audit et correctif](../../../notes/hub-historical-player-end-audit-2026-09-07.md) : SQL DEV confirme la confusion start démo 365395 → completion 365512 à la fin officielle S1. Versions DEV à jour sur `hub_soiree` confirmées par l'utilisateur ; prérequis de rapatriement levé, pas de comparaison distante indépendante.
- [x] Patch local Games/Global : provenance depuis le start brut, garde commune démo/focus/recovery/already_completed ; aucune modification WS/Play/lancement, aucun write réparateur. Starts legacy incomplets = fin historique ; ancienne officielle exacte encore ouverte indiscernable sans nouveau start = ambiguïté explicitement conservée/testée.
- [x] Huit suites ciblées OK, dont tests de régression Games/Global avec vrais helpers et stockage simulé ; contre-épreuve sur ancien bridge en échec. Contrôle du bridge Bingo sans incident Bingo déclaré. Lint PHP/diff check et génération/relecture des index effectués. Aucun commit ni déploiement.
- [x] Recette navigateur du 08/09 validée par l'utilisateur : résultats personnels historique après démo, retour/résultats officiel Hub et démo Hub. Contrôle logs : Hub296 historique27717 fin07:53:18, officiel27718 fin07:57:22 ; Hub295 démo27722/source27710 fin07:59:33, branches cohérentes et GET retours Hub observés. Aucun nouveau patch.
- [ ] Réserve probatoire ciblée : unique SELECT start/completed des six sources/runtimes dans l'audit, pour lier les executions aux completions et vérifier la démo préalable27720 (identifiée historical_dashboard_demo, execution_id Hub non trouvé). Pro rechargé08/09 : POST dashboard07:51:20/07:54:34 corrélés aux démos27720/27721 ; origine mobile confirmée par l’utilisateur. Pas de preuve Nginx de payload WS ni de recette Quiz ce matin. Résultat navigateur acquis, pas de nouvelle recette demandée.
- Livraison migration : fonctionnel DEV validé, aucune anomalie démontrée ; réserve SQL explicite. Global app_games_hubs_functions.php avant Games boot_lib.php, sans redémarrage WS nécessaire. Aucun commit/déploiement par l'agent ; compatibilité legacy et ancienne officielle ambiguë inchangées.

## PATCH 2026-07-15 — Validation papier puis fin naturelle vers Hub
- [x] Remplacer le relais local `paper_finalize_end` par `finalizePaperScores()` avec états monotones et `event_id` stable côté Remote.
- [x] Ne diffuser `endGame`/`HUB_SESSION_FINISHED` qu'après persistance du classement final; restaurer `awaiting_score_validation` en échec.
- [x] Persister podium/classement avant toute transition Hub.
- [x] Forcer le statut terminal dans le `session_update` papier, après constat live `hub_natural_end_results_unavailable: session_not_terminated`; restaurer le statut de revue sur échec.
- [x] Appeler l'action dédiée et notifier Master/Players seulement pour une exécution Hub durable confirmée; journaliser le nombre de sockets avant fermeture différée.
- [x] Conserver l'écran final historique hors Hub et en fallback Canvas.
- [x] En démo Hub canonique, envoyer le résultat historique avant `HUB_SESSION_FINISHED` et transporter `runtimeMode=demo`; ne pas armer ce retour pour une démo Dashboard sans exécution Hub.
- [ ] Recette WS/DB/navigateur réelle: attente sans validation, correction, validation vierge, double clic, reload, Master absent, A tardif/B actif, égalités et hors Hub.

## PATCH 2026-07-12 — Expiration définitive de grâce Hub
- [x] Stocker/annuler le timer 1 h et protéger timer/incarnation concurrents.
- [x] Clear Hub avant `SESSION_ENDED`, sans bloquer la fin sur erreur HTTP.
- [ ] Recette réelle grâce/reconnexion/expiration/A→B/hors Hub.
- [x] 09/09/2026, patch local P0 Santueil : protéger le départ des secondary via `primaryReconnectTimer` et `graceExpirationInProgress`, sans branche papier ni nouveau mécanisme Hub.
- [x] 44 tests ciblés sur les handlers réels : deux formats × Hub/hors Hub × 11 scénarios (ordres de close, retours primary/Remote, plusieurs secondary, expiration et course Hub, échec Hub, remplacement/stale, candidat pending, quit, orphelin sans grâce). Comparaison rouge/vert commune Quiz/BT : 48/88 échecs avant patch, 88/88 réussites après.
- [x] Marker `restart 09-09-2026/01`; README, actions, HANDOFF, CHANGELOG et PM2 documentés; sitemap/index develop régénérés.
- [ ] Déploiement DEV puis recette réelle; PROD non déployé, aucun redémarrage effectué. Les dates Git ne valent pas dates PROD.


## PATCH 2026-06-12 — Primary organizer: recovery apres remplacement device

### Objectif
- eviter qu'une session Quiz reste sans primary organizer alors qu'une socket organizer valide existe encore;
- traiter le cas observe apres remplacement device et fermetures `1006`;
- ne modifier ni les flows papier/numerique ni les contrats front.

### Diagnostic
- Le primary organizer est stocke dans `session.primarySocket` avec `session.primaryInstanceId`.
- `registerOrganizer(isPrimary=true)` promeut deja une nouvelle socket si aucun primary ouvert n'existe, ou passe par un remplacement avec grace si l'ancien primary est encore ouvert.
- A la fermeture, une ancienne socket pouvait encore passer par la branche primary volontaire avant que le code ne verifie qu'elle etait toujours le primary courant.
- `sendMessageToPrimary()` loggait `WS_SEND_NO_PRIMARY_ORGANIZER` si `session.primarySocket` etait absente/fermee, sans tenter de recuperer une socket organizer candidate ouverte.

### Modifie
- `../quiz/web/server/messaging.js`
  - ajoute une recuperation locale dans `sendMessageToPrimary()` depuis `pendingPrimarySocket` / socket organizer ouverte connue;
  - log `PRIMARY_ORGANIZER_RECOVERED` avec ancien/nouveau primary, compte organizers/secondaries actifs et reason;
  - conserve `WS_SEND_NO_PRIMARY_ORGANIZER` quand aucune socket organizer active n'existe, avec compteurs enrichis.
- `../quiz/web/server/actions/connection.js`
  - ignore explicitement une fermeture stale avant tout traitement volontaire/session delete;
  - log `PRIMARY_ORGANIZER_CLOSE_IGNORED_STALE`.
- `../quiz/web/server/restart_serveur.txt`
  - marker WS `restart 12-06-2026/03`.

### Verification
- `node --check /home/romain/Cotton/quiz/web/server/messaging.js`
- `node --check /home/romain/Cotton/quiz/web/server/actions/connection.js`

## PATCH 2026-05-04 — Reprise demo: score joueur avant bind WS

### Objectif
- comprendre et corriger la remise a zero du score quand l'iframe joueur se reconnecte apres une reprise de demo numerique;
- borner le correctif aux demos numeriques deja lancees.

### Cause racine
- sur reprise demo, la vue organizer pouvait deja afficher le score depuis `players_get`;
- au passage sur `Jouer`, `registerPlayer` pouvait chercher le joueur dans `session.players` avant que le cache WS ait ete hydrate depuis la DB;
- si le joueur n'etait pas trouve en memoire, le WS recreait/bindait un joueur runtime a `playerScore: 0`, puis renvoyait cet etat a l'iframe.

### Modifie
- `../quiz/web/server/actions/registration.js`
  - `registerPlayer(...)` devient asynchrone;
  - avant le bind joueur, hydrate `session.players` depuis `players_get` uniquement si `session.isDemo === true`, `session.paperMode !== true`, `!isAdminPaper`, et session deja lancee.
- `../quiz/web/server/actions/wsHandler.js`
  - attend `registerPlayer(...)` pour garantir l'ordre hydrate -> bind.
- `../quiz/web/server/restart_serveur.txt`
  - marker WS mis a jour.

### Verification
- `node --check /home/romain/Cotton/quiz/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/quiz/web/server/actions/wsHandler.js`
- `git diff --check`

## PATCH 2026-05-04 — Demo participant dans quota

### Objectif
- aligner la limite demo affichee avec le nombre de joueurs connectes;
- faire compter `Joueur démo` dans `maxPlayers`.

### Modifie
- `../quiz/web/server/actions/registration.js`
  - `countQuotaPlayers(...)` compte maintenant tous les joueurs memoire;
  - le blocage session pleine s'applique aussi au joueur demo si la limite est deja atteinte.
- `../quiz/web/server/actions/connection.js`
  - retour sous limite recalcule sur tous les joueurs.
- `../quiz/web/server/restart_serveur.txt`
  - marker WS mis a jour.

### Verification
- `node --check /home/romain/Cotton/quiz/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/quiz/web/server/actions/connection.js`

## PATCH 2026-04-30 — Demo participant hors quota

### Objectif
- permettre au participant automatique `Joueur démo` des demos desktop de rester visible cote organizer;
- garantir que ce participant ne consomme pas une place dans `maxPlayers`;
- laisser les vrais joueurs mobiles rejoindre via QR code en plus du joueur demo.

### Modifie
- `../quiz/web/server/actions/registration.js`
  - detection `demoParticipant:true` uniquement si la session WS est marquee demo;
  - stockage `isDemoParticipant` sur le joueur en memoire;
  - calcul de quota via joueurs hors demo pour `checkSessionStatus`, reset `limitReached` et blocage session pleine.
- `../quiz/web/server/actions/connection.js`
  - retour sous limite recalcule hors participants demo.
- `../quiz/web/server/restart_serveur.txt`
  - marker WS mis a jour.

### Verification
- `node --check /home/romain/Cotton/quiz/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/quiz/web/server/actions/connection.js`

## PATCH 2026-03-24 — Logs prod cibles reprise joueur Quiz

### Objectif
- ajouter une preuve `info` serveur compacte a chaque rattachement player WS, afin de verifier demain si les coupures mobiles se traduisent bien par une reprise fonctionnelle de session.

### Correctif livre
- `../quiz/web/server/actions/registration.js`
  - ajout du log `PLAYER_WS_BOUND` (niveau `info`) sur les deux chemins `registerPlayer`:
    - nouveau joueur,
    - joueur reconnecte.
  - meta: `{ player_id, player_db_id, player_name, is_reconnect, is_admin_paper }`.

### Effet attendu
- les sessions Quiz prod montrent maintenant explicitement les rattachements WS joueur reussis, au lieu de ne laisser visibles que les coupures.

## Todo
- Vérifier en intégration que tous les writes WS player-scoped passent en `identity_mode=canon` (quiz `update_score` + `deactivate_player`).
- Surveiller `LEGACY_REGISTER_USED`; retirer définitivement le fallback `playerId` dès compteur=0 côté WS register.
- Planifier retrait du fallback legacy côté glue (`identity_mode=legacy`) dès extinction des usages.
- Exécuter un smoke test loadtest WS (20s, 3 bots) et confirmer `PLAYER_ID_MISSING_OR_INVALID=0`.

## Quick checks (Patch 6)
- Syntaxe WS:
  - `node --check ../quiz/web/server/actions/loadtest.js`
  - `node --check ../quiz/web/server/actions/envUtils.js`
  - `node --check ../quiz/web/server/actions/connection.js`
  - `node --check ../quiz/web/server/actions/gameplay.js`
- Smoke test bots:
  - `rg -n "BOT_IDENTITY|PLAYER_ID_MISSING_OR_INVALID|LEGACY_REGISTER_USED" ../quiz/web/server/server-logs.log`
  - Relance à paramètres identiques (`sid` + bot range) et vérifier `player_id` identiques dans `BOT_IDENTITY`.
- Contrat bridge quiz:
  - `php -l ../games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `rg -n "identity_mode|legacy_identity|BAD_PLAYER_ID|PLAYER_NOT_FOUND|_quiz_is_canonical_player_id" ../games/web/includes/canvas/php/quiz_adapter_glue.php`
- Contrat front register (games):
  - `rg -n "player_stable_id:|getSessionScopedStableKey|getOrCreateStablePlayerRef|player_register_tx|register/debug" ../games/web/includes/canvas/play/register.js`
- Migration SQL présente:
  - `rg -n "uq_cq_players_session_player|idx_cq_players_session_active|player_id" ../games/web/includes/canvas/sql/2026-02-10_players_player_id_upsert.sql`
- Logs runtime:
  - `rg -n "PLAYER_REGISTER_UPSERT_(OK|ERR)|MISSING_PLAYER_ID|PLAYER_DEACTIVATE_BY_KEY_(OK|ERR)" ../quiz/web/server/server-logs.log`
- Replacement WS player:
  - `rg -n "PLAYER_REPLACEMENT|PLAYER_SOCKET_REPLACED_CLEANUP|WS_CLIENT_DISCONNECTED" ../quiz/web/server/server-logs.log`
  - `rg -n "SESSION_REPLACED|4005|player-replaced" ../quiz/web/server/actions/registration.js ../quiz/web/server/actions/wsHandler.js ../quiz/web/server/actions/connection.js`

## AUDIT fin de session (2026-02-11, NO PATCH)

### Fichiers inspectés
- `../quiz/web/server/actions/gameplay.js`
- `../quiz/web/server/actions/registration.js`
- `../quiz/web/server/actions/sessionUtils.js`
- `../quiz/web/server/actions/envUtils.js`
- `../quiz/web/server/actions/wsHandler.js`
- `../quiz/web/server/actions/connection.js`
- `../quiz/web/server/resources/sessions.js`

### Constats factuels
- End detection: bascule par `initializeOrUpdateSession` quand `gameStatus === "Partie terminée"` puis `endGame(sessionId)` (`../quiz/web/server/actions/gameplay.js:235`, `../quiz/web/server/actions/gameplay.js:238`, `../quiz/web/server/actions/gameplay.js:975`).
- Persistance DB à la fin: write `session_update` via `persistPodium` avec payload `{ sessionId, currentSongIndex, gameStatus, totalPlayers, podium, game:'quiz' }` (`../quiz/web/server/actions/gameplay.js:1199`, `../quiz/web/server/actions/gameplay.js:1219`, `../quiz/web/server/actions/gameplay.js:1229`). `event_id` est injecté/obligatoire dans `canvasWrite` (`../quiz/web/server/actions/envUtils.js:293`, `../quiz/web/server/actions/envUtils.js:310`).
- Hydratation DB au reload organizer: `ensureSessionPrimaryId` (`session_primary_id`) puis `players_get`, mapping dans `session.players` (score conservé par max) (`../quiz/web/server/actions/sessionUtils.js:19`, `../quiz/web/server/actions/registration.js:618`, `../quiz/web/server/actions/registration.js:652`, `../quiz/web/server/actions/registration.js:736`).
- Payloads WS envoyés après reload: snapshot players `updatePlayers` puis, en session terminée, payload `endGame` (orga via `sendMessageToOrganizers`, players reconnect via `getGameState`) (`../quiz/web/server/actions/gameplay.js:943`, `../quiz/web/server/actions/gameplay.js:1002`, `../quiz/web/server/actions/gameplay.js:525`, `../quiz/web/server/actions/gameplay.js:599`).
- Reconstruction podium/classement: podium dérivé du ranking trié score desc + tie-break `playerId` alpha (`stableSortByScoreDesc` + `assignCompetitionRanks`), puis top rangs 1..3; si snapshot final mémoire existe, il est prioritaire (`../quiz/web/server/actions/gameplay.js:887`, `../quiz/web/server/actions/gameplay.js:898`, `../quiz/web/server/actions/gameplay.js:1040`, `../quiz/web/server/actions/gameplay.js:1098`).

### Gaps identifiés (sans patch)
- Aucune lecture DB dédiée au podium à la reprise: only `players_get` est lu; le podium reload dépend de `session.finalPodium` mémoire ou recalcul depuis players (`../quiz/web/server/actions/registration.js:652`, `../quiz/web/server/actions/gameplay.js:1047`, `../quiz/web/server/actions/gameplay.js:1098`).
- `getGameStateForRemote` en session terminée mappe `playerRank` depuis `session.finalRankings[*].playerRank` alors que le snapshot figé stocke `finalRank`; risque de `playerRank` nul dans ce chemin (`../quiz/web/server/actions/gameplay.js:535`, `../quiz/web/server/actions/gameplay.js:539`, `../quiz/web/server/actions/gameplay.js:992`).

## Done
- [x] 2026-02-13 — WS quiz observability: `WS_CLIENT_DISCONNECTED` enrichi avec `meta.ws_client_id`, `meta.ws_role` et `closeReason` (en plus de `closeCode/intent/involuntary`) pour faciliter la corrélation avec incidents front.
- [x] 2026-02-12 — WS quiz: fix `disconnectPlayers` crash (`deactivations is not defined`) en réintroduisant la collecte `deactivations` avant `Promise.allSettled`; fin de session organizer (volontaire) validée sans erreur runtime.
- [x] 2026-02-10 — Patch 2: `quiz_api_player_register` passé en UPSERT par `(session_id, player_id)`.
- [x] 2026-02-10 — Patch 2: fallback `player_id` serveur si absent (compat vieux client) + trace `MISSING_PLAYER_ID` côté bridge.
- [x] 2026-02-10 — Patch 2: `quiz_api_deactivate_player` priorise `(session_id, player_id)` puis fallback legacy `(id, session_id)`.
- [x] 2026-02-10 — WS quiz: logs `PLAYER_DEACTIVATE_BY_KEY_OK/ERR` ajoutés dans `web/server/actions/connection.js`.
- [x] 2026-02-10 — Front register (games): envoi `player_id` stable sur `player_register` pour quiz/blindtest.
- [x] 2026-02-11 — Front register (games): `player_id` désormais stable par session via clé `${slug}:player_stable_id:${sessionId}` + migration douce depuis la clé legacy.
- [x] 2026-02-10 — Patch 2b: `persistScore` envoie explicitement `player_id` dans `web/server/actions/gameplay.js`.
- [x] 2026-02-10 — Patch 2c: suppression de la dépendance `created_at/updated_at` dans les writes `cotton_quiz_players` (`player_register`, fallback `update_score`, `deactivate_player`) pour éviter les `SQL_ERROR` si schéma partiel.
- [x] 2026-02-11 — WS quiz: politique player “last connection wins” sur `registerPlayer` (event `SESSION_REPLACED`, close code `4005`, intent `player-replaced`, cleanup mémoire sans `deactivate_player` DB).
- [x] 2026-02-11 — WS quiz: `registerPlayer` strict `player_id` canon (`p:<uuid>`) obligatoire; reject + log `PLAYER_ID_MISSING_OR_INVALID` si absent/invalide; instrumentation `LEGACY_REGISTER_USED` si payload legacy numeric reçu.
- [x] 2026-02-11 — WS quiz: `player_db_id` devient secondaire (`player.playerDbId`, `socket.playerDbId`, `registrationSuccess.playerId`), `deactivate_player` envoyé en mode key-first (`player_id` canon + `playerId` seulement si connu).
- [x] 2026-02-11 — Patch 4 WS→PHP glue: normalisation payload player-scoped dans `envUtils.canvasWrite` (`WS_API_PAYLOAD_VALIDATED`, `player_id` canon obligatoire, `playerId` numeric-only), `persistScore` corrigé key-first (`player_id` canon + `playerId?`), et bridge `quiz_api_update_score`/`quiz_api_deactivate_player` aligné key-first avec `identity_mode` + `legacy_identity`.
- [x] 2026-02-11 — Patch 6 loadtest quiz: génération déterministe `player_id` (`p:<uuid>`) par bot (`cotton-bot-player-id-v1|quiz|sid|botId`), register WS strict (`player_id` obligatoire, `playerId` seulement si numérique connu) et `checkAnswer` key-first (`player_id` + `playerId?`).
