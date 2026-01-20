# Bingo (bingo-musical) — audit WS (résumé)

## 1) Events WS enregistrés (event → handler → fichier)

### Couche transport (`ws` via wrapper)
- `wss: connection` → `WebSocketServer.handleConnection()` → `bingo-musical/src/ws/websocket_server.js`
- `wss: error` → `WebSocketServer.handleServerError()` → `bingo-musical/src/ws/websocket_server.js`
- `ws: message` → `WebSocketServer.handleMessage()` → `bingo-musical/src/ws/websocket_server.js`
- `ws: close` → `WebSocketServer.handleDisconnection()` → `bingo-musical/src/ws/websocket_server.js`
- `ws: error` → `WebSocketServer.handleConnectionError()` → `bingo-musical/src/ws/websocket_server.js`

### Couche application (events émis par le wrapper)
- `connection` → `BingoServer.handleConnection()` → `bingo-musical/src/ws/bingo_server.js`
- `message` → `BingoServer.handleMessage()` → `bingo-musical/src/ws/bingo_server.js`
- `disconnection` → `BingoServer.handleDisconnection()` → `bingo-musical/src/ws/bingo_server.js`
- `error` → `BingoServer.handleError()` → `bingo-musical/src/ws/bingo_server.js`

## 2) Handlers: DB direct ? / Canvas API ?

- `BingoServer.handleConnection()` (`bingo-musical/src/ws/bingo_server.js`) — DB: non ; Canvas API: non
- `BingoServer.handleMessage()` (`bingo-musical/src/ws/bingo_server.js`) — DB: oui (Knex via repositories/DB utils) ; Canvas API: oui (phase_winner via endpoint “canvas” + branche load-test)
- `BingoServer.handleDisconnection()` (`bingo-musical/src/ws/bingo_server.js`) — DB: non ; Canvas API: non
- `BingoServer.handleError()` (`bingo-musical/src/ws/bingo_server.js`) — DB: non ; Canvas API: non

## 3) `deprecated_server.js` branché depuis le point d’entrée ?

- Point d’entrée: `bingo-musical/src/ws/server.js` instancie `BingoServer` depuis `bingo-musical/src/ws/bingo_server.js`.
- `bingo-musical/src/ws/deprecated_server.js` existe mais n’est pas importé/référencé par `bingo-musical/src/ws/server.js` ni par `bingo-musical/src/ws/bingo_server.js`.
