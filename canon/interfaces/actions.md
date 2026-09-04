> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Actions (Canvas / Bridge)

> Contractual registry of actions and where they are handled.

## Conventions (humain)
- Les actions doivent rester stables et documentées ici dès qu’elles sont ajoutées/modifiées.
- **Convention stable de nommage** (sans espaces) :
  - Le champ `action` est en **lowercase** et en **snake_case** (`[a-z0-9_]+`), ex: `session_update`, `players_get`, `case_click`.
  - Une forme *alias* `game:action` est tolérée (ex: `bingo:case_click`) **sans espaces** et uniquement si `game` correspond au préfixe.
  - Ne jamais écrire `bingo: case_click` (avec espace) : c’est une erreur de doc/usage (le bridge va `trim()` mais ce format ne doit pas exister côté clients).
- **Côté bridge** : si `action` est `bingo:xxx` et `game=bingo`, le préfixe est **retiré** avant dispatch (`xxx` est envoyé à `game_api_dispatch()`).

<!-- AUTO-UPDATE:BEGIN id="actions-list" owner="codex" -->
# Actions “canon” (dispatch `game_api_dispatch`)

## Bingo (`bingo_api_*`)
- `bingo:deactivate_player` — `games/web/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:end_game` — `games/web/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:grid_assign` — `games/web/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:grid_cells_sync` — `games/web/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:grid_hydrate` — `games/web/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:grid_lines` — `games/web/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:phase_winner` — `games/web/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:player_register` — `games/web/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:players_get` — `games/web/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:reset` — `games/web/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:resetdemo` — `games/web/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, payload)`
- `bingo:session_update` — `games/web/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, payload)`

Note compteur runtime: pour Bingo, Quiz et Blind Test, `players_get` filtre les joueurs actifs par défaut; `includeInactive` est réservé aux lectures terminales/historiques. Les réhydratations `canvas_display.js` déclenchées en session active (`session/init`, `game/started`, `game/paused`, retour mobile organizer) ne doivent pas envoyer ce flag.

Note format court: `id_jeu_bingo_musical_format=5` est mappe comme une grille 3x3 pour les actions de grille Bingo existantes, sans nouvelle action Canvas.

