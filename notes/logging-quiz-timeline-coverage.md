# Quiz – couverture logs “film A→Z”

Sources : code Quiz WS (`web/server/actions/*.js`, `web/server/server.js`, `web/server/messaging.js`, `web/server/logger_ws.js`), audits compliance, canon `logging.md`.

## Checklist A→Z et couverture
| Event / étape métier | Couvert ? | Log existant (file:line) | Qualité | Fix minimal proposé |
| --- | --- | --- | --- | --- |
| Création / reprise de session (organizer primary) | Oui | `web/server/actions/registration.js:49-124` (info “Session … introuvable. Création…”, “Primary promu…”) | OK (info + sessionId, primaryInstanceId) | Ajouter `action:registration` + `request_id`; réduire texte |
| Promotion / remplacement primary | Oui | `registration.js:123-140` (info, warn) | OK mais verbeux | Ajouter `action:"primary_replace"` + payload compact |
| Connexion secondary (remote) | Partiel | `registration.js:181-220` (acceptSecondary, warns) | Insuffisant: pas de target ni sessionId partout | Log structuré `event:"SECONDARY_CONNECTED"` avec `session_id`/instance |
| checkSession (ping inscription) | Oui | `actions/wsHandler.js:161-166` (WS_IN info) | Partiel: info spam, pas d’action/kind | Tag `kind:"agg"`, niveau debug, `action:"checkSession"` |
| Inscription joueur | Partiel | `registration.js` (plus bas, logs: “Nouveau joueur enregistré…”, warn limites) | OK info mais pas d’ID joueur partout | Forcer `player_id`, `session_id`, `action:"player_register"` |
| Détection limite joueurs atteinte | Oui | `registration.js:388` warn 🚨 | OK | Ajouter `kind:"event"` |
| Reconnexion organizer/game resumed | Oui | `registration.js:168-174` info GAME_RESUMED | OK | Ajouter `action:"game_resumed"` + target |
| Connexion player/remote déjà inscrit | Partiel | `registration.js:373` info “déjà enregistré” | OK mais manque `player_id` structuré | Ajouter champ dédié |
| Début partie (start) | Oui | `gameplay.js:221` info Signal start + remainingTime | OK | Ajouter `action:"start"` + `game_status` |
| Décompte démarré | Oui | `gameplay.js:237` info “Début ou reprise du décompte” | OK | Ajouter `action:"countdown_start"` |
| Heartbeat client | Oui (spam) | `wsHandler.js:323-327` info | Insuffisant (bruit) | Downgrade debug ou agg |
| Mise à jour options (manualAdvance, durées) | Oui | `gameplay.js:569-574` info | Payload volumineux | Compacter, ajouter `action:"updateGameOptions"` |
| Updates session/game state broadcast | Partiel | WS_OUT `messaging.js:129-133` info (sessionUpdate/gameState) | Insuffisant (pas d’agg, pas d’action) | `kind:"agg"`, niveau debug sur refresh, `action` dérivée wsType |
| Réponse joueur (traitement) | Oui | `gameplay.js:671-696` info (points attribués, réponse traitée) | OK mais pas de playerId explicite dans log | Ajouter `player_id`, `is_correct`, `points` structurés |
| Persist score API | Partiel | `gameplay.js:683-686` error on failure; no success log | Insuffisant success path | Log info/ debug “persistScore ok” avec event_id/sessionId |
| Pause | Oui | `gameplay.js:290-292` info/warn | OK | Ajouter `action:"pause"` + reason |
| Force reveal | Oui | `gameplay.js:321` info | OK | Ajouter `action:"force_reveal"` |
| Fin morceau auto (timer) | Oui | `gameplay.js:269-271` info “Fin du morceau” | OK | Ajouter `action:"song_end"` |
| Fin de partie (endGame) | Partiel | `gameplay.js:812-861` info/warn (podium, snapshot) | OK mais épars | Log unique `event:"END_GAME"` avec outcome/podium sizes |
| Déconnexion client (player/organizer) | Oui | `connection.js:63-127` info/warn/warn dedup | OK (sessionId, scope, code) | Ajouter `kind:"event"` |
| Support start/ended | Oui | `audioControl.js:238-245`, `252` info/error | OK | Ajouter `action:"support_start/end"` |
| Audio routing (player/remote) | Oui | `audioControl.js:126-135` info | OK | Ajouter `action:"audio_route"` |
| Loadtest start/stop | Oui | `wsHandler.js:329-399` info | Bruyant | Downgrade debug + agg |
| WS_IN inconnue | Oui | `wsHandler.js:485` warn | OK | Structurer `event:"WS_UNKNOWN_TYPE"` |
| Endpoint /logs export | Oui | `server.js:163-239` JSON response counts | OK (diagnostic) | Option format=jsonl (déjà backlog) |

## Conclusion
- **Suffisant A→Z ?** Non. Les points clés sont mostly loggés, mais plusieurs étapes sont verbeuses non structurées, manquent d’IDs, ou sont noyées dans le bruit (WS_IN/OUT, heartbeat, loadtest).  
- **Top 5 manques bloquants**  
  1) Bruit WS_IN/WS_OUT/heartbeat sans agg → difficile de suivre la timeline.  
  2) Logs réponse joueur sans `player_id` structuré (lecture UI difficile).  
  3) Persist score : pas de log success structuré (seulement errors).  
  4) Inscription joueur/remote/secondary sans `action` ni IDs normalisés.  
  5) EndGame dispersé (pas d’event unique résumé).  

**Ordre recommandé des micro-tâches (métier avant socle viewer)**  
1) Structurer évènements métier critiques : register (player/primary/secondary), start, answer, persistScore success, endGame, support/audio routing — ajouter `action`, IDs, levels adaptés.  
2) Débruiter WS_IN/OUT + heartbeat (agg/debug).  
3) Ajouter log unique END_GAME + payload podium/scores résumés.  
4) Ajouter champs manquants (player_id/is_correct/points) dans les logs de réponse.  
5) Option format=jsonl sur /logs (déjà dans backlog commun) pour export fiable.  

> Périmètre respecté : aucun changement logger framework / viewer / autres jeux. Только documentation. 

## Mises à jour récentes
- **Session lifecycle (start/play/pause/resume/next/stop)** — FAIT (27 jan 2026)  
  - Logs INFO structurés `event:"session_update"` avec `session_id`, `action`, `state`, `index`, `reason` optionnel, dédup par session+action+index pour éviter le spam.  
  - Fichier : `web/server/actions/gameplay.js`.  
  - Exemple attendu (min_level=info) : `{"event":"session_update","action":"pause","session_id":"…","state":"paused","index":12}`.  
- **WS traffic débruité + DEBUG par défaut en dev** — FAIT (27 jan 2026)  
  - WS_IN forcé en DEBUG (agg/throttle conservés) dans `web/server/actions/wsHandler.js`; WS_OUT déjà en DEBUG dans `messaging.js`.  
  - Logger WS (`web/server/logger_ws.js`) considère désormais `NODE_ENV` : en dev (NODE_ENV≠production) ou si `LOG_DEBUG=1` → les logs DEBUG sont écrits, sinon ignorés.  
  - Attendu : min_level=info propre (pas de WS_IN/OUT), min_level=debug montre trafic WS et legacy texte.
