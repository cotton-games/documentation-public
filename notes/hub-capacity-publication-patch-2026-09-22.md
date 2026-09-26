# Capacité Hub et publication Blind Test — patch local du 22/09/2026

> **Statut au 22/09/2026 : branche `sas_players`, EN COURS — NON DÉPLOYÉ EN PROD.** Ce lot est exclu du déploiement `hub_soiree` confirmé par l’opérateur. La promotion documentaire vers `main` ne change pas ce statut. [État de livraison](../canon/deployment-status.md).


**CAPACITÉ HUB AMÉLIORÉE MAIS QUALIFICATION 5 000 NÉCESSAIRE**

**BLIND TEST O(R²) SUPPRIMÉ** (recherche par Player dans la publication ; pas une certification de tous les chemins équipe).

## Sources et contrôle préalable

Navigation START/SITEMAP/Manifest publics et journal AI Studio relus ; journal identique à celui du second audit. Dépendance signalée : `global/web/app/modules/ecommerce/app_ecommerce_functions.php`. L’utilisateur confirme son rechargement depuis DEV. Lecture désormais possible ; aucune modification de ce fichier par ce patch, aucune parité PROD déduite. Son diff local préexistant appartient au rechargement utilisateur.

Références : [audit initial](hub-initial-session-sas-audit-2026-09-22.md), [audit pipeline](hub-player-registration-pipeline-audit-2026-09-22.md). Le résolveur `app_client_player_capacity_resolve` dans Global `app_games_hub_capacity.php` appelle `app_ecommerce_offre_effective_get_context` (fichier ecommerce, fonction vers ligne13858). Celle-ci résout client, offres propres/affiliation réseau, activation et offre effective ; le résolveur capacité lit ensuite `id_erp_jauge` et `nb_joueurs_max`. Pas de cache cohérent couvrant ces mutations identifié. Le coût SQL ecommerce dépend de la branche ; aucun total SQL déployé revendiqué.

## Choix et frontière de fraîcheur

Les réponses sont indépendantes du joueur pour un même endpoint, origine et payload : capacité, statut Hub/démo, clés actives et identités/mappings. Le payload entier fait partie de la clé, donc aussi tout discriminant supplémentaire d’exécution/génération fourni. Isolation par processus et moteur ; pas de cache distribué.

Stratégies examinées :

- TTL : écartée. Même courte, elle peut accepter une clé retirée ou ignorer une suspension/offre expirée. Une TTL n’est pas un contrat d’invalidation.
- Promesse in-flight classique : écartée pour les nouveaux arrivants. Le SQL pourrait déjà avoir lu le roster avant leur tentative.
- Snapshot versionné/incrémental : exige une révision couvrant tous les écrivains Hub, sessions, mappings et ecommerce. Aucune révision commune existante identifiée ; dépasse ce lot.
- Validation par clé : insuffisante seule. `countPlayers` et les alias utilisent les identités actives des autres joueurs runtime ; il faudrait revoir le contrat et le comptage, puis sa synchronisation.
- **Cohorte fermée avant lecture** : retenue. Les demandes déjà en attente sont regroupées par un `setImmediate`. L’entrée est supprimée **avant** le départ du fetch. Toute demande arrivée après déclenche une autre lecture. Aucun résultat/échec n’est conservé pour une admission ultérieure, aucune TTL configurable ni délai fixe ajouté.

Implémentation : `capacity_reads.js` dans chacun des trois serveurs autonomes ; wrapper de la seule action `hub_capacity_get` dans `envUtils.js`. Les autres actions gardent leur transport. Les erreurs et timeouts source rejettent tous les demandeurs concernés ; la demande suivante réessaie normalement. L’API PHP et son payload restent identiques.

`hubCapacity.js` Quiz/BT et `hub_capacity.js` Bingo construisent le Set par identité de réponse via WeakMap. Une réponse partagée donne un seul index ; une nouvelle lecture donne un nouvel index. Le Set est interne et traité en lecture seule. Les réponses/indices ne sont pas conservés dans un cache par session ; le runtime garde naturellement sa dernière autorité comme auparavant.

Cette primitive ne rend pas atomiques les différentes lectures SQL ni le délai entre lecture et bind. Les réponses de lectures distinctes peuvent encore se terminer dans un ordre différent : comportement préexistant, sans nouvelle garantie de sérialisation/version. Elle ne remplace aucun guard d’exécution, de suspension ou d’expiration dans les autres étapes du pipeline. `hub_capacity_get` n’est pas à lui seul une validation complète de tous ces états.

