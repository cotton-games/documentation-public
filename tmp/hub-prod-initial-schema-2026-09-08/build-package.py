#!/usr/bin/env python3
"""Generate reviewed schema-only artifacts from the audited contract. No DB access."""
import json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
DB='prod_cotton_global_0'
contracts=json.loads((HERE/'schema-contract.json').read_text())
assert len(contracts)==13
q=lambda v: 'NULL' if v is None else "'"+str(v).replace("'","''")+"'"
def relation(name,fields,rows):
    return name+'('+','.join(fields)+') AS (\n'+ '\nUNION ALL\n'.join('SELECT '+', '.join(q(x) if not isinstance(x,int) else str(x) for x in r) for r in rows)+'\n)'
reasons={
'games_hubs':'Identité/contexte, routing/intent/transition, activation, présentation, instances, lots, suppression et QR (4 champs dédiés).',
'games_hubs_sessions':'Membership canonique explicite Hub/session, unicité du couple et état.',
'games_hubs_players':'Identités Hub, roster, photo active et dix agrégats stats persistés.',
'games_hubs_players_sessions':'Mapping joueur/session, identité runtime et cycle accès incluant left.',
'games_hubs_participations_probables':'Déclaration probable Hub distincte du roster et des participations legacy.',
'games_hubs_publication':'Publication éditoriale et informations pratiques du Hub.',
'games_hubs_prizes':'Lots globaux par rang, indépendants des lots session historiques.',
'games_hubs_remote_access':'Accès Remote, tokens et révocation.',
'games_hubs_remote_master_presence':'Présence/lease Master et révisions appliquées.',
'games_hubs_remote_runtime_presence':'Présence runtime corrélée à session/exécution/instance.',
'games_hubs_remote_commands':'Queue Remote, idempotence, claim, résultat et reçus QR.',
'programming_quick_operations':'Prérequis associé Quick Schedule : commande idempotente, étapes de reprise, Hub/session et résultat.',
'programming_quick_series_operations':'Prérequis associé Quick Schedule récurrent : template, occurrences, thèmes et résultat.'}
ddl=['-- Phase 1 Hub PROD : 13 nouvelles tables, aucune donnée métier.','-- Cible explicite : '+DB+' ; MariaDB 10.3.39.','-- PRECHECK fourni et analysé ; sauvegarde requise avant exécution opérateur.','-- InnoDB / utf8 / utf8_general_ci explicitement choisis, indépendants du défaut latin1 de la base.','-- Lire README : IF NOT EXISTS ne valide pas un objet déjà présent.','-- Arrêter sur erreur ; ne rejouer aucune migration historique après ce fichier.','-- Aucun ALTER legacy, INSERT, trigger, routine, événement ni conversion de table existante.','']
for step,(table,c) in enumerate(contracts.items(),1):
    source='documentation/'+table+'_phpmyadmin.sql' if table.startswith('programming_') else 'global/web/app/modules/jeux/hubs/app_games_hubs_functions.php::app_games_hub_schema_ensure'
    ddl += [f'-- Étape {step:02d}/13 : {table}', '-- Objet : '+reasons[table],'-- Source : '+source,'-- Compléments/lecteurs/writers : INVENTAIRE.md, schema-contract.json et sql-evidence.json.','-- Dépendances : références logiques uniquement ; aucune FK vers le legacy.']
    if table=='games_hubs':ddl+=['-- QR : app_games_hub_player_qr_functions.php::app_games_hub_player_qr_schema_check.']
    if table=='games_hubs_players':ddl+=['-- Stats : migration 2026-07-30 + app_games_hub_players_stats_columns/_rebuild ; photo : ensure courant.']
    ddl += [f"SELECT '{step:02d}/13 {table} BEGIN' AS ddl_step;",f'CREATE TABLE IF NOT EXISTS `{DB}`.`{table}` (',',\n'.join('  `'+x['name']+'` '+x['definition'] for x in c['columns'])+',',',\n'.join('  '+x for x in c['indexes']),') ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;','SHOW WARNINGS;',f"SELECT '{step:02d}/13 {table} END - contrôler WARNINGS et POSTCHECK' AS ddl_step;",'']
