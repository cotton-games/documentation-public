# Documentation — accès privé canonique — 24/09/2026

## Périmètre et preuve

Source canonique : `cotton-games/documentation` ; contrat dans `START.md` (Accès privé canonique, Parcours, Preuve d’abord), relayé par README, manifest et carte repo documentation. Token dédié fourni par `COTTON_DOCS_TOKEN`, jamais enregistré. Aucun changement applicatif ou workflow de synchronisation.

Préflight effectué via API Contents privée avec les trois headers requis : `START.md?ref=main`, `START.md?ref=develop`, `SITEMAP.ndjson?ref=develop`, `DOCS_MANIFEST.md?ref=develop`, sous `https://api.github.com/repos/cotton-games/documentation/contents/`. START distant main/develop porte encore l’ancien contrat au moment de la lecture ; il s’agit d’une préparation locale, sans publication implicite.

Journal AI Studio consulté avant modification : le lecteur renvoie une enveloppe HTML, y compris avec raw=1 ; le Markdown intégral embarqué dans `const raw` a été extrait et recherché. Aucune occurrence ciblée START/manifest/générateur/dépôt public ; changements externes WWW/AI Studio hors périmètre. Aucun rechargement serveur prétendu. Accès AI Studio indépendant, aucun envoi du token GitHub à ce service.

## Compatibilité du générateur

`SITEMAP.ndjson` expose chaque page Markdown découverte (racine/canon/specs/notes), les index générés et les entrées ciblées existantes, avec `repository`, `path`, `branch`, `api_url`. Les chemins sont la référence. Les index Markdown pointent vers l’API privée. Le header Authorization est apporté par l’agent, jamais par le lien.

Le workflow existant vérifie le préfixe RAW du champ `url` et des lignes de `SITEMAP.txt`. Ces surfaces restent donc **legacy / transition**, avec `url_role` explicite en NDJSON et avertissement TXT ; les agents privés utilisent `api_url`. Aucun changement du workflow ni des anciennes destinations publiques. Le SHA de génération ne fige pas le contenu d’une branche distante.

## Validation

Résultat : **7 tests sur 7 réussis**, **197 entrées NDJSON** dont les chemins existent localement, gardes de publication compatibles, `git diff --check` sans erreur. Valeur de `COTTON_DOCS_TOKEN` absente des 35 fichiers modifiés/créés ; blocs AUTO-UPDATE existants respectés et workflow identique à HEAD.

- `DOCS_BRANCH=develop npm run docs:sitemap` : régénère les trois sitemaps et tous les index.
- `node --test scripts/gen-sitemap.test.mjs scripts/promote-docs.test.mjs` : génération isolée main/develop, chemins existants, format API, garde RAW legacy compatible avec le workflow, couverture Markdown et absence de credentials.
- Résultat distant : HTTP 200 sur `main` et `develop` pour START, sitemap et `canon/repos/games/README.md` (chemin réellement découvert). Lecture distante : START et sitemap de chaque branche, extraction d’un chemin réellement présent, puis GET de ce chemin dans le dépôt privé ; contrôle du nouvel `api_url` généré pour la même page. Aucune requête à un dépôt public.
- `git diff --check` et comparaison du workflow avec HEAD ; recherche en mémoire de la valeur de COTTON_DOCS_TOKEN dans les fichiers modifiés, sans l’afficher.
- Le nouveau contrat distant devra être vérifié après publication par l’opérateur ; aucun push, merge ou déploiement effectué ici.

## Références résiduelles : inventaire legacy / transition

Toutes les URLs publiques des anciens audits, notes, tâches et HANDOFF sont **legacy / transition**, conservées comme preuves datées. Elles ne rendent pas le miroir canonique. Leur remplacement rétrospectif n’est pas nécessaire à la navigation privée ; un éventuel nettoyage historique relève d’un chantier suivant.

Les occurrences du générateur et des sitemaps TXT/NDJSON sont nécessaires à la compatibilité temporaire décrite ci-dessus. Les index Markdown régénérés ne contiennent plus de référence publique. Le tableau recense les autres fichiers versionnés contenant encore le nom du dépôt public (comptage avant ajout du présent rapport).

