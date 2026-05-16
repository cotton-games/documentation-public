# Repo `global` — Tasks

## PATCH 2026-05-14 - Helper BO terminaison offre hors cadre
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livre cote `global`:
  - ajout de `app_ecommerce_reseau_activation_activate_from_bo_detail(...)` pour conserver `ok`, `id_activation`, `id_offre_client_deleguee` et `blocked_reason`;
  - conservation du wrapper historique `app_ecommerce_reseau_activation_activate_from_bo(...)` en retour `id_activation` pour compatibilite;
  - ajout de `app_ecommerce_reseau_offre_hors_cadre_terminate_from_bo(...)` pour terminer une delegation hors cadre ciblee depuis le BO.
- [x] Garde-fous:
  - offre active uniquement, `id_client` siege, `id_client_delegation` affilie, affilie encore rattache au siege;
  - catalogue hors cadre autorise;
  - refus si l'offre est liee a un support reseau ou si l'activation courante prouve un mode `cadre`;
  - aucune action sur les offres propres affilies ni sur les autres offres du meme affilie.
- [x] Verification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [ ] Recette serveur:
  - verifier attribution hors cadre BO sans abonnement actif;
  - verifier terminaison hors cadre et maintien affiliation;
  - verifier non-regression PRO commande hors cadre TdR.

## PATCH 2026-05-13 - Helper Home onboarding premiere animation ABN
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/general/branding/app_branding_functions.php`
  - `pro/web/ec/ec.php`
- [x] Correctif livre cote `global`:
  - mise a jour de `app_client_network_home_widget_get($id_client)`;
  - ajout de `app_client_home_onboarding_widget_get($id_client)` pour normaliser le payload onboarding consomme par la Home EC;
  - exclusion des comptes TdR, pipelines hors `INS`/`ABN`/`CSO` et affiliations sans valeur active hors fallback ABN;
  - detection V1 des offres deleguees actives, jeux reseau partages, design reseau valide et stats LP significatives;
  - retour `onboarding_widget` pour tout `ABN` sans session officielle deja programmee, pas seulement aucune session a venir;
  - sessions demo exclues du calcul par le compteur `flag_session_demo=0 AND flag_configuration_complete=1`;
  - jeux reseau partages suffisants pour la variante contextualisee et le CTA reseau, meme sans offre TdR active;
  - fallback generique Cotton ajoute quand aucun contexte exploitable n'existe, avec CTA vers `extranet/games/library?from=agenda&mode=library`;
  - `onboarding_widget` fournit un titre/CTA neutres premiere animation, sans chips ni CTA secondaire;
  - retour `context_banner` commun pour `ABN` deja actif / `INS` / `CSO` avec jeux reseau, design reseau ou stats significatives;
  - le bandeau commun porte le titre factuel `Ton espace Cotton est affilié à : {Nom_contexte}`;
  - aucun CTA dans les bandeaux, aucun affichage sur simple rattachement, support seul ou stats faibles.
- [x] Invariants:
  - aucune modification des regles pipeline;
  - aucune modification catalogue, design reseau ou creation de session;
  - les stats LP existantes sont reutilisees avec les memes seuils;
  - le CTA CAS 1 avec jeux reseau pointe seulement vers le hub reseau en contexte programmation.
- [x] Verification:
  - `php -l global/web/app/modules/entites/clients/app_clients_functions.php`
- [ ] Recette serveur:
  - verifier les 12 cas produit Home EC demandes avec donnees reelles ou fixtures serveur.
- [ ] Limite V1:
  - operation reseau active non cablee: non trouve dans la documentation et pas de source runtime canonique locale identifiee.

## PATCH 2026-05-13 - Stripe webhooks: suppression emails livemode=false
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
- [x] Correctif livre cote `global`:
  - extension compatible de `app_ecommerce_commande_ajouter(...)` avec `$email_options`;
  - suppression optionnelle des emails Brevo admin commande et AI Studio `INVOICE_MONTHLY` quand le webhook Stripe transmet `suppress_stripe_webhook_emails=1`;
  - log technique `[Stripe Webhook][Email Suppressed] livemode=false` pour chaque email ignore.
- [x] Invariants:
  - aucun critere Cotton opportuniste (`flag_test`, `mode_test`, etc.);
  - aucun usage du prefixe `[ TEST ]` comme source de verite;
  - aucune modification des commandes, factures, montants, paiements, statuts ou synchronisations.
- [x] Verification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l pro/web/ec/ec_webhook_stripe_handler.php`

## PATCH 2026-05-12 - Stats preuve sociale LP reseau
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php`
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Correctif livre:
  - ajout de `app_client_network_lp_stats_get($id_client_reseau)`;
  - comptage des affilies via `clients.id_client_reseau`;
  - comptage des sessions via jointure `championnats_sessions` + `clients`, hors demos et avec configuration complete;
  - comptage joueurs uniquement depuis l'agregat `reporting_games_players_monthly`, si la table existe;
  - application serveur des seuils commerciaux V1 et exclusion automatique des indicateurs absents/faibles;
  - seuils affichables: affilies >= 3, sessions >= 5, joueurs >= 100;
  - seuils signal fort: affilies >= 20, sessions >= 50, joueurs >= 1000;
  - bloc affichable si au moins 2 indicateurs passent les seuils, ou si 1 indicateur atteint un seuil signal fort.
- [x] Donnees exclues V1:
  - recalcul direct des joueurs depuis tables runtime, juge trop couteux/ambigu pour une LP publique.
- [ ] Verification recette serveur:
  - TdR sous seuils: aucun bloc;
  - TdR avec deux indicateurs au-dessus des seuils: bloc affiche;
  - TdR avec un seul indicateur tres fort: bloc affiche;
  - agregat joueurs absent/vide: indicateur joueurs masque sans erreur.

## PATCH 2026-05-12 - Couleurs LP reseau dediees TdR
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `www/web/bo/master/bo_master_form.php`
  - `www/web/lp/lp.php`
- [x] Correctif livre:
  - ajout lazy-init des colonnes `clients.lp_reseau_couleur_principale` et `clients.lp_reseau_couleur_secondaire`;
  - ajout des helpers `app_client_lp_color_normalize`, `app_client_lp_colors_get` et `app_client_lp_colors_save`;
  - ajout du helper `app_client_signup_network_theme_get` pour composer l'habillage signup/signin affilie depuis logo/visuel LP puis branding historique, sans appliquer les couleurs LP au formulaire PRO;
  - valeurs vides autorisees, valeurs invalides neutralisees, valeurs valides normalisees en `#RRGGBB`;
  - script SQL d'alignement ajoute: `documentation/lp_reseau_couleurs_clients_phpmyadmin.sql`.
- [ ] Verification recette serveur:
  - appliquer/valider les colonnes sur dev/prod avant edition BO si le lazy-init ne suffit pas;
  - verifier la persistence et la lecture publique sur une TdR reelle.

## PATCH 2026-05-11 - Abonnement reseau: echeance date_fin et incluses
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/cron_routine_bdd_maj.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Cause confirmee:
  - le cron historique termine les PAK, ABN one-shot et ABN sans engagement expires;
  - l'Abonnement reseau n'avait pas de traitement dedie garantissant l'appel au helper canonique de cloture runtime;
  - les incluses creees sous support reseau ne recuperaient pas systematiquement la `date_fin` du support.
- [x] Correctif livre:
  - ajout de `app_ecommerce_reseau_support_offers_expired_process(...)`;
  - ajout de `app_ecommerce_reseau_support_offer_included_date_fin_sync(...)`;
  - propagation de la `date_fin` support a la creation d'une incluse cadre;
  - appel cron depuis `cron_routine_bdd_maj.php`.
- [x] Invariants:
  - aucune offre propre ni hors cadre n'est fermee par ce flux;
  - une incluse deja terminee n'est pas rouverte ni modifiee;
  - le refresh reseau ne recree pas de support actif et la finalisation archive le runtime.
- [x] Verification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l www/web/bo/cron_routine_bdd_maj.php`
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`

## PATCH 2026-05-11 - Demos LP reseau rattachees au compte TdR
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `www/web/lp/lp.php`
  - `www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_script.php`
  - `www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_script.php`
  - `www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_script.php`
  - `global/web/app/modules/general/branding/app_branding_functions.php`
- [x] Cause confirmee:
  - les formulaires demo LP lancaient les scripts standards avec seulement `frm_mode=session_demo` et `id_catalogue_produit`;
  - les scripts demo forcaient le compte porteur standard `1557`;
  - le design reseau peut etre retrouve depuis le compte TdR, car `app_general_branding_get_detail(...)` traite un `id_client` TdR comme source de branding reseau.
- [x] Correctif livre:
  - ajout d'une resolution serveur du compte TdR a partir du slug public LP reseau/operation;
  - seuls les contextes `reseau` et `operation` sont acceptes;
  - le client resolu doit etre un compte `flag_client_reseau_siege=1`, sinon le fallback demo standard reste `1557`;
  - `app_session_demo_ajouter(...)` conserve les flags demo prives/non officiels existants.
- [x] Invariants:
  - aucun `id_client` sensible n'est transmis cote public;
  - aucune session officielle ou facturable n'est creee par ce flux;
  - les demos standards hors LP reseau/operation gardent le compte demo historique;
  - aucun droit BO/pro n'est donne au visiteur.
- [x] Verification:
  - `php -l global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_script.php`
  - `php -l www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_script.php`
  - `php -l www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_script.php`

## PATCH 2026-05-06 — Stripe ABN: recalcul pipeline client apres cloture terminale
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- [x] Cause confirmee:
  - `customer.subscription.updated/deleted` appelle bien `app_ecommerce_stripe_subscription_terminal_sync(...)` quand Stripe est terminal;
  - ce helper passe l'offre Cotton en `id_etat=4`, mais ne recalculait pas le pipeline du client payeur direct;
  - la logique historique `PAK/ABN -> CSO` existait dans des parcours internes mais pas dans ce webhook Stripe.
- [x] Correctif livre:
  - ajout de `app_ecommerce_client_pipeline_sync_from_effective_offer(...)`;
  - la routine relit l'acces effectif via `app_ecommerce_offre_effective_get_context(...)`;
  - elle conserve `ABN` si une offre active de type abonnement reste effective, bascule `PAK` si l'offre effective restante est un pack, et repasse `CSO` seulement si aucun acces effectif ne reste;
  - `app_ecommerce_stripe_subscription_terminal_sync(...)` appelle cette routine apres la cloture d'offre Stripe pour les offres directes hors support reseau;
  - log sobre ajoute uniquement si le pipeline change: `id_client`, `id_offre_client`, ancien/nouveau pipeline, raison.
- [x] Invariants:
  - aucune migration SQL;
  - aucun changement sur `cancel_at_period_end` tant que l'offre reste active;
  - aucun double traitement Stripe;
  - les offres deleguees et supports reseau gardent les synchronisations existantes.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php`

## PATCH 2026-05-05 — Branding Canvas: sauvegarde merge-safe des designs partiels
- [x] Audit confirme dans:
  - `global/web/app/modules/general/branding/app_branding_ajax.php`
  - `games/web/includes/canvas/core/session_modals.js`
  - `games/web/player_canvas.php`
  - `games/web/remote_canvas.php`
- [x] Cause confirmee:
  - le save branding global reconstruisait les metadonnees depuis les seules cles POST;
  - une cle couleur/police absente pouvait donc retomber a `''`;
  - `logo_mode=original` ou `visuel_mode=original` sans fichier/URL etait interprete comme une suppression media;
  - un save partiel couleur-only pouvait donc vider ou remplacer un logo/visuel existant consomme ensuite par player/remote.
- [x] Correctif livre:
  - avant `app_general_branding_modifier(...)`, l'endpoint relit le branding existant via `app_general_branding_get_complete(...)`;
  - chaque champ meta (`color_background_1`, `color_background_2`, `color_font_1`, `color_font_2`, `font_family_name`, `font_family_url`) utilise la valeur POST si elle existe, sinon la valeur existante;
  - les medias absents passent en operation `preserve`;
  - la suppression media demande maintenant une intention explicite `logo_clear=1` ou `visuel_clear=1`;
  - la reponse `save` expose aussi le branding effectif apres sauvegarde pour que `games` rediffuse un payload live complet.
- [x] Invariants:
  - aucun changement de schema;
  - les uploads fichier/URL existants restent supportes;
  - les resets volontaires restent possibles via marqueur explicite;
  - la resolution player/remote continue de relire le branding effectif via l'API existante.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_ajax.php`

## PATCH 2026-04-29 — Stripe ABN: helpers relance visible et cloture terminale
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Correctif livre:
  - ajout d'un helper de date terminale Stripe priorisant `ended_at`, puis `canceled_at`, puis `current_period_end`, puis la date courante;
  - ajout d'un append idempotent dans `ecommerce_offres_to_clients.commentaire` pour tracer une cloture Stripe due a `payment_failed`;
  - ajout d'un helper de synchronisation terminale qui passe l'offre en `id_etat=4` sans creer de commande ni facture;
  - ajout d'un helper de lecture live Stripe pour exposer un bandeau PRO quand la subscription est `past_due` ou `unpaid`;
  - le helper remonte aussi le statut de la derniere facture Stripe et `amount_remaining` afin de confirmer un retour portail seulement quand la facture est payee ou soldee.
- [x] Invariants:
  - aucune migration SQL;
  - pas de table dediee aux incidents Stripe;
  - le champ Stripe de rattachement reste `asset_stripe_productId`;
  - `id_etat=1` reste hors V1 car le cron l'annule ensuite en `id_etat=10`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-29 — Quiz V1: etat simplifie sans runtime `running`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Correctif livre:
  - pour `Cotton Quiz V1` (`id_type_produit=1`), `app_session_edit_state_get(...)` ne fabrique plus d'etat `running` a partir de la date;
  - une session V1 non archivee par date reste `pending`;
  - une session V1 archivee par date devient `terminated`;
  - la fiche detail PRO ne doit donc plus afficher `Session en cours` pour une V1 sur la seule base de la date.
- [x] Invariants:
  - aucun changement pour les produits runtime `3/4/5/6`;
  - le fallback historique V1 reste base sur la date, faute de runtime fiable;
  - les regles d'archives existantes restent portees par `app_session_is_archive(...)`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `git -C /home/romain/Cotton/global diff --check`

## PATCH 2026-04-27 — Cotton Quiz V2: anti-rejeu papier et visuels par `lot_ids`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - le controle anti-rejeu des questions papier ne consultait que les tables historiques `quizs`, `quizs_series`, `quizs_series_to_questions`;
  - les sessions `Quiz V2` stockent leur composition dans `championnats_sessions.lot_ids`, avec les questions des lots temporaires dans `questions_lots_temp.question_ids`;
  - la borne future legacy excluait les sessions au-dela de `+350j`, pas les sessions a venir dans la fenetre utile;
  - le visuel des cartes pouvait encore etre resolu via les anciennes series legacy, ce qui faisait remonter un visuel de lot sans rapport ou le fallback malgre un lot `L...` illustre.
- [x] Correctif livre:
  - `qz_temp_ctx_init(...)` accepte maintenant un `session_id` et une fenetre configurable;
  - les exclusions couvrent les sessions passees et futures dans une fenetre symetrique;
  - les lots temporaires `T...` des sessions V2 voisines sont lus via `questions_lots_temp` et ajoutes aux questions exclues;
  - la construction papier tente des fenetres de repli `350`, `300`, `240`, `180`, `120`, `60` jours jusqu'a obtenir les trois lots temporaires complets;
  - ajout de helpers de visuel par lot/session V2 pour selectionner uniquement les visuels custom des lots `L...`, avec fallback propre sur `default_cotton_quiz.jpg`;
  - `app_jeu_get_detail(...)` accepte les `lot_ids` de session pour reconstruire les metadonnees et le visuel V2 depuis la vraie composition programmee.
- [x] Addendum prod:
  - `app_cotton_quiz_get_session_visual_src(...)` ne retombe plus sur `app_cotton_quiz_get_series_visual_src(...)` quand `lot_ids` est vide;
  - sans `lot_ids`, un visuel `Quiz V2` renvoie le defaut plutot qu'un visuel legacy potentiellement faux.
- [x] Ajustement regle metier:
  - en presence de plusieurs lots `L...`, le helper selectionne maintenant le dernier `L...` de `lot_ids`;
  - le visuel de ce lot est utilise s'il est custom, sinon le helper renvoie le defaut.
- [x] Nettoyage post-validation:
  - retrait de l'instrumentation temporaire `QUIZ_V2_SESSION_VISUAL_RESOLVE` apres confirmation dev/prod;
  - retour au contrat simple `app_jeu_get_detail(..., $lot_ids)` et `app_cotton_quiz_get_session_visual_src($lot_ids, $id_quiz_client)`.
- [x] Invariants:
  - les lots `L...` ne sont pas inspectes pour exclure leurs questions lors de la generation `T...`, car le generateur temporaire ne selectionne que des `questions.id_lot = 0`;
  - les lots `T...` ne sont pas candidats au visuel de session;
  - aucune generation incomplete n'est acceptee.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `git diff --check`

## PATCH 2026-04-17 — Leaderboards quiz legacy: rang de session recalcule depuis les scores
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - references relues:
    - `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
    - `global/web/app/modules/jeux/sessions/app_sessions_functions_20250521.php`
- [x] Cause confirmee:
  - l'agregat `Mes joueurs` quiz legacy attribuait encore ses points saison via `championnats_resultats.position`;
  - pour des sessions legacy recentes, cette colonne est incoherente voire a `1` partout, alors que `equipe_session_points` reste correcte;
  - les fiches session quiz legacy sont donc justes, mais les leaderboards agreges `pro/play/www` deviennent faux.
- [x] Correctif livre:
  - pour les quiz legacy uniquement, le dashboard recalcule maintenant le rang de chaque session a partir de `equipe_session_points`, puis `equipe_quiz_points` en tie-break;
  - le bareme saison conserve le contrat existant `1er 500 / 2e 300 / 3e 200 / participation 100`, sans dependre de `championnats_resultats.position`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-17 — Photos podium player: consentement par upload trace et transactionnel
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependances relues:
    - `games/web/includes/canvas/php/boot_lib.php`
    - `games/web/includes/canvas/sql/2026-04-17_player_podium_photo_consent.sql`
- [x] Besoin retenu:
  - reutiliser le pipeline upload podium existant cote `global`;
  - ajouter une preuve de consentement obligatoire sans transformer un consentement photo en simple flag global de compte.
- [x] Correctif livre:
  - `app_session_results_podium_photo_upload(...)` accepte maintenant un bloc optionnel `consent`;
  - sur succes upload, le helper persiste une preuve dans `championnats_sessions_podium_photos_consents`;
  - addendum 2026-04-17:
    - la persistance de consentement snapshotte maintenant aussi le pseudo/libelle runtime du podium uploadant;
    - l'eligibilite player ne depend plus d'un bridge EP preexistant.
    - la provenance de la photo visible est maintenant relue depuis la trace de consentement (`player` vs `organizer`);
    - si la photo visible provient d'un organisateur, le helper d'acces player la considere comme verrouillee pour le joueur.
  - si l'ecriture de consentement echoue, le media podium nouvellement cree est supprime et la requete echoue.
- [x] Stockage retenu:
  - consentement porte par l'upload, avec lien vers le media et duplication des ids joueur/runtime/bridge utiles a l'audit.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-17 — Libelles joueur partages: prenom only hors pseudo
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - dependance relue:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - les classements agreges reutilisaient encore un helper commun qui retombait sur `prenom + nom` quand aucun pseudo n'etait disponible;
  - resultat: les sessions affichaient deja des libelles courts, mais certains podiums/classements agreges montraient encore le nom de famille.
- [x] Correctif livre:
  - `app_client_joueurs_dashboard_player_label_get(...)` renvoie maintenant:
    - `pseudo` si disponible;
    - sinon `prenom` seul;
    - sinon `Joueur`.
  - les surfaces qui reutilisent ce helper via le socle partage s'alignent donc sur un affichage joueur `prenom-only`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-17 — Ordre des ex aequo aligne sur `games` pour les resultats de session
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - references relues:
    - `quiz/web/server/actions/gameplay.js`
    - `blindtest/web/server/actions/gameplay.js`
- [x] Cause confirmee:
  - les vues `pro` / `play` / `www` rebrassaient encore localement certaines lignes de podium a egalite de rang;
  - cote `quiz` / `blindtest`, le runtime `games` utilise un ordre stable sur les ex aequo base sur `playerId`;
  - cote `global`, les resultats de session modernes ne relisaient pas toujours cette cle runtime stable, et la normalisation de podium pouvait re-trier differemment du classement complet.
- [x] Correctif livre:
  - `app_session_results_get_context(...)` relit maintenant `player_id` des tables runtime `cotton_quiz_players` / `blindtest_players` quand il existe;
  - cette cle devient la cle d'ordre secondaire prioritaire du classement complet, pour coller au comportement `games`;
  - `app_session_results_podium_normalize(...)` preserve maintenant l'ordre source entre ex aequo au lieu de re-trier par libelle.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-16 — Sessions demo: le helper de statut suit de nouveau le runtime reel
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - `app_session_edit_state_get(...)` court-circuitait encore toute session demo avant le calcul metier par type de jeu;
  - le polling `pro` restait donc actif mais sans jamais pouvoir refléter l'etat reel `pending/running/terminated` d'une demo.
- [x] Correctif livre:
  - retrait du `return` anticipe sur `flag_session_demo = 1` dans `app_session_edit_state_get(...)`;
  - les demos suivent a nouveau le meme calcul runtime que les sessions standard selon leur type et leur etat reel;
  - une demo relancee revient donc naturellement a `is_pending = 1` si son runtime est vraiment reinitialise.
- [x] Invariant conserve:
  - aucun changement cote `games` sur le bypass de relance demo.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-16 — QR code place: suppression du `chmod()` serveur-dépendant
- [x] Audit confirme dans:
  - `global/web/app/modules/qr_code/app_qr_code_place_generator.php`
- [x] Cause confirmee:
  - l'initialisation du generateur QR tentait un `chmod()` sur `sys_get_temp_dir() . '/tmp_qr_codes'` quand `is_writable()` echouait;
  - sur certains environnements `dev`, cette operation est interdite, ce qui faisait remonter un warning PHP lors d'un parcours indirect appelant encore le generateur QR.
- [x] Correctif livre:
  - suppression de la tentative de `chmod()`;
  - fallback simple vers `sys_get_temp_dir()` quand le sous-dossier applicatif ne peut pas etre cree ou n'est pas writable.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/qr_code/app_qr_code_place_generator.php`

