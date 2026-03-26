# Repo `games` — Tasks (journal bref)

## PATCH 2026-03-24 — Logs prod cibles reprise player mobile (3 jeux)

### Objectif
- ajouter une preuve `info` exploitable en prod pour confirmer demain qu'une session joueur se reprend correctement apres coupure/background mobile, sans remonter tout le bruit debug lifecycle.

### Correctif livre
- `../games/web/includes/canvas/play/play-ws.js`
  - emission d'un evenement bus `player/ws:resume_ok` uniquement quand un vrai chemin de reprise joueur aboutit (`foreground:*` ou `ws_open_reconnect`);
- `../games/web/includes/canvas/core/logger.global.js`
  - nouvel evenement `PLAYER_SESSION_RESUME_OK` au niveau `info`, avec `{ sid, game, ws_state, reason }`.

### Effet attendu
- les sessions prod des 3 jeux remontent maintenant une preuve front concise quand la reprise joueur est effectivement reussie apres une coupure WS;
- les warnings transport existants (`PLAYER_REREGISTER_FAIL`, `WS_CLIENT_DISCONNECTED`, `WS_HEARTBEAT_TERMINATE`) peuvent ainsi etre recoupes demain avec des preuves positives de reprise, sans repasser la prod en mode debug.

## PATCH 2026-03-24 — Branding: upload visuel perso `games` = fichier original + persistance locale non degradante

### Audit cible prouve
- `games/web/includes/canvas/core/session_modals.js`

### Constat confirme
- le visuel perso etait pretraite cote navigateur avant upload:
  - preview/crop canvas `600x240`
  - reencodage JPEG `0.8`
- le save branding reuploadait ensuite cette version deja degradee au lieu du `File` original;
- le branding local persistant pouvait aussi reimposer plus tard une ancienne `dataURL` custom, d'ou le symptome `net au chargement puis flou`.

### Correctif livre
- la modale conserve maintenant le `File` original (`_visuelFile` / `_logoFile`) uniquement pour le save branding;
- le preview local leger reste utilise pour l'UI organizer, mais n'est plus la source du media envoye;
- le localStorage `games` ne persiste plus les objets `File`;
- au boot, `initSessionModals()` fusionne `window.ServerBranding` et le branding local au lieu d'ecraser la version serveur;
- si une ancienne `dataURL` locale existe encore alors qu'une URL serveur branding est disponible, l'URL serveur reprend la priorite;
- apres save branding reussi, la persistance locale est reecrite avec les URLs serveur finales avant `update_branding`.

### Effet attendu
- le jeu envoie au serveur le media source au lieu d'un preview compresse;
- le rendu branding ne bascule plus d'une image nette vers une ancienne preview floue quelques secondes apres chargement;
- la persistance hors serveur reste intacte pour les couleurs / modes / prefs, mais n'a plus priorite sur un asset branding serveur reel.
- les erreurs d'upload branding remontees par le serveur sont maintenant affichees telles quelles a l'organizer, y compris pour un logo/visuel trop lourd.
- le reset branding organizer ne peut plus desactiver un branding reseau TdR en supprimant la couche effective au lieu de la seule couche session.

## AUDIT #1 — Offer resolution (source of truth) (2026-03-06)

### Existant confirmé
- Appel du garde-fou central `global`:
  - `games/web/organizer_canvas.php:218` -> `app_session_launch_guard_get(...)`
- Fallback aligné resolver central:
  - `games/web/organizer_canvas.php` -> `app_ecommerce_offre_effective_get_context(...)` si `app_session_launch_guard_get` indisponible.
  - suppression du fallback local divergent basé sur `app_ecommerce_offres_client_get_count(...)`.

### TODO Lot 1 (`games`)
- [x] éviter toute divergence entre fallback local et resolver `global` (contrat unique de décision).
- [x] tracer explicitement dans la doc le comportement de repli (guard indisponible).

## AUDIT Réseau / Affiliation / Branding / Contenus partagés (2026-03-06)

### Cartographie confirmée (preuves code)
- Hydratation branding depuis `global` via token de session:
  - `../games/web/organizer_canvas.php:99`
  - `../games/web/organizer_canvas.php:102`
  - `../games/web/player_canvas.php:65`
  - `../games/web/player_canvas.php:68`
  - `../games/web/remote_canvas.php:70`
  - `../games/web/remote_canvas.php:73`
- Application runtime du branding (DOM/CSS):
  - `../games/web/includes/canvas/play/play-ui.js:2262`
  - `../games/web/includes/canvas/play/play-ui.js:2334`
  - `../games/web/includes/canvas/remote/remote-ui.js:5567`
- Diffusion live des updates branding en WS:
  - `../games/web/includes/canvas/play/play-ws.js:960`
  - `../games/web/includes/canvas/remote/remote-ws.js:727`
- Contrôle offre active au lancement organizer:
  - `../games/web/organizer_canvas.php:156`
  - `../games/web/organizer_canvas.php:217`
  - `../games/web/organizer_canvas.php:251`

### Existant confirmé
- Le runtime `games` consomme le branding effectif via API `global_ajax` avec le `token` de session.
- Le branding impacte l’UI organizer/player/remote (couleurs, font, visuels).
- Les updates branding transitent aussi en temps réel par WS (`update_branding`).
- Les contrôles d’accès offre côté organizer existent (hors démo).

### Manques identifiés (scope `games`)
- Pas de logique affiliation réseau dédiée dans ce repo (normal: repo runtime).
- Pas de modèle de contenu réseau propre (le partage de contenus est géré côté `pro`/`global`).

### Risques
- `token` en query string pour l’appel branding (`...&token=`) avec exposition possible dans logs/proxy.
- Dépendance forte au service `global_ajax` pour hydration branding (dégradation visuelle en cas d’indisponibilité).

## PATCH 2026-03-05 — Remote démarrage visuel + fit question longue (quiz papier lot `T`)

### Objectif
- Remote: améliorer le feedback UX entre clic Start et première question/morceau (phase jingle/initialisation).
- Quiz papier: garantir l’affichage complet des questions très longues (lots `T`) dans le bloc question fixe.

### Correctifs appliqués
- `../games/web/includes/canvas/remote/remote-ui.js`
  - état `setAwaitingStart(...)` durci: affichage du mode “démarrage” uniquement quand la partie est réellement en cours (`wsState === 'En cours'` ou `everStarted`),
  - message d’attente enrichi pendant jingle: “Le jeu démarre” + “Le jingle est en cours, la première question arrive.”,
  - pilotage fiable de la visibilité via `hidden` (au lieu de dépendre uniquement de `d-none`).
- `../games/web/remote_canvas.php`
  - ajout du bloc visuel `#waiting-starting-visual` dans la carte waiting (masqué par défaut avec `hidden`).
- `../games/web/includes/canvas/css/remote_styles.css`
  - style de l’état waiting “is-starting” (animation légère),
  - masquage des textes de bienvenue pendant l’initialisation,
  - rendu final du bloc `waiting-starting` transparent (pas de fond/bordure superflus dans une card déjà stylée).
- `../games/web/includes/canvas/core/canvas_display.js`
  - fit du titre question renforcé (`minPx` abaissé + fallback agressif) pour éviter le clipping des très longues questions.
- `../games/web/includes/canvas/core/games/quiz_ui.js`
  - suppression du fit local du titre pour éviter les conflits avec le fit global de `canvas_display.js`.

