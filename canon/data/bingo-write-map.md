> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Bingo – Write map

> Who writes what, where, and why (contractual).

<!-- AUTO-UPDATE:BEGIN id="write-map" owner="codex" -->
# Bingo — WS writes vs Canvas API writes (evidence-based)

Objectif: cartographier les **écritures DB** initiées par le WS Bingo et indiquer si elles passent désormais par la **Canvas API (PHP)**.

## Bingo – Cell state persistence (hybrid)
- **Source de vérité UI**: `localStorage` côté player (`bingo_checked`). L’UI est mise à jour immédiatement sur clic/déclic.
- **Fallback / reprise**: si `localStorage.bingo_checked` est absent/vide au reload, le player appelle `grid_hydrate` et reconstruit l’état depuis la DB (`jeux_bingo_musical_grids_clients.box_*_timestamp`).
- **Persistance DB (best-effort)**: le player envoie périodiquement un snapshot via `grid_cells_sync` (debounced) + flush sur unload/hidden.
- **Impact BO**: les coches peuvent arriver “par paquets” (latence ≈ debounce), car la DB n’est plus écrite à chaque clic.

## Migré (writes via Canvas API, idempotent)

### `session_update` (déclenché par WS `song_start`)
- WS → Canvas API:
  - `bingo.game/ws/bingo_server.js` (handler `case "song_start"`) → POST `game=bingo&action=session_update`
- Payload minimum:
  - `sessionId`, `id_song`, `position`, `event_id`
- Preuve (documentation):
  - `specs/tests/c1.md` + `specs/smoke-canvas-api.md` (idempotence `already_processed`)

## Nouveau (writes via Canvas API, browser → PHP)

### `player_podium_photo_upload` (declenche par `player_canvas`, fin de session)
- Browser -> Canvas API:
  - `games/web/includes/canvas/play/play-ui.js` -> POST `game=<quiz|blindtest|bingo>&action=player_podium_photo_upload`
- Payload minimum:
  - `sessionId`, `rank`, `files_img[]`, `consent=1`
  - contexte joueur:
    - `game_player_id` / `player_db_id`
    - `game_player_key` / `player_id`
    - `photo_row_key?`
- Ecritures DB:
  - reuse du media podium existant via `app_session_results_podium_photo_upload(...)`
  - si consentement fourni et valide:
    - insert d'une preuve dans `championnats_sessions_podium_photos_consents`
    - snapshot du pseudo/libelle runtime (`runtime_username`, `runtime_label`) pour audit d'effacement
  - si l'insert consentement echoue:
    - rollback applicatif par suppression du media fraichement cree
- Remarques:
  - write browser sans `event_id`;
  - autorisation fondee sur l'eligibilite runtime revalidee cote serveur, pas sur la seule presence du CTA front;
  - la liaison EP n'est plus obligatoire pour ce flux player.

### `grid_cells_sync` (déclenché par le player UI, debounced/batch)
- Browser → Canvas API:
  - `games/web/includes/canvas/play/play-ui.js` → POST `game=bingo&action=grid_cells_sync`
- Payload minimum:
  - `sessionId`, `playerId`, `gridId`, `checkedCells` (array ou JSON string)
- Écriture DB (snapshot):
  - `jeux_bingo_musical_grids_clients.box_{1..25}_timestamp` mis à jour en une seule requête
- Remarques:
  - Best-effort (pas d’idempotence `event_id`): l’UI ne bloque pas si la persistance échoue.
  - “Paquets”: une latence est attendue (debounce + flush unload).

### `end_game` (déclenché par WS `end_game`)
- WS → Canvas API:
  - `bingo.game/ws/bingo_server.js` (handler `case "end_game"`) → POST `game=bingo&action=bingo:end_game`
- Payload minimum:
  - `sessionId`, `event_id`
  - optionnels: `reason`, `ended_at`
- Preuve (documentation):
  - `specs/smoke-canvas-api.md`

### `phase_winner` (déclenché par WS `verification` et remote `admin_phase_winner`)
- WS → Canvas API:
  - `bingo.game/ws/bingo_server.js` (handlers `handleVerificationRequestMessage()` et `case "admin_phase_winner"`) → POST `game=bingo&action=phase_winner`
- Payload minimum:
  - `sessionId`, `playerId`, `phase`, `event_id`
- Remarque:
  - L’API accepte aussi la forme `action=bingo:phase_winner` (normalisation côté bridge).
