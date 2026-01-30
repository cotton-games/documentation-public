<!-- Generated file — do not edit manually. Run npm run docs:sitemap -->

# Cotton Documentation — Start Here (Single Entrypoint)

This `SITEMAP.md` is the **single entrypoint** to the Cotton documentation.
- Web AI agents must orchestrate and delegate edits to Codex; do not propose code patches in chat.
- Verification-first: if unsure/missing info, don’t guess—organize verification (user or Codex audit).

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

## Sitemap
- [CHANGELOG.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/CHANGELOG.md)
- [DOCS_MANIFEST.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md)
- [HANDOFF.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md)
- [pm2-ws.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/pm2-ws.md)
- [README.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md)
- [canon/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/INDEX.md)
- [canon/data/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/INDEX.md)
- [canon/front/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/front/INDEX.md)
- [canon/interfaces/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/INDEX.md)
- [canon/runbooks/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/runbooks/INDEX.md)
- [canon/ws/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/ws/INDEX.md)
- [notes/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/notes/INDEX.md)
- [notes/archive/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/notes/archive/INDEX.md)
- [specs/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/specs/INDEX.md)
- [specs/tests/INDEX.md](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/specs/tests/INDEX.md)
