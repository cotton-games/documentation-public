## Update 2026-09-04 - Hub: génération canonique de routage Remote

Global persiste dans `games_hubs.remote_routing_generation` le compteur causal de navigation et dans `remote_routing_intent_id` sa clé d'idempotence. Après création ou réutilisation réussie d'une exécution, `app_games_hub_session_launch_from_master(...)` publie atomiquement l'intention: le même `launch_intent_id` conserve la génération, toute nouvelle intention l'incrémente, y compris lorsque l'`execution_id` reste identique. Les commandes Remote utilisent `remote-command-{id}`; les clics Master fournissent ou reçoivent un identifiant serveur normalisé.

`app_games_hub_remote_client_routing_state_get(...)` est l'unique producteur du contrat `target + session_id + execution_id + routing_generation + remote_url + runtime_kind + joinable`. `runtime_kind=existing` devient joinable dès la décision centrale, sans présence runtime ni readiness supplémentaire. `new` et `recreated` restent non joinables jusqu'à la readiness exacte de l'exécution. La présence historique reste exposée uniquement comme diagnostic. L'URL historique transporte la génération utilisée afin que le retour fournisse le couple exact à l'anti-rebond.

La décision de runtime reste dans Global après claim Hub Master: une exécution officielle ouverte, non démo et `running` produit `existing`, conserve son identifiant, saute l'injection papier et force l'absence de readiness; sinon le runtime neuf/recréé conserve injection éventuelle et readiness. `remote_transition_payload_json` demeure un relais UX borné, sans `transition_id` propre, et reprend la génération canonique. Présentation et Hub Play ne changent pas.

## Update 2026-09-03 - Futur changement d'offre Cotton → Stripe → Cotton

Le contrat cible des clients en propre est documenté dans `canon/interfaces/ecommerce-offer-change.md`. Cotton reste l'autorité sur l'intention commerciale (offre 12, jauge, périodicité, éligibilité, pricing, remise et upsell); Stripe n'exécute une mutation qu'après validation Cotton, puis les webhooks synchronisent la réalité active et facturée. Ni un Price Stripe ni un `customer.subscription.updated` isolé ne permettent de reconstruire l'intention.

La V1 n'autorise qu'une hausse stricte de jauge sans réduction de durée de période. Le Customer Portal n'est pas le parcours moderne de changement commercial; la cause historique supposée de sa rupture reste une hypothèse à auditer. Les offres déléguées hors cadre sont exclues et conservent leur contrat snapshot/repricing au renewal.

## Update 2026-09-03 - Période de facturation Stripe persistée

Les offres adossées à une subscription Stripe disposent de deux champs dédiés, `stripe_current_period_start` et `stripe_current_period_end`. Le résolveur partagé lit en priorité les périodes portées par `subscription.items.data[*]` (forme Basil): tout item portant au moins une des deux bornes est pertinent, une borne partielle est invalide et plusieurs items ne sont acceptés que si leurs deux bornes sont identiques. En l'absence de période sur les items, il retombe sur les propriétés racine legacy. Une forme absente, incomplète, invalide ou ambiguë n'est jamais persistée.

Les événements `customer.subscription.created`, `customer.subscription.updated` et les renouvellements `invoice.paid` synchronisent ces champs de façon idempotente. `app_ecommerce_stripe_subscription_period_sync_from_id()` permet au runtime de récupérer une Subscription puis délègue au même résolveur et au même UPDATE atomique des deux bornes. Le backfill BO temporaire a été retiré après initialisation de l'existant. Un éventuel futur outil de réparation devra réutiliser ces helpers canoniques sans devenir une surface BO permanente.

Les affichages Stripe utilisent cette période stockée; si elle manque pendant la transition, ils gardent temporairement le calcul historique et émettent un log observable. Les offres sans identifiant Stripe conservent exclusivement le calcul historique. `date_debut`, `date_fin`, dates de facturation, prix, remise, jauge et fréquence ne changent pas de sémantique.

La période d'une facture est un contrat distinct. Lors de `invoice.paid`, Global sélectionne uniquement les `invoice.lines.data[*].period.start/end` des lignes récurrentes rattachées à la Subscription facturée. Toutes les périodes pertinentes doivent être identiques; une divergence, notamment de prorata `subscription_update`, est refusée comme ambiguë. Un payload de lignes tronqué déclenche un GET ciblé paginé de toutes les Invoice Lines. La période résolue est transmise à la création de commande puis figée dans `ecommerce_commandes_lignes.nom`; elle n'est jamais relue depuis `stripe_current_period_start/end`. En l'absence de période Invoice fiable, le calcul Cotton legacy reste le fallback non cassant, avec logs `[Stripe Invoice Period]` explicites.

## Update 2026-09-02 - Assiette contractuelle Stripe des offres déléguées hors cadre

Le renouvellement réseau applique désormais `assiette contractuelle stable + remise réseau courante = Price net`. L'assiette est le snapshot contractuel `cotton_contract_*` courant de la subscription; elle n'est jamais recalculée depuis le catalogue, l'offre ou la jauge Cotton courants. Toute metadata absente/incomplète, subscription dupliquée, couverture incomplète ou classification autre que `offre_deleguee_hors_cadre` échoue fermée sans write Stripe.

La primitive Stripe compare montant TTC et intervalle, fait un no-op idempotent quand ils sont déjà corrects et réévalue le guard métier immédiatement avant `SubscriptionItem::update(..., proration_behavior=none)`. `invoice.created` et `invoice.paid` utilisent la même résolution en lecture seule. Pour une commande hors-cadre payée, le snapshot comptable final reprend `amount_paid` et les taxes Stripe; les autres familles de commandes restent inchangées.

Le Product support d'un write est désormais séparé du montant: un mapping figé du snapshot `offer_id/gauge_id/frequency_id` produit `ABN{jauge}M|A`, puis un Price Stripe actif et unique fournit son Product après contrôle explicite de `active`, de la devise, de la récurrence et de l'association Price/Product. Le `unit_amount` de ce Price catalogue n'est jamais lu pour calculer la cible. Les valeurs offre/jauge/fréquence de l'offre Cotton courante n'interviennent pas; tout support absent, ambigu ou incompatible échoue fermé.

### Évolution future du snapshot contractuel

Les metadata `cotton_contract_*` représentent le dernier état contractuel explicitement validé de la subscription Stripe. Elles sont stables et autoritaires entre deux intentions commerciales explicites. Un renewal les lit sans jamais les modifier. Une future intention commerciale initiée ou validée via Stripe pourra remplacer atomiquement le snapshot courant par une nouvelle version; les renewals suivants consommeront alors cette version. L'état Cotton courant ne constitue jamais à lui seul une intention commerciale et ne peut ni recalculer ni remplacer le snapshot.

La référence actuelle `offer_client:<id>:checkout_v1` provenance le snapshot initial créé au checkout; le reader n'impose ni ce suffixe ni cette origine. Une future convention telle que `offer_client:<id>:stripe_change_v2` pourra identifier un snapshot révisé sans casser les subscriptions existantes. La mutation commerciale, son atomicité et son portail restent hors du périmètre actuel.

## Update 2026-09-01 - Création de préparation Hub sans offre

`app_programming_quick_hub_create_from_game(...)`, et donc l'entrée Dashboard `app_programming_quick_hub_create_from_dashboard_preparation(...)`, ne requiert plus d'offre effective pour créer une session officielle. Il exige toujours un Hub, son propriétaire et son contact; `id_offre_client=0` est persisté en l'absence d'offre. Cette levée est limitée à la préparation: les décisions de lancement officiel et de runtime conservent leur contrôle commercial.

## Update 2026-08-31 - Démo de contrôle Hub

`app_games_hub_demo_representative_create(...)` est la primitive unique de la démo annexe de contrôle, réservée à `official_access`. Elle est appelée directement depuis Master ou par la commande Remote Master-claimée `launch_hub_demo`; cette dernière conserve présence, expiration et idempotence de la file Remote. Le resolver `app_games_hub_remote_client_routing_state_get(...)` reconnaît l’exécution démo ouverte par session source quand aucun focus officiel n’est actif, puis produit l’URL Remote du même runtime/exécution sans écrire `active_session_id` ou `presentation_session_id`. `Tester le jeu` demeure le flux distinct de démo de session des cartes Programme.

La primitive lit la première session officielle du Hub dans l’ordre canonique du Programme. Elle passe ensuite par le même producteur historique que `session_duplicate`, `app_session_demo_create_from_source(...)`, qui fournit une copie isolée avec token neuf, flags démo et branding source. Seule sa thématique est ensuite remplacée, sur la copie, par `app_programming_quick_hub_suggestion_build(...)` et `app_programming_quick_hub_apply_theme_to_session(...)` avec `force_numeric`.

La copie est remise à zéro par `app_games_hub_demo_runtime_reset(...)` avant la création du contexte d’exécution `runtime_mode=demo` et l’URL `hub_launch=1`; c’est cette couche de lancement qui rend le Master immédiatement jouable, jamais la duplication. La voie ne crée ni membership, ni focus, ni présentation, Remote, résultat ou classement du Hub; son unique contexte d’exécution est explicitement démo et lie source/runtimes distincts. Son événement `hub_execution_started` est aussi explicitement exclu de l’historique des départs officiels : une démo ne peut donc jamais masquer le CTA `Lancer une démo`. Pour l’hydratation Canvas de cette démo sans membership, `app_branding_ajax.php` valide `hub_source_session` et `hub_execution` avec `app_games_hub_runtime_context_resolve(...)`, dont la source est relue par le SELECT minimal `app_games_hub_runtime_context_source_session_get(...)` sans boot de module de jeu, puis force `app_games_hub_branding_get($hub, 0)`: branding Hub, réseau/client et défaut Cotton, jamais le branding copié de la session démo.

Ce SELECT minimal transporte aussi `id_type_produit`, nécessaire à `app_games_hub_execution_context_complete(...)` pour écrire la preuve terminale avec le bon slug de jeu. La résolution exige toujours une exécution ouverte correspondant au runtime: une démo Dashboard Pro mobile, même si sa source appartient à un Hub, n'acquiert ni contexte d'exécution ni droit de retour Hub par son seul branding, son statut démo ou son `id_hub`.

## Update 2026-08-31 - Launch Hub papier: bootstrap avant engagement du focus

Pour un lancement Hub papier qui va injecter le roster actif, `app_games_hub_session_launch_from_master(...)` appelle une fois `app_games_hub_paper_historical_session_ensure(...)` après les gardes temporels/métier et avant toute écriture de focus ou création de contexte d'exécution. Un échec Quiz/Blind Test arrête donc explicitement le launch avant qu'il soit partiellement engagé. Le type archive `2` est sauté afin de conserver son support historique inchangé.

Après succès, le chemin existant reste intact: `app_games_hub_session_inject_active_players(...)` sélectionne tous les `games_hubs_players.status='active'`, appelle `player_register` pour chaque joueur, puis active le mapping `games_hubs_players_sessions`. Un échec individuel continue d'incrémenter `failed_count` sans modifier le statut global historique du launch.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_paper_cold_runtime_bootstrap_contract_test.php`.

## Update 2026-08-27 - Quick-add Hub: politiques temporelles explicites

Le service partagé distingue désormais deux politiques serveur. La politique par défaut `live`, conservée par Hub Master et Hub Remote, autorise uniquement l'état canonique `open`. La politique `dashboard_preparation`, forcée par un point d'entrée dédié au Dashboard Pro, autorise `before` et `open`. `expired`, `invalid` et toute politique inconnue échouent fermées.

La politique est incluse dans la proposition signée et vérifiée à la création, afin qu'une proposition Dashboard ne puisse pas être rejouée par le chemin live. Les contrôles compte, Hub actif, date, jeu, idempotence, création, membership, absence de focus runtime et cut-off J+1 midi restent inchangés.

Fichiers de référence:
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`;
- `global/web/tests/programming_quick_hub_service_contract_test.php`.

## Update 2026-08-26 - Hub players: transitions roster pour undo sas papier

`app_games_hub_player_upsert(...)` et `app_games_hub_player_ensure(...)` exposent maintenant une transition roster explicite: `created` quand la ligne Hub est créée, `reactivated` quand une ligne `games_hubs_players.status='left'` redevient `active`, et `already_active` quand l'identité était déjà dans le roster Hub actif. La réactivation utilise une mise à jour conditionnelle sur l'ancien statut afin que deux ajouts concurrents du même joueur ne puissent pas tous deux conclure à une vraie réinscription.

La sémantique des deux `left` reste séparée. `games_hubs_players.status='left'` signifie que le joueur est sorti du roster Hub actif; il n'est plus sélectionné par `app_games_hub_players_list_active(...)` ni par `app_games_hub_session_inject_active_players(...)`. `games_hubs_players_sessions.status='left'` reste une sortie bornée à une session déjà mappée; le joueur Hub peut rester `active` et rester éligible aux parties suivantes.

Le sas papier Remote consomme cette transition uniquement pour accorder un undo éphémère en cas de `created` ou `reactivated`. Aucun changement n'est apporté à l'injection papier, aux sessions numériques, au schéma ou aux mappings anticipés.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `global/web/tests/hub_player_roster_registration_state_test.php`;
- `games/web/modules/app_hub_remote_ajax.php`.

## Update 2026-08-26 - Hub players: membership papier `active|left`

Le contrat `games_hubs_players.status` est confirmé comme statut de membership Hub joueur: la colonne est `active|left`. L'inscription/réactivation passe par `app_games_hub_player_upsert(...)` et écrit `active`; la sortie volontaire historique `app_games_hub_player_leave(...)` écrit `left`.

L'injection papier `app_games_hub_session_inject_active_players(...)` sélectionne les joueurs par `id_hub` et `status='active'`, sans filtre de fraîcheur `last_seen_at`. Un joueur Hub inscrit dont le smartphone est fermé ou inactif reste donc inclus au lancement papier. La désinscription explicite depuis le sas Remote utilise le nouveau helper `app_games_hub_player_unregister(...)`, qui écrit `left` sans toucher aux mappings runtime ni aux signaux de présence.

Les présences restent séparées: Hub Remote lit `games_hubs.hub_remote_instance_seen_at`, le Master/runtime lit les tables `games_hubs_remote_*_presence`, et `players_live`/liste active reste une projection de membership actif, pas une mesure de téléphone connecté.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`.

## Update 2026-08-26 - Hub Remote: gate présence canonique pour Pro

Global/Hubs expose maintenant `app_games_hub_remote_presence_gate_get(...)`, helper commun qui lit la Remote canonique courante depuis `games_hubs.hub_remote_instance_id` et `hub_remote_instance_seen_at`, puis applique un TTL court borné. Ce helper permet aux surfaces hors Games, notamment le Dashboard Pro, de distinguer une Remote réellement fraîche d'un simple token ou d'un accès historique existant.

Le helper ne crée aucune Remote, ne génère aucun token, ne touche pas le runtime et ne modifie pas la propriété d'instance. Il complète les helpers Master/Remote existants: takeover/touch restent les seules écritures d'instance, tandis que le gate retourne seulement `present`, `latest_seen_at`, `age_seconds`, `remote_instance_id` et `ttl_seconds`.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-08-26 - Hub Master hidden: lease canonique bornée

`app_games_hub_remote_master_presence_gate_get(...)` conserve le TTL nominal court de 6 s pour un Hub Master visible, mais lit maintenant la dernière présence canonique de l'instance Master et applique un TTL effectif plus long uniquement si cette ligne annonce `visibility='hidden'`. Cette lease cachée est bornée, reste liée à `hub_master_instance_id`, et n'introduit ni polling supplémentaire ni scan global.

`app_games_hub_remote_control_state_get(...)` expose une commande active à la Remote seulement si elle a été créée depuis la dernière présence fraîche du Master courant. La même borne est passée à `app_games_hub_remote_launch_active_command_get(...)`, afin qu'une ancienne commande `launch_session` non claimable ne soit ni réannoncée par `control_poll`, ni réutilisée après reconnexion.

`app_games_hub_remote_master_presence_release(...)` supprime la présence seulement pour l'instance Master encore canonique. Une fermeture/pagehide tardive d'un ancien Master après takeover est donc ignorée, tandis qu'une vraie sortie de page du Master courant peut libérer la présence sans attendre le fallback TTL.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `global/web/tests/hub_instance_exclusivity_contract_test.php`.

## Update 2026-08-26 - Hub Master frais pour Remote

Global/Hubs porte maintenant la source de vérité d'exclusivité des interfaces Hub dans `games_hubs`: `hub_master_instance_id`, `hub_master_instance_seen_at`, `hub_remote_instance_id`, `hub_remote_instance_seen_at`. Ces champs identifient seulement les pages Hub Master et Hub Remote courantes; ils ne remplacent pas `active_session_id`, `presentation_session_id`, les événements d'exécution ni le routage Remote historique.

`app_games_hub_instance_takeover(...)` est l'unique écriture qui remplace l'instance canonique. Elle ne modifie pas `date_maj`, ne lance rien, ne clear rien et ne change pas la présentation. Les heartbeats passent par `app_games_hub_instance_touch_current(...)`, qui échoue si l'instance n'est plus canonique; ils ne peuvent donc pas reprendre automatiquement la propriété après remplacement.

La présence interactive Remote est maintenant portée par `app_games_hub_remote_master_presence_gate_get(...)`: Master canonique courant, ligne `games_hubs_remote_master_presence` de cette instance, TTL frais de 6 secondes. `app_games_hub_remote_control_state_get(...)` utilise ce gate pour `master_present`; le TTL historique 30 s n'est plus la source d'interactivité Remote.

Les commandes Remote exigent l'instance Remote canonique et le gate Master frais à la création. Le claim Master exige l'instance Master canonique et vérifie la présence fraîche avant toute consommation; si cette présence a été perdue, les commandes pending du Hub courant sont annulées de façon bornée. Le poll Master claim avant de toucher sa présence, afin qu'un retour après absence ne puisse pas exécuter une commande créée dans un contexte stale.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_instance_exclusivity_contract_test.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/modules/app_hub_remote_ajax.php`.

## Update 2026-08-25 - Suppression session Hub et convergence Remote

La suppression individuelle d'une session via le service canonique `app_session_delete_canonical(...)` désactive maintenant d'abord les memberships Hub actifs de cette session (`games_hubs_sessions.status='inactive'`, `updated_at=NOW()`) avant la suppression physique historique de `championnats_sessions`.

Ce signal rend la mutation observable par `app_games_hub_remote_business_revisions_get(...)`: le `membership_revision` et l'empreinte de préparation changent, `control_poll` peut exposer une nouvelle `preparation_revision`, puis Hub Remote déclenche son `business_snapshot`. Cela couvre le cas d'un Hub dont toutes les sessions courantes sont terminées mais dont la fenêtre d'ajout rapide reste ouverte: la synchronisation continue et la suppression Dashboard converge côté Remote.

Fichiers de référence:
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_delete_service_contract_test.php`;
- `global/web/tests/hub_remote_control_contract_test.php`.

## Update 2026-08-25 - Theme renewal date_maj et preparation_revision

Le contrat canonique de renouvellement de thematique reste `app_programming_theme_renewal_plan_for_session(...)` puis `app_programming_theme_renewal_apply_for_session(...)`. Il valide session/client, compatibilite Quiz/Blind Test/Bingo, appartenance Hub si `hub_id`/`hub_row`, Hub non termine, edit-state non lock, selection courante attendue, proposition differente et revalidation contre le catalogue, les exclusions temporaires, le Programme actif et l'historique client.

Les mutations appliquees horodatent maintenant aussi `championnats_sessions.date_maj`: Blind Test met a jour `id_produit`; Quiz met a jour `id_produit`, `lot_ids`, `flag_configuration_complete`; Bingo materialise une playlist client puis met a jour `id_produit` et `flag_configuration_complete`. La detection Remote ne depend toutefois pas uniquement de `date_maj`: `app_games_hub_remote_business_revisions_get(...)` conserve une empreinte stable des champs de preparation (`id_produit`, `lot_ids`, format, mode, statut de configuration, ordre Programme, membership), triee par position puis session.

Fichiers de reference:
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/session_theme_renewal_apply_test.php`;
- `global/web/tests/session_theme_renewal_planner_test.php`;
- `global/web/tests/hub_remote_control_contract_test.php`.

## Update 2026-08-25 - Hub Remote: révision préparation Dashboard/settings

`app_games_hub_remote_business_revisions_get(...)` inclut maintenant une empreinte des champs de préparation Programme des sessions actives du Hub: format, mode de participation, produit/contenu, lots, statut de configuration, ordre et source de membership. Les changements Dashboard Pro sur `id_format`, `flag_controle_numerique`, `id_produit` ou `lot_ids` deviennent donc détectables; Pro met aussi à jour `championnats_sessions.date_maj` sur ces mutations, et l'empreinte conserve une couverture défensive si une écriture historique oublie ce timestamp.

La même révision inclut aussi les événements canoniques `game_events.action = hub_session_settings_save` rattachés aux sessions actives du Hub. La Remote peut donc détecter une sauvegarde de réglages métier et redemander `business_snapshot` sans nouveau canal ni polling parallèle.

Le contrat reste borné: `control_poll` lit seulement des agrégats de révision et ne charge pas le contexte de rendu complet. Le snapshot lourd reste côté Games et réutilise `app_games_hub_render_context_get(...)`.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `games/web/modules/app_hub_remote_ajax.php`.

## Update 2026-08-25 - Hub présentation: politique next-ready

Global/Hubs porte maintenant la politique persistante `next_ready` utilisée après un clear de focus runtime. `app_games_hub_next_ready_session_resolve(...)` cherche la première session du Hub qui n'est ni terminée, ni `running`, ni focus actif, en respectant l'ordre Programme persistant (`position`, fallback index, puis `id`).

`app_games_hub_presentation_apply_next_ready(...)` applique cette décision en appelant uniquement `app_games_hub_presentation_session_set(...)`. Le runtime reste séparé: aucune écriture `active_session_id`, aucun `hub_execution_started`, aucun routage Remote historique n'est produit par cette politique. `app_games_hub_focus_clear(...)` déclenche cette promotion seulement quand le clear atomique réussit, avec option `presentation_next_ready=false` pour les événements qui doivent préserver la présentation courante, notamment la fin naturelle.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_presentation_mode_contract_test.php`;
- `games/web/includes/canvas/php/boot_lib.php`;
- `games/web/modules/app_orga_ajax.php`.

## Update 2026-08-25 - Hub focus runtime vs présentation séparés

Global/Hubs ajoute `games_hubs.presentation_session_id` comme sélection de présentation persistée, nullable et distincte de `games_hubs.active_session_id`. Le focus actif reste le contrat runtime: lancement/reprise, contexte d'exécution ouvert, auto-join Hub Play, routing Remote historique et clear atomique.

Le helper `app_games_hub_presentation_session_set(...)` valide le Hub et l'appartenance de la session, puis écrit seulement `presentation_session_id`, `presentation_mode=session`, `presentation_updated_at` et `date_maj`. Il ne modifie ni `active_session_id`, ni `active_session_activated_at`, ni les événements `hub_execution_started`. À l'inverse, `app_games_hub_focus_set_active(...)` continue d'écrire le focus runtime et aligne aussi `presentation_session_id` sur la session lancée/reprise.

`app_games_hub_presentation_resolve(...)` résout maintenant dans cet ordre: podium Hub choisi, `presentation_session_id` valide, fallback runtime `active_session_id`, puis fallback programme non destructif. Les consommateurs runtime ne lisent pas cette présentation pour autoriser un join: `app_games_hub_get_active_launched_session_for_player(...)` et `app_games_hub_remote_client_routing_state_get(...)` restent basés sur `active_session_id`.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_presentation_mode_contract_test.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `games/web/includes/canvas/sql/2026-08-25_games_hubs_presentation_session.sql`.

## Update 2026-08-25 - Hub Remote: commande `select_session`

Global/Hubs autorise maintenant la commande Remote légère `select_session` dans `games_hubs_remote_commands`. La création valide seulement le Hub, l'accès Remote et l'appartenance de la session; elle transporte `session_id`, `session_token`, `source=hub_remote` et `contract=hub_remote_select_session:v1`.

Cette commande est un contrat de présentation pour Hub Master. Elle ne lance pas la session et ne construit aucune URL runtime. Sa consommation côté Games Master écrit maintenant `games_hubs.presentation_session_id` via `app_games_hub_presentation_session_set(...)`, sans modifier `games_hubs.active_session_id`. Le runtime reste distinct: seule l'action `launch_session` ouvre ou reprend l'exécution et déclenche ensuite le routage `client_routing`.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/modules/app_hub_remote_ajax.php`.

## Update 2026-08-24 - Hub Remote: révisions métier bornées

`app_games_hub_remote_control_state_get(...)` reste le contrat léger de contrôle Remote: présence Master, commandes, routing et indicateurs. Il expose désormais des révisions métier calculées par `app_games_hub_remote_business_revisions_get(...)` via des agrégats horodatés bornés, sans charger `app_games_hub_render_context_get(...)`, les listes de sessions, joueurs ou classements.

Couverture retenue: `preparation_revision` suit Hub, memberships, sessions canoniques et lots; `runtime_revision` suit focus et événements d'exécution; `results_revision` suit joueurs, mappings joueur/session et projection `stats_*`. Le coût `control_poll` passe de 4 requêtes SQL à 4 + agrégats de révision bornés; le snapshot métier lourd reste côté Games dans `business_snapshot`.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-24 - Hub Remote: readiness sur exécution réutilisée

Une exécution Hub réutilisée n'est plus considérée joignable par défaut. Global lit désormais le marqueur existant `hub_remote_runtime_ready` pour le même Hub, la même session et le même `execution_id`: si ce marqueur existe déjà, la Remote peut rejoindre l'exécution réutilisée; sinon `readiness_required=true` reste exposé et Hub Remote attend le callback Organizer.

Ce contrat corrige la séquence réelle où une reprise Blind Test naviguait vers `/remote/blindtest/...` avant `hub_remote_game_readiness_confirmed`, revenait au Hub Remote, puis repartait après readiness. Le même gating s'applique au résultat immédiat de `launch_session` et à `client_routing` pour les reloads ou ouvertures tardives.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-24 - Hub Remote: revert borne vers baseline launch

Le patch non commit qui ajoutait une presence primary courante au calcul `client_routing` a ete retire. Global revient au contrat `f5b23dbc02001c6fd21a18232aae891767fef72e`: `client_joinable` depend de la readiness uniquement pour les transitions qui creent/recreent un runtime; une reprise d'execution ouverte peut etre joignable sans `primary_presence.present=true`.

Le schéma additionnel `games_hubs_remote_master_presence.current_session_id`, `current_execution_id` et `runtime_ready_at`, le helper `app_games_hub_remote_current_primary_presence_get(...)`, les raisons `launch_waiting_primary` / `resume_waiting_primary` et l'instrumentation `PRIMARY_PRESENCE_*` / `CLIENT_JOINABLE_DECISION` / `HUB_REMOTE_CONTROL_STATE` ne font plus partie de l'etat deployable.

Motif du revert: les logs frais `11:58` puis `12:13-12:14` montraient une presence Hub touchee mais hors cle runtime (`current_session_id=0`, `current_execution_id=''`, `runtime_ready_at=NULL`). La contrainte ajoutée pouvait donc bloquer le routage de lancement neuf et de reprise, alors que la baseline connue validait deja le lancement neuf par `hub_remote_game_readiness_confirmed`.

Etat attendu apres revert: lancement neuf stable BT/Quiz/Bingo; reprise suspendue revenue au comportement imparfait mais connu, avec double aller-retour possible avant traitement separe.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/includes/canvas/core/boot_organizer.js`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `games/web/tests/hub_remote_contract_test.php`.

## Update 2026-07-31 - Hub Remote: resolver d'exécution ouverte en reprise

