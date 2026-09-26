# Audit — suppression d’une partie Hub — 16/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-session-removal-audit-20260916" owner="codex" -->

## Statut courant — patch réduit appliqué localement, 16/09/2026

La dernière demande remplace le contrat d’arrêt des runtimes actifs de l’audit précédent. Le retrait est disponible dans le paramétrage Master/Remote pour **non-jouée, suspendue libérée et terminée**, jamais en cours. Pro garde son initiation historique limitée aux non-jouées. Les audits ci-dessous restent historiques ; leur arrêt avant patch ne décrit plus cette version locale. **Aucune livraison PROD, DB réelle, migration, déploiement ou redémarrage.**

### Audit polling / propagation retenue

- Master : `games_hub_preparation_revision` contient la liste active et `date_maj` ; `hubMasterPreparationRefresh` recharge le document puis remplace programme/branding/classement et rebranche les contrôles. Après commande Remote acquittée, un refresh forcé est demandé. Le classement vide remplace aussi un classement antérieur. La garde de suspension automatique du poll après cutoff est désactivée.
- Remote : `control_poll` compare les révisions et déclenche `business_snapshot`. `remove_session` est une commande, traitée côté Master serveur ; aucun retrait métier direct dans la Remote. Terminal réussi → fermeture des réglages et snapshot. Le snapshot retire les cartes absentes, neutralise la sélection pending et ferme une modale dont le membre a disparu ou est devenu en cours. Réponses de réglages tardives contrôlées par numéro de requête et programme courant. Observation conservée après cutoff, gardes remplacement/bootstrap inchangées.
- Pro : poll léger existant de 12 s puis refresh partiel. L’arrêt hors fenêtre aurait empêché d’observer le retrait d’une terminée : il est désactivé. Le resolver legacy refusait une liste partiellement liée, et le rendu refusait de remplacer par une liste vide. La résolution reconnaît désormais uniquement les memberships inactifs accompagnés du journal de retrait ; le rendu utilise aussi la liste active vide et garde le conteneur rafraîchissable. Les éditions locales peuvent différer le refresh jusqu’à leur fermeture, selon le garde existant.
- Play : getter de membres actifs et resolver de présentation déjà canoniques ; aucun fichier Play modifié. Retirer la session présentée sélectionne un autre membre pertinent, sinon le Hub neutre. Aucun lancement automatique. Une session suspendue a déjà perdu son focus ; le journal de suspension conservé maintient le gel.

### Primitive, mappings, rebuild et concurrence

`global/web/app/modules/jeux/hubs/app_games_hub_removal.php` porte `app_games_hub_session_remove` et la classification des états. Propriétaire, Hub actif, membership et état sont relus sous le verrou SQL Hub existant. Ce verrou couvre aussi lancement/reprise, suppression historique et lecture/écriture du rebuild persistant.

Non-jouée : délégation stricte à `app_session_delete_canonical` (suppression physique et nettoyages existants), avec la garde supplémentaire Hub sous verrou pour le Dashboard. Suspendue : preuve `suspended + released`, absence de focus actif ; intention durable `hub-remove-{hub}-{session}` / action `hub_execution_removed`, exécution fermée à la lecture, lancement/reprise et rattachement explicite interdits. Le runtime reste gelé jusqu’au cleanup canonique de cutoff ; aucune prétention de purge mémoire immédiate, aucun changement à `hub_suspend`. Terminée : même retrait logique sans destruction de l’historique.

Les mappings deviennent `left`, avec `left_at` et `last_action=hub_session_removed` ; identifiants, `completed_at`, photos et résultats globaux restent conservés. Présences runtime ciblées supprimées, commandes launch/select pending/claimed/processing ciblées annulées. `presentation_session_id` effacé uniquement s’il correspond au membre retiré.

Dirty puis **rebuild réel synchrone** des contributions restantes, classement/podium/victoires/places/participations ; fallback historique borné acquis conservé. Révision publiée et événement `hub_removal_completed` seulement après succès. Les tables MyISAM ne rendent pas l’ensemble transactionnel : chaque étape est rejouable, intention conservée et réponse retryable en cas d’échec. Une nouvelle demande termine l’opération ; un replay terminé n’effectue pas de deuxième rebuild. Pas de worker de retry ajouté.

### UX et autorité

