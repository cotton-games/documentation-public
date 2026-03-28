# Cotton Documentation — SITEMAP

**Share (cache-busted):** <https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b>

*If ChatGPT sees a “compacted” SITEMAP, always open the Share link above.*

<!-- Generated file — do not edit manually. Run npm run docs:sitemap -->

# Cotton Documentation — Start Here (Single Entrypoint)

**Start here**: lire le README général (https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b) avant d'ouvrir `canon/repos/*` (entrypoint obligatoire).
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
Pour vérifier une page : ouvrir le lien raw suffixé ?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b ; le SHA affiché ci-dessous est la version attendue.
- develop: [view](https://github.com/cotton-games/documentation-public/blob/develop/SITEMAP.md) | [raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b) | sha 413ab2d2e5df5b47b593200e53c3b5320ce50a2b
- main: [view](https://github.com/cotton-games/documentation-public/blob/main/SITEMAP.md) | [raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/SITEMAP.md)

## Repos (repo-first)
- [canon/repos/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/INDEX.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/repos/games/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/repos/games/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/TASKS.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/repos/bingo.game/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/bingo.game/README.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/repos/bingo.game/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/bingo.game/TASKS.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/repos/bingo.game/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/bingo.game/INDEX.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/repos/blindtest/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/blindtest/README.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/repos/blindtest/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/blindtest/TASKS.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/repos/blindtest/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/blindtest/INDEX.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/repos/quiz/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/quiz/README.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/repos/quiz/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/quiz/TASKS.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/repos/quiz/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/quiz/INDEX.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)

## Global specs
- [canon/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/INDEX.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/interfaces/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/INDEX.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/data/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/INDEX.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/runbooks/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/runbooks/INDEX.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [specs/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/specs/INDEX.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [specs/tests/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/specs/tests/INDEX.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)

## DB schema (global)
- [canon/data/schema/OVERVIEW.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/schema/OVERVIEW.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/data/schema/MAP.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/schema/MAP.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/data/schema/DDL.sql](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/schema/DDL.sql?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)

## Project status
- [README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [DOCS_MANIFEST.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [HANDOFF.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [CHANGELOG.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/CHANGELOG.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [pm2-ws.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/pm2-ws.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)

## Notes & archive
- [notes/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/notes/INDEX.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [notes/archive/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/notes/archive/INDEX.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)

## Other
- [canon/front/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/front/INDEX.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)
- [canon/entrypoints.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/entrypoints.md?v=413ab2d2e5df5b47b593200e53c3b5320ce50a2b)

