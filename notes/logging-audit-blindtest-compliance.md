# Audit « logger-first » – Blindtest (compliance)

## Standard attendu (résumé)
- Référence canon : `canon/logging.md` (schema JSONL v1). Flux cible = **1 JSON par ligne** dans `server-logs.log`, lu via `/logs` + proxy/viewer jeux.
- Champs requis : `log_schema_version=1`, `ts` ISO, `level` (debug/info/warn/error), `game`, `source`, `session_id` (snake, compat `sessionId`), `msg/message`. Champs recommandés : `request_id`, `event/wsType`, `kind` (agg/evt), `action`, payload compact.
- Noms snake_case privilégiés ; pas de secrets ; payloads compacts ; `request_id` doit être réutilisé sur tout le flux.
- Agrégation possible via `kind:"agg"` pour les événements très fréquents (ping/refresh), niveaux cohérents (debug pour bruit).
- Backend `/logs` doit renvoyer uniquement des lignes JSON valides (compter les invalides) et rester JSONL sur disque.

## Compliance – émetteurs et bypass
| Émetteur (file:line) | Type | Conforme? | Détails format/champs | Impact | Fix minimal proposé |
| --- | --- | --- | --- | --- | --- |
| `web/server/logger_ws.js:4-134` | Logger WS (singleton) | Partiel | JSONL v1 (`log_schema_version`, `ts`, `level`, `game`, `source`, `sessionId`→`session_id`, `msg`, `data`). Pas de `request_id`, `kind/action`. Console mirror actif (DEBUG_ON). | Base saine mais champs incomplets pour la norme complète. | Enrichir commun (`request_id`, `kind`, `action`, `payload` compact), forcer `session_id` snake et limiter console. |
| `web/server/actions/wsHandler.js:161-166` | WS_IN logger | Partiel | `event:WS_IN`, `wsType`, payload compact, sessionId. Niveau fixe info, throttle partiel (`WS_NOISY_INTERVAL_MS`). Pas de `kind/action`, pas d’agg. | Bruit fort (checkSession/sessionUpdate/gameState). | Ajouter `kind:"agg"` + downgrade debug pour rafraîchissements; champs `action`/`request_id` à l’entrée WS. |
| `web/server/messaging.js:122-133` | WS_OUT logger | Partiel | `event:WS_OUT`, `wsType`, `target`, payload compact, sessionId. Pas de `kind/action`, pas d’agg; niveau info, throttle partiel. | Bruit rafraîchissements sortants. | Même normalisation que WS_IN + agg/coalescing; passer refresh en debug. |
| `web/server/actions/wsHandler.js:300-304` | Heartbeat | Non | Log info « Message heartbeat » sans agg, chaque ping. | Très bruyant multi-sessions. | Downgrade en debug ou supprimer; sinon `kind:"agg"` + coalescing. |
| `web/server/actions/wsHandler.js:379-448` | log_event / log_batch | Partiel | Re-log avec `clientLevel`, `ts`, `event`, `data`; source `GAMES/GAMES_FRONT`. Pas de normalisation niveau numérique/“warning”; `request_id` non propagé. | OK v1 minimal mais incohérences niveau/req. | Normaliser level -> label, véto si sessionId manquant, propager `request_id` fourni. |
| `web/server/actions/connection.js:46-63` | CLIENT_DISCONNECT | Conforme | JSONL enrichi (scope/id/code/reason/connected_ms, schema v1), niveau warn si code anormal. | Utile, volume modéré. | Option : tag `kind:"event"` pour timeline. |
| `web/server/actions/gameplay.js:569-574` | updateGameOptions | Partiel | Info avec payload options complet, sessionId. Pas de `kind/action`; payload potentiellement volumineux. | Bruit ponctuel mais gros payload. | Compacter payload (keys/nums) + ajouter `action`. |
| `web/server/actions/loadtest.js:353-378` | startLoadtest | Partiel | Logs info texte, pas de `event/kind`, pas de `request_id`. | Bruit en mode test. | Passer en debug + `event:"LOADTEST_START"` + agg. |
| `web/server/server.js:163-239` | Endpoint `/logs` | Partiel | GET `/logs?sessionId&limit<=5000&page`; lit JSONL fichiers, normalise (`log_schema_version`, `game`, `source`, compat sessionId/snake, ts fallback), compte `invalid`. Réponse JSON array (pas NDJSON). | Format HTTP ≠ NDJSON; invalid non renvoyé en JSONL. | Documenter format JSON actuel; option `format=jsonl` pour export brut. |
| `web/server/actions/wsHandler.js:460-462` | Unknown type warn | Partiel | Warn texte sans `event/action`. | Faible volume, bruit warn. | Ajouter `event:"WS_UNKNOWN_TYPE"` + payload minimal. |

