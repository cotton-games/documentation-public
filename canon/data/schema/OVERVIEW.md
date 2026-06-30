<!-- Generated manually; keep concise, regen from DDL when schema changes. -->

# DB schema — Overview (dev_cotton_global_0)

## Périmètre
- Base transverse `dev_cotton_global_0`, export SQL “structure only” (aucune donnée).
- Source brute versionnée : `canon/data/schema/DDL.sql` (copie de `_sources/dev_cotton_global_0.sql`).
- Couvre les jeux (quiz/blindtest/bingo), CRM/ecommerce, référentiels, reporting, support.

## Security notes (public-safe)
- Publication = DDL uniquement (CREATE TABLE/INDEX/ENGINE), aucune donnée.
- Secrets/tokens ne doivent jamais être stockés en clair ; les colonnes contenant “token/password” restent structurelles.
- Aucune VIEW / TRIGGER / PROCEDURE / FUNCTION détectée dans le dump (grep DEFILER/VIEW/TRIGGER/PROCEDURE/FUNCTION → 0).
- En cas d’écart vs DB live, la DB fait foi : régénérer le dump et remplacer `DDL.sql`.
- Ne pas publier d’exports contenant DEFINER ou objets exécutables ; conserver “structure only”.
- Colonnes sensibles repérées (structure) : `pwd_token`, `pwd_token_date`, `token` (diverses tables) — vérifier que les valeurs sont hashées/chiffrées côté runtime.

## Conventions observées
- PK sur `id` (INT UNSIGNED AUTO_INCREMENT) quasi systématique.
- Timestamps fréquents : `created_at`, `updated_at` (DEFAULT current_timestamp).
- Multi-tenant implicite via `tenant_id`, `id_client`, `id_session`, `sid` selon domaines.
- FKs majoritairement **logiques** (peu de contraintes InnoDB explicites).

## Domaines principaux (exemples de tables)
- AI pilot : `ai_pilot_*` (agents, tenants, usages, logs).
- Jeux temps réel : `bingo_players`, `bingo_phase_winners`, `blindtest_players`, `blindtest_sessions`, `cotton_quiz_players`, `cotton_quiz_sessions`, `game_events`.
- Contenu bingo musical : `jeux_bingo_musical_*`, `referentiels_*` playlists/morceaux/styles.
- CRM / clients : `clients*`, `crm_*`, `entites_*`, `clients_contacts*`.
- Ecommerce/offres : `ecommerce_*`, `referentiels_*` prix/offres/paiements, `ecommerce_commandes*`.
- Questions/quiz : `questions*`, `quizs*`, `learning_quizs_questions`.
- Reporting : `reporting_games_*`, `reporting_shares`.
- Support / communication : `support_*`, `communication_*`.
- Archives : `x-archive-*` (bingo/equipes/joueurs/morceaux...).

## Règle de maintenance
- À chaque évolution de schéma DB : régénérer l’export structure-only → remplacer `_sources/dev_cotton_global_0.sql` et `DDL.sql`.
- Mettre à jour `MAP.md` si de nouvelles familles de tables apparaissent ou changent.
