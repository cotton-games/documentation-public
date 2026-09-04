# Audit « logger-first » – Quiz (compliance)

## Standard attendu (résumé)
- Référence canon : `canon/logging.md` (schema v1 JSONL). Flux attendu = **1 JSON par ligne** dans `server-logs.log`, consommé via `/logs`.
- Champs obligatoires cibles : `log_schema_version=1`, `ts` ISO, `level` (debug/info/warn/error), `game`, `source`, `session_id` (snake, compat `sessionId`), `msg/message`. Champs conseillés : `request_id`, `event/wsType`, `kind` (agg/evt), `action`, payload compact.
- Noms snake_case préférés, pas de payload volumineux, pas de secrets. `request_id` doit être réutilisé sur un flux. Agrégation possible via `kind:"agg"` pour bruits (ping/heartbeat/refresh).
- Viewer `/logs_session.html` et proxy `logs_proxy.php` consomment du JSONL pur ; le backend `/logs` doit renvoyer uniquement les lignes valides + compter les invalides.

## Compliance – émetteurs et bypass
| Émetteur (file:line) | Type | Conforme? | Détails format/champs | Impact | Fix minimal proposé |
| --- | --- | --- | --- | --- | --- |
| `web/server/logger_ws.js:4-134` | Logger (singleton) | Partiel | Écrit JSONL v1 (`log_schema_version`, `ts`, `level`, `game`, `source`, `sessionId`→`session_id`, `msg`, `data`). Manque `request_id`, `kind/action`. Console mirroring actif (DEBUG_ON). | Base saine mais champs incomplets pour la norme complète. | Ajouter enrichissement commun (`request_id`, `kind`, `action`, `payload` compact) et forcer `session_id` snake en plus de camel. |
| `web/server/actions/wsHandler.js:161-165` | Logger WS_IN | Partiel | `event:WS_IN`, `wsType`, `payload` compact, `sessionId` → JSONL ok. Pas de `kind/action`, pas d’agg, niveau fixe `info`, throttle partiel (`WS_NOISY_INTERVAL_MS`). | Volume important (checkSession, sessionUpdate, gameState). | Ajouter `kind:"agg"` + passage en debug pour pings/refresh; champs `action`, `request_id` à l’entrée WS. |
| `web/server/messaging.js:122-133` | Logger WS_OUT | Partiel | `event:WS_OUT`, `wsType`, `target`, payload compact, sessionId. Pas de `kind/action`, pas d’agg ; niveau `info`, throttle partiel. | Bruit récurrent sur updates (players/session/gameState). | Même normalisation que WS_IN + `kind:"agg"` sur refresh, downgrade debug. |
| `web/server/actions/wsHandler.js:323-327` | Heartbeat | Non | Log `info` « Message heartbeat » sans agg, à chaque ping. | Très bruyant sur toutes sessions. | Downgrade en `debug` ou supprimer; sinon `kind:"agg"` + coalescing. |
| `web/server/actions/log_event|log_batch (wsHandler.js:402-472)` | Ingestion front | Partiel | Re-émet vers logger avec `clientLevel`, `ts`, `event`, `data`; pas de normalisation level numérique, pas de `log_schema_version` ajouté explicitement (hérité), `source` forcé `GAMES_FRONT`. | OK pour compat v1 mais niveaux/req_id non garantis. | Normaliser level -> label, injecter `request_id` si fourni, véto si pas de `sessionId`. |
| `web/server/actions/connection.js:47-64` | CLIENT_DISCONNECT | Conforme | Entrée enrichie (scope/id/code/reason/connected_ms, log_schema_version=1) niveau warn si code anormal. | Bruit modéré, utile timeline. | RAS (option: ajouter `kind:"event"`). |
| `web/server/actions/gameplay.js:569-574` | updateGameOptions | Partiel | Info avec payload objet (options) + sessionId. Pas de `kind/action`; payload complet (risque volume). | Bruit ponctuel ; payload peut gonfler. | Réduire payload (keys/nums) + `action:updateGameOptions`. |
| `web/server/actions/loadtest.js:353-378` | startLoadtest | Partiel | Info texte, pas de champs normalisés (`event`, `kind`). | Bruit élevé en mode loadtest. | Mettre `event:"LOADTEST_START"`, niveau debug/agg. |
| `web/server/server.js:163-239` | Endpoint `/logs` | Partiel | GET `/logs?sessionId={id}&limit<=5000&page`; lit fichiers `server-logs*.log`, normalise (`log_schema_version`, `game`, `source`, compat sessionId/snake, ts fallback). Retour JSON `{ok,count,total,page,pages,invalid,statusSeed,entries[]}` (liste, pas JSONL). | Format backend = JSON array, pas NDJSON; invalid compté mais non retourné en JSONL. | Documenter que backend renvoie JSON (pas NDJSON) et garder JSONL sur disque; envisager export NDJSON direct. |
| `web/server/actions/wsHandler.js:485` | Unknown type warn | Partiel | Warn texte avec type inconnu, sans `event/action`. | Peu fréquent, brouille tri niveau warn. | Ajouter `event:"WS_UNKNOWN_TYPE"` + payload minimal. |

