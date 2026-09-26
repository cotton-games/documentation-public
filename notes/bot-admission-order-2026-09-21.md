# Bots et compteurs runtime — 21/09/2026

## Preuves locales

Client 442, Hub 334. Quiz session 27907 : journal WS `quiz/web/server/server-logs.log` : `SESSION_PLAYER_COUNT` à 07:49:15.615Z = 29 puis 07:49:54.329Z = 30. La vague de bots comporte 71 `registrationError` WS. Leur payload journalisé ne contient pas le code : on ne peut pas attribuer individuellement tous ces refus au garde Hub.

Défaut reproductible dans `games/web/test_bots.php:createBot` : clé canonique disponible dès construction, `ws.onopen` appelait `registerIfReady` sans attendre l’admission HTTP. Le premier envoi interdisait ensuite une nouvelle tentative après succès HTTP (`wsRegistered`). Même course dans `quiz` et `blindtest` `web/server/actions/loadtest.js:createBot`. Test différé reproduit l’envoi prématuré. Le polling SQL du Master (`canvas_display.js:reconcileOrganizerAutoregFromSnapshot`, hydratePlayers) et les mises à jour WS (`ws_effects.js:updatePlayers`) alimentent le compteur depuis des listes distinctes : persistance vs présence runtime. Le correctif traite la course, sans figer artificiellement le compteur au maximum reçu.

Blind Test session 27906 : `blindtest/web/server/server-logs.log` à 07:58:07.306Z, Bot-99 admis avec la même clé `player_id` que dans le Quiz, avant la vague suivante (premiers envois à 07:58:21). 73 erreurs WS pendant cette vague ; motif non journalisé. Les clés de bots sont construites avec jeu + session + index : une nouvelle session génère de nouvelles identités, pas la reprise du roster du Hub plein. L’unique Bot-99 admis ne prouve donc pas un dépassement de quota. Après rechargement du journal Quiz : à 07:58:16.803–16.906Z, 28 départs `voluntary:true`, puis 28 `PLAYER_DEACTIVATE_BY_KEY_OK`. À 07:58:17.804Z, `WS_GAME_PLAYERS_UPDATE_SENT.totalPlayers=2` (ligne 18614). Les deux identités restantes sont Bot-99 et cloclo, déconnectées involontairement plus tôt, donc conservées par le runtime. `test_bots.php` appelle `stop()` sur arrêt explicite et `beforeunload` ; le motif applicatif exact (bouton/fermeture/navigation) n’est pas distingué dans ces traces. Aucun indice d’éviction par la jauge dans cette séquence.

## Changements et validation

- Games : `web/test_bots.php`, `web/tests/bot_admission_order_test.cjs`.
- Quiz et Blind Test : `web/server/actions/loadtest.js`.
- HTTP obligatoire avant envoi WS, y compris ancien id local navigateur ; réponse canonique réutilisée ; refus ou arrêt = aucun envoi.
- 12 scénarios isolés : HTTP avant/après ouverture WS, refus HTTP, arrêt pendant attente, id canonique. Tests capacité runtime existants passants, syntaxes PHP/JS vérifiées.
- Docs README/TASKS des trois repos, HANDOFF, CHANGELOG, index régénérés.

## Limites et retour arrière

Aucun déploiement, restart, DB ou accès distant DEV/PROD. Les bots déjà refusés ne sont pas réparés par ce changement local. Le correctif ne transforme pas les bots en clients du parcours complet Hub ni en roster partagé entre sessions. Test réel à refaire après mise en place manuelle ; la baisse à 2 est expliquée par les 28 départs volontaires enregistrés. Rollback : retirer uniquement les hunks de cette note et son test, préserver le lot jauge/upsell déjà local.

Journal AI Studio public RAW consulté avant patch : aucune mention des fichiers ciblés. Source : journal `documentation/general/0_ROADMAP.md`, rubriques EN COURS / TODO. Pas de motif trouvé imposant un rechargement de ces sources.
