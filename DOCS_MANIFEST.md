# Docs Manifest (Codex maintenance rules)

<!-- NOTE TO CODEX:
1) Only edit inside AUTO-UPDATE blocks.
2) If code changes impact an interface / DB write / entrypoint, update the matching canon doc blocks.
3) Keep IDs stable. Do not rename files without updating docs/README.md index block.
4) Prefer short diffs: update only relevant blocks.
-->

## Update triggers (mapping)
<!-- AUTO-UPDATE:BEGIN id="manifest-triggers" owner="codex" -->
| Change in codebase | Update these docs | Block IDs |
|---|---|---|
| Add/modify canvas API payload/response | `canon/interfaces/canvas-bridge.md` | `bridge-contract`, `bridge-examples` |
| Add/modify an action / handler mapping | `canon/interfaces/actions.md` | `actions-list`, `actions-matrix` |
| New env var / port / endpoint | `canon/entrypoints.md` + `canon/runbooks/dev.md` | `entrypoints-table`, `dev-env` |
| New DB table / new write path | `canon/data/bingo-write-map.md` (+ usage if needed) | `write-map`, `write-sources` |
| Any behavior change visible to users | `CHANGELOG.md` | `changelog-latest` |
| Major milestone / switch of direction | `HANDOFF.md` | `handoff-status`, `handoff-next-steps` |
<!-- AUTO-UPDATE:END id="manifest-triggers" -->

## Canon docs (do not bloat)
- Canon docs should be contractual, short, and link to code paths.
- Historical analysis goes to `docs/notes/` (never canon).

## Snippet "docs" à inclure dans tes prompts Codex
Colle ce bloc en fin de prompt pour forcer une mise à jour de doc cohérente.

> **Docs (obligatoire)**
> - Mets à jour les canon docs concernées **uniquement** dans les blocs `AUTO-UPDATE` (IDs stables).
> - Applique le mapping “Update triggers” ci-dessus :
>   - Interface Canvas (payload/response) → `canon/interfaces/canvas-bridge.md`
>   - Actions/handlers → `canon/interfaces/actions.md`
>   - Env vars / ports / endpoints → `canon/entrypoints.md` (+ `canon/runbooks/dev.md` si présent)
>   - DB writes / tables → `canon/data/bingo-write-map.md` (+ usage si besoin)
> - Si changement visible pour l’utilisateur : mets à jour `docs/CHANGELOG.md` (bloc `changelog-latest`).
> - Si tu ajoutes une nouvelle surface (nouveau type de changement), complète le tableau “Update triggers”.
