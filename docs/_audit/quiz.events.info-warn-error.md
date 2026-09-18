# Quiz — Inventaire evt INFO / WARN / ERROR (WS) — 2026-02-06

| evt | lvl | src | where (file:line) | msg (const/dyn) | meta clés principales | notes |
| --- | --- | --- | --- | --- | --- | --- |
| CONFIG | info | CQ_WS | web/server/actions/envUtils.js:260 | const | canvasEndpointResolved, canvasHost, canvasEndpointSource, tokenPresent/tokenSource, envFileLoaded/envPathUsed/envKeysLoaded, hintSource, nodeEnv, ws_log_v1 | log d’init |
| CANVAS_WRITE_TIMEOUT | warn | CQ_WS | web/server/actions/envUtils.js:164 | const | action, canvasHost, timeoutMs, event_id, sid | write timeout |
| CANVAS_WRITE_FAIL | warn | CQ_WS | web/server/actions/envUtils.js:193 | const | action, canvasHost, statusCode, latencyMs, event_id, tokenPresent/tokenSource, errCode, sid | write HTTP ko |
| WS_CLIENT_CONNECTED | info | CQ_WS | web/server/server.js:225 | const | origin, remoteAddress, role | connexion WS |
| WS_CLIENT_DISCONNECTED | info | CQ_WS | web/server/actions/wsHandler.js:503 | const | sessionId, role, closeCode, intent | déconnexion WS |
| WS_IN | debug | CQ_WS | web/server/actions/wsHandler.js:158 | const | wsType, output, payload | trafic entrée (throttle/whitelist) |
| WS_OUT | debug | CQ_WS | web/server/messaging.js:131 | const | wsType, target, payload | trafic sortie (throttle/structural) |
| FRONT_LOG / payload evt (dynamic) | info/warn/error/debug | CQ_WS | web/server/actions/wsHandler.js:412-465 | dyn (payload.message) | evt (payload.event|data.event|…), sid, role?, meta: ts, ns, data, clientTs, clientLevel | ingestion log_event/log_batch (niv selon payload.level) |

Notes
- Les événements sans evt explicite (logs console ou errors génériques) ne sont pas listés ici.
- WS_IN/WS_OUT restent debug-only par design.
- src est CQ_WS (logger base).

Timeline INFO candidates (hors trafic)
- CONFIG, WS_CLIENT_CONNECTED, WS_CLIENT_DISCONNECTED, FRONT_LOG (si level=info et evt métier issu du front). CANVAS_* sont en warn.

## Logs sans `evt` explicite (informels)
- web/server/server.js:250 — `Logger.log('Un client WebSocket a été déconnecté pour inactivité.')` (info)
- web/server/server.js:264 — `Logger.error('Erreur critique sur le serveur WebSocket :', error)` (error)
- web/server/server.js:268 — `Logger.log(\`Serveur WebSocket en écoute sur le port ${PORT}.\`)` (info)
- web/server/messaging.js:141/174/194/220/248 — `Logger.error("Session ... introuvable pour l'envoi des messages.")` (error)
- web/server/messaging.js:258 — `Logger.warn("Aucun organisateur principal actif...")` (warn)
- web/server/actions/registration.js — nombreux logs sans evt (création session, promotion primary, résolutions, limites joueurs, enregistrements player/secondary, erreurs hydratation DB). Messages dynamiques avec sessionId/playerId.
- web/server/actions/gameplay.js — nombreux logs sans evt (démarrage/arrêt décompte, update game state/options, scoring, endGame, persistScore). Messages dynamiques avec sessionId/player/meta.
- web/server/actions/connection.js — logs déconnexions/cleanup/reconnect wait, warnings erreurs socket/DB, messages dynamiques.
- web/server/actions/audioControl.js — erreurs “Session ... introuvable”, logs redirection audio, support start/ended, firstClickDetected, etc.
- web/server/actions/wsHandler.js — warnings sur messages inconnus/params manquants, logs heartbeat/startLoadtest/stopLoadtest, parse errors (sans evt).
- web/server/actions/loadtest.js — logs loadtest bots lifecycle (`[LOADTEST] ...`) et erreurs associées.
- web/server/actions/wsUtils.js — logs de référence WS (setServerReference) et erreurs si serveur absent.
