# Bingo (bingo.game) — audit WS (résumé)

## 1) Events WS enregistrés (event → handler → fichier)

### Couche transport (`ws` via wrapper)
- `wss: connection` → `WebSocketServer.handleConnection()` → `bingo.game/ws/websocket_server.js`
- `wss: error` → `WebSocketServer.handleServerError()` → `bingo.game/ws/websocket_server.js`
- `ws: message` → `WebSocketServer.handleMessage()` → `bingo.game/ws/websocket_server.js`
- `ws: close` → `WebSocketServer.handleDisconnection()` → `bingo.game/ws/websocket_server.js`
- `ws: error` → `WebSocketServer.handleConnectionError()` → `bingo.game/ws/websocket_server.js`

### Couche application (events émis par le wrapper)
- `connection` → `BingoServer.handleConnection()` → `bingo.game/ws/bingo_server.js`
- `message` → `BingoServer.handleMessage()` → `bingo.game/ws/bingo_server.js`
- `disconnection` → `BingoServer.handleDisconnection()` → `bingo.game/ws/bingo_server.js`
- `error` → `BingoServer.handleError()` → `bingo.game/ws/bingo_server.js`

## 2) Handlers: DB direct ? / Canvas API ?

- `BingoServer.handleConnection()` (`bingo.game/ws/bingo_server.js`) — DB: non ; Canvas API: non
- `BingoServer.handleMessage()` (`bingo.game/ws/bingo_server.js`) — DB: oui (Knex via repositories/DB utils) ; Canvas API: oui (phase_winner via endpoint “canvas” + branche load-test)
- `BingoServer.handleDisconnection()` (`bingo.game/ws/bingo_server.js`) — DB: non ; Canvas API: non
- `BingoServer.handleError()` (`bingo.game/ws/bingo_server.js`) — DB: non ; Canvas API: non

## 3) `deprecated_server.js` branché depuis le point d’entrée ?

- Point d’entrée: `bingo.game/ws/server.js` instancie `BingoServer` depuis `bingo.game/ws/bingo_server.js`.
- `bingo.game/ws/deprecated_server.js` existe mais n’est pas importé/référencé par `bingo.game/ws/server.js` ni par `bingo.game/ws/bingo_server.js`.
