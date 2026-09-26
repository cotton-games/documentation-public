# Hub342 — correction papier Blind Test non confirmée — 22/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub342-paper-score-audit" owner="codex" -->
Audit des copies locales de logs demandées, client3, Hub342. Aucun patch applicatif, accès DB réelle, SSH, service DEV/PROD, déploiement ou restart. Heures ci-dessous en Europe/Paris ; les timestamps WS en UTC sont décalés de +2h.

## Conclusion

Le chemin PHP Blind Test exécuté pendant cette recette utilise le contrat historique, alors que la Remote attend le reçu PATCH2. Le score300 est annoncé persisté par PHP mais la confirmation structurée attendue par la Remote n’est pas fournie par ce chemin. La première action reste `persisted=false` dans sa file ; les suivantes sont bloquées avec « Une correction reste à confirmer. Réessaie sa synchronisation. » avant tout envoi WS.

La différence cours/fin de partie n’explique pas ce message : son contrôle porte sur la confirmation HTTP de la correction précédente, pas sur la phase de jeu. Quiz et Blind Test ont des glues PHP séparés : les traces Quiz montrent bien le nouveau chemin, celles de Blind Test l’ancien.

**Écart d’exécution par rapport au code local confirmé ; cause opérationnelle exacte non vérifiable sur ces seules copies.** Fichier serveur ancien/non chargé, cache PHP ou autre copie servie restent à distinguer. Le corps JSON HTTP n’est pas enregistré dans ces access logs ; sa forme legacy est déduite du chemin PHP identifié et reproduite avec le code local.

## Preuves corrélées

| Source locale | Ligne(s) | Constat |
|---|---|---|
| `global/logs/error_log` | 6–7 | session27931 rattachée au Hub342, client3, vers08:09:50/08:09:57 |
| `games/logs/error_log` | 831,856,876,893 | Quiz : nouvelles traces `paper_score_correction_requested` / `paper_score_persisted`, scores200/220/180/150, de08:08:26 à08:08:47 |
| `games/logs/error_log` | 1222 |08:10:53 : Blind Test, ancien `REMOTE_PAPER_WRITE_RX` puis `REMOTE_PAPER_WRITE_PERSISTED`, session moteur7383, D221086, score300 |
| `games/logs/error_log` |1222–1532|24 tentatives du même event_id et score300, jusqu’à08:12:48, environ toutes les5s ; aucune trace PATCH2 de correction Blind Test |
| `games/logs/access_log` |1951,1972,1983…2315|Réponses Canvas HTTP200 dans la séquence de retries de la Remote Blind Test ; pas de preuve d’une confirmation PATCH2 dans un statut200 |
| `blindtest/web/server/server-logs.log` |1784,1814,6013|Session créée08:09:54 ;48 réconciliations roster,20 participants ; dernière à08:13:50 |
| même fichier |événements du22/09|45 `WS_IN`, dont12 `scores_editing`, mais aucun `admin_set_score` ni confirmation de score : cohérent avec arrêt avant `transmit()` |
| `blindtest/logs/error_log` |ensemble fourni|277 refus d’accès Nginx à06:53:24–06:53:42, avant cette recette ; aucune correction de score dans ce fichier |
| `global/logs/error_log` |ensemble fourni|Mapping Hub présent ; autres277 lignes de refus d’accès. Aucun échec de persistance score expliquant ce message |

Des `WS_SEND_SOCKET_NOT_OPEN` existent aussi (2580, de08:10:07 à08:11:41), souvent sans cible exploitable. Ils doivent rester distincts : le blocage étudié se produit avant l’envoi WS de correction ; ces erreurs ne démontrent donc pas un ACK de score perdu. La version du handler WS PATCH2 en service n’est pas validable sans commande de score reçue.

Aucun token, URL d’accès, pseudo ou IP utilisateur recopié dans ce rapport.

## Mécanisme dans les sources locales

- `games/web/includes/canvas/php/blindtest_adapter_glue.php:997` : l’intention `paper_score_update` sort immédiatement vers `canvas_paper_score_update`.
- Le log ancien à la ligne1019 exige lui-même `remote_action=paper_score_update`. Dans la version locale PATCH2, une même requête ne peut donc pas atteindre ce log : elle aurait déjà été routée vers le helper.
- La réponse historique vers1059 expose `ok`, `currentScore`, K/D et `requiresResync`, mais pas `persisted`, `requested_score`, `confirmed_score`.
- `games/web/includes/canvas/remote/paper_score_sync.js:22` exige ces trois derniers champs. Sans eux : « Persistance du score non confirmée », entrée conservée en attente, aucun `transmit`.
- Sa ligne33 refuse ensuite toute nouvelle correction tant qu’une entrée n’a pas cette confirmation : c’est exactement le message rapporté.
- `remote-ui.js` relance `retry()` toutes les5s : même requête persistée à nouveau côté ancien glue, sans satisfaire le contrat Remote.

## Vérification locale

Sonde Node éphémère exécutant le vrai `createPaperScoreSync`, I/O simulées :

1. Réponse historique `{ok:true,currentScore:300,...}` : première confirmation rejetée, soumission suivante refusée avec le message exact, retry HTTP, zéro envoi WS. Assertions vertes.
2. Réponse PATCH2 `{persisted:true,requested_score:300,confirmed_score:300,...}` : deux corrections successives acceptées et deux envois WS. Assertions vertes.

Aucune modification des tests/applications ni recette réelle prétendue. Les logs prouvent le score relu à300 dans l’ancien chemin, pas son état DB actuel après la période capturée.

## Suite ciblée

Vérifier en priorité la copie effectivement exécutée de `games/web/includes/canvas/php/blindtest_adapter_glue.php` : elle doit contenir le routage PATCH2 ligne997 et le `require_once` de `paper_score.php`. Le helper commun fonctionne déjà pour Quiz dans cette capture. Si le fichier disque est à jour, vérifier le chemin servi/cache PHP ; les logs seuls ne permettent pas de trancher. Ce point est côté Games/PHP, pas un problème que prouve ou résout à lui seul un restart WS.

Après alignement : réessayer la correction en attente via « Score à confirmer — réessayer », vérifier le reçu PATCH2 puis `admin_set_score` et son ACK, et contrôler une baisse de score pendant la partie. Le chemin historique utilise encore `GREATEST` ; ne pas valider les baisses sur cette exécution. Ne pas vider arbitrairement la file pending : elle protège une écriture dont la Remote ne possède pas le reçu.

Documentation seule : rapport, suivi PATCH2 Games/Blind Test et HANDOFF, index générés. Aucun rollback applicatif à prévoir pour cet audit.
<!-- AUTO-UPDATE:END id="hub342-paper-score-audit" -->
