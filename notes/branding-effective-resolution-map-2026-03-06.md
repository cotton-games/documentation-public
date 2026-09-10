# Branding effective resolution map (2026-03-06)

## 1) Global: fonctions `general_branding` lues/écrites + règles type 1/2/3/4

### Canon de résolution (source de vérité)
- `app_general_branding_get_detail(...)`  
  preuve: `global/web/app/modules/general/branding/app_branding_functions.php:17`
- Mapping des types:
  - type `1` = session (`id_related = id_championnat_session`)  
    preuve: `.../app_branding_functions.php:10`, `:21-25`
  - type `2` = événement (`id_related = id_operation_evenement`)  
    preuve: `.../app_branding_functions.php:11`, `:26-30`
  - type `3` = réseau (`id_related = id_client_reseau`)  
    preuve: `.../app_branding_functions.php:12`, `:31-35`
  - type `4` = client (`id_related = id_client`)  
    preuve: `.../app_branding_functions.php:13`, `:36-40`

### Priorité actuelle effective (ordre de recherche)
- Boucle de résolution dans l’ordre `1 -> 2 -> 3 -> 4`, retour au premier match.  
  preuve: `.../app_branding_functions.php:67-90`
- Cas siège: si `clients.flag_client_reseau_siege=1`, la recherche réseau (type 3) est forcée avec `id_related = id_client` (même sans `id_client_reseau`).  
  preuve: `.../app_branding_functions.php:43-55`

### Lecture complète payload branding
- `app_general_branding_get_complete($id_branding)` lit `general_branding` et hydrate:
  - couleurs: `general.color.background_1/font_1/background_2/font_2`
  - police: `general.font.family/family_url`
  - médias: `logo.img_src`, `visuel.img_src`
  preuve: `.../app_branding_functions.php:101`, `:143`, `:205-208`, `:226-227`, `:159-185`

### Écritures `general_branding`
- Insert: `app_general_branding_ajouter(...)` -> `INSERT INTO general_branding`  
  preuve: `.../app_branding_functions.php:321`, `:345-395`
- Update: `app_general_branding_modifier(...)` -> `UPDATE general_branding`  
  preuve: `.../app_branding_functions.php:407`, `:429-450`
- Delete: `app_general_branding_supprimer(...)` -> `DELETE FROM general_branding`  
  preuve: `.../app_branding_functions.php:706-712`
- Upload/restauration/suppression fichiers logo/visuel:  
  preuve: `.../app_branding_functions.php:539-612`, `:614-646`, `:655-701`

### Callsites globaux majeurs
- API `get/save/delete`: `global/web/app/modules/general/branding/app_branding_ajax.php`
  - `get` -> `app_general_branding_get_detail` + `get_complete`  
    preuve: `.../app_branding_ajax.php:205-213`
  - `save` accepte seulement `id_type_branding in [1,4]`  
    preuve: `.../app_branding_ajax.php:327-329`
  - `save` crée type 4 client ou type 1 session selon scope  
    preuve: `.../app_branding_ajax.php:334-364`
  - `delete` supprime médias + ligne  
    preuve: `.../app_branding_ajax.php:298-309`

## 2) Règle de priorité affilié vs siège vs défaut + callsites

### Règle actuelle (métier branding)
1. Session (type 1) si existe  
2. Événement (type 2) si existe  
3. Réseau (type 3) si existe  
4. Client affilié (type 4) sinon  
5. Si aucun branding DB: fallback thème jeu/defaults front

Preuves:
- ordre 1/2/3/4: `global/.../app_branding_functions.php:20-40`, `:67-90`
- override siège sur type 3: `global/.../app_branding_functions.php:43-55`
- fallback thème/defaults games:
  - merge `$THEME = arr_merge_deep($DEFAULT_THEME, $BRANDING)`  
    preuves: `games/web/organizer_canvas.php:285`, `games/web/player_canvas.php:137`, `games/web/remote_canvas.php:142`
  - fallback couleurs globales (`#240445`, `#562AF8`)  
    preuves: `games/web/organizer_canvas.php:320-328`, `games/web/player_canvas.php:217-225`, `games/web/remote_canvas.php:239-247`

### Callsites applicatifs de la résolution
- PRO vue/form:
  - `pro/web/ec/modules/general/branding/ec_branding_view.php:2`
  - `pro/web/ec/modules/general/branding/ec_branding_form.php:34`
- Global API:
  - `global/web/app/modules/general/branding/app_branding_ajax.php:206`, `:282`, `:342`

## 3) PRO: flow création/édition branding (siège/affilié)

### Entrées UI
- Vue branding (CTA créer/modifier):  
  `pro/web/ec/modules/general/branding/ec_branding_view.php:28-32`, `:106-110`
- Formulaire branding -> submit vers script:  
  `pro/web/ec/modules/general/branding/ec_branding_form.php:81-83`

### Action serveur
- `mode=branding_ajouter`
  - défaut `id_type_branding=4` (client)
  - si siège `flag_client_reseau_siege==1` alors `id_type_branding=3` (réseau)
  - `id_related = $_SESSION['id_client']`
  - insert + upload logo/visuel
  preuves: `pro/web/ec/modules/general/branding/ec_branding_script.php:40-45`, `:48-70`, `:72-111`
