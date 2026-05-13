# Repo `games` — Tasks (journal bref)

## PATCH 2026-05-06 — Demo site mobile: libelle CTA lancement

### Objectif
- afficher le libelle exact `Lancer la démo` sur le bouton de lancement mobile organizer des demos publiques du site;
- limiter le comportement aux sessions demo rattachees au compte Cotton WWW Online Demos / Cotton Online Demos;
- ne pas modifier les demos clients, sessions officielles, sessions papier, comportements Quiz / Blind Test / Bingo ni serveurs WS.

### Audit
- Le bouton est rendu dans `web/organizer_canvas.php` (`#play-pause-btn`) et pilote par `web/includes/canvas/core/canvas_display.js` via `setMenuControls()`.
- Le CSS mobile de `web/includes/canvas/css/canvas_styles.css` transforme `.organisateur-menu .orga-btn` en bouton rond 48px et masque les `span`, ce qui explique le rendu icone seule.
- Les demos publiques du site sont creees cote `www` avec `id_client = 1557` et `flag_session_demo = 1` pour Quiz, Blind Test et Bingo Musical.
- Cote organizer, la condition fiable est deja exposee dans `AppConfig`: `isDemoSession === true` et `idClient === "1557"`.

### Modifie
- `../games/web/includes/canvas/core/canvas_display.js`
  - detecte uniquement le cas `isDemoSession + idClient 1557 + mobile + numerique + En attente + bouton play seul`;
  - remplace le libelle par `Lancer la démo` et pose un attribut de rendu sur `#play-pause-btn`;
  - retire cet attribut hors attente / hors cas cible pour conserver le rendu courant.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - conserve les classes existantes du bouton desktop (`btn btn-primary orga-btn px-4`);
  - neutralise seulement la regle mobile qui force le rond et masque le libelle pour `#play-pause-btn[data-public-demo-launch-cta="1"]`.

### Verification
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- TODO navigateur: demo publique site Cotton Online Demos mobile, demo client mobile, session officielle mobile, Bingo demo reset/relance.

## PATCH 2026-05-05 — Bingo GM iframe: sortie attente apres reset demo

### Objectif
- corriger le residuel iframe GM ou, apres reset demo Bingo termine, la grille etait bien vide/deverrouillee mais restait bloquee sur l'ecran d'attente au lancement suivant;
- conserver `bingo_reset_epoch` comme generation de stockage checked/locked uniquement;
- ne pas modifier `bingo.game/ws`.

### Audit
- Le joueur QR externe passe bien en `En cours`, ce qui confirme que le reset global et le flux WS serveur ne sont pas la source principale.
- Cote player Bingo, `demo_reset` remet `mainStarted=false`; ensuite `state` et `passed_song` ne remettaient `mainStarted=true` que si une duree de clip etait fournie.
- L'iframe GM pouvait donc recevoir un signal de partie demarree sans consommer son runtime post-reset ni sortir de l'attente.

### Modifie
- `../games/web/includes/canvas/play/play-ws.js`
  - ajoute la consommation runtime post-reset sur `state`, `reset_game` et `passed_song` des qu'une phase Bingo demarree est observee;
  - remet `mainStarted=true`, repousse l'etat live et la grille disponible, sans toucher aux cles checked/locked invalidees par `bingo_reset_epoch`;
  - ajoute les traces `ui/bingo:postreset:consumed`, `ui/bingo:start_after_reset:received` et `ui/bingo:start_after_reset:applied`.

### Verification
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`

## PATCH 2026-05-05 — Bingo reset demo termine: neutralisation front apres API

### Objectif
- corriger le reset demo Bingo d'une session terminee sans patcher le serveur WS, puisque `bingo.game/ws` ne diverge pas entre prod et develop sur ce flux;
- empecher organizer, iframe GM et joueur QR de conserver/rejouer un etat terminal apres un `resetdemo` DB reussi;
- conserver les grilles demo assignees et les rows `bingo_players`.

### Audit
- La prod fonctionne sans patch WS; `bingo.game` n'a pas de diff `main...develop` sur `ws/bingo_server.js`.
- Le reset DB Bingo remet deja a zero `phase_courante`, `morceau_courant`, logs playlist, `bingo_phase_winners`, timestamps de grilles et `bingo_players.gain_phase`.
- Le risque develop/local est front:
  - l'organizer ne recevait pas lui-meme de `demo_reset` live et pouvait garder store/podium/iframe en etat termine jusqu'au reload;
  - `organizer/demoPostResetReady` pouvait etre emis avant l'attachement du listener `canvas_display.js`;
  - un snapshot Bingo demo phase `0` ne purgeait pas explicitement les winners/medailles/podium front deja hydrates;
  - cote player, les flags locaux de fin statique/reconnexion pouvaient rester poses dans certains chemins avant traitement de `demo_reset`.

### Modifie
- `../games/web/includes/canvas/core/boot_organizer.js`
  - applique un reset local Bingo apres reponse API `resetdemo` OK;
  - publie un signal post-reset persistant jusqu'a consommation par l'UI organizer.
- `../games/web/includes/canvas/core/canvas_display.js`
  - consomme le signal post-reset pending apres attachement du listener et recharge/reconfigure l'iframe GM.
- `../games/web/includes/canvas/core/games/bingo_ui.js`
  - purge winners/medailles/podium quand un snapshot demo revient en phase `0`.
- `../games/web/includes/canvas/play/play-ws.js`
  - sur `demo_reset`, annule les flags locaux de fin statique/reconnexion supprimee avant reset UI/reload.

### Verification
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/games/bingo_ui.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`

## PATCH 2026-05-05 — Bingo GM iframe: invalidation localStorage apres reset demo termine

### Objectif
- corriger le bug residuel ou seule l'iframe organizer `embed=gm` reprenait une grille entierement cochee/verrouillee apres reset demo Bingo;
- conserver le contrat actuel: grilles assignees et rows `bingo_players` conservees;
- ne pas modifier `bingo.game/ws`.

### Audit
- Le scope local `game + sessionId + player_id + gridId` est correct pour une reprise pendant une partie, mais trop stable apres reset demo: le joueur GM garde le meme `player_id` et la meme grille.
- Les anciennes cases/locks peuvent donc rester prioritaires si elles sont lues avant que `grid_hydrate` reconstruise un etat vide depuis la DB resetee.
- La correction retenue ajoute une generation locale de reset, sans changer les writes DB ni le WS.

### Modifie
- `../games/web/includes/canvas/core/boot_organizer.js`
  - ecrit `bingo_reset_epoch:{sessionId}` apres `resetdemo` OK;
  - purge les cles `bingo_checked` / `bingo_locked` scoppées a la session et publie l'epoch dans le signal post-reset.
- `../games/web/includes/canvas/core/canvas_display.js`
  - transmet `bingo_reset_epoch` dans l'URL iframe GM;
  - envoie un `postMessage` de purge a l'iframe active avant de la recharger.
- `../games/web/includes/canvas/play/play-ui.js`
  - inclut l'epoch dans les cles locales checked/locked quand elle existe;
  - lit l'epoch depuis l'URL iframe ou `localStorage`;
  - trace la source appliquee par `grid_hydrate` (`local`, `db`, `empty`, `reset`) avec counts checked/locked.
- `../games/web/includes/canvas/play/play-ws.js`
  - aligne le fallback `emitGridIfAvailable()` sur les cles incluant l'epoch.

### Verification
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`

## PATCH 2026-05-05 — Bingo GM iframe: grille cochée/verrouillée

### Objectif
- corriger le bug bloquant Bingo mobile organizer: l'iframe joueur `embed=gm` affichait une grille entierement cochee et verrouillee des l'inscription;
- couvrir demo mobile, officielle mobile et preview demo desktop sans modifier les sessions papier ni les vrais joueurs QR;
- conserver `player_id` canonique `p:` comme identite principale, `playerId` numerique restant secondaire.

### Audit
- le flux serveur `player_register` / `grid_assign` / `grid_hydrate` garde une vraie grille assignee au joueur auto-GM;
- la corruption visible venait du front player: `play-ui.js` et le fallback `play-ws.js` pouvaient relire `bingo_checked` et `bingo_locked` globaux du navigateur sans prouver qu'ils appartenaient a la session, au `player_id` et a la grille courants;
- le verrouillage observe correspond a la reprise de `bingo_locked`, pas a un probleme CSS;
- les derniers correctifs pre-merge ont probablement rendu l'iframe GM plus deterministe, exposant un etat local stale qui pouvait deja exister.

### Modifie
- `../games/web/includes/canvas/play/play-ui.js`
  - introduit des cles locales scoppées par `game + sessionId + player_id + gridId` pour `bingo_checked` et `bingo_locked`;
  - ne relit plus les anciennes cles globales `bingo_checked` / `bingo_locked` et les supprime activement lors des sauvegardes;
  - n'utilise plus `bingo_grid_id` legacy pour construire le contexte de stockage des cases, afin qu'une nouvelle session ne puisse pas heriter de la grille precedente avant son `grid_assign`;
  - hydrate la grille Bingo depuis l'API avant de choisir entre etat local prouve et timestamps DB;
  - persiste les resets, clicks et locks dans le scope courant;
  - vide aussi `AppConfig.bingoChecked` / `AppConfig.bingoLocked` sur `reset_game`, pour eviter qu'un checked-set runtime stale soit repousse juste apres reset;
  - ajoute des traces `ui/bingo:grid_hydrate:trace` et `ui/bingo:grid_cells_sync:trace` pour distinguer requete, reponse, contexte et nombre de cases cochees.
- `../games/web/includes/canvas/play/play-ws.js`
  - remplace le fallback `emitGridIfAvailable()` sur `localStorage.bingo_checked` global par une resolution scoppée;
  - refuse d'emettre un checked-set local si `sessionId`, `player_id` et `gridId` ne correspondent pas.
  - purge les cles scoppées `bingo_checked` / `bingo_locked` de la session courante sur `demo_reset` et `reset_game`;
  - lit la grille du fallback checked uniquement via la cle scoppée `${game}:grid_id:${sessionId}`, jamais via `bingo_grid_id` legacy;
  - trace l'auth WS Bingo et le premier snapshot player Bingo via des evenements Bus de diagnostic.

### Invariants
- pas de correction CSS;
- aucune purge arbitraire d'une grille deja jouee;
- reprise apres reload conservee pour les cases reellement cochees du meme joueur et de la meme grille;
- session papier inchangee;
- preview demo desktop Bingo conservee;
- aucun changement WS Bingo ni schema DB.

### Tests
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`
- recette navigateur a faire avant prod: Bingo demo mobile, Bingo officielle mobile, Bingo demo desktop, joueur QR reel, reload d'une grille partiellement cochee.

## PATCH 2026-05-05 — Pre-merge: securisation iframe organizer

### Objectif
- traiter les deux risques pre-merge `develop -> main` sans elargir le scope fonctionnel;
- durcir la reception `postMessage` de `gm-player-ready`;
- eviter deux iframes joueur organizer actives en meme temps;
- ne pas modifier les regles metier des pseudos auto-GM.

### Modifie
- `../games/web/includes/canvas/core/canvas_display.js`
  - remplace le ciblage generique `[data-player-iframe="1"], #player-iframe` par une resolution explicite de l'iframe active;
  - charge la preview `demo-player-iframe` seulement pour la demo desktop;
  - charge `player-iframe` seulement pour l'onglet mobile numerique `Jouer`;
  - decharge les autres iframes organizer deja chargees quand une iframe devient active;
  - filtre `gm-player-ready` par origine attendue, source iframe connue et payload coherent session/jeu;
  - conserve Bingo avec grille assignee en exigeant identite + `gridId`/`gridNumber` dans le payload.

### Invariants
- demo desktop `embed=gm&demo_player=1` conservee;
- mobile numerique `Jouer` conserve;
- reprise/reload conservee;
- session papier mobile: aucune iframe auto;
- pas de changement `USERNAME_ALREADY_USED` pour `organizer_auto_player` / `gm_autoreg`.

### TODO
- si un display name GM identique a un joueur reel devient confus en UI, ajouter un suffixe visuel type `(orga)` sans modifier `player_id` ni l'upsert.

### Tests
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `git -C /home/romain/Cotton/games diff --check main...develop`
- `git -C /home/romain/Cotton/games diff --stat main...develop`
- recette navigateur a faire avant prod: Quiz/Blind Test/Bingo demo desktop + mobile, officielle mobile, collision pseudo GM, reload apres score.

## PATCH 2026-05-05 — Demo mobile: ouvrir d'abord l'experience joueur

### Objectif
- en demo mobile numerique, ouvrir la session sur `Vue joueur` pour montrer immediatement l'experience joueur;
- inverser visuellement le toggle demo mobile en `Vue joueur / Vue animateur`;
- respecter ensuite le choix manuel de l'utilisateur;
- ne pas modifier officiel mobile, desktop, QR joueur, scoring ni WS.

### Modifie
- `../games/web/organizer_canvas.php`
  - rend le toggle mobile en `Vue joueur / Vue animateur` seulement quand `flag_session_demo` / `isDemo` est actif;
  - conserve `Animer / Jouer` pour les sessions officielles;
  - sort la mention d'aide demo du bloc QR de la vue en attente et l'affiche au-dessus du QR, alignee a gauche;
  - ajoute la mention hors iframe:
    - Quiz: `Tu joues avec un profil d’Équipe démo.`
    - Blind Test / Bingo: `Tu joues avec un profil de Joueur démo.`
- `../games/web/includes/canvas/core/canvas_display.js`
  - initialise l'onglet mobile actif sur `Jouer` au premier passage en session demo mobile numerique;
  - garde les handlers lies aux IDs existants (`mobile-session-player-btn`, `mobile-session-organizer-btn`) pour ne pas inverser les etats internes;
  - persiste le choix demo mobile en `sessionStorage` scoppé par jeu + session, afin qu'une bascule volontaire vers `Animer` ne soit pas ecrasee par un render ou un reload du meme onglet;
  - ne change pas l'initialisation des sessions officielles.

### Tests
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `git -C /home/romain/Cotton/games diff --check`
- reste a faire en navigateur: demo mobile Quiz / Blind Test / Bingo, reload apres bascule `Animer`, officiel mobile, QR joueur reel.

## PATCH 2026-05-05 — Mobile officiel: stabilisation auto-player organizer

### Objectif
- empêcher l'iframe mobile organizer `Jouer` officielle de retomber sur le register manuel quand le profil auto est disponible;
- conserver le display name transmis par l'organizer (`prenom` ou fallback `Game Master`);
- ne pas modifier les vrais joueurs QR, les demos, le scoring ni les règles WS.

### Audit
- `organizer_canvas.php` expose deja `AppConfig.organizerAutoPlayerDisplayName` et affiche l'aide hors iframe;
- `canvas_display.js` construit l'URL iframe `embed=gm` et ajoute `gm_display_name` en officiel non-demo;
- `register.js` lit `gm_display_name` et auto-register le GM, mais court-circuitait l'auto-register si une identite locale existait pour la meme session;
- dans ce cas, la reprise standard pouvait garder l'identite apres un miss transient `players_get` sans appeler `setStage('play')` / `markPlayerRegistered()`, ce qui laissait `#playerForm` visible.
- addendum logs Bingo officiel 14:20: l'URL iframe etait correcte (`embed=gm&gm_display_name=Romain`) et le `player_register` partait au primo-boot, mais la reponse HTTP 500 arrivait avant `bingo_api_player_register][PLAYER_REGISTER_RX`;
- cause serveur addendum: les gardes `USERNAME_ALREADY_USED` / `USERNAME_REFERENCED`, prevus pour les joueurs QR manuels, pouvaient refuser le displayName auto organizer avant l'upsert par `player_id` canonique.

### Modifie
- `../games/web/includes/canvas/play/register.js`
  - ajoute une reprise dediee `embed=gm` pour une identite locale meme-session valide;
  - ajoute un etat UI `GM_AUTOREGISTERING` reserve a l'iframe organizer, utilise avant tout probe reseau lors du primo-boot;
  - marque immediatement l'UI comme inscrite, masque le formulaire, republie `player/ready` et `gm-player-ready`;
  - applique la meme reprise si le probe `players_get` / `bingoPlayerExists` rate ou echoue alors que l'identite locale GM est exploitable;
  - met a jour le nom local avec le `GM_NAME` courant pour conserver le prenom transmis, ou `Game Master` en fallback.
  - envoie `organizer_auto_player=1` / `gm_autoreg=1` sur le `player_register` auto-GM.
- `../games/web/player_canvas.php`
  - initialise les URLs `embed=gm` avec `data-gate-open="0"` et le message `Connexion de ton profil...` afin que le formulaire manuel ne soit pas visible avant l'execution des modules JS;
  - ne rend plus le bloc `Compte joueur Cotton` dans l'iframe `embed=gm`;
  - ne change pas le rendu initial des URLs QR reelles sans `embed=gm`.
- `../games/web/includes/canvas/core/canvas_display.js`
  - compare l'URL effective de l'iframe avec `dataset.src`;
  - recharge le `src` si une URL deja chargee diverge de l'URL calculee, afin de ne pas garder un ancien embed sans `gm_display_name`.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - acceptent le flag auto-GM et bypassent uniquement pour lui les controles de nom deja utilise / nom reference;
  - conservent les controles de nom pour les inscriptions QR manuelles et les flux EP classiques.

### Invariants
- les joueurs QR reels restent sur le formulaire manuel normal;
- les sessions demo gardent `Équipe démo` pour Quiz et `Joueur démo` pour Blind Test / Bingo;
- aucun changement scoring, DB schema, payload WS serveur ou parcours d'authentification;
- aucun fetch supplementaire du displayName: le nom deja expose par l'organizer est reutilise.
- le bypass d'unicite de nom est borne au flag `organizer_auto_player` emis par l'iframe `embed=gm`.

### Tests
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- reste a faire en navigateur: storage vide + ouverture directe `Jouer` sur Quiz / Blind Test / Bingo officiels mobiles, fallback `Game Master`, demo mobile, joueur QR reel.

## PATCH 2026-05-05 — Design organizer: merge-safe branding + titre/lots partiels

### Objectif
- securiser la propagation du design personnalise organizer vers player, remote et iframe demo;
- eviter qu'un save partiel couleur-only ou media-only vide des champs non modifies;
- conserver la suppression volontaire de logo/visuel via une intention explicite.

### Audit
- `../games/web/includes/canvas/core/session_modals.js` envoie le save branding vers `global_ajax.php?t=general&m=branding&action=save`, puis diffuse `branding/updated` en WS;
- `../games/web/player_canvas.php` et `../games/web/remote_canvas.php` relisent le branding effectif depuis `global_ajax.php?t=general&m=branding&action=get` au refresh/reconnexion;
- `../games/web/includes/canvas/php/prizes_glue.php` acceptait deja des updates partiels de lots, mais reconstruisait `mainTitle` a `''` si la cle etait absente;
- `quiz`, `blindtest` et `bingo` consomment cette chaine commune pour le branding runtime.

