# Audit Bingo Player inscription/réinscription (2026-02-10)

Scope: audit-only, sans patch fonctionnel.

## Verdict explicite

Conclusion: **bug (insert rejoué sans désactivation / sans idempotence)**, pas un mécanisme d'historique volontaire.

Critères observables:
- Pas de garde idempotence côté front pour `player_register` (pas de `event_id`).
- Pas de dédup bridge pour `player_register` (idempotence bridge activée seulement si `event_id` présent).
- `bingo_api_player_register` fait un `INSERT` direct `is_active=1` sans désactiver les anciennes lignes.
- Le check idempotent `(session_id, username, is_active=1)` existe mais est commenté dans le code.
- Schéma DB: aucune contrainte unique sur `bingo_players` (seulement PK `id`).

---

## Diagramme textuel du flux

`player_canvas.php` (imports ES modules)
-> `play/register.js` (submit form / autoreg GM)
-> `apiCall()` (`core/api/api_client.js`, POST form urlencoded)
-> `games_ajax.php?t=jeux&m=canvas`
-> `game_api_dispatch()` (`boot_lib.php`)
-> `bingo_api_player_register()` (`bingo_adapter_glue.php`)
-> `INSERT INTO bingo_players (..., is_active=1)`

---

## 1) Front Player: points d’entrée d’inscription

### 1.1 Entrées identifiées
- Submit utilisateur:
  - `games/web/includes/canvas/play/register.js:1097`
  - `api('player_register', { username: name, sessionId })` à `register.js:1145`
- Auto-register GM iframe (embed=gm):
  - `register.js:761` puis `register.js:811`
  - `api('player_register', { username: GM_NAME, sessionId })`

### 1.2 Quand c’est appelé
- `load`: le module `register.js` est chargé via `player_canvas.php` (`player_canvas.php:315-320`).
- `submit`: appel API au clic submit (`register.js:1097+`).
- `resume/reconnect`: pas d’appel `player_register` si `player_id` local valide; reprise via `players_get` + `player/ready` (`register.js:945-1007`).
- `ws open/first state`: côté player, WS fait auth/ready, pas d’HTTP `player_register` (`play-ws.js:706-770`).

### 1.3 Payload bridge (inscription Bingo)
- Appel front:
  - body construit dans `register.js:552-559`, envoyé en `form`.
  - champs effectifs pour inscription: `game=<slug>`, `action=player_register`, `username`, `sessionId`.
- Transport:
  - `Content-Type: application/x-www-form-urlencoded;charset=UTF-8` (`api_client.js:119-130`).
  - pas de retry automatique dans `apiCall()` (un seul `fetch`, timeout abort, pas de boucle retry).

### 1.4 Risques de double-call front
- Double submit utilisateur: mitigé (bouton désactivé `startBusy`), mais pas verrou global anti-race si deux contextes onglet/appareil.
- Retry manuel après timeout/erreur réseau: possible (première requête peut avoir réussi côté serveur).
- Auto-register GM + submit joueur: séparés (autoreg conditionné à iframe GM), pas applicable au player standard.
- Import module en double: non observé; import unique dans `player_canvas.php:315-320`.

---

## 2) Bridge `games_ajax.php`: dispatch et idempotence

### 2.1 Route + dispatch
- Entrée Canvas: `t=jeux&m=canvas` (`games_ajax.php:103-105`).
- Lecture `game/action` depuis payload (`games_ajax.php:205-207`).
- Dispatch dynamique `{$game}_api_{$action}` via `game_api_dispatch()` (`boot_lib.php:87-102`).

### 2.2 Idempotence bridge
- Le bridge n’active idempotence write que si `event_id/eventId` présent (`games_ajax.php:233-275`).
- Dans ce cas: insert `game_events`, dédup sur SQLSTATE `23000` (`games_ajax.php:155-175`, `287-308`).
- `player_register` front Bingo n’envoie pas `event_id` (`register.js:1145`), donc **pas de guard idempotent bridge**.

