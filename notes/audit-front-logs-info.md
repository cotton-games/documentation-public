# Audit FRONT logs INFO — jeux (31 jan 2026)

## Contexte & méthode
- Scope : logs front (repo `games`), sources JS côté client uniquement (pas WS).
- Cibles : verbosité niveau INFO et champ Meta (logger.global.js → viewer logs_session.html).
- Commandes exécutées :
  - `rg -n --hidden --glob '!.git' "\.info\(" games`
  - `rg -n --hidden --glob '!.git' "logger\.info\(" games`
  - `rg -n --hidden --glob '!.git' "\.warn\(" games`
  - `rg -n --hidden --glob '!.git' "\.debug\(" games`
  - `rg -n --hidden --glob '!.git' "emitTimelineEvent\(|emitGameEvent\(" games`
  - `rg -n --hidden --glob '!.git' -o "\[[A-Z0-9_]{3,}\]" games/web`

## 1) Statistiques brutes
- Occurrences `.info(` totales : **17**
- `.warn(` : 63 ; `.debug(` : 2 ; `emitTimelineEvent|emitGameEvent` : 8 ; tags `[UPPER]` détectés : faibles (DEBUG/INFO/ERROR/BOOT/RESOLVE/ORGA)

Top fichiers `.info(` (count | file)
1. 11 — `web/includes/canvas/core/games/bingo_ui.js`
2. 3 — `web/includes/canvas/core/boot_organizer.js`
3. 2 — `web/includes/canvas/core/logger.global.js`
4. 1 — `web/includes/canvas/core/ws_effects.js`

Top “tags/events” repérés (ligne INFO)
- `renderAll`, `pushMany:done`, `clearAll: vidé`, `onAttach`, `onDetach`, `onPhaseChange`, `prepareQuestion`, `renderQuestion`, `Overlay affiché`, `Création du panneau notifs`, `[bingo] Aucun buffer de notifs…`, `[Canvas] WS ouverte/fermée`, `[WS][bingo] auth_client meta`, `[unlock] gesture detected` (aucun tag répétitif type JOIN/GRID détecté par regex dédiée).

## 2) Classification automatique (par pattern)
Catégories (sur 17 occurrences) :
- **TRANSIENT/TRACE (~12)** : `renderAll`, `pushMany:done`, `clearAll`, `onAttach`, `onDetach`, `onPhaseChange`, `prepareQuestion`, `renderQuestion`, `Overlay affiché`, `Création panneau notifs`, `[bingo] Aucun buffer…`, `[WS][bingo] auth_client meta`.
- **STATE (~3)** : `[Canvas] WS ouverte`, `[Canvas] WS fermée`, `[unlock] gesture detected → unlockAudioOnce()`.
- **RESULT (0)** : aucun log INFO ne marque un résultat succès/échec explicite.
- **API/STRUCT (2)** : `emitGameEvent/emitTimelineEvent` peuvent produire des INFO timeline, mais ici seuls les hooks d’émission sont présents (peu de points d’appel). 

Exemples représentatifs (file:line)
- `bingo_ui.js:318` → `log.info('renderAll: total=', this.others.length);`
- `bingo_ui.js:340` → `log.info('pushMany:done');`
- `bingo_ui.js:441` → `log.info('Overlay affiché (auto-hide 8s)');`
- `bingo_ui.js:717` → `log.info('onPhaseChange', phase);`
- `bingo_ui.js:721-722` → `prepareQuestion` / `renderQuestion`
- `bingo_ui.js:693` → `[bingo] Aucun buffer de notifs ni fallback à rejouer`
- `boot_organizer.js:231/235` → `[Canvas] WS ouverte/fermée ...`
- `boot_organizer.js:981` → `[unlock] gesture detected → unlockAudioOnce()`
- `ws_effects.js:177` → `[WS][bingo] auth_client meta {...}`

Top bruit (INFO à déplacer en DEBUG)
- `renderAll`, `pushMany:done`, `clearAll`, `onAttach`, `onDetach`, `onPhaseChange`, `prepareQuestion`, `renderQuestion`, `auth_client meta`, `unlock gesture`.

