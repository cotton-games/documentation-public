# Hub vide et provenance des sessions retirées — 22/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-empty-pro-navigation-20260922-audit" owner="codex" -->

## Verdict et périmètre

Patch local Global/Pro, non déployé. La navigation Pro confondait session historique et membership courante. Deux cas distincts sont corrigés : Hub conservé avec memberships inactives ; Hub et memberships déjà supprimés, mais sessions et événements de retrait conservés. Aucun DELETE, aucune migration/réparation de données, aucun changement de statut Hub ajouté. Les suppressions complètes préexistantes ne sont pas modifiées par ce patch.

## A. Sources ouvertes, preuve d’abord

URLs RAW consultées (sections effectivement utilisées) :

- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md — « Statut actuel », « Règle preuve d’abord », « Discipline de génération ».
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt — Repos, Project status, Indexes.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.ndjson — entrées repo/status/index ; la réponse web mise en cache portait une autre révision que le téléchargement courant du SITEMAP Markdown.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md — « How to use », « Editing rules ».
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md — « Doc discipline », « Automatisation des index docs ».
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md — « Update triggers », R11/R20, procédure anti-rescan.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md — « Actions réalisées » récentes, contexte de suppression et Quick Add.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/README.md — « Correctif local 2026-09-09 — Quick Add : Hub source autoritaire » : identifiant explicite, résolution interdite dans cette branche.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md — « Hub actif vide : réconciliation transparente — 09/09/2026 », « Quick-add Hub: politiques temporelles explicites » : réutilisation conditionnelle, before/open Dashboard, open Master/Remote.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md — « Supprimer une partie Hub — 16/09/2026 » : retrait, état vide et conservation commerciale.

Comparaison des mêmes chemins avec :

- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/pro/README.md
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/global/README.md
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/games/README.md

Les sections ciblées Quick Add/source, réconciliation vide et suppression sont alignées main=develop ; les fichiers complets diffèrent sur d’autres chantiers. Plusieurs textes portent encore la mention « local non déployé » : cette comparaison documentaire n’est pas une vérification des fichiers servis. Le contrat complet de visibilité demandé était **non trouvé dans la documentation** avant ce patch ; le comportement ci-dessous provient de l’audit du code local.

## B. Contrôle AI Studio avant audit applicatif

https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb — « Fait, livré en PROD », entrées mars à septembre 2026.

Lecture du Markdown brut embarqué dans la réponse du lecteur public (l’ouverture web initiale échouait, téléchargement HTTP réussi). Les modifications externes signalées concernent notamment WWW/campagnes/BO, les scripts Pro authentification/contacts du25/03, Global ecommerce et `global_librairies.php`. Aucun fichier applicatif ciblé ici n’est signalé : **aucun rechargement serveur requis identifié dans ce périmètre**. Ces autres fichiers ne sont pas patchés. Aucun accès SSH/DB/applicatif DEV/PROD effectué ; seules la documentation publique, les copies locales de logs et les sorties phpMyAdmin fournies par l’utilisateur sont exploitées.

## C–D. Suppression actuelle et état final

Sources locales : `games/web/modules/app_hub_master_ajax.php`, `app_hub_view_helpers.php` (dispatch `session_remove`, traitement commande Remote), `app_hub_remote_ajax.php` (commande `remove_session`), `app_hub_removal_helpers.php` ; Global `app_games_hub_removal.php:27–89`, `app_sessions_functions.php:3347–3490`.

