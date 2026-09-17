<!-- AUTO-UPDATE:BEGIN id="hub-quick-add-renewal-20260916" owner="codex" -->
# Hub : Quick Add et remplacement automatique — 16/09/2026

Statut : deux correctifs locaux indépendants, non déployés. Aucun accès DB réel, restart, commit ou publication. Journal AI Studio raw, START, SITEMAP, NDJSON, README, manifest et HANDOFF relus avant modification ; aucun fichier ciblé signalé modifié hors workspace. Logs Games/Global rechargés lus, sans exposer les tokens des URL.

## Complément affichage / wording — 16/09/2026

Le premier patch transmettait un Hub vide au helper lors du SSR Master : le renderer lisait `$view['hub']`, absent du view-model, puis le JS conservait ce faux `can_renew_theme=false` malgré la réponse settings positive. Remote disposait déjà du vrai Hub. Correction locale dans les deux modules Games uniquement : contexte `theme_renewal_hub` réservé à ce calcul, sans toucher aux règles métier ou aux autres consommateurs du view-model ; libellé commun du payload settings, `↻ Proposer une autre playlist` pour Blind Test/Bingo et `↻ Proposer d’autres séries` pour Quiz. Pro les porte directement dans son template : pas de resolver existant trouvé, pas de modification Pro.

Cette précision remplace le libellé générique décrit dans l'audit initial ci-dessous. Tests ajoutés Games `hub_theme_renewal_display_test.php` et `hub_theme_renewal_display_dom_test.mjs` : 60 contrôles PHP, vraies projections Master/Remote et JS, trois jeux/quatre états, concordance Pro, aucun CTA carte, gardes stale conservées. Reproduction avant correction puis succès ; suites de non-régression et syntaxe/diff OK. Local non déployé, recette visuelle réelle restante.

## 1. Quick Add : commit réussi, faux échec d'affichage

### Preuves et séquence

- `games/web/modules/app_hub_view_helpers.php`, `games_hub_handle_quick_session_action:1595` : POST `quick_session_create`, capacité Master/CSRF/Hub actif/fenêtre, puis service Global. Aucun changement de ce handler.
- Global `app_programming_recommendations_functions.php`, `app_programming_quick_hub_create_from_game:3484` → suggestion → `create_from_proposal:3339` : idempotence, création, contenu, membership actif confirmé (`:3457`, source `schedule_plan`), journal de succès, réponse `session_ids`. Games sélectionne la nouvelle session avec `reason=quick_add` et retourne les identifiants ; il ne retourne pas le HTML ni une révision cible.
- `games/logs/error_log:885,898,912,921,952,1238,1245,1255` : Hub320, sélection Quick Add validée des sessions27821→27828 entre13:43:44 et13:53:46. Aucune exception PHP fatale trouvée dans les logs Games/Global consultés. La dernière entrée comprend aussi `QUIZ_NUMERIC_AUTO_PACK_BUILD_PARTIAL` pour27828 : anomalie de génération distincte, non corrigée par ce patch.
- Révision Master : `games_hub_preparation_revision:437`, empreinte des membres et champs `id_produit/lot_ids`. `hubMasterPreparationRefresh:11136` vérifie la révision puis remplace les blocs depuis le rendu serveur. Un poll déjà en vol retourne immédiatement `{ok:false,reason:'in_flight'}` (`:11141`). **Premier point de divergence** : l'ancien `refreshCreatedSessionCard` convertissait ce résultat en `PROGRAM_REFRESH_FAILED`, avant toute vérification de la carte courante.
- Autre faux négatif démontré : l'ancien `waitForQuickAddCard` exigeait une carte *sélectionnée*. Une carte déjà rendue sans sélection pouvait donc déclencher une erreur. Son contrôle initial pouvait également résoudre la promesse avant d'installer inutilement observer/timer.
- Non trouvé dans les logs : raison JavaScript exacte de chaque erreur affichée, exception DOM ou preuve de latence DB. La concurrence et le faux négatif de sélection sont reproduits avec le vrai JavaScript avant patch ; ils ne sont pas attribués arbitrairement à chaque occurrence de recette.

### Correction

