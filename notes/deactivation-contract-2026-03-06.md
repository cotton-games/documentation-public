# Deactivation contract (delegated offers) — 2026-03-06

## 1) Canonical DB model (schema + states)

Source schema:
- `ecommerce_offres_to_clients`:
  - `id_client` (owner/client porteur),
  - `id_client_delegation` (row delegated to another client),
  - `id_etat`,
  - `date_fin`,
  - `date_maj`,
  - `online`.
  - refs: `documentation/canon/data/schema/DDL.sql:1429`, `:1431`, `:1432`, `:1436`, `:1440`, `:1460`, `:1456`.

State meanings found in executable cron comments:
- `1 = NON PAYEE`
- `2 = EN ATTENTE`
- `3 = ACTIVE`
- `4 = TERMINEE`
- `10 = ANNULEE`
- ref: `www/web/bo/cron_routine_bdd_maj.php:16`.

## 2) How app decides active vs inactive

Primary runtime checks in `global` use `id_etat=3`:
- launch guard:
  - `app_session_launch_guard_get` calls `app_ecommerce_offres_client_get_count(..., "id_etat=3")`
  - and checks session offer detail `id_etat===3`.
  - refs: `global/web/app/modules/jeux/sessions/app_sessions_functions.php:863`, `:864`.
- resolver functions (`count/liste`) do not enforce date rules by themselves; they apply caller filters.
  - refs: `global/web/app/modules/ecommerce/app_ecommerce_functions.php:1011`, `:1037`.

Date note:
- date-based filtering exists in specific/legacy functions (example disabled block with `date_fin >= CURDATE()`), but not in the canonical active resolver path.
  - ref: `global/web/app/modules/ecommerce/app_ecommerce_functions.php:2330` (commented block).

## 3) Chosen deactivation contract

Contract to make a delegated offer row read as inactive by app:
1. Set `id_etat` from `3` to `4` (`TERMINEE`).
2. Set `date_maj = NOW()`.
3. Optionally set `date_fin = CURDATE()` if empty or future, for data coherence/reporting.

Why:
- runtime “active” is keyed to `id_etat=3` in live checks;
- cron deactivation paths also use transition to `id_etat=4` for expirations.
  - refs: `www/web/bo/cron_routine_bdd_maj.php:73`, `:100`, `:140`.

## 4) Safe SQL snippets (delegated rows for one seat `id_client`)

Assumption:
- “delegated rows for seat” means rows where `id_client = :seat_id` and `id_client_delegation > 0`.

Preview impacted rows:

```sql
SELECT id, id_client, id_client_delegation, id_etat, date_debut, date_fin, date_maj
FROM ecommerce_offres_to_clients
WHERE id_client = :seat_id
  AND id_client_delegation > 0
  AND id_etat = 3
ORDER BY id ASC;
```

Deactivate (strict, minimal mutation):

```sql
UPDATE ecommerce_offres_to_clients
SET id_etat = 4,
    date_maj = NOW()
WHERE id_client = :seat_id
  AND id_client_delegation > 0
  AND id_etat = 3;
```

Deactivate with date coherence:

```sql
UPDATE ecommerce_offres_to_clients
SET id_etat = 4,
    date_fin = CASE
      WHEN date_fin = '0000-00-00' OR date_fin > CURDATE() THEN CURDATE()
      ELSE date_fin
    END,
    date_maj = NOW()
WHERE id_client = :seat_id
  AND id_client_delegation > 0
  AND id_etat = 3;
```

Post-check:

```sql
SELECT COUNT(*) AS remaining_active_delegated
FROM ecommerce_offres_to_clients
WHERE id_client = :seat_id
  AND id_client_delegation > 0
  AND id_etat = 3;
```

## 5) Guardrails
- Keep filter `id_etat = 3` in UPDATE to avoid rewriting historical rows.
- Do not use `DELETE` for deactivation (breaks audit/history).
- Avoid `id_etat=10` unless cause is true cancellation/unpaid flow (cron semantics).
