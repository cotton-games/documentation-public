> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Runbook – Security (git hygiene / secrets)

> Minimal, contractual rules to prevent secret leakage, especially with **private → public mirroring**.

<!-- AUTO-UPDATE:BEGIN id="security-rules" owner="codex" -->

## Frontière d’autorisation Codex DEV — 26/09/2026

Le [contrat DEV contrôlé](dev.md#capacités-dev-contrôlées-de-codex--26092026) autorise uniquement les wrappers `deploy-dev.sh` / `fetch-dev.sh` et les recettes Playwright approuvées dans le scope demandé. Aucun SSH, PROD, suppression distante, infrastructure, accès DB direct automatisé, write DB automatisé ou contournement FTP/lftp brut. L’existence de credentials ou de binaires n’accorde pas de permission d’usage direct.

Les logs sous `/home/romain/.cotton-dev-artifacts/` et les états Playwright PRO/PLAY/BO sous `/home/romain/.cotton-playwright/` restent hors Git ; ne jamais publier les états ou credentials, y compris HTTP Basic et auth applicative BO. Aucun mécanisme DB read-only automatisé approuvé : SQL exact à fournir à l’opérateur, résultat manuel à attendre.

`games/web/config.php` peut être déployé par le wrapper si fonctionnellement nécessaire malgré son statut Git-ignored ; cette exception de déploiement ne lève pas l’interdiction de commit des configs runtime/secrets. Aucune autre exception implicite.

## Never commit (must be ignored)
- **Secrets**: `.env*`, `secrets*.env*`, `config.local.php`, runtime `config.php`, private keys/certs (`*.pem`, `*.key`, `*.p12`, `*.pfx`, etc.).
- **Runtime artefacts**: logs (`*.log`, `logs/`), caches (`cache/`, `tmp/`), PID files (`*.pid`), runtime caches (ex: QR caches).
- **Data exports / dumps**: `*.sql`, `*.sqlite`, `*.db`, `exports/`, `dumps/`, archives (`*.zip`, `*.tar.gz`, etc.).
- **Ops local scripts**: anything under `_ops_local/` or `_local/`.

## Reviewed migration source
- `migrations/hub_player_qr_dev.sql` est une source de migration demandée explicitement, sans données ni identifiants et sans nom de base codé en dur ; peut être versionnée après revue. Ce n’est pas un dump. Aucun export DEV/PROD, résultat de données, log ou fixture runtime ne doit l’accompagner dans le miroir public.

## Templates (must remain versioned)
- `.env.template`, `.env.example`, `.env.dist`
- `secrets.env.template` (and equivalents)
- `config.template.php`, `config.example.php`, `config.dist.php`

## Mirroring context (private → public)
- The public mirror is a snapshot; anything committed in the private repo can be published.
- If a secret was ever committed: treat it as compromised → rotate + (if needed) purge history before mirroring.
- Reference: `notes/recommendations.md#15-audit-infos-sensibles--durcissement-git-a-faire`

## Temporary BO auth links
- Any BO-generated direct-access link must stay internal-only, short-lived, and single-use.
- Do not expose these links in public/front UI, seeded demo content, screenshots, or mirrored documentation.
- If the implementation reuses an existing token column, consumption must clear the token immediately after a successful login.
## Intention de participation WWW/EP — 21/09/2026
- Les actions probable EP session et page Hub vérifient POST + identité de session + CSRF + activité/fenêtre canonique. Aucun appel d’admission Hub depuis ces actions.
- L’intention auth absente/invalide devient `probable` ; une intention `probable` ne bascule jamais en admission lors de l’ouverture de la fenêtre. `join` explicite reste le retour compte depuis Hub Play.
- `qr_place=1` reste une intention publique de navigation, pas une autorisation cryptographique ni une preuve de présence.
<!-- AUTO-UPDATE:END id="security-rules" -->
