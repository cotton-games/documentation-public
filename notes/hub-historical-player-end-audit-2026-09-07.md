# Audit ciblé — résultats Play historique, Hub 291 — 2026-09-07

## Recette navigateur et contrôle final des logs — 08/09/2026 matin

**Validation navigateur acquise, déclarée par l'utilisateur** : officiel historique après démo préalable → résultats personnels visibles ; officiel orchestré Hub → retour et résultats Hub corrects ; démo Hub → résultats et retour corrects. Ce sont des observations de recette, pas une capture DOM/WS de l'agent. Aucun nouveau patch : aucune anomalie du correctif démontrée dans les logs.

**Périmètre réel des copies** : `games/logs` et `global/logs` sont du 08/09 ; dossier `glopbal/logs` mentionné dans le message non trouvé, lecture de `global/logs`. Les copies Pro initialement restées au 07/09 ont été **rechargées pendant ce contrôle** : elles couvrent maintenant le 08/09, jusqu'à 07:58:07 (access) / 07:58:02 (error). Pro error **11/14** et access **20/27** montrent les POST `/extranet/start/script` à **07:51:20 / 07:54:34**, corrélés aux démos historiques 27720 / 27721 résolues dans Global. Le corps des POST n'est pas journalisé ; l'utilisateur confirme explicitement que ces démos venaient du dashboard mobile et que seule la dernière était une démo Hub. Games s'arrête à 08:00:56, Global à 07:58:40 ; access en `+0200`, heures error corrélées. Les références de lignes de l'audit initial plus bas concernent ses anciens snapshots datés du 07/09, remplacés dans les dossiers Games/Global : utiliser leurs empreintes historiques, ne pas confondre les numérotations.

### Chronologie prouvée et portée de la provenance

| Parcours / Hub | Sessions et exécutions identifiées | Fin et preuves du snapshot 08/09 |
|---|---|---|
| Historique officiel / Hub 296 | Source officielle **27717** ; démo préalable **27720**. Aucun execution_id Hub de cette démo trouvé dans ces logs. | 07:52:09 Master historique (Games error **61–62**) ; Player historique **64**. **07:53:18**, `hub_session_natural_ended` de 27717 → `historical_execution_detected`, engine blindtest, active_session_id=0 (**84**), après `persist_ok` (**83**). Branche historique explicite ; résultats personnels validés au navigateur. |
| Officiel orchestré / Hub 296 | Source/runtime **27718** ; `hubexec-927c008601954be76b7fca73d5523f80`. Une autre démo historique préalable **27721** est visible (Global error **9–10**), pas la démo Hub du troisième scénario. | **07:56:05** focus commité 27718 et création exécution (Games error **112**), Master `hub_launch=1&hub_execution=...` (**115**). **07:57:22** : contexte Hub accepté, podium disponible, focus clear puis completion `completed`, rebuild et retour collectif (**174**). GET Hub Play/Master HTTP 200 au même instant (Games access **310–311**, puis Play **319**). |
| Démo orchestrée / Hub 295 | Source **27710** → runtime annexe **27722** ; `hubexec-77eb069c8f1f2251fa375290b22fe959`. | **07:58:20** création exécution + `hub_preflight_demo_create/launch`, runtime 27722 (Games error **220**) ; URL Master mode demo/source/execution (**222**). Global error **14–16** : `runtime_execution_demo`. **07:59:33** : `hub_demo_execution_completed` source 27710/runtime 27722, result completed (Games error **311**). GET retour Hub Play/Master HTTP 200 à **07:59:36** (Games access **532,534–535**). |

Les trois fins identifiées dans ce snapshot sont **Blind Test**, pas une preuve de recette Quiz ce matin. Le nom de log `hub_paper_execution_completed` de l'officielle est commun au bridge : il ne prouve pas une session papier. Les IDs de membership et IDs SQL internes moteurs ne sont pas nécessaires à cette corrélation et ne sont pas inventés.

**Point précis : non-clôture de la démo préalable par la fin historique.** La trace positive Games error **84** prouve le choix de la branche historique. Dans `canvas_api_hub_session_natural_ended` (`games/web/includes/canvas/php/boot_lib.php:398–428`), cette sortie rend `hub_execution=false` sans completion réussie, clear ou rebuild par ce callback. Cela établit la bonne classification observée ; ce n'est pas une conclusion tirée de la seule absence d'un log de completion.

Toutefois, Global error **4–5** identifie explicitement 27720 comme **`historical_dashboard_demo`**, source 27717 ; Games error **53–54** montre les paramètres `hub_demo_source_session`/`hub_demo_hub`, sans paramètre d'exécution. Le handler de branding (`global/web/app/modules/general/branding/app_branding_ajax.php`, bloc historique **750–810**) distingue ce contexte de `runtime_execution_demo`. L'utilisateur confirme ensuite cette distinction : les démos préalables du matin venaient du dashboard mobile, seule la dernière était orchestrée Hub. Ce parcours ne prouve donc pas la présence d'une **exécution Hub démo ouverte** préalable comme dans l'incident Hub 291. Ne pas inventer cette exécution, ni déclarer le stress-case exact reproduit au navigateur. Le test automatisé couvre bien ce cas.

Les deux completions orchestrées ont la bonne paire source/runtime et la bonne branche dans les logs. Leurs lignes terminales ne portent pas execution_id : le lien aux IDs du lancement est une corrélation cohérente de session et de temps, **pas une lecture du start/completed SQL lié**. Les GET de retour prouvent les navigations HTTP observées ; ni leur contenu exact de résultats ni les payloads WS ne sont dans Nginx. Les résultats/rendus sont validés séparément par l'utilisateur. Les booléens brut de réponse (`hub_execution`, mode) et le contenu des starts ne sont pas exportés ici.

