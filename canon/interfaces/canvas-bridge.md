> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Canvas Bridge API (Contract)

<!-- NOTE TO CODEX:
Only edit inside AUTO-UPDATE blocks.
If required info is missing, update HANDOFF next steps instead of guessing.
-->

> Single source of truth for request/response formats and conventions.

<!-- AUTO-UPDATE:BEGIN id="bridge-contract" owner="codex" -->
# Canvas Bridge API — contract (implementation-aligned)

## Endpoint
- `POST /GAMES/games_ajax.php?t=jeux&m=canvas` (alias historique: `/GAMES/global_ajax.php?t=jeux&m=canvas`)
- Request body:
  - `application/x-www-form-urlencoded` pour les appels bridge classiques
  - `multipart/form-data` toléré pour les uploads, notamment `session_podium_photo_upload` depuis la remote `games` et `player_podium_photo_upload` depuis `player_canvas`
- Response: JSON enveloppé `{ ok, data, error, ts }`
  - Les clients front qui attendaient historiquement un payload “plat” doivent lire les champs dans `data` (ou déballer `data`).

## Bootstrap organizer Hub
- Le lancement Hub Master vers l'organizer reste une navigation même onglet vers `/master/{runtime_session}?hub_launch=1`; le boot lit `window.AppConfig.hubLaunchAutoStart` et `window.AppConfig.hubOrganizer`. Le contexte Organizer expose `sourceSessionId`, `runtimeSessionId`, `runtimeMode` et `executionId`; en officiel source et runtime sont identiques, en démo le runtime est la copie canonique hors membership Hub.
- Aucun payload bridge ni stockage navigateur ne transporte une intention plein écran Hub Master -> organizer. Les contrôles plein écran restent manuels et locaux au document courant.
- Le lancement depuis Hub Remote ne change pas le bridge Canvas: le téléphone dépose une commande `launch_session`, dont le `command_id` devient la clé de retry de l'intention. Hub Master claim puis appelle le même contrat central que son bouton local; toute nouvelle intention Hub crée un runtime démo distinct et la navigation finale reste `/master/{session}?hub_launch=1`.
- Hub Remote ne lance jamais directement le runtime historique. Après décision Hub Master/Global, il navigue seulement depuis `control_poll.client_routing`. La Remote historique reçoit l'`executionId` et la `routingGeneration` canoniques dans `AppConfig.hubRemoteReturn`, puis `HubTransition` renvoie `returned_execution_id + returned_routing_generation`; ces champs servent exclusivement à bloquer le couple exact quitté.
- Readiness, présence et fin naturelle valident l'Organizer contre le `runtime_session_id` déclaré tout en corrélant focus et exécution à la source officielle. Une fin démo complète l'exécution sans rebuild des stats ni injection de résultats Hub.
- Pour une injection Hub papier, le service central appelle avant le focus l'abstraction interne `canvas_historical_session_ensure_for_game(...)`: parent minimal Quiz/Blind Test assuré puis relu, validation sans write pour Bingo. Ce helper n'est pas une action bridge, ne change aucun payload `player_register` et n'appelle pas le preload complet.

## Auth inter-service (service-only)
- Les appels **front (browser)** ne doivent **pas** envoyer `X-Service-Token` (et ne doivent pas en dépendre).
- Le header `X-Service-Token: <secret>` est requis pour les appels **inter-service** idempotents et pour les actions explicitement service-only. Les writes player Bingo same-origin (`player_register`, `grid_assign`, `grid_cells_sync`) portent aussi un `event_id`, mais restent des appels browser sans secret.
  - Si le token n’est pas configuré côté serveur, réponse **403** `ok=false` (`error.code="misconfigured"`) **uniquement** quand le token est requis.
  - Si le token est absent/invalid, réponse **403** `ok=false` (`error.code="forbidden"`).
  - **Bypass dev temporaire (writes uniquement)** : si (1) environnement dev détecté (`APP_ENV=dev` **ou** `HTTP_HOST` contient `.dev.`) **et** (2) `CANVAS_DEV_ALLOW_UNAUTH_WRITES=1`, alors le bridge accepte les writes même sans `X-Service-Token`.
    - Le bridge ajoute `data.auth_bypassed=true` à la réponse JSON enveloppée quand le bypass est utilisé.
    - Un log warning explicite est émis côté PHP: `[canvas bridge][auth_bypass_used] ...`.
    - Interdit hors dev / si le flag est absent → comportement strict inchangé (403 comme avant).

