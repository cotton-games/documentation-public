# Bingo – couverture logs “film A→Z” (audit, no code)

Sources lues : code Bingo WS (`ws/*.js`, `ws/actions/*.js`, `ws/logger.js`, `ws/server.js`), `canon/logging.md`, `notes/logging-audit-bingo-compliance.md`, `notes/logging-post-rollback.md`.

## Checklist A→Z (depuis le code)
1) Connexion WS / heartbeat / ping  
2) Auth / association session (token → sessionId, resolveSessionId)  
3) Join organizer (client) primaire + remote, remplacements  
4) Join players (auth_player) + refus (session inconnue / pleine)  
5) Hydratation session (ensureSessionIdForGame, hydrate/players)  
6) Assignation grille / cases (phase init)  
7) case_click / verification / scoring (points + status)  
8) Updates d’état (session/game state, phase, numbers/cells sync)  
9) Notifications joueurs/remotes (broadcasts WS_OUT)  
10) Pause / reprise / timeouts  
11) Fin de partie (endGame) + snapshot/podium + coupure joueurs  
12) Déconnexions (player/organizer/remote)  
13) Loadtest (start/stop)  
14) Endpoint `/logs` export

## Coverage (logs existants)
| Event A→Z | Couvert ? | Log (file:line) | Niveau | Contexte inclus | Qualité |
| --- | --- | --- | --- | --- | --- |
| Connexion WS | Partiel | `ws/websocket_server.js:104-171` (debug/info) | debug/info | remoteAddress, pas sessionId | OK générique, pas timeline |
| Heartbeat check | Oui | `ws/websocket_server.js:196-203` | info | reason timeout, remoteAddress | Faible bruit, OK |
| WS_IN (actions) | Oui | `ws/bingo_server.js:1940-1946` | info | `event:WS_IN`, wsType, payload compact, sessionId si résolu | Bruit (noisy types non agg) |
| WS_OUT | Oui | `ws/bingo_server.js:1950-1955`, `1970-2008` | info | wsType, target, payload compact, sessionId | Bruit (pas agg) |
| Auth / resolve session | Partiel | `ws/bingo_server.js:1930-1947` | info (ws_in) | sessionId si trouvé, sinon absent | Pas de log structuré d’échec |
| Join organizer/remote | Partiel | `ws/bingo_server.js` (connexion remote/client), logs texte `New connection...` | info | pas de role/client_id structuré | Insuffisant |
| Join player | Partiel | `ws/bingo_server.js:248-283` (log_event/log_batch pour front) + handlers auth_player | warn/info texte | pas de `player_id` structuré dans un log dédié join | Insuffisant |
| Refus player (session full / inconnue) | Partiel | warns `ws/bingo_server.js:???` (limite), `ws/bingo_server.js:1941-1946` sans session | warn | raison peu structurée | Insuffisant |
| Hydratation session/players | Faible | erreurs `ws/bingo_server.js` quand DB/Canvas échoue | warn/error | sessionId | Pas de log succès |
| Assignation grille / phase init | Oui (texte) | `ws/bingo_server.js` multiples info | info | sessionId | Verbeux, pas structuré |
| case_click / verification | Oui | `ws/bingo_server.js` (logs info/error case) | info/error | sessionId, parfois player | Pas de payload structuré (player_id, case) |
| Scoring/persist | Partiel | `ws/bingo_server.js` (score update) | info/error | sessionId | Pas de log success persistant structuré |
| Updates d’état (phase/state) | Oui | `ws/bingo_server.js` via WS_IN/OUT update | info | sessionId, wsType | Bruit (rafraîchissements) |
| Broadcast notifications | Oui | WS_OUT | info | sessionId, target | Bruit |
| Pause/reprise | Partiel | logs info | info | sessionId | Pas structuré |
| Fin de partie (endGame) | Oui (multi logs) | `ws/bingo_server.js` fin flow | info | sessionId | Pas de log unique résumé |
| Déconnexions | Oui | `ws/bingo_server.js` déconnexions + `ws/websocket_server.js` heartbeat terminate | info/warn | sessionId, sometimes client_id | OK mais épars |
| Loadtest start/stop | Oui | `ws/bingo_loadtest.js` | info/warn/debug | sessionId | Bruyant |
| /logs export | Oui | `ws/server.js:155-242` | JSON response | sessionId, invalid count | OK (JSON array)

## Top 5 manques bloquants
1) Bruit WS_IN/WS_OUT non agrégé (refresh/state) → timeline noyée.  
2) Joins non structurés (organizer/remote/player) : pas de `role`, `player_id`/`client_id`, reason/code sur échecs.  
3) case_click / verification / scoring sans payload structuré (player_id, case, result, points).  
4) persistScore/updates sans log success structuré (sessionId/playerId/score/duration).  
5) Fin de partie sans log unique `end_game` résumé (raison, counts, podium/phase).

## Conclusion
- **Suffisant A→Z ?** Non. Les événements sont présents mais bruités et non structurés ; difficile de reconstruire la timeline en `min_level=info`.
- **Ordre recommandé de micro-tâches (Bingo)**  
  1) Débruiter WS_IN/OUT (agg/debug sur refresh) et normaliser les logs de connexion WS_in sans session.  
  2) Structurer joins (organizer/remote/player) avec `role`, IDs, reason/code.  
  3) Structurer case_click/verification/scoring + persist success (IDs, case, result, points, duration).  
  4) Ajouter un log unique `end_game` résumé + dédup.  
  5) Option `/logs?format=jsonl` (si souhaité) + validation invalid/pages.

