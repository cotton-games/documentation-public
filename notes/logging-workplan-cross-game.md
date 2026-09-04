# Workplan cross-game — logs (Quiz / Blindtest / Bingo)

Sources lues :  
- `notes/logging-audit-quiz-compliance.md`  
- `notes/logging-audit-blindtest-compliance.md`  
- `notes/logging-audit-bingo-compliance.md`  
- `canon/logging.md` (schema v1)  
- `notes/logging-post-rollback.md`

## Backlog priorisé (une tâche = un PR)
| Priorité | Tâche | Jeux concernés | Fichiers ciblés (file:line) | Risque | Test (session golden) | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| P0 | Enrichir logger WS commun : `request_id`, `kind`, `action`, payload compact, `session_id` snake + clamp console DEBUG_ON | Quiz, Blindtest, Bingo | `quiz/web/server/logger_ws.js`, `blindtest/web/server/logger_ws.js`, `bingo.game/ws/logger.js` | Faible (log-only) | Lancer une session par jeu, vérifier `/logs` contient `request_id` propagé et `kind/action` | Point de mutualisation principal |
| P0 | Normaliser WS_IN/WS_OUT : ajouter `kind/action` (wsType), passer rafraîchissements & heartbeat en debug/agg, coalescing 2–5s | Quiz, Blindtest, Bingo | `*/actions/wsHandler.js`, `*/messaging.js`, `bingo.game/ws/bingo_server.js` | Moyen (volume log) | Session avec refresh rapides (gameState/sessionUpdate/checkSession) → min_level=info ne doit plus spammer | Réduit bruit majeur |
| P0 | Option `/logs?format=jsonl` (NDJSON brut) + métas invalid/pages | Quiz, Blindtest, Bingo | `*/server.js` (WS) | Faible | Curl `/logs?format=jsonl` → NDJSON ; JSON par défaut intact | Sécurise export/outil |
| P1 | log_event/log_batch : véto sans sessionId, normaliser level (numérique/warning), propager `request_id`, compacter `data` | Quiz, Blindtest, Bingo (front input) | `quiz/web/server/actions/wsHandler.js:379-448`, `blindtest/.../wsHandler.js:379-448`, `bingo.game/ws/bingo_server.js:248-283` | Moyen (rejects) | Envoyer log_batch sans sessionId → rejet; avec level=40 → visible warn; request_id réémis | Assainit flux front |
| P1 | Payload hygiene gameplay/loadtest (scores/options/players) : compacter clés/nums, éviter objets complets | Quiz, Blindtest, Bingo | `*/actions/gameplay.js`, `*/actions/loadtest.js`, `bingo.game/ws/bingo_loadtest.js` | Moyen | Session avec réponses massives → payloads courts (<1KB) | Réduit tailles |
| P1 | Structurer logs texte résiduels (new connection, unknown type) avec `event`, `session_id`, `target` | Bingo (principal), Quiz/BT mineur | `bingo.game/ws/bingo_server.js` (connexions/unknown), `*/actions/wsHandler.js` unknown warn | Faible | Voir viewer : labels non “WS message” + champs présents | Clarifie timeline |
| P2 | Propagation/génération `request_id` par socket/message (UUID si absent client) | Quiz, Blindtest, Bingo | `*/actions/wsHandler.js` (réception), context logger | Moyen | Même request_id vu sur WS_IN/OUT + actions liées | Peut suivre P0 impl |
| P2 | Viewer/Proxy : documenter/ou option `level_mode=ui` harmonisé + mapping actions-map (déjà en cours) | Front (games) | `games/web/logs_session.html`, `games/web/includes/canvas/php/logs_proxy.php`, `games/web/assets/logs/actions-map.json` | Bas | Export + filtres warn/error cohérents | À planifier après backend bruit |

## Regroupement par nature
- **Communs (WS)** : logger enrichi, WS_IN/OUT agg/debug, /logs NDJSON option, log_batch normalisation, request_id propagation, payload hygiene.
- **Spécifiques** :  
  - Bingo : logs texte connexion/unknown à structurer ; WS_IN sans session → tag/skip.  
  - Quiz : heartbeat spam (déjà listé), WS_IN/OUT refresh densité élevée.  
  - Blindtest : idem Quiz (moins de texte legacy).
- **Front** : log_batch input (niveau, request_id, sessionId required), payload compact côté front (via validations serveur).  
- **Viewer/Proxy (fin)** : level_mode/ui, mapping actions-map, export NDJSON côté proxy si backend JSONL disponible.

## Ordre d’exécution recommandé
1) P0 logger commun + WS_IN/OUT agg/debug (réduit bruit partout).  
2) P0 option /logs format=jsonl (débloque outils/export fiables).  
3) P1 log_event/log_batch normalisation + payload hygiene (évite pollution front).  
4) P1 structuration logs texte/unknown (Bingo).  
5) P2 request_id end-to-end.  
6) P2 viewer/proxy alignement (après stabilité backend).  

## Liens utiles
- Audit Quiz : `notes/logging-audit-quiz-compliance.md`  
- Audit Blindtest : `notes/logging-audit-blindtest-compliance.md`  
- Audit Bingo : `notes/logging-audit-bingo-compliance.md`  
- Canon logging : `canon/logging.md`  
- Post-rollback : `notes/logging-post-rollback.md`
