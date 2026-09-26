# Audit transversal des sessions papier et identités Remote — 21 septembre 2026

<!-- AUTO-UPDATE:BEGIN id="paper-session-participant-identity-audit-20260921" owner="codex" -->

> Note historique non canonique : audit figé du 21/09/2026, archivé ici à la demande de l’utilisateur. Les mentions « aucune documentation modifiée » décrivent la passe d’audit initiale. Le présent archivage documentaire est postérieur. Rapport, matrices et résultats sont conservés dans `notes/` ; sondes exécutables et copies applicatives restent dans `/tmp/cotton-paper-audit/`. Les commandes `/tmp` sont celles de la reproduction initiale, pas une installation autonome de cette note.

**Conclusion locale : le défaut Quiz n’est pas isolé. Blind Test possède le même défaut de résolution sur `admin_set_score`. La projection HTTP/WS du participant explique le caractère intermittent ; l’origine organisateur n’est pas une condition du défaut. Bingo utilise correctement la clé canonique dans le parcours actuel, mais son fallback WS numérique ne résout pas le roster papier sans socket.**

Aucun patch, fichier applicatif ou document du dépôt modifié par cet audit. Aucun SSH, accès DB réelle, DEV/PROD applicatif, navigateur, déploiement ou restart. Seules les lectures documentaires HTTP demandées et les exécutions locales isolées ont été effectuées. Les fichiers sous `/tmp/cotton-paper-audit/` sont des artefacts d’audit, pas une mise à jour de la documentation canonique.

La reprise du 21 septembre a révélé de nouveaux changements locaux de capacité/inscription. Les sondes ont été reconstruites et exécutées sur cet état, avec les vrais helpers de capacité. Les résultats du 18 septembre ne sont pas présentés comme une validation de l’état courant. Des modifications concurrentes supplémentaires ont été détectées : les 52 fichiers de preuve ont été figés le 2026-09-21T07:23:09.228058+00:00 dans `source-snapshot/`, puis les cinq sondes relancées avec succès sur cette copie. Les conclusions concernent ces empreintes ; elles ne certifient pas les modifications ultérieures du workspace. L’index de preuves pointe vers la copie figée.

## A. Discipline et périmètre de preuve

Lectures obligatoires réalisées : [START RAW][start], sections « Statut actuel », « Règle preuve d’abord » et « Discipline de génération » ; [SITEMAP.txt RAW][sitemap], rubriques Repos/Global specs ; [Manifest RAW][manifest], « Update triggers », « Routing rules », « Server restart markers » ; README général et HANDOFF. Les mêmes chemins des six cartes repo et des deux contrats ont été récupérés sur `main` et `develop`. Comparaison détaillée en annexe.

Journal [AI Studio][roadmap] récupéré et Markdown du champ `const raw` décodé sans exécuter le JavaScript de la page. Sections « EN COURS » et « Fait, livré en PROD » : changements WWW marketing, `.htaccess`, pages Features/portails, contenus AI Studio, ecommerce et `global/global_librairies.php`. **Aucun fichier de moteur/Remote/roster ciblé n’y est signalé comme modifié hors workspace.** Cela ne prouve pas l’égalité serveur/local. Le pied de page du journal reste daté du 28/08 malgré des entrées de septembre.

Chemins à recharger si l’audit est étendu à ces zones : `global/global_librairies.php`, `www_202606/.htaccess`, `www_202606/fo/modules/communication/statique/fr/`, `www_202606/fo/fo_sitemap.php`, les pages WWW de portails jeux et les dossiers AI Studio cités par le journal. Ils ne sont pas audités à partir de leur copie locale dans ce rapport. Aucun rapatriement serveur d’un moteur n’est imposé par une alerte ciblée de ce journal.

Les branches applicatives sont `hub_soiree`; les HEAD, états Git et empreintes des fichiers inspectés sont joints. Des modifications applicatives préexistantes sont présentes. L’audit ne conclut **pas** à l’état du code servi en production. Les défauts précis ci-dessous sont **non trouvés dans la documentation** consultée, sauf les contrats explicitement cités et le signalement distinct des inscriptions papier tardives.

## B. Jeux papier réellement présents

| Moteur | Papier exploitable dans le code local | Preuve |
|---|---|---|
| Quiz | Oui | Remote `isPaperQuizOrBT`, correction papier et `finalizePaperScores`; adapter Quiz ; [doc Quiz][quizdoc], « Update 2026-07-15 — Finalisation papier et fin naturelle Hub » |
| Bingo | Oui | `handlePhaseWin`, correction grille/ligne/carton, `admin_phase_winner`; [doc Bingo][bingodoc], « Update 2026-06-12 — Remote papier phase winner HTTP-first » |
| Blind Test | Oui | Même surface papier Quiz/BT ; `blindtest_api_update_score`, `finalizePaperScores`; [doc Blind Test][btdoc], « Update 2026-06-12 — Remote papier score fiable » et finalisation papier |

Blind Test reste dans la matrice. Son mode équipe WS est désactivé par `blindtest/web/server/features.js` (`BLINDTEST_TEAMS_ENABLED=false`), ce qui ne supprime pas son mode papier individuel. Les réponses numériques `checkAnswer` et les mutations d’équipe ne sont pas extrapolées au papier.

## C. Provenances séparées

