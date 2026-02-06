# Repo `quiz` — Tasks

## Todo
- None (logging canon complete). Keep watching for future event additions (new gameplay phases, retries).

## Done
- [x] WS logging normalisé en LogEntry v1 (wsHandler, messaging, wsUtils, envUtils, audioControl, loadtest, registration, connection, gameplay); heartbeat client ignoré (pas de log).
- [x] Timeline métier quiz : QUESTION_START_SIGNAL_RX (info, dedup sid+item_index), QUESTION_ENDED (debug), GAME_ENDED (info), PLAYER_REGISTERED (debug), SESSION_PLAYER_COUNT (info, change-only + throttle 2s via helper).
- [x] Tech canon figé : lifecycle/messaging/protocol/ingestion front (WS_SERVER_LISTENING, WS_MSG_PARSE_ERROR, WS_MSG_MISSING_SESSION_ID, WS_MSG_UNKNOWN_TYPE, WS_SEND_*), WS_IN/WS_OUT restent debug-only throttlés.
