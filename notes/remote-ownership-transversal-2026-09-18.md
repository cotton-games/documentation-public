<!-- AUTO-UPDATE:BEGIN id="remote-ownership-transversal-20260918" owner="codex" -->
# Alignement Remote Bingo / Quiz / Blind Test — 18 septembre 2026

> **Statut corrigé après recette DEV : patch non validé fonctionnellement.** Les résultats locaux ci-dessous décrivent la première passe ; deux régressions ont ensuite été signalées. Voir le [rapport des correctifs et preuves](remote-bootstrap-regressions-2026-09-18.md), qui distingue les défauts reproduits de la cause mobile non confirmée. Les markers locaux Quiz/BT sont désormais `/02`.

Patch local, non déployé. Cette note couvre uniquement la passe suivant l’audit `TRANSVERSAL_PARTIEL`. Le correctif antérieur de présence/génération Master reste acquis et inchangé.

## A. Contrôle préalable

Lecture avant patch : [START RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md) (entrée publique), [SITEMAP RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt) (chemins canon), [manifest RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md) (sections « Update triggers (mapping) », « Server restart markers »). Règles de [README RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md), « Maintenance pact » / « AI workflow (mandatory) », et contexte HANDOFF relus dans le travail en cours. Preuves du contrat : [actions RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/actions.md), section suspension Hub ; [bridge RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/canvas-bridge.md), section `hub_lifecycle`. Le patch local antérieur reste une preuve locale, pas une preuve de publication de ces pages.

Journal AI Studio public indiqué dans le manifest consulté avant modification : lecture du Markdown décodé de `const raw`, car la réponse est une enveloppe HTML. Sections « EN COURS » et « Fait, livré en PROD » examinées ; évolutions WWW/e-commerce/global_librairies hors périmètre. Aucun des fichiers ciblés de cette passe signalé à recharger ; aucun fichier rechargé depuis un serveur applicatif. Parité actuelle des fichiers déployés : **non trouvé dans la documentation** ; aucune certification de parité distante.

Mutualisation serveur déployée Quiz/Blind Test : **non trouvé dans la documentation**. Preuve locale : deux `ws/package.json` indépendants, deux `web/server/pm2-ws.ecosystem.config.cjs` avec leur propre cwd/script, imports locaux `__basedir`. Pas d’import inter-repos ajouté : deux helpers courts identiques, test explicite de parité.

## B. Cause

Bingo avait son propre registre Remote protégé. Quiz/Blind Test utilisaient `secondarySockets`, une comparaison navigateur sans page, un message de takeover générique et une fermeture précédant l’installation du successeur. Leur dispatcher ne gardait pas toutes les commandes de l’ancienne Remote, notamment le quit legacy. Le builder lifecycle éliminait les diagnostics de surface/page. Games ne transmettait la page qu’à l’auth Bingo ; les handlers génériques de démo pouvaient fermer le lease même quand la modale de takeover était supprimée.

## C. Fichiers applicatifs et tests modifiés dans cette passe

Chemins relatifs à chaque dépôt. Inventaire comparé aux empreintes prises au début de cette passe, donc distinct des modifications préexistantes.

| Dépôt | Fichier | Rôle |
|---|---|---|
| Games | `web/includes/canvas/remote/remote-ws.js` | Page dans registration/retry standard ; retrait démo avant fermeture de transport silencieuse. |
| Games | `web/includes/canvas/core/hub_demo_lifecycle.js` | Retrait de la seule surface remplacée ; neutralisation callbacks/pagehide/offline sans close durable. |
| Games | `web/tests/hub_remote_continuity_test.mjs` | Registration/retry réels ; handlers forcedDisconnect/UI et lifecycle démo réels, réponse HTTP tardive. |
| Games | `web/tests/hub_suspend_test.mjs` | Loader du nouveau helper réel dans le dispatcher existant. |
| Games | `web/tests/hub_active_resume_test.mjs` | Loader du helper réel pour la registration testée, assertions métier inchangées. |
| Quiz et Blind Test, chacun | `web/server/actions/remoteOwnership.js` | Nouveau helper identités, classification, retrait et propriétaire courant. |
| Quiz et Blind Test, chacun | `web/server/actions/registration.js` | Révocation, publication du successeur avant close, rechecks après await, page, motif structuré. |
| Quiz et Blind Test, chacun | `web/server/actions/connection.js` | Ignore déconnexion d’une Remote remplacée/non référencée. |
| Quiz et Blind Test, chacun | `web/server/actions/wsHandler.js` | Garde général Remote, quit legacy et changement de rôle interdits à l’ancienne Remote. |
| Quiz et Blind Test, chacun | `web/server/actions/hubLifecycle.js` | Champs diagnostiques conservés, preuve de retrait après release réussi. |
| Quiz et Blind Test, chacun | `web/server/restart_serveur.txt` | `restart 11-09-2026/02` → `restart 18-09-2026/01`, préparation uniquement. |
| Quiz et Blind Test, chacun | `tests/remote-continuity.test.cjs` | Nouvelle suite avec vrais modules registration/connection/dispatcher/audio/lifecycle/gameplay. |
| Quiz et Blind Test, chacun | `tests/primary-grace.test.cjs` | Loader du helper réel ; scénarios existants conservés. |
| Blind Test | `tests/teams-disabled.test.cjs` | Loader des dépendances réelles ownership/lifecycle ; assertions équipes inchangées. |