## Mutations et invalidation

| Mutation | Données impactées | Contrat retenu |
|---|---|---|
| Jauge modifiée/upsell | Offre effective et maximum snapshot | Nouvelle lecture ; maximum ascendant conservé |
| Ajout/départ/désactivation/réactivation Hub | Clés et compteur actifs | Nouvelle lecture après la demande ; aucun résultat TTL |
| Mapping ajouté/remplacé, alias | Clés session et identités | Nouvelle lecture et nouvel index |
| Membership ajouté/retiré/changé | Association Hub/session | Relecture PHP existante ; aucune autorité mise en cache |
| Statut Hub/session, suspension/reprise | Guards existants du pipeline | Aucun court-circuit ajouté ; nouvelles lectures source |
| Expiration/fenêtre temporelle | Autorisations temporelles | Pas de TTL : l’écoulement du temps n’émet pas nécessairement une invalidation |
| Offre client/réseau/activation | Offre et jauge | Résolveur existant réexécuté par cohorte ; pas de modification ecommerce |
| Stock Bingo, allocation | Stock support/playlist | Guard stock complet par lecture, verrou et recomptage conservés |
| Reset, génération, exécution | Contexte courant | Aucun cache persistant ; payload distinct isolé ; guards existants inchangés |

Pour toutes ces lignes, une invalidation explicite **exhaustive** nécessiterait de raccorder tous les écrivains et, pour l’expiration, une frontière temporelle. Ce mécanisme n’existe pas dans le périmètre inspecté. Le patch n’en a pas besoin : une cohorte n’est plus joignable dès le départ de la source. Une mutation intervenue après la lecture reste soumise à la course préexistante ; ce patch ne promet pas d’éliminer cette course.

## Bingo et périmètre préservé

Aucun hunk dans `bingo_server.js`, reset/lifecycle/auth, l’allocation des grilles, le PHP Games/Global ou les verrous. Chaque lecture source appelle toujours `app_games_hub_bingo_capacity_ensure` : `GET_LOCK(hub_grid_capacity_<playlist>,5)`, compte/max, génération du manque, recomptage, libération en finally. Les grilles déjà attribuées ne sont pas réaffectées. Un échec de stock reste un refus, pas un fallback.

L’auth Bingo est séquentielle par playlist : **B≈N dans cette vague nominale**, donc pas de gain capacité attendu sur ce chemin, ni réduction des autres reset/lifecycle. Le guard n’est pas séparé/supprimé pour fabriquer un gain. L’unicité d’attribution reste celle du code existant inchangé ; aucun test DB réelle ne la recertifie.

Sas, convergence, watcher, orchestration, papier/démo et UX inchangés. Les réponses non-Hub/démo empruntent le même contrat et leurs branches existantes. Aucun nouveau schéma/index, aucune SQL à exécuter demandée.

## Coûts statiques

N admissions, H clés et mappings logiques du roster, B cohortes réellement formées (1≤B≤N), Q opérations SQL d’une lecture source dans sa branche :

| Élément | Avant | Après |
|---|---|---|
| Appels WS `hub_capacity_get` | N | B |
| Lectures/reconstruction PHP roster | N | B |
| Construction Set WS | N | B |
| Volume logique réponse | N×H | B×H |
| SQL source | N×Q | B×Q ; (N−B)×Q évitées |
| Deux SELECT explicites roster/mappings | 2N | 2B |
| Complexité de cette partie | O(NH) | O(BH+N) |

Pour H=N et **une seule cohorte**, borne favorable (pas un benchmark réseau) :

| N | HTTP/Set avant → après | Unités roster avant → après | SELECT roster évités |
|---|---|---|---|
| 50 | 50 → 1 | 2 500 → 50 | 98 |
| 500 | 500 → 1 | 250 000 → 500 | 998 |
| 5 000 | 5 000 → 1 | 25 000 000 → 5 000 | 9 998 |

Pour B=N : aucune économie HTTP/SQL/volume, O(NH) reste possible. Le payload contient aussi des métadonnées constantes, et les alias peuvent rendre H>N. Ne pas confondre ces unités avec des octets ou des millisecondes. Les inscriptions HTTP pré-WS et `canvas_hub_player_admission` restent hors optimisation. Les scans runtime de comptage/déduplication demeurent. L’objectif de supprimer le roster complet **à chaque admission dans tous les scénarios** n’est donc pas atteint par ce seul lot ; une évolution versionnée/par-clé plus large doit être conçue séparément.

