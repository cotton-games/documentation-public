# Audit de lenteur Hub après photos — 6 septembre 2026

## Conclusion et périmètre

**Audit uniquement ; aucun correctif fonctionnel ni instrumentation installé.** Le remplacement est déclaré fonctionnel par l'utilisateur. Ses fichiers locaux et tests sont préservés.

Sur le Hub **286**, le coût dominant **mesuré côté serveur Master** est le fallback historique du classement, répété tant que la projection reste `dirty` : **3 680–4 614 ms**, médiane **4 222 ms** sur douze rendus, dont **96,65–97,78 %** dans le fallback. Le rebuild incomplet apparaît à **21:47:01**, avant la première trace de fichier photo manquant à **21:52:23**. Cela démontre un ralentissement durable du chemin agrégé, **pas une causalité de l'ajout de photo**. Remote emprunte aussi ce fallback : quatorze occurrences directement attribuables à sa route.

**Photo agrégée absente :** la branche fallback omet l’enrichissement par photo active dans les sources locales, contrairement à la branche fraîche et aux podiums de session (sonde PHP exécutée ci-dessous). Cette omission peut persister à chaque refresh ; payload déployé non capturé.

La comparaison causale « sans photo / upload / avec photo / remplacement » reste incomplète : les logs n'enregistrent ni l'action multipart ni son JSON, et l'absence d'avertissement photo ne prouve pas l'absence de photo. Le coût exact des requêtes SQL internes du fallback, les attentes de session PHP et la date d'application DOM ne sont pas mesurés.

Pour Master/Play, les nouvelles traces montrent une écriture canonique B puis A et une convergence ultérieure des lectures serveur. Le déclencheur navigateur du second POST n'est pas connu. **Lien causal entre la divergence et la lenteur : non établi.** La latence commune allonge plausiblement la fenêtre de divergence, sans expliquer à elle seule une seconde écriture.

## Sources, versions et conservation

Sources RAW rechargées dans l'ordre START → sitemap/index → cartes → manifeste/HANDOFF, copies de lecture dans `/tmp/hub-photo-latency/docs` :

