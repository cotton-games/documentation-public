# Hub — préparation durable E1 et readiness Player — 23/09/2026

## Statut et périmètre

**Statut au 23/09/2026 : branche `hub_session_readiness` NON DÉPLOYÉE EN PROD.** Ce chantier reste exclu du hotfix minimal `hub_soiree`. Les recettes DEV décrites ici et la présence de cette note dans la documentation `main` ne constituent pas une livraison PROD. [État de livraison](../canon/deployment-status.md).

**Complément opérateur du 23/09 : les branches `sas_players` n’étaient pas déployées en DEV.** Les reprises sélectives ci-dessous doivent être livrées avec readiness. L’opérateur rapporte une recette BT/Bingo réussie et un écart Quiz ; ces constats ne valent pas validation par les tests locaux. Le rechargement Quiz n’était pas un miroir avec suppression des fichiers absents : `runtimeExpiry.js` reste localement mais est absent de DEV dans Quiz et BT selon l’opérateur. Voir la liste de livraison explicite ci-dessous, qui complète la liste historique des fichiers modifiés.

Patch local sur `hub_session_readiness`, créé par l’opérateur depuis `hub_soiree` dans cinq dépôts. Pas de merge de `sas_players`. Aucun déploiement, restart, SSH, accès DEV/PROD ou navigateur. Les fichiers `.git` restent en lecture seule dans cette session : changements de travail disponibles, commits non créés. Les tests locaux et les réserves sont consignés ci-dessous ; aucune qualification de charge réelle n’en découle.

Préflight effectué sur worktrees propres avant modification. START/main, SITEMAP, README, manifest et HANDOFF/develop ainsi que journal AI Studio public ont été consultés avant patch. Les recherches ciblées n’ont identifié aucun fichier Canvas/Hub/moteur annoncé comme modifié hors workspace dans le journal ; cela ne prouve aucune parité serveur. Les anciennes notes décrivant `sas_players` restent historiques.

| Dépôt | Base locale `hub_soiree` | Branche de travail | HEAD (sans commit nouveau) |
|---|---|---|---|
| games | 38190ce | hub_session_readiness | 38190ce |
| global | d1f9f15 | hub_session_readiness | d1f9f15 |
| bingo.game | 9788e31 | hub_session_readiness | 9788e31 |
| blindtest | ef1c180 | hub_session_readiness | ef1c180 |
| quiz | 69192a2 | hub_session_readiness | 69192a2 |

`play` reste sur `hub_soiree`/28b01a5, inchangé : watcher Hub, admission et Player Canvas nécessaires sont dans Games. Documentation sur develop/b356285a, changements locaux.

## Reprise sélective de sas_players

| Source | Repris/adapté | Dépendances et exclusions |
|---|---|---|
| Quiz 74b99c9 | cohortes `capacity_reads`, index de réponse `hubCapacity`, transport | Cohorte fermée avant I/O ; aucun cache TTL d’autorisation. Marker restart exclu. |
| BT 1a76a66 | même capacité ; index de publication/classement et test d’équivalence | Priorité membre/première correspondance conservée. Marker restart exclu. |
| Bingo 06b9675 | routage grille, authentification dans queue reset, cohortes/index, state numérique sans roster, tests pipeline | Repository/reset/server repris ensemble ; aucune auth complète avant queue. |
| Games b4609aa | tests capacité cohort/runtime/transport | Fixtures adaptées aux nouvelles dépendances ; aucune règle produit tirée des limites de test. |
| Games 762c925 | runner Browser, sujets, timeline, cleanup, Quiz gameplay, adaptateur Bingo, pont diagnostic | Hooks Master ciblés seulement ; pas de copie globale du helper PHP. UI runner uniquement `test_bots.php`. Outils d’export A/B et test d’installation dépendant d’un bundle externe exclus. |
| Quiz 37b1b78 / BT b6d63cd / Bingo ddc94b2 | métriques, observateurs existants, harnais natifs, hooks transport/auth/publication | BT reçoit en plus un observateur Browser adapté de Quiz. Les diagnostics restent sans autorité de départ. Version/restart exclus. |

La preuve produit, le journal de préparation, l’API de décision, la continuation Master/Remote et le mode Bingo froid sont des adaptations/nouveaux développements. CSS podium/scrollbar, anciens écrans sans rapport et fixture commerciale extérieure au chantier ne sont pas repris. Aucun cherry-pick/merge global effectué.