## Blindtest (`blindtest_api_*`)
- `blindtest:deactivate_player` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`
- `blindtest:player_register` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`
- `blindtest:players_get` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`
- `blindtest:resetdemo` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, payload)`
- `blindtest:session_primary_id` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`
- `blindtest:session_update` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, payload)`
- `blindtest:update_score` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`

Note format court: le resolver Blind Test lit `championnats_sessions.id_format`; `id_format=5` limite le preload a 20 morceaux deterministes depuis la playlist source, sans nouvelle action Canvas.
Note equipes runtime: `blindtest:session_update` conserve `podium_json` et accepte un classement final optionnel (`players`, `rankings` ou `finalRankings`). Les entrees equipe sont persistées dans `blindtest_session_teams` quand la table existe; l'absence de table est non bloquante. Depuis le 2026-07-07, une entree n'est equipe que si `teamMemberCount` / `members` indique au moins 2 membres runtime; une equipe préparée restée seule est transmise comme joueur solo.

### Blindtest WS runtime-only (hors Canvas bridge)
- `paper_finalize_end` — Remote → WS; requête idempotente avec `sessionId` + `event_id`. Elle appelle `finalizePaperScores()` et ne constitue jamais un terminal Master.
- `paper_score_finalization_state` — WS outbound organizers; expose `finalizing_scores`, `completed` ou le retour `awaiting_score_validation` avec `result/reason`, sans remplacer la preuve HTTP de persistance.
- `remoteQuitRequest` — Remote historique → WS → Organizer primaire; demande volontaire confirmée côté Remote. Le serveur relaie uniquement au primary Organizer, qui exécute le contrat Master `endSession(..., serverLogout=true)`. Si aucun primary n'est connecté, le serveur renvoie `remoteQuitUnavailable` à la Remote.
- `teamCreate` — `blindtest/web/server/actions/teams.js` — cree une equipe runtime pour la session courante.
- `teamJoin` — `blindtest/web/server/actions/teams.js` — rattache le joueur canonique a une equipe runtime.
- `teamJoinByCode` — `blindtest/web/server/actions/teams.js` — rattache le joueur canonique a une equipe runtime via son code court.
- `teamLeave` — `blindtest/web/server/actions/teams.js` — retire le joueur de son equipe runtime avant demarrage.
- `teamList` — `blindtest/web/server/actions/teams.js` — renvoie l'etat `teamState`.
- `teamState` — WS outbound — liste publique des equipes, `teamPlayers`, `playerTeamId`, `maxPlayers`, `locked`; `teamCode` est renseigne uniquement pour l'equipe du joueur destinataire.
- `teamError` — WS outbound — refus runtime (`TEAM_FULL`, `TEAM_LOCKED_AFTER_START`, etc.).
- `updatePlayers` / `endGame` player — WS outbound — en Blind Test equipe, `totalPlayers` reste le nombre de joueurs connectes reels, `rankingEntriesTotal` porte le nombre de participants de classement (equipes de 2+ membres + solos), et `isTeam` indique si l'entree finale du joueur est une equipe valide.

Contraintes: les actions create/join/leave restent runtime WS et sont autorisees uniquement en `En attente`, avant `mainPlayerStarted`, avec master primaire ouvert; max 6 membres par equipe; code court unique dans la session, invalide quand l'equipe devient vide. En lobby, une equipe préparée à 1 membre reste visible et rattachée au membre restant. Au classement runtime, une equipe compte seulement a partir de 2 membres présents. La persistance DB est limitee au snapshot final via `blindtest:session_update`.

## Quiz (`quiz_api_*`)
- `quiz:deactivate_player` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`
- `quiz:player_register` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`
- Les trois handlers `player_register` acceptent une adoption d'identité uniquement pendant l'injection Hub papier serveur: une ligne runtime unique au pseudo exact peut recevoir la clé Hub canonique, sans recréation de ligne ni mutation de score/grille/gains. Tout appel navigateur ordinaire conserve les gardes d'unicité historiques.
- Précondition interne Hub papier: avant la boucle, `canvas_historical_session_ensure_for_game(...)` assure et relit le parent Quiz/Blind Test une seule fois. Bingo effectue uniquement une validation de `championnats_sessions`. Cette abstraction n'ajoute aucune action dispatchée et ne modifie aucun payload/résultat public `player_register`.
- `quiz:players_get` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`
- `quiz:resetdemo` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, payload)`
- `quiz:session_primary_id` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`
- `quiz:session_update` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, payload)`
- `quiz:update_score` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`

### Quiz WS runtime-only (hors Canvas bridge)
- `paper_finalize_end` — Remote → WS; requête idempotente avec `sessionId` + `event_id`, traitée par `finalizePaperScores()` sans relais terminal local au Master.
- `paper_score_finalization_state` — WS outbound organizers; état de la finalisation, utilisé pour bloquer le double clic ou restaurer la revue après échec.
- `remoteQuitRequest` — Remote historique → WS → Organizer primaire; demande volontaire confirmée côté Remote. Le serveur relaie uniquement au primary Organizer, qui exécute le contrat Master `endSession(..., serverLogout=true)`. Si aucun primary n'est connecté, le serveur renvoie `remoteQuitUnavailable` à la Remote.

