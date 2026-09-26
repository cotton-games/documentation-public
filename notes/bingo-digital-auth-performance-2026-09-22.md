# Bingo numérique — coût d’authentification, patch local du 22/09/2026

> **Statut au 22/09/2026 : branche `sas_players`, EN COURS — NON DÉPLOYÉ EN PROD.** Ce lot est exclu du déploiement `hub_soiree` confirmé par l’opérateur. La promotion documentaire vers `main` ne change pas ce statut. [État de livraison](../canon/deployment-status.md).


**PIPELINE BINGO AMÉLIORÉ MAIS GOULOT RESTANT**

**ATTRIBUTION DES GRILLES INCHANGÉE ET INVARIANTS PRÉSERVÉS**

Le chemin DB nominal passe de **5 à 4 HTTP serveur**, de **2 à 1 authentification complète**, et de **6 à 5 SELECT repository directs** par joueur. Il conserve une prélecture de routage authentifiée. Le premier `state` Hub numérique conserve le compteur mais ne transporte plus le roster et ne le trie plus. **La queue playlist couvre toujours toute l’auth ; les cohortes capacité ne gagnent pas de regroupement nominal.** Pas de qualification réelle5 000, pas de sas, de déploiement ou de restart.

## Sources, journal et périmètre

Relus : [audit sas](hub-initial-session-sas-audit-2026-09-22.md), [audit pipeline](hub-player-registration-pipeline-audit-2026-09-22.md), [patch capacité/BT](hub-capacity-publication-patch-2026-09-22.md). Navigation publique : [START, Parcours/Discipline de génération](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), [SITEMAP develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), [Manifest, routing/markers](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), README et HANDOFF publics consultés. La doc publique consultée ne contient pas encore tous les derniers patches locaux : le code local et les trois rapports locaux font foi pour cette passe, aucune parité DEV/PROD déduite.

Journal AI Studio RAW rechargé/décodé avant modification. Aucun des fichiers Bingo ciblés signalé comme modifié hors workspace. La dépendance ecommerce précédemment signalée a déjà été rechargée par l’utilisateur ; ni elle ni Games/Global ne sont modifiés dans ce lot. Aucune DB réelle, SSH, navigateur ou environnement applicatif distant utilisé.

Sauvegarde locale de départ pour comparaison ponctuelle : `/tmp/bingo-auth-audit/before/`. Elle inclut le patch capacité précédent ; les comptes avant ci-dessous ont été reproduits sur ce code, pas simplement repris de l’audit.

## Chronologie et classement de chaque étape

Chemin avant : premier `authenticatePlayer` → résolution du token session → `reset_state` de routage → queue playlist → `reset_state` pré-opération → validation clé canonique + second `authenticatePlayer` → restore lifecycle → remplacement socket → capacité → bind → état DB → snapshot trié/envoi → `reset_state` post-opération.

