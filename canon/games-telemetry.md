# Games Front Telemetry & Logging

## Contexte
- Périmètre : front Canvas du repo `games/web/includes/canvas/*` (organizer/player/remote).
- Objectif : **zéro log ad hoc** dans le métier. Le front émet uniquement des événements `telemetry:*` sur `Bus`; `logger.global.js` est le seul producteur de logs structurés (buffer/flush WS).
- Rôles couverts : organizer (Canvas), player, remote.

## Contrat telemetry (front)
- Bus namespace : `telemetry:*`.
- Router : `logger.global.js` écoute `Bus.on('telemetry:*', handler)` et pousse un log structuré `{ ts, level, source:"GAMES", game, role, session_id, event, meta }` dans le buffer existant.
- Niveaux résolus automatiquement :
  - `DEBUG` : `telemetry:ws:send|recv`, `telemetry:api:call:start`, `telemetry:hydrate:start`
  - `INFO` : `telemetry:front:boot`, `telemetry:session:init`, `telemetry:hydrate:ok`, `telemetry:api:call:ok`, `telemetry:ws:status`, `telemetry:ui:action`, `telemetry:session:end`
  - `WARN/ERROR` : `telemetry:front:error`, `telemetry:front:unhandledrejection`, `telemetry:error:handler`, tout `*:fail`
- Événements disponibles :
  - `telemetry:front:boot`
  - `telemetry:session:init`
  - `telemetry:hydrate:start|ok|fail`
  - `telemetry:api:call:start|ok|fail`
  - `telemetry:ws:status`
  - `telemetry:ws:send`
  - `telemetry:ws:recv`
  - `telemetry:ui:action`
  - `telemetry:error:handler`
  - `telemetry:front:error`
  - `telemetry:front:unhandledrejection`
  - `telemetry:session:end`

## Règle anti-logger
- Interdit : tout `Logger.*` ou `console.*` dans le métier (`includes/canvas/**`) hors `core/logger.global.js`.
- Garde-fou : script `games/web/check-no-logger.sh` échoue si `Logger.` est trouvé (hors `logger.global.js`). À brancher dans CI.

## Implémentation (résumé des changements)
- `core/bus.js` : support des wildcards (`Bus.on('telemetry:*', ...)`) + émission `telemetry:error:handler` sur exception de handler.
- `core/logger.global.js` : routeur telemetry unique, niveaux auto, réémission des erreurs/unhandled via `telemetry:*`.
- `core/ws_connector.js` : plus de filtres/logs ; émet `telemetry:ws:*` (status/send/recv) et délègue au router.
- `core/boot_organizer.js` + play (`register.js`, `play-ui.js`, `play-ws.js`) : tous les `Logger.*` remplacés par des `telemetry:*` (`ui:action`, `api:call:*`, `front:error`, etc.).

## Usage / mapping rapide
- Émettre un jalon fonctionnel (UX, boot, etc.) : `Bus.emit('telemetry:ui:action', { action:'xxx', ...meta })`.
- Signaler un statut WS : `Bus.emit('telemetry:ws:status', { state:'open|closed|error', ... })`.
- Trace API : `Bus.emit('telemetry:api:call:start|ok|fail', { api_action:'...', request_id, ... })`.
- Hydratation : `telemetry:hydrate:start|ok|fail`.
- Erreur front : `Bus.emit('telemetry:front:error', { tag, message, stack })` ou `telemetry:front:unhandledrejection`.
- Erreur handler Bus : laisser `Bus.emit` remonter vers `telemetry:error:handler`.

## Points d’attention
- Le buffer/flush WS existant (log_batch/log_event) est conservé ; le routeur telemetry ne change pas les mécanismes de flush.
- Les payloads envoyés via `telemetry:*` doivent rester compacts (pas de gros objets de jeu).
- `Bus.emit` propage désormais le nom d’événement aux handlers wildcard (2ᵉ argument) pour la génération de logs.
