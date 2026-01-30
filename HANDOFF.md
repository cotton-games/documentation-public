# Handoff

<!-- NOTE TO CODEX:
Only edit inside AUTO-UPDATE blocks.
If required info is missing, update HANDOFF next steps instead of guessing.
-->

> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

## Contexte (humain)
Objectif : permettre à un agent IA de reprendre le travail immédiatement, avec une vue d’ensemble assez détaillée (archi, interfaces, entrypoints, DB) et un “où on en est” maintenu.

<!-- AUTO-UPDATE:BEGIN id="handoff-status" owner="codex" -->
## Current status (auto)
**Front telemetry refonte (29 jan 2026)**  
- `core/bus.js` ajoute les handlers wildcard et remonte `telemetry:error:handler` sur exception (lignes 7-84).  
- `core/logger.global.js` installe le routeur `telemetry:*` avec niveaux auto + capture error/unhandled (lignes 80-120, 520-556).  
- WS front : `core/ws_connector.js` n’écrit plus de logs, émet `telemetry:ws:status/send/recv` uniquement.  
- Front métier : `core/boot_organizer.js`, `play/register.js`, `play/play-ui.js`, `play/play-ws.js` utilisent `telemetry:*` (`ui:action`, `api:call:*`, `front:error`, etc.) à la place de `Logger.*`.  
- Runtime canvas : `core/canvas_display.js` + remote/support/session/persist/modals/remote-ui/bingo-notifs/player` émettent uniquement `telemetry:*` (`ui:action`, `front:error`, `api:call:fail`, `error:handler`), plus aucun `Logger/console`.  
- Garde-fou : script `games/web/check-no-logger.sh` étendu à tout `includes/canvas` et bloc `console.*` (exclu `logger.global.js`).  
- Doc canon : ajout d’un index Front vers `canon/front/games-repo.md` + règle logger unique (fichier `canon/front/INDEX.md`, lignes 1-8) généré via `scripts/gen-sitemap.mjs` (lignes 128-143); `canon/INDEX.md` référence `front/` (lignes 12-15) et `SITEMAP.md` inclut l’index (lignes 34-44) après `npm run docs:sitemap`.  
- À faire : brancher le script anti-Logger dans la CI `games` et vérifier l’impact sur les tests front.
**WS writer (30 jan 2026)**  
- `ws/telemetry_writer.js`: remap `LEGACY_LOG` from `GAMES_FRONT` into canonical events (FRONT_BOOT / FRONT_WS_STATUS / API_CALL_OK|ERROR / UI_ACTION / FRONT_ERROR), keeps original ts, fixes “indexed chars” payloads, and dedups `API_CALL_OK` by (session_id, action|endpoint, request_id, ttl 2s).  
- Doc: `canon/ws/bingo-ws-logs-clean.md` note on front log remap & dedup.
**WS writer (30 jan 2026) – part 2**  
- `ws/telemetry_writer.js`: strips empty Buffer `reason` in `WS_CLIENT_DISCONNECT`; remap keeps source=GAMES_FRONT with ingest_source=BINGO_WS; API_CALL_OK dedup tightened (250ms) and works even without request_id using fallback (role/playerId/gridId/gridNumber/username/playlistId) while merging richer payloads.
<!-- AUTO-UPDATE:END id="handoff-status" -->

<!-- AUTO-UPDATE:BEGIN id="handoff-next-steps" owner="codex" -->
## Next steps (auto checklist)
- [ ] Validation terrain : 1 session par jeu (Bingo/Quiz/Blindtest) et capture JSONL via `logs_session.html` montrant `API_CALL_ATTEMPT/RESULT/ERROR` (writes → `event_id`, `already_processed` si replay) ; vérifier que les nouvelles lignes RESULT ko sont en INFO et les succès en DEBUG.
- [ ] Vérifier que les logs legacy réseau apparaissent encore mais en DEBUG (`LEGACY_API_NOTE` / `legacy_api=1`) et que le viewer les masque par défaut.
- [ ] Vérifier côté front que `LOG_BUFFER_LEVEL=info` n’empêche pas les `API_CALL_*` d’être présents dans `log_batch` (bufferEntries) et dans les exports viewer min_level=debug.
- [ ] Jouer une session (Quiz/Bingo/BT), relancer le cron, vérifier que `reporting_games_sessions_detail` reflète la fenêtre M-1/M et que la somme des lignes = sessions affichées (y compris filtres jeu/client) + ouverture `logs_session.html` via le bouton Logs.
- **Phase 1 – Vérifs post-normalisation**  
  - [ ] Tester `/logs_session.html` sur une session réelle (BT/Quiz/Bingo) et confirmer affichage des front logs + compteur `invalid`.  
  - [ ] Vérifier que `statusSeed`/`statusSeedPhase` restent cohérents après normalisation.  
- **Phase 2 – Réduction bruit**  
  - [ ] Agréger/downgrader heartbeats (BT/Quiz) et `remote_missing` (Bingo) pour limiter le volume.  
  - [ ] Supprimer les lignes texte legacy restantes côté Quiz (`server-logs.log`) ou les convertir en JSON compact.  
- **Phase 3 – Durcissement**  
  - [ ] Proxy logs: valider JSON + option `min_level`.  
  - [ ] Viewer: badge `log_schema_version`/source + export JSONL filtré (sans payload sensibles).  
  - [ ] Éventuel `request_id` côté viewer pour corréler filtres / actions user.
<!-- AUTO-UPDATE:END id="handoff-next-steps" -->

<!-- AUTO-UPDATE:BEGIN id="handoff-risks" owner="codex" -->
## Risks / debt (auto)
- Bruit heartbeat (BT/Quiz) et remote_missing (Bingo) toujours volumineux → coût lecture `/logs`, pagination potentiellement lente.  
- Lignes texte legacy Quiz toujours présentes dans `server-logs.log` (non comptées dans `invalid`) → possible perte d’info timeline.  
- Request_id auto front généré séquentiel, pas encore corrélé aux actions utilisateur (corrélation limitée).  
- Proxy ne valide pas le JSON → en cas de fichier corrompu, le viewer peut encore échouer (500 WS ou parse error côté client).
<!-- AUTO-UPDATE:END id="handoff-risks" -->

## Validation (humain)
- Smoke test Canvas API : `specs/smoke-canvas-api.md`
- Tests de lots : `specs/tests/`
