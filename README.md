# Documentation – Cotton Quiz (IA handoff)

> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

## AI workflow (mandatory)

- **Web AI agent (this chat) does not code** (no patches/diffs here): it **plans**, **compiles evidence**, and **writes prompts**.
- If structural details are missing (entrypoints, file locations, data flow, DB writes, WS/API contracts, env vars, side effects), the web agent must request a **Codex audit** (no guessing).
- Deliverable of the web agent: **1..N actionable prompts** for **Codex in VS Code** (scope, files, acceptance checks, and required doc updates).

Source of truth: see `DOCS_MANIFEST.md` → **“AI workflow rule (roles)”**.

### Doc discipline (repo-first)
- Chaque action réalisée → mettre à jour `canon/repos/<repo>/TASKS.md` (update-not-append si la tâche existe déjà).
- Tout changement fonctionnel (flux / actions / contracts / env / log / DB writes) → mettre à jour `canon/repos/<repo>/README.md`.
- Verification-first : le code fait foi ; la doc doit suivre.

### Orchestrators (Web AI) — non-negotiable rule
Any prompt you write for Codex must end with the **“Docs (obligatoire)”** block:
- route documentation updates using `DOCS_MANIFEST.md` (no global doc scan),
- update only `AUTO-UPDATE` blocks (IDs stable),
- and update `HANDOFF.md` **every run** (minimum doc update).

#### Docs (obligatoire) — snippet to paste in every Codex prompt
1) `changed = git diff --name-only`
2) Apply `DOCS_MANIFEST.md` triggers → open only target docs
3) Edit only `AUTO-UPDATE` blocks (IDs stable)
4) Update `HANDOFF.md` (always)
5) If no trigger matches and it’s a new surface → add a trigger (no global scan)

## Parcours de lecture (Agent)
1) `HANDOFF.md`
2) `canon/architecture.md`
3) `canon/entrypoints.md` + `canon/tree.md`
4) `canon/interfaces/canvas-bridge.md` + `canon/interfaces/actions.md`
5) `canon/data/*`
6) `specs/*` (smoke/tests)

## Canon vs Notes
- **Canon** : source de vérité (courte, contractuelle, maintenue par Codex).
- **Notes** : historique / audits / explorations (utile, mais non contractuel).

## Sécurité (secrets / mirroring public)
- Ne jamais committer de fichiers runtime locaux : `.env*`, `secrets*.env`, clés (`*.pem`, `*.key`, etc.), dumps (`*.sql`), logs (`*.log`, `logs/`), caches (`cache/`, `tmp/`) et scripts ops locaux (`_ops_local/`).
- Conserver **uniquement** des templates versionnés (`.env.template`, `secrets.env.template`, `config.template.php`, etc.) et documenter la procédure “copier → remplir”.
- Si un secret a déjà été committé (même supprimé ensuite) : considérer la valeur compromise → **rotation** + (si nécessaire) purge d’historique (ex: `git filter-repo`) avant mirroring vers le public.

## Bonnes pratiques de prompt pour Codex (VS Code)

### Objectif
Donner à Codex des instructions **actionnables** (quoi changer, où, comment valider), et lui demander **systématiquement** de mettre à jour la documentation canon associée.

### Automatisation des index docs (local)
- Active le hook une fois : `git config core.hooksPath .githooks`.
- Le hook `pre-commit` régénère `SITEMAP.md` et tous les `INDEX.md` dès qu’un `.md` est staged, puis les re-stage automatiquement.
- Si tu modifies la documentation manuellement, lance `npm run docs:sitemap` avant commit pour mettre à jour la version publique.

### Règles simples
1) **Cadre** : décris le contexte (jeu, module, flux) et la contrainte (perf, compat, sécu, idempotence, etc.).
2) **Scope précis** : liste les fichiers/dossiers cibles *et* ceux à ne pas toucher.
3) **Définition de “Done”** : conditions vérifiables (commande à lancer, comportement attendu, logs, tests smoke).
4) **Diff minimal** : demande un patch court, sans refactor non demandé.
5) **Documentation en même temps** : impose l’update documentation (canon + changelog) en fin de tâche.

