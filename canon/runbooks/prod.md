<!-- AUTO-UPDATE:BEGIN id="hub-suspend-20260910-prod-note" owner="codex" -->

### 22/09/2026 — Patch auth Bingo numérique, local

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](../deployment-status.md).

Bingo `version.txt` : **`restart 22-09-2026/02`**. Livrer ensemble `ws/bingo_server.js`, `ws/bingo_reset.js`, `ws/repository/base/player_repository.js` et `ws/repository/db/db_player_repository.js`, sur la base du lot capacité précédent. Restart WS Bingo requis après livraison autorisée, aucun exécuté. Quiz/BT inchangés, markers22/09 /01. Aucun nouvel endpoint/env/SQL/reload PHP. [Rapport, tests et rollback](../../notes/bingo-digital-auth-performance-2026-09-22.md).


### 22/09/2026 — Capacité WS / publication BT (local)

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](../deployment-status.md).

Cohortes fermées avant fetch de `hub_capacity_get` : aucun cache de réponse réutilisé par une admission ultérieure, contrat API/stock/verrou Bingo inchangé. Modules `capacity_reads.js` à livrer avec `envUtils` et helpers capacité. BT indexe le lookup Player. Markers Quiz/BT/Bingo : `restart 22-09-2026/01` ; redémarrage des trois WS nécessaire après livraison future autorisée, aucun effectué. Pas de nouvel endpoint/env/SQL ni reload PHP. [Contrat, tests et limites](../../notes/hub-capacity-publication-patch-2026-09-22.md).


## 21/09/2026 — PATCH3 Bingo non déployé

Fichiers applicatifs candidats sur base PATCH1 : `bingo.game/ws/bingo_server.js` et `bingo.game/version.txt` (`restart 21-09-2026/03`). Aucun runtime Games/Quiz/BT ni SQL ajouté par cette passe. Activation non exécutée ; rollback ciblé des seuls hunks PATCH3 pour préserver PATCH1. [Rapport](../../notes/bingo-paper-association-patch3-2026-09-21.md).


## 21/09/2026 — PATCH2 papier non déployé

Aucune opération PROD. Livraison éventuelle coordonnée Games/Quiz/BT nécessaire : nouveau reçu atomique et finalizer avec snapshot. Préserver le lecteur des reçus déjà enregistrés en cas de rollback après utilisation. [Fichiers et limites](../../notes/paper-score-patch2-2026-09-21.md).


## 21/09/2026 — PATCH1 papier non déployé

Aucune opération PROD. Livraison éventuelle coordonnée Games/Global/WS nécessaire pour le contrat roster. Après utilisation des identités `team:ID`, conserver leur lecteur lors d’un rollback Global ; ne pas revenir aveuglément à un lecteur guest-only. [Limites et validation](../../notes/paper-roster-patch1-2026-09-21.md).


18/09/2026 — Préparation locale runtime-expired : Global + Games + trois moteurs doivent partager le contrat d’identité `hub_lifecycle/read` et `hub_session_grace_expired`. Markers Quiz/BT `/03`, Bingo `/02`, date18/09 ; aucune activation exécutée. Pas de migration. Ne pas retirer isolément les lecteurs du marqueur déjà persisté : cela réexposerait une reprise invalide. Retour arrière coordonné à préparer sans suppression du journal. Crash avant acquittement durable = limite explicite, pas de déduction heartbeat. [Livraison et validation hors connexion](../../notes/hub-runtime-expired-2026-09-18.md).


18/09/2026 — Robustesse reprise Bingo : seul marker Bingo `version.txt` préparé à `restart 18-09-2026/01`. Aucun restart exécuté. Contrat coordonné Global/Games/Bingo : heartbeat avec intention/instance Hub, page ID et motif structuré WS ; anciennes pages ouvertes à recharger lors d’une future livraison. Aucun changement de port, endpoint ou configuration ; Quiz/Blind Test WS inchangés.


## Markers WS — suspension Hub, préparation locale 10/09/2026

