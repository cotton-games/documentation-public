# Hub Bot Test Runner — contrat Browser v2

<!-- AUTO-UPDATE:BEGIN id="hub-bot-test-runner" owner="codex" -->

## Extension readiness produit — 23/09/2026

Patch local `hub_session_readiness`, [contrat/recettes/résultats](../../notes/hub-session-readiness-2026-09-23.md). Le runner suit maintenant la preuve E1 produit (le diagnostic seul ne compte plus prêt dans ce mode). BT hydratation/off ajouté. Scénarios simultané/progressif/retry/reconnect/échec permanent/retard +20 s. Bingo froid par défaut UI : allocation dans le KPI ; prepared reste une comparaison explicitement hors KPI. Stock disponible/à compléter à qualifier séparément ; allocation et génération ne sont pas synonymes. Export `e1_readiness` avec quantiles et individus, readiness courante distincte du premier succès ; horloges Global/moteur à synchroniser. Les tests locaux simulent les frontières, aucune performance DEV n’est annoncée.


## Extension Browser v3 — Bingo numérique

[Contrat Bingo détaillé, autorités et livraison](../../notes/hub-bingo-browser-baseline-2026-09-22.md). Même scénario/UUID/sujets/polling/timeline/résumé ; `prepareSubject` injecté prépare N vraies grilles par player_register→grid_assign→grid_hydrate avant armement, sans auth WS ni runtime artificiel. Session cible officielle numérique explicitement sélectionnée, même Hub, prepared/off. Quiz conserve son chemin lorsque la cible est vide. Préparation incomplète interdit armement, N reste figé.

Bingo traverse access/ensure/mapping réels, réhydrate puis auth_player et vraie queue. Grille exploitable, session/playlist/support/identités/exécution/tentative/génération concordants, premier state authentifié **et fin post-reset** sont requis : `grid_ready`, `auth_state_ready`, puis ready=max dans le domaine client. Aucun ready sur bind/state seul. Reset invalide la tentative ; retry commun avec la même identité. Les métriques spécifiques sont dans `engines.bingo`, sans secrets, allocation hors KPI déclarée.

L'observateur marque runtime_ready après restauration lifecycle, sans prétendre à l'ACK organisateur Quiz ; created/accepting désignent le contexte Hub moteur. Racine auth jusqu'à fin post-reset, vraie transition playback et premier contenu observés. Aucun ajout I/O/reset/queue métier. Off synchronise uniquement ; gameplayAdapter reste l'extension future. Stop/cleanup identiques au contrat ci-dessous. Les détails Quiz qui suivent gardent leur portée Quiz.

## Gameplay indépendant et cleanup par run (v2)

[Contrat détaillé, audit/parité et recette](../../notes/hub-gameplay-cleanup-2026-09-22.md). `HubTestRun.gameplayAdapter` expose mode/config/create/summary/stop ; handle moteur message/stop créé seulement après ready. Off par défaut, sans réponses ni I/O oracle ; legacy Quiz utilise vraie admission/socket, initial state et sessionUpdate, checkAnswer et paramètres historiques. Fin legacy sur endGame de tous les sujets, Stop ou timeout10min existant. Legacy BT/Bingo futurs, scripted absent. Export : gameplay_mode/config/activity séparés, answers_accepted=null faute de contrat machine non ambigu. Définitions/timestamps hydration inchangés ; une charge gameplay réelle peut influencer les latences des autres sujets.

Nouveaux sujets propres au run, jamais importés depuis le stockage Hub legacy partagé. Stop annule timers et sockets sans quitter le Hub ni la partie. Cleanup exige sealed + drain effectif et utilise current_player → leave_player → current_player sur les seules identités générées et finales du run, avec vérification stricte d'identité. Résumé cleanup séparé : requested_to_remove/removed/already_absent/failures/verified_inactive ; échecs isolés, répétition idempotente, aucun changement du résumé hydration. Sélecteur des runs de l'onglet ; garder cet onglet ouvert jusqu'au nettoyage, pas de reconstruction automatique depuis les exports sans secrets ni les anciens runs v1. Aucune route/SQL/reset/désallocation ajoutés.

