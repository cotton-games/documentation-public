# Phase 1 Hub PROD — paquet schéma initial

**DDL PROD PRÊT À EXÉCUTER**

Cible : `prod_cotton_global_0`, MariaDB `10.3.39-MariaDB-log`. Treize créations InnoDB : onze tables Hub et deux prérequis Quick Schedule. Aucun ALTER legacy, backfill, trigger, routine, événement, insertion métier, conversion de table existante ou déploiement. `blindtest_session_teams` est volontairement exclue : mode équipe désactivé, lecteurs/writer protégés en cas d’absence.

Les résultats PROD fournis et décisions motivées sont dans [PROD-DECISIONS.md](PROD-DECISIONS.md). Le [contrat détaillé](INVENTAIRE.md), `schema-contract.json` et `sql-evidence.json` donnent les preuves fichier → fonction → SQL et les définitions. L’export élargi ne contient pas toutes les colonnes legacy : aucune certification intégrale du legacy n’est déduite de son existence. Aucune modification legacy n’est nécessaire au paquet retenu.

## Fichiers opérateur

| Fichier | Rôle |
|---|---|
| `00-PRECHECK.sql` | READ-ONLY, conservé ; relevés déjà exécutés et analysés |
| `01-DDL-HUB-PROD.sql` | Treize CREATE complets, qualifiés par la base, avec étapes BEGIN/END et SHOW WARNINGS |
| `02-POSTCHECK-SCHEMA.sql` | Contrôle mécanique des structures et comptages exacts avant backfill |

Ne pas importer les scripts historiques référencés par l’inventaire. `build-package.py` est un générateur local sans accès DB ; `verify-package-local.py` est un banc de test jetable qui crée son propre serveur privé, pas une commande PROD.

## Inventaire final

Toutes ces tables sont absentes selon PRECHECK. Elles seront créées vides, avec **ENGINE=InnoDB, CHARSET=utf8, COLLATE=utf8_general_ci** explicitement définis.

| Objet | Type/périmètre | Usage du code livré | Action |
|---|---|---|---|
| games_hubs | Hub | Identité, contexte, routing/intent/transition, activation, présentation, instances, suppression, QR | CREATE |
| games_hubs_sessions | Hub | Memberships explicites Hub/session | CREATE |
| games_hubs_players | Hub | Identités/roster, photo active, agrégats | CREATE |
| games_hubs_participations_probables | Hub | Intentions de participation | CREATE |
| games_hubs_players_sessions | Hub | Mapping joueur/session et cycle d’accès | CREATE |
| games_hubs_publication | Hub | Publication éditoriale/pratique | CREATE |
| games_hubs_prizes | Hub | Lots globaux par rang | CREATE |
| games_hubs_remote_access | Hub | Accès/tokens Remote et révocation | CREATE |
| games_hubs_remote_master_presence | Hub | Présence Master et révisions | CREATE |
| games_hubs_remote_runtime_presence | Hub | Présence corrélée à session/exécution | CREATE |
| games_hubs_remote_commands | Hub | Queue, idempotence, résultats/reçus QR | CREATE |
| programming_quick_operations | Programmation associée | Idempotence/reprise d’une commande SchedulePlan | CREATE |
| programming_quick_series_operations | Programmation associée | Idempotence/reprise de programmation récurrente | CREATE |

Total : **210 colonnes, dont 181 Hub**, 52 index (85 composantes), 27 contraintes PRIMARY/UNIQUE. Quatre champs QR intégrés dans games_hubs ; dix champs stats intégrés dans games_hubs_players. Les photos, focus/presentation, routing génération/intention/transition, instances et marqueurs tardifs sont inclus. Aucun ADD ultérieur nécessaire. Les types/defaults exacts font partie du POSTCHECK.

Branding utilise general_branding type 5 et les médias existants. Exécutions/démo/readiness utilisent game_events et les sessions existantes. Pas de table supplémentaire inventée. Les deux tables Quick sont des prérequis de programmation, pas des tables games_hubs.

## Protocole phpMyAdmin

