# Migration manuelle du stockage QR Hub — DEV

## Statut et périmètre

2026-09-07 : fichier local [hub_player_qr_dev.sql](../../migrations/hub_player_qr_dev.sql) préparé pour import phpMyAdmin, cible MariaDB 10.3.39 / MyISAM / utf8_general_ci. Autorisation utilisateur limitée à la préparation locale ; aucun import distant ni déploiement exécuté par l’agent. Import DEV réalisé ensuite par l’utilisateur, résultat confirmé ci-dessous. A/C/D conservé ; B applicatif désormais autorisé et implémenté localement, sans déploiement. La migration n’a pas été rejouée pendant B. Aucun raccordement de migration à l’ouverture du Hub ni à un ensure.

La dernière consigne retire PROD du périmètre : sa base Hub est en retard et sera traitée par une migration globale ultérieure. Ne pas importer ce fichier en PROD. Aucun nom de base ni mécanisme de détection d’environnement n’est codé en dur : l’opérateur doit sélectionner la bonne base DEV. La garde de version/moteur n’est pas une preuve d’environnement.

## Import DEV confirmé par le résultat utilisateur

Le résultat phpMyAdmin transmis pour `dev_cotton_global_0` confirme MariaDB 10.3.39-MariaDB-log, `server_supported=1` et `table_supported=1`. Les quatre colonnes passent de `ABSENTE` au précontrôle à `CONFORME` après EXECUTE ; statut final `OK_SCHEMA_QR`. Aucune erreur SQL signalée dans la sortie fournie. L’exécution sur la version cible et le contrôle final du schéma sont donc confirmés par cette preuve utilisateur, sans connexion distante de l’agent.

Cela ne prouve pas un deuxième import, une comparaison des données avant/après ni la recette applicative. Réimport sans ALTER testé localement seulement ; recette Hub avec ancien code et contrôles de données encore à réaliser. Le grand QR et ses commandes sont implémentés dans le patch B local ; les colonnes restent inertes pour le code antérieur et A/C/D seul. PROD reste hors périmètre.

## Éléments suffisants retrouvés en documentation

Le [DDL raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/schema/DDL.sql), sections « Structure de la table games_hubs » et « Index pour la table games_hubs », contient la table MyISAM utf8_general_ci et ses index. Preuve locale : DDL.sql lignes 1967–1988 et 4604–4611. Le snapshot est plus ancien que les colonnes DEV de routage/instances et n’est pas assimilé à un export actuel complet.

Les relevés phpMyAdmin fournis par l’utilisateur complètent cette base : MariaDB 10.3.39-MariaDB-log ; MyISAM Dynamic, 189 lignes, données 35 148 octets, index 37 888 octets, utf8_general_ci ; liste complète SHOW FULL COLUMNS, quatre champs QR absents avant import (désormais conformes selon le résultat ci-dessus). Aucun nouvel export utilisateur requis pour cet ajout en fin de table : aucun index ni ancienne colonne n’est modifié. Le script vérifie les métadonnées au moment de l’import. DDL.sql reste un snapshot, pas une déclaration d’application de cette migration.

## Import DEV et contrôles

1. Sélectionner la base DEV dans phpMyAdmin. Sauvegarder la table (structure et données) et vérifier la possibilité de restauration ; garder cette sauvegarde hors dépôt. Prévoir un créneau sans écritures Hub et une seule importation à la fois.
2. Exécuter les lectures ci-dessous. Contrôler la base, MariaDB 10.3.39, table MyISAM et collation. Les quatre colonnes peuvent être absentes ou déjà présentes avec leur définition exacte.
3. Importer le fichier SQL ENTIER via l’onglet Importer. Il nécessite une même connexion pour ses variables de session et PREPARE/EXECUTE. Aucun DELIMITER particulier. Ne pas copier des fragments isolés ni continuer après une erreur SQL sans inspection.
4. Lire les tableaux de contrôle et le statut final. Seul `OK_SCHEMA_QR` avec les quatre lignes `CONFORME` valide le schéma. `DEJA_CONFORME` indique un réimport sans ALTER. `BLOQUE` ou `INCOMPLET` n’est pas un succès, même si phpMyAdmin affiche « requête exécutée avec succès » pour un SELECT de diagnostic.
5. Refaire les lectures, conserver le résultat hors dépôt et vérifier les données précédentes depuis la sauvegarde en tenant compte d’éventuelles écritures concurrentes. Recette ancien code : création/lecture Hub, inscriptions, lancement officiel/démo, retour, panneau droit et QR réduit A/C/D. Les nouvelles colonnes restent inertes.