Action danger uniquement dans « Paramétrer la partie », aucun CTA supplémentaire de carte. La roue de paramétrage est accessible aussi pour une terminée. En cours : aucune action danger, réglages existants conservés. Confirmation `<dialog>` applicative partagée, titre « Supprimer cette partie ? », Annuler/Supprimer, texte exact programme ou soirée/événement via resolver. Master exige organisateur, CSRF et instance courante. Remote exige accès/instance/CSRF et présence Master ; commande réévaluée lors de son exécution. Devenue en cours → refus ; devenue terminée → retrait terminé. Aucun changement Santeuil, reset, USERNAME_REFERENCED, scoring ou première confirmation de lancement.

### Matrice demandée et niveau de preuve

Les preuves suivantes sont **locales, isolées**, avec stockage et effets externes simulés. Elles ne constituent pas une recette réseau multi-navigateurs ni un test de contention MySQL réelle.

| Cas | Couverture et résultat |
|---|---|
| 1–2 : non-jouée Master/Remote | Handler réel Master et exécution réelle de commande Remote → service réel → délégation historique vérifiée, OK. |
| 3 : non-jouée Dashboard | Contrat historique et garde partagée ; suites `hub_delete_service_contract_test.php` et Dashboard, OK. Nettoyage historique non réécrit. |
| 4–7 : suspendue/terminée Master/Remote | Service/handlers réels, membership/mappings/historique/gel/ACK et replays, OK. |
| 8–10 : En cours | État de réglages partagé sans `can_remove`, édition conservée ; appels forcés et course ouverture/confirmation refusés, OK. |
| 11–12 : rebuild | Orchestration synchrone sous verrou pour suspendue/terminée ; writer réel testé sur fixtures, OK. |
| 13 : fallback dirty | Suites membership fallback et reproduction 101/102 inchangées, OK. |
| 14 : podium | Writer réel : score/participations 1000/2 → 500/1 → 0/0, victoires et podium recalculés puis vides, OK. |
| 15 : présentation | Effacement conditionnel, resolver réel avec ancienne sélection stale, fallback membre restant puis neutre ; aucune activation, OK. |
| 16–20 : propagation dans les six directions | Révisions/liste active/ACK/refresh existants, suites polling Remote, DOM Master et Dashboard ; résolution Pro après retrait testée en mémoire, OK au niveau composants/contrats. Recette simultanée sur navigateurs restante. |
| 21 : modale stale | JS réel extrait : disparition ou devenue en cours annule confirmation et ferme Master/Remote ; gardes requêtes tardives, OK. |
| 22 : dernière session | Projection/podium zéro, resolver neutre, liste Pro canonique vide et conteneur préservé, OK. |
| 23 : Play | Resolver actif réel sans session lancée et présentation fallback ; suites DOM Play et suspension, OK. |
| 24 : quick-add | Gardes temporelles/commerciales inchangées, suites settings/programmation/Dashboard, OK. |

Concurrence simulée supplémentaire : verrou occupé, double demande Master/Remote, état rechargé, huit échecs SQL intermédiaires, rebuild en erreur puis retry. Intention bloquant la reprise avant finalisation et déverrouillage vérifiés. La réentrance de GET_LOCK et la contention entre connexions doivent encore être recettées sur la version DB cible.

### Tests exécutés

Depuis `/home/romain/Cotton` :

```sh
php global/web/tests/hub_session_removal_test.php
php global/web/tests/hub_stats_pending_session_test.php
php global/web/tests/hub_historical_membership_fallback_test.php
php global/web/tests/hub_removed_session_fallback_reproduction_test.php
php games/web/tests/hub_session_settings_test.php
php games/web/tests/hub_remote_contract_test.php
php pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php
node --test games/web/tests/hub_session_removal_dom_test.mjs games/web/tests/hub_session_settings_dom_test.mjs games/web/tests/hub_remote_polling_test.mjs games/web/tests/hub_suspend_test.mjs
```

Résultats : 162 contrôles ciblés de retrait OK ; rebuild réel sur fixtures OK ; 20 suites PHP Global/Games ciblées + Dashboard Pro OK ; quatre fichiers JS, 37 résultats TAP OK. Les assertions des anciens tests qui exigeaient l’arrêt du polling après cutoff ont été actualisées au nouveau contrat. Autres suites PHP exécutées : projection stats, photos fallback, classement Clients, suppression historique, routage canonique, quick Hub service, active resume, suspension, présence Remote, séparation présentation/runtime, natural end rebuild, launch confirmation, fast context, probable Play. Lints PHP et `git diff --check` ciblés ; sitemap/index régénérés.

