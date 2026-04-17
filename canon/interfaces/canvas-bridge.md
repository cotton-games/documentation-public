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

## Auth inter-service (service-only)
- Les appels **front (browser)** ne doivent **pas** envoyer `X-Service-Token` (et ne doivent pas en dépendre).
- Le header `X-Service-Token: <secret>` est requis **uniquement** quand le payload contient `event_id` (intention d’écriture / idempotence).
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
- `event_id` = intention d’écriture + idempotence.
- Replay (même `event_id`) → réponse `ok=true` avec `data.already_processed=true`.
  - Les erreurs 403 (`misconfigured` / `forbidden`) sont pertinentes uniquement lorsque `event_id` est présent (auth activée).
- Implémentation: côté PHP, **toute requête** qui contient `event_id` est traitée comme “write-idempotent” (insert/dedupe en `game_events`), peu importe `game`/`action` → ne jamais envoyer `event_id` sur les reads.
- Exception front “démo” : `resetdemo` est un write **front (organizer)** sans `event_id` (pas d’idempotence `game_events`, pas de `X-Service-Token`).
- Exception front “remote upload podium” : `session_podium_photo_upload` est un write **front (remote)** sans `event_id` ni `X-Service-Token`; l'autorisation repose sur `id_client` + appartenance de session + consentement organisateur present, puis delegue a `app_session_results_podium_photo_upload(...)`.
- Exception front “player upload podium” : `player_podium_photo_upload` est un write **front (player)** sans `event_id` ni `X-Service-Token`; l'autorisation repose sur l'eligibilite runtime revalidee cote serveur (session archivee, joueur courant, podium, consentement present), puis delegue au meme helper partage `app_session_results_podium_photo_upload(...)`.

Normalisation d’action:
- Si `action` est de la forme `bingo:xxx` et `game=bingo`, le bridge normalise vers `action=xxx` avant dispatch.

## Gotchas (à garder en tête)
- **Upload podium remote** : `session_podium_photo_upload` attend un vrai fichier dans `$_FILES['files_img']`, un `sessionId`, un `rank` (`1..3`), un consentement explicite, et, si disponible, un `photo_row_key` pour cibler proprement un ex aequo. La reponse de succes peut embarquer un `session_meta` deja rafraichi pour rerender l'UI sans second call.
- **Priorite organisateur** : quand la photo visible d'une ligne podium est issue d'un upload organisateur (`games_remote_organizer` / `pro_organizer`), le socle la marque comme prioritaire et le flow player ne doit plus pouvoir l'ecraser.
- **Upload podium player** : `player_podium_photo_upload` attend lui aussi un vrai fichier dans `$_FILES['files_img']`, mais n'accepte l'ecriture que pour le joueur courant si la session est terminee, que le joueur est sur le podium, et que `consent=1` est present. La reponse peut renvoyer un `player_access` rafraichi pour rerender la carte de fin.
- **Trace suppression** : le write path player snapshotte aussi le pseudo/libelle runtime visible lors de l'upload, afin de retrouver plus vite photo + session + joueur si une demande d'effacement arrive ensuite.
- **Eligibilite player** : `player_podium_photo_access_get` est un read bridge front destine a l'ecran `Partie terminee`; il retourne l'etat d'eligibilite, la meta podium ciblee et le texte de consentement a afficher. En cas d'ineligibilite, l'UI doit masquer le CTA et le write path doit de toute facon refuser ensuite cote serveur.
- **Bingo identité canonique** : ne pas confondre `player_id` (string stable `p:<uuid>`) et `playerId` (id DB numérique legacy). Les actions player/grid doivent privilégier `player_id`.
- **Validation payload player-scoped** : côté WS wrappers, `player_id` doit être canonique et `playerId` doit rester strictement numérique (jamais `p:<uuid>`).
- **403 uniquement quand `event_id`/`eventId` est présent** : l’auth inter-service est conditionnée à la présence de `event_id`/`eventId` dans le payload. Si tu vois un 403 sur un “read”, vérifie qu’un client/proxy n’ajoute pas `event_id` automatiquement.
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
<!-- AUTO-UPDATE:END id="bridge-examples" -->