1. Les PRECHECK ont été exécutés et analysés. Si l’état PROD a changé depuis, rejouer **00** avant toute écriture : les treize objets doivent toujours être absents à la première installation, sans collision de vue/table et sans trigger.
2. Sauvegarder la base via votre procédure habituelle avant le DDL. Vérifier la cible et conserver les résultats PRECHECK avec la sauvegarde.
3. Importer **01-DDL-HUB-PROD.sql**. Les noms sont entièrement qualifiés ; aucun DATABASE() implicite, aucun changement du défaut latin1 de la base. Suivre les treize marqueurs d’étape et les avertissements. À la première erreur, STOP ; ne pas poursuivre manuellement les étapes dépendantes.
4. Importer **02-POSTCHECK-SCHEMA.sql en entier dans une même session**. Attendu : `SCHEMA_ISSUE_COUNT = 0`, aucune ligne d’anomalie, treize comptages à zéro, puis ligne `#TOTAL_13_TABLES`, total `0`, **SCHEMA_READY_FOR_BACKFILL = YES**.
5. Toute erreur SQL, absence de verdict final, valeur NO, anomalie ou ligne métier signifie STOP. Ne pas backfiller pour « réparer » le schéma. Transmettre les résultats et l’étape atteinte.
6. Après YES : **STOP**. Conserver les nouvelles tables vides. Aucun nouveau code, backfill, Hub, membership, joueur, lot ou commande à créer dans cette phase.

Les droits nécessaires sont CREATE pour 01, visibilité information_schema et SELECT pour les contrôles. Pas de CREATE ROUTINE/SUPER/ALTER legacy demandé. Les outils locaux n’ont pas exécuté ces scripts sur PROD.

## Fonctionnement du POSTCHECK READ-ONLY

Le POSTCHECK ne modifie ni schéma ni données. Il utilise des CTE SELECT, des variables de **session** et un PREPARE/EXECUTE/DEALLOCATE portant exclusivement sur l’une de deux chaînes SELECT fixes. Aucune entrée utilisateur interpolée, table temporaire, procédure ni SQL DDL dynamique. Cette petite garde permet de retourner **NO**, sans tenter de compter une table absente.

Contrôles mécaniques :

- 13 BASE TABLE attendues ; InnoDB, collation/table et charset/collation de chaque colonne.
- 210 colonnes : présence, ordre, type exact (y compris unsigned/ENUM), NULL, DEFAULT et Extra ; colonnes inattendues refusées.
- Tous les index : nom, unicité, ordre/colonne, absence de préfixe, BTREE/ordre ascendant ; index supplémentaires refusés.
- PRIMARY/UNIQUE et absence de contrainte supplémentaire, de trigger dans la base et de table Hub inattendue.
- QR 4/4 et stats 10/10 contrôlés comme toutes les colonnes ; présence et structure des deux tables Quick.
- Seulement après conformité du schéma : COUNT(*) exact sur les 13 tables, y compris Quick, et verdict YES uniquement si toutes sont vides. TABLE_ROWS n’est jamais une preuve de vacuité.

Les alias serveur utf8/utf8mb3 sont normalisés pour les tests sur versions différentes ; la collation effective reste utf8_general_ci. Aucun rabattement de casse des valeurs ENUM ou des défauts. Les variables sont réinitialisées : une exécution antérieure ne constitue jamais une preuve pour une nouvelle exécution. Une erreur SQL invalide le contrôle même si un ancien écran montrait YES.

Le verdict porte sur ce schéma initial et sa vacuité au moment du contrôle. Il ne prouve pas le backfill, l’état métier legacy ou la validité d’un futur déploiement. Le code Hub doit rester non déployé et aucune écriture concurrente Hub/Quick ne doit intervenir entre le contrôle et la prochaine phase.

## InnoDB et compatibilité MariaDB 10.3

Les anciens CREATE du helper et scripts Quick utilisent MyISAM. Aucun contrat n’impose ce moteur : mêmes clés uniques, mêmes CAS/UPSERT et verrous nommés GET_LOCK. InnoDB est DEFAULT en PROD et donne un effet transactionnel réel à la projection stats. Les compensations des parcours SchedulePlan restent nécessaires pour les écritures mixtes avec le legacy MyISAM. Aucun code de transaction ou engine legacy modifié. La justification et les fonctions examinées sont dans PROD-DECISIONS.md.

Le charset/collation du contrat est conservé : aucune conversion vers utf8mb4 ou latin1. Plus grande clé composite : 488 octets, sous la limite historique 768. Aucun index sur TEXT, aucune colonne JSON native, GENERATED, CHECK, valeur DEFAULT fonctionnelle ou fonctionnalité MySQL 8/10.11 requise. Les JSON applicatifs restent TEXT/MEDIUMTEXT.