### Fichiers applicatifs et tests

- Global : `web/app/modules/jeux/hubs/app_games_hub_removal.php` (nouveau), `app_games_hubs_functions.php`, `web/app/modules/jeux/sessions/app_sessions_functions.php` ; tests `hub_session_removal_test.php` (nouveau), `hub_stats_pending_session_test.php`.
- Games : `web/modules/app_hub_removal_helpers.php` (nouveau), `app_hub_view_helpers.php`, `app_hub_remote_ajax.php` ; tests `hub_session_removal_dom_test.mjs` (nouveau), `hub_session_settings_test.php`, `hub_session_settings_dom_test.mjs`, `hub_remote_contract_test.php`, `hub_active_resume_test.php`.
- Pro : `web/ec/modules/tunnel/start/ec_start_sessions_day.php`, `ec_start_sessions_day_dashboard_view.php`, `ec_start_sessions_day_dashboard_test.php`.
- Documentation : présente note, README/TASKS Global/Games/Pro, HANDOFF, CHANGELOG, Canvas bridge, DOCS_MANIFEST, sitemap/index générés.

### Réserves et rollback

Pas de recette navigateur authentifiée, DB réelle, crash moteur ou contention de connexions. Le runtime suspendu est retenu gelé jusqu’au cleanup canonique ; après restart, les limites de restauration existantes restent applicables. Les échecs partiels requièrent une nouvelle tentative tant que l’ACK durable n’est pas écrit. Un onglet caché, une coupure réseau ou une édition locale Pro peut différer la propagation ; retour au premier plan/reprise du réseau/fin d’édition réutilisent les refreshs existants.

Avant toute utilisation : rollback par retrait des seuls changements de ce patch, en conservant le fallback préparatoire accepté. Après utilisation réelle, ne pas réactiver automatiquement les memberships retirés ni effacer les événements de retrait ; ne pas retirer les gardes serveur de reprise sans traitement de ces retraits. Aucun rollback de données effectué ici.

---



## Reprise du chantier principal — audit final : arrêt avant mutation

Le prérequis fallback est acquis et n’a pas été réaudité. Le point bloquant restant est le protocole de cleanup runtime actif/suspendu, avec concurrence et ACK. Aucun patch applicatif supplémentaire, aucune UI ou wording modifiés lors de cette reprise. Ce n’est pas une impossibilité technique : une extension du lifecycle existant est nécessaire avant de pouvoir certifier le retrait tous états demandé.

### Six invariants demandés

| Invariant | Preuve / statut |
|---|---|
| Retrait membership | Brique existante confirmée : Global `app_games_hubs_functions.php:275-287,2918-2969` et Sessions `app_sessions_functions.php:3418-3426`, active→inactive et programme filtré. Ce n’est pas un arrêt moteur. |
| Invalidation des exécutions/reprises | `app_games_hubs_functions.php:4292-4336,4518-4542` : `execution_context_complete` écrit un événement idempotent qui ferme la lecture d’exécution ouverte. Aucun appel d’arrêt WS/mémoire. Une orchestration de retrait avec invalidation atomique de lancement/reprise : **non trouvée**. |
| Cleanup actif/suspendu | **Bloquant.** Quiz/Blindtest `web/server/actions/hubLifecycle.js:54-62` et Bingo `ws/hub_lifecycle.js:54-62` : sweep ne traite que `hubSuspension.suspended` à cutoff atteint, sans lecture canonique. Aucun ACK de cleanup vers Global. |
| Rebuild immédiat | Brique existante déjà auditée et inchangée ; fallback préparatoire accepté. Atomicité retrait/rebuild concurrent non certifiée : ne pas confondre transaction d’écriture de projection et verrou couvrant toute l’opération distribuée. |
| Concurrence | **Non verrouillée pour ce retrait.** Verrou suppression Hub `app_games_hubs_functions.php:3809-3827` utilisé par suppression du conteneur, laquelle refuse les sessions locked (`:3864-3900`). Lancement `:9936-10180` et focus `:4550-4628` ne prennent pas ce verrou ; le focus relit le membership puis effectue un UPDATE distinct. Un verrou du seul futur endpoint supprimer ne suffit pas à sérialiser les reprises déjà engagées. |
| Propagation automatique | Mécanismes réutilisables trouvés, aucun gros nouveau bus requis. Global `:929-961` : révision membership et fingerprint du programme actif. Games Master `app_hub_view_helpers.php:11229-11270`, Remote `app_hub_remote_ajax.php` control_poll/business_snapshot. Pro `ec_start_sessions_day_dashboard_view.php:3072-3324` : polling révision/refresh partiel. Réserves ci-dessous ; aucune recette suppression E2E prétendue. |