| Étape / preuve | Classement | Décision |
|---|---|---|
| `bingo_server.js:performAuthentication`, premier repository | **OBLIGATOIRE À CHAQUE JOUEUR** pour le routage ; hydratation du profil **REDONDANTE** | Nouveau `resolvePlayerPlaylist` : une lecture grille+secret retournant seulement la playlist ; ne constitue jamais une autorisation de bind |
| Premier `reset_state` dans `performAuthentication` | **REDONDANT** pour `auth_player`, utilisé uniquement pour retrouver la playlist | Supprimé pour ce type ; les autres types conservent leur chemin |
| `bingo_reset.js:createBingoResetCoordinator`, lecture pré-opération | **OBLIGATOIRE À CHAQUE JOUEUR** dans le contrat actuel | Conservée ; vérification explicite playlist source = playlist issue de la grille pour ce chemin |
| `performBingoAuthentication`, clé canonique et auth complète | **OBLIGATOIRE À CHAQUE JOUEUR** | Conservées après attente ; comparaison de la playlist réauthentifiée avec celle de la barrière |
| `restoreHubRuntime` → `hub_lifecycle.js:restore` | **OBLIGATOIRE À CHAQUE JOUEUR** avec le protocole actuel ; potentiellement mutualisable avec un nouveau contrat | Conservée fraîche ; pas de flag « déjà restauré » utilisé comme autorité |
| Recherche/remplacement ancien socket | **OBLIGATOIRE À CHAQUE JOUEUR** | Last connection wins conservé, scan O(C) restant |
| `hub_capacity_get` | **OBLIGATOIRE MAIS MUTUALISABLE** | Cohortes pré-fetch existantes conservées ; queue actuelle ⇒ B=N dans le nominal simulé |
| Bind/context/tag/broadcast dirty | **OBLIGATOIRE À CHAQUE JOUEUR** | Inchangés ; pas d’écriture d’attribution grille |
| `getPlayerGameState` | **OBLIGATOIRE À CHAQUE JOUEUR** pour l’état frais, données pourtant communes à la playlist | Deux lectures phase/progression conservées après bind ; pas de version commune garantissant une réutilisation |
| `buildStateFor` / roster complet | Liste Player Hub : **HISTORIQUE / À SUPPRIMER SI PREUVE** ; compteur/état : obligatoires | Preuve client obtenue : liste supprimée uniquement pour ce premier state Hub numérique ; compteur strictement identique |
| Lecture reset post-opération | **OBLIGATOIRE À CHAQUE JOUEUR** dans le contrat actuel | Conservée : observe un reset externe survenu pendant les awaits et réconcilie la mémoire |

Aucune étape dynamique n’a été classée « une fois par runtime/génération » : ni une génération reset stable, ni la présence d’un runtime ne prouvent une offre active, une session non suspendue ou une exécution inchangée.

## Auth repository : routage puis preuve complète

`ws/repository/db/db_player_repository.js:authenticatePlayer` fait deux SELECT nominaux : grille par `(id,id_securite)`, puis profil/grille/playlist avec propriétaire ; le fallback `equipes_joueurs` ajoute un troisième SELECT. Le premier résultat complet était abandonné : seul `idPlaylistClient` servait au routage. Le réutiliser après la queue aurait réutilisé aussi un propriétaire, un secret validé, un profil et un contenu de grille potentiellement anciens.

Le nouveau `resolvePlayerPlaylist(gridID,token)` lit uniquement `id_playlist_client` avec les **mêmes prédicats grille+secret**. La fonction complète existante reste textuellement inchangée et s’exécute dans la barrière. Une rotation du secret entre les deux lectures refuse l’auth ; une autre playlist refuse le bind via `BINGO_PLAYER_ROUTE_CHANGED`. Un changement de propriétaire/profil est relu par l’auth complète comme auparavant, jamais repris depuis le routage. Aucun token/secret/propriétaire n’est écrit, aucune attribution touchée.

Le contrat de base propose un fallback via `authenticatePlayer` pour les autres implémentations éventuelles ; l’économie SQL indiquée concerne l’implémentation DB locale. Pour un profil introuvable, le refus a désormais lieu à l’auth complète dans la queue, sans bind.

Avant : 2 appels auth complète + 1 getState = 3 appels repository, 6 SELECT nominaux / 8 avec deux fallbacks legacy. Après : 1 routage + 1 auth complète + 1 getState = toujours 3 appels repository, **5 SELECT nominaux / 6 legacy**. Résolution froide `ensureSessionIdForGame` : lecture session supplémentaire possible, exclue de ces chiffres comme dans l’audit initial ; elle n’a pas été mise en cache autrement.

## Reset : deux lectures sur le chemin nominal numérique

Le premier HTTP initial ne lisait aucune donnée utilisée ensuite sauf `playlistClientId`. Son résultat `phase/reset_pending/generation` n’était pas utilisé dans `performAuthentication`. La playlist vient maintenant de la grille authentifiée ; la lecture de tête de queue vérifie explicitement sa concordance avec `state.playlistClientId` (`verifyPlaylist`). Une discordance ou un état invalide refuse le chemin.