Version3 locale du 22/09/2026 ; Quiz Browser est opérationnel en DEV selon opérateur, extension Bingo non déployée. **Hub Load Test est un harnais générique ; hydration est son premier scénario, Browser son premier backend.** Le backend Server et l’adaptateur Blind Test restent à développer ; Bingo numérique prepared/off est prêt localement. Les outils session restent dans Diagnostic / legacy.

## Architecture et autorité

`HubTestRun` possède le UUID canonique, N figé, les sujets stables, le collecteur borné, le délai global et le scellement unique. `HubTestScenario.event/summary` porte les règles de scénario ; `BrowserBackend.prepare/arm/stop` réalise les transports. `HubHydrationScenario` porte les champs communs et reçoit les détails métriques moteur injectés.

États : `preparing → armed → observing → draining → sealed`. Dans cette première livraison, l'autorité tourne dans l'onglet Browser ; aucun service contrôleur Server n'est installé. Une préparation incomplète conserve N et termine sans armer. Le backend réutilise les inscriptions publiques de `hub_bots.js` avec `prepareOnly`, vérifie N identités distinctes, effectue la préparation spécifique au moteur, puis arme un observateur de ce moteur et un pont Master `BroadcastChannel`/localStorage. Aucun Player WS avant le vrai launch intent. Une seule observation par processus moteur est autorisée simultanément ; les jobs encore en vol bloquent une nouvelle observation.

Le chemin instrumenté est le bouton de lancement normal du **Hub Master**, dans le même profil navigateur et la même origine que test_bots. Master Remote/mobile et les autres variantes de lancement ne sont pas qualifiés par ce lot. `focus_active` mesure la réception du succès HTTP Master, pas l'instant du commit PHP. `beginPlayFlow` est observé sans modifier son comportement, l'auto-start ou l'orchestration.

## Polling, admission et ready

Browser : 1–200 sujets, chacun avec au plus un poll en vol, suivant 3 500 ms après réponse ; premier poll immédiatement après le launch observé. La vague est donc synchronisée par l'armement : ce n'est pas une simulation des phases de watchers de visiteurs arrivés à des moments différents. Le watcher produit reste inchangé. Budget : 180 polls/sujet, 20 envois register/sujet, 10 minutes pour le run préparation incluse. HTTP borné à 15 s, admission/ACK/state à 30 s. Les erreurs HTTP pré-register utilisent le budget de polls.

Après `active_launched_session`, l'adaptateur Quiz appelle les vraies actions Canvas `session_primary_id`, `player_register`, puis ouvre le socket et envoie `registerPlayer`. La même identité Hub et le même slot sont conservés ; `attempt_seq` augmente à chaque register réellement envoyé. `SESSION_NOT_FOUND` est ajouté sur le refus existant, sans changer l'admission. Retry après 3,5 s, jamais un nouvel inscrit pour compenser un refus.

Pour Quiz, `PLAYER_READY_FOR_GAMEPLAY` = admission valide + ACK `registrationSuccess` pour la bonne session/identité + `getGameState` envoyé **après** cet ACK + état exploitable avec écho diagnostic session/identité concordant. WS open, bind ou ACK seul ne suffisent pas. État courant reconnu ; en cours, index entier et options tableau requis. Les doublons ne comptent pas deux fois ; une déconnexion diminue `ready_current`, pas le nombre de premiers succès. Ce client ne rend pas l'audio/DOM Player. Le mode off ne répond pas ; le mode legacy Quiz répond après ready via une stratégie indépendante décrite ci-dessous.

## Observation et métriques

Hooks Quiz actifs uniquement en présence de l'observateur, disponible avec `NODE_ENV=development` ou `HUB_TEST_ENABLED=1`. Sans run, les handlers conservent leurs retours/promesses/exceptions ; l'écho de state est absent. Seul le code stable de refus est ajouté même hors run. Les contrôles diagnostiques ne créent pas de runtime.

Jalons distincts : armed, launch_intent, focus_active, first_poll_after_launch, first_access_resolved, runtime_created, runtime_accepting, organizer_ack, runtime_ready, first_ws_attempt, first_bind_server, first_bind, ready, gameplay_start, first_content, begin_play_flow. ACK organisateur précède potentiellement l'hydratation : `runtime_ready` n'est émis qu'après fin du handler et bootstrap réussi. `gameplay_start` observe la transition acceptée vers `En cours`; `first_content` observe handleStart. Le démarrage interne PHP ensure n'est pas instrumenté : `milestone_sources.ensure_start=not_observed_in_php`, aucun timestamp serveur inventé.