### Impact
- Avant le 1er Start: la remote reste sur le message de bienvenue standard (pas d’“initialisation” prématurée).
- Après Start, pendant jingle/chargement: état visuel explicite de démarrage, plus lisible.
- En quiz papier, les questions longues restent visibles entièrement dans le cadre fixe (taille texte adaptative).

### Fichiers touchés
- `../games/web/remote_canvas.php`
- `../games/web/includes/canvas/remote/remote-ui.js`
- `../games/web/includes/canvas/css/remote_styles.css`
- `../games/web/includes/canvas/core/canvas_display.js`
- `../games/web/includes/canvas/core/games/quiz_ui.js`

## PATCH 2026-03-20 — Player front logs: restore proof chain before mobile resume debug

### Objectif
- Fiabiliser la preuve `PLAYER_FRONT_BOOT` et la récupération de logs front `player` / `remote` au flush, sans relancer un chantier reconnect/mobile plus large.

### Audit code-first (preuves)
- `../games/web/player_canvas.php`
  - ordre réel de boot confirmé:
    - `@canvas/core/logger_global`
    - `@canvas/play/play-ws`
    - `@canvas/play/play-ui`
    - `@canvas/play/register`
- `../games/web/includes/canvas/core/logger.global.js`
  - `PLAYER_FRONT_BOOT` était émis pendant `tryHookBus()`, donc dès que le logger voyait `window.Bus.on`;
  - cet envoi passait par `emitPlayerFrontProof(...)` -> `Bus.emit('game:ws:send', { type:'log_event' ... })`;
  - mais ce chemin ne bufferisait pas la preuve et dépendait donc d’un listener déjà accroché sur `game:ws:send`.
- `../games/web/includes/canvas/play/play-ws.js`
  - le transport player n’est booté qu’au `Bus.on('player/ready', ...)` via `bootWSConnector(...)`;
  - le listener `Bus.on('game:ws:send', ...)` de transport n’est accroché que dans `ws_connector.js::connect(...)`, donc après ce boot.
- `../games/web/includes/canvas/core/ws_connector.js`
  - quand le listener est présent mais que la socket n’est pas encore `OPEN`, les frames sont bien mises en queue;
  - en revanche, si `game:ws:send` est émis avant que ce listener existe, l’événement Bus est perdu sans replay.
- Conclusion prouvée sur la chaîne actuelle:
  - `PLAYER_FRONT_BOOT` pouvait encore être perdu avant branchement réel du transport `game:ws:send`.
- `../games/web/logs_session.html`
  - le bouton flush ne faisait encore qu’un `localStorage.LOG_FLUSH_REQUEST`;
  - ce mécanisme reste utile pour un onglet local, mais ne couvre pas un player/remote distant.
- Serveurs WS
  - `../../blindtest/web/server/server.js`
  - `../../blindtest/web/server/actions/wsHandler.js`
  - `../../quiz/web/server/server.js`
  - `../../quiz/web/server/actions/wsHandler.js`
  - `../../bingo.game/ws/bingo_server.js`
  - `../../bingo.game/ws/server.js`
  - blindtest/quiz exposaient déjà une chaîne distante `/force_flush` -> broadcast frame `force_flush`;
  - bingo ingérait déjà `log_event/log_batch`, mais n’exposait pas encore d’équivalent HTTP `/force_flush`.

### Cause exacte
- Cause front confirmée:
  - `PLAYER_FRONT_BOOT` partait trop tôt;
  - `emitDirect(...)` ne dépend pas d’un buffer et n’a aucune preuve que le transport Bus->WS est déjà attaché;
  - tant que `play-ws.js` n’a pas booté `ws_connector`, la frame `log_event` de boot peut disparaître.
- Cause remote méta confirmée:
  - le logger n’importe pas directement le `Bus`; il attend `window.Bus` puis accroche ses listeners avec un polling 1s dans `tryHookBus()`;
  - sur `remote`, le `ws/status=open` initial peut donc être émis par `ws_connector.js` avant que `logger.global.js` n’ait réellement accroché `Bus.on('ws/status', ...)`;
  - résultat: le flush distant fonctionne quand même, mais `buildFlushMeta()` peut rester bloqué à `ws_ready_state=unknown` faute d’avoir vu l’événement d’ouverture initial.
- Cause Bingo viewer/proxy confirmée:
  - pas de route serveur `/force_flush`;
  - donc pas de flush distant Bingo équivalent à blindtest/quiz depuis l’outil d’audit.

### Correctif minimal appliqué
- `../games/web/includes/canvas/core/logger.global.js`
  - ajout d’une petite file `pendingProofEntries`;
  - `PLAYER_FRONT_BOOT` est maintenant créé une seule fois puis:
    - envoyé immédiatement si le transport est déjà `OPEN`,
    - sinon mis en attente et rejoué au premier `ws/open` / `ws/status=open`;
  - suppression du risque de doublon:
    - `playerFrontBootLogged` garde l’idempotence côté boot,
    - l’entrée pending est supprimée après premier envoi réussi;
  - les preuves `PLAYER_FRONT_LOG_FLUSH_TRY|OK|FAIL` restent hors buffer, mais sont désormais autorisées aussi pour le rôle `remote` (même nom d’événement, `role` réel dans l’entrée).
  - les marqueurs techniques de diagnostic passent en `debug` dans le viewer:
    - `PLAYER_FRONT_BOOT`
    - `PLAYER_FRONT_LOG_FLUSH_TRY|OK`
    - `PLAYER_WS_LIFECYCLE_DECISION`
    - `WS_CONNECTOR_LIFECYCLE_DECISION`
    - `PLAYER_REREGISTER_TRY|OK`
    - `REGISTER_KEEP_LOCAL_IDENTITY_DESPITE_PROBE_MISS`
  - les échecs restent en niveau haut:
    - `PLAYER_FRONT_LOG_FLUSH_FAIL` -> `warn`
    - `PLAYER_REREGISTER_FAIL` -> `warn`
- `../games/web/includes/canvas/core/ws_connector.js`
  - ajout d’un snapshot runtime partagé `window.__CANVAS_WS_RUNTIME__` mis à jour sur les transitions `connecting`, `opening-auth`, `open`, `closed`, `error`;
  - ce snapshot ne change pas le protocole WS ni le flush; il sert uniquement de mémoire de dernier état transport quand le logger a manqué l’événement Bus initial.
- `../games/web/includes/canvas/core/logger.global.js`
  - hydratation défensive de `wsStatus/wsReadyState/wsUrl` depuis `window.__CANVAS_WS_RUNTIME__` avant `buildFlushMeta()`, `isProofTransportReady()` et à l’accroche tardive `tryHookBus()`;
  - effet attendu:
    - `remote` continue à flusher comme avant,
    - mais `PLAYER_FRONT_LOG_FLUSH_TRY|OK` ne doivent plus remonter avec `ws_ready_state=unknown` sur un transport déjà `open`.
- `../bingo.game/ws/bingo_server.js`
  - ajout d’un broadcast minimal `forceFlushSession(...)`;
  - ajout d’une collecte des sockets par `sid` (organizer, remote, players) via `collectForceFlushTargetsBySid(...)`;
  - ajout du traitement WS `type:"force_flush"` avec logs `FORCE_FLUSH_RX` / `FORCE_FLUSH_BROADCAST`.
- `../bingo.game/ws/server.js`
  - ajout de la route HTTP `GET|POST /force_flush?sid=<sid>`;
  - route alignée sur blindtest/quiz: réponse `{ ok, sid, targets_count }`.