### Une seule lecture SQL restante

Pour confirmer les starts/completions exacts des deux exécutions orchestrées et l'absence d'une completion de démo imputable à la fin historique de 27717, demander **uniquement** le SELECT ci-dessous, en DEV. La jointure gauche garde une ligne NULL si aucun événement n'existe sous le token concerné. Aucun filtre temporel n'exclut une éventuelle exécution démarrée avant le snapshot. Inclure sources et runtimes car le start/completed d'une démo annexe est écrit sous le token source. Les payloads complets permettent de relier execution_id et de vérifier Hub/mode/source/runtime sans supposer des colonnes dédiées.

```sql
SELECT cs.id AS historical_id, e.id AS event_row_id, e.game,
       e.action, e.created_at, e.payload_json
FROM championnats_sessions cs
LEFT JOIN game_events e
  ON e.session_id = cs.id_securite
 AND e.action IN ('hub_execution_started', 'hub_execution_completed')
WHERE cs.id IN (27717,27720,27718,27721,27710,27722)
ORDER BY cs.id, e.id;
```

Schéma vérifié localement dans `canon/data/schema/DDL.sql:1950–1959` (`game_events`) et relations de session déjà auditées ; source [DDL RAW develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/schema/DDL.sql), section `CREATE TABLE game_events`. Le résultat attendu se juge sur les starts liés : mode/source/runtime présents sur start, pas obligatoirement sur completion. Si 27717/27720 ne portent aucun start Hub, conclure « démo historique préalable sans exécution Hub trouvée en DB », pas « exécution Hub démo préservée prouvée ». Aucune requête de réparation ni autre collecte SQL demandée.

### Conservation, discipline et statut migration

Snapshots recopiés à l'identique sous `/tmp/hub-end-final/proof` pour cette vérification ; seules les preuves ciblées et empreintes figurent dans la documentation, pas les logs bruts contenant des identifiants de navigation. Empreintes SHA-256 :

| Snapshot | Lignes | SHA-256 |
|---|---:|---|
| `games/logs/access_log` | 633 | `cfd99d9d2397a1f0e229e14c9d6f8d20ff1c4c6f3bc4d425cbe42f31801d8993` |
| `games/logs/error_log` | 359 | `33d291a7829eb1c862fccebfbc50ffa5a10411de89683c150787071e8639fba1` |
| `global/logs/access_log` | 16 | `e5fb17b237f3b56c08e9f29be4e1c713d34873f4139cef385a839565915569a0` |
| `global/logs/error_log` | 16 | `e7eed0048961c88217fcac5a60069f5137a9e505f25fe7b83f723f0aec75fe64` |
| `pro/logs/access_log` | 37 | `a0c2487742a9c35d39cd9b797086c81c27af02e9d948a668cb814d6043be4da4` |
| `pro/logs/error_log` | 16 | `b6f7b8dcd89114cccfbeed6f0b0031452937db2afe3d40bdbe3d45be1ca4c1f5` |

