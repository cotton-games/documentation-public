# Blindtest – couverture logs “film A→Z” (audit, no code)

Sources lues :  
- Code Blindtest WS (`web/server/actions/*.js`, `web/server/server.js`, `web/server/messaging.js`, `web/server/logger_ws.js`).  
- Canon `logging.md`, `notes/logging-post-rollback.md`.

## Checklist A→Z (dérivée du code, sans hypothèse)
1) Connexion WS + heartbeat/ping  
2) Enregistrement organizer primary / remplacement / resume  
3) Connexion organizer secondary (remote)  
4) Inscription joueur (registerPlayer) / refus limite / session introuvable  
5) Hydratation depuis DB (ensureSessionPrimaryId, players_get)  
6) Démarrage partie (start) / compte à rebours / start song  
7) Mises à jour d’état (sessionUpdate/gameState/update_session_infos/updatePlayers)  
8) Réponse joueur / calcul points / persistScore  
9) Pause / reprise  
10) Fin de morceau / transition chanson  
11) Fin de partie (endGame) + snapshot/podium + coupure joueurs  
12) Déconnexion clients (player/organizer/remote)  
13) Loadtest (start/stop)  
14) Endpoint `/logs` (export)

## Coverage (logs existants)
| Event | Couvert ? | Log (file:line) | Niveau | Contexte inclus | Qualité |
| --- | --- | --- | --- | --- | --- |
| Connexion WS | Partiel | `web/server/server.js:257-268` (log connection) | info | sessionId absent | OK mais générique |
| WS_IN (actions) | Oui | `actions/wsHandler.js:161-166` | info | sessionId via child logger, wsType, payload compact | Bruit (noisy types non agg) |
| WS_OUT | Oui | `messaging.js:122-133` | info | wsType, target, payload compact | Bruit (pas agg) |
| Heartbeat | Oui | `wsHandler.js:300-304` | info | sessionId | Bruit fort |
| Register organizer primary | Oui | `registration.js:49-140` logs texte + success | info | sessionId, primaryInstanceId implicite | Pas structuré, pas role/action |
| Replace/Resume primary | Oui | `registration.js:136-140` | info | sessionId | Non structuré |
| Secondary (remote) join | Oui | `registration.js:180-220` | info | sessionId, remoteInstanceId? | Non structuré |
| Player register success | Oui | `registration.js:399-420` | info | sessionId, playerId (texte), playerName | Pas de clés normalisées |
| Player register fail (session missing) | Oui | `registration.js:353-360` | error | sessionId text | Pas de reason/code struct. |
| Player register fail (limit) | Oui | `registration.js:387-395` | warn | sessionId text | Pas de player_id / code |
| Hydrate players | Partiel | `registration.js:455-470` errors | warn/error | sessionId | Pas de log success |
| Start | Oui | `gameplay.js:190-197` | info | sessionId, remainingTime text | OK |
| Countdown start | Oui | `gameplay.js:206-214` | info | sessionId | OK |
| Song transition | Oui | `gameplay.js:149-150` | info | sessionId | OK |
| Session/game updates | Oui | `gameplay.js:157-158`, WS_IN/OUT | info | sessionId | Bruit/verbosité |
| Player answer + scoring | Oui | `gameplay.js:666-696` | info | msg avec score, pas de player_id structuré | Insuffisant |
| Persist score success | Oui | `gameplay.js:996-1024` | info text “persistScore: OK (changed=%s)” | sessionId absent, pas playerId, pas duration | Insuffisant |
| Persist score error | Oui | `gameplay.js:1026` | error | message seulement | OK |
| Pause | Oui | `gameplay.js:285-299` | info/warn | sessionId | OK |
| End song auto | Oui | `gameplay.js:269-272` | info | sessionId | OK |
| EndGame snapshot send | Oui | `gameplay.js:838-889` | info multiple | sessionId | Dispersé, pas de log unique résumé |
| Disconnect client | Oui | `actions/connection.js:63-128` | info/warn | sessionId, scope, client_id, code | OK (structuré) |
| Loadtest start/stop | Oui | `actions/wsHandler.js:306-399` | info | sessionId | Bruyant |
| /logs endpoint | Oui | `server.js:163-239` | info (responses) | sessionId filter, invalid count | OK JSON array |

## Top 5 manques bloquants
1) Bruit WS_IN/WS_OUT/heartbeat (info, pas d’agg) → timeline noyée.  
2) Logs d’inscription non structurés (organizer/secondary/player) : pas de `role`, `player_id` clés, pas de reason/code sur échecs.  
3) Réponse joueur/scoring : absence de clés `player_id`, `is_correct`, `points`, `score_total` structurées.  
4) persistScore success : pas de sessionId/playerId/duration → impossible de tracer l’écriture.  
5) Fin de partie : pas de log unique “end_game” résumé, logs dispersés.

## Conclusion
- **Suffisant A→Z ?** Non. Les événements existent mais sont soit bruyants (WS), soit non structurés (join/answer/persistScore/endGame), rendant la timeline difficile à suivre en `min_level=info`.
- **Ordre recommandé des micro-tâches (Blindtest)**  
  1) Débruiter WS_IN/OUT + heartbeat (agg/debug).  
  2) Structurer logs join (organizer/secondary/player) avec `role`, IDs, reason/code.  
  3) Structurer player_answer + persistScore success (clés IDs, points, durée).  
  4) Ajouter log unique `end_game` résumé + dédup.  
  5) Option `/logs?format=jsonl` (comme Quiz) si besoin d’export NDJSON.

## Mises à jour récentes
- **Session lifecycle (start/play/pause/resume/next/stop)** — FAIT (27 jan 2026)  
  - Logs INFO structurés `event:"session_update"` avec `session_id`, `action`, `state`, `index`, `reason` optionnel, dédup par session+action+index pour éviter le spam.  
  - Fichier : `web/server/actions/gameplay.js`.  
  - Exemple attendu (min_level=info) : `{"event":"session_update","action":"pause","session_id":"…","state":"paused","index":12}`.  
- **WS traffic débruité + DEBUG par défaut en dev** — FAIT (27 jan 2026)  
  - WS_IN forcé en DEBUG (agg/throttle conservés) dans `web/server/actions/wsHandler.js`; WS_OUT déjà en DEBUG dans `messaging.js`.  
  - Logger WS (`web/server/logger_ws.js`) considère désormais `NODE_ENV` : en dev (NODE_ENV≠production) ou si `LOG_DEBUG=1` → les logs DEBUG sont écrits, sinon ignorés.  
  - Attendu : min_level=info propre (pas de WS_IN/OUT), min_level=debug montre trafic WS et legacy texte.