Les racines `registerPlayer` englobent l'attente capacité et le bind ; `getGameState` est une seconde racine. Compteurs O(1) courant/max, arrivées/fins/retour à zéro. Les sous-appels capacité ne sont pas recomptés comme racines. Scope session sélectionné au premier access ; les événements antérieurs sont mis en tampon puis filtrés. Les compteurs incluent aussi les éventuels Players réels de cette session : utiliser une session de recette isolée. CPU delta, heap/RSS et maxima sont ceux du **processus Quiz entier**, échantillonnés au plus à 1 Hz, non une allocation CPU attribuable aux seuls bots.

Convergence nearest-rank : rang `ceil(q*N)` pour 50/90/95/99 %, temps depuis launch jusqu'au premier ready de ce rang. `time_to_all_ready` exige N premiers succès, sinon null ; `time_to_last_observed_ready` reste distinct. Au vrai gameplay moteur : ready courant, ratio/N et pending/N ; tail complète = max(0, dernier premier-ready − gameplay), seulement si N/N atteint. À 49/50, all-ready et tail restent null. Pas de ventilation historique fine des phases pending dans cette version.

Horloge Browser monotone projetée par timeOrigin ; moteur monotone avec epoch de processus, calibration aller-retour puis contrôles 5 s. Incertitude = demi-RTT maximal ; dérive excessive signale CLOCK_DRIFT, changement epoch interrompt. `ready_count_time_bounds` donne min/max de ready_current dans l'intervalle d'incertitude autour du gameplay. Cette borne réseau ne prouve pas une synchronisation parfaite/asymétrie nulle. Les temps ne doivent pas être interprétés plus finement que cette incertitude.

## Résumé, timeline et arrêt

Un seul `HUB_LOADTEST_RUN_SUMMARY`, schema1/version `hub-browser-3`, imprimé dans la console **du runner Browser** et exportable JSON. Il ne sera pas écrit dans les anciens logs LOADTEST du serveur. Inclut UUID, Hub/session numériques, execution, N, inscrits, accès, refus runtime tentatives/sujets, reprises, retries, WS/bound/ready/current/failures/unresolved, convergence, gameplay, jobs/process, producteurs, validité et timeline. Le hash UI est SHA256 de la concaténation ordonnée des neuf SHA256 des modules bots : hub_bots/core/browser/cleanup/quiz/bingo/quiz_gameplay/bridge/ui. Le manifest de livraison donne les hashes de tous les fichiers, y compris serveur.

Timeline agrégée : ready/current/pending, polls programmés/en vol, racines moteur, arrivées/fins et jalons. Pas de noms, pseudos, clés Hub/session ni profils dans le résumé. Les jetons nécessaires au protocole restent dans les transports/mémoires privés. 40 000 lignes Browser, tampon initial moteur 12 000, 2 000 événements par flush moteur 100 ms ; dépassements rendent le run incomplet. Les corps d'erreurs ne sont pas exportés.

Fin automatique en mode off : N prêts courants + gameplay + runtime_ready + focus + racines à zéro, vérifiés après 2 s ; zéro seul n'est jamais une convergence Hub. Stop coupe polls/retries, ferme les sockets bots, attend HTTP engagés et racines dans une fenêtre globale de 15 s (drain moteur au plus 12 s), puis scelle avec DRAIN_INCOMPLETE si nécessaire. Le canal diagnostic est fermé à expiration. Le serveur peut encore finir une requête au-delà de cette fenêtre : le résumé ne prétend pas l'avoir drainée. Aucun leave Hub, suppression de mapping, reset ou arrêt de partie. La fermeture brutale de l'onglet ne garantit pas un export ; utiliser Stop et exporter avant de fermer. Les inscriptions restent présentes après le run jusqu'au cleanup explicite décrit ci-dessous.

La timeline sert au replay descriptif offline ; elle ne prouve pas les latences qu'aurait un futur sas modifiant la charge et les courses.

[Livraison AVANT/APRÈS, preuves, fichiers, recette Hub50 et rollback](../../notes/hub-test-browser-delivery-2026-09-22.md).

<!-- AUTO-UPDATE:END id="hub-bot-test-runner" -->