La lecture pré-opération fournit génération, phase, pending et playlist : refuse pending, aligne le runtime si la génération a changé, capture la génération via AsyncLocalStorage. Elle doit rester **après** l’attente de queue. Une valeur en mémoire ne prouve pas qu’un reset PHP n’a pas été engagé entre-temps.

La lecture post-opération observe la génération après les awaits d’auth/lifecycle/capacité/state. En cas de reset externe validé, `clearResetState` réinitialise la progression mémoire sans effacer identités/grilles. La supprimer laisserait une mémoire potentiellement ancienne jusqu’au prochain message. Aucun cache de reset partagé entre deux admissions n’est ajouté.

Nominal `auth_player` : **3 → 2** lectures. Refus précoce secret/routage : zéro ; pending/playlist incohérente/échec pré-lecture : une tentative ; runtime déjà suspendu : le bypass historique du coordinateur laisse l’opération au guard lifecycle, donc nombre variable. Autres auth : chemin historique inchangé. Reset gameplay, commandes, retries, pending durable, ACK, verrou SQL `bingo-playlist-<id>` et filtrage de génération sortante inchangés.

Limite préexistante conservée : le verrou SQL est relâché entre requêtes, la queue WS n’est pas une transaction DB globale. Un reset PHP peut se produire pendant l’auth ; la génération capturée et la réconciliation post-opération restent le mécanisme existant, pas une nouvelle promesse d’atomicité réseau/DB.

## Queue : pourquoi elle reste large dans ce lot

La prélecture grille/session s’exécute déjà en parallèle des autres tentatives. Le coordinator prend ensuite une place par playlist et garde la main sur : pré-read reset, authentification complète, lifecycle, remplacement socket, capacité/comptage/bind, lecture état, construction/envoi et post-read reset. Les messages gameplay/reset de cette playlist utilisent la même queue.

Le remplacement et le bind manipulent des Maps et des compteurs ; `clearResetState` touche progression, scores et état des connexions ; `hub_lifecycle.restore` modifie des flags et peut restaurer une suspension. Une simple sortie du bind/state de la queue permettrait à un reset de s’intercaler entre le guard, le bind et la lecture DB. `outgoingPayload` filtre une ancienne génération, **mais n’annule pas un bind ni une mutation mémoire tardive**. La suppression de la queue n’est donc pas un changement mécanique sûr.

La préparation parallèle → commit court nécessiterait au minimum une validation autoritaire de génération au commit, un traitement des résultats devenus obsolètes, et une coordination des reprises/lifecycle/remplacements/déconnexions. Un groupe d’auth parallèles sous une même barrière pourrait aussi être étudié, mais devrait régler les doubles sockets et les flags lifecycle sans ouvrir la barrière aux nouveaux arrivants. Ces architectures ne sont **pas déclarées impossibles** ; elles ne sont pas introduites sans ce protocole et sa preuve. La cible idéale n’est pas forcée au détriment des invariants.

Durée logique séquentielle avant/après : **4 HTTP + 4 SELECT repository nominaux** à l’intérieur de chaque job dans les deux versions (5 SELECT legacy). Le HTTP supprimé et la lecture profil supprimée étaient hors queue. À l’intérieur, seul le tri/sérialisation du roster initial disparaît et un second scan capacité au plafond est évité. Donc **N jobs avant et après**, latence cumulée I/O encore séquentielle ; aucune réduction chiffrée en ms annoncée.

## Lifecycle et capacité

`ws/hub_lifecycle.js:restore` sérialise ses opérations par runtime, positionne loading/failed, valide `activation_allowed`, l’exécution officielle, une suspension persistante, et interdit de déverrouiller silencieusement une suspension mémoire. Le résultat ne contient pas de donnée propre au joueur, mais suspension/fenêtre/exécution peuvent changer sans reset de génération Bingo. Ni `hubHasLiveState` ni `hubExecution` mémoire ne permettent de sauter ce contrôle.