| Provenance | Création/entrée observée | Point de convergence et nuance |
|---|---|---|
| QR joueur / Hub Play | `app_games_hub_player_register_guest_from_play`, ou `app_games_hub_player_register_ep` | Identité Hub ; sur focus papier, `app_hub_player_resolve_session_access` assure une participation persistée. Pas de redirection vers `/play` numérique. |
| Hub Remote organisateur | `games_hub_remote_handle_paper_lobby_player_add` → `app_games_hub_player_ensure` | Ajout au roster Hub uniquement ; pas de participation ni mapping de session immédiatement. |
| Remote session organisateur | `handleAddPlayerLive` → HTTP `player_register`, puis WS `admin_player_register` si `registration_state != already_active` | Participation moteur, bridge Hub et inscription mémoire séparés. L’HTTP peut réussir avant le WS. |
| Injection Hub au lancement | `app_games_hub_session_inject_active_players` | Sélection de tous les joueurs Hub `active`, puis ensure papier, ID moteur et mapping vérifiés. |
| Existant retrouvé | `canvas_api_participant_lookup`, `buildParticipantChoiceFromLookup` | Identité déterministe à partir de `sourceTable/sourceId`, non à partir de l’ID Hub ou moteur. |
| Saisie libre / invité | Hub : génération de token ; Remote session : `getOrCreateRemotePlayerId` | UUID `p:…` ; cache Remote par jeu/contexte/nom normalisé pour les retries. Le nom n’est pas la clé runtime. |
| Équipe historique / wording | Recherche Quiz dans `equipes`; Hub global peut réunir joueurs et équipes | Clé stable `team:<sourceId>` transformée en `p:UUID`; un participant runtime, pas ouverture du chantier équipes. Dans le Hub, cette référence peut être portée comme invité avec token canonique. |
| Restauré / repris | `hydratePlayersFromDB` et maintien du runtime vivant | Restauration depuis `player_id` moteur ; ID DB séparé. Reprise vivante ne crée normalement pas une nouvelle identité. |
| Entrée directe WS héritée | `registerPlayer` ou Bingo `auth_player_paper` | Cas distinct du QR Hub papier, utile pour éprouver les compatibilités et la présence d’une socket. |
| Ligne ancienne sans clé canonique | Helpers legacy/adoption papier | Hors contrat nominal ; Quiz/BT hydratent une chaîne non vide, Bingo exige un `p:UUID` valide. |

Contrats : [Global][globaldoc], « Etat 2026-07-13 — Games hubs participation papier persistante », « Etat 2026-07-15 — Continuité des identités Remote papier dans le Hub », « Update 2026-08-31 — Launch Hub papier: bootstrap avant engagement du focus » ; [Games][gamesdoc], « Ajout anticipé des joueurs papier — 17/09/2026 ». L’ancienne section Global du 12/07 excluant l’ensure papier est contredite par les sections postérieures et le code : elle ne doit pas être prise pour le contrat actuel.

## D. Cartographie des namespaces

Notations : **H** = `games_hubs_players.id`; **M** = `games_hubs_players_sessions.id`; **D** = ID DB moteur ; **K** = clé `p:UUID`; **E** = compte `equipes_joueurs.id`; **T** = équipe `equipes.id`. Aucun de H/M/E/T ne doit être utilisé comme D ni comme K.

| Moteur | D / participation moteur | Session SQL moteur | Identité runtime nominale |
|---|---|---|---|
| Quiz | `cotton_quiz_players.id` | `cotton_quiz_sessions.id`, distinct du token de session | `session.players[].playerId = K`; `playerDbId = D` |
| Blind Test | `blindtest_players.id` | `blindtest_sessions.id`, distinct du token de session | `session.players[].playerId = K`; `playerDbId = D` |
| Bingo | `bingo_players.id` | `bingo_players.session_id` utilise le token ; Maps moteur groupées par `idPlaylistClient` | `player_id = K`; `player_db_id`/`playerId` numérique secondaire ; snapshot dédupliqué par `pid:K` |

Pour chacun des trois moteurs :

| Origine | ID créé Global/Hub | ID persisté moteur | Clé runtime | ID envoyé à la Remote | ID attendu par l’action live |
|---|---|---|---|---|---|
| QR Hub invité | H, token invité K ; M à l’ensure | D avec `player_id=K` | K après hydratation/bind | HTTP : K et D | K |
| QR Hub connecté EP | H, E, identité `ep:E`, token Hub parfois `ep_E`; M à l’ensure | D avec K déterministe de E | K | HTTP : K et D | K |
| Ajout Hub Remote | H ; K disponible/dérivable, M absent initialement | Aucun D avant ensure/injection | Aucune entrée avant injection/bind | Lobby : `id=H`; ensuite projection moteur K/D | Lobby undo : H ; action moteur : K |
| Ajout Remote session | H/M via bridge si session rattachée au Hub | D avec K renvoyés par HTTP | K via `admin_player_register` | HTTP K/D, puis WS propre au moteur | K |
| Injection lancement | H existant ; M créé/enrichi | D retourné et vérifié | K au chargement WS | HTTP K/D, puis WS | K |
| Existant compte/équipe | E ou T conservé en `sourceId`; H/M selon parcours | D ; K déterministe `player:E` ou `team:T` | K | Lookup `id=player:E`/`team:T`, puis K/D moteur | K, jamais `sourceId` |
| Saisie libre | H éventuel, token K ; cache Remote local éventuel | D + K | K | K/D | K |
| Restauré/repris | H/M existants | D existant ; pas de nouvel ID requis | K conservé/relu | K/D selon HTTP/WS | K |

Les trois déclinaisons moteur de cette matrice sont aussi livrées dans `identity-matrix.csv`.

Changement de namespace critique : **le champ JS `playerId` vaut D dans `players_get`, mais K dans `updatePlayers` Quiz/Blind Test**. Le champ `id` du lobby Hub vaut H. L’ID de résultat lookup est préfixé `team:`/`player:`. Les tokens de session, de retour EP et de reprise identifient des contextes/autorisations, pas le participant runtime.

## E. Identité canonique et fonctions

| Moteur | Création / restauration | Résolution et sérialisation | Résolution inverse |
|---|---|---|---|
| Quiz | `registration.js:448 registerPlayer`, `:691 hydratePlayersFromDB` | `normalizeRegisterIds`; `gameplay.js:1032 updatePlayerListNow` sérialise `playerId=K` sans D | `quiz_api_update_score` privilégie `player_id=K`; `adminSetScore` ne traduit pas D vers K |
| Blind Test | `registration.js:448 registerPlayer`, `:696 hydratePlayersFromDB` | `normalizeRegisterIds`; `gameplay.js:1246 updatePlayerListNow` (individuel) | `blindtest_api_update_score` privilégie K ; même défaut `adminSetScore` |
| Bingo | `performBingoAuthentication`, branche `admin_player_register`, `hydratePlayersFromDB` | `getPlayersSnapshot` garde K et D ; `resolvePlayerScopeForGame` | HTTP `_bingo_resolve_identity` résout K ou D dans la session ; WS ne recherche D que dans les joueurs connectés |