## /logs export (WS Blindtest)
- Endpoint: `GET /logs?sessionId=<id>[&limit=1..5000][&page=1..N]` (server.js:174-239).
- Lit `server-logs.log` + rotations, parse JSONL; rejette lignes non-JSON (compteur `invalid`).
- Normalisation : force `log_schema_version`, `game`, `source`, compat `session_id`/`sessionId`, fallback `ts` courant si absent; filtre sur sessionId demandé.
- Réponse JSON paginée `{ok, sessionId, count, total, page, pages, invalid, statusSeed, entries[]}` (pas NDJSON). CORS `*`, GET/OPTIONS only; 400 si sessionId manquant, 405 si autre verbe, 404 si pas `/logs`.

## Corrélation (session_id / request_id)
- `session_id` injecté dès lecture WS (`wsHandler.js:159-166` via logger child) et repris dans WS_OUT (`messaging.js:129-133`) + logs métier (connection/gameplay/registration).
- Sockets portent `sessionId` après register (handlers registration → connection/disconnect).
- `request_id` absent côté WS. Points d’injection envisageables : (1) à la réception WS (génération UUID + stockage socket + logger child), (2) reprise d’un `request_id` client dans `data.request_id` ou `entry.request_id` (log_event/log_batch), (3) normalisation /logs à étendre si ajouté.

## Bruit (top 10 sources)
1. WS_IN info (`checkSession`, `sessionUpdate`, `gameState`, `update_session_infos`, `updatePlayers`) — `wsHandler.js:161-166` — Partiel throttle, pas d’agg. → Non conforme (spam info).  
2. WS_OUT info (mêmes types) — `messaging.js:122-133` — Pas d’agg, throttle partiel. → Non conforme (spam).  
3. Heartbeat info — `wsHandler.js:300-304` — Pas d’agg. → Non conforme (très bruyant).  
4. Refresh session/gameState (structural) — via WS_IN/OUT + `gameplay.broadcastSessionInfos` — coalescing partiel. → À downgrader/agg.  
5. Loadtest start/attach — `wsHandler.js:306-378` — Rafales en test. → Passer debug/agg.  
6. Disconnect info — `connection.js:87-92` — Volume fin de partie. → Conforme, garder.  
7. Score/answer logs — `gameplay.js:671-696` — Un log/réponse; utile mais volume. → À décider (debug/agg pour rafales).  
8. updateGameOptions payload — `gameplay.js:569-574` — Payload large. → Compacter.  
9. Unknown type warn — `wsHandler.js:460-462` — Faible volume mais warn sans struct. → Structurer.  
10. log_batch volumineux — `wsHandler.js:415-448` — Peut contenir gros `data`. → Filtrer/compacter.

## Backlog micro-tâches (TASK 2..n)
1) Enrichir logger WS (request_id, kind/action, payload compact, session_id snake) et limiter console mirror au DEBUG_ON.  
2) WS_IN/OUT : ajouter `kind/action` dérivés de `wsType`, coalescing + passage des rafraîchissements (checkSession/sessionUpdate/gameState/update_session_infos/updatePlayers) en debug ou `kind:"agg"`; heartbeat → debug/suppress.  
3) /logs : ajouter option `format=jsonl` (NDJSON brut) + retour des métas (invalid/pages) ; sinon documenter officiellement le format JSON actuel.  
4) log_event/log_batch : normaliser niveau (numérique/"warning"), propager `request_id` si fourni, refuser sans sessionId, compacter `data`.  
5) Générer/propager `request_id` côté WS (par connexion puis par message) et l’inclure dans tous les logs + /logs.  
6) Payload hygiene : compacter options/scores/players dans les logs gameplay; éviter les objets volumineux.  
7) Ajouter `kind:"event"` sur CLIENT_DISCONNECT et autres logs métier pour clarifier la timeline sans bruit.