### Bingo WS finalisation papier
- `admin_phase_winner` sans joueur avance `phase_courante` comme index 0-based dans la `phases_liste` complète, dont l'index 0 est le sentinelle pré-partie. Il ne persiste aucun gagnant; `BINGO_MANUAL_PHASE_ADVANCE` journalise la grille, les lignes 0-based et l'index avant/après.
- La dernière validation `admin_phase_winner` persistée avec `next_phase=-1` déclenche le handler serveur `end_game` même si aucun Master n'est connecté.
- Remote et Master sont coalescés par un verrou en vol; `paper_score_finalization_state` signale l'échec, tandis que `HUB_SESSION_FINISHED` n'est émis qu'après `bingo:end_game` puis completion Hub confirmés.
- `remote_action=remote_quit_request` — Remote historique → WS Bingo → Organizer; demande volontaire confirmée côté Remote, relayée comme action Organizer avec `sessionId` pour exécuter le contrat Master existant. Si aucun Organizer n'est connecté, Bingo renvoie `remoteQuitUnavailable` à la Remote. L'Organizer doit attendre la prise en charge locale du send `quitGame forced=false` par une socket ouverte avant redirection; le serveur loggue `quitGame_received`, puis diffuse `SESSION_ENDED` avec `reason=organizer_quit` / `terminal_reason=organizer_quit`. Ce terminal ferme les interfaces mais reste reprenable en Hub: le guard mémoire `sessionEndedGames` est réarmé seulement lors d'une reprise Organizer prouvée (`BINGO_QUIT_GUARD_RESET`) et reste distinct de la fin naturelle `bingo:end_game` / `HUB_SESSION_FINISHED`. L'envoi Remote trace `hub_remote_bingo_terminal_delivery` avec état registre/socket et succès/échec d'envoi, sans secret.

### Hub Remote commands (hors Canvas bridge)
- `master_ping` — Hub Remote -> `games_hubs_remote_commands`; commande technique non destructive claimée par Hub Master via `remote_control_poll`.
- `launch_session` — Hub Remote -> `games_hubs_remote_commands`; requête minimale `{session_id}` où l'identifiant reste la source officielle. Hub Master claim la commande et transmet `remote-command-{command_id}` comme `launch_intent_id`: le retry de la même commande retrouve une seule démo/exécution, une nouvelle commande crée une démo/exécution distincte. Le résultat public comprend `source_session_id`, `runtime_session_id`, `runtime_mode`, `execution_id`, `organizer_url` et `remote_url`; les URLs visent le runtime déclaré, officiel ou démo.

Contraintes: le contrat `launch_session` est commun Quiz/Blind Test/Bingo; toute divergence Bingo reste derrière le service central Hub Master et les handlers Canvas/WS existants.

## Canvas (global, `canvas_api_*`)
- `canvas:hub_session_grace_expired` — `games/web/includes/canvas/php/boot_lib.php` — `(pdo, p)`; write service-only, clear conditionnel du focus Hub après expiration définitive.
- `canvas:hub_session_natural_ended` — `games/web/includes/canvas/php/boot_lib.php` — `(pdo, p)`; write service-only après persistance terminale, résout l'exécution par `runtime_session_id`, puis clear conditionnel sur la source officielle et preuve `hub_execution_completed`. En mode démo, il ne modifie pas la source et ne déclenche ni résultats ni rebuild de stats Hub.
- `canvas:participant_lookup` — `games/web/includes/canvas/php/boot_lib.php` — `(pdo, p)`
- `canvas:prizes_get` — `games/web/includes/canvas/php/prizes_glue.php` — `(pdo, p)`
- `canvas:prizes_save` — `games/web/includes/canvas/php/prizes_glue.php` — `(pdo, p)`
- `canvas:session_meta_get` — `games/web/includes/canvas/php/boot_lib.php` — `(pdo, p)`
- `canvas:session_podium_photo_upload` — `games/web/includes/canvas/php/boot_lib.php` — `(pdo, p)`
- `canvas:youtube_catalog_diagnostics_get` — `games/web/includes/canvas/php/boot_lib.php` — `(pdo, p)`

