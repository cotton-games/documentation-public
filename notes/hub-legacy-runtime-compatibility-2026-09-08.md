# Compatibilité runtime Hub legacy — 8 septembre 2026

Passe locale Global/Pro/Games, non commitée et non déployée. Aucun accès DEV/PROD, DB existante, SSH ou navigateur. Seuls les lecteurs documentaires publics requis ont été consultés. Aucun DDL final PROD, script de backfill, manifeste définitif des 68 sessions / 58 Hubs ni commande de déploiement construit.

## Preuves documentaires et écart au code

Sources consultées avant les patches, URL RAW exacte et section :

- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md — « Parcours », règle preuve d'abord et discipline de génération.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md et https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt — navigation initiale et index agent-first.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md — règles générales de documentation.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md — « Routing rules », R11, « Post-edit required actions » ; R13 ajouté localement pour ce périmètre.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md — « Actions réalisées », contexte courant et assertion QR Remote préexistante.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md — « Update 2026-07-27 - Hubs: identité stable et rattachement canonique », « Etat 2026-07-17 - Cascade branding Hub/session », « Etat 2026-07-17 - Publication et lots Hub canoniques », « Update 2026-07-31 - Participations probables Hub et présence runtime », « Update 2026-09-01 - Création de préparation Hub sans offre ».
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/README.md — « Etat 2026-07-17 - Dashboard soirée/événement: publication et lots Hub canoniques ».
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md — « Update 2026-07-17 — Hub: publication et lots persistés » et contrats Master/Remote/Play.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/canvas-bridge.md — bloc « bridge-contract ».
- Journal obligatoire : https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb — Markdown brut décodé depuis `const raw`, sections EN COURS/TODO/Fait, dernière mise à jour 28/08. Mentions de `global/app/modules/ecommerce/app_ecommerce_functions.php`, pages WWW et AI Studio : modifications hors workspace possibles signalées avant patch. Aucun fichier Hub ciblé annoncé ; aucune égalité avec serveur revendiquée. Ecommerce inspecté sans modification.

Les anciennes sections sur l'import des lots de la première session et sur le reconcile à la lecture contredisaient le contrat d'identité non destructive ; elles sont actualisées. Une règle faisant de privé/non publié une ACL d'URL directe est **non trouvé dans la documentation** : l'audit du code distingue filtrage des listes et accès direct, sans inventer de nouvelle politique d'accès.

## A. Six défauts : causes, avant/après

