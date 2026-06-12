# Audit « logger-first » – Bingo (compliance)

## Standard attendu (résumé)
- Référence canon : `canon/logging.md` (JSONL schema v1). Flux cible = **1 JSON par ligne** dans `server-logs.log`, consommé via `/logs` + proxy/viewer.
- Champs requis : `log_schema_version=1`, `ts` ISO, `level` (debug/info/warn/error), `game`, `source`, `session_id` (snake, compat `sessionId`), `msg/message`. Champs recommandés : `request_id`, `event/wsType`, `kind` (agg/evt), `action`, payload compact.
- Noms snake_case privilégiés, pas de secrets, payloads compacts. `request_id` doit être propagé sur tout le flux.
- Agrégation (`kind:"agg"`) attendue pour les rafraîchissements/pings; niveaux cohérents (bruit → debug/agg).
- Backend `/logs` doit filtrer au strict JSONL, compter les lignes invalides, rester JSONL sur disque (export NDJSON ou JSON documenté).

## Compliance – émetteurs et bypass
| Émetteur (file:line) | Type | Conforme? | Détails format/champs | Impact | Fix minimal proposé |
| --- | --- | --- | --- | --- | --- |
| `ws/logger.js:16-154` | Logger WS (singleton) | Partiel | JSONL v1 (`log_schema_version`, `ts`, `level`, `game`, `source`, `sessionId`→`session_id`, `msg`, `data`). Pas de `request_id`, `kind/action`; console mirror actif. | Base saine mais champs incomplets vs norme. | Enrichir commun (`request_id`, `kind`, `action`, `payload` compact), forcer snake_case et limiter console. |
| `ws/bingo_server.js:1940-1946` | WS_IN logger | Partiel | `event:WS_IN`, `wsType`, payload compact, sessionId. Niveau info, pas d’agg/kind/action, pas de request_id. | Bruit important (updates/pings) | Ajouter `kind:"agg"` + downgrade debug pour refresh; champs `action/request_id`. |
| `ws/bingo_server.js:1949-1955` | WS_OUT logger | Partiel | `event:WS_OUT`, `wsType`, `target`, payload compact, sessionId. Niveau info, pas d’agg/kind/action, pas de request_id. | Bruit sortant rafraîchissements. | Même normalisation que WS_IN + agg/coalescing. |
| `ws/bingo_server.js:248-283` | log_event / log_batch | Partiel | Relais front avec `clientLevel`, `ts`, `event`, `data`; source `GAMES_FRONT` par défaut. Pas de normalisation niveaux numériques/“warning”; `request_id` ignoré. | Volume variable, cohérence niveau non garantie. | Normaliser level → label, refuser sans sessionId, propager `request_id` si fourni. |
| `ws/websocket_server.js:199-203` | Heartbeat timeout log | Conforme | Info sur coupure après idle>3× interval; peu fréquent. | Faible bruit. | RAS (option warn si needed). |
| `ws/bingo_server.js:243-245` | New connection info | Partiel | Message texte, pas de sessionId/fields. | Bruit faible mais non structuré. | Ajouter contexte (session/token) ou baisser en debug. |
| `ws/bingo_server.js:1941-1946` (WS_IN sans session) | Partiel | Log sans sessionId quand résolution impossible (ex: avant auth). | Impact tri par session (perte). | Ajouter tag `session_id:null` + action = “unscoped” ou éviter log. |
| `ws/server.js:155-242` | Endpoint `/logs` | Partiel | GET `/logs?sessionId&limit<=5000&page`; lit JSONL fichiers, normalise (`log_schema_version`, `game`, `source`, compat sessionId/snake, ts fallback), compte `invalid`; retourne JSON paginé (pas NDJSON) + `statusSeed` + `statusSeedPhase`. | Format HTTP ≠ NDJSON; invalid non exporté en NDJSON. | Documenter format JSON actuel; option `format=jsonl` pour export brut. |
| `ws/bingo_server.js:1949-1955 & 1970-2008` | WS_OUT broadcast (players/client/remote/socket) | Partiel | Même qu’au-dessus; pas d’agg, info fixe. | Bruit multi-cibles. | Agg/coalescing + niveau debug sur refresh. |
| `ws/bingo_loadtest.js` (multiples) | Partiel | Logs debug/info/warn variés, pas d’action/kind/request_id. | Bruit en mode test. | Baisser info→debug, ajouter tags agg. |