```sql
SELECT DATABASE() AS selected_database,
       VERSION() AS server_version,
       @@version_comment AS server_distribution,
       @@SESSION.sql_mode AS session_sql_mode;

SHOW CREATE TABLE `games_hubs`;

SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE, ENGINE, ROW_FORMAT,
       TABLE_ROWS AS estimated_rows, DATA_LENGTH AS data_bytes,
       INDEX_LENGTH AS index_bytes, DATA_FREE AS free_bytes,
       TABLE_COLLATION, CREATE_OPTIONS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'games_hubs';

SELECT COLUMN_NAME, ORDINAL_POSITION, COLUMN_TYPE, IS_NULLABLE,
       COLUMN_DEFAULT, CHARACTER_SET_NAME, COLLATION_NAME, EXTRA
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'games_hubs'
  AND COLUMN_NAME IN (
    'player_qr_display_mode', 'player_qr_display_revision',
    'player_qr_display_confirmation_json', 'player_qr_official_started_at'
  )
ORDER BY ORDINAL_POSITION;

SHOW VARIABLES WHERE Variable_name IN (
  'lock_wait_timeout', 'innodb_lock_wait_timeout', 'innodb_page_size'
);
```

Si information_schema retourne zéro ligne alors que SHOW CREATE réussit, refaire la lecture avec le schéma DEV explicitement indiqué pour le diagnostic. Le script capture DATABASE() au début et refusera une table non visible ; ne pas contourner cette garde. TABLE_ROWS est estimatif pour InnoDB, pas un checksum des données.

## SQL exact et rejouabilité

Le script utilise des variables de session `@cotton_qr_*`, information_schema et PREPARE / EXECUTE / DEALLOCATE. Aucune procédure stockée, table auxiliaire, transaction applicative, UPDATE/DELETE, trigger ou événement. Les valeurs initiales sont NULL / 0 / NULL / NULL ; aucun backfill ni déduction de lancement officiel.

| Colonne | Définition |
|---|---|
| player_qr_display_mode | varchar(8) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL |
| player_qr_display_revision | bigint unsigned NOT NULL DEFAULT 0 |
| player_qr_display_confirmation_json | text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL |
| player_qr_official_started_at | datetime NULL DEFAULT NULL |

Avant tout ajout, le script vérifie globalement toutes les colonnes existantes : type/longueur/précision, unsigned sans zerofill, nullabilité, défaut exact, charset/collation, absence d’attribut généré/invisible/auto_increment et d’index QR. Les largeurs d’affichage bigint ne sont pas confondues avec une différence de stockage ; les alias utf8/utf8mb3 sont acceptés. Le littéral texte 'NULL' n’est pas accepté comme un défaut SQL NULL.

Toute incompatibilité neutralise la totalité du DDL et produit les noms des colonnes `INCOMPATIBLE`, puis `BLOQUE`. Ce sont des résultats SELECT explicites, pas un SIGNAL SQL ni une exception : aucune routine ou compatibilité SIGNAL préparé n’est nécessaire. Les erreurs réelles PREPARE/EXECUTE restent des erreurs phpMyAdmin. Une limite group_concat_max_len inférieure à 1024 bloque aussi l’import avant ALTER.

Le SQL généré est visible dans `planned_statement` : `ALTER TABLE <base sélectionnée>.games_hubs WAIT 10 ADD COLUMN …, ALGORITHM=COPY, LOCK=SHARED`, uniquement pour les champs absents, tous regroupés dans une seule instruction. Le nom de base est échappé. Si tous les champs sont conformes, aucun ALTER. Aucun changement de moteur, de collation de table, d’index ou d’ancienne définition.

