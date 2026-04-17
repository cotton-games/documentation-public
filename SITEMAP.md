# Cotton Documentation — SITEMAP

**Share (cache-busted):** <https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/SITEMAP.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa>

*If ChatGPT sees a “compacted” SITEMAP, always open the Share link above.*

<!-- Generated file — do not edit manually. Run npm run docs:sitemap -->

# Cotton Documentation — Start Here (Single Entrypoint)

**Start here**: lire le README général (https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/README.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa) avant d'ouvrir `canon/repos/*` (entrypoint obligatoire).
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
Pour vérifier une page : ouvrir le lien raw suffixé ?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa ; le SHA affiché ci-dessous est la version attendue.
- develop: [view](https://github.com/cotton-games/documentation-public/blob/develop/SITEMAP.md) | [raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- main: [view](https://github.com/cotton-games/documentation-public/blob/main/SITEMAP.md) | [raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/SITEMAP.md) | sha c6425251e5777a104a0b4b714445ab6aa1eaf2fa

## Repos (repo-first)
- [canon/repos/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/INDEX.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/repos/games/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/games/README.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/repos/games/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/games/TASKS.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/repos/bingo.game/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/bingo.game/README.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/repos/bingo.game/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/bingo.game/TASKS.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/repos/bingo.game/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/bingo.game/INDEX.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/repos/blindtest/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/blindtest/README.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/repos/blindtest/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/blindtest/TASKS.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/repos/blindtest/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/blindtest/INDEX.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/repos/quiz/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/quiz/README.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/repos/quiz/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/quiz/TASKS.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/repos/quiz/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/quiz/INDEX.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)

## Global specs
- [canon/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/INDEX.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/interfaces/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/interfaces/INDEX.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/data/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/INDEX.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/runbooks/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/runbooks/INDEX.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [specs/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/specs/INDEX.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [specs/tests/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/specs/tests/INDEX.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)

## DB schema (global)
- [canon/data/schema/OVERVIEW.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/schema/OVERVIEW.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/data/schema/MAP.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/schema/MAP.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/data/schema/DDL.sql](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/schema/DDL.sql?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)

## Project status
- [README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/README.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [DOCS_MANIFEST.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/DOCS_MANIFEST.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [HANDOFF.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/HANDOFF.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [CHANGELOG.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/CHANGELOG.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [pm2-ws.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/pm2-ws.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)

## Notes & archive
- [notes/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/notes/INDEX.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [notes/archive/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/notes/archive/INDEX.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)

## Other
- [canon/front/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/front/INDEX.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)
- [canon/entrypoints.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/entrypoints.md?v=c6425251e5777a104a0b4b714445ab6aa1eaf2fa)