### 2.3 Auth headers
- `X-Service-Token` exigé seulement quand `event_id` est présent (`games_ajax.php:229-265`).
- Donc `player_register` (sans `event_id`) passe sans service-token.

---

## 3) PHP glue Bingo: écriture DB `bingo_players`

### 3.1 INSERT exact
- Fonction: `bingo_api_player_register()` (`bingo_adapter_glue.php:1035`).
- SQL:
  - `INSERT INTO bingo_players (session_id, username, gain_phase, is_active) VALUES (:sid, :username, '', 1)` (`bingo_adapter_glue.php:1056-1059`).

### 3.2 Réinscription et `is_active`
- Aucun `UPDATE ... is_active=0` avant insert dans `bingo_api_player_register`.
- La désactivation existe seulement via endpoint dédié `bingo_api_deactivate_player()` (`bingo_adapter_glue.php:968-1024`), appelé dans le front uniquement sur échec grid assign (`register.js:1186`, `1208`) ou quit papier.
- Donc une réinscription rejouée crée une nouvelle ligne active, l’ancienne reste active.

### 3.3 Lookup avant insert
- Lookup idempotent potentiel présent mais commenté:
  - `SELECT id FROM bingo_players WHERE session_id=:sid AND username=:u AND is_active=1 LIMIT 1`
  - bloc commenté `/*/ ... */` (`bingo_adapter_glue.php:1044-1054`).
- En état actuel: **pas de lookup actif avant insert**.

### 3.4 Source de vérité `player_id`
- `player_id` utilisé partout est l’`id` auto-incrément de `bingo_players`:
  - `players_get` expose `id AS playerId` (`bingo_adapter_glue.php:934-951`).
  - `grid_assign` lie la grille via `id_joueur = playerId` (`bingo_adapter_glue.php:1459-1461`).
- Pas de table externe canonicale d’identité joueur/session pour dédupliquer une même personne.

---

## 4) Pourquoi plusieurs lignes pour une même session

Cause directe observée:
1. `player_register` est déclenché (submit/retry/reinscription).
2. Requête sans `event_id` => bridge sans idempotence `game_events`.
3. Glue exécute toujours un `INSERT ... is_active=1`.
4. Ancienne ligne non désactivée automatiquement.
5. Schéma sans contrainte unique empêchant doublon.

Résultat: plusieurs lignes `bingo_players` actives pour un même `session_id` (souvent même username).

---

## Root causes candidates (classées)

1. **Absence d’idempotence sur `player_register` (confirmé)**  
Preuves:
- `register.js:1145` envoie sans `event_id`.
- `games_ajax.php:233-275` n’applique idempotence qu’avec `event_id`.
- `bingo_adapter_glue.php:1056-1059` insert direct.

2. **Réinscription/retry client après timeout ou incertitude réseau (probable, dépend logs runtime)**  
Preuves:
- `apiCall` timeout/abort possible (`api_client.js:141-145`, `233-247`), sans mécanisme de reprise idempotente côté action.
- Un second submit/reload peut rejouer l’inscription.

3. **Historique volontaire via `is_active` (non corroboré pour ce flux)**  
Contre-preuves:
- pas de rotation active/inactive dans `bingo_api_player_register`.
- pas de clé métier stable pour relier anciennes lignes au même joueur.
- pas de contrainte DB pour encadrer “une active + historique”.

---

## Instrumentation/reco (sans patch code ici)

- Ajouter logs corrélés sur `player_register`:
  - front: `request_id/eid`, `sessionId`, `username_hash`.
  - bridge: log `action=player_register`, `has_event_id`, `already_processed`.
  - glue: log insert + `playerId`.
- Décider une règle métier explicite:
  - soit idempotence (`event_id` + dedup bridge),
  - soit unicité active (`session_id + username + is_active=1` via logique/contrainte),
  - soit historique assumé avec désactivation systématique et marqueur de succession.