## Livraison depuis un DEV sans sas_players

Source à copier : **les fichiers actuels des worktrees `hub_session_readiness`**, pas les fichiers bruts de `sas_players` et pas un export du HEAD readiness (le patch n’est pas committé). Aucun merge global de `sas_players` n’est nécessaire. Une liste `git diff` seule ne suffit pas : elle omet les nouveaux fichiers non suivis et les dépendances inchangées mais absentes de DEV.

### Quiz et Blind Test — même liste de chemins

Livrer les fichiers ci-dessous **dans chacun des deux dépôts**, avec leur contenu propre au jeu :

```text
web/server/actions/capacity_reads.js
web/server/actions/connection.js
web/server/actions/envUtils.js
web/server/actions/gameplay.js
web/server/actions/hubCapacity.js
web/server/actions/hubPreparation.js
web/server/actions/hub_readiness_runtime.js
web/server/actions/hub_test_observer.js
web/server/actions/loadtest.js
web/server/actions/loadtest_metrics.js
web/server/actions/registration.js
web/server/actions/runtimeExpiry.js
web/server/actions/wsHandler.js
web/server/logger_v1.js
web/server/messaging.js
```

- `capacity_reads.js`, `hubCapacity.js` et les adaptations de transport reprennent les optimisations sélectionnées de `sas_players`.
- `hub_test_observer.js`, `loadtest_metrics.js`, `loadtest.js` et leurs hooks sont repris/adaptés de `sas_players`. Ils sont requis par les imports de cette implémentation, même sans lancer de charge. Ne pas les omettre sous prétexte qu’il s’agit de diagnostics.
- `hubPreparation.js` et `hub_readiness_runtime.js` sont les nouveaux modules readiness. `registration`, `wsHandler`, `gameplay` et `envUtils` doivent conserver les ajouts readiness au-dessus des reprises sélectives.
- `runtimeExpiry.js` appartient déjà à `hub_soiree` (Quiz `557f5a2`, BT `3461407`, 18/09), pas à une nouveauté de `sas_players`. Son absence DEV est attestée par l’opérateur. Livrer le couple `connection.js`/`runtimeExpiry.js`, même s’il n’apparaît plus dans `git diff`.
- Redémarrage WS de chaque moteur après livraison du lot. `.env`, dépendances npm et configuration PM2 existantes ne sont pas à remplacer par une configuration locale. Les marqueurs opérateur existants ne sont pas modifiés par cette intervention.

### Bingo — lot moteur

```text
ws/bingo_loadtest.js
ws/bingo_reset.js
ws/bingo_server.js
ws/capacity_reads.js
ws/envUtils.js
ws/hub_capacity.js
ws/hub_readiness_runtime.js
ws/hub_test_observer.js
ws/loadtest_metrics.js
ws/repository/base/player_repository.js
ws/repository/db/db_player_repository.js
ws/websocket_server.js
```

Ces adaptations capacité/authentification/reset et diagnostics sont nécessaires au code retenu, avec le nouveau coordinateur. `ws/runtime_expiry.js`, déjà dans la base, doit aussi être présent : import au chargement de `bingo_server.js`. Son absence DEV n’est pas signalée ; vérifier sa présence sans en déduire une nouvelle panne. Redémarrage WS requis après modification du lot. Ne pas recopier Quiz/BT à la place des versions Bingo.

### Global et Games — contrat et surfaces

Global : les deux fichiers applicatifs de la liste historique ci-dessous (`app_games_hub_preparation.php`, `app_games_hubs_functions.php`). Games : tous les fichiers applicatifs de la liste historique ci-dessous, en excluant uniquement `web/tests/**`. Cela inclut les nouveaux modules `core/hub_preparation.js`, `php/hub_readiness.php`, `play/hub_player_readiness.js` et les appelants modifiés.

Dans Games, les reprises du harnais sont `web/includes/bots/hub_bots.js`, les huit `hub_test_*.js` listés plus bas et `web/test_bots.php`. `hub_test_bridge.js` est référencé par le helper Hub ; les autres forment le lot du runner Browser. Les tests automatisés (`tests/**`, `web/tests/**`, `ws/tests/**`) servent à vérifier le workspace et ne sont pas des dépendances du serveur en exploitation. Aucun changement de `play` requis par ce lot.

