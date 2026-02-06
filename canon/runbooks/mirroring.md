> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Runbook – Mirroring (private → public)

## Principe
- `cotton-games/documentation` (privé) est la **source of truth**.
- `cotton-games/documentation-public` (public) est un **miroir** publié automatiquement via GitHub Actions.
- Le miroir est publié en **snapshot** (branche orphan + 1 commit) : pas d’historique.

## Branches
- `develop` (privé) → `develop` (public)
- `main` (privé) → `main` (public)

## Secret (push vers le repo public)
- Le workflow utilise le secret GitHub `DOCS_PUBLIC_PUSH_TOKEN`.
- Le token doit avoir les droits pour push sur `cotton-games/documentation-public` (branches `develop` et `main`).

## Sitemap
Le fichier `SITEMAP.md` (racine) est généré automatiquement avant le push public.

- Génération locale: `npm run docs:sitemap`
- Règles:
  - Scanne les `.md` publiés: racine + `canon/`, `specs/`, `notes/`.
  - Ignore: `.git`, `.github`, `node_modules`, `dist`, `build` + tout fichier/dossier commençant par `_`.
  - Les URLs pointent vers `https://raw.githubusercontent.com/cotton-games/documentation-public/<branch>/<path>`.

## Ce qui est publié
- Tout le contenu du repo, **sauf** `.github/` (retiré avant le push public).
- Le workflow est dans `documentation/.github/workflows/publish-docs.yml` (privé uniquement).

Next: voir `notes/recommendations.md#15-audit-infos-sensibles--durcissement-git-a-faire`.
