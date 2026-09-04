# WS evt canon — quiz & blindtest (2026-02-06, updated)

## Canon mapping appliqué (principaux evt)
### Core WS lifecycle / routing
| evt | lvl | msg | meta clés | quiz occurrences | blindtest occurrences |
| --- | --- | --- | --- | --- | --- |
| WS_SERVER_LISTENING | info | WS server listening | port | web/server/server.js | web/server/server.js |
| WS_SERVER_CRITICAL_ERROR | error | WS server critical error | error, stack | web/server/server.js | web/server/server.js |
| WS_CLIENT_CONNECTED | info | Nouvelle connexion WebSocket établie. | origin, remoteAddress, role | web/server/server.js | web/server/server.js |
| WS_CLIENT_IDLE_DISCONNECTED | info | WS client disconnected (idle) | reason=idle | web/server/server.js | web/server/server.js |
| WS_CLIENT_DISCONNECTED | info | Client WS déconnecté | sid, role, closeCode, intent | web/server/actions/wsHandler.js:537 | web/server/actions/wsHandler.js:513 |
| WS_ERROR / WS_MSG_PARSE_ERROR | error | WS error / parse error | error, stack, sid | web/server/actions/wsHandler.js | web/server/actions/wsHandler.js |
| WS_MSG_REJECTED_STALE_PRIMARY | warn | WS message rejected: stale primary | type, socketPrimary, sessionPrimary, sid, role | web/server/actions/wsHandler.js:171 | web/server/actions/wsHandler.js:171 |
| WS_MSG_MISSING_SESSION_ID | warn | WS message rejected: missing sessionId | action, payload_keys | web/server/actions/wsHandler.js:272/286/346/384/412 | web/server/actions/wsHandler.js:253/267/323/361/389 |
| WS_MSG_UNKNOWN_TYPE | warn | WS message rejected: unknown type | type, sid | web/server/actions/wsHandler.js:503 | web/server/actions/wsHandler.js:479 |
| WS_SEND_SESSION_NOT_FOUND | error | WS send failed: session not found | action, target, sid | web/server/messaging.js | web/server/messaging.js |
| WS_SEND_SOCKET_NOT_OPEN | error | WS send failed: socket not open | socketId?, sid? | web/server/messaging.js | web/server/messaging.js |
| WS_SEND_NO_PRIMARY_ORGANIZER | warn | WS send skipped: no primary organizer | sid | web/server/messaging.js | web/server/messaging.js |

### Registration (logV1 dans registration.js)
| evt | lvl | msg | occurrences (quiz) | occurrences (blindtest) |
| --- | --- | --- | --- | --- |
| WS_REG_SECONDARY_SESSION_NOT_FOUND | error | Secondary registration rejected: session not found | web/server/actions/registration.js:41 | registration.js:41 |
| WS_REG_SESSION_CREATED | info | Session created for primary | registration.js:52 | registration.js:52 |
| WS_REG_PRIMARY_ID_RESOLVE_FAILED | warn | Failed to resolve session_primary_id | registration.js:83 | registration.js:84 |
| WS_REG_DEMO_CLEANUP | info | Demo session cleanup | registration.js:101 | registration.js:102 |
| WS_REG_PRIMARY_PROMOTED / ALREADY_ACTIVE / REPLACED / REGISTERED | info | Primary promoted / already active / replaced / registered | registration.js:134/148/156/160 | registration.js:135/149/157/161 |
| WS_REG_SECONDARY_PRESENT / REPLACED | info | Secondary already connected / replaced | registration.js:187/223 | registration.js:188/224 |
| WS_REG_GAME_RESUMED_SENT | info | GAME_RESUMED sent | registration.js:195, wsUtils.js:20 | registration.js:196, wsUtils.js:20 |
| WS_REG_SESSION_NOT_FOUND | error | Player registration failed: session not found | registration.js:386 | registration.js:387 |
| WS_REG_LIMIT_RESET / LIMIT_REACHED | info/warn | session.limitReached reset / Session full | registration.js:399/427 | registration.js:400/428 |
| PLAYER_REGISTERED | debug | Player registered | registration.js:415/479 | registration.js:409/473 |

