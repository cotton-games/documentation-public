# PATCH 2 — Corrections papier et podium de session Hub — 21/09/2026

<!-- AUTO-UPDATE:BEGIN id="paper-score-patch2-report" owner="codex" -->
Patch local terminé, sans déploiement. PATCH1 validé en recette DEV **selon l’utilisateur** ; modifications préexistantes conservées. Aucun SSH, DB réelle, service applicatif DEV/PROD, navigateur intégré, déploiement ou restart. Lecture seule des copies `games/logs` et `global/logs` rechargées par l’utilisateur. [Contrat canonique](../canon/interfaces/paper-score-corrections.md).

## A. Résolution K/D

Les deux anciens `adminSetScore` utilisaient `playerId ?? player_id` alors que `session.players[].playerId=K` et `playerDbId=D`. Nouveau resolver identique dans `actions/paperScore.js` des deux moteurs : K exclusive, vérification D, fallback D-only via `playerDbId`, conflits explicites. PHP partage le même contrat dans `paper_score.php`. L’absence mémoire se répare uniquement via l’hydratation PATCH1 sur participation persistée active ; aucune création par le score.

## B. Correction vers le bas

Les anciens glues avaient un upsert canonique avec `GREATEST` et `is_active=1`. La nouvelle intention papier sort avant ce chemin : UPDATE exact, lecture confirmée, transaction avec reçu `game_events`. 0→10, 10→3, 3→0, même valeur et borne INT positive testés. Gameplay monotone conservé et exécuté dans le test PHP. Pas de schéma/migration.

## C. Persistance vs synchronisation live

Réponse HTTP complète demandé/confirmé/K/D/request ID, réussite distincte du live. Remote : HTTP sérialisés, message « enregistré », badge de synchronisation non bloquant après persistance, ACK WS corrélé, retry5s/clic/sessionStorage. Timeout HTTP : reçu inconnu conservé/rejoué avec le même ID ; refus métier explicite distingué. Une réponse WS ancienne n’efface pas une action récente.

## D. Réconciliation

Le runtime relit le score persisté, jamais le score du vieux message. `reconcileScores=true` réutilise le lecteur actif et le bind PATCH1, puis republie liste/classement pour Master et Remote. Les hydrations de score attendent les anciennes lectures roster. La maintenance5s récupère aussi les corrections dont aucun WS n’est arrivé. Gardes de suspension/expiration/admission/activité conservées ; hydratation ordinaire sans intention de score inchangée.

## E. Finalisation et podium Hub

Finalizer : sérialisation, relecture confirmée, snapshot K→score, classement canonique existant, persistance terminale. Le contrôle PHP sous verrou commun refuse un snapshot périmé avant l’écriture du podium/statut. Si une correction gagne la course SQL, la fin échoue explicitement puis peut être retentée ; si la fin gagne, la nouvelle correction est refusée. Aucun score mémoire ancien réécrit en DB. Le compteur papier terminal ne dépend plus du nombre de sockets connectées.

### Incident Hub341 : preuves distinctes de la correction de score

Les logs fournis ne démontrent pas une absence de production/persistance des deux podiums terminés. Ils prouvent leur disponibilité côté Hub **avant** l’ajout numérique :

| Heure du journal du21/09 | `games/logs/error_log` | Preuve |
|---|---:|---|
|17:40:43|44072|`hub_natural_end_podium_available`, moteur Bingo, session27927 ; `hub_paper_execution_completed`|
|17:47:30|45183|mêmes événements, moteur Blind Test, session27926|
|17:47:32|45188|3 sessions,2 terminées,2 résultats exploitables,3 groupes podium agrégé|
|17:55:15|46055|`presentation_mode=hub_idle`, raison `overlay_close_button`|
|17:55:28|46088|session27927 sélectionnée explicitement, `active_session_id=0`|
|17:55:33|46094|toujours3 sessions et2 résultats exploitables|
|17:55:58|46149|4 sessions, toujours2 résultats exploitables et3 groupes agrégés|

Session27925 : suspendue selon le scénario utilisateur et le fallback `first_suspended_program_order` journalisé ; pas de preuve de finalisation Quiz dans cette séquence. `global/logs` consulté, pas de preuve complémentaire de rendu podium pour ce Hub dans les événements ciblés. Aucun pseudo, URL Hub, token ou IP recopié dans cette note.

**Cause reproduite avant patch** : `games_hub_master_presentation_selection_resolve` sélectionne bien la session, puis `games_hub_presentation_state_resolve` impose `hub_podium` avec `auto_all_sessions_finished_or_suspended`. Cette condition inclut une session suspendue (`running` sans focus actif). Le renderer masque les podiums de session ; après fermeture de l’automatique, `hubMasterPresentationModeAfterRefresh` peut transformer ce mode en `hub_idle`, expliquant l’absence simultanée du podium agrégé **et** des podiums de session. Le journal prouve les données et les changements de sélection ; la valeur effective de cette variable JS n’est pas journalisée dans ces copies, sa séquence est reproduite en VM. Ajouter une session prête rend `auto_eligible=false` et évite ce remplacement sans produire de nouveau résultat.