Les chemins applicatifs précis sont inventoriés plus bas ; les noms abrégés Global/Hub désignent `web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

| Défaut | Cause et comportement antérieur | Correctif et comportement obtenu |
|---|---|---|
| 1. Membership partiel | Global/Hub `sessions_reconcile` concluait dès qu'un COUNT actif était positif ; les 2 absents sur 3 restaient absents. | Comparaison de toutes les sessions officielles configurées attendues pour client/date/opération exacte. Les actives du même Hub sont laissées intactes, les absentes sont ajoutées, les étrangères/inactives conflictuelles sont signalées sans déplacement. Un conflit retourne un état incomplet, pas un succès complet. Répétition idempotente. |
| 2. Mutation de consultation | Pro day/event/onboarding/personnalisation/debug appelaient `app_evenement_pivot_ensure_for_day`, qui pouvait normaliser/rattacher des sessions et créer un pivot ; certains chemins appelaient le get-or-create Hub. | Nouveau `app_evenement_pivot_resolve_for_day` lit le contexte persistant, et `app_games_hub_existing_for_program` exige un programme complet rattaché au même Hub. Pas de création ni réconciliation dans ces lecteurs. Les writers de modification explicite restent séparés. Les champs historiques restent identiques dans les snapshots répétés. |
| 3. Mauvais Hub choisi | Global/Hub `canonical_existing_for_context` utilisait des poids fonctionnels, un fallback pouvait privilégier un candidat ; `find_for_context` utilisait LIMIT 1. | Membership actif d'abord ; réparation seulement avec un unique candidat exact démontré. Plusieurs candidats => ambiguïté journalisée. Aucune sélection par poids/ID/ancienneté. Échec SQL distinct de l'absence, sans création après lookup_failed. Ancien helper de poids laissé sans appel dans la résolution. |
| 4. Anciennes entrées | Pro play_classic et Games Organizer/Player/Remote pouvaient continuer un parcours de session autonome malgré son membership ; la résolution legacy pouvait provoquer un reconcile. | Les entrées nues officielles résolvent le membership puis Master/Play Hub ; exceptions démo/exécution explicite/terminal conservées. Remote ne crée ni ne divulgue de capacité à partir d'un simple token de session : accès existant + propriétaire/session liée, sinon 409. Sans relation : fallback legacy diagnostiqué, aucun Hub opportuniste. |
| 5. Données de portée session | Getter lots importait la première session personnalisée et pouvait masquer les autres ; héritage branding isolé terminait trop tôt ; les probables Hub pouvaient remplacer la liste legacy. | Lots propres prioritaires, consensus complet uniquement en projection, divergences affichées par partie et résultat Play résolu sur la session exacte. Cascade branding complétée sans copie. Publication séparée des flags de session. Union des probables legacy/Hub sans création de présence à la lecture, clés équipe distinctes. |
| 6. Ancienne offre | Home filtrait les sessions sur l'offre positive courante/0, excluant des programmations avec ancienne offre positive ; regroupements heuristiques risquaient un sous-programme Hub. | Home futur/historique sans prédicat ancien id_offre_client. Agenda résout par membership et conserve les groupes historiques si incomplets. Dashboard et personnalisation lisent l'identité canonique même après changement d'usage du compte. Guards effectifs de lancement/checkout/support conservés. |

## B. Décisions et audit des effets de bord

- Membership canonique > heuristique ; les checks propriétaire/Hub actif des surfaces restent applicables et ne remplacent pas l'identité par un autre candidat.
- Ambiguïté = état d'erreur diagnostiquable, jamais choix automatique. Un programme partiel ne devient pas visuellement son sous-ensemble déjà rattaché.
- Les bootstraps de consultation corrigés ne modifient aucun champ métier de `championnats_sessions` : date, client, opération, offre, format/produit, lots, branding, publication ou contexte.
- Données divergentes conservées à leur niveau ; aucune première session promue arbitrairement. Les lots Hub explicitement enregistrés restent conservés, les lots propres restent prioritaires pour la session. Un Hub initialisé vide ne réimporte pas le legacy.
- Préparation/reprise structurelle indépendante de l'offre effective ; les droits commerciaux restent évalués pour les actions qui les requièrent.

| Graphe suivi | Lecture / effets possibles après patch |
|---|---|
| Pro day/Home/Agenda/personnalisation -> `existing_for_program` -> `get_for_session` -> memberships | Lecture et logs ; pas de création, reconcile, changement session ou déplacement. Journée vide : un Hub actif unique déjà présent peut être lu. |
| Pro contexte -> `pivot_resolve_for_day` -> `pivot_sessions_get_for_day` -> `evenement_get_detail` | Lecture du membership puis opération canonique ou historique, propriétaire vérifié ; conserve même l'événement historique non géré/non publié. `attached_count=0`. Le helper de détail peut appeler l'assurance de schéma existante ; aucun UPDATE métier session. |
| Détail session -> naming/participants/état de jeu | Helpers suivis pour les lecteurs utilisés : pas de normalisation du pivot historique. Le runtime complet possède toujours ses propres compteurs/presences/stats et commandes ; aucune promesse générale de zéro écriture à chaque poll. |
| `sessions_reconcile` explicite -> SQL membership | Ajoute uniquement les liens manquants non conflictuels ; aucune écriture des champs session, pas de déplacement étranger. Ce filet de réparation n'est pas appelé par les lecteurs corrigés. |
| `prizes_get` -> programme canonique complet -> resolver | Lecture seule, même si un appelant fournit un sous-ensemble. `prizes_bootstrap_from_sessions` reste un helper explicite sans appel nominal ; refus divergence/absence de consensus. `prizes_save` reste un writer Hub annoncé. |
| `branding_resolve_for_session` -> membership -> `branding_get` -> `get_detail_merged` | Session > Hub > événement > réseau > compte > Cotton, champ par champ. Hydratation des assets, aucune copie de branding entre sessions. |
| `public_resolve` -> publication/programme/public_sessions | Conserve programme complet et projection filtrée distincts. Le statut événement privé/non publié n'est ni effacé ni déduit d'une seule session. WWW legacy filtre les listes avec privé=0 et online=1 ; accès direct historique non protégé par ces flags. Tests propriétaire/anonyme portent sur le contrôle réel `app_evenement_access_get_control`, pas une ACL inventée dans le resolver. |
| `probable_list/count/get_by_ep` -> tables Hub + legacy des membres actifs | Projection et dédoublonnage EP ; équipe conservée sous clé legacy_team et non convertie en EP. État Hub confirmé/annulé supprime la projection déclarée en doublon. Pas d'INSERT joueur ou présence à la lecture. |
| Inscription EP réelle -> fenêtre existante -> `probable_confirm` | Matérialisation Hub permise à cette action, confirmation idempotente après présence réelle ; pas de suppression/réécriture legacy. Annulation explicite conserve aussi la source historique. |
| Ancienne Remote -> lookup/validate accès existant | Résolution sans création de credentials. Le parcours Remote déjà autorisé conserve ses écritures normales de liaison/présence et les commandes serveur. Aucun focus déplacé par la nouvelle redirection. |
| Focus/présentation/lancement | Aucune nouvelle commande de focus ni nouveau poll. Les commandes explicites et ponts d'exécution existants restent propriétaires des transitions et du lancement commercial. |

### Anciennes entrées inventoriées

- Pro `/extranet/start/games/day/YYYY-MM-DD` : Dashboard et ses helpers événement, debug et personnalisation ; résolution de jour readonly. Home et Agenda menant à ce pivot gardent toutes les sessions attendues.
- Pro `ec_start_sessions_play_classic.php` : session officielle possédée et rattachée -> `/hub/{hub_token}/master` avant le guard de l'ancien lancement autonome ; action de lancement effective garde ses propres contrôles.
- Games `web/modules/app_orga_ajax.php` : GET Organizer/Master legacy -> Master Hub. Exclusions `hub_launch`, `hub_execution`, `master_view=individual`, démo et historique terminé.
- Games `web/player_canvas.php` : entrée Player nue -> `/hub/{hub_token}/play`, hors identité/tokens Hub existants et historique terminé ; chemin d'exécution réel inchangé.
- Games `web/remote_canvas.php` : entrée Remote legacy -> accès Remote Hub existant autorisé ; propriétaire Pro ou session Remote déjà liée exigé ; sans accès, 409 avec invitation à ouvrir depuis l'espace organisateur. Sans membership, fallback historique.
- Liens publics historiques WWW/Play : accès/publication et fiches session inspectés, aucun nouveau redirect global ni mutation ajouté. Le retour Hub déjà résolu utilise les helpers partagés ; aucune assimilation des flags de liste à une ACL.

## C. Fichiers modifiés

Liste relative à chaque dépôt ; tous les changements applicatifs de cette passe sont ci-dessous. Les dossiers d'audits préexistants `documentation/tmp/audit-hub-*` ne sont pas modifiés.

### global

- `web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- `web/app/modules/jeux/sessions/app_sessions_functions.php`
- `web/app/modules/operations/evenements/app_evenements_functions.php`
- `web/tests/hub_identity_stability_contract_test.php`
- `web/tests/hub_legacy_runtime_compatibility_test.php`
- `web/tests/hub_operation_branding_cascade_test.php`
- `web/tests/hub_participation_counters_contract_test.php`
- `web/tests/hub_prizes_test.php`
- `web/tests/hub_publication_prizes_contract_test.php`