Après un échec ou une déconnexion, relire le schéma avant réimport. Chaque exécution repart des métadonnées réelles et complète un ajout partiel conforme. Une définition incompatible doit faire l’objet d’une analyse séparée, sans MODIFY automatique. La vérification finale relit le schéma, elle ne se fonde pas seulement sur l’intention d’ALTER.

## Privilèges, attente et retour arrière

Sur la cible MariaDB, ALTER sur games_hubs est nécessaire ; SELECT/visibilité des métadonnées pour les lectures et la recette. La migration ne demande ni CREATE ROUTINE, ni EXECUTE de routine, ni SUPER, ni LOCK TABLES, ni table temporaire. Le compte web n’a pas besoin d’obtenir ALTER pour cette fonctionnalité. Les droits affichés dans SHOW FULL COLUMNS ne prouvent pas le droit ALTER : faire confirmer ce droit par l’administrateur.

La stratégie explicite COPY/SHARED copie la table et bloque les écritures pendant l’opération ; les verrous de métadonnées peuvent aussi attendre/bloquer des accès. WAIT 10 borne l’attente d’acquisition de verrou, pas la durée totale de copie. Aucun SET GLOBAL ni modification persistante de timeout. Le lock_wait_timeout serveur de 86 400 s n’est pas laissé comme budget d’attente de cet ALTER. Les paramètres InnoDB fournis ne décrivent pas cette table MyISAM.

Le faible volume DEV ne garantit ni l’absence de contention ni la durée PROD. Prévoir espace de copie et sauvegarde. Sur MariaDB 10.3, ne pas présumer les garanties d’atomicité DDL des versions récentes : un crash serveur demande une inspection DBA, la rejouabilité traite les états de schéma lisibles et ne répare pas une table endommagée.

ALTER TABLE provoque un commit implicite et ne s’annule pas avec un simple ROLLBACK. Retour arrière prévu : code précédent, colonnes laissées inertes ; aucune suppression automatique. Ne pas restaurer une sauvegarde en écrasant des écritures récentes sans analyse séparée.

## Compatibilité et livraison ultérieure

Audit statique local : Global app_games_hubs_functions.php, INSERT games_hubs vers ligne 2407, liste explicitement ses colonnes ; les nouveaux champs ont des défauts compatibles avec leur omission. L’ensure vers lignes 246–270 ajoute ses colonnes connues sans supprimer les inconnues. Aucun accès QR persistant dans A/C/D. Le test local vérifie aussi un INSERT à anciennes colonnes explicites après ajout. Ce constat n’est pas une certification de tous les consommateurs externes.

Ordre DEV : schéma manuel (import utilisateur confirmé, ne pas rejouer pour livrer B) → recette ancien code → Global rétrocompatible → Games compatible → recette ci-dessous. Livrer ensemble les fichiers Global `web/app/modules/jeux/hubs/app_games_hubs_functions.php` et son nouveau `app_games_hub_player_qr_functions.php`, puis les fichiers Games `web/modules/app_hub_view_helpers.php`, `web/modules/app_hub_remote_ajax.php` et le nouvel asset `web/includes/canvas/core/hub_player_qr.js`. Conserver le reste des patches locaux ; ne pas livrer un helper manquant ou un ancien asset JS avec les nouvelles vues. Aucun restart WS spécifique.

B vérifie les quatre colonnes par SHOW FULL COLUMNS sans DDL et traite chaque échec QR comme optionnel. Ancien Global ou stockage absent/partiel/illisible : QR réduit, nouvelles commandes indisponibles, Hub/polls/lancements préservés. Une panne ne remet pas à zéro le choix enregistré ; il est réconcilié au rétablissement et confirmé à nouveau. Si seule l’écriture QR échoue après succès métier, un reçu de réduction explicite est conservé dans la queue existante et repris à la même révision au poll ; il ne confirme pas l’affichage et n’écrase pas un choix plus récent. Cette reprise nécessite un reçu lisible ; si son écriture échoue aussi, seules les preuves de succès antérieures disponibles peuvent alimenter la première date. Les écritures QR restent des UPDATE limités aux quatre champs et les commandes utilisent la queue existante ; les droits applicatifs SELECT/INSERT/UPDATE existants suffisent, sans ALTER supplémentaire. Les tests locaux couvrent le repli, les pannes et les conflits ; la compatibilité fonctionnelle sur DEV reste à recetter.

