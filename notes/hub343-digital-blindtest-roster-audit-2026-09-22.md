# Hub343 — Blind Test numérique : six joueurs et compteur vingt — 22/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub343-digital-roster-audit" owner="codex" -->
Audit client10, Hub343, session27934. Vingt inscrits Hub dont18 bots selon l’utilisateur. Captures Master fournies à08:41:58,08:42:01 et08:47:24 ; logs locaux rechargés. Audit initial sans patch ; correctif des bots ensuite demandé et réalisé localement, décrit ci-dessous. Aucun service réel, DB, SSH, déploiement ou restart. Horaires Europe/Paris (logs moteur UTC+2).

## Constats établis

- Les captures montrent les mêmes **six lignes** au classement. Complément utilisateur : le compteur alterne20→6 **aussi sans quitter la pause** ; la capture08:47:24 confirme6 en pause. Ce n’est donc pas une simple différence entre deux vues, ni la preuve de14 déconnexions/reconnexions.
- `blindtest/web/server/server-logs.log:13395` :08:39:10, hydratation de6 participations actives, roster runtime6. Ligne13400 : `connected=6,totalPlayers=6,rankingEntriesTotal=6`. Après le second rechargement, la fenêtre WS va de08:39:09 à08:50:32 :22 publications de compteur, une initiale à1 puis21 à6 ; aucune à20. Dernières publications à08:43:25 (ligne13691),08:44:38 (13709) et08:45:39 (13724), toutes à6.
- Lignes13659 et13679 :08:42:00.584 et08:42:03.511, roster encore6, autour de la capture. Le champ de log `connected` compte ici le roster, pas une preuve de six sockets ouvertes.
- `games/logs/error_log:5194` : dès08:39:04, `Call to undefined function canvas_live_participant_rows()` dans `blindtest_adapter_glue.php:1238`. Stack : `test_bots.php:102` → `blindtest_resolve_token` → `_bt_fetch_players` → `blindtest_api_players_get`.
- **466 occurrences** de cette erreur après le second rechargement (dernière ligne9145 de error_log). `games/logs/access_log:7059` à8337 :466 appels `test_bots.php` en HTTP500 entre08:39:04 et08:45:52. Le chargement nécessaire au démarrage des bots est donc interrompu.
- Global confirme le mapping session27934/Hub343/client10 (lignes303–306). Les logs HTTP Blind Test fournis restent ceux des refus d’accès à06:53, sans preuve supplémentaire sur ce test.

Les20 inscriptions Hub ne garantissent pas20 inscriptions/connexions au moteur numérique. L’erreur de démarrage des bots explique un roster numérique incomplet ; les logs seuls ne permettent pas de reconstituer l’historique individuel de tous les14 manquants. Aucun pseudo, token, IP ou URL d’accès recopié ici.

## Cause locale du HTTP500

`games/web/test_bots.php:101` charge directement `blindtest_adapter_glue.php`, annoncé autonome. Celui-ci appelle désormais `canvas_live_participant_rows` (PATCH1) dans `players_get`, mais la définition de cette fonction se trouve uniquement dans `games/web/includes/canvas/php/boot_lib.php:1033`. Ce dernier n’est pas chargé sur ce parcours.

Vérification PHP locale sans DB : charger le glue seul puis `function_exists('canvas_live_participant_rows')` retourne **false**. Le défaut est donc reproductible dans la copie locale : contrairement à l’incident Hub342, ce diagnostic ne repose pas sur l’hypothèse d’un ancien glue servi. Les lecteurs Quiz/Bingo utilisent aussi ce helper ; leur risque sur les chargements autonomes mérite couverture lors du correctif.

Correctif local réalisé ensuite sur le point d’entrée bots : chargement commun décrit ci-dessous, sans suppression du filtre ni duplication du roster.

## Limite du diagnostic du compteur vingt

Le moteur observé n’envoie pas de roster20. La liste reste6 sur les trois captures. Le template `organizer_canvas.php` contient encore des valeurs initiales20, mais cela **ne suffit pas à prouver** l’origine du libellé complet «20 joueurs connectés» observé.

Le renderer local `canvas_display.js::renderPlayersCountFromStore` écrit pourtant les compteurs pause et lecture depuis le même `GameStore.totalPlayers`. Son exécution isolée sous VM avec total6 donne bien «6 joueurs connectés» en pause et «6» en lecture. Les sources locales seules ne reproduisent donc pas la divergence des deux compteurs avec un store stable.