Quiz `web/server/restart_serveur.txt`, Blind Test `web/server/restart_serveur.txt` et Bingo `version.txt` passent à `restart 10-09-2026/01`, conformément au manifest. Ce sont des fichiers préparés dans le workspace, pas une preuve de copie ou de redémarrage. Aucun service, PM2, configuration, réseau de production ou DB réelle modifié. Le protocole nécessite la cohérence Global/Games/trois moteurs ; aucun rollout partiel n’a été effectué. [Patch et réserves](../../notes/hub-suspend-patch-2026-09-10.md).

<!-- AUTO-UPDATE:END id="hub-suspend-20260910-prod-note" -->

> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Runbook – Prod

> Deployment / reverse proxy / wss.

<!-- AUTO-UPDATE:BEGIN id="prod-steps" owner="codex" -->
# Contexte rapide (workspace apps + documentation)

Le workspace “apps” regroupe plusieurs sous-projets (PHP + Node) utilisés pour le site Cotton (`www/`, `pro/`, `global/`, `games/`) et des serveurs WebSocket temps réel pour certains jeux (`bingo.game/`, `blindtest/`, `quiz/`).

## Lancer en dev (pistes “factuelles”)
- PHP (`www/`, `pro/`, `global/`, `games/`): servir les dossiers web via Apache/Nginx/PHP-FPM, avec les réécritures `.htaccess` actives et un `SERVER_NAME` cohérent avec les configs (`*/web/config.php`, `global/web/global_config.php`, `games/web/config.php`).
- WebSocket Bingo: `bingo.game/ws/server.js` (port via `WS_PORT`, défaut 3030) après installation des dépendances Node dans `bingo.game/ws/`.
- WebSocket Blindtest/Quiz: `blindtest/web/server/server.js` et `quiz/web/server/server.js` (ports via `WS_PORT`, défaut 3031/3032) — ces serveurs référencent des `node_modules` via un chemin `../../ws/node_modules/...` (pré-requis côté environnement de déploiement).

## Lancer en prod (pistes “factuelles”)
- PHP: déploiement type “vhost” par sous-domaine (`www`, `pro`, `global`, `games`) + base MySQL configurée dans les fichiers `config.php`/`global_config.php`.
- WebSocket: exposer en `wss://` derrière un reverse proxy (ports `WS_PORT`), et autoriser l’accès au endpoint HTTP `/logs` si utilisé.

## Variables d’environnement repérées (Node)
- `WS_PORT` (ports WS/HTTP logs)
- `WS_SERVER_URL` (hint env “prod/dev” via présence de `.dev.`)
- `LOG_DEBUG` (niveau de logs)
- `CANVAS_API_URL` (optionnel, endpoint Canvas `.../games_ajax.php?t=jeux&m=canvas` ; alias historique: `.../global_ajax.php?t=jeux&m=canvas`)
- `CANVAS_SERVICE_TOKEN` (requis pour les writes idempotents: envoyé en header `X-Service-Token` quand un `event_id` est présent)
- `CANVAS_ORIGIN`, `ORIGIN`, `BINGO_CANVAS_CONCURRENCY` (hints / load-test / intégration Canvas côté `bingo.game/ws/`)
- `CANVAS_HTTP_TIMEOUT_MS`
- `CANVAS_UPDATE_SCORE_CONCURRENCY` (quiz/blindtest)
- `ROLE_AUDIT_TICK_MS`, `LOG_ROLE_AUDIT` (bingo)

## Priorité de config (WS)
- Les WS chargent `.env` local avec priorité (`preferLocal: true`) sur les clés whitelistées.
- Si une clé whitelistée est présente dans `.env`, elle écrase `process.env` (PM2).
- Si une clé whitelistée est absente de `.env`, fallback vers `process.env`/PM2.
- En prod, définir explicitement `LOG_DEBUG=0` dans `.env` pour couper les logs debug de manière déterministe.
<!-- AUTO-UPDATE:END id="prod-steps" -->
