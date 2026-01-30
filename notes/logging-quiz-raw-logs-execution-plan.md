# Plan d’exécution — Refonte logs bruts Quiz (A→Z)

Sources : `notes/logging-quiz-timeline-coverage.md`, `notes/logging-audit-quiz-compliance.md`, `canon/logging.md`.

## Micro-tâches (1 PR chacune)
1) **Débruitage WS (heartbeat + WS_IN/WS_OUT)**  
   - Fichiers : `web/server/actions/wsHandler.js` (heartbeat + WS_IN), `web/server/messaging.js` (WS_OUT).  
   - Changement : passer heartbeat en debug, basculer les WS_IN/OUT de rafraîchissement (`checkSession`, `sessionUpdate`, `gameState`, `update_session_infos`, `updatePlayers`, `initializeOrUpdateSession`) en debug + tag `kind:"agg"` + throttle existant conservé.  
   - Validation : session golden → `min_level=info` lisible (plus de spam refresh/heartbeat), `min_level=debug` montre les lignes avec `kind:"agg"`.

2) **Structurer les logs d’inscription (organizer/secondary/player)**  
   - Fichiers : `web/server/actions/registration.js`.  
   - Changement : ajouter `action` explicite (`primary_register`, `secondary_connect`, `player_register`), champs `player_id/remote_instance_id/primary_instance_id`, niveau info/warn cohérent.  
   - Validation : inscrire primary+secondary+player → logs structurés avec IDs et session_id.

3) **Réponses joueurs & scoring**  
   - Fichiers : `web/server/actions/gameplay.js`.  
   - Changement : ajouter `player_id`, `is_correct`, `points`, `score_total`, `action:"answer_processed"` + log success `persistScore` (event_id si dispo); réduire verbeux.  
   - Validation : réponse correcte/incorrecte → log unique lisible; persist success + error visibles; viewer counts stables.

4) **Fin de partie / endGame**  
   - Fichiers : `web/server/actions/gameplay.js`.  
   - Changement : log unique `event:"END_GAME"` avec `session_id`, `winner_count`, `players_count`, `status`; dédupliquer logs dispersés.  
   - Validation : fin de partie → un log END_GAME info, aucun doublon superflu.

5) **/logs export option NDJSON + invalid meta**  
   - Fichiers : `web/server/server.js`.  
   - Changement : ajouter `format=jsonl` pour flux NDJSON brut (1 ligne JSON) + inclure `invalid`/`pages` en meta; format JSON par défaut inchangé.  
   - Validation : `/logs?format=jsonl` retourne NDJSON, `/logs` JSON identique à l’existant.