- `../games/web/includes/canvas/php/logs_proxy.php`
  - ajout du proxy `action=force_flush` vers:
    - quiz `http://127.0.0.1:3032/force_flush`
    - blindtest `http://127.0.0.1:3031/force_flush`
    - bingo `http://127.0.0.1:3030/force_flush`
- `../games/web/logs_session.html`
  - le bouton `Forcer flush`:
    - garde le `localStorage.LOG_FLUSH_REQUEST` local comme filet de sécurité;
    - appelle aussi `logs_proxy.php?action=force_flush` pour le flush distant réel.

### Contrat conservé
- Pas d’auto-flush continu en cours de session.
- Flush uniquement:
  - fin de session;
  - demande forcée explicite (`storage` local ou `force_flush` distant).
- Aucun changement organizer sur la stratégie de logs hors cette nouvelle capacité de flush viewer distant.

### Validation attendue
- Blindtest player mobile/distinct:
  - `PLAYER_FRONT_BOOT` présent une seule fois;
  - après `force_flush`: `PLAYER_FRONT_LOG_FLUSH_TRY` puis `PLAYER_FRONT_LOG_FLUSH_OK|FAIL`.
- Bingo player mobile/distinct:
  - même preuve;
  - route exacte: `/force_flush?sid=<sid>` côté `bingo.game/ws/server.js`, relayée par `games/web/includes/canvas/php/logs_proxy.php?action=force_flush`.
- Remote distant:
  - réception de la frame `force_flush`;
  - présence de `PLAYER_FRONT_LOG_FLUSH_TRY` puis `OK|FAIL` avec `role:"remote"` et `ws_ready_state:"open"` si la socket est déjà ouverte.
- Non-régression:
  - pas de double `PLAYER_FRONT_BOOT` sur un boot nominal où le WS ouvre normalement.

### Risques résiduels / next step
- Si la socket n’atteint jamais `OPEN`, `PLAYER_FRONT_BOOT` restera pending et donc non visible côté serveur: c’est un signal utile d’échec transport, pas un faux positif.
- La chaîne doit maintenant être validée en recette réelle mobile/distante, puis seulement servir de base au chantier reconnect/resume.

## PATCH 2026-03-20 — Player mobile resume: single recovery strategy after background

### Objectif
- Rebaseliner proprement la reprise player mobile après arrière-plan, sans reload manuel, sans churn WS et sans duplication de joueur.

### Audit code-first (preuves)
- `../games/web/includes/canvas/core/ws_connector.js` gardait encore un listener `visibilitychange` qui, au retour visible, pouvait fermer une socket `CONNECTING` avec la raison `focus_force_close_connecting`.
- `../games/web/includes/canvas/core/ws_connector.js` appelait bien `window.reRegisterPlayer()` après reconnexion (`waitForReRegisterAndCallIt`), mais le code réel courant de `../games/web/includes/canvas/play/play-ws.js` n’exposait plus cette API globale.
- `../games/web/includes/canvas/play/register.js` conservait déjà localement l’identité joueur quand un probe `players_get` / `bingoPlayerExists` répondait temporairement négatif, mais sans log V1 explicite de décision métier.
- Résultat: deux stratégies concurrentes de reprise subsistaient encore partiellement:
  - transport `ws_connector.js` avec fermeture forcée sur `CONNECTING`;
  - reprise applicative player incomplète / non réexposée côté `play-ws.js`.

### Contrat cible retenu
- Le transport WS reste piloté par `ws_connector.js`.
- Un retour visible ne ferme jamais une socket déjà `CONNECTING`.
- Le player ne relance jamais une 2e machine de reconnexion parallèle.
- Le re-register applicatif player ne se fait que lorsque le transport est réellement `OPEN`.
- En cas de probe de reprise temporairement négatif, l’identité locale est conservée et la reprise WS/API tranche ensuite l’état réel.

### Correctif minimal appliqué
- `../games/web/includes/canvas/play/play-ws.js`
  - réintroduit un point d’entrée unique `window.reRegisterPlayer(reason)` consommé par le connector après reconnect;
  - ajoute des listeners lifecycle player (`visibilitychange`, `pagehide`, `pageshow`) avec décision explicite:
    - `hint_only` si hint background possible,
    - `rereregister_now` uniquement si WS déjà `OPEN`,
    - `defer_to_connector` si transport non prêt / reconnect en cours,
    - `ignore` si évènement non exploitable;
  - garde-fous anti-concurrence sur le re-register applicatif (`reRegisterInFlight` + queue de raison);
  - hint foreground conservé, mais envoyé seulement quand le transport est stabilisé.
- `../games/web/includes/canvas/core/ws_connector.js`
  - suppression de la fermeture forcée d’une socket `CONNECTING` sur retour visible;
  - au retour visible:
    - `ignore` si socket déjà `OPEN`,
    - `defer_to_connector` si socket `CONNECTING`,
    - accélération de la reconnexion transport existante si socket non ouverte, sans lancer une machine parallèle;
  - passage d’une raison de reprise différée (`window.__PLAYER_PENDING_REREGISTER_REASON__`) au `reRegisterPlayer()` appelé après `ws/open`.
- `../games/web/includes/canvas/core/logger.global.js`
  - conserve les logs existants `PLAYER_FOREGROUND_HINT_SENT`, `PLAYER_REREGISTER_TRY`, `PLAYER_REREGISTER_OK`, `PLAYER_REREGISTER_FAIL`;
  - ajoute des logs V1 décisionnels:
    - `PLAYER_WS_LIFECYCLE_DECISION`
    - `WS_CONNECTOR_LIFECYCLE_DECISION`
    - `REGISTER_KEEP_LOCAL_IDENTITY_DESPITE_PROBE_MISS`
  - méta portée: `{source, document_hidden, ws_state|readyState, reconnect_in_progress, decision, reason}`.
- `../games/web/includes/canvas/play/register.js`
  - conservation de la règle “keep local identity on probe miss”;
  - ajout d’un log métier structuré quand on choisit explicitement `keep_local_identity_despite_probe_miss` sur `players_get` ou `bingoPlayerExists`.

### Impact
- Une seule stratégie de reprise survit:
  - lifecycle player = hint/re-register applicatif,
  - connector = reconnexion transport,
  - pas de `close()` forcé concurrent sur `CONNECTING`.
- Après retour foreground:
  - si WS déjà `OPEN`, le player rejoue immédiatement son handshake applicatif sans reload manuel;
  - sinon, le player délègue au connector; le connector reconnecte puis appelle `window.reRegisterPlayer(...)` après `ws/open`.
- Les probes négatifs transitoires ne suffisent plus à faire perdre le `player_id` local sans trace explicite.

### Validation réalisée
- Vérification statique du code sur les 3 jeux `quiz` / `blindtest` / `bingo` via les surfaces partagées `play-ws.js`, `register.js`, `ws_connector.js`, `logger.global.js`.
- Parcours couverts par lecture de code et instrumentation:
  - retour court arrière-plan: foreground avec WS `OPEN` -> `PLAYER_WS_LIFECYCLE_DECISION decision=rereregister_now` puis `PLAYER_REREGISTER_OK`;
  - retour long arrière-plan: foreground avec WS non ouverte -> `PLAYER_WS_LIFECYCLE_DECISION decision=defer_to_connector`, puis `WS_CONNECTOR_LIFECYCLE_DECISION decision=defer_to_connector`, reconnexion transport et re-register post-open;
  - retour pendant `CONNECTING`: plus aucun `focus_force_close_connecting`; décision = délégation au connector;
  - probe négatif transitoire: `REGISTER_KEEP_LOCAL_IDENTITY_DESPITE_PROBE_MISS`.

