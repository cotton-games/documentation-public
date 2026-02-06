## Bingo WS logging cleanup — état actuel (Option A)

### Architecture en place
- **Bus télémétrie** : `ws/telemetry.js` (EventEmitter + `emitTelemetry`).  
- **Writer unique** : `ws/telemetry_writer.js` est l’unique endroit qui écrit via `logger.*`; mappe les events → niveaux, filtre `WS_RECV/WS_SEND` via `WS_LOG_TRAFFIC`.  
- **Wrappers** : `ws/handler_wrapper.js` enveloppe les handlers (Result ⇒ `*_OK` / `*_FAIL`, exceptions ⇒ `EXCEPTION`). Ajout de `canvas_write` ⇒ `CANVAS_WRITE_OK/FAIL` + émission dédiée pour `SESSION_UPDATE_OK/FAIL` quand endpoint = `session_update`.  
- **Helper Canvas/DB** : `hCanvasWrite` dans `ws/bingo_server.js` centralise toutes les écritures Canvas (session_update, bingo:reset, bingo:end_game, phase_winner). Les handlers métier passent par ce helper (payload + meta), plus aucun `canvasWrite` direct.

### Instrumentation transport
- `ws/websocket_server.js` et `bingo_server.logWs*` émettent `WS_RECV` / `WS_SEND` via `emitTelemetry`; le filtrage se fait dans `telemetry_writer` (DEBUG drop si `WS_LOG_TRAFFIC=0`). Aucun log direct côté WS.

### Guard “zéro log direct”
- Script : `bash ws/check-no-direct-logs.sh`
  - Scanne `logger.`, `this.logger.`, `console.`.  
  - Allowlist : `ws/logger.js`, `ws/telemetry_writer.js`, `ws/bingo_loadtest.js` (`TEMP_LOADTEST_ALLOW`).  
  - `ws/bingo_server.js` : plus de `logger.*` ni `withSession().*`; ancien logJoin supprimé. Shim `legacyLoggerFactory` reste uniquement pour compat/LEGACY_LOG.  
  - Attendu : 0 occurrence de `logger.` dans `bingo_server.js` (guard passe).

### Nettoyages runtime
- `ws/envUtils.js` : déjà migré vers `ENVUTIL_WARN/FAIL` (writer unique respecté).  
- `ws/websocket_server.js` : WS_IN/OUT remplacés par `WS_RECV/WS_SEND` via bus.

### Wrappers & handlers BingoServer (`ws/bingo_server.js`)
- `hVerify` (verify) et `hAuth` enveloppés ; `AUTH_RESULT_PLACEHOLDER ok:true` encore temporaire.  
- `hCanvasWrite` (nouveau) : wrap `canvasWrite`, mesure durée, émet `CANVAS_WRITE_OK/FAIL`; si endpoint=`session_update`, émet aussi `SESSION_UPDATE_OK/FAIL` avec meta (track_id, track_position, scope, action, state/phase si fournis).  
- Handlers métier utilisent `hCanvasWrite` : `handleSongStartMessage`, reset (`bingo:reset`), fin de partie (`bingo:end_game`), victoire phase (`phase_winner`), vérif phase gagnante.  
- `song_start` dispatch → `handleSongStartMessage` (utilise `hCanvasWrite`) sans boucle ni appel manquant.
- Auth joueurs/clients/remotes : même wrapper `hAuth` émet `AUTH_OK/FAIL` avec `session_id` et `meta.role` (`player`, `client`, `remote`, `auth_player_paper`). Les échecs (session full, auth_failed, etc.) sont maintenant des `AUTH_FAIL` (plus de logJoin).

### Incident connu & résolution
- EXCEPTION précédente : “`this.handleSongStart` is not a function`”.  
- Résolution : méthode `handleSongStartMessage` créée et réutilisée par le helper `hCanvasWrite`; dispatch corrigé.
- Legacy front logs remappés : `telemetry:*` venant du front (source `GAMES_FRONT`) sont maintenant convertis en events canons (`FRONT_BOOT`, `FRONT_WS_STATUS`, `API_CALL_OK/ERROR`, `UI_ACTION`, `FRONT_ERROR`) avec dédoublonnage des `API_CALL_OK` et normalisation des payloads (voir writer WS).

### Événements & niveaux (exemples)
- `WS_RECV/WS_SEND` (DEBUG, filtrés si `WS_LOG_TRAFFIC!=1`), exemple : `{ event: WS_RECV, meta: { wsType, size, role } }`.  
- `CANVAS_WRITE_OK/FAIL` (INFO/ERROR) : `{ meta: { endpoint, sessionId, duration_ms, ... } }`.  
- `SESSION_UPDATE_OK/FAIL` (INFO/ERROR) : scope/action/track_id/track_position inclus quand présents.  
- `AUTH_OK/FAIL` (INFO/WARN) pour players/clients/remotes/paper avec `meta.role`.  
- `VERIFICATION_OK/FAIL`, `EXCEPTION`, `WS_SERVER_START/STOP`, `WS_CLIENT_CONNECT/DISCONNECT`, `ENVUTIL_WARN/FAIL`, `LEGACY_LOG` (niveau porté par `level`).  
- Timeline attendue (INFO): `SESSION_UPDATE_OK`, `VERIFICATION_*`, `AUTH_OK/FAIL`, `CANVAS_WRITE_OK/FAIL`, connexions/déconnexions; transport reste DEBUG.

### Validation
- `bash ws/check-no-direct-logs.sh`  
- `WS_LOG_TRAFFIC=1` pour voir `WS_RECV/WS_SEND` émis (sinon filtrés).  
- Vérifier l’absence de `canvasWrite` direct : `rg -n \"canvasWrite\\(\" ws` (seulement dans helper).

### Remaining work (checklist)
- Remplacer `AUTH_RESULT_PLACEHOLDER` par de vrais Results (`missing_token`, `role_forbidden`, …).  
- Donner à `session_update` des Results sémantiques côté helper (statut API) et propager au front sans casser le protocole.  
- Migrer les événements `LEGACY_LOG` résiduels vers des événements métier dédiés.  
- Retirer `TEMP_LOADTEST_ALLOW` du guard quand le loadtest est migré ou exclu.

### Changed files (dernière mise à jour)
- `canon/ws/bingo-ws-logs-clean.md`
- `ws/bingo_server.js`
- `ws/websocket_server.js`
- `ws/handler_wrapper.js`
- `ws/telemetry_writer.js`
