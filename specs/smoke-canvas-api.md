# Smoke tests — Canvas API (`GAMES/games_ajax.php?t=jeux&m=canvas`, alias: `GAMES/global_ajax.php?t=jeux&m=canvas`)

Pré-requis (checklist):
- `SESSION_TOKEN` (id_securite) valide pour une session en cours.
- Pour tester des **writes** (payload avec `event_id`): connaître le secret `CANVAS_SERVICE_TOKEN` et l’envoyer en header `X-Service-Token`.
- Règle de sécurité: `X-Service-Token` est **requis uniquement** quand `event_id` (ou `eventId`) est présent dans le payload.

## a) Sans token sur une action *write* → 403
```bash
curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=bingo&action=session_update&sessionId=SESSION_TOKEN&id_song=SONG_ID&position=1&event_id=00000000-0000-0000-0000-0000000000aa'
```

## b) Action invalide sans `event_id` (read-ish) → 404 (pas besoin de token)
```bash
curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=bingo&action=does_not_exist&sessionId=SESSION_TOKEN'
```

## c) Action read valide sans `event_id` → 200 (`ok=true`, token optionnel)
```bash
curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=bingo&action=players_get&sessionId=SESSION_TOKEN'
```

## d) Idempotence (double-submit sur une action write)
Exemple avec `bingo:phase_winner` (adapter les placeholders à une session/phase/joueur valides).

### 1er appel (already_processed=false)
```bash
curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H "X-Service-Token: ${CANVAS_SERVICE_TOKEN}" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=bingo&action=phase_winner&sessionId=SESSION_TOKEN&playerId=PLAYER_ID&phase=1&event_id=00000000-0000-0000-0000-000000000001'
```

### 2e appel (same event_id, already_processed=true)
```bash
curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H "X-Service-Token: ${CANVAS_SERVICE_TOKEN}" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=bingo&action=phase_winner&sessionId=SESSION_TOKEN&playerId=PLAYER_ID&phase=1&event_id=00000000-0000-0000-0000-000000000001'
```

## e) Bingo “song_start” → `session_update` (write)
Exemple avec `id_song` et `position` (adapter les placeholders).

```bash
curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H "X-Service-Token: ${CANVAS_SERVICE_TOKEN}" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=bingo&action=session_update&sessionId=SESSION_TOKEN&id_song=SONG_ID&position=1&event_id=00000000-0000-0000-0000-000000000002'
```

## f) Idempotence (double-submit sur `session_update`)
Le 2e appel renvoie `already_processed=true` (et conserve un `numPassedSongs` cohérent).

### 1er appel
```bash
curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H "X-Service-Token: ${CANVAS_SERVICE_TOKEN}" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=bingo&action=session_update&sessionId=SESSION_TOKEN&id_song=SONG_ID&position=1&event_id=00000000-0000-0000-0000-000000000003'
```

## g) Bingo `grid_cells_sync` (write, front-style, non-idempotent)
```bash
curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=bingo&action=grid_cells_sync&sessionId=SESSION_TOKEN&playerId=PLAYER_ID&gridId=GRID_ID&checkedCells=%5B1%2C2%2C3%5D'
```

## h) Bingo `end_game` (write)
### 1er appel (already_processed=false)
```bash
curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H "X-Service-Token: ${CANVAS_SERVICE_TOKEN}" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=bingo&action=bingo:end_game&sessionId=SESSION_TOKEN&reason=playlist_end&ended_at=1730000000000&event_id=00000000-0000-0000-0000-000000000005'
```

### 2e appel (same event_id, already_processed=true)
```bash
curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H "X-Service-Token: ${CANVAS_SERVICE_TOKEN}" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=bingo&action=bingo:end_game&sessionId=SESSION_TOKEN&reason=playlist_end&ended_at=1730000000000&event_id=00000000-0000-0000-0000-000000000005'
```
