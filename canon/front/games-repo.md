# Front — Repo `games` (canvas organizer / player / remote)

Objectif : documenter le fonctionnement du repo front **`games`** côté “canvas” (organizer / player / remote) et la stratégie **logging/telemetry** unifiée :
- **zéro `Logger.*`** dans le code métier (modules UI/WS/API/etc.)
- **captation d’événements `telemetry:*`** via le Bus
- **un seul writer** : `web/includes/canvas/core/logger.global.js` (buffer + flush + agrégation avec les logs WS)

---

## 1) Ce que contient `games`
`games` est le repo front “multi-jeux / multi-rôles” qui sert :
- **Organizer canvas** (interface maître de session)
- **Player canvas** (interface joueur)
- **Remote canvas** (télécommande / remote)

Ces pages chargent un runtime commun (Bus, WS connector, stores, UI helpers) puis un module “game-specific” selon le jeu / mode.

> Tout ce qui suit vise à rendre le suivi d’une session **lisible**, **stable**, et **diagnosticable**.

---

## 2) Entrypoints (pages)
Dans `web/` (exemples) :
- `organizer_canvas.php` → entrée organizer
- `player_canvas.php` → entrée player
- `remote_canvas.php` → entrée remote

Chaque page :
1) injecte `AppConfig` (game, role, session_id, urls…)
2) charge le runtime ESM (via importmap)
3) boot le rôle (UI + WS + state)

---

## 3) Runtime partagé (les briques)
Chemins indicatifs :
- **Bus** : `web/includes/canvas/core/bus.js`  
  Bus événementiel : `on/off/once/emit`.  
  Règle : le Bus ne loggue pas. En cas d’erreur handler → emit `telemetry:error:handler`.
- **WS connector / transport** : `web/includes/canvas/core/ws_connector.js` (+ éventuels effects `ws_effects.js`)  
  Règle : la couche transport **émet** des événements (status/send/recv), ne loggue pas.
- **Stores / state** : `web/includes/canvas/core/game_store.js` (et modules associés)  
  Règle : les erreurs internes sont remontées en telemetry, pas en console.
- **UI / affichage** : `web/includes/canvas/core/canvas_display.js`, `web/includes/canvas/remote/*`, `web/includes/canvas/play/*`

---

## 4) Logging unifié : principe “telemetry → writer”
### 4.1 Interdits
- **Interdit** : `Logger.*` dans tout fichier de `web/includes/canvas/**`  
  **Exception unique** : `web/includes/canvas/core/logger.global.js` (writer)
- (Optionnel mais recommandé) Interdit : `console.*` dans `web/includes/canvas/**`  
  Exception : `logger.global.js` peut miroir console en mode debug.

### 4.2 Ce que fait le code métier
Le code métier n’écrit pas de logs. Il émet des événements normalisés :

- `Bus.emit("telemetry:<channel>:<name>", payload)` (ex. `Bus.emit("telemetry:front:boot", payload)`)

Exemples :
- `telemetry:front:boot`
- `telemetry:session:init`
- `telemetry:hydrate:start|ok|fail`
- `telemetry:api:call:start|ok|fail`
- `telemetry:ws:status` (open/close/error/reconnect)
- `telemetry:ws:send`
- `telemetry:ws:recv`
- `telemetry:ui:action`
- `telemetry:front:error`
- `telemetry:front:unhandledrejection`
- `telemetry:error:handler`
- `telemetry:session:end`

### 4.3 Payload minimal (contrat)
Chaque événement doit transporter un contexte minimal :
- `game`
- `role` (`organizer|player|remote`)
- `session_id` (si connu ; sinon vide puis complété)
- `meta` (objet libre : action, status, duration_ms, http_status, ws_type…)

Recommandation spécifique pour `telemetry:api:call:*` (dédoublonnage / idempotence) :
- `meta.action` ou `meta.endpoint`
- `meta.request_id` (id unique de l’appel)
- `meta.duration_ms`
- `meta.http_status`

> Objectif : permettre au writer de produire une timeline stable, quelle que soit la source de l’événement.

---

## 5) `logger.global.js` = writer unique (buffer + flush)
Fichier : `web/includes/canvas/core/logger.global.js`

Responsabilités :
1) **écouter** les events `telemetry:*` (via Bus)
2) **décider du level** (info/debug/warn/error) selon des règles simples
3) **normaliser** en log structuré (schema commun)
4) **bufferiser**
5) **flush** (en fin de session, on-demand, ou triggers) vers l’agrégateur (WS/proxy)

### Niveaux recommandés
- **INFO** : jalons session + actions majeures + ws status
- **DEBUG** : transport (send/recv), start d’API/hydrate, détails techniques
- **WARN/ERROR** : uniquement sur fail + erreurs globales

---

## 6) Comment ajouter un nouveau “signal”
Checklist :
1) Identifier le bon event (éviter d’en créer un nouveau si `ui:action` ou `api:call` suffit)
2) Émettre `Bus.emit("telemetry:...", { game, role, session_id, meta })`
3) Vérifier dans `logger.global.js` que l’event est routé (niveau + shape)
4) Vérifier dans le viewer / export (timeline lisible)

---

## 7) Garde-fou (anti-régression)
Un script (ex : `check-no-logger.sh`) doit échouer si `Logger.` apparaît ailleurs que dans `logger.global.js`.

Recommandation :
- scope : `web/includes/canvas/**`
- exclusions : uniquement `web/includes/canvas/core/logger.global.js`
- optionnel : même règle pour `console.`

---

## 8) Debug & outils hors runtime
Certains fichiers peuvent être des outils (bots, admin UI, viewer).  
Ils ne doivent pas polluer le runtime session, et peuvent être traités séparément.

---

## Annexes
- Voir aussi : `canon/logging.md` (principes globaux) et les specs/logs session côté WS.
- Les telemetry front ne doivent pas ressortir en `LEGACY_LOG` dans les logs WS ; elles sont remappées en events canons lors de l’agrégation (cf. `canon/ws/bingo-ws-logs-clean.md`).