`app_games_hub_execution_context_get_open(...)` valide maintenant une exécution ouverte par appartenance Hub/session et par focus actif `games_hubs.active_session_id`, sans exiger que `game_events.created_at` soit postérieur au dernier `active_session_activated_at`. Une reprise Hub peut en effet refocaliser une session dont le runtime et l'`execution_id` existaient déjà avant le nouveau focus.

Le filtre temporel `started_at < active_session_activated_at` n'est donc plus une preuve d'exécution historique. Une exécution complétée reste exclue par `hub_execution_completed`, et une session différente du focus actif reste refusée quand le respect du focus est demandé. Ce contrat permet aux Canvas Master/Player et au routage Remote de conserver le contexte Hub sur reprise sans créer un nouveau bootstrap ni réutiliser une ancienne readiness d'une autre exécution.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `games/web/organizer_canvas.php`;
- `games/web/player_canvas.php`.

## Update 2026-07-31 - Hub Remote: URL de retour de la Remote historique

`app_games_hub_session_remote_url(...)` peut maintenant recevoir le Hub et l'`execution_id` en plus de la session. Quand la Remote historique est ouverte depuis Hub Remote et qu'un accès Remote actif existe, Global ajoute à l'URL `/remote/{game}/{session}` un contexte borné: `hub_remote=1`, `hub_remote_token`, `hub_remote_return=/hub/{remote_token}/remote` et `hub_remote_execution`.

Le token transporté est le token Remote dédié, validé par hash côté Global/Games; le token public Hub Master/Play n'est pas utilisé. Sans Hub ou sans accès Remote actif, l'URL historique reste inchangée afin de préserver les ouvertures hors Hub Remote.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `games/web/remote_canvas.php`;
- `games/web/includes/canvas/core/hub_transition.js`.

## Update 2026-07-31 - Hub Remote: readiness runtime conditionnelle

Global/Hubs distingue maintenant les exécutions Hub Remote qui créent un nouveau runtime de celles qui reprennent une exécution ouverte. Le statut `completed` de `games_hubs_remote_commands` reste limité au traitement serveur par Hub Master; l'exigence de readiness dépend ensuite de `readiness_required`.

La readiness est portée par `game_events.action = hub_remote_runtime_ready`, corrélée durablement au Hub, à la session et à l'`execution_id` renvoyé par le lancement central. `app_games_hub_remote_launch_readiness_mark(...)` valide aussi la commande quand le callback Organizer en fournit une: session Hub, type `launch_session`, payload `session_id` et résultat `completed` portant la même exécution. `app_games_hub_remote_launch_readiness_get_for_execution(...)` lit ensuite cette preuve pour tous les clients Remote d'une même exécution, pas seulement pour la Remote qui a créé la commande.

`app_games_hub_remote_client_routing_state_get(...)` expose le routage client Remote depuis les mêmes marqueurs que Hub Play: présentation/focus Hub, session focalisée, contexte d'exécution ouvert, état de session, URL Remote historique et readiness Organizer. Il ajoute `readiness_required` et `routing_reason`: `launch_waiting_runtime`, `launch_ready`, `resume_ready`, `active_execution_ready` ou `no_active_execution`. `client_joinable` n'est vrai sans readiness que pour une exécution reprise déjà ouverte; une nouvelle exécution reste fail-closed jusqu'au marqueur correspondant.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/includes/canvas/core/boot_organizer.js`.

## Update 2026-07-31 - Hub Remote: commande `launch_session`

Global/Hubs étend la file `games_hubs_remote_commands` au type `launch_session`. La commande reste minimale: `session_id`, origine technique et version de contrat; elle ne transporte ni URL libre, ni type de jeu fourni par le client, ni payload runtime. La validation serveur relit le Hub, vérifie l'appartenance de la session, le statut terminal, la fenêtre de lancement, la présence Master récente et les URLs internes résolues depuis la session canonique.

L'idempotence est bornée par session: une commande `launch_session` active (`pending|claimed|processing`) pour le même Hub et la même session est réutilisée au lieu d'en créer une seconde. L'expiration de `launch_session` est de 60 secondes, contre 20 secondes pour `master_ping`, afin de rester compatible avec le heartbeat Master masqué. Le claim reste atomique `pending -> claimed`; une commande expirée ne peut plus être claimée.

Les URLs sont construites côté serveur: `app_games_hub_session_master_url(...)` pour Organizer et `app_games_hub_session_remote_url(...)` pour la Remote historique. Le service de lancement reste `app_games_hub_session_launch_from_master(...)`, commun à Quiz, Blind Test et Bingo; il valide le Hub, commit le focus, crée/reprend le contexte d'exécution, injecte les joueurs actifs seulement en papier, puis renvoie la navigation Organizer.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`.

## Update 2026-07-31 - Hub Remote: accès, présence Master et commandes

Global/Hubs ajoute le socle Remote Lot 1 avec trois tables dédiées: `games_hubs_remote_access` pour le token Remote révocable, `games_hubs_remote_master_presence` pour la présence des instances Master, et `games_hubs_remote_commands` pour la file persistée des commandes. Les tokens Remote sont suffisamment aléatoires, validés par hash versionné et ne sont pas journalisés.

Le service `app_games_hub_remote_control_state_get(...)` fournit l'état de contrôle léger sans charger joueurs, résultats ni contexte de rendu Hub complet. Il retourne les révisions utiles, la présence Master récente, une commande en attente, et depuis le Lot 2 readiness un routage client borné à la session focalisée/exécution ouverte.

Le seul type de commande autorisé au Lot 1 est `master_ping`. La création est idempotente par clé Remote, l'expiration est courte, le Master claim la plus ancienne commande pending puis la complète sans action destructive. Les futures commandes doivent étendre explicitement l'allowlist et garder le même canal persisté.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`;
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`.

## Update 2026-07-31 - Participations probables Hub et présence runtime

Global/Hubs ajoute une source canonique dédiée aux intentions de présence Hub: `games_hubs_participations_probables`. Elle déduplique par `(id_hub, auth_identity_key)` afin qu'un joueur EP n'ait qu'une intention probable pour toute la soirée/événement, même si plusieurs sessions historiques du même Hub exposent encore le formulaire d'inscription.

Les helpers historiques `app_session_participation_probable_*` conservent la table `championnats_sessions_participations_probables` pour les sessions autonomes. Quand la session est rattachée à un Hub actif et qu'une identité EP est disponible, ils routent `get/add/delete/count/list` vers les helpers Hub `app_games_hub_probable_*`, sans double écriture session + Hub.

Avant J, `app_games_hub_player_prepare_ep_return(...)` renvoie vers la page EP Hub `/extranet/games/hub/{hub_token}` sans créer de ligne `games_hubs_players`; la page EP Hub matérialise ensuite la probable via `app_games_hub_probable_declare_ep(...)` ou la retire via `app_games_hub_probable_cancel_ep(...)`. Pendant la fenêtre de lancement, le retour EP crée/réactive l'identité Hub, confirme l'intention probable existante le cas échéant et redirige vers Hub Play avec `ep_connect_token`. Une fenêtre expirée revient vers la page EP Hub sans création de joueur Hub.

Au lancement Master, l'injection de tous les joueurs Hub actifs est limitée au mode papier (`flag_controle_numerique=0`). En numérique, le focus et le contexte runtime sont créés, mais les participations joueur/session restent créées ou réactivées par présence réelle: polling Hub Play actif, arrivée tardive, reload, QR/Canvas et reprise manuelle. Le statut `left` continue de bloquer l'auto-join de la même partie, avec reprise manuelle possible.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`;
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`;
- `games/web/includes/canvas/sql/2026-07-31_games_hubs_participations_probables.sql`;
- `global/web/tests/hub_probable_participations_contract_test.php`;
- `global/web/tests/hub_ep_return_intent_test.php`;
- `global/web/tests/hub_participation_counters_contract_test.php`.

## Update 2026-07-31 - Photo podium active Hub

Global/Hubs porte désormais le contrat backend de photo podium active par identité Hub. L'identité canonique est `games_hubs_players.id`; une seule photo active peut y être rattachée, et elle est remplacée après un nouvel upload Hub Play autorisé.

L'audit du stockage historique a montré que `app_session_results_podium_photo_upload(...)` écrit dans `medias_images` avec `id_module=id_championnat_session` et un crédit lié au rang ou à la ligne runtime du podium. Ce modèle reste conservé hors Hub, mais ne permet pas l'unicité par identité Hub. La migration manuelle `games/web/includes/canvas/sql/2026-07-31_games_hubs_players_active_podium_photo.sql` ajoute donc `hub_photo_media_id`, `hub_photo_game_key`, `hub_photo_source` et `hub_photo_updated_at` sur `games_hubs_players`.

Le helper d'upload Hub réutilise le traitement historique de l'image: stockage par type de jeu, contrôle de fichier, resize 900x900, qualité 90 et consentement historique. L'éligibilité est désormais prouvée en amont par Games depuis le rang 1 à 3 de l'identité active dans `aggregate_context.aggregate_ranking`, source canonique Global chargée côté serveur; aucun rang navigateur ni podium de session ne fait autorité. Global revalide Hub, identité et mapping de la session choisie comme support de consentement/traçabilité, puis applique les validations de fichier et l'écriture existantes. L'ancienne photo active est supprimée seulement lors d'un remplacement autorisé; une sortie ultérieure du Top 3 ne supprime pas la photo. Aucune copie n'est écrite dans les résultats de session.

La lecture Hub passe par `app_games_hub_player_active_photo_get(...)` et les enrichissements de résultats Hub. Le podium agrégé, les lignes d'aggregate ranking portant des photos, les podiums de sessions terminées du Hub Master et Hub Play après upload résolvent donc la même photo active. Les rangs, scores et libellés restent issus des résultats canoniques de session.

Après un upload réussi, Global met aussi à jour `games_hubs.date_maj`. Cette date est incluse dans la révision légère lue par Games Hub Master; les podiums peuvent donc être relus par refresh partiel sans attendre un rechargement manuel de la page.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`;
- `global/web/tests/hub_players_stats_projection_contract_test.php`.

## Update 2026-07-30 - Fallback participants runtime pour Hubs historiques

Les Hubs historiques peuvent exister après rattachement explicite des sessions sans contenir encore de joueurs Hub. Dans ce cas, les résultats sont pourtant présents dans les tables runtime des sessions. Global ajoute donc un amorçage borné avant le rebuild `stats_*`: si un Hub actif explicite a des sessions terminées fiables mais aucun joueur Hub, `app_games_hub_players_stats_initialize_if_needed(...)` collecte les participants directs des sessions rattachées et crée les joueurs/mappings Hub nécessaires.

La collecte ne déduit jamais un Hub depuis une date. Elle part de `games_hubs_sessions` via `app_games_hub_sessions_get(...)`, filtre les sessions terminées, puis lit `cotton_quiz_players`, `blindtest_players` et `bingo_players` selon le type de partie. Les équipes Blind Test restent exclues comme dans le rebuild runtime existant.

Pour `games_hubs_players.stats_*`, une session Hub doit être explicitement terminée avant d'alimenter le classement agrégé. La règle Hub s'appuie sur `hub_is_terminated`, `hub_runtime_status=completed|terminated` ou l'état runtime canonique `is_terminated`; elle n'utilise pas le fallback historique client `date passée + participants`. Une session en cours avec des scores runtime reste donc exclue du rebuild.

Pour Quiz et Blind Test, une session runtime dont tous les scores sont à zéro n'est pas considérée comme un résultat exploitable: elle ne crée pas de contribution classée et n'est pas matérialisée depuis l'historique. Pour Bingo, une session terminée sans gagnant de phase dans `bingo_phase_winners` n'alimente pas le classement agrégé; les 100 points de participation ne sont appliqués que si la partie a au moins un résultat de phase exploitable. Ces garde-fous évitent qu'une partie non jouée ou incomplète attribue des points de classement.

La matérialisation passe par `app_games_hub_player_upsert(...)` et `app_games_hub_session_mapping_upsert(...)`. Les mappings sont marqués `completed` avec `last_action=historical_materialized`, puis le rebuild canonique projette les résultats dans `games_hubs_players.stats_*`. Les identités restent Hub-locales: `player_id` runtime quand il existe, sinon participation de session; aucune fusion par pseudo. Le lecteur du classement persistant masque les joueurs sans partie comptabilisée (`stats_parties_count=0`).

Les compteurs Hub conservent leurs sources nominales mais disposent d'un fallback d'affichage: si aucun joueur Hub actif n'existe, `app_games_hub_participation_counters_get(...)` peut compter les participants runtime des sessions Hub pour sécuriser l'agenda et le dashboard Pro.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_players_stats_projection_contract_test.php`;
- `global/web/tests/hub_participation_counters_contract_test.php`.

## Update 2026-07-30 - Contexte Global Hub léger pour `aggregate_ranking`

Les surfaces mono-Hub doivent utiliser `app_games_hub_render_context_get(...)` avec un `id_hub` explicite ou une ligne Hub déjà validée. Ce helper Global/Hubs orchestre les sessions Hub, l'agrégat, les joueurs et les éléments de présentation demandés sans passer par le contexte historique client/saison/période.

La source nominale de l'agrégat Hub est `games_hubs_players.stats_*`, lue via `app_games_hub_players_stats_ranking_get(...)` puis adaptée par Global vers le contrat canonique `aggregate_ranking`: rang dense, ordre d'affichage, score, victoires, deuxièmes/troisièmes places, podiums hors victoires, participations, Top 3, identité `hub-local:{id_hub}:{id_hub_player}` et aliases historiques. Une projection vide reste valide quand le Hub n'a aucune session terminée.

Le fallback historique reste temporaire et borné dans Global/Hubs: projection absente, dirty, en erreur, incomplète, schéma absent ou lecture impossible donnent `aggregate_ranking_source=historical_fallback` et `aggregate_ranking_fallback_reason`. Aucun rebuild n'est lancé pendant le rendu. `app_client_joueurs_dashboard_context_compute(...)` retrouve son contrat historique: sans Hub explicite, il calcule les leaderboards client/période/saison comme avant et ne contient plus de raccourci `hub_persistent`.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/app/modules/entites/clients/app_clients_functions.php`;
- `global/web/tests/hub_players_stats_projection_contract_test.php`;
- `global/web/tests/client_joueurs_dashboard_aggregate_ranking_test.php`.

## Update 2026-07-30 - Initialisation auto des stats Hub historiques

`app_games_hub_get_or_create_for_context(...)` déclenche désormais une initialisation opportuniste de `games_hubs_players.stats_*` après résolution/création d'un Hub et réconciliation des memberships. Le rendu Hub reste strictement lecteur: `app_games_hub_render_context_get(...)` ne lance aucun rebuild.

Le candidat d'initialisation est borné: schéma `stats_*` présent, Hub actif explicite, sessions Hub existantes, au moins une session terminée de façon fiable, joueurs Hub actifs, mappings `games_hubs_players_sessions` prouvés, puis projection absente, dirty, en erreur, incomplète ou Hub enrichi par de nouveaux rattachements. Un Hub déjà courant est sauté et un simple rendu nominal ne reconstruit pas les stats.

La projection rebuildable utilise le chemin prouvé du Hub: `games_hubs_sessions` fournit les parties du Hub, `games_hubs_players_sessions` fournit les mappings joueur/partie en statuts `active` ou `completed`, puis les résultats runtime sont résolus par `id_participation` et `participant_key`. Les invités Hub avec `id_ep_player=0` sont donc projetables sans identité EP.

Sources runtime: Quiz lit `cotton_quiz_sessions` / `cotton_quiz_players`, Blind Test lit `blindtest_sessions` / `blindtest_players` pour les solos et signale les équipes non représentables, Bingo lit `bingo_players` / `bingo_phase_winners` en conservant une seule contribution avec la meilleure phase. Une contribution est bornée à `id_hub_player + id_session`; un mapping sans résultat devient une anomalie explicite `mapping_without_result`.

Les logs `hub_historical_stats_init_start`, `hub_historical_stats_init_skip`, `hub_historical_stats_init_end` et `hub_historical_stats_init_error` tracent le déclencheur, les raisons de skip/rebuild, les compteurs bornés et la durée. En cas d'échec, Global conserve le fallback historique en marquant la projection dirty/error selon le contrat existant.

L'outil web temporaire de diagnostic a été retiré. Le CLI générique `global/web/tools/hub_players_stats_rebuild.php` reste disponible pour une recette opérateur contrôlée.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tools/hub_players_stats_rebuild.php`;
- `global/web/tests/hub_players_stats_projection_contract_test.php`.

## Update 2026-07-30 - CLI rebuild stats Hub: environnement explicite

Le CLI `global/web/tools/hub_players_stats_rebuild.php` exige maintenant `--env=dev` avant de charger la configuration et la connexion DB. En CLI, `$_SERVER['SERVER_NAME']` est absent; sans garde, `global_config.php` retombait sur `prod`, puis `lib_db.php` ouvrait immédiatement la connexion production.

Le script réutilise la convention Global existante: `global.dev.cotton-quiz.com` résout `$conf['server']='dev'`. Il refuse tout environnement absent, invalide, `prod` ou `production` avant `lib_db.php`, puis annonce sans secret `Env`, `DB` et `Mode`.

Commande dry-run dev:

```bash
php web/tools/hub_players_stats_rebuild.php --env=dev --hub-id=186 --dry-run --compare-legacy
```

Fichiers de référence:
- `global/web/tools/hub_players_stats_rebuild.php`;
- `global/web/tests/hub_players_stats_rebuild_cli_env_test.php`;
- `global/web/tests/hub_players_stats_projection_contract_test.php`.

## Update 2026-07-30 - Hubs: libération d'un contexte inactif vide

`app_games_hub_get_or_create_for_context(...)` ne réactive pas un Hub exact inactif lorsqu'un insert échoue sur la clé unique `(id_client, hub_date, context_type, id_operation_evenement)`. Si cette ligne inactive ne porte plus aucun membership actif, joueur actif, lot ou publication, Global supprime la racine résiduelle et retente l'insert afin de créer un nouveau Hub.

Ce comportement évite qu'un Hub supprimé ou soft-désactivé mais encore présent en DB soit traité comme autorité métier pour une nouvelle création quick-schedule. Si la ligne inactive porte encore des données bloquantes, elle n'est pas supprimée automatiquement et le statut `inactive_context_conflict` permet de diagnostiquer le blocage sans masquer l'échec.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_identity_stability_contract_test.php`.

## Update 2026-07-29 - Classement agrégé compact Hub Play

Global expose une projection compacte du classement agrégé pour les surfaces joueur qui ne doivent pas charger le podium visuel complet. Les helpers `app_client_joueurs_dashboard_compact_aggregate_from_rows(...)` et `app_client_joueurs_dashboard_compact_aggregate_from_context(...)` projettent les lignes `aggregate_ranking` en Top rangs, joueur courant, voisins immédiats, score libellé et nombre de parties.

Les entrées publiques `app_client_joueurs_dashboard_get_compact_aggregate_for_period(...)` et `app_client_joueurs_dashboard_get_compact_aggregate_for_event(...)` réutilisent le contexte de dashboard existant, mais transmettent `skip_visual_podiums=true` au calcul pour éviter les podiums/photos visuels inutiles sur le chemin compact.

Cette projection ne modifie pas le calcul canonique: `aggregate_ranking`, rangs denses, scores, compteurs, identités stables, dédoublonnage, podiums complets et rendus Pro/WWW/Play existants restent inchangés. Elle sert uniquement à fournir un payload léger prêt pour un affichage joueur mobile-first.

Fichiers de référence:
- `global/web/app/modules/entites/clients/app_clients_functions.php`;
- `games/web/tests/hub_compact_aggregate_test.php`.

## Update 2026-07-28 - Classement saisonnier agrégé canonique

Les classements agrégés multi-parties et multi-jeux utilisent le moteur commun Global. Le périmètre saisonnier est résolu par `app_client_joueurs_dashboard_context_compute(..., scope=filter)` puis projeté par `app_client_joueurs_dashboard_aggregate_ranking_from_leaderboards(...)`.

`app_client_joueurs_season_aggregate_ranking(...)` expose le contrat saisonnier explicite. Chaque ligne conserve le score technique de tri (`aggregate_score` / `score`) et expose les compteurs canoniques `wins_count`, `podiums_count`, `participations_count`, ainsi que les aliases historiques `wins`, `podiums`, `participations`.

`podiums_count` et `podiums` désignent les podiums hors victoires: une victoire ne nourrit jamais le compteur de podiums visible ou canonique. Le diagnostic `top3_count` reste disponible pour auditer l'ancien sens Top 3 (`wins + second_places + third_places`) sans piloter le rendu. Pour Bingo, plusieurs phases gagnées dans une même partie ne produisent qu'une seule contribution agrégée par joueur et par partie: une seule participation, le meilleur bonus de phase, et un seul compteur de rang avec priorité victoire puis podium non gagnant. Le podium détaillé de session Bingo conserve ses phases.

La clé d'identité saisonnière est résolue par `app_client_joueurs_season_identity_key_resolve(...)`. Priorité: joueur Play authentifié (`ep:*` / `id_ep_player`), joueur Global (`player:*` / `id_joueur`), puis identité Hub locale isolée par Hub (`hub-local:{hub_id}:{hub_player_id}`). Les pseudos, noms affichés, casse, avatars, IP, device ou similarités ne fusionnent jamais deux lignes. Un même joueur authentifié peut donc fusionner entre plusieurs Hubs d'un même client/saison, tandis que deux invités Hub non liés restent distincts. Les équipes Blind Test restent des participants équipe distincts et leur score n'est pas redistribué aux membres.

Chaque ligne agrégée expose `identity_key`, `identity_source`, `identity_id`, `display_name`, `wins_count`, `podiums_count`, `participations_count`, `aggregate_score`, `last_result_at`, `top3_count` et `rank`. Quand les sources fournissent `session_ids`, l'agrégateur dédoublonne une contribution dupliquée pour la même identité canonique et la même partie.

Les interfaces agrégées Pro, WWW Place, Play et Games affichent `victoires · podiums · parties` à la place du score. Les champs techniques `participations_count`, `participations` et `count` conservent leur nom et leur sens interne. Les classements et podiums d'une partie continuent d'afficher les scores propres au jeu.

Fichiers de référence:
- `global/web/app/modules/entites/clients/app_clients_functions.php`;
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`;
- `global/web/tests/client_joueurs_dashboard_aggregate_ranking_test.php`.

## Update 2026-07-28 - Renouvellement automatique des thematiques

Le renouvellement automatique des thematiques utilise maintenant le meme planificateur canonique que l'ajout rapide Hub: `app_programming_quick_theme_plan_build(...)`.

Les exclusions strictes restent: selection courante de la session cible, selections deja actives dans le Programme Hub, exclusions temporaires transmises par l'UI, contenus incompatibles ou absents du catalogue. L'historique client devient une preference relachable par paliers `365`, `180`, `30`, puis `0` jours: il ne peut plus epuiser definitivement le catalogue si une autre thematique compatible existe.

Le renouvellement conserve le jeu, le format, le mode, le gabarit Quiz, la position Programme, les guards de membership Hub et les guards d'edition/lancement existants. `app_programming_theme_renewal_apply_for_session(...)` refuse toujours une proposition recente lorsqu'une alternative non recente compatible existe, mais accepte le fallback relache lorsque l'historique ancien, les doublons du Programme actif ou les exclusions temporaires du clic courant couvrent toutes les alternatives. Le contexte Hub est resolu depuis `hub_row` ou `hub_id`, afin que Pro et Games appliquent les memes exclusions pendant la validation finale.

Fichiers de reference:
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`;
- `global/web/tests/session_theme_renewal_planner_test.php`;
- `global/web/tests/session_theme_renewal_apply_test.php`.

## Update 2026-07-28 - Service quick-add Hub: cutoff de reactivation

Le service partage d'ajout rapide Hub controle maintenant explicitement la fenetre temporelle canonique avant creation. `app_programming_quick_hub_context_validate(...)` appelle `app_games_hub_temporal_state(...)` et refuse une nouvelle session rapide lorsque `launch_window_open=false`.

Le refus utilise le code `HUB_QUICK_ADD_WINDOW_EXPIRED`, ajoute l'etat temporel au payload de retour et journalise `hub_quick_add_refused_after_cutoff` sans token sensible. Avant `J+1 12:00:00` Europe/Paris, un Hub peut donc etre `Termine` fonctionnellement mais encore reactivable par ajout d'une partie.

Ce correctif ne modifie pas la DB, les scores, resultats, podiums, rangs, joueurs, lots, rattachements Hub ni les reprises/lancements deja engages.

Fichiers de reference:
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-07-28 - Hub/session: fenetre J+1 midi serveur

La temporalite des sessions et Hubs utilise maintenant une primitive serveur explicite: `app_temporal_window_state($business_date, DateTimeImmutable $now, DateTimeZone $timezone)`. Elle ne choisit pas arbitrairement le fuseau; le fuseau est fourni par l'appelant. Faute de fuseau metier Hub/client canonique persistant dans le schema audite, le fallback plateforme est centralise dans `app_platform_business_timezone()` et vaut `Europe/Paris`.

Contrat: une date metier `J` est ouverte de `J 00:00:00` inclus jusqu'a `J+1 12:00:00` exclu dans le fuseau fourni. A `J+1 12:00:00`, l'etat devient `expired`. La primitive renvoie `state`, `launch_window_open`, `cutoff_at_iso` et `timezone`; elle accepte un `now` injectable pour les tests et reste stable quel que soit le fuseau runtime PHP.

`app_session_get_chronology(...)` delegue a cette primitive et conserve la sortie historique `before|during|after`. `app_games_hub_temporal_state(...)` lit la date canonique du Hub (`games_hubs.hub_date`) et alimente les lignes normalisees Hub avec `temporal_state`, `launch_window_open`, `timezone` et `cutoff_at`.

Le lancement Hub Master refuse une nouvelle session apres la coupure via `HUB_LAUNCH_WINDOW_EXPIRED`, mais permet la reprise d'une session deja engagee lorsque les marqueurs persistants le prouvent (`hub_last_launch_at`, `hub_last_launch_event_id`, runtime/focus). Un mismatch entre `hub_date` et `championnats_sessions.date` est seulement diagnostique, sans token ni mutation implicite.

Invariants: aucune migration DB, aucun snapshot timezone ajoute, aucun changement sur scores, rangs, egalites, participations, resultats historiques, memberships ou tri.

Fichiers de reference:
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/temporal_window_state_test.php`.

## Update 2026-07-28 - Hub: compteur podium affiche sans victoires

Le payload canonique `aggregate_ranking` conserve le champ technique `podiums` avec son sens historique: total Top 3, victoire comprise, soit `wins + second_places + third_places`.

Chaque ligne expose maintenant aussi `display_podium_count`, entier derive de `second_places + third_places`. Ce champ sert uniquement a la presentation des compteurs agreges Hub: une victoire n'est donc plus affichee comme un podium supplementaire, sans modifier le score, les rangs denses, le tri, les participations ni les compteurs techniques.

Le score agrege reste inchange: participation simple `100`, rang 1 `500` au total, rang 2 `300` au total, rang 3 `200` au total.

Fichiers de reference:
- `global/web/app/modules/entites/clients/app_clients_functions.php`;
- `global/web/tests/client_joueurs_dashboard_aggregate_ranking_test.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-28 - Hub: logs ordinaires debug-only et fallbacks robustes

Les helpers photo client retournent maintenant leurs fallbacks existants quand la requête média échoue ou qu'aucune ligne `medias_images` n'est trouvée. Aucun identifiant factice ni tableau partiel n'est créé.

`app_saison_get_id(...)` conserve un contrat entier: en absence de saison ou en échec SQL, le fallback est `0`. Le message administrateur désactivé de création de session référence l'id réellement créé (`$id_championnat_session`) afin de ne plus déclencher de notice pendant le quick schedule.