La provenance exacte du20 reste à vérifier côté page réellement chargée : version/cache des assets et mutations du store/DOM, y compris pendant une pause stable. Le complément oriente vers une réécriture du compteur par des mises à jour successives ; une concurrence HTTP/WS ou une réinjection de snapshot est une hypothèse, pas une cause prouvée. Les logs rechargés vont désormais jusqu’à08:50:32 (Games jusqu’à08:50:50), mais ne contiennent aucun événement de compteur entre08:45:39 et08:50:32 ni la trace de mutation navigateur montrant20. Ils couvrent donc temporellement la capture08:47:24 sans identifier l’émetteur du20. La recherche locale retrouve les écritures du compteur via le store, le preload, les snapshots HTTP et les événements WS ; aucune trace fournie ne permet d’attribuer la valeur20 à l’un d’eux. Aucune preuve permettant d’affirmer que20 est un décompte de sockets, une nouvelle émission moteur ou un changement réel de roster. Ce défaut d’affichage doit être distingué du HTTP500 des bots, confirmé séparément.

## Vérifications et suite

Deux sondes locales : absence du helper après chargement autonome PHP confirmée ; renderer réel des compteurs cohérent pour6 sous DOM simulé. Aucun test permanent ou code applicatif modifié.

Après correction du chargement des dépendances : vérifier `test_bots.php` sans500, puis admissions/roster moteur des20 joueurs. Contrôler ensuite les deux compteurs à chaque bascule pause/lecture avec la version servie et le store inspectés. Ne pas afficher arbitrairement20 pour masquer une inscription numérique incomplète. PATCH1/1B/2/3 non modifiés par cet audit.

## Correctif bots réalisé localement — 22/09/2026

À la demande de l’utilisateur, `games/web/test_bots.php` charge désormais `includes/canvas/php/boot_lib.php` dans le endpoint `ajax=session_meta`, après validation du token non vide. Les trois inclusions de glues isolés sont supprimées ; les résolveurs et payloads Quiz/Blind Test/Bingo restent identiques. Le bootstrap standard apporte le helper commun et les dépendances d’admission Hub. Aucun changement des lecteurs, filtres, règles de jeu, compteurs ou moteurs WS.

Fichier applicatif à déployer **sur la base PATCH1/PATCH2 existante** : `games/web/test_bots.php` uniquement. Aucun restart WS ni marker. Le `boot_lib.php` et ses dépendances doivent être ceux de cette base ; ils ne sont pas modifiés dans ce correctif.

Test ajouté : `games/web/tests/bots_bootstrap_test.php`. Il charge les inclusions réellement déclarées par le script, sans config ni connexion réelle : trois résolveurs disponibles, helpers roster/admission disponibles, vrais lecteurs Quiz/Blind Test avec PDO simulé, filtre actif SQL/déduplication/identités canoniques et exclusion d’un participant non admis. Échec sur la copie avant correction (`BOTS_SOURCE=/tmp/hub343-test_bots-before.php`), succès après. Commande : `php games/web/tests/bots_bootstrap_test.php` depuis Cotton. Syntaxe PHP et diff-check verts ; suite PATCH1 `node games/web/tests/paper_roster_patch1_suite.mjs` :14/14 suites vertes. Le chargement du resolver Bingo est testé ; aucune promesse de recette complète des bots sur réseau réel.

Journal AI Studio relu avant patch : aucun changement des scripts bots identifié. Aucun rechargement applicatif distant, DB réelle, déploiement ou restart. Le compteur20 intermittent reste une investigation distincte.

Recette après copie du fichier : recharger le simulateur, relancer les bots sur le Hub de test, vérifier `test_bots.php?ajax=session_meta` sans500, puis les admissions/publications moteur jusqu’à20. La correction ne réactive pas automatiquement les tentatives déjà échouées et ne force pas un compteur20.

Rollback : retirer uniquement ce remplacement des inclusions dans `test_bots.php` (copie avant correctif `/tmp/hub343-test_bots-before.php`, temporaire locale). Aucun rollback de données ; le retour arrière réintroduit le défaut de dépendance. Documentation : cette note, README/TASKS Games, TASKS Blind Test, HANDOFF, CHANGELOG et index générés.
<!-- AUTO-UPDATE:END id="hub343-digital-roster-audit" -->