**Correctif** : dans le resolver de présentation commun Games, le podium exploitable de la session terminée sélectionnée prime sur cette seule règle automatique. Choix explicites podium général/accueil conservés. Ce défaut est indépendant des scores Quiz/BT et n’est pas spécifique au papier. Le test25 contrôles inclut chaque moteur et «1 suspendue +2 terminées», avec/sans session numérique prête ; un test exécute le vrai renderer et le traitement du podium automatique fermé.

### Complément — consultation après fin du Hub

Défaut supplémentaire reproduit puis corrigé : `closeHubPodium` passe à `hub_idle` ; `selectCard` et `applySelectionIntent` ne revenaient au mode `session` que depuis `hub_podium`. Un clic après fermeture changeait donc la carte sans rendre son podium. Les deux transitions acceptent maintenant aussi `hub_idle`. Les sélections explicites affichent immédiatement le podium ; initialisation/fermeture gardent leur `keepHubPresentation` et ne forcent pas une consultation. Le endpoint de sélection conserve le statut terminé et le focus runtime ; aucune interdiction métier « Hub terminé » n’a été trouvée sur ce chemin.

Fichiers applicatifs de ce complément : Games `web/modules/app_hub_view_helpers.php`, test existant `web/tests/paper_podium_render_test.mjs` étendu. Test rouge avant correctif (`hub_idle` au lieu de `session`), vert ensuite : fermeture agrégée→sélection terminée→rendu immédiat/persistance, initialisation passive et intention Remote. Régressions projection Hub25 contrôles, mobile5 tests et séparation présentation/runtime réussies ; lint PHP et diff-check. Journal AI Studio reconsulté inchangé (hors fins de ligne). Aucun service/DB réelle/navigateur/déploiement/restart. Rollback ciblé complément : inverser les deux conditions JS ; copie préalable `/tmp/hub-podium-completed-followup-before.php`.

### Trace par moteur

|Étape|Quiz|Blind Test|Bingo|
|---|---|---|---|
|Finalisation moteur|`finalizePaperScores` → `endGame` → classement canonique|Même chaîne individuelle, équipes toujours désactivées|`bingo_server.js`, message `end_game` ; résultats par phases déjà attribuées|
|Persistance|`persistPodium` → `quiz_api_session_update` → `cotton_quiz_sessions.podium_json`|Même chaîne → `blindtest_sessions.podium_json`|`bingo_api_phase_winner` → `bingo_phase_winners` ; `bingo_api_end_game` → phase999|
|Projection Hub session|Global `app_session_results_get_context`, type5, normalisation JSON ; repli ranking scores|Global type4, même normalisation/repli individuel ; lecteur équipes historique inchangé|Global types2/3/6, gagnants phase→rang1/2/3 ; aucun repli podium depuis de simples participants|
|Podium disponible|`has_podium` puis `games_hub_result_podium_rows` et `has_usable_podium`|Idem|Idem ; des gagnants de phases sont nécessaires|
|Rendu Master|Sections `data-hub-central-podium` + `renderCentralForSelectedSession`|Idem|Idem, libellé de phase affiché au lieu de points|

Diagnostic différencié : (1) aucun résultat produit → données insuffisantes ; (2) résultat produit mais write échoué → finalisation refusée Quiz/BT ; (3) persistance existante mais projection vide → vérifier statut terminé, normalisation rang/libellé et, Bingo, gagnants de phases ; (4) projection disponible mais cachée → mode/sélection de présentation, cause reproduite ici. Il n’existe pas de veto papier dans cette sélection. Les fonctions réelles de projection Global sont testées avec mysqli factice ; le réseau complet moteur→Hub n’a pas été exécuté.

## F. Matrice Quiz / Blind Test

|Point|Quiz|Blind Test|
|---|---|---|
|K canonique|Prioritaire exclusive|Identique|
|Fallback D|`playerDbId`, DB scoped|Identique|
|Correction ↓|UPDATE exact papier|Helper PHP commun|
|HTTP confirmé|Relecture et reçu atomique|Identique|
|Runtime confirmé|ACK corrélé et relecture DB|Identique|
|Finalisation réconciliée|Reload + comparaison sous verrou|Identique|

## G. Fichiers modifiés par ce patch

Games :