Uniquement le module Quick Add JavaScript de `app_hub_view_helpers.php` : vérifier la présence de l'identifiant créé dans le Programme, avant/après chaque refresh, indépendamment de la sélection ; quatre tentatives forcées espacées de300ms, puis observation DOM bornée de8s. Un poll concurrent ou une erreur après insertion DOM ne produit plus de faux échec. Nettoyage observer/timer. Après commit confirmé, les choix de création restent désactivés ; le retry ne fait que relire l'affichage. Fermer puis rouvrir l'ajout reste une nouvelle intention volontaire.

Le backend Quick Add, sa clé d'idempotence, le membership et les révisions ne sont pas modifiés. Aucun nouveau bus.

### Tests

`games/web/tests/hub_quick_add_refresh_test.mjs` exécute le module réel : succès immédiat, poll concurrent, projection retardée, carte déjà présente non sélectionnée, erreur après mutation DOM, vrai échec puis retry, double clic et une seule création. Le même test sur le fichier d'avant correction échoue sur `immediate` (sélection exigée) puis sur `concurrent` (test isolé).

`hub_program_mutation_revision_test.php` : vrais producteurs Master et Remote/Pro, SQL simulé, cinq projections ajout/remplacement/retrait/vide/réajout à timestamp identique. Les empreintes changent bien sans dépendre de la seconde de `date_maj`.

## 2. Remplacement automatique dans Paramétrer la partie

### Contrat retrouvé et nouvelle éligibilité

Ancien helper Games `games_hub_session_theme_renewal_is_eligible:1440` : origine strictement `quick_hub_create`, session pending et services présents. Cela excluait Dashboard/Agenda/bibliothèque/legacy et même des rattachements Quick Add actuels `schedule_plan`. Bouton carte Master/Remote `↻`, libellé réellement trouvé : **Autre proposition** ; aucun libellé Hub spécifique par jeu trouvé à cet emplacement.

Le helper délègue désormais à Global `app_programming_theme_renewal_hub_session_is_eligible:3758` : propriétaire concordant, Hub actif, configuration complète, aucun focus actif, état canonique pending (inclut contrôle suspension), edit-state non verrouillé, aucune exécution officielle ouverte, fenêtre `before/open`, jeu et sélection existante compatibles. L'origine n'intervient plus. Les alternatives réellement disponibles restent validées par le planner ; aucune génération pendant le rendu de la modale. Une absence d'alternative conserve l'erreur existante.

Préparation/offre : les services existants permettent déjà la préparation sans offre (`app_programming_quick_hub_games_get:2565`, plan/apply sans garde commerciale de lancement). Ce contrat est conservé pour les prospects ; aucune nouvelle exigence d'offre active n'est introduite. Autorité organisateur/CSRF/instance et catalogue client restent inchangés ; l'offre officielle reste contrôlée au lancement.

### UI et autorité

Les icônes directes sont retirées des cartes SSR et de la reconstruction Remote. Bouton secondaire **Autre proposition** dans le contenu des réglages, sous le contexte thématique et avant les options, distinct de la zone destructive et du footer. Tokens de texte de la surface, focus clavier, affichage conditionnel commun. Les réglages non enregistrés ne sont pas réinitialisés par le remplacement ; boutons de sauvegarde/suppression/fermeture verrouillés pendant la requête. Erreurs affichées dans la modale, exclusions temporaires conservées par session même après reconstruction des cartes, protection double clic conservée.

Master conserve `quick_session_theme_renew` → handler existant → plan/apply. Remote conserve la même commande HTTP vers `games_hub_remote_handle_theme_renewal_action:629`, autorité serveur qui appelle le même service Global ; elle ne génère aucun contenu dans le navigateur. L'action existante n'utilisait pas la file de lancement vers le Master : aucune nouvelle file/route n'est inventée. Son snapshot/polling confirme le résultat. Master force aussi son refresh existant après mise à jour de carte.

Global `app_programming_theme_renewal_apply_for_session:3783` ajoute seulement une enveloppe pour le scope Hub : verrou déjà partagé avec lancement/suppression, relecture Hub/membership, refus du retrait journalisé et revalidation de l'éligibilité après acquisition. `finally` libère le verrou. Le corps historique est conservé à l'identique sous `_unlocked:3808`, y compris CAS `expected_current_selection`, catalogue, exclusions et mutations. Hors scope Hub, le chemin historique reste direct.

