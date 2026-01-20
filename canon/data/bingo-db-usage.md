> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Bingo – DB usage

> What tables exist and how they are used.

<!-- AUTO-UPDATE:BEGIN id="db-usage" owner="codex" -->
# bingo-musical — DB usage (scan statique)

Liste des dépendances DB et des appels de requêtes détectés (heuristique), sans inclure le SQL ni les corps de fonctions.

## Dépendances DB
- Déclarées: knex, mysql — `bingo-musical/src/ws/package.json`
- Import `knex`: `bingo-musical/src/ws/bingo_loadtest.js`, `bingo-musical/src/ws/bingo_server.js`, `bingo-musical/src/ws/deprecated_server.js`, `bingo-musical/src/ws/repository/db/utils.js`
- Driver Knex configuré: `mysql` — `bingo-musical/src/ws/knexfile.js`

## Initialisation DB
- `bingo-musical/src/ws/bingo_loadtest.js`: loads knexfile (L3)
- `bingo-musical/src/ws/bingo_loadtest.js`: require('knex')(...) (L4)
- `bingo-musical/src/ws/bingo_server.js`: loads knexfile (L14)
- `bingo-musical/src/ws/bingo_server.js`: require('knex')(...) (L15)
- `bingo-musical/src/ws/deprecated_server.js`: loads knexfile (L9)
- `bingo-musical/src/ws/deprecated_server.js`: require('knex')(...) (L10)
- `bingo-musical/src/ws/repository/db/utils.js`: loads knexfile (L2)
- `bingo-musical/src/ws/repository/db/utils.js`: require('knex')(...) (L3)

## Sites de requêtes (Knex / SQL)
### `bingo-musical/src/ws/bingo_loadtest.js`
- `resolvePlaylistIdFromSessionId()`: championnats_sessions

### `bingo-musical/src/ws/bingo_server.js`
- `ensureSessionIdForGame()`: championnats_sessions
- `handleMessage()`: championnats_sessions, jeux_bingo_musical_playlists_clients
- `handleRemoteMessage()`: bingo_players, championnats_sessions, jeux_bingo_musical_playlists_clients

### `bingo-musical/src/ws/deprecated_server.js`
- `areSongsPassed()`: jeux_bingo_musical_morceaux_to_playlists_clients
- `checkClientAuth()`: jeux_bingo_musical_playlists_clients
- `checkClientAuthV2()`: championnats_sessions, jeux_bingo_musical_playlists_clients
- `checkPlayerAuth()`: jeux_bingo_musical_grids_clients
- `fetchPlayerProfileWithCompat()`: bingo_players, equipes_joueurs, jeux_bingo_musical_grids_clients
- `getBoxNumbersFromLineIndices()`: jeux_bingo_musical_grids_clients
- `getFormatForPlaylistClient()`: jeux_bingo_musical_playlists_clients
- `getGridNumber()`: jeux_bingo_musical_grids_clients
- `getIdPlaylistClientFromGrid()`: jeux_bingo_musical_grids_clients
- `getNumberOfClickableSongs()`: jeux_bingo_musical_morceaux_to_playlists_clients
- `getPlayerName()`: bingo_players
- `getPlaylistClientGridFormat()`: jeux_bingo_musical_playlists_clients
- `heartbeat()`: jeux_bingo_musical_grids_clients

### `bingo-musical/src/ws/repository/db/db_client_repository.js`
- `authenticateClient()`: championnats_sessions, jeux_bingo_musical_playlists_clients

### `bingo-musical/src/ws/repository/db/db_game_repository.js`
- `areSongsPassed()`: jeux_bingo_musical_morceaux_to_playlists_clients
- `saveGameNotification()`: jeux_bingo_musical_playlists_clients_logs

### `bingo-musical/src/ws/repository/db/db_player_repository.js`
- `authenticatePaperPlayer()`: championnats_sessions, jeux_bingo_musical_playlists_clients
- `authenticatePlayer()`: bingo_players, equipes_joueurs, jeux_bingo_musical_grids_clients, jeux_bingo_musical_playlists_clients

### `bingo-musical/src/ws/repository/db/utils.js`
- `acquirePhase()`: jeux_bingo_musical_playlists_clients
- `deactivateBonus()`: jeux_bingo_musical_grids_clients
- `eraseLogsForPlaylistClient()`: jeux_bingo_musical_playlists_clients_logs
- `getCurrentlyPlayedSong()`: jeux_bingo_musical_artistes, jeux_bingo_musical_morceaux, jeux_bingo_musical_morceaux_to_playlists_clients, jeux_bingo_musical_playlists_clients
- `getCurrentphase()`: jeux_bingo_musical_playlists_clients
- `getLogsForPlaylistClient()`: jeux_bingo_musical_playlists_clients_logs
- `getNumberOfPassedSongs()`: jeux_bingo_musical_morceaux_to_playlists_clients
- `getOrganizerName()`: clients_contacts, clients_contacts_to_clients
- `getPlaylistInfo()`: jeux_bingo_musical_artistes, jeux_bingo_musical_morceaux, jeux_bingo_musical_morceaux_to_playlists_clients
- `getPlaylistName()`: jeux_bingo_musical_playlists_clients
- `getPrizesForPlayer()`: championnats_sessions, championnats_sessions_lots, championnats_sessions_lots_to_entites_joueurs
- `getPrizesList()`: championnats_sessions, championnats_sessions_lots
- `handleCaseClickMsg()`: jeux_bingo_musical_grids_clients
- `incrementPhase()`: jeux_bingo_musical_playlists_clients
- `isBonusNotConsumed()`: jeux_bingo_musical_grids_clients
- `markGameFinished()`: jeux_bingo_musical_playlists_clients
- `resetAllGridsForPlaylistClient()`: jeux_bingo_musical_grids_clients
- `resetAllSongsTimestampOfPlaylistClient()`: jeux_bingo_musical_morceaux_to_playlists_clients
- `resetPrizesForPlaylistClient()`: championnats_sessions, championnats_sessions_lots, championnats_sessions_lots_to_entites_joueurs
- `savePrizeForPlayer()`: championnats_sessions_lots_to_entites_joueurs
- `setStartPhase()`: jeux_bingo_musical_playlists_clients
- `storeEventLog()`: jeux_bingo_musical_playlists_clients_logs
- `updateCurrentSongIndex()`: jeux_bingo_musical_playlists_clients
- `updatePassedSongTimestamp()`: jeux_bingo_musical_morceaux_to_playlists_clients
<!-- AUTO-UPDATE:END id="db-usage" -->
