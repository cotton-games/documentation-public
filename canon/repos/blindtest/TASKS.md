# Repo `blindtest` — Tasks

## Todo
- None (logging canon finalisé). Surveiller futures évolutions gameplay/transport.

## Done
- [x] WS logging en LogEntry v1 (wsHandler, messaging, wsUtils, envUtils, audioControl, loadtest, registration, connection, gameplay); heartbeat client silencieux.
- [x] Timeline métier blindtest : TRACK_START_SIGNAL_RX (info, dedup sid+item_index), TRACK_ENDED (debug), GAME_ENDED (info), PLAYER_REGISTERED (debug), SESSION_PLAYER_COUNT (info, change-only + throttle 2s via helper).
- [x] Tech canon : lifecycle/messaging/protocol/ingestion front (WS_SERVER_LISTENING, WS_MSG_PARSE_ERROR, WS_MSG_MISSING_SESSION_ID, WS_MSG_UNKNOWN_TYPE, WS_SEND_*), WS_IN/WS_OUT restent debug-only throttlés.