Aucune modification Global ni Bingo pendant cette passe, attesté par empreintes. Les fichiers Games d’autorité/presence, boot, bridge PHP, bootstrap et ws_connector du patch précédent restent identiques aux empreintes de départ.

## D. Contrat final

- Navigateur : `remoteInstanceId` persistant ; document : `remotePageId` éphémère, identifiants valides de 8–96 caractères alphanumériques/tiret/underscore. Même navigateur et même page : `same_continuity_reconnect`.
- Autre page/onglet actif, autre navigateur ou identité absente/invalide : `takeover`. Un reload produit une nouvelle identité de page : sans preuve serveur de retrait, on ne prétend pas le distinguer d’un autre onglet. Vieux clients acceptés, classement conservateur.
- Après suspension confirmée puis reprise autorisée, le même navigateur peut remplacer silencieusement son ancienne surface marquée par le serveur, si execution/request correspondent au lifecycle repris. Aucun nouveau droit de reprise ni barrière Remote.
- Quiz/Blind Test : socket précédente non ouverte ou déjà révoquée = `stale_socket_replaced`. Révocation de toutes les anciennes références, puis unique `secondarySockets=[nouvelle]`, puis sends/closes ; timeout de terminaison 500 ms ciblé sur l’ancienne. Réenregistrement de la socket courante idempotent.
- Toute commande d’une Remote remplacée, retirée, non courante, d’une autre session ou d’un runtime terminal est écartée. Le quit legacy exige le propriétaire courant même si l’émetteur n’a pas de rôle Remote. Les closes tardifs ne retirent jamais le successeur. Les registrations en attente ne recréent pas un runtime supprimé/terminé ou une socket fermée.
- `request_id`, `trigger`, `surface`, `page_id` traversent les builders lifecycle Quiz/Blind Test. `replacement_reason` reste dans le message/log de remplacement WS. Aucun token ajouté au diagnostic ; champ protocolaire de reprise préexistant conservé uniquement pour l’autorisation de reprise.
- Démo : retrait local de l’ancienne surface silencieuse avant fermeture WS ; heartbeat en vol, pagehide, offline, pageshow et listeners UI ne peuvent plus écrire close/marqueur ou naviguer. Takeover réel/legacy, vraie fermeture/quit et perte réseau réelle conservent la clôture existante. Pas de changement de politique du lease démo.
- Présence/génération Master : contrat Games/Global antérieur inchangé. Fin naturelle, pause/reprise, callbacks de focus et propriétaire Master conservent leur code métier.

## E. Tests réellement exécutés

Toutes les commandes ci-dessous sont locales, sans listener ni DB/service distant. Les fonctions principales de registration et connection Quiz/Blind Test sont chargées intégralement, pas remplacées par des doubles ; dispatcher, audioControl et lifecycle aussi. La fin naturelle charge le vrai gameplay ; réseau/stockage/horloges sont simulés aux frontières.

Depuis Games :

```sh
node --test web/tests/hub_remote_continuity_test.mjs web/tests/hub_suspend_test.mjs web/tests/hub_demo_lifecycle_test.mjs web/tests/hub_demo_reentry_runtime_test.mjs web/tests/hub_launch_confirmation_test.mjs web/tests/hub_active_resume_test.mjs web/tests/hub_remote_presence_test.mjs
php web/tests/hub_suspend_test.php
php web/tests/hub_demo_readiness_flow_test.php
```