Construction globale : `boot_lib.php:979 canvas_build_stable_participant_key(kind, sourceId)` produit un UUID déterministe préfixé `p:`. `app_games_hub_session_player_key` choisit clé EP stable, token invité canonique, sinon UUID dérivé de l’ID Hub. Ces fonctions réelles sont sondées : un même compte EP retrouvé et QR donne la même K ; `team:777` et `player:777` donnent des K différentes.

**Convergence nominale oui, universalité historique non.** Le schéma autorise un `participant_key` vide ; les helpers PHP legacy peuvent accepter/générer une clé `legacy:…`. Les inscriptions WS Quiz/BT exigent `p:UUID`, alors que leur hydratation vérifie surtout la non-vacuité. Bingo filtre les lignes sans UUID canonique ou sans D positif. Ne pas promettre que toutes les lignes historiques convergent sans inspection des données.

Preuve documentaire : [Quiz][quizdoc] et [Blind Test][btdoc], contrat Player/« Admin papier » ; [Bingo][bingodoc], « Identité joueur Bingo (canon) » et hydratation.

## F. Défaut Quiz `adminSetScore`, chaîne exacte

Exemple synthétique : D=201, K=`p:00000000-0000-4000-8000-000000000001`.

1. `quiz_api_players_get` renvoie `{playerId:201,id:201,player_id:K}`.
2. `remote-ui.js:2029 applyScoreUpdate` extrait correctement K **et** D.
3. HTTP `update_score` transporte `{sessionPrimaryId:99,player_id:K,playerId:201,score:7,...}`. `quiz_api_update_score` choisit K si fournie ; sinon D. L’ACK peut donc être valide sans aucune résolution WS.
4. Le même code UI envoie `{type:'admin_set_score',sessionId:'s',player_id:K,playerId:201,score:7,persisted:true,...}`.
5. `wsHandler.js` relaie l’objet à `gameplay.js:1411 adminSetScore`.
6. Le handler calcule `data.playerId ?? data.player_id` : **201 gagne sur K**. Il cherche ensuite `String(player.playerId ?? player.id) === '201'`, alors que `player.playerId=K` et `player.playerDbId=201`.
7. Le participant n’est pas trouvé ; pas de mutation ni broadcast du score. Le handler journalise l’échec mais ne renvoie pas à l’UI un ACK d’échec corrélé. L’UI avait déjà reçu l’ACK HTTP et affiche son succès.

Pourquoi certains participants fonctionnent : après une projection WS complète, l’UI peut ne conserver que `playerId=K`, sans D. Elle envoie alors K dans les deux champs et la comparaison réussit. Après le polling HTTP (toutes les 2,5 secondes), D revient. Un snapshot WS partiel peut fusionner l’ancien `id=D` et le nouveau `playerId=K` : `getNumericPlayerId` retrouve encore D. Les vrais helpers UI et le vrai reducer reproduisent ces deux cas.

Ce n’est donc pas une preuve de « mauvais ID créé par l’organisateur ». C’est une priorité de champ incompatible avec les deux serializers. **Défaut précis : non trouvé dans la documentation** ; [Actions][actions], « Coverage matrix », documente en revanche HTTP avant WS.

## G. Inventaire des actions participant-scoped

Dans cette table, « pas de mismatch observé » porte sur le namespace, pas sur une garantie universelle des permissions/DB/réseau.