## PATCH 2026-04-15 — `Mes joueurs`: requetes dashboard alignees sur `app_session_edit_state_get`
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - le dashboard `Mes joueurs` passait a `app_session_edit_state_get(...)` des lignes `championnats_sessions` partielles ne contenant pas `flag_session_demo`;
  - le helper global lisait encore cet index sans garde, ce qui provoquait des notices PHP repetitives sur `GET /extranet/players?async=1`.
- [x] Correctif livre:
  - ajout de `flag_session_demo` dans les deux requetes source du dashboard (`period_has_leaderboard_data` et `context_compute`);
  - durcissement de `app_session_edit_state_get(...)` pour retomber sur `0` si le detail session fourni est partiel.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-15 — `Mes joueurs`: garde `Bingo` quand une playlist client n'existe plus
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - certaines sessions `Bingo Musical` arrivent encore avec un `id_produit` dont la ligne `jeux_bingo_musical_playlists_clients` n'existe plus ou n'est plus relisible;
  - le helper `app_jeu_get_detail()` dereferencait alors sans garde la playlist client puis son catalogue, ce qui finissait en fatal via `module_get_detail()`.
- [x] Correctif livre:
  - le chemin `type 3/6` de `app_jeu_get_detail()` verifie maintenant d'abord la presence effective de la playlist client;
  - le catalogue playlist, le format et `flag_controle_numerique` sont ensuite relus de facon defensive avec fallback vide / `0`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-15 — Photos podium `pro` / `play`: fallback `prod` en environnement `dev`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - le helper de resolution photo podium privilegiait encore l'URL `www dev` quand le fichier etait absent localement, ce qui ne permettait pas de reutiliser en dev une photo publiee uniquement sur l'environnement `prod`.
- [x] Correctif livre:
  - en `dev`, pour les stockages podium publics `www` / `cotton-quiz` / `cotton_quiz`, le fallback URL choisit maintenant d'abord `www_url['prod']`;
  - cela aligne `pro` / `play` sur le confort de verification deja utilise cote FO.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-15 — `Mes joueurs`: alias photo podium renforces pour participants renommes
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause complementaire confirmee:
  - certains chemins runtime `quiz` / `blindtest` / `bingo` sortaient encore avant d'enregistrer l'ancien `username` comme alias sessionnel quand une liaison `games_connectees` existait deja;
  - le fallback `quiz legacy results` attribuait bien les points, mais ne contribuait pas au dictionnaire `label session -> identity` reutilise pour retrouver les photos podium archivees.
- [x] Correctif livre:
  - enregistrement de l'alias brut `username` avant les `continue` runtime lies aux bridges;
  - ajout de l'alias sessionnel dans le chemin `quiz legacy results`;
  - consolidation du helper de podium agrege pour sortir completement une ligne une fois sa photo resolue par identite.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-15 — `Mes joueurs`: podium agrégé de saison enrichi avec la dernière photo podium disponible
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - dependance relue:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livre:
  - le contexte leaderboard de `Mes joueurs` expose maintenant aussi `players_podium` / `teams_podium`;
  - ces lignes podium reprennent le top 3 agrégé de la saison en conservant score, rang et identité;
  - pour chaque participant ou equipe du podium, le socle relit les sessions classées de la période et reutilise la dernière `photo_src` disponible dans les podiums de sessions déjà archivées;
  - la resolution photo ne depend plus seulement du libelle courant: si un pseudo/nom a change en cours de saison, le rapprochement priorise maintenant l'identite metier sessionnelle pour retrouver la photo historique correspondante;
  - addendum 2026-04-15:
    - les branches runtime `quiz`, `blindtest`, `bingo` et la source `quiz teams` enregistrent maintenant aussi explicitement leurs alias `label session -> identity`;
    - le podium de saison peut donc recroiser les photos meme quand le label historique n'etait connu que dans les tables runtime.
  - si aucune photo n'est trouvée, la ligne podium reste exploitable sans image.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-15 — Photos podium sessions: `play` relit maintenant le stockage public `www`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependances relues:
    - `play/web/config.php`
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
    - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- [x] Cause confirmee:
  - le helper global `app_session_results_podium_photo_src_from_media(...)` calculait ses chemins et URLs depuis `upload_path` / `upload_root` du front appelant;
  - en `play`, ces bases ne pointent pas proprement vers le stockage public `www` des photos podium de session;
  - resultat: la fiche detail `play` pouvait recevoir une URL photo non resolue ou basee sur une mauvaise racine, alors que `pro` affichait bien la photo.
- [x] Correctif livre:
  - les photos podium publiques (`www`, `cotton-quiz`, `cotton_quiz`) se resolvent maintenant explicitement via `www_root` / `www_url`;
  - la verification locale, l'URL finale et le log de fallback utilisent donc la meme racine publique quel que soit le front appelant.
  - addendum 2026-04-15:
    - le fallback `dev` respecte maintenant d'abord `www_url[$conf['server']]`;
    - le repli vers `www_url['prod']` ne se fait plus que si l'environnement courant n'a pas de racine publique `www` disponible.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-13 — Podium sessions: priorité des photos historiques `Quiz V1`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - la lecture des photos podium essayait d'abord les stockages modernes par rang / ligne avant le fallback historique `cotton-quiz/championnats/resultats`;
  - sur les sessions `Quiz V1`, cela pouvait masquer les photos historiques deja associees aux resultats legacy.
- [x] Correctif livre:
  - pour `game_key = quiz_legacy`, la lecture des photos repasse maintenant d'abord par le stockage historique attache au resultat legacy;
  - les stockages modernes par rang / ligne restent utilises uniquement en fallback si aucune photo historique n'est retrouvee.
  - en plus, le fallback legacy couvre maintenant aussi plusieurs conventions d'emplacement / nommage historiques autour de `championnats/resultats`, avec recherche directe d'un fichier `id_resultat.(jpg|jpeg|png|webp)` si le media legacy existe mal ou pointe sur un chemin devenu obsolete.
  - le helper d'URL accepte aussi a nouveau l'ancien schema de repertoire `u/t` (ex. `cotton-quiz/championnats/resultats`) quand le chemin migre sans `$u` ne resolve pas le fichier.
  - la resolution relit maintenant aussi les vrais champs `a/u/t/m` du media en base quand un `media_id` est disponible, puis teste les variantes legacy `-/_` avant de retomber sur une URL par defaut.
  - en environnement `dev`, si une photo historique publique n'existe pas localement mais reste attendue cote `www`, l'URL retombe maintenant sur la racine publique `www_url['prod']` au lieu de reutiliser par erreur le domaine du contexte appelant (`pro`, etc.).
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-13 — Fiche session: message de classement aligné avec le fallback Bingo legacy `2/3`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - la fiche detail de session testait uniquement `session_edit_state['is_terminated']` pour choisir le message de classement manquant;
  - pour certaines sessions Bingo legacy `2/3` considerees historiques via fallback date, on affichait donc encore a tort `Cette session n'a pas été jouée jusqu'au bout`.
- [x] Correctif livre:
  - le helper de message traite maintenant les Bingos legacy `2/3` passes en date comme des sessions historiquement terminees au sens du fallback;
  - dans ce cas, la fiche detail bascule sur un message d'absence de classement exploitable, au lieu du message `pas jouée jusqu'au bout`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-13 — `Mes joueurs`: le Bingo legacy type `2` rentre dans l'historique utile, avec fallback date sur `2/3`
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - dependance relue:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - le type produit `2` correspond au Bingo legacy mais etait encore exclu du moteur `Mes joueurs`;
  - le besoin metier retenu est d'inclure ce legacy Bingo dans `Archives` / `Mes joueurs`, avec un fallback par date passee pour les types `2/3`, y compris sur les sessions numeriques.
- [x] Correctif livre:
  - le mapping jeu rattache maintenant aussi `id_type_produit = 2` a `Bingo Musical`;
  - les requetes source `Mes joueurs` / detection de periodes incluent maintenant le type `2`;
  - le helper de terminaison historique applique maintenant un fallback par date passee pour les sessions Bingo `2/3`, qu'elles soient papier ou numeriques;
  - le type `6` reste hors de ce fallback et doit etre reellement termine runtime.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-13 — `Mes joueurs` / `Archives`: le fallback Bingo papier n'est plus autorisé sur le type `6`
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause confirmee:
  - le fallback legacy ajoute pour preserver certains vieux Bingos papier etait applique a tous les Bingos papier `id_type_produit IN (3,6)`;
  - consequence: des sessions papier recentes de type `6`, passees en date mais non reellement terminees runtime, pouvaient remonter dans `Archives` et entrer dans les agregats `Mes joueurs`.
- [x] Correctif livre:
  - le fallback par date sur session papier est maintenant borne au seul Bingo legacy `id_type_produit = 3`;
  - les sessions Bingo papier type `6` doivent desormais etre reellement terminees pour remonter dans l'historique utile.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-13 — `Mes joueurs`: le selecteur de periodes oubliait la `date` des Quiz legacy
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause confirmee:
  - la synthese `Mes joueurs` charge les sessions avec `date` et compte donc correctement les sessions `Quiz V1` legacy;
  - le helper `app_client_joueurs_dashboard_period_has_leaderboard_data()` ne selectionnait en revanche que `id`, `id_securite`, `id_type_produit`, `id_produit`;
  - or `app_client_joueurs_dashboard_session_is_reliably_terminated()` a besoin de `date` pour considerer un `id_type_produit = 1` comme termine;
  - resultat: les sessions `Quiz V1` etaient visibles dans la synthese mais exclues du selecteur d'annees / saisons.
- [x] Correctif livre:
  - la requete source du helper de periodes charge maintenant aussi `date` et `flag_controle_numerique`, comme le moteur principal de synthese / classement;
  - les periodes contenant uniquement du `Quiz V1` legacy peuvent donc de nouveau etre reconnues comme eligibles.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-13 — `Mes joueurs`: rollback de l'hypothese erronée sur `id_type_produit = 2`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause confirmee:
  - l'hypothese precedente etait fausse: `id_type_produit = 2` correspond au Bingo legacy, pas a `Cotton Quiz`;
  - l'extension de couverture Quiz vers le type `2` etait donc incorrecte et devait etre retiree du moteur `Mes joueurs`.
- [x] Correctif livre:
  - rollback des elargissements Quiz `id_type_produit = 2` dans le mapping jeu, la detection des periodes, le filtrage des sessions et les requetes leaderboard;
  - invalidation du cache `Mes joueurs` via une nouvelle version pour purger tout contexte reconstruit sur cette mauvaise hypothese.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-13 — Historique EC / `Mes joueurs`: Bingo privilégie la vraie fin runtime avec fallback legacy borné
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - dependances relues:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
- [x] Cause confirmee:
  - le moteur partage `app_client_joueurs_dashboard_session_is_reliably_terminated()` traitait encore `Bingo Musical` comme historiquement termine des que `date < today`;
  - l'onglet `Archives` EC reutilisait bien ce moteur, ce qui permettait a une session bingo passee mais non terminee de rester visible si elle avait des participants.
- [x] Correctif livre:
  - `Bingo Musical` repasse maintenant par `app_session_edit_state_get()` comme les autres jeux modernes;
  - si le runtime Bingo est encore disponible, seule une vraie fin runtime valide la session historique;
  - pour les sessions Bingo papier, un fallback legacy par date reste autorise meme si la ligne playlist existe encore mais n'a jamais remonte de fin runtime exploitable;
  - pour les sessions Bingo numeriques, le fallback legacy par date n'est utilise que si la ligne `jeux_bingo_musical_playlists_clients` n'est plus exploitable;
  - le filtre participants reels continue de ne s'appliquer qu'aux sessions numeriques, ce qui preserve les vieux Bingos papier;
  - l'agenda `Archives` EC et `Mes joueurs` restent alignes sur le meme contrat metier.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-13 — Upload podium mobile: premier vrai fichier + orientation EXIF JPEG
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/lib/core/lib_core_upload_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Cause confirmee:
  - le write path podium relisait historiquement `files_img[0]`, ce qui cassait les formulaires mobiles embarquant plusieurs inputs homonymes;
  - le pipeline upload image commun ne normalisait pas l'orientation EXIF des JPEG avant resize/crop.
- [x] Correctif livre:
  - la selection de photo podium isole maintenant le premier fichier effectivement present dans le payload upload;
  - le helper upload commun applique maintenant une normalisation EXIF sur les JPEG avant traitement d'image.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/global/web/lib/core/lib_core_upload_functions.php`

## PATCH 2026-04-13 — Direct access EC: le token n'est plus cassé par un scan QR mobile
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
- [x] Cause confirmee:
  - le lien temporaire `client_contact_direct_access` etait invalidé au premier hit;
  - certains scanners QR mobiles prechargent ou previsualisent l'URL avant la vraie ouverture navigateur, ce qui rendait ensuite le lien `invalide` a l'auth.
- [x] Correctif livre:
  - la consommation du lien direct EC ne vide plus immediatement `pwd_token` / `pwd_token_date`;
  - le lien reste donc reutilisable pendant sa fenetre de validite au lieu d'etre single-use au premier scan.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`

## PATCH 2026-04-11 — Photos podium session: support des ex aequo avec medias distincts
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependances relues:
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
    - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- [x] Cause confirmee:
  - la lecture et l'ecriture des photos podium dediees reposaient exclusivement sur `rank`;
  - une photo `rank:1` etait donc partagee par toutes les lignes `#1` du podium, meme en cas d'egalite.
- [x] Correctif livre:
  - ajout d'une cle stable de ligne de podium (`photo_row_key`) rattachee au contexte de resultats;
  - lecture prioritaire d'un media dedie `row:<photo_row_key>`;
  - fallback conserve sur `rank:X` pour les photos historiques et les rangs sans photo individualisee;
  - `Bingo Musical` enrichit aussi ses lignes podium avec `id` joueur quand il est disponible, pour stabiliser la cle cote runtime.
- [x] Portee:
  - aucun schema DB nouveau;
  - aucune migration de medias existants requise.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-10 — Détection `dev` élargie dans `global_config`
- [x] Correctif livré dans:
  - `global/web/global_config.php`
  - `global/web/global_config.template.php`
- [x] Cause confirmée:
  - le bootstrap Stripe charge désormais `global_config.php` même pour des flows appelés depuis `pro.dev`;
  - la détection historique ne considérait `dev` que pour `global.dev.cotton-quiz.com`;
  - conséquence: un appel depuis `pro.dev.cotton-quiz.com` chargeait bien `global_config.php`, mais avec `server=prod`.
- [x] Correctif:
  - la détection d'environnement considère désormais tout host `*.dev.cotton-quiz.com` comme `dev`;
  - cela réaligne les clés Stripe runtime avec le domaine appelant `pro.dev`.
- [x] Portée:
  - évite l'usage accidentel des clés live dans des flows Stripe déclenchés depuis `pro.dev`.

## PATCH 2026-04-10 — Bootstrap runtime `global_config.php` depuis le SDK Stripe
- [x] Correctif livré dans:
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- [x] Cause confirmée:
  - certains contextes d'exécution Stripe utilisaient `stripe_sdk_functions.php` sans que `$conf` ait été initialisé auparavant;
  - d'autres contextes avaient déjà un `$conf` partiel (`server`, etc.) mais sans buckets Stripe;
  - conséquence: les helpers Stripe ne voyaient pas `stripe_private_api_key` et retombaient systématiquement sur les fallbacks hardcodés.
- [x] Correctif:
  - le SDK Stripe tente maintenant de charger `global_config.php` (puis `global_config.local.php`) si `$conf` n'est pas encore disponible;
  - le bootstrap ne s'arrête plus sur un simple `$conf` non vide; il exige désormais la présence d'au moins un bucket Stripe runtime pour considérer la config comme chargée;
  - un log de bootstrap précise:
    - `loaded=/.../global_config.php`
    - ou `no_runtime_config_found`
- [x] Portée:
  - sécurise les contextes historiques qui incluent directement le SDK sans bootstrap global complet.

## PATCH 2026-04-10 — Debug transitoire source config Stripe (`global_config` vs fallback)
- [x] Instrumentation temporaire ajoutée dans:
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- [x] Objectif:
  - confirmer en `dev` que les secrets Stripe sont bien lus depuis `global_config.php`
  - avant suppression définitive des fallbacks hardcodés.
- [x] Détail:
  - `lib_Stripe_getConfigValue(...)` journalise maintenant:
    - `key`
    - `server`
    - `source=global_config|fallback`
  - uniquement au moment où une valeur Stripe est effectivement résolue.
- [x] Statut:
  - patch de diagnostic uniquement;
  - retiré après vérification runtime concluante.

## PATCH 2026-04-10 — Secrets Stripe: lecture via `global_config` avec fallback transitoire
- [x] Correctif livré dans:
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
  - `global/web/global_config.template.php`
- [x] Objectif:
  - sortir progressivement les secrets Stripe du code versionné;
  - permettre une première bascule `dev` via `global_config.php` avant rotation des clés.
- [x] Détail:
  - `lib_Stripe_getPublicApiKey()` lit désormais `$conf['stripe_public_api_key'][$conf['server']]` en priorité;
  - `lib_Stripe_getPrivateApiKey()` lit désormais `$conf['stripe_private_api_key'][$conf['server']]` en priorité;
  - `lib_Stripe_getPrivateStripeSignatureKey()` lit désormais `$conf['stripe_webhook_secret'][$conf['server']]` en priorité;
  - les anciens fallbacks hardcodés ont été supprimés après validation runtime en `dev`.
- [x] Template:
  - `global/web/global_config.template.php` documente maintenant:
    - `stripe_public_api_key`
    - `stripe_private_api_key`
    - `stripe_webhook_secret`
- [x] Note:
  - aucun `global_config.php` runtime n'est présent dans ce workspace; la mise à jour des vraies valeurs hors git reste à faire sur les environnements concernés.

## PATCH 2026-04-10 — Portail Stripe affilié TdR prod: mapping prod aligné sur la config existante
- [x] Audit confirme dans:
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le runtime prod ne résolvait aucune configuration pour `network_affiliate_cancel_end_of_period`;
  - le debug a confirmé:
    - `env_id=`
    - `env_legacy=`
    - `server_id=`
    - `server_legacy=`
  - Stripe prod expose pourtant une configuration portail existante:
    - `bpc_1RLnEWLP3aHcgkSEBUxGEXa0`
- [x] Correctif livré:
  - le mapping `prod` référence maintenant:
    - `network` => `bpc_1TKulJLP3aHcgkSEn8CdQlt1`
    - `network_affiliate_cancel_end_of_period` => `bpc_1TKulJLP3aHcgkSEn8CdQlt1`
    - `network_affiliate` => `bpc_1TKh9GLP3aHcgkSEMUKlR85t`
    - `network_affiliate_cancel_immediate` => `bpc_1TKh9GLP3aHcgkSEMUKlR85t`
- [x] Portée:
  - rétablit l'ouverture du portail TdR affilié sur le flow `cancel_end_of_period` avec une configuration prod dédiée, séparée du portail standard;
  - rétablit aussi les flows affiliés `immediate` avec une configuration Stripe prod dédiée.
- [x] Statut:
  - instrumentation de debug retirée après confirmation.

## PATCH 2026-04-10 — Audit TdR délégué: piste `Remises 2026` écartée
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - dependance relue:
    - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- [x] Constat confirme:
  - les TdR sont volontairement exclus du scope `Remises 2026`;
  - cette exclusion est cohérente avec le contrat métier, car les remises réseau sont gérées séparément;
  - aucune correction fonctionnelle n'a donc été conservée sur ce point.
- [x] Statut:
  - fausse piste documentée puis annulée;
  - le sujet restant à auditer est bien la chaîne TdR/réseau propre, pas le moteur `Remises 2026`.

## PATCH 2026-04-09 — Photos podium session: URL versionnee pour le remplacement
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Cause confirmee:
  - le remplacement d'une photo podium reecrivait le meme nom de fichier par session/rang;
  - la fiche `pro` pouvait donc relire une URL identique et conserver l'ancienne image via cache navigateur.
- [x] Correctif livre:
  - l'URL resolue des photos podium dediees porte maintenant un suffixe `?v=...`;
  - la version est derivee prioritairement de `date_maj`, puis `date_ajout`, puis `id` media;
  - le fallback de lecture reste inchange quand le mount upload n'est pas visible localement.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

> Invariants V1 a proteger dans `app_ecommerce_functions.php`: aucune auto-creation d'offre support `Abonnement reseau`; aucun write path runtime ne doit fabriquer `En attente` sur simple lecture; aucune propagation de fin support vers les delegations `hors_cadre`; aucun auto-reclassement `hors_cadre -> cadre`; aucune logique de remplacement manuel / upsell / downsell comme verite finale des delegations `hors_cadre`.

## PATCH 2026-04-09 — Historique agenda: helper global aligne sur les filtres `Mes joueurs`
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
- [x] Correctif livre:
  - `global` expose maintenant un helper `app_client_joueurs_dashboard_session_is_history_useful(...)` pour qualifier une session passee avec le meme contrat metier que `Mes joueurs`;
  - le helper compose:
    - verification `session reellement terminee`;
    - conservation des sessions papier meme sans participation remontee;
    - exigence d'au moins une participation reelle fiable pour les sessions numeriques.