ddl+=["SELECT 'DDL terminé : exécuter 02-POSTCHECK-SCHEMA.sql ; aucun backfill/code maintenant' AS next_step;"]
(HERE/'01-DDL-HUB-PROD.sql').write_text('\n'.join(ddl)+'\n')
cols=[]; indexes=[]; constraints=[]
for table,c in contracts.items():
    for ordinal,col in enumerate(c['columns'],1):
        d=col['definition']; typ=re.split(r'\s+(?:NOT NULL|NULL|DEFAULT|AUTO_INCREMENT)',d,1)[0].lower()
        nullable='NO' if 'NOT NULL' in d else 'YES'
        m=re.search(r"\bDEFAULT\s+('(?:[^']|'')*'|\S+)",d)
        # MariaDB >=10.2.7 COLUMN_DEFAULT quotes text literals and represents nullable SQL NULL as 'NULL'.
        default=m[1] if m else ('NULL' if nullable=='YES' else None)
        extra='auto_increment' if 'AUTO_INCREMENT' in d else ''
        istext=bool(re.match(r'(?:var)?char|(?:medium|long|tiny)?text|enum',typ))
        cols.append([table,col['name'],ordinal,typ,nullable,default,extra,'utf8' if istext else None,'utf8_general_ci' if istext else None])
    for idx in c['indexes']:
        primary=idx.startswith('PRIMARY'); unique=primary or idx.startswith('UNIQUE'); name='PRIMARY' if primary else re.search(r'`([^`]+)`',idx)[1]
        names=re.findall(r'`([^`]+)`',idx[idx.index('('):])
        for ordinal,col in enumerate(names,1):indexes.append([table,name,0 if unique else 1,ordinal,col])
        if unique:constraints.append([table,name,'PRIMARY KEY' if primary else 'UNIQUE'])