## API callers (where to patch logging)
| Repo | Caller type | Wrapper function | File:line | Actions covered (write-heavy) | Notes |
|---|---|---|---|---|---|
| games (front organizer) | browser | `__canvasCall` | `games/web/includes/canvas/core/boot_organizer.js:274-335` | `resetdemo`, `session_update`, `prizes_get/save` via `CanvasAPI.*` | Single fetch wrapper; unwraps `{ok,data,error}`; no `event_id` header. |
| games (front remote) | browser | `remoteApi` / `remoteApiFormData` | `games/web/includes/canvas/remote/remote-ui.js:381-430` | `players_get`, `player_register`, `participant_lookup`, `session_primary_id`, `update_score`, `phase_winner`, `session_podium_photo_upload` | Used by remote admin UI; same envelope handling, plus multipart upload for podium photos. Remote paper critical writes use HTTP before WS refresh. |
| games (front player) | browser | `api` | `games/web/includes/canvas/play/register.js` | `session_primary_id`, `players_get`, `player_register`, `grid_assign`, `deactivate_player` | Les writes portent un `event_id`; tentative simultanée coalescée et retry réseau avec le même ID. |
| games (front bingo sync) | browser | direct fetch | `games/web/includes/canvas/play/play-ui.js` | `grid_cells_sync` | Snapshot debounced + `sendBeacon`; ID stable tant que le même snapshot n'est pas acquitté. |
| bingo WS | Node | `canvasWrite` | `bingo.game/ws/envUtils.js` | `bingo:reset`, `session_update`, `bingo:end_game`, `phase_winner`, `hub_session_natural_ended` | Injects `event_id`, sets `X-Service-Token`; natural end emits `HUB_SESSION_FINISHED` only when the bridge confirms the current Hub execution. |
| quiz WS | Node | `canvasWrite` | `quiz/web/server/actions/envUtils.js` | `update_score`, `session_update`, `deactivate_player`, `player_register`, `hub_session_natural_ended` | `CanvasAPI.*` uses this; injects `event_id`, timeout/abort; natural end follows persisted final podium. |
| blindtest WS | Node | `canvasWrite` | `blindtest/web/server/actions/envUtils.js` | `update_score`, `session_update`, `deactivate_player`, `player_register`, `hub_session_natural_ended` | Same as quiz wrapper, including final team/solo snapshot before the Hub callback. |

Evidence details: `notes/logging-api-callers-audit.md`.

### WS primary organizer recovery
- Quiz et Blind Test utilisent `sendMessageToPrimary(sessionId, message)` pour les envois cibles organizer principal.
- Depuis le 2026-06-12, si `session.primarySocket` est absente ou fermee mais qu'une socket organizer ouverte est deja connue de la session, le WS la promeut localement et logge `PRIMARY_ORGANIZER_RECOVERED`.
- Si aucune socket organizer ouverte n'existe, `WS_SEND_NO_PRIMARY_ORGANIZER` reste le signal support attendu, avec compteurs actifs organizer/secondary.
- Bingo n'a pas d'equivalent direct: `sendMsgToClient()` parcourt les sockets organizer ouvertes dans `clients`.

### API call logging spec (API_CALL_*)
- Events: `API_CALL_ATTEMPT` (DEBUG), `API_CALL_RESULT` (DEBUG if `ok=true`, INFO if `ok=false`), `API_CALL_ERROR` (WARN).
- Common fields (snake_case): `request_id` (front+WS), `event_id` (WS writes), `api_action`, `payload_keys`, `http_status`, `latency_ms`, `already_processed?`, `error_message?`, `transport` (`front`/`ws`), `session_id?`, `player_id?`.
- Wrappers instrumented: `__canvasCall` (organizer), `remoteApi` (remote UI), `api` (player UI), `grid_cells_sync` fetch (bingo player), `canvasWrite` (bingo/quiz/blindtest WS).
- Legacy network success logs are downgraded to DEBUG with `event:"LEGACY_API_NOTE"` and `legacy_api=1` to avoid duplicates in the viewer.
<!-- AUTO-UPDATE:END id="actions-list" -->