### Jeux et paramètres

- Quiz type5 : même nombre de séries, préfixes `L/T/N`, ordre/gabarit et catégories du planner ; variantes papier/numérique conservées. Quiz historique type1 non élargi.
- Blind Test type4 : remplacement `id_produit`, format/ordre et options indépendantes conservés.
- Bingo types3/6 déjà reconnus par le service : même matérialisation de playlist client puis rattachement, aucune attribution de grilles par cette action.
- Durée, propositions, format réponses, pilotage, papier/numérique et branding ne sont pas écrits par le remplacement. La comparaison du corps applicateur avant/après confirme son identité.

### Concurrence et propagation

Tests d'éligibilité des origines Quick Add ancien/`schedule_plan`, Dashboard, Agenda, bibliothèque, historique et legacy, pour les trois jeux. Refus running/suspended/completed, contenu incomplet/incompatible, propriétaire divergent, exécution officielle, fenêtre expirée. Test du vrai applicateur avec adaptateurs mémoire : écriture sous verrou, options conservées, seconde sélection attendue devenue obsolète refusée ; lancement/retrait/disparition/propriétaire/fenêtre modifiés à l'acquisition revalidés, verrou occupé refusé. Pas de test MySQL concurrent réel.

Révisions inchangées : Master empreinte ses sessions ; `app_games_hub_remote_business_revisions_get:891` inclut membership, `id_produit`, `lot_ids` et configuration dans son empreinte (`:941-960`). Remote et Dashboard Pro consomment ce même producteur via les polls existants. Les suites Remote et Pro vérifient la reconstruction ; aucune modification Pro.

## Fichiers de ce passage

Applicatif Games : `web/modules/app_hub_view_helpers.php`, `web/modules/app_hub_remote_ajax.php`, `web/includes/canvas/css/hub_launch_confirmation.css`.
Applicatif Global : `web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`.

Tests Games ajoutés : `hub_quick_add_refresh_test.mjs`, `hub_theme_renewal_dom_test.mjs`, `hub_program_mutation_revision_test.php`. Adaptés : `hub_session_settings_test.php`, `hub_remote_contract_test.php`, `hub_remote_polling_test.mjs`, `hub_session_removal_dom_test.mjs`.
Tests Global : nouveau `hub_theme_renewal_guard_test.php` (70 contrôles), fixtures `session_theme_renewal_apply_test.php` adaptées ; assertion d'allowlist `hub_remote_control_contract_test.php` actualisée avec `remove_session` déjà livré localement dans le patch précédent.

## Validation exécutée

Depuis Games : `php web/tests/hub_session_settings_test.php`, `hub_remote_contract_test.php`, `hub_empty_commercial_test.php` (105 contrôles), `hub_program_mutation_revision_test.php`, `hub_modal_contrast_test.php` ; `node web/tests/hub_quick_add_refresh_test.mjs`, `hub_theme_renewal_dom_test.mjs`, `hub_session_settings_dom_test.mjs`, `hub_session_removal_dom_test.mjs`, `hub_remote_polling_test.mjs`, `hub_player_qr_test.mjs`.
Depuis Global : `php web/tests/hub_theme_renewal_guard_test.php`, `session_theme_renewal_planner_test.php`, `session_theme_renewal_apply_test.php`, `hub_session_removal_test.php` (162 contrôles), `hub_remote_control_contract_test.php`.
Depuis Pro : `php web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php` et `ec_start_dashboard_quick_source_hub_test.php` (38 contrôles).

Suites listées OK, syntaxe PHP/JS et `git diff --check` vérifiés. Documentation : README/TASKS Games et Global, bridge, HANDOFF, présente note, index/sitemap régénérés.

Réserves : recette navigateur authentifiée desktop/mobile, véritables latences et concurrence MySQL non exécutées. Les logs seuls ne prouvent pas la cause JavaScript de chaque erreur de recette. La trace Quiz de génération partielle demeure hors périmètre. Pour une diffusion ultérieure, publier Global avec Games pour le bloc remplacement ; le bloc Quick Add peut être retiré/repris séparément. Rollback : retirer les seuls hunks de chaque bloc, en conservant suppression, contraste et correction du Hub vide précédents.
<!-- AUTO-UPDATE:END id="hub-quick-add-renewal-20260916" -->