Une cohorte fermée avant lecture pourrait partager une lecture avec plusieurs demandeurs déjà en attente, mais la queue actuelle ne les fait pas arriver ensemble dans restore. Une promesse réutilisée après début de lecture/une TTL aurait le problème de fraîcheur déjà documenté. **N lectures lifecycle → N**, sans duplication supplémentaire introduite. Le transport `canvasWrite('hub_lifecycle')` et le dispatcher `games_ajax.php` peuvent journaliser le stage read en `game_events` : cet effet persistant n’est pas supprimé ni multiplié ; aucune transformation Games/Global de cette action dans ce lot.

Capacité : même wrapper par cohortes et mêmes guards stock. Harnais intégré : 2/50/500/5 000 tentatives en parallèle donnent respectivement 2/50/500/5 000 appels source capacité, car les jobs sont séquentiels. **Pas de nouveau cache ni de gain de regroupement revendiqué.**

## Premier state : preuve client et contrat conservé

Trajet client réel : `games/web/includes/canvas/play/play-ws.js`, handler Bingo `state`, bloc « 6) Players », transmet `{total:num_connected_players, players}`. `play-ui.js`, listener `player/players:update`, prend le total explicite en priorité ; la liste ne sert que de fallback `.length`. Il ne rend pas de classement Bingo à partir de ce roster. Le compteur périodique Player utilise déjà le message allégé `{type:num_connected_players,num}`. Master/Remote consomment le roster sur leurs propres chemins, non modifiés.

`buildStateFor(gameID,base,{includePlayers:false})` est utilisé uniquement par `auth_player` lorsque la réponse capacité prouve Hub non-démo. `getPlayersSnapshot` conserve le même merge/dédoublonnage et retourne `merged.size` sans créer la liste finale triée. Le parcours du roster et la Map temporaire restent O(C+P), **ce n’est pas un compteur O(1)**. Les appels par défaut, papier, démo/hors Hub, Master/Remote, reset et publications périodiques restent complets.

Comparaison testée : payload nouveau = payload ancien moins `players` ; tous les champs du socle, compteur, génération, `roster`, phase, progression, pause de reprise, lots et champs personnels éventuels restent identiques. Le repository ne mettait pas la grille dans ce premier state : la grille reste chargée par le parcours Player existant (`emitGridIfAvailable` côté client), aucune suppression de donnée grille. Aucun changement client requis.

## Scans et index mémoire

- Doublon/reconnexion : scan de `players.connections`, O(C), conservé.
- `PlayerConnectionsTracker.getPlaylistPlayers` : matérialise/filtre toutes les connexions, O(C), conservé. Son résultat est désormais réutilisé dans la même section synchrone pour comptage et alias au plafond, au lieu d’une seconde extraction.
- Comptage capacité/identités : O(R) ; compteur du state : merge O(C+P), inchangés hors tri.
- Index secondaire non ajouté : `playlistCounts` ne représente pas le merge papier/numérique ni son dédoublonnage, et le code possède des suppressions directes de `connections` (ex. `disposeHubSuspension`). Un index identité → socket réclamerait de centraliser tous les écrivains/cleanup pour ne pas créer une autorité divergente.

## Volumes et complexités statiques

Pour N nouveaux joueurs, runtime déjà routé, nominal DB sans legacy, hors inscriptions PHP pré-WS et publications périodiques :

| Mesure | Avant | Après |
|---|---|---|
| HTTP serveur total | 5N | 4N |
| reset_state | 3N | 2N |
| lifecycle / capacité | N / N | N / N |
| Auth complètes | 2N | N (+ N routages légers) |
| Appels repository de haut niveau | 3N | 3N |
| SELECT repository directs | 6N (8N legacy) | 5N (6N legacy) |
| Jobs séquentiels playlist | N | N |
| Rosters initiaux complets triés envoyés aux Players Hub | N | 0 |
| Comptages/merges initiaux du roster | N | N |

