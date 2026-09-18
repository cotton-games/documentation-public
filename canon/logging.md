> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Logging (canon)

> Objectif : rendre une session retraçable via un flux JSONL (1 JSON par ligne), lisible par `games/web/logs_session.html` via `/logs` (serveurs WS) + `games/web/includes/canvas/php/logs_proxy.php`.

<!-- AUTO-UPDATE:BEGIN id="logging-schema" owner="codex" -->
## Schéma (état actuel après rollback)

- Les serveurs WS écrivent un JSONL minimal par ligne dans `server-logs.log` (un fichier par jeu).  
- Champs généralement présents : `log_schema_version`, `ts`, `level`, `game`, `source`, `session_id`/`sessionId`, `request_id` (quand fourni par le client), `event`/`wsType`, `msg`/`message`, éventuel `payload` compact.  
- Le viewer `logs_session.html` consomme ces lignes via `/logs` et les affiche en brut (pas d’agrégats ni de toggle debug actif).

Notes de prudence :
- Ne pas supposer la présence de `bingo_phase`, d’agrégats `kind:"agg"`, ni de séparation stricte `info`/`debug` : ces éléments ont été retirés/rollbackés.
- `sessionId` (camelCase) peut encore apparaître pour compatibilité, mais le filtrage côté backend se fait principalement sur `session_id`.
- Éviter de logguer des secrets (tokens, cookies, headers).
- **Transport front → WS** : les logs front sont bufferisés puis envoyés en batch (`log_batch`). Les événements `API_CALL_*` (et `LEGACY_API_NOTE`) sont toujours inclus dans le buffer même si `LOG_BUFFER_LEVEL` est `info`, afin de garder les tentatives/résultats API visibles dans les exports debug ; le sink WS temps réel reste par défaut à `warn`.
- **Viewer meta fallback** : si `__view.meta` est vide, le viewer reconstruit une meta courte. Priorité : `API_CALL_*` (api_action/req/http/latency/ok), puis `LEGACY_API_NOTE`, sinon quelques champs génériques (`session_id`, `player_id`, `wsType`, `action`, `state`, `latency_ms`, `http_status`). Objectif : éviter une colonne meta vide quand le backend ne fournit pas `__view.meta`.

## Conventions minimales recommandées (à viser lors de futures évolutions)
- Noms snake_case pour les champs canons (`session_id`, `request_id`, `event_id`, `duration_ms`, `player_id`, `song_index`…).
- Payloads compacts (clé/valeurs courtes), pas d’objets volumineux.
- `request_id` réutilisé à travers un même flux si disponible côté client.

## Fonctionnalités non actives (post-rollback)
- Toggle/debug côté viewer (`show_debug` / `min_level`) : non fonctionnel actuellement.
- Agrégation (actions fréquentes) et champs enrichis (`bingo_phase`, `kind:"agg"`, règles fines info/debug) : non implémentés dans l’état courant.
<!-- AUTO-UPDATE:END id="logging-schema" -->
