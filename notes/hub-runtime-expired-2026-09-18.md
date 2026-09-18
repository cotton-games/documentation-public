# Runtime officiel Hub expiré après grâce involontaire — 18/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-runtime-expired-20260918" owner="codex" -->

Statut : patch local non déployé. Travaux préexistants conservés. Aucun SSH, DB réelle, navigateur, déploiement, restart ou accès applicatif DEV/PROD. Les lectures réseau se limitent à la documentation RAW et au journal demandé.

## A. Contrôle préalable

START main, SITEMAP develop et DOCS_MANIFEST develop relus, puis cartes Global/Games et contrats. Journal AI Studio public relu : aucun fichier ciblé signalé à recharger. Les modifications WWW/AI Studio, global_librairies et e-commerce restent hors périmètre ; aucune parité distante revendiquée.

Preuves documentaires utilisées :

- [START RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), « Règle preuve d’abord » et « Discipline de génération ».
- [SITEMAP RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), « Repos » et « Global specs ».
- [Manifest RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers », « Routing rules » et « Server restart markers ».
- [Canvas bridge RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/canvas-bridge.md), « Payload minimal » : action service-only `hub_session_grace_expired` existante, auparavant clear du focus uniquement.
- [Suspension RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/notes/hub-suspend-patch-2026-09-10.md), « Conservation et gel », « Fenêtre, journal et maintenance », « Restart et limites réelles » : runtime vivant jusqu’au cutoff, sans TTL d’une heure après suspension explicite.

Le marqueur durable de mort exacte n’était pas décrit : **non trouvé dans la documentation** avant ce patch. Les descriptions RAW de suspension portent explicitement la réserve « patch local non déployé ».

## B. Marqueur retenu

`game_events.action = hub_runtime_expired`, via l’action Canvas service-only existante `hub_session_grace_expired`.

Payload durable : `hub_id`, `session_id` numérique, `source_session_id`, `runtime_session_id`, `execution_id`, `engine`, `reason=primary_grace_expired`, `request_id=primary-grace-expired`, `routing_generation`. Colonne historique `game_events.session_id` : token source, convention existante. Aucun token dans les nouveaux logs.

Identité fournie par `hub_lifecycle/read` au moteur vivant, copiée à l’armement de sa grâce. Elle n’est jamais remplacée par une recherche de « l’exécution courante » lors d’un retry. Idempotence : `event_id=hublife-` suivi des 48 premiers caractères du SHA-256 de `hub_runtime_expired|<execution_id>|primary-grace-expired|`, puis `INSERT IGNORE`.

Aucune phase terminale, aucun `hub_execution_completed`, aucune suppression de résultat et aucune migration.

## C. Chaîne complète

1. Les callbacks réels `primaryReconnectTimer` Quiz/Blind Test et `primaryReconnectTimers` Bingo revalident leur timer et identité mémoire ; une suspension explicite les annule et interdit leur effet.
2. Le runtime devient indisponible localement (`graceExpirationInProgress` / `graceExpiringGames`, plus gel `runtimeExpired`). Une inscription tardive ne le réactive pas.
3. Le bridge reçoit l’identité capturée. Global prend le verrou Hub déjà utilisé par lancement/suppression, recharge l’exécution et revalide provenance officielle, moteur et IDs. Une notification ancienne ne vise jamais une exécution plus récente.
4. Global écrit le marqueur idempotent, puis clear conditionnel : session active, génération et date d’activation. Un autre focus reste inchangé. Présentation historique conservée.
5. Le cleanup final moteur suit l’acquittement. En cas d’échec HTTP/SQL/lock, retry mémoire après 2/4/8/16/30 secondes puis toutes les 30 secondes, avec runtime toujours invalide. Il s’agit de livraison d’une mort déjà constatée, pas d’un second timer d’expiration Games.
6. `app_games_hub_official_execution_is_reusable()` refuse le marqueur exact. Le lancement Master, l’entrée de commande Remote, la création officielle même `force_new` et `hub_lifecycle/read/resume` retournent `HUB_RUNTIME_EXPIRED` avant reprise, publication ou fallback `resume_recreated_runtime`.
7. Projection centrale `hub_runtime_expired` : phase persistante inchangée, focus de carte inactif. Master/Remote « Suspendue », aucun CTA Reprendre/Relancer. Play refuse auto-join et accès manuel ; la présentation historique et les résultats restent disponibles. Le marqueur participe à la révision du snapshot.

Si le journal ne peut pas être lu, l’erreur ne devient pas une autorisation de recréer. Aucune modification des règles d’ownership Remote ou de validation de présence/génération Master.

## D. Fichiers modifiés

Liste de cette passe uniquement, par rapport à la copie locale avant patch (les autres modifications du workspace ne sont pas incluses).

- `global/web/app/modules/jeux/hubs/app_games_hub_runtime_expiry.php`
- `global/web/tests/hub_runtime_expiry_test.php`
- `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php`
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- `global/web/tests/hub_demo_lifecycle_test.php`
- `global/web/tests/hub_player_qr_continuation_test.php`
- `games/web/tests/hub_runtime_suspension_time_test.cjs`
- `games/web/includes/canvas/php/boot_lib.php`
- `games/web/includes/canvas/php/hub_lifecycle.php`
- `games/web/modules/app_hub_remote_ajax.php`
- `games/web/modules/app_hub_view_helpers.php`
- `games/web/tests/hub_active_resume_test.php`
- `games/web/tests/hub_demo_readiness_flow_test.php`
- `games/web/tests/hub_demo_ux_contract_test.php`
- `games/web/tests/hub_empty_commercial_test.php`
- `games/web/tests/hub_launch_confirmation_contract_test.php`
- `games/web/tests/hub_paper_preparation_test.php`
- `games/web/tests/hub_remote_master_ux_test.php`
- `games/web/tests/hub_suspend_test.php`
- `games/web/tests/hub_theme_renewal_display_test.php`
- `quiz/web/server/actions/runtimeExpiry.js`
- `quiz/tests/primary-grace.test.cjs`
- `quiz/web/server/actions/connection.js`
- `quiz/web/server/actions/hubLifecycle.js`
- `quiz/web/server/restart_serveur.txt`
- `blindtest/web/server/actions/runtimeExpiry.js`
- `blindtest/tests/primary-grace.test.cjs`
- `blindtest/web/server/actions/connection.js`
- `blindtest/web/server/actions/hubLifecycle.js`
- `blindtest/web/server/restart_serveur.txt`
- `bingo.game/ws/runtime_expiry.js`
- `bingo.game/ws/tests/runtime_expiry.test.js`
- `bingo.game/version.txt`
- `bingo.game/ws/bingo_server.js`
- `bingo.game/ws/hub_lifecycle.js`

Documentation : README/TASKS des cinq repos, `HANDOFF.md`, `CHANGELOG.md`, `canon/interfaces/{canvas-bridge,actions}.md`, `canon/data/bingo-write-map.md`, `pm2-ws.md`, `canon/runbooks/prod.md`, ce rapport et index/sitemap générés.

## E. Tests

Tous les effets SQL/HTTP/WS sont simulés ; aucun serveur ni DB réelle lancé.

- `php global/web/tests/hub_runtime_expiry_test.php` : **213 contrôles** des fonctions réelles bridge, journal, provenance, idempotence, clear CAS, projection Master/Remote, Play actif/accès, refus backend/commande/force_new et lecture SQL indisponible ; trois moteurs × papier/numérique.
- `node --test quiz/tests/primary-grace.test.cjs blindtest/tests/primary-grace.test.cjs` : **53 tests par moteur**, dont expiration officielle corrélée, retry avec inscription refusée, grâce valide et callback déjà en file après reconnexion.
- `node --test bingo.game/ws/tests/runtime_expiry.test.js` : **8 tests**, mêmes conditions via le vrai callback et la vraie authentification Bingo, plus remplacement d’objet runtime.
- `node games/web/tests/hub_runtime_suspension_time_test.cjs` : **72 simulations de suspension/reprise** à +1/+10/+30/+59/+61 min et cutoff −1 ms ; deux formats et fermeture immédiate/heartbeat. Même objet, progression/participants conservés, aucune notification d’expiration. **3 contrôles d’annulation de grâce et 3 de cleanup au cutoff**.
- Suites existantes ciblées : suspension, continuité/ownership Remote, bootstrap/reprise, polling et présence/génération. Résultats consolidés ci-dessous.

Résultats consolidés : **194 tests Node moteurs**, **72 tests Node Games**, **67 suites PHP Hub réussies sur 70** (dont les 213 contrôles dédiés). Les 72 simulations temporelles +6 contrôles sont un lancement séparé. Les suites PHP incluent la présence/génération et le bootstrap existants ; aucune recette navigateur réelle revendiquée.

Commandes groupées, depuis la racine Cotton :

```sh
node --test quiz/tests/primary-grace.test.cjs quiz/tests/remote-continuity.test.cjs blindtest/tests/primary-grace.test.cjs blindtest/tests/remote-continuity.test.cjs blindtest/tests/teams-disabled.test.cjs bingo.game/ws/tests/hub_suspend.test.js bingo.game/ws/tests/remote_continuity.test.js bingo.game/ws/tests/runtime_expiry.test.js
node --test games/web/tests/hub_active_resume_test.mjs games/web/tests/hub_suspend_test.mjs games/web/tests/hub_remote_continuity_test.mjs games/web/tests/hub_remote_polling_test.mjs
php global/web/tests/hub_runtime_expiry_test.php
node games/web/tests/hub_runtime_suspension_time_test.cjs
```

Vérification syntaxique PHP/JS des fichiers concernés et `git diff --check` dans les six dépôts concernés. Aucun test avec connexion à une DB réelle ; le harness de stockage MySQL est exclu de cette passe.

Trois suites PHP élargies restent rouges avec les **mêmes échecs reproduits sur la copie d’avant patch** :

- `games/web/tests/hub_remote_contract_test.php` : anciennes assertions d’emplacement d’aide QR et de sortie Remote (page vide versus vraie page).
- `games/web/tests/hub_master_renewal_eligibility_model_test.php` : éligibilité renouvellement Quick Add.
- `games/web/tests/hub_remote_master_ux_test.php` : `SSR demo CTA eligibility`.

Les harness PHP qui extraient des fonctions isolées reçoivent un stub « aucune expiration » pour la nouvelle dépendance ; le test transversal ci-dessus exécute la vraie autorité persistante. Ces adaptations ne masquent pas les trois échecs préexistants.

## F. Non-régressions

| Cas | Libellé | Action |
|---|---|---|
| Running + focus + runtime vivant | En cours | Reprendre |
| Grâce involontaire non expirée | Projection actuelle | Reprendre |
| Grâce involontaire expirée confirmée | Suspendue | Aucune |
| Suspension explicite, +61 min avant cutoff | Suspendue | Reprendre/Relancer selon surface ; même runtime |
| Fin naturelle | Terminée / Résultats | Aucun lancement |
| Cutoff fermé | Contrat existant | Aucun lancement |

Papier/numérique communs. Démo et hors Hub conservent leur chemin historique. Continuité/ownership Remote, producteur de présence/génération Master et continuations post-suspension ne sont pas corrigés ni redessinés ici. La suspension explicite conserve son sweep au cutoff.

## G. Limites résiduelles

Crash/restart avant persistance : le processus peut perdre la notification mémoire. Aucune mort n’est déduite de l’absence de heartbeat, présence ou focus. Un ancien processus sans identité officielle capturée ne peut pas produire une preuve exacte : le bridge refuse le marquage sans sélectionner une exécution à sa place.

Pendant une panne du bridge, le runtime est déjà invalide localement, mais la projection durable ne converge qu’après persistance. Les retries ne sont pas un outbox durable. La concurrence MySQL, l’interface dans un navigateur et le transport réel restent à recetter après livraison autorisée ; les tests mémoire ne prouvent pas un état DEV/PROD.

## H. Documentation / livraison

README/TASKS Global, Games et trois moteurs mis à jour dans les blocs existants ; TASKS en enrichissement d’entrée existante. HANDOFF, CHANGELOG, Canvas bridge (payload/événements), actions, write-map Bingo, markers et runbook actualisés. Sitemap/index régénérés par `npm run docs:sitemap`.

Markers locaux : Quiz/Blind Test `restart 18-09-2026/03`, Bingo `restart 18-09-2026/02`. Ils ne prouvent aucun redémarrage. Paquet coordonné Global → Games → trois moteurs, avec les nouveaux helpers JS dans chaque package indépendant. Aucun changement PM2/env/port.

Rollback : restaurer uniquement les changements de cette passe en préservant les travaux antérieurs ; ne pas supprimer le journal. Après émission de marqueurs, retirer leurs lecteurs isolément réexposerait une reprise interdite : conserver les gardes ou prévoir une version de retour compatible avec ces événements.

**Aucun déploiement, restart, SSH, accès DB réel, accès applicatif DEV/PROD ou modification serveur.**

<!-- AUTO-UPDATE:END id="hub-runtime-expired-20260918" -->