### Pourquoi les cleanups existants ne suffisent pas

Quiz/Blind Test `hubSuspension.js:16-26` disposent d’un callback qui nettoie gameplay/registration/playerCount/wsHandler, ferme les sockets et retire l’objet `sessions`. Il est câblé au sweep d’expiration, pas à une demande de suppression provenant du Dashboard. Bingo `ws/bingo_server.js:3656-3674` fait aussi un cleanup mémoire, mais refuse explicitement si l’objet n’est pas la suspension attendue. Réutiliser ces callbacks demandera un contrôle d’identité d’exécution et un état terminal dédié ; changer arbitrairement le cutoff ou écrire seulement le membership ne constitue pas ce contrat.

Games `web/includes/canvas/php/hub_lifecycle.php:3-82` accepte read/validate/suspend/release/resume, puis retourne `HUB_STAGE_INVALID`. Il reçoit des appels moteur→Canvas ; il ne commande pas un arrêt PHP→moteur. Le contrôle de suspension dépend du socket primaire côté moteur (`hubLifecycle.js:35-38`). API d’arrêt autoritaire, ciblée par exécution, accessible sans Master et avec preuve durable de cleanup : **non trouvée dans les chemins examinés des trois moteurs**. La fermeture d’une exécution en base n’arrête ni timers, ni sockets, ni état moteur existant.

Reproduction isolée `/tmp/hub-removal-runtime-audit/probe.cjs`, avec les trois vrais modules `createHubLifecycle` et callbacks simulés : état actif + suspension avant cutoff ; le callback de lecture canonique, s’il était appelé, refuserait `SESSION_NOT_IN_HUB`. Après 20 sweeps, pour chacun des trois jeux : **0 lecture canonique, 0 disposal, runtime actif non gelé**. Après cutoff, seule la suspension est disposée. Cette sonde caractérise le sweep ; elle ne simule pas une suppression E2E et n’accède à aucune DB.

### Propagation et états stale : adaptations identifiées, pas blocage architectural

Pro publie `data-program-revision-interval-ms=12000` et utilise une requête de révision puis remplacement partiel du programme. Mais `hubSyncSuspended` coupe polling/check (`:892,3225,3324`) si toutes les parties sont closes et quick-add hors fenêtre. Il faudrait maintenir une observation permettant le retrait des sessions terminées. Le garde `dashboardHasLocalWork` (`:3114-3121`) diffère le refresh pendant certaines modales/éditions/aria-busy : la suppression exigera une invalidation ciblée des états stale, sans écraser une édition non concernée. Ces adaptations sont locales ; aucun besoin de nouveau bus établi.

Master/Remote disposent déjà des révisions et polls ; le backend devra néanmoins revalider membership actif pour chaque action retardée. Play utilise le programme canonique, mais la sortie d’un runtime déjà ouvert dépend aussi du protocole terminal manquant. L’audit ne certifie donc pas encore les six directions de propagation de la suppression.

### Mappings, présentation et comportements conservés

`games_hubs_players_sessions` propose `created|active|left|completed|failed`, pas inactive/removed (`app_games_hubs_functions.php:366-390`). `session_mapping_upsert` gère left_at/completed_at (`:8400-8458`) et conserve les identifiants de participation. `left` est exclu du rebuild déjà audité, mais est réactivable par les chemins de join : il ne constitue pas à lui seul une interdiction définitive de reprise. Aucun mapping n’a été changé.

Le clear focus conditionnel existant (`:4635-4690`) et le resolver de présentation (`:10298` et suivantes, décalage dû au patch préparatoire) restent des briques utiles ; aucun lancement automatique proposé. Les photos et snapshots n’ont pas été touchés. Non démarrée : suppression historique conservée. En cours/suspendue : arrêt terminal non livré. Terminée : retrait + rebuild non livré par ce chantier tant que le contrat tous états est bloqué. Master/Remote/Pro, confirmations et premier lancement : inchangés.

### Contrat nécessaire pour débloquer

