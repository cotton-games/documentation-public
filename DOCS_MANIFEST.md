# Docs Manifest (Codex maintenance rules)

<!-- NOTE TO CODEX:
1) Only edit inside AUTO-UPDATE blocks.
2) If code changes impact an interface / DB write / entrypoint, update the matching canon doc blocks.
3) Keep IDs stable. Do not rename files without updating README.md index block.
4) Prefer short diffs: update only relevant blocks.
-->

## Update triggers (mapping)
<!-- AUTO-UPDATE:BEGIN id="manifest-triggers" owner="codex" -->
## Snippet à coller dans tous les prompts Codex (Docs obligatoire)

0) Mettre à jour `canon/repos/<repo>/TASKS.md` (obligatoire, update-not-append).
0bis) Si changement fonctionnel : mettre à jour `canon/repos/<repo>/README.md`.
0ter) Après toute modification de documentation : exécuter `npm run docs:sitemap` pour régénérer `SITEMAP.md` (version publique).
0quater) L’entrée publique unique est `START.md` (raw complet) → `SITEMAP.md` (raw complet) → carte repo → manifest/doc ciblée.
1) Déterminer `changed files` via `git diff --name-only`.
2) Appliquer les “Routing rules” de ce fichier (`DOCS_MANIFEST.md`) et ouvrir uniquement les docs ciblés (pas de scan global).
3) Mettre à jour uniquement les blocs `AUTO-UPDATE` des docs ciblés (si pertinents).
4) Mettre à jour `HANDOFF.md` (toujours) : résumé + fichiers modifiés + docs touchées + TODO.
5) Si aucune règle ne match et que la zone est nouvelle → ajouter une règle au manifest (pas de scan global).

| Change in codebase | Match (paths/globs) | Update this documentation | Block IDs |
|---|---|---|---|
| Toute action (code ou doc) | *(règle transversale, sans glob)* | `canon/repos/<repo>/TASKS.md` (update-not-append) | n/a |
| Changement fonctionnel (flux/actions/contracts/env/log/DB writes) | *(règle transversale, sans glob)* | `canon/repos/<repo>/README.md` | n/a |
| Add/modify Canvas bridge payload/response or auth/idempotence behavior | `games/web/games_ajax.php`, `games/web/global_ajax.php`, `games/web/includes/canvas/php/**` | `canon/interfaces/canvas-bridge.md` | `bridge-contract`, `bridge-examples` |
| Add/modify an action / handler mapping (WS ↔ Canvas API ↔ PHP glue) | `games/web/includes/canvas/php/*_adapter_glue.php`, `games/web/includes/canvas/php/prizes_glue.php`, `bingo.game/ws/**`, `blindtest/web/server/**`, `quiz/web/server/**` | `canon/interfaces/actions.md` | `actions-list`, `actions-matrix` |
| New env var / port / endpoint / rewrite (PM2, WS, vhosts) | `**/.htaccess`, `**/pm2-*.ecosystem.config.cjs`, `**/version.txt`, `**/.env*`, `bingo.game/ws/**`, `blindtest/web/server/**`, `quiz/web/server/**` | `canon/entrypoints.md` + `canon/runbooks/dev.md` + `pm2-ws.md` | `entrypoints-table`, `dev-env` |
| Git hygiene / secrets / templates (private → public mirroring risk) | `**/.gitignore`, `**/config.php`, `**/config.local.php`, `**/global_config.php`, `**/global_config.local.php`, `**/*secrets*.env*`, `**/*.env*`, `**/*.pem`, `**/*.key`, `**/*.sql`, `**/*.log`, `**/_ops_local/**`, `**/_local/**` | `canon/runbooks/security.md` + `canon/runbooks/mirroring.md` + `HANDOFF.md` | `security-rules`, `handoff-status` |
| WS Bingo changes | `bingo.game/ws/**` | `canon/interfaces/actions.md` + `canon/interfaces/canvas-bridge.md` (+ `canon/data/bingo-write-map.md` si writes) | `actions-list`, `actions-matrix`, `bridge-contract`, `bridge-examples`, `write-map`, `write-sources` |
| User-facing change likely (UI/assets) | `games/web/**`, `www/web/**`, `pro/web/**`, `global/web/**` | `CHANGELOG.md` (+ `HANDOFF.md` si changement notable) | `changelog-latest`, `handoff-status` |

## Procédure anti-rescan (Codex)

But : mettre à jour la doc sans rescanner l’ensemble du dépôt.

1) Déterminer les fichiers modifiés : `changed = git diff --name-only <base>`
2) Appliquer les règles de routing ci-dessous (match par `paths/globs`) pour obtenir `targets.docs`
3) Ouvrir **uniquement** les documents listés dans `targets.docs` (pas de scan global)
4) Éditer **uniquement** les sections marquées `AUTO-UPDATE` dans ces documents
5) Si aucune règle ne match, **ajouter une règle** (paths/globs → docs), puis mettre à jour la doc correspondante
6) Log obligatoire : consigner dans `HANDOFF.md` (Actions réalisées + docs touchées + next steps)

---

## Routing rules (paths/globs → docs)

> Chaque règle est déterministe : un fichier modifié match un glob → ouvre les docs indiqués.