## Dispatch
- `game_api_dispatch($pdo, $payload)`
- Convention:
  - tente `{$game}_api_{$action}` (ex: `bingo_api_session_update`)
  - sinon `canvas_api_{$action}`
  - sinon erreur “action not supported”

## Payload minimal (Bingo, d’après impl + smoke)
Champs communs:
- `game` (obligatoire): `bingo`
- `action` (obligatoire): ex `session_update`, `bingo:reset`, `bingo:end_game`, `phase_winner`
- `sessionId` (recommandé/attendu): token de session (id_securite)
- identité player (actions player/grid): `player_id` canonique (`p:<uuid>`) est la clé de référence; `playerId` numérique reste toléré en fallback legacy sur certaines actions et est résolu côté bridge.
- `phase_winner` (bingo) est désormais key-first: `player_id` canonique requis, `playerId` numérique optionnel (fallback compat).

Idempotence (writes / service-only):
- Toute action **write** (WS → Canvas) DOIT inclure `event_id` (UUID) ; sinon comportement **NON SUPPORTÉ**.
- Les writes browser player Bingo `player_register`, `grid_assign` et `grid_cells_sync` incluent également un `event_id` stable par tentative logique, sans `X-Service-Token`; leur autorisation reste celle du contexte player same-origin.
- `event_id` = intention d’écriture + idempotence.
- Replay (même `event_id`) → réponse `ok=true` avec `data.already_processed=true`.
  - Les erreurs 403 (`misconfigured` / `forbidden`) concernent les appels pour lesquels l'auth inter-service est requise; la simple présence d'un `event_id` sur les trois writes player Bingo n'impose pas de secret navigateur.
- Implémentation: côté PHP, **toute requête** qui contient `event_id` est traitée comme “write-idempotent” (insert/dedupe en `game_events`), peu importe `game`/`action` → ne jamais envoyer `event_id` sur les reads.
- Exception front “démo” : `resetdemo` est un write **front (organizer)** sans `event_id` (pas d’idempotence `game_events`, pas de `X-Service-Token`).
- Exception front “remote upload podium” : `session_podium_photo_upload` est un write **front (remote)** sans `event_id` ni `X-Service-Token`; l'autorisation repose sur `id_client` + appartenance de session + consentement organisateur present, puis delegue a `app_session_results_podium_photo_upload(...)`.
- Exception front “player upload podium” : `player_podium_photo_upload` est un write **front (player)** sans `event_id` ni `X-Service-Token`; l'autorisation repose sur l'eligibilite runtime revalidee cote serveur (session archivee, joueur courant, podium, consentement present), puis delegue au meme helper partage `app_session_results_podium_photo_upload(...)`.

Action d'expiration de grâce Hub:
- `hub_session_grace_expired` est un write service-only appelé uniquement après expiration définitive de la grâce organizer.
- Payload: `game`, `sessionId`, `event_id`. Raisons métier: `hub_focus_cleared`, `different_focus`, `not_hub_session`, `session_not_found`, `clear_failed`.
- Le clear est atomique et sans effet si `games_hubs.active_session_id` ne correspond plus à la session expirée.

