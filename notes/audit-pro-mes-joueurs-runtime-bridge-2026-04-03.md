# Audit `Mes joueurs` / inscriptions runtime-EP / bridge games (2026-04-03)

Scope: audit + patchs fonctionnels sur `global` et `games`.

## Resume executif

Ce fil a couvert 3 sujets relies mais distincts:
- les classements saisonniers agreges `pro` / `play`;
- les inscriptions runtime / EP et leur impact sur les doublons;
- la persistance bridge `championnats_sessions_participations_games_connectees`.

Les causes racines identifiees:
- `Mes joueurs` pouvait exclure a tort des sessions passees si la lecture de terminaison dependait d'un etat runtime mutable ou d'un filtre `is_active` inapproprie pour de l'historique;
- les ajouts remote d'un participant deja connu en base pouvaient peupler seulement la table runtime du jeu sans ecrire la table bridge EP;
- les inscriptions EP re-creaient parfois une nouvelle ligne runtime faute d'identite stable reutilisee;
- la preparation `EP -> games` pouvait accumuler plusieurs lignes bridge pour une meme session et une meme identite EP;
- les doublons runtime etaient favorises par l'absence de garde sur le nom saisi en inscription libre.

## 1) Classements saisonniers agreges `pro` / `play`

### 1.1 Filtre `is_active`

Constat:
- dans le moteur global des classements agreges, plusieurs lectures runtime filtraient les `*_players` avec `is_active = 1`;
- pour une session terminee, les participants runtime passent ensuite inactifs;
- consequence: une session valide pouvait disparaitre des classements agreges, des tops et des compteurs.

Correctif applique:
- suppression du filtre `is_active` dans les lectures runtime du moteur agregateur `Mes joueurs` / `Mes classements`;
- le live n'est pas touche; seul le reporting historique est ajuste.

Impact attendu:
- les sessions terminees dont les participants runtime sont devenus inactifs remontent de nouveau dans les classements agreges.

### 1.2 `Mes joueurs` — synthese haute et sessions bingo

Constat:
- la synthese haute de `Mes joueurs` pouvait ignorer des sessions `Bingo Musical` pourtant passees;
- la cause venait du helper de terminaison du dashboard, qui s'appuyait indirectement sur l'etat courant mutable de `jeux_bingo_musical_playlists_clients.phase_courante`;
- une playlist bingo reutilisee ou reinitialisee pouvait donc faire "disparaitre" retroactivement des sessions anciennes des stats `Mes joueurs`.

Correctif applique:
- pour `bingo` (`id_type_produit = 3` et `6`), une session datee avant aujourd'hui est maintenant consideree comme historique/terminee pour le dashboard organisateur;
- le cache journalier de synthese `Mes joueurs` est versionne pour forcer le recalcul apres ce changement.

Impact attendu:
- les totaux `Sessions organisees`, `Participants inscrits` et `Top jeu` de `Mes joueurs` reintegrent les sessions bingo historiques.

## 2) Ajout remote d'un participant deja connu en base

Constat:
- l'ajout remote d'un joueur/equipe existant en DB mettait bien a jour la table runtime du jeu;
- mais ce flux n'alimentait pas automatiquement `championnats_sessions_participations_games_connectees`;
- consequence: historique EP, `Mes classements`, recherches futures de participants connus et certains recollages de donnees pouvaient diverger du runtime reel.

Correctif applique:
- si l'animateur ajoute depuis la remote un joueur ou une equipe provenant d'un lookup DB:
  - le front transmet `sessionId`, `participantType`, `sourceTable`, `sourceId`;
  - le backend ecrit ou met a jour la ligne bridge correspondante avec `game_player_id`, `game_player_key` et `date_consumed`;
- si l'animateur cree un participant runtime pur depuis la remote, aucun bridge n'est cree.

Regle conservee:
- uniquement les participants issus d'une identite DB connue sont relies a l'EP via la table bridge;
- les creations runtime pures restent confinees aux tables runtime du jeu.

## 3) Doublons runtime et garde sur le nom

### 3.1 Cas traite

Constat:
- un joueur/equipe runtime pouvait s'inscrire, se desinscrire puis se reinscrire avec le meme nom;
- comme la desinscription laissait une ligne runtime inactive, la reinscription recreait une nouvelle ligne et le classement final pouvait afficher un doublon.