Les traces Hub informatives ordinaires ne sont plus écrites dans `error_log` en production à chaque poll: chargement nominal d'agrégat, résolution de membership réussie et résolution branding réussie passent en debug-only. Les erreurs DB, absences/ambiguïtés de membership, mismatches et incohérences restent journalisées normalement.

Le signal `hub_aggregate_ranking_unavailable` n'est pas un log de polling ordinaire: il reste visible lorsque Games a déjà établi que l'agrégat est attendu, mais qu'aucun leaderboard ou agrégat exploitable n'est disponible. Avant première session terminée, Games n'émet plus ce signal; le logger Global conserve donc seulement l'anomalie réelle.

Fichiers de référence:
- `global/web/app/modules/entites/clients/app_clients_functions.php`;
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/client_photo_src_test.php`;
- `global/web/tests/programming_quick_hub_service_contract_test.php`;
- `global/web/tests/hub_identity_stability_contract_test.php`.

## Update 2026-07-27 - Classement agrégé Hub canonique

`app_client_joueurs_dashboard_context_compute(...)` expose maintenant un classement multi-jeux canonique dans `aggregate_ranking`. Ce contrat est construit par `app_client_joueurs_dashboard_aggregate_ranking_from_leaderboards(...)` depuis les leaderboards normalisés du dashboard joueurs; les consommateurs Hub n'ont plus à recalculer l'agrégat.

La fusion utilise les identités stables déjà exposées par les leaderboards. Les identités Hub `hub_player:{id}` et `player:{id}` sont ramenées à la même clé canonique `player:{id}`; les contributions sans identité prouvée restent séparées et ne sont pas fusionnées par nom. Blind Test garde son contrat: les équipes restent des participants équipe distincts et ne sont pas redistribuées aux membres.

Le score agrégé additionne les scores normalisés par jeu. Le tri canonique suit le dashboard joueurs: `score DESC`, `count DESC`, `latest_date DESC`, puis `label ASC` uniquement pour stabiliser l'ordre. Les rangs exposés sont denses; la clé d'égalité est la performance agrégée `score|count`. `latest_date` ordonne seulement les joueurs d'un même groupe ex aequo, et `label` assure l'ordre stable final. Une séquence avec trois premiers ex aequo, deux deuxièmes ex aequo puis un troisième est donc exposée `1, 1, 1, 2, 2, 3`.

Chaque ligne expose notamment `rank`, `aggregate_rank`, `aggregate_tie_key`, `aggregate_tie_count`, `aggregate_order`, `identity`, `participant_type`, `label`, `score`, `count`, `latest_date`, `wins`, `second_places`, `third_places`, `podiums`, `participations`, `games_count` et les champs photo disponibles. Cette forme est la source attendue pour le Hub Master Games, puis pourra être reprise par les pages Pro/publiques sans dupliquer le calcul.

Les podiums de session restent hors scope et conservent leur contrat dans `global/web/app/modules/jeux/sessions/app_sessions_functions.php`.

Fichiers de référence:
- `global/web/app/modules/entites/clients/app_clients_functions.php`;
- `global/web/tests/client_joueurs_dashboard_aggregate_ranking_test.php`;
- `games/web/modules/app_hub_view_helpers.php`.

## Update 2026-07-27 - Hubs: identité stable et rattachement canonique

`games_hubs` porte l'identité persistante d'une soirée ou d'un événement Hub: `id`, `id_securite`, client, date, label, publication, lots, branding, joueurs, historique et état de présentation. Un changement d'usage dynamisation/gamification ne remplace pas ce Hub canonique et ne doit pas changer son token ni perdre ses sessions, joueurs, lots, publication, branding ou podium.

`games_hubs_sessions` est l'autorité canonique du rattachement session-Hub. Une relation active `games_hubs_sessions.status='active'` suffit à établir l'appartenance d'une session au Hub; les lectures Hub doivent consommer cette relation sans requalifier implicitement par opération, contexte ou typologie courante. Une lecture du Hub est non destructive: elle ne crée pas de Hub, ne réconcilie pas silencieusement, ne désactive pas de membership et ne déplace aucune session.

`id_operation_evenement` et `context_type` restent des éléments legacy ou de compatibilité. Ils peuvent aider un backfill strictement non ambigu quand aucune relation canonique n'existe encore, mais ils ne peuvent ni remplacer un Hub existant, ni désactiver un membership actif, ni déplacer implicitement une session d'un Hub vers un autre. En cas d'ambiguïté, le code doit conserver l'état persistant, journaliser/diagnostiquer, et attendre une correction explicite.

Le backfill `app_games_hub_sessions_reconcile(...)` conserve ce rôle legacy et n'est pas une commande métier d'ajout. Les parcours qui viennent de créer/configurer une session pour un Hub connu utilisent `app_games_hub_session_membership_ensure(...)`: cette commande valide le Hub et la session, exige le même compte, la même date et le même contexte opération/événement, crée ou réactive idempotemment la relation du Hub cible, puis relit la persistance. Une adhésion active à un autre Hub est refusée avec `SESSION_ALREADY_IN_OTHER_HUB`; aucun déplacement ou écrasement silencieux n'est effectué. Le quick-add partagé et la Bibliothèque Pro délèguent à cette même primitive.

Les wordings visibles peuvent suivre l'usage courant du compte sans modifier l'identité du Hub. Ainsi un Hub historiquement `context_type=soiree` peut afficher des libellés événement si le compte est désormais en gamification, tout en conservant le même `games_hubs.id`, `id_securite`, rattachements, joueurs, lots, publication, branding, sessions et historique.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_identity_stability_contract_test.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`.

## Update 2026-07-27 - Hubs: contrat serveur `presentation_mode`

La table `games_hubs` porte maintenant un état de présentation explicite, indépendant du focus runtime: `presentation_mode`.

Valeurs autorisées:
- `session`: présentation normale d'une session ou du branding Hub;
- `hub_podium`: présentation du podium agrégé du Hub;
- `hub_idle`: état Hub sans podium agrégé, utilisé pour masquer manuellement le podium.

`app_games_hub_presentation_mode_set(...)` écrit uniquement ce mode et `presentation_updated_at`; il ne modifie jamais `active_session_id`. Depuis le 2026-08-25, `app_games_hub_presentation_session_set(...)` écrit aussi la session présentée dans `presentation_session_id`, toujours sans modifier le runtime. À l'inverse, `app_games_hub_focus_set_active(...)` conserve son contrat runtime et aligne `presentation_session_id` sur la session lancée/reprise.

`app_games_hub_presentation_resolve(...)` expose `mode` en plus de `target` et `session_id`. Si le mode stocké vaut `hub_podium`, le resolver renvoie une cible distincte `hub_podium`; sinon il lit `presentation_session_id`, puis le focus runtime seulement comme fallback d'affichage.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_presentation_mode_contract_test.php`.

## Update 2026-07-26 - Branding Canvas Hub: fallback Cotton complet hors logo

Le fallback Cotton Hub résolu par `app_games_hub_branding_apply_cotton_defaults(...)` complète maintenant aussi les champs couleur et police manquants après la cascade session, Hub actif via `games_hubs_sessions.status='active'`, réseau et compte.

Les valeurs dynamiques communes sont `visuel.img_src` depuis l'asset Cotton Hub, `background_1=#240445`, `background_2=#bba9ff`, `font_1=#FFFFFF`, `font.family=Poppins` et l'URL Google Fonts Poppins. Elles ne s'appliquent que si les couches supérieures n'ont pas fourni le champ, donc un branding réseau ou compte reste prioritaire sur Cotton.

Le logo reste volontairement hors fallback Cotton: sans logo session, Hub, réseau ou compte, `logo.img_src` reste vide. Aucune ligne `general_branding` session ou Hub n'est créée automatiquement; le fallback reste résolu à la lecture.

Les logs Global/Games du 2026-07-26 ont aussi montré le cas `hub_session_membership_resolved` suivi d'un branding effectif vide. Les captures HTTP des sessions `27126` puis `27129` ont précisé la rupture: le JSON contenait bien le Hub résolu, les couleurs et la police Cotton, mais `visuel:""`. Le resolver Hub ne doit donc pas abandonner le fallback Cotton quand `id_client` ou les couches de branding Hub sont absents/inexploitables, l'URL publique `/assets/branding/hubs/cotton-hub-default-visual.jpg` ne doit pas dépendre d'un contrôle filesystem local, et l'endpoint `action=get` matérialise ce visuel à la frontière JSON si un Hub résolu arrive encore sans visuel.

En contexte Hub Canvas, un visuel session marqué comme copie d'un fallback historique de jeu (`branding-qz.png`, `branding-bt.png`, `branding-bm.png`) est ignoré avant le merge. La détection repose sur le hash du fichier local quand il existe, ou sur l'URL canonique connue; c'est une limite documentée faute de champ de provenance DB. Les sessions autonomes conservent leur fallback visuel historique, et un vrai visuel session différent reste prioritaire.

Fichiers de référence:
- `global/web/app/modules/general/branding/app_branding_ajax.php`;
- `global/web/app/modules/general/branding/app_branding_functions.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/app/modules/jeux/sessions_branding/app_sessions_branding_functions.php`;
- `global/web/tests/hub_operation_branding_cascade_test.php`.

## Update 2026-07-26 - Classements Hub: identité joueur canonique

Le contexte `app_client_joueurs_dashboard_context_compute(...)` enrichit maintenant les contributions runtime Hub depuis `games_hubs_players_sessions`.

Pour chaque session du filtre, le mapping `id_session + id_participation/player_id -> id_hub_player` permet de normaliser les joueurs injectés depuis le Hub sous une identité stable `hub_player:{games_hubs_players.id}` avant construction des leaderboards. Cette identité remplace les identités runtime propres à Quiz, Blind Test ou Bingo quand le mapping est prouvé; les contributions sans mapping fiable gardent leur identité runtime et ne sont pas fusionnées par nom.

Blind Test conserve son contrat mixte existant: les équipes runtime restent des participants équipe distincts, avec leur propre identité, et leur score n'est pas redistribué aux membres. Un joueur Hub solo ne fusionne jamais avec une équipe de même nom.

Fichier de référence:
- `global/web/app/modules/entites/clients/app_clients_functions.php`.

## Update 2026-07-26 - Hubs: origine membership du Programme

La requête canonique `app_games_hub_sessions_get(...)` sélectionne maintenant explicitement `games_hubs_sessions.membership_source` sous l'alias `hub_membership_source`.

Les interfaces Hub peuvent ainsi distinguer une session créée via ajout rapide Hub (`quick_hub_create`) d'une session dashboard ou legacy sans déduire cette origine depuis l'état runtime, l'horaire, le contenu ou une autre donnée indirecte.

Fichier de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-07-26 - Hubs: métadonnées de séries Quiz

`app_games_hub_sessions_get(...)` expose désormais, en plus du libellé principal compact `hub_theme_label`, les champs `hub_quiz_series_label` et `hub_quiz_series_names` issus du détail Quiz.

Les interfaces consommatrices peuvent donc garder `4 séries` comme titre de thématique tout en affichant les noms réels des séries en sous-ligne, sans recalculer le contenu depuis `lot_ids`.

Fichier de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-07-26 - Ajout rapide Hub: token runtime compatible Quiz/Blind Test

`app_programming_quick_hub_create_from_proposal(...)` génère désormais l'`id_securite` des sessions Hub quick-add via `app_programming_quick_hub_session_security_id_generate(...)`, avec une longueur maximale de 64 caractères.

Cette borne est nécessaire car `championnats_sessions.id_securite` accepte 255 caractères, mais les tables runtime Quiz et Blind Test utilisent `cotton_quiz_sessions.session_id varchar(64)` et `blindtest_sessions.session_id varchar(64)`. Le `quick-schedule` historique produit le plus souvent `session_id() . uniqid()`, compatible avec cette limite; le premier portage Hub ajoutait un segment hash supplémentaire et pouvait dépasser 64 caractères, empêchant Quiz/Blind Test de matérialiser puis relire leur ligne runtime. Bingo n'utilise pas ces deux tables comme source primaire de statut.

La recette terrain a confirmé le correctif après déploiement Global seul; le patch défensif Games envisagé puis annulé n'est pas nécessaire pour cette régression.

Fichiers de référence:
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`;
- `global/web/tests/programming_quick_hub_service_contract_test.php`.

## Update 2026-07-26 - Ajout rapide Hub: format et mode transverses

L'ajout rapide dashboard Pro et Hub Master déduit désormais le mode et le format à l'échelle du Programme Hub complet, pas seulement depuis les sessions du même jeu que celui ajouté.

Le mode papier/smartphone reste choisi par majorité sur les sessions éligibles du Programme. Le format passe par une clé métier commune: `short` signifie 20 titres pour Blind Test/Bingo et 2 séries pour Cotton Quiz; `standard` signifie 40 titres pour Blind Test/Bingo et 4 séries pour Cotton Quiz. Cette clé est ensuite remappée vers le `session_id_format` du jeu ajouté et, pour Quiz, vers `quiz_pick_count`.

Exemples couverts: un Programme de Blind Test numériques courts ajoute un Quiz numérique 2 séries; un Programme de Blind Test papier courts ajoute un Quiz papier 2 séries ou un Bingo papier 20 titres; un Programme de Quiz numériques 4 séries ajoute un Bingo/Blind Test numérique 40 titres.

Fichiers de référence:
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`;
- `global/web/tests/programming_quick_hub_service_contract_test.php`.

## Update 2026-07-26 - Quiz auto history: libellé de secours culture G

Les builders automatiques Cotton Quiz conservent le comportement de secours existant: une série `history` peut être complétée par des questions génériques quand le stock strict `jour_associe` à ±5 jours de la date de jeu ne suffit pas à remplir les 6 questions.

Pour garder l'UI cohérente avec le contenu réel, la persistance des lots temporaires vérifie maintenant les 6 questions produites avant de nommer la série. Si elles respectent toutes la règle `history_pm5`, le lot reste `Cette semaine dans l'histoire`. Sinon, le lot temporaire est conservé mais nommé exactement `Mix culture G`, avec un descriptif de culture générale. Le même contrat s'applique aux lots papier `T...` et numériques `N...`; pour les numériques, le `contexte_generation` persistant bascule aussi de `type=history_events` à `type=culture_g`.

Fichiers de référence:
- `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`;
- `global/web/tests/quiz_auto_history_label_contract_test.php`.

## Update 2026-07-26 - Ajout rapide Quiz Hub: anti-répétition du Programme

Le service Global d'ajout rapide Hub utilise désormais `app_programming_quick_theme_plan_build(...)` comme primitive de planification commune. Elle construit un plan de sélections à partir du catalogue normalisé, des exclusions temporaires, de l'historique client, des sélections déjà choisies dans le même plan et des sélections déjà présentes dans le Programme.

La source automatique de candidats est alignée sur le quick-schedule: catalogue Cotton uniquement. Quand le loader Bibliothèque Pro `clib_list_get(..., 'cotton', ..., 'themes')` n'est pas disponible, le fallback SQL Global ne sélectionne plus les contenus du client ni tous les contenus publics validés. Il garde seulement les contenus Cotton natifs (`id_client_auteur=0` avec statut publié) et les contenus communauté promus/certifiés Cotton via `community_items.origin='cotton'`.

Pour l'ajout rapide Pro/Games, `app_programming_quick_hub_suggestion_build(...)` relit les parties actives du Hub via le contexte serveur (`games_hubs_sessions` côté appelant Global/Games/Pro), reconstruit les sélections métier canoniques par jeu, puis appelle la primitive avec `requested_count=1`. Pour Cotton Quiz, chaque token `L/T/N` déjà programmé dans le Hub devient une exclusion de slot catalogue avant de proposer les quatre séries suivantes; le fallback best-effort Quiz ne relâche plus ces exclusions Hub.

`app_programming_quick_hub_create_from_proposal(...)` compare maintenant la sélection signée à la proposition recalculée côté serveur avant création et retourne `PROPOSAL_STALE` si le Programme a changé entre suggestion et écriture. Cela évite qu'une proposition générée avant un autre ajout soit appliquée après coup.

Fichiers de référence:
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`;
- `global/web/tests/programming_quick_hub_service_contract_test.php`.

## Update 2026-07-26 - Ajout rapide Quiz Hub: fallback catalogue robuste

Le service Global d'ajout rapide Hub garde `app_programming_quick_hub_create_from_game(...)` comme entrée commune Pro/Games. Pour Cotton Quiz, la proposition reste volontairement un payload catalogue `L...` best-effort non vide; les builders Quiz matérialisent ensuite les lots `T` / `N` après création de l'id session.

Le loader catalogue Quiz ne fait plus dépendre la disponibilité des séries du seul `JOIN community_items`. Il tente toujours le loader Bibliothèque Pro `clib_list_get(...)` quand il est chargé, puis n'ajoute le `JOIN community_items` SQL direct que si toutes les colonnes du contrat existent (`source_type`, `source_id`, `game`, `content_type`, `status`, `origin`). Si le SQL enrichi échoue malgré tout, il journalise `CATALOG_CANDIDATES_COMMUNITY_SQL_FAILED` et retombe sur la requête `questions_lots` historique.

Le fallback SQL léger ne suppose plus que `questions_lots.position` existe: il garde l'ordre historique par position quand la colonne est disponible et retombe sur `id DESC` sinon. Les échecs SQL de fallback sont maintenant journalisés via `CATALOG_CANDIDATES_SQL_FAILED`, afin de distinguer une vraie absence de séries d'un contrat DB incomplet. Ainsi, un schéma communautaire absent ou incomplet ne transforme plus un catalogue Quiz exploitable en `candidate_count=0`.

La notice de `app_cotton_quiz_session_get_detail(...)` sur une session Quiz non encore lancée est également bornée au contrat existant: l'absence de ligne `cotton_quiz_sessions` avant lancement retourne le détail par défaut au lieu d'indexer une ligne nulle.

Fichiers de référence:
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`;
- `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`;
- `global/web/tests/programming_quick_hub_service_contract_test.php`.

## Update 2026-07-25 - Service Global d'ajout rapide Hub

Le module `app/modules/jeux/programmation/app_programming_recommendations_functions.php` expose désormais le moteur métier partagé de l'ajout rapide Hub. L'entrée applicative commune est `app_programming_quick_hub_create_from_game(...)`: elle reçoit un contexte serveur fiable et un type de jeu, prépare une proposition compatible en interne, crée une seule partie et la rattache au Hub. Les primitives `app_programming_quick_hub_suggestion_build(...)` et `app_programming_quick_hub_create_from_proposal(...)` restent disponibles pour la validation sécurité et les tests de proposition signée.

Le service résout côté serveur les jeux autorisés, le mode, le format, les horaires, la thématique automatique et les renouvellements possibles. La création vérifie le token de proposition, le Hub actif/propriétaire, la fenêtre d'expiration, l'offre/contact serveur quand disponible, l'idempotence et la relation `games_hubs_sessions`, explicitement assurée par `app_games_hub_session_membership_ensure(...)` pour la session créée avant vérification. Le navigateur ne peut pas imposer un compte, un Hub, un format, un mode ou une thématique arbitraire.

Le contrat Quiz reprend les règles quick-schedule Pro: le catalogue reprend les séries Cotton legacy, les séries promues Cotton via `community_items` et les séries client autorisées; la proposition prépare un payload catalogue best-effort non vide, sans exiger dès cette étape le nombre final de séries distinctes. Le format court numérique vise quatre candidats catalogue pour alimenter les fallbacks, puis applique exactement deux séries. Les formats Quiz appellent les builders existants `qz_build_paper_quick_short_lot_ids_csv(...)`, `qz_build_numeric_quick_short_lot_ids_csv(...)`, `qz_build_paper_auto_lot_ids_csv(...)` et `qz_build_numeric_auto_pack_result(...)` après création de l'id session, afin que les lots temporaires `T` / `N` soient matérialisés comme dans le dashboard Pro historique.

Les retours sont normalisés pour Pro et Games: l'entrée directe renvoie `ok`, `code`, `message`, `session_ids`, `session_security_ids`, `hub_id`, `dashboard_url`, `replay` et un `quick_context` serveur pour les logs. Cette entrée nettoie `suggestion` et `proposal_token` avant retour afin qu'un adaptateur UI ne transporte pas de proposition signée dans le navigateur. Le service ne modifie pas `games_hubs.active_session_id` et ne dépend pas d'une session navigateur Pro.

Fichiers de référence:
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`;
- `global/web/tests/programming_quick_hub_service_contract_test.php`.

## Update 2026-07-24 - Fallback Cotton Hub sans logo

La cascade branding Hub/session reste fusionnée champ par champ: session, Hub actif via `games_hubs_sessions.status='active'`, réseau, compte, puis Cotton uniquement pour les champs encore absents. Le fallback Cotton ne fournit plus `logo.img_src`: en absence de logo session/Hub/réseau/compte, le branding effectif n'a aucun logo.

Le fallback Cotton conserve le visuel et les autres propriétés canoniques existantes. Les helpers d'asset logo Cotton restent disponibles comme résolveurs d'asset, mais `app_games_hub_branding_apply_cotton_defaults(...)` ne les consomme plus pour compléter un branding.

Les chemins Hub directs utilisés par des sessions officielles lancées depuis Games conservent aussi ce fallback visuel, même lorsqu'aucune ligne `general_branding` Hub explicite n'existe. Les snapshots de démo matérialisent ce visuel Cotton dans le branding session cible après la copie éventuelle des assets issus des couches supérieures.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/app/modules/general/branding/app_branding_functions.php`;
- `global/web/app/modules/jeux/sessions_branding/app_sessions_branding_functions.php`;
- `global/web/tests/hub_operation_branding_cascade_test.php`.

## Update 2026-07-24 - Régression branding Hub sessions officielles et démos

Le resolver Canvas des sessions officielles rattachées à un Hub consomme à nouveau une cascade effective champ par champ: branding session explicite, puis branding Hub via `games_hubs_sessions.status='active'`, puis réseau, compte et fallback Cotton Hub existant. En contexte `branding_context=game` ou `CanvasBrandingHydrator`, un branding session partiel ne bloque donc plus l'héritage Hub pour les champs absents.

La résolution Hub utilisée pour le branding runtime ne déclenche pas la réconciliation legacy par date/opération: elle lit uniquement la relation active persistée. Les appels historiques hors contexte canvas conservent le fallback session/événement/réseau/compte existant.

Fichiers de référence:
- `global/web/app/modules/jeux/sessions_branding/app_sessions_branding_functions.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_operation_branding_cascade_test.php`.

## Update 2026-07-24 - Snapshot démo Hub autonome

Le flux Pro `session_duplicate` peut matérialiser la cascade branding effective d'une session officielle vers le branding session de sa démo. Le helper `app_general_branding_snapshot_to_target(...)` écrit les champs résolus dans `general_branding.id_type_branding=1` et copie les médias depuis les sources `_cascade_sources` existantes, sans rattacher la démo au Hub ni modifier le branding Hub ou la session officielle.

Pour Bingo Musical, `app_bingo_musical_playlist_client_duplicate_for_demo(...)` clone la playlist client déjà préparée avec ses lignes `jeux_bingo_musical_morceaux_to_playlists_clients` ordonnées et numérotées. Les grilles de démo restent régénérées séparément et limitées par la capacité démo historique.

Fichiers de référence:
- `global/web/app/modules/general/branding/app_branding_functions.php`;
- `global/web/app/modules/jeux/bingo_musical/app_bingo_musical_functions.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`.

## Update 2026-07-24 - Fallbacks Cotton partagés pour publication Hub

Le module Hub Global expose désormais `app_games_hubs_publication_defaults(hub_type, locale)` et `app_games_hubs_publication_resolve(hub, publication, locale)` pour l'accroche et la description des Hubs soirée/événement. La V1 est bornée au français et ne crée aucune migration.

La résolution retourne, pour `tagline` et `description`, trois notions distinctes: `raw` correspond à la valeur réellement enregistrée dans `games_hubs_publication`, `effective` correspond à la valeur affichable, et `source` vaut `hub` ou `cotton`. La priorité est strictement Hub personnalisé non vide puis fallback Cotton du type de Hub. Aucun héritage réseau, aucune fiche lieu et aucune fiche événement legacy ne servent de fallback éditorial.

Les textes Cotton restent des fallbacks de lecture et ne sont jamais copiés automatiquement en base. Le titre du Hub reste hors de ce mécanisme et conserve ses règles existantes. `app_games_hub_public_resolve(...)` expose cette nouvelle résolution sous `publication.texts` pour les futurs consommateurs, sans modifier les clés legacy `publication.tagline` / `publication.description` déjà consommées par les pages publiques.

Consommateurs à aligner au patch suivant: `www/web/fo/modules/operations/hubs/fr/fo_hubs_view_shared.php`, `www/web/fo/modules/operations/hubs/fr/fo_hubs_seo.php`, `www/web/fo/modules/operations/evenements/fr/fo_evenements_seo.php`, les anciennes vues événement encore actives, Hub Master/Play et les payloads JSON publics qui exposent `games_hubs_publication.tagline` ou `description`.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_publication_prizes_contract_test.php`.

## Update 2026-07-23 - Quiz quick-schedule court

Le socle Cotton Quiz expose deux builders courts réservés au quick-schedule Pro. `qz_build_paper_quick_short_lot_ids_csv(...)` produit une composition papier à deux séries: un lot temporaire `T` histoire puis un lot thématique `L`. `qz_build_numeric_quick_short_lot_ids_csv(...)` tente une série numérique `N history_events` puis un lot `L` seulement quand le garde-fou numérique l'autorise, actuellement le bypass admin `id_client=10`; si les questions numériques certifiées ne suffisent pas ou si le client n'est pas autorisé, il retombe sur deux lots `L` valides.

Les builders standard historiques ne sont pas modifiés: `qz_build_paper_auto_lot_ids_csv(...)` conserve les 4 séries papier, et le pack numérique standard garde ses familles existantes. Les succès et fallback courts sont journalisés côté technique, sans message visible dans le programmateur.

Fichier de référence:
- `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`.

## Update 2026-07-23 - Assets Cotton Hub canoniques

Les Hubs soirée/événement utilisent désormais une source Cotton statique partagée pour les assets par défaut. Les helpers `app_cotton_hub_default_logo_path_get/url_get()` et `app_cotton_hub_default_visual_path_get/url_get()` résolvent respectivement le filesystem et l'URL publique depuis `global/web/assets/branding/hubs/`.

`app_games_hub_branding_apply_cotton_defaults(...)` complète les brandings Hub sans visuel explicite avec l'asset visuel Cotton. Le fallback Cotton ne complète plus le logo: un logo effectif doit venir d'une couche session, Hub, réseau ou compte. Le fallback SVG inline historique n'est plus la source Global pour les Hubs.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/assets/branding/hubs/cotton-hub-default-logo.png`;
- `global/web/assets/branding/hubs/cotton-hub-default-visual.jpg`.

## Update 2026-07-23 - Duplication branding Hub: assets sur clé canonique

`app_general_branding_duplicate_to_target(source_branding_id, target_type, target_related)` et les copies d'assets dérivées doivent résoudre le rattachement source via `app_general_branding_row_related_get(...)`. Pour un branding Hub `id_type_branding=5`, le dossier média canonique dépend de `id_ref=games_hubs.id`, pas d'une lecture directe de `id_related`.

Cette règle permet de recopier durablement logo et visuel d'un branding Hub vers un branding compte ou une autre cible sans dépendre d'un emplacement Hub réservé au contexte courant. La duplication conserve la convention générique: préparation d'un répertoire cible avec staging/backup, puis hydratation par `app_general_branding_get_upload_detail(...)`.

Fichiers de référence:
- `global/web/app/modules/general/branding/app_branding_functions.php`;
- `global/web/tests/hub_operation_branding_cascade_test.php`.