### Modifie
- `../games/web/includes/canvas/core/session_modals.js`
  - pose `logo_clear=1` ou `visuel_clear=1` uniquement quand l'utilisateur clique explicitement sur le reset/suppression du media;
  - annule ce marqueur quand un nouveau fichier logo/visuel est choisi.
  - relit le branding effectif renvoye par `branding_save` pour diffuser en WS un objet complet (`logo`, `visuel`, `visuelMode`, couleurs, police);
  - conserve aussi `b.logo` / `b.visuel` en fallback live si le serveur distant ne renvoie pas encore ce branding effectif.
- `../games/web/includes/canvas/php/prizes_glue.php`
  - `mainTitle` devient nullable sur le write interne;
  - une requete `prizes_save` sans cle `mainTitle` preserve `championnats_sessions.diffusion_message`.
- `../games/web/player_canvas.php` et `../games/web/remote_canvas.php`
  - le style initial `body` lit maintenant `var(--branding-font)` au lieu de figer la police PHP;
  - le lien de font initial porte `id="custom-font-link"` pour etre remplace par le flux live existant.
- `../games/web/config.php`
  - bump local `CANVAS_ASSET_VER` en `v=2026-05-05_19` pour forcer le rechargement des assets Canvas corriges.
- `../global/web/app/modules/general/branding/app_branding_ajax.php`
  - voir `canon/repos/global/TASKS.md`: merge serveur des couleurs/police et preservation des medias absents.

### Invariants
- pas de refonte UI;
- pas de changement WS player/remote;
- compatibilite conservee avec les payloads complets existants;
- l'absence d'une cle n'est plus une demande d'effacement.

### Tests
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/prizes_glue.php`
- `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_ajax.php`
- `php -l /home/romain/Cotton/games/web/config.php`
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `php -l /home/romain/Cotton/games/web/remote_canvas.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/session_modals.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js`

## PATCH 2026-05-05 — Organizer desktop/mobile: passe UX complémentaire

### Objectif
- ajouter un feedback léger pendant le diagnostic prelaunch automatique;
- afficher `équipe(s) connectée(s)` pour les compteurs participants Quiz uniquement;
- mieux séparer visuellement la preview joueur demo desktop de l'interface organizer;
- améliorer le confort de l'iframe joueur demo desktop, notamment les propositions Quiz / Blind Test et la grille Bingo.

### Modifie
- `../games/web/includes/canvas/core/canvas_display.js`
  - adapte uniquement le libellé du compteur participant selon le jeu: Quiz utilise `équipe connectée` / `équipes connectées`, Blind Test et Bingo gardent `joueur connecté` / `joueurs connectés`.
  - calcule pour la preview demo desktop une zone verticale disponible basée sur le viewport et la barre menu, indépendante de la hauteur du canvas organizer.
  - après confinement de la footerbar au panneau organizer, la zone joueur demo ne réserve plus toute la hauteur de menu côté rail téléphone.
- `../games/web/organizer_canvas.php`
  - déplace l'explication hors de la coque téléphone et supprime le libellé interne `Joueur démo / Scanne le QR code...`;
  - utilise le label demo cohérent avec le jeu au-dessus du téléphone: `Équipe démo` pour Quiz, `Joueur démo` pour Blind Test et Bingo.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - anime sobrement la diode `data-prelaunch-status="running"` du bouton `LANCER LE JEU`, avec garde `prefers-reduced-motion`;
  - donne au panneau desktop demo joueur un fond neutre sur toute la hauteur du viewport et une séparation visuelle plus claire;
  - élargit progressivement la coque téléphone et la réserve desktop associée, avec fallback compact sur desktop étroit.
  - autorise la coque téléphone à occuper la hauteur disponible en haut de page, tout en gardant une limite basse au-dessus de la barre menu.
  - contraint la footerbar à la largeur organizer uniquement en layout demo desktop avec preview joueur intégrée, en neutralisant le `w-100` Bootstrap, afin de libérer le bas du rail téléphone.
  - affiche le bloc explicatif au-dessus du téléphone et allège le padding haut de la coque maintenant qu'elle ne contient plus de texte de consigne.
- `../games/web/includes/canvas/css/player_styles.css`
  - retire la teinte interne du contexte `demo-player-embed` pour revenir au fond `primary-bg` du jeu;
  - augmente l'espace vertical des propositions Quiz / Blind Test dans l'iframe demo;
  - donne un peu plus d'air à la grille Bingo en iframe demo.

### Invariants
- aucun changement de flux métier, WS, scoring, inscription, lancement, prelaunch ou iframe;
- pas de nouveau composant;
- les ajustements player sont bornés à `html.demo-player-embed`;
- les vues joueur réelles hors preview demo ne sont pas ciblées;
- Blind Test et Bingo gardent le wording joueur.

### Tests
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `git -C /home/romain/Cotton/games diff --check -- web/includes/canvas/core/canvas_display.js web/includes/canvas/css/canvas_styles.css web/includes/canvas/css/player_styles.css`

## PATCH 2026-05-05 — Mobile officiel: nom visible du Game Master

### Objectif
- remplacer le libellé visible `Game Master` par le prénom du contact connecté quand l'organisateur utilise l'onglet `Jouer` en session officielle mobile;
- garder `Game Master` si aucun prénom de session fiable n'est disponible;
- préserver les labels demo existants: `Équipe démo` en Quiz, `Joueur démo` en Blind Test / Bingo.

### Source
- source prioritaire: `$_SESSION['client_contact_prenom']`, déjà alimentée par l'authentification espace client PRO et utilisée sur la home EC (`Bonjour ...`);
- fallback serveur si la session PRO n'est pas disponible côté `games`: `clients_logs.id_client_contact` sur la trace `clients_logs.nom LIKE "%Session #... > ajout%"` écrite par `app_session_ajouter()`, filtrée par `id_client`, puis `client_contact_get_detail()` pour récupérer `prenom`.

### Modifie
- `../games/web/organizer_canvas.php`
  - expose `AppConfig.organizerAutoPlayerDisplayName` depuis le prénom de session PRO ou, à défaut, depuis le contact attaché à la session, normalisé et tronqué;
  - affiche en session officielle mobile numerique, dans `#mobile-player-view`, l'aide hors iframe `Tu joues avec le profil {displayName}.`;
- `../games/web/includes/canvas/core/canvas_display.js`
  - transmet ce display name aux iframes organizer `embed=gm` officielles via `gm_display_name`;
  - ne transmet pas ce paramètre en session demo.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - style cette aide comme une petite ligne discrete, sans encadre ni impact sur l'iframe joueur;
- `../games/web/includes/canvas/play/register.js`
  - utilise `gm_display_name` comme nom visible du joueur auto officiel, avec fallback `Game Master`;
  - conserve les labels demo `Équipe démo` / `Joueur démo`;
  - ne change pas le `player_id` stable utilisé comme identité technique.

### Invariants
- aucun changement de scoring, WS, inscription QR, règles de lancement ou reprise;
- aucun nouveau parcours d'authentification ni requête additionnelle;
- les vrais joueurs QR ne reçoivent pas `gm_display_name`;
- la ligne d'aide n'est pas rendue en demo ni en session papier;
- si le prénom n'est pas disponible, le comportement reste `Game Master`.

### Tests
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- vérification statique: `Équipe démo` reste conditionné à Quiz dans `register.js` et `organizer_canvas.php`.

## PATCH 2026-05-05 — Mobile organizer V1: ajustements UX visuels

### Objectif
- ajuster uniquement le wording et le rendu visuel mobile organizer V1;
- ne pas toucher aux flux WS, scoring, auto-register, iframe joueur, reprise demo ou logique countdown;
- ne pas impacter le desktop.

### Modifie
- `../games/web/organizer_canvas.php`
  - remplace l'aide demo mobile sous QR par: `Flashe le QR code ou lance la démo et passe sur l'onglet "Jouer" pour tester l'expérience joueur.`
- `../games/web/includes/canvas/css/canvas_styles.css`
  - agrandit le cercle SVG et le chiffre du countdown en media query mobile uniquement;
  - addendum: force une boite SVG carree explicite en mobile (`width` + `height`), puis ajuste la taille et l'epaisseur pour eviter un rendu trop massif;
  - reduit les bordures colorees des blocs organizer mobiles a `2px` dans les vues attente / Animer / papier mobile;
  - reduit legerement le toggle mobile `Animer / Jouer` tout en conservant une hauteur tactile minimale de `44px`.

### Invariants
- aucun changement JS;
- aucun changement de timing countdown;
- aucun changement de comportement metier, WS, scoring, inscription joueur, iframe ou reprise demo;
- les overrides sont bornes aux breakpoints mobiles.

### Tests
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- verification statique: changements limites a `organizer_canvas.php` et `canvas_styles.css`.

## PATCH 2026-05-05 — Organizer mobile V1: stabilisation scoping desktop/mobile

### Objectif
- corriger la regression desktop introduite par la ligne mobile compacte `visuel + QR`;
- restaurer le layout organizer desktop historique pour Blind Test / Bingo Musical en cours: support a gauche, classement live au centre, preview joueur demo a droite si applicable, lots/QR/visuel dans la zone desktop normale;
- verifier que Quiz desktop ne recupere pas le bloc mobile compact;
- durcir la V1 mobile organizer sans ajouter de composant ni changer le metier;
- conserver les correctifs mobile valides: aide demo mobile, padding lots, ligne visuel + QR mobile, iframe `Jouer`, suppression du tag `VUE JOUEUR`, auto-register et noms demo.

### Audit
- `../games/web/includes/canvas/core/canvas_display.js::getPauseRow()` utilisait `document.querySelector('.pause-row')`;
- depuis l'ajout de `#mobile-session-followup`, la premiere `.pause-row` du DOM etait la ligne mobile `mobile-session-pause-row`, placee avant `#pause-container`;
- en desktop Blind Test / Bingo Musical, `teleportPauseRow('en-cours')` deplacait donc le bloc mobile compact dans le layout desktop au lieu de la ligne pause desktop historique;
- les styles du bloc mobile etaient principalement portes par des classes dediees, mais sans garde desktop explicite si le bloc etait detache de son wrapper `d-lg-none`.
- `setPhase()` peut appeler `showAll()` sur les blocs mobiles pendant `En cours`/`Pause`; le masquage desktop ne doit donc pas dependre uniquement de l'ordre des classes Bootstrap.
- les helpers de pause inter-series utilisaient encore des selectors globaux `.leaderboard-pause-tag` / `.leaderboard-info-tag`, susceptibles de toucher un tag mobile si l'ordre DOM change.

### Modifie
- `../games/web/includes/canvas/core/canvas_display.js`
  - `getPauseRow()` cible maintenant d'abord `#pause-container .pause-row:not(.mobile-session-pause-row)`;
  - le fallback ne regarde que le host de teleport desktop et exclut aussi `.mobile-session-pause-row`;
  - `showAll()` ignore les blocs `mobile-session-*` / `#mobile-player-view` quand le layout courant est desktop;
  - les selectors de pause inter-series passent par `getPauseStatusBlock()` au lieu de chercher le premier tag leaderboard global.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ajoute un garde `@media (min-width: 992px)` qui masque explicitement `#mobile-player-view`, `mobile-session-toggle-wrap`, `mobile-session-followup` et `mobile-session-pause-row` en desktop.
  - scope les styles desktop de `.pause-row` a `#pause-container` et `#pause-row-running-host` pour ne plus styler la ligne mobile compacte.

### Invariants
- aucun changement WS/scoring/rehydratation;
- aucun CTA inscription;
- le bloc compact `visuel + QR` reste disponible uniquement via la vue mobile organizer;
- la preview demo desktop `embed=gm&demo_player=1` conserve son chemin.

### Tests
- `cp /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js /tmp/canvas_display_check.mjs && node --check /tmp/canvas_display_check.mjs`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- verification statique: la ligne teleporteable desktop exclut `.mobile-session-pause-row`.

## PATCH 2026-05-04 — Mobile organizer: vue stable Animer / Jouer

### Objectif
- remplacer l'auto-affichage de l'iframe Game Master / participant par un toggle mobile `Animer / Jouer`;
- retirer les parcours d'inscription joueur pre-lancement cote organizer mobile, tout en conservant l'auto-register `embed=gm` apres lancement;
- ajouter une aide textuelle uniquement en demo mobile numerique en attente, sous le compteur joueurs du QR;
- harmoniser le libelle auto-inscrit en demo: `Équipe démo` pour Quiz, `Joueur démo` pour Blind Test et Bingo Musical;
- garder la meme structure mobile organizer pendant `En cours` et `Pause`;
- corriger l'UX de toutes les sessions mobiles numeriques lancees, demo comme officielles, sur Quiz / Blind Test / Bingo Musical:
  - proteger les blocs lots/QR de la barre d'actions mobile fixe dans `Animer`;
  - retirer le tag `VUE JOUEUR` et le cadre externe lourd autour de l'iframe dans `Jouer`;
- etendre le correctif UI mobile `Animer` aux sessions papier pour:
  - centrer la vague audio dans le bloc support;
  - remplacer le QR seul de bas de page par une ligne compacte visuel + QR;
- stabiliser la remontee immediate du joueur auto-inscrit dans le suivi mobile organizer apres auto-register `embed=gm`;
- stabiliser la reprise reload / continuation demo de l'identite auto-register organizer, sans doublon et sans formulaire d'inscription dans l'iframe;
- stabiliser la reprise demo mobile cote organizer `Animer`, sans attendre l'ouverture de l'onglet `Jouer`, et relayer les scores de l'iframe vers le suivi live;
- detecter la demo aussi dans l'iframe GM mobile, sans reutiliser le mode visuel desktop `demo_player=1`;
- conserver `#quiz-display` dans la posture `Animer`, y compris en pause;
- appliquer le meme principe aux sessions papier mobiles, sans toggle ni iframe joueur, en reutilisant `#mobile-session-followup` sous `#quiz-display`;
- reutiliser le rendu pause mobile existant sous `#quiz-display`, sans cards dediees;
- masquer toggle + blocs complements pendant le jingle de depart;
- garder une V1 pragmatique: pas de remote complete, pas de refonte organizer, pas de duplication des controles footerbar.

### Audit
- `../games/web/organizer_canvas.php` injectait `#player-interface` dans `#quiz-display` avec `d-lg-none`, donc visible uniquement mobile pendant `En cours`;
- la V1 precedente avait rendu cette iframe optionnelle, mais seulement via CTA ponctuel et seulement en `En cours`;
- `../games/web/includes/canvas/core/canvas_display.js` basculait encore vers `.en-pause` / `#pause-container` quand `setPhase('Pause')` etait appele;
- le bloc qui affiche `PAUSE` est `.leaderboard-pause-tag` dans `#pause-container`;
- le rendu pause/mobile session reutilisable est:
  - `.leaderboard.container-rounded-colored.p-3` + `.leaderboard-tag` + `.leaderboard-inner`;
  - `.pause-row` + `.pause-cell`;
  - `.lots-container`;
  - `.qr-container` + `.pause-qr-mask`;
- le jingle desktop/mobile est porte par `#intro-jingle-timer`, affiche par `showIntroCircleTimer()`, avec `status.loadingJingle` pendant la transition;
- le bloc organizer existant est le contenu deja present de `#quiz-display`: support, question/classement/notifs, options quiz desktop et blocs teleportes selon jeu;
- les donnees deja disponibles: compteur joueurs, rankings/players, lots, QR joueur, statut `status.gameStatus`;
- les controles de jeu restent dans la footerbar mobile existante, aucun controle n'est replique dans cette V1.

### Modifie
- `../games/web/organizer_canvas.php`
  - ajoute `#mobile-session-toggle-wrap` au-dessus de `#quiz-display`;
  - ajoute `#mobile-session-followup` sous `#quiz-display` en reprenant le markup/classes pause pour leaderboard, lots et QR;
  - ajoute l'id `#mobile-session-ranking-title` sur le tag joueurs existant pour permettre le libelle dynamique;
  - conserve `#mobile-player-view` et `#player-iframe` pour la posture `Jouer`;
  - retire le tag mobile `VUE JOUEUR` et la classe `container-rounded-colored` du wrapper mobile `#player-interface`, afin que l'iframe player paraisse integree sous le toggle;
  - remplace le QR mobile seul de `#mobile-session-followup` par une ligne compacte avec le visuel de jeu et le QR de rejointure;
  - ajoute en demo mobile numerique avant lancement l'aide sous le compteur joueurs: `Lance la démo, puis passe sur l’onglet Jouer pour tester l’expérience joueur.`;
  - n'affiche pas cette aide en session officielle ni en session papier;
  - aligne le libelle de preview demo desktop sur le jeu (`Équipe démo` pour Quiz, `Joueur démo` sinon).
- `../games/web/includes/canvas/play/register.js`
  - conserve `Game Master` pour l'auto-register `embed=gm` des sessions officielles numeriques;
  - utilise `Équipe démo` pour l'auto-register demo Quiz;
  - utilise `Joueur démo` pour l'auto-register demo Blind Test et Bingo Musical;
  - reconnait la demo mobile via `gm_demo=1`, en plus du flux desktop `demo_player=1`;
  - envoie au parent organizer un `postMessage` `gm-player-ready` avec l'identite complete du joueur auto-inscrit apres succes;
  - reprend directement l'identite GM locale scoppée a la session avant toute nouvelle inscription, pose `data-stage=play`, marque le joueur inscrit et republie `player/ready`;
  - si le stockage local manque, tente une reconciliation via `players_get` avant auto-register; les demos acceptent aussi l'ancien candidat `Game Master` cree par regression, mais republient le nom attendu du jeu;
  - loggue `register/autoreg:reconciled` avec source `local_identity`, `server_snapshot` ou `new_autoreg`, et `register/autoreg:reconcile_multiple_candidates` si plusieurs candidats sont trouves;
  - conserve l'identite canonique Bingo en `player_id` via le flux existant.