Correctif applique:
- une inscription runtime pure est maintenant refusee si:
  - le nom existe deja dans la session, actif ou non;
  - ou si le nom correspond a un joueur / une equipe deja reference chez l'organisateur;
- les inscriptions via `ep_connect_token` et les ajouts remote issus d'un lookup DB bypassent ces controles.

Messages harmonises:
- `Ce nom est deja utilise dans cette session. Merci d'en choisir un autre.`
- `Ce nom n'est plus disponible. Merci d'en choisir un autre.`

### 3.2 Effet metier recherche

But:
- empecher les doublons runtime/runtime;
- empecher aussi qu'un participant runtime libre prenne le nom d'un participant EP connu chez cet organisateur;
- conserver en revanche les inscriptions EP officielles, meme si elles partagent un nom avec un runtime libre deja cree.

## 4) Reinscription EP et identite runtime stable

Constat:
- une inscription EP pouvait creer une nouvelle ligne runtime lors d'une reinscription, au lieu de reutiliser la precedente;
- cause: le `player_register` recevait encore une identite locale de session, pas toujours la cle EP stable resolue via `id_joueur` / `id_equipe`.

Correctif applique:
- `play/register` envoie maintenant aussi le payload source EP (`participantType`, `sourceTable`, `sourceId`);
- cote backend, quand `ep_connect_token` + source EP sont presents, la cle runtime est forcee vers une identite stable derivee de l'identite EP;
- une reinscription EP dans la meme session retombe donc sur la meme ligne runtime.

Impact attendu:
- un participant EP qui se desinscrit puis se reinscrit dans la meme session reactive la meme ligne runtime au lieu d'en creer une nouvelle.

## 5) Dedup de la preparation bridge `EP -> games`

Constat:
- plusieurs lignes bridge pouvaient etre creees pour la meme session et le meme joueur EP au fil des retours `EP -> games`;
- exemple observe: plusieurs lignes `play_ep_account` distinctes pointaient ensuite toutes vers le meme `game_player_id`.

Correctif applique:
- `app_joueur_games_bridge_prepare_return(...)` recherche maintenant une ligne existante pour la meme session, le meme jeu et la meme identite EP;
- si elle existe, son `return_token` est reutilise et son expiration est rafraichie;
- sinon une nouvelle ligne est creee.

Impact attendu:
- la table `championnats_sessions_participations_games_connectees` n'accumule plus plusieurs tickets de preparation pour une meme relation `session + identite EP + jeu`.

## 6) Point restant ouvert

Bug structurel encore a surveiller:
- les classements finaux runtime de session ne dedoublonnent pas encore nativement des rows historiques preexistantes dans les tables `*_players`;
- la prevention principale est maintenant faite a l'inscription par la garde sur le nom et la stabilisation des identites EP;
- si des doublons legacy persistent deja en base, ils peuvent encore ressortir dans certains classements finaux runtime de session.

## Fichiers de code touches sur ce fil

- `global/web/app/modules/entites/clients/app_clients_functions.php`
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `games/web/includes/canvas/php/boot_lib.php`
- `games/web/includes/canvas/php/ep_account_bridge.php`
- `games/web/includes/canvas/php/quiz_adapter_glue.php`
- `games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `games/web/includes/canvas/php/bingo_adapter_glue.php`
- `games/web/includes/canvas/play/register.js`
- `games/web/includes/canvas/remote/remote-ui.js`

## Verification technique realisee

- `php -l` sur les fichiers PHP modifies;
- verification SQL ponctuelle en prod sur:
  - `championnats_sessions`
  - `cotton_quiz_sessions`
  - `cotton_quiz_players`
  - `championnats_sessions_participations_games_connectees`
- verification DevTools sur le flux:
  - `ep_link_resolve`
  - `player_register`
  - `ep_link_finalize`

## Conseils de verification post-deploiement

- `pro > Mes joueurs`
  - verifier que les sessions bingo historiques reapparaissent bien dans la synthese haute;
- `play > Mes classements`
  - verifier qu'un participant ajoute via EP remonte bien dans son historique / rattachement;
- remote organizer
  - verifier qu'un participant lookup DB cree bien une ligne bridge `date_consumed` associee au runtime;
- re-inscription EP
  - verifier qu'une meme identite EP reutilise la meme row runtime au second passage;
- inscription runtime pure
  - verifier le refus si le nom existe deja dans la session ou chez l'organisateur.