- [x] Sources de participation reprises:
  - `Cotton Quiz`: `equipes_to_championnats_sessions`, runtime `cotton_quiz_players`, fallback legacy `championnats_resultats`;
  - `Blind Test`: bridge consomme `championnats_sessions_participations_games_connectees.date_consumed IS NOT NULL`, puis runtime `blindtest_players`;
  - `Bingo Musical`: runtime `bingo_players`, puis fallback legacy `jeux_bingo_musical_grids_clients` non demo avec `id_joueur > 0`.
- [x] Portee:
  - l'objectif est d'eviter que l'agenda historique EC montre des sessions numeriques sans valeur metier alors que `Mes joueurs` les ecarte deja de ses syntheses.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-13 — Compat sessions liste/archive: alias `id` expose aussi par `app_sessions_get_liste(...)`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependances relues:
    - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause confirmee:
  - le helper archive `app_client_joueurs_dashboard_session_is_history_useful(...)` attend une cle `id`;
  - `app_sessions_get_liste(...)` ne remontait ici que `id_championnat_session`, ce qui faisait tomber toutes les lignes a `session_id <= 0` dans certains consumers `www`.
- [x] Correctif livre:
  - `app_sessions_get_liste(...)` expose maintenant aussi `cs.id AS id`, en plus de `id_championnat_session`;
  - les consumers qui reutilisent les helpers archive/metier sur cette liste retrouvent donc un identifiant session compatible sans remapping local.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-09 — Helper centralise des résultats finaux de session et des photos podium pour l'EC
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependances relues:
    - `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
    - `quiz/web/server/actions/gameplay.js`
    - `blindtest/web/server/actions/gameplay.js`
    - `bingo.game/ws/bingo_server.js`
    - `games/web/includes/canvas/core/canvas_display.js`
    - `games/web/includes/canvas/php/quiz_adapter_glue.php`
    - `games/web/includes/canvas/php/blindtest_adapter_glue.php`
    - `games/web/includes/canvas/php/bingo_adapter_glue.php`
- [x] Sources de verite relues:
  - `Cotton Quiz` legacy: `championnats_resultats` via `cotton_quiz_get_classement_session(...)`;
  - `Cotton Quiz` runtime: `cotton_quiz_sessions.podium_json` + `cotton_quiz_players`;
  - `Blind Test` runtime: `blindtest_sessions.podium_json` + `blindtest_players`;
  - `Bingo Musical`: `bingo_phase_winners` (+ labels `bingo_players`).
- [x] Regles centralisees:
  - `Cotton Quiz` runtime / `Blind Test`:
    - tri score descendant;
    - tie-break stable par id joueur DB ascendant;
    - rang competition `1, 1, 3, 4...`, aligne sur les WS games;
  - `Bingo Musical`:
    - aucun classement complet numerique n'est reconstruit;
    - les distinctions de phase alimentent le podium;
    - la lecture `bingo_players` fournit la liste historisee des joueurs affichee cote EC, sans filtre limite aux actifs live.
- [x] Fallbacks centralises:
  - session non terminee -> message explicite `pas jouee jusqu'au bout`;
  - session terminee sans joueur -> message explicite `Aucun joueur connecté`;
- [x] Compat schema bingo:
  - la lecture de `bingo_players` ne suppose plus la presence de `updated_at`;
  - l'ordre utilise `updated_at`, sinon `created_at`, sinon `id`.
- [x] Portee:
  - helper de lecture des resultats + helper de lecture/ecriture des photos podium session;
  - aucun schema DB nouveau;
  - objectif: eviter un recalcul specifique `pro` et centraliser la consommation de la verite runtime.
- [x] Compteur `Particip.` aligne:
  - avant session, le compteur EC conserve la logique predictive historique;
  - apres session, `app_session_get_participants(...)` relit prioritairement les tables modernes `*_players`;
  - fallback legacy seulement pour les anciens `Bingo Musical` et `Cotton Quiz` sans runtime exploitable;
  - `Cotton Quiz` garde le libelle `equipes`.
- [x] Durcissements legacy `Cotton Quiz`:
  - sans runtime `players`, le compteur post-session lit d'abord le nombre reel de lignes `championnats_resultats`, puis seulement en secours les equipes rattachees a la session;
  - le classement legacy conserve ses rangs historiques mais affiche maintenant le score quiz de session, pas les points agreges de classement general.
- [x] Photos gagnants:
  - ajout d'un stockage dedie par session archivee et rang de podium pour `Cotton Quiz`, `Blind Test` et `Bingo Musical`;
  - fallback de lecture conserve sur le stockage quiz historique `www/images/cotton-quiz/championnats/resultats`;
  - les helpers attachent maintenant la photo resolue directement au contexte podium renvoye a `pro`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-09 — Remises ABN: baseline DB runtime reelle + cause racine prod documentee
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - dependances relues:
    - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
    - `pro/web/ec/ec_webhook_stripe_handler.php`
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
    - `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
    - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
    - `www/web/bo/www/modules/ecommerce/remises/bdd_ecommerce_remises.sql`
- [x] Cause racine prod confirmee:
  - la prod a casse apres merge/deploiement `remises` sur un double ecart:
    - migration SQL incomplete par rapport au schema reel attendu au runtime;
    - fichier PRO `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` non mis a jour lors du deploy;
  - le script `bdd_ecommerce_remises.sql` ne couvre pas a lui seul l'etat reel du lot:
    - il n'ajoute pas toute la baseline runtime relue par `global` / `pro`;
    - il ne doit donc plus etre traite comme migration unique suffisante.
- [x] Baseline DB runtime retenue pour le lot `remises`:
  - `ecommerce_offres_to_clients`:
    - snapshot commercial de checkout via `id_remise`, `prix_reference_ht`, `prix_ht`, `remise_nom`, `remise_pourcentage`
    - orchestration Stripe via `stripe_subscription_schedule_id`
    - `id_remise` doit rester nullable (`NULL` = pas de remise snapshottee)
  - `ecommerce_remises`:
    - regle BO canonique `Remises 2026`
    - ciblage metier via `id_typologie`, `id_pipeline_etat`
    - fenetre de validite checkout via `date_debut_commande`, `date_fin_commande`
    - duree metier via `duree_remise_mois`
  - `ecommerce_remises_to_offres`:
    - rattachement de la regle a l'offre catalogue (`id_offre = 12` pour l'ABN standard)
    - pourcentage commercial porte par `remise_pourcentage`
  - `ecommerce_remises_to_clients`:
    - ciblage manuel explicite d'un client a une regle `Remises 2026`
  - `ecommerce_commandes_lignes`:
    - snapshot facture/commande via `id_remise` et `prix_reference_ht`
  - `ecommerce_stripe_write_guards`:
    - idempotence webhook/session pour creation schedule et creation commande
- [x] Liens fonctionnels retenus:
  - BO `Remises 2026`:
    - ecrit la regle dans `ecommerce_remises`
    - ecrit le rattachement offre dans `ecommerce_remises_to_offres`
    - ecrit le ciblage client manuel dans `ecommerce_remises_to_clients`
  - lecture preview checkout:
    - `app_ecommerce_discount_candidates_get_for_client_offer()`
    - `app_ecommerce_discount_resolve_for_checkout()`
  - checkout Stripe standard:
    - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
    - reset puis snapshot de remise sur `ecommerce_offres_to_clients`
    - injection Stripe via `discounts[coupon]` + metadata de moteur attendu
  - webhook:
    - `pro/web/ec/ec_webhook_stripe_handler.php`
    - creation optionnelle d'un `SubscriptionSchedule` pour les cas mensuels bornes
    - stockage du `schedule_id` sur `ecommerce_offres_to_clients`
  - facture:
    - lecture prioritaire du snapshot commande `ecommerce_commandes_lignes`
    - fallback `offre_client` reserve au secours legacy
- [x] Verification prod relevee pendant l'incident:
  - avant correction, la DB prod pouvait afficher une remise visible dans PRO mais non snapshottee au POST paiement (`id_remise = NULL`, `prix_reference_ht = 0`);
  - apres redeploiement du bon `ec_offres_script.php`, les logs checkout confirment:
    - scope OK
    - winner OK
    - resolution OK
    - `snapshot_saved` avec `id_remise`, `prix_reference_ht` et `prix_ht` remises.

## PATCH 2026-04-08 — E-commerce: la periode en cours d'un ABN annuel ne derive plus d'un ancrage mensuel
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - `app_ecommerce_offre_client_abonnement_periode_get_detail()` reutilisait `app_ecommerce_offre_client_abonnement_periode_en_cours_get_date_debut()` pour toute frequence de paiement;
  - ce helper historique avance toujours l'ancre de periode par pas de `1 mois`;
  - sur un ABN annuel, on obtenait donc un debut de periode mensuel glissant, puis une fin recalculee sur `+1 an -1 jour`.
- [x] Correctif livre:
  - le recalcul de `periode_en_cours` par helper mensuel reste borne aux seuls abonnements mensuels (`id_paiement_frequence = 1`);
  - pour un ABN annuel, l'ancre BDD conservee (`date_facturation_debut` puis `date_debut`) reste la base de lecture tant qu'aucune periode Stripe live exploitable ne la remplace.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-08 — Sessions legacy Quiz V1: une date vide reste bien `pending`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
- [x] Cause confirmee:
  - `app_session_edit_state_get()` utilisait la date legacy V1 telle quelle;
  - une session incomplète avec date vide ou `0000-00-00` pouvait donc sortir de `pending` a tort et etre marquee `locked`.
- [x] Correctif livre:
  - le resolver d'etat traite maintenant une date vide / `0000-00-00` / invalide comme `legacy_date_missing`;
  - ces sessions restent `pending` tant qu'aucune vraie date n'est programmee.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-08 — Branding facture PDF: logo commun sorti de `pro`
- [x] Audit confirme dans:
  - `global/web/assets/branding/pdf/`
  - `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
  - `www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`
- [x] Constat confirme:
  - les PDF facture BO/PRO lisaient encore un logo situe dans `pro/web/ec/images/general/logo/`;
  - ce couplage inter-vhost exposait le BO a des erreurs de lecture de fichier.
- [x] Correctif livre:
  - ajout d'un asset partage `global/web/assets/branding/pdf/cotton-facture-logo.jpg`;
  - BO et PRO pointent maintenant vers cette source commune;
  - l'ancien fichier legacy dans `pro` n'est plus utilise par la facture.
- [x] Verification:
  - presence du fichier `global/web/assets/branding/pdf/cotton-facture-logo.jpg`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`

## PATCH 2026-04-08 — E-commerce: TTC d'affichage aligne sur le montant canonique facture
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Constat confirme:
  - plusieurs read paths Cotton affichaient encore un TTC reconstruit depuis un HT deja arrondi;
  - ce chemin pouvait produire un ecart visible avec Stripe sur une meme commande, par exemple `99,90 € HT -25 %`:
    - HT affiche `74,93 €`
    - TTC Cotton legacy `89,92 €`
    - TTC Stripe attendu `89,91 €`;
  - le snapshot commande legacy calculait aussi `prix_unitaire_ttc` depuis `prix_ht`, au lieu de repartir d'un montant canonique unique.
- [x] Correctif livre:
  - ajout d'helpers centraux montant/centimes + resolver d'affichage e-commerce dans `app_ecommerce_functions.php`;
  - le TTC affiche est maintenant resolu depuis un montant canonique unique:
    - montant Stripe reel si deja snapshotte en commande/facture;
    - sinon montant exact issu du tarif de reference et de la remise, avant arrondi HT d'affichage;
  - le HT reste une vue informative derivee;
  - le snapshot commande `ecommerce_commandes_lignes` n'applique plus le chemin `HT arrondi -> TTC`;
  - le checkout Stripe standard/delegue recalcule maintenant son `unit_amount` depuis ce resolver canonique, plus depuis `get_ttc(prix_ht_arrondi)`;
  - les cartes ABN avec remise BO recalculent aussi leur TTC preview depuis la base TTC canonique, plus depuis le HT remisé arrondi.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - cas reproduit execute:
    - entree `99.90 HT`, remise `25 %`
    - avant `74.93 HT -> 89.92 TTC`
    - apres `74.93 HT -> 89.91 TTC`

## PATCH 2026-04-08 — E-commerce: l'onglet `Offre` n'affiche la remise que si elle couvre encore la periode courante
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Correctif livre:
  - `global` expose maintenant un helper qui relit le snapshot de remise d'une offre et decide si cette remise couvre encore la periode de facturation en cours;
  - la decision se base sur:
    - l'offre snapshottee (`id_remise`, `remise_pourcentage`, `prix_reference_ht`)
    - la duree de regle metier
    - l'ancre de facturation de l'offre
    - la periode courante relue sur l'offre;
  - si la remise n'est plus active pour la periode courante, l'onglet `Offre` reste silencieux;
  - si elle est encore active, `pro` reutilise le meme recap metier que le post-checkout Stripe.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`

## PATCH 2026-04-08 — Remises signup: token public resilient `code` ou `id_securite`
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - le resolver public de remise ne depend plus uniquement du champ `code`;
  - un token de lien peut maintenant etre resolu soit par `ecommerce_remises.code`, soit directement par `ecommerce_remises.id_securite`;
  - cela recolle au pattern historique de token opaque pour les liens signup tout en gardant la compatibilite des anciens codes publics.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-08 — Signup PRO: rattachement auto d'une `Remise 2026` transportee par lien
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - un helper global reconnait maintenant une regle `Remises 2026` transportee par le flux historique `id_remise` en session;
  - lors du signup, une regle `Remises 2026` en mode manuel est rattachee au nouveau compte via `ecommerce_remises_to_clients`;
  - si la remise session n'est pas une `Remise 2026`, le fallback legacy `ecommerce_remises_clients` reste inchangé.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-08 — Remises ABN: recap checkout explicite selon remise/trial
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - ajout d'un helper de wording checkout pour les remises ABN;
  - le helper formule maintenant un recap metier explicite selon:
    - remise limitee sans essai gratuit
    - remise limitee apres essai gratuit
    - remise sans limite
    - cas annuel `< 12 mois` relu comme `premiere echeance annuelle`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-08 — Widget ABN: la duree de remise n'est plus affichee avant Stripe
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- [x] Correctif livre:
  - le badge de remise BO sur `Tarifs & commande` n'affiche plus la duree d'application;
  - le pourcentage et le prix barre restent visibles;
  - la duree est laissee au recap Stripe au moment du paiement.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`

## PATCH 2026-04-08 — Stripe customer stale en dev: invalidation auto + recreation dans l'environnement courant
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- [x] Cause confirmee:
  - certains clients de `dev` portent un `asset_stripe_customerId` historise sur un autre environnement Stripe;
  - le checkout standard reutilisait cet id tel quel, ce qui bloquait `Checkout Session` sur `No such customer`.
- [x] Correctif livre:
  - `app_ecommerce_stripe_customer_ensure_for_client(...)` verifie maintenant le `customer` Stripe stocke avant de le reutiliser;
  - si Stripe repond `No such customer`, l'id local est vide puis un nouveau customer est recree dans l'environnement courant;
  - le checkout standard passe maintenant systematiquement par ce helper au lieu de faire confiance aveuglement a `clients.asset_stripe_customerId`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`

## PATCH 2026-04-08 — Remises 2026: duree BO + arbitrage coupon/schedule + exception annuelle
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- [x] Correctif livre:
  - la regle BO de remise ne porte plus une duree Stripe implicite fixe `12 mois`;
  - `global` normalise maintenant une `duree_remise_mois` avec:
    - valeur par defaut `12`
    - borne numerique positive
    - `0/null` interprete comme `sans limite`;
  - le resolver checkout et le resolver preview remontent maintenant:
    - `duree_remise_mois`
    - `duree_remise_label`
    - `is_unlimited`
    - `execution_engine`
    - `schedule_supported`
    - `schedule_blocked_reason`
    - `trial_period_days` / `trial_eligible` sur le path checkout;
  - la decision moteur est maintenant centralisee:
    - duree `sans limite` => `coupon`
    - ABN mensuel avec duree limitee => `schedule`
    - ABN annuel avec duree limitee => `coupon`, sans phasage intra-annuel;
  - exception metier annuelle explicitement codee:
    - si la duree est strictement inferieure a `12 mois`, l'annuel est interprete comme `remise sur la premiere echeance annuelle uniquement`;
    - si la duree est `>= 12 mois`, l'annuel reste sur un chemin simple et stable `coupon`;
    - aucun prorata, aucun mixed interval, aucun schedule annuel complexe n'est introduit;
  - les coupons Stripe `% off` sont maintenant assures par pourcentage + duree:
    - `forever` pour `sans limite`
    - `repeating` pour une duree bornee;
  - la persistance documentaire et runtime est preparee pour:
    - `ecommerce_remises.duree_remise_mois`
    - `ecommerce_offres_to_clients.stripe_subscription_schedule_id`;
  - le helper schedule depuis une subscription Stripe existante:
    - cree un `SubscriptionSchedule` via `from_subscription`
    - reconstruit les phases `trial` puis `discounted` puis `full_price` pour les cas mensuels limites
    - garde `end_behavior=release`
    - laisse la subscription Stripe comme reference principale.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`

## PATCH 2026-04-07 — Remises BO V1 sur checkout ABN standard: resolver unique + snapshot commande
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- [x] Correctif livre:
  - ajout d'un resolver unique de remises BO pour le checkout ABN standard, borne aux regles generiques `ecommerce_remises` + `ecommerce_remises_to_offres` + ciblage explicite `ecommerce_remises_to_clients`;
  - ajout d'un helper de previsualisation sans `offre_client` persistée pour les cartes `Tarifs & commande`, afin de relire la meme remise gagnante avant creation de ligne panier;
  - le scope ABN V1 est borne au runtime periodique moderne:
    - `id_offre = 12`
    - `id_offre_type = 2`
    - `id_paiement_type = 2`;
  - exclusion explicite des contextes reseau uniquement via les gardes prouves du code runtime:
    - `network_delegated_checkout`
    - `id_client_delegation > 0`
    - `clients.id_client_reseau > 0`
    - `app_ecommerce_reseau_support_offer_matches_detail(...)`;
  - ajout du snapshot commercial V1 sur l'offre client:
    - `id_remise`
    - `prix_reference_ht`
    - `prix_ht` final remisé
    - `remise_nom`
    - `remise_pourcentage`;
  - ajout d'un reset de snapshot avant chaque tentative de checkout standard eligible, pour eviter toute derive locale si une tentative precedente avait deja gelé une remise;
  - ajout d'un helper de coupon Stripe `% off` reutilisable par pourcentage, avec retrieve/create defensif et aucun snapshot si le coupon n'est pas garanti;
  - le helper coupon V1 cible maintenant par defaut une duree Stripe de `12 mois` au lieu de `forever`, avec un identifiant coupon versionne pour ne pas reutiliser les anciens coupons permanents deja emis;
  - durcissement du helper Stripe de `Price` catalogue:
    - un `lookup_key` existant n'est plus reutilise aveuglement;
    - le helper revalide maintenant `unit_amount`, devise et periodicite contre le tarif Cotton attendu;
    - si un `Price` actif porte encore la bonne `lookup_key` mais un mauvais montant, un nouveau `Price` conforme est cree avec transfert de `lookup_key`, afin que le checkout reparte sur la bonne base avant coupon;
  - la ligne de commande copie maintenant le snapshot remisé comme source de verite facture:
    - `id_remise`
    - `prix_reference_ht`
    - `prix_unitaire_ht`
    - `remise_*`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`

## PATCH 2026-04-03 — `Mes joueurs`: sessions bingo historiques reintegrees dans la synthese
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause confirmee:
  - la synthese haute `Mes joueurs` relisait, pour `Bingo Musical`, un etat runtime derive de la playlist client;
  - cette playlist pouvant etre reutilisee ou reinitialisee, d'anciennes sessions bingo cessaient alors d'etre vues comme terminees, puis disparaissaient des compteurs de synthese.
- [x] Correctif livre:
  - `app_client_joueurs_dashboard_session_is_reliably_terminated(...)` traite maintenant une session bingo passee comme historique/terminee pour la synthese organisateur;
  - la cle de cache journaliere de synthese est versionnee pour forcer le recalcul apres ce changement.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-04 — Classements agrégés: le podium remplace les `100` points de participation
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livre:
  - les bonus de rang et de phase ne s'ajoutent plus aux `100` points de participation;
  - un `1er / 2e / 3e` rang vaut maintenant `500 / 300 / 200` points au total, et non `600 / 400 / 300`;
  - une simple participation sans podium ni gain de phase reste seule a `100` points.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-04 — Classements historiques: fusion prudente des fallback runtime sur identités DB
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livre:
  - les fallback runtime historiques `runtime:quiz_team:*`, `runtime:blindtest:*` et `runtime:bingo:*` sont maintenant recollés sur une identité DB canonique uniquement si le label normalisé pointe de façon unique vers une identité non-runtime déjà connue dans le contexte du client;
  - la fusion reste donc prudente:
    - priorité absolue aux identités canoniques `team:*` / `ep:*`;
    - aucun merge si plusieurs identités DB différentes partagent le même libellé normalisé;
  - effet attendu: les anciens doublons de casse / accents / ponctuation entre runtime et DB sont absorbés sans fusion agressive des vrais homonymes.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-04 — `Mes classements`: ne retenir que les trimestres réellement acceptés par l'organisateur
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livre:
  - `app_joueur_leaderboards_get_context(...)` ne valide plus un trimestre `courant` ou `precedent` sur la seule base de l'historique joueur lie;
  - chaque trimestre candidat est maintenant revalide via `app_client_joueurs_dashboard_get_context(...)`;
  - si le moteur organisateur retombe sur un autre trimestre, le candidat est rejete et le helper essaie la periode suivante;
  - la section joueur est ignoree si aucun des deux trimestres `courant / precedent` n'est reellement exploitable cote organisateur.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-04 — Dashboard classements: compteurs de sessions + liste complete
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livre:
  - le moteur organisateur `app_client_joueurs_dashboard_get_context(...)` remonte maintenant, par jeu, les compteurs `sessions retenues pour le classement` et `sessions de la saison filtree`;
  - le helper expose aussi la liste complete triee (`players_full` / `teams_full`) en plus du `top 10`, pour permettre un toggle front sans recalcul divergent;
  - le helper joueur `app_joueur_leaderboards_highlight_leaderboard_rows(...)` surligne maintenant aussi les lignes de la liste complete, pas seulement celles du `top 10`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-03 — Signup pro: helper global de recherche de compte existant par `email + nom client`
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
  - point d'entree relu:
    - `pro/web/ec/modules/compte/client/ec_client_script.php`
