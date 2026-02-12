# Repo `blindtest` — Tasks

## Todo
- Vérifier en intégration que tous les writes WS player-scoped passent en `identity_mode=canon` (blindtest `update_score` + `deactivate_player`).
- Surveiller `LEGACY_REGISTER_USED`; retirer définitivement le fallback `playerId` dès compteur=0 côté WS register.
- Planifier retrait du fallback legacy côté glue (`identity_mode=legacy`) dès extinction des usages.
- Exécuter un smoke test loadtest WS (20s, 3 bots) et confirmer `PLAYER_ID_MISSING_OR_INVALID=0`.

## Quick checks (Patch 6)
- Syntaxe WS:
  - `node --check ../blindtest/web/server/actions/loadtest.js`
  - `node --check ../blindtest/web/server/actions/envUtils.js`
  - `node --check ../blindtest/web/server/actions/connection.js`
  - `node --check ../blindtest/web/server/actions/gameplay.js`
- Smoke test bots:
  - `rg -n "BOT_IDENTITY|PLAYER_ID_MISSING_OR_INVALID|LEGACY_REGISTER_USED" ../blindtest/web/server/server-logs.log`
  - Relance à paramètres identiques (`sid` + bot range) et vérifier `player_id` identiques dans `BOT_IDENTITY`.
- Contrat bridge blindtest:
  - `php -l ../games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `rg -n "identity_mode|legacy_identity|BAD_PLAYER_ID|PLAYER_NOT_FOUND|_blindtest_is_canonical_player_id" ../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- Contrat front register (games):
  - `rg -n "player_stable_id:|getSessionScopedStableKey|getOrCreateStablePlayerRef|player_register_tx|register/debug" ../games/web/includes/canvas/play/register.js`
- Migration SQL présente:
  - `rg -n "uq_bt_players_session_player|idx_bt_players_session_active|player_id" ../games/web/includes/canvas/sql/2026-02-10_players_player_id_upsert.sql`
- Logs runtime:
  - `rg -n "PLAYER_REGISTER_UPSERT_(OK|ERR)|MISSING_PLAYER_ID|PLAYER_DEACTIVATE_BY_KEY_(OK|ERR)" ../blindtest/web/server/server-logs.log`
- Replacement WS player:
  - `rg -n "PLAYER_REPLACEMENT|PLAYER_SOCKET_REPLACED_CLEANUP|WS_CLIENT_DISCONNECTED" ../blindtest/web/server/server-logs.log`
  - `rg -n "SESSION_REPLACED|4005|player-replaced" ../blindtest/web/server/actions/registration.js ../blindtest/web/server/actions/wsHandler.js ../blindtest/web/server/actions/connection.js`

## AUDIT fin de session (2026-02-11, NO PATCH)

### Fichiers inspectés
- `../blindtest/web/server/actions/gameplay.js`
- `../blindtest/web/server/actions/registration.js`
- `../blindtest/web/server/actions/sessionUtils.js`
- `../blindtest/web/server/actions/envUtils.js`
- `../blindtest/web/server/actions/wsHandler.js`
- `../blindtest/web/server/actions/connection.js`
- `../blindtest/web/server/resources/sessions.js`

### Constats factuels
- End detection: bascule par `initializeOrUpdateSession` quand `gameStatus === "Partie terminée"` puis `endGame(sessionId)` (`../blindtest/web/server/actions/gameplay.js:202`, `../blindtest/web/server/actions/gameplay.js:205`, `../blindtest/web/server/actions/gameplay.js:868`).
- Persistance DB à la fin: write `session_update` via `persistPodium` avec payload `{ sessionId, currentSongIndex, gameStatus, totalPlayers, podium, game:'blindtest' }` (`../blindtest/web/server/actions/gameplay.js:1092`, `../blindtest/web/server/actions/gameplay.js:1112`, `../blindtest/web/server/actions/gameplay.js:1122`). `event_id` injecté/obligatoire (`../blindtest/web/server/actions/envUtils.js:302`, `../blindtest/web/server/actions/envUtils.js:319`).
- Hydratation DB au reload organizer: `ensureSessionPrimaryId` (`session_primary_id`) puis `players_get`, mapping dans `session.players` (`../blindtest/web/server/actions/sessionUtils.js:19`, `../blindtest/web/server/actions/registration.js:618`, `../blindtest/web/server/actions/registration.js:642`, `../blindtest/web/server/actions/registration.js:726`).
- Payloads WS envoyés après reload: snapshot players `updatePlayers` puis, en session terminée, payload `endGame` (orga via `sendMessageToOrganizers`, players reconnect via `getGameState`) (`../blindtest/web/server/actions/gameplay.js:840`, `../blindtest/web/server/actions/gameplay.js:895`, `../blindtest/web/server/actions/gameplay.js:453`, `../blindtest/web/server/actions/gameplay.js:525`).
- Reconstruction podium/classement: tri score desc + tie-break `playerId` alpha, ranking compétition, podium rang 1..3; snapshot mémoire `finalPodium/finalRankings` prioritaire si présent (`../blindtest/web/server/actions/gameplay.js:783`, `../blindtest/web/server/actions/gameplay.js:794`, `../blindtest/web/server/actions/gameplay.js:933`, `../blindtest/web/server/actions/gameplay.js:991`).