## /logs export (WS Bingo)
- Endpoint: `GET /logs?sessionId=<id>[&limit=1..5000][&page=1..N]` (ws/server.js:155-242).
- Lit `server-logs.log` + rotations; parse JSONL, rejette lignes non-JSON (compteur `invalid`).
- Normalisation : force `log_schema_version`, `game`, `source`, compat `session_id`/`sessionId`, fallback `ts` courant si absent; filtre par sessionId cible.
- Réponse JSON paginée `{ok, sessionId, count, total, page, pages, invalid, statusSeed, statusSeedPhase, entries[]}` (pas NDJSON). CORS `*`, GET/OPTIONS only; 400 si sessionId manquant, 404 si autre path, 405 si autre verbe.

## Corrélation (session_id / request_id)
- `session_id` résolu via `resolveSessionId` (sessionId/session_id/token ou cache gameID) puis attaché dans `withSession` → log child (`ws/bingo_server.js:1930-1947`, `1949-1955`, broadcasts).  
- `sessionId` enregistré côté remote/client/player après auth, réutilisé par loggers ; disconnects/logs en dépendent.  
- `request_id` absent côté WS. Points d’injection possibles : (1) réception WS (générer UUID + logger child), (2) reprise `request_id` depuis messages/log_batch/log_event, (3) extension /logs pour conserver/exposer `request_id`.

## Bruit (top 10 sources)
1. WS_IN info (checkSession, session/game updates, clicks, etc.) — `ws/bingo_server.js:1940-1946` — pas d’agg, info fixe → Non conforme (spam).  
2. WS_OUT info (broadcasts players/client/remote) — `ws/bingo_server.js:1949-1955`, `1970-2008` — pas d’agg → Non conforme (spam).  
3. log_batch volumineux — `ws/bingo_server.js:248-283` — payloads potentiellement gros, niveaux non normalisés.  
4. New connection info texte — `ws/bingo_server.js:243-245` — bruit faible mais non structuré.  
5. Heartbeat termination info — `ws/websocket_server.js:199-203` — faible fréquence, acceptable.  
6. Gameplay logs (scores/phase updates) — multiples info in `ws/bingo_server.js` (game flow) — volume élevé pendant parties.  
7. Loadtest logs — `ws/bingo_loadtest.js` — rafales en mode test.  
8. Unknown message types (remote) — `ws/bingo_server.js:??` (ex: “Unknown message type from remote”) — warn sans struct.  
9. Error logs DB/API — `ws/bingo_server.js` divers — utiles, garder.  
10. Terminate idle connections info — `ws/websocket_server.js:196-203` — faible.

## Backlog micro-tâches (TASK 2..n)
1) Enrichir logger commun (request_id, kind/action, payload compact, session_id snake) et restreindre console mirror.  
2) WS_IN/OUT : ajouter `kind/action` dérivés de `wsType`, coalescing + passage des rafraîchissements (status/state/session updates) en debug ou `kind:"agg"`, request_id propagation; éviter logs sans session.  
3) /logs : option `format=jsonl` (NDJSON brut) + métas invalid/pages; sinon documenter officiellement le format JSON actuel.  
4) log_event/log_batch : normaliser niveaux (numérique/"warning"), propager `request_id`, refuser sans sessionId, compacter `data`.  
5) Générer/propager `request_id` côté WS (connexion + message) et l’inclure dans tous les logs + /logs.  
6) Bruit gameplay/loadtest : downgrader en debug ou `kind:"agg"` les rafraîchissements fréquents; compacter payloads (scores/options).  
7) Structurer les logs texte (new connection, unknown remote type) avec champs (`event`, `wsType`, `session_id`, `target`) pour cohérence viewer.