- `web/games_ajax.php` : délégation de l’idempotence papier au helper atomique.
- `web/includes/canvas/php/paper_score.php` (nouveau), `quiz_adapter_glue.php`, `blindtest_adapter_glue.php` : correction/lecture/contrôle final.
- `web/includes/canvas/remote/paper_score_sync.js` (nouveau), `remote-ui.js`, `remote-ws.js` : ordre HTTP, reçu et ACK, indicateur/retry.
- `web/modules/app_hub_view_helpers.php` : priorité du podium sélectionné et diagnostic borné au rendu.
- Tests nouveaux : `paper_score_http_test.php`, `paper_score_runtime_test.cjs`, `paper_score_sync_test.mjs`, `paper_podium_hub_test.php`, `paper_podium_render_test.mjs`, `paper_score_test_helpers.php`, `paper_score_patch2_suite.mjs`.

Quiz et Blind Test, chacun : `web/server/actions/paperScore.js` (nouveau), `gameplay.js`, `registration.js`, `wsHandler.js`, `web/server/restart_serveur.txt` (`restart 21-09-2026/04`). Aucun fichier applicatif Global ou Bingo modifié par PATCH2. Leurs diffs préexistants sont conservés.

## H. Tests

Depuis `/home/romain/Cotton` :

```sh
node games/web/tests/paper_score_patch2_suite.mjs
```

8/8 groupes réussis : PHP correction/finalisation **98 contrôles**, vrais handlers runtime Quiz/BT avec API simulée, Remote concurrence/retry, projection/presentation Hub **25 contrôles**, renderer réel isolé, mobile podium **5 tests**, séparation présentation/runtime, suite PATCH1 **14/14 suites**. Cas couverts : K seul, K+D, D seul, conflit, inconnu, absent mémoire/DB présent, inactif, hausses/baisses/zéro/égalité/borne, retry HTTP ancien après nouvelle correction, ordre10→3→8 et ACK inversés, indisponibilité runtime, reconnexion Remote, finalisation en échec puis reprise, correction hausse/baisse avant fin, ex æquo et rang3 après baisse. La suite PATCH1 garde ajout tardif/already_active/snapshots partiels/reprise et régressions Bingo.

Tests sur doubles de stockage/transport, **pas de validation MySQL multi-processus ni d’intégration HTTP/WS/auth réelle**. Les assertions SQL vérifient la transaction/verrou et la relecture, sans prétendre mesurer le comportement d’un serveur réel. Les suites historiques globales déjà défaillantes dans PATCH1 ne sont pas déclarées vertes ici. Contrôles syntaxiques PHP/JS, `git diff --check` et générateur sitemap/index exécutés en complément.

## I. Documentation

Nouveau contrat papier score, présent rapport ; README/TASKS Games/Quiz/Blind Test ; contrat PATCH1 clarifié sur le rechargement explicite des scores ; actions/bridge ; règle de routing dédiée ; HANDOFF, CHANGELOG, entrées/runbooks et markers. Index/sitemaps régénérés uniquement par `npm run docs:sitemap`. [Note future équipes](hub-team-model-future.md) distincte du contrat runtime.

## J. Risques / hors périmètre / rollback

- Livraison coordonnée PHP/Remote/Quiz/BT requise : finalizer ancien sans snapshot refusé explicitement. Aucun changement de port/env/process.
- Relecture entière du roster pour réutiliser PATCH1 ; elle reste bornée à5s hors demandes de correction/finalisation. Une indisponibilité HTTP conserve l’état non confirmé et la fin est refusée.
- Saisies de Remotes indépendantes : ordre de commits DB, pas d’ordre universel de leurs horloges. L’UI sérialise ses propres corrections ; retries d’actions acceptées idempotents. `expected_score` disponible pour clients demandant un contrôle concurrent explicite.
- Un écart de population active DB/admission empêche la finalisation au lieu de publier un podium incomplet. Aucune réparation de données legacy entreprise.
- Rollback local : inverser uniquement les diffs PATCH2/nouveaux fichiers, conserver PATCH1 et les autres travaux. Copie préalable des fichiers édités dans `/tmp/paper-score-patch2-baseline/` ; ne pas faire de reset global. Après une livraison future, préserver le lecteur/reçu atomique si des corrections ont déjà été utilisées.
- **NON traité : Bingo D-only winner ; chantier équipes Blind Test ; futur modèle équipe Hub** (note de cadrage uniquement). Aucun déploiement, restart, SSH ou DB réelle.

Lectures préalables : [START RAW main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), sections «Discipline de génération» et «Règle preuve d’abord» ; [SITEMAP develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), routing ; [Manifest RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), «Routing rules» et «Server restart markers». Journal AI Studio RAW indiqué par START consulté : aucun changement ciblé postérieur signalé. Contrat/rapport PATCH1 et audit transversal du21/09 relus avant modification.
<!-- AUTO-UPDATE:END id="paper-score-patch2-report" -->