- Persistance DB (transaction) :
  - Insert `bingo_phase_winners(session_id, phase, player_id, event_id)` (UNIQUE `(session_id, phase)` + `event_id`).
  - Replay `event_id` ou même gagnant sur la même phase → `already_processed=true` (pas d’UPDATE).
  - Conflit (phase déjà gagnée par un autre player) → `ok=false`, `reason=phase_winner_conflict`, log WARN.
  - Insert effectif → UPDATE `bingo_players` (`phase_wins_count`++, `last_won_phase`, `last_won_at=NOW()`).

### `resetdemo` (déclenché par organizer → API puis WS `demo_reset`)
- Browser → Canvas API:
  - `games/web/includes/canvas/core/boot_organizer.js` → POST `game=bingo&action=resetdemo`
- Tables touchées (côté PHP, transaction):
  - `jeux_bingo_musical_playlists_clients` (`phase_courante=0`, `morceau_courant=0`)
  - `jeux_bingo_musical_morceaux_to_playlists_clients` (reset timestamps + `flag_listening`)
  - `jeux_bingo_musical_playlists_clients_logs` (delete)
  - `championnats_sessions_lots_to_entites_joueurs` (delete via join lots/session)
  - `bingo_phase_winners` (delete par `session_id`)
  - `jeux_bingo_musical_grids_clients` (reset timestamps + `flag_bonus`, sans désassigner `id_joueur`)
  - `bingo_players` (`gain_phase=''`, joueurs conservés)
- Remarques:
  - Le WS `demo_reset` ne fait pas d'écriture DB; il remet l'état mémoire à neutre et demande aux clients de se resynchroniser.
  - Côté organizer, apres reponse API OK, le front neutralise aussi son store runtime (`En attente`, winners/medailles/podium vides) et recharge/reconfigure l'iframe GM; ce reset local depend de la reponse DB, pas d'un masquage CSS.
  - Un snapshot Bingo demo phase `0` purge les winners/medailles/podium front deja hydrates pour eviter de rejouer une fin locale apres reset.
  - Une generation locale `bingo_reset_epoch:{sessionId}` est ecrite apres reset demo OK et ajoutee aux cles front `bingo_checked` / `bingo_locked` quand elle existe. Elle invalide les anciennes cles pourtant scoppées par `sessionId + player_id + gridId`, necessaire car la demo conserve les assignations de grille.
  - Côté player Bingo, `demo_reset` force maintenant un reset UI immédiat (`En attente`, `mainStarted=false`, reset grille) puis purge `localStorage.bingo_checked`, `bingo_locked` et `bingo_best_phase` avant reload pour éviter de réinjecter un état obsolète post-reset.
  - Au redemarrage suivant, `bingo_reset_epoch` ne sert pas de verrou d'affichage: les signaux live `state`, `reset_game` ou `passed_song` avec phase demarree consomment le runtime post-reset et remettent `mainStarted=true` cote player/iframe GM.

### `reset` (déclenché par WS client `reset`)
- WS → Canvas API:
  - `bingo.game/ws/bingo_server.js` (handler `case "reset"`) → POST `game=bingo&action=bingo:reset`
- Tables touchées (côté PHP, transaction):
  - `jeux_bingo_musical_grids_clients` (reset timestamps + `flag_bonus`)
  - `jeux_bingo_musical_morceaux_to_playlists_clients` (reset timestamps + `flag_listening`)
  - `jeux_bingo_musical_playlists_clients_logs` (delete)
  - `championnats_sessions_lots_to_entites_joueurs` (delete via join lots/session)
  - `jeux_bingo_musical_playlists_clients` (`phase_courante`)

## Writes DB directs depuis le WS
- Aucun write DB “métier” n’est effectué par le WS Bingo (writes délégués à la Canvas API).

## Bonus request (status closed)
- `bonus_request` a été supprimé côté WS (feature non utilisée).

## Audit “reachable in runtime” (WS Bingo, hors loadtest)

