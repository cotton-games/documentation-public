<!-- AUTO-UPDATE:BEGIN id="remote-bootstrap-regressions-20260918" owner="codex" -->
# Régressions Remote après patch transversal — 18 septembre 2026

**Mise à jour : takeover/rattachement tardif validés en DEV par l’utilisateur.** Le diagnostic ci-dessous conserve les limites de preuve de cette passe ; cette validation ne prouve pas rétrospectivement la cause du cache mobile. Un [correctif UX distinct](remote-takeover-exit-2026-09-18.md) traite désormais la sortie de l’ancienne Remote sur takeover. **Statut au moment de l’audit initial : corrections locales testées ; validation DEV non acquise.** Le mobile affiche la Remote sans commandes utilisables ; le « Master historique » est le Master de session ouvert depuis Hub. Les observations ne permettent pas d’attribuer avec certitude le symptôme mobile au cache. Aucun accès aux environnements ni navigateur utilisé.

## Contrôle préalable — preuves documentaires

- [START RAW main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), section « Statut actuel (important) / Current status (important) » : develop décrit le travail en cours, main l’état publié. Aucune parité de fichiers déployés déduite de cette convention.
- [SITEMAP RAW develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), entrées `canon/repos/games`, `canon/repos/quiz`, `canon/repos/blindtest`, `canon/interfaces/actions.md`, `canon/interfaces/canvas-bridge.md` : routage documentaire. README et HANDOFF publics également consultés.
- [Manifest RAW develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), sections « Update triggers (mapping) », « Routing rules (paths/globs → docs) » et « Server restart markers » : README/TASKS, contrats, passation, génération sitemap/index et markers WS.
- Journal public AI Studio RAW demandé : contenu Markdown extrait de l’enveloppe `const raw`. Des changements WWW/e-commerce/global_librairies sont signalés ; fichier ciblé par cette correction à recharger : **non trouvé**. Copie locale de contrôle : `/tmp/remote-regression-preflight/journal.md`. Aucun reload serveur effectué.
- Preuve documentaire publique de la version exécutée par le mobile : **non trouvé**. Les logs rechargés et le code local sont les seules preuves opérationnelles disponibles.

## A. Takeover — cause prouvée et limite du diagnostic

Bingo, client10, runtime17079 : le 18/09 à12:55:31 Paris, `AUTH_OK` Remote puis `REMOTE_REPLACED` avec `replacement_reason=takeover`, puis close4004 de l’ancienne Remote. Voir copie locale `bingo.game/ws/server-logs.log:35568`, `:35570`, `:35573`. Le serveur a donc accepté ce takeover. Aucune preuve ne justifie de modifier son registre. Les ouvertures HTML ultérieures sans nouvel AUTH ne prouvent pas une garde WS bloquante ; certaines requêtes reçoivent aussi403, sans modification du contrôle d’accès dans cette passe.

Le patch précédent introduit des imports nommés dans `remote-ws.js` (`hubSurfacePageId`) et `remote-ui.js` (`hubSuspendTrace`). Les modules parents sont versionnés, mais leur dépendance relative `../core/hub_runtime_authority.js` ne l’était pas. Avec une ancienne version déjà en cache, le navigateur peut refuser la liaison ESM avant toute exécution : HTML visible, JS inactif. Le test charge les imports réels et la vraie import map PHP, reproduit les exports absents puis passe avec la dépendance versionnée. **Ce défaut existe, mais sa responsabilité dans le mobile signalé reste non confirmée faute de trace console/cache.** L’authentification réussie à12:55:31 ne peut pas être expliquée par un échec ESM antérieur de ce même document.

Quiz/Blind Test : l’ancienne garde globale du dispatcher assimilait une socket portant déjà le rôle Remote à une propriétaire obligatoire, même pour `checkSession` ou `registerOrganizer`. C’est un invariant incorrect pour une candidate. Les tests le reproduisent pour une candidate étiquetée, mais **la socket neuve normale sans rôle passait déjà**. Aucune candidate étiquetée n’est attestée dans les logs DEV : ce défaut latent ne constitue pas la cause démontrée du takeover Bingo observé.