| Jeu | Action | Surface | ID transporté | Résolveur serveur | Clé attendue | Risque |
|---|---|---|---|---|---|---|
| Tous | Recherche existant `participant_lookup` | Hub Remote / Remote session | Contexte session + requête ; résultat typé source + K | `canvas_api_participant_lookup` | E/T typés, puis K | Pas de confusion `id` prouvée |
| Tous | Ajouter/invité/réactiver roster | Hub Remote | K, `sourceTable/sourceId`, pseudo | `app_games_hub_player_ensure` → upsert | Identité Hub `ep:E` / `guest:K` | Pas de conversion D/K ici ; admission capacité peut refuser |
| Tous | Retirer l’ajout courant | Hub Remote | `player_id=H`, undo token + ouverture | `app_games_hub_player_unregister`, borné au Hub | H | Nom de champ ambigu, mais consommateur cohérent ; pas suppression runtime |
| Tous | Liste participants lobby | Hub Remote | Retour `{id:H,pseudo,auth_type,last_seen_at}` | `games_hub_remote_paper_player_public` | H | Clé moteur volontairement absente ; pas utilisée pour corriger un score |
| Tous | Inscription moteur / réactivation | Remote session HTTP | K, source typée, session | `*_api_player_register` + admission/bridge | K ; D renvoyé séparément | HTTP et bind WS peuvent diverger ; `already_active` n’envoie pas de bind |
| Quiz/BT | `admin_player_register` | Remote session WS | `player_id=K`, `playerId=D` | `normalizeRegisterIds` → `registerPlayer` | K | Les deux namespaces sont correctement séparés ; garde active_keys actuelle |
| Bingo | `admin_player_register` | Remote session WS | K/D + token | Branche de `handleRemoteMessage`, relit `bingo_players` actifs | K avec D secondaire | Pas de `adminSetScore` équivalent ; réhydratation DB du roster |
| Tous | `players_get` | Remote session HTTP | Session | `*_api_players_get` | Retour K et D | Source du modèle numérique qui expose le défaut Quiz/BT |
| Quiz/BT | Score total / saisie rapide / appliquer correction | Remote session | HTTP puis WS K+D | `*_api_update_score`, puis `adminSetScore` | K live | **Vulnérable** D prioritaire ; même chemin pour les différentes commandes UI |
| Quiz/BT | Bon/mauvais verdict par item | Remote session | Clé stable dans état local `setVerdict` | Aucun handler réponse papier distinct ; `handleReviewApply` agrège puis score | K côté UI | Local jusqu’à « appliquer » ; hérite ensuite du défaut score |
| Quiz/BT | Ajouter/retirer points, bonus/malus | Remote session | Pas de commande dédiée trouvée ; édition du total disponible | Même chemin score | K | Baisse également empêchée par SQL `GREATEST` |
| Bingo | Déclarer gagnant ligne/double/carton | Remote session, automatique ou manuel avec joueur | K+D, phase, event_id ; HTTP puis WS | `_bingo_resolve_identity` puis `resolvePlayerScopeForGame` | K | OK contrat actuel ; fallback D seul incomplet sans socket |
| Bingo | Grille : vérifier ligne/carton | Remote session | Numéro grille + lignes ; joueur sélectionné facultatif | `grid_lines`, contrôle des positions jouées UI, puis phase winner/fail | Numéro grille pour vérification ; K pour gagnant | Deux namespaces distincts, pas d’assimilation grille/participant trouvée |
| Bingo | Déclarer échec `admin_phase_fail` | Remote session | Phase, grille/nom éventuels | `handleRemoteMessage` | Aucune recherche joueur | Notification seulement, ne retire pas un gain persisté |
| Bingo | Victoire manuelle sans participant | Remote session | Phase, aucune identité | `advancePhaseWithoutWinner` | Aucune | Fonction prévue ; ne doit pas absorber silencieusement une identité fournie mais introuvable |
| Quiz/BT | Valider résultats `paper_finalize_end` | Remote session | Session/event, pas D participant | `finalizePaperScores` → `endGame` → `persistPodium` | K des entrées mémoire | **Podium obsolète possible**, conséquence reproduite du score non appliqué |
| Tous | Classement/podium | Remote session / projections Hub | Liste runtime ou données persistées/mapping | serializers moteur ; `app_games_hub_players_stats_runtime_key_candidates` | K et D explicitement séparés en stats | Peut refléter la divergence amont ; pas de nouveau mélange démontré |
| Tous | Ajouter/modifier photo podium | Remote session fin | Session, rang, `photo_row_key` si connue | `canvas_api_session_podium_photo_upload` → service résultats | Clé de ligne podium, pas playerId live | Pas de mutation runtime ; fallback UI par label/score/rang à distinguer d’une identité canonique |

Exclusion/absence/rename/suppression d’un participant moteur, annulation d’un gagnant Bingo et édition serveur d’une réponse papier : **aucune commande exposée trouvée dans les deux surfaces examinées**. `deactivate_player` existe en API/cleanup de sortie joueur, mais n’est pas appelé par ces modules Remote. `checkAnswer` est une action Player numérique ; les commandes d’équipe BT sont en stand-by. `scores_editing` signale un état d’édition collectif, sans participant cible.

Sources documentaires : [Actions][actions], rubriques Bingo/Blindtest/Quiz, « API callers », « Coverage matrix » et « WS inventory ». Le détail de ces défauts et l’absence des commandes non trouvées sont des résultats de lecture du code, **non trouvés dans la documentation** comme inventaire exhaustif des surfaces papier.

## H. Hub Remote versus Remote session

Hub Remote appelle ses handlers PHP Games, puis Global pour créer/retrouver/retirer du roster. Sa projection affiche H. Pour piloter le runtime actif, son routage fait `window.location.replace(remoteUrl)` vers la Remote session : ce n’est pas un relais d’un objet participant H vers un WS de score.

Remote session reconstruit sa liste depuis preload/HTTP/WS, puis appelle Canvas et WS. Les ouvertures directes et celles issues du Hub arrivent donc au même `remote-ui.js` de correction.

Localisation du défaut Quiz/BT : création **non incriminée** pour K nominale ; projection moteur HTTP/WS **hétérogène** ; passage Hub→Remote **pas de payload joueur relayé identifié** ; construction WS **conserve K mais transporte aussi D dans `playerId`** ; dispatcher **transmet sans traduction** ; resolver **choisit D et ne consulte pas `playerDbId`**. Il faut corriger le contrat de transport et la résolution, pas transformer arbitrairement les IDs Hub.

Doc : [Global][globaldoc], sections de routage Remote et continuité papier ; [Games][gamesdoc], ajout anticipé et Remote Hub.

## I. Hypothèse « ajout organisateur »

**Non confirmée comme cause spécifique.** Pour Quiz/BT, les mêmes K/D donnent les mêmes résultats dans les sept fixtures d’origine. Le facteur déterminant est la dernière projection UI, puis l’existence du participant en mémoire. Les ajouts Remote session déclenchent immédiatement `fetchPlayersSnapshot`, et les résultats lookup peuvent être seedés avec D : ils sont exposés rapidement, mais le polling papier expose aussi les QR.

Pour Bingo legacy, le discriminant est **la présence dans `this.players` connecté**, pas l’origine. Le QR Hub papier reste normalement sur le Hub ; il ne faut donc pas assimiler tous les QR à un `auth_player_paper` avec socket moteur. Nos fixtures distinguent `QR_HUB` et `QR_DIRECT_WS`.

Verdicts des chemins testés : score avec projection HTTP → échec pour QR/organisateur/libre/existant/restauré ; projection WS canonique → succès. Verdict global par action score : `MIXED`, et non `FAIL_ORGANIZER_ADDED` exclusif. Aucun taux d’incidence par provenance n’a été mesuré en environnement réel.

## J. Mapping Hub / moteur / mémoire

