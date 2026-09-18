# Audit transversal `event_id` + `*_players` (2026-02-10)

Scope: confirmation-only, aucun patch fonctionnel, aucune DDL appliquée.

## Executive summary

- `event_id` est **opérationnel** sur le journal global `game_events` (bridge) et sur l’événement métier Bingo `bingo_phase_winners`.
- Côté WS (`bingo.game`, `blindtest`, `quiz`), les actions mutatrices passées via `canvasWrite` injectent `event_id` automatiquement.
- Mais le bridge `games_ajax.php` n’exige pas `event_id` universellement: l’idempotence n’est activée que si `event_id` est présent.
- Des writes mutateurs front/organizer existent sans `event_id` (`player_register`, `deactivate_player`, `grid_assign`, `resetdemo`, `prizes_save`, etc.) donc pas de garde idempotence bridge.
- `*_players` est utilisé comme registre de participants/session (ID technique auto-incrément + drapeau `is_active`), pas comme “player cache” stable cross-reinscription.
- Déconnexion silencieuse: en l’état audité, `is_active` n’est pas systématiquement maintenu à 0 (involontaire = souvent mémoire seulement).

---

## Phase 1 — Inventaire tables “événements métier”

## 1.1 Bingo

### Table événement métier identifiée
- `bingo_phase_winners`
  - Type: historique des gagnants de phase Bingo.
  - Champs clés: `session_id`, `phase`, `player_id`, `event_id`, `created_at`.
  - DDL preuve: `canon/data/schema/DDL.sql:247`, `canon/data/schema/DDL.sql:252`.
  - Unicité: `UNIQUE(event_id)` + `UNIQUE(session_id, phase)` (`canon/data/schema/DDL.sql:4048`, `canon/data/schema/DDL.sql:4051`).

### Writer + `event_id`
- Writer PHP: `bingo_api_phase_winner()` (`games/web/includes/canvas/php/bingo_adapter_glue.php:1085`).
- Validation stricte `event_id` non vide + taille <=64 (`bingo_adapter_glue.php:1089`, `bingo_adapter_glue.php:1091`).
- Insert événement: `INSERT INTO bingo_phase_winners (..., event_id)` (`bingo_adapter_glue.php:1226`).
- Idempotence hard locale sur `event_id` (`bingo_adapter_glue.php:1130`).
- Appelant WS: `bingo.game/ws/bingo_server.js` via `canvasWrite('phase_winner', ...)` (`bingo_server.js:1809`, `bingo_server.js:2115`), `event_id` fourni/généré.

### Autres écritures Bingo (non table événement dédiée)
- `session_update`, `bingo:reset`, `bingo:end_game`, `grid_cells_sync`, `grid_assign`, `player_register`, `deactivate_player` écrivent en DB mais pas dans une table événement dédiée avec `event_id` métier.

## 1.2 Blindtest

### Tables événement métier dédiées avec `event_id`
- Aucune table événement métier dédiée trouvée côté bridge blindtest.
- Les writes blindtest ciblent surtout `blindtest_sessions`/`blindtest_players`:
  - `blindtest_api_session_update` (`games/.../blindtest_adapter_glue.php:515`)
  - `blindtest_api_update_score` (`blindtest_adapter_glue.php:543`)
  - `blindtest_api_player_register` (`blindtest_adapter_glue.php:750`)
  - `blindtest_api_deactivate_player` (`blindtest_adapter_glue.php:702`)
- Pas de colonne `event_id` dans `blindtest_players` DDL (`canon/data/schema/DDL.sql:262`).

### Idempotence de write
- Via bridge global `game_events` (si payload contient `event_id`) (`games/web/games_ajax.php:233`, `games/web/games_ajax.php:287`).
- Côté WS blindtest: `canvasWrite` injecte `payload.event_id` pour actions write (`blindtest/web/server/actions/envUtils.js:99`, `envUtils.js:214`, `envUtils.js:236`).

## 1.3 Quiz