Cette liste couvre le patch applicatif et les dépendances manquantes connues ; elle ne certifie pas un miroir de tous les fichiers DEV. Les autres modules de base doivent rester présents. La lecture statique récursive des `require` locaux trouve 27 modules Quiz, 29 BT et 29 Bingo, sans dépendance locale manquante ; les dépendances npm, imports dynamiques et état du processus DEV ne sont pas validés par cette vérification.

### Remise en conformité locale Quiz après rechargement

Seul écart applicatif corrigé dans cette intervention : `web/server/actions/connection.js`. Rétablissement de l’identité E1 figée, de la garde sur le même objet runtime et la suspension, de `runtimeExpired` avant I/O et de `notifyRuntimeExpired` avec retry. Le fichier redevient identique à `hub_soiree`/`sas_players`/HEAD readiness ; il disparaît donc du diff Git malgré une vraie correction par rapport à la copie DEV rechargée. Les ajouts readiness des autres fichiers sont conservés.

Validation après correction : `node --test tests/hub-readiness.test.cjs tests/primary-grace.test.cjs` dans Quiz, **61/61 succès**, contre quatre échecs d’expiration avant correction ; `node --check web/server/actions/connection.js` valide. Aucun service, DB, SSH, déploiement ou restart. Journal public AI Studio relu, aucune entrée ciblée contradictoire trouvée. Ces preuves ne démontrent pas la cause du défaut immédiat du sas Quiz : le callback corrigé intervient après une heure de grâce.

Rollback de livraison : restaurer une sauvegarde cohérente des fichiers réellement présents sur DEV avant copie, puis redémarrer le moteur concerné ; un checkout global de `hub_session_readiness` ne restaure pas le patch non committé. Ne pas supprimer un helper encore requis par un appelant restauré.

## Contrat implémenté

### Recette DEV rechargée — compte 10, Hub 348, 23/09 à 15:03–15:05

**Validation partielle seulement. Aucun patch applicatif dans cet audit.** Logs locaux Games/Global/Quiz/BT/Bingo et trois `server-logs.log` lus, sans connexion serveur ou DB. Horaires ci-dessous en Europe/Paris (logs WS UTC +2 h). La précédente recette du compte 11 et les traces plus anciennes sont exclues.

| Jeu | Session | Lancement | Connexions Player | Readiness acceptée | Départ observé |
|---|---|---|---|---|---|
| Bingo | 27964 | 15:03:52.301 (début préparation déduit du timing ready) | 3 binds avant 15:04:01.712 | 1/3, identité Hub 1809 | 15:04:07.540, `window_elapsed`, +15 239 ms ; lecture puis premier track à 15:04:19.582 |
| Blind Test | 27963 | 15:04:31.289 (même méthode) | 3 binds avant 15:04:42.704 | 1/3, identité Hub 1809 | 15:04:46.935, `window_elapsed`, +15 646 ms ; premier signal track à 15:04:59.799 |
| Quiz | 27965 | 15:05:20 (profil de lancement PHP) | 3 binds avant 15:05:28.506 | Aucun `HUB_PLAYER_READY` trouvé pour cette session | Aucun `HUB_GAMEPLAY_START` ni passage `En cours` avant suspension Remote à 15:05:47 |

Preuves locales : `games/logs/error_log` lignes 2042/2143/2262 (création/lancement), 2065/2159/2285 (présence `source=ready`), 2125/2242/2331 (suspensions explicites). `bingo.game/ws/server-logs.log` lignes 16459 (reset déterministe), 16460 (ready), 16476 (décision), 16480 (track). `blindtest/web/server/server-logs.log` lignes 16595 (ready), 16650 (décision), 16651 (`En cours`), 16683 (track). Les trois Players atteignent le jeu et son WS ; le blocage antérieur de redirection Hub Play n’est pas reproduit pour ce run. Aucun départ `all_ready` n’est démontré. Un départ à 1/3 après la fenêtre est conforme au fallback, pas une validation de la convergence de tous les Players.