## Update 2026-07-22 - Hub dashboard terminé: verrouillage des mutations

`app_games_hub_dashboard_is_completed(hub)` expose le prédicat partagé utilisé pour verrouiller les mutations d'un dashboard soirée/événement terminé. Il s'appuie uniquement sur les sessions actives du Hub: une session est fermée si elle est terminée côté runtime/édition ou si sa fenêtre chronologique est passée. Un Hub sans sessions actives n'est pas considéré comme terminé par ce prédicat.

`app_games_hub_session_belongs_to_completed_hub(id_session, hub)` résout l'appartenance via `games_hubs_sessions.status='active'` et refuse de déduire un Hub par date, client ou opération. Cette borne sert au renouvellement thématique pour refuser les appels directs sur une session attachée à un Hub terminé, même si le payload ne fournit pas de `hub_id`.

`app_games_hub_prizes_save(...)` refuse désormais `HUB_NOT_EDITABLE` avant toute écriture lorsque ce prédicat indique un Hub terminé. La personnalisation Pro et les services `app_programming_theme_renewal_plan_for_session(...)` / `app_programming_theme_renewal_apply_for_session(...)` consomment le même verrou.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`;
- `global/web/tests/hub_publication_prizes_contract_test.php`;
- `global/web/tests/session_theme_renewal_planner_test.php`;
- `global/web/tests/session_theme_renewal_apply_test.php`.

## Update 2026-07-22 - Résultats Bingo: composition runtime exclusive

`app_session_results_get_context(...)` sépare maintenant la composition des joueurs Bingo et l'enrichissement des libellés. Quand `bingo_players.session_id = championnats_sessions.id_securite` retourne au moins un joueur, cette source runtime définit exclusivement la liste affichée et `players_count`.

Les sources historiques ne peuvent alors que réparer un libellé runtime vide ou générique (`JOUEUR`, `JOUEUR INCONNU`) par correspondance exacte `game_player_id` ou `game_player_key` issue de `championnats_sessions_participations_games_connectees`. Un nom runtime valide n'est pas écrasé et aucun rapprochement par simple nom/pseudo normalisé ne décide de l'appartenance.

Si aucun joueur runtime n'existe, le fallback utilise d'abord les participations historiques exactes rattachées à `id_championnat_session`, puis les anciennes grilles `jeux_bingo_musical_grids_clients` seulement si le garde historique existant l'autorise: session non-démo, type Bingo compatible, playlist non partagée entre plusieurs sessions Bingo non-démo. Les fallbacks ne modifient ni score, ni rang, ni podium.

Fichiers de référence:
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`;
- `global/web/tests/session_results_bingo_membership_contract_test.php`.

## Etat 2026-07-20 - Service de recommandation de programmation

## Update 2026-07-22 - Compteurs Hub de participations globales

`app_games_hub_participation_counters_get(hub)` expose l'agrégat partagé pour les compteurs globaux d'une soirée/événement Hub. Les sessions sources sont uniquement les relations actives `games_hubs_sessions`, sans heuristique par date, client ou opération.

Définitions actuelles:
- `expected_count`: participations probables issues de `championnats_sessions_participations_probables`, dédoublonnées par identité stable `id_joueur` puis `id_equipe` sur l'ensemble du Hub;
- `present_count`: joueurs Hub actifs dans `games_hubs_players`, utilisé pour la présence du jour J;
- `effective_count`: joueurs Hub ayant une participation runtime prouvée dans au moins une session liée, via `games_hubs_players_sessions.status IN ('active','completed')` et `id_participation > 0`.

La future inscription directe au Hub pourra remplacer la source `expected` dans ce helper sans changer les vues consommatrices. Le helper ne crée aucune table et ne modifie aucun flux d'inscription.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_participation_counters_contract_test.php`.

## Update 2026-07-22 - Suppression complète canonique Hub

`app_games_hub_delete_complete(id_hub, id_client, id_client_contact, options)` est le service métier unique de suppression complète d'un Hub soirée/événement. L'objet racine est `games_hubs.id`; une date seule n'est jamais une cible valide. Le service vérifie le compte propriétaire, prend un verrou applicatif MySQL `GET_LOCK`, marque `games_hubs.hub_status='deleting'`, persiste `delete_operation_token`, `delete_step`, `delete_started_at` / `delete_error_at`, puis valide toutes les sessions membres avant mutation destructive.

Les sessions supprimées sont uniquement les relations actives `games_hubs_sessions.id_hub -> id_session`. Une session rattachée à un autre Hub actif, hors compte ou déjà démarrée/terminée selon `app_session_edit_state_get(...)` bloque la suppression complète. Chaque session membre est supprimée via `app_session_delete_canonical(...)`, qui conserve les nettoyages historiques par jeu: Quiz V1 + équipes, Bingo Musical, Blind Test, Quiz V2, puis `app_session_supprimer(...)`.

Après les sessions, le service nettoie `games_hubs_players_sessions`, `games_hubs_players`, `games_hubs_publication`, `games_hubs_prizes`, le branding Hub exclusif `general_branding.id_type_branding=5` (`id_ref` ou `id_related` = Hub) avec ses médias, puis `games_hubs_sessions` et enfin `games_hubs`. Les anciennes opérations/événements ne sont pas supprimés sans preuve d'exclusivité; les relations legacy sont seulement rendues inopérantes par la suppression des sessions/du Hub.

Les tables Hub restent `MyISAM`; cette suppression n'est donc pas atomique. La garantie obtenue est déterministe et reprenable: un Hub en `deleting` n'est plus réutilisé par `app_games_hub_get_or_create_for_context(...)`, les étapes déjà terminées peuvent être rejouées sans suppression dangereuse, et la ligne racine n'est supprimée qu'en toute fin. Une reprogrammation à la même date ne peut repartir à neuf qu'après disparition complète de cette racine Hub.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`;
- `global/web/tests/hub_delete_service_contract_test.php`.

## Update 2026-07-22 - Fallbacks Hub Cotton

Les titres de fallback partagés pour les Hubs soirée/événement sont désormais strictement `Soirée Cotton` et `Événement Cotton`. Ils ne reprennent plus automatiquement le nom du compte. Un titre explicitement personnalisé dans `games_hubs_publication`, l'événement legacy ou une autre source canonique reste prioritaire et n'est pas remplacé.

Fichier de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

Le module global `app/modules/jeux/programmation/app_programming_recommendations_functions.php` porte le socle réutilisable du programmateur rapide. Il expose un profil historique client, une recommandation sérialisable, le calcul borné des occurrences récurrentes et les stockages d'idempotence `programming_quick_operations` / `programming_quick_series_operations`.

Update 2026-07-21: le même module expose aussi le planner sans état `app_programming_theme_renewal_plan(...)` / `app_programming_theme_renewal_plan_for_session(...)` pour préparer un renouvellement de thématique sans écriture. Le planner couvre Blind Test, Bingo Musical et Quiz V2, exclut toujours la sélection courante relue ou validée côté serveur, accepte des exclusions temporaires non fiables en les intersectant avec les candidats éligibles, applique automatiquement depuis le wrapper session l'exclusion historique récente via `app_programming_theme_renewal_used_theme_ids_for_client_game_get(...)`, puis privilégie les thématiques associées à la date courante via `app_programming_theme_renewal_theme_is_in_associated_window(...)`. Il retourne `PROPOSED_SELECTION` ou `NO_ALTERNATIVE` sans relâcher les exclusions, et prépare le contrat `STALE_SELECTION` pour les futurs adaptateurs. Bingo raisonne en identifiants de playlist catalogue même quand la session persiste une playlist client; Quiz V2 renouvelle toutes les séries en conservant leur nombre exact et l'ordre de proposition. Aucun endpoint, aucune migration et aucune persistance de refus ne sont ajoutés dans cette passe.

Update application 2026-07-21: `app_programming_theme_renewal_apply_for_session(...)` applique une proposition explicite sans la recalculer. Le service relit la session, contrôle propriétaire/Hub/état éditable, compare `expected_current_selection` à la sélection persistée, revalide la proposition avec les mêmes primitives que le planner, puis effectue un `UPDATE championnats_sessions` conditionnel. Blind Test bascule seulement `id_produit`; Quiz V2 remplace `lot_ids` ordonné et maintient `id_produit` sur le premier token exploitable; Bingo matérialise une nouvelle playlist client avant la bascule conditionnelle. Les tables Bingo historiques étant MyISAM, l'opération n'est pas présentée comme transactionnelle: en cas de concurrence après matérialisation, le service retourne `STALE_SELECTION`, laisse la session inchangée, conserve l'artefact non affecté et expose son identifiant pour diagnostic. Aucune ancienne playlist/grille n'est supprimée, aucun PDF ni runtime n'est généré, et aucune interface ou route n'est exposée par ce patch.

Update Quiz 2026-07-22: le renouvellement Quiz V2 conserve le gabarit fonctionnel ordonné de la session remplacée. Le contrat ne se limite plus au nombre de séries ni au préfixe `L/T/N`: chaque position est décrite par `slot_template`, avec `type`, `recipe_key`, `role_key` et `slot`. Les recettes auto quick-schedule reconnues sont `history_events`, `arts_literature`, `science_sports_riddles`; le lot catalogue final d'un auto-pack porte le rôle `random`. Le planner enrichit la sélection courante depuis le référentiel candidat, puis choisit un candidat compatible par index. L'apply reconstruit le même gabarit canonique et refuse par `INVALID_PROPOSAL` une proposition qui change format, nombre, préfixe, ordre ou famille, y compris une simple permutation de deux lots temporaires du même type.

Les lots numériques `N` générés par quick-schedule exposent leur famille via `questions_lots_num_temp.contexte_generation` (`type=...`). Les lots papier `T` n'ont pas de colonne dédiée dans `questions_lots_temp`; leur famille est donc retrouvée depuis les métadonnées persistées par les builders auto (`nom` et `descriptif_court`). Aucune comparaison métier ne dépend d'un libellé reconstruit par le navigateur.

Le profil s'appuie sur la définition canonique de session passée significative via `app_client_joueurs_dashboard_session_is_history_useful(...)`. Pour le programmateur rapide, la source historique ne charge que les colonnes utiles à la recommandation et fournit au helper canonique des indicateurs pré-calculés de participants, démarrage et terminaison afin d'éviter les hydratations runtime et les requêtes par session. Les constantes V1 sont regroupées dans le module: au moins 3 soirées significatives, dominance minimale 60 %, marge minimale 10 points, fenêtres horaires de 30 minutes, fallback sans historique aujourd'hui si libre, Blind Test numérique, 19:00, 3 sessions, espacement de programmation rapide à 1 minute pour conserver l'ordre métier sans suggérer une durée de partie.

L'instrumentation du profil rapide journalise en dev ou avec `quick_profile_trace=1` les champs `client_id`, `source`, `history_fetch_ms`, `profile_build_ms`, `recommendation_ms`, `total_ms`, soirées significatives, sessions examinées et état de cache. Les requêtes `EXPLAIN` de diagnostic sont dans `documentation/programming_quick_profile_performance.sql`.

La recommandation reste sans effet de bord: elle combine le profil, le contexte `home|agenda` et une liste de dates occupées fournie par l'appelant. Home et Agenda utilisent la même règle: si un jour habituel fiable existe, proposer la prochaine occurrence libre de ce jour; si elle est occupée, chercher l'occurrence libre suivante du même jour de semaine. Sans historique suffisant, proposer aujourd'hui si libre, sinon la prochaine date libre chronologique. La recommandation fournit `date`, `start_time`, `game_type`, `version_or_format`, `session_count`, `session_spacing_minutes`, `recommended_sessions`, `reasons`, `confidence` et `warnings`. Le format du parcours rapide est déterminé par `app_programming_quick_default_session_format_get(...)` et reste le format standard par défaut, modifiable ensuite sur les fiches session.

Le service `app_programming_recurrence_occurrences_build(...)` extrait la partie réutilisable du moteur historique sans dépendance HTML ni session PHP. Il accepte une première date, une fréquence `weekly|biweekly|monthly`, un jour, une date de fin inclusive et une limite, puis retourne des occurrences `Y-m-d` normalisées. Il conserve les règles historiques hebdomadaires, bihebdomadaires et mensuelles, applique les limites soft/hard du parcours historique et refuse toute fréquence inconnue, notamment l'ancien mode `Dates libres`.

L'idempotence de série est séparée de l'idempotence unitaire dans `programming_quick_series_operations`. Cette table fige le gabarit, la récurrence normalisée, les occurrences, les exclusions/dates occupées, le plan de thèmes et le résultat par occurrence afin qu'un replay ou une reprise ne recrée pas une soirée déjà terminée et ne change pas les thèmes.

Fichiers de référence:
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`;
- `global/web/global_librairies.php`;
- `global/web/tests/programming_quick_recommendation_test.php`;
- `global/web/tests/programming_quick_recurrence_test.php`;
- `global/web/tests/session_theme_renewal_planner_test.php`;
- `global/web/tests/session_theme_renewal_apply_test.php`;
- `documentation/programming_quick_profile_performance.sql`.

## Etat 2026-07-17 - Contrat Hub unifié: publication, nom, planning et déplacement

Le `context_hub` est le modèle cible pour les soirées et événements créés depuis le Pro. La couche historique opérations/événements reste seulement un miroir de compatibilité quand une ancienne route en dépend encore; les nouvelles URLs et les pages publiques Hub doivent s'appuyer sur `games_hubs`, `games_hubs_publication` et `games_hubs_sessions`.

Une page publique Hub répond dès qu'un dashboard Hub existe avec au moins une session liée. La publication d'une session dans l'agenda global du site n'est pas un critère d'existence de cette page: les événements de gamification non publiés dans `/fr/agenda` doivent quand même porter leur page web Hub.

Les libellés de fallback sont centralisés: `Événement Cotton` pour les Hubs événement et `Soirée Cotton` pour les Hubs soirée. Le même contrat alimente dashboard Pro, Hub Master/Play, resolver public et pages publiques, afin d'éviter les divergences entre titre par défaut, nom de Hub et titre affiché.

Le résumé temporel partagé expose le format `date · à partir de HHhMM · N session(s)`. Il est utilisé comme sous-titre commun côté dashboard, Hub Master/Play et page publique Hub.

Le déplacement de date d'un Hub réutilise la règle d'éligibilité historique: toutes les sessions liées peuvent être déplacées ensemble tant qu'aucune n'a commencé. La cible peut être la date du jour, mais elle est refusée si le compte porte déjà une soirée ou un événement à cette date. La mise à jour synchronise le Hub, la relation événement éventuelle et les sessions en conservant leurs horaires.

Fichier de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Etat 2026-07-17 - Resolver public Hub publiable

`app_games_hub_public_resolve(...)` est le contrat métier commun pour les pages publiques Hub. Il retourne publication, visibilité, temporalité, plage horaire, URLs, client, événement legacy éventuel, lieu, branding, lots Hub et sessions publiques filtrées.

Un Hub n'est pas rendu public par sa seule existence. Il doit être actif, avoir une ligne `games_hubs_publication`, ne pas porter un statut de publication désactivé, avoir au moins une session publique complète rattachée et un titre public non générique. Les soirées exigent aussi un lieu publié quand `clients.online` est disponible. Les événements legacy refusent les événements démo ou privés quand ces champs existent.

L'URL publique stable d'une soirée est dérivée de `games_hubs.id_securite` via `app_games_hub_public_url_get(...)`, jamais de l'ID SQL. Les événements conservent leur URL canonique historique `/fr/evenements/{slug}` quand un Hub événement existe, afin d'éviter deux pages indexables concurrentes.

Les sessions rattachées restent exposées comme programme interne du Hub. Les lots restent lus depuis `games_hubs_prizes`; les lots propres aux sessions ne redeviennent pas le modèle public d'un Hub.

Fichier de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Etat 2026-07-17 - Cascade branding Hub/session

Le resolver général expose désormais `app_general_branding_get_detail_merged(...)`: il ne s'arrête plus au premier branding trouvé, mais complète chaque champ manquant en priorité session, opération/Hub, réseau, compte. Pour les sessions de jeu, la couche opération est toujours le branding du Hub (`id_type_branding=5`, `id_ref=games_hubs.id` ou ancien `id_related=games_hubs.id`). `id_operation_evenement` est ignoré par ce chemin de jeu.

`games_hubs_sessions` porte désormais l'appartenance structurelle Hub/session. `app_games_hub_get_or_create_for_context(...)`, l'ouverture programme `app_games_hub_sessions_get(...)` et le resolver inverse `app_games_hub_get_for_session(...)` réconcilient les anciennes données uniquement quand les règles legacy `id_operation_evenement` ou `id_client + date` désignent un Hub actif unique. En cas de plusieurs Hubs candidats, aucun choix implicite n'est fait: `hub_session_membership_ambiguous` est journalisé et la liaison doit être corrigée explicitement.

`app_games_hub_sessions_get(...)` consomme la relation persistée `games_hubs_sessions` pour `Hub → sessions`. `app_games_hub_get_for_session(...)` consomme la même relation pour `session → Hub`; quand une ligne active existe, la lecture persistée est autoritaire et ne refiltre pas par client, date, opération ou flag Hub. Les écarts de contexte éventuels sont journalisés en diagnostic, mais ne font pas retomber Canvas à `resolved_hub_id=0`. Si aucune liaison n'existe encore, il tente le backfill non ambigu puis relit la relation. L'héritage Hub n'est donc plus fondé sur deux requêtes concurrentes et fonctionne avec `id_operation_evenement=0`, en dynamisation comme en gamification, dès que la relation est persistée ou réconciliable.

Pour le branding Canvas, le Hub suit le même niveau de granularité que le réseau: le réseau reçoit un `id_client_reseau`, cherche directement `general_branding.id_type_branding=3`, puis hydrate via `app_general_branding_get_complete(...)`; le Hub reçoit un `id_session`, résout légèrement `id_hub` via `games_hubs_sessions`, cherche directement `general_branding.id_type_branding=5 AND id_ref=id_hub`, puis utilise la même hydratation générique. Ce chemin ne charge ni détail session complet, ni participants, ni état runtime, ni adaptateur Quiz/Blind Test/Bingo.

L'endpoint `general/branding?action=get`, déjà utilisé par les sessions de jeu pour le branding réseau, passe maintenant par `app_session_branding_get_detail(...)`. `global_ajax.php` charge explicitement les helpers Hub et sessions branding nécessaires à ce chemin réel. La cascade Hub est activée pour les requêtes Canvas via `CanvasBrandingHydrator` ou, pour les appels navigateur de modale, `branding_context=game`. `branding_fetch_session_row(...)` inclut `date`, sans quoi le helper Hub canonique ne peut pas rattacher les anciennes sessions non encore persistées.

Le fallback historique réseau/compte est conservé: un résultat session minimal `id=0` ne bloque plus la suite de cascade.

`app_games_hub_operation_branding_get_for_event(...)` reste séparé pour la page publique événement. Sans Hub trouvé, la page conserve son ancien bandeau événement legacy.

Fichiers de référence:
- `global/web/app/modules/general/branding/app_branding_functions.php`;
- `global/web/app/modules/general/branding/app_branding_ajax.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/app/modules/jeux/sessions_branding/app_sessions_branding_functions.php`.

## Etat 2026-07-17 - Publication et lots Hub canoniques

`app_games_hub_schema_ensure()` crée désormais aussi `games_hubs_publication` et `games_hubs_prizes`.

`games_hubs_publication` est la source éditoriale/pratique du Hub: titre, accroche, description, lieu/adresse personnalisés, lien et statut. Elle ne contient ni visuel, ni logo, ni couleurs, ni sessions. L'absence de ligne signifie absence de personnalisation.

`games_hubs_prizes` est la source des lots globaux du Hub, rangs 1 à 3. Elle ne porte aucun gagnant, remise, date de remise ni relation joueur/session. `app_games_hub_prizes_save(...)` insère/met à jour les rangs non vides, supprime les rangs vidés et marque `games_hubs.prizes_initialized_at`; il ne recopie plus vers `championnats_sessions`.

`app_games_hub_prizes_get(...)` lit d'abord `games_hubs_prizes`. Si aucun lot Hub n'existe et que `games_hubs.prizes_initialized_at` est encore vide, un bootstrap borné reprend au plus une fois la première session du programme qui porte des lots personnalisés; les divergences entre sessions sont journalisées et ne sont pas fusionnées. Un Hub initialisé avec zéro lot ne réimporte plus les sessions historiques et retourne le fallback générique `1ᵉʳ prix / 2ᵉ prix / 3ᵉ prix`.

`app_games_hub_public_resolve(...)` expose un contrat commun pour dashboard/pages publiques: publication, lieu, branding, lots et sessions. Les champs éditoriaux ne tombent pas sur le lieu ou le compte; en soirée, seules les informations factuelles de lieu peuvent utiliser le compte comme fallback.

## Etat 2026-07-17 - Branding Hub soirée

`app_games_hub_branding_get(...)` résout maintenant une couche `branding_hub` pour les Hubs, y compris `context_type=soiree` sans événement rattaché. Cette couche est stockée dans `general_branding` avec `id_type_branding=5` et `id_ref=games_hubs.id` (`id_related=games_hubs.id` reste accepté en compatibilité), puis ses fichiers sont uploadés sous `operations/hubs_branding/{id_hub}`.

Cette résolution ne change pas les pages publiques événement legacy, mais le contexte Canvas jeu lit la cascade cible `branding_session -> branding_hub -> branding_reseau -> branding_client -> fallback Cotton`. Si aucune couche Hub n'existe, la cascade réseau puis compte puis fallback Cotton reste inchangée.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/app/modules/general/branding/app_branding_functions.php`.
- `documentation/games_hubs_sessions_phpmyadmin.sql`.

## Etat 2026-07-15 - Lots Hub: resolver de compatibilite session

Le module Hub expose aussi `app_games_hub_branding_fallback_visual_get()`, asset Cotton 600x240 canonique commun au Hub Games et au dashboard Pro. La resolution effective reste `app_games_hub_branding_get(...)`, qui transmet au resolver general les scopes session eventuel, evenement, reseau et compte; sans visuel effectif, les consommateurs utilisent cet asset Cotton et jamais le visuel d'une session.

Historique 2026-07-15: avant la table `games_hubs_prizes`, le modele restait porte par `championnats_sessions.lot_1/lot_2/lot_3` et le resolver normalisait les defaults techniques propres au Bingo et les defaults visuels Quiz/Blind Test dans l'ordre public Hub.

Ce writer historique propageait les trois rangs aux sessions rattachees. Il est remplacé depuis le 2026-07-17 par la persistance directe Hub dans `games_hubs_prizes`; Quiz, Blind Test et Bingo lisent l'ordre canonique Hub sans réécriture des champs session.

## Etat 2026-07-15 - Continuité des identités Remote papier dans le Hub

`app_games_hub_session_register_bridge(...)` persiste le joueur Hub et son mapping dès le succès du `player_register` papier. Le joueur global reste injectable tant que `games_hubs_players.status='active'`, indépendamment du statut `completed` d'un mapping de session. Au lancement papier, un contexte PHP interne et éphémère autorise les adaptateurs à rattacher une unique ligne runtime historique à la clé Hub stable; il exige jeu, token session, clé, pseudo, Hub et joueur Hub concordants et n'est jamais transporté par le navigateur.

La requête injectable est la même que celle du compteur Hub actif: `SELECT * FROM games_hubs_players WHERE id_hub = ? AND status = 'active' ORDER BY id ASC`. Elle n'utilise ni cookies, ni stockage navigateur, ni présence préalable sur Hub Play. Une réparation ne change que la clé de participation runtime et conserve la ligne ainsi que ses résultats associés.

## Etat 2026-07-13 - Games hubs participation papier persistante

Le resolver Hub ne considère plus `papier` comme l'absence de participation runtime. `app_games_hub_paper_participation_ensure(...)` appelle sous verrou le seul `player_register` moteur, sans preload numérique ni opération Player complémentaire, puis active le mapping avec l'ID runtime prouvé. `paper_registration_confirmed` et le message feuille papier restent faux/vides tant que cette preuve manque. Le focus papier est pollé par `active_launched_session`, mais ne redirige jamais vers `/play`.

## Etat 2026-07-13 - Focus Hub monotone après relance

`games_hubs.active_session_id` est relu directement en base avant toute résolution de sessions, présentation, écriture ou clear. `app_games_hub_focus_set_active(...)` valide l'appartenance, écrit synchroniquement `active_session_id` et `active_session_activated_at`, relit la ligne puis refuse la suite si l'ID confirmé diffère de la session demandée. `launch_session` applique ce commit même pour une session déjà runtime `running`, avant création de l'exécution, injection des joueurs et redirect.

Tous les clears relisent le focus et conservent la condition SQL `active_session_id = session_attendue`; une sortie ou fin tardive de A ne peut donc pas effacer B. L'auto-join, le routage Remote historique et `app_games_hub_sessions_get(...)` n'élisent jamais une session à partir du runtime `running`; `app_games_hub_presentation_resolve(...)` peut seulement produire un fallback d'affichage non destructif.

Pour le seul fallback visuel du Master sans focus persistant, `app_games_hub_sessions_get(...)` enrichit chaque session avec son dernier événement `hub_execution_started` appartenant au Hub. Le Master conserve d'abord la prochaine session à venir; s'il n'en existe plus, cet historique durable désigne la session suspendue la plus récemment lancée, sans réutiliser l'heure programmée comme preuve d'activité.

## Etat 2026-07-13 - Reset score borné au rejoin manuel Hub

`app_games_hub_runtime_participation_ensure(...)` autorise la remise à zéro Quiz/Blind Test uniquement pour `join_source=manual`, avec réactivation permise et mapping relu sous verrou encore `left`. Un contexte PHP interne éphémère porte jeu, session et identité canonique pendant le seul `game_api_dispatch(player_register)` concerné; il est restauré en `finally` et n'est pas forgeable par le payload navigateur. Jalons: `hub_session_manual_rejoin_score_reset_authorized` puis `hub_session_manual_rejoin_score_reset_result`. Les autres ensures, relances organisateur et parcours hors Hub ne demandent aucun reset.

## Etat 2026-07-13 - Games hubs fins naturelles durables

Le lancement Hub écrit `hub_execution_started` dans `game_events`, avec un identifiant d'exécution distinct du simple token session. Après fin naturelle acceptée et clear conditionnel réussi, `hub_execution_completed` ferme cette incarnation. `app_games_hub_natural_completion_events_get(...)` exige désormais que la dernière écriture terminale précède cette preuve de complétion; une fin historique ultérieure invalide donc le redirect Hub. Aucun schéma ni barème n'est ajouté.

## Etat 2026-07-11 - Games hubs ensure participation runtime

`app_games_hub_runtime_participation_ensure(...)` est le point unique Hub pour réconcilier identité persistante et participation moteur:
- validation du `participant_key` canonique `p:*`;
- préchargement du runtime puis appel idempotent `player_register`;
- validation stricte de la clé et de l'ID retournés;
- mise à jour du mapping avec l'ID runtime courant;
- verrou MySQL nommé et borné par hub/session/joueur pour sérialiser double polling, injection Master et ouverture Player;
- retour explicite `created`, `reconciled`, `reason`, `participation_id`, `mapping` et réponse moteur.

Un mapping `left` est refusé par défaut. Le rejoin manuel doit transmettre explicitement l'autorisation de réactivation. Les sessions terminées sont refusées. Aucun état de destination Hub n'est modifié par cet ensure.

## Etat 2026-07-11 - Games hubs destination de presentation

`app_games_hub_presentation_resolve(...)` formalise la destination affichée:
- hub actif avec `presentation_mode=hub_podium`: `target=hub_podium`, `session_id=0`;
- `presentation_session_id` rattaché au hub: `target=session`, `session_id=presentation_session_id`;
- absence de présentation dédiée: fallback runtime `active_session_id`, puis fallback programme non destructif;
- focus invalide/non rattaché: repli sûr vers le hub ou le premier candidat programme valide.