### Gaps identifiés (sans patch)
- Pas de read DB podium dédié au reload: only `players_get`; podium reload dépend snapshot mémoire ou recalcul joueurs (`../blindtest/web/server/actions/registration.js:642`, `../blindtest/web/server/actions/gameplay.js:940`, `../blindtest/web/server/actions/gameplay.js:991`).
- `getGameStateForRemote` en session terminée lit `playerRank` sur `finalRankings` alors que le snapshot figé stocke `finalRank`; risque de `playerRank` nul sur ce chemin (`../blindtest/web/server/actions/gameplay.js:464`, `../blindtest/web/server/actions/gameplay.js:468`, `../blindtest/web/server/actions/gameplay.js:885`).

## Done
- [x] 2026-02-12 — WS blindtest: fix `disconnectPlayers` crash (`deactivations is not defined`) en réintroduisant la collecte `deactivations` avant `Promise.allSettled`; fin de session organizer (volontaire) validée sans erreur runtime.
- [x] 2026-02-10 — Patch 2: `blindtest_api_player_register` passé en UPSERT par `(session_id, player_id)`.
- [x] 2026-02-10 — Patch 2: fallback `player_id` serveur si absent (compat vieux client) + trace `MISSING_PLAYER_ID` côté bridge.
- [x] 2026-02-10 — Patch 2: `blindtest_api_deactivate_player` priorise `(session_id, player_id)` puis fallback legacy `(id, session_id)`.
- [x] 2026-02-10 — WS blindtest: logs `PLAYER_DEACTIVATE_BY_KEY_OK/ERR` ajoutés dans `web/server/actions/connection.js`.
- [x] 2026-02-10 — Front register (games): envoi `player_id` stable sur `player_register` pour quiz/blindtest.
- [x] 2026-02-11 — Front register (games): `player_id` désormais stable par session via clé `${slug}:player_stable_id:${sessionId}` + migration douce depuis la clé legacy.
- [x] 2026-02-10 — Patch 2b: `persistScore` envoie explicitement `player_id` dans `web/server/actions/gameplay.js`.
- [x] 2026-02-10 — Patch 2c: suppression de la dépendance `created_at/updated_at` dans les writes `blindtest_players` (`player_register`, fallback `update_score`, `deactivate_player`) pour éviter les `SQL_ERROR` si schéma partiel.
- [x] 2026-02-11 — WS blindtest: politique player “last connection wins” sur `registerPlayer` (event `SESSION_REPLACED`, close code `4005`, intent `player-replaced`, cleanup mémoire sans `deactivate_player` DB).
- [x] 2026-02-11 — WS blindtest: `registerPlayer` strict `player_id` canon (`p:<uuid>`) obligatoire; reject + log `PLAYER_ID_MISSING_OR_INVALID` si absent/invalide; instrumentation `LEGACY_REGISTER_USED` si payload legacy numeric reçu.
- [x] 2026-02-11 — WS blindtest: `player_db_id` devient secondaire (`player.playerDbId`, `socket.playerDbId`, `registrationSuccess.playerId`), `deactivate_player` envoyé en mode key-first (`player_id` canon + `playerId` seulement si connu).
- [x] 2026-02-11 — Patch 4 WS→PHP glue: normalisation payload player-scoped dans `envUtils.canvasWrite` (`WS_API_PAYLOAD_VALIDATED`, `player_id` canon obligatoire, `playerId` numeric-only), `persistScore` corrigé key-first (`player_id` canon + `playerId?`), et bridge `blindtest_api_update_score`/`blindtest_api_deactivate_player` aligné key-first avec `identity_mode` + `legacy_identity`.
- [x] 2026-02-11 — Patch 6 loadtest blindtest: génération déterministe `player_id` (`p:<uuid>`) par bot (`cotton-bot-player-id-v1|blindtest|sid|botId`), register WS strict (`player_id` obligatoire, `playerId` seulement si numérique connu) et `checkAnswer` key-first (`player_id` + `playerId?`).
