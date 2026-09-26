> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Runbook – Mirroring (private → public)

## Principe
- `cotton-games/documentation` (privé) est la **source of truth**.
- `cotton-games/documentation-public` (public) est un **miroir legacy / transition** publié automatiquement via GitHub Actions.
- Le miroir est publié en **snapshot** (branche orphan + 1 commit) : pas d’historique.

## Branches
- `develop` (privé) → `develop` (public)
- `main` (privé) → `main` (public)

## Secret (push vers le repo public)
- Le workflow utilise le secret GitHub `DOCS_PUBLIC_PUSH_TOKEN`.
- Le secret doit etre defini sur le repo source `cotton-games/documentation` (ou au niveau organisation avec acces a ce repo), car le workflow GitHub Actions s'execute depuis ce depot prive.
- Le token doit avoir les droits pour push sur `cotton-games/documentation-public` (branches `develop` et `main`).

## Sitemap
Le fichier `SITEMAP.md` (racine) est généré automatiquement avant le push public.

- Génération locale: `npm run docs:sitemap`
- Règles:
  - Scanne les `.md` publiés: racine + `canon/`, `specs/`, `notes/`.
  - Ignore: `.git`, `.github`, `node_modules`, `dist`, `build` + tout fichier/dossier commençant par `_`.
  - Les index Markdown utilisent l’API Contents privée. `SITEMAP.ndjson` expose `repository`, `path`, `branch`, `api_url` ; le champ `url` et `SITEMAP.txt` conservent les URLs publiques **legacy / transition**, pour compatibilité avec les consommateurs et contrôles existants.
  - Contrat de lecture privée : `START.md`, avec `COTTON_DOCS_TOKEN`, indépendant du secret de publication `DOCS_PUBLIC_PUSH_TOKEN` et du token AI Studio. Le workflow de publication reste inchangé.

## Ce qui est publié
- Tout le contenu du repo, **sauf** `.github/` (retiré avant le push public).
- Le workflow est dans `documentation/.github/workflows/publish-docs.yml` (privé uniquement).

Next: voir `notes/recommendations.md#15-audit-infos-sensibles--durcissement-git-a-faire`.
