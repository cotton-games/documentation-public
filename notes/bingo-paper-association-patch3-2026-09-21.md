# PATCH 3 — Bingo papier : association facultative du joueur — 21/09/2026

<!-- AUTO-UPDATE:BEGIN id="bingo-paper-association-patch3-report" owner="codex" -->
Patch local, non déployé. PATCH1/PATCH2 considérés validés localement selon l’utilisateur ; leurs modifications préexistantes sont conservées. Aucun SSH, DB réelle, accès applicatif DEV/PROD, navigateur intégré, déploiement ou restart.

## A. Ancien lookup

`bingo.game/ws/bingo_server.js::resolvePlayerScopeForGame` accepte directement K ; pour D seul il parcourt `players.getPlaylistPlayers(gameID)`, donc uniquement le registre connecté. `admin_phase_winner` l’appelait avant hydratation et session. Pour le participant papier D=4 sans socket, la sonde exécutant le vrai handler produit `winner_name="Grille #42"`, aucun appel canonique `phase_winner`, et une avance sans gagnant. L’assertion attendue `winner_name="Papier"` échoue sur la copie avant patch ; elle passe après.

Audit des autres usages : `handleVerificationRequestMessage` emploie le même resolver pour une victoire Player numérique. Cet appel et le resolver numérique restent inchangés. `admin_phase_fail` ne résout aucune identité et reste inchangé. Les appels à `resolveCanonicalPlayerId` d’authentification/bind ne sont pas des associations visuelles de gagnant et ne changent pas. Le resolver HTTP `_bingo_resolve_identity` est déjà scoped par session ; il n’est pas modifié dans cette passe.

La recommandation bloquante de l’audit historique (section L, proposition 3) est **supplantée par la demande PATCH3** : une association introuvable ne devient pas un refus métier de phase. L’audit reste une archive des constats antérieurs.

## B. Nouvelle source canonique

Uniquement pour `admin_phase_winner` lorsque `lotsByGame[gameID].paperMode === true` : `resolvePaperPlayerAssociation` réutilise `hydratePlayersFromDB`, `paperRosterMeta` et `paperPlayersByGame` du PATCH1. Aucun second registre. Le lecteur actif/admis existant est relu à la demande ; aucune lecture si aucun joueur n’est fourni. Échec de lecture : pas d’utilisation d’une ancienne identité mémoire.

Le game provient de la Remote authentifiée. Le token fourni, le token serveur, les métadonnées du roster et l’exécution Hub doivent correspondre. Un roster historique/non autoritaire/terminé ne sert pas de preuve de participation active. Les gardes propriétaire de Remote et suspension sont revérifiées après la lecture asynchrone. Aucun participant créé, réactivé, recherché par pseudo ou récupéré depuis une autre session.

## C. Résolution K/D

| Entrée | Résultat |
|---|---|
| K+D | K cherchée dans le roster papier, D doit désigner le même participant |
| K seule | K résolue, D et nom relus depuis le participant |
| D seul | Recherche exacte sur `player_db_id` de tout le roster papier, K existante récupérée |
| K inconnue avec D connu | Aucun fallback de K vers D |
| D inconnu, K invalide/inconnue, inactif, mauvais scope | Association `not_resolved` ; pas d’identité projetée |
| K et D incohérents | Association `conflict` ; pas d’identité projetée |
| Aucun joueur | Aucune recherche ; chemin sans joueur existant |

`phase_over.winner_id` conserve le D attendu des surfaces ; `winner_name` vient du roster résolu. La notification utilise la même identité. Aucun nom libre reçu ne supplante l’identité résolue. Sans résolution, le libellé de grille reste disponible et l’ID vaut null ; une correction suivante sur la même grille ne récupère pas implicitement l’ancien joueur côté serveur.

Un log `bingo_paper_player_association_resolve` par tentative avec identité : session, game, phase, K valide si connue, D valide s’il est fourni, `source=paper_roster`, `result=resolved|not_resolved|conflict`. Aucun pseudo ni payload complet dans ce nouveau log.

## D. Impact sur validation de phase

**Association joueur facultative ; validation Bingo indépendante de cette association.** Sans identité exploitable et sans ACK HTTP, le handler conserve `advancePhaseWithoutWinner`. Avec une identité résolue, il utilise le write canonique existant et son `event_id`. Avec `persisted=true`, il respecte `wonPhase/nextPhase` déjà confirmés par HTTP, même si l’enrichissement visuel échoue : aucune nouvelle avance ni écriture de gagnant. C’est une correction de routage du refresh, pas une modification des règles de phase.

Les algorithmes de grille automatique, refus/validation manuel, ligne/carton, progression, score, podium et fin naturelle restent inchangés. Le signal terminal garde `paper-end-${eventId}` et `paper_state=completed`. Aucun contournement ajouté aux refus métier de persistance ni aux erreurs HTTP de la Remote ; le patch traite la résolution facultative dans le handler WS. Aucun nouveau retry métier. Les erreurs de transport/SQL et leurs garanties restent celles des chemins existants.

## E. Fichiers modifiés

Fichiers applicatifs à livrer pour ce PATCH3, sur une base contenant PATCH1 :

