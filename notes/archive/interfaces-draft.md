# Interfaces détectées (liste partielle)

## API HTTP (serveurs Node)
- `GET /logs` — `bingo.game/ws/server.js`
- `GET /logs` — `BT_Global/web/server/server.js`
- `GET /logs` — `CQ_Global/web/server/server.js`
- `OPTIONS /logs` (CORS preflight) — mêmes fichiers que ci-dessus

## API HTTP (endpoints PHP)
- `GET/POST /global_ajax.php` — `Global/global_ajax.php`
- `GET/POST /games_ajax.php` — `GAMES/games_ajax.php` (alias historique: `GAMES/global_ajax.php`)
- `GET /organizer_canvas.php` — `GAMES/organizer_canvas.php`
- `GET /player_canvas.php` — `GAMES/player_canvas.php`
- `GET /remote_canvas.php` — `GAMES/remote_canvas.php`
- `GET/POST /fo/fo_ajax.php` — `website/fo/fo_ajax.php`
- `GET /fo/fo.php` — `website/fo/fo.php`
- `GET /bo/bo.php` — `website/bo/bo.php`
- `GET/POST /api/*.php` — `website/api/`
- `GET/POST /ec/ec_ajax.php` — `PRO/web/ec/ec_ajax.php`
- `POST /ec/ec_webhook_stripe_handler.php` — `PRO/web/ec/ec_webhook_stripe_handler.php`

## WebSocket (types de messages “métier”)
- `BT_Global/web/server/actions/wsHandler.js`: `admin_player_register`, `admin_set_score`, `advertMainFromRemote`, `answerResult`, `checkAnswer`, `checkSession`, `firstClickDetected`, `force_full_current`, `gameState`, `getGameState`, `heartbeat`, `initializeOrUpdateSession`, `log_batch`, `log_event`, `mainPlayerStarted`, `nextSong`, `paper_finalize_end`, `pauseGame`, `playerRemoteStarted`, `quitGame`, `registerOrganizer`, `registerPlayer`, `remoteGameState`, `scores_editing`, `sessionUpdate`, `setAudioOutput`, `songStuck`, `startLoadtest`, `stopLoadtest`, `togglePlayPause`, `updateGameOptions`, `updatePlayers`, `updateVideoMeta`, `update_branding`, `update_session_infos`
- `CQ_Global/web/server/actions/wsHandler.js`: `admin_player_register`, `admin_set_score`, `advertMainFromRemote`, `answerResult`, `checkAnswer`, `checkSession`, `firstClickDetected`, `forceRevealNow`, `gameState`, `getGameState`, `heartbeat`, `initializeOrUpdateSession`, `log_batch`, `log_event`, `mainPlayerStarted`, `nextSong`, `paper_finalize_end`, `pauseGame`, `pauseStateChanged`, `playerRemoteStarted`, `prevSong`, `quitGame`, `registerOrganizer`, `registerPlayer`, `remoteGameState`, `scores_editing`, `sessionUpdate`, `setAudioOutput`, `skipPause`, `songStuck`, `startLoadtest`, `start_support`, `stopLoadtest`, `support_ended`, `togglePause`, `togglePlayPause`, `updateGameOptions`, `updatePlayers`, `updateVideoMeta`, `update_branding`, `update_session_infos`
- `bingo.game/ws/bingo_server.js`: `admin_phase_fail`, `admin_phase_winner`, `admin_player_register`, `auth_client`, `auth_player`, `auth_player_paper`, `auth_remote`, `bonus_request`, `case_click`, `checkSession`, `end_game`, `firstClickDetected`, `force_full_current`, `notification`, `num_connected_players`, `phase_over`, `playerAfterVictory`, `player_quit`, `playing_state`, `quitGame`, `registrationError`, `registration_error`, `remote_action`, `remote_activation`, `reset`, `scores_editing`, `song_start`, `song_stuck`, `state`, `state_update`, `updatePlayers`, `update_branding`, `update_session_infos`, `verification`
- Événements bas niveau du serveur WS: `bingo.game/ws/websocket_server.js` (`connection`, `message`, `disconnection`, `error`)

## Tables SQL référencées (via Knex, `bingo.game/ws/`)
- `bingo_players`
- `championnats_sessions`
- `championnats_sessions_lots`
- `championnats_sessions_lots_to_entites_joueurs`
- `clients_contacts`
- `clients_contacts_to_clients`
- `equipes_joueurs`
- `jeux_bingo_musical_artistes`
- `jeux_bingo_musical_grids_clients`
- `jeux_bingo_musical_morceaux`
- `jeux_bingo_musical_morceaux_to_playlists_clients`
- `jeux_bingo_musical_playlists_clients`
- `jeux_bingo_musical_playlists_clients_logs`
