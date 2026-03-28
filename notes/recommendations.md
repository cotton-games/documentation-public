# RECOMMENDATIONS — Architecture, sécurité, perf (WS / Canvas API / DB)

Ce document consigne les recommandations prioritaires pour fiabiliser et faire évoluer l’architecture :
**WS (Node)** → **Canvas API (PHP `games_ajax.php?t=jeux&m=canvas`, alias `global_ajax.php?t=jeux&m=canvas`)** → **DB (SQL)**, avec **PRO** pour le rôle organisateur.

---

## 1) Sécurité (priorité haute)

### 1.1 Auth inter-service (WS → API)
**Problème :** si l’endpoint canvas est publiquement accessible, quelqu’un pourrait appeler des actions sensibles (`update_score`, `phase_winner`, etc.) en devinant/obtenant des identifiants.

**Recommandation :**
- Ajouter un secret serveur entre WS et API :
  - Header conseillé : `X-Service-Token: <secret>`
- Vérifier ce secret côté PHP **uniquement** pour `t=jeux&m=canvas`.

**Résultat :** seules les requêtes provenant des serveurs WS (et éventuellement d’autres services internes) peuvent déclencher des écritures métier.

### 1.2 Validation systématique session/token
- Toujours valider que :
  - `session_id` existe
  - `session_token` correspond à la session (source DB)
- Pour les actions liées à un joueur :
  - vérifier que `player_id` appartient à `session_id`

### 1.3 Token joueur (si pas déjà présent)
**Recommandation :**
- Ajouter un `player_token` généré lors de la création DB du joueur, et exiger `player_id + player_token` au register WS/API.
- But : éviter l’usurpation via un simple `player_id`.

### 1.4 Journaliser les erreurs (sans données sensibles)
- Loguer : `game`, `action`, `session_id`, `player_id`, `event_id`, code d’erreur.
- Ne jamais logger les tokens en clair.

### 1.5 Audit “infos sensibles” & durcissement Git (à faire)
Objectif : réduire le risque de fuite d’informations (notamment via le mirroring privé → public).

- Audit rapide du dépôt : secrets/tokens, URLs internes, données clients, exports/captures, `.env`, dumps, logs, archives, clés privées.
- Améliorer et standardiser `.gitignore` pour empêcher l’ajout involontaire de fichiers sensibles.
- Ajouter/compléter une section “Règles de contribution / sécurité” (ex : `SECURITY.md` ou section dédiée) : quoi ne jamais committer, comment gérer les secrets (GitHub Secrets), quelles données ne doivent jamais être publiées.

---

## 2) Robustesse (priorité haute)

### 2.1 Idempotence (anti double-submit)
**Problème :** le WS peut retry une requête API (timeout, reconnexion, etc.) → double écriture DB.

**Recommandation :**
- Ajouter `event_id` (UUID) à toutes les actions qui écrivent en DB :
  - `update_score`, `phase_winner`, `session_update`, `deactivate_player`, etc.
- Côté PHP : ignorer si `event_id` déjà traité (table ou index unique).

### 2.2 États “ghost players”
**Problème :** joueur créé en DB mais jamais connecté WS (ou disconnect brutal).

**Recommandation :**
- Ajouter/maintenir des champs :
  - `connected_at`, `last_seen`, `is_active`
- Mettre en place un cleanup :
  - désactiver les players inactifs après X minutes (ou à la fin de session)

### 2.3 Standardiser le format de réponse JSON
**Recommandation :**
- Tous les handlers API renvoient un format homogène :
  - `{ ok, data, error, ts }`
- Le WS traite explicitement `ok=false` (et diffuse un événement d’erreur lisible côté UI si nécessaire).

---

## 3) Performance & scalabilité (priorité moyenne/haute selon charge)

### 3.1 Réduire le “chattiness” WS ↔ API
**Problème :** Quiz/Blindtest peuvent déclencher beaucoup d’écritures score.

