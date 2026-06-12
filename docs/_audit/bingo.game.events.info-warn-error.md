# Bingo WS — Inventaire evt INFO / WARN / ERROR (source code 2026-02-06)

## Table (principaux evt)
| evt | lvl | src | where (file:line) | msg (constant ?) | meta clés principales | notes |
| --- | --- | --- | --- | --- | --- | --- |
| CONFIG | debug | BINGO_WS | ws/bingo_server.js:70-96 | WS config resolved | canvas_endpoint_resolved, canvas_host, canvas_endpoint_source, token_present, token_source, env_file_* | init, attendu par viewer (mais émis en debug) |
| CONFIG_MISSING_TOKEN | warn | BINGO_WS | ws/bingo_server.js:97-113 | Canvas service token missing… | canvas_host, canvas_endpoint_resolved, hint | absence token service |
| WS_SERVER_START | info | BINGO_WS | ws/bingo_server.js:222 | Bingo server started | role=organizer | démarrage WS |
| WS_SERVER_STOP | warn | BINGO_WS | ws/bingo_server.js:234 | Bingo server stopped | role=organizer | arrêt WS |
| WS_CONNECT | info | BINGO_WS | ws/bingo_server.js:240-262 | (dynamic) | sid, ws_role, origin | nouvelle connexion WS |
| SESSION_PLAYER_COUNT | info | BINGO_WS | ws/bingo_server.js:190-208 | Player count changed | game_id, count, prev_count, delta, reason | throttle 2s, par sid |
| FRONT_LOG_EMPTY | warn | BINGO_WS | ws/bingo_server.js:265-273 | batch empty | raw_entries | log_batch vide |
| FRONT_LOG_REJECTED | warn | BINGO_WS | ws/bingo_server.js:274-283 | rejected invalid front log | reason | entrée front invalide |
| FRONT_LOG_BATCH_PARTIAL | warn | BINGO_WS | ws/bingo_server.js:324-334 | partial batch accepted | accepted, rejected | batch partiellement accepté |
| CHECK_SESSION_ERROR | error | BINGO_WS | ws/bingo_server.js:389-406 | (dynamic) | sid, err | erreur contrôle session |
| AUTH_DUPLICATE_CONNECTION | warn | BINGO_WS | ws/bingo_server.js:603-611 | duplicate connection refused | sid, ws_role, ip | contrôle anti-dup |
| AUTH_MAX_PLAYERS | warn | BINGO_WS | ws/bingo_server.js:619-624 | max players reached | sid, max_players | limite atteinte |
| AUTH_OK | info | BINGO_WS | ws/bingo_server.js:640-647 etc. | Client authenticated | client_id, game_id, is_demo | succès auth (plusieurs occurrences) |
| WS_ROLE_CONNECTED | info | BINGO_WS | ws/bingo_server.js:656-663, 914-920 | Role connected | sid, role | connexion rôle |
| AUTH_FAIL | warn | BINGO_WS | ws/bingo_server.js:688-705 etc. | Auth failed | reason, details | échec auth |
| AUTH_PURGE_INACTIVE | debug | BINGO_WS | ws/bingo_server.js:756-764 | Purge inactive players | removed, game_id | purge démo (debug) |
| AUTH_CLIENT_REPLACED | warn | BINGO_WS | ws/bingo_server.js:784-795 | Existing client disconnected | game_id | remplacement primary |
| ORGANIZER_RECONNECTED | info | BINGO_WS | ws/bingo_server.js:848-855 | Organizer reconnected | sid | reprise session |
| GAME_RESUMED_SENT | info | BINGO_WS | ws/bingo_server.js:864-871 | Game state replayed | sid | reprise après reconnexion |
| REMOTE_REPLACED | warn | BINGO_WS | ws/bingo_server.js:943-971 | Remote replaced | sid, new_ws | remplacement remote |
| PLAYER_QUIT_REQUESTED | info | BINGO_WS | ws/bingo_server.js:1023-1031 | Player quit requested | sid, player_id | demande quit |
| VERIFY_REQUEST | info | BINGO_WS | ws/bingo_server.js:1040-1048 | verify request | sid | vérification support |
| VERIFY_ERROR | error | BINGO_WS | ws/bingo_server.js:1049-1056 | verify error | sid, err | échec vérification |
| PLAYER_MESSAGE_UNKNOWN | warn | BINGO_WS | ws/bingo_server.js:1057-1064 | Unknown player message | type | msg inconnu |
| CANVAS_WRITE_SKIPPED | warn | BINGO_WS | ws/bingo_server.js:1109-1117 etc. | Canvas write skipped | reason, action | write non envoyée |
| CANVAS_WRITE_OK | info | BINGO_WS | ws/bingo_server.js:1140-1150 etc. | Canvas write ok | action, latency_ms, event_id | succès write |
| CANVAS_WRITE_FAIL | warn | BINGO_WS | ws/bingo_server.js:1156-1167 etc. | Canvas write failed | action, statusCode/errCode, event_id, latency_ms | échec write |
| SESSION_RESET | info | BINGO_WS | ws/bingo_server.js:1175-1185 | Session reset | reason | reset session |
| TRACK_START_DUPLICATE_IGNORED | warn | BINGO_WS | ws/bingo_server.js:1230-1237 | duplicate track ignored | item_id | dédup start |
| TRACK_START | info | BINGO_WS | ws/bingo_server.js:1321-1333 | Track start | item_index, item_id, is_jingle | début morceau |
| SESSION_END | info | BINGO_WS | ws/bingo_server.js:1402-1423, 1531-1538 | Session end | result, winner | fin session |
| END_GAME_FAILED | warn | BINGO_WS | ws/bingo_server.js:1544-1553 | end game failed | err | échec end_game |
| SONG_STUCK | warn | BINGO_WS | ws/bingo_server.js:1565-1573 | Song stuck | item_id | stuck audio |
| SESSION_INFOS_UPDATED | info | BINGO_WS | ws/bingo_server.js:1658-1668 | Session infos updated | payload | mise à jour état |
| SESSION_BRANDING_UPDATED | info | BINGO_WS | ws/bingo_server.js:1687-1695 | Branding updated | branding | MAJ branding |
| REMOTE_ACTION | info | BINGO_WS | ws/bingo_server.js:1715-1724 | Remote action | action, payload | action remote |
| ADMIN_PHASE_FAIL | warn | BINGO_WS | ws/bingo_server.js:1759-1768 | Admin phase fail | err | admin phase KO |
| ADMIN_PHASE_WINNER_BAD_PARAMS | warn | BINGO_WS | ws/bingo_server.js:1778-1787 | Bad params | details | |
| ADMIN_PHASE_WIN | info | BINGO_WS | ws/bingo_server.js:1860-1873 | Phase win | winner_id/name | |
| ADMIN_PHASE_WINNER_FAIL | warn | BINGO_WS | ws/bingo_server.js:1911-1916 | Winner fail | err | |
| ADMIN_PHASE_WINNER_ERROR | error | BINGO_WS | ws/bingo_server.js:1918-1926 | Winner error | err | |
| ADMIN_PLAYER_REGISTER_BAD_PARAMS | warn | BINGO_WS | ws/bingo_server.js:1933-1942 | Bad params | details | |
| ADMIN_PLAYER_REGISTER_SESSION_NOT_FOUND | warn | BINGO_WS | ws/bingo_server.js:1949-1958 | Session not found | sid | |
| ADMIN_PLAYER_REGISTER | info | BINGO_WS | ws/bingo_server.js:1984-1989 | Admin player register | player_id | |
| ADMIN_PLAYER_REGISTER_ERROR | error | BINGO_WS | ws/bingo_server.js:1990-1998 | Admin player register error | err | |
| REMOTE_MESSAGE_UNKNOWN | warn | BINGO_WS | ws/bingo_server.js:2000-2010 | Unknown remote msg | type | |
| PHASE_FAIL | warn | BINGO_WS | ws/bingo_server.js:2045-2056 | Phase fail | err | |
| NOTIF_THROTTLED | warn | BINGO_WS | ws/bingo_server.js:2067-2075 | Notification throttled | type, delayMs | |
| VERIFY_DURATION | info | BINGO_WS | ws/bingo_server.js:2081-2089 | Verify duration | ms | perf diag |
| WS_DISCONNECT | info | BINGO_WS | ws/bingo_server.js:2229-2365 | WS disconnected | reason, code, ws_role | multiples endroits |
| GAME_PAUSED_ON_DISCONNECT | info | BINGO_WS | ws/bingo_server.js:2288-2298 | Game paused on disconnect | sid | |
| ORGANIZER_RECONNECT_WAIT | info | BINGO_WS | ws/bingo_server.js:2307-2316 | Waiting for organizer reconnect | sid, timeout | |
| ORGANIZER_RECONNECT_EXPIRED | warn | BINGO_WS | ws/bingo_server.js:2324-2333 | Reconnect expired | sid | |
| ENSURE_SESSION_ID_FAILED | error | BINGO_WS | ws/bingo_server.js:2403-2414 | Ensure session id failed | err | |
| PLAYBACK_STATE_CHANGED | info | BINGO_WS | ws/bingo_server.js:2427-2436 | Playback state changed | state | |
| PLAYER_SOCKET_CLOSE_FAILED | warn | BINGO_WS | ws/bingo_server.js:2591-2598 | Socket close failed | err | |