START, sitemap markdown/texte, README général, manifeste, Handoff, cinq index repo/README/TASKS et journal AI Studio rechargés pour le contrôle final. Journal toujours daté 28/08, aucun fichier du correctif signalé. Contrats RAW de référence : [Games README](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), section « Update 2026-07-15 — Hub: validation papier puis retour après fin naturelle » ; [Global README](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Etat 2026-07-13 - Games hubs fins naturelles durables ». Le détail de la recette du 08/09 dans le RAW public est **non trouvé** avant cette mise à jour locale. Index/sitemap générés puis rechargés ; aucun nouveau test applicatif nécessaire pour ce contrôle documentaire, les huit suites du patch restent les vérifications locales précédemment exécutées.

**Statut du correctif ciblé pour migration : recette fonctionnelle DEV validée sur les trois parcours et traces terminales cohérentes ; aucune anomalie démontrée imposant un nouveau patch. Réserve probatoire SQL limitée aux starts/completions exacts et au statut de la démo préalable**, sans remise en cause du résultat navigateur acquis. Ne pas annoncer une vérification DB complète avant réception du SELECT. Aucun commit ni déploiement par l'agent, aucune action PROD.

Fichiers applicatifs à livrer : **1.** `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php` (helper) ; **2.** `games/web/includes/canvas/php/boot_lib.php` (consommateur). Livraison coordonnée, Global disponible avant Games si séquentielle. Aucun fichier WS/Play à livrer pour ce correctif, aucun redémarrage Node/WS nécessaire à ces modifications PHP ; prise en compte OPcache selon la procédure serveur. Les deux tests du correctif accompagnent les sources sans être des dépendances runtime. Legacy incomplet et ancienne officielle indiscernable : limites inchangées, décrites plus bas.

## Décision et niveau de preuve

L'évolution de continuité/lancement Hub mobile est **reportée, non exécutée**. La réinscription historique à chaque session est le parcours accepté ; compteur Hub à 2 après réinscription confirmé par l'utilisateur. Ce n'est plus un incident d'auto-connexion.

**Défaut précis reproduit avant correctif dans le code local : confusion entre exécution de démo annexe et fin de la session officielle source.** La récupération `completion_recovered` accepte une exécution ouverte sans vérifier son `runtime_mode` ni son `runtime_session_id`, la clôture, puis retourne `hub_execution=true` sans mode démo. Les WS Quiz/Blind Test en déduisent qu'il faut envoyer `HUB_SESSION_FINISHED` à la place du résultat historique `endGame`. Un Play historique sans `hubPresentation` ne redirige pas ; il n'a reçu aucun résultat à rejouer. Le défaut n'est donc pas « toute membership Hub redirige le joueur ».

**Confusion d'exécution prouvée en DEV par SQL fourni par l'utilisateur** : le start **365395** du 07/09/2026 à **13:23:45** porte `hubexec-cf9d18bfdf5b18752854d901a1415007`, Hub 291, mode `demo`, source 27695, runtime 27696. La completion **365512**, à **20:13:24**, clôture ce même execution_id sous la session primaire 27695 ; elle coïncide avec la fin officielle S1 `recovered_after_focus_clear` (`games/logs/error_log:11580–11582`). Les champs mode/source/runtime sont absents de la completion par construction ; leur preuve est le start lié. Ce lien n'est plus une hypothèse. Réception WS effective par Cloclo/Remo12, écran conservé et fins S2/S3 : **non trouvés dans les logs fournis**.

**Correctif local appliqué, vérifications terminées le 08/09/2026**, sans commit ni déploiement. L'utilisateur a confirmé que les versions serveur DEV sont à jour sur `hub_soiree`, PROD sur `main` ; le travail vise DEV. Ce témoignage lève le prérequis de rapatriement, sans comparaison binaire indépendante ni constat de déploiement du nouveau patch. Les confirmations SQL concernent DEV uniquement. Aucun accès SSH/DB/DEV/PROD/navigateur de l'agent ; modifications en cours préservées.

## Correctif livré localement — 08/09/2026

**Cause/correction** : la fin officielle de la source récupérait une exécution démo annexe. Le bridge valide désormais le **start brut** de l'exécution avant de lui attribuer une fin. Il ne se fie ni à la membership, ni aux champs normalisés par défaut par le resolver ouvert. WS/Play restent inchangés : `hub_execution=false` conserve leur émission/rendu historique `endGame`.

| Fichier / fonction / lignes après patch | Changement |
|---|---|
| `games/web/includes/canvas/php/boot_lib.php`, `canvas_api_hub_session_natural_ended:328`, validation commune 363–368 | Appelle le helper de provenance ; helper indisponible = pas d'autorité Hub. |
| Même fonction, démo 379, replay 400–405, recovery 415, focus actif 435 | Même validation dans les quatre branches. Démo rejetée avant toute prétention d'autorité, même avant état terminal. Replay retrouve execution_id depuis le marqueur puis son start. Aucun clear/complete/rebuild sur refus. |
| `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`, `app_games_hub_execution_terminal_provenance_matches:4257–4283` | Lecture seule des starts du token source, ordre ID décroissant. Le dernier start du Hub doit porter le même execution_id, le mode attendu et les IDs source/runtime/session primaire exacts. Officiel : runtime=source ; démo annexe : runtime distinct. Pas de repli vers un ancien start du même Hub. |
| `games/web/tests/hub_natural_end_stats_rebuild_test.php` | Test existant étendu ; vraie fonction bridge et vrai helper Global, frontière stockage/effets simulée. Confusion démo, quatre branches, métadonnées manquantes/incorrectes, ancienne officielle, erreurs de lecture, Quiz/BT/Bingo. |
| `global/web/tests/hub_terminal_provenance_test.php` | Nouveau test exécutant les vrais readers/validator/writer avec journal mémoire : start→terminal→completion, marqueur contaminé, ordre des événements, INSERT IGNORE idempotent, scoping token/Hub, resolver démo conservé, champs legacy normalisés non acceptés comme preuve. |

Le resolver générique `app_games_hub_execution_context_get_open` (désormais 4285) et le reader partagé `app_games_hub_natural_completion_events_get` (4174) ne changent pas. La validation supplémentaire est réservée au bridge terminal ; les autres consommateurs du reader ne sont pas déclarés corrigés. `app_games_hub_execution_context_complete` (4511) conserve son event_id stable et son INSERT IGNORE ; aucun événement existant n'est supprimé, réécrit ou réparé.

### Contrat et limites explicites

- Démo ouverte de S → fin officielle historique S : `hub_execution=false`, démo intacte. Completion déjà contaminée → aucun faux `already_completed` officiel.
- Véritable officielle exacte : focus actif, recovery après clear et replay conservés ; le replay respecte toujours l'ordre terminal→completion du reader existant. Un terminal ultérieur invalide l'ancienne completion. Focus sur une autre session : comportement historique préexistant conservé, aucun clear de cette autre session.
- **Métadonnées anciennes absentes/incomplètes** : provenance refusée, fin historique conservée et aucun write/clear/rebuild Hub. Le resolver générique conserve ses fallbacks pour ses autres appelants. Conséquence assumée : une véritable vieille exécution orchestrée sans preuve explicite ne reçoit plus le retour Hub par ce bridge. Les jeux restent sur leur fin historique ; ne pas annoncer une compatibilité de routage legacy complète.
- **Ancienne officielle de même source** : un nouveau start rend l'ancienne non autoritaire. Une ancienne completion antérieure au nouveau terminal n'est pas réutilisée. En revanche une officielle encore ouverte, identités exactes et aucun nouveau start, reste acceptée en recovery : le callback transporte seulement game/sessionId. La distinguer d'une relance historique indiscernable exigerait une preuve d'incarnation supplémentaire. Ce cas demeure explicitement ambigu, testé comme tel ; aucune évolution WS/lancement ajoutée.
- Sessions autonomes et démos historiques sans contexte Hub : chemins existants conservés. Véritables démos annexes avec start cohérent : résultat et retour démo, sans mutation du focus officiel. Aucun changement de participants, QR, lobby, compteur, routes ou continuité intersessions.

### Vérification locale terminée

Commandes depuis `/home/romain/Cotton` :

```sh
php games/web/tests/hub_natural_end_stats_rebuild_test.php
php global/web/tests/hub_terminal_provenance_test.php
node games/web/tests/hub_transition_remote_test.mjs
node games/web/tests/hub_demo_player_presentation_test.mjs
php games/web/tests/hub_demo_readiness_flow_test.php
php global/web/tests/hub_demo_mode_contract_test.php
php global/web/tests/hub_presentation_mode_contract_test.php
php global/web/tests/hub_remote_control_contract_test.php
```

**Huit suites OK**. Le test Games étendu exécuté contre la version HEAD antérieure du bridge échoue notamment sur la confusion démo/officiel, puis passe sur la version corrigée ; contre-épreuve sous `/tmp/hub-end-fix`, sans mutation des sources. Lint des deux PHP applicatifs et diff checks OK. Génération documentaire puis relecture des index/sitemap effectuées. Les tests utilisent des doubles DB/transport, pas un serveur ni un navigateur. Contrôle Bingo via les branches du bridge commun : aucun défaut Bingo de recette revendiqué.

### Livraison et recette DEV avant migration — protocole initial, validation ci-dessus

Livrer ensemble les deux PHP applicatifs Games/Global (helper Global disponible **avant** le nouveau bridge Games si livraison séquentielle). Games seul avec Global ancien retomberait en historique pour toutes les fins, y compris les vraies orchestrées. Les tests ne sont pas des dépendances de runtime. Aucun changement WS, aucun marker de restart modifié, **aucun redémarrage Node/WS requis par ce patch PHP**. Prise en compte PHP/OPcache selon la procédure serveur existante ; réglage effectif **non trouvé**, pas d'invalidation distante réalisée. Aucun commit ni déploiement par l'agent ; recette DEV désormais validée par l'utilisateur (voir contrôle final en tête).

Recette courte à exécuter en DEV sur `hub_soiree` :

1. Ouvrir une démo Hub annexe d'une source officielle numérique, conserver ses IDs start/source/runtime. Puis lancer cette source par le Master historique du dashboard mobile et inscrire deux joueurs par QR historique.
2. Terminer officiellement : podium Master, **résultats personnels visibles pour les deux Players**, URL historique conservée. Vérifier `endGame` personnel si export disponible et aucune completion de la démo par la source. Refaire en Quiz puis Blind Test ; les scores SQL seuls ne prouvent pas le rendu.
3. Contrôler une vraie officielle lancée par Hub : fin et retour Hub attendus. Contrôler une vraie fin démo : résultat/retour démo et focus officiel inchangé. Rejouer le callback officiel après clear : une seule completion.
4. Contrôler une autonome et une démo historique : résultats historiques. Sur le cas déjà contaminé S1, vérifier qu'un retry n'obtient pas de faux retour officiel ; ne pas purger les événements. Noter URL/écran et présence réseau avant fermeture des Players.

Rollback éventuel : retirer uniquement le correctif du bridge Games et le helper Global associé, en préservant les autres modifications ; aucun rollback DB. Cela réintroduit le défaut connu. La réception WS de la recette originale, le contenu exact de ses podium_json de 2 octets et les fins S2/S3 restent non prouvés.

## Sources RAW et discipline

Rechargés le 07/09 : [START main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), « Parcours », « Preuve d'abord », « Comparer develop vs main », « Discipline de génération » ; [SITEMAP develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), Repos/DB schema/Project status ; [SITEMAP markdown](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md) ; [README général](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md), règles de maintenance ; [Manifest](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers », « Routing rules », « Canon documentation » ; [Handoff](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md), contexte des travaux Hub/démo.

Index RAW ouverts depuis le sitemap, section « Pages » : [Games](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/INDEX.md), [Global](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/INDEX.md), [Pro](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/INDEX.md), [Quiz](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/quiz/INDEX.md), [Blind Test](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/blindtest/INDEX.md). README et TASKS de ces cinq repos rechargés aux mêmes chemins sur main et develop ; fichiers différents, pas d'annonce d'alignement PROD.

Contrats ciblés :

- [README Games develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Update 2026-07-15 — Hub: validation papier puis retour après fin naturelle » : récupération d'une clôture après clear et retour réservé à une destination prouvée ; « Update 2026-08-31 - Diagnostic Hub : démo de contrôle » : runtime annexe distinct ; « Update 2026-07-31 - Hub Canvas: reprise d'exécution ouverte et contexte Hub ». Comparé au [même README main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/games/README.md) : écart develop/main, ne prouve pas le déploiement.
- [README Global develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Etat 2026-07-13 - Games hubs fins naturelles durables » : exécution distincte du token session et marqueur de fin ; [même chemin main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/global/README.md) comparé. Le défaut précis de confusion dans la branche recovery : **non trouvé dans la documentation**, établi par code/sonde ci-dessous.
- [README Pro develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/README.md), « Update 2026-09-01 - Dashboard mobile: lecture Programme et démo active » ; [même chemin main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/pro/README.md), écart documentaire. Le parcours historique individuel reste celui demandé ici.

[Journal AI Studio](https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb) consulté avant l'audit applicatif : enveloppe HTML HTTP 200, Markdown intégral extrait de `const raw` ; dernière mise à jour annoncée 28/08/2026. Sections EN COURS/TODO/Fait livré : aucun fichier de fin Canvas/WS concerné signalé hors workspace. Cela ne certifie pas leur version serveur. Confirmation utilisateur des versions DEV reçue ensuite ; voir livraison locale ci-dessus.

## Correspondances et chronologie corrélée

Chemins relatifs à `/home/romain/Cotton/`. Les heures des access logs sont `+0200`. Les error logs sont corrélés à ces requêtes ; le fuseau interne d'un futur export WS doit être conservé.

La table canonique documentée est **`games_hubs_sessions`**, pas `games_hub_sessions`. SQL phpMyAdmin fourni par l'utilisateur : les trois memberships sont `active`, `membership_source=schedule_plan`, numériques (`flag_controle_numerique=1`), officielles (`flag_session_demo=0`). Les IDs de membership ne sont pas les IDs historiques.

| Session | Membership → session historique | Runtime SQL / état au relevé DEV |
|---|---|---|
| S1 Blind Test (type 4) | 959 → 27695, Hub 291 | `blindtest_sessions.id=7329`, `game_status=3`, updated 20:13:24, total_players=2. Confusion avec l'exécution démo prouvée. |
| S2 Quiz (type 5) | 973 → 27715, Hub 291 | `cotton_quiz_sessions.id=1619`, status=0, updated 20:14:14, total_players=0. Aucune fin prouvée. |
| S3 Blind Test (type 4) | 974 → 27716, Hub 291 | `blindtest_sessions.id=7330`, status=0, updated 20:14:31, total_players=0. Aucune fin prouvée. |
| Démo annexe S1 | Source 27695 → runtime 27696 | `blindtest_sessions.id=7326`, status=1, updated 13:24:07, total_players=1. Le marqueur d'exécution a pourtant été clôturé à la fin de la source officielle. |

Résultats SQL joueurs : S1 `Remo12` (220434), score **8**, et `cloclo` (220433), score **4**, tous deux `is_active=1`. S2 retourne seulement `cloclo` (4913), score 0, actif ; aucune ligne S3 pour les noms sélectionnés. `is_active` n'est pas une présence socket. Les quatre runtimes ont un `podium_json` non NULL de **2 octets** : cela ne prouve pas un podium renseigné, et le contenu exact est **non trouvé** dans ce relevé. Le podium Master est une observation de recette distincte. Les `total_players=0` ne prouvent pas l'absence de lignes joueurs (contre-exemple S2).

Preuve SQL conservée ici sous forme de résultats ciblés fournis par l'utilisateur, pas d'accès DB de l'agent. Les requêtes reproductibles figurent plus bas ; ne pas redemander ces quatre relevés déjà reçus.

| Heure / preuve | Fait observé et limite |
|---|---|
| 13:23:46 — `games/logs/error_log:5778` | Création démo Hub 291, source 27695, runtime 27696, intention `remote-command-510`. Ce n'est pas le lancement officiel mobile du soir. |
| 13:23:55 — `games/logs/error_log:5784`, `global/logs/error_log:102–103` | Readiness de l'exécution `hubexec-cf9d18bfdf5b18752854d901a1415007` ; paramètres source/exécution du Master démo et résolution branding `runtime_execution_demo` pour 27696. |
| 20:11:33 — `games/logs/error_log:11553–11554`, Global 117 | Master `/master/{token27695}?return_url=...`, membership Hub 291, `historical_execution_detected`, offre valide, `is_demo=0`, `game=blindtest`. Le referrer Pro et ce marqueur sont prouvés ; l'UA de ces requêtes est Chrome/CrOS, pas une preuve de largeur mobile. |
| 20:11:38, :47, :50 — `games/logs/error_log:11556,11558,11559` | Player historique : tentative de reprise cookie, mais `historical_execution_detected`, puis fallback inscription classique. Ce sont des preuves positives d'exécution non orchestrée côté Player, pas une simple absence de trace Hub. |
| 20:11:42 — Games 11557 | Une inscription a un bridge Hub `USERNAME_TAKEN`. Pseudo absent : ne pas attribuer cet échec à Cloclo ou Remo12 ni en faire la cause de fin. |
| 20:11:58 — Games 11561 | Autre registration : identité Hub 423, mapping 794, session 27695, bridge réussi. Pseudo non journalisé. Cela ne remet pas en cause le compteur 2 confirmé par l'utilisateur. |
| 20:12:38–20:13:17 — Games 11562–11579 | Écritures `session_update`, changement de paramètres `hub_session_settings_save`, deux `update_score`. Les corps ne sont pas présents : ne pas déduire mode final/score exact des noms d'action. |
| **20:13:24 — Games 11580–11582** | `session_update` avec persistance BT teams=0, puis `hub_session_natural_ended`. Retour de la branche `hub_paper_execution_completed`, `result=recovered_after_focus_clear` pour **27695**. Rebuild `completion_recovered`, `ok=true`, `updated=2`, `players_total=2`, `mapping_without_result_count=0`. Le nom « paper » du log est commun : il ne prouve pas une session papier. Aucun ID d'exécution récupérée dans cette ligne ; le SQL fourni lie précisément cette fin à la completion 365512 de la démo démarrée par 365395. |
| 20:14:03–20:14:31 — Pro 425/427, Games 11583–11588, Global 122/123 | Ouvertures 27715 puis 27716, membership 291, Masters historiques, guards valides ; `session_update`. Pas de fin S2/S3 dans ces fichiers. |

Bornes des snapshots : Games access 36252 lignes, dernière 20:15:26 ; Games error 11588 lignes, dernière 20:14:31 ; Pro access 2345 lignes, dernière 20:14:27 ; Pro error 427 lignes, dernière 20:14:24 ; Global access/error 123 lignes chacun, dernière 20:14:27. Aucune occurrence textuelle Cloclo/Remo12 trouvée dans ces six fichiers. Les logs Nginx ne donnent ni le contenu de toutes les réponses HTTP 200 ni les messages reçus par les sockets.

Empreintes de conservation Games : error `88f446540b57e5f3a1f2a8147f4ab66c8c584d3d9d7c5c7d85dead3efa701d12`, access `dae44a1fbdd69c1f97be482cccaf7ba22b1502c16a782f3367a166e6e24484d8`. Aucun log copié dans la documentation versionnée.

## Chaîne de fin et première divergence — état avant patch (lignes de référence initiales)

**1. Boot individuel : bon garde local.** `games/web/player_canvas.php`, bloc de résolution 279–290, refuse le contexte de retour si focus différent/absent ou exécution non trouvée ; il vide `$hubRow`, donc ne construit pas `HUB_PRESENTATION_CONTEXT` (369–380). Le bridge d'identité reste indépendant (187 et suivants). `persistHubBridgeCookies`, `includes/canvas/play/register.js:316–351`, ajoute `hubToken`/`hubAutoPlayer` après registration, **pas `hubPresentation`**. La membership et le compteur peuvent donc fonctionner sans routage terminal Hub. Master : `organizer_canvas.php:100–129` exige lui aussi une exécution pour activer `hubOrganizer`.

**2. Production terminale moteur.** `blindtest/web/server/actions/gameplay.js`, `endGame:1313–1453` et `persistPodium:1653` ; Quiz mêmes fonctions `1099–1204` et `1366`. Classement/podium sont constitués puis persistés ; ensuite `requestHubNaturalTransition` (BT 118–133, Quiz 111–126) appelle le bridge. La seule présence d'un podium Master ne prouve pas l'envoi du payload personnel Player. L'observation podium/classement Master vient de la recette utilisateur ; son événement exact de rendu n'est pas dans Nginx.

**3. Mauvaise récupération de provenance.** `games/web/includes/canvas/php/boot_lib.php`, `canvas_api_hub_session_natural_ended:328–468` :

- Résout Hub par membership, initialise `$runtimeMode='official'` ; ne résout un runtime démo annexe que si aucun Hub direct n'est trouvé (340–360).
- Sans focus, essaye d'abord `already_completed` (392–402), puis récupère une exécution ouverte par session source (403–407).
- **408–415 : vérifie uniquement terminal + execution_id non vide** ; ne vérifie ni `runtime_mode`, ni `runtime_session_id`, ni `source_session_id` de cette exécution. Appelle complete, retourne `hub_execution=true` et `completion_recovered`, sans `runtime_mode`.
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`, `app_games_hub_execution_context_get_open:4250–4301` lit les événements par token de source ; il retourne volontairement les métadonnées démo/officiel, source et runtime (4294–4296). Focus à zéro n'exclut pas la démo. Le resolver générique n'est pas un validateur de fin officielle.
- `app_games_hub_execution_context_complete:4476–4495` écrit `hub_execution_completed` sous le token passé, avec execution_id/Hub/session primaire, sans recopier mode/source/runtime. Une clôture récupérée à tort peut donc aussi contaminer les lectures ultérieures `already_completed` ; le lien au `hub_execution_started` reste nécessaire pour prouver sa provenance.

**4. Le résultat personnel n'est plus envoyé dans la branche choisie.** BT `endGame:1401–1438`, Quiz `1165–1190` : `hub_execution=true` → résultat historique envoyé seulement si `runtime_mode==='demo'`, puis `sendHubNaturalReturn`. Avec le retour recovery sans mode, seul le signal `HUB_SESSION_FINISHED` est envoyé aux sockets Players encore connectées, puis cleanup après 350 ms. Avec `hub_execution=false`, le serveur envoie bien `endGame` personnalisé (rang/score/total ; métadonnées équipes BT) avant cleanup. Ce branchement commun explique le périmètre potentiel Quiz et BT ; réception réelle encore à vérifier via export WS.

**5. Le Play historique ne peut pas inventer le résultat manquant.** `games/web/includes/canvas/play/play-ws.js`, `commonHandlers:1459–1481` :

- `endGame` → `player/end`, sauf destination Hub/transition active.
- `HUB_SESSION_FINISHED` → tentative de retour Hub ; sans contexte, fallback puis replay seulement si `pendingHubTerminalPayload` existe.
- Ici, le serveur a choisi de ne pas envoyer `endGame` : aucun payload en attente. La sonde reproduit **aucun `player/end` et aucune navigation**, bien que le signal Hub ait été reçu. Le handler pose aussi `staticTerminatedMode` et supprime la reconnexion automatique. L'écran exact demeure celui laissé par les événements précédents ; il n'est pas déductible de cette seule branche.

`hub_transition.js`, `target:63–75`, `shouldBlockHistoricalTerminal:624–628` : exige `hubPresentation.enabled`, pas `hubToken` seul. Le renderer historique `play-ui.js`, abonnement `player/end:2829–2859` met à jour rang/score puis appelle `renderEndCard:2189` et `setState:1200–1245`. Aucun guard d'appartenance Hub n'y bloque ce rendu. Pas de requête résultat dédiée dans ce handler de fin normale : il consomme le payload WS.

## Distinction des causes

| Hypothèse | Conclusion |
|---|---|
| Résultat non produit | Pas l'explication principale de S1 : persistance et rebuild réussis à 20:13:24, podium Master observé. Scores S1 confirmés en SQL (8 et 4) ; podium_json de 2 octets, contenu et validité du podium non prouvés. |
| `endGame` non reçu | Le code démontre une cause **en amont de la réception** : pas d'émission personnelle dans la branche officielle Hub sélectionnée par erreur. Sans export WS, ne pas affirmer quel message Cloclo/Remo12 a reçu. |
| Rendu bloqué par appartenance seule | Non reproduit localement : `hubPresentation=null` + identité bridge → `endGame` est transmis au renderer. |
| Redirection prématurée | Non prouvée pour cette recette. La sonde du scénario contaminé ne redirige pas ; une vraie navigation nécessiterait un contexte Hub activé, un autre événement ou une version différente. |
| Confusion exécution source/démo | Confusion établie en DEV sur S1 : start démo 365395 et completion 365512 portent le même execution_id, en corrélation avec la recovery officielle. |
| S2/S3 touchées | Non établi : seules ouvertures visibles. Pas de généralisation à toutes les sessions membres ni au seul mobile. |
| Sessions autonomes | Sans membership, le bridge renvoie `not_hub_session` et `hub_execution=false`, donc fin historique. |
| Vrai Hub orchestré / démo | Un vrai officiel Hub attend le signal/routage Hub ; une vraie démo reçoit son résultat puis son retour temporisé. À préserver. |
| Bingo | Bridge partagé, donc validation de provenance pertinente ; pas de recette ni de preuve de disparition de résultats Bingo ici. Ne pas déclarer Bingo impacté fonctionnellement sans test spécifique. |

## Origine locale prouvable — avant patch

`git blame` Games : recovery ajoutée par `2b34398b` le 15/07/2026 (`boot_lib.php:403–415`), à l'origine pour réparer une clôture après clear. Global : `fe9baa55` le 31/08/2026 ajoute les champs `source_session_id`, `runtime_session_id`, `runtime_mode` au resolver d'exécution (4294–4296). La recovery conserve son test « execution_id non vide ». Le garde Player contre les exécutions historiques vient de Games `56a55dfd` le 13/07 ; le blocage terminal `endGame` de `e5ca900c` le 13/07.

Ces commits expliquent la coexistence locale des contrats qui permet le défaut. Ils ne prouvent pas une date d'introduction en DEV/PROD, ni le commit déployé au moment de la recette.

## Périmètre retenu

La proposition initiale de validation en amont a été appliquée ; voir « Correctif livré localement » pour fichiers, comportement legacy et limite des anciennes officielles. Aucun élargissement du lancement mobile ni des interfaces WS/Play. Aucune réparation DB.

## Sondes et tests locaux — historique de l’audit avant patch

Sondes sous `/tmp/hub-end-audit`, aucun fichier applicatif/test versionné modifié :

- `php /tmp/hub-end-audit/recovery-probe.php` : vraie fonction `canvas_api_hub_session_natural_ended`, doubles PDO/états/exécution dérivés du test existant. Sans focus, session officielle terminale : aucune exécution → `hub_execution=false`, 0 complete ; officielle exacte → `completion_recovered`, 1 complete ; **démo runtime 201/source 101 pendant fin officielle 101 → même `completion_recovered`, 1 complete**. Reproduit le défaut, pas une connexion DB.
- `node /tmp/hub-end-audit/player-probe.mjs` : vrais handlers `play-ws.js` et `hub_transition.js`, Bus/location simulés. Historique avec bridge : `endGame` → `player/end`, zéro navigation. Même historique recevant uniquement `HUB_SESSION_FINISHED` → zéro `player/end`, zéro navigation. Officiel orchestré → retour Hub ; démo → `player/end` conservé. Ne prétend pas tester le DOM ni le réseau.
- `node games/web/tests/hub_transition_remote_test.mjs` : OK.
- `node games/web/tests/hub_demo_player_presentation_test.mjs` : OK.
- `php games/web/tests/hub_natural_end_stats_rebuild_test.php` : OK. Ce test simule une exécution sans mode/runtime dans son stub : il ne couvre pas la confusion révélée par la sonde.

Commandes avec préfixe Games depuis `/home/romain/Cotton`. Génération `npm run docs:sitemap` et `git diff --check` après consignation.

## SELECT ciblés et éléments à rapatrier

Schéma RAW rechargé : [DDL develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/data/schema/DDL.sql), sections `games_hubs_sessions` (2035–2044), `game_events` (1950–1959), `blindtest_sessions/players` (262–326), `cotton_quiz_sessions/players` (1030–1061). `games_hubs_players` et mappings sont documentés par le schema ensure local Global (292–320, 365–391), pas dans ce snapshot DDL. Les requêtes ci-dessous ne supposent pas leur existence pour résoudre les sessions. Aucun SELECT exécuté par l'agent.

```sql
-- 1. Identifiants exacts : ID membership != ID session historique.
SELECT hs.id AS membership_id, hs.id_hub, hs.id_session,
       hs.status, hs.membership_source,
       cs.id_type_produit, cs.flag_controle_numerique, cs.flag_session_demo,
       cs.id_securite AS session_token
FROM games_hubs_sessions hs
JOIN championnats_sessions cs ON cs.id = hs.id_session
WHERE hs.id_hub = 291 AND hs.id IN (959,973,974)
ORDER BY hs.id;

-- 2. Start/completion : lire les deux ensemble, une completion ne porte pas
--    les champs de mode/runtime (ils doivent être retrouvés sur le start).
SELECT cs.id AS historical_id, e.id, e.action, e.created_at,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json,'$.execution_id')) AS execution_id,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json,'$.hub_id')) AS hub_id,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json,'$.runtime_mode')) AS runtime_mode,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json,'$.source_session_id')) AS source_id,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json,'$.runtime_session_id')) AS runtime_id,
       JSON_UNQUOTE(JSON_EXTRACT(e.payload_json,'$.session_primary_id')) AS completed_session_id
