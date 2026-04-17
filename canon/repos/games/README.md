# Repo `games` — Carte IA d’intervention (canon)

> **But**: permettre à un agent IA “web” (sans accès direct au runtime) de comprendre rapidement :
> - **ce que fait le repo**, **comment ça circule** (WS/HTTP/Bus),
> - **où intervenir** pour coder une évolution ou corriger un bug.
>
> **Règle**: ce fichier est une **source de vérité** (update-not-append).  
> L’historique et les changements vont dans `TASKS.md`.  
> Le point d’entrée public reste `SITEMAP.md`.

## Doc discipline
- `canon/repos/games/TASKS.md` à mettre à jour à chaque action significative (update-not-append si une tâche existe déjà).
- `canon/repos/games/README.md` à mettre à jour dès qu’un changement impacte le fonctionnel (flux/actions inter-repos, endpoints, env vars, idempotence/event_id, jalons logs, writes DB, etc.).
- En cas de divergence, le code fait foi ; corriger la doc immédiatement.

## Update 2026-04-17 — Bingo demo reset: winners DB + local player state are now cleared
- le flux `resetdemo` Bingo ne se contente plus de remettre la playlist et les grilles a zero:
  - il purge maintenant aussi `bingo_phase_winners` pour que le preload organizer/remote reparte sans gagnants historiques;
  - il conserve en revanche les rows `bingo_players` et les assignations de grilles, conformement au contrat demo actuel.
- cote player, le message WS `demo_reset` vide maintenant les reliquats locaux Bingo avant le reload:
  - reset UI immediat vers `En attente`;
  - `mainStarted=false`;
  - reset grille local;
  - `bingo_checked`
  - `bingo_locked`
  - `bingo_best_phase`
- but fonctionnel:
  - une demo Bingo relancee doit pouvoir etre rejouee sans rehydrater ni winners de phase precedents, ni coches/locks locaux residuels.
- perimetre volontairement borne:
  - pas de changement sur `reset` (flux de start),
  - pas de desassignation des grilles ni de suppression des joueurs demo.

## Update 2026-04-17 — Player mobile: upload photo podium V1 avec consentement trace
- le portail `player_canvas` de fin de session peut maintenant proposer un CTA photo au joueur lui-meme, en complement du flux remote deja en place;
- ce CTA n'est visible que si toutes les conditions suivantes sont vraies:
  - la session est terminee/archivee;
  - le participant courant appartient au podium final.
- addendum 2026-04-17:
  - la liaison a l'espace joueur n'est plus obligatoire pour ce flux player;
  - le champ `linked_to_player_account` reste expose a titre informatif quand un bridge existe encore.
- le front player ne duplique pas le pipeline remote:
  - il lit l'eligibilite via `canvas_api_player_podium_photo_access_get(...)`;
  - il ecrit ensuite via `canvas_api_player_podium_photo_upload(...)`;
  - ce write path delegue toujours au helper partage `app_session_results_podium_photo_upload(...)`.
- le formulaire impose maintenant un consentement explicite avant envoi:
  - case obligatoire;
  - texte de diffusion Cotton affiche inline;
  - refus serveur si le consentement manque, meme en appel direct.
- addendum UX 2026-04-17:
  - le player affiche maintenant une preview locale du draft photo avant upload, en reutilisant la meme carte que la photo deja enregistree;
  - la ligne du nom de fichier casse proprement en mobile si le nom est long;
  - si une photo organisateur verrouille deja la ligne podium, la carte joueur masque la description d'upload et garde seulement la preview + la note passive organisateur.
- choix de stockage retenu:
  - une preuve par upload dans `championnats_sessions_podium_photos_consents`;
  - la preuve reference aussi le media cree et les ids joueur/bridge/runtime utiles;
  - addendum 2026-04-17: la preuve snapshotte maintenant aussi le pseudo/libelle runtime visible au moment de l'upload, pour pouvoir retrouver rapidement photo + session + joueur lors d'une demande d'effacement, meme sans compte EP.
- justification:
  - un consentement attache a la photo est plus defensible qu'un simple flag compte joueur global;
  - il permet de prouver quelle photo a ete envoyee, par qui, quand et dans quel contexte.
- garde-fous serveur:
  - pas d'UI pour les non-podium;
  - refus backend si l'appel contourne l'UI sans eligibilite podium/session;
  - les validations MIME / taille / extension / sanitation restent celles du helper upload partage.
- addendum remote 2026-04-17:
  - la remote `games` collecte maintenant elle aussi un consentement explicite avant upload photo podium;
  - ce consentement organisateur est stocke dans la meme table que celui du player, avec une source distincte `games_remote_organizer`;
  - regle de priorite:
    - une photo organisateur visible sur une ligne podium prime toujours sur une photo joueur;
    - si la photo courante d'une ligne podium provient d'un organisateur, le bloc `player_canvas` de cette ligne est masque et le joueur ne peut plus l'ecraser.

## Update 2026-04-17 — Remote podium: une photo par gagnant, pas une photo par rang
- la remote `games` de fin de partie est maintenant alignee sur la granularite deja utilisee cote `pro` pour les photos podium;
- `session_meta_get` et le preload `serverSessionMeta` exposent maintenant toutes les lignes podium `1..3`, meme sans photo deja presente:
  - `photo_row_key`
  - `label`
  - `score`
  - `phase_label`
  - `photo_src`
- cote remote, le rendu de fin de partie ne relie plus les miniatures et les CTA d'upload uniquement au `rank`;
- chaque carte/ligne de podium essaie maintenant d'identifier sa row meta propre:
  - `photo_row_key` si deja disponible;
  - sinon fallback `rang + libelle + phase` pour `bingo`;
  - sinon fallback `rang + libelle + score` pour `quiz` / `blindtest`.
- le bouton photo poste maintenant `rank + photo_row_key` vers `session_podium_photo_upload`, ce qui permet:
  - de charger une photo distincte pour deux gagnants ex aequo sur la meme marche;
  - de modifier ensuite la bonne photo sans ecraser celle d'un autre gagnant du meme rang.
- un `session_meta_get` est aussi relance a la reception de `remote/end`, pour qu'une remote deja ouverte recupere rapidement les row keys et les photos associees apres la fin de partie.

## Update 2026-04-16 — Quit joueur runtime: la purge locale supprime aussi l'identite session-scope
- le quit volontaire cote player numerique ne supprimait jusqu'ici que des cles legacy de `localStorage`;
- or l'identite runtime canonique est aussi stockee scopee par session (`player_stable_id:<sid>`, `player_db_id:<sid>`), ce qui pouvait laisser au reload un faux etat "joueur deja connu" alors que le joueur venait de quitter;
- `play-ui.js` aligne maintenant le quit numerique sur la purge papier:
  - appel explicite a `clearPlayerIdentityForSession({ game, sid })`;
  - suppression du flag `player-registered_<sessionId>`;
  - pour `bingo`, suppression aussi des cles de grille scopees par session;
- effet attendu:
  - apres `Quitter la partie`, un retour sur la page revoit bien l'etape d'inscription;
  - un joueur runtime peut se reinscrire avec un nouveau pseudo sans etre bloque par une identite locale fantome.

## Update 2026-04-16 — Remote papier: garde capacite avant `player_register`
- portee strictement ciblee a l'ajout de participant depuis la remote quand `paperMode` est actif;
- `remote-ui.js` lit maintenant `window.ServerSessionMeta.maxPlayers` et le snapshot joueurs courant (`playersLast` / `playersTotalLast`) avant de laisser partir un nouvel ajout;
- le controle principal est place dans `promptParticipantSelection().preConfirm`:
  - si la session papier est pleine, la modale SweetAlert reste ouverte;
  - le refus remonte en message de validation au lieu de fermer la modale puis d'afficher seulement un toast.
- une seconde verification existe juste avant `remoteApi('player_register', ...)` pour couvrir un cas de concurrence entre deux ajouts;
- nuance fonctionnelle:
  - la garde ne bloque pas un participant deja actif si l'animateur le re-selectionne;
  - aucun contrat backend `player_register` n'est modifie par ce patch.

## Update 2026-04-16 — Quit `master` demos + quit `play`
- `end_game.js` ne base plus la sortie demo sur `id_client === 1557`;
- la sortie `master` s'appuie maintenant sur `AppConfig.isDemoSession` et peut reutiliser un `return_url` explicite fourni par `pro`, memorise par session dans `sessionStorage`;
- en absence de `return_url`, le `master` accepte aussi un referrer `pro` valide comme origine de retour pour les demos;
- les lanceurs demo `pro` connus (`bibliotheque`, `fiche session`, `liste agenda`, duplication directe) ajoutent maintenant ce `return_url` quand ils ouvrent `games/master`;
- `play` n'utilise plus une redirection catalogue par jeu pour `urlPromo`:
  - la cible standard de retour devient la home du site `www`.

## Update 2026-04-16 — Remote fin de partie: upload podium direct dans `games`
- la remote ne redirige plus vers `pro` pour l'ajout des photos gagnants;
- un nouvel endpoint bridge `session_podium_photo_upload` expose maintenant l'upload podium en JSON/multipart depuis `games`, tout en reutilisant le helper global `app_session_results_podium_photo_upload(...)`;
- la remote rerend son podium termine juste apres upload avec le `session_meta_get` renvoye par l'endpoint;
- quand une photo podium existe deja pour un rang, la remote affiche maintenant aussi sa miniature directement dans la ligne concernee;
- la remote supporte maintenant explicitement les 2 shapes de meta observees:
  - preload simple `window.ServerSessionMeta.*`
  - refresh bridge `window.ServerSessionMeta.session.*`