Le resolver ne consulte ni runtime, ni mapping, ni URL navigateur. Ces données interviennent ensuite seulement dans `app_games_hub_session_is_auto_joinable(...)` et la résolution d'accès joueur.

Rectification du 2026-07-13: une présentation `target=session` issue d'un focus Hub actif est le commit autoritatif de lancement pour une session numérique non terminée. `app_games_hub_session_is_auto_joinable(...)` ne demande donc plus `runtime_status=running`: Bingo reste légitimement `pending` jusqu'au démarrage de sa première phase. L'accès joueur assure d'abord la participation avec `player_register`; la grille Bingo n'est ni lue ni assignée par le resolver Hub et reste hydratée après navigation par le boot Player.

## Etat 2026-07-09 - Games hubs focus actif

Le socle hub porte maintenant la session active de soirée indépendamment du runtime des jeux.

Comportement:
- `games_hubs.active_session_id` et `active_session_activated_at` stockent le focus hub courant;
- `app_games_hub_sessions_get(...)` expose `hub_focus_status` (`upcoming`, `active`, `previous`) et `hub_is_focus_active`;
- `app_games_hub_focus_set_active(...)` remplace le focus lors d'un lancement/relancement depuis le Hub Master, sans modifier les etats runtime reels des autres sessions;
- `app_games_hub_get_active_launched_session_for_player(...)` et l'auto-join ne ciblent que la session focus active;
- le programme Hub Play affiche une session non-focus encore runtime `running` comme `Suspendue`, sans CTA joueur de reprise.

Invariants:
- aucune ancienne session n'est forcee en `terminated` pour simuler la progression du hub;
- un mapping `left` sur une ancienne session ne bloque pas l'auto-join vers la session focus suivante;
- les routes historiques `/play/{game}/{token}` restent disponibles hors flow Hub Play.

## Etat 2026-07-07 - Games hubs Lot 1

Le socle global expose le conteneur technique `games_hubs` pour la future supra-interface soiree/evenement.

Comportement:
- la table `games_hubs` porte un token stable `id_securite`, un `id_client`, une `hub_date`, un `context_type` (`event`, `soiree`, `day`), un rattachement optionnel `id_operation_evenement`, un libelle, un flag actif et un statut libre;
- `app_games_hub_get_or_create_for_context(...)` recupere ou cree le hub sans creer de page WWW ni d'objet SEO;
- contrat actuel: `app_games_hub_sessions_get(...)` lit d'abord les relations actives `games_hubs_sessions`; les anciennes heuristiques `id_operation_evenement` ou `id_client + hub_date` ne sont plus des autorités de lecture et ne servent qu'à un backfill strictement non ambigu quand aucun rattachement canonique n'existe encore;
- `app_games_hub_branding_get(...)` reutilise `app_general_branding_get_detail(...)`: avec evenement, la resolution passe par le branding type 2; sans evenement, elle retombe reseau/client;
- depuis le Lot 2, les routes `games` `/hub/{hub_token}/master` et `/hub/{hub_token}/play` consomment ces helpers en lecture seule;
- aucun joueur hub, scoring, lot, option, inscription session ou runtime WS n'est modifie par ce lot.

Fichiers de reference:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/global_librairies.php`;
- `documentation/games_hubs_phpmyadmin.sql`;
- `documentation/canon/data/schema/DDL.sql`.

## Etat 2026-07-06 - Blind Test equipes runtime persistées

Le socle resultats et le moteur `Mes joueurs` savent lire les equipes Blind Test depuis `blindtest_session_teams` quand la table existe.

Comportement:
- les resultats detail session Blind Test fusionnent les equipes persistées avec les joueurs solo;
- les membres presents dans `members_json` sont exclus du classement joueur pour eviter le double comptage;
- quand des equipes runtime existent, le podium est reconstruit depuis le classement mixte equipes + solos plutot que depuis `podium_json`;
- dans ce contexte, `players_count` represente les entites classees affichées; les vrais joueurs restent disponibles dans les donnees runtime `games`;
- le moteur `Mes joueurs` expose pour Blind Test un classement mixte `participants*` en plus des champs historiques `players*` / `teams*`;
- les agregats communauté/saison utilisent l'identite equipe stable `team:{team_name_normalized}`;
- le libelle public des equipes est le nom brut; le nombre de membres reste dans `team_member_count` / `members`;
- depuis le 2026-07-07, une ligne equipe n'est retenue que si le compteur runtime fiable indique au moins 2 membres; une equipe restée seule est traitée comme joueur solo quand le pseudo membre est disponible;
- les anciennes sessions gardent le fallback `podium_json`, puis le comportement joueur historique si aucune equipe n'est disponible.

Invariants:
- aucune equipe n'est lue depuis `blindtest_players` ou `equipes`;
- les joueurs solo d'une session mixte restent dans le leaderboard joueurs;
- Quiz et Bingo ne changent pas.

## Etat 2026-07-03 - Blind Test equipes runtime dans les agregats Pro

Le moteur commun des classements organisateur sait maintenant exploiter les equipes runtime Blind Test quand elles sont presentes dans le podium persiste.

Comportement:
- `app_client_joueurs_dashboard_context_compute(...)` lit `blindtest_sessions.podium_json` pour les sessions Blind Test;
- si le podium contient des entrees equipe runtime (`isTeam`, `teamId` ou `teamName`), ces entrees alimentent le leaderboard `teams` du Blind Test;
- les libelles equipes historiques au format `Nom equipe (nombre de joueurs)` sont maintenant normalises a l'affichage quand la ligne est identifiee comme equipe;
- les lignes individuelles `blindtest_players` de ces sessions sont ignorees dans l'agregat pour eviter d'attribuer le resultat a un seul coequipier.

Invariants:
- les sessions Blind Test sans equipe runtime restent traitees comme avant en leaderboard joueurs;
- les regles de points, rangs, ex aequo et podiums agreges restent inchangées.

## Etat 2026-07-03 - Play classements: scope filtre et jeux utiles

Le moteur organisateur `Mes joueurs` accepte maintenant des options facultatives pour les usages `play`.

Comportement:
- sans option, `app_client_joueurs_dashboard_get_context(...)` conserve son comportement historique;
- avec `force_filter_scope`, l'appel calcule uniquement la periode filtree demandee;
- avec `game_keys`, `app_client_joueurs_dashboard_context_compute(...)` limite les sessions et leaderboards aux jeux utiles (`quiz`, `blindtest`, `bingo`);
- `play` utilise ces options apres avoir determine les jeux reellement joues par le joueur/equipe chez l'organisateur sur la periode candidate.

Invariants:
- les regles de score, tri, ex aequo, podiums, Top 10 et classement complet ne changent pas;
- aucun cache persistant n'est ajoute.

## Etat 2026-07-03 - Play home: synthese historique legere

Le socle joueur expose une synthese legere de l'historique reel pour les KPI home `play`.

Comportement:
- `app_joueur_participations_reelles_summary_rows_get(...)` lit les memes sources que l'historique reel, mais seulement les colonnes necessaires aux totaux et top;
- les lignes restent dedoublonnees par session et filtrees par `app_joueur_historique_session_is_eligible(...)`;
- `app_joueur_participations_reelles_latest_date_get(...)` et `app_joueur_participations_reelles_get_stats(...)` reutilisent cette synthese pour eviter le chargement detaille de l'historique complet.

Invariants:
- les regles d'eligibilite historique restent inchangées;
- les pages d'historique detaillees continuent d'utiliser le helper complet quand elles ont besoin des badges et metadonnees de session.

## Etat 2026-07-03 - Play classements: instrumentation optionnelle

Le contexte joueur des classements peut maintenant emettre des jalons de performance vers `play` quand le helper EP est charge.

Comportement:
- `app_joueur_leaderboards_get_context(...)` marque les etapes lignes organisateurs, identite joueur, regroupement, appels moteur organisateur et sections finales;
- le jalon `leaderboards context - fenetre activite` isole le cout amont de derniere activite avant le vrai retour cache session;
- les appels identiques au moteur organisateur sur le meme client/annee/trimestre sont caches au scope request;
- sans helper `ep_perf_debug_global_mark(...)`, le comportement reste celui du socle global habituel.

Invariants:
- aucune modification de `app_client_joueurs_dashboard_get_context(...)`;
- periodes, ex aequo, podiums, Top 10 / classement complet et visibilite des jeux restent inchanges.

## Etat 2026-07-02 - Contacts multi-comptes: controle appartenance

Les helpers contacts clients exposent un controle explicite d'appartenance contact/client pour les parcours EC multi-comptes.

Comportement:
- `client_contact_client_is_attached(...)` retourne si un contact est rattache a un client;
- `client_contact_direct_access_consume(...)` accepte un `id_client_context` optionnel;
- si ce contexte est fourni, le token n'ouvre ce client que si la liaison existe;
- sans contexte client, le fallback historique reste le premier client lie.

Fichier de reference:
- `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`.

## Etat 2026-07-02 - Quiz: libelle serie unique thematique

Les helpers globaux de metadonnees Cotton Quiz affichent maintenant le nom de la thematique quand une session ne contient qu'une seule serie.

Comportement:
- `app_cotton_quiz_get_series_meta(...)` et `app_cotton_quiz_get_session_series_meta(...)` partagent le meme resolver de libelle;
- une seule serie avec nom disponible renvoie ce nom en `series_label`;
- une seule serie sans nom conserve le repli historique `1 serie`;
- deux series ou plus conservent le libelle compact `N series`.

Consommateurs attendus:
- affichages session PRO/WWW/PLAY bases sur `quiz_series_label`;
- `games` conserve son affichage existant, deja base sur le nom de thematique pour les quiz a une seule serie.

## Etat 2026-07-02 - Logs client: garde contexte BO/admin

Le helper global `log_ajouter(...)` filtre maintenant les ecritures vers `clients_logs` quand la session applicative porte un contexte admin EC.

Comportement:
- cible limitee a la table `clients_logs`;
- detection par `$_SESSION['CQ_admin']=1` ou `$_SESSION['CQ_admin_context']` non vide;
- les autres tables de logs et les sessions client normales conservent leur comportement;
- aucun champ SQL ni filtre `online` n'est ajoute.

Premier consommateur:
- PRO EC pose `CQ_admin_context='bo_client_gate'` lors d'un acces BO vers un compte client.

## Etat 2026-06-30 - Lots Quiz numeriques `N`: filtre source active

La constitution automatique des lots Quiz numeriques `N` utilise uniquement des questions source actives et hors lot.

Regle de selection:
- `questions.statut_numerique='certified'`;
- `questions.id_etat=2`;
- `questions.id_lot=0`;
- fenetre `date_fin_validite` compatible avec la date de session.

Le resolver de lecture d'un lot `N` deja constitue reste volontairement base sur `questions_lots_num_temp.question_ids`, sans ajouter de filtre `id_etat` ou `id_lot`, afin de ne pas casser les lots existants.

## Etat 2026-06-26 - Formats courts Blind Test/Bingo

Le socle global reconnait le format court `id_format=5` pour les jeux musicaux sans migration DB.

Comportement:
- `app_session_format_*` centralise les IDs standard/court pour Blind Test, Bingo V2 et Bingo V3;
- Bingo Musical `id_jeu_bingo_musical_format=5` genere une playlist client de 20 titres avec grille 3x3;
- les anciens formats Bingo `3` et `4` restent les presets 15 titres historiques et ne sont pas reutilises comme comportement produit court;
- les grilles clients du format court sont generees depuis les numeros aleatoires deja affectes aux morceaux de la playlist client;
- les supports BDD HTML/PDF de grilles savent rendre le format 5 avec la mise en page 3x3.
- le PDF papier format 5 utilise le fond 3x3 et positionne volontairement le QR sur la zone lots (`A gagner`, ligne, double ligne, bingo);
- les libelles partages de format renvoient `20 titres` ou `40 titres` pour les affichages PRO;
- `app_session_playlist_tracks_get(...)` resout les titres reellement utilises par une session musicale: Bingo lit la playlist client stockee, Blind Test court applique la selection stable `sha256(id_session|id_morceau)` puis 20 titres.

Fichiers de reference:
- helpers session: `global/web/app/modules/jeux/sessions/app_sessions_functions.php`;
- formats/generation Bingo: `global/web/app/modules/jeux/bingo_musical/app_bingo_musical_functions.php`;
- grilles papier/digital: `global/web/app/modules/jeux/bingo_musical/app_bingo_musical_grids_bdd_pdf.php`, `global/web/app/modules/jeux/bingo_musical/app_bingo_musical_grids_bdd_html.php`.

## Etat 2026-06-25 - Evenements pivot: assurance sans session

Le helper global `app_evenement_pivot_ensure_for_day(...)` accepte maintenant une option explicite `allow_empty`.

Comportement:
- par defaut, le helper conserve le comportement historique et refuse une date sans session avec `skip_reason='no_sessions'`;
- avec `allow_empty=true`, il peut creer ou retrouver le pivot evenement gamification d'une date valide sans rattacher de session;
- les rattachements de sessions restent inchanges: une liste vide produit un attachement no-op, puis les sessions ajoutees plus tard peuvent etre rattachees au meme pivot.

Fichier de reference:
- `global/web/app/modules/operations/evenements/app_evenements_functions.php`.

## Etat 2026-06-25 - Questions numeriques: modele cible sans `questions_numeriques`

Audit de reorientation:
- le schema canon confirme que `questions` porte deja les attributs metier partages: categorie, supports, niveaux, commentaire, `jour_associe`, `jour_associe_v1`, validite et lot catalogue;
- `questions_propositions` reste la table commune des mauvaises propositions rattachees a la question source; les distracteurs n'ont pas de variante papier/numerique;
- `questions_lots_temp` reste le lot temporaire papier `T`, avec `question_ids` pointant vers `questions`;
- `questions_lots_num_temp` reste le bon conteneur de lot numerique `N`, avec `question_ids` pointant vers `questions`;
- les dumps/schema locaux audites ne contiennent pas de table ni donnees `questions_numeriques`; l'acces DB serveur reel doit etre fait avec identifiants.

Decision:
- `questions_numeriques` n'est plus retenue comme table legacy durable;
- si une base serveur contient quelques lignes residuelles, les exporter avant abandon, sans les reintegrer au modele cible;
- le modele cible ajoute les variantes nullable `questions.question_numerique`, `questions.reponse_numerique`, `questions.commentaire_numerique` et `questions.statut_numerique`;
- les lots `N` generes par `qz_create_num_temp_lot(...)` stockent des IDs `questions` avec `question_source='questions'`.

Comportement:
- les builders numeriques selectionnent maintenant `questions.statut_numerique='certified'`, `question_numerique` et `reponse_numerique`;
- la validation numerique verifie que les propositions communes existent dans `questions_propositions`, sans ajout de typage ou duplication;
- `qz_num_lot_questions_get_liste(...)` lit les `N` depuis `questions`, sans fallback `questions_numeriques`;
- `app_session_quiz_digital_guard_get(...)` reutilise ce resolver pour controler une playlist `L/T/N` sans casser les lots existants.

Migration:
- la migration candidate reste additive et idempotente;
- elle ajoute les champs numeriques nullable a `questions`;
- elle cree `questions_lots_num_temp` sans creer `questions_numeriques`;
- elle ajoute/normalise `questions_lots_num_temp.question_source` en `ENUM('questions')`;
- elle bloque si des lignes `questions_lots_num_temp` portent une source non cible, pour forcer un export/nettoyage manuel;
- elle ne modifie pas `questions_propositions`.

## Etat 2026-06-24 - Questions numeriques: commentaire et dates source

La migration candidate `questions_numeriques` conserve maintenant les metadonnees source necessaires au BO d'adaptation numerique.

Champs portes:
- `commentaire`: commentaire metier de `questions.commentaire`, distinct de `commentaire_interne`;
- `jour_associe`: format historique DB `MM-DD`, utilise par les selections histoire/evenements autour de la date de session;
- `jour_associe_v1`: valeur brute `char/varchar(5)` conservee pour compatibilite historique/import, sans conversion ni interpretation applicative nouvelle.

Outillage:
- `qz_questions_numeriques_candidates_audit.php` exporte maintenant `commentaire`, `jour_associe` et `jour_associe_v1` en CSV et dans le SQL preparatoire;
- la migration candidate ajoute `jour_associe_v1` et `commentaire` en nullable pour preserver les questions numeriques existantes;
- aucun import automatique ni normalisation de ces champs n'est branche.

## Etat 2026-06-24 - Quiz V2: helpers auto lots numeriques `N`

Les lots `N` reprennent la logique editoriale des lots temporaires papier `T` sans ajouter de typage persistant en base.

Correspondance papier -> numerique:
- `qz_build_temp_history(...)` -> `qz_build_num_temp_history(...)`: serie `Cette semaine dans l'histoire`, basee sur `jour_associe` proche de la date de session;
- `qz_build_temp_arts(...)` -> `qz_build_num_temp_arts(...)`: serie `Mix culture G - Arts & Littérature`, univers `2`;
- `qz_build_temp_sciences(...)` -> `qz_build_num_temp_sciences(...)`: serie `Mix culture G - Sciences, Sports & Énigmes`, univers `3`, `4`, puis `5` avec rubrique enigmes `15`;
- `qz_build_numeric_auto_pack_lot_ids_csv(...)` prepare la sortie future `N{id_history},N{id_arts},N{id_science}` puis l'ajout eventuel d'un `L{id}` catalogue, comme le papier.
- `qz_build_numeric_auto_pack_result(...)` retourne aussi les `N` reussis et les series echouees, afin que le quick PRO remplace uniquement les familles numeriques sans contenu suffisant.

Regles:
- aucun champ `type_serie` n'est ajoute a `questions_lots_num_temp`; la classification reste implicite par le helper appele et par `nom` / `descriptif_court`, comme pour `T`;
- les helpers `N` selectionnent exclusivement dans `questions_numeriques`;
- la generation automatique exige `statut_validation='certified'`, une question et une reponse non vides, au moins une mauvaise proposition distincte, et le respect des dates de validite;
- les exclusions recentes reutilisent le contexte papier quand il existe, et ajoutent les questions deja presentes dans des lots `N` recents du meme client;
- le quick numerique PRO peut consommer le resultat detaille: les `N` crees sont conserves, les series echouees sont listees dans `failed`, et le fallback thematique reste gere cote `pro`.

Affichage:
- `app_cotton_quiz_get_session_series_meta(...)` lit deja les noms des lots `N` via `qz_num_lot_get_detail(...)`, comme il le fait pour `T`; les cartes/session Pro afficheront donc les libelles des trois series sans colonne de type supplementaire.

## Etat 2026-06-24 - Quiz V2: socle lots numeriques `N`

Le socle Quiz V2 documente maintenant trois familles de tokens dans `championnats_sessions.lot_ids`.

Convention:
- `L{id}`: lot catalogue historique, questions dans `questions`, propositions dans `questions_propositions`;
- `T{id}`: lot temporaire papier, ordre dans `questions_lots_temp.question_ids`, questions relues dans `questions`;
- `N{id}`: lot temporaire numerique, ordre dans `questions_lots_num_temp.question_ids`, questions relues dans `questions_numeriques`.

Comportement:
- `qz_lot_tokens_parse(...)` et `qz_lot_tokens_csv_normalize(...)` reconnaissent `N` sans modifier la convention chiffre nu -> `L`;
- `questions_numeriques` porte une reponse et des propositions fausses inline (`proposition_1..3`) afin de garantir la compatibilite numerique;
- le statut de validation des questions numeriques est borne a `draft`, `reviewed`, `certified`, `rejected`, aligne avec le BO manuel `www`;
- `qz_numeric_question_digital_validation(...)` centralise le controle minimal: reponse non vide et au moins une proposition fausse distincte;
- `app_session_quiz_digital_guard_get(...)` sait controler les playlists mixtes `L/T/N`;
- des helpers auto `N` non branches preparent la meme structure editoriale que les lots papier `T`, sans creer automatiquement de lots en production;
- une migration candidate et un script d'audit dry-run sont fournis sous `global/web/app/modules/jeux/cotton_quiz/tools/`, sans execution automatique ni import massif.
- le script d'audit CLI utilise maintenant `questions.id_lot=0` comme source candidate principale; `questions_lots_temp` ne sert plus qu'a enrichir les lignes auditees avec une indication secondaire de lots `T`.
- l'audit CLI est borne par `--limit` et `--offset`, avec filtres serveur `--status` et `--search`, afin de ne pas charger tout l'historique en memoire.

Outillage serveur DB:
- appliquer la migration candidate manuellement, apres revue:
  `mysql --default-character-set=utf8mb4 -h HOST -u USER -p DB_NAME < /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/tools/2026-06-24_questions_numeriques_lots_num_temp.sql`;
- verifier les tables creees:
  `mysql -h HOST -u USER -p DB_NAME -e "SHOW TABLES LIKE 'questions\\_numeriques'; SHOW TABLES LIKE 'questions\\_lots\\_num\\_temp';"`;
- lancer l'audit sans ecriture:
  `php /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/tools/qz_questions_numeriques_candidates_audit.php --dsn='mysql:host=HOST;dbname=DB_NAME;charset=utf8mb4' --user=USER --pass='PASSWORD' --dry-run --limit=100 --offset=0 --status=all`;
- auditer une tranche filtree:
  `php /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/tools/qz_questions_numeriques_candidates_audit.php --dsn='mysql:host=HOST;dbname=DB_NAME;charset=utf8mb4' --user=USER --pass='PASSWORD' --limit=100 --offset=0 --status=ready --search='cinema'`;
- produire un CSV preparatoire:
  `php /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/tools/qz_questions_numeriques_candidates_audit.php --dsn='mysql:host=HOST;dbname=DB_NAME;charset=utf8mb4' --user=USER --pass='PASSWORD' --export-csv=/tmp/qz_num_candidates.csv`;
- produire un SQL preparatoire, a relire avant toute execution manuelle:
  `php /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/tools/qz_questions_numeriques_candidates_audit.php --dsn='mysql:host=HOST;dbname=DB_NAME;charset=utf8mb4' --user=USER --pass='PASSWORD' --export-sql=/tmp/qz_num_candidates_ready.sql`.

Hors perimetre de cette passe:
- branchement quick numerique PRO, generation papier `T`, imports massifs, front, scoring, WS et options de difficulte.

## Etat 2026-06-22 - Evenements pivot: isolation par date cible

Le helper global d'assurance des pivots gamification isole maintenant strictement chaque page evenement par date.

Comportement:
- `app_evenement_pivot_detail_matches_day(...)` valide qu'un evenement correspond au client courant, au slug pivot cible `cotton-event-{id_client}-{YYYYMMDD}` et aux dates `date_debut/date_fin` de la date cible;
- `app_evenement_pivot_ensure_for_day(...)` ne reutilise plus un `id_operation_evenement` deja present sur les sessions si l'evenement ne correspond pas a la date cible;
- si cet ID appartient a un ancien pivot automatique, les sessions de la date cible sont detachees puis rattachees au pivot propre de cette date;
- un evenement trouve par slug cible mais dont les dates sont incoherentes est refuse au lieu d'etre reutilise;
- les champs publics personnalises d'un evenement existant ne sont jamais propages vers un nouveau pivot;
- le deplacement volontaire d'un groupe complet reste porte par `app_evenement_pivot_managed_event_move_date(...)`.

Fichier de reference:
- `global/web/app/modules/operations/evenements/app_evenements_functions.php`.

## Etat 2026-06-22 - Evenements pivot: deplacement date groupe

Les helpers `operations/evenements` savent maintenant deplacer la date d'un evenement pivot automatique quand tout le groupe de sessions change de date cote PRO.

Comportement:
- `app_evenement_pivot_managed_event_move_date(...)` accepte uniquement les evenements pivots manages reconnus par `app_evenement_pivot_detail_is_managed(...)`;
- le helper met a jour `operations_evenements.date_debut`, `date_fin` et `seo_slug` vers le slug pivot de la nouvelle date;
- le dossier upload `operations/evenements_branding/{ancien_slug}` est deplace vers `{nouveau_slug}` afin que le visuel personnalise reste disponible apres changement effectif de date;
- `operations_evenements.date_maj` est rafraichie pour invalider les URLs de visuels versionnees;
- si le slug cible existe deja pour un autre evenement, le helper refuse le deplacement afin d'eviter d'ecraser une page evenement existante;
- les vrais evenements/operations historiques ne sont pas modifies par ce helper;
- consommateur connu: action PRO de deplacement d'une soiree/evenement complet depuis l'agenda ou le pivot date.

Fichier de reference:
- `global/web/app/modules/operations/evenements/app_evenements_functions.php`.

## Etat 2026-06-19 - Evenements: organisateur public personnalisable

Les helpers `operations/evenements` exposent et sauvegardent un nom d'organisateur public propre a l'evenement.

Comportement:
- colonne `operations_evenements.naming_nom` assuree idempotemment si elle manque;
- `app_evenement_get_detail(...)` et `app_evenement_get_detail_by_seo_slug(...)` remontent `naming_nom`;
- `app_evenement_pivot_update_infos(...)` sauvegarde `naming_nom` avec les autres champs publics de la page evenement;
- le champ sert aux couches PRO/WWW de fallback marque blanche sans modifier le nom du compte.

Fichier de reference:
- `global/web/app/modules/operations/evenements/app_evenements_functions.php`.

# Etat 2026-06-19 - Branding événement: upload permissif et sortie JPG

Le helper de branding événement accepte des sources image plus permissives tout en conservant les artefacts publics historiques.

Comportement:
- `app_evenement_branding_visuel_uploader(...)` peut recevoir un visuel `JPG`, `PNG` ou `WebP`;
- l'image est redimensionnée/recadrée au format événement `1200 × 480 px`;
- le fichier final public reste `place-bandeau-1.jpg`;
- la copie pour la grille Bingo reste `bingo-musical-grid-html-bandeau-1.jpg`;
- les anciennes variantes nommées `.png` / `.webp` sont nettoyées pour éviter les artefacts concurrents;
- le recadrage image commun supporte WebP en plus de JPEG/PNG/GIF.

Fichiers de reference:
- `global/web/app/modules/operations/evenements_branding/app_evenements_branding_functions.php`;
- `global/web/lib/core/lib_core_upload_functions.php`.

# Etat 2026-06-18 - Evenements pivot gamification managés

Les helpers `operations/evenements` exposent maintenant un contrôle explicite des événements pivot automatiques utilisés par le pivot PRO gamification.

Comportement:
- `app_evenement_pivot_detail_is_managed(...)` reconnaît uniquement les événements dont le slug suit `cotton-event-{id_client}-{YYYYMMDD}` avec suffixe d'unicité éventuel et dont les dates correspondent à ce jour;
- les vrais événements/opérations historiques ne sont pas considérés comme des pivots managés;
- `app_evenement_pivot_session_reassign_after_date_change(...)` détache une session de son ancien pivot automatique quand sa date change;
- si la nouvelle date est future/courante, le helper réutilise `app_evenement_pivot_ensure_for_day(...)` pour assurer puis rattacher la session au pivot de la nouvelle date;
- si la nouvelle date n'est pas éligible, la session reste détachée de l'ancien pivot;
- ce helper est consommé par le tunnel PRO lors de la modification d'une session liée à une date pivot.

Fichier de reference:
- `global/web/app/modules/operations/evenements/app_evenements_functions.php`.

# Etat 2026-06-15 - Communaute: contexte classements sur periode explicite

L'agregateur `Ma communaute` peut maintenant etre appele sur une periode explicite sans dupliquer sa logique de classement.