## B. Remote tardive — prérequis de présence absent

Session27869, Hub325 : lancement12:57:39, GET Master12:57:41 sans `hub_routing_generation` (`games/logs/access_log:2529`), registration primaire BT acceptée12:57:42 (`blindtest/web/server/server-logs.log:7064`, `:7067`, `:7068`). Aucun `registerOrganizer isPrimary:false` n’est présent dans cette séquence BT ; les POST de présence Games échouent en HTTP400. Il faut donc examiner le bootstrap en amont du WS Remote.

`games/web/organizer_canvas.php` initialisait `routingGeneration` à `$_GET['hub_routing_generation'] ?? 0`, alors que le builder de nouvelle URL Hub peut omettre ce paramètre. Le validateur Global exact refuse légitimement cette génération0 ; le Hub ne peut ensuite router automatiquement une Remote vers un runtime sans présence exacte. La reproduction avec le vrai bloc PHP produit0 au lieu de12 et échoue avant patch. Cela établit la dépendance producteur indispensable au rattachement tardif ; l’absence du corps de chaque400 interdit de prétendre avoir identifié individuellement toutes ces réponses.

Correction limitée : seulement si le paramètre URL est **absent**, reprendre la génération retournée par le contexte canonique existant, avec `matched=true` pour la session source et l’exécution déjà résolues. Un paramètre présent, même0 ou obsolète, reste inchangé et refusé par Global. Aucune autorité, publication, intention, sélection de focus ou permission de reprise n’est créée. Le rattachement ne dépend pas d’une Remote au lancement.

## C. Correctif et cartographie des gardes

| Point réel Quiz/Blind Test | Politique et état |
| --- | --- |
| `remoteOwnership.state` | `candidate` si jamais promue ; `owner` si référence courante admissible ; `revoked` si retirée ; `obsolete` si déjà promue mais plus courante. |
| `wsHandler` → `allows` | Candidate : découverte `checkSession`, `remoteGameState`, `getGameState` et registration secondaire. Mutations ordinaires réservées à owner ; pas de changement vers joueur/primary. Révoquée/obsolète refusée. |
| `registration.registerOrganizer` avant/après attentes | Refus des retirées ; admission des candidates ; marquage `__remoteCandidate` avant l’attente SQL pour interdire les commandes durant la résolution. Contrôles existants de socket fermée, runtime supprimé/terminal et suspension conservés. |
| `acceptSecondary` | Marque l’ownership établie, retire le statut candidate et publie l’unique propriétaire. La classification continuité/takeover existante est conservée. Anciennes références révoquées avant tout callback send/close. |
| `connection.handleDisconnect` | Garde nécessaire inchangée : ignore ancienne référence/remplacée ; ne détache jamais la successeure. |
| `remoteOwnership.identity`, `replacementReason` | Normalisation page/navigateur et classification inchangées. Autre appareil/page active reste takeover ; même page reconnectée reste silencieuse. |
| Quit legacy | Propriétaire courante obligatoire, même sans rôle Remote annoncé. |
| Lifecycle `hubLifecycle.js` | Aucun nouveau usage ni changement cette passe ; diagnostics et règles de suspension conservés. |

Games : `registerRemote` est exposé au callback `window.reRegisterOrganizer` déjà appelé par le connecteur standard à la reconnexion. Avant correction, aucune trame de réinscription n’était émise à cette étape. `remotePageId` reste le même dans un même document ; aucune nouvelle identité persistante. Le garde du transport retraité reste effectif.

`remote_canvas.php` mappe l’URL résolue de la dépendance `hub_runtime_authority.js` vers sa version `filemtime`, et versionne également le script de lifecycle démo déjà modifié dans la passe antérieure. Le code de ces deux dépendances n’est pas modifié. La retraite silencieuse démo reste distincte du takeover réel et de la fermeture volontaire ; aucune nouvelle restauration de runtime terminal.