- Master : POST `session_remove`, organisateur/instance/CSRF → handler → `app_games_hub_session_remove`.
- Remote : accès/instance/CSRF/présence Master → commande `remove_session` → exécution dans le poll Master → ACK.
- Il n’existe pas ici de couple de fonctions nommé plan/apply : la validation est refaite dans le service sous verrou Hub.
- Pending : suppression individuelle canonique, verrou client/date et Hub, membership inactive, suppression de la ligne session via le service existant.
- Suspendue libérée/terminée : journal durable `hub_execution_removed` (`event_id=hub-remove-H-S`, `session_id` = token source), membership inactive, rattachements joueurs-session `left`, présence runtime retirée, commandes lancement/sélection annulées, présentation correspondante effacée, statistiques dirty/rebuild, révision, puis `hub_removal_completed`. Intent avant étapes rejouables ; pas de transaction globale promise sur les anciennes tables.
- Focus actif/running : refus ; la dernière suppression autorisée ne désactive pas le Hub. Les joueurs Hub, résultats source, suspensions, logs, lots, branding et publication restent conservés. La projection du classement courant est recalculée avec les membres restants.
- `flag_active`/`hub_status` définissent disponibilité technique ; `app_games_hub_temporal_state` définit la fenêtre ; les lecteurs de publication/QR ont leur propre politique. Aucun de ces états n’était un prédicat général de visibilité Pro.

## Preuves terrain fournies pendant l’audit : client10 / Hub343

Les heures ci-dessous sont celles des traces/sorties reçues, sans extrapolation d’horloge serveur.

1. Sortie phpMyAdmin fournie : zéro Hub pour client10 au22/09/2026 ; sessions27934–27937 encore présentes, officielles/configurées, mais LEFT JOIN memberships entièrement NULL.
2. Sortie `game_events` fournie : intent/done pour27934 à08:59:14 (IDs369392/369393),27937 à09:29:14 (369607/369608),27935 à09:29:18 (369609/369610),27936 à09:29:21 (369611/369612).
3. `pro/logs/error_log:37`,22/09/2026 09:29:57 : `hub_delete_completed`, hub343, client10, `deleted_sessions=0`.
4. `pro/logs/error_log:41–43,49–50` : `hub_program_resolution_failed`, `missing_memberships`, candidats27934–27937 ; encore présent à10:23:32. `pro/logs/access_log:92–124` montre retours Home/Agenda/Dashboard.
5. Capture utilisateur10:36 : Programme4 parties (3 suspendues,1 terminée), accès « Indisponible ».

**Cause composée démontrée** : retraits des quatre parties → suppression complète du Hub déjà vide → disparition des memberships → reprise des lignes historiques comme candidates legacy par les lecteurs Pro. `app_games_hub_delete_complete` ne sélectionne que les membres actifs, puis supprime toutes les relations et la racine (`app_games_hubs_functions.php`, fonctions `delete_member_sessions_get` et `delete_complete`, environ3918–4160). Les sources retirées ne sont donc pas effacées par cette suppression. Les logs démontrent l’exécution de ce service, pas le geste UI précis. Aucun indice de réactivation des memberships dans ces GET : c’est une résurrection de l’affichage ; la racine Games a réellement disparu.

Les copies de logs contiennent aussi un défaut de dépendance du simulateur Blind Test, indépendant et déjà traité dans un autre chantier ; aucun glue/runtime n’est modifié ici. Aucun log brut, token, adresse IP ni capture contenant ces éléments n’est recopié dans cette note.

## E–F. Lectures et fallbacks Pro

| Surface | Source avant patch | Correction |
|---|---|---|
| Home, soirée/événement | `ec_home_next_sessions_day_summary_get`, SELECT `championnats_sessions`, prochaine date, fallback dernier jour utile, puis `existing_for_program` ; si Hub vide, anciennes sessions conservées | prédicat partagé avant date/compteurs/LIMIT ; programme canonique vide ne retombe plus sur la liste initiale |
| Agenda courant/archives | `ec_start_sessions_list.php`, SELECT sessions, dates paginées, qualification archive puis groupe par date, expansion des membres actifs | même filtre avant pagination ; pas de repli vers ancien groupe quand la relecture Hub est vide |
| Home/Agenda réseau TdR | jointure sessions/clients via `id_client_reseau` | même filtre corrélé à la session et au propriétaire Hub |
| First-party, prochain jour officiel, aujourd’hui | `ec_first_party_helpers.php`, lignes officielles/configurées/online | filtre partagé sur futurs/aujourd’hui ; historique utile conservé |
| `has_visible_official_session` | `app_client_has_visible_official_session_signal` | filtre en mode visibilité ; mode historique utile explicite conservé |
| Dates occupées et pivots proposés | sessions par date, événements gérés conditionnés à présence de sessions | filtre des candidats navigables ; compte brut de conflit de déplacement inchangé par défaut |
| Dashboard/page par date | SELECT legacy puis `app_games_hub_existing_for_program`; échec = anciennes cartes sans accès Hub | filtre de la liste initiale ; résolution d’un Hub techniquement existant vide toujours autorisée |
| Bibliothèque, proposition de Hub par date | Hubs actifs puis `ec_start_library_schedule_hub_candidate_is_compatible` exigeant un membre officiel/configuré | déjà excluant les programmes vides ; inchangé |
| Anciennes pages événements | `ec.php:33` redirige list/view/form vers Agenda ; ancien widget événement absent de la branche Home courante | pas de patch de code mort |
| Résultats/historique joueurs | lecteurs historiques dédiés, option `allowed_session_ids` pour agrégats Hub | inchangés, aucune purge ; disparaître des groupes Agenda n’efface pas le passé |