- les resolvers de preload `quiz` / `blindtest` / `bingo` injectent maintenant eux aussi `podium_photos` dans `serverSessionMeta`, pour hydrater la remote avec les photos existantes des l'ouverture;
- `boot_lib.php` charge maintenant `global_librairies.php` aussi pour les boots canvas hors `games_ajax.php`, afin que ces resolvers preload aient bien acces aux helpers globaux de resultats;
- la remote force maintenant aussi un `session_meta_get` au boot, puis continue un polling toutes les `5s` uniquement en etat `Partie terminee`;
- le bouton photo remote reproduit maintenant le geste mobile deja utilise sur la fiche session `pro`:
  - ouverture d'un mini-choix `Caméra / Photos` sur `Ajouter une photo` comme sur `Modifier la photo`;
  - `capture="environment"` seulement sur le chemin `Caméra`;
- l'UX du podium termine passe aussi en `3` lignes au lieu de `3` colonnes, avec un CTA photo explicite en fin de ligne:
  - icone appareil photo;
  - libelle `Ajouter une photo` / `Modifier la photo`.

## Update 2026-04-11 — Podium organizer: photos distinctes aussi pour les ex aequo
- le polling `session_meta_get` ne remonte plus seulement `rank + photo_src` pour les photos podium;
- `boot_lib.php` transmet maintenant aussi les metadonnees de ligne necessaires au matching organizer:
  - `photo_row_key`
  - `label`
  - `score`
  - `phase_label`
- `canvas_display.js` n'ecrase donc plus les photos dans une simple map `rank -> src`;
- le podium organizer essaie maintenant de resoudre une photo par carte via:
  - la cle de ligne si elle existe;
  - sinon un matching par `rang + nom + phase` ou `rang + nom + score`;
  - sinon le premier media libre restant sur ce rang;
- effet attendu:
  - si deux gagnants sont `#1 / #1`, le master peut afficher deux photos differentes;
  - le fallback historique `1 photo par rang` reste compatible si l'ancienne donnee est encore la seule disponible.

## Update 2026-04-11 — Remote fin de partie: CTA mobile plus compact
- le travail de compacite CSS du CTA remote de fin de partie a servi de base au redesign suivant;
- depuis le patch 2026-04-16, ce CTA unique vers `pro` n'existe plus: il est remplace par un bouton photo par ligne de podium, mais les garde-fous de largeur mobile et la couleur de texte branding restent reutilises.

## Update 2026-04-10 — Remote papier: ajout participant EP reseede immediatement l'identite runtime canonique
- portee volontairement ciblee:
  - participants issus d'un lookup DB (`sourceTable/sourceId`);
  - ajoutes par l'animateur depuis la remote;
  - donc chemins admin papier, pas le flux joueur `EP -> games` classique deja stable.
- `remote-ui.js` reseede maintenant la liste locale des joueurs juste apres `player_register` sur ce chemin:
  - `player_id` canonique prioritaire;
  - `playerDbId` / `playerId` numerique conserve comme metadonnee secondaire si le backend le renvoie;
  - `playerName`, `score`, `playerScore` completes pour que les actions admin suivantes manipulent deja un objet joueur au format runtime.
- le but n'est pas d'introduire un nouveau contrat:
  - le snapshot `players_get` reste la source autoritaire;
  - le reseed local comble seulement la fenetre immediate apres ajout remote, avant que le refresh standard / WS ne rehydrate la liste complete.
- correctif racine complementaire cote backend:
  - `quiz_adapter_glue.php`, `blindtest_adapter_glue.php` et `bingo_adapter_glue.php` ne dependent plus d'un `INSERT ... ON DUPLICATE KEY` pour reutiliser une identite runtime existante;
  - ils relisent maintenant explicitement la ligne `session + player_id`, reactivent cette ligne si elle existe, et desactivent les doublons residuels portant la meme identite;
  - raison: le schema canon historique ne garantit pas partout un unique index runtime sur `session_id + player_id`, donc l'ancien pseudo-upsert pouvait laisser passer de vrais doublons SQL pour un meme participant EP.
- l'upsert runtime renvoie maintenant aussi un etat metier explicite:
  - `created`;
  - `reactivated`;
  - `already_active`.
- garde complementaire:
  - quand `player_register` est appele avec `ep_connect_token`, les adapters resolvent maintenant l'identite EP (`id_equipe` / `id_joueur`) directement depuis le bridge token cote serveur;
  - la cle runtime canonique ne depend donc plus uniquement du `sourceTable/sourceId` remonte par le navigateur;
  - effet vise: un retour `EP -> games` retombe sur la meme identite runtime qu'un ajout remote lookup du meme participant.
- nuance Bingo-only ajoutee apres regression `develop/fix_joueursEP`:
  - l'audit a confirme une divergence explicite entre `main` et la branche courante dans `bingo_api_player_register()`:
    - `main` ne refait pas de re-resolution serveur EP a cet endroit;
    - `develop/fix_joueursEP` appelle `canvas_api_ep_link_resolve(...)` avant de recalculer `player_id`.
  - pour `Bingo Musical`, seule une source joueur (`participantType=player`, `sourceTable=equipes_joueurs`, `id_joueur > 0`) est compatible avec le contrat runtime:
    - `bingo_players.player_id` reste la cle canonique de session;
    - les grilles numeriques et papier restent rattachees a `jeux_bingo_musical_grids_clients.id_joueur`;
    - une identite `team/equipes` ne constitue donc pas une source canonique exploitable pour ce jeu.
  - `bingo_api_player_register()` traite maintenant ce point explicitement:
    - `canvas_api_ep_link_resolve(...)` est encapsule dans un `try/catch(Throwable)` pour ne plus remonter de `500` brut depuis ce bloc;
    - si la re-resolution serveur ne remonte pas d'`id_joueur` exploitable (`TEAM_ONLY`, `PLAYER_ID_MISSING`, erreur SQL/bridge), le backend journalise le cas puis conserve le fallback sur le payload front deja resolu;
    - si un payload `team/equipes` arrive quand meme sur Bingo, il est purge comme source unsupported avant le bridge runtime, afin d'eviter une canonicalisation erronée sur une identite d'equipe.
  - correctif bridge associe:
    - `player_register` lie deja la row de `championnats_sessions_participations_games_connectees` via `canvas_ep_account_bridge_link_runtime_participant(...)`;
    - `ep_link_finalize` est maintenant idempotent: si la row bridge existe deja avec le meme `game_player_id` / `game_player_key`, il renvoie un succes `already_linked` au lieu d'un faux `TOKEN_INVALID`;
    - les erreurs bridge attendues (`TOKEN_INVALID`, `SESSION_MISMATCH`, `GAME_MISMATCH`, `USERNAME_MISSING`) ne doivent plus sortir du canvas bridge en HTTP `500`, mais en `400`.
  - diagnostic WS Bingo issu de la comparaison avec `main`:
    - aucune divergence de branche n'a ete trouvee dans `play-ws.js` ni dans le serveur WS Bingo sur le chemin `auth_player`;
    - le blocage numerique etait en amont, dans `register.js`, lors de l'emission `player/ready` apres `player_register_ok` + `grid_assign`;
    - une regression de branche avait remplace `isPaperMode()` par `paperMode` sur ce payload;
    - `paperMode` etant hors scope, un `ReferenceError` etait absorbe par le `try/catch`, ce qui supprimait silencieusement `player/ready`;
    - sans `player/ready`, `play-ws.js` ne lance ni `bootWSPlayer({ auth })` ni l'`auth_player` Bingo numerique.
- usage UI:
  - la remote papier n'annonce plus un faux "participant ajoute" quand le participant EP/equipe est deja actif dans la session; elle affiche un message deja-inscrit adapte au type;
  - la page d'inscription `games` traite `already_active` comme un succes idempotent et rehydrate l'identite locale comme un joueur deja inscrit, au lieu de tomber sur une erreur generique.
- correctif complementaire cote player:
  - `games/web/includes/canvas/play/player_identity.js` traite maintenant le `player_id` renvoye par `player_register` comme source de verite pour la session courante;
  - auparavant, si un `player_id` local genere existait deja, il n'etait pas remplace par la cle serveur stable;
  - effet observe dans les logs de session: un meme `player_db_id` pouvait etre vu successivement sous plusieurs `player_id` canoniques en WS, ce qui recreait un doublon purement memoire/UI cote remote et master alors que la DB runtime etait deja dedupee.
- garde complementaire cote WS player papier:
  - pour `quiz` et `blindtest`, le chemin `player/paper:listen` est maintenant strictement passif;
  - il ouvre le WS pour recevoir `update_session_infos`, mais n'envoie plus `registerPlayer` ensuite;
  - les succes d'inscription papier cote `register.js` basculent eux aussi vers cette ecoute passive au lieu d'emettre `player/ready`.
- effet vise:
  - couper a la source le second enregistrement WS d'un participant deja inscrit en runtime par l'admin;
  - eviter les doublons `totalPlayers:2` purement memoire pour un meme `player_db_id`, constates notamment sur `blindtest` papier.
