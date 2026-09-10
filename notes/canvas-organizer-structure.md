# Canvas — Organizer/Remote : repérage structurel (audit léger)

Objectif : localiser les pages qui rendent l’UI organizer/remote (3 jeux + variantes “globalisées”), repérer où `id_client` est déterminé, et relever les hooks DOM (boutons + QR/remote) pour un point d’injection stable.

## Fichiers UI (entrypoints)

### Version “games/” (fronts canvas actuels)
- Organizer : `games/web/organizer_canvas.php`
- Player : `games/web/player_canvas.php`
- Remote : `games/web/remote_canvas.php`
  - Référence canon : `documentation/canon/entrypoints.md`

### Version “global/” (ancienne / legacy)
Supprimée (code obsolète retiré).

## Où `id_client` est déterminé

### Organizer “games/” : via token → session → DB (PHP)
Dans `games/web/organizer_canvas.php`, `id_client` est dérivé du token de session :

```php
$id_championnat_session = app_session_get_id($token);
$app_session_detail = app_session_get_detail($id_championnat_session);
$id_client          = $app_session_detail['id_client'] ?? null;
```

Sources : `games/web/organizer_canvas.php:146` → `games/web/organizer_canvas.php:149`

Puis exposé au front via `window.AppConfig.idClient` :

```js
window.AppConfig = {
  idClient: "<?= (int)$id_client ?>",
};
```

Source : `games/web/organizer_canvas.php:343` → `games/web/organizer_canvas.php:359`

### Organizer “global/” : même logique (guardée)
Supprimé (code obsolète retiré).

### Preload/meta (backend canvas unifié) : `ServerSessionMeta.id_client`
Le preload est construit via `build_preload_for_game()` (dispatcher), qui appelle un resolver par jeu :
- `games/web/includes/canvas/php/boot_lib.php:39` → `games/web/includes/canvas/php/boot_lib.php:76`

Chaque glue lit `championnats_sessions.id_client` par token :
- Quiz : `games/web/includes/canvas/php/quiz_adapter_glue.php:36` → `games/web/includes/canvas/php/quiz_adapter_glue.php:52`
- Blindtest : `games/web/includes/canvas/php/blindtest_adapter_glue.php:36` → `games/web/includes/canvas/php/blindtest_adapter_glue.php:55`
- Bingo : `games/web/includes/canvas/php/bingo_adapter_glue.php:26` → `games/web/includes/canvas/php/bingo_adapter_glue.php:44`

Exposition (quiz) :
- `games/web/includes/canvas/php/quiz_adapter_glue.php:567` → `games/web/includes/canvas/php/quiz_adapter_glue.php:576`

## Hooks DOM repérés (boutons + QR/remote)

### Racines (bons points d’ancrage)
- Organizer : `body#organizer-root[data-game][data-token]`
  - `games/web/organizer_canvas.php:446` → `games/web/organizer_canvas.php:448`
- Remote : `div#remote-root.remote-root[data-game][data-token]`
  - `games/web/remote_canvas.php:351`

### Boutons du menu organizer (2 boutons demandés)
Dans les 2 versions, les boutons sont sélectionnables de façon stable par `data-bs-target` :
- “Personnalisation” : `.organisateur-menu [data-bs-target="#designModal"]`
- “Options de jeu” : `.organisateur-menu [data-bs-target="#optionsModal"]`

HTML (games) :
- `games/web/organizer_canvas.php:922` → `games/web/organizer_canvas.php:942`

HTML (global) :
Supprimé (code obsolète retiré).

JS (déjà en place, preuve de stabilité) :
- `games/web/includes/canvas/core/canvas_display.js:1784` → `games/web/includes/canvas/core/canvas_display.js:1786`

### QR principal (inscription joueurs)
Structure stable :
- conteneur : `div#main-qr-container.qr-mask`
- canvas : `canvas#main-qrcode`

Sources :
- `games/web/organizer_canvas.php:529` → `games/web/organizer_canvas.php:531`

### QR “pilotage mobile / remote” (dans Options)
IDs stables :
- bouton : `#showPilotQR`
- wrapper collapse : `#pilotQRWrap`
- canvas : `#pilot-qr`

Sources :
- `games/web/organizer_canvas.php:1110` → `games/web/organizer_canvas.php:1127`

### URL remote (liaison organizer → remote)
L’URL remote est injectée en config :
- `window.AppConfig.remoteUrl` → `.../remote/{game}/{token}`
  - `games/web/organizer_canvas.php:343` → `games/web/organizer_canvas.php:352`

## Reco : point d’injection le plus stable

Priorité (du plus stable au plus fragile) :
1) **Racine organizer** : `body#organizer-root` + `data-game` / `data-token` (permet de filtrer par jeu sans dépendre du texte).
2) **Sélecteurs par attribut** : `.organisateur-menu [data-bs-target="#designModal"]` et `[data-bs-target="#optionsModal"]` (plus stable que le texte ou l’ordre).
3) **QR** : cibler `#main-qr-container` / `#main-qrcode` (évite collisions avec autres QR : pause/pilot).