1. Intention de retrait durable, idempotente, ciblée Hub/session/exécution ; gel serveur vérifié par lancement, reprise, commandes Remote et mutations moteur/HTTP.
2. Livraison au moteur sans dépendre d’un navigateur Master ; sérialisation avec les opérations runtime déjà en vol, nettoyage des timers/sockets/Maps de l’exécution exacte.
3. ACK durable de cleanup, vérifiable après timeout/retry ; aucune réussite annoncée avant cet ACK ou une preuve serveur d’absence de runtime. La seule absence de heartbeat ne suffit pas à prouver l’arrêt.
4. Finalisation récupérable : exécution/suspension invalidées, focus conditionnel, présentation, membership et mappings neutralisés, rebuild synchrone puis publication révision. Verrou partagé avec les chemins concurrents pertinents.

Ces étapes peuvent étendre le lifecycle existant ; elles ne requièrent pas nécessairement un nouveau bus. Elles ne sont pas implémentées ici, en application de la consigne d’arrêt avant patch lorsqu’un invariant final est bloquant.

### Vérifications de cette reprise

- `php games/web/tests/hub_suspend_test.php` : 74 contrôles OK, effets simulés.
- `node --test games/web/tests/hub_suspend_test.mjs` : 34/34 OK, notamment protocoles Quiz/Blind Test et retour Play.
- `node --test bingo.game/ws/tests/hub_suspend.test.js` : 6/6 OK.
- `php pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php` : OK.
- Sonde des trois vrais lifecycle modules : comportement insuffisant pour suppression confirmé (voir ci-dessus).
- Les 55 scénarios de suppression ne sont pas déclarés validés. Tests existants exécutés uniquement pour caractériser les primitives ; aucun service démarré.

Documentation seule modifiée lors de cette reprise : présente note, HANDOFF, TASKS Global/Games/Pro ; sitemap/index générés. README et contrats métier non modifiés, puisqu’aucun nouveau comportement n’est livré. Sources raw/journal rechargés avant l’audit ; journal identique, aucun chemin ciblé signalé hors workspace. Aucun déploiement, redémarrage, accès DB réel, commit ou push. Rollback de cette étape : retirer seulement ses ajouts documentaires ; conserver le patch préparatoire fallback validé.


## Résolution préparatoire — 16/09/2026 — locale, non déployée

Le blocage de fallback décrit ci-dessous est corrigé par le patch Global demandé après l’audit. Les sections « Audit initial » suivantes restent la preuve historique avant correction ; elles ne décrivent plus le comportement du fallback local. Le chantier de suppression complet demeure non livré.

## Audit initial — décision : arrêt avant patch applicatif

L’invariant bloquant M n’est pas confirmé avec les primitives actuelles. Le rebuild persistant est borné au programme actif, mais le fallback historique ne l’est pas. Un retrait `games_hubs_sessions.status=inactive` suivi d’un rebuild réussi ne garantit donc pas l’exclusion durable : une lecture ultérieure dirty/en erreur peut réintroduire les contributions conservées hors Hub. Conformément à la demande, aucune suppression étendue, modification UI ou modification du premier lancement n’a été appliquée. Ce constat ne signifie pas que le produit est irréalisable : il exige d’abord un contrat de lecture historique borné au Hub.

## Sources et discipline

Entrées raw consultées le 16/09/2026 : [START](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), [SITEMAP](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md), SITEMAP.txt, SITEMAP.ndjson, README, DOCS_MANIFEST et HANDOFF. Copie HTTP directe du sitemap : SHA annoncé `f14efd7e9dd69af23696a3e151388852b6407ddf` ; le cache du lecteur web était plus ancien, la copie directe a été retenue.

Journal AI Studio public chargé et décodé depuis son enveloppe HTML. Aucun chemin applicatif ciblé Global/Hubs, Global/Sessions, Global/Clients, Games/Hub ou Pro/Start signalé comme modifié hors workspace. Les changements WWW publics et AI Studio signalés restent hors périmètre ; aucune copie serveur de ces fichiers n’était nécessaire pour cet audit. Les modifications locales préexistantes sont conservées.

Docs raw pertinentes : [Global README](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), sections « Update 2026-07-30 - Contexte Global Hub léger pour aggregate_ranking », « Initialisation auto des stats Hub historiques » et paragraphe suppression individuelle (ligne 282 de la copie raw). Ces sections décrivent le fallback client/période et le rebuild Hub ; elles ne garantissent pas l’exclusion d’une session retirée. README raw Games et Pro consultés également. Contrat livré de suppression d’une partie Hub déjà démarrée : **non trouvé**.

## Preuves de code (chemins relatifs à /home/romain/Cotton)