1. `participant_key` **n’est pas garanti rempli par le schéma** : défaut SQL chaîne vide. La création Hub Remote ne crée même pas encore de mapping M.
2. La K est générée/dérivable dès l’identité Hub ; le mapping K+D devient prouvé après `player_register` et validation de la réponse dans `app_games_hub_session_participation_ensure`.
3. Ajout organisateur Hub : H immédiatement ; K interne/dérivable ; aucun D garanti. Ajout Remote session : D+K via HTTP, H/M via bridge si contexte Hub valide.
4. Injection : vérifie D>0 et égalité stricte de la K renvoyée avant de marquer M actif. Le compteur `failed_count` conserve les échecs individuels.
5. Remote peut conserver D après une fusion WS partielle ; ce n’est pas nécessairement un ancien H. Les deux cas sont différents. Le lobby Hub n’envoie pas son H au handler score.
6. Remote session **ne contourne pas systématiquement** le Hub : les trois adaptateurs appellent `app_games_hub_session_register_bridge`. Le bridge peut être indisponible/échouer/être explicitement sauté, et le succès moteur ne garantit pas à lui seul `hub_bridge.linked`.
7. Réactivation : upsert par identité existante ; les ensures peuvent réconcilier K/D. Un statut Hub `left` et un mapping session `left` ont des significations distinctes. Le patch de capacité présent le 21/09 refuse les clés non actives et admet explicitement les anciennes clés trouvées dans les mappings des membres Hub actifs.

`canvas_hub_capacity_context(..., true)` ajoute aux `active_keys` les K calculées du roster et les `participant_key` des mappings de la session. Quiz/BT `hubCapacity.allowsPlayer` et Bingo `hub_capacity.applyCapacity` utilisent ces chaînes ; ce sont des gardes d’admission, pas un resolver D→K pour les actions de score. La copie finale inclut aussi `active_identities` (K→H), utilisé pour compter une seule identité Hub malgré plusieurs anciennes clés ; cette déduplication de capacité ne modifie pas `adminSetScore` ni le resolver gagnant Bingo.

## K. Recherche et sélection

`canvas_api_participant_lookup` retourne `id='team:T'` avec `sourceTable='equipes'`, ou `id='player:E'` avec `sourceTable='equipes_joueurs'`; chaque objet porte aussi `player_id=K`. L’historique délimite les entités éligibles ; il ne transforme pas le résultat en ID moteur générique.

`buildParticipantChoiceFromLookup` extrait username, K, participantType, sourceTable, sourceId ; il **n’envoie pas le champ générique `id`**. Hub Remote fait également transiter K/sourceTable/sourceId. Le helper et la sélection réelle sont sondés. La piste « sélection d’un résultat hétérogène puis utilisation aveugle de son id » n’est pas confirmée sur ces parcours.

Saisie libre, invité et résultat historique sont des parcours distincts. Un pseudo sert à l’affichage, au cache de retry ou à une adoption historique contrôlée côté serveur ; l’adoption ne doit pas être confondue avec une résolution live par pseudo.

## L. Modèles JS et pertes de champs

| Surface/projection | Modèle utile | Conversion observée |
|---|---|---|
| Lobby Hub | `{id:H,pseudo,auth_type,last_seen_at}` | Réduction volontaire sans K ; `Number(data-player-id)` pour undo Hub |
| Lookup | `id` préfixé, K, sourceTable, sourceId, participantType | sourceId casté en nombre, K préservée |
| HTTP moteur | `{playerId:D,id:D,player_id:K,...}` | D entier ; K séparée |
| WS Quiz/BT individuel | `{playerId:K,playerName,playerScore,...}` | D non sérialisé dans `updatePlayers` |
| WS Bingo snapshot | `{player_id:K,playerId:D,player_db_id:D,...}` | Namespaces séparés |
| Seed ajout référencé | K avec `playerId`, `playerDbId`, `id` numériques | Rend le défaut score accessible avant le polling suivant |
| Classement rendu | `{id:stableId,name,score,rank,...}` | Réduction pour DOM ; l’action retrouve ensuite l’objet dans `playersLast` |

`getCanonicalPlayerId` lit `player_id`, puis un `playerId` reconnu comme `p:UUID`. `getNumericPlayerId` choisit `playerDbId ?? player_db_id ?? player_id_num ?? id ?? id_player ?? playerId`, puis convertit avec `Number` et `Math.floor`. Ce fallback retrouve D même si un WS partiel vient de remplacer `playerId` par K.

Aucune suppression textuelle de `p:` démontrée dans le chemin de correction. `participant_key`/`runtime_id` ne constituent pas aujourd’hui un champ universel du modèle Remote. Les champs `teamId/isTeam` concernent l’affichage équipe BT conditionnel ; ils ne justifient aucune normalisation générale de `id`.

## M. Résolveurs serveur

Quiz/BT n’ont pas de resolver participant partagé entre inscription, score admin, réponses, sortie et hydratation. L’inscription sépare K/D via `normalizeRegisterIds`; l’hydratation construit `playerId=K/playerDbId=D`; `persistScore` connaît les deux. `adminSetScore` utilise une recherche directe et une priorité inverse. C’est la rupture démontrée.

Bingo a `resolveCanonicalPlayerId`, `resolvePlayerScopeForGame` côté WS, et `_bingo_resolve_identity` côté PHP. La résolution PHP de D est scoped par session et relit K. La résolution WS de D parcourt seulement `players.getPlaylistPlayers(gameID)`, **sans `paperPlayersByGame`**. Dans la branche `admin_phase_winner`, l’absence de K bascule dans `advancePhaseWithoutWinner`, même si D était fourni ou qu’un ACK HTTP avait déjà été reçu.

La validation K n’est pas uniformisée : Hub PHP accepte plus largement `p:[A-Za-z0-9:_-]+`; l’inscription WS exige un UUID. Aucun parcours nominal générateur inspecté ne fabrique volontairement une clé incompatible ; la compatibilité des données anciennes reste un sujet séparé.

## N. Persistance versus runtime

