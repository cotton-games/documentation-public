# Handoff

<!-- NOTE TO CODEX:
Only edit inside AUTO-UPDATE blocks.
If required info is missing, update HANDOFF next steps instead of guessing.
-->

> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

## Contexte (humain)
Objectif : permettre à un agent IA de reprendre le travail immédiatement, avec une vue d’ensemble assez détaillée (archi, interfaces, entrypoints, DB) et un “où on en est” maintenu.

<!-- AUTO-UPDATE:BEGIN id="handoff-status" owner="codex" -->
## Current status (auto)
- What works (confirmed):
  - WS `song_start` persists via Canvas API `bingo.session_update` (idempotent `event_id`) (`docs/specs/tests/c1.md`).
  - WS player `case_click` persists via Canvas API `bingo.case_click` (idempotent `event_id`) (`docs/specs/tests/c2.md`).
  - WS `end_game` persists via Canvas API `bingo.end_game` (idempotent `event_id`) (`docs/specs/smoke-canvas-api.md`).
  - WS `verification` / remote `admin_phase_winner` persists via Canvas API `bingo.phase_winner` (idempotent `event_id`) (code path in `bingo-musical/src/ws/bingo_server.js`).
- WS `reset` persists via Canvas API `bingo.reset` (idempotent `event_id`) (code path in `bingo-musical/src/ws/bingo_server.js`).
- WS Bingo contract (server-side): `num_passed_songs` means “how many songs have been marked listened/played (count of `listening_timestamp > 0`)”, not “current song index”.
  - At phase/session start after `reset`, server forces `state.num_passed_songs = 0` and broadcasts `reset_game` + `state`.
  - On first `song_start`, server calls Canvas API `bingo.session_update`, reads `apiRes.numPassedSongs`, then broadcasts `passed_song { num_passed_songs: <count> }` (expected to become `1` on the first song).
  - Player `state` payload always includes `num_passed_songs`, but WS logs are compacted and omit this field from the printed `state` payload (don’t use logs alone as proof for this one).
- In progress / not migrated:
  - TBD / unknown: bonus flows and any remaining write paths should be re-audited before claiming “no writes” across all code paths.
- Known issues / debt:
  - Repo still contains legacy Knex write helpers (`bingo-musical/src/ws/repository/db/utils.js`), but WS should not use them for writes anymore; keep as debt until removal is safe.
  - Canvas bridge auth now distinguishes front vs service-only calls; regression risk if the front inadvertently starts sending `event_id` or if a write action is added without being marked service-only.
  - If the front expects “first cell checkable as soon as phase is En cours” while `num_passed_songs` is still `0`, that’s a contract mismatch: fix should be front-side or via a new WS field/event (do not repurpose `num_passed_songs` without coordination).
  - If Canvas API service token is missing (`CANVAS_SERVICE_TOKEN`), service-only writes like `bingo.session_update` will fail (HTTP 403 `misconfigured: Canvas service token not configured`), which prevents `numPassedSongs` from incrementing and can leave players stuck with `num_passed_songs = 0`.
<!-- AUTO-UPDATE:END id="handoff-status" -->

<!-- AUTO-UPDATE:BEGIN id="handoff-next-steps" owner="codex" -->
## Next steps (auto checklist)
- [x] Audit des writes WS Bingo (API vs DB direct) basé sur `docs/specs/tests/c1.md`, `docs/specs/tests/c2.md`, `docs/specs/smoke-canvas-api.md` + code WS.
- [x] Migrer `reset` vers Canvas API et supprimer la persistance logs DB côté WS.
- [x] Aligner les clients front sur l’enveloppe Canvas bridge `{ ok, data, error, ts }` (unwrap `data`).
- [ ] Re-audit final: confirmer qu’aucun chemin WS ne fait de write Knex (incluant flows rarement utilisés, ex. bonus).
- [ ] Nettoyage (optionnel, non bloquant): retirer/isolier les modules DB write legacy côté WS si plus aucun read n’en dépend.
- [ ] Ajouter un test manuel “end_game” (analogue à C1/C2) si souhaité; sinon garder smoke comme seule preuve.
<!-- AUTO-UPDATE:END id="handoff-next-steps" -->

<!-- AUTO-UPDATE:BEGIN id="handoff-risks" owner="codex" -->
## Risks / debt (auto)
- “Zéro write DB côté WS” dépend d’un re-audit des flows peu fréquents (ex. bonus); éviter d’affirmer sans preuve exhaustive.
- Canvas bridge auth change: front calls should succeed without `X-Service-Token`; verify `player_register` from browser in dev after deploy.
<!-- AUTO-UPDATE:END id="handoff-risks" -->

## Validation (humain)
- Smoke test Canvas API : `docs/specs/smoke-canvas-api.md`
- Tests de lots : `docs/specs/tests/`