| Sujet | Fichier / fonction / lignes | Constat |
|---|---|---|
| Garde Dashboard | `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php:397-403,1062` | Token requis, pending, non terminée, non verrouillée, fenêtre non dépassée ; formulaire `confirm()` navigateur. |
| Endpoint Pro | `pro/web/ec/modules/tunnel/start/ec_start_script.php:6029-6037` | POST `extranet/start/script`, `frm_mode=session_delete`, autorité client/contact de la session PHP. |
| Suppression avant démarrage | `global/web/app/modules/jeux/sessions/app_sessions_functions.php:3328-3451`, `app_session_delete_canonical[_locked]` | Verrou client/date, relecture, propriétaire, garde is_locked ; nettoyages selon jeu ; membership désactivé avant suppression physique ; ajustements offre/pipeline existants. |
| Suppression physique | même fichier `:3457-3485`, `app_session_supprimer` | DELETE session et lots propres, journal client. La désactivation du membership conserve sa ligne ; ce n’est pas un DELETE du membership. |
| Membership | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:275-287,2918-2969`, `app_games_hub_sessions_get` | Statuts active/inactive ; SELECT joint uniquement les memberships actifs ; ordre date/heure/position/id conservé. |
| Mappings | même fichier `:6340-6389`, `app_games_hub_players_stats_mappings_load` | Lecture bornée aux sessions fournies et aux joueurs Hub ; contributions active/completed, id_participation positif et résolution participant_key. `left` exclu. Le retrait de membership n’est pas une neutralisation automatique de ces lignes. |
| Rebuild nominal | même fichier `:6771-6968`, `app_games_hub_players_stats_rebuild` | Sessions via getter canonique, projection puis écriture transactionnelle stats score/victoires/deuxièmes/troisièmes/participations/date/révision ; valeurs nulles/à zéro recalculables. Aucune suppression de photo dans ce chemin. |
| Dirty | même fichier `:6970-6987,8078-8106` | Mark dirty ne recalcule pas ; dirty/error/schema manquant/lecture impossible peuvent activer le fallback. |
| Fallback non borné | même fichier `:6734-6768`, `app_games_hub_players_stats_legacy_context_get` | Seule option transmise : skip_visual_podiums. Sessions restantes utilisées pour les dates, pas pour une liste d’IDs autorisés. Événement : contexte historique complet de l’événement. |
| Relecture globale | `global/web/app/modules/entites/clients/app_clients_functions.php:4029-4062,5743-5766,5784-5826`, `app_client_joueurs_dashboard_context_compute/get_context_for_period/get_context_for_event` | SELECT championnats_sessions par client/date/événement, démo/configuration/type et fin fiable ; aucune jointure membership actif. L’histoire conservée reste sélectionnable. |
| Agrégat et podium | `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:8120-8215`, `app_games_hub_aggregate_ranking_context_get` | En fallback, reprend aggregate_ranking, leaderboards, stats et display historiques ; enrichit les photos puis dérive Top 3/podium, sans filtrage par sessions membres. |
| Focus | même fichier `:4635-4690`, `app_games_hub_focus_clear` | Membership requis avant clear, comparaison du focus puis UPDATE conditionnel sur la session ; primitive utile, pas un contrat complet de suppression. |
| Présentation | même fichier `:10290-10380`, `app_games_hub_presentation_resolve` | Valide la sélection puis fallback focus/programme/Hub neutre ; ne lance pas une session. Nettoyage persistant et orchestration suppression non validés. |
| Suspendue | `global/web/app/modules/jeux/hubs/app_games_hub_suspension.php:1-43` | Journal conservant la suspension et grant de reprise ; ce contrat n’est pas une destruction du runtime. Invalidation terminale de suppression non trouvée dans ce fichier. |
| Master/Remote | `games/web/modules/app_hub_view_helpers.php:8710`, `games/web/modules/app_hub_remote_ajax.php:1388-1412` | Modales de paramétrage repérées ; Remote conditionne actuellement l’accès par can_edit. Extension tous états non effectuée. |
| Premier lancement | `games/web/includes/canvas/core/launch_confirmation.js:4-5,34` | Ancien avertissement encore présent ; aucun changement de wording appliqué après le blocage. |

## Reproduction isolée du blocage

Exécution des fonctions réelles extraites `app_games_hub_aggregate_ranking_context_get`, `app_games_hub_players_stats_fallback_reason`, `app_games_hub_players_stats_legacy_context_get`, `app_games_hub_aggregate_podium_from_ranking` ; lecteurs persistants/historiques et enrichissement photo remplacés par fixtures. Aucun bootstrap applicatif ni DB. Script et copies raw conservés temporairement dans `/tmp/hub-delete-audit/`.

Fixture : seul membre restant = 102 ; résultat historique de la session retirée 101 conservé ; état persistant dirty. Résultat pour période ET événement :

```text
remaining_members=[102]
returned_source_sessions=[101]
podium_count=1
legacy_options={"skip_visual_podiums":true}
```

Cela prouve l’absence de filtre dans l’orchestration réelle du fallback. Le lecteur historique est simulé dans cette reproduction ; sa sélection non bornée est prouvée séparément par le SELECT réel cité ci-dessus. Ce n’est pas un test E2E ni une observation en base réelle. Même un rebuild immédiatement réussi ne sécurise pas une future activation du fallback. Neutraliser les mappings ne supprime pas les scores runtime historiques lus par ce SELECT.

## Tests exécutés

Depuis n’importe quel dossier, chemins absolus sous `/home/romain/Cotton` :

- `php global/web/tests/hub_players_stats_projection_contract_test.php` : OK.
- `php global/web/tests/hub_stats_pending_session_test.php` : OK (rebuild, dirty, projection vide, Bingo, lectures Master/Remote simulées).
- `php global/web/tests/hub_aggregate_photo_fallback_test.php` : OK (photos, rangs, podium, fallback).
- `php /tmp/hub-delete-audit/reproduce.php` : reproduction du défaut confirmée pour période et événement.

Ces suites valident les contrats existants, pas la nouvelle suppression. Les 50 scénarios demandés ne sont pas déclarés validés : pas de patch, donc pas de recette suppression tous états/surfaces, runtime, concurrence, Play, Quick Schedule ou temporal window. Aucun test connecté, CLI rebuild réel, SQL réel, déploiement, redémarrage, commit ou push.

## Suite nécessaire avant reprise du patch

1. Définir une lecture de résultats Hub bornée aux memberships actifs, y compris fallback, et gérer explicitement l’ensemble vide. Un filtre après agrégation ne peut pas retrancher correctement des contributions déjà fusionnées.
2. Prouver retrait + rebuild + fallback forcé pour soirée/événement, dernière partie supprimée, joueurs partagés, équipes, snapshots et photos, en conservant l’historique Global.
3. Terminer l’audit des cleanups runtime actif/suspendu, exécutions, commandes Remote retardées, autorité serveur et concurrence. Ces invariants ne sont pas certifiés par le présent arrêt anticipé.
4. Seulement ensuite intégrer le retrait canonique, ses trois surfaces, la confirmation dédiée et le nouveau wording, puis exécuter la matrice complète.

## Livraison et limites

Avant démarrage : comportement historique inchangé. Après démarrage : refus historique inchangé ; aucune primitive de retrait complet retenue comme sûre. Membership inactive et rebuild sont des briques réutilisables, mais insuffisantes pour l’invariant M. Runtime actif/suspendu, neutralisation des mappings, snapshots et invalidation de reprise : non implémentés/non certifiés. Les photos d’identité et de résultat sont intactes. UX Master/Remote/Pro et premier lancement inchangés.

Documentation seulement : ce rapport, HANDOFF, TASKS Global/Games/Pro ; index/sitemaps régénérés par le script officiel. README/contrats métier inchangés, aucune fonctionnalité livrée. Risque produit identifié : réapparition des contributions après fallback. Rollback du travail présent : retirer uniquement les ajouts documentaires de cet audit, sans annuler les modifications locales antérieures.

## Patch préparatoire appliqué après l’audit

- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:6744-6752` : relecture `app_games_hub_sessions_get`, construction explicite de `allowed_session_ids`. L’argument historique `$sessions` reste compatible mais n’est plus une autorité pour le fallback ; une liste de rendu périmée ne réintroduit pas les anciennes sessions.
- `global/web/app/modules/entites/clients/app_clients_functions.php:4029-4050` : option détectée avec `array_key_exists`, IDs positifs normalisés/dédoublonnés, clause `AND id IN (...)` ajoutée au chargement initial des sessions. Vide/null = `id IN (0)`. Sans option, la requête conserve son contenu historique.
- Les wrappers période/événement transmettaient déjà les options ; ils ne changent pas. Dates, client, événement, configuration, type et fin fiable restent des restrictions supplémentaires.
- Le moteur ne peut charger que les IDs issus de ce premier SELECT : mappings, participants, scores Quiz/Blind Test, table `blindtest_session_teams`, fallback `blindtest_sessions.podium_json`, grilles/phases/winners Bingo. Aucun filtrage tardif ni modification de scoring.
- Photos : l’enrichissement existant traite uniquement les lignes de ranking déjà produites. Aucune suppression de média, aucune mutation du stockage photo.
- Rebuild nominal `app_games_hub_players_stats_rebuild` inchangé : programme actif → mappings → runtime → projection. Aucun rebuild ajouté pendant le rendu.

