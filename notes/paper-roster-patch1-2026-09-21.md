# PATCH 1 — Inscription et roster papier — 21/09/2026

<!-- AUTO-UPDATE:BEGIN id="paper-roster-patch1-report" owner="codex" -->
**Implémentation locale, non déployée.** [Contrat canonique](../canon/interfaces/paper-roster.md). Aucun SSH, navigateur intégré, DB réelle, appel applicatif DEV/PROD, déploiement ou restart.

Discipline préalable : [START RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), sections « Statut actuel » et « Discipline de génération » ; [SITEMAP develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), rubriques Repos/Global specs ; [Manifest RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers », « Routing rules », « Server restart markers ». README/HANDOFF relus. Journal AI Studio fourni consulté, Markdown extrait du champ `const raw` sans exécuter la page : les entrées EN COURS/PROD portent sur marketing/AI Studio/ecommerce/Global librairies, aucun fichier moteur/roster ciblé signalé. Ce constat n’atteste pas l’égalité serveur/local.

## A. Causes corrigées

- `app_games_hub_player_ensure` conservait une équipe sélectionnée comme guest K/pseudo en perdant sa source ; l’injection suivante tombait dans `USERNAME_REFERENCED`.
- Remote sautait le WS sur `already_active`, état de persistance ne prouvant pas la présence mémoire.
- Préloads Quiz/BT lisaient tous les participants et Bingo forçait `includeInactive=1`, contrairement au live.
- Remote considérait la seule égalité total/longueur comme autorité ; Master remplaçait ses projections sans contrat commun.
- Les participants Hub papier ajoutés tard pouvaient rester hors runtime vivant.

Santeuil reste un scénario de divergence de projection : l’organisateur peut ne constater la disparition qu’à la pause/classement après une première série apparemment normale. **Aucun runtime réel «6 → 3» n’est établi ici.** Le test reproduit un runtime incomplet remplaçant potentiellement un roster plus large, avec données simulées.

## B. Contrat identité Hub → session

Validation serveur par table/ID/relation organisateur/K, nom relu à la source ; conservation de `participantType`, `sourceTable/sourceId`, K et EP applicable. Équipe guest typée dans la colonne existante `auth_identity_key=team:ID`, joueur `ep:ID`, invité `guest:K`. Adoption pré-patch uniquement par K identique lors d’une sélection validée, jamais par pseudo. La source équipe est réinjectée au moteur. Le guard de création libre exacte reste actif ; nom proche autorisé. Aucun changement de schéma.

## C. Bind idempotent

Remote demande `admin_player_register` après toute inscription HTTP réussie, y compris `already_active`. Quiz/BT et Bingo partagent leur lecture active avec le bind ; réponse `paper_player_bound` explicite : `bound`, `already_bound`, `not_found`, `inactive`, `conflict`. K prime ; D fourni est contrôlé. Pas d’INSERT ni réactivation depuis ce handler, pas de création depuis une commande de score.

## D. Alignement preload/live

Préloads vivants délèguent aux `players_get` actifs. Helper commun : K valide, déduplication canonique et admission Hub, session moteur exacte ; ni score ni socket dans les critères. La population Hub active partagée avec la capacité est lue sans déclencher sa synchronisation commerciale. Les lectures historiques demandent explicitement les inactifs, notamment les préloads terminés.

## E. Réconciliation runtime

Réutilisation des hydrations avec lectures concurrentes sérialisées : compléter les K actives manquantes, garder l’objet/score existant, retirer les absents d’une lecture live valide et couvrante. Bingo conserve les grilles mémoire. Déclencheurs : bootstrap/reconnexion, bind et maintenance papier toutes les **5 secondes**. Cette maintenance fournit un chemin de récupération des ajouts tardifs sans socket et sans attendre un prochain bootstrap. Remote Hub assure participation et mapping sur son focus papier vivant ; le runtime converge au prochain cycle, au plus tôt selon disponibilité des lectures. Suspension/expiration/fin ne sont pas des réactivations implicites.

## F. Autorité Remote/Master

Métadonnées `roster` : session, exécution si disponible, génération, révision, source, réconcilié/autoritaire, retraits éventuels. Seule une publication réconciliée couvrante peut supprimer par absence ; tronqués/états incomplets fusionnent. Mauvaise session/exécution et révisions anciennes refusées. Compteur local pris au lancement HTTP : la réponse ancienne est refusée après une modification acceptée. Pas d’union permanente : retrait explicite ou prochain snapshot réconcilié retire les absents.

Master écrit joueurs/classements/compteur conjointement ; Remote dérive son compteur du roster accepté. Équipes BT : compte des membres distinct des entrées de classement, lecture individuelle ne remplace pas le groupement. Numérique hors papier : comportements de remplacement historiques préservés. Nouveaux logs structurés bornés : réconciliation, bind, acceptation/rejet de projection ; aucun pseudo dans ces diagnostics.

## G. UX ajout Remote Hub

Recherche dès 3 caractères, suggestions multiples conservées. `free_guest_allowed` est décidé par le serveur avec le normaliseur canonique : bouton libre aussi avec suggestions proches ; nom exact réservé sans bouton invité, avec explication et sélection existante disponible. Un nouveau texte relance le contrôle et peut réactiver l’ajout ; anciennes réponses de recherche ignorées.

## H. Portée par moteur

| Moteur | Population live canonique | Snapshot autoritaire | Retrait explicite | Test N→M |
|---|---|---|---|---|
| Quiz | Session SQL, actif, K valide, déduplication/admission Hub | `updatePlayers` couvrant après réconciliation, session/exécution/révision | `removed` ordonné ou inactivation/retrait d’admission reflété par lecture couvrante | Réel handler Remote/Master + helper : 6 conservés sur 3 partiels, retrait D, convergence à 3 |
| Blind Test | Même contrat individuel ; projection équipes conservée | Même contrat, top tronqué partiel | Même contrat, sans activation du chantier équipes | Identique + compte de membres et protection de projection équipes |
| Bingo | Session token, actif, K valide/admis, aucun filtre socket | `num_connected_players` après hydratation valide ; `state` partiel | Liste active réconciliée et retraits ordonnés | Identique + vrai bind/hydratation, grilles conservées, sans sockets joueur |

## I. Fichiers modifiés

### games

- `web/includes/canvas/core/canvas_display.js`
- `web/includes/canvas/core/roster_snapshot.js`
- `web/includes/canvas/core/score_store.js`
- `web/includes/canvas/core/ws_effects.js`
- `web/includes/canvas/php/bingo_adapter_glue.php`
- `web/includes/canvas/php/blindtest_adapter_glue.php`
- `web/includes/canvas/php/boot_lib.php`
- `web/includes/canvas/php/hub_capacity.php`
- `web/includes/canvas/php/quiz_adapter_glue.php`
- `web/includes/canvas/remote/remote-ui.js`
- `web/includes/canvas/remote/remote-ws.js`
- `web/modules/app_hub_remote_ajax.php`
- `web/tests/hub_paper_preparation_test.php`
- `web/tests/hub_remote_paper_teams_test.mjs`
- `web/tests/paper_roster_bingo_test.cjs`
- `web/tests/paper_roster_identity_test.php`
- `web/tests/paper_roster_patch1_suite.mjs`
- `web/tests/paper_roster_runtime_test.cjs`
- `web/tests/paper_roster_snapshot_test.mjs`
- `web/tests/paper_roster_ux_test.mjs`

### global

- `web/app/modules/jeux/hubs/app_games_hubs_functions.php`

### quiz

- `web/server/actions/gameplay.js`
- `web/server/actions/registration.js`
- `web/server/actions/wsHandler.js`
- `web/server/restart_serveur.txt`

### blindtest

- `web/server/actions/gameplay.js`
- `web/server/actions/registration.js`
- `web/server/actions/wsHandler.js`
- `web/server/restart_serveur.txt`

### bingo.game

- `version.txt`
- `ws/bingo_server.js`

La documentation touchée est détaillée en K ; les index sont produits uniquement par le générateur.

## J. Tests exécutés et résultats

Depuis `/home/romain/Cotton` :

```sh
node games/web/tests/paper_roster_patch1_suite.mjs
```

**14/14 suites isolées réussies** :

- Provenance/Hub/guard/population : 44 contrôles PHP avec PDO factice ; sources équipes/joueurs, invité, nom proche/exact, source/ID/K/organisateur falsifiés, relecture typée, admission ; pour chaque moteur 2 inactifs + 1 actif → live/preload 1, historique 3.
- Vraies fonctions Quiz/BT bind/hydrate/maintenance exécutées en VM : absent→bound, présent→already_bound, retries sans doublon, inactif non réactivé, D incohérent→conflict, K absent→not_found, conservation score, reconstruction et ajout tardif, suspension.
- Vrais handlers Bingo isolés : mêmes états, reconstruction sans socket joueur, conservation des grilles, suppression de l’inactif, suspension.
- Helper et vrais consommateurs Remote/Master :6 → 3 partiel sans perte, retrait D, snapshot couvrant3, HTTP ancien après ajout WS, mauvaise session/exécution, Santeuil3 attendus/runtime incomplet/ajout 4/convergence, équipes BT et numérique Master.
- UX Hub : seuil3, suggestions, ajout proche, exact bloqué/message, sélection proposée, changement de texte, réponse ancienne.
- Préparation/lobby :82 contrôles incluant appel de l’ensure live sur ajout tardif et absence d’injection en terminé ; bootstrap papier froid, ensure historique, états d’inscription, confirmation papier14 cas, wording équipes12 cas, capacité/upsell/démo, contrat correction Bingo et suspension Bingo7 tests.

Lint PHP/JS des 28 fichiers applicatifs/tests modifiés et `git diff --check` : réussis. Aucun test connecté, aucune preuve d’état DEV/PROD.

**Limites des suites historiques, comparaison baseline obligatoire :**

- `node --test quiz/tests/*.test.cjs blindtest/tests/*.test.cjs` :169 tests,51 succès,118 échecs ; **même bilan sur les sources HEAD non modifiées** chargées via un intercepteur de lecture local. Notamment harness `primary-grace` ne simulant pas `./hubCapacity`. Ces échecs ne sont pas présentés comme des tests réussis et ne sont pas corrigés dans cette passe.
- `hub_remote_paper_recovery_test.mjs` : échec `modal.showDenyButton` sur modal absente, reproduit également avec la Remote HEAD non modifiée. Le code testé de reprise de modale n’est pas changé par le patch.

Les nouvelles recettes exécutent des fonctions de production avec transport/horloge/stockage remplacés. Elles ne simulent pas intégralement réseau, authentification et concurrence SQL multi-processus. La recette «Santeuil DEV» demandée est automatisée **localement** ; elle n’a pas été exécutée sur un service DEV, conformément à l’interdiction.

## K. Documentation mise à jour

- Nouveau contrat `canon/interfaces/paper-roster.md` et présent rapport.
- README/TASKS canoniques Games, Global, Quiz, Blind Test, Bingo ; suivi audit existant Games actualisé, pas de tâche audit dupliquée.
- Manifest routing R24 ; interfaces actions/bridge ; write-map Bingo ; entrées, runbooks dev/prod, `pm2-ws.md`, HANDOFF et CHANGELOG.
- Markers locaux Quiz/BT `restart 21-09-2026/03`, Bingo `restart 21-09-2026/02` ; **aucun restart**.
- `npm run docs:sitemap` : régénération des sitemaps/index, aucune édition manuelle.

## L. Risques et points ouverts

- Tests locaux uniquement ; revue/recette humaine ultérieure nécessaire pour l’exploitation. Les suites historiques défaillantes empêchent de déclarer toute la base de tests verte.
- La réparation des ajouts tardifs dépend du cycle de 5 s et de la disponibilité des lectures ; sur échec, aucune autorité nouvelle de suppression. Coût borné par session papier vivante, à observer en exploitation.
- Livraison coordonnée des lecteurs et producteurs recommandée : anciens WS sans métadonnées restent partiels côté nouveaux clients papier. Le filtrage K valide peut exposer des données legacy non canoniques ; les historiques restent consultables.
- `team:ID` réutilise une colonne existante : une fois ces lignes écrites après une future livraison, un rollback Global doit conserver le lecteur typé. Pour le patch **local non utilisé**, rollback = inverser ses diffs ciblés et retirer ses nouveaux fichiers ; aucune donnée réelle à restaurer. Ne pas faire de reset global sur d’autres travaux.
- **Non corrigés : K/D score, baisse de score/GREATEST, confirmation live des corrections, finalisation stale, Bingo D-only winner. Chantier équipes Blind Test non réactivé.**
<!-- AUTO-UPDATE:END id="paper-roster-patch1-report" -->
