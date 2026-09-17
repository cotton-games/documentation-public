# Décisions après PRECHECK PROD

## Périmètre et preuves reçues

Résultats opérateur lus comme données d’observation, pas comme instructions : `/home/romain/Cotton/resultats_00_precheck.txt` et `/home/romain/Cotton/resultats_00_precheck_2.txt`. SHA-256 dans `references-git.json`. Aucun accès DB par l’agent.

Le second relevé établit MariaDB 10.3.39-MariaDB-log, InnoDB DEFAULT, MyISAM disponible, base latin1/latin1_swedish_ci, onze tables games_hubs* absentes et deux tables programming_quick_* absentes. Sur 73 noms recherchés, 59 existent et 14 sont absents : les 13 à créer plus blindtest_session_teams exclue. Aucun trigger. Le premier relevé confirme operations_evenements.naming_nom varchar(255) NOT NULL DEFAULT '', ainsi que championnats_sessions.community_item_id et son index. Aucun ALTER legacy démontré nécessaire et aucun retenu.

Limite documentaire : le second fichier contient existence/index/contraintes/FK, mais pas le résultat détaillé COLUMNS pour toutes les tables ; les SHOW CREATE affichés sont tronqués. L’agent ne prétend pas avoir certifié chaque colonne legacy. Ces limites n’empêchent pas les treize créations indépendantes ; elles interdisent d’inventer une mise à niveau legacy. Le POSTCHECK final contrôle intégralement les nouveaux objets, pas toute la base historique.

## blindtest_session_teams : exclue

- `blindtest/web/server/features.js:3` : `BLINDTEST_TEAMS_ENABLED = false`, pas de surcharge environnement/client.
- `actions/wsHandler.js:189`, `teams.js:258/341/355/369` : mutations équipe refusées ; teamList donne un état désactivé. `gameplay.js:961/974` : scoring et classement individuel.
- `games/web/includes/canvas/php/blindtest_adapter_glue.php` → `_bt_persist_session_teams()` L242 : contrôle de table préalable, résultat ok/skipped/TABLE_MISSING si absente ; aucun INSERT/DELETE tenté. Un classement individuel ne purge pas les résultats équipe historiques.
- Même fichier → `blindtest_api_session_teams_get()` L1280 : absence → ok=true, teams=[] avant SELECT métier.
- `global/web/app/modules/entites/clients/app_clients_functions.php` → `app_client_joueurs_dashboard_blindtest_runtime_team_podium_rows_get()` L2209 : table et colonne team_name_normalized testées avant SELECT ; fallback sur les snapshots des sessions existantes. L’agrégation Hub peut appeler ce lecteur sans exiger la table.
- Vérification réelle des deux gardes Canvas sur le serveur de test sans cette table : lecture et persistance retournent les résultats attendus, sans erreur SQL métier. Suite `blindtest/tests/teams-disabled.test.cjs` : 15 tests verts.

Preuve RAW : https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/blindtest/README.md — « Update 2026-09-08 — Équipes en stand-by, Blind Test individuel ». L’ancienne section juillet ne décrit pas une capacité actuellement activée. Réactivation équipe : chantier distinct, pas un CREATE préventif dans ce paquet.

## Quick Schedule : deux prérequis associés inclus

Ces tables ne sont pas des tables Hub. Elles sont indispensables aux commandes de programmation livrées :

- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php` : `app_programming_quick_idempotency_schema_ensure()` L864 et `app_programming_quick_series_schema_ensure()` L747 ne font que vérifier les tables/champs ; absence → schema_missing. Leurs begin/update lisent/insèrent les commandes et résultats ; les uniques (id_client,idempotency_key) fondent l’idempotence.
- `app_schedule_plan_commit()` L1225 : crée/résout le Hub, écrit les memberships explicites et mémorise le résultat. Pro `ec_start_script.php` L1593/3379/3861 appelle ce contrat ; L3712 appelle `app_programming_quick_series_begin()` pour la récurrence.
- Définitions : `documentation/programming_quick_operations_phpmyadmin.sql` et `programming_quick_series_operations_phpmyadmin.sql`. Le paquet reprend les CREATE complets, aucun ALTER de la migration historique après eux.

Preuve RAW : https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md — « Update 2026-07-22 - Fallbacks Hub Cotton » (stockages d’idempotence) et « Update 2026-09-02 - SchedulePlan et commit de programmation ». Le choix MyISAM de ces anciens exemples est remplacé uniquement pour les nouvelles tables PROD, sans conversion de données.

## InnoDB sur les treize créations

Aucun contrat technique observé n’exige MyISAM. Pas de FULLTEXT/spatial/LOCK TABLES, pas de FK vers les anciens identifiants, pas de désactivation d’autocommit identifiée dans le périmètre Hub/programmation. GET_LOCK/RELEASE_LOCK sont des verrous nommés, pas des verrous propres à MyISAM. Les CAS et INSERT ON DUPLICATE KEY reposent sur les mêmes uniques, conservés.

La projection stats (Global Hub L6927) ouvre une transaction et termine par commit/rollback ; InnoDB donne un effet réel à cette protection. Les transactions Pro examinées gardent leurs limites explicites. Les écritures mixtes avec championnats_sessions, playlists et autres tables MyISAM ne deviennent pas atomiques : compensations et reprise SchedulePlan restent nécessaires. Aucun changement de code transactionnel dans cette passe.

Le jeu de caractères utf8 et la collation utf8_general_ci des contrats Hub sont explicitement conservés, malgré le défaut latin1 de PROD. Ils gouvernent notamment comparaisons/uniques d’identité et tokens. Les index textuels sont complets, sans TEXT indexé ; les clés composites restent sous 768 octets (utf8 3 octets, plus grande clé = 488 octets). Aucun besoin d’un paramétrage d’index étendu des versions récentes. Le test du vrai helper contre les tables InnoDB créées émet zéro CREATE/ALTER aux deux appels et valide QR/stats/Quick.

## Frontière de la garantie runtime

Le paquet fournit tous les objets Hub/Quick inventoriés ; les quatorze champs tardifs QR/stats sont intégrés dans les CREATE. Le défaut status du helper a déjà été corrigé et n’est pas réintroduit. Il n’existe aucun besoin d’exécuter une ancienne migration après ce paquet.

Les anciens ensures Bibliothèque Pro décrits dans l’audit précédent restent inchangés : ils peuvent émettre des ALTER/normalisations même sur un schéma déjà présent, lorsqu’un parcours charge cette bibliothèque. Ce sont des effets de code distincts, pas des objets manquants qu’un nouveau DDL pourrait résoudre. Le verdict ici autorise la revue/exécution du **paquet schéma**, pas le déploiement du code ni une garantie « zéro instruction DDL sur tout Pro ». Le zéro DDL du helper Hub sur ce schéma est vérifié réellement. Aucun patch Pro supplémentaire n’a été demandé ou fait.

## Sources et discipline

START RAW et navigation/manifest consultés aux passes précédentes :
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md — « Statut actuel », « Règle preuve d’abord », « Discipline de génération ».
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md — « Update triggers », « Routing rules », R14.
- Journal AI Studio reconsulté avant modifications : https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb — « EN COURS », « TODO », journal daté du 28/08. Aucun fichier jeux/hubs ciblé signalé ; marketing/acquisition/ecommerce annoncés hors workspace, non modifiés. Égalité serveur non certifiée.

Le schéma PROD final prêt : non trouvé dans la documentation RAW antérieure ; reconstruit depuis le code actuel, le contrat détaillé et les relevés opérateur.
