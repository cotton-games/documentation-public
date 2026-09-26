<!-- AUTO-UPDATE:BEGIN id="hub-restart-from-zero-audit-20260911" owner="codex" -->
# Audit — Continuer / Recommencer une session Hub suspendue

11/09/2026 — Audit local, patch applicatif arrêté conformément aux conditions A.3/F du demandeur. Aucun changement fonctionnel, déploiement, restart ou accès DB réel. Les constats portent sur le code du workspace, pas sur une inspection du schéma déployé.

## Décision et plus petit blocage

Le modèle lu distingue les exécutions dans `game_events`, mais pas les contributions joueur/session. Créer un nouvel `execution_id` ne suffit donc pas à exclure la tentative remplacée des résultats, participations et agrégats. La voie officielle conserve le même `runtime_session_id`, token et stockage moteur. Aucun contrat `superseded` consommé de bout en bout par ces lecteurs n'a été trouvé.

Pré-requis minimal de conception : définir une tentative officielle autoritaire par session source, relier ses mappings et résultats à cette tentative, puis faire respecter cette autorité par les lecteurs courants et historiques et invalider les projections persistées. Cela implique une évolution du modèle/lecteurs au-delà du branchement UX demandé ; aucune migration proposée comme exécutable ni appliquée ici. Effacer les anciennes données en place ne remplit pas le contrat de remplacement récupérable demandé.

## Preuves code — chemins relatifs au workspace Cotton