- [x] Cause confirmee:
  - `global` exposait deja un test d'existence de contact par email seul, insuffisant pour distinguer un simple contact existant d'un vrai compte client deja cree sous le meme nom;
  - le signup `pro` n'avait donc aucun helper canonique pour recharger proprement un compte existant sur ce critere metier.
- [x] Correctif livre:
  - ajout de `client_contact_client_find_by_email_and_client_name(...)`;
  - jointure `clients_contacts / clients_contacts_to_clients / clients`;
  - comparaison stricte normalisee `LOWER(TRIM(email))` + `LOWER(TRIM(nom client))`;
  - retour borne a un couple `id_client / id_client_contact` exploitable par le write path `pro`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_script.php` OK

## PATCH 2026-04-02 — Historique joueur EP: sessions reellement terminees seulement
- [x] Objectif:
  - aligner la page `Historique` de l'EP sur la meme notion de session terminee que les classements, tout en conservant une regle simple pour le legacy.
- [x] Correctif livre:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - ajout d'un helper local `app_joueur_historique_session_is_eligible(...)`;
    - regle retenue:
      - `Cotton Quiz` legacy `id_type_produit = 1`: session retenue si `cs.date < CURDATE()`;
      - jeux modernes (`5`, `4`, `3`, `6`): session retenue si `cs.date <= CURDATE()` et `app_session_edit_state_get(...).is_terminated = 1`;
    - filtrage applique dans `app_joueur_participations_reelles_get_liste(...)` avant deduplication des lignes par session;
    - `app_joueur_participations_reelles_latest_date_get(...)` reconsomme maintenant la liste historique effective (sans badges) pour ancrer la fenetre glissante sur la derniere session vraiment affichable.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-02 — Classements saisonniers agreges: sessions runtime terminees seulement
- [x] Objectif:
  - exclure des classements saisonniers agreges `pro` et `play` les sessions encore en cours ou simplement configurees, pour ne garder que les parties reellement terminees.
- [x] Correctif livre:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
    - ajout d'un helper local de garde `app_client_joueurs_dashboard_session_is_reliably_terminated(...)`;
    - le helper reutilise `app_session_edit_state_get(...)` et donc la meme interpretation DB que les `3` jeux runtime:
      - `Bingo Musical`: `phase_courante >= 4`;
      - `Blind Test`: `game_status / phase_courante >= 3`;
      - `Cotton Quiz` moderne: `game_status / phase_courante >= 3`;
    - exception legacy explicite:
      - `Cotton Quiz` legacy `id_type_produit = 1` est retenu si `championnats_sessions.date < CURDATE()` au sens strict;
      - le jour courant est donc exclu, meme pour une session legacy deja passee plus tot dans la journee;
    - filtrage applique a la racine de `app_client_joueurs_dashboard_context_compute(...)`, avant consolidation stats / tops / leaderboards;
    - filtrage applique aussi a `app_client_joueurs_dashboard_period_has_leaderboard_data(...)` pour ne plus ouvrir un trimestre dont aucune session n'est runtime-terminee;
    - consequence assumee: les `3` jeux modernes restent sur une preuve runtime DB, tandis que le legacy garde une heuristique date volontairement plus simple.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-02 — Espace joueur: helper global `Mes classements`
- [x] Objectif:
  - permettre a `play` d'afficher, pour un joueur connecte, les classements organisateur deja existants dans `Mes joueurs`, sans dupliquer leur logique metier.
- [x] Correctif livre:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - ajout d'helpers de mapping `id_type_produit -> game_key`;
    - ajout d'helpers de calcul de trimestre courant / precedent;
    - ajout de `app_joueur_linked_clients_rows_get($id_joueur, $date_start, $date_end)` pour isoler les organisateurs lies au joueur sans passer par l'historique detaille complet;
    - compromis 2026-04-02: ce helper reste volontairement borne aux tables stables EP/bridge et legacy pour identifier les organisateurs lies;
    - les classements affiches ensuite continuent de reposer sur `app_client_joueurs_dashboard_get_context(...)`, donc sur la consolidation organisateur complete moderne / legacy / runtime.
    - ajout de `app_joueur_leaderboards_get_context($id_joueur)`;
    - le helper part maintenant de cette liste legere d'organisateurs lies, plutot que de l'historique reel detaille;
    - il limite les organisateurs a ceux deja lies au joueur;
    - il trie les sections du plus frequente au moins frequente;
    - pour chaque organisateur:
      - trimestre courant si le joueur y a des participations reelles;
      - sinon trimestre precedent;
      - sinon section ignoree;
    - la restitution reconsomme ensuite `app_client_joueurs_dashboard_get_context(...)` pour reutiliser les leaderboards organisateur canoniques;
    - seuls les jeux effectivement joues par le joueur sur le trimestre retenu restent affiches dans chaque section.
    - `app_client_joueurs_dashboard_get_context(...)` remonte maintenant aussi les compteurs podium par ligne (`wins`, `second_places`, `third_places`) a partir des memes attributions de points canoniques que le score agrege;
    - `app_joueur_leaderboards_get_context(...)` somme desormais ces compteurs sur la ligne joueur ou equipe surlignee pour alimenter le recap `Participations / 🏆 / 🥈 / 🥉` sans repartir d'un historique detaille.
    - durcissement des classements agreges organisateur: exclusion des bridges `games_connectees` non consommes (`date_consumed IS NOT NULL`) et des joueurs runtime inactifs (`is_active = 1`) sur `cotton_quiz_players`, `blindtest_players`, `bingo_players`, y compris dans la detection des periodes exploitables et les podiums `bingo_phase_winners`;
    - pour `Cotton Quiz`, une participation d'equipe vaut maintenant aussi participation joueur pour tous les membres lies a cette equipe dans l'historique reel moderne `games_connectees`, afin d'aligner `play` sur la lecture equipe deja retenue cote quiz.
    - rollback 2026-04-02: les relectures runtime `cotton_quiz_players` et `bingo_players` ont ete retirees de l'historique reel joueur pour revenir a un etat stable base sur les sources EP/bridge et legacy.
    - `app_joueur_participations_reelles_get_liste(...)` accepte maintenant un bornage temporel optionnel, `app_joueur_participations_reelles_latest_date_get(...)` expose la derniere activite reelle et `app_joueur_participations_reelles_activity_window_get(...)` factorise la fenetre glissante par defaut;
    - `Historique`, les KPI home et `Mes classements` relisent maintenant par defaut les `12 derniers mois` ancres sur la derniere activite reelle du joueur/equipe, avec extension par paliers de `12 mois` uniquement sur `Historique`.
    - l'instrumentation perf temporaire posee pour diagnostic a ensuite ete retiree; le helper conserve seulement les optimisations de cache request-local et de lecture sans badges.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-01 — Branding: reset session avec cascade conditionnelle sur le branding compte
- [x] Objectif:
  - permettre au reset `games` d'un branding session de supprimer aussi le branding compte par defaut quand il est effectivement identique au design de la session;
  - garantir que les sessions futures deja programmees et encore heritees du branding compte conservent ce design via un snapshot session avant suppression.
- [x] Correctif livre:
  - `global/web/app/modules/general/branding/app_branding_ajax.php`
    - ajout d'un preview `action=delete_preview` pour indiquer au front si le reset session supprimera effectivement un branding compte;
    - ajout d'helpers locaux de comparaison de signature branding (couleurs, police, logo, visuel) avec normalisation d'URL;
    - ajout d'un helper de suppression complete par `id_branding`;
    - ajout d'un helper de gel des sessions futures d'un client quand leur branding effectif est encore `branding_client`;
    - `action=delete` accepte maintenant `cascade_client_branding_if_matching=1`:
      - si la session herite directement du branding compte, ou si son branding session a la meme signature visible que le branding compte;
      - alors les futures sessions du client (`date >= CURDATE()`, hors demo, hors session courante) qui heritent encore de ce branding compte sont dupliquees en branding session;
      - puis le branding compte est supprime;
      - enfin le branding session courant est supprime si present.
- [x] Effet attendu:
  - un reset de design depuis `games` peut retirer le design compte par defaut sans faire perdre ce design aux sessions deja programmees qui l'heritaient encore;
  - les sessions futures non encore figees n'utiliseront plus ce design.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_ajax.php`

## TODO structurant — Branding par type de jeu pour toutes les portees
- [ ] Objectif:
  - permettre un branding borne au type de jeu courant (`quiz`, `blindtest`, `bingo`) pour toutes les portees `session / evenement / reseau / client`, avec fallback retrocompatible vers le branding global existant.
- [ ] Constat:
  - `general_branding` ne stocke aujourd'hui que `id_type_branding + id_related`;
  - les resolvers `app_general_branding_*` et `app_session_branding_get_detail()` n'acceptent pas `id_type_produit`;
  - un branding compte ne peut donc etre que global a tous les jeux.
- [ ] Piste retenue:
  - ajouter `id_type_produit` nullable dans `general_branding`;
  - ajouter un index composite `(id_type_branding, id_related, id_type_produit)`;
  - resoudre d'abord `scope + type de jeu`, puis fallback sur `scope global`.
- [ ] Points d'attention:
  - conserver les lignes actuelles sans `id_type_produit` comme fallback global;
  - figer uniquement les futures sessions du type de jeu concerne lors d'un reset destructif;
  - relire aussi les ecrans `pro` qui editent ou consomment le branding.
- [ ] Reference:
  - `documentation/notes/branding_par_type_de_jeu.md`

## PATCH 2026-04-01 — Sessions: helper global d'historisation effective agenda
- [x] Objectif:
  - permettre a `pro` de traiter une session runtime `terminée` comme `historique`, sans rester strictement dépendant de la date.
- [x] Correctif livré:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - `app_session_edit_state_get()` remonte maintenant aussi `is_terminated` et `runtime_status`;
    - les seuils de fin réutilisent les conventions déjà en place côté `games`:
      - `Cotton Quiz` / `Blind Test`: `game_status >= 3`;
      - `Bingo Musical`: `phase_courante >= 4`;
    - ajout de `app_session_is_archive()` et `app_session_display_chronology_get()` pour fusionner chrono date + état runtime terminé.
    - ajout de `app_client_has_archived_sessions()` pour répondre de facon centralisee si un client a déjà au moins une session archivee non demo et complete.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-03-31 — Dashboard joueurs organisateur: helper global d'agrégation V1
- [x] Objectif:
  - fournir a `pro` une source unique et lisible pour le dashboard `Joueurs`, sans logique metier dispersée dans la vue.
- [x] Correctif livre:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
    - ajout de `app_client_joueurs_dashboard_get_context(...)`;
    - ajout d'helpers locaux de normalisation, de tri et de détection de colonnes runtime;
    - `Membre depuis` base sur la plus ancienne `date_debut` connue dans `ecommerce_offres_to_clients`, avec fallback defensif `clients.date_ajout` si aucune offre n'est historisée;
    - separation des periodes:
      - synthese calculee sur toute la periode d'activite (`member_since -> today`);
      - tops calcules eux aussi sur toute la periode d'activite;
      - filtre applique seulement aux classements, via `annee + trimestre civil`, avec defaut sur le trimestre en cours;
      - la synthese globale est maintenant mise en cache en session par client/jour, et les changements de filtre ne recalculent plus que le scope classements;
      - la detection des periodes exploitables pour les classements est maintenant alignee sur les vraies sources leaderboard, y compris les sources runtime (`cotton_quiz_players`, `blindtest_players`, `bingo_players`) et le fallback legacy `championnats_resultats` pour `Cotton Quiz`;
    - la synthese par jeu expose aussi `Meilleure session`, soit le nb max de participants connectes observes sur une meme session pour le jeu;
    - les classements par jeu sont maintenant tries sur un score agrege fiable:
      - `500 / 300 / 200` points au total pour les rangs `1 / 2 / 3` de session sur `Cotton Quiz` / `Blind Test`;
      - `500 / 300 / 200` points au total pour les gains de phase `Bingo / Double ligne / Ligne` sur `Bingo Musical`;
      - `100` points seulement pour une participation sans podium ni gain de phase;
      - le nb de participations reste affiche en information annexe;
      - pour `Cotton Quiz` historique pre-runtime, les bonus podium sont aussi relus via `championnats_resultats.position`;
      - le classement `Bingo Musical` conserve les sessions runtime scorables de la periode et n'exclut que les sessions historiques sans gagnants de phase recuperables de facon fiable, avec message explicite seulement dans ce cas;
    - sessions filtrées sur la meme regle que le reporting BO: `championnats_sessions.flag_session_demo=0` et `flag_configuration_complete=1`;
    - le compteur de sessions de la synthese est maintenant nuance comme cote reporting BO:
      - les sessions papier non demo et completes restent comptees meme sans participation remontee;
      - les sessions numeriques exigent au moins une participation fiable (`joueur` ou `equipe`) pour etre comptabilisees;
    - la liste `annee + trimestre` du filtre est maintenant derivee des seules periodes qui alimentent reellement les classements, afin de conserver une selection valide au lieu de revenir au defaut;
    - agrégation des participations fiables par jeu a partir de:
      - `championnats_sessions_participations_games_connectees` pour les joueurs EP connectés;
      - `jeux_bingo_musical_grids_clients` pour les joueurs EP bingo historiquement rattachés a une grille réelle;
      - `blindtest_players` et `bingo_players` pour les joueurs runtime non EP connectés;
      - `cotton_quiz_players` pour les équipes runtime quiz;
      - `equipes_to_championnats_sessions` pour les équipes quiz;
    - le compteur principal agrège les participants connectés fiables `joueurs + équipes`;
    - déduplication stricte:
      - une seule participation par identité et par session;
      - priorité a l'identité EP (`ep:<id_joueur>`);
      - fallback runtime borné au pseudo/username normalisé, scoped par jeu;
      - aucun recours a `championnats_sessions_participations_probables`.
- [x] Limites V1 assumées:
  - le quiz ne produit pas de classement joueur: le bridge et le runtime y sont consolidés au niveau équipe;
  - les non-EP ne sont pas fusionnés entre jeux différents.
- [x] UX data vide:
  - message explicite quand aucune donnee exploitable n'est disponible globalement;
  - message explicite quand la periode choisie ne permet ni tops ni classements fiables.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-03-31 — Sessions quiz: garde `papier -> numérique` réalignée sur `games`
- [x] Objectif:
  - supprimer l'écart de règle entre `pro/global` et `games` sur la compatibilité numérique d'un quiz.
- [x] Correctif livré:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - `app_session_quiz_digital_guard_get()` réutilise désormais le même seuil que `games`:
      - passage `papier -> numérique` autorisé dès qu'une question possède sa réponse et au moins une fausse proposition valide distincte;
      - le helper `global` n'exige plus à tort `2` fausses propositions, ce qui provoquait des refus côté `pro` pour des quiz déjà considérés compatibles dans `games`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-03-31 — Sessions: helper commun d'état d'édition pour `pro/games`
- [x] Objectif:
  - fournir une règle métier partagée pour déterminer si une session officielle est encore `En attente` et donc encore modifiable.
- [x] Correctif livré:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - ajout de `app_session_edit_state_get()`;
    - ajout d'un alias explicite `app_session_format_change_guard_get()`;
    - suppression du second bloc dupliqué `app_session_participation_probable_*` qui provoquait un fatal `Cannot redeclare ...` et un 500 côté `pro`;
    - règle centralisée:
      - démo: jamais verrouillée;
      - `bingo` / `blindtest` / `cotton quiz v2`: verrou dès que la phase/runtime n'est plus `0`;
      - `cotton quiz v1`: conservation du garde-fou historique basé sur la date.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-03-30 — Historique joueur EP: badges podium live + gains Bingo
- [x] Objectif:
  - enrichir l'historique réel joueur avec des badges de résultat exploitant le bridge `EP -> games` et les tables temps réel quand elles existent.
- [x] Correctif livré:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - ajout d'helpers `app_joueur_history_*` dédiés au calcul de badges d'historique;
    - enrichissement de `app_joueur_participations_reelles_get_liste()` avec:
      - les identités bridge `game_player_id`, `game_player_key`, `game_slug`;
      - `id_equipe` pour le fallback `quiz_legacy`;
      - un tableau `history_badges` prêt pour l'affichage EP;
    - logique de badges appliquée:
      - `quiz` / `blindtest` live: podium limité au top 3 via les tables temps réel joueurs;
      - `quiz_legacy`: fallback sur `championnats_resultats` au niveau équipe;
      - `bingo`: badges par phases gagnées à partir de `bingo_phase_winners`, avec compat `player_id_key` si la colonne existe.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-30 — Routing EP/games: fallback hors session ouverte
- [x] Objectif:
  - éviter qu'un parcours `games_account_join=1` reboucle vers `games` quand la session n'est pas encore ouverte ou déjà expirée.
- [x] Correctif livré:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - ajout d'un helper de lecture d'état temporel de session pour le routing `games_account_join`;
    - règle explicite de fenêtre d'ouverture:
      - `jour J` = session ouverte;
      - `lendemain de session` = encore ouverte strictement avant `12:00`;
      - sinon = session expirée;
    - session future non ouverte: fallback vers le signalement de participation EP;
    - session expirée/non ouverte: fallback vers l'agenda EP;
    - session ouverte: maintien du pont direct vers `games`.
- [x] Note d'interface:
  - le bypass du gating WS en session papier ne vit pas dans `global`, mais cette règle de routing temporel est bien celle que relisent ensuite `play` et `games`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — Equipes joueur: socle d'invitation email V1 pour EP
- [x] Objectif:
  - réutiliser le socle joueur/token existant pour permettre à `play` d'inviter un joueur par email dans une équipe, avec un template transactionnel dédié.
- [x] Correctif livré:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - ajout de `app_joueur_invitation_token_generer()`;
    - ajout de `app_equipe_joueur_invitation_envoyer()`;
    - la fonction valide l'email, borne l'équipe à `5` joueurs max, empêche les doublons dans l'équipe, crée le joueur si besoin, l'ajoute à l'équipe, puis envoie l'email transactionnel;
    - pour un joueur déjà existant, le CTA mail renvoie vers `signin`;
    - pour un nouveau joueur, la fonction pose `pwd_token` + `flag_invitation=1` et renvoie vers `signin/reset/{token}`.
  - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`
    - ajout du template provisoire `ALL_ALL_PLAYER_TEAM_INVITATION`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`

## PATCH 2026-03-27 — Espace joueur: lecture unifiée de l'historique réel
- [x] Objectif:
  - fournir à `play` une source de lecture unique pour l'historique réel joueur, sans réutiliser les participations probables et avec compat legacy Quiz/Bingo.
- [x] Correctif livré:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - ajout de `app_joueur_participations_reelles_get_liste()`;
    - ajout de `app_joueur_participations_reelles_get_stats()`;
    - source moderne prioritaire: `championnats_sessions_participations_games_connectees`;
    - sources legacy de compat:
      - `equipes_to_championnats_sessions` pour Quiz;
      - `jeux_bingo_musical_grids_clients` pour Bingo;
    - dédoublonnage par session et exclusion explicite des participations probables;
    - calcul des marqueurs home `Top organisateur` et `Top jeu` à partir des fréquences observées dans l'historique réel, avec exposition des ids nécessaires aux filtres agenda `play` (`top_organisateur_id`, `top_game_id_type_produit`).
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — New_EJ: `global` recentre sur le bridge EP
- [x] Objectif:
  - conserver dans `new_ej` uniquement le delta `EP -> games`, sans embarquer des changements de logique sur les helpers historiques joueur/session;
- [x] Correctif livre:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - conservation des helpers `app_joueur_games_bridge_*` et de `games_account_join`;
    - retour a `develop` de `app_joueur_sessions_inscriptions_get_liste()` et `app_joueur_session_inscription_get_detail()`;
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - retour au code `develop` pour `app_session_games_play_get_link()` et `app_jeu_get_detail()`;
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-03-26 — Sessions: `app_jeu_get_detail()` ne lit plus `quiz_detail` hors contrat
- [x] Audit confirmé dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `pro/logs/error_log`
- [x] Correctif livré:
  - initialisation défensive des champs communs `id_format`, `format`, `id_origine`, `id_securite_jeu`;
  - initialisation explicite de `quiz_detail` avant le switch;
  - branche `id_type_produit = 5` rendue tolérante quand `quizs` est absent ou incomplet.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-03-26 — Sessions: pont EP -> games pour les joueurs connectés
- [x] Audit confirmé dans:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `documentation/canon/data/schema/DDL.sql`
  - `documentation/canon/data/schema/MAP.md`
