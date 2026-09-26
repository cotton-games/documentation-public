<!-- AUTO-UPDATE:BEGIN id="hub-execution-robustness-20260925" owner="codex" -->
# Robustesse d’exécution Hub et analyse de backport — 25/09/2026

Patch local sur les branches **pregame**, documentation sur **develop**. Aucun commit, patch de main, cherry-pick, merge, push, déploiement, restart ou accès DB/SSH/application distante effectué. Le pregame antérieur est déclaré validé en DEV par l’opérateur dans la demande ; cette validation ne qualifie pas automatiquement ce nouveau patch.

## Préflight et preuves

Lectures privées authentifiées, dans l’ordre START → sitemap → README → manifest → HANDOFF :

- [START, main](https://api.github.com/repos/cotton-games/documentation/contents/START.md?ref=main), « Parcours », « Discipline de génération » et contraintes.
- [SITEMAP.ndjson, develop](https://api.github.com/repos/cotton-games/documentation/contents/SITEMAP.ndjson?ref=develop), entrées exactes des notes et cartes repo.
- [README, develop](https://api.github.com/repos/cotton-games/documentation/contents/README.md?ref=develop), « Parcours de lecture », discipline AUTO-UPDATE.
- [DOCS_MANIFEST, develop](https://api.github.com/repos/cotton-games/documentation/contents/DOCS_MANIFEST.md?ref=develop), « Update triggers », autorité Hub et Open Players.
- [HANDOFF, develop](https://api.github.com/repos/cotton-games/documentation/contents/HANDOFF.md?ref=develop), actions du 25/09 : reprise Master, reveal Remote et retour prématuré.
- [Audit d’autorité, develop](https://api.github.com/repos/cotton-games/documentation/contents/notes/hub-execution-authority-audit-2026-09-25.md?ref=develop), sections B/C/E/F/G. Son constat porte sur les snapshots hub_soiree, pas sur le nouveau pregame.
- [Games README](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/games/README.md?ref=develop), [Quiz README](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/quiz/README.md?ref=develop), [Blind Test README](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/blindtest/README.md?ref=develop), [Bingo README](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/bingo.game/README.md?ref=develop), sections Hub/pregame ; TASKS correspondantes consultées sur develop.
- [Runbook DEV](https://api.github.com/repos/cotton-games/documentation/contents/canon/runbooks/dev.md?ref=develop) et [markers WS](https://api.github.com/repos/cotton-games/documentation/contents/pm2-ws.md?ref=develop), lots locaux du 25/09.

Journal AI Studio consulté avant modification via le lecteur indiqué par START : `https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=<AI_STUDIO_READER_TOKEN>`. Réponse HTML : Markdown brut extrait de `const raw`. Modification serveur plus récente d’un fichier ciblé : **non trouvé**. Les entrées identifiées concernent notamment le site www et AI Studio, pas ces moteurs/probes. Aucun rechargement serveur prétendu. Aucun secret reproduit ici.

## Audit ciblé avant patch

| Axe | Fichiers / fonctions | Cause et différence moteur | Correction retenue / impact pregame |
|---|---|---|---|
| A Bingo | `ws/bingo_server.js` : `performBingoAuthentication`, `restoreHubRuntime` ; `ws/hub_lifecycle.js` : `restore` | Player/Paper/Remote restauraient E et les flags partagés avant publication d’un Client. Un objet conservé pouvait opposer E1 à E2. Audit B/C/E. | Lecture consommateur sans restore/Map autoritaire ; candidats primaires explicites et retrait des échecs. Rebind readiness uniquement après publication Organizer et pour la même preuve d’admission. |
| A Quiz/BT | `web/server/actions/registration.js`, `hubLifecycle.js`, `wsHandler.js` | Remote pouvait restaurer un objet non chargé ; Player pouvait demander le rôle primaire ; initialisation gameplay non réservée au propriétaire. Audit B/C/E. | Sérialisation registration par session ; rôle candidat figé ; Remote sans restore ; objet provisoire retiré ; publication après restore et résolution primaire SQL réussis. Guard des writers runtime. Le relais d’options Remote reste un relais au Master. |
| B commun | `play/register.js`, `play/play-ws.js`, `core/api/api_client.js`, `php/boot_lib.php` | Clé event_id existante mais erreurs transitoires non rejouées ensemble avec E/identité ; boucle hydrate sans arrêt terminal corrélé. | Retry HTTP borné pour mapping Hub actif ; même body/E/identité/event_id ; admission serveur revalidée avant write. Retry registerPlayer Quiz/BT du même payload, jamais registerOrganizer. Aucun nouvel ensure, reset ou parcours d’inscription. |
| C commun | `play/register.js:tryConnectWebSocket`, attentes WS Master/Remote/Player, `hub_runtime_wait.js`, `hub_pregame.js` | `_wsProbePromise = new Promise(() => {})` ne terminait jamais et bloquait les concurrents ; timers/callbacks mal nettoyés ; attente START pouvait rester pendante après fermeture. | Vraie Promise partagée, cleanup, timeout/abort ; garde E avant callbacks ; clôture des attentes START sur fermeture/abort/E différente. Aucun délai métier ajouté. |

Compte rendu avant écriture fourni à l’opérateur dans la conversation : fichiers, causes, invariants et stratégie de tests simulés. Le complément backport est une analyse en lecture seule.

## Contrat effectivement implémenté

- **Organizer = publication d’autorité.** Dans Quiz/BT, une socket Player/candidate Player ou Remote ne devient pas primaire ; une session neuve porte `hubAuthorityEstablished:false` jusqu’à la publication. Toute erreur avant publication retire le candidat et ses timers. La résolution de l’identifiant primaire SQL d’un Hub officiel ne peut plus échouer silencieusement tout en publiant un primaire.
- Bingo Player/Paper/Remote utilisent `readHubRuntime` / `hubLifecycle.read` : lecture E, contrôle suspension/expiration, aucune restauration, aucun resume, aucun gel du runtime partagé. Les consommateurs sont liés à leur E ; E2 n’hérite pas de consommateurs E1. Une auth Player transitoirement refusée ne remplace plus prématurément l’ancienne socket du même joueur.
- Un runtime déjà publié conserve le veto `HUB_EXECUTION_MISMATCH`, même sans socket primaire actuellement ouverte. L’absence momentanée du Master ne suffit jamais à déclarer la partie orpheline. Un mismatch d’un candidat ne gèle pas le propriétaire actif. Collision Bingo de session sur une même playlist active refusée.
- Les objets provisoires sont retirés avant une nouvelle tentative primaire sérialisée ; E2 fraîche peut alors être restaurée sans reprendre l’état E1. Le contexte E fourni par Organizer est comparé à la lecture canonique. Les contrats d’authentification existants sont conservés : ce lot ne crée pas un nouveau mécanisme de credentials Organizer.
- **Retries HTTP** : `player_register` et `grid_assign`, trois tentatives maximum ; `grid_hydrate`, cinq. Backoff technique de 250 ms × numéro de tentative ; timeout HTTP existant de 10 s par tentative. Coalescence des appels identiques ; event_id conservé tant que succès non reçu. Erreurs métier terminales non rejouées ; transport/HTTP transitoire et erreurs d’indisponibilité rejoués. Hydrate peut attendre une grille encore absente, sans appeler reset.
- Activation de ces retries HTTP uniquement avec E et mapping Hub actif déjà connu. Papier, démo et inscriptions autonomes conservent leurs parcours. Le dispatcher revalide E + participation active/joinabilité avant chaque write corrélé. Un changement distant non encore reçu est arrêté par cette revalidation ; les signaux locaux d’arrêt annulent immédiatement la requête et le backoff. Le garde local de contexte est vérifié au retour et pendant l’attente (100 ms).
- **Retry WS Quiz/BT** : trois tentatives de `registerPlayer` du même payload, attente ACK bornée à 10 s, erreurs transitoires uniquement. Fermeture socket annule l’opération ; le connecteur existant reste responsable de la reconnexion. ACK corrélé à E ; jamais installation/restauration d’un primary. Le mécanisme de reconnexion physique Bingo existant n’est pas remplacé.
- **Probes** : succès, erreur, timeout et abort terminent les attentes techniques, nettoient handlers/listeners/timers et libèrent les flags. Une réponse tardive ne peut pas modifier le nouvel E. Le bootstrap Master souscrit à l’ACK avant émission et vérifie encore E avant publication runtime-ready.
- L’attente persistante de readiness Master reste un observateur jusqu’au ready ou à un abort explicite (sortie, gel, changement d’E). Son seuil existant reste diagnostique : ce n’est pas une nouvelle deadline de lancement. La demande START garde son request_id et son retry existant ; fermeture/abandon/changement d’E/slot fermé terminent son attente sans abandon métier implicite.

Invariants conservés : règles Open/readiness/lancement, mêmes E et compteur, aucun quorum/plafond ajouté, jauge client, cinq secondes de calme / watchdog existants, Remote secondaire, reveal natif et reprises ; papier/démo. Open et Abandon ne déclenchent pas de reset Bingo ; seul le départ canonique le conserve.

## Validation locale et limites

Services, sockets, horloges et DB simulés ; **aucune recette DEV/PROD ni navigateur** pour ce patch.

- Suite ciblée : **128 tests verts** (autorité, capacité, client retry/probes, Remote Quiz/BT, reset/suspension/Remote Bingo, attente runtime).
- Suite pregame/routage : **156 tests verts**, dont vagues simulées jusqu’à 5 000 sockets, zéro joueur, abandon, perte d’ACK, retrait, même E et reveal Remote/presence.
- Suspension/reprise : **35 tests verts**, y compris conservation de l’état runtime et reprise aux différentes durées simulées.
- PHP : **54** gardes réels du dispatcher retry ; **133** assertions admission ; **288** assertions reprise Master/Remote ; **42 093** assertions de la matrice pregame existante (simulations, pas une mesure de charge).
- Les anciens tests moteurs échouaient déjà sur la baseline HEAD : 58 échecs de mocks sur 71 (prégame absent des doubles / node:crypto non pris en charge). Baseline extraite en `/tmp/hub-robustness-baseline`, sans modification de branche. Doubles mis à jour ; 23 tests Bingo et 48 tests Remote historiques passent, puis deux tests supplémentaires vérifient les writers interdits et le relais d’options. Les tests lifecycle de reprise simulent désormais aussi E, réellement renvoyée par le service.

Commandes principales depuis `games` :

```sh
node --test --test-concurrency=1 web/tests/hub_execution_authority_test.cjs web/tests/hub_capacity_runtime_test.cjs web/tests/hub_player_retry_probe_test.mjs web/tests/hub_runtime_wait_test.mjs
node --test --test-concurrency=1 web/tests/hub_pregame_flow_test.cjs web/tests/hub_pregame_autostart_test.cjs web/tests/hub_pregame_removal_test.cjs web/tests/hub_pregame_cta_test.cjs web/tests/hub_pregame_proof_transport_test.cjs web/tests/hub_embed_remote_reveal_test.cjs web/tests/hub_bingo_native_registration_test.cjs web/tests/hub_remote_presence_test.mjs
node --test --test-concurrency=1 web/tests/hub_suspend_test.mjs web/tests/hub_runtime_suspension_time_test.cjs
php web/tests/hub_player_retry_guard_test.php
php web/tests/hub_hotfix_admission_test.php
php web/tests/hub_active_resume_test.php
php web/tests/hub_pregame_regressions_test.php
```

Attendu : aucune assertion échouée ; les probes simulées ne conservent aucun timer/listener/flag. Les tests moteurs sont dans `quiz/tests/remote-continuity.test.cjs`, `blindtest/tests/remote-continuity.test.cjs` et `bingo.game/ws/tests/{hub_suspend,remote_continuity,bingo_reset}.test.js`.

## Comparaison réelle main / develop / branche de travail

Références locales lues par `git show`/`rev-parse`, sans fetch ni accès serveur. Les branches applicatives de travail sont **pregame**, et diffèrent de develop. La parité des processus actuellement en PROD avec ces références est **non trouvée** dans cette exécution et n’est pas déduite de la documentation.

| Dépôt | main | develop | base pregame du patch |
|---|---|---|---|
| games | `eaf053953234` | `786480de1ebc` | `cbd2b2526381` |
| bingo.game | `a62ebad9dfa4` | `1038c05539bf` | `6f9f36c02aa6` |
| quiz | `b3d1419dd3cc` | `3ddc167a6c11` | `bbd4af0c62ed` |
| blindtest | `9b898ae6b752` | `2823bc817ffa` | `18c098977ee9` |
| global | `c9320295267c` | `9147983a8121` | `97c8e9a975b3` |

Aucun commit de correctif créé : **aucun SHA à cherry-picker** à ce stade. Les fichiers ci-dessous sont les deltas nécessaires ; les commits pregame/develop complets ne sont pas des prérequis à importer. Comparaison et diffs locaux : `/tmp/hub-robustness-backport/final-comparison.json`, `<repo>.patch`. Vérification d’applicabilité uniquement par `git apply --check` dans des copies des fichiers main, sans application du patch à ces copies ni aux branches main.

### Classement par composant

« Tel quel » signifie **delta ciblé + dépendances listées**, jamais copie du fichier entier depuis pregame/develop. Les tests sur main restent à exécuter après autorisation d’une adaptation ; un dry-run propre n’est pas une validation runtime.

| Catégorie | Composant | Preuve / dépendances / adaptation |
|---|---|---|
| **Backportable tel quel** | A Quiz/BT : `hubLifecycle.js`, `registration.js`, `wsHandler.js` ensemble | Hunks applicables à main. `hubSuspension.restore`, `remoteOwnership`, `cleanupHubRuntime`, résolution SQL et E canonique existent déjà sur main. Les nettoyages de champs pregame optionnels sont sans effet quand absents ; aucun contrôleur pregame importé par le delta. Les trois fichiers de chaque moteur forment un sous-lot cohérent. |
| **Backportable tel quel** | Helper lifecycle Bingo `ws/hub_lifecycle.js` | Lecture sans mutation + contrôle E + préservation du runtime actif : protocole read/restore déjà présent. À associer au changement des appelants Bingo ci-dessous ; le helper seul ne supprime pas la cause du bug. |
| **Backportable tel quel** | C probe `tryConnectWebSocket` dans `play/register.js` | Promise orpheline également présente sur main ; même protocole checkSession/sessionStatus, aucun besoin de pregame. Isoler ce hunk permet un premier lot Games seul. |
| **Backportable tel quel** | C attentes WS `remote/remote-ws.js`, `core/ws_effects.js`, `core/hub_runtime_wait.js` + petit raccord `boot_organizer.js` | Fonctions et observateur persistant déjà présents sur main ; deltas applicables. Contexte hubOrganizer/E et Bus existants. Conserver le couple helper/appelant readiness. Aucune règle de reveal natif transférée. |
| **Backportable tel quel** | B helper `play/player_retry.js`, signal dans `core/api/api_client.js`, raccord HTTP `play/register.js` | main possède déjà event_id stable, mapping Hub et hubPresentation. Imports relatifs et API rawResponse existent. **À livrer avec le garde PHP adapté**, pas de retry client sans fence serveur. Les références optionnelles hubPregame ne sont pas une dépendance obligatoire. |
| **Backportable avec adaptation ciblée** | A Bingo `ws/bingo_server.js` | Conflits de contexte au raccord pregame ; supprimer du backport le replay `hubPregame.bind` et adapter le bloc restore à la version main sans `hubPregame.restore`. Conserver lecture consommateurs, rôle, retrait provisoire, publication après validation et refus E/collision. Le coordinateur `runBingoResetCommand` existe déjà dans main : le reset n’impose pas d’importer pregame. |
| **Backportable avec adaptation ciblée** | B PHP `php/boot_lib.php` | main n’a ni les variables/guards pregame, ni le finally de ce chantier : placer uniquement le nouveau contrôle E/admission au début du try de `game_api_dispatch`. `canvas_api_hub_lifecycle` et `canvas_hub_admitted_player_check` existent déjà. Aucun changement Global nécessaire. |
| **Backportable avec adaptation ciblée** | B/C `play/play-ws.js` | Le fichier a évolué autour du pregame : replacer le helper `registerPlayerWithRetry`, la corrélation E du routage et le remplacement local de waitForWSOpen sur le code main. `hubPresentation`, registerPlayer et les événements WS sont déjà disponibles ; ne pas copier les handlers UI pregame. |
| **Dépendant de develop / à ne pas isoler** | C `core/hub_pregame.js`, replay readiness Bingo et tests spécifiques START/slot | Contrôleur START/retry/phase et bind readiness absents de main. Garder sur pregame ; ils ne sont requis ni par les fences d’autorité historiques, ni par le correctif de probe. Aucun prétexte à importer V2 pour livrer A ou B. |
| **Backportable avec adaptation ciblée** | Tests, markers et documentation de livraison | Les fixtures récentes mentionnent pregame ; sur main utiliser les variantes historiques et ajouter les nouveaux cas autorité/retry/probe. Choisir des markers propres au lot PROD retenu ; ne pas présenter le /05 de pregame comme une livraison. |

### Proposition de découpage PROD, sans exécution

1. **C probes seules** : isolable rapidement, sans moteur ni pregame. Corrige les attentes concurrentes bloquées ; **ne corrige pas à lui seul l’autorité du 24/09**.
2. **A autorité** : Quiz/BT peuvent prendre leur sous-lot cohérent ; Bingo nécessite l’adaptation ciblée du serveur. Ce lot vise directement les mécanismes de risque de l’audit, sans prétendre prouver l’origine de l’incident du 24/09. Réserver une validation de reprise/papier/démo avant livraison.
3. **B retries** : livrer helper + signal API + callers + fence PHP ; registerPlayer WS nécessite aussi les codes de refus/corrélation du sous-lot A. Ne pas activer des retries write sans garde E et idempotence.

Risques spécifiques main : lecture canonique indisponible = refus d’admission plutôt que publication dégradée ; tokens/contexte E anciens peuvent maintenant être refusés explicitement ; double Master/reprise doit conserver le propriétaire et le snapshot ; Bingo ne doit pas conserver des sockets E1 dans E2, ni provoquer de reset lors d’Open/retry. Le coût des lectures supplémentaires d’admission doit être observé après autorisation ; les tests 5 000 sont synthétiques.

Tests minimum à rejouer sur main après adaptation autorisée : matrice des trois moteurs Player/Remote avant Master, orphelin E1→E2, E1 actif protégé, E stale/mismatch, fermeture pendant auth et double Master ; admission/retry même E/identité/event_id, terminal/left/removed et erreurs transitoires ; probes succès/reject/timeout/abort/concurrence/reconnexion ; parcours de lancement **historique main**, reprise papier/démo, reset Bingo uniquement au départ, grille/secret/propriétaire conservés. Aucun test START/pregame ne remplace cette recette historique.

## Fichiers applicatifs et tests du delta local

- `games/web/includes/canvas/core/api/api_client.js`
- `games/web/includes/canvas/core/boot_organizer.js`
- `games/web/includes/canvas/core/hub_pregame.js`
- `games/web/includes/canvas/core/hub_runtime_wait.js`
- `games/web/includes/canvas/core/ws_effects.js`
- `games/web/includes/canvas/php/boot_lib.php`
- `games/web/includes/canvas/play/play-ws.js`
- `games/web/includes/canvas/play/register.js`
- `games/web/includes/canvas/remote/remote-ws.js`
- `games/web/tests/hub_capacity_runtime_test.cjs`
- `games/web/tests/hub_pregame_cta_test.cjs`
- `games/web/tests/hub_runtime_wait_test.mjs`
- `games/web/tests/hub_suspend_test.mjs`
- `games/web/includes/canvas/play/player_retry.js`
- `games/web/tests/hub_execution_authority_test.cjs`
- `games/web/tests/hub_player_retry_guard_test.php`
- `games/web/tests/hub_player_retry_probe_test.mjs`
- `bingo.game/version.txt`
- `bingo.game/ws/bingo_server.js`
- `bingo.game/ws/hub_lifecycle.js`
- `bingo.game/ws/tests/bingo_reset.test.js`
- `bingo.game/ws/tests/hub_suspend.test.js`
- `bingo.game/ws/tests/remote_continuity.test.js`
- `quiz/tests/remote-continuity.test.cjs`
- `quiz/web/server/actions/hubLifecycle.js`
- `quiz/web/server/actions/registration.js`
- `quiz/web/server/actions/wsHandler.js`
- `quiz/web/server/restart_serveur.txt`
- `blindtest/tests/remote-continuity.test.cjs`
- `blindtest/web/server/actions/hubLifecycle.js`
- `blindtest/web/server/actions/registration.js`
- `blindtest/web/server/actions/wsHandler.js`
- `blindtest/web/server/restart_serveur.txt`

Documentation : cette note, complément historique de l’audit, README/TASKS des quatre dépôts modifiés, TASKS Global (audit/backport sans patch), README/TASKS documentation, interfaces actions/canvas-bridge, bingo-write-map, entrypoints/runbook DEV, pm2-ws, HANDOFF, CHANGELOG et index/sitemaps régénérés.

Markers préparés localement : Quiz/BT `web/server/restart_serveur.txt`, Bingo `version.txt` = `restart 25-09-2026/05`. **Aucun redémarrage exécuté.**

Rollback : retirer uniquement ce delta de robustesse et restaurer les markers /04 ; conserver tous les correctifs pregame/reveal/reprise antérieurs. Diffs de référence dans `/tmp/hub-robustness-backport/`. Ne pas utiliser un checkout global ni annuler les branches pregame. Toute action sur main ou serveur exige l’accord explicite de l’opérateur.
<!-- AUTO-UPDATE:END id="hub-execution-robustness-20260925" -->