## D. Fichiers modifiés pendant cette correction

Périmètre comparé aux empreintes prises **au début de cette passe**, et non à HEAD (les patches précédents sont déjà présents).

- **Games** : `web/includes/canvas/remote/remote-ws.js` (callback), `web/organizer_canvas.php` (bootstrap absent), `web/remote_canvas.php` (versions) ; tests `web/tests/hub_remote_bootstrap_context_test.php`, `web/tests/remote_module_cache_test.mjs`, `web/tests/hub_remote_continuity_test.mjs`.
- **Quiz et Blind Test, chacun** : `web/server/actions/remoteOwnership.js`, `web/server/actions/registration.js`, `web/server/actions/wsHandler.js` ; `tests/remote-continuity.test.cjs` ; `web/server/restart_serveur.txt` préparé à `restart 18-09-2026/02`.
- **Global et Bingo** : aucun fichier modifié cette passe, contrôle SHA-256 depuis le relevé initial. `connection.js` et `hubLifecycle.js` Quiz/BT inchangés cette passe également.
- **Documentation** : `HANDOFF.md` ; `canon/repos/{games,quiz,blindtest}/{README,TASKS}.md` ; `canon/interfaces/{actions,canvas-bridge}.md` ; statut rectifié dans `notes/remote-ownership-transversal-2026-09-18.md` ; présente note ; `notes/INDEX.md` généré. Le script a aussi recalculé les sitemaps et autres index, sans différence de contenu supplémentaire par rapport au début de cette passe.

## E. Reproductions rouges avant correction

Sorties conservées dans `/tmp/remote-regression-preflight/` (preuves locales temporaires, non livrables serveur).

| Test avant modification du code concerné | Résultat |
| --- | --- |
| `bootstrap-before.txt` : vrai bootstrap Organizer, URL sans génération | Échec :0 au lieu de12. |
| `cache-before.tap` : exports requis par Remote WS/UI avec ancienne dépendance cachée | 2 échecs/2, exports manquants. |
| `candidates-before.tap` : vrais registration/connection/dispatcher Quiz+BT | 42 passent,6 échouent : par moteur, candidate étiquetée autre appareil, candidate étiquetée tardive et mutation pendant registration en attente. |
| `reconnect-before.tap` : vrai connecteur standard et vraie fonction de registration | 21 passent,2 échouent : pas de réinscription Quiz/BT au reconnect. |

Les scénarios neuf/autre appareil et tardif **sans étiquette préalable** passent avant et après. Ne pas les présenter comme des reproductions rouges de la régression utilisateur. Les nouveaux tests candidat vont jusqu’à la promotion, vérifient les commandes de la nouvelle Remote et le refus des commandes/quit/close tardifs de l’ancienne. Les tests d’intégration bootstrap/presence exercent le vrai matcher Global et le vrai validateur ; accès stockage remplacés par fixtures, aucun navigateur ni serveur réel.

## F. Validation après correction

| Suite | Résultat |
| --- | --- |
| Quiz : continuité Remote + grâce primaire | 70/70 |
| Blind Test : continuité Remote + grâce primaire + équipes désactivées | 85/85 |
| Bingo : continuité + suspension + reset + quit + terminal | 25/25 |
| Games : continuité/cache/suspension/démo/readiness/reprise/présence | 64/64 |
| PHP bootstrap commun, officiel/démo, Quiz/BT/Bingo | 48 contrôles |
| PHP suspension Games | 77 contrôles |
| PHP génération/présence Global inchangé | 21 contrôles |
| PHP readiness démo Games | OK |

Commandes depuis chaque dépôt (toutes terminées avec succès) :