## Blind Test

`actions/gameplay.js:updatePlayerListNow` : après le tri, création de deux Maps (première entrée par membre, première entrée par playerId). Lookup membre prioritaire, puis joueur, puis null. La comparaison des memberIds reste stricte, et l’ordre/les doublons conservent la sémantique des deux anciens `find`. Pas de modification des rangs, scores, total, top50 organisateur, payload individuel, feature flag ou throttle1s.

Pour R joueurs/entrées et M appartenances : recherche ancienne O(R²) en solo, potentiellement O(R×M) en équipe ; nouvelle O(R+M) pour indexation/lookup, mémoire O(R+M). Avec le tri, solo O(R log R). Le code de construction des équipes en amont conserve ses propres coûts.

## Validation locale exécutée

- `node games/web/tests/hub_capacity_cohort_test.cjs` : trois moteurs, 2/100 et 50/500/5 000 appels simultanés, isolation session/origine/endpoint, partage réponse/Set, mutations clés/mappings/jauge, refus source simulés (offre, expiration, suspension, membership, exécution, stock), absence de cache après succès/échec, nouvel arrivant pendant fetch, résolution inversée, exception synchrone.
- `node games/web/tests/hub_capacity_transport_test.cjs` : vrais corps des wrappers/transports sous VM avec I/O simulées ; appels regroupés, erreurs et timeouts, reprise, autres actions non regroupées. Timeout Quiz/BT par AbortController réel ; timeout Bingo via callback du transport simulé.
- `node games/web/tests/hub_capacity_runtime_test.cjs` : vraies fonctions register/probe et auth Bingo sous VM ; 2/100 inscriptions Quiz/BT simultanées avec le vrai lecteur par cohortes, refus au plafond puis reconnexion sans slot supplémentaire ; upsell51, alias, actif/parti, capacité atteinte, reconnexion et branches papier/démo/hors Hub selon fixtures existantes.
- `php global/web/tests/hub_capacity_test.php` : 89 contrôles, SQL doublé en fichiers, concurrence, jauge propre/réseau/inactive/erreur, snapshot, admission/retour/départ, stock Bingo agrandi/idempotent et grilles attribuées préservées. Le résolveur ecommerce est doublé : pas de validation de son SQL réel.
- `node blindtest/web/tests/ranking_publication_index_test.cjs` : oracle des anciens find et vraie publication/publicRankingEntry ; solo/égalités/non classés, équipes synthétiques, priorité membre et identifiants stricts, top50/full, tailles50/500/5 000. Helpers de classement réels avec feature flag désactivé et rangs1,1,3.

Les mutations d’état de la source sont simulées : elles testent la fraîcheur et la propagation, pas les guards DB réels. Pas de test de charge distribué ni de débit/latence annoncé. Recette réelle requise : mesurer B/N, SQL et trafic, mémoire/GC, latence admission/publication aux tailles50/500/5 000, puis qualification des mutations et de Bingo sur environnement autorisé.

## Livraison et rollback

Quiz/BT : `actions/{capacity_reads,envUtils,hubCapacity}.js`, BT également `actions/gameplay.js`. Bingo : `ws/{capacity_reads,envUtils,hub_capacity}.js`. Tests Games et BT ci-dessus. Trois markers : `restart 22-09-2026/01` (`web/server/restart_serveur.txt` Quiz/BT, `version.txt` Bingo).

**Aucun déploiement/restart effectué.** Après une livraison future autorisée, les trois WS devront redémarrer ; aucun reload PHP nécessaire pour ce patch. Livrer chaque nouveau module avec ses consommateurs. Rollback : retirer seulement les hunks de ce lot dans wrappers/helpers/gameplay et les nouveaux modules ; publier un nouveau marker selon discipline projet, sans écraser les autres changements ni le rechargement ecommerce.

Vérification syntaxique des transports et de gameplay : OK. `git diff --check` : OK pour les hunks du patch (Games, Quiz, BT, Bingo et documentation). Le contrôle Global échoue sur des espaces de fin de ligne préexistants dans le fichier ecommerce rechargé par l’utilisateur ; fichier laissé intact, aucune correction cosmétique hors périmètre.

README/TASKS concernés, contrat Canvas, note Bingo, docs exploitation et HANDOFF mis à jour ; sitemap/index générés, pas édités manuellement. Pas de CHANGELOG : aucun changement UX voulu.