| ID | Match (paths/globs) | Docs à ouvrir (ordre) | Notes |
|---:|---|---|---|
| R1 | `**/games_ajax.php` `**/global_ajax.php` `**/*canvas*` | `canon/interfaces/canvas-bridge.md` | Contrat bridge Canvas / exemples |
| R2 | `**/ws/**` `**/*actions*` `**/*adapter*` `**/*glue*` | `canon/interfaces/actions.md` | Mapping actions/handlers |
| R3 | `**/.env*` `**/secrets*.env*` | `canon/entrypoints.md` `canon/runbooks/dev.md` | Variables d’env, setup local/dev |
| R4 | `**/pm2-*.ecosystem.config.*` `**/version.txt` | `pm2-ws.md` `canon/runbooks/prod.md` | Runbook PM2 / WS |
| R5 | `**/*.sql` `**/migrations/**` `**/*schema*` | `canon/data/bingo-write-map.md` | Writes DB / schémas / migrations |
| R6 | `**/bingo*/**` | `canon/data/bingo-write-map.md` `canon/interfaces/actions.md` | Bingo = actions + writes |
| R7 | `**/*service-token*` `**/*auth*` `**/*token*` `**/*header*` | `canon/runbooks/security.md` | Tokens, headers sensibles, logs safe |
| R8 | `**/.gitignore` `**/config.php` `**/config.local.php` `**/secrets*.env*` `**/*.pem` `**/*.key` `**/*.sql` `**/*.log` `**/_ops_local/**` | `canon/runbooks/security.md` | Hygiène git / fuites / artefacts |
| R9 | `www/**` `**/ui/**` `**/assets/**` `**/*.css` `**/*.html` | `CHANGELOG.md` | User-facing changes |
| R10 | `**/SITEMAP.md` `**/DOCS_MANIFEST.md` `**/README.md` | `HANDOFF.md` | Gouvernance + cohérence doc |

## Server restart markers

But : rendre les relances WS **déterministes** et ne pas oublier de bump le “marker de restart”.

| Service | Match (paths/globs) | Marker à bump |
|---|---|---|
| WS Bingo | `bingo.game/**` | `bingo.game/version.txt` |
| WS Blindtest | `blindtest/web/server/**` | `blindtest/web/server/restart_serveur.txt` |
| WS Quiz | `quiz/web/server/**` | `quiz/web/server/restart_serveur.txt` |

## Post-edit required actions (si un glob match)

Si `changed files` match une règle ci-dessus, alors **Codex doit aussi bump le marker correspondant** (même si la modif est “mineure”).

Format de bump (une ligne unique) :
- `restart DD-MM-YYYY/NN`
- `DD-MM-YYYY` = date du jour
- `NN` = compteur (2 chiffres recommandé, 2–3 acceptés), incrémenté si on bump plusieurs fois le même jour
- Si le fichier est vide / absent / hors format : le réinitialiser à `restart <date_du_jour>/01`

Règle générale : pour toute modification, `HANDOFF.md` doit être mis à jour (au minimum : résumé + docs touchées).

### AI agent usage rules (quick)
- Start from the single entrypoint: `https://github.com/cotton-games/documentation-public/raw/develop/SITEMAP.md` (`SITEMAP.md` in-repo).
- Trust hierarchy: `canon/` (source of truth) > `notes/` (non-canon context); use `HANDOFF.md` for current status and `CHANGELOG.md` for user-facing changes.
- Editing rule: only change canon content inside `AUTO-UPDATE` blocks; keep block IDs stable. Humans edit outside blocks.

### AI workflow rule (roles)
- Web AI agent (ex: ChatGPT web) = orchestrator only (plan + prompts + validation).
  - **Does not write code** and does not provide patches/diffs in chat.
  - **Chooses the strategy** and compiles the available information (canon + evidence) to implement it.
  - If **structural information is missing** (entrypoints, file locations, data flow, DB writes, WS/API contracts, env vars, side effects),
    the agent must request a **Codex audit** to retrieve verified details and avoid regressions.
  - Deliverable: **one or more clear, actionable prompts** for **Codex in VS Code** to apply the changes
    (scope, files to touch, acceptance checks, and any required doc updates).
- Codex (or IDE agent) = executor for all code/doc edits in the repo; apply update triggers to keep canon docs aligned.
- Consignation obligatoire: log every change in `HANDOFF.md` (“Actions réalisées”).

### No guessing / Evidence required
- Web agent orchestrates; do not infer missing facts.
- Any prod/deploy recommendation must cite proof (canon doc link, captured command output, or a Codex audit result).
- Accepted sources of truth: `canon/*`, output of commands run by the user/admin, and server config snapshots (env/PM2/reverse-proxy) pasted or captured.
<!-- AUTO-UPDATE:END id="manifest-triggers" -->

## Canon documentation (do not bloat)
- Canon documentation should be contractual, short, and link to code paths.
- Historical analysis goes to `notes/` (never canon).

## Snippet "documentation" à inclure dans tes prompts Codex
Colle ce bloc en fin de prompt pour forcer une mise à jour de doc cohérente.

> **Docs (obligatoire)**
> - Met à jour `canon/repos/<repo>/TASKS.md` (obligatoire, update-not-append).
> - Si changement fonctionnel : `canon/repos/<repo>/README.md`.
> - Mets à jour la documentation canon concernée **uniquement** dans les blocs `AUTO-UPDATE` (IDs stables).
> - Applique le mapping “Update triggers” ci-dessus :
>   - Interface Canvas (payload/response) → `canon/interfaces/canvas-bridge.md`
>   - Actions/handlers → `canon/interfaces/actions.md`
>   - Env vars / ports / endpoints → `canon/entrypoints.md` (+ `canon/runbooks/dev.md` si présent)
>   - DB writes / tables → `canon/data/bingo-write-map.md` (+ usage si besoin)
> - Si changement visible pour l’utilisateur : mets à jour `CHANGELOG.md` (bloc `changelog-latest`).
> - Si tu ajoutes une nouvelle surface (nouveau type de changement), complète le tableau “Update triggers”.
