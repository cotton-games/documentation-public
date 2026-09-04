## Update 2026-09-04 - Hub Remote: routage canonique générationnel

Hub Remote reste uniquement un contrôleur déporté. Tout clic `Lancer`, `Reprendre` ou `Relancer` crée une commande persistée; Hub Master la claim, appelle `app_games_hub_session_launch_from_master(...)`, puis Global décide du focus, de la création/réutilisation d'exécution, de l'injection papier et de la readiness. Le module Remote n'appelle jamais ce service, ne crée aucun runtime et ne construit aucune URL historique. `routing_generation` n'accorde aucun droit de lancement.

Après décision Master/Global, `control_poll.client_routing` est l'unique autorité de navigation. Son contrat contient `target`, `session_id`, `execution_id`, `routing_generation`, `remote_url`, `runtime_kind=existing|new|recreated` et `joinable`. Le résultat `command_status` ne navigue plus, même pour `existing`; il peut seulement accélérer un `control_poll`. Une reprise `existing` déjà validée devient immédiatement joinable, sans heartbeat ni readiness supplémentaire. Les runtimes `new` et `recreated` conservent la readiness avant routage. Le sas papier reste lié au besoin réel d'injection et disparaît en reprise existante.

La Remote historique reçoit `hub_remote_execution` et `hub_routing_generation`, puis renvoie leurs équivalents explicites `returned_execution_id` et `returned_routing_generation`. Hub Remote bloque uniquement si le couple courant est exactement celui qui vient d'être quitté. Une nouvelle intention Master/Global incrémente la génération durable, même si elle réutilise le même `execution_id`; ce même runtime redevient donc routable sans override local, baseline SSR ou relais temporel. `remote_transition_payload_json` reste un signal UX borné et réutilise la génération canonique sans créer un second identifiant causal.

Le bootstrap commercial SSR, les overlays, le claim/takeover, la présentation et Hub Play restent inchangés. L'intention UI conserve le libellé et le spinner pendant les snapshots intermédiaires, sans devenir une autorité métier.

Lorsqu'une Remote historique Quiz/Blind Test rejoint une exécution existante pendant que le Master historique recrée encore sa session en mémoire WS, les variantes canoniques `session_not_found`, `Session introuvable.` et le message historique `La session spécifiée n'existe pas...` sont toutes classées comme indisponibilité transitoire. En contexte Hub Remote seulement, elles utilisent la même fenêtre bornée de retry `registerOrganizer + remoteGameState`; les autres erreurs d'inscription, notamment une reconnexion expirée, restent fatales.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/remote_canvas.php`;
- `games/web/includes/canvas/core/hub_transition.js`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `games/web/tests/hub_remote_ws_retry_test.mjs`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-09-04 - Hub Play: fondation UX/UI de l'entrée joueur

La route `/hub/{token}/play` présente désormais le Hub comme une expérience joueur cohérente avec le Hub Master: le visuel devient un hero allégé avec `Bienvenue` et le titre. Le bandeau Play neutralise le plafond historique `max-height: 170px`; l'image complète est rendue en `contain` et son chargement transmet son ratio intrinsèque au wrapper, avec `5/2` comme repli cohérent avec le fallback `600×240`. Un plafond raisonnable de `420px`/`52svh` borne les formats extrêmes; tout espace résiduel est intégré au dégradé du branding plutôt qu'affiché en noir. Les métadonnées sortent du visuel et composent deux groupes robustes: date/heure, puis `parties · joueurs`. Les mots ne sont plus coupés arbitrairement; la recomposition est réappliquée après les refresh branding. Le compteur joueurs reste live avec `joueur|joueurs`; la barre intermédiaire et son statut visuel redondant sont supprimés.

L'entrée non identifiée n'oppose plus deux cartes équivalentes. Une surface unique donne la priorité au pseudo local avec le titre générique et invariant `Rejoins-nous`, `Choisis ton pseudo pour participer.` et le CTA universel `Participer`. Titre et CTA ne dépendent ni du type soirée/événement, ni de l'heure. Les espacements entre sous-texte, champ et CTA sont distincts mais restent compacts. La continuité EP reste secondaire sous `Déjà un compte Cotton ?`: son descriptif explicite utilise une taille, une graisse, une couleur et un interligne tertiaires, avant le CTA secondaire `Se connecter`. Le lien signup existant reste tertiaire et les URLs d'authentification ne changent pas. Le label `Pseudo` reste sémantiquement associé au champ mais est masqué visuellement puisque le placeholder indique déjà `Ton pseudo`.

Le renderer conserve `register_guest`, les règles de validation/unicité, l'identité Hub et ses cookies/localStorage, `current_player`, le polling, l'état joueur déjà inscrit, les lots et les états post-inscription. L'erreur pseudo reste issue du même contrat serveur; elle est maintenant rattachée au champ visible et annoncée comme alerte. Aucun endpoint, payload, write DB, runtime, focus, présentation ou session n'est modifié.

Une fois le joueur inscrit, Hub Play consomme la même présentation canonique que Master et Remote. Le poll historique `active_launched_session` appelle déjà le resolver Global de présentation et transporte sa projection `presentation`; `games_hub_play_personal_state_resolve(...)` la borne à la session membre correspondante. La surface Play reste strictement en lecture seule: elle ne sélectionne aucune session, ne poste jamais `presentation_session_select` ou `presentation_mode_set` et conserve la cadence de 3,5 secondes.

Lorsque la présentation cible une session non terminée, l'identité légère précède une carte principale portant uniquement un statut joueur (`Prochaine partie`, `Partie en cours` ou `Partie quittée` selon l'état déjà existant), le jeu, la thématique et le visuel résolu par le helper de session commun. Aucun horaire individuel, contrôle organisateur, réglage ou CTA de lancement n'est projeté. Le changement A → B remplace la carte au poll suivant; sans présentation canonique exploitable, le fallback joueur historique reste affiché. La reprise volontaire conserve son CTA et son contrat existants hors de la carte. Lots, classement, sortie, runtime et retour de session gardent leurs contrats.

Cette même carte devient le contexte de résultat lorsque la session présentée est terminée. `games_hub_play_result_for_session_from_context(...)` réutilise le resolver historique de résultat mais lui impose le `session_id` présenté: membership de la session dans le contexte Hub, mapping joueur-session, ranking/podium et copies canoniques restent les seules sources. Une participation consolidée affiche sa copie personnelle; un résultat encore vide reste en préparation; l'absence de mapping conserve la session affichée avec un fallback sans résultat. La carte autonome `Dernier résultat` est supprimée: un résultat chronologiquement plus récent ou plus ancien ne peut jamais remplacer la session choisie par Master.

La photo active reste une propriété de `games_hubs_players` et non du résultat focus. Son UI secondaire est rattachée à l'identité `Tu participes avec`, jamais à la carte session ni à la carte `Classement général`. L'action `Ajouter ma photo` / `Modifier ma photo` apparaît uniquement lorsque le serveur retrouve l'identité Hub active aux rangs 1 à 3 de `aggregate_context.aggregate_ranking`, projection canonique fournie par Global. Games ne recalcule pas le rang, ne retombe pas sur ses leaderboards d'affichage pour cette garde et ignore tout rang navigateur. Une session Hub réellement mappée est sélectionnée côté serveur uniquement pour conserver le support historique de consentement et de traçabilité; elle n'a plus à prouver un podium de session. Un joueur classé 4e ou au-delà ne peut plus ajouter ni remplacer sa photo, même s'il possède un ancien podium de session. Sa photo active existante est conservée et n'est jamais supprimée automatiquement.

L'upload conserve validation fichier, MIME, taille, extension, sanitation, consentement, traçabilité et incrément de révision Hub, puis écrit uniquement `games_hubs_players.hub_photo_*`. Global continue d'enrichir depuis cette photo le podium agrégé, les surfaces de classement et les podiums des sessions Hub terminées où l'identité est retrouvée. Le stockage photo historique par session reste disponible hors Hub mais aucune nouvelle photo par session n'est créée par Hub Play.

`Classement général` continue de lire `aggregate_context.aggregate_ranking` sans recalcul Games; Lots, quitter, reprise, auto-routing, résultat historique backend et cadence de polling restent inchangés.

Le contrat responsive structurant de cette surface est canonique: `< 992px` utilise la composition mobile/tablette portrait et `>= 992px` la composition large. La taille `360 × 740` sert uniquement de viewport de recette étroite; elle n'introduit aucun breakpoint principal.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_probable_play_contract_test.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `games/web/tests/hub_session_settings_dom_test.mjs`.

## Update 2026-09-01 - Hub Master : sessions officielles papier Remote-only

Pour un client actif, `flag_controle_numerique=0` est désormais un invariant prioritaire du resolver commun des cartes Hub Master : une session officielle papier ne produit aucune action `Lancer`, `Reprendre` ou `Relancer`, quels que soient son focus et son état runtime. Une session papier prête conserve uniquement le hint `Lancement depuis la télécommande`; une session papier déjà active reste également sans reprise officielle depuis le Master. Hub Remote conserve ses actions selon les guards existants.

Le mode commercial prospect reste évalué avant ce guard officiel : une source papier compatible propose `Démo avec réponses sur smartphone` immédiatement au-dessus de `Faire la démo`, tandis qu'une source incompatible reste sans action et sans cette mention. Une source smartphone et une offre active ne l'affichent pas. Les sessions officielles numériques conservent leurs actions Master. La défense serveur reste inchangée : le POST direct Master `launch_session` refuse le papier avec `PAPER_LAUNCH_REMOTE_ONLY` avant le service central de lancement.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_prospect_card_action_test.php`;
- `games/web/tests/hub_remote_contract_test.php`.

## Update 2026-09-01 - Mode démo Hub Master : information sans CTA commercial

En mode commercial démo, le Hub Master conserve le QR visible mais indisponible et affiche sous celui-ci une information fonctionnelle uniquement : `Teste le déroulé de ta soirée. La version complète est disponible après abonnement.` Aucun lien ni URL e-commerce ne sont rendus par Games. La décision commerciale et le CTA restent dans l’interface Pro; Remote, le runtime démo et la limite de deux joueurs ne changent pas.

## Update 2026-08-31 - Diagnostic Hub : démo de contrôle

Le `hub-preflight-dialog` Master reste réservé au diagnostic. Pour une offre active, le CTA global `Lancer un test` est disponible avant le premier démarrage officiel depuis Master et, sous forme compacte, dans le header Remote. Son éligibilité calculée par le `business_snapshot` est aussi projetée dans le payload SSR initial, puis réconciliée à chaque refresh : le CTA ne reste donc pas masqué par un état de premier rendu incomplet. Les deux entrées convergent vers `app_games_hub_demo_representative_create(...)`: Master appelle `launch_hub_demo`; Remote crée la commande Master `launch_hub_demo` soumise au TTL de présence, claim et annulation existants, puis son poll redirige le Master vers l’Organizer démo comme pour un lancement de session. Le resolver `client_routing` retrouve l’exécution `runtime_mode=demo` par sa session source lorsque `active_session_id` est vide, attend la présence du Master historique puis reconstruit la Remote depuis le même `execution_id` et `runtime_session_id`. Au retour terminal vers le Hub, le marqueur conserve ce seul `execution_id`; la Remote l’ignore explicitement, même si la lease Master est encore fraîche, afin d’éviter un rebond pendant que sa présence runtime expire. Une nouvelle exécution reste routable. Ni focus, ni présentation, ni membership, ni runtime officiel ne sont modifiés. `Faire la démo` est réservé au mode commercial prospect, y compris lorsqu’une démo annexe active est ouverte : les cartes d’un client actif conservent leurs libellés officiels. Les trois actions Master sont contenues dans le panneau latéral (spinner pendant le test) et la Remote conserve son spinner jusqu’au routage réel. En mode commercial, le QR Master reste visible mais est désactivé et couvert d’une pastille « Non disponible en démo »; la notice, placée sous le QR, utilise la couleur secondaire du branding et indique : « Pour jouer les parties avec plus de 2 joueurs, choisis ton offre ». Son lien renvoie vers `/extranet/ecommerce/offers` sur l’Espace Pro correspondant à la segmentation du compte. Les comptes sans offre active ne voient pas le CTA annexe et le garde Global refuse l’appel forgé.

Le mode commercial prospect est prioritaire sur les états techniques de la session source. La décision `runtime_mode=demo` ne commet plus le focus source et les appelants Master/Remote ne changent plus la présentation officielle; `active_session_id`, `presentation_session_id` et `presentation_mode` restent donc ceux d'avant la démo. Même face à un ancien état pollué, la carte ne peut produire ni lien historique, ni `Lancer`, ni `Reprendre`, ni `Relancer`: elle propose `Faire la démo` si le garde numérique l'autorise, sinon `Démo non disponible pour cette partie.`. Une fin naturelle, un quit ou plusieurs exécutions démo successives ne changent pas cette décision. À l'inverse, un client actif conserve `Reprendre` pour une vraie session officielle au focus et `Relancer` pour une officielle suspendue. Le service Global reste l'autorité finale: sans `official_access`, `app_games_hub_launch_runtime_decision(...)` impose `runtime_mode=demo`, indépendamment de l'action demandée par le navigateur.

Le quit volontaire de la Remote historique conserve le chemin partagé Remote → Organizer → `endSession({serverLogout:true})` → `quitGame`. Pour une exécution annexe `runtime_mode=demo`, `endSession` n'appelle pas le clear du focus officiel; au terminal serveur, seule l'exécution démo est marquée complétée, sans mutation de `active_session_id`, `presentation_session_id`, membership, statuts métier, classement ou statistiques Hub. Le retour `HubTransition` vers `/hub/{remote_token}/remote` conserve l'`execution_id` quitté pendant toute la vie de cette page: une lease Master, une `access_transition` ou un `client_routing` encore frais ne peuvent ni désarmer la garde, ni provoquer un rebond, ni maintenir le voile `Accès à la partie.`. Une nouvelle exécution distincte reste immédiatement routable et conserve son sas de transition. Les sessions officielles Hub et les parcours hors Hub conservent leurs quits historiques.

La fin naturelle suit la même provenance canonique, sans réutiliser la routabilité de l'exécution terminée. Canvas résout le couple source/runtime depuis l'événement `hub_execution_started`, exige le runtime terminal, écrit `hub_execution_completed`, puis renvoie `runtime_mode=demo`; il ne clear jamais le focus officiel et ne reconstruit aucune statistique Hub. Quiz et Blind Test diffusent alors le résultat/podium historique avant `HUB_SESSION_FINISHED`. `HubTransition` préserve ce rendu et affiche `Retour à la soirée…` pendant 2,5 secondes avant de rejoindre le Hub du rôle. Master et Remote conservent leur contexte d'exécution local; le Player historique n'arme Hub Play que si son URL transporte le couple source/exécution validé du lancement Hub. Bingo conserve sa fenêtre finale historique de 8 secondes, déjà prioritaire. Une démo Dashboard Pro mobile reste hors de ce contrat: son contexte de branding ou la membership Hub de sa source ne créent pas d'exécution, n'arment pas `HubTransition` et laissent autoritaire la fin historique.

## Update 2026-08-31 - Injection Hub papier: conteneur historique minimal à froid

Avant la boucle `player_register` d'un vrai lancement Hub papier, Global demande désormais à Games un ensure interne minimal par adapter. Quiz crée idempotemment puis relit `cotton_quiz_sessions`; Blind Test fait de même avec `blindtest_sessions`. Bingo valide seulement la session native dans `championnats_sessions`: ce chemin ne crée ni grille, ni carton, ni preload, ni playlist, ni équipe, ni état de podium.

Cette abstraction `canvas_historical_session_ensure_for_game(...)` n'est pas une action publique Canvas et ne modifie pas le contrat de `player_register`. Elle n'appelle jamais `build_preload_for_game(...)`. Le type Quiz legacy `1` conserve l'adapter Quiz; le type archive `2` ne reçoit pas implicitement ce bootstrap. Un conteneur Quiz/Blind Test déjà présent est seulement relu: participants, scores, gains et état runtime ne sont pas réinitialisés.

Fichiers de référence:
- `games/web/includes/canvas/php/boot_lib.php`;
- `games/web/includes/canvas/php/{quiz,blindtest,bingo}_adapter_glue.php`;
- `games/web/tests/hub_paper_historical_session_ensure_test.php`.

## Update 2026-08-31 - Master individuel historique d'une session Hub terminée

Le GET Games normal `/master/{id_securite}` conserve sa redirection Hub pour une session membre terminée naturellement. Le seul lien produit pour la consultation individuelle terminale ajoute `master_view=individual`; `app_orga_ajax.php` ne l'honore qu'après avoir relu `is_terminated`. Il laisse alors poursuivre le boot du Master historique sans modifier membership, focus, présentation, Remote, commandes, runtime ou résultats. Pending/running et les trois surfaces Hub restent inchangés.

## Update 2026-08-27 - Fin Hub Play et acquittement du podium Hub Master

Hub Play ne déduit plus une prochaine partie de la seule présence d'une `presentation_session_id`. Le view model `games_hub_play_personal_state_resolve(...)` valide la session présentée dans le Programme canonique: une session non terminée produit `preparing`, tandis qu'une session terminée reste présentée en `completed` avec son résultat joueur contextuel ou son fallback sans résultat. L'état final agrégé exige que toutes les sessions métier soient réellement terminées et qu'aucune session ne porte le contexte principal; il reste compatible avec `hub_podium`, puis disparaît naturellement au polling quand une nouvelle session prête est ajoutée. Une session prête ou suspendue empêche une fin visuelle prématurée. Les wordings canoniques `La soirée est terminée 🎉` et `L’événement est terminé 🎉` restent inchangés.

Côté Hub Master, fermer l'auto-podium ne reposte plus la session courante après le POST `hub_idle`. La page mémorise aussi la clé stable de l'événement d'auto-ouverture acquitté afin qu'un document frais ou un `hub:program-refreshed` idempotent ne rouvre pas l'overlay. Cette mémoire reste locale à la page; aucune persistance ou cadence de polling n'est ajoutée. Une nouvelle partie quick-add remet normalement la présentation en session, et sa vraie fin produit une nouvelle clé qui réarme l'ouverture automatique. Le carrousel et `AJOUTER UNE PARTIE` restent utilisables après fermeture.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `games/web/tests/hub_session_settings_dom_test.mjs`.

## Update 2026-08-26 - Hub Remote: retour soirée transitoire

Lorsqu'une Remote historique revient explicitement vers `/hub/{remote_token}/remote` via `HubTransition` rôle `remote`, la navigation ajoute le marqueur local `hub_remote_returning=1`. La page Hub Remote utilise ce marqueur uniquement si le bootstrap voit `master_present=false` et que le Hub n'est pas en `hub_sync_suspended`; elle affiche alors le voile bloquant existant avec le titre `Retour à la soirée…`, sans sous-texte.

Ce sas est strictement un état de page: aucune modification de `master_present`, TTL, DB, focus Hub, `active_session_id`, `presentation_session_id`, `execution_id`, readiness ou `client_routing`. La Remote reste non interactive tant que `master_present` n'est pas confirmé. Le premier `control_poll` avec `master_present=true` retire immédiatement le sas; une erreur réseau ou une fenêtre de grâce bornée à 10 s rend la main aux wordings canoniques `Télécommande prête` / `Écran de diffusion déconnecté` selon `masterEverPresent`.

Les événements navigateur précoces (`pageshow`, `online`, `visibilitychange`) ne peuvent plus déclencher de `control_poll` avant la confirmation `instance_takeover` de la page Hub Remote courante. Cela évite qu'une nouvelle page de retour Hub Remote interprète un `409 instance_current=false` pré-takeover comme une vraie Remote ouverte ailleurs; les vrais remplacements restent traités après takeover par l'overlay terminal existant.

Fichiers de référence:
- `games/web/includes/canvas/core/hub_transition.js`;
- `games/web/remote_canvas.php`;
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-26 - Hub Master: prédiagnostic borné à la fenêtre de lancement

Le prédiagnostic léger du poste Hub Master dépend maintenant uniquement de l'autorité temporelle serveur `app_games_hub_temporal_state($hub)['launch_window_open']`, exposée dans le DOM Master via `data-hub-launch-window-open="1|0"`. Aucun calcul de date/cutoff n'est ajouté côté navigateur, et l'éligibilité ne dépend ni du nombre de sessions, ni de leur statut, ni de `data-hub-sync-suspended`.

Quand `launch_window_open=true`, le comportement automatique reste inchangé: diagnostic initial au boot, rechecks bornés `900 / 1400 / 4200 / 9000 ms`, listeners `offline`, `online`, `pageshow` et `navigator.connection.change`, checks stockage/profil réseau/probe Cotton et UX existants. Le cas Hub encore réactivable avec toutes les sessions courantes terminées conserve donc le diagnostic automatique.

Quand l'état temporel est `before`, l'icône manuelle reste visible dans un état initial neutre `Diagnostic du poste disponible`, sans faux état `running`; aucun timer initial ni listener automatique du préflight n'est armé. Tant qu'aucun diagnostic n'a été exécuté dans la page, la modale affiche seulement le texte de prévisualisation et le CTA `Lancer le diagnostic`, sans bloc résultat. Après un lancement manuel, le résultat historique revient avec le CTA `Relancer le diagnostic`. Quand l'état est `expired`, l'icône manuelle n'est plus rendue et aucun prédiagnostic automatique n'est câblé. Les lancements/reprises, quick-add, Hub Remote, polling Master, takeover, runtime, `prelaunch_check.js`, résultats et podiums restent inchangés.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `games/web/tests/hub_session_settings_dom_test.mjs`.

## Update 2026-08-26 - Hub Remote: sas papier avec annulation bornée

Le sas joueurs papier Hub Remote n'est plus une surface d'administration générale du roster Hub. Les joueurs chargés par `paper_lobby_players` à l'ouverture restent visibles mais strictement en lecture seule: aucun bouton de suppression n'est rendu pour eux et un appel manuel à `paper_lobby_player_remove` sans preuve d'undo est refusé avant toute mutation.

`paper_lobby_player_add` conserve l'ajout Hub-only existant sans créer de participant runtime ni de mapping `games_hubs_players_sessions`. Quand `app_games_hub_player_ensure(...)` indique une vraie entrée dans le roster Hub actif (`created` ou `reactivated`), l'endpoint retourne un token d'undo éphémère lié au Hub, à la session papier, au joueur et à l'ouverture courante du sas. L'UI mémorise ce droit uniquement en mémoire JS et affiche `Annuler l’ajout` en tête de liste. Si le joueur était déjà `active`, aucun token n'est retourné et aucun bouton n'est rendu.

La fermeture de la modale, une réouverture ou un reload effacent le droit d'annulation: le joueur devient alors un joueur Hub normal, visible en lecture seule au prochain chargement du sas. Aucune provenance durable, aucune table, aucune colonne, aucun `localStorage`/`sessionStorage` et aucun mapping session anticipé ne sont introduits. L'injection papier au vrai lancement reste inchangée et continue de dépendre uniquement des joueurs Hub encore `active`.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-08-26 - Hub QR cliquables uniquement en dev

Les QR Hub côté Games restent inchangés côté contenu encodé, mais leur interactivité est maintenant bornée à l'environnement dev. Le QR joueurs du Hub Master (`data-hub-qr-container`) enveloppe le SVG dans un lien `target="_blank"` seulement si `games_hub_qr_links_enabled()` est vrai; en production, le rendu injecte uniquement le SVG sans lien ni handler.

Le générateur Canvas commun `qrcode-svg.js`, utilisé notamment pour les QR joueurs et Remote historiques, ne s'appuie plus sur `location.hostname` ou `localhost`; il rend un lien uniquement quand `window.AppConfig.env === 'dev'`, valeur exposée depuis la configuration serveur.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/includes/canvas/core/qrcode-svg.js`;
- `games/web/tests/hub_remote_contract_test.php`.

## Update 2026-08-26 - Hub Remote: sas papier avec désinscription explicite

Le sas joueurs papier Hub Remote ajoute maintenant une désinscription explicite avant lancement. Chaque joueur listé depuis `paper_lobby_players` expose un bouton `Désinscrire`; la mutation `paper_lobby_player_remove` reste Hub-only, ne lance pas la session, ne crée ni runtime ni mapping `games_hubs_players_sessions`, puis recharge la liste active.

L'état vide est consolidé autour de la phrase exacte unique `Aucun joueur inscrit pour le moment.` et la modale affiche l'intro `Inscris les joueurs papier pour les inclure dans le classement de la soirée.`. Le bouton `Lancer la partie` reste disponible même à zéro joueur et continue de passer par le contrat existant `launch_session`.

Tests associés:
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-26 - Hub Remote: sas joueurs papier aligné historique + gate Pro

Hub Remote intercale un sas joueurs pour les sessions papier avant de créer la commande `launch_session`. Le clic `Lancer` papier ouvre une modale locale de préparation, charge immédiatement les joueurs Hub actifs via `paper_lobby_players`, puis reprend le contrat historique Remote papier d'ajout joueur: seuil de 3 caractères, debounce 180 ms, lookup automatique avec protection de réponse obsolète, sélection d'un participant existant ou création d'un joueur local pour la soirée si aucun résultat n'est retenu.

Le sas n'appelle pas `player_register`, ne crée pas de ligne runtime Quiz/Blindtest/Bingo et ne crée pas de mapping `games_hubs_players_sessions`. Les participations papier restent créées uniquement par l'injection existante `app_games_hub_session_inject_active_players(...)` au vrai lancement. La mutation d'ajout/réactivation passe par le helper Hub-only `app_games_hub_player_ensure(...)`.

Hub Master ne propose plus de lancement neuf papier: les cartes papier affichent la mention statique exacte `Lancement depuis la télécommande` comme information secondaire de carte, hors footer d'action, sans type d'action JS ni apparence de CTA. Le backend direct `launch_session` refuse toujours une session papier avec `PAPER_LAUNCH_REMOTE_ONLY` avant d'atteindre `app_games_hub_session_launch_from_master(...)`. Les sessions numériques conservent leur parcours de lancement existant.

Depuis le Dashboard Pro, le CTA `Diffuser la soirée` / `Diffuser l'événement` reste direct pour un programme 100 % numérique ou si la Hub Remote canonique est fraîche. Si au moins une session papier est programmée et que `hub_remote_instance_id` / `hub_remote_instance_seen_at` sont absents ou stale selon le helper Global `app_games_hub_remote_presence_gate_get(...)`, Pro bloque l'ouverture immédiate du Master et affiche la modale `Ouvre d’abord la télécommande`, avec CTA `Ouvrir la télécommande` pointant vers l'URL Remote existante.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-08-26 - Hub Remote: UI allégée

Hub Remote retire de son rendu visible les panneaux `Lots` et `Top joueurs`, afin de garder la télécommande centrée sur le Programme, l'état de connexion Master, le compteur joueurs et les commandes Remote. Les projections serveur `prizes` et `aggregate` restent dans `business_snapshot`; aucune donnée ni contrat canonique n'est supprimé.

Les wordings de verrou Master sont simplifiés tout en conservant la variante contexte Hub: `Diffuse la soirée depuis l'ordinateur...` ou `Diffuse l'événement depuis l'ordinateur...`. La carte `AJOUTER UNE PARTIE` affiche maintenant `Choisir un nouveau jeu`.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-26 - Hub Remote: transition runtime jusqu'au routage

Hub Remote conserve maintenant l'état de transition runtime après acceptation d'un `launch_session`, même lorsque la commande Master passe `completed`. Le front distingue explicitement `runtimeTransitionPending` de la requête HTTP en vol, du `pendingCommandId`, de la sélection Programme et de la présence Master.

Le CTA `Lancer` / `Reprendre` reste désactivé avec spinner jusqu'à un événement terminal réel: navigation `window.location.replace(...)` déclenchée par `client_routing`, erreur/expiration/annulation/remplacement de commande, perte Master ou refus réseau/métier explicite. `completed` seul ne remet plus le bouton dans son état idle.

Le routage reste piloté par le contrat canonique `control_poll.client_routing`: session cible, `client_joinable=true`, présence du Master historique (`master_context_available=true`) et `remote_url` interne valide. Il ne dépend plus de `pendingCommandId`, afin de préserver les reloads et ouvertures tardives.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-26 - Hub Remote: remplacement cross-context

Hub Remote ne dépend plus du `session_token_hash` PHP singleton pour ses échanges AJAX: la page inclut maintenant le `remoteToken` public dans l'endpoint AJAX, tandis que le bind de session reste limité au chargement HTML initial. Une Remote ouverte dans un autre navigateur, en navigation privée ou sur un autre device peut donc remplacer l'instance canonique sans rendre l'ancienne Remote incapable de résoudre son Hub.

Le premier `control_poll` de l'ancienne Remote après takeover reçoit à nouveau le contrat serveur existant `instance_current=false`, `replaced=true` au lieu d'un `REMOTE_UNAVAILABLE` classé offline. Le front conserve le mécanisme terminal existant: arrêt des timers, blocage des contrôles et overlay "Cette interface est ouverte ailleurs. Vous pouvez fermer cette page.".

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-26 - Hub Remote: CTA runtime optimiste verrouillé

Hub Remote supprime le dernier délai perceptible de sélection Programme en rendant immédiatement la carte cliquée depuis le cache local `latestProgramSessions`, avant la réponse HTTP `select_session`. Cette projection reste strictement visuelle: elle réutilise les données métier déjà projetées par le serveur, dont `games_hub_remote_session_action(...)`, sans recalculer les règles `Lancer` / `Reprendre` côté navigateur.

Le CTA runtime visible pendant cette fenêtre optimiste reste désactivé par la raison locale `pending_selection`; aucun `launch_session` ne peut partir tant que le serveur n'a pas confirmé le même `presentation_session_id`. Au succès courant, le verrou est levé sans attendre `business_snapshot`; en cas d'échec, perte `master_present`, instance remplacée, réponse stale ou snapshot canonique concurrent, la Remote restaure/converge vers le dernier `presentation_session_id` confirmé.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-26 - Hub Remote: CTA runtime immédiat après sélection canonique

Hub Remote confirme maintenant `select_session` en écrivant immédiatement `games_hubs.presentation_session_id` côté serveur, après validation du token Remote, de l'instance courante, du gate frais `master_present` et de l'appartenance session/Hub. La commande `select_session` Master reste créée comme signal de convergence/idempotence, mais la Remote n'attend plus que le Hub Master reflète lui-même ce focus pour rendre la carte complète.

La réponse Remote renvoie le `presentation_session_id` committé et la projection métier de la session sélectionnée, incluant l'action issue de `games_hub_remote_session_action(...)`, les settings et l'éligibilité renouvellement. Le navigateur garde un cache des sessions projetées et reconstruit immédiatement le Programme autour de cette sélection canonique courante; les réponses stale sont ignorées via `selectionRequestToken`, et les protections `pendingCommandId` / `commandInFlight` / `awaitingLaunchRouting` restent inchangées pour le runtime.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-26 - Hub Remote: verrou local tardif et Master hidden

Hub Remote invalide maintenant aussi les réponses tardives de mutation `launch_session` / `master_ping`, pas seulement les réponses `command_status`. Quand `master_present=false` provoque un reset local, les tokens de mutation et de sélection sont avancés, `pollState.commandInFlight` / `pollState.selectionInFlight` sont vidés, les spinners disparaissent et une réponse HTTP ancienne ne peut plus réinstaller `pendingCommandId` ni maintenir `getLaunchDisabledReason()` sur `pending_command`.

Hub Master ne change pas sa cadence de polling: 2 s quand l'onglet est visible et 10 s quand il est caché. Le passage `visibilitychange` publie désormais aussi l'état `hidden`, afin que le gate serveur puisse distinguer un Master volontairement en arrière-plan d'un Master disparu. Une vraie sortie de page envoie une release best-effort `remote_control_release` via `sendBeacon` / `fetch keepalive`; elle est ignorée pour les redirections runtime issues d'un `launch_session` complété.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-26 - Hub Remote: gate frais Hub Master obligatoire

Hub Remote peut s'ouvrir avant le Hub Master tout en restant entièrement non exploitable tant que le Hub Master canonique n'est pas frais. Le rendu initial lit `master_present` avec le même gate serveur frais que `control_poll`, puis affiche un voile global avec modale centrée "Télécommande prête" et wording soirée/événement issu de `games_hub_master_wording_labels_get(...)`.

Le client conserve seulement un état local de page `masterEverPresent`: avant première présence Master, la modale indique de diffuser la soirée/l'événement depuis l'ordinateur; après une présence confirmée puis perdue, elle bascule vers "Écran de diffusion déconnecté" et demande de diffuser à nouveau. Dès qu'un poll reçoit `master_present=true`, le voile disparaît sans reload.

Le verrou bloque toute interaction Remote derrière le voile. Côté serveur, un gate commun refuse les mutations quand le Master frais est absent: `session_settings_save`, `quick_session_create`, `quick_session_theme_renew`, `master_ping`, `select_session` et `launch_session` / reprise. Les lectures `control_poll`, `business_snapshot`, `command_status` et le chargement non-mutant de réglages restent accessibles. Le poll Master claim désormais les commandes avant de rafraîchir sa présence, afin qu'un retour après absence ne ressuscite pas une commande pending ancienne.

Côté front, une commande Remote pending est un état local jetable. Si `control_poll` annonce `master_present=false`, la Remote abandonne immédiatement la pending locale, retire le spinner et invalide la réponse `command_status` en vol, sans mutation serveur de nettoyage. Les statuts terminaux non-success `expired`, `cancelled`, `failed` et `replaced` appliquent le même reset local; `completed` garde le chemin nominal existant et attend toujours le routage canonique `client_routing`.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-26 - Hub Master/Remote: instance exclusive par page

Hub Master et Hub Remote sont maintenant exclusifs par surface: ouvrir un nouveau Hub Master remplace l'ancien Hub Master, et ouvrir une nouvelle Hub Remote remplace l'ancienne Hub Remote. Chaque page génère un UUID de page au chargement; il n'est pas stocké dans `localStorage`, afin que deux onglets d'un même navigateur restent deux instances distinctes.

Le takeover est explicite au boot (`hub_instance_takeover` côté Master, `instance_takeover` côté Remote). Les polls normaux ne reprennent jamais la propriété: ils ne font que toucher l'instance courante et reçoivent `instance_current=false`, `replaced=true` s'ils sont stale. Les actions Master (`launch_session`, présentation, settings, quick-add, renouvellement) et les actions Remote (`control_poll`, `select_session`, `launch_session`, `master_ping`, settings, quick-add, snapshot/status) sont bloquées côté serveur pour une page remplacée.

Une page stale stoppe ses timers/retries, désactive ses contrôles et affiche l'overlay terminale "Cette interface est ouverte ailleurs. Vous pouvez fermer cette page.", sans `window.close` ni redirection vers le Hub.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-08-26 - Hub Remote: hiérarchie légère des cartes Programme

Hub Remote redevient une télécommande compacte: les cartes Programme hors `presentation_session_id` sont strictement informatives et ne rendent plus d'action dans le DOM. Elles restent sélectionnables via le contrat existant `select_session`, qui écrit la présentation canonique côté Hub Master sans lancer de runtime.

La carte présentée est la seule à rendre des actions. Les actions de préparation `session_settings_*` et `quick_session_theme_renew` restent des mutations Remote directes, mais apparaissent désormais en icônes compactes dans la zone haute de la carte (`↻` puis réglages), seulement quand les helpers métier les déclarent disponibles. Le CTA runtime reste séparé en bas de carte et conserve uniquement `Lancer` / `Reprendre` via `launch_session` -> Hub Master -> `command_status` / `control_poll.client_routing`.

Le rendu PHP initial et la reconstruction JS `business_snapshot` appliquent la même hiérarchie: focus canonique d'abord, aucune action sur l'ancienne carte après changement de `presentation_session_id`, aucune transformation des actions de préparation en commande runtime. La carte `AJOUTER UNE PARTIE` reste une action de programme séparée et n'est pas traitée comme une session normale.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-25 - Hub Master/Remote: suspension terminale de synchronisation

Hub Master et Hub Remote suspendent maintenant leurs boucles de synchronisation seulement quand le Hub est terminé et non réactivable: `app_games_hub_dashboard_is_completed(...)` doit être vrai et `app_games_hub_temporal_state(...).launch_window_open` doit être faux. Le cas particulier "toutes les parties courantes sont terminées mais l'ajout rapide reste possible" continue donc à poller, pour permettre la création d'une nouvelle partie et la convergence Master/Remote/Dashboard.

Côté Remote, `business_snapshot` expose `hub_sync_suspended`; le navigateur coupe alors le timer `control_poll` et ignore les relances `pageshow`/`online` tant que cet état terminal reste vrai. Côté Master, les checks de `preparation_revision` et les posts de présence sortent immédiatement quand `data-hub-sync-suspended=1`. Le changement ne transforme pas le Hub en temps réel et ne modifie pas les contrats runtime, commandes ou routage.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-08-25 - Hub Remote: settings et ajout rapide directs

Hub Remote sépare maintenant explicitement les actions runtime des mutations de préparation. Les actions `launch_session` et `select_session` gardent le contrat Remote -> commande -> Master, parce qu'elles concernent l'exécution ou la présentation Master. Les mutations de préparation `session_settings_get`, `session_settings_save` et `quick_session_create` sont traitées directement par l'endpoint Remote authentifié, sans exiger `master_present`.

Le paramétrage Remote réutilise les mêmes primitives que le Master: résolution session Hub, `games_hub_session_settings_state(...)`, `games_hub_session_settings_values(...)`, rendu serveur `canvas_session_options_render(...)`, validation `canvas_session_options_hub_update_normalize(...)` et persistance `canvas_session_options_snapshot_save(...)`. Le client mobile affiche un dialog avec état pending, bloque les doubles soumissions et se réaligne ensuite par `business_snapshot`.

L'ajout rapide Remote expose une carte `AJOUTER UNE PARTIE` dans le Programme. Le client ne transmet que le jeu choisi parmi l'allowlist serveur et une clé d'idempotence; le service Global `app_programming_quick_hub_create_from_game(...)` décide thème, mode, format, horaire, Hub et rattachement. La présentation créée est conservée comme focus pending jusqu'au snapshot contenant la nouvelle session.

Hub Master respecte aussi la sélection portée par le HTML serveur frais après un refresh partiel. Si un quick-add Remote vient de créer une partie et de poser `presentation_session_id`, le Master ne restaure plus l'ancienne carte locale par-dessus la nouvelle sélection canonique.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `games/web/tests/hub_session_settings_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-08-25 - Hub Remote: renouvellement theme et latence

Hub Remote expose maintenant le renouvellement rapide de thematique `↻` sur les memes sessions eligibles que Hub Master: membership `quick_hub_create`, session jamais lancee/pending, non focus runtime actif, non running/terminee, jeux Quiz/Blind Test/Bingo, et service de renouvellement disponible. L'endpoint Remote `quick_session_theme_renew` valide le token Remote, le CSRF, l'appartenance session/Hub et cette eligibility partagee, puis appelle le meme contrat Global `app_programming_theme_renewal_plan_for_session(...)` / `app_programming_theme_renewal_apply_for_session(...)`.

Le renouvellement Remote reste une mutation de preparation directe: aucune commande Master n'est creee, aucun runtime n'est declenche, `master_present` n'est pas requis et la presentation/focus n'est pas changee implicitement. Le navigateur Remote affiche un bouton compact `↻` seulement dans les actions de la carte selectionnee eligible, bloque le double clic, attend la confirmation serveur, puis relit le Programme via `business_snapshot` canonique.

Instrumentation de convergence: en dev/local, `[hub_remote_perf]` trace T0 clic, T1 mutation confirmee, T2 revision serveur retournee, T3 `control_poll` avec revision differente, T4 snapshot lance, T5 snapshot recu et T6 DOM Programme mis a jour. Hub Master trace aussi `[hub_master_perf]` pour revision connue, revision serveur differente, refresh partiel lance/recu et DOM Programme mis a jour. Aucune baisse globale de polling n'est appliquee; `control_poll` conserve son fast-path avec `perf.elapsed_ms` et `perf.sql_queries`.

Fichiers de reference:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `games/web/tests/hub_session_settings_test.php`;
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`.

## Update 2026-08-25 - Hub Master: suppression du badge Prochaine

Hub Master ne rend plus le wording visible `Prochaine` sur les cartes Programme. La carte qui aurait auparavant porté cette mention garde son statut métier standard, par exemple `Prête`, afin de ne pas contredire la sélection manuelle libre du présentateur.

Le changement est strictement UI. `games_hub_next_session_id(...)` reste disponible pour le calcul interne local, et la politique Global `app_games_hub_next_ready_session_resolve(...)` / `app_games_hub_presentation_apply_next_ready(...)` continue de déplacer automatiquement `presentation_session_id` après clear/suspension/quit/grâce. La fin naturelle garde son exception `presentation_next_ready=false`, l'ajout rapide garde `quick_add`, Remote reste consommateur de la présentation canonique.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-08-25 - Hub présentation: prochaine session prête événementielle

La règle interne de prochaine session prête n'est pas un recalcul destructif au refresh. Depuis le patch UI suivant, elle n'est plus affichée comme wording `Prochaine` sur les cartes Master; sa persistance en `presentation_session_id` vient uniquement d'événements métier explicites.

Après suspension, quit Organizer ou expiration de grâce, `app_games_hub_focus_clear(...)` applique la politique `next_ready`: première session non terminée, non running, non focus, triée par `position` Programme puis `id`. Cette écriture passe par `app_games_hub_presentation_session_set(...)`; elle ne modifie ni `active_session_id`, ni exécution, ni routage runtime. Le Remote consomme ensuite seulement le `presentation_session_id` et conserve son pending focus si la carte n'est pas encore dans `sessions[]`.

La fin naturelle est volontairement exclue de cette promotion: `canvas_api_hub_session_natural_ended(...)` passe `presentation_next_ready=false` avec `presentation_reason=natural_completion`. Le retour Master garde donc la session terminée/podium via les événements de complétion historiques au lieu de sauter immédiatement à la prochaine session.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `games/web/includes/canvas/php/boot_lib.php`;
- `games/web/modules/app_orga_ajax.php`;
- `games/web/tests/hub_natural_end_stats_rebuild_test.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `global/web/tests/hub_presentation_mode_contract_test.php`.

## Update 2026-08-25 - Hub Remote: focus différé après ajout rapide

Hub Master traite l'ajout rapide comme une politique explicite de présentation: quand `quick_session_create` confirme un `session_id`, le handler écrit `presentation_session_id` via `app_games_hub_presentation_session_set(..., 'quick_add')`. Le mode seul reste un fallback uniquement si l'identifiant créé ne peut pas être validé dans le Hub.

Hub Remote supporte maintenant l'ordre asynchrone `presentation_session_id=D` avant apparition de `D` dans `sessions[]`. Le navigateur garde un pending focus par `session_id`, ne sélectionne aucune autre carte comme fallback, ne poste pas de `select_session`, puis applique automatiquement `D` dès qu'un snapshot Programme la contient. Si une nouvelle présentation canonique arrive entre-temps, elle remplace ce pending.

Les révisions existantes suffisent: `presentation_updated_at` participe aux révisions métier et la création/rattachement de session fait évoluer la révision de préparation. Aucun polling plus agressif n'est ajouté.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-08-25 - Hub Master: refresh positionnel silencieux

Hub Master restaure maintenant la position du carousel Programme après remplacement DOM sans rejouer d'animation de focus. Le refresh Programme reconstruit le bloc `[data-hub-refresh-block="program"]`; le nouveau conteneur horizontal repart donc naturellement à sa position initiale. La carte sélectionnée restait correcte en données/classes, mais pouvait sortir du viewport parce que le précédent garde utilisait `scroll=false`.

Le contrat est désormais séparé: `selectCard(...)` applique toujours l'état de sélection, et `scrollBehavior` choisit seulement la restitution viewport. Le premier boot Master et les confirmations serveur après `hub:program-refreshed` recentrent la carte canonique avec `behavior:'auto'`, sans persistance ni animation perceptible. Une vraie sélection différente, par clic Master ou intent Remote, conserve le `scrollIntoView` animé historique.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_remote_contract_test.php`.

## Update 2026-08-25 - Hub Master: reload et présentation canonique

Le reload complet du Hub Master restaure désormais la présentation canonique persistée au lieu de recalculer un fallback Programme concurrent. Le view model porte le résultat de `app_games_hub_presentation_resolve(...)`, puis `games_hub_render_program(...)` le transmet à `games_hub_master_presentation_selection_resolve(...)`.

La cause corrigée était bornée au rendu serveur Master: `games_hub_render_program($view, ...)` appelait le resolver avec `$context['hub']`, variable hors scope dans cette fonction. Le resolver recevait donc un Hub vide et le Master pouvait retomber sur `first_unplayed_program_order` malgré un `presentation_session_id` valide, alors que Remote lisait correctement `persistent_presentation_session_id`.

Les règles métier historiques restent inchangées: runtime focus, fin naturelle, podium Hub, suspension, ajout rapide et fallback Programme continuent d'être produits par leurs chemins existants. Le reload se contente de relire la décision canonique quand elle existe; les fallbacks ne s'appliquent que sans présentation canonique restaurable.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_remote_contract_test.php`.

## Update 2026-08-25 - Hub Master refresh sélection idempotent

Hub Master ne rejoue plus l'animation de sélection quand le refresh Programme confirme la même présentation. Le refresh remplace les blocs puis déclenche `hub:program-refreshed`; la réinitialisation du carrousel détecte désormais cet événement et applique la carte sélectionnée sans `scrollIntoView`.

Le contrat reste identitaire: une confirmation serveur du même `presentation_session_id` est silencieuse, tandis qu'un nouvel intent vers une autre session continue de passer par `applySelectionIntent(...)` et peut scroller vers la nouvelle carte. Les refreshs nécessaires aux statuts, CTA, lots et contenus centraux restent inchangés.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_remote_contract_test.php`.

## Update 2026-08-25 - Hub Remote bootstrap sélection et police

Hub Remote conserve maintenant les champs de présentation du snapshot initial dans son payload de rendu. `presentation_session_id` n'est donc plus perdu entre `games_hub_remote_business_snapshot(...)` et le HTML: la carte serveur attendue est sélectionnée dès le chargement.

Le bootstrap navigateur reçoit aussi `initialBranding` et appelle `syncHubBranding(initialBranding)` avant le premier `control_poll`. Le lien de police, les variables CSS, le titre, la méta et le logo compact ne dépendent donc plus d'une première interaction ou d'un snapshot métier ultérieur.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-25 - Hub focus runtime vs présentation séparés

Hub Master et Hub Remote séparent maintenant la présentation de la session runtime active. `games_hubs.active_session_id` reste strictement réservé au runtime: lancement/reprise, validation d'exécution ouverte, auto-join Hub Play, routage Remote historique et clear atomique. Les sélections de cartes Master/Remote écrivent `games_hubs.presentation_session_id` via `app_games_hub_presentation_session_set(...)` et ne modifient plus le focus runtime.

`app_games_hub_presentation_resolve(...)` lit d'abord `hub_podium`, puis `presentation_session_id` si la session appartient au Hub, puis seulement un fallback runtime `active_session_id`, puis un fallback programme non destructif. Hub Remote consomme ce resolver dans `business_snapshot`; si aucun `presentation_session_id` n'est fourni, le navigateur ne sélectionne plus localement la première carte. Le boot Master reçoit aussi la présentation résolue pour éviter de retomber sur une heuristique locale contradictoire.

Le schéma ajoute `games_hubs.presentation_session_id` nullable et l'index `idx_games_hubs_presentation_session`, sans backfill. Le lancement/reprise continue de poser `presentation_session_id = active_session_id` au moment du focus runtime pour garder la présentation alignée sur l'action réelle, mais une sélection ultérieure peut changer l'affichage sans rendre la session joignable.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/includes/canvas/sql/2026-08-25_games_hubs_presentation_session.sql`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_presentation_runtime_separation_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-08-25 - Hub Remote UI mobile-first

Hub Remote `/hub/{remote_token}/remote` est maintenant une télécommande mobile compacte alignée sur Hub Play. L'UI visible ne rend plus les blocs techniques de contrôle, commande en attente, session active ou révision; la présence Master reste une pastille de header discrète, libellée `Connecté` / `Déconnecté` depuis la donnée `master_present`.

Le snapshot métier existant continue d'alimenter le Programme, les Lots et le Top joueurs. Il charge aussi le branding canonique et expose `hub_branding` via `games_hub_play_branding_payload(...)`, afin que la Remote reprenne les variables CSS, la police, le titre, la méta et le logo compact Hub Play au rendu initial puis sur refresh dynamique. Le grand visuel Hub Play n'est pas rendu sur la Remote. Le snapshot porte aussi `presentation_session_id` issu de la présentation serveur résolue, ainsi que le compteur `players_count`, désormais affiché dans une seconde pastille de header avec le wording Hub Master `joueur inscrit` / `joueurs inscrits`. Le Top joueurs réutilise la projection agrégée Master via `games_hub_general_ranking_from_aggregate_context(...)` et affiche les statistiques courtes `vict.`, `pod.`, `part.` au lieu d'un score brut.

Les rangs Lots et Top joueurs disposent d'une colonne compacte centrée. Le rendu PHP initial et la reconstruction dynamique normalisent la valeur de rang avant d'ajouter le seul préfixe visuel `#`, afin d'éviter les doublons du type `##1`.

Le Programme Remote reprend les helpers Master pour ses informations essentielles: jeu, thème, mode/format, séries Quiz et statut, sans afficher l'horaire individuel des cartes. Chaque carte est sélectionnable et envoie une commande légère `select_session` au Hub Master, qui écrit la présentation persistée sans lancer le runtime. Une sélection côté Master poste aussi `presentation_session_select` et écrit cette même présentation; le snapshot suivant fait donc converger la Remote, y compris après fin naturelle/podium. La synchronisation snapshot est silencieuse et ne renvoie pas de nouvelle commande `select_session`.

Seule la carte sélectionnée affiche un CTA si une action runtime existe. Les sessions terminées restent sélectionnables et identifiables comme `Terminée`, mais n'affichent plus le CTA `Résultats`; les actions visibles restent `Lancer` / `Reprendre`. Les CTA gardent le contrat existant `launch_session` -> `command_status` -> `control_poll.client_routing`: aucun routage depuis `command_status`. Au clic, le bouton affiche immédiatement un spinner et reste désactivé après `completed` jusqu'à `routeFromControlState()` ou jusqu'à un échec/timeout serveur.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-08-24 - Remote Bingo Hub: fallback local désactivé en dev

En environnement dev/local, la Remote historique Bingo lancée depuis Hub Remote n'utilise plus le fallback local armé juste après `remote_quit_request`. Après `RemoteAPI.requestQuit(sessionId)`, le bouton reste dans l'état de quit demandé, un diagnostic `REMOTE_BINGO_QUIT_FALLBACK_DISABLED` est loggué, et aucun `returnToHubRemoteAfterNotice(..., 'remote_quit_request')` local n'est déclenché.

La recette dev force donc le retour Hub Remote à dépendre uniquement des terminaux WebSocket `SESSION_ENDED` / `HUB_SESSION_FINISHED`, traités par `remote-ws.js` avec les logs `hub_remote_remote_ws` et `navigation_triggered`. Les autres logs de preuve restent inchangés: `hub_remote_bingo_quit`, `quitGame_received` et `hub_remote_bingo_terminal_delivery`.

Le comportement hors dev reste conservé pour l'instant: le fallback non-dev de 800 ms reste présent et annulable par `remoteQuitUnavailable`. Après recette concluante, la décision attendue est soit une suppression définitive de ce fallback, soit une réactivation documentée comme filet de sécurité uniquement.

Fichiers de référence:
- `games/web/includes/canvas/remote/remote-ui.js`;
- `games/web/includes/canvas/remote/remote-ws.js`;
- `games/web/tests/hub_remote_contract_test.php`.

## Update 2026-08-24 - Bingo Remote quit: garantie `quitGame`

Le quit volontaire Bingo demandé depuis la Remote Hub reste borné au contrat Remote -> Organizer -> `endSession({serverLogout:true})` -> `quitGame` -> Bingo WS. L'Organizer transmet maintenant le `sessionId` reçu dans la demande Remote à `endSession()`, et `endSession()` dispose d'une résolution robuste de secours via GameStore, `AppConfig.sessionId`, preload et `#organizer-root[data-token]`.

Sur `serverLogout=true`, `endSession()` conserve le clear Hub avant la fermeture métier, puis exige que `quitGame` soit effectivement pris en charge par une socket WebSocket ouverte avant d'afficher la notice et de rediriger le Master. Le connecteur WS publie pour cela `ws_connector:send_done` / `ws_connector:send_fail` corrélés par `_sendTraceId`; aucun ACK serveur complexe n'est ajouté. En cas d'absence de session, socket non ouverte, exception ou timeout local, la redirection Organizer est bloquée et l'échec est loggué.

Les traces front attendues sont `hub_remote_bingo_quit` avec `remote_request_consumed`, `end_session_started`, `clear_focus_done`, `quit_game_send_start`, `quit_game_send_done`, puis `redirect_start`. Côté Bingo WS, la réception effective est visible par `quitGame_received`, suivie de `SESSION_END` puis `hub_remote_bingo_terminal_delivery` pour le terminal volontaire.

Fichiers de référence:
- `games/web/includes/canvas/core/boot_organizer.js`;
- `games/web/includes/canvas/core/end_game.js`;
- `games/web/includes/canvas/core/ws_connector.js`;
- `games/web/tests/hub_remote_contract_test.php`;
- `bingo.game/ws/bingo_server.js`.

## Update 2026-08-24 - Hub Remote: relance BT/Quiz et quit Bingo

La reprise Hub Remote Quiz/Blind Test corrèle désormais la readiness Organizer depuis le contexte canonique de l'URL de lancement (`hub_remote_command`, `hub_remote_execution`). La branche reprise pausee ne référence plus les anciens helpers `getHubRemoteCommandId()` / `getHubRemoteExecutionId()`, qui étaient orphelins et pouvaient lever avant `remote_launch_readiness`.

Après preuves réelles commands `72` et `74`, la commande `launch_session` ne pilote plus directement la navigation vers la Remote historique. `command_status=completed` signifie seulement que le Master a traité la demande; le téléphone reste sur Hub Remote, déclenche un `control_poll` immédiat, puis laisse `routeFromControlState(payload.client_routing)` décider.

La source unique de routage Hub Remote -> Remote historique est désormais `control_poll.client_routing`: `client_joinable=true`, `master_context_available=true`, `remote_url`, `focused_session_id`, `execution_id` et `routing_reason`. Le chemin `command.result.remote_url -> window.location.replace(...)` est supprimé, tout comme le log command-driven `hub_remote_launch_remote_navigation`. `control_poll.master_present` décrit seulement la présence Hub Master; le Master historique de jeu publie son propre heartbeat runtime dès `organizer/runtime-ready`, toutes les 3 s, avec TTL serveur 12 s. La readiness ponctuelle reste disponible pour diagnostic/command status mais ne gate plus le routing. Si le contexte Master runtime n'est pas frais, Hub Remote reste affiché, continue son polling et peut naviguer automatiquement sur un poll ultérieur. Un garde `remoteRoutingStarted` rend la navigation idempotente seulement après la première navigation réelle.

La Remote historique Bingo marque aussi les messages WS `state` comme état live Hub Remote. Le quit volontaire Bingo conserve le chemin existant Remote -> Organizer -> `endSession(... serverLogout:true)` -> serveur Bingo -> `SESSION_ENDED`, mais ce terminal porte maintenant `reason=organizer_quit` / `terminal_reason=organizer_quit` et bypass le différé anti-terminal-précoce côté Remote pour revenir immédiatement vers Hub Remote. Quand le quit est demandé depuis la Remote Bingo Hub, la page arme aussi un retour Hub Remote court après `remote_quit_request`, annulé si le serveur renvoie `remoteQuitUnavailable`. En contexte Hub Player, ce seul `SESSION_ENDED` volontaire demande immédiatement `HubTransition.requestTerminalRedirect('player', ...)` vers `/hub/{token}/play`; hors Hub ou sans ce marqueur, le flow historique `player/sessionEnded` reste conservé. La fin naturelle Bingo garde son contrat séparé `phase_over next_phase=-1` -> fenêtre visuelle -> `HUB_SESSION_FINISHED`.

L'instrumentation `hub_remote_remote_ws`, active seulement en contexte Hub Remote et sans token, trace réception WS, état live, terminal accepté/différé, disponibilité retour Hub et déclenchement navigation. Le serveur Bingo trace aussi `hub_remote_bingo_terminal_delivery` sur le terminal volontaire, sans payload complet ni secret, avec présence registre Remote, état de socket et résultat d'envoi.

Fichiers de référence:
- `games/web/includes/canvas/core/boot_organizer.js`;
- `games/web/includes/canvas/play/play-ws.js`;
- `games/web/includes/canvas/remote/remote-ws.js`;
- `games/web/tests/hub_remote_contract_test.php`.
- `games/web/tests/hub_remote_polling_test.mjs`;
- `games/web/tests/hub_transition_remote_test.mjs`.

## Update 2026-08-24 - Hub Remote: convergence métier dynamique

Hub Remote conserve `control_poll` comme canal léger de présence, commandes et routage, mais récupère maintenant un snapshot métier séparé uniquement quand les révisions métier changent. Le snapshot `business_snapshot` réutilise `app_games_hub_render_context_get(...)` et ne renvoie que les données affichées par `/hub/{remote_token}/remote`: programme, statuts/actions, lots, Top 3 agrégé, compteur joueurs et révisions.

Le rendu initial reste produit côté serveur depuis le même snapshot, puis le JS met à jour les blocs Programme, Lots et Top joueurs sans `location.reload()`. Une erreur temporaire du snapshot ne coupe pas le polling de contrôle: un futur `control_poll` peut retenter la convergence.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`.

## Update 2026-08-24 - Hub Remote: revert borne vers baseline launch

Le patch non commit qui ajoutait `primary_presence` au routage Hub Remote a ete retire. Hub Remote revient au contrat de baseline: une commande `launch_session` terminee navigue vers la Remote historique quand l'URL Remote est sure et, pour un nouveau runtime, quand la readiness de l'execution courante est confirmee. Une reprise d'execution ouverte avec `readiness_required=false` n'attend plus une presence primary supplementaire.

Baseline Games conservee: `9c47a21cb21574d7f8ea7ef036cd0c33001d2596`, commit du `2026-08-24 11:28:43 +0200`. Ce commit garde les correctifs Remote historique du matin: quit volontaire via Master, tolerance temporaire `Session introuvable.`, differé des terminaux precoces et suppression des derniers appels `tryCloseTab()`.

Preuves logs conservees pour la suite: le lancement Bingo neuf command `14`, session `27241`, confirmait `hub_remote_game_readiness_confirmed` puis naviguait vers `/remote/bingo/...`. Les reprises `15/16/17` a `18:25-18:26` restent la baseline imparfaite connue: premier routage potentiellement trop tot, retour Hub Remote, second routage correct.

Le diagnostic `11:58` puis `12:13-12:14` a servi a classer le patch presence comme suspect: les heartbeats Master restaient hors cle runtime (`current_session_id=0`, `current_execution_id=''`, `runtime_ready_at=NULL`), donc la nouvelle condition pouvait empecher aussi le lancement neuf.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/includes/canvas/core/ws_effects.js`;
- `games/web/includes/canvas/core/boot_organizer.js`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `games/web/tests/hub_remote_contract_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`.

## Update 2026-08-24 - Remote historique: quit volontaire via Master

La Remote historique ne termine plus une session par disparition de page. Les événements navigateur `pagehide`, `beforeunload`, reload, background, coupure réseau ou fermeture d'onglet restent diagnostics et ne déclenchent aucun `quitGame`.

Le quit volontaire est maintenant explicite et passe par l'Organizer primaire. La Remote affiche la même confirmation que le Master (`Quitter le jeu ?`, `Déconnexion de l'organisateur et de tous les joueurs.`, boutons `Annuler` / `Quitter`), puis émet une demande `remoteQuitRequest` vers Quiz/Blind Test ou `remote_action=remote_quit_request` vers Bingo. L'Organizer reçoit cette demande et appelle le contrat Master existant `endSession({ reason:'Quitter le jeu', serverLogout:true })`. Le Master traite aussi directement un message WS brut `remoteQuitRequest`, afin que le quit reste effectif dès que le socket Master l'a reçu, même si un relais front secondaire ne l'a pas consommé.

En Hub, le Master revient vers Hub Master via le chemin existant, la Remote revient vers Hub Remote à la fin terminale et ne se reconnecte pas automatiquement à une session volontairement quittée. Hors Hub, le comportement reste celui d'un quit Organizer. Le contrat audio, `songStuck` et `organizer/runtime-ready` ne changent pas.

Pendant une relance démarrée depuis Hub Remote, la Remote historique Quiz/Blind Test tolère maintenant pendant une fenêtre courte les `registrationError` / `gameStateError` `Session introuvable.` émis avant que le runtime relancé ait réhydraté sa session WS: elle rejoue `registerOrganizer` + `remoteGameState` au lieu d'ouvrir immédiatement la popup fatale. Un signal terminal `SESSION_ENDED` / `HUB_SESSION_FINISHED` reçu dans les premières secondes du boot Hub Remote est aussi différé, puis annulé si un état live arrive, ce qui évite le rebond Hub Remote -> Remote -> Hub Remote -> Remote causé par un terminal stale. Les notices Remote ne référencent plus l'ancien helper supprimé `tryCloseTab()`.

Fichiers de référence:
- `games/web/remote_canvas.php`;
- `games/web/includes/canvas/remote/remote-ui.js`;
- `games/web/includes/canvas/remote/remote-ws.js`;
- `games/web/includes/canvas/core/ws_effects.js`;
- `games/web/includes/canvas/core/boot_organizer.js`;
- `quiz/web/server/actions/audioControl.js`;
- `blindtest/web/server/actions/audioControl.js`;
- `bingo.game/ws/bingo_server.js`.

## Update 2026-07-31 - Hub Canvas: reprise d'exécution ouverte et contexte Hub

Les Canvas Master et Player conservent maintenant le contexte Hub lors d'une reprise d'exécution runtime déjà ouverte. Le resolver Global `app_games_hub_execution_context_get_open(...)` ne rejette plus une exécution ouverte seulement parce que son événement `hub_execution_started` est antérieur au dernier timestamp de focus; le focus actif est validé par `games_hubs.active_session_id`.

Cette distinction est nécessaire depuis le routage readiness conditionnel: une reprise peut réactiver le focus Hub sur une exécution plus ancienne mais toujours ouverte. Dans ce cas, désactiver `hubOrganizer` ou `hubPresentation` faisait retomber les quits et fins naturelles sur les URLs historiques hors Hub. Les redirections terminales Master/Player repassent donc par `HubTransition` vers Hub Master/Play quand l'exécution ouverte existe.

Fichiers de référence:
- `games/web/organizer_canvas.php`;
- `games/web/player_canvas.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_remote_control_contract_test.php`.

## Update 2026-07-31 - Hub Remote: retour terminal de la Remote historique

Quand Hub Remote ouvre une Remote historique Quiz, Blind Test ou Bingo, l'URL porte maintenant un contexte de retour `hub_remote`. `remote_canvas.php` valide ce contexte côté serveur avec le token Remote dédié, vérifie que la session appartient au Hub du token, refuse tout retour différent de `/hub/{remote_token}/remote`, puis expose `AppConfig.hubRemoteReturn` au front.

`HubTransition` accepte désormais le rôle `remote` et allowliste `/hub/{token}/remote`. Les signaux terminaux reçus par la Remote historique (`HUB_SESSION_FINISHED` et `SESSION_ENDED`) demandent une redirection Hub Remote idempotente; un double signal ne provoque qu'une navigation. En contexte Hub Remote, `tryCloseTab()` ne fait plus `window.close`, `_self` ou `about:blank`; hors contexte Hub Remote, la fermeture historique reste inchangée.

Un reload tardif de la Remote historique après fin de session est traité côté `remote_canvas.php`: si le contexte Hub Remote est valide et que la session est terminée, la page revient directement vers le Hub Remote au lieu de rendre une Remote terminale vide.

Fichiers de référence:
- `games/web/remote_canvas.php`;
- `games/web/includes/canvas/core/hub_transition.js`;
- `games/web/includes/canvas/remote/remote-ws.js`;
- `games/web/includes/canvas/remote/remote-ui.js`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_transition_remote_test.mjs`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-07-31 - Hub Remote: readiness conditionnelle lancement/reprise

Hub Remote redirige vers `/remote/{game}/{session}` selon le type réel de transition renvoyé par Hub Master. Un lancement neuf ou une reprise qui recrée une exécution runtime porte `readiness_required=true`: la Remote attend alors `completed + readiness.ready` pour l'`execution_id` courant. Une reprise d'exécution déjà ouverte porte `readiness_required=false`: focus Hub, exécution ouverte et URL Remote validée suffisent.

L'Organizer chargé depuis `/master/{session}?hub_launch=1&hub_remote_command=...&hub_remote_execution=...` continue de marquer `remote_launch_readiness` après `organizer/runtime-ready`. Cette readiness reste corrélée à l'exécution et protège les arrivées Remote historiques Quiz/Blind Test/Bingo quand un nouveau runtime est créé. Elle n'est pas demandée à nouveau pour une exécution suspendue déjà joignable.

`control_poll.client_routing` porte le routage durable depuis le focus Hub, l'exécution ouverte, `client_joinable`, `readiness_required`, `readiness` et `routing_reason`. Les raisons attendues sont `launch_waiting_runtime`, `launch_ready`, `resume_ready`, `active_execution_ready` et `no_active_execution`. Les reloads et ouvertures tardives suivent cet état canonique sans dépendre de la commande locale.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/games_ajax.php`;
- `games/web/organizer_canvas.php`;
- `games/web/includes/canvas/core/boot_organizer.js`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-07-31 - Hub Remote Lot 2: bouton Lancer

Le bouton `Lancer` du Programme Hub Remote utilise le même état calendaire chaîne que Hub Master (`games_hub_date_state(...)`) avant d'appeler le helper partagé `games_hub_session_is_organizer_launchable(...)`. Une session prête ne doit donc plus être rendue avec `disabled` ni `data-command-type=""` à cause d'un tableau temporel casté en chaîne.

Côté navigateur, l'état des boutons est centralisé: attente initiale, Master absent ou commande active désactivent le lancement; seul le booléen JSON canonique `master_present === true`, sans commande `pending|claimed|processing`, permet l'action. Les commandes terminales ne réactivent pas le lancement si le dernier état Master reste absent.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`.

## Update 2026-07-31 - Hub Remote Lot 2: lancement via Hub Master

Hub Remote peut maintenant demander le lancement d'une partie du programme, mais ne lance jamais directement une session. Les boutons Remote déposent seulement une commande persistée `launch_session` avec `session_id`; aucune URL Organizer/Remote, type de jeu, handler ou payload runtime libre ne vient du téléphone.

Hub Master reste l'autorité d'exécution. Son heartbeat `remote_control_poll` claim atomiquement la commande, marque `processing`, appelle le contrat central existant `app_games_hub_session_launch_from_master(...)`, persiste `completed` ou `failed`, puis navigue automatiquement vers l'Organizer `/master/{session_token}?hub_launch=1` quand le lancement réel réussit. Le téléphone reste sur Hub Remote pendant `pending|claimed|processing` et ne rejoint la Remote historique `/remote/{game}/{session_token}` qu'après `completed` avec une URL résolue côté serveur.

La commande est commune à Quiz, Blind Test et Bingo. Aucune branche Bingo n'est ajoutée dans Hub Remote: la divergence connue reste encapsulée dans le contrat central et le routage Hub Play existant, où le focus Hub est l'autorité d'auto-join car Bingo peut rester `pending` jusqu'à la première phase. Le polling Remote Lot 1 reste borné à une seule boucle et un seul `control_poll` en vol.

Fichiers de référence:
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-07-31 - Hub Remote Lot 1

Games expose maintenant la route mobile `/hub/{remote_token}/remote`, distincte du token public Hub Master/Play. Le module `app_hub_remote_ajax.php` valide le token Remote côté Global, lie ensuite les requêtes AJAX à une session serveur et ne renvoie pas le secret dans les polls.

La télécommande Lot 1 reste read-only: programme, lots, Top 3 agrégé initial, état Master, et une commande non destructive `master_ping`. Aucun lancement réel, changement de runtime, navigation Master ou action session n'est exposé depuis Remote. Le polling Remote consomme `control_poll`, un endpoint O(1) Global, tandis que Hub Master publie sa présence via `remote_control_poll`, claim puis complète uniquement les commandes `master_ping`.

Le polling Remote est borné à une seule boucle active par page: timer enregistré/remplacé, un seul `control_poll` en vol, refresh immédiat coalescé au retour visible/`pageshow`/`online`, backoff réseau visible conservé et cleanup `pagehide` avec abort de la requête courante. Les réponses obsolètes ou annulées ne peuvent pas remplacer un état plus récent, et le bouton `master_ping` est verrouillé pendant la création ou le suivi d'une commande.

Fichiers de référence:
- `games/web/.htaccess`;
- `games/web/modules/app_hub_remote_ajax.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_remote_contract_test.php`;
- `games/web/tests/hub_remote_polling_test.mjs`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-07-31 - Hub Play probable avant-J et lancement digital

Hub Play reprend maintenant, avant le jour du Hub, le comportement historique des sessions: carte `INSCRIPTION` indiquant que la soirée ou l'événement n'est pas encore ouvert, puis bloc `COMPTE JOUEUR COTTON` juste dessous. Hub Play ne matérialise plus de présence probable avant J: aucune action AJAX `hub_probable_declare` / `hub_probable_cancel` n'est exposée côté joueur.

Les liens de connexion/création de compte joueur conservent le parcours EP historique avec `hub_account_action=probable` avant J; après connexion, Global renvoie vers la page EP Hub tant que la fenêtre est fermée, et c'est cette page qui permet de valider ou retirer la participation probable. Pendant la fenêtre ouverte, les mêmes liens restent sur `hub_account_action=join` et inscrivent directement dans `games_hubs_players` avant retour Hub Play. Les inscriptions libres par pseudo restent fermées avant J et le chemin `register_guest` conserve son garde historique de fenêtre de lancement.

Au lancement, Games consomme le contrat Global: une session papier continue de recevoir l'injection de tous les joueurs Hub actifs, tandis qu'une session numérique attend la présence réelle du joueur par Hub Play/QR/Canvas/reload/reprise manuelle. Les comportements de départ volontaire restent inchangés: `left` empêche l'auto-join dans la même partie et laisse l'action manuelle reprendre.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/includes/canvas/sql/2026-07-31_games_hubs_participations_probables.sql`;
- `games/web/tests/hub_probable_play_contract_test.php`;
- `play/web/ep/ep_signin.php`;
- `play/web/ep/ep_signup.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-07-31 - Hub Master: prédiagnostic léger du poste

Hub Master affiche maintenant, dans l'utilitaire fixe près du plein écran, un diagnostic léger du poste. Hors modale, l'affichage reste limité à une icône et une pastille colorée; le détail est ouvrable à la demande, relançable manuellement, et une alerte visible n'apparaît que si un check est bloquant. Dans la modale, la présentation reprend le principe du diagnostic historique: une synthèse claire, la raison principale, puis un ou deux conseils ciblés si nécessaire, sans tableau de bord technique par signal.

Le périmètre reste volontairement hors session et hors runtime. Les checks couvrent seulement le stockage navigateur (`localStorage` et `sessionStorage`), le signal `navigator.onLine`, le profil réseau optionnel `navigator.connection` quand le navigateur l'expose, puis deux probes HTTP cache-bustés vers un asset Cotton statique same-origin. Les seuils reprennent le budget réseau historique côté média: timeout `6000ms`, lenteur asset au-dessus de `2200ms`, minimum `2.0 Mb/s`. Le résultat le plus dégradé des mesures Cotton est conservé. Le profil réseau absent n'est pas une anomalie; un profil `3g`, plus lent ou `saveData` déclenche seulement une vigilance. Le premier diagnostic attend brièvement la disponibilité du DOM, puis des recontrôles bornés sont planifiés après chargement complet jusqu'à 9 secondes si l'état reste vert. `pageshow` ne déclenche plus de diagnostic sur une première ouverture normale; il sert seulement aux pages restaurées ou aux résultats déjà périmés.

Le module ne réutilise pas le diagnostic historique Canvas de lancement: pas de WebSocket, pas de `session_meta_get`, pas de lien joueur/QR, pas de catalogue YouTube, pas de Bus/GameStore et aucune modification de `prelaunch_check.js`. Le bloc de refresh partiel `prizes` est borné au contenu Lots/QR afin que l'utilitaire fixe, le bouton de diagnostic et le plein écran ne soient pas remplacés lors d'un rafraîchissement Master.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `games/web/tests/hub_session_settings_dom_test.mjs`.

## Update 2026-07-31 - Bingo Hub: transition finale avant retour Hub

En fin naturelle Bingo dans un Hub, l'overlay final de victoire reste maintenant visible avant le retour au Hub. `HubTransition` expose une transition finale non persistée, par rôle, armée uniquement quand le payload Bingo annonce `next_phase=-1`; elle attend le montage de l'overlay, conserve la durée historique de 8 secondes, puis exécute la redirection Hub demandée. Une deadline de 10 secondes force le retour si un signal attendu manque.

Le périmètre est limité aux parcours Hub Bingo: Master numérique, Player numérique et Master papier. Le Player papier reste exclu, car il n'a pas d'écran joueur numérique à préserver. Côté Player numérique, le handler `phase_over` arme directement la même transition avant `HUB_SESSION_FINISHED`, car il ne passe pas par l'overlay organizer `bingo_ui.js`. Pendant la fenêtre finale, `HubTransition` laisse aussi l'UI historique sous-jacente se rendre normalement pour éviter une page Master vide si l'overlay est masqué ou en cours de retrait. Les résultats, scores, mappings Hub, focus runtime, contrats Global et serveurs WS ne changent pas; les signaux terminaux existants sont seulement différés côté front pendant la fenêtre visuelle active.

Fichiers de référence:
- `games/web/includes/canvas/core/hub_transition.js`;
- `games/web/includes/canvas/core/games/bingo_ui.js`;
- `games/web/includes/canvas/core/ws_effects.js`;
- `games/web/includes/canvas/play/play-ws.js`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-31 - Hub Play wording Bingo et chip état

Les derniers résultats Bingo gagnants utilisent maintenant un titre commun `Bravo ! 🎉`. Le sous-titre dépend de la meilleure phase gagnée déjà résolue par le résultat canonique: `Tu remporte le Bingo.`, `Tu remporte la Double ligne.` ou `Tu remporte la Ligne.`. Le cas sans phase gagnée reste `Merci d’avoir joué !` puis `On t’attend pour la prochaine !`.

La chip d'état du header Hub Play ne dépend plus seulement du libellé initial de page. `renderPersonalState(...)` passe par `personalStatePillLabelFor(...)`: attente -> `En attente`, partie en cours -> `En cours`, départ/reprise -> `Partie quittée`, soirée/événement terminé -> `Terminé`. Quand une partie est ajoutée depuis le Dashboard Pro après des parties terminées ou suspendues, le polling Play peut donc faire repasser la chip de `Terminé` à `En attente` avec le bloc d'état.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `games/web/tests/hub_session_settings_dom_test.mjs`.

## Update 2026-07-31 - Hub Play lots dynamiques

Hub Play ne dépend plus uniquement du HTML initial pour afficher les lots. Les actions joueur déjà pollées (`current_player` au chargement puis `active_launched_session` pendant l'attente) chargent déjà le contexte `prizes`; elles exposent maintenant un payload borné `hub_prizes` contenant les trois lignes visibles du bloc Lots.

Le front Play ajoute `renderHubPrizes(...)`, qui remplace uniquement les lignes `.hub-player-prize` dans le bloc existant. Le titre contextualisé `Lots de la soirée` / `Lots de l’événement`, l'ordre des cartes et les règles d'affichage des lots restent inchangés. Aucun nouveau timer n'est ajouté: la mise à jour suit le polling Play existant, donc un lot renseigné depuis le Dashboard Pro après connexion joueur apparaît sans reload de la page Hub Play.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `games/web/tests/hub_session_settings_dom_test.mjs`.

## Update 2026-07-31 - Hub Play dernier résultat et médaille Master

La carte Hub Play `Dernier résultat` garde le même titre de section que les autres cartes principales, mais son contenu est maintenant hiérarchisé. La ligne `jeu · thématique` reste une méta secondaire issue des libellés déjà exposés par le contexte de session, tandis que le titre/sous-titre de performance devient le point focal. Les lots, badges génériques, score et pastille de rang ne sont pas réintroduits dans cette carte.

Pour Bingo, la copie visible s'appuie sur la meilleure phase gagnée déjà retenue dans `last_result`: `Bingo ! 🎉`, `Double ligne ! 🎉` ou `Ligne ! 🎉`, puis `Tu remportes la phase ...`. Aucun classement chiffré n'est ajouté pour Bingo; l'éligibilité photo continue d'utiliser le rang structuré du podium canonique.

Sur le Hub Master, la médaille des podiums de session avec photo n'est plus placée dans la zone de contenu recadrée. La carte avec photo garde seulement l'image dans un conteneur `overflow: hidden` avec coins arrondis; la médaille est enfant direct de la carte, au-dessus de l'image, avec `z-index` dédié. Les photos, le resolver Hub, les rangs, les phases Bingo, la taille globale du podium et le podium agrégé ne changent pas.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `games/web/tests/hub_session_settings_dom_test.mjs`.

## Update 2026-07-31 - Hub Play photo podium Bingo

Hub Play reprend maintenant le rang structuré déjà exposé par le podium canonique Bingo. Côté Global, les résultats Bingo sont produits depuis `bingo_phase_winners`: la phase runtime est convertie en ligne de podium portant `rank` numérique et `phase_label`, puis Hub Master consomme ces lignes. L'écart venait de la projection Play, qui reconnaissait le gagnant Bingo mais ne gardait que `phase_label`; le contrôle photo refusait alors le résultat faute de `rank` 1..3.

La projection Play sélectionne désormais, pour l'identité Hub courante, la meilleure ligne de podium Bingo par `rank` numérique entre 1 et 3. S'il n'existe aucune phase gagnée structurée Top 3, aucun module photo n'est exposé. Si plusieurs phases ont été gagnées par la même identité, une seule ligne est retenue: la meilleure phase. Les libellés `Bingo !`, `Double ligne remportée` et `Ligne remportée` restent de la copie visible; ils ne pilotent pas l'éligibilité photo.

Le reste du contrat photo ne change pas: l'accès historique prouve toujours session/résultat Top 3, l'upload reste rattaché à la photo active de `games_hubs_players`, et Blind Test / Quiz conservent leur projection existante.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`.

## Update 2026-07-31 - Hub Play UI auto-routing et photo compacte

Hub Play garde les contrats runtime et photo existants, mais harmonise l'affichage joueur. Les cartes suivent l'ordre état identité, dernier résultat, classement général, lots, puis sortie du Hub. Les titres `Dernier résultat`, `Classement général` et `Lots de la soirée` / `Lots de l’événement` utilisent le même style de titre de carte en casse normale.

Le premier bloc explicite l'auto-routing sans ajouter d'action: `Prêt à jouer 🎉` indique de rester sur la page pour rejoindre automatiquement la prochaine partie lancée; entre deux sessions, le joueur voit qu'il rejoindra automatiquement la prochaine partie dès son lancement. Les états `left` / `resume_available` conservent leur wording spécifique et le CTA manuel `Rejoindre à nouveau`; ils ne reprennent pas le message générique d'auto-connexion.

Quand une photo podium active existe, Hub Play n'affiche plus la photo en grand. Le module passe en sous-zone compacte: copie contextualisée soirée/événement, bouton `Remplacer la photo` et miniature paysage à ratio fixe. La grande prévisualisation reste utilisée uniquement après sélection d'une nouvelle photo, avec consentement et annulation possibles; après succès AJAX, la sous-zone compacte est réactualisée localement.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_dom_test.mjs`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-31 - Hub photo podium active

Les uploads photo depuis Hub Play ne créent plus de photo de podium différente par session. Le backend part toujours du garde-fou historique (`app_session_results_player_podium_photo_access_get(...)`) pour prouver que la session appartient au Hub, que l'identité connectée correspond au résultat et que le rang est 1, 2 ou 3, puis écrit une photo active unique sur l'identité `games_hubs_players`.

La migration minimale `games/web/includes/canvas/sql/2026-07-31_games_hubs_players_active_podium_photo.sql` ajoute `hub_photo_media_id`, `hub_photo_game_key`, `hub_photo_source` et `hub_photo_updated_at` à `games_hubs_players`. Elle est nécessaire car le stockage historique utilise `medias_images.id_module = id_championnat_session` avec un crédit rang/ligne podium; il ne peut donc pas garantir l'unicité par identité Hub sans recopie par session. Aucun backfill n'est fait: les anciennes photos de session restent disponibles hors Hub.

La lecture Hub utilise le resolver actif Global: podium agrégé, classement général si une surface affiche les photos, podiums de sessions terminées dans Hub Master et Hub Play après upload résolvent `photo_src` depuis `games_hubs_players`. Le résultat canonique de session reste l'autorité pour rang, score, égalités et libellés; seule la photo est enrichie depuis la couche Hub.

Pour éviter un refresh manuel du Hub Master après upload Hub Play, l'écriture photo met à jour la révision du Hub via `games_hubs.date_maj`. Le Master conserve son refresh partiel existant: il vérifie la révision visible à intervalle court, puis remplace Programme/Lots/Central uniquement quand la révision change. Le bloc central inclut les podiums de session et le podium agrégé.

Fichiers de référence:
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/includes/canvas/sql/2026-07-31_games_hubs_players_active_podium_photo.sql`;
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`.

## Update 2026-07-30 - Hub Play: UI fusion et classement Global

Hub Play fusionne désormais l'ancien bloc `Ton profil` avec l'état courant du joueur dans un panneau compact centré sur le pseudo et une seule formulation d'état. La reprise après départ volontaire reste une action manuelle explicite dans ce panneau; le bloc séparé `Reprise` n'est plus rendu. Les parcours d'auto-redirection et de réinjection automatique vers une partie focus restent inchangés hors cas `status=left`.

Les actions Play `current_player` et `active_launched_session` chargent maintenant le contexte Global Hub léger via `app_games_hub_render_context_get(...)` / `app_games_hub_aggregate_ranking_context_get(...)`. Le classement général Play consomme uniquement `aggregate_context.aggregate_ranking`, sélectionne Top 3, joueur courant et voisins pour l'affichage, et ne recalcule ni score, ni rang, ni tie-breaker côté Games.

Le dernier résultat joueur s'aligne sur la copie canonique de fin de partie portée par `games/web/includes/canvas/play/play-ui.js::renderEndCard()`, tout en conservant la source résultat de session déjà exposée au Hub. La carte affiche le jeu et la thématique séparément, sans badge podium, score, rang en pastille ni répétition de lot; les lots restent uniquement dans le bloc Hub `Lots de la soirée` / `Lots de l’événement`.

Le module photo podium Hub Play est une adaptation bornée du contrat historique de podium de session (`player_podium_photo_access_get` / `player_podium_photo_upload`). Il s'affiche seulement quand le dernier résultat de l'identité Hub est rang 1, 2 ou 3, réutilise les contrôles existants de consentement/upload et délègue désormais l'écriture au contrat photo active Hub décrit dans l'entrée du 2026-07-31.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/includes/canvas/play/play-ui.js`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`.

## Update 2026-07-30 - Hub Master: contexte Global Hub léger

Sur un reload complet Hub Master, Games appelle désormais `app_games_hub_render_context_get(...)` avec la ligne Hub explicite et les sessions déjà chargées. Le classement général et le podium agrégé continuent de consommer uniquement `aggregate_context.aggregate_ranking`; Games ne lit pas `app_games_hub_players_stats_ranking_get(...)`, ne trie pas et ne décide pas du fallback.

Global/Hubs décide de la source: projection `games_hubs_players.stats_*` saine -> `aggregate_ranking_source=hub_persistent_stats`; projection absente, dirty, en erreur, incomplète ou illisible -> `aggregate_ranking_source=historical_fallback` avec raison bornée. Le helper historique client/période n'est plus appelé sur le chemin nominal Hub Master.

Le profil dev-only `hub_master_full_reload_profile` mesure toujours le reload complet. La phase `global_hub_context` remplace l'ancienne phase `historical_global_context`; les compteurs `aggregate_source`, `aggregate_fallback_reason`, `aggregate_persistent_read_ms`, `aggregate_historical_fallback_ms` et `aggregate_historical_fallback_used` permettent de vérifier que le coût historique Global disparaît quand la projection est saine.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_context_fast_path_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-07-30 - Hub Master: instrumentation reload complet

Le reload complet du Hub Master dispose maintenant d'un profil dev-only borné `hub_master_full_reload_profile`. Il se déclenche uniquement sur un rendu Master sans action AJAX, en environnement dev détecté par `$conf['server']`, `APP_ENV` ou host dev, et journalise des durées par phase sans token, cookie, IP, user-agent ni nom joueur.

Le profil distingue notamment bootstrap Hub, client, programme, branding, lots, événements de complétion, résultats des sessions terminées, contexte historique Global, projection de classement, podium agrégé, joueurs live et assemblage final. Cette instrumentation ne bascule pas encore le rendu sur `games_hubs_players.stats_*`: la source historique reste l'autorité tant que les mesures dev n'ont pas confirmé que `historical_global_context` explique la lenteur.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-07-30 - Hub: rebuild stats players sur fin naturelle

Quand une session Hub se termine naturellement depuis l'organizer Canvas, `hub_session_natural_ended` déclenche maintenant le rebuild persistant des stats joueurs Hub après preuve métier: session Hub, non démo, résultats terminaux écrits, clear focus gardé, puis `hub_execution_completed` idempotent. Le même chemin s'applique aux récupérations tardives après focus déjà vidé et aux replays `already_completed`.

Le rebuild consomme le service Global existant `app_games_hub_players_stats_rebuild(...)` en mode `dry_run=false, write=true`. La réponse du callback Canvas reste centrée sur la transition Hub et ne remonte pas d'erreur de rebuild aux moteurs; les diagnostics sont portés par les logs `hub_players_stats_rebuild_*` et par `app_games_hub_players_stats_mark_dirty(...)` si le rebuild échoue ou signale des résultats runtime incomplets.

Fichiers de référence:
- `games/web/includes/canvas/php/boot_lib.php`;
- `games/web/tests/hub_natural_end_stats_rebuild_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_players_stats_projection_contract_test.php`.

## Update 2026-07-29 - Canvas runtime: réhydratation compteurs actifs

Pendant une session numérique active, `canvas_display.js` ne doit pas demander les joueurs inactifs lors des réhydratations de compteur/roster déclenchées par `session/init`, `game/started`, `game/paused` ou le retour de la vue mobile vers organizer. Ces chemins appellent `players_get` avec le contrat par défaut du bridge: seuls les joueurs actifs sont retournés par les endpoints PHP.

La capacité historique reste conservée: `includeInactive=1` est encore possible pour les contextes terminaux ou historiques. La décision est centralisée côté front et s'appuie sur l'état terminal (`Partie terminée` / `Terminé`) ou les phases Bingo terminales (`-1`, `4`, `>5`), sans considérer `Pause` comme terminal.

Ce patch ne modifie ni les endpoints `players_get`, ni les handlers `deactivate_player`, ni les WebSockets. Les résultats finaux, podiums et classements historiques peuvent continuer à réhydrater les participants passés quand le contexte est terminal.

Fichiers de référence:
- `games/web/includes/canvas/core/canvas_display.js`;
- `games/web/tests/hub_session_settings_dom_test.mjs`.

## Update 2026-07-29 - Hub: contextes allégés et fast-paths AJAX

Le contexte Hub peut maintenant être chargé avec des options explicites. `games_hub_get_context_from_request($options)` pilote séparément client, sessions, branding, lots, événements de complétion, résultats de sessions, agrégat, temporalité et jeux d'ajout rapide. Le contexte complet reste le fallback des rendus qui en ont besoin.

Les actions AJAX légères passent par `games_hub_get_context_for_action_from_request(...)`, qui évite de reconstruire l'agrégat et les résultats complets quand l'action ne les consomme pas. Les profils couvrent notamment `players_count`, `current_player`, `active_launched_session`, `preparation_revision`, `session_settings_*`, `quick_session_create`, `manual_join_session`, `leave_session`, `launch_session` et `presentation_mode_set`.

Hub Play utilise un contexte initial dédié via `games_hub_get_initial_play_context_from_request()`: Hub, client, sessions, branding, lots et temporalité restent disponibles, tandis que les événements de complétion, les résultats complets, l'agrégat Master et les jeux quick-add ne sont pas chargés au GET initial joueur.

Le lancement Master retire le calcul préalable du compteur de joueurs actifs avant dispatch. Si Global renvoie `_hub_launch_profile`, Games complète la mesure de publication, journalise `hub_launch_session_profile`, puis supprime cette clé privée de la réponse JSON.

Ces chemins améliorent le coût des POST répétés et du premier affichage Play, mais introduisent un contrat de contexte partiel: tout nouveau handler Hub doit déclarer les données dont il dépend au lieu de supposer le contexte complet.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/modules/app_hub_play_ajax.php`;
- `games/web/modules/app_hub_master_ajax.php`;
- `games/web/tests/hub_context_fast_path_test.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-29 - Hub Play: clôture reprise QR Player

L'instrumentation navigateur temporaire de reprise QR Hub Player est retirée des sources runtime. Les correctifs fonctionnels restent en place: masquage anti-flash `data-hub-transition-pending="player_auto_restore"`, release/fallback `HubTransition`, priorité de l'auto-restore Hub sur la reprise locale, fast path serveur QR/session, reprise directe Bingo, retour Hub Play canonique et départ volontaire confirmé par `leave_session`.

Le polling de présentation Hub côté Player Canvas ne démarre plus au chargement module: `play-ws.js` attend maintenant `player/ready`, conserve les contrôles focus/pageshow, et utilise un intervalle fallback de 15 secondes au lieu de 4 secondes. Cela réduit les appels résiduels à `/hub/{token}/play?action=active_launched_session` sans supprimer la résilience si le WS ou l'état de présentation manque un changement.

Le 500 isolé observé sur `active_launched_session` venait du bootstrap `games_ajax.php` avant exécution du code Hub, avec `$conf` manquant malgré des requêtes identiques en 200 avant et après. Le bridge ajoute seulement un diagnostic structuré `[games_bootstrap][config_missing]` avec contexte non sensible et chemin Hub tronqué, puis conserve la même exception; aucune valeur `$conf` par défaut ne masque l'erreur.

Fichiers de référence:
- `games/web/games_ajax.php`;
- `games/web/player_canvas.php`;
- `games/web/includes/canvas/core/hub_transition.js`;
- `games/web/includes/canvas/play/play-ws.js`;
- `games/web/includes/canvas/play/play-ui.js`;
- `games/web/includes/canvas/play/register.js`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-29 - Hub Play: retour après départ volontaire Player

Quand un joueur quitte volontairement une session numérique lancée depuis Hub Play, le Player Canvas attend désormais la confirmation JSON `ok:true` du POST Hub `leave_session` avant de naviguer. Cette action conserve l'identité Hub et les cookies, marque le mapping Hub/session en `left` côté serveur, écrit `leftVoluntarily_{sessionId}=1` côté navigateur, puis redirige en `location.replace(...)` vers l'URL canonique `/hub/{hub_token}/play` fournie par le serveur dans `hubAutoPlayer.hubPlayUrl`.

Hub Play reste responsable du non-réinject automatique: après un mapping `left`, `active_launched_session` expose l'accès sans `play_url` automatique et propose la reprise manuelle quand elle est autorisée. Les départs volontaires Hub ne passent plus par le nettoyage historique complet du Player Canvas; les parcours non Hub le conservent. Les fins orchestrées par l'organisateur continuent de préserver le mapping/grille sans poser le marqueur de départ volontaire.

Fichiers de référence:
- `games/web/player_canvas.php`;
- `games/web/includes/canvas/play/play-ui.js`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-29 - Hub Play: reprise rapide QR session Player numérique

Quand un joueur rouvre le QR direct d'une session numérique Hub après fermeture involontaire, `player_canvas.php` peut désormais réutiliser immédiatement le mapping Hub/session déjà complet au lieu de refaire l'ensure runtime canonique. Ce fast path est borné aux preuves serveur déjà présentes: Hub, joueur Hub, session Hub et exécution ouverte, mapping `active` sur la session courante, participation runtime existante, participant canonique `p:*`, session non papier et pas de reprise manuelle d'un joueur volontairement parti. Les mappings incomplets, `left`, papier, manuels ou non canoniques continuent de passer par `app_games_hub_runtime_participation_ensure(...)` ou par le parcours historique.

Côté Bingo, `register.js` tente une reprise directe avant le submit `player_register`: identité Hub persistée localement, hydratation de grille via `grid_hydrate`, assignation `grid_assign` seulement si le serveur confirme `GRID_NOT_FOUND`, puis état inscrit et `player/ready`. En cas d'échec, le flux retombe sur le submit historique afin de conserver les gardes existantes. Quiz et Blind Test gardent leur auto-register direct déjà plus court.

Le périmètre reste limité au Player Canvas numérique issu de Hub Play/session QR: aucun changement DB, règle de participation, papier, départ volontaire, Hub Remote, scores, rangs, lots, WebSocket ou moteur runtime.

Fichiers de référence:
- `games/web/player_canvas.php`;
- `games/web/includes/canvas/play/register.js`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-29 - Hub Play: suppression du flash lobby avant partie numérique

Quand Hub Play route un joueur Hub valide vers une session numérique déjà focus, `player_canvas.php` arme désormais un état `data-hub-transition-pending="player_auto_restore"` uniquement après preuve serveur complète: Hub actif, session rattachée, exécution ouverte, mapping actif, participation runtime numérique et identité `p:*` persistée. Le CSS critique masque le lobby historique pendant ce bootstrap afin d'éviter l'affichage transitoire du formulaire/register avant l'entrée dans la partie.

`register.js` relâche ce masque seulement après finalisation de l'auto-register et émission `player/ready`, y compris pour Bingo après attribution/restauration de grille. Les fallbacks explicites réaffichent l'UI historique en cas de contexte client invalide, mapping manquant, départ volontaire, payload incohérent, erreur d'auto-register ou timeout borné. `hub_transition.js` conserve `releaseLaunch()` pour Hub Master et ajoute un helper générique `releasePending(...)` / `armPendingTimeout(...)` réutilisé par le rôle `player_auto_restore`.

Le périmètre reste volontairement limité au parcours Player Canvas numérique issu de Hub Play: aucun changement DB, règle de participation, papier, Hub Remote, UI Hub Play globale, scores, rangs, lots ou moteur runtime.

Fichiers de référence:
- `games/web/player_canvas.php`;
- `games/web/includes/canvas/core/hub_transition.js`;
- `games/web/includes/canvas/play/register.js`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-28 - Hub Master: retrait preview photos podium agrégé

Le mode local/dev `preview_podium_photos=all|none|partial|broken` du podium agrégé Hub Master est retiré après validation visuelle. Les trois fixtures temporaires `photo-1.jpg`, `photo-2.jpg`, `photo-3.jpg` ne sont plus utilisées ni conservées dans `games/web/includes/canvas/images/hub/`.

Le rendu continue de consommer les photos réelles exposées par le modèle via `photo_src` / `photo_url`. Les comportements validés restent inchangés: cercle photo `object-fit: cover`, fallback texte quand aucune photo n'existe, retour propre au fallback si une image réelle échoue, nom sur plaque uniquement quand une photo occupe le cercle, statistiques principales et notes de participation conditionnelles.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-28 - Hub Master: rollback plein écran et podiums de session réduits

La tentative de continuité plein écran Hub Master -> organizer est annulée. Le code ne transporte plus d'intention via `sessionStorage`: les clés `hub_fullscreen_intent` et `hub_fullscreen_return_intent`, le writer Hub, le reader organizer, le TTL, les helpers JS dédiés, le hook de boot et le CTA `Continuer en plein écran` sont retirés.

Les contrôles historiques de plein écran manuel restent l'autorité côté navigateur: bouton Hub Master, bouton organizer `fullscreenBtn`, API native `requestFullscreen` / `exitFullscreen` et synchronisation `fullscreenchange`. Les parcours de lancement ne changent pas: `hub_launch=1`, autostart organizer, `HubTransition`, ainsi que les routes `Lancer`, `Relancer` et `Reprendre` restent inchangés.

La limite technique reste celle du Fullscreen API: le plein écran appartient au document courant et ne peut pas être garanti pendant une navigation vers un autre document. Une piste future éventuelle serait de permettre à Hub Remote de signaler au Master qu'un passage en plein écran est souhaité; toute activation effective restera soumise aux permissions et à une interaction utilisateur sur le navigateur Master.

Le podium de session central du Hub Master garde ses marqueurs visuels sobres: cartes de rang teintées or/argent/bronze, médaille ronde non focalisable, ordre visuel `2-1-3`, rang 1 légèrement dominant, nom principal et score secondaire. Les cartes sont toutefois réduites pour laisser respirer le titre: hauteur normale `82%` au lieu de `94%`, rang 1 `90%` au lieu de `100%`, photo plafonnée à `146px` au lieu de `168px`, médaille plafonnée à `47px` au lieu de `52px`, et espace titre/podium `clamp(20px, 4.5cqh, 34px)`. Les données ne changent pas: rangs, égalités, scores, noms joueur/équipe, source canonique des résultats, cap à trois cartes, sélection centrale et podium agrégé restent inchangés.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/organizer_canvas.php`;
- `games/web/includes/canvas/core/canvas_display.js`;
- `games/web/includes/canvas/core/boot_organizer.js`;
- `games/web/tests/hub_session_settings_test.php`;
- `games/web/tests/hub_session_settings_dom_test.mjs`.

## Update 2026-07-28 - Hub Master: podium agrégé Bravo et photos réelles

Le podium agrégé plein écran du Hub Master garde le bouton d'action stable `Podium`, mais la modale devient un écran de célébration avec le header `Bravo !` et le sous-titre court `Podium général après X partie(s)`, sans `jouée(s)`.

Le rendu accepte désormais une photo optionnelle par entrée via `photo_src` et `photo_url` dans la projection interne du podium, sans nouveau stockage, migration DB, récupération Hub Play ni modification des scores/rangs/lots/memberships. Avec photo, le cercle contient seulement l'image ronde cadrée `object-fit: cover`; le nom passe sur la plaque avec la statistique principale. Sans photo, le nom reste dans le cercle en fallback texte. Une erreur de chargement image bascule une seule fois vers ce fallback et ne laisse pas d'icône cassée.

La photo est clippée par un disque interne dédié: le wrapper de portrait reste non clippant pour conserver la médaille au premier plan, tandis que le disque `overflow:hidden` porte l'image absolue `inset:0`, `width:100%`, `height:100%`, `object-fit:cover`, `object-position:center` et `border-radius:50%`. Les plaques du podium général ne rendent plus les lots; ceux-ci restent disponibles dans le modèle et dans la colonne `Lots de la soirée / de l’événement`. Les plaques hybrides ont un `padding-inline` resserré, et le bouton utilitaire `Podium` est masqué pendant l'overlay afin de laisser la fermeture au CTA intégré à l'image.

La plaque affiche en priorité `victoire(s) · podium(s)` depuis `wins` et `display_podium_count`. Une note `partie(s)` n'apparaît qu'en ligne secondaire discrète quand au moins deux entrées Top 3 ont les mêmes victoires/podiums, le même score canonique et des compteurs de participations différents; cela reflète le départage Global `score` puis `count` sans recalculer ni modifier le classement.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `games/web/tests/hub_session_settings_dom_test.mjs`.

## Update 2026-07-28 - Hub Master: selection automatique Programme et ajout rapide

Le Hub Master distingue quatre intentions de presentation du carrousel Programme: selection manuelle restauree pendant un refresh, selection evenementielle apres fin naturelle, selection explicite issue d'un ajout rapide, et fallback automatique general.

L'ordre visuel du carrousel Master est fixe et canonique: les cartes metier sont rendues par `championnats_sessions.position` croissante, puis `id` et index source uniquement comme garde deterministe. Les statuts runtime, horaires, dates de fin, ordre reel de lancement, focus et selection ne participent pas au tri. La carte `Ajouter une partie` ne fait pas partie du tri metier et reste toujours apres toutes les sessions.

La resolution automatique generale ne depend pas de l'horaire. Elle choisit d'abord une session portant un focus runtime Hub confirme, puis la premiere session prete/non jouee selon la position persistante du Programme, puis la premiere session suspendue reprenable selon cette meme position, puis la derniere session terminee pertinente uniquement s'il ne reste aucune session prete ou suspendue. La carte `Ajouter une partie` reste reservee au cas sans session metier.

La fin naturelle d'une session est un contexte de retour distinct du fallback general. Quand le GET Master revient du canvas organisateur `/master/...hub_launch=1`, le rendu serveur utilise les `completion_events` canoniques du Hub avant les pending pour selectionner la session terminee et son podium. Aucun parametre de presentation n'est requis dans l'URL, aucun etat one-shot n'est stocke sur le Hub, et un reload manuel sans referrer canvas revient a la resolution automatique generale. Le clear normal du focus Hub ne recree pas `active_session_id` et ne route pas Hub Play vers la session terminee.

La Remote de jeu ne redirige pas vers Hub Master lors de `HUB_SESSION_FINISHED`. Elle garde un etat termine local; le retour cible Remote sera le futur Hub Remote, pas une seconde page Master.

Un reload navigateur ulterieur ne porte plus ce marqueur one-shot: la resolution automatique generale redevient donc applicable et peut selectionner la premiere session prete/non jouee. Dans la page courante, l'intention `natural_completion` peut etre remplacee uniquement par un clic manuel, un lancement/reprise creant un nouveau focus, l'ajout rapide d'une nouvelle session, l'ouverture du podium agrege ou la disparition de la carte.

Apres `quick_session_create`, le Master ferme la modale sur succes serveur confirme, consomme l'identifiant canonique renvoye dans `session_ids`, force le refresh partiel avec une intention `preferredSessionId`, quitte un eventuel mode `hub_podium` pour revenir a `session`, selectionne la nouvelle carte dans le DOM reconstruit selon l'ordre Programme et la fait defiler via le carrousel existant. Ce flux ne cree pas de focus runtime, ne lance pas la session et ne route pas les joueurs.

La modale d'ajout rapide reste ouverte et bloquee jusqu'a confirmation visuelle de cette nouvelle carte: carte presente dans le carrousel, placee avant `Ajouter une partie`, selectionnee, et scroll de selection declenche par le carrousel. Une creation serveur reussie mais non visible dans le DOM est traitee comme une erreur de synchronisation: la modale reste ouverte, n'effectue pas de nouvel appel de creation et propose seulement de relancer le refresh d'affichage. Aucun fallback `location.reload()` n'est utilise dans ce cycle.

Fichiers de reference:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `games/web/tests/hub_session_settings_dom_test.mjs`.

## Update 2026-07-28 - Hub Master: termine mais reactivable

Le Hub Master distingue maintenant l'etat courant du programme et l'autorisation d'ajout rapide. Quand toutes les sessions membres courantes sont terminees, le programme peut afficher `Termine`; cela ne ferme pas le Hub tant que la fenetre serveur `J+1 12:00:00` Europe/Paris reste ouverte.

La carte Programme `Ajouter une partie`, le bouton/modal d'ajout rapide et le dialogue associe sont donc pilotes par `hub_temporal_state.launch_window_open`. Apres cutoff, la carte n'est plus rendue et la garde serveur Master renvoie `409` avec `HUB_QUICK_ADD_WINDOW_EXPIRED` avant toute creation. Avant cutoff, une session peut etre ajoutee meme si les sessions existantes sont toutes closes.

Source des sessions: le Hub Master conserve `app_games_hub_sessions_get(...)` / `games_hubs_sessions` comme autorite de rattachement. Aucun changement sur les podiums, resultats, scores, rangs, focus, joueurs, lots ou memberships existants.

Fichiers de reference:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`.

## Update 2026-07-28 - Hub Master/Play: fenetre J+1 midi serveur

Le Hub Master et le Hub Play consomment la temporalite serveur issue de Global: une date Hub reste ouverte jusqu'a `J+1 12:00:00` exclu dans le fuseau plateforme explicite `Europe/Paris`, centralise par `app_platform_business_timezone()`. Le navigateur ne decide plus l'autorisation avec son fuseau local; il ne fait qu'afficher ou relayer la meta serveur.

`games_hub_date_state(...)` mappe maintenant l'etat temporel canonique: une date d'hier avant midi local reste exploitable (`open`/presentation active) au lieu d'etre archivee a minuit. Le contexte Hub expose `hub_temporal_state`; le rendu porte aussi `data-hub-temporal-state`, `data-hub-cutoff-at` et `data-hub-timezone`.

Les actions sensibles restent gardees cote serveur. Le POST Master `hub_launch` passe par `app_games_hub_session_launch_from_master(...)`, qui refuse une nouvelle session apres coupure mais autorise une reprise prouvee. Cote Play, `register_guest` refuse les nouvelles inscriptions apres coupure sauf si une session Hub deja engagee reste ouverte dans le contexte. Les podiums/resultats de sessions individuelles ne sont pas modifies.

Canvas expose dans `ServerSessionMeta` les champs `timezone`, `cutoff_at`, `launch_window_open` et `temporal_state` via `canvas_session_temporal_meta(...)`. `boot_organizer.js` et `prelaunch_check.js` utilisent cette autorite serveur en priorite; le fallback local reste `Europe/Paris` et non le fuseau navigateur.

Fichiers de reference:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/includes/canvas/php/boot_lib.php`;
- `games/web/includes/canvas/php/bingo_adapter_glue.php`;
- `games/web/includes/canvas/php/blindtest_adapter_glue.php`;
- `games/web/includes/canvas/php/quiz_adapter_glue.php`;
- `games/web/includes/canvas/core/boot_organizer.js`;
- `games/web/includes/canvas/core/prelaunch_check.js`;
- `games/web/player_canvas.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-28 — Hub agrégat: podiums affichés hors victoires

Le Hub Master consomme toujours `aggregate_ranking` depuis Global et ne recalcule ni le score, ni le tri, ni les rangs denses. Pour les statistiques visibles du classement général et du podium agrégé, Games utilise maintenant le champ canonique `display_podium_count`.

Contrat payload: `podiums` et `podiums_count` excluent les victoires; `display_podium_count` porte la même valeur visible, et `top3_count` reste le diagnostic Top 3 si nécessaire. La presentation masque les segments a zero et conserve l'ordre `victoires · podiums · parties` en libellé long, avec `part.` conservé en compact. Exemples: `wins=1, display_podium_count=0, participations=1` affiche `1 vict. · 1 part.`; `wins=0, display_podium_count=1, participations=1` affiche `1 pod. · 1 part.`.

Les identités et le dédoublonnage du classement général restent ceux de Global: fusion seulement sur joueur Play/Global fiable, repli Hub-local distinct par Hub, équipes Blind Test conservées comme participants équipe.

Compatibilite: si un ancien payload Global ne fournit pas `display_podium_count`, Games calcule une valeur bornee par `max(0, podiums - wins)` dans le helper central `games_hub_aggregate_display_podium_count(...)`. Les podiums de session individuels ne sont pas modifies.

Fichiers de reference:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `games/web/tests/hub_session_settings_dom_test.mjs`;
- `global/web/app/modules/entites/clients/app_clients_functions.php`;
- `global/web/tests/client_joueurs_dashboard_aggregate_ranking_test.php`.

## Update 2026-07-28 — Routes Hub sur endpoint canonique

Les routes `/hub/{hub_token}/master` et `/hub/{hub_token}/play` ciblent maintenant directement `games/web/games_ajax.php?t=jeux&m=hub_master|hub_play` via `games/web/.htaccess`.

L'alias historique `games/web/global_ajax.php` reste disponible et continue de charger `games_ajax.php`, mais il n'est plus utilisé par le parcours Hub Master/Play normal. Cela supprime le log répétitif `deprecated_alias_used` sur chaque poll Hub sans modifier les URLs publiques `/hub/...`, les paramètres, les cookies ni les réponses JSON/HTML.

Fichiers de référence:
- `games/web/.htaccess`;
- `games/web/global_ajax.php`;
- `games/web/games_ajax.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-28 — Hub agrégat: logs attendus vs indisponibles

Le contexte Hub distingue maintenant explicitement l'état où l'agrégat n'est pas encore attendu de l'état où il devrait être disponible mais ne l'est pas.

Avant toute session terminée, c'est-à-dire sans `completion_events` et sans résultat fini exploitable (`finished_results_count=0`), Games ne charge pas le contexte agrégé et n'écrit aucun log d'agrégat. Cet état est nominal pendant les polls Master/Play de préparation et pendant le dernier poll qui précède immédiatement la persistance finale d'une session.

Quand l'agrégat est attendu et exploitable, `hub_aggregate_ranking_loaded` reste un diagnostic transport/debug, rendu silencieux en fonctionnement normal par le logger Global. Quand l'agrégat est attendu mais qu'aucun leaderboard exploitable n'est disponible, `hub_aggregate_ranking_unavailable` reste un signal visible avec `id_hub`, `completed_sessions`, `finished_results_count` et `aggregate_key_state`.

Aucun calcul métier n'est modifié: `games_hub_should_load_aggregate_context(...)`, `aggregate_ranking`, `display.has_leaderboards`, les rangs, le podium central, le podium agrégé, le polling, le focus Hub et la persistance de fin de session conservent leur comportement.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_identity_stability_contract_test.php`.

## Update 2026-07-27 — Hub Master: podium agrégé de soirée/événement

Le Hub Master possède maintenant un mode de présentation Hub distinct de la présentation d'une session. Le contrat serveur est `presentation_mode` avec les valeurs `session`, `hub_podium` et `hub_idle`; il est séparé du focus runtime `active_session_id`.

Passe visuelle complémentaire: le titre du podium agrégé visible est désormais stable et vaut `Podium`, indépendamment de l'usage courant soirée/événement. Le sous-titre métier reste contextualisé par les résultats, par exemple `Classement général après 3 parties jouées`.

Les wordings visibles du Hub Master relèvent de la présentation. Ils sont résolus depuis l'usage courant du client (`clients.id_solution_usage`) quand il est disponible, puis seulement en fallback depuis le `games_hubs.context_type` historique. Un Hub canonique conservé en `context_type=soiree` peut donc afficher `Lots de l’événement` et `Podium de l’événement` si le compte est désormais en gamification, sans création ni remplacement de Hub. `context_type` ne constitue plus l'autorité d'identité Hub; il reste un fallback de compatibilité quand le contexte d'usage courant est indisponible.

Le classement agrégé est maintenant un contrat Global. Le contexte joueurs expose `aggregate_ranking`, construit par `app_client_joueurs_dashboard_aggregate_ranking_from_leaderboards(...)` depuis les leaderboards normalisés; Games le consomme via `games_hub_general_ranking_from_aggregate_context(...)` sans recalculer l'agrégat ni les rangs. Les scores restent internes au tri; le rendu central projette les rangs denses `1`, `2` et `3` sous le titre stable `Podium`. Le visuel et les couleurs restent ceux du Hub, jamais ceux d'une session.

Games demande le contexte agrégé dès qu'un événement de fin naturelle existe ou qu'au moins une session terminée expose déjà un podium exploitable. Cette seconde preuve évite qu'un Hub nouvellement créé reste sans `Classement général` ni podium agrégé quand le retour de la première session terminée précède l'écriture ou la lecture de `completion_events`.

Le rendu agrégé trois gagnants est hybride: un fond local WebP fournit la scène, les matières, les anneaux et plaques vides, tandis que l'overlay HTML/CSS/SVG fournit toutes les données variables. Les cercles portent l'identité: photo valide centrée en `object-fit: cover`, sinon pseudo ou nom d'équipe complet, sur deux lignes maximum, avec taille responsive bornée selon la longueur; une image en erreur bascule proprement vers ce fallback texte. Les plaques de la scène hybride portent seulement le résultat existant puis le lot réel en information secondaire `Lot : ...` quand il est disponible. Le PNG source `games/web/includes/canvas/images/hub/podium-evening-3w-source.png` reste inchangé; un master normalisé `1664x936` strict 16:9 est conservé, puis `games/web/includes/canvas/images/hub/podium-evening-3w.webp` est servi pour l'intégration. Aucun upscale 3840x2160 n'est produit dans cette passe.

La scène hybride est utilisée dès qu'au moins un rang agrégé exploitable existe et que le WebP local est présent. Elle rend les trois marches `#1`, `#2`, `#3`; un rang dense absent laisse simplement sa marche vide. En cas d'asset absent, le rendu HTML historique non cassé reste disponible. Les podiums de session continuent d'utiliser les classes sobres historiques.

Les coordonnées de la scène hybride sont centralisées en custom properties relatives au repère Figma `1664x936`: slot central pour la première place dense, slot gauche pour la deuxième, slot droit pour la troisième. La calibration applique les centres et diamètres fournis pour avatars, avec `transform: translate(-50%, -50%)`; les médaillons sont ancrés localement au wrapper avatar (`left:50%; top:0`) et suivent donc le portrait au redimensionnement. Le bloc titre/sous-titre et les tailles typographiques utilisent des unités de conteneur de scène (`cqw`) plutôt que le viewport brut, pour conserver le même centre et le même rapport d'échelle en overlay Hub Master et en plein écran. Les plaques utilisent les rectangles frontaux comme zone officielle stat + lot secondaire. En cas d'égalité sur un rang dense, Games ne duplique pas la marche: il regroupe les entrées du rang, affiche un badge `×N` près de la médaille et fait tourner les identités du groupe toutes les 5 secondes tant que l'overlay est visible. Les champs photo déjà présents dans l'agrégat (`photo_src` ou variantes avatar/photo existantes) sont conservés; sans source canonique, le médaillon garde la même géométrie avec le libellé complet.

Cette scène agrégée est rendue comme une surcouche modale au-dessus de tout le Hub Master, pas comme une vue contrainte dans le visuel central. Le voile couvre la colonne centrale, le carrousel Programme, les lots/QR et la colonne classement/live; le panneau reste centré et large. La fermeture passe par le fond, Escape, le bouton interne ou le trophée `Masquer le podium`; les clics dans le panneau ne ferment pas et les clics derrière ne sont pas transmis. Le trophée et le plein écran restent en bas à gauche au-dessus du voile.

La composition interne n'est plus un assemblage de cartes identiques. `hub-master-podium-stage__scene` définit explicitement les zones `second first third`; chaque rang reçoit un modificateur dédié `--first`, `--second` ou `--third`. Le gagnant est séparé de la marche physique: bloc `__winner` pour médaillon/nom/stat, bloc `__step` pour la façade. La première marche est plus haute et plus large, avec avatar plus grand, accent or et couronne SVG inline; les rangs 2 et 3 gardent des accents argent/bronze et des dimensions lisibles.

Accessibilité overlay: la section Hub porte `role="dialog"`, `aria-modal="true"`, un titre `aria-labelledby` et un sous-titre `aria-describedby`. À l'ouverture, le focus va sur le bouton fermer; à la fermeture, il revient au trophée quand il est encore présent. Pendant l'overlay, les contrôles d'arrière-plan sortent du tab order, hors utilitaires Master, sans dépendre d'un focus trap fragile.

Les lots affichés sur le podium agrégé sont associés par rang dense, jamais par index d'affichage. Le resolver Games construit un mapping depuis `rank_value`/`rank`, puis rend `2e prix` sous `#2`, `1er prix` sous `#1` et `3e prix` sous `#3`, sans modifier l'ordre persistant de `games_hubs_prizes`. En cas d'égalité, toutes les identités tournantes d'une même marche partagent le lot de ce rang dense; aucune attribution gagnant n'est persistée en base. Le lot est intégré à la façade de sa marche; si aucun libellé de lot n'est disponible, aucun bloc lot vide n'est rendu et la marche conserve seulement son rang structurel.

Décoration: aucun asset distant n'est requis. Le décor du cas trois gagnants vient du WebP local; la couronne SVG n'est plus rendue dans la branche hybride.

L'affichage automatique passe en `hub_podium` quand aucune session n'a le focus runtime, qu'au moins une partie terminée possède un podium exploitable, et que toutes les sessions métier sont terminées ou suspendues. Une session pending bloque cet affichage automatique. Le mode manuel `hub_idle` permet de masquer le podium même si l'auto serait éligible.

Le bouton trophée du Master écrit uniquement le mode de présentation. Le clic sur une carte Programme, l'ajout rapide et le lancement/reprise d'une session ferment le podium agrégé en revenant à `session`, sans modifier le classement, les résultats, les podiums de session ni `active_session_id`. Quand `hub_podium` est actif, aucune carte du carrousel n'a `is-selected`, mais l'index technique reste conservé.

Les remplacements partiels `preparation_revision` conservent le mode overlay: après remplacement Programme/Lots/central, le binding est réappliqué sans doublon et la restauration de sélection ne simule pas de clic carte tant que `hub_podium` reste actif.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/includes/canvas/images/hub/podium-evening-3w-source.png`;
- `games/web/includes/canvas/images/hub/podium-evening-3w-normalized.png`;
- `games/web/includes/canvas/images/hub/podium-evening-3w.webp`;
- `games/web/tests/hub_session_settings_dom_test.mjs`;
- `games/web/tests/hub_session_settings_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`;
- `global/web/tests/hub_presentation_mode_contract_test.php`.

## Update 2026-07-27 — Hub Master: podium terminé borné à trois cartes

Le podium central du Hub Master consomme maintenant le même contrat que les surfaces Master historiques: une partie terminée expose au plus trois cartes de podium. Les rangs de compétition restent inchangés (`1, 1, 3`, `1, 2, 2`, etc.), mais une égalité massive ne produit plus toutes les lignes de rang `1` à `3` dans le Hub.

La correction est portée dans Global sur `app_session_results_podium_from_rankings(...)` et `app_session_results_podium_normalize(...)`, puis doublée côté Hub par `games_hub_result_podium_rows(...)`. Le Hub ne tronque donc pas après rendu navigateur: il reçoit et rend déjà la sélection bornée.

Contrat documenté par les tests:
- égalité massive en première place: les trois premières lignes canoniques seulement;
- égalité en deuxième place: trois cartes maximum, rangs conservés;
- équipes Blind Test: métadonnées d'équipe conservées;
- podium JSON normalisé et cas une/deux/zéro ligne.

La règle exacte "max trois cartes malgré égalités" n'a pas été trouvée dans START/DOCS_MANIFEST comme texte canonique; elle est déduite de l'audit des surfaces Master/Canvas historiques et figée ici par tests.

Fichiers de référence:
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`;
- `global/web/tests/session_results_podium_contract_test.php`;
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-27 — Hub Master: sélection de présentation distincte du focus

Le Hub Master distingue maintenant explicitement le focus runtime Hub de la sélection locale du carrousel Programme. `active_session_id` reste le contrat runtime lu par Hub Play et par les canvases; sélectionner une carte Master ne l'écrit pas et ne route aucun joueur.

La carte mise en avant en resolution automatique generale est résolue par `games_hub_master_presentation_selection_resolve(...)`. La priorité est déterministe et ne dépend pas des horaires individuels: session au focus runtime confirmé, première partie prête/non jouée selon la position persistante du Programme, première session runtime suspendue à reprendre selon cette même position, dernière fin naturelle prouvée par `hub_execution_completed` seulement s'il ne reste aucune prête/suspendue, première session métier, puis carte `Ajouter une partie` seulement si aucune session métier n'existe.

Après une fin naturelle, le Canvas complète l'exécution Hub et vide le focus via les helpers Global existants. Dans la page courante de retour Master, une intention locale `natural_completion` sélectionne explicitement la partie terminée afin que `renderCentralForSelectedSession()` affiche son podium prérendu si disponible, au lieu de basculer sur la prochaine partie du Programme. Cette intention n'est pas persistée: un reload navigateur ultérieur revient à la résolution automatique générale.

Le refresh `preparation_revision` remplace désormais aussi le bloc central branding/podium en plus du Programme et des Lots. Une sélection manuelle reste restaurée si la carte existe encore; un fallback automatique ne s'applique qu'après disparition de la carte ou événement runtime prioritaire.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-26 — Hub Master: classement général et inscrits live

La colonne droite du Hub Master rend désormais un seul panneau combiné. Dès qu'un classement existe, le titre visible est `Classement général`; les anciennes sous-sections par jeu (`Cotton Quiz`, `Blind Test`, `Bingo Musical`) ne sont plus rendues dans cette colonne.

Le classement général consomme toujours `aggregate_context` chargé par `games_hub_get_context_from_request()` depuis les helpers Global `app_client_joueurs_dashboard_get_context_for_event(...)` ou `app_client_joueurs_dashboard_get_context_for_period(...)`. La source canonique du classement multi-jeux est désormais `aggregate_context['aggregate_ranking']`, calculée côté Global. Games ne fusionne plus localement les leaderboards; il applique seulement une projection d'affichage, dont `display_stat_short` pour la colonne droite.

Global additionne les scores normalisés par identité canonique, puis trie comme le dashboard joueurs: score décroissant, nombre de contributions, date récente, libellé. Les rangs exposés au Hub sont denses et leur clé d'égalité est la performance agrégée `score|count`; la date récente ordonne seulement les ex aequo et le libellé stabilise l'ordre final.

Le Hub Master n'affiche plus les points dans la colonne droite. Ils restent uniquement internes au tri et au calcul d'agrégation. Si Global expose déjà `wins`, `second_places` ou `third_places`, Games affiche un indicateur court: victoires en priorité, sinon podiums. Si aucune statistique fiable n'est présente sur la ligne, aucun indicateur n'est affiché.

Le bloc `Inscrits live` reste toujours rendu sous le classement et conserve sa source existante: `app_games_hub_players_count_active(...)` et `app_games_hub_players_list_active(...)`, donc `games_hubs_players.status='active'`, trié par `COALESCE(last_seen_at, updated_at, created_at) DESC, id DESC`. Le polling `players_count` continue de rafraîchir compteur et liste indépendamment du classement. À zéro joueur, le libellé `joueurs inscrits` est masqué et seul `0` + `En attente de joueurs.` reste visible.

Quand aucun classement n'est disponible, `Inscrits live` garde sa liste complète. Quand le classement existe, la colonne droite se découpe en deux zones: le classement en zone haute scrollable et `Inscrits live` en zone basse toujours visible. Dans cet état, la liste live affiche seulement les cinq derniers inscrits puis `+ X autres` si nécessaire; le compteur reste celui de tous les joueurs actifs.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`;

## Update 2026-07-26 — Hub Master: carte ajout rapide allégée

La carte `Ajouter une partie` du carrousel Hub Master affiche seulement l'icône `+` et le titre `AJOUTER UNE PARTIE` dans sa zone visuelle. Les textes secondaires `Compléter le programme` et `Choix automatique` sont retirés.

L'espacement sous l'icône est augmenté pour mieux séparer le pictogramme du titre. Le CTA footer `Ajouter`, l'action `quick_add` et l'ouverture de la modale restent inchangés.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-26 — Hub Master: séries Quiz séparées des détails

Les lignes de séries Quiz ne sont plus rendues dans le bloc commun `hub-session__details`. Ce bloc reste réservé aux métadonnées courtes de carte, notamment `Sur smartphone` ou `Sur papier`.

Les thématiques Quiz numérotées sont maintenant envoyées dans le payload `theme_lines` et rendues juste en dessous, dans une div dédiée `hub-session__theme-lines`. Cette séparation redonne de la respiration à la carte tout en conservant le titre principal compact (`4 séries`) et les ellipses sur les intitulés longs.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-26 — Hub Master: renouvellement aligné dashboard Pro

Le renouvellement `↻` du Hub Master reprend le mécanisme du dashboard Pro: chaque carte garde en mémoire locale une liste bornée de `temporary_exclusions`, alimentée uniquement par `previous_selection` renvoyé par le serveur après un apply réussi.

Au clic suivant, le Hub transmet ces exclusions à `app_programming_theme_renewal_plan_for_session(...)`, puis applique la proposition retournée par le même service Global. Cela évite de refaire immédiatement A -> B -> A quand plusieurs alternatives existent. Comme dans Pro, cette mémoire n'est pas persistée dans `sessionStorage`, `localStorage` ou cookie, et elle est réinitialisée quand le service signale qu'aucune alternative ne reste avec les exclusions courantes.

Pour Cotton Quiz, le Hub transmet aussi les options `theme_renewal_operation=plan/apply`; si le loader dashboard `start_theme_renewal_candidate_loader` est chargé dans le contexte, il est utilisé comme dans le dashboard Pro. Sinon, le service Global garde son loader canonique.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-26 — Hub Master: garde de renouvellement quick-add

L'icône `↻` du Hub Master dépend uniquement de l'origine persistée `games_hubs_sessions.membership_source='quick_hub_create'`, propagée dans le modèle sous `hub_membership_source`, et d'une session jamais lancée selon l'indicateur canonique `hub_last_launch_event_id` / `hub_last_launch_at`.

Une ligne runtime initiale ou un statut `En attente` ne constitue pas une preuve de lancement. À l'inverse, dès qu'un événement `hub_execution_started` est retrouvé pour la session dans ce Hub, le renouvellement est refusé même si un état runtime paraît encore éditable.

Le contrôle `↻` reste rendu avant `⚙` seulement quand le garde passe. La règle CSS de visibilité reste alignée sur `⚙`: les deux actions sont masquées hors carte sélectionnée et affichées sur la carte sélectionnée. Le comportement et le positionnement de `⚙` ne changent pas.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_master_renewal_eligibility_model_test.php`.

## Update 2026-07-26 — Hub Master: sous-lignes des séries Quiz

Les cartes Programme Quiz du Hub Master gardent le libellé principal compact fourni par Global (`4 séries`, `2 séries` ou thème unique), mais ne répètent plus ce compteur dans la ligne de détails.

Quand les noms de séries Quiz sont disponibles, la carte affiche d'abord le mode de participation (`Sur smartphone` / `Sur papier`), puis une sous-ligne numérotée par série: `1 ...`, `2 ...`, etc. Le style utilise une variante compacte dédiée, sans puces, avec police plus petite et ellipses contrôlées pour rester lisible dans les cartes du carrousel.

Le payload serveur expose aussi `details_variant=quiz-series`; les mises à jour Ajax de carte après paramétrage ou changement automatique de thématique conservent donc le même rendu sans reload global.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-24 — Fallback Cotton sans logo dans les interfaces

Les interfaces Organizer, Player, Remote et Hub Master consomment le même branding effectif. Comme Global ne fournit plus de logo depuis le fallback Cotton, ces surfaces rendent un logo uniquement si une couche session, Hub, réseau ou compte en fournit un.

Le Player respecte désormais une valeur `logo.img_src` absente au lieu de retomber localement sur `/images/logo.png`. Les visuels par défaut propres aux jeux et les logos techniques dédiés aux QR/impressions restent conservés.

Les sessions officielles lancées depuis le Hub Games conservent le visuel Cotton Hub par défaut dans le branding runtime, même lorsqu'aucun logo n'est disponible dans la cascade.

Fichiers de référence:
- `games/web/player_canvas.php`;
- `games/web/organizer_canvas.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-26 — Hub Master: autre proposition automatique quick-add

Le Hub Master reste une interface d'animation. Il ne permet pas de modifier librement une session ni de programmer une thématique depuis le Hub.

Pour une carte issue de l'ajout rapide Hub (`games_hubs_sessions.membership_source='quick_hub_create'`) et jamais lancée (`hub_runtime_status` pending / `hub_is_pending=1`), le Master peut afficher l'icône `↻` avant la roue `⚙`. Son tooltip est `Autre proposition`. Les sessions créées depuis le Dashboard, les sessions bibliothèque/backfill legacy et toute session déjà lancée, suspendue ou terminée n'affichent pas cette action.

Le POST Hub `quick_session_theme_renew` réutilise strictement le contrat Global de renouvellement existant: `app_programming_theme_renewal_plan_for_session(...)` puis `app_programming_theme_renewal_apply_for_session(...)`, avec appartenance Hub, état éditable, exclusions historiques, exclusions du programme, diversité, validation de proposition et apply conditionnel. Games ne crée aucun algorithme de sélection.

Après succès, le navigateur met à jour uniquement la carte retournée par le serveur. Le carrousel, l'ordre du Programme, la sélection locale, le focus Hub, les états runtime, les WebSockets, l'ajout rapide et la roue `⚙` restent inchangés.

# Repo `games` — Carte IA d’intervention (canon)

## Update 2026-07-26 — Hub Master: refresh préparation symétrique

Le Hub Master `/hub/{hub_token}/master` reste l'interface d'exploitation de la soirée, mais il détecte maintenant les changements de préparation validés ailleurs, notamment depuis le Dashboard Pro, sans rechargement complet de la page.

Le POST `preparation_revision` expose une révision légère construite depuis le contexte canonique déjà utilisé par le rendu Hub: ligne Hub, Programme `games_hubs_sessions` / `championnats_sessions`, branding effectif via `app_games_hub_branding_get(...)` et lots via `app_games_hub_prizes_get(...)`. Le navigateur vérifie cette révision au retour au premier plan (`visibilitychange`, `pageshow`) et, tant qu'il reste visible, sur un intervalle léger de 60 secondes.

Si la révision n'a pas changé, aucun bloc n'est reconstruit. Si elle change, le Master relit la page serveur puis remplace uniquement les blocs marqués `data-hub-refresh-block="program"` et `data-hub-refresh-block="prizes"`, synchronise le style inline, le titre, la méta et le visuel central du branding, puis réinitialise les handlers concernés: QR, plein écran, carrousel Programme, renouvellement `↻` et paramétrage `⚙`.

La sélection courante du Programme est restaurée si la session existe encore. Si elle a disparu, le carrousel recalculé choisit une carte valide. Les panneaux `Inscrits live` et `Classement général`, les podiums déjà rendus, les WebSockets, timers, overlays, animations, focus Hub persistant, `active_session_id` et runtime des sessions en cours ne sont pas remis à zéro par ce refresh.

L'ajout rapide depuis Hub Master utilise désormais le même mécanisme de refresh forcé après création réussie: il ne fait plus de `location.reload()` pour relire le Programme.

Fichiers de référence:
- `games/web/modules/app_hub_view_helpers.php`;
- `games/web/tests/hub_session_settings_test.php`.

## Update 2026-07-24 — Hub Master: branding, lots et Programme dashboard-aligned

Le Hub Master `/hub/{hub_token}/master` consomme toujours `games_hub_get_context_from_request()` puis `games_hub_build_view_model()` dans `games/web/modules/app_hub_view_helpers.php`. Le view-model expose déjà `hub_visual` et `hub_logo` depuis le branding effectif canonique; le Master affiche maintenant le logo effectif dans le panneau gauche, au-dessus des lots, uniquement si `hub_logo` fournit une URL. Le visuel central reste le visuel effectif du Hub.

Le panneau gauche Master affiche désormais `Lots de la soirée` ou `Lots de l’événement` selon le contexte éditorial effectif résolu depuis l'usage courant du compte, avec `games_hubs.context_type` seulement en fallback de compatibilité. Les lots restent strictement lus depuis `app_games_hub_prizes_get(...)` / `games_hubs_prizes` dans l'ordre canonique, avec les mêmes fallbacks de rang qu'avant. Le panneau ne dépend plus d'un étirement `display:flex`: le QR garde une taille naturelle bornée, et la commande plein écran est ancrée en `position:fixed` en bas à gauche du viewport Master, hors flux du panneau, avec borne safe-area et sans recouvrir les lots ni le QR.

Le Master ajoute une commande utilitaire Fullscreen dans ce panneau gauche. Elle utilise l'API native `requestFullscreen` / `exitFullscreen`, synchronise son icône Bootstrap et ses libellés sur `fullscreenchange`, et reste masquée si le navigateur ne supporte pas l'API. Aucun faux plein écran CSS, route, focus Hub, runtime ou WebSocket n'est introduit.

Les cartes Programme Master ne rendent plus d'horaire individuel. Le tri serveur, la sélection locale du carrousel, les flèches, le CTA unique de la carte active, les statuts, la roue de paramétrage et l'affichage central branding/podium restent inchangés. La zone principale hiérarchise jeu, thématique, puis métadonnées utilisateur; les modes visibles sont `Sur smartphone` et `Sur papier`. Les formats restent bornés aux libellés métier déjà résolus, notamment `20 titres` / `40 titres` pour Blind Test et les séries Quiz si présentes. Le contenu des cartes est légèrement remonté par marge interne stable, et le CTA utilise l'accent effectif du branding avec texte calculé par contraste noir/blanc.

Hub Master/Play emploient désormais `partie(s)` pour les libellés visibles propres au Hub, y compris le sous-titre partagé `date · à partir de HHhMM · N partie(s)` fourni par `app_games_hub_schedule_label_get(...)`; les noms techniques `session_*`, `id_session`, actions Ajax et contrats runtime restent inchangés.

Ajout rapide Hub: le moteur réutilisable vit désormais dans Global via `app_programming_quick_hub_create_from_game(...)`, qui enchaîne côté serveur résolution, recommandation et création idempotente. Games expose côté serveur Master l'action `quick_session_create`, protégée par la capacité Master, le token Hub actif et le CSRF Hub. Le Hub est résolu depuis le contexte du token, le compte depuis la ligne Hub, et le navigateur ne fournit pas d'identifiant compte/Hub/contact, de format, de mode, de thème ou de `proposal_token`.

Le carrousel Programme Master rend maintenant une carte d'action `Ajouter une partie` après les parties existantes. Elle appartient au même carrousel et aux mêmes flèches, mais ne porte aucun `id_session`, aucun lancement et aucun statut métier; la sélection locale de cette carte ne modifie jamais le focus Hub. La carte n'est pas entièrement cliquable: elle affiche dans son footer le CTA partagé `Ajouter`, qui ouvre seul la modale.

L'interface d'ajout rapide est une modale Master. Elle affiche uniquement les jeux disponibles fournis par `app_programming_quick_hub_games_get(...)`. Le clic sur un jeu déclenche directement `quick_session_create` avec `csrf_token`, `id_type_produit` et `quick_schedule_idempotency_key`; la thématique, le mode, le format, l'horaire et le rattachement Hub sont résolus côté serveur. Il n'y a pas d'écran de proposition, pas de CTA `Proposer autre chose` et pas de confirmation intermédiaire.

Après succès ou replay idempotent, Games ne fabrique pas une carte partielle en JavaScript: le Master déclenche le refresh préparation par blocs afin de récupérer le rendu serveur canonique du Programme, sans reload complet. Le focus Hub persistant, les sessions en cours/suspendues, les WebSockets, les lots, le QR, la Fullscreen API et la roue de paramétrage ne sont pas modifiés par cette UI.

## Update 2026-07-17 — Hub Master/Play: contexte, nom et planning

Hub Master et Hub Play consomment le même contexte Hub que le dashboard Pro et les pages publiques. Les titres de fallback sont `Événement {nom_compte}` ou `Soirée {nom_compte}`, sans libellé dérivé de la date ni retour à l'ancien modèle opérationnel.

Le sous-titre temporel reprend le format commun `date · à partir de HHhMM · N partie(s)`, pour rester aligné avec le dashboard et la page publique Hub. Le contexte affiché reste celui de la soirée ou de l'événement avant le lieu.

Les lots Hub restent lus depuis `games_hubs_prizes` pour Hub Master/Play, mais leur affichage sur la page publique Hub est volontairement désactivé côté `www` pour le moment.

## Update 2026-07-17 — Canvas: branding Hub hérité

Les interfaces de jeu appellent déjà `global_ajax.php?t=general&m=branding&action=get` depuis PHP avec le User-Agent `CanvasBrandingHydrator/1.0`. Ce chemin est le chemin historique qui faisait fonctionner le branding réseau; côté Global, il active désormais le resolver session avec cascade Hub champ par champ: session spécifique, Hub type 5, réseau, compte, puis fallback Cotton pour le visuel Hub.

Le branding des jeux ne dépend pas de `id_operation_evenement`: une soirée de dynamisation ou de gamification avec `id_operation_evenement=0` mais un Hub valide hérite du branding Hub `general_branding.id_type_branding=5`.

Le rattachement utilisé par Canvas est résolu côté Global via `games_hubs_sessions`. Les anciennes règles par opération ou `id_client + date` ne servent qu'à réconcilier des données non ambiguës; si plusieurs Hubs actifs peuvent revendiquer une session, Global journalise l'ambiguïté et ne choisit pas de Hub arbitraire.

Les canvases concernés sont Organizer/Master, Player et Remote. L'aperçu de la modale branding ajoute aussi `branding_context=game` car il part du navigateur et ne peut pas définir le User-Agent serveur. Les pages publiques de session côté `play` ne portent pas ce contexte et gardent leur comportement legacy. Le cache Canvas courant est `v=2026-07-17_02`.

## Update 2026-07-17 — Hub: publication et lots canoniques
- Le view model Hub ne fabrique plus `1er prix / 2e prix / 3e prix`. Il consomme `app_games_hub_prizes_get(...)`, le resolver Global egalement utilise par le prototype Pro.
- Le Hub Master, Hub Play et les canvases Organizer/Player/Remote rattachés à un Hub lisent `games_hubs_prizes` dans l'ordre canonique rang 1, rang 2, rang 3. Les sessions autonomes gardent les champs historiques `championnats_sessions.lot_1/lot_2/lot_3`.
- Le bootstrap historique est borné par `games_hubs.prizes_initialized_at`: une première lecture peut importer la première session personnalisée d'un ancien Hub jamais initialisé, mais une suppression volontaire des trois lots Hub marque l'initialisation, ne réimporte plus les anciennes valeurs et affiche le fallback générique rang 1 à 3.
- Le SQL initial des tables est `games/web/includes/canvas/sql/2026-07-17_games_hubs_publication_prizes.sql`; le correctif idempotent `2026-07-17_games_hubs_prizes_initialization_state.sql` ajoute le marqueur d'initialisation sur `games_hubs` si la base déjà importée ne le possède pas.
- Le fallback visuel Cotton 600x240 du Hub delegue au helper Global `app_games_hub_branding_fallback_visual_get()`. Le SVG rendu par Hub Master/Play est inchange, mais le dashboard Pro peut desormais employer strictement le meme asset sans recopier la cascade ni choisir une session.

## Update 2026-07-15 — Hub Master: carte Programme, contenu central et paramétrage de session
- Passe 2: la carte Programme sélectionnée expose une petite roue de paramétrage sur la route `/hub/{hub_token}/master`, selon le même modèle de capacité par token que les pages Master historiques sur `games.*`. Le même token ouvert sur Hub Play ne donne pas ce droit; les écritures exigent aussi le jeton CSRF propre à la page Master et revérifient côté serveur l'appartenance de la session.
- `session_settings_get` et `session_settings_save` restent dans le POST Hub existant. Le jeu, la version et le format sont dérivés de la session serveur; la session doit provenir du contexte courant, appartenir au Hub et ne pas être terminée. Version et format ne font plus partie du contrat de write Hub: un payload forgé contenant `paperMode` ou `sessionFormat` est rejeté `STRUCTURAL_OPTIONS_FORBIDDEN`, et le handler Hub n'appelle plus `session_update`.
- Le formulaire est produit par le renderer PHP partagé `includes/canvas/php/session_options_form.php`, également utilisé par `organizer_canvas.php`. En contexte Hub, `show_version=false` et `show_format=false` retirent entièrement ces groupes; le Master historique conserve ses contrôles. Le Hub expose seulement les options runtime pertinentes: Quiz pilotage manuel papier, durée, propositions numériques et pause inter-séries; Blind Test durée puis propositions/type en numérique; Bingo durée. Les accès Remote, QR/Pilot et `Force full current` restent absents.
- La modale applique un thème de contenu calculé par luminance relative WCAG sur sa couleur de fond effective, avec variables distinctes pour fond, contrôle, textes principal/secondaire/atténué, séparateur, bordure, accent et son texte, états désactivés, erreur et focus. Le parseur accepte hex court/long et `rgb()`/`rgba()`; la couleur du texte d'accent résulte du meilleur ratio noir/blanc.
- Les enums et booléens sont validés par le schéma partagé. `canvas_session_options_resolve()` applique l'ordre snapshot serveur valide, ancien `localStorage`, puis défaut historique; pour un Quiz papier sans valeur exploitable, `manualAdvance=true`. Un `false` explicite n'est jamais remplacé. Le Hub persiste uniquement les clés runtime autorisées dans le snapshot complet `game_events.action=hub_session_settings_save`; les valeurs structurelles et les options masquées sont reprises de l'état courant sans être écrasées. Le Master historique et le runtime consomment le même resolver/défaut.
- En version papier, la modale propose les générateurs historiques: feuilles de réponses Quiz, feuilles de réponses Blind Test 20/40 titres selon le format persistant et grilles Bingo Musical. L'URL Hub utilise un grant aléatoire de 30 minutes lié au Hub, à la session et au jeu; le serveur revérifie capacité Master, token Hub actif, appartenance, version papier et jeu dérivé avant d'inclure le générateur global canonique. Un format Blind Test/Bingo modifié mais non enregistré désactive le lien. Aucun lien Remote/Pilot n'est créé.
- Ajustement post-recette: le renderer pose `hidden` avant le premier paint pour les supports et le groupe complet `Pilotage manuel` d'un Quiz numérique; `refreshConditionalFields()` reste l'unique synchronisation lors des bascules. Une règle Hub ciblée donne priorité à tout attribut `hidden` sur les `display:grid`; aucune classe Bootstrap absente ni listener parallèle n'est requis. Les groupes d'options Quiz/Blind Test/Bingo utilisent un `gap:1rem`, équivalent au `mb-3` Bootstrap historique, indépendant de l'état des champs et sans effet sur le Master historique.
- Le succès renvoie l'état serveur complet et les options autoritatives, puis actualise seulement le cache historique local. Aucune métadonnée de carte n'est réécrite par une sauvegarde runtime Hub; sélection, ordre, scroll, CTA, centre et focus restent inchangés.
- La modale native gère chargement, erreur, enregistrement, anti-double-submit, fermeture extérieure/Échap et restauration du focus sur la roue. Son sous-titre rappelle de façon non éditable la version persistée et, pour les jeux musicaux, 20/40 titres. Une session terminée n'a pas de roue et toute tentative directe est refusée; une session suspendue conserve ses options runtime éditables.
- Aucun WebSocket, `active_session_id`, règle de focus, polling live ou accès Remote n'est modifié par cette passe. Le cache Canvas local courant est `v=2026-07-15_04`; `games/web/config.php` reste ignoré par Git et doit être déployé explicitement.
- Chaque carte du carrousel Programme sépare désormais sa zone visuelle inchangée d'un footer compact intégré au même contour. Le wrapper visuel conserve image, overlays, heure, jeu, thème, métadonnées et badges; son coin supérieur droit ne porte plus de contrôle.
- L'unique CTA existant est toujours synchronisé sur la seule carte sélectionnée actionnable, avec les mêmes libellés et actions `Lancer`, `Reprendre` ou `Relancer`, dans le footer de cette carte. `setAction()` n'affiche ce footer et ne pose `.has-program-action` que si le CTA possède un type, un libellé et sa cible effective; toutes les autres cartes masquent explicitement leur footer.
- La hauteur extérieure reste `calc(clamp(212px, 30vh, 234px) + 46px)` pour chaque carte. Sans CTA, la grille interne devient `minmax(0, 1fr) 0` et le visuel, son image et son overlay occupent toute la hauteur avec arrondis inférieurs; avec CTA, la seconde ligne reprend ses `46px`. Changer de sélection ne provoque donc ni saut de hauteur ni décalage vertical du carrousel.
- Le clic CTA reste isolé du handler de sélection. La piste Programme gagne la hauteur du footer et la ligne hero flexible absorbe cette hausse; les cartes sont légèrement réduites et le scale sélectionné borné afin de garder leurs bordures haute/basse visibles. Le visuel central conserve son ratio `5 / 2` et `object-fit: contain`, sans modification des panneaux Lots, QR ou classement/inscrits.
- Branding et podiums de sessions sont des contenus alternatifs de la même enveloppe centrale `.hub-master-feature`: position, largeur, hauteur, ratio `5 / 2`, marges et contraintes de grille sont donc identiques. Le changement de carte ne remplace que le contenu intérieur. Une session terminée avec podium canonique exploitable affiche son propre podium; une session non terminée ou terminée sans podium affiche toujours le branding global du Hub.
- Au chargement, `games_hub_get_context_from_request()` appelle `app_session_results_get_context()` une fois pour chaque session dont l'état serveur est terminé et normalise les résultats par `session_id`. Les cartes non terminées ne déclenchent aucun calcul de résultat. Tous les podiums utilisables sont rendus côté serveur; le navigateur ne recalcule ni rang, ni score, ni URL de photo et n'effectue aucune requête lors d'un clic ou d'une flèche.
- `selectCard()` reste l'unique mutation de sélection locale et appelle `renderCentralForSelectedSession()`, qui relit la carte portant réellement `.is-selected`, associe son `data-hub-session-id` au podium prérendu et masque tous les autres contenus. La sélection initiale, le focus Hub et `active_session_id` restent inchangés.
- `app_session_results_get_context()` résout déjà les photos durables du podium avec `app_session_results_podium_photo_get()` et les expose dans chaque ligne via `photo_src`, y compris pour les entrées équipe normalisées. Le Hub affiche cette URL canonique lorsqu'elle existe; sans photo, aucun média factice n'est rendu et la carte textuelle centrée reste le fallback, comme dans le Master Canvas historique.
- La présence d'une photo ne participe jamais au calcul de hauteur: chaque podium prérendu réserve une ligne compacte au header et une ligne `minmax(0, 1fr)` aux places. Le header affiche contexte, jeu et thème sur une seule ligne; chaque photo est contrainte à `clamp(124px, 48cqh, 188px)`, rognée au centre avec `object-fit: cover`, puis le rang, le nom et le score occupent l'espace restant dans une marche plus compacte.

## Update 2026-07-15 — Hub: continuité des joueurs ajoutés depuis la Remote papier
- Un joueur créé par `player_register` depuis une session papier reste un joueur Hub canonique actif; les lancements suivants sélectionnent exclusivement `games_hubs_players.id_hub = ? AND status = 'active'`, puis réutilisent sa clé `p:*` serveur sans dépendre d'un cookie, d'un localStorage ou d'une visite Player.
- Si une ancienne inscription Remote de la session cible existe sous une clé locale différente mais avec le même pseudo exact, l'injection serveur peut adopter cette unique ligne runtime sous la clé Hub. Cette réparation est impossible hors du contexte interne borné par jeu, token session, clé canonique, pseudo, Hub et joueur Hub; un conflit ambigu reste refusé.
- L'adoption modifie uniquement `player_id` sur la ligne existante: elle conserve l'ID SQL, le score Quiz/Blind Test, la grille et les gains Bingo, et ne crée ni équipe Blind Test ni socket Player.
- Les mappings `completed` restent propres à une session et n'altèrent jamais `games_hubs_players.status`; seuls les joueurs Hub globalement `active` sont injectables. Un mapping `left` reste exclu sauf réactivation explicitement autorisée.
- Observabilité: `hub_remote_player_bridge_*`, `hub_launch_injectable_players_selected` et `hub_paper_player_injection_*` exposent le parcours sans nécessiter de trace navigateur.

## Update 2026-07-13 — Hub: participation runtime des sessions papier
- Une session papier focus matérialise désormais chaque joueur Hub actif par le `player_register` persistant du moteur avant d'exposer `paper_registration_confirmed=true` et le message de confirmation sur Hub Play.
- L'orchestration distingue `app_games_hub_session_participation_ensure(...)`, le wrapper numérique avec preload et `app_games_hub_paper_participation_ensure(...)`. Le wrapper papier exécute uniquement `player_register`: aucune navigation Player Canvas, grille Bingo, équipe Blind Test ni socket Player.
- L'identité réutilise la clé `p:*` du mapping Hub et le pseudo Hub exact. Le verrou MySQL hub/session/joueur et l'UPSERT des trois adaptateurs rendent polling, reload et double onglet idempotents; le mapping n'est activé qu'après validation de l'ID et de la clé retournés.
- Master et Remote papier relisent `players_get` toutes les 2,5 s afin d'intégrer les writes Hub même sans socket Player. Bingo accepte les lignes actives sans grille; Quiz et Blind Test acceptent les joueurs persistés déconnectés, Blind Test restant solo sans équipe automatique.
- `active_launched_session` traite le focus papier comme rejoignable techniquement, mais ne produit jamais de `play_url`. Une erreur persistante conserve Hub Play sans confirmation mensongère et le polling peut retenter après initialisation du runtime organisateur.

## Update 2026-07-13 — Hub Master: focus après relance suspendue
- Le POST `launch_session` ne redirige plus sur la seule réussite de l'UPDATE: le focus demandé doit être relu et confirmé dans `games_hubs.active_session_id` avant contexte d'exécution, réinjection et ouverture du Canvas.
- Le payload Master reconstruit `hub_is_focus_active` par comparaison entière stricte avec ce focus persistant. Une session `running` non-focus reste `Suspendue`; le runtime ne peut jamais l'élire implicitement.
- Le tri, le CTA et la sélection initiale du carrousel privilégient l'unique carte focus. Sans focus, la prochaine session à venir est prioritaire; s'il n'en reste aucune, la session suspendue dont l'exécution Hub est la plus récente est centrée, indépendamment de son horaire planifié. Une sélection manuelle de carte reste locale au DOM et n'écrit aucun focus.
- `active_launched_session`, Hub Play et les guards Player consomment la même présentation relue en base. Un clear tardif d'une ancienne session est ignoré par comparaison puis protégé par l'UPDATE conditionnel.

## Update 2026-07-15 — Hub: validation papier puis retour après fin naturelle
- La fin du support Quiz/Blind Test papier pose `awaiting_score_validation`: cet état est non terminal, garde Master/Remote visibles, autorise les corrections HTTP-first et n'engage ni podium, ni completion Hub, ni barrière terminale.
- Le clic Remote `paper_finalize_end` est une demande idempotente portant un `event_id`, pas une preuve terminale. Les WS passent à `finalizing_scores`, persistent le classement/podium, puis seulement à `completed`; en échec ils reviennent à la revue avec une erreur exploitable.
- Bingo utilise la validation persistée de la dernière phase (`next_phase=-1`) comme demande de finalisation. Le WS déclenche lui-même `bingo:end_game`, même sans socket Master; un Master connecté peut envoyer le même terminal sans doubler le write grâce au verrou en vol et au même `event_id` logique.
- La barrière Hub ignore `paper_finalize_end` et les états de revue. Elle ne s'engage que sur `game/ended`/`endGame` après preuve finale; une erreur de write appelle `abortTerminal`, révèle le document et conserve les contrôles.
- Si le focus a été vidé mais que l'écriture `hub_execution_completed` a échoué, `hub_session_natural_ended` récupère l'exécution encore ouverte pour écrire la preuve au retry; une Remote seule peut ainsi achever la transition sans socket Master.
- Les transitions Hub appliquent désormais un contrat commun: une destination Hub prouvée au boot ou au signal terminal suspend le rendu historique devenu obsolète; si la preuve manque ou si le boot échoue, l'UI historique est révélée et `HUB_TRANSITION_FALLBACK_HISTORICAL_UI` est journalisé.
- Sur `/master/{token}?hub_launch=1`, le paramètre n'active la garde que si une exécution Hub ouverte valide aussi `hubOrganizer`. Le document reste non présenté pendant ce bootstrap borné, l'ancien délai d'autostart de 350 ms est supprimé, puis le premier rendu visible est le flux lancé ou l'état Pause restauré. Un blocage d'offre/garde réaffiche le lobby avec une erreur déterministe.
- Côté Master, une barrière terminale commune et monotone est engagée dès le premier terminal définitif local ou WS lorsque `hubOrganizer` prouve l'exécution et fournit déjà une destination Master valide. Elle couvre `game/ended`, `endGame`, les snapshots Bingo terminaux déjà persistés et un preload terminé, mais jamais `paper_finalize_end` ni la revue papier.
- Cette barrière masque le document avant toute mutation terminale, bloque podium/résultats et mémorise le dernier replay historique utile. `HUB_SESSION_FINISHED` commite ensuite une seule fois `location.replace()`; tout callback terminal tardif reste ignoré. Sans preuve/destination valide, ou si `location.replace()` lève une erreur, le document est révélé et le terminal historique est rejoué une seule fois.
- Côté Player, le contrat existant reste inchangé: `HUB_SESSION_FINISHED` appelle `location.replace()` vers Hub Play avant `player/end`, et Bingo bloque aussi ses snapshots `current_phase=-1`.
- Au chargement de Hub Play, les écrans `register` et `waiting` sont tous deux précédés d'un état `resolving`: `current_player` résout d'abord session EP, identité locale et cookies Hub côté serveur. `register` ne devient visible qu'après absence confirmée de joueur actif; un joueur actif retrouve directement son état inscrit, puis seulement le polling de présentation démarre.
- Toute identité active, qu'elle vienne du chargement `current_player` ou d'un `register_guest` réussi sans reload, démarre le même watcher canonique `active_launched_session`. Il effectue un tick immédiat puis une boucle récursive toutes les 3,5 s, sans requête concurrente; une `play_url` validée est engagée une seule fois via `location.replace()`.
- Le watcher compare `presentation.target/session_id/reason` à chaque réponse. Le focus Hub actif est la validation de lancement; Bingo peut donc être redirigé alors que son runtime est encore `pending` avant la première phase. L'ensure ne fait que `player_register`; `grid_assign` puis `grid_hydrate` restent post-navigation dans le boot Player Bingo.
- L'audit Master Bingo a localisé la première divergence avant le Player: l'auto-start Hub immédiat pouvait émettre `game/init` puis `game/started` avant que `session_sync.startAutoSync()` ait attaché ses handlers; les commandes Bingo `reset` et `playing_state` étaient alors perdues. L'ancien délai de 350 ms ne faisait que masquer cette course.
- En Bingo, le premier `state` authentifié pose déjà l'état collant WS `open` et émet `ws/registered`; `ws_effects.js` ne réattend plus une seconde occurrence susceptible d'être perdue dans le même callback. Il attache l'autosync, republie l'ACK unifié puis publie `organizer/runtime-ready`. Le parcours Hub attend cette condition avant d'engager exactement le même `Game.handleUI({type:'play'})` que le clic `ui/play` historique.
- Pour Bingo, `ACTION_ACCEPTED` et la libération de la garde exigent un message serveur `state` non terminal après l'engagement du `reset`; sa phase prouve que le runtime partagé a accepté l'initialisation. En timeout ou rejet, `HUB_MASTER_AUTOSTART_FAILED` libère la garde en fallback historique.
- Après validation réelle du Master, les logs HTTP Player montrent la navigation Bingo mais aucun POST `player_register`, `grid_assign` ou `grid_hydrate`. La première divergence est dans `register.js`: une identité locale Bingo valide entrait dans `bingoPlayerExists()` puis quittait l'IIFE avant `form.addEventListener('submit', ...)`; la demande Hub mémorisée ne pouvait jamais être rejouée.
- Un mapping `hubAutoPlayer` actif et non `left` a désormais priorité sur cette seule branche de reprise locale. Le formulaire atteint son binding, puis `bootHubAutoRegister()` rejoue une fois `requestSubmit()` dans le handler historique; ce flux conserve `player_register → grid_assign → ensureHubBingoGridReady/grid_hydrate → player/ready`. Hors Hub, la reprise locale reste inchangée.
- La recette suivante confirme désormais `player_register`, mais révélait un premier `player/ready` prématuré avant `grid_assign` (`grid_hydrate=grid_forbidden`), puis une interface restée `En attente` malgré le snapshot WS de la session reprise. Tant que l'auto-inscription Hub n'est pas commitée, la branche OPEN garde donc l'écran de connexion et n'appelle plus `ensureDigitalWsReady()`.
- Le Player Bingo normalise `current_phase` en nombre, mémorise chaque état runtime issu de `state` / `players_sync`, puis rejoue explicitement ce snapshot après l'ouverture WS authentifiée. Une reprise affiche ainsi immédiatement `Pause` ou `En cours`, même si le premier événement précède la fin du bootstrap applicatif.
- Un `SESSION_ENDED` reçu dans un Canvas Player rattaché à un Hub n'est plus assimilé à un départ volontaire du joueur. Le retour vers Hub Play conserve l'identité locale, l'affectation/grille Bingo et supprime tout marqueur `leftVoluntarily` résiduel; un clic explicite sur `Quitter` conserve au contraire la désactivation et le nettoyage historiques.
- Ce retour Hub utilise `location.replace()` afin que l'historique navigateur ne rouvre pas la socket de session terminée. Les sessions hors Hub restent sur leur parcours historique.
- Lorsqu'un joueur a réellement quitté puis choisit `Rejoindre à nouveau` sur Hub Play, l'URL `hub_join=manual` restaure la clé canonique `p:*` portée par `hub_player_token`. Si l'exposition `hubAutoPlayer` n'est pas disponible, le Canvas retrouve la ligne Bingo déjà réactivée par le backend, restaure son ID SQL et appelle `grid_assign` avant tout démarrage WS.
- L'ancienne grille ayant été libérée par `deactivate_player`, `grid_assign` peut en attribuer une nouvelle. Le `player/ready` n'est émis qu'après persistance de son ID et de son secret; un échec réel d'attribution laisse le formulaire visible avec un message explicite.
- Une reprise Bingo avec la même clé canonique et le même pseudo contourne les réservations de nom destinées aux nouvelles identités: l'UPSERT réactive la ligne existante, tandis qu'une autre clé demandant ce pseudo reste refusée. Le bootstrap `hub_join=manual` est également autorisé à remettre `active` un mapping qu'un `leave` tardif aurait repassé `left` pendant la navigation.
- Pour Quiz et Blind Test, `player/ready.playerName` est persisté par le connecteur WS avant `registerPlayer`; si le stockage a été nettoyé, le pseudo autoritatif `AppConfig.hubAutoPlayer.name` sert de fallback. Le serveur ne reçoit donc plus un nom vide rendu ensuite comme `Joueur`.
- Pour Quiz et Blind Test, `deactivate_player` ne constitue pas à lui seul une demande de remise à zéro. Le score n'est effacé que lorsque Hub Play retrouve sous verrou un mapping session réellement `left` et traite l'action explicite `manual_join_session` pour la même identité canonique. Ce contexte interne serveur est borné au jeu, au token de session et au `player_id`; une réactivation automatique, un accès direct/hors Hub, une reconnexion réseau ou une relance organisateur conserve le score, même si la ligne SQL était inactive. `upsert.changed_fields` inclut `score` seulement lorsque cette réinscription Hub autorisée a réellement effacé une valeur non nulle.
- Bingo suit une règle différente: `bingo_phase_winners` et les champs `phase_wins_count/last_won_*` représentent des phases effectivement gagnées dans la session. Un départ volontaire, une nouvelle grille ou une réinscription ne les effacent pas; la relance organisateur doit restaurer ce palmarès historique. Seul un reset métier complet de la session/démo purge ces gains.
- En échec du submit Hub, les verrous local et global sont réarmés avant le fallback, afin qu'une tentative ultérieure ne soit pas bloquée par un engagement incomplet.
- Jalons terminaux Master sans token: `HUB_MASTER_TERMINAL_EVENT_RECEIVED`, `HUB_MASTER_TERMINAL_RENDER_SUPPRESSED`, `HUB_MASTER_FINISHED_SIGNAL_RECEIVED`, `HUB_MASTER_FINISHED_REDIRECT_COMMITTED`, `HUB_MASTER_TERMINAL_CALLBACK_IGNORED_AFTER_REDIRECT` et, uniquement en échec, `HUB_TRANSITION_FALLBACK_HISTORICAL_UI`. Les jalons de lancement, auto-register, watcher Hub Play et redirect Player existants restent inchangés.
- Un lancement explicite depuis Hub Master crée désormais une preuve durable `hub_execution_started` dans `game_events`; le rattachement de la session seul ne définit plus le parcours Hub.
- Après persistance terminale, `hub_session_natural_ended` exige cette exécution ouverte et le focus courant, effectue le clear atomique, puis écrit `hub_execution_completed`. Seule cette preuve autorise le signal et les redirects au reload.
- `HUB_SESSION_FINISHED` est émis vers les sockets encore ouvertes avant leur fermeture; les clients tracent sa réception puis utilisent immédiatement `location.replace()`. Les ouvertures Pivot Pro restent sur les écrans historiques.
- Les writes navigateur Bingo `player_register`, `grid_assign` et `grid_cells_sync` fournissent un `event_id` stable pendant une tentative/retry; le bridge restitue le résultat métier sur replay sûr.
- Cache Canvas courant: `v=2026-07-15_04`, couvrant la machine d'état papier, la barrière terminale, le renderer partagé et la persistance serveur du paramétrage. `games/web/config.php` est ignoré par Git et doit être inclus explicitement au déploiement.
- Hub Master relit le dernier podium durable via `app_session_results_get_context()` et remplace `Inscrits live` par les leaderboards existants de `app_client_joueurs_dashboard_get_context_for_period()` ou `..._for_event()`.
- Les fins hors Hub, `quitGame`, expiration de grâce et erreurs Canvas conservent leurs parcours historiques.

## Update 2026-07-12 — Hub: clear après expiration de grâce
- `hub_session_grace_expired` retrouve session et Hub puis réutilise le clear conditionnel existant.
- Une expiration A vide le focus seulement si A est encore actif; sinon `different_focus`. Hors Hub: `not_hub_session` sans effet.
- Aucun mapping joueur, identité Hub, podium ou fin naturelle n'est modifié.

## Update 2026-07-12 — Hub: reprise suspendue synchronisée Master / Player
- Une session Hub déjà commencée est restaurée en `Pause` au retour du Master; `hub_launch=1` ne relance automatiquement que les sessions réellement jamais démarrées. Le clic Play explicite reste le seul passage de la reprise vers `En cours`.
- Après `registrationSuccess` du Master, `boot_organizer.js` republie une fois le snapshot restauré `Pause`. Cette publication tardive évite que l'événement initial soit perdu avant l'attachement de `session_sync` et interdit un snapshot résiduel `En attente`.
- Le bootstrap Player Hub considère une identité active, valide et non `left` comme une restauration en cours: la sonde `checkSession` ne réaffiche pas transitoirement le formulaire d'inscription pendant la réconciliation.
- Lorsqu'un Player est rechargé pendant la suspension, son nouveau socket est ouvert mais n'est encore rattaché à aucune session. Le serveur lui adresse `GAME_RESUMED` avec le `sessionId`; `play-ws.js` réémet alors `registerPlayer`, attend `registrationSuccess`, puis demande `getGameState` et reçoit la Pause courante.
- `GAME_RESUMED` n'est accepté comme déclencheur de réinscription que s'il cible la session Player courante. Les tentatives simultanées sont dédupliquées et l'ACK local d'inscription est invalidé dès que le transport quitte `open`.
- Une déconnexion organisateur réellement volontaire reste distincte: le serveur envoie `SESSION_ENDED`, déconnecte les participants et supprime le runtime. Elle ne passe pas par ce chemin de reprise.
- Jalons utiles: `boot_organizer:hub_launch_resume_paused`, `hub_launch_resume_pause_snapshot_sent`, `PLAYER_GAME_RESUMED_REGISTER`, `PLAYER_REGISTERED`, puis `gameState.gameStatus=Pause`.

## Update 2026-07-12 — Hub: réconciliation numérique / papier
- Les sessions papier sont résolues avant l'ensure runtime numérique: elles conservent leur mapping Hub actif sans exiger une participation numérique et restent sur le parcours de confirmation papier.
- Pour une session numérique, un mapping Hub actif peut être exposé à `AppConfig.hubAutoPlayer` sans faire de `runtimeEnsure.ok` une preuve d'authentification WS; l'ACK `registrationSuccess` reste la preuve du rattachement effectif du socket.
- Les mappings `left`, les sessions terminées et les parcours hors Hub gardent leurs protections historiques.

## Update 2026-07-11 — Hub: sortie organisateur et désactivation du focus
- Une sortie volontaire depuis le Canvas organisateur d'une session hub appelle l'endpoint organisateur avant `quitGame` afin d'effacer le focus persistant.
- `app_games_hub_focus_clear(...)` valide le hub actif et l'appartenance de la session, puis efface `active_session_id` uniquement s'il désigne encore cette session; une sortie tardive de A ne peut donc pas effacer le focus de B.
- L'opération est idempotente (`cleared` ou `not_focus`) et ne modifie ni la phase runtime ni l'état final historique de la session.
- Le Canvas organisateur revient vers `/hub/{hub_token}/master`; les joueurs continuent de traiter `SESSION_ENDED` vers `/hub/{hub_token}/play`.
- L'auto-join recharge le focus courant et ne produit plus de `play_url` lorsque le focus est absent, incohérent, non `running` ou terminé.
- `app_games_hub_session_is_auto_joinable(...)` porte ce contrat joueur strict, tandis que `games_hub_session_is_organizer_launchable(...)` autorise l'organisateur à relancer une session du jour non terminée même sans focus.
- Une session non-focus dont la DB indique encore `running` repasse par la garde de lancement, la réinjection des hub players et `/master/{token}?hub_launch=1`; le Canvas reconstruit ainsi le runtime WS historique avant que l'auto-join joueur ne devienne admissible.
- Les parcours hors hub ne disposent pas du contexte `hubOrganizer` et conservent leur sortie historique.

> **But**: permettre à un agent IA “web” (sans accès direct au runtime) de comprendre rapidement :
> - **ce que fait le repo**, **comment ça circule** (WS/HTTP/Bus),
> - **où intervenir** pour coder une évolution ou corriger un bug.
>
> **Règle**: ce fichier est une **source de vérité** (update-not-append).  
> L’historique et les changements vont dans `TASKS.md`.  
> Le point d’entrée public reste `SITEMAP.md`.

## Doc discipline
- `canon/repos/games/TASKS.md` à mettre à jour à chaque action significative (update-not-append si une tâche existe déjà).
- `canon/repos/games/README.md` à mettre à jour dès qu’un changement impacte le fonctionnel (flux/actions inter-repos, endpoints, env vars, idempotence/event_id, jalons logs, writes DB, etc.).
- En cas de divergence, le code fait foi ; corriger la doc immédiatement.

## Update 2026-07-11 — Hub: destination canonique et resynchronisation player
- Depuis le 2026-08-25, `games_hubs.active_session_id` exprime uniquement la destination runtime Hub Play/Remote historique. La destination volontairement présentée par Master/Remote est portée par `games_hubs.presentation_session_id`.
- Le polling `active_launched_session` expose explicitement `presentation.target`, `presentation.session_id` et `presentation.reason`; les critères runtime/mapping restent une étape distincte d'auto-joinabilité.
- Une session Player issue d'un hub vérifie cette présentation au boot, toutes les quatre secondes et au retour au premier plan. Si le focus est vidé ou passe de A à B, elle revient par Hub Play, qui résout ensuite l'éventuelle session cible.
- Tant que le focus reste sur la session courante, la page Player reste en place, y compris pendant la grâce organisateur et sur le podium.
- Les sessions hors hub n'activent aucun polling de présentation. Les événements WS restent des accélérateurs et non la source persistante de destination.

## Update 2026-07-17 — Hub: publication et lots persistés

- `games_hubs_publication` porte les champs éditoriaux/pratiques propres à une soirée ou un événement: titre, accroche, description, lieu/adresse personnalisés, lien et statut. Elle ne stocke ni visuel, ni logo, ni couleurs, ni sessions.
- `games_hubs_prizes` porte les lots globaux du Hub, au maximum trois rangs, sans gagnant, remise, date de remise ni relation joueur/session.
- `app_games_hub_prizes_get(...)` lit d'abord `games_hubs_prizes`. Si aucun lot Hub n'existe et que `games_hubs.prizes_initialized_at` est vide, un bootstrap transitionnel reprend la première session du programme portant des lots personnalisés et journalise les divergences sans fusion. Après sauvegarde ou suppression volontaire des trois rangs, le Hub reste initialisé même avec zéro lot.
- Hub Master/Play et les canvases Organizer/Player/Remote rattachés à un Hub lisent les lots Hub; une session autonome conserve les champs historiques `championnats_sessions.lot_1..3`.
- `app_games_hub_public_resolve(...)` expose séparément publication, lieu, branding, lots et sessions. Le visuel reste fourni par le resolver branding Hub et sa cascade existante.

## Update 2026-07-11 — Hub: réconciliation de la participation runtime
- Avant de rediriger Hub Play ou d'exposer `AppConfig.hubAutoPlayer`, le backend appelle l'ensure central `app_games_hub_runtime_participation_ensure(...)`.
- Un mapping `active` et un ancien `id_participation > 0` ne suffisent plus: `player_register` est rappelé avec la clé canonique `p:*`, puis le mapping reçoit l'ID réellement retourné par le moteur courant.
- `player_canvas.php` ne construit `hubAutoPlayer` que si l'ensure réussit et si clé/ID/mapping sont cohérents. En échec, le fallback historique reste visible et un log `hub_session_qr_resume_runtime_ensure_failed` fournit la raison.
- Les mappings `left` ne sont jamais réactivés automatiquement; seul le rejoin manuel existant autorise leur réconciliation.
- Blind Test et Quiz utilisent leur upsert `(session, player_id)`. Bingo assure d'abord la participation de la même façon, puis conserve son submit historique et son `grid_assign` idempotent pour la grille.

## Update 2026-07-10 — Hub Master: hero ratio réel et footer flexible
- Le visuel principal du Hub Master utilise le ratio réel `5 / 2` et n'est plus recadré par `object-fit: cover`.
- La colonne centrale reste en trois lignes, mais le hero est une ligne auto calculée depuis sa largeur disponible; le footer/carrousel devient la piste flexible `minmax(0, 1fr)`.
- Le panneau QR conserve la même hauteur que le visuel, avec une largeur dynamique bornée entre environ 220px et 320px.
- Le carrousel exploite la hauteur restante avec cartes centrées et bornées, sans modifier le CTA rond, les flèches ni la logique de sélection/lancement.

## Update 2026-07-10 — Hub Master: rythme vertical et QR borné
- La colonne centrale de `/hub/{hub_token}/master` garde la structure header, visuel+QR, carrousel, avec un `row-gap` unique pour harmoniser les espacements entre lignes.
- La piste visuel+QR est bornée directement par la grille centrale, évitant une ligne `1fr` avec `max-height` qui laissait un espace résiduel avant le carrousel.
- Le panneau QR s'étire à la même hauteur que le conteneur visuel; son contenu est séparé en titre naturel puis zone QR occupant l'espace restant.
- Le rendu QR est borné sur largeur et hauteur au niveau du wrapper et des enfants générés (`img`, `canvas`, `svg`), sans modifier le texte ni la logique du carrousel.
- Le CTA rond de la carte active, les états de sessions et les panneaux Lots / Inscrits live restent inchangés.

## Update 2026-07-10 — Hub Master: CTA rattaché à la carte active
- Le CTA rond du Programme Master n'est plus un élément flottant indépendant: le DOM unique est déplacé dans la carte sélectionnée quand elle est actionnable.
- Le bouton est ancré en haut à droite de la carte active, avec `aria-label`/`title`; les cartes latérales ne lancent jamais de session.
- Le clic sur le CTA stoppe la propagation pour ne pas déclencher aussi la sélection de carte.
- La zone centrale utilise une grille compacte: header stable, visuel/QR légèrement réduits, carrousel visible sans scroll global attendu.
- La règle `Non jouée` avant fallback `Prête` pour date passée reste inchangée.

## Update 2026-07-10 — Hub Master: carrousel focus avec bouton rond
- Le carrousel Programme de `/hub/{hub_token}/master` reste dans la colonne centrale et laisse les panneaux Lots / Inscrits live en pleine hauteur.
- Le header de carrousel (`Programme`, compteur, CTA texte) est retiré; les flèches sont des contrôles latéraux discrets.
- La carte sélectionnée est la surface dominante du programme; les cartes latérales sont atténuées et servent uniquement à sélectionner.
- Le seul CTA visible côté Programme est un bouton rond superposé à la carte sélectionnée quand elle est jouable (`Lancer` ou `Reprendre`).
- Les sessions terminées, passées non jouées et les dates passées restent consultables sans bouton d'action.

## Update 2026-07-10 — Hub Master: programme carrousel footer
- `/hub/{hub_token}/master` teste une composition avec lots en panneau gauche, identité/visuel/QR au centre, inscrits live à droite et Programme en footer.
- Le Programme Master est un carrousel horizontal de cartes visuelles; cliquer une carte ou les flèches change seulement la sélection.
- Les cartes Programme n'ont toujours aucun CTA interne et affichent heure, jeu, thème/titre, métas utiles et badge d'état.
- Le CTA unique du footer dépend de la session sélectionnée: `Reprendre` pour le focus actif, `Lancer` pour une session jouable, aucun CTA pour terminée/passée/non jouée ou date passée.
- Aucun classement agrégé, runtime jeu ou historique pro n'est modifié par cette passe UI.

## Update 2026-07-10 — Hub Master: programme conducteur
- La colonne Programme de `/hub/{hub_token}/master` est un conducteur compact: heure lisible, titre, type de jeu, format/version, durée et badge d'état.
- Les cartes Programme Master ne portent plus de CTA par session (`Lancer`, `Reprendre`, résultats); l'action de lancement/reprise est affichée hors Programme quand `master_cta` fournit une session jouable.
- Le focus hub actif reste la session la plus identifiable via `hub-session--focus` / `hub-session--priority`; sans focus actif, la prochaine session peut être marquée `Prochaine`.
- Une session passée non terminée n'est plus affichée `Prête`; elle devient `Non jouée`, sans action de retour jeu.
- Le runtime jeu, l'historique pro et la conservation des sessions hub ne changent pas.

## Update 2026-07-09 — Hub: session active/focus distinct du runtime
- Le hub dispose maintenant d'un focus propre, stocke sur `games_hubs.active_session_id` et `active_session_activated_at`.
- Ce focus ne modifie pas les états runtime réels des jeux: une ancienne session peut rester techniquement `running`, mais ne pilote plus l'auto-join hub.
- `app_games_hub_sessions_get(...)` enrichit chaque session avec `hub_focus_status` (`upcoming`, `active`, `previous`) et `hub_is_focus_active`.
- Quand le master lance une session depuis le hub, `app_games_hub_focus_set_active(...)` remplace le focus courant et logge l'ancienne session comme désactivée côté hub.
- Hub Play auto-join uniquement la session numérique `hub_is_focus_active=1`, non terminée réellement, avec hub player actif et mapping non `left`.
- Un mapping `left` sur une ancienne session ne bloque plus l'auto-join de la nouvelle session focus.
- Le programme Hub Master trie par focus: session active en premier, sessions à venir ensuite, anciennes sessions runtime `running` non-focus comme `Suspendue`, puis sessions terminées.
- Côté Master, `En cours` et `Reprendre` sont réservés au focus actif; une session `Suspendue` affiche `Relancer`, qui repasse par `launch_session` pour reposer le focus sans changer l'état runtime réel.
- Le programme Hub Play ne déclenche plus de resolver auto sur les sessions précédentes encore `running`; elles s'affichent comme `Suspendue` et ne proposent aucun CTA de reprise.
- Seule la session focus active peut afficher `Session quittée` + `Rejoindre à nouveau` quand le joueur l'a quittée volontairement.
- L'action Hub Play `manual_join_session` refuse aussi côté serveur une session non-focus et renvoie un message sans `play_url`.
- Logs focus/auto-join: `hub_focus_set_active_start`, `hub_focus_previous_deactivated`, `hub_focus_active_selected`, `hub_auto_join_focus_candidate`, `hub_auto_join_skip_not_focus`, `hub_auto_join_skip_left_for_this_session`, `hub_auto_join_redirect_focus_session`.

## Update 2026-07-09 — Hub Play: reprise depuis cookies après bridge session
- Hub Play reprend maintenant une identité créée par le bridge session -> hub sans dépendre d'une clé `localStorage` hub préexistante.
- Au chargement de `/hub/{hub_token}/play`, l'action `current_player` accepte les cookies `cotton_hub_token` et `cotton_hub_player_token` comme source de reprise si le token hub cookie correspond exactement au hub courant.
- Le fallback cookie est aussi disponible pour `active_launched_session` et `manual_join_session`, afin que l'enchainement vers la session suivante fonctionne même après une entrée initiale par QR session.
- Les cookies d'un autre hub, un player manquant ou un player `left` ne créent rien et retombent sur le register hub.
- Le cas EP est repris par `$_SESSION['id_joueur']` si disponible ou par cookie player `ep_{id}`; il ne crée pas de doublon guest.
- `register.js` écrit les cookies issus de `hub_bridge` avec `Path=/`, `SameSite=Lax` et `Secure` en HTTPS.
- Logs de reprise: `hub_play_resume_from_cookie_start`, `hub_play_resume_from_cookie_hub_match`, `hub_play_resume_from_cookie_hub_mismatch`, `hub_play_resume_from_cookie_player_found`, `hub_play_resume_from_cookie_player_missing`, `hub_play_resume_from_cookie_player_left`, `hub_play_resume_from_cookie_success`, `hub_play_resume_from_cookie_fallback_register`.

## Update 2026-07-09 — Hub identity: QR session -> hub implicite
- Une inscription classique depuis `/play/{game}/{session_token}` rattache maintenant le joueur au hub si la session appartient a une soirée hub.
- `player_canvas.php` detecte l'appartenance hub et expose `AppConfig.hubSessionBridge`, sans rediriger ni masquer le formulaire classique quand aucune identite hub n'existe.
- Le rattachement effectif se fait dans les endpoints `player_register` Quiz, Blind Test et Bingo apres creation/reprise de la participation session.
- Le retour API contient `hub_bridge`; `register.js` pose alors `cotton_hub_token` et `cotton_hub_player_token`, puis met a jour `AppConfig.hubToken` / `AppConfig.hubAutoPlayer`.
- Invite: le `player_id` session canonique `p:*` devient aussi le `games_hubs_players.player_token`, ce qui evite deux identites entre session et hub.
- EP: quand le register porte `sourceTable='equipes_joueurs'` et `sourceId`, le hub player est cree/retrouve en `auth_type='ep'` avec `id_ep_player`, sans creer de doublon invite.
- Papier et Bingo passent par le meme bridge: inscription runtime confirmee, mapping hub/session cree, cookies hub poses; papier reste sans redirection `/play`.
- Hors hub, `hub_bridge.linked=false` et aucun hub player n'est cree; le register session classique garde son comportement historique.
- Le flux hub -> session transmet `skip_hub_register_bridge=true` pour eviter de retraiter un rattachement déjà orchestre par le hub.
- Logs attendus: `hub_session_register_bridge_detected`, `hub_session_register_bridge_no_existing_hub_player`, `hub_session_register_bridge_guest_created`, `hub_session_register_bridge_ep_found`, `hub_session_register_bridge_mapping_created`, `hub_session_register_bridge_cookies_set`, `hub_session_register_bridge_skipped_no_hub`, `hub_session_register_bridge_failed`.

## Update 2026-07-09 — Hub identity: résolution canonique hub -> session
- Le contrat d'identité hub vers session passe par `app_hub_player_resolve_session_access(...)` dans `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.
- Le resolver vérifie: hub actif, session rattachée au hub, hub player rattaché et actif, type de session, mapping `games_hubs_players_sessions`, participation runtime et rattachement EP.
- La sortie canonique expose `player_id` (`p:*`), `playerId` runtime, pseudo, `auth_type`, `id_ep_player`, `id_hub_player`, `id_session`, `session_token`, `game`, `session_type`, `mapping_status`, `can_auto_join`, `can_manual_join`, `is_paper`, `is_finished`, `should_redirect_to_play`.
- `app_games_hub_player_join_session(...)` reste un wrapper compat vers ce resolver; les chemins hub launch, hub play polling et accès direct player utilisent le même contrat.
- Les sessions numériques créent/retrouvent la participation runtime puis redirigent vers `/play/{game}/{token}` uniquement si `should_redirect_to_play=true`.
- Les sessions papier conservent l'identité et le mapping Hub historiques sans créer, rechercher ni attendre une participation runtime numérique; elles restent sur Hub Play avec le message: `Ton inscription est confirmée. Récupère ta feuille de jeu auprès de l’organisateur.`
- Pour une session numérique, `hubAutoPlayer.player_id` est la clé stable `p:...` et `hubAutoPlayer.playerId` l'ID SQL moteur. Le succès de `player_register` prouve l'UPSERT SQL, pas à lui seul la présence mémoire ni l'acceptation WS.
- `games_hubs_players_sessions` trace maintenant `auto_joined_at`, `manual_joined_at`, `last_joined_at`, `left_at`, `completed_at`, `join_count`, `last_action` et le statut `completed`.
- Hub Play pose les cookies games `cotton_hub_token` et `cotton_hub_player_token` apres inscription/reprise hub; ces cookies permettent de reprendre une identite hub quand un joueur scanne ensuite un QR session simple `/play/{game}/{session_token}`.
- Sur QR session sans paramètres hub, `player_canvas.php` cherche le hub actif de la session via `app_games_hub_get_for_session(...)`, vérifie que le cookie hub éventuel correspond à ce hub, puis retrouve uniquement un hub player existant par cookie `p:*` / `ep_*` ou par `$_SESSION['id_joueur']`.
- Si cette résolution implicite échoue, aucun hub player n'est créé et le formulaire session classique reste affiché.
- Quitter volontairement une session Hub depuis le player attend la confirmation `action=leave_session` avant retour Hub Play et marque le mapping `left`; le hub player reste actif dans la soirée.
- Le polling Hub Play respecte `left`: pas de boucle d'auto-redirection vers la même session; le CTA manuel `Rejoindre à nouveau` poste `action=manual_join_session`, appelle le resolver en `join_source=manual` / `manual_rejoin=true`, remet le mapping `active`, pose `manual_joined_at`, `last_joined_at`, `last_action=manual_rejoin`, puis redirige vers `/play/{game}/{token}` avec `hub_token`, `hub_player_token`, `hub_player_id` et `hub_join=manual`.
- Le polling `active_launched_session` est non bloquant: si l'auto-join échoue temporairement, le hub renvoie HTTP 200 avec `play_url=''`, `poll_error` et le détail `access`, pour éviter un 400 console en boucle. Le clic manuel garde ses erreurs strictes.
- Côté player, `register.js` traite `hub_join=manual` comme un rejoin explicite: il supprime/ignore le flag local `leftVoluntarily_{sessionId}` posé au quit volontaire, puis consomme `AppConfig.hubAutoPlayer`. Sans ce nettoyage local, le backend exposait bien le mapping actif mais le front retombait sur le register classique.
- Hub Play affiche sous `{pseudo} Prêt à jouer` un programme compact backend-driven: sessions à venir, numériques en cours, sessions volontairement quittées, reprises, papier confirmé et terminées. Les CTA du programme réutilisent `manual_join_session` et ne construisent plus d'URL session nue.
- Hors contexte hub valide, le register session classique reste le fallback inchangé.
- Logs serveur ajoutés autour de `hub_session_access_*` et de la reprise manuelle: `hub_session_manual_rejoin_requested`, `hub_session_manual_rejoin_resolve_start`, `hub_session_manual_rejoin_mapping_left_found`, `hub_session_manual_rejoin_mapping_reactivated`, `hub_session_manual_rejoin_participation_found`, `hub_session_manual_rejoin_participation_created`, `hub_session_manual_rejoin_redirect_play`, `hub_session_manual_rejoin_confirm_paper`, `hub_session_manual_rejoin_failed`.

## Update 2026-07-08 — Hub master: lancement direct depuis programme
- Les cartes programme de `/hub/{hub_token}/master` exposent maintenant deux actions: CTA principal `Lancer`/`Reprendre`/`Résultats` et CTA secondaire `Paramétrer`.
- `Paramétrer` ouvre `/master/{session_token}` sans injection hub et sans lancement.
- `Lancer` poste `action=launch_session` sur le hub master; le backend vérifie hub/session, applique `app_session_launch_guard_get(...)`, injecte les joueurs hub `active` via `player_register`, écrit le mapping `games_hubs_players_sessions`, puis redirige vers `/master/{session_token}?hub_launch=1`.
- Le démarrage effectif utilise le boot organizer existant: `AppConfig.hubLaunchAutoStart` appelle `beginPlayFlow({ source: 'hub' })`, auto-confirme la gate comme la remote et conserve le jingle/intro de transition.
- Le lancement `source: 'hub'` bypass le blocage diagnostic/prelaunch automatique; les contrôles matériel/connexion seront proposés depuis le hub master, tandis que les guards offre/session restent conservées.
- Côté joueur, le hub play poll `action=active_launched_session`; en session `running`, il injecte le joueur courant en fallback idempotent puis redirige vers `/play/{game}/{session_token}?hub_token=...&hub_player_token=...&hub_player_id=...`.
- `player_canvas.php` expose `AppConfig.hubAutoPlayer` depuis le mapping actif après chargement de la session; le payload contient pseudo, `player_id` canonique, id runtime, jeu, session, hub, source et type d'auth.
- `register.js` finalise directement Quiz/Blind Test depuis ce mapping serveur, marque l'UI inscrite et émet `player/ready`; Bingo conserve le submit historique, attend `grid_assign` puis `grid_hydrate` avec retry court, persiste la grille et émet `player/bingo:setGrid` avant `player/ready`.
- Pour éviter un boot silencieux/cache, `register.js` logge `register_js_loaded` en console au chargement, puis appelle `bootHubAutoRegister()` au boot module et au DOM ready avec garde `window.__hubAutoRegisterStarted`.
- Les invités hub reçoivent désormais un `player_token` canonique `p:*`; les anciens tokens hub sans clé canonique sont convertis en `participant_key` `p:*` déterministe au prochain join idempotent. Les joueurs EP hub transmettent `sourceTable='equipes_joueurs'` et `sourceId=id_ep_player`.
- Les inscriptions classiques gardent la gate normale `checkSession`; le flux hub bypass ce probe uniquement avec mapping serveur actif (`AppConfig.hubAutoPlayer.enabled`, pseudo, `player_id=p:*`, `playerId>0`), dès le bootstrap puis côté submit Bingo, car le WS player peut encore répondre "non active" pendant le passage master en jeu.
- Si `AppConfig.hubAutoPlayer` n'est pas disponible, `register.js` conserve le parcours historique; il ne finalise pas depuis le seul `localStorage`.
- Les logs de diagnostic player exposent les étapes `hub_auto_player_detected`, `hub_auto_player_missing`, `hub_auto_player_mapping_missing`, `hub_auto_player_boot_start`, `hub_auto_player_bypass_check_session`, `hub_auto_player_submit_start`, `hub_auto_player_ready_emit`, `hub_auto_player_waiting_gate_skipped` et `hub_auto_player_failed`; Bingo ajoute `hub_auto_player_bingo_submit_start`, `hub_auto_player_bingo_submit_ok`, `hub_auto_player_bingo_grid_missing`, `hub_auto_player_bingo_grid_retry`, `hub_auto_player_bingo_grid_ready`, `hub_auto_player_bingo_ready_emit`, `hub_auto_player_bingo_failed`.
- Quand un mapping hub actif est déjà exposé à la page joueur, Quiz/Blindtest marquent directement l'UI comme inscrite (`data-registered=1`) et émettent `player/ready`; Bingo exécute automatiquement le submit historique avec bypass `checkSession` limité au flux hub afin d'inscrire/réactiver le joueur puis d'attribuer la grille.
- À l'entrée directe `/play/{game}/{session_token}?hub_token=...&hub_player_id=...`, `player_canvas.php` répare idempotemment le mapping hub/session via `app_games_hub_player_join_session(...)` avant d'exposer `AppConfig.hubAutoPlayer`, pour garantir la présence de la ligne runtime jeu (`blindtest_players`, `quiz_players`, `bingo_players`).
- Limite assumée: aucun `start_session` PHP commun n'existe encore pour Quiz/Blind Test/Bingo; le hub orchestre donc injection + redirection + auto-start JS/WS.

## Update 2026-07-08 — Hub play runtime players V1
- `/hub/{hub_token}/play` persiste maintenant l'inscription hub dans `games_hubs_players`, sans injecter le joueur dans les sessions lancees.
- Le modele distingue `auth_type=guest` via `auth_identity_key=guest:{player_token}` et `auth_type=ep` via `auth_identity_key=ep:{id_joueur}`; le statut `left` conserve la ligne et l'exclut du compteur.
- Les actions POST hub play sont `current_player`, `register_guest`, `leave_player`, `players_count` et `validate_player_name`.
- Le compteur hub play/master lit `app_games_hub_players_count_active(...)` au lieu de l'etat visuel local; le front refresh le compteur joueur toutes les 15 secondes.
- L'inscription invite est idempotente par navigateur via `player_token`; une re-inscription apres depart reactive la ligne existante quand l'identite est la meme.
- Le bloc `Compte joueur Cotton` est disponible sur le Hub Play et redirige vers Play avec `hub_account_join=1`; au retour, `app_games_hub_player_prepare_ep_return(...)` cree/reprend l'entree EP et renvoie `/hub/{hub_token}/play?ep_connect_token=...`.
- Les pseudos actifs sont compares via `pseudo_normalized` dans le hub; en conflit avec un autre joueur actif, le message reste `Ce nom n'est plus disponible. Merci d'en choisir un autre.`.
- Hors scope maintenu: injection automatique dans les sessions, mapping hub->participation session, equipes Blind Test hub, classement agregé hub et retour hub de fin de session.

## Update 2026-07-08 — Hub play V1: alignement visuel session historique
- `/hub/{hub_token}/play` reprend maintenant le header compact des pages player historiques: titre centré, meta `X sessions • date • à partir de HHhMM`, chip joueurs local et chip état soirée (`En attente`, `En cours`, `Terminée`).
- Le visuel haut hub est plein largeur au même format que les sessions historiques, sans bordure, avec hauteur contrainte et bords de page épousés; le visuel hub par défaut est au ratio `600x240`.
- La chip joueurs reprend l'icône historique Bootstrap Icons `bi-people-fill`.
- La carte d'inscription masque le contexte date/lieu, masque le label visible `Pseudo`, garde `Pseudo` en placeholder et utilise le CTA `S'inscrire`.
- Après inscription locale, `#screen-waiting` devient un empilement de cartes transparentes à bordure légère: message `{pseudo} Prêt à jouer 🎉` puis `A gagner`.
- Les lots soirée/événement reprennent la présentation historique des prix.
- Le bloc `Au programme` est finalement retiré du Hub Play V1 pour rester au plus proche de l'attente joueur historique.
- `Quitter la soirée` devient un CTA léger en bas de l'écran d'attente; il reste local et sans écriture serveur.

## Update 2026-07-08 — Hub play V1: validation pseudo EP avant stockage
- Le submit pseudo du hub play appelle maintenant `POST /hub/{hub_token}/play` avec `action=validate_player_name` avant d'écrire `hub:{hubToken}:player_identity`.
- Cette validation ne crée aucun joueur et n'écrit aucune table; elle applique la validation locale 1-20 caractères puis réutilise `canvas_session_has_referenced_participant_name(...)` sur les sessions rattachées au hub.
- Si le pseudo correspond à un participant EP déjà référencé pour une session du hub, le hub renvoie le message runtime `Ce nom n'est plus disponible. Merci d'en choisir un autre.` et ne stocke pas l'identité locale.
- Les doublons de pseudos entre deux navigateurs restent hors garantie tant qu'il n'existe pas de stockage serveur des inscrits hub.

## Update 2026-07-08 — Hub play V1: UI inscription historique et pseudo
- `/hub/{hub_token}/play` reprend plus strictement la carte d'inscription historique joueur: `Inscription`, texte `Prêt à jouer ? Choisis ton nom de scène...`, champ `Pseudo`, input type `form-control`, compteur/erreur et CTA principal compact.
- Le style de la carte revient au contraste historique `primary-font` sur `primary-bg`, avec titre accent `secondary-bg`, input clair, erreur rouge et bouton arrondi.
- La validation locale hub applique les règles générales du runtime session avant stockage local: normalisation des espaces, trim, pseudo obligatoire et longueur 1 à 20 caractères; le pseudo n'est plus tronqué silencieusement.
- Les validations session qui dépendent d'une session cible, d'une table joueurs ou d'un participant EP référencé restent au moment de `player_register`; le hub local ne garantit pas encore l'unicité entre deux navigateurs.
- Aucun endpoint d'inscription, aucune table joueurs, aucune grille Bingo, aucune équipe et aucune auto-redirection ne changent dans ce correctif.

## Update 2026-07-08 — Hub play V1: correctif UI historique
- `/hub/{hub_token}/play` garde le modèle d'inscription locale de soirée, mais son rendu joueur revient vers le rythme des pages player historiques: visuel pleine largeur en haut, puis écran mobile centré avec carte d'inscription ou d'attente.
- Le header sticky joueur hub est retiré pour éviter le doublon titre/date et laisser le formulaire visible rapidement sur mobile.
- Jour J, la carte affiche `Rejoins la soirée`, le texte d'attente de lancement, le label `Ton pseudo` et le CTA `Je suis prêt`.
- Après inscription locale, le lobby affiche `Prêt à jouer 🎉`, le pseudo, le statut `En attente du lancement…`, un programme secondaire minimal et aucun bouton de changement de pseudo.
- Le bouton secondaire `Quitter la soirée` supprime seulement l'identité locale `hub:{hubToken}:player_identity`, pose le flag local `hub:{hubToken}:leftVoluntarily` et revient à l'état avant inscription si la date hub est ouverte.
- Aucun modèle session, aucune équipe, aucune auto-redirection, aucune pré-inscription session et aucune écriture serveur ne changent dans ce correctif.

## Update 2026-07-08 — Hub play V1: inscription locale soirée
- `/hub/{hub_token}/play` devient une entrée joueur hub mobile-first: avant Jour J les inscriptions libres sont fermées avec message EP/participation probable, Jour J le joueur saisit un pseudo, après Jour J la soirée est fermée.
- L'inscription hub reste locale navigateur et scoppée au token: `hub:{hubToken}:player_identity` contient `schema`, `name`, `stablePlayerId` au format `p:*`, `source`, `registeredAt` et `updatedAt`.
- Cette inscription hub n'écrit aucune table de jeu, ne réserve aucun pseudo session, ne crée pas de participation session et ne consomme aucune grille Bingo.
- Après inscription hub, le joueur voit un lobby simple `Prêt à jouer 🎉`, son pseudo, le statut `En attente du lancement...` et un rappel programme secondaire.
- Les URLs de sessions préparées depuis le hub embarquent un `hub_token` strictement validé, mais aucune auto-redirection n'est déclenchée tant qu'une notion fiable de session active hub n'existe pas.
- `/play/{game}/{session_token}` expose maintenant `AppConfig.hubToken` quand le paramètre est valide; les sorties joueur numérique, `SESSION_ENDED` et papier renvoient alors vers `/hub/{hub_token}/play`.
- Les routes classiques sans `hub_token` gardent leur retour historique vers `AppConfig.urlPromo` ou `/`.
- Le bug Blind Test suspecté autour d'un accès sans master ouvert n'est pas corrigé dans ce lot; le hub play ne s'appuie pas sur `checkSession` pour ouvrir son inscription.

## Update 2026-07-08 — Hub master V1 simplifie avant play
- `/hub/{hub_token}/master` est recentre comme ecran d'accueil soiree/evenement avant play: header contexte, visuel soiree, QR vers `/hub/{hub_token}/play`, programme lateral et etat inscrits live.
- Le master hub est un viewport fixe `100vh` sans scroll global, pense pour 1366x768 et 1920x1080.
- Le visuel hub garde un format large coherent avec les visuels de sessions/hub et utilise le fallback Cotton multi-jeux tant que `branding_operation.visual` n'existe pas.
- Le programme master est compact, limite a 5 sessions visibles avec mention `+ X sessions`; la prochaine session est marquee mais aucun lien de lancement n'est rendu dans cette V1.
- Le panneau inscrits live affiche un etat propre `En attente des premiers joueurs` tant qu'aucune agregation hub live n'est disponible.
- Sont masques/retires du master pour ce lot: lots de soiree fallback, CTA principal de lancement session, bilan, footer organisateur, modales personnalisation/options/programme et programme en grandes cartes.
- `/hub/{hub_token}/play` reste fonctionnellement inchangé dans ce patch.
- Les routes directes session et interfaces historiques restent inchangées.

## Update 2026-07-07 — Hub master/play: structure soirée/événement
- Les pages `/hub/{hub_token}/master` et `/hub/{hub_token}/play` appliquent la structure branding canon retournée par `app_games_hub_branding_get(...)`.
- Champs lus: `general.color.background_1`, `general.color.background_2`, `general.color.font_1`, `general.font.family`, `general.font.family_url`, `logo.img_src`, `visuel.img_src`.
- Les anciens fallback plats restent tolérés, mais aucune nouvelle logique de résolution branding n'est ajoutée côté `games`.
- Aucun branding n'est écrit, propagé aux sessions ou copié vers une nouvelle table.
- `app_hub_view_helpers.php` prépare un view-model `hub_*` pour le futur branding opération/soirée: titre, sous-titre/date/lieu, visuel, logo, couleurs, police, lots et options.
- Le master hub reprend la structure du lobby master historique `organizer_canvas.php` en attente (`#waiting-container`, colonnes QR/lots/visuel, `qr-container`, `lots-container`, `main-visual`, `organisateur-menu`) sans modifier l'interface historique: viewport 100vh sans scroll global, CTA principal vers `/master/{session_token}`, QR vers `/hub/{hub_token}/play`, lots de soirée fallback et programme compact limité à 3 lignes visibles avec mention de débordement.
- Le play hub reprend la structure du lobby player historique `player_canvas.php` en attente (`player-root`, `header-banner`, `player-header`, `player-main .screen`, `register-screen`, `screen-waiting`, `lots-card`, `card`) sans modifier l'interface historique: largeur smartphone, lots fallback et programme avec CTA tactile vers `/play/{game}/{session_token}` seulement pour une session du jour.
- Depuis l'alignement visuel du 2026-07-07, ces surfaces utilisent un habillage sombre Canvas/player par défaut: fond immersif violet profond, accents multi-jeux, panneaux transparents, contours lumineux et suppression des grandes cards blanches de type dashboard.
- Le hub est le lobby soirée/événement avant, entre et après les sessions; les sessions continuent de s'exécuter dans leurs interfaces historiques.
- Les pages ne sélectionnent pas une session de référence pour définir le branding hub et ne réutilisent pas arbitrairement les lots d'une session individuelle.

## Update 2026-07-07 — Supra-interface soiree/evenement: routes read-only Lot 2
- `games` expose deux routes hub publiques read-only: `/hub/{hub_token}/master` et `/hub/{hub_token}/play`.
- Le hub est lu par `games_hubs.id_securite` uniquement; un token invalide, introuvable ou inactif affiche une erreur non sensible.
- La vue master affiche le branding effectif, le titre hub, la date, le lieu/client, le programme des sessions et un QR/lien vers `/hub/{hub_token}/play`.
- La vue play affiche les memes informations cote joueur et propose seulement un CTA manuel vers `/play/{game}/{session_token}` quand une session du jour est clairement disponible.
- Les routes directes session restent inchangées: `/master/{token}`, `/play/{game}/{token}`, `/remote/{game}/{token}`.
- Aucun lancement, edition, scoring, lot, option, inscription joueur, participant hub, classement hub, polling ou WS hub n'est ajoute.
- Le branding est lu via le helper global existant; aucune ecriture branding n'est effectuee par ces pages.

## Update 2026-07-07 — Supra-interface soiree/evenement: conteneur Lot 1
- Le conteneur technique `games_hubs` est porte par `global`, pas par le runtime Canvas.
- Le pivot PRO initialise un hub par date/contexte pour preparer la future experience soiree/evenement.
- Les routes directes session restent inchangées: `/master/{token}`, `/play/{game}/{token}`, `/remote/{game}/{token}`.
- Aucune interface master/play/remote hub n'est creee dans ce lot.
- Les sessions restent l'unite d'execution; le hub ne modifie ni scoring, ni lots, ni options, ni inscriptions session, ni WS.

## Update 2026-07-06 — Blind Test: rendu equipes runtime
- Les surfaces organizer/master et remote affichent les equipes runtime Blind Test avec leur nom public brut.
- Le nombre de membres n'est plus ajoute au libelle public (`Nom equipe` au lieu de `Nom equipe (2)`).
- Les lignes equipe sont identifiees visuellement par un badge compact `ÉQUIPE`.
- Cote player, pendant une partie Blind Test, un membre d'equipe voit un bandeau commun avec pastille interne `ÉQUIPE` et nom equipe brut; le meme bandeau evolue vers le feedback quand un coequipier repond.
- Les champs techniques restent disponibles pour les compteurs: `teamMemberCount`, `members`, `totalPlayers`, `rankingEntriesTotal`.
- Depuis le 2026-07-07, si les compteurs runtime indiquent moins de 2 membres, les surfaces Canvas/remote traitent l'entree comme joueur solo: pas de badge `ÉQUIPE`, pas de remplacement du pseudo par `teamName`.
- Depuis le 2026-07-07, le player mobile n'affiche le bandeau `ÉQUIPE · {teamName}` et les textes `Ton équipe...` que si le payload runtime indique une equipe active; l'etat lobby `teamState` seul ne suffit plus pendant la partie.
- Depuis le 2026-07-07, la remote Blind Test normalise ses listes d'affichage: le lobby peut afficher une equipe préparée comme groupe sans doubler ses membres en lignes principales, et les classements/podiums remote retirent les membres couverts par une vraie entree equipe runtime 2+.
- Le scoring, les rangs, les IDs et la persistance ne changent pas.

## Update 2026-07-03 — Player Blind Test: equipes runtime
- L'ecran joueur Blind Test en attente affiche une carte equipe apres inscription WS, sans changer le formulaire pseudo ni le tunnel compte joueur.
- La carte explique le principe V1: chaque membre garde son mobile, mais la premiere reponse envoyee par un membre compte pour toute l'equipe sur le morceau.
- `play-ws.js` demande l'etat equipe via `teamList` apres `registrationSuccess`, puis relaie `teamState` / `teamError` au Bus.
- `play-ui.js` rend la carte equipe, permet `teamCreate`, `teamJoinByCode` et `teamLeave`, affiche le code equipe aux membres et verrouille l'UI quand le serveur indique `locked=true`.
- La carte equipe a trois etats exclusifs: solo avec texte court et CTA `Former une équipe`, membre avec nom/code/compteur et CTA `Quitter l'équipe`, saisie code avec CTA `Rejoindre l'équipe` et `Annuler`.
- Les CTA de la carte equipe utilisent des boutons rectangulaires dedies aux textes longs; les boutons ronds globaux du player restent reserves aux controles iconiques.
- En cours de morceau, quand un coequipier a deja repondu, le player garde les propositions visibles mais desactivees, affiche un bandeau court au-dessus de la grille (`pending`, `success`, `error`) et alimente le badge points avec le resultat de l'equipe sur ce morceau.
- Le footer score/rang consomme les champs `teamMode`, `teamId`, `teamName`, `playerScore`, `playerRank` de `updatePlayers`; en l'absence de mode equipe, le comportement joueur existant reste inchange.
- L'affichage du compteur equipe reste pilote par le dernier `teamState`; les `updatePlayers` de score/rang ne remplacent plus le statut membre.
- Quiz et Bingo ne sont pas actifs sur cette carte: le markup est borne a `data-game-only="blindtest"` et les handlers verifient `gameSlug() === "blindtest"`.

## Update 2026-07-06 — Blind Test: persistance equipes runtime
- Le bridge Canvas `blindtest:session_update` accepte maintenant un classement final optionnel (`players`, `rankings` ou `finalRankings`) en plus du podium existant.
- Quand ce classement contient des entrees equipe, le bridge persiste uniquement ces equipes dans `blindtest_session_teams`, avec nom snapshot, nom normalise, score final, rang final, nombre de membres et `members_json`.
- `blindtest_players` reste strictement la table des vrais joueurs; aucune equipe runtime n'y est injectee et la table legacy `equipes` n'est pas utilisee.
- La persistance equipe est non bloquante: si la table n'est pas encore migree ou si l'upsert echoue, `podium_json` et l'etat de session continuent d'etre sauvegardes, avec log support `blindtest_session_teams`.

## Update 2026-07-06 — Player Blind Test: fin de partie equipe
- Le player distingue maintenant le total de joueurs connectes reels du total de participants de classement.
- Le badge joueurs continue d'afficher les joueurs connectes reels.
- Le footer `Classement` et l'ecran de fin utilisent les participants de classement: equipes runtime + joueurs solo.
- Quand l'entree finale du joueur est une equipe, les textes deviennent `Ton équipe termine...` et `Ton équipe remporte...`; un solo dans une session mixte garde le wording individuel.

## Update 2026-06-26 — Formats courts Blind Test/Bingo
- Blind Test lit maintenant `championnats_sessions.id_format` depuis le token de session.
- Le format court `id_format=5` ne cree pas de playlist client: la playlist source est triee par position/id_morceau, puis un ordre stable pseudo-aleatoire est calcule par `sha256(id_session|id_morceau)` et limite a 20 titres.
- Le format standard conserve la playlist source complete, avec ordre stable par position/id_morceau.
- Bingo Canvas reconnait le format 5 comme une grille 3x3 pour les controles de lignes papier.
- Le player Bingo ne deduit plus seulement le layout du nombre de numeros: `grid_assign` / `grid_hydrate` exposent `gridFormat`, `gridCols`, `gridRows` et `gridCellCount`, et le front rend 9 cases en 3x3 pour le format court meme si un payload legacy embarque 20 numeros.
- Cotton Quiz n'est pas modifie par ce format.

## Update 2026-06-24 — Quiz lot_ids: socle `N` numérique
- Le resolver Quiz Canvas accepte maintenant les tokens `N{id}` dans `championnats_sessions.lot_ids`, en complément de `L{id}` (lot catalogue `questions`) et `T{id}` (lot temporaire papier `questions_lots_temp`).
- Hotfix boot: la validation de `quiz_resolve_token()` accepte aussi `N{id}`; une session de test en `lot_ids='N1'` ne doit plus echouer sur `playlistId manquant ou invalide`.
- `N{id}` résout `questions_lots_num_temp.question_ids`, puis lit les questions dans `questions_numeriques`; les propositions fausses sont portées inline par `proposition_1..3` et exposées au front sous la même forme que le legacy (`proposition_1..4`, `lotId`, `lotName`).
- La garde serveur de bascule papier -> numérique accepte les playlists mixtes `L/T/N` et valide les questions `N` avec le même critère minimum: réponse non vide et au moins une proposition fausse distincte.
- Cette passe ne change ni génération rapide, ni génération papier `T`, ni scoring, ni WS, ni UI player/organizer.

## Update 2026-06-22 — Sessions demo: bascule papier avant lancement
- Les sessions demo restent numeriques par defaut, mais le switch `Version` de la modale Options est maintenant disponible aussi en demo tant que la session est en attente.
- Le verrou de format Canvas ne traite plus `flag_session_demo=1` comme un verrou permanent: il reutilise les phases runtime (`En attente` / phase 0 autorisee, session demarree verrouillee) pour Quiz, Blind Test et Bingo.
- Une demo papier n'affiche plus le parcours joueur numerique integre inutile: le panneau iframe desktop demo n'est pas rendu au chargement si la demo est deja papier, et il est masque/vide si l'organisateur bascule en papier.
- Le layout split demo est pilote par une visibilite explicite du panneau: en bascule dynamique vers papier, le listener `options/updated` relit le champ papier sauvegarde, le panneau est marque desactive/cache pour neutraliser `d-lg-flex` et les regles CSS `:has(...)`; en retour numerique, le panneau, les metriques viewport et l'iframe demo sont restaures.
- Les gardes existantes restent en place pour les sessions lancees, en pause, terminees ou archivees via `format_locked` / `FORMAT_SWITCH_LOCKED`; les sessions officielles, quotas, scoring numerique et flux WS ne changent pas.

## Update 2026-06-12 — Remote Quiz papier: contexte courant preserve apres correction
- Le connecteur remote (`remote-ws.js`) utilise maintenant `window.Preload.playlist.songs` comme fallback lorsque l'etat WS porte un `currentSongIndex` mais que la playlist WS interne n'est pas encore hydratee.
- Ce fallback restaure l'item courant, la serie courante et le bouton de lancement de support en session Quiz papier apres reload remote ou apres un ACK score suivi d'un refresh partiel.
- Le flow `persist before WS` des corrections papier reste inchange: ACK HTTP avant toast, puis WS `admin_set_score` best-effort.
- Aucun contrat front ni serveur WS n'est modifie.

## Update 2026-06-12 — Remote papier Blind Test/Bingo: persistance avant refresh WS
- Blind Test utilise maintenant le meme chemin fiable que Quiz pour la correction de score papier: `remoteApi('update_score')` confirme la persistance HTTP avant le WS `admin_set_score`; le bridge Blind Test ajoute les logs `REMOTE_PAPER_WRITE_RX` / `REMOTE_PAPER_WRITE_PERSISTED`.
- Bingo papier persiste les attributions gagnantes avec joueur via `bingo:phase_winner` depuis la remote avant d'emettre `admin_phase_winner`.
- Le message WS Bingo devient un refresh best-effort avec `persisted=true`, `wonPhase`, `nextPhase` et `requiresResync=true`; si l'organizer/master n'est pas connecte au moment du broadcast, le gagnant reste rehydratable depuis `bingo_phase_winners` / l'etat Canvas.
- Les ajouts de participants remote papier restent deja conformes: `player_register` HTTP avant `admin_player_register`.
- Aucun flux de session numerique n'est modifie.

## Update 2026-06-12 — Remote papier Quiz: correction fiable hors primary WS
- En correction papier Quiz, la remote persiste maintenant les scores par HTTP Canvas bridge (`quiz:update_score`) avant d'emettre le WS `admin_set_score`.
- Le succes affiche cote remote depend donc d'un ACK HTTP post-write DB; le WS ne porte plus la fiabilite du write critique et sert seulement a rafraichir les sockets presentes.
- Si le primary organizer est momentanement absent, le write reste conserve en DB; au retour/reload, l'organizer et la remote doivent rehydrater les joueurs/scores depuis la source serveur (`players_get` / preload existant).
- Les logs cibles ajoutes couvrent reception remote, persistance DB, tentative/bypass WS, absence primary organizer avec `resync_required`, application de resync memoire et ACK renvoye.
- Aucun contrat de commande visible n'est renomme: `admin_set_score` reste le message WS de rafraichissement, `quiz:update_score` reste l'action bridge de persistence.

## Update 2026-06-04 — Officielle future: modale accueil preparation
- A la premiere ouverture organizer d'une session officielle future hors fenetre active, `boot_organizer.js` affiche une modale informative `Prépare ta session avant le jour J`.
- La condition reprend le contexte du garde-fou de lancement: session officielle non demo, non lancable, non ouverte, `sessionChronology=before`.
- L'astuce de cette modale est adaptee au support: pilotage mobile en desktop, lancement demo via bouton `Play` en mobile.
- La modale ne contient qu'un CTA `Fermer`, persiste sa fermeture en `localStorage` par session (`cotton_official_prep_modal_seen_{session_id}`) et ne declenche ni navigation ni duplication demo.
- Une fois cette modale fermee, le clic `Tester en démo` lance directement la duplication demo via le flux Pro `session_duplicate`; la modale de lancement existante reste le fallback si l'accueil n'a pas ete vu.
- Le QR de pilotage mobile reste borne a `demo || canLaunchOfficial`; aucune interface animateur/QR n'est ouverte pour l'officielle hors fenetre active.

## Update 2026-05-18 — Demo LP reseau: retour autorise vers la LP
- Le quit organizer des sessions demo continue de memoriser `return_url` depuis l'URL `/master/{token}`.
- La validation du retour accepte toujours les URLs PRO `/extranet/...`.
- Elle accepte maintenant aussi les URLs `www` strictement bornees a `/lp/reseau/...` et `/lp/operation/...`, afin que les demos lancees depuis une LP reseau/operation reviennent sur leur page d'origine.
- Les chemins relatifs `/lp/reseau/...` et `/lp/operation/...` sont normalises contre `AppConfig.wwwUrl`, pas contre l'origine `games`.
- Les autres origines et chemins `www` restent refuses.

## Update 2026-05-06 — Demo site mobile: CTA lancement explicite
- En vue organizer mobile numerique, les demos publiques du site rattachees au compte Cotton WWW Online Demos / Cotton Online Demos (`id_client=1557` + `flag_session_demo=1`) affichent `Lancer la démo` sur le bouton principal de lancement quand ce bouton est la seule action de la barre basse.
- Les demos clients, sessions officielles et sessions papier conservent le rendu mobile existant.
- Le bouton garde les classes de CTA organizer existantes (`btn btn-primary orga-btn px-4`); seul le comportement responsive qui force le rond icone seule est neutralise pour ce cas cible.
- Aucun changement WS, bridge, scoring, inscription joueur, reset Bingo ou logique de jeu Quiz / Blind Test / Bingo.

## Update 2026-05-05 — Bingo reset demo termine: neutralisation front post-API
- Apres une reponse `resetdemo` OK en demo Bingo, l'organizer remet localement le store en `En attente`, vide winners/medailles/podium Bingo et resynchronise l'iframe joueur GM avant le reload.
- Le signal `bingo_postreset=1` est maintenant stocke en pending global si `canvas_display.js` n'a pas encore attache son listener; il est consomme des que l'UI organizer est prete.
- Cote organizer, un snapshot Bingo demo phase `0` purge aussi les winners/medailles/podium front afin qu'un etat terminal precedent ne survive pas au reset DB.
- Cote player, `demo_reset` annule les flags locaux de fin statique/reconnexion supprimee avant de repasser en `En attente`, vider la grille et reload.
- Le reset demo ecrit aussi une generation locale `bingo_reset_epoch:{sessionId}` et purge les anciennes cles `bingo_checked` / `bingo_locked` scoppées a la session. L'iframe GM recoit cette generation dans son URL (`bingo_reset_epoch`) pour que les cles `sessionId + player_id + gridId` de l'ancienne partie ne soient plus considerees valides.
- Cette generation reste limitee au stockage local: au nouveau lancement Bingo, les signaux live player `state`, `reset_game` et `passed_song` avec phase demarree consomment le runtime post-reset, remettent `mainStarted=true` et poussent la grille afin que l'iframe GM quitte l'ecran d'attente sans rehydrater les anciennes cases.
- Les traces `ui/bingo:grid_hydrate:trace` indiquent maintenant l'epoch, le nombre de cases/locks locaux, les cases DB et la source appliquee (`local`, `db`, `empty`, `reset`).
- Les traces `ui/bingo:postreset:consumed`, `ui/bingo:start_after_reset:received` et `ui/bingo:start_after_reset:applied` documentent la sortie d'attente post-reset avec `sessionId`, `player_id`, `gridId`, `resetEpoch`, phase et `mainStarted`.
- Aucun changement serveur WS Bingo ni contrat DB: la source terminale est toujours neutralisee par `resetdemo` cote PHP (`phase_courante=0`, winners/grilles/gains remis a neutre), le front evite seulement de reutiliser un cache runtime terminal apres cette reponse OK.

## Update 2026-05-05 — Bingo GM iframe: etat de grille scoppé
- En Bingo, l'etat local des cases cochees et verrouillees du player est maintenant scoppé par `game + sessionId + player_id + gridId`.
- Les anciennes cles globales `bingo_checked` et `bingo_locked` ne sont plus relues pour hydrater l'etat joueur; elles sont supprimees lors des sauvegardes Bingo.
- Pour l'etat des cases, le contexte de stockage exige la cle scoppée `${game}:grid_id:${sessionId}` et ne retombe plus sur `bingo_grid_id` legacy.
- L'iframe organizer `embed=gm` ne doit donc plus reprendre un etat stale d'une autre grille ou d'un ancien joueur, ce qui pouvait afficher la grille entierement cochee et verrouillee des l'inscription.
- `grid_hydrate` reste le fallback de reprise DB quand aucun etat local prouve n'existe; si un etat local scoppé existe, il reste prioritaire pour preserver les cases deja cochees avant reload.
- `play-ws.js` applique la meme resolution scoppée dans le fallback `emitGridIfAvailable()`.
- Sur `demo_reset` et `reset_game`, le player purge aussi les cles scoppées de la session courante et vide `AppConfig.bingoChecked` / `AppConfig.bingoLocked`; un reset demo ne doit donc pas rehydrater une grille depuis l'etat local precedent.
- Aucun contrat WS Bingo, adapter PHP, schema DB, session papier ou flux joueur QR n'est modifie.

## Update 2026-05-05 — Organizer iframe: postMessage et iframe active
- `canvas_display.js` n'accepte plus `gm-player-ready` que depuis une iframe organizer connue (`demo-player-iframe` ou `player-iframe`), avec une origine strictement attendue (`window.location.origin` ou l'origine calculee de `AppConfig.gameUrl`).
- Le payload `gm-player-ready` doit correspondre a la session et au jeu courants; Bingo exige aussi une identite joueur et une grille (`gridId` ou `gridNumber`) pour conserver le contrat de grille assignee.
- La configuration iframe est maintenant contextuelle: preview desktop demo uniquement en layout desktop, iframe mobile `Jouer` uniquement en session numerique mobile active, aucune iframe auto en papier mobile.
- Quand une iframe organizer devient active, les autres iframes joueur organizer chargees sont dechargees pour eviter deux connexions WS concurrentes.
- Le comportement metier des pseudos auto-GM reste inchangé: les collisions de display name ne rebloquent pas `organizer_auto_player` / `gm_autoreg`.
- TODO produit: si les collisions de display name deviennent genantes visuellement, traiter par suffixe d'affichage type `(orga)` sans changer le `player_id` stable ni les regles d'upsert.

## Update 2026-05-05 — Mobile officiel: profil joueur auto organizer
- En session officielle mobile numerique, l'onglet organizer `Jouer` utilise un display name de joueur auto issu du prenom du contact connecte quand il est disponible.
- Source prioritaire: `$_SESSION['client_contact_prenom']`; fallback serveur: contact recupere depuis la trace `clients_logs` de creation de session puis `client_contact_get_detail()`.
- Si aucun prenom fiable n'est trouve, le libelle visible reste `Game Master`.
- `canvas_display.js` transmet ce display name uniquement aux iframes organizer officielles via `gm_display_name`; les vrais joueurs QR ne recoivent pas ce parametre.
- Au primo-boot d'une URL `embed=gm`, `player_canvas.php` initialise le HTML en gate fermee avec un message de preparation du profil, puis `register.js` garde l'etat `GM_AUTOREGISTERING` jusqu'a la fin de l'auto-register. Le formulaire manuel reste reserve aux URLs joueur reelles.
- Si l'iframe `embed=gm` a deja une identite locale valide pour la meme session, `register.js` reprend cette identite comme auto-player organizer sans afficher le formulaire manuel, meme si un probe de reprise `players_get` rate ponctuellement.
- Si l'URL iframe calculee change apres lazy-load, le `src` charge est realigne sur `dataset.src` pour ne pas garder un ancien embed sans `gm_display_name`.
- `register.js` utilise ce display name comme `username` visible pour l'auto-register `embed=gm`, sans modifier le `player_id` stable ni les regles d'inscription.
- La vue mobile organizer affiche hors iframe, sous le toggle `Animer / Jouer`, une aide discrete: `Tu joues avec le profil {displayName}.`
- Les demos conservent leurs labels: `Équipe démo` en Quiz, `Joueur démo` en Blind Test / Bingo; cette aide officielle n'est pas affichee en demo.

## Update 2026-05-05 — Design organizer: sauvegarde partielle securisee
- Le save design organizer reste compatible avec les payloads complets existants, mais la securite est maintenant cote serveur/persistance.
- Cote `global`, couleurs, couleur de texte et police sont fusionnees avec le branding existant si une cle est absente du POST.
- Logo et visuel sont preserves quand le payload ne contient pas de nouveau media; leur suppression requiert maintenant `logo_clear=1` ou `visuel_clear=1`.
- Cote `games`, `session_modals.js` n'envoie ces marqueurs de suppression que lors d'un reset media explicite depuis l'UI.
- `prizes_save` preserve maintenant `diffusion_message` quand `mainTitle` est absent, afin qu'un payload lots-only ne vide pas le titre.
- Player, remote et iframe demo continuent de consommer le branding effectif par les chemins existants: hydration API au chargement/reconnexion et `update_branding` en live.
- En live, `update_branding` est reconstruit depuis le branding effectif renvoye par `branding_save`; si ce retour serveur n'est pas encore disponible, le front preserve les URLs `logo` / `visuel` deja connues au lieu d'envoyer un branding media-vide.
- Les pages player/remote exposent la police initiale via `--branding-font` et leur `body` lit cette variable, pour permettre a `player/branding` et `remote/branding` de changer la police sans refresh.
- `CANVAS_ASSET_VER` est bump localement en `v=2026-05-05_19` pour eviter que les interfaces restent sur un ancien JS Canvas.

## Update 2026-05-05 — Mobile organizer V1: ajustements UX visuels
- L'aide demo mobile sous QR indique maintenant les deux parcours de test attendus: flasher le QR code depuis un mobile, ou lancer la demo puis ouvrir l'onglet `Jouer`.
- Le countdown de lancement mobile est agrandi via CSS uniquement; la logique et les timings restent inchanges.
- Les bordures colorees des blocs organizer mobiles sont allegees en mobile sans changer les couleurs de marque ni le rendu desktop.
- Le toggle mobile `Animer / Jouer` est legerement compact en conservant une cible tactile minimale.
- Aucun flux WS, scoring, inscription joueur, iframe joueur ou reprise demo n'est modifie.

## Update 2026-05-05 — Mobile organizer V1: containment desktop
- Les blocs de session mobile organizer (`#mobile-session-toggle-wrap`, `#mobile-session-followup`, `#mobile-player-view`, `.mobile-session-pause-row`) restent masques en layout desktop meme si `setPhase()` appelle `showAll()` pendant `En cours` ou `Pause`.
- La ligne pause teleporteable par `canvas_display.js` cible uniquement la ligne desktop de `#pause-container` ou son host de teleport, et exclut explicitement `.mobile-session-pause-row`.
- Les helpers d'entete de pause inter-series ciblent maintenant le bloc status de pause desktop, pas le premier tag `.leaderboard-*` global.
- Les styles desktop de `.pause-row` sont scopes au conteneur pause desktop/host de teleport; ils ne s'appliquent plus a la ligne mobile compacte visuel + QR.
- Aucun changement de flux joueur, d'auto-register, de scoring ou de session papier: la passe borne seulement les effets visuels mobile/desktop.

## Update 2026-05-04 — Demo mobile organizer: aide QR sans inscription pre-lancement
- En demo mobile numerique avant lancement, `organizer_canvas.php` affiche sous le compteur joueurs du bloc QR: `Lance la démo, puis passe sur l’onglet Jouer pour tester l’expérience joueur.`
- Cette aide est limitee aux demos numeriques en attente: elle n'est pas affichee en session officielle, ni en session papier, et disparait avec la vue d'attente apres lancement.
- Aucun parcours d'inscription joueur n'est introduit avant lancement: pas de CTA sous QR, pas de `organizer_signup=1`, pas d'ecoute `organizer-signup-complete`, pas d'ouverture iframe player pour inscrire l'organisateur.
- L'auto-register `embed=gm` reste conserve apres lancement et pour la preview desktop demo.
- En session officielle numerique, l'auto-register garde le libelle `Game Master`.
- En demo, `register.js` nomme le participant auto-inscrit `Équipe démo` pour Quiz, et `Joueur démo` pour Blind Test / Bingo Musical.
- En papier mobile, le toggle `Jouer`, l'iframe player et l'auto-register participant papier restent absents.

## Update 2026-05-04 — Mobile organizer lance: correctifs UX Animer / Jouer
- Ces correctifs s'appliquent a toutes les sessions mobiles numeriques lancees, demo comme officielles, sur Quiz / Blind Test / Bingo Musical.
- En posture `Animer`, `#mobile-session-followup` conserve une reserve basse plus confortable en numerique non papier, afin que les blocs lots et QR puissent scroller au-dessus de la barre d'actions mobile fixe.
- En posture `Jouer`, le wrapper mobile de l'iframe player ne porte plus le tag `VUE JOUEUR` ni le cadre `container-rounded-colored`; le toggle actif suffit a indiquer le contexte.
- Le contenu interne de `player_canvas.php`, le flux `embed=gm`, les noms `Équipe démo` / `Joueur démo` / `Game Master` et les sessions papier mobiles ne changent pas.

## Update 2026-05-04 — Mobile organizer Animer: support audio et bas de page compact
- En posture mobile `Animer`, numerique comme papier, la vague audio de `#quiz-support` est recentree dans le bloc noir sans changer le rendu desktop.
- Le bas de `#mobile-session-followup` utilise maintenant une ligne compacte `visuel de jeu + QR de rejointure` au lieu d'un QR seul en grand sous les lots.
- Le bloc `Lots à gagner !` garde un padding/margin bas supplementaire en posture mobile `Animer`, afin de rester separe de la ligne visuel/QR et de la barre d'actions fixe.
- La vue mobile en attente, l'aide demo sous QR, la vue `Jouer`, l'auto-register et la demo desktop ne changent pas.

## Update 2026-05-04 — Mobile organizer: auto-register GM et suivi joueurs
- L'iframe GM mobile d'une session demo recoit maintenant `gm_demo=1`; ce marqueur permet a `register.js` d'utiliser `Équipe démo` en Quiz et `Joueur démo` en Blind Test / Bingo Musical sans activer le layout desktop `demo_player=1`.
- `demo_player=1` reste reserve a la preview desktop demo.
- Apres auto-register `embed=gm`, le player poste `gm-player-ready` au parent organizer avec `playerId`, `playerDbId`, `playerName`, `game` et les infos de grille Bingo disponibles.
- `canvas_display.js` merge ce joueur dans `GameStore.players` et rerend immediatement compteur + listes, pour eviter l'etat `1 joueur connecté` sans ligne dans `Suivi des joueurs`.
- Les evenements WS qui ne fournissent qu'un total (`num_connected_players` / `updatePlayers` sans lignes detaillees) ne purgent plus le roster local quand le total reste positif; le snapshot detaille suivant reste autoritaire.
- Les sessions officielles numeriques gardent `Game Master`; les sessions papier mobiles ne creent toujours aucun participant automatiquement.

## Update 2026-05-04 — Mobile organizer: reprise identite GM apres reload
- Avant toute nouvelle inscription `embed=gm`, `register.js` tente de reprendre l'identite locale scoppée a la session (`player_identity`, id DB, pseudo) et ouvre directement la scene player.
- Si le stockage local est absent mais que le roster serveur contient deja le joueur auto-inscrit attendu, `register.js` le reconcilie via `players_get` et restaure `player_identity`.
- A la reprise d'une demo mobile numerique en cours, `canvas_display.js` relit aussi `players_get` cote organizer pour hydrater `GameStore.players`, restaurer le `player_identity` local et afficher le joueur/score dans `Animer` sans attendre l'ouverture de `Jouer`.
- L'iframe GM republie le message parent existant `gm-player-ready` quand son score/rang change; le parent merge ce payload dans le suivi joueurs pour eviter de dependre d'une pause ou d'un refresh long.
- En demo, la reconciliation accepte aussi l'ancien nom `Game Master` comme candidat legacy pour eviter un doublon apres la regression, mais republie le nom attendu (`Équipe démo` ou `Joueur démo`) dans l'iframe et vers le parent organizer.
- Bingo conserve `player_id` canonique `p:` comme source principale; `playerId` numerique reste seulement l'id DB associe.
- Les logs front discrets `register/autoreg:reconciled` et `register/autoreg:reconcile_multiple_candidates` documentent la source de reprise et les ambiguites eventuelles.

## Update 2026-05-04 — Mobile organizer: vue stable Animer / Jouer pendant session
- Pendant une session numerique mobile (`En cours` ou `Pause`, non papier), `organizer_canvas.php` n'affiche plus automatiquement l'iframe Game Master / participant.
- Un toggle mobile `Animer / Jouer` est affiche au-dessus de `#quiz-display`.
- `Animer` est la posture par defaut:
  - `#quiz-display` reste visible en `En cours` comme en `Pause`;
  - en pause mobile numerique, `canvas_display.js` affiche les sections de jeu plutot que `#pause-container`, afin d'eviter un changement complet d'UI;
  - le suivi mobile sous `#quiz-display` reutilise le rendu pause mobile existant: leaderboard, `pause-row`, `lots-container`, QR.
- Pendant le jingle de depart (`#intro-jingle-timer` / `status.loadingJingle`), le toggle et les blocs complementaires mobiles sont masques temporairement; `#quiz-display` conserve l'animation existante.
- `Jouer` masque la posture organizer et affiche `#player-iframe` avec le flux existant `embed=gm`; l'URL et le fonctionnement interne de l'iframe ne changent pas.
- En session papier mobile, aucun toggle n'est affiche: `#quiz-display` reste aussi la vue de reference en `En cours` et `Pause`; le meme `#mobile-session-followup` que la posture numerique `Animer` est reutilise sous le jeu pour le suivi joueurs/etat, les lots et le QR.
- La reserve basse de la vue papier mobile est portee par ce conteneur mobile commun, afin que le QR puisse scroller entierement au-dessus de la footerbar sans agrandir artificiellement une card.
- Les espacements mobiles separent maintenant les besoins: `#quiz-display.en-cours` ne porte plus la marge footerbar globale, le suivi sous `Animer` protege son dernier bloc par son padding bas, et la vue `Jouer` porte sa propre marge de securite autour de l'iframe.
- Les marges propres a la session mobile gardent un peu d'air entre le toggle numerique, `#quiz-display` et les blocs repris de la pause pour eviter que les tags absolus chevauchent visuellement la section precedente; le bloc lots mobile force une hauteur automatique et garde les lignes de lots proches du titre.
- Le titre du bloc joueurs mobile reste le tag existant mais suit `status.gameStatus`: `Suivi des joueurs` en `En cours`, `Pause` en `Pause`.
- Cote Quiz uniquement, la posture mobile `Animer` masque l'overlay `#quiz-leaderboard-overlay` (`Point scores !`) dans `#quiz-display`, car le suivi joueurs mobile est deja affiche juste dessous; la posture `Jouer`, le desktop et les autres jeux ne sont pas concernes.
- Toujours cote Quiz mobile `Animer`, la strategie player conserve maintenant `#quiz-question` visible lors du rendu des questions suivantes, meme si le rendu du support arrive avant la pose de `body.mobile-session-organizer-active`; l'ancien masquage mobile numerique reste reserve aux contextes hors posture organizer.
- Au basculement vers `Jouer`, l'iframe redemande le recalcul de hauteur `gm-iframe-size-request` deja supporte par le player; une hauteur minimale mobile sert de repli CSS et la mesure `embed=gm` evite de prendre le viewport comme hauteur minimale artificielle.
- Invariants: desktop, avant session, fin de session, mode papier, WS/API/DB et footerbar mobile sont inchanges.
- Vigilance V1: `Animer` garde le support courant et la question/etat de jeu; un organisateur qui participe depuis le meme telephone doit utiliser `Jouer` pour eviter de consulter la posture organizer.

## Update 2026-05-04 — Demo desktop Bingo: Vue joueur integree
- Sur les sessions demo desktop Quiz, Blind Test et Bingo Musical, `organizer_canvas.php` affiche un panneau `Vue joueur` avec une iframe player existante.
- L'iframe est ouverte avec `embed=gm&demo_player=1`; `register.js` utilise alors le libelle demo du jeu (`Équipe démo` pour Quiz, `Joueur démo` pour Blind Test / Bingo Musical) au lieu de `Game Master`.
- Cette iframe recoit seule la classe `demo-player-embed`: la preview desktop est rendue dans une coque telephone centree avec des teintes de fond derivees de la couleur client, des espacements compacts, un contenu scrollable a hauteur explicite, la footerbar score/classement visible, des interactions souris desktop et un box model borne pour eviter le rognage lateral, sans modifier le comportement de l'iframe Game Master mobile.
- Quand cette preview est visible, `canvas_display.js` mesure le cockpit organizer reel (`.main-section .responsive-center`) et expose `--organizer-viewport-width` / `--organizer-qr-max-size`; le QR principal se dimensionne donc selon la largeur utile hors panneau `Vue joueur`.
- Le panneau `Vue joueur` utilise aussi `--demo-player-scene-top` / `--demo-player-scene-height`, calculees depuis l'union du header organizer et de la scene organizer visible, afin de s'aligner verticalement sur les blocs organizer sans safe area specifique au-dessus de la footerbar.
- `play-ws.js` propage `demoParticipant:true` au WS comme meta demo; depuis le 2026-05-04, ce flag ne donne plus d'exemption quota: le participant automatique demo compte dans `maxPlayers`, comme un joueur mobile.
- Pour Bingo, l'iframe reutilise le flux Game Master mobile existant: auto-register dans `bingo_players`, appel `grid_assign`, stockage `bingo_grid_secret`, puis auth WS `auth_player`. La grille de `Joueur démo` est donc une vraie grille Bingo et consomme la meme capacite demo qu'un joueur mobile.
- Le QR code principal reste visible et porte le wording demo `Scannez le QR code pour tester aussi depuis votre téléphone.`
- Le reset demo Bingo conserve le contrat existant: purge des winners et etats locaux, conservation des rows `bingo_players` et des assignations de grilles.

## Update 2026-04-23 — Organizer: test pre-lancement V1
- addendum 2026-04-27:
  - le prelaunch organizer est recentre sur la configuration du poste: le scan des supports multimedia n'est plus lance ni affiche cote organizer;
  - le code de diagnostic supports reste conserve pour reutilisation ulterieure cote `pro`;
  - le bouton footerbar `Verif` est retire; la pastille de statut prelaunch est maintenant portee par le bouton `Lancer`;
  - la confirmation de lancement affiche la mini synthese du test technique et le controle du son;
  - un statut rouge bloque le lancement dans la confirmation, mais ne desactive plus le bouton `Lancer` en amont.
  - le controle du son de la synthese prelaunch expose maintenant un bouton `Stop` apres lancement du jingle temoin;
  - la fermeture de la modale de test coupe aussi automatiquement le jingle temoin en cours;
  - `web/organizer_canvas.php` encode maintenant toutes les donnees serveur injectees dans des scripts inline via un helper JSON dedie;
  - ce helper conserve l'Unicode mais echappe les caracteres HTML sensibles (`<`, `>`, `&`, quotes) et substitue les octets UTF-8 invalides;
  - objectif: empecher une donnee de preload/playlist/lot/branding de fermer ou casser une balise `<script>`, ce qui pouvait tronquer le DOM avant la footerbar organizer sur certains contenus demo.
  - le profil reseau lent est maintenant centralise dans `web/includes/canvas/core/network_profile.js`, partage entre prelaunch et player;
  - le prelaunch re-evalue le check `network_profile` sur changement `navigator.connection` pendant une session en attente, sans relancer tous les checks;
  - il relit aussi ce profil apres la fin du test initial pour couvrir le cas DevTools ou `Slow 4G` est deja actif au chargement mais stabilise dans l'API navigateur quelques instants plus tard;
  - il complete ce signal navigateur par `network_probe`, une mesure HTTP reelle vers un asset Cotton, utilisable sur les navigateurs qui n'exposent pas `navigator.connection`;
  - il controle aussi l'environnement YouTube via `media_dependency`, en reutilisant `yt_loader.js` pour charger l'API iframe sans monter de player temoin pendant l'auto-check;
  - le jingle temoin reste le chemin de test player/lecture YouTube complet au clic utilisateur;
  - les conseils de la confirmation de lancement distinguent les cas reseau lent, mesure reseau incomplete, YouTube lent/bloque et proposent uniquement les actions validees cote utilisateur;
  - addendum: la modale prelaunch s'ouvre maintenant au chargement des sessions ouvrables; l'etape 1 automatique affiche le resultat de configuration, puis l'etape 2 `Player et volume` se lance uniquement sur bouton utilisateur;
  - addendum 2026-04-28: cette modale affiche maintenant deux panneaux fixes visibles des l'ouverture: connexion/stabilite avec test automatique, puis player/volume avec jingle temoin au clic. Chaque panneau affiche sa raison principale, ses actions recommandees et une relance ciblee;
  - addendum 2026-04-28: le controle lien/QR joueur est rattache au panneau configuration, les actions de correction demandent de relancer le test plutot que de recharger la page, et l'action stockage cible navigation privee + stockage local;
  - addendum 2026-04-28: le panneau jingle temoin reste factuel et verifie uniquement le demarrage du player; il ne conclut plus sur le volume/son, mais ajoute en succes un conseil utilisateur si le jingle n'est pas entendu;
  - addendum 2026-04-28: le jingle temoin ne peut etre lance qu'apres la fin de la verification configuration/connexion, afin d'eviter les tests concurrents;
  - addendum 2026-04-28: un jingle temoin qui ne demarre pas est diagnostique comme probleme de player/lecture, pas comme probleme de volume; un echec YouTube ne genere donc plus de conseil de sortie audio;
  - addendum 2026-04-28: les wordings visibles du parcours prelaunch actuel sont reformules en tutoiement, sans jargon technique visible; la logique du test reste inchangee et les textes legacy du scan complet des supports/remplacements temporaires ne sont pas repris dans cette passe.
  - addendum 2026-04-28: le jingle temoin n'a plus de bouton `Stop`; fermer la modale coupe toujours le test en cours, et le resultat player/volume n'est affiche qu'apres demarrage effectif du jingle;
  - addendum 2026-04-29: la modale prelaunch garde les deux panneaux fixes, mais adopte un rendu checklist plus friendly: header plus accueillant, icones de domaine, badges de statut compacts, fonds vert/orange/rouge adoucis et actions `Relancer le test` plus explicites; la logique, les seuils et les blocages restent inchanges.
  - addendum 2026-04-30: sur les sessions demo, le prelaunch automatique continue de tourner en arriere-plan; le vert n'ouvre pas la modale diagnostic et lance directement la demo au clic `Lancer`, l'orange ouvre la modale diagnostic au chargement puis affiche une confirmation legere avec `Lancer la démo` et `Voir le diagnostic`, et le rouge bloque en rouvrant le diagnostic.
  - addendum 2026-04-30: sur les sessions officielles, le prelaunch automatique n'ouvre pas la modale en vert, mais l'ouvre automatiquement en orange/rouge; la pastille `Lancer` reste mise a jour et le rouge bloque toujours au clic.
  - addendum 2026-04-30: la modale prelaunch s'intitule `Diagnostic avant lancement` avec le sous-titre `Vérification de cet appareil, de la connexion et du son.`; dans la confirmation officielle, l'avertissement metier reste prioritaire; en vert, seul un lien discret `Diagnostic réseau et son` place sous le CTA principal ouvre la modale prelaunch, et en orange le message `Point à vérifier avant ta session` est separe d'un CTA secondaire `Voir le diagnostic`.
  - addendum 2026-04-30: les bandeaux prelaunch auto orange/rouge ne s'affichent plus sur l'interface organizer tant que la session est en attente; la modale diagnostic au chargement, la confirmation/blocage au clic `Lancer` et la pastille portent l'information avant demarrage.
  - addendum 2026-04-30: le profil reseau ne classe plus une connexion cellulaire ou un `downlink` navigateur nul comme offline; `navigator.connection.type` reste affiche comme contexte, et le rouge vient de `navigator.onLine === false` ou des checks applicatifs bloquants existants.
  - addendum 2026-04-30: le check `network_profile` ne produit plus d'orange sur les seuls signaux `navigator.connection`; la vigilance `La connexion de cet appareil semble lente ou instable.` doit venir d'une mesure applicative lente/instable (`bridge`, `network_probe`, WS), pas du type cellulaire ou d'un profil navigateur prudent.
  - addendum: `media_dependency` est maintenant actualise par ce test player/volume, et non par un test de lecture sans interaction au chargement;
  - addendum: la confirmation de lancement ne porte plus le rappel prelaunch ni le controle audio; le garde-fou est applique avant lancement et sur l'acces remote/QR remote;
  - addendum: en session papier, la popup d'invitation a ouvrir la telecommande attend la fermeture de la modale prelaunch et reste masquee si le statut est rouge;
  - le player n'affiche plus le bandeau `Connexion lente detectee` tant que la session reste `En attente`, afin que l'alerte avant lancement soit portee par le prelaunch.
- addendum 2026-04-24:
  - le prelaunch organizer suit maintenant un etat runtime simple: `inactive`, `auto_running`, `manual_running`, `completed`, `cancelled`;
  - au chargement organizer, un pre-check automatique ne lance plus que l'etape 1 technique;
  - ce pre-check auto ne demarre ni scan multimedia ni controle du son;
  - le bouton `Test` garde le role de porte d'entree vers le module complet et relance un test full au clic si l'etat courant vient seulement du pre-check auto;
  - le bouton `Test` n'est visible qu'en `En attente`; hors de cet etat, il est masque et tout test en cours est coupe;
  - la footerbar organizer recycle maintenant les memes signaux produit:
    - pastille `Test` verte/orange/rouge selon le pre-check;
    - bandeau organizer partage absent si OK, orange si vigilance, rouge si incompatibilite;
    - bouton `Lancer` desactive uniquement pour les incompatibilites critiques de lancement.
  - l'alerte visible n'utilise plus un conteneur dedie sous la footerbar: elle passe par le meme bandeau partage que les alertes organizer de connexion, remonte dynamiquement au-dessus de `.organisateur-menu`.
  - le wording utilisateur du module est maintenant simplifie:
    - intro modale `On verifie rapidement que tout est pret sur ce poste.`;
    - note basse `Ce controle reflete la situation sur ce poste et ce reseau au moment du test.`;
    - etape 1 `Connexion et stabilite`;
    - synthese et rappels de lancement bases sur `Configuration verifiee / a surveiller / a corriger`;
    - diagnostics supports plus courts, moins techniques, sans mention `Controle catalogue Cotton`.
  - la phrase de synthese principale distingue maintenant la nature du probleme detecte:
    - connexion seule: synthese orientee connexion;
    - supports seuls: synthese orientee liens/supports;
    - cas mixte: synthese generique `Quelques points sont a surveiller avant le lancement.`;
    - cas OK: `Aucun point bloquant detecte.`
  - si la technique est correcte mais que des liens supports sont problematiques, la synthese n'accuse plus la connexion; elle bascule sur un message centré supports.
  - pendant le scan live de l'etape 2, l'UI n'affiche plus les metadonnees du support en cours (titre, artiste, question, bonne reponse):
    - `Verification du support n° X` et `On verifie ce lien...` restent visibles;
    - le detail support reste disponible ensuite dans la synthese et le bloc de remplacement.
  - dans la footerbar organizer, le bouton est maintenant libelle `Verif` et son tooltip est fixe a `Verifier la configuration avant lancement`.
  - le bandeau orange affiche maintenant `Connexion a surveiller. La partie peut etre lancee, mais certains medias peuvent demarrer avec un leger delai.` et disparait automatiquement comme le bandeau de connexion lente pendant le jeu;
  - le bandeau rouge affiche maintenant `Connexion insuffisante pour lancer dans de bonnes conditions. Verifie la connexion puis relance le test.` et suit lui aussi un affichage temporaire pour ne pas bloquer durablement l'acces a la footerbar.
  - en etat `En attente`, `Lancer` n'attend plus un `jingleReady` prealable: le jingle est prime pendant le clic de lancement lui-meme.
  - la footerbar organizer se rerend maintenant sur les evenements `prelaunch/*`, pour que l'etat du bouton `Lancer` suive bien la fin du test auto;
  - pendant un pre-check auto ou un test manuel, `Lancer` est indisponible; toute demande de lancement annule immediatement le test courant pour eviter qu'un scan continue apres demarrage de la session.
  - correctif perf 2026-04-24:
    - le watcher organizer du prelaunch ne reexecute plus `cancelPrelaunchCheck('game_not_pending')` sur chaque patch du store une fois la partie lancee;
    - il reagit maintenant uniquement aux vraies transitions de `status.gameStatus`, ce qui supprime la boucle de rerender/store observee apres passage en `En cours`;
    - l'initialisation du module est aussi verrouillee pour eviter un double abonnement accidentel.
- les incompatibilites critiques de lancement sont maintenant bornees strictement:
  - `organizer_boot`;
  - `storage`;
  - `session_context`;
  - `bridge`;
  - `ws_open`;
  - `ws_stability`;
  - `network_profile` si offline;
  - `media_dependency` si YouTube est bloque alors que la session contient des supports YouTube;
  - erreur runtime `prelaunch_runtime`.
- les echecs non critiques (ex. lien joueur/QR) restent visibles, mais basculent en vigilance orange plutot qu'en blocage rouge.
- l'organizer `games` expose maintenant un CTA de test pre-lancement dans la footerbar, a cote du bouton `Lancer`;
- le test est session-bound, manuel, centre organizer, et produit une synthese compacte orientee actions utiles.
- l'UI est structuree en deux vues:
  - un bloc de test automatique qui enchaine `Etape 1 — Verifications techniques`, puis `Etape 2 — Verification des supports multimedia`;
  - une synthese persistante plus legere, sans intro redondante, avec phrase de synthese douce, recommandations techniques si besoin, remplacements de liens et controle du son.
- apres un test termine, une reouverture de la modale affiche directement la synthese; l'organizer peut continuer les corrections ou relancer un test complet.
- module front:
  - `web/includes/canvas/core/prelaunch_check.js`;
  - import map exposee par `web/organizer_canvas.php`;
  - bootstrap depuis `web/includes/canvas/core/boot_organizer.js`.
- checks automatiques V1:
  - boot organizer;
  - stockage local/session;
  - contexte session;
  - bridge Canvas `session_meta_get`;
  - WebSocket ouverte;
  - stabilite WS courte;
  - lien joueur / QR.
  - l'etape 1 mesure aussi des signaux observables cote organizer: temps de reponse bridge, delai d'ouverture WS, absence de coupure WS sur courte fenetre, profil `navigator.connection` si disponible (`saveData`, `effectiveType`, `downlink`, `rtt`), disponibilite/latence de l'API iframe YouTube si la session contient des supports YouTube.
- rendu UX:
  - la modale n'affiche plus de bandeau global de statut;
  - l'etape 1 affiche uniquement le controle courant pendant l'analyse, avec statut `en cours`, puis vert/orange/rouge;
  - quand tout passe, la synthese garde une mention discrete de verification technique;
  - si les services repondent mais que des signaux sont lents ou fragiles, la synthese propose des ameliorations possibles sans promettre de debit ni de fluidite garantie;
  - si l'etape technique detecte une connexion indisponible ou une WebSocket KO/instable, le test s'arrete avant l'etape 2, masque la verification des supports multimedia et propose `Relancer le test`;
  - un profil navigateur offline (`navigator.onLine === false`) est libelle comme connexion Internet indisponible avec recommandation de reconnexion; les signaux `navigator.connection` (`type`, `effectiveType`, `downlink`, `rtt`, `saveData`) restent des signaux de contexte, pas un critere rouge ou orange unique;
  - les controles applicatifs exposes a l'utilisateur evitent le jargon technique: le bridge est presente comme une `Communication avec l’application`, avec messages de delai ou d'indisponibilite;
  - si le profil reseau est lent selon les seuils du player principal (`saveData`, `slow-2g`/`2g`/`3g`, downlink audio/video insuffisant, RTT eleve) ou si l'appel applicatif preflight mesure une latence > 2500 ms, le test affiche une vigilance forte et ne lance pas le scan exhaustif des supports, afin d'eviter des faux diagnostics lies au reseau;
  - une reponse bridge ou WebSocket lente mais fonctionnelle reste une vigilance et ne bloque pas a elle seule le scan media.
  - en echec bloquant, la synthese explique simplement pourquoi le lancement peut etre perturbe et affiche uniquement les points problematiques avec une action simple recommandee;
  - l'etape 2 demarre automatiquement apres l'etape 1;
  - l'etape 2 affiche uniquement le support courant pendant la verification, avec statut individuel vert/orange/rouge, puis alimente la synthese quand le controle est termine;
  - les supports problematiques sont presentes comme non bloquants pour le lancement, mais susceptibles de perturber certaines questions en `Quiz`, ou certains morceaux en `Blind Test` / `Bingo Musical`; ils restent en vigilance, sans rouge ni croix de blocage dans la synthese;
  - les supports musicaux problematiques proposent une recherche `YT Music`; les supports video quiz affichent la bonne reponse sous la question et proposent une recherche `YouTube` basee en priorite sur cette bonne reponse quand elle est disponible, avec la question uniquement en secours;
  - le jingle commun marque `isJingle` est exclu du scan des supports, puis sert de temoin audio dans le controle du son quand il est disponible;
  - le controle du son propose simplement `Lancer le jingle temoin`, sans confirmation utilisateur ni statut artificiel de validation, et laisse le jingle aller a sa fin naturelle.
- checks guides V1:
  - ouverture du lien joueur;
  - confirmation d'un joueur test inscrit;
  - test sonore local si le contenu de session le requiert;
  - scan automatique des supports audio/video detectes pendant le test complet.
- supports de session:
  - le scan lit les supports reels depuis `GameStore.playlist.songs`;
  - `Blind Test` et `Bingo Musical` traitent l'audio comme bloquant;
  - `Quiz` ne demande le son que si la session contient des supports media;
  - avant le test iframe/local, le scan YouTube appelle le read bridge `youtube_catalog_diagnostics_get` pour relire les diagnostics deja produits par le module `pro` dans `content_links_check_results`;
  - si le catalogue signale un support connu comme inutilisable (`unavailable`, `not_public`, `embed_restricted`, `age_restricted`, `live_stream`, `region_blocked_fr`), l'etape 2 l'affiche directement comme problematique et propose la remediation par lien temporaire;
  - YouTube est diagnostique via l'API iframe dans l'environnement organizer, avec classification prudente: `OK`, `Suspect`, `Casse`, `Bloque par l'environnement`, `A valider manuellement`;
  - le probe YouTube prelaunch utilise une fenetre proche du player principal (15 s, 20 s en profil lent); un timeout devient `A valider manuellement` car il peut venir du reseau et non du lien;
  - le diagnostic ne promet jamais une garantie absolue de lecture future.
- remplacements temporaires:
  - lorsqu'un support audio/video est `Casse`, `Bloque par l'environnement` ou `Suspect`, l'organizer peut tester un lien temporaire;
  - dans le formulaire de remplacement, le raccourci de recherche est place sous le libelle `Lien temporaire de remplacement`;
  - si le lien temporaire est valide, il est applique a `GameStore.playlist.songs` pour la session courante;
  - avant application runtime, les liens YouTube/Music/shorts/embed sont normalises en URL `youtube.com/watch?v=...`, en conservant les parametres temporels utiles (`t/start`, `end`);
  - l'application ou la restauration d'un lien temporaire ne relance pas tout le prelaunch: la synthese reste ouverte et seule la ligne concernee est mise a jour;
  - le remplacement est stocke seulement dans `sessionStorage` scope session/jeu et ne modifie pas la donnee source en base;
  - l'organizer peut revenir au lien d'origine.
- observabilite:
  - `logger.global.js` trace `PRELAUNCH_START`, `PRELAUNCH_CHECK`, `PRELAUNCH_COMPLETE`, `PRELAUNCH_REPLACEMENT_TEST`, `PRELAUNCH_REPLACEMENT_APPLY`, `PRELAUNCH_REPLACEMENT_RESET`;
  - les metas restent compactes: session, jeu, id de check, statut global.
- la modale de confirmation de lancement conserve le flux principal existant, mais affiche un rappel du dernier etat de test.

## Update 2026-04-17 — Bingo demo reset: winners DB + local player state are now cleared
- le flux `resetdemo` Bingo ne se contente plus de remettre la playlist et les grilles a zero:
  - il purge maintenant aussi `bingo_phase_winners` pour que le preload organizer/remote reparte sans gagnants historiques;
  - il conserve en revanche les rows `bingo_players` et les assignations de grilles, conformement au contrat demo actuel.
- cote player, le message WS `demo_reset` vide maintenant les reliquats locaux Bingo avant le reload:
  - reset UI immediat vers `En attente`;
  - `mainStarted=false`;
  - reset grille local;
  - `bingo_checked`
  - `bingo_locked`
  - `bingo_best_phase`
- but fonctionnel:
  - une demo Bingo relancee doit pouvoir etre rejouee sans rehydrater ni winners de phase precedents, ni coches/locks locaux residuels.
- perimetre volontairement borne:
  - pas de changement sur `reset` (flux de start),
  - pas de desassignation des grilles ni de suppression des joueurs demo.

## Update 2026-04-17 — Player mobile: upload photo podium V1 avec consentement trace
- le portail `player_canvas` de fin de session peut maintenant proposer un CTA photo au joueur lui-meme, en complement du flux remote deja en place;
- ce CTA n'est visible que si toutes les conditions suivantes sont vraies:
  - la session est terminee/archivee;
  - le participant courant appartient au podium final.
- addendum 2026-04-17:
  - la liaison a l'espace joueur n'est plus obligatoire pour ce flux player;
  - le champ `linked_to_player_account` reste expose a titre informatif quand un bridge existe encore.
- le front player ne duplique pas le pipeline remote:
  - il lit l'eligibilite via `canvas_api_player_podium_photo_access_get(...)`;
  - il ecrit ensuite via `canvas_api_player_podium_photo_upload(...)`;
  - ce write path delegue toujours au helper partage `app_session_results_podium_photo_upload(...)`.
- le formulaire impose maintenant un consentement explicite avant envoi:
  - case obligatoire;
  - texte de diffusion Cotton affiche inline;
  - refus serveur si le consentement manque, meme en appel direct.
- addendum UX 2026-04-17:
  - le player affiche maintenant une preview locale du draft photo avant upload, en reutilisant la meme carte que la photo deja enregistree;
  - la ligne du nom de fichier casse proprement en mobile si le nom est long;
  - si une photo organisateur verrouille deja la ligne podium, la carte joueur masque la description d'upload et garde seulement la preview + la note passive organisateur.
- choix de stockage retenu:
  - une preuve par upload dans `championnats_sessions_podium_photos_consents`;
  - la preuve reference aussi le media cree et les ids joueur/bridge/runtime utiles;
  - addendum 2026-04-17: la preuve snapshotte maintenant aussi le pseudo/libelle runtime visible au moment de l'upload, pour pouvoir retrouver rapidement photo + session + joueur lors d'une demande d'effacement, meme sans compte EP.
- justification:
  - un consentement attache a la photo est plus defensible qu'un simple flag compte joueur global;
  - il permet de prouver quelle photo a ete envoyee, par qui, quand et dans quel contexte.
- garde-fous serveur:
  - pas d'UI pour les non-podium;
  - refus backend si l'appel contourne l'UI sans eligibilite podium/session;
  - les validations MIME / taille / extension / sanitation restent celles du helper upload partage.
- addendum remote 2026-04-17:
  - la remote `games` collecte maintenant elle aussi un consentement explicite avant upload photo podium;
  - ce consentement organisateur est stocke dans la meme table que celui du player, avec une source distincte `games_remote_organizer`;
  - regle de priorite:
    - une photo organisateur visible sur une ligne podium prime toujours sur une photo joueur;
    - si la photo courante d'une ligne podium provient d'un organisateur, le bloc `player_canvas` de cette ligne est masque et le joueur ne peut plus l'ecraser.

## Update 2026-04-17 — Remote podium: une photo par gagnant, pas une photo par rang
- la remote `games` de fin de partie est maintenant alignee sur la granularite deja utilisee cote `pro` pour les photos podium;
- `session_meta_get` et le preload `serverSessionMeta` exposent maintenant toutes les lignes podium `1..3`, meme sans photo deja presente:
  - `photo_row_key`
  - `label`
  - `score`
  - `phase_label`
  - `photo_src`
- cote remote, le rendu de fin de partie ne relie plus les miniatures et les CTA d'upload uniquement au `rank`;
- chaque carte/ligne de podium essaie maintenant d'identifier sa row meta propre:
  - `photo_row_key` si deja disponible;
  - sinon fallback `rang + libelle + phase` pour `bingo`;
  - sinon fallback `rang + libelle + score` pour `quiz` / `blindtest`.
- le bouton photo poste maintenant `rank + photo_row_key` vers `session_podium_photo_upload`, ce qui permet:
  - de charger une photo distincte pour deux gagnants ex aequo sur la meme marche;
  - de modifier ensuite la bonne photo sans ecraser celle d'un autre gagnant du meme rang.
- un `session_meta_get` est aussi relance a la reception de `remote/end`, pour qu'une remote deja ouverte recupere rapidement les row keys et les photos associees apres la fin de partie.

## Update 2026-04-16 — Quit joueur runtime: la purge locale supprime aussi l'identite session-scope
- le quit volontaire cote player numerique ne supprimait jusqu'ici que des cles legacy de `localStorage`;
- or l'identite runtime canonique est aussi stockee scopee par session (`player_stable_id:<sid>`, `player_db_id:<sid>`), ce qui pouvait laisser au reload un faux etat "joueur deja connu" alors que le joueur venait de quitter;
- `play-ui.js` aligne maintenant le quit numerique sur la purge papier:
  - appel explicite a `clearPlayerIdentityForSession({ game, sid })`;
  - suppression du flag `player-registered_<sessionId>`;
  - pour `bingo`, suppression aussi des cles de grille scopees par session;
- effet attendu:
  - apres `Quitter la partie`, un retour sur la page revoit bien l'etape d'inscription;
  - un joueur runtime peut se reinscrire avec un nouveau pseudo sans etre bloque par une identite locale fantome.

## Update 2026-04-16 — Remote papier: garde capacite avant `player_register`
- portee strictement ciblee a l'ajout de participant depuis la remote quand `paperMode` est actif;
- `remote-ui.js` lit maintenant `window.ServerSessionMeta.maxPlayers` et le snapshot joueurs courant (`playersLast` / `playersTotalLast`) avant de laisser partir un nouvel ajout;
- le controle principal est place dans `promptParticipantSelection().preConfirm`:
  - si la session papier est pleine, la modale SweetAlert reste ouverte;
  - le refus remonte en message de validation au lieu de fermer la modale puis d'afficher seulement un toast.
- une seconde verification existe juste avant `remoteApi('player_register', ...)` pour couvrir un cas de concurrence entre deux ajouts;
- nuance fonctionnelle:
  - la garde ne bloque pas un participant deja actif si l'animateur le re-selectionne;
  - aucun contrat backend `player_register` n'est modifie par ce patch.

## Update 2026-04-16 — Quit `master` demos + quit `play`
- `end_game.js` ne base plus la sortie demo sur `id_client === 1557`;
- la sortie `master` s'appuie maintenant sur `AppConfig.isDemoSession` et peut reutiliser un `return_url` explicite fourni par `pro`, memorise par session dans `sessionStorage`;
- en absence de `return_url`, le `master` accepte aussi un referrer `pro` valide comme origine de retour pour les demos;
- les lanceurs demo `pro` connus (`bibliotheque`, `fiche session`, `liste agenda`, duplication directe) ajoutent maintenant ce `return_url` quand ils ouvrent `games/master`;
- `play` n'utilise plus une redirection catalogue par jeu pour `urlPromo`:
  - la cible standard de retour devient la home du site `www`.

## Update 2026-04-16 — Remote fin de partie: upload podium direct dans `games`
- la remote ne redirige plus vers `pro` pour l'ajout des photos gagnants;
- un nouvel endpoint bridge `session_podium_photo_upload` expose maintenant l'upload podium en JSON/multipart depuis `games`, tout en reutilisant le helper global `app_session_results_podium_photo_upload(...)`;
- la remote rerend son podium termine juste apres upload avec le `session_meta_get` renvoye par l'endpoint;
- quand une photo podium existe deja pour un rang, la remote affiche maintenant aussi sa miniature directement dans la ligne concernee;
- la remote supporte maintenant explicitement les 2 shapes de meta observees:
  - preload simple `window.ServerSessionMeta.*`
  - refresh bridge `window.ServerSessionMeta.session.*`
- les resolvers de preload `quiz` / `blindtest` / `bingo` injectent maintenant eux aussi `podium_photos` dans `serverSessionMeta`, pour hydrater la remote avec les photos existantes des l'ouverture;
- `boot_lib.php` charge maintenant `global_librairies.php` aussi pour les boots canvas hors `games_ajax.php`, afin que ces resolvers preload aient bien acces aux helpers globaux de resultats;
- la remote force maintenant aussi un `session_meta_get` au boot, puis continue un polling toutes les `5s` uniquement en etat `Partie terminee`;
- le bouton photo remote reproduit maintenant le geste mobile deja utilise sur la fiche session `pro`:
  - ouverture d'un mini-choix `Caméra / Photos` sur `Ajouter une photo` comme sur `Modifier la photo`;
  - `capture="environment"` seulement sur le chemin `Caméra`;
- l'UX du podium termine passe aussi en `3` lignes au lieu de `3` colonnes, avec un CTA photo explicite en fin de ligne:
  - icone appareil photo;
  - libelle `Ajouter une photo` / `Modifier la photo`.

## Update 2026-04-11 — Podium organizer: photos distinctes aussi pour les ex aequo
- le polling `session_meta_get` ne remonte plus seulement `rank + photo_src` pour les photos podium;
- `boot_lib.php` transmet maintenant aussi les metadonnees de ligne necessaires au matching organizer:
  - `photo_row_key`
  - `label`
  - `score`
  - `phase_label`
- `canvas_display.js` n'ecrase donc plus les photos dans une simple map `rank -> src`;
- le podium organizer essaie maintenant de resoudre une photo par carte via:
  - la cle de ligne si elle existe;
  - sinon un matching par `rang + nom + phase` ou `rang + nom + score`;
  - sinon le premier media libre restant sur ce rang;
- effet attendu:
  - si deux gagnants sont `#1 / #1`, le master peut afficher deux photos differentes;
  - le fallback historique `1 photo par rang` reste compatible si l'ancienne donnee est encore la seule disponible.

## Update 2026-04-11 — Remote fin de partie: CTA mobile plus compact
- le travail de compacite CSS du CTA remote de fin de partie a servi de base au redesign suivant;
- depuis le patch 2026-04-16, ce CTA unique vers `pro` n'existe plus: il est remplace par un bouton photo par ligne de podium, mais les garde-fous de largeur mobile et la couleur de texte branding restent reutilises.

## Update 2026-04-10 — Remote papier: ajout participant EP reseede immediatement l'identite runtime canonique
- portee volontairement ciblee:
  - participants issus d'un lookup DB (`sourceTable/sourceId`);
  - ajoutes par l'animateur depuis la remote;
  - donc chemins admin papier, pas le flux joueur `EP -> games` classique deja stable.
- `remote-ui.js` reseede maintenant la liste locale des joueurs juste apres `player_register` sur ce chemin:
  - `player_id` canonique prioritaire;
  - `playerDbId` / `playerId` numerique conserve comme metadonnee secondaire si le backend le renvoie;
  - `playerName`, `score`, `playerScore` completes pour que les actions admin suivantes manipulent deja un objet joueur au format runtime.
- le but n'est pas d'introduire un nouveau contrat:
  - le snapshot `players_get` reste la source autoritaire;
  - le reseed local comble seulement la fenetre immediate apres ajout remote, avant que le refresh standard / WS ne rehydrate la liste complete.
- correctif racine complementaire cote backend:
  - `quiz_adapter_glue.php`, `blindtest_adapter_glue.php` et `bingo_adapter_glue.php` ne dependent plus d'un `INSERT ... ON DUPLICATE KEY` pour reutiliser une identite runtime existante;
  - ils relisent maintenant explicitement la ligne `session + player_id`, reactivent cette ligne si elle existe, et desactivent les doublons residuels portant la meme identite;
  - raison: le schema canon historique ne garantit pas partout un unique index runtime sur `session_id + player_id`, donc l'ancien pseudo-upsert pouvait laisser passer de vrais doublons SQL pour un meme participant EP.
- l'upsert runtime renvoie maintenant aussi un etat metier explicite:
  - `created`;
  - `reactivated`;
  - `already_active`.
- garde complementaire:
  - quand `player_register` est appele avec `ep_connect_token`, les adapters resolvent maintenant l'identite EP (`id_equipe` / `id_joueur`) directement depuis le bridge token cote serveur;
  - la cle runtime canonique ne depend donc plus uniquement du `sourceTable/sourceId` remonte par le navigateur;
  - effet vise: un retour `EP -> games` retombe sur la meme identite runtime qu'un ajout remote lookup du meme participant.
- nuance Bingo-only ajoutee apres regression `develop/fix_joueursEP`:
  - l'audit a confirme une divergence explicite entre `main` et la branche courante dans `bingo_api_player_register()`:
    - `main` ne refait pas de re-resolution serveur EP a cet endroit;
    - `develop/fix_joueursEP` appelle `canvas_api_ep_link_resolve(...)` avant de recalculer `player_id`.
  - pour `Bingo Musical`, seule une source joueur (`participantType=player`, `sourceTable=equipes_joueurs`, `id_joueur > 0`) est compatible avec le contrat runtime:
    - `bingo_players.player_id` reste la cle canonique de session;
    - les grilles numeriques et papier restent rattachees a `jeux_bingo_musical_grids_clients.id_joueur`;
    - une identite `team/equipes` ne constitue donc pas une source canonique exploitable pour ce jeu.
  - `bingo_api_player_register()` traite maintenant ce point explicitement:
    - `canvas_api_ep_link_resolve(...)` est encapsule dans un `try/catch(Throwable)` pour ne plus remonter de `500` brut depuis ce bloc;
    - si la re-resolution serveur ne remonte pas d'`id_joueur` exploitable (`TEAM_ONLY`, `PLAYER_ID_MISSING`, erreur SQL/bridge), le backend journalise le cas puis conserve le fallback sur le payload front deja resolu;
    - si un payload `team/equipes` arrive quand meme sur Bingo, il est purge comme source unsupported avant le bridge runtime, afin d'eviter une canonicalisation erronée sur une identite d'equipe.
  - correctif bridge associe:
    - `player_register` lie deja la row de `championnats_sessions_participations_games_connectees` via `canvas_ep_account_bridge_link_runtime_participant(...)`;
    - `ep_link_finalize` est maintenant idempotent: si la row bridge existe deja avec le meme `game_player_id` / `game_player_key`, il renvoie un succes `already_linked` au lieu d'un faux `TOKEN_INVALID`;
    - les erreurs bridge attendues (`TOKEN_INVALID`, `SESSION_MISMATCH`, `GAME_MISMATCH`, `USERNAME_MISSING`) ne doivent plus sortir du canvas bridge en HTTP `500`, mais en `400`.
  - diagnostic WS Bingo issu de la comparaison avec `main`:
    - aucune divergence de branche n'a ete trouvee dans `play-ws.js` ni dans le serveur WS Bingo sur le chemin `auth_player`;
    - le blocage numerique etait en amont, dans `register.js`, lors de l'emission `player/ready` apres `player_register_ok` + `grid_assign`;
    - une regression de branche avait remplace `isPaperMode()` par `paperMode` sur ce payload;
    - `paperMode` etant hors scope, un `ReferenceError` etait absorbe par le `try/catch`, ce qui supprimait silencieusement `player/ready`;
    - sans `player/ready`, `play-ws.js` ne lance ni `bootWSPlayer({ auth })` ni l'`auth_player` Bingo numerique.
- usage UI:
  - la remote papier n'annonce plus un faux "participant ajoute" quand le participant EP/equipe est deja actif dans la session; elle affiche un message deja-inscrit adapte au type;
  - la page d'inscription `games` traite `already_active` comme un succes idempotent et rehydrate l'identite locale comme un joueur deja inscrit, au lieu de tomber sur une erreur generique.
- correctif complementaire cote player:
  - `games/web/includes/canvas/play/player_identity.js` traite maintenant le `player_id` renvoye par `player_register` comme source de verite pour la session courante;
  - auparavant, si un `player_id` local genere existait deja, il n'etait pas remplace par la cle serveur stable;
  - effet observe dans les logs de session: un meme `player_db_id` pouvait etre vu successivement sous plusieurs `player_id` canoniques en WS, ce qui recreait un doublon purement memoire/UI cote remote et master alors que la DB runtime etait deja dedupee.
- garde complementaire cote WS player papier:
  - pour `quiz` et `blindtest`, le chemin `player/paper:listen` est maintenant strictement passif;
  - il ouvre le WS pour recevoir `update_session_infos`, mais n'envoie plus `registerPlayer` ensuite;
  - les succes d'inscription papier cote `register.js` basculent eux aussi vers cette ecoute passive au lieu d'emettre `player/ready`.
- effet vise:
  - couper a la source le second enregistrement WS d'un participant deja inscrit en runtime par l'admin;
  - eviter les doublons `totalPlayers:2` purement memoire pour un meme `player_db_id`, constates notamment sur `blindtest` papier.
- effet attendu:
  - aligner plus tot la logique admin remote sur la logique joueur classique, sans patcher separement chaque action admin.
  - dans les deux sens, `remote lookup -> EP -> games` et `EP -> games -> remote lookup` doivent maintenant retomber sur la meme ligne runtime au lieu d'en creer une seconde.
  - pour `bingo`, cet alignement reste borne aux identites joueur; si la re-resolution serveur devient inexploitable, le flux doit rester operationnel sans `500` et sans conversion forcee en identite d'equipe.

## Update 2026-04-09 — Fin de session `games`: retour organizer fiche detail `pro` + photos podium live
- le runtime `games` expose maintenant une cible canonique `sessionDetailUrl` vers `pro/extranet/start/game/view/<id_securite_session>` pour la surface organizer.
- les ajouts remote issus d'une recherche DB n'ecrivent plus de `return_token` vide dans `championnats_sessions_participations_games_connectees`; un token technique unique est maintenant genere pour rester compatible avec la contrainte SQL globale `uniq_return_token`, sans changer le parcours EP joueur classique.
- le podium organizer ne depend plus d'un `file_exists(...)` local sur le serveur `games` pour diffuser les photos gagnants; si le media est present en base mais que le FS local n'expose pas le meme mount que `www/pro`, l'URL canonique `www/upload/...` est quand meme renvoyee au polling.
- correctif racine 2026-04-09: `games_ajax.php` charge maintenant `global_librairies.php` avant le bridge canvas. Sans cela, les endpoints canvas executes avec `exit` precoce, comme `session_meta_get`, ne voyaient pas les helpers globaux (`app_session_get_id`, `app_session_get_detail`, `app_session_results_get_context`) necessaires pour remonter les photos podium vers l'UI organizer.
- organiser:
  - `end_game.js` ne renvoie plus seulement vers le dashboard `pro`;
  - la sortie volontaire priorise maintenant la fiche detail session, afin que l'organisateur retombe directement sur l'upload des photos gagnants.
- remote:
  - ce flux de redirection vers la fiche detail `pro` a ensuite ete remplace par l'upload direct dans `games` (voir update 2026-04-16);
  - le `quit` remote reste un simple `close/about:blank` apres liberation du slot.
- podium organizer:
  - `session_meta_get` expose maintenant `podium_photos` (rang + URL) en plus de la meta de verrouillage format;
  - la signature de polling organizer integre ces photos, ce qui permet de re-render le podium quand elles changent apres la fin de session;
  - `canvas_display.js` sait afficher une photo dediee par rang `#1/#2/#3`, avec cadrage stable.
- portee:
  - ce flux cible uniquement les sessions qui ouvrent reellement l'interface `games`;
  - `Cotton Quiz` V1 historique ne fait pas partie de cette mecanique.

## Update 2026-04-07 — Refus d'inscription: purge locale ciblee + `playerDbId` strict par session
- le portail player `games` nettoie maintenant explicitement l'identite locale provisoire seulement quand `player_register` est refuse pour un motif metier de nom:
  - `USERNAME_ALREADY_USED`;
  - `USERNAME_REFERENCED`.
- ce cleanup ne s'applique pas aux erreurs techniques (`timeout`, erreur reseau, `SQL_ERROR`, reponse invalide), afin de ne pas casser une reprise legitime si le serveur a en realite valide l'inscription.
- pour `Bingo Musical`, la purge efface aussi les artefacts de grille purement locaux (`grid_id`, `grid_secret`, cellules/numeros coches) afin d'eviter qu'un premier refus de pseudo ne pollue la seconde inscription.
- en complement, les chemins `bingo` sensibles (`register`, hydratation/sync de grille, auth WS) ne relisent plus un `playerDbId` global legacy:
  - seul l'id DB scope a la session courante est accepte;
  - le fallback global legacy reste reserve aux chemins de migration/compat, pas au gameplay actif.
- effet attendu:
  - un refus de pseudo ne laisse plus derriere lui une identite locale fantome susceptible de casser une inscription suivante;
  - un `playerDbId` persiste depuis une autre session ne peut plus etre recolle a tort sur la session bingo courante.

## Update 2026-04-03 — Inscriptions runtime / EP / remote: garde de nom + bridge EP stabilises
- les inscriptions runtime pures refusent maintenant:
  - un nom deja utilise dans la session, meme inactif;
  - un nom deja reference chez l'organisateur.
- les bypass restent bornes aux seuls cas voulus:
  - inscription via `ep_connect_token`;
  - ajout remote issu d'un lookup DB existant.
- les messages d'erreur utilisateur sont harmonises:
  - `Ce nom est déjà utilisé dans cette session. Merci d'en choisir un autre.`
  - `Ce nom n'est plus disponible. Merci d'en choisir un autre.`
- quand l'animateur ajoute depuis la remote un joueur ou une equipe deja connu en base, `games` renseigne maintenant aussi `championnats_sessions_participations_games_connectees` avec `game_player_id`, `game_player_key` et `date_consumed`.
- une reinscription EP sur la meme session reutilise maintenant une identite runtime stable, au lieu de recreer une nouvelle row runtime a chaque retour.

## Update 2026-04-02 — `EP -> games`: un token de retour priorise maintenant le flow EP sur le resume local
- quand un joueur revient de `play` avec `ep_connect_token`, le portail player `games` ne laisse plus une identite locale deja stockee court-circuiter l'auto-inscription EP.
- avant ce correctif, un `player_id` local sur la meme session pouvait declencher un `resume` puis un `return` anticipes dans `register.js`, ce qui bypassait completement `tryAutoRegisterFromEp()`.
- effet attendu:
  - comportement aligne entre onglet normal et onglet prive sur un retour `Compte joueur Cotton`;
  - le flux EP reste prioritaire tant qu'il n'est pas finalise.

## Update 2026-04-02 — Observabilite `EP -> games`: preuves centralisees du flux `ep_connect_token`
- `logger.global.js` remonte maintenant aussi les etapes `register/debug` du portail player pour les retours `play -> games` avec `ep_connect_token`.
- les journaux centralises de session peuvent maintenant montrer explicitement:
  - la resolution bridge `ep_link_resolve`;
  - le depart/abort d'auto-inscription EP;
  - l'upsert `player_register`;
  - la finalisation `ep_link_finalize`;
  - les erreurs `missing_player_id` / upsert joueur.
- objectif:
  - diagnostiquer depuis le `.jsonl` de session l'etape exacte ou le flux `Compte joueur Cotton` decroche, sans devoir reconstruire le parcours uniquement depuis la console navigateur ou les logs PHP.
- ces preuves restent volontairement en `debug`, afin de conserver la capacite de diagnostic sans surcharger le niveau de logs prod.

## Update 2026-04-02 — Player reload: bootstrap `GameMeta` aligne avec la reprise locale
- le portail session player `games` publie maintenant `window.GameMeta = { slug, title }` comme l'organizer, en plus de `window.AppConfig.gameSlug`.
- ce metadata manquait sur le canvas player alors qu'une partie du runtime commun (`logger`, `ws_effects`, `session_modals`, `canvas_display`, etc.) continue de relire `window.GameMeta?.slug`.
- effet fonctionnel vise:
  - reprise locale plus stable quand un joueur deja connu en `localStorage` recharge la page avant ou pendant l'entree effective dans l'interface de jeu;
  - disparition des traces `game: ''` cote logger player sur ce chemin de reprise.
- garde complementaire:
  - `logger.global.js` relit maintenant aussi `window.AppConfig.gameSlug` si `window.GameMeta` manque encore.

## Update 2026-04-01 — Reset design organizer: session + compte si design identique
- le CTA `Revenir au design d'origine du jeu` de la modale organizer ne se limite plus au branding session courant.
- `session_modals.js` demande d'abord un `delete_preview` au backend branding, puis envoie un delete `cascade_client_branding_if_matching=1`.
- le wording de confirmation annonce désormais aussi:
  - la suppression automatique du design compte s'il existe et s'il correspond au design effectif de la session;
  - l'arret d'usage de ce design pour les prochaines sessions;
  - la conservation du design sur les sessions deja programmees qui l'heritaient deja.
- ces lignes d'impact ne sont affichees que si le backend confirme qu'un branding compte sera reellement supprime.
- dans la modale SweetAlert, cette mention conditionnelle est rendue en corps reduit, italique, avec un leger espacement au-dessus.
- le front `games` laisse le backend `global` decider si le design compte doit etre supprime, afin d'eviter toute divergence locale sur la portee effective du reset.

## Update 2026-04-01 — Remote papier: lookup DB de joueurs / equipes existants
- la remote papier ne cree plus seulement des participants runtime en saisie libre.
- nouvelle action bridge globale `participant_lookup`:
  - `quiz` -> recherche d'equipes existantes dans `equipes`;
  - `blindtest` / `bingo` -> recherche de joueurs existants dans `equipes_joueurs`.
- la modale remote propose des suggestions a partir de 3 caracteres, tout en conservant la validation en saisie libre si aucun resultat ne convient.
- si l'animateur choisit une entree existante, la remote envoie un `player_id` canonique `p:uuid` derive de facon deterministe de la source metier (`id_equipe` / `id_joueur`).
- pour `quiz`, en cas d'equipes homonymes, le sous-texte de suggestion affiche jusqu'a 2 prenoms de joueurs associes a l'equipe afin d'aider l'animateur a distinguer les doublons sans exposer un id technique en premier niveau.
- pour `blindtest` / `bingo`, les fiches `equipes_joueurs` portant un email technique `@cotton-quiz.com` sont exclues du lookup remote: elles sont considerees comme des identites internes / invitations non finalisees et ne doivent pas polluer la selection animateur.
- pour les autres joueurs, en cas d'homonymie sur le libelle affiche (`pseudo` prioritaire, sinon `prenom`), le sous-texte de suggestion affiche l'email associe sous forme masquee (`xx***yy@domaine`) quand une colonne email standard est disponible dans `equipes_joueurs`.
- le lookup joueur dedoublonne aussi les fiches qui partagent le meme libelle affiche et le meme email normalise, en gardant prioritairement la fiche a activite/date la plus recente (`updated_at`, sinon `created_at`, sinon `id` le plus grand).
- effet attendu:
  - re-ajouter le meme joueur/equipe sur une session papier reactive la meme identite runtime au lieu de creer un doublon logique;
  - les cas hors base restent couverts par le fallback saisie libre.
- la validation backend `player_register` n'est plus bornee a `20` caracteres en dur:
  elle lit la longueur declaree de la colonne `username` par jeu via `information_schema`, avec fallback `20` si l'introspection echoue.

## Note d'evolution — Branding par type de jeu
- l'UI organizer `games` ne porte aujourd'hui qu'un branding session (`id_type_branding = 1`) ou compte global (`id_type_branding = 4`), sans dimension `quiz / blindtest / bingo`.
- si un branding par type de jeu est introduit plus tard, `games` devra transmettre le type de jeu courant au save, au preview et au delete du branding, et borner le wording `prochaines sessions` au seul type courant.
- cette evolution ne peut pas etre tenue proprement par le front seul: elle depend d'un modele `global` capable de resoudre un branding scope + type de jeu avec fallback vers le branding global existant.

## Update 2026-04-01 — Organizer: QR remote papier borné a la fenetre d'ouverture
- `session_modals.js` n'ouvre plus automatiquement le bloc `#pilotQRWrap` sur le seul critere `paperMode`.
- L'auto-ouverture du QR remote exige maintenant `papier + ClientSessionMeta.isOpen`.
- Effet fonctionnel:
  - session papier non ouverte: la modale `Options de jeu` garde le QR remote replie;
  - session papier ouverte: le QR remote continue a s'ouvrir automatiquement;
  - le garde existant de `boot_organizer.js` au clic reste la seconde ligne de defense si l'utilisateur tente quand meme d'ouvrir le bloc hors session.

## Update 2026-03-26 — Player register: pont `EP -> games` pour compte joueur
- `player_canvas.php` n'expose plus un simple lien inline: l'ecran d'inscription joueur rend maintenant un bloc `Compte joueur Cotton` distinct du formulaire pseudo, avec promesse minimale d'usage de l'espace joueur (`historique`, `prochaines sessions`, `organisateurs deja frequentes`) et CTAs de connexion / creation de compte pointant vers `play` avec contexte session.
- `register.js` sait consommer un `ep_connect_token` de retour, résoudre l'identité EP via le bridge canvas, puis lancer l'auto-inscription joueur dès que la gate de session est ouverte.
- le runtime continue d'écrire dans `*_players` pour le gameplay; la liaison métier durable EP -> session -> joueur de jeu est finalisée à part dans `championnats_sessions_participations_games_connectees`.
- nouveaux endpoints bridge côté canvas:
  - `ep_link_resolve`
  - `ep_link_finalize`
- effet attendu:
  - Blindtest / Bingo: auto-inscription au prénom joueur EP;
  - Quiz numérique: auto-inscription au nom d'équipe déjà résolu côté `play`.
- nuance de routing quand la session n'est pas ouverte:
  - future non ouverte: le bloc compte joueur garde ses CTA vers `play`, mais le retour post-auth EP vise le signalement de participation probable plutôt qu'un rebouclage direct vers `games`;
  - session expirée/non ouverte: le retour post-auth EP vise l'agenda joueur pour inciter à rejoindre de prochaines sessions.
- regle temporelle explicite:
  - une session est consideree `ouverte` pour ce parcours si elle a lieu aujourd'hui;
  - ou si elle a eu lieu hier et qu'il est encore strictement avant `12:00`;
  - au-dela, elle repasse en `expiree`.
- nuance au jour J avant ouverture:
  - quand un joueur revient de `play` avec un `ep_connect_token`, le message d'attente n'apparait plus dans le bloc pseudo;
  - il remplace maintenant le texte et les CTA du bloc `Compte joueur Cotton`;
  - `Blindtest` / `Bingo`: message centré sur l'inscription du joueur;
  - `Quiz`: message centré sur l'inscription de l'équipe, avec mention du joueur connecté.
  - ce contexte EP est maintenant aussi résolu explicitement tant que la gate reste en `NO_MASTER`, pour éviter toute réouverture parasite du formulaire pseudo avant l'ouverture réelle.
- nuance session ouverte:
  - hors `NO_MASTER`, le bloc `Compte joueur Cotton` revient à sa promesse standard et n'affiche pas le message d'attente lié au pont EP.
- nuance session papier:
  - après un retour `EP -> games` sur une session papier, l'UI ne bascule pas vers le jeu;
  - le formulaire pseudo reste masqué et le rendu historique papier est repris, avec confirmation contextualisée joueur/équipe et CTA de désinscription.
  - le jour J avant ouverture (`NO_MASTER`), ce même rendu de confirmation papier est maintenant affiché immédiatement au retour d'EP.
  - sur ce parcours papier, la fermeture de gate WS ne bloque pas le retour EP: le gating WS numerique est volontairement bypasse pour retomber sur ce rendu papier historique au lieu d'essayer d'ouvrir l'interface de jeu.

## Update 2026-03-24 — Observability prod reprise player mobile
- `play-ws.js` emet maintenant une preuve front `player/ws:resume_ok` uniquement quand une vraie reprise joueur aboutit apres coupure/reouverture (`foreground:*` ou `ws_open_reconnect`).
- `logger.global.js` publie cette preuve en `info` sous `PLAYER_SESSION_RESUME_OK` avec `{ sid, game, ws_state, reason }`.
- objectif: pouvoir relire en prod la stabilite reelle des sessions joueur sur Bingo / Blindtest / Quiz sans remonter toutes les decisions lifecycle en `info`.

## Update 2026-03-24 — Branding: upload visuel perso et persistance locale alignés sur le rendu serveur
- `session_modals.js` conserve maintenant le `File` original pour l'envoi branding, tout en gardant un preview local léger pour la modale organizer.
- Le localStorage `games` ne persiste plus les objets `File`; il persiste seulement l'état branding sérialisable.
- Au boot, `initSessionModals()` fusionne désormais `window.ServerBranding` injecté par PHP avec le cache local au lieu d'écraser la version serveur.
- Si le branding local stocke encore une ancienne `dataURL` custom et qu'une URL serveur branding existe déjà, l'URL serveur reprend la priorité pour éviter l'effet `net au chargement puis flou`.
- Après un save branding réussi, `games` réécrit le branding persistant avec les URLs serveur finales (`logo` / `visuel`) avant la diffusion WS `update_branding`.
- En cas d'échec upload `logo` / `visuel` remonté par le serveur (fichier trop lourd, upload partiel, erreur PHP), l'alerte organizer réaffiche maintenant le message métier exact au lieu d'un simple échec générique.
- Le reset branding depuis l'UI organizer est maintenant borné à la couche session: il ne peut plus supprimer par erreur le branding effectif amont (notamment un branding réseau TdR servi à un affilié).
- Effet attendu: le rendu de jeu reste stable après chargement et n'est plus dégradé par une ancienne preview compressée conservée en local.

## Update 2026-03-06 — Réseau Étape 1 (guard offre effective)
- `organizer_canvas.php` supprime le fallback local divergent de contrôle d’offre (`activeCount/sessionOfferActive`).
- Le repli utilise désormais le resolver métier central `global` (`app_ecommerce_offre_effective_get_context(...)`) quand `app_session_launch_guard_get(...)` n’est pas disponible.
- Effet: contrat unique de décision d’accès (offre propre / réseau / inactif), sans redéfinition locale dans `games`.

## Update 2026-03-04 — Quiz lot `L`: ordre des questions (position > id)
- Hydratation quiz (`quiz_adapter_glue.php`, lot `L`):
  - tri appliqué: `ORDER BY q.position ASC, q.id ASC`.
- Comportement attendu:
  - priorité à l’ordre métier bibliothèque (`questions.position`),
  - fallback stable sur `id` quand `position` est absente/identique (ex: `0` partout).

## Update 2026-03-05 — Remote: état visuel de démarrage + quiz: fit question longue
- Remote waiting (`remote_canvas.php`, `remote-ui.js`, `remote_styles.css`):
  - ajout d’un état “démarrage en cours” pendant jingle/initialisation après Start,
  - affichage conditionné à un démarrage réel de partie (pas de visuel d’initialisation avant le 1er start),
  - pendant cet état, les textes de bienvenue sont masqués pour ne garder que le message de démarrage.
- Quiz organizer (`canvas_display.js`, `quiz_ui.js`):
  - fit du titre de question renforcé pour les textes très longs (notamment lots temporaires `T` en papier),
  - bloc question conservé fixe; c’est la taille du texte qui s’adapte pour rester visible.

## Terminologie (anti-confusion)
- **WS frame** : objet JSON envoyé sur socket, champ obligatoire `type`.
- **HTTP bridge** : “action” dispatchée côté PHP (bridge `t=jeux&m=canvas`).
- **Bus event** : `Bus.emit/on(...)` côté front (Bus-first).

---

## Scope & entrypoints
### Pages (HTML)
- Organizer : `web/organizer_canvas.php`
- Player : `web/player_canvas.php`
- Remote : `web/remote_canvas.php`

### Bridge HTTP (Canvas API)
- `web/games_ajax.php` (alias possible : `web/global_ajax.php` selon routage global/branding)

---

## Actors & flows (vue mentale)
### Actors
- **Organizer** : maître de session (démarre/pause/next/prev, options, fin de partie). UI + WS + persistance.
- **Remote** : écran secondaire / télécommande (reçoit l’état, envoie des commandes).
- **Player** : client mobile (register/auth, reçoit l’état, joue).

### Flows principaux
1) Organizer ↔ **WS** ↔ Players  
2) Organizer ↔ **WS** ↔ Remote  
3) Organizer ↔ **HTTP (PHP)** ↔ DB (persistance `session_update`, options, etc.)

### Backend surfaces (résumé)
- `web/games_ajax.php` : bridge JSON (CORS + auth optionnelle + idempotence) → dispatch
- Dispatch côté PHP vers : `web/includes/canvas/php/*_adapter_glue.php` (quiz / blindtest / bingo)

---

## Runtime & I/O

## WebSocket (front)
### Format des frames sortantes (canon)
- **Chaque frame WS** est un objet JSON : `{ type: string, ...fields }`
- Corrélation reply possible : ajout `"_cid"` (optionnel)
- Sérialisation/queue : `web/includes/canvas/core/ws_connector.js` (Bus `game:ws:send`)  
  Réf : `ws_connector.js:300-327`

### Handshake / reconnection (std vs bingo)
- **Non-bingo (std)** : `ws/open` émis dès `onopen`, heartbeat client toutes ~25s, flush queue.
- **Bingo** : à l’ouverture socket, envoie auth (`auth_*`), **attend un premier message serveur `type:"state"`** comme ACK avant d’émettre `ws/open`. Pas de heartbeat client ; répond aux `ping` serveur par `pong`.
- **Logs front V1 (player)** :
  - production des logs côté navigateur dans `core/logger.global.js`;
  - transport de flush = WS uniquement (`game:ws:send` -> `log_event` / `log_batch`);
  - pas de fallback HTTP / `sendBeacon` pour ces logs V1;
  - `PLAYER_FRONT_BOOT` est maintenant gardé pending si le transport n’est pas encore réellement prêt, puis rejoué exactement une fois au premier `ws/open`;
  - `ws_connector.js` publie aussi un snapshot runtime partagé (`window.__CANVAS_WS_RUNTIME__`) sur les transitions WS majeures; `logger.global.js` s’en sert pour hydrater `ws_ready_state` si l’événement `ws/status` initial a été manqué lors d’une accroche Bus tardive;
  - le contrat de flush reste:
    - flush fin de session,
    - ou flush forcé explicite;
  - une frame WS `force_flush` est maintenant exécutée côté `player` et `remote`, ce qui permet de faire remonter des logs front distants sans ajouter de flush auto en cours de session.

### Router inbound partagé
- `web/includes/canvas/core/ws_effects.js` écoute `Bus.on('game:ws:message')` **une fois** et route des types WS vers des events Bus “srv/*” (et bingo-specific).  
  Il ignore les types heartbeat.  
  Réf : `ws_effects.js:450-664`
- Correctif 2026-02-12 (anti-régression lots Bingo): le hook `Bus.on('options/updated')` n’envoie plus `update_session_infos` pour toute option; l’envoi est limité aux champs de contrôle de session (`paperMode`, plus `manualAdvance` pour quiz), afin d’éviter des updates session inutiles sur simples options gameplay (`songDuration`, etc.).

### Types inbound traités par `ws_effects.js` (canon, extraits)
- `endGame` → `srv/endGame` (hydration scores) (`ws_effects.js:450-466`)
- `paper_finalize_end` → trace de compat non terminale uniquement; la commande Remote est traitée par le WS moteur et ne termine plus localement le Master.
- `paper_score_finalization_state` → annule une barrière éventuellement engagée et restaure la revue sur échec; `completed` reste informatif, `endGame`/`HUB_SESSION_FINISHED` portent le terminal.
- `togglePlayPause` → `srv/togglePlayPause` (`ws_effects.js:472-478`)
- `togglePause` → `srv/toggleInterseriesPause` (`ws_effects.js:479-480`)
- `nextSong` / `prevSong` → `srv/nextSong` / `srv/prevSong` (`ws_effects.js:480-493`)
- `skipPause` → `quiz/interseries/end` (`ws_effects.js:494`)
- `forcedDisconnect` → notice + end session (`ws_effects.js:495-510`)
- `gameOptionsUpdate` → persist options + `options/updated` (`ws_effects.js:512-547`)
- `force_full_current` → `srv/forceFullCurrent` (`ws_effects.js:540-544`)
- `start_support` → `srv/startSupport` (`ws_effects.js:545-547`)
- `support_ended` → `srv/supportEnded` (`ws_effects.js:548-550`)
- Bingo :
  - `state` → patch store + `bingo/stateSnapshot` + `srv/phaseUpdate` / `srv/playerUpdate` / `srv/notifications` (`ws_effects.js:552-611`)
  - `remote_action` → map vers `srv/*` ou `options/updated` (`ws_effects.js:612-653`)

> Note : `canvas_display.js` ne consomme pas WS directement (wiring UI/Bus uniquement).

---

## HTTP / PHP bridge (Canvas)
### Endpoint
- Bridge JSON : `web/games_ajax.php` (route `t=jeux&m=canvas`)

### Service-token auth (compat front + service)
- **Auth service-token** appliquée quand le header `HTTP_X_SERVICE_TOKEN` est fourni (canal inter-service).
- Secret attendu : env `CANVAS_SERVICE_TOKEN`.
- En cas de header invalide : 403 JSON `{ ok:false, error:{code,...}, ... }`.
- Les clients browser (sans header service) restent compatibles en mode public.

### Idempotence `game_events`
- Les actions mutatrices passent par une liste centrale bridge (`MUTATING_ACTIONS`), avec résolution `getOrCreateEventId(...)`.
- Si `event_id` est absent/invalide, le bridge génère un UUID v4 et loggue `MISSING_EVENT_ID` (warning structuré).
- Si `event_id` est présent/valide, le bridge loggue `EVENT_ID_RX`.
- Ensuite insertion préalable dans `game_events` pour ces actions mutatrices.
- Dédup : duplication détectée par SQLSTATE 23000 → on répond `ok` avec `already_processed:true` et on **court-circuite** le handler.
- En pratique, l’unicité repose sur `event_id` (pas de composite référencé dans le code).  
  Réf : `web/games_ajax.php:155-175`
- Côté front `games`, les appels mutateurs passent désormais avec `event_id` (`canvasCall` et flux player register/deactivate/grid_assign).
- Remote paper register (`remote-ui.js`): `player_register` envoie aussi `event_id`, conservé en localStorage pour retry idempotent tant que la tentative n’est pas confirmée.

### Identité joueur (key-first)
- Les payloads WS/API player-scoped doivent être key-first: `player_id` canon (`p:<uuid>`) prioritaire, `playerId` numérique optionnel (compat).
- `playerId` ne doit jamais transporter un `p:<uuid>`; la validation est faite côté wrappers WS et côté glue PHP.
- Les actions player-scoped des glues quiz/blindtest/bingo exposent `identity_mode` (`canon|legacy`) et `legacy_identity` (bool) pour piloter la suppression du fallback legacy.
- Persistance front canon (session-scoped):
  - `${game}:session_id`
  - `${game}:player_stable_id:${sid}` -> `p:<uuid>` (source de vérité)
  - `${game}:player_db_id:${sid}` -> numeric optionnel
- Helper front: `web/includes/canvas/play/player_identity.js`:
  - `getOrCreatePlayerId({game,sid})` avec migration legacy (`${game}:player_stable_id`, `${game}:player_id`, `player_id`)
    - si une session a déjà une origine d’identité (`${game}:player_id_origin:${sid}`), la suppression de la clé scoped force une régénération `p:<uuid>` (pas de "résurrection" depuis une clé globale legacy)
  - `persistServerPlayerIdIfAbsent(...)` pour ne jamais écraser le scoped canon avec une valeur non canonique
  - log debug contractuel: `PLAYER_ID_STORAGE_RESOLVED {game,sid,source:'scoped|migrated|generated'}`
- Remote (organisateur, ajout joueur papier): `remote-ui.js` maintient aussi une identité canonique locale par clé `game + session + username normalisé` et l’envoie en key-first sur `player_register`.

### Bingo — persistance `phase_winner` (Canvas API)
- Handler : `web/includes/canvas/php/bingo_adapter_glue.php::bingo_api_phase_winner`.
- Schéma : table `bingo_phase_winners` (UNIQUE `event_id` + `(session_id, phase)`, source de vérité), colonnes dénormalisées sur `bingo_players` (`phase_wins_count`, `last_won_phase`, `last_won_at`).
- Migration 2026-02-12 : ajout progressif `bingo_phase_winners.player_id_key` (canonique `p:*`) via script SQL idempotent, avec fallback compat legacy si colonne absente.
- Logique : transaction ; identité gagnant résolue key-first (`player_id` canonique -> `player_db_id`) ; insert historique ; si `event_id` déjà vu ou même joueur sur la même phase -> `already_processed=true`; si autre joueur sur phase existante -> `ok=false`, `error=phase_winner_conflict` + `reason=phase_winner_conflict`; sinon avance `phase_courante`, incrémente dénorm, log `PHASE_WINNER_PERSISTED`.
- Diagnostic corrigé 2026-08-27 : `phases_liste` est canoniquement la liste complète avec sentinelle initial `0` (`0,1,2,3|5`) et `phase_courante` son index 0-based. `advancePhaseWithoutWinner` supprimait seul le `0`, puis écrivait un index calculé dans cette liste raccourcie. Après phase 1 sans joueur, l'index restait donc `1` au lieu de `2`; le `phase_winner phase=2` suivant lisait `phaseNums[1]=1` côté PHP et retournait `PHASE_MISMATCH`. `games_ajax.php` transformait ce refus métier en HTTP 500 par statut par défaut. Le WS conserve maintenant le sentinelle et avance l'index complet; mismatch/terminal/conflit `phase_winner` sont classés HTTP 409, et les refus loggent l'état de phase. Le fallback `prompt()` convertit uniquement à sa frontière les lignes humaines 1-based vers les index `grid_lines` 0-based, avec bornes 3/5 lignes et rejet avant write; le sélecteur normal applique la même borne 3 lignes au format court `5`. Le chemin numérique Bingo, le terminal, l'idempotence et les contrats Hub Remote restent inchangés.

### CORS / origins (résumé)
- Origins **https only**.
- Dev : `*.dev.cotton-quiz.com` (exclut `global.dev.cotton-quiz.com`)
- Prod : `*.cotton-quiz.com` (exclut `global.cotton-quiz.com`)  
  Réf : `games_ajax.php:71-90`

---

## WS contracts (canon, par rôle)
> Objectif : distinguer **commandes sortantes** (frames envoyées) et **messages entrants** (types reçus).

### Organizer
- **Outbound (commands)** : typiquement `registerOrganizer`, `remoteGameState`, `togglePlayPause`, `togglePause`, `nextSong`, `prevSong`, `skipPause`, `force_full_current`, `endGame`  
  (émis via `Bus.emit('game:ws:send', ...)` depuis `boot_organizer.js` / `end_game.js` et modules de contrôle)
- **Inbound** : messages de présence/état (ex : `SECONDARY_PRESENT`, `SCORES_EDITING`) gérés dans `boot_organizer.js`, et messages gameplay “généraux” routés via `ws_effects.js`.

### Remote (`web/includes/canvas/remote/remote-ws.js`)
- **Outbound** (RemoteAPI → `game:ws:send`) :
  - contrôles : `togglePlayPause`, `nextSong`, `prevSong`, `skipPause`, `togglePause`
  - options : `updateGameOptions`
  - bingo : `remote_action` (`start_game|play_song|pause|next_song|set_duration|force_full_current`)
  - fin : `quitGame`; `paper_finalize_end(sessionId,event_id)` demande la finalisation serveur et reste non terminal tant que les writes ne sont pas confirmés.
- **Inbound** (handlers map) :
  - commun : `gameState`, `sessionUpdate`, `state`, `endGame`, `paper_score_finalization_state`, `HUB_SESSION_FINISHED`, `SESSION_ENDED`, `notification`, `remote_sync`, `updatePlayers`, `update_session_infos`, `update_branding`, `forcedDisconnect`, etc.
  - alias sync: `initializeOrUpdateSession` est traité comme `sessionUpdate` côté remote.
- options : `gameOptionsUpdate`, `GAME_OPTIONS_UPDATED`, `STATE_SYNC` (appliqués côté remote) + patchs provenant aussi de `gameState`/`sessionUpdate`/`remote_sync`.
- hydration tardive quiz/blindtest: `session_sync` renvoie désormais `playlistSongs` dès qu’une playlist non vide est disponible (pas uniquement au tout premier `initializeOrUpdateSession`), ce qui restaure le titre série / total questions / CTA support en remote.
- garde historique corrigée : le refresh des propositions n’est plus bloqué quand `currentSongIndex` logique reste identique pendant la transition jingle -> round #1.
- reveal remote (quiz/blindtest) stabilisé : la correction n’est plus effacée sur chaque `remote/options:proposals`, la classe visuelle canon `option-reveal` est appliquée avec compat legacy `.reveal`, `remote/options:correct` transporte `{text,key}`, et le patch DOM applique la correction par `data-option-key` (key-first, fallback texte uniquement).
- observability remote options : logs v1 `REMOTE_OPTIONS_RX` (réception), `REMOTE_OPTIONS_RENDER` (rendu), `REMOTE_OPTIONS_GUARD_BLOCK` (blocage guard), avec contexte `phase/isJingle/started`, émis en bus-first via `ui/remote:action` (pas de `window.Logger.debug` direct).
- remote add-player (`handleAddPlayerLive`) : payload `player_register` = `{ username, player_id, event_id, sessionId|sessionPrimaryId }` ; `player_id` canonique persisté localement ; `event_id` conservé jusqu’au succès pour retry idempotent.
- remote mode manuel: à réception `remote/sessionInfos` quand `paperMode` change, `applyManualModeUI()` est rejoué immédiatement pour éviter un calcul UI sur un `SESSION_PAPER` obsolète.
- remote actions joueur/phase (`remote-ui.js`) : `admin_player_register`, `admin_set_score`, `admin_phase_winner`, `admin_phase_fail` transportent `event_id`, `player_id` canonique si dispo, et `playerId` numérique en compat.
- remote listing joueurs (quiz/blindtest) : fusion key-first sur identité canonique (`player_id` si dispo, sinon id numérique) pour éviter les doublons d’affichage lors des snapshots mixtes (`playerId` legacy + `player_id` canonique).
- bridge PHP quiz/blindtest (`quiz_adapter_glue.php` / `blindtest_adapter_glue.php`) : `players_get` et preload `players` renvoient aussi `player_id` (et `updated_at` si disponible), avec fallback safe pré-migration si la colonne n’existe pas encore.
- mode historique (session terminée) : `players_get` accepte `includeInactive` pour inclure les participants déconnectés; la remote l’active automatiquement en vue terminée pour éviter de “sortir” des joueurs du classement final.
- WS quiz/blindtest (reconnexion orga sur session terminée) : réhydratation DB forcée + reconstruction du snapshot `endGame` pour réaligner l’affichage final avec les participants persistés.
- WS bingo (auth orga) : à l’authentification, si la phase courante est terminale, l’hydratation joueurs DB active `includeInactive` pour reconstruire un snapshot historique cohérent.
- exception Bingo (papier animateur) : `admin_phase_winner` peut être envoyé sans `player_id/playerId`; le WS Bingo applique alors un avancement manuel de phase (sans persistance `phase_winner` DB), pour permettre la progression même sans joueur sélectionné.
- organizer Bingo (`core/ws_effects.js`) : sur `phase_over`, la phase gagnée utilise désormais `won_phase` en priorité (fallback legacy via `next_phase` si absent) pour éviter les décalages d’annonce en correction manuelle papier.
- notifs Bingo admin manuel : les victoires forcées réutilisent le format historique `PlayerWin` (même canal/UI que les victoires standards), au lieu d’un message `Info` spécifique.
- fallback podium Bingo (orga + remote) : en absence de gagnants hydratés, affichage cohérent papier avec `Joueur inconnu` par phase gagnée (Bingo / Double ligne / Ligne), au lieu d’un fallback score-driven ou placeholders génériques.
- remote Bingo fin de partie : la liste joueurs est conservée en `Partie terminée` (ignore snapshots vides tardifs) et fallback `players_get` est déclenché si `endGame.players` est absent/vide.

### Player (`web/includes/canvas/play/play-ws.js`)
- **Outbound** :
  - quiz/blindtest : `registerPlayer { sessionId, player_id, playerId? }` (canon strict + db optionnel), gameplay `checkAnswer { player_id, ... }`, fin `quitGame`
  - bingo : auth auto `auth_player` / `auth_player_paper` avec `player_id` canon obligatoire (+ `id_player` db pour compat auth), fin `player_quit`
- **Recovery contract (mobile/background)** :
  - `ws_connector.js` reste seul pilote de la reconnexion transport;
  - au retour `visibilitychange/pageshow`, le player ne fait un re-register applicatif que si le transport est déjà `OPEN`;
  - si le transport est `CONNECTING` / `CLOSED` / `ERROR`, le player ne ferme rien et délègue au connector;
  - après reconnect transport, `ws_connector.js` rappelle `window.reRegisterPlayer(reason)` une fois `ws/open` atteint;
  - instrumentation V1 attendue:
    - `PLAYER_FRONT_BOOT`
    - `PLAYER_FRONT_LOG_FLUSH_TRY|OK|FAIL`
    - `PLAYER_WS_LIFECYCLE_DECISION`
    - `WS_CONNECTOR_LIFECYCLE_DECISION`
    - `PLAYER_REREGISTER_TRY|OK|FAIL`
    - `REGISTER_KEEP_LOCAL_IDENTITY_DESPITE_PROBE_MISS`
- **Observability chain (player front)** :
  - `PLAYER_FRONT_BOOT` est créé quand le logger player accroche réellement le Bus front, puis envoyé immédiatement si le transport est déjà `OPEN`, sinon rejoué au premier `ws/open`;
  - `PLAYER_FRONT_LOG_FLUSH_TRY|OK|FAIL` sont émis en `log_event` direct côté navigateur, avec `role:"player"` ou `role:"remote"` selon le client recevant le flush forcé;
  - si le logger a raté le premier `ws/status=open` (cas `remote` possible quand `window.Bus` arrive après l’ouverture), `buildFlushMeta()` relit l’état partagé du connector pour éviter un `ws_ready_state=unknown` sur un flush pourtant réellement envoyé sur WS;
  - ces marqueurs techniques de diagnostic (`PLAYER_FRONT_BOOT`, `PLAYER_FRONT_LOG_FLUSH_TRY|OK`, lifecycle, re-register OK, conservation d’identité locale) sont classés `debug` dans le viewer; seuls les échecs restent en `warn`/`error`;
  - les serveurs WS quiz/blindtest/bingo acceptent déjà `log_event` / `log_batch` côté player, puis les exposent via leurs endpoints `/logs`.
- Register API front (`web/includes/canvas/play/register.js`) :
  - quiz/blindtest/bingo envoient `player_register` avec `player_id` session-scoped (`${slug}:player_stable_id:${sessionId}`),
  - migration douce legacy: si `${slug}:session_id === sessionId` et `${slug}:player_stable_id` existe, copie vers la clé session-scoped,
  - la clé legacy est conservée pour compat mais n’est plus la source de vérité,
  - pour Bingo, séparation explicite front: `player_id` (canon `p:<uuid>`) vs `player_db_id` (id DB numérique legacy pour auth WS papier/numérique).
- Resume probes / identité locale :
  - un probe `players_get` / `bingoPlayerExists` temporairement négatif au retour mobile n’entraîne plus de purge immédiate du `player_id` local;
  - la décision métier est loggée en V1 (`REGISTER_KEEP_LOCAL_IDENTITY_DESPITE_PROBE_MISS`) puis la reprise WS/API tranche l’état réel.
- Bingo APIs player côté front (`play/register.js` + `play/play-ui.js`) :
  - `grid_assign`, `grid_hydrate`, `grid_cells_sync` envoient `player_id` canonique en premier, avec `playerId` numérique seulement en fallback compat,
  - `grid_id` est persisté en clé session-scoped `${slug}:grid_id:${sessionId}` (fallback lecture legacy `bingo_grid_id`),
  - juste avant `player_register` Bingo, `player_id` est normalisé strictement (jamais numérique) via `preparePlayerIdPreRegister`, avec migration legacy numeric vers `player_db_id` et log debug `PLAYER_ID_PRE_REGISTER`.
- **Inbound** :
  - commun : `gameState`, `sessionUpdate`, `updatePlayers`, `registrationSuccess`, `SESSION_ENDED`, `answerResult`, `answerReveal`, `update_session_infos`, `update_branding`
  - bingo : `state`, `passed_song`, `phase_over`, `remote_sync`, `notifications`, `demo_reset`
  - replacement: `SESSION_REPLACED` (last connection wins) -> onglet remplacé passe en read-only, bannière persistante, et reconnect manuel via “Reprendre ici”.
- player supports (quiz/blindtest) :
  - pipeline Drive partagé (tous types) via `core/player/index.js::getDirectGoogleDriveUrl` puis rendu `iframe` `/file/d/<id>/preview` si host `drive.google.com|docs.google.com`,
  - timeout adaptatif `drive/image` 15-20s, annulation des timers au `load/error`, logs `SUPPORT_START_FAIL_DETAIL` enrichis (`support_kind`, `timeout_ms`, `retry_count`, `stale_token`),
  - Drive: retry “hard reload iframe” retiré (fenêtre de grâce conservée) pour éviter les disparitions visuelles sur supports déjà partiellement affichés,
  - sémantique Drive timeout (tous types Drive):
    - `drive-timeout-before-render` = erreur bloquante (pas de rendu confirmé),
    - `drive-timeout-after-render` = soft error observée, mais `support/started` est maintenu en `drive-ready` pour ne pas masquer un support déjà visible/exploitable.
- Close code WS dédié replacement player : `4005` (`player replaced`) ; le transport front stoppe la reconnexion auto tant que la reprise n’est pas explicitement demandée.

### Note cross-origin (register)
- `localStorage` reste borné à l’origin (sous-domaine/protocole): un `player_id` session-scoped n’est pas partagé entre origins distinctes.
- Résilience actuelle: fallback serveur (`MISSING_PLAYER_ID` + UPSERT `(session_id, player_id)`), mais continuité inter-origins non garantie sans transport explicite du `player_id` (token/URL/postMessage côté produit).

### Quit player & `deactivate_player` (cross-game, canon 2026-02-10)
- `quiz` / `blindtest` : `quitGame` (front -> WS) puis désactivation Canvas (`deactivate_player`) côté WS serveur.
- `bingo` : `player_quit` (front -> WS) puis désactivation Canvas (`deactivate_player`) côté WS serveur.
- Conséquence: plus d’appel API front direct `deactivate_player` dans `games` pour bingo; responsabilité unifiée côté serveurs WS.

---

## Gameplay concepts & transitions (compact)
### Index & statuts (glossaire minimal)
- `currentSongIndex` (front) / `current_song_index` (DB) : position **0-based**
- Bingo : `num_passed_songs` sert à dériver l’index logique
- `item_index` : index **humain** “contenu” (1-based, sans jingles) utilisé pour logs (`core/player/index.js`, `emitRoundStarted`)
- `gameStatus` : libellé humain (0 En attente / 1 En cours / 2 Pause / 3 Partie terminée) via maps côté adapters
- Bingo phases : `current_phase` ∈ {0,1,2,3/5,-1} avec labels (En attente/Ligne/Double ligne/Bingo/Terminé) + `is_playing` pour En cours/Pause

### End-of-game (vue mentale)
- Déclencheur possible : commande `endGame` ou message `SESSION_ENDED` / phase bingo -1
- `ws_effects.js` route `endGame` vers `srv/endGame` (podium, scores)
- `end_game.js` (organizer) stop timers + `Bus.emit('session/end')` + cleanup UI (et persistance finale si branchée)

### Terminated Static Mode (2026-02-11)
- Si `window.Preload` indique une session terminée (`preload.isTerminated` ou `preload.session.isTerminated` ou `preload.session.gameStatus === "Partie terminée"`), le front ne boot pas de WS.
- Conséquences:
  - pas de `auth_client` / `registerOrganizer` côté organizer,
  - pas de `registerOrganizer` / `remoteGameState` côté remote,
  - pas de `auth_player*` / `registerPlayer` côté player si preload terminal dispo.
- Source de vérité en mode statique: `window.Preload` injecté serveur.
- Bascule live -> static:
  - à réception de `endGame`, le front conserve désormais le WS en live et ouvre une fenêtre de grâce de 20 min (session-scoped, `sessionStorage`),
  - au boot/reload, si preload est terminal mais qu’une grâce active existe, le WS reste autorisé,
  - hors grâce, le comportement statique preload s’applique (pas de boot WS).
- Bingo preload enrichi:
  - `preload.players.players[]` (issus de `bingo_players` via `players_get`, shape compat organizer),
  - `preload.phase_winners[]` (issus de `bingo_phase_winners`, ordonnés par phase),
  - utilisé en statique pour reconstruire le podium winners sans WS live.

---

## Paper mode
- Flags : `paperMode` (WS payload), DB `flag_controle_numerique` (0 papier / 1 digital)
- Override : `localStorage paperModeOverride_<sid>`
- Player paper : si déjà “paper registered”, ignore la majorité des WS sauf `update_session_infos`
- Bingo paper : auth `auth_player_paper`, quit via `player_quit`
- Templates : `quiz_support_paper.php`, `blindtest_support_paper.php`, `bingo_grids_paper.php`
- Grids bingo : via HTTP APIs côté `bingo_adapter_glue.php` (assign/sync)
- Quiz uniquement (bascule papier -> numérique):
  - autorisée uniquement avant démarrage de la session,
  - contrôle de conformité effectué sur toutes les questions de toutes les séries du quiz (pas uniquement la série courante),
  - hydratation organizer expose `digitalSwitchAllowed`, `digitalSwitchInvalidCount`, `digitalSwitchReason`, `digitalSwitchMessage`,
  - anti-bypass serveur au persist (`session_update`): transition `flag_controle_numerique 0 -> 1` revalidée côté DB, refusée avec `PAPER_TO_DIGITAL_BLOCKED_MISSING_PROPOSALS` si session démarrée (`reason=STARTED`) ou questions non “numérique-ready”.

## Contrôle offre active (organizer/master)
- Contrôle appliqué à l’accès organizer (`web/organizer_canvas.php`) dès l’hydratation session:
  - détection démo via `championnats_sessions.flag_session_demo` (et `serverSessionMeta.isDemo`),
  - session démo: bypass du contrôle offre,
  - session non-démo: offre active requise, sinon blocage 403 avec CTA offres.
- CTA offres:
  - URL finale forcée sur le domaine `pro` (`$CONF_PRO_URL`),
  - chemin contextuel `/extranet/ecommerce/offers/...` conservé si fourni par le guard,
  - fallback `/extranet/ecommerce/offers`.
- Logique de référence réutilisée côté app: `app_session_launch_guard_get(...)` (fallback local aligné si indisponible dans le contexte).
- Bridge Canvas (`web/games_ajax.php`):
  - depuis `2026-03-05`, plus de guard offre sur les writes (`session_update`, `prizes_save`, `resetdemo`),
  - raison: éviter les effets de bord runtime (persistance bloquée) sur sessions en cours,
  - politique retenue: contrôle d’offre centralisé au point d’entrée organizer (`web/organizer_canvas.php`).

---

## Script map 20/80 (why / risk / validate)
- `core/ws_connector.js` — **why**: transport WS unique / auth / queue / reconnect ; **risk**: plus de live, boucle reconnect ; **validate**: `ws/status`→open + messages passent + (std) heartbeat ~25s.
- `core/ws_effects.js` — **why**: router inbound WS→Bus + effets gameplay ; **risk**: commandes/états non répercutés ; **validate**: recevoir `gameOptionsUpdate` → `options/updated`.
- `play/play-ws.js` — **why**: auth/register player + réponses ; **risk**: player muet / answer jamais envoyée ; **validate**: `checkAnswer` → `game:ws:send`.
- `remote/remote-ws.js` — **why**: télécommande + mapping handlers ; **risk**: next/pause ignorés ; **validate**: action remote → état serveur revient.
- `core/session_persist.js` — **why**: push `session_update` ; **risk**: désynchro/persistance cassée ; **validate**: une action gameplay produit 1 write attendu.
- `web/games_ajax.php` — **why**: CORS/auth/idempotence/dispatch ; **risk**: 403, CORS, already_processed mal compris ; **validate**: POST avec/sans `event_id`.
- `php/*_adapter_glue.php` — **why**: accès DB par jeu ; **risk**: état/podium faux ; **validate**: preload session cohérent.
- `core/logger.global.js` — **why**: writer logs Bus→LogEntry ; **risk**: viewer illisible/silencieux ; **validate**: `game:ws:send` + `game:ws:message` loggués.

---

## Bus hooks for logging (liste courte)
Le writer central écoute typiquement :
- Transport : `ws/status`, `ws/open`, `ws/close`
- WS payloads : `game:ws:send`, `game:ws:message`
- HTTP : `api/call`, `api/ok`, `api/fail`
- Gameplay : `timer/*`, `support/*`, `session/*`, `player/*`, `remote/*`
Writer : `web/includes/canvas/core/logger.global.js`

---

## Interactions (vue rapide)
- Clients canvas ↔ WebSocket (transport unique géré par `web/includes/canvas/core/ws_connector.js`), routing inbound via `ws_effects.js`.
- HTTP bridge `web/games_ajax.php` reçoit les writes/reads Canvas et appelle les adapters PHP par jeu.
- Logs front centralisés via `web/includes/canvas/core/logger.global.js` (Bus-first).
- Test pre-lancement organizer via `prelaunch_check.js`: lit `GameStore`, appelle `canvasCall('session_meta_get')`, observe `window.__CANVAS_WS_RUNTIME__` / Bus WS, applique les remplacements temporaires sur `GameStore.playlist.songs`, puis journalise `prelaunch/*`.

## Actions clés (runbook court)
- Lancer front (serveur PHP) : vhost cible `games/web/` (cf. `games/web/config.php`).
- Tester bridge : POST sur `games/web/games_ajax.php?t=jeux&m=canvas` avec/ sans `event_id`.
- Ouvrir viewer logs front : `games/web/logs_session.html?sessionId=<sid>`.

## Variables d’environnement (bridge PHP)
| Key | Required | Used in | Note |
| --- | --- | --- | --- |
| `CANVAS_SERVICE_TOKEN` | Requis pour valider les appels inter-service signés | `games/web/games_ajax.php` | Comparé au header `HTTP_X_SERVICE_TOKEN` |

## Happy path (front/bridge)
1) Vhost pointe vers `games/web/` (config.php OK).
2) Token service présent dans l’env PHP (`CANVAS_SERVICE_TOKEN`) pour les appels WS→bridge signés.
3) Client front init WS via `ws_connector.js`, reçoit `state` (bingo) ou handshake std.
4) Actions mutatrices émettent writes HTTP via `games_ajax.php` avec `event_id` (client ou bridge compat).
5) Bridge accepte, insère dans `game_events` (idempotence) et renvoie payload JSON `ok:true`.
6) Logs viewer (`logs_session.html`) affiche les entrées `/logs` WS pour le `sessionId`.

## Organizer mobile officiel: iframe `Jouer`
- Le parent organizer construit l'iframe joueur avec `embed=gm` et, hors demo, `gm_display_name` a partir du prenom fiable connu cote organizer. Fallback conserve: `Game Master`.
- `register.js` lit ce contexte des query params / `AppConfig`, masque le formulaire manuel via l'etat `GM_AUTOREGISTERING`, puis lance `player_register` sans attendre une identite locale preexistante.
- Le payload auto-GM porte `organizer_auto_player=1` / `gm_autoreg=1`. Les handlers Quiz, Blind Test et Bingo utilisent ce flag uniquement pour ne pas bloquer le displayName auto sur les controles `USERNAME_ALREADY_USED` / `USERNAME_REFERENCED`; les vrais joueurs QR gardent les controles standard et le formulaire manuel.
- L'iframe `embed=gm` ne rend pas le bloc `Compte joueur Cotton`, car ce parcours appartient aux vrais joueurs.

## Organizer mobile demo: onglet `Jouer` prioritaire
- En demo mobile numerique, le toggle organizer est rendu visuellement en `Vue joueur / Vue animateur` et l'etat initial ouvre `Vue joueur` pour afficher directement l'experience joueur.
- Les handlers restent attaches aux IDs historiques; l'ordre visuel ne change donc pas le sens interne des actions.
- Le choix manuel demo mobile est conserve en `sessionStorage` par jeu + session. Si l'utilisateur bascule sur `Animer`, les renders suivants et un reload du meme onglet respectent ce choix.
- Les sessions officielles mobiles gardent `Animer / Jouer` avec `Animer` par defaut. Le desktop n'utilise pas cette inversion.
- La mention hors iframe indique le profil demo: `Équipe démo` pour Quiz, `Joueur démo` pour Blind Test / Bingo.
- En vue en attente demo mobile, l'aide `Lance ta démo...` est positionnee au-dessus du bloc QR et alignee a gauche.

## Bridge EP -> games
- `games/web/includes/canvas/php/ep_account_bridge.php`
  - pour `quiz`, le username injecté dans `games` reste le nom d'équipe;
  - pour `blindtest` / `bingo`, le bridge utilise désormais `equipes_joueurs.pseudo` si disponible, avec fallback sur `prenom`.
- `games/web/includes/canvas/php/boot_lib.php`
  - `participant_lookup` cote remote papier applique maintenant un filtre dur par organisateur a partir de la session courante (`championnats_sessions.id_client`);
  - `quiz` propose uniquement des equipes deja vues chez cet organisateur via `championnats_sessions_participations_probables`, `championnats_sessions_participations_games_connectees` et le legacy `equipes_to_championnats_sessions`;
  - `blindtest` / `bingo` proposent uniquement des joueurs deja lies au compte organisateur via `championnats_sessions_participations_probables`, `championnats_sessions_participations_games_connectees` et le legacy bingo `jeux_bingo_musical_grids_clients`.

## Scénarios d’échec
- Symptôme : 403 sur `games_ajax.php` lors d’un write WS — Cause : header `X_SERVICE_TOKEN` invalide vs `CANVAS_SERVICE_TOKEN` — Fix : aligner les secrets côté WS/PHP.
- Symptôme : pas de logs dans viewer — Cause : endpoint WS `/logs` ne renvoie rien (sid erroné ou pas de log) — Fix : vérifier sid, générer trafic, relire.
- Symptôme : déjà traité (`already_processed:true`) — Cause : même `event_id` réutilisé — Fix : générer un nouvel `event_id` côté appelant.

## Observability (viewer-first)
- Logs front : `games/web/logs_session.html` consomme `logs_proxy.php` → lit `/logs` du WS ciblé (JSONL).
- Chips viewer (`total/debug/info/warn/error`) : stats globales obtenues via `logs_proxy.php?stats=1&force=1` (recalcul forcé, sans cache) pour éviter les écarts temporaires après flush front; la chip `visibles` reste calculée localement sur les entrées chargées.
- WS debug côté front : hooks `logger.global.js` sur Bus (`ws/status`, `game:ws:send`, `game:ws:message`).
- HTTP bridge : réponses JSON explicites (`ok`, `error`, `already_processed`, `code`), CORS selon règles dans `games_ajax.php`.
- Flush front vers WS :
  - `LOG_FLUSH_TRIGGER` (debug) avec `source="viewer"` ou `source="session_end"` et meta `{sid, game, source, queued_count}`.
  - `LOG_FLUSH_TRY` (debug), `LOG_FLUSH_OK` (info), `LOG_FLUSH_FAIL` (warn).
  - Meta flush attendue: `{count, ws_ready_state, ws_url?}` (URL seulement si non sensible/disponible).
- Viewer “Forcer flush” :
  - `logs_session.html` écrit toujours `localStorage.LOG_FLUSH_REQUEST` pour réveiller un onglet local sur le même navigateur/origin.
  - le bouton appelle aussi `logs_proxy.php?action=force_flush`, qui relaie vers `/force_flush` sur quiz/blindtest/bingo pour un flush distant réel.
  - `logger.global.js` écoute l’événement `storage` sur `LOG_FLUSH_REQUEST` puis exécute `flushBufferToWS()`.
  - `logger.global.js` normalise chaque entrée avant envoi (`ensureEntrySourceTs`) : conservation de `entry.ts` si valide, fallback ISO sinon, et ajout systématique `meta.client_ts` + `meta.event_ts` (timestamps source d’émission front).
  - Le flush envoie `type:"log_batch"` sur la WS déjà ouverte de la session active.
  - Le même chemin émet aussi un flush auto à la fin de session (`gameStatus === "Partie terminée"`).
- Attendu côté WS ingest (`log_batch`/`log_event`) : ingestion visible dans les logs WS (ex: marqueur `LOG_BATCH_RX` si implémenté, ou entrées enrichies `meta.ingested_by`) puis entrées `src=GAMES` visibles dans `/logs` avec `msg` non vide et `meta` utile.
- Reveal player (quiz/blindtest) :
  - le reveal arrive via `answerReveal` (post-verrou / fin timer), avec payload `{correctOption, correctOptionKey?, currentSongIndex}`.
  - logs front debug associés : `PLAYER_REVEAL_RX` (`game,sid,itemIndex,has_correct_key,correctKey?`) puis `PLAYER_REVEAL_APPLY` (`found,method:key|legacy`).

## 2026-04-13 — Détection d'environnement WS

`games/web/config.php` ne doit pas limiter la détection `dev` au seul host `games.dev.cotton-quiz.com`, ni dépendre uniquement de `SERVER_NAME`. La règle utilise maintenant `HTTP_HOST` en priorité, avec fallback `SERVER_NAME`, et s'aligne sur `global` avec `*.dev.cotton-quiz.com`. Cela évite de basculer par erreur en `prod` sur d'autres sous-domaines dev ou derrière certains vhosts/proxies, et donc d'injecter les URLs WebSocket de production dans `AppConfig.wsUrl`.

En complément, `games/web/organizer_canvas.php` expose temporairement en `dev` un objet `window.__COTTON_WS_DEBUG__` dans la console navigateur. Il permet de comparer le host vu par PHP (`HTTP_HOST`, `SERVER_NAME`), l'environnement retenu (`conf.server`, `AppConfig.env`) et l'URL WS finalement injectée (`AppConfig.wsUrl`) pour distinguer un mauvais routage serveur d'un cache HTML stale.

Le diagnostic a mis en evidence un second point: `games/web/modules/app_orga_ajax.php` n'initialisait pas localement `$env`, contrairement aux variantes `play` et `remote`. Il héritait donc de la portée de `games_ajax.php`, où `$env` etait ensuite reaffecte via `$CONF_SERVER ?? 'prod'` alors que `$CONF_SERVER` n'etait pas defini. Organizer pouvait ainsi injecter une `wsUrl` de production alors meme que `conf.server === 'dev'` et que la matrice runtime des URLs WS etait correcte.

Le debug `window.__COTTON_WS_DEBUG__` a ensuite ete retire apres validation du correctif. Il ne faisait partie que de la phase de diagnostic et n'est pas conserve dans le rendu standard organizer.

## 2026-04-16 — Branding organizer: cadrage final reporte cote `global`

Le branding de session recadre toujours le visuel localement dans la modale organizer (`600x240` cover) pour l'apercu utilisateur. En revanche, la solution retenue n'est plus de fabriquer un derive HD dans `games`.

`session_modals.js` est revenu a un flux simple: le front affiche sa preview locale, mais renvoie de nouveau le fichier source brut au backend pour `branding_visuel`.

Le cadrage final du visuel branding est maintenant porte par `global`, qui ne rabaisse plus la cible serveur en fonction de la taille source. Le visuel uploadé conserve donc le ratio attendu du branding (`1600x640`, soit le meme ratio que `600x240`) sans dependre du derive front.

## 2026-05-05 — Bingo organizer: badges gagnants de phase

Les badges organizer Bingo (`LIGNE`, `DOUBLE LIGNE`, `BINGO`) sont portés par `bingo.medalsById` et rafraîchis via `bingo/medals/updated`. Le handler `srv/phaseOver` résout l'id gagnant vers la clé joueur affichée (`playerId` prioritaire, id legacy en fallback), puis déclenche le rerender mobile et desktop si une médaille ou un gagnant de phase change. Le rerender cible aussi la liste organizer compacte en live, pas uniquement les listes plein écran ou le mode pause.

Au rendu, une ligne joueur Bingo cherche son badge sur les différentes clés connues (`playerId`, `player_id`, id DB/legacy, mapping grille). Cela évite qu'un update live du joueur GM en iframe masque temporairement une médaille stockée sous la clé canonique `p:`.

Au boot organizer, `Preload.phase_winners` réhydrate les gagnants et `medalsById` même si la session Bingo est encore en cours. Cette réhydratation est ignorée juste après un reset démo Bingo (`bingo_postreset=1`) pour ne pas réinjecter d'anciens gagnants dans une démo remise à zéro.

Après reset d'une démo Bingo depuis une session terminée, `bingo_postreset=1` reste uniquement un signal parent. Au boot suivant, si le preload serveur confirme que la session est revenue en `En attente`, l'organizer vide l'iframe joueur GM puis la reconfigure avec son URL normale. Cela évite de dépendre d'un push WS `demo_reset` que l'iframe statique terminée ne reçoit pas toujours.

L'hydratation depuis snapshot conserve les médailles déjà connues quand le snapshot ne transporte pas de notifications `PlayerWin`, afin d'éviter qu'un état serveur partiel efface les badges pendant une session en cours.
- À la reprise d'une session numérique suspendue, un `hubAutoPlayer` actif et non `left` protège la phase de restauration: le retour de la gate à `open` ne peut pas afficher le formulaire avant la tentative WS. Cette garde ne vaut pas preuve d'authentification et ne change pas le fallback hors Hub.
- Une session Hub déjà commencée est restaurée côté Master en `Pause`; elle publie ce snapshot aux Players, puis ne revient à `En cours` qu'après une action Play explicite. `hub_launch` conserve l'auto-start uniquement au premier lancement réel.
- La publication de reprise est acquittée après `ws/registered`, afin que le snapshot `Pause` ne dépende pas de l'ordre entre `game/paused`, l'ouverture WS et l'attachement de `session_sync`.

## 2026-07-31 — Hub Play: branding live

Hub Play consomme maintenant le branding Hub depuis les payloads joueur existants, sans ajouter de nouveau polling.

Contrat:
- `current_player` et `active_launched_session` chargent `client` + `branding`;
- les reponses exposent `hub_branding` avec revision, titre, meta, visuel, logo, police, couleurs et variables CSS;
- le front Play applique ces valeurs sur `:root`, le lien de police, le bandeau visuel, le logo discret de bas de page, le titre et la meta d'en-tete;
- le visuel et le logo sont cache-bustes avec la revision Hub pour couvrir un remplacement de fichier sous URL identique.

Effet attendu: une personnalisation faite depuis le Dashboard Pro se propage a Hub Play sans reload complet, comme elle le fait deja sur Hub Master.

## 2026-07-31 — Player Canvas Hub: transition initiale sans lobby

Le contrat de navigation Hub reste inchange: Hub Play redirige le joueur vers le Player Canvas des que la session Hub focus est lancee et auto-joinable. Aucun `runtime_started`, `player_redirect_ready`, nouveau signal WebSocket, nouveau contrat Global, retard de publication `play_url` ou dependance au jingle n'est introduit.

Marqueur canonique:
- le rendu Hub Player s'appuie sur `HUB_AUTO_PLAYER.enabled`, produit dans `player_canvas.php` seulement apres preuve serveur: token Hub valide, session rattachee au Hub, execution ouverte, joueur Hub resolu, mapping actif et participation runtime numerique avec `participant_key` canonique.
- `HUB_SESSION_BRIDGE.has_hub` n'est pas utilise comme declencheur de suppression du lobby, car il serait trop large pour un acces direct historique a une session rattachee Hub sans auto-player prouve.

Rendu initial:
- en contexte Hub Player prouve, `#screen-waiting` ne rend plus le lobby historique. Il rend directement une scene `player-hub-transition-scene` avec `La partie démarre…` et `Prépare-toi à jouer !`, sans CTA, sans lots, sans tips et sans carte equipe Blind Test.
- hors Hub, le markup historique de lobby reste dans la branche existante: `Bienvenue`, textes Quiz/Blind Test/Bingo, CTA Blind Test `Former une équipe`, lots et tips.
- les points d'accroche historiques sont conserves: `#screen-waiting`, `#screen-running`, `#player-options`, `#bingo-grid`, `#state-pill`, `#players-count`.

Layout mobile:
- `.player-root` et ses descendants utilisent `box-sizing:border-box`, afin que les largeurs `100%` des conteneurs Player avec padding/border ne produisent pas de depassement horizontal.
- la scene Hub reste bornee par `width:100%` + `max-width:520px`, sans `100vw` ni largeur fixe mobile.
- la hauteur utile s'appuie sur le layout flex existant: `player-root` en colonne `min-height:100dvh`, `player-main` flexible, padding bas de `.screen` conservant la reserve de la barre basse fixe. La carte de transition utilise une hauteur compacte `svh` et le visuel/header est compacte uniquement en contexte Hub Player sur les faibles hauteurs.
- le spinner respecte `prefers-reduced-motion`.

Remplacement par runtime:
- Quiz et Blind Test continuent de recevoir `gameState` / `sessionUpdate`, puis `play-ws.js` emet `player/state`; `play-ui.js::setState(...)` masque `#screen-waiting` et affiche `#screen-running`, puis rend les options dans `#player-options`.
- Bingo continue de recevoir `state`, `reset_game`, `passed_song` ou `players_sync`; le meme chemin `player/state` affiche `#screen-running` et `renderBingoGrid()` hydrate `#bingo-grid`.
- en reprise apres suspension, `GAME_RESUMED` reemet `registerPlayer`, attend `registrationSuccess`, puis demande `getGameState`; la restauration ne depend pas du jingle.

Portee:
- aucun changement Hub Play, Hub Master, Global, mappings, participations, tables runtime, protocoles WS, generation `play_url`, focus Hub, regles de demarrage, suspension/reprise, QR ou etats metier des jeux.
- `player_auto_restore` reste le contrat d'auto-inscription Hub existant; la correction remplace le lobby dans le HTML initial au lieu de masquer un lobby deja rendu.
- controles Playwright sur fixture locale: `320x568`, `360x640`, `375x667`, `390x844`, `412x915`, `624x1024`, `667x375`; aucun scroll horizontal, spinner/titre/sous-titre visibles, aucune collision header/barre basse.
- recette navigateur reelle encore a faire: lancement initial, arrivee en partie active, reload/reconnexion, suspension puis reprise sans jingle, et acces Player hors Hub.
## Update 2026-08-31 - Master/Remote en runtime démo Hub

Hub Master et Hub Remote manipulent toujours la carte officielle, mais leurs URLs Organizer/Remote sont maintenant reconstruites depuis `runtime_session_id` et `runtime_mode` de l'exécution ouverte. Refresh, retry et takeover retrouvent ainsi la même démo canonique sans l'inscrire dans le Programme ni déplacer le focus vers elle.

Les resets Blind Test, Quiz et Bingo restent le contrat des URLs démo historiques (`Continuer / Recommencer`) et ne sont plus appelés lors d'un nouveau test depuis Hub. Chaque intention Hub reçoit un runtime neuf; une source papier est toujours copiée en numérique avec une information explicite dans Master/Organizer.

Pendant une démo, les QR Organizer restent disponibles: le participant automatique `Joueur démo` / `Équipe démo` compte dans la capacité de deux, et un joueur réel supplémentaire peut rejoindre le runtime par son URL directe. Ce join reste entièrement hors des tables roster, mappings et participations probables Hub. En mode commercial prospect, le QR du Master Hub est volontairement visible mais désactivé; le QR Hub et Hub Play conservent leur comportement historique avant fenêtre.

Une réentrée sur exécution ouverte conserve `execution_id`, runtime et URL sans reset automatique, puis expose la modale historique `Continuer / Recommencer`. La recette réelle a montré que les deux URLs étaient déjà strictement identiques; la page blanche venait du masque initial `hub_launch`, qui cachait aussi SweetAlert alors que le boot attendait sa réponse avant d'attacher l'UI. Ce masque est maintenant libéré juste avant le choix. Le service d'une exécution démo ouverte ne rejoue plus `focus_set_active`, préparation/reset démo, création d'exécution, injection ou publication de présentation: il résout le runtime et reconstruit l'URL Organizer. Le CTA reste dans tous ces cas `Tester le jeu`, tandis que `Reprendre` demeure réservé à l'officiel. Une démo déjà terminale rouverte manuellement garde son rendu historique; une démo Hub qui atteint sa fin naturelle en direct montre son résultat brièvement puis retourne au Hub. Quand l'exécution précédente est complétée, la même démo est reset avant la création d'une nouvelle exécution. La fin naturelle continue d'exclure les statistiques Hub.
