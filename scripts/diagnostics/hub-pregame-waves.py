#!/usr/bin/env python3
"""Read-only wave audit. No names, runtime keys or player identifiers in output.

Examples:
  python3 scripts/diagnostics/hub-pregame-waves.py --poc-root /home/romain/Cotton
  python3 scripts/diagnostics/hub-pregame-waves.py --telemetry /path/server-logs.log
"""
import argparse
import hashlib
import json
import math
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path


def millis(value):
    return round(datetime.fromisoformat(value.replace('Z', '+00:00')).timestamp() * 1000)


def read_rows(path):
    rows = []
    with path.open() as stream:
        for number, line in enumerate(stream, 1):
            try:
                row = json.loads(line)
            except ValueError:
                continue
            if isinstance(row, dict):
                rows.append((number, row))
    return rows


def summarize(arrivals, boundary=None):
    """arrivals: ordered (timestamp_ms, source_line), one per first identity."""
    gaps = [b[0] - a[0] for a, b in zip(arrivals, arrivals[1:])]
    ordered = sorted(gaps)
    pauses = [dict(gap_ms=gaps[i-1], next_line=line,
                   subsequent_identities=len(arrivals)-i)
              for i, (_, line) in enumerate(arrivals) if i and gaps[i-1] >= 5000]
    packets, current = [], 0
    for i, _ in enumerate(arrivals):
        if i and gaps[i-1] >= 5000:
            packets.append(current)
            current = 0
        current += 1
    if current:
        packets.append(current)
    return dict(unique_identities=len(arrivals),
                before_boundary=None if boundary is None else sum(t < boundary for t, _ in arrivals),
                after_boundary=None if boundary is None else sum(t >= boundary for t, _ in arrivals),
                gap_p50_ms=ordered[math.ceil(len(ordered)*.5)-1] if ordered else None,
                gap_p95_ms=ordered[math.ceil(len(ordered)*.95)-1] if ordered else None,
                gap_max_ms=max(gaps) if gaps else None,
                pauses_ge_5s=pauses, packets_separated_by_5s=packets,
                peak_first_binds_per_1s=max(Counter(t//1000 for t, _ in arrivals).values(), default=0))


def poc(root):
    # Explicit recipe windows from Open Players V2 section AE; no inferred E mapping.
    cases = [('blindtest', 27986, '12:09:45', '12:10:39'),
             ('blindtest', 27987, '12:13:34', '12:16:54'),
             ('bingo', 27989, '12:17:25', '12:21:28'),
             ('bingo', 27990, '12:21:43', '12:22:27'),
             ('quiz', 27991, '12:23:12', '12:23:41'),
             ('blindtest', 27992, '12:25:12', '12:25:51')]
    paths = {game: root / ('bingo.game/ws/server-logs.log' if game == 'bingo'
                          else game+'/web/server/server-logs.log') for game, *_ in cases}
    cache = {game: read_rows(path) for game, path in paths.items()}
    result = []
    for game, session, start, end in cases:
        rows = [(n, d) for n, d in cache[game]
                if '2026-09-25T'+start <= d.get('ts', '') < '2026-09-25T'+end]
        binds = [(n, d) for n, d in rows if d.get('evt') == 'PLAYER_WS_BOUND']
        sids = {d.get('sid') for _, d in binds}
        if len(sids) != 1 or None in sids:
            raise ValueError(f'{session}: missing or ambiguous runtime; cannot infer a session')
        launches = [d for _, d in rows if d.get('sid') in sids and
                    (d.get('evt') == 'SESSION_RESET' or d.get('evt') == 'WS_GAME_SESSION_UPDATED'
                     and d.get('meta', {}).get('gameStatus') == 'En cours')]
        boundary = millis(launches[0]['ts']) if launches else None
        seen, arrivals = set(), []
        for line, d in sorted(binds, key=lambda item: item[1]['ts']):
            identity = d['meta']['player_id']
            if identity not in seen:
                seen.add(identity)
                arrivals.append((millis(d['ts']), line))
        result.append(dict(game=game, session=session,
                           boundary_kind='runtime_launch_proxy_NOT_START_ACK',
                           boundary_utc=launches[0]['ts'] if launches else None,
                           eligible_population=None, source=str(paths[game].relative_to(root)),
                           source_sha256=hashlib.sha256(paths[game].read_bytes()).hexdigest(),
                           first_bind_line=arrivals[0][1], last_bind_line=arrivals[-1][1],
                           **summarize(arrivals, boundary)))
    return result


def telemetry(paths):
    groups = defaultdict(list)
    for path in paths:
        for line, row in read_rows(path):
            event = row.get('meta', {}) if row.get('evt') == 'HUB_PREGAME_WAVE' else row
            if event.get('event') == 'hub_pregame_wave':
                groups[(event['execution_id'], event['trace_id'])].append((line, event))
    result = []
    for index, (_, rows) in enumerate(sorted(groups.items()), 1):
        rows.sort(key=lambda item: item[1]['ts_ms'])
        # Deduplicate overlapping rotated/exported files, not real reconnects.
        unique = {json.dumps(d, sort_keys=True): (line, d) for line, d in rows}
        rows = sorted(unique.values(), key=lambda item: item[1]['ts_ms'])
        accepted = [d['ts_ms'] for _, d in rows if d['stage'] == 'start_accepted']
        arrivals = [(d['ts_ms'], line) for line, d in rows
                    if d['stage'] == 'bind' and d['first_identity']]
        result.append(dict(trace=index, boundary_kind='server_START_accepted',
                           ack_sent_count=sum(d['stage'] == 'ack_sent' for _, d in rows),
                           population_samples=[{k: d.get(k) for k in ('ts_ms', 'eligible_identities',
                               'ready_eligible', 'full_ready_observed', 'added', 'removed')}
                               for _, d in rows if d['stage'] == 'population'],
                           **summarize(arrivals, accepted[0] if accepted else None)))
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--poc-root', type=Path)
    group.add_argument('--telemetry', nargs='+', type=Path)
    args = parser.parse_args()
    print(json.dumps(poc(args.poc_root) if args.poc_root else telemetry(args.telemetry), indent=2))