Comportement:
- `app_client_joueurs_dashboard_get_context_for_period($id_client, $date_start, $date_end, $period_label = '')` expose un contexte joueurs/classements pour une plage de dates fournie;
- la fonction reutilise `app_client_joueurs_dashboard_context_compute(...)` avec un override de periode;
- les criteres existants restent conserves: client courant, sessions officielles completes non-demo, sessions terminees/exploitables, participants connectes fiables, podiums et classements par jeu;
- une session passee avec participants reels est consideree exploitable pour eviter d'exclure des resultats visibles quand le flag runtime termine n'est pas remonte;
- pour Bingo, si un meme joueur gagne plusieurs phases dans une session, les points des phases sont cumules et la participation deja comptee n'est retiree qu'une seule fois du bonus agrege;
- aucun nouveau calcul divergent ni nouvelle table SQL n'est introduit;
- premier consommateur connu: le bilan agrege de la page PRO `/extranet/start/games/day/YYYY-MM-DD`.

Fichier de reference:
- `global/web/app/modules/entites/clients/app_clients_functions.php`.

# Etat 2026-06-10 - Signal session officielle visible

Le helper `app_client_has_visible_official_session_signal($id_client, $require_useful_archive = 0)` centralise le signal utilise par la navigation PRO pour savoir si un compte a une vraie surface session a afficher.

Statut 2026-06-18: l'etat documente ci-dessous est l'etat final restaure apres rollback de la tentative de bornage du signal global. Aucun nouveau bornage global n'est conserve dans `global`; le correctif de performance restant est local au feedback recent cote `pro`.

Comportement:
- une session officielle complete non demo et non archivee qualifie le signal standard;
- une session archivee qualifie seulement si elle est utile pour l'historique via `app_client_joueurs_dashboard_session_is_history_useful(...)`;
- une archive utile est une session papier demarree ou une session numerique demarree avec vrais participants/resultats exploitables;
- une session papier non demo ou une session numerique avec vrais participants peut qualifier l'historique meme si son runtime n'est pas explicitement termine, a condition que `app_session_edit_state_get(...)` la considere demarree;
- les sessions demo, incompletes et archives numeriques sans joueurs ne qualifient pas;
- avec `$require_useful_archive = 1`, seules les archives utiles qualifient.

Fichier de reference:
- `global/web/app/modules/entites/clients/app_clients_functions.php`.

# Etat 2026-06-09 - Widget affiliation reseau ABN

Le widget d'affiliation reseau Home utilise le meme seuil d'affichage pour les comptes `ABN` avec ou sans sessions programmees.

Comportement:
- un `ABN` affiche le widget si le reseau apporte au moins un signal de banniere: jeux partages, habillage reseau ou stats significatives;
- un `ABN` sans ce signal sort avec `abn_no_banner_value`;
- la sortie `abn_no_actionable_value` n'est plus utilisee;
- les `ABN` affilies affichables sortent en `abn_network_context` / `context_banner`, avec ou sans sessions programmees;
- l'ancien mode `abn_network_onboarding` est supprime pour eviter le remplacement par le widget `first_party` sur la Home.

Fichier de reference:
- `global/web/app/modules/entites/clients/app_clients_functions.php`.

# Etat 2026-06-02 - Abonnement reseau: ensure sans double support

Correctif fonctionnel cote `global`:
- `app_ecommerce_reseau_offre_dediee_ensure_for_client(...)` relit maintenant le contrat reseau existant avant sa recherche par catalogue;
- si le contrat pointe deja vers une offre support valide et non archivee, cette ligne est reutilisee comme support courant;
- la creation automatique d'une nouvelle ligne support reste reservee au cas ou aucune offre support exploitable n'existe.

Effet attendu:
- un backfill/ensure reseau ne doit plus fabriquer une deuxieme ligne `Abonnement réseau` quand une offre support est deja rattachee au contrat;
- les recherches historiques par offre catalogue canonique ou legacy restent les fallbacks.

# Etat 2026-05-22 - BO module aside: hook de rendu cellule

Le helper global `module_aside_get_html(...)` applique maintenant, quand elle existe, la fonction optionnelle `bo_{module}_list_cell_html_get($field_name, $row_module, $default_html)` sur les cellules non-ID des blocs externalises.

Effet attendu:
- les blocs BO externalises peuvent reutiliser le meme rendu de cellule que les listings master sans dupliquer la logique;
- le comportement par defaut reste inchange si aucun helper module n'est charge;
- premier consommateur: les blocs `clients_logs` des fiches client/contact affichent les actions avec les memes libelles lisibles que `Tracking > Logs clients`.

# Etat 2026-05-22 - Stripe: journal resiliations et feedback annulation

Le module ecommerce global journalise les resiliations Stripe dans `user_feedback_events`, avec ou sans raison/commentaire client.

## Update 2026-05-22 - Stripe: journal resiliations sans feedback
- `app_ecommerce_stripe_subscription_cancellation_feedback_capture(...)` sert maintenant aussi de journal des resiliations Stripe sans raison/commentaire;
- une ligne sans feedback/commentaire est acceptee seulement si la subscription Stripe porte un signal de resiliation (`canceled_at`, `ended_at`, `cancel_at` ou `cancel_at_period_end`);
- `user_feedback_events.created_at` represente la demande de resiliation quand `subscription.canceled_at` est disponible;
- sans raison Stripe, la ligne affiche `Résiliation demandée`;
- le backfill Stripe priorise aussi `canceled_at`, scanne les subscriptions actives/trialing avec resiliation planifiee, et peut rafraichir les lignes deja presentes quand `update_existing` est active.

Comportement:
- `app_ecommerce_stripe_subscription_cancellation_feedback_capture(...)` lit `cancellation_details.feedback`, `comment` et `reason` depuis une souscription Stripe;
- les resiliations sont stockees dans `user_feedback_events` avec le contexte `stripe_subscription_cancellation`;
- le dedoublonnage se fait par subscription Stripe pour eviter une double insertion entre `customer.subscription.updated` et `customer.subscription.deleted`;
- `user_feedback_events.created_at` priorise `subscription.canceled_at`, puis la date fournie par l'appelant, puis `NOW()`;
- la date effective de resiliation Stripe est conservee dans `tags_json.cancellation_effective_at`, avec priorite `ended_at`, puis `cancel_at`, puis `current_period_end` si resiliation fin de periode, puis `canceled_at`;
- si la table `user_feedback_events` manque, le webhook reste non bloquant.

Backfill ponctuel:
- `global/web/assets/stripe/sdk/tools/backfill_cancellation_feedback.php` permet de recuperer les feedbacks historiques;
- par defaut, le script est en `dry-run`;
- la passe `Events API` couvre les evenements Stripe encore listables (`customer.subscription.updated` / `customer.subscription.deleted`, retention Stripe generalement limitee aux 30 derniers jours);
- la passe `Subscriptions API` tente aussi les souscriptions annulees au-dela de cette fenetre, en relisant l'objet subscription courant et son `cancellation_details`;
- l'insertion reste stricte: une souscription Stripe doit correspondre a une offre locale via `ecommerce_offres_to_clients.asset_stripe_productId`.

# Etat 2026-05-18 - Demos LP reseau: URL de retour

Correctif fonctionnel cote `global`:
- `app_session_demo_context_return_url_get()` reconstruit une URL de retour publique depuis le contexte LP poste (`lp_demo_context`, `lp_network_slug`);
- seuls les contextes `reseau` et `operation` sont acceptes;
- le slug reseau reste contraint a `[a-z0-9-]+`.

Effet attendu:
- les scripts publics `www` peuvent ajouter un `return_url` stable vers `/lp/reseau/{slug}` ou `/lp/operation/{slug}` au lien organizer `/master/{token}`;
- aucune URL arbitraire postee par le navigateur n'est reprise comme destination.

# Etat 2026-05-18 - Assets LP reseau: hero sans recadrage force

Correctif fonctionnel cote `global`:
- `app_client_lp_asset_uploader(...)` conserve le comportement logo historique, mais traite maintenant le `hero` LP reseau comme un visuel marketing souple;
- le `hero` LP est redimensionne en largeur maximale `1600px` sans hauteur imposee;
- `upload_image_recadrer()` reste inchange pour les flux qui ont besoin d'un emplacement strict, notamment les interfaces de jeu.

Effet attendu:
- les visuels principaux LP reseau gardent leur ratio source apres upload;
- une image horizontale recommandee en `1600 x 900 px` ne subit plus de coupe serveur pour rentrer dans `1200 x 480`;
- la protection de rendu est portee par la LP publique, pas par le core upload.

# Etat 2026-05-14 - BO contrats reseau: terminaison hors cadre ciblee

Correctif fonctionnel cote `global`:
- `app_ecommerce_reseau_activation_activate_from_bo_detail(...)` expose le retour structure de l'activation reseau au BO sans casser le wrapper historique qui retourne seulement `id_activation`;
- une attribution hors cadre peut donc etre consideree reussie quand une offre deleguee est creee, meme si aucune activation cadre n'est ecrite;
- `app_ecommerce_reseau_offre_hors_cadre_terminate_from_bo(...)` termine une delegation hors cadre ciblee par `id_offre_client`.

Garde-fous:
- l'offre doit etre active, appartenir au siege, cibler l'affilie et appartenir au catalogue hors cadre autorise;
- l'affilie doit encore etre rattache au siege;
- une offre liee a un support reseau, une activation courante `cadre`, une offre propre ou une autre offre de l'affilie est refusee;
- la terminaison ne detache pas l'affilie du reseau.

# Etat 2026-05-13 - Helper Home onboarding premiere animation ABN

Correctif fonctionnel cote `global`:
- `app_client_network_home_widget_get($id_client)` centralise l'eligibilite et le contenu reseau Home EC affilie;
- `app_client_home_onboarding_widget_get($id_client)` normalise le payload onboarding consomme par la Home EC;
- le helper exclut les comptes TdR eux-memes et les pipelines hors cible;
- les signaux V1 retenus sont: offre deleguee reseau active, jeux reseau partages, design reseau valide, et stats LP reseau significatives;
- les stats reutilisent `app_client_network_lp_stats_get(...)` avec les memes seuils LP;
- le widget complet est retourne pour tout `ABN` sans session officielle deja programmee, pas seulement aucune session a venir;
- les sessions demo sont exclues du calcul via `flag_session_demo=0 AND flag_configuration_complete=1`;
- si des jeux reseau sont partages, ils suffisent a produire la variante contextualisee et le CTA reseau, meme sans offre TdR active;
- sans contexte exploitable, le helper retourne la variante generique Cotton avec logo Cotton et CTA vers `extranet/games/library?from=agenda&mode=library`, afin de choisir directement une thematique;
- ce widget complet expose un wording neutre premiere animation, sans chips ni CTA secondaire, et fournit un CTA principal unique;
- `ABN` deja actif retourne seulement un bandeau contexte si jeux reseau, design reseau ou stats significatives existent;
- `INS` / `CSO` retournent le meme bandeau contexte si jeux reseau, design reseau ou stats significatives existent;
- aucun bandeau n'est retourne sur simple rattachement `id_client_reseau` ou sur une offre/support sans ligne ressource/stat affichable.

Sortie helper:
- `show`, `pipeline`, `network_name`, `network_logo`, `advantages`, `stats`, `variant`, `display_mode`, `details`, `primary_cta`, `secondary_cta`, `priority`, `placement`;
- les routes sont composees depuis les points d'entree PRO existants: programmation et catalogue jeux reseau en contexte agenda.

Limites V1:
- operation reseau active: non trouve dans la documentation et non cablee faute de source runtime canonique locale sure.

# Etat 2026-05-13 - Stripe webhooks: emails supprimes en livemode=false

Correctif fonctionnel cote `global`:
- `app_ecommerce_commande_ajouter(...)` accepte une option email interne permettant aux webhooks Stripe de supprimer les emails metier sans interrompre la creation de commande/facture;
- cette option est exclusivement pilotee par `pro/web/ec/ec_webhook_stripe_handler.php` apres lecture de `event.livemode`;
- les emails concernes cote commande sont l'alerte admin commande Brevo et le transactionnel AI Studio `INVOICE_MONTHLY`.

Invariants:
- aucune deduction via champs Cotton (`flag_test`, `mode_test`, etc.);
- aucun changement de montants, lignes, factures, paiements, etats ou synchronisations;
- chaque email ignore logge `[Stripe Webhook][Email Suppressed] livemode=false`.

# Etat 2026-05-12 - Stats preuve sociale LP reseau

Correctif fonctionnel cote `global`:
- `app_client_network_lp_stats_get($id_client_reseau)` expose les indicateurs LP reseau affichables;
- les affilies sont comptes depuis `clients.id_client_reseau`;
- les sessions sont comptees depuis `championnats_sessions` joint a `clients`, hors demos et avec configuration complete;
- les joueurs sont lus uniquement depuis l'agregat `reporting_games_players_monthly` si disponible.

Effet attendu:
- `www` peut afficher un bloc de preuve sociale sur `/lp/reseau/{slug}` uniquement lorsque les seuils commerciaux sont atteints;
- aucun recalcul runtime joueur n'est fait cote LP publique;
- en absence d'agregat joueurs, le compteur joueurs est simplement ignore.

Seuils commerciaux V1:
- etablissements affilies inscrits: indicateur affichable a partir de `3`, signal fort a partir de `20`;
- sessions de jeu programmees: indicateur affichable a partir de `5`, signal fort a partir de `50`;
- joueurs deja accueillis: indicateur affichable a partir de `100`, signal fort a partir de `1000`.

Regle d'affichage LP:
- afficher le bloc si au moins `2` indicateurs passent leur seuil affichable;
- afficher aussi le bloc si `1` seul indicateur passe son seuil de signal fort;
- limiter le rendu public a `3` indicateurs maximum, dans l'ordre affilies, sessions, joueurs;
- ne jamais afficher un compteur a `0`, un indicateur absent, ni un bloc generique vide.

# Etat 2026-05-12 - Couleurs LP reseau dediees au compte TdR

Correctif fonctionnel cote `global`:
- `app_client_lp_colors_*` ajoute deux parametres optionnels sur `clients`: `lp_reseau_couleur_principale` et `lp_reseau_couleur_secondaire`;
- les valeurs sont normalisees au format strict `#RRGGBB`; une valeur vide ou invalide est ignoree proprement;
- ces couleurs sont dediees a la LP reseau et ne modifient pas le design reseau complet;
- `app_client_signup_network_theme_get(...)` compose le theme signup/signin affilie en priorisant logo/visuel LP TdR puis branding signup reseau historique; il n'expose pas les couleurs LP au formulaire PRO.

Effet attendu:
- `www` peut prioriser les couleurs LP du compte TdR avant les couleurs du design reseau;
- `pro` peut appliquer le logo et le visuel LP sur `signup` / `signin` des qu'une affiliation reseau est resolue;
- en absence de couleurs LP valides, les fallbacks design reseau puis Cotton restent inchanges.

# Etat 2026-05-11 - Parametrage LP sur abonnement reseau

Correctif fonctionnel cote `global`:
- `app_ecommerce_reseau_support_lp_settings_*` cree, lit et sauvegarde une table dediee `ecommerce_reseau_support_lp_settings` rattachee a `ecommerce_offres_to_clients.id`;
- les champs couverts sont: activation de personnalisation, titre public, accroche, description courte, CTA actif, CTA inactif et slug public optionnel;
- `app_ecommerce_reseau_support_offer_active_latest_get(...)` expose l'abonnement reseau actif le plus recent pour une TdR (`date_debut DESC`, puis `id DESC`).

Effet attendu:
- `www` peut enrichir la LP reseau depuis l'abonnement support actif sans dupliquer l'affiliation ni l'activation d'offre incluse;
- une TdR sans abonnement actif conserve une LP d'affiliation reseau sobre, sans promesse d'acces inclus.

# Etat 2026-05-11 - Demos LP reseau portees par la TdR

Correctif fonctionnel cote `global`:
- les scripts demo publics peuvent maintenant resoudre cote serveur le compte TdR associe a une LP reseau/operation via son slug public;
- le contexte accepte est limite a `reseau` ou `operation`, et le compte resolu doit etre un client `flag_client_reseau_siege=1`;
- en cas de contexte absent, invalide ou non resolu, les demos standards restent portees par le compte demo historique `1557`;
- `app_session_demo_ajouter(...)` garde les attributs demo prives/non officiels existants et ne cree aucune offre, commande ou droit BO/pro.

Effet attendu:
- une demo lancee depuis une LP reseau/operation valide herite du compte TdR porteur, quel que soit le contenu affiche par la LP;
- le design reseau reste applique par la resolution branding existante, avec fallback design courant si aucun design reseau n'existe;
- les demos lancees hors LP reseau/operation conservent leur comportement historique.

# Repo `global`

## Update 2026-09-03 - Contrat commercial des délégations hors cadre

Une offre client déléguée hors cadre porte son état commercial courant dans la même ligne : `prix_reference_ht` est l’assiette HT avant remise, `prix_ht` le net HT courant et `remise_*` la remise effectivement appliquée. Le catalogue n’est qu’un fallback legacy signalé lorsque l’assiette manque. Les lectures et refreshs ne modifient jamais Stripe; seul le moteur contractuel déclenché en écriture par `invoice.upcoming` peut remplacer le Price, sans prorata. Un échec Stripe 429, transport/timeout ou 5xx est marqué retryable afin que la redelivery reprenne idempotemment le write; un blocage métier reste non retryable.

## Update 2026-05-11 - Abonnement reseau / echeance date_fin
- `app_ecommerce_reseau_support_offers_expired_process(...)` cloture les supports reseau actifs dont `date_fin < CURDATE()` et reutilise `app_ecommerce_reseau_support_offer_transition_finalize(...)`;
- `app_ecommerce_reseau_support_offer_included_date_fin_sync(...)` propage la date de fin du support aux offres incluses actives liees par `reseau_id_offre_client_support_source`;
- la creation d'une offre deleguee incluse reprend la `date_fin` du support source si elle existe;
- les offres propres, hors cadre et deja terminees restent hors perimetre de cette synchronisation.

## Etat 2026-05-06 — Stripe ABN: le pipeline client suit la cloture effective

Correctif fonctionnel cote `global`:
- `app_ecommerce_stripe_subscription_terminal_sync(...)` continue de porter la transition terminale Stripe vers Cotton: l'offre liee a la subscription passe en `ecommerce_offres_to_clients.id_etat=4`;
- apres cette transition, les offres directes hors support reseau recalculent maintenant le pipeline du client via `app_ecommerce_client_pipeline_sync_from_effective_offer(...)`;
- la source de verite du recalcul est l'acces effectif relu par `app_ecommerce_offre_effective_get_context(...)`, donc le client ne repasse pas `CSO` s'il conserve une autre offre active;
- si l'offre effective restante est un abonnement, le pipeline reste ou redevient `ABN`; si c'est un pack, il devient `PAK`; sans acces effectif et hors `INS`, il repasse `CSO`.

Invariants:
- `cancel_at_period_end` ne declenche pas ce recalcul tant que Stripe n'envoie pas une souscription effectivement terminee;
- les offres deleguees et supports reseau restent traitees par les synchronisations reseau existantes;
- aucun secret Stripe ni donnee sensible n'est journalise.

## Etat 2026-05-05 — Branding Canvas: saves partiels merge-safe

Correctif fonctionnel cote `global`:
- l'endpoint `general/branding?action=save` relit maintenant le branding existant avant d'appeler `app_general_branding_modifier(...)`;
- les champs couleurs et police absents du POST conservent leur valeur existante au lieu d'etre remplaces par une chaine vide;
- l'absence de `branding_logo` ou `branding_visuel` n'est plus interpretee comme une suppression;
- la suppression volontaire d'un media doit passer par `logo_clear=1` ou `visuel_clear=1`;
- la reponse de save renvoie le branding effectif apres sauvegarde pour permettre une rediffusion live complete cote `games`.

Effet attendu:
- une modification de couleur dans l'organizer ne supprime plus le logo ou le visuel personnalise visible cote player/remote;
- une modification de media ne remet plus les couleurs ou la police a blanc;
- les payloads complets historiques restent compatibles.

## Etat 2026-04-29 — Quiz V1: statut runtime volontairement simplifie

Correctif fonctionnel cote `global`:
- `app_session_edit_state_get(...)` ne simule plus un etat `running` pour les sessions `Cotton Quiz V1` (`id_type_produit=1`) a partir de la seule date;
- faute de runtime fiable sur cette version legacy, une session V1 non archivee par date reste traitee comme `pending`;
- une session V1 archivee par date devient `terminated`;
- les produits runtime modernes (`3/4/5/6`) conservent leur lecture de phase existante.

Effet attendu:
- la fiche detail PRO ne signale plus `Session en cours` pour une V1 simplement parce que la date du jour est atteinte;
- le statut visible V1 reste limite a un maintien legacy simple: en attente ou terminee selon la date.

## Etat 2026-04-27 — Cotton Quiz V2: exclusions papier et visuels par lots reels

Correctifs fonctionnels cote `global`:
- la generation automatique des lots temporaires papier ne regarde plus seulement les tables historiques `quizs`, `quizs_series` et `quizs_series_to_questions`;
- elle ajoute maintenant les sessions `Cotton Quiz V2` deja programmees via `championnats_sessions.lot_ids` et les questions des lots `T...` relues dans `questions_lots_temp.question_ids`;
- la fenetre d'exclusion est symetrique autour de la session cible: sessions passees et futures dans la fenetre courante, avec exclusion de la session en cours quand son id est connu;
- si le vivier devient insuffisant, le builder tente progressivement des fenetres plus courtes (`350`, `300`, `240`, `180`, `120`, `60` jours) et n'accepte une generation que si les trois familles attendues sont completes;
- la resolution des visuels `Cotton Quiz V2` peut maintenant partir des `lot_ids` reels d'une session:
  - seuls les tokens `L...` sont candidats au visuel;
  - si plusieurs lots `L...` sont presents, le dernier lot `L...` de la sequence est la source de verite visuelle;
  - les copies identiques du visuel par defaut sont ignorees;
  - les tokens `T...` restent hors selection visuelle;
  - le fallback reste `default_cotton_quiz.jpg` si aucun lot `L...` ne porte de visuel custom.
- addendum prod: pour un visuel `Quiz V2`, l'absence de `lot_ids` ne déclenche plus de fallback sur les series legacy; le socle renvoie le visuel par defaut pour eviter d'afficher un lot historique sans rapport.

Effet attendu:
- une question deja utilisee dans un lot temporaire V2 recent ou prochain ne retombe plus par defaut dans une nouvelle session papier;
- les cartes agenda et les vues qui passent les `lot_ids` n'heritent plus d'un visuel issu d'un ancien quiz legacy sans rapport.

## Etat 2026-04-17 — Leaderboards quiz legacy: le rang est rederive des scores de session

Correctif fonctionnel cote `global`:
- le dashboard partage `Mes joueurs` n'utilise plus `championnats_resultats.position` comme source de verite pour attribuer les points saison du `Cotton Quiz` legacy;
- pour le quiz legacy uniquement, le socle recalcule maintenant le rang de chaque session a partir de:
  - `equipe_session_points` DESC;
  - puis `equipe_quiz_points` DESC;
  - puis `label` ASC;
- le bareme saison existant reste inchange (`1er 500 / 2e 300 / 3e 200 / participation 100`), mais il est reapplique sur un rang rederive des scores et non plus sur une colonne `position` legacy devenue non fiable;
- effet attendu:
  - `pro`, `play` et `www` retrouvent des classements agreges quiz coherents avec les fiches session legacy;
  - aucun changement n'est apporte ici aux jeux runtime modernes.

## Etat 2026-04-17 — Photos podium player: le socle partage trace maintenant un consentement par upload

Correctif fonctionnel cote `global`:
- le helper partage `app_session_results_podium_photo_upload(...)` continue de porter le write path podium commun utilise par `pro`, `games remote` et maintenant `games player`;
- il accepte en plus un bloc `consent` facultatif:
  - texte de consentement affiche;
  - version/contexte/source;
  - horodatage;
  - identites runtime et bridge du joueur.
- le stockage retenu est une preuve par upload dans `championnats_sessions_podium_photos_consents`, reliee au `media_image_id` cree;
- addendum 2026-04-17:
  - le socle snapshotte maintenant aussi `runtime_username` / `runtime_label` au moment de l'upload player;
  - l'objectif est de pouvoir retrouver rapidement la photo, la session et le joueur runtime visible lors d'une demande d'effacement, meme sans lien EP;
  - la meme table de consentement sert aussi aux uploads organisateur (`games_remote_organizer`);
  - la provenance de la photo visible est maintenant relue depuis cette trace pour distinguer une photo `player` d'une photo `organizer`.
- effet attendu:
  - chaque photo podium envoyee depuis le player peut etre justifiee par une preuve autonome;
  - on evite un faux positif de type "le compte a deja consenti une fois" alors que la photo de session est nouvelle;
  - si la preuve consentement ne peut pas etre ecrite, la photo n'est pas conservee.

## Etat 2026-04-17 — Libelles joueur: plus de nom de famille dans les classements partages

Correctif fonctionnel cote `global`:
- le helper partage de libelle joueur des dashboards / leaderboards ne retombe plus sur `prenom + nom`;
- la regle est maintenant:
  - `pseudo` si present;
  - sinon `prenom` seul;
  - sinon `Joueur`;
- effet attendu:
  - les podiums et classements agreges de `pro`, `play` et `www` affichent les joueurs avec le meme niveau de libelle court que les sessions;
  - les equipes ne sont pas impactees par ce changement.

## Etat 2026-04-17 — Resultats de session: ordre des ex aequo aligne sur `games`

Correctif fonctionnel cote `global`:
- pour les sessions runtime `Cotton Quiz` / `Blind Test`, le socle relit maintenant la cle joueur canonique `player_id` quand elle existe dans les tables runtime;
- cette cle est reutilisee comme cle d'ordre secondaire du classement complet quand plusieurs participants partagent le meme score, afin de coller a l'ordre stable deja applique par `games`;
- la normalisation des podiums de session preserve maintenant aussi l'ordre source entre ex aequo, au lieu de re-trier localement par libelle;
- effet attendu:
  - `pro`, `play` et `www` peuvent afficher le meme ordre d'ex aequo qu'une interface `games` pour une session donnee;
  - les vues qui reconstruisent seulement l'affichage ne doivent plus inventer un autre ordre entre lignes de meme rang.

## Etat 2026-04-16 — Sessions demo: `app_session_edit_state_get(...)` suit de nouveau le runtime reel

Correctif fonctionnel cote `global`:
- `app_session_edit_state_get(...)` ne court-circuite plus les demos avant le calcul de statut;
- une session demo reutilise maintenant le meme calcul de statut que les autres sessions selon son type de jeu et son runtime;
- effet attendu cote `pro`: la fiche detail peut afficher correctement `En attente`, `En cours` ou `Session terminee` pour une demo, puis revenir a `En attente` apres une relance qui remet vraiment le runtime a zero;
- aucun changement n'est apporte ici au bypass de relance cote `games`.

## Etat 2026-04-16 — QR code place: initialisation temp robuste sans `chmod()`

Correctif fonctionnel cote `global`:
- le generateur partage `AppQrCodePlaceGenerator` tentait encore un `chmod()` sur son sous-repertoire temporaire `/tmp/tmp_qr_codes`;
- sur certains serveurs `dev`, ce changement de permissions est interdit meme quand `/tmp` reste exploitable, ce qui faisait fuiter un warning PHP jusque dans le parcours `www -> fiche session -> Je participe`;
- l'initialisation choisit maintenant `tmp_qr_codes` si le dossier est effectivement disponible et writable, sinon retombe simplement sur `sys_get_temp_dir()` sans essayer de modifier les droits;
- effet attendu: plus de warning `chmod(): Operation not permitted`, sans changer le contrat de generation des PNG/PDF QR.

## Etat 2026-04-15 — `Mes joueurs`: sessions dashboard rendues compatibles avec `app_session_edit_state_get`

