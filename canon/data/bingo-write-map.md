<!-- AUTO-UPDATE:BEGIN id="hub-suspend-20260910-bingo-writes" owner="codex" -->

## 23/09/2026 — Préparation E1

[Contrat local](../../notes/hub-session-readiness-2026-09-23.md) : journal `game_events/action=hub_session_preparation`, version 1, clé dérivée d’E1 ; opération initiale Bingo déterministe rejouée par le reset existant. Le gate exige opération completed et génération courante. Aucun nouveau schéma, aucune allocation de stock dans le endpoint ciblé WS. Les écritures de stock/allocation existantes du parcours public sont conservées.


### 22/09/2026 — Auth numérique : aucune nouvelle écriture

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](../deployment-status.md).

Prélecture repository de routage et payload Player allégé ; auth complète et guards reset/lifecycle conservés. Suppression du premier reset_state de routage, pas du reset gameplay ni de ses verrous ; attribution/stock/grilles entièrement inchangés. `hub_lifecycle(stage:read)` peut toujours journaliser :N appels nominaux, aucun effet supplémentaire ajouté. [Rapport](../../notes/bingo-digital-auth-performance-2026-09-22.md).


### 22/09/2026 — Capacité WS / publication BT (local)

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](../deployment-status.md).

Cohortes fermées avant fetch de `hub_capacity_get` : aucun cache de réponse réutilisé par une admission ultérieure, contrat API/stock/verrou Bingo inchangé. Modules `capacity_reads.js` à livrer avec `envUtils` et helpers capacité. BT indexe le lookup Player. Markers Quiz/BT/Bingo : `restart 22-09-2026/01` ; redémarrage des trois WS nécessaire après livraison future autorisée, aucun effectué. Pas de nouvel endpoint/env/SQL ni reload PHP. [Contrat, tests et limites](../../notes/hub-capacity-publication-patch-2026-09-22.md).


## 21/09/2026 — PATCH3 association papier

Aucun SQL/migration ni algorithme de write modifié. Le fallback D-only sans socket rejoint maintenant le write `phase_winner` canonique existant avec K+D résolus ; identité absente/non résolue conserve `advancePhaseWithoutWinner`. Un ACK déjà persisté ne déclenche aucun des deux writes. Résolution read-only via le lecteur PATCH1. [Rapport](../../notes/bingo-paper-association-patch3-2026-09-21.md).


## 21/09/2026 — Roster papier

Le bind WS relit la participation persistée ; il ne fait ni INSERT ni réactivation. Préload et lecture live excluent les inactifs ; historique explicite conservé. La réconciliation conserve les grilles mémorisées ; les writes score/gains/winner sont hors passe. [Contrat](../interfaces/paper-roster.md).


21/09/2026 — Upsell Hub : UPDATE conditionnel ascendant de `championnats_sessions.nb_joueurs_max`, INSERT uniquement des grilles libres manquantes dans `jeux_bingo_musical_grids_clients`, sous verrou playlist/support de capacité. Générateur existant avec offset ; secrets/numéros/affectations/scores existants conservés. Aucun ALTER/migration. [Détails](../../notes/hub-capacity-upsell-2026-09-21.md).


18/09/2026 — Expiration involontaire officielle, patch local : ajout de l’événement idempotent `hub_runtime_expired` dans `game_events` et clear CAS `games_hubs.active_session_id`. Tables/schema inchangés. Identité capturée par WS, contrôlée sous verrou Hub ; aucune phase terminale ni complétion/résultat créé. Grilles/résultats persistés conservés, runtime invalidé. Papier/numérique communs ; démos et suspension explicite exclues. [Payload et idempotence](../interfaces/canvas-bridge.md), [tests](../../notes/hub-runtime-expired-2026-09-18.md).


18/09/2026, local non déployé : aucune table/migration ajoutée. Les événements lifecycle existants conservent `trigger`, `surface`, `page_id`, `routing_generation`, `routing_intent_id` et le `request_id` corrélé. La présence reste dans la table existante ; sa validation utilise la publication courante. La preuve de retrait d’une socket et son page ID restent en mémoire WS uniquement ; aucune écriture de gameplay supplémentaire.


## Suspension Hub officielle — patch local du 10/09/2026

`hub_suspend` ajoute uniquement des événements de lifecycle à `game_events`, l’invalidation des commandes Hub et le clear conditionnel du focus/présence. Il ne désactive pas `bingo_players`, ne vide pas les grilles, ne change pas les phases et ne passe pas par `sessionEndedGames` ou la fin naturelle.

Pendant le gel, les handlers WS et le dispatch HTTP refusent les nouvelles mutations (phase winner, inscriptions, grilles, progression/reset/fin). Les Maps/roster restent vivants jusqu’à reprise explicite ou cleanup opportuniste après le cutoff Hub. Après restart, seules les données persistées existantes sont restaurables ; pas de snapshot durable supplémentaire. [Contrat](../../notes/hub-suspend-patch-2026-09-10.md).