- effet attendu:
  - aligner plus tot la logique admin remote sur la logique joueur classique, sans patcher separement chaque action admin.
  - dans les deux sens, `remote lookup -> EP -> games` et `EP -> games -> remote lookup` doivent maintenant retomber sur la meme ligne runtime au lieu d'en creer une seconde.
  - pour `bingo`, cet alignement reste borne aux identites joueur; si la re-resolution serveur devient inexploitable, le flux doit rester operationnel sans `500` et sans conversion forcee en identite d'equipe.

## Update 2026-04-09 — Fin de session `games`: retour organizer fiche detail `pro` + photos podium live
- le runtime `games` expose maintenant une cible canonique `sessionDetailUrl` vers `pro/extranet/start/game/view/<id_securite_session>` pour la surface organizer.
- les ajouts remote issus d'une recherche DB n'ecrivent plus de `return_token` vide dans `championnats_sessions_participations_games_connectees`; un token technique unique est maintenant genere pour rester compatible avec la contrainte SQL globale `uniq_return_token`, sans changer le parcours EP joueur classique.
- le podium organizer ne depend plus d'un `file_exists(...)` local sur le serveur `games` pour diffuser les photos gagnants; si le media est present en base mais que le FS local n'expose pas le meme mount que `www/pro`, l'URL canonique `www/upload/...` est quand meme renvoyee au polling.
- correctif racine 2026-04-09: `games_ajax.php` charge maintenant `global_librairies.php` avant le bridge canvas. Sans cela, les endpoints canvas executes avec `exit` precoce, comme `session_meta_get`, ne voyaient pas les helpers globaux (`app_session_get_id`, `app_session_get_detail`, `app_session_results_get_context`) necessaires pour remonter les photos podium vers l'UI organizer.
- organiser:
  - `end_game.js` ne renvoie plus seulement vers le dashboard `pro`;
  - la sortie volontaire priorise maintenant la fiche detail session, afin que l'organisateur retombe directement sur l'upload des photos gagnants.
- remote:
  - ce flux de redirection vers la fiche detail `pro` a ensuite ete remplace par l'upload direct dans `games` (voir update 2026-04-16);
  - le `quit` remote reste un simple `close/about:blank` apres liberation du slot.
- podium organizer:
  - `session_meta_get` expose maintenant `podium_photos` (rang + URL) en plus de la meta de verrouillage format;
  - la signature de polling organizer integre ces photos, ce qui permet de re-render le podium quand elles changent apres la fin de session;
  - `canvas_display.js` sait afficher une photo dediee par rang `#1/#2/#3`, avec cadrage stable.
- portee:
  - ce flux cible uniquement les sessions qui ouvrent reellement l'interface `games`;
  - `Cotton Quiz` V1 historique ne fait pas partie de cette mecanique.

## Update 2026-04-07 — Refus d'inscription: purge locale ciblee + `playerDbId` strict par session
- le portail player `games` nettoie maintenant explicitement l'identite locale provisoire seulement quand `player_register` est refuse pour un motif metier de nom:
  - `USERNAME_ALREADY_USED`;
  - `USERNAME_REFERENCED`.
- ce cleanup ne s'applique pas aux erreurs techniques (`timeout`, erreur reseau, `SQL_ERROR`, reponse invalide), afin de ne pas casser une reprise legitime si le serveur a en realite valide l'inscription.
- pour `Bingo Musical`, la purge efface aussi les artefacts de grille purement locaux (`grid_id`, `grid_secret`, cellules/numeros coches) afin d'eviter qu'un premier refus de pseudo ne pollue la seconde inscription.
- en complement, les chemins `bingo` sensibles (`register`, hydratation/sync de grille, auth WS) ne relisent plus un `playerDbId` global legacy:
  - seul l'id DB scope a la session courante est accepte;
  - le fallback global legacy reste reserve aux chemins de migration/compat, pas au gameplay actif.
- effet attendu:
  - un refus de pseudo ne laisse plus derriere lui une identite locale fantome susceptible de casser une inscription suivante;
  - un `playerDbId` persiste depuis une autre session ne peut plus etre recolle a tort sur la session bingo courante.

## Update 2026-04-03 — Inscriptions runtime / EP / remote: garde de nom + bridge EP stabilises
- les inscriptions runtime pures refusent maintenant:
  - un nom deja utilise dans la session, meme inactif;
  - un nom deja reference chez l'organisateur.
- les bypass restent bornes aux seuls cas voulus:
  - inscription via `ep_connect_token`;
  - ajout remote issu d'un lookup DB existant.
- les messages d'erreur utilisateur sont harmonises:
  - `Ce nom est déjà utilisé dans cette session. Merci d'en choisir un autre.`
  - `Ce nom n'est plus disponible. Merci d'en choisir un autre.`
- quand l'animateur ajoute depuis la remote un joueur ou une equipe deja connu en base, `games` renseigne maintenant aussi `championnats_sessions_participations_games_connectees` avec `game_player_id`, `game_player_key` et `date_consumed`.
- une reinscription EP sur la meme session reutilise maintenant une identite runtime stable, au lieu de recreer une nouvelle row runtime a chaque retour.

## Update 2026-04-02 — `EP -> games`: un token de retour priorise maintenant le flow EP sur le resume local
- quand un joueur revient de `play` avec `ep_connect_token`, le portail player `games` ne laisse plus une identite locale deja stockee court-circuiter l'auto-inscription EP.
- avant ce correctif, un `player_id` local sur la meme session pouvait declencher un `resume` puis un `return` anticipes dans `register.js`, ce qui bypassait completement `tryAutoRegisterFromEp()`.
- effet attendu:
  - comportement aligne entre onglet normal et onglet prive sur un retour `Compte joueur Cotton`;
  - le flux EP reste prioritaire tant qu'il n'est pas finalise.

## Update 2026-04-02 — Observabilite `EP -> games`: preuves centralisees du flux `ep_connect_token`
- `logger.global.js` remonte maintenant aussi les etapes `register/debug` du portail player pour les retours `play -> games` avec `ep_connect_token`.
- les journaux centralises de session peuvent maintenant montrer explicitement:
  - la resolution bridge `ep_link_resolve`;
  - le depart/abort d'auto-inscription EP;
  - l'upsert `player_register`;
  - la finalisation `ep_link_finalize`;
  - les erreurs `missing_player_id` / upsert joueur.
- objectif:
  - diagnostiquer depuis le `.jsonl` de session l'etape exacte ou le flux `Compte joueur Cotton` decroche, sans devoir reconstruire le parcours uniquement depuis la console navigateur ou les logs PHP.
- ces preuves restent volontairement en `debug`, afin de conserver la capacite de diagnostic sans surcharger le niveau de logs prod.

## Update 2026-04-02 — Player reload: bootstrap `GameMeta` aligne avec la reprise locale
- le portail session player `games` publie maintenant `window.GameMeta = { slug, title }` comme l'organizer, en plus de `window.AppConfig.gameSlug`.
- ce metadata manquait sur le canvas player alors qu'une partie du runtime commun (`logger`, `ws_effects`, `session_modals`, `canvas_display`, etc.) continue de relire `window.GameMeta?.slug`.
- effet fonctionnel vise:
  - reprise locale plus stable quand un joueur deja connu en `localStorage` recharge la page avant ou pendant l'entree effective dans l'interface de jeu;
  - disparition des traces `game: ''` cote logger player sur ce chemin de reprise.
- garde complementaire:
  - `logger.global.js` relit maintenant aussi `window.AppConfig.gameSlug` si `window.GameMeta` manque encore.

## Update 2026-04-01 — Reset design organizer: session + compte si design identique
- le CTA `Revenir au design d'origine du jeu` de la modale organizer ne se limite plus au branding session courant.
- `session_modals.js` demande d'abord un `delete_preview` au backend branding, puis envoie un delete `cascade_client_branding_if_matching=1`.
- le wording de confirmation annonce désormais aussi:
  - la suppression automatique du design compte s'il existe et s'il correspond au design effectif de la session;
  - l'arret d'usage de ce design pour les prochaines sessions;
  - la conservation du design sur les sessions deja programmees qui l'heritaient deja.
- ces lignes d'impact ne sont affichees que si le backend confirme qu'un branding compte sera reellement supprime.
- dans la modale SweetAlert, cette mention conditionnelle est rendue en corps reduit, italique, avec un leger espacement au-dessus.
- le front `games` laisse le backend `global` decider si le design compte doit etre supprime, afin d'eviter toute divergence locale sur la portee effective du reset.

## Update 2026-04-01 — Remote papier: lookup DB de joueurs / equipes existants
- la remote papier ne cree plus seulement des participants runtime en saisie libre.
- nouvelle action bridge globale `participant_lookup`:
  - `quiz` -> recherche d'equipes existantes dans `equipes`;
  - `blindtest` / `bingo` -> recherche de joueurs existants dans `equipes_joueurs`.
