# Suspension Hub officielle — patch local du 10 septembre 2026

<!-- AUTO-UPDATE:BEGIN id="hub-suspend-report-20260910" owner="codex" -->

Statut : patch dans les worktrees, **non déployé**. Aucun service démarré/redémarré, aucune DB réelle ouverte, aucune migration, aucun commit/push. Journal AI Studio et entrées documentaires raw consultés avant modification. Les contrôles ci-dessous sont hors connexion, avec effets DB/HTTP/sockets/horloge simulés lorsque nécessaire.

## Contrat et ordre

Uniquement sous `isOfficialHubOrchestrated()` : confirmation « Suspendre la partie ? », CTA Annuler/Suspendre et phrase soirée/événement issue du resolver existant. `quitGame` transporte `intent=hub_suspend`, `execution_id`, `source_session_id`, `runtime_session_id`, `request_id`.

Le primary courant reste l’autorité WS. La Remote relaye au Master, sans seconde confirmation. Le service Canvas vérifie le jeu, le Hub, les IDs source/runtime officiels, l’exécution ouverte, la provenance brute existante et l’absence de terminal. Une intention invalide est refusée sans fallback destructeur. Le moteur ne transmet pas un `event_id` fourni par le navigateur aux étapes du bridge.

Ordre : validation → Pause → marqueur mémoire suspendu → journal confirmé → `HUB_SUSPEND_ACK` → clear focus conditionnel → marqueur de libération → `HUB_SESSION_SUSPENDED` → navigation. L’ACK d’envoi WS seul n’autorise pas le retour. Les erreurs restent sur la surface ; une nouvelle tentative réutilise le request ID métier. Une libération partiellement échouée reste gelée et se réessaie sans terminal. Les opérations lifecycle sont sérialisées par runtime ; les actions déjà engagées avant la confirmation ne sont pas annulées globalement.

## Conservation et gel

- Quiz/Blind Test : même objet `sessions[token]`, même roster, scores, progression, verrous de réponses et équipes BT. Les closes suspendus détachent seulement les sockets ; aucune désactivation des participants DB, aucune grâce ni suppression orpheline. Après reprise, seuls les ACK primary transportent le snapshot vivant complet ; il n’est pas envoyé aux Players. Le Master applique playlist/index/temps restant avant la synchronisation, puis reste en Pause.
- Bingo : mêmes Maps/clé `idPlaylistClient`, joueurs et progression. Les vérifications, winners, commandes Remote, reset et fin sont bloqués. Une collision avec un runtime conservé est refusée avant réaffectation. Le registre historique remplace la Remote précédente et conserve une Remote courante par jeu ; toutes les surfaces encore attachées reçoivent le signal non terminal.
- Le garde WS s’applique aux nouvelles mutations et inscriptions. `game_api_dispatch` bloque aussi scores, phases, grilles, inscriptions/désactivations, progression/reset/finalisation. Quiz/BT contrôlent également le token résolu depuis la vraie clé historique des scores, même si le payload propose un autre token. Bingo contrôle aussi le scope playlist de l’action legacy `grid_get_or_assign`.
- Pas de `SESSION_ENDED`, de `sessionEndedGames` pour la suspension, de fin naturelle, de podium, de reset ni de nouvelle injection Hub.

Master utilise `resolveQuitRedirect()` après confirmation métier et libération du focus. Remote valide exécution/runtime, supprime le reconnect et utilise sa destination Hub existante. Play conserve son observateur de présentation/focus existant. Les présences sont purgées à suspension et reprise ; les heartbeats suspendus ou d’une ancienne génération sont refusés. Le routing reste non joinable tant que le journal marque la suspension, même si une présence stale existe.

## Reprise et concurrence