| Fichier | Occurrences | Statut / raison |
|---|---:|---|
| `.github/workflows/publish-docs.yml` | 1 | Mirroring temporaire : workflow inchangé, destination de publication. |
| `HANDOFF.md` | 565 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `README.md` | 1 | Legacy / transition : explication explicite de la coexistence, sans autorité canonique. |
| `START.md` | 1 | Legacy / transition : explication explicite de la coexistence, sans autorité canonique. |
| `canon/deployment-status.md` | 4 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `canon/runbooks/hub-player-qr-migration.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `canon/runbooks/mirroring.md` | 2 | Mirroring temporaire : runbook, destination/secret de push ; compatibilité legacy documentée. |
| `docs/README_export_cohortes.md` | 4 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `docs/_audit/deep-research-report.md` | 5 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/audit-etape2-bo-contrat-cadre-reseau-2026-03-06.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/audit-etape2a-offre-reseau-dediee-2026-03-08.md` | 9 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/bingo-digital-auth-performance-2026-09-22.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/bingo-hub-resume-robustness-2026-09-18.md` | 13 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/bingo-paper-association-patch3-2026-09-21.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/blindtest-teams-standby-2026-09-08.md` | 4 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/cast-dev-poc-2026-09-17.md` | 8 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/dashboard-mobile-individual-master-2026-09-16.md` | 1 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-access-probable-only-2026-09-21.md` | 11 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-active-master-resume-2026-09-09.md` | 2 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-bots-2026-09-21.md` | 1 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-branding-sync-2026-09-07.md` | 7 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-empty-pro-navigation-2026-09-22.md` | 13 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-empty-reconciliation-2026-09-09.md` | 5 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-historical-player-end-audit-2026-09-07.md` | 21 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-initial-session-sas-audit-2026-09-22.md` | 9 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-launch-resume-ux-2026-09-08.md` | 6 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-launch-test-audit-2026-09-07.md` | 23 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-legacy-runtime-compatibility-2026-09-08.md` | 10 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-master-podium-scrollbar-2026-09-22.md` | 13 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-mobile-player-continuity-audit-2026-09-07.md` | 14 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-paper-early-roster-audit-2026-09-17.md` | 5 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-participation-cta-2026-09-20.md` | 4 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-photo-latency-audit-2026-09-06.md` | 8 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-play-photo-replacement-audit-2026-09-06.md` | 5 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-play-quit-rejoin-audit-2026-09-07.md` | 5 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-play-ux-end-to-end-audit-2026-09-06.md` | 6 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-player-registration-pipeline-audit-2026-09-22.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-prod-code-migration-2026-09-09.md` | 20 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-public-removed-sessions-2026-09-22.md` | 6 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-quick-add-source-2026-09-09.md` | 6 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-remote-master-ux-audit-2026-09-07.md` | 16 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-restart-from-zero-audit-2026-09-11.md` | 5 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-runtime-expired-2026-09-18.md` | 5 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-session-removal-audit-2026-09-16.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/hub-soiree-hotfix-2026-09-23.md` | 6 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/implementation-etape2-bo-contrat-cadre-reseau-2026-03-06.md` | 2 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/paper-roster-patch1-2026-09-21.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/paper-score-patch2-2026-09-21.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/paper-session-participant-identity-audit-2026-09-21.md` | 9 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/paper-session-participant-identity-audit-2026-09-21/doc-comparison.md` | 16 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/play-hub-account-return-share-2026-09-21.md` | 1 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/play-unified-hub-auth-2026-09-21.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/remote-bootstrap-regressions-2026-09-18.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/remote-ownership-transversal-2026-09-18.md` | 6 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/remote-takeover-exit-2026-09-18.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/ws-loadtest-ab-instrumentation-2026-09-22.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/ws-native-loadtools-audit-2026-09-22.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `notes/www-play-program-schedule-2026-09-21.md` | 1 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `tmp/audit-hub-pre-prod/RAPPORT.md` | 13 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `tmp/audit-hub-prod-initial/RAPPORT.md` | 3 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `tmp/dev_import_quiz_histoire_coupe_du_monde.sql` | 1 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |
| `tmp/hub-prod-initial-schema-2026-09-08/PROD-DECISIONS.md` | 4 | Legacy / transition : citations/preuves historiques conservées ; ne pas les utiliser comme contrat d’accès actuel. |

Consigne externe également repérée : `/home/romain/Cotton/AGENTS.md`, section 0, pointe vers le miroir comme entrée publique unique. **Legacy / transition, encore à migrer par l’opérateur** : hors racines inscriptibles de cette session ; la demande explicite de migration privée prévaut ici. Aucun autre dépôt applicatif modifié.

## Retour arrière

Revenir sur ce lot documentaire et régénérer avec la version précédente du générateur ; préserver les modifications indépendantes. Aucun rollback applicatif, DB ou workflow requis.

## Fichiers modifiés ou créés dans ce lot

- `DOCS_MANIFEST.md`
- `HANDOFF.md`
- `README.md`
- `SITEMAP.md`
- `SITEMAP.ndjson`
- `SITEMAP.txt`
- `START.md`
- `canon/INDEX.md`
- `canon/data/INDEX.md`
- `canon/data/schema/INDEX.md`
- `canon/front/INDEX.md`
- `canon/interfaces/INDEX.md`
- `canon/repos/INDEX.md`
- `canon/repos/bingo.game/INDEX.md`
- `canon/repos/blindtest/INDEX.md`
- `canon/repos/documentation/INDEX.md`
- `canon/repos/documentation/README.md`
- `canon/repos/documentation/TASKS.md`
- `canon/repos/games/INDEX.md`
- `canon/repos/global/INDEX.md`
- `canon/repos/play/INDEX.md`
- `canon/repos/pro/INDEX.md`
- `canon/repos/quiz/INDEX.md`
- `canon/repos/www/INDEX.md`
- `canon/runbooks/INDEX.md`
- `canon/runbooks/mirroring.md`
- `notes/INDEX.md`
- `notes/archive/INDEX.md`
- `notes/documentation-private-access-2026-09-24.md`
- `notes/paper-session-participant-identity-audit-2026-09-21/INDEX.md`
- `scripts/gen-sitemap.mjs`
- `scripts/gen-sitemap.test.mjs`
- `scripts/promote-docs.test.mjs`
- `specs/INDEX.md`
- `specs/tests/INDEX.md`