**Quiz — course bootstrap fortement probable :** `quiz/web/server/server-logs.log` 25390–25400 montre ACK Master à 15:05:24.701, début hydratation à .762, second ACK/already-active à .802/.803 et hydratation terminée à .847. L’unique init journalisé arrive à .751 (ligne 25392), mais aucun `WS_GAME_SESSION_UPDATED` ne suit. Le front émet `ws/registered` avant `sendSessionInit` (`core/ws_effects.js:403`) ; readiness réagit immédiatement avec un poll. `quiz/actions/wsHandler.js:430` peut relancer `registerOrganizer` pendant le premier bootstrap encore en cours. Cette relance remet le lifecycle en chargement ; `hubSuspension.rejectMutation` peut alors rejeter l’init. Sans init appliqué, la playlist initialement vide empêche `hubPreparation.healthy` et donc les preuves/départ. Le rejet direct et le prédicat live ne sont pas journalisés : ce mécanisme reste fortement probable pour la recette, pas une preuve complète de son déroulé interne. Les erreurs initiales `WS_REG_SESSION_NOT_FOUND` sont suivies de binds réussis, donc ne constituent pas le blocage persistant. Quiz et BT ont bien redémarré vers 15:03:09 selon leurs logs.

**Deux Players non prêts dans Bingo/BT :** identité Hub 1809 seule prête ; identités 1808 (guest) et 1807 (EP) connectées mais sans preuve acceptée. Les deux dernières utilisent ChromeOS, la première Android. `play-ws.js:1597` attend `requestAnimationFrame` avant l’ACK : **l’opérateur confirme que les deux Players ChromeOS étaient en arrière-plan tandis que le Player Android était visible.** Cette configuration est cohérente avec les ACK différés en attente d’une frame ; le fallback à 15 s remplit son rôle. Les logs ne contiennent pas toute la séquence proof/ACK ni les callbacks navigateur : le lien précis avec le callback reste une explication fortement étayée, pas une trace directe. Les relectures d’état BT se poursuivent environ toutes les deux secondes sans nouveau ready. Ne pas assimiler trois connexions à trois preuves d’application.

Suite recommandée avant validation du patch : corriger/tester l’ordonnancement bootstrap Quiz (pas de retry concurrent avec le premier bootstrap, init appliqué avant santé runtime), puis qualifier les ACK Player avec visibilité connue et motifs de refus observables. Ne pas supprimer la garde lifecycle ni abaisser artificiellement les critères de santé. Recette `all_ready` à 3/3 puis cas volontairement absent/arrière-plan ; aucune qualification de charge ou d’expiration 1 h ne découle de ce run.

1. Global conserve l’exécution officielle numérique ouverte, y compris runtime `pending`. Une absence de heartbeat n’est pas un critère de création d’E2. Lifecycle, provenance, suspension, expiration, retrait et focus restent opposables ; `HUB_EXECUTION_MISMATCH` reste intact dans les trois moteurs.
2. Sous le verrou Hub existant, un événement `hub_session_preparation` dans `game_events` conserve E1, début, deadline, fenêtre, phase et `reset_operation_id` déterministe. `INSERT IGNORE` et clé dérivée d’E1 rendent le retry stable. Aucun schéma/migration. Un ancien E1 encore pending est marqué explicitement compatible dans son événement de lancement.
3. Le watcher existant rend l’accès Player disponible. Les moteurs valident les Players déjà admis par `hub_readiness/stage=admit` : session/exécution officielle courante, membre actif, mapping actif et participation existante. Ce chemin ne recharge ni commerce, ni stock, ni roster entier. Parcours sans préparation fiable, papier, démo et autonome conservent la capacité historique. Le probe de la page Player n’est plus répété lorsque le mapping Hub fiable existe.
4. Une incarnation moteur et un challenge sont associés au bind courant. Quiz/BT attendent ACK register puis état appliqué ; Bingo attend grille exploitable, état appliqué et preuve post-lecture reset de même génération. La preuve inclut Hub, session numérique/token, E1, incarnation, identité Hub, clé Player, génération et challenge. Le moteur refuse ancien socket, ancienne génération ou mauvais contexte. `player/ready` historique n’est pas utilisé.
5. Le lobby Master historique est visible pendant préparation et affiche le nombre courant prêt/attendu. Le bouton Play est masqué dans ce sas. Aucun CTA additionnel. Les erreurs de transport laissent E1 vivant ; les reprises techniques ne recréent ni fenêtre ni intention.
6. Le Master poll le coordinateur chaque seconde. Global relit l’exécution, le Master courant, les ressources et le roster sous verrous Hub puis admission ; les attendus comprennent les membres actifs encore sans mapping. La décision est `all_ready` ou `window_elapsed`, uniquement avec runtime sain. Révision du roster contrôlée lors de consommation ; une arrivée après décision ne la révoque pas.
7. `consume` conserve une décision `starting`, puis la mutation gameplay autorisée la marque `started`. Contrôles Master/Remote utilisent le même état moteur. Remote ne peut consommer seul la décision ni avancer le gameplay avant ce départ ; ses messages réels `remote_action` Bingo sont filtrés. L’ancien abandon 15 s ne s’applique plus à E1 en préparation ; générations obsolètes restent rejetées.
8. Les retardataires s’hydratent sur l’état courant sans rouvrir le sas. Les compteurs courants perdent les sockets fermées ; le premier succès reste distinct. Les événements `HUB_PLAYER_READY` et `HUB_GAMEPLAY_START` permettent la corrélation par E1 ; le harnais conserve le premier succès par identité, y compris après changement d’incarnation.