**Recommandations :**
- Écrire en DB uniquement ce qui est nécessaire :
  - score final + réponses, plutôt que des micro-updates trop fréquentes
- Envisager un **batch** (toutes les N secondes) si la charge augmente.
- Utiliser des index adaptés (voir 4.2).

### 3.2 Timeout / retry côté WS
- Définir un timeout raisonnable pour l’appel API.
- Retry limité + backoff (ex : 1 retry après 200–500ms) uniquement si l’action est idempotente via `event_id`.

### 3.3 Caching léger côté WS (optionnel)
- Pour certaines actions read-heavy (`players_get`, `grid_hydrate`), un cache court (ex : 500ms–2s) peut éviter de surcharger PHP/DB lors des pics.

---

## 4) Base de données (priorité moyenne)

### 4.1 Bingo : assignation de grilles atomique
**Problème :** concurrence lors de l’attribution de grilles.

**Recommandations :**
- Faire l’assignation dans une transaction.
- Ajouter une contrainte d’unicité empêchant une double attribution :
  - ex : unique `(session_id, grid_id)` et/ou `(session_id, player_id)` selon ton modèle.

### 4.2 Index “évidence”
Selon tes requêtes les plus fréquentes (à ajuster), viser des index :
- `players(session_id, is_active)` / `players(session_id, last_seen)`
- `scores(session_id, player_id)` ou table de réponses `(session_id, player_id, question_id)`
- `bingo_grids(session_id, grid_id)` / `bingo_players(session_id, player_id)`

---

## 5) Observabilité (priorité moyenne)

### 5.1 Corrélation
- Faire circuler un `request_id`/`event_id` depuis WS → API → DB/logs pour diagnostiquer facilement.

### 5.2 Endpoint santé
- Ajouter (si utile) :
  - WS : `/health` (ou log de démarrage + métriques simples)
  - API : action `health` interne (protégée) ou endpoint séparé

### 5.3 Table “events” (optionnel mais très pratique)
Créer une table générique `game_events` (ou équivalent) avec :
- `event_id` (unique)
- `game`, `action`
- `session_id`, `player_id`
- `created_at`
- `payload_json` (compact)
Utile pour : idempotence + audit + debug.

---

## 6) Ops (déploiement)

### 6.1 Relance WS Bingo via `version.txt`
- Pratique : quand une relance du serveur WS Bingo est nécessaire, bump `bingo.game/version.txt` (format `restart DD-MM-YYYY/NN`).
- Objectif : déclencher une relance côté infra sans mélanger ce mécanisme avec un versioning applicatif.

---

## 6) Gouvernance & documentation (priorité moyenne)

### 6.1 Garder l’API petite
- Favoriser des actions stables et génériques.
- Éviter la multiplication d’actions “one-off” si elles peuvent être regroupées.

### 6.2 Process “ajouter une action”
Checklist rapide :
1) Nommer : `quiz_api_<action>` / `bingo_api_<action>` / `blindtest_api_<action>` ou `canvas_api_<action>`
2) Définir payload minimal + validations
3) Ajouter `event_id` si écriture DB
4) Réponse JSON standard
5) Ajouter au doc `INTERFACES_CANON.md` et à `ACTIONS_CANON.md`

---

## 7) Priorités suggérées (ordre recommandé)
1) `X-Service-Token` WS→API + vérification côté PHP
2) `event_id` + idempotence sur actions write-heavy (`update_score`, `phase_winner`)
3) `connected_at/last_seen` + cleanup ghost players
4) Sécuriser l’assignation de grilles Bingo (transaction + unicité)
5) Standardiser réponses JSON + gestion d’erreurs WS
6) Ajuster index DB et, si besoin, batch/caching léger

---

Table de mapping (Bingo)
Action canon (API)	Côté WS (message/type courant)	Payload minimal (en + des champs communs)	Handler PHP (cible)	Impact DB (tables touchées)
bingo: phase_winner 