Depuis Quiz puis Blind Test :

```sh
# Quiz
node --test tests/remote-continuity.test.cjs tests/primary-grace.test.cjs
# Blind Test
node --test tests/remote-continuity.test.cjs tests/primary-grace.test.cjs tests/teams-disabled.test.cjs
```

Depuis Bingo :

```sh
node --test ws/tests/remote_continuity.test.js ws/tests/hub_suspend.test.js ws/tests/bingo_reset.test.js ws/tests/bingo_quit_guard.test.js ws/tests/bingo_terminal_delivery.test.js
```

Depuis Global :

```sh
php web/tests/hub_runtime_presence_generation_test.php
```

Résultats : Games **60/60** TAP, Quiz **65/65**, Blind Test **80/80**, Bingo **25/25**. Global : **21** cas canoniques, dont génération stale, intent stale et focus changé. Games PHP : **77** contrôles suspension/dispatch et suite readiness démo verte. Syntaxe des 12 fichiers JS applicatifs modifiés et `git diff --check` validées.

Couverture Remote de chaque moteur : première inscription, même page, reload/nouvel onglet conservateur, autre appareil, legacy sans page, socket révoquée et non coopérative, commandes ordinaires et quit tardifs, close tardif, timeout ciblé, suspension/reprise avec ancienne socket toujours vivante, corrélation diagnostique, terminal/registration en vol et fin naturelle réelle officielle/démo. Les suites de grâce inchangées vérifient le contrat Master. Les tests Games exécutent la retraite démo avec les handlers réels pour les trois moteurs. Bingo reset couvre le protocole `demo_reset` ; le fichier historique `demo.test.js` ne teste que la forme de l’auth, et n’est pas utilisé comme preuve métier démo.

Pendant l’adaptation, les harness historiques ne connaissaient pas le nouveau require et échouaient au chargement. Les loaders ont été complétés avec les vrais modules ; les assertions existantes n’ont pas été assouplies.

## F. Documentation

README et TASKS Games/Quiz/Blind Test actualisés ; entrée de suspension existante TASKS complétée (update-not-append). HANDOFF, actions et canvas-bridge mis à jour dans leurs blocs AUTO-UPDATE, IDs conservés. Cette note distingue la présence Master antérieure de l’ownership Remote aligné. `npm run docs:sitemap` régénère sitemap et index ; aucune édition manuelle des générés.

<!-- INVENTORY:BEGIN -->
Liste exhaustive des fichiers documentation modifiés ou régénérés dans cette passe :

- `HANDOFF.md`
- `canon/interfaces/actions.md`
- `canon/interfaces/canvas-bridge.md`
- `canon/repos/blindtest/README.md`
- `canon/repos/blindtest/TASKS.md`
- `canon/repos/games/README.md`
- `canon/repos/games/TASKS.md`
- `canon/repos/quiz/README.md`
- `canon/repos/quiz/TASKS.md`
- `notes/INDEX.md`
- `notes/remote-ownership-transversal-2026-09-18.md`

<!-- INVENTORY:END -->

## G. Risques résiduels et rollback

Recette réelle multi-onglets/appareils, ordre des événements réseau et intégration HTTP/DB après livraison restent à faire ; simulations locales ne certifient pas les serveurs déployés. Sans identité de page ou preuve de retrait, un reload concurrent reste volontairement traité comme takeover. La politique existante ferme la démo sur takeover réel : elle est conservée, pas redéfinie. Les deux copies serveur doivent rester alignées ; le test de parité impose la présence des deux repos dans ce workspace de validation.

Rollback : retirer uniquement les changements inventoriés de cette passe, restaurer les markers précédents si non activés, conserver les modifications antérieures Bingo/Games/Global. Aucune donnée à restaurer. Livrer ensuite de façon cohérente le client Games et les deux serveurs pour bénéficier des motifs structurés et de la retraite silencieuse ; aucun ordre de déploiement exécuté ici.

## H. Déploiement

Aucun déploiement, aucun restart, aucun SSH, aucun accès DB réel, aucun accès applicatif DEV/PROD ni modification serveur. Seules les documentations publiques prescrites ont été consultées à distance. Tous les changements et marqueurs sont locaux.
<!-- AUTO-UPDATE:END id="remote-ownership-transversal-20260918" -->