Correctif fonctionnel cote `global`:
- le dashboard `Mes joueurs` relisait des sessions via des `SELECT` partiels ne chargeant pas `flag_session_demo`;
- ces lignes etaient ensuite passees a `app_session_edit_state_get(...)`, qui lisait encore cet index sans garde et spamait la reponse PHP de notices sur `GET /extranet/players?async=1`;
- les requetes source du dashboard injectent maintenant explicitement `flag_session_demo`;
- le helper global de statut session retombe aussi proprement sur `0` si ce champ est absent d'un detail partiel;
- effet attendu: plus de notices `Undefined index: flag_session_demo` sur le chargement async de `Mes joueurs`, avec un contrat de donnees plus robuste entre le dashboard client et le socle sessions.

## Etat 2026-04-15 — `Mes joueurs`: une playlist Bingo manquante ne casse plus le chargement async

Correctif fonctionnel cote `global`:
- certaines sessions `Bingo Musical` historiques pointent encore vers un `id_produit` dont la playlist client n'est plus resoluble;
- le helper `app_jeu_get_detail()` dereferencait pourtant cette playlist et son catalogue sans garde sur le chemin `type 3/6`, ce qui pouvait provoquer un fatal pendant `GET /extranet/players?async=1`;
- le helper verifie maintenant d'abord la presence de la playlist client puis relit le catalogue / format Bingo de facon defensive;
- effet attendu: la session concernee degrade son detail jeu sans faire tomber tout `Mes joueurs`.

## Etat 2026-04-13 — Fiche session: message de classement Bingo legacy aligne sur le fallback historique

Correctif fonctionnel cote `global`:
- la fiche detail de session utilisait uniquement le flag runtime `is_terminated` pour afficher le message de classement manquant;
- pour certaines sessions Bingo legacy `2/3` considerees historiques via fallback date, cela affichait encore a tort `Cette session n'a pas été jouée jusqu'au bout`;
- le helper de message aligne maintenant la fiche session sur la meme logique fallback `2/3`;
- effet attendu: ces sessions affichent desormais un message d'absence de classement exploitable, et non plus un faux message de session interrompue.

## Etat 2026-04-13 — Fiche session Bingo: labels joueurs reconciliés avec les liaisons EP

Correctif fonctionnel cote `global`:
- la fiche detail de session `Bingo Musical` relisait jusqu'ici directement `bingo_players.username` et `bingo_phase_winners -> bingo_players.username`;
- quand le runtime ne portait pas de `username`, le podium tombait en `Joueur inconnu` et la liste pouvait masquer l'identite pourtant connue cote `games_connectees` ou `grids_clients`;
- le helper de resultats de session recolle maintenant les labels Bingo via les liaisons joueur consommees (`championnats_sessions_participations_games_connectees`) puis le fallback legacy `jeux_bingo_musical_grids_clients`;
- priorite d'affichage: `pseudo`, sinon `prenom nom`, avec reappariement par `game_player_id`, `game_player_key` puis libelle normalise.
- addendum: le switch de `app_session_results_get_context(...)` traite maintenant aussi `id_type_produit = 2` comme `Bingo Musical`, pour rester coherent avec `Mes joueurs`, `Historique` et les autres mappings Bingo du socle.
- addendum: la liste basse Bingo fusionne maintenant les joueurs runtime et les participants legacy prouves, tandis que l'absence de podium exploitable remonte une mention dediee `Les données de cette session ne permettent pas d'afficher le podium.`

## Etat 2026-04-13 — `Mes joueurs`: le Bingo legacy type `2` est reintegre, avec fallback date sur `2/3`

Correctif fonctionnel cote `global`:
- le type produit `2` correspond au Bingo legacy et etait encore exclu du moteur `Mes joueurs`;
- le moteur rattache maintenant `id_type_produit = 2` a `Bingo Musical` dans ses sources et son mapping jeu;
- la terminaison historique Bingo applique maintenant un fallback par date passee pour les types `2/3`, y compris en numerique;
- le type `6` reste volontairement exclu de ce fallback et doit etre reellement termine runtime.

## Etat 2026-04-13 — `Mes joueurs` / `Archives`: le fallback Bingo papier est borne au type `3`

Correctif fonctionnel cote `global`:
- le fallback legacy par date pour les Bingos papier etait encore trop large;
- il s'appliquait aux types `3` et `6`, ce qui pouvait laisser remonter des sessions papier recentes de type `6` simplement parce que leur date etait passee;
- le fallback papier est maintenant reserve au seul Bingo legacy `id_type_produit = 3`;
- effet attendu: un Bingo papier type `6` n'entre plus dans `Archives` ni dans les agregats `Mes joueurs` sans vraie fin runtime.

## Etat 2026-04-13 — `Mes joueurs`: les periodes de classement revoient les Quiz V1 legacy

Correctif fonctionnel cote `global`:
- la synthese `Mes joueurs` comptait correctement les vieilles sessions `Cotton Quiz V1`, mais le selecteur de periodes pouvait les ignorer;
- cause confirmee: le helper `app_client_joueurs_dashboard_period_has_leaderboard_data()` n'injectait pas la colonne `date` dans sa requete source, alors que le helper de terminaison legacy en a besoin pour reconnaitre un `id_type_produit = 1` comme session terminee;
- la requete du helper de periodes charge maintenant `date` et `flag_controle_numerique`, comme le moteur principal du dashboard;
- effet attendu: les annees / saisons contenant uniquement du `Quiz V1` legacy peuvent de nouveau apparaitre dans le selecteur de classements.

## Etat 2026-04-13 — `Mes joueurs`: rollback de l'hypothese `id_type_produit = 2` cote Quiz

Correctif fonctionnel cote `global`:
- verification faite dans le socle sessions: `id_type_produit = 2` correspond au Bingo legacy, pas a `Cotton Quiz`;
- l'extension precedente du moteur `Mes joueurs` vers `id_type_produit = 2` pour Quiz a donc ete retiree;
- le cache `Mes joueurs` est invalide pour eviter de conserver des contextes reconstruits sur cette mauvaise hypothese;
- l'investigation de la borne historique des classements doit donc se poursuivre sur une autre source de donnees, pas sur ce mapping de type produit.

## Etat 2026-04-13 — Historique EC / `Mes joueurs`: Bingo privilégie la vraie fin runtime avec fallback legacy

Correctif fonctionnel cote `global`:
- `Bingo Musical` n'est plus considere termine dans les moteurs historiques uniquement parce que sa date est passee;
- `app_client_joueurs_dashboard_session_is_reliably_terminated()` relit maintenant d'abord le statut runtime bingo via `app_session_edit_state_get()`;
- les sessions Bingo papier gardent un fallback legacy par date, ce qui couvre les vieux historiques dont `phase_courante` n'a jamais ete alimentee;
- les sessions Bingo numeriques ne retombent sur la date que si le runtime n'est plus exploitable;
- effet attendu: `Mes joueurs` et l'onglet `Archives` EC privilégient une vraie fin runtime sans faire disparaitre les vieux Bingos papier legitimes.

## Etat 2026-04-13 — Direct access EC: le token survit aux pre-ouvertures de scanners QR

Correctif fonctionnel cote `global`:
- le mecanisme `client_contact_direct_access` ne vide plus son token au premier hit;
- objectif: eviter qu'un scanner QR mobile ou une previsualisation d'URL consomme le lien avant la vraie ouverture navigateur;
- le lien temporaire reste donc exploitable pendant sa duree de validite normale.

## Etat 2026-04-13 — Upload podium mobile: lecture robuste du fichier et correction orientation JPEG

Correctif fonctionnel cote `global`:
- le write path des photos podium ne suppose plus que le bon fichier se trouve en position `0` du tableau `files_img`;
- il isole maintenant le premier vrai fichier présent, ce qui securise les formulaires mobiles et les payloads multi-inputs;
- le pipeline upload image applique en plus une normalisation EXIF sur les JPEG avant resize/crop;
- objectif: eviter a la fois les faux echecs d'upload mobile et les photos importees de bibliotheque affichees a l'envers.

## Etat 2026-04-11 — Photos podium session: resolution prioritaire par gagnant, fallback par rang

Correctif fonctionnel cote `global`:
- le helper de resultats de session ne limite plus la lecture d'une photo podium a la seule place `#1/#2/#3`;
- chaque ligne de podium recoit maintenant une cle stable de gagnant (`photo_row_key`) derivee du rang et de l'identite de la ligne quand elle existe;
- la lecture des photos tente d'abord un media dedie a cette ligne de podium, puis conserve le fallback historique par rang pour les uploads deja en place;
- le write path d'upload accepte lui aussi cette cle cible, ce qui permet a deux gagnants ex aequo au meme rang de porter des photos differentes sans migration de schema.

## Etat 2026-04-10 — Détection `dev` élargie dans `global_config`

Correctif fonctionnel cote `global`:
- `global/web/global_config.php` et `global/web/global_config.template.php` ne réservent plus le mode `dev` au seul host `global.dev.cotton-quiz.com`;
- tout host `*.dev.cotton-quiz.com` est désormais reconnu comme `dev`;
- objectif: garantir que les flows Stripe déclenchés depuis `pro.dev` puis bootstrapés via `global_config.php` continuent d'utiliser les clés et URLs `dev`, sans basculer par erreur en `prod`.

## Etat 2026-04-10 — SDK Stripe: bootstrap autonome du runtime config

Correctif fonctionnel cote `global`:
- `global/web/assets/stripe/sdk/stripe_sdk_functions.php` ne depend plus strictement d'un bootstrap amont pour disposer de `$conf`;
- si le SDK est appelé dans un contexte historique incomplet, il tente désormais de charger:
  - `global_config.php`
  - puis `global_config.local.php`
- le bootstrap ne se contente plus d'un `$conf` non vide; il vérifie maintenant la présence effective des buckets Stripe runtime avant de considérer la configuration comme disponible;
- objectif: permettre l'usage des clés Stripe déclarées hors git dans le runtime, même lorsque le point d'entrée n'a pas initialisé la config globale avant d'inclure le SDK.

## Etat 2026-04-10 — Secrets Stripe: lecture via `global_config` sans fallback hardcodé

Correctif fonctionnel cote `global`:
- les helpers Stripe ne prennent plus uniquement leurs secrets depuis le code versionné;
- ils lisent désormais en priorité les valeurs runtime de `global_config.php` via:
  - `stripe_public_api_key`
  - `stripe_private_api_key`
  - `stripe_webhook_secret`
- les anciennes valeurs hardcodées ont été retirées après validation runtime en `dev`;
- `global/web/global_config.template.php` documente maintenant explicitement ces trois blocs de configuration.

## Etat 2026-04-10 — Portail Stripe affilié TdR prod: mapping prod rétabli

Correctif fonctionnel cote `global`:
- le portail Stripe utilise maintenant en `prod`:
  - `bpc_1TKulJLP3aHcgkSEn8CdQlt1` pour `network` et `network_affiliate_cancel_end_of_period`
  - `bpc_1TKh9GLP3aHcgkSEMUKlR85t` pour `network_affiliate` et `network_affiliate_cancel_immediate`
- objectif: rétablir les ouvertures de portail Stripe des offres affiliées TdR sans dépendre d'une variable runtime absente, avec une séparation `prod` cohérente entre portail standard, portail `at_period_end` et portail `immediate`.

## Etat 2026-04-10 — Audit TdR délégué: la piste `Remises 2026` est écartée

Etat fonctionnel cote `global`:
- les TdR restent volontairement exclus du moteur `Remises 2026`;
- cette exclusion est cohérente avec le contrat métier actuel, les remises réseau TdR étant gérées séparément;
- aucune ouverture du scope `Remises 2026` n'est conservée dans le code.

## Etat 2026-04-09 — Photos podium session: URL versionnee apres remplacement

Correctif fonctionnel cote `global`:
- les photos podium dediees par session/rang gardent leur stockage existant, mais leur URL resolue porte maintenant un suffixe `?v=...`;
- la version vient de `date_maj`, sinon `date_ajout`, sinon `id` media;
- objectif: forcer le navigateur a recharger la nouvelle image quand une photo podium est remplacee sans changer le nom de fichier.

## Etat 2026-04-09 — Historique agenda: helper global de qualification metier

Correctif fonctionnel cote `global`:
- `global` expose maintenant un helper de qualification de session passee reutilisable par l'agenda EC;
- ce helper reprend le meme contrat que `Mes joueurs`:
  - session non demo et complete;
  - session reellement terminee selon le jeu;
  - conservation des sessions papier meme sans participants;
  - exclusion des sessions numeriques sans participation reelle fiable;
- les sources de participation reprises sont les memes que celles deja utilisees par `Mes joueurs`, avec priorite aux tables runtime modernes et fallbacks legacy bornees par jeu.

## Etat 2026-04-09 — Résultats de session EC: helper centralise de lecture et photos podium

Correctif fonctionnel cote `global`:
- `global` expose maintenant un helper de lecture des resultats finaux de session pour la fiche EC historique;
- ce helper centralise la consommation des sources deja persistées par les jeux:
  - `championnats_resultats` pour `Cotton Quiz` legacy;
  - `cotton_quiz_sessions` + `cotton_quiz_players`;
  - `blindtest_sessions` + `blindtest_players`;
  - `bingo_phase_winners` (+ labels `bingo_players`);
- pour `Cotton Quiz` runtime et `Blind Test`, le helper reapplique le meme contrat de rang competition que les WS games (`score desc`, tie-break stable par id, rangs `1,1,3...`);
- pour `Bingo Musical`, il n'invente pas de classement complet et expose:
  - le podium de phases reellement disponible;
  - puis la liste historisee des joueurs de session;
- le helper retourne aussi des messages metier explicites quand une session n'est pas terminee ou quand aucun joueur n'a ete retrouve.
- pour Bingo historique, la relecture des joueurs ne depend plus du seul filtre live `is_active=1`, afin d'eviter les faux negatifs sur session deja terminee.
- la compatibilite schema bingo est aussi durcie: la liste joueurs n'exige plus `updated_at` et retombe sur `created_at` puis `id` selon les colonnes reellement presentes.
- `global` expose aussi un stockage dedie de photos gagnants par session archivee et rang de podium pour `Cotton Quiz`, `Blind Test` et `Bingo Musical`.
- pour `Cotton Quiz` legacy, la lecture des photos conserve un fallback sur le stockage historique `championnats/resultats`, afin de rester compatible avec les anciens uploads vainqueur deja presents.
- le compteur `Particip.` de l'EC est maintenant aligne sur ce contrat: predictive avant session, puis lecture prioritaire des tables modernes `*_players` sur session passee, avec fallback legacy seulement pour les anciens `Bingo Musical` et `Cotton Quiz` sans runtime exploitable.
- `Cotton Quiz` garde un libelle `equipes` meme si le runtime moderne fournit la source.
- pour `Cotton Quiz` legacy sans runtime, le compteur post-session relit d'abord les lignes reelles de `championnats_resultats`, et la colonne de score de la fiche historique expose le score quiz de session au lieu des points agreges du classement saisonnier.

## Etat 2026-04-08 — Factures PDF: le logo partage vit maintenant dans `global`

Correctif fonctionnel cote `global`:
- un asset commun `global/web/assets/branding/pdf/cotton-facture-logo.jpg` sert maintenant de source unique pour le logo facture;
- les PDF BO et PRO ne dependent plus d'un fichier logo stocke dans `pro`;
- cela stabilise le rendu BO sur les environnements ou les permissions inter-vhost ne permettent pas de lire directement les assets `pro`.

## Etat 2026-04-08 — E-commerce: le TTC d'affichage part maintenant d'un montant canonique unique

Correctif fonctionnel cote `global`:
- `global` expose maintenant un resolver centralise d'affichage e-commerce base sur des montants canoniques en centimes;
- le TTC affiche n'est plus reconstruit depuis un HT deja arrondi quand une remise existe;
- si un montant facture/snapshotte existe deja, c'est lui qui doit rester la reference finale d'affichage;
- pour les previews avant paiement, le TTC est maintenant resolu depuis le tarif de reference exact et la remise, puis le HT affiche est laisse comme vue informative derivee;
- le snapshot commande copie maintenant ce meme contrat, ce qui supprime les micro-ecarts visibles entre Cotton et Stripe sur une meme commande.

## Etat 2026-04-08 — E-commerce: l'etat de remise d'une offre est maintenant borne a sa periode courante

Correctif fonctionnel cote `global`:
- `global` expose maintenant un helper qui determine si une remise snapshottee sur l'offre couvre encore la periode de facturation en cours;
- ce helper relit la duree metier de la regle, l'ancre de facturation et la periode courante de l'abonnement;
- les vues `pro` peuvent donc afficher une remise active sur l'offre sans la laisser visible apres expiration metier de cette remise.

## Etat 2026-04-08 — Checkout ABN: recap de remise explicite avant Stripe

Correctif fonctionnel cote `global`:
- `global` expose maintenant un helper de formulation du recap de remise pour le checkout ABN;
- ce recap ne depend plus du wording natif Stripe quand un `trial` est combine a un coupon;
- les cas couverts sont:
  - remise limitee standard
  - remise limitee apres essai gratuit
  - remise sans limite
  - annuel `< 12 mois` relu comme remise sur la premiere echeance annuelle.

## Etat 2026-04-08 — Remises 2026: duree parametree, moteur compose par client reel

Correctif fonctionnel cote `global`:
- la remise BO `Remises 2026` ne repose plus sur une duree fixe implicite `12 mois`;
- `global` normalise maintenant une duree d'application metier:
  - `12 mois` par defaut;
  - `1..N mois`;
  - `sans limite`;
- le moteur de resolution compose maintenant le scenario final avec:
  - la duree de la regle;
  - la frequence reelle de l'offre;
  - l'eligibilite effective au trial CHR cote client;
- arbitrage retenu:
  - mensuel + duree limitee => `schedule`
  - toute duree `sans limite` => `coupon`
  - annuel + duree limitee => chemin simple `coupon`, sans phasage intra-annuel;
- exception annuelle explicite:
  - si la duree est `< 12 mois`, l'effet metier est `remise sur la premiere facture annuelle uniquement`;
  - si la duree est `>= 12 mois`, le chemin reste simple et stable, sans schedule annuel;
- `global` prepare aussi la persistance d'audit `stripe_subscription_schedule_id` sur l'offre client pour les seuls cas schedules;
- le helper de creation de schedule part d'une subscription Stripe creee par Checkout via `from_subscription`, puis reconstruit les phases utiles pour les seuls cas mensuels limites.

## Etat 2026-04-07 — Remises BO V1 sur ABN standard: resolver unique + snapshot de ligne

Correctif fonctionnel cote `global`:
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php` expose maintenant un resolver unique de remises BO pour le checkout ABN standard;
- `global` expose aussi un helper de previsualisation du meme resolver pour les cartes `Tarifs & commande`, avant meme qu'une ligne `offre_client` existe;
- le helper Stripe de resolution des `Price` catalogue revalide maintenant le `lookup_key` trouve contre le tarif Cotton attendu:
  - meme `unit_amount`,
  - meme devise,
  - meme periodicite recurrente;
- si un ancien `Price` Stripe conserve la bonne `lookup_key` mais un montant obsolete, `global` recree maintenant un `Price` conforme et transfere la `lookup_key` dessus pour que le checkout reparte de la bonne base TTC;
- le guard runtime V1 ne se contente plus de `id_offre_type = 2`:
  - il borne explicitement le lot a `id_offre = 12`,
  - il borne explicitement le lot a l'ABN periodique `id_paiement_type = 2`,
  - afin de ne pas embarquer les anciens chemins ABN one-shot/commentes encore visibles dans le code historique;
- le moteur lit les regles generiques existantes et leur rattachement offre, puis ajoute un ciblage explicite comptes organisateurs via `ecommerce_remises_to_clients`;
- le scope V1 reste strict:
  - remise en pourcentage uniquement;
  - une seule remise gagnante;
  - non cumulable;
  - coupon Stripe borne par defaut a `12 mois` pour les nouvelles souscriptions V1;
  - fenetre de date de commande;
  - reseau explicitement exclu via les gardes runtime prouves;
- le snapshot commercial est maintenant porte par l'offre client puis recopie dans la ligne de commande avec:
  - `id_remise`
  - `prix_reference_ht`
  - `prix_ht` final
  - `remise_nom`
  - `remise_pourcentage`;
- la ligne de commande devient ainsi la verite de facturation sans recalcul webhook.

## Etat 2026-04-03 — `Mes joueurs`: sessions bingo historiques reintegrees dans la synthese

Correctif fonctionnel cote `global`:
- la synthese haute `Mes joueurs` ne depend plus, pour `Bingo Musical`, d'un etat de playlist client potentiellement reinitialise ou reutilise apres coup;
- une session bingo passee est maintenant consideree comme historique/terminee pour les compteurs de synthese organisateur;
- le cache journalier de synthese est aussi versionne pour forcer un recompute apres ce changement de logique;
- effet:
  - les sessions bingo historiques reapparaissent dans `Sessions organisees`, `Participants inscrits` et `Top jeu`;
  - la correction reste bornee a la synthese organisateur et ne modifie pas le live.

## Etat 2026-04-04 — Classements agrégés: le podium ne se cumule plus avec la participation

Correctif fonctionnel cote `global`:
- le score agrégé ne cumule plus `100` points de participation avec les gains de podium ou de phase;
- un rang `1 / 2 / 3` vaut maintenant `500 / 300 / 200` points au total sur `Cotton Quiz` / `Blind Test`;
- un gain `Bingo / Double ligne / Ligne` vaut maintenant `500 / 300 / 200` points au total sur `Bingo Musical`;
- une participation simple sans podium ni gain de phase reste seule a `100` points.

## Etat 2026-04-04 — Classements historiques: fallback runtime recollés aux identités DB

Correctif fonctionnel cote `global`:
- le moteur de leaderboard essaie maintenant de rattacher les anciennes identites runtime de secours (`runtime:quiz_team:*`, `runtime:blindtest:*`, `runtime:bingo:*`) a une identite DB canonique deja connue dans le contexte du client;
- la fusion repose sur un libelle normalise, mais reste volontairement prudente:
  - seulement si une seule identite non-runtime correspond;
  - aucune fusion si le meme libelle normalise pointe vers plusieurs identites DB differentes;
- effet:
  - les anciens doublons purement historiques de casse, accents ou ponctuation entre runtime et DB sont absorbes;
  - les vrais cas ambigus restent separes plutot que fusionnes de force.

## Etat 2026-04-04 — `Mes classements`: période joueur recadrée sur la vraie saison organisateur

Correctif fonctionnel cote `global`:
- `app_joueur_leaderboards_get_context(...)` ne considere plus qu'une participation joueur dans le trimestre courant suffit, a elle seule, a imposer ce trimestre a l'affichage;
- le helper demande maintenant explicitement au moteur organisateur `app_client_joueurs_dashboard_get_context(...)` si le trimestre candidat est bien accepte tel quel;
- si le moteur organisateur retombe sur un autre trimestre faute de donnees leaderboard exploitables, le candidat est rejete et le helper tente le trimestre precedent;
- effet: la saison affichee cote `play`, les tableaux et les compteurs de sessions restent alignes sur la vraie saison organiseur effectivement servie par le moteur `Mes joueurs`.

## Etat 2026-04-04 — Dashboard classements: session scope + liste complete

Correctif fonctionnel cote `global`:
- le moteur organisateur `app_client_joueurs_dashboard_get_context(...)` remonte maintenant, pour chaque leaderboard de jeu, deux compteurs distincts:
  - le nb de sessions effectivement retenues dans le calcul du classement;
  - le nb de sessions retrouvees sur la saison filtree pour ce jeu;
- ces compteurs servent a afficher un rappel explicite du scope du classement dans `Mes joueurs` et `Mes classements`;
- le helper expose aussi des listes completes triees (`players_full` / `teams_full`) en plus des listes tronquees `top 10`, afin que `pro` et `play` puissent derouler tout le classement sans recalcul front ou variation metier;
- cote joueur, `app_joueur_leaderboards_highlight_leaderboard_rows(...)` marque maintenant aussi la ligne courante dans ces listes completes, pas seulement dans le `top 10`.

## Etat 2026-04-03 — Signup pro: helper de resolution par `email + nom client`

Correctif fonctionnel cote `global`:
- `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php` expose maintenant `client_contact_client_find_by_email_and_client_name(...)`;
- ce helper relit `clients_contacts -> clients_contacts_to_clients -> clients` pour retrouver un compte existant quand:
  - l'email du contact correspond;
  - le nom du client correspond aussi;
- la comparaison est normalisee avec `trim + lower` sur les deux champs, puis reste stricte en egalite exacte;
- le helper renvoie `id_client` et `id_client_contact` pour permettre au signup `pro` de reutiliser un compte deja existant au lieu d'en recreer un.

## Etat 2026-04-02 — Historique joueur EP: sessions reellement terminees seulement

Correctif fonctionnel cote `global`:
- `app_joueur_participations_reelles_get_liste(...)` ne remonte plus toute participation reelle datee `<= aujourd'hui` indistinctement;
- l'historique joueur applique maintenant la meme notion de fin reelle que les classements, avec une nuance legacy explicite:
  - `Cotton Quiz` legacy `id_type_produit = 1`: session retenue si `date < aujourd'hui`;
  - jeux modernes (`Cotton Quiz` runtime, `Blind Test`, `Bingo Musical`): session retenue si `date <= aujourd'hui` et `app_session_edit_state_get(...).is_terminated = 1`.
- cette garde s'applique au helper de liste lui-meme, avant deduplication des sources `games_connectees / quiz_legacy / bingo_legacy`;
- `app_joueur_participations_reelles_latest_date_get(...)` est maintenant recale sur cette meme lecture effective de l'historique, afin que la fenetre glissante `12 derniers mois` ne s'ancre plus sur une session du jour ou non terminee qui serait de toute facon exclue de l'affichage.

## Etat 2026-04-02 — Classements saisonniers agreges: sessions runtime reellement terminees uniquement

Correctif fonctionnel cote `global`:
- le moteur organisateur `app_client_joueurs_dashboard_get_context(...)` ne retient plus, pour les classements saisonniers agreges utilises dans `pro` et `play`, que les sessions dont l'etat runtime DB est explicitement `termine`;
- la regle se base sur la meme lecture centralisee que le garde d'edition session:
  - `Bingo Musical`: `phase_courante >= 4`;
  - `Blind Test`: `game_status / phase_courante >= 3`;
  - `Cotton Quiz` moderne: `game_status / phase_courante >= 3`;
- exception legacy explicite:
  - `Cotton Quiz` legacy `id_type_produit = 1` est reintegre avec une regle historique simple `date < aujourd'hui`;
  - le jour courant reste donc exclu, meme si la session legacy a deja eu lieu plus tot dans la journee.
- cette lecture s'appuie sur les tables runtime mises a jour par les glue `games`, via `app_session_edit_state_get()`;
- effet de bord volontaire:
  - une session non demarree ou encore en cours n'alimente plus les tops / stats / classements agreges du dashboard organisateur;
  - `Cotton Quiz` legacy ne repose pas sur un statut runtime DB “termine”, mais sur cette borne date stricte pour rester compatible avec son historique.
- la detection des trimestres exploitables (`period_has_leaderboard_data`) applique la meme garde, ce qui evite de proposer un trimestre dont les donnees de classement ne sont pas encore juridiquement stabilisees.

## Etat 2026-04-02 — Helper joueur `app_joueur_leaderboards_get_context(...)`

Correctif fonctionnel cote `global`:
- `global` expose maintenant un helper joueur dedie pour alimenter une page EP `Mes classements`;
- ce helper ne recalcule pas un nouveau moteur de classement:
  - il part maintenant d'une liste legere d'organisateurs lies au joueur (`app_joueur_linked_clients_rows_get(...)`), bornee aux seules sources EP/bridge et legacy stables;
  - il isole les organisateurs deja lies au joueur sans relire le detail complet de l'historique;
  - il choisit, organisateur par organisateur, le trimestre courant si le joueur y a une participation reelle, sinon le trimestre precedent;
  - il reconsomme ensuite `app_client_joueurs_dashboard_get_context(...)` pour reutiliser les classements organisateur deja stabilises dans `Mes joueurs`.