Les sources de date/compte/contexte/opération restent utilisées pour les vrais parcours autonomes. Une membership inactive, orpheline, liée à un Hub inactif/deleting ou étranger ne devient plus une preuve d’autonomie. La trace durable de retrait couvre également le cas où toutes les memberships ont disparu.

## G–H. Dashboard vide et Quick Add

`ec_start_sessions_day_dashboard.php` inclut le même contrôleur que la route par date. Après filtrage des anciennes sessions, `app_games_hub_existing_for_program` peut toujours résoudre l’unique Hub actif de la date avec une liste vide. Aucun garde « zéro session = inaccessible », redirect automatique, writer ou reconstruction de membership n’est ajouté.

Le programme reste vide, les révisions/polls existants fonctionnent et le formulaire Quick Add conserve son `id_hub`. Le contrôleur `start_dashboard_quick_program_context_get` revalide la source et prend sa date/contexte/opération ; la branche explicite ne passe jamais dans `get_or_create`. Le service dédié Dashboard permet before/open, sous les autres gardes existants ; expired/invalid ne sont pas rouverts. Les defaults mode/format s’appliquent lorsqu’aucun membre ne donne de majorité. Le retour garde la date source et le rattachement rejoint H.

Une URL connue reste utilisable pour un Hub vide existant, sans session utilisateur propriétaire. Un Hub **physiquement supprimé**, comme343, ne peut pas être restauré par ce patch : l’URL ne ressuscite plus les cartes. Plusieurs Hubs ambigus à la même date restent soumis au refus existant ; aucune nouvelle règle de choix n’est inventée.

## I. Resolver standard : audit et limites conservées

- `app_games_hub_get_or_create_for_context` : réutilise le Hub actif de contexte exact, y compris vide ; sinon crée, ou refuse ambiguïté/conflit. Sa réconciliation legacy ignorait déjà les memberships inactives existantes ; elle ignore désormais aussi les sessions avec intent durable de retrait lorsque ces memberships n’existent plus.
- SchedulePlan (`app_schedule_plan_empty_hub_check`, `target_hub_resolve`, `commit`) : Hub explicite revalidé ; sans cible, unique racine vide compatible réutilisée, sous verrou client/date puis Hub. Programme non vide, contexte/opération différents, exécution ouverte ou commande Remote non QR pending refusés. Création avec `skip_reconcile=true` si aucune racine.
- **Complément Quick Schedule corrigé après recette :** le comptage des sessions officielles utilise désormais le prédicat partagé de navigation. Les sources retirées n’occupent plus la date ; les vrais programmes autonomes la bloquent toujours. Le comptage brut des memberships actives reste autoritaire, même si la session est absente/mal configurée. Les retraits avec `hub_execution_removed` et `hub_removal_completed` concordants clôturent uniquement l’exécution/source correspondante pour ce garde ; intent seul, ACK absent, identité incohérente, exécution ouverte ou commande non QR en attente refusent la réutilisation. Le Hub vide compatible est réutilisé sous les verrous existants, avec le même contexte/opération et sans réactivation historique.
- Réutiliser H conserve joueurs, lots, branding, publication, participations probables et données historiques ; le risque de conserver un ancien contexte est réel et a été signalé avant patch. Les résultats courants restent bornés aux membres actifs. Aucun nettoyage de focus ou d’annexes n’est ajouté.
- Quick Add depuis Dashboard vide demeure un chemin explicite distinct de cette programmation sans cible.