- la modale remote propose des suggestions a partir de 3 caracteres, tout en conservant la validation en saisie libre si aucun resultat ne convient.
- si l'animateur choisit une entree existante, la remote envoie un `player_id` canonique `p:uuid` derive de facon deterministe de la source metier (`id_equipe` / `id_joueur`).
- pour `quiz`, en cas d'equipes homonymes, le sous-texte de suggestion affiche jusqu'a 2 prenoms de joueurs associes a l'equipe afin d'aider l'animateur a distinguer les doublons sans exposer un id technique en premier niveau.
- pour `blindtest` / `bingo`, les fiches `equipes_joueurs` portant un email technique `@cotton-quiz.com` sont exclues du lookup remote: elles sont considerees comme des identites internes / invitations non finalisees et ne doivent pas polluer la selection animateur.
- pour les autres joueurs, en cas d'homonymie sur le libelle affiche (`pseudo` prioritaire, sinon `prenom`), le sous-texte de suggestion affiche l'email associe sous forme masquee (`xx***yy@domaine`) quand une colonne email standard est disponible dans `equipes_joueurs`.
- le lookup joueur dedoublonne aussi les fiches qui partagent le meme libelle affiche et le meme email normalise, en gardant prioritairement la fiche a activite/date la plus recente (`updated_at`, sinon `created_at`, sinon `id` le plus grand).
- effet attendu:
  - re-ajouter le meme joueur/equipe sur une session papier reactive la meme identite runtime au lieu de creer un doublon logique;
  - les cas hors base restent couverts par le fallback saisie libre.
- la validation backend `player_register` n'est plus bornee a `20` caracteres en dur:
  elle lit la longueur declaree de la colonne `username` par jeu via `information_schema`, avec fallback `20` si l'introspection echoue.

## Note d'evolution — Branding par type de jeu
- l'UI organizer `games` ne porte aujourd'hui qu'un branding session (`id_type_branding = 1`) ou compte global (`id_type_branding = 4`), sans dimension `quiz / blindtest / bingo`.
- si un branding par type de jeu est introduit plus tard, `games` devra transmettre le type de jeu courant au save, au preview et au delete du branding, et borner le wording `prochaines sessions` au seul type courant.
- cette evolution ne peut pas etre tenue proprement par le front seul: elle depend d'un modele `global` capable de resoudre un branding scope + type de jeu avec fallback vers le branding global existant.

## Update 2026-04-01 — Organizer: QR remote papier borné a la fenetre d'ouverture
- `session_modals.js` n'ouvre plus automatiquement le bloc `#pilotQRWrap` sur le seul critere `paperMode`.
- L'auto-ouverture du QR remote exige maintenant `papier + ClientSessionMeta.isOpen`.
- Effet fonctionnel:
  - session papier non ouverte: la modale `Options de jeu` garde le QR remote replie;
  - session papier ouverte: le QR remote continue a s'ouvrir automatiquement;
  - le garde existant de `boot_organizer.js` au clic reste la seconde ligne de defense si l'utilisateur tente quand meme d'ouvrir le bloc hors session.

## Update 2026-03-26 — Player register: pont `EP -> games` pour compte joueur
- `player_canvas.php` n'expose plus un simple lien inline: l'ecran d'inscription joueur rend maintenant un bloc `Compte joueur Cotton` distinct du formulaire pseudo, avec promesse minimale d'usage de l'espace joueur (`historique`, `prochaines sessions`, `organisateurs deja frequentes`) et CTAs de connexion / creation de compte pointant vers `play` avec contexte session.
- `register.js` sait consommer un `ep_connect_token` de retour, résoudre l'identité EP via le bridge canvas, puis lancer l'auto-inscription joueur dès que la gate de session est ouverte.
- le runtime continue d'écrire dans `*_players` pour le gameplay; la liaison métier durable EP -> session -> joueur de jeu est finalisée à part dans `championnats_sessions_participations_games_connectees`.
- nouveaux endpoints bridge côté canvas:
  - `ep_link_resolve`
  - `ep_link_finalize`
- effet attendu:
  - Blindtest / Bingo: auto-inscription au prénom joueur EP;
  - Quiz numérique: auto-inscription au nom d'équipe déjà résolu côté `play`.
- nuance de routing quand la session n'est pas ouverte:
  - future non ouverte: le bloc compte joueur garde ses CTA vers `play`, mais le retour post-auth EP vise le signalement de participation probable plutôt qu'un rebouclage direct vers `games`;
  - session expirée/non ouverte: le retour post-auth EP vise l'agenda joueur pour inciter à rejoindre de prochaines sessions.
- regle temporelle explicite:
  - une session est consideree `ouverte` pour ce parcours si elle a lieu aujourd'hui;
  - ou si elle a eu lieu hier et qu'il est encore strictement avant `12:00`;
  - au-dela, elle repasse en `expiree`.
- nuance au jour J avant ouverture:
  - quand un joueur revient de `play` avec un `ep_connect_token`, le message d'attente n'apparait plus dans le bloc pseudo;
  - il remplace maintenant le texte et les CTA du bloc `Compte joueur Cotton`;
  - `Blindtest` / `Bingo`: message centré sur l'inscription du joueur;
  - `Quiz`: message centré sur l'inscription de l'équipe, avec mention du joueur connecté.
  - ce contexte EP est maintenant aussi résolu explicitement tant que la gate reste en `NO_MASTER`, pour éviter toute réouverture parasite du formulaire pseudo avant l'ouverture réelle.
- nuance session ouverte:
  - hors `NO_MASTER`, le bloc `Compte joueur Cotton` revient à sa promesse standard et n'affiche pas le message d'attente lié au pont EP.
- nuance session papier:
  - après un retour `EP -> games` sur une session papier, l'UI ne bascule pas vers le jeu;
  - le formulaire pseudo reste masqué et le rendu historique papier est repris, avec confirmation contextualisée joueur/équipe et CTA de désinscription.
  - le jour J avant ouverture (`NO_MASTER`), ce même rendu de confirmation papier est maintenant affiché immédiatement au retour d'EP.
  - sur ce parcours papier, la fermeture de gate WS ne bloque pas le retour EP: le gating WS numerique est volontairement bypasse pour retomber sur ce rendu papier historique au lieu d'essayer d'ouvrir l'interface de jeu.

## Update 2026-03-24 — Observability prod reprise player mobile
- `play-ws.js` emet maintenant une preuve front `player/ws:resume_ok` uniquement quand une vraie reprise joueur aboutit apres coupure/reouverture (`foreground:*` ou `ws_open_reconnect`).
- `logger.global.js` publie cette preuve en `info` sous `PLAYER_SESSION_RESUME_OK` avec `{ sid, game, ws_state, reason }`.
- objectif: pouvoir relire en prod la stabilite reelle des sessions joueur sur Bingo / Blindtest / Quiz sans remonter toutes les decisions lifecycle en `info`.

## Update 2026-03-24 — Branding: upload visuel perso et persistance locale alignés sur le rendu serveur
- `session_modals.js` conserve maintenant le `File` original pour l'envoi branding, tout en gardant un preview local léger pour la modale organizer.
- Le localStorage `games` ne persiste plus les objets `File`; il persiste seulement l'état branding sérialisable.
- Au boot, `initSessionModals()` fusionne désormais `window.ServerBranding` injecté par PHP avec le cache local au lieu d'écraser la version serveur.
- Si le branding local stocke encore une ancienne `dataURL` custom et qu'une URL serveur branding existe déjà, l'URL serveur reprend la priorité pour éviter l'effet `net au chargement puis flou`.
- Après un save branding réussi, `games` réécrit le branding persistant avec les URLs serveur finales (`logo` / `visuel`) avant la diffusion WS `update_branding`.
- En cas d'échec upload `logo` / `visuel` remonté par le serveur (fichier trop lourd, upload partiel, erreur PHP), l'alerte organizer réaffiche maintenant le message métier exact au lieu d'un simple échec générique.
- Le reset branding depuis l'UI organizer est maintenant borné à la couche session: il ne peut plus supprimer par erreur le branding effectif amont (notamment un branding réseau TdR servi à un affilié).
- Effet attendu: le rendu de jeu reste stable après chargement et n'est plus dégradé par une ancienne preview compressée conservée en local.

## Update 2026-03-06 — Réseau Étape 1 (guard offre effective)
- `organizer_canvas.php` supprime le fallback local divergent de contrôle d’offre (`activeCount/sessionOfferActive`).
- Le repli utilise désormais le resolver métier central `global` (`app_ecommerce_offre_effective_get_context(...)`) quand `app_session_launch_guard_get(...)` n’est pas disponible.
- Effet: contrat unique de décision d’accès (offre propre / réseau / inactif), sans redéfinition locale dans `games`.

## Update 2026-03-04 — Quiz lot `L`: ordre des questions (position > id)
- Hydratation quiz (`quiz_adapter_glue.php`, lot `L`):
  - tri appliqué: `ORDER BY q.position ASC, q.id ASC`.
- Comportement attendu:
  - priorité à l’ordre métier bibliothèque (`questions.position`),
  - fallback stable sur `id` quand `position` est absente/identique (ex: `0` partout).

## Update 2026-03-05 — Remote: état visuel de démarrage + quiz: fit question longue
- Remote waiting (`remote_canvas.php`, `remote-ui.js`, `remote_styles.css`):
  - ajout d’un état “démarrage en cours” pendant jingle/initialisation après Start,
  - affichage conditionné à un démarrage réel de partie (pas de visuel d’initialisation avant le 1er start),
  - pendant cet état, les textes de bienvenue sont masqués pour ne garder que le message de démarrage.
- Quiz organizer (`canvas_display.js`, `quiz_ui.js`):
  - fit du titre de question renforcé pour les textes très longs (notamment lots temporaires `T` en papier),
  - bloc question conservé fixe; c’est la taille du texte qui s’adapte pour rester visible.

