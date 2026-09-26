<!-- Generated manually; keep concise, regen from DDL when schema changes. -->

# DB schema — Overview (dev_cotton_global_0)

## Périmètre
- Base transverse `dev_cotton_global_0`, export SQL “structure only” (aucune donnée).
- Source brute versionnée : `canon/data/schema/DDL.sql` (copie de `_sources/dev_cotton_global_0.sql`).
- Couvre les jeux (quiz/blindtest/bingo), CRM/ecommerce, référentiels, reporting, support.

## Migration QR Hub appliquée en DEV par l’utilisateur
- [Migration manuelle DEV](../../runbooks/hub-player-qr-migration.md) : quatre colonnes dédiées, fichier SQL séparé et rejouable pour MariaDB 10.3.39/MyISAM. Le snapshot games_hubs est plus ancien que les relevés DEV du 07/09 ; il complète leur audit, sans certifier tout le schéma live. Résultat phpMyAdmin reçu : quatre colonnes CONFORME et OK_SCHEMA_QR. DDL.sql reste un snapshot ancien, inchangé en l’absence d’un nouvel export complet ; les définitions ajoutées sont dans le fichier de migration et le runbook. PROD sera traité dans une migration globale distincte.

- B applicatif local utilise ces colonnes via `global/web/app/modules/jeux/hubs/app_games_hub_player_qr_functions.php` : cible, révision, JSON exact révision/instance/mode (256 octets maximum) et première date officielle. Lecture de définition sans ALTER ; absent/partiel/illisible = repli QR réduit, sans bloquer le Hub. Migration non rejouée pendant B ; [contrat](../../interfaces/canvas-bridge.md#pilotage-du-qr-joueurs-hub--b-local).

- Choix QR manuel : défaut reduced à l’initialisation ; un ancien expanded sans reçu de commande explicite à la révision courante reste projeté reduced. La trace officielle reste conservée mais ne déclenche aucun accueil. Schéma inchangé, aucune nouvelle migration.

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
- Jeux temps réel : `bingo_players`, `bingo_phase_winners`, `blindtest_players`, `blindtest_session_teams`, `blindtest_sessions`, `cotton_quiz_players`, `cotton_quiz_sessions`, `game_events`.
- Hubs : `games_hubs`, `games_hubs_sessions`, `games_hubs_players`, `games_hubs_players_sessions`, `games_hubs_participations_probables`, `games_hubs_publication`, `games_hubs_prizes`.
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

## Patch en attente d'import DEV — 2026-09-03
- `ecommerce_offres_to_clients.stripe_current_period_start/end` stockent les bornes courantes renvoyées par Stripe sans changer la sémantique de `date_debut/date_fin`.
- Le DDL canonique contient les colonnes; l'import idempotent phpMyAdmin est fourni dans `ecommerce_offres_to_clients_stripe_current_period_phpmyadmin.sql`.
- Aucun index n'est ajouté: ces colonnes sont lues avec la ligne d'offre, jamais utilisées comme clé de recherche ou de jointure dans ce patch.
- La connexion disponible depuis le worktree n'étant pas autorisée, le schéma live DEV n'est pas encore attesté et doit être migré avant recette.