- `../games/web/includes/canvas/core/canvas_display.js`
  - garde un etat front local `__mobilePlayerActive`;
  - active la bascule uniquement si `status` vaut `En cours` ou `Pause`, layout mobile et mode numerique;
  - expose sur `body` la posture courante via `mobile-session-organizer-active` / `mobile-session-player-active`;
  - ajoute `isPaperMobileSession()` pour distinguer les sessions papier mobiles;
  - en pause mobile numerique, affiche `#quiz-display` et les blocs session mobile au lieu de `#pause-container`;
  - en papier mobile, affiche `#quiz-display` en cours comme en pause, puis reutilise `#mobile-session-followup` sous le jeu, sans afficher le toggle ni l'iframe joueur;
  - detecte le jingle via `status.loadingJingle` ou `#intro-jingle-timer` visible et masque temporairement toggle + suivi en mobile numerique comme papier;
  - rafraichit `#mobile-session-total-players` et `#mobile-session-ranking-list`;
  - met a jour le titre joueurs mobile via `status.gameStatus`: `Suivi des joueurs` en cours, `Pause` en pause;
  - expose le loader iframe par instance pour charger `#player-iframe` au clic sur `Jouer`.
  - ajoute `gm_demo=1` aux iframes GM des sessions demo sans appliquer `demo_player=1` a l'iframe mobile;
  - consomme `gm-player-ready`, merge le joueur auto-inscrit dans `GameStore.players`, puis rerend compteur et listes de suivi immediatement.
  - au bootstrap/reprise organizer, relit `players_get` pour hydrater le roster/score existant et restaurer l'identite auto-register en localStorage avant que l'onglet `Jouer` soit ouvert;
  - loggue `canvas_display:demo_autoreg:bootstrap_reconciled`, `canvas_display:demo_autoreg:score_resync` et `canvas_display:demo_autoreg:multiple_candidates`.
- `../games/web/includes/canvas/play/play-ui.js`
  - republie le message parent existant `gm-player-ready` quand le score/rang du player embarque change, afin que la vue `Animer` mobile mette a jour le suivi sans attendre une pause ou un snapshot long.
- `../games/web/includes/canvas/core/score_store.js`
  - `hydratePlayers()` conserve les joueurs existants quand un evenement serveur fournit seulement un total sans lignes joueurs detaillees.
- `../games/web/includes/canvas/core/ws_effects.js`
  - `updatePlayers` et `num_connected_players` ne traitent plus une liste vide avec total positif comme une purge de roster; ils conservent le roster local jusqu'au snapshot detaille suivant.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - rend le QR de rejointure `#mobile-session-qrcode`.
- `../games/web/includes/canvas/core/session_modals.js`
  - synchronise les lots du bloc mobile.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ajoute les styles du toggle, les espacements de session mobile et `.mobile-player-hidden` sous media query mobile;
  - borne l'aide demo QR au mobile numerique et masque l'ancien texte telephone sur mobile pour eviter deux aides concurrentes;
  - conserve les styles internes des blocs pause reutilises;
  - renforce la reserve basse de `#mobile-session-followup` uniquement en posture mobile numerique `Animer` non papier, pour proteger lots/QR de la barre d'actions fixe;
  - applique aussi en posture mobile `Animer` papier la reserve basse, le padding du bloc lots et la ligne compacte visuel + QR;
  - centre la vague audio dans `#quiz-support` en posture mobile `Animer`, via le wrapper YouTube en flex/absolute et une taille de SVG bornee;
  - allege `#mobile-player-view .mobile-player-interface` et supprime le rayon externe de l'iframe mobile pour eviter le double cadre en posture `Jouer`;
  - retire `.en-cours` de la marge mobile globale `6rem`, afin que `#quiz-display` ne cree pas de vide avant les blocs organizer;
  - cible la securite footerbar sur `#mobile-player-view` pour la posture `Jouer`, avec une hauteur minimale responsive sur `#player-iframe`;
  - reouvre legerement les marges entre toggle, `#quiz-display` et blocs organizer, pour eviter les quasi-chevauchements des tags absolus sans revenir aux grands vides.
  - masque `#quiz-leaderboard-overlay` uniquement sous `body[data-game="quiz"].mobile-session-organizer-active` en mobile, pour retirer le doublon `Point scores !` dans la posture `Animer`.
  - rend le bloc lots de `#mobile-session-followup` compact (`height:auto`, contenu en haut, liste rapprochee du titre) et porte la reserve footerbar sur le conteneur mobile commun, pas sur les cards.
- `../games/web/includes/canvas/core/canvas_display.js`
  - redemande au player son resize `gm-iframe-size-request` lors du passage a `Jouer`, en reutilisant le mecanisme iframe existant.
- `../games/web/includes/canvas/play/play-ui.js`
  - ajuste la mesure de hauteur `embed=gm` pour privilegier le contenu visible du document plutot que le `clientHeight` viewport quand celui-ci agrandit artificiellement l'iframe.
- `../games/web/includes/canvas/core/player/strategies/quiz.js`
  - corrige la branche Quiz numerique mobile: `#quiz-question` n'est plus masque quand la posture `Animer` est active;
  - rend cette detection robuste aux courses de rendu en croisant `body.mobile-session-organizer-active`, `status.gameStatus`, le toggle mobile et l'etat de `#mobile-player-view`;
  - conserve le masquage historique hors posture organizer, ou l'interface joueur peut prendre le relais.
- `../games/web/config.php`
  - bump local `CANVAS_ASSET_VER`.

### Invariants
- desktop inchange;
- avant session officielle et fin de session inchanges;
- modes papier mobile et desktop inchanges pour ces deux correctifs UX;
- pas de CTA d'inscription joueur pre-lancement, pas de `organizer_signup=1`, pas d'ouverture iframe player avant lancement pour inscrire l'organisateur;
- fonctionnement interne de l'iframe `embed=gm` inchange hors libelle demo;
- pas d'auto-register participant papier;
- le compteur mobile organizer ne doit plus rester durablement superieur a zero avec une liste de suivi vide apres auto-register GM;
- reload / reprise d'une meme session: l'iframe GM reutilise le meme `player_id` canonique et le meme id DB si disponibles; aucune creation silencieuse de doublon;
- reload / reprise demo mobile: la vue `Animer` hydrate aussi le joueur/score existant via snapshot serveur sans necessiter un passage prealable par `Jouer`;
- score live demo mobile: les changements de score de l'iframe GM sont repercutes dans le suivi organizer via le message parent existant `gm-player-ready`;
- pas de changement WS/API/DB.

### Limites
- la lisibilite mobile depend du responsive desktop existant;
- `#quiz-display` conserve la densite responsive existante;
- le jingle masque les complements mobiles, mais le rendu de `#quiz-display` reste celui de l'overlay existant;
- la question/support courant restent visibles dans `Animer`, donc l'organisateur qui joue depuis le meme telephone doit utiliser `Jouer` pour ne pas consulter la posture organizer;
- la hauteur iframe depend du resize fourni par le document player quand le contenu depasse le repli CSS;
- si un contenu player utilise des elements hors flux ou une hauteur CSS imposee, l'iframe peut encore scroller au lieu de coller exactement au contenu;
- une V2 pourra reprendre une logique inspiree remote si la V1 confirme le besoin.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/config.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/session_modals.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `git diff --check`

## PATCH 2026-05-04 — Demo iframe: préserver le GM mobile

### Objectif
- corriger l'effet de bord ou l'iframe Game Master mobile recevait aussi le mode `demo_player=1` en session demo;
- conserver la hauteur naturelle et le scroll page de l'iframe GM mobile historique.

### Modifie
- `../games/web/includes/canvas/core/canvas_display.js`
  - construit l'URL iframe par iframe;
  - ajoute `demo_player=1` uniquement a `#demo-player-iframe`;
  - retire explicitement ce parametre pour `#player-iframe` mobile.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- la `Vue joueur démo` desktop garde `embed=gm&demo_player=1`;
- l'iframe Game Master mobile garde seulement `embed=gm`;
- pas de changement quota/scoring/WS.

## PATCH 2026-05-04 — Demo desktop: wording Vue joueur

### Objectif
- clarifier le haut de la coque `Vue joueur` des demos desktop;
- inciter l'utilisateur a tester aussi la demo depuis un vrai mobile via QR code.

### Modifie
- `../games/web/organizer_canvas.php`
  - remplace le tag `Joueur démo` par `Vue joueur démo` + `Testez aussi sur votre mobile avec le QR code.`
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ajoute le style compact titre/sous-titre dans la coque telephone.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/config.php`

## PATCH 2026-05-04 — Demo quota: Joueur demo compte dans maxPlayers

### Objectif
- simplifier la regle produit des demos desktop: `Joueur démo` compte dans la limite affichee;
- avec une demo a 2 joueurs max, laisser 1 place mobile en plus du joueur automatique;
- harmoniser Quiz, Blind Test et Bingo.

### Modifie
- Cote `games`, pas de changement de flux player: l'iframe continue d'envoyer `demoParticipant:true` comme meta demo et conserve le libelle `Joueur démo`.
- Les serveurs WS Quiz/Blind Test/Bingo retirent l'exemption quota.

### Invariants
- scoring, classements et affichage live inchanges;
- sessions normales inchangees;
- Bingo conserve l'attribution de vraie grille via `grid_assign`.

## PATCH 2026-05-04 — Demo desktop Bingo: Vue joueur + Joueur demo

### Objectif
- etendre a Bingo Musical la preview desktop `Vue joueur` deja livree pour Quiz/Blind Test;
- reutiliser le flux iframe/player existant sans mock decoratif;
- attribuer une vraie grille Bingo a `Joueur démo`.

### Audit
- `../games/web/organizer_canvas.php` limitait encore le panneau aux demos `quiz`/`blindtest`.
- `../games/web/includes/canvas/play/register.js` savait deja auto-inscrire l'iframe `embed=gm` Bingo, utiliser `Joueur démo` si `demo_player=1`, appeler `grid_assign`, stocker `bingo_grid_secret` et emettre `player/ready`.
- `../games/web/includes/canvas/play/play-ws.js` envoyait `demoParticipant:true` pour Quiz/Blind Test via `registerPlayer`, mais pas encore sur l'auth Bingo `auth_player`.
- Le reset demo Bingo conserve deja le contrat documente: purge `bingo_phase_winners` + etats locaux player, conservation `bingo_players` et assignations de grilles.

### Modifie
- `../games/web/organizer_canvas.php`
  - active le panneau desktop `Vue joueur` pour les demos Bingo.
- `../games/web/includes/canvas/play/play-ws.js`
  - ajoute `demoParticipant:true` dans l'auth WS Bingo `auth_player` uniquement pour l'iframe `embed=gm&demo_player=1`.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- sessions Bingo normales inchangees;
- iframe Game Master mobile historique inchangee hors `demo_player=1`;
- QR demo principal conserve avec `Scannez le QR code pour tester aussi depuis votre téléphone.`;
- Quiz/Blind Test non modifies fonctionnellement dans cette passe.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/config.php`

## PATCH 2026-04-30 — Demo desktop: Vue joueur + Joueur demo

### Objectif
- rendre visible la boucle organizer -> joueur -> reponse -> score/classement dans les demos desktop;
- reutiliser le flux player existant sans masquer le QR code;
- nommer clairement le participant automatique `Joueur démo`.

### Modifie
- `../games/web/organizer_canvas.php`
  - ajoute un panneau desktop `Vue joueur` pour les demos Quiz/Blind Test;
  - conserve le QR code principal et ajoute le wording `Scannez le QR code pour tester aussi depuis votre téléphone.`
- `../games/web/includes/canvas/core/canvas_display.js`
  - gere plusieurs iframes player via `data-player-iframe`;
  - ajoute `demo_player=1` a l'URL iframe des sessions demo.
  - configure uniquement l'iframe desktop demo des `session/init` et force son chargement, pour eviter l'etat `about:blank` en attente sans modifier le declenchement mobile historique.
  - mesure le cockpit organizer reel avec `ResizeObserver` quand la preview desktop est visible, puis expose `--organizer-viewport-width` et `--organizer-qr-max-size`;
  - mesure l'union entre le header organizer et la scene organizer visible (`#waiting-container`, `#quiz-display`, `#pause-container`) et expose `--demo-player-scene-top` / `--demo-player-scene-height`.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - appelle explicitement la configuration de l'iframe demo apres `attachOrganizerUI()`, car le premier `session/init` est emis avant l'attache des listeners UI;
  - initialise les metriques de cockpit organizer pour recalculer le QR au redimensionnement.
- `../games/web/includes/canvas/play/register.js`
  - le mode iframe demo inscrit `Joueur démo`;
  - ne bloque pas l'auto-register demo sur une session deja full cote probe.
- `../games/web/includes/canvas/play/play-ws.js`
  - propage `demoParticipant:true` au WS comme meta demo; ce flag ne doit plus exclure ce joueur du quota.
- `../games/web/includes/canvas/play/play-ui.js`
  - ajoute la classe `demo-player-embed` uniquement au player `embed=gm&demo_player=1`, sans toucher au Game Master mobile.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - style du panneau desktop, du wording QR demo et de la coque telephone de preview;
  - masque le bloc explicatif `demo-player-copy` pour laisser plus de hauteur au telephone;
  - centre la coque telephone dans la hauteur utile de l'ecran desktop;
  - force l'iframe a remplir la largeur interne sans bordure native;
  - plafonne `#main-qr-container` et `.qr-svg` via `--organizer-qr-max-size` quand le layout demo player est actif;
  - cale le panneau `Vue joueur` sur la bande verticale mesuree de la scene organizer au lieu du viewport/safe area footer.
- `../games/web/includes/canvas/css/player_styles.css`
  - compacte uniquement le contenu embarque `demo-player-embed`;
  - ajoute une teinte de fond derivee de `--primary-bg`, sans imposer une couleur hors branding client;
  - donne une hauteur explicite a la zone scrollable dans l'iframe tout en forcant la footerbar score/classement visible;
  - ajoute les interactions souris desktop sur les elements cliquables;
  - applique `box-sizing:border-box` et `min-width:0` dans le scope embed pour eviter le rognage lateral sans reduire artificiellement le viewport.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Limites
- V1 limitee a Quiz et Blind Test; Bingo Musical reste a cadrer a cause de l'attribution de grille.
- La vue integree reutilise le parcours player reel `embed=gm`; aucun faux mock decoratif n'est ajoute.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/config.php`

## PATCH 2026-04-30 — Organizer: prelaunch reseau mobile sans faux orange navigateur

### Objectif
- reduire les faux positifs orange sur mobile 4G/5G quand les endpoints et le jeu sont fluides;
- identifier le declencheur du message `La connexion de cet appareil semble lente ou instable.`;
- reserver la vigilance orange reseau a une lenteur/instabilite applicative mesuree ou a un check reellement fragile.

### Audit
- le message est produit dans `prelaunch_check.js` quand la raison primaire est `network_profile`, `network_probe` ou `network_slow`;
- le faux positif mobile venait du check `network_profile`: `isSlowNetworkConnection(...)` convertissait des signaux `navigator.connection` (`effectiveType`, `downlink`, `rtt`, `saveData`) en `STATUS.WARN`;
- comme `hasSlowNetworkProfile(...)` considere `network_profile WARN` comme vigilance, ce signal navigateur seul suffisait a passer orange.

### Modifie
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - `checkNetworkProfile()` garde le rouge uniquement pour `navigator.onLine === false`;
  - les profils `type`, `effectiveType`, `downlink`, `rtt`, `saveData` sont affiches comme indicatifs en `STATUS.OK`;
  - l'orange reste porte par les checks applicatifs existants: bridge lent, `network_probe` lent/instable, WS ou autres signaux reels.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- prelaunch reseau conserve;
- cellulaire, inconnu, `effectiveType` prudent ou `downlink` faible ne bloquent pas et ne passent pas orange seuls;
- mode avion/offline reste rouge;
- endpoint/bridge/WS KO restent bloquants selon les regles existantes;
- API `navigator.connection` toujours optionnelle;
- scan supports multimedia non reintegre cote organizer.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `php -l /home/romain/Cotton/games/web/config.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-30 — Organizer: prelaunch reseau mobile non bloquant

### Objectif
- accepter les connexions mobiles 3G/4G/5G quand les tests applicatifs passent;
- ne plus convertir l'absence de Wi-Fi, un type cellulaire ou un `downlink` navigateur nul en diagnostic rouge;
- conserver le rouge pour les echecs reels: navigateur offline, bridge/WS indisponibles, timeout critique ou endpoint indispensable KO.

### Modifie
- `../games/web/includes/canvas/core/network_profile.js`
  - expose `navigator.connection.type` dans le snapshot et l'affichage du profil pour garder le transport en contexte;
  - reserve `isOfflineNetworkConnection()` a `navigator.onLine === false`;
  - ne traite plus `downlink <= 0` comme absence d'Internet exploitable.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- prelaunch reseau conserve;
- checks applicatifs `bridge`, `ws_open`, `ws_stability` et `network_probe` conserves;
- rouge toujours bloquant en cas d'offline ou d'echec applicatif bloquant;
- cellulaire/inconnu non bloquant si les checks applicatifs passent;
- scan supports multimedia non reintegre cote organizer;
- API `navigator.connection` optionnelle.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/network_profile.js`
- `php -l /home/romain/Cotton/games/web/config.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-30 — Organizer: prelaunch vert leger, orange/rouge explicites

### Objectif
- conserver une UX legere quand le prelaunch est vert: pas d'ouverture automatique de diagnostic, pas de confirmation demo;
- ouvrir automatiquement le diagnostic quand le prelaunch auto termine orange ou rouge, en demo comme en officiel;
- conserver les garde-fous de lancement rouge/orange/vert existants;
- rendre la confirmation officielle claire: vert avec lien discret, orange avec CTA secondaire diagnostic, rouge bloque.

### Modifie
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - remplace le titre/sous-titre de la modale par `Diagnostic avant lancement` et `Vérification de cet appareil, de la connexion et du son.`;
  - conserve le lancement automatique `runPrelaunchCheck(...)` au chargement et a la reprise en `En attente`;
  - ouvre automatiquement `showPrelaunchModal()` seulement quand l'auto-precheck finit en `warning` ou `fail`;
  - garde le verrou remote/diagnostic uniquement pour les etats `fail`, `running` et `untested`; les etats finaux vert/orange ne dependent plus d'une fermeture de modale.
  - ne publie plus les bandeaux prelaunch orange/rouge de l'auto-check tant que la session est encore `En attente`.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - conserve la modale officielle de lancement;
  - restaure l'icone SweetAlert `question` de la confirmation officielle, liee au titre comme en prod;
  - remplace le bouton `Annuler` par une croix de fermeture dans les confirmations prelaunch;
  - en officiel vert, affiche seulement l'avertissement metier, le CTA `✅ Oui, démarrer` et le lien discret `Diagnostic réseau et son` sous le CTA principal;
  - en officiel orange, affiche `Point à vérifier avant ta session` sans lien dans le message, puis un CTA secondaire `Voir le diagnostic`;
  - en demo vert, lance directement sans confirmation ni proposition `Tester le son`;
  - en demo orange, conserve la confirmation legere avec `Lancer la démo` et `Voir le diagnostic`;
  - conserve le blocage rouge avant la confirmation officielle: clic `Lancer` -> modale diagnostic, pas de lancement.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ajoute un lien officiel vert discret sous le CTA principal;
  - rend le CTA secondaire diagnostic en outline vigilance.
  - reserve l'espace de la croix sur le titre des confirmations de lancement pour eviter le chevauchement.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- prelaunch automatique conserve;
- seuils rouge/orange/vert inchanges;
- scan supports multimedia non reintegre cote organizer;
- bouton `Lancer` reste cliquable en rouge pour ouvrir le diagnostic;
- statut orange non bloquant;
- modale prelaunch existante et coupure automatique du jingle inchangees;
- pas de confirmation demo en vert;
- comportement de reprise/redemarrage des demos inchange.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `php -l /home/romain/Cotton/games/web/config.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-30 — Organizer: sessions demo prelaunch allegees

