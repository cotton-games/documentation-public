# État de livraison — production et travaux non déployés

<!-- AUTO-UPDATE:BEGIN id="deployment-status" owner="codex" -->

## Statut courant au 23/09/2026

**`hub_soiree` : livraison PROD signalée par l’opérateur, y compris l’essai du hotfix du 23/09. `sas_players`, `hub_session_readiness` et `cast` : évolutions propres NON DÉPLOYÉES EN PROD.** La synchronisation documentaire `develop` → `main` conserve ces exclusions. Les recettes DEV et les tests locaux ne changent pas ce statut. Aucun autre chantier décrit dans cette documentation ne doit être considéré comme livré sans confirmation explicite.

Le hotfix reprend seulement l’admission WS ciblée et l’attente organisateur tardive : il ne livre pas le sas/readiness complet. L’incident Player Bingo cloclo reste ouvert ; les correctifs envisagés dans le diagnostic ne sont pas appliqués.

## Hotfix hub_soiree du 23/09/2026 — essai PROD signalé, incident Player en cours

Admission WS ciblée et attente organisateur tardive seulement ; worktrees Games/Bingo/BT/Quiz issus de `hub_soiree`, sans commit car `.git` en lecture seule. [Périmètre séparé](../notes/hub-soiree-hotfix-2026-09-23.md). Aucun sas complet livré par ce lot, aucun déploiement/restart exécuté par Codex. L’opérateur signale une recette compte442 ; audit des copies de logs DEV17:17–17:22 : gameplay observé, réserves sur grilles bots et lenteur Bingo, parité des versions exécutées non attestée. Après cette recette DEV, l’opérateur confirme une livraison/recette en PROD sur le client10. Les copies WS montrent deux lancements Bingo, mais cloclo reste sans bind initial puis rejoint à la reprise ; diagnostic incomplet, fichiers Games vides. Voir K du rapport. La parité exacte des fichiers serveur reste non vérifiée. Les références Git du 22/09 ci-dessous sont historiques et ne constituent pas les empreintes du hotfix déployé.


## Référence au 22/09/2026

**L’opérateur confirme le déploiement des branches applicatives `hub_soiree` en production le22/09/2026. Les évolutions propres à `sas_players` et `cast` ne sont PAS déployées en production.** Cette déclaration est la source du statut de livraison ; Codex n’a ni consulté les serveurs ni vérifié les processus exécutés.

| Périmètre | Statut consigné le 22/09 | Lecture de la documentation |
|---|---|---|
| Branches applicatives `hub_soiree` | **Déployées en PROD, confirmation opérateur** | Référence du lot livré ; les mentions historiques « local », « non déployé » ou « aucun restart effectué » décrivent les passes antérieures de l’agent |
| Correctif public des sessions Hub retirées, postérieur au lot livré | **DÉPLOIEMENT PROD PRÉVU — confirmation attendue** | Global/WWW/Play : [périmètre et tests](../notes/hub-public-removed-sessions-2026-09-22.md) ; intention de déploiement annoncée par l’opérateur le 22/09/2026, sans confirmation de réalisation |
| Changements propres à `sas_players` | **EN COURS — NON DÉPLOYÉS EN PROD** | Optimisations expérimentales décrites pour préparation/qualification ; pas le comportement de la production |
| Changements propres à `cast` | **EN COURS — NON DÉPLOYÉS EN PROD** | POC Cast DEV Pro/Games ; pas une fonctionnalité de diffusion disponible en production |

La promotion documentaire `develop` → `main` conserve aussi les descriptions de travaux futurs. **La présence d’une section dans la documentation `main` ne constitue pas une preuve de son déploiement : lire son statut et sa branche.** Ne pas retirer ces exclusions pendant la promotion. Un nouveau déploiement explicite devra actualiser ce tableau et les sections concernées.

Les historiques et commandes futures restent conservés : une case de développement cochée n’est pas une recette terrain réussie, et une instruction de restart ne prouve pas un processus redémarré. La confirmation opérateur ne valide pas automatiquement les tests matériels, de charge ou les recettes navigateur restants. Les autres conceptions futures déjà explicitement signalées restent futures ; elles ne sont pas promues par cette annonce.

## `sas_players` : périmètre exclu