| N | HTTP avant → après | SELECT directs avant → après | Lignes roster initiales avant → après, vague vide croissante |
|---|---|---|---|
| 50 | 250 → 200 | 300 → 250 | 1 275 → 0 |
| 500 | 2 500 → 2 000 | 3 000 → 2 500 | 125 250 → 0 |
| 5 000 | 25 000 → 20 000 | 30 000 → 25 000 | 12 502 500 → 0 |

Les lignes supposent l’envoi des populations1,2,…,N. En reconnexion d’un roster fixe R : N×R lignes évitées. Le total numérique de requêtes SQL côté Games/Global/ecommerce n’est pas établi ; le HTTP reset retiré évite également ses lectures/verrous PHP, sans inventer leur total déployé.

Initial state : tri/transport O(R log R)/O(R) → comptage O(C+P), payload sans roster O(1) par rapport à R. Sur la vague, un volume WS O(N²) disparaît et le tri répété O(N² log N) disparaît ; **scans/merges O(N²) et réponses capacité O(NH) restent**, ainsi que les I/O sérialisées. Les publications organisateur/Remote continuent de porter O(R) ; leur throttle1s n’est pas modifié.

## Tests locaux exécutés

Nouveau `bingo.game/ws/tests/bingo_auth_pipeline.test.js` : fonctions réelles auth/restore/snapshot/remplacement sous VM, vrai coordinator, vrai lifecycle, vrai lecteur capacité, vraie classe DB repository avec Knex/SQL et réseau doublés ; aucune connexion externe.

- 2/50/500/5 000 tentatives simultanées : chaque socket retrouve sa grille/identité/playlist, phase0/progression0/génération0, aucune grille dupliquée dans les fixtures, aucun joueur perdu, jobs tous terminés et compteur d’attente revenu à zéro ; une seule opération active par playlist.
- Routage secret invalide, ID canonique invalide, rotation secret, déplacement playlist après routage, changement propriétaire relu, discordance session/playlist ; fallback legacy6 SELECT.
- Pending reset, erreur lecture, avant/après reset, génération changée pendant les awaits, reset qui attend la fin de l’auth, échec reset puis progression de la queue, reconnexion/plafond/retrait actif.
- Runtime nouveau/existant, lecture lifecycle par joueur, refus lifecycle/suspension/expiration simulés, pas de lecture persistante supplémentaire introduite.
- Payload complet vs réduit ; total avec merge/dédoublonnage papier et progression préservée ; démo/hors Hub complets. Vrais extraits adapter/UI : même compteur et état score/rang avec/sans liste.

Commandes depuis `/home/romain/Cotton` :

```sh
node --test bingo.game/ws/tests/bingo_auth_pipeline.test.js
php global/web/tests/hub_capacity_bingo_grid_test.php
php games/web/tests/bingo_reset_test.php
node games/web/tests/hub_capacity_runtime_test.cjs
node games/web/tests/paper_roster_bingo_test.cjs
```

Résultats : les12 premiers scénarios du nouveau test passent, dont5 000 ; les2 scénarios ajoutés démo/UI passent séparément avec `--test-name-pattern='demo and autonomous|actual Player'` (14 scénarios couverts). Comparaison de départ avec `BINGO_AUTH_BASELINE=/tmp/bingo-auth-audit/before/ws/bingo_server.js` sur2/50 : comptes6 SELECT/5 HTTP retrouvés et3/1 275 lignes de roster, puis5 SELECT/4 HTTP et zéro ligne après patch. L’option baseline sert à la comparaison locale, pas à un déploiement.