## /logs export (WS Quiz)
- Endpoint: `GET /logs?sessionId=<id>[&limit=1..5000][&page=1..N]` (server.js:174-238).
- Trie les fichiers `server-logs.log` + rotations, parse JSONL; rejette lignes non-JSON (compteur `invalid`).
- Normalisation : force `log_schema_version`, `game`, `source`, compat `session_id`/`sessionId`, fallback `ts` actuel si absent; filtre par `sessionId` demandé.
- Réponse JSON (array) et non NDJSON: `{ok, sessionId, count, total, page, pages, invalid, statusSeed, entries[]}`; `statusSeed` = premier log d’état après la page pour aider la timeline.
- CORS `*`, méthodes GET/OPTIONS uniquement; 400 si `sessionId` manquant, 405 sinon GET.

## Corrélation (session_id / request_id)
- `session_id` attaché tôt : payload WebSocket (`data.sessionId`) → logger child dans `wsHandler.js:159-166` et `messaging.js:129-132`; propagé dans la plupart des logs métier (gameplay/registration/connection).
- Sockets portent `sessionId` dès enregistrement organizer/player (`registration.js:110-140`, `acceptSecondary`), repris par disconnect handler (`connection.js:67-92`).
- `request_id` inexistant côté WS. Points d’injection possibles :
  1) À la réception WS (`wsHandler` juste après parse) : générer UUID et stocker sur `socket` + logger child context;
  2) Reprendre un `request_id` client si présent dans `data.request_id` ou `entry.request_id` (log_event/log_batch) et le propager;
  3) /logs n’ajoute pas `request_id` si absent, donc normalisation à étendre si ajouté.

## Bruit (top 10 sources)
1. WS_IN info (types `checkSession`, `sessionUpdate`, `gameState`, `update_session_infos`, etc.) – `wsHandler.js:161-166` — Partiel agg/throttle; spam sur rafraîchissements.
2. WS_OUT info (mêmes types) – `messaging.js:122-133` — Pas d’agg, throttle partiel.
3. Heartbeat info – `wsHandler.js:323-327` — Non conforme, très fréquent.
4. sessionUpdate/gameState refresh – indirect via WS_IN/OUT + `gameplay.broadcastSessionInfos` → multiples en chaîne.
5. loadtest start/attach – `wsHandler.js:353-378` — rafales en mode test.
6. Disconnect info – `connection.js:87-120` — pic en phase de fin de partie; niveau info.
7. SCORE/answer logs – `gameplay.js:671-696` — un log par réponse; utile mais volumineux.
8. updateGameOptions – `gameplay.js:569-574` — faible volume, payload gros.
9. ADMIN set score – `gameplay.js:1067` — rare mais verbose.
10. Unknown WS type warn – `wsHandler.js:485` — faible volume mais niveau warn.

Recommandations bruit: 1) passer heartbeat en debug ou supprimer; 2) tagger WS_IN/OUT refresh en `kind:"agg"` + min_level=debug; 3) geler WS_OUT/IN throttle sur update_session_infos/sessionUpdate/gameState à 3–5s et ajouter coalescing par signature; 4) downgrader loadtest logs en debug; 5) compacter payloads (options/scores) et/ou `kind:"event"`.

## Backlog micro-tâches (TASK 2..n)
1) Normaliser logger v1 Quiz : ajouter enrichissement commun (`request_id`, `kind`, `action`, `payload` compact, `session_id` snake) et clamp console mirroring au DEBUG_ON.
2) WS_IN/OUT : ajouter `kind`/`action` dérivés de `wsType`, coalescing + passage des rafraîchissements (checkSession/sessionUpdate/gameState/update_session_infos/updatePlayers) en debug ou agg; heartbeat → debug/suppress.
3) /logs : option `format=jsonl` pour renvoyer NDJSON brut + include `invalid`/`pages` meta; sinon documenter format JSON actuel dans canon.
4) Ingestion front (`log_event`/`log_batch`) : normaliser `level` numérique/`warning`, valider `sessionId`, propager `request_id` si fourni.
5) Génération `request_id` WS côté serveur (par connexion puis par message si client fournit) + propagation dans tous logs.
6) Payload hygiene : compacter logs volumineux (scores/options/players) et éviter données complètes (ex: options array complet).
7) Ajouter `kind:"event"` sur CLIENT_DISCONNECT et autres logs métier pour clarifier timeline.

