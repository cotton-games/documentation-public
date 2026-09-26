# Quiz DEV — état figé d’envUtils et base du harnais Hub

<!-- AUTO-UPDATE:BEGIN id="quiz-dev-envutils-baseline-20260922" owner="codex" -->

**ÉTAT QUIZ DEV FIGÉ — HARNAIS HUB PEUT ÊTRE PRÉPARÉ.**

Audit du snapshot `/tmp/quiz-dev-snapshot/envUtils.js`, fourni après rechargement DEV. Les autres fichiers Quiz du lot instrumentation correspondent aux fichiers actuellement non commités de `sas_players`, selon confirmation opérateur ; le processus a été redémarré avec cet état. Cette attestation est retenue, sans redemander leurs snapshots. BT/Bingo n’ont pas reçu ce lot. Aucun accès serveur/DB, patch applicatif, marker, restart ou déploiement dans cette passe.

## Comparaison exacte

| Version d’envUtils | SHA256 | Conclusion |
|---|---|---|
| Snapshot DEV fourni | `ca7fca8edc8c8fe67cbcd29aa62dac7d20c0f26f5dea51d393443fba9014c366` | 13115 octets |
| AVANT instrumenté `/tmp/ws-loadtest-ab-2026-09-22-ready/before/quiz/web/server/actions/envUtils.js` | même SHA | **Identique octet pour octet** |
| Récupération `/tmp/quiz-ws-baseline-recovery-2026-09-22/web/server/actions/envUtils.js` | même SHA | **Identique octet pour octet** ; aucune variante provisoire supplémentaire |
| Worktree `sas_players` actuel | `d7bca2390f4fe7529289a67898db4397aa999832858c534f8d53d42fd08d539c` | 13397 octets, instrumentation + cohortes |
| APRÈS instrumenté du bundle figé | même SHA que worktree | Identique au local actuel |
| HEAD performance commité `74b99c90a69d9c94de98e69b9abb79b5c1e7e3ea` | `af8037ed8d4975caffcf8e22ff6d2f18f2a90a70e22eb1f477b3cd106f2f318f` | 12711 octets, cohortes sans les hooks non commités |

DEV→worktree : **un seul bloc différent**, autour des lignes188–199. Le local importe `createCapacityReader` depuis `./capacity_reads`, crée `readCapacity`, et route `hub_capacity_get` vers ce lecteur avec endpoint/origin/payload. DEV appelle directement `__canvasCallSource` pour cette action comme pour les autres. Tout le reste du fichier est identique.

La différence est fonctionnelle et voulue : DEV effectue une lecture source par demande atteignant le transport ; le local regroupe les appels identiques en attente avant le départ du fetch, via `setImmediate`. Ce n’est ni un cache TTL ni une réutilisation des nouvelles demandes arrivées après départ du fetch. DEV n’a **aucune dépendance** `capacity_reads` dans ce fichier, et aucun regroupement de capacité par ce chemin, même si un fichier module inutilisé était présent sur disque.

Endpoints, token service, actions Canvas, identité joueur, event_id des writes, payloads, parsing des réponses et gestion timeout/erreur sont identiques entre DEV et worktree en dehors de cette indirection. Pas de fallback caché, de bypass d’admission ou de désactivation de mesure. Pas de divergence inattendue à réparer. La qualification « temporaire » décrit son usage de récupération, pas un contenu distinct de l’AVANT propre.

## Hooks réellement présents dans DEV

Chemin analysé : `quiz-dev-snapshot/envUtils.js`.

- Ligne1 : import du collecteur `./loadtest_metrics`.
- Lignes188–195 : `loadtestMetrics.capacity(...)` sur `hub_capacity_get`, comptage des demandes et tailles observées par identité de réponse.
- Lignes197–201 : `measure('capacity_source_fetches', ...)` pour les sources capacité, et `measure('server_http_' + action, ...)` pour les autres actions passant par ce transport ; durées, succès/échecs/timeouts et I/O via le collecteur.
- Ligne262 : `capacity_response_bytes` sur le buffer réponse déjà lu, sans seconde requête.
- Ligne337 : `CanvasAPI.hubCapacity` emprunte ce chemin instrumenté.

Ces hooks n’enregistrent des mesures que si un contexte de run actif existe. Ils ne créent ni run Hub ni résumé de leur propre initiative. L’absence de `LOADTEST_*` lors du test Hub50 reste donc expliquée par le générateur navigateur, pas par un envUtils privé d’instrumentation.

## Matrice figée

| Élément | Quiz DEV | sas_players local |
|---|---|---|
| instrumentation loadtest | Présente, même lot que local selon opérateur ; hooks envUtils confirmés par snapshot. Harnais natif, pas encore Hub unifié | Présente, non commitée ; quatre JS hors envUtils identiques au bundle AVANT |
| capacité cohortes | **Absente dans le transport envUtils confirmé** | **Présente**, lecteur `capacity_reads` + dispatch ; `hubCapacity.js` contient aussi l’index WeakMap performance |
| publication / gameplay | Aucun patch de publication/gameplay dans le lot Quiz déclaré ; auto-start réel conservé | `actions/gameplay.js`, `actions/registration.js`, `messaging.js` inchangés entre ref AVANT et HEAD ; pas d’optimisation publication BT transposée à Quiz |
| marker | `restart 22-09-2026/03` **selon la correspondance opérateur des autres fichiers du lot avec le local** ; pas de snapshot marker demandé | `restart 22-09-2026/03`, lu, non modifié |
| envUtils | AVANT instrumenté, SHA `ca7fca8e…`, identique au fichier de récupération | APRÈS instrumenté, SHA `d7bca239…` ; unique delta : activation cohortes |

