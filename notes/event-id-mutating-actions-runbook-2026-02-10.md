# Runbook — Event ID mutating actions (Patch Point 1)

Date: 2026-02-10
Scope: `games` bridge/front (`games_ajax.php`, `play/register.js`, `play/play-ui.js`, `core/api/api_client.js`)

## Covered mutating actions
- `player_register`
- `deactivate_player`
- `grid_assign`
- `resetdemo`
- `prizes_save`

## What to verify in logs
- Bridge info log on receive: `[canvas bridge][EVENT_ID_RX] action=<action> event_id=<id>`
- Bridge warning compat (should trend to 0): `[canvas bridge][MISSING_EVENT_ID] ... generated_event_id=<id>`
- Idempotent replay response: `ok=true`, `idempotent=true`, `already_processed=true`, same `event_id`

## Manual checks (browser)
1. Player register flow (Bingo player page): submit registration.
2. Bingo grid assignment: continue until grid is assigned.
3. Quit Bingo player: trigger `deactivate_player`.
4. Organizer demo reset: trigger reset from organizer UI.
5. Organizer prizes save: edit/save prizes.
6. Inspect PHP error log for `EVENT_ID_RX` on each action and confirm `MISSING_EVENT_ID` absent (or rare legacy caller).

## Manual checks (curl examples)
Replace `<token>` and `<service-token>`.

```bash
curl -sS -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H 'X-Service-Token: <service-token>' \
  --data-urlencode 'game=bingo' \
  --data-urlencode 'action=session_update' \
  --data-urlencode 'sessionId=<token>' \
  --data-urlencode 'event_id=11111111-1111-4111-8111-111111111111'
```

Replay exact same request: expect `already_processed=true`.

```bash
curl -sS -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  --data-urlencode 'game=bingo' \
  --data-urlencode 'action=player_register' \
  --data-urlencode 'sessionId=<token>' \
  --data-urlencode 'username=TestPlayer'
```

Expect success in compat mode even without `event_id`, with bridge-generated id and `MISSING_EVENT_ID` warning.