Action de fin naturelle Hub:
- Un lancement explicite Hub écrit d'abord `hub_execution_started` dans `game_events`. Ce marqueur d'incarnation, le focus courant et l'écriture terminale distinguent une exécution Hub d'une ouverture historique d'une session seulement rattachée.
- `hub_session_natural_ended` est un write service-only distinct de la grâce, de `quitGame` et des abandons techniques. Il est appelé par le moteur uniquement après réussite de l'écriture terminale (`session_update` final Quiz/Blind Test, `bingo:end_game` Bingo).
- Payload: `game`, `sessionId`, `event_id`; `X-Service-Token` est obligatoire même indépendamment de la règle générique liée à `event_id`.
- Le bridge exige `hub_execution_started` encore ouvert et `active_session_id = session`, relit les résultats, effectue le clear gardé puis écrit `hub_execution_completed`. Réponse métier: `hub_session`, `hub_execution`, `cleared`, `reason`, `hub_id`, `hub_token`, `session_id`, `current_session_id`, `podium_available`.
- Après preuve de clôture Hub (`hub_execution_completed`, récupération tardive ou replay `already_completed`), le bridge déclenche le rebuild persistant dev des stats joueurs Hub via `app_games_hub_players_stats_rebuild(..., dry_run=false, write=true)`. Les sessions démo sont exclues; les erreurs ou résultats runtime incomplets sont journalisés et marquent les stats dirty/error quand le contrat Global est disponible, sans exposer d'erreur dans la réponse du callback.
- Une course tardive A après activation de B retourne `different_focus` et ne vide pas B. Une session hors Hub retourne `hub_session=false`; les moteurs gardent alors leur écran final historique.
- Les replays sûrs de `hub_session_natural_ended`, `player_register`, `grid_assign` et `grid_cells_sync` redispatchent leurs handlers idempotents afin de restituer le résultat métier, tout en conservant `already_processed=true`. Cela évite qu'une réponse réseau perdue transforme un ACK de replay en payload incomplet.
- Pour Quiz et Blind Test, `player_register` ne déduit jamais une remise à zéro du seul statut `is_active`. `score=0` exige le contexte serveur interne posé par Hub Play pendant `manual_join_session`, après vérification sous verrou que le mapping de cette identité était `left`; jeu, session et `player_id` doivent correspondre. Toute autre réactivation conserve le score. La réponse inclut `score` dans `upsert.changed_fields` seulement si cette opération autorisée a effacé une valeur non nulle.
- Bingo ne transpose pas ce reset aux gains de phase: `bingo_phase_winners` et `phase_wins_count/last_won_*` survivent à `deactivate_player` puis `player_register`, car ils matérialisent un résultat acquis. Ils ne sont purgés que par les actions de reset complet prévues à cet effet.
- Lors d'une injection Hub papier, `player_register` reçoit la clé `p:*` du joueur Hub actif. Si une unique ligne runtime du même jeu et de la même session porte déjà le pseudo exact sous une ancienne clé Remote, un contexte PHP interne — jeu, token session, clé, pseudo, Hub et joueur Hub — autorise le remplacement de cette seule clé. L'ID de ligne, score, grille et gains sont conservés; hors de ce contexte ou avec plusieurs conflits, `USERNAME_ALREADY_USED` reste la réponse.
- Les writes Bingo browser génèrent leur `event_id` côté appelant. Une requête simultanée est coalescée; après erreur réseau, le retry logique réutilise l'ID, puis une nouvelle tentative métier en crée un nouveau.

Normalisation d’action:
- Si `action` est de la forme `bingo:xxx` et `game=bingo`, le bridge normalise vers `action=xxx` avant dispatch.