## Terminologie (anti-confusion)
- **WS frame** : objet JSON envoyé sur socket, champ obligatoire `type`.
- **HTTP bridge** : “action” dispatchée côté PHP (bridge `t=jeux&m=canvas`).
- **Bus event** : `Bus.emit/on(...)` côté front (Bus-first).

---

## Scope & entrypoints
### Pages (HTML)
- Organizer : `web/organizer_canvas.php`
- Player : `web/player_canvas.php`
- Remote : `web/remote_canvas.php`

### Bridge HTTP (Canvas API)
- `web/games_ajax.php` (alias possible : `web/global_ajax.php` selon routage global/branding)

---

## Actors & flows (vue mentale)
### Actors
- **Organizer** : maître de session (démarre/pause/next/prev, options, fin de partie). UI + WS + persistance.
- **Remote** : écran secondaire / télécommande (reçoit l’état, envoie des commandes).
- **Player** : client mobile (register/auth, reçoit l’état, joue).

### Flows principaux
1) Organizer ↔ **WS** ↔ Players  
2) Organizer ↔ **WS** ↔ Remote  
3) Organizer ↔ **HTTP (PHP)** ↔ DB (persistance `session_update`, options, etc.)

### Backend surfaces (résumé)
- `web/games_ajax.php` : bridge JSON (CORS + auth optionnelle + idempotence) → dispatch
- Dispatch côté PHP vers : `web/includes/canvas/php/*_adapter_glue.php` (quiz / blindtest / bingo)

---

## Runtime & I/O

## WebSocket (front)
### Format des frames sortantes (canon)
- **Chaque frame WS** est un objet JSON : `{ type: string, ...fields }`
- Corrélation reply possible : ajout `"_cid"` (optionnel)
- Sérialisation/queue : `web/includes/canvas/core/ws_connector.js` (Bus `game:ws:send`)  
  Réf : `ws_connector.js:300-327`

### Handshake / reconnection (std vs bingo)
- **Non-bingo (std)** : `ws/open` émis dès `onopen`, heartbeat client toutes ~25s, flush queue.
- **Bingo** : à l’ouverture socket, envoie auth (`auth_*`), **attend un premier message serveur `type:"state"`** comme ACK avant d’émettre `ws/open`. Pas de heartbeat client ; répond aux `ping` serveur par `pong`.
- **Logs front V1 (player)** :
  - production des logs côté navigateur dans `core/logger.global.js`;
  - transport de flush = WS uniquement (`game:ws:send` -> `log_event` / `log_batch`);
  - pas de fallback HTTP / `sendBeacon` pour ces logs V1;
  - `PLAYER_FRONT_BOOT` est maintenant gardé pending si le transport n’est pas encore réellement prêt, puis rejoué exactement une fois au premier `ws/open`;
  - `ws_connector.js` publie aussi un snapshot runtime partagé (`window.__CANVAS_WS_RUNTIME__`) sur les transitions WS majeures; `logger.global.js` s’en sert pour hydrater `ws_ready_state` si l’événement `ws/status` initial a été manqué lors d’une accroche Bus tardive;
  - le contrat de flush reste:
    - flush fin de session,
    - ou flush forcé explicite;
  - une frame WS `force_flush` est maintenant exécutée côté `player` et `remote`, ce qui permet de faire remonter des logs front distants sans ajouter de flush auto en cours de session.