### pro

- `web/ec/modules/communication/home/ec_home_standard_composition_test.php`
- `web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
- `web/ec/modules/tunnel/start/ec_start_legacy_offer_visibility_test.php`
- `web/ec/modules/tunnel/start/ec_start_sessions_day.php`
- `web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`
- `web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`
- `web/ec/modules/tunnel/start/ec_start_sessions_day_event_helpers.php`
- `web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`
- `web/ec/modules/tunnel/start/ec_start_sessions_day_hub_debug.php`
- `web/ec/modules/tunnel/start/ec_start_sessions_day_personalization_helpers.php`
- `web/ec/modules/tunnel/start/ec_start_sessions_list.php`
- `web/ec/modules/tunnel/start/ec_start_sessions_play_classic.php`

### games

- `web/modules/app_hub_view_helpers.php`
- `web/modules/app_orga_ajax.php`
- `web/player_canvas.php`
- `web/remote_canvas.php`
- `web/tests/hub_legacy_entry_routes_test.php`
- `web/tests/hub_legacy_session_prizes_test.php`

### documentation

- `HANDOFF.md`, `CHANGELOG.md`, `DOCS_MANIFEST.md` (R13).
- `canon/repos/global/README.md`, `canon/repos/global/TASKS.md`.
- `canon/repos/pro/README.md`, `canon/repos/pro/TASKS.md`.
- `canon/repos/games/README.md`, `canon/repos/games/TASKS.md`.
- `canon/interfaces/canvas-bridge.md` (bridge-contract).
- `notes/hub-legacy-runtime-compatibility-2026-09-08.md` (ce rapport).
Index/sitemap générés par `npm run docs:sitemap` ; les estampilles utilisent le HEAD local, sans édition manuelle :

- `SITEMAP.md`
- `SITEMAP.ndjson`
- `SITEMAP.txt`
- `canon/INDEX.md`
- `canon/data/INDEX.md`
- `canon/data/schema/INDEX.md`
- `canon/front/INDEX.md`
- `canon/interfaces/INDEX.md`
- `canon/repos/INDEX.md`
- `canon/repos/bingo.game/INDEX.md`
- `canon/repos/blindtest/INDEX.md`
- `canon/repos/games/INDEX.md`
- `canon/repos/global/INDEX.md`
- `canon/repos/play/INDEX.md`
- `canon/repos/pro/INDEX.md`
- `canon/repos/quiz/INDEX.md`
- `canon/repos/www/INDEX.md`
- `canon/runbooks/INDEX.md`
- `notes/INDEX.md`
- `notes/archive/INDEX.md`
- `specs/INDEX.md`
- `specs/tests/INDEX.md`

## D. Tests et commandes

Exécution locale PHP sur fixtures/mocks, sans DB existante ni serveur. Les tests de routes exécutent les branches réelles avec interception des redirections/exit. Les tests de source vérifient en complément le câblage ; ils ne constituent pas une recette navigateur ni une preuve de concurrence MyISAM réelle.

Résultat : **30 suites PASS / 31 ; 1 FAIL préexistant**. Chaque commande ci-dessous est à lancer depuis son dépôt.

| Dépôt | Commande | Résultat |
|---|---|---|
| global | `php web/tests/hub_identity_stability_contract_test.php` | PASS |
| global | `php web/tests/hub_legacy_runtime_compatibility_test.php` | PASS |
| global | `php web/tests/hub_publication_prizes_contract_test.php` | PASS |
| global | `php web/tests/hub_operation_branding_cascade_test.php` | PASS |
| global | `php web/tests/hub_probable_participations_contract_test.php` | PASS |
| global | `php web/tests/hub_prizes_test.php` | PASS |
| global | `php web/tests/hub_participation_counters_contract_test.php` | PASS |
| global | `php web/tests/hub_ep_return_intent_test.php` | PASS |
| global | `php web/tests/hub_remote_control_contract_test.php` | PASS |
| global | `php web/tests/hub_paper_cold_runtime_bootstrap_contract_test.php` | PASS |
| global | `php web/tests/hub_demo_mode_contract_test.php` | PASS |
| global | `php web/tests/hub_delete_service_contract_test.php` | PASS |
| global | `php web/tests/programming_quick_hub_service_contract_test.php` | PASS |
| games | `php web/tests/hub_legacy_entry_routes_test.php` | PASS |
| games | `php web/tests/hub_legacy_session_prizes_test.php` | PASS |
| games | `php web/tests/hub_probable_play_contract_test.php` | PASS |
| games | `php web/tests/hub_demo_qr_reentry_contract_test.php` | PASS |
| games | `php web/tests/hub_natural_end_stats_rebuild_test.php` | PASS |
| games | `php web/tests/hub_individual_terminal_master_test.php` | PASS |
| games | `php web/tests/hub_branding_sync_test.php` | PASS |
| games | `php web/tests/hub_remote_contract_test.php` | FAIL préexistant QR HTML |
| games | `php web/tests/hub_presentation_runtime_separation_test.php` | PASS |
| games | `php web/tests/hub_context_fast_path_test.php` | PASS |
| play | `php web/tests/ep_hub_detail_contract_test.php` | PASS |
| pro | `php web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php` | PASS |
| pro | `php web/ec/modules/tunnel/start/ec_start_sessions_list_agenda_test.php` | PASS |
| pro | `php web/ec/modules/tunnel/start/ec_start_dashboard_program_helpers_test.php` | PASS |
| pro | `php web/ec/modules/tunnel/start/ec_start_legacy_offer_visibility_test.php` | PASS |
| pro | `php web/ec/modules/tunnel/start/ec_start_library_hub_add_flow_test.php` | PASS |
| pro | `php web/ec/modules/communication/home/ec_home_standard_composition_test.php` | PASS |
| pro | `php web/ec/modules/communication/home/ec_home_hub_branding_visual_test.php` | PASS |

Le FAIL unique de `games/web/tests/hub_remote_contract_test.php` attend l'ancien attribut HTML `data-hub-qr-clickable` (assertion ligne 330). Même échec reproduit en remplaçant uniquement le `$helpersSource` du test par `git show HEAD:web/modules/app_hub_view_helpers.php`, conservé dans `/tmp/hub-baseline-helpers.php`. Test/renderer de référence proviennent du HEAD ; aucune correction QR hors périmètre. Le Handoff signalait déjà cette assertion avant cette passe.

Contrôles complémentaires effectués : `php -l <fichier>` pour les **27 fichiers PHP** modifiés/nouveaux : PASS ; `git diff --check` dans Global, Pro, Games et documentation : PASS. `npm run docs:sitemap` depuis documentation : génération automatique attendue et vérifiée, aucun fichier `tmp/audit-hub-*` publié (le générateur ne parcourt que racine/canon/specs/notes).

### Matrice minimale

| Cas demandé | Couverture locale |
|---|---|
| 1–3. Membership complet, partiel, absent | identity_stability : 0/3, 1/3, 2/3, 3/3 en soirée et événement ; foreign active refusé, pas de vol de lien. |
| 4–5. Membership autoritaire, deux Hubs valides | identity_stability : usage/contexte divergents ne remplacent pas le Hub ; ambiguïté explicite. |
| 6. Anciennes URLs | legacy_entry_routes : destinations Master/Play/Remote, exceptions runtime/terminal, membership absent, contrôle Remote. |
| 7. Aucune mutation session | identity_stability + legacy_runtime : snapshots complets répétitifs, Hub présent/absent et memberships présents/absents ; fixture refuse les UPDATE métier. |
| 8–10. Lots identiques/divergents/un seul personnalisé | prizes + legacy_runtime : consensus, aucun partage divergent, aucune promotion d'un sous-programme ; legacy_session_prizes : résultat de session exact, Quiz/Bingo. |
| 11. Branding propre/client | operation_branding_cascade : deux sessions, personnalisation de l'une, fallback client de l'autre, snapshot inchangé. |
| 12–13. Événement privé/non publié, flags divergents | legacy_runtime : flags conservés, programme complet versus public_sessions, contrôle propriétaire/anonyme existant. |
| 14. Probables joueur/équipe et fenêtre | legacy_runtime + probable_participations + probable_play : union, dédoublonnage, aucune présence avant fenêtre, confirmation réelle/répétée, legacy intact. |
| 15–17. Offre active/ancienne positive/0, absence effective | legacy_offer_visibility : sélections Home indépendantes de l'option offre, toutes les programmations conservées ; suites Dashboard/Agenda/guards existantes en complément. |
| 18. Idempotence | identity_stability et legacy_runtime : lectures/réparation/confirmation répétées, absence de duplication et snapshots stables. |

## E. Risques résiduels et rollback

| Classe | État |
|---|---|
| Corrigé localement | Les six défauts ci-dessus, avec tests ciblés et contrats actualisés. Aucune affirmation que les fichiers distants ont changé. |
| Couvert par la future migration | Création déterministe des 58 identités/68 liens, exhaustivité et unicité, propriété/contexte, conservation des valeurs legacy. Sans ces liens, le runtime reste volontairement en fallback et ne finit pas le backfill au premier accès. |
| À vérifier avant activation PROD | Recette intégrée et navigateur interdits dans cette passe, données réelles non lues ; aucune certification PROD possible. Concurrence de writers/reconcile MyISAM non testée en DB réelle et sans nouveau verrou global ; la future maintenance doit empêcher les écritures concurrentes et contrôler les postconditions. Coût accru des projections probables (list/count lisent les sources) à mesurer sur volumes réels. |
| Échec de test restant | Assertion HTML QR Master préexistante ; la suite complète n'est pas verte. À traiter dans son chantier QR, sans masquer l'échec. |
| Données historiques déjà transformées | Les lots Hub déjà importés arbitrairement avant ce correctif ne peuvent être distingués des valeurs explicitement saisies sans provenance. Aucun nettoyage automatique : audit/correction explicite séparés si de tels cas sont établis. |
| Hors périmètre | Changement de politique ACL des liens publics, commerce/ecommerce, moteurs WS, refonte Remote/focus, schéma transactionnel, déploiement, DDL final et backfill PROD. |

Rollback avant activation : retirer conjointement ce lot Global/Pro/Games et ses tests/docs, en préservant les modifications étrangères au lot. Aucun changement distant ou donnée migrée à annuler. Un rollback ultérieur du runtime doit tenir compte des guards retirés et ne doit pas être présenté comme une annulation du futur backfill.

## F. Impact sur la future migration

La séquence reste `PRECHECK -> DDL -> backfill déterministe -> contrôles -> activation du code Hub`. Le paquet futur doit fixer l'identité de chaque Hub et chaque membership, contrôler les 68 liens vers les 58 Hubs attendus et leur unicité avant activation. Ce rapport n'est ni ce manifeste ni une preuve des comptes en PROD.

Après ces préconditions, `legacy -> 58 Hubs / 68 memberships -> nouveau parcours` utilise les relations persistées au premier accès. Le code ne réécrit pas les pivots historiques pour rendre les sessions compatibles et ne complète pas silencieusement un manifeste incomplet. Les champs propres aux sessions restent consultables ; seules les valeurs Hub réellement communes/explicitement choisies appartiennent au Hub. Les anciennes URLs suivent les mêmes identités stables ; les droits commerciaux actuels s'appliquent aux actions, sans faire disparaître la préparation historique.