## Gotchas (à garder en tête)
- **`players_get` runtime actif** : pour Quiz, Blind Test et Bingo, le contrat par défaut retourne les joueurs actifs. `includeInactive=1` doit rester borné aux écrans terminaux, historiques ou de résultats; les réhydratations `canvas_display.js` pendant `En cours` ou `Pause` ne doivent pas l'envoyer, sinon un joueur volontairement sorti (`is_active=0`) peut revenir dans le roster et gonfler `GameStore.totalPlayers`.
- **Upload podium remote** : `session_podium_photo_upload` attend un vrai fichier dans `$_FILES['files_img']`, un `sessionId`, un `rank` (`1..3`), un consentement explicite, et, si disponible, un `photo_row_key` pour cibler proprement un ex aequo. La reponse de succes peut embarquer un `session_meta` deja rafraichi pour rerender l'UI sans second call.
- **Priorite organisateur** : quand la photo visible d'une ligne podium est issue d'un upload organisateur (`games_remote_organizer` / `pro_organizer`), le socle la marque comme prioritaire et le flow player ne doit plus pouvoir l'ecraser.
- **Upload podium player** : `player_podium_photo_upload` attend lui aussi un vrai fichier dans `$_FILES['files_img']`, mais n'accepte l'ecriture que pour le joueur courant si la session est terminee, que le joueur est sur le podium, et que `consent=1` est present. La reponse peut renvoyer un `player_access` rafraichi pour rerender la carte de fin.
- **Remote papier Quiz/Blind Test `update_score`** : la correction de score depuis la remote papier passe par le bridge HTTP avant le WS. Payload attendu: `game=quiz|blindtest`, `action=update_score`, `sessionId`, `sessionPrimaryId`, `player_id` canonique ou `playerId` numerique, `score`, `event_id`, `role=remote`, `remote_action=paper_score_update`, `paperMode=1`. Le succes HTTP est l'ACK fiable apres write DB; le WS `admin_set_score` est seulement un refresh best-effort et peut etre manque si aucun primary organizer n'est connecte.
- **Blind Test equipes runtime** : `blindtest:session_update` peut recevoir `players` / `rankings` / `finalRankings` pour persister `blindtest_session_teams`. Une ligne est persistée comme equipe uniquement si `teamMemberCount`, `team_member_count` ou `members` indique au moins 2 membres; une equipe préparée restée seule doit rester une ligne joueur solo dans les payloads publics.
- **Remote papier Bingo `phase_winner`** : l'attribution gagnante avec joueur depuis la remote papier passe par le bridge HTTP avant le WS. Payload attendu: `game=bingo`, `action=phase_winner`, `sessionId`, `player_id` canonique ou `playerId` numerique, `phase`, `event_id`, `role=remote`, `remote_action=paper_phase_winner`, `paperMode=1`. Le WS `admin_phase_winner` porte ensuite `persisted=true`, `wonPhase`, `nextPhase` et `requiresResync=true` pour rafraichir les sockets connectees sans repersister. `PHASE_MISMATCH`, `GAME_ALREADY_ENDED` et `phase_winner_conflict` sont des conflits métier HTTP 409, pas des erreurs serveur 500. Le fallback de saisie de lignes convertit les numéros humains 1-based en index `grid_lines` 0-based avant la requête.
- **Terminal papier commun** : `awaiting_score_validation` reste non terminal. Pour Quiz/Blind Test, `paper_finalize_end` est une commande WS avec `event_id`; le serveur persiste le `session_update` final avant tout `hub_session_natural_ended`. Pour Bingo, `phase_winner(nextPhase=-1)` déjà acquitté précède `bingo:end_game` avec un ID stable. `hub_session_natural_ended` n'est appelé qu'après le write terminal; le WS n'est jamais l'unique preuve de succès.
- **Erreur terminale papier** : si `session_update` final ou `bingo:end_game` échoue, aucun appel Hub n'est effectué et `paper_score_finalization_state` ramène les organisateurs à `awaiting_score_validation`. Le payload WS est une notification d'UI, pas une preuve DB.
- **Retry completion Hub** : si `hub_session_natural_ended` a déjà vidé le focus mais échoue sur `hub_execution_completed`, un replay retrouve la session terminée et l'exécution encore ouverte, écrit la preuve idempotente puis renvoie `hub_execution=true`; aucune socket Master n'est requise.
- **Formats courts musicaux** : `championnats_sessions.id_format=5` est interprete par jeu sans migration DB. Blind Test limite le preload a 20 titres via ordre deterministe `id_session|id_morceau`; Bingo lit le format 5 comme une grille 3x3 dans `grid_lines`, `grid_assign` et les mappings WS. Les reponses Bingo `grid_assign` / `grid_hydrate` doivent porter `gridFormat`, `gridCols`, `gridRows` et `gridCellCount` afin que le player rende le layout depuis le format, pas depuis la seule longueur de `numbers`.
- **Trace suppression** : le write path player snapshotte aussi le pseudo/libelle runtime visible lors de l'upload, afin de retrouver plus vite photo + session + joueur si une demande d'effacement arrive ensuite.
- **Eligibilite player** : `player_podium_photo_access_get` est un read bridge front destine a l'ecran `Partie terminee`; il retourne l'etat d'eligibilite, la meta podium ciblee et le texte de consentement a afficher. En cas d'ineligibilite, l'UI doit masquer le CTA et le write path doit de toute facon refuser ensuite cote serveur.
- **Diagnostic catalogue YouTube** : `youtube_catalog_diagnostics_get` est un read front utilise par le test pre-lancement organizer. Il recoit une liste compacte `{id,url}` de supports YouTube detectes, extrait les `videoId`, relit `content_links_check_results` et renvoie le dernier diagnostic connu par support. Il ne lance aucun appel YouTube Data API et ne fait aucun write.
- **prizes_save partiel** : `prizes_save` accepte des payloads partiels. Une cle de lot absente preserve la colonne `lot_*` correspondante; depuis le 2026-05-05, `mainTitle` absent preserve aussi `championnats_sessions.diffusion_message`.
- **Bingo identité canonique** : ne pas confondre `player_id` (string stable `p:<uuid>`) et `playerId` (id DB numérique legacy). Les actions player/grid doivent privilégier `player_id`.
- **Bingo demoParticipant** : `demoParticipant` est un flag WS-only sur `auth_player`, pas un champ du Canvas bridge. Depuis le 2026-05-04, il n'exclut pas le socket demo desktop du quota WS: `Joueur démo` compte dans `maxPlayers`.
- **Switch format demo** : depuis le 2026-06-22, `session_meta_get` ne verrouille plus une session demo par principe. `format_locked` depend de l'etat runtime comme pour une officielle: phase attente autorisee, session demarree verrouillee. Les actions `quiz|blindtest|bingo:session_update` peuvent donc persister `paperMode` sur une demo non lancee, mais doivent toujours renvoyer `FORMAT_SWITCH_LOCKED` si la session est deja demarree.
- **Organizer iframe postMessage** : `gm-player-ready` est un message browser parent/iframe, pas une action bridge. Depuis le 2026-05-05, le parent organizer doit le refuser si l'origine, l'iframe source, la session, le jeu ou la grille Bingo attendue ne correspondent pas au contexte courant.
- **Validation payload player-scoped** : côté WS wrappers, `player_id` doit être canonique et `playerId` doit rester strictement numérique (jamais `p:<uuid>`).
- **403 sur un appel inter-service idempotent/service-only** : vérifier le token et sa configuration. Les trois writes player Bingo same-origin constituent l'exception documentée: ils portent un `event_id` sans exposer de secret au navigateur. Si un read reçoit un 403, vérifier qu'un client/proxy ne le transforme pas en write authentifié.
- **Différencier `misconfigured` vs `forbidden`** :
  - `error.code="misconfigured"` : le serveur PHP n’a pas `CANVAS_SERVICE_TOKEN` (ex: env manquante / secret non chargé) alors qu’un write le requiert.
  - `error.code="forbidden"` : header `X-Service-Token` absent ou ne matche pas `CANVAS_SERVICE_TOKEN` côté serveur.