| Sujet | Fichier, fonction et lignes | Constat |
|---|---|---|
| Badge | `games/web/modules/app_hub_view_helpers.php`, `games_hub_session_master_status_label`, 3725–3738 ; rendu cartes 4607–4616 | Running, sans focus, non terminée donne Suspendue. Le badge seul ne prouve pas une suspension officielle exacte ; une action devrait relire provenance et journal. |
| Nouvelle exécution | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`, `app_games_hub_execution_context_create`, 4345–4398 | `force_new` génère un `hubexec-*` et écrit `hub_execution_started`. Pas de reset moteur ni purge/versionnement de résultats dans cette primitive. |
| Producteur officiel | même fichier, `app_games_hub_session_launch_from_master`, 10078–10230 | `resume_recreated_runtime`, readiness, injection papier active et routage existent ; source et runtime officiels restent `session.id`. La branche existing retourne avant injection avec grant de reprise. Ce n'est pas un restart officiel isolé. |
| Mappings | même fichier, `app_games_hub_schema_ensure`, 366–420 | Unicité `(id_hub_player,id_session)`, aucun `execution_id` dans ce mapping ni ses colonnes complémentaires. |
| Participations | même fichier, `app_games_hub_participation_counters_get`, 6034–6051 | Compte les mappings active/completed avec participation, jointure sur session ; fallback participants historiques. Aucun filtre de tentative. |
| Stats | même fichier, `app_games_hub_players_stats_mappings_load`, 6341–6393 ; collecteurs Quiz/BT/Bingo 6474–6635 | Mappings par session ; Quiz joint sur token, BT sur session, Bingo winners sur token. Un nouvel événement d'exécution ne change pas ces jointures. |
| Podium/photos | même fichier, `app_games_hub_session_podium_row_hub_player_get`, 7689–7725 | Résolution Hub/session/participant, sans tentative. |
| Fallback agrégats | même fichier, `app_games_hub_aggregate_ranking_context_get`, 8189–8199 | Repli sur `app_games_hub_players_stats_legacy_context_get` avec les sessions. Ajouter uniquement un événement superseded ne le filtre pas. |

Les intitulés de fonctions et numéros de lignes désignent la copie auditée. Ni la popup Master/Remote ni la nouvelle commande, son verrou, son retry ou son rollback n'ont été implémentés. Le contrat Continuer est conservé sans modification.

## Bingo — reset canonique et conservation des grilles

Deux chemins existants doivent être distingués, sans inventer un reset moteur parallèle :

- `games/web/includes/canvas/php/bingo_adapter_glue.php:698–780`, `bingo_api_reset` : remet les timestamps des 25 cases et le bonus à zéro, les morceaux, logs, lots et la phase cible. Il ne modifie ni l'identifiant de grille, ni son contenu, ni `id_joueur`. Mais il ne purge pas `bingo_phase_winners`, ni `bingo_players.gain_phase`, et ne remet pas `morceau_courant` à zéro. Ce chemin seul est insuffisant.
- Même fichier, `_bingo_reset_demo_state:790–875` : reset complet existant avec phase/index zéro, purge winners, gains joueurs vides et **conservation des rows joueurs et de l'attribution des grilles**. C'est la logique de reset complet à réutiliser dans une future solution autorisée ; sa route `resetdemo` ne devient pas pour autant une route officielle. Elle ne crée pas de nouvelle exécution et ne règle pas le blocage d'autorité des résultats.
- Ne pas utiliser `_bingo_reset_grids_support:1049` : cette fonction désassigne explicitement `id_joueur=0`.

Attribution serveur : `bingo_api_grid_assign:2223–2328` et `bingo_api_grid_get_or_assign:2455–2527` recherchent d'abord une grille existante par playlist/support/joueur. Si trouvée, ils la retournent avant toute prise de grille libre. Cette propriété dépend de la conservation de ces clés. Les lectures précèdent le verrou d'attribution : elles ne démontrent pas à elles seules l'absence de double attribution sous concurrence. L'invariant absolu « aucun chemin ne consomme une nouvelle grille » n'est donc pas certifié pour un futur restart/rejoin concurrent.

Mémoire WS : `bingo.game/ws/bingo_server.js:169–227` contient notamment clients, paperPlayersByGame, playingStates, lotsByGame, sessionIdByGame, currentTrackPositionByGame et hubRuntimes. Le handler `reset:1463–1575` persiste d'abord, conserve les joueurs officiels, supprime deux caches et diffuse `reset_game`. Il ne réinitialise pas toutes ces Maps. Le handler `demo_reset:1432–1461` remet notamment la lecture et la position à zéro. `buildStateFor:4027–4038` peut encore projeter la progression conservée d'un runtime Hub gelé. `disposeHubSuspension:3694–3706` supprime de nombreuses Maps : ce cleanup n'est pas à appeler comme reset arbitraire avant une transition récupérable.

Player : `games/web/includes/canvas/play/play-ws.js`, `clearBingoScopedGridStateForCurrentSession:864` purge les clés checked/locked scoppées sans retirer l'identité de grille. Le handler `reset_game:1333–1365` diffuse le reset UI. `play-ui.js:3070–3105` vide coches/verrous, index et médaille puis persiste l'état vide en conservant la grille. Le mécanisme démo possède également un `bingo_reset_epoch` pour invalider les anciennes coches à identité constante. Le futur restart doit couvrir les Players déconnectés/retournés au Hub, qui ne reçoivent pas nécessairement le signal WS de reset.

## Recette Bingo obligatoire à implémenter après levée du blocage

1. Préparer une session officielle avec joueurs Hub actifs, grilles attribuées, cases cochées/verrouillées, progression et gagnant de phase. Capturer execution_id, identités Hub/runtime, idPlaylistClient, identifiants/numéros/contenu des grilles, propriétaires et nombre de grilles libres.
2. Suspendre puis Recommencer depuis Master et, dans une recette séparée, Remote.
3. Exiger nouvelle exécution ; pour les joueurs déjà présents toujours actifs : mêmes identités et mêmes grilles/contenus/propriétaires, zéro nouvelle attribution et nombre de grilles libres inchangé. Ne pas réactiver les joueurs Hub devenus inactifs.
4. Exiger phase/index initiaux, aucun winner/gain/progression, cases/bonus/coches/verrous/médailles remis à zéro en DB simulée, Maps et Player/localStorage.
5. Rejoindre avec un Player précédemment déconnecté, recharger, rejouer le même request_id et simuler deux rejoins concurrents : mêmes grilles, aucune consommation supplémentaire, une seule nouvelle exécution.
6. Exiger aucune contribution de l'ancienne tentative aux résultats, participations, classement, podium/photos, stats persistées et fallback historique ; échec avant création récupérable et ancien runtime non réutilisé après succès.

Cette recette n'a pas été exécutée : la fonctionnalité est volontairement non implémentée. La matrice complète des 30 cas du demandeur reste requise après levée du blocage.

## Vérifications exécutées hors connexion

- Global : `php web/tests/hub_stats_pending_session_test.php` — OK (fixtures de consolidation/rebuild, fallback et winners Bingo).
- Bingo : `node --test ws/tests/hub_suspend.test.js ws/tests/bingo_phase_progress.test.js` — 7/7.
- Games : `node --test web/tests/hub_suspend_test.mjs` — 34/34.

Ces tests existants utilisent des effets externes simulés ; ils valident les contrats actuels, pas le restart demandé. Les autres suites demandées n'ont pas été relancées puisque l'audit a déclenché l'arrêt avant patch.

## Documentation raw consultée

- [START](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), « Discipline de génération » et « Règle preuve d'abord » ; SITEMAP.md/txt/ndjson develop, README, DOCS_MANIFEST (« Routing rules »), HANDOFF (« Suspension officielle Hub ») lus avant audit applicatif.
- Journal AI Studio à l'URL fournie par le demandeur : contenu raw extrait du champ JavaScript `const raw` du lecteur public. Aucun chemin applicatif ciblé signalé comme modifié hors workspace dans les entrées consultées ; la divergence `.htaccess` WWW est hors périmètre. Cela ne certifie pas la synchronisation serveur.
- [Bingo write map](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/bingo-write-map.md), sections `resetdemo` et `reset` : conservation `id_joueur`, winners et stockage Player.
- [Actions](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/actions.md), « Suspension officielle Hub » et matrice Bingo `reset`/`resetdemo` : gel des mutations et voies distinctes.
- [Global README](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Hub Remote — boucle automatique selon présence runtime » : existing et readiness new/recreated. [Bingo README](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/bingo.game/README.md), contrat Canvas bridge.
- Contrat officiel de remplacement d'une tentative avec exclusion complète et conservation garantie des grilles : **non trouvé dans la documentation consultée**.

Seule la documentation de l'audit est modifiée (rapport, HANDOFF, TASKS Games/Global/Bingo et index générés). README fonctionnels et contrats livrés inchangés. Aucun rollback applicatif nécessaire ; le rapport ne décrit aucune livraison PROD.
<!-- AUTO-UPDATE:END id="hub-restart-from-zero-audit-20260911" -->