- `mode=branding_modifier`
  - update par `id_branding` + upload logo/visuel
  preuves: `pro/web/ec/modules/general/branding/ec_branding_script.php:119-145`, `:147-187`

### Comportement affilié héritant réseau (UI)
- Pas de bouton de modification si client affilié et branding résolu de type réseau.  
  preuve: `pro/web/ec/modules/general/branding/ec_branding_view.php:101-114`

## 4) Games: champs exacts attendus par `play-ui.js` / `remote-ui.js` + source

### Source serveur (`global_ajax`)
- `organizer/player/remote_canvas.php` appellent:
  - `/global_ajax.php?t=general&m=branding&action=get&format=json&token=...`
  preuves: `games/web/organizer_canvas.php:99-104`, `games/web/player_canvas.php:65-70`, `games/web/remote_canvas.php:70-75`
- extraction payload:
  - `$payload = $data['branding'] ?? ($data['data']['branding'] ?? null)`
  preuves: `games/web/organizer_canvas.php:128`, `games/web/player_canvas.php:94`, `games/web/remote_canvas.php:99`
- merge branding dans thème:
  - `$BRANDING = arr_merge_deep($BRANDING, $payload)` puis `$THEME = arr_merge_deep($DEFAULT_THEME, $BRANDING)`
  preuve: `games/web/organizer_canvas.php:138-140`, `:285`

### Payload WS attendu par front runtime (play/remote)
- émission WS `update_branding`:
  - payload réduit par `lightBranding()`:
    - `primaryBg`, `secondaryBg`, `primaryFont`, `fontFamily`, `fontUrl`, `logoMode`, `visuelMode`, `logo`, `visuel`
  preuves: `games/web/includes/canvas/core/ws_effects.js:867-878`, `:891`
- source de ce payload canonique (orga):
  - construit dans `session_modals.js` après save REST
  preuves: `games/web/includes/canvas/core/session_modals.js:2141-2153`, `:2156`

### Champs consommés par `play-ui.js`
- handler: `Bus.on('player/branding', ...)`  
  preuve: `games/web/includes/canvas/play/play-ui.js:2262-2263`
- `applyBrandingToDOM_Player({...})` consomme:
  - `primaryBg`, `secondaryBg`, `primaryFont`, `fontFamily`, `fontUrl`
  - `visuelMode`, `visuel` (logo non appliqué ici)
  preuves: `.../play-ui.js:2334-2365`, `:2370-2382`

### Champs consommés par `remote-ui.js`
- handler: `Bus.on('remote/branding', ...)`  
  preuve: `games/web/includes/canvas/remote/remote-ui.js:5567-5568`
- `applyBrandingToDOM_Remote({...})` consomme:
  - `primaryBg`, `secondaryBg`, `primaryFont`, `fontFamily`, `fontUrl`
  preuves: `.../remote-ui.js:2946-2969`

## TODOs audit (garde-fous + héritage PRO)

### Garde-fous à renforcer
1. `global/app_branding_ajax.php`: ajouter contrôle d’autorisation explicite sur `save/delete` (session client + ownership `id_branding`/`id_client`), car le handler hydrate `$_SESSION['id_client']` depuis paramètres (`id_client`/token) sans garde d’ACL visible.  
   preuves: `global/.../app_branding_ajax.php:163-171`, `:323-350`, `:261-313`
2. `global/app_branding_ajax.php`: ouvrir explicitement la gestion type `3` (réseau) avec règles d’accès siège, aujourd’hui `save` limite à `[1,4]` alors que PRO écrit `3`.  
   preuves: `global/.../app_branding_ajax.php:327-329`, `pro/.../ec_branding_script.php:42-43`
3. `global/app_branding_functions.php`: imposer unicité logique `(id_type_branding,id_related)` (contrainte DB ou check applicatif), car resolver prend le premier `fetch_assoc()` sans tri.  
   preuve: `global/.../app_branding_functions.php:75-80`
4. `global/app_branding_ajax.php`: filtrer téléchargement URL distante (`dl_to_tmp`) via allowlist MIME/taille/domaine + rate-limit/logs, pour limiter SSRF et abus upload indirect.  
   preuve: `global/.../app_branding_ajax.php:37-67`, `:420-428`, `:457-458`

### Où afficher l’état d’héritage côté PRO
1. `pro/web/ec/modules/general/branding/ec_branding_view.php`:
   - afficher clairement la source effective (`session/evenement/reseau/client`) via `type.slug`/`type.nom` déjà disponibles.
   - expliciter “hérité du siège” quand `id_client_reseau>0 && type.slug=='branding_reseau'`.
   preuves: `.../ec_branding_view.php:2`, `:101-114`
2. `pro/web/ec/modules/general/branding/ec_branding_form.php`:
   - bannière “édition bloquée car héritage réseau actif” avant formulaire quand cas affilié hérité.
   preuve: `.../ec_branding_form.php:34`
3. PRO compte siège:
   - ajouter indicateur de portée au save (`type 3 réseau` vs `type 4 client`) sur écran/confirm submit.
   preuve: `.../ec_branding_script.php:42-43`