### Router inbound partagé
- `web/includes/canvas/core/ws_effects.js` écoute `Bus.on('game:ws:message')` **une fois** et route des types WS vers des events Bus “srv/*” (et bingo-specific).  
  Il ignore les types heartbeat.  
  Réf : `ws_effects.js:450-664`
- Correctif 2026-02-12 (anti-régression lots Bingo): le hook `Bus.on('options/updated')` n’envoie plus `update_session_infos` pour toute option; l’envoi est limité aux champs de contrôle de session (`paperMode`, plus `manualAdvance` pour quiz), afin d’éviter des updates session inutiles sur simples options gameplay (`songDuration`, etc.).

### Types inbound traités par `ws_effects.js` (canon, extraits)
- `endGame` → `srv/endGame` (hydration scores) (`ws_effects.js:450-466`)
- `paper_finalize_end` → `srv/paper/finalizeEnd` (`ws_effects.js:468-470`)
- `togglePlayPause` → `srv/togglePlayPause` (`ws_effects.js:472-478`)
- `togglePause` → `srv/toggleInterseriesPause` (`ws_effects.js:479-480`)
- `nextSong` / `prevSong` → `srv/nextSong` / `srv/prevSong` (`ws_effects.js:480-493`)
- `skipPause` → `quiz/interseries/end` (`ws_effects.js:494`)
- `forcedDisconnect` → notice + end session (`ws_effects.js:495-510`)
- `gameOptionsUpdate` → persist options + `options/updated` (`ws_effects.js:512-547`)
- `force_full_current` → `srv/forceFullCurrent` (`ws_effects.js:540-544`)
- `start_support` → `srv/startSupport` (`ws_effects.js:545-547`)
- `support_ended` → `srv/supportEnded` (`ws_effects.js:548-550`)
- Bingo :
  - `state` → patch store + `bingo/stateSnapshot` + `srv/phaseUpdate` / `srv/playerUpdate` / `srv/notifications` (`ws_effects.js:552-611`)
  - `remote_action` → map vers `srv/*` ou `options/updated` (`ws_effects.js:612-653`)

> Note : `canvas_display.js` ne consomme pas WS directement (wiring UI/Bus uniquement).

---

## HTTP / PHP bridge (Canvas)
### Endpoint
- Bridge JSON : `web/games_ajax.php` (route `t=jeux&m=canvas`)

### Service-token auth (compat front + service)
- **Auth service-token** appliquée quand le header `HTTP_X_SERVICE_TOKEN` est fourni (canal inter-service).
- Secret attendu : env `CANVAS_SERVICE_TOKEN`.
- En cas de header invalide : 403 JSON `{ ok:false, error:{code,...}, ... }`.
- Les clients browser (sans header service) restent compatibles en mode public.

### Idempotence `game_events`
- Les actions mutatrices passent par une liste centrale bridge (`MUTATING_ACTIONS`), avec résolution `getOrCreateEventId(...)`.
- Si `event_id` est absent/invalide, le bridge génère un UUID v4 et loggue `MISSING_EVENT_ID` (warning structuré).
- Si `event_id` est présent/valide, le bridge loggue `EVENT_ID_RX`.
- Ensuite insertion préalable dans `game_events` pour ces actions mutatrices.
- Dédup : duplication détectée par SQLSTATE 23000 → on répond `ok` avec `already_processed:true` et on **court-circuite** le handler.
- En pratique, l’unicité repose sur `event_id` (pas de composite référencé dans le code).  
  Réf : `web/games_ajax.php:155-175`
- Côté front `games`, les appels mutateurs passent désormais avec `event_id` (`canvasCall` et flux player register/deactivate/grid_assign).
- Remote paper register (`remote-ui.js`): `player_register` envoie aussi `event_id`, conservé en localStorage pour retry idempotent tant que la tentative n’est pas confirmée.

### Identité joueur (key-first)
- Les payloads WS/API player-scoped doivent être key-first: `player_id` canon (`p:<uuid>`) prioritaire, `playerId` numérique optionnel (compat).
- `playerId` ne doit jamais transporter un `p:<uuid>`; la validation est faite côté wrappers WS et côté glue PHP.
- Les actions player-scoped des glues quiz/blindtest/bingo exposent `identity_mode` (`canon|legacy`) et `legacy_identity` (bool) pour piloter la suppression du fallback legacy.
- Persistance front canon (session-scoped):
  - `${game}:session_id`
  - `${game}:player_stable_id:${sid}` -> `p:<uuid>` (source de vérité)
  - `${game}:player_db_id:${sid}` -> numeric optionnel
- Helper front: `web/includes/canvas/play/player_identity.js`:
  - `getOrCreatePlayerId({game,sid})` avec migration legacy (`${game}:player_stable_id`, `${game}:player_id`, `player_id`)
    - si une session a déjà une origine d’identité (`${game}:player_id_origin:${sid}`), la suppression de la clé scoped force une régénération `p:<uuid>` (pas de "résurrection" depuis une clé globale legacy)
  - `persistServerPlayerIdIfAbsent(...)` pour ne jamais écraser le scoped canon avec une valeur non canonique
  - log debug contractuel: `PLAYER_ID_STORAGE_RESOLVED {game,sid,source:'scoped|migrated|generated'}`
- Remote (organisateur, ajout joueur papier): `remote-ui.js` maintient aussi une identité canonique locale par clé `game + session + username normalisé` et l’envoie en key-first sur `player_register`.

### Bingo — persistance `phase_winner` (Canvas API)
- Handler : `web/includes/canvas/php/bingo_adapter_glue.php::bingo_api_phase_winner`.
- Schéma : table `bingo_phase_winners` (UNIQUE `event_id` + `(session_id, phase)`, source de vérité), colonnes dénormalisées sur `bingo_players` (`phase_wins_count`, `last_won_phase`, `last_won_at`).
- Migration 2026-02-12 : ajout progressif `bingo_phase_winners.player_id_key` (canonique `p:*`) via script SQL idempotent, avec fallback compat legacy si colonne absente.
- Logique : transaction ; identité gagnant résolue key-first (`player_id` canonique -> `player_db_id`) ; insert historique ; si `event_id` déjà vu ou même joueur sur la même phase -> `already_processed=true`; si autre joueur sur phase existante -> `ok=false`, `error=phase_winner_conflict` + `reason=phase_winner_conflict`; sinon avance `phase_courante`, incrémente dénorm, log `PHASE_WINNER_PERSISTED`.

### CORS / origins (résumé)
- Origins **https only**.
- Dev : `*.dev.cotton-quiz.com` (exclut `global.dev.cotton-quiz.com`)
- Prod : `*.cotton-quiz.com` (exclut `global.cotton-quiz.com`)  
  Réf : `games_ajax.php:71-90`

---

## WS contracts (canon, par rôle)
> Objectif : distinguer **commandes sortantes** (frames envoyées) et **messages entrants** (types reçus).

### Organizer
- **Outbound (commands)** : typiquement `registerOrganizer`, `remoteGameState`, `togglePlayPause`, `togglePause`, `nextSong`, `prevSong`, `skipPause`, `force_full_current`, `endGame`  
  (émis via `Bus.emit('game:ws:send', ...)` depuis `boot_organizer.js` / `end_game.js` et modules de contrôle)
- **Inbound** : messages de présence/état (ex : `SECONDARY_PRESENT`, `SCORES_EDITING`) gérés dans `boot_organizer.js`, et messages gameplay “généraux” routés via `ws_effects.js`.

### Remote (`web/includes/canvas/remote/remote-ws.js`)
- **Outbound** (RemoteAPI → `game:ws:send`) :
  - contrôles : `togglePlayPause`, `nextSong`, `prevSong`, `skipPause`, `togglePause`
  - options : `updateGameOptions`
  - bingo : `remote_action` (`start_game|play_song|pause|next_song|set_duration|force_full_current`)
  - fin : `quitGame`, `paper_finalize_end`
- **Inbound** (handlers map) :
  - commun : `gameState`, `sessionUpdate`, `state`, `endGame`, `SESSION_ENDED`, `notification`, `remote_sync`, `updatePlayers`, `update_session_infos`, `update_branding`, `forcedDisconnect`, etc.
  - alias sync: `initializeOrUpdateSession` est traité comme `sessionUpdate` côté remote.
- options : `gameOptionsUpdate`, `GAME_OPTIONS_UPDATED`, `STATE_SYNC` (appliqués côté remote) + patchs provenant aussi de `gameState`/`sessionUpdate`/`remote_sync`.
- hydration tardive quiz/blindtest: `session_sync` renvoie désormais `playlistSongs` dès qu’une playlist non vide est disponible (pas uniquement au tout premier `initializeOrUpdateSession`), ce qui restaure le titre série / total questions / CTA support en remote.
- garde historique corrigée : le refresh des propositions n’est plus bloqué quand `currentSongIndex` logique reste identique pendant la transition jingle -> round #1.
- reveal remote (quiz/blindtest) stabilisé : la correction n’est plus effacée sur chaque `remote/options:proposals`, la classe visuelle canon `option-reveal` est appliquée avec compat legacy `.reveal`, `remote/options:correct` transporte `{text,key}`, et le patch DOM applique la correction par `data-option-key` (key-first, fallback texte uniquement).
- observability remote options : logs v1 `REMOTE_OPTIONS_RX` (réception), `REMOTE_OPTIONS_RENDER` (rendu), `REMOTE_OPTIONS_GUARD_BLOCK` (blocage guard), avec contexte `phase/isJingle/started`, émis en bus-first via `ui/remote:action` (pas de `window.Logger.debug` direct).
- remote add-player (`handleAddPlayerLive`) : payload `player_register` = `{ username, player_id, event_id, sessionId|sessionPrimaryId }` ; `player_id` canonique persisté localement ; `event_id` conservé jusqu’au succès pour retry idempotent.
- remote mode manuel: à réception `remote/sessionInfos` quand `paperMode` change, `applyManualModeUI()` est rejoué immédiatement pour éviter un calcul UI sur un `SESSION_PAPER` obsolète.
- remote actions joueur/phase (`remote-ui.js`) : `admin_player_register`, `admin_set_score`, `admin_phase_winner`, `admin_phase_fail` transportent `event_id`, `player_id` canonique si dispo, et `playerId` numérique en compat.
- remote listing joueurs (quiz/blindtest) : fusion key-first sur identité canonique (`player_id` si dispo, sinon id numérique) pour éviter les doublons d’affichage lors des snapshots mixtes (`playerId` legacy + `player_id` canonique).
- bridge PHP quiz/blindtest (`quiz_adapter_glue.php` / `blindtest_adapter_glue.php`) : `players_get` et preload `players` renvoient aussi `player_id` (et `updated_at` si disponible), avec fallback safe pré-migration si la colonne n’existe pas encore.
- mode historique (session terminée) : `players_get` accepte `includeInactive` pour inclure les participants déconnectés; la remote l’active automatiquement en vue terminée pour éviter de “sortir” des joueurs du classement final.
- WS quiz/blindtest (reconnexion orga sur session terminée) : réhydratation DB forcée + reconstruction du snapshot `endGame` pour réaligner l’affichage final avec les participants persistés.
- WS bingo (auth orga) : à l’authentification, si la phase courante est terminale, l’hydratation joueurs DB active `includeInactive` pour reconstruire un snapshot historique cohérent.
- exception Bingo (papier animateur) : `admin_phase_winner` peut être envoyé sans `player_id/playerId`; le WS Bingo applique alors un avancement manuel de phase (sans persistance `phase_winner` DB), pour permettre la progression même sans joueur sélectionné.
- organizer Bingo (`core/ws_effects.js`) : sur `phase_over`, la phase gagnée utilise désormais `won_phase` en priorité (fallback legacy via `next_phase` si absent) pour éviter les décalages d’annonce en correction manuelle papier.
- notifs Bingo admin manuel : les victoires forcées réutilisent le format historique `PlayerWin` (même canal/UI que les victoires standards), au lieu d’un message `Info` spécifique.
- fallback podium Bingo (orga + remote) : en absence de gagnants hydratés, affichage cohérent papier avec `Joueur inconnu` par phase gagnée (Bingo / Double ligne / Ligne), au lieu d’un fallback score-driven ou placeholders génériques.
- remote Bingo fin de partie : la liste joueurs est conservée en `Partie terminée` (ignore snapshots vides tardifs) et fallback `players_get` est déclenché si `endGame.players` est absent/vide.

### Player (`web/includes/canvas/play/play-ws.js`)
- **Outbound** :
  - quiz/blindtest : `registerPlayer { sessionId, player_id, playerId? }` (canon strict + db optionnel), gameplay `checkAnswer { player_id, ... }`, fin `quitGame`
  - bingo : auth auto `auth_player` / `auth_player_paper` avec `player_id` canon obligatoire (+ `id_player` db pour compat auth), fin `player_quit`
- **Recovery contract (mobile/background)** :
  - `ws_connector.js` reste seul pilote de la reconnexion transport;
  - au retour `visibilitychange/pageshow`, le player ne fait un re-register applicatif que si le transport est déjà `OPEN`;
  - si le transport est `CONNECTING` / `CLOSED` / `ERROR`, le player ne ferme rien et délègue au connector;
  - après reconnect transport, `ws_connector.js` rappelle `window.reRegisterPlayer(reason)` une fois `ws/open` atteint;
  - instrumentation V1 attendue:
    - `PLAYER_FRONT_BOOT`
    - `PLAYER_FRONT_LOG_FLUSH_TRY|OK|FAIL`
    - `PLAYER_WS_LIFECYCLE_DECISION`
    - `WS_CONNECTOR_LIFECYCLE_DECISION`
    - `PLAYER_REREGISTER_TRY|OK|FAIL`
    - `REGISTER_KEEP_LOCAL_IDENTITY_DESPITE_PROBE_MISS`
- **Observability chain (player front)** :
  - `PLAYER_FRONT_BOOT` est créé quand le logger player accroche réellement le Bus front, puis envoyé immédiatement si le transport est déjà `OPEN`, sinon rejoué au premier `ws/open`;
  - `PLAYER_FRONT_LOG_FLUSH_TRY|OK|FAIL` sont émis en `log_event` direct côté navigateur, avec `role:"player"` ou `role:"remote"` selon le client recevant le flush forcé;
  - si le logger a raté le premier `ws/status=open` (cas `remote` possible quand `window.Bus` arrive après l’ouverture), `buildFlushMeta()` relit l’état partagé du connector pour éviter un `ws_ready_state=unknown` sur un flush pourtant réellement envoyé sur WS;
  - ces marqueurs techniques de diagnostic (`PLAYER_FRONT_BOOT`, `PLAYER_FRONT_LOG_FLUSH_TRY|OK`, lifecycle, re-register OK, conservation d’identité locale) sont classés `debug` dans le viewer; seuls les échecs restent en `warn`/`error`;
  - les serveurs WS quiz/blindtest/bingo acceptent déjà `log_event` / `log_batch` côté player, puis les exposent via leurs endpoints `/logs`.
- Register API front (`web/includes/canvas/play/register.js`) :
  - quiz/blindtest/bingo envoient `player_register` avec `player_id` session-scoped (`${slug}:player_stable_id:${sessionId}`),
  - migration douce legacy: si `${slug}:session_id === sessionId` et `${slug}:player_stable_id` existe, copie vers la clé session-scoped,
  - la clé legacy est conservée pour compat mais n’est plus la source de vérité,
  - pour Bingo, séparation explicite front: `player_id` (canon `p:<uuid>`) vs `player_db_id` (id DB numérique legacy pour auth WS papier/numérique).
- Resume probes / identité locale :
  - un probe `players_get` / `bingoPlayerExists` temporairement négatif au retour mobile n’entraîne plus de purge immédiate du `player_id` local;
  - la décision métier est loggée en V1 (`REGISTER_KEEP_LOCAL_IDENTITY_DESPITE_PROBE_MISS`) puis la reprise WS/API tranche l’état réel.
- Bingo APIs player côté front (`play/register.js` + `play/play-ui.js`) :
  - `grid_assign`, `grid_hydrate`, `grid_cells_sync` envoient `player_id` canonique en premier, avec `playerId` numérique seulement en fallback compat,
  - `grid_id` est persisté en clé session-scoped `${slug}:grid_id:${sessionId}` (fallback lecture legacy `bingo_grid_id`),
  - juste avant `player_register` Bingo, `player_id` est normalisé strictement (jamais numérique) via `preparePlayerIdPreRegister`, avec migration legacy numeric vers `player_db_id` et log debug `PLAYER_ID_PRE_REGISTER`.
- **Inbound** :
  - commun : `gameState`, `sessionUpdate`, `updatePlayers`, `registrationSuccess`, `SESSION_ENDED`, `answerResult`, `answerReveal`, `update_session_infos`, `update_branding`
  - bingo : `state`, `passed_song`, `phase_over`, `remote_sync`, `notifications`, `demo_reset`
  - replacement: `SESSION_REPLACED` (last connection wins) -> onglet remplacé passe en read-only, bannière persistante, et reconnect manuel via “Reprendre ici”.
- player supports (quiz/blindtest) :
  - pipeline Drive partagé (tous types) via `core/player/index.js::getDirectGoogleDriveUrl` puis rendu `iframe` `/file/d/<id>/preview` si host `drive.google.com|docs.google.com`,
  - timeout adaptatif `drive/image` 15-20s, annulation des timers au `load/error`, logs `SUPPORT_START_FAIL_DETAIL` enrichis (`support_kind`, `timeout_ms`, `retry_count`, `stale_token`),
  - Drive: retry “hard reload iframe” retiré (fenêtre de grâce conservée) pour éviter les disparitions visuelles sur supports déjà partiellement affichés,
  - sémantique Drive timeout (tous types Drive):
    - `drive-timeout-before-render` = erreur bloquante (pas de rendu confirmé),
    - `drive-timeout-after-render` = soft error observée, mais `support/started` est maintenu en `drive-ready` pour ne pas masquer un support déjà visible/exploitable.
- Close code WS dédié replacement player : `4005` (`player replaced`) ; le transport front stoppe la reconnexion auto tant que la reprise n’est pas explicitement demandée.

### Note cross-origin (register)
- `localStorage` reste borné à l’origin (sous-domaine/protocole): un `player_id` session-scoped n’est pas partagé entre origins distinctes.
- Résilience actuelle: fallback serveur (`MISSING_PLAYER_ID` + UPSERT `(session_id, player_id)`), mais continuité inter-origins non garantie sans transport explicite du `player_id` (token/URL/postMessage côté produit).

### Quit player & `deactivate_player` (cross-game, canon 2026-02-10)
- `quiz` / `blindtest` : `quitGame` (front -> WS) puis désactivation Canvas (`deactivate_player`) côté WS serveur.
- `bingo` : `player_quit` (front -> WS) puis désactivation Canvas (`deactivate_player`) côté WS serveur.
- Conséquence: plus d’appel API front direct `deactivate_player` dans `games` pour bingo; responsabilité unifiée côté serveurs WS.

---

## Gameplay concepts & transitions (compact)
### Index & statuts (glossaire minimal)
- `currentSongIndex` (front) / `current_song_index` (DB) : position **0-based**
- Bingo : `num_passed_songs` sert à dériver l’index logique
- `item_index` : index **humain** “contenu” (1-based, sans jingles) utilisé pour logs (`core/player/index.js`, `emitRoundStarted`)
- `gameStatus` : libellé humain (0 En attente / 1 En cours / 2 Pause / 3 Partie terminée) via maps côté adapters
- Bingo phases : `current_phase` ∈ {0,1,2,3/5,-1} avec labels (En attente/Ligne/Double ligne/Bingo/Terminé) + `is_playing` pour En cours/Pause

### End-of-game (vue mentale)
- Déclencheur possible : commande `endGame` ou message `SESSION_ENDED` / phase bingo -1
- `ws_effects.js` route `endGame` vers `srv/endGame` (podium, scores)
- `end_game.js` (organizer) stop timers + `Bus.emit('session/end')` + cleanup UI (et persistance finale si branchée)

### Terminated Static Mode (2026-02-11)
- Si `window.Preload` indique une session terminée (`preload.isTerminated` ou `preload.session.isTerminated` ou `preload.session.gameStatus === "Partie terminée"`), le front ne boot pas de WS.
- Conséquences:
  - pas de `auth_client` / `registerOrganizer` côté organizer,
  - pas de `registerOrganizer` / `remoteGameState` côté remote,
  - pas de `auth_player*` / `registerPlayer` côté player si preload terminal dispo.
- Source de vérité en mode statique: `window.Preload` injecté serveur.
- Bascule live -> static:
  - à réception de `endGame`, le front conserve désormais le WS en live et ouvre une fenêtre de grâce de 20 min (session-scoped, `sessionStorage`),
  - au boot/reload, si preload est terminal mais qu’une grâce active existe, le WS reste autorisé,
  - hors grâce, le comportement statique preload s’applique (pas de boot WS).
- Bingo preload enrichi:
  - `preload.players.players[]` (issus de `bingo_players` via `players_get`, shape compat organizer),
  - `preload.phase_winners[]` (issus de `bingo_phase_winners`, ordonnés par phase),
  - utilisé en statique pour reconstruire le podium winners sans WS live.

---

## Paper mode
- Flags : `paperMode` (WS payload), DB `flag_controle_numerique` (0 papier / 1 digital)
- Override : `localStorage paperModeOverride_<sid>`
- Player paper : si déjà “paper registered”, ignore la majorité des WS sauf `update_session_infos`
- Bingo paper : auth `auth_player_paper`, quit via `player_quit`
- Templates : `quiz_support_paper.php`, `blindtest_support_paper.php`, `bingo_grids_paper.php`
- Grids bingo : via HTTP APIs côté `bingo_adapter_glue.php` (assign/sync)
- Quiz uniquement (bascule papier -> numérique):
  - autorisée uniquement avant démarrage de la session,
  - contrôle de conformité effectué sur toutes les questions de toutes les séries du quiz (pas uniquement la série courante),
  - hydratation organizer expose `digitalSwitchAllowed`, `digitalSwitchInvalidCount`, `digitalSwitchReason`, `digitalSwitchMessage`,
  - anti-bypass serveur au persist (`session_update`): transition `flag_controle_numerique 0 -> 1` revalidée côté DB, refusée avec `PAPER_TO_DIGITAL_BLOCKED_MISSING_PROPOSALS` si session démarrée (`reason=STARTED`) ou questions non “numérique-ready”.

## Contrôle offre active (organizer/master)
- Contrôle appliqué à l’accès organizer (`web/organizer_canvas.php`) dès l’hydratation session:
  - détection démo via `championnats_sessions.flag_session_demo` (et `serverSessionMeta.isDemo`),
  - session démo: bypass du contrôle offre,
  - session non-démo: offre active requise, sinon blocage 403 avec CTA offres.
- CTA offres:
  - URL finale forcée sur le domaine `pro` (`$CONF_PRO_URL`),
  - chemin contextuel `/extranet/ecommerce/offers/...` conservé si fourni par le guard,
  - fallback `/extranet/ecommerce/offers`.
- Logique de référence réutilisée côté app: `app_session_launch_guard_get(...)` (fallback local aligné si indisponible dans le contexte).
- Bridge Canvas (`web/games_ajax.php`):
  - depuis `2026-03-05`, plus de guard offre sur les writes (`session_update`, `prizes_save`, `resetdemo`),
  - raison: éviter les effets de bord runtime (persistance bloquée) sur sessions en cours,
  - politique retenue: contrôle d’offre centralisé au point d’entrée organizer (`web/organizer_canvas.php`).

---

## Script map 20/80 (why / risk / validate)
- `core/ws_connector.js` — **why**: transport WS unique / auth / queue / reconnect ; **risk**: plus de live, boucle reconnect ; **validate**: `ws/status`→open + messages passent + (std) heartbeat ~25s.
- `core/ws_effects.js` — **why**: router inbound WS→Bus + effets gameplay ; **risk**: commandes/états non répercutés ; **validate**: recevoir `gameOptionsUpdate` → `options/updated`.
- `play/play-ws.js` — **why**: auth/register player + réponses ; **risk**: player muet / answer jamais envoyée ; **validate**: `checkAnswer` → `game:ws:send`.
- `remote/remote-ws.js` — **why**: télécommande + mapping handlers ; **risk**: next/pause ignorés ; **validate**: action remote → état serveur revient.
- `core/session_persist.js` — **why**: push `session_update` ; **risk**: désynchro/persistance cassée ; **validate**: une action gameplay produit 1 write attendu.
- `web/games_ajax.php` — **why**: CORS/auth/idempotence/dispatch ; **risk**: 403, CORS, already_processed mal compris ; **validate**: POST avec/sans `event_id`.
- `php/*_adapter_glue.php` — **why**: accès DB par jeu ; **risk**: état/podium faux ; **validate**: preload session cohérent.
- `core/logger.global.js` — **why**: writer logs Bus→LogEntry ; **risk**: viewer illisible/silencieux ; **validate**: `game:ws:send` + `game:ws:message` loggués.

---

## Bus hooks for logging (liste courte)
Le writer central écoute typiquement :
- Transport : `ws/status`, `ws/open`, `ws/close`
- WS payloads : `game:ws:send`, `game:ws:message`
- HTTP : `api/call`, `api/ok`, `api/fail`
- Gameplay : `timer/*`, `support/*`, `session/*`, `player/*`, `remote/*`
Writer : `web/includes/canvas/core/logger.global.js`

---

## Interactions (vue rapide)
- Clients canvas ↔ WebSocket (transport unique géré par `web/includes/canvas/core/ws_connector.js`), routing inbound via `ws_effects.js`.
- HTTP bridge `web/games_ajax.php` reçoit les writes/reads Canvas et appelle les adapters PHP par jeu.
- Logs front centralisés via `web/includes/canvas/core/logger.global.js` (Bus-first).

## Actions clés (runbook court)
- Lancer front (serveur PHP) : vhost cible `games/web/` (cf. `games/web/config.php`).
- Tester bridge : POST sur `games/web/games_ajax.php?t=jeux&m=canvas` avec/ sans `event_id`.
- Ouvrir viewer logs front : `games/web/logs_session.html?sessionId=<sid>`.

## Variables d’environnement (bridge PHP)
| Key | Required | Used in | Note |
| --- | --- | --- | --- |
| `CANVAS_SERVICE_TOKEN` | Requis pour valider les appels inter-service signés | `games/web/games_ajax.php` | Comparé au header `HTTP_X_SERVICE_TOKEN` |

## Happy path (front/bridge)
1) Vhost pointe vers `games/web/` (config.php OK).
2) Token service présent dans l’env PHP (`CANVAS_SERVICE_TOKEN`) pour les appels WS→bridge signés.
3) Client front init WS via `ws_connector.js`, reçoit `state` (bingo) ou handshake std.
4) Actions mutatrices émettent writes HTTP via `games_ajax.php` avec `event_id` (client ou bridge compat).
5) Bridge accepte, insère dans `game_events` (idempotence) et renvoie payload JSON `ok:true`.
6) Logs viewer (`logs_session.html`) affiche les entrées `/logs` WS pour le `sessionId`.

## Bridge EP -> games
- `games/web/includes/canvas/php/ep_account_bridge.php`
  - pour `quiz`, le username injecté dans `games` reste le nom d'équipe;
  - pour `blindtest` / `bingo`, le bridge utilise désormais `equipes_joueurs.pseudo` si disponible, avec fallback sur `prenom`.
- `games/web/includes/canvas/php/boot_lib.php`
  - `participant_lookup` cote remote papier applique maintenant un filtre dur par organisateur a partir de la session courante (`championnats_sessions.id_client`);
  - `quiz` propose uniquement des equipes deja vues chez cet organisateur via `championnats_sessions_participations_probables`, `championnats_sessions_participations_games_connectees` et le legacy `equipes_to_championnats_sessions`;
  - `blindtest` / `bingo` proposent uniquement des joueurs deja lies au compte organisateur via `championnats_sessions_participations_probables`, `championnats_sessions_participations_games_connectees` et le legacy bingo `jeux_bingo_musical_grids_clients`.

## Scénarios d’échec
- Symptôme : 403 sur `games_ajax.php` lors d’un write WS — Cause : header `X_SERVICE_TOKEN` invalide vs `CANVAS_SERVICE_TOKEN` — Fix : aligner les secrets côté WS/PHP.
- Symptôme : pas de logs dans viewer — Cause : endpoint WS `/logs` ne renvoie rien (sid erroné ou pas de log) — Fix : vérifier sid, générer trafic, relire.
- Symptôme : déjà traité (`already_processed:true`) — Cause : même `event_id` réutilisé — Fix : générer un nouvel `event_id` côté appelant.

## Observability (viewer-first)
- Logs front : `games/web/logs_session.html` consomme `logs_proxy.php` → lit `/logs` du WS ciblé (JSONL).
- Chips viewer (`total/debug/info/warn/error`) : stats globales obtenues via `logs_proxy.php?stats=1&force=1` (recalcul forcé, sans cache) pour éviter les écarts temporaires après flush front; la chip `visibles` reste calculée localement sur les entrées chargées.
- WS debug côté front : hooks `logger.global.js` sur Bus (`ws/status`, `game:ws:send`, `game:ws:message`).
- HTTP bridge : réponses JSON explicites (`ok`, `error`, `already_processed`, `code`), CORS selon règles dans `games_ajax.php`.
- Flush front vers WS :
  - `LOG_FLUSH_TRIGGER` (debug) avec `source="viewer"` ou `source="session_end"` et meta `{sid, game, source, queued_count}`.
  - `LOG_FLUSH_TRY` (debug), `LOG_FLUSH_OK` (info), `LOG_FLUSH_FAIL` (warn).
  - Meta flush attendue: `{count, ws_ready_state, ws_url?}` (URL seulement si non sensible/disponible).
- Viewer “Forcer flush” :
  - `logs_session.html` écrit toujours `localStorage.LOG_FLUSH_REQUEST` pour réveiller un onglet local sur le même navigateur/origin.
  - le bouton appelle aussi `logs_proxy.php?action=force_flush`, qui relaie vers `/force_flush` sur quiz/blindtest/bingo pour un flush distant réel.
  - `logger.global.js` écoute l’événement `storage` sur `LOG_FLUSH_REQUEST` puis exécute `flushBufferToWS()`.
  - `logger.global.js` normalise chaque entrée avant envoi (`ensureEntrySourceTs`) : conservation de `entry.ts` si valide, fallback ISO sinon, et ajout systématique `meta.client_ts` + `meta.event_ts` (timestamps source d’émission front).
  - Le flush envoie `type:"log_batch"` sur la WS déjà ouverte de la session active.
  - Le même chemin émet aussi un flush auto à la fin de session (`gameStatus === "Partie terminée"`).
- Attendu côté WS ingest (`log_batch`/`log_event`) : ingestion visible dans les logs WS (ex: marqueur `LOG_BATCH_RX` si implémenté, ou entrées enrichies `meta.ingested_by`) puis entrées `src=GAMES` visibles dans `/logs` avec `msg` non vide et `meta` utile.
- Reveal player (quiz/blindtest) :
  - le reveal arrive via `answerReveal` (post-verrou / fin timer), avec payload `{correctOption, correctOptionKey?, currentSongIndex}`.
  - logs front debug associés : `PLAYER_REVEAL_RX` (`game,sid,itemIndex,has_correct_key,correctKey?`) puis `PLAYER_REVEAL_APPLY` (`found,method:key|legacy`).

## 2026-04-13 — Détection d'environnement WS

`games/web/config.php` ne doit pas limiter la détection `dev` au seul host `games.dev.cotton-quiz.com`, ni dépendre uniquement de `SERVER_NAME`. La règle utilise maintenant `HTTP_HOST` en priorité, avec fallback `SERVER_NAME`, et s'aligne sur `global` avec `*.dev.cotton-quiz.com`. Cela évite de basculer par erreur en `prod` sur d'autres sous-domaines dev ou derrière certains vhosts/proxies, et donc d'injecter les URLs WebSocket de production dans `AppConfig.wsUrl`.

En complément, `games/web/organizer_canvas.php` expose temporairement en `dev` un objet `window.__COTTON_WS_DEBUG__` dans la console navigateur. Il permet de comparer le host vu par PHP (`HTTP_HOST`, `SERVER_NAME`), l'environnement retenu (`conf.server`, `AppConfig.env`) et l'URL WS finalement injectée (`AppConfig.wsUrl`) pour distinguer un mauvais routage serveur d'un cache HTML stale.

Le diagnostic a mis en evidence un second point: `games/web/modules/app_orga_ajax.php` n'initialisait pas localement `$env`, contrairement aux variantes `play` et `remote`. Il héritait donc de la portée de `games_ajax.php`, où `$env` etait ensuite reaffecte via `$CONF_SERVER ?? 'prod'` alors que `$CONF_SERVER` n'etait pas defini. Organizer pouvait ainsi injecter une `wsUrl` de production alors meme que `conf.server === 'dev'` et que la matrice runtime des URLs WS etait correcte.

Le debug `window.__COTTON_WS_DEBUG__` a ensuite ete retire apres validation du correctif. Il ne faisait partie que de la phase de diagnostic et n'est pas conserve dans le rendu standard organizer.

## 2026-04-16 — Branding organizer: cadrage final reporte cote `global`

Le branding de session recadre toujours le visuel localement dans la modale organizer (`600x240` cover) pour l'apercu utilisateur. En revanche, la solution retenue n'est plus de fabriquer un derive HD dans `games`.

`session_modals.js` est revenu a un flux simple: le front affiche sa preview locale, mais renvoie de nouveau le fichier source brut au backend pour `branding_visuel`.

Le cadrage final du visuel branding est maintenant porte par `global`, qui ne rabaisse plus la cible serveur en fonction de la taille source. Le visuel uploadé conserve donc le ratio attendu du branding (`1600x640`, soit le meme ratio que `600x240`) sans dependre du derive front.