FROM game_events e
JOIN championnats_sessions cs ON cs.id_securite = e.session_id
WHERE cs.id IN (27695,27696,27715,27716)
  AND e.action IN ('hub_execution_started','hub_execution_completed')
ORDER BY e.id;

-- 3. État et résultat moteur (ids candidats confirmés par logs).
SELECT cs.id AS historical_id, bs.id AS runtime_sql_id,
       bs.game_status, bs.updated_at, bs.total_players,
       bs.podium_json IS NOT NULL AS has_podium,
       LENGTH(bs.podium_json) AS podium_bytes
FROM championnats_sessions cs
LEFT JOIN blindtest_sessions bs ON bs.session_id = cs.id_securite
WHERE cs.id IN (27695,27696,27716);

SELECT cs.id AS historical_id, qs.id AS runtime_sql_id,
       qs.game_status, qs.updated_at, qs.total_players,
       qs.podium_json IS NOT NULL AS has_podium,
       LENGTH(qs.podium_json) AS podium_bytes
FROM championnats_sessions cs
LEFT JOIN cotton_quiz_sessions qs ON qs.session_id = cs.id_securite
WHERE cs.id = 27715;

-- 4. Résultats des deux joueurs ; ID SQL interne pour BT/Quiz.
SELECT cs.id AS historical_id, p.id, p.username, p.score, p.is_active
FROM championnats_sessions cs
JOIN blindtest_sessions bs ON bs.session_id = cs.id_securite
JOIN blindtest_players p ON p.session_id = bs.id
WHERE cs.id IN (27695,27716) AND p.username IN ('Cloclo','Remo12');