ACTIONS_CANON

	admin_phase_winner / verification 

BINGO_WRITE_MAP

	phase (et si besoin “mode/raison”) + event_id 

BINGO_WRITE_MAP

	bingo_adapter_glue.php 

ACTIONS_CANON

	championnats_sessions, jeux_bingo_musical_playlists_clients, jeux_bingo_musical_playlists_clients_logs 

BINGO_WRITE_MAP


bingo: session_update 

ACTIONS_CANON

	song_start (aujourd’hui = write DB direct WS) 

BINGO_WRITE_MAP

	id_playlist_client (ou équivalent), id_song, position 

BINGO_WRITE_MAP

	bingo_adapter_glue.php 

ACTIONS_CANON

	(aujourd’hui WS) jeux_bingo_musical_morceaux_to_playlists_clients, jeux_bingo_musical_playlists_clients 

BINGO_WRITE_MAP


(à créer / ou à intégrer à session_update) bingo: end_game	end_game (aujourd’hui = write DB direct WS) 

BINGO_WRITE_MAP

	id_playlist_client (ou session_id) + éventuellement reason	Nouveau handler (ou branche dans bingo_api_session_update)	(aujourd’hui WS) jeux_bingo_musical_playlists_clients (mark finished) 

BINGO_WRITE_MAP


(à créer / ou à intégrer à une action existante) bingo: case_click	case_click 

INTERFACES

	id_grid/id_playlist_client, num_case, clicked (+ optionnel ts_client) 

BINGO_WRITE_MAP

	Nouveau handler (ou extension grid_hydrate/grid_lines)	(aujourd’hui WS) jeux_bingo_musical_grids_clients (timestamps / état case) 

BINGO_WRITE_MAP


bingo: grid_assign 

ACTIONS_CANON

	(pas de write DB explicite détecté côté WS pour “assign grid↔player”) 

BINGO_WRITE_MAP

	player_id + (selon modèle) grid_id ou paramètres d’assignation	bingo_adapter_glue.php 

ACTIONS_CANON

	À aligner : aujourd’hui l’assignation “canon” n’apparaît pas comme write DB côté WS 

BINGO_WRITE_MAP


bingo: grid_hydrate 

ACTIONS_CANON

		read (players/remote)	grid_id ou player_id selon impl	bingo_adapter_glue.php 

ACTIONS_CANON

		Read-heavy (DB selon impl)
		Subtilité front (Bingo player):
		- `play-ui.js` ne relance pas `grid_hydrate` si la grille est déjà en cache (numbers déjà chargés via localStorage).
		- Donc l’état “cases cochées” doit être persistant côté client (`localStorage.bingo_checked`) pour survivre aux reloads sans round-trip API.
		- Sinon : `bingo_checked` reste `[]` et un reload pendant la partie ne peut pas ré-afficher les coches.
bingo: grid_lines 

ACTIONS_CANON

		read / compute	grid_id + (optionnel) phase/rules	bingo_adapter_glue.php 

ACTIONS_CANON

	Read-heavy (DB selon impl)
bingo: players_get 

ACTIONS_CANON

	read / broadcast	(souvent rien en +)	bingo_adapter_glue.php 

ACTIONS_CANON

	Read-heavy (DB selon impl)
bingo: player_register 

ACTIONS_CANON

	admin_player_register (et auth joueurs) 

INTERFACES

	identité joueur + (id grid/playlist si nécessaire)	bingo_adapter_glue.php 

ACTIONS_CANON

	Write (création/liaisons) selon impl
bingo: deactivate_player 

ACTIONS_CANON

	player_quit (mais pas de write DB détecté côté WS) 

BINGO_WRITE_MAP

	player_id (+ raison)	bingo_adapter_glue.php 

ACTIONS_CANON

	À implémenter côté API : aujourd’hui la “désactivation” semble mémoire-only côté WS 

BINGO_WRITE_MAP