- [START main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), « Statut actuel », « Discipline de génération » : distinction documentation main/develop et vérification hors workspace.
- [SITEMAP develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), « Repos », « Project status », « Indexes » ; SITEMAP.md, README et index Games/Global également rechargés.
- [DOCS_MANIFEST develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers » : HANDOFF/TASKS et génération.
- [Games README develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Update 2026-09-04 - Hub Play: fondation UX/UI de l'entrée joueur », « Update 2026-08-25 - Hub Master: reload et présentation canonique », « Update 2026-08-25 - Hub Master refresh sélection idempotent » : photo identité, présentation commune et restauration silencieuse.
- [Global README develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Update 2026-07-31 - Photo podium active Hub » et « Update 2026-07-30 - Contexte Global Hub léger pour `aggregate_ranking` » : lecteur agrégé Global, fallback dirty/incomplet sans rebuild dans le rendu.
- [HANDOFF develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md), « Games/Global: Hub Play premium, session contextuelle et photo identité — 2026-09-04 » ; cartes TASKS Games/Global et contrat Canvas lus. Le journal public ne contient pas encore les diffs locaux photo de la passe précédente.
- [Audit précédent local](hub-play-photo-replacement-audit-2026-09-06.md) relu. Les archives du **4 septembre** restent les preuves de ce précédent audit ; elles ne servent pas de baseline quantitative pour la recette présente.
- Journal AI Studio à l'URL public_reader fournie : nouvelle lecture HTTP 200, Markdown extrait de `const raw` du lecteur HTML sans exécution ; dernière mise à jour **28/08/2026**. Aucun chemin Hub/photo récent identifié ; changements WWW/AI Studio/campagne Rentrée hors périmètre.

Sources exécutées : **non vérifiables intégralement**. L'accès source SSH/FTP reste indisponible dans cette session (clé d'hôte SSH inconnue, aucun mot de passe enregistré dans les profils FTP). Les sources locales expliquent les noms d'événements et leurs branches, mais ne sont pas présentées comme un hash du code serveur. L'utilisateur confirme le remplacement corrigé en recette et identifie le token Master correspondant à 286 ; son token n'est pas reproduit ici. Les anciens noms fixes encore présents dans les avertissements sont des références de média, pas une preuve suffisante de version du writer exécuté.

État initial : travaux de la correction précédente non commités dans Games/Global/Documentation. Empreintes SHA-256 des cinq fichiers code/tests concernés conservées avant audit et comparées en fin de passe ; aucun changement de ces fichiers. Snapshots des quatre logs courants copiés uniquement dans `/tmp/hub-photo-latency`, sans publication de logs bruts, tokens ou IP.

## Période, horodatages et chronologie

| Source courante rechargée par l'utilisateur | Couverture du snapshot | Nombre de lignes |
| --- | --- | ---: |
| `games/logs/access_log` | 06/09 06:53:34–22:12:26 | 3 092 |
| `games/logs/error_log` | 06/09 06:53:34–22:12:25 | 1 325 |
| `global/logs/access_log` | 06/09 05:42:14–21:45:46 | 317 |
| `global/logs/error_log` | 06/09 05:42:14–21:45:46 | 317 |

Premier snapshot : Games rechargé à 22:03:59, Global à 22:03:52. Second rechargement fourni pendant cet audit : Games prolongé jusqu’à 22:12:26, Global inchangé. Premier snapshot conservé dans `/tmp/hub-photo-latency/snapshot-2203`. Vérification horloge à 22:07:35 Europe/Paris ; réponse utilisateur « il y a quelques minutes ». **Access : +0200 explicite. Error nginx : fuseau non écrit**, +0200 corrélé par les mêmes requêtes aux mêmes secondes. Fuseaux PHP/DB configurés : non trouvé. Global ne contient pas de nouvelle requête HTTP après 21:45:46 ; cela n'exclut pas les appels à sa bibliothèque PHP depuis Games.

| Heure +0200, 06/09 | Preuve Games error_log (ligne) | Ce qui est établi |
| --- | --- | --- |
| 21:45:34 / 21:45:38 | 998 / 1000 : `hub_presentation_session_set`, 27679→27677, raisons `hub_remote_select_session_immediate` puis `hub_remote_select_session` | Écriture Remote puis traitement Master de la même sélection ; aucun délai DOM mesuré |
| 21:45:38 | 1003 : `hub_master_full_reload_profile total_ms=74`, `should_load_aggregate=0`, trois sessions, un joueur | Baseline avant fin de partie, pas une baseline prouvée sans photo |
| 21:47:01 | 1066 : `hub_paper_execution_completed` session 27677, puis `hub_players_stats_rebuild_incomplete`, `ok=true`, `updated=1`, `players_total=1`, `mapping_without_result_count=1`, `duration_ms=105`, `INCOMPLETE_RUNTIME_RESULTS` | Un mapping n'a pas de contribution résultat ; le hook marque la projection dirty |
| 21:47:06 | 1068 : Remote `hub_aggregate_ranking_persistent_fallback`, `reason=projection_dirty`, `read_ms=5` | Remote entre dans le même fallback |
| 21:47:14 | 1072 : `total_ms=3827`, `aggregate_historical_fallback_ms=3742`, lecture persistante 4 ms | Coût historique dominant dès avant la première trace photo |
| 21:48:12 | 1088 : total 4420 ms, fallback 4296 ms | Ralentissement répété |
| 21:51:21 | 1132 : présentation 27677→27678, `master_program_select`, runtime actif 0 | Écriture canonique B |
| 21:51:39 | 1139 : présentation 27678→27677, `master_program_select`, runtime actif 0 | Véritable seconde écriture canonique A, pas seulement affichage ancien |
| 21:52:23 | 1149 : premier `[missing_local_file] media=hub-player-286-414-podium-active.jpg` | Joueur **414**, stockage Blindtest ; date du premier ajout non prouvée |
| 21:52:41 | 1155 : total 4614 ms, fallback 4509 ms | Chemin historique toujours dominant |
| 21:59:57 | 1213 : total 3975 ms, fallback 3864 ms ; access 2659 GET Master 200, puis 2660–2661 POST Master 499 | Rendu lent et abandons clients à la même seconde ; cause des 499 inconnue |
| 22:00:40 | 1222 : dernière trace de l'ancien fichier absent ; access 2683 POST Play 200, 417 octets | **Candidat remplacement**, sans corps POST/JSON pour le certifier individuellement |
| 22:00:46 | access 2688 : POST Play 200, 1776 octets (1753 auparavant) | Changement de taille de réponse, contenu et application inconnus |
| 22:00:50 | 1226 : total 4559 ms, fallback 4456 ms ; access 2689 GET Master 200 | Ralentissement persistant après le candidat remplacement |
| 22:00:55 | 1227 : fallback Remote ; access 2690 POST Remote 200, 2133 octets | Lecture Remote ; aucune mesure durée complète ni application UI |
| 22:03:58 | 1250 : `projection_dirty`, `read_ms=5` | Projection encore dirty en fin du snapshot |
| 22:06:28 | 1270 : présentation 27677→27678, `master_program_select`, actif runtime 0 | Nouvelle sélection après remplacement signalé |
| 22:06:33 | 1273 : total 4203 ms, fallback 4090 ms | Coût du même ordre, pas d’augmentation supplémentaire démontrée |
| 22:12:09 | 1320 : présentation 27678→27679, `master_program_select`, actif runtime 0 | Dernière sélection de recette |
| 22:12:25 | 1325 : total 4182 ms, fallback 4081 ms, dirty persistant | Convergence encore lente ; aucune nouvelle erreur de fichier photo |


Les douze profils lents Master ont des totaux 3827, 4420, 4316, 3865, 4424, 3680, 4241, 4614, 3975, 4559, 4203, 4182 ms. Le profil commence **dans le chargement du contexte Hub**, après bootstrap PHP/session, et termine au shutdown : il exclut l'attente avant ce point, le transfert réseau et le DOM.

Comparaison à périmètre raisonnablement stable (Hub 286, trois sessions, une terminée, un joueur) :

| Fenêtre | Occurrences fallback | Médiane `read_ms` persistante | Interprétation |
| --- | ---: | ---: | --- |
| 21:47:01–21:52:22 | 51 | 4 ms | Fallback lent déjà présent ; absence de photo non démontrée |
| 21:52:23–22:00:39 | 66 | 5 ms | Ancienne référence manquante ; stabilisation de photo non prouvée |
| 22:00:40–22:03:58 | 27 | 5 ms | Après candidat remplacement, dirty persiste ; un profil Master à 4,559 s |

**211 événements fallback** jusqu’à 22:12:25, et non 211 uploads : 125 attribuables à Play, 12 à Master, 14 à Remote, 60 avec route tronquée. Le premier snapshot comptait 144 événements ; le dernier rechargement ajoute 67 occurrences et aucun nouvel avertissement photo. `read_ms` mesure uniquement le lecteur persistant, **pas** les 3–4 secondes suivantes. Avertissement photo 414 : **127 messages dans 65 lignes**, de 21:52:23 à 22:00:40. Plusieurs lignes stderr sont tronquées, ce qui limite les corrélations et les comptages. Aucun ID nouveau de média, timing d'upload, GET image, durée nginx/upstream ou identifiant partagé navigateur/serveur dans ces logs. Comparaison causale avant/après photo : **non disponible**.

## Chemins partagés, coûts et invalidations

### Fallback durable : confirmé et mesuré

- `games/web/includes/canvas/php/boot_lib.php:302` : `mapping_without_result_count > 0` ou résultats ambigus entraîne `app_games_hub_players_stats_mark_dirty(..., AUTO_REBUILD_INCOMPLETE)` même si le rebuild répond `ok=true`.
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:6568` : chaque mapping retenu sans contribution devient `NO_RUNTIME_RESULT_FOR_MAPPING`. Le sous-motif réel de 414/27677 (score nul, données tardives, mapping obsolète, résultat papier, etc.) est **non trouvé sans état DB** ; ne pas déclarer artificiellement cette projection fraîche.
- `app_games_hub_aggregate_ranking_context_get:7936` : dirty → `app_games_hub_players_stats_legacy_context_get:6604` → `app_client_joueurs_dashboard_get_context_for_period:5743` → `app_client_joueurs_dashboard_context_compute:3875` dans `app_clients_functions.php`.
- Le fallback reconstruit les statistiques et classements client/période (tous les jeux autorisés, pas uniquement le Top 3 demandé par Remote). Il utilise notamment une sélection `championnats_sessions` filtrée par client/date, des lectures runtime et des agrégations PHP. `skip_visual_podiums=true` saute la construction des podiums visuels ; **pas** le calcul des classements. Requête SQL dominante et plan d'exécution : non mesurés ; aucune attribution arbitraire des 4 s au SQL, au CPU ou à un appel photo.
- Le rendu ne lance aucun rebuild de statistiques. La projection reste dirty faute de nouvelle consolidation probante ; il s'agit de calculs de secours répétés, pas de 211 écritures/rebuilds.

### Effet d'une photo sur les surfaces : confirmé dans les sources locales

- Writer photo, `app_games_hubs_functions.php:7752` : après bascule active, `UPDATE games_hubs SET date_maj=NOW()`. Aucun `stats_dirty_at` modifié par ce writer. Resize/crop/consentement/suppression sont des coûts ponctuels ; ils ne s'exécutent pas au poll. Leur durée réelle est non trouvée.
- Master : `games_hub_preparation_revision:433` inclut `date_maj`. `hubMasterPreparationRefresh` (helpers:10758) vérifie la révision puis **GET toute la page** ; le navigateur ne remplace que programme, lots et zone centrale. Une simple photo peut donc entraîner une reconstruction serveur complète incluant l'agrégat lent. Garde `inFlight` + cadence 5 s conservés.
- Play : `games_hub_light_context_options_for_action:174` donne à `current_player` et `active_launched_session` sessions, branding, lots, résultats de sessions et agrégat. Ces polls reconstruisent le contexte sans attendre une révision photo. Poll présentation 3,5 s, garde in-flight ; l'espacement entre réponses inclut travail serveur/réseau, ce n'est pas un chronomètre d'affichage.
- Remote : `app_hub_remote_ajax.php:256` charge `app_games_hub_render_context_get(load_aggregate=true, aggregate_ranking_limit=3)` pour `business_snapshot`. Le reader persistant sélectionne aussi les colonnes photo ; **branche fraîche**, la conversion des lignes résout les médias puis `games_hub_remote_aggregate_project:179` élimine ces champs du payload final. **Branche dirty observée**, le fallback saute les podiums visuels et les quatorze lignes Remote n'ont aucun avertissement photo : le coût partagé établi est l'agrégat, pas un téléchargement d'image Remote.
- `app_games_hub_remote_business_revisions_get:876` inclut `date_maj` dans les révisions préparation/résultats (pas directement dans runtime). `businessRevisionChanged` → `refreshBusinessSnapshot` (Remote:2642) reconstruit le snapshot après changement de l'une d'elles. `control_poll` reste un chemin de contrôle distinct ; ses timings complets ne sont pas journalisés ici.

### Répétitions photo, lecture qui écrit et verrous

- `app_games_hub_player_active_photo_from_row:7472` appelle `upload_get_detail`; `app_session_results_podium_photo_src_from_media` (`sessions/app_sessions_functions.php:1496`) appelle de nouveau `upload_get_detail`. **Deux SELECT média par résolution avec photo**, sans mémo dans ces helpers. La lecture par identité ajoute un SELECT joueur ; chaque ligne de podium session ajoute son JOIN mapping/joueur. Donc trois requêtes de ces helpers par ligne session photographiée, hors schéma/contexte ; répétées pour une même identité sur plusieurs podiums. Total réel par requête non instrumenté.
- Le resolver image essaie plusieurs `file_exists` locaux puis renvoie une URL de fallback et logue si aucun chemin n'existe. **Aucun HTTP sortant dans ce resolver** ; renvoyer une URL ne la télécharge pas. Répertoire réseau monté ou coût réel des stat : non trouvé.
- Play peut toucher `last_seen_at`/`updated_at` lors de la résolution d'identité (branche guest / helpers:2841, `app_games_hub_player_touch:5691`). Remote inclut `MAX(COALESCE(last_seen_at, updated_at, created_at))` dans sa révision résultats. **Chemin local de réinvalidations sans changement de score démontré**, mais fréquence effective non mesurée (ni contenu des révisions ni association session PHP dans les logs). Le rendu agrégé lui-même ne réécrit pas `date_maj`; pas de boucle infinie photo démontrée.
- `.htaccess` route Master/Play/Remote vers `games_ajax.php`, qui appelle `session_start()` ligne 35. Pas de `session_write_close` trouvé dans Games ni les helpers Global inspectés. Un handler verrouillant **et un même cookie de session** peuvent sérialiser ces surfaces, upload inclus. Configuration serveur/session_id et attente de verrou non disponibles : blocage plausible, **pas prouvé**. Le profil Master commence après ce point.
- Schémas locaux Hub player/mapping en MyISAM ; moteur réel, attente DB, saturation workers/FPM et file d'attente : non trouvés. Les 499 indiquent des requêtes abandonnées, sans preuve du motif. Ne pas conclure à une saturation.
- Le dernier correctif `podiumPhotoGeneration` est borné à `renderIdentityPhoto` ; présentation, classement, lots et routage sont traités par les callbacks comme avant. Il ne suspend ni ne ralentit les autres projections. Coût navigateur des images (octets, décodage, rendu, cache HTTP) : non mesuré et distinct du temps PHP dominant.

## Présentation Master/Play : écritures et lectures

| Écriture canonique (error Games) | Lectures serveur suivantes | Limite |
| --- | --- | --- |
| 21:51:21, l.1132 : 27677→**27678**, `master_program_select`, actif runtime **0** | Remote 21:51:26 l.1133 ; Play 21:51:30 l.1134 ; Master 21:51:35 l.1135/1136 | 5/9/14 s entre timestamps, pas délai clic→écran |
| 21:51:39, l.1139 : 27678→**27677**, même raison, actif **0** | Remote 21:51:45 l.1140 ; Master 21:51:49 l.1141/1142 ; Play 21:51:54 l.1144 | 6/10/15 s ; Play lit encore B à 21:51:39 l.1138, avant la seconde ligne d'écriture |
| 22:06:28, l.1270 : 27677→**27678**, actif **0** | Master 22:06:33 l.1271–1273 ; Play 22:06:37 l.1274 ; Remote 22:06:42 l.1276 | 5/9/14 s ; pas de retour sur A ensuite dans les logs |
| 22:12:09, l.1320 : 27678→**27679**, actif **0** | Remote 22:12:16 l.1321 ; Play 22:12:20 l.1322 ; Master 22:12:25 l.1323–1325 | 7/11/16 s ; access 3083/3084/3090 HTTP 200 aux mêmes secondes |


Les deux dernières sélections corroborent le ressenti de suivi lent déclaré par l’utilisateur sur les trois surfaces. Le coût du rendu Master reste comparable aux observations antérieures à 21:52:23 ; la photo peut provoquer une invalidation supplémentaire, mais aucun coût marginal de photo n’est isolé. La présentation canonique a réellement changé ; le focus runtime reste nul. Le retour sur A n'est donc pas réductible à un ancien document appliqué côté Master. Les logs ne révèlent ni `event.isTrusted`, ni clic, ni séquence de requêtes navigateur : une intention humaine, un handler rejoué ou un POST ancien retardé ne sont pas départageables.

Hypothèse UI distincte : `hubMasterPreparationRefresh` capture sélection/intention avant `fetchFreshDocument`, remplace ensuite les blocs sans comparer une génération de sélection au retour. Une sélection pendant le GET peut rencontrer un document/intention plus ancien. Mais `restoreSelection` pose `data-hub-skip-presentation-persist=1`, et le handler `selectCard` respecte `persistPresentation=false` : ce seul restore ne prouve **pas** l'émission du second POST. Application tardive DOM : ouverte, pas démontrée ici. Les lectures finissent par converger sur A ; divergence persistante B au-delà de 21:51:54 non prouvée.

## Photo agrégée absente : écart entre les deux chemins de lecture

Dernier constat utilisateur : photo visible avec retard sur le podium de session Master, toujours absente du podium agrégé ; avant le passage du Top 3 session au Top 3 agrégé, affichage déclaré stable et rapide. Ce témoignage oriente la recherche mais ne constitue pas une mesure avant/après à contexte identique.

**Défaut démontré dans les sources locales :** `app_games_hub_aggregate_ranking_context_get` (Global hubs, ligne 7936) enrichit les photos via `app_games_hub_stats_rows_to_aggregate_ranking` (7844) seulement lorsque la projection est fraîche. En `projection_dirty`, il reprend le classement historique tel quel, puis construit le podium. `app_games_hub_players_stats_legacy_context_get` (6604) appelle le contexte client avec `skip_visual_podiums=true`. Dans `app_clients_functions.php`, `app_client_joueurs_dashboard_context_compute` (3875, construction des participants vers 5630) produit identités et statistiques sans photo ; `app_client_joueurs_dashboard_aggregate_ranking_from_leaderboards` (2541) initialise `photo_src` vide et ne copie qu'une éventuelle photo déjà fournie. Aucun enrichissement par photo active Hub sur cette branche.

Au contraire, Games `games_hub_get_context_from_request` (appel d'enrichissement vers ligne 318 de `app_hub_view_helpers.php`) utilise `app_games_hub_session_result_context_enrich_active_photos` (Global 7583) pour les podiums de session. Le podium agrégé Games reprend `photo_src` (helper vers 728), et le renderer vers 8179 ne crée une image que si cette source est non vide. Répéter le refresh ne répare donc pas une photo absente du résultat serveur ; ce défaut ne nécessite aucune hypothèse de cache ou d'URL inchangée.

**Sonde PHP exécutée**, fonctions réelles chargées, lectures DB et résolution média simulées, fixture de participant reproduisant la forme sans photo du contexte client :

```text
projection fraîche : source=hub_persistent_stats, photo=/fixture-new-photo.jpg, resolver appelé 1 fois
projection dirty   : source=historical_fallback, photo="", resolver appelé 0 fois
podium de session  : photo=/fixture-new-photo.jpg
```

Commande : `php /tmp/hub-photo-latency/photo-fallback-probe.php`. Assertions sur la présence en branche fraîche et l'absence en branche dirty réussies. Il s'agit d'une reproduction isolée du défaut local, pas d'une lecture de la BDD ni d'une recette navigateur. Les 211 fallbacks du Hub 286 établissent que la branche concernée est exécutée en recette ; son JSON exact et la concordance des sources déployées restent non vérifiés. Lien entre branche lente et omission photo démontré localement, très cohérent avec les observations ; lien avec la réécriture canonique de présentation toujours non établi.

**Historique ciblé :** Global `e98db4d` (30/07, 17:38:13 +0200) introduit le lecteur agrégé et son fallback ; `154137f` (31/07, 10:30:35 +0200) ajoute la photo active aux sessions et à la conversion des statistiques persistantes, sans ajouter l'enrichissement du fallback. Games `e34d406` (04/09, 16:59:19 +0200) retire la preuve par podium de session, introduit l'accès photo par identité/classement agrégé et ajoute `aggregate=true, force_aggregate=true` aux actions d'accès/upload photo. L'ancien défaut de lecture est donc antérieur au changement de règle, qui ajoute une dépendance explicite au calcul agrégé pour ces actions. Dates de commits locaux, **pas des preuves d'heure de déploiement**. Une stabilité antérieure avec projection fraîche est compatible avec ces chemins, sans être prouvée par les logs disponibles.

## Suite autorisée — correctifs locaux appliqués

1. **Photo absente : enrichir également le classement historique avec la photo active Hub**, après le calcul canonique et avant la dérivation du Top 3/podium, par identité Hub exacte (lecture groupée), sans toucher aux rangs, scores ou critères d’éligibilité. Ne jamais rattacher une photo par seul pseudo ; identité ambiguë ou étrangère au Hub : aucune association. Couvrir branche fraîche/dirty et A→B→C après polls/reload. Ce correctif de lecture ne supprime pas à lui seul les 4 s de fallback. **Appliqué localement après autorisation** : `app_games_hub_aggregate_ranking_enrich_active_photos`, lecture groupée limitée au Hub et aux clés `hub-local:<hub>:<player>` exactes, rejet des équipes et identités contradictoires. `hub_aggregate_photo_fallback_test.php` vérifie parité des champs, égalités/rangs/participations, A→B→C et lectures répétées. Aucune modification du writer photo.
2. **Priorité performance : sortir du fallback lent par une consolidation correcte.** Inspecter en lecture seule le mapping 414/27677, diagnostic de contribution, score/état runtime et projection `stats_*`. Le hook natural-end et le collector runtime (`boot_lib.php`, `app_games_hubs_functions.php`) sont le périmètre initial. Si une donnée arrive tard, proposer un retry borné lié à sa publication ; si mapping réellement incohérent, corriger sa résolution. Preuve phpMyAdmin reçue et correctif local appliqué : une participation active sans résultat dans une session non terminée ne produit plus de faux diagnostic incomplet ; ne pas effacer `dirty`, inventer un score ni utiliser une projection incomplète pour le Top 3. Risque : changer silencieusement le classement si l'on contourne le garde au lieu de traiter la source.
3. **Optimisation indépendante, petite et reviewable :** mémo **limitée à la requête** du détail média/résolution photo et option `include_photos=false` pour le snapshot Remote avant résolution (payload déjà sans photos). Périmètre : reader/conversion Global, resolver média et appel Remote ; aucun changement de cadence/routage. Risque : utiliser une valeur mémo ancienne dans la requête d'upload ; invalider après write/delete. Ne pas annoncer que cette optimisation enlèvera les 4 s : le fallback dirty reste le coût dominant.
4. **Après mesure :** découpler présence et révision de résultats pour éviter qu'un touch joueur relance des snapshots lourds ; conserver les mises à jour roster/compteur via leur signal dédié. Réutiliser éventuellement un résultat de fallback par **révision canonique de résultats**, avec photos enrichies séparément, seulement après définition de toutes les invalidations et de l'éligibilité fraîche. Risque de résultat/Top 3 périmé ; ce cache partagé n'est ni une cause présumée ni un patch prêt dans cet audit.
5. Ne modifier le refresh Master contre une réponse ancienne qu'après reproduction instrumentée. Risque : écraser une présentation volontaire nouvelle en donnant priorité à un intent local ancien. Aucun changement proposé du focus runtime, classement ou polling pour masquer le délai.

## Mesures manquantes et recette courte proposée

**Instrumentation temporaire, proposée uniquement**, limitée au Hub 286 et à quelques minutes :

- Identifiant de requête aléatoire commun navigateur/PHP ; rôle/action, horodatages entrée PHP, avant/après `session_start`, début/fin contexte, début/fin fallback, compte/durée SQL agrégée, compte/durée résolution média/stat, révisions lues/renvoyées. En nginx si disponible : `request_time`, `upstream_response_time`, `upstream_header_time`. Aucune donnée d'authentification, contenu photo ou pseudo.
- Upload : session/identité numériques, ancien/nouveau ID média, étapes validation/traitement/consentement/bascule, date de commit, code et statut. Lectures suivantes : ID média/révision, sans URL tokenisée.
- Master/Play/Remote : `performance.now()` à émission/réception/application, présentation et génération capturées/appliquées ; pour les sélections `isTrusted`, source handler et ID requête. Les logs console perf existants Master sont limités à localhost/127.0.0.1/*.local : ne pas présumer qu'ils existent sur `games.dev` ; fournir un opt-in DEV temporaire. Network/HAR expurgé pour GET image et requêtes métier.
- DB en lecture seule : mapping, contribution manquante, projection et état runtime ; pas de données personnelles ni de write/rebuild de production pendant la mesure.

Recette (≈2–3 min) : même Hub, mêmes trois fenêtres/navigateurs et même visibilité ; noter le partage éventuel de session. Observer 20 s sans action, sélectionner B une seule fois et attendre 15 s ; ajouter/remplacer photo A, attendre 20 s ; remplacer B puis attendre 20 s ; sélectionner A puis B pendant un refresh en cours. Capturer POST+réponse+application et GET image. Pour un véritable « premier ajout » comparatif, utiliser une identité de test Top 3 sans photo sans supprimer celle validée. Refaire seulement la séquence sélection avec session PHP distincte si les mesures montrent une attente de session. Les conclusions doivent séparer attente serveur, temps de calcul, transfert et rendu.

## Livraison et validation

Documentation seule : présente note, HANDOFF et TASKS Games/Global mis à jour dans les entrées photo existantes ; README Games/Global précisés : obligation d’enrichissement inchangée, écart connu du fallback documenté, pas de CHANGELOG fonctionnel. Sitemap/index régénérés par `npm run docs:sitemap`, relus/validés. Analyse reproductible des snapshots en `/tmp/hub-photo-latency` ; comptages et profils recalculés, code/tests photo vérifiés inchangés. Sonde PHP isolée fraîche/dirty/session exécutée ; aucune validation de bout en bout. Aucun déploiement, aucune instrumentation installée et aucun test navigateur prétendu pour cette passe d'audit.

## Passe de correction autorisée — livraison locale

Journal AI Studio relu avant modification (HTTP 200, Markdown décodé du lecteur public, dernière entrée 28/08). Aucun fichier Hub récent signalé. Sources serveur non rechargées faute d’accès opérationnel ; utilisateur sans SSH. Snapshot du fichier Global avant patch conservé dans `/tmp/hub-photo-fix`. Correctif remplacement préexistant préservé.

### Preuve DB reçue de phpMyAdmin DEV

L’utilisateur a exécuté les deux SELECT de lecture sur `dev_cotton_global_0` et transmis :

| Objet | Donnée pertinente |
|---|---|
| Joueur 414, Hub 286 | score agrégé 500 ; 1 participation ; computed/dirty `2026-09-06 21:47:01` ; erreur `AUTO_REBUILD_INCOMPLETE` |
| Mapping 414 / 27677 | `completed`, participation/runtime 220418, score Blindtest 19 |
| Mapping 414 / 27678 | `active`, participation/runtime 220419, score Blindtest 0 |

Aucune clé joueur ou token publiée ici. Les SELECT prennent 0,0002 s et 0,0119 s selon phpMyAdmin : ce sont des diagnostics ciblés, **pas** les temps de rendu. Fuseau de la DB non établi ; la valeur 21:47:01 correspond à l’événement de rebuild dans les logs nginx corrélés +0200.

### Causes et périmètre corrigés

1. `app_games_hub_aggregate_ranking_context_get` omettait la photo active en branche historique. Ajout de `app_games_hub_aggregate_ranking_enrich_active_photos` : lecture groupée limitée aux identités exactes `hub-local:<hub>:<player>` et au Hub courant ; équipes et identités contradictoires ignorées. Résolution via le même helper média que le consolidé, avant dérivation des podiums. Seuls trois champs photo sont enrichis ; aucun tri, score, rang ou participation n’est changé.
2. `app_games_hub_players_stats_projection_from_hub_runtime` classait chaque mapping retenu sans contribution parmi les résultats manquants, y compris la prochaine session active à score nul. Le hook naturel `canvas_api_hub_players_stats_rebuild_after_natural_end` réactivait alors `dirty` après avoir correctement écrit 500 points/1 participation. Le contrôle ignore désormais **uniquement** les absences de contribution d’un mapping `active` dont la session n’est pas explicitement terminée selon le diagnostic existant. Mapping `completed` ou session terminée : anomalie conservée. Les collecteurs, contributions et règles de scores/égalité ne changent pas. Un vrai rebuild depuis les sources est toujours nécessaire pour effacer l’invalidation.

Code de cette passe : **Global uniquement**, `web/app/modules/jeux/hubs/app_games_hubs_functions.php`, `web/tests/hub_aggregate_photo_fallback_test.php`, `web/tests/hub_stats_pending_session_test.php`. Aucun diff Games supplémentaire, writer/remplacement inchangé, aucune migration ni nouveau polling, aucun changement de présentation/routage. Les modifications antérieures du remplacement restent dans les worktrees.

### Tests et mesures

- Rouge avant / vert après : absence de photo dans le fallback ; faux `rebuild_incomplete` provoqué par la session active suivante.
- `php web/tests/hub_aggregate_photo_fallback_test.php` : parité des champs de classement/photo entre les deux branches sur fixture avec égalités ; A→B→C, cinq lectures par version, isolement identité exacte, aucun calcul historique sur dix lectures fraîches.
- `php web/tests/hub_stats_pending_session_test.php` : collecteur Blindtest, projection, rebuild et hook naturel réels avec DB simulée selon les données Hub 286 ; 500 points/1 participation conservés ; arrivée d’un nouveau résultat puis rebuild produit 1000 points/2 participations ; résultat final manquant reste dirty, même si le mapping est encore actif.
- Comparaison instrumentée isolée sur **20 appels du lecteur agrégé**, alternant limite Master 300 / Remote 3 après rebuild : avant **20 fallbacks, dirty=true** ; après **0 fallback, dirty=false**, score/participation inchangés. Ce test utilise la fonction commune, pas les routes HTTP ni une BDD réelle ; aucun gain de temps serveur n’en est déduit.
- Contrats `hub_players_stats_projection_contract_test.php`, `hub_players_stats_rebuild_cli_env_test.php`, `hub_natural_end_stats_rebuild_test.php` verts ; tests remplacement `hub_photo_replace_test.php` et `hub_photo_replace_test.mjs` verts ; lint PHP et diff whitespace vérifiés.
- Référence réelle avant : douze rendus Master 3,680–4,614 s, médiane 4,222 s, 96,65–97,78 % dans le fallback. **Après réel : non mesuré**, aucun déploiement dans cette passe.

### Recette DEV et récupération de la projection existante — à effectuer après livraison

Le patch ne remet pas magiquement à jour une projection déjà dirty. Utiliser le rebuild canonique existant : prochaine fin naturelle effective, ou parcours organisateur appelant `app_games_hub_get_or_create_for_context` → `app_games_hub_players_stats_initialize_if_needed`, ou CLI DEV autorisé séparément. Ne pas faire de SQL pour effacer le marqueur. Une simple lecture Master/Remote ne reconstruit pas les stats, par contrat.

Sur le Hub 286 : vérifier le rebuild complet et les champs stats, puis ouvrir Master/Remote/Play à contexte identique ; constater la disparition des `projection_dirty` répétés et mesurer les nouveaux profils Master + durées réseau Remote. Ajouter/remplacer A→B→C, vérifier URL/GET image, podium session et agrégé sans reload manuel, cinq polls puis reload. Rejouer invalidation légitime avec un nouveau résultat ; vérifier contributions actualisées puis lectures sans fallback. Conserver les cas annulation/refus/hors Top 3 du correctif précédent. La propagation DOM et le gain réel restent à recetter.

Rollback : retirer seulement les deux changements locaux de lecture/diagnostic et leurs nouveaux tests, en préservant le writer de remplacement antérieur. Aucun schéma à restaurer ; le rollback réintroduirait l’omission photo et le faux dirty. HANDOFF/TASKS mis à jour dans leurs entrées existantes, README Games/Global et CHANGELOG actualisés ; sitemap/index régénérés et relus.

## Clarification de la contribution attendue — complément au patch

Journal AI Studio relu avant ce complément : identique au précédent, pas de nouveau chemin Hub. Contrats README raw Games/Global rechargés. La formule précédente « session terminée donc contribution attendue » était trop large : le contrôle original ne lisait aucune preuve de réponse ou de saisie de résultat. Il assimilait l’absence de contribution à une anomalie dès qu’un mapping `active/completed`, avec `id_participation > 0`, appartenait au Hub/session/joueur retenus et que le mapping était completed ou la session explicitement terminée.

### Contrats sourcés et décision métier

- [Global README raw develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Etat 2026-07-13 - Games hubs participation papier persistante » : injection au lancement limitée au papier, création numérique par présence réelle (y compris polling Play/QR/reload), pas preuve de réponse à une question.
- Même raw, « Update 2026-07-30 - Fallback participants runtime pour Hubs historiques » : Quiz/Blindtest entièrement à zéro sans contribution ; Bingo sans résultat de phase sans contribution. **Zéro individuel** ne signifie pas exclusion lorsque la session a un score positif.
- Même raw, « Update 2026-07-30 - Initialisation auto des stats Hub historiques » : mapping runtime exact, `mapping_without_result` documenté, mais aucune distinction explicite non-saisie papier/zéro final dans les champs lus. La simple inscription Hub n’y vaut pas participation.
- [Games README raw develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Update 2026-08-26 - Hub Remote: sas joueurs papier aligné historique + gate Pro » : sas Hub-only, lignes runtime/mappings seulement à l’injection du vrai lancement.
- Ambiguïté exposée à l’utilisateur **avant modification** : papier sans résultat saisi. Réponse explicite : **« Hors classement, sans dirty »**. Cette décision est désormais consignée dans le canon local. Pas de nouvelle distinction inventée entre zéro et champ non saisi pour une seule ligne d’une session partiellement renseignée.

### Matrice avant / après ce complément

| Cas | Comportement avant complément | Après complément / dirty |
|---|---|---|
| Inscrit Hub, jamais joint au numérique, aucun mapping runtime | Pas de contribution attendue, pas d’anomalie | Identique ; pas de dirty lié à ce joueur |
| Joueur présent à zéro, autre score positif dans la session | Classé selon le rang runtime, participation comptée | Identique ; pas de dirty ; fixture zéro/19 = rang 2, 300 points agrégés |
| Tous les scores Quiz/Blindtest à zéro | Aucun point/participation, mais faux `mapping_without_result` après terminaison | Lignes runtime effectivement lues reconnues comme volontairement non classables ; pas de dirty |
| Injection papier, aucun score saisi (valeurs initiales zéro) | Même faux incomplete malgré absence normale de classement | Hors classement, pas de dirty, selon décision utilisateur |
| Bingo sans gagnant de phase | Pas de contribution mais faux incomplete pour les mappings | Lecture de phases réussie et vide : pas de dirty ; échec de lecture : absence non prouvée, anomalie maintenue |
| Mapping finalisé ou session terminée, ligne runtime référencée introuvable | Anomalie puis dirty dans le hook naturel | Anomalie maintenue : référence de stockage incohérente, pas un score nul observé |

### Critère exact dans le code corrigé

`app_games_hub_players_stats_mappings_load` (6240) retient statuts active/completed, IDs positifs dont participation, Hub/session/joueur présents. Résolution runtime par ID puis clé (`mapping_best_match`), **pas par pseudo**, sans lire réponses, score-saisi, présence effective au-delà de l’enregistrement runtime ni publication finale.

Les collecteurs Quiz (6374), Blindtest (6416), Bingo (6475) ne changent aucun score/rang. Ils transmettent désormais une liste interne `unranked_mappings` pour les **lignes réellement retrouvées** mais exclues par la règle de classement : `NO_POSITIVE_SCORE`, `NO_PHASE_RESULT`. Une requête ayant échoué ne prouve pas une absence légitime. `projection_from_hub_runtime` (6555) ne signale un mapping sans contribution que s’il n’est pas ainsi exclu et si mapping completed ou terminaison explicite. Le hook Games (boot_lib.php, 301) transforme toujours les anomalies restantes en `AUTO_REBUILD_INCOMPLETE` ; ce hook est inchangé. Ce contrôle prouve une incohérence de référence runtime, **pas** qu’un joueur a répondu ou qu’un score papier doit obligatoirement exister.

Autre cause de boucle corrigée : `ranking_rows_project` filtre les joueurs sans partie comptée ; `fallback_reason` confondait alors un classement vide calculé et une projection absente. En cas de classement vide seulement, `ranking_get` (7447) lit un résumé borné au Hub entier : joueurs, computed manquants, dirty, erreurs et lignes classables. Un vide validé exige au moins un joueur, tous calculés, aucun dirty/erreur et aucune ligne classable. Une projection inconnue, une lecture échouée ou un résultat tronqué conserve le fallback. Aucun calcul historique ni write n’est ajouté aux lectures ; seulement une petite requête de compteurs dans le cas vide.

### Tests et limites

`hub_stats_pending_session_test.php` complété : collecteurs réels Quiz/Blindtest/Bingo, quatre cas demandés, zéro individuel versus tous zéros, erreur de lecture des phases, contribution gagnante, vide consolidé lu cinq fois sans fallback, gardes missing/dirty/error/ranked. DB simulée ; assertions explicites sur les défauts avant correction puis attentes corrigées. Tests projection, photo fallback, writer de remplacement et hook naturel verts ; lint et diff-check verts.

Les fichiers supplémentaires modifiés dans ce complément sont le helper Global et le test existant `hub_stats_pending_session_test.php`, plus documentation. Aucun fichier applicatif Games supplémentaire, aucun déploiement. La mesure réseau/DOM reste à effectuer en DEV après vrai rebuild. Papier partiellement saisi : zéro individuel et non-saisie ne sont pas distinguables par les colonnes actuellement lues ; lorsqu’un autre score est positif, la ligne zéro reste classée selon la règle existante. Un contrat de validation/saisie distinct serait nécessaire pour changer ce cas, non modifié ici.