```sh
# Quiz
node --test tests/remote-continuity.test.cjs tests/primary-grace.test.cjs
# Blind Test
node --test tests/remote-continuity.test.cjs tests/primary-grace.test.cjs tests/teams-disabled.test.cjs
# Bingo
node --test ws/tests/remote_continuity.test.js ws/tests/hub_suspend.test.js ws/tests/bingo_reset.test.js ws/tests/bingo_quit_guard.test.js ws/tests/bingo_terminal_delivery.test.js
# Games
node --test web/tests/hub_remote_continuity_test.mjs web/tests/remote_module_cache_test.mjs web/tests/hub_suspend_test.mjs web/tests/hub_demo_lifecycle_test.mjs web/tests/hub_demo_reentry_runtime_test.mjs web/tests/hub_launch_confirmation_test.mjs web/tests/hub_active_resume_test.mjs web/tests/hub_remote_presence_test.mjs
php web/tests/hub_remote_bootstrap_context_test.php
php web/tests/hub_suspend_test.php
php web/tests/hub_demo_readiness_flow_test.php
# Global
php web/tests/hub_runtime_presence_generation_test.php
# Documentation
npm run docs:sitemap
```

Syntaxes PHP des deux templates, syntaxe JS des fichiers exécutables modifiés et `git diff --check` contrôlés. Matrice existante préservée : première Remote, reconnect même page, reload/onglet conservateur, autre appareil/takeover, fallback sans page, zombies/quit/close, suspension/reprise, démo et vraie fin naturelle dans les modules moteur. Les effets réseau/DB sont simulés ; ces tests ne prouvent ni le cache du mobile ni le fonctionnement complet en DEV.

## G. Génération Master et périmètre

Global et serveur Bingo inchangés par empreintes. Les tests de présence/génération existants sont rejoués sans modification de leur implémentation. `hub_runtime_authority.js`, `boot_organizer.js`, `ws_connector.js`, `hub_demo_lifecycle.js` et les validateurs Global ne changent pas pendant cette correction.

Exception nécessaire explicitée : **`organizer_canvas.php` change le bootstrap du producteur** lorsqu’un paramètre manque ; affirmer « aucun fichier Master modifié » serait faux. Le test prouve que cette absence empêche la présence requise pour le routage Remote. Les publications, génération/intention/focus/exécution et leur validation restent sous la même autorité ; les valeurs explicitement stale restent refusées. Aucun changement de TTL, poll, grâce ou algorithme de reprise.

## H. Documentation, livraison et recette restante

TASKS existants actualisés (pas de tâche dupliquée), README et contrats corrigés, rapport précédent marqué non validé DEV, HANDOFF complété. Modifications dans les blocs AUTO-UPDATE avec IDs conservés. Sitemap/index régénérés par le script, sans édition manuelle des générés.

Aucun déploiement, restart, SSH, DB réelle, accès DEV/PROD, navigateur intégré ou modification sur serveur distant. Les markers sont seulement des fichiers locaux. Les travaux antérieurs sont conservés. La livraison devra conserver un ensemble cohérent de templates/modules Games et helpers/handlers Quiz/BT ; le versionnement suppose que les timestamps de livraison reflètent les versions des fichiers, comme le mécanisme existant.

Recette nécessaire après livraison autorisée : client10, session déjà lancée depuis Hub sans Remote, ouverture tardive ; autre appareil puis vérification que B commande et A ne commande plus ; reconnexion même page ; suspension/reprise ; officiel et démo sur les trois moteurs. Vérifier aussi sans effacer le cache ancien, puisque c’est le cas réparé par le versionnement. Succès attendu : Remote utilisable, pas de faux takeover sur reconnect, pas de fermeture démo pour continuité silencieuse. Le symptôme mobile doit encore être confirmé ou réinvestigué si cette recette échoue.

Rollback : retirer uniquement les modifications de cette passe à partir de son état initial, en conservant les corrections antérieures ; aucun reset global des dépôts sales et aucune restauration de données. Revenir au bootstrap/cache précédent réintroduirait les défauts reproduits. Ne pas considérer les tests locaux comme une levée des deux régressions DEV signalées.
<!-- AUTO-UPDATE:END id="remote-bootstrap-regressions-20260918" -->