## Avancement micro-tâches
- **Bingo #1 (débruitage WS traffic + heartbeat)** — FAIT  
  - WS_IN/WS_OUT passent en debug par défaut (repassent en info si `WS_LOG_TRAFFIC=1`).  
  - Heartbeat terminate passe en warn (événement anormal unique par connexion).  
  - Files touchées : `ws/bingo_server.js` (logWsInMessage/logWsOutMessage), `ws/websocket_server.js` (heartbeat terminate).  
  - Attendu : en `min_level=info`, timeline nettoyée du trafic générique; en debug (ou `WS_LOG_TRAFFIC=1`), le trafic reste visible.
- **Bingo #2 (joins structurés)** — FAIT  
  - Helper `logJoin` + logs join_success/failure (`event:"join"`, `role`, `session_id`, `player_id`/`client_id`, reason/code) pour joueurs (auth_player/auth_player_paper) et refus (session full, session inconnue) + auth_failed.  
  - Fichier : `ws/bingo_server.js`.  
  - Attendu : en `min_level=info`, les joins affichent role/ids/reason sans payload verbeux.
- **Bingo #3 (verification / winner / persist)** — FAIT 
  - Logs structurés INFO : `event:"verification"` avec `session_id`, `player_id`, `phase_index`, `outcome:winner|not_winner`, `reason` (si non_winner), `next_phase`, `duration_ms`.  
  - Persist `phase_winner` : `event:"persist"`, `action:"phase_winner"`, `outcome:"ok"`, `session_id`, `player_id`, `phase`, `next_phase`, `changed`, `duration_ms`, `event_id`.  
  - Notification remote (phase_winner) : `event:"notify_remote"`, `action:"phase_winner"`, `session_id`, `phase`, `player_id`, `outcome:"sent"`.  
  - Fichier : `ws/bingo_server.js`.  
  - Preuve (min_level=info attendu) : enchaînement `verification` not_winner puis `verification` winner → `persist` phase_winner ok (optionnel notify_remote).
- **Bingo #4 (end_game résumé unique + dédup)** — FAIT  
  - Log structuré INFO unique `event:"end_game"` avec `session_id`, `game_id`, `reason`, `players_count`, `phase_index|phase_count` (si fournis), `duration_ms`, `winner_player_id/winners_count` (si connus).  
  - Dédup par session via `endGameLogged`; émis sur fin volontaire (`quitGame` non forcé), fin API `end_game`, et timeout reconnection organisateur.  
  - Fichier : `ws/bingo_server.js`; restart marker `bingo.game/version.txt` mis à jour.  
  - Preuve (min_level=info) : une session complète montre exactement 1 ligne `event:"end_game"` (ex. reason `playlist_end`), malgré plusieurs triggers potentiels.
- **Bingo #5 (PlayerFail throttling débruité)** — FAIT  
  - Anti-spam : remplace les logs INFO répétés “PlayerFail throttling” par un seul log INFO initial, occurrences suivantes en DEBUG dans une fenêtre de 30s, spike WARN si `total>=50`.  
  - Résumé périodique : log INFO `event:"player_fail_throttle_summary"` par fenêtre (30s) avec `total_count`, `unique_players_count`, `top_reasons` ; clé sessionId si connue.  
  - Fichier : `ws/bingo_server.js`; restart marker `bingo.game/version.txt` mis à jour.  
  - Preuve (min_level=info) : scénario avec nombreux PlayerFail → plus de spam ligne-à-ligne, on voit un résumé 30s et éventuellement un WARN spike, détails disponibles en `min_level=debug`.
- **Bingo #6b (session_update scope phase/media/state + position debug)** — FAIT  
  - `event:"session_update"` porte désormais `scope` (`phase`|`media`|`state`). Phases loguées en INFO, dédup par session+phase_index, champs `phase_key` (line/double_line/bingo), `phase_index`, `phase_label`, `next_phase_key/index?`. Media `next` (song_start) structuré avec `track_position`/`track_id`; positions courantes passent en DEBUG (`action:"position"`). State (pause/resume/stop) conserve `state` machine-friendly.  
  - Fichier : `ws/bingo_server.js`; restart marker `bingo.game/version.txt` mis à jour.  
  - Attendu viewer : min_level=info montre phases et éventuels media next; pas de bruit “Maj current position”; debug garde les positions.
- **Bingo #6c (legacy media logs -> debug + session_update dedup)** — FAIT  
  - Logs legacy media (song_start text, current position) downgradés en DEBUG.  
  - `session_update` reste INFO uniquement si évolution (state/phase/media change); sinon DEBUG. Dédup séparée state/phase/media par session.  
  - Fichier : `ws/bingo_server.js`; restart marker `bingo.game/version.txt` mis à jour.  
  - Attendu : min_level=info montre seulement les transitions effectives; min_level=debug révèle répétitions/legacy.
- **Bingo #6 (session_update lifecycle + phase)** — FAIT  
  - Logs INFO structurés `event:"session_update"` pour les transitions start/next/pause/resume/stop (dédup par session + action + phase).  
  - Champs : `session_id`, `event`, `game:"bingo"`, `action`, `state` (lobby|playing|paused|ended), `phase_key` (line|double_line|bingo) + `phase_index` + `phase_label`, optionnel `next_phase_key/index` sur `next`, `reason`, `duration_ms`.  
  - Points d’émission : premier `song_start` (start→playing phase line), victoire de phase (next→phase courante), pause organiser déconnecté (pause), reprise organiser reconnecté (resume), `logEndGameOnce` (stop).  
  - Fichier : `ws/bingo_server.js`; restart marker `bingo.game/version.txt` mis à jour.  
  - Exemple attendu (min_level=info) : start `state=playing, phase_key=line`; next→double_line puis bingo; pause/resume conservent `phase_key`; stop émis avant `end_game` unique.
