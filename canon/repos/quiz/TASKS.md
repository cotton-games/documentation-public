# Repo `quiz` — Tasks

## Todo
- Vérifier en intégration que tous les writes WS player-scoped passent en `identity_mode=canon` (quiz `update_score` + `deactivate_player`).
- Surveiller `LEGACY_REGISTER_USED`; retirer définitivement le fallback `playerId` dès compteur=0 côté WS register.
- Planifier retrait du fallback legacy côté glue (`identity_mode=legacy`) dès extinction des usages.
- Exécuter un smoke test loadtest WS (20s, 3 bots) et confirmer `PLAYER_ID_MISSING_OR_INVALID=0`.

## Quick checks (Patch 6)
- Syntaxe WS:
  - `node --check ../quiz/web/server/actions/loadtest.js`
  - `node --check ../quiz/web/server/actions/envUtils.js`
  - `node --check ../quiz/web/server/actions/connection.js`
  - `node --check ../quiz/web/server/actions/gameplay.js`
- Smoke test bots:
  - `rg -n "BOT_IDENTITY|PLAYER_ID_MISSING_OR_INVALID|LEGACY_REGISTER_USED" ../quiz/web/server/server-logs.log`
  - Relance à paramètres identiques (`sid` + bot range) et vérifier `player_id` identiques dans `BOT_IDENTITY`.
