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
**Front logs INFO audit (31 jan 2026)**  
- Rapport transféré dans `notes/audit-front-logs-info.md` (games front) : cartographie INFO vs WARN/DEBUG, patterns bruyants, dédoublonnage et règles Meta (op/target/role/state/phase*/client_id/player_id/grid_id/question_index/songIndex/completedLines/progress, exclusion session_id). Sert de guide pour réduire le bruit INFO et harmoniser Meta côté viewer/front.  
**Logs viewer meta + WS context (31 jan 2026)**  
- Viewer `games/web/logs_session.html`: meta builder now prioritizes business keys (op/wsType/target/role/state/gameStatus/phase*/client_id/player_id/grid_id/question_index/songIndex/completedLines/progress), keeps env/debug_on for GAMES data, caps to ~8 pairs, and scrubs `session_id`/`sessionId` even inside debug payloads.  
- WS messaging (blindtest/quiz `web/server/messaging.js`, bingo `ws/bingo_server.js`): frequent WS info logs now carry a flat `meta` object (op/wsType/target/state/gameStatus/phase*/client_id/player_id/etc., no session_id); bingo join logs tag `op:"join"`. Aids Meta column without altering existing payloads.  
- Impact: WS session_update/state/join lines now surface op/target/state/client_id in Meta; session_id never displayed (even debug transport).  
**API_CALL logging wrappers instrumented (28 jan 2026)**  
- Wrappers (front): `__canvasCall` (organizer), `remoteApi` (remote UI), `api` (player UI), bingo `grid_cells_sync` fetch → emit `API_CALL_ATTEMPT/RESULT/ERROR` with `request_id`, `api_action`, `http_status`, `latency_ms`, `already_processed` when present.  
- Wrappers (WS): `canvasWrite` in `bingo.game/ws/envUtils.js`, `quiz/web/server/actions/envUtils.js`, `blindtest/web/server/actions/envUtils.js` instrumented similarly; `event_id` preserved for idempotent writes.  
- Legacy network success logs downgraded to DEBUG with `event:"LEGACY_API_NOTE"` + `legacy_api=1` (Bingo reset/session_update/end_game/phase_winner; Quiz/Blindtest persistScore/persistPodium).  
- Viewer: `games/web/assets/logs/actions-map.json` maps `API_CALL_*` + `LEGACY_API_NOTE` (debug default).  
- Docs updated: `canon/interfaces/actions.md` (API_CALL spec), `notes/logging-api-callers-audit.md` (patch applied). 
- Transport front→WS: `logger.global.js` lifts `event`/`api_action`/`request_id` to root and always buffers `API_CALL_*`/`LEGACY_API_NOTE` even if `LOG_BUFFER_LEVEL=info`, so debug API calls reach `log_batch` exports.  
- Viewer meta fallback: `logs_session.html` now reconstructs meta when `__view.meta` is empty (API_CALL_* → api_action/req/http/latency/ok; legacy_api → note; otherwise generic fields), preventing blank meta cells. Evidence: `games/web/logs_session.html` (helpers pickField/buildMetaFallback/metaToText).  
**Canvas API callers audit (28 jan 2026)**  
- Livrables : inventaire des wrappers Canvas front/WS + points de patch recommandés + doc mise à jour (`canon/interfaces/actions.md`, `notes/logging-api-callers-audit.md`).  
- Best patch points : front `__canvasCall` (organizer), `remoteApi` (remote UI), `api` (player UI), bingo `grid_cells_sync` fetch; WS wrappers `canvasWrite` (bingo/quiz/blindtest envUtils) qui injectent déjà `event_id`.  
- Evidences : voir `notes/logging-api-callers-audit.md` (paths+lines) et tables “API callers” / “Logging patch plan” dans `canon/interfaces/actions.md`.
**Games log proxy/viewer simplification (28 jan 2026)**  
- Fichiers : `games/web/includes/canvas/php/logs_proxy.php`, `games/web/logs_session.html`, `games/web/assets/logs/actions-map.json`.  
- Modifs : proxy sert une sortie JSON stable (`logs[]/entries[]` triées ts asc) avec normalisation `session_id`, filtrage min_level+recherche texte, méta détaillée (`page_count`, `raw_counts`, `effective_counts`, `invalid_skipped`, upstream). Plus d’action map côté proxy ni `level_mode`. Viewer consomme le nouveau schéma (meta/page_count/invalid), supprime `level_mode`, conserve la classification via action-map. Action-map mise à jour : `loadingSupport` debug confirmé, `playerReady` debug, `SUPPORT_START` info, `WS_IN/WS_OUT` debug, `JOIN_ERROR` warn inchangé.  
- Tests attendus : `/web/includes/canvas/php/logs_proxy.php?game=bingo&sessionId=...&min_level=info` renvoie une page triée asc avec `meta.page_count>=1`; `search=` filtre dans message/source/event/meta. Viewer `/web/logs_session.html` charge une session (min_level=info) et affiche timeline INFO/WARN/ERROR; min_level=debug montre WS transport/front debug; export JSONL toujours dispo.  
**Games logs viewer reset minimal (28 jan 2026)**  
- Fichier : `games/web/logs_session.html`.  
- Modifs : UI réduite (session_id + min_level + bouton Charger, pas de pagination/flush/recherche/export). Chargement unique page=1 limit=500 via `logs_proxy.php`, tri ts asc, pas de level_mode/dedup. Header affiche range_ts min→max, pages_loaded/page_count, total, raw/eff counts, invalid_skipped. Action-map conservée pour la classification mais fallback brut si indispo. Export supprimé.  
- Tests attendus : min_level=info → timeline métier visible ou range_ts indique que le début manque ; min_level=debug → transport/legacy visibles si présents sur la plage ; header explicite pages 1/X + range_ts ; aucune UI fantôme.  
**Logs proxy validation mode (28 jan 2026)**  
- Fichier : `games/web/includes/canvas/php/logs_proxy.php`.  
- Modifs : si upstream.pages ≤10 et upstream.total ≤5000, le proxy fetch toutes les pages upstream (1..N), fusionne, trie ts asc, applique uniquement min_level + search, et renvoie tout en une réponse (page_count=1) avec diagnostics `range_ts_raw/effective`, `pages_loaded=N`, `raw_total` complet. Si upstream.pages>10 ou total>5000, fallback sur le comportement actuel (1 page) tout en exposant upstream.* pour transparence.  
- Tests attendus : session Bingo de repro → meta.pages_loaded=3, raw_total ≈1357, range_ts_raw min affiche le début (FRONT_BOOT/JOIN) sans changer le viewer.  
**Logs proxy meta honnête (28 jan 2026)**  
- Fichier : `games/web/includes/canvas/php/logs_proxy.php`.  
- Modifs : la meta expose aussi `upstream_pages`, `upstream_total`, `upstream_page_first_fetch` pour refléter le découpage réel même quand on renvoie une seule page (page_count=1). Le bloc upstream est conservé.  
- Effet : lecture directe des meta permet de savoir qu’il existe plusieurs pages upstream sans dépendre du viewer.  
**Logs proxy transparent (28 jan 2026)**  
- Fichier : `games/web/includes/canvas/php/logs_proxy.php`.  
- Modifs : proxy désormais transport-only : fetch/merge/sort/paginate + filtres min_level/search + stats meta. Aucune réécriture d’entry (plus de meta fabriquée ni payload déplacé). Ajouts tolérés : `ts_num` si absent, `ts` ISO si manquant, `session_id` ajouté depuis `sessionId` (idem data[0]). Pas de suppression de `sessionId`. Counts/invalid/page meta inchangés, upstream mirroring conservé.  
- Effet : les entries INFO/DEBUG arrivent intactes (data/payload/meta préservés) pour le viewer; plus de `meta=keys=payload,ns,target,clientLevel` injecté; payload complet reste côté DEBUG WS message.  
**Logs viewer meta enrichie (28 jan 2026)**  
- Fichier : `games/web/logs_session.html`.  
- Modifs : Meta différenciée par niveau : INFO affiche tout contexte structuré dispo (meta/data/ctx/racine) ordonné (role/state/phase/… en priorité) jusqu’à 6 paires, DEBUG transport détecte WS message/wsType/payload et montre routing + valeurs payload scrub/cappées (8 paires max, fallback payload_keys/payload_truncated), WARN/ERROR gardent http_status/code/op/path/cause + stack_top. Exclusions strictes (structure, session_id, secrets, payload brut), anti-dup `[TAG]` sur event/action, troncs 60 chars, arrays≤10, objets keys≤8. Meta vide seulement s’il n’y a vraiment rien d’utile.  
- Effet : INFO GAMES/WS montre le contexte métier (ex UI_BINGO_VERIFY role/phase/completedLines, session_update winner_id/phase/state/duration), DEBUG “WS message” affiche payload valeurs scrubbed, plus de répétition event/tag ni de `null`.  
**Logs viewer level fidelity (28 jan 2026)**  
- Fichier : `games/web/logs_session.html`.  
- Modifs : ajout `getEffectiveLevel` (source of truth `entry.level`, fallback clientLevel) utilisé pour filtrage min_level et affichage colonne Niveau. Action-map n’override plus le badge; un log debug reste affiché comme debug.  
- Effet : les lignes “WS message” restent en debug et disparaissent en min_level=info; l’affichage du niveau correspond aux valeurs du JSON d’origine.  
**Logs viewer meta noise cut (28 jan 2026)**  
- Fichier : `games/web/logs_session.html`.  
- Modifs : exclusion stricte de `sessionId`/`session_id` des paires Meta (page mono-session), en plus des clés structurelles déjà filtrées.  
- Effet : plus de `sessionId=...` visible dans la colonne Meta; canon session_id reste disponible dans l’entry brute si nécessaire.  
**Logs viewer data obj render (28 jan 2026)**  
- Fichier : `games/web/logs_session.html`.  
- Modifs : exclut désormais la clé `data` des paires Meta (évite `data=[obj]`) tout en utilisant toujours `data[0]` comme source de contexte structuré.  
- Effet : les logs GAMES INFO (ex `[UI_BINGO_VERIFY]`) affichent directement les champs utiles de `data[0]` (role/phase/completedLines…) sans placeholder `data=[obj]`.  
**Logs viewer GAMES data preserved (28 jan 2026)**  
- Fichier : `games/web/logs_session.html`.  
- Modifs : la normalisation conserve `data` dans les entries; Meta INFO priorise désormais `data[0]` pour les sources GAMES (role/phase/completedLines…) avant le reste du contexte, avec anti-dup event et exclusions sessionId/session_id.  
- Effet : les logs GAMES INFO utilisant `data[0]` affichent leur contexte métier (ex UI_BINGO_VERIFY role/phase/completedLines) au lieu d’une Meta vide ou d’un placeholder; aucune perte de data pendant le mapping.  
**Logs viewer export back (28 jan 2026)**  
- Fichier : `games/web/logs_session.html`.  
- Modifs : bouton “Exporter JSONL” réactivé (download du jeu de logs filtrés actuel, format JSONL des entries brutes). Export désactivé si aucune entrée.  
- Effet : possibilité de récupérer facilement les logs affichés (post-filtrage) pour analyse externe.  
**Logs viewer export WYSIWYG (28 jan 2026)**  
- Fichier : `games/web/logs_session.html`.  
- Modifs : stockage du dataset affiché (`logsDisplayed` = {raw, view}) lors du rendu; export JSONL sérialise exactement ces lignes dans l’ordre visible, en incluant `__view` (ts/level/source/message/meta). Pas d’entries cachées ni réordonnées.  
- Effet : le fichier exporté correspond 1:1 aux lignes présentes dans la table après filtres/tri; vérif simple du count/ordre affiché.  
**Quiz: normalize session_update fields (27 jan 2026)**  
- Fichier : `quiz/web/server/actions/gameplay.js`.  
- Modifs : logs lifecycle `event:"session_update"` émettent uniquement `session_id` (camelCase retiré), `state` normalisé machine (lobby|playing|paused|ended) dérivé de l’ancien label/action; label humain conservé en optionnel `state_label`. Champs livrés : `session_id`, `event`, `action`, `state`, `index`, `state_label?`, `reason?`, `duration_ms?`.  
- Mapping appliqué : start/play/resume/next → playing ; pause → paused ; stop/end → ended ; défaut → lobby.  
- Tests attendus : start → play → pause → resume → next → stop → logs `state` ∈ {lobby, playing, paused, ended} sans champ `sessionId`.
**Bingo WS logging defaults (27 jan 2026)**  
- Fichiers : `bingo.game/ws/logger.js`, `bingo.game/ws/bingo_server.js`, `bingo.game/version.txt`.  
- Modifs : logger WS active DEBUG par défaut en dev (`APP_ENV=dev` ou URL .dev./localhost, ou LOG_LEVEL=debug/LOG_DEBUG=1) tout en gardant prod à INFO; logs WS_IN sans session basculés en DEBUG (traﬁc viewer-friendly); restart marker bump `restart 27-01-2026/06`.  
- Tests attendus : en dev sans variables, logs DEBUG visibles (WS_IN/OUT en debug, timeline INFO préservée) ; en prod, DEBUG inactif sauf LOG_DEBUG=1 ou LOG_LEVEL=debug ; `WS_LOG_TRAFFIC=1` force WS_IN/OUT en INFO si nécessaire.
**Bingo: viewer-first boot/transport + join client (27 jan 2026)**  
- Fichiers : `bingo.game/ws/bingo_server.js`, `bingo.game/ws/websocket_server.js`, `bingo.game/version.txt`.  
- Modifs : logs boot/connexion réseau (`server started/stopped`, `New connection`, WS server listen) downgradés en DEBUG pour nettoyer INFO; ajout jalon INFO structuré `event:"join"` pour auth client (result ok/error, session_id, client_id safe, reason si échec).  
- Tests attendus : `min_level=info` ne montre plus les messages de démarrage ni “New connection”; un log join info apparaît sur auth client ok/ko; `min_level=debug` garde boot/transport. Restart marker: `restart 27-01-2026/07`.
**Quiz/Blindtest/Bingo: session_id canon (27 jan 2026)**  
- Fichiers : `quiz|blindtest/web/server/logger_ws.js`, `bingo.game/ws/logger.js`, `quiz|blindtest/web/server/messaging.js`, `quiz|blindtest/web/server/actions/wsHandler.js`, restart markers (`quiz/web/server/restart_serveur.txt`, `blindtest/web/server/restart_serveur.txt`, `bingo.game/version.txt`).  
- Modifs : les loggers WS dérivent désormais `session_id` (depuis session_id ou sessionId) et n’émettent plus le champ camelCase `sessionId`; contexts/children alignés sur `session_id`.  
- Tests attendus : nouveaux logs (INFO/DEBUG) ne contiennent plus `sessionId`, seulement `session_id` quand dispo; WS traffic reste en DEBUG par défaut, `WS_LOG_TRAFFIC=1` reste l’override. Restart markers bump: bingo `/08`, quiz `/09`, blindtest `/10`.
**Blindtest: normalize session_update fields (27 jan 2026)**  
- Fichier : `blindtest/web/server/actions/gameplay.js`.  
- Modifs : logs lifecycle `event:"session_update"` émettent uniquement `session_id` (camelCase retiré), `state` machine (lobby|playing|paused|ended) via mapping label/action; `state_label` optionnel si label ≠ machine. Champs : `session_id`, `event`, `action`, `state`, `index`, `state_label?`, `reason?`, `duration_ms?`.  
- Mapping : start/play/resume/next → playing ; pause → paused ; stop/end → ended ; défaut → lobby.  
- Tests attendus : start → play → pause → resume → next → stop → logs `state` conformes, pas de `sessionId`.
**Bingo: session_update lifecycle logs (27 jan 2026)**  
- Fichier : `bingo.game/ws/bingo_server.js`.  
- Modifs : ajout helper `logSessionUpdateBingo` (dédup par session+action+phase), logs INFO `event:"session_update"` pour start/next/pause/resume/stop avec `session_id`, `game:"bingo"`, `action`, `state` (lobby|playing|paused|ended) + phase enrichie (state playing/paused) `phase_key` line|double_line|bingo, `phase_index`, `phase_label`, `next_phase_key/index` optionnels, `reason?`, `duration_ms?`; fallback phase=line si non résolue. Points d’émission : premier song_start (start), phase_winner (next), pause/resume organizer disconnect/reconnect, logEndGameOnce (stop).  
- Tests attendus : session démarrée → log start phase line; phase wins → next double_line puis bingo; pause/resume conservent phase; stop avant `end_game` unique; aucun spam de sync.
**Bingo: session_update scope (phase/media/state) + position debug (27 jan 2026)**  
- Fichier : `bingo.game/ws/bingo_server.js`.  
- Modifs : `session_update` porte `scope` (phase/media/state). Phases log INFO dédup par phase_index avec `phase_key|phase_index|phase_label`, `next_phase_*` optionnel; media `next` structuré (track_position/id); positions courantes passent en DEBUG (`action:"position"`). State pause/resume/stop conserve state normalisé + reason. Champs normalisés snake_case (`session_id`, `game_id`, `track_id`, `track_position`, `latency_ms`).  
- Tests attendus : min_level=info montre phases et media next sans spam position; min_level=debug affiche positions.
**Bingo: session_update dedup + legacy media logs -> debug (27 jan 2026)**  
- Fichier : `bingo.game/ws/bingo_server.js`.  
- Modifs : logs legacy media (song_start texte, current position) downgradés en debug; `session_update` émis en INFO uniquement lors d'une évolution (state/phase/media change), sinon DEBUG, avec dédup séparée par scope.  
- Tests attendus : min_level=info affiche seulement les transitions effectives; min_level=debug montre répétitions/legacy.
**Quiz/Blindtest: WS_IN -> debug + logger dev-friendly (27 jan 2026)**  
- Fichiers : `quiz/web/server/actions/wsHandler.js`, `blindtest/web/server/actions/wsHandler.js`, `quiz|blindtest/web/server/logger_ws.js`.  
- Modifs : trafic WS_IN forcé en DEBUG (plus d'INFO) pour un timeline viewer propre; logger WS considère `NODE_ENV` (dev => DEBUG_ON) et `LOG_DEBUG=1` pour écrire les logs debug; WS_OUT déjà en debug. Restart markers: quiz `restart_serveur.txt` 27-01-2026/07, blindtest 27-01-2026/08.  
- Tests attendus : min_level=info sans WS_IN/OUT; min_level=debug affiche WS_IN/OUT; en dev ou LOG_DEBUG=1 les DEBUG sont écrits.
**Quiz/Blindtest: WS traffic DEBUG par défaut (27 jan 2026)**  
- Fichiers : `quiz/web/server/messaging.js`, `quiz/web/server/actions/wsHandler.js`, `blindtest/web/server/messaging.js`, `blindtest/web/server/actions/wsHandler.js`, `quiz/web/server/restart_serveur.txt`, `blindtest/web/server/restart_serveur.txt`.  
- Modifs : logs `event:"WS_OUT"` forcés en DEBUG par défaut (option `WS_LOG_TRAFFIC=1` pour remonter en INFO), maintien du dédoublonnage existant; contexte logger passe en `session_id` uniquement (plus de doublon `sessionId`).  
- Tests attendus : `min_level=info` n'affiche plus WS_IN/OUT; `min_level=debug` les montre; avec `WS_LOG_TRAFFIC=1` les WS_IN/OUT réapparaissent en INFO. Markers restart bump: quiz `restart 27-01-2026/08`, blindtest `restart 27-01-2026/09`.
**Quiz/Blindtest: reduce countdown msg redundancy (27 jan 2026)**  
- Fichiers : `quiz/web/server/actions/gameplay.js`, `blindtest/web/server/actions/gameplay.js`.  
- Modifs : logs FR de décompte (“Début ou reprise du décompte…”, “Décompte mis en pause…”) downgradés en DEBUG (conservés via `Logger.debug?`). Les logs structurés `event:"session_update"` restent en INFO.  
- Test attendu : min_level=info → seule la ligne `session_update` apparaît sur start/pause/resume/next; min_level=debug → messages FR visibles.
**Quiz/Blindtest: legacy INFO → DEBUG (viewer clean) (27 jan 2026)**  
- Fichiers : `quiz/web/server/actions/gameplay.js`, `quiz/web/server/actions/wsHandler.js`, `blindtest/web/server/actions/gameplay.js`.  
- Modifs : logs texte legacy (reset démo, scores remis à 0, nouveau morceau détecté, session mise à jour, start signal, fin de morceau, force reveal, start/stop loadtest) passent en DEBUG via `Logger.debug?`; timeline INFO conserve uniquement les logs structurés (join/session_update/player_answer/persist/end_game…).  
- Tests attendus : min_level=info ne montre plus ces messages FR, min_level=debug les affiche.
**Quiz logs – micro-tâche #1 (débruitage WS) appliquée (31 jan 2026)**  
- WS_IN/WS_OUT rafraîchissements (checkSession/update_session_infos/initializeOrUpdateSession/updatePlayers) passent en debug avec tag `kind:"agg"` + throttling conservé; heartbeat loggué en debug uniquement.  
- Fichiers: `quiz/web/server/actions/wsHandler.js`, `quiz/web/server/messaging.js`.  
- Résultat attendu: `min_level=info` lisible en session golden (moins de spam refresh/heartbeat); `min_level=debug` montre le détail agg.  
- Prochaines micro-tâches (voir `notes/logging-quiz-raw-logs-execution-plan.md`): structurer inscriptions, réponses/scoring, END_GAME, option /logs jsonl.
**Games front timeline (27 jan 2026)**  
- Fichiers front: `games/web/includes/canvas/core/logger.global.js`, `games/web/includes/canvas/core/ws_connector.js`, `games/web/includes/canvas/play/register.js`, `games/web/assets/logs/actions-map.json`.  
- Modifs: ajout helper `Logger.timeline` + jalons front cross-game (`FRONT_BOOT`, `SESSION_INIT`, `SESSION_SET`, `SESSION_STATUS`, `FRONT_UNLOAD`) émis en INFO; `CLIENT_READY` passe en DEBUG. Player register (bingo) émet `JOIN_ATTEMPT/JOIN_OK/JOIN_ERROR` via timeline; actions-map renseigne ces jalons pour quiz/blindtest/bingo (level info sauf JOIN_ERROR warn). WS transport logs (open/close/error/WS_RECV) downgradés en DEBUG pour viewer-first.  
- Dev=debug par défaut confirmé: `logger.global` active DEBUG si env≠prod ou host .dev/localhost/.test ou param `debug=1`/`localStorage.DEBUG=1`.  
- Tests attendus: page front → log INFO `FRONT_BOOT` avec env/debug_on, `SESSION_INIT/SET/STATUS` sur bus + store change; bingo inscription → `JOIN_*` jalons en INFO/WARN; WS traffic n’apparaît plus en min_level=info (toujours en debug). 
**Bingo WS viewer-first cleanup (28 jan 2026)**  
- Fichiers: `bingo.game/ws/bingo_server.js`.  
- Modifs: dédup warn “Aucun remote actif” avec code `NO_REMOTE_ACTIVE` (1 warn/30s par game, duplicatas en debug); logs join enrichis (result ok/error) pour player, player_paper, client, remote avec auth failures en WARN; remote join success/fail structurés; WS transport reste DEBUG par défaut; boot/connection messages déjà en DEBUG.  
- Tests attendus: min_level=info montre join success/failure + jalons métier sans spam remote warn; min_level=debug conserve le détail (dup warn en debug).  
**Bingo WS auth/media scrub (28 jan 2026)**  
- Fichiers: `bingo.game/ws/bingo_server.js`.  
- Modifs: logs auth legacy (“Client/Player/Remote authenticated”) downgradés en DEBUG (jalon canon = event:join en INFO/WARN). Logs media temp song_start passent en DEBUG (tag debug_temp). WS payload compaction nettoie les tokens (tokenPresent bool) pour checkSession/auth*, fallback scrub sur payload par défaut; checkSession response remplace token par tokenPresent. session_update(state) garde INFO seulement sur évolution (dédup inchangée). mainPlayerStarted laissé intact (explicitement exclu).  
- Tests attendus: min_level=info sans logs auth verbose ni song_start temp; tokens absents des payloads (tokenPresent uniquement); session_update state uniquement quand changement.  
**Games front loading/playerReady noise (28 jan 2026)**  
- Fichiers: `games/web/includes/canvas/core/player/index.js`, `games/web/includes/canvas/core/boot_organizer.js`, `games/web/assets/logs/actions-map.json`.  
- Modifs: `[loadingSupport]` basculé en DEBUG avec dédup (log uniquement si on/reason/index change); actions-map classe loadingSupport en DEBUG. `[playerReady]` passe en DEBUG + dédup (log seulement si playerReady change) et token masqué via tokenPresent bool. SUPPORT_START resté INFO.  
- Tests attendus: min_level=info → plus de bruit loadingSupport/playerReady; min_level=debug → logs rares (uniquement changements).  
**Games front ws_connector cleanup (28 jan 2026)**  
- Fichiers: `games/web/includes/canvas/core/ws_connector.js`.  
- Modifs: transport WS forcé en DEBUG (open/ack/close/error/WS_RECV/auth send logs downgradés + tokens masqués); ajout jalons timeline front `JOIN_ATTEMPT` (1x), `JOIN_OK` (open/ack) et `JOIN_ERROR` (close/error sans OK) avec payload minimal {session_id, role, game, code?}; dédup via flags par instance; session_id uniquement (pas de sessionId). Dev default DEBUG inchangé (via logger.global).  
- Tests attendus: front quiz/bt/bingo → min_level=info montre FRONT_BOOT/SESSION_* + JOIN_* sans traces transport ni tokens; min_level=debug conserve transport mais tokens redacted/omitted.  
**Quiz: player_answer log structuré (31 jan 2026)**  
- Fichier : `quiz/web/server/actions/gameplay.js`.  
- Modifs : log réponse joueur devenu structuré (info) avec `event:"player_answer"`, `player_id`, `is_correct`, `points_awarded`, `score_total`, `song_index`, `question_id`, `answer_choice`; message court.  
- Test attendu : session avec 2 joueurs → en `min_level=info`, un log par réponse avec player_id + is_correct + points; pas de données sensibles.
**Quiz: join/registration logs structurés (31 jan 2026)**  
- Fichier : `quiz/web/server/actions/registration.js`.  
- Modifs : helper `logJoin` + logs join_success/failure structurés (`event:"join"`, `role`, `session_id`, `player_id`/`client_id`, reason/code pour échecs) pour primary, secondary, player; limite atteinte et session inexistante journalisées.  
- Tests : session avec primary + secondary + joueurs; en `min_level=info`, les joins montrent role + IDs; échec session inexistante/pleine en warn.
**Quiz: end_game summary log (31 jan 2026)**  
- Fichier : `quiz/web/server/actions/gameplay.js`.  
- Modifs : log unique info `event:"end_game"` (flag in-memory) avec `session_id`, `reason="normal_end"`, `final_state="finished"`, `total_players`, `connected_players_at_end`, `playlist_name`, `song_index`, `total_songs`; message court `end_game`.  
- Tests : fin de partie normale → un seul log end_game; fin rejouée/reconnectée ne duplique pas le log.
**Quiz: session_update lifecycle logs (27 jan 2026)**  
- Fichiers : `quiz/web/server/actions/gameplay.js`.  
- Modifs : logs INFO structurés `event:"session_update"` pour transitions start/play/pause/resume/next/stop (champs `session_id`, `action`, `state`, `index`, `reason` optionnel) avec dédup par session+action+index; log `next` sur changement de morceau, `pause`/`resume` selon statut, `stop` sur fin de partie.  
- Tests : session test start → pause → resume → next → end_game ; en `min_level=info`, une ligne `session_update` par transition sans spam; en debug inchangé.
**Quiz: persistScore success log structuré (31 jan 2026)**  
- Fichier : `quiz/web/server/actions/gameplay.js`.  
- Modifs : log info `event:"persistScore"` après succès Canvas avec `session_id`, `session_primary_id`, `player_id`, `score_total`, `changed`, `song_index`, `question_id`, `duration_ms`; message court “persistScore ok”.  
- Test attendu : session avec réponses → un log “persistScore ok” corrélé aux réponses; les erreurs restent logguées (`persistScore: API error`).
**Blindtest: débruitage heartbeat + WS traffic (31 jan 2026)**  
- Fichiers : `blindtest/web/server/actions/wsHandler.js`, `blindtest/web/server/messaging.js`.  
- Modifs : WS_IN/WS_OUT passent en debug par défaut (info seulement si `WS_LOG_TRAFFIC=1`), heartbeat logué en debug; throttle existant conservé.  
- Tests : session blindtest “golden” → `min_level=info` lisible sans spam heartbeat/WS; en set `WS_LOG_TRAFFIC=1`, WS_IN/OUT réapparaissent en info pour troubleshooting.
**Blindtest: player_answer log structuré (31 jan 2026)**  
- Fichier : `blindtest/web/server/actions/gameplay.js`.  
- Modifs : log info `event:"player_answer"` par réponse avec `session_id`, `player_id`, `is_correct`, `points_awarded`, `score_total`, `song_index`, `question_id`; message court `player_answer`. Aucun changement de scoring.  
- Tests : session avec réponses correctes/incorrectes → un log par réponse en min_level=info avec player_id/is_correct/points.
**Blindtest: persistScore success log structuré (31 jan 2026)**  
- Fichier : `blindtest/web/server/actions/gameplay.js`.  
- Modifs : log info `event:"persistScore"` après succès Canvas avec `session_id`, `session_primary_id`, `player_id`, `score_total`, `changed`, `song_index`, `question_id`, `duration_ms`; message court “persistScore ok”. Erreurs existantes conservées.  
- Tests : session avec scoring → un log persistScore ok corrélé aux réponses; forcer une erreur Canvas continue de logguer `persistScore: API error`.
**Blindtest: end_game summary log (31 jan 2026)**  
- Fichier : `blindtest/web/server/actions/gameplay.js`.  
- Modifs : log unique info `event:"end_game"` (flag in-memory) avec `session_id`, `reason="normal_end"`, `final_state="finished"`, `total_players`, `connected_players_at_end`, `playlist_name`, `song_index`, `total_songs`; message court `end_game`.  
- Tests : fin de partie → un seul log end_game; rerun/reconnect ne duplique pas le log.
**Blindtest: session_update lifecycle logs (27 jan 2026)**  
- Fichiers : `blindtest/web/server/actions/gameplay.js`, `blindtest/web/server/restart_serveur.txt`.  
- Modifs : logs INFO structurés `event:"session_update"` pour les transitions start/play/pause/resume/next/stop (champs `session_id`, `action`, `state`, `index`, `reason` optionnel) avec dédup par session+action+index; log `next` sur changement de morceau, `pause`/`resume` sur changement de statut, `stop` sur fin de partie.  
- Tests : session test start → pause → resume → next → end_game ; en `min_level=info`, une ligne `session_update` par transition sans spam; en debug inchangé.
**Blindtest: join/registration logs structurés (31 jan 2026)**  
- Fichier : `blindtest/web/server/actions/registration.js`.  
- Modifs : helper `logJoin` + logs join_success/failure structurés (`event:"join"`, `role`, `session_id`, `player_id`/`client_id`, reason/code sur échecs) pour primary/secondary/player; session inconnue et limite atteinte journalisées.  
- Tests : session avec primary + secondary + joueurs; en `min_level=info` les joins montrent role + IDs; échec session inexistante/pleine en warn.
**Bingo: débruitage WS traffic + heartbeat (31 jan 2026)**  
- Fichiers : `bingo.game/ws/bingo_server.js`, `bingo.game/ws/websocket_server.js`.  
- Modifs : WS_IN/WS_OUT passent en debug par défaut (info si `WS_LOG_TRAFFIC=1`), heartbeat terminate passe en warn. Pas d’impact sur les logs métier.  
- Tests : session Bingo en `min_level=info` → trafic générique/heartbeat absent; en debug ou avec `WS_LOG_TRAFFIC=1`, trafic visible pour troubleshooting.
**Bingo: verification/winner/persist logs structurés (31 jan 2026)**  
- Fichiers : `bingo.game/ws/bingo_server.js`, `bingo.game/version.txt` (restart marker).  
- Modifs : logs INFO structurés `verification` (outcome winner/not_winner + session_id/player_id/phase/duration_ms), `persist` phase_winner ok (session_id/player_id/phase/next_phase/changed/duration_ms/event_id), `notify_remote` phase_winner (sent). Log de requête verification initial passé en debug.  
- Tests : session avec vérif non gagnante puis gagnante → timeline min_level=info montre verification not_winner, verification winner, persist phase_winner ok (optionnel notify_remote); errors existantes inchangées.
**Bingo: end_game résumé unique + dédup (27 jan 2026)**  
- Fichiers : `bingo.game/ws/bingo_server.js`, `bingo.game/version.txt` (restart marker).  
- Modifs : log INFO structuré unique `event:"end_game"` avec `session_id`/`sessionId`, `game_id`, `reason`, `players_count`, `phase_index|phase_count` si fournis, `duration_ms`, `winner_player_id|winners_count` si disponibles; dédup in-memory par session. Déclenché sur `quitGame` volontaire, message WS `end_game` (Canvas write), et timeout de reconnexion organisateur.  
- Tests : session Bingo complète + arrêt admin/timeout → en `min_level=info` une seule ligne `event:"end_game"` par session; trafic debug conservé via `WS_LOG_TRAFFIC=1` si besoin.
**Bingo: PlayerFail throttling débruité (27 jan 2026)**  
- Fichiers : `bingo.game/ws/bingo_server.js`, `bingo.game/version.txt` (restart marker).  
- Modifs : anti-spam des logs “PlayerFail throttling” (fenêtre 30s : 1ère occurrence INFO, suivantes DEBUG, WARN spike si ≥50) + résumé périodique INFO `event:"player_fail_throttle_summary"` (total_count, unique_players_count, top_reasons, session_id si connue). Aucun changement métier.  
- Tests : déclencher plusieurs PlayerFail en <30s → `min_level=info` montre au plus un log initial + un résumé 30s (éventuel WARN spike), pas de spam; en `min_level=debug` les occurrences restent visibles.
**Bingo: join/registration logs structurés (31 jan 2026)**  
- Fichier : `bingo.game/ws/bingo_server.js`.  
- Modifs : helper `logJoin` + logs join_success/failure structurés (`event:"join"`, `role`, `session_id`, `player_id`/`client_id`, reason/code) pour joueurs (auth_player/auth_player_paper) et refus (session full, session inconnue) + auth failed.  
- Tests : session Bingo avec organizer + joueurs + cas refus → en `min_level=info`, logs join success/failure montrent role+IDs+reason.
**Quiz timeline coverage (A→Z) (31 jan 2026)**  
- Note: `notes/logging-quiz-timeline-coverage.md` (évalue si les logs métier Quiz permettent de suivre une session de bout en bout).  
- Résultat: insuffisant A→Z. Manques majeurs: bruit WS_IN/OUT/heartbeat non agrégé, logs réponse sans player_id structuré, pas de log success persistScore, inscriptions secondary/player peu structurées, fin de partie sans événement résumé. Recos: structurer events métier (register/start/answer/persistScore/endGame/support/audio) avec `action`+IDs, débruiter WS_IN/OUT+heartbeat, ajouter log unique END_GAME, compléter payload réponse, option /logs jsonl déjà dans backlog commun.
**Blindtest timeline coverage (A→Z) (31 jan 2026)**  
- Note: `notes/logging-blindtest-timeline-coverage.md` (audit des logs bruts Blindtest).  
- Conclusion: timeline insuffisante. Manques bloquants: bruit WS_IN/OUT/heartbeat; logs join non structurés (role/IDs/reason); player_answer/persistScore success non structurés; pas de log unique end_game; persistance score sans sessionId/playerId/duration. Recos micro-tâches: (1) débruiter WS; (2) structurer joins; (3) structurer answers + persistScore success; (4) log unique end_game; (5) option /logs jsonl si besoin.
**Bingo timeline coverage (A→Z) (31 jan 2026)**  
- Note: `notes/logging-bingo-timeline-coverage.md` (audit des logs bruts Bingo).  
- Conclusion: timeline insuffisante. Manques bloquants: bruit WS_IN/OUT non agrégé; joins non structurés (role/IDs/reason); case_click/verification/scoring sans payload structuré; persistScore/updates sans log success structuré; pas de log unique end_game. Ordre micro-tâches proposé: (1) débruiter WS; (2) structurer joins; (3) structurer case_click/verification/scoring + persist success; (4) log end_game unique; (5) option /logs jsonl.
**Workplan cross-game logs prêt (31 jan 2026)**  
- Note synthèse/priorisation : `notes/logging-workplan-cross-game.md` (backlog unique Quiz/Blindtest/Bingo).  
- Contenu : consolidation des 3 audits + canon/logging + post-rollback ; backlog P0/P1/P2 avec tâches mutualisées (logger enrichi, WS_IN/OUT agg/debug, option /logs jsonl, normalisation log_batch, payload hygiene), spécifiques par jeu, front et viewer/proxy en fin ; ordre d’exécution recommandé + liens vers chaque audit.  
- Suivant : lancer PRs séparés par tâche (une tâche = un PR) en suivant l’ordre P0→P2.
**Bingo — audit compliance logger-first (31 jan 2026)**  
- Note d’audit : `notes/logging-audit-bingo-compliance.md` (scope WS Bingo + /logs).  
- Constats : logger `ws/logger.js` JSONL v1 partiel (manque request_id/kind/action) ; WS_IN/OUT en info sans agg ni mapping niveau (`ws/bingo_server.js:1940-1955`) ; log_batch relai sans normalisation niveaux/req_id (`ws/bingo_server.js:248-283`) ; `/logs` renvoie JSON paginé (normalise schema v1, compte invalid) pas NDJSON (`ws/server.js:155-242`). Bruits principaux : WS_IN/OUT rafraîchissements, log_batch volumineux, logs texte connexion; heartbeat termination peu fréquent. Evidence file:line dans la note.  
- Recos : enrichir logger (request_id/kind/action/payload compact), passer refresh WS en debug/agg, option /logs format=jsonl ou doc du format actuel, normaliser log_event/log_batch niveaux + request_id, compacter payloads, structurer logs texte.  
- Prochaines étapes : suivre “Backlog micro-tâches (TASK 2..n)” dans la note pour planifier les correctifs minimaux.
**Blindtest — audit compliance logger-first (31 jan 2026)**  
- Note d’audit : `notes/logging-audit-blindtest-compliance.md` (scope WS Blindtest + /logs).  
- Constats : logger `web/server/logger_ws.js` OK JSONL v1 partiel (manque request_id/kind/action) ; WS_IN/OUT en info sans agg ni mapping niveau ; heartbeat loggué info ; /logs renvoie JSON paginé (normalise schema v1, compte invalid) pas NDJSON ; log_event/log_batch relaie sans normaliser niveaux numériques/warning ni request_id. Evidence file:line dans la note.  
- Recos : enrichir logger commun (request_id/kind/action/payload compact), passer heartbeat et refresh WS en debug/agg, ajouter agg/coalescing WS_IN/OUT, option /logs format=jsonl ou documentation du format actuel, propager/normaliser request_id et niveaux côté log_event/log_batch, compacter payloads volumineux.  
- Prochaines étapes : suivre la liste “Backlog micro-tâches (TASK 2..n)” de la note pour planifier les correctifs minimaux.
**Quiz — audit compliance logger-first (31 jan 2026)**  
- Note d’audit créée : `notes/logging-audit-quiz-compliance.md` (scope Quiz WS + /logs). 
- Constats : logger `web/server/logger_ws.js` produit du JSONL v1 partiel (manque request_id/kind/action) ; WS_IN/OUT loggent en info sans agg ni mapping niveau ; heartbeat loggué info (bruit) ; /logs renvoie JSON paginé (pas NDJSON) mais normalise schema v1 et compte les lignes invalides ; ingestion `log_event/log_batch` relaie sans normaliser level num/warning ni request_id. Evidence file:line dans la note.
- Recos (micro-tâches proposées) : enrichir logger commun (request_id/kind/action/payload compact, session_id snake), passer heartbeat et refresh WS en debug/agg, ajouter agg/coalescing WS_IN/OUT, option /logs format=jsonl ou doc format JSON actuel, propager/normaliser request_id et niveaux côté log_event/log_batch, compacter payloads volumineux. 
- Prochaines étapes suggérées : voir section “Backlog micro-tâches (TASK 2..n)” dans la note pour planifier les correctifs minimaux.
**WS disconnect logging (26 jan 2026)**  
- Bingo WS: `bingo_server.js` logge `CLIENT_DISCONNECT` schema v1 (source `BINGO_WS`, game, sessionId compat) avec `client_scope` (player/organizer/remote), `client_id`, code/reason/was_clean, `connected_ms`, niveau warn si code anormal (≠1000/1001 ou wasClean=false) + dédoublonage 3s; close handler passe code/raison/wasClean depuis `websocket_server.js` (heartbeat 1006). Evidence: `bingo.game/ws/bingo_server.js:74-137`, `bingo.game/ws/websocket_server.js:37-63`, `147-168`.  
- Blindtest WS: `connection.js` ajoute dédoublonage 3s et log `CLIENT_DISCONNECT` (source `BT_WS`) avec scope (player/organizer/remote), id (playerId/primaryInstanceId/remoteInstanceId), code/reason/was_clean, intent, connected_ms, niveau warn si code anormal; `wsHandler.js` tagge `connectedAt`. Evidence: `blindtest/web/server/actions/connection.js:1-74`, `blindtest/web/server/actions/wsHandler.js:25-33`, `335-371`.  
- Quiz WS: même logique que BT (source `QUIZ_WS`) avec connectedAt et dédoublonage 3s. Evidence: `quiz/web/server/actions/connection.js:1-74`, `quiz/web/server/actions/wsHandler.js:25-33`, `343-380`.  
- Viewer (games) : affichage FR des `CLIENT_DISCONNECT` — label `Déconnexion <scope> (<reason>, code=<code>)` + id tronqué (6…4) dans le message; reste au niveau info/warn donc invisible en `only=error`. Evidence: `games/web/logs_session.html:552-602` (branche `refacto/log-viewer-v1`).  
- Viewer (games) : le sélecteur Niveau pilote le mode d’affichage. `error` déclenche la vue agrégée erreurs (auto-pagination jusqu’à 500 erreurs / 20 pages, pagination masquée, tri desc), autres niveaux reviennent au mode paginé normal (page remise à 1). Bouton “Erreurs” supprimé. Evidence: `games/web/logs_session.html:173-190`, `300-320`, `853-956`.  
- Viewer (games) : normalisation des timestamps (`ts` nombre → ISO) utilisée pour le tri/affichage; les events sans wsType (ex `CLIENT_DISCONNECT`) apparaissent désormais correctement avec libellé et métas. Evidence: `games/web/logs_session.html:352-366`, `554-607`.  
- Proxy logs (games) : `min_level` applique désormais un ranking (debug=10 < info < warn < error) avec fallback `clientLevel` et default info; le filtre garde les niveaux >= seuil (debug conserve tout). Fixe le cas où `min_level=debug` renvoyait 0 entrée. Evidence: `games/web/includes/canvas/php/logs_proxy.php:69-118`.  
- Viewer (games) : filtre Niveau en mode debug fonctionne par seuil (debug < info < warn < error) au lieu d’égalité stricte, avec fallback level inconnus→info; un param `debug_test=1` loggue le comptage gardé pour micro-tests. Evidence: `games/web/logs_session.html:303-330`, `705-764`.  
**Bingo loadtest verification (26 jan 2026)**  
- `bingo_loadtest.js` réactive `grid_hydrate` après auth (file d’attente Canvas + retry) avec jitter 200–1200ms, remplit numbers/cells et logge DEBUG counts/gridSize (tags `loadtest/grid_hydrate`). Evidence: `bingo.game/ws/bingo_loadtest.js:568-599`.  
- Taille de grille déduite de la grille réelle (numbers/cells) avec layout dynamique (4x5 pour 20, 5x5 pour 25, 3x3 pour 9) et fallback 20 loggé DEBUG (tags `loadtest/fallback`). Evidence: `bingo.game/ws/bingo_loadtest.js:379-426`.  
- Diagnostics verification: DEBUG phase manquante, seuil non atteint (sous `LOADTEST_DEBUG`), envoi verification avec phase + lignes; duplication handler `ws.on('open')` supprimée. Evidence: `bingo.game/ws/bingo_loadtest.js:449-519`, `725-729`.  
- Endpoint Canvas du loadtest aligné sur `envUtils.getCanvasEndpoint` (hints WS/ORIGIN identiques au serveur) pour éviter de cibler la prod en dev (404 sur `grid_hydrate`/`grid_cells_sync`). Evidence: `bingo.game/ws/bingo_loadtest.js:74-128`.  
**Quiz persist score (26 jan 2026)**  
- Réponse Canvas `session_primary_id` désormais déballée (`json.data` si présent) pour aligner le bridge Quiz sur le schéma canon `{ ok, data, ... }`, supprimant les erreurs massives “Persist score failed: session_primary_id … réponse invalide”. Evidence: `quiz/web/server/actions/envUtils.js:176-205`.  
- Restart marker Quiz mis à jour: `quiz/web/server/restart_serveur.txt` → `restart 26-01-2026/01`.  
**Games log viewer branche (26 jan 2026)**  
- Branche dédiée créée pour le chantier viewer/logs: repo `games`, branche `refacto/log-viewer-v1` (base `develop`), SHA de départ `62b351ba02f0699d8693915e757e3b3fe2ddadd2`.  
**Logs viewer niveaux (26 jan 2026)**  
- `games/web/logs_session.html` ajoute un bloc Résumé: counts raw/eff. par niveau (error/warn/info/debug), invalid skipped, mode actif (params only/min_level/lang). Evidence: `games/web/logs_session.html:55-65`, `110-156`, `303-337`, `476-517`.  
- Lecture des params URL `min_level` (défaut info), `only` (error|warn), `lang` conservée pour affichage du mode; pas encore de filtrage serveur. Evidence: `games/web/logs_session.html:113-118`.  
- Comptages calculés côté client sur le jeu de données chargé, sans modifier la collecte ni les filtres existants.

**Logs viewer action-map (26 jan 2026)**  
- Réactivation de `web/assets/logs/actions-map.json` côté viewer: fetch + cache mémoire, badge status actionMap dans le résumé, fallback sûr. Evidence: `games/web/logs_session.html:350-388`, `560-653`, `986-1040`.  
- Application de la map pour dériver `effectiveLevel` (par jeu/wsType) avant filtrage: `checkSession` et autres ping passent debug si mappés. Evidence: `games/web/logs_session.html:560-653`.  
- Les compteurs Raw/Effective utilisent désormais `effectiveLevel` ; debug_test log affiche `actionMapLoaded`. Tests à faire: session avec checkSession → `min_level=debug` montre les lignes en debug et compteur Effective debug>0.

**Export complet (JSONL) (26 jan 2026)**  
- Bouton unique « Exporter complet (JSONL) » : boucle pages via `logs_proxy.php` (min_level courant) jusqu’à cap 50 pages / 10k entrées, applique filtres UI, exporte JSONL. Evidence: `games/web/logs_session.html` (exportFullSession).  
- Nom de fichier: `logs_<game>_<sessionId>_<YYYYMMDD-HHMM>_p<page>_limit<limit>_mode<min_level>.jsonl`.  
- Première ligne meta `_meta` avec export_version, exported_at, game, sessionId, source_url (params proxies), ui_filters (min_level/levelFilter/textFilter/page/limit), counts_raw/effective, `pages_fetched`, `cap_reached`, `total_entries_exported`.  
- Statut UI affiche la progression page i/j et mentionne si le cap est atteint.  
- Une ligne JSON par entrée (sans retrait de champs). Tests: session multi-pages → fichier volumineux, JSONL valide.

**Fix export NDJSON (28 jan 2026)**  
- Cause: le client concaténait les lignes avec `\\n`, produisant un seul JSON avec `\n` échappés.  
- Fix: `downloadJsonl` écrit `lines.join('\n') + '\n'` et Blob `application/x-ndjson;charset=utf-8`; chaque log est une ligne réelle. Evidence: `games/web/logs_session.html` (downloadJsonl).  
- Test: exporter une session >1 log, vérifier plusieurs lignes réelles (grep '^{' compte >1) et parsage ligne à ligne JSON OK.

**Filtre warn/error numérique (29 jan 2026)**  
- Symptôme: des logs warn/error avec level numérique (40/50) disparaissaient en vue warn/error.  
- Cause: la normalisation traitait `40` comme texte → ne matchait pas warn/error.  
- Fix: normalisation du niveau côté viewer (levelToLabel gère nombres + “warning”) et côté proxy (mapping numérique → labels). Evidence: `games/web/logs_session.html` (filter warn/error via levelToLabel), `games/web/includes/canvas/php/logs_proxy.php` (normalize_level numérique).  
- Test: log level=40 → visible en vue warn; level=50 → visible en vue error; pas de régression info/debug.

**level_mode=ui + effective_level proxy (30 jan 2026)**  
- Ajout param `level_mode` (raw par défaut, ui aligne sur le niveau effectif) dans `games/web/includes/canvas/php/logs_proxy.php`.  
- Proxy calcule et renvoie toujours `effective_level` (mapping actions-map.json + normalisation numérique + warning→warn), sans modifier le `level` brut.  
- Filtre `only`/`min_level` s’appuie sur `effective_level` quand `level_mode=ui`, sinon reste sur le niveau brut.  
- Usage recommandé test: `...logs_proxy.php?game=bingo&sessionId=...&min_level=warn&level_mode=ui` doit inclure un `end_game` (level info, effective warn). Evidence: proxy code.
- Bug corrigé 30 jan 2026: chemin actions-map.json corrigé (`../../../assets/logs/actions-map.json`) pour que le proxy applique bien le mapping UI; auparavant le fichier n’était pas trouvé, `effective_level` restait `info`.

**Compteurs alignés warn/error (29 jan 2026)**  
- Ajout `getEffectiveLevel` (viewer) utilisé partout (header, filtres warn/error) pour unifier la normalisation (effective_level/level/clientLevel, numériques et “warning”). Evidence: `games/web/logs_session.html`.  
- Proxy déjà normalisé numérique; header simplifié et affiche Effective uniquement.  
- Test: en min_level=warn, les warn+error (y compris level numérique) sont affichés et comptés.

**Affichage niveau normalisé (30 jan 2026)**  
- Le badge Niveau des lignes affiche le niveau effectif normalisé (labels/debug/info/warn/error) et la classe couleur suit ce niveau; tooltip `effective=… | raw=…` pour transparence. Evidence: `games/web/logs_session.html` (renderLogs, getEffectiveLevel).  
- getEffectiveLevel centralise la priorité (effective_level > effectiveLevel > level > clientLevel) + mapping numériques et “warning”.  
- Objectif: cohérence entre header, filtres, et rendu ligne, même si les niveaux source sont numériques.

**UI Logs session – catégories & niveau effectif (31 jan 2026)**  
- Badge Niveau rendu sur `effectiveLevel` (fallback level) + tooltip raw.  
- Classification générique + Bingo v1: cat/icon/short (conn/ws/state/remote/notification/phase/end/win), ajout d’un chip devant l’event et d’une bordure colorée par cat.  
- Rendu pensé multi-jeux via `classifyEventByGame` extensible. Evidence: `games/web/logs_session.html` (renderLogs + classify functions + CSS chip/cat-*). Tests: WS_IN end_game → chip 🛑 END, badge WARN (effective), border cat-end.
- Débruitage WS: formatEventLabel supprime “WS message” et le doublon WS_IN/WS_OUT; Event/message n’affiche plus deux icônes.
- Regroupement optionnel des doublons consécutifs (checkbox “Regrouper doublons” activée par défaut), clé = displayKey (label affiché) + source + niveau effectif + payload équivalent; chip ×N ajouté sur la ligne agrégée. Evidence: `games/web/logs_session.html` (buildDisplayKey, payloadEquivalent, collapse).  

**Audit niveau effectif (30 jan 2026)**  
- Symptôme observé: certains logs `WS_IN` avec `wsType=end_game` s’affichent WARN alors que `level:"info"` dans la réponse.  
- Cause identifiée: mapping `actions-map.json` (`end_game` → level warn) appliqué dans `applyActionMap` → `effectiveLevel` surclasse le level brut.  
- Points d’entrée: `normalizeEntry` + `applyActionMap` (wsType map), `classifyUpdate` (downgrade/transition), `applyFilters` (filtre min_level via getEffectiveLevel), `renderLogs` (badge via getEffectiveLevel), `loadErrorsAggregated` (warn/error vue).  
- Champs niveaux entrants utilisés: `level`, `effective_level`, `effectiveLevel`, `clientLevel`, parfois numériques.  
- Reco patch minimale (non implémentée ici): calculer un `effectiveLevel` unique juste après normalisation (avant map+classify), le stocker sur l’entrée et l’utiliser partout (rendu, filtres, compteurs, vues warn/error); s’appuyer sur `getEffectiveLevel`/`levelToLabel`. Tests: min_level=warn/error affiche exactement warn+error (y compris numériques).  
**Logs viewer only=error (26 jan 2026)**  
- Proxy `logs_proxy.php` filtre server-side `only`/`min_level`, recalcule count/total/pages; utilise `effective_level` si présent. Evidence: `games/web/includes/canvas/php/logs_proxy.php:6-129`.  
- Viewer: bouton “Erreurs” + param `only=error`; auto-pagine les erreurs jusqu’à 500 entrées, affiche le mode dans le Résumé. Evidence: `games/web/logs_session.html:200-236`, `300-321`, `736-837`.  
- Test à faire: session avec erreurs → `logs_session.html?...&only=error` affiche les erreurs sans parcourir les pages.
**Front JS errors → GAMES_FRONT (26 jan 2026)**  
- Ajout hooks `window.onerror` / `unhandledrejection` qui émettent des entrées schema v1 (level error, source GAMES_FRONT, session_id si résolue) via le logger front existant; payload safe `{path,file,line,col,stack_trunc,reason_trunc}`. Evidence: `games/web/includes/canvas/core/logger.global.js:174-240`.  
- Anti-spam: déduplication 2s par clé msg+file+line + rate limit 20 erreurs/min. Evidence: `games/web/includes/canvas/core/logger.global.js:176-204`.  
- Transport réutilise le buffer / sinks existants (log_batch). Test à faire: provoquer erreur JS et vérifier présence dans logs_session.html (source GAMES_FRONT, level error).
**Reporting jeux & joueurs (25 jan 2026)**  
- Cron `cron_routine_bdd_maj.php` crée/purge `reporting_games_sessions_detail` sur la même fenêtre que les agrégats (backfill si caches vides), puis insère les sessions avec `players_count = équipes_joueurs + bingo_players + blindtest_players + cotton_quiz_players` et les mêmes filtres que le monthly (pas de démos, config complète, client actif, session terminée). Evidence: `www/web/bo/cron_routine_bdd_maj.php:210-296`.  
- BO `bo_facturation_pivot_saas.php` : endpoint JSON `?games_sessions_detail_ajax=1` (month obligatoire, filtres game/client, mapping type produit, retour rows+clients) + modal drilldown filtres jeu/client avec tableau Date | Jeu | Client | SessionId | Joueurs | Logs (lien basé sur `games_url` avec fallback). Evidence: `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php:1-104`, `4678-4713`, `5322-5588`, `5766-5776`.

**Normalisation minimale appliquée (25 jan 2026)**  
- WS `/logs` (Bingo/BT/Quiz) normalise chaque ligne JSONL: `log_schema_version=1`, `game`, `source`, compat `session_id`/`sessionId`, fallback `ts` si absent, skip legacy non-JSON + compteur `invalid` renvoyé. Evidence: `bingo.game/ws/server.js:11-85`, `blindtest/web/server/server.js:32-113`, `quiz/web/server/server.js:32-113`.  
- Loggers WS émettent `log_schema_version=1`, `game`, `session_id` (miroir `sessionId`). Evidence: `bingo.game/ws/logger.js:4-104`, `blindtest/web/server/logger_ws.js:4-111`, `quiz/web/server/logger_ws.js:4-106`.  
- Ingestion front `log_batch` taggée `source:GAMES_FRONT` (au lieu de `GAMES`). Evidence: `bingo.game/ws/bingo_server.js:246-284`, `blindtest/web/server/actions/wsHandler.js:420-445`, `quiz/web/server/actions/wsHandler.js:442-445`.  
- Front logger (`games/web/includes/canvas/core/logger.global.js`) en JSONL v1: ajoute `log_schema_version`, `session_id`, `game`, `request_id` auto (base+seq), source `GAMES_FRONT`; flush WS conserve ces champs. Evidence: `games/web/includes/canvas/core/logger.global.js:118-195` et `205-243`.  
- Viewer `games/web/logs_session.html` robuste: fallback `ts` auto, summary (totaux, sources, invalid skipped), compteur `invalid` issu du backend, filtres/dédupe inchangés. Evidence: `games/web/logs_session.html:576-719` et `738-770`.  
- Restart markers : Bingo `version.txt` → `restart 26-01-2026/06`; Blindtest `web/server/restart_serveur.txt` → `restart 26-01-2026/01`; Quiz `web/server/restart_serveur.txt` → `restart 26-01-2026/02`.

**Viewer logs FR/EN + mapping actions (24 jan 2026)**  
- Mapping JSON FR/EN + niveau par jeu consommé par le viewer (actions/wsType des docs, + bruits ping/register). Fallback compact pour les actions non mappées, détermination de niveau via mapping ou regex (error/warn/ping). Params URL: `lang` (fr par défaut, `?lang=en`), `min_level` (par défaut info, `debug|info|warn|error`), `only=error`; header stats: total / visibles / debug masqués / warn / error. Evidence: `games/web/assets/logs/actions-map.json:1-200`, `games/web/logs_session.html:515-915`.

**Canal/Audience + session updates triées (24 jan 2026)**  
- Colonne “Canal/Audience” : FRONT, WS_IN/WS_OUT + cible (socket/organizers/players/all) + rôle éventuel, remplace l’ancienne colonne Client. Evidence: `games/web/logs_session.html:443-767`.  
- Session updates : analyse delta d’état (status/index/tick) par session : transitions (status/index changent) restent en info et montrent le détail, refresh (tick seul) basculent en debug (masqués par défaut). Evidence: `games/web/logs_session.html:647-739`, `791-853`.  
- Fallback labels compacts et filtres existants inchangés; test mapping: `node -e "const map=require('./web/assets/logs/actions-map.json'); console.log(Object.keys(map))"` (ok).

**Timeline enrichie (24 jan 2026)**  
- Reclassement auto des mises à jour de session / sync state en `debug` (wsType `initializeOrUpdateSession`, `getGameState`, `update_session_infos`, `updateSession`, `sessionStatus`, ou message/label “Mise à jour session”/“État de jeu”), inscriptions/start/score restent en info. Evidence: `games/web/logs_session.html:461-479`.  
- Dérivation `client_scope` (organizer/player/remote/socket/all/server/front) + affichage colonne “Client” + filtre URL `?scope=organizer|player|remote|all|socket|server|front`. Evidence: `games/web/logs_session.html:488-505`, `694-768`, `793-853`.  
- Colonne ajoutée (7 cols) avec colSpan ajustés pour lignes vides/transition. Evidence: `games/web/logs_session.html:695-769`.

**Branches & commits (refacto/log-normalization-v1)**  
- games: `13f4b15` (warning source align) + `17ded84` (front logger + viewer fallback).  
- bingo.game: `fb90972` (normalize /logs + schema v1 + restart).  
- blindtest: `f95e8dc` (normalize /logs + schema v1 + restart).  
- quiz: `3c6c56c` (normalize /logs + schema v1 + restart).

## Actions réalisées (auto)
- BO drilldown sessions : endpoint `?games_sessions_detail_ajax=1` sécurise toujours une réponse JSON (header utf-8, validation month/game, `exit;`, `display_errors=0`, logs d'erreur) et l’UI affiche l’aperçu de réponse en cas de non-JSON (texte 200 chars) via la modal. Router intercepte avant layout (`bo.php:84-123`) et délègue à `bo_facturation_pivot_saas_handle_games_sessions_detail_ajax()`. Evidence: `www/web/bo/bo.php:84-123`, `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php:1-140`, `5322-5588`.  
- Reporting jeux & joueurs : cron ajoute la table `reporting_games_sessions_detail` (fenêtre M-1/M, purge + insert par session avec addition stricte joueurs, filtres alignés agrégats) et logge le volume; BO ajoute l’endpoint JSON `?games_sessions_detail_ajax=1` + modal drilldown filtres jeu/client (colonnes Date/Jeu/Client/SessionId/Joueurs/Logs, lien `games_url` fallback). Evidence: `www/web/bo/cron_routine_bdd_maj.php:210-296`; `www/web/bo/www/modules/synthèses/facturation_pivot/bo_facturation_pivot_saas.php:1-104`, `4678-4713`, `5322-5588`, `5766-5776`; doc `documentation/canon/data/games-reporting.md` (bloc `reporting-jeux`). Tests manuels à faire (jouer une session, lancer le cron, ouvrir le drilldown + logs).  
- Fix JSON drilldown HTML leak : handler déplacé tout en haut + `ob_clean()` + header JSON utf-8 + validation month/game + `exit;` pour éviter tout DOCTYPE/HTML. Client-side parse error montre l’aperçu 200 chars. Evidence: `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php:1-120`, `5322-5588`.  
- Reporting démos (detail) : cron crée `reporting_games_demos_detail` (schema miroir sessions detail) + purge fenêtre M-1/M + insert des sessions `flag_session_demo=1` (backfill si table vide depuis la 1re démo) puis mise à jour `players_count = équipes_joueurs + bingo_players + blindtest_players + cotton_quiz_players`; fenêtre choisie loggée. Evidence: `www/web/bo/cron_routine_bdd_maj.php:250-356`.  
- Reporting démos backfill + totaux : si `reporting_games_sessions_detail`/`reporting_games_demos_detail` sont vides, backfill depuis la date min des sessions correspondantes jusqu'à aujourd'hui; purge/insert sur cette fenêtre; totaux “Démos inscrits” réactivés et calculés en sommant uniquement les mois affichés. Evidence: `www/web/bo/cron_routine_bdd_maj.php:250-356`, `www/web/bo/www/modules/synthèses/facturation_pivot/bo_facturation_pivot_saas.php:4418-4460`.  
- BO modal UX (sessions & démos) : préfiltre jeu depuis le clic, titres explicites (sessions/démos visiteurs/démos inscrits), filtre client masqué/désactivé pour visiteurs (client 1557), rechargement sur changement de filtre jeu/client, état "Chargement…" et message vide explicite. Evidence: `www/web/bo/www/modules/synthèses/facturation_pivot/bo_facturation_pivot_saas.php:4300-4460`, `5322-5850`.  
- Normalisation minimale logging (WS Bingo/BT/Quiz + front + viewer) : `/logs` ajoute schema v1 + skip legacy (`bingo.game/ws/server.js:11-85`, `blindtest/web/server/server.js:32-113`, `quiz/web/server/server.js:32-113`); loggers émettent schema v1 + `session_id` (`bingo.game/ws/logger.js:4-104`, `blindtest/web/server/logger_ws.js:4-111`, `quiz/web/server/logger_ws.js:4-106`); ingestion front taggée `GAMES_FRONT` (`bingo.game/ws/bingo_server.js:246-284`, `blindtest/web/server/actions/wsHandler.js:420-445`, `quiz/web/server/actions/wsHandler.js:442-445`); logger front v1 + `request_id` auto (`games/web/includes/canvas/core/logger.global.js:118-195`, `205-243`); viewer summary + compteur invalid (`games/web/logs_session.html:576-770`). Tests: non exécutés (à faire en env dev avec session réelle).
- Viewer `/logs_session.html` : support mapping JSON FR/EN (`web/assets/logs/actions-map.json`) + inférence niveau (mapping → regex ping/error) + labels fallback compacts (`IN/OUT wsType → cible` + résumé payload 3 clés) + filtres `min_level` (par défaut info) / `only=error` + param `lang` + stats header (total/visibles/debug masqués/warn/error). Evidence: `games/web/assets/logs/actions-map.json:1-200`, `games/web/logs_session.html:515-915`. Tests: `node -e "const map=require('./web/assets/logs/actions-map.json'); console.log(Object.keys(map))"` (ok); pas de test navigateur (session BT/Quiz/Bingo à faire).
- Viewer `/logs_session.html` (timeline utile) : reclasse les updates de session/sync en debug caché par défaut + garde inscriptions/start/score/bingo en info; ajoute dérivation `client_scope` (organizer/player/remote/socket/all/server/front) + colonne “Client” + filtre URL `scope=`. Evidence: `games/web/logs_session.html:461-505`, `694-853`. Tests: à faire en BT/Quiz avec `?min_level=debug` pour voir les updates et `?scope=organizer` etc.
- `games/web/games_ajax.php` (alias `games/web/global_ajax.php`) → bypass dev optionnel des writes sans `X-Service-Token` (garde prod strict) + log warning + `data.auth_bypassed=true` → débloquer temporairement les WS en dev → test: `php -l games/web/games_ajax.php`.
- `documentation/canon/interfaces/canvas-bridge.md` → doc contrat auth + bypass dev → aligner comportement/contrat → test: N/A (doc).
- `documentation/SITEMAP.md` → standardiser les liens “raw” vers `raw.githubusercontent.com` (fiabilité agents/outils, moins de redirections/cache) → test: curl HEAD sur 2–3 entrées clés.
- `documentation/SITEMAP.md` → SITEMAP: standardisation des URLs raw vers `/refs/heads/develop` pour fiabilité agents/outils (`https://raw.githubusercontent.com/cotton-games/documentation-public/develop/` → `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/`).
- `documentation/scripts/gen-sitemap.mjs` + `.github/workflows/publish-docs.yml` → fix: générateur SITEMAP “branch-aware” (`DOCS_BRANCH` > `GITHUB_REF_NAME` > `develop`) + URLs `raw.githubusercontent.com/.../refs/heads/${branch}/...` (develop/main) pour éviter que le mirroring régénère avec un préfixe hardcodé. Exemples: develop → `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md`, main → `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/HANDOFF.md`.
- `documentation/canon/entrypoints.md` + `documentation/canon/runbooks/dev.md` + `documentation/canon/runbooks/troubleshooting.md` → doc env var `CANVAS_DEV_ALLOW_UNAUTH_WRITES` + troubleshooting 403 → rendre le runbook actionnable → test: N/A (doc).
- `SITEMAP.md` → ajout “Start Here / Single Entrypoint” + intent map + editing rules (doc onboarding IA).
- `README.md` + `DOCS_MANIFEST.md` + `SITEMAP.md` → clarification du rôle “web AI orchestrator” vs “Codex executor” + consignation obligatoire dans `HANDOFF.md` → rendre le pacte explicite et actionnable.
- `README.md` + `DOCS_MANIFEST.md` + `SITEMAP.md` → ajout règle “verification-first / no guessing” (preuves requises avant recommandations prod) + template + exemple PM2 (`cwd` relatif) → éviter les actions basées sur des hypothèses.
- `documentation/canon/entrypoints.md` + `documentation/canon/runbooks/troubleshooting.md` (+ `documentation/canon/runbooks/dev.md`) → consignation evidence-based des chemins PHP (`/var/www/<vhost>/web`/`private`) + règle PM2 WS (cwd relatif + `./.env`) avec “minimum evidence required” → éviter toute déduction de chemins WS absolus.
- `games/web/games_ajax.php` + `games/web/global_ajax.php` → refactor “no regression”: nouveau nom explicite côté vhost games + shim alias historique + update call-sites (games/WS/docs) → réduire confusion avec `global/global_ajax.php` → test: `php -l games/web/games_ajax.php` + `php -l games/web/global_ajax.php`.
- `games/web/organizer_canvas.php` → pour `id_client=1557`, masquer “Personnalisation”, “Options de jeu” et les QR (inscription + pause + pilotage) → test: vérif manuelle UI (client 1557 vs autres clients).
- WS Bingo + front canvas: compat `passed_song` (server envoie `num_passed_songs` + conserve `x` legacy; front tolère `x`/`numPassedSongs`) + accept alias `registration_error` (en plus de `registrationError`) → test: vérif manuelle progression Bingo (player + remote).
- Bingo demo reset: ajout action Canvas API `bingo.resetdemo` (glue PHP) + organizer reset démo aligné BT (API → reload), grilles réinitialisées sans désassignation → test: démo Bingo revient “En attente” + index 0, joueurs/grilles conservés.
- Bingo demo reset follow-up: fix WS `auth_client` payload (`id_playlist_client`) by adding `data-playlist-id` on canvas roots + adding `playlistClientId` to Bingo preload/meta; remote/player resync via WS `demo_reset` (server resets in-memory state + broadcasts neutral `state` first), and the organizer emits `demo_reset` after the API reset commit delay → test: remote/player show phase 0 then reload.
- Bingo: `bingo.session_update` ignores song updates while `phase_courante=0` to prevent `morceau_courant` from being re-written by a late `song_start` right after a demo reset.
- Workspace git hygiene: durcissement des `.gitignore` par repo + ajout de templates (`*.template.*`) pour éviter la fuite de secrets/artefacts (contexte mirroring privé → public).
- `documentation/DOCS_MANIFEST.md` → ajout de règles “décidables” (Match globs) + procédure Codex anti-rescan basée sur `git diff --name-only` + MAJ `documentation/README.md` (rappel anti-rescan).
- `documentation/DOCS_MANIFEST.md` → ajout table “Routing rules (paths/globs → docs)” + procédure “anti-rescan (Codex)” (déterministe via `git diff --name-only`, pas de scan global).
- `documentation/canon/runbooks/security.md` + `documentation/SITEMAP.md` → ajout d’un runbook canon “sécurité / git hygiene” (mirroring privé → public) et publication via sitemap.
- `documentation/README.md` + `documentation/DOCS_MANIFEST.md` → ajout règle “Web AI orchestrator” + snippet “Docs (obligatoire)” à coller dans tous les prompts Codex (anti-rescan).
- `documentation/DOCS_MANIFEST.md` + `documentation/README.md` → ajout règle “Server restart markers” : toute modif WS (`bingo.game/**`, `blindtest/web/server/**`, `quiz/web/server/**`) implique de bump le marker associé (`version.txt` / `restart_serveur.txt`) au format `restart DD-MM-YYYY/NN`.
- PM2 WS (DEV): alignement `apps[].name`/`apps[].cwd` avec la réalité runtime pour permettre `pm2 startOrReload ... --update-env` (Bingo: `bingo-ws` id 1, symlink `/home/bingo_game/bingo-ws` → `/var/www/bingo.game.dev.cotton-quiz.com/ws/server.js`; BT: `server` id 39, cwd `/var/www/blindtest.dev.cotton-quiz.com/web/server`; Quiz: `server` id 0, cwd `/var/www/quiz.dev.cotton-quiz.com/web/server`) + MAJ `documentation/pm2-ws.md`.
  - Commandes admin (DEV):
    ```bash
    pm2 startOrReload /var/www/blindtest.dev.cotton-quiz.com/web/server/pm2-ws.ecosystem.config.cjs --update-env
    pm2 startOrReload /var/www/quiz.dev.cotton-quiz.com/web/server/pm2-ws.ecosystem.config.cjs --update-env
    pm2 startOrReload /var/www/bingo.game.dev.cotton-quiz.com/ws/pm2-ws.ecosystem.config.cjs --update-env
    ```
- 403 Canvas API writes (WS): diagnostic evidence-based + correctif minimal
  - Evidence runtime (WS Bingo logs): `canvasEndpointResolved` a basculé sur `https://games.cotton-quiz.com/...` + `tokenPresent=false` → writes `session_update/reset/...` en 403 `forbidden`.
  - Fix code: fallback d’endpoint “sans hint” basé sur `NODE_ENV`/`APP_ENV` (non-prod → host `.dev.`) + support alias token `CANVAS_API_SERVICE_TOKEN` + log safe au démarrage (`canvasEndpointResolved`, `tokenPresent`, `tokenSource`).
  - Doc: `documentation/pm2-ws.md` clarifie la priorité `CANVAS_API_URL` + la règle host/token (sans secrets).
- Blindtest WS: ajout de logs safe de diagnostic Canvas writes (sans secrets) dans `blindtest/web/server/actions/envUtils.js`:
  - boot: `tags:["config"]` (`canvasEndpointResolved`, `canvasHost`, `tokenPresent`, `tokenSource`, `nodeEnv/appEnv`, `hintSource`)
  - write failure: `tags:["api_write_failed"]` (`action`, `statusCode`, `canvasHost`, `event_id`, `latencyMs`)
  - write sans token: warning unique (hint “set CANVAS_SERVICE_TOKEN”)
- WS (Bingo/Blindtest/Quiz): chargement local `.env` au boot (whitelist, sans écraser l’env PM2) pour rendre l’injection robuste malgré `cwd`/symlinks et éviter les 403 “token missing”.
  - Evidence: logs `tags:["config"]` pouvaient montrer `tokenPresent=false` alors que le `.env` existe côté serveur.
  - Fix: loader local boot-only (search `__dirname/.env` puis `process.cwd()/.env`) + log safe `envFileLoaded/envFilePathUsed/envKeysLoaded` + token source.
- Canvas API (BT/Quiz): alignement WS sur la réponse canon `{ ok, data, error, ts }`
  - Evidence: `session_primary_id`/`players_get` pouvaient être vus comme “réponse invalide” côté WS car les champs étaient attendus “à plat” au lieu de `data.*`.
  - Fix: WS BT/Quiz lisent désormais les champs attendus dans l’objet `data` (wrappers `__canvasCall` unwrappent `data`); compat ajoutée côté PHP pour `session_primary_id` (`sessionId`/`session_id`/`token`).
  - Doc: `documentation/canon/interfaces/actions.md` rappelle que les clients doivent déballer `data`.
- WS Bingo: audit “reachable DB writes” (hors loadtest) pour préparer le nettoyage Knex legacy
  - Result: aucun write DB “métier” reachable depuis `bingo.game/ws/bingo_server.js` (les writes passent par Canvas API) ; DB reads restent utilisés (auth/hydrate, `ensureSessionIdForGame`, `ensureGameProgressHydrated`).
  - Nettoyage effectué (22 janvier 2026): suppression franche `case_click` (WS + Canvas) + suppression `bonus_request` (WS) + suppression de l’hydratation DB des lots côté WS.
  - Doc: `documentation/canon/data/bingo-write-map.md` + `documentation/canon/data/bingo-db-usage.md` + `documentation/specs/tests/c2.md`.
- WS Blindtest/Quiz: mitigation burst `update_score` (23 janvier 2026)
  - `ensureSessionPrimaryId`: coalescing par session via `session.__primaryIdInFlight` (évite le thundering herd).
  - `update_score`: enqueue non-bloquant + cap concurrence via `CANVAS_UPDATE_SCORE_CONCURRENCY` (default 5) + logs “queue pressure/drained” synthétiques.
  - Canvas HTTP: timeout AbortController via `CANVAS_HTTP_TIMEOUT_MS` (default 3000ms), sans retry automatique.
  - Quiz: alignement Blindtest sur `event_id` injecté pour toutes les write actions Canvas (idempotence).
  - Restart markers bumped: Blindtest `restart 23-01-2026/01`, Quiz `restart 23-01-2026/02`.
- Cible de restauration (23 jan 2026) : games `62b351ba02f0699d8693915e757e3b3fe2ddadd2`, quiz `fe9918b2b76ad067fd1ccd93750ec1a2edd8f0e7`, blindtest `f830d7a2b3d4a50c2b0ed4c497ec88d90b581646`, bingo.game `03d00d01fa39b81bef526a6c8e5ad72a3737ba4d`.
- Rollback appliqué côté code (voir repos) et doc nettoyée pour ne plus décrire les features de logging avancé (toggle debug, agrégats, bingo_phase).

## Audit logging (23 janvier 2026) — bruit vs manquants (preuves)

### Où sont produits les logs (WS + PHP proxy)
- Quiz WS:
  - Logger JSONL: `quiz/web/server/logger_ws.js` → écrit `quiz/web/server/server-logs.log` (rotation locale).
  - Endpoint lecture session: `quiz/web/server/server.js` → `GET /logs?sessionId=...` (lit JSON par ligne, ignore les lignes non-JSON).
  - WS_IN throttlé: `quiz/web/server/actions/wsHandler.js` (log `{ event:"WS_IN", wsType, payload: compact… }`).
  - WS_OUT: `quiz/web/server/messaging.js` (log `{ event:"WS_OUT", wsType, target, payload: compact… }`).
  - Bruit majeur: `quiz/web/server/actions/gameplay.js` logge l’objet `session` entier (`Logger.log(\`Session … mise à jour\`, session)`).
- Blindtest WS: même structure que Quiz (fichiers miroirs sous `blindtest/web/server/`).
- Bingo WS:
  - Logger JSONL: `bingo.game/ws/logger.js` → écrit `bingo.game/ws/server-logs.log` (rotation locale).
  - Endpoint lecture session: `bingo.game/ws/server.js` → `GET /logs?sessionId=...`.
- UI viewer + proxy PHP:
  - UI: `games/web/logs_session.html`
  - Proxy: `games/web/includes/canvas/php/logs_proxy.php` → proxy `http://127.0.0.1:<port>/logs` selon `game`.

### Échantillons (réels) + formats observés
- Quiz: `quiz/web/server/server-logs.log`
  - Mix **texte** (ancien format) + **JSONL** (nouveau logger). Extraits courts:
    - `[22/12/2025 12:12:18] [ERROR] Le socket spécifié est introuvable ou n’est pas ouvert.`
    - `{"ts":"2026-01-20T07:43:40.618Z","level":"info","source":"CQ_WS","sessionId":"…","event":"WS_IN","wsType":"registerOrganizer",…}`
- Blindtest: `blindtest/web/server/server-logs.log`
  - **JSONL** uniquement (mais payloads très lourds possibles). Extrait court:
    - `{"ts":"2026-01-22T14:19:03.221Z","level":"info","source":"BT_WS","msg":"Message heartbeat reçu du client."}`
- Bingo: `bingo.game/ws/server-logs.log`
  - **JSONL** uniquement. Extrait court:
    - `{"ts":"2026-01-21T08:03:26.663Z","level":"info","source":"BINGO_WS","sessionId":"…","tags":["song_start"],"msg":"session_update via API ok","event_id":"…","latencyMs":…}`

### Top événements / spam (comptages sur fichiers réels)
Analyse rapide (parser JSON quand possible, sinon normalisation du texte) :
- Quiz (`quiz/web/server/server-logs.log`, ~74335 lignes; ~73351 non-JSON):
  - spam: `Le socket spécifié…` (~9545), heartbeat (~5420) + `Message reçu: heartbeat…` (~5282)
  - spam: “Message envoyé aux organisateurs …: [object Object]” (plusieurs milliers)
- Blindtest (`blindtest/web/server/server-logs.log`, ~4605 lignes JSON):
  - spam: `Message heartbeat reçu du client.` (~1899)
  - volume significatif: WS logs `event=WS_IN/WS_OUT` et `msg="WS message"`
- Bingo (`bingo.game/ws/server-logs.log`, ~8978 lignes JSON):
  - volume fort: `msg="WS message"` (~4215)
  - spam: warnings “❌ Aucun remote actif …” (plusieurs centaines, selon gameID)

### Tableau bruit / utilité / champs manquants

| Event/type (observé) | Volume | Utilité | Champs manquants / à normaliser |
|---|---:|---|---|
| `WS_IN` (`wsType=heartbeat`) | Fort | Debug | passer en `debug` + **agréger** (`counts`/`window_ms`) + `request_id` |
| `WS_OUT` (`msg="WS message"`) | Fort | Timeline/Debug | `kind="ws"`, `action="out"`, `request_id` (corrélation), payload compact ok |
| “socket introuvable / pas ouvert” | Fort | Debug (souvent race) | agréger + inclure `session_id`, `target` + downgrade `level` |
| `Session … mise à jour` (avec objet `session` complet) | Fort | Inutile/bruit | remplacer par **résumé** (`players_connected`, `phase`, `song_index`, etc.) |
| Writes Canvas (`… via API ok/failed`, `latencyMs`) | Moyen | Timeline + debug perf | normaliser `duration_ms`, `status`, `action` (`api_call`), `request_id` |
| “Hydratation depuis la BDD échouée” (avec payload énorme) | Faible→Moyen | Debug | réduire payload, garder `error`, `stack`, `status`, `duration_ms` |

### Décision doc
- Spécification du schéma canon (JSONL) ajoutée dans `canon/logging.md` (incl. `request_id` + compat `sessionId`).

## Implémentation logging (23 janvier 2026)
- Quiz/Blindtest: logger JSONL v1 + redaction/troncature payload (anti-secrets) + propagation `request_id` via AsyncLocalStorage:
  - `quiz/web/server/logger_ws.js`, `blindtest/web/server/logger_ws.js`
  - `quiz/web/server/actions/wsHandler.js`, `blindtest/web/server/actions/wsHandler.js` (génère `request_id` par message + agrégation heartbeat 5s)
- Réduction bruit Quiz/Blindtest:
  - `quiz/web/server/actions/gameplay.js`, `blindtest/web/server/actions/gameplay.js` → stop dump `session` complet, log `summary` compact (debug)
  - `quiz/web/server/messaging.js`, `blindtest/web/server/messaging.js` → agrégation 5s des “socket pas ouvert” (warn synthétique)
- Canvas writes (Quiz/Blindtest): normalisation canon `kind/action/status` sans surcharger `action` (Canvas) :
  - `quiz/web/server/actions/envUtils.js`, `blindtest/web/server/actions/envUtils.js` (ajoute `kind:'api'`, `action:'canvas_write'`, `status`, `canvas_action`; `latencyMs` → `duration_ms` via logger)
- Bingo: logger JSONL v1 + propagation `request_id` sur réception messages + réduction bruit remote manquant:
  - `bingo.game/ws/logger.js`, `bingo.game/ws/websocket_server.js` (génère `request_id` si absent)
  - `bingo.game/ws/bingo_server.js` (agrégation 5s “remote manquant”)
- Restart markers bumped (obligatoire):
  - WS Bingo: `bingo.game/version.txt` → `restart 23-01-2026/01`
  - WS Blindtest: `blindtest/web/server/restart_serveur.txt` → `restart 23-01-2026/02`
  - WS Quiz: `quiz/web/server/restart_serveur.txt` → `restart 23-01-2026/03`
- Timeline/info logs (session_start/end, phase transitions, round start/stop, players snapshots, sync_state) instrumentés dans les gameplay BT/Quiz (`logTimelineEvent`, `logPlayersSnapshot`, `logSyncState`) + le doc canon `canon/logging.md` mentionne ces events et l’agrégation.
- Viewer logs (`games/web/logs_session.html` + `games/web/includes/canvas/php/logs_proxy.php`): toggle “Afficher les logs debug”, résumé (lignes/erreurs/agrégats/durée), filtres `show_debug`/`min_level`, agrégats montés en évidence.
- Audit & implémentation logs (23 janvier 2026) : `quiz/web/server/actions/wsHandler.js`, `blindtest/.../wsHandler.js`, `quiz/.../messaging.js`, `blindtest/.../messaging.js` passent `WS_IN`/`WS_OUT` en `debug` ; `quiz/.../gameplay.js`, `blindtest/.../gameplay.js` réduisent `sync_state` au besoin + agrègent en debug ; `bingo.game/ws/bingo_server.js` ajoute `logBingoSongStart`, `track_position` agg, `verification_result` et enrichit les infos `status/bingo_phase` + `logVerificationResult` ; `games/web/logs_session.html` consomme `bingo_phase` pour afficher `play:LIGNE` quand disponible ; `documentation/canon/logging.md` décrit les nouveaux events/agrégats et ce `HANDOFF.md` bloque le historique. Tests : recharger `/logs_session.html?sessionId=...` (mode normal / debug) et vérifier la timeline sans WS_IN/WS_OUT, puis en debug.

### Comment vérifier (manuel)
- Créer une session, ouvrir `/logs_session.html?sessionId=...` et vérifier que les entrées récentes contiennent `log_schema_version:1` et `request_id` (au moins sur `WS_IN`).
- Envoyer des heartbeats (Quiz/BT) et vérifier qu’on voit des lignes “WS heartbeat (aggregated)” au lieu d’un log par heartbeat.
- Provoquer un envoi vers socket fermé (Quiz/BT) et vérifier un warn synthétique “Socket introuvable / pas ouvert (agrégé)” au lieu de milliers de lignes.
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
