# DB schema — MAP (dev_cotton_global_0)

Guidage navigation par domaines. FKs listées = **logiques (non contraintes)** sauf mention explicite.

## AI pilot
- Tables : `ai_pilot_agents`, `ai_pilot_api_usage`, `ai_pilot_client_preferences`, `ai_pilot_generated_contents`, `ai_pilot_ia_services`, `ai_pilot_media_assets`, `ai_pilot_platforms`, `ai_pilot_scheduled_tasks`, `ai_pilot_system_logs`, `ai_pilot_tenants`, `ai_pilot_tenant_agents`, `ai_pilot_tenant_agent_configs`.
- FKs logiques : `ai_pilot_api_usage.tenant_id → ai_pilot_tenants.id`; `ai_pilot_tenant_agents.agent_id → ai_pilot_agents.id`; `ai_pilot_tenant_agent_configs.tenant_agent_id → ai_pilot_tenant_agents.id`.

## Jeux temps réel (sessions/joueurs)
- Tables : `bingo_players`, `bingo_phase_winners`, `blindtest_players`, `blindtest_sessions`, `cotton_quiz_players`, `cotton_quiz_sessions`, `game_events`.
- FKs logiques : `*_players.id_session → *_sessions.id`; `bingo_phase_winners.session_id → championnats_sessions.id_securite` (token), unique `(session_id, phase)` + `event_id`; `game_events.event_id` unique, lié aux writes Canvas.
- Notes : `bingo_players` dénormalise les gains (`phase_wins_count`, `last_won_phase`, `last_won_at`) pour lecture rapide.

## Bingo musical (contenu)
- Tables : `jeux_bingo_musical_artistes`, `jeux_bingo_musical_grids`, `jeux_bingo_musical_grids_clients`, `jeux_bingo_musical_morceaux`, `jeux_bingo_musical_morceaux_to_playlists`, `jeux_bingo_musical_morceaux_to_playlists_clients`, `jeux_bingo_musical_playlists`, `jeux_bingo_musical_playlists_clients`, `jeux_bingo_musical_playlists_clients_logs`, `jeux_bingo_musical_playlists_rubriques`.
- FKs logiques : `*_grids_clients.grid_id → jeux_bingo_musical_grids.id`; `*_morceaux_to_playlists.playlist_id → jeux_bingo_musical_playlists.id`; `*_playlists_clients.playlist_id → jeux_bingo_musical_playlists.id`.

## Référentiels jeux / contenu
- Tables : `referentiels_morceaux_styles`, `referentiels_morceaux_popularites`, `referentiels_playlists_difficultes`, `referentiels_sessions_evenements`, `referentiels_questions_feedback_reload_types`, `referentiels_equipes_joueurs_types`, `referentiels_logs_types`, `referentiels_branding_types`, `referentiels_bingo_musical_playlists_clients_logs_types`.
- FKs logiques : typiquement `<entity>_type_id → referentiels_*_types.id`.

## Questions / quiz / learning
- Tables : `questions`, `questions_bonus`, `questions_propositions`, `questions_tags`, `questions_to_tags`, `questions_rubriques`, `questions_univers`, `questions_feedback`, `questions_lots*`, `quizs`, `quizs_series`, `quizs_series_to_questions`, `learning_quizs_questions`.
- FKs logiques : `questions_to_tags.question_id → questions.id`; `quizs_series_to_questions.question_id → questions.id`; `quizs_series.quiz_id → quizs.id`.

## Clients / CRM / entités
- Tables : `clients`, `clients_branding`, `clients_contacts`, `clients_contacts_to_clients`, `clients_emails_transactionnels_logs`, `clients_logs`, `clients_logs_onboarding`, `clients_logs_utm`, `clients_temoignages`, `crm_abonnes`, `crm_contacts`, `crm_parrainages`, `entites_utilisateurs`, `entites_utilisateurs_logs`, `entites_joueurs_emails_transactionnels_logs`, `entites_joueurs_logs`, `clients_contacts_to_clients`.
- FKs logiques : `clients_contacts_to_clients.contact_id → clients_contacts.id`; `clients_branding.client_id → clients.id`; `entites_utilisateurs.tenant_id → clients.id` (à confirmer).

## Ecommerce / offres / paiements
- Tables : `ecommerce_commandes`, `ecommerce_commandes_lignes`, `ecommerce_formules*`, `ecommerce_offres*`, `ecommerce_produits_types`, `ecommerce_remises*`, `ecommerce_remises_to_offres*`, `ecommerce_offres_paniers`, `ecommerce_offres_to_clients`.
- FKs logiques : `ecommerce_commandes_lignes.commande_id → ecommerce_commandes.id`; `ecommerce_formules_declinaisons.formule_id → ecommerce_formules.id`; `ecommerce_offres_to_clients.client_id → clients.id`; `ecommerce_remises_to_offres.offre_id → ecommerce_offres.id`.

## Equipes / championnats
- Tables : `equipes`, `equipes_joueurs`, `equipes_joueurs_to_equipes`, `equipes_logs`, `equipes_to_championnats_sessions`, `championnats_sessions`, `championnats_saisons`, `championnats_resultats`, `championnats_contributions_points`, `championnats_sessions_lots*`, `equipes_championnats_sessions_reponses`.
- FKs logiques : `equipes_to_championnats_sessions.championnat_session_id → championnats_sessions.id`; `equipes_joueurs_to_equipes.equipe_id → equipes.id`.

## Reporting
- Tables : `reporting_games_*`, `reporting_shares`.
- FKs logiques : `reporting_games_*` indexées par `session_id`, `game`, `month/year` (agrégats).

## Support / communication
- Tables : `support_*`, `communication_*`.
- FKs logiques : `support_contacts.client_id → clients.id` (à confirmer), `communication_*` liés aux rubriques/clients via ids.

## Archives
- Tables : `x-archive-*` (bingos, équipes, joueurs, morceaux, résultats).
- FKs logiques : conservent anciens ids de production ; utiliser avec prudence.