`existing` conserve l’`execution_id`, réactive conditionnellement le focus et publie la nouvelle génération. Un jeton de reprise est lié à la suspension et à cette génération ; seul son échange service validé dégele le moteur. Une simple URL/reconnexion ne suffit pas. Une reprise n’est autorisée qu’après la libération de la suspension. Les commandes anciennes pending/claimed/processing sont annulées, puis leur statut est vérifié à l’entrée du launch Remote.

A suspendue → B terminée/focus libre → reprise A : autorisée dans la fenêtre. A suspendue → B active : refus, y compris par condition SQL de mise à jour du focus. Plusieurs suspensions avec identités distinctes coexistent. Une suspension avant la première écriture périodique conserve la projection runtime `running` depuis sa preuve d’exécution ; elle n’est pas convertie en runtime `new` avec réinjection.

La branche historique de grâce Santeuil reste inchangée : seul un close avec runtime suspendu suit le nouveau détachement. Hors exécution officielle prouvée, modale/quit/cleanup/désactivations/QR et démos suivent leurs chemins existants.

## Fenêtre, journal et maintenance

Source canonique : `app_games_hub_temporal_state()` / `app_temporal_window_state()`, `hub_date`, Europe/Paris, J00:00 inclus à J+1 midi exclu. Les chemins Master et Remote ne dispensent plus une exécution officielle `existing/open_execution` du garde. Les créations/recréations officielles restent refusées après cutoff. L’inscription après restart vérifie également la fenêtre.

`game_events` stocke uniquement `hub_suspended`, `hub_suspend_released`, `hub_resume_requested`, `hub_resumed` avec identités, request ID, cutoff et autorisation/génération de reprise. Aucun nouveau statut DB, TTL de suspension, daemon ou snapshot durable complet.

Les boucles existantes (heartbeat Quiz/BT 30 s, maintenance Bingo 1 s) examinent les suspensions. Après cutoff, si l’identité est toujours la même et qu’aucune reprise/lifecycle n’est en cours, elles ferment/détachent les sockets et libèrent runtime, compteurs, timers et caches concernés. Aucune fin naturelle ou écriture de résultat artificielle. Le refus de reprise dépend du cutoff serveur, pas de la ponctualité du cleanup. Les accès Hub relisent le journal pour la projection/routing ; il n’existe pas d’API Hub prétendant supprimer à distance une mémoire WS.

## Restart et limites réelles

Sans restart, l’état vivant reste autoritaire. Après restart, seules les données déjà persistées et le preload existant sont récupérables : scores/participants et progression persistée, sans garantie sur la dernière écriture encore en vol, les verrous/états éphémères, ni la position média à la frame près. La playlist BT conserve la reconstruction déterministe existante. Le marqueur empêche un restart de transformer une suspension en gameplay libre ou de contourner le cutoff.

La vérification initiale lifecycle requiert le bridge service ; une erreur n’est pas traitée comme absence de suspension. Global, Games et les trois moteurs doivent utiliser le même protocole. Les markers sont préparés à `restart 10-09-2026/01`, sans copie ou redémarrage exécuté. Aucun navigateur/WS/API/DB réel n’était disponible pour cette intervention : une recette connectée reste nécessaire avant de déclarer le contrat livré.

## Matrice de validation demandée

