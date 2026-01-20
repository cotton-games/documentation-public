# Docs – Cotton Quiz (IA handoff)

> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

## Parcours de lecture (Agent)
1) `docs/HANDOFF.md`
2) `docs/canon/architecture.md`
3) `docs/canon/entrypoints.md` + `docs/canon/tree.md`
4) `docs/canon/interfaces/canvas-bridge.md` + `docs/canon/interfaces/actions.md`
5) `docs/canon/data/*`
6) `docs/specs/*` (smoke/tests)

## Canon vs Notes
- **Canon** : source de vérité (courte, contractuelle, maintenue par Codex).
- **Notes** : historique / audits / explorations (utile, mais non contractuel).

## Bonnes pratiques de prompt pour Codex (VS Code)

### Objectif
Donner à Codex des instructions **actionnables** (quoi changer, où, comment valider), et lui demander **systématiquement** de mettre à jour la documentation canon associée.

### Règles simples
1) **Cadre** : décris le contexte (jeu, module, flux) et la contrainte (perf, compat, sécu, idempotence, etc.).
2) **Scope précis** : liste les fichiers/dossiers cibles *et* ceux à ne pas toucher.
3) **Définition de “Done”** : conditions vérifiables (commande à lancer, comportement attendu, logs, tests smoke).
4) **Diff minimal** : demande un patch court, sans refactor non demandé.
5) **Docs en même temps** : impose l’update docs (canon + changelog) en fin de tâche.

### Template de prompt (copier/coller)
> **Contexte**
> - Objectif : <ce que je veux obtenir>
> - Pourquoi : <raison / bug / contrainte>
>
> **Scope**
> - À modifier : <liste fichiers ou dossiers>
> - À ne pas modifier : <liste>
>
> **Exigences**
> - Compat : <prod/dev, versions, contraintes>
> - Sécurité : <tokens, event_id, droits>
> - Perf : <si applicable>
>
> **Critères de validation**
> - Cas 1 : <étapes + résultat attendu>
> - Cas 2 : <...>
>
> **Livrable**
> - Fais un patch (diff) + notes de test.
> - Puis **mets à jour la doc** :
>   - `docs/CHANGELOG.md` (bloc `changelog-latest`) si changement visible.
>   - Les canon docs concernées **uniquement dans les blocs `AUTO-UPDATE`** (IDs stables).
>   - Si une nouvelle surface existe (action, endpoint, env var, write DB), mets à jour le mapping dans `docs/DOCS_MANIFEST.md`.

### Exemples rapides
**Bugfix ciblé**
> Corrige le bug “<symptôme>” sur Bingo : le handler `<action>` ne met pas à jour `<champ>`.
> Scope : `ws/bingo/*`, `api/canvas/*`.
> Done : smoke `docs/specs/smoke-canvas-api.md` passe + logs WS montrent `<message>`.
> Docs : update `canon/interfaces/actions.md` + `canon/interfaces/canvas-bridge.md` (blocs) + changelog.

**Ajout d’une action**
> Ajoute l’action `bingo:case_lock` (payload `<...>`) avec idempotence via `event_id`.
> Mets à jour : handler WS + write map DB si nécessaire.
> Validation : curl d’exemple + vérif DB.
> Docs : `actions.md` (liste + matrix) + `canvas-bridge.md` (exemples) + `bingo-write-map.md` si write.

### Anti-patterns (à éviter)
- “Refactor général” sans limites de scope.
- Demander “mets à jour la doc” sans pointer **quelles** docs / blocs.
- Oublier les critères de validation (Codex “devine” et sur-modifie).

<!-- AUTO-UPDATE:BEGIN id="docs-index" owner="codex" -->
## Index (auto)
- Handoff: `docs/HANDOFF.md`
- Canon
  - Architecture: `docs/canon/architecture.md`
  - Repo map: `docs/canon/tree.md`
  - Entrypoints: `docs/canon/entrypoints.md`
  - Interfaces
    - Canvas bridge: `docs/canon/interfaces/canvas-bridge.md`
    - Actions: `docs/canon/interfaces/actions.md`
  - Data
    - Bingo DB usage: `docs/canon/data/bingo-db-usage.md`
    - Bingo write map: `docs/canon/data/bingo-write-map.md`
  - Runbooks
    - Dev: `docs/canon/runbooks/dev.md`
    - Prod: `docs/canon/runbooks/prod.md`
    - Troubleshooting: `docs/canon/runbooks/troubleshooting.md`
- Specs
  - Smoke: `docs/specs/smoke-canvas-api.md`
  - Tests: `docs/specs/tests/`
- Notes
  - Audit: `docs/notes/bingo-audit-summary.md`
  - Recommendations: `docs/notes/recommendations.md`
  - Archive: `docs/notes/archive/`
<!-- AUTO-UPDATE:END id="docs-index" -->
