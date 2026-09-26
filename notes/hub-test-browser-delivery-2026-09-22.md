# Hub Bot Test Runner — livraison locale du 22/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-test-browser-delivery-20260922" owner="codex" -->

Suite : [correctif v2 gameplay Quiz + stop/cleanup](hub-gameplay-cleanup-2026-09-22.md), Games seul. Le premier run AVANT est désormais rapporté comme concluant sur hydration ; les statuts « non déployé » ci-dessous décrivent la livraison initiale à sa préparation. Bundle v1 gelé conservé pour base/rollback.

**HARNAIS HUB GÉNÉRIQUE — BACKEND BROWSER PRÊT. BASELINE QUIZ AVANT PRÉSERVÉE.** Prêt pour une première recette opérateur, pas encore qualifié en navigateur/DEV réel. Aucun déploiement, restart, commit ou charge DEV effectué. Journal AI Studio RAW relu avant patch : aucun des fichiers ciblés signalé à recharger. [Contrat implémenté](../canon/interfaces/hub-bot-test-runner.md), [base DEV attestée](quiz-dev-envutils-baseline-2026-09-22.md), [conception](hub-loadtest-unified-design-2026-09-22.md).

## Fichiers du lot

Games, fichiers déployables identiques AVANT/APRÈS :

- `web/test_bots.php` : entrée Hub Load Test et repli UI legacy.
- `web/modules/app_hub_view_helpers.php` : bridge Master, launch/focus observés.
- `web/includes/canvas/core/boot_organizer.js` : observation beginPlayFlow.
- `web/includes/bots/hub_bots.js` : option prepareOnly, legacy conservé.
- `web/includes/bots/hub_test_core.js` : autorité, sujets, scénario, collecteur, résumé.
- `web/includes/bots/hub_test_browser.js` : population, polling individuel, retry/drain.
- `web/includes/bots/hub_test_quiz.js` : vraie admission, ACK puis state validé.
- `web/includes/bots/hub_test_bridge.js` : contexte de run et événements Master.
- `web/includes/bots/hub_test_ui.js` : UI, transports, horloge, console/export.

Games, outillage/tests locaux : `tools/build_hub_test_quiz_ab.py`, `web/tests/hub_test_runner_test.cjs`, fixture de `web/tests/ws_loadtest_harness_test.cjs`. Les autres modifications préexistantes du workspace ne font pas partie de ce patch.

Quiz, modifiés par cette passe : `web/server/actions/hub_test_observer.js` (nouveau), `wsHandler.js`, `registration.js`, `gameplay.js`, `web/server/messaging.js`, `web/server/restart_serveur.txt`. Les changements des fichiers métier sont des hooks/écho/code diagnostic ; aucune règle de capacité, publication, admission ou gameplay changée. `envUtils.js` n'a pas été édité : le fichier local APRÈS est conservé et la livraison AVANT utilise le snapshot DEV.

Le bundle inclut aussi les dépendances attestées : `actions/loadtest.js`, `actions/loadtest_metrics.js`, `logger_v1.js`, et les variantes explicites `actions/envUtils.js`, `actions/hubCapacity.js`, plus `actions/capacity_reads.js` **APRÈS seulement**. Total : 9 fichiers Games ; 11 Quiz AVANT, 12 Quiz APRÈS. Aucun fichier Blind Test/Bingo/Global modifié dans ce lot.

## Bundle et preuves reproductibles

Bundle final local : `/tmp/hub-test-quiz-ab-2026-09-22-ready/`.

- `before/{games,quiz}/` : copies complètes à livrer pour baseline.
- `after/{games,quiz}/` : mêmes hooks et outils, performance existante ajoutée.
- `manifest.json` : SHA256 base/AVANT/APRÈS de chaque fichier, refs et markers.
- `{games,quiz}.dev-to-before.patch` et `.before-to-dev.patch` : instrumentation et retour à la base connue ; la base Games est HEAD local, pas une attestation nouvelle de DEV.
- `{games,quiz}.performance.patch` : delta AVANT→APRÈS, vide pour Games.
- `verification.txt` : application réellement vérifiée dans des répertoires temporaires.