Audit syntaxique 10.3 : CREATE TABLE IF NOT EXISTS, InnoDB, types simples, DEFAULT littéraux/NULL, index BTREE ; WITH/CTE non récursifs disponibles depuis 10.2 ; SELECT préparables avant 10.6. Aucune syntaxe ALTER récente ni DDL transactionnel supposé.

Sources MariaDB primaires : [CTE et nouveautés 10.2](https://mariadb.com/resources/blog/whats-new-in-mariadb-server-10-2/), [PREPARE — permitted statements](https://mariadb.com/docs/server/reference/sql-statements/prepared-statements/prepare-statement), [CREATE TABLE](https://mariadb.com/docs/server/reference/sql-statements/data-definition/create/create-table), [Information Schema COLUMNS](https://mariadb.com/docs/server/reference/system-tables/information-schema/information-schema-tables/information-schema-columns-table). Ces références expliquent les primitives ; elles ne remplacent pas un test sur la version PROD.

## Validation locale et limites

`python3 tmp/hub-prod-initial-schema-2026-09-08/verify-package-local.py` depuis documentation. Le script initialise un serveur **10.11.14**, sous /tmp, avec `--no-defaults`, socket privé et `--skip-networking`, puis l’arrête. Aucun accès aux DB existantes, DEV ou PROD. **Ce test n’est pas une certification MariaDB 10.3.** La compatibilité 10.3 est auditée statiquement ; le résultat opérateur restera requis après import.

Résultats dans `validation-package.txt` :

- Base sans Hub → NO ; installation complète → YES ; relance → YES avec métadonnées inchangées.
- Interruption après six tables → NO ; reprise du fichier complet → YES.
- Table/ligne legacy témoin conservées à l’identique. Garantie structurelle supplémentaire : 01 ne contient que les treize CREATE de noms nouveaux, SELECT et SHOW WARNINGS.
- Vrais helpers PHP sur le schéma InnoDB créé : zéro CREATE/ALTER aux deux appels, gardes QR/stats/Quick conformes.
- Absence de blindtest_session_teams : deux fonctions Canvas réelles renvoient les résultats prévus ; 15 tests Node du mode équipe désactivé verts.
- Quinze contre-tests → NO : défaut/type QR, stats absente, nullabilité/ENUM, unique manquante, ordre d’index, mauvais engine/collation, colonne/index inattendu, trigger, table Quick absente, ligne Hub et ligne Quick. Retour à un schéma neuf → YES.

Limite runtime distincte : les ensures Bibliothèque Pro restent capables d’émettre des DDL/normalisations même sur schéma présent. Le paquet ne dépend pas de ces émissions pour créer les objets Hub/Quick ; il ne corrige pas ce comportement de code. La garantie zéro DDL testée concerne le helper Hub conforme. La livraison du code et cette réserve restent une étape séparée, pas une autorisation implicite de déploiement.

## Interruption, relance et retour arrière

CREATE TABLE n’est pas annulable par ROLLBACK. Ne pas entourer ce fichier d’une transaction en espérant annuler une migration. Les marqueurs BEGIN/END servent à localiser l’arrêt ; un END avec avertissement « table exists » ne certifie pas sa définition.

Après interruption entre instructions : relever l’étape, lire 00/02, vérifier que les tables déjà présentes appartiennent à cette installation et correspondent au contrat. Les anomalies « absent » sont normales avant reprise ; toute définition incompatible exige STOP. Rejouer ensuite 01 entièrement : IF NOT EXISTS conserve les objets existants et crée les manquants. Puis rejouer 02 ; toute ligne métier détectée bloque la suite, sans suppression automatique.

Après crash serveur ou table endommagée : inspection DBA avant reprise. Le protocole ne répare pas une corruption. Les CREATE prennent des verrous de métadonnées et consomment espace disque ; ils ne reconstruisent pas les tables legacy. La durée réelle dépend du serveur, aucun délai garanti.

Retour arrière recommandé avant backfill/code : laisser les treize tables vides en place et conserver l’ancien code. Aucun DROP automatique fourni. Une suppression ultérieure exigerait vérification de vacuité/absence d’utilisateurs et décision dédiée ; ne pas restaurer une sauvegarde en écrasant des écritures legacy plus récentes.

## Jonction phase 2 uniquement

Préconditions : POSTCHECK vert, tables Hub/Quick encore vides, inventaire PROD recalculé, manifeste session → clé Hub figé, absence d’écritures concurrentes pendant le backfill si nécessaire. Aucune requête INSERT de migration, aucun backfill des 58 Hubs/68 memberships ni préparation de déploiement dans ce dossier.