### Template de prompt (copier/coller)
> **Contexte**
> - Objectif : <ce que je veux obtenir>
> - Pourquoi : <raison / bug / contrainte>
>
> **Scope**
> - À modifier : <liste fichiers ou dossiers>
> - À ne pas modifier : <liste>
>
> **Exigences**
> - Compat : <prod/dev, versions, contraintes>
> - Sécurité : <tokens, event_id, droits>
> - Perf : <si applicable>
>
> **Critères de validation**
> - Cas 1 : <étapes + résultat attendu>
> - Cas 2 : <...>
>
> **Livrable**
> - Fais un patch (diff) + notes de test.
> - Puis **mets à jour la doc** :
>   - `CHANGELOG.md` (bloc `changelog-latest`) si changement visible.
>   - La documentation canon concernée **uniquement dans les blocs `AUTO-UPDATE`** (IDs stables).
>   - Si une nouvelle surface existe (action, endpoint, env var, write DB), mets à jour le mapping dans `DOCS_MANIFEST.md`.

### Exemples rapides
**Bugfix ciblé**
> Corrige le bug “<symptôme>” sur Bingo : le handler `<action>` ne met pas à jour `<champ>`.
> Scope : `ws/bingo/*`, `api/canvas/*`.
> Done : smoke `specs/smoke-canvas-api.md` passe + logs WS montrent `<message>`.
> Docs : update `canon/interfaces/actions.md` + `canon/interfaces/canvas-bridge.md` (blocs) + changelog.

**Ajout d’une action**
> Ajoute l’action `bingo:case_lock` (payload `<...>`) avec idempotence via `event_id`.
> Mets à jour : handler WS + write map DB si nécessaire.
> Validation : curl d’exemple + vérif DB.
> Docs : `actions.md` (liste + matrix) + `canvas-bridge.md` (exemples) + `bingo-write-map.md` si write.

### Anti-patterns (à éviter)
- “Refactor général” sans limites de scope.
- Demander “mets à jour la doc” sans pointer **quelle** documentation / blocs.
- Oublier les critères de validation (Codex “devine” et sur-modifie).

<!-- AUTO-UPDATE:BEGIN id="docs-index" owner="codex" -->

## 26/09/2026 — Capacités DEV contrôlées de Codex