| Cas utilisateur | Preuves locales | Limite |
|---|---|---|
| 1–5 : Master/Remote, Quiz/BT/Bingo, papier/numérique | `hub_suspend_test.mjs`, `bingo.game/ws/tests/hub_suspend.test.js` : protocole, authority/relay et handlers WS réels isolés | Pas de clic navigateur ni service réel |
| 6–11 : roster/actifs/scores/progression, aucune grâce/suppression | Nouveaux cas des deux `primary-grace.test.cjs`, tests lifecycle et closes Bingo | Writes DB simulés ; aucun état DB réel certifié |
| 12–16 : focus/statut et retours Master/Remote/Play, Remote non initiatrice | Tests PHP focus/projection, handlers de navigation exécutés en VM, observateur Play existant | Navigation simulée |
| 17–18 : nouvelles mutations bloquées, opérations engagées conservées | Handlers WS réels et dispatch PHP central ; promesse en vol dans le contrôleur | Pas d’injection de fautes réseau réelle |
| 19–21 : `existing`, dégel explicite, présence exacte, anti-rebond | Lifecycle, active-resume, presence/routing/automatic-return ; snapshot/minuteur vivant | SQL/HTTP simulés |
| 22–24 : A→B→A, B active, coexistence/collision Bingo | Focus réel isolé avec CAS simulé ; contrôleur plusieurs runtimes ; collision Bingo | Pas de stress multiclient réel |
| 25–26 : cutoff et anciennes exceptions | `temporal_window_state_test.php`, `hub_suspend_contract_test.php`, contrats Remote | Horloge simulée, dont DST Paris |
| 27–28 : cleanup/restart | Sweep et dispose isolés ; lecture persistante/refus de grant/cutoff simulés | Pas de restart réel ; restauration best-effort documentée |
| 29–32 : historique/Santeuil/démos/QR | Suites existantes grâce, quit Bingo, legacy routes, demo readiness/surfaces/reentry et player QR | Régression locale uniquement |

## Tests exécutés

Les commandes PHP ci-dessous sont des fixtures hors connexion. Les tests Node exécutent les contrôleurs et plusieurs handlers réels avec frontières externes simulées. Résultats de la dernière passe :

**32/32 suites réussies.**

### global

```bash
php web/tests/temporal_window_state_test.php
php web/tests/hub_suspend_contract_test.php
php web/tests/hub_terminal_provenance_test.php
php web/tests/hub_remote_control_contract_test.php
php web/tests/hub_client_routing_canonical_test.php
php web/tests/hub_player_qr_temporal_test.php
```

### games

```bash
php web/tests/hub_suspend_test.php
php web/tests/hub_active_resume_test.php
php web/tests/hub_remote_contract_test.php
php web/tests/hub_remote_presence_read_test.php
php web/tests/hub_demo_runtime_surfaces_test.php
php web/tests/hub_legacy_entry_routes_test.php
php web/tests/hub_individual_terminal_master_test.php
php web/tests/hub_demo_readiness_flow_test.php
php web/tests/hub_launch_confirmation_contract_test.php
node --test web/tests/hub_suspend_test.mjs
node --test web/tests/hub_active_resume_test.mjs
node --test web/tests/hub_transition_remote_test.mjs
node --test web/tests/hub_remote_presence_test.mjs
node --test web/tests/hub_remote_automatic_return_test.mjs
node --test web/tests/hub_remote_return_execution_test.mjs
node --test web/tests/hub_remote_polling_test.mjs
node --test web/tests/hub_remote_ws_retry_test.mjs
node --test web/tests/hub_launch_confirmation_test.mjs
node --test web/tests/hub_demo_reentry_runtime_test.mjs
node --test web/tests/hub_player_qr_test.mjs
```

### quiz

```bash
node --test tests/primary-grace.test.cjs
```

### blindtest

```bash
node --test tests/primary-grace.test.cjs
```

### bingo.game

```bash
node --test ws/tests/hub_suspend.test.js
node --test ws/tests/bingo_quit_guard.test.js
node --test ws/tests/bingo_terminal_delivery.test.js
node --test ws/tests/bingo_phase_progress.test.js
```

Syntaxe des 50 fichiers PHP/JS modifiés contrôlée sans charger les applications ; `git diff --check` sur les cinq repos applicatifs. Les counts internes des suites ne doivent pas être confondus avec des scénarios E2E réels.

## Fichiers applicatifs modifiés

### global