### Limites / next step
- Validation mobile réelle non exécutée dans cette tâche; la preuve disponible ici est un audit code-first + instrumentation front renforcée.
- Si un incident persiste, la prochaine lecture doit corréler:
  - `PLAYER_WS_LIFECYCLE_DECISION`
  - `WS_CONNECTOR_LIFECYCLE_DECISION`
  - `PLAYER_REREGISTER_*`
  - `REGISTER_KEEP_LOCAL_IDENTITY_DESPITE_PROBE_MISS`

## PATCH 2026-03-04 — Quiz hydration lot `L`: ordre sur `position` puis fallback `id`

### Objectif
- Aligner l’ordre de questions consommé côté app `games` avec l’ordre métier défini en bibliothèque (`questions.position`), tout en conservant un fallback stable quand `position` est absente/identique.

### Correctif minimal appliqué
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`:
  - lot `L`: tri SQL passé de `ORDER BY q.id ASC` à `ORDER BY q.position ASC, q.id ASC`.

### Impact
- Si `position` est correctement renseignée: affichage des questions selon cet ordre.
- Si `position` vaut `0` partout ou est identique: fallback naturel sur `q.id ASC`.

### Fichier touché
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`

## Audit croisé 2026-03-04 — Contrôle des liens YouTube (patch porté par `pro`)

### Objectif
- Vérifier si `games` devait porter une logique métier de contrôle des liens YouTube pour la V1 admin.

### Résultat
- Audit README/TASKS `games` + code `global`/`pro` conclut que la V1 doit être portée côté admin `pro` (scan offline), sans patch runtime `games`.
- Aucun fichier du repo `games` modifié dans ce patch.

### Impact
- `non trouvé dans la documentation` pour un `canon/repos/games/HANDOFF.md` public (URL fournie retourne 404 au moment de l’audit).
- Suivi documentaire maintenu ici (`TASKS.md`) en l’absence de handoff repo `games`.

## Google Drive support semantics soft-timeout after render (2026-02-27)

### Objectif
- Appliquer une sémantique explicite Drive:
  - `drive-timeout` bloquant si aucun rendu réussi,
  - `drive-timeout` non bloquant si le support a déjà été rendu/visible.

### Audit complémentaire
- Point central confirmé: `../games/web/includes/canvas/core/player/index.js::displaySupport(...)` (branche Drive unique pour tous les types Drive supportés).
- Propagation observability confirmée:
  - erreur -> `emitSupportEvent('SUPPORT_START_FAIL_DETAIL')` -> bus `support/error` -> `SUPPORT_ERROR` logger.
  - état prêt UI -> bus `support/started` avec `reason` consommé par `canvas_display.js` (`READY_OK`).

### Correctif minimal appliqué
- `../games/web/includes/canvas/core/player/index.js`:
  - `endLoadingForToken(...)` accepte maintenant une dissociation:
    - `errorReason` (observability/log),
    - `startedReason` (raison fonctionnelle UI).
  - branche Drive:
    - ajout flag `driveHasRenderedSuccessfully`,
    - ajout heuristique `hasLikelyDriveRendered(iframe)` (navigation effective/cross-origin) pour couvrir le cas rendu visible sans signal strict de readiness,
    - timeout final:
      - avant rendu: `drive-timeout-before-render` (bloquant),
      - après rendu: `drive-timeout-after-render` loggé en soft error, mais `support/started` émis avec `reason='drive-ready'` pour préserver l’affichage.

### Impact attendu
- Cas Drive “jamais affiché” inchangé (erreur bloquante/fallback possible).
- Cas Drive “affiché puis timeout” conservé en UI (dégradé observé, sans masquage).
- Supports non-Drive inchangés.

### Fichier touché
- `../games/web/includes/canvas/core/player/index.js`

## Audit supports Google Drive (multi-types) + patch timeout UI (2026-02-27)

### Objectif
- Auditer la prise en charge Google Drive sur le pipeline support front (pas seulement image) et corriger la disparition visuelle observée avec `reason=drive-timeout`.

### Résultat d’audit (code-first)
- Pipeline support commun localisé dans `../games/web/includes/canvas/core/player/index.js::displaySupport(...)`.
- Détection Drive centralisée via `getDirectGoogleDriveUrl(...)`, exécutée avant les branches media directes (image/audio/vidéo).
- `drive-timeout` est émis via `endLoadingForToken(...)` -> event bus `support/error` -> logger `SUPPORT_ERROR`.
- Les événements `start_support` / `support_ended` sont relayés via `../games/web/includes/canvas/core/ws_effects.js` (handlers WS + émission organizer).
- Constat: le retry Drive rechargeait l’`iframe` (`src` modifié) au premier timeout, ce qui pouvait effacer un support déjà partiellement affiché avant `drive-timeout`.

### Correctif minimal appliqué
- `../games/web/includes/canvas/core/player/index.js`:
  - durcissement de la reconnaissance Drive:
    - host strict `drive.google.com` / `docs.google.com`,
    - extraction id par `/d/<id>` ou `?id=<id>`,
    - normalisation vers `https://drive.google.com/file/d/<id>/preview`.
  - stratégie timeout Drive ajustée:
    - suppression du retry “hard reload” de l’`iframe` (plus de changement de `src` au premier timeout),
    - conservation d’une fenêtre de grâce unique avant `drive-timeout`.

### Impact attendu
- Réduction des cas “support visible puis disparu” sur Drive lent.
- `drive-timeout` reste possible si le support n’est pas prêt après la fenêtre de grâce.
- Pas de changement de pipeline pour les supports non-Drive.

### Fichier touché
- `../games/web/includes/canvas/core/player/index.js`

## Contrôle offre active — accès master organizer (2026-02-25)

### Objectif
- Bloquer l’accès direct organizer/master par token de session si le client n’a pas d’offre active.
- Exempter strictement les sessions démo.

### Implémentation
- Détection démo canonique:
  - source-of-truth: `championnats_sessions.flag_session_demo` (exposé aussi en `serverSessionMeta.isDemo`).
- Point de contrôle hydratation organizer:
  - `web/organizer_canvas.php` applique le contrôle dès le chargement session/client,
  - réutilisation prioritaire de la logique existante `app_session_launch_guard_get($id_session)`,
  - fallback local aligné sur la même règle si la fonction n’est pas dispo dans le contexte.
- Règle:
  - session démo -> accès autorisé sans contrôle offre,
  - session non-démo -> offre active requise, sinon blocage 403 + écran avec CTA offres.
- CTA offres organizer:
  - normalisation sur le sous-domaine `pro` (`$CONF_PRO_URL`),
  - conservation du suffixe contextuel renvoyé par le guard (`/extranet/ecommerce/offers/...`) quand présent,
  - fallback sur `/extranet/ecommerce/offers` si URL absente/non conforme.
- Anti-bypass bridge (organizer actions):
  - `2026-03-05`: ce guard a été retiré de `web/games_ajax.php` (plus de contrôle offre sur les writes Canvas),
  - cause: incident prod sur writes (`session_update`) avec `403 offer_inactive` et `details.reason=INTERNAL_ERROR`,
  - décision: contrôle d’offre conservé uniquement au point d’entrée organizer (`web/organizer_canvas.php`) pour le blocage d’accès/lancement.
