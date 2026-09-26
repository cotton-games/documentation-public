# Cotton Documentation — SITEMAP

**Navigation API privée (authentification requise) :** <https://api.github.com/repos/cotton-games/documentation/contents/SITEMAP.ndjson?ref=develop>

Lire avec les headers de START.md ; COTTON_DOCS_TOKEN pour Codex, jamais dans une URL.

<!-- Generated file — do not edit manually. Run npm run docs:sitemap -->

# Cotton Documentation — Navigation

**Start here**: lire le README général (https://api.github.com/repos/cotton-games/documentation/contents/README.md?ref=develop) avant d'ouvrir `canon/repos/*` (entrypoint obligatoire).
Ne pas naviguer directement dans les sous-repos sans ce contexte.

Canonical repository: `cotton-games/documentation`. Entrypoint: `START.md` → `SITEMAP.ndjson` → `DOCS_MANIFEST.md` → targeted paths.
- `main` = référence publiée PROD avec exclusions explicites ; `develop` = préparation. Preuve : URL API + chemin + branche + heading ; absent = `non trouvé`.
- `SITEMAP.txt` et le champ NDJSON `url` sont legacy / transition ; utiliser `api_url` pour les lectures privées.
- Web AI agents must orchestrate and delegate edits to Codex; do not propose code patches in chat.
- Verification-first: if unsure/missing info, don’t guess—organize verification (user or Codex audit).
- IDE agents: **do not edit `SITEMAP.md` or `canon/**/INDEX.md` directly**; edit `scripts/gen-sitemap.mjs` if structure must change, then run `npm run docs:sitemap`.

## How to use (humans + AI agents)
1) **Read first**
   - `README.md` → what this repo is, how to navigate, editing rules
   - `DOCS_MANIFEST.md` → “update triggers” (what code change → what doc to update)
   - `HANDOFF.md` → current state, what’s confirmed, what’s next, risks/debt

2) **Choose by intent**
   - **Integrate / understand API & contracts** → `canon/interfaces/*`
   - **Find endpoints / env vars / ports** → `canon/entrypoints.md`
   - **Run locally / dev ops** → `canon/runbooks/dev.md`
   - **Troubleshoot (403, tokens, connectivity, etc.)** → `canon/runbooks/troubleshooting.md`
   - **Data model / writes** → `canon/data/*`
   - **Project status / roadmap** → `HANDOFF.md`
   - **User-facing changes** → `CHANGELOG.md`
   - **Deep dives / historical reasoning** (not source of truth) → `notes/*`

3) **Editing rules (critical)**
   - **`canon/` is source-of-truth.** `notes/` is non-canon (context only).
   - Some files contain `AUTO-UPDATE` blocks:
     - AI tools may edit **only inside** `AUTO-UPDATE` blocks.
     - **Do not change block IDs.** Humans edit outside these blocks.
   - When code changes, update docs using the mapping in `DOCS_MANIFEST.md`.

---

## Branches
Lire via API Contents avec ref explicite. SHA source de génération : 146cadccd4ebdcc63904569789fde8e3ed7b6038 (ne fige pas la branche distante).
- develop: [START API](https://api.github.com/repos/cotton-games/documentation/contents/START.md?ref=develop) | [sitemap API](https://api.github.com/repos/cotton-games/documentation/contents/SITEMAP.ndjson?ref=develop) | sha 146cadccd4ebdcc63904569789fde8e3ed7b6038
- main: [START API](https://api.github.com/repos/cotton-games/documentation/contents/START.md?ref=main) | [sitemap API](https://api.github.com/repos/cotton-games/documentation/contents/SITEMAP.ndjson?ref=main)

## Repos (repo-first)
- [canon/repos/INDEX.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/INDEX.md?ref=develop)
- [canon/repos/documentation/README.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/documentation/README.md?ref=develop)
- [canon/repos/documentation/TASKS.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/documentation/TASKS.md?ref=develop)
- [canon/repos/games/README.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/games/README.md?ref=develop)
- [canon/repos/games/TASKS.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/games/TASKS.md?ref=develop)
- [canon/repos/bingo.game/README.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/bingo.game/README.md?ref=develop)
- [canon/repos/bingo.game/TASKS.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/bingo.game/TASKS.md?ref=develop)
- [canon/repos/bingo.game/INDEX.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/bingo.game/INDEX.md?ref=develop)
- [canon/repos/blindtest/README.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/blindtest/README.md?ref=develop)
- [canon/repos/blindtest/TASKS.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/blindtest/TASKS.md?ref=develop)
- [canon/repos/blindtest/INDEX.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/blindtest/INDEX.md?ref=develop)
- [canon/repos/quiz/README.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/quiz/README.md?ref=develop)
- [canon/repos/quiz/TASKS.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/quiz/TASKS.md?ref=develop)
- [canon/repos/quiz/INDEX.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/quiz/INDEX.md?ref=develop)

## Global specs
- [canon/INDEX.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/INDEX.md?ref=develop)
- [canon/interfaces/INDEX.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/interfaces/INDEX.md?ref=develop)
- [canon/data/INDEX.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/data/INDEX.md?ref=develop)
- [canon/data/cotton-certified-direct-import.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/data/cotton-certified-direct-import.md?ref=develop)
- [canon/data/quiz-numeric-question-adaptation-csv.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/data/quiz-numeric-question-adaptation-csv.md?ref=develop)
- [canon/runbooks/INDEX.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/runbooks/INDEX.md?ref=develop)
- [specs/INDEX.md](https://api.github.com/repos/cotton-games/documentation/contents/specs/INDEX.md?ref=develop)
- [specs/tests/INDEX.md](https://api.github.com/repos/cotton-games/documentation/contents/specs/tests/INDEX.md?ref=develop)

## DB schema (global)
- [canon/data/schema/OVERVIEW.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/data/schema/OVERVIEW.md?ref=develop)
- [canon/data/schema/MAP.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/data/schema/MAP.md?ref=develop)
- [canon/data/schema/DDL.sql](https://api.github.com/repos/cotton-games/documentation/contents/canon/data/schema/DDL.sql?ref=develop)

## Project status
- [START.md](https://api.github.com/repos/cotton-games/documentation/contents/START.md?ref=develop)
- [README.md](https://api.github.com/repos/cotton-games/documentation/contents/README.md?ref=develop)
- [DOCS_MANIFEST.md](https://api.github.com/repos/cotton-games/documentation/contents/DOCS_MANIFEST.md?ref=develop)
- [HANDOFF.md](https://api.github.com/repos/cotton-games/documentation/contents/HANDOFF.md?ref=develop)
- [CHANGELOG.md](https://api.github.com/repos/cotton-games/documentation/contents/CHANGELOG.md?ref=develop)
- [pm2-ws.md](https://api.github.com/repos/cotton-games/documentation/contents/pm2-ws.md?ref=develop)

## Notes & archive
- [notes/INDEX.md](https://api.github.com/repos/cotton-games/documentation/contents/notes/INDEX.md?ref=develop)
- [notes/archive/INDEX.md](https://api.github.com/repos/cotton-games/documentation/contents/notes/archive/INDEX.md?ref=develop)

## Other
- [canon/front/INDEX.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/front/INDEX.md?ref=develop)
- [canon/entrypoints.md](https://api.github.com/repos/cotton-games/documentation/contents/canon/entrypoints.md?ref=develop)