- [x] Correctif livré:
  - ajout des helpers `app_joueur_games_bridge_*` pour préparer un retour court vers `games`;
  - `app_joueur_session_inscription_get_link()` accepte maintenant un contexte moderne `games_account_join`;
  - ajout de la nouvelle table `championnats_sessions_participations_games_connectees`;
  - ajout du SQL d'import phpMyAdmin `documentation/championnats_sessions_participations_games_connectees_phpmyadmin.sql`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-26 — Sessions: nouveau support dédié de participations probables pour `play`
- [x] Audit confirmé dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `documentation/canon/data/schema/DDL.sql`
  - `documentation/canon/data/schema/MAP.md`
- [x] Correctif livré:
  - ajout d'helpers `app_session_participation_probable_*` sur le domaine sessions;
  - les reads joueur `app_joueur_session_inscription_get_detail()` et `app_joueur_sessions_inscriptions_get_liste()` s'appuient maintenant sur `championnats_sessions_participations_probables`;
  - `app_joueur_session_inscription_get_link()` reste borne au parcours historique `play`, hors exception explicite du flux moderne `games_account_join=1`;
  - ajout du SQL d'import phpMyAdmin `documentation/championnats_sessions_participations_probables_phpmyadmin.sql`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## Invariant — synchro hors workspace avant patch évolutif
- Pour toute évolution touchant `global/ai_studio/**`, `global/web/**`, `website/**` ou des scripts/workflows transverses, commencer par consulter le journal global AI Studio (mode raw) afin d’identifier les éléments potentiellement plus à jour sur serveur que dans le workspace local.
- Inclure une demande de recharge depuis les serveurs pour les scripts/dossiers signalés avant audit ou patch : `http://global.cotton-quiz.com/ai_studio/documentation/ai_studio_documentation_view.php?f=0_ROADMAP_journal_travaux.md&mode=raw`
- Ce journal sert de contrôle de synchro et de détection d’écarts ; il ne remplace pas la preuve finale par le code, les fichiers réellement rechargés et la documentation canon.

## PATCH 2026-03-26 — E-commerce: confirmation de commande routee vers AI Studio transactionnel
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_functions.php`
  - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`
  - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_webhook.php`
- [x] Constat confirme:
  - `app_ecommerce_commande_ajouter()` envoyait encore le mail client de confirmation via `lib_Brevo_sendMailFromTemplate(...)` et le template legacy `287`;
  - le bloc etait deja borne metierement a la premiere facture de l'offre et a un sous-ensemble explicite de types d'offre / paiement;
  - le catalogue transactionnel AI Studio expose maintenant `ALL_ALL_INVOICE_MONTHLY`, dont le contenu correspond a une confirmation de commande avec facture disponible;
  - le webhook AI Studio exige `CONTACT_EMAIL` et gere le destinataire reel cote n8n/Brevo, avec BCC de monitoring.
- [x] Correctif livre:
  - l'ancien bloc Brevo direct est conserve en commentaire pour validation transitoire;
  - l'envoi effectif passe maintenant par `ai_studio_email_transactional_send('ALL', 'ALL', 'INVOICE_MONTHLY', ...)`;
  - les variables transmises sont alignees sur le template AI Studio: `CLIENT_NOM`, `CONTACT_PRENOM`, `CONTACT_NOM`, `CONTACT_EMAIL`, `COMMANDE_DATE`, `COMMANDE_OFFRE_NOM`, `COMMANDE_TOTAL_TTC`;
  - les gardes metier historiques du bloc restent inchangees.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-25 — E-commerce Stripe: socle d'idempotence persistante pour les writes commande/facture
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
- [x] Constat confirme:
  - le socle `global` savait deja relire un `stripe_invoice_id` dans `commentaire_facture`, mais pas reserver un write avant creation de commande;
  - aucun helper natif n'existait pour dedoublonner les PAK sur `payment_intent.id` ni les retries bruts sur `event.id`;
  - la fenetre `creation commande -> rattachement token Stripe` restait ouverte aux executions concurrentes.
- [x] Correctif livre:
  - ajout d'une table `ecommerce_stripe_write_guards` creee a la demande, avec unicite par `scope_key + object_id`;
  - ajout d'helpers `claim/complete` + verrou `GET_LOCK` pour piloter proprement les retries webhook sur `invoice.id`, `payment_intent.id` et `event.id`;
  - ajout d'un token `stripe_payment_intent_id` et d'un point d'injection `commentaire_facture` directement dans `app_ecommerce_commande_ajouter(...)`;
  - conservation explicite du point d'extension futur pour `customer.subscription.updated`, sans embarquer ce correctif dans ce lot.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK

## PATCH 2026-03-25 — E-commerce: compatibilite read path contact via `app_client_contact_get_detail()`
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - le flux `app_ecommerce_commande_ajouter()` appelait `app_client_contact_get_detail(...)`;
  - seule la fonction legacy `client_contact_get_detail(...)` etait definie, ce qui provoquait un fatal PHP dans le webhook Stripe au moment de finaliser une commande;
  - la quasi-totalite des call sites historiques `pro` et `global` restent encore en `client_contact_get_detail(...)`, donc un renommage brutal aurait ete plus risqué qu'un alias de compatibilite.
- [x] Correctif livre:
  - ajout d'un alias applicatif `app_client_contact_get_detail(...)` qui delegue au helper legacy existant;
  - harmonisation du second call site e-commerce `global` pour reutiliser ce nommage `app_*`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-24 — E-commerce/Brevo: le socle webhook reste silencieux et tolerant aux moves de liste deja faits
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/assets/sendinblue/api/sendinblue_api_functions.php`
- [x] Constat confirme:
  - le socle commandes ne portait encore aucune ancre native pour relier une commande Cotton a un `invoice.id` Stripe deja traite;
  - les helpers Brevo `lib_*` faisaient encore des `print_r` sur succes et des `echo` en erreur, y compris pour les moves de liste `160 -> 161`;
  - ces sorties parasites pouvaient polluer des flux serveur comme le webhook Stripe, et les erreurs metier `already removed/already in list` n'etaient pas traitees comme des no-op idempotents.
- [x] Correctif livre:
  - ajout d'helpers commandes pour attacher et relire un token `stripe_invoice_id` via `commentaire_facture`;
  - les helpers Brevo `lib_Brevo_sendMailFromTemplate`, `lib_Brevo_createUser`, `lib_Brevo_updateUser` et `lib_Brevo_moveListUser` journalisent maintenant les erreurs sans produire de sortie HTTP;
  - `lib_Brevo_moveListUser` accepte maintenant les cas `already removed` / `already in list` comme etats idempotents.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/assets/sendinblue/api/sendinblue_api_functions.php` OK

## PATCH 2026-03-24 — Branding: le pipeline upload visuel perso respecte la qualite demandee et evite l'upscale
- [x] Audit confirme dans:
  - `global/web/lib/core/lib_core_upload_functions.php`
  - `global/web/app/modules/general/branding/app_branding_ajax.php`
  - `global/web/app/modules/general/branding/app_branding_functions.php`
- [x] Constat confirme:
  - le core image recadrait encore les JPEG avec une qualite forcee a `80`, meme quand une autre qualite etait demandee;
  - le flux branding `games` demandait une cible fixe trop basse puis pouvait encore upscale artificiellement la sortie;
  - le symptome en jeu etait coherent avec un double probleme `compression finale trop forte + cible figee`.
- [x] Correctif livre:
  - `upload_image_recadrer()` respecte maintenant la qualite JPEG demandee et derive correctement la compression PNG;
  - l'endpoint branding `games` demande maintenant une qualite `100` et une cible visuel max `1600x640`;
  - le helper branding adapte la cible effective du `visuel` a la taille source pour eviter de grossir artificiellement une image plus petite.
  - l'endpoint branding retourne maintenant aussi un message d'erreur explicite pour `logo` / `visuel` quand PHP signale un upload trop lourd, partiel ou bloque, ainsi que pour un POST depassant `post_max_size`.
  - le delete branding borne maintenant aussi explicitement la suppression a la portee demandee (`session` ou `client`) quand `id_type_branding` est fourni, au lieu de supprimer la couche effective resolue.
  - si aucun branding n'existe sur cette portee explicite, le delete repond maintenant en no-op reussi au lieu de retomber sur la resolution effective et de pouvoir toucher une couche amont (ex. reseau TdR).
- [x] Effet attendu:
  - le media final branding conserve mieux les aplats et les textes fins;
  - une source `1280x720` ne ressort plus en `1200x480` fige puis potentiellement molle, mais dans une cible adaptee type `1280x512`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/lib/core/lib_core_upload_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_ajax.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_functions.php` OK

## PATCH 2026-03-19 — Reseau TdR: cloture BO support = fermeture reelle des incluses `cadre`
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Constat confirme:
  - le write path BO `modifier -> id_etat=4` passait bien par `app_ecommerce_reseau_support_offer_force_close_from_bo()`;
  - ce helper ne fermait que les incluses encore presentes dans `ecommerce_reseau_contrats_affilies` en `activation_state=active`;
  - une incluse `cadre` encore liee au support par `reseau_id_offre_client_support_source` mais deja desynchronisee de la table d'activations pouvait donc rester active cote SI;
  - ces lignes parasites pouvaient ensuite continuer a polluer la lecture PRO et l'historique TdR.
- [x] Correctif livre:
  - la cloture BO collecte maintenant aussi toutes les delegations actives encore liees au support via `reseau_id_offre_client_support_source`;
  - chaque incluse `cadre` ciblee est fermee en `Terminee`, puis son pipeline affilié est resynchronise;
  - les surfaces TdR `Offres` peuvent maintenant filtrer explicitement ces incluses `cadre` a partir de leur marqueur canonique `reseau_id_offre_client_support_source` et, en secours, du mode d'activation persiste.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-19 — BO support reseau: le champ `Fin` redevient editable
- [x] Audit confirme dans:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
- [x] Constat confirme:
  - le formulaire BO custom de l'`Abonnement reseau` cachait `date_fin` dans un `input hidden`, alors meme que la vue BO masquait aussi cette valeur;
  - cela empechait tout test BO cible sur la date de fin locale d'un support reseau sans passage SQL.
- [x] Correctif livre:
  - le champ `Fin` est maintenant affiche et modifiable dans le formulaire custom BO de l'`Abonnement reseau`;
  - la vue BO de ce support affiche aussi explicitement la date de fin courante.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php` OK

## PATCH 2026-03-19 — BO support reseau: la case `Offert` pilote aussi le rendu front
- [x] Audit confirme dans:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Constat confirme:
  - le formulaire BO custom de l'`Abonnement reseau` cachait `flag_offert`;
  - le write path BO forcait encore `flag_offert = 0` a la creation;
  - le front affichait `OFFERT !` uniquement pour les offres non support reseau, meme si `flag_offert = 1`.
- [x] Correctif livre:
  - la case `Offert` est maintenant visible dans le formulaire BO custom support reseau;
  - la vue BO affiche aussi l'etat `Offert`;
  - le create support BO respecte desormais la valeur postee;
  - le front affiche `OFFERT !` des que `flag_offert = 1`, y compris pour l'`Abonnement reseau`;
  - le controle BO `Offert` utilise maintenant un rendu simple aligne sur le bloc, sans decalage lateral ni zone non cliquable;
  - le formulaire n'embarque plus de champ cache concurrent `flag_offert`, et le script BO reapplique defensivement `date_fin` / `flag_offert` apres le sync support pour eviter toute perte au save.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-19 — BO support reseau: `date_fin` et `flag_offert` persistent enfin au save
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Constat confirme:
  - apres `module_modifier`, le write path BO support relancait `app_ecommerce_reseau_abonnement_bo_sync_offer_client()`;
  - ce helper republiait prix/periode/jauge/quota, mais ne reinjectait ni `date_fin` ni `flag_offert`;
  - consequence: une `date_fin` saisie manuellement pouvait etre perdue dans le recalcul support, et le flag `Offert` ne restait pas fiable entre vue et modification.
- [x] Correctif livre:
  - le sync BO support republie maintenant aussi `date_fin` et `flag_offert`;
  - le script BO normalise ces deux champs avant `module_modifier` et les transmet aussi au helper de sync.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-19 — BO support reseau: activation forcee avec fin planifiee preservee
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Constat confirme:
  - lors du premier save `En attente -> Active`, `app_ecommerce_reseau_support_offer_activate_from_external_write_path()` reinitialisait volontairement `date_fin = '0000-00-00'`;
  - le BO devait pourtant pouvoir forcer une activation sans paiement tout en gardant une fin planifiee pour les tests et les clotures locales.
- [x] Correctif livre:
  - apres la reactivation support depuis le BO, le script reapplique explicitement `id_etat = 3`, `date_fin` et `flag_offert`;
  - le premier save `Active` peut donc maintenant conserver une fin planifiee au lieu de revenir a une activation ouverte sans date.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-19 — BO support reseau: la creation peut vraiment partir en `Active`
- [x] Audit confirme dans:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Constat confirme:
  - en mode `ajouter`, le write path support forcait encore `$_POST['id_etat'] = 2`;
  - apres insertion, il reappliquait a nouveau `id_etat = 2`, ce qui expliquait un affichage final `pending_payment` meme quand le BO demandait explicitement `Active`.
- [x] Correctif livre:
  - la creation support respecte maintenant `id_etat = 3` quand le BO le demande explicitement;
  - apres insertion, le flux BO active aussi le support via le write path dedie puis reapplique `id_etat = 3`, `date_fin` et `flag_offert`.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-19 — Cron support reseau: la fin effective clot aussi les incluses `cadre`
- [x] Audit confirme dans:
  - `www/web/bo/cron_routine_bdd_maj.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - le cron `ABN SANS engagement` passait bien l'offre support reseau en `Terminee`;
  - mais il n'appelait ensuite que `app_ecommerce_reseau_support_offer_transition_finalize()`, qui archivait le runtime contrat sans fermer les offres deleguees incluses `cadre`;
  - le BO manuel `Terminee`, lui, passait par `app_ecommerce_reseau_support_offer_force_close_from_bo()` et fermait correctement ces incluses.
- [x] Correctif livre:
  - `app_ecommerce_reseau_support_offer_transition_finalize()` ferme maintenant aussi les delegations `cadre` actives liees au support courant avant archivage du contrat runtime;
  - la fermeture preserve une `date_fin` deja planifiee si elle existe, sinon pose `CURDATE()`;
  - chaque affilié impacte est resynchronise apres fermeture effective.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-19 — Stripe support reseau: la fin de periode ecrit a nouveau `date_fin`
- [x] Audit confirme dans:
  - `pro/web/ec/ec_webhook_stripe_handler.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - le support reseau devait etre retrouve via `asset_stripe_productId` puis recevoir `date_fin = current_period_end` sur `customer.subscription.updated`;
  - mais un premier `case customer.subscription.updated` consommait deja l'evenement pour la seule sync deleguee, rendant unreachable le write path support declare plus bas;
  - `app_ecommerce_reseau_facturation_refresh()` n'effacait pas ensuite cette date: le blocage etait bien en amont, dans le webhook non pris en compte.
- [x] Correctif livre:
  - le traitement principal `customer.subscription.updated/customer.subscription.deleted` prend maintenant aussi en charge le support reseau;
  - la fin de periode Stripe support renseigne de nouveau `date_fin`, relance le refresh local et planifie les incluses liees;
  - le doublon mort du webhook est retire pour eviter toute regression.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK

## PATCH 2026-03-19 — Reseau TdR: suppression du reclassement implicite au chargement BO
- [x] Audit confirme dans:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - la page BO `reseau_contrats` appelait `app_ecommerce_reseau_contrat_reclassify_delegations()` des l'ouverture de l'ecran;
  - cette chaine pouvait ecrire dans `ecommerce_reseau_contrats_affilies`, `ecommerce_offres_to_clients`, `clients` et `clients_logs` via les helpers de sync/reclassement/facturation/pipeline;
  - aucune preuve explicite ouverte ne justifie un write cache dans une simple lecture BO.
- [x] Correctif livre:
  - suppression de l'appel automatique au chargement de `bo_reseau_contrats_list.php`;
  - les write paths explicites BO restent inchanges, dont l'action manuelle `sync_legacy` si un raccord historique doit encore etre force volontairement.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-19 — Reseau TdR: neutralisation definitive du remplacement delegue `hors_cadre`
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - les helpers legacy `app_ecommerce_reseau_delegated_checkout_context_start_replace()`, `app_ecommerce_reseau_delegated_offer_replace()`, la planification differee et son executeur cron restaient encore presents et atteignables;
  - ce socle contredisait l'invariant V1 `hors_cadre = gestion/résiliation explicite uniquement`, meme si l'UI principale n'exposait plus le bouton.
- [x] Correctif livre:
  - les helpers de remplacement immediat / differe renvoient maintenant `replacement_disabled_v1`;
  - l'execution cron d'un plan legacy le marque en erreur metier `replacement_disabled_v1` au lieu de rebasculer une offre;
  - l'invariant V1 est donc porte par le serveur, pas seulement par le retrait de l'UI.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-17 — Reseau TdR: le hors cadre delegue ne depend plus d'un contrat reseau automatique
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - le contexte d'action affilié et les flows `hors_cadre` explicites continuaient de bloquer sur `network_contract_missing`;
  - l'attachement post-paiement tentait encore d'ecrire une activation reseau meme quand aucune ligne `ecommerce_reseau_contrats` n'existait pour la TdR;
  - cette hypothese n'est plus valide depuis le passage a une offre abonnement reseau facultative.
- [x] Correctif livre:
  - `app_ecommerce_reseau_affiliate_action_context_get()` accepte maintenant un mode `allow_missing_contract` pour les flows `hors_cadre`;
  - le checkout delegue `hors cadre` et l'analyse de contexte d'une offre deleguee payee passent maintenant avec `id_contrat_reseau = 0`;
  - l'attachement post-paiement et l'activation explicite `hors_cadre` n'ecrivent plus d'activation reseau quand aucun contrat n'existe;
  - les flows `included/cadre` gardent leur verrou historique sur un support reseau actif et un contrat resolu.
- [x] Invariant V1 fige:
  - l'absence de contrat reseau ne doit plus servir de pretexte documentaire pour reintroduire un parcours de remplacement `hors_cadre`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-17 — Contenu reseau V1: durcissement schema/write/read sans migration SQL dédiée
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - la persistance V1 reste portée par `ecommerce_reseau_content_shares` creee a la demande par `app_ecommerce_reseau_content_shares_schema_ensure()`;
  - l'unicité métier est deja visée dans ce helper par `ux_reseau_content_share (id_client_siege, game, content_type, source_id)`;
  - les writes etaient deja idempotents (`INSERT ... ON DUPLICATE KEY UPDATE` pour partager, `UPDATE` borne pour retirer), mais les lectures continuaient de remonter des lignes `active` dont la source pouvait etre inactive ou supprimée.
- [x] Correctif livre:
  - ajout d'une verification source centralisee par jeu pour ne considerer exploitable qu'un contenu encore present, encore actif (`id_etat=2` ou `online=1`) et valide quand applicable;
  - `app_ecommerce_reseau_content_share_set()` refuse maintenant le partage d'une source non exploitable;
  - `app_ecommerce_reseau_content_share_is_active()`, `app_ecommerce_reseau_content_share_ids_get()` et `app_ecommerce_reseau_content_share_counts_get()` ignorent maintenant ces sources cassées en lecture;
  - decision retenue pour ce lot: maintien du lazy-init avec assurance de schema existante, sans extraction immediate vers une migration SQL dediee.
- [x] Risques / dette documentes:
  - contrainte d'unicité prouvée dans le code via `app_ecommerce_reseau_content_shares_schema_ensure()`, mais non reverifiee sur une base locale accessible depuis ce poste;
  - si l'industrialisation du schema hors runtime devient prioritaire, l'extraction doit rester strictement bornee a `ecommerce_reseau_content_shares`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-16 — Contenu reseau V1: socle de partage transverse pour la bibliothèque PRO
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Constat confirme:
  - l'affiliation reseau canonique passe deja par `clients.id_client_reseau`;
  - les contrats/activations reseau existent deja dans `ecommerce_reseau_*`;
  - aucune persistance `contenu partagé au réseau` n'existe encore;
  - le pattern le plus proche reste une projection separee du modele source, a l'image de `community_items`.
- [x] Correctif livre:
  - ajout d'un socle `ecommerce_reseau_content_shares` cree a la demande, borne au besoin `partagé au réseau`;
  - la lecture/ecriture reste portee par des helpers `global` dedies, sans changer l'origine du contenu ni toucher au runtime `games`;
  - la lecture affilié reutilise simplement `id_client_reseau` pour retrouver les contenus partages par la TdR.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-16 — Branding reseau: ajouter une validite optionnelle et ignorer les couches expirees
- [x] Audit confirme dans:
  - `global/web/app/modules/general/branding/app_branding_functions.php`
  - `global/web/app/modules/general/branding/app_branding_ajax.php`
  - `pro/web/ec/modules/general/branding/ec_branding_script.php`
- [x] Cause / besoin confirme:
  - la hiérarchie type `1/2/3/4` etait bien en place, mais aucune validite temporelle n'etait documentee ni resolue pour la couche reseau type `3`;
  - la page PRO branding existante n'avait donc aucun moyen canonique d'annoncer `Actif jusqu'au ...` ou `Expire`.
- [x] Correctif livre:
  - ajout de la colonne SQL `general_branding.valable_jusqu_au` via migration dediee;
  - `app_general_branding_get_complete()` hydrate maintenant `validite.valable_jusqu_au` et `validite.is_expired`;
  - `app_general_branding_get_detail()` ignore desormais un branding reseau type `3` quand `valable_jusqu_au` est depasse en fin de journee;
  - les helpers d'ajout/modification acceptent maintenant `valable_jusqu_au`;
  - un helper de lookup direct stabilise aussi la lecture du dernier branding type/id_related.