### Tables événement métier dédiées avec `event_id`
- Aucune table événement métier dédiée trouvée côté bridge quiz.
- Writes quiz vers `cotton_quiz_sessions`/`cotton_quiz_players`:
  - `quiz_api_session_update` (`games/.../quiz_adapter_glue.php:624`)
  - `quiz_api_update_score` (`quiz_adapter_glue.php:652`)
  - `quiz_api_player_register` (`quiz_adapter_glue.php:859`)
  - `quiz_api_deactivate_player` (`quiz_adapter_glue.php:811`)
- Pas de colonne `event_id` dans `cotton_quiz_players` DDL (`canon/data/schema/DDL.sql:999`).

### Idempotence de write
- Via `game_events` bridge si `event_id` présent (`games_ajax.php:233`, `games_ajax.php:287`).
- Côté WS quiz: `canvasWrite` injecte `event_id` pour writes (`quiz/web/server/actions/envUtils.js:48`, `envUtils.js:210`, `envUtils.js:226`).

---

## Phase 2 — Vérif “event_id partout”

## 2.1 Bridge: règles exactes

- `hasEventId = event_id|eventId présent` (`games/web/games_ajax.php:233`).
- Auth service-token déclenchée seulement si `hasEventId` (`games_ajax.php:239`).
- Idempotence bridge déclenchée seulement si `hasEventId` (`games_ajax.php:272`, `games_ajax.php:274`).
- Si duplication `event_id`: retour `already_processed=true` (`games_ajax.php:296`).
- Si `event_id` absent: dispatch normal, aucune garde idempotence.

## 2.2 Actions mutatrices exposées par le bridge (et comportement `event_id`)

Dispatch dynamique: toute fonction `*_api_<action>` ou `canvas_api_<action>` existante (`games/web/includes/canvas/php/boot_lib.php:96`).

### Tableau actions

| Action bridge | Mutateur DB | `event_id` requis par bridge ? | Comportement si absent | Appelants observés |
|---|---:|---:|---|---|
| `bingo.phase_winner` | Oui | Non (bridge), **Oui dans handler** | Bridge passe; handler rejette `BAD_PARAMS` | WS Bingo (`bingo_server.js:1809`) |
| `bingo.session_update` | Oui | Non | Exécution sans idempotence si absent | WS Bingo (`bingo_server.js:1265`) + organizer/front |
| `bingo:bingo:reset` (action `reset`) | Oui | Non | Exécution sans idempotence si absent | WS Bingo (`bingo_server.js:1128`) + organizer `resetdemo` séparé |
| `bingo:bingo:end_game` (action `end_game`) | Oui | Non | Exécution sans idempotence si absent | WS Bingo (`bingo_server.js:1485`) |
| `bingo.grid_cells_sync` | Oui | Non | Exécution sans idempotence | Front player (`play-ui.js:1119`) |
| `bingo.grid_assign` | Oui | Non | Exécution sans idempotence | Front player (`register.js:1174`) |
| `bingo.player_register` | Oui | Non | Exécution sans idempotence | Front player (`register.js:1145`) |
| `bingo.deactivate_player` | Oui | Non | Exécution sans idempotence | Front player (`play-ui.js:2386`, `register.js:1186`) |
| `quiz.update_score` | Oui | Non | Sans `event_id` => non idempotent bridge | WS Quiz (`quiz gameplay.js:1181`) via `canvasWrite` |
| `quiz.session_update` | Oui | Non | idem | WS Quiz (`quiz gameplay.js:1226`) |
| `quiz.deactivate_player` | Oui | Non | idem | WS Quiz (`quiz connection.js:99`) |
| `quiz.player_register` | Oui | Non | idem | WS Quiz loadtest (`quiz loadtest.js:18`) + front register |
| `blindtest.update_score` | Oui | Non | idem | WS Blindtest (`blindtest gameplay.js:1074`) |
| `blindtest.session_update` | Oui | Non | idem | WS Blindtest (`blindtest gameplay.js:1119`) |
| `blindtest.deactivate_player` | Oui | Non | idem | WS Blindtest (`blindtest connection.js:100`) |
| `blindtest.player_register` | Oui | Non | idem | WS Blindtest loadtest (`blindtest loadtest.js:18`) + front register |
| `canvas.prizes_save` | Oui | Non | idem | Organizer front (`boot_organizer.js:284`) |
| `*.resetdemo` | Oui | Non | idem | Organizer front (`boot_organizer.js:281`) |