| Divergence | Preuve | Effet |
|---|---|---|
| HTTP score réussi, runtime inchangé | Quiz/BT : vrais payloads UI et `adminSetScore`, 14 cas HTTP sur 7 origines | Score live faux/ancien, pas seulement affichage Remote |
| Baisse acceptée UI/live, DB reste au maximum | Quiz/BT `*_api_update_score` utilise `GREATEST`; `currentScore` peut rester 10 pour demande 3 | Le handler ignore `currentScore` et affecte `score`; divergence indépendante du namespace |
| Score runtime corrigé, fallback persistance échoue | `adminSetScore` affecte/broadcast avant `persistScore`; catch journalise sans rollback | Possible par panne API ; branche lue, panne non injectée dans cette campagne |
| Inscription HTTP réussie, bind mémoire absent | HTTP avant WS ; WS sauté pour `already_active`, ou refusé par admission/transport | Participant visible dans polling Remote mais absent du roster mémoire possible |
| K correcte mais joueur mémoire absent | Fixture tardive sans entrée : le vrai `adminSetScore` ne crée/réhydrate pas le joueur | Corriger la priorité des champs ne suffit pas pour ce cas |
| Podium dérivé d’un score mémoire ancien | Vrai `finalizePaperScores` après échec D/K, deux moteurs | Le payload `updateSession` porte encore l’ancien score podium |
| Bingo D-only sans socket | Vrai `handleRemoteMessage` après hydratation papier | Avance sans gagnant ; ACK HTTP et broadcast peuvent emprunter des chemins divergents |

Le HANDOFF RAW actuel, section « Diagnostic — 19/09/2026 — Échec test Bingo Hub 329 », signale aussi un **incident distinct** d’inscriptions papier tardives Blind Test absentes du roster Master vivant. Ce signalement n’est pas utilisé comme preuve d’un bug de namespace ni comme recette effectuée par cet audit. Le chemin Hub papier persiste la participation sans rediriger vers le Player numérique ; une présence DB ne prouve pas une entrée mémoire WS.

Pour la baisse de score, la sonde PHP exécute le vrai handler avec PDO factice et émule `GREATEST`; elle ne constitue pas un test de moteur SQL réel. La requête réellement émise est la preuve de la sémantique monotone.

## O. Reprises et identité

Quiz et Blind Test : trois scénarios chacun exécutent les vrais modules d’inscription/reconnexion, déconnexion dans la grâce et suspension/reprise, avec temps et API simulés. Même objet participant, même K et même D conservés ; la correction D+K continue d’échouer après chaque reprise.

Bingo : vrais `handleDisconnection`, `restoreHubRuntime`, lifecycle et `hydratePlayersFromDB`, stockage/horloge simulés. Les trois scénarios conservent K/D ; le roster vivant est conservé et la réhydratation relit la même K. Le handshake complet d’authentification, les sockets réseau et les courses de production ne sont pas simulés intégralement par cette sonde.

Pas de rotation normale d’identité démontrée après reprise. Pas de garantie sur des lignes DB anciennes/incomplètes ni sur une modification externe du mapping. `Math.max` lors de l’hydratation Quiz/BT peut conserver un score mémoire supérieur, sujet score distinct de l’identité.

Doc : [Quiz][quizdoc], [Blind Test][btdoc] et [Bingo][bingodoc], sections « Suspension officielle Hub »/reprise ; [Actions][actions], « Suspension Hub officielle ».

## P. Sondes, vérification et limites

Commandes reproductibles :

```bash
node /tmp/cotton-paper-audit/probe.cjs
node /tmp/cotton-paper-audit/probe-bingo.cjs
node /tmp/cotton-paper-audit/probe-ui.cjs
php /tmp/cotton-paper-audit/probe-http.php
php /tmp/cotton-paper-audit/probe-keys.php
```

Résultats : 28 cas de score Quiz/BT (14 échecs de mutation live avec projection HTTP, 14 succès avec projection WS), 14 cas Bingo winner/fail (6 fallbacks legacy sans socket), 9 scénarios d’identité après reprise, 2 finalisations obsolètes reproduites, 2 absences de participant mémoire testées, 2 modèles de fusion UI et 5 constructions de clés Hub. Les tests assertent les défauts observés : une sortie 0 signifie « reproduction conforme », pas « application corrigée ».

Les traces `results.json` et `bingo-results.json` portent `origin`, `hub_player_id`, `mapping_id`, `participation_id`, `participant_key`, `engine_db_id`, `runtime_key`, `remote_payload_id`, `resolved_runtime_key`, `action_result`. Les IDs sont synthétiques ; `null` signifie donnée non construite dans la fixture, pas absence prouvée dans une vraie session.

Suites existantes exécutées avec succès : `hub_paper_preparation_test.php` (75 checks, stockage factice), `hub_player_roster_registration_state_test.php`, `hub_paper_cold_runtime_bootstrap_contract_test.php`, `bingo_paper_correction_test.mjs`, `hub_capacity_runtime_test.cjs`. Ces cinq suites ont été relancées sur le workspace à la clôture ; elles complètent les cinq sondes exécutées sur la copie figée. Les deux suites Global sont des vérifications de contrat source, pas des intégrations DB.

**Limites de couverture explicites :** les sept origines de la sonde moteur sont des fixtures issues des formes établies dans le code. Ce ne sont pas sept parcours complets QR/Hub/HTTP/WS exécutés avec la vraie DB. Les transitions Hub sont couvertes par code et tests de handlers à stockage simulé ; les inscriptions PHP de chaque moteur et les uploads photo ne sont pas tous exécutés de bout en bout. Les mutations réseau, l’idempotence DB réelle et les migrations historiques ne sont pas validées. Les commandes non exposées ne sont pas artificiellement créées pour remplir la matrice. Aucun SQL utilisateur n’est nécessaire pour établir les défauts locaux ; une mesure d’incidence réelle demanderait une collecte séparée autorisée.

## Q. Matrices finales

Les codes demandés sont utilisés pour le résultat combiné des projections. Une action absente, un test non exécuté ou un refus métier attendu n’est pas transformé en `OK_ALL_ORIGINS`.

