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

## Blindtest (`blindtest_api_*`)
- `blindtest:deactivate_player` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`
- `blindtest:player_register` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`
- `blindtest:players_get` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`
- `blindtest:resetdemo` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, payload)`
- `blindtest:session_primary_id` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`
- `blindtest:session_update` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, payload)`
- `blindtest:update_score` — `games/web/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`

## Quiz (`quiz_api_*`)
- `quiz:deactivate_player` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`
- `quiz:player_register` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`
- `quiz:players_get` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`
- `quiz:resetdemo` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, payload)`
- `quiz:session_primary_id` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`
- `quiz:session_update` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, payload)`
- `quiz:update_score` — `games/web/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`

## Canvas (global, `canvas_api_*`)
- `canvas:prizes_get` — `games/web/includes/canvas/php/prizes_glue.php` — `(pdo, p)`
- `canvas:prizes_save` — `games/web/includes/canvas/php/prizes_glue.php` — `(pdo, p)`

## API callers (where to patch logging)
| Repo | Caller type | Wrapper function | File:line | Actions covered (write-heavy) | Notes |
|---|---|---|---|---|---|
| games (front organizer) | browser | `__canvasCall` | `games/web/includes/canvas/core/boot_organizer.js:274-335` | `resetdemo`, `session_update`, `prizes_get/save` via `CanvasAPI.*` | Single fetch wrapper; unwraps `{ok,data,error}`; no `event_id` header. |
| games (front remote) | browser | `remoteApi` | `games/web/includes/canvas/remote/remote-ui.js:381-410` | `players_get`, `player_register`, `session_primary_id` | Used by remote admin UI; same envelope handling. |
| games (front player) | browser | `api` | `games/web/includes/canvas/play/register.js:513-548` | `session_primary_id`, `players_get`, `player_register`, `grid_assign`, `deactivate_player` | All player HTTP calls go through this helper. |
| games (front bingo sync) | browser | direct fetch | `games/web/includes/canvas/play/play-ui.js:1046-1088` | `grid_cells_sync` | Debounced + `sendBeacon` fallback; no shared wrapper. |
| bingo WS | Node | `canvasWrite` | `bingo.game/ws/envUtils.js:167-195` | `bingo:reset`, `session_update`, `bingo:end_game`, `phase_winner` | Injects `event_id`, sets `X-Service-Token` if present. |
| quiz WS | Node | `canvasWrite` | `quiz/web/server/actions/envUtils.js:208-233` | `update_score`, `session_update`, `deactivate_player`, `player_register` | `CanvasAPI.*` uses this; injects `event_id`, timeout/abort. |
| blindtest WS | Node | `canvasWrite` | `blindtest/web/server/actions/envUtils.js:211-239` | `update_score`, `session_update`, `deactivate_player`, `player_register` | Same as quiz wrapper. |