[Contrat central dans le runbook DEV](canon/runbooks/dev.md#capacités-dev-contrôlées-de-codex--26092026) : déploiement ciblé via wrapper, logs en lecture seule, Playwright et états PRO/PLAY/BO hors Git, boucle autonome pour les tâches demandant implémentation + validation DEV. Restrictions SSH/PROD/infrastructure/DB et interdiction de contournement conservées. Capacités validées manuellement selon l’opérateur ; ce chantier documente leur disponibilité, sans déploiement ni recette applicative. [Suivi documentaire](canon/repos/documentation/TASKS.md).


## Hotfix et suivi de recette — 23/09/2026

**Hotfix préparé sur `hub_soiree`, recette DEV compte442 auditée partiellement ; livraison/essai PROD ensuite signalés par l’opérateur, avec incident Player cloclo non résolu (rapport K).** Admission WS ciblée des Players Hub officiels numériques déjà admis et reprise de la même intention après timeout technique organisateur. Aucun sas Player, readiness composite, roster/délai/compteur nouveau, protocole `HUB_PLAYER_READY`, runner ou optimisation de charge. Git en lecture seule : aucun nouveau commit ni branche. [Rapport et limites](notes/hub-soiree-hotfix-2026-09-23.md). La livraison signalée du hotfix ne vaut ni livraison de `hub_session_readiness`, ni résolution de l’incident Player ; les logs DEV ne prouvent pas la parité de tous les fichiers déployés.


## Production et travaux en cours — 23/09/2026

**`hub_soiree` déployé en production selon confirmation opérateur ; évolutions `sas_players`, `hub_session_readiness` et `cast` NON DÉPLOYÉES EN PROD.** [État de livraison de référence](canon/deployment-status.md). Ce statut reste applicable après promotion de la documentation vers `main` ; présence documentaire et livraison applicative sont distinctes.


- Bingo papier : [PATCH3 association facultative joueur/grille, rapport et tests](notes/bingo-paper-association-patch3-2026-09-21.md).


## Promotion après déploiement PROD

Le contenu de main reprend exactement develop ; les sitemap/index sont régénérés pour main. Utiliser `node scripts/promote-docs.mjs` depuis main propre, puis vérifier et committer. Pour un merge déjà ouvert : `--resume`. Installation initiale dans develop obligatoire. [Procédure et tests](notes/documentation-promotion-main.md).

## Documentation entrypoint (start here)
- Source canonique : dépôt privé **`cotton-games/documentation`**. Point d’entrée : `https://api.github.com/repos/cotton-games/documentation/contents/START.md?ref=main`.
- Codex utilise **`COTTON_DOCS_TOKEN`** fourni par l’environnement uniquement pour les lectures documentaires GitHub. Headers et confidentialité : START, section « Accès documentaire privé canonique » ; aucune valeur de token dans les fichiers, logs ou réponses. Le token AI Studio reste indépendant.
- Avant le parcours thématique ci-dessus : START sur `main`, puis SITEMAP.ndjson → README → DOCS_MANIFEST → HANDOFF. **Pour un chantier de préparation, basculer vers `develop` après START pour toutes ces lectures et les docs de travail** ; pour la référence publiée PROD, rester sur `main`, exclusions de déploiement conservées.
- Navigation sans supposition par chemin identifié, via API Contents privée. Anciens index main : extraire le chemin de `title` / `url` selon START, sans visiter le miroir. `documentation-public` et ses liens résiduels sont **legacy / transition** ; leurs anciens libellés d’entrée obligatoire sont remplacés par START.
- Preuve d’abord : URL API sans secret + chemin + branche + heading ; information absente = `non trouvé`. Pour un audit d’écart, comparer le même chemin sur `main` et `develop`.
- Les branches divergent volontairement : la procédure de promotion ci-dessus concerne une promotion explicitement demandée, **pas cette correction ciblée du contrat d’accès sur main**. Aucun contenu fonctionnel de develop n’est importé par ce lot.

## Web AI agent role (type ChatGPT web)
- Orchestrate only: plan + prompts + validation steps.
- Do NOT propose code patches in chat.
- All code/doc edits must be performed by Codex in the repo.
- Always log actions in `HANDOFF.md` (“Actions réalisées”).
- Règle ops : toute modif des serveurs WS doit aussi bump le marker de restart correspondant (voir “Server restart markers” dans `DOCS_MANIFEST.md`).
- Anti-rescan: déterminer les docs à ouvrir via `git diff --name-only` + `DOCS_MANIFEST.md` (pas de scan global).
- Web AI orchestrator rule: tout prompt Codex doit inclure en fin le bloc “Docs (obligatoire)” (voir `DOCS_MANIFEST.md`).

Mini workflow:
`User describes change → Web agent writes plan + Codex prompt → Codex implements → Web agent verifies via docs.`

## Verification-first rule (no guessing)
- If info is missing/uncertain: do not guess.
- List Unknowns → choose verification path → only then propose actions (especially for prod/deploy).

Template (required):
- Unknowns:
- Risk if wrong:
- How to verify (User/Codex):
- Owner:
- Proof/Stop condition:

Example (PM2 / relative `cwd`):
- Unknowns: what the real server paths are; what PM2 `cwd` resolves to; what folder actually contains `server.js`.
- Risk if wrong: restarting the wrong process / broken deploy due to bad working directory.
- How to verify: User runs `pm2 show <app>` + `pwd` in the deploy dir, or Codex audits the PM2 config + repo layout and proposes the exact commands to confirm.
- Proof/Stop condition: captured output showing absolute `cwd` + script path match the intended service.

## Index (auto)
- Handoff: `HANDOFF.md`
- Canon
  - Architecture: `canon/architecture.md`
  - Repo map: `canon/tree.md`
  - Entrypoints: `canon/entrypoints.md`
  - Logging: `canon/logging.md`
  - Interfaces
    - Canvas bridge: `canon/interfaces/canvas-bridge.md`
    - Actions: `canon/interfaces/actions.md`
  - Data
    - Bingo DB usage: `canon/data/bingo-db-usage.md`
    - Bingo write map: `canon/data/bingo-write-map.md`
    - Quiz numeric CSV adaptation: `canon/data/quiz-numeric-question-adaptation-csv.md`
  - Runbooks
    - Dev: `canon/runbooks/dev.md`
    - Mirroring: `canon/runbooks/mirroring.md`
    - Prod: `canon/runbooks/prod.md`
    - Troubleshooting: `canon/runbooks/troubleshooting.md`
- Specs
  - Smoke: `specs/smoke-canvas-api.md`
  - Tests: `specs/tests/`
- Notes
  - Audit: `notes/bingo-audit-summary.md`
  - Recommendations: `notes/recommendations.md`
  - Archive: `notes/archive/`
<!-- AUTO-UPDATE:END id="docs-index" -->
