# Cotton Documentation — SITEMAP

**Share (cache-busted):** <https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/SITEMAP.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036>

*If ChatGPT sees a “compacted” SITEMAP, always open the Share link above.*

<!-- Generated file — do not edit manually. Run npm run docs:sitemap -->

# Cotton Documentation — Start Here (Single Entrypoint)

**Start here**: lire le README général (https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/README.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036) avant d'ouvrir `canon/repos/*` (entrypoint obligatoire).
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
Pour vérifier une page : ouvrir le lien raw suffixé ?v=98b206a06d9bbff05592b2d0cd994f4641bd3036 ; le SHA affiché ci-dessous est la version attendue.
- develop: [view](https://github.com/cotton-games/documentation-public/blob/develop/SITEMAP.md) | [raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- main: [view](https://github.com/cotton-games/documentation-public/blob/main/SITEMAP.md) | [raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/SITEMAP.md) | sha 98b206a06d9bbff05592b2d0cd994f4641bd3036

## Repos (repo-first)
- [canon/repos/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/INDEX.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/repos/games/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/games/README.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/repos/games/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/games/TASKS.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/repos/bingo.game/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/bingo.game/README.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/repos/bingo.game/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/bingo.game/TASKS.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/repos/bingo.game/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/bingo.game/INDEX.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/repos/blindtest/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/blindtest/README.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/repos/blindtest/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/blindtest/TASKS.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/repos/blindtest/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/blindtest/INDEX.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/repos/quiz/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/quiz/README.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/repos/quiz/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/quiz/TASKS.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/repos/quiz/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/quiz/INDEX.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)

## Global specs
- [canon/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/INDEX.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/interfaces/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/interfaces/INDEX.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/data/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/INDEX.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/data/cotton-certified-direct-import.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/cotton-certified-direct-import.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/data/quiz-numeric-question-adaptation-csv.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/quiz-numeric-question-adaptation-csv.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/runbooks/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/runbooks/INDEX.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [specs/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/specs/INDEX.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [specs/tests/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/specs/tests/INDEX.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)

## DB schema (global)
- [canon/data/schema/OVERVIEW.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/schema/OVERVIEW.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/data/schema/MAP.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/schema/MAP.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/data/schema/DDL.sql](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/schema/DDL.sql?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)

## Project status
- [README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/README.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [DOCS_MANIFEST.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/DOCS_MANIFEST.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [HANDOFF.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/HANDOFF.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [CHANGELOG.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/CHANGELOG.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [pm2-ws.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/pm2-ws.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)

## Notes & archive
- [notes/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/notes/INDEX.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [notes/archive/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/notes/archive/INDEX.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)

## Other
- [canon/front/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/front/INDEX.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)
- [canon/entrypoints.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/entrypoints.md?v=98b206a06d9bbff05592b2d0cd994f4641bd3036)