- Logs structurés ajoutés:
  - `SESSION_ACCESS_OFFER_CHECK {session_id,client_id,game,is_demo,offer_ok,role=master}`
  - `SESSION_ACCESS_DENIED_OFFER_INACTIVE`

### Fichiers touchés
- `../games/web/organizer_canvas.php`
- `../games/web/games_ajax.php`

## Quiz — garde-fou bascule Papier -> Numérique (2026-02-25)

### Objectif
- Autoriser la bascule papier -> numérique uniquement avant démarrage, et seulement si toutes les questions de toutes les séries du quiz sont prêtes pour le numérique.

### Correctifs appliqués
- Hydratation quiz (`quiz_adapter_glue.php`):
  - calcul serveur `digitalSwitchAllowed`, `digitalSwitchInvalidCount`, `digitalSwitchReason`, `digitalSwitchMessage` injectés dans `preload.session` et `serverSessionMeta`,
  - périmètre contrôle = toutes les questions de toutes les séries (`lot_ids` complet, incluant lots temporaires `T*`).
- Règle “question OK pour numérique” (serveur):
  - réponse non vide,
  - au moins 2 fausses propositions non vides, distinctes de la bonne réponse.
- UI organizer (`session_modals.js`):
  - blocage de la bascule vers Numérique si `digitalSwitchAllowed=false` avec message explicite,
  - verrouillage du toggle papier/numérique si session démarrée (tooltip/message “Modifiable avant le démarrage”).
- Anti-bypass serveur (`qz_session_update`):
  - sur tentative papier->numérique (`flag_controle_numerique: 0 -> 1`), revalidation serveur complète,
  - refus si session démarrée ou propositions manquantes avec code `PAPER_TO_DIGITAL_BLOCKED_MISSING_PROPOSALS`,
  - logs structurés:
    - `QUIZ_PAPER_TO_DIGITAL_CHECK`
    - `QUIZ_PAPER_TO_DIGITAL_BLOCKED`
    - `QUIZ_PAPER_TO_DIGITAL_OK`.
- Bridge HTTP (`games_ajax.php`):
  - mapping HTTP 400 ajouté pour `paper_to_digital_blocked_missing_proposals`.

### Fichiers touchés
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/core/session_modals.js`
- `../games/web/games_ajax.php`

## Support startup + remote hydration fixes (2026-02-13)

### Objectif
- Réduire les faux échecs de démarrage support (`img-timeout` / `drive-timeout`) et fiabiliser l’hydratation remote en mode manuel.

### Correctifs appliqués
- `core/player/index.js`:
  - timeouts support rendus adaptatifs selon qualité réseau (`drive/image`: 15s nominal, 20s connexion lente),
  - retry unique pour `drive` et `image` avant `SUPPORT_ERROR`,
  - timers trackés puis annulés systématiquement au `load`/`error`,
  - `SUPPORT_START_FAIL_DETAIL` enrichi (`support_kind`, `timeout_ms`, `retry_count`) et `stale_token` ajouté pour distinguer les timeouts obsolètes.
- `core/session_sync.js`:
  - `playlistSongs` est renvoyé non seulement à l’initialisation, mais aussi au premier moment où la playlist devient non vide (`didPlaylistSync`), pour corriger la non-hydratation remote tardive.
- `remote/remote-ui.js`:
  - après `remote/sessionInfos` avec changement `paperMode`, recalcul immédiat `applyManualModeUI()` pour éviter un état manuel évalué sur un `SESSION_PAPER` obsolète (bouton support manquant).

### Fichiers touchés
- `../games/web/includes/canvas/core/player/index.js`
- `../games/web/includes/canvas/core/session_sync.js`
- `../games/web/includes/canvas/remote/remote-ui.js`

## Terminated Static Mode (2026-02-11)

### Objectif
- Si `window.Preload` indique une session terminée, ne pas ouvrir de WebSocket côté front (`organizer`, `remote`, `player` si preload dispo) et afficher l’état final depuis preload.

### Implémentation
- Garde preload terminée ajoutée dans:
  - `../games/web/includes/canvas/core/ws_effects.js`
  - `../games/web/includes/canvas/remote/remote-ws.js`
  - `../games/web/includes/canvas/play/play-ws.js`
- En mode statique:
  - pas de boot WS
  - pas d’envoi `registerOrganizer` / `remoteGameState` / `auth_*` / `registerPlayer`
  - `remote` émet l’état final local depuis preload (`remote/state`, `remote/end`, `remote/players:update` et winners bingo preload)
  - `organizer` hydrate aussi les scores/joueurs depuis preload (plus dépendance WS pour l’écran final)
- Bascule live -> static:
  - à réception WS `endGame`, passage en mode static + reload HTTP (`location.replace` avec `_tsm=*`) pour recharger un preload terminal.

### Preload attendu côté front
- quiz/blindtest:
  - `preload.session.isTerminated` (bool)
  - `preload.isTerminated` (bool)
  - `preload.players.players[]` (déjà présent)
- bingo:
  - `preload.session.isTerminated` (bool)
  - `preload.isTerminated` (bool)
  - `preload.players.players[]` (ajouté pour réhydrater organizer en mode terminal)
  - `preload.phase_winners[]` (phase winners ordonnés)

### Fichiers touchés (code)
- `../games/web/includes/canvas/core/ws_effects.js`
- `../games/web/includes/canvas/core/boot_organizer.js`
- `../games/web/includes/canvas/remote/remote-ws.js`
- `../games/web/includes/canvas/remote/remote-ui.js`
- `../games/web/includes/canvas/play/play-ws.js`
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`

### Correctif bingo reload terminé (2026-02-11)
- Symptôme observé: après `endGame` en live, l’UI organizer bingo affichait bien joueurs + gagnants; après refresh/reload, liste vide et podium fallback.
- Cause racine confirmée: `ws_effects.js` coupe le WS en mode preload terminé, mais `bingo_resolve_token` n’injectait pas `preload.players` (contrairement à quiz/blindtest).
- Correctif appliqué: `bingo_resolve_token` injecte désormais `players` (shape compat `{ players: [...] }`) via lecture DB (`bingo_api_players_get`) en plus de `phase_winners`.

### Ajustement UX live endGame (2026-02-11)
- Constat: bascule statique immédiate à réception WS `endGame` trop agressive pour l’écran de fin live (organizer/remote/player).
- Nouveau comportement:
  - à `endGame`, on marque une fenêtre de grâce WS de 20 min en `sessionStorage` (clé session-scoped),
  - on ne force plus de reload `_tsm` immédiat,
  - au boot/reload, si preload est "Partie terminée" mais grâce active, la connexion WS reste autorisée.
- Portée:
  - organizer: `../games/web/includes/canvas/core/ws_effects.js`
  - remote: `../games/web/includes/canvas/remote/remote-ws.js`
  - player: `../games/web/includes/canvas/play/play-ws.js`

### Correctif Bingo play reload gagnant (2026-02-11)
- Symptôme: en fin de partie Bingo, un joueur gagnant voyait bien le message/lot en live, mais après reload retombait sur un écran "non gagnant".
- Correctif: persistance de `bingo_best_phase` en clé session-scoped (`bingo_best_phase:<sessionId>`) avec fallback legacy global.
- Effet: l’écran de fin joueur recharge correctement la meilleure phase gagnée et le lot associé depuis `window.AppSessionLots`.
- Fichier: `../games/web/includes/canvas/play/play-ui.js`