Exporteur : `python3 tools/build_hub_test_quiz_ab.py /tmp/hub-test-quiz-ab-nouveau-dossier` depuis Games ; refuse un dossier déjà existant. Dépend des snapshots locaux gelés dans /tmp ; conserver le bundle final hors /tmp pour pérenniser la preuve. Aucun checkout ni mutation Git.

Quiz base métier AVANT `69192a2f4e3a45557c6b6f88421969623828c68f`, APRÈS `74b99c90a69d9c94de98e69b9abb79b5c1e7e3ea`, Games `b4609aa4d7d86aaed8c04c0344aca67341bfeb55`. Le snapshot DEV envUtils est conservé octet pour octet, SHA256 `ca7fca8edc8c8fe67cbcd29aa62dac7d20c0f26f5dea51d393443fba9014c366`. AVANT : aucun import capacity_reads, module absent du bundle, hubCapacity ancien sans WeakMap. APRÈS : capacité par cohortes/index déjà présents sur sas_players. La différence est limitée à ces trois fichiers et au marker.

Vérifié sur tous les fichiers, par application des patches et SHA256 : **base + instrumentation = AVANT ; AVANT + rollback = base ; AVANT + performance = APRÈS**. Les patches de performance ne modifient aucun module du nouveau harnais. Ne pas utiliser directement les fichiers non commités de sas_players pour livrer AVANT.

| Élément | Quiz DEV connu avant cette passe | Bundle AVANT | Local / bundle APRÈS |
|---|---|---|---|
| Ancienne instrumentation loadtest | Présente, attestée | Conservée | Conservée |
| Harnais Hub Browser | Absent | Nouveau lot préparé | Même nouveau lot |
| Cohortes capacité / index | Absents | Absents | Présents, performance existante |
| Publication / gameplay | Métier actuel | Même métier + observation | Même métier + observation |
| Marker | /03 déclaré | /05 préparé | /06 préparé |
| envUtils | Snapshot DEV AVANT | Identique au snapshot | Version performance locale |

Les markers /05 et /06 nécessiteront une activation opérateur **après copie complète** ; aucun restart effectué. /04 reste le marker du précédent pack de récupération non déployé.

## Vérifications locales

Depuis Games :

```sh
node --test web/tests/hub_test_runner_test.cjs
node --test web/tests/ws_loadtest_harness_test.cjs
node --test web/tests/hub_bots_test.cjs web/tests/hub_bots_runtime_test.cjs web/tests/bot_admission_order_test.cjs
php -l web/test_bots.php
php -l web/modules/app_hub_view_helpers.php
```

23 tests runner verts : 1/10/50, préparation complète/incomplète, refus/retries/récupération stable, ACK/state désordonnés ou absents, bind sans state, gameplay précoce/intermédiaire, N/N et 49/50, nearest-rank, tail, reconnexion, stop/poll/admission en vol, timeout, résumé unique/sans secret, timeline/jobs, incertitude avec déconnexion, doubles BT/Bingo, hooks hors run. Cas Browser50 complet avec vrai hub_bots + backend + adaptateur, HTTP/WS simulés : 50 identités, 100 tentatives WS, 50 refus puis 50 prêts. Tests sur fonctions Quiz réelles : ACK avant hydrate bloqué, runtime_ready après fin, écho initial absent hors run. Fermeture WS avant ACK/state déclenche un retry.

24 tests du harnais WS existant verts ; trois fichiers de régression Hub/admission verts (26 tests en exécution groupée avec les 23 runner). Syntaxe JS vérifiée ; Canvas parsé en ESM. Deux lints PHP verts. Vérifications SHA des patches et rollback réussies. Génération documentaire et `git diff --check` exécutés. Les simulations accélèrent la cadence ; elles ne prouvent ni la précision en navigateur réel, ni la tenue à 200, ni un palier Server500/5000.

## Livraison future Quiz DEV AVANT

