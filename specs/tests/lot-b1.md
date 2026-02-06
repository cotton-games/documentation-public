# LOT-B1 — tests manuels (phase_winner via Canvas API)

## Pré-requis
- `CANVAS_API_URL` (optionnel) vers `.../games_ajax.php?t=jeux&m=canvas` (alias: `.../global_ajax.php?t=jeux&m=canvas`; sinon défaut basé sur `CANVAS_ORIGIN`/`ORIGIN`/`WS_SERVER_URL`).
- (Optionnel) `CANVAS_SERVICE_TOKEN` si l’endpoint canvas l’exige (envoyé en header `X-Service-Token`).

## Cas 1 — session papier: remote valide un gagnant
- Démarrer le WS Bingo, puis lancer une session en mode papier.
- Depuis la remote, déclencher un `admin_phase_winner`.
- Attendu:
  - Logs WS: “phase_winner via API ok” avec `sessionId`, `phase`, `winnerPlayerId`, `event_id`.
  - DB (côté canvas): la phase avance (table `jeux_bingo_musical_playlists_clients`) et un log est ajouté (table `jeux_bingo_musical_playlists_clients_logs`).

## Cas 2 — session numérique: victoire via verification
- Démarrer le WS Bingo, puis jouer une partie numérique jusqu’à gagner une phase via `verification`.
- Attendu:
  - Logs WS: “phase_winner via API ok” avec `sessionId`, `phase`, `winnerPlayerId`, `event_id`.
  - DB (côté canvas): phase avancée + log ajouté (mêmes tables que Cas 1).

## Cas 3 — erreur API (URL invalide) : le WS ne crash pas
- Démarrer le WS Bingo avec une URL invalide: `CANVAS_API_URL=http://127.0.0.1:9/invalid`.
- Déclencher un `admin_phase_winner` OU une victoire via `verification`.
- Attendu:
  - Logs WS: “phase_winner via API failed” avec `sessionId`, `phase`, `winnerPlayerId`, `event_id` (sans token de service).
  - Le process WS reste vivant (pas de crash).
