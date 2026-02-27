# Cotton Documentation — SITEMAP

**Share (cache-busted):** <https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7>

*If ChatGPT sees a “compacted” SITEMAP, always open the Share link above.*

<!-- Generated file — do not edit manually. Run npm run docs:sitemap -->

# Cotton Documentation — Start Here (Single Entrypoint)

**Start here**: lire le README général (https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7) avant d'ouvrir `canon/repos/*` (entrypoint obligatoire).
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
Pour vérifier une page : ouvrir le lien raw suffixé ?v=e3e9898b64bdc5c36076357aaa597d74317c69b7 ; le SHA affiché ci-dessous est la version attendue.
- develop: [view](https://github.com/cotton-games/documentation-public/blob/develop/SITEMAP.md) | [raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7) | sha e3e9898b64bdc5c36076357aaa597d74317c69b7
- main: [view](https://github.com/cotton-games/documentation-public/blob/main/SITEMAP.md) | [raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/SITEMAP.md)

## Repos (repo-first)
- [canon/repos/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/INDEX.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/repos/games/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/repos/games/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/TASKS.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/repos/bingo.game/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/bingo.game/README.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/repos/bingo.game/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/bingo.game/TASKS.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/repos/bingo.game/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/bingo.game/INDEX.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/repos/blindtest/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/blindtest/README.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/repos/blindtest/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/blindtest/TASKS.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/repos/blindtest/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/blindtest/INDEX.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/repos/quiz/README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/quiz/README.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/repos/quiz/TASKS.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/quiz/TASKS.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/repos/quiz/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/quiz/INDEX.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)

## Global specs
- [canon/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/INDEX.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/interfaces/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/INDEX.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/data/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/INDEX.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/runbooks/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/runbooks/INDEX.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [specs/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/specs/INDEX.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [specs/tests/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/specs/tests/INDEX.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)

## DB schema (global)
- [canon/data/schema/OVERVIEW.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/schema/OVERVIEW.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/data/schema/MAP.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/schema/MAP.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/data/schema/DDL.sql](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/schema/DDL.sql?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)

## Project status
- [README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [DOCS_MANIFEST.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [HANDOFF.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [CHANGELOG.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/CHANGELOG.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [pm2-ws.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/pm2-ws.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)

## Notes & archive
- [notes/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/notes/INDEX.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [notes/archive/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/notes/archive/INDEX.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)

## Other
- [canon/front/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/front/INDEX.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)
- [canon/entrypoints.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/entrypoints.md?v=e3e9898b64bdc5c36076357aaa597d74317c69b7)

