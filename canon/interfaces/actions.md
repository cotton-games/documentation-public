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
- `bingo:case_click` — `GAMES/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:deactivate_player` — `GAMES/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:end_game` — `GAMES/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:grid_assign` — `GAMES/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:grid_hydrate` — `GAMES/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:grid_lines` — `GAMES/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:phase_winner` — `GAMES/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:player_register` — `GAMES/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:players_get` — `GAMES/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:reset` — `GAMES/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, p)`
- `bingo:session_update` — `GAMES/includes/canvas/php/bingo_adapter_glue.php` — `(pdo, payload)`

## Blindtest (`blindtest_api_*`)
- `blindtest:deactivate_player` — `GAMES/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`
- `blindtest:player_register` — `GAMES/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`
- `blindtest:players_get` — `GAMES/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`
- `blindtest:resetdemo` — `GAMES/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, payload)`
- `blindtest:session_primary_id` — `GAMES/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`
- `blindtest:session_update` — `GAMES/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, payload)`
- `blindtest:update_score` — `GAMES/includes/canvas/php/blindtest_adapter_glue.php` — `(pdo, p)`

## Quiz (`quiz_api_*`)
- `quiz:deactivate_player` — `GAMES/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`
- `quiz:player_register` — `GAMES/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`
- `quiz:players_get` — `GAMES/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`
- `quiz:resetdemo` — `GAMES/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, payload)`
- `quiz:session_primary_id` — `GAMES/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`
- `quiz:session_update` — `GAMES/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, payload)`
- `quiz:update_score` — `GAMES/includes/canvas/php/quiz_adapter_glue.php` — `(pdo, p)`

## Canvas (global, `canvas_api_*`)
- `canvas:prizes_get` — `GAMES/includes/canvas/php/prizes_glue.php` — `(pdo, p)`
- `canvas:prizes_save` — `GAMES/includes/canvas/php/prizes_glue.php` — `(pdo, p)`
<!-- AUTO-UPDATE:END id="actions-list" -->

<!-- AUTO-UPDATE:BEGIN id="actions-matrix" owner="codex" -->
## Coverage matrix (auto)
| area | action | write? | required fields | idempotence | notes |
|---|---|---:|---|---|---|
| Bingo | `player_register` | ❌ | `username`, `sessionId` | — | Front (browser), no `X-Service-Token`, no `event_id` |
| Bingo | `session_update` | ✅ | `sessionId`, `event_id`, + `id_song` (write) | `already_processed` on replay | Used by WS `song_start` (see `docs/specs/tests/c1.md`) |
| Bingo | `case_click` (alias `bingo:case_click`) | ✅ | `sessionId`, `event_id`, `playerId`, `gridId`, `num_case`, `clicked` | `already_processed` on replay | Used by WS player `case_click` (see `docs/specs/tests/c2.md`) |
| Bingo | `end_game` (alias `bingo:end_game`) | ✅ | `sessionId`, `event_id` | `already_processed` on replay | Optional: `reason`, `ended_at` (see `docs/specs/smoke-canvas-api.md`) |
| Bingo | `phase_winner` (alias `bingo:phase_winner`) | ✅ | `sessionId`, `event_id`, `playerId`, `phase` | `already_processed` on replay | Used by WS verification + remote admin |
| Bingo | `reset` (alias `bingo:reset`) | ✅ | `sessionId`, `event_id` | `already_processed` on replay | Optional: `target_phase`, `reason`, `source` |
| Blindtest | `session_primary_id` | ❌ | `sessionId` | — | Read (no `event_id`) |
| Blindtest | `players_get` | ❌ | `sessionPrimaryId` | — | Read (no `event_id`) |
| Blindtest | `update_score` | ✅ | `sessionPrimaryId`, `playerId`, `score`, `event_id` | `already_processed` on replay | WS persistence (score) |
| Blindtest | `session_update` | ✅ | `sessionId`, `event_id` | `already_processed` on replay | WS persistence (session end / podium) |
| Blindtest | `deactivate_player` | ✅ | `sessionPrimaryId`, `playerId`, `event_id` | `already_processed` on replay | WS voluntary quit cleanup |
| Blindtest | `player_register` | ✅ | `sessionPrimaryId`, `username`, `event_id` | `already_processed` on replay | Used by WS loadtest bots |
| Quiz | `session_primary_id` | ❌ | `sessionId` | — | Read (no `event_id`) |
| Quiz | `players_get` | ❌ | `sessionPrimaryId` | — | Read (no `event_id`) |
| Quiz | `update_score` | ✅ | `sessionPrimaryId`, `playerId`, `score`, `event_id` | `already_processed` on replay | WS persistence (score) |
| Quiz | `session_update` | ✅ | `sessionId`, `event_id` | `already_processed` on replay | WS persistence (session end / podium) |
| Quiz | `deactivate_player` | ✅ | `sessionPrimaryId`, `playerId`, `event_id` | `already_processed` on replay | WS voluntary quit cleanup |
| Quiz | `player_register` | ✅ | `sessionPrimaryId`, `username`, `event_id` | `already_processed` on replay | Used by WS loadtest bots |
<!-- AUTO-UPDATE:END id="actions-matrix" -->