### Connection / session lifecycle (connection.js)
Key evt: WS_SESSION_NOT_FOUND, WS_CONN_PLAYER_DISCONNECTED, WS_PLAYER_NOT_FOUND, WS_CONN_UNDER_PLAYER_LIMIT, WS_CONN_PLAYER_MARK_INACTIVE, WS_CONN_PENDING_PRIMARY_CANCELLED, WS_CONN_PRIMARY_DISCONNECTED, WS_CONN_FIRST_CLICK_RESET, WS_CONN_PRIMARY_CLOSE_IGNORED, WS_CONN_WAIT_PRIMARY_RECONNECT, WS_CONN_PRIMARY_NOT_RECONNECTED, WS_CONN_SECONDARY_DISCONNECTED, WS_CONN_NO_ORGANIZER_LEFT, WS_CONN_SESSION_DELETED. Occurrences mirrored in both repos (see connection.js lines ~20–300).

#### Player count helper
| evt | lvl | msg | règles | occurrences |
| --- | --- | --- | --- | --- |
| SESSION_PLAYER_COUNT | info | Player count changed | change-only per sid, throttle 2s; meta `{count, prev_count, delta, reason, ...}` | quiz: web/server/actions/playerCount.js:33 ; blindtest: web/server/actions/playerCount.js:33 |

### Audio control (audioControl.js)
Evt: WS_AUDIO_OUTPUT_REQUEST, WS_AUDIO_NO_PRIMARY, WS_AUDIO_REDIRECT_REMOTE/PLAYER, WS_AUDIO_INVALID_OPTION, WS_AUDIO_FIRST_CLICK, WS_AUDIO_SECONDARY_PRESENT, WS_AUDIO_UPDATE_VIDEO_META_RX/TX, WS_AUDIO_START_SUPPORT_FORWARD/ACK. Occurrences mirrored (audioControl.js lines ~98–226).

### Gameplay (gameplay.js)
- Start signal (dedup sid+item_index):
  - Quiz : QUESTION_START_SIGNAL_RX (info) meta `{item_index, remainingTime}` (gameplay.js:264/270)  
  - Blindtest : TRACK_START_SIGNAL_RX (info) meta `{item_index, remainingTime}` (gameplay.js:232/238)
- End of item (debug): QUESTION_ENDED / TRACK_ENDED meta `{item_index, reason, duration_ms, is_jingle?}` (quiz: gameplay.js:327 ; blindtest: gameplay.js:295).
- GAME_ENDED (info) meta `{reason?, podium_size?, top3_player_ids?}` (quiz: gameplay.js:950 ; blindtest: gameplay.js:845).
- Reste des WS_GAME_* (countdown, session update, answer, score, pause...) conservés avec niveaux existants; WS_SESSION_NOT_FOUND / WS_PLAYER_NOT_FOUND restent error/warn.

### Loadtest (loadtest.js + wsHandler.js)
Evt: LOADTEST_REGISTER_PLAYER, LOADTEST_HTTP_REGISTER_OK, LOADTEST_PROFILE_MISSING_PLAYER_ID, LOADTEST_WS_CONNECTED, LOADTEST_REGISTRATION_REFUSED, LOADTEST_ANSWER_CORRECT/INCORRECT/SENT, LOADTEST_ENDGAME_RECEIVED, LOADTEST_WS_CLOSED, LOADTEST_STOP, LOADTEST_START_MISSING_SESSION, LOADTEST_START_INVALID_COUNT, LOADTEST_START, LOADTEST_ATTACH_INVALID/OK. Occurrences mirrored (loadtest.js lines ~129–560; wsHandler.js lines 342/365/etc.).

### Canvas / infra (envUtils.js, wsUtils.js)
Evt: CANVAS_HTTP_NO_ABORT_CONTROLLER, CANVAS_WRITE_TIMEOUT, CANVAS_WRITE_FAIL, CANVAS_WRITE_NO_TOKEN; WS_SERVER_REF_SET / WS_SERVER_REF_MISSING. Occurrences mirrored.

## Heartbeat
- Pas de log heartbeat (aucun evt WS_HEARTBEAT_RX); le message client `heartbeat` ne loggue pas, sert uniquement à rafraîchir `isAlive`.

## Informels restants
- Compte brut `rg "Logger.(log|warn|error)" web/server/actions` :
  - quiz : 2 occurrences (bridge `Logger.logV1` dans `wsHandler.js`) — aucune log informelle.
  - blindtest : 2 occurrences (bridge `Logger.logV1` dans `wsHandler.js`) — aucune log informelle.
- Migrations finalisées (2026-02-06) : tech canon + business timeline (QUESTION_/TRACK_*), helper SESSION_PLAYER_COUNT, PLAYER_REGISTERED en debug, heartbeat silencieux.
