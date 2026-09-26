# Migration du code Hub / soirée vers PROD — audit du 09/09/2026

**SERVER_RECONCILIATION CLEARED — MERGES MAY CONTINUE.** Les deux patches sont appliqués dans les fichiers de travail sur `hub_soiree` (non commités). Les nouveaux main contiennent exactement les références PROD. Résultats identiques aux sources préparées : PROD intégralement conservée, plus les seuls ajouts Hub. LP extérieure inchangée. Commiter ces deux réconciliations avant les merges ; aucun merge, push, déploiement ou SQL effectué dans cette passe.

État précédent conservé pour historique :

**État de reprise du 09/09 : CODE PACKAGE BLOCKED — SERVER_RECONCILIATION_REQUIRED.** Backfill PROD terminé/validé selon utilisateur ; Pro main=hub_soiree=a7b596570d99c64ecb768f9b84339e712146f7a4 confirmé. Sept autres repos sur main propres, ancien cherry-pick Bingo clos. Relecture fraîche AI Studio identique, mais règle LP WWW absente des deux branches et changement Global04/05 non réconcilié : copies serveur requises. Vrai merge Bingo refusé sur ORIG_HEAD.lock : .git toujours en lecture seule. Aucun merge/push/déploiement pendant cette reprise. [Tableau AI Studio, versions locales, copies précises et verdicts](../tmp/hub-prod-code-2026-09-09/REPRISE-AI-STUDIO.md).

Les sections A–G ci-dessous conservent **l'audit initial**, et non l'état courant des branches/DB. Le manifeste initial reste historique/candidat ; aucun fichier FINAL généré avant les vrais merges et validations. Les sources locales pointent maintenant vers les anciens main : ne pas transférer à partir de l'ancien CSV.

Livrables locaux détaillés : [inventaire et commits](../tmp/hub-prod-code-2026-09-09/INVENTAIRE.md), [tableau ordonné des fichiers](../tmp/hub-prod-code-2026-09-09/FICHIERS-PROD.md), [CSV opérateur avec sources absolues et empreintes](../tmp/hub-prod-code-2026-09-09/FICHIERS-PROD.csv), [attentes DB exhaustives](../tmp/hub-prod-code-2026-09-09/DB-ATTENDUS.md), [preuves des contrôles](../tmp/hub-prod-code-2026-09-09/evidence/). Le dossier `tmp` est local et ignoré par Git : archiver ces pièces avec la préparation de livraison ; leur présence publique n'est pas revendiquée.

## Preuves documentaires et périmètre

Pages RAW effectivement consultées, avec leurs sections utiles :