- [x] Effet attendu:
  - un branding reseau actif et non expire continue de participer a la resolution type `3`;
  - au-dela de la fin de la journee choisie, la couche reseau est ignoree et le fallback reprend automatiquement.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_script.php` OK
- [x] Correctif media complementaire:
  - le logo reseau PRO ne passe plus par un recadrage hauteur force;
  - l'upload branding reseau conserve maintenant le ratio source et evite la coupe laterale dans le header games.
- [x] Correctif upload final aligne games:
  - le helper branding normalise maintenant les fichiers uploadés avec la meme logique MIME/extension que le flux games/ajax avant l'appel au core upload;
  - le core upload image supporte aussi `webp` et ne reference plus une variable `mime` non definie pendant le redimensionnement;
  - le helper branding garde finalement un comportement de save proche de l'implementation historique: purge puis upload, sans restauration automatique d'un ancien media pendant le save.
- [x] Instrumentation upload:
  - ajout de logs `[branding:upload]` au niveau du helper global de branding pour voir la normalisation du media, le path cible et les fichiers reels avant/apres ecriture.
- [x] Diagnostic final save branding:
  - les logs prouvent que le POST branding reecrit bien le nouveau `logo.png` au bon emplacement apres unlink;
  - le symptome restant venait donc de la relecture d'une URL d'asset stable, pas d'un echec d'upload;
  - `app_general_branding_get_complete()` retourne maintenant des URLs versionnees sur `filemtime` pour `logo` et `visuel`, afin de casser le cache apres save.

## PATCH 2026-03-16 — Facturation reseau: exposer l'affilie facture pour les offres deleguees
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/modules/compte/factures/ec_factures_list.php`
  - `www/web/bo/www/modules/ecommerce/factures/bo_factures_list.php`
- [x] Besoin confirme:
  - une TdR ne differencie pas facilement plusieurs factures d'offres deleguees `hors cadre` quand elles ont le meme montant.
- [x] Correctif livre:
  - ajout d'un helper global qui resolve le nom de l'affilie a partir de l'offre facturee si `id_client_delegation > 0`;
  - affichage de ce libelle (`Affilié : <nom>`) dans les listes de factures PRO et BO;
  - injection du meme libelle dans le texte de ligne produit au moment de creer la commande, pour les nouvelles factures PDF;
  - enrichissement aussi des vues PDF BO/PRO au rendu, pour couvrir les factures deja generees.
- [x] Effet attendu:
  - les factures TdR d'offres deleguees affichent `Affilié : <nom>` directement dans la liste;
  - les factures PDF reprennent aussi ce libelle sous le nom du produit, y compris sur des factures deja existantes.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_list.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php` OK

## PATCH 2026-03-16 — Reseau TdR: prioriser la delegation liee au support courant pour un affilié sans offre active
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - les resolutions runtime/sync legacy privilegiaient encore une delegation active legacy "la plus recente" pour un affilié, meme lorsqu'une autre ligne active etait explicitement rattachee au support reseau courant;
  - apres des historiques BO charges, une activation incluse valide pouvait donc etre relue puis resynchronisee en `hors_cadre`.
- [x] Correctif livre:
  - la resolution canonique des delegations actives choisit maintenant d'abord la ligne active liee au support courant via `reseau_id_offre_client_support_source`;
  - a defaut seulement, elle retombe sur la delegation active la plus recente.
- [x] Portee:
  - `app_ecommerce_reseau_delegations_actives_resolues_get_liste()`
  - `app_ecommerce_reseau_contrat_sync_legacy_delegations()`
  - `app_ecommerce_reseau_affiliate_active_delegated_offer_get_id()`
- [x] Effet attendu:
  - si la TdR a un abonnement reseau actif, qu'il reste du quota et que l'affilie n'a aucune offre active, l'activation manuelle doit marcher quel que soit l'historique des anciennes delegations.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-16 — Reseau TdR: conserver `cadre` a l'ecriture pour les activations incluses
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - `app_ecommerce_reseau_activation_write()` calculait `mode_facturation_effective()` depuis un detail contrat incomplet;
  - une activation demandee en `cadre` pouvait donc etre persistee en `hors_cadre`, surtout visible apres suppression de l'ancien auto-reclassement.
- [x] Correctif livre:
  - le helper recharge maintenant le contrat runtime complet via `app_ecommerce_reseau_contrat_get_by_client_siege()` avant de calculer le mode effectif.
- [x] Durcissement complementaire:
  - `app_ecommerce_reseau_activation_mode_facturation_effective()` transmet maintenant aussi `id_client_siege` a `app_ecommerce_reseau_contrat_get_state()`, pour reutiliser l'offre support runtime si la ligne contrat n'a pas encore son `id_offre_client_contrat` a jour.
- [x] Durcissement lecture/runtime:
  - la couverture reseau et la sync legacy deduisent maintenant aussi `cadre` depuis `reseau_id_offre_client_support_source` quand l'offre deleguee est rattachee au support reseau courant.
- [x] Effet attendu:
  - `signup_affiliation` et `Activer via l'abonnement` recreent bien une offre incluse `cadre` quand le support reseau est actif et qu'une place reste disponible.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-16 — Reseau TdR: ne plus auto-reclasser les offres deleguees `hors cadre` vers `cadre`
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - la couverture reseau absorbait encore implicitement des offres deleguees actives `hors cadre` dans le quota `cadre` des qu'un abonnement reseau etait actif;
  - le reclassement runtime pouvait donc retoucher ces offres alors que la nouvelle regle metier demande de ne plus y toucher automatiquement.
- [x] Correctif livre:
  - `mode_reclassement` reflete maintenant uniquement le mode d'activation reel (`cadre`/`hors_cadre`) deja porte par l'activation reseau;
  - le moteur de reclassement ne declenche plus de remplacement automatique `hors cadre -> cadre` pour les offres deleguees actives.
- [x] Effet attendu:
  - les offres deleguees `hors cadre` actives restent en supplement tant que l'utilisateur ne les resilie pas lui-meme;
  - seules les activations manuelles d'affiliés sans offre entrent dans le quota reseau.
- [x] Invariants a proteger dans `app_ecommerce_functions.php`:
  - ne jamais transformer une delegation `hors_cadre` active en `cadre` par simple recalcul runtime;
  - ne jamais declencher de remplacement automatique d'une delegation `hors_cadre`;
  - ne jamais propager la fin BO ou Stripe du support vers une delegation `hors_cadre`;
  - reserver `En attente` aux seuls write paths explicites.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-16 — Stripe portail reseau: hardening technique historique autour de `subscription_update`
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - preuve log:
    - `pro/logs/error_log` avec `Missing required param: features[subscription_update][products]` sur la config `network`
- [x] Cause confirmee:
  - la sync `network` activait `features.subscription_update.enabled=true` sans pousser le catalogue produit/prix attendu par Stripe;
  - le deep-link `subscription_update` restait donc considere comme desactive/incomplet.
- [x] Correctif livre:
  - ajout d'un helper qui derive `product_id` + `price_ids` recurrents depuis la souscription Stripe ciblee;
  - fusion de ce catalogue avec les `products` deja presents sur la configuration Billing Portal;
  - ajout de `default_allowed_updates=['price']` quand necessaire.
- [x] Correctif complementaire livre:
  - filtrage des prix compatibles Billing Portal `subscription_update` (`active`, `recurring`, `billing_scheme=per_unit`, `usage_type=licensed`, sans `tiers_mode` ni `transform_quantity`);
  - remplacement integral de la liste de prix du produit reseau cible pour eliminer les anciens prix invalides deja stockes sur la config.
- [x] Portee:
  - la sync reseau garde le headline `Cotton - Abonnement réseau`;
  - elle completrait aussi la config Stripe avec un catalogue `subscription_update` coherent pour ce lot historique.
- [x] Realignement metier livre:
  - le portail reseau standard n'essaie plus de synchroniser `subscription_update` hors besoin explicite;
  - la vue PRO abonnement reseau peut maintenant utiliser un flux de resiliation sans trainer ces contraintes de modification Stripe;
  - ce bloc ne doit plus etre relu comme une validation V1 d'un parcours de modification de plan.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — Reseau: les affiliés supprimes du SI ne doivent plus consommer le quota reseau
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - preuve metier:
    - des affiliés supprimes via le BO restaient comptes comme actifs dans la couverture reseau, bloquant la creation d'une offre incluse sur `quota_reached`
- [x] Cause confirmee:
  - la couverture active et la sync legacy relisaient `ecommerce_offres_to_clients` sans verifier l'existence courante de `id_client_delegation` dans `clients`;
  - des delegations orphelines restaient donc consommees meme apres suppression du client cote SI.
- [x] Correctif livre:
  - ajout d'un `INNER JOIN clients` dans `app_ecommerce_reseau_delegations_actives_resolues_get_liste()`;
  - ajout du meme filtre dans `app_ecommerce_reseau_contrat_sync_legacy_delegations()`.
- [x] Effet attendu:
  - un affilié supprime du SI sort du calcul `quota_consumed/quota_remaining`;
  - la place redevient disponible pour un nouvel affilié reel.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — Reseau: le signup affilié ne doit plus reclencher un reclassement global avant son activation incluse
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - `client_affilier()` relancait encore `app_ecommerce_reseau_contrat_reclassify_delegations()` juste apres l'ecriture de l'affiliation;
  - sur `signup_affiliation`, ce recalcul precoce concurrencait l'orchestration dediee `activation explicite included`.
- [x] Correctif livre:
  - `client_affilier()` accepte maintenant un flag `run_network_reclassify`;
  - `app_ecommerce_reseau_affilier_client()` le passe a `0` uniquement pour `source='signup_affiliation'`.
- [x] Portee:
  - les autres appels a `client_affilier()` gardent le reclassement historique.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — Reseau: le reclassement auto ne doit plus terminer l'offre source du signup affilié
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - preuve fonctionnelle:
    - offre deleguee creee cote SI directement en `Terminee` avec `debut = fin` apres signup affilié sous abonnement reseau
- [x] Cause confirmee:
  - le remplacement auto `hors_cadre -> cadre` recreait la cible via le helper de creation deleguee;
  - la garde d'idempotence pouvait re-selectionner la ligne source elle-meme comme offre active equivalente;
  - le write path de remplacement cloturait alors cette source, d'ou une offre terminee le jour meme.
- [x] Correctif livre:
  - ajout d'un `id_offre_client_exclude` optionnel dans `app_ecommerce_reseau_offre_deleguee_create_for_affilie()`;
  - utilisation de cette exclusion depuis `app_ecommerce_reseau_delegated_offer_replace()` quand la cible `cadre` est creee;
  - garde defensive supplementaire `target_offer_same_as_source`.
- [x] Cause complementaire confirmee:
  - la creation deleguee declenchait `app_ecommerce_reseau_facturation_refresh_from_offer_client()`;
  - ce refresh relancait aussitot `app_ecommerce_reseau_contrat_reclassify_delegations()` pendant le write path, ouvrant une recursion `create -> refresh -> reclassify -> create`.
- [x] Correctif complementaire livre:
  - ajout d'un flag `run_post_create_hooks` sur `app_ecommerce_reseau_offre_deleguee_create_for_affilie()`;
  - les write paths reseau qui font deja un reclassement/activation ensuite desactivent ces hooks immediats pour n'executer qu'un seul recalcul en fin de flux.
- [x] Correctif complementaire 2 livre:
  - `app_ecommerce_reseau_contrat_reclassify_delegations()` est maintenant protege contre la reentrance dans une meme requete PHP pour un meme `id_client_siege`;
  - `app_ecommerce_reseau_delegated_offer_replace()` ne lance plus deux `facturation_refresh_from_offer_client()` successifs apres remplacement, mais un seul `app_ecommerce_reseau_facturation_refresh()` global.
- [x] Correctif d'orchestration livre:
  - `app_ecommerce_reseau_affilier_client()` special-case maintenant `signup_affiliation`;
  - ce flux passe directement par `app_ecommerce_reseau_activation_activate_affiliate_explicit(... activation_mode_request=included ...)`;
  - l'offre deleguee de premiere affiliation est donc creee directement en `cadre` quand le support reseau est actif, sans write path de remplacement.
- [x] Ajustement final livre:
  - `app_ecommerce_reseau_activation_activate_affiliate_explicit()` supporte `skip_post_activation_reclassify`;
  - `signup_affiliation` l'utilise pour ne pas relancer le reclassement final interne sur une premiere creation `cadre`.
- [x] Effet de bord corrige:
  - l'activation explicite reseau relance maintenant `app_ecommerce_reseau_affilie_pipeline_sync_from_effective_offer()`;
  - le pipe affilié redevient coherent (`ABN/PAK`) meme sans passage par le write path de reclassement.
- [x] Ajustement final:
  - l'activation explicite `included` n'est plus bloquante si `id_erp_jauge_cible` n'est pas encore resolue dans la couverture;
  - le helper de creation de delegation reprend alors sa logique de fallback historique.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — AI Studio signup pro: loader fiabilise avec `__DIR__`
- [x] Audit confirme dans:
  - `global/web/global_librairies.php`
  - `global/web/ai_studio/workflows/crm/1_emails_transactional/ai_studio_emails_transactional_functions.php`
  - dependance creation client:
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - preuve log:
    - `pro/logs/error_log` sur `POST /extranet/account/establishment/script` avec `Call to undefined function ai_studio_email_transactional_send()`
- [x] Cause confirmee:
  - le fichier workflow existait bien, mais le `require` passait par un chemin relatif sensible au `cwd` PHP;
  - le signup lisait aussi un `id_remise` session non garanti et la creation client pouvait lire un departement non resolu.
- [x] Correctif livre:
  - chargement de la brique AI Studio via `__DIR__`;
  - garde sur `$_SESSION['id_remise']` dans le signup;
  - garde sur la resolution `referentiels_zones_departements`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/global_librairies.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php` OK

## PATCH 2026-03-15 — Reseau: auto-attribution affilié rendue idempotente
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - point d'entree relu:
    - `pro/web/ec/modules/compte/client/ec_client_script.php`
  - preuve log:
    - `pro/logs/error_log` sur `id_client=2054` avec une rafale d'offres deleguees actives (`id_offre_client` successifs `7426` -> `8123`)
- [x] Cause confirmee:
  - le signup affilié sous abonnement reseau pouvait rejouer l'auto-attribution sans verrou metier;
  - la creation deleguee ne reverifiait pas l'existence d'une offre equivalente juste avant l'`INSERT`.
- [x] Correctif livre:
  - verrou MySQL par couple `siege/affilie` dans l'auto-attribution reseau;
  - verrou MySQL dans la creation de delegation;
  - garde SQL d'idempotence sur la combinaison `offre + jauge + frequence + support_source` avant insertion.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — Branding dev: retour vide propre si le client branding est absent
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients_branding/app_clients_branding_functions.php`
  - preuve log:
    - `pro/logs/error_log` (`Undefined variable: branding_type_slug`, `Trying to access array offset on value of type null`)
- [x] Cause confirmee:
  - le helper branding continuait avec un `app_client_detail` vide, puis lisait `seo_slug` et d'autres donnees non garanties.
- [x] Correctif livre:
  - initialisation defensive du contexte par defaut;
  - retour immediat du branding vide si aucun client exploitable n'est resolu.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_branding/app_clients_branding_functions.php` OK

## PATCH 2026-03-15 — AI Studio transactionnel: chemin legacy corrige pour eviter le fatal pro dev
- [x] Audit confirme dans:
  - `global/web/global_librairies.php`
  - `global/web/ai_studio/workflows/crm/1_emails_transactional/ai_studio_emails_transactional_functions.php`
  - preuve log:
    - `pro/logs/error_log` (`Call to undefined function ai_studio_email_transactional_send()` depuis `ec_client_script.php:227`)
- [x] Cause confirmee:
  - le loader global pointait encore vers `ai_studio/workflows/crm/emails_transactional/...`;
  - la fonction existe en realite sous `ai_studio/workflows/crm/1_emails_transactional/...`, donc elle n'etait jamais chargee dans `pro`.
- [x] Correctif livre:
  - le loader global tente maintenant le chemin reel `1_emails_transactional` puis garde l'ancien chemin en fallback;
  - l'URL du webhook transactionnel est elle aussi alignee sur `1_emails_transactional`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/global_librairies.php` OK
  - `php -l /home/romain/Cotton/global/web/ai_studio/workflows/crm/1_emails_transactional/ai_studio_emails_transactional_functions.php` OK

## PATCH 2026-03-15 — Portail Stripe reseau: deep-link sur la souscription support + headline aligne
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Causes confirmees:
  - le CTA `Mon offre` de l'abonnement reseau ouvrait une session Billing Portal globale du customer TdR, sans `flow_data`, donc non ciblee sur la souscription support;
  - le libelle visible cote Stripe restait porte par une configuration portail reseau historique non alignee sur `Abonnement reseau`.
- [x] Correctif livre:
  - le helper Billing Portal supporte maintenant aussi un deep-link `subscription_update` cible sur une souscription donnee;
  - la configuration portail reseau voit son `business_profile.headline` resynchronise vers `Cotton - Abonnement reseau` avant creation de session;
  - le sync reseau active aussi `features.subscription_update` sur cette configuration pour autoriser ce deep-link cible;
  - les autres variantes portail Stripe restent inchangées.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Reclassement support reseau par remplacement de la `hors cadre` legacy (historique abandonné)
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - focus:
    - `app_ecommerce_reseau_contrat_reclassify_delegations(...)`
    - `app_ecommerce_reseau_delegated_offer_replace(...)`
- [x] Cause confirmee:
  - le remplacement auto vers `cadre` ne dependait que de l'etat de la table d'activation (`mode_facturation=hors_cadre`);
  - une offre deleguee legacy pouvait donc rester la meme ligne SI si l'activation etait deja passee en `cadre`, meme sans rattachement au support reseau courant.
- [x] Correctif livre:
  - le reclassement force maintenant un vrai remplacement vers `cadre` quand l'offre active n'est pas deja sourcee par le support reseau courant (`reseau_id_offre_client_support_source`);
  - l'ancien critere sur `mode_facturation=hors_cadre` reste en fallback quand la colonne de source n'est pas disponible.
- [x] Relecture V1 finale:
  - cette logique de remplacement `hors_cadre -> cadre` n'est plus retenue;
  - l'invariant V1 conserve seulement la bonne ecriture des activations `cadre` explicites, sans auto-reclassement.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Checkout reseau: transmettre l'id securite de retour Stripe
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/compte/offres/ec_offres_script.php`
    - `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php`
- [x] Cause confirmee:
  - le flux `pay_network_support` preparait bien Checkout Stripe mais ne remontait pas l'`id_securite` de l'offre support au retour;
  - `script/cb` redirigeait alors vers `manage/s3/` sans identifiant.
- [x] Correctif livre:
  - le helper reseau remonte maintenant `id_offre_client_support_securite`;
  - le point d'entree compte/offres stocke cette valeur en session avant redirection Stripe;
  - le step 3 garde un fallback sur l'offre support reseau courante si l'identifiant manque encore.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php` OK

## PATCH 2026-03-13 — Stripe trialing: exposer `trial_end` pour `Mon offre`
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Cause confirmee:
  - le snapshot Stripe expose le statut `trialing` mais pas explicitement `trial_end`, donc la vue metier affichait encore la periode abonnement au lieu de la fin d'essai.
- [x] Correctif livre:
  - le snapshot Stripe remonte maintenant `trial_start` et `trial_end`;
  - la vue `Mon offre` peut ainsi afficher une date d'essai Stripe active sans casser l'affichage standard apres essai.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-13 — Stripe standard: autocreation du prix catalogue manquant
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - preuve log complementaire:
    - `pro/logs/error_log` (`reason=stripe_price_not_found ; detail=ABN100M` apres le premier correctif)
- [x] Cause confirmee:
  - certains environnements Stripe n'exposent pas encore le `Price` catalogue attendu, donc la simple resolution `lookup_keys/search` reste vide;
  - un pre-checkout SQL faisait aussi un `fetch_assoc()` sans verifier le resultat de requete.
- [x] Correctif livre:
  - ajout d'un helper global d'autocreation ciblee du `Price` Stripe catalogue avec conservation du `lookup_key`;
  - le checkout standard ne declenche cette creation qu'en fallback sur `price_not_found`, a partir du montant TTC et de la periodicite deja portes par l'offre client;
  - le pre-checkout SQL est garde contre un resultat `false`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK

## PATCH 2026-03-13 — Stripe standard: resolution catalogue robuste + garde-fou portail
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - preuves log:
    - `pro/logs/error_log` (`stripe_price_not_found` sur `ABN100A` / `ABN100M`)
    - `pro/logs/error_log` (`No such subscription ... a similar object exists in live mode`)
- [x] Causes confirmees:
  - la resolution des tarifs Stripe standard reposait sur `Price::search` uniquement, ce qui laissait echouer des cles catalogue pourtant attendues;
  - la preparation `subscription_cancel` du portail standard pouvait tenter une annulation sur une souscription inaccessible dans l'environnement Stripe courant.