<!-- AUTO-UPDATE:BEGIN id="actions-matrix" owner="codex" -->
## Coverage matrix (auto)
| area | action | write? | required fields | idempotence | notes |
|---|---|---:|---|---|---|
| Canvas / Hub | `hub_session_natural_ended` | ✅ | `game`, `sessionId`, `event_id`, `X-Service-Token` | replay résultat + focus/exécution gardés | Exige session terminée et `hub_execution_started`; écrit `hub_execution_completed` après clear et récupère au retry un clear déjà commité avec exécution encore ouverte. |
| Bingo | `player_register` | ✅ | `username`, `sessionId`, `player_id`, `event_id` | replay résultat + upsert | Front browser sans service token; ID stable pendant retry, upsert sur `(session_id, player_id)`. Une injection Hub papier serveur peut adopter une unique ligne historique sous contrôle du contexte interne. |
| Bingo WS | `auth_player` | ❌ | `id_player`, `id_grid`, `token`, `player_id`, `demoParticipant?` | — | WS-only auth, hors Canvas bridge. `demoParticipant=true` identifie la preview desktop mais compte quand meme dans le quota `maxPlayers`. |
| Bingo | `resetdemo` | ✅ | `sessionId` | — | Organizer triggers API reset + reload; PHP purge demo state inclut maintenant `bingo_phase_winners`, puis WS `demo_reset` resync remote/player, force le player Bingo a basculer immédiatement en `En attente`, vider son état local, puis reload. |
| Bingo | `session_update` | ✅ | `sessionId`, `event_id`, + `id_song` (write) | `already_processed` on replay | WS emits `event:"session_update"` only on state/phase/media evolution (dedup), WS_IN/OUT traffic stays DEBUG by défaut (`WS_LOG_TRAFFIC=1` → INFO) |
| Bingo | `grid_assign` | ✅ | `sessionId`, `player_id` (canon), `gridSupport`, `event_id` | replay résultat + assign idempotent | Si déjà assigné, renvoie la même grille (`already_assigned=true`); appels simultanés coalescés côté navigateur. |
| Bingo | `grid_hydrate` | ❌ | `sessionId`, `player_id` (canon), `gridId?` | — | Read: si `gridId` absent, le bridge retrouve la grille via l’assignation joueur. |
| Bingo | `grid_cells_sync` | ✅ | `sessionId`, `player_id` (canon), `gridId`, `checkedCells`, `event_id` | replay résultat + snapshot idempotent | Front browser best-effort; le même snapshot réutilise son ID après erreur réseau. Un beacon accepté par le navigateur clôt la tentative locale, le bridge déduplique toute livraison répétée. |
| Bingo | `end_game` (alias `bingo:end_game`) | ✅ | `sessionId`, `event_id` | `already_processed` on replay + verrou WS en vol | Après dernière phase persistée, le WS peut le déclencher sans Master; échec = retour revue, sans podium/Hub. Optional: `reason`, `ended_at`. |
| Bingo | `phase_winner` (alias `bingo:phase_winner`) | ✅ | `sessionId`, `event_id`, `player_id` (canon), `phase` | `already_processed` on replay | `playerId` numérique optionnel (legacy) ; WS envoie key-first (`player_id`). |
| Bingo | `reset` (alias `bingo:reset`) | ✅ | `sessionId`, `event_id` | `already_processed` on replay | Optional: `target_phase`, `reason`, `source` |
| Canvas | `participant_lookup` | ❌ | `game`, `query`, `sessionId?` | — | Remote papier helper to search existing players/teams before registration. |
| Canvas | `player_podium_photo_access_get` | ❌ | `game`, `sessionId`, `game_player_id?`, `player_db_id?`, `game_player_key?`, `player_id?` | — | Read: player end-screen eligibility check for podium photo CTA; returns eligibility, row meta, runtime snapshot and consent text. |
| Canvas | `player_podium_photo_upload` | ✅ | `game`, `sessionId`, `rank`, `files_img[]`, `consent=1`, `game_player_id?`, `player_db_id?`, `game_player_key?`, `player_id?`, `photo_row_key?` | — | Front player multipart upload for own podium photo; server rechecks ended session, podium membership and consent, then snapshots runtime label/pseudo for deletion audit. |
| Canvas | `session_meta_get` | ❌ | `game`, `sessionId` | — | Read: polling organizer / remote metadata, inclut aussi `podium_photos`. |
| Quiz / Blind Test / Bingo | `session_update` avec `paperMode` sur demo | ✅ | `sessionId`, `paperMode` | — | Autorise la persistance du format sur une demo non lancee; garde `FORMAT_SWITCH_LOCKED` si la phase runtime indique une session demarree. |
| Canvas | `youtube_catalog_diagnostics_get` | ❌ | `game`, `sessionId`, `items[]` | — | Read: test pre-lancement organizer; relit `content_links_check_results` pour signaler les supports YouTube deja connus comme inutilisables par le scan `pro`. |
| Canvas | `session_podium_photo_upload` | ✅ | `game`, `sessionId`, `rank`, `id_client`, `files_img[]`, `consent=1`, `consent_text`, `photo_row_key?` | — | Front remote multipart upload for ended-session podium photos; remote now collects organizer consent before upload and persists it with source `games_remote_organizer`. |
| Blindtest | `session_primary_id` | ❌ | `sessionId` | — | Read (no `event_id`) |
| Blindtest | `players_get` | ❌ | `sessionPrimaryId`; `includeInactive` terminal/historique only | — | Read (no `event_id`). Les réhydratations runtime actives de `canvas_display.js` ne doivent pas envoyer `includeInactive`; le filtre actif serveur reste le contrat par défaut. |
| Blindtest | `update_score` | ✅ | `sessionPrimaryId`, `player_id` (canon), `score`, `event_id` | `already_processed` on replay | `playerId` numérique optionnel (legacy); WS envoie key-first (`player_id`). |
| Blindtest | `session_update` | ✅ | `sessionId`, `event_id` | `already_processed` on replay | WS persistence (session end / podium); le payload final peut porter `players[]` avec equipes de 2+ membres seulement; WS_IN/WS_OUT traffic stays DEBUG par défaut (`WS_LOG_TRAFFIC=1` → INFO) |
| Blindtest | `deactivate_player` | ✅ | `sessionPrimaryId`, `player_id` (canon), `event_id` | `already_processed` on replay | `playerId` numérique optionnel (legacy); WS voluntary quit cleanup key-first. |
| Blindtest | `player_register` | ✅ | `sessionPrimaryId`, `username`, `event_id` | `already_processed` on replay | UPSERT canonique; `score=0` uniquement sous contexte serveur interne d'un `manual_join_session` Hub dont le mapping était `left`; toute autre réactivation conserve le score. |
| Blindtest WS runtime | `teamCreate` / `teamJoin` / `teamLeave` / `teamList` | ❌ | `sessionId`, `player_id`, `teamId?`, `teamName?` | — | Runtime-only: stocke `session.teams` / `session.teamPlayers`; verrou avant start requis, pas de bridge Canvas/DB; une equipe a 1 membre reste une préparation visible, seule une equipe vide est supprimée, et le joueur seul sera classé en solo au démarrage. |
| Blindtest WS runtime | `remoteQuitRequest` | ✅ | `sessionId` | verrou front Remote + relais primary | Quit volontaire confirmé côté Remote; le WS relaie au primary Organizer, puis l'Organizer exécute `endSession({ reason:'Quitter le jeu', serverLogout:true })`. |
| Quiz | `session_primary_id` | ❌ | `sessionId` | — | Read (no `event_id`) |
| Quiz | `players_get` | ❌ | `sessionPrimaryId`; `includeInactive` terminal/historique only | — | Read (no `event_id`). Les réhydratations runtime actives de `canvas_display.js` ne doivent pas envoyer `includeInactive`; le filtre actif serveur reste le contrat par défaut. |
| Quiz | `update_score` | ✅ | `sessionPrimaryId`, `player_id` (canon), `score`, `event_id` | `already_processed` on replay | `playerId` numérique optionnel (legacy); WS envoie key-first (`player_id`). |
| Quiz remote papier | `update_score` | ✅ | `sessionId`, `sessionPrimaryId`, `player_id` (canon) ou `playerId`, `score`, `event_id`, `role=remote`, `remote_action=paper_score_update`, `paperMode=1` | `already_processed` on replay | La remote persiste par HTTP avant le WS `admin_set_score`; le succes remote depend de l'ACK bridge, le WS est un refresh best-effort si le primary organizer est disponible. |
| Quiz | `session_update` | ✅ | `sessionId`, `event_id` | `already_processed` on replay | WS persistence (session end / podium); WS_IN/WS_OUT traffic stays DEBUG by défaut (`WS_LOG_TRAFFIC=1` → INFO) |
| Quiz | `deactivate_player` | ✅ | `sessionPrimaryId`, `player_id` (canon), `event_id` | `already_processed` on replay | `playerId` numérique optionnel (legacy); WS voluntary quit cleanup key-first. |
| Quiz | `player_register` | ✅ | `sessionPrimaryId`, `username`, `event_id` | `already_processed` on replay | UPSERT canonique; `score=0` uniquement sous contexte serveur interne d'un `manual_join_session` Hub dont le mapping était `left`; toute autre réactivation conserve le score. |
| Quiz WS runtime | `remoteQuitRequest` | ✅ | `sessionId` | verrou front Remote + relais primary | Quit volontaire confirmé côté Remote; le WS relaie au primary Organizer, puis l'Organizer exécute `endSession({ reason:'Quitter le jeu', serverLogout:true })`. |
| Bingo WS runtime | `remote_action=remote_quit_request` | ✅ | `sessionId` | verrou front Remote + relais Organizer + send local garanti | Quit volontaire confirmé côté Remote; Bingo relaie l'action et le `sessionId` à l'Organizer, qui exécute `endSession({ reason:'Quitter le jeu', serverLogout:true })` et attend `quitGame` pris en charge par une socket ouverte avant redirection. Le serveur loggue `quitGame_received`; le `SESSION_ENDED` volontaire porte `organizer_quit`, son envoi Remote est tracé par `hub_remote_bingo_terminal_delivery`, et son guard d'idempotence est réarmé uniquement sur reprise Organizer prouvée. |