Régression WS :41 tests verts avec `node --test` sur `bingo_reset`, `bingo_phase_progress`, `hub_suspend`, `runtime_expiry`, `remote_continuity`, `bingo_quit_guard`, `bingo_terminal_delivery`, `bingo_winner_notification` (`ws/tests/*.test.js`, sélection explicite hors ancien test Jest demo). PHP : vrai générateur append formats court/long, papier/numérique, stock51–100, attributions/scores existants conservés, idempotence ; reset canonique/interleavings/recovery. Runtime capacité trois moteurs et roster papier Bingo verts. Syntaxe des quatre fichiers applicatifs et du test : OK. `git diff --check` Bingo et documentation : OK. Comparaison avec la sauvegarde : corps existants des méthodes repository auth complète/papier/état et branches auth papier/organisateur/Remote textuellement inchangés.

Ces doubles ne prouvent pas la concurrence DB réelle ni l’unicité d’attribution en production. Le code d’attribution, de secret, de génération et le verrou `hub_grid_capacity_<playlist>` sont inchangés ; les tests existants autour de ces invariants restent verts. Les durées du runner VM ne sont pas des benchmarks serveur.

## Qualification réelle 5 000 : plan uniquement

1. Environnement ultérieurement autorisé, jauge/stock réellement suffisants ; paliers50/500/5 000, phase0 sans auto-start. Pas de lancement réel effectué ici.
2. Séparer reconnexion WS sur grilles prêtes (coût auth) et vague froide Hub (ensure, allocation, navigation). Profils distincts ; valider unicité propriétaire/grille/token par lectures autorisées après le test.
3. Harnais bots futur : dépasser la limite200/context via plusieurs contextes indépendants et cadence d’admission non séquentielle ; reproduire polling watcher, puis mesurer séparément la queue serveur. Ne pas attribuer à Bingo une limite du générateur.
4. Instrumenter t_route/queue_enter/queue_start/pre_reset/auth/lifecycle/capacity/bind/state/post_reset/queue_end, profondeur/pente/drainage, B/N capacité, HTTP/SQL/bytes, mémoire/GC/event-loop, bufferedAmount ; p50/p95/p99/max. Fixer les budgets avant la recette, pas ici.
5. Recettes distinctes reset pending/commit/échec/retry pendant vague, suspension/expiration/reprise, coupure lifecycle, secret invalide/rotation, reconnexion multi-onglet et plafond. Critères : aucune identité/grille croisée, pas de bind mauvaise génération/playlist, phase0 avant départ autorisé, queue drainée, scores/grilles préservés.
6. Le goulet de queue étant confirmé, ne pas utiliser ce lot pour annoncer5 000 prêts. Étudier ensuite le protocole de préparation/commit ou de cohortes d’auth, avec validation reset/lifecycle explicite, avant le sas.

## Fichiers, livraison et rollback

Applicatif Bingo uniquement : `ws/bingo_server.js`, `ws/bingo_reset.js`, `ws/repository/base/player_repository.js`, `ws/repository/db/db_player_repository.js`, `version.txt`. Test ajouté ci-dessus. Les hunks précédents dans `ws/envUtils.js`, `ws/hub_capacity.js`, `ws/capacity_reads.js` appartiennent au lot capacité, conservé. Aucun hunk Quiz/BT/Games/Global ajouté dans cette passe.

Marker Bingo **`restart 22-09-2026/02`** ; Quiz/BT restent `/01`. **Restart WS Bingo nécessaire après livraison future autorisée ; aucun restart/déploiement exécuté.** Pas de reload PHP, migration/table/index ni SQL à demander pour décider ce patch.

Rollback : retirer seulement les hunks de cette passe dans les quatre fichiers applicatifs et le test ; conserver le lot capacité/BT et les changements utilisateur. Publier ensuite un nouveau marker selon discipline, pas écraser un déploiement existant avec une ancienne valeur. Contrat Player réduit compatible avec le client existant ; revenir au payload complet ne nécessite aucun patch front.

Documentation : README/TASKS Bingo (entrée existante enrichie), HANDOFF, contrats actions/Canvas, DB usage/write map, entrypoints/runbooks/PM2 et index générés. Pas de CHANGELOG : aucune UX visible voulue.