SELECT cs.id AS historical_id, p.id, p.username, p.score, p.is_active
FROM championnats_sessions cs
JOIN cotton_quiz_sessions qs ON qs.session_id = cs.id_securite
JOIN cotton_quiz_players p ON p.session_id = qs.id
WHERE cs.id = 27715 AND p.username IN ('Cloclo','Remo12');
```

Si ces noms ne correspondent pas à des lignes (équipe/normalisation), retourner les participations de ces seules sessions, pas une recherche globale. `is_active` n'est pas une preuve de connexion actuelle. Si JSON_EXTRACT indisponible sur l'environnement, retourner les payloads des seuls événements start/completed sélectionnés ; ne pas inventer de colonnes physiques `runtime_mode` dans `game_events`.

**Prérequis serveur levé** : l'utilisateur a confirmé DEV à jour sur `hub_soiree`, PROD sur `main`. Pas de copies séparées comparées ni d'accès serveur de l'agent ; le travail et les preuves SQL concernent DEV. Aucun rapatriement supplémentaire demandé pour ce correctif ciblé. START, manifeste, sitemap/index et journal AI Studio avaient été rechargés avant patch ; aucun fichier ciblé signalé hors workspace. Les contrats Games/Global et bridge ont également été rechargés aux mêmes chemins main/develop lors de la finalisation ; ils diffèrent, ce qui ne constitue pas une vérification de déploiement.

Pour la preuve de réception manquante, les exports WS restent utiles : `blindtest/web/server/server-logs.log` et `quiz/web/server/server-logs.log` avec rotations couvrant la recette. Ils ne conditionnent pas la correction backend désormais testée.

Données de recette encore demandées : heure des vraies fins S1/S2/S3, jeux réellement en défaut, URL et texte écran côté chaque joueur, présence/retour au premier plan, éventuel rechargement. L'écran n'a pas été déduit d'une absence de log. Les exports devraient permettre de corréler `HUB_NATURAL_END_CANVAS_ACCEPTED`, `HUB_SESSION_FINISHED_EMITTED`, `endGame`, `hub_natural_end_signal_received`, `player/end`, fermetures sockets et éventuelle navigation.

## Matrice de recette manuelle complémentaire

| Cas | Attendu |
|---|---|
| Historique autonome BT puis Quiz | Résultat historique personnel, aucune navigation Hub ; podium Master conservé. |
| Historique membre Hub sans aucune démo préalable | Même fin historique, compteur et bridge identités conservés. Pas d'auto-connexion intersession attendue. |
| **Démo Hub ouverte sur source S, puis officiel individuel S** | Après fin officielle : résultat historique Cloclo/Remo12 ; aucune clôture de l'exécution démo annexe, aucun `hub_execution=true` attribué à S par cette démo. Cas prioritaire de régression. |
| Officiel individuel après démo terminée / marker contaminé existant | Pas de faux `already_completed` officiel à partir du start démo ; tests de lecture de provenance, sans purge DB. |
| Vrai officiel orchestré Hub | Retour Hub Play habituel, pas d'écran historique forcé ; exécution officielle exacte close. |
| Retry après clear d'une vraie exécution officielle | Recovery/idempotence conservées, une completion, pas de perte du retour Hub. Tester focus passé à une autre session. |
| Vraie démo Hub / démo historique Pro | Résultat et retour temporisé de la première préservés ; fin historique de la seconde préservée ; focus/roster officiels inchangés. |
| Socket présente, arrière-plan, reconnexion à la fin | Distinguer envoi, réception et replay ; rang/score/total cohérents. Jamais remplacer un résultat absent par une simple carte sans preuve. |
| Mobile, écran large, Quiz/BT (solo et équipe) | Même classification backend ; tester réception `endGame` personnelle et carte visible, pas uniquement podium Master. |
| Bingo, si helper de fin partagé modifié | Contrôle non-régression de fin orchestrée/individuelle et temporalité visuelle ; aucun défaut Bingo déclaré par cet audit. |

Recette minimale utilisateur : noter ID/mode au lancement, ouvrir les deux Players par QR historique, jouer/terminer, conserver les consoles/logs jusqu'à l'affichage final, noter URL/écran avant toute fermeture ; refaire avec une démo Hub préalable non close, puis contrôler un vrai lancement Hub. Vérifier les événements SQL avant/après sans DELETE/UPDATE. Les fins S2/S3 doivent être capturées au-delà de la borne des logs actuellement fournis.