- Contrat bridge quiz:
  - `php -l ../games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `rg -n "identity_mode|legacy_identity|BAD_PLAYER_ID|PLAYER_NOT_FOUND|_quiz_is_canonical_player_id" ../games/web/includes/canvas/php/quiz_adapter_glue.php`
- Contrat front register (games):
  - `rg -n "player_stable_id:|getSessionScopedStableKey|getOrCreateStablePlayerRef|player_register_tx|register/debug" ../games/web/includes/canvas/play/register.js`
- Migration SQL présente:
  - `rg -n "uq_cq_players_session_player|idx_cq_players_session_active|player_id" ../games/web/includes/canvas/sql/2026-02-10_players_player_id_upsert.sql`
- Logs runtime:
  - `rg -n "PLAYER_REGISTER_UPSERT_(OK|ERR)|MISSING_PLAYER_ID|PLAYER_DEACTIVATE_BY_KEY_(OK|ERR)" ../quiz/web/server/server-logs.log`
- Replacement WS player:
  - `rg -n "PLAYER_REPLACEMENT|PLAYER_SOCKET_REPLACED_CLEANUP|WS_CLIENT_DISCONNECTED" ../quiz/web/server/server-logs.log`
  - `rg -n "SESSION_REPLACED|4005|player-replaced" ../quiz/web/server/actions/registration.js ../quiz/web/server/actions/wsHandler.js ../quiz/web/server/actions/connection.js`

## AUDIT fin de session (2026-02-11, NO PATCH)

### Fichiers inspectés
- `../quiz/web/server/actions/gameplay.js`
- `../quiz/web/server/actions/registration.js`
- `../quiz/web/server/actions/sessionUtils.js`
- `../quiz/web/server/actions/envUtils.js`
- `../quiz/web/server/actions/wsHandler.js`
- `../quiz/web/server/actions/connection.js`
- `../quiz/web/server/resources/sessions.js`

### Constats factuels
- End detection: bascule par `initializeOrUpdateSession` quand `gameStatus === "Partie terminée"` puis `endGame(sessionId)` (`../quiz/web/server/actions/gameplay.js:235`, `../quiz/web/server/actions/gameplay.js:238`, `../quiz/web/server/actions/gameplay.js:975`).
- Persistance DB à la fin: write `session_update` via `persistPodium` avec payload `{ sessionId, currentSongIndex, gameStatus, totalPlayers, podium, game:'quiz' }` (`../quiz/web/server/actions/gameplay.js:1199`, `../quiz/web/server/actions/gameplay.js:1219`, `../quiz/web/server/actions/gameplay.js:1229`). `event_id` est injecté/obligatoire dans `canvasWrite` (`../quiz/web/server/actions/envUtils.js:293`, `../quiz/web/server/actions/envUtils.js:310`).
- Hydratation DB au reload organizer: `ensureSessionPrimaryId` (`session_primary_id`) puis `players_get`, mapping dans `session.players` (score conservé par max) (`../quiz/web/server/actions/sessionUtils.js:19`, `../quiz/web/server/actions/registration.js:618`, `../quiz/web/server/actions/registration.js:652`, `../quiz/web/server/actions/registration.js:736`).
- Payloads WS envoyés après reload: snapshot players `updatePlayers` puis, en session terminée, payload `endGame` (orga via `sendMessageToOrganizers`, players reconnect via `getGameState`) (`../quiz/web/server/actions/gameplay.js:943`, `../quiz/web/server/actions/gameplay.js:1002`, `../quiz/web/server/actions/gameplay.js:525`, `../quiz/web/server/actions/gameplay.js:599`).
- Reconstruction podium/classement: podium dérivé du ranking trié score desc + tie-break `playerId` alpha (`stableSortByScoreDesc` + `assignCompetitionRanks`), puis top rangs 1..3; si snapshot final mémoire existe, il est prioritaire (`../quiz/web/server/actions/gameplay.js:887`, `../quiz/web/server/actions/gameplay.js:898`, `../quiz/web/server/actions/gameplay.js:1040`, `../quiz/web/server/actions/gameplay.js:1098`).

### Gaps identifiés (sans patch)
- Aucune lecture DB dédiée au podium à la reprise: only `players_get` est lu; le podium reload dépend de `session.finalPodium` mémoire ou recalcul depuis players (`../quiz/web/server/actions/registration.js:652`, `../quiz/web/server/actions/gameplay.js:1047`, `../quiz/web/server/actions/gameplay.js:1098`).
- `getGameStateForRemote` en session terminée mappe `playerRank` depuis `session.finalRankings[*].playerRank` alors que le snapshot figé stocke `finalRank`; risque de `playerRank` nul dans ce chemin (`../quiz/web/server/actions/gameplay.js:535`, `../quiz/web/server/actions/gameplay.js:539`, `../quiz/web/server/actions/gameplay.js:992`).

## Done
- [x] 2026-02-13 — WS quiz observability: `WS_CLIENT_DISCONNECTED` enrichi avec `meta.ws_client_id`, `meta.ws_role` et `closeReason` (en plus de `closeCode/intent/involuntary`) pour faciliter la corrélation avec incidents front.
- [x] 2026-02-12 — WS quiz: fix `disconnectPlayers` crash (`deactivations is not defined`) en réintroduisant la collecte `deactivations` avant `Promise.allSettled`; fin de session organizer (volontaire) validée sans erreur runtime.
- [x] 2026-02-10 — Patch 2: `quiz_api_player_register` passé en UPSERT par `(session_id, player_id)`.
- [x] 2026-02-10 — Patch 2: fallback `player_id` serveur si absent (compat vieux client) + trace `MISSING_PLAYER_ID` côté bridge.
- [x] 2026-02-10 — Patch 2: `quiz_api_deactivate_player` priorise `(session_id, player_id)` puis fallback legacy `(id, session_id)`.
- [x] 2026-02-10 — WS quiz: logs `PLAYER_DEACTIVATE_BY_KEY_OK/ERR` ajoutés dans `web/server/actions/connection.js`.
- [x] 2026-02-10 — Front register (games): envoi `player_id` stable sur `player_register` pour quiz/blindtest.
- [x] 2026-02-11 — Front register (games): `player_id` désormais stable par session via clé `${slug}:player_stable_id:${sessionId}` + migration douce depuis la clé legacy.
- [x] 2026-02-10 — Patch 2b: `persistScore` envoie explicitement `player_id` dans `web/server/actions/gameplay.js`.
- [x] 2026-02-10 — Patch 2c: suppression de la dépendance `created_at/updated_at` dans les writes `cotton_quiz_players` (`player_register`, fallback `update_score`, `deactivate_player`) pour éviter les `SQL_ERROR` si schéma partiel.
- [x] 2026-02-11 — WS quiz: politique player “last connection wins” sur `registerPlayer` (event `SESSION_REPLACED`, close code `4005`, intent `player-replaced`, cleanup mémoire sans `deactivate_player` DB).
- [x] 2026-02-11 — WS quiz: `registerPlayer` strict `player_id` canon (`p:<uuid>`) obligatoire; reject + log `PLAYER_ID_MISSING_OR_INVALID` si absent/invalide; instrumentation `LEGACY_REGISTER_USED` si payload legacy numeric reçu.
- [x] 2026-02-11 — WS quiz: `player_db_id` devient secondaire (`player.playerDbId`, `socket.playerDbId`, `registrationSuccess.playerId`), `deactivate_player` envoyé en mode key-first (`player_id` canon + `playerId` seulement si connu).
- [x] 2026-02-11 — Patch 4 WS→PHP glue: normalisation payload player-scoped dans `envUtils.canvasWrite` (`WS_API_PAYLOAD_VALIDATED`, `player_id` canon obligatoire, `playerId` numeric-only), `persistScore` corrigé key-first (`player_id` canon + `playerId?`), et bridge `quiz_api_update_score`/`quiz_api_deactivate_player` aligné key-first avec `identity_mode` + `legacy_identity`.
- [x] 2026-02-11 — Patch 6 loadtest quiz: génération déterministe `player_id` (`p:<uuid>`) par bot (`cotton-bot-player-id-v1|quiz|sid|botId`), register WS strict (`player_id` obligatoire, `playerId` seulement si numérique connu) et `checkAnswer` key-first (`player_id` + `playerId?`).
