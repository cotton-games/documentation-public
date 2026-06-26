# Quiz — Logs informels (sans `evt`) — extraction brute (2026-02-06)

Raw capture (`rg "Logger.(log|warn|error)" web/server`):

```
web/server/server.js:250:            Logger.log('Un client WebSocket a été déconnecté pour inactivité.');
web/server/server.js:264:    Logger.error('Erreur critique sur le serveur WebSocket :', error);
web/server/server.js:268:    Logger.log(`Serveur WebSocket en écoute sur le port ${PORT}.`);
web/server/messaging.js:141:        Logger.error(`Session ${sessionId} introuvable pour l'envoi des messages.`);
web/server/messaging.js:174:        Logger.error(`Session ${sessionId} introuvable pour l'envoi des messages.`);
web/server/messaging.js:194:        Logger.error(`Session ${sessionId} introuvable pour l'envoi des messages.`);
web/server/messaging.js:220:        Logger.error(`Session ${sessionId} introuvable pour l'envoi des messages.`);
web/server/messaging.js:248:        Logger.error(`Session ${sessionId} introuvable pour l'envoi des messages.`);
web/server/messaging.js:258:        Logger.warn(`Aucun organisateur principal actif pour la session ${sessionId}.`);
web/server/messaging.js:267:        Logger.error(`Session ${sessionId} introuvable pour l'envoi des messages.`);
web/server/messaging.js:285:        Logger.error('Le socket spécifié est introuvable ou n’est pas ouvert.');
web/server/actions/wsHandler.js:170:                sessionLogger.warn(`❌ Rejet de "${type}" : message d’un primary obsolète pour session ${sessionId}`);
web/server/actions/wsHandler.js:267:                        sessionLogger.warn('scores_editing sans sessionId', data);
web/server/actions/wsHandler.js:278:                        sessionLogger.warn('paper_finalize_end sans sessionId', data);
web/server/actions/wsHandler.js:325:                    sessionLogger.log("Message heartbeat reçu du client.");
web/server/actions/wsHandler.js:336:                        sessionLogger.warn('startLoadtest appelé sans sessionId');
web/server/actions/wsHandler.js:352:                        sessionLogger.log(
web/server/actions/wsHandler.js:369:                            sessionLogger.warn('startLoadtest appelé sans nbBots ni profils');
web/server/actions/wsHandler.js:375:                        sessionLogger.log(
web/server/actions/wsHandler.js:392:                        sessionLogger.warn('stopLoadtest sans sessionId');
web/server/actions/wsHandler.js:396:                    sessionLogger.log(`stopLoadtest reçu pour session ${sessionId}`);
web/server/actions/wsHandler.js:405:                        Logger.warn('log_event sans sessionId', entry);
web/server/actions/wsHandler.js:434:                        Logger.warn('log_batch vide');
web/server/actions/wsHandler.js:474:                    sessionLogger.warn(`Type de message inconnu : ${type}`);
web/server/actions/wsHandler.js:477:            Logger.error('Erreur de parsing du message WebSocket :', err);
web/server/actions/wsHandler.js:524:        Logger.error('Erreur WebSocket :', error);
web/server/actions/registration.js:41:            Logger.error(`Session ${sessionId} introuvable. Un secondarySocket ne peut pas créer une session.`);
web/server/actions/registration.js:50:        Logger.log(`Session ${sessionId} introuvable. Création d'une nouvelle session pour le primarySocket.`);
web/server/actions/registration.js:78:        Logger.warn('Impossible de résoudre session_primary_id (continue quand même):', e.message);
web/server/actions/registration.js:93:            Logger.log(`🧹 Session démo détectée : ${beforeCount - afterCount} joueur(s) déconnecté(s) supprimé(s).`);
web/server/actions/registration.js:123:            Logger.log(`Primary promu immédiatement pour ${sessionId} → ${newInstanceId}`);
web/server/actions/registration.js:134:            Logger.log(`Primary déjà actif pour ${sessionId} → ${session.primaryInstanceId}`);
web/server/actions/registration.js:139:            Logger.log(`Primary changé pour ${sessionId}: ${oldInstanceId || '∅'} → ${newInstanceId}`);
web/server/actions/registration.js:140:            Logger.log(`Organisateur principal enregistré/reconnecté pour la session ${sessionId}`);
web/server/actions/registration.js:154:                Logger.error('Hydratation depuis la BDD échouée :', e);
web/server/actions/registration.js:165:            Logger.log(`⚠️ Le primarySocket de la session ${sessionId} est informé qu'un secondarySocket est déjà connecté.`);
web/server/actions/registration.js:173:        Logger.log(`📡 GAME_RESUMED envoyé aux clients connectés.`);
web/server/actions/registration.js:201:        Logger.log(`♻️ Secondary remplacé pour ${sessionId} (${sameInstance ? 'same' : 'other'} instance).`);
web/server/actions/registration.js:324:      Logger.error(`Erreur lors de updatePlayerListNow(${sessionId})`, e);
web/server/actions/registration.js:341:      Logger.error(`Erreur lors de updatePlayerListNow(${sessionId})`, e);
web/server/actions/registration.js:355:        Logger.error(`Session ${sessionId} introuvable. Le joueur ne peut pas être enregistré.`);
web/server/actions/registration.js:366:        Logger.log(`✅ session.limitReached réinitialisé car il reste de la place (${session.players.length}/${session.maxPlayers}).`);
web/server/actions/registration.js:373:        Logger.log(`Le joueur ${playerName} (ID : ${playerId}) est déjà enregistré. Mise à jour du socket.`);
web/server/actions/registration.js:388:            Logger.warn(`🚨 Limite de ${session.maxPlayers} joueurs atteinte dans la session ${sessionId}`);
web/server/actions/registration.js:419:        Logger.log(`Nouveau joueur enregistré : ${playerName} (ID : ${playerId}) dans la session ${sessionId}`);
web/server/actions/gameplay.js:111:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/gameplay.js:140:        Logger.log(`🔄 Nettoyage de la session démo ${sessionId} car elle est repassée en "En attente".`);
web/server/actions/gameplay.js:148:            Logger.log(`🔄 Score de ${player.playerName} (ID: ${player.playerId}) remis à 0.`);
web/server/actions/gameplay.js:180:        Logger.log(`Nouveau morceau détecté pour la session ${sessionId}. Réinitialisation des réponses.`);
web/server/actions/gameplay.js:188:    Logger.log(`Session ${sessionId} mise à jour :`, session);
web/server/actions/gameplay.js:209:        Logger.error(`Session ${sessionId} introuvable pour démarrer.`);
web/server/actions/gameplay.js:221:    Logger.log(`Signal "start" reçu pour la session ${sessionId} avec remainingTime=${remainingTime}s.`);
web/server/actions/gameplay.js:233:        Logger.error(`Session ${sessionId} introuvable pour lancer le décompte.`);
web/server/actions/gameplay.js:237:    Logger.log(`Début ou reprise du décompte pour la session ${sessionId}`);
web/server/actions/gameplay.js:249:            Logger.error(`⚠️ remainingTime non défini pour la session ${sessionId}, arrêt du décompte.`);
web/server/actions/gameplay.js:269:            Logger.log(`⏹️ Fin du morceau pour la session ${sessionId}`);
web/server/actions/gameplay.js:290:        Logger.log(`Décompte mis en pause pour la session ${sessionId}`);
web/server/actions/gameplay.js:292:        Logger.warn(`Aucun décompte actif à mettre en pause pour la session ${sessionId}`);
web/server/actions/gameplay.js:298:      Logger.error(`Erreur lors de l'envoi du classement complet en pause pour ${sessionId}`, e);
web/server/actions/gameplay.js:307:        Logger.error(`Session ${sessionId} introuvable pour forceRevealNow.`);
web/server/actions/gameplay.js:321:    Logger.log(`⏩ Force reveal (remainingTime=0) pour la session ${sessionId}`);
web/server/actions/gameplay.js:349:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/gameplay.js:394:            Logger.warn(`[manualAdvance] sessionUpdate → manualAdvance=${session.manualAdvance} (paper quiz)`);
web/server/actions/gameplay.js:405:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/gameplay.js:465:    Logger.log(`État du jeu envoyé à la télécommande pour la session ${sessionId}`);
web/server/actions/gameplay.js:473:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/gameplay.js:485:        Logger.error(`Joueur non trouvé pour la session ${sessionId}.`);
web/server/actions/gameplay.js:510:            Logger.log(`Message endGame envoyé au joueur reconnecté : ${player.playerName}`);
web/server/actions/gameplay.js:512:            Logger.warn(`Données finales introuvables pour le joueur ${player.playerName}.`);
web/server/actions/gameplay.js:536:    Logger.log(
web/server/actions/gameplay.js:546:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/gameplay.js:557:        Logger.warn(`[manualAdvance] updateGameOptions sans valeur → on conserve ${data.manualAdvance} (session ${sessionId})`);
web/server/actions/gameplay.js:569:    Logger.log(`Options de jeu mises à jour pour la session ${sessionId}:`, {
web/server/actions/gameplay.js:580:        Logger.warn(`❌ Session introuvable pour update_session_infos (${sessionId})`);
web/server/actions/gameplay.js:606:        Logger.warn(`❌ Session introuvable pour update_session_infos (${sessionId})`);
web/server/actions/gameplay.js:635:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/gameplay.js:649:        Logger.error(`Joueur ${playerId} introuvable dans la session ${sessionId}.`);
web/server/actions/gameplay.js:671:        Logger.log(`Points attribués : ${points}, Score total : ${player.playerScore}`);
web/server/actions/gameplay.js:685:          .catch(err => Logger.error('Persist score failed:', err));
web/server/actions/gameplay.js:696:    Logger.log(`Réponse traitée pour ${player.playerName} : ${isCorrect ? 'Correcte' : 'Incorrecte'}. Score : ${player.playerScore}`);
web/server/actions/gameplay.js:748:  if (!session) { Logger.error(`Session ${sessionId} introuvable pour la mise à jour.`); return; }
web/server/actions/gameplay.js:749:  if (session.isGameEnded) { Logger.log(`Partie terminée pour ${sessionId}, MAJ ignorée.`); return; }
web/server/actions/gameplay.js:807:  Logger.log(`Mise à jour envoyée pour ${sessionId}. Connectés : ${sorted.length}`);
web/server/actions/gameplay.js:812:  if (!session) { Logger.error(`Session ${sessionId} introuvable pour terminer la partie.`); return; }
web/server/actions/gameplay.js:817:    Logger.log(`Snapshot endGame renvoyé aux organisateurs (session déjà terminée) → ${sessionId}`);
web/server/actions/gameplay.js:861:  Logger.log(`Partie terminée ${sessionId}. Podium:`, podium);
web/server/actions/gameplay.js:968:        Logger.log(`Joueur ${player.playerName} déconnecté (fin de partie) pour la session ${sessionId}`);
web/server/actions/gameplay.js:970:        Logger.warn(`Erreur lors de la fermeture du socket joueur ${player.playerName}`, e);
web/server/actions/gameplay.js:983:    Logger.error('persistScore: sessionPrimaryId indisponible');
web/server/actions/gameplay.js:996:    Logger.log('persistScore: OK (changed=%s)', String(res?.changed));
web/server/actions/gameplay.js:998:    Logger.error('persistScore: API error', e.message || e);
web/server/actions/gameplay.js:1048:      Logger.warn('[adminSetScore] params manquants', data);
web/server/actions/gameplay.js:1053:      Logger.warn('[adminSetScore] session introuvable', sessionId);
web/server/actions/gameplay.js:1063:      Logger.warn('[adminSetScore] player introuvable', { sessionId, playerId: pid });
web/server/actions/gameplay.js:1067:    Logger.log('[adminSetScore] score mis à jour', { sessionId, playerId: pid, score });
web/server/actions/gameplay.js:1072:      Logger.warn('[adminSetScore] persistScore failed', err?.message || err);
web/server/actions/gameplay.js:1075:    Logger.error('[adminSetScore] erreur', e.message || e);
web/server/actions/envUtils.js:139:    Logger.warn(
web/server/actions/envUtils.js:165:    Logger.warn(
web/server/actions/envUtils.js:194:      Logger.warn(
web/server/actions/envUtils.js:222:    Logger.warn(
web/server/actions/connection.js:19:        Logger.error('Session introuvable pour le socket déconnecté.');
web/server/actions/connection.js:26:        Logger.log(`Joueur ${socket.playerId} déconnecté ${isVoluntary ? 'volontairement' : 'involontairement'} de la session ${sessionId}`);
web/server/actions/connection.js:41:        Logger.warn(`Joueur introuvable pour la session ${sessionId}`);
web/server/actions/connection.js:49:        Logger.log(`Joueur ${player.playerName} parti volontairement de la session ${sessionId} – slot libéré`);
web/server/actions/connection.js:58:    Logger.log(`Joueur ${player.playerName} déconnecté involontairement de la session ${sessionId} – slot conservé`);
web/server/actions/connection.js:64:        Logger.log(`✅ La session ${sessionId} est repassée sous la limite (${session.players.length}/${session.maxPlayers}). La prochaine inscription déclenchera une nouvelle alerte.`);
web/server/actions/connection.js:78:    if (res?.changed) Logger.log(`✅ Joueur ${playerId} marqué inactif (BDD).`);
web/server/actions/connection.js:79:    else Logger.log(`ℹ️ Joueur ${playerId} déjà inactif (aucun changement).`);
web/server/actions/connection.js:81:    Logger.error(`❌ Erreur deactivatePlayerInDB(playerId=${playerId}):`, error?.message || error);
web/server/actions/connection.js:90:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/connection.js:96:        Logger.log(`Pending primary annulé pour la session ${sessionId}`);
web/server/actions/connection.js:102:        Logger.log(`PrimarySocket déconnecté pour la session ${sessionId}. Volontaire : ${isVoluntary}`);
web/server/actions/connection.js:119:            Logger.log(`Session ${sessionId} supprimée après déconnexion volontaire.`);
web/server/actions/connection.js:125:            Logger.log(`🔄 firstClickDetected réinitialisé à false pour la session ${sessionId}`);
web/server/actions/connection.js:127:            Logger.log(`ℹ️ Fermeture d'un ancien primary ignorée (un nouveau primary est déjà en place).`);
web/server/actions/connection.js:130:        Logger.log(`🔄 firstClickDetected réinitialisé à false pour la session ${sessionId}`);
web/server/actions/connection.js:162:            Logger.log(`Attente de ${RECONNECTION_TIMEOUT / 1000} secondes pour la reconnexion de l'orga principal...`);
web/server/actions/connection.js:169:                    Logger.log(`OrgaSocket principal non reconnecté pour la session ${sessionId} après ${RECONNECTION_TIMEOUT / 1000} secondes.`);
web/server/actions/connection.js:178:                    Logger.log(`Session ${sessionId} supprimée après expiration du délai de reconnexion.`);
web/server/actions/connection.js:183:        Logger.log(`OrgaSocket secondaire déconnecté de la session ${sessionId}`);
web/server/actions/connection.js:188:            Logger.log(`Aucun organisateur restant pour la session ${sessionId}. Déconnexion de tous les joueurs.`);
web/server/actions/connection.js:191:            Logger.log(`Session ${sessionId} supprimée.`);
web/server/actions/connection.js:208:            Logger.log(`Joueur ${player.playerName} déconnecté pour la session ${sessionId}`);
web/server/actions/connection.js:211:         Logger.warn(`Erreur lors de la fermeture du socket joueur ${player.playerName}`, e);
web/server/actions/connection.js:231:        Logger.log(`OrgaSocket secondaire déconnecté pour la session ${sessionId}`);
web/server/actions/connection.js:234:      Logger.warn('Erreur lors de la fermeture d’un secondarySocket', e);
web/server/actions/wsUtils.js:8:    Logger.log(\"✅ Référence au serveur WebSocket enregistrée dans wsUtils.js\");
web/server/actions/wsUtils.js:13:        Logger.error(\"❌ [ERREUR] WebSocket Server non défini dans wsUtils.js !\");
web/server/actions/wsUtils.js:20:            Logger.log(`📡 GAME_RESUMED envoyé à un client non enregistré (sessionId=${sessionId})`);
web/server/actions/loadtest.js:129:    Logger.log(
web/server/actions/loadtest.js:159:        Logger.log(
web/server/actions/loadtest.js:164:        Logger.warn(
web/server/actions/loadtest.js:171:    Logger.warn(
web/server/actions/loadtest.js:178:    Logger.log(`[LOADTEST] ${state.name} connecté au WS (${url})`);
web/server/actions/loadtest.js:188:      Logger.warn(
web/server/actions/loadtest.js:202:        Logger.log(
web/server/actions/loadtest.js:206:        Logger.log(
web/server/actions/loadtest.js:214:      Logger.log(`[LOADTEST] ${state.name} reçoit endGame → fermeture WS`);
web/server/actions/loadtest.js:226:    Logger.log(
web/server/actions/loadtest.js:232:    Logger.error(`[LOADTEST] ${state.name} WS error:`, err);
web/server/actions/loadtest.js:253:      Logger.warn(`[LOADTEST] Erreur lors de la fermeture de ${state.name}`, e);
web/server/actions/loadtest.js:425:    Logger.log(
web/server/actions/loadtest.js:437:  Logger.log(`[LOADTEST] Arrêt de ${bots.length} bots pour la session ${sessionId}`);
web/server/actions/loadtest.js:453:      Logger.error(`[LOADTEST] Erreur lors de la fermeture du bot ${bot.name || '?'} `, e);
web/server/actions/loadtest.js:462:    Logger.warn('[LOADTEST] startLoadtest sans sessionId → ignoré');
web/server/actions/loadtest.js:467:    Logger.warn('[LOADTEST] startLoadtest avec nbBots <= 0 → ignoré');
web/server/actions/loadtest.js:478:  Logger.log(`[LOADTEST] Démarrage de ${finalCount} bots pour la session ${sessionId}`);
web/server/actions/loadtest.js:508:    Logger.warn('[LOADTEST] attachPreRegisteredBot sans sessionId ou playerId');
web/server/actions/loadtest.js:532:  Logger.log(
web/server/actions/audioControl.js:9:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/audioControl.js:24:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/audioControl.js:38:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/audioControl.js:52:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/audioControl.js:65:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/audioControl.js:81:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/audioControl.js:96:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/audioControl.js:108:    Logger.log('Données reçues pour setAudioOutput:', { sessionId, output }); // Ajout du log
web/server/actions/audioControl.js:111:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/audioControl.js:119:        Logger.error(`Aucun player principal connecté pour la session ${sessionId}.`);
web/server/actions/audioControl.js:126:        Logger.log(`Redirection de l'audio vers la télécommande pour la session ${sessionId}`);
web/server/actions/audioControl.js:135:        Logger.log(`Redirection de l'audio vers le player principal pour la session ${sessionId}`);
web/server/actions/audioControl.js:143:        Logger.warn(`Option audio non valide pour la session ${sessionId}`);
web/server/actions/audioControl.js:151:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/audioControl.js:165:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/audioControl.js:172:    Logger.log(`✅ firstClickDetected activé pour la session ${sessionId}`);
web/server/actions/audioControl.js:184:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/audioControl.js:193:    Logger.log(`⚠️ Le primarySocket de la session ${sessionId} est informé qu'un secondarySocket est déjà connecté.`);
web/server/actions/audioControl.js:200:        Logger.error(`Session ${sessionId} introuvable.`);
web/server/actions/audioControl.js:213:    Logger.log(`📨 Réception de updateVideoMeta du player principal : songIndex=${songIndex}, valid=${valid}`);
web/server/actions/audioControl.js:223:    Logger.log(`📤 Message updateVideoMeta relayé à la remote pour session ${sessionId}`);
web/server/actions/audioControl.js:230:        Logger.error(`Session ${sessionId || '(inconnue)'} introuvable.`);
web/server/actions/audioControl.js:238:        Logger.log(`Demande start_support relayée au primary (session ${sessionId}).`);
web/server/actions/audioControl.js:245:        Logger.log(`Ack start_support envoyé aux remotes (session ${sessionId}).`);
web/server/actions/audioControl.js:252:        Logger.error(`Session ${sessionId || '(inconnue)'} introuvable pour support_ended.`);
```

Phase 2 (à faire) : extraire `context_keys` et proposer `suggested_evt` par entrée.