## J–L. Architecture retenue et fichiers applicatifs

Nouveau module pur `global/web/app/modules/jeux/hubs/app_games_hub_pro_navigation.php` :

1. `app_games_hub_session_not_removed_sql(alias)` : absence d’événement `hub_execution_removed` pour le token source. Réutilise le journal existant, sans nouveau champ ni écriture ; en l’absence de membership courante, l’intent suffit pour éviter une résurrection pendant un retry incomplet.
2. `app_games_hub_pro_navigation_session_sql(alias)` : **membership active dans Hub actif/non deleting du même propriétaire**, OU **aucune membership et aucune trace de retrait**. Un membre courant actif reste autoritaire ; une session vraiment autonome n’est pas masquée. Alias validé, prédicats SQL corrélés, aucune boucle N+1 ni cache d’état.
3. Le premier prédicat protège aussi la sélection de candidats de `app_games_hub_sessions_reconcile`, sans changer les règles d’identité du resolver.

Global : nouveau module ci-dessus ; `app_games_hubs_functions.php` (chargement + réconciliation) ; `app_clients_functions.php` (signal visibilité).

Pro, sous `web/ec/modules/` : `tunnel/start/ec_first_party_helpers.php`, `ec_start_sessions_day.php`, `ec_start_sessions_day_helpers.php`, `ec_start_sessions_list.php` ; `widget/ec_widget_client_lieu_sessions_agenda.php`.

Games : aucun fichier applicatif modifié. Master/Remote conservent leur accès par token et Quick Add explicite en fenêtre live, ainsi que leur programme vide commercial. Pas de nouvelle UX, aucun moteur/WS/score/suspension/démo modifié.

Les résumés Home et Agenda sont calculés par requête ; caches statiques de détail/jeu/qualification archive limités à la requête PHP, sans cache persistant identifié à invalider. Dashboard utilise la révision/poll existante. Les relectures voient naturellement le nouveau membre après ajout ; une course inter-requêtes ne constitue pas une promesse de snapshot transactionnel global.

## M. Tests locaux

Nouveau `global/web/tests/hub_pro_navigation_test.py` : exécute les vrais lecteurs PHP Home, Agenda (sélection/groupement), first-party, dates, signal client, début du contrôleur Dashboard et réconciliation, avec transport de requêtes vers des **fixtures SQLite en mémoire**. Aucune connexion MySQL ni bootstrap applicatif. Doubles uniquement pour lookups Hub, état runtime, médias et I/O ; ce test ne valide pas les plans MySQL, l’auth HTTP ou les verrous réels.

49 contrôles,148 SELECT : retrait partiel/total, retry, Home/Agenda/TdR, prochaine date/pagination, Dashboard vide sans marker, course dernière suppression→relecture Home, nouveau membre même Hub, historique terminé non vidé, mode historique utile, Hub inactive/deleting/étranger, membership orpheline, autonome et démo, Hub/memberships physiquement absents avec traces de retrait, absence de réattachement par réconciliation. Aucune écriture applicative autorisée dans ce test ; les mutations du scénario sont uniquement celles des fixtures.

Tests mis à jour :

- Pro `ec_start_dashboard_quick_source_hub_test.php` :46 contrôles, ajout des sources vides soirée/événement, date/contexte/opération, création unique et retry sans resolver générique.
- Pro `ec_start_legacy_offer_visibility_test.php` : chargement du prédicat pur dans sa fixture isolée ; visibilité hors Hub inchangée.
- Global `programming_quick_hub_service_contract_test.php` : assertion focus bornée aux services Quick Add ; le garde de renouvellement situé ailleurs dans le même fichier ne constitue pas une écriture du focus. Faux échec reproduit sur sources HEAD avant correction du test.
- Games `hub_empty_commercial_test.php` : initialise la configuration Pro de la fixture ;105 contrôles Master/Remote/Play programme vide. Échec de fixture sans `$conf` reproduit avant correction.

