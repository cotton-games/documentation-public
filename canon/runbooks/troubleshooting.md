> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Troubleshooting

> Known issues, checks, and diagnostics.

## 403 sur le bridge Canvas : check-list rapide (humain)
1. **L’appel contient-il `event_id` (ou `eventId`) ?**
   - Oui → l’auth inter-service est activée : `X-Service-Token` est requis.
   - Non → un 403 est suspect : vérifier qu’un proxy / wrapper n’ajoute pas `event_id` automatiquement.
2. **`X-Service-Token` est-il bien présent et correct côté WS ?** (env `CANVAS_SERVICE_TOKEN`)
3. **Le serveur PHP Canvas est-il configuré ?** (`CANVAS_SERVICE_TOKEN` disponible dans l’env PHP ; sinon `error.code="misconfigured"`)
4. **Le token est-il correct ?** (`error.code="forbidden"` si header absent ou mismatch)
4. **Symptôme fréquent** : si les writes sont refusés, certains états côté DB peuvent rester inchangés (ex: compteur `numPassedSongs`).

<!-- AUTO-UPDATE:BEGIN id="ts-checks" owner="codex" -->
- WS not connecting: verify ports (`WS_PORT`) and reverse proxy `wss://` termination.
- Canvas calls failing:
  - verify `CANVAS_API_URL`;
  - 403 uniquement si `event_id`/`eventId` est présent → vérifier `X-Service-Token` (env `CANVAS_SERVICE_TOKEN`) et la config côté PHP.
- Missing node_modules pathing: verify shared `ws/node_modules` layout used by BT/CQ servers.
- Logs viewer:
  - Open `GAMES/logs_session.html` (optionnellement `?sessionId=...`), puis cliquer “Charger”.
  - Le viewer lit `server-logs.log` “via les serveurs WS” et passe par `GAMES/includes/canvas/php/logs_proxy.php` (paramètres `game`, `sessionId`, `limit`, `page`).
- Canvas bridge response shape:
  - Le bridge renvoie une enveloppe `{ ok, data, error, ts }`; côté front, les champs métier sont dans `data` (ex: `data.playerId`).
<!-- AUTO-UPDATE:END id="ts-checks" -->
