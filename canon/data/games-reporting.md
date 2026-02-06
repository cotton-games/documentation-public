> **Maintenance pact**: Codex may only edit inside `AUTO-UPDATE` blocks. Humans keep block IDs stable.

# Reporting jeux & joueurs (BO)

<!-- AUTO-UPDATE:BEGIN id="reporting-jeux" owner="codex" -->
## Tables (cron `cron_routine_bdd_maj.php`)
- `reporting_games_sessions_monthly` / `reporting_games_players_monthly` / `reporting_games_players_by_type_monthly` recalculées sur fenêtre glissante M-1/M (backfill complet si caches vides).
- **Nouveau** `reporting_games_sessions_detail` (figé par session) recalculé sur la même fenêtre : `month_key (YYYY-MM)`, `session_id` (championnats_sessions.id_securite), `session_date`, `id_client`, `id_type_produit`, `players_count`, `updated_at`. Index: unique `session_id`, + index mois/client/type/date. Données purgées avant insert pour la fenêtre courante.
- Filtres “session comptée” alignés sur les agrégats mensuels : pas de démos, config complète, client non archivé, session terminée (Bingo phase>=4, BlindTest game_status=3, Quiz game_status=3) et présence de joueurs.

## Règle joueurs (par session)
`players_count = équipes_joueurs + bingo_players + blindtest_players + cotton_quiz_players` (addition stricte, COALESCE 0). Agrégations players/month réutilisent les mêmes sources/filtres.

## Drilldown BO (“Jeux et joueurs”)
- Source: `reporting_games_sessions_detail` (mois cliquable + filtres jeu/client). Jeu → mapping id_type_produit: Quiz (1,5), Bingo (2,3,6), Blind Test (4).
- Colonnes modal: Date | Jeu | Client | SessionId | Joueurs | Logs.
- Lien logs: `games_url/<env>/games/web/logs_session.html?sessionId=<id>`, fallback interne `/games/web/logs_session.html?...` si `games_url` absent.
- Fraîcheur: reflète le dernier run du cron (champ `updated_at` des lignes insérées).
- Endpoint BO JSON: `?games_sessions_detail_ajax=1&month=YYYY-MM[&game=Quiz|Bingo|Blind Test][&client_id=...]` renvoie toujours un JSON `{ok:true, month, rows[], clients[]}` ou `{ok:false, error}` avec header `application/json; charset=utf-8` et `exit;` pour éviter tout HTML/warning dans la réponse.
- Router BO: l’endpoint est intercepté tôt dans `bo.php` (t=syntheses&m=facturation_pivot&p=saas&games_sessions_detail_ajax=1) avant tout layout, puis délègue à `bo_facturation_pivot_saas_handle_games_sessions_detail_ajax()`.
<!-- AUTO-UPDATE:END id="reporting-jeux" -->