Evidence details: `notes/logging-api-callers-audit.md`.

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
| Bingo | `player_register` | ❌ | `username`, `sessionId`, `player_id` | — | Front (browser), no `X-Service-Token`, no `event_id`; upsert côté bridge sur `(session_id, player_id)` |
| Bingo | `resetdemo` | ✅ | `sessionId` | — | Organizer triggers API reset + reload; WS `demo_reset` is used to resync remote/player (no WS DB reset) |
| Bingo | `session_update` | ✅ | `sessionId`, `event_id`, + `id_song` (write) | `already_processed` on replay | WS emits `event:"session_update"` only on state/phase/media evolution (dedup), WS_IN/OUT traffic stays DEBUG by défaut (`WS_LOG_TRAFFIC=1` → INFO) |
| Bingo | `grid_assign` | ✅ | `sessionId`, `player_id` (canon), `gridSupport` | — | Idempotent côté bridge: si déjà assigné, renvoie la même grille (`already_assigned=true`); `playerId` numérique accepté en fallback compat. |
| Bingo | `grid_hydrate` | ❌ | `sessionId`, `player_id` (canon), `gridId?` | — | Read: si `gridId` absent, le bridge retrouve la grille via l’assignation joueur. |
| Bingo | `grid_cells_sync` | ✅ | `sessionId`, `player_id` (canon), `gridId`, `checkedCells` | — | Front (browser), best-effort debounced snapshot; `playerId` numérique accepté en fallback compat; pas de `X-Service-Token`/`event_id` sur la voie front legacy. |
| Bingo | `end_game` (alias `bingo:end_game`) | ✅ | `sessionId`, `event_id` | `already_processed` on replay | Optional: `reason`, `ended_at` (see `specs/smoke-canvas-api.md`) |
| Bingo | `phase_winner` (alias `bingo:phase_winner`) | ✅ | `sessionId`, `event_id`, `player_id` (canon), `phase` | `already_processed` on replay | `playerId` numérique optionnel (legacy) ; WS envoie key-first (`player_id`). |
| Bingo | `reset` (alias `bingo:reset`) | ✅ | `sessionId`, `event_id` | `already_processed` on replay | Optional: `target_phase`, `reason`, `source` |
| Blindtest | `session_primary_id` | ❌ | `sessionId` | — | Read (no `event_id`) |
| Blindtest | `players_get` | ❌ | `sessionPrimaryId` | — | Read (no `event_id`) |
| Blindtest | `update_score` | ✅ | `sessionPrimaryId`, `player_id` (canon), `score`, `event_id` | `already_processed` on replay | `playerId` numérique optionnel (legacy); WS envoie key-first (`player_id`). |
| Blindtest | `session_update` | ✅ | `sessionId`, `event_id` | `already_processed` on replay | WS persistence (session end / podium); WS_IN/WS_OUT traffic stays DEBUG by défaut (`WS_LOG_TRAFFIC=1` → INFO) |
| Blindtest | `deactivate_player` | ✅ | `sessionPrimaryId`, `player_id` (canon), `event_id` | `already_processed` on replay | `playerId` numérique optionnel (legacy); WS voluntary quit cleanup key-first. |
| Blindtest | `player_register` | ✅ | `sessionPrimaryId`, `username`, `event_id` | `already_processed` on replay | Used by WS loadtest bots |
| Quiz | `session_primary_id` | ❌ | `sessionId` | — | Read (no `event_id`) |
| Quiz | `players_get` | ❌ | `sessionPrimaryId` | — | Read (no `event_id`) |
| Quiz | `update_score` | ✅ | `sessionPrimaryId`, `player_id` (canon), `score`, `event_id` | `already_processed` on replay | `playerId` numérique optionnel (legacy); WS envoie key-first (`player_id`). |
| Quiz | `session_update` | ✅ | `sessionId`, `event_id` | `already_processed` on replay | WS persistence (session end / podium); WS_IN/WS_OUT traffic stays DEBUG by défaut (`WS_LOG_TRAFFIC=1` → INFO) |
| Quiz | `deactivate_player` | ✅ | `sessionPrimaryId`, `player_id` (canon), `event_id` | `already_processed` on replay | `playerId` numérique optionnel (legacy); WS voluntary quit cleanup key-first. |
| Quiz | `player_register` | ✅ | `sessionPrimaryId`, `username`, `event_id` | `already_processed` on replay | Used by WS loadtest bots |

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
| Blindtest | `session_update` | write | `blindtest/web/server/actions/gameplay.js` | `game`, `sessionId`, `currentSongIndex`, `gameStatus`, `totalPlayers`, `podium`, `event_id`* | `changed` |
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
- **WS Bingo**: patch `canvasWrite` (`envUtils.js:167-195`) once to log attempt/result/error with `event_id`, `statusCode`, `latencyMs`, `canvasHost`; callers already pass `sessionId/playerId/phase`.
- **WS Quiz/Blindtest**: patch `canvasWrite` (`quiz/web/server/actions/envUtils.js:208-233`, `blindtest/web/server/actions/envUtils.js:211-239`) to log attempt/result/error with `event_id`, `statusCode`, `latencyMs`, token presence, unwrapped `data`; covers `update_score`, `session_update`, `deactivate_player`, `player_register`.
- **Fallbacks**: if wrappers cannot be patched, instrument per-call sites listed in `notes/logging-api-callers-audit.md` (`bingo_server.js`, `play/register.js`, etc.).
<!-- AUTO-UPDATE:END id="actions-matrix" -->
