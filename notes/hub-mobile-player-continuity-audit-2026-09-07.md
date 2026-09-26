# Audit fonctionnel — continuité joueurs Hub depuis Pro mobile — 2026-09-07

> Cadrage utilisateur du 07/09 : évolution mobile reportée et non exécutée. La réinscription historique entre sessions est acceptée ; absence d'auto-connexion non considérée comme incident. Le défaut de résultats Play fait l'objet de [l'audit ciblé Hub 291](hub-historical-player-end-audit-2026-09-07.md). Les constats techniques ci-dessous restent une analyse d'écart de parcours, pas une autorisation de correctif.

## Conclusion et limites

**Défaut de raccordement établi dans le code local, incident serveur non encore reproduit.** Le CTA officiel mobile ouvre le Master individuel historique. Celui-ci lit l'appartenance Hub, mais le clic de lancement ne traverse pas `app_games_hub_session_launch_from_master`. Il manque donc l'injection papier et l'engagement du focus nécessaires au parcours automatique numérique. La présence dans le compteur Hub ne prouve ni une participation à la prochaine session ni une connexion WebSocket actuelle.

Aucun patch fonctionnel, commit, déploiement, SSH, DB, DEV/PROD ou navigateur utilisé. Les conclusions portent sur le workspace du 07/09, avec modifications préexistantes conservées. Les tests cités sont des contrats locaux, pas une recette serveur.

## Sources rechargées et fraîcheur

Navigation suivie : [START main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), sections « Statut actuel », « Parcours », « Règle preuve d’abord », « Discipline de génération » → [SITEMAP develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), rubriques Repos/Global specs/DB schema/Project status → index Pro/Games/Global → README/TASKS correspondants. README général, HANDOFF, manifeste et schéma également rechargés. [Manifest](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers » et « Canon documentation » : consignation dans note + Handoff + TASKS, génération des index.

Index consultés : [Pro](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/INDEX.md), [Games](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/INDEX.md), [Global](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/INDEX.md), section « Pages ».

Journal [AI Studio fourni](https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb) consulté avant lecture applicative : HTTP 200 via curl après échec de l'outil web ; le serveur renvoie une enveloppe HTML, dont la variable JSON `const raw` a été décodée pour lire le Markdown intégral. Dernière mise à jour annoncée : 28/08/2026. Sections « EN COURS », « TODO », « Fait, livré en PROD » : modifications marketing, AI Studio, ecommerce, authentification ; **aucun fichier de lancement/roster Hub ciblé signalé**. Le Hub AI Studio cité dans ce journal n'est pas le Hub de jeu. Aucun rapatriement impératif identifié par ce journal ; égalité serveur/workspace : **non trouvée**.

Comparaison des mêmes chemins main/develop : **écart documentaire develop > main** sur les trois README (et TASKS). Les sections suivantes sont présentes dans develop et absentes de main ; cela ne certifie pas les fichiers actuellement déployés :

| Documentation RAW develop + section utilisée | Même chemin main comparé |
|---|---|
| [README Pro](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/README.md), « Update 2026-09-01 - Dashboard mobile: lecture Programme et démo active », « Update 2026-08-28/30 - Dashboard Pro canonique » | [README Pro main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/pro/README.md) |
| [README Games](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Update 2026-08-31 - Injection Hub papier: conteneur historique minimal à froid », « Update 2026-07-15 — Hub: continuité des joueurs ajoutés depuis la Remote papier » | [README Games main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/games/README.md) |
| [README Global](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Update 2026-08-31 - Launch Hub papier: bootstrap avant engagement du focus », « Update 2026-08-26 - Hub players: membership papier `active|left` », « Etat 2026-07-15 - Continuité des identités Remote papier dans le Hub », « Etat 2026-07-11 - Games hubs ensure participation runtime » et rectification du 13/07 | [README Global main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/global/README.md) |

Le complément du 07/09 de la section Global « transitions roster pour undo sas papier » documente aussi la nouvelle règle publique de réinscription invitée, explicitement locale/non déployée. Ne pas généraliser cette règle à PROD.

## Preuves code et comparaison ordonnée

Chemins ci-dessous relatifs à `/home/romain/Cotton/`. Les plages se rapportent au code lu le 07/09, avant tout correctif fonctionnel. Abréviation **H** = `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

| Étape | Pro mobile → Master individuel | Hub Master / Remote → orchestration |
|---|---|---|
| Route produite | `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`, `ec_start_day_session_individual_access_get`, 1930–2035 : `app_session_get_link(..., flag_direct_launcher=1)`. `global/web/app/modules/jeux/sessions/app_sessions_functions.php`, `app_session_get_link`, 3935 et 4099/4116/4133 : `/master/{id_securite}` pour types 4/5/6. Vue Dashboard, bloc construction 329–350 puis lien 1001 : ajout `return_url`, pas `hub_launch`. | `.htaccess` Games, règles 2–7 : `/hub/{token}/master` → `games_ajax.php?...m=hub_master`, `/master/{token}` → `global_ajax.php?...m=orga`. Pro `ec_start_sessions_day.php`, bloc 213–220 construit l'URL Hub. Remote crée une commande, ne lance pas directement. |
| Seuil responsive | `ec_start_sessions_day_dashboard_v2_style.php`, règles 51–53 puis media 602 et 682–710 : CTA individuel masqué par défaut, `inline-flex` jusqu'à 991,98 px ; bandeau d'actions Hub masqué dans ce media. Vue 1001 : vrai href, pas une redirection JS dépendante de largeur. | Bandeau Hub visible desktop ; Remote route séparée. Aucune preuve que le mobile passe implicitement par ce service. |
| Guards d'accès | Helper Pro 1930–2035 : identifiants/type valides, terminal → Résultats, compte inactif → duplication démo, compte actif → chronologie `during` ET fenêtre Hub ouverte, contenu présent, type 4/5/6, `app_session_launch_guard_get`. `games/web/organizer_canvas.php`, bloc guard 430 et suivants ; `games_ajax.php`, bloc 281 et suivants pour mutations protégées. | `games/web/modules/app_hub_view_helpers.php`, handler `launch_session` 2825–2865 ; Remote `app_hub_remote_ajax.php`, handler 1069–1084 crée `launch_session` après gates de contrôle/présence Master. Master claim/dispatch 3409 et `games_hub_handle_master_remote_launch_command`, appel 3607 avec clé `remote-command-{id}`. |
| Résolution Hub | `games/web/modules/app_orga_ajax.php`, bloc 141–160 : `app_games_hub_get_for_session`, puis resolver contexte démo si absent. H `app_games_hub_get_for_session`, 4824–4912 : membership active persistée ; une relation unique suffit, ambiguïté → vide ; pas d'élection par date/client. Lire le Hub ne l'active pas. | H `app_games_hub_session_launch_from_master`, 9916–10078 : Hub actif, appartenance via `app_games_hub_session_belongs_to_hub`, refus terminal, décision temporelle/commerciale, réutilisabilité de l'exécution, guard métier pour nouveau runtime officiel. |
| Avant participants | `organizer_canvas.php`, 100–129 : contexte Hub activé seulement avec exécution ; lecture éventuelle de l'exécution si focus correspond. 190–199 : preload. `boot_organizer.js`, 1141–1291 : hydratation joueurs/session puis `session/init`. Aucun appel au service de lancement Hub ni à l'injection dans ces blocs. | H 10063–10153 : pour papier officiel neuf/recréé, `app_games_hub_paper_historical_session_ensure` AVANT focus ; arrêt si échec. Puis focus écrit/confirmé, contexte d'exécution créé/réutilisé, publication génération de routage. Runtime officiel existant → retour 10155–10176, sans injection. |
| Sélection/injection | Absence d'injection collective Hub dans ce chemin. Les inscriptions historiques individuelles restent possibles : adaptateurs `player_register` puis bridge Hub (voir ci-dessous). | H 10178–10202 : papier officiel → `app_games_hub_session_inject_active_players`; numérique → skip `digital_presence_runtime`; démo → skip `demo_runtime_without_hub_players`. Injection 9550–9607 : `id_hub` + `status='active'`, chaque joueur → resolver `join_source=launch`. |
| Participation et mapping | Le bridge remonte les inscriptions réellement faites vers le Hub, mais ne fait pas l'opération inverse à la session suivante. H `app_games_hub_session_register_bridge`, 8517–8688 ; appel après registration : `quiz_adapter_glue.php` 1668, `blindtest_adapter_glue.php` 1693, `bingo_adapter_glue.php` 1703. Cela explique qu'un joueur ajouté historiquement puisse grossir le compteur Hub sans être repris ensuite. | H `app_hub_player_resolve_session_access` 9066–9307 → `app_games_hub_session_participation_ensure` 8737–9050 : verrou Hub/session/joueur, mapping relu, preload numérique seulement, `game_api_dispatch(player_register)`, vérification ID et clé retournés, mapping `active` ensuite. |
| Lancement effectif | `games/web/includes/canvas/core/boot_organizer.js`, `beginPlayFlow` 1634–1748 : guards officiel/prelaunch/fenêtre, intro, `Game.handleUI({type:'play'})` 1707 ; binding `ui/play` 1769–1772. `core/player/index.js`, `handleUI` 1722–1780 : première lecture, état « En cours », `emitRoundStarted`. Pas de commit focus Hub ici. | H 10204–10230 retourne `/master/{token}?hub_launch=1&hub_execution=...` après injection. `organizer_canvas.php` 127–129 exige contexte d'exécution ; `boot_organizer.js` 1775–1805 attend runtime prêt puis `beginPlayFlow({source:'hub'})`. Même moteur historique en aval. |

## Contrat exact : identité, papier, numérique

- **Identité Hub** : H `app_games_hub_schema_ensure`, 292–320 : état `active|left`, unicité `(id_hub, auth_identity_key)`. `app_games_hub_players_count_active`, 5812–5825 compte exactement les actifs. `app_games_hub_player_touch`, 5799–5810 ne change que les dates. Ni TTL ni test de socket dans le compteur ou la sélection papier.
- **Fin naturelle** : `games/web/includes/canvas/php/boot_lib.php`, `canvas_api_hub_session_natural_ended`, 328–468 : exige contexte/terminal, clear conditionnel du focus, fermeture d'exécution ; aucune désactivation de l'identité Hub dans ce handler. H resolver 9153–9175 et programme 9419–9429 marquent le mapping `completed` lorsque la terminaison est constatée. Ce n'est pas nécessairement une mise à jour immédiate de tous les mappings à la seconde de fin. Un mapping S1 `completed` ne retire pas l'identité des actifs et n'interdit pas S2.
- **Départ Hub** : H `app_games_hub_player_leave` 5785–5797 et `app_games_hub_player_unregister` 5738–5771 écrivent `games_hubs_players.status='left'`. Le second annonce explicitement `hub_only`, sans créer de mapping/runtime. Départ de session et départ Hub sont deux périmètres distincts.
- **Réinscription** : upsert interne H 5512–5622 peut réactiver la même identité ; EP passe par `app_games_hub_player_register_ep` 5677 et suivants. Public invité Hub Play H 5631–5675 : retry de sa propre identité active inchangé ; après départ, pseudo déjà utilisé (même `left`) refusé, autre pseudo libre → nouvelle identité. Cette règle locale récente doit être vérifiée sur la version serveur concernée.
- **Papier** : mode calculé par H `app_games_hub_session_mode_get` 5827–5831 (`flag_controle_numerique=0`). Sélection collective = tous les actifs du Hub, y compris sans visite récente Hub Play. **Pas les identités `left`.** Puis guards supplémentaires : Hub actif, membership session, joueur du même Hub actif, jeu/token supportés, session non terminée, clé canonique valide, API disponible. Mapping de CETTE session `left` empêche le rejoin automatique ET `launch`; seuls `manual/direct/refresh` ou `manual_rejoin` permettent la réactivation (H 9128–9200). Papier appelle uniquement `player_register` puis mapping prouvé, sans grille/Player WS/navigation numérique. `paper_registration_confirmed` exige preuve runtime.
- **Numérique** : **aucune requête collective de joueurs à injecter au lancement canonique**. Un joueur doit encore effectuer le parcours Hub Play : requête `active_launched_session`, identité résolue active (preuve/cookie/EP), session membre égale au focus persisté, `hub_is_focus_active=1`, non terminée ; mapping non `left` pour autojoin ; ensure runtime réussi. H `app_games_hub_get_active_launched_session_for_player` 10338–10428 et `app_games_hub_session_is_auto_joinable` 10228–10241 ; Games handler `active_launched_session` 2996–3024. `runtime_status=running` n'est pas exigé (Bingo peut rester pending). Pas de seuil `last_seen_at` dans cette décision. « Présence » signifie ici requête/parcours effectif, pas une équivalence active = socket connectée. La connexion au runtime suit la création/réconciliation de participation et la navigation Player.
- **Idempotence** : mapping unique `(id_hub_player,id_session)` (H 365–391), recherche H 8382–8394 ; verrou `GET_LOCK` 5 s avec clé Hub/session/joueur, relecture mapping 8811–8834 ; clé participant stable et `event_id=hub:{hub}:{session}:{player}` 8844–8853 ; validation API puis upsert 8956–9000. Un mapping existant n'est pas à lui seul un succès : le moteur est réconcilié. Un `completed` d'une autre session ne bloque pas. Le résumé d'injection est imparfait : le resolver papier retourne `active`, alors que `already_count` ne reconnaît que `already_active` ; ne pas conclure à des doublons d'après `injected_count` seul. Les échecs individuels ne font pas échouer automatiquement le lancement global.

## Autres causes examinées

| Cause envisagée | Verdict borné / preuve |
|---|---|
| Identité désactivée à tort en fin | Non trouvée dans les handlers de fin/complétion examinés. Les écritures `left` identifiées sont des départs explicites. SELECT avant/après requis pour le cas observé. |
| Rattachement absent/ambigu ou focus incorrect | Possible en données. Le resolver exige une membership active unique ; ne pas réparer en déduisant le Hub du client/date. Focus absent est déjà une conséquence attendue du lancement historique neuf. |
| Injection écrasée par initialisation | Non trouvée dans les ensures SQL historiques : `_qz_ensure_session_exists` (`quiz_adapter_glue.php` 81–122) et `_bt_ensure_session_exists` (`blindtest_adapter_glue.php` 88–105) retournent si la session existe, sinon INSERT IGNORE, sans supprimer les joueurs. `bingo_api_reset` 698–788 réinitialise grilles/morceaux/lots, pas le roster Hub. Une course runtime/rendu reste à vérifier ; absence de test bout en bout WS. |
| Mapping antérieur bloquant S2 | Non pour S1 `completed` : clé composée avec session. Oui pour mapping S2 `left`, conformément au départ volontaire ; erreurs d'API/verrou/clé peuvent aussi empêcher la preuve de participation. |
| Données présentes, lobby vide | Possible, distinct du défaut d'injection. Preload Quiz `_qz_fetch_players` 182–217 / BT `_bt_fetch_players` 345–380 lit par ID SQL interne de session ; Bingo `_bingo_fetch_players_for_preload` 254–274 lit par token avec `includeInactive=1`. `bingo_api_players_get` 1258–1308 filtre `is_active=1` sauf includeInactive ; `canvas_display.js`, `shouldIncludeInactivePlayersForSnapshot` 471–485 ne l'ajoute qu'en terminal. Quiz/BT WS `updatePlayerListNow` (`quiz/web/server/actions/gameplay.js` 1032–1076, BT 1244–1283) utilisent le roster mémoire dédupliqué et limitent le rendu live à 50 entrées (BT peut agréger en équipes). Ni compteur Hub ni présence SQL ne prouve ce roster mémoire. |

L'initialisation WS peut remettre des scores à zéro sur transition vers « En attente » (Quiz `initializeOrUpdateSession`, 250–282) ; le commentaire « démo » ne suffit pas à prouver un guard démo autour de ce bloc. Ce risque de reprise doit être testé, sans le confondre avec une suppression d'identités Hub ni élargir ce correctif à un refactoring WS.

Filtres runtime supplémentaires vérifiés : `quiz_api_players_get` (`quiz_adapter_glue.php`, 1250–1288) et `blindtest_api_players_get` (`blindtest_adapter_glue.php`, section du même nom) excluent `is_active=0` sauf `includeInactive`. Ce flag moteur n'est pas `games_hubs_players.status`. `quiz/web/server/actions/registration.js`, `hydratePlayersFromDB` 668–807 : inclut les inactifs uniquement démo/terminal, exige ID SQL de session, ignore une clé `player_id` vide, déduplique et restaure aussi des joueurs déconnectés. `registerPlayer` 433–650 applique également la capacité `maxPlayers` (565–577). Bingo `bingo_server.js`, `hydratePlayersFromDB` 3464–3613 exige clé canonique et ID numérique positif ; les lignes sont projetées dans `paperPlayersByGame`. Ainsi, même le roster moteur n'est pas synonyme de sockets actuellement connectées.

Point d'intégration à valider impérativement : `registerOrganizer` Quiz (`registration.js`, 205–225) n'hydrate la DB qu'une fois en live (`_hydratedFromDB`), sauf conditions démo/terminal. Une injection après l'ouverture du Master doit donc réconcilier **aussi le roster WS**, pas uniquement le store du navigateur ; un snapshot WS ancien peut sinon remplacer l'affichage rafraîchi. C'est une limite concrète à la proposition de correctif, pas une preuve que l'incident actuel vient d'une injection déjà effectuée.

## Correctif minimal évalué — non appliqué

Conserver CTA Pro, `/master/{id_securite}`, lobby, QR et retour historique. Intégrer un appel serveur de préparation officielle **au clic de lancement accepté**, après les guards existants et avant `runIntroIfNeeded`/`Game.handleUI(play)`, pas au GET du Master ni au simple preload. Point client : `beginPlayFlow` dans `boot_organizer.js`. Point serveur proposé : action organisateur dans `app_orga_ajax.php`, avec les protections de mutation existantes (auth organisateur, méthode/CSRF ou contrat existant vérifié lors du patch), résolution session canonique puis membership Hub ; ne jamais accepter Hub/mode officiel sur la seule foi du navigateur.

Le helper Global doit réutiliser/exposer la préparation canonique du lancement, sans dupliquer les SQL : guards → ensure historique papier → focus confirmé → exécution → injection papier → résultat exploitable. L'appel direct au service complet existant demande d'isoler ses effets de navigation/routage/QR : renvoyer uniquement une URL que le client ignorerait ne suffit pas à préserver l'UX. Ne pas activer automatiquement le contexte de retour Hub historique si cela remplace le retour Pro demandé. Pour numérique, engager le focus canonique permet le parcours existant des joueurs présents ; **ne pas injecter tout le roster numérique**, ce serait changer le contrat.

Après une injection réalisée après le preload initial, rafraîchir le snapshot participants historique avant de démarrer : sinon les lignes peuvent être bien créées mais invisibles dans le lobby/store. Garantir aussi la réconciliation des arrivées Hub Play concurrentes. Une simple insertion de l'appel d'injection dans le PHP GET aurait le mauvais moment fonctionnel et ne réglerait pas le focus numérique.

Idempotence nécessaire : intention serveur/session stable au retry ; réutilisation d'exécution officielle encore ouverte ; mêmes verrous et clés de participation ; refus terminal ; respect du mapping `left` ; traitement explicite des échecs partiels. Appel du service Hub déjà effectué (`source=hub`/exécution vérifiée) → pas de seconde préparation. Double clic, retry réseau, deux Masters et polling Player doivent converger ; pas seulement un booléen JS. Une reprise runtime existante conserve les participants et scores ; ne pas réinjecter aveuglément ni appeler resetdemo. Un contexte démo/`flag_session_demo=1`, même avec une source officielle Hub, doit sortir avant focus/injection officiels. Session autonome sans membership → parcours actuel sans joueur Hub ; distinguer absence réelle et erreur/ambiguïté de résolution.

Périmètre fonctionnel proposé :

- `games/web/includes/canvas/core/boot_organizer.js` : barrière au lancement + actualisation participants.
- `games/web/modules/app_orga_ajax.php` : action serveur organisateur vérifiée.
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php` : préparation partagée, idempotence/guards, sans nouveau contrat de sélection.
- Éventuellement `games/web/organizer_canvas.php` pour exposer la capacité/contexte minimal ; `canvas_display.js` seulement si le rafraîchissement existant ne peut être réutilisé.
- Tests ciblés Games/Global. Aucun changement Pro/routes/QR/lobby visuel, adaptateurs moteur ou WS requis à ce stade ; si un tel besoin apparaît, réévaluer le scope avant patch.

## Données à demander et SELECT ciblés

Demander environnement observé, jeu/mode, ID Hub H, IDs numériques S1/S2, heures des ouvertures et vrais clics « lancer », pseudonymes/IDs techniques de 2–3 joueurs (invité/EP), origine de leur inscription (Hub Play, QR historique, Remote papier), et état de l'onglet joueur entre les sessions. Aucun token/cookie n'est nécessaire dans le retour.

Schéma : [DDL RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/schema/DDL.sql), sections `games_hubs`, `games_hubs_sessions`, `game_events`, `cotton_quiz_sessions/players`, `blindtest_sessions/players`, `bingo_players`; [OVERVIEW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/schema/OVERVIEW.md), état du snapshot. Les deux tables roster/mappings ne figurent pas dans ce DDL rechargé : définitions **locales vérifiées** dans H `app_games_hub_schema_ensure`, 292–320 et 365–391. Ne pas supposer ces extensions présentes sur le serveur. Première requête de lecture :

```sql
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('games_hubs','games_hubs_sessions','games_hubs_players',
    'games_hubs_players_sessions','championnats_sessions','game_events',
    'cotton_quiz_sessions','cotton_quiz_players','blindtest_sessions',
    'blindtest_players','bingo_players')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
```

Après concordance, remplacer les nombres d'exemple 100, 101, 102 par H, S1, S2 ; exécuter les mêmes SELECT avant S1, après fin S1, après ouverture S2 puis après lancement réel S2 :

```sql
SELECT id, id_client, hub_date, flag_active, active_session_id,
       active_session_activated_at, presentation_session_id
FROM games_hubs WHERE id = 100;

SELECT ghs.id_hub, ghs.id_session, ghs.status, ghs.membership_source,
       cs.id_type_produit, cs.flag_controle_numerique, cs.flag_session_demo
FROM games_hubs_sessions ghs
JOIN championnats_sessions cs ON cs.id = ghs.id_session
WHERE ghs.id_session IN (101,102)
ORDER BY ghs.id_session, ghs.id_hub;

SELECT id, auth_type, status, created_at, updated_at, last_seen_at
FROM games_hubs_players WHERE id_hub = 100 ORDER BY id;

SELECT id_hub_player, id_session, game_type, id_participation,
       status, join_count, last_action, last_joined_at, left_at,
       completed_at, last_error
FROM games_hubs_players_sessions
WHERE id_hub = 100 AND id_session IN (101,102)
ORDER BY id_hub_player, id_session;

SELECT id_hub_player, id_session, COUNT(*) AS n
FROM games_hubs_players_sessions
WHERE id_hub = 100 AND id_session IN (101,102)
GROUP BY id_hub_player,id_session HAVING COUNT(*) > 1;

SELECT e.id, e.action, e.created_at
FROM game_events e
JOIN championnats_sessions cs ON cs.id_securite = e.session_id
WHERE cs.id IN (101,102)
  AND e.action IN ('hub_execution_started','hub_execution_completed',
    'player_register','session_update','end_game')
ORDER BY e.id DESC LIMIT 100;
```

Preuve runtime (choisir le jeu ; pas de confusion ID primaire SQL et token) :

```sql
SELECT cs.id AS official_session_id, s.id AS runtime_id,
       p.id AS participation_id, p.is_active, p.score
FROM championnats_sessions cs
JOIN cotton_quiz_sessions s ON s.session_id = cs.id_securite
LEFT JOIN cotton_quiz_players p ON p.session_id = s.id
WHERE cs.id IN (101,102) ORDER BY cs.id,p.id;

SELECT cs.id AS official_session_id, s.id AS runtime_id,
       p.id AS participation_id, p.is_active, p.score
FROM championnats_sessions cs
JOIN blindtest_sessions s ON s.session_id = cs.id_securite
LEFT JOIN blindtest_players p ON p.session_id = s.id
WHERE cs.id IN (101,102) ORDER BY cs.id,p.id;

SELECT cs.id AS official_session_id, p.id AS participation_id, p.is_active
FROM championnats_sessions cs
LEFT JOIN bingo_players p ON p.session_id = cs.id_securite
WHERE cs.id IN (101,102) ORDER BY cs.id,p.id;
```

Ces requêtes n'ont pas été exécutées. Les lignes moteur sans mapping doivent être rapprochées de l'inscription historique ; ne pas fusionner les joueurs par pseudo. Les doublons de clés runtime seront à contrôler via `player_id` seulement si la première requête confirme cette colonne, absente du snapshot DDL de ces tables. Pour le rendu, demander les réponses `active_launched_session`, preload/`players_get` et `updatePlayers` aux instants utiles, sans secrets ; SQL seul ne donne pas les sockets.

Si une modification hors workspace des fichiers concernés est connue, **merci de rapatrier leur version de l'environnement observé avant toute conclusion sur cette version** : les trois fichiers du périmètre minimal, `organizer_canvas.php`, `games_ajax.php`, les trois `*_adapter_glue.php`, `boot_lib.php`, et côté Pro `ec_start_sessions_day_helpers.php`, `ec_start_sessions_day_dashboard_view.php`, `ec_start_sessions_day_dashboard_v2_style.php` plus Global `app_sessions_functions.php`. Pour une divergence limitée au rendu WS, ajouter `quiz/web/server/actions/{registration,gameplay,connection}.js` et équivalents Blind Test. Aucun rafraîchissement à l'aveugle des modifications locales.

## Recette ciblée à exécuter après correctif éventuel

| Cas | Observation attendue |
|---|---|
| Mobile 390/768/991 px, contrôle frontière 992 | Routes et CTA historiques conservés ; ouvrir le Master ne lance pas la session ; QR/lobby/retour inchangés. |
| S1 puis S2 officielles papier, même Hub | Identités actives avec et sans navigateur récent injectées dans chacune ; même identité Hub, participation/mapping propre à chaque session. Identité `left` exclue. Comparer avant/après clic, pas seulement après ouverture. |
| S1 puis S2 numériques | Joueur Hub Play encore présent rejoint S2 grâce au focus ; joueur navigateur fermé reste actif au Hub mais n'est pas injecté en masse ; réouverture valide déclenche ensure. Tester invité, EP, QR historique et arrivée tardive. |
| Fin naturelle | S1 terminale, focus clear conditionnel, identité Hub active inchangée, mapping completed observé après résolution ; S2 ne récupère ni score ni mapping S1. Fin tardive S1 n'efface pas focus S2. |
| Départ / réinscription | Départ session S1 laisse identité éligible S2 ; mapping S1 left interdit autojoin S1 ; rejoin manuel suit son contrat de reset. Départ Hub exclut S2. Public invité : même pseudo refusé après départ dans la version locale actuelle, autre pseudo → nouvelle identité ; EP/internal → réactivation contrôlée. |
| Reprise / relance / retry | Pause/reload/runtime existant, runtime recréé, double clic, réponse perdue, lancement Hub suivi accès individuel et ordre inverse, polling concurrent : aucune nouvelle ligne en doublon, aucun score remis à zéro sur simple reprise ; terminal non relançable. |
| Échec partiel | Refus commercial/temporel/auth, ensure historique KO, verrou/API KO : aucun lancement silencieusement présenté comme complet ; diagnostic permettant de distinguer participants manquants et rendu. |
| Contrôles exclus | Sessions autonomes, démo historique dupliquée, démo Hub, compte inactif et hors fenêtre : aucun roster officiel importé, aucun focus officiel modifié par démo. |
| Rendu | Vérifier les 3 jeux, papier/numérique, nouveau runtime froid, participants SQL vs mapping vs preload vs lobby/WS ; Bingo actif/inactif, BT équipes et plus de 50 entrées en live. |

## Vérifications locales réalisées

- `php global/web/tests/hub_player_roster_registration_state_test.php` : OK.
- `php global/web/tests/hub_paper_cold_runtime_bootstrap_contract_test.php` : OK.
- `php global/web/tests/hub_remote_control_contract_test.php` : OK.
- `php pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php` : OK.
- Aucun nouveau test d'implémentation ni simulation présentée comme recette réelle. Génération documentaire et contrôle diff effectués après consignation.

Les quatre commandes ci-dessus sont à exécuter depuis `/home/romain/Cotton` (ou adapter le préfixe au repo). Aucun correctif à annuler ; rollback documentaire limité à cette note et aux entrées associées, sans toucher aux modifications préexistantes.
