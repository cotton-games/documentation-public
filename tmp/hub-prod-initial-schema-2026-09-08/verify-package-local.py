#!/usr/bin/env python3
"""Only creates a disposable local MariaDB with a private socket, no network/config.
No connection parameters can be supplied. Never contacts an existing database.
"""
import json, pathlib, re, subprocess, tempfile, time
HERE=pathlib.Path(__file__).resolve().parent
ROOT=HERE.parents[2]
DB='prod_cotton_global_0'
ddl=(HERE/'01-DDL-HUB-PROD.sql').read_text(); post=(HERE/'02-POSTCHECK-SCHEMA.sql').read_text()
creates=re.findall(r'CREATE TABLE IF NOT EXISTS .*?;',ddl,re.S)
assert len(creates)==13
work=pathlib.Path(tempfile.mkdtemp(prefix='cotton-hub-pack-test-'))
subprocess.run(['mariadb-install-db','--no-defaults','--datadir='+str(work/'data'),'--auth-root-authentication-method=normal','--skip-test-db'],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
log=open(work/'server.log','w')
server=subprocess.Popen(['/usr/sbin/mariadbd','--no-defaults','--datadir='+str(work/'data'),'--socket='+str(work/'s.sock'),'--pid-file='+str(work/'s.pid'),'--skip-networking','--log-error='+str(work/'error.log')],stdout=log,stderr=log)
cmd=['mariadb','--no-defaults','--protocol=SOCKET','--socket='+str(work/'s.sock'),'-u','root','--batch','--raw']
def sql(s):
    r=subprocess.run(cmd,input="SET SESSION sql_mode='';\n"+s,text=True,capture_output=True)
    if r.returncode:raise RuntimeError(r.stderr+'\n'+r.stdout[-1800:])
    return r.stdout

def reset():
    sql(f'DROP DATABASE IF EXISTS `{DB}`; CREATE DATABASE `{DB}` CHARACTER SET latin1 COLLATE latin1_swedish_ci;')

def verify(expected,label):
    result=sql(post)
    (work/'last-postcheck.txt').write_text(result)
    actual='YES' if '#TOTAL_13_TABLES\t0\tYES' in result else 'NO'
    assert actual==expected, label+'\n'+result[:8000]
    if expected=='NO':assert re.search(r'(?:^NO\t|\tNO$)',result,re.M),result
    print('PASS',label,actual,flush=True)

try:
    for _ in range(150):
        if (work/'s.sock').exists():break
        if server.poll() is not None:raise RuntimeError((work/'error.log').read_text())
        time.sleep(.1)
    print(sql('SELECT VERSION();').strip(),flush=True)
    reset();verify('NO','base sans Hub')
    sql(ddl);verify('YES','première installation')
    before=sql(f"SELECT TABLE_NAME,COLUMN_NAME,COLUMN_TYPE,COLUMN_DEFAULT,IS_NULLABLE,EXTRA FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='{DB}' ORDER BY TABLE_NAME,ORDINAL_POSITION;")
    sql(ddl);verify('YES','relance')
    assert before==sql(f"SELECT TABLE_NAME,COLUMN_NAME,COLUMN_TYPE,COLUMN_DEFAULT,IS_NULLABLE,EXTRA FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='{DB}' ORDER BY TABLE_NAME,ORDINAL_POSITION;")
    # Actual PHP helper against actual generated schema, proxy only counts DDL.
    php=r'''<?php
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
class SchemaAuditProxy {
 public $db; public $ddl=0;
 function __construct($socket) { $this->db=new mysqli('localhost','root','','prod_cotton_global_0',0,$socket); }
 function real_escape_string($s) { return $this->db->real_escape_string($s); }
 function query($s) { if(preg_match('/^\s*(CREATE|ALTER)\s/i',$s)) $this->ddl++; return $this->db->query($s); }
}
$GLOBALS['mysqli']=new SchemaAuditProxy($argv[1]);
require $argv[2].'/global/web/app/modules/jeux/hubs/app_games_hubs_functions.php';
require $argv[2].'/global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php';
app_games_hub_schema_ensure(); app_games_hub_schema_ensure();
if($GLOBALS['mysqli']->ddl!==0 || !app_games_hub_players_stats_schema_ready() || empty(app_games_hub_player_qr_schema_check()['ok']) || !app_programming_quick_idempotency_schema_ensure() || !app_programming_quick_series_schema_ensure()) exit(1);
require $argv[2].'/games/web/includes/canvas/php/blindtest_adapter_glue.php';
$pdo=new PDO('mysql:unix_socket='.$argv[1].';dbname=prod_cotton_global_0','root','',array(PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION));
$get=blindtest_api_session_teams_get($pdo,array('sessionPrimaryId'=>1));
$save=_bt_persist_session_teams($pdo,'test',array());
if(empty($get['ok']) || $get['teams']!==array() || empty($save['ok']) || $save['reason']!=='TABLE_MISSING') exit(2);
echo "PASS real helper: 0 DDL, QR/stats/Quick conformes ; table équipes absente gérée en lecture/écriture.\n";
'''
    (work/'probe.php').write_text(php)
    subprocess.run(['php',str(work/'probe.php'),str(work/'s.sock'),str(ROOT)],check=True)
    # Interrupted sequence, then full safe replay.
    reset();sql('\n'.join(creates[:6]));verify('NO','interruption après 6 tables');sql(ddl);verify('YES','reprise complète')
    # Ensure legacy rows/structure stay byte-identical under the package.
    sql(f"CREATE TABLE `{DB}`.championnats_sessions (id int PRIMARY KEY, marker varchar(20)) ENGINE=MyISAM; INSERT INTO `{DB}`.championnats_sessions VALUES (1,'legacy');")
    before=sql(f'SHOW CREATE TABLE `{DB}`.championnats_sessions; SELECT * FROM `{DB}`.championnats_sessions;')
    sql(ddl)
    assert before==sql(f'SHOW CREATE TABLE `{DB}`.championnats_sessions; SELECT * FROM `{DB}`.championnats_sessions;')
    verify('YES','legacy intact et tables nouvelles vides')
    mutations=[
      ('QR default',"ALTER TABLE games_hubs MODIFY player_qr_display_revision bigint(20) unsigned NOT NULL DEFAULT 1"),
      ('QR enum/type',"ALTER TABLE games_hubs MODIFY player_qr_display_mode varchar(9) NULL DEFAULT NULL"),
      ('stats absente',"ALTER TABLE games_hubs_players DROP COLUMN stats_error"),
      ('nullabilité',"ALTER TABLE games_hubs MODIFY active_session_id int(10) unsigned NULL DEFAULT 0"),
      ('enum status',"ALTER TABLE games_hubs_players_sessions MODIFY status enum('created','active','completed','failed') NOT NULL DEFAULT 'created'"),
      ('unique absente',"ALTER TABLE games_hubs DROP INDEX uniq_games_hubs_token"),
      ('index ordre',"ALTER TABLE games_hubs DROP INDEX idx_games_hubs_client_date, ADD KEY idx_games_hubs_client_date(hub_date,id_client)"),
      ('engine',"ALTER TABLE games_hubs ENGINE=MyISAM"),
      ('collation',"ALTER TABLE games_hubs DEFAULT COLLATE utf8_bin"),
      ('colonne inattendue',"ALTER TABLE games_hubs ADD COLUMN unexpected int"),
      ('index inattendu',"ALTER TABLE games_hubs ADD INDEX unexpected (hub_status)"),
      ('trigger',"CREATE TRIGGER hub_unexpected BEFORE INSERT ON games_hubs FOR EACH ROW SET NEW.hub_label='unexpected'"),
      ('table Quick absente',"DROP TABLE programming_quick_series_operations"),
      ('Hub non vide',"INSERT INTO games_hubs (id_securite,hub_date,date_ajout) VALUES ('test','2026-09-08',NOW())"),
      ('Quick non vide',"INSERT INTO programming_quick_operations (created_at,updated_at,expires_at) VALUES (NOW(),NOW(),NOW())")]
    for label,mutation in mutations:
        reset();sql(ddl);sql('USE `'+DB+'`; '+mutation+';');verify('NO',label)
    reset();sql(ddl);verify('YES','état final reconstitué')
    print('PASS : tests réels sur serveur isolé ; aucune certification 10.3 par ce test 10.11.',flush=True)
finally:
    server.terminate();server.wait(timeout=20);log.close()
    print('Serveur isolé arrêté. Traces :',work,flush=True)