- `web/app/modules/jeux/hubs/app_games_hub_suspension.php`
- `web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- `web/tests/hub_suspend_contract_test.php`

### games

- `web/games_ajax.php`
- `web/includes/canvas/core/boot_organizer.js`
- `web/includes/canvas/core/end_game.js`
- `web/includes/canvas/core/hub_runtime_authority.js`
- `web/includes/canvas/core/timer_engine.js`
- `web/includes/canvas/core/ws_connector.js`
- `web/includes/canvas/core/ws_effects.js`
- `web/includes/canvas/php/boot_lib.php`
- `web/includes/canvas/php/hub_lifecycle.php`
- `web/includes/canvas/remote/remote-ui.js`
- `web/includes/canvas/remote/remote-ws.js`
- `web/modules/app_hub_view_helpers.php`
- `web/organizer_canvas.php`
- `web/remote_canvas.php`
- `web/tests/hub_active_resume_test.mjs`
- `web/tests/hub_active_resume_test.php`
- `web/tests/hub_demo_readiness_flow_test.php`
- `web/tests/hub_launch_confirmation_test.mjs`
- `web/tests/hub_remote_contract_test.php`
- `web/tests/hub_suspend_test.mjs`
- `web/tests/hub_suspend_test.php`

### quiz

- `tests/primary-grace.test.cjs`
- `web/server/actions/audioControl.js`
- `web/server/actions/connection.js`
- `web/server/actions/envUtils.js`
- `web/server/actions/gameplay.js`
- `web/server/actions/hubLifecycle.js`
- `web/server/actions/hubSuspension.js`
- `web/server/actions/playerCount.js`
- `web/server/actions/registration.js`
- `web/server/actions/wsHandler.js`
- `web/server/restart_serveur.txt`
- `web/server/server.js`

### blindtest

- `tests/primary-grace.test.cjs`
- `web/server/actions/audioControl.js`
- `web/server/actions/connection.js`
- `web/server/actions/envUtils.js`
- `web/server/actions/gameplay.js`
- `web/server/actions/hubLifecycle.js`
- `web/server/actions/hubSuspension.js`
- `web/server/actions/playerCount.js`
- `web/server/actions/registration.js`
- `web/server/actions/wsHandler.js`
- `web/server/restart_serveur.txt`
- `web/server/server.js`

### bingo.game

- `version.txt`
- `ws/bingo_server.js`
- `ws/envUtils.js`
- `ws/hub_lifecycle.js`
- `ws/tests/hub_suspend.test.js`

## Documentation et suite

README/TASKS des cinq repos, HANDOFF, interfaces actions/bridge, write map Bingo, notes markers/PM2/runbook et CHANGELOG actualisés. Sitemap et INDEX générés avec le script officiel en conservant la branche locale main. Cela ne publie pas la documentation ni le code.

Réserves restantes : recette connectée, observation des requêtes réellement persistées et essai de restart sur un environnement dédié. Aucun reset « Relancer depuis le début » implémenté ; les identités exécution/suspension/génération restent distinctes pour cette évolution future.

Retour arrière éventuel : traiter ce patch comme un ensemble cohérent Global/Games/moteurs. Une ancienne version moteur ignore le marqueur de suspension ; un retour partiel pendant des suspensions actives casserait le contrat. Aucun rollback ni déploiement exécuté ici.

## Correction du timeout remonté le 11 septembre

Les logs rechargés établissent le défaut du relais : `blindtest/web/server/server-logs.log` lignes2024–2027,2054,2246–2249 montrent le type `remoteQuitRequest` entrant côté Master, au lieu de `quitGame` (09:19:29,09:19:39 et09:21:22 Europe/Paris). Le log Games n’enregistre qu’un appel `hub_lifecycle` au bootstrap à09:18:48 ; aucune étape de suspension ne parvient au bridge pendant cette séquence. Le code du dispatcher refuse ce type depuis le primary ; sa réponse sans `execution_id` échouait au filtre de corrélation du Master.

Correction : `end_game.js` conserve seulement intent, execution/source/runtime/request IDs, puis ajoute sessionId et forced=false. Une nouvelle tentative mémorise ce payload nettoyé. Le transport partagé et les quits historiques restent inchangés. Quiz, Blind Test et Bingo renvoient les identifiants execution/runtime dans les refus d’autorisation. Markers des trois moteurs : `restart 11-09-2026/01`.

Le test du relais Quiz/BT utilisait auparavant un mock transformant directement le type en `quitGame`, ce qui masquait le défaut. Il exécute maintenant la vraie fonction `audioControl.remoteQuitRequest`, le Master, la sérialisation du connecteur, le dispatcher et le lifecycle. Les transports externes restent simulés. Deux cas couvrent les enveloppes Quiz/BT et Bingo et la nouvelle tentative ; un cas Bingo vérifie les refus corrélés.

Validation du correctif : 9 fichiers de tests, 135 résultats TAP verts. Depuis chaque repo :

```sh
# Games : 33 + 3 résultats
node --test web/tests/hub_suspend_test.mjs web/tests/hub_active_resume_test.mjs web/tests/hub_transition_remote_test.mjs web/tests/hub_remote_return_execution_test.mjs
# Quiz puis Blind Test : 46 chacun
node --test tests/primary-grace.test.cjs
# Bingo : 7 résultats
node --test ws/tests/hub_suspend.test.js ws/tests/bingo_quit_guard.test.js ws/tests/bingo_terminal_delivery.test.js
```

Recette DEV restante après diffusion : suspendre depuis la Remote, vérifier Pause/conservation et retour Master/Remote au Hub, puis reprendre la même exécution en Pause. Vérifier aussi le clic Master et un refus réel sans timeout. Aucun déploiement/restart réalisé ici ; ne pas redémarrer un runtime vivant à conserver pour cette recette. Rollback limité aux changements du 11/09, sans annuler le patch de suspension antérieur ni les autres modifications présentes.

## Retour Play — complément du 11 septembre

11/09/2026 — Retour Play après suspension : `active_launched_session` peut conserver `presentation.target=session` sur la session suspendue tout en renvoyant `session:null`. Le Player utilise désormais cette absence explicite de session active pour revenir au Hub, indépendamment de la sélection de présentation. `player_unresolved` et un champ absent ne prouvent pas une perte de focus. Isolation démo et garde visuelle terminale conservées ; polling existant de15s et contrôles de premier plan inchangés.

Logs Games09:37:17,09:37:24 et09:37:32 : focus nul, sélection persistante27802 ; le navigateur reste en session. La sélection de présentation et le focus sont intentionnellement distincts. Le correctif frontend couvre la réponse réelle du getter Global (session nulle avec présentation conservée), sans modifier ce contrat serveur ni forcer la présentation du Hub.

Validation : test de régression exécuté en mémoire avec l’ancien contrôle → échec attendu sur ce cas ; version corrigée → succès. Dix combinaisons couvrent session active/nulle, absence du champ, joueur non résolu, présentation Hub et isolation démo. Commandes depuis Games :

```sh
node --test web/tests/hub_suspend_test.mjs web/tests/hub_demo_player_presentation_test.mjs web/tests/hub_transition_remote_test.mjs
php web/tests/hub_presentation_runtime_separation_test.php
```

35 résultats TAP et contrat PHP verts ; syntaxe/diff vérifiés. Recette DEV après diffusion du fichier Play et rechargement du Player : suspendre en conservant la présentation sur la session ; retour Hub Play au prochain polling (intervalle15s, dépend du navigateur/réseau), puis reprise même session. Aucun serveur WS modifié ni marker incrémenté dans ce complément. Rollback : retirer uniquement le nouveau contrôle `noActiveSession`, ce qui rétablit le défaut ; ne pas annuler les autres modifications présentes.

## Retour immédiat Player par WebSocket — 11 septembre

11/09/2026 — Retour Play immédiat autorisé : Quiz/Blind Test/Bingo incluent désormais les sockets Players de la session dans les destinataires de `HUB_SESSION_SUSPENDED`, émis uniquement après succès de release/clear focus. Le handler Play valide contexte officiel, execution_id, runtime_session_id, token sessionId et request_id non vide ; il bloque les reconnects et revient directement au Hub Play, une seule fois, sans flux terminal. Les démos et signaux obsolètes sont ignorés. Le polling15s corrigé reste en secours ; une réponse HTTP déjà en vol ne provoque pas de seconde navigation.

Cette évolution remplace le polling comme chemin principal ; aucune réduction de son intervalle. Extension des destinataires dans les adaptateurs lifecycle Quiz/Blind Test et le constructeur Bingo ; le protocole et son ordre ACK→release→signal restent identiques. Les closes suspendus existants détachent les sockets sans désactiver le roster. Les refus lifecycle sont également diffusés aux destinataires, sans handler de navigation Player pour ces erreurs.

Validation locale : 133 résultats TAP verts ; Games34, Bingo6, grâce Quiz46, grâce Blind Test46, isolation Player démo1. Les tests exécutent le handler Play, le dispatch Quiz/Blind Test réel, et le sélecteur de destinataires Bingo réel avec release différé ou refusé. Vérifications des identités obsolètes, doublons, séparation des jeux Bingo et conservation du roster. Commandes depuis les repos correspondants :

```sh
# Games
node --test web/tests/hub_suspend_test.mjs web/tests/hub_demo_player_presentation_test.mjs
# Bingo
node --test ws/tests/hub_suspend.test.js
# Quiz puis Blind Test
node --test tests/primary-grace.test.cjs
```

Markers : `restart 11-09-2026/02` pour les trois moteurs. Aucun redémarrage ni déploiement exécuté. Recette DEV : charger le Player avec le nouveau frontend, suspendre depuis Master/Remote, vérifier retour à réception du signal sans attendre le polling, puis reprise avec roster/progression conservés. Activer le nouveau code WS dans une fenêtre adaptée : le redémarrage perd l’état vivant non persisté selon la limite déjà documentée. Rollback de cette seule évolution : retirer le handler et les Players des destinataires lifecycle ; le retour par polling reste opérationnel.

## Reprise papier — garde du Master corrigé le 11 septembre

11/09/2026 — Reprise Quiz papier : suppression du filtre `flag_controle_numerique != 0` dans le garde `$HUB_RESUME_EXISTING` de Games `organizer_canvas.php`. Une reprise officielle papier autorisée suit désormais le même chemin que le numérique ; contexte activé, exécution exacte, focus actif, runtime running et génération exacte restent obligatoires. Le dégel WS exige toujours son autorisation de reprise.

Preuve logs : Hub319/session27805, GET Master avec paramètres de reprise à09:49:10,09:49:29 et09:49:54 →302 puis Hub200 ; aucune registration Quiz après la suspension09:48:58. Le filtre numérique rejetait une reprise serveur légitime avant ouverture WS, expliquant le retour silencieux au Hub. Aucun assouplissement des grants ou du cutoff.

La matrice du vrai garde PHP échoue avant patch sur `organizer paper/digital 0 valid`, puis passe avec papier et numérique, en refusant mauvaise exécution/génération/focus, runtime terminal, démo ou contexte désactivé. Validation depuis Games :

```sh
php web/tests/hub_active_resume_test.php
node --test web/tests/hub_active_resume_test.mjs web/tests/hub_suspend_test.mjs
php web/tests/hub_legacy_entry_routes_test.php
```

56 contrôles PHP et35 résultats TAP verts ; anciennes routes OK. Aucun changement moteur ni marker WS. Recette DEV : diffuser `organizer_canvas.php`, reprendre depuis le Hub, attendre Master en Pause et vérifier scores/progression. Rollback limité à rétablir la condition numérique supprimée (réintroduit le défaut), sans annuler les autres changements présents.

<!-- AUTO-UPDATE:END id="hub-suspend-report-20260910" -->