L’automatisme suppose le Master connecté et le runtime sain. La borne est une autorisation de départ, observée à la cadence de polling (~1 s), avec latences réseau et intro existante ensuite ; ce n’est pas une promesse temps réel. En cas d’indisponibilité des ressources, reprise automatique sur E1 dès retour de santé.

## Fenêtre, durabilité et Bingo

`HUB_SESSION_CONVERGENCE_MS` est lu côté Global lors de la création de préparation. **15 000 ms par défaut temporaire de recette, non qualifié produit**. Valeur entière entre 1 000 et 120 000 ; configuration invalide refusée. Une modification de configuration ne déplace pas une deadline déjà enregistrée. Retry, reload, nouveaux membres et pertes de connexion ne la réinitialisent pas.

Le reset initial Bingo est préparé avant la preuve finale, via la commande/journal de reset existants et le même operation_id durable. Le chemin historique `game/init` adopte également cet ID. Replay après ACK perdu/reload conserve l’opération ; une préparation déjà `started` ne déclenche plus de reset initial. La décision vérifie reset terminé et génération actuelle. Une création d’exécution sur une partie déjà lancée n’est pas un reset implicite : ce lot initialise le sas sur le runtime pending, puis reprend son journal malgré la phase 1 post-reset.

Le stockage SQL n’est pas dupliqué avec une nouvelle table. La readiness des sockets reste volatile ; après redémarrage moteur, les preuves sont réacquises avec une nouvelle incarnation. La deadline reste SQL. Le premier succès historique entre processus se retrouve dans les événements collectés ; le compteur live n’est jamais restauré depuis les logs.

## Grosses sessions et harnais

Browser : 1–200 sujets, vagues 10/30/50/100 ; Quiz/BT utilisent l’adaptateur ACK/état, Bingo son authentification et sa queue réelles. En mode readiness produit, le diagnostic `hub_test_*` seul ne suffit jamais à compter prêt. Gameplay BT/Bingo reste off ; extension legacy gameplay réservée au Quiz.

Scénarios sélectionnables : simultané, progressif 300 ms, premier essai en échec, reconnexion après readiness, un échec permanent, un retardataire à +20 s. L’évolution du roster et le départ volontaire sont aussi couverts par tests du coordinateur ; recette Browser manuelle avec ajout/retrait d’un membre. La valeur +20 s suppose la fenêtre temporaire de 15 s ; ajuster le harnais si une fenêtre différente est qualifiée.

Bingo : mode froid par défaut dans l’UI, `player_register → grid_assign → grid_hydrate` après access/launch et inclus dans le KPI. Mode prepared séparé, explicitement `allocation_in_kpi=false`. Export distingue grille déjà associée et nouvelle allocation ; nouvelle allocation ne signifie pas nouvelle génération de stock. Le stock global peut être complété sur le chemin réel de lancement/ensure, avant création d’E1 : conserver aussi la timeline depuis le clic Master, pas seulement E1_start.

Le coût de génération du stock n’est pas isolé par un nouveau compteur SQL dans ce lot. Faire deux recettes distinctes stock disponible/stock à compléter, et noter la fixture. Sans accès DB local, requête **en lecture seule à exécuter manuellement** avant/après recette :

