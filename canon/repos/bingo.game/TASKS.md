# Repo `bingo.game` — Tasks

## Todo
- Exécuter smoke test complet en environnement intégré: multi-onglets `SESSION_REPLACED` (close 4005), reboot WS + `PLAYERS_HYDRATE_*`, puis vérification DB anti-doublons `(session_id, player_id)`.
- Vérifier les clients legacy et le loadtest: tous les `auth_player` / `auth_player_paper` et `phase_winner` doivent envoyer/résoudre `player_id` canon (`p:<uuid>`), sinon rejet/skip instrumenté.
- Exécuter smoke test loadtest bingo (20s, 3 bots) et confirmer `PLAYER_ID_MISSING_OR_INVALID=0`.

## Quick checks (Patch 6)
- Syntaxe WS:
  - `node --check ../bingo.game/ws/bingo_loadtest.js`
  - `node --check ../bingo.game/ws/bingo_server.js`
- Smoke test bots:
  - `rg -n "BOT_IDENTITY|PLAYER_ID_MISSING_OR_INVALID|LEGACY_REGISTER_USED|auth_player envoyé" ../bingo.game/ws/server-logs.log`
  - Relance à paramètres identiques (`sid` + bot range) et vérifier `player_id` identiques dans `BOT_IDENTITY`.

## Note preload winners (games, 2026-02-11)
- Le preload Bingo exposé par `games` a été enrichi avec `phase_winners[]` lu depuis `bingo_phase_winners` (ordre par `phase`, puis `event_id`) et `players.players[]` (shape compat organizer) lu via `players_get`.
- Shape preload winners:
  - `phase` (int),
  - `player_id` (canon),
  - `player_db_id` (si résolu via `bingo_players`),
  - `player_name`,
  - `event_id`.
- Flag terminal ajouté aussi côté preload:
  - `preload.isTerminated`,
  - `preload.session.isTerminated`.
- Objectif: permettre un rendu statique de fin de session côté front `games` sans connexion WS.

## AUDIT fin de session (2026-02-11, NO PATCH)

### Fichiers inspectés
- `../bingo.game/ws/bingo_server.js`
- `../bingo.game/ws/envUtils.js`
- `../bingo.game/ws/bingo_service.js`
- `../bingo.game/ws/repository/db/db_game_repository.js`

### Constats factuels
- End detection: trois chemins runtime visibles.
- `quitGame` organizer volontaire: émission `SESSION_ENDED`, fermeture joueurs, marquage `sessionEndedGames` (`../bingo.game/ws/bingo_server.js:1460`, `../bingo.game/ws/bingo_server.js:1498`, `../bingo.game/ws/bingo_server.js:1508`).
- `end_game` explicite: write Canvas `bingo:end_game` puis WS `endGame` et fermeture joueurs (sans `SESSION_ENDED`) (`../bingo.game/ws/bingo_server.js:1515`, `../bingo.game/ws/bingo_server.js:1548`, `../bingo.game/ws/bingo_server.js:1619`, `../bingo.game/ws/bingo_server.js:1625`).
- timeout reconnexion organizer: émission `SESSION_ENDED` + fermeture joueurs + marquage `sessionEndedGames` (`../bingo.game/ws/bingo_server.js:2486`, `../bingo.game/ws/bingo_server.js:2504`, `../bingo.game/ws/bingo_server.js:2511`).
- Persistance DB à la fin: `bingo:end_game` payload `{ game:'bingo', sessionId, reason, ended_at, event_id }` (`../bingo.game/ws/bingo_server.js:1549`, `../bingo.game/ws/bingo_server.js:1555`).
- Persistance winners phase: write `phase_winner` payload `{ game:'bingo', sessionId, player_id, playerId?, phase, event_id }` (admin et player flow) (`../bingo.game/ws/bingo_server.js:1894`, `../bingo.game/ws/bingo_server.js:1901`, `../bingo.game/ws/bingo_server.js:2225`, `../bingo.game/ws/bingo_server.js:2232`).
- `event_id` write requis/injecté dans `canvasWrite` (`../bingo.game/ws/envUtils.js:239`, `../bingo.game/ws/envUtils.js:258`).
- Hydratation DB reload organizer: only `players_get` sur session (`{ game:'bingo', sessionId }`) puis mapping dans `paperPlayersByGame` (joueurs fusionnés dans snapshot) (`../bingo.game/ws/bingo_server.js:2754`, `../bingo.game/ws/bingo_server.js:2787`, `../bingo.game/ws/bingo_server.js:2897`, `../bingo.game/ws/bingo_server.js:3098`).
- Payloads WS reload: en `auth_client`/`auth_remote`, snapshot `state` construit via `buildStateFor(...getPlayersSnapshot)`; pas de payload winners/podium dédié (`../bingo.game/ws/bingo_server.js:871`, `../bingo.game/ws/bingo_server.js:1051`, `../bingo.game/ws/bingo_server.js:3137`).

### Gaps identifiés (sans patch)
- Aucune lecture DB de winners de phase au reload (`phase_winner` est write-only côté WS): aucun `winners_get`/`phase_winner_get`/mapping winners trouvé (`../bingo.game/ws/bingo_server.js`, recherche code sur actions read).
- Le snapshot de reprise reconstruit la liste joueurs (`num_connected_players`, `players`) mais pas une liste historique des gagnants de phase; l’UI reçoit les winners uniquement via messages live `phase_over` au moment où ils surviennent (`../bingo.game/ws/bingo_server.js:2287`, `../bingo.game/ws/bingo_server.js:3130`).