Ancien Games avec nouveau Global : les propriétés supplémentaires de contrôle sont ignorées ; sans nouveau navigateur Master, aucune confirmation QR courante et aucune commande QR utilisable. Au passage au nouveau Games, le choix persistant est appliqué et confirmé. Nouveau Games avec ancien Global : gardes function_exists et contrôleur sans état QR conduisent au rendu réduit. Retour arrière : restaurer le code précédent en conservant les colonnes inertes, sans DROP ni ROLLBACK DDL.

PROD : migration globale distincte, à construire depuis son schéma réel et sa version ; inclure tous les prérequis Hub, puis les quatre colonnes QR. Recette sur une copie représentative de PROD avant livraison schéma → Global → Games. Le succès DEV ne valide pas cette future migration globale.

## Tests locaux et recette restante

`python3 specs/tests/hub_player_qr_migration_test.py` crée une base synthétique jetable sous /tmp sur un serveur local sans réseau, avec --no-defaults (aucune configuration/DB distante). Il teste le fichier original et sa garde de version. Si le serveur local diffère de 10.3.39, une copie en mémoire neutralise uniquement cette garde pour tester la sémantique : cela ne vaut pas recette de syntaxe sur 10.3.39.

Résultat local : OK sur MariaDB 10.11.14, garde originale vérifiée puis sémantique testée sur la copie en mémoire décrite ci-dessus.

Matrice : 16 combinaisons de colonnes présentes/absentes et réimports sans ALTER, définitions incompatibles bloquant tous les ajouts, mauvais moteur, base/table absente, limite de concaténation réduite, timeout réel sous verrou puis reprise, compte avec SELECT+ALTER seulement, données anciennes conservées et INSERT ancien code. Aucun test navigateur ni import distant effectué par l’agent ; premier import utilisateur DEV validé ci-dessus. Résultat et version locale consignés dans HANDOFF ; premier import MariaDB 10.3.39/phpMyAdmin confirmé ; réimport sur la cible, confirmation des comportements de verrouillage et de droits sur la version cible, et parcours Hub restent à réaliser en DEV.

## Arrivée réduite et restauration du choix manuel

QR manuel uniquement (consigne du 07/09 remplaçant l’accueil automatique) : arrivée réduite par défaut dans toute fenêtre. `initialize` initialise un mode NULL à reduced et incrémente sa révision, sans lecture de l’historique de lancement ni modification de la première date officielle. Agrandir exige une action explicite Master/Remote ; gardes d’éligibilité, réduction lancement/podium, queue et cadence inchangées.

Le choix expanded est restauré après reload/reconnexion/remplacement seulement si un reçu réussi de commande explicite expanded correspond à la révision persistée. Le reçu peut provenir de l’ancienne instance : il prouve le choix, pas l’affichage actuel. La nouvelle instance doit confirmer son application avec son propre identifiant. Un ancien expanded automatique sans ce reçu reste rendu réduit ; la préférence brute n’est pas effacée. Une réduction ou un lancement incrémente la révision et empêche la restauration depuis l’ancien reçu. Si le journal est indisponible, repli réduit, jamais déduction d’un choix manuel.

Livraison : helper Global puis vue Games, sans nouvelle migration. Carte toujours centrée.

## Recette applicative B sur DEV après livraison coordonnée