Commandes principales, depuis la racine Cotton :

```sh
python3 global/web/tests/hub_pro_navigation_test.py
php pro/web/ec/modules/tunnel/start/ec_start_dashboard_quick_source_hub_test.php
php global/web/tests/hub_session_removal_test.php
php global/web/tests/hub_historical_membership_fallback_test.php
php global/web/tests/hub_legacy_runtime_compatibility_test.php
php global/web/tests/schedule_plan_empty_hub_test.php
php global/web/tests/schedule_plan_commit_behavior_test.php
php global/web/tests/programming_quick_hub_service_contract_test.php
php global/web/tests/hub_delete_service_contract_test.php
php games/web/tests/hub_empty_commercial_test.php
node games/web/tests/hub_session_removal_dom_test.mjs
php pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php
php pro/web/ec/modules/tunnel/start/ec_start_sessions_list_agenda_test.php
php pro/web/ec/modules/tunnel/start/ec_start_quick_schedule_ui_test.php
php pro/web/ec/modules/tunnel/start/ec_start_library_hub_add_flow_test.php
php pro/web/ec/modules/tunnel/start/ec_start_legacy_offer_visibility_test.php
php pro/web/ec/modules/communication/home/ec_home_standard_composition_test.php
php pro/web/ec/modules/communication/home/ec_home_hub_branding_visual_test.php
node pro/web/ec/modules/tunnel/start/ec_start_dashboard_mobile_refresh_test.mjs
```

Ces suites passent. Test supplémentaire `pro/web/ec/ec_legacy_events_navigation_test.php` : échec préexistant confirmé sur HEAD, assertion d’un ancien marqueur `// Version 14/10/2024` désormais absent ; aucune correction de ce test hors périmètre. Garde de redirection vérifié directement dans `ec.php`. Lint PHP des12 fichiers PHP modifiés/nouveaux et diff-check des4 dépôts verts ; génération documentaire via `npm run docs:sitemap`.178 cibles RAW générées vérifiées contre les fichiers locaux, aucune URL tronquée ni cible absente. Les4 URLs publiques SITEMAP/README Pro/Global/Games répondent200 ; la nouvelle note répond404 tant que cette modification locale n’est pas publiée (attendu, aucune publication effectuée).

## Complément Quick Schedule — recette du 22/09/2026

Logs rechargés : `pro/logs/error_log:73`,11:02:06, `QUICK_SCHEDULE_COMMIT_FAILED`, date22/09/2026, code `DATE_OCCUPIED`. Les nouvelles traces Global rattachent27942 et27943 au Hub345 ; elles ne suffisent pas à elles seules à prouver son état actuel. Aucun accès serveur ou SQL supplémentaire nécessaire au correctif du garde démontré dans le code.

Fichiers supplémentaires : Global `web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`, `web/tests/schedule_plan_commit_behavior_test.php`, `web/tests/schedule_plan_empty_hub_test.php` ; extension SQL réelle du test navigation existant ; Pro `web/ec/modules/tunnel/start/ec_start_script.php` et `ec_start_quick_schedule_ui_test.php`. Chargement explicite du prédicat pur dans le service. Aucun schéma/API publique modifié.

SchedulePlan :68 contrôles, dont16 nouveaux sur sessions historiques retenues, retrait suspendu achevé, identité source/exécution/event/ACK, intent incomplet, membership active mal configurée, source autonome, retrait sans membership, commande pending, session terminée, commit même Hub, historique inchangé et retry. Le test navigation exécute également les nouvelles requêtes SELECT du garde contre SQLite :49 contrôles/148 SELECT (dont jointure intent/ACK et ACK avec mauvaise action). Fixture de politique temporelle pour ces SELECT ; politique canonique couverte par la suite SchedulePlan existante. SQLite adapte REGEXP/CONCAT, sans valider les plans MySQL ni la concurrence réelle.