16/09/2026 — Notifications gagnantes Bingo : reconstruction depuis winners structurés à la lecture WS, formatter commun live/reprise. Log PHP historique et tous les writes conservés. Contrat détaillé dans `canon/repos/bingo.game/README.md`. Patch local non déployé.

<!-- AUTO-UPDATE:END id="hub-suspend-20260910-bingo-writes" -->

> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Bingo – Write map

> Who writes what, where, and why (contractual).

<!-- AUTO-UPDATE:BEGIN id="write-map" owner="codex" -->

### Hotfix hub_soiree — 23/09, non déployé

Validation WS ciblée : SELECT session, mapping/Player et participation Bingo ; pas de stock global, allocation, GET_LOCK ni écriture d’admission. Auth grille/secret, état individuel et reset versionné conservés sans changement. Les appels capacité/stock nécessaires au preload, auth organisateur, probes et autres chemins restent en place. Garde autostart dans sessionStorage du Master ; aucune nouvelle table, migration ou écriture `game_events`. Le journal de préparation E1 décrit plus bas appartient au chantier complet et n’est pas porté. [Rapport](../../notes/hub-soiree-hotfix-2026-09-23.md).

# Bingo — WS writes vs Canvas API writes (evidence-based)

Objectif: cartographier les **écritures DB** initiées par le WS Bingo et indiquer si elles passent désormais par la **Canvas API (PHP)**.

## Injection Hub papier à froid
- L'ensure commun préalable délègue à `bingo_historical_session_ensure(...)`, qui relit uniquement la session native `championnats_sessions`.
- Ce chemin ne lance pas `build_preload_for_game(...)`, n'insère ni runtime parent ni grille/carton et ne modifie aucune affectation existante. Les writes Bingo restent ceux de `player_register` puis des actions de grille historiques.

## Bingo – Cell state persistence (hybrid)
- **Source de vérité UI**: `localStorage` côté player (`bingo_checked`). L’UI est mise à jour immédiatement sur clic/déclic.
- **Fallback / reprise**: si `localStorage.bingo_checked` est absent/vide au reload, le player appelle `grid_hydrate` et reconstruit l’état depuis la DB (`jeux_bingo_musical_grids_clients.box_*_timestamp`).
- **Persistance DB (best-effort)**: le player envoie périodiquement un snapshot via `grid_cells_sync` (debounced) + flush sur unload/hidden.
- **Idempotence navigateur**: chaque snapshot porte un `event_id`; un retry du même snapshot réutilise cet ID, puis l'ACK le libère.
- **Impact BO**: les coches peuvent arriver “par paquets” (latence ≈ debounce), car la DB n’est plus écrite à chaque clic.
- **Format court 2026-06-26**: `id_jeu_bingo_musical_format=5` utilise 20 morceaux en playlist client et 9 cases utiles en grille 3x3; les colonnes `box_10_number` a `box_25_number` restent a 0 pour les grilles generees.

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
  - `sessionId`, `player_id`, `playerId?`, `gridId`, `checkedCells` (array ou JSON string), `event_id`, `bingo_reset_generation`
- Écriture DB (snapshot):
  - `jeux_bingo_musical_grids_clients.box_{1..25}_timestamp` mis à jour en une seule requête
- Remarques:
  - Best-effort mais idempotent: l’UI ne bloque pas si la persistance échoue et conserve l'ID pour le retry du même snapshot.
  - “Paquets”: une latence est attendue (debounce + flush unload).
  - Génération courante obligatoire après le premier reset ; ancienne/absente refusée HTTP409 avant écriture. Absence compatible seulement en génération 0. Snapshot inchangé accepté même si zéro ligne modifiée. Verrou commun au reset et aux attributions.

### `end_game` (déclenché par WS `end_game`)
- WS → Canvas API:
  - `bingo.game/ws/bingo_server.js` (handler `case "end_game"`) → POST `game=bingo&action=bingo:end_game`
  - après `phase_winner` papier acquitté avec `nextPhase=-1`, le WS appelle ce handler directement; la présence du Master n'est pas requise.
- Payload minimum:
  - `sessionId`, `event_id`
  - optionnels: `reason`, `ended_at`
- Preuve (documentation):
  - `specs/smoke-canvas-api.md`
- Ordre terminal:
  - `phase_winner` persisté → `end_game` persisté → `hub_session_natural_ended` → `HUB_SESSION_FINISHED`.
  - Un verrou par partie coalesce le terminal Remote/Master. En échec de `end_game`, aucun podium terminal ni callback Hub n'est diffusé et le verrou est libéré pour retry.

### `phase_winner` (déclenché par WS `verification` et remote `admin_phase_winner`)
- WS → Canvas API:
  - `bingo.game/ws/bingo_server.js` (handlers `handleVerificationRequestMessage()` et `case "admin_phase_winner"`) → POST `game=bingo&action=phase_winner`