- `bingo.game/ws/bingo_server.js` — resolver papier et projection de l’association, ACK conservé.
- `bingo.game/version.txt` — `restart 21-09-2026/03`, préparé uniquement.

Tests, sans nécessité de copie applicative :

- `bingo.game/ws/tests/bingo_winner_notification.test.js` — fixture VM adaptée au nom local `winnerId` résolu ; assertions métier conservées.
- `games/web/tests/bingo_paper_association_test.cjs` — nouveau, vrai handler/lecteur/progression avec API/DB simulées.
- `games/web/tests/bingo_paper_association_ui_test.cjs` — nouveau, vrais callbacks/handlers/renderers avec DOM et transport simulés.
- `games/web/tests/bingo_paper_patch3_suite.mjs` — nouveau, runner de régression.

Aucun runtime Games, Global, Quiz ou Blind Test modifié par PATCH3. Aucun SQL/migration, dépendance ou variable d’environnement ajouté.

## F. Tests

Depuis la racine Cotton : `node games/web/tests/bingo_paper_patch3_suite.mjs`.

5/5 groupes verts : 24 scénarios serveur, UI réelle isolée, contrat PHP winner, 10 résultats TAP Bingo (notifications, phases, quit, livraison terminale), suite PATCH2 8/8 qui inclut PATCH1 14/14. Syntaxe Node et diff-check ciblés verts. Les tests sont locaux et ne prouvent pas une recette réseau/SQL/navigateur réelle.

| Cas demandé | Couverture |
|---|---|
| 1–4 : K+D, K seule, D avec/sans socket | Vrai handler, appel canonique K+D et affichage du nom du roster |
| 5–7 : D inconnu, K inconnue, conflit | Aucun ID projeté ; phase avancée normalement sans joueur |
| 8 : aucune association | Aucune lecture roster ni write participant |
| 9 : automatique sans joueur | Vraie `handleBingoPaperCorrection`, grille valide simulée, puis vrai handler serveur |
| 10 : manuel sans joueur | Vrai callback manuel gagnant et perdant ; refus ne fait pas avancer |
| 11 : même grille puis sans association | Deux commandes serveur, aucune réutilisation de nom/ID |
| 12 : mauvaise session | Token et exécution incohérents ; D inactif/connecté seul exclu |
| 13 : retry/idempotence | Même event_id transmis au write idempotent simulé ; ACK répété sans write ni avance |
| 14 : fin naturelle | Dispatch réel du handler vers `end_game`, associé/non associé/inconnu/ACK ; helpers terminaux testés séparément |
| 15 : PATCH1 | 14/14 suites existantes ; suspension pendant résolution également couverte |
| 16 : Master/Remote | D sans socket → vrai message serveur → adaptateur Master → HTML overlay ; adaptateur Remote → store gagnants → HTML podium |

## G. Documentation et preuves préalables

Contrat fonctionnel dans `canon/repos/bingo.game/README.md`, tâche PATCH3 dans son TASKS ; suivi de l’audit Games mis à jour sans doublon. README Games, actions, bridge, write map, entrypoints, runbooks DEV/PROD, PM2, HANDOFF, CHANGELOG, index README mis à jour. Index/sitemaps générés par `npm run docs:sitemap`. Règles existantes du manifest WS Bingo/markers/actions suffisantes ; pas de changement des contrats PATCH1/PATCH2.

Lectures préalables :

- [START RAW main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), « Statut actuel » et « Comparer develop vs main » : travail local non assimilé à PROD.
- [SITEMAP develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md) et [manifest develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers » et règles WS/markers.
- Journal AI Studio public relu avant modification ; contenu identique à la lecture PATCH2 après normalisation des fins de ligne. Aucun nouvel écart signalé concernant ce moteur. Ce journal ne constitue pas une vérification des fichiers serveurs.
- [Contrat PATCH1](../canon/interfaces/paper-roster.md), [contrat PATCH2](../canon/interfaces/paper-score-corrections.md), [audit transversal](paper-session-participant-identity-audit-2026-09-21.md), sections Bingo/lookup K-D et proposition historique désormais supplantée.

## H. Risques / rollback

Une association déclenche une lecture active/admission supplémentaire, partagée avec l’hydratation déjà en vol. Latence et concurrence réseau non mesurées ici. En échec de lecture, l’affichage est volontairement sans identité plutôt que fondé sur un roster périmé ; la phase peut continuer selon les chemins existants. Les ACK HTTP demeurent ceux du protocole authentifié existant. Pas de nouvelle garantie transactionnelle, ni refonte du chemin historique sans joueur.

Rollback ciblé : retirer seulement les hunks PATCH3 de `bingo_server.js` et rétablir le marker précédent, sans supprimer les changements PATCH1 ni les autres travaux locaux. Copies avant patch : `/tmp/paper-association-patch3-baseline/` (temporaires locales, non archivage de livraison). Tests et docs peuvent être retirés séparément ; aucun rollback de données. Aucun déploiement/restart exécuté.

**PATCH1 inchangé et réutilisé ; PATCH2 inchangé ; équipes Blind Test non traitées ; futur modèle équipe Hub non traité.**
<!-- AUTO-UPDATE:END id="bingo-paper-association-patch3-report" -->
