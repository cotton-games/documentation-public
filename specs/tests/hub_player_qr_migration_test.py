"""Run against a disposable local MariaDB socket only; never read client config.
The shipped version guard is tested first. On a different local version, only
that guard is substituted in a test copy to exercise DDL/validation semantics.
This is not a substitute for acceptance on DEV MariaDB 10.3.39/phpMyAdmin.
"""
import itertools
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[2]
SQL = (ROOT / 'migrations/hub_player_qr_dev.sql').read_text()
DDL = (ROOT / 'canon/data/schema/DDL.sql').read_text()
BASE = re.search(r'CREATE TABLE `games_hubs` \(.*?;', DDL, re.S).group()
INDEXES = re.search(r'ALTER TABLE `games_hubs`\s+ADD PRIMARY KEY.*?;', DDL, re.S).group()
DEFS = [
    '`player_qr_display_mode` varchar(8) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL',
    '`player_qr_display_revision` bigint unsigned NOT NULL DEFAULT 0',
    '`player_qr_display_confirmation_json` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL',
    '`player_qr_official_started_at` datetime NULL DEFAULT NULL',
]
SERVER = shutil.which('mariadbd') or '/usr/sbin/mariadbd'
for binary in ('mariadb', 'mariadb-install-db', SERVER):
    if not shutil.which(binary):
        raise SystemExit(f'Missing local test dependency: {binary}')