1. Hub actif neuf : QR réduit à l’arrivée dans chaque fenêtre. Après clic explicite Agrandir : grand QR toujours centré dans une superposition indépendante, page visible derrière un voile léger, carré intégral noir/blanc et marge blanche ; titre SCANNE POUR JOUER de même force que LOTS DE LA SOIRÉE. Scanner depuis un téléphone à distance de diffusion et vérifier le bon Hub joueur. Sur tablette paysage et écran large, aucun recadrage ni déplacement de la colonne droite.
2. Master : Agrandir/Réduire immédiats même avec réponse retardée, Tab/Échap et restitution du focus ; la persistance reste vérifiée ensuite. Remote : réduire/agrandir, double clic et commandes croisées, pastille/compteur/Programme stables pendant l’attente et notification d’erreur hors hero. Le bouton attend la confirmation réelle de l’écran ; aucune bascule supplémentaire sur retry. Réduire puis recharger les deux pages : le choix reste réduit. Agrandir puis perte réseau/reconnexion et remplacement Master : choix conservé, nouvelle confirmation, ancien onglet inopérant.
3. Lancement officiel réussi (neuf puis reprise) : réduction, aucun retour automatique au grand QR ; ancien agrandissement retardé refusé. Un lancement refusé garde le choix. Démo : réduction mais aucune date de premier officiel. Présenter puis fermer rapidement un podium : pas de réapparition automatique ; agrandissement manuel lorsque permis.
4. Contrôler actif/prospect et compteur 0 → 1 → plusieurs → 0 : deux zones et largeur fixes, classement existant conservé, erreurs sans faux zéro ; prospect sans grand QR/commande active, phrase inchangée. Vérifier Play, papier, retour Remote et exclusivité d’instance.

Validation historique B, avant la consigne finale manuelle (fixture SQL adaptée mais non réexécutée pendant ce correctif ; tests mémoire et JS exécutés) : `python3 web/tests/hub_player_qr_storage_test.py` dans Global (base synthétique locale MariaDB 10.11.14, sans réseau, vrais SQL CAS/queue, absent/partiel/complet, aucune migration rejouée) et `node web/tests/hub_player_qr_test.mjs` dans Games (contrôleur/DOM simulé). Ils ne prouvent ni le scan physique ni le rendu navigateur, ni une recette B sur MariaDB DEV 10.3.39. Les commandes complètes et résultats sont consignés dans l’audit/HANDOFF.

## Preuves et sources

- [README Global raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Update 2026-09-04 - Hub: génération canonique de routage Remote » : séparation de la génération/routage existants. Contrat QR persistant publié : **non trouvé**.
- [DOCS_MANIFEST raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers » et « Routing rules » : préflight AI Studio, HANDOFF, README/TASKS et sitemap/index.
- [Journal AI Studio raw via lecteur](https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb), « DEV : 21-28/08/2026 » et pied « Dernière mise à jour : 28/08/2026 » : HTTP 200 relu, Markdown const raw extrait. Chemins Hub Games/Global concernés : **non trouvé**. Cela ne certifie pas la synchronisation serveur. Si modification externe signalée, recharger/comparer les trois helpers Games app_hub_view_helpers.php, app_hub_remote_ajax.php, app_hub_master_ajax.php et Global app_games_hubs_functions.php en préservant A/C/D.
- [MySQL 8.0 ALTER TABLE](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html), « Privileges » et « Performance and Space Requirements » ; [commits implicites](https://dev.mysql.com/doc/refman/8.0/en/implicit-commit.html).
- [MariaDB ALTER TABLE](https://mariadb.com/docs/server/reference/sql-statements/data-definition/alter/alter-table), « Privileges », « Algorithm », « LOCK » ; [PREPARE](https://mariadb.com/docs/server/reference/sql-statements/prepared-statements/prepare-statement), « Permitted statements ». Références générales ; cible DEV MariaDB 10.3.39 ; compatibilité PROD non établie.

- [MariaDB WAIT/NOWAIT](https://mariadb.com/docs/server/reference/sql-statements/transactions/wait-and-nowait), « Syntax » ; [COLUMNS](https://mariadb.com/docs/server/reference/system-tables/information-schema/information-schema-tables/information-schema-columns-table), « COLUMN_DEFAULT » : SQL de contrôle et distinction défaut NULL/littéral.