| Jeu | Origine | Action | ID Remote | ID runtime | Résolution | Verdict |
|---|---|---|---|---|---|---|
| Quiz | QR Hub, Hub Remote, Remote session, libre, existant, restauré | Score/correction appliquée | HTTP→WS D + K | K | Échec D prioritaire ; succès sur projection WS sans D | `MIXED` |
| Blind Test | Mêmes origines | Score/correction appliquée | HTTP→WS D + K | K | Même échec/succès | `MIXED` |
| Quiz/BT | Toutes origines présentes en mémoire | Inscription WS canonique / rattachement même K | K + D séparés | K | Résolution K et dédup réussies dans les fixtures admises | `OK_ALL_ORIGINS` — namespace et fixtures seulement |
| Bingo | Toutes origines testées | Gagnant ligne/carton actuel | K + D | K | K prioritaire, broadcast gagnant | `OK_ALL_ORIGINS` — contrat actuel simulé |
| Bingo | Papier sans socket, dont QR Hub | Gagnant legacy D seul | D | K | Roster papier non consulté, avance sans gagnant | `MIXED` — dépend du contrat et de la socket |
| Bingo | Entrée directe avec socket moteur | Gagnant legacy D seul | D | K | D→K depuis `this.players` | `OK_ALL_ORIGINS` non applicable à tous les QR ; succès du cas connecté |
| Bingo | Toutes fixtures | Déclarer échec | Phase/grille/nom | Sans objet | Notification sans lookup participant | `OK_ALL_ORIGINS` — absence de lookup uniquement |
| Quiz/BT | Toutes origines affectées par score | Finalisation | Liste mémoire K | K | Identité conservée, score ancien possible | `MIXED` — contamination du résultat |
| Tous | Reprise vivante testée | Reconnexion/reprise puis action | Identique avant/après | K conservée | Pas de nouveau mismatch créé par reprise | Score Q/BT `MIXED`; Bingo canonique `OK_ALL_ORIGINS` |
| Tous | Hub Remote | Ajout/recherche/undo Hub | Source typée/K ou H pour undo | Pas de lookup live | Namespaces cohérents dans code/tests locaux | Pas d’échec d’identité démontré ; pas de verdict end-to-end DB |
| Tous | Podium | Photo | Rang/clé de ligne | Sans mutation live | Contrat distinct, lecture statique | Non testé en upload ; aucun verdict runtime attribué |

| Source participant | Quiz papier | Bingo papier | Blind Test papier |
|---|---|---|---|
| QR Hub | `MIXED` score ; admission tardive mémoire à distinguer | K+D OK ; D-only sans socket vulnérable | `MIXED` score ; même réserve tardive |
| Hub Remote | `MIXED` après injection | K+D OK ; D-only sans socket vulnérable | `MIXED` après injection |
| Remote session | `MIXED`; HTTP snapshot immédiat | K+D OK ; legacy sans socket vulnérable | `MIXED`; HTTP snapshot immédiat |
| Saisie libre | `MIXED` score | K+D OK ; legacy sans socket vulnérable | `MIXED` score |
| Retrouvé/existant | `MIXED` score ; lookup typé correct | K+D OK ; lookup typé | `MIXED` score ; lookup typé correct |
| Restauré/repris | `MIXED` score ; K/D conservés | K/D conservés ; legacy incomplet | `MIXED` score ; K/D conservés |

Le détail de chaque fixture est dans `action-matrix.csv`, avec son ID et sa résolution observée. « Toutes origines » ne signifie pas « toute donnée legacy possible ».

## R. Verdict architectural

1. **Classe de bugs**, pas cas Quiz isolé : Quiz et BT partagent la même priorité de champ erronée ; Bingo présente une variante de fallback incomplet. La divergence score DB/live a aussi une cause indépendante (`GREATEST`).
2. **Sur-exposition organisateur non démontrée comme propriété de l’identité.** L’organisateur expose immédiatement des objets HTTP riches en D ; les QR passent également par ce serializer. Une comparaison de fréquence réelle reste non mesurée.
3. **Les surfaces n’ont pas le même contrat d’objet.** Hub Remote utilise H pour son roster ; Remote session utilise K/D moteur. Les actions live issues du Hub arrivent ensuite au même code Remote session que l’ouverture directe.
4. **K=`p:UUID` est le canon nominal commun**, scoped par session/runtime. Elle n’est pas un ID DB ni forcément le token EP Hub. La fiabilité universelle des données historiques n’est pas prouvée ; le schéma et les chemins legacy autorisent des exceptions.
5. Vulnérables aujourd’hui **dans les copies locales** : toutes corrections papier Quiz/BT passant par `applyScoreUpdate` quand D est présent ; finalisation dérivée ; Bingo legacy numérique sans socket. Les payloads Bingo actuels K+D testés ne reproduisent pas le défaut Quiz.
6. Un serializer commun côté Games est pertinent ; **adaptations moteur nécessaires** : arrays `playerId/playerDbId` Quiz/BT versus registres papier/connectés Bingo. Il faut aussi séparer score autoritaire de correction et score monotone de gameplay, et traiter indépendamment les inscriptions persistées non attachées à la mémoire.

## S. Patch minimal proposé, non exécuté

1. Dans Games, contrat d’action live explicite : `player_id=K` (ou `participant_key` versionné et adapté), `player_db_id=D` séparé. L’HTTP conserve l’ID DB utile ; le WS n’utilise plus `playerId=D` comme cible prioritaire. Éviter un renommage général des IDs Hub/source.
2. Dans Quiz/BT, resolver unique scoped par session : K valide prioritaire ; compatibilité D via `playerDbId` **uniquement en absence de K** ; refus explicite si K/D fournis désignent des participants différents. Le résultat retourne participant + K + D. Utiliser ce resolver dans `adminSetScore`; réemploi progressif dans les commandes concernées, sans refactor global.
3. Dans Bingo, le fallback D doit consulter le roster papier et le registre connecté du game courant. Une identité explicitement fournie mais introuvable doit être refusée ; seul le choix manuel sans identité peut appeler `advancePhaseWithoutWinner`.
4. Ajouter un résultat WS corrélé par `event_id` et une réconciliation explicite après ACK HTTP. Un succès de persistance n’est pas un succès live. Ne pas supposer qu’une reconnexion ou un polling HTTP hydrate automatiquement la mémoire.
5. Pour les baisses : voie autoritaire de correction papier (`score = valeur demandée`, après contrôles/idempotence appropriés), distincte du `GREATEST` du scoring normal. Respecter le score confirmé dans l’ACK. Ce point est nécessaire pour le contrat « retirer des points », indépendamment du resolver.
6. Bloquer/rafraîchir la finalisation tant que la correction persistée n’est pas réconciliée en mémoire, afin de ne pas republier un podium obsolète. Préciser séparément la stratégie des inscriptions papier tardives et du cas `already_active` sans participant mémoire ; ne pas créer aveuglément un joueur depuis une simple commande score.