Comparaison locale `git diff --name-only hub_soiree...sas_players` et `git log hub_soiree..sas_players` :
- Quiz (`74b99c9`) : `capacity_reads.js`, transport `envUtils.js`, index de capacité `hubCapacity.js`, marker WS.
- Blind Test (`1a76a66`) : mêmes optimisations de capacité, publication indexée dans `gameplay.js`, test dédié et marker WS.
- Bingo (`06b9675`) : cohortes capacité/transport, `bingo_server.js`, `bingo_reset.js`, repositories joueur, tests d’authentification et marker.
- Games (`b4609aa`) : trois tests de capacité/cohortes/runtime/transport ; aucun nouveau runtime Games dans ce delta.

Sont donc **hors PROD** : regroupement des lectures de capacité en cohortes, index de lookup publication BT, prélecture de routage Bingo et suppression du reset_state initial, allègement du premier state Player Hub. Les gains annoncés et les markers22/09 /01 ou /02 appartiennent à ce chantier. Ne pas appliquer les consignes de livraison de ces lots au titre du déploiement `hub_soiree`.

Rapports : [capacité/publication](../notes/hub-capacity-publication-patch-2026-09-22.md), [auth Bingo](../notes/bingo-digital-auth-performance-2026-09-22.md). Les audits sas/pipeline/charge liés décrivent des investigations et une qualification à poursuivre ; ils ne prouvent pas la livraison d’un sas joueur complet.

## `hub_session_readiness` : périmètre exclu au 23/09

**NON DÉPLOYÉ EN PROD.** Préparation durable E1, protocole de readiness Player, fenêtre/roster de préparation, projection Remote et harnais associés restent un chantier distinct. Les reprises sélectives de `sas_players` dans cette branche ne sont pas livrées par le hotfix minimal. [Périmètre et recettes DEV](../notes/hub-session-readiness-2026-09-23.md).

## `cast` : périmètre exclu

Comparaison locale `hub_soiree...cast` :
- Games (`f55862a`) : receiver CAF et outils/tests sous `tools/cast-dev/`, endpoints `web/cast/dev/`.
- Pro (`d27afd0`) : sender, garde/configuration/outils sous `tools/cast-dev/`, endpoint `web/cast/dev/asset.php`, include du Dashboard.
- Global possède une branche `cast` sans commit propre au-delà de `hub_soiree` ; aucun nouveau lot Global Cast identifié.

**POC expérimental, NON DÉPLOYÉ EN PROD.** Le guard DEV et l’opt-in ne valent pas confirmation de livraison DEV ni validation matérielle. [Rapport Cast](../notes/cast-dev-poc-2026-09-17.md). Les mentions génériques historiques HDMI/cast ne désignent pas automatiquement ce POC.

## Références Git locales du lot annoncé livré — constat historique du 22/09

Les huit branches `hub_soiree` sont ancêtres des `main` locales. Global et WWW portent des commits de merge, les six autres références sont identiques. Références constatées, **pas empreintes vérifiées sur serveur** :

| Repo | `hub_soiree` | `main` |
|---|---|---|
| `games` | `38190ce` | `38190ce` |
| `global` | `94b569e` | `4d272c4` |
| `pro` | `02e7467` | `02e7467` |
| `quiz` | `69192a2` | `69192a2` |
| `blindtest` | `ef1c180` | `ef1c180` |
| `bingo.game` | `9788e31` | `9788e31` |
| `play` | `e55a762` | `e55a762` |
| `www` | `6333212` | `5d2a842` |

## Passe documentaire et validation

Documentation sur `develop`, propre au départ. Journal AI Studio relu : aucune modification externe ciblée de ces documents signalée. Sources ouvertes : [SITEMAP RAW, How to use](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md), [README RAW, Doc discipline et promotion](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md), [manifest RAW, routing](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), [HANDOFF RAW, actions capacité/auth/Cast](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md). L’annonce opérateur de cette conversation prime pour le statut du déploiement22/09 ; une preuve distante de celui-ci n’est pas fournie par ces pages.

Mises à jour : START, README général, README/TASKS des huit repos, sections capacité/auth/Cast des contrats et runbooks concernés, trois rapports de chantier, CHANGELOG, HANDOFF, manifest et procédure de promotion. Historique préservé, sans remplacement global des anciens statuts. Index/sitemaps régénérés via `npm run docs:sitemap`, liens locaux de cette passe et `git diff --check` contrôlés. Aucun applicatif, marker, branche, index Git, commit, merge, push ou serveur modifié ; promotion vers `main` laissée à l’opérateur.

Rollback : retirer uniquement les ajouts de cette passe documentaire et régénérer les index. Ne change pas le statut réel des branches applicatives.

<!-- AUTO-UPDATE:END id="deployment-status" -->
