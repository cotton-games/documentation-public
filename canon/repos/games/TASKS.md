# Repo `games` — Tasks (journal bref)

## PATCH 2026-09-04 - Hub Remote: routage canonique générationnel
- [x] Préserver strictement le flux Remote → commande → Hub Master → service Global; interdire au module Remote lancement direct, création/réutilisation runtime, focus et construction d'URL historique.
- [x] Naviguer uniquement depuis `control_poll.client_routing.joinable`; supprimer la redirection depuis `command.result` et accélérer seulement le poll après commande terminée.
- [x] Transporter `execution_id + routing_generation` vers la Remote historique et renvoyer `returned_execution_id + returned_routing_generation` au Hub.
- [x] Remplacer les autorisations locales/SSR/relais temporels par le seul blocage du couple exact retourné; autoriser une génération plus récente du même `execution_id`.
- [x] Couvrir le couple exact, la génération suivante, l'absence de navigation par résultat de commande et l'absence de chemin runtime direct dans les contrats PHP/JS.
- [x] Reconnaître le message historique `registrationError` d'une Remote secondaire arrivée avant la session WS primaire et le traiter par le retry Hub Remote borné, sans rendre les erreurs définitives retentables.
- [x] Ajouter au modal d'overlay commun un spinner discret pour `Accès à la partie…` et `Retour à la soirée…`, en réutilisant `remote-spin`; le masquer dans tous les autres états et conserver le respect global de `prefers-reduced-motion` sans changer aucune condition ni cadence.
- [x] Relire START main, SITEMAP/DOCS_MANIFEST/HANDOFF develop et le journal AI Studio raw; aucune évolution externe Hub Remote/Master/runtime à recharger.
- [x] Confirmer que `commercialDemoMode` était lu par le clic runtime avant sa première affectation par `business_snapshot`, tandis que le harnais JS injectait artificiellement sa déclaration.
- [x] Initialiser `commercialDemoMode` depuis le contexte SSR et conserver sa réconciliation dynamique par snapshot.
- [x] Auditer la chaîne projection Remote → commande → claim Master → service Global → exécution/readiness/routage pour lancement neuf, reprise ouverte et reprise recréée.
- [x] Projeter `transition_type`, `execution_id` attendu et `paper_lobby_required` via le resolver Global partagé: sas conservé pour lancement neuf et recréation avec injection; commande directe pour une exécution officielle ouverte et `running`.
- [x] Reconstituer la recette KO dans les logs: commande `382`, Hub `283`, session `27667`, relance suspendue, ancien contexte `hubexec-d3c5c3a6b661d17ca90105884e6ed4ee` réutilisé, readiness confirmée puis routing écarté par le garde anti-rebond du retour historique.
- [x] Corriger la surcorrection focus et présence: une exécution officielle ouverte, non démo et `running` est réutilisable sans focus; le TTL court de présence reste un garde de routage tardif, pas un signal de recréation.
- [x] Auditer les commandes `384`/`386`: `hubexec-388d…` restait ouvert et sa présence exacte était encore fraîche après le clear focus; la recréation `hubexec-55b1…` et le second sas provenaient donc du critère de focus trop strict maintenant retiré.
- [x] Rendre `runtimeTransitionPending` prioritaire sur la projection d'action des snapshots intermédiaires et conserver l'intention acceptée jusqu'au routing ou à un terminal d'erreur.
- [x] Afficher `Accès à la partie…` indépendamment de `master_present` pendant la transition, et `Retour à la soirée…` dès le SSR jusqu'au premier `control_poll` frais même si la présence Master initiale vaut déjà true.
- [x] Préserver le gate Master frais: claim avant touch de présence, ancienne commande non ressuscitée, reset local des statuts terminaux et nouveau clic disponible.
- [x] Préserver l'anti-rebond: seule la paire `execution_id + routing_generation` quittée est bloquée; toute nouvelle intention validée par Master/Global publie une génération distincte avant routage.
- [x] Préserver intégralement Hub Play et `app_hub_view_helpers.php`; aucune mutation supplémentaire de présentation, focus ou runtime.
- [x] Étendre les tests Remote pour le clic avant snapshot, reprise ouverte sans focus ni sas, anti-rebond avant clic, commande/intention/exécution/URL discordantes, recréation avec sas/readiness, numérique, terminal et démo.
- [x] Couvrir les snapshots intermédiaires réalistes sur lancement papier, reprise ouverte et relance recréée: intention/libellé stable, un seul sas, voile continu et navigation canonique finale.
- [ ] Recette navigateur dev: mesurer T0 clic → claim → T3 résultat terminal → T4 `location.replace` sur reprise ouverte; contrôler lancement neuf papier, reprise recréée avec sas/readiness, remplacement Master entre création et claim, puis clic avant le premier snapshot.

## IMPLÉMENTÉ/VALIDÉ 2026-09-04 - Hub Play: fondation, session contextuelle et photo identité
- [x] Auditer la route `/hub/{token}/play`, son entrypoint Games, le view-model/renderer, l'inscription pseudo, l'auth Cotton, l'identité locale, le polling, le header et les tests avant patch.
- [x] Consulter START/SITEMAP/README/DOCS_MANIFEST/HANDOFF et le journal AI Studio raw; aucune entrée ciblée Games/Hub Play récente ne requiert de rechargement serveur.
- [x] Transformer le visuel Hub en hero événementiel allégé portant le titre; afficher `Bienvenue`; neutraliser le `max-height: 170px` hérité et préserver l'image entière avec `contain` dans un wrapper piloté par son ratio intrinsèque. Le fallback `600×240` donne `5/2`; un plafond `420px`/`52svh` borne les formats extrêmes et le canvas branding absorbe le résidu sans bande noire.
- [x] Sortir les métadonnées sous le visuel; séparer date/heure de la ligne `parties · joueurs`, interdire les coupures arbitraires et conserver cette composition après refresh branding. Couvrir `1|3|10 parties` et `1|n joueurs`.
- [x] Supprimer la barre intermédiaire joueurs/statut et toutes ses dépendances `statePill`; déplacer le compteur joueurs dans les métadonnées sans supprimer `active_count`, ses mises à jour ou son singulier/pluriel.
- [x] Réunir l'entrée dans une seule surface: titre générique `Rejoins-nous`, pseudo et CTA universel `Participer` prioritaires; `Déjà un compte Cotton ?` et `Se connecter` secondaires.
- [x] Préserver les URLs signin/signup existantes, `register_guest`, les règles d'unicité, la valeur saisie, le focus, les cookies/localStorage, l'état déjà inscrit et les polls existants.
- [x] Masquer visuellement le label Pseudo redondant tout en conservant son association accessible; garder `aria-describedby`/`role=alert`, le message pseudo indisponible et les focus/tactile/reduced-motion.
- [x] Aérer légèrement la surface d'entrée entre sous-texte, champ et CTA sans allonger excessivement la carte.
- [x] Conserver un descriptif explicite du compte Cotton mais le rendre tertiaire par sa taille, sa graisse, sa couleur, son interligne et ses espacements; conserver le titre structurant, le CTA secondaire et le signup tertiaire.
- [x] Rendre le CTA principal indépendant du contexte avec `Participer`; interdire dans les guards DOM les variantes entrée `Rejoins|Rejoindre la soirée|l’événement`, sans changer le submit ni `register_guest`.
- [x] Aligner le layout structurant sur `< 992px` / `>= 992px` (`991.98px` / `992px` en CSS); `360 × 740` reste un viewport de recette et non un breakpoint principal.
- [x] Réutiliser dans l'état joueur inscrit la projection `presentation` déjà jointe au poll `active_launched_session`, elle-même issue du resolver Global canonique de `presentation_session_id`; ne créer ni endpoint, ni selector, ni write Play.
- [x] Remplacer le message générique de préparation par une carte principale en lecture seule: statut joueur, jeu, thématique et visuel de session existant; exclure tout horaire individuel, réglage, contrôle organisateur et CTA de lancement.
- [x] Faire suivre à la carte le passage session A → session B au poll historique de 3,5 s, conserver un fallback propre sans focus et garder la reprise manuelle uniquement dans son état métier existant.
- [x] Alléger l'identité en introduction de la carte et conserver sans refonte les lots, résultats, classement, sortie et états post-session existants.
- [x] Couvrir projection A/B/sans focus, absence d'heure et d'écriture de présentation, DOM responsive et non-régression Remote.
- [x] Résoudre le résultat personnel par `session_id` présenté en réutilisant mapping et contexte résultat existants, sans assimiler le focus au dernier résultat chronologique.
- [x] Transformer la même carte focus en contexte `Partie terminée`: copie résultat canonique si disponible, attente si consolidation en cours, fallback sans résultat si le joueur n'a pas participé; ne jamais reprendre le résultat d'une autre session.
- [x] Supprimer la carte autonome `Dernier résultat` et conserver jeu, thématique, visuel et statut dans l'unique carte pilotée par Master.
- [x] Sortir entièrement l'UI photo du résultat et du module `Classement général`; rattacher discrètement Ajouter/Modifier à l'identité `Tu participes avec`.
- [x] Faire du rang 1–3 dans `aggregate_context.aggregate_ranking` l'unique preuve serveur d'éligibilité; interdire le fallback leaderboard Games, le rang navigateur et l'ancien podium de session comme preuve.
- [x] Autoriser un Top 3 Hub sans podium de session; refuser un ancien podium de session désormais rang 4+, même avec requête forgée.
- [x] Conserver une session mappée choisie côté serveur uniquement comme contexte historique de consentement/traçabilité, sans lui donner d'autorité sur le rang.
- [x] Conserver `games_hubs_players.hub_photo_*`, validations fichier/MIME/taille/extension/sanitation, consentement, traçabilité, révision Hub et enrichissement Global des podiums Hub/session; aucune migration ni photo par session.
- [x] Préserver sans suppression automatique une photo existante après sortie du Top 3, tout en masquant/refusant l'action tant que le joueur n'est plus éligible.
- [x] Préserver sans recalcul le classement `aggregate_context.aggregate_ranking`, les Lots, la sortie, la reprise et l'auto-routing.
- [x] Valider le lint PHP, les contrats Hub PHP/JS, les guards CSS/DOM des micro-ajustements et `git diff --check`.
- [ ] Effectuer une capture navigateur réelle `360 × 740`, `768 × 1024` et `992px` dans un environnement disposant d'un moteur headless; valider notamment prête/running/terminée avec et sans résultat, A terminée → B, identité photo aux rangs 1/2/3 puis 4+, papier/numérique et absence de focus. L'installation temporaire Playwright est restée bloquée et a été interrompue sans modification du dépôt.

## AUDITÉ 2026-09-01 - Baseline globale des tests
- [x] Exécuter les 20 scripts first-party autonomes: 17 passent, 3 échouent, 0 skip; syntaxe PHP/Node 20/20.
- [x] Confirmer sur trois passages que les trois échecs sont déterministes et non flaky.
- [x] Réaligner `hub_remote_polling_test.mjs` sur le sas `access_transition` introduit par `16e79bef`, avec libération terminale et routage canonique stricts.
- [x] Réaligner `hub_session_settings_test.php` sur `!openDemoReentry` (`d0a4708b`) et `hub_session_settings_dom_test.mjs` sur le layout utility statique (`652d03f7`); corriger les lectures de source de test masquées par le premier arrêt.
- [x] Classer ces trois rouges comme tests obsolètes; aucune régression fonctionnelle Games identifiée pendant l'audit.
- [x] Baseline après réalignement: 20/20 tests et 20/20 vérifications de syntaxe PHP/Node.

## CORRIGÉ/VALIDÉ 2026-09-01 - Actions et hints des cartes Hub Master
- [x] Déplacer les hints papier du contenu visuel vers le pied de la carte sélectionnée, juste au-dessus du CTA lorsqu'il existe.
- [x] Centrer le contenu du footer dans les deux axes et préserver le message d'indisponibilité lorsqu'aucune action ne peut être affichée.
- [x] Afficher `Partie du JJ/MM/AAAA` pour une session à venir d'un client actif sans CTA, à partir de l'état temporel canonique.
- [x] Conserver les conditions métier existantes, les libellés et les CTA du carrousel.
- [x] Corriger la régression du resolver introduite par `247b1f98437cc775455842e6d5a502498484b64a` : transmettre le mode papier et faire primer `paper_session => none` sur les branches officielles Master `Lancer|Reprendre|Relancer`.
- [x] Conserver le prospect papier compatible en `Faire la démo`, le prospect incompatible sans action, et les actions officielles numériques.
- [x] Afficher `Démo avec réponses sur smartphone` juste au-dessus de `Faire la démo` uniquement pour le prospect papier compatible; l'omettre pour smartphone, offre active et démo indisponible.
- [x] Couvrir simultanément le hint `Lancement depuis la télécommande` et l'absence de CTA Master dans le HTML rendu; conserver le refus serveur direct `PAPER_LAUNCH_REMOTE_ONLY` et le lancement papier Remote.

## CORRIGÉ/VALIDÉ 2026-09-01 - QR joueur des démos historiques Hub
- [x] Propager vers l'URL Play du QR Master le contexte branding-only déjà validé (`hub_demo_source_session`, `hub_demo_hub`) d'une démo historique ouverte depuis Dashboard/Hub.
- [x] Conserver les QR sans paramètres hors démo et laisser Global valider la démo, la source et le Hub avant fallback branding.
- [x] Préserver runtime, exécution, focus, membership et QR Remote.

## CORRIGÉ/VALIDÉ 2026-09-01 - Transition Remote Hub vers partie
- [x] Conserver l'overlay transitoire de la Remote Hub pendant le routage vers une Remote de session et afficher `Accès à la partie.`.
- [x] Ne pas confondre ce sas court avec la déconnexion réelle du Master; le retour session -> Hub conserve `Retour à la soirée…`.
- [x] Préserver la file de commandes, les routes Remote, les verrous et les états offline existants.
- [x] Déduire aussi le sas de l'état serveur (`pending_command_type` ou `client_routing`) avant le premier rendu offline, pour supprimer tout flash de déconnexion.
- [x] Couvrir le trou entre commande `completed` et première présence du Master de session avec un signal Global borné à 15 secondes, consommé uniquement par l'overlay de transition.
- [x] Couvrir aussi le lancement direct depuis Hub Master, qui ne crée pas de commande Remote : son activation de focus fraîche est le signal de transition canonique.
- [x] Publier immédiatement un marqueur de transition dédié depuis Hub Master avant chaque redirection officielle ou démo; la Remote le consomme au poll suivant sans attendre l'absence de présence.
- [x] Conserver le marqueur de retour historique et son `execution_id` pendant toute la vie de la page Hub Remote: une présence Master encore fraîche ne peut plus rerouter vers l'exécution terminale quittée; seule une nouvelle exécution distincte reste routable.
- [x] Appliquer ce même garde au signal `Accès à la partie`: l'`access_transition` et le `client_routing` encore frais de l'exécution quittée ne doivent pas figer `runtimeTransitionPending` au retour.
- [x] Sur quit d'une démo annexe Hub, ignorer le clear officiel dans `endSession`, puis compléter uniquement l'exécution démo au terminal serveur sans modifier focus, présentation, membership, statuts, classement ni statistiques Hub.
- [x] Couvrir le contrat par un test de garde anti-rebond, la matrice Remote commune et un test terminal serveur Quiz/Blind Test/Bingo préservant l'état officiel.
- [x] Corriger la fin naturelle démo: compléter l'exécution depuis le contexte source/runtime canonique, conserver l'exécution non routable et ne toucher à aucun état officiel.
- [x] Diffuser le résultat historique Quiz/Blind Test avant le signal collectif; appliquer un délai commun de 2,5 s avec `Retour à la soirée…`, en laissant la fenêtre finale Bingo de 8 s prioritaire.
- [x] Refuser d'armer le retour démo sans `runtime_mode=demo` et `execution_id` transportés par le lancement Hub; couvrir explicitement la démo Dashboard Pro mobile rattachée à une source Hub, qui conserve sa fin historique.
- [x] Armer le retour Player vers Hub Play depuis le couple source/exécution explicite de l'URL démo Hub, sans déduire de membership runtime ni injecter le roster Hub.
- [ ] Recette navigateur: même session source, comparer démo Dashboard mobile sans retour Hub et démo lancée Hub avec résultat puis retours Master/Remote; vérifier Bingo et l'absence de rebond après plusieurs polls.

## CORRIGÉ/VALIDÉ 2026-09-01 - Hub prospect : Quiz papier incompatible
- [x] Masquer l'action `Faire la démo` du Master quand le guard canonique refuse la conversion numérique du Quiz papier.
- [x] Afficher `Démo non disponible pour cette partie.` sur Master et Remote, et appliquer la même garde aux cartes Remote.
- [x] Préserver le lancement des démos papier compatibles, les sessions officielles et la voie Dashboard mobile.
- [x] Retirer le hint Master technique sur la conversion numérique, devenu inutile.

## CORRIGÉ/VALIDÉ 2026-09-01 - Remote prospect : test global masqué
- [x] Masquer `Lancer un test` sur la Remote lorsqu'une décision commerciale canonique indique le mode démo prospect.
- [x] Conserver `Faire la démo` sur les cartes Programme, seule voie prospect de lancement, et refuser côté serveur une commande globale forgée.
- [x] Faire primer le statut prospect sur `hub_is_focus_active`, `hub_runtime_status` et l'absence d'exécution démo ouverte: après quit ou fin naturelle, aucune branche officielle `Lancer|Reprendre|Relancer` ne peut écraser l'action démo.
- [x] Centraliser la décision Master dans `games_hub_master_card_action_resolve(...)` et aligner le wording Remote sur `Faire la démo`.
- [x] Empêcher les deux appelants Master/Remote de changer `presentation_mode` après un lancement `runtime_mode=demo`; Global conserve aussi focus et sélection de présentation sans mutation.
- [x] Couvrir état initial, quit, fin naturelle, exécutions A/B, démo incompatible, vraie reprise client actif et isolation focus/présentation par `hub_prospect_card_action_test.php`; conserver la garde Global forçant tout prospect en `runtime_mode=demo`.
- [ ] Recette navigateur: prospect `Faire la démo` → quit/fin → retour → `Faire la démo` → nouvelle exécution; répéter sur une démo incompatible et comparer à un client actif réellement suspendu.
- [x] Préserver l'éligibilité active-offre, le runtime, les sessions officielles, le Hub Master et les memberships.
- [x] Projeter aussi le contexte commercial dans le payload SSR Remote et le revalider à chaque snapshot, afin que le CTA ne puisse pas réapparaître.
- [x] Rendre le masquage `[hidden]` prioritaire sur le `display:inline-flex` du CTA, supprimer la notice démo Remote redondante et laisser le Master porter cet état produit.
- [x] Court-circuiter la modale de préparation joueurs papier pour toute démo prospect issue du Programme Remote; elle reste réservée au lancement officiel.

## CORRIGÉ/VALIDÉ 2026-09-01 - Notice Mode démo du Hub Master sans commerce
- [x] Retirer le lien e-commerce de la notice Master et conserver le message fonctionnel validé sur la limite de deux joueurs.
- [x] Laisser le CTA et la décision commerciale au Dashboard Pro; ne modifier ni Remote, ni runtime, ni garde de capacité.
- [x] Couvrir l’absence de lien commercial et le wording par `hub_demo_runtime_surfaces_test.php`.

## IMPLÉMENTÉ/VALIDÉ 2026-08-31 - Runtime démo Hub par intention et prévol
- [x] Router Master et Remote vers le runtime déclaré par l'exécution tout en conservant la source officielle comme contexte Hub, y compris après refresh/takeover.
- [x] Fiabiliser `resetdemo`: état et joueurs Blind Test/Quiz réellement remis à zéro, erreurs propagées, ensure Quiz sérialisé, postconditions Bingo vérifiées.
- [x] Projeter la démo papier en expérience numérique et expliquer que la session officielle reste papier.
- [x] Conserver les QR historiques: QR Hub/Hub Play avant fenêtre et QR propre au runtime démo. Le participant automatique compte dans la capacité démo et un second joueur réel peut rejoindre directement le runtime sans écriture Hub.
- [x] Retirer la reprise Hub d'une démo ouverte: toute nouvelle intention crée un runtime/exécution neufs; le masque `hub_launch` reste libéré avant la modale historique `Continuer / Recommencer`, conservée pour les URLs démo hors Hub.
- [x] Ne pas afficher `hub-demo-runtime-notice` dans le Master historique : le statut commercial Mode démo est porté par les interfaces Hub uniquement.
- [x] Réserver `hub-preflight-dialog` au diagnostic compact et placer son CTA distinct `Lancer une démo` dans les actions Master. Avant le premier démarrage officiel, il crée une démo autonome du premier jeu officiel, valide l’URL `/master/{id_securite}` puis passe par la même primitive `window.location.href` que `Tester le jeu` des cartes Programme; son binding délégué depuis `document` est indépendant du cycle de vie Preflight. Le contrat JSON partagé normalise `ok=true|1|"1"`, nécessaire car le producteur démo retourne `1`. L’action est une icône compacte avec spinner local, sans bandeau d’état persistant. Les traces navigateur `[hub_demo]` bornées couvrent binding, clic, requête, réponse et navigation. Il disparaît dès qu’une officielle a démarré, sans compter les démos isolées.
- [x] Transmettre les identifiants d'exécution Hub déjà présents dans l'URL vers l'hydrateur branding Canvas, sans exposer de nouvel identifiant ni modifier les parcours hors Hub.
- [x] Propager ce contexte dans l’iframe Play démo et dans l’URL/QR Remote produite par Master; Remote accepte aussi l’identifiant `hub_remote_execution`, pour les démos Hub prévol comme commerciales.
- [x] Réserver strictement `Faire la démo` aux cartes prospect, même lorsqu’une démo annexe est ouverte; pour offre active, ajouter le CTA global compact Master/Remote `Lancer un test`. Son éligibilité du snapshot est projetée au SSR initial puis réconciliée au refresh; il crée la commande Master `launch_hub_demo`, dont le poll Master suit la redirection Organizer canonique.
- [x] Faire converger `client_routing` sur l’exécution démo isolée via la session source, sans focus, présentation ou membership; Master et Remote reconstruisent ainsi le même runtime/execution.
- [x] Empêcher le rebond Remote au retour terminal : `hub_remote_returning` conserve et bloque seulement l’`execution_id` que la page vient de quitter, y compris pendant la lease Master encore fraîche, sans bloquer une nouvelle démo.
- [x] En mode commercial prospect, placer la notice sous le QR Master, le laisser visible mais désactivé avec la pastille « Non disponible en démo », appliquer les couleurs secondaires du branding et informer sur la limite de deux joueurs sans lien e-commerce.
- [x] Compléter la fin naturelle depuis le runtime démo vers l'exécution de la source, sans modifier la source ni reconstruire stats/résultats.
- [x] Couvrir surfaces, routage, source/runtime, QR, capacité, absence d'injection Hub, réentrée, reset et non-régression officielle dans `hub_demo_runtime_surfaces_test.php`, `hub_demo_qr_reentry_contract_test.php`, `hub_demo_reentry_runtime_test.mjs` et les contrats Hub existants.
- [ ] Recette navigateurs/DB: Master + Remote, reload/takeover, trois jeux papier, auto-participant démo et accès direct Play pendant une exécution démo.

## CORRIGÉ/VALIDÉ 2026-08-31 - Injection Hub papier à froid
- [x] Ajouter une abstraction interne `canvas_historical_session_ensure_for_game(...)`, distincte de `build_preload_for_game(...)`, avant le premier `player_register` du lancement Hub papier.
- [x] Quiz types `1|5`: assurer puis relire `cotton_quiz_sessions`; Blind Test type `4`: assurer puis relire `blindtest_sessions`.
- [x] Bingo type `6`: validation légère sans création runtime, preload, grille ni carton; type archive `2` laissé hors extension implicite.
- [x] Conserver le contrat public `player_register`, l'idempotence et les scores/gains existants.
- [x] Couvrir création à froid, refetch, second passage, échec explicite et absence d'écriture Bingo par `hub_paper_historical_session_ensure_test.php`.
- [ ] Recette DB/navigateurs post-déploiement: Quiz `5`, Blind Test `4`, Bingo `6` et Quiz legacy `1`, Master/Remote historiques non préchauffés, puis second lancement.

## CORRIGÉ/VALIDÉ 2026-08-31 - Master individuel historique pour Résultats mobile Pro
- [x] Relire START raw `main`, SITEMAP/DOCS_MANIFEST `develop`, README Games et historique Git; journal AI Studio raw retenté, inaccessible en `HTTP 403 Forbidden`.
- [x] Prouver la redirection: `games/web/modules/app_orga_ajax.php` redirige seulement le GET d'une session Hub terminée naturellement vers `/hub/{hub_token}/master`, avant le boot historique.
- [x] Ajouter l'intention explicite `master_view=individual`, honorée seulement si `app_session_edit_state_get(...).is_terminated`; GET normal, pending/running, Hub Master/Remote/Play, focus, commandes, runtime et persistance restent inchangés.
- [x] Laisser le boot historique poursuivre pour ce seul cas terminal, sans mutation Hub et avec le log borné `hub_individual_terminal_master_view`.
- [x] Ajouter `hub_individual_terminal_master_test.php`: routing normal, borne terminale, absence de mutation et bases Master Blind Test/Cotton Quiz/Bingo Musical.
- [ ] Recette navigateur authentifiée: session Hub terminée, URL normale puis URL `master_view=individual`, vérifier le rendu des résultats et l'absence de changement Hub.

## CORRIGÉ/VALIDÉ 2026-08-27 - Quick-add Master/Remote reste live-only
- [x] Confirmer que Master et Remote continuent d'appeler le service Global générique, dont la politique par défaut reste `live`.
- [x] Couvrir sur les handlers réels la matrice `before` refusé, `open` autorisé, `expired` refusé.
- [x] Vérifier côté Master que la carte `Ajouter une partie` reste absente avant fenêtre et après cutoff, mais présente en `open`.
- [x] Conserver focus, présentation, polling, runtime, cadence et endpoints métier inchangés; charger le vrai handler Remote depuis un sous-processus de test sans seam ni modification du dispatch de production.
- [x] Réaligner le test HubTransition sur le marqueur canonique `hub_remote_returning=1`, en vérifiant l'URL exacte, la conservation des paramètres existants et l'unicité de la navigation.

## CORRIGÉ/VALIDÉ 2026-08-27 - Stabilisation fin Hub Play et podium Hub Master
- [x] Relire START raw main, SITEMAP/DOCS_MANIFEST raw develop et carte Games; journal AI Studio inaccessible en HTTP 403, puis poursuivre sur dérogation explicite de l'utilisateur.
- [x] Prouver Hub Play: une `presentation_session_id` conservée sur la dernière session terminée déclenchait `preparing` avant le calcul de fin canonique, même avec toutes les sessions métier terminées et la fenêtre quick-add encore ouverte.
- [x] Valider la présentation Play contre la session canonique correspondante et exiger que toutes les sessions soient réellement terminées avant l'état final; une session prête ou suspendue empêche donc la fin visuelle, et une nouvelle session prête restaure l'attente au poll suivant.
- [x] Prouver Hub Master: la fermeture postait `hub_idle`, puis `selectCard()` repostait la session sélectionnée et remettait le mode à `session`; l'auto-éligibilité rejouée au refresh rouvrait alors le podium.
- [x] Rendre la sélection visuelle post-fermeture non persistante et mémoriser en page la clé stable de l'événement d'auto-podium acquitté; un rerender identique reste fermé, une nouvelle vraie fin change la clé et réarme l'ouverture.
- [x] Préserver fin naturelle, carrousel, carte `AJOUTER UNE PARTIE`, quick-add, synchronisation réactivable, focus/runtime/routage et cadences de polling.
- [x] Couvrir par `hub_session_settings_test.php`, `hub_session_settings_dom_test.mjs`, `hub_remote_contract_test.php`, `hub_remote_polling_test.mjs` et `hub_natural_end_stats_rebuild_test.php`.
- [ ] Recette navigateur: dernière fin -> podium auto -> fermeture -> refresh/poll -> navigation jusqu'au quick-add -> création C -> nouvelle fin C et réouverture auto.

## CORRIGÉ/VALIDÉ 2026-08-27 - Bingo papier: correction sans joueur puis gagnant affecté
- [x] Prouver le cas Hub Remote Bingo papier: avec `phases_liste=0,1,2,5` et `phase_courante=1`, la correction sans joueur de phase 1 filtrait le sentinelle `0` côté WS puis réécrivait l'index `1` au lieu de `2`; la correction avec joueur de phase 2 rencontrait ensuite `PHASE_MISMATCH` côté PHP.
- [x] Confirmer la source du HTTP 500: `bingo_api_phase_winner` retournait l'état métier `PHASE_MISMATCH`, puis `games_ajax.php` conservait son statut par défaut 500; aucun fatal PHP ni accès tableau invalide n'était requis.
- [x] Aligner `advancePhaseWithoutWinner` sur le contrat historique unique: `phases_liste` complète avec sentinelle `0`, et `phase_courante` index 0-based dans cette liste. Le chemin numérique historique n'est pas modifié.
- [x] Ajouter le diagnostic `BINGO_MANUAL_PHASE_ADVANCE` (`lines`, `grid_number`, phase/index avant-après, `phases_liste`) et `PHASE_WINNER_REJECTED` côté PHP; classer mismatch/terminal/conflit `phase_winner` en HTTP 409.
- [x] Corriger le seul fallback `prompt()`: wording humain borné, conversion unique 1-based -> 0-based, rejet vide/`0`/négatif/hors plage/doublon avant toute requête; aligner le sélecteur normal sur 3 lignes pour le format court `5`.
- [x] Couvrir première/dernière/autre ligne, phases alternatives, correction sans joueur puis avec joueur, absence de double persistance, index sans décalage, terminal inchangé et absence de HTTP 500 par `bingo_phase_progress.test.js`, `bingo_paper_correction_test.mjs` et `bingo_phase_winner_contract_test.php`.
- [ ] Recette navigateur/dev avec vraie DB: confirmer `REMOTE_PAPER_WRITE_RX phase=2`, `PHASE_WINNER_PERSISTED`, `REMOTE_PAPER_WRITE_PERSISTED` et HTTP 200 sur le scénario exact.

## PATCH 2026-08-26 - Hub Remote retour soirée transitoire
- [x] Relire la discipline documentaire: START raw main, SITEMAP.txt develop, DOCS_MANIFEST et README Games. Journal AI Studio raw inaccessible via outil web puis `curl` (`HTTP 403 Forbidden`); fallback documentaire/local appliqué.
- [x] Auditer `hubRemoteReturn`, `HubTransition` rôle `remote`, allowlist `/hub/{token}/remote`, terminaux `SESSION_ENDED` / `HUB_SESSION_FINISHED`, overlay Hub Remote, `masterEverPresent`, cadences `control_poll` et états replaced/offline/suspended.
- [x] Ajouter un marqueur explicite et borné `hub_remote_returning=1` seulement sur les retours Remote historique -> Hub Remote via `HubTransition` et le reload terminal direct `remote_canvas.php`, sans modifier l'URL allowlistée ni les gates serveur.
- [x] Afficher `Retour à la soirée…` dans le voile bloquant existant uniquement si le marqueur est présent, `master_present=false` au bootstrap et `hub_sync_suspended=false`.
- [x] Sortir immédiatement du sas sur `master_present=true`; expirer le sas sur offline ou après 10 s pour laisser les wordings canoniques `Télécommande prête` / `Écran de diffusion déconnecté` reprendre selon `masterEverPresent`.
- [x] Corriger la course observée en recette Bingo: bloquer les `control_poll` issus de `pageshow`/`online`/timer tant que `instance_takeover` n'a pas confirmé la nouvelle page Remote, afin qu'un `409` pré-takeover ne rende pas l'overlay `Cette interface est ouverte ailleurs`.
- [x] Préserver `master_present`, TTL, DB, focus Hub, `active_session_id`, `presentation_session_id`, `execution_id`, readiness, `client_routing`, mutations Remote et priorité de l'overlay instance remplacée.
- [x] Couvrir par `hub_remote_contract_test.php` et `hub_remote_polling_test.mjs`.
- [ ] Recette navigateur réelle: fin naturelle et quit volontaire Remote historique -> Hub Remote, Master revenant vite puis Master absent durable.

## PATCH 2026-08-26 - Hub Master prédiagnostic borné à la fenêtre de lancement
- [x] Relire la discipline documentaire: START raw main, SITEMAP.txt develop, DOCS_MANIFEST et carte Games. Journal AI Studio raw inaccessible via outil web puis `curl` (`HTTP 403 Forbidden`); fallback audit local déjà réalisé et fichiers locaux propres avant patch.
- [x] Exposer le booléen serveur canonique `data-hub-launch-window-open="1|0"` depuis `$hub_temporal_state['launch_window_open']`.
- [x] Garder le diagnostic automatique strictement inchangé quand `launch_window_open=true`: boot, timers `900/1400/4200/9000`, listeners réseau/pageshow/connection, checks, seuils et UX.
- [x] En état `before`, conserver le diagnostic manuel mais démarrer l'icône en état neutre, sans timer initial ni listener automatique.
- [x] En état `before`, masquer le bloc résultat de la modale tant qu'aucun diagnostic n'a été exécuté dans la page et afficher `Lancer le diagnostic`; restaurer le résultat historique et `Relancer le diagnostic` après lancement manuel.
- [x] En état `expired`, ne plus rendre l'icône manuelle et ne câbler aucun prédiagnostic automatique.
- [x] Vérifier que l'éligibilité ne dépend pas de `data-hub-sync-suspended`, des sessions ou de leurs statuts; le cas fenêtre ouverte + sessions terminées conserve l'auto-diagnostic.
- [x] Couvrir par `hub_session_settings_test.php` et `hub_session_settings_dom_test.mjs`.
- [ ] Recette navigateur: Master before/open/expired, avec clic manuel before et Hub ouvert dont les sessions courantes sont terminées.

## PATCH 2026-08-26 - Hub QR dev-only
- [x] Auditer les QR concernés: QR joueurs Hub Master (`data-hub-qr-container`) et générateur Canvas commun `renderMainQR` / `renderPauseQR` / `renderPilotQR`.
- [x] Réutiliser le helper environnement central `games_hub_master_reload_profile_dev_enabled()` via `games_hub_qr_links_enabled()`.
- [x] Retirer les heuristiques hostname du helper et du générateur QR commun; le dev-only repose sur `$conf['server'] === 'dev'` ou `APP_ENV=dev` côté serveur, et `AppConfig.env === 'dev'` côté Canvas.
- [x] Rendre le QR Hub joueurs cliquable en dev avec `target="_blank"` / `rel="noopener noreferrer"` et strictement visuel en prod.
- [x] Couvrir par `hub_remote_contract_test.php`.
- [ ] Recette navigateur dev/prod: scanner/cliquer le QR joueurs Hub Master et vérifier l'absence de lien en prod.

## PATCH 2026-08-26 - Hub Remote sas papier: annulation bornée d'ajout joueur
- [x] Auditer le statut joueur avant patch: l'injection papier lit `games_hubs_players.status='active'`; l'état d'exclusion existant est `left`, pas `inactive`; `last_seen_at` ne gate pas l'injection.
- [x] Borner `paper_lobby_player_remove` côté Hub Remote par un token d'undo éphémère en session PHP, lié Hub + session papier + joueur + ouverture du sas et consommé avant `app_games_hub_player_unregister(...)`.
- [x] Rendre les joueurs présents au chargement strictement read-only dans le sas: aucun bouton de suppression, aucun droit d'undo et aucune mutation Hub/session possible via l'UI normale.
- [x] Afficher `Annuler l’ajout` uniquement pour une création/réinscription Hub réellement provoquée dans l'ouverture courante du sas, avec état JS en mémoire vidé à l'ouverture/fermeture.
- [x] Corriger le wording vide: une seule phrase exacte `Aucun joueur inscrit pour le moment.` et ajout de l'intro demandée.
- [x] Ajouter les tests lisibles: lancement papier possible avec zéro joueur, joueurs initiaux read-only, undo tokenisé avant lancement, endpoint Hub-only et absence de mapping/runtime.
- [ ] Recette navigateur: joueur inscrit visible après fermeture smartphone, ajout à la volée annulable dans la même ouverture, fermeture/reload puis joueur read-only.

## PATCH 2026-08-26 - Hub Remote sas papier: alignement historique, Master hint, gate Pro
- [x] Relire le préambule documentaire obligatoire: START raw main, SITEMAP.txt develop, DOCS_MANIFEST, README/TASKS Games, CHANGELOG et HANDOFF. Journal AI Studio raw inaccessible via outil web puis `curl` (`HTTP 403 Forbidden`); fallback documentaire/local appliqué.
- [x] Revalider le contrat papier: `flag_controle_numerique=0`, injection Hub -> runtime papier uniquement au vrai lancement via `app_games_hub_session_inject_active_players(...)`.
- [x] Ajouter un helper Hub-only `app_games_hub_player_ensure(...)` qui crée/réactive `games_hubs_players` sans appeler `player_register` ni `app_games_hub_session_mapping_upsert(...)`.
- [x] Ajouter les endpoints Remote bornés `paper_lobby_players`, `paper_lobby_lookup`, `paper_lobby_player_add`, protégés par token Remote, CSRF pour mutation et instance Remote canonique.
- [x] Intercaler le sas avant `launch_session` côté Hub Remote pour les seules sessions papier; le numérique conserve le POST direct existant.
- [x] Remplacer le bouton `Rechercher` du sas par le contrat historique: seuil 3 caractères, debounce 180 ms, recherche automatique, protection des réponses obsolètes, sélection existante ou création locale Hub-only si aucun résultat.
- [x] Masquer le lancement papier neuf côté Hub Master et afficher `Lancement depuis la télécommande` comme hint secondaire hors conteneur d'action; garder le garde serveur `PAPER_LAUNCH_REMOTE_ONLY`.
- [x] Ajouter le contrôle Pro avant `Diffuser`: s'il existe une session papier et que la Remote canonique est absente/stale, afficher la modale `Ouvre d’abord la télécommande` avec CTA vers l'URL Remote existante.
- [x] Couvrir par `hub_remote_polling_test.mjs`, `hub_remote_contract_test.php`, `hub_session_settings_test.php`, `hub_remote_control_contract_test.php`, `hub_instance_exclusivity_contract_test.php` et `ec_start_sessions_day_dashboard_test.php`.
- [ ] Recette navigateur réelle: Remote papier avec aucun joueur, ajout depuis recherche et saisie libre, annulation sans runtime, validation puis routage Remote historique.

## PATCH 2026-08-26 - Hub Remote UI allégée
- [x] Relire le préambule documentaire obligatoire: START raw main, SITEMAP.txt develop, DOCS_MANIFEST, README/TASKS Games, CHANGELOG et HANDOFF. Journal AI Studio raw inaccessible via outil web puis `curl` (`HTTP 403 Forbidden`); fallback documentaire/local appliqué.
- [x] Auditer le rendu Remote: les panneaux `Lots` et `Top joueurs` étaient rendus dans `games_hub_remote_render_page(...)`, puis reremplis côté JS par `renderSimpleList(...)` depuis `payload.prizes` / `payload.aggregate`.
- [x] Confirmer que la suppression peut rester présentationnelle: `games_hub_remote_business_snapshot(...)` continue d'exposer `prizes` et `aggregate`; seules les cibles DOM et leur rerender Remote disparaissent.
- [x] Ajuster les messages de verrou Master avec le contexte existant `hub_wording.noun_with_article`, sans afficher simultanément soirée et événement.
- [x] Remplacer le sous-libellé quick-add Remote `Action` par `Choisir un nouveau jeu`.
- [x] Couvrir par `hub_remote_polling_test.mjs` et `hub_remote_contract_test.php`: Programme/compteur/statut conservés, panneaux retirés, wording soirée/événement, quick-add, transition runtime.
- [ ] Recette navigateur réelle: Hub Remote mobile avec Master absent puis perdu, quick-add disponible, lancement/reprise avec latence, vérifier rendu sans panneaux Lots/Top joueurs.

## PATCH 2026-08-26 - Hub Remote transition runtime jusqu'au routage
- [x] Relire le préambule documentaire obligatoire: START raw main, SITEMAP.txt develop, DOCS_MANIFEST, README/TASKS Games, CHANGELOG et HANDOFF. Journal AI Studio raw inaccessible via outil web puis `curl` (`HTTP 403 Forbidden`); fallback documentaire/local appliqué.
- [x] Reconstituer la machine d'état Remote: clic `Lancer`/`Reprendre` -> `launch_session` -> `pendingCommandId` -> `command_status` -> `completed` -> `control_poll.client_routing` -> `remote_url` -> `window.location.replace(...)`.
- [x] Prouver la cause UX: après `completed`, `pendingCommandId` était vidé avant routage et les rerenders pouvaient perdre le `data-loading` du bouton; le CTA redevenait normal alors que `client_routing` n'avait pas encore déclenché la navigation.
- [x] Clarifier l'état local avec `runtimeTransitionPending`, distinct de `commandInFlight`, `selectionInFlight` et `pendingCommandId`.
- [x] Garder le CTA runtime désactivé et en spinner de l'acceptation de commande jusqu'à navigation effective, erreur terminale, perte Master ou expiration réelle.
- [x] Retirer la dépendance de routage à `pendingCommandId`: si `client_routing.client_joinable=true`, `master_context_available=true` et `remote_url` est valide, la navigation reste déclenchée même en reload/ouverture tardive.
- [x] Couvrir par `hub_remote_polling_test.mjs`, `hub_remote_contract_test.php` et `global/web/tests/hub_remote_control_contract_test.php`.
- [ ] Recette navigateur réelle: lancer/reprendre depuis Hub Remote avec latence Master/Organizer, vérifier que le spinner reste visible jusqu'au changement de page et que les erreurs terminales le retirent.

## PATCH 2026-08-26 - Hub Remote remplacement cross-context
- [x] Relire le préambule documentaire obligatoire: START raw main, SITEMAP.txt develop, DOCS_MANIFEST, README/TASKS Games et HANDOFF. Journal AI Studio raw inaccessible via outil web puis `curl` (`HTTP 403 Forbidden`); fallback documentaire/local appliqué.
- [x] Reconstituer le contrat existant: takeover Remote explicite, UUID de page, polls stale refusés avec `instance_current=false` / `replaced=true`, overlay terminal sans tentative de reprise.
- [x] Prouver la cause cross-context: l'ouverture Remote B réécrivait `games_hubs_remote_access.session_token_hash`; Remote A, dans une autre session PHP, postait ensuite vers un endpoint AJAX sans `remoteToken`, ne résolvait plus le Hub et recevait `REMOTE_UNAVAILABLE` au lieu du payload stale.
- [x] Corriger la résolution AJAX: l'endpoint Remote inclut le `remoteToken` public et le bind `session_token_hash` ne s'effectue plus sur les requêtes AJAX, afin que deux contextes isolés convergent par le contrat serveur canonique.
- [x] Couvrir par `hub_remote_polling_test.mjs` le premier `control_poll` stale en HTTP non-2xx et par `hub_remote_contract_test.php` le contrat endpoint/bind.
- [ ] Recette navigateur réelle: Remote A normal, Remote B navigation privée ou device distinct, vérifier sur A l'overlay terminal et non la seule pastille `Déconnecté`.

## PATCH 2026-08-26 - Hub Remote CTA optimiste verrouillé
- [x] Relire le préambule documentaire obligatoire: START raw main, SITEMAP.txt develop, DOCS_MANIFEST, README/TASKS Games, HANDOFF et CHANGELOG. Journal AI Studio raw consulté via l'URL imposée mais inaccessible en lecture utile (`HTTP 500 Internal Server Error` via outil web); fallback documentaire/local appliqué.
- [x] Auditer la latence résiduelle: après le chantier précédent, `selectProgramCard()` marquait la carte au clic mais le CTA de la nouvelle carte n'entrait dans le DOM qu'à T4/T5, après réponse `select_session`, car les cartes hors focus ne rendent plus d'actions.
- [x] Ajouter la sélection visuelle optimiste: au clic, `latestProgramSessions` rerend immédiatement le Programme avec la carte demandée comme focus et les actions issues du cache serveur.
- [x] Ajouter le verrou local `pending_selection`: le CTA optimiste est visible mais désactivé, et `bindLaunchButtons()` ne peut pas poster `launch_session` avant confirmation canonique.
- [x] Gérer rollback/convergence: échec `select_session`, `master_present=false`, instance remplacée, réponse stale ou snapshot canonique concurrent restaurent/conservent le dernier `presentation_session_id` confirmé.
- [x] Couvrir par `hub_remote_polling_test.mjs` et `hub_remote_contract_test.php`: CTA avant résolution Promise, désactivation pendant sélection, aucun launch prématuré, succès sans `business_snapshot`, stale A->B, échec, Master loss et instance remplacée.
- [ ] Recette navigateur mobile: mesurer T0 clic -> T2 CTA DOM immédiat, puis T4/T5 confirmation; vérifier que le CTA ne lance rien avant confirmation.

## PATCH 2026-08-26 - Hub Remote CTA runtime immédiat après sélection
- [x] Relire le préambule documentaire obligatoire: START raw main, SITEMAP.txt develop, DOCS_MANIFEST, README/TASKS Games, HANDOFF et CHANGELOG. Journal AI Studio raw consulté via l'URL imposée mais inaccessible en lecture utile (`HTTP 500 Internal Server Error` via outil web); fallback documentaire/local appliqué.
- [x] Auditer le parcours réel: clic carte -> `select_session` Remote -> commande pending -> `control_poll` -> `business_snapshot` -> reflet Master; le premier point canonique exploitable devait devenir la réponse `select_session` enrichie.
- [x] Confirmer la cause du délai: le DOM initial ne rend plus d'actions sur les cartes hors focus; `selectProgramCard()` ne pouvait donc pas afficher le CTA d'une nouvelle carte avant reconstruction `business_snapshot`.
- [x] Corriger le handler `select_session`: créer la commande Master existante, écrire immédiatement `presentation_session_id` via `app_games_hub_presentation_session_set(...)`, puis retourner le focus committé et la projection métier de la session.
- [x] Corriger le front Remote: garder un cache des sessions projetées, appliquer seulement la dernière réponse `select_session` via `selectionRequestToken`, reconstruire le Programme local sans attendre un reflet Master et conserver le verrou `master_present`.
- [x] Couvrir par `hub_remote_contract_test.php` et `hub_remote_polling_test.mjs`: CTA immédiat `Lancer/Reprendre`, réponse stale ignorée, changement rapide A -> B côté UI, carte terminée sans CTA et sélection Master via snapshot conservée.
- [ ] Recette navigateur mobile: sélectionner successivement deux cartes prêtes/reprenables avec Master présent, vérifier apparition immédiate du CTA; répéter Master absent et pendant lancement pending.

## PATCH 2026-08-26 - Hub Remote verrou résiduel et Master hidden
- [x] Auditer le verrou front restant: après `master_present=false -> true`, `getLaunchDisabledReason()` peut revenir à `null`, mais `selectProgramCard()` refuse encore si `pollState.commandInFlight` reste vrai; une réponse tardive `launch_session` peut ensuite réinstaller `pendingCommandId` et ramener la raison exacte `pending_command`.
- [x] Corriger sans `enableButtons()` forcé: reset local invalide les mutations en vol, vide `commandInFlight` / `selectionInFlight`, retire spinner/loading et empêche les réponses tardives de restaurer une commande pending.
- [x] Auditer Master hidden dans les logs: les POST Master ont des gaps 9/10/13/43/63 s alors que la Remote poll régulièrement; avec un gate 6 s et un background interval 10 s, les fausses déconnexions sont mécaniques.
- [x] Publier immédiatement `visibility=hidden` sur `visibilitychange` sans ajouter de polling et envoyer une release best-effort sur `pagehide`, ignorée pendant les redirections runtime nominales.
- [x] Couvrir par `hub_remote_polling_test.mjs` et `hub_remote_contract_test.php`.
- [ ] Recette navigateur: Master visible plusieurs dizaines de secondes, Master hidden 1-2 min sans flash, retour premier plan sans takeover, fermeture réelle avec blocage Remote, takeover A -> B avec A hidden.

## PATCH 2026-08-26 - Hub Remote bloquée sans Master frais
- [x] Corriger la machine d'état front pending: `master_present=false` abandonne la commande locale, supprime spinner/verrous et invalide les réponses `command_status` tardives sans mutation serveur; `expired`, `cancelled`, `failed` et `replaced` réinitialisent aussi l'UI quand Master est présent.
- [x] Relire le préambule documentaire obligatoire: START raw main, SITEMAP.txt/SITEMAP.ndjson develop, DOCS_MANIFEST, README/TASKS Games/Global, HANDOFF et CHANGELOG. Journal AI Studio raw consulté via l'URL imposée mais inaccessible en lecture utile (`HTTP 500 Internal Server Error` via outil web); fallback documentaire/local appliqué.
- [x] Auditer `master_present`: l'ancien TTL 30 s existait depuis `a527c61b`; la régression venait de nouvelles mutations Remote directes non gated et de l'usage du signal 30 s comme interactivité.
- [x] Auditer `business_snapshot`: il reconstruit le Programme/Lots/Top joueurs et les révisions métier depuis `app_games_hub_render_context_get(...)`; il ne pilote pas la présence Master, mais expose maintenant `hub_wording` issu de `games_hub_master_wording_labels_get(...)` pour le wording Remote.
- [x] Brancher le dispatch Remote sur un gate serveur frais calculé une fois par requête HTTP de mutation, sans nouveau polling Remote/Master.
- [x] Refuser côté serveur les mutations Remote sans Master frais: `session_settings_save`, `quick_session_create`, `quick_session_theme_renew`, `master_ping`, `select_session`, `launch_session` / reprise; conserver les lectures `control_poll`, `business_snapshot`, `command_status` et get non-mutant.
- [x] Remplacer le bandeau bas par un voile global bloquant avec modale centrée, blur/atténuation du fond et `masterEverPresent` seulement local pour le wording.
- [x] Déplacer le claim Master avant le touch de présence pour éviter qu'un retour Master rafraîchisse artificiellement une absence avant évaluation des pending.
- [x] Couvrir par `hub_remote_contract_test.php` et `hub_remote_polling_test.mjs`: rendu initial, `false -> true`, `true -> false`, retour `false -> true`, wording soirée/événement, verrou global, guards préparation/runtime.
- [ ] Recette navigateur réelle: Remote ouverte avant Master, ouverture CTA Dashboard Master, disparition voile sans reload; perte après ~6 s, refus settings/quick-add/renew/select/launch; retour Master sans exécution d'ancienne commande pending; takeover Master A -> B.

## PATCH 2026-08-26 - Exclusivité Hub Master / Hub Remote
- [x] Relire le préambule documentaire obligatoire: START raw main, SITEMAP.txt develop, DOCS_MANIFEST, README/TASKS Games/Global, HANDOFF et CHANGELOG. Journal AI Studio raw consulté via `curl` mais inaccessible (`HTTP 403 Forbidden`, `Fichier non autorisé ou introuvable`); fallback documentaire/local appliqué.
- [x] Auditer les surfaces Hub: Hub Master persistait son identité dans `localStorage` (`cottonHubMasterInstanceId`), donc deux onglets partageaient la même instance; Hub Remote n'avait pas de propriété canonique serveur.
- [x] Ajouter un boot explicite `hub_instance_takeover` côté Master et `instance_takeover` côté Remote, sans WebSocket et sans effet sur runtime, présentation, exécution ou routage.
- [x] Faire porter aux requêtes Hub Master/Remote un UUID de page, non partagé par `localStorage`.
- [x] Rejeter les polls/actions/mutations stale avec `instance_current=false` et `replaced=true`.
- [x] Afficher une overlay terminale "Cette interface est ouverte ailleurs. Vous pouvez fermer cette page.", arrêter timers/retries et bloquer les contrôles, sans `window.close` ni redirection Hub.
- [x] Couvrir par `hub_remote_contract_test.php` et `hub_remote_polling_test.mjs`.
- [ ] Recette navigateur: ouvrir deux Masters puis deux Remotes, vérifier que le dernier onglet reste actif, que les anciens affichent l'overlay, et qu'aucun launch/restart/quit/clear n'est produit au takeover.

## PATCH 2026-08-26 - Hub Remote cartes Programme légères
- [x] Relire le préambule documentaire obligatoire: START raw main, SITEMAP.txt develop, DOCS_MANIFEST, README/TASKS Games, HANDOFF et CHANGELOG. Journal AI Studio raw inaccessible avant patch (`HTTP 403 Forbidden`), fallback documentaire/local appliqué.
- [x] Auditer le rendu actuel: `games_hub_remote_sessions_project(...)` expose action runtime, settings et eligibility renouvellement; le rendu PHP initial et `renderProgram()` JS rendaient les actions dans un bloc de carte masqué hors focus.
- [x] Auditer Hub Master: les icônes de préparation sont compactes dans `games_hub_render_program(...)` via `data-hub-session-theme-renew` et `data-hub-session-settings`, avec disponibilité issue de `games_hub_session_settings_state(...)` et `games_hub_session_theme_renewal_is_eligible(...)`.
- [x] Corriger Hub Remote: hors `presentation_session_id`, les cartes ne rendent plus aucun CTA/action de préparation dans le DOM; au focus, préparation en icônes compactes hautes et CTA runtime séparé en bas.
- [x] Conserver la carte `AJOUTER UNE PARTIE` comme action programme séparée, sans lui appliquer les règles de session.
- [x] Couvrir rendu initial/JS et déplacement de focus par `hub_remote_contract_test.php` et `hub_remote_polling_test.mjs`.
- [ ] Recette navigateur mobile: parcourir Programme avec plusieurs sessions, sélectionner successivement des cartes, vérifier absence de gros boutons hors focus et absence de lancement au clic carte.

## PATCH 2026-08-25 - Hub sync suspendue uniquement après terminal non réactivable
- [x] Auditer l'intérêt perf: Dashboard Pro ajoute seulement un check 12 s léger; Remote conserve un poll 2-3 s et Master des boucles présence/révision visibles dans les logs.
- [x] Confirmer le cas réactivable: un Hub peut avoir toutes ses sessions courantes terminées tant que la fenêtre d'ajout rapide reste ouverte.
- [x] Définir le garde commun de suspension: Hub completed ET `launch_window_open=false`.
- [x] Exposer `hub_sync_suspended` dans le snapshot Remote et couper les nouveaux `control_poll` seulement sur cet état.
- [x] Ajouter `data-hub-sync-suspended` au rendu Master et court-circuiter refresh de préparation + présence.
- [x] Couvrir Remote/Master par tests de contrat et test JS de polling terminal.
- [ ] Recette navigateur réelle après cutoff: Hub terminé, Remote/Master ouverts, vérifier absence de nouveaux polls; avant cutoff avec toutes les sessions terminées, ajouter une partie et vérifier réactivation/convergence.

## PATCH 2026-08-25 - Hub Remote renouvellement theme et instrumentation convergence
- [x] Relire START raw main, SITEMAP.txt develop, DOCS_MANIFEST et cartes Games/Global/Pro; journal AI Studio raw non consulte car demande explicitement signale en erreur.
- [x] Auditer Master: `quick_session_theme_renew` est rendu seulement pour les sessions `quick_hub_create`, jamais lancees, non running/terminees/focus actif, jeux quiz/blindtest/bingo, avec CSRF Master et helper Global plan/apply.
- [x] Auditer Dashboard Pro: le bouton `↻` chaine `session_theme_renewal_plan` puis `session_theme_renewal_apply`, en injectant le candidate loader Quiz et le `hub_id` quand present.
- [x] Ajouter sur Hub Remote l'endpoint direct `quick_session_theme_renew`, protege par token Remote session-bound + CSRF + appartenance Hub + eligibility Master.
- [x] Garder le renouvellement comme mutation de preparation: aucune commande Master, aucun `master_present`, aucun runtime, aucun changement de focus implicite.
- [x] Exposer `theme_renewal.eligible` dans la projection Remote et afficher un bouton compact `↻` uniquement dans la zone d'actions de la carte selectionnee.
- [x] Prevenir le double clic Remote, attendre la reponse serveur, puis rafraichir via `business_snapshot` canonique sans appliquer localement le theme.
- [x] Ajouter instrumentation dev-only `[hub_remote_perf]` T0-T6 et `[hub_master_perf]` autour du refresh partiel Master.
- [x] Couvrir par `hub_remote_contract_test.php`, `hub_session_settings_test.php` et `hub_remote_polling_test.mjs`.
- [ ] Recette navigateur: mesurer Dashboard -> Remote, Master -> Remote et Remote -> Master pour format/mode/contenu/settings/quick-add/`↻`; relever les logs `[hub_remote_perf]` et `[hub_master_perf]` sur localhost.

## PATCH 2026-08-25 - Hub Remote settings et quick-add directs
- [x] Relire START raw main, SITEMAP.txt develop, DOCS_MANIFEST et cartes Games/Global/Pro; journal AI Studio raw consulté mais inaccessible (`HTTP 403 Forbidden`, `Fichier non autorisé ou introuvable`).
- [x] Auditer Master: `session_settings_get/save` valide capacité Master + CSRF + session Hub, puis réutilise `canvas_session_options_hub_update_normalize(...)` et `canvas_session_options_snapshot_save(...)`; `quick_session_create` délègue à `app_programming_quick_hub_create_from_game(...)`.
- [x] Auditer Remote: `control_poll` compare les révisions métier puis appelle `business_snapshot`, qui savait déjà reconstruire Programme/Lots/Top joueurs depuis `app_games_hub_render_context_get(...)`.
- [x] Ajouter des endpoints Remote directs `session_settings_get`, `session_settings_save` et `quick_session_create`, protégés par token Remote session-bound + CSRF Remote + appartenance session/Hub.
- [x] Garder `launch_session` et `select_session` dans le contrat Remote -> commande -> Master; aucune commande Master pour settings ou quick-add.
- [x] Ajouter le dialog mobile de paramétrage Remote à partir du formulaire serveur canonique, sans appliquer de valeur optimiste définitive avant confirmation.
- [x] Ajouter la carte Remote `AJOUTER UNE PARTIE`; le client transmet seulement le type de jeu allowlisté et une clé d'idempotence au service Global.
- [x] Conserver le focus pending: après quick-add Remote, `presentation_session_id` créé est gardé jusqu'au prochain `business_snapshot` contenant la session.
- [x] Corriger le focus Master après quick-add Remote: le refresh partiel conserve la session sélectionnée par le HTML serveur frais au lieu de restaurer l'ancienne sélection locale.
- [x] Couvrir par `hub_remote_contract_test.php`, `hub_remote_polling_test.mjs` et `hub_session_settings_test.php`.
- [ ] Recette navigateur réelle: Dashboard -> Master/Remote format, mode, contenu sans reload; Remote settings -> Master/Remote; Remote quick-add double tap/retry; vérifier aucun runtime lancé.

## PATCH 2026-08-25 - Hub Remote UI header et listes compactes
- [x] Relire START raw main, SITEMAP.txt develop et DOCS_MANIFEST; journal AI Studio raw consulté mais inaccessible (`HTTP 403 Forbidden`, `Fichier non autorisé ou introuvable`).
- [x] Auditer `games/web/modules/app_hub_remote_ajax.php`: header Remote, présence Master, compteur `players_count`, Lots et Top joueurs sont rendus dans le PHP initial puis reconstruits par le JS inline via `applyBusinessSnapshot()`.
- [x] Confirmer que les styles Remote sont inline/scopés dans `app_hub_remote_ajax.php`; aucun CSS partagé modifié.
- [x] Remplacer uniquement le wording visible `Master présent` / `Master absent` par `Connecté` / `Déconnecté`, sans renommer `master_present`.
- [x] Déplacer le compteur joueurs dans une pastille header compacte et conserver la pluralisation `joueur inscrit` / `joueurs inscrits` alimentée par `players_count`.
- [x] Normaliser les rangs avant ajout du préfixe visuel unique `#` pour éviter `##1` en rendu initial et snapshot dynamique.
- [x] Centrer les rangs Lots/Top joueurs dans une colonne stable, sans changer les projections métier.
- [x] Couvrir par `hub_remote_contract_test.php` et `hub_remote_polling_test.mjs`.
- [ ] Recette navigateur réelle 320/360/375/390/430: vérifier absence d'overflow horizontal, pastilles lisibles, sous-titre sur une ligne, CTA inchangé, Lots/Top joueurs alignés.

## PATCH 2026-08-25 - Hub Master: retirer le badge Prochaine
- [x] Relire START raw main, SITEMAP.txt, SITEMAP.ndjson et DOCS_MANIFEST; ne pas interroger le journal AI Studio raw avant patch car déjà en erreur.
- [x] Auditer les usages `Prochaine`: assignation visible dans `games_hub_render_program(...)`, classe UI `hub-session--next`, helper interne `games_hub_next_session_id(...)`, tests de rendu Programme.
- [x] Classer `UI_ONLY_TO_REMOVE`: substitution `Prête -> Prochaine` et classe `hub-session--next`.
- [x] Classer `POLICY_INTERNAL_TO_KEEP`: `games_hub_next_session_id(...)`, sélection automatique Master, helpers Global `app_games_hub_next_ready_session_resolve(...)` et `app_games_hub_presentation_apply_next_ready(...)`.
- [x] Classer `TEST_TO_ADAPT`: rendu Master doit ne plus contenir `Prochaine` ni `hub-session--next`, tout en gardant la même cible interne.
- [x] Retirer uniquement la restitution visuelle côté Hub Master.
- [x] Couvrir par `hub_session_settings_test.php`; conserver les tests quick add, Remote convergence, séparation runtime/presentation et fin naturelle.
- [ ] Recette navigateur: vérifier que les cartes Master n'affichent plus `Prochaine`, puis tester suspension/quit avec next-ready et fin naturelle sans promotion.

## PATCH 2026-08-25 - Hub présentation: prochaine session prête événementielle
- [x] Relire START, SITEMAP, SITEMAP.ndjson, DOCS_MANIFEST; journal AI Studio raw inaccessible (`HTTP 403`, `Fichier non autorisé ou introuvable`).
- [x] Auditer les preuves historiques: `natural_completion_return` sélectionne la session terminée/podium avant pending; la résolution générale sélectionne pending avant completion ou suspended.
- [x] Conclure la règle: next-ready persistant uniquement sur événement suspension/quit/grâce, pas sur refresh, reload, Remote poll ou reconstruction DOM.
- [x] Exclure la fin naturelle de la promotion next-ready pour préserver le retour podium/session terminée.
- [x] Garder quick add comme producteur explicite `quick_add` de présentation créée, sans régression pending Remote.
- [x] Marquer les clears Organizer/grâce avec des raisons dédiées et laisser Global appliquer la politique via le helper présentation.
- [x] Couvrir par `hub_natural_end_stats_rebuild_test.php`, `hub_session_settings_test.php`, contrats Remote et contrats Global présentation/routing.
- [ ] Recette navigateur: session A lancée puis quit/suspension avec B prête => Master/Remote sélectionnent B; fin naturelle de A avec B prête => retour podium/A, puis B seulement après événement explicite suivant.

## PATCH 2026-08-25 - Hub Master refresh positionnel silencieux
- [x] Relire START, SITEMAP, DOCS_MANIFEST; journal AI Studio raw inaccessible (`HTTP 403`, `Fichier non autorisé ou introuvable`).
- [x] Relire les logs rechargés `games/logs` et `global/logs`: la sélection canonique `presentation_session_id` est correcte côté serveur; pas de trace Global d'un focus concurrent.
- [x] Identifier la cause UI: `replaceBlock('[data-hub-refresh-block="program"]', ...)` reconstruit le DOM Programme; le nouveau scroller repart à `scrollLeft=0`.
- [x] Corriger la confusion `scroll=false`: le refresh et le boot doivent repositionner la carte canonique en `behavior:'auto'`, pas supprimer tout repositionnement.
- [x] Conserver le scroll animé pour une vraie nouvelle sélection Master/Remote vers une autre carte.
- [x] Couvrir par `hub_remote_contract_test.php`.
- [ ] Recette navigateur: carte canonique hors premières cartes, refresh Programme sans second mouvement mais carte visible/centrée; puis sélection différente avec animation conservée.

## PATCH 2026-08-25 - Hub Master reload restaure la présentation canonique
- [x] Relire START, SITEMAP, DOCS_MANIFEST et docs Games/Global; journal AI Studio raw inaccessible (`HTTP 403`, `Fichier non autorisé ou introuvable`).
- [x] Analyser `games/logs/error_log`, `games/logs/access_log`, `global/logs/error_log` et `global/logs/access_log` autour des derniers tests Master/Remote.
- [x] Conclure côté serveur: une seule écriture `presentation_session_id` par sélection, Remote résout bien `persistent_presentation_session_id`, mais les GET Master retombent sur `first_unplayed_program_order`.
- [x] Identifier la cause code: `games_hub_render_program($view, ...)` utilisait `$context['hub']` hors scope pour relire la présentation.
- [x] Corriger minimalement: transporter `presentation` dans le view model et le passer au resolver de sélection Master.
- [x] Ajouter un contrat qui interdit au rendu Programme de relire `$context['hub']` hors scope.
- [ ] Recette navigateur/logs: vérifier que les GET Master après sélection affichent la session canonique et plus `first_unplayed_program_order`.

## PATCH 2026-08-25 - Hub Master refresh sélection idempotent
- [x] Inventorier les chemins de sélection Master: clic carte, clavier, flèches, podium close, init carrousel, intent Remote, refresh Programme et clic synthétique de restauration.
- [x] Tracer le chemin commun Master -> Master et Remote -> Master: écriture présentation, changement de révision, refresh Programme, `hub:program-refreshed`, réinit carrousel.
- [x] Identifier la ligne responsable du second focus: `selectCard(selected, true, ...)` pendant la réinit post-refresh.
- [x] Corriger minimalement: détecter `hub:program-refreshed` et initialiser la carte déjà sélectionnée sans scroll.
- [x] Conserver le scroll initial de page et le scroll pour un vrai nouvel intent vers une autre session.
- [x] Couvrir par `hub_remote_contract_test.php`.
- [ ] Recette navigateur: clic Master B puis refresh, Remote B puis refresh sans second déplacement; sélection réelle C avec déplacement conservé.

## PATCH 2026-08-25 - Hub Remote bootstrap sélection et police
- [x] Reprendre les logs/constat de chargement: Remote sans carte sélectionnée jusqu'à interaction et police appliquée tardivement.
- [x] Identifier la cause sélection: `games_hub_remote_initial_payload(...)` ne recopiait pas `presentation_session_id` depuis le snapshot initial.
- [x] Recopier `active_session_id`, `presentation_session_id`, `presentation_mode` et `presentation_reason` dans le payload initial.
- [x] Appliquer `syncHubBranding(initialBranding)` au bootstrap JS pour injecter font/variables/logo sans attendre `business_snapshot`.
- [x] Couvrir par `hub_remote_contract_test.php` et `hub_remote_polling_test.mjs`.
- [ ] Recette navigateur: hard reload Hub Remote, vérifier carte sélectionnée et police appliquée avant toute interaction.

## PATCH 2026-08-25 - Hub focus runtime vs présentation séparés
- [x] Reprendre l'audit `active_session_id`: classer runtime légitime, usages présentation à migrer et champs de compatibilité à conserver.
- [x] Garder `games_hubs.active_session_id` comme focus runtime strict: launch/reprise, contexte d'exécution, auto-join Hub Play, routing Remote historique et clear restent inchangés.
- [x] Faire lire Hub Remote `business_snapshot.presentation_session_id` depuis `app_games_hub_presentation_resolve(...)`, sans fallback client vers la première carte.
- [x] Remplacer les sélections Master/Remote par `app_games_hub_presentation_session_set(...)`, qui écrit seulement la présentation et ne lance pas de runtime.
- [x] Faire utiliser au boot Master la présentation persistée quand elle existe, puis les fallbacks non destructifs du programme.
- [x] Corriger le libellé Master: une carte présentée mais non focalisée runtime n'affiche plus `En cours`.
- [x] Ajouter la migration Games `2026-08-25_games_hubs_presentation_session.sql`, sans backfill.
- [x] Couvrir la séparation par `hub_remote_contract_test.php` et `hub_presentation_runtime_separation_test.php`.
- [ ] Recette navigateur: sélectionner une session terminée puis suspendue depuis Master et Remote; vérifier que `presentation_session_id` change, que `active_session_id` ne change pas avant `Lancer` / `Reprendre`, que Hub Play ne rejoint rien, puis lancer/reprendre et vérifier le routage runtime.

## PATCH 2026-08-25 - Hub Remote UI mobile-first + focus partagé
- [x] Relire START, SITEMAP, SITEMAP.ndjson, DOCS_MANIFEST et HANDOFF; journal AI Studio raw consulté mais inaccessible (`HTTP 403`, `Fichier non autorisé ou introuvable`), fallback documentaire local relu.
- [x] Borner le patch à Hub Remote, au poll Master et à la commande légère Global `select_session`, sans changer `client_routing`, `runtime_presence`, readiness, WS, Hub Play ou scoring.
- [x] Retirer du rendu utilisateur les blocs techniques `Contrôle`, `Tester l’écran Master`, commande en attente, session active et révision.
- [x] Reprendre le branding compact Hub Play dans `business_snapshot` via `games_hub_play_branding_payload(...)`: couleurs, police, titre, méta et logo compact au rendu initial puis en refresh dynamique, sans grand visuel Remote.
- [x] Ajouter un résumé compact `Inscrits live` depuis `business_snapshot.players_count`, avec wording Hub Master `joueur inscrit` / `joueurs inscrits` et mise à jour snapshot sans reload.
- [x] Aligner la projection Programme Remote sur les helpers Master: jeu, thème, format/mode, séries Quiz et statut, sans horaires individuels dans les cartes.
- [x] Exposer `presentation_session_id` dans `business_snapshot`; cette première passe le lisait encore depuis le focus runtime avant séparation dédiée.
- [x] Rendre les cartes Remote sélectionnables via `select_session`; Hub Master consomme la commande comme intention de présentation, sans lancer le runtime.
- [x] Faire poster les sélections de cartes Master vers `presentation_session_select`, afin que Master -> Remote converge aussi par snapshot.
- [x] Corriger le fast-path de `presentation_session_select`: charger les sessions avant validation d'appartenance Hub pour que les clics Master persistent réellement le focus.
- [x] Empêcher la restauration post-refresh du carrousel Master de reposter ou d'animer une sélection synthétique, et ignorer le scroll quand un intent Remote cible déjà la carte sélectionnée.
- [x] Neutraliser les notices `play_url` / `master_url` absentes dans le payload branding Remote.
- [x] Synchroniser la sélection Remote depuis le snapshot sans renvoyer de `select_session`, pour laisser les événements serveur/fin de partie écraser une ancienne sélection locale.
- [x] Supprimer le CTA `Résultats`; garder des CTA visibles seulement pour `Lancer` / `Reprendre`.
- [x] Harmoniser `Inscrits live`, Lots (`#rang` avant lot) et Top joueurs (`#rang`, pseudo, stat courte) sur la structure compacte Master.
- [x] Projeter le Top joueurs via `games_hub_general_ranking_from_aggregate_context(...)` et afficher `display_stat_short` au lieu du score brut.
- [x] Ajouter un spinner immédiat sur les CTA `launch_session`, le conserver après `completed` jusqu'au routage canonique, et nettoyer l'état loading sur erreur/expiration.
- [x] Couvrir par `hub_remote_contract_test.php` et `hub_remote_polling_test.mjs`.
- [ ] Recette navigateur mobile: 320x568, 360x640, 375x667, 390x844, 430x932 sans overflow horizontal; vérifier Remote -> Master, Master -> Remote, fin naturelle -> podium + Remote sélectionnée, sélection terminée sans CTA, suspendue avec `Reprendre`, prête avec `Lancer`, spinner puis navigation via `client_routing`.

## PATCH 2026-08-24 - Remote Bingo Hub: fallback local désactivé en dev
- [x] Borner la recette: ne pas modifier le contrat terminal, Bingo WS, BT/Quiz, Player ou Remote hors Bingo Hub.
- [x] Désactiver en dev/local le fallback `remote_quit_request` côté Remote Bingo Hub après `RemoteAPI.requestQuit(sessionId)`.
- [x] Conserver le fallback hors dev comme filet temporaire inchangé.
- [x] Conserver les logs existants `hub_remote_bingo_quit`, `quitGame_received`, `hub_remote_bingo_terminal_delivery`, `hub_remote_remote_ws` et `navigation_triggered`; ajouter seulement le diagnostic local `REMOTE_BINGO_QUIT_FALLBACK_DISABLED`.
- [x] Étendre `hub_remote_contract_test.php` pour surveiller le garde dev et la présence du fallback non-dev.
- [ ] Recette navigateur dev: Remote Bingo Hub -> Quitter -> verifier absence de retour local a 800 ms, puis retour uniquement apres `SESSION_ENDED` / `HUB_SESSION_FINISHED` avec `hub_remote_remote_ws` et `navigation_triggered`.
- [ ] Apres recette concluante: supprimer definitivement le fallback ou le reactiver explicitement/documenter comme filet de securite uniquement.

## PATCH 2026-08-24 - Bingo Remote quit: garantie quitGame Organizer
- [x] Relire START, SITEMAP, DOCS_MANIFEST et HANDOFF; journal AI Studio raw consulté mais inaccessible (`HTTP 403`, `Fichier non autorisé ou introuvable`), fallback documentaire local relu.
- [x] Reconstituer l'ordre réel: `endSession(serverLogout=true)` faisait `clear_hub_focus`, puis un `Bus.emit('game:ws:send')` fire-and-forget conditionné à un `sessionId` local, puis notice/cleanup/redirection Master.
- [x] Comparer BT/Quiz/Bingo: BT/Quiz relaient `remoteQuitRequest` au primary puis consomment `quitGame`; Bingo relayait `remote_action=remote_quit_request`, mais pouvait perdre le `sessionId` Remote avant `endSession`.
- [x] Corriger `boot_organizer.js`: propager le `sessionId` de la demande Remote vers `endSession()` et logguer `hub_remote_bingo_quit stage=remote_request_consumed`.
- [x] Corriger `end_game.js`: résoudre le `sessionId` depuis explicite/store/AppConfig/preload/DOM, attendre un résultat local `ws_connector:send_done` pour `quitGame`, et bloquer la redirection si l'envoi est absent, non OPEN, throw ou timeout.
- [x] Corriger `ws_connector.js`: exposer `ws_connector:send_done` / `ws_connector:send_fail` corrélés par `_sendTraceId`, sans ajouter d'ACK serveur.
- [x] Étendre `hub_remote_contract_test.php` pour vérifier l'ordre `clear_hub_focus -> await quitGame -> redirect`, les logs et la propagation `sessionId`.
- [ ] Recette navigateur dev: Remote Bingo Hub -> Quitter -> logs `remote_request_consumed`, `end_session_started`, `quit_game_send_start`, `quit_game_send_done`, `quitGame_received`, `SESSION_END`, `hub_remote_bingo_terminal_delivery send_success=true`, puis retours Master/Play/Remote.

## PATCH 2026-08-24 - Hub Remote: garde Master historique avant auto-routing
- [x] Relire START, SITEMAP, DOCS_MANIFEST et HANDOFF; journal AI Studio raw consulté mais inaccessible (`HTTP 403`, `Fichier non autorisé ou introuvable`), fallback documentaire local relu.
- [x] Identifier le garde aval Remote historique: erreurs WS `Session introuvable.` / notices `remote/error` et terminaux retournent Hub Remote via `hubRemoteReturn`, mais seulement apres une navigation inutile.
- [x] Prouver par logs que `control_poll.master_present` est le Hub Master, pas le Master historique de jeu; il reste true tant que le Hub Master envoie `remote_control_poll`.
- [x] Ajouter un heartbeat Master historique `remote_runtime_presence` apres `organizer/runtime-ready`, avec présence Global par hub/session/execution et TTL serveur court.
- [x] Exposer `client_routing.master_context_available` separement de `client_joinable`, sans rendre `master_present=false` ni `master_context_available=false` terminaux.
- [x] Modifier `routeFromControlState()` pour exiger `client_joinable=true` + `master_context_available=true`.
- [x] Ajouter le test Poll 1 `client_joinable=true/master_present=false` sans navigation puis Poll 2 Master valide avec navigation automatique, plus le cas Hub Master present seul sans navigation.
- [x] Corriger la regression command `85`: le heartbeat runtime ne depend plus de `remote_launch_readiness`, demarre des `organizer/runtime-ready` et devient la source canonique de `client_joinable`.
- [x] Conserver la readiness comme diagnostic/`command_status` uniquement, sans gating routing.
- [ ] Recette navigateur dev: Hub Remote session joignable avec Hub Master present mais Master historique ferme reste affiché, puis ouverture/reprise Master historique déclenche une seule navigation Remote.

## PATCH 2026-08-24 - Remote historique: sortie hors Hub
- [x] Diagnostiquer le fallback hors Hub: `SESSION_ENDED` et `remote/sessionEnded` etaient preserves, mais l'UI n'avait plus de sortie quand `returnToHubRemoteAfterNotice(...)` retournait `false`.
- [x] Exposer `proUrl` / `wwwUrl` dans `remote_canvas.php` et retablir `tryCloseTab()` puis redirection Pro si `idClient > 0`, sinon WWW serveur-aware (`www.dev` en dev, `www` en prod).
- [x] Garder le bouton quit Remote avec l'icone Master `bi-x-lg` et en derniere position de barre basse.
- [x] Couvrir par `hub_remote_contract_test.php` et verifier `remote_canvas.php` / `remote-ui.js`.
- [ ] Recette navigateur dev hors Hub: depuis Remote historique, confirmer le quit, verifier fermeture onglet ou redirection Pro/WWW apres `SESSION_ENDED`.

## PATCH 2026-08-24 - Hub Remote: relance BT/Quiz et quit Bingo
- [x] Relire START, SITEMAP, DOCS_MANIFEST et HANDOFF; journal AI Studio raw consulté mais inaccessible (`HTTP 403`, `Fichier non autorisé ou introuvable`), fallback documentaire local relu.
- [x] Auditer `getHubRemoteCommandId`, `hub_remote_command`, `hub_remote_execution`, `remote_launch_readiness` et `organizer/runtime-ready`; confirmer que les helpers `getHubRemoteCommandId()` / `getHubRemoteExecutionId()` étaient orphelins dans la branche reprise pausee.
- [x] Restaurer la correlation canonique depuis l'URL Organizer (`hub_remote_command`, `hub_remote_execution`) via `hubRemoteLaunchContext()`, sans stub des anciens helpers.
- [x] Après recette réelle command `72`, corriger le contrat navigateur: une exécution réutilisée mais pas encore prête ne déclenche plus `window.location.replace(remoteUrl)`.
- [x] Conserver `execution_id`, `launch_session`, `control_poll` et `business_snapshot`; consommer `readiness_required` / `client_routing` corrigés côté Global.
- [x] Après recette réelle command `74`, supprimer le second chemin de navigation: `command_status completed` ne lit plus `command.result.remote_url`, ne fait plus `window.location.replace(...)` et ne loggue plus `hub_remote_launch_remote_navigation`.
- [x] Déclencher seulement un `control_poll` immédiat après commande `launch_session` terminée; laisser `routeFromControlState(payload.client_routing)` comme source unique de navigation.
- [x] Rendre cette navigation canonique idempotente avec `remoteRoutingStarted`, pour ignorer deux polls joinables successifs.
- [x] Comparer le quit Remote Bingo au quit Quiz/Blind Test; identifier que le snapshot live Bingo arrive par `state`, non marque comme live Hub Remote avant terminal.
- [x] Marquer les snapshots Bingo `state` comme etat live Hub Remote afin qu'un `SESSION_ENDED` de quit volontaire ne soit pas classe comme terminal stale de bootstrap.
- [x] Ajouter l'instrumentation temporaire `hub_remote_remote_ws` en contexte Hub Remote, sans token, pour prouver si la Remote Bingo reçoit `SESSION_ENDED`, le diffère, l'accepte, appelle HubTransition ou échoue à naviguer.
- [x] Marquer le `SESSION_ENDED` Bingo de quit volontaire avec `reason=organizer_quit` / `terminal_reason=organizer_quit`, sans changer les fins naturelles ni la grâce organizer.
- [x] Faire revenir immédiatement le Player Bingo Hub vers Hub Play sur ce terminal volontaire explicite, en conservant le flow historique hors Hub et le délai visuel de fin naturelle.
- [x] Corriger la Remote Bingo Hub: le terminal explicite `organizer_quit` bypass maintenant le differé anti-terminal-precoce et demande immédiatement le retour Hub Remote.
- [x] Corriger le quit demande depuis la Remote Bingo Hub: apres envoi de `remote_quit_request`, armer un retour Hub Remote court annulable par `remoteQuitUnavailable`, afin de ne plus dependre uniquement de la livraison terminale serveur vers la Remote.
- [x] Couvrir le contrat Player par `hub_session_settings_test.php` et le contrat serveur/Remote par `hub_remote_contract_test.php`.
- [x] Couvrir par `hub_remote_contract_test.php`, `hub_remote_polling_test.mjs` et `hub_transition_remote_test.mjs` avec la structure Bingo réelle `SESSION_ENDED`.
- [ ] Recette navigateur dev: relance/reprise Blind Test et Quiz sans log `hub_remote_launch_remote_navigation`, avec `client_routing.client_joinable=true` avant un seul trajet vers Remote historique; quit volontaire Bingo avec logs `hub_remote_bingo_terminal_delivery` et `hub_remote_remote_ws`, puis retour immédiat Master/Player/Remote vers leurs surfaces Hub.

## PATCH 2026-08-24 - Hub Remote: convergence métier dynamique
- [x] Relire START, SITEMAP, DOCS_MANIFEST et HANDOFF; journal AI Studio raw consulté mais inaccessible (`HTTP 403`, `Fichier non autorisé ou introuvable`), fallback documentaire local relu.
- [x] Réutiliser `app_games_hub_render_context_get(...)` pour produire le snapshot métier Remote, sans dupliquer les règles Master côté JS.
- [x] Ajouter l'action AJAX séparée `business_snapshot`, distincte de `control_poll`.
- [x] Initialiser les révisions métier depuis le rendu initial pour éviter un snapshot doublon au premier `control_poll`.
- [x] Déclencher le snapshot seulement sur changement de `preparation_revision`, `runtime_revision` ou `results_revision`.
- [x] Mettre à jour sans reload les blocs Programme, Lots et Top joueurs, puis rebrancher les boutons de lancement.
- [x] Garder `control_poll`, `launch_session`, `execution_id`, `readiness_required` et `client_routing` dans leurs contrats existants.
- [x] Couvrir par `hub_remote_contract_test.php` et `hub_remote_polling_test.mjs`, dont absence de snapshot sans changement, retry après erreur snapshot et absence de double polling visible/pageshow.
- [ ] Recette navigateur dev: Remote ouverte sur `/hub/{remote_token}/remote`, ajout/suppression/modification de partie, changement lots, launch/reprise/quit/fin naturelle, Top 3 après résultats, deux cycles sans donnée ancienne.

## PATCH 2026-08-24 - Hub Remote: revert borne vers baseline launch
- [x] Identifier la baseline locale: `games@9c47a21cb21574d7f8ea7ef036cd0c33001d2596` (`2026-08-24 11:28:43 +0200`) et `global@f5b23dbc02001c6fd21a18232aae891767fef72e`.
- [x] Confirmer que les changements suspects etaient non commit: `primary_presence`, `runtime_ready_at`, contrainte `readiness && primary_presence`, `resume_waiting_primary`, presence Organizer et reconciliation `pendingCommandId`.
- [x] Restaurer le contrat Hub Remote de baseline: `completed + remote_url + readiness si requise` declenche la navigation Remote historique.
- [x] Conserver les correctifs orthogonaux du matin: quit volontaire Remote, tolerance `Session introuvable.`, differé terminal precoce, wording et tests Remote associes.
- [x] Verifier que les fichiers cibles Games n'ont plus de diff apres revert.
- [x] Couvrir par `php web/tests/hub_remote_contract_test.php` et `node web/tests/hub_remote_polling_test.mjs`.
- [ ] Recette navigateur dev: lancement neuf BT, lancement neuf Quiz, lancement neuf Bingo, reprise suspendue BT, reload Hub Remote session active, quit Remote, quit Master -> Hub Remote.

## PATCH 2026-08-24 - Remote historique: quit volontaire via Master
- [x] Auditer le quit Master existant: boutons `#quitGameLink` / `#quitGameLinkMobile`, confirmation `Quitter le jeu ?`, handler `ui/quit` et contrat `endSession({ reason:'Quitter le jeu', serverLogout:true })`.
- [x] Auditer les serveurs runtime: Quiz/Blind Test `quitGame` ferme volontairement via `handleDisconnect(..., true)`; Bingo `quitGame forced=false` termine la session et notifie joueurs/Remote.
- [x] Retirer le bouton `X` du header Remote et déplacer l'action volontaire dans la barre mobile basse avec icône de sortie.
- [x] Aligner la confirmation Remote sur le wording Master exact: `Quitter le jeu ?`, `Déconnexion de l'organisateur et de tous les joueurs.`, `Annuler`, `Quitter`.
- [x] Remplacer le quit direct Remote par une demande explicite vers l'Organizer primaire: `remoteQuitRequest` Quiz/Blind Test, `remote_action.remote_quit_request` Bingo.
- [x] Faire exécuter côté Organizer le contrat Master existant, sans seconde logique de clôture Remote et sans fermeture automatique sur `pagehide`, `beforeunload`, reload, background ou coupure réseau.
- [x] Corriger la suite des logs de recette: quand le Master reçoit déjà `WS_MESSAGE type=remoteQuitRequest`, `boot_organizer.js` traite aussi le message WS brut en garde direct et appelle `endSession()` sans dépendre uniquement du relais `ws_effects`.
- [x] Corriger la relance Hub Remote: `gameStateError` / `registrationError` `Session introuvable.` est toléré et rejoué quelques secondes en contexte Hub Remote pendant que le runtime recrée la session WS, au lieu d'afficher immédiatement la popup fatale.
- [x] Corriger le rebond post-log: un `SESSION_ENDED` / `HUB_SESSION_FINISHED` reçu trop tôt au boot Hub Remote est différé quelques secondes et annulé dès qu'un état live (`registrationSuccess`, `gameState`, `sessionUpdate`, `update_session_infos`) confirme la relance.
- [x] Retirer les derniers appels UI à l'ancien `tryCloseTab()` afin que les popups Remote ne lèvent plus `ReferenceError` après le bouton `Fermer`.
- [x] Garder hors périmètre audio, `songStuck` et `organizer/runtime-ready`.
- [x] Couvrir le contrat par `hub_remote_contract_test.php`, `hub_remote_polling_test.mjs`, lint PHP et syntaxe JS ciblée.
- [ ] Recette navigateur dev: Hub Remote -> Remote historique -> bouton bas `Quitter`, vérifier retour Hub Master côté Master, Hub Remote côté téléphone, joueurs déconnectés, relance depuis Hub Remote sans popup `Session introuvable.`, et absence de popup `Action nécessaire` sur Remote déjà autorisée.

## PATCH 2026-07-31 - Hub Canvas: reprise d'exécution ouverte et contexte Hub
- [x] Vérifier les logs rechargés: `hub_execution_context_detected reused=1`, puis `historical_execution_detected role=master` et fallback `hub_execution_unresolved` au chargement Organizer.
- [x] Identifier la cause: les Canvas filtraient l'exécution ouverte avec le timestamp de focus, ce qui casse une reprise qui réactive le focus sur une exécution déjà existante.
- [x] Corriger la règle centrale Global: `app_games_hub_execution_context_get_open(...)` valide le focus par `active_session_id` et ne rejette plus une reprise ouverte par comparaison `started_at < active_session_activated_at`.
- [x] Garder `organizer_canvas.php` et `player_canvas.php` comme consommateurs standards du resolver central, avec exposition de `sessionId` / `executionId` côté Master.
- [x] Couvrir le contrat par `hub_remote_contract_test.php` et `global/web/tests/hub_remote_control_contract_test.php`.
- [ ] Recette navigateur dev: reprise Bingo/Blind Test/Quiz, quit volontaire Master, fin naturelle, Hub Play, Remote et timer runtime; confirmer absence de fallback historique `hub_execution_unresolved`.

## PATCH 2026-07-31 - Hub Remote: retour terminal de la Remote historique
- [x] Auditer le contrat Hub Play existant: contexte `hubPresentation`, `HubTransition` rôle `player`, URL `/hub/{hub_token}/play` et redirection terminale idempotente.
- [x] Identifier la cause du retour Remote raté: la Remote historique n'avait pas de contexte Hub Remote et retombait sur `tryCloseTab()` puis `about:blank`.
- [x] Valider côté `remote_canvas.php` le contexte `hub_remote`: token Remote dédié, session appartenant au Hub, retour strict `/hub/{remote_token}/remote`, aucune exposition du token Master.
- [x] Charger `HubTransition` sur la Remote historique et exposer `AppConfig.hubRemoteReturn`.
- [x] Étendre `HubTransition` au rôle `remote`, avec allowlist `/hub/{token}/remote`, destination `hub_remote` et navigation idempotente.
- [x] Router `HUB_SESSION_FINISHED` et `SESSION_ENDED` de `remote-ws.js` vers Hub Remote quand le contexte validé existe, en gardant le fallback historique hors Hub.
- [x] Modifier `tryCloseTab()` pour revenir au Hub Remote sans `window.close` ni `about:blank` en contexte Hub Remote, tout en conservant le comportement historique hors Hub.
- [x] Couvrir contrat et idempotence par `hub_remote_contract_test.php` et `hub_transition_remote_test.mjs`.
- [ ] Recette navigateur dev par jeu: Quiz, Blind Test et Bingo lancés depuis Hub Remote, fin volontaire/naturelle, reload après fin, absence d'onglet blanc, Remote hors Hub inchangée.

## PATCH 2026-07-31 - Hub Remote: readiness conditionnelle lancement/reprise
- [x] Relire START main, SITEMAP develop, DOCS_MANIFEST et journal AI Studio raw avant patch; aucune entrée AI Studio pertinente Hub Remote/Master/runtime hors workspace local n'a été trouvée.
- [x] Prouver la chronologie réelle: `completed` est persisté côté Games Master juste après `app_games_hub_session_launch_from_master(...)`, avant que le navigateur Organizer ait chargé `/master/{session}?hub_launch=1`.
- [x] Auditer les signaux historiques: `organizer/runtime-ready` est publié après inscription/authentification Organizer et initialisation session Canvas; Quiz/Blind Test rejettent une Remote secondaire si la session WS n'existe pas encore.
- [x] Faire porter à l'URL Organizer les paramètres corrélés `hub_remote_command` et `hub_remote_execution`, sans secret Remote ni payload runtime libre.
- [x] Ajouter l'action Master `remote_launch_readiness`, appelée par l'Organizer après readiness runtime et validée par session Hub, commande et exécution.
- [x] Exposer `readiness`, `transition_type` et `readiness_required` dans `command_status`; attendre readiness pour un nouveau runtime, router directement une reprise d'exécution ouverte.
- [x] Réévaluer le contrat contre Hub Play: conserver focus/exécution comme autorité commune et déplacer la disponibilité durable de `command_id + execution_id` vers `id_hub + session_id + execution_id`.
- [x] Faire consommer à Hub Remote `control_poll.client_routing` pour les reloads, ouvertures tardives, reprises et changements de focus sans commande locale suivie, avec `routing_reason` explicite.
- [x] Couvrir la relance d'une session suspendue: l'Organizer publie la readiness après `organizer/runtime-ready` sans auto-play.
- [x] Réévaluer après logs de reprise: retirer le fallback `session_update` Canvas et conditionner le verrou Remote au type réel de transition.
- [x] Couvrir le contrat par `hub_remote_contract_test.php` et `hub_remote_polling_test.mjs`.
- [ ] Recette navigateur dev par jeu: Quiz, Blind Test et Bingo avec Master + Remote; vérifier lancement neuf avec attente readiness, reprise d'exécution ouverte sans nouveau marqueur et reprise recréée avec nouvelle readiness, puis tester Master fermé, double tap, deux Remotes, deux Masters et réseau coupé.

## PATCH 2026-07-31 - Hub Remote Lot 2: bouton Lancer
- [x] Auditer le chemin réel du bouton Remote: rendu PHP, `data-command-type`, `disabled`, premier `control_poll`, `master_present`, `pendingCommandId`, commandes terminales et réponses hors ordre.
- [x] Identifier la cause exacte: le rendu Remote passait le tableau `app_games_hub_temporal_state(...)` à `games_hub_session_is_organizer_launchable(...)`, qui attend une chaîne `today|open`; le cast `Array` produisait les notices et rendait `available=false`, `disabled` et `data-command-type=""`.
- [x] Corriger la lançabilité Remote avec `games_hub_date_state(...)`, sans changer le contrat serveur `control_poll`, la présence Master, les tokens ou les fréquences.
- [x] Centraliser l'état JS des boutons sur `lastControlState` + `pendingCommandId`, avec interprétation stricte du booléen JSON `master_present === true`.
- [x] Étendre les tests Remote: premier poll Master présent, Master absent, poll en erreur, JSON invalide, commande pending/completed/expired, booléen strict, absence de double boucle et réponse tardive.
- [ ] Recette navigateur dev: QR Remote + Master ouvert, vérifier `Lancer` actif après le premier `control_poll`, puis masquer/réafficher l'onglet, commande expirée et Master absent.

## PATCH 2026-07-31 - Hub Remote Lot 2: lancement par Hub Master
- [x] Relire START main, SITEMAP develop, DOCS_MANIFEST et journal AI Studio raw avant patch; aucun fichier Hub Remote/Master/runtime pertinent hors workspace n'a été trouvé.
- [x] Collecter la baseline des repos `games`, `global`, `pro`, `play`, `bingo.game`, `blindtest`, `quiz`, `documentation`; ne rien reset ni nettoyer.
- [x] Auditer le contrat central Master: route POST Hub Master `action=launch_session`, handler Games, service Global `app_games_hub_session_launch_from_master(...)`, focus Hub, contexte d'exécution, injection papier, réponse `redirect_url` et navigation Organizer.
- [x] Confirmer la convergence Quiz/Blind Test/Bingo derrière le contrat central; aucune branche Bingo ajoutée dans Hub Remote.
- [x] Ajouter les actions Programme dans Hub Remote avec projection PHP: label `Lancer/Reprendre/Relancer/Résultats`, commande disponible, session id, disabled reason, sans dupliquer les règles en JS.
- [x] Faire déposer `launch_session` par Remote uniquement comme commande persistée; aucune URL ni type de jeu n'est fourni par le téléphone.
- [x] Faire exécuter `launch_session` par Hub Master dans `remote_control_poll`: claim atomique, processing, service central, completed/failed, navigation automatique Master.
- [x] Faire naviguer Hub Remote vers la Remote historique uniquement après `completed` et `remote_url` validée same-origin/interne.
- [x] Conserver les garanties Lot 1: timer unique, un seul `control_poll` en vol, double tap neutralisé, `master_ping` inchangé.
- [x] Vérifications locales: lints PHP ciblés, `hub_remote_contract_test.php`, `hub_remote_polling_test.mjs`, `hub_context_fast_path_test.php`, `hub_session_settings_test.php`.
- [ ] Recette navigateur dev par jeu: Master + Remote téléphone, lancement Quiz/Blind/Bingo, double tap, Master absent/hidden, deux Remotes, deux Masters, réseau coupé et commande expirée.

## PATCH 2026-07-31 - Hub Remote Lot 1
- [x] Relire START, SITEMAP, DOCS_MANIFEST, README Games/Global/Pro et journal AI Studio raw avant patch; aucune entrée AI Studio ciblée Hub Remote/Master/Pro n'a signalé un fichier hors workspace à recharger.
- [x] Auditer les logs Games/Global/Pro du 2026-07-31 15:57-16:05: aucun 4xx/5xx ni erreur PHP Remote; POST Remote doublés à la seconde après refresh visible; commandes `master_ping` 1 à 5 créées.
- [x] Identifier la cause exacte des doublons: `visibilitychange` rappelait `poll()` directement, alors que le `setTimeout(poll, ...)` du tick précédent n'était ni stocké ni annulable et que `control_poll` n'avait pas de garde en vol.
- [x] Ajouter la route `/hub/{remote_token}/remote` vers `app_hub_remote_ajax.php`, avec token Remote dédié et session serveur pour les AJAX.
- [x] Rendre une interface mobile read-only bornée: programme, lots, Top 3 initial, présence Master, statut commande et bouton `Tester l’écran Master`.
- [x] Exposer seulement `control_poll`, `master_ping` et `command_status`; aucune action de lancement, navigation Master ou mutation runtime réelle.
- [x] Ajouter côté Hub Master un polling léger `remote_control_poll`, hub-only, qui publie la présence et complète uniquement `master_ping`.
- [x] Borner le polling Remote à une seule boucle active: timer unique enregistré, un seul `control_poll` en vol, refresh visible/`pageshow`/`online` coalescé, backoff réseau, cadence normale après succès, abort `pagehide` et garde `master_ping`.
- [x] Couvrir le contrat route/UI/actions/polling par `games/web/tests/hub_remote_contract_test.php`, les scénarios timer/requête en vol par `games/web/tests/hub_remote_polling_test.mjs`, et conserver `hub_context_fast_path_test.php`.
- [ ] Recette navigateur réelle: QR Dashboard Pro -> Remote mobile, Master ouvert/fermé, onglet Master masqué, ping reçu/expiré, absence de lancement réel.

## PATCH 2026-07-31 - Hub Play probable avant-J et lancement digital
- [x] Relire START, SITEMAP, DOCS_MANIFEST, README Games/Global, schéma DB et journal AI Studio raw avant patch; aucune entrée AI Studio ciblée Hub probable/runtime n'a signalé un fichier hors workspace à recharger.
- [x] Retirer les actions Hub Play `hub_probable_declare` et `hub_probable_cancel`: la matérialisation probable ne se fait plus depuis Hub Play hors fenêtre.
- [x] Ajouter le bloc UI avant-J historique: message “pas encore ouvert” puis bloc compte joueur EP juste dessous.
- [x] Faire transporter au CTA compte joueur avant-J l'intention EP explicite `hub_account_action=probable`; garder `join` pendant la fenêtre ouverte.
- [x] Préserver la fermeture des inscriptions libres avant J: `register_guest` reste gardé par la fenêtre Hub existante.
- [x] Consommer le contrat Global de lancement: papier avec injection des joueurs actifs, numérique sans injection globale et avec création de participation par présence réelle.
- [x] Couvrir le contrat par `games/web/tests/hub_probable_play_contract_test.php`.
- [ ] Recette navigateur: Hub avant-J non connecté, login/signup EP -> page EP Hub, validation/retrait probable, Hub ouvert -> inscription `games_hubs_players`, lancement papier, lancement numérique avec arrivée tardive/reload/QR et reprise manuelle après départ volontaire.

## PATCH 2026-07-31 - Hub Master: prédiagnostic léger du poste
- [x] Relire START, SITEMAP, DOCS_MANIFEST, README Games et journal AI Studio raw avant patch; prédiagnostic Hub Master non trouvé dans la documentation, aucun fichier Games/Hub hors workspace local à recharger.
- [x] Ajouter près du plein écran Hub Master un bouton de diagnostic léger, avec état prêt/vigilance/échec, live region, détail relançable et alerte uniquement en cas d'échec.
- [x] Borner les checks à des signaux fiables hors session: `localStorage`/`sessionStorage`, `navigator.onLine`, profil `navigator.connection` optionnel (`3g` inclus en vigilance) et probes HTTP cache-bustés sur un asset Cotton statique same-origin avec seuils historiques média (`6000ms`, `2200ms`, `2.0 Mb/s`).
- [x] Exclure explicitement les diagnostics historiques Canvas/session/WS/joueur/YouTube/catalogue et préserver `prelaunch_check.js`.
- [x] Garder le diagnostic résistant au refresh partiel Master: le bloc `prizes` remplaçable est recentré sur Lots/QR et l'utilitaire fixe reste hors remplacement.
- [x] Décaler le premier diagnostic après disponibilité du DOM, empêcher `pageshow` de lancer un premier run prématuré, ajouter des recontrôles bornés après chargement complet jusqu'à 9 secondes si l'état reste vert, conserver le pire résultat des mesures Cotton, relancer sur changement du profil de connexion navigateur et garder hors modale uniquement l'icône avec pastille colorée.
- [x] Remplacer le détail en tableau de bord par une synthèse type diagnostic historique: état global, raison principale et un ou deux conseils ciblés, sans libellés techniques visibles (`Profil réseau`, `Services Cotton`, débit reçu).
- [x] Vérifications locales: `php -l web/modules/app_hub_view_helpers.php`, `node web/tests/hub_session_settings_dom_test.mjs`, `php web/tests/hub_session_settings_test.php`, `php web/tests/hub_context_fast_path_test.php`.
- [ ] Recette réelle Hub Master: vérifier bouton, alerte offline, détail manuel, retour online et absence de perturbation plein écran/refresh partiel.

## PATCH 2026-07-31 - Bingo Hub: transition finale visuelle avant retour Hub
- [x] Relire START, SITEMAP, DOCS_MANIFEST, actions canon et README Games avant patch; journal AI Studio raw consulté, sans fichier Bingo/Hub hors workspace local à recharger.
- [x] Auditer le chemin réel de fin Bingo Hub: `phase_over` avec `next_phase=-1`, overlay final Bingo, puis signaux Hub `HUB_SESSION_FINISHED` et gardes Player vers Hub Play.
- [x] Ajouter dans `HubTransition` une transition finale non persistée, par rôle, avec visibilité minimale `8000ms`, deadline `10000ms`, destination Hub mémorisée localement, signaux idempotents et logs bornés.
- [x] Armer la transition uniquement sur Bingo final Hub avant montage de l'overlay: Master numérique, Master papier et Player numérique; exclure explicitement le Player papier.
- [x] Faire passer les retours terminaux Master/Player par `requestTerminalRedirect(...)` et différer les gardes/polling Player pendant la fenêtre visuelle active.
- [x] Vérifier les logs du test dev session `27228`: Master différé environ 4 secondes, mais Players redirigés immédiatement car leur handler `phase_over` ne passait pas par `bingo_ui.js`; correctif ajouté dans `play-ws.js` pour armer la transition Player directement sur `phase_over next_phase=-1`.
- [x] Aligner la durée finale sur l'overlay historique Bingo de 8 secondes et préserver l'UI historique sous-jacente pendant la transition (`HUB_FINAL_VISUAL_HISTORICAL_UI_PRESERVED`) afin d'éviter un écran Master vide.
- [x] Vérifier les logs du test dev session `27229`: fin naturelle Bingo à `11:51:52`, rebuild Hub OK (`updated=3`) et retour Master à `11:52:00`, conforme à la fenêtre de 8 secondes.
- [x] Préserver le rendu Bingo final existant et son auto-hide historique; aucun changement de score, résultat, DB, mapping, focus runtime, Global, WS serveur ou papier Player.
- [x] Vérifications locales: test Hub PHP, test rebuild fin naturelle, test DOM Hub, syntaxe JS ciblée sur `hub_transition.js`, `bingo_ui.js`, `ws_effects.js` et `play-ws.js`.
- [ ] Recette navigateur dev complémentaire: relancer Master Bingo numérique, Player Bingo numérique et Master Bingo papier; confirmer retour Hub après environ 8 secondes, absence d'écran Master vide et absence de `GET /hub/.../play` Player avant la fenêtre visuelle.

## PATCH 2026-07-31 - Player Canvas Hub: transition initiale sans lobby
- [x] Relire START, SITEMAP, DOCS_MANIFEST, README Games et journal AI Studio raw avant patch; aucune entrée AI Studio ne signale un fichier Games/Player Canvas hors workspace local à recharger.
- [x] Auditer le marqueur Hub canonique: `HUB_AUTO_PLAYER.enabled`, exposé seulement après token Hub valide, session rattachée, exécution ouverte, joueur Hub, mapping actif et participation runtime numérique.
- [x] Remplacer côté serveur le contenu initial de `#screen-waiting` par une scène `La partie démarre…` / `Prépare-toi à jouer !` uniquement en contexte Hub Player prouvé.
- [x] Conserver hors Hub le lobby historique complet, dont `Bienvenue`, lots, tips et CTA Blind Test `Former une équipe`.
- [x] Conserver les conteneurs runtime `#screen-running`, `#player-options` et `#bingo-grid`; Quiz/Blind Test/Bingo continuent de remplacer naturellement la transition via `player/state`.
- [x] Vérifier et corriger le layout mobile Hub-only: suppression de l'overflow horizontal par `box-sizing:border-box`, hauteur de transition compacte en `svh`, visuel/header compactés sur faibles hauteurs et spinner compatible `prefers-reduced-motion`.
- [x] Contrôles Playwright fixture: `320x568`, `360x640`, `375x667`, `390x844`, `412x915`, `624x1024`, `667x375`; aucun scroll horizontal, spinner/titre/sous-titre visibles, aucune collision header/barre basse.
- [x] Préserver le contrat de redirection Hub Play, `player_auto_restore`, les mappings, participations, QR, suspension/reprise, WS et jingle: aucun `runtime_started`, `player_redirect_ready`, nouveau signal WS ou contrat Global ajouté.
- [x] Vérifications locales: `php -l web/player_canvas.php`, `php -l web/tests/hub_session_settings_test.php`, `php web/tests/hub_session_settings_test.php`, `node web/tests/hub_session_settings_dom_test.mjs`, fixture Playwright mobile.
- [ ] Recette réelle: lancement initial depuis Hub, arrivée/reload en partie active, suspension puis reprise sans jingle, reconnexion WS, et accès Player hors Hub.

## PATCH 2026-07-31 - Hub Play wording Bingo et chip état
- [x] Remplacer les titres de résultat Bingo gagnant par `Bravo ! 🎉`.
- [x] Adapter les sous-titres Bingo: `Tu remporte le Bingo.`, `Tu remporte la Double ligne.`, `Tu remporte la Ligne.`.
- [x] Garder le cas Bingo sans phase sur `Merci d’avoir joué !` / `On t’attend pour la prochaine !`.
- [x] Corriger la chip header Hub Play: états terminaux en `Terminé`, attente en `En attente`, sans rester figée après ajout de partie post-terminaison.
- [x] Vérifications locales: `php -l web/modules/app_hub_view_helpers.php`, `php web/tests/hub_session_settings_test.php`, `node web/tests/hub_session_settings_dom_test.mjs`, `php web/tests/hub_context_fast_path_test.php`.
- [ ] Recette réelle: ajouter une partie depuis Dashboard Pro après fin/suspension des autres et vérifier la chip Hub Play.

## PATCH 2026-07-31 - Hub Play lots dynamiques
- [x] Auditer le rafraîchissement existant: Hub Master remplace déjà son bloc lots via `preparation_revision`, mais Hub Play ne rendait ses lots qu'au HTML initial.
- [x] Réutiliser le polling Play existant `active_launched_session` / `current_player`, déjà chargé avec `prizes=true`, sans ajouter de timer ni endpoint Dashboard.
- [x] Exposer un payload borné `hub_prizes` côté actions Play.
- [x] Ajouter `renderHubPrizes(...)` pour remplacer uniquement les lignes du bloc `Lots` côté Hub Play.
- [x] Préserver le wording `Lots de la soirée` / `Lots de l’événement`, l'ordre de carte et les règles d'affichage existantes.
- [x] Vérifications locales: `php -l web/modules/app_hub_view_helpers.php`, `php web/tests/hub_session_settings_test.php`, `node web/tests/hub_session_settings_dom_test.mjs`, `php web/tests/hub_context_fast_path_test.php`.
- [ ] Recette réelle: modifier les lots depuis Dashboard Pro après connexion Hub Play et vérifier l'apparition sans reload sur plusieurs mobiles.

## PATCH 2026-07-31 - Hub Play dernier résultat et médaille Master
- [x] Conserver le titre `Dernier résultat` sur le même style que `Classement général` et lots.
- [x] Rendre `jeu · thématique` comme méta secondaire lisible, issue des libellés canoniques déjà transmis à Hub Play.
- [x] Donner le focus visuel à la performance principale sans réintroduire lot, badge podium, score ou rang en pastille.
- [x] Aligner la copie Bingo sur la meilleure phase gagnée (`Bingo`, `Double ligne`, `Ligne`) sans inventer de classement chiffré.
- [x] Auditer la médaille coupée du podium de session Hub Master: la carte photo masquait les débordements et la médaille était dans une zone de contenu recadrée.
- [x] Corriger uniquement le placement/clipping de la médaille: médaille enfant direct de la carte, photo seule recadrée, z-index explicite.
- [x] Vérifications locales: `php -l web/modules/app_hub_view_helpers.php`, `php web/tests/hub_session_settings_test.php`, `node web/tests/hub_session_settings_dom_test.mjs`, `php web/tests/hub_context_fast_path_test.php`.
- [ ] Recette visuelle Hub Play mobile/desktop et Hub Master avec/sans photo pour confirmer l'absence de coupure de médaille.

## PATCH 2026-07-31 - Hub Play photo podium Bingo
- [x] Auditer la structure canonique Bingo: `app_session_results_get_context(...)` lit `bingo_phase_winners`, convertit la phase runtime en ligne de podium avec `rank` numérique et `phase_label`, puis normalise le podium.
- [x] Constater l'écart: Hub Master recevait le `rank` structuré du podium, mais Hub Play ne conservait que `phase_label` dans `games_hub_play_last_result_from_context(...)`; le garde photo refusait donc le résultat avant l'appel d'accès historique.
- [x] Sélectionner pour Hub Play la meilleure ligne Bingo gagnée via le `rank` structuré 1..3, afin de ne proposer qu'un module photo même si plusieurs phases ont été remportées.
- [x] Ne pas dériver l'éligibilité depuis le DOM ni depuis les seules chaînes `BINGO` / `DOUBLE LIGNE` / `LIGNE`; les libellés restent utilisés uniquement pour la copie visible.
- [x] Conserver le rattachement photo à l'identité Hub active, sans changement pour Blind Test, Quiz ou stockage photo.
- [x] Vérifications locales: `php -l web/modules/app_hub_view_helpers.php`, `php web/tests/hub_session_settings_test.php`, `node web/tests/hub_session_settings_dom_test.mjs`, `php web/tests/hub_context_fast_path_test.php`.
- [ ] Recette réelle Bingo: rangs 1/2/3 avec module photo, aucune phase sans module, phases multiples avec un seul module, upload/remplacement visible Hub Play et Hub Master sans confusion d'identité Hub.

## PATCH 2026-07-31 - Hub Play UI auto-routing et photo compacte
- [x] Aligner les titres `Dernier résultat`, `Classement général` et lots sur le même style `h3` en casse normale.
- [x] Réordonner les cartes Play: état identité, dernier résultat, classement général, lots, sortie Hub.
- [x] Expliciter l'auto-connexion dans les états `waiting` et `completed`, sans CTA supplémentaire.
- [x] Préserver les états de départ volontaire et le CTA manuel `Rejoindre à nouveau`.
- [x] Afficher une photo active existante dans une sous-zone compacte avec wording soirée/événement, miniature paysage et CTA `Remplacer la photo`.
- [x] Réserver la grande prévisualisation à la sélection/remplacement avant upload, avec annulation revenant à la photo active.
- [x] Couvrir le contrat par `hub_session_settings_dom_test.mjs`, `hub_session_settings_test.php` et `hub_context_fast_path_test.php`.
- [ ] Recette visuelle mobile 320/375/430: Top 3 sans photo, sélection, upload, reload avec photo, remplacement, joueur avec photo hors Top 3 agrégé, soirée/événement.

## PATCH 2026-07-31 - Hub photo podium active par identité
- [x] Auditer `player_podium_photo_access_get`, `player_podium_photo_upload`, `app_session_results_player_podium_photo_access_get(...)`, `app_session_results_podium_photo_upload(...)`, le stockage `medias_images`, la résolution photo des podiums Hub et le mapping `games_hubs_players_sessions`.
- [x] Constater que le stockage historique est par session/rang/ligne podium et qu'aucun champ existant de `games_hubs_players` ne permet une photo active unique par identité Hub.
- [x] Ajouter la migration minimale `2026-07-31_games_hubs_players_active_podium_photo.sql` pour rattacher une photo active à `games_hubs_players`, sans backfill ni recopie des anciennes photos.
- [x] Ajouter côté Global le resolver actif `app_games_hub_player_active_photo_get(...)`, l'enrichissement des podiums de session Hub et l'upload Hub Play avec traitement image historique 900x900/90.
- [x] Câbler Hub Play pour lire/remplacer la photo active Hub après preuve session Hub + mapping identité + rang Top 3, sans appeler `app_session_results_podium_photo_upload(...)` en contexte Hub.
- [x] Câbler Hub Master pour enrichir les podiums de sessions terminées depuis l'identité Hub, en gardant le résultat runtime comme source des rangs/scores.
- [x] Faire changer la révision Hub après upload photo et réduire le polling visible Master pour actualiser le bloc central sans refresh manuel.
- [x] Couvrir le contrat par tests source: migration non destructive, stockage sur `games_hubs_players.id`, refus non Top 3, consentement historique, absence de photo par session, lecture par resolver Hub.
- [ ] Import SQL dev et recette réelle: première photo, remplacement après autre session, reload Hub Play, podium session, podium agrégé, solo, équipe, refus rang >3, refus session hors Hub, séparation de deux identités Hub.

## PATCH 2026-07-30 - Hub Play: finition état, résultat et photo podium
- [x] Simplifier le bloc état: pseudo, une seule formulation normale `La soirée est terminée 🎉` / `L’événement est terminé 🎉`, complément en paragraphe distinct, CTA manuel conservé.
- [x] Simplifier le dernier résultat: jeu + thématique en méta, copie canonique titre/sous-titre, sans badge podium, score, rang en pastille ni lot répété.
- [x] Ajouter une adaptation Hub Play du module photo podium historique, bornée aux rangs 1 à 3; l'écriture backend est remplacée le 2026-07-31 par la photo active `games_hubs_players`.
- [x] Garder inchangés auto-routing, départ volontaire, reprise manuelle, chargement Global, bloc Lots, classement général et CTA Quitter.
- [x] Vérifications locales: lint PHP, tests Hub fast-path/aggregate/session settings/DOM.
- [ ] Recette visuelle mobile 320/375/430 et desktop: hors podium sans module photo, rangs 1/2/3 avec module, photo déjà présente -> `Remplacer la photo`, wording soirée/événement et lots inchangés.

## PATCH 2026-07-30 - Hub Play: UI fusion et classement Global
- [x] Relire START, SITEMAP, DOCS_MANIFEST, README Games et journal AI Studio raw avant patch; aucune entrée AI Studio récente ne signale un fichier Hub Play hors workspace local à recharger.
- [x] Auditer le chemin Hub Play: `app_hub_play_ajax.php`, `app_hub_view_helpers.php`, le composant fin de partie `play-ui.js::renderEndCard()` et les helpers Global Hub.
- [x] Fusionner identité joueur et état courant dans le premier panneau Play, retirer le bloc séparé `Reprise`, conserver uniquement la reprise manuelle après départ volontaire.
- [x] Charger pour `current_player` et `active_launched_session` les lots, résultats de session et `aggregate_context` nécessaires au dernier résultat et au classement général.
- [x] Afficher le dernier résultat avec une copie alignée sur l'écran final Player Canvas, sans recalculer les résultats, et exposer le lot Hub associé quand il existe.
- [x] Afficher le classement général depuis `aggregate_context.aggregate_ranking` en sélectionnant Top 3, joueur courant et voisins, sans recalcul local des scores/rangs/tie-breakers.
- [x] Auditer le contrat photo: seul le contrat podium de session existe (`player_podium_photo_access_get` / `player_podium_photo_upload`); aucun contrat photo identité Hub active n'a été ajouté.
- [x] Vérifications locales: lint PHP helper/test, `hub_context_fast_path_test.php`, `hub_compact_aggregate_test.php`.
- [ ] Recette navigateur authentifiée: inscription Hub Play, lancement Quiz/Blind Test/Bingo, départ volontaire puis retour Play sans auto-rejoin, reprise manuelle, dernier résultat avec lot, classement général après stats Global alimentées.

## PATCH 2026-07-30 - Hub Master: contexte Global Hub léger
- [x] Remplacer le chargement agrégé historique période/événement par `app_games_hub_render_context_get(...)` quand Games dispose du Hub explicite.
- [x] Passer les sessions déjà chargées au helper Global Hub pour éviter une seconde lecture du programme.
- [x] Conserver le rendu Master consommateur du contrat `aggregate_context.aggregate_ranking`, sans tri ni fallback local.
- [x] Conserver l'instrumentation reload et journaliser source, raison de fallback, temps de lecture projection et éventuel coût de fallback historique.
- [x] Renommer la phase mesurée en `global_hub_context` pour distinguer le nouveau helper de l'ancien coût `historical_global_context`.
- [x] Couvrir que le contexte complet Games appelle le helper Global Hub et ne charge plus l'agrégat historique par période.
- [ ] Recette dev: reload complet Hub Master avec projection saine, vérifier `aggregate_ranking_source=hub_persistent_stats`, `historical_fallback_used=0` et disparition du coût médian `historical_global_context`.

## DIAG 2026-07-30 - Hub Master: profil reload complet avant bascule stats persistées
- [x] Relire START, SITEMAP, DOCS_MANIFEST, README Games/Global et journal AI Studio raw avant intervention; aucune entrée AI Studio ciblée ne signale `hub_players_stats`, `games_hubs_players`, `app_hub_view_helpers.php` ou Hub Master hors workspace local.
- [x] Auditer le reload complet Master: `games_hub_get_context_from_request(...)` charge Hub, client, programme, branding, lots, événements de complétion, résultats des sessions terminées puis contexte historique Global via event/période.
- [x] Auditer le rendu Master: `games_hub_general_ranking_from_aggregate_context(...)` consomme `aggregate_ranking` ou reconstruit depuis `leaderboards`, puis `games_hub_presentation_state_resolve(...)` produit le podium agrégé sans modifier le podium de dernière session.
- [x] Auditer le lecteur persistant Global `app_games_hub_players_stats_ranking_get(...)`: lecture unique `games_hubs_players`, rang dense par `stats_aggregate_score|stats_parties_count`, ordre score, parties, récence, pseudo, et signal `fresh=false` sur dirty/error.
- [x] Ajouter une instrumentation dev-only des reloads complets Master, loggée sous `hub_master_full_reload_profile`, sans token, cookie, IP, user-agent ou nom joueur.
- [x] Mesurer par phases: bootstrap Hub, client, programme, branding, lots, événements de complétion, résultats sessions, contexte historique Global, projection ranking, podium agrégé, joueurs live et assemblage final.
- [ ] Collecter plusieurs reloads complets sur le même Hub dev et comparer la médiane de `historical_global_context` au total avant tout patch fonctionnel.
- [x] Bascule bornée Hub Master vers le producteur Global `aggregate_ranking` avec source persistée préférée quand `id_hub` explicite est transmis.

## PATCH 2026-07-30 - Hub: rebuild stats players sur fin naturelle
- [x] Relire START, SITEMAP, DOCS_MANIFEST et le journal AI Studio raw avant patch; aucune entrée AI Studio récente ne signale `hub_players_stats`, `games_hubs_players` ou le callback Canvas hors workspace local.
- [x] Auditer le chemin réel `hub_session_natural_ended`: session Hub prouvée, résultat terminal écrit, clear focus gardé, finalisation idempotente `hub_execution_completed`.
- [x] Brancher après finalisation métier le rebuild persistant `app_games_hub_players_stats_rebuild(..., dry_run=false, write=true)` sans modifier la réponse visible du callback.
- [x] Exclure les sessions démo, journaliser start/end/error avec méta bornée, et utiliser `app_games_hub_players_stats_mark_dirty(...)` sur échec ou résultats runtime incomplets.
- [x] Couvrir hors Hub, démo, résultats non finaux, succès, erreur masquée, dirty/error, replay et moteurs Quiz/Blind Test/Bingo dans `hub_natural_end_stats_rebuild_test.php`.
- [ ] Recette dev authentifiée: finir naturellement un Hub Quiz, Blind Test et Bingo, vérifier logs `hub_players_stats_rebuild_*`, colonnes `games_hubs_players.stats_*`, replay idempotent et absence d'impact sur session démo.

## PATCH 2026-07-30 - Migration stats Hub players
- [x] Ajouter la migration autonome `web/includes/canvas/sql/2026-07-30_games_hubs_players_stats_projection.sql`.
- [x] Conserver un import manuel phpMyAdmin: pas de `USE`, pas d'exécution par Codex, pas de donnée environnementale.
- [x] Ajouter les requêtes de contrôle avant/après et des DDL idempotents via `INFORMATION_SCHEMA`.
- [ ] Recette post-import: confirmer les dix colonnes `stats_*`, puis laisser Global exécuter dry-run/write bornés.

## PATCH 2026-07-29 - Canvas runtime: réhydratation compteurs actifs
- [x] Relire START, SITEMAP, DOCS_MANIFEST, carte Games, interfaces Canvas et journal AI Studio raw avant patch; aucune entrée AI Studio récente ne signale `canvas_display.js`, `players_get` ou `score_store` hors workspace à recharger.
- [x] Corriger `canvas_display.js` pour que les réhydratations runtime actives (`session/init`, `game/started`, `game/paused`, retour mobile organizer) n'envoient plus systématiquement `includeInactive=1`.
- [x] Centraliser la décision: `includeInactive` est ajouté seulement si l'état front est terminal (`Partie terminée` / `Terminé`) ou si la phase Bingo front est terminale (`-1`, `4`, `>5`).
- [x] Préserver les endpoints PHP, les WebSockets, les résultats finaux et la capacité historique d'appeler `players_get` avec inactifs en contexte terminal.
- [x] Couvrir Quiz, Blind Test et Bingo dans `hub_session_settings_dom_test.mjs`: payload runtime actif sans `includeInactive`, payload terminal avec `includeInactive`, phases Bingo terminales.
- [ ] Recette navigateur authentifiée: Blind Test puis Quiz/Bingo avec deux joueurs, départ volontaire, start/pause/reprise/retour mobile, fin de session et résultats historiques.

## PATCH 2026-07-29 - Hub: contextes allégés et fast-paths AJAX
- [x] Ajouter des options de chargement à `games_hub_get_context_from_request(...)` pour éviter les blocs coûteux quand une action ne les utilise pas.
- [x] Router les actions AJAX légères via `games_hub_get_context_for_action_from_request(...)`.
- [x] Ajouter `games_hub_get_initial_play_context_from_request()` pour le GET initial Hub Play sans résultats complets, completion events, agrégat Master ni quick-add games.
- [x] Éviter le calcul `app_games_hub_players_count_active(...)` avant `launch_session`.
- [x] Journaliser le profil borné `hub_launch_session_profile` quand Global fournit `_hub_launch_profile`, puis retirer cette clé privée du JSON.
- [x] Couvrir les profils de contexte dans `hub_context_fast_path_test.php`.
- [x] Couvrir la projection compacte via `hub_compact_aggregate_test.php`.
- [ ] Recette navigateur/performance authentifiée: mesurer GET Play, POST légers Hub Play/Master, lancement Master et retour Master.

## PATCH 2026-07-29 - Hub Play: clôture reprise QR Player
- [x] Relire START, SITEMAP, DOCS_MANIFEST, carte Games et journal AI Studio raw avant patch; aucune entrée AI Studio récente ne signale un fichier Games/Hub/Player Canvas hors workspace à recharger.
- [x] Retirer l'instrumentation temporaire `__hubRestore*`, `[HUB_RESTORE_PERF]`, marqueurs bootstrap/imports/modules, jalons WS/register/release/presentation sync et sorties console de diagnostic.
- [x] Préserver les correctifs fonctionnels du lot: anti-flash `player_auto_restore`, release/fallback `HubTransition`, priorité auto-restore Hub, fast path serveur, reprise Bingo, `hubPlayUrl`, `leave_session` attendu, `leftVoluntarily` et `location.replace`.
- [x] Auditer le 500 isolé `Global config $conf manquante ou invalide`: requêtes identiques en 200 avant/après, échec avant code Hub; ajouter seulement un diagnostic structuré non sensible avant de relancer la même exception.
- [x] Auditer le polling résiduel Player Canvas: timer unique sans overlap, mais démarrage trop précoce et intervalle 4 secondes vers le resolver Hub complet.
- [x] Démarrer le polling Hub Presentation après `player/ready`, garder focus/pageshow, passer l'intervalle fallback à 15 secondes sans retirer la résilience.
- [x] Couvrir les contrats dans `hub_session_settings_test.php`.
- [x] Vérifications locales: lints PHP/JS ciblés OK; test Hub PHP OK; recherche runtime sans marqueurs perf temporaires OK.

## PATCH 2026-07-29 - Hub Play: retour après départ volontaire Player
- [x] Relire START, SITEMAP, DOCS_MANIFEST, carte Games et journal AI Studio raw avant patch; aucune entrée AI Studio récente ne signale un fichier Games/Hub/Player Canvas hors workspace à recharger.
- [x] Lire les logs `games/logs` et `global/logs` du nouveau test: ancienne session `27166` OK avec `leave_session` puis mapping `left`; nouveau test session `27167` boucle en `mapping_found status=active` et auto-redirection, sans `hub_session_left_mapping_updated`.
- [x] Auditer le chemin réel de sortie Player: confirmation bouton, WS `quitGame`, POST Hub `leave_session`, nettoyage local, puis redirection.
- [x] Identifier la cause: le départ Hub volontaire utilisait `sendBeacon` sans confirmation serveur et passait par le nettoyage historique car la préservation Hub était réservée à `serverEnded`.
- [x] Exposer dans `HUB_AUTO_PLAYER` l'URL Hub Play canonique validée serveur, attendre le JSON `ok:true` de `leave_session`, préserver identité Hub/session locale, écrire `leftVoluntarily_{sessionId}=1`, puis revenir en `location.replace(...)` vers Hub Play.
- [x] Préserver les parcours non Hub et les fins orchestrées serveur; aucun changement papier, score, rang, lot, Hub Remote ou réactivation implicite.
- [x] Couvrir le contrat dans `hub_session_settings_test.php`.

## PATCH 2026-07-29 - Hub Play: release auto-restore avant reprise locale Quiz/Blind Test
- [x] Lire les nouveaux logs `games/logs` et `global/logs` du test 11:16-11:17.
- [x] Confirmer côté serveur que le QR Blind Test passe par le fast path: mapping actif, participation existante, `hub_session_qr_resume_existing_mapping_fast_path`, `hub_session_qr_resume_auto_player_exposed`.
- [x] Identifier la cause probable du délai restant: la branche locale `existingId` Quiz/Blind Test pouvait retourner avant le binding submit et court-circuiter l'auto-restore Hub différée, laissant le masque attendre le timeout de 9 secondes.
- [x] Aligner Quiz/Blind Test sur la protection déjà présente côté Bingo: quand un mapping Hub auto actif est prouvé, ne pas prendre la reprise locale historique avant l'auto-register Hub.
- [x] Couvrir le contrat dans `hub_session_settings_test.php`.

## DIAG 2026-07-29 - Hub Play: instrumentation front reprise QR Player
- [x] Relire START, SITEMAP, DOCS_MANIFEST, carte Games et journal AI Studio raw avant patch; aucune entrée AI Studio récente ne signale un fichier Games/Hub/Player Canvas hors workspace à recharger.
- [x] A ajouté une instrumentation temporaire `window.__hubRestorePerf`, ensuite retirée lors de la clôture du lot, active uniquement pendant le diagnostic sous `data-hub-transition-pending="player_auto_restore"` prouvé côté serveur.
- [x] A marqué pendant le diagnostic bootstrap HTML, bloc d'imports statiques, début/fin des modules `play-ws`, `play-ui`, `register`, boot Hub Presentation Sync, WS, auto-restauration, `player/ready`, `releasePending`, frame visible et chemins Bingo `grid_hydrate` / `grid_assign`.
- [x] Pendant le diagnostic, n'a journalisé aucun token, cookie, nom joueur ou identifiant complet dans les détails `[HUB_RESTORE_PERF]`; les détails étaient limités à des statuts, booléens et raisons bornées.
- [x] Auditer sans réordonner: `play-ui.js` consomme `PlayerAPI` depuis `play-ws.js` et installe le listener `player/ready`; `play-ws.js` installe aussi `player/ready`, `session/set`, le boot WS et `bootHubPresentationSync()`.
- [x] Vérifications locales: lint PHP Player OK; syntaxe JS `hub_transition.js`, `play-ws.js`, `play-ui.js`, `register.js` OK en mode ESM.
- [x] Instrumentation retirée lors de la clôture du lot du 2026-07-29; ne pas considérer `window.__hubRestorePerf` / `[HUB_RESTORE_PERF]` comme actifs.

## PATCH 2026-07-29 - Hub Play: reprise rapide QR session Player numérique
- [x] Relire START, SITEMAP, DOCS_MANIFEST, carte Games et journal AI Studio raw avant patch; aucune entrée AI Studio récente ne signale un fichier Games/Hub/Player Canvas hors workspace à recharger.
- [x] Réduire le chemin serveur QR/session quand le mapping Hub/session est déjà complet: Hub/joueur/session/exécution ouverts, mapping actif session courante, participation runtime existante, participant canonique `p:*`, numérique et non manuel.
- [x] Conserver `app_games_hub_runtime_participation_ensure(...)` comme fallback canonique pour les mappings incomplets, papier, `left`, manuels, sans participation ou non canoniques.
- [x] Ajouter pour Bingo une reprise directe avant submit historique: persistance identité Hub, `grid_hydrate`, `grid_assign` uniquement sur `GRID_NOT_FOUND`, état inscrit et émission `player/ready`.
- [x] Garder le submit historique comme fallback si la reprise Bingo échoue, sans modifier Quiz/Blind Test hors chemin déjà direct.
- [x] Couvrir les contrats dans `hub_session_settings_test.php`.
- [x] Vérifications locales: lints PHP/JS ciblés OK; test Hub PHP OK.

## PATCH 2026-07-29 - Hub Play: suppression flash lobby Player numérique
- [x] Relire START, SITEMAP, DOCS_MANIFEST, carte Games et journal AI Studio raw avant patch; aucune entrée AI Studio récente ne signale un fichier Games/Hub/Player Canvas hors workspace à recharger.
- [x] Auditer le parcours réel Hub Play -> Player Canvas: validation Hub/session/exécution ouverte, mapping actif, participation runtime numérique, exposition `HUB_AUTO_PLAYER`, puis auto-register `register.js`.
- [x] Armer `data-hub-transition-pending="player_auto_restore"` côté `player_canvas.php` uniquement après preuve serveur complète d'un joueur Hub numérique autorisé à rejoindre la session focus.
- [x] Ajouter un CSS critique qui masque le lobby/register historique pendant ce bootstrap, sans changer l'UI Hub Play générale ni les lobbies historiques hors auto-restore Hub.
- [x] Étendre `hub_transition.js` avec `releasePending(...)` et `armPendingTimeout(...)`, tout en conservant l'API Master `releaseLaunch()`.
- [x] Relâcher le masque dans `register.js` seulement après état inscrit et `player/ready`, y compris Bingo après grille; fallback explicite sur mapping invalide, départ volontaire, payload invalide, erreur et timeout.
- [x] Conserver hors scope DB, règles de participation, sessions papier, Hub Remote, scores, rangs, lots, moteur runtime, routage Hub Play non focus et participations probables.
- [x] Couvrir les contrats dans `hub_session_settings_test.php`.
- [x] Vérifications locales: lint PHP Player/test OK; syntaxe JS `hub_transition.js` et `register.js` ESM OK; test Hub PHP OK.

## PATCH 2026-07-28 - Hub Master: retrait preview photos podium agrégé
- [x] Retirer le mode local/dev `preview_podium_photos=all|none|partial|broken` maintenant que la validation visuelle du podium agrégé est faite.
- [x] Supprimer les helpers de fixtures `games_hub_preview_podium_photo_*` / `games_hub_apply_preview_podium_photos`, la lecture de `$_GET['preview_podium_photos']` et l'injection `dev_preview`.
- [x] Supprimer les trois assets temporaires `photo-1.jpg`, `photo-2.jpg`, `photo-3.jpg` du dossier Hub.
- [x] Conserver la consommation des photos réelles `photo_src` / `photo_url`, le fallback texte, le fallback image cassée, les plaques et les statistiques du podium agrégé.
- [x] Couvrir l'absence du mode preview dans `hub_session_settings_test.php`.

## PATCH 2026-07-28 - Hub Master: rollback plein écran et podiums de session réduits
- [x] Relire START, SITEMAP.txt, SITEMAP.ndjson, DOCS_MANIFEST, carte Games et journal AI Studio raw avant audit; aucune entrée AI Studio récente ne signale un fichier Games/Hub hors workspace à recharger.
- [x] Auditer le parcours réel: Hub Master POST `launch_session` ou lien de reprise, navigation même onglet vers `/master/{session}?hub_launch=1`, autostart organizer via `boot_organizer.js`, retour Hub via `HubTransition`/`hubOrganizer.masterUrl`.
- [x] Annuler entièrement la tentative de continuité plein écran Hub Master -> organizer: plus de `sessionStorage` `hub_fullscreen_intent` ou `hub_fullscreen_return_intent`, plus de writer Hub, reader organizer, TTL, helper exporté, hook boot ni CTA `Continuer en plein écran`.
- [x] Préserver les contrôles historiques de plein écran manuel Hub Master et organizer, `hub_launch=1`, l'autostart Hub organizer, `HubTransition`, ainsi que les routes lancement/reprise/relance.
- [x] Harmoniser le podium de session central Hub Master uniquement: médailles rondes or/argent/bronze, cartes sobres, ordre `2-1-3`, rang 1 modérément dominant, labels accessibles, sans changer rangs/scores/égalités/source/cap trois cartes ni podium agrégé.
- [x] Réduire la hauteur des cartes de session sans scale global ni déplacement du carrousel: cartes normales `94% -> 82%`, rang 1 `100% -> 90%`, photos `168px -> 146px`, médaille `52px -> 47px`, gap titre/podium `margin-top: clamp(20px, 4.5cqh, 34px)`.
- [x] Couvrir le contrat dans `hub_session_settings_test.php` et `hub_session_settings_dom_test.mjs`.

## PATCH 2026-07-28 - Hub Master: podium agrégé Bravo et photos réelles
- [x] Relire START, SITEMAP, DOCS_MANIFEST, carte Games et journal AI Studio raw avant audit; aucune entrée AI Studio récente `games`, `Hub Master` ou `podium` ne signale un fichier hors workspace local à recharger.
- [x] Remplacer le header de la modale de podium agrégé par `Bravo !` et `Podium général après X partie(s)`, sans suffixe `jouée(s)`, en conservant le bouton latéral stable `Podium`.
- [x] Préparer le contrat interne `photo_url` / `photo_src` par entrée de podium sans migration DB ni récupération Hub Play.
- [x] Afficher les photos en cercle `object-fit: cover`, basculer sur le fallback texte en cas d'erreur image, et garder le rendu sans photo avec nom dans le cercle.
- [x] Corriger le clipping photo: wrapper portrait non clippant pour médaille/badge, disque interne `overflow:hidden`, image absolue `inset:0`, `object-fit:cover`, `border-radius:50%`, sans padding/marge interne.
- [x] Déplacer le nom sur la plaque uniquement quand une photo occupe le cercle; afficher la statistique principale `victoires · podiums`, sans lot dans les plaques du podium général.
- [x] Resserrer le `padding-inline` des plaques hybrides et masquer le bouton utilitaire `Podium` quand l'overlay est déjà affiché, puisque la fermeture reste portée par le CTA de l'image.
- [x] Afficher une ligne `partie(s)` seulement quand deux entrées Top 3 ont mêmes victoires/podiums, même score et participations différentes, donc quand le `count` canonique peut expliquer l'ordre sans recalculer le classement.
- [x] Couvrir photos réelles, absence de photo, image invalide, absence de lots, participation utile et absence de participation inutile dans les tests Hub.
- [x] Vérifications locales: lint PHP helper/test OK; tests Hub PHP et DOM Node OK.

## PATCH 2026-07-28 - Hub Master: selection auto Programme et ajout rapide
- [x] Relire START, SITEMAP, DOCS_MANIFEST, carte Games et journal AI Studio raw avant audit; aucune entrée AI Studio récente ne signale un fichier Hub Master hors workspace à recharger.
- [x] Auditer le resolver `games_hub_master_presentation_selection_resolve(...)`, l'initialisation carrousel, la restauration de sélection après `preparation_revision` et le succès `quick_session_create`.
- [x] Corriger la priorité automatique générale: focus runtime Hub confirmé, première session prête/non jouée par position Programme persistante, première suspendue reprenable par position Programme, dernière terminée seulement s'il ne reste aucune prête/suspendue, puis première session métier.
- [x] Conserver le cas événementiel de fin naturelle comme preuve de session terminée pertinente uniquement quand il n'existe plus de session prête/suspendue en résolution générale.
- [x] Corriger la régression restante de fin naturelle: restaurer le chemin fonctionnel precedent en faisant primer les `completion_events` canoniques uniquement quand le GET Hub Master revient du canvas organisateur `/master/...hub_launch=1`.
- [x] Figer l'ordre DOM du carrousel Master sur le Programme canonique: `championnats_sessions.position` croissante, puis `id`/index comme garde deterministe; aucun tri par statut, heure, fin naturelle, focus, recence ou selection.
- [x] Garder `Ajouter une partie` hors tri metier et toujours apres les sessions; apres ajout rapide, selectionner/scroller la nouvelle carte a sa position canonique sans la deplacer.
- [x] Annuler le fallback serveur borné ajouté ensuite: pas de `natural_completion_session_id`, pas de `natural_completion_marked_at`, pas de consommation 15 minutes, pas de parametres URL de presentation.
- [x] Faire survivre la session terminee aux refreshs `preparation_revision` par la selection courante du carrousel tant qu'aucun evenement explicite ne la remplace, sans recréer `active_session_id`.
- [x] Supprimer la redirection directe Remote -> Hub Master sur `HUB_SESSION_FINISHED`; la Remote ne doit pas ouvrir de seconde page Master et attendra le futur Hub Remote.
- [x] Après ajout rapide, lire `session_ids[0]`, rafraîchir le Programme avec `preferredSessionId`, sélectionner la nouvelle carte, fermer la modale seulement apres confirmation visuelle et revenir en présentation `session` sans écrire `active_session_id` ni lancer la partie.
- [x] Ajuster l'UX d'ajout rapide: garder la modale ouverte en chargement jusqu'a confirmation DOM de la carte creee, selectionnee, avant `Ajouter une partie`; en cas de creation OK mais refresh/carte absente, afficher une erreur de synchronisation avec retry de refresh uniquement, sans doublon de creation ni `location.reload()`.
- [x] Autoriser les remplacements attendus de sélection événementielle: clic manuel, lancement/reprise réelle, ajout rapide, podium agrégé ou disparition de la carte.
- [x] Préserver la restauration de sélection manuelle sur refresh sans intention; si la session préférée issue de l'ajout rapide est absente du DOM, laisser le fallback serveur sûr au lieu de restaurer l'ancienne sélection.
- [x] Ne pas modifier podiums, résultats, classements agrégés, focus runtime, routage Hub Play/joueurs, ordre persistant du Programme ni calculs de lots.
- [x] Vérifications locales: lint PHP helper/test OK; syntaxe JS `hub_transition.js` OK; tests Hub PHP et DOM Node OK; `git diff --check` Games OK.

## PATCH 2026-07-28 - Hub Master: termine mais reactivable
- [x] Auditer le Hub Master: les compteurs/listes utilisent deja le rattachement canonique `games_hubs_sessions` via `app_games_hub_sessions_get(...)`.
- [x] Distinguer l'etat courant `Termine` de la fenetre de reactivation: un Hub dont toutes les sessions membres courantes sont terminees peut encore accepter une partie jusqu'a `J+1 12:00` Europe/Paris.
- [x] Masquer/refuser l'ajout rapide uniquement quand `hub_temporal_state.launch_window_open=false`, pas parce que le programme est termine.
- [x] Ne plus afficher la carte Programme `Ajouter une partie` du Hub Master quand le Hub est cloture/expire.
- [x] Ajouter une garde serveur Master avant l'appel au service Global, avec JSON `409` et code `HUB_QUICK_ADD_WINDOW_EXPIRED` apres cutoff.
- [x] Conserver les sessions, resultats, podiums, focus, scores, rangs, joueurs, lots et memberships existants.
- [x] Couvrir le contrat dans `hub_session_settings_test.php`.

## PATCH 2026-07-28 - Hub Master/Play: fenetre J+1 midi
- [x] Aligner `games_hub_date_state(...)` sur la primitive temporelle serveur: hier avant midi reste ouvert, `J+1 12:00:00` expire.
- [x] Exposer `hub_temporal_state`, `cutoff_at` et `timezone` dans le contexte/rendu Hub.
- [x] Garder les actions sensibles cote serveur: launch Master via Global, register Play refuse apres cutoff sauf session deja engagee.
- [x] Ajouter `timezone`, `cutoff_at`, `launch_window_open` et `temporal_state` dans `ServerSessionMeta` Canvas.
- [x] Faire utiliser la meta serveur par Organizer/prelaunch avant tout fallback local, sans fuseau navigateur.
- [x] Couvrir le contrat dans `hub_session_settings_test.php` et conserver les podiums/resultats de session hors scope.

## PATCH 2026-07-28 — Hub agrégat: affichage podiums hors victoires
- [x] Consommer `display_podium_count` pour les stats visibles du classement général et du podium agrégé.
- [x] Centraliser le fallback ancien payload dans `games_hub_aggregate_display_podium_count(...)` avec `max(0, podiums - wins)`.
- [x] Aligner le nouveau payload Global: `podiums`/`podiums_count` excluent les victoires, `top3_count` conserve le diagnostic Top 3.
- [x] Masquer les segments statistiques a zero en conservant l'ordre `victoires · podiums · parties` en libellé long, avec `part.` conservé en compact.
- [x] Consommer le contrat d'identité agrégée Global sans fusion locale par pseudo: joueur Play/Global fiable, Hub-local distinct par Hub, équipes Blind Test distinctes.
- [x] Couvrir les cas victoire seule, deuxième/troisième place, victoire + podium, deux victoires, participation seule, ancien payload, joueur, équipe, classement général et podium agrégé.
- [x] Ne pas modifier les podiums de session, scores, rangs, tri, focus ou rendu global hors chaîne statistique.
- [x] Vérifications locales: lint PHP helper OK; test Hub PHP OK; test DOM Hub OK.

## PATCH 2026-07-28 — Hub agrégat: logs attendus vs indisponibles
- [x] Relire START, SITEMAP, DOCS_MANIFEST et le journal AI Studio raw avant patch; aucune entrée AI Studio récente ne signale une modification hors workspace du helper Hub Games ciblé.
- [x] Reprendre la recette logs `2026-07-28 08:44-08:47`: les `unavailable` du Hub `183` cessent à la bascule fin naturelle/agrégat chargé, puis seuls les `loaded` persistent.
- [x] Distinguer explicitement `should_load_aggregate=false` de l'anomalie `should_load_aggregate=true` mais agrégat vide.
- [x] Rendre silencieux l'état nominal avant première session terminée: aucun `hub_aggregate_ranking_unavailable` quand `completed_sessions=0` et `finished_results_count=0`.
- [x] Conserver `hub_aggregate_ranking_loaded` pour diagnostic debug-only et `hub_aggregate_ranking_unavailable` uniquement comme signal d'agrégat attendu mais absent.
- [x] Couvrir les états avant fin, attendu+disponible, attendu+absent et bascule post-fin dans `hub_session_settings_test.php`.
- [x] Vérifications locales: lint PHP helper/test OK; test Hub PHP OK.
- [ ] Recette logs authentifiée: rejouer un Hub complet et confirmer silence agrégat avant fin, puis `loaded` uniquement en debug et aucun retour `unavailable` après podium.

## PATCH 2026-07-28 — Hub routes endpoint canonique
- [x] Relire START, SITEMAP, DOCS_MANIFEST et le journal AI Studio raw avant patch.
- [x] Confirmer que les polls `/hub/{token}/master|play` passaient par `games/web/global_ajax.php` via `.htaccess`, déclenchant `deprecated_alias_used` à chaque requête.
- [x] Migrer uniquement les routes Hub Master/Play vers `games_ajax.php`, sans supprimer l'alias historique ni modifier les routes remote/play/master legacy.
- [x] Ajouter des assertions dans `hub_session_settings_test.php` garantissant que les routes Hub ne ciblent plus l'alias.
- [x] Vérifications locales: lint PHP ciblé OK; tests Hub PHP/DOM OK; recherche finale routes Hub -> alias OK; `git diff --check` Games OK.
- [ ] Recette navigateur authentifiée: cycle polling Hub Master/Play et actions launch/settings/quick add sans nouveau log `deprecated_alias_used`.

## PATCH 2026-07-27 — Hub Master: composition visuelle du podium agrégé
- [x] Consulter les RAW obligatoires avant patch: START, SITEMAP, DOCS_MANIFEST et journal AI Studio raw. Le journal AI Studio ne contient pas d'occurrence explicite `podium`, `hub master` ou `app_hub` dans la version récupérée localement.
- [x] Identifier les fichiers réellement utilisés par l'overlay agrégé: `games/web/modules/app_hub_view_helpers.php` pour helpers/rendu/CSS/JS, `games/web/tests/hub_session_settings_test.php` et `games/web/tests/hub_session_settings_dom_test.mjs` pour le contrat source.
- [x] Appliquer le rectificatif canonique: le classement agrégé et ses rangs denses sont produits par Global (`aggregate_ranking`), Games les consomme sans recalculer l'agrégat.
- [x] Corriger la régression nouveau Hub: charger le contexte agrégé dès qu'une session terminée a un podium exploitable, même si `completion_events` est encore vide.
- [x] Distinguer en tests les états `aggregate_ranking` absent, présent vide avec leaderboards sources, présent vide sans sources, et présent renseigné.
- [x] Conserver les victoires/podiums, l'association des lots par rang dense, les règles d'ouverture/fermeture, le podium de session, le classement général latéral et le fallback historique asset absent.
- [x] Stabiliser le titre visible du podium agrégé à `Podium`; garder le sous-titre métier `Classement général après X partie(s) jouée(s)`.
- [x] Corriger le fallback identité de la branche hybride trois gagnants: photo valide centrée en cercle; sinon pseudo/nom d'équipe complet sur deux lignes maximum, sans initiale seule.
- [x] Ajouter un retour propre des images cassées vers le fallback texte, sans afficher d'image brisée.
- [x] Réserver le cercle à l'identité et la plaque au résultat/lot; les plaques hybrides ne répètent plus systématiquement le pseudo.
- [x] Projeter les rangs denses `1`, `2`, `3` en trois marches fixes; laisser une marche vide si un rang manque, au lieu d'exiger exactement trois entrées.
- [x] Grouper les ex aequo par rang dense, afficher un badge `×N` accessible et faire tourner les identités du groupe toutes les 5 secondes pendant l'overlay.
- [x] Auditer les limites de longueur: joueurs Quiz/Blind Test/Bingo runtime 20 caractères côté client et serveur DB-aware; joueur Hub 20 caractères côté client/serveur; équipe Blind Test runtime 20 caractères côté client/serveur; identités remote/historiques préparées jusqu'à 80 caractères côté remote/persistance snapshot.
- [x] Calibrer titre et fallback identité avec coordonnées relatives à la scène `1664x936` et tailles `cqw` bornées, afin d'éviter une dérive entre overlay normal Hub Master et plein écran.
- [x] Vérifications locales: lint PHP OK; tests Hub PHP et DOM Node OK. Mesures géométriques établies depuis l'asset `1664x936`; captures navigateur non produites localement faute de navigateur headless installé.

## PATCH 2026-07-27 — Hub Master: wordings selon usage effectif
- [x] Consulter START, SITEMAP, SITEMAP.ndjson, DOCS_MANIFEST et le journal AI Studio raw avant audit; aucune entrée ciblée Hub Master wordings/`context_type` à recharger hors workspace dans les lignes filtrées.
- [x] Auditer `games_hub_get_context_from_request()`: le Hub Master charge déjà le client courant via `app_client_get_detail(...)`.
- [x] Identifier la divergence: `Lots de ...` et `Podium de ...` étaient dérivés de `games_hubs.context_type`, qui peut rester `soiree` après changement d'usage vers gamification.
- [x] Rappeler dans le README Games que `games_hubs.context_type` n'est plus l'autorité des wordings visibles quand l'usage courant du compte est disponible.
- [x] Rappeler que l'adaptation de wording ne modifie ni l'identité `games_hubs`, ni les rattachements `games_hubs_sessions`, ni les joueurs/lots/publication/branding/historique.
- [x] Centraliser `games_hub_wording_context_get(...)` et `games_hub_master_wording_labels_get(...)` côté Games pour résoudre les libellés depuis `clients.id_solution_usage`, avec fallback sur `games_hubs.context_type` uniquement si l'usage courant est indisponible.
- [x] Adapter les occurrences Hub Master: titre des lots, bouton trophée, titre de modale podium, aria-labels Master `Accueil`, `Programme` et alt du visuel central.
- [x] Ne pas modifier Hub id, token, `context_type`, opération legacy, memberships, joueurs, lots, publication, branding, podium calculé ni rendu graphique.
- [x] Couvrir gamification sur Hub historique `soiree`, dynamisation, fallback historique sans usage courant, cohérence des occurrences et absence de création/mutation Hub dans `hub_session_settings_test.php` et `hub_session_settings_dom_test.mjs`.
- [x] Vérifications locales: lints PHP ciblés OK; `hub_session_settings_test.php`, `hub_session_settings_dom_test.mjs`, `hub_master_renewal_eligibility_model_test.php` OK; `git diff --check` Games OK.
- [ ] Recette navigateur authentifiée: compte passé en gamification avec Hub canonique historique `soiree`, vérifier `Lots de l’événement`, bouton et modale `Podium de l’événement`; compte dynamisation inchangé avec labels soirée.

## PATCH 2026-07-27 — Hub Master: podium agrégé de soirée/événement
- [x] Consulter START, SITEMAP, DOCS_MANIFEST et le journal AI Studio raw avant audit; aucune entrée Games/Hub récente à recharger hors workspace dans les sections visibles.
- [x] Auditer le Hub Master: classement agrégé via `aggregate_context`, podiums de session via `session_results`, sélection visuelle via carrousel local, focus runtime via `active_session_id`.
- [x] Normaliser non destructivement l'asset local `podium-evening-3w-source.png` par crop centré `x=4 y=2` vers `1664x936` exact 16:9; source originale conservée inchangée.
- [x] Exporter `games/web/includes/canvas/images/hub/podium-evening-3w.webp` en `1664x936` WebP qualité 88, sans upscale 3840x2160 artificiel.
- [x] Ajouter un contrat de présentation explicite consommable par Games: `presentation_mode=session|hub_podium|hub_idle`, séparé de `active_session_id`.
- [x] Consommer le podium agrégé depuis le contrat Global `aggregate_ranking`, puis projeter côté Games les rangs denses `1`, `2`, `3` pour le rendu et les lots.
- [x] Différencier visuellement le podium agrégé du podium de session: scène cérémonielle Hub, image de fond locale trois gagnants, overlay HTML/CSS/SVG pour titre, portraits, rangs, noms et stats.
- [x] Sortir le podium agrégé de la contrainte du hero central: rendu en surcouche `position:fixed` au-dessus de la colonne centrale, du carrousel, des lots/QR et de la colonne classement/live.
- [x] Ajouter un panneau modal centré avec voile sombre interceptant les clics, tout en gardant les utilitaires trophée et plein écran en bas à gauche au-dessus du voile.
- [x] Gérer les fermetures attendues: clic fond uniquement, Escape singleton, bouton fermer interne et bouton trophée `Masquer le podium`; les clics dans le panneau ne ferment pas et ne traversent pas vers les cartes.
- [x] Ajouter les attributs d'accessibilité overlay: `role="dialog"`, `aria-modal`, titre/sous-titre liés, focus envoyé au bouton fermer, restauration vers le trophée, arrière-plan retiré du tab order pendant l'ouverture.
- [x] Recomposer la scène en véritables marches: conteneur `hub-master-podium-stage__scene`, zones CSS `second first third`, blocs gagnant `__winner` séparés des façades `__step`, sans dépendre d'un simple `order` sur trois cartes identiques.
- [x] Brancher la scène hybride si au moins un rang agrégé exploitable et WebP local présent; les rangs denses absents laissent des marches vides, l'asset absent conserve le rendu HTML historique.
- [x] Centraliser les coordonnées hybrides en custom properties relatives au repère `1664x936`, avec slots visuels centre/gauche/droite mais médaillons portant les rangs réels.
- [x] Appliquer la calibration Figma `1664x936`: titre/sous-titre, avatars, médailles et plaques positionnés sur les coordonnées numériques de référence; avatars centrés par diamètre, sans hauteur Figma.
- [x] Supprimer la couronne SVG de la branche hybride et ancrer chaque médaillon localement au wrapper de son avatar, sans coordonnées globales propres aux médailles.
- [x] Rendre la première place dominante: marche plus haute, colonne plus large, avatar plus grand, accent or et médaillon de rang central.
- [x] Conserver des rangs 2 et 3 lisibles avec accents argent/bronze, médaillons stables et marches plus basses mais non anecdotiques.
- [x] Rendre les plaques hybrides avec le nom du gagnant, sa stat existante puis le lot réel en information secondaire `Lot : ...` quand disponible; aucun libellé `1ER PRIX`/`2E PRIX`/`3E PRIX`.
- [x] Ajouter uniquement des décorations CSS/SVG inline: halo, séparation, confettis statiques, lauriers discrets; aucun asset externe ni animation permanente.
- [x] Afficher le podium agrégé avec le branding Hub, un titre `Podium de la soirée` ou `Podium de l’événement`, le sous-titre `Classement général après X parties jouées`, et les noms/stats/lots secondaires des gagnants dans les plaques de la scène hybride.
- [x] Corriger l'association des lots par `rank_value`/rang, sans réordonner les données persistées: `2e prix` sous `#2`, `1er prix` sous `#1`, `3e prix` sous `#3`.
- [x] Préparer les photos/avatars sur le podium agrégé: conservation des champs photo déjà exposés par l'agrégat, médaillon carré circulaire `object-fit: cover`, fallback initiale même géométrie quand aucune source canonique n'existe.
- [x] Ajouter le bouton trophée Master: inactif `Podium de la soirée/événement`, actif `Masquer le podium`; il écrit seulement le mode de présentation.
- [x] Automatiser l'apparition quand aucune session n'est active, au moins un résultat exploitable existe, et toutes les sessions métier sont terminées ou suspendues; une pending bloque l'auto.
- [x] Fermer le podium agrégé sur clic carte, ajout rapide, lancement/reprise; garder l'index technique du carrousel sans sélection visuelle quand `hub_podium` est actif.
- [x] Préserver `hub_podium` après `preparation_revision` et remplacement partiel: rebinding sans doublon, close hook réassigné, `restoreSelection(...)` neutralisé tant que l'overlay reste actif.
- [x] Ne pas modifier Hub Play, WebSockets, focus runtime, calcul des scores, classement général, podiums de session, branding Hub/session, ajout rapide ni actions `↻`/`⚙`.
- [x] Vérifications locales: lint PHP Games OK; `hub_session_settings_test.php`, `hub_session_settings_dom_test.mjs`, `session_results_podium_contract_test.php` OK; contrôles dimensions/MIME/poids des assets OK.
- [ ] Recette navigateur authentifiée: bouton trophée, auto fin de soirée, sessions suspendues, pending bloquante, ajout rapide, launch/reprise, noms/stats/lots secondaires en plaques hybrides, lot absent sans ligne vide, clic fond sans sélection carte derrière, Escape/focus clavier, refresh partiel en overlay, ouverture répétée sans doublon, fullscreen, podium une/deux/trois places, photos/fallbacks, branding clair/sombre, faible hauteur, desktop/mobile, contrôle visuel 992/1280/1366/1440/1920/2560.
- [ ] Asset natif HDPI à produire après validation des coordonnées HTML: `3200x1800` ou `3840x2160` natif, sans upscale traditionnel.

## PATCH 2026-07-27 — Hub Master: podium terminé limité aux 3 cartes historiques
- [x] Auditer preuve d'abord: journal AI Studio raw, START, DOCS_MANIFEST, état Git local, helpers Hub Games et helpers résultats Global.
- [x] Auditer les surfaces historiques Master/Canvas Quiz, Blind Test, Bingo: le rendu historique affiche au plus trois cartes de podium et les préloads runtime bornent déjà les podiums à trois entrées.
- [x] Identifier la divergence: `app_session_results_podium_from_rankings(...)` et `app_session_results_podium_normalize(...)` renvoyaient toutes les lignes de rang 1 à 3; le Hub Master filtrait les rangs mais ne limitait pas à trois cartes.
- [x] Corriger la source commune Global pour borner le podium normalisé à trois lignes, en conservant les rangs de compétition et l'ordre canonique déjà calculé.
- [x] Ajouter une garde défensive Hub `games_hub_result_podium_rows(...)` afin que le bloc central n'affiche jamais plus de trois lignes valides même si un contexte ancien est injecté.
- [x] Couvrir les cas demandés: une/deux/zéro lignes, égalités massives, égalités en deuxième place, équipes Blind Test, podium JSON normalisé.
- [x] Ne pas modifier scoring, rangs de compétition, agrégation générale, focus Hub, WebSockets, Canvas runtime, Programme, Lots, ajout rapide, `↻` ni `⚙`.
- [x] Vérifications locales: lints PHP Global/Games OK; tests podium Global et Hub OK; test DOM Hub OK; `git diff --check` OK.
- [ ] Recette navigateur authentifiée: session Hub terminée avec 13 ex aequo, comparer Hub Master central et Master historique; vérifier max 3 cartes desktop/mobile et aucune troncature navigateur tardive.

## PATCH 2026-07-27 — Hub Master: sélection carrousel après fin naturelle
- [x] Auditer le journal AI Studio raw, les docs START/DOCS_MANIFEST et l'état Git local/remotes Games avant patch.
- [x] Auditer les contrats `active_session_id`: lancement confirmé via Global `app_games_hub_focus_set_active(...)`, fin naturelle via Canvas `canvas_api_hub_session_natural_ended(...)` puis `app_games_hub_focus_clear(...)`, routage Hub Play via `app_games_hub_presentation_resolve(...)`.
- [x] Identifier la cause: le rendu Master utilisait `next_session_fallback` dès qu'il n'y avait plus de focus, donc la prochaine partie pouvait remplacer visuellement la partie tout juste terminée.
- [x] Ajouter `games_hub_master_presentation_selection_resolve(...)` comme résolution unique de carte Master: focus confirmé, runtime suspendu, dernière fin naturelle prouvée par événement canonique, première pending selon position Programme, première session métier, puis carte ajout uniquement sans session métier.
- [x] Propager les événements de completion naturels du contexte vers le view-model, sans nouvelle écriture DB et sans déduire la dernière partie terminée depuis l'horaire.
- [x] Étendre le refresh préparation Master au bloc central branding/podium afin qu'un podium devenu disponible arrive sans recalcul navigateur ni reload complet.
- [x] Préserver la sélection manuelle pendant les refreshs si la carte existe encore; fallback déterministe seulement si elle disparaît.
- [x] Ne pas modifier le calcul des podiums, le classement général, l'agrégation de scores, `active_session_id`, Hub Play, Canvas, WebSockets, sessions papier, ajout rapide, `↻` ni `⚙`.
- [x] Vérifications locales: lints PHP Hub helper/test OK; `hub_session_settings_test.php` OK; `hub_session_settings_dom_test.mjs` OK.
- [ ] Recette navigateur authentifiée: fin naturelle session 1 avec retour Hub sans reload complet, podium 1 affiché, session 2 disponible mais non sélectionnée, lancement/reprise session 2, Hub Play non routé avant lancement.

## PATCH 2026-07-26 — Hub Master: synchronisation préparation sans reload
- [x] Auditer les endpoints Hub Master: rendu initial `/hub/{token}/master`, POST `players_count`, `launch_session`, `session_settings_get/save`, `quick_session_create`, `quick_session_theme_renew`.
- [x] Auditer les helpers existants: `games_hub_get_context_from_request()`, `games_hub_build_view_model()`, `games_hub_render_program()`, `games_hub_session_card_payload()`, résolveurs Global `app_games_hub_branding_get()` et `app_games_hub_prizes_get()`.
- [x] Ajouter une révision légère `preparation_revision` basée sur Hub, Programme, branding et lots, sans polling agressif de blocs.
- [x] Déclencher la vérification sur `visibilitychange`, `pageshow` et un intervalle visible de 60 s.
- [x] Remplacer uniquement les blocs Programme et Lots, synchroniser style/visuel/titre branding, puis réinitialiser QR, plein écran, carrousel, renouvellement et paramétrage sans double-binding.
- [x] Remplacer le reload après ajout rapide Hub Master par un refresh forcé des blocs.
- [x] Préserver la sélection courante si la session existe encore; sinon laisser le carrousel choisir une carte valide.
- [x] Ne pas toucher aux panneaux live/classement, au focus Hub persistant, aux WebSockets, timers, overlays, podiums déjà affichés ni runtime des sessions en cours.
- [x] Vérifications locales: lint PHP Hub helper OK; `hub_session_settings_test.php`, `hub_master_renewal_eligibility_model_test.php`, `hub_publication_prizes_contract_test.php` OK.
- [ ] Recette navigateur authentifiée: Dashboard + Hub ouverts, ajout/suppression session non démarrée, renouvellement, changement format/mode, branding, lots, avec session active/suspendue et inscrits live conservés.

## PATCH 2026-07-26 — Hub Master: classement général et inscrits live
- [x] Masquer les points dans le rendu du classement général Hub Master, sans modifier le score interne ni le tri.
- [x] Afficher seulement une statistique métier déjà exposée par Global: victoires en priorité, sinon podiums, et aucun indicateur si `wins` / `second_places` / `third_places` sont absents.
- [x] Séparer la colonne droite en deux zones quand le classement existe: `Classement général` scrollable en haut, `Inscrits live` fixe et toujours visible en bas.
- [x] Conserver la liste live complète avant apparition du classement, puis limiter l'aperçu live à cinq derniers inscrits avec `+ X autres` après classement.
- [x] Couvrir le contrat UI: absence de points, stats présentes/absentes, liste live complète avant classement, aperçu limité après classement et structure scrollable.
- [x] Auditer la source live Hub: `games_hubs_players.status='active'`, compteur `app_games_hub_players_count_active(...)`, liste `app_games_hub_players_list_active(...)`, tri derniers vus/arrivés en tête.
- [x] Auditer la source classement: `aggregate_context['leaderboards']` produit par les helpers Global de dashboard joueurs, avec listes déjà normalisées `players_full`, `teams_full`, `participants_full`.
- [x] Remplacer le rendu legacy par jeu par une liste générale unique `Classement général`.
- [x] Fusionner uniquement les lignes avec identité explicite stable `participant_type + identity`; ne pas fusionner deux noms identiques avec identités distinctes.
- [x] Corriger le cas Hub inter-jeux: reconnaître `hub_player:{id}` comme clé canonique `player:{id}` afin de fusionner Quiz + Blind Test + Bingo pour le même joueur Hub, même si une ligne Quiz héritée arrivait avec `participant_type=team`.
- [x] Garder les contributions runtime sans mapping Hub sur leur identité propre, sans fallback par nom.
- [x] Additionner les scores déjà normalisés par Global, puis trier score décroissant, contributions, date récente, libellé, avec rangs de compétition en cas d'égalité.
- [x] Rendre `Inscrits live` sous le classement avec le même compteur, la même liste et le même refresh `players_count`.
- [x] Masquer `joueurs inscrits` quand le compteur vaut zéro, tout en conservant `0` et `En attente de joueurs.`.
- [x] Faire de la colonne droite un seul panneau scrollable quand classement et inscrits dépassent la hauteur.
- [x] Vérifications locales: lint PHP Hub helper/test OK; `hub_session_settings_test.php` OK.
- [ ] Recette navigateur authentifiée: zéro/un/plusieurs inscrits, première session terminée, sessions multi-jeux, joueur classé déconnecté, joueur inscrit non classé, longue liste et faible hauteur.

## PATCH 2026-07-26 — Hub Master: carte ajout rapide allégée
- [x] Retirer le texte secondaire `Compléter le programme` de la carte `Ajouter une partie`.
- [x] Retirer la ligne de détail `Choix automatique`.
- [x] Augmenter l'espacement entre l'icône `+` et le titre de carte.
- [x] Conserver la carte, le CTA footer `Ajouter` et l'ouverture de la modale inchangés.
- [x] Vérifications locales: lint PHP Hub helpers/tests OK; `hub_session_settings_test.php` et `hub_master_renewal_eligibility_model_test.php` OK.
- [ ] Recette navigateur: Hub Master avec et sans sessions existantes, vérifier sélection carte add, CTA footer et rythme visuel.

## PATCH 2026-07-26 — Hub Master: séries Quiz hors détails carte
- [x] Séparer les séries Quiz du bloc commun `hub-session__details`.
- [x] Ajouter une div dédiée `hub-session__theme-lines` rendue sous `hub-session__details`.
- [x] Garder `hub-session__details` pour les métadonnées courtes comme `Sur smartphone` / `Sur papier`, sans doublon `4 séries`.
- [x] Adapter le payload et les mises à jour AJAX avec `theme_lines`.
- [x] Retirer la variante `hub-session__details--quiz-series` pour redonner de la respiration à la carte.
- [x] Vérifications locales: lint PHP Hub helpers/tests OK; `hub_session_settings_test.php` et `hub_master_renewal_eligibility_model_test.php` OK.
- [ ] Recette navigateur: Hub Master Quiz 4 séries avec intitulés longs, vérifier respiration carte et ellipses desktop/mobile.

## PATCH 2026-07-26 — Hub Master: renouvellement aligné dashboard Pro
- [x] Comparer le flux Hub Master avec le dashboard Pro: le dashboard chaîne plan/apply avec exclusions temporaires par carte alimentées par `previous_selection`.
- [x] Ajouter la transmission Hub `temporary_exclusions` vers `app_programming_theme_renewal_plan_for_session(...)`, bornée à 24 items.
- [x] Renvoyer `previous_selection`, `applied_selection` et `effective_exclusions` au navigateur Hub après apply.
- [x] Côté navigateur, stocker les exclusions temporaires par carte DOM, sans `sessionStorage`, `localStorage` ni cookie, et les alimenter uniquement depuis la sélection serveur précédente.
- [x] Empêcher les doubles clics et ignorer les réponses tardives comme le dashboard Pro.
- [x] Pour Quiz, transmettre `theme_renewal_operation=plan/apply` et utiliser `start_theme_renewal_candidate_loader` si le loader dashboard est chargé.
- [x] Tests: handler Hub avec exclusions, contrat JS d'exclusions temporaires, non-régression ajout rapide et `⚙`.
- [x] Vérifications locales: `hub_session_settings_test.php`, `hub_master_renewal_eligibility_model_test.php`, tests Global planner/apply OK.
- [ ] Recette navigateur: cliquer plusieurs fois sur `↻` sur une carte quick-add Hub et vérifier que la séquence ne revient pas immédiatement sur les deux mêmes thématiques tant que des alternatives existent.

## PATCH 2026-07-26 — Hub Master: éligibilité renouvellement quick-add
- [x] Auditer la chaîne `games_hubs_sessions` -> chargement Programme -> modèle session -> helper -> rendu HTML.
- [x] Confirmer que le bouton `↻` est absent du DOM quand le garde échoue; le CSS le masque seulement hors carte sélectionnée comme `⚙`.
- [x] Faire dépendre le garde "jamais lancée" de `hub_last_launch_event_id` / `hub_last_launch_at`, pas de la seule existence runtime ni du statut `En attente`.
- [x] Ajouter un test qui construit les sessions via `app_games_hub_sessions_get(...)` avec une ligne SQL `games_hubs_sessions.membership_source='quick_hub_create'`, puis rend le Programme Master.
- [x] Couvrir origine différente, quick Hub jamais lancée, quick Hub déjà lancée et présence inchangée de `⚙`.
- [x] Vérifications locales: nouveau test d'éligibilité modèle OK; lint PHP Hub helpers OK; `hub_session_settings_test.php` OK.
- [ ] Recette DB authentifiée: créer une session via ajout rapide Hub Master et vérifier `membership_source`, `hub_last_launch_event_id=0`, `↻` présent sur carte sélectionnée; lancer puis vérifier disparition.

## PATCH 2026-07-26 — Hub Master: détails des séries Quiz en carte
- [x] Reprendre la convention dashboard Pro: conserver le libellé principal de thématique sur la carte et rendre le détail Quiz en sous-lignes.
- [x] Afficher les noms de séries Quiz en lignes numérotées sous le mode `Sur smartphone` / `Sur papier`, sans répéter le compteur `4 séries` dans les métadonnées.
- [x] Ajouter une variante CSS compacte dédiée aux séries Quiz, sans puces et avec police réduite.
- [x] Conserver le même rendu après les mises à jour Ajax de carte (`settings` / autre proposition) via `details_variant`.
- [x] Couvrir le rendu avec quatre séries longues dans `hub_session_settings_test.php`.
- [x] Vérifications locales: lint PHP Hub helpers/tests OK; `hub_session_settings_test.php` OK; contrat Global quick Hub OK.
- [ ] Recette navigateur: Hub Master Quiz 2/4 séries sur desktop 1366/1920 et mobile, avec renouvellement de thématique si session quick-add éligible.

## PATCH 2026-07-26 — Hub Master: autre proposition quick-add
- [x] Auditer le contrat Dashboard/Global existant: `app_programming_theme_renewal_plan_for_session(...)` puis `app_programming_theme_renewal_apply_for_session(...)`, avec exclusions, validation, garde Hub et apply conditionnel.
- [x] Utiliser `games_hubs_sessions.membership_source='quick_hub_create'` comme seule preuve persistée d'une session créée via l'ajout rapide Hub.
- [x] Ajouter l'action Master `quick_session_theme_renew`, protégée par capacité Master, CSRF, Hub actif, appartenance Hub, source quick-add et état jamais lancé.
- [x] Rendre l'icône `↻` avant `⚙` uniquement sur les cartes quick-add Hub jamais lancées; conserver le handler et le comportement de la roue.
- [x] Mettre à jour seulement la carte retournée par le serveur après renouvellement, sans reload global, sans focus Hub, sans changement d'ordre et sans mutation runtime.
- [x] Couvrir la visibilité quick-add/Dashboard/bibliothèque/lancée, le refus serveur non quick-add, l'appel du contrat Global, l'ordre du programme et la non-régression de `⚙`.
- [x] Vérifications locales: `php -l` Hub helpers/tests OK; `hub_session_settings_test.php` OK; contrats Global `session_theme_renewal_apply_test.php`, `session_theme_renewal_planner_test.php`, `programming_quick_hub_service_contract_test.php` OK.
- [ ] Recette navigateur authentifiée: Hub quick-add Quiz/Blind/Bingo jamais lancé, renouvellement plusieurs fois, lancement puis disparition de `↻`, session Dashboard et bibliothèque sans icône, roue `⚙` inchangée.

## PATCH 2026-07-24 — Fallback Cotton sans logo dans les interfaces
- [x] Auditer les fallbacks front locaux vers `/images/logo.png`.
- [x] Retirer le fallback header Player vers `/images/logo.png`.
- [x] Conserver le rendu conditionnel existant du Hub Master: logo affiché uniquement si `hub_logo` fournit une URL.
- [x] Conserver les logos techniques QR/papier séparés du branding de session.
- [x] Couvrir le contrat dans `hub_session_settings_test.php`.
- [x] Vérifications locales: lint PHP Player OK; test Hub settings OK.
- [ ] Recette navigateur: Organizer/Player/Remote/Hub Master sans logo dans la cascade, puis avec logo Hub/réseau/compte.

## PATCH 2026-07-24 — Hub Master: alignement branding, lots et cartes Programme
- [x] Afficher le logo effectif `hub_logo` dans le panneau gauche Master lorsqu'une URL exploitable est fournie par le resolver canonique.
- [x] Remplacer le header `Lots + compteur` par `Lots de la soirée` ou `Lots de l’événement`, sans quantité affichée.
- [x] Ajouter une commande de plein écran native, masquée si l'API Fullscreen n'est pas disponible, avec libellés accessibles entrée/sortie.
- [x] Retirer les horaires individuels visibles des cartes Programme Master et aligner les modes sur `Sur smartphone` / `Sur papier`.
- [x] Harmoniser les libellés visibles Hub Master/Play vers `partie(s)`, y compris les sous-titres header issus de `app_games_hub_schedule_label_get(...)`.
- [x] Retirer le `display:flex` du panneau gauche Master, conserver le QR à taille naturelle et ancrer le plein écran en `position:fixed` en bas à gauche du viewport Master sans dépendre de l'étirement, des lots ou du QR.
- [x] Remonter légèrement le contenu des cartes Programme sans changer leur hauteur externe.
- [x] Faire utiliser au CTA Programme l'accent effectif du branding avec texte contrasté calculé; couvrir blanc, noir, clair, sombre et fallback Cotton.
- [x] Harmoniser le fallback dashboard Pro/personnalisation sur le couple Cotton canonique `#240445` / `#bba9ff`.
- [x] Conserver le tri, la sélection locale, les flèches, le CTA unique et le podium central sans modifier runtime, WebSockets, Hub Play ni canvases historiques.
- [x] Auditer l'ajout rapide dashboard: le contrat canonique reste côté Pro (`dashboard_quick_session_create` + helpers quick-schedule + idempotence Global); aucune implémentation concurrente n'a été ajoutée dans Games.
- [x] Extraire le moteur minimal d'ajout rapide dans Global: jeux autorisés, paramètres, proposition signée, renouvellement, création idempotente et rattachement Hub.
- [x] Ajouter l'endpoint serveur Master `quick_session_create`, borné par capacité Master, token Hub actif, propriétaire, contexte et CSRF, sans session navigateur Pro.
- [x] Adapter `dashboard_quick_session_create` côté Pro pour déléguer au même service Global `create_from_game` après ses gardes Pro.
- [x] Documenter le payload Master direct `csrf_token` / `id_type_produit` / `quick_schedule_idempotency_key`.
- [x] Brancher l'UI Master d'ajout rapide sur le contrat stabilisé, sans dupliquer le moteur ni accepter de thème/format arbitraire du navigateur.
- [x] Ajouter la carte `Ajouter une partie` après les parties du carrousel, sans `id_session`, focus métier ni action de lancement; elle s'ouvre uniquement par son CTA footer `Ajouter`, pas par clic pleine carte.
- [x] Ajouter la modale Master: choix jeu autorisé serveur puis création directe `quick_session_create`, sans proposition visible, renouvellement, confirmation intermédiaire ni `proposal_token` navigateur.
- [x] Rafraîchir le Programme par reload contrôlé après succès pour relire le rendu serveur canonique et le nombre de parties.
- [x] Vérifications locales: lints PHP ciblés Games/Global/Pro OK; tests `hub_session_settings_test.php`, `hub_publication_prizes_contract_test.php`, `programming_quick_hub_service_contract_test.php`, `programming_quick_recommendation_test.php`, `programming_quick_idempotency_contract_test.php`, `session_theme_renewal_planner_test.php`, `session_theme_renewal_apply_test.php`, `ec_start_sessions_day_dashboard_test.php` OK; JS inline Hub extrait OK; diff whitespace OK.
- [ ] Recette navigateur authentifiée: logo/fallbacks, lots 0-3 sans compteur, plein écran bouton/Échap et zoom/faible hauteur, carte `Ajouter une partie` non entièrement cliquable avec CTA `Ajouter`, double clic, ajout des trois jeux, Hub Play mobile, dashboard Pro du même Hub, 1366x768 et 1920x1080.

## PATCH 2026-07-17 — Hub Master/Play: contexte et libellés communs
- [x] Lire le nom Hub normalisé depuis le contrat partagé.
- [x] Utiliser les fallbacks `Événement {nom_compte}` et `Soirée {nom_compte}`.
- [x] Aligner le sous-titre temporel sur `date · à partir de HHhMM · N partie(s)`.
- [x] Conserver le contexte soirée/événement avant le lieu.
- [x] Continuer à lire les lots depuis `games_hubs_prizes` côté Master/Play; l'absence d'affichage public des lots est portée côté `www`.
- [ ] Recette navigateur: Hub Master et Hub Play avec titre manquant, plusieurs sessions, soirée et événement.

## PATCH 2026-07-17 — Publication et lots canoniques Hub
- [x] Ajouter les tables `games_hubs_publication` et `games_hubs_prizes` avec DDL idempotent et création runtime via `app_games_hub_schema_ensure()`.
- [x] Faire de `games_hubs_prizes` la source lue par Hub Master/Play et par les canvases session rattachés à un Hub; les sessions autonomes gardent les champs historiques `lot_1..3`.
- [x] Bootstrap transitionnel borné par `games_hubs.prizes_initialized_at`: si aucun lot Hub n'existe et que le Hub n'a jamais été initialisé, reprendre une seule fois la première session personnalisée; après suppression volontaire des trois rangs, ne jamais réimporter les lots historiques.
- [x] Ajouter un resolver public Hub séparant publication, lieu, branding, sessions et lots, sans stocker visuel/logo/couleurs dans la publication.
- [x] Ajouter le correctif SQL idempotent `2026-07-17_games_hubs_prizes_initialization_state.sql` pour les bases où `2026-07-17_games_hubs_publication_prizes.sql` a déjà été importé sans le marqueur.
- [x] Vérifications locales: `php -l` global Hub; `php -l` Organizer, Player et Remote Canvas; test de contrat Hub publication/lots OK.
- [ ] Recette DB: contrôler les tables importées, appliquer seulement si nécessaire le correctif `prizes_initialized_at`, puis vérifier bootstrap, sauvegarde, suppression des trois lots et absence d'écriture `championnats_sessions.lot_1/2/3`.

## PATCH 2026-07-17 — Canvas branding Hub hérité
- [x] Les appels branding des canvases Organizer, Player, Remote et de l'aperçu modale ajoutent `branding_context=game`.
- [x] Le chemin serveur principal reste le User-Agent historique `CanvasBrandingHydrator/1.0`; `branding_context=game` ne sert qu'aux appels navigateur de modale.
- [x] Côté Global, l'endpoint commun utilise maintenant le resolver session historique avec cascade Hub type 5, au lieu d'une branche parallèle.
- [x] Le rattachement Hub/session est consommé depuis `games_hubs_sessions`; les règles legacy ne servent qu'au backfill non ambigu.
- [x] `id_operation_evenement` n'intervient plus dans la résolution du branding des jeux; une session de soirée avec `id_operation_evenement=0` hérite du branding Hub.
- [x] Bump cache Canvas: `CANVAS_ASSET_VER=v=2026-07-17_02`.
- [x] Aucun contrat Canvas, WebSocket, lot, score ou route Hub n'est modifié.
- [x] Vérification locale: `php -l` sur `organizer_canvas.php`, `player_canvas.php`, `remote_canvas.php`; test global `hub_operation_branding_cascade_test.php` OK.

## PATCH 2026-07-15 — Lots Hub issus du resolver commun
- [x] Retirer les trois prix factices du view model Hub.
- [x] Resoudre les lots dynamiquement depuis la couche Global partagee avec le prototype Pro.
- [x] Conserver ordre et limite de trois sur Hub Master et Hub Play, sans dupliquer le payload; defaults Hub si toutes les sessions sont par defaut, premiere personnalisation sinon.
- [x] Deleguer le fallback visuel Cotton du Hub au helper Global partage, a rendu SVG strictement inchange.
- [x] Valider syntaxe PHP et whitespace; aucun contrat Canvas/WS modifie.
- [ ] Recette navigateur avec listes identiques, divergentes et vides apres publication.

## PATCH 2026-07-15 — Continuité Hub des joueurs ajoutés depuis une Remote papier
- [x] Corréler les logs rechargés: création Hub en session A, nouvelle clé Remote locale en session B, `USERNAME_TAKEN` au bridge puis `USERNAME_ALREADY_USED` lors de la réinjection de la clé Hub.
- [x] Autoriser Quiz, Blind Test et Bingo à adopter l'unique ligne runtime conflictuelle uniquement sous contexte d'injection papier serveur strict; conserver son ID SQL et toutes ses données métier.
- [x] Ajouter les jalons `hub_remote_player_bridge_*`, `hub_launch_injectable_players_selected` et `hub_paper_player_injection_*`.
- [x] Valider syntaxe PHP, whitespace et invariants statiques des trois adaptateurs.
- [ ] Recette intégrée DB/Remote/Hub après déploiement: session A, reprise A, session B, Hub Play, doublon/left, puis contrôle des trois moteurs.

## PATCH 2026-07-13 — Auto-inscription Hub papier persistante
- [x] Remplacer le return papier avant runtime par un ensure limité à `player_register`, sans preload numérique, grille Bingo, équipe Blind Test, navigation ou WS Player.
- [x] N'exposer le message Hub papier qu'après validation persistante de `playerId`, `player_id`, mapping actif et `paper_registration_confirmed`.
- [x] Rendre le focus papier éligible au polling `active_launched_session` sans jamais générer de `play_url`.
- [x] Réconcilier Master et Remote papier depuis `players_get` toutes les 2,5 s, indépendamment d'une socket Player.
- [x] Vérifier syntaxe PHP/ES module, absence d'opérations numériques dans la branche papier et contrats `registration_state` des trois adaptateurs.
- [ ] Recette intégrée Quiz/Blind Test/Bingo: polling/reload/deux onglets, focus A→B→A, mapping `left`, sans Master connecté au write, transitions papier↔numérique et parcours papier hors Hub.

## PATCH 2026-07-13 — Focus Hub monotone après relance suspendue
- [x] Auditer le CTA carrousel → `launch_session` → focus global → exécution/injection → redirect → reconstruction Master → presentation Player.
- [x] Confirmer le focus DB demandé avant redirect et reconstruire sessions/presentation depuis la ligne persistée plutôt que depuis un tableau Hub reçu en argument.
- [x] Vérifier que badge, CTA, ordre et sélection initiale reposent sur `hub_is_focus_active`; aucune sélection carrousel n'est persistée en storage.
- [x] En absence de focus, conserver la prochaine session à venir en priorité puis départager les sessions suspendues par leur dernier `hub_execution_started`, et non par leur horaire planifié.
- [x] Simuler A, C puis B focus avec trois sessions runtime `running`: focus en tête, badge `En cours`, autres `Suspendue`, CTA et sélection alignés.
- [ ] Recette réelle A → B → C → relance A → relance B avec lecture SQL directe, Hub Play/Players et callback tardif de A.

## PATCH 2026-07-15 — Validation papier et retour Hub après fin naturelle
- [x] Auditer Quiz, Blind Test et Bingo de la fin du support jusqu'au write terminal, à la completion Hub et au redirect.
- [x] Rendre `awaiting_score_validation` non terminal, `finalizing_scores` anti-double clic et `completed` dépendant de la persistance critique.
- [x] Retirer `paper_finalize_end` et `phase_over=-1` précoce des preuves de barrière; engager la barrière sur `game/ended`/`endGame` définitifs et l'annuler sans podium sur échec.
- [x] Permettre à la Remote Bingo de déclencher `bingo:end_game` après la dernière phase persistée même sans Master, avec verrou en vol et replay Hub.
- [x] Bloquer le premier rendu lobby Master pendant un `hub_launch=1` validé par une exécution Hub ouverte, supprimer l'autostart retardé et révéler seulement le flux lancé ou la Pause restaurée.
- [x] Intercepter `endGame` et les snapshots Bingo terminaux avant rendu, puis donner priorité à `location.replace()` vers Hub Master/Play au signal `HUB_SESSION_FINISHED`; rejouer le terminal historique seulement si aucune destination Hub valide n'est disponible.
- [x] Fermer la fenêtre Master uniquement après preuve terminale: barrière monotone sur `game/ended`, `endGame`, snapshot terminal persisté et preload terminé; revue papier visible, callbacks tardifs ignorés et redirect unique au signal fini.
- [x] Faire précéder la sélection `register/waiting` de Hub Play par `current_player`, sans créer d'identité locale avant la réponse serveur et sans démarrer le polling session avant résolution active.
- [x] Démarrer une boucle canonique `active_launched_session` immédiatement après toute résolution ou inscription `current_player` active, y compris sans reload; boucle récursive sans chevauchement et redirect atomique par `location.replace()`.
- [x] Aligner Bingo sur la présentation Hub focus active même lorsque son runtime reste `pending` avant la première phase; `player_register` précède le redirect, tandis que `grid_assign` / `grid_hydrate` restent dans le boot Player.
- [x] Auditer le lancement métier Master Bingo avant toute correction Player: première divergence localisée entre l'auto-start Hub immédiat et l'attachement asynchrone de `session_sync`, qui pouvait perdre `game/init` et `game/started`.
- [x] Consommer pour Bingo la preuve collante du premier `state` authentifié au lieu de réattendre un `ws/registered` déjà émis, puis attendre explicitement `organizer/runtime-ready` (socket enregistrée + autosync attachée), engager le même `Game.handleUI({type:'play'})` que le bouton historique et confirmer le `state` serveur post-`reset` avant de libérer la garde visuelle.
- [x] Ajouter les jalons structurés Master `HUB_MASTER_AUTOSTART_*` sans token, conserver le fallback historique déterministe et passer le cache Canvas local à `v=2026-07-13_08`.
- [x] Distinguer durablement rattachement Hub et exécution Hub avec `hub_execution_started` / `hub_execution_completed` dans `game_events`.
- [x] Action dédiée service-only, idempotente et clear conditionnel protégé contre A tardif / B actif; aucune transition pour une ouverture Pivot Pro historique.
- [x] Émission temps réel comptée avant fermeture des sockets et redirects reload autorisés uniquement par la preuve d'exécution complétée.
- [x] Stabiliser les `event_id` Bingo browser et restituer les résultats de replay pour `player_register`, `grid_assign`, `grid_cells_sync`.
- [x] Après recette réelle, supprimer la boucle GET native Bingo: bloquer explicitement tous les bootstraps Hub jusqu'au binding effectif du handler `submit`, avant tout `requestSubmit()`.
- [x] Corriger les variables de token non initialisées dans les trois resolvers adaptateurs.
- [x] Podium durable central et leaderboards agrégés existants dans le panneau droit; carrousel et panneau gauche inchangés.
- [x] Ajouter à la seule carte Programme sélectionnée une roue ouvrant une modale de paramétrage Hub pour Quiz, Blind Test et Bingo, sans accès Remote, QR/Pilot ni `Force full current`; calculer le contraste du contenu et de l'accent par luminance relative de la couleur réellement appliquée.
- [x] Mutualiser renderer, schéma, resolver et snapshot avec le Master Canvas historique; appliquer snapshot serveur puis `localStorage` puis défaut `manualAdvance=true` en Quiz papier, sans écraser un `false` explicite.
- [x] Protéger les actions `session_settings_get/save` par la capacité de la route Hub Master et son token actif, CSRF, appartenance Hub, jeu dérivé serveur et garde d'état/format revalidée au write; Hub Play ne reçoit pas cette capacité.
- [x] Retirer Version/Format du renderer Hub uniquement, rejeter ces clés sur POST forgé et supprimer tout `session_update` du handler Hub; persister seulement les options runtime autorisées dans `game_events` sans focus, sélection, ordre, scroll, CTA, centre ni WS.
- [x] Réutiliser les supports papier historiques dans la modale: feuilles Quiz, feuilles Blind Test et grilles Bingo, avec grant Hub/session/jeu signé, contrôle serveur de la version papier et désactivation si le format visible n'est pas encore persisté.
- [x] Après recette UI, faire respecter `hidden` sur la section Supports papier malgré le `display:grid`, synchroniser ouverture et bascules uniquement via `refreshConditionalFields()`, puis porter l'espacement Quiz sur le conteneur Pilotage manuel dans la seule modale Hub.
- [x] Couvrir les trois schémas, valeurs invalides, thèmes clair/sombre, persistance Hub/Master, supports, absence de Remote, route Master/Play, token Hub concordant/discordant, CSRF, session étrangère et états pending/terminated par un test PHP ciblé; valider PHP, JS inline/ESM et whitespace.
- [ ] Recette navigateur Hub Master passe 2: trois jeux, numérique/papier, thèmes clair/sombre et accents clair/sombre, supports PDF, persistance bidirectionnelle, suspendue/terminée, clavier/Échap/clic extérieur, double clic et refus d'une session d'un autre Hub, avec cache `v=2026-07-15_04`.
- [ ] Recette navigateur Quiz, Blind Test et Bingo avec cache `v=2026-07-15_01`: attente multi-polling, correction puis validation, double clic, reload Remote/Master, Master absent, session suivante et hors Hub; aucun podium avant validation et un seul `location.replace()`.
- [ ] Recette Master Bingo Hub avec `v=2026-07-13_08`: vérifier `DISCOVERED → DEPENDENCIES_READY → ACTION_COMMITTED → ACTION_ACCEPTED → RUNTIME_READY`, phase serveur `1`, commandes Master actives, reload sur la même partie et aucun double lancement.
- [x] Après validation réelle du Master, isoler la divergence Player dans `register.js`: une identité locale Bingo valide faisait `return` avant le binding du submit malgré la demande Hub différée; donner priorité au mapping Hub actif, rejouer le submit historique après binding et réarmer les deux verrous sur échec.
- [x] Rejouer le Player Bingo: auto-register et participation confirmés; les logs ont ensuite isolé un boot WS/hydrate prématuré avant `grid_assign` et une non-restitution visuelle du snapshot de reprise.
- [x] Interdire `ensureDigitalWsReady()` tant que l'inscription Hub Bingo n'est pas commitée, accepter une phase WS numérique ou sérialisée, mémoriser `state` / `players_sync` et rejouer le dernier statut après l'auth Bingo.
- [x] Distinguer `SESSION_ENDED` Hub d'un départ volontaire Player: conserver identité et grille, ne pas poser `leftVoluntarily`, puis revenir via `location.replace()`; garder le nettoyage historique pour le bouton Quitter et le hors Hub.
- [x] Pour `hub_join=manual`, restaurer la clé canonique Hub après purge locale, retrouver l'ID SQL de la participation réactivée et exécuter `grid_assign` avant `player/ready`; afficher une erreur actionnable si aucune grille ne peut être attribuée.
- [x] Après logs réels, autoriser Bingo à réactiver une clé `player_id` déjà connue avec son pseudo inchangé sans la rejeter comme un nouveau doublon; les contrôles d'unicité restent actifs pour toute nouvelle identité.
- [x] Réparer au bootstrap un mapping repassé `left` pendant une navigation manuelle et propager explicitement le pseudo `player/ready` vers l'auth WS Quiz/Blind Test, avec fallback sur le pseudo Hub serveur.
- [x] Aligner la reprise volontaire Quiz/Blind Test sur son score runtime vierge sans utiliser `is_active` comme preuve: autoriser `score=0` seulement depuis `manual_join_session` quand le Hub retrouve sous verrou le mapping de cette participation en statut `left`.
- [x] Auditer l'équivalent Bingo et préserver explicitement ses résultats de phase: `bingo_phase_winners` et `phase_wins_count/last_won_*` décrivent des gains réellement acquis dans la session et ne sont pas remis à zéro lors d'une réinscription.
- [ ] Rejouer avec cache `v=2026-07-13_14`: départ volontaire Player → Hub Play → `Rejoindre à nouveau`; vérifier une nouvelle grille, l'état `Pause` ou `En cours`, aucun Register bloquant et le pseudo Hub exact dans Quiz/Blind Test.
- [ ] Sur Quiz et Blind Test, marquer des points puis quitter volontairement côté joueur et rejoindre à nouveau: le joueur doit repartir à 0 et `changed_fields` doit contenir `score` lors de cette réactivation.
- [ ] Sur Quiz et Blind Test, marquer des points puis quitter volontairement côté organisateur et relancer sans quit joueur: le score doit être restauré, même si la fermeture collective a désactivé la ligne SQL.
- [ ] Vérifier qu'une réactivation inactive hors Hub ou automatique conserve le score; seuls `hub_session_manual_rejoin_score_reset_authorized/result` doivent prouver la remise à zéro Hub.
- [ ] Sur Bingo, gagner une phase, quitter volontairement, recevoir une nouvelle grille puis relancer côté organisateur: le gagnant historique de la phase doit rester présent une seule fois.
- [ ] Recette ciblée Hub Play: Blind Test et Bingo déjà présents avant lancement, puis reload dans les mêmes conditions; vérifier le même resolver, un unique watcher, un seul redirect et aucune attente de grille Bingo.

## PATCH 2026-07-12 — Clear Hub à expiration de grâce
- [x] Action Canvas service-only idempotente et clear atomique `active_session_id = id_session`.
- [x] Retours explicites sans modification des mappings.
- [ ] Recette navigateur/DB/WS multi-moteur, notamment A puis B et Player suspendu.

## PATCH 2026-07-12 — Reprise Hub suspendue synchronisée Master / Player
- Statut: implémenté et validé statiquement; recette navigateur/WS Blind Test, Quiz et Bingo requise.
- Cause Master: l'hydratation restaurait correctement la session, mais l'auto-start Hub pouvait la remettre en `En cours`; de plus, le premier événement Pause pouvait précéder l'attachement de `session_sync`.
- Correction Master: une session déjà commencée reste en `Pause`, sans auto-start, puis republie une seule fois son snapshot Pause après `ws/registered`. Un premier lancement réellement vierge conserve son auto-start.
- Cause Player résiduelle: après rechargement pendant la suspension, le socket neuf recevait `GAME_RESUMED` sans avoir émis ou confirmé `registerPlayer`; aucun `registrationSuccess` ni `gameState` n'arrivait avant un retour de focus.
- Correction Player: `GAME_RESUMED(sessionId courant)` déclenche une réinscription Quiz/Blindtest si aucun ACK n'est actif; `registrationSuccess` demande ensuite `getGameState`. Garde anti-doublon, invalidation de l'ACK hors transport `open` et trace `PLAYER_GAME_RESUMED_REGISTER` ajoutées.
- Invariants: une déconnexion organisateur réellement volontaire reste une fin (`SESSION_ENDED` + suppression runtime); papier, Bingo, hors Hub, mappings `left`, fin naturelle et remplacement d'onglet ne sont pas réinterprétés comme une reprise.
- Recette attendue: suspendre une session en lecture, recharger le Player, relancer le Master; observer `GAME_RESUMED` -> `PLAYER_GAME_RESUMED_REGISTER` -> `PLAYER_REGISTERED` -> `gameState(Pause)`, sans formulaire Register ni état `En attente`.
- Vérifications locales: parsing ES module de `play-ws.js` et `logger.global.js`; `git diff --check` sur le code et la documentation.

## PATCH 2026-07-12 — Réconciliation Hub numérique / papier et garde Register
- Statut: implémenté et validé statiquement; recette DB/navigateur multi-moteurs requise.
- Papier: résolution avant ensure numérique, conservation du mapping Hub actif et absence d'exigence de participation runtime numérique.
- Numérique: exposition de l'identité Hub active sans utiliser `runtimeEnsure.ok` comme preuve d'ACK WS; l'inscription réelle reste confirmée par `registrationSuccess`.
- UI Register: une identité Hub valide et non `left` protège la phase de restauration contre le retour transitoire au formulaire lors de `checkSession`, sans simuler d'authentification.

## PATCH 2026-07-11 — Ensure participation runtime Hub
- Statut: implémenté et validé statiquement; recette DB/navigateur multi-moteurs requise.
- `player_canvas.php` appelle l'ensure global même si le mapping paraît déjà actif et n'expose `hubAutoPlayer` qu'après confirmation runtime.
- Les mappings `left`, sessions terminées et parcours hors Hub ne déclenchent aucune réinscription automatique.
- Blind Test/Quiz conservent leur finalisation directe; Bingo conserve le submit, l'assignation et l'hydratation de grille historiques après ensure.

## PATCH 2026-07-11 — Destination canonique Hub et sync session Player
- Statut: implémenté et validé statiquement; recette navigateur/DB multi-moteurs requise.
- Réalisé: réponse `presentation` dans le polling Hub Play, contexte Hub validé dans `player_canvas.php`, contrôle player au boot/intervalle/réveil, retour unique par Hub Play quand le focus est vide ou cible une autre session.
- Cache: `CANVAS_ASSET_VER` passe à `v=2026-07-11_02` pour distribuer le nouveau module player.
- Invariants: podium et grâce restent dans la session tant que le focus ne change pas; aucun polling hors hub; runtime, mapping et auto-register restent distincts de la destination.
- Hors lot conservé: participation runtime obsolète, présence/grâce persistante, révision monotone et expiration de grâce.

## PATCH 2026-07-11 — Hub sortie organisateur / focus et relance
- Statut: code et conséquence de relance corrigés, recette navigateur/DB multi-moteurs à exécuter.
- Cause: le `quitGame` organisateur fermait le runtime WS sans effacer `games_hubs.active_session_id`; le polling Hub Play retrouvait encore un focus `running` et reconstruisait la `play_url`.
- Réalisé: helper global atomique/idempotent de clear, appel Canvas avant notification WS, retour Hub Master, garde de relecture focus/runtime dans l'auto-join, séparation auto-join joueur/capacité de lancement organisateur.
- Relance: une session non-focus non terminée affiche `Relancer`, repose le focus, restaure les mappings des joueurs actifs et ouvre le master avec `hub_launch=1` afin de reconstruire un runtime disparu.
- À vérifier: Blind Test, Bingo et Quiz (sortie, reload Hub Play, relance A, lancement B/course tardive, parcours hors hub, fin naturelle).

## PATCH 2026-07-10 — Hub Master gap visuel / programme

### Objectif
- garantir un gap stable entre le bas du visuel central et le programme Master;
- garder le visuel centré verticalement entre le header et le programme;
- conserver le ratio `5 / 2`, le cap de largeur `980px` et les coins arrondis visibles;
- réduire automatiquement le visuel par la hauteur disponible quand le viewport est trop bas;
- ne pas modifier les dimensions, animations, états ni comportements du carrousel.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - `.hub-master-center` passe à `grid-template-rows: auto minmax(0, 1fr) clamp(240px, 36vh, 277px)`;
  - le gap visuel -> programme est porté par `row-gap: var(--hub-master-gap-hero-program)`, borné à `clamp(12px, 1.6vh, 16px)`;
  - `.hub-master-program-footer` n'ajoute plus de marge haute propre; sa hauteur utile reste bornée par `calc(100% - var(--hub-master-gap-hero-program))`;
  - `.hub-master-hero` reste en `min-height: 0`, devient conteneur `container-type: size`, garde `overflow: visible` et centre le visuel avec `align-items: center`;
  - `.hub-master-visual` garde `aspect-ratio: 5 / 2`, `max-height: 100%`, `object-fit: contain` côté image, et ajoute une largeur dérivée de la hauteur disponible: `width: min(100%, 980px, calc(100cqh * 5 / 2))`.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/games diff --check -- web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/documentation diff --check`
- `npm run docs:sitemap`

## PATCH 2026-07-10 — Hub Master QR latéral final et centre simplifié

### Objectif
- valider le QR de participation dans le panneau gauche, directement sous les trois lots maximum;
- supprimer le doublon QR central;
- simplifier le centre en header, visuel puis carrousel, sans modifier le carrousel ni sa logique;
- garder de l'espace naturel sous le QR pour un futur bloc organisateur.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - ajout de la section `.hub-master-panel__section.hub-master-join-section` sous `.hub-master-prizes`;
  - réutilisation de `.hub-master-panel__head` avec le texte `SCANNE POUR PARTICIPER`;
  - ajout du conteneur `.hub-master-join-box`, analogue visuellement à `.hub-master-prizes`;
  - QR intégré `.hub-master-join-box__qr` en `width: min(100%, 180px)`, `aspect-ratio: 1 / 1`, fond blanc compact et padding 8px;
  - espacement compact `margin-top: 12px` après les lots, sans `margin-top: auto`;
  - suppression du bloc central `.hub-master-join`, de `#main-qr-container`, de ses styles et du `ResizeObserver` dédié;
  - `.hub-master-hero` passe en une colonne `minmax(0, 1fr)`;
  - `.hub-master-center-header` est centré, et `.hub-master-visual` est borné à `width: min(100%, 980px)`;
  - génération QR conservée via `[data-hub-qr-container]`, avec la même `data-url`/`$play_url`.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/games diff --check -- web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/documentation diff --check`
- `npm run docs:sitemap`

## PATCH 2026-07-10 — Hub Master libellé QR animé

### Objectif
- remplacer le texte QR par `Scanne pour participer`;
- garder la couleur de police primaire sur le texte;
- réserver la couleur secondaire à l'effet glow;
- reprendre la petite animation des QR de session des pages master historiques.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - le libellé `Scanne pour rejoindre la soirée` devient `Scanne pour participer`;
  - le titre QR utilise `var(--primary-font)`;
  - ajout de `@keyframes hub-master-qr-glow`, scoped au Hub Master, inspiré de `.cta-glow` / `glowCta`, avec halo secondaire;
  - ajout d'une désactivation via `prefers-reduced-motion: reduce`.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/games diff --check -- web/modules/app_hub_view_helpers.php`
- `rg -n "Scanne pour rejoindre|Scanne pour participer|hub-master-qr-glow|cta-glow|glowCta|hub-master-join__text h2" /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php /home/romain/Cotton/games/web/organizer_canvas.php /home/romain/Cotton/games/web/includes/canvas/css/canvas_styles.css`

## PATCH 2026-07-10 — Hub Master rééquilibrage vertical final

### Objectif
- rendre le carrousel à nouveau secondaire après la tentative `40vh`;
- donner plus de place au visuel/QR et à la respiration header -> hero;
- conserver le ratio réel `5 / 2`, le QR, le CTA rond et toute la logique existante.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - la grille centrale utilise des gaps différenciés: `--hub-master-gap-header-hero` et `--hub-master-gap-hero-program`;
  - le footer est borné à `clamp(240px, 36vh, 277px)` au lieu d'être la seule piste `1fr`;
  - le hero gagne de la largeur visuelle via un panneau QR borné `minmax(230px, clamp(230px, 22%, 270px))`;
  - les cartes reviennent à `height: clamp(225px, 34vh, 265px)` avec `max-height: calc(100% - 12px)`;
  - le footer compense sa marge haute avec `height: calc(100% - var(--hub-master-gap-hero-program))`.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/games diff --check -- web/modules/app_hub_view_helpers.php`
- `rg -n "hub-master-gap-header-hero|hub-master-gap-hero-program|grid-template-rows: auto auto clamp\\(240px, 36vh, 277px\\)|grid-template-columns: minmax\\(0, 1fr\\) minmax\\(230px, clamp\\(230px, 22%, 270px\\)\\)|margin-top: var\\(--hub-master-gap|padding: 6px max|height: clamp\\(225px, 34vh, 265px\\)|height: min\\(100%, clamp\\(270px, 40vh, 310px\\)|aspect-ratio: 5 / 2|object-fit: contain|data-hub-program-action|stopPropagation" /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`

## PATCH 2026-07-10 — Hub Master carrousel hauteur utile

### Objectif
- réduire le vide vertical dans la piste flexible du carrousel Master;
- conserver la troisième piste centrale en `minmax(0, 1fr)`;
- faire grandir les cartes selon la hauteur disponible sans toucher au hero ni au CTA rond.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - la piste réelle du carrousel est `.hub-master-program-footer .hub-program[data-hub-program-carousel]`;
  - ajout de `box-sizing: border-box` et d'un padding vertical compact `clamp(6px, 1vh, 12px)`;
  - les cartes `.hub-session[data-hub-program-card]` passent de l'ancienne borne `min(calc(100% - 14px), 260px)` à `min(100%, clamp(270px, 40vh, 310px))`;
  - la carte active reste `.hub-session.is-selected`, les flèches et le CTA rond restent inchangés.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/games diff --check -- web/modules/app_hub_view_helpers.php`
- `rg -n "hub-master-program-footer \\.hub-program|box-sizing: border-box|padding: clamp\\(6px, 1vh, 12px\\)|hub-master-program-footer \\.hub-session|height: min\\(100%, clamp\\(270px, 40vh, 310px\\)\\)|height: min\\(calc\\(100% - 14px\\), 260px\\)|grid-template-rows: auto auto minmax\\(0, 1fr\\)|hub-master-program-action|stopPropagation" /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`

## PATCH 2026-07-10 — Hub Master hero ratio réel et footer flexible

### Objectif
- utiliser toute la hauteur disponible de la colonne centrale;
- supprimer le recadrage vertical du visuel principal;
- dimensionner la ligne hero depuis le ratio réel du visuel et la largeur restante après le panneau QR;
- laisser le footer/carrousel absorber la hauteur restante.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - la grille centrale passe à `auto auto minmax(0, 1fr)`;
  - la ligne hero n'est plus une piste bornée à `clamp(285px, 36vh, 390px)`;
  - le visuel principal utilise `aspect-ratio: 5 / 2` et `object-fit: contain`;
  - le panneau QR est une colonne dynamique `minmax(220px, clamp(220px, 30%, 320px))` et s'étire à la même hauteur que le visuel;
  - les cartes du carrousel sont centrées et bornées à `min(calc(100% - 14px), 260px)` pour profiter du footer flexible sans coller aux bords avec le scale actif.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/games diff --check -- web/modules/app_hub_view_helpers.php`
- `rg -n "aspect-ratio: 15 / 8|hub-master-visual \\.hub-visual|object-fit: cover|grid-template-rows: auto auto minmax\\(0, 1fr\\)|grid-template-rows: auto minmax\\(0, clamp|height: min\\(calc\\(100% - 14px\\), 260px\\)|hub-master-program-action|stopPropagation" /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`

## PATCH 2026-07-10 — Hub Master rythme vertical et QR borné

### Objectif
- harmoniser l'espacement vertical entre header, ligne visuel/QR et carrousel;
- aligner strictement le panneau QR sur la hauteur du conteneur visuel;
- borner le QR en largeur et hauteur sans toucher au CTA rond ni au carrousel.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - la colonne centrale utilise un `row-gap` unique `--hub-master-row-gap`;
  - la piste visuel/QR passe en hauteur explicite bornée au lieu d'une piste `1fr` plafonnée;
  - les paddings verticaux redondants du header/carrousel sont retirés pour ne plus fausser le rythme;
  - le panneau QR est étiré à `height: 100%` comme le conteneur visuel;
  - le QR est placé dans une zone interne `hub-master-join__qr-frame` en grille, avec contraintes sur `img`, `canvas`, `svg` et enfants directs.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/games diff --check -- web/modules/app_hub_view_helpers.php`
- `rg -n "hub-master-row-gap|hub-master-center|hub-master-center-header|hub-master-hero|hub-master-program-footer \\.hub-program|hub-master-join|hub-master-join__qr-frame|hub-qr|position: absolute|hub-master-program-action|scale\\(" /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`

## PATCH 2026-07-15 — Hub Master CTA et centre pilotés par la carte

### Objectif
- conserver sans compression la zone visuelle des cartes Programme;
- placer l'unique CTA de la carte sélectionnée actionnable dans un footer intégré;
- supprimer toute ligne de footer lorsqu'aucun CTA n'est effectivement rendu, sans modifier la hauteur extérieure des cartes;
- libérer le coin supérieur droit du visuel pour une future action de paramétrage, sans créer de contrôle factice;
- compenser la hauteur du footer dans la grille centrale sans modifier les panneaux latéraux ni le ratio `5 / 2`.
- faire correspondre le contenu central à la session réellement sélectionnée, sans modifier la règle de sélection initiale ni le focus Hub.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - chaque carte Master sépare `.hub-session__visual` et `.hub-session__footer` dans le même article; le footer porte `hidden` par défaut;
  - le CTA Programme unique est déplacé dynamiquement dans le footer de la carte active actionnable;
  - `setAction()` retire d'abord `.has-program-action` et masque les footers de toutes les cartes, puis n'affiche celui de la carte sélectionnée que si le CTA a un libellé et une cible `link` ou `launch` valide;
  - toutes les cartes gardent la hauteur extérieure `calc(clamp(212px, 30vh, 234px) + 46px)`; la grille passe de `minmax(0, 1fr) 0` sans CTA à `minmax(0, 1fr) 46px` avec CTA;
  - sans footer, `.hub-session__visual` remplit la carte et son image/overlay reçoivent les arrondis inférieurs, sans `:empty` ni condition fondée sur le statut;
  - le bouton devient horizontal avec son icône et son libellé métier visible;
  - le clic sur le CTA ne déclenche plus le handler de sélection de carte;
  - les cartes latérales restent sélectionnables sans action et sans contrôle vide;
  - la zone visuelle des cartes est bornée à `clamp(212px, 30vh, 234px)` et la sélection à `scale(1.02)` pour préserver les bordures haute/basse dans la piste scrollable;
  - la piste Programme augmente de façon bornée; la ligne hero `minmax(0, 1fr)` absorbe la hauteur ajoutée, sans recadrer le visuel central;
  - branding et tous les podiums de sessions terminées exploitables partagent l'unique enveloppe `.hub-master-feature` en ratio `5 / 2`; aucun podium ne définit une hauteur concurrente;
  - `games_hub_get_context_from_request()` prépare au chargement une entrée par session et appelle le helper canonique `app_session_results_get_context()` uniquement pour les sessions terminées;
  - le payload serveur normalise `session_id`, `is_finished`, `result_context` et `has_usable_podium`; une session terminée sans ligne classée exploitable ne rend aucun podium vide;
  - chaque carte porte son `data-hub-session-id`; l'unique `selectCard()` appelle `renderCentralForSelectedSession()` après clic, clavier, flèche ou sélection initiale;
  - le rendu central relit `.is-selected`, affiche le podium prérendu correspondant et restaure le branding global dans tous les autres cas, sans fetch, reconstruction de classement ou écriture de focus;
  - le contenu du podium central utilise des `clamp()` en `cqh` calculés dans cette enveloppe, avec minima compacts et maxima bornés;
  - les lignes du contexte résultat réutilisent directement `photo_src`; une image est rendue si elle existe, sinon la carte textuelle historique reste centrée, sans fallback inventé ni requête navigateur;
  - la grille podium contraint le header puis les cartes dans l'espace restant; le header tient sur une ligne et une carte avec photo borne explicitement l'image à `clamp(124px, 48cqh, 188px)` avant de laisser le reste au rang, nom et score;
  - les photos utilisent `object-fit: cover` et `object-position: center` pour rogner les bords tout en gardant la partie centrale.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- rendu PHP de test puis `node --check` sur le script inline;
- assertions DOM comparatives branding/podium et podium avec/sans photo;
- assertions DOM avec cartes simultanément actionnable/non actionnable: footer caché pour les cartes sélectionnées ou voisines sans CTA, footer visible et CTA unique pour la carte actionnable, hauteur extérieure constante après clic et flèches;
- assertions de préparation: une invocation serveur par session terminée, aucune pour la session non terminée, correspondance stricte du podium au `session_id`;
- `git -C /home/romain/Cotton/games diff --check -- web/modules/app_hub_view_helpers.php`
- `rg -n "hub-session__visual|hub-session__footer|hub-master-program-action|stopPropagation|aspect-ratio: 5 / 2|object-fit: contain" /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`

## PATCH 2026-07-10 — Hub Master carrousel focus bouton rond

### Objectif
- finir l'UX du carrousel Programme Master en supprimant l'effet barre d'outils;
- rendre la carte sélectionnée dominante;
- déplacer l'action de lancement/reprise en bouton rond unique superposé à la carte focus.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - le carrousel Programme reste dans la zone centrale et ne passe plus sous les panneaux latéraux;
  - la ligne `Programme / X sessions`, le CTA texte séparé et les flèches en toolbar sont retirés;
  - les flèches deviennent des contrôles latéraux discrets;
  - la carte sélectionnée est agrandie/éclaircie avec bordure et ombre plus fortes;
  - le seul CTA programme visible est un bouton rond centré sur la carte sélectionnée, uniquement si la session est jouable;
  - les cartes latérales restent sélectionnables au clic/clavier sans lancement.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/games diff --check -- web/modules/app_hub_view_helpers.php`
- `rg -n "hub-master-program-footer__head|hub-session__cta|hub-session__actions|data-hub-program-card[\\s\\S]{0,220}data-hub-launch-session|>Programme<|>Reprendre<|>Lancer<" /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`

## PATCH 2026-07-10 — Hub Master programme carrousel footer

### Objectif
- tester un layout Master où le Programme devient un carrousel visuel horizontal en footer;
- déplacer les lots dans le panneau gauche;
- garder le panneau droit pour les inscrits live et conserver le CTA unique hors cartes.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - le panneau gauche affiche les lots de soirée/événement en liste compacte;
  - le centre conserve identité, visuel et QR, sans programme ni lots;
  - le programme Master est rendu en footer carrousel avec cartes visuelles sélectionnables;
  - clic carte/flèches = sélection uniquement;
  - le CTA unique du footer est synchronisé sur la carte sélectionnée: `Reprendre` pour focus actif, `Lancer` pour session jouable, aucun CTA pour terminée/passée/non jouée;
  - les cartes conservent heure, jeu, thème/titre, métas et badge d'état, sans CTA interne.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/games diff --check -- web/modules/app_hub_view_helpers.php`
- `rg -n "hub-session__cta|hub-session__actions|data-hub-program-card[\\s\\S]{0,220}data-hub-launch-session|>Reprendre<|>Lancer<" /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`

## PATCH 2026-07-10 — Hub Master programme timeline sans CTA cartes

### Objectif
- transformer la colonne Programme de `/hub/{hub_token}/master` en conducteur compact de soirée;
- retirer les CTA `Lancer` / `Reprendre` / résultats des cartes Programme;
- éviter l'état `Prête` sur une session passée non jouée.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - le rendu Master des sessions affiche heure, titre, jeu, format/version, durée et badge d'état sans action par carte;
  - la session focus active ou, à défaut, la prochaine session reçoit la priorité visuelle via les classes existantes;
  - les sessions passées non terminées affichent `Non jouée`;
  - une action unique centrale est affichée hors Programme quand `master_cta` expose une session jouable.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/games diff --check -- web/modules/app_hub_view_helpers.php`
- `rg -n "hub-master-program .*data-hub-launch-session|hub-session__cta|>Lancer<|>Reprendre<" /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`

## PATCH 2026-07-09 — Hub Master programme CTA priority/live panel

### Objectif
- corriger la hiérarchie visuelle des cartes sessions du panneau gauche Master sans modifier le modèle focus hub ni le runtime jeu;
- réserver le highlight fort à la session focus active, avec fallback sur la prochaine session uniquement si aucun focus actif n'existe;
- borner le panneau droit live en colonne scrollable et corriger le pluriel `joueur(s) inscrit(s)`.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - ajoute le calcul `has_focus_active` / `is_priority_session` pour séparer le focus fonctionnel de la mise en avant UI;
  - remplace le highlight fort `hub-session--next` par `hub-session--priority`;
  - garde `Reprendre` en CTA fort sur le focus actif, sinon `Lancer` fort seulement sur la prochaine session quand il n'y a aucun focus actif;
  - rend les sessions à venir non prioritaires en CTA secondaire discret mais cliquable;
  - remplace le CTA des sessions terminées par un statut sobre `Terminée`;
  - conserve le footer CTA collé sous le visuel, sans `Paramétrer` ni `.hub-session__prep`;
  - passe le panneau `Inscrits live` en colonne bornée avec liste interne scrollable;
  - corrige `0 joueurs inscrits`, `1 joueur inscrit`, `N joueurs inscrits` côté rendu serveur et polling JS.

### A suivre
- Classement/agrégat hub: des helpers résultats existent côté sessions globales, mais aucun payload agrégé propre n'est exposé dans le helper Hub Master à ce périmètre. Ne pas recalculer par points/rangs dans l'UI; brancher seulement quand un agrégat hub canonique sera disponible.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/games diff --check -- web/modules/app_hub_view_helpers.php`
- `rg -n "Paramétrer|hub-session__prep" /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`

## PATCH 2026-07-09 — Passe UI Hub Master / Hub Play

### Objectif
- améliorer uniquement le rendu Hub Master et Hub Play avant les évolutions fonctionnelles suivantes;
- conserver le modèle focus hub distinct du runtime jeu;
- garder l'ordre commun: active/en cours, à venir, suspendues, terminées.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - le panneau gauche Master affiche toutes les sessions et scrolle indépendamment;
  - le CTA `Paramétrer` est masqué, le CTA principal devient un footer de carte avec icône Bootstrap existante;
  - le texte du CTA Master est calculé selon la luminosité de la couleur secondaire de branding;
  - le bloc QR Master s'aligne en hauteur avec le visuel central sans déformer le QR;
  - les lots fallback deviennent `1ᵉʳ prix`, `2ᵉ prix`, `3ᵉ prix`;
  - le panneau droit Master affiche la liste scrollable des pseudos inscrits et masque le message d'attente dès qu'il y a un inscrit;
  - Hub Play sépare l'inscription et le compte joueur Cotton en deux cartes distinctes;
  - le bloc prêt devient `Bienvenue {pseudo} 🎉` avec texte court, sans CTA global de reprise.
- `../global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`
  - ajoute `app_games_hub_players_list_active(...)`, lecture bornée des joueurs actifs pour l'UI Master;
  - trie le programme Hub Play avec les mêmes buckets que Master;
  - garde `Session quittée` + `Rejoindre à nouveau` uniquement pour la session focus active quittée;
  - affiche `Suspendue` sans CTA joueur sur les sessions non-focus encore runtime `running`.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- `git -C /home/romain/Cotton/games diff --check -- web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/global diff --check -- web/app/modules/jeux/hubs/app_games_hubs_functions.php`

## PATCH 2026-07-09 — Hub active session focus

### Objectif
- distinguer la session active du hub de l'etat runtime reel des jeux;
- eviter qu'une ancienne session encore `running` et quittee par un joueur bloque l'auto-join vers la session suivante;
- ne jamais forcer une ancienne session en `terminée` pour simuler la progression hub.
- aligner l'UI Hub Play: aucune reprise proposee sur une session non-focus precedente.
- stabiliser l'UI Hub Master: ordre focus, badge `Suspendue` et CTA `Relancer` sur les anciennes sessions encore runtime `running`.

### Modifie
- `../global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`
  - ajoute `games_hubs.active_session_id` / `active_session_activated_at`;
  - ajoute `app_games_hub_focus_set_active(...)`;
  - enrichit les sessions avec `hub_focus_status` et `hub_is_focus_active`;
  - filtre l'auto-join sur la session focus active uniquement;
  - garde les reprises manuelles/directes possibles hors auto-join.
  - retire les CTA `manual_join_session` des sessions `previous` dans le programme Hub Play;
  - exige `hub_is_focus_active=1` pour afficher un etat `running` avec CTA;
- `../games/web/modules/app_hub_view_helpers.php`
  - trie le programme Master par buckets: focus actif, prochaines sessions, suspendues, terminees;
  - affiche `Suspendue` pour les sessions non-focus encore runtime `running`;
  - limite le libelle master `Reprendre` au focus courant;
  - affiche `Relancer` sur une session suspendue et reutilise l'action `launch_session` pour reposer le focus hub sans modifier le runtime.
  - bloque `manual_join_session` côté Hub Play pour une session non-focus, sans modifier les routes `/play/{game}/{token}`.
- `../games/web/includes/canvas/sql/2026-07-09_games_hubs_active_session_focus.sql`
  - migration versionnee focus hub.

### Verification locale
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `git diff --check`

## PATCH 2026-07-09 — Hub Play resume depuis cookies bridge session

### Objectif
- apres un QR session hub et un register session classique, afficher directement `{pseudo} Prêt à jouer` sur Hub Play;
- ne plus dépendre d'une identité `localStorage` créée par le register hub;
- conserver les garde-fous multi-hub, player left et EP.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - ajoute `games_hub_player_from_cookie(...)`;
  - `current_player`, `active_launched_session` et `manual_join_session` utilisent le fallback cookie validé contre le hub courant;
  - reprise EP par `$_SESSION['id_joueur']` et par cookie `ep_{id}`;
  - logs `hub_play_resume_from_cookie_*`.
- `../games/web/includes/canvas/play/register.js`
  - ajoute `Secure` en HTTPS aux cookies hub poses depuis `hub_bridge`;
  - bump `REGISTER_JS_VERSION` a `2026-07-09_04_hub_cookie_resume`.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER` a `v=2026-07-09_04`.

### Verification locale
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `php -l /home/romain/Cotton/games/web/config.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`

## PATCH 2026-07-09 — Hub session QR implicit attach

### Objectif
- faire d'un QR session classique une porte d'entree hub quand la session appartient a une soirée hub;
- conserver l'inscription session immediate sans redirection préalable vers le hub;
- eviter les doublons d'identite entre participation session, hub guest et compte EP.

### Modifie
- `../games/web/player_canvas.php`
  - detecte l'appartenance hub d'une session QR et expose `AppConfig.hubSessionBridge`;
  - ne redirige pas et laisse le register classique si aucune identite hub existante n'est resolue.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - ajoutent `hub_bridge` au retour `player_register`;
  - appellent le helper global depuis le token session public apres l'upsert runtime;
  - transmettent `sourceTable/sourceId` pour rattachement EP.
- `../games/web/includes/canvas/play/register.js`
  - pose les cookies `cotton_hub_token` / `cotton_hub_player_token` depuis `hub_bridge`;
  - met a jour `AppConfig.hubToken` et `AppConfig.hubAutoPlayer` pour retour hub et quit session;
  - conserve le flux papier et le flux hors hub.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER` a `v=2026-07-09_03`.

### Verification locale
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `php -l /home/romain/Cotton/games/web/config.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`

## PATCH 2026-07-09 — Hub identity session access hardening

### Objectif
- centraliser la résolution hub player -> session dans un backend unique;
- empêcher le retour au formulaire session classique quand le contexte hub est valide;
- distinguer session numérique, session papier, auto-join, rejoin manuel et départ volontaire de session;
- rendre le clic manuel `Rejoindre à nouveau` équivalent au contrat backend d'auto-join, mais en mode manuel explicite;
- réintroduire un programme compact Hub Play basé sur l'état backend.

### Modifie
- `../global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`
  - ajoute `app_hub_player_resolve_session_access(...)`;
  - ajoute `app_games_hub_get_for_session(...)` pour retrouver le hub actif d'une session scannée par QR;
  - ajoute `app_games_hub_player_program_get(...)` pour exposer au Hub Play une liste compacte calculée depuis sessions, runtime, mapping et resolver;
  - conserve `app_games_hub_player_join_session(...)` comme wrapper compat;
  - enrichit `games_hubs_players_sessions` avec les états `auto_joined_at`, `manual_joined_at`, `last_joined_at`, `left_at`, `completed_at`, `join_count`, `last_action`;
  - retourne une identité session canonique: `player_id`, `playerId`, pseudo, auth, hub player, session, token, jeu, type `digital|paper`, mapping et flags.
- `../games/web/modules/app_hub_view_helpers.php`
  - ajoute `leave_session`;
  - ajoute `manual_join_session`, qui appelle `app_hub_player_resolve_session_access(...)` en `join_source=manual` / `manual_rejoin=true`, puis redirige vers `/play/{game}/{token}` avec contexte hub complet et `hub_join=manual`;
  - stabilise `active_launched_session`: le polling renvoie HTTP 200 avec `play_url=''` si l'auto-join échoue temporairement, au lieu d'un 400 navigateur;
  - pose les cookies games `cotton_hub_token` et `cotton_hub_player_token` apres inscription/reprise hub, et les retire seulement quand le joueur quitte la soirée;
  - affiche la confirmation papier `Ton inscription est confirmée. Récupère ta feuille de jeu auprès de l’organisateur.`;
  - n'auto-redirige plus un joueur qui a quitté volontairement une session et propose un CTA manuel `Rejoindre à nouveau`;
  - affiche sous la carte prêt un programme compact des sessions avec badges `À venir`, `En cours`, `Session quittée`, `Papier`, `Terminée` et CTA backend si nécessaire.
- `../games/web/player_canvas.php`
  - utilise le resolver commun en accès direct `/play/{game}/{token}?hub_token=...`;
  - reprend aussi une identité hub sur QR session simple `/play/{game}/{token}` via cookies games ou `$_SESSION['id_joueur']`, uniquement si le hub player existe déjà dans le hub actif de cette session;
  - expose les flags de résolution dans `AppConfig.hubAutoPlayer`.
- `../games/web/includes/canvas/play/play-ui.js`
  - notifie le hub en best-effort sur quit volontaire de session, sans quitter la soirée.
- `../games/web/includes/canvas/play/register.js`
  - corrige la régression manual rejoin: `hub_join=manual` supprime/ignore `leftVoluntarily_{sessionId}` avant `tryAutoRegisterFromHub`, pour laisser `AppConfig.hubAutoPlayer` finaliser sans formulaire session.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER` à `v=2026-07-09_02`.
- `../games/web/includes/canvas/sql/2026-07-09_games_hubs_players_sessions_access_state.sql`
  - migration versionnée des champs d'état mapping.

### Garde-fous
- hors hub, le register session historique reste inchangé;
- un simple `hub_token` ne suffit pas: hub actif, session rattachée, hub player actif et mapping/participation résolus sont requis;
- un QR session sans paramètres hub ne bypass le formulaire classique que si un cookie/token hub existant ou un compte EP connecté retrouve un hub player actif du même hub;
- session papier = inscription runtime réelle + confirmation hub, sans redirection `/play`;
- session numérique = inscription runtime réelle + redirection seulement si auto-join autorisé;
- auto-join interdit si le mapping est `left`; manual rejoin autorisé uniquement via clic explicite `manual_join_session`;
- `Quitter cette session` marque le mapping session `left`; `Quitter la soirée` conserve le statut hub player `left`.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `git -C /home/romain/Cotton/games diff --check`
- `git -C /home/romain/Cotton/global diff --check`

## PATCH 2026-07-08 — Hub master launch sessions Lot 2

### Objectif
- lancer une session depuis la carte programme du hub master sans passer par un second lobby nominal;
- injecter les joueurs hub actifs dans la participation runtime session;
- faire basculer automatiquement les joueurs hub play vers la session active.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - ajoute les actions `launch_session` et `active_launched_session`;
  - ajoute sur les cartes programme master les CTA `Lancer`/`Reprendre`/`Résultats` et `Paramétrer`;
  - ajoute le polling hub play vers la session active.
- `../games/web/modules/app_hub_master_ajax.php`
  - traite les actions hub avant rendu master.
- `../games/web/organizer_canvas.php`
  - expose `AppConfig.hubLaunchAutoStart` via `?hub_launch=1`.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - déclenche le flux `beginPlayFlow({ source: 'hub' })`, avec confirmation auto et jingle existant.
- `../games/web/player_canvas.php`
  - expose `AppConfig.hubAutoPlayer` quand un mapping hub/session actif complet est trouvé depuis `hub_token` + `hub_player_token`/`hub_player_id`.
- `../games/web/includes/canvas/play/register.js`
  - logge `register_js_loaded` en console au chargement;
  - appelle `bootHubAutoRegister()` au boot module et au DOM ready avec garde `window.__hubAutoRegisterStarted`;
  - teste le mapping serveur actif avant `checkSession`, finalise directement Quiz/Blind Test, émet `player/ready`, garde Bingo sur le submit historique avec bypass gate strict;
  - pour Bingo hub, attend `grid_assign` puis `grid_hydrate` avec 5 retries courts, persiste la grille, émet `player/bingo:setGrid`, puis seulement `player/ready`;
  - trace les étapes `hub_auto_player_*` et `hub_auto_player_bingo_*`.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER` à `v=2026-07-08_16` pour casser le cache du module player.
- `../games/web/includes/canvas/sql/2026-07-08_games_hubs_players_sessions.sql`
  - migration versionnee du mapping.

### Garde-fous
- `Paramétrer` ne lance pas et n'injecte aucun joueur;
- `Lancer` ne relance pas une session `running` ou terminee;
- le lancement réel reste porté par le boot organizer JS/WS commun, faute d'action PHP stable de start session multi-jeux;
- le fallback hub play injecte seulement le joueur hub actif courant dans une session déjà `running`.
- l'URL player hub transporte explicitement `hub_player_token` et `hub_player_id`; aucun auto-player n'est accepté depuis le seul `localStorage` navigateur.
- le bypass `checkSession` exige `AppConfig.hubAutoPlayer.enabled`, un pseudo, `player_id=p:*` et `playerId>0`; un simple `hub_token` ne suffit pas.

### Verification
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `php -l /home/romain/Cotton/games/web/modules/app_hub_master_ajax.php`
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`

## PATCH 2026-07-08 — Hub play runtime players V1

### Objectif
- créer/reprendre une inscription joueur au niveau soirée/événement hub;
- couvrir les invités pseudo simple et les comptes joueur Cotton / EP;
- rendre le compteur hub cohérent après refresh/multi-onglets sans créer de participation session.

### Modifie
- `../global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`
  - ajoute `games_hubs_players` dans `app_games_hub_schema_ensure()`;
  - ajoute les helpers `app_games_hub_player_get_current`, `app_games_hub_player_register_guest`, `app_games_hub_player_register_ep`, `app_games_hub_player_leave`, `app_games_hub_player_touch`, `app_games_hub_players_count_active`;
  - ajoute `app_games_hub_player_prepare_ep_return(...)` pour le retour Play compte joueur vers `/hub/{hub_token}/play?ep_connect_token=...`.
- `../games/web/modules/app_hub_view_helpers.php`
  - branche les actions `current_player`, `register_guest`, `leave_player`, `players_count`;
  - remplace l'etat prêt local-only par un état DB;
  - affiche le bloc `Compte joueur Cotton` côté hub play;
  - lit le compteur actif DB pour le mini header play et le panneau master.
- `../play/web/ep/ep_signin.php`, `../play/web/ep/ep_signup.php`
  - transportent `hub_account_join` et `id_securite_games_hub`.
- `../play/web/ep/modules/compte/authentification/ep_authentification_script.php`, `../play/web/ep/modules/compte/joueur/ep_joueur_script.php`
  - redirigent les connexions/creations compte joueur vers le hub si le contexte hub est present.
- `../global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - ajoute une branche hub dans `app_joueur_session_inscription_get_link(...)` avant le flux session historique.
- `../games/web/includes/canvas/sql/2026-07-08_games_hubs_players.sql`
  - migration versionnee pour la table runtime hub players.

### Garde-fous
- aucune insertion dans `cotton_quiz_players`, `blindtest_players`, `bingo_players`;
- aucune creation de participation session ou mapping session;
- conflit pseudo renvoye proprement sans casser la page;
- les lignes quittées passent `status='left'` et restent conservees.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/ep_signin.php`
- `php -l /home/romain/Cotton/play/web/ep/ep_signup.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/authentification/ep_authentification_script.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/joueur/ep_joueur_script.php`

## PATCH 2026-07-08 — Hub play V1 validation pseudo EP

### Objectif
- empêcher le hub de stocker une identité locale qui sera refusée ensuite par `player_register` à cause d'un conflit EP référencé;
- réutiliser la garde serveur existante sans pré-inscrire ni écrire dans les tables de jeu.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - ajoute une validation pseudo hub locale + serveur;
  - appelle `canvas_session_has_referenced_participant_name(...)` pour chaque session rattachée au hub;
  - expose une réponse JSON `validate_player_name` via le helper hub;
  - bloque le stockage `hub:{hubToken}:player_identity` si le serveur renvoie `USERNAME_REFERENCED`.
- `../games/web/modules/app_hub_play_ajax.php`
  - route les actions hub play avant le rendu HTML.

### Garde-fous
- aucune écriture dans `cotton_quiz_players`, `blindtest_players`, `bingo_players`;
- pas de réservation pseudo session ni consommation Bingo;
- pas de compteur hub serveur ni garantie de doublon inter-navigateurs.

### Verification
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `php -l /home/romain/Cotton/games/web/modules/app_hub_play_ajax.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-07-08 — Hub play V1 alignement visuel session

### Objectif
- aligner visuellement le Hub Play sur la page joueur historique;
- garder seulement les wordings et assets propres au contexte soirée/événement;
- rendre l'attente hub en cartes historiques: prêt, lots, programme, quitter.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - remet le `player-header .bar` sur le Hub Play avec titre, meta, chip joueurs et chip état soirée;
  - charge Bootstrap Icons et reprend l'icône historique `bi-people-fill` dans la chip joueurs;
  - calcule l'horaire de première session, l'état soirée et les sessions visibles non terminées;
  - retire la bordure du visuel haut, force un rendu plein largeur contraint comme les pages session et passe le fallback visuel hub au ratio `600x240`;
  - masque le contexte de la première carte et le label visible au-dessus du champ pseudo;
  - remplace le CTA par `S'inscrire`;
  - remplace l'état inscrit riche par `#screen-waiting` en cartes transparentes: prêt puis `A gagner`;
  - affiche les 3 lots soirée/événement;
  - retire finalement le bloc `Au programme`;
  - déplace `Quitter la soirée` en CTA léger de bas de page.

### Garde-fous
- pas de changement routes, master, auto-redirection, équipes, auto-inscription session ou écritures serveur;
- le compteur joueur reste local à l'identité navigateur en attendant un compteur hub serveur.

### Verification
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`

## PATCH 2026-07-08 — Hub play V1 UI historique + pseudo runtime

### Objectif
- rapprocher encore le hub play de l'inscription joueur historique;
- appliquer au pseudo hub les règles générales du runtime session avant stockage local;
- documenter les limites restantes sur doublons hub et conflits EP.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - aligne la carte d'inscription sur `#register-screen`: titre `Inscription`, texte historique adapté soirée, champ `Pseudo`, `form-control`, compteur, erreur et CTA compact;
  - reprend le contraste historique de carte claire sur fond player sombre;
  - normalise le pseudo par collapse espaces + trim;
  - refuse localement les pseudos vides et les pseudos de plus de 20 caractères avec le message runtime `Le pseudo doit contenir entre 1 et 20 caractères.`;
  - ne tronque plus le pseudo avant stockage `hub:{hubToken}:player_identity`;
  - conserve l'état inscrit `Prêt à jouer 🎉`, `En attente du lancement…` et `Quitter la soirée`.

### Audit validation
- `register.js` applique déjà trim/collapse espaces et limite `MAX_CHAR=20` avant `player_register`.
- Les backends Quiz, Blind Test et Bingo refusent `BAD_USERNAME` si vide ou trop long, `USERNAME_ALREADY_USED` sur doublon session et `USERNAME_REFERENCED` si le pseudo correspond à un participant EP référencé.
- Ces contrôles de doublon/EP dépendent d'une session cible et/ou d'une table joueurs; le hub play V1, local et sans session active, ne peut pas garantir l'unicité entre navigateurs.

### Garde-fous
- pas de pré-inscription session ni écriture dans `cotton_quiz_players`, `blindtest_players`, `bingo_players`;
- pas de consommation de grille Bingo;
- pas de création d'endpoint de validation qui donnerait une garantie d'unicité incomplète;
- pas de changement équipes, auto-redirection ou master.

### Verification
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`

## PATCH 2026-07-08 — Hub play V1 correctif UI historique

### Objectif
- réaligner `/hub/{hub_token}/play` sur l'ergonomie des pages player historiques;
- supprimer le doublon titre/date entre header et carte;
- garder le formulaire visible rapidement sur mobile;
- ajouter une sortie locale volontaire sans écriture serveur.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - retire le header sticky du play hub et laisse le visuel hub comme signal haut de page;
  - remplace le contenu avant inscription par une carte compacte `Rejoins la soirée` avec label `Ton pseudo` et CTA `Je suis prêt`;
  - garde les états avant Jour J et après Jour J fermés sans pseudo;
  - remplace `Changer de pseudo` par `Quitter la soirée`;
  - supprime localement `hub:{hubToken}:player_identity` au quit et pose `hub:{hubToken}:leftVoluntarily`;
  - garde le programme seulement comme rappel secondaire après inscription.

### Garde-fous
- pas de changement session, équipes, auto-redirection, auto-inscription session ou migrations;
- pas d'écriture serveur au moment de rejoindre ou quitter le hub play;
- pas de modification des routes historiques `/play/{game}/{session_token}`.

### Verification
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`

## PATCH 2026-07-08 — Hub play V1 inscription locale soirée

### Objectif
- transformer `/hub/{hub_token}/play` en entrée joueur mobile-first avec inscription hub locale;
- appliquer les règles date hub: avant Jour J pas de pseudo libre, Jour J inscription pseudo libre, après Jour J fermé;
- conserver l'inscription effective session dans `/play/{game}/{session_token}` via `register.js`;
- préparer le retour vers le hub quand une session joueur est ouverte depuis un hub.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - ajoute l'état date hub et des URLs de session pouvant embarquer `hub_token`;
  - remplace le play hub par un écran simple avant inscription + lobby local après inscription;
  - stocke uniquement une identité navigateur `hub:{hubToken}:player_identity` avec pseudo, `p:*` stable, timestamps et schéma;
  - garde le programme secondaire et ne rend pas de redirection automatique vers une session active.
- `../games/web/modules/app_play_ajax.php`
  - valide strictement `hub_token` / `hubToken` et le transmet au player.
- `../games/web/player_canvas.php`
  - expose `AppConfig.hubToken` au player historique.
- `../games/web/includes/canvas/play/play-ui.js`
  - renvoie vers `/hub/{hub_token}/play` après sortie joueur numérique ou `SESSION_ENDED` si `hubToken` est valide.
- `../games/web/includes/canvas/play/register.js`
  - applique le même retour hub pour les sorties papier.
- `../games/web/config.php`
  - bump local `CANVAS_ASSET_VER` pour invalider le cache des JS player.

### Garde-fous
- aucune écriture dans `cotton_quiz_players`, `blindtest_players`, `bingo_players` depuis le hub play;
- aucune pré-inscription aux sessions, aucune réservation de pseudo session, aucune grille Bingo consommée;
- pas d'auto-redirection basée sur une session du jour ou sur `checkSession`;
- pas de modification équipes ni de correctif Blind Test runtime dans ce lot.

### Verification
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `php -l /home/romain/Cotton/games/web/modules/app_play_ajax.php`
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`

## PATCH 2026-07-08 — Hub master V1 simplifie avant play

### Objectif
- simplifier `/hub/{hub_token}/master` comme ecran d'accueil soiree/evenement projetable;
- conserver un viewport fixe 100vh sans scroll global;
- afficher header contexte, visuel soiree, gros QR vers `/hub/{hub_token}/play`, programme lateral et inscrits live;
- retirer les fonctions avancees animateur du master pour ce lot;
- ne pas modifier `/hub/{hub_token}/play` fonctionnellement.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - remplace le rendu master par une grille `hub-master-screen` a 3 colonnes: programme, visuel+QR, inscrits live;
  - borne le programme master a 5 sessions visibles avec mention `+ X sessions`;
  - marque la prochaine session sans CTA d'ouverture;
  - conserve le visuel fallback Cotton multi-jeux et les variables `hub_*`;
  - supprime du rendu master les lots fallback, le CTA principal de lancement, le footer organisateur et les modales.

### Garde-fous
- pas de modification fonctionnelle de `/hub/{hub_token}/play`;
- pas de modification des interfaces historiques session;
- pas de changement Quiz / Blind Test serveur / Bingo serveur;
- pas de branding de session applique arbitrairement.

### Verification
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `php -l /home/romain/Cotton/games/web/modules/app_hub_master_ajax.php`
- `php -l /home/romain/Cotton/games/web/modules/app_hub_play_ajax.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-07-07 — Hub master/play: refonte structure soirée/événement

### Objectif
- refondre `/hub/{hub_token}/master` comme interface animateur soirée/événement;
- refondre `/hub/{hub_token}/play` comme entrée joueur immersive soirée/événement;
- refaire ces deux surfaces comme lobbies soirée/événement, sur la base directe des lobbies historiques de session en attente;
- reprendre la structure de `organizer_canvas.php` pour le master hub sans modifier le canvas historique;
- reprendre la structure de `player_canvas.php` pour le play hub sans modifier le canvas historique;
- ajuster le master en écran externe fixe sans scroll global;
- ajuster le play en layout mobile-first;
- rendre visible le branding effectif déjà résolu par le helper global;
- préparer les variables `hub_*` pour le futur branding opération sans écrire de branding.

### Modifie
- `../games/web/modules/app_hub_view_helpers.php`
  - lit les couleurs, logo, visuel et police dans la structure `general_branding` imbriquée;
  - conserve les fallbacks plats existants.
  - ajoute CTA master vers `/master/{session_token}`, programme secondaire, QR soirée, lots fallback, panneau joueurs préparatoire, footer de gestion et modales structurelles;
  - applique au hub master les wrappers/classes du lobby organizer: `main-section`, `responsive-center`, `header-wrapper`, `waiting-container`, `qr-container`, `main-qr-container`, `lots-container`, `main-visual`, `organisateur-menu`, `orga-btn`, `play-pause-btn`;
  - applique au hub play les wrappers/classes du lobby player: `player-root`, `header-banner`, `player-header`, `player-main`, `screen`, `register-screen`, `screen-waiting`, `lots-card`, `card`, `prize`;
  - impose au master une grille 100vh compacte avec footer intégré et programme limité à 3 lignes visibles + mention de sessions supplémentaires;
  - centre le play sur une largeur smartphone avec boutons tactiles et scroll naturel;
  - remplace les cards blanches par un thème sombre Canvas/player: fond immersif, panneaux semi-transparents, contours lumineux, QR/lots/programme intégrés et CTA accentué;
  - garde le hub play comme simple porte d'entrée vers les routes play historiques, sans inscription transverse.

### Garde-fous
- pas de modification des masters/play/remote historiques;
- pas d'écriture ou propagation branding;
- pas d'agrégation arbitraire des lots de sessions;
- pas de patch Quiz/Blind Test/Bingo dans ce lot.

### Verification
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-07-07 — Supra-interface soiree/evenement: routes read-only Lot 2

### Objectif
- creer les routes visibles read-only `/hub/{hub_token}/master` et `/hub/{hub_token}/play`;
- afficher le branding effectif, les informations de soiree/evenement et le programme des sessions;
- conserver les routes session existantes.

### Modifie
- `../games/web/.htaccess`
  - ajoute les rewrites `/hub/{hub_token}/master` et `/hub/{hub_token}/play`.
- `../games/web/modules/app_hub_view_helpers.php`
  - centralise validation token, lecture hub/client/sessions/branding et rendu HTML.
- `../games/web/modules/app_hub_master_ajax.php`
- `../games/web/modules/app_hub_play_ajax.php`

### Garde-fous
- pas de changement `/master/{token}`, `/play/{game}/{token}`, `/remote/{game}/{token}`;
- pas de lancement, edition, scoring, lots, options, inscription joueur, mapping participant, classement global, polling ou WS hub;
- pas d'ecriture branding.

### Verification
- `php -l /home/romain/Cotton/games/web/modules/app_hub_view_helpers.php`
- `php -l /home/romain/Cotton/games/web/modules/app_hub_master_ajax.php`
- `php -l /home/romain/Cotton/games/web/modules/app_hub_play_ajax.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-07-07 — Supra-interface soiree/evenement: conteneur Lot 1

### Objectif
- documenter le conteneur technique `games_hubs` cree cote `global` et initialise cote `pro`;
- preparer le futur hub soiree/evenement sans modifier les interfaces session directes.

### Garde-fous
- aucune modification du repo `games` dans ce lot;
- routes directes conservees: `/master/{token}`, `/play/{game}/{token}`, `/remote/{game}/{token}`;
- aucune interface master/play/remote hub creee;
- aucun changement scoring, lots, options, inscriptions session ou WS.

### Verification
- verifier que `games/web/.htaccess` conserve les trois routes session directes existantes.

## PATCH 2026-07-07 — Remote Blind Test: equipes et membres sans doublons

### Objectif
- aligner la remote sur le rendu master pour les classements Blind Test mixtes equipes + solos;
- ne plus afficher une equipe runtime et ses membres comme lignes concurrentes;
- garder l'equipe préparée visible en lobby, y compris à 1 membre, sans badge runtime.

### Modifie
- `../games/web/includes/canvas/remote/remote-ui.js`
  - ajoute une normalisation locale des lignes remote Blind Test;
  - separe equipe préparée lobby et equipe runtime active;
  - déduplique les membres couverts par `members` / `memberIds` d'une ligne equipe;
  - applique la liste normalisee au lobby, au classement live et au podium final;
  - aligne le markup nom + badge equipe sur le rendu master;
  - affiche aussi le badge `ÉQUIPE` dans la liste d'attente remote pour une ligne equipe valide avant démarrage;
  - affiche `Joueurs inscrits ({total joueurs})` pour conserver le nombre réel de joueurs connectés même quand la liste montre des participants dédupliqués.
- `../games/web/includes/canvas/css/remote_styles.css`
  - reprend le layout flex du badge `ÉQUIPE` master dans les classements/podiums remote.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js`
- `git -C /home/romain/Cotton/games diff --check -- web/includes/canvas/remote/remote-ui.js`

## PATCH 2026-07-07 — Player Blind Test: bandeau equipe runtime seulement

### Objectif
- ne plus afficher le bandeau `ÉQUIPE · {teamName}` pendant le jeu si l'equipe préparée ne compte qu'un seul membre runtime;
- conserver l'affichage lobby d'une equipe préparée à 1 membre avant lancement;
- aligner le wording de fin et les feedbacks equipe sur `isTeam` / `teamMemberCount`.

### Modifie
- `../games/web/includes/canvas/play/play-ui.js`
  - separe l'etat lobby `teamState` de l'etat equipe active runtime;
  - affiche le bandeau et les messages `Ton équipe...` uniquement si le payload runtime indique une equipe 2+;
  - nettoie le bandeau quand le runtime indique solo.
- `../games/web/includes/canvas/play/play-ws.js`
  - relaie `teamMemberCount` depuis `updatePlayers`.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-07-07 — Blind Test: equipes runtime solo affichées comme joueurs

### Objectif
- ne plus afficher badge ou nom d'equipe pour une equipe runtime Blind Test avec moins de 2 membres;
- filtrer les lignes `blindtest_session_teams` invalides et normaliser les payloads de podium/classement.

### Modifie
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - ignore les equipes persistées ou issues du ranking final si `players_count` / `teamMemberCount` est inférieur à 2;
  - corrige la callback de filtrage pour accepter `null` avant `array_filter`.
- `../games/web/includes/canvas/core/canvas_display.js`
- `../games/web/includes/canvas/remote/remote-ui.js`
  - ne reconnaissent plus une entrée comme équipe si `teamMemberCount`, `team_member_count` ou `members` indique moins de 2 membres.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-07-06 — Player Blind Test: bandeau equipe commun

### Objectif
- afficher au joueur membre d'une equipe Blind Test un repere compact `ÉQUIPE · {teamName}`;
- conserver ce repere pendant la partie, hors etats attente/termine;
- faire evoluer le meme bandeau vers le feedback quand un coequipier a deja repondu.

### Modifie
- `../games/web/includes/canvas/play/play-ui.js`
  - derive le nom equipe depuis `teamState` / `teamName` courant;
  - affiche un bandeau `team-answer-banner is-info` uniquement en Blind Test, pendant la partie, pour un membre d'equipe;
  - reutilise ce meme bandeau pour les etats feedback `pending`, `success`, `error`.
  - conserve le feedback equipe jusqu'au changement d'extrait, afin qu'un refresh d'options ne le remplace pas trop vite.
- `../games/web/includes/canvas/css/player_styles.css`
  - centre le texte du bandeau equipe, ajoute la pastille interne `ÉQUIPE` et l'ellipsis du nom long.

### Verification
- `node --check` via copie `.mjs` de `play-ui.js` dans `/tmp`.
- `git -C /home/romain/Cotton/games diff --check -- web/includes/canvas/play/play-ui.js web/includes/canvas/css/player_styles.css`

## PATCH 2026-07-06 — Blind Test: libelle equipe sans compteur

### Objectif
- afficher les equipes runtime Blind Test sous leur nom public brut;
- signaler l'identite equipe par un badge compact `ÉQUIPE`;
- conserver les compteurs membres uniquement dans les champs techniques.

### Modifie
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `blindtest_api_session_teams_get()` renvoie `playerName` = nom equipe brut, sans suffixe `(n)`.
- `../games/web/includes/canvas/core/canvas_display.js`
  - podium et classement complet master affichent le nom brut + badge `ÉQUIPE` pour les lignes equipe.
- `../games/web/includes/canvas/remote/remote-ui.js`
  - meme rendu pour remote/classement de fin.
- `../games/web/includes/canvas/css/canvas_styles.css`
- `../games/web/includes/canvas/css/remote_styles.css`
  - style du badge compact.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- Parse ES modules via copie `.mjs` dans `/tmp` et `node --check`.
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-07-06 — Blind Test: snapshot termine et compteurs equipes

### Objectif
- afficher les podiums/classements agreges equipes + solos a l'ouverture d'une session Blind Test terminee;
- couvrir aussi le cold open PHP sans relance WS;
- conserver les badges joueurs sur `totalPlayers`, et utiliser `rankingEntriesTotal` seulement pour le classement.

### Modifie
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - ajout `blindtest_api_session_teams_get()` pour relire `blindtest_session_teams`.
  - correction de la relecture: `session_teams_get` filtre sur `blindtest_session_id = sessionPrimaryId`, car `session_id` stocke le token public de session; fallback legacy sur `session_id` numerique.
  - les sessions jouees avant la persistance effective de `blindtest_session_teams` restent sur le fallback historique.
  - `blindtest_resolve_token()` remplace les membres par les equipes runtime dans `Preload.players` et `Preload.podium` quand la session est terminee;
  - `Preload.totalPlayers` vient de `blindtest_sessions.total_players` et `Preload.rankingEntriesTotal` du classement equipes + solos.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - utilise `Preload.totalPlayers`, `Preload.rankingEntriesTotal` et `Preload.podium` au boot master.
- `../games/web/includes/canvas/core/ws_effects.js`
  - hydrate le store avec `rankingEntriesTotal` sur `endGame`.
- `../games/web/includes/canvas/core/score_store.js`
  - stocke `rankingEntriesTotal` separement de `totalPlayers`.
  - preserve les rankings Blind Test contenant des equipes runtime aussi en statut termine, afin que les resync DB joueurs bruts ne remplacent pas le classement complet.
- `../games/web/includes/canvas/remote/remote-ui.js`
  - ignore en session Blind Test terminee les updates de liste sans equipe quand la liste courante/preload contient deja des equipes runtime.
- `../games/web/includes/canvas/play/play-ws.js`
  - relaie les deux totaux sur snapshots statiques et messages WS.
- `../games/web/includes/canvas/play/play-ui.js`
  - n'utilise plus `players.length` comme fallback badge quand `rankingEntriesTotal` est fourni.
- `../games/web/includes/canvas/remote/remote-ws.js`
  - relaie `rankingEntriesTotal`.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- Parse ES modules via `node --experimental-vm-modules`.
- `git diff --check` sur les fichiers modifies.

## PATCH 2026-07-06 — Player Blind Test: fin equipe et total participants

### Objectif
- adapter le wording de fin quand le joueur est membre d'une equipe runtime;
- afficher le rang sur le nombre de participants de classement (equipes + solos);
- conserver le badge joueurs sur le nombre de joueurs connectes reels.

### Modifie
- `../games/web/includes/canvas/play/play-ws.js`
  - relaie `rankingEntriesTotal` et `isTeam` depuis le WS Blind Test.
- `../games/web/includes/canvas/play/play-ui.js`
  - separe `playersTotalLast` (badge joueurs) et `rankingParticipantsTotalLast` (footer/classement);
  - libelles fin equipe: `Ton équipe termine...` et `Ton équipe remporte...`;
  - un joueur solo dans une session mixte garde le wording individuel.

### Verification
- `node --experimental-vm-modules --input-type=module -e "... SourceTextModule(...play-ws.js/play-ui.js) ..."`

## PATCH 2026-07-06 — Blind Test: table dediee equipes runtime

### Objectif
- persister les equipes runtime Blind Test dans une table dediee;
- conserver `blindtest_players` comme table des vrais joueurs;
- ne pas utiliser la table legacy `equipes`.

### Modifie
- `../games/web/includes/canvas/sql/2026-07-06_blindtest_session_teams.sql`
  - cree `blindtest_session_teams` avec identite session, client, nom normalise, score, rang final et membres JSON.
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `session_update` accepte un classement final optionnel (`players` / `rankings` / `finalRankings`);
  - extrait uniquement les entrees equipe et les upsert dans `blindtest_session_teams`;
  - tolere l'absence de table et les erreurs SQL par log non bloquant;
  - conserve `podium_json` et les writes `blindtest_players` existants.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`

## PATCH 2026-07-06 — Player Blind Test: code equipe, CTA rectangulaires et carte compacte

### Objectif
- rendre les actions de la carte equipe lisibles sur mobile;
- ne plus reutiliser la classe globale `.btn`, reservee aux boutons ronds/iconiques du player.
- rejoindre une equipe par code court runtime.
- simplifier la carte en trois etats exclusifs: solo, membre, saisie code.

### Modifie
- `../games/web/player_canvas.php`
  - CTA `Former une équipe`, `Rejoindre une équipe`, `Quitter l’équipe` et `Annuler` portent des classes dediees a la carte equipe;
  - ajout d'un panneau de saisie du code equipe qui remplace le contenu solo;
  - wording solo compact: `Jouez en Equipe !` puis rappel court de la premiere reponse d'equipe.
- `../games/web/includes/canvas/play/play-ws.js`
  - ajout `PlayerAPI.joinTeamByCode()`.
- `../games/web/includes/canvas/play/play-ui.js`
  - rendu exclusif solo/membre/saisie code;
  - suppression du CTA `Jouer seul` en etat solo;
  - masquage du texte d'intro quand le joueur est membre ou saisit un code;
  - rendu membre: nom equipe, code equipe, aide de partage, compteur membres, CTA `Quitter l’équipe`;
  - suppression de la confirmation `Tu as rejoint l’équipe...` en etat membre.
  - verrouillage coequipier: les propositions restent visibles/desactivees, un bandeau compact contextualise (`pending`, `success`, `error`) est insere au-dessus de la grille et le badge points affiche `+X pts` ou `0 pt` depuis la reponse d'equipe.
  - uppercase automatique du code et emission `teamJoinByCode`;
  - message de succes preserve au-dessus des details equipe.
- `../games/web/includes/canvas/css/player_styles.css`
  - ajout de `team-action-btn`, variantes primaire/secondaire et `team-action-link`;
  - actions empilees pleine largeur sous `640px`, champ code responsive, cible tactile 44-48px minimum;
  - suppression de l'espace reserve au statut quand il est vide;
  - en etat membre, CTA `Quitter l’équipe` place sous le bloc texte.
  - ajout du bandeau compact `team-answer-banner` au-dessus des options, avec variations legeres succes/erreur.

### Verification
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `node --experimental-vm-modules --input-type=module -e "... SourceTextModule(...play-ui.js/play-ws.js) ..."`
- `git -C /home/romain/Cotton/games diff --check -- web/player_canvas.php web/includes/canvas/play/play-ui.js web/includes/canvas/play/play-ws.js web/includes/canvas/css/player_styles.css`
- Verification statique mobile: les CTA equipe ne portent plus `.btn`; les actions restent en `grid-template-columns:1fr` avant `640px`.

## PATCH 2026-07-03 — Player Blind Test: wording premiere reponse equipe

### Objectif
- aligner l'accueil equipe sur la promesse "chacun garde son mobile";
- afficher un message clair quand un coequipier a deja repondu pour l'equipe.

### Modifie
- `../games/web/player_canvas.php`
  - wording accueil: premiere reponse envoyee compte pour tout le groupe.
- `../games/web/includes/canvas/play/play-ui.js`
  - message apres creation equipe: invitation jusqu'a 5 coequipiers et premiere reponse par morceau;
  - bouton de rejointure: `Rejoins l’équipe « {teamName} ».`;
  - rendu `teamAlreadyAnswered` dans la zone de reponses et verrouillage des options.

### Verification
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `node --experimental-vm-modules --input-type=module -e "... SourceTextModule(...play-ws.js/play-ui.js) ..."`
- `git diff --check`

## PATCH 2026-07-03 — Player Blind Test: compteur equipe preserve

### Objectif
- eviter que les updates de score/rang en mode equipe remplacent l'affichage du compteur equipe;
- garder `teamState` comme source d'affichage `Equipe actuelle : X (n/6)`.

### Modifie
- `../games/web/includes/canvas/play/play-ui.js`
  - sur `player/players:update` avec `teamMode=true`, rerend le dernier `teamState` connu au lieu d'ecrire un statut `Score equipe`;
  - le compteur reste donc visible apres quit volontaire ou fermeture socket d'un autre membre.

### Verification
- `node --experimental-vm-modules --input-type=module -e "... SourceTextModule(...play-ws.js/play-ui.js) ..."`
- `git diff --check`

## PATCH 2026-07-03 — Player Blind Test: carte equipes runtime

### Objectif
- exposer la surcouche equipe runtime Blind Test depuis l'ecran d'attente joueur;
- ne pas modifier le tunnel d'inscription joueur ni les autres jeux actifs;
- conserver le scoring individuel cote client, avec affichage du score/rang equipe quand le WS le fournit.

### Modifie
- `../games/web/player_canvas.php`
  - ajout d'une carte attente Blind Test avec le texte produit V1;
  - CTA `Former une équipe`, `Jouer seul` et liste des equipes a rejoindre.
- `../games/web/includes/canvas/play/play-ws.js`
  - demande `teamList` apres `registrationSuccess` Blind Test;
  - relai `teamState` / `teamError` vers le Bus;
  - ajout `PlayerAPI.createTeam()`, `joinTeam()`, `leaveTeam()`, `refreshTeams()`.
- `../games/web/includes/canvas/play/play-ui.js`
  - rendu des equipes runtime, compteurs membres, verrouillage apres start;
  - emission des actions equipe depuis les CTA;
  - affichage du score/rang equipe quand `updatePlayers.teamMode=true`.
- `../games/web/includes/canvas/css/player_styles.css`
  - styles de la carte equipe.

### Verification
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `node --experimental-vm-modules --input-type=module -e "... SourceTextModule(...play-ws.js/play-ui.js) ..."`

### Recette manuelle restante
- Ouvrir un player Blind Test inscrit en attente: carte equipe visible.
- Creer une equipe puis reconnecter le joueur: l'etat equipe est renvoye.
- Deux joueurs: le second voit et rejoint l'equipe.
- Apres lancement: boutons verrouilles et actions refusees par le WS.
- Quiz/Bingo: aucune carte equipe active.

## PATCH 2026-06-26 — Formats courts Blind Test/Bingo

### Objectif
- lire `championnats_sessions.id_format` pour activer le format court sans table supplementaire;
- Blind Test court: fournir 20 morceaux deterministes depuis la playlist source;
- Bingo court: reconnaitre le format 5 comme grille 3x3 cote Canvas.

### Modifie
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `_bt_get_session_meta_by_token()` expose `session_id` et `id_format`;
  - `svc_fetch_playlist_blindtest()` ordonne la playlist source par position/id_morceau;
  - si `id_format=5`, tri pseudo-aleatoire stable par `sha256(id_session|id_morceau)` puis limitation a 20 titres.
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - `_bingo_line_to_boxes()` traite le format 5 comme une grille 3x3;
  - `grid_assign` et `grid_hydrate` renvoient `gridFormat`, `gridCols`, `gridRows` et `gridCellCount`;
  - le player Bingo rend la grille depuis ces metadonnees, persiste le layout en localStorage et affiche 9 cases en 3x3 pour le format court.
- `../games/web/includes/canvas/css/player_styles.css`
  - ajoute les regles `data-cols="3"` pour eviter l'affichage 4 colonnes en player/demo/mobile.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php` OK.
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php` OK.
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js` OK.
- `git -C /home/romain/Cotton/games diff --check` OK.

## PATCH 2026-06-24 — Quiz: resolution des lots numeriques `N`

### Objectif
- poser uniquement le socle de lecture `N{id}` pour Quiz V2;
- conserver les chemins `L` et `T` existants;
- ne pas modifier front, WS, scoring, generation rapide ni papier.

### Diagnostic hotfix boot
- Une session test avec `championnats_sessions.lot_ids='N1'` etait rejetee par `quiz_resolve_token()` avec `PLAYLIST_INVALID` / `playlistId manquant ou invalide`.
- `_qz_fetch_questions()` et `quiz_can_switch_to_digital()` acceptaient deja `N`; la validation resolver restait limitee a `L/T`.
- Le warning front `SESSION_SYNC_MISSING_SESSION` est un symptome aval probable du preload interrompu.

### Modifie
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `_qz_fetch_questions()` accepte `N{id}`;
  - `N` lit `questions_lots_num_temp.question_ids`, puis `questions_numeriques`;
  - les propositions inline `proposition_1..3` sont exposees dans le format playlist historique;
  - la garde `quiz_can_switch_to_digital()` accepte les playlists mixtes `L/T/N`.
  - `quiz_resolve_token()` accepte aussi les playlists mixtes `L/T/N`, ce qui debloque le boot Canvas d'un lot `N` de test.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-06-22 — Demos: bascule papier avant lancement

### Objectif
- verifier pourquoi une demo ne pouvait pas passer de numerique a papier depuis les options;
- autoriser uniquement une demo non lancee / en attente;
- ne pas modifier les sessions officielles, quotas, scoring numerique ni flux WS hors necessite stricte.

### Diagnostic
- `games/web/includes/canvas/php/boot_lib.php` retournait `lock_reason=demo` avant toute lecture des phases, ce qui rendait `format_locked` permanent pour les demos.
- `games/web/organizer_canvas.php` masquait la section `Version` de la modale Options quand `$isDemo` etait vrai.
- Les adapters `quiz`, `blindtest` et `bingo` savent deja persister `paperMode` dans `championnats_sessions.flag_controle_numerique`; le refus venait du `FORMAT_SWITCH_LOCKED` alimente par la garde demo.
- `pro/web/ec/modules/tunnel/start/ec_start_script.php` herite deja `flag_controle_numerique` lors d'une duplication demo depuis une officielle; Bingo recree sa playlist client avec les compteurs papier/numerique selon ce flag.
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php` garde les demos catalogue numeriques par defaut pour les jeux V2/V5/V6.

### Modifie
- `../games/web/includes/canvas/php/boot_lib.php`
  - suppression du verrou permanent `flag_session_demo=1`;
  - les demos reutilisent les phases runtime: attente autorisee, demarree verrouillee.
- `../games/web/organizer_canvas.php`
  - la section `Version` est rendue aussi pour les demos;
  - le panneau iframe joueur demo n'est pas rendu si la demo est deja papier.
- `../games/web/includes/canvas/core/canvas_display.js`
  - masque et vide l'iframe demo quand `paperMode` passe a true;
  - relit explicitement `paperMode` / `flagControleNumerique` dans `options/updated` pour eviter les bascules implicites sur payload incomplet;
  - distingue la sync initiale `source=boot` du save Options pour ne pas reconfigurer/recharger l'iframe demo au chargement d'une demo numerique;
  - route `game/started` vers l'iframe demo (`demoOnly`) en session demo desktop pour eviter `CANVAS_DISPLAY_IFRAME_MISSING` sur `#player-iframe`;
  - marque le panneau demo comme desactive pour neutraliser le layout CSS `:has(...)`;
  - supprime `d-lg-flex`, pose `hidden` et force `display:none!important` pendant le mode papier afin que le save Options produise le meme rendu qu'un reload;
  - force un recalcul des metriques viewport apres bascule papier/numerique;
  - restaure l'iframe demo lors du retour en numerique.
- `../games/web/includes/canvas/core/session_modals.js`
  - ajoute `source=boot` sur l'emission initiale `options/updated`;
  - ajoute `source=options-save` sur l'emission apres sauvegarde de la modale Options.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - les paddings de split demo ne s'appliquent plus si `#demo-player-desktop-panel` porte `data-demo-panel-disabled="1"`;
  - le panneau desactive est cache via une regle de defense `display:none!important`.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/session_modals.js`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-06-12 — Remote Quiz papier: fallback contexte courant apres ACK score

### Objectif
- corriger une regression UI remote apres les patches `persist before WS`;
- conserver le succes de correction score uniquement apres ACK HTTP;
- ne pas modifier les serveurs WS ni les sessions numeriques.

### Diagnostic
- Le patch score remote ne remplace pas l'etat UI complet par l'ACK `update_score`: il ne met a jour que le joueur local et envoie `admin_set_score` en best-effort.
- La perte de serie courante / bouton support venait du connecteur remote quand un message d'etat avait `currentSongIndex` exploitable mais pas de playlist WS exploitable au meme moment: `emitNowUpcomingByIndex()` ne pouvait alors pas reconstruire `remote/now`.
- Sans `remote/now`, `currentNowItem` restait vide, donc le badge de serie et `updateStartSupportCTA()` n'avaient plus le contexte necessaire.

### Modifie
- `../games/web/includes/canvas/remote/remote-ws.js`
  - ajoute un fallback local depuis `window.Preload.playlist.songs` quand la playlist WS interne est vide;
  - n'ecrase pas une playlist deja hydratee;
  - restaure `remote/playlist:snapshot`, puis `remote/now` / index / upcoming a partir du preload si necessaire.

### Verification
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/remote/remote-ws.js`
- `git diff --check`

## PATCH 2026-06-12 — Remote papier Blind Test/Bingo: writes critiques avant WS

### Objectif
- completer la passe transverse Quiz sans refonte metier;
- verifier Blind Test et Bingo papier sur les actions remote critiques;
- utiliser les endpoints Canvas existants pour confirmer la persistance avant le succes remote quand le write etait critique.

### Diagnostic
- Blind Test partage le composant remote `applyScoreUpdate()` avec Quiz: la correction de score passe deja par `remoteApi('update_score')` avant le WS, mais il manquait les logs bridge Blind Test.
- Bingo persistait bien `phase_winner` cote serveur WS avant broadcast quand le message arrivait, mais la remote papier affichait le succes apres un envoi WS seul pour les attributions gagnantes avec joueur.
- Les ajouts de participants remote papier passent deja par `player_register` HTTP avant le WS best-effort.
- Les actions Bingo `admin_phase_fail` restent des notifications de controle, sans write persistant de gagnant.

### Modifie
- `../games/web/includes/canvas/remote/remote-ui.js`
  - les attributions gagnantes Bingo papier avec identite joueur appellent maintenant `bingo:phase_winner` via HTTP avant `admin_phase_winner`;
  - le WS porte `persisted=true`, `wonPhase`, `nextPhase` et `requiresResync=true` pour rafraichir organizer/remote/ecrans;
  - aucun flux numerique n'est modifie.
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - ajoute `REMOTE_PAPER_WRITE_RX` / `REMOTE_PAPER_WRITE_PERSISTED` sur les corrections remote papier `update_score`.
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - ajoute `REMOTE_PAPER_WRITE_RX` / `REMOTE_PAPER_WRITE_PERSISTED` sur `phase_winner` remote papier, y compris replay idempotent.

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`

## PATCH 2026-06-12 — Remote papier Quiz: score persiste avant WS

### Objectif
- corriger les desynchronisations de correction papier Quiz quand le primary organizer WS est absent;
- conserver un patch minimal sans refonte globale ni changement des sessions numeriques;
- garantir qu'un score corrige depuis la remote recoit un ACK fiable seulement apres persistance DB.

### Diagnostic
- La remote papier Quiz appelait `admin_set_score` uniquement via WS depuis `games/web/includes/canvas/remote/remote-ui.js`.
- Le serveur Quiz WS persistait ensuite via `CanvasAPI.updateScore`, puis tentait de notifier l'organizer via `updatePlayers`.
- En cas de socket organizer principale absente, `messaging.sendMessageToPrimary()` loggait `WS_SEND_NO_PRIMARY_ORGANIZER` et le broadcast etait saute; la remote affichait pourtant un succes local sans ACK HTTP de la persistance.
- Le log reel de la session `dnoed0aejjbruj3lics51tv5cv69ef1d4c951d0` montre des deconnexions `1006` et des remplacements `4004` avant 29 occurrences `WS_SEND_NO_PRIMARY_ORGANIZER` entre `2026-06-11T19:36:03Z` et `2026-06-11T19:38:20Z`.

### Modifie
- `../games/web/includes/canvas/remote/remote-ui.js`
  - `applyScoreUpdate()` persiste maintenant le score via HTTP `quiz:update_score` avant d'emettre le WS `admin_set_score`;
  - l'ACK visible remote depend de la reponse HTTP du bridge, pas du broadcast WS;
  - le WS devient un signal best-effort de rafraichissement memoire / sockets presentes avec `persisted=true` et `requiresResync=true`.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
  - ajoute des logs cibles `REMOTE_PAPER_WRITE_RX` et `REMOTE_PAPER_WRITE_PERSISTED` pour les writes remote papier `update_score`.
- `../quiz/web/server/actions/gameplay.js`
  - `adminSetScore()` journalise la reception, applique le score en memoire WS, force le refresh des organizers presents et saute la double persistance si l'HTTP a deja confirme le write.
- `../quiz/web/server/messaging.js`
  - `sendMessageToPrimary()` retourne un booleen et enrichit `WS_SEND_NO_PRIMARY_ORGANIZER` avec `ws_type` et `resync_required`.
- `../quiz/web/server/restart_serveur.txt`
  - marker bump `restart 12-06-2026/01`.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `node --check /home/romain/Cotton/quiz/web/server/messaging.js`
- `node --check /home/romain/Cotton/quiz/web/server/actions/gameplay.js`
- `node --check /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js` non exploitable tel quel: fichier front ESM avec imports `@canvas/*` sans contexte module Node.

## PATCH 2026-06-04 — Session officielle future: modale accueil preparation

### Objectif
- afficher une modale informative a la premiere ouverture organizer d'une session officielle future hors fenetre active;
- reprendre le meme perimetre que le garde-fou de lancement existant, sans ajouter d'action ni rendre la session officielle lancable;
- conserver la modale de lancement demo comme fallback si la modale d'accueil n'a pas encore ete vue.

### Audit
- `organizer_canvas.php` calcule `sessionChronology`, `isOfficialSession`, `canLaunchOfficial` et `isPreparationMode` pour les sessions officielles non demo.
- `boot_organizer.js` bloque le lancement via `handleOfficialLaunchGate()`; hors fenetre active, `confirmOfficialDemoLaunch()` propose la duplication demo avec `postDemoDuplicate()`.
- La duplication demo utilise l'URL Pro `demoDuplicateActionUrl` et le POST `frm_mode=session_duplicate`.
- Les options de jeu et la version papier passent par `#optionsModal` et `session_modals.js`.
- Le QR de pilotage mobile reste affiche uniquement si `is_demo_session || canLaunchOfficial`; il n'est donc pas expose sur une officielle future hors fenetre active.

### Modifie
- `../games/web/includes/canvas/core/boot_organizer.js`
  - ajoute une modale SweetAlert informative `Prépare ta session avant le jour J`;
  - conditionne l'affichage a une session officielle non demo, non lancable, non ouverte, avec `sessionChronology === before`;
  - formate la date reelle en francais si disponible, sinon utilise le fallback `programmée pour plus tard`;
  - affiche une astuce adaptee au support: pilotage mobile en desktop, lancement demo via bouton `Play` en mobile;
  - persiste la fermeture en `localStorage` avec `cotton_official_prep_modal_seen_{session_id}`;
  - conserve un unique CTA `Fermer` et ne lance aucune action;
  - apres fermeture de cette modale, le clic `Tester en démo` lance directement la demo sans reafficher la modale de garde-fou.

### Verification
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- TODO navigateur: officielle future hors fenetre active, demo, officielle active/lancable, session passee, fallback click lancement.

## PATCH 2026-05-18 — Demo LP reseau: quit retour LP

### Objectif
- permettre au quit organizer d'une demo lancee depuis une LP reseau/operation de revenir sur cette LP;
- conserver les protections contre les retours externes ou vers `/master/`.

### Audit
- `end_game.js` memorise deja `return_url` depuis l'URL `/master/{token}` pour les sessions demo.
- La validation n'autorisait que l'origine PRO et les chemins `/extranet/...`, ce qui excluait les LP publiques `www`.

### Modifie
- `../games/web/includes/canvas/core/end_game.js`
  - conserve l'autorisation PRO `/extranet/...`;
  - autorise aussi l'origine `wwwUrl` uniquement pour `/lp/reseau/...` et `/lp/operation/...`;
  - normalise les `return_url` relatifs `/lp/...` contre `AppConfig.wwwUrl` afin d'eviter une resolution par erreur sur `games`;
  - refuse toujours les autres chemins et les URLs contenant `/master/`.

### Verification
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/end_game.js`
- TODO navigateur: demo LP reseau Quiz / Blind Test / Bingo, puis bouton `Quitter le jeu`.

## PATCH 2026-05-06 — Demo site mobile: libelle CTA lancement

### Objectif
- afficher le libelle exact `Lancer la démo` sur le bouton de lancement mobile organizer des demos publiques du site;
- limiter le comportement aux sessions demo rattachees au compte Cotton WWW Online Demos / Cotton Online Demos;
- ne pas modifier les demos clients, sessions officielles, sessions papier, comportements Quiz / Blind Test / Bingo ni serveurs WS.

### Audit
- Le bouton est rendu dans `web/organizer_canvas.php` (`#play-pause-btn`) et pilote par `web/includes/canvas/core/canvas_display.js` via `setMenuControls()`.
- Le CSS mobile de `web/includes/canvas/css/canvas_styles.css` transforme `.organisateur-menu .orga-btn` en bouton rond 48px et masque les `span`, ce qui explique le rendu icone seule.
- Les demos publiques du site sont creees cote `www` avec `id_client = 1557` et `flag_session_demo = 1` pour Quiz, Blind Test et Bingo Musical.
- Cote organizer, la condition fiable est deja exposee dans `AppConfig`: `isDemoSession === true` et `idClient === "1557"`.

### Modifie
- `../games/web/includes/canvas/core/canvas_display.js`
  - detecte uniquement le cas `isDemoSession + idClient 1557 + mobile + numerique + En attente + bouton play seul`;
  - remplace le libelle par `Lancer la démo` et pose un attribut de rendu sur `#play-pause-btn`;
  - retire cet attribut hors attente / hors cas cible pour conserver le rendu courant.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - conserve les classes existantes du bouton desktop (`btn btn-primary orga-btn px-4`);
  - neutralise seulement la regle mobile qui force le rond et masque le libelle pour `#play-pause-btn[data-public-demo-launch-cta="1"]`.

### Verification
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- TODO navigateur: demo publique site Cotton Online Demos mobile, demo client mobile, session officielle mobile, Bingo demo reset/relance.

## PATCH 2026-05-05 — Bingo GM iframe: sortie attente apres reset demo

### Objectif
- corriger le residuel iframe GM ou, apres reset demo Bingo termine, la grille etait bien vide/deverrouillee mais restait bloquee sur l'ecran d'attente au lancement suivant;
- conserver `bingo_reset_epoch` comme generation de stockage checked/locked uniquement;
- ne pas modifier `bingo.game/ws`.

### Audit
- Le joueur QR externe passe bien en `En cours`, ce qui confirme que le reset global et le flux WS serveur ne sont pas la source principale.
- Cote player Bingo, `demo_reset` remet `mainStarted=false`; ensuite `state` et `passed_song` ne remettaient `mainStarted=true` que si une duree de clip etait fournie.
- L'iframe GM pouvait donc recevoir un signal de partie demarree sans consommer son runtime post-reset ni sortir de l'attente.

### Modifie
- `../games/web/includes/canvas/play/play-ws.js`
  - ajoute la consommation runtime post-reset sur `state`, `reset_game` et `passed_song` des qu'une phase Bingo demarree est observee;
  - remet `mainStarted=true`, repousse l'etat live et la grille disponible, sans toucher aux cles checked/locked invalidees par `bingo_reset_epoch`;
  - ajoute les traces `ui/bingo:postreset:consumed`, `ui/bingo:start_after_reset:received` et `ui/bingo:start_after_reset:applied`.

### Verification
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`

## PATCH 2026-05-05 — Bingo reset demo termine: neutralisation front apres API

### Objectif
- corriger le reset demo Bingo d'une session terminee sans patcher le serveur WS, puisque `bingo.game/ws` ne diverge pas entre prod et develop sur ce flux;
- empecher organizer, iframe GM et joueur QR de conserver/rejouer un etat terminal apres un `resetdemo` DB reussi;
- conserver les grilles demo assignees et les rows `bingo_players`.

### Audit
- La prod fonctionne sans patch WS; `bingo.game` n'a pas de diff `main...develop` sur `ws/bingo_server.js`.
- Le reset DB Bingo remet deja a zero `phase_courante`, `morceau_courant`, logs playlist, `bingo_phase_winners`, timestamps de grilles et `bingo_players.gain_phase`.
- Le risque develop/local est front:
  - l'organizer ne recevait pas lui-meme de `demo_reset` live et pouvait garder store/podium/iframe en etat termine jusqu'au reload;
  - `organizer/demoPostResetReady` pouvait etre emis avant l'attachement du listener `canvas_display.js`;
  - un snapshot Bingo demo phase `0` ne purgeait pas explicitement les winners/medailles/podium front deja hydrates;
  - cote player, les flags locaux de fin statique/reconnexion pouvaient rester poses dans certains chemins avant traitement de `demo_reset`.

### Modifie
- `../games/web/includes/canvas/core/boot_organizer.js`
  - applique un reset local Bingo apres reponse API `resetdemo` OK;
  - publie un signal post-reset persistant jusqu'a consommation par l'UI organizer.
- `../games/web/includes/canvas/core/canvas_display.js`
  - consomme le signal post-reset pending apres attachement du listener et recharge/reconfigure l'iframe GM.
- `../games/web/includes/canvas/core/games/bingo_ui.js`
  - purge winners/medailles/podium quand un snapshot demo revient en phase `0`.
- `../games/web/includes/canvas/play/play-ws.js`
  - sur `demo_reset`, annule les flags locaux de fin statique/reconnexion supprimee avant reset UI/reload.

### Verification
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/games/bingo_ui.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`

## PATCH 2026-05-05 — Bingo GM iframe: invalidation localStorage apres reset demo termine

### Objectif
- corriger le bug residuel ou seule l'iframe organizer `embed=gm` reprenait une grille entierement cochee/verrouillee apres reset demo Bingo;
- conserver le contrat actuel: grilles assignees et rows `bingo_players` conservees;
- ne pas modifier `bingo.game/ws`.

### Audit
- Le scope local `game + sessionId + player_id + gridId` est correct pour une reprise pendant une partie, mais trop stable apres reset demo: le joueur GM garde le meme `player_id` et la meme grille.
- Les anciennes cases/locks peuvent donc rester prioritaires si elles sont lues avant que `grid_hydrate` reconstruise un etat vide depuis la DB resetee.
- La correction retenue ajoute une generation locale de reset, sans changer les writes DB ni le WS.

### Modifie
- `../games/web/includes/canvas/core/boot_organizer.js`
  - ecrit `bingo_reset_epoch:{sessionId}` apres `resetdemo` OK;
  - purge les cles `bingo_checked` / `bingo_locked` scoppées a la session et publie l'epoch dans le signal post-reset.
- `../games/web/includes/canvas/core/canvas_display.js`
  - transmet `bingo_reset_epoch` dans l'URL iframe GM;
  - envoie un `postMessage` de purge a l'iframe active avant de la recharger.
- `../games/web/includes/canvas/play/play-ui.js`
  - inclut l'epoch dans les cles locales checked/locked quand elle existe;
  - lit l'epoch depuis l'URL iframe ou `localStorage`;
  - trace la source appliquee par `grid_hydrate` (`local`, `db`, `empty`, `reset`) avec counts checked/locked.
- `../games/web/includes/canvas/play/play-ws.js`
  - aligne le fallback `emitGridIfAvailable()` sur les cles incluant l'epoch.

### Verification
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`

## PATCH 2026-05-05 — Bingo GM iframe: grille cochée/verrouillée

### Objectif
- corriger le bug bloquant Bingo mobile organizer: l'iframe joueur `embed=gm` affichait une grille entierement cochee et verrouillee des l'inscription;
- couvrir demo mobile, officielle mobile et preview demo desktop sans modifier les sessions papier ni les vrais joueurs QR;
- conserver `player_id` canonique `p:` comme identite principale, `playerId` numerique restant secondaire.

### Audit
- le flux serveur `player_register` / `grid_assign` / `grid_hydrate` garde une vraie grille assignee au joueur auto-GM;
- la corruption visible venait du front player: `play-ui.js` et le fallback `play-ws.js` pouvaient relire `bingo_checked` et `bingo_locked` globaux du navigateur sans prouver qu'ils appartenaient a la session, au `player_id` et a la grille courants;
- le verrouillage observe correspond a la reprise de `bingo_locked`, pas a un probleme CSS;
- les derniers correctifs pre-merge ont probablement rendu l'iframe GM plus deterministe, exposant un etat local stale qui pouvait deja exister.

### Modifie
- `../games/web/includes/canvas/play/play-ui.js`
  - introduit des cles locales scoppées par `game + sessionId + player_id + gridId` pour `bingo_checked` et `bingo_locked`;
  - ne relit plus les anciennes cles globales `bingo_checked` / `bingo_locked` et les supprime activement lors des sauvegardes;
  - n'utilise plus `bingo_grid_id` legacy pour construire le contexte de stockage des cases, afin qu'une nouvelle session ne puisse pas heriter de la grille precedente avant son `grid_assign`;
  - hydrate la grille Bingo depuis l'API avant de choisir entre etat local prouve et timestamps DB;
  - persiste les resets, clicks et locks dans le scope courant;
  - vide aussi `AppConfig.bingoChecked` / `AppConfig.bingoLocked` sur `reset_game`, pour eviter qu'un checked-set runtime stale soit repousse juste apres reset;
  - ajoute des traces `ui/bingo:grid_hydrate:trace` et `ui/bingo:grid_cells_sync:trace` pour distinguer requete, reponse, contexte et nombre de cases cochees.
- `../games/web/includes/canvas/play/play-ws.js`
  - remplace le fallback `emitGridIfAvailable()` sur `localStorage.bingo_checked` global par une resolution scoppée;
  - refuse d'emettre un checked-set local si `sessionId`, `player_id` et `gridId` ne correspondent pas.
  - purge les cles scoppées `bingo_checked` / `bingo_locked` de la session courante sur `demo_reset` et `reset_game`;
  - lit la grille du fallback checked uniquement via la cle scoppée `${game}:grid_id:${sessionId}`, jamais via `bingo_grid_id` legacy;
  - trace l'auth WS Bingo et le premier snapshot player Bingo via des evenements Bus de diagnostic.

### Invariants
- pas de correction CSS;
- aucune purge arbitraire d'une grille deja jouee;
- reprise apres reload conservee pour les cases reellement cochees du meme joueur et de la meme grille;
- session papier inchangee;
- preview demo desktop Bingo conservee;
- aucun changement WS Bingo ni schema DB.

### Tests
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`
- recette navigateur a faire avant prod: Bingo demo mobile, Bingo officielle mobile, Bingo demo desktop, joueur QR reel, reload d'une grille partiellement cochee.

## PATCH 2026-05-05 — Pre-merge: securisation iframe organizer

### Objectif
- traiter les deux risques pre-merge `develop -> main` sans elargir le scope fonctionnel;
- durcir la reception `postMessage` de `gm-player-ready`;
- eviter deux iframes joueur organizer actives en meme temps;
- ne pas modifier les regles metier des pseudos auto-GM.

### Modifie
- `../games/web/includes/canvas/core/canvas_display.js`
  - remplace le ciblage generique `[data-player-iframe="1"], #player-iframe` par une resolution explicite de l'iframe active;
  - charge la preview `demo-player-iframe` seulement pour la demo desktop;
  - charge `player-iframe` seulement pour l'onglet mobile numerique `Jouer`;
  - decharge les autres iframes organizer deja chargees quand une iframe devient active;
  - filtre `gm-player-ready` par origine attendue, source iframe connue et payload coherent session/jeu;
  - conserve Bingo avec grille assignee en exigeant identite + `gridId`/`gridNumber` dans le payload.

### Invariants
- demo desktop `embed=gm&demo_player=1` conservee;
- mobile numerique `Jouer` conserve;
- reprise/reload conservee;
- session papier mobile: aucune iframe auto;
- pas de changement `USERNAME_ALREADY_USED` pour `organizer_auto_player` / `gm_autoreg`.

### TODO
- si un display name GM identique a un joueur reel devient confus en UI, ajouter un suffixe visuel type `(orga)` sans modifier `player_id` ni l'upsert.

### Tests
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `git -C /home/romain/Cotton/games diff --check main...develop`
- `git -C /home/romain/Cotton/games diff --stat main...develop`
- recette navigateur a faire avant prod: Quiz/Blind Test/Bingo demo desktop + mobile, officielle mobile, collision pseudo GM, reload apres score.

## PATCH 2026-05-05 — Demo mobile: ouvrir d'abord l'experience joueur

### Objectif
- en demo mobile numerique, ouvrir la session sur `Vue joueur` pour montrer immediatement l'experience joueur;
- inverser visuellement le toggle demo mobile en `Vue joueur / Vue animateur`;
- respecter ensuite le choix manuel de l'utilisateur;
- ne pas modifier officiel mobile, desktop, QR joueur, scoring ni WS.

### Modifie
- `../games/web/organizer_canvas.php`
  - rend le toggle mobile en `Vue joueur / Vue animateur` seulement quand `flag_session_demo` / `isDemo` est actif;
  - conserve `Animer / Jouer` pour les sessions officielles;
  - sort la mention d'aide demo du bloc QR de la vue en attente et l'affiche au-dessus du QR, alignee a gauche;
  - ajoute la mention hors iframe:
    - Quiz: `Tu joues avec un profil d’Équipe démo.`
    - Blind Test / Bingo: `Tu joues avec un profil de Joueur démo.`
- `../games/web/includes/canvas/core/canvas_display.js`
  - initialise l'onglet mobile actif sur `Jouer` au premier passage en session demo mobile numerique;
  - garde les handlers lies aux IDs existants (`mobile-session-player-btn`, `mobile-session-organizer-btn`) pour ne pas inverser les etats internes;
  - persiste le choix demo mobile en `sessionStorage` scoppé par jeu + session, afin qu'une bascule volontaire vers `Animer` ne soit pas ecrasee par un render ou un reload du meme onglet;
  - ne change pas l'initialisation des sessions officielles.

### Tests
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `git -C /home/romain/Cotton/games diff --check`
- reste a faire en navigateur: demo mobile Quiz / Blind Test / Bingo, reload apres bascule `Animer`, officiel mobile, QR joueur reel.

## PATCH 2026-05-05 — Mobile officiel: stabilisation auto-player organizer

### Objectif
- empêcher l'iframe mobile organizer `Jouer` officielle de retomber sur le register manuel quand le profil auto est disponible;
- conserver le display name transmis par l'organizer (`prenom` ou fallback `Game Master`);
- ne pas modifier les vrais joueurs QR, les demos, le scoring ni les règles WS.

### Audit
- `organizer_canvas.php` expose deja `AppConfig.organizerAutoPlayerDisplayName` et affiche l'aide hors iframe;
- `canvas_display.js` construit l'URL iframe `embed=gm` et ajoute `gm_display_name` en officiel non-demo;
- `register.js` lit `gm_display_name` et auto-register le GM, mais court-circuitait l'auto-register si une identite locale existait pour la meme session;
- dans ce cas, la reprise standard pouvait garder l'identite apres un miss transient `players_get` sans appeler `setStage('play')` / `markPlayerRegistered()`, ce qui laissait `#playerForm` visible.
- addendum logs Bingo officiel 14:20: l'URL iframe etait correcte (`embed=gm&gm_display_name=Romain`) et le `player_register` partait au primo-boot, mais la reponse HTTP 500 arrivait avant `bingo_api_player_register][PLAYER_REGISTER_RX`;
- cause serveur addendum: les gardes `USERNAME_ALREADY_USED` / `USERNAME_REFERENCED`, prevus pour les joueurs QR manuels, pouvaient refuser le displayName auto organizer avant l'upsert par `player_id` canonique.

### Modifie
- `../games/web/includes/canvas/play/register.js`
  - ajoute une reprise dediee `embed=gm` pour une identite locale meme-session valide;
  - ajoute un etat UI `GM_AUTOREGISTERING` reserve a l'iframe organizer, utilise avant tout probe reseau lors du primo-boot;
  - marque immediatement l'UI comme inscrite, masque le formulaire, republie `player/ready` et `gm-player-ready`;
  - applique la meme reprise si le probe `players_get` / `bingoPlayerExists` rate ou echoue alors que l'identite locale GM est exploitable;
  - met a jour le nom local avec le `GM_NAME` courant pour conserver le prenom transmis, ou `Game Master` en fallback.
  - envoie `organizer_auto_player=1` / `gm_autoreg=1` sur le `player_register` auto-GM.
- `../games/web/player_canvas.php`
  - initialise les URLs `embed=gm` avec `data-gate-open="0"` et le message `Connexion de ton profil...` afin que le formulaire manuel ne soit pas visible avant l'execution des modules JS;
  - ne rend plus le bloc `Compte joueur Cotton` dans l'iframe `embed=gm`;
  - ne change pas le rendu initial des URLs QR reelles sans `embed=gm`.
- `../games/web/includes/canvas/core/canvas_display.js`
  - compare l'URL effective de l'iframe avec `dataset.src`;
  - recharge le `src` si une URL deja chargee diverge de l'URL calculee, afin de ne pas garder un ancien embed sans `gm_display_name`.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - acceptent le flag auto-GM et bypassent uniquement pour lui les controles de nom deja utilise / nom reference;
  - conservent les controles de nom pour les inscriptions QR manuelles et les flux EP classiques.

### Invariants
- les joueurs QR reels restent sur le formulaire manuel normal;
- les sessions demo gardent `Équipe démo` pour Quiz et `Joueur démo` pour Blind Test / Bingo;
- aucun changement scoring, DB schema, payload WS serveur ou parcours d'authentification;
- aucun fetch supplementaire du displayName: le nom deja expose par l'organizer est reutilise.
- le bypass d'unicite de nom est borne au flag `organizer_auto_player` emis par l'iframe `embed=gm`.

### Tests
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- reste a faire en navigateur: storage vide + ouverture directe `Jouer` sur Quiz / Blind Test / Bingo officiels mobiles, fallback `Game Master`, demo mobile, joueur QR reel.

## PATCH 2026-05-05 — Design organizer: merge-safe branding + titre/lots partiels

### Objectif
- securiser la propagation du design personnalise organizer vers player, remote et iframe demo;
- eviter qu'un save partiel couleur-only ou media-only vide des champs non modifies;
- conserver la suppression volontaire de logo/visuel via une intention explicite.

### Audit
- `../games/web/includes/canvas/core/session_modals.js` envoie le save branding vers `global_ajax.php?t=general&m=branding&action=save`, puis diffuse `branding/updated` en WS;
- `../games/web/player_canvas.php` et `../games/web/remote_canvas.php` relisent le branding effectif depuis `global_ajax.php?t=general&m=branding&action=get` au refresh/reconnexion;
- `../games/web/includes/canvas/php/prizes_glue.php` acceptait deja des updates partiels de lots, mais reconstruisait `mainTitle` a `''` si la cle etait absente;
- `quiz`, `blindtest` et `bingo` consomment cette chaine commune pour le branding runtime.

### Modifie
- `../games/web/includes/canvas/core/session_modals.js`
  - pose `logo_clear=1` ou `visuel_clear=1` uniquement quand l'utilisateur clique explicitement sur le reset/suppression du media;
  - annule ce marqueur quand un nouveau fichier logo/visuel est choisi.
  - relit le branding effectif renvoye par `branding_save` pour diffuser en WS un objet complet (`logo`, `visuel`, `visuelMode`, couleurs, police);
  - conserve aussi `b.logo` / `b.visuel` en fallback live si le serveur distant ne renvoie pas encore ce branding effectif.
- `../games/web/includes/canvas/php/prizes_glue.php`
  - `mainTitle` devient nullable sur le write interne;
  - une requete `prizes_save` sans cle `mainTitle` preserve `championnats_sessions.diffusion_message`.
- `../games/web/player_canvas.php` et `../games/web/remote_canvas.php`
  - le style initial `body` lit maintenant `var(--branding-font)` au lieu de figer la police PHP;
  - le lien de font initial porte `id="custom-font-link"` pour etre remplace par le flux live existant.
- `../games/web/config.php`
  - bump local `CANVAS_ASSET_VER` en `v=2026-05-05_19` pour forcer le rechargement des assets Canvas corriges.
- `../global/web/app/modules/general/branding/app_branding_ajax.php`
  - voir `canon/repos/global/TASKS.md`: merge serveur des couleurs/police et preservation des medias absents.

### Invariants
- pas de refonte UI;
- pas de changement WS player/remote;
- compatibilite conservee avec les payloads complets existants;
- l'absence d'une cle n'est plus une demande d'effacement.

### Tests
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/prizes_glue.php`
- `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_ajax.php`
- `php -l /home/romain/Cotton/games/web/config.php`
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `php -l /home/romain/Cotton/games/web/remote_canvas.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/session_modals.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js`

## PATCH 2026-05-05 — Organizer desktop/mobile: passe UX complémentaire

### Objectif
- ajouter un feedback léger pendant le diagnostic prelaunch automatique;
- afficher `équipe(s) connectée(s)` pour les compteurs participants Quiz uniquement;
- mieux séparer visuellement la preview joueur demo desktop de l'interface organizer;
- améliorer le confort de l'iframe joueur demo desktop, notamment les propositions Quiz / Blind Test et la grille Bingo.

### Modifie
- `../games/web/includes/canvas/core/canvas_display.js`
  - adapte uniquement le libellé du compteur participant selon le jeu: Quiz utilise `équipe connectée` / `équipes connectées`, Blind Test et Bingo gardent `joueur connecté` / `joueurs connectés`.
  - calcule pour la preview demo desktop une zone verticale disponible basée sur le viewport et la barre menu, indépendante de la hauteur du canvas organizer.
  - après confinement de la footerbar au panneau organizer, la zone joueur demo ne réserve plus toute la hauteur de menu côté rail téléphone.
- `../games/web/organizer_canvas.php`
  - déplace l'explication hors de la coque téléphone et supprime le libellé interne `Joueur démo / Scanne le QR code...`;
  - utilise le label demo cohérent avec le jeu au-dessus du téléphone: `Équipe démo` pour Quiz, `Joueur démo` pour Blind Test et Bingo.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - anime sobrement la diode `data-prelaunch-status="running"` du bouton `LANCER LE JEU`, avec garde `prefers-reduced-motion`;
  - donne au panneau desktop demo joueur un fond neutre sur toute la hauteur du viewport et une séparation visuelle plus claire;
  - élargit progressivement la coque téléphone et la réserve desktop associée, avec fallback compact sur desktop étroit.
  - autorise la coque téléphone à occuper la hauteur disponible en haut de page, tout en gardant une limite basse au-dessus de la barre menu.
  - contraint la footerbar à la largeur organizer uniquement en layout demo desktop avec preview joueur intégrée, en neutralisant le `w-100` Bootstrap, afin de libérer le bas du rail téléphone.
  - affiche le bloc explicatif au-dessus du téléphone et allège le padding haut de la coque maintenant qu'elle ne contient plus de texte de consigne.
- `../games/web/includes/canvas/css/player_styles.css`
  - retire la teinte interne du contexte `demo-player-embed` pour revenir au fond `primary-bg` du jeu;
  - augmente l'espace vertical des propositions Quiz / Blind Test dans l'iframe demo;
  - donne un peu plus d'air à la grille Bingo en iframe demo.

### Invariants
- aucun changement de flux métier, WS, scoring, inscription, lancement, prelaunch ou iframe;
- pas de nouveau composant;
- les ajustements player sont bornés à `html.demo-player-embed`;
- les vues joueur réelles hors preview demo ne sont pas ciblées;
- Blind Test et Bingo gardent le wording joueur.

### Tests
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `git -C /home/romain/Cotton/games diff --check -- web/includes/canvas/core/canvas_display.js web/includes/canvas/css/canvas_styles.css web/includes/canvas/css/player_styles.css`

## PATCH 2026-05-05 — Mobile officiel: nom visible du Game Master

### Objectif
- remplacer le libellé visible `Game Master` par le prénom du contact connecté quand l'organisateur utilise l'onglet `Jouer` en session officielle mobile;
- garder `Game Master` si aucun prénom de session fiable n'est disponible;
- préserver les labels demo existants: `Équipe démo` en Quiz, `Joueur démo` en Blind Test / Bingo.

### Source
- source prioritaire: `$_SESSION['client_contact_prenom']`, déjà alimentée par l'authentification espace client PRO et utilisée sur la home EC (`Bonjour ...`);
- fallback serveur si la session PRO n'est pas disponible côté `games`: `clients_logs.id_client_contact` sur la trace `clients_logs.nom LIKE "%Session #... > ajout%"` écrite par `app_session_ajouter()`, filtrée par `id_client`, puis `client_contact_get_detail()` pour récupérer `prenom`.

### Modifie
- `../games/web/organizer_canvas.php`
  - expose `AppConfig.organizerAutoPlayerDisplayName` depuis le prénom de session PRO ou, à défaut, depuis le contact attaché à la session, normalisé et tronqué;
  - affiche en session officielle mobile numerique, dans `#mobile-player-view`, l'aide hors iframe `Tu joues avec le profil {displayName}.`;
- `../games/web/includes/canvas/core/canvas_display.js`
  - transmet ce display name aux iframes organizer `embed=gm` officielles via `gm_display_name`;
  - ne transmet pas ce paramètre en session demo.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - style cette aide comme une petite ligne discrete, sans encadre ni impact sur l'iframe joueur;
- `../games/web/includes/canvas/play/register.js`
  - utilise `gm_display_name` comme nom visible du joueur auto officiel, avec fallback `Game Master`;
  - conserve les labels demo `Équipe démo` / `Joueur démo`;
  - ne change pas le `player_id` stable utilisé comme identité technique.

### Invariants
- aucun changement de scoring, WS, inscription QR, règles de lancement ou reprise;
- aucun nouveau parcours d'authentification ni requête additionnelle;
- les vrais joueurs QR ne reçoivent pas `gm_display_name`;
- la ligne d'aide n'est pas rendue en demo ni en session papier;
- si le prénom n'est pas disponible, le comportement reste `Game Master`.

### Tests
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- vérification statique: `Équipe démo` reste conditionné à Quiz dans `register.js` et `organizer_canvas.php`.

## PATCH 2026-05-05 — Mobile organizer V1: ajustements UX visuels

### Objectif
- ajuster uniquement le wording et le rendu visuel mobile organizer V1;
- ne pas toucher aux flux WS, scoring, auto-register, iframe joueur, reprise demo ou logique countdown;
- ne pas impacter le desktop.

### Modifie
- `../games/web/organizer_canvas.php`
  - remplace l'aide demo mobile sous QR par: `Flashe le QR code ou lance la démo et passe sur l'onglet "Jouer" pour tester l'expérience joueur.`
- `../games/web/includes/canvas/css/canvas_styles.css`
  - agrandit le cercle SVG et le chiffre du countdown en media query mobile uniquement;
  - addendum: force une boite SVG carree explicite en mobile (`width` + `height`), puis ajuste la taille et l'epaisseur pour eviter un rendu trop massif;
  - reduit les bordures colorees des blocs organizer mobiles a `2px` dans les vues attente / Animer / papier mobile;
  - reduit legerement le toggle mobile `Animer / Jouer` tout en conservant une hauteur tactile minimale de `44px`.

### Invariants
- aucun changement JS;
- aucun changement de timing countdown;
- aucun changement de comportement metier, WS, scoring, inscription joueur, iframe ou reprise demo;
- les overrides sont bornes aux breakpoints mobiles.

### Tests
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- verification statique: changements limites a `organizer_canvas.php` et `canvas_styles.css`.

## PATCH 2026-05-05 — Organizer mobile V1: stabilisation scoping desktop/mobile

### Objectif
- corriger la regression desktop introduite par la ligne mobile compacte `visuel + QR`;
- restaurer le layout organizer desktop historique pour Blind Test / Bingo Musical en cours: support a gauche, classement live au centre, preview joueur demo a droite si applicable, lots/QR/visuel dans la zone desktop normale;
- verifier que Quiz desktop ne recupere pas le bloc mobile compact;
- durcir la V1 mobile organizer sans ajouter de composant ni changer le metier;
- conserver les correctifs mobile valides: aide demo mobile, padding lots, ligne visuel + QR mobile, iframe `Jouer`, suppression du tag `VUE JOUEUR`, auto-register et noms demo.

### Audit
- `../games/web/includes/canvas/core/canvas_display.js::getPauseRow()` utilisait `document.querySelector('.pause-row')`;
- depuis l'ajout de `#mobile-session-followup`, la premiere `.pause-row` du DOM etait la ligne mobile `mobile-session-pause-row`, placee avant `#pause-container`;
- en desktop Blind Test / Bingo Musical, `teleportPauseRow('en-cours')` deplacait donc le bloc mobile compact dans le layout desktop au lieu de la ligne pause desktop historique;
- les styles du bloc mobile etaient principalement portes par des classes dediees, mais sans garde desktop explicite si le bloc etait detache de son wrapper `d-lg-none`.
- `setPhase()` peut appeler `showAll()` sur les blocs mobiles pendant `En cours`/`Pause`; le masquage desktop ne doit donc pas dependre uniquement de l'ordre des classes Bootstrap.
- les helpers de pause inter-series utilisaient encore des selectors globaux `.leaderboard-pause-tag` / `.leaderboard-info-tag`, susceptibles de toucher un tag mobile si l'ordre DOM change.

### Modifie
- `../games/web/includes/canvas/core/canvas_display.js`
  - `getPauseRow()` cible maintenant d'abord `#pause-container .pause-row:not(.mobile-session-pause-row)`;
  - le fallback ne regarde que le host de teleport desktop et exclut aussi `.mobile-session-pause-row`;
  - `showAll()` ignore les blocs `mobile-session-*` / `#mobile-player-view` quand le layout courant est desktop;
  - les selectors de pause inter-series passent par `getPauseStatusBlock()` au lieu de chercher le premier tag leaderboard global.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ajoute un garde `@media (min-width: 992px)` qui masque explicitement `#mobile-player-view`, `mobile-session-toggle-wrap`, `mobile-session-followup` et `mobile-session-pause-row` en desktop.
  - scope les styles desktop de `.pause-row` a `#pause-container` et `#pause-row-running-host` pour ne plus styler la ligne mobile compacte.

### Invariants
- aucun changement WS/scoring/rehydratation;
- aucun CTA inscription;
- le bloc compact `visuel + QR` reste disponible uniquement via la vue mobile organizer;
- la preview demo desktop `embed=gm&demo_player=1` conserve son chemin.

### Tests
- `cp /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js /tmp/canvas_display_check.mjs && node --check /tmp/canvas_display_check.mjs`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- verification statique: la ligne teleporteable desktop exclut `.mobile-session-pause-row`.

## PATCH 2026-05-04 — Mobile organizer: vue stable Animer / Jouer

### Objectif
- remplacer l'auto-affichage de l'iframe Game Master / participant par un toggle mobile `Animer / Jouer`;
- retirer les parcours d'inscription joueur pre-lancement cote organizer mobile, tout en conservant l'auto-register `embed=gm` apres lancement;
- ajouter une aide textuelle uniquement en demo mobile numerique en attente, sous le compteur joueurs du QR;
- harmoniser le libelle auto-inscrit en demo: `Équipe démo` pour Quiz, `Joueur démo` pour Blind Test et Bingo Musical;
- garder la meme structure mobile organizer pendant `En cours` et `Pause`;
- corriger l'UX de toutes les sessions mobiles numeriques lancees, demo comme officielles, sur Quiz / Blind Test / Bingo Musical:
  - proteger les blocs lots/QR de la barre d'actions mobile fixe dans `Animer`;
  - retirer le tag `VUE JOUEUR` et le cadre externe lourd autour de l'iframe dans `Jouer`;
- etendre le correctif UI mobile `Animer` aux sessions papier pour:
  - centrer la vague audio dans le bloc support;
  - remplacer le QR seul de bas de page par une ligne compacte visuel + QR;
- stabiliser la remontee immediate du joueur auto-inscrit dans le suivi mobile organizer apres auto-register `embed=gm`;
- stabiliser la reprise reload / continuation demo de l'identite auto-register organizer, sans doublon et sans formulaire d'inscription dans l'iframe;
- stabiliser la reprise demo mobile cote organizer `Animer`, sans attendre l'ouverture de l'onglet `Jouer`, et relayer les scores de l'iframe vers le suivi live;
- detecter la demo aussi dans l'iframe GM mobile, sans reutiliser le mode visuel desktop `demo_player=1`;
- conserver `#quiz-display` dans la posture `Animer`, y compris en pause;
- appliquer le meme principe aux sessions papier mobiles, sans toggle ni iframe joueur, en reutilisant `#mobile-session-followup` sous `#quiz-display`;
- reutiliser le rendu pause mobile existant sous `#quiz-display`, sans cards dediees;
- masquer toggle + blocs complements pendant le jingle de depart;
- garder une V1 pragmatique: pas de remote complete, pas de refonte organizer, pas de duplication des controles footerbar.

### Audit
- `../games/web/organizer_canvas.php` injectait `#player-interface` dans `#quiz-display` avec `d-lg-none`, donc visible uniquement mobile pendant `En cours`;
- la V1 precedente avait rendu cette iframe optionnelle, mais seulement via CTA ponctuel et seulement en `En cours`;
- `../games/web/includes/canvas/core/canvas_display.js` basculait encore vers `.en-pause` / `#pause-container` quand `setPhase('Pause')` etait appele;
- le bloc qui affiche `PAUSE` est `.leaderboard-pause-tag` dans `#pause-container`;
- le rendu pause/mobile session reutilisable est:
  - `.leaderboard.container-rounded-colored.p-3` + `.leaderboard-tag` + `.leaderboard-inner`;
  - `.pause-row` + `.pause-cell`;
  - `.lots-container`;
  - `.qr-container` + `.pause-qr-mask`;
- le jingle desktop/mobile est porte par `#intro-jingle-timer`, affiche par `showIntroCircleTimer()`, avec `status.loadingJingle` pendant la transition;
- le bloc organizer existant est le contenu deja present de `#quiz-display`: support, question/classement/notifs, options quiz desktop et blocs teleportes selon jeu;
- les donnees deja disponibles: compteur joueurs, rankings/players, lots, QR joueur, statut `status.gameStatus`;
- les controles de jeu restent dans la footerbar mobile existante, aucun controle n'est replique dans cette V1.

### Modifie
- `../games/web/organizer_canvas.php`
  - ajoute `#mobile-session-toggle-wrap` au-dessus de `#quiz-display`;
  - ajoute `#mobile-session-followup` sous `#quiz-display` en reprenant le markup/classes pause pour leaderboard, lots et QR;
  - ajoute l'id `#mobile-session-ranking-title` sur le tag joueurs existant pour permettre le libelle dynamique;
  - conserve `#mobile-player-view` et `#player-iframe` pour la posture `Jouer`;
  - retire le tag mobile `VUE JOUEUR` et la classe `container-rounded-colored` du wrapper mobile `#player-interface`, afin que l'iframe player paraisse integree sous le toggle;
  - remplace le QR mobile seul de `#mobile-session-followup` par une ligne compacte avec le visuel de jeu et le QR de rejointure;
  - ajoute en demo mobile numerique avant lancement l'aide sous le compteur joueurs: `Lance la démo, puis passe sur l’onglet Jouer pour tester l’expérience joueur.`;
  - n'affiche pas cette aide en session officielle ni en session papier;
  - aligne le libelle de preview demo desktop sur le jeu (`Équipe démo` pour Quiz, `Joueur démo` sinon).
- `../games/web/includes/canvas/play/register.js`
  - conserve `Game Master` pour l'auto-register `embed=gm` des sessions officielles numeriques;
  - utilise `Équipe démo` pour l'auto-register demo Quiz;
  - utilise `Joueur démo` pour l'auto-register demo Blind Test et Bingo Musical;
  - reconnait la demo mobile via `gm_demo=1`, en plus du flux desktop `demo_player=1`;
  - envoie au parent organizer un `postMessage` `gm-player-ready` avec l'identite complete du joueur auto-inscrit apres succes;
  - reprend directement l'identite GM locale scoppée a la session avant toute nouvelle inscription, pose `data-stage=play`, marque le joueur inscrit et republie `player/ready`;
  - si le stockage local manque, tente une reconciliation via `players_get` avant auto-register; les demos acceptent aussi l'ancien candidat `Game Master` cree par regression, mais republient le nom attendu du jeu;
  - loggue `register/autoreg:reconciled` avec source `local_identity`, `server_snapshot` ou `new_autoreg`, et `register/autoreg:reconcile_multiple_candidates` si plusieurs candidats sont trouves;
  - conserve l'identite canonique Bingo en `player_id` via le flux existant.
- `../games/web/includes/canvas/core/canvas_display.js`
  - garde un etat front local `__mobilePlayerActive`;
  - active la bascule uniquement si `status` vaut `En cours` ou `Pause`, layout mobile et mode numerique;
  - expose sur `body` la posture courante via `mobile-session-organizer-active` / `mobile-session-player-active`;
  - ajoute `isPaperMobileSession()` pour distinguer les sessions papier mobiles;
  - en pause mobile numerique, affiche `#quiz-display` et les blocs session mobile au lieu de `#pause-container`;
  - en papier mobile, affiche `#quiz-display` en cours comme en pause, puis reutilise `#mobile-session-followup` sous le jeu, sans afficher le toggle ni l'iframe joueur;
  - detecte le jingle via `status.loadingJingle` ou `#intro-jingle-timer` visible et masque temporairement toggle + suivi en mobile numerique comme papier;
  - rafraichit `#mobile-session-total-players` et `#mobile-session-ranking-list`;
  - met a jour le titre joueurs mobile via `status.gameStatus`: `Suivi des joueurs` en cours, `Pause` en pause;
  - expose le loader iframe par instance pour charger `#player-iframe` au clic sur `Jouer`.
  - ajoute `gm_demo=1` aux iframes GM des sessions demo sans appliquer `demo_player=1` a l'iframe mobile;
  - consomme `gm-player-ready`, merge le joueur auto-inscrit dans `GameStore.players`, puis rerend compteur et listes de suivi immediatement.
  - au bootstrap/reprise organizer, relit `players_get` pour hydrater le roster/score existant et restaurer l'identite auto-register en localStorage avant que l'onglet `Jouer` soit ouvert;
  - loggue `canvas_display:demo_autoreg:bootstrap_reconciled`, `canvas_display:demo_autoreg:score_resync` et `canvas_display:demo_autoreg:multiple_candidates`.
- `../games/web/includes/canvas/play/play-ui.js`
  - republie le message parent existant `gm-player-ready` quand le score/rang du player embarque change, afin que la vue `Animer` mobile mette a jour le suivi sans attendre une pause ou un snapshot long.
- `../games/web/includes/canvas/core/score_store.js`
  - `hydratePlayers()` conserve les joueurs existants quand un evenement serveur fournit seulement un total sans lignes joueurs detaillees.
- `../games/web/includes/canvas/core/ws_effects.js`
  - `updatePlayers` et `num_connected_players` ne traitent plus une liste vide avec total positif comme une purge de roster; ils conservent le roster local jusqu'au snapshot detaille suivant.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - rend le QR de rejointure `#mobile-session-qrcode`.
- `../games/web/includes/canvas/core/session_modals.js`
  - synchronise les lots du bloc mobile.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ajoute les styles du toggle, les espacements de session mobile et `.mobile-player-hidden` sous media query mobile;
  - borne l'aide demo QR au mobile numerique et masque l'ancien texte telephone sur mobile pour eviter deux aides concurrentes;
  - conserve les styles internes des blocs pause reutilises;
  - renforce la reserve basse de `#mobile-session-followup` uniquement en posture mobile numerique `Animer` non papier, pour proteger lots/QR de la barre d'actions fixe;
  - applique aussi en posture mobile `Animer` papier la reserve basse, le padding du bloc lots et la ligne compacte visuel + QR;
  - centre la vague audio dans `#quiz-support` en posture mobile `Animer`, via le wrapper YouTube en flex/absolute et une taille de SVG bornee;
  - allege `#mobile-player-view .mobile-player-interface` et supprime le rayon externe de l'iframe mobile pour eviter le double cadre en posture `Jouer`;
  - retire `.en-cours` de la marge mobile globale `6rem`, afin que `#quiz-display` ne cree pas de vide avant les blocs organizer;
  - cible la securite footerbar sur `#mobile-player-view` pour la posture `Jouer`, avec une hauteur minimale responsive sur `#player-iframe`;
  - reouvre legerement les marges entre toggle, `#quiz-display` et blocs organizer, pour eviter les quasi-chevauchements des tags absolus sans revenir aux grands vides.
  - masque `#quiz-leaderboard-overlay` uniquement sous `body[data-game="quiz"].mobile-session-organizer-active` en mobile, pour retirer le doublon `Point scores !` dans la posture `Animer`.
  - rend le bloc lots de `#mobile-session-followup` compact (`height:auto`, contenu en haut, liste rapprochee du titre) et porte la reserve footerbar sur le conteneur mobile commun, pas sur les cards.
- `../games/web/includes/canvas/core/canvas_display.js`
  - redemande au player son resize `gm-iframe-size-request` lors du passage a `Jouer`, en reutilisant le mecanisme iframe existant.
- `../games/web/includes/canvas/play/play-ui.js`
  - ajuste la mesure de hauteur `embed=gm` pour privilegier le contenu visible du document plutot que le `clientHeight` viewport quand celui-ci agrandit artificiellement l'iframe.
- `../games/web/includes/canvas/core/player/strategies/quiz.js`
  - corrige la branche Quiz numerique mobile: `#quiz-question` n'est plus masque quand la posture `Animer` est active;
  - rend cette detection robuste aux courses de rendu en croisant `body.mobile-session-organizer-active`, `status.gameStatus`, le toggle mobile et l'etat de `#mobile-player-view`;
  - conserve le masquage historique hors posture organizer, ou l'interface joueur peut prendre le relais.
- `../games/web/config.php`
  - bump local `CANVAS_ASSET_VER`.

### Invariants
- desktop inchange;
- avant session officielle et fin de session inchanges;
- modes papier mobile et desktop inchanges pour ces deux correctifs UX;
- pas de CTA d'inscription joueur pre-lancement, pas de `organizer_signup=1`, pas d'ouverture iframe player avant lancement pour inscrire l'organisateur;
- fonctionnement interne de l'iframe `embed=gm` inchange hors libelle demo;
- pas d'auto-register participant papier;
- le compteur mobile organizer ne doit plus rester durablement superieur a zero avec une liste de suivi vide apres auto-register GM;
- reload / reprise d'une meme session: l'iframe GM reutilise le meme `player_id` canonique et le meme id DB si disponibles; aucune creation silencieuse de doublon;
- reload / reprise demo mobile: la vue `Animer` hydrate aussi le joueur/score existant via snapshot serveur sans necessiter un passage prealable par `Jouer`;
- score live demo mobile: les changements de score de l'iframe GM sont repercutes dans le suivi organizer via le message parent existant `gm-player-ready`;
- pas de changement WS/API/DB.

### Limites
- la lisibilite mobile depend du responsive desktop existant;
- `#quiz-display` conserve la densite responsive existante;
- le jingle masque les complements mobiles, mais le rendu de `#quiz-display` reste celui de l'overlay existant;
- la question/support courant restent visibles dans `Animer`, donc l'organisateur qui joue depuis le meme telephone doit utiliser `Jouer` pour ne pas consulter la posture organizer;
- la hauteur iframe depend du resize fourni par le document player quand le contenu depasse le repli CSS;
- si un contenu player utilise des elements hors flux ou une hauteur CSS imposee, l'iframe peut encore scroller au lieu de coller exactement au contenu;
- une V2 pourra reprendre une logique inspiree remote si la V1 confirme le besoin.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/config.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/session_modals.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `git diff --check`

## PATCH 2026-05-04 — Demo iframe: préserver le GM mobile

### Objectif
- corriger l'effet de bord ou l'iframe Game Master mobile recevait aussi le mode `demo_player=1` en session demo;
- conserver la hauteur naturelle et le scroll page de l'iframe GM mobile historique.

### Modifie
- `../games/web/includes/canvas/core/canvas_display.js`
  - construit l'URL iframe par iframe;
  - ajoute `demo_player=1` uniquement a `#demo-player-iframe`;
  - retire explicitement ce parametre pour `#player-iframe` mobile.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- la `Vue joueur démo` desktop garde `embed=gm&demo_player=1`;
- l'iframe Game Master mobile garde seulement `embed=gm`;
- pas de changement quota/scoring/WS.

## PATCH 2026-05-04 — Demo desktop: wording Vue joueur

### Objectif
- clarifier le haut de la coque `Vue joueur` des demos desktop;
- inciter l'utilisateur a tester aussi la demo depuis un vrai mobile via QR code.

### Modifie
- `../games/web/organizer_canvas.php`
  - remplace le tag `Joueur démo` par `Vue joueur démo` + `Testez aussi sur votre mobile avec le QR code.`
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ajoute le style compact titre/sous-titre dans la coque telephone.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/config.php`

## PATCH 2026-05-04 — Demo quota: Joueur demo compte dans maxPlayers

### Objectif
- simplifier la regle produit des demos desktop: `Joueur démo` compte dans la limite affichee;
- avec une demo a 2 joueurs max, laisser 1 place mobile en plus du joueur automatique;
- harmoniser Quiz, Blind Test et Bingo.

### Modifie
- Cote `games`, pas de changement de flux player: l'iframe continue d'envoyer `demoParticipant:true` comme meta demo et conserve le libelle `Joueur démo`.
- Les serveurs WS Quiz/Blind Test/Bingo retirent l'exemption quota.

### Invariants
- scoring, classements et affichage live inchanges;
- sessions normales inchangees;
- Bingo conserve l'attribution de vraie grille via `grid_assign`.

## PATCH 2026-05-04 — Demo desktop Bingo: Vue joueur + Joueur demo

### Objectif
- etendre a Bingo Musical la preview desktop `Vue joueur` deja livree pour Quiz/Blind Test;
- reutiliser le flux iframe/player existant sans mock decoratif;
- attribuer une vraie grille Bingo a `Joueur démo`.

### Audit
- `../games/web/organizer_canvas.php` limitait encore le panneau aux demos `quiz`/`blindtest`.
- `../games/web/includes/canvas/play/register.js` savait deja auto-inscrire l'iframe `embed=gm` Bingo, utiliser `Joueur démo` si `demo_player=1`, appeler `grid_assign`, stocker `bingo_grid_secret` et emettre `player/ready`.
- `../games/web/includes/canvas/play/play-ws.js` envoyait `demoParticipant:true` pour Quiz/Blind Test via `registerPlayer`, mais pas encore sur l'auth Bingo `auth_player`.
- Le reset demo Bingo conserve deja le contrat documente: purge `bingo_phase_winners` + etats locaux player, conservation `bingo_players` et assignations de grilles.

### Modifie
- `../games/web/organizer_canvas.php`
  - active le panneau desktop `Vue joueur` pour les demos Bingo.
- `../games/web/includes/canvas/play/play-ws.js`
  - ajoute `demoParticipant:true` dans l'auth WS Bingo `auth_player` uniquement pour l'iframe `embed=gm&demo_player=1`.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- sessions Bingo normales inchangees;
- iframe Game Master mobile historique inchangee hors `demo_player=1`;
- QR demo principal conserve avec `Scannez le QR code pour tester aussi depuis votre téléphone.`;
- Quiz/Blind Test non modifies fonctionnellement dans cette passe.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/config.php`

## PATCH 2026-04-30 — Demo desktop: Vue joueur + Joueur demo

### Objectif
- rendre visible la boucle organizer -> joueur -> reponse -> score/classement dans les demos desktop;
- reutiliser le flux player existant sans masquer le QR code;
- nommer clairement le participant automatique `Joueur démo`.

### Modifie
- `../games/web/organizer_canvas.php`
  - ajoute un panneau desktop `Vue joueur` pour les demos Quiz/Blind Test;
  - conserve le QR code principal et ajoute le wording `Scannez le QR code pour tester aussi depuis votre téléphone.`
- `../games/web/includes/canvas/core/canvas_display.js`
  - gere plusieurs iframes player via `data-player-iframe`;
  - ajoute `demo_player=1` a l'URL iframe des sessions demo.
  - configure uniquement l'iframe desktop demo des `session/init` et force son chargement, pour eviter l'etat `about:blank` en attente sans modifier le declenchement mobile historique.
  - mesure le cockpit organizer reel avec `ResizeObserver` quand la preview desktop est visible, puis expose `--organizer-viewport-width` et `--organizer-qr-max-size`;
  - mesure l'union entre le header organizer et la scene organizer visible (`#waiting-container`, `#quiz-display`, `#pause-container`) et expose `--demo-player-scene-top` / `--demo-player-scene-height`.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - appelle explicitement la configuration de l'iframe demo apres `attachOrganizerUI()`, car le premier `session/init` est emis avant l'attache des listeners UI;
  - initialise les metriques de cockpit organizer pour recalculer le QR au redimensionnement.
- `../games/web/includes/canvas/play/register.js`
  - le mode iframe demo inscrit `Joueur démo`;
  - ne bloque pas l'auto-register demo sur une session deja full cote probe.
- `../games/web/includes/canvas/play/play-ws.js`
  - propage `demoParticipant:true` au WS comme meta demo; ce flag ne doit plus exclure ce joueur du quota.
- `../games/web/includes/canvas/play/play-ui.js`
  - ajoute la classe `demo-player-embed` uniquement au player `embed=gm&demo_player=1`, sans toucher au Game Master mobile.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - style du panneau desktop, du wording QR demo et de la coque telephone de preview;
  - masque le bloc explicatif `demo-player-copy` pour laisser plus de hauteur au telephone;
  - centre la coque telephone dans la hauteur utile de l'ecran desktop;
  - force l'iframe a remplir la largeur interne sans bordure native;
  - plafonne `#main-qr-container` et `.qr-svg` via `--organizer-qr-max-size` quand le layout demo player est actif;
  - cale le panneau `Vue joueur` sur la bande verticale mesuree de la scene organizer au lieu du viewport/safe area footer.
- `../games/web/includes/canvas/css/player_styles.css`
  - compacte uniquement le contenu embarque `demo-player-embed`;
  - ajoute une teinte de fond derivee de `--primary-bg`, sans imposer une couleur hors branding client;
  - donne une hauteur explicite a la zone scrollable dans l'iframe tout en forcant la footerbar score/classement visible;
  - ajoute les interactions souris desktop sur les elements cliquables;
  - applique `box-sizing:border-box` et `min-width:0` dans le scope embed pour eviter le rognage lateral sans reduire artificiellement le viewport.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Limites
- V1 limitee a Quiz et Blind Test; Bingo Musical reste a cadrer a cause de l'attribution de grille.
- La vue integree reutilise le parcours player reel `embed=gm`; aucun faux mock decoratif n'est ajoute.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/config.php`

## PATCH 2026-04-30 — Organizer: prelaunch reseau mobile sans faux orange navigateur

### Objectif
- reduire les faux positifs orange sur mobile 4G/5G quand les endpoints et le jeu sont fluides;
- identifier le declencheur du message `La connexion de cet appareil semble lente ou instable.`;
- reserver la vigilance orange reseau a une lenteur/instabilite applicative mesuree ou a un check reellement fragile.

### Audit
- le message est produit dans `prelaunch_check.js` quand la raison primaire est `network_profile`, `network_probe` ou `network_slow`;
- le faux positif mobile venait du check `network_profile`: `isSlowNetworkConnection(...)` convertissait des signaux `navigator.connection` (`effectiveType`, `downlink`, `rtt`, `saveData`) en `STATUS.WARN`;
- comme `hasSlowNetworkProfile(...)` considere `network_profile WARN` comme vigilance, ce signal navigateur seul suffisait a passer orange.

### Modifie
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - `checkNetworkProfile()` garde le rouge uniquement pour `navigator.onLine === false`;
  - les profils `type`, `effectiveType`, `downlink`, `rtt`, `saveData` sont affiches comme indicatifs en `STATUS.OK`;
  - l'orange reste porte par les checks applicatifs existants: bridge lent, `network_probe` lent/instable, WS ou autres signaux reels.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- prelaunch reseau conserve;
- cellulaire, inconnu, `effectiveType` prudent ou `downlink` faible ne bloquent pas et ne passent pas orange seuls;
- mode avion/offline reste rouge;
- endpoint/bridge/WS KO restent bloquants selon les regles existantes;
- API `navigator.connection` toujours optionnelle;
- scan supports multimedia non reintegre cote organizer.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `php -l /home/romain/Cotton/games/web/config.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-30 — Organizer: prelaunch reseau mobile non bloquant

### Objectif
- accepter les connexions mobiles 3G/4G/5G quand les tests applicatifs passent;
- ne plus convertir l'absence de Wi-Fi, un type cellulaire ou un `downlink` navigateur nul en diagnostic rouge;
- conserver le rouge pour les echecs reels: navigateur offline, bridge/WS indisponibles, timeout critique ou endpoint indispensable KO.

### Modifie
- `../games/web/includes/canvas/core/network_profile.js`
  - expose `navigator.connection.type` dans le snapshot et l'affichage du profil pour garder le transport en contexte;
  - reserve `isOfflineNetworkConnection()` a `navigator.onLine === false`;
  - ne traite plus `downlink <= 0` comme absence d'Internet exploitable.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- prelaunch reseau conserve;
- checks applicatifs `bridge`, `ws_open`, `ws_stability` et `network_probe` conserves;
- rouge toujours bloquant en cas d'offline ou d'echec applicatif bloquant;
- cellulaire/inconnu non bloquant si les checks applicatifs passent;
- scan supports multimedia non reintegre cote organizer;
- API `navigator.connection` optionnelle.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/network_profile.js`
- `php -l /home/romain/Cotton/games/web/config.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-30 — Organizer: prelaunch vert leger, orange/rouge explicites

### Objectif
- conserver une UX legere quand le prelaunch est vert: pas d'ouverture automatique de diagnostic, pas de confirmation demo;
- ouvrir automatiquement le diagnostic quand le prelaunch auto termine orange ou rouge, en demo comme en officiel;
- conserver les garde-fous de lancement rouge/orange/vert existants;
- rendre la confirmation officielle claire: vert avec lien discret, orange avec CTA secondaire diagnostic, rouge bloque.

### Modifie
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - remplace le titre/sous-titre de la modale par `Diagnostic avant lancement` et `Vérification de cet appareil, de la connexion et du son.`;
  - conserve le lancement automatique `runPrelaunchCheck(...)` au chargement et a la reprise en `En attente`;
  - ouvre automatiquement `showPrelaunchModal()` seulement quand l'auto-precheck finit en `warning` ou `fail`;
  - garde le verrou remote/diagnostic uniquement pour les etats `fail`, `running` et `untested`; les etats finaux vert/orange ne dependent plus d'une fermeture de modale.
  - ne publie plus les bandeaux prelaunch orange/rouge de l'auto-check tant que la session est encore `En attente`.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - conserve la modale officielle de lancement;
  - restaure l'icone SweetAlert `question` de la confirmation officielle, liee au titre comme en prod;
  - remplace le bouton `Annuler` par une croix de fermeture dans les confirmations prelaunch;
  - en officiel vert, affiche seulement l'avertissement metier, le CTA `✅ Oui, démarrer` et le lien discret `Diagnostic réseau et son` sous le CTA principal;
  - en officiel orange, affiche `Point à vérifier avant ta session` sans lien dans le message, puis un CTA secondaire `Voir le diagnostic`;
  - en demo vert, lance directement sans confirmation ni proposition `Tester le son`;
  - en demo orange, conserve la confirmation legere avec `Lancer la démo` et `Voir le diagnostic`;
  - conserve le blocage rouge avant la confirmation officielle: clic `Lancer` -> modale diagnostic, pas de lancement.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ajoute un lien officiel vert discret sous le CTA principal;
  - rend le CTA secondaire diagnostic en outline vigilance.
  - reserve l'espace de la croix sur le titre des confirmations de lancement pour eviter le chevauchement.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- prelaunch automatique conserve;
- seuils rouge/orange/vert inchanges;
- scan supports multimedia non reintegre cote organizer;
- bouton `Lancer` reste cliquable en rouge pour ouvrir le diagnostic;
- statut orange non bloquant;
- modale prelaunch existante et coupure automatique du jingle inchangees;
- pas de confirmation demo en vert;
- comportement de reprise/redemarrage des demos inchange.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `php -l /home/romain/Cotton/games/web/config.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-30 — Organizer: sessions demo prelaunch allegees

### Objectif
- alleger la premiere experience demo sur l'interface organizer;
- conserver le prelaunch automatique, ses seuils et les blocages de lancement;
- eviter l'ouverture automatique de la modale diagnostic au chargement des demos vertes.

### Modifie
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - detecte les sessions demo via `AppConfig`, `ServerSessionMeta` ou `ClientSessionMeta`;
  - conserve `runPrelaunchCheck({ trigger: 'auto_precheck' })` au chargement;
  - n'appelle plus automatiquement `showPrelaunchModal()` pour les demos vertes; orange/rouge rouvrent le diagnostic avec la regle cible du 2026-04-30;
  - ne maintient plus le garde remote/modal-dismissed sur une demo verte ou orange; rouge/running/untested restent gardes.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - ajoute une confirmation demo dediee au clic `Lancer`;
  - orange: message `La démo peut être lancée, mais un point est à surveiller.`, CTA principal `Lancer la démo`, CTA secondaire `Voir le diagnostic`;
  - vert: lancement direct sans confirmation;
  - les CTA secondaires ferment la confirmation et ouvrent la modale prelaunch existante, qui porte deja le controle jingle;
  - rouge/running/untested restent bloques avant lancement et rouvrent la modale diagnostic.
- `../games/web/includes/canvas/core/canvas_display.js`
  - inclut `ClientSessionMeta.isDemo` dans la detection de prelaunch requis pour la pastille et l'attente de fin d'auto-check.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ajoute le style compact de la confirmation demo.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- prelaunch automatique conserve;
- seuils rouge/orange/vert inchanges;
- scan supports multimedia non reintegre cote organizer;
- bouton `Lancer` reste cliquable en rouge: le clic ouvre le diagnostic sans lancer;
- fermeture de la modale coupe toujours le jingle temoin via le chemin existant;
- wording demo limite au jingle/player sur cet appareil, sans garantie d'audibilite future.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `php -l /home/romain/Cotton/games/web/config.php`

## PATCH 2026-04-29 — Organizer: prelaunch plus friendly

### Objectif
- rendre la modale prelaunch organizer moins froide et plus proche d'une checklist de preparation avant animation;
- conserver strictement le comportement existant du test configuration/connexion et du jingle temoin;
- corriger la priorite de garde au clic `Lancer`: une session future non ouverte doit afficher l'alerte de session non ouverte, pas la modale prelaunch non executee.

### Modifie
- `../games/web/includes/canvas/core/boot_organizer.js`
  - borne le blocage prelaunch du clic `Lancer` aux sessions en attente qui sont ouvertes ou demo;
  - laisse les sessions futures non ouvertes passer vers `gateStartWithSessionMeta()`, qui affiche l'alerte existante `Prepare ta session...`.
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - reformule le header en `On verifie que tout est pret`;
  - ajoute des icones de domaine, badges de statut compacts et CTAs `Relancer le test` dans les deux panneaux fixes;
  - simplifie les titres de panneaux en `Session et connexion` et `Son et medias`, sans sous-titre de panneau;
  - supprime les titres internes redondants avec les badges: le message principal porte directement l'information utile;
  - simplifie les succes: `La session est prete.` et `Le jingle a bien demarre sur cet appareil.`;
  - corrige le badge header des etats verts: `ready` affiche maintenant `Verifie`, pas `A surveiller`;
  - remplace le libelle rouge `Action requise` par `Action necessaire`;
  - conserve les deux panneaux visibles: `Session et connexion` et `Son et medias`;
  - conserve le statut factuel du jingle temoin: il verifie le demarrage du player sur cet appareil, pas l'audibilite.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - adoucit la modale avec fond chaud, cartes checklist, badges verts/oranges/rouges harmonises, icones plus visibles et spacing plus compact;
  - colore le fond des icones de domaine selon le niveau courant vert/orange/rouge;
  - allege le bandeau de statut interne pour reduire l'effet carte imbriquee;
  - aligne les actions recommandees a gauche avec indentation moderee;
  - rend la relance moins prioritaire quand le panneau est vert;
  - masque le sous-titre global sur mobile pour reduire la hauteur;
  - garde le responsive mobile en faisant passer badge et action sous le titre du panneau.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- logique metier prelaunch inchangee;
- seuils reseau inchanges;
- regles rouge/orange/vert inchangees;
- aucun endpoint, SQL ou WebSocket modifie;
- scan supports multimedia non reintegre cote organizer;
- fermeture de la modale coupe toujours le jingle temoin via le chemin existant.
- sessions futures non ouvertes: la modale prelaunch n'est plus ouverte au clic `Lancer`; le message de session non ouverte reprend la priorite.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `php -l /home/romain/Cotton/games/web/config.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-28 — Organizer: modale prelaunch en 2 panneaux fixes

### Follow-up
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - reformule uniquement les wordings visibles du parcours prelaunch actuel: titre/sous-titre de modale, panneaux connexion/direct et son/medias, statuts globaux, checks reseau, conseils, rappel de lancement et bandeaux;
  - retire le jargon visible des messages utilisateur (`WebSocket`, `localStorage`, `sessionStorage`, `Profil reseau navigateur`, `API YouTube`, `preflight`, `RTT`) au profit de formulations autour de la session, de Cotton, du direct joueurs, d'Internet et de cet appareil;
  - conserve les fonctions legacy de scan complet des supports multimedia et de remplacement temporaire sans reecriture de wording, puisqu'elles ne sont pas atteintes dans le parcours runtime actuel.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - reformule le rappel orange de confirmation de lancement et l'alerte fallback rouge sans employer `configuration`.
- `../games/web/includes/canvas/core/canvas_display.js`
  - reformule les tooltips runtime du bouton `Lancer` quand le prelaunch est en attente ou bloque.
- `../games/web/includes/canvas/core/network_profile.js`
  - remplace l'affichage brut `RTT` par une mention utilisateur `reponse ... ms`.
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - bloque le lancement du jingle temoin tant que le panneau configuration n'a pas termine son test;
  - ajoute un garde dans `runSoundControl()` pour eviter une collision meme si le bouton est force cote DOM;
  - recentre le panneau jingle temoin sur la verification factuelle du demarrage du player;
  - retire les statuts/raisons de resultat lies au volume ou au son, puisque le test ne peut pas confirmer que le son est entendu;
  - ajoute seulement en succes le conseil utilisateur: si le jingle n'est pas entendu, verifier les equipements/le volume puis relancer le test;
  - clarifie le diagnostic player/volume: un jingle temoin qui ne demarre pas signale un probleme de player/lecture, pas un probleme de volume;
  - evite d'ajouter `sound_user` en echec quand le jingle YouTube ne demarre pas, afin de ne pas afficher de conseil volume contradictoire;
  - rattache le check `player_link` au panneau connexion/configuration;
  - retire les mentions `rechargez cette page` des actions prelaunch au profit de `relancez ce test`;
  - remplace l'action stockage par `Evitez l'utilisation du navigateur en navigation privee et autorisez l'utilisation du stockage local.`;
  - supprime le bouton `Stop` du jingle temoin;
  - conserve la coupure automatique du jingle/test a la fermeture de la modale;
  - attend l'etat YouTube `PLAYING` avant de produire un resultat positif player/volume;
  - evite qu'une fermeture avant resultat soit interpretee comme un test valide.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - applique au bouton `Fermer` de la modale prelaunch le style du bouton principal de confirmation de lancement.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Objectif
- clarifier la difference entre un probleme configuration/connexion et un probleme player/son;
- garder les deux tests visibles des l'ouverture de la modale.

### Modifie
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - affiche deux panneaux fixes dans la modale prelaunch:
    - connexion/stabilite: test automatique, spinner, bloc resultat, relance ciblee;
    - player/volume: CTA jingle temoin, spinner pendant la lecture, bloc resultat, relance ciblee;
  - separe les raisons principales et les actions recommandees par domaine;
  - retire le CTA global `Recharger la page` de la modale: le footer garde seulement `Fermer`.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ajoute le layout de header de panneau et son comportement mobile.
- `../games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `php -l /home/romain/Cotton/games/web/config.php`

## PATCH 2026-04-27 — Organizer: prelaunch recentre sur la configuration

### Objectif
- retirer le scan des supports multimedia de l'UI organizer;
- garder dans `games` uniquement un controle automatique de configuration du poste avant lancement;
- reporter le scan/correction des supports vers la fiche detail de session EC `pro`, plus adaptee aux actions de remplacement.

### Correctif livre
- `../games/web/organizer_canvas.php`
  - supprime le bouton footerbar `Verif`;
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - garde le code de scan supports dans le module, mais ne l'appelle plus depuis l'organizer;
  - lance automatiquement uniquement les checks techniques quand la session est dans une fenetre de lancement reelle;
  - aligne cette fenetre sur `window.ClientSessionMeta.isOpen`, deja utilise par le bouton `Lancer`, pour eviter un etat `Configuration non verifiee` permanent sur une session pourtant ouvrable;
  - ecoute maintenant les changements `navigator.connection` tant que la session est en attente et re-evalue seulement le check `network_profile`, afin que Slow 4G/retour reseau mette a jour la pastille `Lancer` et la confirmation sans refaire tout le prelaunch;
  - relit aussi `network_profile` apres la fin du prelaunch initial, avec un second passage differe, pour capter le profil DevTools deja actif au chargement mais expose tardivement par Chrome;
  - ajoute `network_probe`, un telechargement cache-buste d'un asset Cotton pour mesurer la connexion effective sur tous navigateurs;
  - ouvre la modale prelaunch au chargement organizer, affiche `Test de ta configuration en cours`, puis bascule sur la synthese et les actions;
  - force l'affichage de la synthese des que le test automatique produit un statut final (`ready`, `warning`, `fail`), afin d'eviter que la modale reste sur `Test termine / Affichage de la synthese...`;
  - ajuste le sous-titre de modale pour citer le poste et le reseau, retire les restes de l'ancienne synthese dans le corps et garde uniquement le reminder final apres l'etape automatique;
  - affiche le controle player/volume sous le reminder, quand il est utile, avec le style du bloc precedemment utilise dans la confirmation de lancement;
  - securise le layout du reminder pour que les conseils restent sous `Avant de demarrer, si possible :` ou `Actions a effectuer :`;
  - masque le CTA footer `Recharger la page` quand le resultat est vert et renomme le bouton audio `Jingle temoin`;
  - retire `media_dependency` de l'auto-check navigateur: le test player/lecture YouTube complet reste declenche par le bouton `Tester le player et le volume`, afin de profiter du geste utilisateur requis par le navigateur;
  - masque l'etape player/volume si l'etape configuration est rouge;
  - retire le rappel prelaunch et le controle audio de la confirmation de lancement, qui redevient une confirmation simple;
  - verrouille l'acces remote/QR remote tant que la modale prelaunch n'est pas fermee ou que le statut prelaunch est rouge;
  - retarde la popup papier d'invitation a ouvrir la telecommande jusqu'a la fermeture de la modale prelaunch, et ne l'affiche pas si la configuration reste rouge;
  - classe l'API YouTube bloquee en rouge si la session contient de vrais supports YouTube, et en vigilance si seul le jingle temoin est concerne;
  - applique des conseils utilisateur differencies pour connexion mesuree lente, mesure reseau incomplete, vigilance YouTube et blocage YouTube;
  - evite maintenant de republier le bandeau global orange/rouge quand le controle son met seulement a jour `audioProbe`;
  - aligne les bandeaux auto-precheck orange/rouge sur les phrases de synthese de la modale;
  - lance en parallele les checks independants apres ouverture WebSocket pour limiter le temps d'attente ajoute par `network_probe` et `media_dependency`;
  - place l'etape `Player et volume` dans la modale prelaunch, sous la synthese, avec un bouton `Tester le player et le volume` et un bouton `Stop` quand le jingle temoin est actif;
  - deduplique les conseils de lancement par intention pour eviter les actions quasi identiques quand plusieurs checks reseau echouent;
  - connecte le resultat du jingle temoin au check `media_dependency`, afin que le reminder et le blocage de lancement suivent un echec YouTube detecte au clic;
  - preserve le resultat du test termine quand l'utilisateur clique sur `Lancer`, au lieu de remettre l'etat a `untested` juste avant la confirmation;
  - expose le statut prelaunch sur le bouton `Lancer`;
  - ajoute le HTML de confirmation de lancement avec mini synthese + controle du son;
  - rend les messages orange et rouge plus explicites, avec jusqu'a 3 conseils cibles selon les checks en alerte ou bloquants;
  - ajuste les textes vert, non-verifie, QR et WebSocket pour rester comprehensibles cote utilisateur;
  - controle `localStorage` et `sessionStorage` dans l'etape navigateur; si le stockage est bloque, l'erreur devient bloquante et le prelaunch s'arrete avant les checks reseau pour eviter les faux diagnostics;
  - remplace le message rouge additionnel oriente connexion par un message generique sur les points signales;
  - remplace les invitations utilisateur a `relancer le test` par une demande de rechargement de page;
  - finalise le wording rouge autour de `Actions a effectuer` et de conseils simples par type de blocage;
  - finalise le wording orange autour de l'experience potentiellement moins fluide sur ce poste et de conseils cibles par type de vigilance;
  - bloque la confirmation de lancement si le statut config est rouge;
  - ajoute sous le verdict de confirmation une phrase sans prefixe technique, inspiree du wording utilisateur existant, pour expliquer le premier check bloquant ou en vigilance qui justifie `Configuration a surveiller` ou `Configuration a corriger`;
  - conserve le bouton `Stop` du jingle temoin et la coupure a la fermeture de la confirmation/modale.
- `../games/web/includes/canvas/core/network_profile.js`
  - centralise la detection de profil reseau lent pour prelaunch et player;
  - reprend les seuils player: audio `< 1.2 Mb/s`, video `< 2.0 Mb/s`, RTT `> 250 ms`, types `slow-2g/2g/3g` et `saveData`.
- `../games/web/includes/canvas/core/player/index.js`
  - consomme le module reseau partage pour le bandeau `Connexion lente detectee`;
  - n'affiche plus ce bandeau tant que la session est `En attente`, afin que le prelaunch reste l'unique alerte avant lancement.
- `../games/web/organizer_canvas.php`
  - ajoute l'alias importmap `@canvas/core/network_profile`.
- `../games/web/includes/canvas/core/session_modals.js` et `../games/web/includes/canvas/core/ws_effects.js`
  - protegent les acces stockage pendant le boot pour eviter qu'un `SecurityError` localStorage/sessionStorage ne provoque de faux diagnostics reseau.
- `../games/web/includes/canvas/core/canvas_display.js`
  - desactive le bouton `Lancer` tant que l'auto-check d'une session ouverte n'a pas produit un statut final;
  - laisse maintenant `Lancer` cliquable si le statut prelaunch est rouge, afin que le clic rouvre la modale de test sans lancer la session;
  - affiche seulement la pastille de statut sur `Lancer` en etat `En attente`.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - garde la confirmation de lancement simple;
  - bloque les demandes de lancement UI/remote si le prelaunch est rouge ou si le garde-fou remote est encore actif;
  - affiche un rappel leger `Configuration a surveiller - voir le test` dans la confirmation de lancement quand le prelaunch est orange, afin de rouvrir la modale de diagnostic sans recharger;
  - expose le helper de rappel orange au scope du portail de lancement pour eviter une erreur runtime avant affichage de la SweetAlert;
  - attend la fin/fermeture du prelaunch avant d'afficher la popup papier de telecommande.
- `../games/web/includes/canvas/core/session_modals.js`
  - empeche l'auto-ouverture du QR remote papier tant que le garde-fou prelaunch est actif.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - deplace les pastilles prelaunch du bouton `Verif` supprime vers le bouton `Lancer`;
  - ajoute le style du bloc audio dans la confirmation de lancement.
  - ajoute le style de la raison principale dans le rappel de confirmation.
  - remonte les z-index des modales Bootstrap/SweetAlert au-dessus du bouton quit flottant mobile.
  - laisse le padding natif de la liste des conseils prelaunch dans la confirmation de lancement.

### Effet attendu
- organizer reste centre sur la capacite du poste a lancer/animer;
- les supports multimedia ne sont plus scannes ni affiches dans l'organizer;
- les corrections de supports seront traitees cote `pro`, la ou les actions de remplacement existent deja.

### Verification
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js /tmp/boot_organizer.mjs && node --check /tmp/boot_organizer.mjs`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js /tmp/canvas_display.mjs && node --check /tmp/canvas_display.mjs`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-27 — Organizer: stop du jingle temoin prelaunch

### Objectif
- permettre a l'organisateur de couper le jingle temoin lance depuis la synthese du test prelaunch;
- eviter qu'un test de son continue a jouer si l'organisateur ferme la modale.

### Correctif livre
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - ajoute un controle interne du media de test audio en cours;
  - affiche un bouton `Stop` a cote de `Lancer le jingle temoin` quand le test sonore est actif;
  - coupe le son actif sur clic `Stop`;
  - coupe aussi le son sur fermeture de la modale (`hide.bs.modal` / `hidden.bs.modal` et fermeture programmatique).

### Verification
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-27 — Organizer: injection JSON inline durcie

### Objectif
- corriger un chargement DOM incomplet observe sur `organizer_canvas.php` pour une session demo `quiz` avec le lot `L246` (`Tubes des annees 80`);
- eviter qu'une donnee de playlist, de lot, de branding ou de preload contenant une sequence HTML sensible casse une balise `<script>` inline et empeche le rendu de la footerbar organizer.

### Correctif livre
- `../games/web/organizer_canvas.php`
  - ajoute le helper `canvas_inline_json(...)`;
  - encode toutes les donnees injectees dans les scripts inline avec `JSON_HEX_TAG`, `JSON_HEX_AMP`, `JSON_HEX_APOS`, `JSON_HEX_QUOT` et `JSON_INVALID_UTF8_SUBSTITUTE`;
  - applique ce durcissement a `ServerSessionMeta`, `Preload`, `AppConfig`, `GameMeta`, branding, defaults design, titre et lots de session.

### Effet attendu
- une valeur issue d'un lot ou d'un preload ne peut plus fermer prematurement une balise `<script>` via `</script>` ni produire un JSON vide a cause d'un octet UTF-8 invalide;
- le DOM organizer doit continuer jusqu'a la footerbar, y compris sur les sessions demo avec contenus atypiques.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-24 — Organizer: pre-check auto et blocage strict du lancement

### Objectif
- lancer automatiquement l'etape 1 du test organizer au chargement de page;
- reutiliser la footerbar existante (`Test`, bandeau, `Lancer`) pour refléter ce pre-check sans lancer tout le module;
- reserver le blocage de `Lancer` aux seules incompatibilites vraiment critiques.

### Correctif livre
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - introduit un etat runtime `inactive / auto_running / manual_running / completed / cancelled`;
  - ajoute un mode `auto_precheck` qui s'arrete apres les checks techniques;
  - ne lance ni scan multimedia ni controle du son dans ce mode auto;
  - conserve le test complet derriere le bouton `Test`;
  - masque `Test` et annule tout scan en cours des que le jeu quitte `En attente`;
  - relance un pre-check auto si l'organizer revient ensuite en `En attente`;
  - corrige une regression perf post-lancement: le subscribe organizer ne recancel plus le prelaunch sur chaque patch du store apres sortie de `En attente`, mais seulement sur transition reelle de `gameStatus`;
  - verrouille aussi `initPrelaunchCheck()` pour eviter un double abonnement si le module est reinitialise;
  - recale le rouge sur les seuls checks critiques de lancement, et degrade les autres echecs en vigilance orange;
  - reutilise le bandeau organizer partage orange/rouge selon le resultat, au lieu d'un conteneur dedie;
  - pour l'orange, reprend maintenant le wording `Connexion lente detectee...` et un TTL de `5s`, identique au bandeau de connexion lente pendant le jeu;
  - le rouge `Configuration incompatible` utilise maintenant lui aussi un TTL de `5s`.
  - ajuste maintenant le wording utilisateur du module pour un ton plus simple et plus oriente animation:
    - intro modale et note de prudence simplifiees;
    - etape 1 renommee `Connexion et stabilite`;
    - libelles techniques raccourcis (`connexion Cotton`, `direct`, `acces joueur`, `connexion`, `supports`);
    - synthese technique reformulee en `configuration verifiee / a surveiller / a corriger`;
    - diagnostics supports/YouTube/media simplifies, sans mention `Controle catalogue Cotton` cote utilisateur;
    - bloc son reformule en guidance animateur simple;
    - bandeaux auto-precheck, titres runtime du bouton `Test` et rappel de lancement alignes sur ce meme ton.
  - ajuste maintenant la phrase de synthese principale pour distinguer:
    - problemes de connexion uniquement;
    - problemes de supports uniquement;
    - cas mixtes connexion + supports;
    - cas OK.
  - evite ainsi un faux message `connexion a surveiller` quand le seul probleme detecte concerne un ou plusieurs supports multimedia.
  - pendant le scan de l'etape 2, la ligne en cours n'affiche plus titre/artiste/question/reponse:
    - elle montre maintenant `Verification du support n° X` puis `On verifie ce lien...`;
    - le detail complet reste conserve dans le bloc de remplacement/correction apres scan.
- `../games/web/organizer_canvas.php`
  - le libelle visible du bouton organizer passe maintenant de `Test` a `Verif`.
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - le tooltip runtime du bouton organizer est maintenant fixe a `Verifier la configuration avant lancement`, sans reprendre le statut runtime dans le titre.
- `../games/web/includes/canvas/core/canvas_display.js`
  - remonte les bandeaux partages au-dessus de la footerbar organizer via un offset calcule sur la vraie hauteur de `.organisateur-menu`;
  - supprime la dependance a `jingleReady` pour le tout premier lancement en etat `En attente`, afin d'eviter un bouton `Lancer` bloque alors que le jingle n'est prime qu'au clic;
  - rerend explicitement les controles footerbar sur les evenements `prelaunch/*`, pour sortir proprement d'un etat `running` du pre-check auto;
  - desactive `Lancer` tant que le pre-check auto ou le test manuel tournent, puis uniquement si le statut final est rouge;
  - masque `Test` dans tous les etats hors `En attente`;
  - aligne aussi le tooltip bloquant de `Lancer` sur le nouveau wording prelaunch.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - annule explicitement le test en cours des la demande de lancement (`ui` / `remote`) pour eviter toute concurrence scan/lancement.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - ne garde que le style modal prelaunch; le layout de bandeau dedie est retire.

### Effet attendu
- en arrivant sur organizer, la pastille `Test` reflète deja l'etat minimal du poste;
- un cas OK laisse `Lancer` actif sans bandeau;
- un cas a surveiller affiche le bandeau orange mais laisse `Lancer` actif;
- un cas incompatible affiche le bandeau rouge et desactive `Lancer`;
- le clic sur `Test` reste la porte d'entree vers le diagnostic complet.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js /tmp/canvas_display.mjs && node --check /tmp/canvas_display.mjs`
- `npm run docs:sitemap`

## PATCH 2026-04-23 — Organizer: test pre-lancement V1 UX auto + synthese

### Objectif
- ajouter dans `games` uniquement un test pre-lancement compact, manuel et session-bound;
- aider l'organisateur a detecter les causes de lancement rate avant de cliquer `Lancer`;
- rester centre organizer sans pre-scan `pro` ni refonte large.
- simplifier l'UX en un enchainement automatique technique puis supports multimedia, suivi d'une synthese persistante;
- supprimer le bandeau global de statut dans la modale, au profit d'un statut par etape.

### Correctif livre
- `../games/web/organizer_canvas.php`
  - ajoute l'alias import map `@canvas/core/prelaunch_check`;
  - ajoute le CTA `bi-shield-check` dans la footerbar, a cote du bouton de lancement;
  - le bouton expose un etat visuel neutre / vert / orange / rouge / running.
- `../games/web/includes/canvas/core/prelaunch_check.js`
  - nouveau module V1 de diagnostic organizer;
  - rendu en deux vues lisibles:
    - bloc de test automatique: `Etape 1 — Verifications techniques`, puis `Etape 2 — Verification des supports multimedia`;
    - synthese courte avec recommandations actionnables, remplacements de liens et controle du son, sans intro redondante avec le titre de modale;
  - checks automatiques: boot, stockage local, contexte session, bridge `session_meta_get`, WS ouverte, stabilite courte, lien joueur / QR;
  - l'etape 1 affiche uniquement le controle courant pendant l'analyse, avec statut `en cours` puis vert/orange/rouge, puis une synthese en fin d'etape;
  - preflight de fluidite minimale: l'etape 1 mesure les signaux observables cote organizer (latence bridge, delai d'ouverture WS, stabilite courte, profil `navigator.connection` si disponible, disponibilite/latence YouTube si des supports YouTube sont detectes) et remonte une vigilance si l'environnement semble fragile;
  - si l'etape 1 detecte une connexion indisponible ou une WebSocket KO/instable, le flux s'arrete avant le scan des supports multimedia;
  - le profil navigateur `navigator.onLine === false` est affiche comme `Connexion Internet indisponible`, avec une recommandation dediee de reconnexion; `downlink` reste un signal de qualite reseau, pas un critere offline;
  - les messages utilisateur du controle bridge sont reformules sans jargon (`Communication avec l’application`, delai inhabituel, application indisponible) et ne parlent plus de `Bridge` ou de `connexion Cotton`;
  - si l'etape 1 detecte seulement un profil reseau marque lent selon les memes seuils que le player principal (`saveData`, `slow-2g`/`2g`/`3g`, downlink audio/video insuffisant, RTT eleve) ou une latence applicative mesuree > 2500 ms, le flux affiche une vigilance forte, ne lance pas le scan media et laisse l'organizer ameliorer le reseau ou accepter le risque au lancement;
  - le scan des supports reels depuis `GameStore.playlist.songs` s'enchaine automatiquement apres les verifications techniques, avec affichage du support courant pendant l'analyse;
  - le jingle commun `isJingle` est exclu du scan media, puis reutilise comme temoin pour le controle du son en synthese quand il est disponible;
  - a la fin des etapes automatiques, la modale bascule sur une synthese plus legere, qui devient aussi l'affichage par defaut lors d'une reouverture apres test;
  - la synthese ne presente plus un verdict technique brutal: elle distingue absence de blocage, points a surveiller et risque de lancement perturbe;
  - les supports multimedia problematiques ne font plus basculer la synthese en rouge: ils restent en vigilance, avec remplacement optionnel;
  - lecture read-only des diagnostics catalogue YouTube via `youtube_catalog_diagnostics_get` avant le test iframe/local;
  - cette lecture consomme les resultats deja persistés par `pro` dans `content_links_check_results`, sans appel YouTube Data API depuis `games` et sans controle de fraicheur en V1.1;
  - diagnostic YouTube via API iframe et diagnostic media direct via chargement metadata;
  - le timeout de probe YouTube du prelaunch est aligne sur la fenetre haute du player principal (15 s, 20 s en profil lent) et un timeout est classe `A valider manuellement`, pas comme lien inactif;
  - classification prudente: `OK`, `Suspect`, `Casse`, `Bloque par l'environnement`, `A valider manuellement`.
  - remplacements temporaires session-only pour les supports problematiques:
    - raccourci de recherche `YT Music` pour les titres musicaux;
    - affichage de la bonne reponse sous la question pour les supports video quiz, y compris sur une synthese deja stockee, et utilisation de cette bonne reponse comme requete `YouTube` prioritaire quand elle est disponible;
    - saisie d'un lien temporaire;
    - test du lien dans l'environnement organizer;
    - application a `GameStore.playlist.songs` si le test est OK;
    - normalisation du lien temporaire avant injection runtime: les liens YouTube/Music/shorts/embed sont convertis en URL `youtube.com/watch?v=...` exploitable par le player, avec conservation des bornes `t/start` et `end` quand elles existent;
    - application d'un lien temporaire sans relancer tout le test: la ligne support et la synthese sont mises a jour directement a partir du test deja valide;
    - restauration du lien d'origine sans relance automatique, avec invitation a relancer le test si l'organizer veut reverifier;
    - stockage limite a `sessionStorage`, sans write bridge ni modification base;
    - action de retour au lien d'origine.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - initialise le module apres attache UI;
  - enrichit la confirmation `Lancer la session maintenant ?` avec le dernier etat du test.
- `../games/web/includes/canvas/css/canvas_styles.css`
  - styles du CTA footerbar, etat visuel, modale de diagnostic, cartes d'etapes, ligne courante avec statut individuel, liens de recherche, rappel de lancement.
- `../games/web/includes/canvas/core/logger.global.js`
  - ajoute les evenements `PRELAUNCH_START`, `PRELAUNCH_CHECK`, `PRELAUNCH_COMPLETE`;
  - ajoute les evenements de remediation `PRELAUNCH_REPLACEMENT_TEST`, `PRELAUNCH_REPLACEMENT_APPLY`, `PRELAUNCH_REPLACEMENT_RESET`.

### Effet attendu
- l'organisateur peut lancer et relancer un diagnostic court juste avant lancement;
- a l'ouverture d'un nouveau test, seul le bloc de progression automatique est visible;
- aucun bandeau global de statut n'est affiche en haut de la modale;
- si la technique est OK, la synthese garde seulement une mention discrete;
- si la technique est exploitable mais fragile, l'UI propose des ameliorations possibles sans bloquer abusivement;
- si la technique echoue, l'UI explique simplement pourquoi le lancement peut etre perturbe et liste les points a corriger;
- si la connexion Internet est indisponible ou que la WebSocket est KO/instable, la synthese indique que l'app Cotton a besoin d'une connexion stable et suffisante, masque la verification des supports et propose uniquement `Relancer le test`;
- si le profil reseau est lent mais encore exploitable, ou si l'appel applicatif preflight mesure une latence > 2500 ms, la synthese indique que le jeu peut fonctionner avec des supports moins fluides ou ignores; elle ne propose plus de scan exhaustif dans cet environnement pour eviter les faux diagnostics;
- si le bridge ou la WebSocket sont seulement lents mais encore fonctionnels, le test reste en vigilance et peut continuer vers le scan media.
- l'etape media demarre automatiquement apres l'etape technique et affiche seulement le support courant pendant la verification;
- la synthese affiche seulement les blocs utiles: recommandations techniques si necessaire, supports problematiques avec remplacement temporaire, puis controle du son;
- les blocs `Configuration technique`, `Supports multimedia` et `Controle du son` sont espaces pour ameliorer la lecture;
- le bloc supports adapte son wording au jeu: questions perturbees pour `Quiz`, morceaux perturbes pour `Blind Test` / `Bingo Musical`;
- le controle du son est integre a la synthese sous forme d'action simple `Lancer le jingle temoin`, sans confirmation utilisateur ni statut artificiel `Son OK / non valide`; le jingle temoin n'est plus coupe volontairement avant sa fin naturelle;
- dans le bloc de remplacement, les liens `YT Music` / `YouTube` sont affiches sous `Lien temporaire de remplacement`; la mention session-only redondante est retiree.
- pour `Quiz`, la recherche `YouTube` de remplacement part de la bonne reponse quand elle existe, avec la question uniquement en secours.
- apres un test deja effectue, rouvrir la modale affiche directement cette synthese, avec possibilite de corriger les liens ou de relancer le test;
- l'etat reste visible dans la footerbar et reapparait dans la confirmation de lancement;
- `Blind Test` et `Bingo Musical` remontent les problemes audio comme critiques;
- `Quiz` ne demande pas de validation audio/video si la session ne contient pas de support media;
- les supports YouTube/media sont diagnostiques sur l'environnement reel sans promesse de garantie absolue.
- un timeout YouTube pendant le scan signale un environnement trop lent pour conclure, sans marquer le lien comme inactif;
- si le scan `pro` a deja marque un support YouTube comme indisponible/non public/non integrable/age-gate/live/bloque FR, l'etape media le remonte immediatement avant meme le test iframe organizer.
- les liens temporaires corrigent uniquement le runtime de la session en cours et ne remplacent pas une correction durable admin/base.

### TODO suite
- adapter le cron journalier pour alimenter regulierement `content_links_check_results`;
- prevoir un flux admin de signalement/correction durable pour les liens source problematiques detectes par le test pre-lancement.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js /tmp/boot_organizer.mjs && node --check /tmp/boot_organizer.mjs`
- `npm run docs:sitemap`

## PATCH 2026-04-17 — Bingo demo reset: purge winners + cleanup player local state

### Objectif
- corriger le cas ou une session demo `Bingo Musical` etait relancee avec un reset DB incomplet du point de vue metier et un etat joueur encore sale cote navigateur;
- eviter qu'un restart demo conserve des gagnants de phase precedents ou que le player reinjecte ses anciennes coches/locks apres `demo_reset`.

### Correctif livre
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - `_bingo_reset_demo_state(...)` supprime maintenant aussi les lignes `bingo_phase_winners` de la session pendant `resetdemo`;
  - le reste du contrat demo est conserve: joueurs et assignations de grilles restent en place, seules les traces de partie sont remises a zero.
- `../games/web/includes/canvas/play/play-ws.js`
  - a la reception de `demo_reset`, le player Bingo bascule maintenant tout de suite son UI sur `En attente`, remet `mainStarted` a `false`, reset la grille, puis purge `bingo_checked`, `bingo_locked` et `bingo_best_phase` avant le reload.

### Effet attendu
- une demo Bingo relancee repart sans anciens gagnants de phase dans le preload organizer/remote;
- le player ne reapplique plus ses anciennes coches/locks locales apres le reset demo;
- `reset` (flux de start) reste inchange.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `node --check /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`
  - non exploitable tel quel ici: fichier ESM navigateur avec imports `@canvas/*`.

## PATCH 2026-04-17 — Remote podium: upload distinct par gagnant en cas d'ex aequo

### Objectif
- aligner la remote `games` sur le comportement deja livre cote `pro` pour les photos podium;
- eviter qu'un upload fait sur un rang partage (`#1 / #1`, etc.) ecrase ou reutilise implicitement la photo du premier gagnant trouve;
- permettre un bouton photo par gagnant reel, meme quand plusieurs participants partagent la meme place.

### Correctif livre
- `../games/web/includes/canvas/php/boot_lib.php`
  - `session_meta_get` remonte maintenant toutes les lignes de podium `1..3`, meme quand une ligne n'a pas encore de photo;
  - chaque ligne conserve `photo_row_key`, `label`, `score`, `phase_label`, `photo_src`.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - le preload `serverSessionMeta.podium_photos` suit maintenant la meme regle: toutes les lignes podium sont exposees, pas seulement celles qui ont deja une image.
- `../games/web/includes/canvas/remote/remote-ui.js`
  - le rendu de fin de partie ne raisonne plus uniquement `par rang`;
  - chaque ligne visible du podium essaie maintenant de matcher sa propre row meta via `photo_row_key`, puis via `rang + libelle + phase/score`;
  - le CTA photo transporte desormais `rank + photo_row_key`, donc l'upload peut cibler le bon gagnant sur un rang partage;
  - un refresh `session_meta_get` est aussi force a la reception de `remote/end` pour hydrater rapidement les row keys sur une remote deja ouverte.

### Effet attendu
- si deux gagnants sont ex aequo sur une meme marche du podium, chacun peut recevoir sa propre photo depuis la remote;
- une photo deja presente reste rattachee au bon gagnant au rerender, au lieu d'etre dupliquee par simple rang.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `node --check /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js` non exploitable tel quel dans la sandbox:
  - fichier ESM navigateur;
  - imports `@canvas/*` non resolus hors runtime web.

## PATCH 2026-04-16 — Quit joueur runtime: purge LS scallee sur la session

### Objectif
- corriger le cas ou un joueur runtime quitte volontairement la session puis revient sur la page;
- eviter qu'une identite locale session-scope survive au quit et fasse croire au portail player qu'un joueur est deja encore inscrit.

### Correctif livre
- `../games/web/includes/canvas/play/play-ui.js`
  - le quit volontaire purge maintenant aussi l'identite runtime scallee sur la session via `clearPlayerIdentityForSession({ game, sid })`;
  - supprime en plus les residus legacy et session-scope qui pouvaient survivre au quit:
    - `${slug}:player_db_id`
    - `player-registered_${sessionId}`
    - pour `bingo`, `${slug}:grid_id:${sessionId}` et `${slug}:grid_number:${sessionId}`

### Effet attendu
- apres un quit volontaire, un retour sur la page retombe bien sur le formulaire d'inscription;
- un joueur runtime peut se reinscrire avec un nouveau pseudo au lieu d'etre bloque par une identite LS fantome.

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`

## PATCH 2026-04-16 — Redirections de sortie `master`/`play`

### Objectif
- renvoyer les demos `master` vers leur vrai point d'entree `pro` au lieu d'une regle historique liee a un seul `id_client`;
- uniformiser la sortie `play` vers la home du site.

### Correctif livre
- `../games/web/includes/canvas/core/end_game.js`
  - detection demo basee sur `AppConfig.isDemoSession`;
  - memorisation d'un `return_url` explicite ou d'un referrer `pro` valide, scope par session;
  - reutilisation de cette origine au quit du `master`.
- `../games/web/organizer_canvas.php`
  - expose `isDemoSession` dans `AppConfig`.
- `../games/web/modules/app_play_ajax.php`
  - remplace l'ancienne cible catalogue par la home `www` pour `URLPROMO`.

### Cote `pro` branche sur ce patch
- `../pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- `../pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `../pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
- `../pro/web/ec/modules/tunnel/start/ec_start_script.php`
- `../pro/web/ec/modules/compte/client/ec_client_script.php`
  - propagent `return_url` sur les ouvertures demo `games/master`.

## PATCH 2026-04-16 — Remote fin de partie: upload podium direct + CTA `pro` retire

### Objectif
- supprimer la dependance au contexte `pro` mobile pour l'ajout des photos gagnants depuis la remote;
- permettre un upload direct dans `games`, tout en gardant `master` et la fiche detail `pro` synchronises sur la meme source de verite;
- simplifier aussi l'UX du podium remote en fin de partie avec un rendu `3` lignes + CTA photo explicite en fin de ligne.

### Correctif livre
- `../games/web/includes/canvas/php/boot_lib.php`
  - ajoute l'action bridge `session_podium_photo_upload`;
  - appelle `app_session_results_podium_photo_upload(...)` puis renvoie un `session_meta_get` frais pour rerender immediat.
- `../games/web/includes/canvas/remote/remote-ui.js`
  - ajoute `remoteApiFormData(...)` pour les appels multipart du bridge canvas;
  - remplace le CTA unique vers `pro` par un bouton photo par ligne de podium;
  - affiche une vignette photo devant les infos de ligne quand une photo podium existe deja pour ce rang;
  - corrige la lecture de `session_meta_get` apres upload: la remote lit maintenant `session.podium_photos` quand la reponse bridge est imbriquee, au lieu d'attendre uniquement `podium_photos` en top-level;
  - reproduit le choix mobile `Caméra / Photos` avant ouverture du picker natif sur `Ajouter une photo` comme sur `Modifier la photo`;
  - ajoute un `session_meta_get` immediat au boot puis un polling `5s` seulement en `Partie terminee`, pour ne plus figer les photos podium sur la remote;
  - declenche l'upload direct depuis la remote puis rerend le podium avec les `podium_photos` retournees.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - enrichissent le `serverSessionMeta` de preload avec `podium_photos` issues du helper global de resultats;
  - but: hydrater la remote avec les miniatures podium existantes des le boot, sans attendre un appel `session_meta_get`.
- `../games/web/includes/canvas/php/boot_lib.php`
  - charge desormais `global_librairies.php` aussi pendant les boots canvas standard;
  - but: rendre effectivement disponibles dans les `glue` les helpers globaux de resultats utilises pour `podium_photos`, pas seulement sur la voie `games_ajax.php`.
- `../games/web/remote_canvas.php`
  - retire l'ancien export `sessionDetailUrl` devenu inutile cote remote.
- `../games/web/includes/canvas/css/remote_styles.css`
  - passe le podium termine de `3` colonnes a `3` lignes;
  - aligne le contenu a gauche et le CTA photo a droite, avec fallback mobile pleine largeur.

### Effet attendu
- la remote reste autonome pour l'ajout des photos gagnants;
- un upload reussi met immediatement a jour le podium remote;
- le `master games` et la fiche detail `pro` relisent ensuite la meme photo via leur lecture standard des resultats.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/remote_canvas.php`

## PATCH 2026-04-16 — Remote papier: garde `maxPlayers` avant write path d'inscription

### Objectif
- empecher qu'un ajout joueur papier parte jusqu'au `write path` `player_register` quand la session a deja atteint sa capacite max;
- corriger l'UX actuelle ou la modale d'ajout se ferme puis ne laisse qu'un toast d'erreur, ce qui ressemble a une fermeture anormale de la remote.

### Correctif livre
- `../games/web/includes/canvas/remote/remote-ui.js`
  - ajoute des helpers locaux de capacite bases sur `SESSION_PAPER`, `window.ServerSessionMeta.maxPlayers` et le snapshot joueurs courant;
  - deplace le garde principal dans `promptParticipantSelection().preConfirm` pour que SweetAlert affiche une validation inline et reste ouverte si la session est pleine;
  - ajoute une seconde garde defensive juste avant `remoteApi('player_register', ...)` pour couvrir les courses entre deux ajouts;
  - preserve le cas d'un participant deja actif, qui ne doit pas etre faussement bloque par ce garde front.

### Effet attendu
- sur session papier pleine, l'animateur reste dans la modale `Ajouter un joueur/equipe` avec un message clair au lieu de voir la modale disparaitre;
- aucun nouvel appel `player_register` ne doit partir depuis la remote pour ce cas simple de capacite deja atteinte;
- le patch reste borne a la remote papier et ne modifie ni le contrat backend ni les autres parcours d'inscription.

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js`

## PATCH 2026-04-11 — Remote: CTA `Ajouter les photos des gagnants !` compact, responsive et aligne branding

### Objectif
- reduire la hauteur du CTA de fin de partie cote remote;
- s'assurer qu'il ne force pas un debordement horizontal sur mobile;
- utiliser la vraie couleur de texte branding de la remote au lieu d'un noir hardcode.

### Correctif livre
- `../games/web/includes/canvas/css/remote_styles.css`
  - reduction de la hauteur utile et du padding du bouton;
  - largeur bornee avec `max-width:100%` et `min-width:0`;
  - wrapping autorise pour le contenu afin d'eviter toute largeur de page forcee sur petit ecran;
  - texte aligne sur `var(--primary-font)` au lieu de `#111`.

### Effet attendu
- le bouton reste lisible mais plus compact sous le podium remote;
- sur mobile, il ne doit plus elargir la page ni provoquer de scroll horizontal parasite;
- le texte suit maintenant la couleur principale de texte issue du branding applique a la remote.

## PATCH 2026-04-11 — Podium organizer: les ex aequo n'ecrasent plus leurs photos

### Objectif
- corriger le rendu `master`/organizer qui continuait a n'afficher qu'une seule photo pour plusieurs gagnants partageant le meme rang;
- conserver la compatibilite avec les anciennes photos stockees seulement par rang.

### Correctif livre
- `../games/web/includes/canvas/php/boot_lib.php`
  - `session_meta_get` enrichit `podium_photos` avec:
    - `photo_row_key`
    - `label`
    - `score`
    - `phase_label`
  - but: donner au front organizer assez de contexte pour distinguer deux lignes `#1`.
- `../games/web/includes/canvas/core/canvas_display.js`
  - le podium organizer ne convertit plus les photos en simple `Map(rank -> src)`;
  - il conserve maintenant une liste de photos par rang et attribue une photo par carte via matching:
    - cle de ligne si disponible;
    - sinon `rang + nom + phase`;
    - sinon `rang + nom + score`;
    - sinon premier media encore libre sur ce rang.
  - le fallback reste donc compatible avec les medias historiques uniquement attaches au rang.

### Effet attendu
- sur `master`, deux gagnants ex aequo peuvent maintenant afficher deux photos differentes, comme sur la fiche detail `pro`;
- si une seule photo legacy existe encore pour un rang, elle reste affichee sur la premiere carte correspondante sans casser le podium.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `node --check /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js` non exploitable tel quel dans la sandbox:
  - fichier ESM navigateur;
  - imports `@canvas/*` non resolus hors import map du runtime web.

## PATCH 2026-04-10 — Remote papier: reseed identite canonique apres ajout participant EP

### Objectif
- garder un patch strictement borne a l'ajout remote d'un participant issu d'un lookup DB (`EP/existant`);
- faire en sorte qu'apres cet ajout, la remote manipule immediatement la meme identite runtime canonique que les parcours joueur classiques, sans ajouter de correctifs disperses sur chaque action admin.
- corriger la regression Bingo apparue sur `develop/fix_joueursEP` quand `player_register` relance une re-resolution serveur via `ep_connect_token`.

### Correctif livre
- `../games/web/includes/canvas/remote/remote-ui.js`
  - ajout de `seedRemoteRegisteredParticipant(...)`;
  - apres `player_register`, si l'ajout vient d'un lookup DB (`sourceTable/sourceId`), la remote reinjecte aussitot dans son store local un joueur normalise avec:
    - `player_id` canonique;
    - `playerDbId` / `playerId` numerique si la reponse backend le fournit;
    - `playerName`, `score`, `playerScore` alignes sur le contrat runtime.
  - le snapshot `players_get` reste ensuite la source de confirmation autoritaire; ce reseed ne remplace pas le refresh standard, il bouche la fenetre ou l'UI admin pouvait encore raisonner sur une identite partielle.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - `player_register` ne repose plus sur un `ON DUPLICATE KEY` implicite pour reutiliser une identite existante;
  - la ligne runtime la plus recente pour `session + player_id` est maintenant relue explicitement, reactivee, et les doublons residuels de meme identite sont passes inactifs.
  - l'API remonte maintenant `registration_state = created|reactivated|already_active`.
  - quand `ep_connect_token` est present, ces adapters rederivent maintenant `sourceTable/sourceId` depuis `ep_link_resolve` cote serveur avant de calculer la cle runtime canonique.
- suivi Bingo-only:
  - la divergence `main` vs `develop` a ete confirmee dans `bingo_api_player_register()`:
    - `main` reutilise uniquement le payload front deja resolu;
    - `develop/fix_joueursEP` ajoute une re-resolution serveur `canvas_api_ep_link_resolve(...)` avant le recalcul du `player_id`.
  - `Bingo Musical` n'accepte maintenant comme source canonique exploitable que `participantType=player` / `sourceTable=equipes_joueurs`:
    - un resultat serveur `team/equipes` est journalise comme `EP_RESOLVE_UNUSABLE` puis ignore;
    - le code retombe alors sur le payload front deja fourni si celui-ci reste exploitable.
  - l'appel a `canvas_api_ep_link_resolve(...)` est maintenant protege par `try/catch(Throwable)` pour empecher toute remontee en `500` brut depuis ce bloc;
  - si la source finale n'est pas exploitable pour Bingo, le backend purge le mapping unsupported (`equipes`) et poursuit avec le chemin runtime existant au lieu de fabriquer une identite canonique d'equipe incompatible avec `bingo_players` / `id_joueur` / les grilles.
- suivi bridge EP apres preuve front:
  - les logs joueur ont montre que `player_register` reussissait bien puis que l'echec se deplacait sur `ep_link_finalize`;
  - cause racine: `bingo_api_player_register()` appelle deja `canvas_ep_account_bridge_link_runtime_participant(...)`, donc `ep_link_finalize` pouvait repasser dans la meme seconde avec exactement les memes valeurs et lire `rowCount() === 0` comme un faux `TOKEN_INVALID`;
  - `canvas_api_ep_link_finalize()` relit maintenant d'abord la row bridge par `return_token`, puis traite ce cas comme un succes idempotent `already_linked` au lieu d'un echec;
  - `games_ajax.php` ne remonte plus `TOKEN_INVALID` / `SESSION_MISMATCH` / `GAME_MISMATCH` / `USERNAME_MISSING` en HTTP `500`: ces erreurs bridge sont maintenant mappees en `400`.
- suivi WS Bingo apres comparaison `main` vs `fix_joueursEP`:
  - aucune divergence n'a ete trouvee dans `play-ws.js` ni dans `bingo.game/ws/**` pour le boot/auth WS Bingo numerique;
  - la divergence bloquante est dans `register.js`, juste avant l'entree WS:
    - sur `fix_joueursEP`, l'emission `Bus.emit('player/ready', ...)` utilise `gridId: paperMode ? null : ...`;
    - `paperMode` n'existe pas dans ce scope;
    - le `ReferenceError` est absorbe par le `try/catch`, donc `player/ready` n'est jamais emis, ce qui empeche tout boot/auth WS Bingo apres `player_register_ok`.
  - correctif: retour a `isPaperMode()` comme en `main` pour que l'emission `player/ready` Bingo numerique reparte bien vers `play-ws.js`.
- `../games/web/includes/canvas/play/register.js`
  - le portail player traite `already_active` comme un succes idempotent;
  - ce cas n'est plus marque comme `freshRegistration`.
- `../games/web/includes/canvas/play/player_identity.js`
  - l'identite canonique renvoyee par `player_register` ecrase maintenant l'identite session precedente, meme si un `player_id` local deja canonique etait present;
  - but: eviter qu'un `player_id` genere localement survive apres un retour `EP -> games` et recree ensuite un doublon purement WS/UI pour le meme `player_db_id`.
- `../games/web/includes/canvas/play/play-ws.js`
  - `player/paper:listen` devient reellement passif pour `quiz` / `blindtest`;
  - le boot WS papier n'appelle plus `authenticatePlayer()` apres ouverture sur ces jeux.
- `../games/web/includes/canvas/play/register.js`
  - les succes d'inscription papier `quiz` / `blindtest` emettent maintenant `player/paper:listen` au lieu de `player/ready`;
  - `ensurePaperWsListening()` s'aligne sur ce meme chemin passif.
- `../games/web/includes/canvas/remote/remote-ui.js`
  - la remote affiche maintenant `deja inscrit` pour un participant lookup deja actif dans la session, avec wording joueur/equipe adapte;
  - elle n'envoie plus `admin_player_register` si le backend a simplement confirme une inscription deja active.

### Effet attendu
- juste apres un ajout remote d'un participant EP/existant, les actions admin suivantes repartent deja d'une identite runtime compatible avec les WS;
- le perimetre reste volontairement limite aux sessions papier et aux participants ajoutes par lookup remote.
- la reinscription du meme participant EP, que l'entree se fasse par la remote ou par `EP -> games`, doit reutiliser la meme row runtime.
- l'UX distingue maintenant correctement `ajoute/reactive` de `deja inscrit`.
- les clients player n'ont plus le droit de conserver un `player_id` canonique local divergent apres confirmation serveur; le `player_id` serveur devient la reference unique pour les prochains `registerPlayer` WS.
- en papier `quiz` / `blindtest`, un joueur deja present en runtime ne doit plus se re-enregistrer en WS juste pour ecouter la session.
- en `bingo`, une re-resolution serveur EP qui ne remonte pas un `id_joueur` exploitable ne casse plus `player_register`:
  - pas de `500` brut;
  - pas de mapping force vers `team/equipes`;
  - fallback propre sur le payload front si disponible.

### Verification
- revue diff locale `games/web/includes/canvas/remote/remote-ui.js`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- validation syntaxique ESM navigateur non concluante dans la sandbox via Node brut (`import` front non resolu hors import map navigateur)
- controle complementaire Bingo-only:
  - relecture comparee `main` vs `fix_joueursEP` sur `bingo_api_player_register()`;
  - validation syntaxique PHP apres ajout du fallback defensif Bingo.
- controle complementaire bridge EP:
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/ep_account_bridge.php`
  - `php -l /home/romain/Cotton/games/web/games_ajax.php`
- controle complementaire WS Bingo:
  - comparaison locale `main...fix_joueursEP` sur `web/includes/canvas/play/register.js`, `play-ws.js`, `player_identity.js`;
  - verification locale de la ligne d'emission `player/ready` Bingo.

## PATCH 2026-04-17 — Player mobile: upload photo vainqueur avec consentement obligatoire

### Objectif
- permettre a un joueur podium d'ajouter sa photo directement depuis `player_canvas` en fin de session, sans passer par la remote;
- reutiliser le write path podium existant cote `games/global` au lieu de dupliquer un second pipeline upload;
- n'ouvrir ce flux qu'aux participants reellement eligibles et l'assortir d'un consentement explicite trace.

### Audit confirme
- rendu fin de session player:
  - `../games/web/player_canvas.php`
  - `../games/web/includes/canvas/play/play-ui.js`
  - `../games/web/includes/canvas/css/player_styles.css`
- flux upload podium deja en place cote remote:
  - `../games/web/includes/canvas/remote/remote-ui.js`
  - `../games/web/includes/canvas/php/boot_lib.php`
  - `../global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- liaison runtime -> espace joueur:
  - `../games/web/includes/canvas/play/register.js`
  - `../games/web/includes/canvas/php/ep_account_bridge.php`
  - `../games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `../games/web/includes/canvas/php/bingo_adapter_glue.php`
- stockage lien player account:
  - `championnats_sessions_participations_games_connectees`
- aucun mecanisme partage deja present pour un consentement upload-specifique avec horodatage:
  - les champs `rgpd_consentement_*` existants portent sur le compte joueur, pas sur une photo podium donnee.

### Correctif livre
- `../games/web/player_canvas.php`
  - ajoute une carte mobile `Ajouter une photo` dans l'ecran `Partie terminee`, cachee par defaut;
  - la carte contient:
    - miniature existante si presente;
    - choix `Camera / Photos`;
    - case de consentement obligatoire avant validation.
- `../games/web/includes/canvas/play/play-ui.js`
  - relit maintenant l'eligibilite via `player_podium_photo_access_get` a l'entree en etat `Partie terminee`;
  - n'affiche le CTA que si le joueur:
    - appartient au podium final;
    - est lie a un espace joueur via le bridge EP/runtime;
    - joue une session archivee/terminee compatible.
  - poste ensuite le fichier et le consentement vers `player_podium_photo_upload`.
- `../games/web/includes/canvas/css/player_styles.css`
  - habillage mobile-first du bloc upload photo de fin de session.
- `../games/web/includes/canvas/php/boot_lib.php`
  - ajoute:
    - `canvas_api_player_podium_photo_access_get(...)`
    - `canvas_api_player_podium_photo_upload(...)`
  - revalide cote serveur:
    - session archivee;
    - joueur concerne;
    - podium only;
    - liaison espace joueur presente;
    - consentement fourni.
- `../games/web/games_ajax.php`
- `../games/web/includes/canvas/core/api/api_client.js`
  - declarent `player_podium_photo_upload` comme action bridge mutante.
- `../games/web/includes/canvas/php/ep_account_bridge.php`
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - propage maintenant `ep_connect_token` lors de l'inscription runtime pour fiabiliser la presence de `id_joueur` / `id_equipe` dans le bridge.

### Stockage consentement retenu
- `../games/web/includes/canvas/sql/2026-04-17_player_podium_photo_consent.sql`
  - nouvelle table `championnats_sessions_podium_photos_consents`.
- `../games/web/includes/canvas/sql/2026-04-17_player_podium_photo_consent_runtime_snapshot.sql`
  - ajoute `runtime_username` et `runtime_label` dans la preuve d'upload.
- `../global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - l'upload podium partage accepte maintenant un bloc `consent`;
  - en succes upload:
    - la photo est d'abord ecrite comme avant dans `medias_images`;
    - puis une preuve de consentement par upload est inseree avec:
      - `session/game/rank/photo_row_key/media_image_id`
      - ids runtime et bridge (`game_player_id`, `game_player_key`, `id_joueur`, `id_equipe`, `bridge_id`)
      - snapshot runtime (`runtime_username`, `runtime_label`)
      - texte, contexte, source, timestamp, IP, user-agent.
  - si la preuve consentement echoue, le media fraichement cree est supprime pour eviter une photo orpheline sans preuve.

### Addendum 2026-04-17 — Podium player sans lien EP
- le flux player n'exige plus de liaison a l'espace joueur pour l'eligibilite;
- la garde serveur reste:
  - session archivee;
  - joueur courant;
  - podium uniquement;
  - consentement obligatoire.
- motivation:
  - ouvrir l'upload aux podiums runtime sans compte EP;
  - conserver malgre tout une piste de suppression exploitable via le snapshot du pseudo/libelle runtime stocke avec la photo.
- addendum UX 2026-04-17:
  - quand une photo est selectionnee mais pas encore envoyee, le joueur peut maintenant supprimer ce draft local via un petit bouton de reset;
  - effet attendu:
    - retour a l'etape precedente;
    - reaffichage du CTA `Ajouter une photo`;
    - consentement et message d'etat remis a zero avant une nouvelle selection.
  - addendum UX player:
    - le draft local affiche maintenant aussi une preview de l'image choisie avant l'envoi, comme sur la remote;
    - si le nom de fichier est long, la ligne fichier casse proprement en mobile au lieu de faire deborder la card;
    - quand une photo organisateur verrouille la ligne podium, le texte `Partage une photo paysage...` est masque et seule la note `Photo ajoutée par l'organisateur.` reste visible.

### Addendum 2026-04-17 — Remote podium: consentement organisateur + priorite orga
- `../games/web/includes/canvas/remote/remote-ui.js`
- `../games/web/includes/canvas/css/remote_styles.css`
- `../games/web/includes/canvas/php/boot_lib.php`
  - la remote ajoute maintenant une etape draft locale apres choix du fichier:
    - preview de l'image;
    - suppression du draft pour revenir au CTA precedent;
    - consentement organisateur obligatoire avant upload final.
- regle metier:
  - une photo organisateur visible sur une ligne podium prime sur une photo joueur;
  - le helper player masque donc le bloc d'upload si la photo visible provient d'un organisateur.
- addendum synchro player:
  - `../games/web/includes/canvas/play/play-ui.js`
  - `../games/web/includes/canvas/php/boot_lib.php`
    - l'ecran de fin joueur ne se contente plus d'un fetch one-shot de `player_podium_photo_access_get`;
    - un refresh leger tourne maintenant toutes les `10s` uniquement en `Partie terminee`, avec refresh immediat aussi au retour de focus/onglet visible;
    - si une photo organisateur apparait pendant qu'un draft joueur local existe encore, le draft local est nettoye et la carte bascule sur l'etat verrouille + preview organisateur.
    - addendum perf:
      - le bridge player renvoie maintenant aussi une `photo_signature`;
      - le polling player ne rerend plus la carte si cette signature n'a pas change.

### Verification
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/ep_account_bridge.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/games_ajax.php`
- `node --check` non conclusif dans cette sandbox pour `play-ui.js`:
  - fichier ESM navigateur avec imports/resolution front hors contexte Node brut.

## PATCH 2026-04-09 — Session detail redirect + podium photos live after end

### Objectif
- renvoyer l'organisateur vers la fiche detail session `pro` quand il ouvre/quitte une session `games`, afin de pousser l'upload des photos gagnants;
- faire remonter les photos podium ajoutees apres la fin directement sur le podium organizer sans rouvrir la session.

### Correctif livre
- `../games/web/organizer_canvas.php`
  - expose maintenant `AppConfig.sessionDetailUrl` vers `/extranet/start/game/view/<id_securite_session>` pour la sortie organizer.
- `../games/web/includes/canvas/php/ep_account_bridge.php`
  - les inserts `games_remote_lookup` generent maintenant un `return_token` technique unique au lieu d'une chaine vide, pour rester compatibles avec `uniq_return_token` sans impacter le parcours EP joueur direct.
- `../games/web/games_ajax.php`
  - charge maintenant `global_librairies.php` avant d'entrer dans le bridge canvas; les endpoints canvas avec `exit` precoce, notamment `session_meta_get`, voient donc enfin les helpers globaux de session/resultats.
- `../global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - la relecture des photos podium renvoie maintenant l'URL canonique du media meme si le fichier n'est pas visible via `file_exists(...)` sur le serveur `games`, afin d'eviter un faux negatif inter-serveurs sur le podium organizer.
- `../games/web/includes/canvas/core/end_game.js`
  - la sortie organizer redirige maintenant prioritairement vers `sessionDetailUrl` au lieu du simple dashboard `pro`.
- `../games/web/remote_canvas.php`
  - a cette date, ajout initial du CTA termine `Ajouter les photos des gagnants !` et correction de l'initialisation `CONF_SITE_ROOT` pour eviter le warning PHP sur les URLs absolues de branding.
- `../games/web/includes/canvas/remote/remote-ui.js`
  - a cette date, le quit volontaire en `Partie terminee` redirigeait aussi vers la fiche detail session;
  - ce comportement a ensuite ete retire au profit de l'upload direct remote (patch 2026-04-16).
- `../games/web/includes/canvas/php/boot_lib.php`
  - `session_meta_get` expose maintenant `podium_photos` et integre leur signature au polling organizer.
- `../games/web/includes/canvas/core/boot_organizer.js`
  - le polling organizer persiste `podium_photos` dans `window.ServerSessionMeta` et redemande un rerender podium quand elles changent.
- `../games/web/includes/canvas/core/canvas_display.js`
- `../games/web/includes/canvas/css/canvas_styles.css`
  - le podium organizer sait maintenant afficher une photo par rang (`#1/#2/#3`) avec cadrage dedie.

### Effet attendu
- fermer volontairement `master` en fin de session ramene l'organisateur sur la fiche session `pro`;
- si une photo gagnant est ajoutee depuis `pro` apres la fin, le podium organizer la recupere automatiquement via le polling deja en place.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/remote_canvas.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`

## PATCH 2026-04-07 — Refus de pseudo: cleanup cible + `playerDbId` strict sur bingo

### Objectif
- eviter qu'un refus metier d'inscription (`pseudo deja pris / reference`) laisse une identite locale provisoire incoherente;
- empecher aussi qu'un `playerDbId` global legacy d'une autre session soit reutilise par erreur sur un flux bingo courant.

### Correctif livre
- `../games/web/includes/canvas/play/register.js`
  - ajout de `clearRejectedRegistrationDraft(...)`;
  - purge executee uniquement sur refus metier `USERNAME_ALREADY_USED` / `USERNAME_REFERENCED`;
  - aucune purge sur erreur technique, pour ne pas casser une reprise legitime apres un succes serveur;
  - pour `bingo`, purge complementaire des artefacts locaux de grille.
- `../games/web/includes/canvas/play/player_identity.js`
  - ajout de `getPlayerDbIdStrict({ game, sid })`;
  - lecture bornee a la cle `player_db_id:<session>` sans fallback global.
- `../games/web/includes/canvas/play/play-ws.js`
- `../games/web/includes/canvas/play/play-ui.js`
  - les chemins bingo critiques (auth WS, hydrate/sync de grille, reprise) relisent maintenant uniquement le `playerDbId` strict de la session courante.

### Effet attendu
- un premier refus de pseudo n'empoisonne plus une inscription ulterieure avec une identite locale fantome;
- bingo ne peut plus recoller un `playerDbId` persiste depuis une autre session.

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/play/player_identity.js`

## PATCH 2026-04-03 — Inscriptions runtime / EP / remote: garde de nom + bridge EP

### Objectif
- prevenir les doublons de nom cote runtime sans casser les inscriptions EP legitimement rattachees a un compte;
- stabiliser aussi le bridge EP <-> runtime pour les retours `play` et les ajouts remote issus d'un lookup DB.

### Correctif livre
- `../games/web/includes/canvas/php/boot_lib.php`
  - ajout du helper de detection de nom deja reference chez l'organisateur.
- `../games/web/includes/canvas/php/ep_account_bridge.php`
  - ajout du helper de liaison runtime -> bridge EP pour les ajouts remote DB.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - refus runtime pur si le nom existe deja dans la session ou s'il est deja reference chez l'organisateur;
  - bypass conserve pour `ep_connect_token` et pour les ajouts remote issus d'un lookup DB;
  - messages utilisateur harmonises;
  - les inscriptions EP derivent maintenant une identite runtime stable a partir de la source metier;
  - les ajouts remote DB ecrivent / mettent a jour `championnats_sessions_participations_games_connectees`.
- `../games/web/includes/canvas/play/register.js`
  - envoi de `ep_connect_token` et du payload source EP (`participantType/sourceTable/sourceId`) sur `player_register`.
- `../games/web/includes/canvas/remote/remote-ui.js`
  - transmission de `sessionId`, `participantType`, `sourceTable`, `sourceId` pour l'ajout remote live.

### Effet attendu
- les doublons runtime sont refuses plus tot;
- une reinscription EP dans la meme session reutilise la meme identite runtime;
- un ajout remote DB laisse maintenant une trace bridge exploitable cote EP/classements.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/ep_account_bridge.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`

## PATCH 2026-04-02 — `ep_connect_token` ne doit pas etre bypass par une identite locale

### Objectif
- garantir qu'un retour `play -> games` avec `ep_connect_token` reste prioritaire sur une reprise locale de joueur deja stockee;
- eviter l'ecart de comportement entre onglet normal (avec localStorage) et onglet prive.

### Correctif livre
- `../games/web/includes/canvas/play/register.js`
  - les branches de reprise locale `bingo` et `quiz/blindtest` sont maintenant bornees par `!hasPendingEpConnectFlow()`;
  - ajout du stage debug `ep_autoreg_resume_bypass_local_identity` quand un reliquat local est ignore pour laisser le flux EP aller jusqu'au bout.

### Effet attendu
- un `ep_connect_token` pending ne peut plus etre masque par un `player_id` local preexistant sur la meme session;
- le flow `Compte joueur Cotton` doit maintenant se comporter comme en navigation privee, meme avec un historique local deja present.

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `node --check /home/romain/Cotton/games/web/includes/canvas/core/logger.global.js`

## PATCH 2026-04-02 — Observabilite du flux `EP -> games` via `ep_connect_token`

### Objectif
- rendre le diagnostic du pont `play -> games` faisable directement depuis le log WS centralise de session;
- prouver si un retour `ep_connect_token` casse sur la resolution du token, l'inscription joueur ou la finalisation bridge.

### Correctif livre
- `../games/web/includes/canvas/core/logger.global.js`
  - ajout d'un listener `register/debug` avec mapping de niveaux/messages pour les stages `ep_link_*`, `ep_autoreg_*`, `player_register_*` et `gate_*`;
  - ajout des evenements centralises:
    - `PLAYER_REGISTER_UPSERT_OK`
    - `PLAYER_REGISTER_UPSERT_ERR`
    - `MISSING_PLAYER_ID`
  - reglage final: les preuves du flux `EP -> games` restent en `debug` pour limiter le bruit en prod.

### Effet attendu
- le `.jsonl` de session remonte maintenant une preuve lisible du point exact de decrochage du flux `Compte joueur Cotton`;
- au prochain test, il doit etre possible de distinguer clairement:
  - echec `ep_link_resolve`;
  - echec d'upsert `player_register`;
  - echec `ep_link_finalize`;
  - ou simple retour UI sans echec bridge.

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/core/logger.global.js`

## PATCH 2026-04-02 — Player reload avec identite locale: `GameMeta` manque sur le canvas player

### Objectif
- stabiliser le rechargement du portail session player `games` quand un joueur est deja connu en localStorage;
- supprimer l'incoherence de bootstrap entre organizer canvas et player canvas sur les metadonnees de jeu.

### Correctif livre
- `../games/web/player_canvas.php`
  - injection de `window.GameMeta = { slug, title }` dans le bootstrap player, alignee sur l'organizer;
- `../games/web/includes/canvas/core/logger.global.js`
  - fallback `resolveGameSlug()` sur `window.AppConfig.gameSlug` si `window.GameMeta` est absent.

### Effet attendu
- un rechargement player avec identite locale preexistante ne perd plus le slug de jeu au bootstrap;
- les logs player ne remontent plus `game: ''` sur ce chemin;
- la reprise auto (`player/ready` -> `bootWS` -> `authenticatePlayer`) dispose du meme metadata contractuel que le reste du runtime.

### Verification
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `node --check /home/romain/Cotton/games/web/includes/canvas/core/logger.global.js`

## PATCH 2026-04-01 — Organizer: reset design session avec suppression compte si design identique

### Objectif
- clarifier dans la modale organizer que le reset vers le design du jeu peut aussi retirer le design compte par defaut;
- declencher ce comportement automatiquement sans ajouter de second CTA.

### Correctif livre
- `../games/web/includes/canvas/core/session_modals.js`
  - avant d'afficher la confirmation, le front appelle maintenant un preview backend pour savoir si un branding compte sera effectivement supprime;
  - la confirmation `Revenir au design d'origine du jeu` mentionne maintenant explicitement:
    - la remise au design du jeu pour la session courante;
    - la suppression automatique du design compte s'il existe et s'il correspond au design effectif de la session;
    - le fait que les prochaines sessions n'utiliseront plus ce design;
    - le fait que les sessions deja programmees qui l'heritaient deja le conserveront;
  - ces lignes d'impact ne sont affichees que si le preview confirme la suppression compte;
  - dans SweetAlert, la mention conditionnelle est affichee en petit, italique, avec un leger espacement au-dessus;
  - le POST de delete joint maintenant `cascade_client_branding_if_matching=1` pour demander au backend global de gerer ce reset elargi.

### Effet attendu
- l'utilisateur comprend avant validation que le reset de session peut aussi retirer le design compte par defaut;
- le front `games` delegue au backend la logique de gel des sessions futures deja programmees puis de suppression conditionnelle du design compte.

### Verification
- `node --experimental-default-type=module --check /home/romain/Cotton/games/web/includes/canvas/core/session_modals.js`

## TODO structurant — Branding par type de jeu

### Constat
- le front `games` ne sait aujourd'hui enregistrer qu'un branding session ou un branding compte global, sans dimension `quiz / blindtest / bingo`;
- un wording ou un delete borne au type de jeu courant ne peut pas etre fiable sans support backend correspondant.

### Cible
- permettre `Utiliser ce design pour mes prochaines sessions de ce jeu`;
- si reset du design sur une session d'un jeu donne, ne supprimer que le branding compte du meme type de jeu;
- laisser les autres jeux du meme compte inchanges.

### Dependances
- evolution du modele `global` de branding pour porter `id_type_produit`;
- evolution des endpoints save / preview / delete et des resolvers runtime;
- fallback retrocompatible sur le branding global existant tant qu'aucun branding par jeu n'existe.

### Reference
- `documentation/notes/branding_par_type_de_jeu.md`

## PATCH 2026-04-01 — Organizer: QR remote papier non ouvert garde ferme dans la modale d'options

### Objectif
- empecher l'UI organizer `games` d'exposer le QR d'acces remote depuis la modale d'options quand une session papier n'est pas encore ouverte;
- conserver le comportement existant pour les sessions papier effectivement ouvertes.

### Correctif livre
- `../games/web/includes/canvas/core/session_modals.js`
  - ajout d'une garde locale `canAutoExpandPilotQR(isPaper)` basee sur `window.ClientSessionMeta.isOpen`;
  - `setPilotQRExpanded()` n'ouvre plus automatiquement `#pilotQRWrap` en simple mode papier: l'auto-ouverture exige maintenant `papier + session ouverte`;
  - hors session ouverte, la modale referme explicitement le bloc QR remote et remet `aria-expanded=false`, tout en laissant le garde de clic existant dans `boot_organizer.js`.

### Effet attendu
- une session papier future ou fermee n'affiche plus en force le QR remote dans la modale d'options organisateur;
- sur une session papier ouverte, le QR continue a se deployer automatiquement comme avant.

### Verification
- `node --experimental-default-type=module --check /home/romain/Cotton/games/web/includes/canvas/core/session_modals.js`

## PATCH 2026-03-31 — Quiz organizer: diagnostic persistance format + garde polling réelle

### Objectif
- tracer explicitement le résultat serveur du switch `papier / numérique` sur les sessions quiz;
- faire remonter au polling organizer `games` la vraie garde `papier -> numérique`, au lieu d'un `digitalSwitchAllowed=true` forcé.
- si le plantage survient avant les logs quiz, journaliser aussi l'erreur au niveau bridge/dispatch.

### Correctif livré
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
  - ajout de logs métier dédiés sur les writes de format quiz:
  - `QUIZ_SESSION_UPDATE_REQUEST`
  - `QUIZ_SESSION_UPDATE_LOCKED`
  - `QUIZ_PAPER_TO_DIGITAL_CHECK`
  - `QUIZ_PAPER_TO_DIGITAL_BLOCKED`
  - `QUIZ_PAPER_TO_DIGITAL_OK`
  - `QUIZ_SESSION_UPDATE_FLAG_WRITE`
- `../games/web/includes/canvas/php/boot_lib.php`
  - `session_meta_get` expose maintenant la vraie compatibilité numérique quiz quand la session est encore en papier et non verrouillée;
  - le polling organizer reçoit désormais `digitalSwitchAllowed`, `digitalSwitchInvalidCount`, `digitalSwitchReason` et `digitalSwitchMessage` cohérents avec la garde serveur quiz.
- `../games/web/games_ajax.php`
  - ajout de logs bridge `INVALID_HANDLER_RESPONSE` et `HANDLER_ERROR` pour journaliser le `game`, l'`action`, le code métier et le code HTTP final quand le handler ne répond pas `ok`.
- `../games/web/includes/canvas/php/boot_lib.php`
  - ajout de logs `game_api_dispatch` `CALL/FAIL` pour confirmer le handler réellement appelé et son code de retour en cas d'échec.

### Effet attendu
- les logs `games` permettent de distinguer clairement un refus métier, un verrou runtime, un write SQL effectif ou un no-op;
- si l'échec survient avant `quiz_adapter_glue.php`, le bridge `games_ajax.php` et le dispatch remontent maintenant aussi une preuve exploitable;
- l'organizer `games` ne masque plus un refus `papier -> numérique` derrière un état local incohérent.

### Vérification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/games_ajax.php`

## PATCH 2026-03-31 — Organizer: synchro format avec `pro` + verrou runtime hors `En attente`

### Objectif
- empêcher tout changement de format officiel après sortie de l'état `En attente`, quel que soit le point d'entrée `games` ou `pro`;
- répercuter dans l'UI organizer `games` un changement de format déclenché depuis `pro`, sans recharger toute la page.

### Correctif livré
- `../games/web/includes/canvas/php/boot_lib.php`
  - ajout d'un helper commun `canvas_session_format_guard_get()` pour déterminer l'état `pending/locked`;
  - ajout de l'action canvas `session_meta_get` pour exposer l'état minimal de session à l'organizer.
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
  - blocage serveur du write `flag_controle_numerique` si la session officielle n'est plus `En attente`.
- `../games/web/includes/canvas/core/api_provider.js`
- `../games/web/includes/canvas/core/boot_organizer.js`
  - ajout d'un polling organizer ciblé sur `session_meta_get`;
  - si `pro` change le format, l'organizer met à jour `window.ServerSessionMeta`, resynchronise les radios de la modale et réémet `options/updated` pour réaligner l'UI.

### Effet attendu
- un organizer `games` déjà ouvert suit un changement `pro -> format` en quelques secondes sans reload complet;
- si la session n'est plus `En attente`, les write paths `games` refusent désormais le changement de format même si l'UI locale n'a pas encore été rouverte.

### Vérification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`

## PATCH 2026-03-30 — Compte joueur EP: fallback hors session ouverte

### Objectif
- permettre au bloc `Compte joueur Cotton` de rester utile quand la session `games` n'est pas ouverte, sans reboucler vers `games` après auth EP.

### Correctif livre
- `../games/web/player_canvas.php`
  - adaptation du texte du bloc selon l'état temporel de la session;
  - avant session non ouverte: message orienté `prévenir l'organisateur`;
  - session expirée/non ouverte: message orienté `prochaines sessions`.
  - fenêtre d'ouverture explicite:
    - `jour J` = ouvert;
    - `lendemain de session` = encore ouvert strictement avant `12:00`;
    - sinon = expiré.
- `../global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - fallback `games_account_join` vers `manage/s1/{token}` pour une session future non ouverte;
  - fallback `games_account_join` vers l'agenda EP pour une session expirée/non ouverte.
 - `../games/web/includes/canvas/play/register.js`
  - au jour J, le message d'attente du retour EP remplace désormais le texte/CTA du bloc `Compte joueur Cotton` au lieu d'apparaitre dans le bloc pseudo.
  - le resolve `ep_connect_token` tourne maintenant aussi quand la gate reste en `NO_MASTER`, afin de conserver le formulaire pseudo fermé et de rendre immédiatement le message de confirmation au retour de `play`.
  - pour une session papier, le retour `EP -> games` réutilise désormais le rendu papier historique avec message contextualisé joueur/équipe et CTA de désinscription.
  - sur ce flux papier, le gating WS ne constitue pas une garde bloquante: il est volontairement contourné pour conserver le retour de confirmation papier au lieu de tenter une entrée dans le gameplay numérique.

### Effet attendu
- les CTA `Se connecter / Créer mon compte joueur` restent exploitables même quand le pseudo historique `games` est fermé;
- le joueur authentifié EP n'est plus renvoyé inutilement vers `games` tant que la session n'est pas ouverte.
- quand la session est réellement ouverte, le bloc `Compte joueur Cotton` garde sa promesse standard et n'affiche plus le message dédié `NO_MASTER`.

## PATCH 2026-03-27 — Player canvas: bloc dedie `Compte joueur Cotton`

### Objectif
- remplacer le simple lien `S'inscrire avec mon compte joueur` par un vrai point d'entree EP distinct du formulaire pseudo, avec une promesse d'experience minimale plus claire.

### Correctif livre
- `../games/web/player_canvas.php`
  - remplacement du lien inline par un bloc `Compte joueur Cotton` separe du formulaire pseudo;
  - ajout d'un titre, d'une promesse minimale (`historique`, `prochaines sessions`, `organisateurs deja frequentes`) et de CTAs `Me connecter avec mon compte joueur` / `Creer mon compte`.
- `../games/web/includes/canvas/css/player_styles.css`
  - styles du nouveau bloc dedie pour l'ecran d'inscription joueur.

### Effet attendu
- le point d'entree EP sur `games` est plus lisible et ne vend plus une simple bascule technique;
- le formulaire pseudo reste le chemin principal immediat, avec un second bloc clairement distinct pour le compte joueur Cotton.

### Verification rapide
- `php -l /home/romain/Cotton/games/web/player_canvas.php`

## PATCH 2026-03-27 — New_EJ: `games` reduit au noyau bridge EP

### Objectif
- supprimer les ajouts non essentiels autour du chantier `EP -> games` pour ne conserver que le noyau bridge necessaire au retour joueur connecte.

### Correctif livre
- `../games/web/games_ajax.php`
  - suppression du log `ACTION_RX` non indispensable;
- residuel bridge confirme sur:
  - `../games/web/config.template.php`
  - `../games/web/includes/canvas/php/boot_lib.php`
  - `../games/web/includes/canvas/php/ep_account_bridge.php`
  - `../games/web/includes/canvas/play/register.js`
  - `../games/web/player_canvas.php`

### Effet attendu
- le diff `new_ej` cote `games` se limite a la configuration et au runtime strictement necessaires au flux `S'inscrire avec mon compte joueur`.

## PATCH 2026-03-26 — Player register: `S'inscrire avec mon compte joueur` + pont EP

### Objectif
- permettre depuis la page player `games` de basculer vers `play`, s'authentifier/créer son compte joueur, puis revenir sur la session avec une identité EP résolue pour auto-inscription.

### Correctif livre
- `../games/web/player_canvas.php`
  - ajout du CTA `S'inscrire avec mon compte joueur`;
  - injection des URLs `play` de signin/signup avec contexte session.
- `../games/web/includes/canvas/play/register.js`
  - prise en charge du query param `ep_connect_token`;
  - résolution du lien EP via `ep_link_resolve`;
  - auto-inscription dès que la gate joueur est ouverte;
  - finalisation du lien métier via `ep_link_finalize` après `player_register`.
- `../games/web/includes/canvas/php/ep_account_bridge.php`
  - nouveau bridge canvas de lecture/finalisation du retour EP.
- `../games/web/includes/canvas/php/boot_lib.php`
  - chargement du bridge EP.

### Effet attendu
- un joueur connecté à l'EP n'a plus à ressaisir son pseudo;
- Blindtest/Bingo utilisent le prénom EP;
- Quiz numérique utilise l'équipe déjà choisie côté `play`;
- les writes runtime restent dans `*_players`, sans déporter la logique métier vers les tables de jeu.

## PATCH 2026-03-24 — Logs prod cibles reprise player mobile (3 jeux)

### Objectif
- ajouter une preuve `info` exploitable en prod pour confirmer demain qu'une session joueur se reprend correctement apres coupure/background mobile, sans remonter tout le bruit debug lifecycle.

### Correctif livre
- `../games/web/includes/canvas/play/play-ws.js`
  - emission d'un evenement bus `player/ws:resume_ok` uniquement quand un vrai chemin de reprise joueur aboutit (`foreground:*` ou `ws_open_reconnect`);
- `../games/web/includes/canvas/core/logger.global.js`
  - nouvel evenement `PLAYER_SESSION_RESUME_OK` au niveau `info`, avec `{ sid, game, ws_state, reason }`.

### Effet attendu
- les sessions prod des 3 jeux remontent maintenant une preuve front concise quand la reprise joueur est effectivement reussie apres une coupure WS;
- les warnings transport existants (`PLAYER_REREGISTER_FAIL`, `WS_CLIENT_DISCONNECTED`, `WS_HEARTBEAT_TERMINATE`) peuvent ainsi etre recoupes demain avec des preuves positives de reprise, sans repasser la prod en mode debug.

## PATCH 2026-03-24 — Branding: upload visuel perso `games` = fichier original + persistance locale non degradante

### Audit cible prouve
- `games/web/includes/canvas/core/session_modals.js`

### Constat confirme
- le visuel perso etait pretraite cote navigateur avant upload:
  - preview/crop canvas `600x240`
  - reencodage JPEG `0.8`
- le save branding reuploadait ensuite cette version deja degradee au lieu du `File` original;
- le branding local persistant pouvait aussi reimposer plus tard une ancienne `dataURL` custom, d'ou le symptome `net au chargement puis flou`.

### Correctif livre
- la modale conserve maintenant le `File` original (`_visuelFile` / `_logoFile`) uniquement pour le save branding;
- le preview local leger reste utilise pour l'UI organizer, mais n'est plus la source du media envoye;
- le localStorage `games` ne persiste plus les objets `File`;
- au boot, `initSessionModals()` fusionne `window.ServerBranding` et le branding local au lieu d'ecraser la version serveur;
- si une ancienne `dataURL` locale existe encore alors qu'une URL serveur branding est disponible, l'URL serveur reprend la priorite;
- apres save branding reussi, la persistance locale est reecrite avec les URLs serveur finales avant `update_branding`.

### Effet attendu
- le jeu envoie au serveur le media source au lieu d'un preview compresse;
- le rendu branding ne bascule plus d'une image nette vers une ancienne preview floue quelques secondes apres chargement;
- la persistance hors serveur reste intacte pour les couleurs / modes / prefs, mais n'a plus priorite sur un asset branding serveur reel.
- les erreurs d'upload branding remontees par le serveur sont maintenant affichees telles quelles a l'organizer, y compris pour un logo/visuel trop lourd.
- le reset branding organizer ne peut plus desactiver un branding reseau TdR en supprimant la couche effective au lieu de la seule couche session.

## AUDIT #1 — Offer resolution (source of truth) (2026-03-06)

### Existant confirmé
- Appel du garde-fou central `global`:
  - `games/web/organizer_canvas.php:218` -> `app_session_launch_guard_get(...)`
- Fallback aligné resolver central:
  - `games/web/organizer_canvas.php` -> `app_ecommerce_offre_effective_get_context(...)` si `app_session_launch_guard_get` indisponible.
  - suppression du fallback local divergent basé sur `app_ecommerce_offres_client_get_count(...)`.

### TODO Lot 1 (`games`)
- [x] éviter toute divergence entre fallback local et resolver `global` (contrat unique de décision).
- [x] tracer explicitement dans la doc le comportement de repli (guard indisponible).

## AUDIT Réseau / Affiliation / Branding / Contenus partagés (2026-03-06)

### Cartographie confirmée (preuves code)
- Hydratation branding depuis `global` via token de session:
  - `../games/web/organizer_canvas.php:99`
  - `../games/web/organizer_canvas.php:102`
  - `../games/web/player_canvas.php:65`
  - `../games/web/player_canvas.php:68`
  - `../games/web/remote_canvas.php:70`
  - `../games/web/remote_canvas.php:73`
- Application runtime du branding (DOM/CSS):
  - `../games/web/includes/canvas/play/play-ui.js:2262`
  - `../games/web/includes/canvas/play/play-ui.js:2334`
  - `../games/web/includes/canvas/remote/remote-ui.js:5567`
- Diffusion live des updates branding en WS:
  - `../games/web/includes/canvas/play/play-ws.js:960`
  - `../games/web/includes/canvas/remote/remote-ws.js:727`
- Contrôle offre active au lancement organizer:
  - `../games/web/organizer_canvas.php:156`
  - `../games/web/organizer_canvas.php:217`
  - `../games/web/organizer_canvas.php:251`

### Existant confirmé
- Le runtime `games` consomme le branding effectif via API `global_ajax` avec le `token` de session.
- Le branding impacte l’UI organizer/player/remote (couleurs, font, visuels).
- Les updates branding transitent aussi en temps réel par WS (`update_branding`).
- Les contrôles d’accès offre côté organizer existent (hors démo).

### Manques identifiés (scope `games`)
- Pas de logique affiliation réseau dédiée dans ce repo (normal: repo runtime).
- Pas de modèle de contenu réseau propre (le partage de contenus est géré côté `pro`/`global`).

### Risques
- `token` en query string pour l’appel branding (`...&token=`) avec exposition possible dans logs/proxy.
- Dépendance forte au service `global_ajax` pour hydration branding (dégradation visuelle en cas d’indisponibilité).

## PATCH 2026-03-05 — Remote démarrage visuel + fit question longue (quiz papier lot `T`)

### Objectif
- Remote: améliorer le feedback UX entre clic Start et première question/morceau (phase jingle/initialisation).
- Quiz papier: garantir l’affichage complet des questions très longues (lots `T`) dans le bloc question fixe.

### Correctifs appliqués
- `../games/web/includes/canvas/remote/remote-ui.js`
  - état `setAwaitingStart(...)` durci: affichage du mode “démarrage” uniquement quand la partie est réellement en cours (`wsState === 'En cours'` ou `everStarted`),
  - message d’attente enrichi pendant jingle: “Le jeu démarre” + “Le jingle est en cours, la première question arrive.”,
  - pilotage fiable de la visibilité via `hidden` (au lieu de dépendre uniquement de `d-none`).
- `../games/web/remote_canvas.php`
  - ajout du bloc visuel `#waiting-starting-visual` dans la carte waiting (masqué par défaut avec `hidden`).
- `../games/web/includes/canvas/css/remote_styles.css`
  - style de l’état waiting “is-starting” (animation légère),
  - masquage des textes de bienvenue pendant l’initialisation,
  - rendu final du bloc `waiting-starting` transparent (pas de fond/bordure superflus dans une card déjà stylée).
- `../games/web/includes/canvas/core/canvas_display.js`
  - fit du titre question renforcé (`minPx` abaissé + fallback agressif) pour éviter le clipping des très longues questions.
- `../games/web/includes/canvas/core/games/quiz_ui.js`
  - suppression du fit local du titre pour éviter les conflits avec le fit global de `canvas_display.js`.

### Impact
- Avant le 1er Start: la remote reste sur le message de bienvenue standard (pas d’“initialisation” prématurée).
- Après Start, pendant jingle/chargement: état visuel explicite de démarrage, plus lisible.
- En quiz papier, les questions longues restent visibles entièrement dans le cadre fixe (taille texte adaptative).

### Fichiers touchés
- `../games/web/remote_canvas.php`
- `../games/web/includes/canvas/remote/remote-ui.js`
- `../games/web/includes/canvas/css/remote_styles.css`
- `../games/web/includes/canvas/core/canvas_display.js`
- `../games/web/includes/canvas/core/games/quiz_ui.js`

## PATCH 2026-03-20 — Player front logs: restore proof chain before mobile resume debug

### Objectif
- Fiabiliser la preuve `PLAYER_FRONT_BOOT` et la récupération de logs front `player` / `remote` au flush, sans relancer un chantier reconnect/mobile plus large.

### Audit code-first (preuves)
- `../games/web/player_canvas.php`
  - ordre réel de boot confirmé:
    - `@canvas/core/logger_global`
    - `@canvas/play/play-ws`
    - `@canvas/play/play-ui`
    - `@canvas/play/register`
- `../games/web/includes/canvas/core/logger.global.js`
  - `PLAYER_FRONT_BOOT` était émis pendant `tryHookBus()`, donc dès que le logger voyait `window.Bus.on`;
  - cet envoi passait par `emitPlayerFrontProof(...)` -> `Bus.emit('game:ws:send', { type:'log_event' ... })`;
  - mais ce chemin ne bufferisait pas la preuve et dépendait donc d’un listener déjà accroché sur `game:ws:send`.
- `../games/web/includes/canvas/play/play-ws.js`
  - le transport player n’est booté qu’au `Bus.on('player/ready', ...)` via `bootWSConnector(...)`;
  - le listener `Bus.on('game:ws:send', ...)` de transport n’est accroché que dans `ws_connector.js::connect(...)`, donc après ce boot.
- `../games/web/includes/canvas/core/ws_connector.js`
  - quand le listener est présent mais que la socket n’est pas encore `OPEN`, les frames sont bien mises en queue;
  - en revanche, si `game:ws:send` est émis avant que ce listener existe, l’événement Bus est perdu sans replay.
- Conclusion prouvée sur la chaîne actuelle:
  - `PLAYER_FRONT_BOOT` pouvait encore être perdu avant branchement réel du transport `game:ws:send`.
- `../games/web/logs_session.html`
  - le bouton flush ne faisait encore qu’un `localStorage.LOG_FLUSH_REQUEST`;
  - ce mécanisme reste utile pour un onglet local, mais ne couvre pas un player/remote distant.
- Serveurs WS
  - `../../blindtest/web/server/server.js`
  - `../../blindtest/web/server/actions/wsHandler.js`
  - `../../quiz/web/server/server.js`
  - `../../quiz/web/server/actions/wsHandler.js`
  - `../../bingo.game/ws/bingo_server.js`
  - `../../bingo.game/ws/server.js`
  - blindtest/quiz exposaient déjà une chaîne distante `/force_flush` -> broadcast frame `force_flush`;
  - bingo ingérait déjà `log_event/log_batch`, mais n’exposait pas encore d’équivalent HTTP `/force_flush`.

### Cause exacte
- Cause front confirmée:
  - `PLAYER_FRONT_BOOT` partait trop tôt;
  - `emitDirect(...)` ne dépend pas d’un buffer et n’a aucune preuve que le transport Bus->WS est déjà attaché;
  - tant que `play-ws.js` n’a pas booté `ws_connector`, la frame `log_event` de boot peut disparaître.
- Cause remote méta confirmée:
  - le logger n’importe pas directement le `Bus`; il attend `window.Bus` puis accroche ses listeners avec un polling 1s dans `tryHookBus()`;
  - sur `remote`, le `ws/status=open` initial peut donc être émis par `ws_connector.js` avant que `logger.global.js` n’ait réellement accroché `Bus.on('ws/status', ...)`;
  - résultat: le flush distant fonctionne quand même, mais `buildFlushMeta()` peut rester bloqué à `ws_ready_state=unknown` faute d’avoir vu l’événement d’ouverture initial.
- Cause Bingo viewer/proxy confirmée:
  - pas de route serveur `/force_flush`;
  - donc pas de flush distant Bingo équivalent à blindtest/quiz depuis l’outil d’audit.

### Correctif minimal appliqué
- `../games/web/includes/canvas/core/logger.global.js`
  - ajout d’une petite file `pendingProofEntries`;
  - `PLAYER_FRONT_BOOT` est maintenant créé une seule fois puis:
    - envoyé immédiatement si le transport est déjà `OPEN`,
    - sinon mis en attente et rejoué au premier `ws/open` / `ws/status=open`;
  - suppression du risque de doublon:
    - `playerFrontBootLogged` garde l’idempotence côté boot,
    - l’entrée pending est supprimée après premier envoi réussi;
  - les preuves `PLAYER_FRONT_LOG_FLUSH_TRY|OK|FAIL` restent hors buffer, mais sont désormais autorisées aussi pour le rôle `remote` (même nom d’événement, `role` réel dans l’entrée).
  - les marqueurs techniques de diagnostic passent en `debug` dans le viewer:
    - `PLAYER_FRONT_BOOT`
    - `PLAYER_FRONT_LOG_FLUSH_TRY|OK`
    - `PLAYER_WS_LIFECYCLE_DECISION`
    - `WS_CONNECTOR_LIFECYCLE_DECISION`
    - `PLAYER_REREGISTER_TRY|OK`
    - `REGISTER_KEEP_LOCAL_IDENTITY_DESPITE_PROBE_MISS`
  - les échecs restent en niveau haut:
    - `PLAYER_FRONT_LOG_FLUSH_FAIL` -> `warn`
    - `PLAYER_REREGISTER_FAIL` -> `warn`
- `../games/web/includes/canvas/core/ws_connector.js`
  - ajout d’un snapshot runtime partagé `window.__CANVAS_WS_RUNTIME__` mis à jour sur les transitions `connecting`, `opening-auth`, `open`, `closed`, `error`;
  - ce snapshot ne change pas le protocole WS ni le flush; il sert uniquement de mémoire de dernier état transport quand le logger a manqué l’événement Bus initial.
- `../games/web/includes/canvas/core/logger.global.js`
  - hydratation défensive de `wsStatus/wsReadyState/wsUrl` depuis `window.__CANVAS_WS_RUNTIME__` avant `buildFlushMeta()`, `isProofTransportReady()` et à l’accroche tardive `tryHookBus()`;
  - effet attendu:
    - `remote` continue à flusher comme avant,
    - mais `PLAYER_FRONT_LOG_FLUSH_TRY|OK` ne doivent plus remonter avec `ws_ready_state=unknown` sur un transport déjà `open`.
- `../bingo.game/ws/bingo_server.js`
  - ajout d’un broadcast minimal `forceFlushSession(...)`;
  - ajout d’une collecte des sockets par `sid` (organizer, remote, players) via `collectForceFlushTargetsBySid(...)`;
  - ajout du traitement WS `type:"force_flush"` avec logs `FORCE_FLUSH_RX` / `FORCE_FLUSH_BROADCAST`.
- `../bingo.game/ws/server.js`
  - ajout de la route HTTP `GET|POST /force_flush?sid=<sid>`;
  - route alignée sur blindtest/quiz: réponse `{ ok, sid, targets_count }`.
- `../games/web/includes/canvas/php/logs_proxy.php`
  - ajout du proxy `action=force_flush` vers:
    - quiz `http://127.0.0.1:3032/force_flush`
    - blindtest `http://127.0.0.1:3031/force_flush`
    - bingo `http://127.0.0.1:3030/force_flush`
- `../games/web/logs_session.html`
  - le bouton `Forcer flush`:
    - garde le `localStorage.LOG_FLUSH_REQUEST` local comme filet de sécurité;
    - appelle aussi `logs_proxy.php?action=force_flush` pour le flush distant réel.

### Contrat conservé
- Pas d’auto-flush continu en cours de session.
- Flush uniquement:
  - fin de session;
  - demande forcée explicite (`storage` local ou `force_flush` distant).
- Aucun changement organizer sur la stratégie de logs hors cette nouvelle capacité de flush viewer distant.

### Validation attendue
- Blindtest player mobile/distinct:
  - `PLAYER_FRONT_BOOT` présent une seule fois;
  - après `force_flush`: `PLAYER_FRONT_LOG_FLUSH_TRY` puis `PLAYER_FRONT_LOG_FLUSH_OK|FAIL`.
- Bingo player mobile/distinct:
  - même preuve;
  - route exacte: `/force_flush?sid=<sid>` côté `bingo.game/ws/server.js`, relayée par `games/web/includes/canvas/php/logs_proxy.php?action=force_flush`.
- Remote distant:
  - réception de la frame `force_flush`;
  - présence de `PLAYER_FRONT_LOG_FLUSH_TRY` puis `OK|FAIL` avec `role:"remote"` et `ws_ready_state:"open"` si la socket est déjà ouverte.
- Non-régression:
  - pas de double `PLAYER_FRONT_BOOT` sur un boot nominal où le WS ouvre normalement.

### Risques résiduels / next step
- Si la socket n’atteint jamais `OPEN`, `PLAYER_FRONT_BOOT` restera pending et donc non visible côté serveur: c’est un signal utile d’échec transport, pas un faux positif.
- La chaîne doit maintenant être validée en recette réelle mobile/distante, puis seulement servir de base au chantier reconnect/resume.

## PATCH 2026-03-20 — Player mobile resume: single recovery strategy after background

### Objectif
- Rebaseliner proprement la reprise player mobile après arrière-plan, sans reload manuel, sans churn WS et sans duplication de joueur.

### Audit code-first (preuves)
- `../games/web/includes/canvas/core/ws_connector.js` gardait encore un listener `visibilitychange` qui, au retour visible, pouvait fermer une socket `CONNECTING` avec la raison `focus_force_close_connecting`.
- `../games/web/includes/canvas/core/ws_connector.js` appelait bien `window.reRegisterPlayer()` après reconnexion (`waitForReRegisterAndCallIt`), mais le code réel courant de `../games/web/includes/canvas/play/play-ws.js` n’exposait plus cette API globale.
- `../games/web/includes/canvas/play/register.js` conservait déjà localement l’identité joueur quand un probe `players_get` / `bingoPlayerExists` répondait temporairement négatif, mais sans log V1 explicite de décision métier.
- Résultat: deux stratégies concurrentes de reprise subsistaient encore partiellement:
  - transport `ws_connector.js` avec fermeture forcée sur `CONNECTING`;
  - reprise applicative player incomplète / non réexposée côté `play-ws.js`.

### Contrat cible retenu
- Le transport WS reste piloté par `ws_connector.js`.
- Un retour visible ne ferme jamais une socket déjà `CONNECTING`.
- Le player ne relance jamais une 2e machine de reconnexion parallèle.
- Le re-register applicatif player ne se fait que lorsque le transport est réellement `OPEN`.
- En cas de probe de reprise temporairement négatif, l’identité locale est conservée et la reprise WS/API tranche ensuite l’état réel.

### Correctif minimal appliqué
- `../games/web/includes/canvas/play/play-ws.js`
  - réintroduit un point d’entrée unique `window.reRegisterPlayer(reason)` consommé par le connector après reconnect;
  - ajoute des listeners lifecycle player (`visibilitychange`, `pagehide`, `pageshow`) avec décision explicite:
    - `hint_only` si hint background possible,
    - `rereregister_now` uniquement si WS déjà `OPEN`,
    - `defer_to_connector` si transport non prêt / reconnect en cours,
    - `ignore` si évènement non exploitable;
  - garde-fous anti-concurrence sur le re-register applicatif (`reRegisterInFlight` + queue de raison);
  - hint foreground conservé, mais envoyé seulement quand le transport est stabilisé.
- `../games/web/includes/canvas/core/ws_connector.js`
  - suppression de la fermeture forcée d’une socket `CONNECTING` sur retour visible;
  - au retour visible:
    - `ignore` si socket déjà `OPEN`,
    - `defer_to_connector` si socket `CONNECTING`,
    - accélération de la reconnexion transport existante si socket non ouverte, sans lancer une machine parallèle;
  - passage d’une raison de reprise différée (`window.__PLAYER_PENDING_REREGISTER_REASON__`) au `reRegisterPlayer()` appelé après `ws/open`.
- `../games/web/includes/canvas/core/logger.global.js`
  - conserve les logs existants `PLAYER_FOREGROUND_HINT_SENT`, `PLAYER_REREGISTER_TRY`, `PLAYER_REREGISTER_OK`, `PLAYER_REREGISTER_FAIL`;
  - ajoute des logs V1 décisionnels:
    - `PLAYER_WS_LIFECYCLE_DECISION`
    - `WS_CONNECTOR_LIFECYCLE_DECISION`
    - `REGISTER_KEEP_LOCAL_IDENTITY_DESPITE_PROBE_MISS`
  - méta portée: `{source, document_hidden, ws_state|readyState, reconnect_in_progress, decision, reason}`.
- `../games/web/includes/canvas/play/register.js`
  - conservation de la règle “keep local identity on probe miss”;
  - ajout d’un log métier structuré quand on choisit explicitement `keep_local_identity_despite_probe_miss` sur `players_get` ou `bingoPlayerExists`.

### Impact
- Une seule stratégie de reprise survit:
  - lifecycle player = hint/re-register applicatif,
  - connector = reconnexion transport,
  - pas de `close()` forcé concurrent sur `CONNECTING`.
- Après retour foreground:
  - si WS déjà `OPEN`, le player rejoue immédiatement son handshake applicatif sans reload manuel;
  - sinon, le player délègue au connector; le connector reconnecte puis appelle `window.reRegisterPlayer(...)` après `ws/open`.
- Les probes négatifs transitoires ne suffisent plus à faire perdre le `player_id` local sans trace explicite.

### Validation réalisée
- Vérification statique du code sur les 3 jeux `quiz` / `blindtest` / `bingo` via les surfaces partagées `play-ws.js`, `register.js`, `ws_connector.js`, `logger.global.js`.
- Parcours couverts par lecture de code et instrumentation:
  - retour court arrière-plan: foreground avec WS `OPEN` -> `PLAYER_WS_LIFECYCLE_DECISION decision=rereregister_now` puis `PLAYER_REREGISTER_OK`;
  - retour long arrière-plan: foreground avec WS non ouverte -> `PLAYER_WS_LIFECYCLE_DECISION decision=defer_to_connector`, puis `WS_CONNECTOR_LIFECYCLE_DECISION decision=defer_to_connector`, reconnexion transport et re-register post-open;
  - retour pendant `CONNECTING`: plus aucun `focus_force_close_connecting`; décision = délégation au connector;
  - probe négatif transitoire: `REGISTER_KEEP_LOCAL_IDENTITY_DESPITE_PROBE_MISS`.

### Limites / next step
- Validation mobile réelle non exécutée dans cette tâche; la preuve disponible ici est un audit code-first + instrumentation front renforcée.
- Si un incident persiste, la prochaine lecture doit corréler:
  - `PLAYER_WS_LIFECYCLE_DECISION`
  - `WS_CONNECTOR_LIFECYCLE_DECISION`
  - `PLAYER_REREGISTER_*`
  - `REGISTER_KEEP_LOCAL_IDENTITY_DESPITE_PROBE_MISS`

## PATCH 2026-03-04 — Quiz hydration lot `L`: ordre sur `position` puis fallback `id`

### Objectif
- Aligner l’ordre de questions consommé côté app `games` avec l’ordre métier défini en bibliothèque (`questions.position`), tout en conservant un fallback stable quand `position` est absente/identique.

### Correctif minimal appliqué
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`:
  - lot `L`: tri SQL passé de `ORDER BY q.id ASC` à `ORDER BY q.position ASC, q.id ASC`.

### Impact
- Si `position` est correctement renseignée: affichage des questions selon cet ordre.
- Si `position` vaut `0` partout ou est identique: fallback naturel sur `q.id ASC`.

### Fichier touché
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`

## Audit croisé 2026-03-04 — Contrôle des liens YouTube (patch porté par `pro`)

### Objectif
- Vérifier si `games` devait porter une logique métier de contrôle des liens YouTube pour la V1 admin.

### Résultat
- Audit README/TASKS `games` + code `global`/`pro` conclut que la V1 doit être portée côté admin `pro` (scan offline), sans patch runtime `games`.
- Aucun fichier du repo `games` modifié dans ce patch.

### Impact
- `non trouvé dans la documentation` pour un `canon/repos/games/HANDOFF.md` public (URL fournie retourne 404 au moment de l’audit).
- Suivi documentaire maintenu ici (`TASKS.md`) en l’absence de handoff repo `games`.

## Google Drive support semantics soft-timeout after render (2026-02-27)

### Objectif
- Appliquer une sémantique explicite Drive:
  - `drive-timeout` bloquant si aucun rendu réussi,
  - `drive-timeout` non bloquant si le support a déjà été rendu/visible.

### Audit complémentaire
- Point central confirmé: `../games/web/includes/canvas/core/player/index.js::displaySupport(...)` (branche Drive unique pour tous les types Drive supportés).
- Propagation observability confirmée:
  - erreur -> `emitSupportEvent('SUPPORT_START_FAIL_DETAIL')` -> bus `support/error` -> `SUPPORT_ERROR` logger.
  - état prêt UI -> bus `support/started` avec `reason` consommé par `canvas_display.js` (`READY_OK`).

### Correctif minimal appliqué
- `../games/web/includes/canvas/core/player/index.js`:
  - `endLoadingForToken(...)` accepte maintenant une dissociation:
    - `errorReason` (observability/log),
    - `startedReason` (raison fonctionnelle UI).
  - branche Drive:
    - ajout flag `driveHasRenderedSuccessfully`,
    - ajout heuristique `hasLikelyDriveRendered(iframe)` (navigation effective/cross-origin) pour couvrir le cas rendu visible sans signal strict de readiness,
    - timeout final:
      - avant rendu: `drive-timeout-before-render` (bloquant),
      - après rendu: `drive-timeout-after-render` loggé en soft error, mais `support/started` émis avec `reason='drive-ready'` pour préserver l’affichage.

### Impact attendu
- Cas Drive “jamais affiché” inchangé (erreur bloquante/fallback possible).
- Cas Drive “affiché puis timeout” conservé en UI (dégradé observé, sans masquage).
- Supports non-Drive inchangés.

### Fichier touché
- `../games/web/includes/canvas/core/player/index.js`

## Audit supports Google Drive (multi-types) + patch timeout UI (2026-02-27)

### Objectif
- Auditer la prise en charge Google Drive sur le pipeline support front (pas seulement image) et corriger la disparition visuelle observée avec `reason=drive-timeout`.

### Résultat d’audit (code-first)
- Pipeline support commun localisé dans `../games/web/includes/canvas/core/player/index.js::displaySupport(...)`.
- Détection Drive centralisée via `getDirectGoogleDriveUrl(...)`, exécutée avant les branches media directes (image/audio/vidéo).
- `drive-timeout` est émis via `endLoadingForToken(...)` -> event bus `support/error` -> logger `SUPPORT_ERROR`.
- Les événements `start_support` / `support_ended` sont relayés via `../games/web/includes/canvas/core/ws_effects.js` (handlers WS + émission organizer).
- Constat: le retry Drive rechargeait l’`iframe` (`src` modifié) au premier timeout, ce qui pouvait effacer un support déjà partiellement affiché avant `drive-timeout`.

### Correctif minimal appliqué
- `../games/web/includes/canvas/core/player/index.js`:
  - durcissement de la reconnaissance Drive:
    - host strict `drive.google.com` / `docs.google.com`,
    - extraction id par `/d/<id>` ou `?id=<id>`,
    - normalisation vers `https://drive.google.com/file/d/<id>/preview`.
  - stratégie timeout Drive ajustée:
    - suppression du retry “hard reload” de l’`iframe` (plus de changement de `src` au premier timeout),
    - conservation d’une fenêtre de grâce unique avant `drive-timeout`.

### Impact attendu
- Réduction des cas “support visible puis disparu” sur Drive lent.
- `drive-timeout` reste possible si le support n’est pas prêt après la fenêtre de grâce.
- Pas de changement de pipeline pour les supports non-Drive.

### Fichier touché
- `../games/web/includes/canvas/core/player/index.js`

## Contrôle offre active — accès master organizer (2026-02-25)

### Objectif
- Bloquer l’accès direct organizer/master par token de session si le client n’a pas d’offre active.
- Exempter strictement les sessions démo.

### Implémentation
- Détection démo canonique:
  - source-of-truth: `championnats_sessions.flag_session_demo` (exposé aussi en `serverSessionMeta.isDemo`).
- Point de contrôle hydratation organizer:
  - `web/organizer_canvas.php` applique le contrôle dès le chargement session/client,
  - réutilisation prioritaire de la logique existante `app_session_launch_guard_get($id_session)`,
  - fallback local aligné sur la même règle si la fonction n’est pas dispo dans le contexte.
- Règle:
  - session démo -> accès autorisé sans contrôle offre,
  - session non-démo -> offre active requise, sinon blocage 403 + écran avec CTA offres.
- CTA offres organizer:
  - normalisation sur le sous-domaine `pro` (`$CONF_PRO_URL`),
  - conservation du suffixe contextuel renvoyé par le guard (`/extranet/ecommerce/offers/...`) quand présent,
  - fallback sur `/extranet/ecommerce/offers` si URL absente/non conforme.
- Anti-bypass bridge (organizer actions):
  - `2026-03-05`: ce guard a été retiré de `web/games_ajax.php` (plus de contrôle offre sur les writes Canvas),
  - cause: incident prod sur writes (`session_update`) avec `403 offer_inactive` et `details.reason=INTERNAL_ERROR`,
  - décision: contrôle d’offre conservé uniquement au point d’entrée organizer (`web/organizer_canvas.php`) pour le blocage d’accès/lancement.
- Logs structurés ajoutés:
  - `SESSION_ACCESS_OFFER_CHECK {session_id,client_id,game,is_demo,offer_ok,role=master}`
  - `SESSION_ACCESS_DENIED_OFFER_INACTIVE`

### Fichiers touchés
- `../games/web/organizer_canvas.php`
- `../games/web/games_ajax.php`

## Quiz — garde-fou bascule Papier -> Numérique (2026-02-25)

### Objectif
- Autoriser la bascule papier -> numérique uniquement avant démarrage, et seulement si toutes les questions de toutes les séries du quiz sont prêtes pour le numérique.

### Correctifs appliqués
- Hydratation quiz (`quiz_adapter_glue.php`):
  - calcul serveur `digitalSwitchAllowed`, `digitalSwitchInvalidCount`, `digitalSwitchReason`, `digitalSwitchMessage` injectés dans `preload.session` et `serverSessionMeta`,
  - périmètre contrôle = toutes les questions de toutes les séries (`lot_ids` complet, incluant lots temporaires `T*`).
- Règle “question OK pour numérique” (serveur):
  - réponse non vide,
  - au moins 2 fausses propositions non vides, distinctes de la bonne réponse.
- UI organizer (`session_modals.js`):
  - blocage de la bascule vers Numérique si `digitalSwitchAllowed=false` avec message explicite,
  - verrouillage du toggle papier/numérique si session démarrée (tooltip/message “Modifiable avant le démarrage”).
- Anti-bypass serveur (`qz_session_update`):
  - sur tentative papier->numérique (`flag_controle_numerique: 0 -> 1`), revalidation serveur complète,
  - refus si session démarrée ou propositions manquantes avec code `PAPER_TO_DIGITAL_BLOCKED_MISSING_PROPOSALS`,
  - logs structurés:
    - `QUIZ_PAPER_TO_DIGITAL_CHECK`
    - `QUIZ_PAPER_TO_DIGITAL_BLOCKED`
    - `QUIZ_PAPER_TO_DIGITAL_OK`.
- Bridge HTTP (`games_ajax.php`):
  - mapping HTTP 400 ajouté pour `paper_to_digital_blocked_missing_proposals`.

### Fichiers touchés
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/core/session_modals.js`
- `../games/web/games_ajax.php`

## Support startup + remote hydration fixes (2026-02-13)

### Objectif
- Réduire les faux échecs de démarrage support (`img-timeout` / `drive-timeout`) et fiabiliser l’hydratation remote en mode manuel.

### Correctifs appliqués
- `core/player/index.js`:
  - timeouts support rendus adaptatifs selon qualité réseau (`drive/image`: 15s nominal, 20s connexion lente),
  - retry unique pour `drive` et `image` avant `SUPPORT_ERROR`,
  - timers trackés puis annulés systématiquement au `load`/`error`,
  - `SUPPORT_START_FAIL_DETAIL` enrichi (`support_kind`, `timeout_ms`, `retry_count`) et `stale_token` ajouté pour distinguer les timeouts obsolètes.
- `core/session_sync.js`:
  - `playlistSongs` est renvoyé non seulement à l’initialisation, mais aussi au premier moment où la playlist devient non vide (`didPlaylistSync`), pour corriger la non-hydratation remote tardive.
- `remote/remote-ui.js`:
  - après `remote/sessionInfos` avec changement `paperMode`, recalcul immédiat `applyManualModeUI()` pour éviter un état manuel évalué sur un `SESSION_PAPER` obsolète (bouton support manquant).

### Fichiers touchés
- `../games/web/includes/canvas/core/player/index.js`
- `../games/web/includes/canvas/core/session_sync.js`
- `../games/web/includes/canvas/remote/remote-ui.js`

## Terminated Static Mode (2026-02-11)

### Objectif
- Si `window.Preload` indique une session terminée, ne pas ouvrir de WebSocket côté front (`organizer`, `remote`, `player` si preload dispo) et afficher l’état final depuis preload.

### Implémentation
- Garde preload terminée ajoutée dans:
  - `../games/web/includes/canvas/core/ws_effects.js`
  - `../games/web/includes/canvas/remote/remote-ws.js`
  - `../games/web/includes/canvas/play/play-ws.js`
- En mode statique:
  - pas de boot WS
  - pas d’envoi `registerOrganizer` / `remoteGameState` / `auth_*` / `registerPlayer`
  - `remote` émet l’état final local depuis preload (`remote/state`, `remote/end`, `remote/players:update` et winners bingo preload)
  - `organizer` hydrate aussi les scores/joueurs depuis preload (plus dépendance WS pour l’écran final)
- Bascule live -> static:
  - à réception WS `endGame`, passage en mode static + reload HTTP (`location.replace` avec `_tsm=*`) pour recharger un preload terminal.

### Preload attendu côté front
- quiz/blindtest:
  - `preload.session.isTerminated` (bool)
  - `preload.isTerminated` (bool)
  - `preload.players.players[]` (déjà présent)
- bingo:
  - `preload.session.isTerminated` (bool)
  - `preload.isTerminated` (bool)
  - `preload.players.players[]` (ajouté pour réhydrater organizer en mode terminal)
  - `preload.phase_winners[]` (phase winners ordonnés)

### Fichiers touchés (code)
- `../games/web/includes/canvas/core/ws_effects.js`
- `../games/web/includes/canvas/core/boot_organizer.js`
- `../games/web/includes/canvas/remote/remote-ws.js`
- `../games/web/includes/canvas/remote/remote-ui.js`
- `../games/web/includes/canvas/play/play-ws.js`
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`

### Correctif bingo reload terminé (2026-02-11)
- Symptôme observé: après `endGame` en live, l’UI organizer bingo affichait bien joueurs + gagnants; après refresh/reload, liste vide et podium fallback.
- Cause racine confirmée: `ws_effects.js` coupe le WS en mode preload terminé, mais `bingo_resolve_token` n’injectait pas `preload.players` (contrairement à quiz/blindtest).
- Correctif appliqué: `bingo_resolve_token` injecte désormais `players` (shape compat `{ players: [...] }`) via lecture DB (`bingo_api_players_get`) en plus de `phase_winners`.

### Ajustement UX live endGame (2026-02-11)
- Constat: bascule statique immédiate à réception WS `endGame` trop agressive pour l’écran de fin live (organizer/remote/player).
- Nouveau comportement:
  - à `endGame`, on marque une fenêtre de grâce WS de 20 min en `sessionStorage` (clé session-scoped),
  - on ne force plus de reload `_tsm` immédiat,
  - au boot/reload, si preload est "Partie terminée" mais grâce active, la connexion WS reste autorisée.
- Portée:
  - organizer: `../games/web/includes/canvas/core/ws_effects.js`
  - remote: `../games/web/includes/canvas/remote/remote-ws.js`
  - player: `../games/web/includes/canvas/play/play-ws.js`

### Correctif Bingo play reload gagnant (2026-02-11)
- Symptôme: en fin de partie Bingo, un joueur gagnant voyait bien le message/lot en live, mais après reload retombait sur un écran "non gagnant".
- Correctif: persistance de `bingo_best_phase` en clé session-scoped (`bingo_best_phase:<sessionId>`) avec fallback legacy global.
- Effet: l’écran de fin joueur recharge correctement la meilleure phase gagnée et le lot associé depuis `window.AppSessionLots`.
- Fichier: `../games/web/includes/canvas/play/play-ui.js`

## Audit remote paper register (2026-02-12)

### Objectif
- Garantir la compatibilité migrations `player_id` (UPSERT/UNIQUE) pour l’ajout joueur depuis remote (session papier), sans doublon et idempotent au retry.

### Résultat
- Gap confirmé avant patch:
  - `remote-ui.js` envoyait `player_register` sans `event_id`.
  - `player_id` était généré en format non canonique (`remote:*`) et non persistant.
- Correctif appliqué:
  - `player_id` canonique (`p:<uuid>`) généré/persisté en localStorage, scope `game + session + username normalisé`.
  - `event_id` UUID généré/persisté par tentative d’inscription, réutilisé au retry tant que la tentative n’est pas confirmée.
  - purge de la tentative pending uniquement après succès `player_register`.
  - payload `player_register` key-first sur les 3 jeux: `username`, `player_id`, `event_id`, puis `sessionId` (bingo) ou `sessionPrimaryId` (quiz/blindtest).
  - `playerId` numérique reste optionnel (uniquement retour serveur / compat), pas utilisé comme identité canonique.
  - actions remote joueur/phase harmonisées (`admin_player_register`, `admin_set_score`, `admin_phase_winner`, `admin_phase_fail`): envoi `event_id` + `player_id` canonique quand disponible, `playerId` numérique en compat.
  - listing remote quiz/blindtest dédupliqué key-first (`player_id` canonique prioritaire, fallback numérique) pour éviter les doubles entrées visuelles sur snapshots mixtes.
  - exception Bingo validée (session papier animateur): `admin_phase_winner` sans joueur est autorisé côté WS (`bingo_server.js`) et déclenche un avancement manuel de phase sans write `phase_winner` DB.
  - organizer Bingo: `phase_over` exploite `won_phase` en source de vérité (fallback `next_phase` conservé), ce qui corrige le décalage d’annonce de phase gagnée en mode manuel.
  - mode manuel Bingo sans joueur: calcul de `next_phase` aligné sur la phase explicitement validée par l’admin (si présente dans `phases_liste`), et notifs victoire rétablies en `PlayerWin` (format historique, plus de `"... validée manuellement"`).
  - fallback podium Bingo harmonisé (orga + remote): sans gagnants hydratés, rendu `Joueur inconnu` par phase (Bingo / Double ligne / Ligne), sans fallback classement par score.
  - liste joueurs remote Bingo fin de session: protection contre écrasement par snapshots vides post-`endGame` + fallback `players_get` si nécessaire.
  - quiz/blindtest hydratation alignée: `players_get` et preload `players` exposent désormais `player_id` canonique (et `updated_at` si présent), avec fallback legacy safe si colonne absente (introspection schéma).
  - effet: les hydrations WS quiz/blindtest qui dédupliquent key-first sur `player_id` ne perdent plus de lignes valides quand la DB contient des identités canoniques.
  - sessions terminées: `players_get` supporte `includeInactive` (quiz/blindtest/bingo) pour récupérer aussi les participants déconnectés/inactifs, afin de conserver un classement final cohérent avec la participation réelle.
  - WS quiz/blindtest: à la reconnexion orga d’une session terminée, hydratation DB forcée (incluant inactifs), invalidation du snapshot final en mémoire, puis reconstruction/renvoi `endGame` depuis l’état hydraté.
  - WS bingo: hydratation DB au login orga (`auth_client`) passe désormais `includeInactive=true` quand la phase est terminale (`current_phase=-1`), pour réaligner le snapshot joueurs avec l’historique de participation.

### Fichier touché
- `../games/web/includes/canvas/remote/remote-ui.js`
- `../bingo.game/ws/bingo_server.js`
- `../games/web/includes/canvas/core/ws_effects.js`
- `../games/web/includes/canvas/core/games/bingo_ui.js`
- `../games/web/includes/canvas/core/canvas_display.js`
- `../games/web/includes/canvas/remote/remote-ws.js`
- `../games/web/includes/canvas/php/quiz_adapter_glue.php`
- `../games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
- `../quiz/web/server/actions/registration.js`
- `../blindtest/web/server/actions/registration.js`
- `../bingo.game/ws/bingo_server.js`

## Bingo lots regression fix (2026-02-12)

### Objectif
- Éviter la disparition du bloc “lots à gagner” côté player Bingo quand l’organizer modifie des options en phase d’attente (ex: `songDuration`).

### Correctif appliqué
- `ws_effects.js`: `options/updated` ne pousse plus systématiquement `update_session_infos`; envoi limité aux changements de contrôle de session (`paperMode`, et `manualAdvance` pour quiz).
- Effet attendu: un changement d’option gameplay (`songDuration`) ne déclenche plus de diffusion `sessionInfos` inutile.

### Fichiers touchés
- `../games/web/includes/canvas/core/ws_effects.js`

## Logs viewer chips sync fix (2026-02-12)

### Objectif
- Éliminer l’écart temporaire entre chips globales (`total/debug/info/warn/error`) et tableau après flush front (`log_batch`), tout en conservant des chips basées sur l’ensemble des logs.

### Correctif appliqué
- `logs_proxy.php`: ajout du paramètre `force=1` pour bypass cache sur `stats=1`.
- `logs_session.html`: requête stats passée en `stats=1&force=1` pour recalcul global immédiat.
- `visibles` reste inchangé (toujours calculé côté client sur les entrées chargées).

### Fichiers touchés
- `../games/web/includes/canvas/php/logs_proxy.php`
- `../games/web/logs_session.html`

## Bingo phase winners canonical key migration (2026-02-12)

### Objectif
- Finaliser la migration identity key-first pour les gagnants de phase Bingo, tout en restant compatible avec le schéma legacy (`player_id` numérique) durant la transition.

### Correctif appliqué
- `bingo_api_phase_winner` résout désormais l’identité gagnant via `_bingo_resolve_identity` (source de vérité: `player_id` canonique), puis persiste l’ID DB legacy pour compat table.
- Ajout du code d’erreur explicite `error=phase_winner_conflict` sur conflit inter-joueurs d’une même phase (en plus de `reason`).
- Lecture winners (`_bingo_fetch_phase_winners`) basculée key-first:
  - priorise `bingo_phase_winners.player_id_key` si la colonne existe,
  - fallback sur jointure `bingo_players` sinon.
- Écriture winners rétrocompatible:
  - si `player_id_key` existe, insertion `(session_id, phase, player_id, player_id_key, event_id)`,
  - sinon insertion legacy `(session_id, phase, player_id, event_id)`.
- Correctif post-migration: résolution d’une ambiguïté SQL `session_id/phase` dans la requête de conflit (`WHERE w.session_id = :sid AND w.phase = :phase`).

### Migration DB ajoutée
- Nouveau script idempotent:
  - `../games/web/includes/canvas/sql/2026-02-12_bingo_phase_winners_player_id_key.sql`
- Contenu:
  - ajoute `player_id_key VARCHAR(64) NULL` si absente,
  - backfill depuis `bingo_players` via relation legacy (`session_id + id`),
  - ajoute index `idx_bpw_session_phase_player_key`,
  - post-check `missing_player_id_key`.

### Fichiers touchés
- `../games/web/includes/canvas/php/bingo_adapter_glue.php`
- `../games/web/includes/canvas/sql/2026-02-12_bingo_phase_winners_player_id_key.sql`

## AUDIT data results (DB reads): current pipeline (2026-02-11)

### Scope audité
- Données: players (identité), scores, podium/leaderboard final (quiz/blindtest), winners de phase bingo.
- Front surfaces: organizer, remote, player register.
- Contraintes: audit only, zéro patch runtime.

### Call-sites front qui lisent DB (résultats)
- `../games/web/includes/canvas/play/register.js:835` -> `session_primary_id` (HTTP bridge) pour résoudre `sessionPrimaryId` avant contrôle d’existence joueur.
- `../games/web/includes/canvas/play/register.js:845` -> `players_get { sessionPrimaryId }` (quiz/blindtest), utilisé en auto-resume (`playerExistsInSession`), retourne `players[]` avec score.
- `../games/web/includes/canvas/play/register.js:861` -> `players_get { sessionId }` (bingo), utilisé en auto-resume (`bingoPlayerExists`), retourne `players[]`.
- `../games/web/includes/canvas/remote/remote-ui.js:417` -> `session_primary_id` (HTTP bridge), prérequis pour read joueurs côté remote.
- `../games/web/includes/canvas/remote/remote-ui.js:3211` -> `players_get { sessionId }` (bingo) via `fetchPlayersSnapshot()`.
- `../games/web/includes/canvas/remote/remote-ui.js:3215` -> `players_get { sessionPrimaryId }` (quiz/blindtest) via `fetchPlayersSnapshot()`.
- `../games/web/includes/canvas/remote/remote-ui.js:3260` -> `fetchPlayersSnapshot()` appelé après `player_register` remote (rafraîchissement manuel liste joueurs).
- `../games/web/organizer_canvas.php:51` + `../games/web/remote_canvas.php:50` -> preload HTTP serveur (`build_preload_for_game`) injecté dans `window.Preload` (lecture DB au rendu page, sans fetch JS direct).

### Reads DB preload (HTTP direct, page load)
- Quiz: `../games/web/includes/canvas/php/quiz_adapter_glue.php:508` lit état session + players (`_qz_fetch_players`) et injecte `preload.players` (`...:539`, `...:564`).
- Blindtest: `../games/web/includes/canvas/php/blindtest_adapter_glue.php:396` lit état session + players (`_bt_fetch_players`) et injecte `preload.players` (`...:427`, `...:455`).
- Bingo: `../games/web/includes/canvas/php/bingo_adapter_glue.php:134` lit état session + playlist uniquement; pas de `preload.players/podium/winners` (`...:173-182`).

### Pipeline par jeu (constat actuel)
| Donnée | Quiz | Blindtest | Bingo |
| --- | --- | --- | --- |
| Players | Mix preload HTTP (`quiz_resolve_token`) + WS (`gameState/sessionUpdate/updatePlayers/endGame`) + read HTTP ponctuel (`players_get`) pour register/remote add-player | Mix preload HTTP (`blindtest_resolve_token`) + WS (`gameState/sessionUpdate/updatePlayers/endGame`) + read HTTP ponctuel (`players_get`) pour register/remote add-player | WS snapshot principal (`state`, `num_connected_players`) + read HTTP ponctuel `players_get` (register/remote add-player). Preload bingo ne contient pas players |
| Scores | Transportés dans `players` (preload quiz/bt + WS). Pas de read `session_get` dédié trouvé côté front | Idem quiz | Pas de score podium final dédié côté front; leaderboard bingo affiché surtout via players + winners mémoire |
| Podium / leaderboard final | Affiché depuis WS `endGame` (`m.podium` sinon `m.players`) `remote-ui.js:4822`; fallback tri front dans `renderEndPodium` `...:2812-2824` | Idem quiz | Podium construit depuis map `bingoWinners` mémoire (`remote-ui.js:2767`, `...:2845`), pas de read DB winners dédié |
| Winners phase | N/A | N/A | Reçus en live via WS `phase_over` (`remote-ws.js:709`) ou notifications WS parsées (`remote-ws.js:657-677`), stockés en mémoire (`remote-ui.js:4621-4635`) |
| Qui calcule | WS calcule et pousse; front peut retraiter/ordonner podium pour rendu (`remote-ui.js:2818`) | WS calcule et pousse; front peut retraiter/ordonner podium pour rendu | Front remote reconstruit podium depuis winners mémoire; organizer render peut fallback depuis store/players (`canvas_display.js:1177-1250`) |

### Focus reload session terminée
- Organizer: hydrate preload sans players (`boot_organizer.js:383-391`, `...:463-476`), puis attend WS pour résultats (`ws_effects.js:450-467`, `...:563-635`).
- Remote quiz/blindtest: peut afficher players preload immédiat (`remote-ui.js:231`, `...:458-464`), puis WS `remoteGameState` (`remote-ws.js:299`, `...:515-560`) et/ou `endGame` (`...:601-607`) pilote le rendu final.
- Remote bingo: pas de preload winners/podium; rendu fin dépend des messages WS reçus (`state/phase_over/notifications`). Aucun read front de `bingo_phase_winners` trouvé.

### Réponses factuelles demandées
- Quiz, reload terminé: rendu résultats vient principalement du snapshot WS (`endGame`), avec fallback visuel possible sur players preload/WS.
- Blindtest, reload terminé: idem quiz.
- Bingo, reload terminé: rendu résultats vient du snapshot WS `state` + événements live winners; pas de fetch HTTP front dédié winners.

### Gaps identifiés (sans patch)
- Aucun call-site front trouvé pour lire un podium DB stocké (`podium_json`) au reload.
- Aucun call-site front trouvé pour lire `bingo_phase_winners` (ni action read dédiée winners).
- Fallback `remote/state` en “Partie terminée” côté quiz/blindtest attend `m.podium/m.players` (`remote-ui.js:4716-4720`), alors que `remote-ws.js` n’injecte pas ces champs dans l’event `remote/state` (`remote-ws.js:520`, `...:542`).

- 2026-02-11 — code+doc — Patch 5 front identity persistence (bingo/blindtest/quiz): helper session-scoped `getOrCreatePlayerId({game,sid})` + migration legacy (`${game}:player_stable_id`, `${game}:player_id`, `player_id`) + logs `PLAYER_ID_STORAGE_RESOLVED {game,sid,source}`; wiring `register.js` + `play-ws.js` pour stabilité reload/changement d’onglet, et comportement attendu après suppression de clé scoped (nouvel ID généré au prochain register/auth de session).
- 2026-02-11 — code+doc — WS player registration canon strict: `play-ws.js` envoie désormais `registerPlayer { sessionId, player_id, playerId? (db) }` pour quiz/blindtest, envoie aussi `player_id` canon sur `auth_player` / `auth_player_paper` Bingo, et passe `checkAnswer` en `player_id` (plus de dépendance protocolaire au champ legacy `playerId` comme identifiant canon).
- 2026-02-11 — bugfix bingo/front — `player_register` ne part plus jamais avec un `player_id` numérique: normalisation stricte pré-appel (`preparePlayerIdPreRegister`) vers `p:<uuid>`, migration douce legacy (`player_id` numeric -> `player_db_id`), et log debug `PLAYER_ID_PRE_REGISTER` `{sessionId,pid_sent,pid_source,legacy_db_id_if_any}`.
- 2026-02-11 — code+doc — Player replacement UX (last connection wins): `play-ws.js` gère `SESSION_REPLACED` (mode read-only, blocage des envois WS, API `resumeAfterReplacement`), `ws_connector.js` stoppe la reconnexion auto après close code `4005` (`__WS_SUPPRESS_RECONNECT__` + event `ws/session_replaced`), `play-ui.js` affiche une bannière persistante + toast + bouton “Reprendre ici” (reload), force `Pause`, stoppe timers/reveal, et désactive réponses/grille locale (quiz/blindtest/bingo côté front commun).
- 2026-02-11 — code+doc — Register/identity front session-scoped (quiz/blindtest/bingo): `play/register.js` utilise `${slug}:player_stable_id:${sessionId}` comme source de vérité du `player_id` canonique (`p:<uuid>`), conserve `${slug}:player_stable_id` en compat legacy (migration douce si `keySid` match), et sépare désormais `player_id` (stable) de `player_db_id` (numérique legacy). Bingo envoie explicitement `player_id` sur `player_register/grid_assign/grid_hydrate/grid_cells_sync`, persiste `grid_id` aussi en clé session-scoped `${slug}:grid_id:${sessionId}`, et n’utilise plus la clé globale legacy comme vérité. Instrumentation debug `register/debug` maintenue (`*_tx`, `*_ok`, `*_fail`) avec `{sessionId, stable_key, player_id, player_id_origin, username}`.
- 2026-02-10 — code+doc — Patch Point 1 “event_id partout” (mode progressif, non-bloquant): `games_ajax.php` introduit une liste centrale d’actions mutatrices + helper `getOrCreateEventId` (UUID v4 serveur si absent/invalide), logs `EVENT_ID_RX` (info bridge) et warning structuré `MISSING_EVENT_ID`; idempotence `game_events` activée pour ces actions même sans `event_id` client initial. Front `canvasCall` injecte `event_id` pour actions mutatrices; `play/register.js` et `play/play-ui.js` propagent aussi `event_id` (`player_register`, `grid_assign`, `deactivate_player`). Compat maintenue: aucune requête rejetée pour `event_id` manquant.
- 2026-02-09 — code+doc — Reveal player key-first: `play-ws.js` consomme `answerReveal`; `play-ui.js` applique désormais le reveal par `data-option-key` (`applyRevealByKey`) avec fallback legacy texte/index, et émet les logs v1 debug `PLAYER_REVEAL_RX` / `PLAYER_REVEAL_APPLY` via `logger.global.js`.
- 2026-02-10 — audit+doc — Audit transversal `event_id + *_players` (`games_ajax.php`, `includes/canvas/php/*`, `play/*`, WS repos): confirmation que l’idempotence bridge dépend strictement de la présence de `event_id`; writes WS via `canvasWrite` injectent `event_id`, mais plusieurs writes front/organizer restent sans `event_id` (`player_register`, `deactivate_player`, `grid_assign`, `resetdemo`, `prizes_save`). Côté `*_players`, rôle observé = registre de participation/session + `is_active` partiel (déconnexion involontaire souvent mémoire seulement). Rapports: `notes/audit-event-id-players-2026-02-10.md` + `notes/audit-bingo-player-register-reinscription-2026-02-10.md`.
- 2026-02-09 — code+doc — Bots answer payload durci (`games/web/test_bots.php`): sélection désormais par objet option (et non par texte), envoi WS explicite `selectedOption=opt.raw` + `selectedOptionKey=opt.key` quand disponible; fallback texte conservé seulement si options legacy sans objet.
- 2026-02-09 — code+doc — Bots submit key compat: correction du payload `checkAnswer` dans `games/web/test_bots.php` (virgule manquante entre `selectedOption` et `selectedOptionKey`) pour éviter les envois sans clé menant à `PLAYER_ANSWER_EVAL method=\"legacy\"`.
- 2026-02-09 — code+doc — Player answers compat key-first: `play-ui.js` expose désormais `data-option-key=<option.key>` (si disponible) et `play-ws.js` envoie `checkAnswer { selectedOption, selectedOptionKey }` en conservant `selectedOption` pour compat legacy WS.
- 2026-02-09 — code+doc — Remote options jingle fix: `remote-ws.js` ne gate plus le refresh des propositions sur le seul changement d’index logique (cas jingle→round1, index logique inchangé), applique aussi les updates via `remote_sync` / `GAME_OPTIONS_UPDATED` / `STATE_SYNC`, et ajoute les logs v1 `REMOTE_OPTIONS_RX` + `REMOTE_OPTIONS_GUARD_BLOCK`; `remote-ui.js` ajoute `optionsLive` + log `REMOTE_OPTIONS_RENDER`. Compat convention logs: émission via bus `ui/remote:action` (suppression des `window.Logger.debug` directs pour `REMOTE_OPTIONS_*`). Stabilité reveal (quiz/blindtest): conservation de la correction sur `remote/options:proposals` + alias CSS `option-reveal` (compat `.reveal`) + reveal key-first strict (`data-option-key`) avec logs debug `BT_REMOTE_REVEAL_RX`/`BT_REMOTE_REVEAL_APPLY`; propagation `correctOptionKey` depuis `session_sync` vers WS quiz/blindtest.
- 2026-02-09 — code+doc — Front logger: ajout `ensureEntrySourceTs` dans `logger.global.js` pour garantir un timestamp source par entrée (`meta.client_ts` + `meta.event_ts`) avant `log_batch`/`log_event`; compat ISO conservée (`entry.ts` préservé si valide, fallback ISO sinon).
- 2026-02-08 — code+doc — Flush logs front harmonisé viewer-first: `LOG_FLUSH_TRY` (debug), `LOG_FLUSH_OK` (info), `LOG_FLUSH_FAIL` (warn) avec meta `{count, ws_ready_state, ws_url?}`; objectif: preuve d’ingestion front côté WS (`LOG_BATCH_RX`) et lisibilité timeline.
- 2026-02-09 — code+doc — Rollback Bingo flush: suppression de la voie `logs_proxy.php?flush=1`/`force_flush` (non native Bingo), retour au trigger viewer `localStorage.LOG_FLUSH_REQUEST` consommé par `logger.global.js` (`storage` -> `flushBufferToWS` -> `log_batch`).
- 2026-02-05 — code+doc — Bingo Canvas `phase_winner` persisté : ajout table `bingo_phase_winners`, colonnes de dénormalisation `phase_wins_count/last_won_*` sur `bingo_players`, handler PHP transactionnel (idempotence `event_id`, conflit inter-joueur, update phase_courante, logs PHASE_WINNER_*); doc canon synchronisée (DDL/OVERVIEW/MAP/write-map/HANDOFF).
- 2026-02-05 — code — Remote options diagnostics : instrumentation Bus-first (INTENT/SEND/ACK/OVERRIDDEN avec corrélation seq/latence) pour `updateGameOptions` (remote-ui/remote-ws, logger.global).
- 2026-02-05 — code — Diagnostics songDuration (organizer): logs Bus-first REMOTE_ACTION_RX/BLOCKED, ORG_TO_SERVER_SEND, ORG_OPTIONS_OBSERVED/OVERRIDDEN avec séquencement et latence (ws_effects, logger.global).
- 2026-02-05 — code — Remote_action guard split: les actions options (set_duration/choices/pause/option_type/manual) bypass le guard organizerCanControlSync; seules les commandes player restent bloquées si player_not_ready; log classification `remote_action_classified`.
- 2026-02-05 — doc — ajout contrats WS/HTTP, idempotence, paper-mode, glossaire états; README restructuré; TASKS mis à jour
- 2026-02-05 — doc — création du parcours repo-first (INDEX/README/TASKS) + intégration “surfaces d’intervention” (script map 20/80)

## PATCH 2026-03-26 — New_EJ: priorite du flux `ep_connect_token` sur l'etat local
- [x] Audit ciblé:
  - `games/web/includes/canvas/play/register.js`
  - `games/web/player_canvas.php`
- [x] Correctif livré:
  - le retour `EP -> games` ne se fait plus court-circuiter par `isReturningPlayer()` tant qu'une reprise via `ep_connect_token` est en attente;
  - ajout d'un etat local dedie a la completion du flux EP pour eviter les gardes hors scope;
  - maintien du comportement historique pour les joueurs deja connus quand aucun token EP n'est present.
- [x] Vérification:
  - revue diff ciblée `games/web/includes/canvas/play/register.js`
  - `node --check` non exploitable tel quel sur ce fichier front ESM (`@canvas/*`)

## PATCH 2026-03-27 — Bridge EP -> games: priorité au pseudo pour Blind Test / Bingo
- [x] Audit ciblé:
  - `games/web/includes/canvas/php/ep_account_bridge.php`
- [x] Correctif livré:
  - le bridge `ep_connect_token` charge désormais `equipes_joueurs.pseudo` en plus de `prenom`;
  - pour `blindtest` / `bingo`, le username injecté dans `games` prend le pseudo en priorité, avec fallback sur le prénom;
  - le cas `quiz` reste inchangé sur le nom d'équipe.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/ep_account_bridge.php`

## PATCH 2026-03-31 — Quiz organizer: `session_update` accepte un switch de format seul
- [x] Audit ciblé:
  - `games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `games/logs/error_log`
  - `games/logs/access_log`
- [x] Correctif livré:
  - le handler `quiz_api_session_update()` n'injecte plus `currentSongIndex=null` et `gameStatus=null` quand le payload organizer ne porte qu'un changement de format;
  - `qz_session_update()` peut donc traiter un `paperMode` / `flagControleNumerique` seul sans tomber sur `BAD_GAME_STATUS` avant la persistance du flag;
  - la cause a ete prouvee par les logs `game_api_dispatch FAIL quiz.session_update error=BAD_GAME_STATUS` sur les requetes organizer du `31/03/2026`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`

## PATCH 2026-03-31 — Quiz organizer: nettoyage logs + message de compatibilite numerique
- [x] Audit ciblé:
  - `games/web/includes/canvas/core/session_modals.js`
  - `games/web/includes/canvas/php/boot_lib.php`
  - `games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `games/web/games_ajax.php`
- [x] Correctif livré:
  - retrait des logs de diagnostic temporaires (`game_api_dispatch`, `HANDLER_ERROR`, `QUIZ_SESSION_UPDATE_*`) ajoutes pour l'enquete du `500`;
  - la modale organizer desactive maintenant tout le switch de format quiz quand le passage `papier -> numerique` est interdit;
  - une note statique s'affiche sous le switch: `Ce quiz n'est pas compatible avec la version numérique du jeu.`
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `php -l /home/romain/Cotton/games/web/games_ajax.php`

## PATCH 2026-03-31 — Organizer games: sortie automatique si session supprimee cote pro
- [x] Audit ciblé:
  - `games/web/includes/canvas/core/boot_organizer.js`
  - `games/web/includes/canvas/core/end_game.js`
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- [x] Correctif livré:
  - le polling organizer `session_meta_get` intercepte maintenant `session_not_found`;
  - si la session a ete supprimee cote `pro` pendant qu'un organizer `games` est ouvert, l'interface reutilise le chemin de quit volontaire (`quitGame` via WS + `endSession()`) puis redirige vers `pro`.
- [x] Vérification:
  - revue ciblée de `games/web/includes/canvas/core/boot_organizer.js`

## PATCH 2026-04-01 — Remote papier: lookup DB joueurs/equipes existants
- [x] Audit ciblé:
  - `games/web/includes/canvas/remote/remote-ui.js`
  - `games/web/includes/canvas/css/remote_styles.css`
  - `games/web/includes/canvas/php/boot_lib.php`
  - `games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `games/web/includes/canvas/php/bingo_adapter_glue.php`
  - `games/web/includes/canvas/php/ep_account_bridge.php`
- [x] Correctif livré:
  - ajout de l'action bridge `participant_lookup` pour suggérer les equipes `quiz` depuis `equipes` et les joueurs `blindtest` / `bingo` depuis `equipes_joueurs` a partir de 3 caracteres;
  - la modale remote permet soit de selectionner une entree existante, soit de confirmer une saisie libre;
  - une selection DB envoie un `player_id` canonique `p:uuid`, derive de facon deterministe de la source metier (`id_equipe` / `id_joueur`), afin de reutiliser la meme identite runtime au lieu de regenerer un id local aleatoire;
  - pour `quiz`, les equipes homonymes sont desormais distinguees par un contexte metier affiche dans les suggestions: jusqu'a 2 prenoms de joueurs associes a chaque equipe;
  - pour `blindtest` / `bingo`, les fiches `equipes_joueurs` portant un email technique `@cotton-quiz.com` sont maintenant exclues du lookup remote;
  - les autres joueurs homonymes sont distingues par un email masque dans les suggestions quand `equipes_joueurs` expose une colonne email standard (`email`, `mail` ou `adresse_mail`);
  - le lookup joueur dedoublonne les fiches strictement homonymes (`libelle affiche + email normalise`) et garde la plus recente (`updated_at`, sinon `created_at`, sinon `id` le plus grand) pour ne pas exposer plusieurs fois le meme joueur a l'animateur;
  - le lookup remote applique maintenant un filtre dur par organisateur a partir de la session courante: `quiz` ne remonte que les equipes deja vues pour ce client via les tables recentes plus `equipes_to_championnats_sessions`, tandis que `blindtest` / `bingo` ne remontent que les joueurs deja lies a ce compte organisateur via les tables recentes plus le legacy bingo `jeux_bingo_musical_grids_clients`;
  - les libelles remote explicitent ce perimetre avec `joueur/equipe deja lie(e) a ton compte organisateur`;
  - les handlers `player_register` lisent maintenant la longueur reelle de leur colonne `username` via `information_schema`, avec fallback `20`, au lieu d'une borne fixe `20`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
  - `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-04-13 — Games config: détection dev robuste pour les URLs WS
- [x] Audit ciblé:
  - `games/web/config.php`
  - `games/web/config.template.php`
- [x] Correctif livré:
  - la détection d'environnement `games` ne reposait que sur `games.dev.cotton-quiz.com`, ce qui faisait retomber d'autres hosts dev en `prod`;
  - la détection utilise maintenant `HTTP_HOST` en priorité, avec fallback `SERVER_NAME`, pour éviter les faux `prod` derrière vhost / proxy;
  - `games` aligne maintenant sa détection sur la règle robuste `*.dev.cotton-quiz.com`, comme `global`;
  - les clés `bt_ws_url`, `qz_ws_url` et `bm_ws_url` pointent donc à nouveau vers les endpoints dev dès que le host courant est un sous-domaine dev valide.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/config.php`
  - `php -l /home/romain/Cotton/games/web/config.template.php`

## PATCH 2026-04-13 — Games organizer: debug runtime de résolution WS
- [x] Audit ciblé:
  - `games/web/organizer_canvas.php`
- [x] Correctif livré:
  - ajout temporaire d'un debug dev `window.__COTTON_WS_DEBUG__` loggé en console dans organizer;
  - le payload expose `HTTP_HOST`, `SERVER_NAME`, `REQUEST_URI`, `conf.server`, `AppConfig.env` et `AppConfig.wsUrl` pour isoler un mauvais host runtime, une conf erronée ou un rendu HTML stale/cache.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/organizer_canvas.php`

## PATCH 2026-04-13 — Games organizer: héritage de `$env` corrigé
- [x] Audit ciblé:
  - `games/web/modules/app_orga_ajax.php`
  - `games/web/games_ajax.php`
- [x] Correctif livré:
  - `app_orga_ajax.php` ne recalculait pas localement `$env` et héritait donc de la portée du fichier appelant;
  - `games_ajax.php` réécrivait ensuite `$env` avec `$CONF_SERVER ?? 'prod'`, alors que `$CONF_SERVER` n'était pas défini;
  - résultat: organizer pouvait sélectionner les URLs WS `prod` alors même que `conf.server === 'dev'` et que la matrice `bt_ws_url/qz_ws_url/bm_ws_url` était correcte;
  - `app_orga_ajax.php` calcule maintenant explicitement `$env = (string)($conf['server'] ?? 'prod')`;
  - `games_ajax.php` aligne aussi son `$env` CORS sur `$conf['server']`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/modules/app_orga_ajax.php`
  - `php -l /home/romain/Cotton/games/web/games_ajax.php`

## PATCH 2026-04-13 — Games organizer: retrait du debug WS temporaire
- [x] Audit ciblé:
  - `games/web/organizer_canvas.php`
- [x] Correctif livré:
  - suppression de `window.__COTTON_WS_DEBUG__` après validation de la chaîne de résolution WS en dev;
  - le rendu organizer retrouve un bootstrap propre sans log console de diagnostic.
- [x] Vérification:
  - `php -l /home/romain/Cotton/games/web/organizer_canvas.php`

## PATCH 2026-04-16 — Branding sessions: persistance du visuel recadré
- [x] Audit ciblé:
  - `games/web/includes/canvas/core/session_modals.js`
- [x] Correctif livré:
  - la solution front intermédiaire a été retirée;
  - `session_modals.js` est revenu au flux simple: aperçu local recadré pour la modale, mais envoi prioritaire du fichier source brut au backend pour `branding_visuel`;
  - le cadrage final du visuel branding est désormais porté côté `global`, pas par un dérivé HD fabriqué dans `games`.
- [x] Vérification:
  - revue de diff sur `games/web/includes/canvas/core/session_modals.js`

## PATCH 2026-05-05 — Bingo organizer: médailles de phase visibles pendant la session
- [x] Audit ciblé:
  - `games/web/includes/canvas/core/games/bingo_ui.js`
  - `games/web/includes/canvas/core/canvas_display.js`
  - `games/web/includes/canvas/core/ws_effects.js`
- [x] Correctif livré:
  - `srv/phaseOver` émet maintenant `bingo/medals/updated` quand un gagnant de phase ajoute ou améliore une médaille;
  - les gagnants reçus sous id canonique ou id legacy sont resolus vers la même clé joueur que la liste organizer (`playerId` prioritaire);
  - l'hydratation Bingo depuis snapshot conserve les médailles déjà connues au lieu de repartir d'un objet vide quand le snapshot ne contient pas les notifications `PlayerWin`.
  - `bingo/medals/updated` rafraîchit maintenant aussi la liste organizer compacte en live, pas seulement les listes plein écran et le mode pause.
  - le rendu des badges Bingo recherche maintenant la médaille sur toutes les clés connues de la ligne joueur (`playerId`, `player_id`, id DB/legacy, mapping grille) pour couvrir le cas du joueur GM en iframe dont la forme d'identifiant peut changer après un update live.
  - au reload/reprise d'une session Bingo en cours, `Preload.phase_winners` réhydrate maintenant aussi `bingo.medalsById` et émet `bingo/medals/updated`; le chemin est explicitement désactivé juste après un reset démo Bingo (`bingo_postreset=1`).
  - après reset d'une démo Bingo qui était terminée, `bingo_postreset=1` sert de signal parent: si le boot serveur confirme `En attente`, l'organizer vide puis reconfigure l'iframe joueur GM avec son URL normale.
- [x] Impact:
  - aucune modification de contrat WS ou bridge;
  - aucun changement de logique player / grille Bingo;
  - correction limitée au rendu organizer mobile et desktop des badges `LIGNE`, `DOUBLE LIGNE`, `BINGO`.
- [x] Vérification:
  - `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/games/bingo_ui.js`
# PATCH 2026-07-12 — Régression Hub relance numérique / papier

- [x] Isoler les hunks `runtime_participation_ensure` et la nouvelle barrière `runtimeEnsure.ok`.
- [x] Séparer le contrat papier: mapping/identité Hub sans preload, moteur ni `id_participation` runtime requis.
- [x] Restaurer l'exposition de `hubAutoPlayer` depuis un mapping numérique actif sans assimiler `player_register.ok` à une preuve WS.
- [x] Vérifier la syntaxe PHP et les diffs.
- [ ] Exécuter la recette réelle quit/relaunch et capturer première trame/réponse WS pour Blind Test, Quiz et Bingo.
# PATCH 2026-07-12 — Player Hub après suspension

- [x] Identifier le premier affichage fautif: `setUiState(OPEN)` → `setStage('register')` → `form.style.display=''` lorsque le storage n'est pas encore restauré.
- [x] Faire reconnaître un `hubAutoPlayer` valide/non-left comme restauration en cours dans la décision UI uniquement.
- [x] Conserver les payloads et ACK WS réels des trois moteurs.
- [x] Ajouter une trace non sensible de la garde.
- [ ] Recette réelle suspend/reprise et grâce organisateur sur Blind Test, Quiz et Bingo.
# PATCH 2026-07-12 — Relance Hub Master en Pause

- [x] Empêcher `hubLaunchAutoStart` de relancer automatiquement une session déjà commencée.
- [x] Réutiliser l'hydratation `Pause` et le snapshot `game/paused` existants.
- [x] Republier le snapshot `Pause` après `ws/registered` pour supprimer la course de bootstrap.
- [x] Conserver l'auto-start du premier lancement Hub.
- [ ] Recette réelle: suspension → relance Master en Pause → Player en Pause → clic Play → deux interfaces en cours.

# PATCH 2026-07-31 — Hub Play branding live

- [x] Reutiliser le polling Play existant (`current_player`, `active_launched_session`) pour transporter le branding Hub canonique.
- [x] Charger `client` + `branding` pour ces actions afin de conserver le meme titre et les memes variables que le rendu initial.
- [x] Ajouter `hub_branding` aux payloads Play: revision, titre, meta, visuel, logo, police, couleurs et variables CSS.
- [x] Appliquer cote Play les variables CSS, la police, le bandeau visuel, le logo discret de bas de page, le titre et la meta sans reload complet.
- [x] Cache-buster le visuel et le logo Play avec la revision Hub pour couvrir les remplacements sous URL stable.
- [x] Verification: `php -l web/modules/app_hub_view_helpers.php`, `node web/tests/hub_session_settings_dom_test.mjs`, `php web/tests/hub_session_settings_test.php`.
- [ ] Recette reelle: joueur connecte sur Hub Play, modification branding depuis Dashboard Pro, mise a jour Play sans reload pendant que Hub Master suit deja.

# PATCH 2026-08-25 — Hub présentation: quick-add et pending focus Remote

- [x] Audit ciblé:
  - `games/web/modules/app_hub_view_helpers.php`
  - `games/web/modules/app_hub_remote_ajax.php`
  - `games/web/tests/hub_session_settings_test.php`
  - `games/web/tests/hub_remote_polling_test.mjs`
  - `games/web/tests/hub_remote_contract_test.php`
  - `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- [x] Matrice historique reconstituée:
  - boot/reload sans présentation canonique: fallback rendu seulement (`first_unplayed_program_order`, puis `first_suspended_program_order`, puis dernière fin naturelle, puis première session métier);
  - sélection manuelle Master/Remote: présentation persistée, pas de mutation runtime;
  - lancement/reprise: événement runtime, `active_session_id` et `presentation_session_id` alignés;
  - ajout rapide: événement métier `quick_add`, doit persister la session créée;
  - fin naturelle/suspension/podium: règles historiques conservées mais non réécrites dans ce patch faute d'un nouveau producteur prouvé hors quick-add.
- [x] Correctif livré:
  - `quick_session_create` persiste la première session créée comme `presentation_session_id` avec raison diagnostique `quick_add`;
  - Hub Remote garde `pendingPresentationSessionId` quand la présentation canonique cible une session absente du Programme local;
  - aucun fallback Remote concurrent n'est sélectionné pendant ce pending;
  - le pending est appliqué automatiquement quand `sessions[]` contient la session cible;
  - une nouvelle présentation canonique reçue remplace le pending précédent.
- [x] Révisions:
  - pas de nouveau polling;
  - convergence assurée par `presentation_updated_at` côté présentation et par la révision de préparation liée aux mutations Programme.
- [x] Vérification:
  - `php -l web/modules/app_hub_view_helpers.php`
  - `php -l web/modules/app_hub_remote_ajax.php`
  - `php web/tests/hub_session_settings_test.php`
  - `node web/tests/hub_remote_polling_test.mjs`
  - `php web/tests/hub_remote_contract_test.php`
  - `php web/tests/hub_presentation_runtime_separation_test.php`
  - `node web/tests/hub_session_settings_dom_test.mjs`
  - `php /home/romain/Cotton/global/web/tests/hub_presentation_mode_contract_test.php`
  - `php /home/romain/Cotton/global/web/tests/hub_remote_control_contract_test.php`
- [ ] Recette navigateur:
  - Hub Master ajoute une partie rapide D, vérifie sélection Master D et `presentation_session_id=D`;
  - Hub Remote ouverte avant l'apparition de D doit rester sans fallback puis sélectionner D au snapshot suivant;
  - répéter avec D visible avant la présentation;
  - vérifier qu'une sélection manuelle E reçue pendant le pending remplace D.