## Tests du patch

Deux tests ajoutés dans Global :

1. `web/tests/hub_historical_membership_fallback_test.php` : vraies fonctions historiques (wrappers, contexte, scores, agrégats, équipes table/JSON), vraie orchestration fallback et enrichissement photo ; seuls les accès DB/médias, la lecture du programme, l’état persistant et quelques métadonnées d’environnement sont simulés. Matrice période/événement × Blind Test/Bingo × solo/équipes table/snapshot, deux membres puis retrait puis vide ; joueurs communs, compteurs, score, podium, photos, contexte de rendu périmé, dirty/error/schema/missing/projection_incomplete et chemin persistant sain. Chaque requête de résultat vérifie qu’elle n’élargit pas les IDs sélectionnés initialement. Scoring Bingo historique explicite conservé (fixture une session : 600/400/300).
2. `web/tests/hub_removed_session_fallback_reproduction_test.php` : reproduction originale 101 retirée / 102 restante conservée. Le stub historique respecte désormais l’option transmise ; résultat attendu vide car sa seule contribution était 101. Vérifie aussi `allowed_session_ids=[102]` pour les deux wrappers.

Commandes exécutées depuis le workspace :

```sh
php ../global/web/tests/hub_historical_membership_fallback_test.php
php ../global/web/tests/hub_removed_session_fallback_reproduction_test.php
php ../global/web/tests/hub_players_stats_projection_contract_test.php
php ../global/web/tests/hub_stats_pending_session_test.php
php ../global/web/tests/hub_aggregate_photo_fallback_test.php
php ../global/web/tests/client_joueurs_dashboard_aggregate_ranking_test.php
```