```sql
SELECT COUNT(*) AS total, SUM(id_joueur = 0) AS libres,
       SUM(id_joueur <> 0) AS associees
FROM jeux_bingo_musical_grids_clients
WHERE id_playlist_client = :playlist_id AND id_grid_support = 2;
```

Les exports contiennent les timings observés, volumes logiques/HTTP/capacité selon instrumentation active, profondeur/temps de queue Bingo et état du processus uniquement si observateur actif. Le nombre de locks SQL et le coût réel DB ne sont pas mesurables par doubles locaux. Ne pas les déduire du seul nombre d’appels.

`e1_readiness` exporte P50/P90/P95/P99/max des succès observés, individus et décision de départ. Les absents sont comptés séparément ; ces quantiles ne représentent pas 100 % du roster si incomplet. Le calcul soustrait le début Global à l’horloge moteur : synchronisation des horloges requise. Les simulations locales utilisent une horloge injectée et ne qualifient ni fenêtre ni performances réseau/DB/CPU.

## Validation locale

<!-- READINESS-RESULTS:BEGIN -->
Comptage par **fichier de test**, pas par assertion. Exécution isolée PHP/Node ; vagues paramétrées 10/30/50/100.

| Dépôt | Réussis | Exécutés | Échecs restants |
|---|---:|---:|---:|
| games | 95 | 107 | 12 |
| global | 59 | 61 | 2 |
| quiz | 3 | 3 | 0 |
| blindtest | 4 | 5 | 1 |
| bingo.game | 10 | 10 | 0 |

Les 15 fichiers encore en échec étaient déjà en échec sur les snapshots des HEAD de base. Le test BT équipes, après adaptation des mocks asynchrones, reproduit précisément les deux assertions papier en échec sur les deux versions (13/15 sous-tests passent). Les autres erreurs concernent notamment fixtures de rendu/routage déjà divergentes, `pngjs` absent et contrat commercial existant. Ce constat ne remplace pas la couverture bloquée par ces fixtures.

- Protocole nouveau : 8 sous-tests par moteur, 26 assertions endpoint Games, 17 assertions Global, continuation Master, Remote au-delà de 15 s et helper de reset initial Bingo.
- Harnais produit : 24 sous-tests runner et 21 adaptateur Bingo, dont allocation froide et rejet de preuve incorrecte.
- Pipeline Bingo réel avec I/O simulées : 16 sous-tests ; publication BT équivalente sur 10/30/50/100.
- Suspension/reprise temporelle : 72 cas + 3 annulations de grace + 3 coupures ; succès.
- Syntaxe PHP/JS/ESM et `git diff --check` validés ; aucun test de serveur ou de charge réelle.

| Taille | Protocole Quiz/BT/Bingo | Auth Bingo (doubles) | Publication BT |
|---:|---|---|---|
| 10 | OK | 10 auth, 50 lectures SQL simulées, 20 lectures reset, 0 ligne roster dans state | Équivalence OK |
| 30 | OK | 30 auth, 150 lectures SQL simulées, 60 lectures reset, 0 ligne roster dans state | Équivalence OK |
| 50 | OK | 50 auth, 250 lectures SQL simulées, 100 lectures reset, 0 ligne roster dans state | Équivalence OK |
| 100 | OK | 100 auth, 500 lectures SQL simulées, 200 lectures reset, 0 ligne roster dans state | Équivalence OK |

Ces coûts Bingo décrivent la fixture legacy/capacité du pipeline optimisé ; la nouvelle admission ciblée est testée séparément et ne doit pas se voir attribuer ces mêmes compteurs. Quantiles du protocole à horloge injectée : script de progression déterministe, **pas des latences mesurées**. Les P50/P90/P95/P99 réels par jeu/taille, appels HTTP réels, locks SQL et CPU/mémoire restent à collecter en recette.

Fichiers encore en échec :