cte='WITH\n'+',\n'.join([
relation('expected_tables',['table_name'],[[t] for t in contracts]),
relation('expected_columns',['table_name','column_name','ordinal_position','column_type','is_nullable','column_default','extra','character_set_name','collation_name'],cols),
relation('expected_indexes',['table_name','index_name','non_unique','seq_in_index','column_name'],indexes),
relation('expected_constraints',['table_name','constraint_name','constraint_type'],constraints),
f"actual_tables AS (SELECT * FROM information_schema.TABLES WHERE TABLE_SCHEMA = '{DB}' AND TABLE_NAME IN (SELECT table_name FROM expected_tables))",
f"actual_columns AS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = '{DB}' AND TABLE_NAME IN (SELECT table_name FROM expected_tables))",
f"actual_indexes AS (SELECT * FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = '{DB}' AND TABLE_NAME IN (SELECT table_name FROM expected_tables))",
f"actual_constraints AS (SELECT * FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = '{DB}' AND TABLE_NAME IN (SELECT table_name FROM expected_tables))",
"""issues AS (
SELECT e.table_name AS object_name, 'TABLE_ABSENTE_OU_ENGINE_COLLATION_TYPE' AS problem
FROM expected_tables e LEFT JOIN actual_tables a ON a.TABLE_NAME=e.table_name
WHERE a.TABLE_NAME IS NULL OR a.TABLE_TYPE <> 'BASE TABLE' OR a.ENGINE <> 'InnoDB'
   OR REPLACE(a.TABLE_COLLATION,'utf8mb3','utf8') <> 'utf8_general_ci'
UNION ALL
SELECT CONCAT(e.table_name,'.',e.column_name), 'COLONNE_ABSENTE_OU_DEFINITION'
FROM expected_columns e LEFT JOIN actual_columns a ON a.TABLE_NAME=e.table_name AND a.COLUMN_NAME=e.column_name
WHERE a.COLUMN_NAME IS NULL OR a.ORDINAL_POSITION <> e.ordinal_position
   OR NOT (BINARY a.COLUMN_TYPE <=> BINARY e.column_type)
   OR NOT (a.IS_NULLABLE <=> e.is_nullable)
   OR NOT (BINARY a.COLUMN_DEFAULT <=> BINARY e.column_default)
   OR NOT (BINARY a.EXTRA <=> BINARY e.extra)
   OR NOT (REPLACE(a.CHARACTER_SET_NAME,'utf8mb3','utf8') <=> e.character_set_name)
   OR NOT (REPLACE(a.COLLATION_NAME,'utf8mb3','utf8') <=> e.collation_name)
UNION ALL
SELECT CONCAT(a.TABLE_NAME,'.',a.COLUMN_NAME), 'COLONNE_INATTENDUE'
FROM actual_columns a LEFT JOIN expected_columns e ON a.TABLE_NAME=e.table_name AND a.COLUMN_NAME=e.column_name
WHERE e.column_name IS NULL
UNION ALL
SELECT CONCAT(e.table_name,'.',e.index_name,'#',e.seq_in_index), 'INDEX_ABSENT_OU_DEFINITION'
FROM expected_indexes e LEFT JOIN actual_indexes a ON a.TABLE_NAME=e.table_name AND a.INDEX_NAME=e.index_name AND a.SEQ_IN_INDEX=e.seq_in_index
WHERE a.INDEX_NAME IS NULL OR a.NON_UNIQUE<>e.non_unique OR a.COLUMN_NAME<>e.column_name
   OR a.SUB_PART IS NOT NULL OR a.INDEX_TYPE<>'BTREE' OR NOT(a.COLLATION <=> 'A')
UNION ALL
SELECT CONCAT(a.TABLE_NAME,'.',a.INDEX_NAME,'#',a.SEQ_IN_INDEX), 'INDEX_INATTENDU'
FROM actual_indexes a LEFT JOIN expected_indexes e ON a.TABLE_NAME=e.table_name AND a.INDEX_NAME=e.index_name AND a.SEQ_IN_INDEX=e.seq_in_index
WHERE e.index_name IS NULL
UNION ALL
SELECT CONCAT(e.table_name,'.',e.constraint_name), 'CONTRAINTE_ABSENTE_OU_TYPE'
FROM expected_constraints e LEFT JOIN actual_constraints a ON a.TABLE_NAME=e.table_name AND a.CONSTRAINT_NAME=e.constraint_name
WHERE a.CONSTRAINT_NAME IS NULL OR a.CONSTRAINT_TYPE<>e.constraint_type
UNION ALL
SELECT CONCAT(a.TABLE_NAME,'.',a.CONSTRAINT_NAME), 'CONTRAINTE_INATTENDUE'
FROM actual_constraints a LEFT JOIN expected_constraints e ON a.TABLE_NAME=e.table_name AND a.CONSTRAINT_NAME=e.constraint_name
WHERE e.constraint_name IS NULL
UNION ALL
SELECT CONCAT(EVENT_OBJECT_TABLE,'.',TRIGGER_NAME), 'TRIGGER_INATTENDU'
FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'prod_cotton_global_0'
UNION ALL
SELECT TABLE_NAME, 'TABLE_HUB_INATTENDUE'
FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'prod_cotton_global_0'
AND LEFT(TABLE_NAME,10)='games_hubs' AND TABLE_NAME NOT IN (SELECT table_name FROM expected_tables)
)"""
])+'\n'
post=['-- READ-ONLY pour les données et le schéma. Variables de session + PREPARE d\'un SELECT uniquement.','-- Exécuter le fichier entier dans la même session phpMyAdmin. Aucun DDL/DML/routine/table temporaire.','-- Le SELECT de comptage exact n\'est préparé que si toutes les structures sont conformes.','-- Une erreur SQL invalide toute validation ; le seul verdict final est SCHEMA_READY_FOR_BACKFILL.','-- Les alias utf8mb3/utf8 des versions de test sont équivalents ; types, valeurs et défauts restent exacts.','SET @cotton_hub_schema_issues = NULL;',cte+'SELECT COUNT(*) INTO @cotton_hub_schema_issues FROM issues;',"SELECT @cotton_hub_schema_issues AS SCHEMA_ISSUE_COUNT;",cte+'SELECT object_name, problem FROM issues ORDER BY object_name, problem;']
counts=' UNION ALL '.join('SELECT '+q(t)+' AS table_name, COUNT(*) AS row_count FROM `'+DB+'`.`'+t+'`' for t in contracts)
countsql="WITH counts AS ("+counts+") SELECT table_name, row_count, '-' AS SCHEMA_READY_FOR_BACKFILL FROM counts UNION ALL SELECT '#TOTAL_13_TABLES', SUM(row_count), IF(SUM(row_count)=0,'YES','NO') FROM counts"
post += ["-- Aucun nom fourni par l'utilisateur : deux chaînes SELECT fixes, aucun DDL dynamique.","SET @cotton_hub_count_sql = IF(@cotton_hub_schema_issues = 0,\n"+q(countsql)+",\n"+q("SELECT 'NO' AS SCHEMA_READY_FOR_BACKFILL, 'Structure non conforme ou contrôle incomplet ; comptages non exécutés' AS reason")+");",'PREPARE cotton_hub_count_stmt FROM @cotton_hub_count_sql;','EXECUTE cotton_hub_count_stmt;','DEALLOCATE PREPARE cotton_hub_count_stmt;']
(HERE/'02-POSTCHECK-SCHEMA.sql').write_text('\n\n'.join(post)+'\n')
print('Generated:',len(contracts),'tables,',len(cols),'columns,',len(indexes),'index components.')
