> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Architecture

## Vue d’ensemble (humain)
- Dépôt multi-projets : PHP (sites) + Node (serveurs WebSocket jeux).
- Jeux principaux : Bingo Musical, Blindtest, Quiz.
- Architecture “canvas” : un endpoint bridge côté PHP (`global_ajax.php?t=jeux&m=canvas`) consommé par divers front/canvas.

<!-- AUTO-UPDATE:BEGIN id="arch-overview" owner="codex" -->
## Overview (auto)

### Composants
- **Front web (browser)** : pages “organizer/remote/player” (reads Canvas).
- **Serveurs WS (Node)** : un serveur par jeu (Bingo / BT / Quiz) ; reçoit les events temps réel (players, remote) et persiste certains événements via le bridge Canvas (writes idempotents).
- **Bridge Canvas (PHP)** : endpoint `games_ajax.php?t=jeux&m=canvas` (dans ce repo: `games/web/games_ajax.php`; alias historique: `games/web/global_ajax.php`) qui :
  - valide l’auth inter-service **uniquement** si `event_id`/`eventId` est présent,
  - applique l’idempotence via insertion/déduplication en `game_events`,
  - dispatch vers `game_api_dispatch()` (`games/web/includes/canvas/php/boot_lib.php`) puis vers `*_adapter_glue.php`.
- **Handlers glue (PHP)** : `games/web/includes/canvas/php/*_adapter_glue.php` (logique métier + SQL).
- **DB (MySQL)** : tables de sessions/joueurs + table `game_events` (idempotence/déduplication des writes via `event_id`).

### Flux principaux (READ vs WRITE)

```
Browser (organizer/remote/player)
  |  (READ)  POST games_ajax.php?t=jeux&m=canvas
  |          game=...&action=...&sessionId=...   (NO event_id / eventId)
  v
Canvas Bridge (PHP)  --dispatch-->  *_adapter_glue.php  --SQL-->  MySQL

WS Server (Node)
  |  (WRITE) POST games_ajax.php?t=jeux&m=canvas
  |          game=...&action=...&sessionId=...&event_id=UUID
  |          + header X-Service-Token: ${CANVAS_SERVICE_TOKEN}
  v
Canvas Bridge (PHP)  --idempotence--> game_events (dedupe)
  |                           |
  +--dispatch--> *_adapter_glue.php --SQL--> MySQL
```

### Règles contractuelles “à ne pas casser”
- **Reads vs Writes** : `event_id`/`eventId` ⇒ “write-idempotent” (insert/déduplication `game_events`) ⇒ ne jamais envoyer `event_id` côté front/reads.
- **Auth inter-service** : `X-Service-Token` est vérifié **uniquement** quand `event_id`/`eventId` est présent (sinon le header est ignoré).
- **Normalisation d’action** : si `action` est de la forme `bingo:xxx` avec `game=bingo`, le bridge normalise vers `action=xxx` avant `game_api_dispatch()`.

### Pointeurs vers la doc canon
- Entrypoints : `canon/entrypoints.md`
- Contrat bridge : `canon/interfaces/canvas-bridge.md`
- Registry actions + matrice write/read : `canon/interfaces/actions.md`
- Writes Bingo (inventaire) : `canon/data/bingo-write-map.md`
- Smoke tests : `specs/smoke-canvas-api.md`
- WS (env/pm2) : `pm2-ws.md`
<!-- AUTO-UPDATE:END id="arch-overview" -->