- `games/web/tests/hub_demo_qr_reentry_contract_test.php` — échec de base reproduit.
- `games/web/tests/hub_master_renewal_eligibility_model_test.php` — échec de base reproduit.
- `games/web/tests/hub_remote_paper_recovery_test.mjs` — échec de base reproduit.
- `games/web/tests/hub_settings_series_dom_test.mjs` — échec de base reproduit.
- `games/web/tests/hub_remote_polling_test.mjs` — échec de base reproduit.
- `games/web/tests/hub_player_qr_image_test.mjs` — échec de base reproduit.
- `games/web/tests/hub_player_qr_server_test.php` — échec de base reproduit.
- `games/web/tests/hub_remote_contract_test.php` — échec de base reproduit.
- `games/web/tests/hub_active_resume_test.php` — échec de base reproduit.
- `games/web/tests/hub_remote_master_ux_test.php` — échec de base reproduit.
- `games/web/tests/hub_session_settings_test.php` — échec de base reproduit.
- `games/web/tests/remote_module_cache_test.mjs` — échec de base reproduit.
- `global/web/tests/schedule_plan_commit_contract_test.php` — échec de base reproduit.
- `global/web/tests/hub_guest_rejoin_test.php` — échec de base reproduit.
- `blindtest/tests/teams-disabled.test.cjs` — échec de base reproduit.
<!-- READINESS-RESULTS:END -->

Commandes sans serveur/DB :

```bash
php global/web/tests/hub_preparation_test.php
php games/web/tests/hub_readiness_test.php
node games/web/tests/hub_preparation_test.mjs
node games/web/tests/hub_preparation_remote_test.cjs
node quiz/tests/hub-readiness.test.cjs
node blindtest/tests/hub-readiness.test.cjs
node bingo.game/ws/tests/hub-readiness.test.cjs
HUB_TEST_POPULATIONS=10,30,50,100 node bingo.game/ws/tests/bingo_auth_pipeline.test.js
HUB_TEST_POPULATIONS=10,30,50,100 node blindtest/web/tests/ranking_publication_index_test.cjs
node games/web/tests/hub_test_runner_test.cjs
node games/web/tests/hub_test_bingo_test.cjs
```

Exécuter depuis le dossier parent Cotton. Les tests PHP utilisent des doubles ; le script `hub_session_membership_dev_diagnostic.php` nécessite une DB et est exclu des contrôles isolés. Les suites agrégées `_suite.mjs` doublonnent les fichiers individuels ; elles ne sont pas comptées une seconde fois. Le vieux `demo.test.js` dépend de Jest et reste distinct des tests node:test. Les tests de comparaison 5 000 conservent leur option par défaut ; les recettes demandées utilisent explicitement 10/30/50/100.

## Livraison, risques et rollback

Pas de commit possible dans le montage `.git` en lecture seule ; pas de contournement ni de clone destiné à prétendre avoir commité les branches originales. Découpage conseillé lors de reprise avec Git inscriptible : Global état E1/API ; moteurs protocole ; Games continuation/lobby/Player ; optimisations et instrumentation via hunks ; harnais/tests ; documentation. Certains fichiers portent plusieurs responsabilités et nécessitent une revue des hunks.

Recette restante avant promotion : navigateur Master/Remote/Players réels, reprises et double onglet, 10/30/50/100 par jeu, froid/chaud Bingo et coût de génération du stock, synchronisation d’horloges, quantification HTTP/locks/DB. La fenêtre produit reste à choisir sur mesures réelles. Les contrôles publics PHP legacy encore lourds sont conservés ; le découplage ciblé concerne le bind WS déjà admis et le probe navigateur fiable.

Rollback coordonné des fichiers des cinq dépôts vers les HEAD du tableau, en conservant les journaux `game_events` ; aucune suppression de données recommandée. Ne pas redescendre isolément un moteur/API/frontend sur une session de préparation active : protocole version 1 réparti entre ces composants. La syntaxe validée et les doubles ne remplacent pas une recette distribuée.

## Fichiers modifiés par dépôt

### global