### Conclusion phase 2

- “`event_id` partout” est vrai pour les writes WS passant par `canvasWrite`.
- Ce n’est pas vrai pour les writes front/organizer basés sur `canvasCall/apiCall` (pas d’injection `event_id` automatique).

---

## Phase 3 — Safe to add `UNIQUE(event_id)`

## Tables avec `event_id` en schéma

- `game_events.event_id` (`canon/data/schema/DDL.sql:1869`)
  - Déjà `UNIQUE KEY uniq_event_id` (`DDL.sql:4343`).
- `bingo_phase_winners.event_id` (`DDL.sql:252`)
  - Déjà `UNIQUE KEY uniq_event_id` (`DDL.sql:4051`).

## Requêtes de contrôle doublons

```sql
SELECT event_id, COUNT(*) c
FROM game_events
GROUP BY event_id
HAVING c > 1;
```

```sql
SELECT event_id, COUNT(*) c
FROM bingo_phase_winners
GROUP BY event_id
HAVING c > 1;
```

## Exécution locale

- Tentative d’exécution SQL effectuée, non réalisable dans cet environnement (socket/TCP MySQL indisponible sandbox):  
  - `ERROR 2002 ... mysqld.sock` puis `ERROR 2004 ... Can't create TCP/IP socket`.
- Donc: résultat non vérifié runtime ici; commandes prêtes pour exécution sur environnement DB accessible.

---

## Phase 4 — Audit `*_players` (rôle, usages, invariants)

## 4.1 Schéma + index

- `bingo_players`:
  - colonnes: `id`, `username`, `session_id`, `gain_phase`, `created_at`, `is_active`, etc. (`DDL.sql:229`)
  - index: PK `id` uniquement (`DDL.sql:4042`)
- `blindtest_players`:
  - colonnes: `id`, `username`, `session_id`, `score`, `is_active`, ... (`DDL.sql:262`)
  - index: PK `id` uniquement (`DDL.sql:4056`)
- `cotton_quiz_players`:
  - colonnes: `id`, `username`, `session_id`, `score`, `is_active`, ... (`DDL.sql:999`)
  - index: PK `id` uniquement (`DDL.sql:4181`)

Constat: pas de `event_id`, pas de “stable_player_id” métier dédié; `id` est technique auto-incrément.

## 4.2 Usages applicatifs

### Tableau usages clés

| Usage | Requête / code | Suppose unicité joueur ? | Filtre `is_active` ? | Risque |
|---|---|---:|---:|---|
| Listing joueurs actifs (Bingo API) | `bingo_api_players_get` (`bingo_adapter_glue.php:937`) | Non (liste de lignes) | Oui | doublons actifs visibles si multi-lignes |
| Listing joueurs actifs (Quiz API) | `quiz_api_players_get` (`quiz_adapter_glue.php:778`) | Non | Oui | idem |
| Listing joueurs actifs (Blindtest API) | `blindtest_api_players_get` (`blindtest_adapter_glue.php:669`) | Non | Oui | idem |
| Fetch players session state (Quiz) | `_qz_fetch_players` (`quiz_adapter_glue.php:147`) | Implicite oui côté UI, mais DB non contrainte | **Non** | peut réinjecter inactifs/anciens |
| Fetch players session state (Blindtest) | `_bt_fetch_players` (`blindtest_adapter_glue.php:142`) | idem | **Non** | idem |
| Admin papier Bingo count | `knex('bingo_players').where({session_id,is_active:1})` (`bingo_server.js:1959`) | Non | Oui | cohérent pour actifs uniquement |

## 4.3 Maintenance `is_active` et déconnexions silencieuses

