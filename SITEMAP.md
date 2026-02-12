# Cotton Documentation — SITEMAP

**Share (cache-busted):** <https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/SITEMAP.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca>

*If ChatGPT sees a “compacted” SITEMAP, always open the Share link above.*

<!-- Generated file — do not edit manually. Run npm run docs:sitemap -->

# Cotton Documentation — Start Here (Single Entrypoint)

**Start here**: lire le README général (https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/README.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca) avant d'ouvrir `canon/repos/*` (entrypoint obligatoire).
Ne pas naviguer directement dans les sous-repos sans ce contexte.

This `SITEMAP.md` is the **single entrypoint** to the Cotton documentation.
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
Pour vérifier une page : ouvrir le lien raw suffixé ?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca ; le SHA affiché ci-dessous est la version attendue.
- develop: [view](https://github.com/cotton-games/documentation-public/blob/develop/SITEMAP.md) | [raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- main: [view](https://github.com/cotton-games/documentation-public/blob/main/SITEMAP.md) | [raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/SITEMAP.md) | sha 6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca

## Repos (repo-first)
- [canon/repos/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/INDEX.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/repos/games/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/games/README.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/repos/games/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/games/TASKS.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/repos/bingo.game/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/bingo.game/README.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/repos/bingo.game/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/bingo.game/TASKS.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/repos/bingo.game/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/bingo.game/INDEX.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/repos/blindtest/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/blindtest/README.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/repos/blindtest/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/blindtest/TASKS.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/repos/blindtest/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/blindtest/INDEX.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/repos/quiz/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/quiz/README.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/repos/quiz/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/quiz/TASKS.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/repos/quiz/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/quiz/INDEX.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)

## Global specs
- [canon/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/INDEX.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/interfaces/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/interfaces/INDEX.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/data/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/INDEX.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/runbooks/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/runbooks/INDEX.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [specs/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/specs/INDEX.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [specs/tests/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/specs/tests/INDEX.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)

## DB schema (global)
- [canon/data/schema/OVERVIEW.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/schema/OVERVIEW.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/data/schema/MAP.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/schema/MAP.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/data/schema/DDL.sql](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/schema/DDL.sql?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)

## Project status
- [README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/README.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [DOCS_MANIFEST.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/DOCS_MANIFEST.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [HANDOFF.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/HANDOFF.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [CHANGELOG.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/CHANGELOG.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [pm2-ws.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/pm2-ws.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)

## Notes & archive
- [notes/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/notes/INDEX.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [notes/archive/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/notes/archive/INDEX.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)

## Other
- [canon/front/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/front/INDEX.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)
- [canon/entrypoints.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/entrypoints.md?v=6d98b05fcc6d2f0b8ef320f8c5d8ecdc87a90aca)

