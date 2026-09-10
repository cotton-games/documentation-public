# Quick Add Hub — correctif local du 09/09/2026

## Diagnostic confirmé par l'opérateur

Les SELECT PROD fournis dans la conversation confirment le client 1726 `id_solution_usage=2`, Hub 132 `event/620` créé à 14:35:07 avec sessions 30194–30196, puis Hub 142 `soiree/0` et session 30230 créés à 16:57:31. Chaque session a un membership actif unique. Le GET suivant journalise `ambiguous_existing_hubs`. Le second Hub vient du Quick Add Dashboard sans ID source, dont le helper inversait la sémantique usage 2. Les lignes PROD n'ont pas été relues en DB par l'agent.

Le défaut est présent au SHA Pro livré `a7b596570d99c64ecb768f9b84339e712146f7a4` et dans les fonctions correspondantes sur main/hub_soiree. Le correctif est uniquement local sur Pro:hub_soiree. Aucun patch main, aucune réparation PROD, aucun déploiement.

## Contrat après correction

La modale poste `id_hub`. `start_dashboard_quick_program_context_get` accepte une source explicite et la recharge par ID ; il vérifie propriétaire, activité, suppression, date et type de contexte. La source invalide échoue sans alternative. Le service reçoit le Hub, son programme issu des memberships, sa date et son opération. La date du POST ne remplace jamais celle du Hub validé ; le contrôleur construit le retour depuis la date canonique. La route Dashboard reste par date, et l'ambiguïté existante reste refusée.

L'action Dashboard exige la source : même l'absence du champ est un échec, pas un accès au fallback. Seuls les appels du helper omettant la source conservent le chemin générique, avec usage 2 correctement associé à gamification/événement.

| Surface | Transport réel | Résolution cible | Classe avant / après |
|---|---|---|---|
| Dashboard Pro | POST `dashboard_quick_session_create`, désormais `id_hub` | Chargement exact puis service Global de préparation | VULNERABLE_TO_SAME_BUG → SAFE_EXPLICIT_HUB |
| Hub Master | CTA Ajouter une partie → POST `quick_session_create` sur l'URL courante avec token Hub, CSRF et clé idempotente | `app_games_hub_get_by_token` → contexte Hub → handler → service Global live | SAFE_EXPLICIT_HUB inchangé |
| Remote Hub | Ajout direct → AJAX `hub_remote&remoteToken=...`, action `quick_session_create`, CSRF et clé idempotente | validation token Remote ou session liée au Hub → handler → service Global live | SAFE_EXPLICIT_HUB inchangé |

Master et Remote ne redirigent pas vers Quick Schedule pour cet ajout. Leur objet Hub serveur reste contraignant, même si un autre `id_hub` est posté. Retour Master par token identique ; Remote rafraîchit son snapshot. Les trois surfaces utilisent `app_programming_quick_hub_create_from_game` puis `create_from_proposal` et le membership explicite `schedule_plan`, pas le commit `app_schedule_plan_commit`. Ce dernier conserve Home/Agenda generated_program, Bibliothèque fixed_content et récurrence. Aucun get_or_create dans les handlers Master/Remote ou la branche Dashboard explicite. La signature de proposition, l'idempotence et les guards Global ne sont pas modifiés.

Sources code : Pro `ec_start_script.php` (helper source et action Dashboard), `ec_start_sessions_day_dashboard_view.php` (formulaire) ; Games `app_hub_view_helpers.php` (route/token, handler, POST courant), `app_hub_remote_ajax.php` (token/session, handler, AJAX) ; Global `app_programming_recommendations_functions.php` (service partagé, majorités, membership, replay).

## Validation locale et limites

Commandes depuis la racine Cotton :

```bash
php pro/web/ec/modules/tunnel/start/ec_start_dashboard_quick_source_hub_test.php
php pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php
php pro/web/ec/modules/tunnel/start/ec_start_quick_schedule_ui_test.php
php pro/web/ec/modules/tunnel/start/ec_start_library_hub_add_flow_test.php
php global/web/tests/programming_quick_hub_service_contract_test.php
php global/web/tests/schedule_plan_commit_behavior_test.php
php global/web/tests/schedule_plan_commit_contract_test.php
```

Les six premières commandes passent. La nouvelle suite contient 38 contrôles : événement 620, soirée 0, usage 2, sources invalides, programme majoritaire papier court et numérique standard, idempotence, absence de Hub/session/membership supplémentaire au replay, handlers réels Master et Remote sur événement 620. Fixtures en mémoire seulement : authentification, catalogue, proposition signée et stockage sont des doubles ; helper Pro, résolution des paramètres et fonctions de création Global/handlers sont réellement exécutés. Pas de validation DB ou navigateur revendiquée.

La dernière commande conserve deux échecs préexistants : `Dashboard consumes an existing Hub read-only` et `remaining Dashboard write is explicitly bounded to legacy migration`. Ces assertions cherchent des chaînes qui ne sont plus dans `ec_start_sessions_day.php`, non modifié par ce patch. Elles ont été reproduites en substituant les sources HEAD d'avant patch au test, sans checkout. Les tests ne sont pas masqués ni corrigés hors périmètre. Syntaxe PHP des quatre fichiers Pro vérifiée ; diff sans erreur. Recette authentifiée DEV à effectuer séparément.

## Données PROD — relations attendues, aucune écriture proposée