### Response shape note (auto)
- Bridge always responds with an envelope `{ ok, data, error, ts }` (see `canon/interfaces/canvas-bridge.md`).
- WS callers must read fields inside `data` (or use a wrapper that unwraps `data`).

### WS inventory (Blindtest/Quiz) (auto)
WS callers (deduped) and the payload keys they send to the bridge.

| game | action | read/write | WS call sites | payload keys (WS → bridge) | data fields used by WS |
|---|---|---:|---|---|---|
| Blindtest | `session_primary_id` | read | `blindtest/web/server/actions/sessionUtils.js` | `game`, `sessionId` | `sessionPrimaryId` |
| Blindtest | `players_get` | read | `blindtest/web/server/actions/registration.js` | `game`, `sessionPrimaryId` | `players[]` (`playerId`, `playerName`, `score`) |
| Blindtest | `update_score` | write | `blindtest/web/server/actions/gameplay.js` | `game`, `sessionPrimaryId`, `player_id`, `playerId?`, `score`, `event_id`* | `changed` |
| Blindtest | `session_update` | write | `blindtest/web/server/actions/gameplay.js` | `game`, `sessionId`, `currentSongIndex`, `gameStatus`, `totalPlayers`, `podium`, `players?`, `event_id`* | `changed` |
| Blindtest | `deactivate_player` | write | `blindtest/web/server/actions/connection.js` | `game`, `sessionPrimaryId`, `player_id`, `playerId?`, `event_id`* | `changed` |
| Blindtest | `player_register` | write | `blindtest/web/server/actions/loadtest.js` | `game`, `sessionPrimaryId`, `username`, `event_id`* | `playerId`, `username`, `sessionPrimaryId` |
| Quiz | `session_primary_id` | read | `quiz/web/server/actions/sessionUtils.js` | `game`, `sessionId` | `sessionPrimaryId` |
| Quiz | `players_get` | read | `quiz/web/server/actions/registration.js` | `game`, `sessionPrimaryId` | `players[]` (`playerId`, `playerName`, `score`) |
| Quiz | `update_score` | write | `quiz/web/server/actions/gameplay.js` | `game`, `sessionPrimaryId`, `player_id`, `playerId?`, `score`, `event_id`* | `changed` |
| Quiz | `session_update` | write | `quiz/web/server/actions/gameplay.js` | `game`, `sessionId`, `currentSongIndex`, `gameStatus`, `totalPlayers`, `podium`, `event_id`* | `changed` |
| Quiz | `deactivate_player` | write | `quiz/web/server/actions/connection.js` | `game`, `sessionPrimaryId`, `player_id`, `playerId?`, `event_id`* | `changed` |
| Quiz | `player_register` | write | `quiz/web/server/actions/loadtest.js` | `game`, `sessionPrimaryId`, `username`, `event_id`* | `playerId`, `username`, `sessionPrimaryId` |