## Audit remote paper register (2026-02-12)

### Objectif
- Garantir la compatibilité migrations `player_id` (UPSERT/UNIQUE) pour l’ajout joueur depuis remote (session papier), sans doublon et idempotent au retry.

### Résultat
- Gap confirmé avant patch:
  - `remote-ui.js` envoyait `player_register` sans `event_id`.
  - `player_id` était généré en format non canonique (`remote:*`) et non persistant.
- Correctif appliqué:
  - `player_id` canonique (`p:<uuid>`) généré/persisté en localStorage, scope `game + session + username normalisé`.
  - `event_id` UUID généré/persisté par tentative d’inscription, réutilisé au retry tant que la tentative n’est pas confirmée.
  - purge de la tentative pending uniquement après succès `player_register`.
  - payload `player_register` key-first sur les 3 jeux: `username`, `player_id`, `event_id`, puis `sessionId` (bingo) ou `sessionPrimaryId` (quiz/blindtest).
  - `playerId` numérique reste optionnel (uniquement retour serveur / compat), pas utilisé comme identité canonique.
  - actions remote joueur/phase harmonisées (`admin_player_register`, `admin_set_score`, `admin_phase_winner`, `admin_phase_fail`): envoi `event_id` + `player_id` canonique quand disponible, `playerId` numérique en compat.
  - listing remote quiz/blindtest dédupliqué key-first (`player_id` canonique prioritaire, fallback numérique) pour éviter les doubles entrées visuelles sur snapshots mixtes.
  - exception Bingo validée (session papier animateur): `admin_phase_winner` sans joueur est autorisé côté WS (`bingo_server.js`) et déclenche un avancement manuel de phase sans write `phase_winner` DB.
  - organizer Bingo: `phase_over` exploite `won_phase` en source de vérité (fallback `next_phase` conservé), ce qui corrige le décalage d’annonce de phase gagnée en mode manuel.
  - mode manuel Bingo sans joueur: calcul de `next_phase` aligné sur la phase explicitement validée par l’admin (si présente dans `phases_liste`), et notifs victoire rétablies en `PlayerWin` (format historique, plus de `"... validée manuellement"`).
  - fallback podium Bingo harmonisé (orga + remote): sans gagnants hydratés, rendu `Joueur inconnu` par phase (Bingo / Double ligne / Ligne), sans fallback classement par score.
  - liste joueurs remote Bingo fin de session: protection contre écrasement par snapshots vides post-`endGame` + fallback `players_get` si nécessaire.
  - quiz/blindtest hydratation alignée: `players_get` et preload `players` exposent désormais `player_id` canonique (et `updated_at` si présent), avec fallback legacy safe si colonne absente (introspection schéma).
  - effet: les hydrations WS quiz/blindtest qui dédupliquent key-first sur `player_id` ne perdent plus de lignes valides quand la DB contient des identités canoniques.
  - sessions terminées: `players_get` supporte `includeInactive` (quiz/blindtest/bingo) pour récupérer aussi les participants déconnectés/inactifs, afin de conserver un classement final cohérent avec la participation réelle.
  - WS quiz/blindtest: à la reconnexion orga d’une session terminée, hydratation DB forcée (incluant inactifs), invalidation du snapshot final en mémoire, puis reconstruction/renvoi `endGame` depuis l’état hydraté.
  - WS bingo: hydratation DB au login orga (`auth_client`) passe désormais `includeInactive=true` quand la phase est terminale (`current_phase=-1`), pour réaligner le snapshot joueurs avec l’historique de participation.

### Fichier touché
- `../games/web/includes/canvas/remote/remote-ui.js`
- `../bingo.game/ws/bingo_server.js`
- `../games/web/includes/canvas/core/ws_effects.js`
- `../games/web/includes/canvas/core/games/bingo_ui.js`
- `../games/web/includes/canvas/core/canvas_display.js`
- `../games/web/includes/canvas/remote/remote-ws.js`
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
- `../quiz/web/server/actions/registration.js`
- `../blindtest/web/server/actions/registration.js`
- `../bingo.game/ws/bingo_server.js`

## Bingo lots regression fix (2026-02-12)

### Objectif
- Éviter la disparition du bloc “lots à gagner” côté player Bingo quand l’organizer modifie des options en phase d’attente (ex: `songDuration`).

### Correctif appliqué
- `ws_effects.js`: `options/updated` ne pousse plus systématiquement `update_session_infos`; envoi limité aux changements de contrôle de session (`paperMode`, et `manualAdvance` pour quiz).
- Effet attendu: un changement d’option gameplay (`songDuration`) ne déclenche plus de diffusion `sessionInfos` inutile.

### Fichiers touchés
- `../games/web/includes/canvas/core/ws_effects.js`

## Logs viewer chips sync fix (2026-02-12)

### Objectif
- Éliminer l’écart temporaire entre chips globales (`total/debug/info/warn/error`) et tableau après flush front (`log_batch`), tout en conservant des chips basées sur l’ensemble des logs.

### Correctif appliqué
- `logs_proxy.php`: ajout du paramètre `force=1` pour bypass cache sur `stats=1`.
- `logs_session.html`: requête stats passée en `stats=1&force=1` pour recalcul global immédiat.
- `visibles` reste inchangé (toujours calculé côté client sur les entrées chargées).

### Fichiers touchés
- `../games/web/includes/canvas/php/logs_proxy.php`
- `../games/web/logs_session.html`

## Bingo phase winners canonical key migration (2026-02-12)

### Objectif
- Finaliser la migration identity key-first pour les gagnants de phase Bingo, tout en restant compatible avec le schéma legacy (`player_id` numérique) durant la transition.

### Correctif appliqué
- `bingo_api_phase_winner` résout désormais l’identité gagnant via `_bingo_resolve_identity` (source de vérité: `player_id` canonique), puis persiste l’ID DB legacy pour compat table.
- Ajout du code d’erreur explicite `error=phase_winner_conflict` sur conflit inter-joueurs d’une même phase (en plus de `reason`).
- Lecture winners (`_bingo_fetch_phase_winners`) basculée key-first:
  - priorise `bingo_phase_winners.player_id_key` si la colonne existe,
  - fallback sur jointure `bingo_players` sinon.
- Écriture winners rétrocompatible:
  - si `player_id_key` existe, insertion `(session_id, phase, player_id, player_id_key, event_id)`,
  - sinon insertion legacy `(session_id, phase, player_id, event_id)`.
- Correctif post-migration: résolution d’une ambiguïté SQL `session_id/phase` dans la requête de conflit (`WHERE w.session_id = :sid AND w.phase = :phase`).

### Migration DB ajoutée
- Nouveau script idempotent:
  - `../games/web/includes/canvas/sql/2026-02-12_bingo_phase_winners_player_id_key.sql`
- Contenu:
  - ajoute `player_id_key VARCHAR(64) NULL` si absente,
  - backfill depuis `bingo_players` via relation legacy (`session_id + id`),
  - ajoute index `idx_bpw_session_phase_player_key`,
  - post-check `missing_player_id_key`.

### Fichiers touchés
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
- `../games/web/includes/canvas/sql/2026-02-12_bingo_phase_winners_player_id_key.sql`

## AUDIT data results (DB reads): current pipeline (2026-02-11)