- contrat fonctionnel:
- sections triees par frequence de participation du joueur;
- uniquement les organisateurs lies au joueur;
- uniquement les jeux effectivement joues par le joueur sur le trimestre retenu pour l'organisateur;
- durcissement 2026-04-13: un leaderboard jeu n'est plus conserve si le joueur ou son equipe n'y sont pas effectivement reperes dans les lignes consolidees; un simple lien historique a l'organisateur ne suffit donc plus;
- `Cotton Quiz` reste expose comme classement equipes, `Blind Test` et `Bingo Musical` comme classements joueurs;
  - pour `Cotton Quiz`, si une equipe est reliee a une session, tous les joueurs actuellement lies a cette equipe peuvent maintenant etre consideres comme participants cote historique joueur, y compris dans la branche moderne `championnats_sessions_participations_games_connectees`.
  - rollback 2026-04-02: l'historique reel joueur ne relit plus directement les sessions runtime `cotton_quiz_players` et `bingo_players`; il revient a un socle stable base sur les sources EP/bridge et legacy deja reliees au joueur.
  - `Mes classements` est maintenant decouple de l'historique detaille joueur: la page n'utilise plus `app_joueur_participations_reelles_get_liste(...)` pour selectionner ses organisateurs, mais une vue legere des liens joueur -> organisateurs sur la periode;
  - compromis 2026-04-02: la liste legere des organisateurs lies reste fondee sur les seules tables stables EP/bridge et legacy;
  - les classements affiches dans chaque section restent en revanche ceux du moteur organisateur `Mes joueurs`, qui conserve sa consolidation complete moderne / legacy / runtime.
  - update 2026-04-02: le moteur organisateur remonte maintenant aussi les compteurs podium par ligne de classement (`wins`, `second_places`, `third_places`) a partir des memes attributions de points canoniques, ce qui permet a `Mes classements` de recalculer le recap joueur/equipe directement depuis la ligne surlignee.
  - durcissement 2026-04-02: les classements agreges organisateur excluent maintenant les bridges `championnats_sessions_participations_games_connectees` non consommes (`date_consumed IS NOT NULL` requis) et les joueurs runtime inactifs (`is_active = 1`) sur `cotton_quiz_players`, `blindtest_players` et `bingo_players`, y compris pour les podiums bingo;
  - le helper `app_joueur_participations_reelles_get_liste(...)` accepte maintenant aussi un bornage optionnel `date_start / date_end`, `app_joueur_participations_reelles_latest_date_get(...)` expose la derniere date d'activite reelle, et `app_joueur_participations_reelles_activity_window_get(...)` centralise la fenetre glissante par defaut:
    - `Historique` charge les `12 derniers mois` d'activite reelle, avec extension par paliers de `12 mois`;
    - les KPI home et `Mes classements` relisent eux aussi par defaut les `12 derniers mois` ancres sur la derniere activite reelle du joueur/equipe, pour eviter les recalculs complets sur tout l'historique.

## Etat 2026-04-01 — Branding: reset `games` avec cascade conditionnelle sur le branding compte

Correctif fonctionnel cote `global`:
- l'endpoint `global_ajax.php?t=general&m=branding&action=delete_preview` permet maintenant a `games` de savoir si un branding compte sera effectivement supprime avec le reset session courant;
- l'endpoint `global_ajax.php?t=general&m=branding&action=delete` accepte maintenant le signal `cascade_client_branding_if_matching=1` pour le flux organizer `games`;
- en reset de session (`id_type_branding = 1`), `global` peut maintenant:
  - detecter un branding compte `type 4`;
  - verifier qu'il correspond bien au design effectif de la session:
    - soit parce que la session herite directement du branding compte;
    - soit parce que le branding session present a la meme signature visible (`couleurs`, `police`, `logo`, `visuel`) que le branding compte;
  - figer d'abord les sessions futures du meme client qui heritent encore de ce branding compte, via duplication en branding session;
  - supprimer ensuite le branding compte;
  - puis supprimer le branding session courant si present.
- perimetre du gel:
  - sessions du client `date >= CURDATE()`;
  - hors demo;
  - hors session courante;
  - uniquement quand leur branding effectif courant est exactement `branding_client`.

## Note d'evolution — Branding par type de jeu

Etat actuel:
- le branding `global` est resolu par portee seulement: `session > evenement > reseau > client`;
- la table `general_branding` ne porte pas de `type de jeu`.

Implication:
- un branding compte est aujourd'hui global a tous les jeux du client;
- un support `par type de jeu` applicable a toutes les portees (`session/evenement/reseau/client`) demande une evolution de schema et de resolution, pas seulement un patch front.

Reference de conception:
- `documentation/notes/branding_par_type_de_jeu.md`

## Etat 2026-03-31 — Helper metier `app_client_joueurs_dashboard_get_context(...)`

Correctif fonctionnel cote `global`:
- `global` expose maintenant un helper unique pour preparer le dashboard PRO `Mes joueurs`;
- `global` expose aussi `app_client_has_archived_sessions($id_client)` pour permettre a `pro` de reutiliser la meme notion de session archivee avant d'exposer ou non la nav `Mes joueurs`;
- le contrat retourne `Membre depuis`, `Aujourd'hui`, une synthese globale sur toute la periode d'activite, des tops calcules sur cette meme periode, puis une periode de filtre dediee aux seuls classements;
- les sessions comptabilisees s'alignent sur la meme regle que le reporting BO: `championnats_sessions.flag_session_demo=0` et `flag_configuration_complete=1`;
- dans la synthese, le comptage des sessions reste aligne sur le reporting BO:
  - une session papier non demo et complete est comptee meme sans participation remontee;
  - une session numerique doit en revanche avoir produit au moins une participation fiable (`joueur` ou `equipe`) pour etre comptabilisee;
  - les sessions demo restent toujours exclues;
- la metrique principale du dashboard signifie `participants connectes (joueurs & equipes)` en agrégeant les deux sources fiables;
- la consolidation des participations privilegie d'abord les rattachements EP reels (`championnats_sessions_participations_games_connectees`, `jeux_bingo_musical_grids_clients`), puis complete avec les tables runtime de jeu quand elles existent;
- quand une session dispose deja de joueurs runtime sur le jeu concerne, ce runtime devient la source de verite pour le nb de participations reelles; le bridge/EP ne sert alors plus qu'au rattachement d'identite, sans ouvrir de participation supplementaire;
- pour `Cotton Quiz`, les lignes `cotton_quiz_players` sont interpretees comme des equipes et non comme des joueurs;
- les participations probables ne sont jamais utilisees;
- le helper porte aussi les messages d'etat vide quand aucune donnee exploitable n'est disponible, globalement ou sur la periode filtree;
- la periode de filtre des classements est maintenant pilotee par une annee d'activite puis un trimestre civil, avec defaut sur le trimestre en cours s'il contient au moins une session qui alimente reellement un classement, sinon sur le dernier trimestre qui contient effectivement des donnees de classement, et options bornees par `Membre depuis`;
- la liste `annees + trimestres` est maintenant construite directement a partir des periodes qui alimentent reellement les classements; une selection utilisateur valide n'est plus ecrasee par la logique de defaut;
- cette detection de periodes exploitables relit maintenant les memes sources que les vrais leaderboards:
  - `Cotton Quiz`: `equipes_to_championnats_sessions`, runtime `cotton_quiz_players`, puis fallback legacy `championnats_resultats`;
  - `Blind Test`: bridge `championnats_sessions_participations_games_connectees` et runtime `blindtest_players`;
  - `Bingo Musical`: runtime `bingo_players`;
- techniquement, la synthese globale est maintenant mise en cache en session par client/jour, tandis que les classements sont recalcules sur le seul scope de la periode filtree;
- la deduplication reste conservative:
  - une identite EP prime toujours sur un doublon runtime de la meme session;
  - les fallbacks non EP utilisent un nom/pseudo normalise borne au jeu, sans fusion heuristique entre jeux.
## Etat 2026-03-31 — Helper `Mes joueurs`: meilleure session dans la synthese

Correctif fonctionnel cote `global`:
- `app_client_joueurs_dashboard_get_context(...)` expose maintenant, pour chaque jeu de la synthese, `Meilleure session`, soit le nb max de participants connectes observes sur une meme session;
- cette valeur s'appuie sur les participations deja dedupliquees par session, en restant bornee aux memes sources fiables que le reste du dashboard;
- la regle reste bornee aux memes donnees fiables que la synthese V1 (`sessions` BO non demo/completes, joueurs connectes et equipes runtime/EP selon les sources deja retenues).

## Etat 2026-03-31 — Helper `Mes joueurs`: classements tries par score agrege

Correctif fonctionnel cote `global`:
- les classements du dashboard `Mes joueurs` restent fondes sur les memes participants fiables, mais sont maintenant tries par un score agrege plutot que par le seul nb de participations;
- regle retenue:
  - `500 / 300 / 200` points au total pour les rangs `1 / 2 / 3` de session sur `Cotton Quiz` / `Blind Test`, calcules a partir des scores runtime persistés;
  - `500 / 300 / 200` points au total pour les gains de phase `Bingo / Double ligne / Ligne` sur `Bingo Musical`, via `bingo_phase_winners`, avec rattachement prioritaire par `player_id_key` quand il existe;
  - `100` points seulement pour une participation reelle sans podium ni gain de phase;
  - quand le bridge EP historique n'existe pas encore pour une session legacy, ces bonus se recollent aussi par pseudo runtime normalise, sur la meme logique conservative que les participations;
- quand une meme session legacy remonte a la fois une participation EP et une ligne runtime au meme pseudo, le fallback conserve maintenant la premiere identite connue de la session pour eviter que le bonus soit attribue a une ligne runtime doublon plutot qu'a la ligne leaderboard deja visible;
- cette meme priorite s'applique aussi desormais a l'ingestion des participations runtime legacy elles-memes, afin d'eviter la creation d'une seconde ligne de classement au meme pseudo quand une identite de session existe deja;
- pour `Cotton Quiz` historique pre-runtime, les bonus podium peuvent aussi etre relus via `championnats_resultats.position`, sans dependre des tables runtime actuelles;
- pour `Bingo Musical`, le classement conserve maintenant les sessions runtime scorables de la periode, et n'exclut que les sessions historiques sans gagnants de phase recuperables de facon fiable; une mention inline discrète n'est affichee que dans ce cas partiel, pas pour les sessions sans joueur runtime a exclure logiquement;
- les tops de synthese restent eux calcules uniquement sur les participations, sans melanger ce nouveau score de classement;
- le nb de participations reste expose dans les lignes de classement comme information annexe.
- les compteurs `victoires / 2e / 3e places` doivent etre derives des bonus nets reellement ajoutes au score (`400 / 200 / 100`) afin de rester coherents avec le total affiche.

## Etat 2026-04-04 — Helper joueur `Top classement` pour la home EP

Correctif fonctionnel cote `global`:
- ajout de `app_joueur_leaderboards_best_rank_get($id_joueur, $cache_ttl_seconds=300)`;
- ce helper est dédié au KPI home `Top classement` et ne doit pas construire tout le contexte détaillé de la page `Classement(s)`;
- il réutilise la même logique métier de sélection de période et de détection d'identité joueur / équipe, mais:
  - ne cherche que le meilleur rang;
  - s'arrête dès qu'un `#1` est trouvé;
  - met en cache le résultat en session sur une courte durée pour éviter de recalculer la même information à chaque retour home;
- le contexte complet `app_joueur_leaderboards_get_context(...)` met lui aussi en cache sa réponse en session sur une courte durée, et le helper `Top classement` peut s'appuyer sur ce cache s'il existe déjà.

## Etat 2026-04-10 — Portail Stripe TdR: résolution robuste des souscriptions affiliées déléguées

Correctif fonctionnel côté `global`:
- le portail Stripe d'une offre affiliée déléguée ne dépend plus uniquement du `asset_stripe_productId` stocké sur l'offre;
- si cet identifiant n'est pas un `sub_...` valide ou ne permet plus de relire la souscription, le SI tente maintenant de retrouver la souscription via les métadonnées Stripe:
  - `metadata['offre_client_id_securite']`
  - puis `metadata['offre_client_id']`;
- la meilleure souscription retrouvée est choisie par priorité d'état (`active`, `trialing`, etc.) puis par récence;
- le `subscription_id` retrouvé est réécrit dans `ecommerce_offres_to_clients.asset_stripe_productId` pour stabiliser les appels suivants;
- les flows portail deep-linkés (`subscription_cancel`, `subscription_update`) réessaient maintenant avec cette souscription résolue avant de conclure à `subscription_snapshot_unavailable`.
- le fallback est volontairement limité aux offres déléguées affiliées; les offres standard en propre conservent leur comportement `main`.
- en complément, les portails Stripe standards revalident maintenant le `customer` stocké avant création de session; un `asset_stripe_customerId` périmé n'empêche plus silencieusement l'affichage du CTA `Gérer mon abonnement`.

## Etat 2026-04-13 — Compatibilite liste sessions / helper archive

Correctif fonctionnel cote `global`:
- `app_sessions_get_liste(...)` expose maintenant aussi la cle canonique `id` en plus de `id_championnat_session`;
- cela permet de reutiliser directement les helpers archive/metier comme `app_client_joueurs_dashboard_session_is_history_useful(...)` sur cette liste, sans remapping local;
- effet visible: les consumers `www` qui filtrent les sessions passees avec ce helper ne vident plus la liste faute d'identifiant session compatible.

## Etat 2026-04-04 — Historique joueur: sessions terminées réalignées sur les classements

Correctif fonctionnel cote `global`:
- l'historique réel joueur n'utilise plus une simple règle `session passée par date`;
- `app_joueur_historique_session_is_eligible(...)` s'aligne maintenant sur la logique des classements via `app_client_joueurs_dashboard_session_is_reliably_terminated(...)`;
- conséquence:
  - une session doit être `non demo`;
  - `flag_configuration_complete = 1`;
  - et réellement terminée selon le même moteur que les leaderboards, pas seulement passée dans le calendrier.

## Etat 2026-04-15 — Helpers podium `play`

Correctif fonctionnel cote `global`:
- `app_session_results_photo_src_stabilize_for_play(...)` fournit désormais une URL photo podium stable pour les écrans `play`:
  - priorité au domaine public `www/upload` du serveur courant;
  - fallback final sur `www prod`;
  - si une URL `www prod` arrive déjà en entrée, le helper la remappe malgré tout vers `www` du serveur courant dès qu'il peut reconstruire le chemin relatif;
- `app_joueur_leaderboards_highlight_leaderboard_rows(...)` marque maintenant aussi `players_podium` et `teams_podium` avec `is_current`, en plus des lignes de classement classiques.

## Etat 2026-04-15 — Archive dashboard: mode `historique seul`

Correctif fonctionnel cote `global`:
- `app_client_joueurs_dashboard_archive_sessions_get(...)` accepte maintenant un indicateur explicite pour ne charger que les sessions passees utiles;
- le helper accepte aussi un `offset`, pour que les consumers puissent paginer l'historique sans recharger un second chemin metier;
- quand ce mode est actif, le helper n'appelle plus `app_sessions_get_liste(...)` sur les sessions a venir avant de filtrer l'historique;
- les consumers FO `place` s'en servent pour:
  - l'onglet `Sessions passees`;
  - la colonne `sessions recentes` des classements agreges.

## Etat 2026-04-16 — Descriptions lieu: normalisation commune

Le module `clients` expose maintenant des helpers communs de normalisation pour les descriptions lieu:
- version courte sur une seule ligne;
- version longue avec retours à la ligne conservés;
- nettoyage des anciens `<br>` et balises héritées avant affichage.

Le back-office `pro` stocke ainsi désormais un texte simple normalisé, puis `pro` et `www` réutilisent le même rendu.

## Etat 2026-04-16 — Dashboard joueurs: fallback classements sans saison exploitable

Correctif fonctionnel cote `global`:
- la finalisation du contexte `app_client_joueurs_dashboard_*` est maintenant centralisée;
- quand le contexte filtré ne remonte aucun classement exploitable mais que la synthèse historique existe via cache, le message fallback `classements` est désormais correctement réappliqué;
- cela couvre aussi le cas où la saison par défaut n'a aucune session filtrée, au lieu de laisser silencieusement la vue bloquée sur la saison courante.

## Etat 2026-04-16 — Cotton Quiz: visuel session dérivé des séries illustrées

Correctif fonctionnel cote `global`:
- les détails jeu `Cotton Quiz` ne retombent plus systématiquement sur `default_cotton_quiz.jpg`;
- si le quiz contient au moins une série avec un vrai visuel custom, le moteur utilise désormais l'image de la dernière série illustrée;
- une simple copie inchangée du fichier `default_cotton_quiz.jpg` sur un lot n'est pas considérée comme un visuel custom;
- sinon le fallback historique `default_cotton_quiz.jpg` reste utilisé.

## Etat 2026-04-16 — Branding Blind Test: instrumentation du flux `general/branding`

Instrumentation diagnostique cote `global`:
- ajout de traces `error_log` dans `app_branding_ajax.php` pour les actions `get`, `save` et `delete_preview`;
- les traces exposent la portee demandee (`session` ou `client`), l'id branding resolu, puis le branding effectif apres sauvegarde;
- objectif: confirmer en conditions reelles si une session `Blind Test` reste resolue en `branding_session` meme apres une sauvegarde `client` via la coche `Utiliser ce design pour mes prochaines sessions`.

Correctif de robustesse associe:
- `app_branding_ajax.php` ne passe plus par `app_session_get_detail(...)` pour resoudre le contexte minimal d'une session;
- le module lit maintenant directement `championnats_sessions` pour recuperer `id_client` et `id_operation_evenement`, ce qui evite le fatal `app_blind_test_get_detail()` observe sur les flux branding `Blind Test` dans `global`.

## Etat 2026-04-16 — Branding visuel: ratio final impose par `global`

Le flux `games` est revenu a un envoi prioritaire du fichier source brut pour `branding_visuel`. L'apercu local de la modale reste recadre pour l'utilisateur, mais il n'est plus utilise comme derive HD de sauvegarde.

Le cadrage final du visuel branding est desormais porte par `app_general_branding_visuel_uploader(...)`: le backend ne rabaisse plus la cible `visuel` a la taille source avant appel au helper `upload(...)`.

En plus, un post-traitement `app_general_branding_cover_fit(...)` recadre explicitement l'image par le centre et force le media actif exactement aux dimensions demandees. La cible `1600x640` definie par `app_branding_ajax.php` est donc bien respectee cote serveur, avec le meme ratio que `600x240`.

## Etat 2026-04-16 — Duplication branding session: pas d'ecriture si la copie medias echoue

Le gel des sessions programmees avant suppression d'un `branding_client` repose sur `app_general_branding_duplicate_to_target(...)`.

La duplication ne copie plus les assets directement dans le dossier session cible. Elle prepare d'abord les medias dans un dossier de staging, verifie la presence des fichiers actifs (`logo.*`, `visuel.*` quand ils existent cote source), puis remplace le dossier cible par swap atomique.

Si la copie des medias echoue, la fonction retourne `0` avant toute creation ou mise a jour de ligne `general_branding` cote session. On evite ainsi le cas ou un `branding_session` prioritaire existe sans ses fichiers et bloque tous les fallbacks.

## Etat 2026-04-17 — Sessions: helper partage agenda / archive

Le module `global` expose maintenant deux helpers de bascule reutilisables par les listes:
- `app_session_list_item_is_archive(...)`
- `app_sessions_filter_by_archive_state(...)`

Ils appliquent la meme regle de classement qu'en fiche detail:
- archive si la date est passee;
- archive aussi si la session est deja `terminated` cote moteur, meme le jour J.

Objectif: eviter les divergences entre details, agendas et historiques quand une session numerique se termine avant changement de date.

## Etat 2026-04-17 — Leaderboards agreges: labels uniformises en uppercase

Les leaderboards agreges portes par `app_client_joueurs_dashboard_*` normalisent maintenant aussi leurs libelles d'affichage:
- `pseudo` si present, sinon `prenom`, deja ramene a un usage `prenom seul`;
- passage en uppercase pour les joueurs;
- passage en uppercase egalement pour toutes les lignes/podiums de leaderboard au moment de la construction finale.

Effet attendu: sur `pro`, `play` et `www`, les podiums et classements agreges affichent des labels visuellement harmonises, y compris pour les pseudos qui restaient jusque-la dans leur casse source.

## Etat 2026-04-17 — Resultats de session: labels uniformises en uppercase

Les fiches resultat de session (`pro` / `play` / `www`) utilisent maintenant aussi une normalisation uppercase partagee dans `app_session_results_*`.

Le formatage est applique:
- aux lignes de classement competitif (`quiz`, `blindtest`);
- aux podiums derives;
- au cas `Bingo Musical`, y compris la liste joueurs et le podium de phases.

Effet attendu: plus de melange `Poulette` / `REMO` / `ROMAIN` sur une meme fiche resultat; les labels session suivent maintenant la meme logique visuelle que les leaderboards agreges.

## Etat 2026-04-17 — FO place: plus de cache journalier stale sur les leaderboards

Le contexte `fo_place` des leaderboards publics n'est plus relu depuis un cache de session journalier cote `global`.

Le calcul est maintenant refait au rechargement pour la partie leaderboard, tout en conservant la reutilisation du `summary_cache` pour les blocs de synthese. Objectif: eviter qu'une session du jour nouvellement terminee reste invisible sur `www/place` parce que le navigateur avait deja charge la page plus tot dans la journee.

Effet attendu: si un `Bingo Musical` ou un `Blind Test` vient juste de se terminer et alimente un classement agrege, l'onglet `Classements` de la fiche `place` doit le montrer des le reload.

## Etat 2026-04-17 — Play: ordre des jeux aligne sur `pro` / `www`

Le builder `app_joueur_leaderboards_get_context(...)` force maintenant l'ordre de rendu `blindtest`, `bingo`, `quiz` avant d'ajouter d'eventuels jeux supplementaires.

Objectif: eviter les inversions de sections visibles sur `play`, par exemple un bloc `Bingo Musical` rendu avant `Blind Test` simplement a cause de l'ordre d'apparition des participations dans l'historique joueur.

## Etat 2026-04-17 — Sessions `quiz`: metadonnees de series accessibles aussi en liste

Les sorties de `app_sessions_get_liste(...)` embarquent maintenant `lot_ids` ainsi que trois champs derives:
- `quiz_series_count`
- `quiz_series_label`
- `quiz_series_names`

Pour les types `Cotton Quiz` `1` et `5`, ces metadonnees sont calculees via `app_cotton_quiz_get_session_series_meta(...)`, donc a partir des `lot_ids` quand ils existent, puis avec fallback `id_produit` si necessaire.

Objectif: permettre aux cartes liste et aux vues publiques compactes d'afficher un libelle court `1 serie` / `x series` sans devoir reconstituer la session complete.

## Etat 2026-04-17 — Sessions `quiz`: helper partage de libelle compact

Le module `global` expose maintenant `app_session_quiz_compact_label_get(...)`.

Regle:
- priorite au `quiz_series_label` calcule sur la session;
- fallback au `quiz_series_label` du helper jeu si disponible;
- fallback final a `theme` pour les anciens formats de quiz;
- retour vide si le fallback duplique simplement `nom_court`.

Objectif: donner une seule source de verite aux agendas `pro`, `play` et `www` pour les labels `1 serie` / `x series` sans casser les formats historiques.
## Update 2026-07-12 — Hub: contrats papier et numérique séparés

Le resolver d'accès Hub court-circuite désormais explicitement l'ensure Canvas pour une session papier. Il maintient l'identité et le mapping Hub sans exiger de preload, de `player_register`, d'ID runtime ou de statut Canvas numérique. L'ensure reste limité au parcours numérique.
## Update 2026-08-31 - Producteur canonique du Master individuel terminal

`app_session_get_individual_terminal_master_link(...)` construit uniquement pour Blind Test, Cotton Quiz et Bingo Musical déjà terminés le launcher Games individuel historique avec `master_view=individual`. C'est une intention de présentation, pas un droit ni une autorisation de lancement; Games conserve la revalidation terminale et le routage Hub par défaut.
## Update 2026-08-31 - Mode démo Hub canonique

Le Hub sépare désormais la session officielle source du runtime exécuté. Avant la fenêtre, tous les comptes utilisent une démo; pendant la fenêtre, une offre effective active conserve le runtime officiel historique et une offre inactive utilise la démo; après la fenêtre aucune démo n'est autorisée. Le garde officiel reste appliqué uniquement au chemin officiel.

Pour le seul bouton Hub `Tester le jeu`, `app_session_demo_create_from_source(source_session_id, launch_intent_id)` crée une nouvelle copie à chaque nouvelle intention. `game_events:hub_demo_launch_intent` est un registre de retry par intention (même intention ou même `command_id` Remote → même démo et même exécution), jamais un mapping durable source→démo. Les URLs démo hors Hub conservent le resolver historique `app_session_demo_source_resolve_or_create(...)`, leur token stable et leur modal `Continuer / Recommencer`. Les exécutions portent `source_session_id`, `runtime_session_id`, `runtime_mode` et `launch_intent_id`; `active_session_id`, la présentation et le membership restent exclusivement officiels. Une nouvelle intention clôt l'exécution démo ouverte et ne reset pas son runtime.

Cette séparation vaut dès le lancement: lorsque la décision canonique retourne `runtime_mode=demo`, le service ne commet pas le focus source, conserve `active_session_id`, `presentation_session_id` et `presentation_mode`, et ne clear aucun focus officiel si la préparation de la copie échoue. Seule la branche `runtime_mode=official` appelle `app_games_hub_focus_set_active(...)`. La provenance Dashboard Pro mobile reste hors de ce service Hub et conserve son parcours historique.

Les sources papier Blind Test, Quiz et Bingo restent inchangées; leur démo est toujours numérique. La fin d'un runtime démo complète l'exécution de la source sans stats, résultats ni contributions agrégées.
## Update 2026-09-02 - SchedulePlan et commit de programmation

`app_schedule_plan_commit(...)` est le contrat d'écriture commun des programmations Quick Schedule. Un plan entièrement validé fixe l'intention (`generated_program|fixed_content|quick_add`), le contexte `soiree|event|day`, la date, le Hub exact éventuel, la commande idempotente et l'ordre/heure/contenu de chaque session. Le commit résout ou crée d'abord le Hub sans réconciliation globale, appelle le writer de session, crée chaque `games_hubs_sessions` avec la source explicite `schedule_plan`, puis vérifie les postconditions avant de mémoriser le succès.

`games_hubs`, `games_hubs_sessions` et `programming_quick_operations` étant MyISAM, aucune atomicité SQL n'est revendiquée. La compensation supprime uniquement les memberships et sessions produits par la commande, puis son Hub s'il vient d'être créé et reste vide. Les sessions générées ont une identité déterministe par commande et position; après 30 secondes, une commande interrompue à l'étape `writing_plan` reprend sur le Hub déjà mémorisé et retrouve donc aussi une session créée avant l'interruption. Les identifiants compensables sont persistés pour qu'une reprise de la même idempotency key commence par leur nettoyage; un succès rejoué retourne le même Hub et les mêmes sessions.

`app_games_hub_sessions_reconcile(...)` reste réservé aux données historiques, à la lecture/migration et à la réparation. Le quick-add ne l'utilise plus comme commande d'ajout et compense sa session si le thème ou le membership explicite échoue. Une projection `games_hubs_publication` seule ne bloque plus la libération d'une ancienne clé de contexte inactive.