### Objectif
- alleger la premiere experience demo sur l'interface organizer;
- conserver le prelaunch automatique, ses seuils et les blocages de lancement;
- eviter l'ouverture automatique de la modale diagnostic au chargement des demos vertes.

### Modifie
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - detecte les sessions demo via `AppConfig`, `ServerSessionMeta` ou `ClientSessionMeta`;
  - conserve `runPrelaunchCheck({ trigger: 'auto_precheck' })` au chargement;
  - n'appelle plus automatiquement `showPrelaunchModal()` pour les demos vertes; orange/rouge rouvrent le diagnostic avec la regle cible du 2026-04-30;
  - ne maintient plus le garde remote/modal-dismissed sur une demo verte ou orange; rouge/running/untested restent gardes.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - ajoute une confirmation demo dediee au clic `Lancer`;
  - orange: message `La démo peut être lancée, mais un point est à surveiller.`, CTA principal `Lancer la démo`, CTA secondaire `Voir le diagnostic`;
  - vert: lancement direct sans confirmation;
  - les CTA secondaires ferment la confirmation et ouvrent la modale prelaunch existante, qui porte deja le controle jingle;
  - rouge/running/untested restent bloques avant lancement et rouvrent la modale diagnostic.
- `../games/web/includes/canvas/core/canvas_display.js`
  - inclut `ClientSessionMeta.isDemo` dans la detection de prelaunch requis pour la pastille et l'attente de fin d'auto-check.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ajoute le style compact de la confirmation demo.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- prelaunch automatique conserve;
- seuils rouge/orange/vert inchanges;
- scan supports multimedia non reintegre cote organizer;
- bouton `Lancer` reste cliquable en rouge: le clic ouvre le diagnostic sans lancer;
- fermeture de la modale coupe toujours le jingle temoin via le chemin existant;
- wording demo limite au jingle/player sur cet appareil, sans garantie d'audibilite future.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `php -l /home/romain/Cotton/games/web/config.php`

## PATCH 2026-04-29 — Organizer: prelaunch plus friendly

### Objectif
- rendre la modale prelaunch organizer moins froide et plus proche d'une checklist de preparation avant animation;
- conserver strictement le comportement existant du test configuration/connexion et du jingle temoin;
- corriger la priorite de garde au clic `Lancer`: une session future non ouverte doit afficher l'alerte de session non ouverte, pas la modale prelaunch non executee.

### Modifie
- `../games/web/includes/canvas/core/boot_organizer.js`
  - borne le blocage prelaunch du clic `Lancer` aux sessions en attente qui sont ouvertes ou demo;
  - laisse les sessions futures non ouvertes passer vers `gateStartWithSessionMeta()`, qui affiche l'alerte existante `Prepare ta session...`.
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - reformule le header en `On verifie que tout est pret`;
  - ajoute des icones de domaine, badges de statut compacts et CTAs `Relancer le test` dans les deux panneaux fixes;
  - simplifie les titres de panneaux en `Session et connexion` et `Son et medias`, sans sous-titre de panneau;
  - supprime les titres internes redondants avec les badges: le message principal porte directement l'information utile;
  - simplifie les succes: `La session est prete.` et `Le jingle a bien demarre sur cet appareil.`;
  - corrige le badge header des etats verts: `ready` affiche maintenant `Verifie`, pas `A surveiller`;
  - remplace le libelle rouge `Action requise` par `Action necessaire`;
  - conserve les deux panneaux visibles: `Session et connexion` et `Son et medias`;
  - conserve le statut factuel du jingle temoin: il verifie le demarrage du player sur cet appareil, pas l'audibilite.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - adoucit la modale avec fond chaud, cartes checklist, badges verts/oranges/rouges harmonises, icones plus visibles et spacing plus compact;
  - colore le fond des icones de domaine selon le niveau courant vert/orange/rouge;
  - allege le bandeau de statut interne pour reduire l'effet carte imbriquee;
  - aligne les actions recommandees a gauche avec indentation moderee;
  - rend la relance moins prioritaire quand le panneau est vert;
  - masque le sous-titre global sur mobile pour reduire la hauteur;
  - garde le responsive mobile en faisant passer badge et action sous le titre du panneau.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- logique metier prelaunch inchangee;
- seuils reseau inchanges;
- regles rouge/orange/vert inchangees;
- aucun endpoint, SQL ou WebSocket modifie;
- scan supports multimedia non reintegre cote organizer;
- fermeture de la modale coupe toujours le jingle temoin via le chemin existant.
- sessions futures non ouvertes: la modale prelaunch n'est plus ouverte au clic `Lancer`; le message de session non ouverte reprend la priorite.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `php -l /home/romain/Cotton/games/web/config.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-28 — Organizer: modale prelaunch en 2 panneaux fixes

### Follow-up
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - reformule uniquement les wordings visibles du parcours prelaunch actuel: titre/sous-titre de modale, panneaux connexion/direct et son/medias, statuts globaux, checks reseau, conseils, rappel de lancement et bandeaux;
  - retire le jargon visible des messages utilisateur (`WebSocket`, `localStorage`, `sessionStorage`, `Profil reseau navigateur`, `API YouTube`, `preflight`, `RTT`) au profit de formulations autour de la session, de Cotton, du direct joueurs, d'Internet et de cet appareil;
  - conserve les fonctions legacy de scan complet des supports multimedia et de remplacement temporaire sans reecriture de wording, puisqu'elles ne sont pas atteintes dans le parcours runtime actuel.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - reformule le rappel orange de confirmation de lancement et l'alerte fallback rouge sans employer `configuration`.
- `../games/web/includes/canvas/core/canvas_display.js`
  - reformule les tooltips runtime du bouton `Lancer` quand le prelaunch est en attente ou bloque.
- `../games/web/includes/canvas/core/network_profile.js`
  - remplace l'affichage brut `RTT` par une mention utilisateur `reponse ... ms`.
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - bloque le lancement du jingle temoin tant que le panneau configuration n'a pas termine son test;
  - ajoute un garde dans `runSoundControl()` pour eviter une collision meme si le bouton est force cote DOM;
  - recentre le panneau jingle temoin sur la verification factuelle du demarrage du player;
  - retire les statuts/raisons de resultat lies au volume ou au son, puisque le test ne peut pas confirmer que le son est entendu;
  - ajoute seulement en succes le conseil utilisateur: si le jingle n'est pas entendu, verifier les equipements/le volume puis relancer le test;
  - clarifie le diagnostic player/volume: un jingle temoin qui ne demarre pas signale un probleme de player/lecture, pas un probleme de volume;
  - evite d'ajouter `sound_user` en echec quand le jingle YouTube ne demarre pas, afin de ne pas afficher de conseil volume contradictoire;
  - rattache le check `player_link` au panneau connexion/configuration;
  - retire les mentions `rechargez cette page` des actions prelaunch au profit de `relancez ce test`;
  - remplace l'action stockage par `Evitez l'utilisation du navigateur en navigation privee et autorisez l'utilisation du stockage local.`;
  - supprime le bouton `Stop` du jingle temoin;
  - conserve la coupure automatique du jingle/test a la fermeture de la modale;
  - attend l'etat YouTube `PLAYING` avant de produire un resultat positif player/volume;
  - evite qu'une fermeture avant resultat soit interpretee comme un test valide.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - applique au bouton `Fermer` de la modale prelaunch le style du bouton principal de confirmation de lancement.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Objectif
- clarifier la difference entre un probleme configuration/connexion et un probleme player/son;
- garder les deux tests visibles des l'ouverture de la modale.

### Modifie
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - affiche deux panneaux fixes dans la modale prelaunch:
    - connexion/stabilite: test automatique, spinner, bloc resultat, relance ciblee;
    - player/volume: CTA jingle temoin, spinner pendant la lecture, bloc resultat, relance ciblee;
  - separe les raisons principales et les actions recommandees par domaine;
  - retire le CTA global `Recharger la page` de la modale: le footer garde seulement `Fermer`.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ajoute le layout de header de panneau et son comportement mobile.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `php -l /home/romain/Cotton/games/web/config.php`

## PATCH 2026-04-27 — Organizer: prelaunch recentre sur la configuration

### Objectif
- retirer le scan des supports multimedia de l'UI organizer;
- garder dans `games` uniquement un controle automatique de configuration du poste avant lancement;
- reporter le scan/correction des supports vers la fiche detail de session EC `pro`, plus adaptee aux actions de remplacement.

### Correctif livre
- `../games/web/organizer_canvas.php`
  - supprime le bouton footerbar `Verif`;
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - garde le code de scan supports dans le module, mais ne l'appelle plus depuis l'organizer;
  - lance automatiquement uniquement les checks techniques quand la session est dans une fenetre de lancement reelle;
  - aligne cette fenetre sur `window.ClientSessionMeta.isOpen`, deja utilise par le bouton `Lancer`, pour eviter un etat `Configuration non verifiee` permanent sur une session pourtant ouvrable;
  - ecoute maintenant les changements `navigator.connection` tant que la session est en attente et re-evalue seulement le check `network_profile`, afin que Slow 4G/retour reseau mette a jour la pastille `Lancer` et la confirmation sans refaire tout le prelaunch;
  - relit aussi `network_profile` apres la fin du prelaunch initial, avec un second passage differe, pour capter le profil DevTools deja actif au chargement mais expose tardivement par Chrome;
  - ajoute `network_probe`, un telechargement cache-buste d'un asset Cotton pour mesurer la connexion effective sur tous navigateurs;
  - ouvre la modale prelaunch au chargement organizer, affiche `Test de ta configuration en cours`, puis bascule sur la synthese et les actions;
  - force l'affichage de la synthese des que le test automatique produit un statut final (`ready`, `warning`, `fail`), afin d'eviter que la modale reste sur `Test termine / Affichage de la synthese...`;
  - ajuste le sous-titre de modale pour citer le poste et le reseau, retire les restes de l'ancienne synthese dans le corps et garde uniquement le reminder final apres l'etape automatique;
  - affiche le controle player/volume sous le reminder, quand il est utile, avec le style du bloc precedemment utilise dans la confirmation de lancement;
  - securise le layout du reminder pour que les conseils restent sous `Avant de demarrer, si possible :` ou `Actions a effectuer :`;
  - masque le CTA footer `Recharger la page` quand le resultat est vert et renomme le bouton audio `Jingle temoin`;
  - retire `media_dependency` de l'auto-check navigateur: le test player/lecture YouTube complet reste declenche par le bouton `Tester le player et le volume`, afin de profiter du geste utilisateur requis par le navigateur;
  - masque l'etape player/volume si l'etape configuration est rouge;
  - retire le rappel prelaunch et le controle audio de la confirmation de lancement, qui redevient une confirmation simple;
  - verrouille l'acces remote/QR remote tant que la modale prelaunch n'est pas fermee ou que le statut prelaunch est rouge;
  - retarde la popup papier d'invitation a ouvrir la telecommande jusqu'a la fermeture de la modale prelaunch, et ne l'affiche pas si la configuration reste rouge;
  - classe l'API YouTube bloquee en rouge si la session contient de vrais supports YouTube, et en vigilance si seul le jingle temoin est concerne;
  - applique des conseils utilisateur differencies pour connexion mesuree lente, mesure reseau incomplete, vigilance YouTube et blocage YouTube;
  - evite maintenant de republier le bandeau global orange/rouge quand le controle son met seulement a jour `audioProbe`;
  - aligne les bandeaux auto-precheck orange/rouge sur les phrases de synthese de la modale;
  - lance en parallele les checks independants apres ouverture WebSocket pour limiter le temps d'attente ajoute par `network_probe` et `media_dependency`;
  - place l'etape `Player et volume` dans la modale prelaunch, sous la synthese, avec un bouton `Tester le player et le volume` et un bouton `Stop` quand le jingle temoin est actif;
  - deduplique les conseils de lancement par intention pour eviter les actions quasi identiques quand plusieurs checks reseau echouent;
  - connecte le resultat du jingle temoin au check `media_dependency`, afin que le reminder et le blocage de lancement suivent un echec YouTube detecte au clic;
  - preserve le resultat du test termine quand l'utilisateur clique sur `Lancer`, au lieu de remettre l'etat a `untested` juste avant la confirmation;
  - expose le statut prelaunch sur le bouton `Lancer`;
  - ajoute le HTML de confirmation de lancement avec mini synthese + controle du son;
  - rend les messages orange et rouge plus explicites, avec jusqu'a 3 conseils cibles selon les checks en alerte ou bloquants;
  - ajuste les textes vert, non-verifie, QR et WebSocket pour rester comprehensibles cote utilisateur;
  - controle `localStorage` et `sessionStorage` dans l'etape navigateur; si le stockage est bloque, l'erreur devient bloquante et le prelaunch s'arrete avant les checks reseau pour eviter les faux diagnostics;
  - remplace le message rouge additionnel oriente connexion par un message generique sur les points signales;
  - remplace les invitations utilisateur a `relancer le test` par une demande de rechargement de page;
  - finalise le wording rouge autour de `Actions a effectuer` et de conseils simples par type de blocage;
  - finalise le wording orange autour de l'experience potentiellement moins fluide sur ce poste et de conseils cibles par type de vigilance;
  - bloque la confirmation de lancement si le statut config est rouge;
  - ajoute sous le verdict de confirmation une phrase sans prefixe technique, inspiree du wording utilisateur existant, pour expliquer le premier check bloquant ou en vigilance qui justifie `Configuration a surveiller` ou `Configuration a corriger`;
  - conserve le bouton `Stop` du jingle temoin et la coupure a la fermeture de la confirmation/modale.
- `../games/web/includes/canvas/core/network_profile.js`
  - centralise la detection de profil reseau lent pour prelaunch et player;
  - reprend les seuils player: audio `< 1.2 Mb/s`, video `< 2.0 Mb/s`, RTT `> 250 ms`, types `slow-2g/2g/3g` et `saveData`.
- `../games/web/includes/canvas/core/player/index.js`
  - consomme le module reseau partage pour le bandeau `Connexion lente detectee`;
  - n'affiche plus ce bandeau tant que la session est `En attente`, afin que le prelaunch reste l'unique alerte avant lancement.
- `../games/web/organizer_canvas.php`
  - ajoute l'alias importmap `@canvas/core/network_profile`.
- `../games/web/includes/canvas/core/session_modals.js` et `../games/web/includes/canvas/core/ws_effects.js`
  - protegent les acces stockage pendant le boot pour eviter qu'un `SecurityError` localStorage/sessionStorage ne provoque de faux diagnostics reseau.
- `../games/web/includes/canvas/core/canvas_display.js`
  - desactive le bouton `Lancer` tant que l'auto-check d'une session ouverte n'a pas produit un statut final;
  - laisse maintenant `Lancer` cliquable si le statut prelaunch est rouge, afin que le clic rouvre la modale de test sans lancer la session;
  - affiche seulement la pastille de statut sur `Lancer` en etat `En attente`.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - garde la confirmation de lancement simple;
  - bloque les demandes de lancement UI/remote si le prelaunch est rouge ou si le garde-fou remote est encore actif;
  - affiche un rappel leger `Configuration a surveiller - voir le test` dans la confirmation de lancement quand le prelaunch est orange, afin de rouvrir la modale de diagnostic sans recharger;
  - expose le helper de rappel orange au scope du portail de lancement pour eviter une erreur runtime avant affichage de la SweetAlert;
  - attend la fin/fermeture du prelaunch avant d'afficher la popup papier de telecommande.
- `../games/web/includes/canvas/core/session_modals.js`
  - empeche l'auto-ouverture du QR remote papier tant que le garde-fou prelaunch est actif.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - deplace les pastilles prelaunch du bouton `Verif` supprime vers le bouton `Lancer`;
  - ajoute le style du bloc audio dans la confirmation de lancement.
  - ajoute le style de la raison principale dans le rappel de confirmation.
  - remonte les z-index des modales Bootstrap/SweetAlert au-dessus du bouton quit flottant mobile.
  - laisse le padding natif de la liste des conseils prelaunch dans la confirmation de lancement.

### Effet attendu
- organizer reste centre sur la capacite du poste a lancer/animer;
- les supports multimedia ne sont plus scannes ni affiches dans l'organizer;
- les corrections de supports seront traitees cote `pro`, la ou les actions de remplacement existent deja.

### Verification
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js /tmp/boot_organizer.mjs && node --check /tmp/boot_organizer.mjs`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js /tmp/canvas_display.mjs && node --check /tmp/canvas_display.mjs`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-27 — Organizer: stop du jingle temoin prelaunch

### Objectif
- permettre a l'organisateur de couper le jingle temoin lance depuis la synthese du test prelaunch;
- eviter qu'un test de son continue a jouer si l'organisateur ferme la modale.

### Correctif livre
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - ajoute un controle interne du media de test audio en cours;
  - affiche un bouton `Stop` a cote de `Lancer le jingle temoin` quand le test sonore est actif;
  - coupe le son actif sur clic `Stop`;
  - coupe aussi le son sur fermeture de la modale (`hide.bs.modal` / `hidden.bs.modal` et fermeture programmatique).

### Verification
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-27 — Organizer: injection JSON inline durcie

### Objectif
- corriger un chargement DOM incomplet observe sur `organizer_canvas.php` pour une session demo `quiz` avec le lot `L246` (`Tubes des annees 80`);
- eviter qu'une donnee de playlist, de lot, de branding ou de preload contenant une sequence HTML sensible casse une balise `<script>` inline et empeche le rendu de la footerbar organizer.

### Correctif livre
- `../games/web/organizer_canvas.php`
  - ajoute le helper `canvas_inline_json(...)`;
  - encode toutes les donnees injectees dans les scripts inline avec `JSON_HEX_TAG`, `JSON_HEX_AMP`, `JSON_HEX_APOS`, `JSON_HEX_QUOT` et `JSON_INVALID_UTF8_SUBSTITUTE`;
  - applique ce durcissement a `ServerSessionMeta`, `Preload`, `AppConfig`, `GameMeta`, branding, defaults design, titre et lots de session.

