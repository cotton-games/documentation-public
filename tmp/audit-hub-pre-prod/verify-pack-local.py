"""Validation du pack sur fixture jetable /tmp, socket local sans reseau/config."""
import getpass,re,subprocess,tempfile,time
from pathlib import Path
ROOT=Path('/home/romain/Cotton'); PACK=Path(__file__).parent
with tempfile.TemporaryDirectory(prefix='cotton-hub-audit-db-',dir='/tmp') as directory:
 p=Path(directory);sock=str(p/'mysql.sock')
 subprocess.run(['mariadb-install-db','--no-defaults',f'--datadir={p}/data','--auth-root-authentication-method=normal','--skip-test-db'],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
 server=subprocess.Popen(['/usr/sbin/mariadbd','--no-defaults',f'--datadir={p}/data',f'--socket={sock}',f'--pid-file={p}/pid',f'--log-error={p}/error','--skip-networking',f'--user={getpass.getuser()}'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 client=['mariadb','--no-defaults','--protocol=socket',f'--socket={sock}','-uroot','--batch','--skip-column-names']
 def q(sql,db=True):
  r=subprocess.run(client+(['audit_fixture'] if db else []),input=sql,capture_output=True,text=True,timeout=30)
  if r.returncode:raise RuntimeError(r.stderr)
  return r.stdout
 try:
  for _ in range(100):
   try:version=q('SELECT VERSION();',False).strip();break
   except RuntimeError:time.sleep(.1)
  else:raise RuntimeError('fixture startup failed')
  q('CREATE DATABASE audit_fixture;',False)
  ddl=(ROOT/'documentation/canon/data/schema/DDL.sql').read_text()
  for t in ['championnats_sessions','clients','ecommerce_offres_to_clients','operations_evenements','championnats_sessions_participations_probables','quizs','jeux_bingo_musical_playlists_clients','jeux_bingo_musical_playlists']:
   q(re.search(r'CREATE TABLE `'+t+r'` \(.*?;',ddl,re.S)[0])
  php=(ROOT/'global/web/app/modules/jeux/hubs/app_games_hubs_functions.php').read_text()
  for m in re.finditer(r'CREATE TABLE IF NOT EXISTS `games_hubs[^`]*` \(.*?\) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci',php,re.S):q(m[0]+';')
  q("SET sql_mode=''; INSERT INTO championnats_sessions (id,id_client,date,flag_session_demo,flag_configuration_complete,id_type_produit,id_operation_evenement,id_offre_client) VALUES (1,7,'2026-09-10',0,1,5,0,0),(2,7,'2026-09-10',0,1,4,8,12),(3,8,'2026-09-11',0,0,6,0,0),(4,8,'2026-09-11',1,1,5,0,0);")
  q("INSERT INTO games_hubs (id,id_securite,id_client,hub_date,context_type,id_operation_evenement,date_ajout) VALUES (1,'test-a',7,'2026-09-10','soiree',0,NOW()),(2,'test-b',7,'2026-09-10','event',8,NOW()); INSERT INTO games_hubs_sessions (id_hub,id_session,created_at) VALUES (1,1,NOW());")
  logs=[f'Local MariaDB {version}. Pas une validation MariaDB PROD 10.3.39.']
  for name in ['00-schema-readonly.sql','01-parc-readonly.sql','02-couverture-readonly.sql','03-pre-post-readonly.sql']:
   sql=(PACK/name).read_text();clean=re.sub(r'--[^\n]*','',sql)
   assert all(re.match(r'\s*(SELECT|SHOW)\b',x,re.I) for x in re.sub(r"'(?:''|[^'])*'", "''", clean).split(';') if x.strip()),name
   result=q(sql);logs.append(f'{name}: SQL execute sans erreur, {len(result.splitlines())} lignes fixture.')
  # Les variantes PHP et SQL sont comptees distinctement, sans choisir un Hub.
  assert q("SELECT COUNT(*) FROM games_hubs WHERE id_client=7 AND hub_date='2026-09-10' AND flag_active=1 AND hub_status<>'deleting';").strip()=='2'
  assert q("SELECT COUNT(*) FROM games_hubs WHERE id_client=7 AND hub_date='2026-09-10' AND flag_active=1 AND (id_operation_evenement=0 OR id_operation_evenement=0);").strip()=='1'
  logs.append('Fixture : 2 candidats jour contre 1 candidat SQL pour operation 0 ; cas distingue.')
  (PACK/'validation-sql.txt').write_text('\n'.join(logs)+'\n');print('\n'.join(logs))
 finally:
  server.terminate()
  try:server.wait(timeout=10)
  except subprocess.TimeoutExpired:server.kill();server.wait()