Validation future : les mêmes fixtures doivent réussir sous projections HTTP, WS complet et WS partiel ; conflits K/D refusés ; anciens clients D-only résolus sans cibler un autre joueur ; ajout après hydratation initiale ; réduction de score ; finalisation ; trois reprises. Patch, livraison et restart restent hors de cette passe.

## T. Documentation future

Aucune documentation modifiée dans cette passe, conformément à la demande explicite, y compris HANDOFF/TASKS. Lors du patch : mettre à jour les tâches existantes (update-not-append) et README Games/Quiz/Blind Test/Bingo ; Global si mapping/admission change ; `HANDOFF.md`, `canon/interfaces/actions.md`, `canon/interfaces/canvas-bridge.md`, les sections de mapping participant Hub et éventuellement `canon/data/bingo-write-map.md`. `CHANGELOG.md` pour les corrections visibles, markers WS selon les moteurs effectivement modifiés ; régénérer sitemap/index. Routing : [Manifest][manifest], « Routing rules », R1/R2/R6/R11 et « Server restart markers ».

Corriger également la contradiction historique de la section Global du 12/07 sur les participations papier, si cette section est maintenue comme contrat.

## U. Résumé final obligatoire

### Cause Quiz connue

Remote : `player_id=K` et `playerId=D`. `adminSetScore` choisit D, compare à `player.playerId=K`, ignore `playerDbId`, échoue après un possible ACK HTTP. La projection WS sans D explique les succès intermittents.

### Étendue

Quiz **et Blind Test** : correction totale, saisie rapide, application des verdicts papier ; podium/finalisation exposés par propagation du score ancien. Bingo : parcours actuel canonique testé correct, compatibilité numérique seule sans socket vulnérable. Baisse de score Q/BT : divergence supplémentaire `GREATEST`.

### Origines à risque

QR Hub, Hub Remote injecté, Remote session, libre, existant et restauré sont tous exposés au défaut score avec la même forme HTTP. Pas de preuve d’une cause spécifique « ajout organisateur ». QR Hub papier ≠ socket moteur numérique ; cette distinction compte pour Bingo et les inscriptions tardives.

### Namespace canonique

Quiz/Blind Test : `session.players[].playerId = p:UUID`, D dans `playerDbId`. Bingo : `player_id = p:UUID`, D secondaire, roster papier distinct du registre connecté. H/M/E/T et tokens de session/reprise restent séparés.

### Risque fonctionnel

- **Action live refusée/ignorée** : participant non résolu, sans ACK d’échec UI approprié ; admission capacité peut aussi refuser légitimement.
- **DB mise à jour, runtime non** : défaut central reproduit avec persistance simulée.
- **Runtime modifié, DB non alignée** : baisse `GREATEST`; panne de fallback possible par code.
- **Mauvais participant ciblé** : non reproduit sur les origines canoniques ; ne pas l’affirmer. Les conflits K/D doivent être rejetés dans le futur resolver.
- **Affichage seul** : succès optimiste et alternance de snapshots masquent l’échec ; le défaut sous-jacent dépasse l’affichage puisque la finalisation reprend la mémoire.
- **Bingo legacy** : phase avancée sans attribution canonique plutôt qu’un refus net de l’identité introuvable.

### Patch recommandé

Transport K/D explicite, resolver scoped avec compatibilité D contrôlée, fallback Bingo couvrant les joueurs papier, confirmation/réconciliation live, correction de score autoritaire distincte du scoring monotone. Plan uniquement, aucun patch exécuté.

## Annexes de preuve

- [Index des preuves](paper-session-participant-identity-audit-2026-09-21/evidence-index.md) : chemins et fonctions avec liens vers les sources figées.
- [Matrice des identités](paper-session-participant-identity-audit-2026-09-21/identity-matrix.csv) : trois moteurs × huit provenances.
- [Matrice des actions](paper-session-participant-identity-audit-2026-09-21/action-matrix.csv) : 42 cas score/gagnant, résolutions et payloads.
- `results.json`, `bingo-results.json`, `resume-results.json`, `bingo-resume-results.json`, `finalization-results.json`, `http-results.json`, `ui-results.json`, `key-results.json`.
- [Empreintes des sources](paper-session-participant-identity-audit-2026-09-21/source-hashes.json), [horodatage et changements concurrents](paper-session-participant-identity-audit-2026-09-21/snapshot-metadata.json), `workspace-state.json`, [comparaison documentaire](paper-session-participant-identity-audit-2026-09-21/doc-comparison.md) : périmètre/version.
- Les probes ne chargent pas les bootstraps applicatifs réels ni les clients réseau. Leurs seuls effets sont des écritures d’artefacts dans `/tmp`.

[start]: https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md
[sitemap]: https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt
[manifest]: https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md
[quizdoc]: https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/quiz/README.md
[btdoc]: https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/blindtest/README.md
[bingodoc]: https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/bingo.game/README.md
[globaldoc]: https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md
[gamesdoc]: https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md
[actions]: https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/actions.md
[roadmap]: https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb

<!-- AUTO-UPDATE:END id="paper-session-participant-identity-audit-20260921" -->