with tempfile.TemporaryDirectory(prefix='cotton-qr-test-', dir='/tmp') as tmp:
    tmp = Path(tmp)
    sock = str(tmp / 'server.sock')
    subprocess.run(['mariadb-install-db', '--no-defaults', f'--datadir={tmp / "data"}',
                    '--auth-root-authentication-method=normal', '--skip-test-db'],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    server = subprocess.Popen([SERVER, '--no-defaults', f'--datadir={tmp / "data"}',
                               f'--socket={sock}', f'--pid-file={tmp / "server.pid"}',
                               f'--log-error={tmp / "server.log"}', '--skip-networking',
                               f'--user={__import__("getpass").getuser()}'],
                              stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    client = ['mariadb', '--no-defaults', '--protocol=socket', f'--socket={sock}',
              '-uroot', '--batch', '--skip-column-names']

    def query(sql, database=True):
        result = subprocess.run(client + (['qr_fixture'] if database else []),
                                input=sql, text=True, capture_output=True, timeout=25)
        if result.returncode:
            raise AssertionError(result.stderr)
        return result.stdout

    def reset(definitions=()):
        query('DROP TABLE IF EXISTS games_hubs; ' + BASE + INDEXES)
        if definitions:
            query('ALTER TABLE games_hubs ' + ', '.join('ADD COLUMN ' + x for x in definitions))
        query("INSERT INTO games_hubs (id,id_securite,id_client,hub_date,date_ajout) "
              "VALUES (1,'fixture',42,'2026-09-07','2026-09-07 12:00:00');")

    def count_qr():
        return int(query("SELECT COUNT(*) FROM information_schema.COLUMNS "
                         "WHERE TABLE_SCHEMA='qr_fixture' AND TABLE_NAME='games_hubs' "
                         "AND COLUMN_NAME LIKE 'player_qr_%';"))

    try:
        for _ in range(150):
            if server.poll() is not None:
                raise AssertionError((tmp / 'server.log').read_text())
            try:
                version = query('SELECT VERSION();', False).strip()
                break
            except AssertionError:
                time.sleep(0.1)
        else:
            raise AssertionError('Local fixture server did not start')
        query('CREATE DATABASE qr_fixture CHARACTER SET utf8 COLLATE utf8_general_ci;', False)
        reset()
        target = version.startswith('10.3.39-MariaDB')
        original = query(SQL)
        assert ('OK_SCHEMA_QR' if target else 'BLOQUE') in original
        assert count_qr() == (4 if target else 0)
        fixture_sql = SQL if target else SQL.replace("VERSION() LIKE '10.3.39-MariaDB%'", '1 /* local semantic fixture only */')
        assert fixture_sql != SQL or target
        old_cols = re.findall(r'^\s*`([^`]+)`', BASE, re.M)
        select_old = 'SELECT ' + ','.join('`' + x + '`' for x in old_cols) + ' FROM games_hubs ORDER BY id;'
        for mask in itertools.product((False, True), repeat=4):
            reset([d for d, present in zip(DEFS, mask) if present])
            before = query(select_old)
            first = query(fixture_sql)
            assert 'OK_SCHEMA_QR' in first and count_qr() == 4
            assert query(select_old) == before
            assert query('SELECT player_qr_display_mode IS NULL,player_qr_display_revision,'
                         'player_qr_display_confirmation_json IS NULL,player_qr_official_started_at IS NULL '
                         'FROM games_hubs;').strip() == '1\t0\t1\t1'
            second = query(fixture_sql)
            assert 'DEJA_CONFORME' in second and 'ALTER TABLE `' not in second
            assert query(select_old) == before
        # Incompatible columns must block ALL missing additions, not just themselves.
        bad_defs = [DEFS[0].replace('varchar(8)', 'varchar(9)'),
                    DEFS[0].replace('DEFAULT NULL', "DEFAULT 'NULL'"),
                    DEFS[0].replace('utf8_general_ci', 'utf8_bin'),
                    DEFS[1].replace(' unsigned', ''),
                    DEFS[1].replace('DEFAULT 0', 'DEFAULT 1'),
                    DEFS[1].replace('NOT NULL', 'NULL'),
                    DEFS[1].replace('DEFAULT 0', 'DEFAULT 0 UNIQUE'),
                    DEFS[2].replace(' text ', ' longtext '),
                    DEFS[3].replace('datetime', 'datetime(6)'),
                    '`player_qr_display_revision` bigint unsigned AS (id + 1) VIRTUAL']
        for bad in bad_defs:
            reset([bad])
            before = query('SHOW CREATE TABLE games_hubs;')
            out = query(fixture_sql)
            assert 'INCOMPATIBLE' in out and 'BLOQUE' in out and 'OK_SCHEMA_QR' not in out
            assert count_qr() == 1 and query('SHOW CREATE TABLE games_hubs;') == before
        reset()
        query('ALTER TABLE games_hubs ENGINE=InnoDB;')
        assert 'BLOQUE' in query(fixture_sql) and count_qr() == 0
        reset()
        assert 'BLOQUE' in query('SET SESSION group_concat_max_len=100;\n' + fixture_sql)
        assert count_qr() == 0
        assert 'BLOQUE' in query(fixture_sql, False)
        query('DROP TABLE games_hubs;')
        assert 'BLOQUE' in query(fixture_sql)
        # A metadata/table lock expires cleanly, then the same file is resumable.
        reset()
        holder = subprocess.Popen(client + ['--unbuffered', 'qr_fixture'],
                                  stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE, text=True)
        try:
            holder.stdin.write('LOCK TABLES games_hubs READ; SELECT CONNECTION_ID(); DO SLEEP(60);')
            holder.stdin.close()
            connection_id = int(holder.stdout.readline().strip())
            started = time.monotonic()
            try:
                query(fixture_sql)
                raise AssertionError('Expected lock timeout')
            except AssertionError as error:
                assert '1205' in str(error), str(error)
            assert time.monotonic() - started < 20
            assert count_qr() == 0
        finally:
            if 'connection_id' in locals():
                query(f'KILL CONNECTION {connection_id};', False)
            holder.wait(timeout=5)
        assert 'OK_SCHEMA_QR' in query(fixture_sql)
        # Only SELECT + ALTER: no CREATE ROUTINE, CREATE, INSERT or SUPER grant.
        reset()
        query("CREATE USER 'qr_operator'@'localhost'; "
              "GRANT SELECT, ALTER ON qr_fixture.* TO 'qr_operator'@'localhost';", False)
        client[client.index('-uroot')] = '-uqr_operator'
        try:
            assert 'OK_SCHEMA_QR' in query(fixture_sql)
        finally:
            client[client.index('-uqr_operator')] = '-uroot'
        # Pre-existing application can still omit all QR fields on INSERT.
        reset()
        query(fixture_sql)
        query("INSERT INTO games_hubs (id,id_securite,id_client,hub_date,date_ajout) "
              "VALUES (2,'old-code',43,'2026-09-07','2026-09-07 12:00:00');")
        assert query('SELECT player_qr_display_revision FROM games_hubs WHERE id=2;').strip() == '0'
        print(f'OK local {version}: version guard, 16 partial states + replays, '
              '10 incompatibilities, wrong engine/database/table/limit, lock timeout/retry, '
              'SELECT+ALTER privileges, old INSERT and data preserved.')
        print('DEV 10.3.39/phpMyAdmin acceptance still required.' if not target else 'Target server version tested locally.')
    finally:
        server.terminate()
        try:
            server.wait(timeout=15)
        except subprocess.TimeoutExpired:
            server.kill()
            server.wait()