## Timeline INFO candidates (non-transport)
- WS_SERVER_START, WS_CONNECT, AUTH_OK, WS_ROLE_CONNECTED, SESSION_PLAYER_COUNT, SESSION_INFOS_UPDATED, SESSION_BRANDING_UPDATED, TRACK_START, SESSION_END, GAME_PAUSED_ON_DISCONNECT, ORGANIZER_RECONNECT_WAIT, PLAYBACK_STATE_CHANGED, ADMIN_PLAYER_REGISTER, ADMIN_PHASE_WIN, VERIFY_DURATION.
- INFO transport-like (à écarter si besoin) : WS_CONNECT, WS_DISCONNECT (multiple), SESSION_PLAYER_COUNT (fréquent).

## WARN (bruit potentiel)
- CONFIG_MISSING_TOKEN, FRONT_LOG_* (EMPTY/REJECTED/BATCH_PARTIAL), AUTH_MAX_PLAYERS, AUTH_FAIL, AUTH_CLIENT_REPLACED, REMOTE_REPLACED, CANVAS_WRITE_FAIL, TRACK_START_DUPLICATE_IGNORED, END_GAME_FAILED, SONG_STUCK, ADMIN_PHASE_FAIL/… , PHASE_FAIL, NOTIF_THROTTLED, ORGANIZER_RECONNECT_EXPIRED, PLAYER_SOCKET_CLOSE_FAILED.

## ERROR (critiques)
- CHECK_SESSION_ERROR, VERIFY_ERROR, ADMIN_PHASE_WINNER_ERROR, ADMIN_PLAYER_REGISTER_ERROR, ENSURE_SESSION_ID_FAILED, generic ERROR handlers (bingo_server.js:521/538/554), VERIFY_ERROR.

## Couverture attendue
- CONFIG / CONFIG_MISSING_TOKEN présents (CONFIG en debug).
- Canvas writes : SKIPPED/OK/FAIL couverts.
- ROLE_AUDIT est émis en debug (logger.js:213) — non listé ici car hors info/warn/error.