Hub 132 doit rester la racine `event`, opération 620, compte 1726, date 09/09. Si l'opérateur conserve 30230, la session doit avoir la même date/compte/opération 620 et un unique membership actif vers 132 ; les memberships des trois sessions initiales restent sur132. Ses paramètres papier/numérique, format et contenu nécessitent une décision distincte : déplacer le membership seul ne les réaligne pas et ne modifie pas `championnats_sessions.id_operation_evenement`.

Avant tout retrait du Hub 142, contrôler :

- `games_hubs_sessions` et `championnats_sessions`, y compris sessions officielles/démos et autres memberships ;
- `games_hubs_players`, `games_hubs_players_sessions`, `games_hubs_participations_probables` (identités, inscriptions, contributions, scores) ;
- `games_hubs_publication`, `games_hubs_prizes`, branding type 5 (`id_ref` ou `id_related`) et médias ;
- `games_hubs_remote_access`, `games_hubs_remote_master_presence`, `games_hubs_remote_runtime_presence`, `games_hubs_remote_commands` (tokens, présence, commandes et réponses JSON) ;
- champs de focus/présentation, générations et QR sur `games_hubs` ;
- `game_events` (Hub, exécutions, sources/runtime, complétions) ;
- `programming_quick_operations` : Hub cible et résultat de replay, IDs de sessions et URL ; éventuels JSON des opérations de série ;
- runtime du jeu associé à 30230, participations et démos dérivées ; toutes références supplémentaires révélées par le schéma réel ;
- URLs publiques ou tokens déjà distribués, médias et caches/session navigateur, qui ne sont pas tous inspectables en SQL.

La suppression complète applicative d'un Hub supprime ses sessions membres : elle n'est pas une opération de fusion. Ne pas l'utiliser comme raccourci pour conserver30230. Ne pas supposer qu'un seul déplacement de membership puis suppression 142 suffirait. Ces contrôles sont un préalable à une procédure opérateur séparée.

### Lectures opérateur minimales

Aucune commande ci-dessous ne modifie les données. L'inventaire du schéma évite de supposer que toutes les tables du code existent effectivement en PROD.

1. Inventaire des références explicites Hub/session et des champs JSON à examiner :

```sql
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND (TABLE_NAME IN ('programming_quick_operations', 'general_branding')
       OR COLUMN_NAME IN ('id_hub', 'hub_id', 'id_session',
                       'source_session_id', 'runtime_session_id',
                       'active_session_id', 'presentation_session_id')
       OR (TABLE_NAME IN ('game_events', 'programming_quick_operations',
                          'programming_quick_series_operations',
                          'games_hubs_remote_commands')
           AND COLUMN_NAME LIKE '%json%'))
ORDER BY TABLE_NAME, ORDINAL_POSITION;
```

2. Générer, sans les exécuter automatiquement, les SELECT de comptage pour les références Hub existantes. Exécuter ensuite les SELECT retournés dans phpMyAdmin ; toute ligne concernant 142 doit être qualifiée avant réparation. Les lignes 132 servent de comparaison et ne sont pas à supprimer.

```sql
SELECT CONCAT('SELECT `', REPLACE(COLUMN_NAME, '`', '``'),
              '` AS hub_id, COUNT(*) AS reference_count FROM `',
              REPLACE(TABLE_NAME, '`', '``'), '` WHERE `',
              REPLACE(COLUMN_NAME, '`', '``'), '` IN (132,142) GROUP BY `',
              REPLACE(COLUMN_NAME, '`', '``'), '`;') AS readonly_sql
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND COLUMN_NAME IN ('id_hub', 'hub_id')
ORDER BY TABLE_NAME, COLUMN_NAME;
```

3. Résultat idempotent et branding, dont les références ne se limitent pas à un membership. Après confirmation de ces colonnes par l'inventaire pour les tables susceptibles de différer :

```sql
SELECT hub_id, status, operation_step, session_ids_json,
       result_json, dashboard_url, created_at, updated_at
FROM programming_quick_operations
WHERE id_client = 1726 AND hub_id IN (132,142);

SELECT id, id_type_branding, id_ref, id_related
FROM general_branding
WHERE id_type_branding = 5
  AND (id_ref IN (132,142) OR id_related IN (132,142));
```

Le registre peut avoir expiré : son absence actuelle ne contredit pas les logs. Les champs JSON et les références indirectes joueur/exécution ne sont pas couverts exhaustivement par les comptages ; la procédure de réparation dépendra des résultats, sans SQL d'écriture dans cette note.

## Documentation publique consultée

- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md — Statut actuel ; Règle preuve d'abord.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt — Repos ; Project status.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md — Update triggers ; Routing rules.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/README.md — Update 2026-09-02 Contrat atomique métier Quick Schedule ; Update 2026-08-27 Dashboard Hub: ajout rapide autorisé en préparation.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md — Update 2026-09-02 SchedulePlan et commit de programmation ; Update 2026-08-27 Quick-add Hub: politiques temporelles explicites.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/notes/hub-prod-migration-2026-09-09.md — Livraison et provenance ; Validation et limites.

Le journal AI Studio raw fourni a été relu avant patch : entrées 07–09/09 sous « Fait, livré en PROD / Septembre 2026 » relatives aux pages WWW, SEO, sitemap et .htaccess. Aucun fichier Pro/Games/Global de ce correctif signalé comme modifié extérieurement ; aucun rechargement serveur. L'incident132/142 et la garantie effective de transmission dans la modale étaient non trouvés dans la documentation publique consultée : diagnostic issu du code, des traces et des SELECT fournis par l'opérateur.