- **Symptôme “writes WS bloqués”** : si les writes Canvas idempotents (ex: `bingo.session_update`, `bingo.reset`, `bingo.end_game`) renvoient 403, les effets DB associés ne se produisent pas → logique aval “bloquée” (ex: progression liée à `session_update` comme le compteur renvoyé `numPassedSongs` sur certains chemins).

## Format de réponse (réel)
```json
{
  "ok": true,
  "data": {
    "idempotent": true,
    "already_processed": false,
    "event_id": "00000000-0000-0000-0000-000000000001"
  },
  "error": null,
  "ts": 1700000000000
}
```
<!-- AUTO-UPDATE:END id="bridge-contract" -->

<!-- AUTO-UPDATE:BEGIN id="bridge-examples" owner="codex" -->
## Examples (auto)
### Bingo `reset` (write, idempotent)

Request (form-urlencoded):
```bash
	curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H "X-Service-Token: ${CANVAS_SERVICE_TOKEN}" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=bingo&action=bingo:reset&sessionId=SESSION_TOKEN&target_phase=1&event_id=00000000-0000-0000-0000-000000000010'
```

Response (1er appel):
```json
{ "ok": true, "data": { "idempotent": true, "already_processed": false, "event_id": "00000000-0000-0000-0000-000000000010" }, "error": null, "ts": 1700000000000 }
```

Response (replay, same `event_id`):
```json
{ "ok": true, "data": { "idempotent": true, "already_processed": true, "event_id": "00000000-0000-0000-0000-000000000010" }, "error": null, "ts": 1700000000000 }
```

### Quiz papier `update_score` depuis remote

Request (form-urlencoded, front remote):
```bash
curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=quiz&action=update_score&sessionId=SESSION_TOKEN&sessionPrimaryId=123&player_id=p:00000000-0000-4000-8000-000000000001&score=30&event_id=remote-evt-1&role=remote&remote_action=paper_score_update&paperMode=1'
```

Response:
```json
{ "ok": true, "data": { "idempotent": true, "already_processed": false, "event_id": "remote-evt-1", "changed": true, "currentScore": 30, "requiresResync": true }, "error": null, "ts": 1700000000000 }
```
<!-- AUTO-UPDATE:END id="bridge-examples" -->