## 3) Dédoublonnage observé (redondance 2–3 logs pour une même étape)
1) `bingo_ui.js` (store.pushMany) : `renderAll: total=...` suivi de `pushMany:done` pour chaque rafraîchissement de notif + éventuel `clearAll` → garder 1 INFO (ex: «notifications updated count=X») et basculer le reste en DEBUG.
2) `bingo_ui.js` (cycle question) : `onPhaseChange` + `prepareQuestion` + `renderQuestion` déclenchés en rafale à chaque changement → conserver un seul INFO «phase/question changée (index)», déplacer les deux autres en DEBUG.
3) `boot_organizer.js` (WS lifecycle) : INFO `WS ouverte` + INFO `WS fermée` à chaque reconnexion, plus WARN en cas d’erreur → garder `WS ouverte` en DEBUG, conserver `WS fermée` en WARN/INFO conditionnel (code >=400) pour signaler les coupures significatives.
4) `ws_effects.js` (auth_client meta) : INFO émis à chaque boot Bingo alors que le même contexte est déjà en payload WS → basculer en DEBUG.

## 4) Audit Meta
A) **Logger front (`core/logger.global.js`)**
- Entrée log structure : `{ ts, level, ns?, source:'GAMES', sessionId?, message?, data?[] }`.
- Si `data[0]` est un objet, le logger remonte à la racine : `event`, `api_action`, `request_id`, `transport` (pour Meta côté viewer).
- `sessionId` est rempli automatiquement depuis le DOM (AppConfig/dataset/data-session-id) puis attaché à l’entrée; le champ reste présent dans `data[0]` si fourni par l’appelant.
- Pas de filtrage des clés métiers : tout objet passé en `data[0]` est transmis brut (peut contenir `sessionId`, arrays volumineux, etc.).

B) **Viewer (`web/logs_session.html`)**
- Meta est construite en agrégeant `raw.meta`, `data[0]` (si objet), `ctx/extra`, puis les champs racine non exclus.
- Exclusions du rendu : clés structurelles (`ts*`, level, source, game, msg, data, payload, headers, stack, session_id/sessionId) + sensibles (token/password...).
- Priorités globales (META_PRIORITY) : `op, wsType/ws_type, target, role, state, gameStatus, phase_key/phaseKey, phase_label, phase_index, client_id/clientId, player_id/playerId, grid_id/gridId, team_id/teamId, question_index/questionIndex, currentSongIndex/songIndex, completedLines, progress` (≈8 paires max).
- Source `GAMES` : Meta privilégie `data[0]` avant le reste; `env`/`debug_on` visibles si présents.
- Causes de Meta pauvre/bruitée : `data[0]` absent ou non-plat, tags hétérogènes sans clés métiers, présence de `sessionId`/payloads verbeux (même si le viewer les exclut), messages uniquement textuels sans objet de contexte.

Clés métiers recommandées (front INFO) : `op`, `target`, `role`, `state` ou `gameStatus`, `phase_key`, `client_id`, `player_id`, `grid_id`, `question_index|songIndex`, `completedLines|progress`.

## 5) Recommandations (sans patch)
### Règle globale INFO vs DEBUG
- INFO réservé aux jalons «résultat» ou état stable : connexion établie OK/KO, phase changée (une seule ligne), inscription/join succès/échec, action utilisateur validée. 
- TRANSIENT/TRACE → DEBUG : starts, attempts, renders, prepare/render question, refresh/renderAll, meta de boot/auth, unlock gesture, buffers vides.
- WS lifecycle front (open/close) → DEBUG; garder WARN uniquement quand close code >= 400 ou échec répétitif.

### Règle Meta (front)
- Chaque log INFO doit fournir un objet plat (data[0]) avec au moins : `op`, `target`, `role`, `state|gameStatus`, `phase_key?`, `client_id?`, `player_id?`, `grid_id?`, `question_index|songIndex?`, `progress|completedLines?`; **exclure systématiquement `sessionId/session_id`**.
- Si aucun champ métier pertinent, préférer ne pas logguer en INFO (ou descendre en DEBUG) plutôt que d’envoyer un message texte seul.

### Plan patch minimal (proposition)
1) `bingo_ui.js` : déclasser en DEBUG les logs de rafraîchissement (renderAll/pushMany/clearAll/prepareQuestion/renderQuestion/onPhaseChange/onAttach/onDetach) et remplacer par un unique INFO consolidé «notif_count=X phase=Y question=Z». 
2) `boot_organizer.js` & `ws_effects.js` : basculer `WS ouverte/fermée` et `auth_client meta` en DEBUG (ou INFO conditionnel sur échec), conserver seulement un INFO/WARN sur échec/retry.
3) `logger.global.js` : ajouter un filtre avant envoi pour retirer `sessionId/session_id` du `data[0]` et encourager un schéma `meta` plat avec les clés métier listées ci-dessus.