### Scope audité
- Données: players (identité), scores, podium/leaderboard final (quiz/blindtest), winners de phase bingo.
- Front surfaces: organizer, remote, player register.
- Contraintes: audit only, zéro patch runtime.

### Call-sites front qui lisent DB (résultats)
- `../games/web/includes/canvas/play/register.js:835` -> `session_primary_id` (HTTP bridge) pour résoudre `sessionPrimaryId` avant contrôle d’existence joueur.
- `../games/web/includes/canvas/play/register.js:845` -> `players_get { sessionPrimaryId }` (quiz/blindtest), utilisé en auto-resume (`playerExistsInSession`), retourne `players[]` avec score.
- `../games/web/includes/canvas/play/register.js:861` -> `players_get { sessionId }` (bingo), utilisé en auto-resume (`bingoPlayerExists`), retourne `players[]`.
- `../games/web/includes/canvas/remote/remote-ui.js:417` -> `session_primary_id` (HTTP bridge), prérequis pour read joueurs côté remote.
- `../games/web/includes/canvas/remote/remote-ui.js:3211` -> `players_get { sessionId }` (bingo) via `fetchPlayersSnapshot()`.
- `../games/web/includes/canvas/remote/remote-ui.js:3215` -> `players_get { sessionPrimaryId }` (quiz/blindtest) via `fetchPlayersSnapshot()`.
- `../games/web/includes/canvas/remote/remote-ui.js:3260` -> `fetchPlayersSnapshot()` appelé après `player_register` remote (rafraîchissement manuel liste joueurs).
- `../games/web/organizer_canvas.php:51` + `../games/web/remote_canvas.php:50` -> preload HTTP serveur (`build_preload_for_game`) injecté dans `window.Preload` (lecture DB au rendu page, sans fetch JS direct).

### Reads DB preload (HTTP direct, page load)
- Quiz: `../games/web/includes/canvas/php/quiz_adapter_glue.php:508` lit état session + players (`_qz_fetch_players`) et injecte `preload.players` (`...:539`, `...:564`).
- Blindtest: `../games/web/includes/canvas/php/blindtest_adapter_glue.php:396` lit état session + players (`_bt_fetch_players`) et injecte `preload.players` (`...:427`, `...:455`).
- Bingo: `../games/web/includes/canvas/php/bingo_adapter_glue.php:134` lit état session + playlist uniquement; pas de `preload.players/podium/winners` (`...:173-182`).

### Pipeline par jeu (constat actuel)
| Donnée | Quiz | Blindtest | Bingo |
| --- | --- | --- | --- |
| Players | Mix preload HTTP (`quiz_resolve_token`) + WS (`gameState/sessionUpdate/updatePlayers/endGame`) + read HTTP ponctuel (`players_get`) pour register/remote add-player | Mix preload HTTP (`blindtest_resolve_token`) + WS (`gameState/sessionUpdate/updatePlayers/endGame`) + read HTTP ponctuel (`players_get`) pour register/remote add-player | WS snapshot principal (`state`, `num_connected_players`) + read HTTP ponctuel `players_get` (register/remote add-player). Preload bingo ne contient pas players |
| Scores | Transportés dans `players` (preload quiz/bt + WS). Pas de read `session_get` dédié trouvé côté front | Idem quiz | Pas de score podium final dédié côté front; leaderboard bingo affiché surtout via players + winners mémoire |
| Podium / leaderboard final | Affiché depuis WS `endGame` (`m.podium` sinon `m.players`) `remote-ui.js:4822`; fallback tri front dans `renderEndPodium` `...:2812-2824` | Idem quiz | Podium construit depuis map `bingoWinners` mémoire (`remote-ui.js:2767`, `...:2845`), pas de read DB winners dédié |
| Winners phase | N/A | N/A | Reçus en live via WS `phase_over` (`remote-ws.js:709`) ou notifications WS parsées (`remote-ws.js:657-677`), stockés en mémoire (`remote-ui.js:4621-4635`) |
| Qui calcule | WS calcule et pousse; front peut retraiter/ordonner podium pour rendu (`remote-ui.js:2818`) | WS calcule et pousse; front peut retraiter/ordonner podium pour rendu | Front remote reconstruit podium depuis winners mémoire; organizer render peut fallback depuis store/players (`canvas_display.js:1177-1250`) |

### Focus reload session terminée
- Organizer: hydrate preload sans players (`boot_organizer.js:383-391`, `...:463-476`), puis attend WS pour résultats (`ws_effects.js:450-467`, `...:563-635`).
- Remote quiz/blindtest: peut afficher players preload immédiat (`remote-ui.js:231`, `...:458-464`), puis WS `remoteGameState` (`remote-ws.js:299`, `...:515-560`) et/ou `endGame` (`...:601-607`) pilote le rendu final.
- Remote bingo: pas de preload winners/podium; rendu fin dépend des messages WS reçus (`state/phase_over/notifications`). Aucun read front de `bingo_phase_winners` trouvé.

### Réponses factuelles demandées
- Quiz, reload terminé: rendu résultats vient principalement du snapshot WS (`endGame`), avec fallback visuel possible sur players preload/WS.
- Blindtest, reload terminé: idem quiz.
- Bingo, reload terminé: rendu résultats vient du snapshot WS `state` + événements live winners; pas de fetch HTTP front dédié winners.

### Gaps identifiés (sans patch)
- Aucun call-site front trouvé pour lire un podium DB stocké (`podium_json`) au reload.
- Aucun call-site front trouvé pour lire `bingo_phase_winners` (ni action read dédiée winners).
- Fallback `remote/state` en “Partie terminée” côté quiz/blindtest attend `m.podium/m.players` (`remote-ui.js:4716-4720`), alors que `remote-ws.js` n’injecte pas ces champs dans l’event `remote/state` (`remote-ws.js:520`, `...:542`).