- Payload minimum:
  - `sessionId`, `playerId`, `phase`, `event_id`
- Remarque:
  - L’API accepte aussi la forme `action=bingo:phase_winner` (normalisation côté bridge).
  - `phases_liste` conserve son sentinelle initial `0`; `phase_courante` est l'index 0-based dans cette liste complète. L'avancement papier sans joueur modifie seulement cet index et n'insère aucune ligne gagnante.
- Persistance DB (transaction) :
  - Insert `bingo_phase_winners(session_id, phase, player_id, event_id)` (UNIQUE `(session_id, phase)` + `event_id`).
  - Replay `event_id` ou même gagnant sur la même phase → `already_processed=true` (pas d’UPDATE).
  - Conflit (phase déjà gagnée par un autre player) → `ok=false`, `reason=phase_winner_conflict`, log WARN.
  - Insert effectif → UPDATE `bingo_players` (`phase_wins_count`++, `last_won_phase`, `last_won_at=NOW()`).
  - Une désactivation/réinscription joueur ou l'attribution d'une nouvelle grille ne supprime pas ce résultat historique; seule une action de reset complet purge `bingo_phase_winners` et les états de gain associés.

### `resetdemo` et `reset` — génération serveur (11/09/2026, patch local)
- Une seule primitive : `_bingo_reset_demo_state`, phase 0 pour `resetdemo`, phase cible 1 par défaut pour `reset` de lancement WS.
- Identités, session/playlist et propriété/contenu des grilles conservés. Aucun `id_joueur=0`, aucune recréation de participation, aucune nouvelle attribution pour un propriétaire. Nouveaux joueurs admis par les règles historiques.
- Reset SQL : phase/position, timestamps/flags d’écoute, cases/bonus, logs/lots attribués, `bingo_phase_winners`. `bingo_players` : `gain_phase=''`, `phase_wins_count=0`, `last_won_phase=NULL`, `last_won_at=NULL` ; identité et activité conservées.
- Verrou nommé par playlist pour reset, inscription/attribution, snapshots et mutations ; vérification des postconditions avant succès. Les tables historiques MyISAM empêchent de garantir un rollback intégral par transaction seule.
- Stockage : `game_events`, action `bingo_reset_operation`, `session_id` token ; `payload_json` contient génération, request_id, phase, statut pending/completed et résultat. Marqueur durable avant la primitive, finalisé après succès ; aucune migration. Garder ces événements pendant la vie de la session.
- Idempotence : même `event_id` logique → même résultat, une seule génération. Pending après erreur partielle bloque le gameplay ; même ID reprend le reset. Le Master conserve cet ID en sessionStorage et partage une promesse entre doubles clics. Les refus concurrents stale ne créent pas une génération supplémentaire.
- `reset_state` expose génération/phase/playlist/reset_pending au WS. Preload lisible pendant pending pour permettre la reprise ; inscriptions/hydratations runtime bloquées jusqu’au succès.
- Le lancement attend `reset_ack` corrélé avant jingle/lecture ; opération stable en sessionStorage, retry conservé même après perte de connexion. Auth Master possible pendant pending uniquement pour récupérer le reset.
- WS : file par partie, contrôle de génération, contexte asynchrone versionné, playback/position/caches/gardes dérivées vidés avant ACK, roster et configuration lots conservés. Diffusion aux Players/Remote/Master. Notification répétée = pas de second nettoyage d’une partie reprise.
- Player : autorité serveur `bingo_reset_generation`, coches/locks/médaille sous `server-<g>`, purge à changement y compris au retour absent ; identité et grille conservées. Les réponses/snapshots anciens ne deviennent pas des writes de nouvelle génération. Migration des anciennes clés scoppées en génération 0.
- [Fichiers, matrice des 25 cas, commandes et réserves](../../notes/bingo-reset-generation-patch-2026-09-11.md). Futur Hub Recommencer non implémenté ; aucune livraison PROD revendiquée.

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
- Writes browser Bingo: `games/web/includes/canvas/play/register.js` (`player_register`, `grid_assign`) et `games/web/includes/canvas/play/play-ui.js` (`grid_cells_sync`), avec IDs stables par tentative logique.
- PHP handlers (writes): `games/web/includes/canvas/php/bingo_adapter_glue.php` (functions `bingo_api_session_update`, `bingo_api_end_game`, `bingo_api_phase_winner`, `bingo_api_grid_cells_sync`).
- Player podium upload + shared storage: `games/web/includes/canvas/php/boot_lib.php`, `global/web/app/modules/jeux/sessions/app_sessions_functions.php`, migration `games/web/includes/canvas/sql/2026-04-17_player_podium_photo_consent.sql`.
- Evidence documentation: `specs/smoke-canvas-api.md`, `specs/tests/c1.md`, `specs/tests/c2.md`.
<!-- AUTO-UPDATE:END id="write-sources" -->
