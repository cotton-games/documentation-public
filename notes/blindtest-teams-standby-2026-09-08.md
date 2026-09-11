# Blind Test — équipes conservées en stand-by — 08/09/2026

## Décision et état de livraison

Correctif local sur les branches `hub_soiree` Blind Test/Games. Le produit courant est individuel. L’implémentation équipe reste identifiable, testable et réversible ; réactivation via chantier dédié, probablement contrat Hub cross-game, sans commencer ce chantier ici. Aucun commit, déploiement, restart réel, accès SSH/DB/DEV/PROD ou navigateur.

## Discipline avant patch et limites de fraîcheur

Sources consultées : [START main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), sections « Statut actuel » et « Discipline de génération » ; [carte Blind Test develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/blindtest/README.md), sections équipes des 03/07 et 06/07 ; [TASKS](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/blindtest/TASKS.md) ; [manifest](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers » et « Server restart markers ». SITEMAP, README, manifest et Handoff locaux lus avant patch.

Le journal AI Studio `documentation/general/0_ROADMAP.md` a été consulté avec `mode=raw` à l’URL du manifeste. Le premier accès web avait échoué ; la lecture HTTP locale RAW a réussi. Les entrées mentionnent des pages portail WWW Blind Test/Bingo/Quiz, des pages marketing et AI Studio, mais aucun fichier runtime ciblé Blind Test/Games. Aucun fichier à recharger depuis un serveur n’est identifié par ce journal. Cela ne prouve pas que le workspace est à jour des serveurs : aucun accès serveur indépendant. Les trois dépôts étaient propres au début du travail.

## Audit factuel et stratégie minimale

| Surface | Preuves code / fonctions | Traitement |
|---|---|---|
| Lobby joueur hors Hub | `games/web/player_canvas.php`, `bt-team-card`, boutons create/join/code/leave | Markup conservé, `hidden` et `display:none` dès le rendu HTML |
| Commandes Player | `games/web/includes/canvas/play/play-ws.js`, `PlayerAPI`, `wsSend`, handlers `registrationSuccess`/`teamState` | Capacité false par défaut ; seul état WS explicitement enabled autorise les actions sortantes |
| UI contexte/réponse/fin | `games/web/includes/canvas/play/play-ui.js`, `renderBlindtestTeams`, `applyRuntimeTeamState`, bandeau et résultat équipe | Carte pilotée par capacité ; lecture du résultat historique conservée |
| WS direct | `blindtest/web/server/actions/wsHandler.js`, `handleTeamAction`, switch des cinq actions | Refus avant dispatch métier des quatre mutations ; lecture runtime maintenue |
| Métier équipe | `actions/teams.js`, create/join/byCode/leave, `buildTeamState`, `removePlayerFromRuntimeTeam` | Même défense aux entrées internes ; OFF ne génère aucun code et ne mute pas le roster |
| Inscription/reconnexion | `actions/registration.js`, `registerPlayer`, `sendTeamStateToPlayer` | Inscription canonique inchangée ; capacité OFF envoyée après ACK via le module équipe |
| Départ/fermeture | `actions/connection.js`, `removePlayerFromRuntimeTeam`, `broadcastTeamState` | Appels existants conservés ; garde métier empêche mutation équipe, état diffusé vide |
| Réponse/verrouillage | `actions/gameplay.js`, `runtimeTeamForPlayer`, `teamIdForPlayer`, `handleAnswer` | OFF rend null le rattachement effectif, donc aucun accès à `teamItemAnswers` dans le gameplay |
| Scoring/rangs/podium | `gameplay.js`, `hasRuntimeTeams`, `buildRankingEntries`, `updatePlayerListNow`, `buildEndGamePayloadFromSession`, `persistScore`, `persistPodium` | Projection live joueur, score individuel, doublon individuel conservé ; snapshot historique terminé lisible |
| Master/Remote | `games/.../core/canvas_display.js`, `ws_effects.js`, `remote/remote-ui.js` | Renderers de badge/équipe depuis les payloads seulement ; aucune commande de création identifiée. OFF live produit des lignes solo ; renderers historiques conservés |
| Canvas persistance | `games/.../php/blindtest_adapter_glue.php`, `_bt_persist_session_teams`, `blindtest_session_teams` | Snapshot sans équipe ne supprime plus les lignes historiques ; principal `session_update` inchangé |
| Hydratation/reprise | `registration.js::hydrateFinalRankingsFromDB`, `envUtils.js::sessionTeamsGet`, glue `blindtest_api_session_teams_get`, `_bt_build_preload_rankings_with_session_teams` | Lectures et snapshots finaux inchangés, sans condition OFF |
| Logs/config | `messaging.js` autorise `teamState`/`teamError`, aucun flag préexistant trouvé | Nouveau booléen métier central, sans option env/client |

Avant le patch, inscription joueur puis création depuis le lobby ou directement en WS suffisait ; fenêtre `En attente`, master primaire ouvert, pas de démarrage. Une première réponse équipe verrouillait les autres membres et alimentait le score projeté. Le badge final et la persistance rendaient la fonctionnalité visible sur la branche de préparation PROD ; changelog mis à jour sans affirmer qu’elle était déjà déployée.

## Coupe-circuit et compatibilité

`blindtest/web/server/features.js` contient `BLINDTEST_TEAMS_ENABLED = false` et exporte un objet gelé. Le flag n’est ni une variable PM2/env, ni un champ de session, ni un paramètre client. Il est lu au chargement du WS.

- OFF : `teamCreate`, `teamJoin`, `teamJoinByCode`, `teamLeave` renvoient `{ type: 'teamError', code: 'TEAM_FEATURE_DISABLED', message: 'Le Blind Test se joue individuellement.' }`, sans mutation ni write Canvas.
- `teamList` reste une lecture disponible ; `teamState` contient `enabled=false`, `teams=[]`, `teamPlayers={}`, `playerTeamId=null`, `maxPlayers=6`, `locked=true`. Aucun nom ni code. Inscription/reconnexion et notifications existantes utilisent la même construction.
- OFF : rattachement effectif nul et mode classement équipe false même si `teams`, `teamPlayers`, `teamItemAnswers` existent. Le chemin individuel calcule et persiste le score de chaque joueur. Les hints neutres existants (`isTeam=false`, `teamId=null`) restent compatibles.
- Résultat terminé : les `finalRankings` et le podium préexistants sont lus comme avant, y compris badges équipe. Le flag porte sur la fonctionnalité courante, pas sur l’interprétation des archives.
- `_bt_persist_session_teams` avait une branche `DELETE` lorsque les IDs équipe étaient vides ; elle devient un retour sans write `NO_TEAM_RANKINGS`. Aucune suppression de table/champ/donnée, aucune migration. Le traitement des snapshots équipe non vides reste en place.
- Aucune modification des règles Hub, des seuils démo, des formats papier/numérique ou du code Bingo/Quiz. Matrice testée avec transitions Canvas simulées : officiel/démo × Hub/hors Hub × sans équipe/résidus. Les sources des handlers sont exécutées, les services externes sont simulés.

## Fichiers code/tests

Blind Test : `web/server/features.js` (nouveau), `web/server/actions/{gameplay,teams,wsHandler}.js`, `web/server/restart_serveur.txt`, `tests/teams-disabled.test.cjs` (nouveau).

Games : `web/player_canvas.php`, `web/includes/canvas/play/{play-ui,play-ws}.js`, `web/includes/canvas/php/blindtest_adapter_glue.php`, `web/tests/hub_session_settings_test.php`, nouveaux `web/tests/blindtest_teams_disabled_ui_test.mjs` et `web/tests/blindtest_teams_history_test.php`.

## Tests exécutés

Depuis `documentation`, sauf mention contraire :

| Commande | Résultat |
|---|---|
| `node --test ../blindtest/tests/teams-disabled.test.cjs` | 15/15 : inscription WS, refus WS et métier sans mutation, liste vide, conservation roster, 8 combinaisons de parcours/résidus, lecture/hydratation terminée, code dormant ON, comparaison exacte du chemin individuel ON/OFF, 2 cas papier |
| `node ../games/web/tests/blindtest_teams_disabled_ui_test.mjs` | PASS : masquage HTML, ancien serveur sans capacité, OFF, révocation, aucune émission team*, réponses/inscription intactes |
| `php ../games/web/tests/blindtest_teams_history_test.php` | PASS : vrais helpers avec PDO simulé refusant tout write, conservation historique, preload, JSON membres malformé |
| `php ../games/web/tests/hub_session_settings_test.php` | OK ; assertion lobby adaptée à la carte dormante |
| `php ../games/web/tests/hub_paper_historical_session_ensure_test.php` | OK |
| `node ../games/web/tests/hub_remote_polling_test.mjs` | OK |
| `php ../games/web/tests/hub_natural_end_stats_rebuild_test.php` | OK |
| `php ../games/web/tests/hub_remote_contract_test.php` | Échec préexistant, une assertion QR, voir ci-dessous |

L’assertion Remote rouge est exactement : `Hub Master player QR is clickable only when the server dev flag enables it and commercial demo mode is inactive`. Contre-épreuve : test HEAD exécuté dans `/tmp`, `__DIR__` fixé au dossier tests réel, sources modifiées qu’il lit (`player_canvas.php`, `wsHandler.js`) remplacées par leurs versions HEAD. Même unique échec. Aucun changement QR pour ce correctif. Les autres suites peuvent écrire `Failed to connect to bus: No data available` via l’environnement shell, sans empêcher leur résultat OK.

La preuve d’absence d’effet du code résiduel est double : deux membres avec une réponse équipe résiduelle à 999 points répondent chacun, reçoivent des points différents et deux writes canoniques ; sans équipe, les messages/classements et writes Canvas OFF sont exactement égaux au chemin individuel avec module ON dans le harness.

Contrôles finaux : `node --check` sur tous les JS/CJS/MJS modifiés/ajoutés (modules navigateur via `node --input-type=module --check`), `php -l` sur PHP modifiés/ajoutés, `git diff --check` dans les trois dépôts, `npm run docs:sitemap` et relecture des index générés.

## Documentation, marker et retour arrière

README/TASKS Blind Test et Games actualisés ; entrées historiques V1/carte modifiées sur place (update-not-append). Interfaces actions/bridge, entrypoints, runbook DEV, PM2, CHANGELOG, HANDOFF et cette note mis à jour. Modifications uniquement dans les blocs AUTO-UPDATE quand présents ; index/sitemap générés par le script existant.

Marker préparé : `restart 01-09-2026/01` → `restart 08-09-2026/01` ; aucun redémarrage effectué.

Retour arrière technique : rétablir les fichiers du correctif en bloc, puis nouveau marker selon discipline ; ne pas réintroduire la purge des archives sans décision dédiée. La réactivation volontaire nécessite un chantier produit et une validation avant bascule du booléen, le code dormant étant conservé/testé.

## Risques résiduels / recette réelle

- Les contrôles sont locaux, avec services et DOM simulés : aucune preuve de déploiement, cache navigateur, listener WS réel ou données serveur. Aucun SQL nécessaire pour préparer ce correctif.
- La livraison devra inclure le nouveau `features.js`, les handlers WS et les assets/template Games. Le marker préparé doit être pris en compte par la procédure habituelle ; recharger les clients pour retirer une UI ancienne mise en cache. Un ancien client peut encore afficher son ancien bouton, mais le WS patché refuse toute mutation.
- Vérifier après livraison autorisée : nouvelle session hors Hub/Hub, démo/officielle, absence d’UI équipe, réponses indépendantes, classements joueurs, lecture d’un ancien podium équipe. Historique sans équipe et équipe doivent rester lisibles.
- Le test Remote QR préexistant reste rouge ; il n’est pas une régression introduite par le coupe-circuit.