### Inventory messages (résumé)
| channel | wsType | classification | evidence (code) |
|---|---|---|---|
| unauth | `checkSession` | DB read | `bingo.game/ws/bingo_server.js` (select `championnats_sessions` + join playlist_client) |
| unauth | `auth_player` / `auth_client` / `auth_remote` / `auth_player_paper` | DB reads (hydrate state) | `bingo.game/ws/bingo_server.js` + repos `bingo.game/ws/repository/db/*` |
| player | `verification` | Canvas API write (`phase_winner` + `event_id`) | `bingo.game/ws/bingo_server.js` → `canvasWrite('phase_winner', …)` |
| organizer | `reset` | Canvas API write (`bingo:reset` + `event_id`) | `bingo.game/ws/bingo_server.js` → `canvasWrite('bingo:reset', …)` |
| organizer | `song_start` | Canvas API write (`session_update` + `event_id`) | `bingo.game/ws/bingo_server.js` → `canvasWrite('session_update', …)` |
| organizer | `end_game` | Canvas API write (`bingo:end_game` + `event_id`) | `bingo.game/ws/bingo_server.js` → `canvasWrite('bingo:end_game', …)` |
| remote | `admin_phase_winner` | Canvas API write (`phase_winner` + `event_id`) | `bingo.game/ws/bingo_server.js` → `canvasWrite('phase_winner', …)` |
| misc | `ensureSessionIdForGame` / `ensureGameProgressHydrated` | DB reads | `bingo.game/ws/bingo_server.js` → `knex('championnats_sessions')` + `DBUtils.getNumberOfPassedSongs()` |

### DB write-like functions (static) and reachability
`bingo.game/ws/repository/db/utils.js` still contains many legacy Knex writes, but they are not referenced by WS message handlers (hors loadtest) in `bingo.game/ws/bingo_server.js` as of this audit.

| function | file | type | reachable from `bingo_server.js` (hors loadtest)? | notes |
|---|---|---|---|---|
| `storeEventLog` | `bingo.game/ws/repository/db/utils.js` | WRITE | no | legacy logs table writes; removed from WS paths |
| `updatePassedSongTimestamp` / `updateCurrentSongIndex` | `bingo.game/ws/repository/db/utils.js` | WRITE | no | legacy song progression writes; WS now uses Canvas API `session_update` |
| `resetAll*` / `eraseLogsForPlaylistClient` / `setStartPhase` | `bingo.game/ws/repository/db/utils.js` | WRITE | no | legacy reset writes; WS now uses Canvas API `bingo:reset` |

## Recommandation (nettoyage)
- Nettoyage effectué : suppression de `case_click` (WS + Canvas) et suppression de `bonus_request` côté WS.

## Tests manuels (checklist)
1) Cocher/décocher rapidement → 1 sync DB après debounce (et flush sur unload).
2) Supprimer `localStorage.bingo_checked` puis reload → état reconstruit via `grid_hydrate` depuis la DB.
3) Multi-device: A coche, attendre flush; B reload sans LS → récupère via DB.
4) BO: le compteur “Nb cases cochées” suit après le flush (latence ≈ debounce).
5) `phase_winner` : 1er call → insert `bingo_phase_winners` + `bingo_players.phase_wins_count`++ + `last_won_*` mis à jour.
6) `resetdemo` : relancer une démo après gains de phase + coches locales → plus aucun gagnant de phase ni lock/check local ne doit survivre au reload player/remote.
6) `phase_winner` replay (même `event_id`) → `already_processed=true`, pas d’insert, pas d’incrément.
7) `phase_winner` autre joueur même phase → `ok=false`, `reason=phase_winner_conflict`, pas d’incrément ni d’avance phase.
<!-- AUTO-UPDATE:END id="write-map" -->

<!-- AUTO-UPDATE:BEGIN id="write-sources" owner="codex" -->
## Source code pointers (auto)
- WS→Canvas API (writes): `bingo.game/ws/bingo_server.js` (search `postCanvasForm(`).
- Bridge + idempotence: `games/web/games_ajax.php` (alias historique: `games/web/global_ajax.php`; write actions require `event_id`, returns `already_processed` on replay).
- PHP handlers (writes): `games/web/includes/canvas/php/bingo_adapter_glue.php` (functions `bingo_api_session_update`, `bingo_api_end_game`, `bingo_api_phase_winner`, `bingo_api_grid_cells_sync`).
- Player podium upload + shared storage: `games/web/includes/canvas/php/boot_lib.php`, `global/web/app/modules/jeux/sessions/app_sessions_functions.php`, migration `games/web/includes/canvas/sql/2026-04-17_player_podium_photo_consent.sql`.
- Evidence documentation: `specs/smoke-canvas-api.md`, `specs/tests/c1.md`, `specs/tests/c2.md`.
<!-- AUTO-UPDATE:END id="write-sources" -->