- 2026-02-11 — code+doc — Patch 5 front identity persistence (bingo/blindtest/quiz): helper session-scoped `getOrCreatePlayerId({game,sid})` + migration legacy (`${game}:player_stable_id`, `${game}:player_id`, `player_id`) + logs `PLAYER_ID_STORAGE_RESOLVED {game,sid,source}`; wiring `register.js` + `play-ws.js` pour stabilité reload/changement d’onglet, et comportement attendu après suppression de clé scoped (nouvel ID généré au prochain register/auth de session).
- 2026-02-11 — code+doc — WS player registration canon strict: `play-ws.js` envoie désormais `registerPlayer { sessionId, player_id, playerId? (db) }` pour quiz/blindtest, envoie aussi `player_id` canon sur `auth_player` / `auth_player_paper` Bingo, et passe `checkAnswer` en `player_id` (plus de dépendance protocolaire au champ legacy `playerId` comme identifiant canon).
- 2026-02-11 — bugfix bingo/front — `player_register` ne part plus jamais avec un `player_id` numérique: normalisation stricte pré-appel (`preparePlayerIdPreRegister`) vers `p:<uuid>`, migration douce legacy (`player_id` numeric -> `player_db_id`), et log debug `PLAYER_ID_PRE_REGISTER` `{sessionId,pid_sent,pid_source,legacy_db_id_if_any}`.
- 2026-02-11 — code+doc — Player replacement UX (last connection wins): `play-ws.js` gère `SESSION_REPLACED` (mode read-only, blocage des envois WS, API `resumeAfterReplacement`), `ws_connector.js` stoppe la reconnexion auto après close code `4005` (`__WS_SUPPRESS_RECONNECT__` + event `ws/session_replaced`), `play-ui.js` affiche une bannière persistante + toast + bouton “Reprendre ici” (reload), force `Pause`, stoppe timers/reveal, et désactive réponses/grille locale (quiz/blindtest/bingo côté front commun).
- 2026-02-11 — code+doc — Register/identity front session-scoped (quiz/blindtest/bingo): `play/register.js` utilise `${slug}:player_stable_id:${sessionId}` comme source de vérité du `player_id` canonique (`p:<uuid>`), conserve `${slug}:player_stable_id` en compat legacy (migration douce si `keySid` match), et sépare désormais `player_id` (stable) de `player_db_id` (numérique legacy). Bingo envoie explicitement `player_id` sur `player_register/grid_assign/grid_hydrate/grid_cells_sync`, persiste `grid_id` aussi en clé session-scoped `${slug}:grid_id:${sessionId}`, et n’utilise plus la clé globale legacy comme vérité. Instrumentation debug `register/debug` maintenue (`*_tx`, `*_ok`, `*_fail`) avec `{sessionId, stable_key, player_id, player_id_origin, username}`.
- 2026-02-10 — code+doc — Patch Point 1 “event_id partout” (mode progressif, non-bloquant): `games_ajax.php` introduit une liste centrale d’actions mutatrices + helper `getOrCreateEventId` (UUID v4 serveur si absent/invalide), logs `EVENT_ID_RX` (info bridge) et warning structuré `MISSING_EVENT_ID`; idempotence `game_events` activée pour ces actions même sans `event_id` client initial. Front `canvasCall` injecte `event_id` pour actions mutatrices; `play/register.js` et `play/play-ui.js` propagent aussi `event_id` (`player_register`, `grid_assign`, `deactivate_player`). Compat maintenue: aucune requête rejetée pour `event_id` manquant.
- 2026-02-09 — code+doc — Reveal player key-first: `play-ws.js` consomme `answerReveal`; `play-ui.js` applique désormais le reveal par `data-option-key` (`applyRevealByKey`) avec fallback legacy texte/index, et émet les logs v1 debug `PLAYER_REVEAL_RX` / `PLAYER_REVEAL_APPLY` via `logger.global.js`.
- 2026-02-10 — audit+doc — Audit transversal `event_id + *_players` (`games_ajax.php`, `includes/canvas/php/*`, `play/*`, WS repos): confirmation que l’idempotence bridge dépend strictement de la présence de `event_id`; writes WS via `canvasWrite` injectent `event_id`, mais plusieurs writes front/organizer restent sans `event_id` (`player_register`, `deactivate_player`, `grid_assign`, `resetdemo`, `prizes_save`). Côté `*_players`, rôle observé = registre de participation/session + `is_active` partiel (déconnexion involontaire souvent mémoire seulement). Rapports: `notes/audit-event-id-players-2026-02-10.md` + `notes/audit-bingo-player-register-reinscription-2026-02-10.md`.
- 2026-02-09 — code+doc — Bots answer payload durci (`games/web/test_bots.php`): sélection désormais par objet option (et non par texte), envoi WS explicite `selectedOption=opt.raw` + `selectedOptionKey=opt.key` quand disponible; fallback texte conservé seulement si options legacy sans objet.
- 2026-02-09 — code+doc — Bots submit key compat: correction du payload `checkAnswer` dans `games/web/test_bots.php` (virgule manquante entre `selectedOption` et `selectedOptionKey`) pour éviter les envois sans clé menant à `PLAYER_ANSWER_EVAL method=\"legacy\"`.
- 2026-02-09 — code+doc — Player answers compat key-first: `play-ui.js` expose désormais `data-option-key=<option.key>` (si disponible) et `play-ws.js` envoie `checkAnswer { selectedOption, selectedOptionKey }` en conservant `selectedOption` pour compat legacy WS.
- 2026-02-09 — code+doc — Remote options jingle fix: `remote-ws.js` ne gate plus le refresh des propositions sur le seul changement d’index logique (cas jingle→round1, index logique inchangé), applique aussi les updates via `remote_sync` / `GAME_OPTIONS_UPDATED` / `STATE_SYNC`, et ajoute les logs v1 `REMOTE_OPTIONS_RX` + `REMOTE_OPTIONS_GUARD_BLOCK`; `remote-ui.js` ajoute `optionsLive` + log `REMOTE_OPTIONS_RENDER`. Compat convention logs: émission via bus `ui/remote:action` (suppression des `window.Logger.debug` directs pour `REMOTE_OPTIONS_*`). Stabilité reveal (quiz/blindtest): conservation de la correction sur `remote/options:proposals` + alias CSS `option-reveal` (compat `.reveal`) + reveal key-first strict (`data-option-key`) avec logs debug `BT_REMOTE_REVEAL_RX`/`BT_REMOTE_REVEAL_APPLY`; propagation `correctOptionKey` depuis `session_sync` vers WS quiz/blindtest.
- 2026-02-09 — code+doc — Front logger: ajout `ensureEntrySourceTs` dans `logger.global.js` pour garantir un timestamp source par entrée (`meta.client_ts` + `meta.event_ts`) avant `log_batch`/`log_event`; compat ISO conservée (`entry.ts` préservé si valide, fallback ISO sinon).
- 2026-02-08 — code+doc — Flush logs front harmonisé viewer-first: `LOG_FLUSH_TRY` (debug), `LOG_FLUSH_OK` (info), `LOG_FLUSH_FAIL` (warn) avec meta `{count, ws_ready_state, ws_url?}`; objectif: preuve d’ingestion front côté WS (`LOG_BATCH_RX`) et lisibilité timeline.
- 2026-02-09 — code+doc — Rollback Bingo flush: suppression de la voie `logs_proxy.php?flush=1`/`force_flush` (non native Bingo), retour au trigger viewer `localStorage.LOG_FLUSH_REQUEST` consommé par `logger.global.js` (`storage` -> `flushBufferToWS` -> `log_batch`).
- 2026-02-05 — code+doc — Bingo Canvas `phase_winner` persisté : ajout table `bingo_phase_winners`, colonnes de dénormalisation `phase_wins_count/last_won_*` sur `bingo_players`, handler PHP transactionnel (idempotence `event_id`, conflit inter-joueur, update phase_courante, logs PHASE_WINNER_*); doc canon synchronisée (DDL/OVERVIEW/MAP/write-map/HANDOFF).
- 2026-02-05 — code — Remote options diagnostics : instrumentation Bus-first (INTENT/SEND/ACK/OVERRIDDEN avec corrélation seq/latence) pour `updateGameOptions` (remote-ui/remote-ws, logger.global).
- 2026-02-05 — code — Diagnostics songDuration (organizer): logs Bus-first REMOTE_ACTION_RX/BLOCKED, ORG_TO_SERVER_SEND, ORG_OPTIONS_OBSERVED/OVERRIDDEN avec séquencement et latence (ws_effects, logger.global).
- 2026-02-05 — code — Remote_action guard split: les actions options (set_duration/choices/pause/option_type/manual) bypass le guard organizerCanControlSync; seules les commandes player restent bloquées si player_not_ready; log classification `remote_action_classified`.
- 2026-02-05 — doc — ajout contrats WS/HTTP, idempotence, paper-mode, glossaire états; README restructuré; TASKS mis à jour
- 2026-02-05 — doc — création du parcours repo-first (INDEX/README/TASKS) + intégration “surfaces d’intervention” (script map 20/80)