- [START main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), « Statut actuel », « Comparer develop vs main », « Discipline de génération » : distinction préparation/PROD, journal AI Studio, génération des index.
- [SITEMAP develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md), « How to use » et « Repos » ; [index texte](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt) et [NDJSON](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.ndjson).
- [README général](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md), « Doc discipline (repo-first) », « Sécurité » ; [manifest](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers », R11–R16 et « Server restart markers ».
- [HANDOFF](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md), « Phase 1 schéma Hub PROD : paquet final prêt », « Compatibilité runtime Hub avant migration PROD » et « Backfill Hub PROD59/70 préparé pour revue ». Le document local a aussi des mises à jour de reprise DB du 09/09, conservées intégralement ; ne pas déduire d'un instantané RAW l'état actuel du backfill traité séparément.
- [Global](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Ensure Hub : contrôle précis de status avant ALTER », « Compatibilité de la programmation legacy », « Provenance des exécutions de fin Canvas ».
- [Games](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Hub Remote: routage canonique générationnel », « Hub: validation papier puis retour après fin naturelle », contrat QR manuel et complément UX du 07/09.
- [Pro](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/README.md), Dashboard Hub canonique et parcours Bibliothèque/Programme ; [Play](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/play/README.md), « EP auth: intention probable Hub » et « EP classements: agrégat saisonnier Global ».
- [WWW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/www/README.md), pages publiques soirée/événement et regroupement des sessions sur les fiches lieu.
- [Bingo](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/bingo.game/README.md), « Validation papier et fin naturelle Hub », « Quit volontaire Hub reprenable » ; [Blind Test](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/blindtest/README.md), stand-by équipes et « Finalisation papier et fin naturelle Hub » ; [Quiz](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/quiz/README.md), « Finalisation papier et fin naturelle Hub ».
- [Entrypoints](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/entrypoints.md), « Points d’entrée », « Blind Test — coupe-circuit produit » ; [runbook PROD](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/runbooks/prod.md), « Lancer en prod », « Variables d’environnement » ; [PM2](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/pm2-ws.md), « Sélection de l’endpoint Canvas », « Preuves runtime PM2 (DEV, evidence-based — PROD might differ) » ; [bridge](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/canvas-bridge.md), contrats Hub/QR ; [actions](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/actions.md), matrice des actions.

Les huit README applicatifs ont également été téléchargés au même chemin sur `main` : **écart develop>main pour les huit**. Les SHA des contenus comparés sont archivés. Cela ne certifie pas le contenu des serveurs PROD.

Le journal AI Studio indiqué dans START a été consulté avant toute tentative de changement de branche, puis son `const raw` décodé depuis la réponse HTML. Sections EN COURS, TODO et historique de livraison ; dernière date affichée 28/08/2026. Chevauchements avec le lot : `global/web/global_librairies.php`, Pro authentification/contacts, `www/web/.htaccess` et `fo_sessions_view.php`. Ecommerce Global est déjà identique main=Hub et exclu du delta final ; les fichiers LP et newsletters signalés ne sont pas dans le lot. Le diff de `global_librairies.php` ajoute deux requires sans retrait du reste ; celui du routage WWW ajoute la soirée en préservant les autres règles. Les scripts Pro ajoutent le chargement sûr du helper transactionnel AI Studio. Aucun de ces constats ne vaut comparaison octet par octet avec un fichier serveur : **égalité serveur non trouvée dans la documentation** ; comparaison ciblée à réaliser avant transfert manuel. Aucun rechargement serveur ni écrasement local n'a eu lieu.

## A. Inventaire des branches

Neuf dépôts Git ont été trouvés sous `/home/romain/Cotton`, sans supposer la liste. Huit portent `hub_soiree` ; `documentation` n'en porte pas, reste sur `develop` et présentait déjà des modifications. L'inventaire détaillé donne les SHA complets, les commits dans les deux sens, les fichiers divergents dans les deux sens et le delta de merge simulé.

| Repo | Branche courante | main abrégé | hub_soiree abrégé | Commits main seuls / Hub seuls | Fichiers Hub depuis base / delta simulé |
|---|---|---|---|---:|---:|
| bingo.game | hub_soiree | 1038c05539bf | 42b829e63fc7 | 0 / 7 | 9 / 9 |
| blindtest | hub_soiree | 2823bc817ffa | 67f6cb0e3aac | 0 / 10 | 11 / 11 |
| games | hub_soiree | 786480de1ebc | 71eb3c713e39 | 0 / 105 | 91 / 91 |
| global | hub_soiree | 5ec94b28a998 | 626a76bfcd8b | 79 / 91 | 66 / 61 |
| play | hub_soiree | 39d99115516c | 4a7c22623ca2 | 0 / 7 | 10 / 10 |
| pro | hub_soiree | f5af07280eed | eaca08277ecf | 97 / 82 | 64 / 60 conflictuels |
| quiz | hub_soiree | 3ddc167a6c11 | cabfdb16fe31 | 0 / 4 | 8 / 8 |
| www | hub_soiree | 24704ea08c7e | 56b31c84566e | 93 / 7 | 14 / 9 |

`git ls-remote --heads origin main hub_soiree` confirme les SHA locaux des huit dépôts. Aucun fetch/push. Tous les fichiers applicatifs suivis sont propres ; **Bingo a néanmoins un sequencer de cherry-pick préexistant**. Ni suppression ni renommage dans les deltas de livraison simulés. Les fichiers main-only restent conservés, dont les caches QR Global et le calendrier V3 Pro.

## B. Audit de compatibilité

### Verdict par dépôt

Le verdict ci-dessous porte sur l'exécution demandée **dans cette session**. Un blocage des écritures Git ne signifie pas qu'un défaut fonctionnel a été trouvé dans tous les dépôts. Aucun dépôt n'est déclaré prêt à déployer.

| Repo | Verdict | Compatibilité examinée et blocage |
|---|---|---|
| bingo.game | MERGE BLOCKED | Fast-forward possible ; trois suites ciblées vertes. Cherry-pick préexistant empêche le switch. Ne pas abort/quit une opération dont l'intention n'est pas connue. Déploiement dépend du nouveau bridge Games pour les fins papier. |
| blindtest | MERGE BLOCKED | Fast-forward possible ; 15 cas du pilote équipes OFF verts. Tentative de switch refusée : `.git/index.lock`, Read-only file system. Nouveau features.js obligatoire avec les handlers. |
| games | MERGE BLOCKED | Fast-forward possible ; contrats Hub/Remote/Player, QR, branding, legacy et fins testés. Deux suites rouges expliquées ci-dessous, deux écarts de whitespace ; recette navigateur restante. Écritures Git interdites dans le profil courant. |
| global | MERGE BLOCKED | Merge-tree sans conflit ; ecommerce déjà identique, main-only conservé. Signatures existantes étendues par paramètres optionnels, stockage QR testé sur SQL isolé. Une suite de contrat Pro ancienne reste rouge. Écritures Git interdites ; fraîcheur serveur des fichiers AI Studio non certifiée. |
| play | MERGE BLOCKED | Fast-forward possible ; contrat EP Hub vert. Nouveau parcours auth/probable dépend de Global et des routes Games. Écritures Git interdites. |
| pro | MERGE BLOCKED | Conflit Git réel, corrections parallèles main à conserver, deux sources finales non validées, ensures Bibliothèque et dépendance AI Studio à vérifier. Ne pas résoudre arbitrairement même si les deux blocs conflictuels sont des espaces. |
| quiz | MERGE BLOCKED | Fast-forward possible, sept JS valides ; callbacks/env/fins papier comparés aux producteurs et consommateurs. Pas de suite fonctionnelle Quiz dédiée trouvée ; loadtest non exécuté. Écritures Git interdites. |
| www | MERGE BLOCKED | Merge-tree sans conflit ; ecommerce déjà identique. Routes Hub, SEO et rendu public examinés ; le seul test versionné ajouté concerne le contrat ecommerce et ne certifie pas la page Hub. Écritures Git interdites ; routage/fichiers serveur à rapprocher. |

### Modifications parallèles et conflit Pro

Global : les cinq fichiers ecommerce communs sont octet-identiques main=Hub. WWW : même constat pour les cinq fichiers ecommerce/contrats. Ils n'ont pas à être redéployés pour Hub. Pro : deux tests Stripe, webhook Stripe et détail d'offre déjà identiques ; liste Bibliothèque, widget offre et script checkout diffèrent.

`pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` produit deux blocs de conflit dans la simulation, autour de `subscription_data` (lignes 489 et 522 de la projection conflictuelle). Le contenu visible varie par espaces/ligne blanche ; aucun choix appliqué, conformément à la demande d'arrêt sur conflit.

**Le merge automatique ne doit pas être remplacé par une copie de la branche Hub.** Pour `ec_bibliotheque_list.php`, il conserve une suppression de `main` issue de `00ca6323d4b1f3317ede10b5adb73bdfb56c4063` (« fix pagination… ») : retrait du filtre PHP agenda/mine qui reconstruisait `total`, `page=1`, `last_page=1`. Copier le fichier Hub réintroduirait ce filtre et perdrait cette correction de pagination. La simulation est documentée, pas validée comme source finale. Le widget offre auto-fusionné est en revanche identique au blob Hub. Les deux chemins Pro à reconstruire depuis le futur merge sont le script checkout et la liste Bibliothèque. Recette ciblée pagination/choix de thème et souscription après résolution indispensable.

### Includes, routes, API, JSON et dépendances

- Global charge `app_games_hubs_functions.php` et `app_programming_recommendations_functions.php` depuis `global_librairies.php`. Le premier exige `app_games_hub_player_qr_functions.php`. Les points de chargement doivent suivre les nouveaux helpers sur disque.
- Games charge Global **avant** le bridge Canvas dans `games_ajax.php`. `boot_lib.php` et `app_hub_view_helpers.php` exigent le nouveau `session_options_form.php`. Les nouveaux modules Hub passent par le dispatch `t=jeux&m=hub_master|hub_play|hub_remote`. Les imports et assets nouveaux sont inclus dans la liste.
- Routes Games : `/hub/{hub_token}/master`, `/hub/{hub_token}/play`, `/hub/{remote_token}/remote`. Token Remote distinct du token public. Alias `global_ajax.php` préservé ; nouvelle règle `/master/{session_token}` pointe vers ce shim existant, qui charge `games_ajax.php`. Les anciennes routes Master/Player ont les gardes membership et exceptions de consultation/exécution ; Remote legacy réutilise seulement un accès autorisé existant ou renvoie un état contrôlé.
- Les trois WS appellent `hub_session_grace_expired` et `hub_session_natural_ended`, reconnus comme writes idempotents ; `games_ajax.php` les autorise et `boot_lib.php` les implémente. Le bridge reste `{ok,data,error,ts}`, service token et event_id. Ne pas redémarrer les nouveaux WS avant ce bridge : en Bingo, l'erreur de completion empêche de sortir de la revue de score papier ; les autres jeux ont aussi des branches d'échec/retry.
- `HUB_SESSION_FINISHED` transporte `hubToken`, `runtimeMode`, `sessionId`. Consumers Master/Player/Remote et leurs gardes de provenance présents. Le résultat `hub_execution` décide du retour Hub, sans convertir arbitrairement une ancienne session en exécution officielle. Les contrats de fin naturelle et séparation présentation/runtime sont testés.
- Remote : commande persistée puis claim par Master ; `control_poll.client_routing` gouverne la navigation avec target/session_id/execution_id/routing_generation/remote_url/runtime_kind/joinable. Retour par paire exécution/génération, readiness pour new/recreated, reprise existing sans attente ajoutée. Pas de navigation déduite du seul succès de commande. QR : mode/révision/confirmation et queue doivent être cohérents entre Global et Games.
- Play : `/extranet/games/hub/{token}`, paramètres `hub_account_join`, `id_securite_games_hub`, `hub_account_action=join|probable` conservés à travers signin/signup et les POST. Global choisit probable avant J ou inscription réelle pendant la fenêtre ; ne pas activer les producteurs de liens sans la page EP cible.
- WWW : `/fr/soirees/{token}`, nouveaux renderer/SEO Hub et relais des pages session/événement ; liste lieu groupée. La regex publique accepte les tokens alphanumériques avec tiret ; les tokens créés par le writer Hub actuel sont compatibles. Aucun chemin legacy supprimé par ce lot.
- Pro : helpers Dashboard/Programme/personnalisation/Bibliothèque avant les vues et actions ; `ec.php` et le routage après les modules. Le chargement email vise un fichier AI Studio externe au delta, gardé par is_file/function_exists avec journalisation d'échec : le garde évite un fatal mais ne prouve pas qu'un email sera envoyé.

Contrôle statique borné : 357 occurrences de chemins littéraux inspectées, 316 résolues dans les exports Git. Les occurrences restantes se ramènent à 25 références uniques : dépendances Node/configs hors Git, deux includes Google commentés et anciennes surfaces Pro. Toutes les références absentes sont déjà présentes dans main, sauf le bootstrap config du nouveau CLI DEV explicitement exclu. Ce contrôle n'exécute pas les résolveurs dynamiques. Tous les noms app_* appelés sur des lignes ajoutées ont une définition dans les sources candidates, sauf `app_joueur_pseudo_public_get`, explicitement protégé par function_exists avec repli pseudo/prenom. Aucun nouvel include applicatif littéral manquant démontré.

### Schéma, données et environnement

[Contrat DB exhaustif](../tmp/hub-prod-code-2026-09-09/DB-ATTENDUS.md) : 11 tables Hub et 2 Quick, 210 colonnes, 52 index, types/NULL/defaults/uniques détaillés. L'empreinte du helper Global courant correspond à `corrected_source_sha256` du pack schéma final. Aucune modification SQL nécessaire démontrée.

| Moment de livraison | Conclusion |
|---|---|
| Avant schéma | Pas une mise en service sûre : helpers historiques peuvent tenter CREATE/ALTER ; schéma partiel non qualifié. |
| Schéma complet, avant backfill | Certaines lectures legacy ont un repli et QR dégrade proprement ; cela ne suffit pas à autoriser la bascule. Les writers peuvent créer des Hubs et compromettre le protocole initial supposant les cibles vides. |
| Schéma + backfill validés | Ordre requis pour activer ce chantier sur les sessions reprises, après traitement des écarts entre le lot backfill et l'ouverture effective. Pas de promesse d'état DB déjà atteint. |

Les tables de publication, lots, roster, présence et commandes ne doivent pas recevoir de seeds fictifs. Publication compte et lots session legacy restent les sources initiales du pack. Les sessions hors lot ne doivent pas disparaître : fallback legacy et contrôle d'ambiguïté présents. Aucun remplissage de runtime ni de stats historiques par cette passe.

Pas de feature flag global Hub trouvé. `BLINDTEST_TEAMS_ENABLED=false` est une constante versionnée, sans surcharge client/env ; table blindtest_session_teams exclue tant que ce contrat reste fermé. Guards de table absente présents dans Canvas et Global. QR incomplet : réduit/commandes indisponibles, pas d'ALTER QR implicite. Les autres ensures Hub et Bibliothèque conservent leurs effets propres : le zéro DDL démontré sur schéma Hub conforme ne s'étend pas à tout Pro.

Configs locales/PROD et secrets conservés, aucun remplacement prévu : global_root, server, URL Games/Play/Pro/WWW/Global, `CANVAS_API_URL`, `CANVAS_SERVICE_TOKEN`, `CANVAS_API_SERVICE_TOKEN`, `APP_ENV`/`NODE_ENV`, hints d'origine et environnement PHP. Vérifier les valeurs PROD sans les journaliser. Les `.htaccess` modifiés contiennent des directives **Nginx `rewrite ... break;`** : ne pas les traiter comme des fichiers Apache autonomes. Mécanisme réel d'inclusion/rechargement du vhost PROD : non trouvé dans la documentation.

## C. Merges effectués

**Zéro.** Pour chaque dépôt, `main après = main avant` et `hub_soiree après = hub_soiree avant`, SHA complets dans l'inventaire. Aucun squash, suppression de branche, commit, force-update, fetch ou push.

Simulations réalisées par `git merge-tree --write-tree main hub_soiree`, avec objets temporaires dans `/tmp/hub-prod-audit/<repo>/objects` et lecture des objets du dépôt : aucune modification des refs/index originaux. Sept arbres non conflictuels exportés pour validation ; Pro testé sur la branche Hub, pas présenté comme arbre final fusionné. La simulation conflictuelle est seulement utilisée pour établir les écarts à préserver.

Tentatives et refus exacts :

```text
git -C /home/romain/Cotton/bingo.game switch main
fatal: cannot switch branch while cherry-picking

git -C /home/romain/Cotton/blindtest switch main
fatal: Unable to create '/home/romain/Cotton/blindtest/.git/index.lock': Read-only file system
```

Bingo : sequencer avec tête initiale f1ae312546246ab439bfeb8212e5c9a6332c5381 et tâches `pick 2f4c2b6 morceau entier`, `pick f307c94 persist endGame serveur`, sans CHERRY_PICK_HEAD. Rien n'a été continué, quitté ou annulé. Les huit `.git` applicatifs sont en lecture seule dans le profil d'accès fourni ; aucune tentative de contournement. Les refus sont des erreurs Git/filesystem, pas un rejet d'auto-review.

## D. Validation

Contrôles **avant merge, sur sources candidates**, pas validation après merge : 184 `php -l`, 61 contrôles de syntaxe JS, tous verts. Pour les modules navigateur, `node --input-type=module --check` lit le source ; pour CommonJS/ESM explicites, `node --check fichier`.

| Repo | PHP lint | JS syntaxe | Suites/pilotes ciblés, après correction du contexte de test uniquement |
|---|---:|---:|---|
| bingo.game | — | 8 | 3/3 verts : phases, quit guard, livraison terminale |
| blindtest | — | 10 | 1 pilote vert, 15 cas équipes OFF |
| games | 36 | 36 | 32/34 verts ; deux rouges décrits ci-dessous |
| global | 63 | — | 43/44 verts + pilote SQL QR vert |
| play | 9 | — | 1/1 vert |
| pro | 63 | — | 13/14 verts sur Hub ; pas sur futur merge |
| quiz | — | 7 | Aucune suite dédiée trouvée ; loadtest non lancé |
| www | 13 | — | 1/1 vert, contrat ecommerce uniquement |

Soit 95 suites/pilotes verts sur 99, quatre rouges conservés, plus une contre-sonde UX datée verte. Les logs et commandes exactes sont dans validation.json et validation-followup.json. Le test PHP de stockage QR requiert un socket privé et est lancé par son pilote Python ; MariaDB 10.11.14 jetable sans réseau, arrêté après test. Absent/partiel/complet, CAS SQL, queue, instances, priorités testés. Aucun accès aux DB existantes ou aux services WS/Stripe/AI Studio d'écriture.

Échecs originaux et diagnostic :

1. Games `hub_remote_contract_test.php:330` : recherche l'ancienne expression exacte du markup QR. Le nouveau renderer place le QR réel uniquement hors découverte ; l'attribut n'a donc plus la conjonction précédente. Couverture SSR découverte/actif verte dans les suites dédiées. Assertion obsolète, pas modifiée pendant cet audit.
2. Games `hub_remote_master_ux_test.php:80` : fixture `hub_date=2026-09-07`, expirée le 09/09 selon la fenêtre J+1 midi. Contre-sonde exportée, seule date changée en `date('Y-m-d')` : suite intégralement verte. Test original toujours rouge ; aucun changement applicatif.
3. Global `schedule_plan_commit_contract_test.php:59–60` : recherche `found_read_only` et le commentaire `Bootstrap legacy uniquement` dans l'ancien emplacement Dashboard. Le nouveau resolver et les contrats legacy sont présents ; tests comportementaux SchedulePlan et legacy verts. Ces assertions lexicales restent rouges.
4. Pro `ec_legacy_events_navigation_test.php:22` : borne la Home sur le commentaire d'archive `// Version 14/10/2024`, absent. Les autres assertions passent ; tests Home composition/branding verts. Pas de résolution du conflit Pro ni de recette finale induite.

Trois échecs de contexte de test ont été levés sans modifier le code : deux SQL canoniques requis par les tests ont été copiés dans l'export documentaire voisin (Global idempotence et Pro Quick Schedule repassent) ; le test Dashboard Pro a été exécuté dans le workspace réel pour lire sa configuration locale ignorée par Git et passe. Pas de copie de secrets dans le paquet.

`git diff --check main <arbre candidat>` : vert sur six dépôts ; Games signale trailing whitespace dans `web/player_canvas.php:883` et ligne vide finale dans `web/tests/hub_compact_aggregate_test.php:130`. Pro contrôlé main→Hub, pas le merge conflictuel : whitespace présent, détails archivés. Aucun nettoyage hors du périmètre de préparation ; ne pas annoncer tous les diff checks verts.

Après les merges futurs : refaire syntaxe/tests ciblés sur les vrais arbres `main`, diff check, statut complet (pas seulement porcelain), absence d'unmerged entries et d'opérations en cours, comparer le delta à l'inventaire initial puis régénérer les empreintes et les deux sources Pro. La cohérence inter-repos actuelle est celle de projections candidates avec Pro Hub, pas d'un ensemble de main mergés.

## E. Liste exhaustive des fichiers PROD

[Tableau Ordre / Repo / Fichier / Type / Dépend de / Pourquoi](../tmp/hub-prod-code-2026-09-09/FICHIERS-PROD.md) et [CSV opérateur](../tmp/hub-prod-code-2026-09-09/FICHIERS-PROD.csv) : **153 chemins**, dont **151 utiles au runtime et 2 PNG source optionnels**. Répartition : Global 17, Games 46, Bingo 6, Blind Test 10, Quiz 8, Play 9, WWW 9, Pro 48. Chaque ligne donne le chemin relatif exact ; CSV : source absolue et SHA-256 courant.

Les 106 autres chemins du delta simulé sont tous classés dans l'annexe des exclusions : tests/diagnostics, 11 anciennes migrations SQL de Games, outil DEV Global. Aucun fichier purement documentaire dans le tableau applicatif. Aucun fichier à supprimer ou renommer. Aucun package Node/lockfile/config secret modifié entre les branches. Les deux PNG ne sont pas nécessaires au renderer qui appelle le WebP ; ils sont marqués optionnels explicitement.

Pour les huit repos : **chemin PROD non trouvé** dans les pages RAW consultées. Les preuves PM2 disponibles désignent DEV et ne sont pas transposées à PROD. Les chemins source locaux sont `/home/romain/Cotton/<repo>/` + chemin exact du tableau. Les fichiers Pro checkout et liste Bibliothèque ne doivent pas être transférés depuis ces sources Hub : leur source finale doit provenir du merge résolu. Rien de cette liste n'est libéré pour déploiement tant que les blocages restent ouverts.

## F. Ordre global recommandé

Cet ordre est déduit des requires, routes et callbacks. Il suppose une fenêtre de maintenance pour la livraison du code : aucune compatibilité de copie progressive pendant une partie active n'est certifiée. La politique de verrouillage du backfill séparé reste celle de son propre pack ; cette recommandation n'impose pas de modifier ce SQL.

| Étape | Travail manuel précis | Déjà en place | Inversion / atomicité |
|---:|---|---|---|
| 0 | Lever blocages Git/Pro, figer les SHA finaux et le manifeste, sauvegarder les fichiers ciblés et les configs serveur ; comparer les fichiers signalés AI Studio ; planifier fin des parties et suspension des accès/writers pour la bascule code. | Merges et validations réellement terminés ; racines PROD établies. | Pas de transfert depuis des sources encore divergentes. Pause code globale jusqu'à l'étape 9 ; les resets de processus perdent leur mémoire runtime. |
| 1 | Confirmer le schéma complet puis le backfill **du pack courant**, avec ses PRE/POST et contrôle des nouveaux écarts avant activation. Références locales aux packs schéma 08/09 et backfill 09/09, sans rejouer d'anciennes migrations. | Procédure DB séparée autorisée et résultats opérateur. | Le code avant cette étape peut lancer ses ensures/writers ; simple existence des tables insuffisante. DDL et backfill ne sont pas une transaction commune. Ne pas rerun le contrôle de vacuité initial après un backfill réussi. |
| 2 | Copier les deux assets Global `web/assets/branding/hubs/cotton-hub-default-logo.png` et `cotton-hub-default-visual.jpg`. | Racine assets Global et droits de lecture HTTP. | Additif ; avant les templates qui les référencent. Pas de restart. |
| 3 | Suivre les lignes Global : helper QR puis helper Hub et recommandations, modules sessions/joueurs/clients/branding/événements ; `global_librairies.php` et `global_ajax.php` en dernier. | Schéma/backfill validés, ancien code hors trafic pendant le lot. | Global est requis par tous les frontaux. Bibliothèque de fonctions et loaders constituent un lot coordonné ; remplacer un loader avant le helper crée un fatal. |
| 4 | Games : images, nouveaux JS/CSS et `session_options_form.php`, autres modules/JS/CSS, adapters et `boot_lib.php`, helper/projections/handlers Hub, puis `games_ajax.php`, les trois pages Canvas et `.htaccess`. | Global terminé ; tous les imports/URLs du tableau disponibles. | Lot Games cohérent avant retour trafic. Bridge doit précéder nouveaux WS ; JS avant import maps/templates. QR PHP/JS et Global vont ensemble. |
| 5 | Pour chacun des trois WS : nouveaux modules en premier, handlers/envUtils/messaging ensuite ; marker en dernier. Redémarrer chaque processus effectif après le transfert complet et vérifier son endpoint Canvas/tokenPresent. | Bridge Games nouveau et Global, aucune partie en cours, dépendances Node existantes. | Module manquant au boot = crash. Nouveaux WS avec ancien bridge = fin/grâce Hub refusée. Un restart par service ; noms/cwd PROD à établir, ne pas reprendre ceux de DEV. |
| 6 | Play : nouveau détail EP Hub puis auth/signup et classements/inscription, règle `.htaccess` en dernier. | Global et Games opérationnels ; URLs PROD cohérentes. | Le retour probable a besoin de la route EP. Publier un lien avant la cible crée un parcours cassé. Lot auth + page + route cohérent. |
| 7 | WWW : partial Hub puis SEO/vue Hub, relais événements/sessions et agrégat lieu, `.htaccess` en dernier. | Global, Games et Play. | Évite des liens publics vers des routes absentes. Le merge conserve les ajouts main-only et les règles LP ; une copie complète de Hub est interdite. |
| 8 | Pro : helpers/styles/Bibliothèque, vues/widgets puis actions `ec_start_script.php`, Dashboard, navigation `ec.php` et `.htaccess`. Utiliser les deux sources finales issues du merge Pro. | Tous les services précédents + résolution Pro + helper email externe présent. | Pro est le principal producteur de programmation/lancement : pas de nouvelle soirée tant que les consumers ne sont pas prêts. Ensemble PHP et JS inline à livrer comme un lot. |
| 9 | Valider/recharger les rewrites via la configuration réellement utilisée, invalider les assets concernés et OPcache si nécessaire, contrôler l'intégration puis rouvrir les accès. | Tous les transferts complets, WS redémarrés, DB conforme. | Un simple upload `.htaccess` ne démontre pas activation Nginx. Le retour en trafic est la frontière atomique de la livraison coordonnée. |

Les étapes 3–8 peuvent être préparées dans des emplacements de staging si l'infrastructure le permet ; aucun mécanisme de symlink/release n'est attesté ici. Le tableau de fichiers reste utilisable pour une copie manuelle sous maintenance. Les assets existants ont des références dont le versionnement n'est pas uniforme : plusieurs import maps utilisent filemtime, des références Hub/CSS/launch_confirmation restent sans version. Invalidation ciblée côté cache/CDN et rechargement des clients requis selon l'installation ; ne pas supposer qu'un mtime règle tous les caches.

## G. Actions manuelles, limites et rollback

1. Reprendre dans une session autorisant l'écriture des `.git` applicatifs. Clarifier/terminer l'opération Bingo existante selon son intention, sans abort automatique. Résoudre Pro après revue des deux blocs et conserver le correctif pagination main ; aucune action n'a été réalisée sur le sequencer.
2. Réconcilier les quatre tests obsolètes/dépendants du temps et les whitespace signalés, refaire les contrôles sur les futurs main ; revue/recette Pro pagination et souscription. Aucune variante de test temporaire ne remplace un test committé.
3. Confirmer les résultats du schéma/backfill séparés et l'écart de cohorte avant ouverture. Contrôler les ensures Bibliothèque et leurs droits/normalisations ; ne pas accorder DDL ou rejouer un SQL historique pour faire disparaître une erreur.
4. Renseigner les racines PROD et les commandes de restart/vhost réellement utilisées. Vérifier lecture des nouveaux helpers/assets, répertoires existants d'upload/branding/photos accessibles en écriture au runtime concerné. Aucun chmod global ni nouveau mode chiffré inventé ; fichiers/dossiers d'upload hors Git conservés.
5. Comparer les sources serveur signalées AI Studio avec les versions finales ; conserver configs/secrets/Node modules/uploads/caches. Vérifier la présence du helper transactionnel et tester le parcours mot de passe/invitation dans la recette autorisée ; aucun email de test envoyé par l'agent.
6. Recette après mise en place : anciens liens Master/Player/Remote, compte actif et découverte, Master présent/absent, reprise existante et nouvelle exécution, QR réduit/agrandi et confirmation, probable avant J/inscription réelle, trois jeux numérique/papier, édition/validation des scores, fin naturelle et retour sur même exécution/génération, sortie volontaire/grâce, branding/probables/lots legacy, page publique et Dashboard. Fenêtres J/J+1 midi à couvrir. Aucun test navigateur PROD ni session réelle prétendu exécuté ici.
7. Rollback code : refermer les accès, restaurer **le jeu complet** de fichiers sauvegardés par étape, retirer seulement les nouveaux chemins listés si le retour à main avant livraison l'exige, restaurer les rewrites, rétablir les trois WS cohérents et invalider les caches. Ne pas revenir partiellement Global/Games/WS. Conserver les tables/données Hub tant qu'une procédure DB séparée n'autorise leur retrait ; un rollback code ne constitue pas un rollback backfill, surtout après nouvelles participations/programmations.

Documentation de cette passe : présente note, tâche dédiée dans les huit TASKS (update-not-append en cas de reprise), HANDOFF, routing R17, sitemap/index régénérés. Aucun README fonctionnel changé puisqu'aucun comportement applicatif n'a été modifié. Les mises à jour DB préexistantes ou concurrentes dans documentation sont préservées ; aucune livraison locale n'est qualifiée de déployée.
