# Handoff

## Discipline doc (obligatoire à chaque intervention)
- Après toute intervention sur un repo : mettre à jour `canon/repos/<repo>/TASKS.md` (update-not-append si tâche existante, sauf nouvelle tâche distincte).
- Si changement fonctionnel (flux/actions inter-repos, endpoints, env vars/fallbacks, idempotence/event_id, jalons logs info, writes DB) : mettre à jour `canon/repos/<repo>/README.md`.
- Si changement de structure doc / liens : ne pas éditer `SITEMAP.md` ni `canon/**/INDEX.md` à la main → passer par `npm run docs:sitemap`.

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
**Agent-first indexes (06 fév 2026)**  
- Générateur `gen-sitemap.mjs` produit aussi `SITEMAP.txt` (1 URL/ligne, raw-only) et `SITEMAP.ndjson` (kind/title/url).  
- START.md oriente d’abord vers `SITEMAP.txt` puis vers `SITEMAP.md` (vue humaine).  
- CI publish bloque si SITEMAP.txt ≤50 lignes, si une URL contient `...`, ou si SITEMAP.txt/ndjson contient une URL hors `raw.githubusercontent.com`.
**SITEMAP/INDEX guardrails (06 fév 2026)**  
- Générateur `scripts/gen-sitemap.mjs` bloque toute URL contenant `...` (regex URL + garde SITEMAP) et les liens mdLink sont validés.  
- CI `publish-docs` ajoute un check sur SITEMAP/INDEX pour refuser les URLs tronquées (`...`).  
- Entrypoint public ajouté : `START.md` (raw complet) → `SITEMAP.md` → carte repo → manifest/doc ciblée (liens raw only).
**WS Bingo logs role enrichment (06 fév 2026)**  
- `ws/logger.js` ajoute `deriveRole` (priorité ctx.role > client.wsRole > ws.wsRole > endpoint hint > `server`) + wrapper `logV1` qui injecte toujours `v/ts/src/game/sid/role`; compteur DEBUG `ROLE_AUDIT` suit les entrées sans role avant enrichissement.  
- `ws/websocket_server.js` utilise `logV1`; logs WS info|warn|error portent désormais `role` (fallback `server`) sans refactor global.
**Bingo phase_winner persistence (05 fév 2026)**  
- Schéma: ajout `bingo_phase_winners` (UNIQUE `event_id` + `(session_id, phase)`) et dénormalisation `bingo_players` (`phase_wins_count`, `last_won_phase`, `last_won_at`). Docs mises à jour (`DDL.sql`, `_sources`, `OVERVIEW`, `MAP`).  
- Canvas API: `bingo_api_phase_winner` transactionnel avec idempotence `event_id`, verrou session + conflit interplayer, update playlist phase_courante + incrément `bingo_players`, logs `PHASE_WINNER_*`.  
- Checklist tests ajoutée dans `canon/data/bingo-write-map.md` (insert / replay / conflit).
**Doc discipline + DB schema (05 fév 2026)**  
- Discipline repo-first ajoutée : chaque action → `canon/repos/<repo>/TASKS.md` (update-not-append), changement fonctionnel → `canon/repos/<repo>/README.md`; règles diffusées dans README racine, `DOCS_MANIFEST.md`, READMEs `canon/repos/games` et `canon/repos/bingo.game`.  
- Schéma DB global publié (structure only) : `canon/data/schema/DDL.sql` (+ `_sources/dev_cotton_global_0.sql`, `OVERVIEW.md`, `MAP.md`), indexé dans SITEMAP/INDEX, aucun VIEW/TRIGGER/PROC/FUNC détecté, colonnes token/password signalées en notes sécurité.
**SITEMAP entrypoint renforcé (05 fév 2026)**  
- Générateur `scripts/gen-sitemap.mjs` ajoute un bloc “Start here” en tête : lien vers README général (entrypoint obligatoire avant `canon/repos/*`), régénéré avec SHA unique.
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
**Bus audit outil (03 fév 2026)**  
- Ajout `tools/audit_bus_events.js` (scan `games/web/**` excl. `.git/node_modules/dist`, ext js/ts/mjs/cjs/jsx/vue/php/html/htm) pour collecter `Bus.emit/on/once` et `window.Bus`.  
- Génère `docs/_generated/bus-events.json` (154 events / 502 occurrences au 03/02/2026).
**Support logs (03 fév 2026)**  
- `games/web/includes/canvas/core/logger.global.js` : hook Bus support/player/jingle events → LogEntry v1 via `emitGameEvent`, redaction profonde (URL sans query/hash, tokens/headers drop), throttling `support/playstate` (2s) et `support/loading` (1s), mapping viewer-first (INFO jalons, DEBUG bruit, ERROR anomalies).
**Support WARN (03 fév 2026)**  
- `logger.global.js` : ajoute WARN dérivés des événements support existants : `SUPPORT_START_SLOW` (loading >8s sans started par sid+token) et `SUPPORT_REBUFFER_EARLY` (playstate=false dans les 5s après start), dédupliqués par session/token, sans bruit INFO supplémentaire.
**Init timeline (03 fév 2026)**  
- `logger.global.js` : jalons Bus pour init organizer/player/remote + WS: SESSION_INIT/WS_LIVE (timer WS_NO_REPLY 8s), PLAYER_REGISTERED/READY, REMOTE_REGISTERED/SESSION_INFOS/READY, remote interaction warn (cooldown 10s), remote state/upcoming/videoMeta debug dédupe; dédup jalons 2s par sid.
**Session en cours + pipeline (03 fév 2026)**  
- `logger.global.js` : ajoute jalons Bus viewer-first pour la session en cours (GAME_STARTED, UI_START_SUPPORT, BINGO_PHASE) et alertes pipeline (WS_SEND_FAIL, EMIT_WITHOUT_SESSION_INIT, REMOTE_DISCONNECTED) avec cooldowns et redaction existante.
**Fin de session (03 fév 2026)**  
- `logger.global.js` : instrumentation fin de session (WS_DISCONNECTED warn via ws:close/status, SESSION_END reasoned once/sid, pagehide/beforeunload hooks), flush logs jalons (start/debug, flushed/info, fail/warn), cooldowns anti-spam.
**Session summary (03 fév 2026)**  
- `logger.global.js` : ajoute `SESSION_SUMMARY` (debug, 1x/sid) émis lors de `SESSION_END`, avec compteurs/flags (levels, supports, ws, roles, remote, flush, bingo), sans métadonnées sensibles.
**API wrapper Bus (03 fév 2026)**  
- Ajout `games/web/includes/canvas/core/api/api_client.js` : wrapper unique `apiCall()` (timeout, AbortController) qui émet `api/call|ok|fail` sur Bus (URL sans query/hash, headers non loggés, body/response shape et bytes seulement), calcule latency_ms, gère erreurs `timeout|network|http|parse|business`.
**UI → Bus + apiCall (03 fév 2026)**  
- `games/web/includes/canvas/play/play-ui.js` : remplace `Logger UI_*` par `Bus.emit ui/...`, passe les appels API bingo (hydrate, sync, deactivate) via `apiCall` (ctx role=player) et ajoute Bus instrumentation (`ui/bingo:grid_hydrate:start`, quit events), supprime logs bruit et redirige erreurs vers `ui/error/exception`.
**Logger Bus UI/API (03 fév 2026)**  
- `logger.global.js` : mappe les nouveaux événements Bus UI/api (`ui/quit:*`, `ui/answer:select`, `ui/bingo:verify`, `api/call|ok|fail`) vers LogEntry v1 (debug/info/warn) avec dedup/cooldown et meta redaction.
**Register Bus/apiCall (03 fév 2026)**  
- `games/web/includes/canvas/play/register.js` : utilise `apiCall` (Bus `api/call|ok|fail`) pour les appels register, supprime les logs `API_CALL_*`, émet quelques événements `ui/register:*` (boot/submit/start/success) et remplace le cache sessionPrimaryId par un Bus `cache/set`.
**Register Bus-first (04 fév 2026)**  
- `games/web/includes/canvas/play/register.js` : suppression complète des `LoggerV1` restants (ws probe, auto-register GM/player, grid assign, gate status, UI state) au profit de `Bus.emit` catégories `ws/probe:*`, `register/autoreg:*`, `ui/register:state` (debug/warn levels gérés côté logger.global).
**Logger Bus register/ws (04 fév 2026)**  
- `logger.global.js` : ajoute la prise en charge des nouveaux events Bus register/ws (`ws/probe:*`, `register/autoreg:*`, `ui/register:state`) avec dedup/cooldown (debug/warn) et redaction meta.
**Remote apiCall (04 fév 2026)**  
- `games/web/includes/canvas/remote/remote-ui.js` : remplace les fetch API par `apiCall` (Bus `api/call|ok|fail`) pour `remoteApi` et `grid_lines`, conserve payloads et ajoute ctx role=remote.
**Imports relatifs apiCall (04 fév 2026)**  
- `play/play-ui.js`, `remote/remote-ui.js` : import `apiCall` via chemins relatifs (`../core/api/api_client.js`) pour éviter les erreurs de résolution navigateur.
**Export logs JSONL (04 fév 2026)**  
- `web/includes/canvas/php/logs_proxy.php` : mode `export=1&format=jsonl` (ou `export=1`) qui streame toutes les pages `/logs` en NDJSON (5000/page) sans buffer mémoire, entête download `logs_session_<sid>.jsonl`, erreurs tardives signalées par ligne `_export_error` ; comportement viewer existant inchangé.
**Viewer logs pagination (04 fév 2026)**  
- `web/logs_session.html` : conservation pagination/limit, tri récent→ancien, UI revue (niveau avec sémantique info=info+warn+error, debug=all), bouton export JSONL visibles (icône), affichage jeu + récap total/levels/visibles.
**Export ALL (04 fév 2026)**  
- `web/logs_session.html` : bouton export ALL (stream JSONL via `logs_proxy.php?export=1&format=jsonl`) utilisant jeu détecté + sid, message de statut “Téléchargement de tous les logs (JSONL)…”, export visibles conservé.
**Stats proxy (04 fév 2026)**  
- `web/includes/canvas/php/logs_proxy.php` : param `stats=1` retourne `{ok, sid, game, total, by_level, pages, per_page, computed_at}` en comptant toutes les pages `/logs` (5000/page) sans stocker les entrées; niveaux détectés via `level|lvl|normalized.effectiveLevel`; cache 60s (APCu sinon `/tmp`). Erreurs page1/mi-parcours → 502 avec meta `page`.
**Viewer recap via stats (04 fév 2026)**  
- `web/logs_session.html` : le bouton Charger appelle d’abord `logs_proxy.php?stats=1` pour remplir le récap global (total + by_level par stats, jeu détecté), puis charge la page paginée; pastilles debug/info/warn/error sont cliquables et fixent le filtre niveau (page=1); visibles reste le compteur filtré actuel.
**Level fast-path pagination (04 fév 2026)**  
- `web/logs_session.html` : si le niveau choisi (warn/error ou info aggregée ou debug) a <500 logs selon stats, force limit=500 et page=1 et pagination se masque naturellement; sinon pagination inchangée.
**Proxy warn/error filtre (04 fév 2026)**  
- `web/includes/canvas/php/logs_proxy.php` : `level=warn|error` (ou `level_mode`) filtre côté proxy si l’amont ne supporte pas, en parcourant les pages (5000/page) et ne gardant que les entrées du niveau demandé pour remplir `limit`; retourne `ok, entries, total_filtered, total_all (si cache stats), pages, page`. Compatibilité conservée pour les autres requêtes et export/stats.
**Proxy level pagination (04 fév 2026)**  
- `web/includes/canvas/php/logs_proxy.php` : `level=debug|info|warn|error` applique un filtrage serveur avec pagination sur l’ensemble filtré (semantique viewer: debug=all, info=info+warn+error, warn=warn, error=error), scan pages amont 5000/page avec cap 2000 pages, renvoie `pages_filtered/total_filtered/limit/page/entries` ; fallback passthrough si niveau absent.
**Viewer level server-filter (04 fév 2026)**  
- `web/logs_session.html` : lorsque le niveau est choisi (select ou pastille), l’appel passe `level=` au proxy (filtrage serveur); pagination utilise `pages_filtered/total_filtered` et si total<500 force limit=500 page=1 pour récupérer tout le niveau en une page; recherche texte reste côté client.
**Viewer UI simplifiée (04 fév 2026)**  
- `web/logs_session.html` : suppression des champs limite/page/niveau et de la ligne de statut; pagination conservée via boutons + label Page X/Y; contrôles restants: Session ID, recherche texte, Charger, Forcer flush, exports.
**Recap filtres stricts (04 fév 2026)**  
- `web/logs_session.html` : pastilles recap total/debug/info/warn/error cliquables; total enlève le filtre serveur, les autres appliquent `level=` strict côté proxy, page reset à 1; chip active signalée; nombres recap = stats strictes; visibles = lignes affichées après filtre texte.
**Pagination mono-page si <500 (04 fév 2026)**  
- `web/logs_session.html` : règle <500 appliquée aux pastilles strictes (debug/info/warn/error) : limit fixé à 500, page=1, pagination désactivée quand stats niveau <500; total conserve pagination standard via pages_filtered/total.
**Export boutons tooltips (04 fév 2026)**  
- `web/logs_session.html` : boutons export icône only, tooltips clarifiés “Exporter les logs visibles (JSONL)” et “Exporter tous les logs (stream JSONL)” (appel export=1&format=jsonl).
**Chips colorées (04 fév 2026)**  
- `web/logs_session.html` : fond léger coloré pour les chips recap (total bleu, info vert, warn orange, error rouge) pour lisibilité.
**Chips colorées (fix) (04 fév 2026)**  
- `web/logs_session.html` : couleurs appliquées via sélecteur `.recap .chip-*` pour surclasser le fond par défaut et afficher correctement les teintes.
**Chips hover (04 fév 2026)**  
- `web/logs_session.html` : effet hover sur les chips (légère translation + ombre + bord accent) pour un feedback bouton.
**Chips pointer (04 fév 2026)**  
- `web/logs_session.html` : curseur pointer sur les chips cliquables.
**Game label non-clickable (04 fév 2026)**  
- `web/logs_session.html` : `gameLabel` reste non interactif (cursor défaut, pointer-events none).
**Visible chip non-clickable (04 fév 2026)**  
- `web/logs_session.html` : pastille `recap-visible` rendue non interactive (cursor défaut, pointer-events none).
**Timeline inline (04 fév 2026)**  
- `web/logs_session.html` : insertion de jalons frontend (src=GAMES, lvl=info) directement dans le tableau (ordre DESC) : En attente, Start de la partie, Nouveau contenu (# round/question), Phase gagnée (bingo), Fin de partie. Milestones alignés sur les logs anchors, rendu bandeau coloré, pas d’appel serveur additionnel (données de la page courante uniquement).
**Timeline inline règles précises (05 fév 2026)**  
- `web/logs_session.html` : jalons basés sur GAMES info avec règles corrigées : index round sans +1 (item_index brut), “En attente” inséré après le 1er log visible, “Start de la partie” inséré après le round #1 (ou 1er log si absent), round/phase/end insérés avant leur log ancre; classes milestone-row--{waiting|round|start|phase|end}, bandeau coloré.
**Timeline fix (05 fév 2026)**  
- `web/logs_session.html` : correction affichage “undefined” des logs (renderLogs gère items type=log/milestone; log entries récupérées via item.entry).
**Timeline attente anchor (05 fév 2026)**  
- `web/logs_session.html` : jalon “En attente” ancré après le premier `SESSION_STATUS` GAMES info dont gameStatus contient “attente” (sinon après le 1er log).
**Timeline attente stricte (05 fév 2026)**  
- `web/logs_session.html` : jalon “En attente” uniquement si un `SESSION_STATUS` GAMES info avec gameStatus contenant “attente” est présent (plus de fallback sur le 1er log).
**Timeline fin stricte (05 fév 2026)**  
- `web/logs_session.html` : jalon “Fin de partie” uniquement si un `SESSION_STATUS` GAMES info contient “termin” (plus de fallback sur le dernier log).
**Timeline start stricte (05 fév 2026)**  
- `web/logs_session.html` : “Start de la partie” uniquement si un `GAME_ROUND_STARTED` avec `item_index=0` est présent (plus de fallback).
**Filtre Source (05 fév 2026)**  
- `web/logs_session.html` : sélecteur Source (Tous/Front/WS), filtrage par src.endsWith('_WS'); timeline désactivée en mode WS; préférence persistée en localStorage.
**Timeline pause/reprise (05 fév 2026)**  
- `web/logs_session.html` : jalons supplémentaires pour `SESSION_STATUS` GAMES info : `gameStatus` contenant “pause” → “Jeu en pause”, contenant “en cours”/“reprise” → “Reprise du jeu” (insertion avant le log ancre, sans fallback).
**Timeline pause/reprise condition (05 fév 2026)**  
- `web/logs_session.html` : “Reprise du jeu” seulement si `gameStatus` contient “en cours”/“reprise” ET `previousStatus` contenait “pause” (évite faux positifs démarrage). Pause inchangée.
**Timeline pause/reprise sans dédup (05 fév 2026)**  
- `web/logs_session.html` : suppression du dédoublonnage pause/reprise pour que le jalon apparaisse même si plusieurs statuts similaires figurent dans la page filtrée.
**Player/jingle unready sélectif (05 fév 2026)**  
- `web/includes/canvas/core/player/index.js` : les erreurs YT/prepare émettent `player/unready` uniquement pour un support non-jingle, et `jingle/unready` uniquement pour un jingle (détection via playlist currentIndex).
<!-- AUTO-UPDATE:END id="handoff-status" -->

<!-- AUTO-UPDATE:BEGIN id="handoff-next-steps" owner="codex" -->
## Next steps (auto checklist)
- [ ] Vérifier que `SITEMAP.txt` et `SITEMAP.ndjson` sont bien publiés (raw) et restent >50 lignes après regen côté public.
- [ ] Vérifier `START.md` rendu public: liens raw complets, navigation START → SITEMAP → carte repo → manifest/doc ciblée fonctionne pour bingo.game.
- [ ] Validation terrain : 1 session par jeu (Bingo/Quiz/Blindtest) et capture JSONL via `logs_session.html` montrant `API_CALL_ATTEMPT/RESULT/ERROR` (writes → `event_id`, `already_processed` si replay) ; vérifier que les nouvelles lignes RESULT ko sont en INFO et les succès en DEBUG.
- [ ] Vérifier que les logs legacy réseau apparaissent encore mais en DEBUG (`LEGACY_API_NOTE` / `legacy_api=1`) et que le viewer les masque par défaut.
- [ ] Vérifier côté front que `LOG_BUFFER_LEVEL=info` n’empêche pas les `API_CALL_*` d’être présents dans `log_batch` (bufferEntries) et dans les exports viewer min_level=debug.
- [ ] Jouer une session (Quiz/Bingo/BT), relancer le cron, vérifier que `reporting_games_sessions_detail` reflète la fenêtre M-1/M et que la somme des lignes = sessions affichées (y compris filtres jeu/client) + ouverture `logs_session.html` via le bouton Logs.
- [ ] Session Bingo dev : vérifier export JSONL viewer → aucune ligne info|warn|error sans `role` (compteur DEBUG `ROLE_AUDIT` reste à 0 après enrichissement).
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
- Les gardes CI (raw-only, anti-ellipsis, lignes minimales) bloqueront la publication si de nouveaux scripts produisent des URLs vues/github.com dans SITEMAP.txt/ndjson : surveiller après ajouts.
- Alerte CI/guard si un outil ou un éditeur tronque des URLs en `...` dans SITEMAP/INDEX (bloquant publish) : surveiller après regen.
- Bruit heartbeat (BT/Quiz) et remote_missing (Bingo) toujours volumineux → coût lecture `/logs`, pagination potentiellement lente.  
- Lignes texte legacy Quiz toujours présentes dans `server-logs.log` (non comptées dans `invalid`) → possible perte d’info timeline.  
- Request_id auto front généré séquentiel, pas encore corrélé aux actions utilisateur (corrélation limitée).  
- Proxy ne valide pas le JSON → en cas de fichier corrompu, le viewer peut encore échouer (500 WS ou parse error côté client).
<!-- AUTO-UPDATE:END id="handoff-risks" -->

## Validation (humain)
- Smoke test Canvas API : `specs/smoke-canvas-api.md`
- Tests de lots : `specs/tests/`
