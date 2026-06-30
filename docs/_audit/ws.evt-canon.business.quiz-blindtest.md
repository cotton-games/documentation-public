# WS evt canon — business timeline (quiz & blindtest) — 2026-02-06

## Règles ajoutées
- `SESSION_PLAYER_COUNT` : log uniquement sur changement de `count`; throttle 2s par `sid`; meta `{count, prev_count, delta, reason, …}`; rôle par défaut `server` (pas de rôle forcé organiser).
- `*_START_SIGNAL_RX` : déduplication par `sid + item_index` (Map en mémoire dans `gameplay.js`) pour éviter les doublons à chaque item.

## Quiz
| evt | lvl | msg | meta clés | occurrences |
| --- | --- | --- | --- | --- |
| SESSION_PLAYER_COUNT | info | Player count changed | count, prev_count, delta, reason, … | web/server/actions/playerCount.js:33 |
| PLAYER_REGISTERED | debug | Player registered | player_id, player_name?, is_reconnect?, is_admin_paper? | web/server/actions/registration.js:416/480 |
| QUESTION_START_SIGNAL_RX | info | Start signal received | item_index, remainingTime | web/server/actions/gameplay.js:264/270 |
| QUESTION_ENDED | debug | Question ended | item_index, reason?, duration_ms? | web/server/actions/gameplay.js:327 |
| GAME_ENDED | info | Game ended | reason?, podium_size?, top3_player_ids? | web/server/actions/gameplay.js:950 |

## Blindtest
| evt | lvl | msg | meta clés | occurrences |
| --- | --- | --- | --- | --- |
| SESSION_PLAYER_COUNT | info | Player count changed | count, prev_count, delta, reason, … | web/server/actions/playerCount.js:33 |
| PLAYER_REGISTERED | debug | Player registered | player_id, player_name?, is_reconnect?, is_admin_paper? | web/server/actions/registration.js:410/474 |
| TRACK_START_SIGNAL_RX | info | Start signal received | item_index, remainingTime | web/server/actions/gameplay.js:232/238 |
| TRACK_ENDED | debug | Track ended | item_index, reason?, duration_ms?, is_jingle? | web/server/actions/gameplay.js:295 |
| GAME_ENDED | info | Game ended | reason?, podium_size?, top3_player_ids? | web/server/actions/gameplay.js:845 |

Notes : GAME_ENDED conserve le snapshot final (payload podium) et reste loggé en info; events TRACK/QUESTION *_ENDED en debug pour ne pas polluer la timeline info.
