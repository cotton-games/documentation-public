> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Bingo – Write map

> Who writes what, where, and why (contractual).

<!-- AUTO-UPDATE:BEGIN id="write-map" owner="codex" -->
# Bingo — WS writes vs Canvas API writes (evidence-based)

Objectif: cartographier les **écritures DB** initiées par le WS Bingo et indiquer si elles passent désormais par la **Canvas API (PHP)**.

## Migré (writes via Canvas API, idempotent)

### `session_update` (déclenché par WS `song_start`)
- WS → Canvas API:
  - `bingo-musical/src/ws/bingo_server.js` (handler `case "song_start"`) → POST `game=bingo&action=session_update`
- Payload minimum:
  - `sessionId`, `id_song`, `position`, `event_id`
- Preuve (docs):
  - `docs/specs/tests/c1.md` + `docs/specs/smoke-canvas-api.md` (idempotence `already_processed`)

### `case_click` (déclenché par WS player `case_click`)
- WS → Canvas API:
  - `bingo-musical/src/ws/bingo_server.js` (handler `case "case_click"`) → POST `game=bingo&action=bingo:case_click`
- Payload minimum:
  - `sessionId`, `playerId`, `gridId`, `num_case`, `clicked`, `event_id`
- Preuve (docs):
  - `docs/specs/tests/c2.md` + `docs/specs/smoke-canvas-api.md`

### `end_game` (déclenché par WS `end_game`)
- WS → Canvas API:
  - `bingo-musical/src/ws/bingo_server.js` (handler `case "end_game"`) → POST `game=bingo&action=bingo:end_game`
- Payload minimum:
  - `sessionId`, `event_id`
  - optionnels: `reason`, `ended_at`
- Preuve (docs):
  - `docs/specs/smoke-canvas-api.md`

### `phase_winner` (déclenché par WS `verification` et remote `admin_phase_winner`)
- WS → Canvas API:
  - `bingo-musical/src/ws/bingo_server.js` (handlers `handleVerificationRequestMessage()` et `case "admin_phase_winner"`) → POST `game=bingo&action=phase_winner`
- Payload minimum:
  - `sessionId`, `playerId`, `phase`, `event_id`
- Remarque:
  - L’API accepte aussi la forme `action=bingo:phase_winner` (normalisation côté bridge).

### `reset` (déclenché par WS client `reset`)
- WS → Canvas API:
  - `bingo-musical/src/ws/bingo_server.js` (handler `case "reset"`) → POST `game=bingo&action=bingo:reset`
- Tables touchées (côté PHP, transaction):
  - `jeux_bingo_musical_grids_clients` (reset timestamps + `flag_bonus`)
  - `jeux_bingo_musical_morceaux_to_playlists_clients` (reset timestamps + `flag_listening`)
  - `jeux_bingo_musical_playlists_clients_logs` (delete)
  - `championnats_sessions_lots_to_entites_joueurs` (delete via join lots/session)
  - `jeux_bingo_musical_playlists_clients` (`phase_courante`)

## Writes DB directs depuis le WS
- Aucun write DB “métier” n’est effectué par le WS Bingo (writes délégués à la Canvas API).

## Inconnu / à vérifier
- Actions “bonus” (`bonus_request`) : code présent mais le chemin d’écriture DB n’est pas démontré ici (à confirmer avant de conclure une migration complète).
<!-- AUTO-UPDATE:END id="write-map" -->

<!-- AUTO-UPDATE:BEGIN id="write-sources" owner="codex" -->
## Source code pointers (auto)
- WS→Canvas API (writes): `bingo-musical/src/ws/bingo_server.js` (search `postCanvasForm(`).
- Bridge + idempotence: `GAMES/global_ajax.php` (write actions require `event_id`, returns `already_processed` on replay).
- PHP handlers (writes): `GAMES/includes/canvas/php/bingo_adapter_glue.php` (functions `bingo_api_session_update`, `bingo_api_case_click`, `bingo_api_end_game`, `bingo_api_phase_winner`).
- Evidence docs: `docs/specs/smoke-canvas-api.md`, `docs/specs/tests/c1.md`, `docs/specs/tests/c2.md`.
<!-- AUTO-UPDATE:END id="write-sources" -->