### Effet attendu
- une valeur issue d'un lot ou d'un preload ne peut plus fermer prematurement une balise `<script>` via `</script>` ni produire un JSON vide a cause d'un octet UTF-8 invalide;
- le DOM organizer doit continuer jusqu'a la footerbar, y compris sur les sessions demo avec contenus atypiques.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-24 — Organizer: pre-check auto et blocage strict du lancement

### Objectif
- lancer automatiquement l'etape 1 du test organizer au chargement de page;
- reutiliser la footerbar existante (`Test`, bandeau, `Lancer`) pour refléter ce pre-check sans lancer tout le module;
- reserver le blocage de `Lancer` aux seules incompatibilites vraiment critiques.

### Correctif livre
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - introduit un etat runtime `inactive / auto_running / manual_running / completed / cancelled`;
  - ajoute un mode `auto_precheck` qui s'arrete apres les checks techniques;
  - ne lance ni scan multimedia ni controle du son dans ce mode auto;
  - conserve le test complet derriere le bouton `Test`;
  - masque `Test` et annule tout scan en cours des que le jeu quitte `En attente`;
  - relance un pre-check auto si l'organizer revient ensuite en `En attente`;
  - corrige une regression perf post-lancement: le subscribe organizer ne recancel plus le prelaunch sur chaque patch du store apres sortie de `En attente`, mais seulement sur transition reelle de `gameStatus`;
  - verrouille aussi `initPrelaunchCheck()` pour eviter un double abonnement si le module est reinitialise;
  - recale le rouge sur les seuls checks critiques de lancement, et degrade les autres echecs en vigilance orange;
  - reutilise le bandeau organizer partage orange/rouge selon le resultat, au lieu d'un conteneur dedie;
  - pour l'orange, reprend maintenant le wording `Connexion lente detectee...` et un TTL de `5s`, identique au bandeau de connexion lente pendant le jeu;
  - le rouge `Configuration incompatible` utilise maintenant lui aussi un TTL de `5s`.
  - ajuste maintenant le wording utilisateur du module pour un ton plus simple et plus oriente animation:
    - intro modale et note de prudence simplifiees;
    - etape 1 renommee `Connexion et stabilite`;
    - libelles techniques raccourcis (`connexion Cotton`, `direct`, `acces joueur`, `connexion`, `supports`);
    - synthese technique reformulee en `configuration verifiee / a surveiller / a corriger`;
    - diagnostics supports/YouTube/media simplifies, sans mention `Controle catalogue Cotton` cote utilisateur;
    - bloc son reformule en guidance animateur simple;
    - bandeaux auto-precheck, titres runtime du bouton `Test` et rappel de lancement alignes sur ce meme ton.
  - ajuste maintenant la phrase de synthese principale pour distinguer:
    - problemes de connexion uniquement;
    - problemes de supports uniquement;
    - cas mixtes connexion + supports;
    - cas OK.
  - evite ainsi un faux message `connexion a surveiller` quand le seul probleme detecte concerne un ou plusieurs supports multimedia.
  - pendant le scan de l'etape 2, la ligne en cours n'affiche plus titre/artiste/question/reponse:
    - elle montre maintenant `Verification du support n° X` puis `On verifie ce lien...`;
    - le detail complet reste conserve dans le bloc de remplacement/correction apres scan.
- `../games/web/organizer_canvas.php`
  - le libelle visible du bouton organizer passe maintenant de `Test` a `Verif`.
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - le tooltip runtime du bouton organizer est maintenant fixe a `Verifier la configuration avant lancement`, sans reprendre le statut runtime dans le titre.
- `../games/web/includes/canvas/core/canvas_display.js`
  - remonte les bandeaux partages au-dessus de la footerbar organizer via un offset calcule sur la vraie hauteur de `.organisateur-menu`;
  - supprime la dependance a `jingleReady` pour le tout premier lancement en etat `En attente`, afin d'eviter un bouton `Lancer` bloque alors que le jingle n'est prime qu'au clic;
  - rerend explicitement les controles footerbar sur les evenements `prelaunch/*`, pour sortir proprement d'un etat `running` du pre-check auto;
  - desactive `Lancer` tant que le pre-check auto ou le test manuel tournent, puis uniquement si le statut final est rouge;
  - masque `Test` dans tous les etats hors `En attente`;
  - aligne aussi le tooltip bloquant de `Lancer` sur le nouveau wording prelaunch.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - annule explicitement le test en cours des la demande de lancement (`ui` / `remote`) pour eviter toute concurrence scan/lancement.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ne garde que le style modal prelaunch; le layout de bandeau dedie est retire.

### Effet attendu
- en arrivant sur organizer, la pastille `Test` reflète deja l'etat minimal du poste;
- un cas OK laisse `Lancer` actif sans bandeau;
- un cas a surveiller affiche le bandeau orange mais laisse `Lancer` actif;
- un cas incompatible affiche le bandeau rouge et desactive `Lancer`;
- le clic sur `Test` reste la porte d'entree vers le diagnostic complet.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js /tmp/canvas_display.mjs && node --check /tmp/canvas_display.mjs`
- `npm run docs:sitemap`

## PATCH 2026-04-23 — Organizer: test pre-lancement V1 UX auto + synthese

### Objectif
- ajouter dans `games` uniquement un test pre-lancement compact, manuel et session-bound;
- aider l'organisateur a detecter les causes de lancement rate avant de cliquer `Lancer`;
- rester centre organizer sans pre-scan `pro` ni refonte large.
- simplifier l'UX en un enchainement automatique technique puis supports multimedia, suivi d'une synthese persistante;
- supprimer le bandeau global de statut dans la modale, au profit d'un statut par etape.

### Correctif livre
- `../games/web/organizer_canvas.php`
  - ajoute l'alias import map `@canvas/core/prelaunch_check`;
  - ajoute le CTA `bi-shield-check` dans la footerbar, a cote du bouton de lancement;
  - le bouton expose un etat visuel neutre / vert / orange / rouge / running.
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - nouveau module V1 de diagnostic organizer;
  - rendu en deux vues lisibles:
    - bloc de test automatique: `Etape 1 — Verifications techniques`, puis `Etape 2 — Verification des supports multimedia`;
    - synthese courte avec recommandations actionnables, remplacements de liens et controle du son, sans intro redondante avec le titre de modale;
  - checks automatiques: boot, stockage local, contexte session, bridge `session_meta_get`, WS ouverte, stabilite courte, lien joueur / QR;
  - l'etape 1 affiche uniquement le controle courant pendant l'analyse, avec statut `en cours` puis vert/orange/rouge, puis une synthese en fin d'etape;
  - preflight de fluidite minimale: l'etape 1 mesure les signaux observables cote organizer (latence bridge, delai d'ouverture WS, stabilite courte, profil `navigator.connection` si disponible, disponibilite/latence YouTube si des supports YouTube sont detectes) et remonte une vigilance si l'environnement semble fragile;
  - si l'etape 1 detecte une connexion indisponible ou une WebSocket KO/instable, le flux s'arrete avant le scan des supports multimedia;
  - le profil navigateur `navigator.onLine === false` est affiche comme `Connexion Internet indisponible`, avec une recommandation dediee de reconnexion; `downlink` reste un signal de qualite reseau, pas un critere offline;
  - les messages utilisateur du controle bridge sont reformules sans jargon (`Communication avec l’application`, delai inhabituel, application indisponible) et ne parlent plus de `Bridge` ou de `connexion Cotton`;
  - si l'etape 1 detecte seulement un profil reseau marque lent selon les memes seuils que le player principal (`saveData`, `slow-2g`/`2g`/`3g`, downlink audio/video insuffisant, RTT eleve) ou une latence applicative mesuree > 2500 ms, le flux affiche une vigilance forte, ne lance pas le scan media et laisse l'organizer ameliorer le reseau ou accepter le risque au lancement;
  - le scan des supports reels depuis `GameStore.playlist.songs` s'enchaine automatiquement apres les verifications techniques, avec affichage du support courant pendant l'analyse;
  - le jingle commun `isJingle` est exclu du scan media, puis reutilise comme temoin pour le controle du son en synthese quand il est disponible;
  - a la fin des etapes automatiques, la modale bascule sur une synthese plus legere, qui devient aussi l'affichage par defaut lors d'une reouverture apres test;
  - la synthese ne presente plus un verdict technique brutal: elle distingue absence de blocage, points a surveiller et risque de lancement perturbe;
  - les supports multimedia problematiques ne font plus basculer la synthese en rouge: ils restent en vigilance, avec remplacement optionnel;
  - lecture read-only des diagnostics catalogue YouTube via `youtube_catalog_diagnostics_get` avant le test iframe/local;
  - cette lecture consomme les resultats deja persistés par `pro` dans `content_links_check_results`, sans appel YouTube Data API depuis `games` et sans controle de fraicheur en V1.1;
  - diagnostic YouTube via API iframe et diagnostic media direct via chargement metadata;
  - le timeout de probe YouTube du prelaunch est aligne sur la fenetre haute du player principal (15 s, 20 s en profil lent) et un timeout est classe `A valider manuellement`, pas comme lien inactif;
  - classification prudente: `OK`, `Suspect`, `Casse`, `Bloque par l'environnement`, `A valider manuellement`.
  - remplacements temporaires session-only pour les supports problematiques:
    - raccourci de recherche `YT Music` pour les titres musicaux;
    - affichage de la bonne reponse sous la question pour les supports video quiz, y compris sur une synthese deja stockee, et utilisation de cette bonne reponse comme requete `YouTube` prioritaire quand elle est disponible;
    - saisie d'un lien temporaire;
    - test du lien dans l'environnement organizer;
    - application a `GameStore.playlist.songs` si le test est OK;
    - normalisation du lien temporaire avant injection runtime: les liens YouTube/Music/shorts/embed sont convertis en URL `youtube.com/watch?v=...` exploitable par le player, avec conservation des bornes `t/start` et `end` quand elles existent;
    - application d'un lien temporaire sans relancer tout le test: la ligne support et la synthese sont mises a jour directement a partir du test deja valide;
    - restauration du lien d'origine sans relance automatique, avec invitation a relancer le test si l'organizer veut reverifier;
    - stockage limite a `sessionStorage`, sans write bridge ni modification base;
    - action de retour au lien d'origine.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - initialise le module apres attache UI;
  - enrichit la confirmation `Lancer la session maintenant ?` avec le dernier etat du test.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - styles du CTA footerbar, etat visuel, modale de diagnostic, cartes d'etapes, ligne courante avec statut individuel, liens de recherche, rappel de lancement.
- `../games/web/includes/canvas/core/logger.global.js`
  - ajoute les evenements `PRELAUNCH_START`, `PRELAUNCH_CHECK`, `PRELAUNCH_COMPLETE`;
  - ajoute les evenements de remediation `PRELAUNCH_REPLACEMENT_TEST`, `PRELAUNCH_REPLACEMENT_APPLY`, `PRELAUNCH_REPLACEMENT_RESET`.

### Effet attendu
- l'organisateur peut lancer et relancer un diagnostic court juste avant lancement;
- a l'ouverture d'un nouveau test, seul le bloc de progression automatique est visible;
- aucun bandeau global de statut n'est affiche en haut de la modale;
- si la technique est OK, la synthese garde seulement une mention discrete;
- si la technique est exploitable mais fragile, l'UI propose des ameliorations possibles sans bloquer abusivement;
- si la technique echoue, l'UI explique simplement pourquoi le lancement peut etre perturbe et liste les points a corriger;
- si la connexion Internet est indisponible ou que la WebSocket est KO/instable, la synthese indique que l'app Cotton a besoin d'une connexion stable et suffisante, masque la verification des supports et propose uniquement `Relancer le test`;
- si le profil reseau est lent mais encore exploitable, ou si l'appel applicatif preflight mesure une latence > 2500 ms, la synthese indique que le jeu peut fonctionner avec des supports moins fluides ou ignores; elle ne propose plus de scan exhaustif dans cet environnement pour eviter les faux diagnostics;
- si le bridge ou la WebSocket sont seulement lents mais encore fonctionnels, le test reste en vigilance et peut continuer vers le scan media.
- l'etape media demarre automatiquement apres l'etape technique et affiche seulement le support courant pendant la verification;
- la synthese affiche seulement les blocs utiles: recommandations techniques si necessaire, supports problematiques avec remplacement temporaire, puis controle du son;
- les blocs `Configuration technique`, `Supports multimedia` et `Controle du son` sont espaces pour ameliorer la lecture;
- le bloc supports adapte son wording au jeu: questions perturbees pour `Quiz`, morceaux perturbes pour `Blind Test` / `Bingo Musical`;
- le controle du son est integre a la synthese sous forme d'action simple `Lancer le jingle temoin`, sans confirmation utilisateur ni statut artificiel `Son OK / non valide`; le jingle temoin n'est plus coupe volontairement avant sa fin naturelle;
- dans le bloc de remplacement, les liens `YT Music` / `YouTube` sont affiches sous `Lien temporaire de remplacement`; la mention session-only redondante est retiree.
- pour `Quiz`, la recherche `YouTube` de remplacement part de la bonne reponse quand elle existe, avec la question uniquement en secours.
- apres un test deja effectue, rouvrir la modale affiche directement cette synthese, avec possibilite de corriger les liens ou de relancer le test;
- l'etat reste visible dans la footerbar et reapparait dans la confirmation de lancement;
- `Blind Test` et `Bingo Musical` remontent les problemes audio comme critiques;
- `Quiz` ne demande pas de validation audio/video si la session ne contient pas de support media;
- les supports YouTube/media sont diagnostiques sur l'environnement reel sans promesse de garantie absolue.
- un timeout YouTube pendant le scan signale un environnement trop lent pour conclure, sans marquer le lien comme inactif;
- si le scan `pro` a deja marque un support YouTube comme indisponible/non public/non integrable/age-gate/live/bloque FR, l'etape media le remonte immediatement avant meme le test iframe organizer.
- les liens temporaires corrigent uniquement le runtime de la session en cours et ne remplacent pas une correction durable admin/base.