- `web/app/modules/jeux/hubs/app_games_hub_preparation.php`
- `web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- `web/tests/hub_paper_resume_reconciliation_test.php`
- `web/tests/hub_preparation_test.php`
- `web/tests/hub_remote_control_contract_test.php`

### games

- `web/games_ajax.php`
- `web/includes/bots/hub_bots.js`
- `web/includes/bots/hub_test_bingo.js`
- `web/includes/bots/hub_test_bridge.js`
- `web/includes/bots/hub_test_browser.js`
- `web/includes/bots/hub_test_cleanup.js`
- `web/includes/bots/hub_test_core.js`
- `web/includes/bots/hub_test_quiz.js`
- `web/includes/bots/hub_test_quiz_gameplay.js`
- `web/includes/bots/hub_test_ui.js`
- `web/includes/canvas/core/boot_organizer.js`
- `web/includes/canvas/core/hub_preparation.js`
- `web/includes/canvas/core/session_sync.js`
- `web/includes/canvas/core/ws_connector.js`
- `web/includes/canvas/core/ws_effects.js`
- `web/includes/canvas/php/bingo_adapter_glue.php`
- `web/includes/canvas/php/boot_lib.php`
- `web/includes/canvas/php/hub_lifecycle.php`
- `web/includes/canvas/php/hub_readiness.php`
- `web/includes/canvas/play/hub_player_readiness.js`
- `web/includes/canvas/play/play-ws.js`
- `web/includes/canvas/play/register.js`
- `web/modules/app_hub_remote_ajax.php`
- `web/modules/app_hub_view_helpers.php`
- `web/organizer_canvas.php`
- `web/player_canvas.php`
- `web/test_bots.php`
- `web/tests/bot_admission_order_test.cjs`
- `web/tests/hub_active_resume_test.mjs`
- `web/tests/hub_capacity_cohort_test.cjs`
- `web/tests/hub_capacity_runtime_test.cjs`
- `web/tests/hub_capacity_transport_test.cjs`
- `web/tests/hub_launch_confirmation_test.mjs`
- `web/tests/hub_master_mobile_actions_test.mjs`
- `web/tests/hub_preparation_bingo_reset_test.cjs`
- `web/tests/hub_preparation_remote_test.cjs`
- `web/tests/hub_preparation_test.mjs`
- `web/tests/hub_readiness_test.php`
- `web/tests/hub_runtime_suspension_time_test.cjs`
- `web/tests/hub_suspend_test.mjs`
- `web/tests/hub_test_bingo_test.cjs`
- `web/tests/hub_test_cleanup_test.cjs`
- `web/tests/hub_test_gameplay_test.cjs`
- `web/tests/hub_test_runner_test.cjs`
- `web/tests/paper_score_runtime_test.cjs`
- `web/tests/ws_loadtest_harness_test.cjs`
- `web/tests/ws_loadtest_instrumentation_test.cjs`

### quiz

- `tests/hub-readiness.test.cjs`
- `tests/primary-grace.test.cjs`
- `tests/remote-continuity.test.cjs`
- `web/server/actions/capacity_reads.js`
- `web/server/actions/envUtils.js`
- `web/server/actions/gameplay.js`
- `web/server/actions/hubCapacity.js`
- `web/server/actions/hubPreparation.js`
- `web/server/actions/hub_readiness_runtime.js`
- `web/server/actions/hub_test_observer.js`
- `web/server/actions/loadtest.js`
- `web/server/actions/loadtest_metrics.js`
- `web/server/actions/registration.js`
- `web/server/actions/wsHandler.js`
- `web/server/logger_v1.js`
- `web/server/messaging.js`

### blindtest

- `tests/hub-readiness.test.cjs`
- `tests/primary-grace.test.cjs`
- `tests/remote-continuity.test.cjs`
- `tests/teams-disabled.test.cjs`
- `web/server/actions/capacity_reads.js`
- `web/server/actions/envUtils.js`
- `web/server/actions/gameplay.js`
- `web/server/actions/hubCapacity.js`
- `web/server/actions/hubPreparation.js`
- `web/server/actions/hub_readiness_runtime.js`
- `web/server/actions/hub_test_observer.js`
- `web/server/actions/loadtest.js`
- `web/server/actions/loadtest_metrics.js`
- `web/server/actions/registration.js`
- `web/server/actions/wsHandler.js`
- `web/server/logger_v1.js`
- `web/server/messaging.js`
- `web/tests/ranking_publication_index_test.cjs`

### bingo.game

- `ws/bingo_loadtest.js`
- `ws/bingo_reset.js`
- `ws/bingo_server.js`
- `ws/capacity_reads.js`
- `ws/envUtils.js`
- `ws/hub_capacity.js`
- `ws/hub_readiness_runtime.js`
- `ws/hub_test_observer.js`
- `ws/loadtest_metrics.js`
- `ws/repository/base/player_repository.js`
- `ws/repository/db/db_player_repository.js`
- `ws/tests/bingo_auth_pipeline.test.js`
- `ws/tests/hub-readiness.test.cjs`
- `ws/tests/hub_suspend.test.js`
- `ws/tests/runtime_expiry.test.js`
- `ws/websocket_server.js`
