# Logging post-rollback (25 jan 2026)

- Périmètre : flux consommés par `games/web/logs_session.html` (WS Bingo/Blindtest/Quiz via `/logs` + logs front “GAMES” envoyés en `log_batch`).
- Source de vérité : code local post-rollback (cf. evidences ci-dessous). Pas de supposition runtime sans trace file:line.

## Tableau de vérité (format réel)

| Source | Fichier log | Format | Champs | Bruit dominant | Manques |
|---|---|---|---|---|---|
| Bingo_WS | `bingo.game/ws/server-logs.log` | JSONL | `log_schema_version=1`, `ts`, `level`, `source`, `session_id+sessionId`, `request_id`, `event_id`, `payload` compact | heartbeats, `remote_missing` agrégés | doublon `msg/message`, pas de niveau numérique |
| Blindtest_WS | `blindtest/web/server/server-logs.log` | JSONL | `log_schema_version=1`, `ts`, `level`, `source`, `session_id+sessionId`, `request_id`, `kind/action` partiel | heartbeats massifs | pas d’`event_id` généralisé, `msg/message` doublons |
| Quiz_WS | `quiz/web/server/server-logs.log` | mix texte + JSONL | `ts`, `level`, `source`, `sessionId`, `event/wsType`, `payload` | heartbeats, dumps session complets, lignes texte non JSON | pas de `log_schema_version`, pas de `session_id` snake_case, pas de `request_id` |
| GAMES (front) | réinjecté dans WS | JSON via `log_batch` | `ts`, `level`, `source:GAMES`, `sessionId`, `ns`, `data` | peu de bruit (buffer warn+) | pas de `log_schema_version`, pas de `session_id`, pas de `request_id` |

## Évidences (file:line)
- Viewer requête proxy + pagination/dedupe : `games/web/logs_session.html:567-727`.
- Proxy HTTP → WS `/logs` : `games/web/includes/canvas/php/logs_proxy.php:6-77`.
- WS /logs + lecture JSONL : `bingo.game/ws/server.js:125-209`, `blindtest/web/server/server.js:125-201`, `quiz/web/server/server.js:125-200`.
- Logger Bingo (schema v1) : `bingo.game/ws/logger.js:16-111`; ingestion `log_batch` front : `bingo.game/ws/bingo_server.js:246-285`.
- Logger BT/Quiz : `blindtest/web/server/logger_ws.js:4-116`, `quiz/web/server/logger_ws.js:4-116`; ingestion front BT : `blindtest/web/server/actions/wsHandler.js:413-447`.
- Front buffer + flush WS : `games/web/includes/canvas/core/logger.global.js:184-239` (log_batch), `games/web/includes/canvas/core/logger.global.js:399-402` (flush trigger).

## Actions minimales proposées
1) Réduire bruit heartbeat/remote_missing (BT/Quiz/Bingo) et supprimer logs texte legacy Quiz.  
2) Forcer schéma v1 + `session_id` + `request_id` (Quiz WS + front).  
3) Proxy: valider JSON + option `min_level`; viewer: badge source+schema.
