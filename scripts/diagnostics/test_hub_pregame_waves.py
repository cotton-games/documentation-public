import importlib.util
import json
import re
import sqlite3
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('waves', HERE / 'hub-pregame-waves.py')
waves = importlib.util.module_from_spec(spec)
spec.loader.exec_module(waves)


class WaveTests(unittest.TestCase):
    def test_pause_then_packet_and_unknown_start(self):
        arrivals = [(i*10, i+1) for i in range(20)] + [(7000+i*10, 21+i) for i in range(30)]
        out = waves.summarize(arrivals)
        self.assertEqual(out['packets_separated_by_5s'], [20, 30])
        self.assertEqual(out['pauses_ge_5s'][0]['subsequent_identities'], 30)
        self.assertIsNone(out['after_boundary'])
        self.assertEqual(waves.summarize(arrivals, 6000)['after_boundary'], 30)

    def test_telemetry_rotations_and_reconnects(self):
        def row(stage, timestamp, **extra):
            return {'evt': 'HUB_PREGAME_WAVE', 'meta': dict(event='hub_pregame_wave',
                    execution_id='fixture-E', trace_id='fixture-runtime', stage=stage, ts_ms=timestamp, **extra)}
        rows = [row('bind', 10, first_identity=True), row('bind', 11, first_identity=False),
                row('start_accepted', 20), row('ack_sent', 21), row('bind', 30, first_identity=True)]
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)/'fixture.jsonl'
            path.write_text('\n'.join(json.dumps(r) for r in rows)+'\ninvalid line\n')
            result = waves.telemetry([path, path])
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]['unique_identities'], 2)
        self.assertEqual(result[0]['after_boundary'], 1)
        self.assertEqual(result[0]['ack_sent_count'], 1)
        self.assertNotIn('fixture-E', json.dumps(result))

    def test_zero_and_singleton(self):
        self.assertEqual(waves.summarize([])['unique_identities'], 0)
        self.assertIsNone(waves.summarize([(1, 1)])['gap_max_ms'])


class PopulationSQLTests(unittest.TestCase):
    def test_actual_select_excludes_left_not_unmapped_and_has_no_ceiling(self):
        source = (HERE.parents[2]/'global/web/app/modules/jeux/hubs/app_games_hub_pregame.php').read_text()
        sql = re.search(r'\$q = \$pdo->prepare\("(SELECT p.id FROM games_hubs_players p.*?)"\);', source, re.S).group(1)
        # SQL behavior on a disposable in-memory fixture; no connection to Cotton/MySQL.
        db = sqlite3.connect(':memory:')
        db.executescript('CREATE TABLE games_hubs_players(id INTEGER, id_hub INTEGER, status TEXT);'
                         'CREATE TABLE games_hubs_players_sessions(id_hub INTEGER, id_hub_player INTEGER, id_session INTEGER, status TEXT);')
        db.executemany('INSERT INTO games_hubs_players VALUES(?,3,?)', [(i, 'active') for i in range(1, 5002)]+[(6000, 'left')])
        db.execute("INSERT INTO games_hubs_players VALUES(7000,4,'active')")
        db.executemany('INSERT INTO games_hubs_players_sessions VALUES(?,?,?,?)',
                       [(3, 1, 11, 'left'), (3, 2, 12, 'left'), (3, 3, 11, 'created'),
                        (3, 4, 11, 'failed'), (4, 5, 11, 'left'), (3, 6, 11, 'active')])
        ids = [r[0] for r in db.execute(sql, {'hub': 3, 'session': 11})]
        self.assertEqual(ids, list(range(2, 5002)))
        db.close()


if __name__ == '__main__':
    unittest.main()
