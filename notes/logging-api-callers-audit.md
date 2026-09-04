# Logging API Callers Audit (2026-01-28)

Scope: locate every Canvas API caller (front + WS) and pinpoint the best wrapper to instrument `API_CALL_{ATTEMPT|RESULT|ERROR}` without shipping code yet. Evidence = path:line.

## Best single patch point (per repo)
- games (front, organizer UI): `__canvasCall` fetch wrapper — `games/web/includes/canvas/core/boot_organizer.js:274-335`
  - Covers organizer writes: `resetdemo`, `session_update`, `prizes_get/save` via `CanvasAPI.*`.
- games (front, remote UI): `remoteApi` helper — `games/web/includes/canvas/remote/remote-ui.js:381-410`
  - Covers remote admin calls (`players_get`, `player_register`, `session_primary_id`).
- games (front, player UI): `api` helper — `games/web/includes/canvas/play/register.js:513-548`
  - Covers player flows: `session_primary_id`, `players_get`, `player_register`, `grid_assign`, `deactivate_player`.
- games (front, bingo grid sync): direct fetch `grid_cells_sync` — `games/web/includes/canvas/play/play-ui.js:1046-1080`
  - Only bingo players; best-effort debounce/flush + beacon.
- bingo WS: `canvasWrite` (idempotent, adds `event_id`) — `bingo.game/ws/envUtils.js:167-195`
  - Used for all WS writes: `bingo:reset`, `session_update`, `bingo:end_game`, `phase_winner`.
- quiz WS: `canvasWrite` (`event_id` injected) — `quiz/web/server/actions/envUtils.js:208-233`
  - Used via `CanvasAPI.updateScore/updateSession/deactivatePlayer/playerRegister`.
- blindtest WS: `canvasWrite` (`event_id` injected) — `blindtest/web/server/actions/envUtils.js:211-239`
  - Same surface as quiz (`CanvasAPI.*`).

## Call sites (writes/critical) — evidence
- Organizer API (games):
  - `CanvasAPI.updateSession` called by `postSessionUpdate` — `games/web/includes/canvas/core/session_persist.js:41-52`.
  - Prizes writes via `savePrizesToServer` → `CanvasAPI.savePrizes` — `games/web/includes/canvas/core/session_modals.js:712-723`.
- Remote UI (games):
  - `players_get` snapshots — `games/web/includes/canvas/remote/remote-ui.js:3139-3151`.
  - Live `player_register` — `.../remote-ui.js:3170-3183`.
- Player UI (games):
  - `player_register` (multiple branches) — `games/web/includes/canvas/play/register.js:779-806`, `949-951`, `1119-1120`, `1315-1317`.
  - `grid_assign` — `.../register.js:816-824`, `949-951`, `1183-1187`.
  - `deactivate_player` on quit — `.../register.js:1222-1258`.
  - Bingo `grid_cells_sync` — `games/web/includes/canvas/play/play-ui.js:1046-1088` (fetch/keepalive + beacon fallback).
- Bingo WS (writes):
  - `bingo:reset` — `bingo.game/ws/bingo_server.js:1082-1123`.
  - `session_update` (song_start) — `.../bingo_server.js:1167-1201`.
  - `bingo:end_game` — `.../bingo_server.js:1403-1457`.
  - `phase_winner` admin — `.../bingo_server.js:1636-1693`; auto-verify path — `.../bingo_server.js:1889-1931`.
- Quiz WS (writes):
  - `update_score` — `quiz/web/server/actions/gameplay.js:1159-1192`.
  - `session_update` podium/end — `.../actions/gameplay.js:1197-1233`.
  - `deactivate_player` — `.../actions/connection.js:130-145`.
  - `player_register` (loadtest HTTP) — `.../actions/loadtest.js:16-28`.
- Blindtest WS (writes):
  - `update_score` — `blindtest/web/server/actions/gameplay.js:1057-1092`.
  - `session_update` podium/end — `.../actions/gameplay.js:1095-1131`.
  - `deactivate_player` — `.../actions/connection.js:130-145`.
  - `player_register` (loadtest HTTP) — `.../actions/loadtest.js:16-28`.

## Fields available at patch points
- Front wrappers (`__canvasCall`, `remoteApi`, `api`): have `action`, `game`, full payload, HTTP status, parsed JSON (`ok`, `data`, `error`), and endpoint URL; no `event_id` nor service token.
- Bingo WS `canvasWrite`: sets `X-Service-Token` if present, injects `event_id` (UUID), knows `canvasHost`, `statusCode`, `latency`, and can log `isWriteAction`.
- Quiz/Blindtest WS `canvasWrite`: injects `event_id`, supports timeout/abort, logs token presence; returns envelope `data` already unwrapped.
- Callers often pass identifiers:
  - Organizer/remote/player front: `sessionId`, `sessionPrimaryId`, `playerId`, `gridId`, `username`, `reason`.
  - WS: `sessionId`, `sessionPrimaryId`, `playerId`, `phase`, `target_phase`, `score`, `reason`, `event_id` (already set).

## Fallbacks if wrapper patch not possible
- Instrument per-call logs at:
  - `games/web/includes/canvas/play/register.js` branches (`player_register`, `grid_assign`, `deactivate_player`).
  - `games/web/includes/canvas/play/play-ui.js:1046-1088` for `grid_cells_sync`.
  - `bingo.game/ws/bingo_server.js` action handlers listed above.
  - `quiz|blindtest/web/server/actions/gameplay.js` (`persistScore`/`persistPodium`) and `connection.js` (`deactivatePlayerInDB`).

Next step (not executed): wire `API_CALL_ATTEMPT/RESULT/ERROR` at the best patch points above.

## Patch applied — 2026-01-28
- Instrumented API wrappers: `__canvasCall`, `remoteApi`, `api`, `grid_cells_sync` fetch, and `canvasWrite` (bingo/quiz/blindtest) with `API_CALL_ATTEMPT/RESULT/ERROR` and `request_id` (`event_id` preserved for WS writes).
- Downgraded legacy network success logs to DEBUG with `event:"LEGACY_API_NOTE"` in Bingo WS and Quiz/Blindtest WS gameplay (persistScore/persistPodium).
- Updated viewer mapping (`web/assets/logs/actions-map.json`) to display `API_CALL_*` with meta and to keep legacy API notes in debug.
- Transport rule: `logger.global.js` always buffers `API_CALL_*` and `LEGACY_API_NOTE` regardless of `LOG_BUFFER_LEVEL` so they reach `log_batch` WS exports (evidence: `games/web/includes/canvas/core/logger.global.js`).
