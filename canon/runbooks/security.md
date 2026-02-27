> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Runbook – Security (git hygiene / secrets)

> Minimal, contractual rules to prevent secret leakage, especially with **private → public mirroring**.

<!-- AUTO-UPDATE:BEGIN id="security-rules" owner="codex" -->
## Never commit (must be ignored)
- **Secrets**: `.env*`, `secrets*.env*`, `config.local.php`, runtime `config.php`, private keys/certs (`*.pem`, `*.key`, `*.p12`, `*.pfx`, etc.).
- **Runtime artefacts**: logs (`*.log`, `logs/`), caches (`cache/`, `tmp/`), PID files (`*.pid`), runtime caches (ex: QR caches).
- **Data exports / dumps**: `*.sql`, `*.sqlite`, `*.db`, `exports/`, `dumps/`, archives (`*.zip`, `*.tar.gz`, etc.).
- **Ops local scripts**: anything under `_ops_local/` or `_local/`.

## Templates (must remain versioned)
- `.env.template`, `.env.example`, `.env.dist`
- `secrets.env.template` (and equivalents)
- `config.template.php`, `config.example.php`, `config.dist.php`

## Mirroring context (private → public)
- The public mirror is a snapshot; anything committed in the private repo can be published.
- If a secret was ever committed: treat it as compromised → rotate + (if needed) purge history before mirroring.
- Reference: `notes/recommendations.md#15-audit-infos-sensibles--durcissement-git-a-faire`
<!-- AUTO-UPDATE:END id="security-rules" -->