Le pack de récupération comportait un marker `/04` **préparé**, mais ce n’est pas une preuve de son déploiement. La dernière attestation opérateur fait foi pour la matrice : autres fichiers actuels, donc `/03`. Aucun numéro d’activation future n’est décidé ici et aucun marker n’est réécrit.

La copie DEV certifie envUtils ; l’attestation certifie les autres fichiers du lot. Elle n’est pas transformée en audit de tous les fichiers historiques/configurations de l’application. Notamment, le contenu déployé de `hubCapacity.js`, hors lot non commité, n’est pas certifié par cette copie : cela n’empêche pas de préparer le harnais sur une base AVANT explicitement figée. Aucun snapshot supplémentaire requis pour cet audit.

## Base exacte pour le prochain patch

**Base de compatibilité et de livraison AVANT Quiz : ref métier `69192a2f4e3a45557c6b6f88421969623828c68f` + instrumentation AVANT, dont envUtils est maintenant confirmé identique au DEV.** Pour les fichiers du lot, voici les contenus précis attestés à figer avant développement ; marker traité séparément comme métadonnée d’activation, pas comme patch métier :

| Fichier sous Quiz | SHA256 de base |
|---|---|
| `web/server/actions/envUtils.js` | `ca7fca8edc8c8fe67cbcd29aa62dac7d20c0f26f5dea51d393443fba9014c366` |
| `web/server/actions/loadtest.js` | `9141ec5c6b90928aa95a9af4dc89b00721e5addaf6c72667fbf71272ce906135` |
| `web/server/actions/loadtest_metrics.js` | `be745a1e58c7e55333b20fd15437267deef06350d94baef4833dfb7ad0268215` |
| `web/server/actions/wsHandler.js` | `0291d4b01da9d8f495859f97a2fd296cfbebba36442b50d33a736c01c56fbd6b` |
| `web/server/logger_v1.js` | `34666c0e49d55b68fcc8b65eb8631ee81a76f969e61b114b1c63981b61436d22` |
| `web/server/restart_serveur.txt` (attestation, pas mutation) | `1483f2bef845d9e99822490b5f5d8ddffa8f78056c032006092e37fef9b71b16` |

Le prochain développement peut rester sur `sas_players` ; **la base de livraison AVANT n’est pas le fichier envUtils complet de ce worktree**. Conserver le snapshot DEV et le bundle AVANT immuables. Préparer le delta du harnais unifié contre les cinq JS ci-dessus ; pour envUtils, partir du snapshot AVANT ou transposer seulement les nouveaux hooks en conservant le dispatch direct. Si ce fichier n’a pas besoin de changer, l’exclure du lot de livraison. Ne pas restaurer/envoyer automatiquement le local APRÈS par une copie de fichiers modifiés.

Pour les dépendances métier de la fixture AVANT : `hubCapacity.js` pris à la ref AVANT (sans WeakMap performance), aucun import `capacity_reads`. Ne pas livrer ces optimisations dans le lot harnais. La ref choisie définit la fixture reproductible ; elle n’est pas présentée comme une preuve byte-for-byte de tout le serveur actuellement chargé.

Conserver parallèlement le métier performance local actuel sans l’écraser. L’artefact APRÈS sera le même harnais instrumenté avec le delta métier explicite (`capacity_reads`, routage envUtils et index hubCapacity). Un seul harnais, deux manifests de métier ; aucun retour durable à deux architectures de test. Vérifier les empreintes et le diff livré, rejeter tout import cohortes dans l’AVANT ; capturer d’abord la baseline Hub unifiée avant livraison performance. L’adaptation de l’exporteur sera un futur travail de développement, pas une opération réalisée ici.

## Vérifications exécutées

Comparaison binaire/SHA des six envUtils ; diff AVANT→HEAD vérifie que le lot performance Quiz ne touche que `capacity_reads.js`, `envUtils.js`, `hubCapacity.js` et marker. Les quatre autres JS instrumentés sont identiques au bundle AVANT. Aucun fichier applicatif modifié.

Test existant exécuté sur une **copie du snapshot DEV fourni** dans `/tmp/quiz-dev-envutils-audit-2026-09-22/before/quiz/web/server/actions/`, avec collecteur local attesté. Transport HTTP simulé, aucun réseau/serveur/DB :

```sh
# Depuis /home/romain/Cotton/games
LOADTEST_AB_BEFORE=/tmp/quiz-dev-envutils-audit-2026-09-22/before node --test --test-name-pattern='/quiz:' web/tests/ws_loadtest_instrumentation_test.cjs
node --check /tmp/quiz-dev-snapshot/envUtils.js
```

**2 tests ciblés réussis**,8 hors périmètre ignorés :50 demandes synchrones identiques → snapshot DEV50 fetches, B/N=1, taille cohorte1 ; local APRÈS1 fetch, B/N=0,02, cohorte50. Bytes source comptés et résultat métier attendu identique dans cette fixture, avec et sans contexte diagnostique. Cela démontre le branchement des versions, pas une performance réseau réelle ni un gain garanti à toute cadence. Syntaxe valide.

Documentation : note dédiée, compléments dans conception Hub/rapport A/B, README/TASKS Quiz, TASKS Games et HANDOFF ; index générés et `git diff --check`. Aucun rollback applicatif requis. Aucun nouveau snapshot des autres fichiers Quiz demandé.

**ÉTAT QUIZ DEV FIGÉ — HARNAIS HUB PEUT ÊTRE PRÉPARÉ.** L’écart envUtils est l’écart AVANT/APRÈS prévu ; le remplacer par le local performance détruirait la baseline, le conserver fournit une base valide au prochain harnais.

<!-- AUTO-UPDATE:END id="quiz-dev-envutils-baseline-20260922" -->
