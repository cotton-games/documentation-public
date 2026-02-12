# Changelog

> Keep it short: user-facing behavior + interfaces + migrations.

<!-- AUTO-UPDATE:BEGIN id="changelog-latest" owner="codex" -->
## Unreleased
- Bingo phase winners canonical migration (games): `bingo_api_phase_winner` now resolves winner identity key-first (`player_id` canonique) before persistence; added `phase_winner_conflict` explicit error code; added support for canonical winner key storage/read via `bingo_phase_winners.player_id_key` (with legacy fallback), plus SQL ambiguity fix on joined conflict query (`w.session_id`, `w.phase`).
- Logs viewer chips fix (games): global level chips (`total/debug/info/warn/error`) now request forced stats recomputation (`stats=1&force=1`) to avoid stale cache mismatch after front flush (`visibles` unchanged and still client-side).
- Bingo waiting-state hotfix: changing organizer game options (e.g. `songDuration`) no longer clears player prizes/lots UI; front now sends `update_session_infos` only for paper/session-control fields, and Bingo WS no longer emits implicit empty `prizes` payloads when none are provided.
- Quiz/blindtest WS hotfix: fixed organizer disconnect crash (`ReferenceError: deactivations is not defined`) by restoring player deactivation promise collection in `disconnectPlayers`; session end now completes DB deactivate + socket cleanup without runtime error.
- Quiz/blindtest player reveal is now key-first: server emits `answerReveal` only after reveal timing/lock (wrong-answer players), carrying `{correctOption, correctOptionKey}`; player UI applies highlight by `data-option-key` with legacy text/index fallback.
- Quiz/blindtest security hotfix: `correctOptionKey` is now stripped from all player-bound WS payloads (`gameState/sessionUpdate/socket sends`) with a server-side guard log (`WS_PLAYER_PAYLOAD_STRIPPED`), while remote/organizer key-first reveal remains intact.
- Player answer compat migration: front now sends `selectedOptionKey` alongside `selectedOption`; server evaluates key-first when key is present with legacy fallback, and emits debug signals `PLAYER_ANSWER_RX` / `PLAYER_ANSWER_EVAL`.
- Remote quiz/blindtest: stabilize correct option reveal with key-first matching (`remote/options:correct` carries `{text,key}`, `sessionUpdate/gameState` propagate `correctOptionKey`, options carry stable `key`, and remote UI patches reveal via `data-option-key`), preventing blindtest/quiz reveal loss on text-format mismatches.
- BO “Jeux et joueurs” : drilldown sessions figé (table `reporting_games_sessions_detail` via cron, addition stricte joueurs) + modal filtrable (jeu/client) avec lien `logs_session.html`.
- Bingo `reset` migrated to Canvas API; WS no longer performs DB writes for reset.
- Removed DB log persistence from WS (no more `saveGameNotification` writes); logs remain file/stdout.
- Front clients updated to handle Canvas bridge envelope responses (`data` unwrapping).
- Organizer: hide customization/options buttons and QR/remote block for client `#1557`.
- Bingo WS/front: normalize `passed_song` counter key (`num_passed_songs`, legacy fallback `x`) + accept `registration_error` alias.
- Bingo demo reset: organizer calls Canvas API `resetdemo` then reloads; remote/player are resynced via WS `demo_reset` (no WS DB reset), and WS in-memory state is reset to neutral (`phase=0`, `num_passed_songs=0`, `is_playing=false`).
- Bingo: fix organizer WS `auth_client` payload (`id_playlist_client`) by propagating playlistId via DOM/preload/meta; prevent `session_update` from re-writing `morceau_courant` while `phase_courante=0` (avoids post-reset song_start races).
- Logs viewer/proxy (games): proxy simplifié (JSON stable `logs[]/meta`, tri asc, `session_id` normalisé, filtres min_level + recherche, stats raw/eff/invalid) ; viewer `logs_session.html` lit la nouvelle meta, affiche INFO/WARN/ERROR par défaut (DEBUG sur demande) et conserve l’export JSONL; action-map alignée (`loadingSupport`/`playerReady`→debug, `SUPPORT_START`→info, `WS_IN/WS_OUT`→debug, `JOIN_ERROR` warn).
- Logs viewer reset (games): `logs_session.html` réduit au minimum (session_id + min_level + charger, pas de pagination/recherche/flush/export), fetch unique page=1 limit=500, header explicite range_ts + pages_loaded/page_count + total + raw/eff/invalid; export désactivé.
<!-- AUTO-UPDATE:END id="changelog-latest" -->