### Bingo
- `is_active=0` seulement via API `bingo_api_deactivate_player` (`bingo_adapter_glue.php:978`).
- Déconnexion WS:
  - volontaire: `player_quit` -> `removePlayer` mémoire (`bingo_server.js:1022`, `bingo_server.js:2236`).
  - involontaire: `markInactive` mémoire seulement (`bingo_server.js:2245`, `bingo.game/ws/lib/lib.js:57`).
- Heartbeat timeout coupe la socket (`bingo.game/ws/websocket_server.js:235`) puis disconnection event.
- Pas de preuve d’update DB `bingo_players.is_active` automatique sur timeout/involontaire.

### Quiz / Blindtest
- Déconnexion volontaire: `deactivatePlayerInDB` appelle `CanvasAPI.deactivatePlayer` (`quiz connection.js:57`, `quiz connection.js:99`; `blindtest connection.js:58`, `blindtest connection.js:100`).
- Déconnexion involontaire: `player.isConnected=false` mémoire seulement (`quiz connection.js:76`; `blindtest connection.js:77`), pas de désactivation DB.
- Déconnexion silencieuse couverte transport: heartbeat serveur termine socket (`quiz server.js:312`; `blindtest server.js:312`), puis close handler route vers `handleDisconnect` involontaire (`quiz wsHandler.js:740`; `blindtest wsHandler.js:716`).
- Donc timeout WS n’entraîne pas automatiquement `is_active=0` en DB.

### Observation additionnelle
- `disconnectPlayers()` (quiz/blindtest) contient `Promise.allSettled(deactivations)` mais `deactivations` n’est pas défini dans le fichier audité (`quiz connection.js:256`, `blindtest connection.js:257`, grep local sans définition).  
  => la désactivation batch de fin de session n’est pas démontrable/fiable en l’état.

---

## Notion d’identifiant joueur stable

- Bingo: identifiant utilisé = `bingo_players.id` (renvoyé par `player_register`, `players_get`, lié à `grids_clients.id_joueur`).
  - Pas de clé stable cross-réinscription indépendante de la ligne DB.
- Quiz/Blindtest: identifiant utilisé = `*_players.id` (stocké côté front localStorage, utilisé WS `playerId`).
  - Pas de `player_id` métier durable séparé.
- `eid` front (`register.js`) = corrélation UI, pas identifiant joueur persistant.

---

## Phase 5 — Synthèse décisionnelle (safe plan)

## Décisions à prendre

### Event tables
- Recommandation: maintenir/renforcer `UNIQUE(event_id)` sur toutes tables idempotentes événementielles.
- Tables prêtes (schéma déjà conforme): `game_events`, `bingo_phase_winners`.
- Quiz/Blindtest: pas de table événementielle dédiée actuellement; writes s’appuient sur `game_events` si `event_id` transmis.

### Players tables

Option A — Officialiser “historique de connexions + ligne active”
- Préconditions minimales:
  - désactivation fiable sur timeout/involontaire,
  - toutes les lectures métier/UX filtrent `is_active=1`,
  - éviter les endpoints non filtrés (`_qz_fetch_players`, `_bt_fetch_players`).

Option B — Modèle joueur stable
- Introduire un identifiant joueur stable et contrainte d’unicité logique (par session + stable id), avec upsert.
- Pré-requis:
  - source métier fiable de stable id,
  - stratégie de backfill/migration.

Priorisation recommandée
1. Étape 1: verrouiller le périmètre `event_id` (actions write sans `event_id` à adresser en priorité).
2. Étape 2: décider A vs B pour `*_players` selon besoins métier (historique assumé vs unicité).

## Checklist go / no-go

- `GO` Option A seulement si:
  - chaque usage “liste/count players” filtre `is_active=1`,
  - timeout/involontaire met bien `is_active=0`.
- `NO-GO` Option A si:
  - des usages critiques lisent sans filtre actif,
  - des ghost actives persistent après pertes réseau.
- `GO` Option B si:
  - on peut définir un identifiant joueur stable univoque par session/joueur.

