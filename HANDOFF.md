# Handoff — Bingo winners canonical key migration

Date: 2026-02-12  
Scope: `games` Bingo Canvas API (`bingo_adapter_glue.php`) + migration SQL winners.

## Résumé
- Objectif: sécuriser `phase_winner` en key-first (`player_id` canonique) et préparer la sortie du legacy numérique pour les gagnants de phase.
- Correctifs appliqués:
  - `phase_winner_conflict` expose désormais `error='phase_winner_conflict'` (en plus de `reason`).
  - `bingo_api_phase_winner` résout l’identité via `_bingo_resolve_identity` (canonique), puis persiste l’ID DB legacy pour compat.
  - lecture winners key-first avec fallback legacy (`player_id_key` si présent, sinon jointure `bingo_players`).
  - écriture winners rétrocompatible: insert `player_id_key` quand la colonne existe.
  - fix SQL post-patch: clause ambiguë corrigée (`w.session_id`, `w.phase`) dans la requête de conflit.

## Migration DB
- Script ajouté: `../games/web/includes/canvas/sql/2026-02-12_bingo_phase_winners_player_id_key.sql`
- Actions:
  - ajoute `player_id_key VARCHAR(64) NULL` si absent,
  - backfill depuis `bingo_players`,
  - index `idx_bpw_session_phase_player_key`,
  - post-check des lignes sans clé canonique.

## Fichiers code impactés (hors repo documentation)
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
- `../games/web/includes/canvas/sql/2026-02-12_bingo_phase_winners_player_id_key.sql`

## Impact attendu
- Plus de conflit `phase_winner` masqué sans code explicite.
- Traçabilité winners alignée sur `player_id` canonique (avec compat legacy maintenue).
- Aucun changement WS requis pour ce lot.

## Docs mises à jour
- `CHANGELOG.md`
- `canon/repos/games/TASKS.md`
- `canon/repos/games/README.md`
- `HANDOFF.md`