1. Archiver les fichiers DEV remplacés, leur marker et leurs empreintes. Pour Quiz, retenir l'attestation opérateur et le snapshot déjà figés ; aucune nouvelle copie exigée sans contradiction. Pour Games, contrôler les éventuels changements DEV hors workspace avant remplacement.
2. Dans FileZilla, saisir **`/tmp/hub-test-quiz-ab-2026-09-22-ready/before/` comme site local**. Ce dossier est indépendant de la branche Git active. Livrer les neuf fichiers sous Games et les fichiers Quiz aux chemins correspondants, sauf marker réservé à la fin. Ne pas copier `after/`, envUtils du worktree ni capacity_reads pour cette baseline.
3. Vérifier le manifest : envUtils SHA ca7fca8e…, ancien hubCapacity, dépendances observer/metrics présentes. Contrôler la syntaxe sur l'installation si possible. Config existante : `NODE_ENV=development` ou `HUB_TEST_ENABLED=1` nécessaire à l'observation. Aucun fichier de secrets/configuration livré par le bundle.
4. Copier le marker AVANT `restart_serveur.txt` /05 **en dernier**, puis employer le mécanisme habituel d'activation Quiz DEV. Cette procédure est future, pas exécutée par Codex. Vérifier écoute WS et connexion Master/Player normale avant test.
5. Recharger test_bots et le Master avec les nouveaux scripts (rechargement complet pour les imports ESM). Ne pas livrer BT/Bingo pour ce lot.

## Premier run Hub50

1. Ouvrir test_bots et le Hub Master réel dans deux onglets du même profil/origine. Garder le runner visible/actif ; pas de mise en veille. Utiliser un Hub de recette avec session Quiz neuve, capacité permettant 50, sans autre charge de cette session/processus si l'on veut comparer les métriques.
2. Choisir Hub, 50, Browser/prepared/hydration ; Start. Attendre **Préparation 50/50**, puis **Prêt — lance la session Quiz depuis le Hub**. Aucun Player WS ne doit précéder le lancement. Une préparation incomplète n'autorise pas le lancement de la mesure.
3. Lancer avec le bouton normal du Hub Master. Ne pas créer de runtime manuellement, ne pas changer l'auto-start et ne pas employer un loadtest natif en parallèle. Observer Hydratation X/50 puis Partie démarrée avec X/50 prêts, Drainage et Terminé.
4. Exporter le JSON. Attendus : generator browser, requested/registered_hub 50, runtime_created/accepting/ACK/ready distincts, first_ws/bind/ready, focus et gameplay moteur présents, N/N ou null explicite, counters de refus/retries, timeline et incertitude. `validity.incomplete=false` est nécessaire à une baseline complète ; des refus runtime récupérés ne sont pas à eux seuls un échec.
5. Si bloqué, Stop puis exporter le résumé incomplet ; conserver avec logs Quiz, heures, marker et manifest. Le résumé autoritaire se trouve dans l'export Browser, pas forcément dans server-logs. Stop ne termine pas le jeu et ne retire pas les identités Hub.
6. Valider ce premier run avant palier 200 ou adaptation BT/Bingo. Comparer AVANT/APRÈS avec même harnais, N, paramètres, environnement et préparation ; utiliser une session/exécution fraîche et signaler les différences d'état. Backend Server500/5000 puis sas restent futurs.

## Rollback

Avant activation, restaurer les sauvegardes des seuls fichiers copiés. Après activation, remettre le lot Quiz DEV connu (snapshot envUtils et instrumentation antérieure) et les fichiers Games sauvegardés, puis activation contrôlée avec marker approprié choisi par l'opérateur. Les patches before-to-dev prouvent le retour à la base connue, mais ne remplacent pas une sauvegarde des variations DEV Games. Depuis APRÈS, revenir d'abord au lot AVANT, en retirant capacity_reads si exclusivement installé par ce lot, puis retirer le harnais si nécessaire. Aucun rollback SQL, aucune suppression des inscriptions de test automatisée ; ne pas restaurer tout un worktree et perdre les autres travaux.

Documentation : contrat dédié, cette note, README/TASKS Games/Quiz, conception historique reliée, runbook DEV, HANDOFF, manifest/routing et index générés.

<!-- AUTO-UPDATE:END id="hub-test-browser-delivery-20260922" -->
