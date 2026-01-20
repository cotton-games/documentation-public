# Changelog

> Keep it short: user-facing behavior + interfaces + migrations.

<!-- AUTO-UPDATE:BEGIN id="changelog-latest" owner="codex" -->
## Unreleased
- Bingo `reset` migrated to Canvas API; WS no longer performs DB writes for reset.
- Removed DB log persistence from WS (no more `saveGameNotification` writes); logs remain file/stdout.
- Front clients updated to handle Canvas bridge envelope responses (`data` unwrapping).
<!-- AUTO-UPDATE:END id="changelog-latest" -->