Résultat : six suites OK. Syntaxe PHP des deux fichiers applicatifs et des deux tests OK. `git diff --check` Global/documentation OK. Sitemap/index régénérés via `npm run docs:sitemap`.

Contre-épreuve hors Hub : source Clients avant patch extraite de HEAD dans `/tmp/hub-delete-audit/client-before.php`, puis exécution séparée du même test avec `--compat-only`, une fois avec `HUB_TEST_CLIENT_SOURCE` pointant sur cette source, une fois avec le code modifié. `cmp compat-before.json compat-after.json` retourne 0 : 18 contextes complets identiques, sans option, couvrant compute/période/événement, Blind Test/Bingo et équipes table/JSON. Le mode de fixture remplace les métadonnées calendrier pour rendre la comparaison déterministe ; aucune base réelle.

Documentation actualisée : HANDOFF, TASKS/README Global, présente note, contrat de lecture bridge, CHANGELOG et index générés. Journal/raw rechargés avant patch, journal identique. Aucun chemin ciblé signalé hors workspace.

## Réserves et rollback du patch préparatoire

Aucune recette DB/serveur/navigateur réelle. Une relecture canonique supplémentaire intervient seulement sur le chemin historique (également lors d’une comparaison legacy explicitement demandée), pas sur le classement persistant sain. Le getter existant conserve son comportement, dont son helper de schéma ; aucun DDL nouveau n’a été ajouté ou exécuté ici. Le snapshot de membres est acquis au début de cette lecture ; l’atomicité avec une future suppression concurrente reste au contrat de suppression à implémenter.

Aucune suppression tous états, modification de runtime, commande Remote, focus, reprise, présentation, UI ou wording. Le patch ne remet pas de lui-même à zéro une projection persistante périmée mais déclarée saine : le futur retrait doit toujours invalider/rebuilder cette projection.

Rollback : retirer les deux changements applicatifs Global pour restaurer le fallback antérieur (ce qui réintroduirait le défaut), puis les deux tests et les seules additions documentaires de cette étape ; préserver les modifications préexistantes. Aucun rollback DB ni redémarrage effectué.

<!-- AUTO-UPDATE:END id="hub-session-removal-audit-20260916" -->