Le calendrier utilisait déjà le filtre partagé. Le POST est maintenant cohérent ; les Hubs ambigus ont un message distinct, et l’invitation Dashboard exige que la date ait un programme visible. Quick Add explicite reste inchangé. Tests Quick Schedule, Quick Add46, suppression162 et contrat service passent également. Aucune suppression/purge historique, aucun déploiement/restart. Livrer le service Global avec le prédicat du lot précédent et le contrôleur Pro ; vérifier sur serveur retrait pending/terminé/suspendu puis programmation de la même date, retour du programme dans Home/Agenda, identité inchangée et refus dès qu’un membre est actif. Rollback : retirer ce complément code/tests/docs sans réparation DB.

## N. SQL opérateur et réserves terrain

Requêtes READ-ONLY réellement exécutées par l’utilisateur dans phpMyAdmin (résultats décrits plus haut) :

```sql
SELECT h.id, h.id_client, h.hub_date, h.context_type, h.id_operation_evenement,
       h.flag_active, h.hub_status, h.active_session_id, h.presentation_session_id
FROM games_hubs h
WHERE h.id_client = 10 AND h.hub_date = '2026-09-22';

SELECT cs.id AS session_id, cs.flag_session_demo, cs.flag_configuration_complete,
       cs.date, cs.id_operation_evenement, m.id_hub, m.status AS membership_status,
       m.membership_source, m.updated_at
FROM championnats_sessions cs
LEFT JOIN games_hubs_sessions m ON m.id_session = cs.id
WHERE cs.id_client = 10 AND cs.id IN (27934,27935,27936,27937)
ORDER BY cs.id, m.id_hub;

SELECT id, event_id, action, created_at
FROM game_events
WHERE event_id LIKE 'hub-remove-343-%'
ORDER BY id;
```

La décision sur la provenance a attendu ces retours. Aucune requête de réparation et aucune DB réelle exécutée par Codex. Après livraison manuelle : recette des10 cas de la demande, notamment double HTTP, retrait/poll/Quick Add concurrents, before/open/cutoff, sessions suspendues/terminées, soirée/événement/réseau, historique conservé et absence de shortcut. Vérifier les plans/temps MySQL sur volumes réels : le journal est corrélé par `session_id` (index présent dans le snapshot local), sans présumer son indexation réellement déployée. Si journal et memberships sont tous deux purgés, la provenance serait indiscernable d’une vraie session autonome ; aucune heuristique destructive compte/date n’est ajoutée.

Livrer ensemble le nouveau module Global et ses appelants Global/Pro. Aucun déploiement/restart effectué, aucun marker WS touché. Rollback : retirer uniquement les changements listés de ce patch et régénérer la documentation ; aucune donnée à restaurer puisque le patch n’en modifie pas. Le Hub343 déjà supprimé n’est pas recréé.

## Contrat durable

Un Hub sans session métier active n’est plus exposé comme soirée/événement dans les surfaces générales de navigation Pro. Son Dashboard Hub Pro peut néanmoins rester utilisable lorsqu’il est déjà ouvert, afin de permettre l’ajout immédiat d’une nouvelle partie au même Hub via Quick Add. Une fois hors de ce contexte, l’utilisateur repasse par le parcours normal de programmation.

Lorsqu’un Dashboard Hub Pro possède explicitement un Hub source, y compris lorsque ce Hub est temporairement vide, Quick Add conserve cette identité Hub et ne passe pas par une résolution générique susceptible de créer un second Hub.

La présence historique d’une session dans `championnats_sessions` ne suffit pas à rendre cette session membre du programme Hub courant. Les surfaces Pro générales respectent les memberships et la provenance durable de retrait ; leur disparition ultérieure ne transforme pas une session retirée en session autonome.

<!-- AUTO-UPDATE:END id="hub-empty-pro-navigation-20260922-audit" -->
