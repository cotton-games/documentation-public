# AUDIT LOGS WS — Quiz & Blindtest vs Bingo v1 (2026-02-06)

## Contrat cible Bingo (canon v1)
- Format JSONL : `v=1, ts, lvl, src=BINGO_WS, evt, sid, role(fallback=server), eid, msg?, meta{...}` (décliné via `logV1` / `logger` dans `bingo.game/ws/logger.js`).
- Enrichissement rôle automatique (`deriveRole`) + audit debug `ROLE_AUDIT`.
- Rotation/purge : 10 Mo, 5 sauvegardes, purge >15 j, DEBUG forcé actif.
- API lecture : `GET /logs?sid=<sid>[&limit=&page=]` (limite max 5000), renvoie `entries` triées (sid requis).

## Cartographie des émissions actuelles
| repo | fichier | fonction | evt/msg | niveau | champs produits | sid/role présents ? | notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| quiz | `web/server/logger_ws.js` | `createLogger`/`write` | toutes (log/info/warn/error/debug) | info/warn/error/debug | `ts`, `level`, `source=CQ_WS`, `sessionId`, `msg`, `data`, + ctx merge | sessionId oui ; role non | rotation 10 Mo / 5 backups, purge >15 j, `DEBUG_ON = !prod || LOG_DEBUG=1` |
| quiz | `web/server/actions/wsHandler.js` | `handleWebSocketConnection` | `WS_IN` (allowlist + throttle) | info | `event, wsType, output, payload, msg='WS message', sessionId, source` | sid oui (`sessionId`); role non | log uniquement sur types autorisés/throttlés |
| quiz | `web/server/messaging.js` | `logWsOut` + `sendMessage*` | `WS_OUT` (allowlist + structural/throttle) | info (+ debug traces "sent to …") | `event, wsType, target, payload, sessionId, source` | sid oui; role non | dédup structural sur types clés |
| quiz | `web/server/actions/envUtils.js` | IIFE config | `config` | info | `tags=['config'], canvasEndpointResolved/Host/Source, tokenPresent/Source, envFileLoaded/envKeysLoaded, hintSource, nodeEnv, appEnv` | sid/role non | exécuté au chargement du module |
| quiz | `web/server/actions/envUtils.js` | `canvasWrite/__canvasCall` | `CANVAS_WRITE_TIMEOUT/FAILED` | warn | `tags=['api_write_timeout'|'api_write_failed'], action, canvasHost, statusCode?, latencyMs, timeoutMs, event_id, tokenPresent, tokenSource` | sid/role non | `payload.event_id` auto pour writes |
| quiz | `web/server/actions/wsHandler.js` | `log_event` / `log_batch` | relai front (entry.level) | info/warn/error/debug | `ts/ns/event/data/clientTs/clientLevel`, `source` (entry.source||'GAMES'), `sessionId` | sessionId oui; role non | warn si sessionId manquant ou batch vide |
| quiz | `web/server/server.js` | WS lifecycle | messages texte connexion/ping/erreur | info/error | `msg` (+ éventuels objets error dans data) | sid/role non | bruit console activé si DEBUG_ON |
| blindtest | `web/server/logger_ws.js` | idem quiz (source=`BT_WS`) | idem | idem | idem (avec `source=BT_WS`) | sessionId oui; role non | même rotation/purge/debug |
| blindtest | `web/server/actions/wsHandler.js` | `WS_IN`, `log_event`, `log_batch` | idem quiz | idem | idem | idem | code miroir |
| blindtest | `web/server/messaging.js` | `WS_OUT` | idem | idem | idem | idem | idem |
| blindtest | `web/server/actions/envUtils.js` | config + Canvas writes | idem | idem | idem | sid/role non | idem |
| blindtest | `web/server/server.js` | WS lifecycle | idem | idem | idem | sid/role non | idem |

## Matrice des diffs vs Bingo v1
- **Format log** : Bingo = `v, ts, lvl, src, evt, sid, role, eid, meta`; Quiz/Blindtest = `ts, level, source(CQ_WS|BT_WS), sessionId, msg, data + ctx` (pas de `v/evt/role/eid`, clé sid nommée `sessionId`).
- **Role** : Bingo enrichit systématiquement (`role` fallback server) ; Quiz/Blindtest n’enregistrent aucun rôle.
- **Evt** : Bingo exige `evt` (canon), Quiz/Blindtest utilisent `event` ad hoc (WS_IN/WS_OUT) mais champ nommé `event`, pas `evt`.
- **Debug policy** : Bingo debug forcé actif ; Quiz/Blindtest debug désactivé en prod sauf `LOG_DEBUG=1`.
- **/logs endpoint** : Bingo `GET /logs?sid=...`; Quiz/Blindtest `GET /logs?sessionId=...` (limite max 5000 identique, page/limit idem, payload includes `statusSeed` en +).
- **Source tag** : Bingo `src=BINGO_WS`; Quiz `source=CQ_WS`; Blindtest `source=BT_WS`.

## Décision WS_IN/WS_OUT (Bingo-first)
Bingo n’a pas de convention WS_IN/WS_OUT. Proposition Option A (garder mais les mapper au format v1 et basculer en debug) : conserver les points d’observation pour diag, mais les émettre en `evt=WS_IN|WS_OUT`, `lvl=debug` par défaut, avec `sid` et `meta.payload/target/wsType`, pour aligner sur le schéma v1 sans bruit en info. Justification : évite de perdre la télémétrie trafic utile en QA tout en restant compatible avec le viewer Bingo et en limitant le volume en production.