### TODO suite
- adapter le cron journalier pour alimenter regulierement `content_links_check_results`;
- prevoir un flux admin de signalement/correction durable pour les liens source problematiques detectes par le test pre-lancement.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js /tmp/boot_organizer.mjs && node --check /tmp/boot_organizer.mjs`
- `npm run docs:sitemap`

## PATCH 2026-04-17 — Bingo demo reset: purge winners + cleanup player local state

### Objectif
- corriger le cas ou une session demo `Bingo Musical` etait relancee avec un reset DB incomplet du point de vue metier et un etat joueur encore sale cote navigateur;
- eviter qu'un restart demo conserve des gagnants de phase precedents ou que le player reinjecte ses anciennes coches/locks apres `demo_reset`.

### Correctif livre
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - `_bingo_reset_demo_state(...)` supprime maintenant aussi les lignes `bingo_phase_winners` de la session pendant `resetdemo`;
  - le reste du contrat demo est conserve: joueurs et assignations de grilles restent en place, seules les traces de partie sont remises a zero.
- `../games/web/includes/canvas/play/play-ws.js`
  - a la reception de `demo_reset`, le player Bingo bascule maintenant tout de suite son UI sur `En attente`, remet `mainStarted` a `false`, reset la grille, puis purge `bingo_checked`, `bingo_locked` et `bingo_best_phase` avant le reload.

### Effet attendu
- une demo Bingo relancee repart sans anciens gagnants de phase dans le preload organizer/remote;
- le player ne reapplique plus ses anciennes coches/locks locales apres le reset demo;
- `reset` (flux de start) reste inchange.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `node --check /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`
  - non exploitable tel quel ici: fichier ESM navigateur avec imports `@canvas/*`.

## PATCH 2026-04-17 — Remote podium: upload distinct par gagnant en cas d'ex aequo

### Objectif
- aligner la remote `games` sur le comportement deja livre cote `pro` pour les photos podium;
- eviter qu'un upload fait sur un rang partage (`#1 / #1`, etc.) ecrase ou reutilise implicitement la photo du premier gagnant trouve;
- permettre un bouton photo par gagnant reel, meme quand plusieurs participants partagent la meme place.

### Correctif livre
- `../games/web/includes/canvas/php/boot_lib.php`
  - `session_meta_get` remonte maintenant toutes les lignes de podium `1..3`, meme quand une ligne n'a pas encore de photo;
  - chaque ligne conserve `photo_row_key`, `label`, `score`, `phase_label`, `photo_src`.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - le preload `serverSessionMeta.podium_photos` suit maintenant la meme regle: toutes les lignes podium sont exposees, pas seulement celles qui ont deja une image.
- `../games/web/includes/canvas/remote/remote-ui.js`
  - le rendu de fin de partie ne raisonne plus uniquement `par rang`;
  - chaque ligne visible du podium essaie maintenant de matcher sa propre row meta via `photo_row_key`, puis via `rang + libelle + phase/score`;
  - le CTA photo transporte desormais `rank + photo_row_key`, donc l'upload peut cibler le bon gagnant sur un rang partage;
  - un refresh `session_meta_get` est aussi force a la reception de `remote/end` pour hydrater rapidement les row keys sur une remote deja ouverte.

### Effet attendu
- si deux gagnants sont ex aequo sur une meme marche du podium, chacun peut recevoir sa propre photo depuis la remote;
- une photo deja presente reste rattachee au bon gagnant au rerender, au lieu d'etre dupliquee par simple rang.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `node --check /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js` non exploitable tel quel dans la sandbox:
  - fichier ESM navigateur;
  - imports `@canvas/*` non resolus hors runtime web.

## PATCH 2026-04-16 — Quit joueur runtime: purge LS scallee sur la session

### Objectif
- corriger le cas ou un joueur runtime quitte volontairement la session puis revient sur la page;
- eviter qu'une identite locale session-scope survive au quit et fasse croire au portail player qu'un joueur est deja encore inscrit.

### Correctif livre
- `../games/web/includes/canvas/play/play-ui.js`
  - le quit volontaire purge maintenant aussi l'identite runtime scallee sur la session via `clearPlayerIdentityForSession({ game, sid })`;
  - supprime en plus les residus legacy et session-scope qui pouvaient survivre au quit:
    - `${slug}:player_db_id`
    - `player-registered_${sessionId}`
    - pour `bingo`, `${slug}:grid_id:${sessionId}` et `${slug}:grid_number:${sessionId}`

### Effet attendu
- apres un quit volontaire, un retour sur la page retombe bien sur le formulaire d'inscription;
- un joueur runtime peut se reinscrire avec un nouveau pseudo au lieu d'etre bloque par une identite LS fantome.

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`

## PATCH 2026-04-16 — Redirections de sortie `master`/`play`

### Objectif
- renvoyer les demos `master` vers leur vrai point d'entree `pro` au lieu d'une regle historique liee a un seul `id_client`;
- uniformiser la sortie `play` vers la home du site.

### Correctif livre
- `../games/web/includes/canvas/core/end_game.js`
  - detection demo basee sur `AppConfig.isDemoSession`;
  - memorisation d'un `return_url` explicite ou d'un referrer `pro` valide, scope par session;
  - reutilisation de cette origine au quit du `master`.
- `../games/web/organizer_canvas.php`
  - expose `isDemoSession` dans `AppConfig`.
- `../games/web/modules/app_play_ajax.php`
  - remplace l'ancienne cible catalogue par la home `www` pour `URLPROMO`.

### Cote `pro` branche sur ce patch
- `../pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- `../pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `../pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
- `../pro/web/ec/modules/tunnel/start/ec_start_script.php`
- `../pro/web/ec/modules/compte/client/ec_client_script.php`
  - propagent `return_url` sur les ouvertures demo `games/master`.

## PATCH 2026-04-16 — Remote fin de partie: upload podium direct + CTA `pro` retire

### Objectif
- supprimer la dependance au contexte `pro` mobile pour l'ajout des photos gagnants depuis la remote;
- permettre un upload direct dans `games`, tout en gardant `master` et la fiche detail `pro` synchronises sur la meme source de verite;
- simplifier aussi l'UX du podium remote en fin de partie avec un rendu `3` lignes + CTA photo explicite en fin de ligne.

### Correctif livre
- `../games/web/includes/canvas/php/boot_lib.php`
  - ajoute l'action bridge `session_podium_photo_upload`;
  - appelle `app_session_results_podium_photo_upload(...)` puis renvoie un `session_meta_get` frais pour rerender immediat.
- `../games/web/includes/canvas/remote/remote-ui.js`
  - ajoute `remoteApiFormData(...)` pour les appels multipart du bridge canvas;
  - remplace le CTA unique vers `pro` par un bouton photo par ligne de podium;
  - affiche une vignette photo devant les infos de ligne quand une photo podium existe deja pour ce rang;
  - corrige la lecture de `session_meta_get` apres upload: la remote lit maintenant `session.podium_photos` quand la reponse bridge est imbriquee, au lieu d'attendre uniquement `podium_photos` en top-level;
  - reproduit le choix mobile `Caméra / Photos` avant ouverture du picker natif sur `Ajouter une photo` comme sur `Modifier la photo`;
  - ajoute un `session_meta_get` immediat au boot puis un polling `5s` seulement en `Partie terminee`, pour ne plus figer les photos podium sur la remote;
  - declenche l'upload direct depuis la remote puis rerend le podium avec les `podium_photos` retournees.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - enrichissent le `serverSessionMeta` de preload avec `podium_photos` issues du helper global de resultats;
  - but: hydrater la remote avec les miniatures podium existantes des le boot, sans attendre un appel `session_meta_get`.
- `../games/web/includes/canvas/php/boot_lib.php`
  - charge desormais `global_librairies.php` aussi pendant les boots canvas standard;
  - but: rendre effectivement disponibles dans les `glue` les helpers globaux de resultats utilises pour `podium_photos`, pas seulement sur la voie `games_ajax.php`.
- `../games/web/remote_canvas.php`
  - retire l'ancien export `sessionDetailUrl` devenu inutile cote remote.
- `../games/web/includes/canvas/css/remote_styles.css`
  - passe le podium termine de `3` colonnes a `3` lignes;
  - aligne le contenu a gauche et le CTA photo a droite, avec fallback mobile pleine largeur.

### Effet attendu
- la remote reste autonome pour l'ajout des photos gagnants;
- un upload reussi met immediatement a jour le podium remote;
- le `master games` et la fiche detail `pro` relisent ensuite la meme photo via leur lecture standard des resultats.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/remote_canvas.php`

## PATCH 2026-04-16 — Remote papier: garde `maxPlayers` avant write path d'inscription

### Objectif
- empecher qu'un ajout joueur papier parte jusqu'au `write path` `player_register` quand la session a deja atteint sa capacite max;
- corriger l'UX actuelle ou la modale d'ajout se ferme puis ne laisse qu'un toast d'erreur, ce qui ressemble a une fermeture anormale de la remote.

### Correctif livre
- `../games/web/includes/canvas/remote/remote-ui.js`
  - ajoute des helpers locaux de capacite bases sur `SESSION_PAPER`, `window.ServerSessionMeta.maxPlayers` et le snapshot joueurs courant;
  - deplace le garde principal dans `promptParticipantSelection().preConfirm` pour que SweetAlert affiche une validation inline et reste ouverte si la session est pleine;
  - ajoute une seconde garde defensive juste avant `remoteApi('player_register', ...)` pour couvrir les courses entre deux ajouts;
  - preserve le cas d'un participant deja actif, qui ne doit pas etre faussement bloque par ce garde front.

### Effet attendu
- sur session papier pleine, l'animateur reste dans la modale `Ajouter un joueur/equipe` avec un message clair au lieu de voir la modale disparaitre;
- aucun nouvel appel `player_register` ne doit partir depuis la remote pour ce cas simple de capacite deja atteinte;
- le patch reste borne a la remote papier et ne modifie ni le contrat backend ni les autres parcours d'inscription.

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js`

## PATCH 2026-04-11 — Remote: CTA `Ajouter les photos des gagnants !` compact, responsive et aligne branding

### Objectif
- reduire la hauteur du CTA de fin de partie cote remote;
- s'assurer qu'il ne force pas un debordement horizontal sur mobile;
- utiliser la vraie couleur de texte branding de la remote au lieu d'un noir hardcode.

### Correctif livre
- `../games/web/includes/canvas/css/remote_styles.css`
  - reduction de la hauteur utile et du padding du bouton;
  - largeur bornee avec `max-width:100%` et `min-width:0`;
  - wrapping autorise pour le contenu afin d'eviter toute largeur de page forcee sur petit ecran;
  - texte aligne sur `var(--primary-font)` au lieu de `#111`.

### Effet attendu
- le bouton reste lisible mais plus compact sous le podium remote;
- sur mobile, il ne doit plus elargir la page ni provoquer de scroll horizontal parasite;
- le texte suit maintenant la couleur principale de texte issue du branding applique a la remote.

## PATCH 2026-04-11 — Podium organizer: les ex aequo n'ecrasent plus leurs photos

### Objectif
- corriger le rendu `master`/organizer qui continuait a n'afficher qu'une seule photo pour plusieurs gagnants partageant le meme rang;
- conserver la compatibilite avec les anciennes photos stockees seulement par rang.

### Correctif livre
- `../games/web/includes/canvas/php/boot_lib.php`
  - `session_meta_get` enrichit `podium_photos` avec:
    - `photo_row_key`
    - `label`
    - `score`
    - `phase_label`
  - but: donner au front organizer assez de contexte pour distinguer deux lignes `#1`.
- `../games/web/includes/canvas/core/canvas_display.js`
  - le podium organizer ne convertit plus les photos en simple `Map(rank -> src)`;
  - il conserve maintenant une liste de photos par rang et attribue une photo par carte via matching:
    - cle de ligne si disponible;
    - sinon `rang + nom + phase`;
    - sinon `rang + nom + score`;
    - sinon premier media encore libre sur ce rang.
  - le fallback reste donc compatible avec les medias historiques uniquement attaches au rang.

### Effet attendu
- sur `master`, deux gagnants ex aequo peuvent maintenant afficher deux photos differentes, comme sur la fiche detail `pro`;
- si une seule photo legacy existe encore pour un rang, elle reste affichee sur la premiere carte correspondante sans casser le podium.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `node --check /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js` non exploitable tel quel dans la sandbox:
  - fichier ESM navigateur;
  - imports `@canvas/*` non resolus hors import map du runtime web.

## PATCH 2026-04-10 — Remote papier: reseed identite canonique apres ajout participant EP

### Objectif
- garder un patch strictement borne a l'ajout remote d'un participant issu d'un lookup DB (`EP/existant`);
- faire en sorte qu'apres cet ajout, la remote manipule immediatement la meme identite runtime canonique que les parcours joueur classiques, sans ajouter de correctifs disperses sur chaque action admin.
- corriger la regression Bingo apparue sur `develop/fix_joueursEP` quand `player_register` relance une re-resolution serveur via `ep_connect_token`.

### Correctif livre
- `../games/web/includes/canvas/remote/remote-ui.js`
  - ajout de `seedRemoteRegisteredParticipant(...)`;
  - apres `player_register`, si l'ajout vient d'un lookup DB (`sourceTable/sourceId`), la remote reinjecte aussitot dans son store local un joueur normalise avec:
    - `player_id` canonique;
    - `playerDbId` / `playerId` numerique si la reponse backend le fournit;
    - `playerName`, `score`, `playerScore` alignes sur le contrat runtime.
  - le snapshot `players_get` reste ensuite la source de confirmation autoritaire; ce reseed ne remplace pas le refresh standard, il bouche la fenetre ou l'UI admin pouvait encore raisonner sur une identite partielle.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - `player_register` ne repose plus sur un `ON DUPLICATE KEY` implicite pour reutiliser une identite existante;
  - la ligne runtime la plus recente pour `session + player_id` est maintenant relue explicitement, reactivee, et les doublons residuels de meme identite sont passes inactifs.
  - l'API remonte maintenant `registration_state = created|reactivated|already_active`.
  - quand `ep_connect_token` est present, ces adapters rederivent maintenant `sourceTable/sourceId` depuis `ep_link_resolve` cote serveur avant de calculer la cle runtime canonique.
- suivi Bingo-only:
  - la divergence `main` vs `develop` a ete confirmee dans `bingo_api_player_register()`:
    - `main` reutilise uniquement le payload front deja resolu;
    - `develop/fix_joueursEP` ajoute une re-resolution serveur `canvas_api_ep_link_resolve(...)` avant le recalcul du `player_id`.
  - `Bingo Musical` n'accepte maintenant comme source canonique exploitable que `participantType=player` / `sourceTable=equipes_joueurs`:
    - un resultat serveur `team/equipes` est journalise comme `EP_RESOLVE_UNUSABLE` puis ignore;
    - le code retombe alors sur le payload front deja fourni si celui-ci reste exploitable.
  - l'appel a `canvas_api_ep_link_resolve(...)` est maintenant protege par `try/catch(Throwable)` pour empecher toute remontee en `500` brut depuis ce bloc;
  - si la source finale n'est pas exploitable pour Bingo, le backend purge le mapping unsupported (`equipes`) et poursuit avec le chemin runtime existant au lieu de fabriquer une identite canonique d'equipe incompatible avec `bingo_players` / `id_joueur` / les grilles.
- suivi bridge EP apres preuve front:
  - les logs joueur ont montre que `player_register` reussissait bien puis que l'echec se deplacait sur `ep_link_finalize`;
  - cause racine: `bingo_api_player_register()` appelle deja `canvas_ep_account_bridge_link_runtime_participant(...)`, donc `ep_link_finalize` pouvait repasser dans la meme seconde avec exactement les memes valeurs et lire `rowCount() === 0` comme un faux `TOKEN_INVALID`;
  - `canvas_api_ep_link_finalize()` relit maintenant d'abord la row bridge par `return_token`, puis traite ce cas comme un succes idempotent `already_linked` au lieu d'un echec;
  - `games_ajax.php` ne remonte plus `TOKEN_INVALID` / `SESSION_MISMATCH` / `GAME_MISMATCH` / `USERNAME_MISSING` en HTTP `500`: ces erreurs bridge sont maintenant mappees en `400`.
- suivi WS Bingo apres comparaison `main` vs `fix_joueursEP`:
  - aucune divergence n'a ete trouvee dans `play-ws.js` ni dans `bingo.game/ws/**` pour le boot/auth WS Bingo numerique;
  - la divergence bloquante est dans `register.js`, juste avant l'entree WS:
    - sur `fix_joueursEP`, l'emission `Bus.emit('player/ready', ...)` utilise `gridId: paperMode ? null : ...`;
    - `paperMode` n'existe pas dans ce scope;
    - le `ReferenceError` est absorbe par le `try/catch`, donc `player/ready` n'est jamais emis, ce qui empeche tout boot/auth WS Bingo apres `player_register_ok`.
  - correctif: retour a `isPaperMode()` comme en `main` pour que l'emission `player/ready` Bingo numerique reparte bien vers `play-ws.js`.
- `../games/web/includes/canvas/play/register.js`
  - le portail player traite `already_active` comme un succes idempotent;
  - ce cas n'est plus marque comme `freshRegistration`.
- `../games/web/includes/canvas/play/player_identity.js`
  - l'identite canonique renvoyee par `player_register` ecrase maintenant l'identite session precedente, meme si un `player_id` local deja canonique etait present;
  - but: eviter qu'un `player_id` genere localement survive apres un retour `EP -> games` et recree ensuite un doublon purement WS/UI pour le meme `player_db_id`.
- `../games/web/includes/canvas/play/play-ws.js`
  - `player/paper:listen` devient reellement passif pour `quiz` / `blindtest`;
  - le boot WS papier n'appelle plus `authenticatePlayer()` apres ouverture sur ces jeux.
- `../games/web/includes/canvas/play/register.js`
  - les succes d'inscription papier `quiz` / `blindtest` emettent maintenant `player/paper:listen` au lieu de `player/ready`;
  - `ensurePaperWsListening()` s'aligne sur ce meme chemin passif.
- `../games/web/includes/canvas/remote/remote-ui.js`
  - la remote affiche maintenant `deja inscrit` pour un participant lookup deja actif dans la session, avec wording joueur/equipe adapte;
  - elle n'envoie plus `admin_player_register` si le backend a simplement confirme une inscription deja active.

### Effet attendu
- juste apres un ajout remote d'un participant EP/existant, les actions admin suivantes repartent deja d'une identite runtime compatible avec les WS;
- le perimetre reste volontairement limite aux sessions papier et aux participants ajoutes par lookup remote.
- la reinscription du meme participant EP, que l'entree se fasse par la remote ou par `EP -> games`, doit reutiliser la meme row runtime.
- l'UX distingue maintenant correctement `ajoute/reactive` de `deja inscrit`.
- les clients player n'ont plus le droit de conserver un `player_id` canonique local divergent apres confirmation serveur; le `player_id` serveur devient la reference unique pour les prochains `registerPlayer` WS.
- en papier `quiz` / `blindtest`, un joueur deja present en runtime ne doit plus se re-enregistrer en WS juste pour ecouter la session.
- en `bingo`, une re-resolution serveur EP qui ne remonte pas un `id_joueur` exploitable ne casse plus `player_register`:
  - pas de `500` brut;
  - pas de mapping force vers `team/equipes`;
  - fallback propre sur le payload front si disponible.

### Verification
- revue diff locale `games/web/includes/canvas/remote/remote-ui.js`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- validation syntaxique ESM navigateur non concluante dans la sandbox via Node brut (`import` front non resolu hors import map navigateur)
- controle complementaire Bingo-only:
  - relecture comparee `main` vs `fix_joueursEP` sur `bingo_api_player_register()`;
  - validation syntaxique PHP apres ajout du fallback defensif Bingo.
- controle complementaire bridge EP:
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/ep_account_bridge.php`
  - `php -l /home/romain/Cotton/games/web/games_ajax.php`
- controle complementaire WS Bingo:
  - comparaison locale `main...fix_joueursEP` sur `web/includes/canvas/play/register.js`, `play-ws.js`, `player_identity.js`;
  - verification locale de la ligne d'emission `player/ready` Bingo.

## PATCH 2026-04-17 — Player mobile: upload photo vainqueur avec consentement obligatoire

### Objectif
- permettre a un joueur podium d'ajouter sa photo directement depuis `player_canvas` en fin de session, sans passer par la remote;
- reutiliser le write path podium existant cote `games/global` au lieu de dupliquer un second pipeline upload;
- n'ouvrir ce flux qu'aux participants reellement eligibles et l'assortir d'un consentement explicite trace.

### Audit confirme
- rendu fin de session player:
  - `../games/web/player_canvas.php`
  - `../games/web/includes/canvas/play/play-ui.js`
  - `../games/web/includes/canvas/css/player_styles.css`
- flux upload podium deja en place cote remote:
  - `../games/web/includes/canvas/remote/remote-ui.js`
  - `../games/web/includes/canvas/php/boot_lib.php`
  - `../global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- liaison runtime -> espace joueur:
  - `../games/web/includes/canvas/play/register.js`
  - `../games/web/includes/canvas/php/ep_account_bridge.php`
  - `../games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `../games/web/includes/canvas/php/bingo_adapter_glue.php`
- stockage lien player account:
  - `championnats_sessions_participations_games_connectees`
- aucun mecanisme partage deja present pour un consentement upload-specifique avec horodatage:
  - les champs `rgpd_consentement_*` existants portent sur le compte joueur, pas sur une photo podium donnee.

### Correctif livre
- `../games/web/player_canvas.php`
  - ajoute une carte mobile `Ajouter une photo` dans l'ecran `Partie terminee`, cachee par defaut;
  - la carte contient:
    - miniature existante si presente;
    - choix `Camera / Photos`;
    - case de consentement obligatoire avant validation.
- `../games/web/includes/canvas/play/play-ui.js`
  - relit maintenant l'eligibilite via `player_podium_photo_access_get` a l'entree en etat `Partie terminee`;
  - n'affiche le CTA que si le joueur:
    - appartient au podium final;
    - est lie a un espace joueur via le bridge EP/runtime;
    - joue une session archivee/terminee compatible.
  - poste ensuite le fichier et le consentement vers `player_podium_photo_upload`.
- `../games/web/includes/canvas/css/player_styles.css`
  - habillage mobile-first du bloc upload photo de fin de session.
- `../games/web/includes/canvas/php/boot_lib.php`
  - ajoute:
    - `canvas_api_player_podium_photo_access_get(...)`
    - `canvas_api_player_podium_photo_upload(...)`
  - revalide cote serveur:
    - session archivee;
    - joueur concerne;
    - podium only;
    - liaison espace joueur presente;
    - consentement fourni.
- `../games/web/games_ajax.php`
- `../games/web/includes/canvas/core/api/api_client.js`
  - declarent `player_podium_photo_upload` comme action bridge mutante.
- `../games/web/includes/canvas/php/ep_account_bridge.php`
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - propage maintenant `ep_connect_token` lors de l'inscription runtime pour fiabiliser la presence de `id_joueur` / `id_equipe` dans le bridge.

### Stockage consentement retenu
- `../games/web/includes/canvas/sql/2026-04-17_player_podium_photo_consent.sql`
  - nouvelle table `championnats_sessions_podium_photos_consents`.
- `../games/web/includes/canvas/sql/2026-04-17_player_podium_photo_consent_runtime_snapshot.sql`
  - ajoute `runtime_username` et `runtime_label` dans la preuve d'upload.
- `../global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - l'upload podium partage accepte maintenant un bloc `consent`;
  - en succes upload:
    - la photo est d'abord ecrite comme avant dans `medias_images`;
    - puis une preuve de consentement par upload est inseree avec:
      - `session/game/rank/photo_row_key/media_image_id`
      - ids runtime et bridge (`game_player_id`, `game_player_key`, `id_joueur`, `id_equipe`, `bridge_id`)
      - snapshot runtime (`runtime_username`, `runtime_label`)
      - texte, contexte, source, timestamp, IP, user-agent.
  - si la preuve consentement echoue, le media fraichement cree est supprime pour eviter une photo orpheline sans preuve.

### Addendum 2026-04-17 — Podium player sans lien EP
- le flux player n'exige plus de liaison a l'espace joueur pour l'eligibilite;
- la garde serveur reste:
  - session archivee;
  - joueur courant;
  - podium uniquement;
  - consentement obligatoire.
- motivation:
  - ouvrir l'upload aux podiums runtime sans compte EP;
  - conserver malgre tout une piste de suppression exploitable via le snapshot du pseudo/libelle runtime stocke avec la photo.
- addendum UX 2026-04-17:
  - quand une photo est selectionnee mais pas encore envoyee, le joueur peut maintenant supprimer ce draft local via un petit bouton de reset;
  - effet attendu:
    - retour a l'etape precedente;
    - reaffichage du CTA `Ajouter une photo`;
    - consentement et message d'etat remis a zero avant une nouvelle selection.
  - addendum UX player:
    - le draft local affiche maintenant aussi une preview de l'image choisie avant l'envoi, comme sur la remote;
    - si le nom de fichier est long, la ligne fichier casse proprement en mobile au lieu de faire deborder la card;
    - quand une photo organisateur verrouille la ligne podium, le texte `Partage une photo paysage...` est masque et seule la note `Photo ajoutée par l'organisateur.` reste visible.

### Addendum 2026-04-17 — Remote podium: consentement organisateur + priorite orga
- `../games/web/includes/canvas/remote/remote-ui.js`
- `../games/web/includes/canvas/css/remote_styles.css`
- `../games/web/includes/canvas/php/boot_lib.php`
  - la remote ajoute maintenant une etape draft locale apres choix du fichier:
    - preview de l'image;
    - suppression du draft pour revenir au CTA precedent;
    - consentement organisateur obligatoire avant upload final.
- regle metier:
  - une photo organisateur visible sur une ligne podium prime sur une photo joueur;
  - le helper player masque donc le bloc d'upload si la photo visible provient d'un organisateur.
- addendum synchro player:
  - `../games/web/includes/canvas/play/play-ui.js`
  - `../games/web/includes/canvas/php/boot_lib.php`
    - l'ecran de fin joueur ne se contente plus d'un fetch one-shot de `player_podium_photo_access_get`;
    - un refresh leger tourne maintenant toutes les `10s` uniquement en `Partie terminee`, avec refresh immediat aussi au retour de focus/onglet visible;
    - si une photo organisateur apparait pendant qu'un draft joueur local existe encore, le draft local est nettoye et la carte bascule sur l'etat verrouille + preview organisateur.
    - addendum perf:
      - le bridge player renvoie maintenant aussi une `photo_signature`;
      - le polling player ne rerend plus la carte si cette signature n'a pas change.

### Verification
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/ep_account_bridge.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/games_ajax.php`
- `node --check` non conclusif dans cette sandbox pour `play-ui.js`:
  - fichier ESM navigateur avec imports/resolution front hors contexte Node brut.

## PATCH 2026-04-09 — Session detail redirect + podium photos live after end

### Objectif
- renvoyer l'organisateur vers la fiche detail session `pro` quand il ouvre/quitte une session `games`, afin de pousser l'upload des photos gagnants;
- faire remonter les photos podium ajoutees apres la fin directement sur le podium organizer sans rouvrir la session.

### Correctif livre
- `../games/web/organizer_canvas.php`
  - expose maintenant `AppConfig.sessionDetailUrl` vers `/extranet/start/game/view/<id_securite_session>` pour la sortie organizer.
- `../games/web/includes/canvas/php/ep_account_bridge.php`
  - les inserts `games_remote_lookup` generent maintenant un `return_token` technique unique au lieu d'une chaine vide, pour rester compatibles avec `uniq_return_token` sans impacter le parcours EP joueur direct.
- `../games/web/games_ajax.php`
  - charge maintenant `global_librairies.php` avant d'entrer dans le bridge canvas; les endpoints canvas avec `exit` precoce, notamment `session_meta_get`, voient donc enfin les helpers globaux de session/resultats.
- `../global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - la relecture des photos podium renvoie maintenant l'URL canonique du media meme si le fichier n'est pas visible via `file_exists(...)` sur le serveur `games`, afin d'eviter un faux negatif inter-serveurs sur le podium organizer.
- `../games/web/includes/canvas/core/end_game.js`
  - la sortie organizer redirige maintenant prioritairement vers `sessionDetailUrl` au lieu du simple dashboard `pro`.
- `../games/web/remote_canvas.php`
  - a cette date, ajout initial du CTA termine `Ajouter les photos des gagnants !` et correction de l'initialisation `CONF_SITE_ROOT` pour eviter le warning PHP sur les URLs absolues de branding.
- `../games/web/includes/canvas/remote/remote-ui.js`
  - a cette date, le quit volontaire en `Partie terminee` redirigeait aussi vers la fiche detail session;
  - ce comportement a ensuite ete retire au profit de l'upload direct remote (patch 2026-04-16).
- `../games/web/includes/canvas/php/boot_lib.php`
  - `session_meta_get` expose maintenant `podium_photos` et integre leur signature au polling organizer.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - le polling organizer persiste `podium_photos` dans `window.ServerSessionMeta` et redemande un rerender podium quand elles changent.
- `../games/web/includes/canvas/core/canvas_display.js`
- `../games/web/includes/canvas/css/canvas_styles.css`
  - le podium organizer sait maintenant afficher une photo par rang (`#1/#2/#3`) avec cadrage dedie.

### Effet attendu
- fermer volontairement `master` en fin de session ramene l'organisateur sur la fiche session `pro`;
- si une photo gagnant est ajoutee depuis `pro` apres la fin, le podium organizer la recupere automatiquement via le polling deja en place.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/remote_canvas.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`

## PATCH 2026-04-07 — Refus de pseudo: cleanup cible + `playerDbId` strict sur bingo

### Objectif
- eviter qu'un refus metier d'inscription (`pseudo deja pris / reference`) laisse une identite locale provisoire incoherente;
- empecher aussi qu'un `playerDbId` global legacy d'une autre session soit reutilise par erreur sur un flux bingo courant.

### Correctif livre
- `../games/web/includes/canvas/play/register.js`
  - ajout de `clearRejectedRegistrationDraft(...)`;
  - purge executee uniquement sur refus metier `USERNAME_ALREADY_USED` / `USERNAME_REFERENCED`;
  - aucune purge sur erreur technique, pour ne pas casser une reprise legitime apres un succes serveur;
  - pour `bingo`, purge complementaire des artefacts locaux de grille.
- `../games/web/includes/canvas/play/player_identity.js`
  - ajout de `getPlayerDbIdStrict({ game, sid })`;
  - lecture bornee a la cle `player_db_id:<session>` sans fallback global.
- `../games/web/includes/canvas/play/play-ws.js`
- `../games/web/includes/canvas/play/play-ui.js`
  - les chemins bingo critiques (auth WS, hydrate/sync de grille, reprise) relisent maintenant uniquement le `playerDbId` strict de la session courante.

### Effet attendu
- un premier refus de pseudo n'empoisonne plus une inscription ulterieure avec une identite locale fantome;
- bingo ne peut plus recoller un `playerDbId` persiste depuis une autre session.

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/play/player_identity.js`

## PATCH 2026-04-03 — Inscriptions runtime / EP / remote: garde de nom + bridge EP

### Objectif
- prevenir les doublons de nom cote runtime sans casser les inscriptions EP legitimement rattachees a un compte;
- stabiliser aussi le bridge EP <-> runtime pour les retours `play` et les ajouts remote issus d'un lookup DB.

### Correctif livre
- `../games/web/includes/canvas/php/boot_lib.php`
  - ajout du helper de detection de nom deja reference chez l'organisateur.
- `../games/web/includes/canvas/php/ep_account_bridge.php`
  - ajout du helper de liaison runtime -> bridge EP pour les ajouts remote DB.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - refus runtime pur si le nom existe deja dans la session ou s'il est deja reference chez l'organisateur;
  - bypass conserve pour `ep_connect_token` et pour les ajouts remote issus d'un lookup DB;
  - messages utilisateur harmonises;
  - les inscriptions EP derivent maintenant une identite runtime stable a partir de la source metier;
  - les ajouts remote DB ecrivent / mettent a jour `championnats_sessions_participations_games_connectees`.
- `../games/web/includes/canvas/play/register.js`
  - envoi de `ep_connect_token` et du payload source EP (`participantType/sourceTable/sourceId`) sur `player_register`.
- `../games/web/includes/canvas/remote/remote-ui.js`
  - transmission de `sessionId`, `participantType`, `sourceTable`, `sourceId` pour l'ajout remote live.

### Effet attendu
- les doublons runtime sont refuses plus tot;
- une reinscription EP dans la meme session reutilise la meme identite runtime;
- un ajout remote DB laisse maintenant une trace bridge exploitable cote EP/classements.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/ep_account_bridge.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`

## PATCH 2026-04-02 — `ep_connect_token` ne doit pas etre bypass par une identite locale

### Objectif
- garantir qu'un retour `play -> games` avec `ep_connect_token` reste prioritaire sur une reprise locale de joueur deja stockee;
- eviter l'ecart de comportement entre onglet normal (avec localStorage) et onglet prive.

### Correctif livre
- `../games/web/includes/canvas/play/register.js`
  - les branches de reprise locale `bingo` et `quiz/blindtest` sont maintenant bornees par `!hasPendingEpConnectFlow()`;
  - ajout du stage debug `ep_autoreg_resume_bypass_local_identity` quand un reliquat local est ignore pour laisser le flux EP aller jusqu'au bout.

### Effet attendu
- un `ep_connect_token` pending ne peut plus etre masque par un `player_id` local preexistant sur la meme session;
- le flow `Compte joueur Cotton` doit maintenant se comporter comme en navigation privee, meme avec un historique local deja present.

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `node --check /home/romain/Cotton/games/web/includes/canvas/core/logger.global.js`

## PATCH 2026-04-02 — Observabilite du flux `EP -> games` via `ep_connect_token`

### Objectif
- rendre le diagnostic du pont `play -> games` faisable directement depuis le log WS centralise de session;
- prouver si un retour `ep_connect_token` casse sur la resolution du token, l'inscription joueur ou la finalisation bridge.

### Correctif livre
- `../games/web/includes/canvas/core/logger.global.js`
  - ajout d'un listener `register/debug` avec mapping de niveaux/messages pour les stages `ep_link_*`, `ep_autoreg_*`, `player_register_*` et `gate_*`;
  - ajout des evenements centralises:
    - `PLAYER_REGISTER_UPSERT_OK`
    - `PLAYER_REGISTER_UPSERT_ERR`
    - `MISSING_PLAYER_ID`
  - reglage final: les preuves du flux `EP -> games` restent en `debug` pour limiter le bruit en prod.

### Effet attendu
- le `.jsonl` de session remonte maintenant une preuve lisible du point exact de decrochage du flux `Compte joueur Cotton`;
- au prochain test, il doit etre possible de distinguer clairement:
  - echec `ep_link_resolve`;
  - echec d'upsert `player_register`;
  - echec `ep_link_finalize`;
  - ou simple retour UI sans echec bridge.

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/core/logger.global.js`

## PATCH 2026-04-02 — Player reload avec identite locale: `GameMeta` manque sur le canvas player

### Objectif
- stabiliser le rechargement du portail session player `games` quand un joueur est deja connu en localStorage;
- supprimer l'incoherence de bootstrap entre organizer canvas et player canvas sur les metadonnees de jeu.

### Correctif livre
- `../games/web/player_canvas.php`
  - injection de `window.GameMeta = { slug, title }` dans le bootstrap player, alignee sur l'organizer;
- `../games/web/includes/canvas/core/logger.global.js`
  - fallback `resolveGameSlug()` sur `window.AppConfig.gameSlug` si `window.GameMeta` est absent.

### Effet attendu
- un rechargement player avec identite locale preexistante ne perd plus le slug de jeu au bootstrap;
- les logs player ne remontent plus `game: ''` sur ce chemin;
- la reprise auto (`player/ready` -> `bootWS` -> `authenticatePlayer`) dispose du meme metadata contractuel que le reste du runtime.

### Verification
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `node --check /home/romain/Cotton/games/web/includes/canvas/core/logger.global.js`

## PATCH 2026-04-01 — Organizer: reset design session avec suppression compte si design identique

### Objectif
- clarifier dans la modale organizer que le reset vers le design du jeu peut aussi retirer le design compte par defaut;
- declencher ce comportement automatiquement sans ajouter de second CTA.

### Correctif livre
- `../games/web/includes/canvas/core/session_modals.js`
  - avant d'afficher la confirmation, le front appelle maintenant un preview backend pour savoir si un branding compte sera effectivement supprime;
  - la confirmation `Revenir au design d'origine du jeu` mentionne maintenant explicitement:
    - la remise au design du jeu pour la session courante;
    - la suppression automatique du design compte s'il existe et s'il correspond au design effectif de la session;
    - le fait que les prochaines sessions n'utiliseront plus ce design;
    - le fait que les sessions deja programmees qui l'heritaient deja le conserveront;
  - ces lignes d'impact ne sont affichees que si le preview confirme la suppression compte;
  - dans SweetAlert, la mention conditionnelle est affichee en petit, italique, avec un leger espacement au-dessus;
  - le POST de delete joint maintenant `cascade_client_branding_if_matching=1` pour demander au backend global de gerer ce reset elargi.

### Effet attendu
- l'utilisateur comprend avant validation que le reset de session peut aussi retirer le design compte par defaut;
- le front `games` delegue au backend la logique de gel des sessions futures deja programmees puis de suppression conditionnelle du design compte.

### Verification
- `node --experimental-default-type=module --check /home/romain/Cotton/games/web/includes/canvas/core/session_modals.js`

## TODO structurant — Branding par type de jeu

### Constat
- le front `games` ne sait aujourd'hui enregistrer qu'un branding session ou un branding compte global, sans dimension `quiz / blindtest / bingo`;
- un wording ou un delete borne au type de jeu courant ne peut pas etre fiable sans support backend correspondant.

### Cible
- permettre `Utiliser ce design pour mes prochaines sessions de ce jeu`;
- si reset du design sur une session d'un jeu donne, ne supprimer que le branding compte du meme type de jeu;
- laisser les autres jeux du meme compte inchanges.

### Dependances
- evolution du modele `global` de branding pour porter `id_type_produit`;
- evolution des endpoints save / preview / delete et des resolvers runtime;
- fallback retrocompatible sur le branding global existant tant qu'aucun branding par jeu n'existe.

### Reference
- `documentation/notes/branding_par_type_de_jeu.md`

## PATCH 2026-04-01 — Organizer: QR remote papier non ouvert garde ferme dans la modale d'options

### Objectif
- empecher l'UI organizer `games` d'exposer le QR d'acces remote depuis la modale d'options quand une session papier n'est pas encore ouverte;
- conserver le comportement existant pour les sessions papier effectivement ouvertes.

### Correctif livre
- `../games/web/includes/canvas/core/session_modals.js`
  - ajout d'une garde locale `canAutoExpandPilotQR(isPaper)` basee sur `window.ClientSessionMeta.isOpen`;
  - `setPilotQRExpanded()` n'ouvre plus automatiquement `#pilotQRWrap` en simple mode papier: l'auto-ouverture exige maintenant `papier + session ouverte`;
  - hors session ouverte, la modale referme explicitement le bloc QR remote et remet `aria-expanded=false`, tout en laissant le garde de clic existant dans `boot_organizer.js`.

### Effet attendu
- une session papier future ou fermee n'affiche plus en force le QR remote dans la modale d'options organisateur;
- sur une session papier ouverte, le QR continue a se deployer automatiquement comme avant.

### Verification
- `node --experimental-default-type=module --check /home/romain/Cotton/games/web/includes/canvas/core/session_modals.js`

## PATCH 2026-03-31 — Quiz organizer: diagnostic persistance format + garde polling réelle

### Objectif
- tracer explicitement le résultat serveur du switch `papier / numérique` sur les sessions quiz;
- faire remonter au polling organizer `games` la vraie garde `papier -> numérique`, au lieu d'un `digitalSwitchAllowed=true` forcé.
- si le plantage survient avant les logs quiz, journaliser aussi l'erreur au niveau bridge/dispatch.

### Correctif livré
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
  - ajout de logs métier dédiés sur les writes de format quiz:
  - `QUIZ_SESSION_UPDATE_REQUEST`
  - `QUIZ_SESSION_UPDATE_LOCKED`
  - `QUIZ_PAPER_TO_DIGITAL_CHECK`
  - `QUIZ_PAPER_TO_DIGITAL_BLOCKED`
  - `QUIZ_PAPER_TO_DIGITAL_OK`
  - `QUIZ_SESSION_UPDATE_FLAG_WRITE`
- `../games/web/includes/canvas/php/boot_lib.php`
  - `session_meta_get` expose maintenant la vraie compatibilité numérique quiz quand la session est encore en papier et non verrouillée;
  - le polling organizer reçoit désormais `digitalSwitchAllowed`, `digitalSwitchInvalidCount`, `digitalSwitchReason` et `digitalSwitchMessage` cohérents avec la garde serveur quiz.
- `../games/web/games_ajax.php`
  - ajout de logs bridge `INVALID_HANDLER_RESPONSE` et `HANDLER_ERROR` pour journaliser le `game`, l'`action`, le code métier et le code HTTP final quand le handler ne répond pas `ok`.
- `../games/web/includes/canvas/php/boot_lib.php`
  - ajout de logs `game_api_dispatch` `CALL/FAIL` pour confirmer le handler réellement appelé et son code de retour en cas d'échec.

### Effet attendu
- les logs `games` permettent de distinguer clairement un refus métier, un verrou runtime, un write SQL effectif ou un no-op;
- si l'échec survient avant `quiz_adapter_glue.php`, le bridge `games_ajax.php` et le dispatch remontent maintenant aussi une preuve exploitable;
- l'organizer `games` ne masque plus un refus `papier -> numérique` derrière un état local incohérent.

### Vérification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/games_ajax.php`

## PATCH 2026-03-31 — Organizer: synchro format avec `pro` + verrou runtime hors `En attente`

### Objectif
- empêcher tout changement de format officiel après sortie de l'état `En attente`, quel que soit le point d'entrée `games` ou `pro`;
- répercuter dans l'UI organizer `games` un changement de format déclenché depuis `pro`, sans recharger toute la page.

### Correctif livré
- `../games/web/includes/canvas/php/boot_lib.php`
  - ajout d'un helper commun `canvas_session_format_guard_get()` pour déterminer l'état `pending/locked`;
  - ajout de l'action canvas `session_meta_get` pour exposer l'état minimal de session à l'organizer.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - blocage serveur du write `flag_controle_numerique` si la session officielle n'est plus `En attente`.
- `../games/web/includes/canvas/core/api_provider.js`
- `../games/web/includes/canvas/core/boot_organizer.js`
  - ajout d'un polling organizer ciblé sur `session_meta_get`;
  - si `pro` change le format, l'organizer met à jour `window.ServerSessionMeta`, resynchronise les radios de la modale et réémet `options/updated` pour réaligner l'UI.

### Effet attendu
- un organizer `games` déjà ouvert suit un changement `pro -> format` en quelques secondes sans reload complet;
- si la session n'est plus `En attente`, les write paths `games` refusent désormais le changement de format même si l'UI locale n'a pas encore été rouverte.

### Vérification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`

## PATCH 2026-03-30 — Compte joueur EP: fallback hors session ouverte

### Objectif
- permettre au bloc `Compte joueur Cotton` de rester utile quand la session `games` n'est pas ouverte, sans reboucler vers `games` après auth EP.

### Correctif livre
- `../games/web/player_canvas.php`
  - adaptation du texte du bloc selon l'état temporel de la session;
  - avant session non ouverte: message orienté `prévenir l'organisateur`;
  - session expirée/non ouverte: message orienté `prochaines sessions`.
  - fenêtre d'ouverture explicite:
    - `jour J` = ouvert;
    - `lendemain de session` = encore ouvert strictement avant `12:00`;
    - sinon = expiré.
- `../global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - fallback `games_account_join` vers `manage/s1/{token}` pour une session future non ouverte;
  - fallback `games_account_join` vers l'agenda EP pour une session expirée/non ouverte.
 - `../games/web/includes/canvas/play/register.js`
  - au jour J, le message d'attente du retour EP remplace désormais le texte/CTA du bloc `Compte joueur Cotton` au lieu d'apparaitre dans le bloc pseudo.
  - le resolve `ep_connect_token` tourne maintenant aussi quand la gate reste en `NO_MASTER`, afin de conserver le formulaire pseudo fermé et de rendre immédiatement le message de confirmation au retour de `play`.
  - pour une session papier, le retour `EP -> games` réutilise désormais le rendu papier historique avec message contextualisé joueur/équipe et CTA de désinscription.
  - sur ce flux papier, le gating WS ne constitue pas une garde bloquante: il est volontairement contourné pour conserver le retour de confirmation papier au lieu de tenter une entrée dans le gameplay numérique.

### Effet attendu
- les CTA `Se connecter / Créer mon compte joueur` restent exploitables même quand le pseudo historique `games` est fermé;
- le joueur authentifié EP n'est plus renvoyé inutilement vers `games` tant que la session n'est pas ouverte.
- quand la session est réellement ouverte, le bloc `Compte joueur Cotton` garde sa promesse standard et n'affiche plus le message dédié `NO_MASTER`.

## PATCH 2026-03-27 — Player canvas: bloc dedie `Compte joueur Cotton`

### Objectif
- remplacer le simple lien `S'inscrire avec mon compte joueur` par un vrai point d'entree EP distinct du formulaire pseudo, avec une promesse d'experience minimale plus claire.

### Correctif livre
- `../games/web/player_canvas.php`
  - remplacement du lien inline par un bloc `Compte joueur Cotton` separe du formulaire pseudo;
  - ajout d'un titre, d'une promesse minimale (`historique`, `prochaines sessions`, `organisateurs deja frequentes`) et de CTAs `Me connecter avec mon compte joueur` / `Creer mon compte`.
- `../games/web/includes/canvas/css/player_styles.css`
  - styles du nouveau bloc dedie pour l'ecran d'inscription joueur.

### Effet attendu
- le point d'entree EP sur `games` est plus lisible et ne vend plus une simple bascule technique;
- le formulaire pseudo reste le chemin principal immediat, avec un second bloc clairement distinct pour le compte joueur Cotton.

### Verification rapide
- `php -l /home/romain/Cotton/games/web/player_canvas.php`

## PATCH 2026-03-27 — New_EJ: `games` reduit au noyau bridge EP

### Objectif
- supprimer les ajouts non essentiels autour du chantier `EP -> games` pour ne conserver que le noyau bridge necessaire au retour joueur connecte.

### Correctif livre
- `../games/web/games_ajax.php`
  - suppression du log `ACTION_RX` non indispensable;
- residuel bridge confirme sur:
  - `../games/web/config.template.php`
  - `../games/web/includes/canvas/php/boot_lib.php`
  - `../games/web/includes/canvas/php/ep_account_bridge.php`
  - `../games/web/includes/canvas/play/register.js`
  - `../games/web/player_canvas.php`

### Effet attendu
- le diff `new_ej` cote `games` se limite a la configuration et au runtime strictement necessaires au flux `S'inscrire avec mon compte joueur`.

## PATCH 2026-03-26 — Player register: `S'inscrire avec mon compte joueur` + pont EP

### Objectif
- permettre depuis la page player `games` de basculer vers `play`, s'authentifier/créer son compte joueur, puis revenir sur la session avec une identité EP résolue pour auto-inscription.

### Correctif livre
- `../games/web/player_canvas.php`
  - ajout du CTA `S'inscrire avec mon compte joueur`;
  - injection des URLs `play` de signin/signup avec contexte session.
- `../games/web/includes/canvas/play/register.js`
  - prise en charge du query param `ep_connect_token`;
  - résolution du lien EP via `ep_link_resolve`;
  - auto-inscription dès que la gate joueur est ouverte;
  - finalisation du lien métier via `ep_link_finalize` après `player_register`.
- `../games/web/includes/canvas/php/ep_account_bridge.php`
  - nouveau bridge canvas de lecture/finalisation du retour EP.
- `../games/web/includes/canvas/php/boot_lib.php`
  - chargement du bridge EP.

### Effet attendu
- un joueur connecté à l'EP n'a plus à ressaisir son pseudo;
- Blindtest/Bingo utilisent le prénom EP;
- Quiz numérique utilise l'équipe déjà choisie côté `play`;
- les writes runtime restent dans `*_players`, sans déporter la logique métier vers les tables de jeu.

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

## PATCH 2026-03-26 — New_EJ: priorite du flux `ep_connect_token` sur l'etat local
- [x] Audit ciblé:
  - `games/web/includes/canvas/play/register.js`
  - `games/web/player_canvas.php`
- [x] Correctif livré:
  - le retour `EP -> games` ne se fait plus court-circuiter par `isReturningPlayer()` tant qu'une reprise via `ep_connect_token` est en attente;
  - ajout d'un etat local dedie a la completion du flux EP pour eviter les gardes hors scope;
  - maintien du comportement historique pour les joueurs deja connus quand aucun token EP n'est present.
- [x] Vérification:
  - revue diff ciblée `games/web/includes/canvas/play/register.js`
  - `node --check` non exploitable tel quel sur ce fichier front ESM (`@canvas/*`)

## PATCH 2026-03-27 — Bridge EP -> games: priorité au pseudo pour Blind Test / Bingo
- [x] Audit ciblé:
  - `games/web/includes/canvas/php/ep_account_bridge.php`
- [x] Correctif livré:
  - le bridge `ep_connect_token` charge désormais `equipes_joueurs.pseudo` en plus de `prenom`;
  - pour `blindtest` / `bingo`, le username injecté dans `games` prend le pseudo en priorité, avec fallback sur le prénom;
  - le cas `quiz` reste inchangé sur le nom d'équipe.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/ep_account_bridge.php`

## PATCH 2026-03-31 — Quiz organizer: `session_update` accepte un switch de format seul
- [x] Audit ciblé:
  - `games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `games/logs/error_log`
  - `games/logs/access_log`
- [x] Correctif livré:
  - le handler `quiz_api_session_update()` n'injecte plus `currentSongIndex=null` et `gameStatus=null` quand le payload organizer ne porte qu'un changement de format;
  - `qz_session_update()` peut donc traiter un `paperMode` / `flagControleNumerique` seul sans tomber sur `BAD_GAME_STATUS` avant la persistance du flag;
  - la cause a ete prouvee par les logs `game_api_dispatch FAIL quiz.session_update error=BAD_GAME_STATUS` sur les requetes organizer du `31/03/2026`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`

## PATCH 2026-03-31 — Quiz organizer: nettoyage logs + message de compatibilite numerique
- [x] Audit ciblé:
  - `games/web/includes/canvas/core/session_modals.js`
  - `games/web/includes/canvas/php/boot_lib.php`
  - `games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `games/web/games_ajax.php`
- [x] Correctif livré:
  - retrait des logs de diagnostic temporaires (`game_api_dispatch`, `HANDLER_ERROR`, `QUIZ_SESSION_UPDATE_*`) ajoutes pour l'enquete du `500`;
  - la modale organizer desactive maintenant tout le switch de format quiz quand le passage `papier -> numerique` est interdit;
  - une note statique s'affiche sous le switch: `Ce quiz n'est pas compatible avec la version numérique du jeu.`
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `php -l /home/romain/Cotton/games/web/games_ajax.php`

## PATCH 2026-03-31 — Organizer games: sortie automatique si session supprimee cote pro
- [x] Audit ciblé:
  - `games/web/includes/canvas/core/boot_organizer.js`
  - `games/web/includes/canvas/core/end_game.js`
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- [x] Correctif livré:
  - le polling organizer `session_meta_get` intercepte maintenant `session_not_found`;
  - si la session a ete supprimee cote `pro` pendant qu'un organizer `games` est ouvert, l'interface reutilise le chemin de quit volontaire (`quitGame` via WS + `endSession()`) puis redirige vers `pro`.
- [x] Vérification:
  - revue ciblée de `games/web/includes/canvas/core/boot_organizer.js`

## PATCH 2026-04-01 — Remote papier: lookup DB joueurs/equipes existants
- [x] Audit ciblé:
  - `games/web/includes/canvas/remote/remote-ui.js`
  - `games/web/includes/canvas/css/remote_styles.css`
  - `games/web/includes/canvas/php/boot_lib.php`
  - `games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `games/web/includes/canvas/php/bingo_adapter_glue.php`
  - `games/web/includes/canvas/php/ep_account_bridge.php`
- [x] Correctif livré:
  - ajout de l'action bridge `participant_lookup` pour suggérer les equipes `quiz` depuis `equipes` et les joueurs `blindtest` / `bingo` depuis `equipes_joueurs` a partir de 3 caracteres;
  - la modale remote permet soit de selectionner une entree existante, soit de confirmer une saisie libre;
  - une selection DB envoie un `player_id` canonique `p:uuid`, derive de facon deterministe de la source metier (`id_equipe` / `id_joueur`), afin de reutiliser la meme identite runtime au lieu de regenerer un id local aleatoire;
  - pour `quiz`, les equipes homonymes sont desormais distinguees par un contexte metier affiche dans les suggestions: jusqu'a 2 prenoms de joueurs associes a chaque equipe;
  - pour `blindtest` / `bingo`, les fiches `equipes_joueurs` portant un email technique `@cotton-quiz.com` sont maintenant exclues du lookup remote;
  - les autres joueurs homonymes sont distingues par un email masque dans les suggestions quand `equipes_joueurs` expose une colonne email standard (`email`, `mail` ou `adresse_mail`);
  - le lookup joueur dedoublonne les fiches strictement homonymes (`libelle affiche + email normalise`) et garde la plus recente (`updated_at`, sinon `created_at`, sinon `id` le plus grand) pour ne pas exposer plusieurs fois le meme joueur a l'animateur;
  - le lookup remote applique maintenant un filtre dur par organisateur a partir de la session courante: `quiz` ne remonte que les equipes deja vues pour ce client via les tables recentes plus `equipes_to_championnats_sessions`, tandis que `blindtest` / `bingo` ne remontent que les joueurs deja lies a ce compte organisateur via les tables recentes plus le legacy bingo `jeux_bingo_musical_grids_clients`;
  - les libelles remote explicitent ce perimetre avec `joueur/equipe deja lie(e) a ton compte organisateur`;
  - les handlers `player_register` lisent maintenant la longueur reelle de leur colonne `username` via `information_schema`, avec fallback `20`, au lieu d'une borne fixe `20`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
  - `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-13 — Games config: détection dev robuste pour les URLs WS
- [x] Audit ciblé:
  - `games/web/config.php`
  - `games/web/config.template.php`
- [x] Correctif livré:
  - la détection d'environnement `games` ne reposait que sur `games.dev.cotton-quiz.com`, ce qui faisait retomber d'autres hosts dev en `prod`;
  - la détection utilise maintenant `HTTP_HOST` en priorité, avec fallback `SERVER_NAME`, pour éviter les faux `prod` derrière vhost / proxy;
  - `games` aligne maintenant sa détection sur la règle robuste `*.dev.cotton-quiz.com`, comme `global`;
  - les clés `bt_ws_url`, `qz_ws_url` et `bm_ws_url` pointent donc à nouveau vers les endpoints dev dès que le host courant est un sous-domaine dev valide.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/config.php`
  - `php -l /home/romain/Cotton/games/web/config.template.php`

## PATCH 2026-04-13 — Games organizer: debug runtime de résolution WS
- [x] Audit ciblé:
  - `games/web/organizer_canvas.php`
- [x] Correctif livré:
  - ajout temporaire d'un debug dev `window.__COTTON_WS_DEBUG__` loggé en console dans organizer;
  - le payload expose `HTTP_HOST`, `SERVER_NAME`, `REQUEST_URI`, `conf.server`, `AppConfig.env` et `AppConfig.wsUrl` pour isoler un mauvais host runtime, une conf erronée ou un rendu HTML stale/cache.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/organizer_canvas.php`

## PATCH 2026-04-13 — Games organizer: héritage de `$env` corrigé
- [x] Audit ciblé:
  - `games/web/modules/app_orga_ajax.php`
  - `games/web/games_ajax.php`
- [x] Correctif livré:
  - `app_orga_ajax.php` ne recalculait pas localement `$env` et héritait donc de la portée du fichier appelant;
  - `games_ajax.php` réécrivait ensuite `$env` avec `$CONF_SERVER ?? 'prod'`, alors que `$CONF_SERVER` n'était pas défini;
  - résultat: organizer pouvait sélectionner les URLs WS `prod` alors même que `conf.server === 'dev'` et que la matrice `bt_ws_url/qz_ws_url/bm_ws_url` était correcte;
  - `app_orga_ajax.php` calcule maintenant explicitement `$env = (string)($conf['server'] ?? 'prod')`;
  - `games_ajax.php` aligne aussi son `$env` CORS sur `$conf['server']`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/modules/app_orga_ajax.php`
  - `php -l /home/romain/Cotton/games/web/games_ajax.php`

## PATCH 2026-04-13 — Games organizer: retrait du debug WS temporaire
- [x] Audit ciblé:
  - `games/web/organizer_canvas.php`
- [x] Correctif livré:
  - suppression de `window.__COTTON_WS_DEBUG__` après validation de la chaîne de résolution WS en dev;
  - le rendu organizer retrouve un bootstrap propre sans log console de diagnostic.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/organizer_canvas.php`

## PATCH 2026-04-16 — Branding sessions: persistance du visuel recadré
- [x] Audit ciblé:
  - `games/web/includes/canvas/core/session_modals.js`
- [x] Correctif livré:
  - la solution front intermédiaire a été retirée;
  - `session_modals.js` est revenu au flux simple: aperçu local recadré pour la modale, mais envoi prioritaire du fichier source brut au backend pour `branding_visuel`;
  - le cadrage final du visuel branding est désormais porté côté `global`, pas par un dérivé HD fabriqué dans `games`.
- [x] Vérification:
  - revue de diff sur `games/web/includes/canvas/core/session_modals.js`

## PATCH 2026-05-05 — Bingo organizer: médailles de phase visibles pendant la session
- [x] Audit ciblé:
  - `games/web/includes/canvas/core/games/bingo_ui.js`
  - `games/web/includes/canvas/core/canvas_display.js`
  - `games/web/includes/canvas/core/ws_effects.js`
- [x] Correctif livré:
  - `srv/phaseOver` émet maintenant `bingo/medals/updated` quand un gagnant de phase ajoute ou améliore une médaille;
  - les gagnants reçus sous id canonique ou id legacy sont resolus vers la même clé joueur que la liste organizer (`playerId` prioritaire);
  - l'hydratation Bingo depuis snapshot conserve les médailles déjà connues au lieu de repartir d'un objet vide quand le snapshot ne contient pas les notifications `PlayerWin`.
  - `bingo/medals/updated` rafraîchit maintenant aussi la liste organizer compacte en live, pas seulement les listes plein écran et le mode pause.
  - le rendu des badges Bingo recherche maintenant la médaille sur toutes les clés connues de la ligne joueur (`playerId`, `player_id`, id DB/legacy, mapping grille) pour couvrir le cas du joueur GM en iframe dont la forme d'identifiant peut changer après un update live.
  - au reload/reprise d'une session Bingo en cours, `Preload.phase_winners` réhydrate maintenant aussi `bingo.medalsById` et émet `bingo/medals/updated`; le chemin est explicitement désactivé juste après un reset démo Bingo (`bingo_postreset=1`).
  - après reset d'une démo Bingo qui était terminée, `bingo_postreset=1` sert de signal parent: si le boot serveur confirme `En attente`, l'organizer vide puis reconfigure l'iframe joueur GM avec son URL normale.
- [x] Impact:
  - aucune modification de contrat WS ou bridge;
  - aucun changement de logique player / grille Bingo;
  - correction limitée au rendu organizer mobile et desktop des badges `LIGNE`, `DOUBLE LIGNE`, `BINGO`.
- [x] Vérification:
  - `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/games/bingo_ui.js`
