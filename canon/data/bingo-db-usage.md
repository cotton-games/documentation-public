> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Bingo – DB usage

> What tables exist and how they are used.

<!-- AUTO-UPDATE:BEGIN id="db-usage" owner="codex" -->
# bingo.game — DB usage (scan statique)

Liste des dépendances DB et des appels de requêtes détectés (heuristique), sans inclure le SQL ni les corps de fonctions.

## Dépendances DB
- Déclarées: knex, mysql — `bingo.game/ws/package.json`
- Import `knex`: `bingo.game/ws/bingo_loadtest.js`, `bingo.game/ws/bingo_server.js`, `bingo.game/ws/repository/db/utils.js`
- Driver Knex configuré: `mysql` — `bingo.game/ws/knexfile.js`

## Initialisation DB
- `bingo.game/ws/bingo_loadtest.js`: loads knexfile (L3)
- `bingo.game/ws/bingo_loadtest.js`: require('knex')(...) (L4)
- `bingo.game/ws/bingo_server.js`: loads knexfile (L14)
- `bingo.game/ws/bingo_server.js`: require('knex')(...) (L15)
- `bingo.game/ws/repository/db/utils.js`: loads knexfile (L2)
- `bingo.game/ws/repository/db/utils.js`: require('knex')(...) (L3)

## Sites de requêtes (Knex / SQL)
### `bingo.game/ws/bingo_loadtest.js`
- `resolvePlaylistIdFromSessionId()`: championnats_sessions
- Loadtest hydrate la grille via Canvas (`grid_hydrate`) après auth (throttle global + jitter) pour aligner les vérifications sur la grille réelle.

### `bingo.game/ws/bingo_server.js`
- `ensureSessionIdForGame()`: championnats_sessions
- `handleMessage()`: championnats_sessions, jeux_bingo_musical_playlists_clients
- `handleRemoteMessage()`: bingo_players, championnats_sessions, jeux_bingo_musical_playlists_clients

### `bingo.game/ws/repository/db/db_client_repository.js`
- `authenticateClient()`: championnats_sessions, jeux_bingo_musical_playlists_clients

### `bingo.game/ws/repository/db/db_game_repository.js`
- `changeCurrentTrack()`: jeux_bingo_musical_morceaux_to_playlists_clients, jeux_bingo_musical_playlists_clients
- `areSongsPassed()`: jeux_bingo_musical_morceaux_to_playlists_clients
- `saveGameNotification()`: jeux_bingo_musical_playlists_clients_logs

### `bingo.game/ws/repository/db/db_player_repository.js`
- `authenticatePaperPlayer()`: championnats_sessions, jeux_bingo_musical_playlists_clients
- `authenticatePlayer()`: bingo_players, equipes_joueurs, jeux_bingo_musical_grids_clients, jeux_bingo_musical_playlists_clients

### `bingo.game/ws/repository/db/utils.js`
- `acquirePhase()`: jeux_bingo_musical_playlists_clients
- `eraseLogsForPlaylistClient()`: jeux_bingo_musical_playlists_clients_logs
- `getCurrentphase()`: jeux_bingo_musical_playlists_clients
- `getLogsForPlaylistClient()`: jeux_bingo_musical_playlists_clients_logs
- `getNumberOfPassedSongs()`: jeux_bingo_musical_morceaux_to_playlists_clients
- `getOrganizerName()`: clients_contacts, clients_contacts_to_clients
- `getPlaylistInfo()`: jeux_bingo_musical_artistes, jeux_bingo_musical_morceaux, jeux_bingo_musical_morceaux_to_playlists_clients
- `getPlaylistName()`: jeux_bingo_musical_playlists_clients
- `incrementPhase()`: jeux_bingo_musical_playlists_clients
- `markGameFinished()`: jeux_bingo_musical_playlists_clients
- `resetAllGridsForPlaylistClient()`: jeux_bingo_musical_grids_clients
- `resetAllSongsTimestampOfPlaylistClient()`: jeux_bingo_musical_morceaux_to_playlists_clients
- `setStartPhase()`: jeux_bingo_musical_playlists_clients
- `storeEventLog()`: jeux_bingo_musical_playlists_clients_logs
- `updateCurrentSongIndex()`: jeux_bingo_musical_playlists_clients
- `updatePassedSongTimestamp()`: jeux_bingo_musical_morceaux_to_playlists_clients
<!-- AUTO-UPDATE:END id="db-usage" -->