## Done
- [x] 2026-02-13 — WS bingo observability: ajout d’un log `WS_CLIENT_DISCONNECTED` enrichi (`sid`, `role`, `meta.ws_client_id`, `meta.ws_role`, `closeCode`, `closeReason`, `intent`, `involuntary`) pour corréler les coupures WS avec les erreurs front de support/hydratation.
- [x] 2026-02-12 — Bingo WS `update_session_infos` hardening: ne diffuse plus de `prizes` implicites vides quand aucune info lots n’est fournie; conservation de l’état lots existant et protection contre effacement UI des lots côté player.
- [x] 2026-02-10 — Audit avant modif (NO PATCH) du cycle joueur WS (auth/reconnect/disconnect) et du lien DB.
- [x] 2026-02-10 — Constat: serveur WS bingo ne reconstruit pas la liste joueurs depuis DB au boot; snapshot basé mémoire/socket (+ papier).
- [x] 2026-02-10 — Constat: `auth_player` remplace une connexion existante même `idPlayer` (anti multi-onglet par socket).
- [x] 2026-02-10 — Constat: disconnect passif => `markInactive` mémoire; désactivation DB seulement sur quit volontaire.
- [x] 2026-02-10 — Constat SQL bridge: `bingo_api_player_register` fait INSERT simple, check idempotence commenté => risque doublons actifs.
- [x] 2026-02-11 — Patch Bingo compat quiz/blindtest: hydratation players DB à la connexion organizer (`PLAYERS_HYDRATE_*` best-effort + dedup déterministe), replacement WS player “last connection wins” (`SESSION_REPLACED` + close `4005` + cleanup `player-replaced`), instrumentation write unifiée `CANVAS_WRITE_OK/ERR` incluant `event_id`.
- [x] 2026-02-11 — Harmonisation identité joueur Bingo: `player_id` canonique (`p:<uuid>`) propagé sur register/assign/hydrate/sync, séparation explicite `player_id` (stable) vs `playerId` (id DB), bridge Bingo durci (résolution identité canonique + fallback legacy numeric -> canonical, `LEGACY_API_NOTE`) et réponses API enrichies (`player_id`, `playerId`, `legacy_identity`, `already_assigned`).
- [x] 2026-02-11 — WS bingo strict: `auth_player`/`auth_player_paper` refusent désormais les connexions sans `player_id` canonique valide (`PLAYER_ID_MISSING_OR_INVALID`), replacement `last connection wins` basé sur `player_id` canon, et logs lifecycle enrichis avec `player_id` + `player_db_id`.
- [x] 2026-02-11 — Hydrate bingo key-first: `PLAYERS_HYDRATE` conserve uniquement les rows avec `player_id` canon, stocke `player_id` + `player_db_id`, et la snapshot WS expose ces deux identités (canon primaire, numérique secondaire).
- [x] 2026-02-11 — Patch 4 WS→PHP glue: `canvasWrite` valide les payloads player-scoped (`phase_winner`, `deactivate_player`) via normalisation canon (`WS_API_PAYLOAD_VALIDATED`), `phase_winner` envoie désormais `player_id` canon key-first (avec fallback lookup local par `playerId`), et `bingo_api_deactivate_player` passe sur `_bingo_resolve_identity` avec retours `identity_mode` + `legacy_identity`.
- [x] 2026-02-11 — Patch 6 loadtest bingo: génération déterministe `player_id` (`p:<uuid>`) par bot (`cotton-bot-player-id-v1|bingo|sid|botId`), envoi `player_id` sur `player_register`/`auth_player` et writes gameplay (`grid_cells_sync`, `deactivate_player`), avec `playerId` numérique envoyé uniquement si connu.
- [x] 2026-02-11 — Reconnect terminal sync: sur `auth_client` et `auth_remote`, si la phase WS est terminale (`-1` ou `>=4`), le serveur renvoie désormais un `endGame` de resynchronisation (payload `{type,endGame,gameStatus,message,players,totalPlayers}`) après le snapshot `state`, sans write DB supplémentaire.
- [x] 2026-02-12 — Uniformisation `admin_player_register` bingo: acceptation key-first (`player_id` canon) avec fallback `playerId` numérique, refresh/diffusion `num_connected_players` enrichi (`player_id` + `playerId`), digest aligné canon-first, et fallback DB pré-migration si colonne `bingo_players.player_id` absente.
- [x] 2026-02-12 — Bingo papier admin (phase manuelle): correction du décalage `next_phase` (calcul basé sur `requestedPhase` quand valide dans `phases_liste`) et restauration des notifs victoire en format historique `PlayerWin` (`log_type=3`, message `"<PHASE> gagnée : Bravo ..."`).
- [x] 2026-02-12 — Bingo fin de session (fallback UI): `endGame` WS enrichi avec `players/totalPlayers`; `phase_over` manuel sans identité envoie `winner_name` fallback; snapshot players durci (`player_id` -> `player_db_id` -> `playerName`) pour éviter la perte de la liste joueurs remote.