\* `event_id` is injected by the WS wrapper for write actions (see `blindtest/web/server/actions/envUtils.js` and `quiz/web/server/actions/envUtils.js`).
\* Les wrappers WS valident les payloads player-scoped avant appel bridge (`WS_API_PAYLOAD_VALIDATED`) : `player_id` canon requis, `playerId` numeric-only.
\* Loadtests WS URL: `blindtest/web/server/actions/loadtest.js` and `quiz/web/server/actions/loadtest.js` default to `ws://127.0.0.1:${WS_PORT}/` (fallback 3031 for Blindtest, 3032 for Quiz).
\* WS `update_score` write smoothing: `CANVAS_UPDATE_SCORE_CONCURRENCY` (default 5) caps in-process concurrency; `CANVAS_HTTP_TIMEOUT_MS` (default 3000) aborts Canvas HTTP calls (no retry).

### Logging patch plan (next step)
- **Front (games)**: instrument the three fetch wrappers — `__canvasCall` (`boot_organizer.js:274-335`), `remoteApi` (`remote-ui.js:381-410`), `api` (`play/register.js:513-548`) — to emit attempt/result/error with `action`, `game`, payload keys, HTTP status, parsed envelope; add a small hook on standalone `grid_cells_sync` (`play-ui.js:1046-1088`).
- **Player end-screen upload**: `games/web/includes/canvas/play/play-ui.js` now also calls the bridge directly for `player_podium_photo_access_get` and `player_podium_photo_upload`; this path is browser-originated, multipart for the upload, and does not carry `event_id`.
- **WS Bingo**: patch `canvasWrite` (`envUtils.js:167-195`) once to log attempt/result/error with `event_id`, `statusCode`, `latencyMs`, `canvasHost`; callers already pass `sessionId/playerId/phase`.
- **WS Quiz/Blindtest**: patch `canvasWrite` (`quiz/web/server/actions/envUtils.js:208-233`, `blindtest/web/server/actions/envUtils.js:211-239`) to log attempt/result/error with `event_id`, `statusCode`, `latencyMs`, token presence, unwrapped `data`; covers `update_score`, `session_update`, `deactivate_player`, `player_register`.
- **Fallbacks**: if wrappers cannot be patched, instrument per-call sites listed in `notes/logging-api-callers-audit.md` (`bingo_server.js`, `play/register.js`, etc.).
<!-- AUTO-UPDATE:END id="actions-matrix" -->
