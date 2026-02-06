# Changelog

> Keep it short: user-facing behavior + interfaces + migrations.

<!-- AUTO-UPDATE:BEGIN id="changelog-latest" owner="codex" -->
## Unreleased
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