- [x] Correctif livre:
  - ajout d'un helper global de resolution Stripe par `lookup_key`, qui tente d'abord `Price::all(lookup_keys=...)`, puis seulement un fallback `search`;
  - la preparation de session portail bloque maintenant proprement un deep link `subscription_cancel` si le snapshot de la souscription remonte deja une erreur Stripe.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Réseau TdR: downsell délégué différé (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - en changement manuel `hors cadre` avec `deferred_end_of_period`, la cible payée pouvait être revalidée à `id_etat=3` par le write path post-paiement avant la vraie fin de la source;
  - cela cassait la planification: source sans `date_fin` visible et cible active trop tôt.
- [x] Correctif livré:
  - `app_ecommerce_offre_client_valider(...)` saute désormais l'activation immédiate pour une cible de remplacement différé;
  - le précheck et le planificateur différé acceptent maintenant une cible déjà payée mais encore en `id_etat=2`.
  - le planificateur différé aligne aussi maintenant la `date_fin` source sur `current_period_end` renvoyé par Stripe si la période courante n'est pas encore entièrement résolue localement.
- [x] Relecture V1 finale:
  - cette logique de `downsell` délégué n'est plus une trajectoire produit active;
  - elle reste documentée ici uniquement comme historique technique abandonné.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Stripe: helper local de lecture des configs Billing Portal
- [x] Audit confirmé dans:
  - `global/web/assets/stripe/sdk/tools/list_billing_portal_configurations.php`
- [x] Besoin couvert:
  - récupérer les IDs `bpc_...` et leurs modes Stripe à partir de la clé déjà présente dans le code, y compris en prod, sans dépendre d'une clé recopiée à la main.
- [x] Correctif livré:
  - ajout d'un helper CLI `dev|prod` qui charge `config.php`, `init.php` et `stripe_sdk_functions.php`, puis liste les configurations Billing Portal Stripe avec `subscription_cancel_mode`, `proration_behavior` et `subscription_update_enabled`;
  - validation en `dev`: `bpc_1TAU7iLP3aHcgkSElGilMv0U` est bien en `immediately`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/tools/list_billing_portal_configurations.php` OK
  - `php /home/romain/Cotton/global/web/assets/stripe/sdk/tools/list_billing_portal_configurations.php dev` OK

## PATCH 2026-03-13 — Stripe portail affilié: réalignement sur 2 variantes utiles (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- [x] Décision métier appliquée:
  - pas de variante `network_affiliate_manage`;
  - changements d'offre déléguée `hors cadre` via tunnel Cotton;
  - seules restaient les voies `cancel_end_of_period` et `cancel_immediate` dans cette étape historique.
- [x] Correctif livré:
  - suppression du support utile de `network_affiliate_manage`;
  - préremplissage `dev` des deux variantes sur les configs Stripe déjà existantes:
    - `network_affiliate_cancel_end_of_period` -> `bpc_1T9LACLP3aHcgkSEh2y79vUB`
    - `network_affiliate_cancel_immediate` -> `bpc_1TAU7iLP3aHcgkSElGilMv0U`
- [x] Relecture V1 finale:
  - la vérité finale n'ouvre plus ni réactivation dédiée ni changement d'offre `hors_cadre`;
  - seule la résiliation explicite d'une délégation `hors_cadre` reste à conserver fonctionnellement.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/stripe_sdk_functions.php` OK

## PATCH 2026-03-13 — Stripe portail affilié: variantes dédiées par usage hors cadre (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- [x] Constat confirmé:
  - une résiliation unitaire déléguée `hors cadre` passait par la mauvaise voie Stripe et finissait en annulation effective au lieu de planifier `cancel_at_period_end`.
- [x] Correctif livré:
  - ajout du support des variantes `network_affiliate_manage`, `network_affiliate_cancel_end_of_period` et `network_affiliate_cancel_immediate`;
  - le helper de préparation de session portail accepte maintenant une `configuration_variant` explicite pour les offres affiliées réseau;
  - la résolution des IDs supporte les nouvelles variables d'environnement Stripe dédiées à ces variantes.
- [x] Relecture V1 finale:
  - `network_affiliate_manage` et les usages de réactivation / remplacement associés ne sont plus retenus comme vérité finale.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/stripe_sdk_functions.php` OK

## PATCH 2026-03-13 — Stripe portail réseau: audit ciblé customer/subscription avant write Stripe
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirmé:
  - le clic `Voir / résilier` / `Réactiver mon offre` ne fait aucun write Stripe côté Cotton; seul le portail Stripe peut poser `cancel_at_period_end`;
  - le log existant ne permettait pas de vérifier si la session portail était créée avec le bon `customer` pour la souscription ciblée.
- [x] Correctif livré:
  - le helper portail récupère maintenant un snapshot Stripe de la souscription ciblée avant création de session;
  - le résultat et les logs exposent `configuration_id`, `flow_type`, `subscription_customer_id`, `customer_subscription_match`, `subscription_status`, `subscription_cancel_at_period_end` et `subscription_current_period_end`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Réseau TdR: une fin Stripe future doit primer sur la clôture terminale
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - une délégation `hors cadre` résiliée via portail Stripe pouvait recevoir un événement terminal alors que `current_period_end` était encore future;
  - le write path terminal rabattait alors la clôture au jour courant si aucune `date_fin` future n'avait encore été persistée localement;
  - même après persistance de la bonne `date_fin`, le helper pouvait encore désactiver immédiatement l'offre et la passer trop tôt à `Terminée`.
- [x] Correctif livré:
  - la réconciliation Stripe -> SI traite désormais toute `current_period_end` future comme une fin planifiée prioritaire, même si Stripe expose déjà un statut terminal;
  - la désactivation réseau immédiate ne doit donc plus partir trop tôt sur une résiliation portail censée courir jusqu'à la fin de période;
  - tant que la fin Stripe est future, le helper sort maintenant sans passer l'offre en `Terminée`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Réseau TdR: réconciliation Stripe des délégations `hors cadre`
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
- [x] Causes confirmées:
  - une résiliation faite dans le portail Stripe d'une délégation `hors cadre` n'avait aucun write path SI dédié;
  - les scénarios de remplacement immédiat décrits dans ce lot sont désormais à lire comme historiques abandonnés.
- [x] Correctifs livrés:
  - ajout d'une réconciliation Stripe -> SI pour les souscriptions déléguées `hors cadre` sur `customer.subscription.updated` / `customer.subscription.deleted`;
  - `cancel_at_period_end` met maintenant à jour la `date_fin` SI, et un statut terminal déclenche la désactivation/clôture côté réseau;
  - la partie encore valable pour V1 est la réconciliation de résiliation fin de période / fin effective; pas le remplacement.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK

## PATCH 2026-03-13 — Réseau TdR / Stripe: sync pipeline hors cadre et robustesse `customer_id`
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Causes confirmées:
  - une offre déléguée `hors cadre` activée après paiement écrivait bien l'activation réseau, mais ne resynchronisait pas le pipeline affilié;
  - `app_ecommerce_stripe_customer_ensure_for_client(...)` pouvait encore sortir sans `customer_id` exploitable si le client possédait déjà un `asset_stripe_customerId` mais pas de contact principal/email exploitable.
- [x] Correctifs livrés:
  - ajout d'un appel explicite à `app_ecommerce_reseau_affilie_pipeline_sync_from_effective_offer(...)` juste après l'activation hors cadre payée;
  - ajout d'un fallback de sync direct basé sur l'offre déléguée effectivement activée si la lecture canonique de l'offre effective ne remonte pas encore au moment du webhook;
  - le helper Stripe renvoie maintenant le `customer_id` déjà connu même en l'absence de contact exploitable, ce qui limite les blocages standard/portail liés à la qualité des données client.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Réseau TdR: persistance dédiée des remplacements délégués différés (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/cron_routine_bdd_maj.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Cause confirmée:
  - les downsells manuels délégués validés fonctionnellement reposaient encore sur des marqueurs `[reseau_replace:*]` et `[reseau_replace_timing:*]` stockés dans `ecommerce_offres_to_clients.commentaire`;
  - cette persistance technique rendait le cron dépendant d’un champ métier libre, alors que la planification différée est maintenant un objet d’orchestration à part entière.
- [x] Correctif livré:
  - ajout d’une persistance dédiée `ecommerce_reseau_delegated_replacements` pour les remplacements planifiés d’offres déléguées;
  - le scheduler différé écrit désormais d’abord dans cette table, puis le cron exécute en priorité les lignes `scheduled` arrivées à échéance;
  - `app_ecommerce_reseau_delegated_offer_replace_context_extract(...)` relit aussi cette table avant tout fallback legacy sur `commentaire`;
  - une compatibilité de reprise reste active pour les anciennes planifications déjà créées via marqueurs, afin d’éviter toute rupture après déploiement du patch.
- [x] Relecture V1 finale:
  - les règles `upsell manuel = remplacement immédiat`, `downsell manuel = remplacement différé` et `auto-reclassement = remplacement immédiat` ne sont plus retenues;
  - cette persistance doit être lue uniquement comme trace d'une étape historique abandonnée.
- [x] Alignement develop/prod 2026-03-23:
  - le script phpMyAdmin de référence `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql` ne doit plus créer cette table historique;
  - un SQL one-shot d'alignement supprime aussi `ecommerce_reseau_delegated_replacements` des bases `develop` déjà dérivées de l'ancien état.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Widget délégué: remplacement manuel explicite dans le catalogue (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- [x] Cause confirmée:
  - le widget savait afficher le contexte délégué, mais pas distinguer un changement d’offre manuel ni identifier l’offre source active.
- [x] Correctif livré:
  - le bandeau du tunnel passe à `Changement d’offre pour ...` quand le contexte de remplacement manuel est présent;
  - l’offre source reste visible mais son CTA devient `Offre actuelle` et reste désactivé sur la périodicité active.
- [x] Relecture V1 finale:
  - ce contexte de remplacement manuel n'est plus une trajectoire produit V1.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` OK

## PATCH 2026-03-13 — Stripe portail réseau: IDs test centralisés dans `global` (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/config.php`
- [x] Correctif livré:
  - ajout d'un helper global pour résoudre les IDs de configuration Billing Portal par variante;
  - retrait de l'ID `network` injecté dans `pro/web/config.php`;
  - ajout de la variante test `network_affiliate` dédiée aux offres affiliées sans `Modifier`.
- [x] Relecture V1 finale:
  - la variante `network_affiliate` ne doit plus être relue comme une surface finale active;
  - la vérité V1 conserve seulement la résiliation explicite des délégations `hors_cadre`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/stripe_sdk_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/config.php` OK

## PATCH 2026-03-13 — Stripe portail affilié: deep link sur la souscription choisie (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livré:
  - le helper portail accepte maintenant un `flow_type=subscription_cancel` optionnel;
  - en contexte affilié réseau, la session Stripe peut être créée directement sur la souscription ciblée au lieu d'ouvrir la liste globale client.
- [x] Relecture V1 finale:
  - ce bloc reste un détail technique historique des anciennes variantes portail;
  - il ne doit plus être relu comme la base d'un parcours `Gérer l'offre` ou `Changer d'offre` en V1.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Réseau TdR: write path unique de remplacement d’une offre déléguée active (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `pro/web/ec/modules/compte/client/ec_client_network_script.php`
- [x] Cause confirmée:
  - le flux délégué savait créer ou rattacher une nouvelle offre `hors cadre`, mais pas remplacer proprement une délégation active existante;
  - l’auto-reclassement `hors cadre -> cadre` se contentait encore d’un switch de mode de facturation dans la surcouche réseau, sans clôturer l’ancienne offre ni résilier proprement la subscription Stripe source.
- [x] Correctif livré:
  - ajout du helper central `app_ecommerce_reseau_delegated_offer_replace(...)` avec garde-fous, verrou applicatif par offre source et sortie structurée (`ok`, `blocked_reason`, `stripe_action`, `si_updates`, `facturation_refresh_done`);
  - ajout d’un helper Stripe d’annulation immédiate avec prorata sur la subscription source, déclenché seulement après validation complète de la cible;
  - le flux de paiement délégué peut maintenant embarquer un contexte `manual_offer_change` persistant sur l’offre cible puis appeler automatiquement le helper de remplacement après paiement validé;
  - l’auto-reclassement vers `cadre` réutilise maintenant le même write path central au lieu d’un simple changement de mode.
- [x] Portée Stripe explicitée:
  - le portail Stripe des offres affiliées peut maintenant cibler une configuration dédiée `network_affiliate`;
  - cette configuration doit être fournie via `STRIPE_BILLING_PORTAL_CONFIGURATION_NETWORK_AFFILIATE_ID` ou `STRIPE_BILLING_PORTAL_CONFIGURATION_NETWORK_AFFILIATE` pour garantir un portail `Voir / résilier` sans `Modifier`.
- [x] Relecture V1 finale:
  - ce write path de remplacement, `manual_offer_change` et l'auto-reclassement associe ne sont plus des trajectoires actives a retenir.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php` OK

## PATCH 2026-03-13 — Réseau TdR: sécurisation du repricing Stripe des offres déléguées hors cadre
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
- [x] Cause confirmée:
  - le repricing dynamique des offres déléguées hors cadre existait déjà, mais il dépendait d'un `refresh` réseau et pas du cycle Stripe lui-même;
  - un renouvellement automatique pouvait donc repartir sur un montant non rafraîchi si aucun refresh réseau n'était intervenu avant échéance.
- [x] Correctif livré:
  - ajout d'un helper global ciblant uniquement une subscription Stripe rattachée à une offre déléguée `hors cadre` de TdR;
  - le webhook Stripe appelle désormais ce helper sur `invoice.upcoming` et `invoice.created`, puis le relance en contrôle sur `invoice.paid` pour les cycles;
  - les autres abonnements restent hors périmètre de ce mécanisme.
- [x] Point d'exploitation:
  - pour bénéficier de la pré-sync avant prélèvement, l'endpoint Stripe doit bien être abonné aux événements `invoice.upcoming` et `invoice.created`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK

## PATCH 2026-03-13 — Tunnel délégué: fallback serveur sur contexte affilié `pending`
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- [x] Cause confirmée:
  - un retour navigateur vers le step 1 pouvait rejouer un POST sans `network_delegated_token`;
  - le flux délégué repartait alors hors contexte affilié, malgré une offre `pending` déjà ouverte pour cet affilié.
- [x] Correctif livré:
  - ajout d'un helper global pour retrouver l'offre déléguée `pending` d'un affilié;
  - le step 1 PRO réutilise maintenant le contexte délégué en session quand le token manque mais qu'une offre `pending` cohérente existe déjà.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK

## PATCH 2026-03-13 — Réseau PRO: CTA `Commander` explicite et remise détaillée en confirmation
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Cause confirmée:
  - le tunnel délégué pouvait encore conserver un libellé hérité comme `Essayer gratuitement` sur la première étape;
  - la page de confirmation n'affichait que `Remise réseau`, sans rappeler le pourcentage réellement stocké sur l'offre.
- [x] Correctif livré:
  - en contexte `network_delegated_token`, le CTA de sélection d'offre affiche maintenant `Commander`;
  - la note d'essai gratuit reste neutralisée dans ce contexte;
  - le bloc marketing CHR retire aussi la mention `testez pendant 15 jours` en contexte affilié;
  - la confirmation affiche désormais `Remise réseau (x%)` quand un pourcentage est présent sur l'offre.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-13 — Réseau PRO: tunnel délégué aligné sur la typologie de la TdR, sans promesse d'essai gratuit
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- [x] Cause confirmée:
  - l'entrée de commande déléguée redirigeait en dur vers le segment catalogue `abonnement`, sans reprendre la typologie de la tête de réseau qui commande;
  - en parallèle, le widget catalogue pouvait encore afficher les marqueurs UI d'essai gratuit en contexte affilié, alors que la création `pending` d'offre déléguée force déjà `trial_period_days = 0`.
- [x] Correctif livré:
  - ajout d'un helper global de résolution du point d'entrée catalogue PRO selon la typologie de la TdR (`abonnement` / `evenement` / `particulier`);
  - le démarrage d'un checkout délégué réutilise désormais ce helper pour choisir la bonne route de tunnel;
  - le widget catalogue masque maintenant toute UI d'essai gratuit en contexte `network_delegated_token` et poste aussi `trial_period_days = 0`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` OK

## DOC 2026-03-13 — Réseau BO: navigation croisée vers la TdR et l'offre support
- [x] Documentation transversale alignée:
  - la fiche BO `Abonnement réseau` expose désormais le client TdR en accès direct;
  - la synthèse BO `Affiliés du réseau` permet maintenant de rouvrir directement l'offre support active.
- [x] Portée métier rappelée:
  - aucun helper runtime global ni write path réseau n'est modifié par ce lot;
  - le changement porte uniquement sur l'exposition BO de liens de navigation autour du support réseau.

## PATCH 2026-03-12 — Réseau: rebaseline documentaire du plan pré-prod
- [x] Étapes closes fonctionnellement
  - `Étape 1`
    - resolver canonique confirmé;
    - priorité réelle confirmée: offre propre active, puis accès réseau actif, sinon inactif;
    - mapping final des `inactive_reason` explicitement exposé.
  - `Étape 2`
    - `ecommerce_offres_to_clients` reste le support commercial / Stripe principal;
    - `ecommerce_reseau_contrats*` reste une surcouche technique de capacité, rattachement, mode de facturation et trace.
  - `Étape 2A`
    - pas d’auto-création support encore branchée hors ajout BO explicite;
    - les helpers `ensure/backfill` restent seulement tolérés comme code dormant tant qu’aucun appel actif n’est prouvé.
  - `Étape 2B`
    - lecture BO `reseau_contrats` stabilisée;
    - distinction `Incluse à un abonnement réseau` vs `Hors abonnement réseau` stabilisée;
    - fallback BO historique seulement toléré comme legacy borné.
- [x] Étape close avec réserve
  - `Étape 3`
    - fermée sur le code livré d’après les audits déjà obtenus;
    - invariants métier confirmés:
      - `affiliation != accès actif`
      - offre propre active prioritaire
      - offre propre affilié jamais repricée
      - seules les délégations TdR `hors abonnement réseau` sont repricées
      - pas d’accès réseau effectif sans offre support active
    - réserve explicite:
      - absence de preuve de bout en bout sur un cycle Stripe réel après changement de palier.
- [x] Prochain lot pré-prod attendu
  - hardening final des étapes `1 / 2`:
    - purge des derniers fallbacks legacy encore actifs ou appelables
    - audit final colonne par colonne de `ecommerce_reseau_contrats`
    - normalisation documentaire / SQL prouvée du schéma `ecommerce_reseau_contrats*`
  - validation Stripe réelle finale pour lever la réserve de l’étape `3`.
- [x] Hors périmètre maintenu
  - étapes `4 / 5 / 6` volontairement non ouvertes à ce stade;
  - pas de nouvelles tâches fonctionnelles hors pré-prod.

## PATCH 2026-03-12 — Réseau: remise dynamique persistant les délégations `hors abonnement réseau`
- [x] Audit confirme dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - la remise réseau était recalculée dynamiquement pour les agrégats et affichages;
  - la facturation réelle des abonnements reposait toutefois sur le `prix_ht` stocké sur chaque offre déléguée.
- [x] Correctif runtime appliqué
  - le calcul des offres `hors abonnement réseau` repart maintenant du tarif catalogue de référence puis applique la remise réseau courante;
  - le refresh réseau persiste le `prix_ht` net, `remise_nom` et `remise_pourcentage` sur chaque délégation active concernée;
  - une synchro Stripe dédiée met aussi à jour la souscription correspondante sans prorata immédiat.
- [x] Périmètre métier explicité
  - la remise réseau ne concerne en prix que les offres déléguées `hors abonnement réseau` portées par la TdR;
  - les offres commandées en propre par un affilié ne sont pas recalculées;
  - en revanche, les affiliés rattachés à la TdR avec offre propre active comptent désormais dans le volume actif servant à déterminer le palier de remise réseau.
- [x] Effet attendu
  - prochaine facturation locale et prochain cycle Stripe alignés sur le palier réseau courant;
  - absence d’impact tarifaire collatéral sur les offres propres affilié.

## PATCH 2026-03-11 — Réseau: rattachement explicite des délégations incluses à l'offre support source
- [x] Audit confirme dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - aucune offre déléguée ne portait l'id de l'`Abonnement réseau` source;
  - le pointeur `id_offre_client_deleguee` de `ecommerce_reseau_contrats_affilies` reste un état courant, pas un historique fiable.
- [x] Correctif runtime appliqué
  - ajout d'un helper de disponibilité/persistance pour `reseau_id_offre_client_support_source`;
  - les write-paths `cadre` alimentent désormais ce rattachement sur création/réactivation/activation;
  - les flux `hors abonnement réseau` le remettent explicitement à `0`.
- [x] Effet attendu
  - une offre déléguée incluse sait désormais de quel `Abonnement réseau` elle provient;
  - les futures vues d'historique peuvent se brancher sur cette clé sans heuristique fragile.

## PATCH 2026-03-11 — Réseau: helper des offres incluses figé par offre support
- [x] Audit confirme dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - la couverture canonique BO savait compter le contrat courant, mais pas relire proprement les offres incluses d’une archive `Abonnement réseau`;
  - les vues `offres_clients` risquaient donc de relire le support actif au lieu du support affiché.
- [x] Correctif runtime appliqué
  - ajout d’un helper dédié pour lister les offres déléguées incluses rattachées à une offre support donnée;
  - filtrage par fenêtre de vie de l’offre support affichée pour éviter les biais avec un autre support réseau actif.
- [x] Effet attendu
  - la fiche BO d’un `Abonnement réseau` historique garde son périmètre d’offres incluses;
  - les offres support terminées conservent un historique lisible des délégations reliées.

## PATCH 2026-03-11 — Réseau: reclassement `cadre` vs `hors abonnement` stabilisé
- [x] Audit confirme dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - la couverture canonique savait déjà distinguer `delegations_cadre` et `delegations_hors_cadre`
  - les libellés métier restaient historiques `contrat cadre` / `hors cadre`
- [x] Correctif runtime appliqué
  - les libellés de couverture sont réalignés sur:
    - `offre déléguée incluse à l'abonnement réseau`
    - `offre déléguée hors abonnement réseau`
  - la vue BO peut désormais s'appuyer sur ces statuts sans ambiguïté métier
- [x] Effet attendu
  - cohérence de lecture entre couverture canonique et écran BO TdR
  - plus de confusion métier entre quota inclus et facturation hors abonnement

## PATCH 2026-03-11 — Reseau post-lot-2: runtime canonique + reorder Stripe
- [x] Audit confirme dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - la couverture exploitable redevient pilotee par l'offre support active + quota + offre cible
  - aucune reintroduction de `ecommerce_reseau_contrats.contract_state` comme verite metier
- [x] Correctif runtime affiliés applique
  - `app_ecommerce_reseau_contrat_couverture_get_detail(...)` ne depend plus de `contract_state` pour calculer `quota_exploitable`
  - l'activation `cadre` reste conditionnee par l'offre support active et le quota disponible
## PATCH 2026-03-23 — GLOBAL clients_contacts: jeton de connexion EC temporaire
- [x] Audit confirme dans `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
- [x] Correctif runtime applique
  - ajout d'un helper de generation de jeton temporaire pour un `clients_contacts`
  - ajout d'un helper de consommation du jeton avec fenetre courte (`48h`), resolution du client rattache et invalidation immediate
  - aucun nouveau champ SQL ajoute: reutilisation controlee de `pwd_token` / `pwd_token_date`
- [x] Verification
  - `php -l global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php` OK

- [x] Correctif BO support applique
  - le flux `ajouter` de l'`Abonnement reseau` resynchronise maintenant les vraies valeurs saisies
  - le premier submit redirige vers la vue enregistree, plus vers un second passage sur le formulaire
- [x] Correctif reorder Stripe appuye sur le write path existant
  - `app_ecommerce_offre_client_gerer(...)` est reutilise pour creer une nouvelle offre avec un nouvel `id_securite`
  - le reorder ne recycle plus une ancienne ligne terminee

## PATCH 2026-03-13 — Remplacement differe des offres deleguees en downsell (historique abandonné)
- [x] Audit confirme dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - le write path `app_ecommerce_reseau_delegated_offer_replace(...)` reste adapte aux remplacements immediats
  - le SI disposait deja des briques `date_fin` / cron / webhook Stripe pour porter une fin de periode
- [x] Correctif runtime applique
  - ajout d'une resolution serveur `immediate_prorated` vs `deferred_end_of_period` pour les changements manuels d'offres deleguees hors cadre
  - ajout d'un helper Stripe `cancel_at_period_end` dedie au downsell manuel
  - la cible payee d'un downsell manuel repasse en `id_etat=2` avec date d'effet future, au lieu d'etre rattachee tout de suite
  - la planification SI `source -> cible` est stockee sur l'offre cible via marqueurs de commentaire reutilisables par le cron
- [x] Effet attendu
  - ces hypotheses `upsell manuel`, `downsell manuel` et `auto-reclassement` ne sont plus retenues en V1 finale
  - cette section est conservee seulement comme historique technique

## PATCH 2026-03-13 — Instrumentation du downsell differe delegue (historique abandonné)
- [x] Le diagnostic montre encore un trou entre la cible `En attente` et la planification effective de la source
- [x] Des logs applicatifs ont ete ajoutes sur:
  - `app_ecommerce_reseau_delegated_checkout_offer_attach_after_payment(...)`
  - `app_ecommerce_reseau_delegated_offer_replace_schedule_deferred(...)`
- [x] Les prochains tests doivent maintenant produire une preuve explicite de:
  - blocage `precheck`
  - retour Stripe `cancel_at_period_end`
  - calcul `period_end/effective_date`
  - `affected_rows` sur l'update SQL source
- [x] Le premier test instrumente a isole le vrai root cause:
  - fatal PHP sur appel a `app_ecommerce_offre_client_abonnement_periode_en_cours_get_detail()` (fonction inexistante)
  - correctif applique en reutilisant `app_ecommerce_offre_client_abonnement_periode_get_detail(...)`
- [x] Le test `upsell` a isole un second root cause:
  - au retour webhook, la cible immediate pouvait deja etre consideree comme l'offre active courante
  - `app_ecommerce_reseau_delegated_checkout_offer_context_get(...)` bloquait alors sur `source_offer_not_current` avant la cloture immediate de la source
- [x] Relecture V1 finale:
  - cette instrumentation documente un chantier de `downsell`/`upsell` désormais abandonné comme trajectoire produit;
  - elle reste utile seulement pour mémoire technique.
  - correctif applique pour autoriser ce cas quand l'offre courante est precisement la cible marquee

## PATCH 2026-03-26 — New_EJ: restauration du contrat `develop` autour des participations probables et du bridge EP
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - restauration des helpers `app_session_participation_probable_*` et `app_session_participations_probables_*` supprimés par `new_ej`;
  - `app_joueur_sessions_inscriptions_get_liste()` et `app_joueur_session_inscription_get_detail()` redeviennent compatibles avec les participations probables legacy, y compris pour les types `4` et `5`;
  - conservation du nouveau bridge `EP -> games`;
  - ajout d'un garde-fou sur l'insert bridge `championnats_sessions_participations_games_connectees` pour retomber proprement sur le parcours legacy en cas d'échec SQL.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — Signup joueur: tolérance département vide sur création de compte
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - normalisation de `id_zone_departement` à `NULL` dans `app_joueur_ajouter(...)` quand aucun département n'est fourni;
  - évite l'échec SQL sur insertion joueur quand le signup public envoie un département vide.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — Joueur: helpers `pseudo` + fallback nom d'affichage
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout des helpers de support `pseudo` (`support colonne`, `normalisation`, `validation`, `lecture`, `save/delete`);
  - contrainte de longueur alignée sur `games`: `1–20` caractères;
  - ajout d'un helper de nom d'affichage avec fallback sur `prenom`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — Joueur: helper de suppression de liaison équipe
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'un helper `app_joueur_equipe_supprimer(...)` pour retirer une liaison `joueur <=> équipe`;
  - usage destiné à la page EP `Pseudo / Equipes`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — Joueur: joueurs liés par équipe + suppression contextuelle
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'un helper pour lister les joueurs liés à une équipe avec nom d'affichage pseudo/prénom;
  - évolution de `app_joueur_equipe_supprimer(...)` pour distinguer `left_team` et `team_deleted`;
  - suppression automatique de l'équipe devenue vide après retrait du dernier joueur lié.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — Joueur: suppression compte RGPD depuis l'EP
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'un helper `app_joueur_compte_supprimer(...)`;
  - retrait des liaisons équipe avant suppression;
  - purge des tables directement personnelles (`participations_probables`, `participations_games_connectees`, `jeux_bingo_musical_grids_clients`, logs joueur, lots joueur);
  - neutralisation des références legacy de contribution en remplaçant `id_equipe_joueur` par `0` sur les contenus qui doivent rester visibles.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-28 — Joueur: invitation équipe alignée sur `PLAYER_ALL_TEAM_INVITATION`
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`
- [x] Correctif livré:
  - l'envoi invitation équipe appelle maintenant `ai_studio_email_transactional_send('PLAYER','ALL','TEAM_INVITATION', ...)`;
  - le payload alimente les nouvelles variables `CONTACT_PRENOM` (invitant) et `CONTACT_PRENOM_INVITE` (invité), sans dépendre des anciens champs `INVITER_*`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-30 — Sessions: métadonnées `Cotton Quiz` V2 par séries
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - ajout du helper `app_cotton_quiz_get_series_meta(...)` qui lit `quizs_series` pour un quiz client;
  - ajout du helper `app_cotton_quiz_get_session_series_meta(...)` qui lit `championnats_sessions.lot_ids` et résout les noms de lots `L...` / `T...` dans l'ordre de session;
  - `app_jeu_get_detail()` pour `id_type_produit=5` remonte maintenant:
    - `quiz_series_count`
    - `quiz_series_label`
    - `quiz_series_names`
  - `app_session_get_detail()` remonte aussi ces métadonnées session pour que `play` puisse afficher les lots classiques `L...` sans dépendre uniquement de `quizs_series.nom`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-03-30 — Joueur: equipe quiz remontee dans les inscriptions EP
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - `app_joueur_sessions_inscriptions_get_liste(...)` remonte maintenant pour chaque session:
    - `id_equipe_inscrite`
    - `equipe_nom_inscrite`
    - `nb_equipes_inscrites`
  - ces champs permettent a `play` d'afficher un message coherent entre la home et les cartes agenda quiz sans redeviner l'equipe depuis un simple boolen d'inscription.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-31 — Session quiz: helper global de compatibilite numerique
- [x] Audit cible:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livre:
  - ajout de `app_session_quiz_digital_guard_get(...)` pour reconstruire la compatibilite numerique d'une session `Cotton Quiz` depuis `lot_ids`, `questions` et `questions_propositions`;
  - la regle alignee avec `games` exige une bonne reponse non vide et au moins deux propositions distinctes de cette reponse.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-04 — Classements agrégés: cohérence des compteurs podiums
- [x] Audit ciblé:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livré:
  - le mapping `victoire / 2e / 3e` repose désormais sur les bonus nets réellement ajoutés au score agrégé;
  - suppression de l'ancien mapping implicite sur valeurs brutes, devenu incohérent après le passage à `podium remplace participation`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-16 — Helpers de description lieu
- [x] Audit ciblé:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livré:
  - ajout de helpers globaux pour normaliser `descriptif_court` et `descriptif_long`;
  - nettoyage des anciens `<br>` / balises héritées;
  - conservation des retours à la ligne du descriptif long;
  - `app_client_modifier(...)` stocke désormais ces descriptions sous forme texte normalisée.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-04 — Joueur: helper léger pour `Top classement`
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `play/web/ep/modules/communication/home/ep_home_index.php`
- [x] Correctif livré:
  - ajout de `app_joueur_leaderboards_best_rank_get(...)` pour la home EP;
  - arrêt anticipé dès qu'un rang `#1` est trouvé;
  - cache de session court sur le meilleur rang;
  - suppression de l'appel au contexte complet `app_joueur_leaderboards_get_context(...)` sur la home.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_index.php`

## PATCH 2026-04-04 — Joueur: historique aligné sur la terminaison des classements
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - `app_joueur_historique_session_is_eligible(...)` réutilise désormais la même notion de session réellement terminée que les classements;
  - exclusion explicite des sessions démo et des sessions incomplètes;
  - les requêtes d'historique remontent les drapeaux session nécessaires (`flag_session_demo`, `flag_configuration_complete`, `flag_controle_numerique`).
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-10 — Stripe portail TdR: fallback subscription snapshot pour offre affiliée déléguée
- [x] Audit ciblé:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause exacte:
  - le message `network_affiliate_subscription_snapshot_unavailable` venait d'un `asset_stripe_productId` non vide mais non exploitable comme souscription Stripe;
  - pour une offre affiliée déléguée TdR, aucun fallback ne reconstituait la vraie souscription via les métadonnées Stripe `offre_client_id(_securite)`.
- [x] Correctif livré:
  - ajout d'un resolver global `app_ecommerce_stripe_subscription_id_resolve_from_offer_client(...)`;
  - validation du `sub_...` stocké puis fallback via `\Stripe\Subscription::search(...)` sur les métadonnées de l'offre cliente;
  - persistance du `subscription_id` retrouvé dans `ecommerce_offres_to_clients.asset_stripe_productId`;
  - `app_ecommerce_stripe_customer_backfill_from_offer_subscription(...)` et `app_ecommerce_stripe_billing_portal_session_prepare(...)` utilisent désormais ce resolver avant de conclure à `subscription_snapshot_unavailable`;
  - le fallback est borné aux offres déléguées affiliées pour ne pas modifier le comportement des portails Stripe standard.
  - pour les offres non affiliées, `app_ecommerce_stripe_billing_portal_session_prepare(...)` revalide désormais le `customer` Stripe via `app_ecommerce_stripe_customer_ensure_for_client(...)` avant d'essayer d'ouvrir le Billing Portal.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-07 — Joueur: cache court du contexte leaderboards
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'un cache de session court pour `app_joueur_leaderboards_get_context(...)`;
  - ajout d'un cache mémoire par requête pour éviter les recomputations intra-request;
  - `app_joueur_leaderboards_best_rank_get(...)` réutilise ce cache de contexte quand il existe.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
## PATCH 2026-04-13 — Fiche session Bingo: fallback identité joueur sur résultats
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - le moteur `app_session_results_get_context(...)` réconcilie maintenant les labels `Bingo Musical` avec les liaisons joueur EP (`games_connectees`) puis le fallback legacy `grids_clients`;
  - le podium de phases et la liste des joueurs n'affichent plus seulement `bingo_players.username` quand il est vide;
  - priorité d'affichage: `pseudo`, sinon `prenom nom`, avec appariement via `game_player_id`, `game_player_key` puis libellé normalisé;
  - le switch de résultats session couvre aussi les anciens `Bingo Musical` `id_type_produit = 2`;
  - la liste Bingo fusionne aussi les participants legacy prouvés absents du runtime, et un message dédié est remonté quand seul le podium reste indisponible.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-15 — Helpers podium `play`
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'un helper global de stabilisation d'URL photo podium pour les vues `play`, avec priorité au domaine public `www/upload` et fallback final `www prod`;
  - correctif complémentaire: si l'entrée est déjà en `www prod`, le helper reconstruit malgré tout l'URL `www` du serveur courant quand elle est déductible, au lieu de conserver `prod` par défaut;
  - le surlignage joueur `play` couvre désormais aussi `players_podium` / `teams_podium` en plus des lignes de tableaux.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-15 — Archive dashboard: option `historique seul`
- [x] Audit ciblé:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livré:
  - `app_client_joueurs_dashboard_archive_sessions_get(...)` accepte désormais un drapeau pour éviter le chargement des sessions à venir quand seul l'historique est demandé;
  - le helper accepte aussi un `offset` explicite pour permettre une pagination archive par lots côté `www`;
  - les consumers FO `place` l'utilisent pour `Sessions passées` et les `sessions récentes` liées aux classements.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-16 — Dashboard joueurs: fallback classements sur saison vide
- [x] Audit ciblé:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livré:
  - ajout d'une finalisation commune du contexte dashboard joueurs pour recalculer `has_summary`, `has_filter_results` et les messages fallback à la fin du pipeline;
  - le cas `synthèse disponible + aucun classement exploitable` remonte maintenant bien `empty_filter`, y compris quand la saison par défaut n'a aucune session filtrée;
  - `app_client_joueurs_dashboard_get_context(...)` et `app_client_joueurs_dashboard_get_context_fo_place(...)` réappliquent aussi cette finalisation après fusion du cache synthèse.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-16 — Cotton Quiz: visuel multi-séries
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - ajout d'un helper `app_cotton_quiz_get_series_visual_src(...)` pour sélectionner le visuel de la dernière série effectivement illustrée d'un quiz;
  - les copies inchangées de `default_cotton_quiz.jpg` sont exclues de cette sélection;
  - `app_jeu_get_detail(...)` réutilise maintenant ce helper pour les quizzes multi-séries, avec fallback inchangé sur `default_cotton_quiz.jpg`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-16 — Branding Blind Test: instrumentation diagnostic
- [x] Audit ciblé:
  - `global/web/app/modules/general/branding/app_branding_ajax.php`
  - `games/web/includes/canvas/core/session_modals.js`
- [x] Instrumentation livree:
  - ajout d'un helper `branding_trace_log(...)` dans `app_branding_ajax.php`;
  - traces ajoutees sur `get`, `save` et `delete_preview` pour journaliser la portee demandee, les ids branding resolus et le branding effectif apres sauvegarde;
  - objectif: confirmer si une session `Blind Test` reste resolue en `branding_session` apres une sauvegarde `branding_client`.
- [x] Correctif livre:
  - suppression de la dependance a `app_session_get_detail(...)` dans `app_branding_ajax.php` pour la resolution du contexte branding;
  - lecture SQL minimale de `championnats_sessions` pour recuperer `id_client` et `id_operation_evenement`;
  - effet attendu: plus de fatal `app_blind_test_get_detail()` sur `get`, `save`, `delete_preview` et `delete` du module branding `global`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_ajax.php`

## PATCH 2026-04-16 — Branding visuel: ratio final force cote `global`
- [x] Audit ciblé:
  - `global/web/app/modules/general/branding/app_branding_functions.php`
  - `games/web/includes/canvas/core/session_modals.js`
- [x] Correctif livré:
  - `app_general_branding_visuel_uploader(...)` ne rabaisse plus la cible `visuel` à la taille source avant upload;
  - ajout d'un post-traitement `app_general_branding_cover_fit(...)` qui recadre par le centre et force le média actif exactement aux dimensions demandées;
  - le backend conserve donc la cible demandée par `app_branding_ajax.php` (`1600x640`, même ratio que `600x240`) et coupe/centre le visuel si nécessaire pour tenir dans ce gabarit;
  - `session_modals.js` est revenu au flux simple avec envoi prioritaire du fichier source brut pour `branding_visuel`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_functions.php`

## PATCH 2026-04-16 — Duplication branding client -> session sécurisée
- [x] Audit ciblé:
  - `global/web/app/modules/general/branding/app_branding_functions.php`
- [x] Correctif livré:
  - `app_general_branding_duplicate_to_target(...)` prépare maintenant les assets dans un dossier de staging puis effectue un swap atomique du dossier cible;
  - si la copie des médias source échoue, la fonction retourne `0` avant toute écriture `general_branding` sur la cible session;
  - le dossier cible précédent est restauré automatiquement si le swap final échoue;
  - effet attendu: plus de `branding_session` écrit avec `logo/visuel` absents lors du gel des sessions programmées avant suppression d'un branding client.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_functions.php`

## PATCH 2026-04-17 — Sessions: helper partagé de bascule agenda / archive
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - ajout des helpers `app_session_list_item_is_archive(...)` et `app_sessions_filter_by_archive_state(...)`;
  - la décision `agenda` vs `archive` peut désormais être réutilisée par les listes `play`, `www` et widgets `pro` sans reposer uniquement sur `cs.date >= CURDATE()`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-17 — Leaderboards agrégés: labels joueurs / équipes en uppercase
- [x] Audit ciblé:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livré:
  - `app_client_joueurs_dashboard_player_label_get(...)` renvoie désormais `pseudo` ou `prenom` en uppercase;
  - ajout du helper `app_client_joueurs_dashboard_label_display_format(...)`;
  - les lignes/podiums de leaderboards agrégés passent maintenant toutes par ce formateur avant rendu, ce qui harmonise l'uppercase sur joueurs et équipes.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-17 — Résultats de session: labels joueurs en uppercase
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - ajout de `app_session_results_label_display_format(...)`;
  - les labels podium / classement de session sont maintenant formatés en uppercase dans les helpers `app_session_results_*`;
  - le fallback `pseudo` / `prenom` reste bien en `prenom seul`, sans retour à `prenom + nom`;
  - couverture explicite ajoutée aussi sur le cas `Bingo` qui ne passait pas par le ranking compétitif standard.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-17 — FO place: leaderboards recalculés au reload + ordre des jeux aligné sur `pro`
- [x] Audit ciblé:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - `app_client_joueurs_dashboard_get_context_fo_place(...)` ne relit plus un cache de session journalier pour les leaderboards `www place`; le contexte est recalculé au reload afin qu'une session `bingo` nouvellement terminée apparaisse sans attendre une invalidation manuelle;
  - `app_joueur_leaderboards_get_context(...)` impose maintenant l'ordre `blindtest`, `bingo`, `quiz` dans les sections `play`, avec conservation des jeux additionnels éventuels en fin de liste.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-17 — Sessions `quiz`: libellé court `1 série` / `x séries` exposé aussi aux listes
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - `app_sessions_get_liste(...)` sélectionne maintenant aussi `lot_ids`;
  - les lignes de session sont enrichies avec `quiz_series_count`, `quiz_series_label`, `quiz_series_names` pour les types `1` et `5`;
  - `app_session_get_detail(...)` applique le même enrichissement aux sessions `quiz` legacy et V2;
  - `app_jeu_get_detail(...)` expose aussi les métadonnées de séries sur le `quiz` legacy quand elles sont reconstructibles depuis `id_produit`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-17 — Sessions `quiz`: helper partagé de libellé compact agenda
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - ajout de `app_session_quiz_compact_label_get(...)`;
  - priorité à `quiz_series_label` côté session, puis fallback `quiz_series_label` côté jeu, puis fallback `theme` pour les anciens formats;
  - le helper masque aussi les faux doublons du type `Cotton Quiz`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-30 — Config Stripe isolée du contexte applicatif
- [x] Audit ciblé:
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
  - `global/web/global_config.php`
  - `global/web/global_config_stripe.php`
- [x] Correctif livré:
  - le bootstrap Stripe ne charge plus `global_config.php` en fallback, afin d'éviter l'écrasement de `$conf['site_url']` dans les runtimes `pro` / `www`;
  - les clés Stripe sont isolées dans `global_config_stripe.php`;
  - `global_config.php` inclut désormais cette config dédiée pour conserver le comportement des scripts exécutés dans le contexte `global`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/global_config.php`
  - `php -l /home/romain/Cotton/global/web/global_config_stripe.php`
  - `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/stripe_sdk_functions.php`
  - test runtime: appel `lib_Stripe_getPrivateApiKey()` avec `$conf['site_url']['prod']='https://pro.cotton-quiz.com'`, valeur conservée après bootstrap.
# PATCH 2026-05-11 - Parametrage LP sur abonnement reseau

- [x] Audit cible:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - BO `www/web/bo/www/modules/ecommerce/offres_clients/*`
  - LP `www/web/lp/lp.php`
- [x] Correctif livre:
  - ajout de la table runtime `ecommerce_reseau_support_lp_settings`;
  - ajout des helpers `app_ecommerce_reseau_support_lp_settings_get/save`;
  - ajout du resolver `app_ecommerce_reseau_support_offer_active_latest_get(...)` pour la regle V1 "abonnement actif le plus recent";
  - aucune modification de `app_ecommerce_reseau_affilier_client(...)` ni des regles d'activation d'offre incluse.
- [ ] Recette serveur:
  - verifier creation/lecture table sur une fiche `Abonnement reseau`;
  - verifier plusieurs supports actifs et dates incompletes.
