## Update 2026-09-03 - Période Stripe autoritaire pour l'affichage

Le webhook synchronise désormais `stripe_current_period_start/end` à la création/mise à jour d'une subscription et après un `invoice.paid`. La lecture commune accepte la forme Stripe Basil par items ainsi que la forme racine legacy et refuse les périodes multi-items divergentes. Les vues Pro affichent les bornes stockées pour une offre Stripe; pendant la migration, une absence déclenche un fallback legacy journalisé. Les offres non Stripe et les calculs commerciaux historiques restent inchangés.

Pour une facture créée par `invoice.paid`, le webhook résout séparément la période historique depuis les Invoice Lines récurrentes de la Subscription. Il transmet ce résultat aux trois chemins `subscription_create|subscription_cycle|subscription_update`; la ligne de commande le persiste dans son nom et les PDF continuent de lire ce snapshot. Des périodes identiques sont admises, des périodes divergentes sont explicitement ambiguës et utilisent le fallback Cotton legacy journalisé, jamais la période courante de la Subscription. Si `invoice.lines` est tronqué, seules les lignes complètes de cette Invoice sont récupérées auprès de Stripe.

## Update 2026-09-02 - Renouvellement Stripe contractuel des délégations hors cadre

Le checkout d'une nouvelle offre déléguée hors cadre persiste sur la subscription Stripe le premier snapshot explicite: référence contractuelle, assiette brute HT en centimes, offre client, offre catalogue, jauge et fréquence. Le Price reste net de la remise réseau et aucun coupon réseau n'est ajouté.

Au renouvellement, `invoice.upcoming` est l'unique chemin de write du `SubscriptionItem`: il relit ce snapshot, recalcule seulement la remise réseau courante, compare montant et intervalle puis écrit avec `proration_behavior=none` si nécessaire. `invoice.created` contrôle la divergence sans write; `invoice.paid` contrôle sans repricing, crée la commande puis aligne uniquement cette commande hors-cadre sur `amount_paid` et les taxes de l'Invoice Stripe. Une metadata contractuelle absente bloque le repricing sans fallback catalogue. Les extractions acceptent `invoice.subscription` puis `invoice.parent.subscription_details.subscription`.

Le guard partagé exige l'offre active exacte, la subscription locale exacte, la délégation exacte et `commercial_status=offre_deleguee_hors_cadre` depuis la couverture canonique; il est rejoué immédiatement avant tout write Stripe. Offres propres, propres avec délégation legacy, déléguées cadre et couvertures ambiguës restent hors chemin.

Depuis le correctif du 2026-09-03, le Product technique du nouveau Price n'est plus repris depuis le Price inline courant. Le snapshot offre/jauge/fréquence construit un `lookup_key` contractuel figé; le Price catalogue actif et unique correspondant fournit seulement un Product vérifié actif. Son `unit_amount` est ignoré. Lookup absent/ambigu, Price inactif ou incompatible, devise/récurrence divergente et Product absent/inactif bloquent le write. Les logs exposent les identifiants contractuels, le lookup et le support Stripe retenu sans secret.

### Évolution future du snapshot contractuel

Le snapshot lu au webhook est le dernier état contractuel explicitement validé de la subscription, pas nécessairement son état initial. Un renewal ne modifie jamais ce snapshot. Une future intention commerciale explicite via Stripe pourra le remplacer atomiquement; les renewals suivants liront la nouvelle version. Une évolution locale Cotton seule n'est jamais une intention commerciale. `checkout_v1` décrit uniquement la provenance du snapshot initial et n'est pas un format imposé par le reader aux futures références.

## Update 2026-09-02 - Contrat atomique métier Quick Schedule

Les constructeurs `generated_program` (Home/Agenda) et `fixed_content` (Bibliothèque générale ou Hub explicite) produisent désormais le même `SchedulePlan`: client, intention, contexte, date, Hub cible éventuel, nom, commande idempotente et liste ordonnée exacte des sessions avec heure, jeu, contenu, format et mode. La récurrence construit le même plan pour chaque occurrence. Toute validation de contenu, format, date, choix de Hub et ownership précède le commit.

Le commit commun `app_schedule_plan_commit(...)`, fourni par Global, fixe le Hub avant la création/configuration des sessions. Un Hub explicite reste autoritaire; un Hub général unique est transporté explicitement; plusieurs Hubs sans choix et une date occupée en `generated_program` échouent avant le writer. Le moteur Bibliothèque historique reste le configurateur du contenu fixed, mais son ancienne résolution Hub est neutralisée dans ce scope: le membership est créé ensuite par le commit commun.

Les tables Hub/idempotence étant MyISAM, le contrat repose sur compensation et non sur un faux rollback SQL. En cas d'échec, les memberships `schedule_plan`, sessions et éventuel Hub vide créés par la commande sont retirés; une compensation incomplète est journalisée et nettoyée avant reprise idempotente. Le succès n'est persisté qu'après contrôle du Hub actif, du client, du contexte/date, du nombre et de l'ordre des sessions configurées, et de l'unique membership actif de chaque session vers le Hub cible.

Le Dashboard consomme ce résultat. Son bootstrap résiduel reste limité à une migration legacy de sessions existantes sans membership; une date vide ne crée ni pivot événement ni Hub. Il ne constitue pas un mécanisme de réparation de Quick Schedule.

## Update 2026-09-02 - Déplacement et suppression cohérents d'un Hub

La modification de date transmet maintenant l'identifiant exact du Hub au service Pro puis Global. Le contexte persistant `soiree|event|day` n'est plus redéduit des `id_operation_evenement` des sessions. Le service déplace l'ensemble autoritatif des memberships actifs, y compris lorsqu'une ancienne opération partielle a déjà décalé leurs dates, refuse une autre racine Hub active sur la cible et ne confirme plus un échec Global comme un succès.

La lecture `/extranet/start/games/day/YYYY-MM-DD` résout d'abord un Hub existant sans mutation. Elle ne bootstrap un ancien programme que lorsque des sessions existent et qu'aucune n'a déjà de membership actif. Une date vide supprimée, ou des sessions encore possédées par un autre Hub, ne crée donc plus de Hub fantôme à chaque rechargement.

## Update 2026-09-02 - Chronologie canonique des membres Hub

Le Dashboard Pro projette désormais toute session ayant un membership actif depuis `games_hubs.hub_date`, comme le quick-add et la fenêtre de lancement du Hub. La date propre de `championnats_sessions` reste disponible pour le diagnostic de cohérence et demeure l'autorité d'une session hors Hub, mais elle ne peut plus faire passer isolément une carte en `Non jouée`, fermer le CTA global ou masquer son accès individuel pendant que le Hub est ouvert. Une replanification non lancée `futur -> aujourd'hui` reste donc pending/jouable; le trajet inverse `aujourd'hui -> futur` redevient à venir.

`Non jouée` reste une projection non persistée, produite seulement pour un runtime non terminé après fermeture de la fenêtre canonique. Les états runtime réellement terminés restent autoritaires.

## Update 2026-09-01 - Dashboard mobile: lecture Programme et démo active

Sous `992px`, les cartes Programme privilégient désormais une hauteur naturelle: intitulé/thématique et métadonnées ne sont plus comprimés, le renouvellement de playlist prend sa propre ligne, et les actions jeu/impression s'empilent. Pour une offre active, une carte dépliée expose aussi `Lancer un test` via le même POST historique `session_duplicate` que le prospect; elle reste hors Hub, numérique, limitée à deux joueurs et n'altère ni lancement, ni focus, ni session officielle. Pour une offre inactive, l'action principale de la carte devient `Faire la démo` et conserve exactement le même producteur historique. Le CTA officiel reste prioritaire dans la carte repliée; aucun rendu desktop n'est ajouté.

Une session officielle papier conserve sa métadonnée `Sur papier` quel que soit l'état commercial. Ses actions officielles `Grilles de jeu` / `Feuilles de jeu` restent disponibles, selon leurs guards historiques, uniquement pour une offre effective active; elles sont absentes sur mobile et desktop lorsque `access_state=inactive`. Pour ce prospect, si la démo numérique autonome est effectivement disponible, la carte mobile précise `Démo avec réponses sur smartphone` sous `Faire la démo`; la mention est absente pour une source smartphone, une démo indisponible ou une offre active. Cette projection réutilise la décision commerciale du Dashboard sans modifier le helper d'impression, le mode officiel ni le POST de démo.

## Update 2026-09-01 - Préparation Hub sans offre active

Le Quick Schedule et l'ajout d'une partie depuis le Dashboard Pro créent désormais une session **officielle** du Hub même lorsque le compte n'a pas d'offre active. La session conserve alors `id_offre_client=0`; elle n'est ni convertie en démo ni rattachée à un runtime de test. Le Mode démo et la dérivation de test restent des décisions distinctes au clic de test. Les gardes de lancement officiel, Master, Remote, capacité deux joueurs des démos, ownership et memberships Hub ne changent pas.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`.

## Update 2026-09-01 - Dashboard Hub: mode démo dans Actions

Le Dashboard utilise la décision commerciale déjà résolue par `app_ecommerce_offre_effective_get_context(...)`: seule la valeur `access_state=inactive` affiche le bloc `Mode démo`. Ce bloc est rendu par le même wrapper Actions que les CTA, avant Écran de diffusion et Télécommande. Il consomme directement `$url_ecommerce` et `$tarifs_commande_cta_label`, déjà calculés dans `ec.php` pour la navigation Pro: `Essai gratuit` devient « avant d’activer ton essai gratuit » / « Activer mon essai gratuit », `Je m'abonne` devient « avant de choisir ton abonnement » / « Choisir mon abonnement », et `Je commande` devient « avant de commander ton offre » / « Commander une offre ». Son introduction reprend le contexte Dashboard existant: « Ta soirée est prête… » pour la dynamisation et « Ton événement est prêt… » pour les autres usages; elle présente maintenant la démo comme le test du déroulé et de l’expérience Hub complète. Ce texte remplace intégralement l'ancien descriptif: aucune phrase historique du type « Pour lancer les parties avec tes joueurs… » n'est ajoutée après la nouvelle formulation. Programme ne contient plus aucun message commercial et conserve ses données, quick-add, cartes et refreshs partiels inchangés. Le CTA prospect global devient `Tester ma soirée` ou `Tester mon événement`, avec une aide décrivant l’écran diffusé et le test du déroulé; les wordings client actif restent intacts.

Sous `992px`, Actions devient visible pour ce contexte démo et conserve l’ordre Mode démo, Écran de diffusion, Télécommande; le contexte actif garde sa présentation mobile existante. Le bloc Pro conserve la famille de la couleur secondaire du Hub Master, mais l’emploie dans une surface claire à faible saturation, bordée et avec un texte foncé teinté par le branding: il ne concurrence donc pas `Tester ma soirée` / `Tester mon événement`. Son CTA commercial reste une action secondaire compacte. Sa typographie reprend celle des autres blocs Dashboard: titre de niveau Lots, sous-texte de niveau Programme et bouton secondaire compact mais visible. La sous-ligne Programme est masquée seulement lorsque Mode démo est rendu. La décision Remote réutilise ce même contexte commercial canonique: pour une offre inactive, un mode brut `required` est ramené à `optional`; la modale propose alors `Piloter avec la télécommande ?` et explique le QR ou la poursuite sur l'appareil courant. La sous-ligne de l'action Télécommande devient `Teste le pilotage de ta soirée depuis ton mobile.` en dynamisation ou `Teste le pilotage de ton événement depuis ton mobile.` dans les autres contextes prospect. Une offre active conserve strictement ses modes `none|optional|required`, ses guards et le wording `Pilote l’animation depuis ton mobile.`. Le QR, le polling, la poursuite sans Remote, le nouvel onglet, Hub Master et les règles runtime ne changent pas. La Télécommande continue de commander Master (`select_session`, `launch_session` ou `launch_hub_demo`) seulement après son garde de présence fraîche; elle n’est pas un accès joueur. Le runtime démo isolé et sa capacité de test restent inchangés.

À `360px`, tous les comptes bénéficient d’une respiration mobile accrue: espacement sous Retour agenda, entre les grandes cartes, dans l’en-tête, les Lots et Programme, et entre les cartes de parties; l’ajout de partie et les détails dépliés reçoivent aussi un inset vertical plus confortable. Aucun layout desktop n’est affecté.

Pour un prospect mobile, `Faire la démo` ne passe jamais par Hub Master ni Remote: le formulaire POSTe `session_duplicate`, qui délègue à `app_session_demo_source_resolve_or_create` et ouvre `/master/{token_demo}` dans un nouvel onglet. La démo dérivée est numérique, limitée à deux joueurs, hors Hub et en lobby; le resolver réutilise la copie si la source est inchangée et la synchronise si elle évolue. Avant ce POST, puis dans le contrôleur pour empêcher tout contournement direct, un Cotton Quiz papier appelle `app_session_quiz_digital_guard_get`; un refus affiche « Démo non disponible pour cette partie. » sans créer de démo. Sur mobile, les CTA Diffusion, Hub Master et Remote restent cachés; les comptes actifs et le desktop conservent leurs contrats.

## Update 2026-08-31 - Démo Hub dans le diagnostic Master

Pour une offre effective active, les cartes Programme ne rendent aucune démo avant la fenêtre et conservent uniquement leurs CTA officiels pendant celle-ci. L’unique démo de contrôle est accessible depuis le `hub-preflight-dialog` du Hub Master : elle crée une copie autonome d’une session représentative et l’ouvre dans un nouvel onglet sans modifier le Hub officiel. Le parcours offre inactive et son bloc commercial `Mode démo` restent inchangés.

## Update 2026-08-28/30 - Dashboard Pro canonique

La route `/extranet/start/games/day/YYYY-MM-DD` appelle directement l'unique renderer canonique du Dashboard dans tous les environnements. Les paramètres historiques `?ui=v1` et `?ui=v2` sont de simples paramètres inconnus et n'influencent pas le rendu: aucun helper, argument, champ de formulaire ni branche de version ne subsiste. L'alias `/dashboard` rejoint le même contrôleur. Le chargement initial, le renouvellement de thème, les modifications Format/Mode, le quick-add et le polling relisent tous la route canonique; chaque remplacement DOM exige le marqueur stable `data-dashboard-renderer="canonical"`, sans couplage à un numéro de version. Aucun rewrite, endpoint ni URL Hub Master/Remote/Play n'est ajouté ou modifié. Sous `992px`, le seul CTA `Résultats` d'une session moderne terminée appelle le producteur canonique du Master individuel Games avec l'intention terminale `master_view=individual`; il ne reconstruit aucun hostname et ne passe plus par `/extranet/start/game/view/{id_securite}`. Les CTA Préparer, Ouvrir le jeu et Reprendre, ainsi que le Dashboard desktop, restent inchangés.

Le Dashboard réutilise les données et les hooks DOM existants. L'audit de `games_hub_build_view_model()`, `games_hub_play_branding_payload()` et des styles `.hub-shell--master.main-section` prouve que le Hub Master n'affiche pas `background_1` en aplat exact: il l'intègre à 76–78 % dans un dégradé sombre fixe, puis utilise `background_2` pour les halos, bordures, focus et petits aplats. Le shell Dashboard reproduit donc ce contrat minimal avec les mêmes fallbacks `#240445` / `#bba9ff`: deux halos secondaires et un dégradé `#0c0316 → mix(primary 76 %, #07020f 24 %) → #05010b`. `Retour à mon agenda` reste blanc comme les éléments de premier plan du Master. Sur desktop, Header commun `Identité 6/12 | Visuel 6/12`, Actions, Lots puis Programme forment quatre niveaux. Lots est une carte compacte pleine largeur entre le CTA principal et Programme; Programme occupe ensuite toute la largeur. Les wrappers fonctionnels et hooks de refresh restent distincts. Les trois lots sont affichés sur une seule ligne en petites surfaces équilibrées et séparées par un gap, avec rang, médaille, libellé effectif et crayon discret; sous `576px`, ils s'empilent en conservant cette séparation. La cellule reste informative: seul le bouton crayon, nommé pour son rang et accessible au clavier, ouvre le formulaire inline existant sur le bon lot; un Dashboard terminé reste en lecture seule. Les valeurs proviennent toujours de `app_games_hub_prizes_get/save`; sans personnalisation, les fallbacks partagés `1ᵉʳ prix`, `2ᵉ prix`, `3ᵉ prix` restent visibles et non bloquants. Le raccord blanc entre Identité et Visuel, le contrat panoramique `5/2` et la respiration basse desktop restent inchangés. Sous `992px`, Header, Lots et Programme redeviennent trois surfaces blanches autonomes séparées par le fond sombre; le wrapper parent `.event-dashboard__event-card` est transparent, sans bordure, rayon, ombre ni padding, et le wrapper Actions est entièrement masqué sans espace réservé. Le DOM métier, le renderer et les hooks de refresh ne sont pas dupliqués.

Le menu `⋯`, très secondaire, reste en haut à droite. Sous `992px`, son seul pseudo-élément Bootstrap `dropdown-toggle::after` est masqué dans le scope Dashboard et son conteneur reçoit un léger inset supérieur/droit de `.35rem`: le bouton reste `⋯`, décollé de la bordure, avec la même cible, les mêmes actions et attributs accessibles. La colonne suit titre/badge/menu, métadonnées, accroche/description ou état vide, lieu, puis footer. Ces quatre groupes occupent toute la hauteur du visuel et partagent uniformément l’espace libre avec `justify-content:space-between`, tout en conservant un gap minimal commun. L’éditorial se contracte avant les éléments pratiques. Le lieu tient sur trois lignes compactes et disparaît entièrement sans donnée réelle; le footer aligne Infos à gauche et `Page publique ↗` à droite. L’URL client valide reste un texte non cliquable.

L'audit du contrat existant confirme un visuel panoramique `1600 × 640`, soit `5/2`: ce format est imposé au traitement d'upload et déjà utilisé par le composant historique comme par le rendu mobile. La V2 desktop reprend ce contrat à `width:100%; height:auto`: le visuel remplit sa demi-grille, sa hauteur découle uniquement du ratio et ne dépend jamais de la hauteur de l'Identité. La source branding Hub, le fallback et le contraste actuels restent inchangés, avec rayon constant et contenu masqué aux bords. Le libellé secondaire `Design` reste ancré en haut à droite du cadre et ouvre le parcours existant `Personnaliser le design`; logo bas-gauche et pastilles bas-droite partagent des marges internes constantes. Aucun overlay n'est positionné par rapport au conteneur extérieur.

À partir de `992px`, la ligne Actions occupe toute la largeur utile et son wrapper DOM reste l'unité de refresh. Avec un CTA principal seul, celui-ci utilise toute la ligne; avec Télécommande, la répartition reste proche de `2/3 | 1/3`. Diffusion conserve sa surface sombre, sa bordure secondaire de 3 px, sa copie blanche et ses petits aplats contrastés. Son hover/focus n'émet plus d'ombre externe: le feedback reste porté par la variation locale de fond/bordure, un inset léger et une translation de 1 px, afin de ne pas assombrir la carte Lots située dessous. Remote conserve son contrôle ghost secondaire, ses propres hover/focus et son contrat fonctionnel. Sous `992px`, cette exposition Dashboard de Master et Remote disparaît entièrement; leurs guards, tokens, modales, routes et comportements restent inchangés. Réduction de mouvement et sauvegarde Ajax Design restent inchangées.

Le markup canonique donne au CTA principal une icône issue de l'état temporel déjà résolu — diffusion/prévisualisation, reprise ou résultats — et conserve exactement `$dashboard_primary_label`. Son repère supérieur stable est `ÉCRAN DE DIFFUSION`. Une ligne pédagogique, résolue depuis les mêmes états de présentation, décrit uniquement l'écran montré aux joueurs. Télécommande reçoit une icône smartphone et une hiérarchie en trois lignes: `TÉLÉCOMMANDE`, `Afficher le QR code`, puis `Pilote l’animation depuis ton mobile.`. Une flèche ronde porte l'affordance secondaire; aucun ancien kicker ou pastille QR alternatif n'est rendu.

Aucun statut `Connectée` / `Non connectée` n'est affiché dans la carte Actions: la présence Remote n'est pas disponible dans les données SSR ni dans le refresh HTML. Elle reste volontairement lue par `dashboard_master_access_check` uniquement au clic ou pendant une modale visible. Le renderer ne lance donc aucune lecture initiale, n'ajoute aucun polling et ne transforme pas un état local en source de vérité. Les conditions Remote/Master, leur ordre fonctionnel et leurs guards ne changent pas.

Le shell de modale existant charge deux parcours distincts. `Personnaliser le design` contient seulement visuel, logo, couleurs, retour au design Cotton et option de design par défaut disponible; le nom et les champs éditoriaux en sont absents. `Informations de la soirée` / `Informations de l’événement` contient le nom, l'accroche, la description et les informations publiques existantes. Les groupes Identité et Présentation y conservent le rythme partagé `.78rem`. Les deux formulaires publient une portée explicite vers le handler `personalization_save` existant: celui-ci exécute seulement les mutations branding ou publication/lieu déjà en place, sans nouvel endpoint ni sauvegarde parallèle. La portée `full` reste disponible pour l'appel direct de la modale, sans constituer un renderer Dashboard alternatif.

Programme reste en dehors du `header` et conserve son conteneur, son refresh partiel, quick-add et tous ses hooks métier. Chaque carte présente la vignette puis `Jeu · Thématique`, la méta et le renouvellement existant. Sous `992px` seulement, la carte repliée expose d'abord le parcours individuel historique de sa session. `ec_start_day_session_individual_access_get(...)` délègue chronologie et fin à `app_session_display_chronology_get(...)` / `app_session_edit_state_get(...)`, l'autorisation à `app_session_launch_guard_get(...)` et l'URL à `app_session_get_link(..., 'launcher', ..., flag_direct_launcher=1)`. Pour les types modernes `4|5|6`, ce producteur Global construit depuis `$conf['games_url'][$conf['server']]` la route individuelle Games `/master/{id_securite}`; elle est distincte de `/hub/{hub_token}/master` et aucune origine n'est reconstruite dans Pro. Les libellés mobiles historiques restent conditionnels: `Préparer` en chronologie `before`, `Ouvrir le jeu` pour une session ouvrable encore pending, `Reprendre` pour une session démarrée et `Résultats` après terminaison/fermeture. Ce dernier utilise toujours la fiche historique Pro `/extranet/start/game/view/{id_securite}` dans l'onglet courant; les trois actions de lancement/reprise ciblent Games dans un nouvel onglet. Le CTA launcher est absent sans producteur Games prouvé, contenu configuré ou autorisation historique. Pour une offre active, les cartes papier gardent ensuite l'action compacte existante avec le SVG imprimante inline déjà employé par Pro: `Feuilles de jeu` pour Blind Test/Cotton Quiz, `Grilles de jeu` pour Bingo Musical; aucune police d'icônes, URL ou générateur supplémentaire n'est introduit. Pour une offre inactive, cette action officielle est absente sur mobile et desktop sans modifier la métadonnée papier. Smartphone ne reçoit aucune action d'impression. Primaire et impression partagent une ligne bornée à 38 px; le primaire prend l'espace restant et l'impression est tronquée proprement si nécessaire. Le chevron reste un bouton séparé qui déplie les détails. La carte repliée ne rend plus la suppression. Tous les panneaux ouverts partagent `DURÉE | RÉPONSES`, puis `PLAYLIST` ou `SÉRIE(S)`. `Voir le détail` reste le lien le plus discret. `Choisir une autre playlist` / `Choisir une autre série` réemploie le même URL catalogue et devient un petit bouton secondaire local; les états non éditables restent absents comme avant. Quand le guard historique l'autorise, l'unique formulaire `session_delete` est rendu en dernier dans les détails sous l'action secondaire `Supprimer la partie`, avec la confirmation et les champs existants. Le formulaire Dashboard historique `Lancer une démo`, le wrapper `.event-dashboard__session-details-actions`, l'impression et la note spécifiques aux grilles de démo Bingo sont supprimés: leur seul producteur était le Dashboard et aucun accès à la démo correspondante n'y subsistait. Le parcours légitime `Tester` de la fiche session conserve `session_duplicate` et son ouverture Master. États `none|optional|required`, résultats et routing runtime restent inchangés.

Sous `992px`, Programme affiche après son titre et ses compteurs, avant l'ajout et les cartes, une recommandation non bloquante vers un ordinateur ou une tablette paysage. Une offre effective inactive, toujours résolue par `app_ecommerce_offre_effective_get_context(...)`, reçoit `Découvre l’expérience complète` et le texte prospect commun soirée/événement. Une offre active reçoit `Prêt à diffuser ?`, puis la variante `ta soirée` ou `ton événement` issue de `$day_is_dynamisation_context`. L'encart n'a ni CTA, ni QR, ni modale; il est masqué sur desktop. Sa visibilité temporelle consomme `has_started_session`, désormais exposé par `ec_start_day_dashboard_temporal_projection_get(...)` depuis son calcul canonique existant sur `running|suspended|completed`: il reste visible avant le premier lancement, disparaît dès qu'une session a commencé ou repris, et reste absent sur un Dashboard terminal. Les CTA officiels, démos, impression, Master/Remote, routes, navigation, focus et chronologie ne changent pas.

La visibilité Bibliothèque est désormais bornée par l'état métier commun: `ec_start_day_session_content_detail_available(...)` consomme uniquement `is_pending/is_terminated` issus de `app_session_edit_state_get(...)`. `Voir le détail` reste donc présent avant démarrage, puis disparaît en cours et terminé pour Blind Test, Bingo Musical et Cotton Quiz, sur desktop comme mobile. Les liens `Choisir une autre…`, la page Bibliothèque et ses guards ne changent pas.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_v2_style.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_library_hub_add_flow_test.php`.

## Update 2026-08-28 - Programmateur Pro: nom canonique, paramètres allégés et aides contextuelles

Le programmateur rapide `/extranet/start/games/quick-schedule` propose désormais `Nom de la soirée` ou `Nom de l’événement` au-dessus du bloc temporel `Quand ?`. Le champ est prérempli par le fallback canonique `Soirée Cotton` / `Événement Cotton`, reste facultatif dans l’interface et alimente le `hub_label` créé via le 5e argument existant de `app_games_hub_get_or_create_for_context(...)`. Un champ laissé vide ou inchangé conserve le rendu final historique; un nom personnalisé devient le titre canonique du Dashboard et reste modifiable par `Personnaliser la soirée` / `Personnaliser l’événement`.

La page entière repose sur trois niveaux typographiques: titre de page, titre de section, label de paramètre. `Nom de la soirée/événement`, `Quand ?` et `Quel programme ?` partagent le composant `quick-schedule-section-title` sur desktop et mobile; le nom n'est rendu qu'une fois et son texte continue d'étiqueter le champ via `aria-labelledby`. Les six sous-titres principaux `Date`, `À partir de`, `Jeu`, `Combien de parties ?`, `Durée de chaque partie` et `Comment jouent les participants ?` partagent strictement `quick-schedule-field-label` et son texte interne `quick-schedule-field-label__text`, avec les mêmes famille, taille, style, graisse, couleur, casse, interligne, marges, alignement et aides info lorsqu'elles existent, sur mobile comme sur desktop. Les champs de récurrence réutilisent la même grammaire parente. Sous `992px`, le regroupement visuel reste porté par les cartes, sans surtitre `Identité et date` qui créerait un quatrième niveau; `Récapitulatif` rejoint le même niveau de section uniquement sur mobile.

Sous `992px` uniquement, les choix sont plus denses sans descendre sous 40 px de hauteur: pour supprimer tout état intermédiaire `2 + 1`, les trois jeux sont empilés en une colonne jusqu'à `575.98px`, donc à 360/430 px, puis la grille adaptative les aligne sur une seule ligne dès le palier supérieur, notamment à 768 px. Les cinq quantités restent sur une ligne, et durée comme smartphone/papier occupent chacune deux colonnes. Les sélecteurs de durée montrent seulement `20 min` et `10 min`; leurs détails `40 titres` / `20 titres` restent visibles sur desktop et conservés dans l'`aria-label`, sans modifier valeurs, mapping ou durée réelle. Sur mobile, le récapitulatif masque la couverture et neutralise la surface de `quick-party-card`: son texte commence sur le même axe que `Récapitulatif` et sa date réutilise le libellé existant sous la forme naturelle `mercredi 2 septembre · à partir de 19h00`, tandis que la récurrence conserve son détail. À partir de `992px`, la grille trois colonnes, la carte récapitulative avec son visuel `1200/640`, les libellés de durée détaillés, la date en capitales, les espacements et les CTA restent inchangés. Champs, aides, états, validation, valeurs POST, récurrence, création Hub/sessions et navigation post-création ne changent pas.

`Quel programme ?` conserve les jeux et contrats existants, dans l’ordre `Jeu`, `Combien de parties ?`, `Durée de chaque partie`, `Comment jouent les participants ?`. Les titres, marges externes et espacements entre grands groupes suivent le même rythme structurel que la colonne `Nom` / `Quand ?`; la hiérarchie vient uniquement des composants. Le jeu utilise ainsi un gabarit plus généreux et un état sélectionné Cotton plein, tandis que quantité, durée et mode partagent un gabarit secondaire compact. Les formats restent les IDs standard/court existants et s’affichent durée puis contenu sur une ligne. Le raccourci UI expose seulement `1..5`, avec `3` par défaut; la validation serveur conserve sa capacité historique `1..10`. Smartphone et papier restent les deux valeurs `1|0`, rendues par le même composant symétrique sans description.

Six textes seulement portent une aide `info-circle`: le titre Nom, puis les labels `Date`, `À partir de`, `Jeu`, `Combien de parties ?` et `Comment jouent les participants ?`. Le nom précise qu’il est affiché aux participants; Date rappelle que les parties sont jouables uniquement le jour programmé; l’horaire est présenté comme indicatif pour les participants; Jeu et Nombre précisent que d’autres éléments pourront être ajoutés après programmation; l’aide Mode recommande une bonne couverture mobile, idéalement en 4G ou plus, pour une expérience fluide sur smartphone. La phrase Nombre n’est plus affichée en permanence sous `1..5`. Le composant local utilise un bouton accessible et un popover absolu sans décalage du layout, ouvert au hover, au focus ou au tap et fermé par nouveau tap, clic extérieur, perte de focus ou `Escape`. Les associations natives `label for` de Date et À partir de restent conservées; tous les paramètres partagent désormais la même marge basse `.3rem`, avec un gap `.35rem` avant l'icône éventuelle. Aucun autre contrôle ou contrat de soumission n’est modifié.

Le titre du champ de nom reste singulier en programmation simple (`Nom de la soirée` / `Nom de l’événement`) et devient pluriel tant que la récurrence est active (`Nom des soirées` / `Nom des événements`), sans changer la valeur ni le pipeline `hub_label`. Dans ce mode, l’affichage Flatpickr de `Jusqu’au` utilise `JJ/MM/AAAA`; sa valeur soumise reste ISO et le récapitulatif conserve ses dates françaises longues. La légende textuelle sous Date est supprimée sur mobile et desktop: l'état sélectionné et le repère violet des dates déjà programmées restent portés directement par les cellules Flatpickr, sans nouvelle requête ni changement de détection.

Dans la confirmation, le H2 générique `Ta soirée` / `Ton événement` / `Tes soirées` est supprimé: le nom personnalisé devient directement la première information textuelle du corps de carte. La métadonnée Programme forme une phrase fondée sur la durée réelle du format, par exemple `3 parties de 20 min sur smartphone` ou `2 parties de 10 min sur papier`; les volumes `40 titres` / `2 séries` restent détaillés dans les choix desktop et leurs libellés accessibles mais ne sont plus répétés dans le récapitulatif. En récurrence, une à trois occurrences conservent la présentation par dates. À partir de quatre occurrences créables, la carte affiche la règle canonique synthétique selon la fréquence et le jour choisis, bornée par la première et la dernière date effectivement produites, par exemple `Tous les vendredis du 28 août 2026 au 25 décembre 2026`. La date, le seul horaire global `À partir de`, l’espacement technique d’ordre, les thématiques automatiques, la création, l’idempotence, la récurrence serveur et la navigation post-création ne changent pas.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_quick_schedule.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_quick_schedule_ui_test.php`.

## Update 2026-08-27 - Dashboard Hub: ajout rapide autorisé en préparation

Le Dashboard Pro peut de nouveau ajouter une partie à un Hub futur. Son garde quick-add accepte explicitement les états temporels canoniques `before` et `open`, puis appelle le point d'entrée Global dédié `app_programming_quick_hub_create_from_dashboard_preparation(...)`. Les états `expired` et `invalid` restent refusés avec le contrat JSON existant.

Cette exception est strictement limitée à la préparation depuis le Dashboard. Elle ne modifie ni `launch_window_open`, ni l'éligibilité Master/Remote, ni le lancement/reprise, ni les routes runtime. Le texte d'état vide reste cohérent: futur avec Programme vide `Ajoute une première partie`; futur avec Programme existant `Ajoute une autre partie`; toutes sessions closes mais état `open`, l'ajout reste proposé.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-08-27 - Dashboard Hub: révision comme signal de convergence

Le Dashboard utilise `preparation_revision` comme signal d'invalidation de sa projection, et non comme verrou ou preuve d'un conflit externe. Les succès AJAX Personnalisation, Lots, renouvellement de thématique, Format/Mode et quick-add exposent toujours la révision canonique calculée après écriture; le navigateur avance ainsi sa baseline et évite un GET redondant quand son DOM a déjà été remis à jour.

Chaque contrôle léger mémorise la génération locale au départ de sa requête. Si une mutation locale est acquittée avant le retour HTTP, cette réponse devenue antérieure est ignorée puis un contrôle frais peut être rejoué.

Une révision différente déclenche maintenant le refresh partiel canonique sans message utilisateur lorsque le Dashboard est libre. Si une saisie, une modale ou une requête locale est active, la révision reste mémorisée et le refresh se rejoue automatiquement dès que cette activité se termine, sans fermer ni écraser l'état local. Un acquittement local ne supprime jamais une révision déjà en attente: le HTML serveur frais reste relu afin d'absorber une éventuelle mutation intervenue en parallèle. Le composant de synchronisation et son CTA `Réessayer` ne deviennent visibles qu'après un échec technique du refresh.

Les composants de `preparation_revision` restent l'identité métier Hub, les memberships, les sessions/fingerprints, les réglages et les lots. Les accès/tokens et présences Remote/Master restent exclus. Le polling Remote, la décision Master `none|optional|required` et l'ouverture nouvel onglet ne changent pas.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-08-27 - Dashboard Hub: parcours Master / Remote et accès Télécommande autonome

Le Dashboard Hub conserve deux accès distincts. Le CTA autonome historique `Télécommande / Afficher le QR code` ouvre sa propre modale Bootstrap avec un QR vers `/hub/{remote_token}/remote`; son token est fourni au rendu par `app_games_hub_remote_access_get_or_create(...)`. Sa visibilité SSR réutilise exactement le mode métier canonique calculé pour le Hub courant: masqué en `none`, visible en `optional|required`. À chaque ouverture seulement, la modale autonome utilise le même contrôle frais `dashboard_master_access_check` que le flow Master pour détecter la présence effective. Le CTA Hub Master attend une éventuelle mutation Programme papier/numérique en vol, puis appelle cette décision fraîche, qui relit les memberships et états canoniques, recalcule `remote_access_mode`, et retourne présence Remote et URLs Master/Remote utiles. Aucun dataset SSR ne décide du parcours Master et aucun onglet blanc n'est pré-ouvert.

- `none`: aucune session réellement activable dans la fenêtre canonique courante, Hub futur/prévisualisation, programme vide ou résultats/read-only. L'endpoint Master ne lit pas la présence Remote et ne crée pas d'accès Remote; Master s'ouvre dans un nouvel onglet sans modale Master, QR Master ni polling. Le CTA Télécommande autonome est lui aussi masqué. Une fenêtre quick-add éventuelle ne change pas ce résultat.
- `optional`: il reste uniquement des sessions numériques activables. Remote déjà présente au contrôle frais: Master s'ouvre directement dans un nouvel onglet. Remote absente: modale QR et CTA `Continuer sans télécommande`. Tant que la modale reste ouverte, le polling suit aussi bien connexion que déconnexion; l'état connecté reprend exactement le libellé métier initial du Dashboard (`$dashboard_primary_label`).
- `required`: au moins une session papier est réellement activable dans la fenêtre courante. Remote déjà présente: Master s'ouvre directement dans un nouvel onglet. Sinon, la même modale affiche le besoin papier et le libellé métier initial du Dashboard dans un CTA désactivé. Connexion: CTA activé; déconnexion: retour immédiat au QR et CTA désactivé. Le clic final refait un dernier contrôle frais avant ouverture. `completed`, `terminated`, `past`, `not_played`, fenêtre future ou expirée et runtime terminal restent exclus; une fenêtre fermée impose toujours `none`, même si un runtime résiduel paraît reprenable.

Le polling partagé n'existe que lorsqu'une des deux modales Remote est visible. Il utilise l'endpoint canonique, une cadence récursive de 2 s, un garde anti-chevauchement et un identifiant de génération qui invalide les réponses tardives. Côté Master, il reste bidirectionnel et s'arrête sur clic final réussi, continuation sans Remote, annulation/fermeture ou destruction de page — jamais sur la seule détection positive. Côté autonome, il démarre par un contrôle frais à chaque ouverture; Remote absente, il affiche le QR et `En attente de la télécommande…`; Remote déjà ou nouvellement présente, il affiche `Télécommande connectée`, stoppe le polling puis ferme la modale après 900 ms. Fermeture manuelle, `hidden.bs.modal`, réouverture et `pagehide` invalident proprement le flow courant. Tous les chemins Master utilisent `openMasterInNewTab(...)`; aucun fallback ne remplace le Dashboard courant.

Les wordings sont alignés sans redesign: autonome `Ouvrir la télécommande`; Master optional `Piloter avec la télécommande ?`; Master required `Ouvre la télécommande`; les trois réutilisent le même texte de scan et les mêmes feedbacks attente/connecté. Les footers restent spécifiques: continuation sans Remote en optional, blocage en required, fermeture automatique sans CTA de continuation en autonome.

Les refreshs HTML partiels resynchronisent ensemble le CTA Remote autonome, sa modale dédiée et son initialisation QR. Une transition serveur `none → optional|required` peut donc ajouter le CTA et sa cible Bootstrap sans reload complet; la transition inverse retire la modale lorsqu'elle n'est pas ouverte. Le flow Master reste indépendant et inchangé.

La convergence Programme reste indépendante du parcours Master/Remote. Une différence de révision ne produit plus de garde ni de message attribuant le changement à un autre écran; elle entraîne un refresh automatique immédiat ou différé jusqu'à la fin d'une activité locale.

Pour le parcours Master, l'URL/token Remote via `app_games_hub_remote_access_get_or_create(...)` n'est demandé par l'endpoint frais que pour `optional|required` avec Remote absente. Séparément, le rendu du CTA autonome réutilise `ec_start_day_dashboard_remote_access_mode_for_hub_get(...)` avec les sessions Hub déjà chargées et ne demande son accès canonique qu'en `optional|required`; aucun AJAX ni polling n'est lancé au chargement initial. Lorsque l'une des modales est ouverte, `app_games_hub_remote_presence_gate_get(...)` reste l'unique autorité Global de présence via `dashboard_master_access_check`. Les routes `/hub/{hub_token}/master` et `/hub/{remote_token}/remote`, Hub Master/Remote runtime, quick-add, routage, IDs runtime et DB restent inchangés.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-08-25 - Dashboard Hub: convergence autonome légère

Le dashboard Hub `/extranet/start/games/day/YYYY-MM-DD` ne dépend plus uniquement de `visibilitychange`, `pageshow` et `focus` pour converger après une mutation de préparation faite depuis Hub Remote ou Hub Master. Ces événements restent des accélérateurs, mais un poll léger borné vérifie maintenant la `preparation_revision` canonique toutes les 12 secondes quand le Dashboard Hub est visible.

Le tick appelle seulement l'action Pro `dashboard_program_revision_check`, qui valide le Hub du client puis lit `app_games_hub_remote_business_revisions_get(...)`. Si la révision est identique, aucun HTML Programme n'est chargé et aucun DOM n'est reconstruit. Si elle diffère, le refresh partiel Dashboard existant est réutilisé automatiquement. Une édition de lots, une édition Format/Mode, une modale active, un renouvellement de thématique ou une requête en cours diffèrent silencieusement ce remplacement jusqu'à la libération de l'interface. Seul un échec de chargement affiche le retry technique `Réessayer`.

Ce poll Dashboard n'est pas un temps réel. Il est suspendu quand toutes les sessions du Hub sont terminées et que la fenêtre d'ajout rapide est fermée (`launch_window_open=false`), afin de conserver le cas réactivable où le Hub paraît terminé mais peut encore recevoir une partie.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-08-26 - Dashboard Hub: modales Remote finalisées

Les modales Dashboard liées à la télécommande ont été resserrées sans changer les gardes métier. La modale `Ouvre d’abord la télécommande` conserve le QR Remote existant, affiche le texte court `Certaines parties se jouent sur papier. Tu auras besoin de la télécommande pour vérifier les inscriptions et les lancer.`, et son CTA de retry reprend le même `$dashboard_primary_label` que le CTA principal Dashboard (`Diffuser la soirée`, `Diffuser l’événement`, `Reprendre la diffusion`, etc.).

La modale `Télécommande mobile` ne rend plus l'URL texte ni le bouton `Copier`; seul le QR reste visible. Son aide reprend le contexte existant soirée/événement et indique le pilotage à distance sans revenir sur l'appareil qui diffuse. Les QR Remote Dashboard deviennent cliquables seulement quand la configuration canonique `$conf['server']` vaut `dev`; en production, aucun lien ni handler interactif n'est rendu autour du QR.

Le bouton secondaire `Annuler` du garde papier porte une classe locale `dashboard-paper-remote-gate__cancel` avec couleurs forcées sur normal/hover/focus afin de rester lisible malgré les règles Pro partagées sur `.btn` / `.btn-light`.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-08-25 - Dashboard Hub: mutations Programme horodatées

Les modifications de format, mode smartphone/papier et contenu effectuées depuis le Programme du Dashboard Hub mettent maintenant à jour `championnats_sessions.date_maj`. Hub Master détectait déjà ces changements par son refresh partiel; Hub Remote peut désormais les voir sans reload via les révisions de préparation Global puis `business_snapshot`.

Le correctif reste borné à l'horodatage des mutations existantes dans `ec_start_dashboard_program_update(...)`: validations Pro, conversions Quiz, régénération Bingo, remplacement de contenu et gardes d'édition restent inchangés.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_dashboard_program_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-07-31 - Dashboard Hub: QR télécommande mobile

Le Dashboard Hub journée affiche maintenant un CTA `Télécommande` actif quand la page est éditable et qu'un Hub existe. Le CTA ouvre une modale Bootstrap avec QR code et lien copiable vers `/hub/{remote_token}/remote`, généré par le service Global `app_games_hub_remote_access_get_or_create(...)`.

Le token Remote est distinct du token Hub public Master/Play. La vue Pro ne journalise pas le secret et ne donne pas accès aux routes Master; elle se limite à exposer le lien Remote via QR/copie. Si le service Remote n'est pas disponible, le CTA reste désactivé avec une raison courte au lieu d'un faux état “bientôt disponible”.

La régénération manuelle du token n'est pas encore exposée dans cette UI Lot 1; le service Global dispose du point de génération/révocation pour une future action opérateur.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-07-31 - Dashboard Hub live refresh élargi

Le dashboard journée Hub `/extranet/start/games/day/YYYY-MM-DD` utilisait déjà un refresh HTML partiel après ajout rapide de partie et au retour/focus depuis le Hub. Ce refresh remplaçait seulement le bloc Programme et la ligne méta d'horaire, ce qui pouvait laisser la chip de statut, le CTA Hub Master et les lots dans leur état initial.

Le remplacement HTML existant couvre maintenant aussi `.event-dashboard__eyebrow` pour le contexte/statut, `.event-dashboard__header-actions` pour les accès Remote/Hub Master et `[data-dashboard-prizes]` pour le bloc Lots. Les protections existantes sont conservées: pas de remplacement automatique pendant une édition de lots, une édition Format/Mode, un renouvellement de thématique ou une modale active.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-07-30 - Dashboard Hub: bilan via contexte Global Hub

Le bilan du dashboard journée/soirée `/extranet/start/games/day/YYYY-MM-DD` transmet maintenant l'`id_hub` explicite déjà résolu par `ec_start_sessions_day.php` à `ec_start_day_bilan_get(...)`. Quand le helper Global `app_games_hub_render_context_get(...)` est disponible, le bilan consomme son `aggregate_ranking` au lieu de relancer le contexte historique par période.

Le fallback historique `app_client_joueurs_dashboard_get_context_for_period(...)` est conservé uniquement si aucun Hub explicite n'est fourni ou si le helper Hub n'est pas disponible. Pro ne déduit aucun Hub depuis une date et ne réimplémente ni tri, ni scores, ni fallback stats.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Update 2026-07-30 - Quick-schedule: rattachement Hub atomique

Le quick-schedule Pro assure désormais explicitement le rattachement Hub de chaque session créée avant la vérification finale. Après résolution du Hub, le flux appelle `app_programming_quick_hub_membership_ensure(...)` pour tous les `created_session_ids`; ce wrapper délègue à la commande canonique Global `app_games_hub_session_membership_ensure(...)`, puis le flux relit les memberships actifs via `app_games_hub_sessions_get(...)`.

Cette étape évite qu'une session créée par quick-schedule reste orpheline lorsque le Hub existe déjà avec des memberships actifs considérés comme autoritaires par la réconciliation Global. Les erreurs d'idempotence incluent aussi le `hub_status` retourné par Global pour faciliter le diagnostic d'un blocage de contexte.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-07-28 - EC Communauté: classement saisonnier agrégé

La page Communauté / Mes joueurs consomme le `aggregate_ranking` saisonnier fourni par Global au lieu de rendre les classements séparés par jeu. Le filtre de saison existant reste inchangé.

Chaque ligne affiche désormais `X victoire(s) · Y podium(s) · Z partie(s)` via le helper commun Global. Le score agrégé reste disponible uniquement comme donnée technique de tri dans le contrat Global et n'est plus affiché dans ce classement saisonnier. Les identités suivent le contrat Global: fusion seulement sur joueur Play/Global fiable, jamais sur pseudo.

Addendum 2026-07-29: le rendu agrégé conserve le podium Pro au-dessus du tableau en projetant les rangs 1 à 3 du `aggregate_ranking` dans le renderer podium existant. Le podium ne recalcule pas les scores, rangs ou compteurs; il réutilise strictement les lignes agrégées Global.

Fichiers de référence:
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_shared.php`;
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`;
- `pro/web/ec/modules/compte/client/ec_client_view.php`;
- `global/web/app/modules/entites/clients/app_clients_functions.php`.

## Update 2026-07-28 - EC: suppression du menu legacy `Mes événements`

Le parcours client EC n'expose plus l'ancien menu `Mes événements`. La cause historique était une requête de navigation dans `web/ec/ec.php` sur `operations_evenements`, affichée pour les clients non gamification dès qu'une ancienne opération événement non démo restait récente ou à venir. Cette règle pouvait réapparaître après un changement d'usage BO.

La règle canonique est désormais: Home, Agenda et Communauté utilisent l'Agenda Hub `/extranet/start/games` et les dashboards journée. Les pages utilisateur legacy `operations/evenements` `list`, `view` et `form` redirigent vers l'Agenda Hub. Les rewrites, modules legacy, scripts, widgets, tables et données sont conservés pour compatibilité technique/support; ils ne doivent pas redevenir des entrées client visibles.

Fichiers de référence:
- `pro/web/ec/ec.php`;
- `pro/web/ec/modules/communication/home/ec_home_index.php`;
- `pro/web/ec/ec_legacy_events_navigation_test.php`.

## Update 2026-07-28 - Dashboard/Archives Hub: membership canonique et reactivation

Le dashboard journee `/extranet/start/games/day/YYYY-MM-DD` et les groupes Archives resolus sur un Hub utilisent maintenant les sessions membres actives `games_hubs_sessions` via `app_games_hub_sessions_get(...)` comme source de compteur et de liste. Cela corrige les ecarts de type Hub Master `5`, dashboard `5`, Archives `4` quand une session ready/non jouee a ete ajoutee apres minuit mais reste membre du Hub courant.

Sur `/extranet/start/games/archives`, l'elargissement Hub se fait desormais avant le groupement des dates: la liste source est dedupliquee avec les memberships actifs des Hubs trouves sur les dates chargees, tout en conservant les filtres explicites jeu/date. Le filtre d'historique utile ne peut donc plus retirer une session membre Hub du listing archive hors dashboard.

L'etat `Termine` signifie seulement que toutes les sessions membres courantes sont closes. Il ne rend pas le Hub definitivement ferme: l'ajout rapide dashboard reste disponible jusqu'a `J+1 12:00:00` Europe/Paris si `hub_temporal_state.launch_window_open=true`, puis il est refuse par JSON `409` avec `hub_quick_add_window_expired`.

Les listes Pro generales encore basees sur leur logique calendrier historique restent hors scope hors groupe Hub resolu. Aucun changement sur creation Hub, suppression, resultats, podiums, scores, rangs, joueurs, lots ou memberships.

Fichiers de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-07-28 - Dashboard Hub: sessions ouvertes jusqu'a J+1 midi

Le dashboard dedie `/extranet/start/games/day/YYYY-MM-DD` utilise maintenant la chronologie session canonique `app_session_get_chronology(...)` pour les cartes du Programme. Une session Hub datee de la veille reste donc active avant midi local plateforme, au lieu d'etre presentee comme archivee des minuit.

Cette même chronologie unitaire alimente le contexte temporel global du Dashboard. Tant qu'au moins une session non close est `during`, y compris le matin de J+1, le badge reste `Aujourd'hui` et le CTA propose `Diffuser la soirée` / `Diffuser l'événement`; un runtime `running|suspended` reprenable produit `En cours` et `Reprendre la diffusion`. La pastille Programme `N connecté(s)` consomme elle aussi ces classes canoniques et reste visible dans la fenêtre ouverte. La date civile `past|today|upcoming` ne peut plus reclasser une fenêtre canonique ouverte en `À venir` / prévisualisation ni masquer ce compteur. Après J+1 12:00 ou lorsque toutes les sessions sont réellement closes, la projection terminale existante reste inchangée.

Les autres consommateurs du même Dashboard suivent la même autorité: le Programme conserve son ordre actif, l'état vide ne masque pas l'ajout rapide, et la page événement avec sa personnalisation reste accessible tant que la chronologie vaut `before|during`. Le polling ne reconstruit plus un terminal depuis les libellés des sessions: il se suspend depuis le contexte canonique en lecture seule, y compris pour `not_played` après cutoff.

Le correctif est volontairement borne au dashboard Hub et a ses cartes Programme. Les listes et agendas Pro generaux qui classent encore par `CURDATE()` ne sont pas elargis dans cette passe: leur statut archive/non-highlight reste distinct de l'autorite technique de lancement et reprise portee par Global/Games.

Fallback temporel: aucune colonne timezone Hub/client fiable n'est introduite; le fuseau plateforme centralise reste `Europe/Paris` via Global. Aucun changement sur DB, creation Hub, rattachements, suppression, quick schedule, participations, resultats, tri ou rangs.

Fichiers de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`.

## Update 2026-07-28 - Dashboard/auth: notices PHP supprimées

Le dashboard journée initialise désormais les états de conseil `dashboard_all_sessions_closed` et `dashboard_has_started_session` depuis les sessions du Programme déjà construites, avant toute lecture. Les cas sans session, sessions futures, session en cours et sessions terminées gardent les branches de conseil existantes sans masquer une donnée métier par un simple `isset()`.

Le script d'authentification initialise `session_init` avant les flux backoffice, formulaire et lien temporaire; les redirections et le retour dashboard ne changent pas. Le widget CTA sessions initialise aussi `cta_presentation` à une valeur neutre pour conserver le rendu carte par défaut.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`;
- `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-07-27 - Dashboard titre: hub_label canonique prioritaire

Le dashboard journée `/extranet/start/games/day/YYYY-MM-DD` reprend maintenant l'identité explicite du Hub déjà résolu pour la journée. Lorsqu'un Hub actif possède un `hub_label` non vide et non legacy, ce label est la source principale du titre affiché dans le header Dashboard.

La cascade est: `games_hubs.hub_label` explicite, puis titre événement historique explicite si aucun label Hub exploitable n'existe, puis fallback de contexte (`Soirée Cotton` ou `Événement Cotton`). `id_operation_evenement`, le titre d'opération legacy, la typologie courante du compte et le contexte dynamisation/gamification ne sont pas des autorités prioritaires de titre. Aucune copie du titre dans les sessions n'est nécessaire; le Dashboard et le Hub Master doivent présenter la même identité Hub.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-07-26 - Dashboard Programme: renouvellement automatique

Le dashboard soirée/événement aligne le renouvellement automatique des thématiques sur le comportement Hub Master/Games. Après une proposition appliquée, le bloc Programme Pro peut être relu et remplacé depuis le rendu serveur canonique; l'état de renouvellement est donc conservé par session et réattaché aux cartes recréées.

Les exclusions temporaires restent locales à la page, bornées à 24 entrées et alimentées uniquement par `previous_selection` renvoyé par le serveur. Elles sont transmises à Global via `temporary_exclusions` pour éviter de reproposer immédiatement les mêmes thématiques, sans persistance navigateur.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`.

## Update 2026-07-26 - Dashboard Programme: refresh au retour du Hub

Le dashboard canonique `/extranet/start/games/day/YYYY-MM-DD` conserve son ouverture du Hub Master dans un nouvel onglet. À chaque retour au premier plan après masquage, il vérifie le Programme depuis le serveur en relisant l'URL canonique du dashboard, puis remplace uniquement `.event-dashboard__program` avec le HTML issu du même rendu initial.

Le refresh couvre les sessions ajoutées ou modifiées depuis le Hub: ordre du Programme, thématiques/visuels, statuts runtime Hub, formats/modes, actions disponibles, compteurs et métadonnées dépendantes. Il déduplique `visibilitychange`, `pageshow` et `focus`, garde une seule requête active et conserve le DOM courant en cas d'erreur.

Un garde local central bloque le remplacement quand le dashboard est occupé ou sale: édition des lots, édition Format/Mode, modales de personnalisation ou d'ajout rapide ouvertes, renouvellement de thématique ou requête en cours. Dans ce cas, une information discrète apparaît dans le Programme avec l'action `Actualiser le programme`; le clic explicite peut confirmer la perte d'une édition locale.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-07-25 - Dashboard quick add adapte le service Global

L'action Pro `dashboard_quick_session_create` reste l'adaptateur authentifié du dashboard: elle conserve les gardes Pro, le CSRF, la résolution compte/contact/offre/date/Hub et la transformation de réponse pour l'UI. Après ces validations, elle délègue la proposition et la création au service Global partagé `app_programming_quick_hub_suggestion_build(...)` puis `app_programming_quick_hub_create_from_proposal(...)`.

La logique métier principale de l'ajout rapide Hub n'est plus spécifique au dashboard: jeux autorisés, mode, format, thématique automatique, renouvellement, token de proposition, idempotence, création et rattachement `games_hubs_sessions` sont portés par Global. L'endpoint dashboard garde le même contrat visible pour l'UI existante et journalise le chemin `service=global_quick_hub`.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`.

## Update 2026-07-24 - Agenda états Hub et remplacement verrouillé

L'Agenda Pro `/extranet/start/games` reprend maintenant les chips d'état du dashboard pour les cartes soirée/événement. Le statut global est calculé depuis la temporalité de la date et, quand un Hub existe, depuis les sessions Hub persistées: `À venir`, `Aujourd’hui`, `En cours` ou `Terminé`. La chip est placée dans le header de la carte, alignée à droite, sans modifier le CTA principal ni les actions de date/suppression complète.

Les lignes de parties de l'Agenda utilisent le même mapping d'état que le Programme dashboard: état d'édition session, `hub_runtime_status`, session active du Hub et chronologie de date. Les états non futurs (`En cours`, `Suspendue`, `Terminée`, etc.) sont affichés en chip à droite de la ligne; `À venir` reste sans chip pour conserver une lecture compacte.

Dans le dashboard soirée/événement, les liens `Voir / Remplacer` des séries Quiz et playlists suivent maintenant le verrouillage visuel des paramètres Format/Mode. Dès que la session n'est plus éditable, le rendu devient un libellé désactivé non cliquable, tandis que les gardes serveur existants restent la source d'autorité.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_agenda_test.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-07-24 - Retour design Cotton sans logo fallback

Le dashboard et la modale de personnalisation consomment le branding effectif résultant de la cascade session/Hub/réseau/compte, puis Cotton seulement pour les champs non-logo. `Revenir au design Cotton` ne poste plus d'intention média logo Cotton et ne matérialise plus de fichier logo Cotton dans le branding Hub.

Après retour au design Cotton, le logo effectif vient donc du réseau s'il existe, sinon du compte s'il existe, sinon aucun logo n'est rendu. Le visuel Cotton, les couleurs et la police restent disponibles via la cascade existante. L'upload ou le remplacement manuel d'un logo Hub reste inchangé.

Les démos lancées depuis le dashboard récupèrent également ce visuel Cotton par défaut via le snapshot Global lorsque le visuel effectif vient du fallback Hub.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_personalization_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-07-24 - Dashboard Programme: snapshot démo réaligné sur branding Hub effectif

Le POST `frm_mode=session_duplicate` lancé depuis le Programme dashboard valide désormais que `session_duplicate_context=dashboard_program`, `id_hub`, la propriété du Hub, son activité et la relation active `games_hubs_sessions` correspondent à la session source avant de matérialiser un snapshot Hub. Le snapshot de la démo consomme le resolver Global corrigé: session partielle, Hub, réseau, compte puis fallback Cotton Hub existant.

Les appels historiques à `session_duplicate` sans contexte dashboard Hub fiable restent sur le comportement historique. La démo créée n'est pas rattachée au Hub et conserve son branding session autonome après modification ultérieure du Hub.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `global/web/app/modules/jeux/sessions_branding/app_sessions_branding_functions.php`.

## Update 2026-07-24 - Dashboard Programme: démo snapshot et grilles Bingo papier

Dans les cartes dépliées du Programme, `Lancer une démo` continue de poster vers `frm_mode=session_duplicate`. Pour Bingo Musical en mode papier seulement, un second bouton `Imprimer les grilles de la démo` poste vers le même handler avec `session_duplicate_action=print_bingo_demo_grids`; Blind Test, Cotton Quiz et Bingo smartphone ne l'affichent pas.

Le contrat historique général de `session_duplicate` est conservé: hors exception Bingo Musical papier dashboard, chaque appel crée une nouvelle démo fraîche depuis l'état persistant courant de la session officielle. Les anciens appels sans contexte dashboard fiable ne consomment pas la cascade Hub; ils conservent le fallback historique de copie du branding session source quand il existe.

L'exception Bingo Musical papier est strictement temporaire et bornée au dashboard: une empreinte de la session source, de la playlist préparée et du branding effectif permet aux deux boutons de réutiliser la même démo uniquement tant que l'état courant n'a pas changé. Si le format, la playlist ou le branding effectif évolue, l'ancienne référence n'est pas resynchronisée; le clic suivant crée une nouvelle démo fraîche et remplace la référence temporaire.

Dans les cartes Bingo papier, la zone démo affiche une note dédiée à la place de l'ancienne mention générique: les grilles de la démo sont spécifiques à cette démo et ne doivent pas être utilisées pendant la partie officielle.

La duplication depuis le dashboard Hub validé appelle les helpers Global pour figer le branding effectif en branding session de la démo et pour cloner la playlist client Bingo déjà préparée. La session officielle, le Hub, les résultats et la synchronisation inverse restent inchangés.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `global/web/app/modules/general/branding/app_branding_functions.php`;
- `global/web/app/modules/jeux/bingo_musical/app_bingo_musical_functions.php`.

## Update 2026-07-24 - Dashboard Programme mobile: cartes session en accordéon

Sur mobile, le Programme du dashboard canonique `/extranet/start/games/day/YYYY-MM-DD` rend maintenant les cartes session comme de vrais accordéons. `Ajouter une partie` reste la première carte. Les sessions sont toutes repliées au chargement, une seule peut être ouverte, et le clic sur l'en-tête compact ou sur le chevron synchronise `aria-expanded` sans réagir aux liens, boutons, formulaires ou champs internes.

La carte repliée mobile affiche le visuel, le nom du jeu, le résumé `{format} · {mode}`, le contenu sélectionné, le renouvellement automatique de thématique quand il est disponible et le CTA d'impression quand la session est jouable sur papier. Les actions de suppression et de gestion restent masquées tant que la carte est repliée. Le CTA d'impression et le renouvellement restent dans l'en-tête et ne déclenchent pas l'accordéon.

La carte ouverte garde la structure fonctionnelle livrée précédemment: `Configuration` avec édition inline Format/Mode, `Contenu` ou séries Quiz avec `Voir / Remplacer`, puis `Lancer une démo`. Les actions secondaires mobiles sont séparées sous les actions principales; `Supprimer` est rendu en bas de la carte ouverte. Le desktop conserve sa grille grâce au nouvel en-tête rendu en `display: contents`, en dehors du libellé d'impression contextualisé.

Les libellés d'impression visibles/accessibles viennent de l'identifiant produit canonique déjà disponible: Bingo Musical affiche `Imprimer les grilles de jeu`; Blind Test et Cotton Quiz affichent `Imprimer les feuilles de jeu`.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-07-24 - Dashboard Hub: accroche/description effectives sans copie fallback

Le dashboard canonique `/extranet/start/games/day/YYYY-MM-DD` consomme maintenant la résolution partagée Global pour l'accroche affichée de la fiche soirée/événement. Une absence de personnalisation dans `games_hubs_publication.tagline` affiche le fallback Cotton du type de Hub, sans utiliser la fiche lieu, la fiche événement legacy ou un héritage réseau.

La modale de personnalisation garde les champs `Accroche` et `Description` sur les valeurs brutes réellement enregistrées dans `games_hubs_publication`. Quand ces valeurs sont vides, les textes Cotton apparaissent en `placeholder`; ils ne sont pas injectés dans `value` et ne sont donc pas soumis comme personnalisations lors d'une sauvegarde de design ou d'un autre réglage.

Le submit continue d'écrire `tagline` et `description` via `app_games_hub_publication_save(...)`, avec la normalisation existante des valeurs vides. Pour les événements, le miroir legacy `app_evenement_pivot_update_infos(...)` conserve les descriptions déjà présentes dans la fiche événement au lieu de recevoir les champs Hub bruts vides; la source éditoriale du Hub reste donc `games_hubs_publication`. Le titre n'est pas modifié par ce patch.

Surfaces volontairement non alignées dans cette passe: pages publiques Hub/événement `www`, anciennes pages événement, Hub Master/Play et payloads publics. Elles doivent consommer `publication.texts` ou `app_games_hubs_publication_resolve(...)` lors du prochain patch.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_personalization_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-07-24 - Agenda Pro: résumé Hub sans gestion de parties

L'Agenda Pro `/extranet/start/games` reste le point d'entrée pour retrouver les soirées et événements programmés du compte. Les cartes de date y résument désormais le Hub et son Programme sans devenir un second espace de gestion des parties. Le dashboard `/extranet/start/games/day/YYYY-MM-DD/dashboard` conserve la préparation, la personnalisation et les actions de gestion; le Hub reste l'interface d'exploitation en direct.

Le CTA principal d'une carte soirée/événement de l'Agenda pointe toujours vers `/extranet/start/games/day/YYYY-MM-DD/dashboard`. Son libellé varie selon la temporalité: `Préparer la soirée/l'événement`, `Ouvrir la soirée/l'événement` le jour J, puis `Consulter la soirée/l'événement` pour les archives. L'Agenda ne renvoie plus une carte Hub directement vers le pivot jour simple ou vers le Hub Master.

Les actions de modification de date et de suppression complète Hub dans l'Agenda reprennent les classes structurelles et les icônes du dashboard (`event-dashboard__structure-action`, calendrier `bi-calendar2-event`, corbeille `bi-trash3`). Les comportements existants restent inchangés: `sessions_day_move` pour déplacer la date et `hub_delete` protégé par CSRF pour supprimer le Hub complet.

Les parties affichées dans les cartes Agenda restent dans le traitement liste de l'Agenda, mais les éléments internes reprennent les conventions du Programme dashboard: espacements de ligne, dimensions de visuel, titre, ligne format/mode harmonisée (`20 titres · sur smartphone`, `4 séries · sur smartphone`, `40 titres · sur papier`) puis ligne thématique dédiée. Les noms de séries Cotton Quiz sont affichés sur cette ligne quand ils sont disponibles. L'Agenda n'affiche pas d'horaire par partie et ne rend plus de suppression individuelle de partie, de modale de confirmation unitaire, ni de CTA `Ajouter 1 session`.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_agenda_test.php`.

## Update 2026-07-23 - Bibliothèque Hub: ajout depuis Programme et programmation générale

Les parcours Bibliothèque de programmation suivent maintenant deux contrats distincts.

Depuis le Programme d'un dashboard Hub, le lien catalogue transporte l'`id_hub` explicite issu du contexte serveur validé. La recette navigateur a confirmé que ce contexte devait survivre au chemin complet `Dashboard Hub -> Ajouter une partie -> Bibliothèque -> contenu -> settings`: la liste, les cartes, filtres, pagination, détails, sélection directe de catalogue et Quiz Builder conservent maintenant `id_hub`. Le POST Bibliothèque en déduit seulement alors le tunnel agenda et redirige vers settings avec `tunnel=agenda&id_hub=...`.

Settings ne passe en mode Hub qu'après validation serveur du Hub actif et propriétaire; dans ce mode, les champs date et heure ne sont pas rendus, aucun `required` date/heure n'est applicable et le bloc `Programmation` vide disparaît. Le titre devient `Ajouter « {contenu} » à la soirée/l'événement` ou `Ajouter ce Cotton Quiz à la soirée/l'événement`, l'introduction indique seulement de choisir le format avant ajout au programme, et le CTA devient `Ajouter au programme`. Au POST, le serveur ignore toute date/heure transmise, reprend `games_hubs.hub_date`, calcule l'horaire suivant depuis les sessions réellement rattachées au Hub, configure une seule session, appelle la commande explicite Global `app_games_hub_session_membership_ensure(...)`, vérifie l'appartenance active puis revient au dashboard du même Hub. Cette commande est distincte du backfill legacy: elle fonctionne aussi quand le Hub possède déjà des parties actives, reste idempotente pour le même Hub et refuse de déplacer silencieusement une session déjà active dans un autre Hub.

Depuis la Bibliothèque générale, sans Hub explicite validé, settings reproduit quick-schedule pour une seule partie dont le contenu est déjà sélectionné. La date reste demandée et visible. À chaque changement, l'endpoint `library_schedule_context_probe` reliste sans mutation tous les Hubs actifs/accessibles du compte pour cette date, sans filtrer par le contexte préféré du compte; ce contexte préféré ne sert qu'à créer une soirée/un événement quand aucun Hub n'existe. Si un Hub unique existe, l'interface annonce l'ajout au programme existant, masque `À partir de`, retire son `required` et bascule le CTA sur `Ajouter au programme`. Si aucun Hub n'existe, l'interface annonce la création d'une soirée ou d'un événement, garde le champ `À partir de` obligatoire et adapte le CTA `Créer la soirée` / `Créer l'événement`. Si plusieurs Hubs compatibles existent, l'interface exige un choix radio explicite sans présélection.

Les routes settings Bibliothèque partagent désormais la structure visuelle quick-schedule: le header historique du tunnel est absent pour ces pages, le titre est rendu dans le shell (`Programmer/Ajouter le {jeu} « {thème} »`), puis les trois colonnes `Quand ?`, `Quel programme ?` et carte confirmation. Hors Hub explicite, le sous-titre reste fixe: `Choisis une date pour programmer cette partie.` Le choix d'une date déclenche ensuite le probe serveur et affiche un message sans titre `Programmation`, juste au-dessus des CTA: en dynamisation `Cette soirée existe déjà...` ou `Une nouvelle soirée sera créée...`, en gamification `Un événement existe déjà à cette date...` ou `Un nouvel événement sera créé...`. Le datepicker est initialisé localement pour rester vide au chargement, afficher le jour de semaine, transmettre le `dateStr` Flatpickr au probe et marquer les dates déjà programmées avec le repère quick-schedule sans les désactiver; la légende `Date sélectionnée / Déjà programmée` est affichée sous le champ et la CSS du repère n'est pas scopée au shell car Flatpickr rend son calendrier hors composant. `Quel programme ?` affiche d'abord `Format` (`40 titres · ~20 min` / `20 titres · ~10 min`), puis `Mode de jeu` (`Sur smartphone` / `Sur papier`). Cotton Quiz ne rend pas ce choix Format, car le nombre de séries est déjà porté par la sélection Bibliothèque; le titre devient `Programmer ce Cotton Quiz 1 série` ou `Programmer ce Cotton Quiz x séries` et le format technique reste en hidden. La carte confirmation est préremplie côté serveur: le jeu apparaît dès le chargement, le titre de session affiche la thématique Blind Test/Bingo, et Cotton Quiz conserve la règle nom de série si une seule série ou `x séries` si Builder multi-séries sans répéter ce format à côté du mode de jeu.

Au POST, Pro ne fait pas confiance à la détection navigateur: `session_setting` rerésout les Hubs pour la date et le compte. Hub unique ou Hub choisi dans une liste compatible rejoint le même write path que l'ajout Hub: heure injectée ignorée, horaire recalculé depuis le Programme réel, rattachement explicite et vérification active. Aucun Hub relance le contexte canonique quick-schedule (`soiree` ou `event`), utilise l'heure `À partir de` pour la première partie, puis `session_theme` crée/récupère le Hub via `app_games_hub_get_or_create_for_context(...)`, vérifie le rattachement actif et redirige vers `/extranet/start/games/day/{date}#session-{id}`. Les parcours démo, multiples/récurrents, `resume` et `resume-batch` restent conservés pour leurs usages historiques.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.
- `pro/web/ec/modules/tunnel/start/ec_start_library_hub_add_flow_test.php`.

## Update 2026-07-23 - Bibliothèque Hub: remplacement avec Hub explicite

Le parcours `Dashboard Hub -> Remplacer -> Bibliothèque -> choix -> validation` ne repose plus sur le seul `return_url` ni sur une reconstruction par date. Les liens `Voir / Remplacer` du Programme portent maintenant l'`id_hub` explicite issu du dashboard validé. La Bibliothèque conserve ce contexte dans ses liens, filtres, pagination, retour catalogue, Quiz Builder et formulaires de validation.

Au POST `content_library_apply_session_theme`, `ec_bibliotheque_script.php` valide avant mutation que la session appartient au compte courant, que le Hub explicite existe, est actif, appartient au même compte et que la relation active `games_hubs_sessions` relie précisément cette session à ce Hub. Le POST interne `session_theme` reprend cette validation et donne la priorité au dashboard Hub validé sur les retours historiques `game/view` ou `resume`.

Cette entrée remplace la mention précédente qui présentait le retour Hub comme corrigé uniquement via le `return_url` ou la date de session: le comportement livré ici utilise le Hub explicite comme source de vérité.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_dashboard_program_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`;
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`;
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`;
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-07-23 - Dashboard Programme: détail intégré, Bibliothèque et conversions

Le bloc Programme du dashboard canonique `/extranet/start/games/day/YYYY-MM-DD` ouvre maintenant un panneau intégré dans la carte via chevron accessible au lieu de naviguer vers la fiche session. Une seule carte peut être ouverte à la fois. Le panneau affiche les paramètres persistés, les séries ou playlists avec liens `Voir / Remplacer`, et une action `Lancer une démo` basée sur `session_duplicate`.

Les liens `Voir / Remplacer` ouvrent d'abord la fiche détail du contenu dans la Bibliothèque, en contexte session/dashboard. Depuis cette fiche, `Remplacer cette playlist` ou `Remplacer cette série` renvoie vers la home catalogue du jeu concerné. La fiche du nouveau contenu choisi réutilise ensuite le contrat historique `content_library_apply_session_theme`; pour Quiz, `slot_index` cible exactement la série à remplacer et les autres tokens `lot_ids` gardent leur ordre. Le retour final est validé côté serveur et revient au dashboard Hub lorsque l'URL correspond à la session propriétaire et à une relation Hub active `games_hubs_sessions.id_hub` / `id_session`; ce contrôle évite le fallback fiche session après validation réelle depuis le catalogue.

Le POST final de remplacement sécurise aussi le cas où un ancien `return_url` fiche session circule encore: en contexte agenda/library, `ec_bibliotheque_script.php` reconstruit le retour canonique `/extranet/start/games/day/{date}#session-{id}` depuis la session cible et le valide avant redirection. Dans le Programme, les cartes Quiz n'ajoutent plus `2 séries` ou `4 séries` dans la ligne format/mode, puisque ce nombre est déjà le titre du contenu. Après renouvellement automatique, le front rafraîchit le bloc Programme depuis le serveur afin de mettre à jour la carte dépliée et les liens `Voir / Remplacer`.

Les changements Format et Version passent par `frm_mode=dashboard_session_options_update`, protégé par le CSRF dashboard et par les gardes serveur de session éditable. Les sessions verrouillées, terminées, démarrées, avec résultats ou participations runtime sont refusées. Pour Quiz, l'option smartphone est désactivée si le garde numérique historique sait déjà que la composition ne peut pas être jouée sur téléphone; sinon le serveur refuse avec un message sobre.

Cotton Quiz convertit depuis `championnats_sessions.lot_ids`, pas depuis un libellé affiché. Le format technique `5` correspond à 2 séries, le format `2` à 4 séries. Les recettes canoniques sont conservées: numérique `N history_events`, `N arts_literature`, `N science_sports_riddles`, `L catalogue`; papier `T histoire`, `T arts`, `T science`, `L catalogue`. Le passage 4 -> 2 garde l'histoire et le dernier `L`; le passage 2 -> 4 garde histoire/catalogue et insère arts/science. Les compositions 100% `L` restent 100% catalogue, tronquées ou complétées par des `L`.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_dashboard_program_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`;
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_dashboard_program_helpers_test.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-07-23 - Dashboard Hub: persistance compte masquée sous branding réseau

La modale de personnalisation du dashboard soirée/événement ne propose plus la case `Enregistrer ce design comme défaut...` quand le compte bénéficie d'un branding réseau réellement exploitable. Le critère est recalculé serveur via la couche `general_branding.id_type_branding=3` résolue par le helper canonique, et non par la seule affiliation administrative `clients.id_client_reseau`.

Dans ce cas, un payload forgé avec `apply_design_to_future=1` est neutralisé avant l'appel au helper de sauvegarde compte: la personnalisation Hub courante continue d'être sauvegardée normalement, mais le branding compte type 4 n'est ni créé ni modifié depuis cette modale. `Annuler les changements` et `Revenir au design Cotton` restent des actions locales/Hub uniquement.

Pour les comptes sans branding réseau exploitable, la persistance compte existante reste disponible. Le footer utilise maintenant un `<label class="account-branding-default-option">` autour de la checkbox et du texte afin de conserver le clic pleine ligne, le focus clavier, le wrap responsive et un alignement vertical centré sans offset CSS.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_personalization_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Update 2026-07-23 - Dashboard Hub: design Cotton canonique

Les adaptateurs Pro `ec_start_day_personalization_cotton_visual_path_get/url_get()` délèguent aux helpers Global de visuel Cotton quand ils sont disponibles. Le bouton `Revenir au design Cotton` prépare donc le même visuel que le fallback Hub partagé.

Au submit, l'intention média Cotton continue de créer ou mettre à jour le visuel du branding Hub type 5 via `app_general_branding_visuel_uploader(...)`. Elle ne crée plus de logo Cotton. Le visuel généré temporairement côté Pro est supprimé: sans fichier canonique lisible, aucun média divergent n'est matérialisé.

Fichier de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_personalization_helpers.php`.

## Etat 2026-07-23 - Dashboard personnalisation: actions design locales et design compte

La modale de personnalisation du dashboard `/extranet/start/games/day/YYYY-MM-DD` garde ses sections `Identité et design` et `Informations publiques`, ses routes Ajax et ses champs existants. La sauvegarde du design écrit maintenant la couche explicite `general_branding.id_type_branding=5` liée à `games_hubs.id` dès qu'un Hub canonique existe; le fallback branding événement `id_type_branding=2` ne reste qu'un repli legacy sans Hub.

`Annuler les changements` remplace l'ancien retour au design par défaut. L'action ne poste rien au clic: elle restaure localement couleurs, inputs fichier et aperçus logo/visuel depuis la cascade réseau/compte calculée sans la couche Hub courante. Si une couche Hub explicite existe, sa suppression est seulement préparée; elle est confirmée et exécutée au submit `Enregistrer`. Si l'utilisateur modifie ensuite une couleur ou un fichier, l'intention devient une sauvegarde Hub explicite au lieu d'une suppression.

`Revenir au design Cotton` est disponible seulement quand la cascade héritée contient un branding réseau ou compte. Le clic charge localement les valeurs Cotton canoniques hors logo; aucune couche Hub, compte ou réseau n'est modifiée avant `Enregistrer`. Au submit, ce design devient une couche Hub explicite si l'utilisateur confirme la sauvegarde de la modale.

Le submit Cotton porte une intention média explicite uniquement pour le visuel. Les inputs fichier peuvent rester vides: le serveur matérialise le visuel Cotton via `app_general_branding_visuel_uploader(...)`, qui purge seulement les variantes actives du visuel Hub avant réécriture. Un upload manuel de logo reste possible et prioritaire, mais aucun logo Cotton n'est créé automatiquement. La source actuelle du visuel est centralisée dans `ec_start_day_personalization_cotton_visual_*`.

Le footer parle de `design par défaut`, car `general_branding.id_type_branding=4` est commun au compte. Il affiche une seule case décochée associée à `Enregistrer`: `Enregistrer ce design comme défaut pour mes prochaines soirées` ou `...mes prochains événements` selon le contexte. Quand elle est cochée, le serveur enregistre le design final puis enregistre uniquement les champs compatibles dans le branding compte canonique: couleurs, police, logo et visuel. Les informations publiques Hub/événement, publication, lieu, date, liens et textes éditoriaux ne sont pas copiés.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_personalization_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Etat 2026-07-23 - Quick-schedule formats communs et Quiz court

Le programmateur rapide `/extranet/start/games/quick-schedule` affiche maintenant le même réglage Format pour Blind Test, Bingo Musical et Cotton Quiz, immédiatement après le choix du jeu. Blind Test et Bingo Musical affichent `40 titres · ~20 min` puis `20 titres · ~10 min`; Cotton Quiz affiche `4 séries · ~20 min` puis `2 séries · ~10 min`. Le format standard reste le défaut rapide. Le champ posté reste `session_id_format`; le contrat interne n'est pas unifié au-delà de quick-schedule.

Blind Test conserve ses identifiants techniques existants: Standard = format `2` / 40 titres, Court = format `5` / 20 titres. Bingo Musical conserve la même normalisation technique que ses formats standard/court historiques. Cotton Quiz utilise le même choix visuel dans quick-schedule: Standard garde le programme auto historique de 4 séries, tandis que Court produit exactement 2 séries par session.

Pour Cotton Quiz papier court, la création applique `T Cette semaine dans l'histoire` puis un lot thématique `L` choisi par la règle métier quick-schedule existante. Pour Cotton Quiz numérique court, le format final reste exactement 2 séries mais la sélection automatique prépare jusqu'à 4 lots `L` de secours afin de disposer de deux lots thématiques distincts. La création tente `N history_events` uniquement quand le garde-fou numérique Global l'autorise, aujourd'hui le bypass admin `id_client=10`; sinon, ou si la DB de questions numériques certifiées ne suffit pas encore, elle persiste deux `L` valides sans message technique visible. Les reprises idempotentes et les récurrences conservent le format sélectionné dans le gabarit/template.

La carte de confirmation garde le jeu seul comme titre (`Blind Test`, `Bingo Musical`, `Cotton Quiz`) et place les métadonnées sur une ligne: `{nombre de parties} · {contenu du format} · {mode de jeu}`. Elle affiche donc `1 partie · 40 titres · sur smartphone`, `5 parties · 20 titres · sur papier`, `1 partie · 4 séries · sur smartphone` ou `3 parties · 2 séries · sur papier`, sans répéter `~20 min`, `~10 min`, `format standard` ni `format court`. L'aide générale de durée sous les paramètres est supprimée, car la durée approximative est portée uniquement par les boutons de choix du format.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_quick_schedule.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_quick_schedule_ui_test.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Etat 2026-07-23 - Interface quick-schedule en trois colonnes

Le programmateur rapide `/extranet/start/games/quick-schedule` conserve ses routes, champs POST, recommandations Global, idempotence, récurrence, exclusions, détection des dates occupées, thème automatique et création Hub. La passe UI organise seulement la présentation en zones DOM stables: `Quand ?`, `Quel programme ?`, confirmation, puis footer d'actions.

Sur desktop large, la grille utilise trois colonnes égales: date/récurrence, paramètres de programme, confirmation. Sous 1200 px, elle passe en deux colonnes avec confirmation pleine largeur; sous 992 px, elle s'empile en une colonne sans `order` CSS ni duplication, donc le focus suit toujours calendrier, paramètres, confirmation, footer.

La date principale et le champ `Jusqu'au` sont portés par le datepicker `flatpickr` flottant maison dans la première colonne, avec jour de semaine visible dans le champ. `Jusqu'au` est auto-complété et recalculé au changement de date principale ou de fréquence à la prochaine occurrence: +7 jours, +14 jours ou même rang de jour dans le mois suivant. Les dates retirées et déjà programmées restent marquées dans ces calendriers à l'ouverture avec leurs classes et libellés accessibles, sans légende sous le champ; les dates ajoutées ne sont plus marquées car elles sont résumées dans la confirmation. L'ancienne liste détaillée des occurrences est supprimée. Le calendrier `Jusqu'au` porte l'interaction retirer/rétablir une occurrence. Le même calcul JS d'aperçu nourrit les marquages et les exclusions soumises; le serveur continue de reconstruire et valider la récurrence via Global avant création.

Dans la colonne programme, le Format est un réglage en chips partagé par les trois jeux depuis la passe suivante; le sélecteur `1`, `2`, `3`, `+` garde l'accès à 4..10 sans popover superposé.

La confirmation conserve son style de carte et affiche le nombre de soirées, l'heure de départ, la liste des dates récurrentes, le jeu avec format et le nombre de parties par soirée. Le footer pleine largeur affiche une note légère sur les thématiques automatiques et l'ajustement possible de chaque partie, puis les CTA.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_quick_schedule.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_quick_schedule_ui_test.php`.

## Etat 2026-07-22 - UX cohérence quick-schedule, dashboard et Agenda

Le programmateur rapide `/extranet/start/games/quick-schedule` conserve son parcours direct Home/Agenda, ses helpers de recommandation Global, son thème automatique et ses Hubs par date. La copie d'introduction parle désormais de `programme sur mesure`. Le nombre de parties reste rapide pour 3/2/1, avec un contrôle compact `+` qui permet 4 à 10 parties; le serveur valide strictement 1 à 10 et refuse un horaire dont la dernière partie dépasserait la date.

Blind Test et Bingo Musical exposent dans quick-schedule un choix de format `Standard · 40 titres` ou `Court · 20 titres`, piloté par les helpers Global `app_session_format_*`. Quiz ne rend pas ce contrôle et retombe sur son défaut. Le format posté n'est accepté serveur que s'il est disponible pour le jeu; sinon, la normalisation canonique reprend la main.

Le dashboard soirée/événement garde le CTA historique `Voir le détail` pour l'accès fiche session. Les actions d'impression utilisent un libellé accessible contextualisé: `Imprimer les grilles de jeu` pour Bingo, `Imprimer les feuilles de jeu` ailleurs. La modale `Ajouter une partie` conserve la création automatique et n'affiche d'abord que les cartes de jeux; après sélection, elle affiche la mention de thématique automatique puis le lien discret `Choisir dans le catalogue`, qui renvoie vers le parcours bibliothèque historique avec jeu, `day_date`, `day_context` et `return_url`.

L'Agenda `/extranet/start/games` remonte les informations globales au niveau du bloc date: nom d'événement si présent, `À partir de HHhMM`, nombre de parties et participation Hub selon l'état temporel. Le jour J, ce résumé reprend la règle dashboard en distinguant `attendu(s)` et `connecté(s)` au lieu d'afficher un total générique. Les lignes de session ne répètent plus les participations unitaires. Les sessions autonomes conservent le fallback historique quand aucun Hub exploitable n'est trouvé.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_quick_schedule.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`.

## Etat 2026-07-22 - Dashboard soirée/événement: état temporel et lecture seule

Le dashboard canonique `/extranet/start/games/day/YYYY-MM-DD` calcule maintenant son contexte temporel via `ec_start_day_dashboard_temporal_context_get(...)`, basé sur les états unitaires existants de `ec_start_day_dashboard_session_state_get(...)`. La vue n'a plus son propre calcul divergent pour décider de l'état global.

Quand le dashboard est `En cours`, le CTA Hub Master garde le kicker `Diffuser aux joueurs` et affiche `Reprendre la diffusion`. Quand il est `Terminé`, la page devient une consultation: pas de trigger ni modal de personnalisation, pas de Remote, pas d'ajout rapide, pas de contrôles d'édition de lots et pas de renouvellement thématique. Les refus serveur correspondants vivent dans les scripts/services, pas seulement dans le DOM.

Les cartes session n'affichent plus les participations unitaires dans leur ligne de caractéristiques; les compteurs globaux restent dans le sous-titre du Programme. Les actions personnalisation/date/suppression Hub sont ancrées en haut à droite de `event-dashboard__summary` sur desktop et mobile. Sur mobile, les compteurs globaux s'alignent à gauche, et l'icône fantôme de renouvellement reste 24 px avec un glyphe légèrement agrandi.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_session_theme_renewal_ajax_test.php`.

## Etat 2026-07-22 - Dashboard soirée/événement: compteurs globaux de participations

Le dashboard canonique `/extranet/start/games/day/YYYY-MM-DD` affiche maintenant dans le bloc `Programme` des compteurs globaux de participation du Hub, sur la ligne du sous-titre avec la capacité historique. Le titre conserve seulement `Programme` et le compteur de parties.

Les compteurs ne somment pas les compteurs par session. La vue appelle une seule fois `app_games_hub_participation_counters_get(...)`, puis choisit le libellé selon l'état temporel déjà utilisé par le dashboard: avant le jour J, seules les participations probables non nulles sont affichées en `participant(s) attendu(s)`; le jour J non terminé affiche les attendus non nuls puis la présence Hub, y compris `0 connecté`; après fermeture, seul le total réel effectif est affiché en `participant(s)`. Les icônes reprennent les pictogrammes historiques `bell-fill` et `people-fill` via `ec_start_day_session_info_icon_get(...)`.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Etat 2026-07-22 - Dashboard soirée/événement: micro-correctifs pill et renouvellement

Le dashboard canonique `/extranet/start/games/day/YYYY-MM-DD` conserve ses routes, actions, données et permissions. La pill temporelle du header (`Aujourd’hui`, `Demain`, etc.) est maintenant centrée via une boîte de libellé interne propre à `.event-dashboard__chip`; le problème venait du libellé inline dans l'eyebrow, et non du composant d'état des cartes. Les pills d'état des parties utilisent la même structure de libellé interne afin de rester cohérentes sur tous leurs états.

Dans les cartes Programme, l'action de renouvellement automatique de thématique n'est plus dans la colonne d'actions à droite ni dans une colonne dédiée avant le visuel. Quand elle est disponible, elle est rendue comme bouton fantôme de 24 px dans la ligne du titre de thématique, immédiatement après le titre; le titre se tronque avant l'icône, l'icône reste visible, et les visuels restent alignés entre cartes avec et sans renouvellement. La description secondaire reste limitée à une ligne. Les actions `Imprimer`, `Voir le détail` et `Supprimer` restent sur leurs chemins existants; le CTA détail affiche maintenant le libellé `Voir le détail` avant l'icône. Le renouvellement utilise l'`aria-label` `Changer automatiquement de thématique`, le tooltip court `Changement auto`, et garde la chaîne Ajax plan/apply existante.

La pill temporelle `Aujourd'hui` utilise le texte contrasté calculé pour l'accent, comme le CTA principal Hub. L'état `En cours` reprend ce même style contrasté; l'état `Terminé` reprend le style discret de `À venir`. La carte `Ajouter une partie` retrouve un hover/focus léger par bordure, fond teinté et ombre contenue, sans déplacement ni changement de hauteur.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Etat 2026-07-22 - Dashboard soirée/événement: correctifs responsive, Quiz et personnalisation

Le dashboard canonique `/extranet/start/games/day/YYYY-MM-DD` conserve deux colonnes sur desktop et une colonne sur mobile. Sur mobile, les conteneurs de colonnes sont aplatis afin d'afficher les blocs dans l'ordre fiche, Programme, Lots, puis actions opérationnelles. La fiche mobile retire le padding, la bordure et le fond propres de `event-dashboard__summary`. Les actions structurelles du titre restent dans une grille titre/actions à droite, sans occuper toute la ligne ni repousser le sous-titre date/horaire/parties.

Les cartes Programme acceptent désormais que les cartes Quiz soient plus hautes que les autres. La ligne principale reste le nombre de séries ou le nom de la série unique; la ligne secondaire affiche la liste complète des séries sur plusieurs lignes si nécessaire. Le visuel de session est ancré en haut de la carte pour rester aligné quand le texte Quiz augmente la hauteur.

Après renouvellement de thématique Quiz, le dashboard ne choisit plus arbitrairement le visuel du premier item de `applied_selection`. L'adaptateur Start enrichit la réponse `session_theme_renewal_apply` avec `data.session.visual`, calculé via `ec_start_agenda_session_summary_get(...)` après écriture. Le front utilise ce visuel canonique recalculé en priorité, puis seulement en fallback `items[0].visual`.

La modale de personnalisation garde les mêmes routes et contrats Ajax, mais son layout desktop affiche désormais les champs avant l'aperçu en conservant les proportions ajustées `3fr / 2fr`. La colonne preview reste sticky sur desktop mais est masquée sur mobile. Le séparateur haut entre sections `start-day-personalization__section` est retiré pour alléger la lecture.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_session_theme_renewal_ajax_test.php`.

## Etat 2026-07-22 - Dashboard soirée/événement: dernière passe UI fiche et Programme

Le dashboard `/extranet/start/games/day/YYYY-MM-DD/dashboard` regroupe désormais les actions structurelles près du titre: personnalisation, modification de date et suppression complète. La personnalisation ouvre la même modale Ajax qu'avant via `data-start-day-event-open`; la modification de date garde la modale `sessions_day_move`; la suppression conserve `hub_delete`. Les libellés accessibles et tooltips sont contextualisés, l'icône date utilise un calendrier Bootstrap, et seul le bouton de suppression devient destructif au survol/focus.

Le lien `Voir la page publique` reste séparé, sous les métadonnées, comme action secondaire. Il ne rejoint pas les actions structurelles.

Le panneau Lots n'ajoute plus de second formulaire sous la lecture. Les trois lignes existantes deviennent éditables inline: rang et médaille restent en place, le libellé est remplacé par le champ correspondant, puis `Annuler` et `Enregistrer` s'affichent dans le même panneau. La sauvegarde continue d'utiliser `dashboard_prizes_save`, `dashboard_prizes_csrf` et `app_games_hub_prizes_save(...)`; le succès réaffiche les lignes mises à jour sans flash technique, tandis qu'une erreur garde les champs ouverts avec un message sobre.

Les cartes Programme séparent les actions en deux niveaux. Les actions principales sont `Thématique` et `Imprimer` quand disponible; les actions secondaires `Voir le détail` et `Supprimer` passent sur une ligne distincte, plus discrète au repos. `Supprimer` garde un traitement destructif uniquement au hover/focus. La présentation Quiz a ensuite évolué: la ligne principale reste `N séries` ou la série unique, et le détail complet peut s'afficher sur plusieurs lignes.

Le Programme n'a plus de scroll interne ni d'indicateur `N autres parties`. Il prend sa hauteur naturelle et laisse la page gérer le défilement vertical; les gradients/masques et la synchronisation JS de hauteur ont été retirés. La carte `Ajouter une partie` est maintenant la première carte du Programme, avant les sessions existantes, et le refresh Ajax du dashboard remplace toujours `.event-dashboard__program`, donc conserve cet ordre depuis le HTML persisté.

La colonne gauche garde le flux naturel fiche, visuel, informations/lieu puis Lots. Les Lots ne sont plus alignés artificiellement en bas de colonne; les deux colonnes peuvent avoir des hauteurs différentes.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Etat 2026-07-22 - Dashboard/Agenda: suppression complète Hub branchée

Le dashboard `/extranet/start/games/day/YYYY-MM-DD/dashboard` et l'agenda `/extranet/start/games` exposent la suppression complète d'une soirée/événement seulement lorsque le Hub canonique existe et que `app_games_hub_delete_member_sessions_validate(...)` l'autorise. Les deux vues ciblent `games_hubs.id`, jamais la date seule, et postent `frm_mode=hub_delete` vers `ec_start_script.php` avec `hub_delete_csrf`.

`ec_start_script.php` ne porte pas la logique métier: il vérifie le CSRF, le compte Pro courant, puis appelle `app_games_hub_delete_complete(...)`. En succès, l'utilisateur revient à l'agenda; en erreur, le message visible reste fonctionnel et ne révèle ni table, ni identifiant technique, ni étape interne. Les formulaires de confirmation neutralisent le double submit en désactivant le bouton de validation.

La suppression unitaire historique `frm_mode=session_delete` délègue aussi à `app_session_delete_canonical(...)`, ce qui évite de dupliquer les nettoyages par jeu entre fiche session, dashboard, agenda et suppression complète Hub.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Etat 2026-07-22 - Dashboard soirée/événement: passe consolidée identité et actions

Le dashboard `/extranet/start/games/day/YYYY-MM-DD/dashboard` lit toujours son programme depuis le Hub persistant. Le titre sans personnalisation reprend le fallback global `Soirée Cotton` ou `Événement Cotton`, sans écraser un titre personnalisé existant. Le CTA Hub Master conserve le kicker unique `Diffuser aux joueurs`; son libellé principal est `Prévisualiser la soirée/l’événement` avant le jour J, `Diffuser la soirée/l’événement` le jour J ou pendant une session ouverte, puis `Consulter les résultats` quand toutes les parties sont fermées.

Le titre affiche une action discrète de modification de date quand `ec_start_day_group_can_move(...)` l'autorise. Elle ouvre la modale existante du pivot/agenda et soumet `sessions_day_move`, donc réutilise `ec_start_day_group_move(...)`: contrôles d'état, collision date, mise à jour sessions, saison, événement legacy éventuel et Hub via `app_games_hub_move_context_date(...)`. La suppression complète d'une soirée/événement n'est pas branchée: aucun service canonique transactionnel ne couvre encore Hub + sessions + publication + lots + branding + mappings.

Les cartes Programme restent des conteneurs neutres. Les actions principales sont `Thématique` (accessible `Changer de thématique`) et `Imprimer`; les actions secondaires sont `Voir le détail` et `Supprimer` quand la session est encore éditable. La suppression unitaire réutilise `frm_mode=session_delete`, le même chemin que la fiche session, avec confirmation, puis le retour dashboard relit le programme Hub. Le refresh Ajax après ajout remplace le Programme et resynchronise aussi le libellé temporel d'en-tête pour éviter un compteur divergent.

Pour Quiz V2, la présentation de la carte utilise les métadonnées canoniques exposées par `app_jeu_get_detail(...)`: `quiz_series_count`, `quiz_series_label`, `quiz_series_names`. Une seule série affiche la thématique sans ligne redondante; plusieurs séries affichent `{N} séries` puis la liste complète des noms en ligne secondaire, sur plusieurs lignes si nécessaire. Le terme ambigu `lots` n'est pas utilisé dans cette présentation.

Les lots Hub restent lus/écrits via `app_games_hub_prizes_get(...)` / `app_games_hub_prizes_save(...)`. L'action `Modifier les lots` transforme le panneau en formulaire inline avec les trois rangs; aucune modale, aucun panneau séparé et aucun message technique de succès ne sont affichés.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_session_theme_renewal_ajax_test.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Etat 2026-07-22 - Dashboard Programme: ajout rapide d'une partie

Le dashboard `/extranet/start/games/day/YYYY-MM-DD/dashboard` permet maintenant d'ajouter une partie depuis la carte finale du bloc `Programme` sans quitter la page. La carte ouvre une modale courte `Ajouter une partie`: avant sélection, seules les cartes de jeux sont visibles; après sélection, une mention légère précise que Cotton sélectionnera automatiquement la thématique et propose `Choisir dans le catalogue`. Elle ne demande ni heure, ni format/version, ni thématique, ni nombre de joueurs.

Les choix de jeu proviennent de `ec_start_quick_schedule_games_get(...)`, source partagée avec `/extranet/start/games/quick-schedule`. La modale reprend les cartes visuelles de sélection quick-schedule: visuel, libellé, sélection radio exclusive, hover, focus clavier, couleurs, rayons et empilement responsive. Le CTA `Ajouter la partie` reste désactivé tant qu'aucun jeu n'est sélectionné, puis pendant la requête.

La validation serveur passe par `frm_mode=dashboard_quick_session_create` dans `pro/web/ec/modules/tunnel/start/ec_start_script.php`. L'action vérifie le CSRF quick-schedule, le compte connecté, la date du dashboard, le jeu autorisé par la source partagée, l'offre effective et l'idempotence `programming_quick_operations`. Elle relit le programme courant via le Hub persistant, déduit smartphone/papier par majorité sur tout le programme, puis déduit le format et le nombre de séries Quiz seulement depuis les sessions du même jeu. En absence ou égalité, elle retombe sur les défauts quick-schedule. Elle calcule ensuite l'heure suivante depuis la dernière session éligible du programme Hub et l'espacement canonique d'ordre d'une minute, refuse proprement si aucun créneau ne reste sur la même date, force une seule partie, prépare la thématique via `start_quick_schedule_theme_payloads_prepare(...)`, puis crée avec `start_quick_schedule_occurrence_create(...)`.

Le rattachement Hub n'est pas réinventé dans le dashboard: le contexte soirée/événement est reconstruit côté serveur, puis `start_quick_schedule_occurrence_create(...)` appelle `app_games_hub_get_or_create_for_context(...)` et vérifie que la session créée est présente dans `app_games_hub_sessions_get(...)`, donc via la relation persistée `games_hubs_sessions`. Les sessions supprimées, inactives, démo ou incomplètes sont exclues des recommandations. Après succès Ajax, le front recharge le HTML du dashboard et remplace uniquement `.event-dashboard__program`; en cas d'échec de ce rafraîchissement après création, la modale indique que la partie est créée et propose de rafraîchir le dashboard au lieu de relancer la création.

Update accès session: les occurrences rapides génèrent désormais un `id_securite` sans point décimal, compatible avec les routes Start historiques. Aucun patch de rétrocompatibilité `.htaccess` n'est conservé en dev.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_quick_schedule.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_dashboard_quick_parameters_test.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_quick_schedule_ui_test.php`.

## Etat 2026-07-21 - Dashboard Programme: actions de session et renouvellement manuel

Les cartes `Programme` du dashboard `/extranet/start/games/day/YYYY-MM-DD/dashboard` ne sont plus des liens couvrant toute la ligne. Chaque rangée garde les informations existantes de session, puis expose à droite des actions interactives séparées: `Changer la thématique` en action principale, `Imprimer les supports` quand le support papier historique est disponible, et `Ouvrir les paramètres complets` vers la fiche session existante.

La compatibilité du renouvellement n'est pas dupliquée en JavaScript: la vue appelle `app_programming_theme_renewal_game_from_type(...)` via `ec_start_day_dashboard_theme_renewal_game_get(...)`, ce qui limite l'action à Blind Test, Bingo Musical et Quiz V2. Les sessions verrouillées par `app_session_edit_state_get(...)` n'affichent pas l'action. Le clic sur `Changer la thématique` est maintenant une action immédiate: le dashboard appelle `session_theme_renewal_plan`, puis applique directement la proposition via `session_theme_renewal_apply` dès que le plan retourne `PROPOSED_SELECTION`, sans dialogue ni confirmation supplémentaire.

Le front conserve uniquement un cycle temporaire par carte, en mémoire JavaScript, pour éviter l'alternance immédiate entre deux thématiques pendant une même visite du dashboard. Après `APPLIED_SELECTION`, il ajoute aux `temporary_exclusions` la `previous_selection` renvoyée par le serveur, bornée à 24 entrées, puis transmet cette liste au plan suivant. Il ne persiste aucun refus, ne reconstruit aucun ID depuis le DOM ou les libellés, ne lance aucun retry automatique et n'utilise aucun `sessionStorage`, `localStorage` ou cookie.

Le champ transitoire `current_public_label` / `data.presentation.current_selection_label`, ajouté uniquement pour la comparaison de l'ancienne modale, est supprimé. Après application, le libellé visible de la carte provient de `applied_selection` renvoyé par le serveur Global; `expected_current_selection` reste un payload opaque de concurrence et n'est jamais utilisé comme libellé public.

Update 2026-07-22: pour Quiz V2, l'adaptateur Pro injecte le loader de candidats comme option de service au plan et à l'apply, jamais dans le payload navigateur. Ce loader combine les lots catalogue `L`, les lots temporaires papier `T` et les lots temporaires numériques `N`, puis enrichit chaque candidat avec une famille métier (`recipe_key` / `role_key`). Les `N` relisent `contexte_generation=type=...`; les `T` relisent les métadonnées persistées par les builders auto (`nom` / `descriptif_court`); les `L` d'auto-pack portent le rôle `random`.

Pendant l'opération de plan uniquement, le loader peut générer des lots auto frais de même famille avec les primitives quick-schedule: papier `qz_build_temp_history`, `qz_build_temp_arts`, `qz_build_temp_sciences`; numérique `qz_build_numeric_auto_series`. L'apply ne régénère rien: il relit le référentiel et laisse Global valider que le payload opaque conserve format, count, ordre, préfixe et famille par slot. Le front continue donc de transmettre exactement `game`, `version`, `expected_current_selection` et `proposal` depuis la réponse plan, sans reconstruire de token depuis le DOM.

Les codes métier sont traités côté UI: `PROPOSED_SELECTION` déclenche l'application immédiate sans afficher la proposition, `NO_ALTERNATIVE` affiche un retour local sans appeler l'application, `APPLIED_SELECTION` met à jour uniquement la carte concernée et affiche temporairement `Thématique remplacée`, `NO_CHANGE` synchronise sans annoncer de remplacement, `STALE_SELECTION` demande un nouveau clic volontaire, `SESSION_NOT_EDITABLE` neutralise durablement l'action, `INVALID_PROPOSAL`, `SESSION_INACCESSIBLE`, `INCOMPATIBLE_SESSION`, `HUB_SESSION_MISMATCH`, `WRITE_FAILED` et `BINGO_MATERIALIZATION_FAILED` affichent un message sobre sans détails techniques ni identifiants Bingo. Si `NO_ALTERNATIVE` intervient alors qu'un cycle temporaire est actif, le dashboard vide ce cycle, affiche `Toutes les thématiques disponibles ont été parcourues.` et attend un nouveau clic volontaire.

Update UI 2026-07-22: après chaque issue de la chaîne plan/apply, le bouton de renouvellement retire `disabled`, `aria-busy` et la classe de chargement. Après `APPLIED_SELECTION`, le libellé et le visuel de la carte Programme sont mis à jour uniquement depuis `applied_selection` serveur. Les derniers ajustements de hiérarchie placent les actions d'information dans `event-dashboard__summary-core` avec `padding-top:.5rem`, allègent le résumé desktop et conservent l'alignement visuel des Lots.

L'impression reprend les conditions et URLs de la fiche session historique: uniquement sessions papier non terminées, Quiz V1 statique `ec/medias/documents/feuilles/Cotton_Quiz_feuille_jeu*.pdf`, Bingo Musical via `games/includes/canvas/php/bingo_grids_paper.php?id_securite=...`, Blind Test et Quiz V2 via `app_session_get_link(..., 'print', ...)`. Ces liens restent stables après renouvellement car ils ciblent la session par `id_securite`/date et résolvent les supports courants à l'ouverture; le dashboard ne génère aucun support, ne prépare aucun runtime, ne synchronise pas Hub Master/Play et ne crée aucun nouveau chemin PDF.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_session_theme_renewal_ajax_test.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`.

## Etat 2026-07-21 - Adaptateur HTTP interne de renouvellement thématique

Le contrôleur Start canonique `pro/web/ec/modules/tunnel/start/ec_start_script.php` expose deux actions POST JSON/formulaire pour le futur dashboard, sans bouton ni modification d'interface:

- `frm_mode=session_theme_renewal_plan`: reçoit `id_session` ou `id_securite_session`, `hub_id` optionnel et `temporary_exclusions` borné à 24 entrées, puis appelle `app_programming_theme_renewal_plan_for_session(...)`;
- `frm_mode=session_theme_renewal_apply`: reçoit `id_session` ou `id_securite_session`, `hub_id` optionnel, `game`/`version` attendus, `expected_current_selection` obligatoire et `proposal` obligatoire, puis appelle `app_programming_theme_renewal_apply_for_session(...)`.

L'adaptateur résout le compte depuis `$_SESSION['id_client']`, jamais depuis le navigateur. Les deux actions exigent POST, session Pro authentifiée et CSRF Ajax existant du dashboard (`ec_dashboard_prizes_csrf`, transmis comme `dashboard_prizes_csrf` ou `csrf_token`). Le Hub optionnel reste un simple contexte transmis au service Global; l'appartenance session/Hub reste vérifiée par les primitives Global et `games_hubs_sessions`.

Le JSON de transport est stable: `success`, `code`, `message`, `data`. La proposition retourne `current_selection`, `expected_current_selection` à retransmettre tel quel, `proposal`, `labels`, `effective_exclusions`, `no_alternative` et `stale_selection_supported`. L'application ne recalcule jamais une proposition; elle transmet `expected_current_selection` et la proposition explicite à Global, puis renvoie `previous_selection`, `applied_selection`, `changed`, `technical_ids`, `bingo_materialization` et `refresh_required` sur `STALE_SELECTION`.

Mapping HTTP principal: `PROPOSED_SELECTION`, `NO_ALTERNATIVE`, `APPLIED_SELECTION` et `NO_CHANGE` restent en 200; `STALE_SELECTION`, `SESSION_NOT_EDITABLE` et `HUB_SESSION_MISMATCH` en 409; `INVALID_PROPOSAL` et `INCOMPATIBLE_SESSION` en 422; CSRF en 403; non authentifié en 401; session inaccessible en 404; `WRITE_FAILED` et `BINGO_MATERIALIZATION_FAILED` en 500.

L'adaptateur ne contient aucune sélection de candidats, aucune règle par jeu, aucune écriture directe de renouvellement, aucune création de playlist Bingo, aucune génération PDF et aucune préparation runtime. En cas de concurrence Bingo après matérialisation, il laisse le contrat Global remonter `unassigned_playlist_client_id`, marque `modified=false` et n'effectue aucun nettoyage.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_session_theme_renewal_ajax_test.php`;
- `global/web/app/modules/jeux/programmation/app_programming_recommendations_functions.php`.

## Etat 2026-07-21 - Dashboard soirée/événement: modale personnalisation compacte

La modale Ajax ouverte depuis le lien `Personnaliser la soirée` / `Personnaliser l’événement` du dashboard `/extranet/start/games/day/YYYY-MM-DD/dashboard` conserve la route de chargement `/extranet/start/games/day/event/modal/YYYY-MM-DD` et la sauvegarde `/extranet/start/games/day/event/script`.

Elle s'ouvre maintenant avec deux sections visibles: `Identité et design`, puis `Informations publiques`. La première section contient uniquement le nom contextualisé, le visuel principal, le logo, la couleur principale et la couleur secondaire. Sur desktop, le corps scrollable place ces champs d'identité avant l'aperçu global sticky. L'aperçu global combine le visuel dominant, le logo superposé, le nom, l'accroche et les deux couleurs; il se met à jour côté client lors des changements de texte, fichiers et couleurs. L'aperçu dédié du logo est retiré: le logo reste prévisualisé uniquement dans l'aperçu global.

La date n'est plus affichée ni sauvegardée depuis cette modale. La sauvegarde ne lit plus `hub_date`, ne déclenche plus `ec_start_day_group_move(...)` et ne renvoie plus de redirection de déplacement. La police n'est plus affichée; le traitement relit la police effective existante pour la réécrire telle quelle avec les couleurs, afin de ne pas effacer une valeur persistée.

La modale lit les couleurs effectives depuis le même resolver branding Hub que le dashboard, avec le fallback partagé `#25183c` / `#bba9ff`. Les couleurs explicitement persistées restent distinguées des couleurs effectives: une sauvegarde sans toucher aux champs couleur et sans upload ne crée pas de branding local à cause des valeurs natives de `input[type=color]`.

Après sauvegarde Ajax sans fichier de visuel principal, le dashboard conserve le même visuel effectif qu'au rechargement. Si aucun visuel personnalisé n'existe, la réponse JSON renvoie le fallback `app_games_hub_branding_fallback_visual_get(...)`; côté client, le cache-buster ignore les URLs `data:` et `blob:` pour ne pas casser le SVG fallback.

Les informations publiques sont affichées directement sous la grille principale, sans sous-sections intermédiaires lourdes. Accroche et description restent enregistrées dans `games_hubs_publication`. En mode Soirée, un conseil léger invite à vérifier le lieu publié sur Cotton, puis le résumé et le formulaire structuré du lieu éditent exclusivement les champs natifs du compte (`clients`), sans miroir ni fallback commun avec la publication Hub. En mode Événement, les champs directs sont dans l'ordre accroche, description, lieu, adresse et lien de l'événement; ils restent propres au Hub/publication événement et ne lisent ni ne modifient le compte support.

Desktop: largeur bornée autour de 940 px, hauteur bornée au viewport, header Bootstrap réduit au titre contextualisé, footer `Annuler` / `Enregistrer` fixe, corps central seul scrollable, grille proportionnelle et aperçu sticky désactivé sur viewport bas. Update 2026-07-22: les champs passent avant la colonne d'aperçu, avec proportions ajustées `3fr / 2fr`; l'aperçu est masqué sur mobile. Le conseil média est un texte secondaire sans cadre, en `text-muted`/italique: visuel idéal 1600 × 640 px, logo PNG transparent, fichiers conseillés sous 1 Mo, champ vide pour conserver l'image actuelle. Il ne modifie pas la limite serveur réelle de 10 000 Ko ni ses validations. Mobile: la modale occupe le viewport et n'affiche que les champs utiles et sections publiques, sans preview ni scroll horizontal.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_personalization_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Etat 2026-07-21 - Dashboard soirée/événement après quick-schedule

Le dashboard `/extranet/start/games/day/YYYY-MM-DD/dashboard` reste la surface existante du prototype Hub et conserve ses contrôleurs, helpers, routes et sauvegardes Ajax. Après une création quick-schedule, aucun message post-création n'est rendu sur le dashboard; la redirection unitaire quick-schedule pointe directement vers `/dashboard` sans `?created=1`.

La composition desktop reste en deux colonnes dans la même enveloppe claire. La grille de premier niveau place à gauche la fiche soirée/événement puis les Lots, et à droite les CTA opérationnels puis le Programme. La hauteur de la carte globale suit les hauteurs naturelles des colonnes. Sous `991.98px`, le flux redevient naturel et conserve l'ordre mobile fiche, Programme, Lots puis actions selon les règles responsive du dashboard.

Le visuel de la fiche garde le ratio canonique Hub `5/2` issu du fallback partagé `600x240`: son wrapper n'a ni padding, ni fond apparent, ni bordure; l'image est en `object-fit: contain` pour ne jamais rogner le branding. L'icône de personnalisation n'est plus superposée au visuel: elle est placée en haut à droite de la fiche, à côté du logo éventuel, et conserve un `aria-label`/`title` contextualisé `Personnaliser la soirée` ou `Personnaliser l’événement`. La page publique conditionnelle est affichée dans le bloc localisation, sous l'adresse, comme lien compact `Voir la page publique` avec icône externe; aucune barre d'actions secondaire n'est rendue en bas de fiche.

Le Programme réutilise le résumé partagé `ec_start_agenda_session_summary_get(...)` et les liens détail historiques via `ec_start_day_session_results_url_get(...)`. Son en-tête affiche `Programme` avec un compteur compact `N partie(s)`, sans répéter la ligne date/horaire déjà portée par la fiche soirée/événement. Les lignes du dashboard sont une liste verticale, une partie par rangée pleine largeur desktop et mobile, avec visuel, jeu, thème, version/format et chevron; la ligne entière est le seul lien. Le Programme prend désormais sa hauteur naturelle: il n'a plus de scroll interne, d'indicateur `N autres parties`, de gradients de débordement ni de synchronisation JS avec la colonne gauche. La carte `Ajouter une partie` est rendue en première carte, avant les sessions existantes, puis la page porte le défilement vertical global sur desktop comme sur mobile.

Les helpers horaires partagés affichent désormais seulement l'heure de départ (`À partir de HHhMM`) au lieu d'une plage avec heure de fin. Cela couvre le dashboard, les résumés de dates et l'Agenda `/extranet/start/games`; les compteurs utilisateur du dashboard parlent de `partie(s)`.

Les Lots restent lus et sauvegardés via `app_games_hub_prizes_get(...)` et `app_games_hub_prizes_save(...)`. Le rendu en lecture est une liste compacte sous le titre `Lots`: chaque rang non vide occupe une ligne avec rang, médaille et libellé (`#1 🏆`, `#2 🥈`, `#3 🥉`), séparée par un filet léger. Les valeurs personnalisées remplacent les fallbacks effectifs; les rangs vides restent masqués. L'action de lecture unique `Modifier les lots` reste à côté du titre. Sur desktop/tablette, l'édition locale affiche le même formulaire en panneau superposé opaque ancré en bas de carte, déployé entièrement vers le haut au-dessus des informations voisines, sans variation de hauteur ni déplacement du contenu inférieur; seul le corps des trois champs peut scroller si nécessaire. Sur mobile, l'édition reste intégrée à hauteur naturelle avec `Annuler` / `Enregistrer` sous les champs. Ajax, CSRF, annulation, restauration des valeurs persistées et maintien des saisies en erreur restent conservés; aucun message de succès technique n'est affiché en lecture.

Le CTA Remote Hub est rendu avant le Hub Master avec les libellés courts `Télécommande` et `Afficher le QR code`, mais reste volontairement désactivé avec `Bientôt disponible`: aucune route Hub Remote opérationnelle n'a été trouvée côté dashboard Pro. Les routes observées sont les remotes historiques de session sous `games/web/remote_canvas.php` et `/remote/{game}/{sessionId}`; elles ne constituent pas un contrat Remote Hub soirée/événement. Les deux accès opérationnels sont des cartes compactes en haut de la colonne droite sur desktop, côte à côte via `auto-fit` quand la largeur le permet et empilées sinon. Le CTA Hub Master continue d'utiliser strictement `$day_hub_master_url`, affiche le kicker `Diffuser aux joueurs` puis `Diffuser la soirée` ou `Diffuser l’événement`, sauf état fermé qui garde l'accès résultats. Son fond plein utilise l'accent de branding effectif, avec couleur de texte calculée pour le contraste; la Remote garde un fond léger teinté par ce même accent.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`.

## Etat 2026-07-20 - Programmation rapide V1

Une route PRO dédiée `/extranet/start/games/quick-schedule` expose le nouveau programmateur rapide. Elle accepte `source=home|agenda` et `date=YYYY-MM-DD` pour le contexte Agenda. L'écran affiche une proposition compacte à confirmer, contextualisée avec le wording canonique soirée/événement: date puis horaire avec les contrôles maison du quick historique, chips jeu, mode smartphone/papier, chips 3/2/1 parties et une carte résumé `Ta soirée` ou `Ton événement`.

Le retour est borné côté serveur: `source=home` affiche `Retour à l’accueil` vers `/extranet/dashboard`, `source=agenda` affiche `Retour à mon agenda` vers le tunnel Agenda canonique, et une source absente ou invalide utilise ce même repli canonique sans URL de retour libre. Le bouton `Annuler` partage exactement cette destination. La carte résumé affiche le jeu sur sa propre ligne, la date avec `À PARTIR DE HHhMM`, puis `N partie(s) sur smartphone/papier` sans répéter le jeu; quick-schedule ne montre plus ni heure de fin, ni horaires techniques individuels, ni plage horaire.

En environnement `dev`, les liens de programmation Home et Agenda pointent directement vers cette route. L'Agenda ne demande plus de sélectionner une date avant d'entrer dans le parcours: `source=agenda` ouvre la même interface que la Home, et la date recommandée est calculée par le service partagé. Le champ date de quick-schedule reprend ensuite le rôle de sélection manuelle.

La date par défaut ne doit jamais être occupée. La vue quick-schedule lit les dates occupées via `ec_start_day_creation_occupied_dates_get(...)`, les transmet au datepicker maison `flatpickerdatetime`, marque les jours concernés et les désactive. Une date occupée est une date du compte portant au moins une session officielle non-démo configurée, plus les événements pivot gérés pertinents quand le compte est en gamification; les états sans session cible ne bloquent pas.

La soumission passe par `frm_mode=quick_schedule_execute` dans le script tunnel existant. Le serveur revalide CSRF, date, heure, offre active, jeu, version, compteur, collision de date et idempotence. Le refus de date occupée est réexécuté côté serveur après reconnaissance d'un replay/reprise idempotente, afin de couvrir requête forgée, date devenue occupée, concurrence et double envoi sans casser le replay de la création initiale. Le format n'est plus exposé dans l'interface rapide: il est déterminé côté serveur par le format canonique par défaut du jeu, actuellement standard `2`. L'espacement quick-schedule canonique est de 1 minute entre sessions: il ordonne les parties persistées (`HH:MM`, `HH:MM+1`, etc.) sans représenter une durée de partie, et il alimente recommandation, hash de commande, récurrence et création réelle. La création réutilise `app_session_ajouter(...)`, les helpers d'auto-thème existants et le chemin canonique `session_theme`, puis crée/réconcilie le Hub avant de rediriger vers `/extranet/start/games/day/YYYY-MM-DD/dashboard`.

En dynamisation uniquement, un lien discret `Programmer plusieurs soirées` sous le champ Date active la récurrence quick-schedule. Les comptes de gamification restent strictement limités à l'événement unique. L'interface récurrente ne propose que `Fréquence`, `Jour` et `Jusqu’au`, avec les fréquences historiques compatibles `weekly`, `biweekly`, `monthly`; le mode historique `Dates libres` n'a aucune UI et ses paramètres sont explicitement refusés côté serveur, comme toute liste arbitraire de dates ou d'horaires. Le navigateur affiche un aperçu des occurrences calculées dans le footer pleine largeur de la carte, après la zone formulaire/aperçu et avant la phrase de réassurance puis les CTA. En programmation simple, ce bloc reste `d-none` et ne réserve aucun espace.

La soumission récurrente reconstruit toujours les occurrences côté serveur via le service global, vérifie que les exclusions sont un sous-ensemble des dates calculées, retire les dates occupées au moment réel de validation et persiste une opération de série. Le gabarit commun est jeu, version, nombre de parties, format standard, heure globale de début et espacement d'ordre quick-schedule d'une minute; les thèmes ne sont pas copiés comme gabarit, ils sont sélectionnés automatiquement sur la liste finale des sessions à créer puis figés dans l'opération avant toute insertion. Chaque occurrence créée produit sa propre soirée, son propre Hub et ses propres rattachements `games_hubs_sessions`; une occurrence ne peut pas réussir si une session manque dans le Hub de sa date ou si le Hub contient un écart de date. Le mode unitaire conserve sa redirection dashboard; le mode récurrent redirige vers `/extranet/start/game/resume-batch/{token}` avec le statut de chaque occurrence.

Fichiers de référence:
- `pro/web/.htaccess`;
- `pro/web/ec/ec.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_quick_schedule.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_agenda_mode.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`.

## Etat 2026-07-17 - Dashboard Hub: URL publique, date et libellés unifiés

Le dashboard soirée/événement affiche dans le bloc localisation le lien vers la page publique Hub quand le Hub existe et qu'au moins une session lui est liée. Le lien est généré vers le domaine `www` configuré, pas vers `pro`; un dashboard événement sans compte publié peut donc exposer son URL Hub événement, tandis qu'une soirée garde aussi l'accès public au lieu depuis la page Hub.

Les titres de fallback sont normalisés partout sur la règle `Événement {nom_compte}` ou `Soirée {nom_compte}`. Le dashboard n'invente plus de titre depuis la date et partage le même libellé de planning que les surfaces Hub: `Lun. 10 août 2026 · à partir de 19h45 · 1 session`, dérivé d'une seule préparation date/horaire/sessions.

Le formulaire de personnalisation remplace le champ organisateur par la date de la soirée ou de l'événement. Cette date est modifiable depuis le dashboard en réutilisant la règle d'éligibilité historique du pivot: déplacement autorisé seulement si aucune session du groupe n'a commencé. Les sessions liées sont déplacées ensemble en conservant leurs horaires. Le dashboard refuse une date déjà occupée pour le même compte et affiche ces dates dans son mini-calendrier.

Le dernier essai non essentiel qui ajoutait le marquage des dates occupées dans les modales historiques `Modifier la date` de l'agenda Pro et du pivot a été annulé. Ces surfaces gardent leur comportement antérieur; la modification de date enrichie reste limitée au dashboard Hub.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`.

## Etat 2026-07-17 - Dashboard soirée/événement: publication et lots Hub canoniques

Le dashboard `/extranet/start/games/day/YYYY-MM-DD/dashboard` utilise maintenant `games_hubs_publication` pour les informations éditoriales et pratiques propres à la soirée ou l'événement: titre, accroche, description, lieu/adresse personnalisés et lien. En mode Soirée, ces champs ne sont plus écrits dans `clients`; les données du lieu ne servent que de fallback factuel à l'affichage. En mode Événement, un miroir legacy vers `operations_evenements` reste borné tant que l'ancienne page publique événement dépend encore de ce modèle.

Le bloc Lots écrit directement dans `games_hubs_prizes` par rang 1, 2 et 3, supprime les rangs vidés, marque `games_hubs.prizes_initialized_at` même si les trois champs sont vidés et renvoie un payload JSON Ajax. Le dashboard ne choisit plus une session source, ne fusionne plus les lots entre sessions et ne propage plus les lots vers `championnats_sessions`. Quand aucun lot personnalisé n'existe, la lecture affiche le fallback générique sans préremplir les champs comme valeurs persistées.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_personalization_helpers.php`;
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`.

## Etat 2026-07-17 - Dashboard soirée/événement: personnalisation unifiée

Le prototype `/extranet/start/games/day/YYYY-MM-DD/dashboard` expose désormais l'icône du visuel principal comme point d'entrée unique de personnalisation de l'opération. La modale chargée en AJAX regroupe Identité, Identité visuelle, Présentation, Informations pratiques et Lien, sans onglets ni distinction visible entre branding et informations métier.

La sauvegarde répartit les données: publication éditoriale/pratique vers `games_hubs_publication`; miroir legacy événement seulement pour compatibilité publique existante; `games_hubs.hub_label` pour le libellé court du Hub; visuel, logo, couleurs et police vers `general_branding`. Après succès, le dashboard met à jour le titre, le visuel, le logo, les couleurs et la police sans rechargement ni notification persistante. Une erreur conserve la modale ouverte et les valeurs saisies.

Le Hub utilisé par le dashboard est celui créé/récupéré par `app_games_hub_get_or_create_for_context(...)`. Son programme est relu via `app_games_hub_sessions_get(...)`, qui alimente désormais la relation persistée `games_hubs_sessions` quand les sessions de la date ou de l'opération sont non ambiguës. Une session ajoutée après la création du Hub est donc réconciliée à la prochaine ouverture du pivot/dashboard, sans créer de Hub concurrent.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_personalization_helpers.php`.

## Etat 2026-07-16 - Prototype parallele du tableau de bord Soiree / Evenement

Une surface de test distincte du pivot historique est disponible pour chaque date autorisee:

- pivot historique inchange: `/extranet/start/games/day/YYYY-MM-DD`;
- prototype: `/extranet/start/games/day/YYYY-MM-DD/dashboard`;
- l'ancien pivot propose un lien explicite `Tester le nouveau tableau de bord`; aucun lien Agenda/Home n'est redirige;
- le prototype reutilise la preparation du pivot, son filtrage `id_client + date`, la derivation gamification/dynamisation et le `get_or_create` Hub existant;
- le premier ecran porte un header enrichi (identite + CTA Hub Master), puis une premiere ligne `Programme des sessions | Lots de la soiree/evenement` bornee a `clamp(380px, 52vh, 440px)` sur desktop. Le header Programme conserve seulement son titre. A partir de 840 px de largeur utile, une container query affiche les six sessions en deux colonnes et trois rangees, sur une base de carte de 100 px avec visuel 72 px; en dessous, la liste revient a une colonne. Sous 992 px, hauteur de carte et liste redeviennent naturelles sans scroll imbrique;
- `Design et personnalisation` occupe seul la seconde ligne avec une grille `.8fr / 1.2fr` et un apercu 5/2 limite a 240 px de haut;
- l'ancien bloc `Preparation`, `Essentiel pret` et le tag `Parametree` sont supprimes; chaque carte suit quatre lignes: badge d'etat, horaire/jeu, theme en capitales, puis caracteristiques plus petites (`Version · Format - Capacite/Participation`). Comme sur le pivot historique, une participation disponible remplace la capacite: les deux ne sont jamais affichees ensemble;
- le Hub Master est la voie principale pour lancer, reprendre, relancer et consulter les resultats; la fiche session reste un acces secondaire de preparation et de detail;
- les cartes session n'activent jamais le runtime et n'exposent aucun Master, Remote, launcher ou reprise directe: chaque carte est un lien unique couvrant toute sa surface vers `/extranet/start/game/view/{id_securite}`, via le helper de detail du pivot. Aucun CTA texte ni lien interactif imbrique n'est rendu; un chevron decoratif, un libelle accessible neutre et un focus clavier visible signalent la navigation;
- l'action historique `Ajouter une session` quitte le header et devient la derniere carte de la grille, avec plus, titre et mention `Completer le programme`. Elle reutilise strictement `day_add_session_url`, reste visible dans un programme vide actionnable et n'entre dans aucun compteur ou etat session. Aucune limite a six sessions n'etant definie, elle reste en septieme position et devient accessible par le scroll interne apres les six cartes visibles;
- le runtime brut (`pending`, `running`, `terminated`/`completed`) reste intact. L'etat fonctionnel du dashboard reutilise la fenetre historique (jour J jusqu'au lendemain avant 12 h): avant `A venir`; pendant `A venir`, `En cours`, `Suspendue` ou `Terminee`; apres fermeture `Terminee` si completee, sinon `Non jouee`. `Suspendue` signifie strictement `running` sans `active_session_id` Hub;
- le Hub Play est expose uniquement comme lien d'inscription copiable dans la page Pro authentifiee;
- le lien couvrant chaque carte reutilise le tracking session existant avec le contexte explicite `prototype tableau de bord`; l'action Hub globale n'est pas attribuee artificiellement a une session;
- la personnalisation regroupe visuel, titre public, lieu/organisateur, origine et couleurs du branding, destinations reelles, page publique, Media Kit et lien participant. Le visuel vient exclusivement de `app_games_hub_branding_get(...)`: evenement, reseau, compte, puis fallback Cotton partage; aucun visuel de session, de jeu ou de fiche lieu n'est un fallback;
- en dynamisation, le rendu precise que le Hub utilise l'identite effective tandis que la page lieu conserve le branding general de l'etablissement;
- les lots sont affiches en lecture a cote du programme (rangs non vides uniquement, etat vide utile), puis `Modifier` / `Ajouter des lots` ouvre localement les trois champs. `Annuler` restaure les valeurs persistantes; une erreur serveur garde l'edition et une sauvegarde reussie revient en lecture. Le resolver partage affiche les trois fallbacks Hub si toutes les sessions sont encore sur leurs defaults propres au jeu, sinon il reprend la premiere session personnalisee dans l'ordre du programme; l'avertissement n'apparait qu'en edition et en cas de divergence reelle;
- l'editeur de lots du dashboard écrit les trois rangs dans `games_hubs_prizes`; les sessions historiques ne sont plus recopiées ni utilisées comme source éditable;
- un seul conseil compact est rendu depuis les agregats temporels existants: `Prepare ta soiree`, `Prepare le lancement`, `Pendant la soiree` ou `Retrouve les resultats`;
- aucun contrat Canvas ou WebSocket et aucune migration ne sont modifies.

Fichiers de reference:
- `pro/web/.htaccess`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`.
- `pro/web/ec/modules/tracking/clients_logs/ec_clients_logs_session_cta_ajax.php`.

## Etat 2026-07-07 - Pivot date: acces debug hub games

Le pivot `/extranet/start/games/day/YYYY-MM-DD` peut afficher un acces discret vers le master hub read-only quand le parametre `hub_debug=1` est present.

Comportement:
- le hub continue d'etre initialise silencieusement comme en Lot 1;
- si le hub existe et que `games_url` est configure, le pivot calcule `/hub/{hub_token}/master` et `/hub/{hub_token}/play`;
- le lien visible du pivot pointe uniquement vers la vue master et seulement en debug;
- l'endpoint JSON reserve `/extranet/start/games/day/hub/debug/YYYY-MM-DD` renvoie aussi `master_url` et `play_url`.

Garde-fous:
- aucune UX visible par defaut;
- aucun lien automatique vers la vue joueur hub depuis PRO;
- aucune route session directe modifiee.

Fichiers de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_hub_debug.php`.

## Etat 2026-07-07 - Pivot date: hub games silencieux

Le pivot `/extranet/start/games/day/YYYY-MM-DD` initialise silencieusement le conteneur `games_hubs` de la date affichee.

Comportement:
- en gamification, le hub est cree/retrouve avec `context_type=event` quand un `id_operation_evenement` unique existe ou est assure par le pivot;
- en dynamisation/soiree sans evenement public, le hub est cree/retrouve avec `context_type=soiree` sur `id_client + date`, sans creation `operations_evenements`;
- les autres contextes utilisent `context_type=day`;
- aucune UX visible, aucun CTA hub, aucune page WWW et aucune route session directe ne sont modifies;
- l'endpoint reserve `/extranet/start/games/day/hub/debug/YYYY-MM-DD` renvoie en JSON le hub, les sessions liees et le type de branding effectif pour controle manuel en contexte EC connecte.

Fichiers de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_hub_debug.php`;
- `pro/web/.htaccess`.

## Etat 2026-07-06 - Pivot et communauté Blind Test mixtes

Les surfaces Pro qui affichent les agrégats Blind Test utilisent maintenant une règle unique quand des équipes runtime existent.

Comportement:
- le moteur global remplace les membres présents dans `blindtest_session_teams.members_json` par l'identité équipe `team:{team_name_normalized}`;
- les joueurs solo de la même session restent des joueurs;
- les équipes runtime sont affichees avec leur nom brut et un badge `ÉQUIPE`, pas avec un suffixe `(n)`;
- le pivot `/extranet/start/games/day/YYYY-MM-DD` affiche un classement participants mixte pour Blind Test: équipes + solos, triés par score agrégé;
- la page communauté/saison affiche également Blind Test comme un classement participants unique quand des équipes runtime existent;
- le podium Pro partagé recalcule aussi le podium Blind Test sur cette population mixte;
- les bonus podium saison sont attribués depuis un seul classement par session, pas depuis deux classements séparés joueurs/equipes;
- les anciennes sessions sans données `blindtest_session_teams` gardent les fallbacks existants.

Invariants:
- pas d'ecriture dans `blindtest_players`;
- pas d'utilisation de `equipes` pour les équipes runtime Blind Test;
- Quiz, Bingo et sessions Blind Test sans equipe conservent leur comportement.

## Etat 2026-07-03 - Agregats EC Pro: equipes runtime Blind Test

Les surfaces EC Pro de bilan et de communaute recuperent les classements depuis le moteur global `app_client_joueurs_dashboard_*`.

Comportement:
- le bilan pivot `/extranet/start/games/day/...` affiche les equipes runtime Blind Test quand le podium persiste contient des entrees equipe;
- la page `/extranet/account/establishment/view/general` fait de meme sur les classements saisonniers;
- les templates Pro affichent les lignes equipe runtime avec nom brut + badge `ÉQUIPE`.

Invariants:
- pas de changement des routes, du rendu des sessions sans equipe, ni du scoring affiche;
- la correction est portee par `global/web/app/modules/entites/clients/app_clients_functions.php`.

## Etat 2026-07-03 - Logs CTA session bornes aux sessions

Les logs `Session #... > CTA ... cliqué [ contexte ]` ne doivent plus representer l'ouverture d'un pivot date.

Comportement:
- le widget Home `Mon agenda` et le resume batch n'annotent plus leurs liens vers `/extranet/start/games/day/YYYY-MM-DD`;
- l'arrivee sur le pivot reste tracee par le log de page `Page : tunnel > start > sessions_day`;
- les attributs `data-session-cta-log="1"` restent portes par les CTA de cartes session qui ouvrent/preparent/reprennent une session ou ses resultats;
- le contexte fallback des cartes agenda devient `agenda liste`;
- le libelle serveur conserve `Ouvrir le jeu` quand le CTA de session le porte explicitement.

Fichiers de reference:
- `pro/web/ec/modules/tracking/clients_logs/ec_clients_logs_session_cta_ajax.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`;
- `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php`.

## Etat 2026-07-02 - Contacts multi-comptes: bascule bornee

L'EC conserve le modele contact multi-comptes existant: un contact peut etre rattache a plusieurs clients et utiliser le selecteur de compte quand plusieurs rattachements existent.

Comportement:
- la connexion email/password choisit encore le premier client rattache par ordre `id_client ASC`;
- le selecteur de compte `client_gate` verifie maintenant que le client poste appartient au contact courant avant de recreer la session EC;
- une bascule reelle de compte est journalisee sur le client destination avec le compte source et le compte destination;
- un lien temporaire genere depuis une fiche client BO transmet le client cible et la consommation du token respecte ce client si le contact y est bien rattache;
- un lien temporaire sans client cible garde le fallback historique vers le premier client rattache.

Fichiers de reference:
- `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`.

## Etat 2026-07-02 - Bibliotheque Quiz papier: serie unique

Depuis la bibliotheque PRO, la programmation d'un Quiz papier V2 avec une seule serie selectionnee respecte maintenant cette intention.

Comportement:
- le flux `from=library` transmet la serie catalogue sous forme `L{id}` via le setting puis `session_theme`;
- si la session est un Quiz V2 papier et que la selection contient une seule serie catalogue, `lot_ids` reste limite a cette serie;
- la generation papier automatique des 3 lots temporaires `T` n'est pas declenchee dans ce cas;
- un log applicatif `QUIZ_PAPER_LIBRARY_SINGLE_SERIES` trace le chemin avec `session_id`, `id_catalogue_produit` et `lot_ids`;
- les compositions Quiz papier automatiques multi-series restent inchangées hors flux bibliotheque serie unique.

Fichier de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`.

## Etat 2026-07-02 - Logs clics CTA session

Les clics explicites sur CTA de session sont journalises sans changer la destination des liens.

Comportement:
- les liens annotes `data-session-cta-log="1"` envoient un log via `/ec/ec_ajax.php?t=tracking&m=clients_logs&p=session_cta`;
- le navigateur utilise `navigator.sendBeacon` quand disponible, puis `fetch(... keepalive)` en fallback;
- les actions sont normalisees en `Préparer`, `Ouvrir`, `Reprendre`, `Résultats`;
- les contextes couverts sont `home`, `home jour J`, `pivot date`, `pivot date jour J`, `confirmation programmation`;
- le log ecrit suit le format `Session #... > CTA ... cliqué [ contexte ]`;
- le serveur verifie que la session appartient au client connecte avant ecriture;
- le filtrage admin/support existant dans `log_ajouter(...)` continue d'empecher la pollution `clients_logs` pendant une session BO/admin;
- aucun log automatique au chargement de page n'est ajoute.

Fichiers de reference:
- `pro/web/ec/modules/tracking/clients_logs/ec_clients_logs_session_cta_ajax.php`;
- `pro/web/ec/ec.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume.php`;
- `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`.

## Etat 2026-07-02 - First_party: offre active non eligible et logs non trompeurs

Le tunnel `/extranet/onboarding/first-party` est reserve aux comptes prospect/reactivation sans offre active. Une offre active sort du parcours first_party avant rendu de l'ecran.

Comportement:
- le brouillon `first_party_onboarding_v1_{id_client}` porte `commercial_state='prospect'` ou `commercial_state='active'`;
- a chaque chargement/action du tunnel, l'etat courant est recalcule depuis l'offre effective;
- si une offre active est detectee, le brouillon est purge, un log first_party explicite est ecrit, puis l'utilisateur est redirige avant rendu HTML;
- la redirection vise le pivot de date si une session future existe, sinon la programmation classique;
- les comptes avec offre active, y compris `ABN` / `PAK` sans historique officiel utile, ne sont plus eligibles au tunnel first_party;
- le log de route generique `Page : tunnel > start > first_party_onboarding` n'est plus ecrit par le footer global;
- un affichage reel du tunnel loggue `First_party > écran affiché [ prospect éligible ]` ou `First_party > écran affiché [ réactivation éligible ]`;
- une creation effective depuis le tunnel loggue separement `Session officielle > création depuis first_party`;
- aucune logique ne s'appuie sur `clients_logs.online`.

Fichiers de reference:
- `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- `pro/web/ec/ec.php`.

## Etat 2026-07-02 - Logs client: exclusion des sessions BO/admin

Les logs internes client ne sont plus alimentes par les actions declenchees pendant un acces support/admin depuis le BO vers l'EC.

Comportement:
- l'acces BO/admin vers EC est detecte au moment ou `pro/web/ec/modules/compte/authentification/ec_authentification_script.php` consomme les cookies `CQ_admin_gate_client_id` et `CQ_admin_gate_client_contact_id`;
- la session EC conserve `CQ_admin=1` et ajoute `CQ_admin_context='bo_client_gate'` pour les requetes suivantes, une fois les cookies supprimes;
- le helper global `log_ajouter(...)` ignore les ecritures vers `clients_logs` quand ce contexte admin est present;
- une authentification client normale, un lien temporaire client ou un acces direct jeu avec `CQ_admin=0` purge ce marqueur;
- la deconnexion supprime aussi `CQ_admin_context`;
- le champ `online` de `clients_logs` n'est pas utilise pour differencier l'origine client/admin.

Limite historique:
- les anciennes lignes deja ecrites sans marqueur admin ne sont pas reclassees automatiquement; un nettoyage doit rester manuel et borne par une fenetre/date/IP connue.

Fichiers de reference:
- `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`;
- `pro/web/ec/modules/compte/deconnexion/ec_deconnexion_script.php`;
- `pro/web/ec/ec_sign.php`;
- `pro/web/ec/ec.php`;
- `global/web/lib/core/lib_core_log_functions.php`.

## Etat 2026-07-02 - Feedback Home borne a l'offre active et a la soiree

Le widget feedback Home porte maintenant sur la derniere soiree ou le dernier evenement, en conservant une session d'ancrage technique pour l'enregistrement.

Comportement:
- le titre devient `Ta dernière soirée...` ou `Ton dernier événement...` selon le contexte client;
- un retour deja donne sur une session de la meme date bloque une nouvelle demande sur cette soiree/evenement;
- quand une offre effective active existe, la recherche de session terminee recente est bornee a `championnats_sessions.id_offre_client` de cette offre;
- un CSO/reactive avec une nouvelle offre active ne voit plus une demande de feedback portant sur une session terminee d'une ancienne offre;
- sans offre active, le comportement historique du widget reste conserve.

Fichiers de reference:
- `pro/web/ec/modules/general/feedback/ec_feedback_lib.php`;
- `pro/web/ec/modules/communication/home/ec_home_index.php`.

## Etat 2026-07-02 - Agenda archives et bilan des sessions papier

Les archives agenda PRO affichent maintenant les journees significatives comme des groupes complets: le filtre d'historique utile sert a retenir la date, puis toutes les sessions archivees de cette date sont rendues dans la carte.

Comportement:
- une journee archivee retenue parce qu'elle contient une session papier ou des resultats ne masque plus les autres sessions archivees de la meme date;
- les filtres jeu/date restent appliques;
- le pivot passe `/extranet/start/games/day/YYYY-MM-DD` compte les sessions papier passees comme sessions jouees;
- quand des sessions papier sont archivees sans resultats exploitables, le bloc `Bilan` affiche le total de sessions et un message generique `Aucun résultat disponible pour cette soirée/cet événement.`.

Fichiers de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`.

## Etat 2026-07-02 - Pivot evenement: lien resultats publics dans le bilan

Sur le pivot gamification `/extranet/start/games/day/YYYY-MM-DD`, le bloc `Bilan de ton événement` affiche maintenant un lien simple vers la page publique quand au moins une session est terminee et que l'evenement dispose d'une page publique.

Comportement:
- contexte limite aux evenements gamification avec bilan contenant au moins une session terminee;
- le lien apparait dans le bloc bilan, sous la phrase `Retrouve le résultat de la session jouée.` ou `Retrouve les podiums et classements des sessions jouées.`;
- libelle: `→ Voir sur la page web de l’événement`;
- cible: page publique `www` `/fr/evenements/{slug}`, ouverte dans un nouvel onglet;
- pas d'affichage en dynamisation ni avant les premieres sessions terminees.

Fichier de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`.

## Etat 2026-07-01 - Logs internes client prospects et offres

Les logs internes client distinguent maintenant mieux les etats Home, les types de sessions et les actions d'offres.

Comportement:
- les creations de sessions journalisent le type: `Session démo {Jeu} #{id} > ajout [ YYYY-MM-DD ]` ou `Session officielle {Jeu} #{id} > ajout [ YYYY-MM-DD ]`;
- les trois etats Home deja pousses en `dataLayer` sont aussi journalises cote serveur dans `clients_logs`, une seule fois par chargement principal;
- la page `Mon offre` ajoute `Offre > Mon offre > affichage`;
- la creation d'une offre en attente ajoute `Offre > Souscription > étape 1`;
- la validation commune SEPA/Stripe conserve `Client > Offre > Validation` et ajoute `Offre > Validation`;
- une validation avec `trial_period_days > 0` ajoute `Offre > Essai gratuit > activé`;
- l'ancien flux sans engagement qui pose une `date_fin` ajoute `Offre > Renouvellement > désactivation demandée` puis `Offre > Renouvellement > désactivation confirmée`;
- les logs pipeline `Client > Pipeline > Etat > ...` sont conserves sans duplication.

Limites:
- les clics Home utiles restent uniquement analytics/front dans cette passe, faute d'endpoint serveur dedie audite;
- aucun libelle de resiliation immediate n'est ajoute, car le flux audite correspond a une desactivation de renouvellement par fin de periode.

Fichiers de reference:
- helper logs: `global/web/lib/core/lib_core_log_functions.php`;
- sessions: `global/web/app/modules/jeux/sessions/app_sessions_functions.php`;
- home: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- offres: `pro/web/ec/modules/compte/offres/ec_offres_view.php`, `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`, `global/web/app/modules/ecommerce/app_ecommerce_functions.php`.

## Etat 2026-07-01 - Expiration du contexte affiliation signup/signin

Le contexte d'affiliation pre-auth issu des LP reseau est maintenant temporaire et borne a 2 heures.

Regles livrees cote PRO:
- `/utm/reseau/{slug}` et `/utm/reseau/{slug}/signin` posent `$_SESSION['id_client_reseau']` avec `id_client_reseau_context_created_at` et `id_client_reseau_context_expires_at`;
- un contexte ancien sans `id_client_reseau_context_expires_at` est invalide et purge au prochain rendu ou POST pre-auth;
- `signup` et `signin` appliquent l'habillage reseau uniquement si le contexte est encore valide;
- la creation de compte et le signin de compte existant consomment l'affiliation uniquement si l'expiration n'est pas depassee;
- la remise reseau portee par ce contexte est supprimee si le contexte est invalide;
- la deconnexion nettoie aussi les metadonnees d'expiration;
- un nouveau passage volontaire par la LP reseau recree un contexte valide de 2 heures.

Points d'entree PRO:
- pose du contexte: `pro/web/ec/ec_sign.php`;
- rendu pre-auth: `pro/web/ec/ec_signup.php`, `pro/web/ec/ec_signin.php`;
- purge POST: `pro/web/ec/do_script.php`, `pro/web/fo/do_script.php`;
- consommation creation/signin: `pro/web/ec/modules/compte/client/ec_client_script.php`, `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`;
- nettoyage deconnexion: `pro/web/ec/modules/compte/deconnexion/ec_deconnexion_script.php`.

Voir aussi la carte `www`: les CTA stockes cote site public peuvent recreer `/utm/reseau/...`; ils sont donc expires avec la meme duree de 2 heures.

## Etat 2026-07-01 - Home classique et confirmation apres offre active

Les comptes avec offre active ou essai gratuit actif sortent du guidage first_party force sur la home et sur la confirmation de commande.

Comportement:
- la home reduite first_party est reservee aux comptes sans offre active, notamment les `INS` eligibles;
- les comptes `ABN` / `PAK` avec offre effective active affichent la home classique, meme sans session future ni historique significatif;
- sur home classique, aucun widget ou encart first_party n'est pousse;
- si un compte `ABN` / `PAK` actif n'a ni session future ni historique significatif, la premiere ligne Home affiche aussi un 3e widget `Mon offre`, apres l'agenda programmation et les jeux Cotton;
- ce widget reprend l'offre effective active, evite un doublon avec la boucle PAK existante et affiche un resume compact avec visuel contextualise, reference/date, tarif, periode courante ou essai gratuit, et eventuelle fin programmee;
- la date de fin programmee est alignee avec `Offre & factures`: `trial_end` Stripe n'est utilise que si l'offre est encore en essai actif; sinon la fin de periode courante fait reference;
- `Offre & factures` tutoie aussi les mentions de fin programmee (`Ton abonnement...`, `Ton essai...`) pour rester coherent avec la Home;
- les sessions futures de la Home et de la confirmation acceptent l'offre effective active ainsi que les sessions non rattachees preparees avant commande (`id_offre_client=0` ou `NULL`);
- le fallback d'historique utile reste filtre sur l'offre effective active; une ancienne animation liee a une offre terminee ne peut donc plus remplacer la programmation d'une nouvelle offre reactivee;
- la confirmation de commande S3 applique le meme principe sur l'offre qui vient d'etre validee: sans session rattachee a cette offre, elle propose la programmation au lieu du bilan historique;
- l'etat vide du widget agenda Home suit l'usage: gamification `Ajoute ton prochain événement` avec modale de date, dynamisation `Programmation` avec lien programmateur;
- la confirmation de commande `/ecommerce/offers/manage/s3/...` ne renvoie plus vers le tunnel first_party apres activation;
- depuis cette confirmation, si des sessions futures existent, la carte riche de prochaine soiree/evenement de la Home est reutilisee et ouvre le pivot;
- sans session future, le widget reprend la programmation selon l'usage: creation d'evenement en gamification, programmateur de soiree en dynamisation.
- sur desktop large, la confirmation affiche le detail de commande en deux tiers et le widget en un tiers; sur mobile/tablette, les deux blocs restent empiles pleine largeur.

Fichiers de reference:
- home: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- agenda Home: `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`;
- offre Home: `pro/web/ec/modules/widget/ec_widget_ecommerce_offre_client_bloc.php`;
- confirmation commande: `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php`;
- widget CTA sessions: `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`.

## Etat 2026-06-30 - Logs demo catalogue non trompeurs

Les parcours d'inscription/catalogue et les acces directs de jeu ne journalisent plus `MAJ date session demo` quand aucune session demo n'existe reellement pour le client.

Comportement:
- `ec_sign.php` relit les lignes `championnats_sessions.flag_session_demo=1` du client avant toute mise a jour de date;
- si aucune ligne n'est trouvee, aucun log standard `MAJ date session demo` n'est ecrit;
- si des demos existent, seules ces lignes sont ciblees par l'UPDATE de date et le log contient l'id de chaque session ciblee;
- `ec_client_script.php` et `ec_authentification_script.php` n'emettent plus ce libelle sans contexte de session demo rattachee au client courant;
- l'inscription standard sans parametres catalogue produit le log explicite `Inscription standard [ aucune demande catalogue ]`;
- dans l'inscription catalogue, une demande de demo qui ne cree aucune ligne `championnats_sessions` produit le log explicite `Inscription sans demo [ type produit #... / catalogue #... ]`;
- aucune session demo n'est creee sur simple connexion; `app_session_demo_ajouter`, first_party, agenda, sessions officielles et dates occupees ne changent pas.

Fichiers de reference:
- `pro/web/ec/ec_sign.php`;
- `pro/web/ec/modules/compte/client/ec_client_script.php`;
- `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`.

## Etat 2026-06-30 - Bibliotheque Quiz: detail des lots numeriques `N`

Depuis une fiche session Quiz numerique, le lien `Voir le détail` vers `/extranet/games/library/temp/N{id}` affiche les variantes numeriques des questions.

Comportement:
- les lots `N` utilisent `questions.question_numerique`, `questions.reponse_numerique` et `questions.commentaire_numerique` en affichage quand ces champs sont renseignes;
- les champs source `question`, `reponse`, `commentaire` restent conserves pour les formulaires et les usages papier;
- les lots temporaires papier `T` et les lots catalogue `L` conservent la vue classique.

Fichier de reference:
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`.

## Etat 2026-06-26 - Formats courts Blind Test/Bingo

Le tunnel PRO distingue maintenant la `Version du jeu` du `Format de la session` pour Blind Test et Bingo Musical.

Comportement:
- `session_flag_controle_numerique` reste dedie a la version papier/numerique;
- `session_id_format` porte le format metier par jeu: `2` standard, `5` court pour Blind Test/Bingo;
- le choix Standard/Court apparait dans le setting classique et dans le quick agenda uniquement pour Blind Test/Bingo;
- le quick agenda masque/desactive ce choix pour Cotton Quiz afin de ne pas modifier ses formats;
- le bouton de validation du quick agenda utilise la couleur neutre `bg-color-20`, tandis que le setting unitaire garde la couleur du jeu;
- les resumes/listes et la fiche detail affichent `40 titres` ou `20 titres` quand le jeu est Blind Test/Bingo;
- dans le setting classique, `Format de la session` et `Version du jeu` reprennent le style chips radio du quick mais restent deux champs distincts;
- le setting unitaire Blind Test/Bingo utilise le meme markup `agenda-quick-choice-*` que le quick, pas les anciennes grandes cartes compactees par CSS;
- pour Bingo, l'agenda et la fiche detail affichent le format du produit quand il differe encore de `championnats_sessions.id_format`;
- pour Blind Test, le listing agenda recharge le detail session complet afin de lire `championnats_sessions.id_format` et afficher `20 titres` pour le format court;
- la fiche bibliotheque ouverte depuis une session (`context=session`) affiche les titres reellement utilises par cette session: snapshot playlist client pour Bingo, selection courte deterministe pour Blind Test;
- depuis la fiche detail, l'impression Bingo papier ouvre directement le PDF Canvas `games/includes/canvas/php/bingo_grids_paper.php`, comme les options de jeu;
- sur une session Bingo deja generee, un changement de format via `Modifier` regenere un nouveau playlist client et ses grilles avant de supprimer l'ancien; en cas d'echec confirme, l'ancien produit reste reference et le retour se fait sur le setting.

Fichiers de reference:
- setting/quick: `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`;
- sauvegarde/configuration: `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- affichages: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`, `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`, `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`.
- fiche bibliotheque session: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`.

## Etat 2026-06-26 - Agenda/widgets: dates deja programmees ouvrables

Dans l'écran de programmation depuis l'agenda et dans les widgets gamification de choix direct d'une date d'evenement, le bloc `Ajouter une soirée` / `Créer un événement` distingue maintenant les dates deja programmees des dates passees indisponibles.

Comportement:
- les dates deja programmees ne sont plus envoyees a flatpickr comme dates `disable` sur l'ecran agenda mode ni sur les modales directes de creation d'evenement;
- elles restent selectionnables et portent un style dedie dans le calendrier;
- la selection d'une date deja programmee affiche un message explicite avec date en français: `Une soirée est déjà programmée le ...` ou `Un événement est déjà programmé le ...`;
- le CTA devient `Ouvrir la soirée` / `Ouvrir l’événement` et redirige vers `/extranet/start/games/day/YYYY-MM-DD`;
- une date libre conserve le CTA de creation et le POST `sessions_day_create`;
- le serveur conserve le garde anti-doublon existant `date_error=occupied`;
- les dates passees restent bloquees par `minDate`, et les parcours quick multi-dates, pivot, bibliotheque classique et first_party ne changent pas.

Fichiers de reference:
- ecran agenda mode: `pro/web/ec/modules/tunnel/start/ec_start_agenda_mode.php`;
- widgets/modales evenement: `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`, `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`, `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- helpers dates occupees / pivot: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- garde serveur creation: `pro/web/ec/modules/tunnel/start/ec_start_script.php`.

## Etat 2026-06-26 - Dynamisation agenda: parcours sans stepper

Le parcours de programmation depuis l'agenda dynamisation ne présente plus le stepper 3 étapes.

Comportement:
- `/extranet/start/agenda/mode/...` conserve le titre `Programmer mes soirées` et les blocs `Ajouter une soirée` / `Programmer plusieurs soirées`, sans `Étape 1/3`;
- `/extranet/start/game/setting/...&from=agenda&mode=quick` conserve le titre `Programmation rapide`, le formulaire et l'aperçu, sans `Étape 2/3`;
- `/extranet/start/game/resume-batch/...` conserve le titre `Tes sessions sont prêtes !`, les sessions, les badges `Ajoutée` et les CTA, sans `Étape 3/3`;
- le ciblage reste limité aux comptes dynamisation; les routes, la création de sessions, `first_party`, la bibliothèque classique, le pivot unitaire et la gamification ne changent pas.

Fichier de reference:
- header tunnel/stepper: `pro/web/ec/modules/tunnel/start/ec_start_include_header.php`.

## Etat 2026-06-26 - Pivot date: ajout session unitaire sans resume

Depuis le pivot `/extranet/start/games/day/YYYY-MM-DD`, l'ajout d'une session unitaire passe par choix jeu/bibliothèque/setting puis revient directement au pivot après validation.

Comportement:
- les steppers sont masqués sur le choix jeu, la bibliothèque, la fiche bibliothèque et le setting seulement quand le contexte porte `day_date` + `return_url` et n'est pas le quick multi-dates;
- le setting affiche la mention de contexte date: `Cette session sera ajoutée à la soirée programmée le ...` ou `Cette session sera ajoutée à l'événement programmé le ...`;
- après création de la session et application du contenu bibliothèque, le retour se fait directement vers le `return_url` sûr ou vers `/extranet/start/games/day/YYYY-MM-DD`, avec `session_created=1`;
- `/start/game/resume/` reste disponible pour les parcours unitaires hors pivot et `/start/game/resume-batch/` reste inchangé pour le quick;
- les paramètres `day_date`, `day_context`, `return_url` et `event_pending=1` restent propagés.

Fichiers de reference:
- header tunnel/stepper: `pro/web/ec/modules/tunnel/start/ec_start_include_header.php`;
- setting et retour serveur: `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`, `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- bibliothèque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`, `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`.

## Etat 2026-06-26 - Home gamification: datepicker creation evenement

La modale `Créer un événement` ouverte depuis le widget Home gamification initialise maintenant son champ date comme la modale de l'agenda.

Comportement:
- la Home garde son optimisation globale qui désactive les scripts étendus par défaut;
- quand la modale événement Home est présente, le widget charge localement flatpickr, la locale FR, le thème Cotton et le plugin de confirmation;
- le champ date affiche un libellé lisible via `altFormat: j F Y`, tout en postant `day_date` au format `YYYY-MM-DD`;
- le calendrier s'ouvre au clic dans le champ;
- la modale agenda, les routes et le POST `sessions_day_create` ne changent pas.

Fichier de référence:
- widget agenda Home: `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`.

## Etat 2026-06-26 - Cartes jeux library/choose: largeur responsive

Les cartes principales de jeux de `/games/library` et `/start/game/choose/` reprennent une logique responsive cohérente: row fluide, colonnes plafonnées et mêmes breakpoints.

Comportement:
- les cartes jeu de la bibliothèque utilisent une classe dédiée, sans modifier les cartes produits ni les CTA;
- sur l'accueil bibliothèque, les règles sont déclarées dans le style commun du hub, avant le branchement `network_manage` et avant le `return`;
- sur petits écrans, les cartes peuvent être centrées avec une largeur lisible;
- dès tablette, l'alignement revient au flux standard;
- les colonnes bibliothèque reprennent les mêmes plafonds et breakpoints que `/start/game/choose/`;
- le bloc `Les jeux du réseau` est borné sur le footprint des 3 cartes principales, sans contraindre la row des jeux, sur `/games/library` comme sur `/start/game/choose/`.

Fichiers de référence:
- bibliothèque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`;
- choix jeu: `pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php`.

## Etat 2026-06-26 - Modele date: modification au niveau soiree/evenement

La date est maintenant portee par la soiree ou l'evenement complet. Une session individuelle conserve seulement son horaire modifiable.

Comportement:
- la page detail/gestion d'une session ne propose plus de modification individuelle de date;
- le setting d'une session existante affiche la date en lecture seule et indique `La date se modifie depuis la soirée ou l’événement complet.`;
- l'heure de la session reste modifiable depuis le setting session;
- un ancien POST `session_setting` ne peut plus deplacer une session seule: si la session est deja complete, la date originale est conservee cote serveur;
- le deplacement complet depuis le pivot `/extranet/start/games/day/YYYY-MM-DD` reste la voie unique pour changer la date d'une soiree ou d'un evenement;
- le jour J, ce deplacement complet est autorise tant que toutes les sessions de la date sont encore en attente;
- si une session du jour est demarree, en cours, terminee ou verrouillee, le deplacement complet reste bloque;
- les routes publiques, pages publiques, quick, creation de soiree/evenement, ajout de session depuis pivot, suppression de session et modification d'heure ne changent pas.

Fichiers de reference:
- setting session: `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`;
- sauvegarde setting: `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- vue session: `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`;
- pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- helpers deplacement pivot: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`.

## Etat 2026-06-26 - Programmation soiree/evenement: ajustements post-recette

Les parcours date/pivot distinguent maintenant plus clairement une premiere session d'une session complementaire, sans changer les routes ni la creation.

Comportement:
- le parcours agenda dynamisation utilise un stepper en 3 etapes: `Programmation`, `Paramètres`, `C'est prêt !`;
- l'ecran `/start/agenda/mode/...` en dynamisation affiche `Étape 1/3 — Programmation`;
- le quick `/start/game/setting/...&from=agenda&mode=quick` affiche `Étape 2/3 — Paramètres`;
- le resume batch quick affiche `Étape 3/3 — C'est prêt !`;
- en quick dynamisation, l'apercu des occurrences indique pour chaque ligne si elle cree une `Nouvelle soirée` ou si elle ajoute une `Session ajoutée à la soirée existante`;
- le bloc `Ajouter une soirée` precise que la thematique de chaque session sera choisie ensuite;
- le bloc `Programmer plusieurs soirées` precise que les thematiques sont choisies automatiquement selon les dates, parmi les contenus populaires;
- sur `/start/game/setting/...&from=library`, un message court apparait seulement si la date cible contient deja des sessions: depuis une date liee, `Cette session sera ajoutée à ta soirée.` / `Cette session sera ajoutée à ton événement.`; depuis le catalogue sans date liee, `Cette session sera ajoutée à la soirée programmée à cette date.` / `Cette session sera ajoutée à l'événement programmé à cette date.`;
- ce message est rendu au chargement si la date est deja connue et se met a jour quand l'utilisateur change la date dans le champ `session_date`;
- les parametres `day_date`, `day_context`, `return_url` et `event_pending=1` restent propages dans les liens et formulaires de la bibliotheque et du setting;
- `/start/game/choose/` affiche le titre singulier `Je programme une session de jeu`, sans astuce basse, avec des cartes plus souples sur les largeurs intermediaires;
- la bibliotheque ouverte depuis un pivot affiche `Choisis une première session...` si la date est vide et `Choisis une nouvelle session...` si la date contient deja des sessions;
- le resume batch quick regroupe par date toutes les sessions officielles de chaque date concernee, y compris celles qui existaient deja, et marque les sessions nouvellement creees.

Fichiers de reference:
- setting/quick: `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`;
- choix mode agenda et stepper: `pro/web/ec/modules/tunnel/start/ec_start_agenda_mode.php`, `pro/web/ec/modules/tunnel/start/ec_start_include_header.php`;
- choix jeu: `pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php`, `pro/web/ec/modules/tunnel/start/ec_start_include_header.php`;
- bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`, `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`;
- routage setting/library: `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- resume batch: `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php`.

## Etat 2026-06-26 - Gamification: date avec pivot vide non bloquante

La modale gamification `Créer un événement` ne bloque plus une date uniquement parce qu'un pivot événement managé vide existe déjà pour cette date.

Comportement:
- une date reste occupée si elle contient au moins une session officielle configurée;
- un pivot événement vide `cotton-event-{id_client}-{YYYYMMDD}` ne rend plus la date indisponible dans le datepicker;
- si l'utilisateur choisit une date qui possède déjà ce pivot vide, la création réutilise le pivot existant et redirige vers `/extranet/start/games/day/YYYY-MM-DD`;
- la dynamisation reste inchangée.

Fichier de reference:
- helpers date/pivot: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`.

## Etat 2026-06-26 - Pivot date: etat vide premiere session

Le pivot `/extranet/start/games/day/YYYY-MM-DD` distingue maintenant une date deja composee de sessions d'une date qui vient seulement d'etre creee.

Comportement:
- avec des sessions, le pivot conserve les chips de synthese (`X sessions`, horaire de depart), les cartes sessions existantes et la carte complémentaire `Ajouter une session`;
- sans session, le header affiche la chip `Aucune session`;
- sans session, le sous-texte header indique `Ta soirée est créée. Ajoute une première session de jeu pour commencer.` en dynamisation et `Ton événement est créé. Ajoute une première session de jeu pour commencer.` en gamification;
- sans session, la carte d'ajout devient l'action principale `Ajouter une première session`;
- le lien d'ajout conserve `day_date`, `day_context`, `return_url` et propage `event_pending=1` dans le retour si le pivot l'a reçu;
- les routes, la creation de sessions, le quick, la modale de creation evenement, les pages publiques et les CTA des cartes sessions existantes ne changent pas.

Fichier de reference:
- pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`.

## Etat 2026-06-26 - Quick dynamisation V2.1: reglages globaux compacts

La programmation rapide dynamisation reste sur la page unique `start/game/setting/{token}?from=agenda&mode=quick`, mais l'interface ne garde plus que deux blocs principaux: `Programmation`, puis `Sessions à créer`.

Comportement:
- `Programmer plusieurs soirées` initialise un brouillon quick technique puis ouvre directement le formulaire `Programmation rapide`;
- le bloc `Programmation` presente recurrence / dates libres, dates, jours, periode et horaires;
- le bloc `Sessions à créer` regroupe le choix global `Jeu`, le choix global `Version`, le compteur de sessions, l'apercu des occurrences et la confirmation;
- `Blind Test`, `Bingo Musical` et `Cotton Quiz` sont proposes sous forme de boutons/pills segmentes, sans descriptions marketing ni carte de decouverte produit;
- la version `Numérique` / `Classique` correspond au jeu selectionne et utilise le meme traitement compact, sans choix manuel de playlist ni thematique;
- le jeu et la version choisis s'appliquent a toutes les sessions creees; il n'y a pas de choix par session ni de multi-jeu dans cette passe;
- au submit, le brouillon session est bascule sur le jeu selectionne avant la creation batch, puis le contenu quick reste auto-genere comme avant;
- les anciennes URLs quick qui portent deja un jeu/session continuent de preselectionner ce jeu;
- les parcours `Ajouter une soirée`, gamification `Créer un événement`, library/thematique, first_party et pages publiques ne changent pas.

Fichiers de reference:
- choix mode agenda: `pro/web/ec/modules/tunnel/start/ec_start_agenda_mode.php`;
- header tunnel: `pro/web/ec/modules/tunnel/start/ec_start_include_header.php`;
- formulaire quick setting: `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`;
- validation et creation batch quick: `pro/web/ec/modules/tunnel/start/ec_start_script.php`.

## Etat 2026-06-25 - Programmation agenda: date/pivot d'abord

La programmation PRO depuis Home/Agenda commence maintenant par l'objet naturel `soirée / événement`: choisir une date, ouvrir le pivot de préparation, puis ajouter les sessions depuis ce pivot.

Comportement:
- les CTAs `Je programme` ouvrent `start/agenda/mode/{offre}`;
- depuis l'agenda, le bouton `Ajouter` des comptes gamification ouvre une modale légère `Créer un événement` au lieu d'une page tunnel;
- en gamification, les widgets partagés `Je programme` ouvrent aussi cette modale; le widget Home affiche `Ajoute ton prochain événement`, et le CTA bas d'agenda est libellé `PROCHAIN ÉVÉNEMENT` avec un texte centré sur la création de l'événement puis l'ajout des sessions;
- en gamification (`id_solution_usage=2`), l'ecran propose `Créer un événement`: choix d'une date, assurance du pivot événement, puis redirection vers `/extranet/start/games/day/YYYY-MM-DD`;
- en dynamisation, l'ecran propose `Ajouter une soirée` ou `Programmer plusieurs soirées`;
- l'ecran dynamisation `/start/agenda/mode/` garde seulement le titre de header, affiche un visuel sur chaque bloc d'intention et harmonise les CTA en bouton plein;
- `Ajouter une soirée` ouvre un pivot date vide sans objet événement dédié;
- le calendrier de creation des soirées/événements desactive les dates futures deja occupees par une session officielle et, en gamification, les dates qui possedent deja un pivot evenement managé;
- un POST manuel sur une date occupee revient au choix de date avec un avertissement explicite;
- si l'assurance du pivot evenement vide echoue techniquement sur une date libre, l'utilisateur est quand meme redirige vers le pivot de preparation avec un etat neutre, afin que l'ajout de la premiere session reste possible;
- `Programmer plusieurs soirées` conserve le quick multi-dates existant et va directement au paramétrage quick après choix du jeu;
- le pivot futur sans session affiche un état vide actionnable: événement/soirée créé(e), puis CTA `Ajouter une session`;
- `Ajouter une session` depuis le pivot conserve `day_date`, `day_context` et `return_url`, afin de revenir vers l'événement/la soirée courante.

Fichiers de reference:
- entree shell/CTA: `pro/web/ec/ec.php`, `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`, `pro/web/ec/modules/widget/ec_widget_ecommerce_offre_client_bloc.php`;
- choix date/mode: `pro/web/ec/modules/tunnel/start/ec_start_agenda_mode.php`;
- agenda et modale creation événement: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- routage tunnel: `pro/web/ec/modules/tunnel/start/ec_start_script.php`, `pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php`;
- helpers date/pivot: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`, `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_helpers.php`.

## Etat 2026-06-24 - Quiz quick numerique: lots `N` avec fallback thematique par serie

Le quick agenda Cotton Quiz V2 numerique applique maintenant les helpers de lots numeriques temporaires `N` quand l'ancien quick fournit un pack multi-series.

Comportement:
- `start_quiz_v2_apply_lots_to_session(...)` tente de creer les series `N` depuis `questions_numeriques certified`;
- si une serie numerique manque de contenu certifie, le quick conserve les autres `N` reussis et remplace uniquement la serie manquante par une thematique `L` deja choisie par l'ancien quick;
- l'ordre final des `lot_ids` est toujours: lots `N` reussis d'abord, puis lots thematiques `L` de fallback;
- une selection bibliotheque d'une seule thematique `L` n'est pas transformee automatiquement en pack `N`;
- le resume batch affiche un message clair quand une serie numerique n'a pas pu etre creee faute de contenu suffisant.

Fichiers de reference:
- application quick/theme: `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- message resume batch: `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php`;
- helpers `N`: `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`.

## Etat 2026-06-24 - Quiz V2: acceptation des tokens `N` dans `lot_ids`

Le tunnel PRO accepte maintenant `N{id}` comme token de lot Quiz V2 deja prepare, en complement de `L{id}` et `T{id}`.

Comportement:
- `start_quiz_v2_apply_lots_to_session(...)` normalise et conserve les tokens `N` quand ils sont fournis explicitement;
- les chiffres nus restent interpretes comme `L{id}`;
- la suppression d'un slot Quiz sait conserver une liste mixte `L/T/N`;
- le choix rapide et la generation papier automatique ne produisent toujours pas de `N` dans cette passe.

## Etat 2026-06-22 - Navigation: Ma communaute masquee en mode evenement

La navigation EC PRO ne propose plus la page `Ma communauté` aux comptes en mode evenement/gamification.

Comportement technique:
- la garde de menu utilise le booleen shell existant `$client_is_gamification_usage`, base sur `id_solution_usage=2`;
- `$show_client_community_menu` est force a `false` en gamification, tout en conservant les gardes precedentes pour les comptes dynamisation / lieux publics;
- la vue directe `/extranet/account/establishment/view/general` redirige les comptes gamification vers `/extranet/start/games` avec un flash neutre indiquant que participants, classements et bilans sont disponibles depuis chaque evenement;
- la route de modification `/extranet/account/establishment/manage` reste accessible, car elle est reutilisee par les modales de fiche depuis les pivots;
- les pages evenements, pivots, historiques, bilans, statistiques, participants et routes publiques ne changent pas.

Fichier de reference:
- shell/navigation EC: `pro/web/ec/ec.php`.

## Etat 2026-06-22 - Pivot date: aide affichage et pilotage

Le pivot `/extranet/start/games/day/YYYY-MM-DD` propose maintenant une aide discrete en modale pour expliquer comment afficher et piloter les sessions de jeu.

Comportement technique:
- les conseils Avant et Jour J affichent le meme lien `→ Comment afficher et piloter le jeu ?`;
- le lien ouvre une seule modale commune `Afficher et piloter le jeu`;
- avant le Jour J, l'etape `Test et personnalisation` integre le bouton `Préparer` dans son texte principal au lieu d'une phrase isolee;
- le Jour J, la note directe sur le pilotage mobile est remplacee par le lien d'aide, afin d'eviter une repetition hors modale;
- la modale affiche une variante desktop/tablette large pour la diffusion vers TV/videoprojecteur depuis ordinateur ou tablette paysage, avec schema `Sessions de jeu -> TV / videoprojecteur -> Joueurs`;
- la modale affiche une variante mobile pour l'animation depuis mobile sans ecran externe, avec schema `Mobile animateur -> Joueurs`;
- les variantes sont gerees en HTML/CSS local, sans image externe, asset ni detection complexe;
- les regles metier, CTA principaux de sessions, logique de lancement, QR/lien joueur et logique mobile organizer ne changent pas.

Fichier de reference:
- pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`.

## Etat 2026-06-22 - First_party: schema modes d'usage Jour J

Dans le parcours `/extranet/onboarding/first-party`, une section `Affichage aux joueurs` affiche maintenant un mini schema avant la section `Le jour J, comment ça se passe ?` quand elle est presente, ou avant `Derniers conseils` le Jour J.

Comportement technique:
- le schema est rendu uniquement en HTML/CSS dans `ec_start_first_party_onboarding.php`, sans image externe ni nouvel asset;
- une introduction adaptee desktop/tablette large ou mobile est affichee au-dessus du schema, avec note legere sur les configurations moins fiables;
- desktop/tablette large affiche le flux `Sessions de jeu -> TV / videoprojecteur -> Joueurs` sous forme horizontale avec icones renforcees, connecteurs libelles, mention Mobile organisateur et note legere sur l'ouverture directe depuis une TV connectee;
- mobile affiche le flux `Mobile organisateur -> Joueurs`, rappelle que ce mode fonctionne sans écran externe et indique qu'une diffusion externe doit passer par ordinateur ou tablette paysage;
- les astuces `Derniers conseils` / `Quelques astuces` ne repetent plus les rappels deja portes par la section `Affichage aux joueurs`;
- la section reste visible avant le Jour J et le Jour J, avec un emplacement adapte a l'ordre des sections;
- le basculement repose sur le breakpoint CSS local existant (`max-width: 991.98px`) via deux variantes HTML;
- l'etape `Avant la session` conserve son texte explicatif historique;
- aucun changement sur les CTA, regles de lancement, logique QR/lien joueur, logique mobile organizer ni conseils materiels hors perimetre.

Fichier de reference:
- first_party onboarding: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-22 - Gamification: isolation pages evenement par date

Les pivots gamification n'heriteront plus des informations publiques d'un ancien evenement lors de la creation ou de l'ajout d'une session sur une nouvelle date.

Comportement contractuel:
- un nouvel evenement pivot gamification reste propre a sa date cible, avec slug stable `cotton-event-{id_client}-{YYYYMMDD}` et valeurs par defaut tant qu'il n'est pas personnalise;
- `app_evenement_pivot_ensure_for_day(...)` ne reutilise un evenement deja rattache que si son client, son slug et ses dates correspondent strictement a la date cible;
- si une session d'une nouvelle date porte encore un ancien pivot automatique d'une autre date, elle est detachee de cet ancien pivot puis rattachee au pivot propre de la date cible;
- le bloc `Page web de l’événement` et sa modale continuent de sauvegarder uniquement l'evenement pivot courant;
- le deplacement reel d'un groupe evenement complet via `sessions_day_move` reste le seul cas ou les informations user-facing de la page evenement sont conservees en changeant de date;
- la dynamisation reste inchangee et continue de s'appuyer sur la page lieu commune.

Fichiers de reference:
- helper evenement pivot: `global/web/app/modules/operations/evenements/app_evenements_functions.php`;
- contexte/modale pivot: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_helpers.php`, `ec_start_sessions_day_event_modal.php`, `ec_start_sessions_day_event_script.php`;
- creation/reglage sessions: `pro/web/ec/modules/tunnel/start/ec_start_script.php`, `ec_start_step_1_game.php`, `ec_start_step_2_setting.php`.

## Etat 2026-06-22 - Agenda: modification date soiree/evenement

L'agenda PRO et le pivot `/extranet/start/games/day/YYYY-MM-DD` portent maintenant l'action principale de decalage d'une soiree ou d'un evenement complet.

Comportement contractuel:
- une icone discrete de modification est affichee pres de la date du groupe dans `/extranet/start/games` et dans le header du pivot;
- l'action ouvre une modale calendrier et poste vers l'endpoint prive existant `/extranet/start/script` avec `frm_mode=sessions_day_move`;
- toutes les sessions officielles de la date source sont deplacees vers la date cible, avec horaires inchanges;
- apres succes, la redirection va vers le nouveau pivot `/extranet/start/games/day/YYYY-MM-DD`;
- l'action est disponible seulement si toutes les sessions du groupe sont strictement futures, en attente, non demarrees et non terminees;
- si la date cible contient deja des sessions officielles, le deplacement est bloque pour eviter une fusion silencieuse;
- la modification individuelle de date reste disponible depuis le detail/reglage d'une session;
- lorsqu'une session appartient a un groupe multi-session, le formulaire individuel affiche un avertissement indiquant qu'elle sera deplacee vers une autre soiree/evenement;
- les rattachements evenement non pivot ne sont pas modifies; les pivots gamification automatiques de groupe complet conservent leur record `operations_evenements` et leur dossier de visuels quand le slug cible est libre, sinon le detachement/rattachement existant reste le fallback controle.

Fichiers de reference:
- action serveur: `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- helpers groupe/pivot: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- listing agenda: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- reglage session individuelle: `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`.
- helper evenement pivot: `global/web/app/modules/operations/evenements/app_evenements_functions.php`.

## Etat 2026-06-21 - Pivot date: chargements conditionnels

Le pivot `/extranet/start/games/day/YYYY-MM-DD` conserve son rendu actuel mais evite plusieurs calculs serveur quand les blocs associes ne sont pas affiches.

Diagnostic:
- le bilan Jour J appelait le contexte dashboard complet meme lorsqu'aucune session de la date n'etait terminee;
- le resume `Ton agenda public` dynamisation rechargeait detail client, visuel, branding et taux de completion avant de savoir si la section etait visible;
- les donnees detaillees de page evenement gamification et les widgets Media Kit pouvaient etre prepares alors que leurs blocs/modal n'etaient pas accessibles.

Comportement technique:
- le contexte dashboard complet du bilan est appele pour les dates passees, ou pour le Jour J seulement si au moins une session est terminee;
- le resume de page lieu dynamisation est charge uniquement quand la section `Ton agenda public` est affichee;
- le detail/branding de page evenement gamification est charge uniquement quand le bloc `Page web de l’événement` est affiche;
- la modale Media Kit n'est rendue que lorsque les conseils sont visibles;
- les modales/scripts lieu et evenement ne sont plus injectes sur les pivots ou aucun CTA visible ne peut les ouvrir;
- les regles de sessions, rattachement evenement, recommandations, CTA, first_party, reseau et offres ne changent pas.

Fichiers de reference:
- pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- helpers pivot/bilan: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`.

## Etat 2026-06-21 - Pivot Jour J: note pilotage mobile desktop (remplace le 2026-06-22)

Sur le pivot `/extranet/start/games/day/YYYY-MM-DD`, cette passe avait reserve la note de l'etape 1 des conseils Jour J aux affichages desktop. Elle est remplacee depuis le 2026-06-22 par le lien d'aide commun `Comment afficher et piloter le jeu ?`.

Comportement technique:
- l'etape `Avant le lancement` conservait son texte principal et ses autres contenus;
- la note `Pour piloter la session sur mobile, utilise le QR code dédié depuis les options de jeu.` etait rendue sur desktop uniquement;
- cette note n'est plus affichee hors modale depuis la passe `Pivot date: aide affichage et pilotage`;
- les autres conseils Jour J, les conseils avant Jour J, les cartes sessions, routes et actions de preparation ne sont pas modifies.

Fichier de reference:
- pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`.

## Etat 2026-06-20 - Home EC pro: pivot, programmation et agenda public

La Home EC PRO est recentree sur la prochaine date, la programmation et les jeux, tandis que l'acces a la page publique du lieu est deplace dans le pivot dynamisation.

Comportement contractuel:
- le widget Home `Ma communauté` n'est plus rendu depuis la Home, quel que soit le contexte compte; la page et la navigation existantes ne sont pas supprimees;
- le widget agenda Home conserve la prochaine date courante/future comme priorite et pointe vers `/extranet/start/games/day/YYYY-MM-DD?from=home`;
- si aucune date future/courante n'existe mais qu'un historique agenda utile existe, la Home affiche `Dernière soirée` ou `Dernier événement`, avec CTA `Voir le bilan` vers le pivot de cette date;
- un bilan Home n'est eligible que si au moins une session de cette date serait visible dans l'historique agenda: session archivee selon la logique agenda et utile selon `app_client_joueurs_dashboard_session_is_history_useful(...)`;
- la recherche de dernier bilan reste bornee: elle parcourt un lot limite de sessions passees candidates, de la plus recente a la plus ancienne, puis retient la premiere date qui satisfait la regle historique agenda;
- si aucun agenda futur ni historique n'existe, l'etat vide de programmation existant reste le premier widget;
- un widget programmation secondaire apparait uniquement quand un widget pivot ou dernier bilan existe deja, en deuxieme position avant `Les jeux Cotton`;
- le CTA `Je programme` reutilise la route de programmation deja employee par l'etat agenda vide;
- sur le pivot dynamisation, le bloc `Ton agenda public` s'affiche avant le Jour J et le Jour J, jamais apres date ni en gamification;
- le bloc dynamisation reutilise les styles du bloc `Page web de l’événement`, affiche le nom du lieu, adapte ses CTA selon la completion de la fiche lieu, et masque `Voir la page` quand l'URL publique n'est pas construisible;
- les donnees du bloc `Ton agenda public` passent par un resume profil lieu normalise qui recharge le detail client, reprend les descriptions normalisees, l'adresse, la photo/branding, le taux de completion de fiche et l'URL publique disponible;
- les blocs page publique sont places avant les conseils en preparation, puis apres les conseils le Jour J;
- l'etape dynamisation `Outils de communication` renvoie vers `Voir le Media Kit` et ne porte plus le CTA de personnalisation de la page lieu.
- sur le pivot date uniquement, les cartes sessions et la carte `Ajouter une session` restent en 3 colonnes entre `1400px` et `1699.98px` pour eviter des cartes trop etroites avec la sidebar; le comportement 4 colonnes reste disponible au-dela.
- l'etape 1 du tunnel de programmation officielle affiche une astuce sous les cartes de choix du jeu pour expliquer le cas multi-jeux: choisir d'abord un premier jeu, puis ajouter d'autres sessions sur la même date depuis le pivot de preparation;
- cette astuce adapte le vocabulaire au contexte compte: `soirée` en dynamisation, `événement` en gamification;
- les cartes de jeu de cette étape gardent leur action existante mais leur CTA devient `Choisir ce jeu`;
- la carte `Ajouter une session` du pivot date conserve son CTA et sa route, avec un texte d'aide indiquant qu'une autre session complète la soirée/l'événement avec un autre jeu ou un autre thème.

Fichiers de reference:
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- widget agenda Home: `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`;
- helper agenda/pivot: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- choix du jeu: `pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php`;
- pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`.

## Etat 2026-06-19 - Pivot evenement: organisateur public personnalisable

La modale événement du pivot gamification permet de surcharger le nom public de l'organisateur pour les cas marque blanche.

Comportement technique:
- champ optionnel `Organisateur de l'événement` dans `ec_start_sessions_day_event_modal.php`;
- valeur postee sous `naming_nom` et sauvegardee via le helper global de mise a jour pivot;
- si le champ est vide, le nom du compte reste le fallback public;
- aucun changement sur les cartes sessions du PRO ni sur l'agenda dynamisation.

Fichiers de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php`;
- `global/web/app/modules/operations/evenements/app_evenements_functions.php`.

## Etat 2026-06-19 - Home gamification: retrait widget Ma communaute

La Home EC PRO ne pousse plus la page compte/place comme destination principale pour les comptes gamification.

Comportement technique:
- le widget `Ma communauté` ne se rend plus quand `id_solution_usage = 2`;
- l'accès navigation existant vers `Ma communauté` n'est pas supprimé;
- les comptes dynamisation conservent le widget selon les conditions existantes;
- les autres widgets Home restent inchangés.

Fichier de reference:
- `pro/web/ec/modules/widget/ec_widget_client_lieu_resume.php`.

## Etat 2026-06-19 - Agenda gamification: nom evenement dans le groupe

L'agenda EC PRO affiche le nom de l'evenement dans le header du groupe de date quand ce nom a ete renseigne.

Comportement technique:
- la liste agenda remonte `id_operation_evenement` avec les sessions;
- en contexte gamification (`id_solution_usage = 2`), le header compact garde la date en premiere ligne et affiche `Nom evenement · X sessions · plage horaire` en seconde ligne si un evenement unique est rattache au groupe;
- les noms generes par defaut `Événement Cotton du JJ/MM/AAAA` et `Événement du ...` sont masques pour eviter un placeholder lourd;
- le nom long est ellipse dans la ligne meta;
- le CTA `Préparer l'événement` et les cartes sessions ne changent pas;
- l'agenda dynamisation conserve le rendu precedent.

Fichier de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`.

## Etat 2026-06-19 - Upload visuel événement: formats acceptes

Les écrans PRO qui uploadent le visuel événement sont alignés sur les uploads image récents du repo.

Comportement technique:
- la modale événement du pivot `/extranet/start/games/day/YYYY-MM-DD`, le formulaire historique événement et le widget résumé événement acceptent maintenant `JPG`, `PNG` et `WebP`;
- l'aide utilisateur indique le format final `1200 × 480 px`;
- la preview de la modale pivot conserve le ratio `5 / 2`;
- le traitement global continue de produire les fichiers publics historiques en `.jpg`, donc les URLs existantes ne changent pas;
- les uploads fiche lieu / compte ne sont pas modifiés dans cette passe.

Fichiers de reference:
- modale pivot: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php`;
- formulaire evenement: `pro/web/ec/modules/operations/evenements/ec_evenements_form.php`;
- widget resume: `pro/web/ec/modules/widget/ec_widget_operation_evenement_resume_upload.php`;
- helper branding: `global/web/app/modules/operations/evenements_branding/app_evenements_branding_functions.php`.

## Etat 2026-06-19 - Pivot gamification: bloc page web événement

Le pivot gamification `/extranet/start/games/day/YYYY-MM-DD` affiche maintenant un bloc dedie a la page web de l'evenement sous les cartes sessions.

Comportement technique:
- la section des cartes sessions affiche un titre visible `Session de jeu` / `Sessions de jeu`, avec l'icone `bi-controller` deja utilisee dans le repo;
- le bloc s'affiche uniquement en contexte gamification/evenement, avant Jour J et le Jour J;
- il reutilise l'evenement pivot existant et la route modale existante de personnalisation;
- le titre de section `🌐 Page web de l’événement` et son aide utilisent le style commun des sections du pivot;
- quand la page evenement est suffisamment renseignee, il affiche le visuel a gauche et les informations a droite;
- les informations sont ordonnees ainsi: titre de l'evenement, accroche courte, description longue si renseignee, lieu/adresse, lien externe utilisateur si renseigne;
- la description longue est bornee visuellement dans le bloc avec ellipsis pour que la colonne de contenu desktop ne depasse pas la hauteur du visuel;
- les actions `Voir la page` et `Modifier` sont alignees en bas de la colonne d'informations;
- quand la page evenement contient surtout des valeurs par defaut ou trop peu de signaux utiles, le pivot garde la meme structure d'aperçu avec visuel a gauche, titre `Événement du ...`, texte d'incitation, CTA principal `Compléter la page` et CTA secondaire `Voir la page` si l'URL Cotton est disponible;
- dans cet etat peu renseigne, le visuel evenement est affiche s'il existe, sinon le visuel par defaut est conserve;
- la modale de modification pre-remplit aussi le nom avec `Événement du ...` quand le nom courant est vide ou encore au format genere `Événement Cotton du ...`, afin que ce titre soit sauvegarde puis transmis tel quel a la page `www`;
- apres sauvegarde de la modale, le bloc `Page web de l’événement` est rafraichi sans rechargement: visuel, titre, accroche, description, lieu/adresse et lien externe sont repris depuis la reponse JSON;
- les signaux utiles pris en compte sont: visuel personnalise, titre non genere, description, lieu/adresse, lien externe utilisateur;
- il n'affiche ni statut prive/public ni date, deja portee par le header du pivot;
- `Voir la page` ouvre l'URL Cotton `www` `/fr/evenements/{slug}` dans un nouvel onglet;
- `Modifier` ouvre la modale existante de modification de la page evenement;
- le lien externe utilisateur est normalise avant affichage: `http://` et `https://` sont conserves, sinon `https://` est prefixe;
- l'etape 2 `Outils de communication` en gamification pointe maintenant vers `Voir le Media Kit`, la modification de la page evenement etant portee par le bloc dedie;
- l'entree de menu `Mes événements` est masquee pour les comptes gamification afin de garder le pivot comme point d'entree principal, sans supprimer les routes historiques.

Fichiers de reference:
- pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- vue historique evenement: `pro/web/ec/modules/operations/evenements/ec_evenements_view.php`;
- navigation EC: `pro/web/ec/ec.php`.

## Etat 2026-06-19 - First_party: contexte événement et visuels post-modale

Le tunnel `first_party` stabilise le rendu de la section `Les participants` juste apres creation des sessions et apres personnalisation des pages publiques.

Comportement technique:
- apres creation des sessions guidees, la premiere date future et les compteurs derives sont recalcules dans le meme cycle de requete;
- le bloc gamification affiche donc immediatement `Page de ton événement` au lieu de retomber provisoirement sur `Agenda public`;
- la sauvegarde de la page evenement renvoie maintenant l'URL du visuel evenement exploitable;
- la sauvegarde de la fiche lieu en modale `first_party` renvoie maintenant l'URL du visuel lieu exploitable;
- l'image du bloc participants est mise a jour cote client apres succes AJAX, sans attendre un rechargement;
- le comportement couvre `Page de ton événement` en gamification et `Agenda public` en dynamisation.

Fichiers de reference:
- tunnel first_party: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- script page evenement: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php`;
- script fiche lieu: `pro/web/ec/modules/compte/client/ec_client_script.php`.

## Etat 2026-06-19 - Step 2 programmation: garde first_party et creation agenda quick

Le formulaire `step_2_setting` doit rester affichable pour les comptes actifs `ABN` / `PAK`, y compris quand l'acces vient d'une offre effective active et quand la session est creee depuis le mode agenda quick.

Comportement technique:
- le rendu `step_2_setting` reutilise le contexte d'offre effective deja calcule par le shell EC pour le client courant, afin d'eviter un recalcul fragile pendant l'affichage du formulaire;
- les comptes actifs `ABN` / `PAK` avec offre, abonnement ou pack actif n'ont pas de borne date `first_party` appliquee par le datepicker;
- les comptes sans offre effective active qui doivent passer par l'activation d'offre (`INS` eligibles et `CSO` de reactivation) conservent le blocage hors pivot quand une premiere date officielle future existe;
- le mode agenda quick verifie maintenant par `app_session_get_id(...)` que la session creee est relisible avant de rediriger vers `/extranet/start/game/setting/{token}`;
- si la creation avec offre active produit un token non relisible, l'echec est journalise mais aucune session officielle n'est creee sans rattachement d'offre;
- `session_init` applique la meme verification pour le chemin bibliotheque et vide le token si la session n'est pas relisible, afin de ne pas fabriquer une URL `setting/{token}` invalide;
- `step_2_setting` verifie aussi que le detail session est exploitable, appartient au client courant et porte un type de jeu valide avant de rendre le formulaire;
- les echecs de creation/relecture sont journalises cote PHP avec client, contact, offre, type produit, insert id et erreur mysqli;
- le header du tunnel ne lit plus le detail session sur les etapes sans session chargee, ce qui evite les notices parasites dans les logs;
- si un ancien lien `setting` porte un token invalide, la page affiche une relance de programmation au lieu d'un shell vide.

Fichiers de reference:
- helpers first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- choix date front et fallback token invalide: `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`;
- creation agenda quick et validation serveur: `pro/web/ec/modules/tunnel/start/ec_start_script.php`.
- header tunnel: `pro/web/ec/modules/tunnel/start/ec_start_include_header.php`.

## Etat 2026-06-19 - First_party: garde date limitee aux comptes sans offre active

La date de premiere soiree / premier evenement `first_party` reste une information de parcours accompagne, mais n'est plus une borne de programmation pour les comptes avec acces effectif actif.

Comportement technique:
- le rendu `step_2_setting` reutilise le contexte d'offre effective deja calcule par le shell EC pour le client courant, afin d'eviter un recalcul fragile pendant l'affichage du formulaire;
- les comptes sans offre effective active qui doivent passer par l'activation d'offre (`INS` eligibles et `CSO` de reactivation) conservent le blocage hors pivot quand une premiere date officielle future existe;
- pour ces comptes sans acces actif, une nouvelle programmation officielle a une date inferieure ou egale a la premiere date future reste refusee cote serveur;
- le datepicker continue d'appliquer la date minimale uniquement lorsque cette garde sans acces actif s'applique explicitement;
- les comptes actifs `ABN` / `PAK` avec offre, abonnement ou pack actif peuvent programmer librement avant la date `first_party`, avancer une session existante et ajouter d'autres sessions avant cette date;
- la detection d'acces actif reste centralisee via `app_ecommerce_offre_effective_get_context(...)` dans le helper `ec_first_party_has_active_offer(...)`;
- le pivot `/extranet/onboarding/first-party`, les widgets Home/Agenda, les demos, les offres, le paiement et les CTA hors garde de programmation ne sont pas modifies.

Fichiers de reference:
- helpers first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- choix date front: `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`;
- validation serveur: `pro/web/ec/modules/tunnel/start/ec_start_script.php`.

## Etat 2026-06-18 - Pivot date: déplacement/suppression sessions liées

Le pivot `/extranet/start/games/day/YYYY-MM-DD` garde une navigation cohérente quand une session liée est modifiée ou supprimée depuis sa fiche détail.

Comportement technique:
- les vrais événements/opérations continuent de borner le calendrier de modification de session sur `operations_evenements.date_debut/date_fin`;
- les événements pivot automatiques gamification (`cotton-event-{id_client}-{YYYYMMDD}`) ne bornent plus le datepicker à leur jour unique;
- le formulaire tolère les slugs pivot suffixés par l'unicité historique et retire une borne `maxDate` mono-date héritée lorsqu'elle correspond au jour du pivot;
- quand une session attachée à un pivot automatique change de date, le script de sauvegarde demande au helper global de la détacher de l'ancien pivot et de l'assurer/rattacher au pivot de la nouvelle date;
- le mode multi-dates issu du paramétrage applique la même réaffectation aux occurrences créées ou déplacées;
- quand une session est supprimée depuis sa fiche détail avec un `return_url` vers une page pivot, le script compte les sessions officielles restantes à cette date;
- si la session supprimée était la dernière de cette date, la redirection revient directement vers `/extranet/start/games` au lieu de renvoyer vers une page pivot vide;
- les règles de suppression jeu, offres PAK, pipeline et logs restent inchangées.

Fichiers de reference:
- formulaire de paramétrage: `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`;
- script de sauvegarde/suppression: `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- helper événement: `global/web/app/modules/operations/evenements/app_evenements_functions.php`.

## Etat 2026-06-18 - Pivot date: communication avant Jour J

Le pivot `/extranet/start/games/day/YYYY-MM-DD` simplifie les recommandations avant Jour J pour les contextes dynamisation et gamification.

Comportement technique:
- les cartes avant Jour J passent de trois etapes a deux etapes: `Test et personnalisation`, puis `Outils de communication`;
- l'ancienne etape separee `Page de ton lieu` / `Page de ton événement` n'est plus ajoutee entre les deux;
- en dynamisation, l'etape 2 indique que la ou les sessions sont publiees sur la page du lieu;
- le lien `la page de ton lieu` pointe vers la page place `www` quand le slug public est disponible;
- le lien `Media Kit` ouvre la modale Media Kit existante du pivot;
- le CTA `Personnaliser la page de mon lieu` ouvre la modale de modification de fiche lieu existante;
- en gamification, l'etape 2 indique que la ou les sessions sont affichees sur la page de l'evenement;
- le lien `la page de ton événement` pointe vers la page evenement `www` quand le slug public est disponible;
- le Jour J gamification affiche aussi le lien `Voir la page web de l’événement` sous le sous-titre, avec le style du lien de retour header, en assurant/rattachant le pivot événement du jour puis en lisant si besoin l'événement déjà attaché aux sessions;
- le CTA `Personnaliser la page de l’événement` ouvre la modale evenement existante du pivot;
- le bilan et les cartes sessions ne changent pas.

Fichier de reference:
- pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`.

## Etat 2026-06-18 - Pivot gamification: modale page evenement

Le pivot `/extranet/start/games/day/YYYY-MM-DD` permet maintenant aux comptes gamification de preparer la page de leur evenement avant le jour J.

Comportement technique:
- en mode `upcoming` gamification, l'etape 2 des recommandations devient `Page de ton événement` quand un evenement pivot unique est disponible;
- le CTA `Personnaliser la page` ouvre une modale dediee, sans navigation pleine page;
- la modale expose seulement les champs V1 utiles: visuel evenement, nom, accroche courte, description, lieu, adresse, lien externe et libelle du lien;
- la date est affichee en lecture seule et les champs legacy sensibles restent exclus: public/prive, `online`, dates, horaires, SEO slug, code evenement, suppression, equipe, rubrique, offre/jauge et programmation;
- la sauvegarde passe par un endpoint JSON dedie au pivot, valide le client courant, le contexte gamification, la date future, l'evenement et son proprietaire;
- le helper global `app_evenement_pivot_update_infos(...)` ne met a jour que les champs autorises et n'appelle pas `app_evenement_modifier()`;
- le visuel reutilise les conventions historiques `operations/evenements_branding/{seo_slug}` via l'uploader evenement branding, sans propagation aux sessions.

Fichiers de reference:
- pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- helper/modale/script pivot evenement: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_event_*.php`;
- routes: `pro/web/.htaccess`;
- helpers evenement: `global/web/app/modules/operations/evenements/app_evenements_functions.php`.

## Etat 2026-06-18 - Pivot gamification: evenement par date

Le pivot `/extranet/start/games/day/YYYY-MM-DD` assure maintenant un evenement interne pour les dates futures des comptes gamification.

Comportement technique:
- le pivot standard continue de charger uniquement les sessions officielles non demo, completes, du client courant et de la date demandee;
- le chargement inclut `id_operation_evenement` pour connaitre les rattachements existants;
- l'assurance ne s'execute que pour les comptes gamification (`id_solution_usage=2`) en mode `upcoming`, hors reseau, hors `first_party` et hors dynamisation;
- le helper global `app_evenement_pivot_ensure_for_day(...)` reutilise un evenement deja rattache si toutes les sessions pointent vers le meme ID;
- si aucune session n'est rattachee, il recherche ou cree un evenement pivot par slug stable `cotton-event-{id_client}-{YYYYMMDD}`;
- l'evenement cree reste prive et non publie (`flag_evenement_prive=1`, `online=0`) et conserve les conventions historiques `id_securite` / `code_operation_evenement`;
- le rattachement n'ecrase jamais un `id_operation_evenement` existant et n'appelle pas `app_evenement_modifier()`;
- aucune modale, aucun upload visuel et aucun changement UI ne sont introduits dans cette passe.

Fichiers de reference:
- pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- helper evenement: `global/web/app/modules/operations/evenements/app_evenements_functions.php`.

## Etat 2026-06-18 - EC Agenda courant borne par dates

Les agendas a venir gardent le rendu regroupe par date, mais ne chargent plus tout le futur au premier affichage.

Comportement technique:
- la route `extranet/start/games?network_agenda=1` reutilise toujours le listing Agenda general;
- en mode agenda standard courant, la page charge d'abord 10 dates distinctes a venir du compte, plus une date supplementaire pour detecter `Voir plus`;
- le lien `Voir plus` standard augmente `days_limit` de 10 dates et conserve les parametres existants;
- en mode reseau courant, la page charge d'abord 10 dates distinctes a venir du reseau, plus une date supplementaire pour detecter `Voir plus`;
- seules les sessions des dates affichees sont ensuite chargees et rendues;
- le lien `Voir plus` reseau augmente `network_days_limit` de 10 dates et conserve les parametres existants;
- les groupes de dates ne sont pas coupes au milieu;
- les filtres existants par type de jeu et date restent appliques en SQL;
- le lien archives reseau n'est plus determine par un scan complet des sessions passees: il utilise des tests courts `LIMIT 1` equivalents aux preuves d'archive utile de l'agenda standard;
- la Home, les routes, droits, CTA et libelles restent inchanges.

Fichier de reference:
- listing Agenda general/reseau: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`.

## Etat 2026-06-18 - EC historiques sessions/offres bornes

Les historiques lourds de l'EC chargent progressivement les entrees affichees sans refondre les pages ni changer les regles metier.

Comportement technique:
- `/extranet/start/games/archives` charge 20 sessions archivees utiles au premier affichage, puis +20 par clic `Voir plus`;
- la vue archives applique des limites SQL par batch, demande une entree utile supplementaire pour savoir si `Voir plus` doit etre affiche, puis rend uniquement la limite courante;
- les filtres date/type de jeu existants sont aussi pousses dans le SQL quand ils sont presents;
- `/extranet/account/offers` conserve les offres/abonnements actifs et les CTA principaux separement de l'historique;
- l'historique des commandes/offres terminees charge 10 entrees au premier affichage, puis +10 par clic `Voir plus`;
- l'historique reseau ne construit plus tout l'historique detaille avant decoupe visible et remplace l'ancienne pagination `Precedent/Suivant` par `Voir plus`;
- les plafonds techniques ne pilotent pas l'UX: ils normalisent seulement les acces directs abusifs, tandis que les liens generes progressent jusqu'a epuisement reel des donnees;
- les routes, droits, filtres client, details d'offre, facturation et regles d'archivage restent inchanges.

Fichiers de reference:
- archives agenda: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- offres compte: `pro/web/ec/modules/compte/offres/ec_offres_view.php`;
- offres actives conservees: `pro/web/ec/modules/compte/offres/ec_offres_include_list.php`.

## Etat 2026-06-18 - Ma communaute: wording fiche contextualise

Les vues EC de fiche/portail compte `/extranet/account/establishment/view/general` et `/extranet/account/establishment/manage` contextualisent maintenant leurs microcopies selon l'usage et la typologie du compte.

Comportement technique:
- `id_solution_usage=2` distingue la gamification du contexte dynamisation;
- le helper local `ec_client_profile_wording.php` centralise les textes de fiche compte;
- les comptes dynamisation conservent le vocabulaire `lieu`;
- les comptes gamification n'affichent plus le vocabulaire `lieu` sur les champs de nom, accroche, description, visuel et lien de fiche;
- les variantes gamification distinguent entreprise (`id_typologie=3`), particulier (`id_typologie=12`) et organisation/generique;
- les textes gamification presentent la fiche comme un portail de compte partageable, pas comme un evenement precis;
- le lien de fiche gamification garde la meme URL mais affiche `Voir ma page privée sur le site`.
- le widget Home `Ma communaute`, la vue fiche et le formulaire gardent le visuel custom du compte quand il existe;
- si le compte n'a que le fallback `branding-client-default`, ces surfaces utilisent les assets locaux `ec/images/compte/client/branding-client-default.jpg` pour la dynamisation, `branding-client-default-gm.jpg` pour la gamification generique/organisation/entreprise et `branding-client-default-pt.jpg` pour les particuliers;
- le widget Home affiche aussi le bandeau `Exemple d'illustration.` sur ces visuels fallback, comme la vue fiche et le formulaire;
- cette adaptation ne rajoute pas de requete Home: le widget reutilise uniquement l'URL deja renvoyee par `app_client_get_photo_src()` pour detecter l'ancien fallback.

Fichiers de reference:
- helper wording: `pro/web/ec/modules/compte/client/ec_client_profile_wording.php`;
- formulaire: `pro/web/ec/modules/compte/client/ec_client_form.php`;
- vue fiche: `pro/web/ec/modules/compte/client/ec_client_view.php`;
- widget Home: `pro/web/ec/modules/widget/ec_widget_client_lieu_resume.php`;
- logique signup auditee: `pro/web/ec/ec_signup.php`.

## Etat 2026-06-18 - First party: wording fiche privee

Dans le tunnel `first_party`, l'astuce de fiche post-programmation adapte son wording selon que la page lieu est publique ou privee.

Comportement technique:
- les lieux publies conservent `fiche lieu` et `pages publiques du site`;
- les comptes non publies/gamification utilisent `fiche` et `ta page privee du site`;
- l'astuce reste visible pour les pages privees en contexte evenement/gamification;
- la mise a jour apres sauvegarde de la fiche en modale reprend le meme wording.

Fichier de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-18 - Ma communaute: fiche lieu et page privee

Le widget Home `Ma communaute` et le bloc 1 fiche lieu de la page `Ma communaute` partagent une regle d'affichage commune.

Comportement technique:
- `show_client_community_profile` n'a plus de restriction specifique aux comptes gamification;
- `show_client_place_profile_card` pilote a la fois le widget Home `Ma communaute` et le bloc fiche lieu;
- `client_has_published_public_place_page` distingue les pages lieu publiees sur `www` des pages privees accessibles par URL directe;
- si la page lieu n'est pas publiee sur `www`, le widget parle de `page privee` et le lien du bloc fiche lieu affiche `Voir ma page privee sur le site`;
- les stats/classements de `Ma communaute` restent conditionnes par les signaux joueurs existants.

Fichiers de reference:
- flags communs: `pro/web/ec/ec.php`;
- widget Home: `pro/web/ec/modules/widget/ec_widget_client_lieu_resume.php`;
- page `Ma communaute`: `pro/web/ec/modules/compte/client/ec_client_view.php`.

## Etat 2026-06-18 - Home: differé de rendu optimisé

La navigation vers la Home EC reste une navigation pleine page vers `/extranet/dashboard`. Le skeleton plein ecran au clic sortant dans `web/ec/ec.php` est annule et aucun nouveau skeleton/shell Home n'est retenu avant mesure precise.

Comportement technique:
- `web/ec/ec.php` ne porte pas de skeleton de navigation vers `/extranet/dashboard`;
- `web/ec/modules/communication/home/ec_home_index.php` ne porte pas de shell/skeleton Home ajoute;
- les widgets Home finaux restent rendus cote serveur dans le meme document;
- l'instrumentation temporaire de mesure serveur/navigateur a ete retiree apres validation;
- sur la Home uniquement, les scripts footer sont charges avec `defer` pour ne plus bloquer le parsing/paint du document;
- sur la Home uniquement, les vendors etendus non requis au premier rendu ne sont plus charges: jQuery UI, Swiper, Flatpickr et Sortable, cote CSS et JS;
- les images de cartes Home non critiques (`Nouveautés`, `Les jeux Cotton`, `Ma communaute`, agenda) sont chargees en lazy/low priority;
- Google Fonts/Poppins est preconnecte et charge explicitement dans le `<head>` pour eviter sa decouverte tardive via `@import`;
- la Home finale, ses widgets, CTA, wordings et contextes `first_party` / TdR / reseau / `INS` / `CSO` / `ABN` / `PAK` restent inchanges.

Fichiers de reference:
- layout EC: `pro/web/ec/ec.php`;
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`.

## Etat 2026-06-18 - Home sans prochaine date: fallback programmation borne

La Home EC garde ses widgets et fallbacks existants. Apres regression globale, seul le correctif local du feedback recent est conserve; la tentative de bornage du signal global de session officielle visible a ete rollbackee.

Comportement technique:
- le helper `ec_home_next_sessions_day_summary_get()` reste le chemin standard pour la prochaine date et sort vide apres une requete bornee quand aucune date n'existe;
- `ec_feedback_recent_finished_session_get()` ne charge plus toutes les archives: il inspecte au plus 10 sessions officielles completes des 14 derniers jours;
- les controles existants d'archive utile et d'existence de feedback sont conserves sur ces candidates seulement;
- `app_client_has_visible_official_session_signal(...)` reste sur son implementation precedente pour restaurer la performance globale de l'extranet;
- aucun wording, CTA, ordre de widgets ou contexte `first_party` / `INS` / `CSO` / `ABN` / `PAK` / TdR / reseau n'est modifie.

Fichiers de reference:
- feedback Home recent: `pro/web/ec/modules/general/feedback/ec_feedback_lib.php`;
- point d'entree Home: `pro/web/ec/ec.php`;
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`.

## Etat 2026-06-18 - Home agenda sessions bornees

Le widget Home `Prochaine soiree` / `Prochain evenement` conserve ses regles contextuelles, mais son chemin donnees est maintenant borne a la prochaine date utile.

Comportement technique:
- `ec_widget_client_lieu_sessions_agenda.php` utilise `ec_home_next_sessions_day_summary_get()` pour le resume Home standard;
- le helper cherche d'abord une seule prochaine date officielle courante/future du client (`LIMIT 1`), puis charge uniquement les sessions de cette date;
- le chemin Home standard ne charge pas les archives et ne parcourt plus les dates historiques ou les listes Agenda/Pivot completes;
- les etats runtime sont calcules uniquement pour les sessions de la date affichee quand cette date est aujourd'hui;
- les fallbacks `first_party` / programmation restent executes seulement quand aucune session utile n'est trouvee;
- le widget garde les CTA courts: `Préparer`, `Ouvrir`, `Reprendre`, `Voir le bilan`.

Fichiers de reference:
- widget Home agenda lieu: `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`;
- helper Home sessions bornees: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`.

## Etat 2026-06-17 - Home render initial stable

Statut 2026-06-18: obsolete / annule. Le shell/squelette Home introduit par ce bloc a ete retire par la passe du 18/06; l'etat final restaure une Home sans shell/skeleton ajoute et traite le differe de rendu par mesure puis optimisation des ressources bloquantes.

Historique du bloc annule: la Home EC conservait son rendu serveur final, mais affichait une structure stable des l'entree du module pour eviter l'ecran vide pendant les calculs des widgets.

Comportement technique:
- `ec_home_index.php` emet un en-tete Home et un squelette visuel avant les calculs `first_party`, feedback, affiliation reseau, Stripe, nouveautes et donnees TdR;
- ce squelette reserve une hauteur desktop/mobile proche de la grille finale et ne porte aucun texte metier ni CTA;
- quand les vrais widgets commencent a etre rendus, le squelette est masque et l'en-tete historique n'est pas duplique;
- le JS Home d'egalisation de largeurs reste inchange et continue de s'executer apres `DOMContentLoaded`, `load` et fonts ready.

Fichier de reference:
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`.

## Etat 2026-06-17 - Home/Agenda sessions groupees: deuxieme passe performance

Le rendu Home/Agenda conserve les memes wordings et CTA, mais evite plusieurs chemins couteux qui restaient actifs apres la premiere optimisation.

Comportement technique:
- le widget Home agenda ne calcule les modales/guards `first_party` que lorsque le widget n'a aucune session a afficher et que le CTA de programmation peut etre utilise;
- les listes Home, Agenda et pivot date incluent `lot_ids` et `nb_joueurs_max` pour permettre aux resumes de session de rester sur les donnees deja chargees;
- `ec_start_day_game_detail_get()` mutualise `app_jeu_get_detail()` pendant un meme rendu PHP;
- `ec_start_agenda_session_summary_get()` ne calcule plus l'etat runtime pour une date strictement future;
- `ec_start_agenda_session_can_delete()` valide directement une session future du client deja presente dans la liste, sans recharger detail session + detail jeu;
- l'Agenda courant hors reseau n'a plus besoin de charger toutes les archives passees pour afficher le lien archives: il utilise des tests SQL courts par source de preuve d'historique utile;
- l'Agenda reseau conserve le fallback historique.

Fichiers de reference:
- widget Home agenda lieu: `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`;
- listing Agenda general: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- helpers sessions par date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- page pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`.

## Etat 2026-06-17 - Home/Agenda sessions groupees: performance

Les vues Home et Agenda conservent les regles UX de regroupement par date, mais evitent les chargements et compteurs repetes introduits par les resumes de soiree/evenement.

Comportement technique:
- la Home agenda lieu ne charge plus toutes les sessions officielles futures pour construire la prochaine carte;
- elle recupere d'abord la prochaine date officielle courante/future du client, puis charge uniquement les sessions de cette date;
- le widget Home garde les etats existants: `Préparer`, `Ouvrir` / libelle contexte, `Reprendre`, `Voir le bilan` selon futur/Jour J/session en cours/toutes sessions terminees;
- le helper partage `ec_start_day_session_detail_get()` mutualise les appels `app_session_get_detail()` pendant un meme rendu PHP;
- le listing Agenda precharge les compteurs de participations probables avec une seule requete `GROUP BY` sur les sessions affichees;
- `ec_start_agenda_session_summary_get()` accepte ces compteurs precharges et garde son fallback historique si elle est appelee hors Agenda;
- les pages pivot reutilisent le detail session deja resolu pour leurs cartes, sans cache persistant.

Fichiers de reference:
- widget Home agenda lieu: `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`;
- listing Agenda general: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- helper sessions par date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- page pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- cartes sessions partagees: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`.

## Etat 2026-06-17 - Agenda programmation: wordings soirees/evenements

Les entrees de programmation distinguent maintenant la programmation generale d'une ou plusieurs sessions et l'ajout depuis une page pivot de date.

Comportement contractuel:
- hors page pivot, le widget partage `Nouvelle session` parle de prochaines soirees ou prochains evenements selon le contexte client;
- en dynamisation / lieu public, le titre de carte devient `TES PROCHAINES SOIRÉES` et le texte indique que les sessions programmees seront regroupees par soiree dans l'agenda;
- en gamification / evenement, le titre de carte devient `TES PROCHAINS ÉVÉNEMENTS` et le texte indique que les sessions programmees seront regroupees par evenement dans l'agenda;
- le CTA de programmation generale reste `Je programme`;
- dans le listing agenda general, le header reprend la meme largeur que les blocs de soiree/evenement sur desktop large;
- le lien `QR code permanent` est aligne sur la limite droite de ces blocs;
- dans la vue archives, le CTA de retour `Mon agenda` / `Agenda du réseau` est place a cote du titre `Archives`;
- dans le listing agenda a venir hors reseau, les sessions supprimables affichent une croix rouge legere en fin de ligne;
- cette suppression demande confirmation en modale, reutilise le flux `session_delete` existant et revient vers l'agenda courant;
- un bloc de soiree/evenement dont la derniere session est supprimee n'est plus rendu apres le retour sur le listing;
- les lignes compactes des blocs soiree/evenement affichent les inscrits d'une session archivee ou `Participations : X` pour les participations probables a droite de l'horaire de session quand cette donnee existe;
- dans le footer des blocs agenda a venir, le CTA secondaire `Ajouter 1 session` est affiche a cote du CTA principal;
- ce CTA secondaire reprend le flux d'ajout date de la page pivot, avec `day_date`, `day_context` et retour vers le pivot;
- son rendu inverse le CTA principal: fond transparent par defaut, couleur pleine au survol;
- dans le listing agenda general, cette carte de programmation reprend la largeur des blocs de soiree/evenement regroupes par date;
- dans cette variante agenda, le titre reste en haut, puis le texte est affiche a gauche et l'icone `+` a droite sur desktop/tablette, avec empilement mobile;
- les autres inclusions du widget de programmation partage gardent leur largeur de carte historique;
- les agendas vides Home dynamisation affichent `Ton agenda est vide` puis `Programme dès maintenant tes prochaines soirées Cotton ! Choisis tes dates puis ajoute tes parties de jeu.`;
- les agendas vides Home gamification affichent `Ton agenda est vide` puis `Programme dès maintenant ton prochain événement ! Choisis une date puis ajoute une ou plusieurs parties de jeu.`;
- depuis la page pivot `/extranet/start/games/day/YYYY-MM-DD`, la carte locale d'ajout affiche `AJOUTER UNE SESSION`, puis `Complète cette soirée avec une session de jeu supplémentaire.` ou `Complète cet événement avec une session de jeu supplémentaire.`;
- le CTA pivot devient `Ajouter à cette soirée` ou `Ajouter à cet événement`;
- l'ajout depuis pivot conserve la date imposee via `day_date`, le contexte via `day_context` et le retour via `return_url`;
- dans la bibliotheque agenda, le bandeau `Choisis une nouvelle session pour ta soiree/ton evenement` est affiche uniquement quand `day_date` est valide, donc seulement pour un ajout depuis une page pivot deja datee;
- en programmation agenda classique sans date verrouillee, aucun bandeau de contexte agenda n'est affiche dans la bibliotheque, le stepper du tunnel restant le contexte de programmation;
- la bibliotheque et le tunnel de programmation continuent de manipuler des sessions de jeu et de propager le contexte agenda existant;
- l'ancienne fiche `operations/events` conserve le comportement de programmation existant et n'est pas requalifiee en ajout rattache;
- les confirmations `resume` et `resume_batch` n'affichent plus la carte de programmation generale apres creation; elles conservent les bandeaux de date et les liens vers le pivot de la date;
- les CTA metier des cartes sessions restent inchanges: `Préparer`, `Ouvrir le jeu`, `Reprendre`, `Voir les résultats`.

Fichiers de reference:
- widget programmation partage: `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`;
- widget Home agenda lieu: `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`;
- widget Home agenda evenement: `pro/web/ec/modules/widget/ec_widget_operation_evenement_agenda.php`;
- page pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- confirmations tunnel: `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume.php`, `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php`;
- listing Agenda general: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- bibliotheque agenda: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`, `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`, `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`;
- tunnel programmation: `pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php`, `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`, `pro/web/ec/modules/tunnel/start/ec_start_script.php`.

## Etat 2026-06-16 - Agenda day: header compact, accompagnement en étapes et bilan allégé

La page pivot `/extranet/start/games/day/YYYY-MM-DD` conserve les cartes sessions comme zone d'action principale et remplace le bloc passif `Recommandations et astuces` par une section légère d'étapes contextualisées.

Comportement contractuel:
- le header de page n'utilise plus un grand hero violet degrade: il devient un bloc compact dans le flux, proche des cartes de date de l'agenda;
- le titre du header reprend la logique agenda avec `AUJOURD'HUI — ...`, `DEMAIN — ...` ou la date uppercase sinon;
- les pills `x sessions` et plage horaire restent affichees dans le header;
- le header affiche un sous-titre contextuel pour avant/Jour J/apres, adapte au contexte dynamisation/gamification et au nombre de sessions;
- les cartes sessions remontent visuellement plus pres du haut de page;
- quand la date est passee ou quand le bilan est la section principale, le sous-titre et l'accompagnement ne sont plus affiches;
- quand le bilan est affiche en premier, les cartes sessions restent en dessous sous le titre `Sessions jouées`;
- le bloc `Bilan` reste une synthese globale mais son rendu est plus compact: statistiques en chips, podium partage rendu en format reduit par CSS local, Top 10 plus dense et bareme raccourci;
- quand le podium du bilan contient des photos, la page conserve une hauteur d'image suffisante pour que les gagnants restent visibles malgre le rendu compact;
- les microcopies de bilan respectent le singulier/pluriel: `Session jouée`, `le résultat de la session jouée`, `les résultats des sessions jouées`;
- les cartes d'etapes sont visuelles et legeres sur le fond violet: fond translucide renforce, bordure claire visible, numero centre en haut, titre puis picto lumineux centre, texte blanc/quasi blanc, pas de fond gris plein;
- les variantes a 2 étapes occupent toute la largeur disponible en deux colonnes sur desktop/tablette, avec empilement seulement sur mobile etroit;
- les titres de section d'etapes restent courts (`À faire avant le jour J`, `À faire avant l'événement`) pour laisser le contexte au sous-titre du header;
- les contextes dynamisation / lieu public affichent avant le jour J trois étapes: preparation de la ou des sessions, verification de la page lieu si pertinente, puis annonce de la soiree via le Media Kit inline et les liens publics de session;
- les contextes gamification / evenement affichent avant le jour J deux étapes: preparation de la ou des sessions et information des participants via le Media Kit inline;
- les textes d'etapes et microcopies de liens respectent le singulier/pluriel (`ma session`, `ta session`, `le lien de ta session`, `tes sessions`, `tes liens de sessions`);
- l'etape de preparation n'affiche plus de liens horaires et indique d'utiliser le bouton `Préparer` de la ou des cartes session;
- les liens horaires d'annonce ouvrent les pages publiques www des sessions en nouvel onglet;
- le jour J, les deux contextes affichent trois étapes sans CTA: ouvrir le jeu depuis la carte session, accueillir les joueurs/participants, puis revenir au pivot pour suivre le bilan ou la session suivante;
- l'information de pilotage animateur mobile par QR code dedie est integree a l'etape `Ouvrir le jeu`; aucune note separee n'est affichee sous les étapes Jour J;
- les actions transverses sont des liens integres dans le texte et reutilisent les modales existantes Media Kit et fiche lieu, sans lien mort ni duplication de logique;
- depuis les archives agenda, le CTA `Voir le bilan` ouvre le pivot avec `from=archives`; le lien retour du pivot devient `Retour aux archives`;
- les fiches sessions passees ouvertes depuis ce pivot gardent un retour contextualise vers la page pivot (`Ma soiree`, `Mon evenement` ou `Mon animation`) au lieu du retour generique `Archives`;
- les cartes sessions et leurs CTA `Préparer`, `Ouvrir le jeu`, `Reprendre`, `Voir les résultats` et `Gérer` restent inchanges.

Fichier de reference:
- page agenda day: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`.

## Etat 2026-06-16 - Agenda pivot: ajout Quiz multi-series

Depuis la page pivot `/extranet/start/games/day/YYYY-MM-DD`, l'ajout d'une session Cotton Quiz via le builder multi-series conserve le contexte de date jusqu'a la fin du tunnel.

Comportement contractuel:
- le formulaire builder multi-series de la bibliotheque transmet `day_date` et `day_context` quand il est ouvert depuis le tunnel agenda;
- la validation du builder redirige vers `/extranet/start/game/setting/{session}` avec `tunnel=agenda`, `day_date`, `day_context` et `return_url` vers le pivot de date;
- le champ date de l'etape `setting` reste verrouille sur la date de la soiree/evenement;
- apres validation de l'etape `setting`, le sous-appel `session_theme` conserve `from=library`, `tunnel=agenda`, les `quiz_lot_ids` et le `return_url` pivot;
- les redirections bibliotheque agenda vers `setting` pour quiz simple et autres contenus conservent aussi le meme retour pivot.

Fichiers de reference:
- builder bibliotheque liste: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`;
- script bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`;
- script tunnel start: `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- formulaire setting: `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`.

## Etat 2026-06-16 - Session detail: retour pivot persistant

Le detail d'une session officielle future/courante reste rattache par defaut a sa page pivot de date.

Comportement contractuel:
- si une fiche session officielle non-demo et non archivee est ouverte sans `return_url`, elle calcule son retour par defaut vers `/extranet/start/games/day/YYYY-MM-DD` a partir de sa date;
- un `return_url` explicite conserve la priorite, notamment quand la fiche vient directement de la page pivot ou d'une action interne;
- le header de la fiche session utilise le contexte calcule pour afficher `Ma soiree`, `Mon evenement` ou `Mon animation`, au lieu de retomber sur `Mon agenda`;
- les actions de changement de thematique depuis les cartes session conservent ce retour pivot;
- les fiches archivees gardent le retour archives existant.

Fichiers de reference:
- detail session: `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`;
- header start: `pro/web/ec/modules/tunnel/start/ec_start_include_header.php`;
- carte session partagee: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`;
- helper pivot day: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`.

## Etat 2026-06-15 - Home / Agenda / confirmation autour du pivot soiree-evenement

La page pivot `/extranet/start/games/day/YYYY-MM-DD` devient le point de continuite naturel autour d'une date de sessions.

Comportement contractuel:
- le widget Home `Mon agenda` reste un raccourci operationnel et cible la prochaine date future ou courante via `/extranet/start/games/day/YYYY-MM-DD`;
- le widget Home ne liste pas les sessions individuelles et n'affiche pas le compteur global du reste de l'agenda; il conserve seulement le resume de la prochaine soiree/evenement;
- quand une prochaine date existe, le titre du widget devient `Prochaine soiree`, `Prochain evenement` ou `Prochaine animation` selon le contexte client;
- le rendu du widget avec prochaine date reprend une carte plus vivante: visuel de la premiere session, badge contexte (`PROCHAINE SOIRÉE`, `PROCHAIN ÉVÉNEMENT`, `C'EST LE JOUR J`, `EN COURS`, `BILAN`), titre engageant, resume court, date en haut a droite du badge, pills horaire/sessions, CTA principal en clic global de carte et lien secondaire `Agenda complet` dans le contenu;
- le visuel du widget Home utilise le meme detail jeu que les cartes Agenda, avec prise en compte des `lot_ids` pour les sessions Quiz;
- les libelles badge/titre evitent les redondances: futur `PROCHAINE SOIRÉE` / `PROCHAIN ÉVÉNEMENT`, jour J non demarre `C'EST LE JOUR J`, soiree/evenement lance `EN COURS`, session runtime en cours `EN COURS` + titre `Une session est en cours`;
- les wordings finaux du futur utilisent `PROCHAINE SOIRÉE` / `PROCHAIN ÉVÉNEMENT`, `Ta soiree est programmee` / `Ton evenement est programme`, et un lien secondaire court `Agenda complet`;
- l'etat bilan du jour utilise le badge `BILAN` et le texte court `Retrouve le bilan de ta soiree` / `Retrouve le bilan de ton evenement`;
- si toutes les sessions de la date du jour sont terminees, la Home peut afficher `BILAN` avec CTA `Voir le bilan` vers la page pivot; cette exception ne s'applique pas aux dates strictement passees;
- une date du jour reste consideree comme courante jusqu'a la fin de la journee, meme si une ou plusieurs sessions sont deja terminees;
- si une session de la prochaine date est en cours, le CTA Home devient `Reprendre`;
- quand le widget agenda standard affiche des sessions liees, la Home ne rend pas en plus le widget `first_party`;
- si aucune session future/courante n'existe, le widget conserve l'acces de programmation existant;
- la Home ne pousse pas les dates passees et n'affiche pas d'acces direct au bilan;
- l'Agenda conserve ses groupes par date et ses cartes sessions;
- dans chaque bandeau de date Agenda et confirmation batch, le compteur de sessions, la plage horaire et le CTA pivot conditionnel sont places a gauche, pres de la date;
- les groupes Agenda futurs/courants conservent le CTA pivot contextuel `Voir la soiree` / `Voir l'evenement` / `Voir l'animation`;
- les groupes Agenda archives affichent `Voir le bilan` vers la meme page pivot de date seulement pour les dates strictement passees;
- la confirmation batch `/extranet/start/game/resume-batch/...` regroupe les sessions creees par date, avec un CTA pivot propre a chaque date et les cartes sessions en dessous;
- la confirmation unitaire `/extranet/start/game/resume/...` affiche aussi le bandeau date avec le total de sessions de la date, mais conserve uniquement la carte de la session nouvellement programmee;
- l'action `Ajouter une session` reste disponible sous les groupes de confirmation;
- une session ouverte depuis une carte de la page pivot transmet cette page comme retour de sortie de jeu;
- une fiche session ouverte depuis la page pivot affiche un retour contextualise `Ma soiree`, `Mon evenement` ou `Mon animation`;
- le pivot ouvert depuis la Home affiche un retour vers l'accueil;
- une session ouverte depuis l'Agenda ou la fiche session conserve le retour existant vers la fiche detail session;
- les URLs de retour restent bornees au mecanisme existant `return_url` de l'interface games, limite aux URLs internes `/extranet/`.

Fichiers de reference:
- widget Home agenda: `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`;
- listing Agenda: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- confirmation batch: `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php`;
- page pivot date: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- carte session partagee: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`;
- sanitisation retour games: `games/web/organizer_canvas.php`.

## Etat 2026-06-15 - Agenda: bilan agrege de soiree/evenement

La page `/extranet/start/games/day/YYYY-MM-DD` presente maintenant un Bilan global pour une date passee, en reutilisant l'agregation `Ma communaute` sur le perimetre du jour.

Comportement contractuel:
- le haut de page `Bilan` synthétise la soiree/evenement au lieu de relister les resultats par session;
- les sessions prises en compte sont les sessions officielles du client courant, sur la date URL, completes non-demo et terminees/exploitables selon les criteres existants de l'agregateur communaute;
- le compteur participants reprend l'agregat fiable de `Ma communaute` quand disponible;
- l'UI reprend le rendu `Ma communaute`: badge par jeu, podium en 3 cartes, tableau Top 10 et points alignes a droite;
- un podium global et un classement global sont affiches par jeu, comme dans `Ma communaute`, quand plusieurs jeux sont consolidables sur la date;
- si la date est aujourd'hui et qu'il reste des sessions a jouer, l'ordre reste `Sessions`, `Recommandations`, puis `Bilan provisoire` avec le message court `Certaines sessions sont encore a jouer`;
- la section `Sessions` du jour conserve toutes les sessions de la date, y compris celles terminees aujourd'hui et deja classees en archive, pour garder le deroule complet de la soiree/evenement;
- quand toutes les sessions sont consolidees ou quand la date est passee, le bilan passe en premier puis les cartes sessions restent en dessous;
- le titre reste `Bilan de ta soiree` / `Bilan de ton evenement` des que la date est passee ou que toutes les sessions sont consolidees;
- les statistiques principales restent sobres: sessions jouees, participants, jeux joues;
- en cas d'agregat non fiable pour tous les jeux, aucun faux podium n'est affiche et le message utilisateur indique que le classement global sera disponible apres consolidation;
- si aucune session n'est terminee, le bloc affiche un etat doux sans faux zero;
- si une partie seulement des sessions est terminee, le titre devient `Bilan provisoire` et precise que le bilan se complete au fil des sessions jouees;
- les cartes sessions du bas et leurs CTA, dont `Voir les resultats`, restent inchangees.

Fichiers de reference:
- page agenda day: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- helper agenda day: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- agregateur communaute: `global/web/app/modules/entites/clients/app_clients_functions.php`;
- resultats par session: `global/web/app/modules/jeux/sessions/app_sessions_functions.php`.

## Etat 2026-06-15 - Agenda: vue operationnelle par date

L'agenda EC expose une V1 de page operationnelle par date pour presenter les sessions officielles d'un meme client sur une meme journee, sans creer d'objet metier evenement.

Comportement contractuel:
- la nouvelle route technique est `/extranet/start/games/day/YYYY-MM-DD`;
- le parametre date est valide strictement et une date invalide ou sans session affiche un etat vide avec retour agenda;
- la page reconstruit les donnees depuis le client courant, la date URL et les sessions officielles completes non-demo, avec mode temporel `upcoming`, `today` ou `past`;
- les cartes sessions existantes sont reutilisees afin de conserver les CTA `Gerer`, `Ouvrir le jeu`, `Reprendre` ou `Voir les resultats`;
- le bandeau de groupe de `/extranet/start/games` affiche un CTA visible `Voir la soiree`, `Voir l'evenement` ou `Voir l'animation` selon le contexte client;
- la distinction `soiree` / `evenement` / `animation` reste limitee aux libelles visibles: les routes et noms techniques utilisent `day`;
- avant le jour J, la page affiche `Sessions` puis `Recommandations et astuces`, avec liens integres vers le Media Kit et, si pertinent, la fiche lieu;
- le jour J, l'ordre devient `Sessions`, puis `Recommandations et astuces`;
- apres le jour J, l'ordre devient `Bilan`, puis `Sessions`;
- il n'y a plus de section `Communication` separee: la liste complete de liens publics copiables et le QR agenda permanent du lieu ne sont pas affiches sur cette page V1;
- la modale Media Kit est alimentee localement par les jeux programmes sur la date; la modale fiche lieu reutilise le formulaire async existant uniquement pour les contextes lieu public / dynamisation pertinents;
- le bilan de date passee est une synthese globale: sessions prises en compte, participants fiables, podium/classement global par jeu si l'agregat communaute est consolidable, sinon message utilisateur sans faux classement;
- le widget Home `Mon agenda`, les regles `first_party`, les regles de programmation `CSO` / `ABN` / `PAK`, les archives et le module `operations/events` ne sont pas modifies.

Fichiers de reference:
- route: `pro/web/.htaccess`;
- helper agenda day: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- page agenda day: `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
- listing agenda: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
- carte session agenda: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`.

## Etat 2026-06-12 - First_party ABN/PAK: historique utile bloque le widget Jour J

Les comptes actifs `ABN` / `PAK` avec archive officielle utile ne reconstruisent plus un contexte Home `first_party` uniquement parce qu'une session officielle est programmee le jour courant.

Comportement contractuel:
- `ec_first_party_can_access_today_preparation(...)` reste limite aux comptes `ABN` / `PAK` actifs, non restreints, avec offre active et session officielle du jour;
- cette branche Jour J refuse maintenant les comptes ayant deja un historique officiel utile via `ec_first_party_has_useful_past_official_sessions(...)`;
- `INS` conserve ses regles de Home simplifiee et de preparation avec session officielle future;
- `ABN` / `PAK` sans archive officielle utile et en premiere programmation potentielle conservent l'acces `first_party` existant;
- la Home et le widget continuent de rendre uniquement l'etat serveur retourne par `ec_first_party_home_widget_state_get(...)`;
- aucun changement de CTA, URL, texte, tunnel, SQL ou style n'est introduit.

Fichier de reference:
- helper first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`.

## Etat 2026-06-12 - First_party mobile: ancrage et ajustements locaux

Le parcours `first_party` / `first_session` applique un patch UI mobile cible sans refonte responsive globale.

Comportement contractuel:
- la Home simplifiee `first_party` ajuste uniquement le variant `offer_card` sous le wrapper `home-first-party-simplified-grid`;
- la Home complete des comptes actifs `ABN` / `PAK` en preparation `first_party` conserve le trio de widgets standards `Mon agenda`, `Les jeux` et `Ma communaute` apres le widget prioritaire;
- les widgets Home complets et les composants partages (`card-widget`, `btn`, `home-content-row`, `home-grid-sync-col`, `card-game`) ne sont pas modifies globalement;
- le tunnel `/extranet/onboarding/first-party` marque la section active avec `first-party-current-step` et scrolle vers elle seulement apres un POST de validation;
- l'arrivee normale en GET ne declenche pas de scroll automatique;
- l'etape 3 garde la priorite des contenus reseau, mais son bloc d'information et ses mini-cartes sont moins denses sur mobile;
- le pivot Jour J conserve ses CTA et URLs, avec un rendu mobile du CTA formule moins comprime;
- aucun changement metier, SQL, texte ou route n'est introduit.

Fichiers de reference:
- widget first_party Home: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`;
- orchestration Home: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- pivot/tunnel first_party: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-11 - Home: widget ABN generique premiere animation neutralise

La Home ne rend plus l'ancien widget reseau generique `Lance ta première animation` / `Je me lance`.

Comportement contractuel:
- la variante `abn_generic_onboarding` retournee par `app_client_home_onboarding_widget_get(...)` est neutralisee cote Home;
- le parcours de premiere animation est porte par le widget `first_party`;
- les bandeaux reseau contextuels restent autorises quand ils apportent une information d'affiliation exploitable (`abn_network_context`, `ins_network_context`, `cso_network_context`);
- aucune regle d'eligibilite `first_party`, de pivot jour J ou de programmation n'est modifiee.

Fichier de reference:
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`.

## Etat 2026-06-11 - First_party pivot: cartes sessions alignees agenda

Les cartes sessions du pivot `/extranet/onboarding/first-party` suivent les conventions de l'agenda pour l'etat session, les compteurs et les CTA.

Comportement contractuel:
- le statut d'une session repose sur `app_session_edit_state_get(...)` puis `app_session_display_chronology_get(...)`, comme les cartes agenda;
- avant la session et pendant une session non terminee, le compteur affiche les participations probables via `app_session_participations_probables_get_count(...)`;
- apres session terminee/archivee, le compteur affiche les joueurs runtime issus de `app_session_results_get_context(...)[players_count]`;
- si une session terminee n'a aucun joueur runtime exploitable, aucun compteur n'est affiche afin d'eviter une indication trompeuse;
- les CTA gardent les URLs existantes et changent seulement de libelle selon l'etat de chaque carte: `Préparer`, `Ouvrir le jeu`, `Reprendre`, `Voir les résultats`;
- le rendu visuel reprend les conventions agenda: cloche pour participations probables, icone joueurs pour compteur runtime, cast pour acces jeu, trophee pour resultats;
- l'agenda affiche aussi `Reprendre` pour une session en cours, au lieu de reutiliser `Ouvrir le jeu`;
- aucune regle d'eligibilite `INS` / `CSO` / `ABN` / `PAK` n'est modifiee.

Fichiers de reference:
- pivot first_party: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- carte agenda: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`;
- helpers statut/resultats: `global/web/app/modules/jeux/sessions/app_sessions_functions.php`.

## Etat 2026-07-22 - Résultats Bingo: compteur runtime strict

Les surfaces PRO qui affichent les résultats archivés ou terminés consomment `app_session_results_get_context(...)[players_count]`. Pour Bingo, ce compteur suit maintenant strictement la liste affichée par `global`: si `bingo_players.session_id` contient des joueurs pour la session, les labels historiques liés à la playlist ne peuvent plus ajouter de participants. Les fallbacks historiques restent disponibles uniquement pour les archives sans runtime fiable.

Fichiers de référence:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`;
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`.

## Etat 2026-06-11 - First_party ABN/PAK: pivot conserve tout le jour J

Les comptes actifs `ABN` / `PAK` qui ont une preparation `first_party` programmee aujourd'hui gardent l'acces au widget Home pret et au pivot `/extranet/onboarding/first-party` pendant toute la date de first_party, meme si une session du jour est deja terminee et devient une archive utile.

Comportement contractuel:
- l'eligibilite `ec_first_party_is_eligible_account(...)` reste la source pour proposer ou creer une nouvelle preparation first_party;
- l'acces au pivot jour J utilise une condition separee: compte actif `ABN` / `PAK`, non siege reseau, offre effective active, et au moins une session officielle complete non-demo online datee du jour;
- cette condition n'ouvre pas le tunnel initial et ne neutralise pas l'historique officiel utile: une session utile continue donc de bloquer la relance de premiere programmation;
- le widget Home reste en mode `preparation` pendant le jour J si des sessions first_party du jour existent, y compris apres detection d'une archive utile;
- le lendemain, la condition jour J tombe, le widget pivot n'est plus prioritaire et la Home active classique reprend si l'historique est utile;
- si les sessions passees ne sont pas utiles, la regle existante de reproposition du widget initial reste inchangee;
- aucun changement n'est applique aux comptes `INS` / `CSO`.

Rattrapage documentaire first_party ABN/PAK / CSO / navigation:
- la logique `ec_first_party_requires_offer_activation_before_next_programming(...)` separe les comptes qui doivent activer une formule (`INS`, `CSO` sans offre active) des `ABN` / `PAK` actifs;
- les blocages de programmation distinguent `INS`, `CSO`, `ABN` et `PAK`: `ABN` / `PAK` actifs sont exclus du blocage global `choisis une formule`;
- la garde fine `date <= first_party` reste la protection dediee `ABN` / `PAK` autour de la premiere date programmee;
- `Mon agenda`, `Ma communaute` et `Media Kit` restent accessibles aux `ABN` / `PAK` actifs quand leur signal de session visible le permet;
- le widget agenda Home ne declenche plus la modale formule pour `ABN` / `PAK` actifs;
- les CTA bibliotheque restent alignes sur le contexte first_party seulement avant programmation / avant premiere date utile, puis reviennent aux actions classiques;
- le widget Home `first_party` peut afficher pour les seuls `CSO` sans offre active le lien secondaire `Reactiver directement un abonnement`, sans modifier le CTA principal vers le parcours guide.

Fichier de reference:
- helper first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`.

## Etat 2026-06-11 - First_party ABN/PAK: sortie du blocage formule

Les comptes actifs `ABN` / `PAK` qui ont programme leur first_party ne sont plus assimiles a des `INS` pour les blocages de formule et la navigation client actif.

Comportement contractuel:
- la modale `Ta premiere soiree est prete... choisis d'abord ta formule d'essai gratuit` reste reservee aux comptes qui doivent activer une formule avant de programmer une autre session, notamment `INS` et `CSO` de reactivation;
- `ABN` / `PAK` avec offre effective active, pack actif ou abonnement actif ne declenchent plus ce blocage global du seul fait d'une session officielle first_party future;
- pour `ABN` / `PAK`, la garde fine de date reste applicable: une nouvelle session ne peut pas etre placee a une date inferieure ou egale a la premiere date officielle first_party;
- apres une session officielle first_party passee, meme sans archive utile, `ABN` / `PAK` peuvent reprendre une programmation classique;
- `Mon agenda`, `Ma communaute` et `Media Kit` ne sont plus masques pour `ABN` / `PAK` actifs par la restriction de navigation first_party;
- le parcours `CSO` sans offre active reste separe: eligibilite de reactivation, Home simplifiee, lien secondaire de reactivation et blocage avec session officielle future sont conserves.

Fichiers de reference:
- helper first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- navigation shell EC: `pro/web/ec/ec.php`;
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- widget agenda Home: `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`;
- bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`, `ec_bibliotheque_list.php`, `ec_bibliotheque_script.php`.

## Etat 2026-06-11 - Widget Home first_party: lien reactivation CSO et eligibilite INS

Le widget Home `first_party` conserve son role de parcours recommande, mais propose aux anciens clients `CSO` sans offre active un acces secondaire discret a la commande avant programmation.

Comportement contractuel:
- le CTA principal du widget reste inchange et continue de pointer vers `/extranet/onboarding/first-party`;
- pour un `CSO` eligible, sans offre active et sans first_party deja programmee, un lien secondaire `Reactiver directement un abonnement` apparait juste sous le CTA principal;
- le lien reutilise l'URL ecommerce deja calculee pour le menu `Je commande`, sans nouvelle route;
- le lien reutilise le rendu du CTA secondaire Jour J (`ec-first-party-offer-card-secondary-cta`) au lieu d'un style specifique CSO;
- le clic global de la carte reste dirige vers le parcours guide, tandis que le clic secondaire stoppe sa propagation et reste cliquable independamment;
- le lien n'est pas affiche pour `INS`, `ABN`, `PAK`, ni quand le widget est en mode preparation avec session officielle future;
- le cas Jour J formule/pivot existant reste prioritaire et ne recoit pas ce lien.

Regle d'eligibilite associee:
- un `INS` eligible n'est plus bloque par l'historique de sessions officielles passees;
- un `CSO` eligible sans offre active reste lui aussi independant de l'historique officiel passe;
- `ABN` et `PAK` conservent la prise en compte de l'historique officiel utile pour ne pas rouvrir a tort un parcours de premiere programmation.

Fichiers de reference:
- helper first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- widget first_party Home: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`.

## Etat 2026-06-11 - Navigation first_party: commande discrete en derniere position

Le parcours `first_party` / `next_party` reste le parcours recommande, mais l'acces direct a la commande reste disponible dans la navigation comme entree discrete.

Comportement contractuel:
- l'ancien CTA commande dominant du menu gauche n'est pas affiche pour les comptes accompagnes;
- le lien commande est rendu comme un lien de navigation standard (`nav-link`), avec le libelle dynamique existant `Essai gratuit` / `Je m'abonne` / `Je commande`;
- l'URL ecommerce existante est conservee;
- pour un menu simplifie, l'ordre attendu est `Accueil`, `Les jeux`, puis le lien commande;
- si `Offre & Factures` est affiche, notamment pour certains `CSO`, le lien commande est place sous `Offre & Factures`;
- le lien commande reste la derniere entree visible de la liste principale;
- `Mon agenda`, `Ma communaute` et `Media Kit` restent masques selon les regles du parcours accompagne;
- aucun changement sur Home, tunnel, pivot, bibliotheque, programmation, page commande, routes ou offre effective.

Fichier de reference:
- navigation shell EC: `pro/web/ec/ec.php`.

## Etat 2026-06-11 - First_party etendu aux CSO sans offre active

Le tunnel existant `/extranet/onboarding/first-party` couvre maintenant aussi les comptes `CSO` sans offre active effective, comme parcours accompagne de relance / reactivation.

Comportement contractuel:
- aucune route `next_party` n'est creee; le parcours reutilise uniquement `/extranet/onboarding/first-party`;
- l'eligibilite reste centralisee dans `ec_first_party_is_eligible_account(...)`;
- un `CSO` est eligible seulement si `app_ecommerce_offre_effective_get_context(...)` ne remonte pas d'acces commercial effectif actif;
- une offre deleguee active resolue par le helper d'offre effective bloque donc le parcours de reactivation;
- les exclusions deja appliquees au parcours restent conservees: compte restreint, siege reseau, contexte `venue` / `event` non resolu;
- les affilies reseau ne sont pas exclus par principe; seule l'offre effective active les sort du parcours;
- les wordings `INS` restent `premiere soiree` / `premier evenement`;
- les wordings `CSO` deviennent `prochaine soiree` / `prochain evenement`;
- la Home simplifiee affiche `first_party` en 2/3 et `Les jeux` en 1/3 pour un `CSO` eligible, sans widget commande/offre Home;
- avec session officielle future, le widget passe en mode preparation/pivot avec CTA `Voir ma soiree` / `Voir mon evenement`;
- la navigation masque `Mon agenda`, `Ma communaute`, `Media Kit` et le CTA commande dominant pour tout compte dans le parcours accompagne;
- la bibliotheque peut alimenter le brouillon first_party d'un `CSO` eligible sans session officielle future;
- apres programmation d'une session officielle future, les tentatives de programmation hors pivot sont bloquees tant qu'aucune offre effective active n'existe.

Fichiers de reference:
- helper first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- widget first_party Home: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`;
- pivot first_party: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`, `ec_bibliotheque_list.php`, `ec_bibliotheque_script.php`;
- navigation shell EC: `pro/web/ec/ec.php`;
- widget agenda Home: `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`.

## Etat 2026-06-11 - Home first_party: horaires aux couleurs gamification

La carte Home `first_party` en variante commande utilise l'accent typologie pour les horaires affiches dans le resume `Premier evenement programme` / `Soiree programmee`.

Comportement contractuel:
- les horaires des sessions ne sont plus forces en violet generique dans la carte `offer_card`;
- la couleur suit `ec_first_party_typology_color_id_get(...)`, deja utilisee pour le badge et le CTA du widget;
- l'accent `21` est rendu en orange Cotton et l'accent `22` en rose dans cette carte;
- le variant standard du widget `first_party`, les donnees de sessions, les libelles et les CTA ne changent pas.

Fichier de reference:
- widget first_party Home: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`.

## Etat 2026-06-11 - Home first_party: widget reseau affilié conserve en bas

La Home EC conserve le widget de contexte reseau affilie sous les autres blocs quand `app_client_home_onboarding_widget_get(...)` le rend affichable, y compris dans la Home simplifiee `first_party`.

Comportement contractuel:
- le widget reseau affilie n'est plus neutralise par la presence du widget `first_party`;
- son emplacement reste le rendu bas de Home deja prevu par `home_network_affiliate_widget_render_at_bottom`;
- la Home simplifiee `first_party` garde sa grille principale `first_party` + `Les jeux`;
- le widget reseau s'affiche uniquement apres cette grille et seulement si ses conditions serveur existantes retournent `show`;
- aucun changement sur les comptes tete de reseau, le helper reseau, les CTA ou les donnees affichees.

Fichier de reference:
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`.

## Etat 2026-06-10 - Home INS simplifiee first_party avec sessions futures

La Home `INS` reste simplifiee autour du widget `first_party` et du widget `Les jeux`, y compris quand une premiere session officielle future existe deja.

Comportement contractuel:
- pour `INS`, la Home simplifiee s'applique des qu'un widget `first_party` est visible, en onboarding ou en preparation;
- avec session officielle future, le widget `first_party` affiche le mode preparation et le recap dynamique existant;
- sans session officielle future, un contexte `venue` / `event` peut etre reconstruit depuis la typologie si l'etat first_party standard est vide;
- le widget `Les jeux` garde la variante `Explore les thèmes` dans cette Home simplifiee;
- les `ABN` / `PAK` conservent une regle plus stricte: Home simplifiee uniquement en onboarding, donc sans session officielle future;
- les CTA bibliotheque de preprogrammation restent limites aux comptes `INS`, `ABN` et `PAK` sans session officielle future.

Fichiers de reference:
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- fiches bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`;
- liste/builder bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`;
- seed bibliotheque first_party: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`.

## Etat 2026-06-10 - Pivot first_party: astuce fiche lieu toujours visible

Dans le pivot `/extranet/onboarding/first-party`, l'astuce fiche lieu reste visible en contexte lieu public, y compris quand la fiche client possede deja les informations minimales.

Comportement contractuel:
- l'astuce reste limitee au contexte `venue`; elle reste absente en contexte evenement/gamification;
- si la fiche lieu manque de champs obligatoires, le lien affiche `Complète ta fiche lieu` et le texte demande de verifier les infos publiques;
- si la fiche lieu est deja complete, le lien affiche `Vérifie ta fiche lieu` et le texte demande d'adapter les infos affichees aux joueurs;
- la modale reutilise toujours la page existante de gestion du lieu;
- apres une sauvegarde reussie depuis la modale, l'astuce reste visible et bascule en mode verification au lieu d'etre retiree.

Fichier de reference:
- pivot first_party: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-10 - Widget Home first_party: pictos commande

Le widget Home `first_party` en variante `offer_card` reprend les pictogrammes visibles dans les widgets de commande dont il reutilise le gabarit.

Comportement contractuel:
- le titre affiche une icone selon la typologie: `✨` pour lieu/abonnement, `🎯` pour evenement, `⚡` pour particulier;
- le CTA principal affiche `🚀` avant son texte;
- les libelles de CTA du variant `offer_card` ne portent plus de fleche `→`;
- la destination du CTA principal et le comportement `stretched-link` restent inchanges;
- le CTA secondaire, quand il existe, conserve son role de pivot sans icone ajoutee.

Fichier de reference:
- widget first_party Home: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`.

## Etat 2026-06-10 - First_party ABN/PAK avant session officielle future

Les comptes actifs `ABN` / `PAK` eligibles au contexte `first_party` et sans session officielle future utilisent maintenant la meme experience de premiere programmation que les comptes `INS` pre-programmation.

Comportement contractuel:
- la Home simplifiee s'applique quand `ec_first_party_home_widget_state_get(...)` retourne un etat `onboarding`, donc sans session officielle future;
- la grille principale affiche le widget `first_party` en 2/3 puis `Les jeux` en 1/3 sur desktop;
- le widget Home `Mon agenda` et la grille Home standard sont masques dans ce contexte uniquement;
- le widget `Les jeux` affiche alors `Joue des démos`, `Explore les thèmes`, `Ajoute tes contenus`;
- les fiches detail bibliotheque affichent `Lancer une démo`, puis `Utiliser pour ma première soirée` ou `Utiliser pour mon premier événement`;
- le CTA d'utilisation preselectionne le contenu dans le tunnel `first_party` existant via `first_party_library_confirm=1`, sans creer de session depuis la bibliotheque;
- le builder Cotton Quiz conserve le passage par validation du builder avant la redirection first_party;
- les `ABN` / `PAK` ayant deja une session officielle future ne passent pas dans la Home simplifiee et conservent leurs comportements de programmation existants;
- les contextes agenda, remplacement de theme et first_party deja en cours ne sont pas modifies.

Fichiers de reference:
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- widget first_party Home: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`;
- widget Les jeux: `pro/web/ec/modules/widget/ec_widget_jeux_discover_library.php`;
- fiches bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`;
- liste/builder bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`;
- seed bibliotheque first_party: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`;
- helper first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`.

## Etat 2026-06-10 - Correctif INS Quiz bibliotheque et widget Jour J

Le parcours bibliotheque Cotton Quiz des comptes `INS` sans session officielle future conserve le builder multi-series avant d'entrer dans `first_party`.

Comportement contractuel:
- sur une fiche Cotton Quiz non legacy, le CTA d'utilisation first_party ajoute la serie au builder Quiz au lieu de creer directement une selection first_party;
- le builder permet toujours jusqu'a 4 series;
- `Valider` / `Continuer` depuis le builder seed ensuite le tunnel `first_party` avec les series choisies;
- la correction s'applique au bandeau builder de la fiche detail et de la liste bibliotheque;
- les playlists Blind Test / Bingo Musical gardent la bascule directe vers le tunnel;
- les comptes `INS` avec session officielle future gardent le blocage hors pivot;
- le widget Home `first_party` post-programmation n'affiche plus les chips d'actions sous le recap;
- le Jour J, les CTA formule et pivot sont cote a cote sur desktop et le CTA pivot reste lisible;
- le CTA du widget est rapproche du contenu pour limiter les grands blancs.
- le widget `first_party` INS est de nouveau entierement cliquable; le clic global suit le CTA principal, formule si elle est affichee sinon pivot;
- le hover de la carte active aussi l'etat visuel du CTA principal via `stretched-link`, comme le widget `Les jeux`, sans positionnement propre sur le bouton principal;
- les comptes typologie Particulier utilisent le visuel `/ec/images/communication/statique/cotton-club.jpg`, identique au widget commande.

Fichiers de reference:
- fiche detail bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`;
- liste bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`;
- widget first_party Home: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`.

## Etat 2026-06-10 - Home INS first_party: recap dynamique dans le layout 2/3

La Home `INS` conserve son layout simplifie, mais le widget `first_party` affiche a nouveau les informations concretes de la premiere soiree / du premier evenement une fois les sessions officielles programmees.

Comportement contractuel:
- le layout reste `first_party` en 2/3 puis `Les jeux` en 1/3 sur desktop;
- le widget commande/offre Home reste masque pour les comptes `INS`;
- en pre-programmation, le widget garde les etapes d'accompagnement;
- en post-programmation avec session officielle future, le widget affiche le resume dynamique deja disponible: date, nombre de sessions, jeu(x), horaires et titres/themes si accessibles;
- les etapes generiques sont remplacees par les actions restantes: personnaliser, tester, preparer le partage ou les informations participants;
- avant Jour J, le CTA unique renvoie au pivot avec `Voir ma soirée` ou `Voir mon événement`;
- le Jour J, sans offre active, le widget propose la formule seulement si `ec_first_party_typology_offer_url_get(...)` fournit une URL; sinon il conserve le pivot seul;
- les donnees dynamiques restent issues de `ec_first_party_home_widget_state_get(...)` et du resume local `$first_party_widget_summary`;
- aucun changement sur programmation, pivot, tunnel, routes, SQL ni comportements `ABN` / `PAK` / `CSO`;
- le widget `Les jeux` garde pour `INS` le point `Explore les thèmes` et s'aligne en hauteur avec le widget `first_party`.

Fichiers de reference:
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- widget first_party Home: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`;
- widget Les jeux: `pro/web/ec/modules/widget/ec_widget_jeux_discover_library.php`;
- helper first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`.

## Etat 2026-06-10 - Bibliotheque INS avant programmation first_party

Les fiches detail de la bibliotheque accompagnent les comptes `INS` vers le parcours de premiere soiree / premier evenement tant qu'aucune session officielle future first_party n'est programmee.

Comportement contractuel:
- la regle s'applique uniquement aux comptes `INS` en contexte first_party, sans session officielle future;
- le CTA principal affiche `Lancer une démo`;
- le CTA secondaire affiche `Utiliser pour ma première soirée` en contexte lieu/soiree, ou `Utiliser pour mon premier événement` en contexte evenement;
- le CTA direct `Créer un Blind Test` / `Créer un Bingo Musical` / `Créer un Cotton Quiz` n'est pas affiche dans ce cas;
- le CTA d'utilisation reutilise le seed bibliotheque first_party existant, preselectionne le contenu et redirige vers `/extranet/onboarding/first-party`;
- aucune session officielle n'est creee depuis la fiche bibliotheque;
- aucune modale intermediaire n'est affichee pour ce cas;
- les comptes `INS` avec session officielle future conservent le blocage hors pivot et la modale first_party existante;
- les comptes `ABN`, `PAK` et `CSO` conservent leurs CTA, leur ordre et leurs comportements existants;
- le widget Home `Les jeux Cotton` affiche pour les seuls `INS`: `Joue des démos`, `Explore les thèmes`, `Ajoute tes contenus`.

Fichiers de reference:
- fiche detail bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`;
- seed bibliotheque first_party: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`;
- widget Les jeux: `pro/web/ec/modules/widget/ec_widget_jeux_discover_library.php`.

## Etat 2026-06-10 - Home INS simplifiee first_party + jeux

La Home EC des comptes `INS` utilise maintenant une composition simplifiee et dediee autour du parcours first_party.

Comportement contractuel:
- la Home `INS` non siege reseau affiche uniquement deux widgets dans la grille principale;
- le widget `first_party` est en premiere position et occupe 2/3 de la ligne desktop;
- le widget `Les jeux` est en seconde position et occupe 1/3 de la ligne desktop;
- les deux widgets passent en pleine largeur sur mobile;
- le widget offre/commande Home n'est plus rendu pour les comptes `INS`;
- le widget `first_party` reprend le gabarit du widget commande: carte `card-widget`, image laterale desktop, image haute mobile, badge, contenu, points et CTA;
- sans session officielle future, le widget garde le role de preparation de premiere soiree / premier evenement;
- avec session officielle future, le widget conserve l'etat pret et son CTA vers `/extranet/onboarding/first-party`;
- le CTA commande du menu EC est masque pour un `INS` avec session officielle future first_party;
- les Homes `ABN`, `PAK` et `CSO` ne changent pas.

Fichiers de reference:
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- widget first_party Home: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`;
- widget Les jeux: `pro/web/ec/modules/widget/ec_widget_jeux_discover_library.php`;
- navigation shell EC: `pro/web/ec/ec.php`.

## Etat 2026-06-10 - First_party INS programme: blocage hors pivot

Les comptes `INS` qui ont deja une premiere soiree / un premier evenement officiel a venir restent dans le parcours `first_party` jusqu'a cette premiere date et ne peuvent pas creer une nouvelle session officielle hors pivot.

Comportement contractuel:
- la garde ne s'applique qu'aux comptes `INS` eligibles avec au moins une session officielle future;
- les tentatives de programmation depuis le tunnel start, le mode agenda quick, les CTA Home/agenda et la bibliotheque sont bloquees avant creation;
- la modale affiche `Ta première soirée est prête` en contexte lieu/soiree, ou `Ton premier événement est prêt` en contexte evenement;
- le CTA principal utilise la route d'offre existante resolue par typologie quand elle est disponible;
- si aucune route formule n'est disponible, aucune route n'est inventee et le pivot reste le minimum d'action disponible;
- le CTA secondaire renvoie vers `/extranet/onboarding/first-party`;
- une fois la premiere date passee, ce patch ne change pas le comportement existant de reprise du process de premiere soiree / premier evenement;
- les comptes `ABN` / `PAK` conservent leurs gardes first_party existantes;
- les liens `Mon agenda`, `Ma communaute` et `Media Kit` de la navigation EC sont masques pour tous les comptes `INS`.

Fichiers de reference:
- helper first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- script start: `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`, `ec_bibliotheque_view.php`, `ec_bibliotheque_list.php`;
- widgets: `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`, `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`;
- navigation shell EC: `pro/web/ec/ec.php`.

## Etat 2026-06-10 - First_party: historique utile et suppression du resume

Le widget Home `first_party` et les gardes de premiere programmation utilisent l'historique officiel utile, pas la simple existence brute d'une session officielle passee.

Comportement contractuel:
- une archive officielle utile/significative bloque le parcours de premiere programmation;
- une session officielle passee non utile, par exemple numerique sans vrais joueurs/resultats, ne bloque plus le parcours;
- une session papier passee demarree non demo ou une session numerique passee demarree avec vrais joueurs/resultats est consideree utile meme si elle n'est pas explicitement terminee;
- les comptes `ABN` / `PAK` actifs sans archive utile peuvent donc entrer dans le parcours premiere programmation;
- les comptes `INS` sans session future et sans archive utile retombent sur l'affichage classique `Prépare ta première soirée Cotton` / `Prépare ton premier événement Cotton`;
- le mode Home `resume` n'est plus expose: pas de libelle `Reprogramme...` ni CTA `Reprendre ma préparation`;
- une session officielle future conserve le mode preparation existant;
- aucun changement sur le pivot, le checkout ou la creation de sessions.

Fichiers de reference:
- helper first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- widget Home: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`.

## Etat 2026-06-10 - Navigation EC: liens masques sans session visible

Les liens `Mon agenda`, `Media Kit` et `Ma communaute` de la navigation gauche EC sont bornes par l'existence d'une session officielle visible: session future/en cours non archivee, ou archive utile.

Comportement contractuel:
- les comptes siege reseau ne voient toujours pas `Mon agenda`, `Media Kit` ni `Ma communaute`;
- `Mon agenda` et `Media Kit` sont affiches seulement si le compte possede au moins une session officielle visible selon `app_client_has_visible_official_session_signal(...)`;
- le CTA ecommerce du menu gauche suit la meme garde et affiche `Essai gratuit` pour un compte `INS` dynamisation eligible, `Je commande` pour un compte gamification, sinon `Je m'abonne`;
- une session future/en cours complete non demo qualifie l'affichage;
- une session archivee qualifie l'affichage seulement si elle est utile pour l'historique: papier demarree ou numerique demarree avec vrais participants/resultats exploitables;
- `Ma communaute` suit la meme base, sauf pour l'usage gamification qui exige directement une archive utile;
- le CTA `Voir mes sessions passees` de `/extranet/start/games` utilise le meme filtre utile que la liste `Archives`;
- la regle ne depend pas du pipeline, de la typologie ni de l'offre active/effective;
- les sessions demo et les sessions incompletes ne qualifient pas l'affichage;
- `Agenda reseau`, les routes agenda, les sessions et les pages Home / first_party / offre / checkout ne sont pas modifies.

Fichier de reference:
- navigation shell EC: `pro/web/ec/ec.php`.
- agenda EC: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`.

## Etat 2026-06-09 - First_party pivot: verification fiche lieu avant partage

Le pivot `/extranet/onboarding/first-party` affiche une astuce inline dans la section `Les participants` pour les comptes lieu public / dynamisation, avant les outils de partage.

Comportement contractuel:
- le rappel est limite au contexte `venue` first_party, donc pas affiche pour `event` / gamification;
- l'astuce apparait dans la section participants lorsque les outils de partage sont affiches avant jour J et jour J;
- le texte demande de verifier l'adresse affichee aux joueurs avant partage des liens de sessions;
- l'astuce est masquee si la fiche lieu porte deja les champs obligatoires du formulaire (`nom`, `adresse`, `code postal`, `ville`, `pays`) ou apres sauvegarde modale reussie;
- le CTA `Completer ma fiche lieu` ouvre une grande modale avec le formulaire existant `Ma communaute` / gestion du lieu, rendu en fragment async;
- la sauvegarde reste sur la page pivot et repond en JSON seulement dans ce contexte modal;
- un fallback permet d'ouvrir `/extranet/account/establishment/manage` si le chargement ou l'enregistrement modal echoue;
- aucun formulaire lieu concurrent n'est cree;
- le champ `Adresse` est maintenant obligatoire dans le formulaire lieu;
- aucune regle `clients.online`, `/fr/place` ou `/fr/agenda` n'est modifiee.

Fichier de reference:
- pivot first_party: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- formulaire lieu existant: `pro/web/ec/modules/compte/client/ec_client_form.php`;
- sauvegarde lieu existante: `pro/web/ec/modules/compte/client/ec_client_script.php`.

## Etat 2026-06-09 - First_party pivot: essai gratuit et date lointaine

Le pivot `/extranet/onboarding/first-party` conserve l'activation d'offre existante, mais affiche maintenant un rappel non bloquant lorsque la premiere date officielle first_party est strictement apres J+15.

Comportement contractuel:
- le message ne s'affiche que pour un compte `INS` eligible first_party, sans offre active, avec une premiere session officielle future planifiee;
- la premiere date doit etre strictement superieure a aujourd'hui + 15 jours;
- le message affiche: `Ton essai gratuit dure 15 jours. Attends le bon moment pour l’activer : ta préparation restera disponible.`;
- le CTA de choix de formule reste disponible;
- aucun changement de Checkout Stripe, webhook, etat d'offre, session ou regle `CSO`.

Audit Stripe:
- le checkout abonnement transmet seulement `trial_period_days` a Stripe;
- le webhook `invoice.paid` valide l'offre Cotton des la creation de la souscription, meme si la facture initiale est a `0` pendant l'essai;
- l'activation differee n'est donc pas patchee sans conception bout-en-bout Stripe + Cotton + webhooks.

Fichier de reference:
- pivot first_party: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-09 - Home EC: widget affiliation reseau en bas de page

Le widget Home qui resume l'affiliation d'un compte a une TdR est rendu en bas de la Home pour test de placement.

Comportement contractuel:
- le composant reste `pro/web/ec/modules/widget/ec_widget_client_network_affiliate_home.php`;
- les classes et variantes existantes du composant sont conservees;
- les anciens points d'appel en haut de page sont neutralises par un rendu differe;
- le widget est rendu une seule fois apres la grille principale de la Home.
- les rows principales de la Home partagent `home-content-row` pour harmoniser l'espacement vertical selon les contextes;
- le widget compact `Nouveautes` garde une marge haute dediee quand il reste dans la row des widgets centraux;
- en desktop, la row basse est bornee a la largeur utile de la derniere row de contenu visible et evite une marge basse excessive.

Fichier de reference:
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`.

## Cadrage first_party V1 et extensions futures — 2026-06-09

Le parcours `first_party` V1 reste un parcours d'accompagnement de premiere soiree / premier evenement.

Perimetre V1:
- comptes `INS` eligibles;
- nouveaux comptes actifs `ABN` / `PAK` sans session officielle passee;
- objectif produit: aider a preparer une premiere soiree ou un premier evenement, sans devenir un assistant de programmation general.

Extensions futures a traiter comme projets separes:
- `CSO` autonomes sans offre active: parcours de reactivation, avec regle offre/session dediee;
- affilies reseau: regle dediee tenant compte de la delegation, du support reseau, des contenus partages et des restrictions TdR.

Decision actuelle:
- ne pas transformer `first_party` V1 en parcours de reactivation general;
- conserver les extensions futures hors runtime tant que leur regle produit et technique n'est pas validee.

## Etat 2026-06-09 - First_party CSO: audit sans ouverture runtime

Les comptes `CSO` restent exclus de l'eligibilite `first_party` runtime.

Constats:
- `CSO` est un etat pipeline lu depuis `clients.id_pipeline_etat`, pas une garantie autonome d'absence d'offre active;
- la source fiable d'acces commercial est `app_ecommerce_offre_effective_get_context(...)`, qui distingue offre propre active, acces reseau actif et inactif;
- un compte `CSO` peut avoir un rattachement reseau, un contexte support/delegation inactif ou des sessions officielles futures;
- le tunnel first_party peut techniquement creer des sessions sans offre active, car ses sessions sont creees sans `id_offre_client`, puis le pivot renvoie vers l'offre adaptee;
- l'annulation du pivot supprime des sessions officielles futures affichees, donc un CSO avec session officielle future doit rester exclu.

Regle proposee pour un futur patch:
- pipeline `CSO` confirme;
- aucun acces effectif (`app_ecommerce_offre_effective_get_context(...).access_state === inactive`);
- aucune session officielle future exploitable;
- compte non restreint, non siege reseau/TdR;
- pas de delegation reseau active ou en attente a traiter par le parcours reseau;
- contexte `venue` / `event` resolu par typologie comme les autres comptes first_party;
- tunnel et CTA offre verifies en recette pour CSO venue, event et affilie reseau inactif.

Decision actuelle: non patche.

## Etat 2026-06-09 - Home first_party: retour wording historique et modale agenda Home

Le widget Home `first_party` conserve sa logique d'affichage et revient aux wordings historiques de premiere soiree / premier evenement.

Comportement contractuel:
- en contexte lieu/CHR, les etats entree/reprise parlent de `premiere soiree`;
- en contexte evenement, les etats entree/reprise parlent de `premier evenement`;
- le mode reprise INS conserve le wording historique `Reprogramme...` et son CTA de reprise;
- la branche generique `Prepare une soiree Cotton` / `Prepare un evenement Cotton` n'est plus maintenue;
- le raccourci agenda Home `Je programme` affiche une modale first_party pour `ABN` / `PAK` actifs eligibles, sans session officielle passee ni session officielle future;
- cette modale reutilise la copie agenda first_party existante;
- le CTA principal pointe vers `/extranet/onboarding/first-party`, le CTA secondaire ferme la modale;
- les conditions d'eligibilite first_party ne changent pas et `CSO` reste ferme.

Fichiers de reference:
- widget Home first_party: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`;
- widget agenda Home: `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`;
- helpers first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`.

## Etat 2026-06-09 - Home EC: Nouveautes compactes stabilisees

La Home EC conserve le widget `Nouveautes` dans la grille principale pour les comptes eligibles, mais la variante compacte demarre maintenant sur une ligne desktop dediee lorsqu'elle suit des cartes Home.

Comportement contractuel:
- le widget `Nouveautes` ne se colle plus a droite des premieres cartes quand les widgets prioritaires `first_party`, reseau ou feedback ne sont pas affiches;
- la rupture de ligne est limitee aux breakpoints desktop larges (`xl+`) et a la variante compacte;
- le bloc `Nouveautes` calcule sa largeur depuis la largeur reelle de la carte widget de la ligne precedente multipliee par le nombre de cartes jeu, afin que chaque carte conserve la meme largeur de reference sur desktop;
- le faux break flex ne porte pas de hauteur ni de marge verticale, afin de limiter l'espace au-dessus du bloc;
- les cartes internes `Nouveautes` utilisent une grille compacte avec un nombre de colonnes explicite egal au nombre de cartes jeu, pour rester en ligne sur desktop;
- l'ecart horizontal entre cartes `Nouveautes` est aligne sur la gouttiere desktop `gx-sm-4` des widgets de la ligne precedente;
- aucun breakpoint intermediaire ne force plus 2 colonnes sur tablette/viewport reduit; seule la bascule mobile sous `768px` passe en colonne unique;
- les conditions d'affichage, les contenus remontes et les liens des cartes `Nouveautes` restent inchanges.

Fichiers de reference:
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- widget Nouveautes: `pro/web/ec/modules/widget/ec_widget_home_latest_game_news.php`.

## Etat 2026-06-08 - First_party Home jour J

Le widget Home `first_party` devient actionnable le jour de la premiere date officielle first_party, sans modifier le pivot.

Comportement contractuel:
- avant le jour J, le widget conserve les copies `Ta première soirée Cotton est prête !` / `Ton premier événement Cotton est prêt !` et le CTA de consultation du pivot;
- le jour J avec offre active, le widget affiche `C’EST LE JOUR J`, oriente vers `Ouvrir mes sessions` ou `Ouvrir ma session`, et conserve la destination pivot `/extranet/onboarding/first-party`;
- le jour J sans offre active, le widget conserve aussi la destination pivot pour que l'utilisateur puisse revenir a ses sessions;
- le jour J sans offre active, le CTA devient `Voir mes sessions` ou `Voir ma session`, tandis que la copie rappelle la formule adaptee;
- le contexte `venue` parle d'essai gratuit adapte au lieu, le contexte `event` parle de formule adaptee au premier evenement sans wording essai gratuit;
- le recap de droite conserve date, nombre/type de sessions et horaires/titres, avec le label `AUJOURD’HUI` le jour J;
- les sessions affichees restent celles de la premiere date officielle future uniquement, sans melanger les dates ulterieures;
- la Home demande jusqu'a 50 sessions de cette premiere date pour fiabiliser singulier/pluriel et recap.

Fichiers de reference:
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- widget Home first_party: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`;
- helpers first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`.

## Etat 2026-06-08 - First_party reprise INS post-date

La regle first_party distingue maintenant un compte prospect `INS` d'un compte actif `ABN` / `PAK` apres passage d'une date officielle.

Comportement contractuel:
- un `INS` reste eligible first_party meme si une session officielle passee existe;
- un `INS` avec sessions futures ou jour J conserve le widget pret et le pivot;
- un `INS` sans session future mais avec sessions officielles passees voit un widget de reprise sur la Home;
- ce widget renvoie vers le tunnel first_party pour choisir une nouvelle date et recreer des sessions propres;
- les anciennes sessions passees ne sont pas supprimees automatiquement;
- `ABN` / `PAK` actifs avec session officielle passee ne recoivent pas de relance first_party automatique;
- les sessions futures restent limitees a la premiere date officielle future.

Fichiers de reference:
- helpers first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- widget Home first_party: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`.

## Etat 2026-06-08 - First_party jour J et confirmation activation

Le pivot `/extranet/onboarding/first-party` distingue maintenant la preparation avant la premiere date officielle future et le jour J.

Comportement contractuel:
- avant la date, le pivot reste centre sur personnalisation, test, communication, QR/liens et activation si necessaire;
- le jour J, le hero affiche `C’est le jour J !` et rappelle que les sessions se lancent depuis cette page;
- avant le jour J, un compte avec offre active voit un bloc neutre `Tes sessions sont prêtes` et ne voit plus de CTA de choix d'offre;
- sans offre active, le hero propose `Choisir ma formule d’essai gratuit` en contexte `venue`, ou `Choisir ma formule` en contexte `event`;
- avec offre active, le hero ne propose pas de CTA d'offre et les cartes sessions portent l'action `Ouvrir le jeu`;
- sans offre active, les cartes sessions restent accessibles en `Personnaliser et tester`;
- la section `Derniers conseils` est placee avant la communication et rappelle que le QR de session est affiche dans l'interface de jeu;
- la section communication reste complete le jour J, Media Kit inclus, apres les conseils;
- le QR permanent du pivot reste presente comme acces a l'agenda Cotton et aux prochaines sessions, pas comme QR direct de jeu;
- la confirmation d'offre utilise la meme logique durable que la Home first_party: si le compte est eligible avec sessions futures, elle remplace `Nouvelle session` par un retour au pivot; si le compte est eligible sans session future, elle renvoie vers le tunnel;
- le checkout ne pose plus de contexte temporaire `first_party_checkout_context_{id_client}` et ne depend plus de `from=first_party` pour choisir la carte success;
- hors eligibilite durable first_party, la confirmation d'offre conserve le comportement `Nouvelle session`.

Fichiers de reference:
- pivot first_party: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- checkout offres: `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_1.php`, `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php`, `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`, `pro/web/ec/modules/ecommerce/offres/ec_offres_script_paiement_cb.php`;
- carte confirmation/session: `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`.

## Etat 2026-06-08 - First_party par historique officiel et premiere date future

Le tunnel `/extranet/onboarding/first-party` repose maintenant sur l'historique officiel du compte: tant qu'un compte `INS`, `ABN` ou `PAK` eligible n'a aucune session officielle passee, ses premieres sessions officielles futures forment sa premiere soiree ou son premier evenement.

Comportement contractuel:
- les comptes `INS` eligibles, `ABN` actifs et `PAK` actifs sont exclus des qu'une session officielle prise en compte est strictement anterieure a aujourd'hui;
- une session officielle prise en compte est non demo, configuration complete, en ligne, avec une date exploitable;
- le mode `preparation` est affiche sans historique officiel passe et sans session officielle future;
- le mode `pret` est affiche sans historique officiel passe avec au moins une session officielle future, meme creee hors tunnel;
- la Home et la page pivot affichent uniquement les sessions officielles de la premiere date future;
- les dates futures suivantes ne sont pas melangees au pivot first_party;
- `created_session_ids` peut encore servir au flux courant apres creation, mais ne qualifie plus durablement l'eligibilite ou le mode pret;
- le widget historique Home `Lance ta première animation` est masque lorsque le widget first_party est visible;
- les modales agenda et bibliotheque reutilisent les copies first_party selon le contexte `venue` / `event`;
- le pivot d'un compte actif ne propose ni formule, ni essai gratuit, ni commande finale; il affiche un bloc neutre `Tes sessions sont prêtes`.

Fichiers de reference:
- helpers first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- tunnel/pivot: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- garde date: `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`.

## Etat 2026-06-08 - First_party bibliotheque: selection prete a l'etape 3

Depuis la bibliotheque EC Pro, une playlist Blind Test/Bingo ou un quiz valide peut servir de point de depart au tunnel `/extranet/onboarding/first-party` sans creer de session officielle a l'ouverture de la modale.

Comportement contractuel:
- les modales agenda restent generiques, car aucun contenu n'est choisi;
- les modales bibliotheque mentionnent explicitement la playlist ou le quiz choisi et confirment seulement l'entree dans le tunnel first_party;
- la creation officielle reste reservee a la validation finale du tunnel;
- une selection bibliotheque seed l'etat temporaire `first_party_onboarding_v1_{id_client}` et redirige directement vers l'etape 3;
- l'etape 3 affiche la selection en premiere session, meme si le contenu ne figure pas dans le mini-catalogue auto;
- si l'utilisateur revient a l'etape 2 et choisit 2 ou 3 sessions, la premiere session conserve la selection bibliotheque et les sessions suivantes sont generees automatiquement;
- en Quiz, le clic `Créer un Cotton Quiz` conserve le builder bibliotheque: la modale first_party apparait seulement a la validation du builder, et l'ordre des series est preserve;
- l'intro de l'etape 3 indique que la selection est prete, propose un lien vers l'etape 2 pour adapter le rythme, puis laisse valider le theme ou les themes;
- le CTA d'etape 3 devient `Valider ce thème` pour Blind Test/Bingo avec une seule session, sinon `Valider ces thèmes`;
- le message d'aide reseau de l'etape 3 est masque pour une selection bibliotheque seule, mais peut reapparaitre si le rythme ajoute des sessions auto;
- en contexte first_party, le filtre bibliotheque `mine` masque la carte d'ajout de contenu perso lors d'une modification de playlist/serie.

Fichiers de reference:
- helpers first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- tunnel first_party: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`, `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`, `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`.

## Etat 2026-06-08 - First_party Quiz: presentation par serie

Dans le tunnel `/extranet/onboarding/first-party`, l'etape 3 conserve l'auto-selection Quiz mais presente chaque session sous une forme dediee:
- une seule miniature d'illustration pour la session, calculee via `app_jeu_get_detail(5, ..., $lot_ids)` afin de reutiliser le choix de visuel multi-series existant;
- une liste des series thematiques auto-selectionnees avec titre, descriptif et badges existants;
- un CTA `Modifier` par serie, sans CTA global de modification sur la session Quiz.

Comportement contractuel:
- le clic `Modifier` d'une serie ouvre le mini-catalogue integre du tunnel;
- le mini-catalogue s'ouvre alors sous la serie ciblee et se comporte comme une selection unique: il surligne la serie ciblee, affiche la serie courante et les candidates, masque les autres series conservees, puis la selection suivante remplace uniquement le slot de cette serie dans la session;
- en mode modification, le mini-catalogue affiche la thematique selectionnee + 11 thematiques disponibles, en excluant les contenus deja selectionnes dans les autres sessions en cours de programmation;
- apres choix, le mini-catalogue se referme pour tous les jeux; en Quiz, la page se recentre sur la serie modifiee;
- dans la bibliotheque appelee depuis `from=first_party`, la liste et la fiche detail affichent le wording dynamique `première soirée` ou `premier événement` selon le contexte du compte.
- le lien `Voir plus de séries thématiques` conserve le contexte `from=first_party`, `session_index` et `slot_index` vers le catalogue complet;
- le recapitulatif affiche la meme presentation Quiz image unique + liste, sans CTA inactif;
- Blind Test/Bingo conservent la modification globale de session existante.

## Etat 2026-06-05 - First_party: contenus personnels et edition themes

L'etape 3 du tunnel `/extranet/onboarding/first-party` garde son catalogue volontairement reduit, mais signale que les contenus personnels peuvent etre crees depuis le menu `Les jeux`.

Comportement contractuel:
- l'astuce est affichee dans le panneau `Modifier` de chaque session;
- elle parle de playlists pour Blind Test/Bingo et de series thematiques pour Cotton Quiz;
- elle conserve le contexte `première soirée` pour `venue` et `événement` pour `event`;
- le lien `Les jeux` pointe vers la liste personnelle du jeu choisi via `clib_theme_mine_list_url_get($selected_game)`, avec fallback generique `/extranet/games/library`;
- la liste de choix manuel affiche les contenus personnels compatibles avant les contenus reseau/recommandes existants, dans une seule liste sans section personnelle dediee;
- la liste visible de modification est bornee a 12 contenus maximum par panneau, dont 2 contenus personnels maximum, les plus recemment crees;
- un lien de bas de mini-catalogue envoie vers la bibliotheque du jeu: `Voir plus de playlists` pour Blind Test/Bingo, `Voir plus de séries thématiques` pour Quiz;
- la bibliotheque conserve le contexte `from=first_party`, `session_index` et `slot_index` Quiz;
- les liens de fiche detail de la bibliotheque reinjectent ce contexte pour que le CTA reste `Choisir` apres navigation;
- en contexte first_party, la fiche detail bibliotheque affiche le CTA `Choisir`;
- la selection catalogue POST `content_library_first_party_choose` remplace uniquement le contenu temporaire dans `$_SESSION[first_party_onboarding_v1_{id_client}]`, puis renvoie sur l'etape 3;
- chaque serie Quiz auto affiche un CTA `Modifier` qui ouvre le mini-catalogue integre du tunnel et cible le slot de la serie;
- l'auto-selection initiale reste basee sur les contenus recommandes/reseau existants;
- la bibliotheque agenda officielle reste reservee aux sessions deja creees, car elle depend d'un `id_securite_session` et modifie directement les sessions officielles.

## Etat 2026-06-05 - First_party: annulation pivot

L'annulation confirmee depuis le pivot `/extranet/onboarding/first-party` vide maintenant l'etat temporaire du tunnel avant de quitter la page.

Comportement contractuel:
- la cle de session `first_party_onboarding_v1_{id_client}` est remise a l'etat par defaut apres suppression effective des sessions;
- la redirection vers la Home utilise `redir('/extranet/dashboard')`, qui gere aussi le cas ou des sorties HTML ont deja ete envoyees;
- un retour manuel dans le tunnel apres annulation repart donc sur des etapes vierges.

## Etat 2026-06-05 - First_party: finitions premier evenement

La variante `event` du parcours first_party des comptes `INS` non CHR parle maintenant de `premier événement` pour rester coherente avec la disparition du widget une fois les sessions programmees passees.

Comportement contractuel:
- le widget Home affiche `Prépare ton premier événement Cotton` puis `Ton premier événement Cotton est prêt !`;
- les copies du tunnel, du pivot et des controles de programmation utilisent `premier événement` en contexte `event`;
- dans la carte pivot `Partage les liens des sessions`, les intitules de sessions cliquables forcent la couleur de typologie first_party;
- la modale d'annulation affiche une phrase de relance contextualisee;
- apres annulation confirmee, le tunnel redirige vers `/extranet/dashboard`.

## Etat 2026-06-05 - First_party: couleurs/offres/controles par typologie

Le tunnel et le widget Home `first_party` suivent maintenant la couleur principale deja utilisee par les widgets ecommerce INS de la Home:
- CHR / lieux publics: `btn-color-20`;
- evenement: `btn-color-22`;
- particulier: `btn-color-21`.

Comportement contractuel:
- `ec_first_party_typology_color_id_get(...)` et `ec_first_party_typology_button_class_get(...)` centralisent le mapping couleur;
- `ec_first_party_typology_offer_url_get(...)` centralise l'URL d'offres du CTA pivot `Choisir ma formule` selon `id_typologie`;
- le widget Home first_party et le tunnel/pivot portent une classe couleur typologie et des variables CSS first_party;
- les CTA principaux du tunnel utilisent la classe bouton typologie, y compris le CTA final de formule;
- les controles qui bloquent la programmation officielle avant le parcours first_party et ceux qui forcent une nouvelle date apres la premiere session officielle future s'appliquent a tous les comptes `INS` eligibles hors siege reseau/restreint;
- les messages de blocage restent `premiere soiree` pour la variante `venue` et deviennent `evenement` pour la variante `event`.

Fichiers de reference:
- helpers first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- Home/widget: `pro/web/ec/modules/communication/home/ec_home_index.php`, `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`;
- tunnel/pivot: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- controles programmation: `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`, `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`, `pro/web/ec/modules/tunnel/start/ec_start_script.php`, `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`.

## Etat 2026-06-05 - First_party: extension event pour INS non CHR

Le tunnel `/extranet/onboarding/first-party` est maintenant commun a deux variantes:
- `venue` pour les comptes `INS` CHR / lieux publics deja eligibles;
- `event` pour les autres comptes `INS` eligibles, hors sieges reseau/restreints.

Comportement contractuel:
- `ec_first_party_context_get(...)` porte le choix `venue` / `event`;
- la variante `venue` conserve le vocabulaire premiere soiree, l'essai gratuit, le QR permanent de lieu et les gardes de programmation CHR existants;
- la variante `event` affiche `Prépare ton événement Cotton`, `Ton événement Cotton est prêt !` et oriente la sortie vers personnalisation, test, informations participants, Media Kit et liens dedies des sessions;
- la variante `event` ne parle pas d'essai gratuit, de QR permanent, de rentabilite d'etablissement, de clients ou de consommation;
- la creation finale, les sessions officielles, la priorite des contenus reseau, les demos et la page pivot restent sur le tunnel commun;
- les evenements dataLayer existants conservent leur nom et recoivent `first_party_context`.

Fichiers de reference:
- helpers first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- Home: `pro/web/ec/modules/communication/home/ec_home_index.php`, `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`;
- tunnel/pivot: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-05 - First_party: priorite contenus reseau etape 3

Dans le tunnel `/extranet/onboarding/first-party`, l'etape 3 priorise les contenus deja selectionnes par la tete de reseau quand le compte `INS` CHR courant est affilie a un reseau.

Comportement contractuel:
- un affilie reseau est identifie par `id_client_reseau > 0` et different de l'ID client courant;
- les contenus reseau compatibles sont ceux retournes pour ce client par `clib_network_share_ids_for_scope_get('affiliate', $game, $client_detail)`;
- les contenus reseau sont relus comme objets catalogue du jeu choisi, puis affiches avant les contenus `A la une` Cotton/Communaute;
- l'auto-selection de 1, 2 ou 3 sessions consomme d'abord ces contenus reseau compatibles, puis complete avec le fallback `A la une` existant;
- si un meme contenu existe aussi dans `A la une`, il n'est affiche qu'une fois et conserve son statut reseau;
- l'etape 3 affiche le badge `Sélection de ton réseau` et un court texte d'aide uniquement quand au moins un contenu reseau compatible existe;
- sans reseau affilie ou sans contenu reseau compatible, le comportement reste celui du fallback `A la une`;
- aucun changement n'est apporte aux widgets Home, a la programmation hors tunnel, a l'essai gratuit, a la creation de sessions, a l'eligibilite, aux offres, a la facturation ou aux regles de date.

Fichiers de reference:
- tunnel first_party: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- helpers bibliotheque reseau: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`.

## Etat 2026-06-05 - First_party: programmation standard apres premiere soiree

Pour les comptes `INS` CHR, la programmation officielle hors tunnel first_party est maintenant bornee autour de la premiere soiree officielle future.

Comportement contractuel:
- l'eligibilite `INS` CHR reste limitee au pipe `INS`, aux typologies CHR `1/8`, hors siege reseau;
- avant toute session officielle future complete et en ligne, les tentatives de programmation officielle hors tunnel sont redirigees/interceptees vers `/extranet/onboarding/first-party`;
- les CTA naturels de programmation en bibliotheque/fiche thematique restent visibles: le blocage se fait au submit serveur avec une notice douce;
- les demos restent accessibles a tout moment;
- des qu'une premiere session officielle future complete et en ligne existe, les URLs de programmation standard redeviennent accessibles;
- la premiere soiree de reference V1 est la premiere session `championnats_sessions` du client avec `flag_session_demo=0`, `flag_configuration_complete=1`, `online=1`, `DATE(date) >= CURDATE()`, triee par `date ASC, heure_debut ASC, id ASC`;
- tant que cette premiere soiree est future, toute programmation officielle a une date `<=` cette date est refusee cote serveur;
- en multi-date agenda quick, si une occurrence est interdite, toute la soumission est refusee avant creation de sessions;
- le choix de date affiche un message avec lien `Voir ma soirée` vers `/extranet/onboarding/first-party` et applique un garde front `minDate = premiere_soiree + 1 jour` quand c'est simple;
- apres passage de la premiere date officielle future, aucune date de reference n'est trouvee et la programmation standard est restauree;
- aucune migration SQL, aucun marqueur DB `first_party`, aucune modification d'offre, d'essai gratuit ou de facturation n'est introduite.

Fichiers de reference:
- helpers first_party: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- CTA globaux: `pro/web/ec/ec.php`, `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`;
- bibliotheque/fiche: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`, `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`;
- validation date: `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- choix date front: `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`;
- pivot first_party: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-05 - Pivot first_party: confirmation modale annulation

Sur la page pivot `/extranet/onboarding/first-party`, l'annulation de la premiere soiree demande toujours une confirmation explicite.

Comportement contractuel:
- le lien `Annuler cette soirée` ouvre une modale Bootstrap coherente avec les autres modales du tunnel;
- la confirmation est demandee meme quand aucune participation n'est encore rattachee aux sessions;
- quand des participations existent, la modale affiche un avertissement specifique indiquant que les joueurs ne verront plus ces sessions dans l'agenda;
- le submit de confirmation transmet `confirm_cancel_with_players=1`;
- le serveur refuse l'annulation si cette confirmation explicite est absente;
- l'annulation continue de supprimer les sessions officielles futures/non passees affichees via `app_session_supprimer(...)`;
- aucune regle d'eligibilite, de creation de session, d'essai gratuit ou d'offre n'est modifiee.

Fichier de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-05 - Home first_party: widget plus visible et rassurant

Le widget Home lie au tunnel `/extranet/onboarding/first-party` reste non bloquant, mais devient plus visible et plus rassurant pour les prospects `INS` CHR.

Comportement contractuel:
- l'eligibilite et le choix d'etat restent portes par `ec_home_index.php` et les helpers `first_party` existants;
- sans session officielle future/non passee, le widget affiche `Prépare ta première soirée Cotton`, un texte de parcours guide, la micro-rassurance `Parcours guidé · Annulable · Modifiable` et le CTA `Démarrer ma préparation →`;
- avec une premiere soiree programmee, le widget affiche `Ta première soirée Cotton est prête !`, un texte oriente venue des premiers joueurs/supports/partage/test, la micro-rassurance `Supports · Partage · Test` et le CTA `Faire venir mes joueurs →`;
- les deux etats conservent le CTA vers `/extranet/onboarding/first-party`;
- toute la carte est un lien unique vers `/extranet/onboarding/first-party`; le CTA interne est un element visuel non imbrique;
- sans session officielle future/non passee, un mini-visuel CSS leger en trois intentions est affiche a droite sur desktop et passe sous le texte sur mobile, sans mention `En 3 étapes` ni numerotation;
- les intentions utilisent des pictos SVG locaux doux pour eviter l'effet tunnel obligatoire;
- avec une premiere soiree programmee, le widget reutilise les sessions deja chargees par la Home pour afficher un resume concret avec le titre `Ta soirée programmée`: date si disponible, nombre de sessions, jeu principal si commun, puis jusqu'a trois lignes horaire + titre/theme;
- pour les sessions Cotton Quiz, les libelles compacts du resume gardent le contexte jeu, par exemple `Cotton Quiz 1 série` ou `Cotton Quiz 4 séries`;
- si plus de trois sessions sont programmees, le resume ajoute une ligne `+ x autre(s) session(s)`;
- si les details de session sont incomplets, le resume conserve un libelle robuste `Sessions programmées` / `Détail disponible dans la préparation` sans afficher de champ vide;
- le resume programme ne contient pas de lien secondaire, car toute la carte est deja cliquable;
- aucune regle d'eligibilite, de creation de session, d'essai gratuit, de facturation ou de priorisation reseau n'est modifiee.

Fichiers de reference:
- orchestration Home: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- widget Home: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`.

## Etat 2026-06-05 - Programmation: datepicker Cotton first_party et agenda quick

Les ecrans de programmation EC Pro utilisent le meme composant de date Cotton que la programmation depuis la bibliotheque.

Comportement contractuel:
- dans le tunnel `first_party`, etape 4, `party_date` utilise `flatpickerdatetime` avec le theme Cotton;
- l'etat initial first_party propose une date a J+5;
- les horaires first_party sont selectionnes via listes au quart d'heure, avec valeurs POST `HH:MM`;
- les horaires par defaut first_party sont `19:00`, `19:45`, `20:30`;
- dans `/extranet/start/game/setting/?from=agenda&mode=quick`, les dates libres et la date de fin de recurrence utilisent aussi `flatpickerdatetime`;
- les lignes de dates libres ajoutees apres chargement initialisent le meme datepicker.

Fichiers de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`.

## Etat 2026-06-05 - Home Nouveautes: pastilles jeu mobiles

Le widget Home `Nouveautés Cotton` conserve ses pastilles jeu sur les images, mais leur rendu mobile est borne pour eviter les debordements.

Comportement contractuel:
- les libelles longs comme `Bingo Musical` et `Cotton Quiz` restent dans la largeur de l'image;
- si l'espace est insuffisant, le texte est tronque avec ellipsis plutot que de sortir du conteneur;
- sous `575.98px`, les pastilles ont un padding et une taille reduits.

Fichier de reference:
- `pro/web/ec/modules/widget/ec_widget_home_latest_game_news.php`.

## Etat 2026-06-05 - Home: exclusion Nouveautes si first_party visible

La Home EC priorise le widget `first_party` sur le widget `Nouveautés Cotton`.

Comportement contractuel:
- le widget `ec_widget_home_first_party_onboarding.php` reste pilote par ses flags d'affichage onboarding/preparation;
- un booleen commun `$home_first_party_widget_visible` represente le fait que ce widget sera affiche;
- `ec_widget_home_latest_game_news.php` est desactive des que ce booleen est vrai;
- l'exclusion ne recopie pas la regle d'eligibilite `first_party`, afin de suivre automatiquement ses futurs elargissements.

Fichier de reference:
- `pro/web/ec/modules/communication/home/ec_home_index.php`.

## Etat 2026-06-05 - Agenda sessions: CTA preparation avant fenetre active

Dans l'agenda EC Pro, les cartes de sessions officielles programmables utilisent un libelle de CTA base sur la fenetre temporelle de la session, pas sur la presence d'une offre active.

Comportement contractuel:
- pour une session officielle non archivee de type Blind Test `4`, Cotton Quiz `5` ou Bingo Musical `6`, avant la fenetre active, le CTA affiche `Préparer`;
- l'affichage de `Préparer` ne depend pas de `app_session_launch_guard_get(...)` ni d'une offre effective active;
- quand la fenetre active est ouverte, le CTA affiche `Ouvrir le jeu`;
- l'icone launcher existante est conservee;
- apres la fenetre, le comportement archive/resultats existant reste conserve.

Fichier de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`.

## Etat 2026-06-05 - First_party: thematiques choisies allegees

Dans le tunnel `/extranet/onboarding/first-party`, les thematiques choisies aux etapes 3 et 5 sont affichees comme contenu de session, sans effet de mini-carte grisee.

Comportement contractuel:
- les cartes de session conservent leur encadrement;
- les thematiques choisies n'ajoutent plus de fond gris, bordure ni padding dedies;
- quand une session n'a qu'une seule thematique, celle-ci occupe toute la largeur disponible;
- le recapitulatif conserve la note de personnalisation/test, mais comme texte simple du bloc sans border ni padding.

Fichier de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-05 - Pivot first_party: CTA formule responsive mobile

Le footer `Ta formule d'essai gratuit` de `/extranet/onboarding/first-party` garde son CTA principal vers le choix de formule, mais son rendu mobile est maintenant explicitement contraint dans la carte.

Comportement contractuel:
- le libelle complet `Choisir ma formule d'essai gratuit` reste affiche sur desktop;
- sur mobile, le libelle court `Choisir ma formule` evite un retour de ligne desequilibre;
- le bouton reste centre, pleine largeur mobile et borne au conteneur;
- le style mobile reduit legerement padding et taille de police pour eviter les debordements;
- l'URL et la logique d'annulation de la soiree ne changent pas.

Fichier de reference:
- `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-04 - First_party: recapitulatif integre en etape 5

Le tunnel `/extranet/onboarding/first-party` integre le recapitulatif comme une vraie etape avant la creation officielle des sessions.

Comportement contractuel:
- le parcours INS CHR reste borne a cinq etapes: jeu, rythme, themes, date/horaires, recapitulatif;
- l'etape 5 est affichee fermee dans le meme flux que les autres etapes tant qu'elle n'est pas atteinte;
- une fois l'etape 5 atteinte, les etapes 1 a 4 restent visibles sous forme fermee et modifiables via leurs actions locales;
- l'etape 5 affiche la date, le nombre de sessions, le jeu choisi, la synthese du rythme, les horaires et les contenus/themes par session;
- la validation finale visible est `Programmer ma soirée`;
- l'action secondaire globale de l'etape 5 est un unique `Recommencer`;
- les sessions officielles ne sont creees qu'apres ce POST final `create_sessions`;
- depuis l'etape 5, l'utilisateur peut revenir au jeu, au rythme, aux themes ou a la date/horaires sans perdre la session PHP temporaire `first_party_onboarding_v1_{id_client}`;
- la page pivot `Ta soirée Cotton est prête !` reste reservee a l'etat post-creation avec des sessions officielles futures/non passees.

Invariants:
- aucune nouvelle route;
- aucune migration SQL;
- aucune modification profonde de la logique metier de creation;
- aucun CTA `Retour au tableau de bord` n'est expose dans le tunnel de preparation;
- tracking `first_party_summary_view` conserve pour l'affichage du recapitulatif.

Fichier de reference:
- tunnel first_party: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-04 - Pivot first_party: page de preparation stabilisee

La page pivot `/extranet/onboarding/first-party`, affichee quand un compte `INS` CHR possede des sessions officielles futures/non passees, sert de page de preparation avant le jour J.

Comportement contractuel:
- le hero ne contient pas de CTA direct et rappelle seulement que le lancement officiel des sessions dependra de la formule d'essai gratuit choisie;
- les cartes de sessions sont entierement cliquables vers la preparation/test de la session et affichent un lien discret `Personnaliser et tester →`;
- pour les sessions Quiz, les cartes affichent les titres des series en liste compacte `Série N : titre` quand ils sont disponibles, avec fallback vers le libelle compact `N séries`;
- le vocabulaire visible parle de `participation(s)`, pas de joueurs inscrits/preinscrits;
- la section participants conserve trois cartes: Media Kit, liens d'inscription et QR code;
- la carte Media Kit ouvre une modale ciblee sur le Media Kit du jeu programme, avec un visuel adapte au jeu;
- la carte QR code reste entierement cliquable et accessible clavier, avec un lien discret en bas de carte;
- la carte liens d'inscription n'est pas cliquable globalement, expose une copie par session via icone et prefixe les sessions Quiz par `Cotton Quiz N séries`;
- la section `Le jour J, comment ça se passe ?` reste informative et legere: trois etapes compactes, un visuel unique a droite et deux astuces discretes;
- le bloc final `Ta formule d'essai gratuit` porte le CTA principal vers `/extranet/ecommerce/offers/abonnement/s1/1`;
- `Annuler cette soirée` reste une action secondaire; la confirmation existante est demandee uniquement si des participations existent;
- la mise en page evite les conteneurs imbriques trop visibles et utilise toute la largeur disponible de la page EC.

Invariants:
- aucune nouvelle route;
- aucune migration SQL;
- aucune modification du checkout ou de l'activation d'essai;
- aucune modification de la logique de copie, QR code, Media Kit, preparation/demo ou annulation.

Fichier de reference:
- pivot: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-04 - Preparation officielle Games sans offre active

Les sessions officielles futures/non passees peuvent etre ouvertes en mode preparation dans l'interface organisateur Games meme si le client n'a pas encore d'offre active.

Regles contractuelles:
- l'entree `/master/{token}` ne doit pas etre bloquee par l'absence d'offre pour une session officielle future/non passee;
- le lancement officiel reste conditionne a une offre active et a une fenetre active;
- `app_session_launch_guard_get(...)` reste le guard de lancement/offre, pas un guard d'entree en preparation;
- la remote officielle est indisponible tant que la session officielle n'est pas lancable;
- le CTA Games est contextuel: `Tester en démo` hors fenetre active, `Lancer le jeu` en fenetre active, avec modale offre requise si l'offre manque;
- la duplication demo reutilise le flux Pro `session_duplicate`; aucune synchronisation demo -> officielle n'est attendue;
- les liens Games issus du pivot `first_party`, de la fiche session et de la liste sessions portent `nav_ctx=first_party`, et le quit officiel/demo revient vers `/extranet/onboarding/first-party`;
- une demo dupliquee depuis une officielle est forcee non publiee et privee (`flag_session_demo=1`, `flag_session_privee=1`, `online=0`);
- la pivot `first_party` affiche `Préparer la session` et remet communication + activation au centre;
- l'annulation depuis la pivot supprime les sessions officielles futures/non passees affichees via `app_session_supprimer(...)`; une confirmation explicite n'est requise que si des joueurs sont inscrits ou preinscrits.

Fichiers de reference:
- `games/web/organizer_canvas.php`;
- `games/web/remote_canvas.php`;
- `games/web/games_ajax.php`;
- `games/web/includes/canvas/core/boot_organizer.js`;
- `games/web/includes/canvas/core/canvas_display.js`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`.

## Etat 2026-06-03 - First_party INS CHR: sessions futures et blocage hors parcours

Le mode preparation de premiere soiree des comptes `INS` CHR repose uniquement sur `championnats_sessions`.

Regles contractuelles:
- `INS` CHR + au moins une session officielle future/non passee: afficher le widget Home `Ta soirée Cotton est prête !` et la page pivot en mode preparation;
- `INS` CHR + uniquement des sessions officielles passees: ne pas afficher `Ta soirée est prête !`; le widget initial de premiere soiree redevient disponible;
- `INS` CHR + aucune session officielle: afficher le widget initial;
- une session officielle qualifiante est une session `flag_session_demo=0`, `flag_configuration_complete=1`, `online=1`, rattachee au client, avec `DATE(date) >= CURDATE()`;
- aucun log `first_party`, aucun `clients_logs` et aucune migration SQL ne servent de source de verite;
- la creation de nouvelles sessions officielles est bloquee hors parcours de premiere soiree pour `INS` CHR;
- la personnalisation des sessions officielles existantes, l'application de theme sur session existante, la consultation, le design, les demos et `session_duplicate` restent autorises;
- la demo est generee depuis l'officielle au moment du test; aucune synchronisation inverse demo -> officielle n'est attendue.

Fichiers de reference:
- helper source de verite: `pro/web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
- pivot: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- blocages serveur: `pro/web/ec/modules/tunnel/start/ec_start_script.php`, `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`.

## Etat 2026-06-03 - Onboarding premiere soiree: auto-pick moment/populaire

La proposition automatique des themes du tunnel `/extranet/onboarding/first-party` utilise maintenant deux sources catalogue:
- premier choix automatique: preset `now`, pour garder une thematique du moment;
- choix suivants: preset `themes` avec tri populaire, pour eviter d'empiler plusieurs contenus saisonniers sur une soiree a 2 ou 3 sessions.

Le pool affichable/modifiable reste calcule localement depuis `clib_list_get(...)` et deduplique les contenus `now` + populaires. Les validations serveur existantes restent la source de verite.

## Etat 2026-06-03 - Onboarding premiere soiree: UX Lot 2 ter

L'entree `/extranet/onboarding/first-party` conserve le perimetre Lot 2 bis, avec une UX stabilisee avant la programmation des horaires.

Comportement contractuel:
- une seule etape est affichee comme active;
- les etapes deja validees sont repliees en resume avec bouton `Modifier`;
- les etapes suivantes restent des resumes grises tant que les choix requis ne sont pas faits;
- apres validation des themes, la page affiche uniquement le recapitulatif final;
- le recapitulatif contient le jeu, le nombre de sessions, les intentions et les themes sous forme de mini-cartes;
- les miniatures de jeux utilisent la meme source que la home bibliotheque: `medias_url/statique/jeux/{seo_slug}/presentation/{seo_slug}.jpg`;
- les themes selectionnes affichent image, titre et description courte quand disponibles;
- les changements effectues dans un panneau `Modifier` sont refletes immediatement dans la zone compacte;
- les validations serveur du Lot 2 bis restent la source de verite.

Invariants:
- aucune creation de session officielle;
- aucun appel a `app_session_ajouter()`;
- aucun write dans `championnats_sessions`;
- aucun checkout, essai gratuit, QR code session joueur ou lien public reel.

Fichier de reference:
- entree tunnel: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-03 - Onboarding premiere soiree: Lot 3B creation officielle et pivot essai

Le CTA `Créer mes sessions` du tunnel `/extranet/onboarding/first-party` cree maintenant les sessions officielles configurees, puis affiche une page pivot post-creation centree sur l'activation de l'essai gratuit.

Comportement contractuel:
- la creation finale revalide tout l'etat temporaire avant ecriture;
- l'idempotence repose sur un `creation_token` et le stockage `created_session_ids` dans l'etat de session PHP;
- si `created_session_ids` existe deja, un refresh ou un retour navigateur affiche directement la page post-creation sans recreer de sessions;
- Blind Test cree une session `id_type_produit=4`, `flag_session_demo=0`, `id_produit` catalogue et `flag_configuration_complete=1`;
- Bingo Musical cree une session `id_type_produit=6`, genere une playlist client dans `jeux_bingo_musical_playlists_clients`, puis marque la session complete;
- Cotton Quiz cree une session `id_type_produit=5`, renseigne `id_produit` sur le premier lot et `lot_ids` avec les lots selectionnes, puis marque la session complete;
- les sessions utilisent `party_date` et `scheduled_time`, converti au format horaire historique `HHhMM`;
- si une creation echoue apres une premiere ecriture, le flux supprime les sessions creees et les playlists client Bingo creees afin d'eviter un etat incoherent;
- la page post-creation ne refait pas le gros recapitulatif: elle affiche un rappel synthetique, puis les blocs activation/outils, personnalisation, frais/realisme et premiers signaux;
- le CTA `Activer mon essai gratuit` pointe vers le flux existant `/extranet/ecommerce/offers/abonnement/s1/1`;
- aucun lien public operationnel, QR code agenda reel, Media Kit telechargeable ni outil de personnalisation n'est debloque dans ce lot.

Writes:
- `championnats_sessions`;
- `jeux_bingo_musical_playlists_clients` pour les sessions Bingo Musical;
- `championnats_sessions_lots` via l'initialisation standard des lots;
- `clients_logs` via les helpers existants de creation/suppression de session.

Fichier de reference:
- entree tunnel: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-03 - Onboarding premiere soiree: Lot 3A date et horaires

L'etape 4 du tunnel `/extranet/onboarding/first-party` collecte la date de soiree et les horaires indicatifs avant le recapitulatif de confirmation.

Comportement contractuel:
- l'etape 4 devient active apres validation des themes;
- la date et les horaires restent stockes dans l'etat temporaire de session PHP, sans creation de session officielle;
- les horaires par defaut sont `20:30`, `21:15`, `22:00`, soit environ 45 minutes entre sessions;
- les horaires sont indicatifs: ils servent surtout a informer les joueurs et n'empechent pas de lancer les sessions avant ou apres;
- l'avertissement communication s'affiche uniquement si la date choisie laisse moins de 5 jours complets pour communiquer;
- le message d'avertissement est non bloquant;
- a partir de 5 jours ou plus avant la soiree, aucun message d'avertissement ou de reassurance n'est affiche;
- le recapitulatif affiche la date au format francais lisible, par exemple `Dimanche 7 juin 2026`;
- le CTA `Créer mes sessions` reste non destructif dans le Lot 3A et ne cree aucune ligne `championnats_sessions`.

Invariants:
- aucun appel a `app_session_ajouter()`;
- aucun write dans `championnats_sessions`;
- aucun checkout, essai gratuit, QR code session joueur ou lien public reel.

Fichier de reference:
- entree tunnel: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.

## Etat 2026-06-03 - Onboarding premiere soiree: correctif Lot 2 bis

L'entree `/extranet/onboarding/first-party` conserve le parcours guide V1, avec un correctif sur le rythme et la selection des themes.

Comportement contractuel:
- l'etape 2 accepte `1`, `2` ou `3` sessions; `2` reste le choix recommande et le defaut serveur;
- valider l'etape 2 genere une proposition de contenus `A la une` pour chaque session;
- l'etape 3 affiche par defaut des cartes compactes par session avec les themes proposes;
- la liste complete des contenus n'est ouverte qu'apres clic sur `Modifier` pour la session concernee;
- pour Quiz, une session peut contenir 1 a 4 themes/lots;
- pour Blind Test et Bingo Musical, une session conserve un seul contenu/playlist;
- l'etat temporaire est normalise sous `sessions[index, content_ids[]]`;
- les anciens etats `content_ids` sont migres puis nettoyes au prochain passage;
- les doublons de contenu entre sessions sont rejetes cote serveur;
- aucune session officielle n'est creee, `app_session_ajouter()` n'est pas appele et `championnats_sessions` n'est pas modifie;
- aucun essai gratuit, checkout ecommerce, QR code session joueur ou lien public reel n'est modifie.

Note d'audit:
- le tunnel agenda historique possede des helpers d'auto-selection dans `pro/web/ec/modules/tunnel/start/ec_start_script.php`;
- ils sont lies a un handler qui cree ensuite des sessions officielles;
- l'onboarding V1 n'inclut pas ce handler et limite sa proposition aux contenus `A la une` via `clib_list_get(..., 'now')`.

Fichiers de reference:
- entree tunnel: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- helper catalogue reutilise: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`.

## Etat 2026-06-03 - Onboarding premiere soiree: parcours guide Lot 2 V1

L'entree `/extranet/onboarding/first-party` porte maintenant le debut du parcours guide de preparation d'une premiere soiree Cotton.

Comportement contractuel:
- l'etat temporaire est conserve en session PHP par compte connecte, sous `first_party_onboarding_v1_{id_client}`;
- l'etape 1 permet de choisir un seul jeu principal: Blind Test, Bingo Musical ou Quiz;
- l'etape 2 limite le rythme a `2` ou `3` sessions;
- l'etape 3 propose uniquement les contenus `A la une` du jeu selectionne;
- les contenus sont recuperes via `clib_list_get($seo_slug, $type, 0, '', 1, 12, 'now')`, pour `cotton` et `community`, puis dedupliques;
- la validation serveur rejette les jeux non autorises, les rythmes hors `2/3`, les contenus hors selection `A la une` et les doublons;
- le recapitulatif final affiche le jeu, le nombre de sessions et les themes retenus;
- le CTA `Programmer mes horaires` reste desactive tant que le Lot 3 n'est pas livre;
- aucune ligne `championnats_sessions` n'est creee et `app_session_ajouter()` n'est pas appele;
- aucun essai gratuit, checkout ecommerce, QR code session joueur ou lien public reel n'est modifie.

Fichiers de reference:
- entree tunnel: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;
- helper catalogue reutilise: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`;

## Etat 2026-06-03 - Home EC: onboarding premiere soiree INS CHR

La Home EC expose un bloc prioritaire `Prépare ta 1ère soirée Cotton` pour les comptes INS CHR sans session officielle deja configuree.

Comportement contractuel:
- l'eligibilite V1 est limitee a `client_pipeline_etat_nom === INS`;
- la typologie client doit etre `1` ou `8`, en coherence avec la logique EC abonnement existante;
- le compteur utilise `client_session_official_programmed_count`, donc uniquement les sessions officielles non-demo avec `flag_configuration_complete=1`;
- les sieges reseau sont exclus;
- le bloc est non bloquant et laisse la Home explorable;
- le CTA ouvre `/extranet/onboarding/first-party`;
- l'entree tunnel Lot 1 V1 affiche seulement la structure des prochaines etapes;
- aucune session n'est creee, aucun essai gratuit n'est active, le checkout ecommerce n'est pas modifie;
- le bloc pousse les evenements front `first_party_onboarding_view` et `first_party_onboarding_start` si le `dataLayer` est disponible.

Fichiers de reference:
- route: `pro/web/.htaccess`;
- integration Home: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- widget Home: `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`;
- entree tunnel minimale: `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`;

## Etat 2026-06-02 - Home EC: Nouveautes Cotton

La Home EC Pro expose un widget `Nouveautés Cotton` pour les comptes dont le pipe est `INS`, `ABN`, `PAK` ou `CSO`.

Comportement contractuel:
- le widget remonte au plus 3 cartes: une playlist Blind Test, une playlist Bingo Musical et une serie Quiz;
- les contenus proviennent des catalogues Cotton et Communaute, uniquement lorsqu'ils sont publies/visibles cote EC;
- les playlists Blind Test et Bingo Musical partagent la meme table catalogue et sont strictement dedupliquees par `id_playlist` / `source_id`;
- la selection Bingo exclut donc l'ID playlist deja retenu pour Blind Test, sans compenser par une seconde carte du meme usage;
- le tri de nouveaute utilise `community_items.published_at` quand disponible, puis `date_ajout DESC, id DESC`;
- les dates evenementielles `jour_associe_debut` / `jour_associe_fin` ne sont pas utilisees pour ce widget;
- chaque carte complete pointe vers la fiche detail bibliotheque EC de la thematique, pas vers une programmation ni un lancement de session;
- le widget ne propose pas de CTA global ni de lien catalogue secondaire: seul le texte `Découvrir →` reste visible dans les cartes;
- le chip du jeu reprend les couleurs EC existantes: Blind Test vert, Bingo Musical bleu, Quiz rose; le chip catalogue reste neutre;
- `INS` et `CSO` utilisent une variante large/editoriale; `ABN` et `PAK` utilisent une variante compacte sous les cartes principales.
- la variante compacte est synchronisee en desktop sur la largeur utile de la premiere ligne de cartes Home, via le mecanisme `home-grid-sync-col`;
- le widget est rendu comme une section legere sur le fond Home, sans wrapper blanc global; seules les cartes nouveaute restent blanches;
- la grille des cartes utilise toute la largeur disponible en desktop et se replie en 2 puis 1 colonne selon le viewport;
- l'espacement vertical du wrapper est reduit pour rester coherent avec les autres blocs Home;
- la recuperation ajoute une requete limitee pour les playlists Blind/Bingo, une requete limitee pour le Quiz et un check schema memoise; le rendu n'ajoute pas de requete SQL par carte.

Fichiers de reference:
- recuperation et rendu: `pro/web/ec/modules/widget/ec_widget_home_latest_game_news.php`;
- integration Home EC: `pro/web/ec/modules/communication/home/ec_home_index.php`.

## Etat 2026-05-21 - Webhook Stripe: feedback annulation abonnement

Le webhook Stripe PRO capture maintenant les retours utilisateur de resiliation d'abonnement:
- evenements concernes: `customer.subscription.updated` et `customer.subscription.deleted`;
- source Stripe: `subscription.cancellation_details.feedback`, `comment` et `reason`;
- destination: `user_feedback_events` via le helper global ecommerce;
- l'appel est idempotent et non bloquant pour ne pas perturber la synchronisation d'offre existante.

## Update 2026-05-22 - Webhook Stripe: date de demande resiliation
- le handler transmet maintenant `subscription.canceled_at` au helper global pour alimenter `user_feedback_events.created_at`;
- si `canceled_at` est absent, il transmet `event.created`;
- ce changement permet de journaliser aussi les resiliations Stripe sans feedback/commentaire, avec une date metier plus proche de la demande client.

# Etat 2026-05-14 - BO contrats reseau hors cadre, flux PRO inchange

Le correctif BO `reseau_contrats` sur les offres deleguees hors cadre ne modifie pas le flux PRO TdR:
- `Mon reseau` conserve le demarrage de commande via `start_delegated_hors_cadre_checkout`;
- le tunnel ecommerce PRO continue de creer une offre pending puis de rattacher l'offre payee hors cadre;
- les garde-fous PRO existants restent inchanges: legitimite TdR, affilie rattache, refus offre propre, refus delegation deja active.

# Repo `pro`

## Update 2026-09-03 - Cible Pro pour le futur changement d'offre

Le futur CTA `Modifier mon abonnement` doit lancer un parcours Cotton, pas un changement commercial dans le Customer Portal Stripe. Cotton calcule les évolutions autorisées et affiche jauge, périodicité, prix de référence, remise, prix net et avantage; une preview Stripe du prorata peut précéder la confirmation, puis Cotton ensure/crée le Price, met à jour la Subscription et attend le webhook de synchronisation.

La V1 des clients en propre impose une hausse stricte de jauge sans réduction de durée de période. La rupture historique supposée du changement via portail Stripe est documentée comme hypothèse à confirmer. Contrat complet: `canon/interfaces/ecommerce-offer-change.md`. Les offres déléguées hors cadre restent exclues.

## Update 2026-09-03 - Souscription et renouvellement réseau hors cadre

Pro reste l’unique point d’entrée utilisateur qui crée conjointement le checkout Stripe et l’offre Cotton déléguée hors cadre. Au renouvellement, le snapshot contractuel Stripe conserve l’assiette HT et la remise réseau courante peut réviser le net sur le même `id_offre_client`; `invoice.upcoming` est l’unique writer du Price, sans prorata, tandis que les autres événements restent sans repricing. Si ce write rencontre un 429, un timeout/incident réseau ou un 5xx Stripe, le webhook répond en échec pour obtenir une redelivery; succès, no-op et blocages fonctionnels conservent leur acquittement normal.

## Update 2026-09-02 - Home standard, Quick Schedule et routage Bibliothèque

Home EC et `/extranet/start/games` ouvrent `/extranet/start/games/quick-schedule` avec l'intention `generated_program`: jeu et contenu sont proposés automatiquement, les dates déjà occupées restent bloquées et la récurrence demeure disponible. La Bibliothèque générale et l'ajout depuis un Dashboard Hub explicite rejoignent le même écran avec l'intention distincte `fixed_content`: `source=library` n'est qu'une provenance et le contenu Blind Test, Bingo ou les séries Quiz sélectionnés restent autoritatifs. Le choix passe d'abord par `session_init`, conservé comme ancrage de version, type, offre et compatibilité; Quick Schedule reçoit ensuite l'identifiant de cette session préparée et les identifiants catalogue/Quiz, sans réutiliser l'ancien payload suggestif `library_content_ids/library_game`.

En `fixed_content` général, une date déjà occupée est valide et conserve un curseur sélectionnable; `generated_program` garde son jour désactivé. Le probe serveur distingue aucun Hub réellement programmé, un Hub unique ou plusieurs Hubs: une ligne vide ou temporaire sans session membre active et complètement configurée ne suffit plus à annoncer un Hub existant. Le nom reste modifiable pour une création; si un Hub unique existe, sa section reste visible avec son nom autoritatif en lecture seule et l'heure est masquée. Une ambiguïté exige un choix explicite et affiche ensuite le nom du Hub choisi sans permettre sa modification. La légende Date est retirée. Blind Test et Bingo exposent `Durée de la partie`, avec le même espacement supérieur que `Comment jouent les participants ?`; Quiz ne fabrique aucun choix de format et conserve sa règle métier, avec garde de compatibilité smartphone fondée sur les séries choisies. Programme et récapitulatif nomment le choix `Jeu · Thème`, puis un seul message près du CTA décrit création, ajout ou choix ambigu. Le POST partage CSRF, ownership, gardes compte/offre, validation date/format/mode et idempotence Quick Schedule. Le commit `SchedulePlan` fixe d'abord le Hub et l'heure; son writer réutilise `session_setting -> session_theme` uniquement pour configurer le contenu, sous un marqueur scoped qui interdit toute seconde résolution d'heure ou adhésion legacy. Le commit central écrit ensuite l'unique membership explicite `schedule_plan`; aucun rattachement concurrent n'est déplacé silencieusement. Le succès retourne toujours au Dashboard canonique.

Depuis un Dashboard Hub explicite, Quick Schedule rend une variante compacte `fixed_content`: aucun choix de nom, date, récurrence, jeu ou quantité; il présente le contenu autoritatif, la durée, le mode et le récapitulatif. Le serveur valide le Hub actif et propriétaire, impose sa date et calcule l'horaire suivant depuis son Programme; les valeurs navigateur sont ignorées. Annulation, retour et succès visent le même Dashboard grâce à l'identité Hub explicite, sans référent HTTP. Le renderer settings reste compatible pour les anciennes URLs directes et les parcours distincts de remplacement, démo, sessions existantes/autonomes, multiples/récurrentes, `resume` et `resume-batch`; il n'est plus le renderer de l'ajout courant depuis la Bibliothèque générale ou un Hub explicite. La Home ne bascule plus vers sa variante réduite `first_party` et tous les comptes self-service, y compris `INS`, utilisent la même grille standard. La navigation Pro reste conditionnée par le statut commercial du compte; la tête de réseau reste exclue du self-service.

La Home standard rend maintenant au plus deux grandes cartes sur sa première ligne, en une colonne mobile puis deux colonnes égales à partir de `md`: la programmation ou la date courante/future canonique, puis `LES JEUX COTTON`. Un historique seul est projeté sur cette surface vers `Programmer ma prochaine soirée` / `Programmer mon prochain événement`; les bilans, autres dates et ajouts supplémentaires restent dans `/extranet/games`. La seconde carte `Programmation`, `Mon agenda` et les cartes d'offre ne sont plus incluses dans la grille Home, sans supprimer leurs producteurs ni leurs accès spécialisés. Nouveautés commence dans une ligne distincte; feedback récent, alertes Stripe et contexte réseau affilié restent inchangés.

Le visuel de la carte contextuelle représente le Hub et non une session: Home et Dashboard partagent la résolution `app_games_hub_branding_get(...)` et le fallback `app_games_hub_branding_fallback_visual_get()`. Le producteur Home résout le Hub canonique existant sans le créer, utilise ses sessions membres pour conserver jusqu'à trois noms de jeux uniques en overlay, et ne sélectionne plus le visuel d'un jeu. Cette image reste identique pour le même Hub en futur, Jour J, en cours ou terminé le Jour J, sur mobile et desktop; seuls badge, texte et CTA suivent la temporalité.

Le CTA de programmation Home utilise directement `ec_programming_quick_schedule_url_get('home')` pour tout compte standard, indépendamment de l'usage et du nom de serveur; l'ancien modal `sessions_day_create` n'est plus un parcours atteignable. La carte Bibliothèque utilise une copie unique sans condition `INS/ABN/PAK/CSO`: `Découvre les jeux`, `Explore les thématiques`, `Retrouve tes contenus`, puis `Accéder aux jeux`. Pour une date prête aujourd'hui, l'offre effective canonique ne change pas la destination Dashboard Hub: l'actif parle de diffusion et lancement sur desktop, de préparation et lancement sous `992px`; en cours, le titre contextualisé est en capitales et l'aide distingue reprise de la diffusion sur desktop et reprise de la soirée/l'événement sur mobile. Les CTA `Ouvrir` et `Reprendre` ne changent pas. Futur, Jour J, en cours et terminal continuent de venir du producteur temporel existant.

Le Dashboard ouvert avec `?from=home` affiche `← Retour à l'accueil` vers `/extranet/dashboard` et conserve ce contexte sur les rafraîchissements ou retours d'ajout internes nécessaires. Une entrée Agenda/directe conserve `← Retour à mon agenda`. Ce contrat ne repose pas sur `HTTP_REFERER` et ne propage pas `from=home` vers Master, Remote ou les URLs session. La branche Home TdR, ses raccourcis et outils réseau ne changent pas.

## Etat 2026-05-18 - Bibliotheque Quiz: difficulte 3 niveaux et legacy

La bibliotheque EC Pro expose 3 choix de difficulte pour les thematiques Quiz et conserve cette convention pour les nouvelles sauvegardes.

Comportement contractuel:
- a la lecture Quiz, `1` s'affiche `Facile`, `2` s'affiche `Moyen`, `3` s'affiche `Difficile`;
- les anciennes valeurs `4` ou `5` sont temporairement relues comme `Difficile`, pour eviter une regression avant migration de donnees;
- l'editeur de thematique preselectionne le choix normalise, sans retomber a `Facile` pour une ancienne valeur haute;
- a l'enregistrement Quiz, les choix UI sont stockes directement: `Facile=1`, `Moyen=2`, `Difficile=3`;
- les series historiques doivent etre normalisees par patch donnees dedie et borne au perimetre legacy: ancien `3 -> 2`, anciens `4/5 -> 3`;
- Blind Test et Bingo Musical restent sur leur cotation directe `1..3`.

Fichiers de reference:
- normalisation bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`;
- editeur de thematique: `pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_edit.php`;
- sauvegarde editeur: `pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_save.php`;
- adapter Quiz: `pro/web/ec/modules/jeux/bibliotheque/sources/quiz_series.php`.

## Etat 2026-05-18 - Home EC TdR: recommandations formats image de marque

La modale `Mettre à jour mon image de marque` de la Home EC TdR affiche maintenant des recommandations directement sous les titres `Logo` et `Visuel principal`.

Comportement contractuel:
- le logo recommande un format carre, idealement `512 x 512 px`;
- le visuel principal recommande une image horizontale, idealement `1600 x 900 px`;
- les contraintes techniques d'upload existantes restent affichees separement: extensions acceptees et poids max serveur.

Fichier de reference:
- home EC TdR: `pro/web/ec/modules/communication/home/ec_home_index.php`.

## Etat 2026-05-18 - Bibliotheque Cotton: ordre des thematiques du moment

Dans la bibliotheque EC Pro des contenus Cotton certifies, le preset `A la une` / `now` conserve le perimetre initial de la liste, priorise les contenus dont la date du jour est comprise dans la fenetre `jour_associe_debut` / `jour_associe_fin`, puis applique la creation recente uniquement comme departage entre ces contenus du moment.

Comportement contractuel:
- le filtre `A la une` n'est pas elargi par la date de creation;
- entre plusieurs contenus Cotton simultanement "du moment", l'ordre est maintenant la date de creation catalogue la plus recente: `date_ajout DESC`, puis `id DESC`;
- les contenus Cotton hors periode gardent le departage historique par popularite;
- le tri Communaute `A la une` reste base sur la popularite.

Fichier de reference:
- liste bibliotheque: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`.

## Etat 2026-05-18 - Playlist perso: artistes courts

Le flux d'ajout et de verification des playlists perso accepte les noms d'artistes courts mais non vides, par exemple `U2`.

Comportement contractuel:
- le signal `Nom d’artiste incomplet` est reserve a un champ artiste vide;
- un artiste de 1 ou 2 caracteres n'est plus marque douteux sur ce seul critere;
- les autres signaux restent inchanges: lien media manquant, titre manquant, termes YouTube ambigus (`topic`, `release`, `various artists`, etc.), separateurs/parentheses a nettoyer et incoherence possible avec le nom de chaine YouTube.

Fichiers de reference:
- analyse initiale playlist perso: `pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlist_analyze.php`;
- source/import contenus playlist: `pro/web/ec/modules/jeux/bibliotheque/sources/playlists_content.php`;
- affichage et recalcul des lignes a corriger: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`.

## Etat 2026-05-15 - Preview et import DB minimal Markdown Cotton Quiz

Le PRO expose une surface admin reservee au compte Cotton `id_client=10` pour previsualiser puis importer en DB une serie Cotton Quiz depuis un fichier source Markdown valide.

Comportement contractuel:
- l'URL `/extranet/games/import/quiz` passe par le shell PRO connecte et refuse tout compte dont `$_SESSION['id_client'] !== 10`;
- le fichier `.md` ou le texte colle est parse et affiche d'abord en preview des champs detectes;
- si la preview ne contient aucune alerte bloquante, un CTA explicite `Importer la serie en DB` est affiche apres confirmation utilisateur;
- l'import DB minimal cree la serie, les questions, les mauvaises propositions et les supports valides en preview;
- l'import DB minimal ne pilote plus `flag_begin`, `flag_une` ni `online` sur `questions_lots`; les tris `A la une` s'appuient sur `jour_associe_debut/fin`, et le statut d'affichage Quiz reste porte par `id_etat=2`;
- l'illustration de thematique est telechargee au moment de l'import, verifiee, puis ecrite en `.jpg` dans le chemin attendu par la bibliotheque PRO: `cotton_quiz/images/jeux_cotton_quiz/questions_lots/{id_lot}.jpg`;
- si une serie existe deja avec le meme titre ou slug, le CTA peut reparer uniquement cette illustration locale, sans modifier les questions ni les propositions;
- les supports image de question sont telecharges au moment de l'import DB, valides comme images, ecrits dans `/upload/quiz/images/questions/question/`, puis remplaces dans `questions.lien_support` par une URL Cotton locale;
- les supports audio, video et YouTube ne sont pas telecharges: l'URL validee en preview est conservee comme lien support;
- les supports ne sont plus editables dans l'importeur PHP: toute correction doit etre faite dans le Markdown source ou dans la previsualisation editoriale de l'agent IA, puis la preview est relancee;
- la rubrique catalogue est lue depuis le champ `Rubrique` du Markdown et la page affiche si elle correspond a une ligne active de `questions_lots_rubriques`;
- la page signale les alertes de structure utiles: titre/rubrique manquants, rubrique inconnue, nombre de questions different de 6, question/propositions/bonne reponse/explication manquantes, support invalide;
- les series Cotton certifiees importables doivent contenir exactement 6 questions et une explication par question;
- le Markdown peut declarer des supports types via `Support type`, `Support`, `Support start`, `Support end` et `Note support`;
- types reconnus en preview et import DB minimal: `image`, `audio`, `video`, `youtube`, `youtube_audio`, `youtube_video`;
- pour les supports audio/video/YouTube, `Support start` et `Support end` sont ajoutes en preview a l'URL finale via les parametres `start` et `end`;
- pour les supports image, l'URL affichee en preview reste l'URL source du Markdown, mais l'import definitif stocke une copie locale Cotton et met a jour la question avec cette URL locale;
- l'illustration de thematique est affichee comme URL source/import candidate, puis importee comme visuel bibliotheque lors du CTA DB;
- les titres, textes secondaires, alertes et CTA sont surcharges localement pour rester lisibles sur le fond sombre de cette page.

Fichiers de reference:
- route: `pro/web/.htaccess`;
- page preview: `pro/web/ec/modules/jeux/import/ec_import_quiz.php`.

Historique:
- le 14/05/2026, cette page portait aussi un import DB avec upload automatique des images et edition des supports en session;
- le 15/05/2026, le flux est simplifie: preview obligatoire, CTA DB restaure apres preview valide, illustration de serie importee en visuel bibliotheque, mais plus d'edition des supports dans l'importeur;
- le 18/05/2026, l'import DB internalise a nouveau les supports image de question en les copiant dans le stockage Cotton, sans changer le comportement lien externe des supports audio/video/YouTube;
- le 18/05/2026, l'import DB arrete de forcer `flag_begin` et `flag_une` lors de la creation d'une serie.

## Etat 2026-05-14 - Import admin de series Cotton Quiz depuis Markdown

Etat historique remplace le 15/05/2026 par la preview technique et l'import DB minimal ci-dessus.

## Etat 2026-05-13 - Home EC onboarding premiere animation ABN

La Home EC affiche maintenant un widget compact `Pour bien demarrer` pour les comptes `ABN` sans session officielle deja programmee. Le rendu est normalise par `app_client_home_onboarding_widget_get(...)`, qui reutilise le helper historique `app_client_network_home_widget_get(...)` sans casser ses sorties existantes.

Comportement contractuel:
- `id_client_reseau` seul ne suffit pas a afficher le widget;
- un compte TdR ne voit pas ce widget affilie et conserve la Home reseau siege existante;
- `ABN` sans session officielle deja programmee, pas seulement a venir: widget prioritaire premiere animation;
- si un contexte exploitable existe (offre deleguee, jeux reseau selectionnes, design reseau ou operation cablee plus tard), la variante contextualisee est prioritaire;
- des jeux reseau selectionnes suffisent a contextualiser le widget et a pointer le CTA vers `extranet/games/library?network_manage=1&from=agenda&mode=library`, meme sans offre TdR active;
- si aucun contexte exploitable n'existe, la variante generique Cotton utilise le logo Cotton et pointe vers `extranet/games/library?from=agenda&mode=library` pour demarrer directement par la bibliotheque de thematiques;
- le hub bibliotheque conserve `from=agenda&mode=library` quand l'utilisateur choisit un jeu depuis ce CTA onboarding;
- ce widget prioritaire utilise un wording neutre hors vocabulaire reseau, sans chips, sans CTA secondaire, et affiche le CTA unique `Je me lance`;
- le widget prioritaire ne rend jamais les ressources ni les stats du contexte affilie; ces lignes restent reservees aux bandeaux;
- le widget prioritaire et les bandeaux affilies ajustent leur largeur desktop sur la largeur cumulee de la premiere ligne de widgets situee en dessous; sur mobile, ils reprennent la pleine largeur disponible;
- le feedback post-animation Home EC suit la meme largeur desktop que le bandeau affilie et s'affiche au-dessus de lui quand les deux existent;
- le feedback post-animation du detail session archivee est affiche en pleine largeur, aligne sur les cartes detail/resultats;
- `ABN` deja actif, `INS` et `CSO`: bandeau commun leger sous le titre Home, sans CTA, uniquement si jeux selectionnes, habillage personnalise ou stats significatives existent;
- le bandeau commun affiche le titre factuel `Ton espace Cotton est affilié à : {Nom_contexte}` puis les lignes compactes disponibles, avec les stats reseau avant les ressources (`Des jeux sont selectionnes pour toi`, `Un habillage personnalise s'applique a tes jeux`) quand les deux existent;
- en mobile, le bandeau affilie conserve son logo et masque les stats reseau pour rester leger; les ressources utiles peuvent rester visibles;
- aucun bandeau n'est affiche sur simple rattachement `id_client_reseau` sans contenu valorisable;
- aucun CTA reseau n'est expose dans les bandeaux pour ne pas concurrencer les blocs offre, commande, agenda ou bibliotheque;
- sur la Home TdR, le widget `Ton lien d'affiliation` expose la LP reseau sur le domaine `www` (`/lp/reseau/{slug}`) et priorise le visuel principal LP reseau en fond, avec fallback sur le visuel statique historique;
- dans ce widget, le lien affiche ouvre la LP pour previsualisation; la copie du lien reste portee par le CTA bas dedie;
- ce meme widget donne acces a une modale legere pour remplacer le logo LP reseau, le visuel principal LP reseau et les deux couleurs LP reseau; ces assets sont diffuses aux affilies et le POST PRO reutilise `app_client_lp_asset_uploader(...)` / `app_client_lp_colors_save(...)`;
- cette modale reste sur la Home TdR, avec libelles courts `Logo` / `Visuel principal`, previews image avant sauvegarde et champs couleur lisibles pour permettre le choix couleur depuis les images selectionnees;
- le bloc `Animation reseau` de la Home TdR affiche les stats reseau significatives quand `app_client_network_lp_stats_get(...)` les rend affichables, avec les memes seuils que la LP; dans ce cas le sous-titre generique est masque;
- les assets/couleurs LP sont la source dediee de la LP publique; s'ils sont absents, la LP retombe sur les fallbacks Cotton plutot que sur le design reseau complet;
- sur la Home TdR, le bloc `Animation reseau` peut afficher le logo LP TdR en pastille en haut a droite de son titre, sans remplacer les widgets de pilotage;
- dans le tunnel programmation agenda, l'etape de choix du jeu reprend la meme carte d'acces aux jeux reseau que la Home bibliotheque EC lorsque les jeux reseau sont accessibles;
- cette carte reste sous les trois cartes de choix de jeu et ouvre `library?network_manage=1&from=agenda&mode=library` pour conserver le contexte de programmation;
- sur l'etape de choix du jeu, l'affichage de cette carte est decouple du widget Home et d'une offre active: un compte affilie non siege la voit des qu'au moins un contenu reseau est partage par la TdR;
- le media de cette carte priorise le visuel de branding reseau; sans visuel, il utilise le logo LP TdR en pastille centree; sans logo LP, il conserve `catalogue_contenus.png`, avec une hauteur fallback bornee au gabarit du visuel branding et fixee a `220px` desktop / `180px` mobile;
- le bloc haut du hub `Jeux selectionnes` / contenus reseau priorise aussi le visuel branding reseau; sans visuel branding, il utilise le logo LP TdR en pastille centree adaptee a la hauteur reelle du bloc et plus compacte en contexte affilie; sans logo LP, il conserve le visuel historique `catalogue_contenus.png`;
- la Home bibliotheque EC standard reste un contexte de consultation: elle ne devient programmation que si `from=agenda&mode=library` est deja present dans l'URL.
- le hub `Jeux du reseau` ouvert avec `from=agenda&mode=library` affiche l'indicateur `Etape 1/4 - Jeu`;
- depuis une fiche de contenu reseau consultee dans ce contexte, les retours vers `Jeux du reseau`, la recommandation reseau et le retour builder Quiz conservent `from=agenda&mode=library`.

Fichiers de reference:
- orchestration Home: `pro/web/ec/modules/communication/home/ec_home_index.php`;
- preservation du contexte bibliotheque agenda: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`;
- retours fiche contenu reseau: `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`;
- rendu carte: `pro/web/ec/modules/widget/ec_widget_client_network_affiliate_home.php`;
- choix jeu agenda: `pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php`;
- upload assets LP depuis Home TdR: `pro/web/ec/modules/compte/client/ec_client_script.php`;
- helper contenu/eligibilite: `global/web/app/modules/entites/clients/app_clients_functions.php`.

## Etat 2026-05-13 - UTM reseau vers signin contextualise

Les liens d'affiliation reseau disposent maintenant d'une variante explicite pour connecter un compte existant sans perdre le contexte TdR.

Comportement contractuel:
- `/utm/reseau/{slug}` conserve le comportement historique: resolution TdR dans `ec_sign.php`, pose de `$_SESSION['id_client_reseau']`, puis redirection vers `signup`;
- `/utm/reseau/{slug}/signin` utilise le meme resolveur, pose le meme contexte reseau, puis redirige vers `signin`;
- `/utm/reseau/{slug}/{code}/signin` conserve aussi le code remise reseau quand il est valide;
- `ec_signup.php` et `ec_signin.php` ne sont pas modifies: ils consomment le contexte de session existant.

Fichiers de reference:
- routes: `pro/web/.htaccess`;
- resolveur UTM: `pro/web/ec/ec_sign.php`;
- rendu connexion: `pro/web/ec/ec_signin.php`.

## Etat 2026-05-13 - Stripe webhooks: emails supprimes en livemode=false

Le webhook Stripe utilise maintenant uniquement `event.livemode` pour decider si les emails de notification doivent etre envoyes.

Comportement contractuel:
- `livemode === false`: l'evenement Stripe est un evenement test; les emails de notification declenches par le webhook sont ignores avec un log technique;
- `livemode === true`: comportement email inchange;
- livemode absent ou illisible: comportement email inchange et log d'ambiguite;
- les synchronisations Stripe, commandes, factures, paiements, statuts et guards d'idempotence continuent de s'executer dans tous les cas.

Fichiers de reference:
- entree webhook et lecture `livemode`: `pro/web/ec/ec_webhook_stripe_handler.php`;
- emails de commande/facture: `global/web/app/modules/ecommerce/app_ecommerce_functions.php`.

## Etat 2026-05-12 - Signup/signin: habillage affiliation reseau par assets LP TdR

Le rendu public `signup` / `signin` applique maintenant l'habillage reseau des qu'un contexte TdR est resolu via `$_SESSION['id_client_reseau']`.

Priorite d'affichage:
- logo LP reseau du compte TdR, affiche dans une pastille blanche coherente avec la LP;
- visuel LP reseau du compte TdR en fond de page avec filtre integre au background;
- branding signup reseau historique en fallback element par element;
- fallback Cotton si aucun element reseau exploitable n'existe.

Invariants:
- le declencheur reste l'affiliation reseau resolue, pas un marqueur d'origine LP;
- les couleurs LP reseau ne sont pas appliquees au formulaire signup/signin, pour eviter les risques de lisibilite sans controle de teinte dedie;
- `/utm/reseau/{slug}` continue de passer par `ec_sign.php` et de rediriger vers `signup`;
- la logique signup/signin, rattachement et activation incluse reste portee par les scripts existants.

Fichiers de reference:
- entree lien: `pro/web/ec/ec_sign.php`;
- rendu inscription: `pro/web/ec/ec_signup.php`;
- rendu connexion: `pro/web/ec/ec_signin.php`;
- theme CSS: `pro/web/ec/includes/css/ec_custom.css`;
- composition des assets LP: `global/web/app/modules/entites/clients/app_clients_functions.php`.

## Etat 2026-05-06 — Affiliation TdR: compte existant via signin

Le parcours lien d'affiliation TdR -> signup -> signin rattache maintenant aussi un compte Cotton existant au reseau, en reutilisant le helper central `app_ecommerce_reseau_affilier_client(..., 'signup_affiliation')`.

Comportement contractuel:
- le contexte du lien est porte en session par `ec_sign.php` via `$_SESSION['id_client_reseau']`;
- apres connexion reussie dans `ec_authentification_script.php`, ce contexte est consomme pour rattacher le client existant;
- une offre propre active reste prioritaire: aucune offre incluse `cadre`, aucune offre `hors_cadre` et aucun repricing/remise reseau ne sont appliques par ce parcours;
- sans abonnement reseau actif, sans offre cible ou sans quota disponible, le parcours pose seulement l'affiliation, sans acces reseau effectif;
- si support actif + offre cible + quota disponible et aucune offre propre active, le helper peut activer une delegation incluse `cadre`;
- un compte deja rattache a une autre TdR n'est pas reaffecte automatiquement depuis signin;
- dans ce dernier cas, le shell PRO affiche un flash explicite sans exposer le nom de l'autre reseau.

Fichiers de reference:
- entree lien: `pro/web/ec/ec_sign.php`;
- flash post-login: `pro/web/ec/ec.php`;
- bascule signup/signin: `pro/web/ec/ec_signup.php`, `pro/web/ec/ec_signin.php`;
- post-login compte existant: `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`;
- creation compte: `pro/web/ec/modules/compte/client/ec_client_script.php`;
- moteur affiliation/offres: `global/web/app/modules/ecommerce/app_ecommerce_functions.php`.

## Etat 2026-05-06 — Stripe ABN: cloture effective et pipeline client

Le webhook Stripe garde le comportement stabilise pour les offres:
- une souscription `past_due` reste une relance Stripe sans coupure Cotton;
- `cancel_at_period_end` programme la fin de periode sans repasser le client `CSO` trop tot;
- la cloture Cotton intervient seulement quand Stripe envoie une souscription effectivement `canceled` ou `deleted`.

Effet attendu apres cloture effective:
- l'offre Stripe/Cotton est marquee `Terminee` cote socle `global`;
- le pipeline du client est recalcule depuis les offres encore actives;
- un client sans autre acces actif repasse `CSO`;
- un client avec une autre offre active reste dans le pipeline correspondant (`ABN` ou `PAK`).

## Etat 2026-04-29 — Agenda Quiz V1: `Ouvrir le jeu` reprend le launcher historique

Correctif fonctionnel cote `pro`:
- dans les cartes de l'agenda EC, le CTA `Ouvrir le jeu` des sessions `Cotton Quiz V1` (`id_type_produit=1`) ne reste plus sans URL;
- il pointe maintenant vers le parcours classique PRO `/extranet/start/game/play/{id_securite_session}`;
- ce parcours conserve le launcher historique de cette version (`quiz.game` pour l'animation mobile, `quiz.display` pour l'ecran de diffusion), comme la fiche detail session.

Invariants:
- aucun changement pour `Cotton Quiz V2`, `Blind Test`, `Bingo Musical` ni `games/master`;
- le garde-fou de lancement commercial reste applique avant acces au jeu;
- cette version legacy reste bornee au strict maintien d'acces.

## Etat 2026-04-28 — Micro-feedback utilisateur V1

L'espace PRO ajoute une premiere collecte de micro-feedback discrete, non bloquante et separee par contexte metier / surface d'affichage.
- apres programmation, le resume de session standard et le resume rapide multi-sessions demandent si l'etape etait claire (`session_programmed_summary`, surface `session_summary`);
- ce feedback de programmation est limite par client: apres un retour ou une fermeture, il n'est plus repropose pendant 30 jours;
- sur la home PRO, une session reelle terminee recemment peut declencher le retour post-animation (`session_finished_experience`, surface `pro_home`);
- la home ne considere que la derniere session terminee recente: si elle a deja un retour ou une fermeture, aucun bloc plus ancien n'est remonte a sa place;
- sur la fiche detail d'une session terminee, le meme contexte post-session peut etre propose en secondaire (`pro_session_detail`) si aucun retour ni fermeture n'existe deja pour cette session;
- les retours positifs sont enregistres directement, sans champ commentaire;
- les retours moyens/negatifs ouvrent un champ commentaire optionnel, avec tags facultatifs sur la home;
- la fermeture du bloc est conservee comme feedback ignore (`internal_status=ignored`) afin de ne pas reproposer la meme session.
- sur les resumes de programmation, le bloc est affiche au-dessus des cartes de session avec un rendu compact en ligne.

Contrat technique:
- stockage generique dans `user_feedback_events`;
- script SQL phpMyAdmin: `pro/sql/user_feedback_events_phpmyadmin.sql`;
- endpoint AJAX: `pro/web/ec/ec_ajax.php?t=general&m=feedback&p=submit`;
- helper PRO: `pro/web/ec/modules/general/feedback/ec_feedback_lib.php`.

Invariants:
- aucun bloc de feedback n'est ajoute cote `games`;
- le post-session exclut les demos via `flag_session_demo=0`;
- la home reutilise les helpers historiques `app_client_joueurs_dashboard_archive_sessions_get()` / `app_client_joueurs_dashboard_session_is_history_useful()` pour rester alignee avec les exclusions metriques/historiques.

Durcissement serveur avant prod — 2026-04-29:
- l'endpoint accepte uniquement les couples `session_programmed_summary` + `session_summary`, `session_finished_experience` + `pro_home`, `session_finished_experience` + `pro_session_detail`;
- les valeurs techniques sont bornees par contexte: programmation `yes` / `neutral` / `no` / `ignored`, post-session `great` / `improve` / `ignored`;
- les commentaires/tags sont ignores cote serveur pour les retours positifs et les fermetures, et les tags restent limites au retour post-session `improve`;
- les sessions demo sont refusees cote endpoint aussi pour le feedback apres programmation;
- un controle anti-doublon est relu juste avant insertion;
- aucun changement UI ni schema SQL; la table `user_feedback_events` doit etre importee via `pro/sql/user_feedback_events_phpmyadmin.sql` avant production.
- les `rating_label` sont normalises cote serveur sans emoji avant insertion: `Oui`, `Moyen`, `Non`, `Oui, très bien`, `Pas totalement`, `Fermé`; les valeurs techniques restent la source de distinction, notamment `neutral` vs `no`.

## Etat 2026-04-28 — Fiche session PRO: verification des supports de session

La fiche detail session PRO propose maintenant une verification des supports depuis la section `Tester`, sans remettre le scan multimedia dans `games organizer`.
- le bouton lit d'abord les diagnostics deja presents dans `content_links_check_results`;
- la fiche session ne lance jamais le scan global admin `ccl_scan_run()`;
- les supports non couverts des lots temporaires Quiz peuvent etre controles directement, mais uniquement a la demande et uniquement pour la session courante;
- les diagnostics directs sont ajoutes a `content_links_check_results` pour etre retrouvables ensuite cote admin, sans effacer le scan global;
- l'UI reste non bloquante et actionnable:
  - playlist: badge `x morceaux douteux`;
  - serie Quiz: badge `x supports douteux`;
  - lot temporaire: retour JSON avec position, id question, extrait et support concerne.

Invariants:
- les sessions demo et la duplication de session test gardent leur logique existante;
- le lancement des jeux n'est pas modifie;
- aucune dependance front PRO n'est ajoutee vers `games/web/includes/canvas/core/prelaunch_check.js`.

## Etat 2026-04-27 — Programmation et agenda EC: format stable, visuels Quiz V2 par session

Correctifs fonctionnels cote `pro`:
- dans les chemins de programmation, le polling `session_sync_state` ne remplace plus le choix local `Numerique` / `Classique` ni le format associe une fois que l'organisateur a modifie ces controles dans la page;
- cela evite qu'un choix `Classique` repasse visuellement en `Numerique` apres une modification de date avant sauvegarde;
- les cartes de l'agenda EC transmettent maintenant les `lot_ids` de session au socle `app_jeu_get_detail(...)`;
- pour un `Cotton Quiz V2`, le visuel de carte est donc resolu depuis les vrais lots `L...` programmes sur la session, avec fallback sur le visuel par defaut si aucun lot classique ne porte de visuel custom.
- addendum prod: la fiche detail et le parcours classique transmettent aussi les `lot_ids` disponibles, pour eviter qu'une vue secondaire repasse par le contrat legacy.

Effet attendu:
- le parametrage reste coherent tant que l'utilisateur edite sa session;
- les cartes agenda ne piochent plus un visuel dans une ancienne serie legacy sans rapport avec la session V2 affichee.

## Etat 2026-04-23 — Controle des liens YouTube: diagnostic Data API aligne cron

Le module admin `Les jeux > Controle des liens` ne se limite plus au controle `oEmbed` pour les scans quand une cle YouTube Data API est disponible.
- le scan dedoublonne les `videoId`, interroge YouTube Data API par lots de 50, puis persiste le resultat dans `content_links_check_results`;
- les causes remontees sont alignees sur le cron BO Bingo Musical:
  - ressource indisponible/supprimee/privee;
  - statut non public;
  - integration YouTube desactivee;
  - restriction d'age;
  - live/direct;
  - blocage region France;
- si la cle Data API est absente, le scan garde un fallback `oEmbed` et indique ce fallback dans `error_detail`;
- aucune correction automatique ni write base metier n'est ajoute: le module conserve le flux de correction groupée existant.

## Etat 2026-04-17 — Fiche session terminee: upload podium local sans QR ni caméra

Correctif fonctionnel cote `pro`:
- sur la fiche detail d'une session archivee, le CTA `Ajouter une photo` / `Modifier la photo` n'ouvre plus de modale QR code pour basculer sur mobile;
- ce CTA ouvre maintenant seulement la bibliotheque locale de l'appareil courant, y compris sur mobile;
- l'intention produit est maintenant nette:
  - prendre une photo en direct se fait depuis la remote;
  - la fiche detail `pro` ne sert plus qu'a reutiliser une photo deja existante sur le device courant.

## Etat 2026-04-17 — Resultats / `Mes joueurs`: ordre des ex aequo aligne sur `games`

Correctif fonctionnel cote `pro`:
- la fiche session terminee et les podiums agreges `Mes joueurs` ne re-trient plus les ex aequo par libelle;
- elles preservent maintenant l'ordre source fourni par le socle partage, lui-meme recale sur l'ordre stable de `games` pour les sessions runtime;
- effet attendu:
  - a rang egal, le podium et le classement complet racontent enfin la meme histoire;
  - un meme top de saison ou une meme fiche session ne doit plus inverser deux lignes ex aequo entre le podium et le tableau.

## Etat 2026-04-16 — `Ma communauté`: trigger QR aligné en ligne

Correctif fonctionnel cote `pro`:
- dans `Ma communauté`, le raccourci `QR code permanent à imprimer.` suit maintenant un rendu responsive;
- sur desktop, le trigger reste dans la colonne QR et garde un affichage vertical avec le texte au-dessus de l'icone;
- sur mobile, le trigger est deplace sous la description du compte et passe en affichage horizontal `icone + texte`.
- sur mobile, le bloc gagne aussi un peu plus d'espace au-dessus et au-dessous pour mieux respirer entre la description et le lien public.
- sur mobile, le groupe `icone + texte` est aussi recentre sous la description.
- sur mobile, le trigger reapplique en plus un padding explicite, la classe utilitaire `p-0` etant sinon trop agressive pour ce bloc.
- le trigger mobile reserve aussi une hauteur minimale pour contenir correctement l'icone QR et son texte.

## Etat 2026-04-16 — Bibliothèque: aperçus YouTube courts audio/vidéo

Correctif fonctionnel cote `pro`:
- dans la bibliothèque de thématiques, les aperçus inline ne reposent plus sur un simple fallback fixe quand l'URL support ne fournit pas déjà `start` / `end`;
- les bornes explicites dans l'URL restent prioritaires;
- sinon, l'aperçu lit maintenant la duree reelle du support puis applique la regle:
  - media `>= 40s` => depart a `30s`
  - media `< 40s` => depart a `0s`
- cette logique est appliquee aux aperçus YouTube audio/video et aux aperçus video HTML5.

## Etat 2026-04-16 — Demos `games/master`: retour contextualise vers `pro`

Correctif fonctionnel cote `pro`:
- les lanceurs demo connus n'ouvrent plus `games/master` sans contexte de retour;
- `bibliotheque`, `fiche detail session`, `liste agenda`, duplication de session et parcours compte ajoutent maintenant un `return_url` vers la page `pro` d'origine quand ils ouvrent une demo dans `games`;
- objectif:
  - quitter une demo depuis `master` doit ramener l'utilisateur a son point d'entree EC;
  - la logique reste strictement reservee aux demos, sans modifier les retours des sessions officielles.

## Etat 2026-04-16 — Fiche session terminee: lien `games` dans le bloc `Parametres`

Correctif fonctionnel cote `pro`:
- le bloc `Parametres` de la fiche detail session reutilise maintenant aussi le lien `games` quand la session est terminee;
- le statut `Session terminee` affiche desormais le texte:
  - `Voir les resultats de cette session sur l'interface de jeu.`
- le lien pointe vers le meme `url_session_game_interface` deja calcule pour les sessions en cours;
- aucun autre comportement n'est modifie:
  - pas de changement de garde;
  - pas de changement de routing;
  - seule la notice de statut du bloc `Parametres` est enrichie pour le cas archive.

## Etat 2026-04-16 — Fiche detail session demo: le polling suit l'etat reel

Correctif fonctionnel cote `pro`:
- la fiche detail d'une session demo n'ignore plus l'etat runtime partage au moment du polling;
- une demo en cours redevient donc non modifiable depuis `pro`, comme une session standard;
- une demo relancee depuis `games` repasse automatiquement en `En attente` dans `pro` si son runtime est effectivement revenu a l'etat initial;
- aucun changement de contournement n'est applique cote `games`: la relance d'une demo reste possible depuis l'interface jeu.

## Etat 2026-04-16 — `Mon agenda`: acces au QR code permanent depuis le header

Correctif fonctionnel cote `pro`:
- la page `Mon agenda` propose maintenant elle aussi l'acces au QR code permanent du lieu, sans obliger a passer par `Ma communauté`;
- le trigger est ajoute dans le header agenda, a droite du titre `Mon agenda`, avec le libelle `QR code permanent` et une icone QR cliquable;
- le clic ouvre la meme modale que sur `Ma communauté`, avec le meme message d'usage, le meme apercu PNG et le meme CTA `Enregistrer`;
- le bouton n'est expose que sur l'agenda standard du lieu:
  - pas sur `Archives`;
  - pas sur `Agenda du réseau`.

## Etat 2026-04-15 — `Ma fiche lieu`: synthèse + classements `Mes joueurs` chargés en différé

Correctif fonctionnel cote `pro`:
- la page `Ma fiche lieu` affiche maintenant immédiatement son bloc principal de présentation, puis hydrate en AJAX un nouveau bloc `synthèse + classements` issu du moteur `Mes joueurs`;
- cette synthèse reprend un bloc `Mes stats`, un bloc `Participants` et un bloc `Mes tops`, dans le style des cartes `Ma fiche lieu`;
- les `Classements par jeu` sont dupliqués sous cette synthèse, avec le même contrat de saison, podium et liens archive que sur `Mes joueurs`;
- la page réutilise le même loader que `Mes joueurs` pendant l’hydratation, et le changement de saison recharge uniquement le fragment leaderboard;
- ajustement d’interface:
  - la marge cumulée entre le bloc principal lieu et la zone hydratée a été supprimée;
  - le sélecteur `Saison` est maintenant intégré dans l’en-tête du bloc classements, au lieu d’être isolé dans une card dédiée;
  - le conteneur `Classements par jeu` est désormais une card unique alignée sur les autres blocs de `Ma fiche lieu`, avec sous-blocs internes simplifiés pour éviter l’empilement de paddings;
  - les wrappers visuels internes de chaque jeu ont finalement été retirés pour ne garder que l’espacement vertical entre blocs;
  - le bloc `Participants` est renommé `Mes Participants`;
  - les compteurs secondaires du bloc `Mes tops`, les titres `Top 10 / Classement complet` et les liens liés aux sessions de classement utilisent maintenant la même couleur d’accent `#582AFF` que le lien `Afficher/Replier le classement`;
  - le widget QR code bas de page a été supprimé et remplacé par un raccourci QR cliquable intégré à droite dans le bloc principal des infos générales, recentré et agrandi;
  - ce raccourci affiche maintenant une courte explication d’usage, puis ouvre une modale simple avec:
    - un aperçu image du QR code;
    - un CTA direct `Enregistrer` vers l’image PNG;
  - la sortie historique `qr-code-place` accepte maintenant aussi `?format=png`, ce qui permet de réutiliser le même générateur centralisé hors PDF.
  - ajustement final QR:
    - le libellé compact devient `QR code permanent à imprimer.`;
    - la modale explicite maintenant l’usage `Il donne accès à l'ensemble de tes prochaines sessions.`;
    - la source PNG du QR est générée en définition plus élevée pour une meilleure qualité d’impression.
    - la colonne QR du bloc principal est maintenant centrée verticalement pour rester alignée avec le reste des infos lieu;
    - l’image PNG enregistrable n’est plus un QR brut: elle est désormais composée pour l’impression avec `{nom du compte}`, `Agenda des jeux Cotton`, QR avec logo Cotton centré et lien public.
    - le logo central n’est plus relu depuis le repo `games`: il est maintenant stocké comme asset mutualisé dans `global/web/assets/branding/qr/cotton-logo-qr.png`.
    - la modale QR utilise maintenant une largeur `modal-lg` et un aperçu plus grand pour mieux exploiter l’espace disponible;
    - le lien encodé par le QR suit désormais `www_url` de l’environnement courant (`dev`/`prod`) tout en gardant le format historique `/place/{code_client}`.
    - le trigger QR du bloc principal aligne maintenant texte et icône sur le même axe au lieu d’un empilement vertical ambigu;
    - l’image PNG générée est aussi resserrée verticalement pour réduire les blancs inutiles visibles dans l’aperçu de la modale.
    - le PNG généré reste maintenant sur fond transparent, avec un léger contour arrondi autour du support;
    - le bloc QR lui-même est aussi rogné avec des coins arrondis.
    - la composition `titre + sous-titre + QR + lien` est maintenant recentrée verticalement dans le canvas du PNG.
  - logique de visibilité affinée:
    - le menu `Ma communauté` reprend la même sécurité que `Mes joueurs` quand des données de synthèse existent;
    - l’ancienne règle `Ma fiche lieu` reste prioritaire pour le bloc principal d’infos générales et force aussi la présence du menu même sans données;
    - dans ce cas sans données, la page affiche à la place un message `Aucune info de communauté disponible pour le moment...`;
    - le lien de navigation est maintenant placé juste sous `Mon agenda`, ou sous `Les jeux` quand `Mon agenda` n’est pas affiché.
  - l’accès à l’ancienne page `Mes joueurs` est maintenant désactivé:
    - le lien de navigation a été retiré;
    - l’URL historique `extranet/players` redirige vers `Ma communauté`;
    - le code n’est pas supprimé car le socle partagé reste réutilisé par la nouvelle page et son coût de conservation est faible.
- le rendu leaderboard est maintenant mutualisé dans un include partagé pour préparer une éventuelle suppression future de la page `Mes joueurs`.

## Etat 2026-04-15 — `Ma fiche lieu` ouverte à tous les comptes non siège réseau

Correctif fonctionnel cote `pro`:
- l’entrée de navigation `Ma fiche lieu` n’est plus limitée aux seuls comptes `Dynamiser` ou `test`;
- elle est maintenant visible pour tous les comptes `non siège réseau`, ce qui permet de centraliser plus largement les infos lieu + joueurs sur une seule page.

## Etat 2026-04-15 — `Mes joueurs`: ordre de lecture des classements aligne sur `Blind Test`, `Bingo`, `Quiz`

Correctif fonctionnel cote `pro`:
- la page `Mes joueurs` affichait ses blocs classement dans l'ordre technique du contexte dashboard;
- le rendu suit maintenant l'ordre de lecture retenu sur les autres fronts Cotton: `Blind Test`, puis `Bingo Musical`, puis `Cotton Quiz`;
- l'ordre reste conditionne par les donnees disponibles: un jeu absent ou vide n'est toujours pas force.

## Etat 2026-04-13 — Fiche session archivée: espacement rétabli sous `Version : Papier`

Correctif fonctionnel cote `pro`:
- quand le lien d'impression papier n'est plus affiche sur une session archivee, la ligne `Version : Papier` retrouve maintenant un espacement bas standard;
- le rendu compact sans marge basse reste reserve au seul cas ou le bloc d'impression papier est effectivement rendu juste dessous.

## Etat 2026-04-13 — `Archives`: le filtre Bingo inclut aussi le legacy type `2`

Correctif fonctionnel cote `pro`:
- l'historique `Archives` interprete maintenant `bingo-musical` comme `id_type_produit IN (2,3,6)`;
- la detection locale de statut archive recharge aussi le detail jeu pour le type `2`, afin d'aligner les liens `Détail` et les filtres archives avec le moteur partage `Mes joueurs`.

## Etat 2026-04-13 — Fiche session historique: impression papier masquée

Correctif fonctionnel cote `pro`:
- sur la fiche détail d'une session papier terminée/archivée, le lien `Imprimer les feuilles de réponses` n'est plus affiché;
- l'impression reste proposée uniquement tant que la session n'est pas en historique.

## Etat 2026-04-13 — `Mes joueurs`: liens `Détail` vers l'historique archives filtré

Correctif fonctionnel cote `pro`:
- les sous-totaux par jeu ouvrent le meme historique archive, mais filtre sur `Cotton Quiz`, `Bingo Musical` ou `Blind Test`;
- le lien global `Détail` de la synthese a ete retire pour ne garder que les liens utiles par jeu;
- dans les cartes de classement par jeu, le rappel `Classement calculé sur X sessions...` expose maintenant `Détail` inline dans la phrase, vers l'historique archive du jeu sur la saison selectionnee;
- les lignes `Classement calculé...` et `Attribution des points...` gardent un rendu de texte neutre, mais le lien `Détail` reste bleu pour mieux ressortir;
- l'historique `Archives` relit ces filtres via `seo_slug_jeu`, `date_start` et `date_end`.

## Etat 2026-04-13 — Fiche session historique: retour header `"Archives"` vers le bon agenda

Correctif fonctionnel cote `pro`:
- sur la fiche detail d'une session archivee, le CTA de retour du header n'ouvre plus l'agenda standard des sessions a venir;
- il affiche maintenant exactement `"Archives"` et renvoie vers `extranet/start/games/archives`;
- les fiches non archivees gardent le libelle et la destination historique `Mon agenda`.

## Etat 2026-04-13 — Fiche session historique: `Paramètres` redevient le bloc d'entree

Correctif fonctionnel cote `pro`:
- sur la fiche detail d'une session archivee, le bloc `Paramètres` repasse maintenant avant `Résultats`;
- le bandeau de statut est aussi present sur l'historique avec le libelle `Session terminée`, pour rester aligne sur la logique visuelle deja en place pour `Session en cours`;
- le bloc `Paramètres` ne re-expose plus les thematiques / playlists d'une session terminee;
- l'objectif est de garder sur l'historique un bloc de contexte court et stable, puis de laisser le recap post-session dans `Résultats`.

## Etat 2026-04-13 — Fiche session historique mobile: ajout photo via un bouton unique

Correctif fonctionnel cote `pro`:
- l'ajout de photo podium sur mobile ne montre plus 2 boutons distincts `Prendre une photo` / `Choisir une photo`;
- un seul bouton ouvre maintenant un mini-menu `Caméra / Photos`, dans l'esprit des modules d'ajout de photo mobiles classiques;
- l'objectif est de laisser Android/iOS proposer directement `Caméra`, `Photos` ou source equivalente sans dupliquer le formulaire dans la vue;
- les formats non supportes restent filtres avant envoi.

## Etat 2026-04-13 — Fiche session historique desktop: bascule mobile via QR code

Correctif fonctionnel cote `pro`:
- sur desktop, le bouton `Ajouter une photo` ouvre maintenant une modale;
- cette modale affiche le QR code mobile et conserve un CTA d'upload local direct sur l'appareil courant;
- le lien s'appuie sur le mecanisme existant de connexion temporaire organisateur, puis redirige vers la fiche session concernee;
- cela evite de creer une page mobile dediee: l'utilisateur reprend simplement l'upload depuis la meme fiche session sur son telephone.

## Etat 2026-04-11 — Fiche session historique: photos gagnants distinctes pour les ex aequo

Correctif fonctionnel cote `pro`:
- la fiche detail d'une session archivee n'associe plus une photo unique a tout un rang de podium quand plusieurs gagnants sont ex aequo;
- l'ecran `Résultats` garde son groupement visuel par place (`#1`, `#2`, `#3`), mais chaque gagnant de la carte peut maintenant afficher et uploader sa propre photo;
- le formulaire d'upload transmet desormais une cle stable de ligne de podium en plus du rang, ce qui permet de distinguer deux gagnants differents sur une meme place sans casser le fallback historique par rang;
- en cas de refresh ou d'evolution du podium, la vue remonte un message explicite si le gagnant cible n'est plus disponible.

## Etat 2026-04-10 — TdR: le portail Stripe d'une offre affiliée reutilise le bon contexte de souscription

Correctif fonctionnel cote `pro` / `global`:
- le flux `extranet/account/network/script?mode=open_affiliate_offer_portal` garde son handler et ses gardes TdR inchanges;
- la correction est centralisee sur la preparation de session Stripe: un deep link de portail delegue utilise maintenant le customer de la souscription cible quand il differe du customer siege memorise;
- effet attendu: un TdR peut de nouveau ouvrir le portail Stripe d'une offre affiliée active ou en supplement sans casser les portails standards.

## Etat 2026-04-09 — Fiche session historique: `Résultats` avant `Paramètres`, remplacement photo visible

Correctif fonctionnel cote `pro`:
- sur une session archivee, le bloc `Résultats` est maintenant affiche avant `Paramètres`;
- l'intention est de mettre le recap post-session et le podium en premiere lecture sur la fiche detail;
- le front d'upload podium reste sur les formats effectivement supportes (`jpg`, `jpeg`, `png`, `webp`) afin d'eviter un faux signal d'acceptation cote navigateur.

## Etat 2026-04-09 — Archives agenda: meme contrat metier que `Mes joueurs`

Correctif fonctionnel cote `pro`:
- la page `Archives` de l'agenda EC ne se contente plus de relire des sessions techniquement passees;
- elle reapplique maintenant le meme filtre metier que `Mes joueurs` pour ne garder que les sessions vraiment utiles au client;
- une session archivee n'est donc plus affichee si elle est numerique mais sans participation reelle fiable;
- les sessions papier restent visibles meme sans participation remontee;
- le listing agenda relit maintenant `flag_controle_numerique` et s'appuie sur un helper global de qualification historique.

## Etat 2026-04-09 — Fiche session historique: résultats finaux et photos gagnants

Correctif fonctionnel cote `pro`:
- la fiche detail d'une session archivee dans l'EC affiche maintenant un bloc `Résultats` en tete de vue;
- l'ordre est `Podium` puis `Classement complet` quand une verite exploitable existe;
- la vue ne recalcule pas un classement metier propre a `pro`: elle consomme un helper global branche sur les sources runtime / legacy deja stabilisees;
- le bloc `Ressources` est masque pour une session historique;
- le podium affiche maintenant aussi `🏆`, `🥈`, `🥉`;
- le podium est presente en `3` cases sur desktop puis en colonne sur mobile;
- pour `Cotton Quiz` et `Blind Test`, ces `3` cases reprennent maintenant les vraies positions du podium `games` en cas d'egalite (`#1 / #1 / #3`, etc.), au lieu de forcer artificiellement `#1 / #2 / #3`;
- chaque case de podium peut maintenant uploader une photo gagnant via `extranet/start/script`, avec une route dediee par jeu (`quiz`, `blindtest`, `bingo`);
- sur desktop, chaque case conserve un CTA unique `Ajouter une photo` / `Modifier la photo`;
- sur mobile, chaque case expose 2 actions distinctes:
  - `Prendre une photo`
  - `Choisir une photo`
  afin d'eviter la variabilite des navigateurs mobiles sur un input fichier unique;
- si une photo est deja liee a une place, elle est affichee en tete de la case correspondante;
- la photo affichee dans la fiche EC est volontairement recadree avec une hauteur fixe pour conserver un rythme de page stable;
- `Bingo Musical` reste borne au podium de phases et a la liste historisee des joueurs tant qu'aucun classement complet ordonne fiable n'existe cote jeux;
- les absences de donnees sont maintenant expliquees cote utilisateur:
  - session non terminee;
  - session terminee sans joueur connecte.
- la vue historique Bingo ne depend plus du seul filtre live `bingo_players.is_active=1`, ce qui evite les faux `Aucun joueur...` apres fermeture de session.
- `Cotton Quiz` legacy conserve aussi un fallback de lecture sur le stockage historique des photos gagnants `championnats/resultats` quand aucune photo session dediee n'a encore ete chargee.
- pour `Cotton Quiz` legacy sans runtime `players`, le compteur `Particip.` post-session s'aligne maintenant d'abord sur les resultats reels de session (`championnats_resultats`) et la colonne de score affiche bien le score quiz de session, pas les points de classement agreges.

## Etat 2026-04-09 — Remises ABN: la verite de deploy inclut schema DB + script checkout PRO

Etat courant a retenir cote PRO:
- une remise `Remises 2026` peut etre visible dans `Tarifs & commande` et `Detail de ma commande` seulement si la chaine complete est coherente:
  - regle BO active dans `ecommerce_remises`
  - rattachement offre dans `ecommerce_remises_to_offres`
  - ciblage client manuel dans `ecommerce_remises_to_clients` ou match pipeline/typologie
  - snapshot runtime ecrit sur `ecommerce_offres_to_clients`
  - webhook Stripe capable ensuite d'orchestrer le cas `schedule` si besoin;
- la prod a confirme un point de vigilance de deploy:
  - mettre a jour la DB ne suffit pas;
  - le fichier `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` doit etre deployee avec le lot, sinon PRO peut afficher la remise sans la transmettre au checkout Stripe;
- le script SQL historique `www/web/bo/www/modules/ecommerce/remises/bdd_ecommerce_remises.sql` n'est pas une migration complete du lot tel qu'il tourne aujourd'hui en prod.

Baseline DB minimale a considerer cote PRO:
- `ecommerce_offres_to_clients`:
  - `id_remise` nullable
  - `prix_reference_ht`
  - `stripe_subscription_schedule_id`
- `ecommerce_remises`:
  - `date_debut_commande`
  - `date_fin_commande`
  - `duree_remise_mois`
- `ecommerce_remises_to_offres`
- `ecommerce_remises_to_clients`
- `ecommerce_commandes_lignes`:
  - `id_remise`
  - `prix_reference_ht`

Lecture fonctionnelle cote PRO:
- `ec_offres_include_detail.php` affiche la remise preview via le resolver global;
- `ec_offres_script.php` est le vrai point d'application avant Stripe:
  - reset snapshot
  - resolution de la remise gagnante
  - snapshot sur `ecommerce_offres_to_clients`
  - injection Stripe;
- `ec_webhook_stripe_handler.php` orchestre ensuite le `SubscriptionSchedule` pour les cas mensuels limites;
- `ec_factures_view_pdf.php` relit ensuite les snapshots canoniques de commande/facture.

## Etat 2026-04-08 — `Offres & factures`: un ABN annuel garde maintenant sa vraie periode courante

Correctif fonctionnel cote PRO:
- l'onglet `Offre` n'affiche plus une periode annuelle derivee d'un ancrage mensuel glissant;
- pour un abonnement annuel direct, la periode relue reste maintenant alignee sur l'ancre BDD de souscription tant que Stripe ne remonte pas une periode live exploitable;
- le cas type commande `20/10/2025` affiche donc bien `du 20 octobre 2025 au 19 octobre 2026`, au lieu d'un faux decalage `du 20 mars 2026 au 19 mars 2027`.

## Etat 2026-04-08 — Bibliothèque agenda Quiz legacy V1: une seule série thématique peut être choisie

Correctif fonctionnel cote PRO:
- pour les comptes `Cotton Quiz` legacy V1, la bibliothèque ne propose plus le builder multi-séries du Quiz V2;
- dans le tunnel de programmation par thématique, ces comptes choisissent maintenant une seule série;
- cette série reste pensée comme la série thématique finale du quiz:
  - format `2 séries` => série 2
  - format `4 séries` => série 4;
- le write path serveur borne lui aussi ce flux à une seule série pour les sessions `id_type_produit = 1`.

## Etat 2026-04-08 — Agenda legacy Quiz V1: les sessions incomplètes ne sont plus ejectees vers `view`

Correctif fonctionnel cote PRO:
- dans le tunnel agenda `Cotton Quiz` legacy V1, une session encore sans vraie date ne doit plus etre consideree comme verrouillee;
- la page `setting` garde maintenant l'utilisateur sur l'etape de programmation tant que la session n'a pas encore de jeu genere;
- cela couvre les 2 chemins remontes en recette:
  - `programmation rapide`
  - `programmation par thematique` via la bibliotheque.

## Etat 2026-04-08 — Factures PRO: le logo PDF vient maintenant de `global`

Correctif fonctionnel cote PRO:
- la facture PDF ne depend plus d'un logo stocke dans `pro/web/ec/images/general/logo/`;
- elle lit maintenant un asset partage sous `global/web/assets/branding/pdf/`;
- le rendu reste identique, mais la source est desormais commune avec le BO.

## Etat 2026-04-08 — Factures PRO: le PDF front relit enfin les snapshots canoniques

Correctif fonctionnel cote PRO:
- l'ouverture d'une facture depuis l'espace PRO utilisait encore un template PDF distinct du BO, non realigne;
- ce template reste aligne sur le BO en conservant la remise dans le libelle produit, tout en reaffichant le prix de reference HT avant remise;
- le bloc totaux expose desormais `TOTAL HT`, `REMISE ... HT`, `TOTAL REMISÉ HT`, `TVA (...)` puis `TOTAL TTC`;
- le PDF etant regenere a chaque ouverture, ce nouveau rendu vaut aussi pour les factures deja existantes.

## Etat 2026-04-08 — E-commerce: les ecrans PRO affichent maintenant le TTC canonique de facturation

Correctif fonctionnel cote PRO:
- `Tarifs & commande`, `Detail de ma commande` et `Historique de mes commandes` reutilisent maintenant le meme resolver de montant e-commerce;
- le TTC final affiche ne repart plus d'un HT deja arrondi quand une remise est appliquee;
- le cas type `100 joueurs` avec `-25 %` garde donc un HT affiche `74,93 €`, mais le TTC final affiche devient `89,91 €`, aligne sur Stripe;
- le HT reste une information de lecture, alors que le TTC final reste la verite de facturation affichee a l'utilisateur.

## Etat 2026-04-08 — `Offres & factures`: l'onglet `Offre` n'affiche la remise que si elle s'applique encore

Correctif fonctionnel cote PRO:
- dans l'onglet `Offre`, une remise snapshottee n'est maintenant plus affichee de facon aveugle sur toute la vie de l'abonnement;
- le bloc n'apparait que si la remise couvre encore la periode de facturation en cours;
- quand elle est encore active, le rendu reprend le meme recap metier que celui affiche juste apres le checkout Stripe.

## Etat 2026-04-08 — Signup remise: le token public n'est plus limite au champ `code`

Correctif fonctionnel cote PRO:
- la route historique `/utm/cotton/...` reste le point d'entree public des liens de remise;
- le token porte maintenant de facon fiable une remise soit via son `code`, soit via son `id_securite`;
- `ec_sign.php` reste le point d'entree legacy principal de portage, puis redirige vers `signup`;
- `signin` et `signup` savent aussi relire ce meme token public quand il est present en querystring.

## Etat 2026-04-08 — Signup remise: `signin` et `signup` savent aussi relire un token public

Correctif fonctionnel cote PRO:
- le point d'entree partageable principal reste la route historique `/utm/cotton/...`;
- `signin` sait aussi resoudre un token public de remise present en querystring et poser `$_SESSION['id_remise']` avant connexion;
- si l'utilisateur bascule ensuite vers `signup`, le portage session de la remise reste conserve jusqu'a la creation du compte;
- `signup` sait aussi relire ce meme triplet UTM, ce qui garde le meme comportement si un lien direct `signup` est utilise plus tard.

## Etat 2026-04-08 — Checkout ABN: `Detail de ma commande` explicite enfin la duree de remise

Correctif fonctionnel cote PRO:
- le step `Detail de ma commande` affiche maintenant un recap metier de la remise avant bascule vers Stripe;
- ce recap remplace le simple `Au lieu de ...` quand une remise BO est resolue;
- il explicite aussi le cas `trial + remise`, que Stripe Checkout n'affiche pas toujours de facon assez precise.

## Etat 2026-04-08 — Checkout ABN: orchestration simple selon duree de remise

Correctif fonctionnel cote PRO:
- le checkout Stripe abonnement reste le point d'entree unique;
- la logique d'essai gratuit CHR reste resolue au niveau du client reel, sans nouveau champ BO technique;
- les metadata de souscription tracent maintenant la duree de remise et le moteur attendu;
- le webhook `checkout.session.completed` orchestre les seuls cas mensuels limites via `SubscriptionSchedule`, apres creation de la subscription par Checkout;
- l'orchestration est idempotente:
  - write guards applicatifs sur session/event Stripe;
  - garde locale sur `stripe_subscription_schedule_id` deja stocke;
- les cas annuels restent volontairement simples:
  - `< 12 mois` => remise sur la premiere facture annuelle uniquement
  - `>= 12 mois` => remise durable/simple selon la duree
  - aucun phasage annuel complexe n'est introduit.

## Etat 2026-04-07 — Checkout ABN standard: remises BO appliquees via Stripe `discounts`

Correctif fonctionnel cote PRO:
- le checkout Stripe standard de l'abonnement utilise maintenant, hors reseau, un point d'insertion unique pour les remises BO generiques;
- les remises V1 sont maintenant aussi visibles en previsualisation dans le parcours PRO, aux memes endroits que les remises legacy:
  - `Tarifs & commande`;
  - `Detail de ma commande`;
- ces vues relisent le resolver de facon previsionnelle avant redirection Stripe, pour afficher la remise et le tarif net attendus sans ecrire de snapshot;
- le scope runtime V1 est borne a l'ABN periodique reel du code existant:
  - `id_offre_type = 2`
  - `id_paiement_type = 2`
  - hors reseau / hors delegation;
- Stripe reste la source de verite du prix catalogue de base via le `price` resolu par `lookupKey`, mais ce `Price` est maintenant revalide contre le TTC Cotton courant avant creation de la session;
- si une ancienne `lookupKey` Stripe pointe encore vers un montant obsolete, le checkout bascule maintenant sur un nouveau `Price` catalogue conforme au tarif courant au lieu de conserver l'ancien montant;
- Cotton n'ajoute qu'une remise gagnante `% off` si:
  - le resolver BO renvoie une regle eligible;
  - le coupon Stripe reutilisable du pourcentage est disponible;
  - le snapshot local de l'offre client est ecrit avec succes;
- les nouvelles souscriptions V1 portent maintenant une remise Stripe limitee a `12 mois`, tracee aussi en metadata de souscription;
- en cas d'echec coupon ou snapshot:
  - aucun `discounts` n'est envoye a Stripe;
  - aucun snapshot remisé n'est conserve;
  - le checkout continue au prix catalogue Stripe de base;
- la facture PDF lit d'abord la ligne de commande; le fallback `offre_client` ne sert plus qu'au secours legacy quand la ligne est vide.

## Etat 2026-04-04 — `Mes joueurs`: perimetre de sessions et classement complet deroulable

Correctif fonctionnel cote PRO:
- dans `Mes joueurs`, chaque tableau de classement rappelle maintenant explicitement son perimetre de calcul juste avant la ligne `Attribution des points par session`:
  - `Classement calculé sur X session(s) jouée(s) depuis le début de la saison`;
- le dashboard reconsomme pour cela les nouveaux compteurs exposes par le moteur global de leaderboard, sans logique metier recalculee dans la vue;
- quand un classement depasse `10` lignes, un simple lien souligne `Afficher le classement complet` permet maintenant de derouler toute la liste, puis `Replier le classement` la rebascule en `Top 10`;
- le titre du tableau bascule en meme temps de `Top 10 des joueurs/equipes sur la saison selectionnee` vers `Classement complet sur la saison selectionnee`.

## Etat 2026-04-03 — Signup pro: reutiliser le compte existant si `email + nom client` sont identiques

Correctif fonctionnel cote PRO:
- le write path `pro/web/ec/modules/compte/client/ec_client_script.php` ne cree plus systematiquement un nouveau compte lors d'un signup public;
- avant creation, il tente maintenant de retrouver un couple existant `email contact + nom client` via un helper `global`;
- si ce couple est retrouve, le flux reutilise directement `id_client` et `id_client_contact`, ouvre la session pro sur ce compte et saute les side effects de creation initiale;
- si un seul des deux champs diverge, le comportement reste inchange et un nouveau compte peut etre cree;
- la regle est volontairement stricte:
  - correspondance exacte normalisee sur `email` et `nom client` uniquement;
  - pas de fusion heuristique sur email seul ou sur nom approchant.

## Etat 2026-04-02 — Bibliothèque Quiz: le save global des séries n'upload plus deux fois les images

Correctif fonctionnel cote PRO:
- dans l'edition d'une série quiz existante, `Enregistrer` ne relance plus un second upload base64 redondant pour chaque question image;
- le mode AJAX d'edition rapide est maintenant aussi branché sur le helper serveur d'upload image déjà utilisé par les flux non AJAX;
- la création d'une question de remplacement dans un lot temporaire n'échoue plus sur les questions sans `jour_associe`: l'insert respecte maintenant le contrat SQL actuel de la table `questions`;
- le comportement métier reste inchangé pour une question seule, mais le save global de plusieurs questions avec image évite maintenant la double charge réseau/disque/SQL qui provoquait des erreurs `fetch`.

## Etat 2026-04-01 — EC: rubrique `Mes joueurs` pour organisateurs ABN/PAK/CSO non TdR

Correctif fonctionnel cote PRO:
- une nouvelle entree de navigation `Mes joueurs` est disponible dans l'EC pour les seuls comptes organisateurs non TdR dont le pipeline est `ABN`, `PAK` ou `CSO`, juste sous `Mon agenda`;
- cette entree est maintenant masquee si le client n'a encore aucune session historique archivée non demo et complete, afin d'eviter une page `Mes joueurs` vide sur un compte sans historique;
- le CTA de navigation `Je commande / Tarifs & commande` est maintenant stabilise dans le shell EC a la fois par une classe locale dediee, par un verrouillage dimensionnel inline des marges/largeur, du padding horizontal et du padding vertical au rendu HTML, et par un gutter de scrollbar reserve sur le conteneur scrollable du menu gauche, pour eviter les variations de largeur au fil des navigations tout en gardant une hauteur plus compacte;
- la page embarque maintenant un vrai titre de contenu `Joueurs et classements` dans un bandeau `.after-header`, comme sur les autres surfaces EC, avec compatibilite native du mode sombre deja presente dans `ec_custom.css`;
- au clic sur `Mes joueurs`, l'utilisateur arrive maintenant immediatement sur la page; un ecran d'attente avec spinner est affiche seul pendant qu'un chargement asynchrone recupere ensuite uniquement le fragment utile du dashboard, sans recharger le shell EC complet;
- sur cette page `Mes joueurs`, le widget chat Brevo est maintenant explicitement desactive pour eviter les erreurs front `BrevoConversations is not defined` dans ce contexte;
- si le fragment async de `Mes joueurs` revient vide, la vue ne laisse plus une page blanche: elle bascule sur le message d'etat vide deja prevu;
- l'URL dediee `/extranet/players` ouvre une page de pilotage avec une synthese sessions/participants connectes (joueurs & equipes) calculee sur toute la periode d'activite et rappel `Membre depuis` integre a ce bloc, avec les tops directement affiches en bas de cette synthese;
- dans cette synthese, le total `Sessions organisees` reste aligne sur le reporting BO: les sessions papier non demo et completes sont comptees meme sans participation remontee, tandis que les sessions numeriques doivent avoir au moins une participation fiable pour etre comptabilisees;
- le detail par jeu de la synthese est maintenant integre directement dans les 2 KPI principaux:
  - `Sessions organisees` affiche le total puis le detail `Cotton Quiz / Blind Test / Bingo Musical`;
  - `Participants inscrits` affiche le total puis le detail par jeu avec granularite adaptee (`equipes` pour `Cotton Quiz`, `joueurs` pour `Blind Test` et `Bingo Musical`);
- l'ancien tableau de detail par jeu sous la synthese a ete supprime;
- le conteneur de synthese est maintenant rendu sur fond transparent, sans padding de carte, pour laisser ressortir visuellement les blocs KPI et ameliorer la lisibilite des contrastes texte;
- le filtre des classements repose maintenant sur une annee d'activite puis un trimestre civil (`Janvier-Mars`, `Avril-Juin`, `Juillet-Septembre`, `Octobre-Decembre`), avec selection par defaut sur le trimestre en cours s'il contient au moins une session qui alimente reellement un classement, sinon sur le dernier trimestre qui contient effectivement des donnees de classement;
- les listes `Annee` et `Trimestre` ne proposent maintenant que les periodes qui ont de vraies donnees de classement exploitables, ce qui evite de retomber sur la periode par defaut quand l'utilisateur choisit un trimestre valide;
- la detection des periodes exploitables pour `Mes joueurs` est maintenant alignee sur les memes sources que les classements reels, y compris les sources runtime recentes non EP;
- le filtre trimestre se met a jour automatiquement a chaque changement d'annee ou de trimestre, sans CTA `Filtrer` ni lien `Reinitialiser`, et ne recharge plus que la zone `Classements par jeu`;
- dans `Classements par jeu`, l'ordre est maintenant pilote par un score agrege:
  - `500 / 300 / 200` points au total pour les rangs `1 / 2 / 3` sur `Cotton Quiz` / `Blind Test`;
  - `500 / 300 / 200` points au total pour les gains de phase `Bingo / Double ligne / Ligne` sur `Bingo Musical`;
  - `100` points pour une simple participation sans podium ni gain de phase;
  - le nb de participations reste visible entre parentheses a cote du nom;
- pour `Cotton Quiz`, les sessions historiques pre-runtime peuvent aussi recuperer leurs bonus podium via la table legacy `championnats_resultats`;
- pour `Bingo Musical`, le classement reste affiche sur les sessions runtime scorables de la periode; seules les sessions historiques sans gagnants de phase recuperables de facon fiable sont exclues, avec une mention inline discrète en italique pour prevenir l'utilisateur;
- le compteur principal affiche aussi, seulement si la période contient au moins une session papier, une mention discrète rappelant que les joueurs papier non inscrits aux sessions ne sont pas inclus;
- l'acces direct est refuse aux comptes TdR et la surface n'est pas exposee aux contacts animateurs;
- la vue reste volontairement legere: toute l'agregation metier est preparee cote `global` par un helper unique, sans requetes SQL reconstruites dans le template;
- les changements de filtre periode ne rechargent plus systematiquement la synthese globale: celle-ci est desormais reutilisee depuis un cache de session journalier, pendant que les classements seuls sont recalcules sur la periode choisie;
- les blocs KPI de `Mes joueurs` ressortent maintenant davantage visuellement, avec un fond bleu leger base sur `#43B6E5`, une bordure teintee, une ombre discrete, et un conteneur parent allégé pour mieux les isoler;
- les titres des blocs `Classements par jeu` reutilisent maintenant les couleurs dediees de chaque jeu deja presentes dans `pro` (`Cotton Quiz`, `Blind Test`, `Bingo Musical`), avec la meme couleur de texte que les CTA du portail bibliotheque; le resultat `Top jeu` reprend aussi ce badge couleur;
- chaque classement affiche maintenant, sous son titre `Top 10`, une mention `text-muted` rappelant la regle d'attribution des points selon le jeu;
- dans la synthese, `Top equipe` est masque si aucun quiz n'a ete organise, `Top joueur` est masque si aucun `Blind Test` ou `Bingo Musical` n'a ete organise, et les libelles passent au pluriel (`Top joueurs` / `Top equipes`) en cas d'ex aequo en tete;
- les sessions demo sont exclues de bout en bout, les sessions incompletes sont ignorees, et les participations probables EP ne sont jamais utilisees;
- les blocs `Top joueur` et `Top equipe` ne sortent un leader que s'il existe un vrai ecart de participations; en cas d'ex aequo en tete devant les autres, la vue peut afficher jusqu'a 3 noms, et si tout le monde est a egalite elle affiche `-`;
- si aucune donnee exploitable n'est disponible globalement, ou sur la periode de tops/classements choisie, un message explicite l'indique dans l'interface;
- pour `Cotton Quiz`, les lignes runtime `cotton_quiz_players` sont interpretees comme des equipes: la V1 n'affiche donc qu'un classement equipes sur ce jeu.

## Etat 2026-03-26 — Confirmation de commande: le flux e-commerce route maintenant vers AI Studio transactionnel

Correctif fonctionnel transverse `pro/global`:
- le mail client de confirmation de commande n'utilise plus l'appel Brevo direct historique dans le socle e-commerce `global`;
- le point d'envoi commande/facture route maintenant vers le catalogue transactionnel AI Studio avec le code `ALL_ALL_INVOICE_MONTHLY`;
- le contenu du mail reste celui d'une confirmation de commande avec facture disponible dans l'espace pro;
- le lot ne change pas les gardes metier existantes: l'envoi reste borne a la premiere facture de l'offre et au perimetre produit/paiement deja en place;
- le destinataire reel est maintenant porte par `CONTACT_EMAIL` dans le payload AI Studio, avec transport n8n/Brevo centralise et BCC de monitoring cote webhook.

## Etat 2026-03-25 — EC desktop: la navigation gauche est resserree pour laisser plus de place au contenu

Correctif fonctionnel cote PRO:
- sur desktop, la navigation gauche EC occupe maintenant moins de largeur;
- le shell reste identique en structure et en logique de menu, mais le gain d'espace est pris principalement sur la droite afin de conserver l'alignement gauche et le marquage actif historiques;
- les elements desktop du menu (logo, liens, CTA) partagent maintenant une meme largeur utile, ce qui stabilise leur centrage sans offsets heterogenes, et les 3 icones basses sont reparties en `space-between`;
- la liste desktop `ul.navbar-nav[data-simplebar]` neutralise aussi les marges negatives heritees du theme global, pour eviter qu'elle reste plus large que le panneau et fasse apparaitre un ascenseur horizontal;
- le `navbar-collapse` desktop est maintenant recale en largeur `100%` dans son conteneur, sans compensations laterales negatives, afin que l'ensemble du bloc navigation reste proprement inscrit dans le panneau;
- le shell desktop n'applique plus de padding lateral propre; la largeur utile de navigation est maintenant portee directement a `100%` du panneau, ce qui cale le menu au plus juste dans son container;
- le footer bas desktop garde ses 3 icones en `space-between`, avec un peu plus d'air lateral; les liens d'icone sont explicites en flex et leurs `svg` sont maintenant rendus en bloc non compressible pour eviter la coupe visuelle du pictogramme `Contact`;
- sur mobile, le drawer de navigation est aussi reduit en largeur (`min(82vw, 17rem)`) y compris dans l'etat `body.sidebar-menu`, avec un override telephone sous `576px` (`min(74vw, 15rem)`); le panneau n'est plus force jusqu'en bas de page, mais borne a une `max-height` mobile, avec scroll global du drawer si besoin, ce qui garde naturellement le footer des 3 icones dans le flux visible du menu;
- le correctif est limite a une surcharge CSS locale de l'EC, sans modification du routing, des etats actifs ni des write paths e-commerce.

## Etat 2026-03-25 — Tunnel commande EC: le recap step 2 aligne l'affichage d'essai gratuit sur Stripe

Correctif fonctionnel cote PRO:
- le recap `Détail de ma commande` ne montre plus `Essai gratuit, aucun prélèvement avant le ...` pour un abonnement `CSO` qui n'obtient pas de trial au checkout Stripe;
- l'affichage du step 2 reutilise maintenant la meme regle que le write path Stripe: trial pour `INS` si l'offre le porte, exception client `712` conservee, aucun trial en contexte reseau delegue;
- on supprime ainsi une promesse visuelle incoherente sans modifier la logique de paiement elle-meme.

## Etat 2026-03-25 — Stripe e-commerce: `customer.subscription.updated` ignore le parcours reseau pour un compte independant

Correctif fonctionnel cote PRO:
- le webhook continue a traiter les vrais cas reseau support et delegation, mais ne tente plus de sync delegation reseau pour une offre non deleguee;
- un compte independant mis a jour via le portail Stripe standard reste donc sur un parcours webhook standard/no-op cote reseau;
- cela supprime le faux `blocked_reason` `delegated_context_missing`, le `stripe_action` a libelle reseau associe et l'email admin trompeur qui en decoulait;
- aucun email client nouveau n'est introduit dans ce lot, qui reste borne au patch 2;
- les emails transactionnels client specialises `update / renewal / unsubscribe` ne sont pas encore cables dans l'etat courant: leur absence reste donc attendue tant que le patch 3 n'est pas implemente;
- un futur audit ne doit pas confondre ce non-cablage patch 3 avec une regression du correctif patch 2.

## Etat 2026-03-25 — Stripe e-commerce: le read path contact webhook accepte le nommage `app_*`

Correctif fonctionnel cote PRO:
- le fatal `Call to undefined function app_client_contact_get_detail()` observe pendant la finalisation webhook Stripe est neutralise;
- `global` expose maintenant explicitement un alias `app_client_contact_get_detail(...)`, compatible avec le nommage applicatif `app_*`;
- les call sites historiques `client_contact_get_detail(...)` restent valides, ce qui evite une refonte large immediate;
- le flux commande/webhook peut donc relire le contact client avant les mails admin/client sans tomber sur ce manque de compatibilite.

## Etat 2026-03-25 — Stripe e-commerce: les writes Cotton sont verrouilles avant creation de commande

Correctif fonctionnel cote PRO:
- `payment_intent.succeeded` (PAK) et `invoice.paid` (abonnements) posent maintenant une garde persistante avant toute creation de commande Cotton;
- le webhook serialise aussi les retries concurrents via un verrou applicatif MySQL par objet Stripe (`payment_intent.id` ou `invoice.id`);
- un retry brut sur le meme `event.id` Stripe deja complete sort maintenant proprement sans reexecuter les writes Cotton;
- les tokens Stripe sont desormais poses sur la commande Cotton des l'insert, ce qui supprime la fenetre historique ou le rattachement arrivait seulement apres creation.

## Etat 2026-03-24 — Stripe ABN: les rejoues `invoice.paid` n'engendrent plus de doublons de factures internes

Correctif fonctionnel cote PRO:
- le webhook Stripe des abonnements dedoublonne maintenant les traitements `invoice.paid` sur l'`invoice.id` Stripe;
- l'identifiant de facture Stripe est persiste sur la commande Cotton, puis relu avant toute recreation ulterieure;
- un retry Stripe sur un meme paiement d'abonnement n'ajoute donc plus une nouvelle facture interne;
- les actions secondaires apres creation de commande, comme la mise a jour metadata Stripe ou l'alerte mail admin, sont maintenant journalisees sans faire echouer l'ACK du webhook.

## Etat 2026-03-24 — EC TdR: l'upload du visuel perso branding envoie maintenant une base haute resolution

Correctif fonctionnel cote PRO:
- le flux EC TdR de `Design reseau` ne plafonne plus l'upload `visuel` a `600x240`;
- `ec_branding_script.php` aligne maintenant le write path sur une cible haute `1600x640`, compatible avec le helper branding global adaptatif;
- l'EC continue donc a produire le preview / formulaire habituel, mais la source envoyee au pipeline branding n'est plus reduite aussi agressivement avant le rendu `games`;
- si un upload `logo` / `visuel` echoue maintenant (fichier trop lourd, upload partiel, erreur serveur), la page branding affiche un message clair au retour au lieu d'un echec silencieux;
- le rendu final en jeu beneficie ainsi a la fois du meilleur upload EC et des correctifs `global`/`games` sur la qualite finale et la priorite donnee a l'asset serveur.

## Etat 2026-03-24 — Désign des jeux: la confirmation de sauvegarde cible le bon formulaire

Correctif fonctionnel cote PRO:
- la modale de confirmation `Enregistrer` du design reseau soumet maintenant explicitement le formulaire `network-branding-form`;
- le conflit precedent avec l'id generic `frm`, deja utilise dans le shell EC pour le switch multi-compte, est supprime;
- le clic sur `Confirmer` n'envoie donc plus vers la home EC et enregistre bien le design.

## Etat 2026-03-24 — EC: les cookies BO de delegation sont expires des leur consommation

Correctif fonctionnel cote PRO:
- en navigation classique, un ancien passage par le BO pouvait continuer a imposer le dernier compte visite tant que les cookies `CQ_admin_gate_*` restaient vivants;
- `ec_authentification_script.php` expire maintenant explicitement ces cookies navigateur des qu'ils sont consommes;
- le comportement redevient donc coherent entre navigation privee et navigation classique.

## Etat 2026-03-24 — EC: la déconnexion nettoie complètement la session après un lien temporaire

Correctif fonctionnel cote PRO:
- `develop` et `main` n'ont pas d'ecart sur le flux auth/deconnexion concerne;
- la sortie EC via `Se deconnecter` purge maintenant l'integralite de la session d'authentification EC;
- le cookie de session PHP est aussi expire explicitement;
- les cookies BO historiques `CQ_admin_gate_*` sont eux aussi expires s'ils existent encore dans le navigateur;
- apres un acces via lien temporaire, revenir sur `signin` ne laisse donc plus d'etat residuel bloquant une connexion avec un autre login / mot de passe.

## Etat 2026-03-24 — BO: l'accès direct admin vers l'EC ne retombe plus sur `signin`

Correctif fonctionnel cote PRO:
- l'acces historique BO vers l'EC, base sur les cookies `CQ_admin_gate_client_id` / `CQ_admin_gate_client_contact_id`, fonctionne a nouveau;
- la regression venait de `ec_authentification_script.php`: une session BO deja preparee etait ensuite ecrasee parce que le script retraitait aussi les parametres `GET` de routing (`t/m/p/l`) comme une requete d'authentification;
- le bloc `formulaire / lien temporaire` ne s'execute maintenant plus quand la session BO a deja ete initialisee;
- le nouveau lien temporaire par token reste inchange et compatible avec ce correctif.

## Etat 2026-03-24 — Session test depuis une session programmée: le branding session est repris

Correctif fonctionnel cote PRO:
- depuis la fiche detail d'une session programmée, le CTA `Tester` cree toujours une session démo liee a cette session, mais cette demo recupere maintenant aussi le branding session de la session source quand il existe;
- ce CTA ouvre maintenant directement la session démo dans un nouvel onglet sur `games/master/{id_securite_session}`, sans passer par l'etape intermediaire `resume`;
- la resolution runtime du branding de session priorise desormais explicitement le branding `general_branding` de type `session`, avant les fallbacks `evenement`, puis `reseau`, puis `client`;
- la duplication de session pour une demo recopie aussi la ligne de branding session et ses assets dans le repertoire cible de la nouvelle session démo;
- on evite ainsi le retour parasite vers un branding evenement/reseau/client quand la session programmée possede deja un habillage session specifique.

## Etat 2026-03-23 — EC: connexion directe temporaire par lien, sans écran de login

Correctif fonctionnel cote PRO:
- l'EC accepte maintenant un lien temporaire de connexion directe de la forme `/extranet/authentication/script?mode=client_contact_direct_access&token=...`;
- ce lien est strictement temporaire et a usage unique: il reutilise un jeton court cote `clients_contacts`, puis l'efface immediatement apres consommation;
- le point d'entree script autorise aussi explicitement ce mode sans session preexistante, ce qui permet l'ouverture en navigation privee;
- en succes, le contact est redirige directement vers la home EC (ou l'onboarding si le compte est encore en `INS` sans solution active);
- en echec ou expiration, l'utilisateur revient sur `signin` avec un message simple indiquant que le lien n'est plus valide;
- ce mecanisme n'ajoute aucun bouton ni affichage cote front EC standard: il est pense pour un usage interne BO.

## Etat 2026-03-24 — Désign des jeux: confirmation explicite avant sauvegarde

Correctif fonctionnel cote PRO:
- la page `Désign des jeux` demande maintenant une confirmation explicite avant d'enregistrer un design;
- le clic sur `Enregistrer` ouvre une modale de confirmation;
- la modale rappelle l'impact metier: `Ce design sera affiché par défaut sur les interfaces de jeu de l'ensemble de tes affiliés.`
- le footer des CTA est aussi reequilibre dans les vues `Désign des jeux` et `Modifier le design`, avec un espacement haut/bas symetrique;
- si un ajustement de hauteur est necessaire pour rester visuellement aligne avec la preview, il est absorbe dans l'espace bas du contenu, juste au-dessus du footer.

## Etat 2026-03-24 — Désign des jeux: apercu reel via session démo

Correctif fonctionnel cote PRO:
- quand un design reseau actif existe, la `view` affiche maintenant le lien `Voir sur une session démo` a cote du badge d'etat dans la carte, avec une icone d'ouverture externe visible;
- ce CTA ouvre une vraie session démo dans un nouvel onglet, pour voir le rendu final du branding dans le contexte jeu;
- la demo priorise un contenu deja partage avec le reseau, avec preference `blindtest`, puis `bingo`, puis `quiz`;
- si aucun contenu partage exploitable n'est disponible, le fallback ouvre une demo `blindtest` sur une playlist validee parmi les plus populaires;
- la creation de session ne se fait qu'au clic, jamais au simple chargement de la page `Désign des jeux`;
- la `form` d'edition ne duplique pas ce CTA;
- le module branding charge aussi explicitement `ec_bibliotheque_lib.php`, sinon les helpers `clib_*` requis pour choisir la demo restent absents et le CTA ne peut pas sortir.

## Etat 2026-03-23 — Navigation: le CTA `Tarifs & commande` n'exclut plus le reseau Beer's Corner

Correctif fonctionnel cote PRO:
- le CTA de navigation `Je commande / Tarifs & commande` n'applique plus l'exception hardcodee qui masquait cette entree pour tous les affiliés rattaches au reseau `1294` (Beer's Corner);
- desormais, l'affichage du CTA redevient pilote par les seules regles generales: pas d'offre active effective, pas de restriction TdR self-service, et cas `pending_payment` explicitement autorise;
- un affilié Beer's Corner sans offre active, meme s'il conserve seulement des offres terminees en historique, retrouve donc bien le CTA de commande dans la nav.

## Etat 2026-03-23 — Offres TdR: l'historique des delegations terminees re-affiche la date de fin

Correctif fonctionnel cote PRO:
- dans `Offres` cote TdR, l'historique des offres deleguees `hors cadre` terminees re-affiche maintenant `Abonnement terminé depuis le ...`;
- le trou ne venait pas de `ec_offres_include_detail.php`, qui savait deja afficher cette mention quand il recevait bien le contexte `hors cadre`;
- la perte d'affichage venait du point d'appel historique dans `ec_offres_view.php`, qui reinjectait ces offres terminees avec `offre_detail_is_network_hors_cadre = 0`;
- les lignes d'historique TdR deleguees `hors cadre` transportent maintenant ce flag jusqu'au composant de detail, ce qui reactive la branche de rendu deja presente pour la date de fin.

## Etat 2026-03-23 — Mes affiliés: la remise reseau est expliquee et mise en contexte

Correctif fonctionnel cote PRO:
- le premier bloc de `Mes affiliés` garde le lien d'affiliation puis affiche maintenant un encart dedie a la remise reseau;
- si une remise est deja active, l'encart affiche un angle marketing (`Une remise qui évolue avec ton réseau !`), le pourcentage actuellement applique aux souscriptions reseau et un lien court `Calculée sur X affilié(s) actif(s)*` vers une explication inline en bas de page;
- si la remise reseau courante vaut `0%`, l'encart remplace le recapitulatif par un message d'amorcage: `Profite d'une remise réseau de 5% sur tes souscriptions réseau dès ta 2e commande !`;
- l'explication inline de bas de page rappelle que la remise reseau s'applique dynamiquement aux souscriptions commandees par le reseau et peut evoluer a la hausse comme a la baisse selon les affiliés actifs, avec rappel des paliers;
- dans le tableau `Mes affiliés`, le total de sessions programmees peut etre complete par `À venir : X session(s)` seulement si ce compteur est strictement positif;
- le bloc d'action d'un affilié sans offre active peut afficher sous `Commander` la mention `Remise réseau de x% !` uniquement si une remise reseau s'applique reellement;
- les en-tetes, cellules et CTA du tableau sont maintenant centres verticalement, sans etirer les boutons sur toute la largeur de leur colonne.

## Etat 2026-03-23 — Factures PDF: le pourcentage de remise reseau est visible sur la ligne produit

Correctif fonctionnel cote PRO:
- les factures PDF PRO completent maintenant le libelle `Remise réseau` avec son pourcentage quand une remise s'applique, par exemple `Remise réseau : 5,00 %`;
- le rendu PDF relit d'abord `remise_nom` et `remise_pourcentage` sur la ligne de commande, puis bascule si besoin sur le detail de l'offre client liee a la commande pour couvrir aussi des factures historiques dont la ligne stockee etait incomplete;
- la generation des nouvelles lignes de commande inclut elle aussi le pourcentage dans le libelle de remise pour garder un historique coherent.

## Etat 2026-03-23 — Mes affiliés: les sessions a venir sont detaillees sous le total

Correctif fonctionnel cote PRO:
- dans la colonne `Infos` du tableau `Mes affiliés`, chaque affilié garde son total de sessions programmées;
- une ligne supplementaire `À venir : X session(s)` apparait maintenant juste en dessous;
- ce compteur reprend les sessions non demo completes dont la date est superieure ou egale a la date du jour.

## Etat 2026-03-23 — Mon offre affilié: l'historique garde aussi les offres deleguees terminees

Correctif fonctionnel cote PRO:
- le rendu affilié savait deja afficher `Abonnement terminé depuis le ...` pour une offre deleguee terminee;
- les offres deleguees vues par un affilié re-affichent aussi `Offre pilotée par {nom_TdR}` juste sous la ligne `Référence`, avec la couleur du badge `Déléguée`;
- cote TdR, la mention `Délégation de l'offre à {nom_affilié}` reprend maintenant cette meme couleur et ce meme niveau de mise en avant;
- la perte d'affichage venait en fait du helper global `app_ecommerce_offres_client_get_liste()`, qui ne chargeait les offres deleguees qu'en fallback si aucune offre propre n'existait;
- un affilié ayant a la fois une offre propre et une offre deleguee terminee retrouvait donc maintenant cette offre deleguee dans `Historique de mes commandes`;
- la correction se fait en amont du rendu, via une requete unique qui remonte ensemble les offres propres et les offres deleguees visibles pour l'affilié.
- le passage historique reinitialise aussi des variables de contexte du composant de detail avant chaque `require`, afin d'eviter qu'une carte precedente ne laisse un etat residuel sur la suivante.
- enfin, dans `ec_offres_include_detail.php`, la branche deleguee du cas `ABN SANS engagement` a ete sortie du `if (id_etat==3)` qui la rendait inatteignable pour une offre terminee `id_etat==4`.

## Etat 2026-03-23 — Offre 12 sans engagement: le rendu affilié `Mon offre` reste correct

Correctif fonctionnel cote PRO:
- l'offre catalogue `12` peut repasser `sans engagement` sans faire disparaitre, cote affilié, la mention `Abonnement terminé depuis le ...` sur une offre deleguee terminee;
- le rendu `Mon offre` ne depend plus a tort de la branche `avec engagement` pour afficher la date de fin d'une offre deleguee terminee;
- les autres comportements historiques de l'offre `12` restent alignes avec sa semantique existante dans le code: abonnement mensuel sans date de fin initiale par defaut, wording non engage sur les lignes de commande, et cloture cron uniquement quand une `date_fin` reelle existe.

## Etat 2026-03-23 — Navigation EC: le lien `Branding` est desactive

Correctif fonctionnel cote PRO:
- le lien de navigation `Branding` n'est plus affiche dans le shell EC;
- la regle legacy basee sur le cookie `CQ_admin_gate_client_id` est maintenant neutralisee explicitement dans `ec.php`;
- la page `/extranet/account/branding/view` et son contexte `Design du réseau` restent existants, mais ne sont plus proposes via cette entree de nav.

## Etat 2026-03-23 — Navigation EC: `Ma fiche lieu` reste masquee pour une TdR meme en test

Correctif fonctionnel cote PRO:
- le lien `Ma fiche lieu` reste reserve aux comptes non TdR;
- l'ouverture historique aux comptes `TEST` est conservee uniquement hors TdR;
- une tete de reseau ne voit donc plus ce lien de navigation, meme si son compte est en etat `TEST`.

## Etat 2026-03-23 — TdR/Affiliés: `Mes affiliés` expose aussi le support réseau en attente

Correctif fonctionnel cote PRO:
- la page `Mes affiliés` continue d'afficher la micro-synthese du support reseau actif au-dessus du tableau;
- cette micro-synthese apparait maintenant aussi quand l'`Abonnement reseau` est `En attente de paiement`;
- cette synthese `En attente de paiement` ne s'affiche que si l'offre support porte un montant reellement facturable (`prix_ht > 0`);
- dans ce cas, le lien de la synthese renvoie vers `Offres` et non plus vers un declenchement direct du checkout;
- le CTA de paiement/activation reste donc pose sur la page `Offres`, conforme au parcours demande.

## Etat 2026-03-20 — TdR/Affiliés: headers de pages simplifies + retours home

Correctif fonctionnel cote PRO:
- les pages TdR `Mes affiliés`, `Design du réseau` et `Jeux sélectionnés` n'affichent plus leurs sous-titres descriptifs de header;
- les blocs internes `Mes affiliés` et `Design du réseau` retirent aussi les sous-titres purement explicatifs devenus redondants;
- quand ces pages sont ouvertes depuis la home reseau, un lien `← Retour à l'accueil` apparait au-dessus du titre;
- cote affilié, la page `Jeux sélectionnés` retire aussi son sous-titre de header;
- le lien `← Retour à la bibliothèque` sur cette page affilié reutilise maintenant le meme style que `← Retour au catalogue`.

## Etat 2026-03-20 — Jeux sélectionnés: blocs d'intro refondus sur le pattern hero

Correctif fonctionnel cote PRO:
- la page `Jeux sélectionnés` garde ses 2 blocs d'intro/outillage distincts, cote TdR et cote affilié;
- ces 2 blocs adoptent maintenant un layout `visuel a gauche / texte a droite`, aligne sur le hero home reseau;
- le visuel gauche reutilise l'image `catalogue_contenus.png` deja utilisee sur la home pour `Jeux sélectionnés`;
- les textes passent sur la meme hierarchie que les autres blocs reseau, avec CTA en bas quand il existe deja;
- les chips de scope TdR (`Contenus réseau / Cotton / Communauté / Mine`) restent presentes sous le 2e bloc.

## Etat 2026-03-20 — Home TdR: hero affiliation aligne sur le split visuel INS

Correctif fonctionnel cote PRO:
- la home TdR conserve sa 1re ligne desktop `2/3 - 1/3`, avec le bloc de synthese reseau toujours separe a droite;
- le hero gauche n'utilise plus une image de fond pleine largeur avec mini-carte inline;
- ce hero adopte maintenant un layout `visuel a gauche / contenu a droite`, aligne sur le pattern des widgets home INS sans offre;
- la partie gauche affiche maintenant le `nom du compte TdR` a la place de `Réseau Cotton`, sans pastilles basses;
- la partie droite ouvre sur un titre `Ton lien d'affiliation` traite comme les autres titres de bloc reseau;
- ce bloc deroule ensuite trois lignes avec icone `check`: `Développe ton réseau`, `Diffuse tes couleurs`, `Choisis tes jeux`;
- la phrase `Partage ce lien pour permettre à tes affiliés de rejoindre ton réseau.` reste au-dessus du lien;
- le lien d'affiliation est affiche juste au-dessus du CTA de copie, avec feedback de copie;
- le hero utilise maintenant un CTA unique `Copier le lien`, et retire le bouton `Copier` secondaire inline;
- la partie visuelle gauche garde l'univers reseau sans les pills de promesse precedentes.

## Etat 2026-03-19 — TdR: bloc droit hero recentre sur une vraie vue rapide reseau

Correctif fonctionnel cote PRO:
- la home TdR conserve son hero gauche et ses trois cartes reseau de la 2e ligne;
- le bloc droit de la 1re ligne se lit maintenant comme une synthese reseau et non plus comme trois raccourcis empiles;
- ce bloc affiche un titre conditionnel `Par où commencer ?` quand le compte est encore vide, sinon `Vue rapide du réseau`;
- la donnee `Affiliés` passe en premier, avec mise en avant du total et pill `X actifs · Y inactifs`;
- `Désign des jeux` et `Jeux sélectionnés` reprennent maintenant le meme style de label que `Affiliés`, tout en restant presentes comme des etats/leviers (`À faire` / `Prêt`);
- les `sessions reseau a venir` restent visibles en footer discret, et le lien vers l'agenda reseau est desactive tant qu'aucune session n'est programmee;
- le bloc `Agenda du réseau` harmonise aussi son titre avec les autres cartes reseau, et le nom des affiliés dans cette carte reutilise maintenant le violet d'accent de la page a la place du rose;
- les routes et helpers metier utilises restent inchanges: liste affiliés, branding reseau, jeux reseau et agenda reseau.

## Etat 2026-03-19 — V1 offres reseau / offres deleguees: reference finale

Reference produit a retenir:
- l'offre support `Abonnement reseau` n'existe visiblement qu'en `Active`, `En attente` ou `Terminee`;
- une offre support `Abonnement reseau` n'est jamais auto-creee en V1: sa creation reste un write path BO explicite;
- `Mon offre` / `Offres & factures` et `Mon reseau` restent des lectures front pures: aucune simple lecture runtime ne doit recreer un support `En attente`;
- l'ecran BO `reseau_contrats` reste une surface de lecture/pilotage: aucun reclassement reseau implicite ne doit partir d'un simple chargement de page;
- un support `Active` autorise seulement les activations incluses `cadre` explicites d'affilies inactifs, dans la limite du quota;
- le BO peut forcer un support en `Active` sans paiement et lui conserver une `date_fin` explicite pour une terminaison locale planifiee;
- cette meme regle vaut aussi des la creation BO du support: si `Active` est choisi explicitement, le support ne doit pas retomber en `En attente` au save;
- un support `Active` n'absorbe jamais automatiquement une delegation `hors_cadre` existante, qui reste `hors_cadre`;
- une delegation `hors_cadre` active ne peut plus etre remplacee en V1: elle peut seulement etre resiliee;
- aucun endpoint PRO direct ni tunnel Stripe ne doit pouvoir relancer un remplacement `hors_cadre`, meme sans bouton visible en interface;
- le passage BO du support a `Terminee` clot uniquement les delegations incluses `cadre` liees a ce support;
- la fin effective du support via cron applique la meme regle que le BO manuel: seules les delegations incluses `cadre` liees a ce support sont cloturees;
- apres cette cloture BO, un affilié sans autre offre active doit retomber en pipeline `CSO`, la liste `Mes affiliés` ne doit plus afficher de faux `Actif abonnement réseau`, et `Offres` TdR ne doit jamais exposer les incluses `cadre`, meme en historique;
- une resiliation Stripe fin de periode du support reste visible dans `Mon offre`, sans impact automatique sur les offres deleguees `hors_cadre`;
- cote affilies, les libelles metier a conserver sont `Actif via le reseau` sans support actif et `Actif en supplement` avec support actif.

## Etat 2026-03-18 — Référence actuelle TdR / Affiliés

Etat courant à retenir:
- navigation gauche TdR:
  - `Affiliés`
  - `Agenda réseau` si au moins une session officielle réseau à venir existe
  - `Désign des jeux`
  - `Jeux sélectionnés`
- home TdR:
  - duo de blocs reseau au-dessus des widgets
  - en desktop: layout `2/3 - 1/3`, en mobile: colonne
  - bloc `Réseau Cotton` avec image de fond reseau + mini-carte lien d'affiliation integree et maintenue a droite en desktop
  - bloc de synthese reseau simple et visuel a droite du hero
  - widgets `Mes affiliés`, `Design du réseau`, `Jeux sélectionnés` et `Agenda de mon réseau`
  - style home: header transparent, avec seule la ligne icône + titre surlignée en jaune `#FFDB03`
- page `/extranet/account/network`:
  - titre `Mes affiliés`
  - carte dédiée `Lien d'affiliation`
  - micro-synthese support active sous la phrase d'aide (`Abonnement reseau actif` + `Nombres d'affiliés activables via l'abonnement réseau : X/Y`)
  - tableau de pilotage simplifié `Affilié / Statut / Infos / Action`
  - pas de bloc `Personnalisation`, pas de bloc Jeux sélectionnés, pas de détail d'offre dans les lignes
- page `/extranet/account/branding/view`:
  - titre `Design du réseau`
  - plus de lien haut de page `Retour a Mon reseau`
- hub `Jeux sélectionnés`:
  - si aucun jeu n'est partagé, affichage direct des 3 blocs jeux vers les catalogues standards
  - si au moins un jeu est partagé, affichage du CTA `Ajouter des jeux` avec le comportement actuel

## Etat 2026-03-18 — TdR: finition UI sur home, affiliés, design et Jeux sélectionnés

Correctif fonctionnel cote PRO:
- la home TdR demarre maintenant par un hero visuel premium, avec promesse reseau et rappel d'usage du compte reseau;
- le lien d'affiliation y est integre directement dans le hero avec un bouton `Copier`;
- la home TdR expose les widgets `Mes affiliés`, `Design du réseau` et `Jeux sélectionnés`, plus `Agenda de mon réseau`;
- ces widgets home utilisent maintenant un header transparent, avec la seule ligne icone + titre surlignée en jaune `#FFDB03`;
- `/extranet/account/network` remplace son titre `Mon réseau` par `Mes affiliés`;
- `/extranet/account/network` ne garde plus que le lien d'affiliation puis un tableau de pilotage simplifié;
- la page retire les blocs `Personnalisation` / Jeux sélectionnés et le détail d'offre dans chaque ligne affilié;
- la colonne `Infos` remonte la métrique existante `sessions programmées`;
- la colonne `Action` garde `Activer` / `Désactiver` / `Commander` quand légitime, sinon renvoie vers `Offres` filtré sur l'affilié;
- l'accès `Désign des jeux` depuis la home et depuis `Mes affiliés` injecte maintenant `nav_ctx=network_design` pour stabiliser le menu gauche sur `Désign des jeux`;
- `Jeux sélectionnés` retire les liens retour `Mon réseau`;
- si aucun jeu n'est partagé, le hub affiche directement les 3 blocs de jeux vers les catalogues standards;
- si au moins un jeu est partagé, ces 3 blocs sont masqués et le CTA `Ajouter des jeux` conserve le comportement actuel.

## Etat 2026-03-19 — TdR: hero home recentre sur la promesse reseau et l'acquisition affiliée

Correctif fonctionnel cote PRO:
- la home TdR ouvre maintenant sur une 1re ligne `2/3 - 1/3`, sans refonte du reste de la page;
- en desktop, le hero conserve une largeur `2/3` et s'accompagne d'une carte synthese `1/3`; en mobile, les deux blocs repassent en colonne;
- le bloc `Réseau Cotton` garde le visuel reseau local en image de fond avec overlay pour la lisibilite, reintegre le lien d'affiliation dans une mini-carte a droite maintenue en bord droit sur desktop, et retire le texte marketing central ainsi que la puce haute;
- le bloc de droite concentre maintenant les principales infos reseau: nombre d'affilies, repartition `Actifs / Inactifs`, sessions reseau a venir, statut design partage et volume de jeux partages;
- les pills de valeur ferment toujours ce hero et sont poussees au plus bas du bloc;
- la grille reseau sous le hero reaffiche `Mes affiliés`, puis `Désign des jeux`, puis `Jeux sélectionnés`;
- les trois cartes `Mes affiliés`, `Design du réseau` et `Jeux sélectionnés` utilisent maintenant le meme pattern visuel avec grand visuel en tete;
- `Mes affiliés` utilise le visuel statique `santeuil-cafe-nantes.jpg`;
- la carte `Design du réseau` reste refondue avec un grand visuel en tete;
- cette carte utilise par defaut `cotton-reseau-marque-blanche.jpg`, puis le remplace par le visuel branding reseau de l'utilisateur s'il est defini;
- `Jeux sélectionnés` utilise le visuel statique `jeu-qr-code-smartphone.jpg`;
- les visuels de ces trois cartes sont maintenant plus compacts, avec une hauteur reduite de moitie et un cadrage image centre;
- un leger filtre colore inspire du hero est applique sur ces visuels pour mieux les harmoniser avec le bloc 1;
- les recaps detailles de statut reseau ne sont plus repetes dans ces trois cartes et sont regroupes dans la carte synthese de 1re ligne;
- la carte `Design du réseau` garde le meme style de CTA footer `Personnaliser` que `Mes affiliés` et `Jeux sélectionnés`, et le visuel haut ne montre plus de liseré blanc parasite;
- le micro-texte du lien explique maintenant clairement le parcours: diffuser le lien, faire rejoindre de nouveaux etablissements, puis les retrouver dans `Mes affiliés` pour piloter activations, offres et activite;
- le mecanisme de copie et la source de l'URL d'affiliation restent ceux deja utilises sur la home TdR;
- aucun CTA commercial additionnel ni second gros bloc `lien d'affiliation` n'est introduit sous le hero.

## Etat 2026-03-18 — TdR: la home expose 3 raccourcis réseau

Correctif fonctionnel cote PRO:
- la home TdR remplace le bloc réseau précédent par 3 widgets raccourcis alignés avec la navigation:
  - `Mes affiliés`
  - `Désign des jeux`
  - `Jeux sélectionnés`
- le widget `Mes affiliés` affiche le nombre d'affiliés rattachés, puis le détail `Actifs / Inactifs` quand au moins un affilié existe;
- le widget `Désign des jeux` affiche un statut simple selon qu'un branding réseau actif est partagé ou non;
- le widget `Jeux sélectionnés` affiche le nombre de jeux actuellement partagés avec les affiliés;
- l'agenda réseau existant reste affiché sous ces 3 raccourcis;
- son widget affiche maintenant le total de sessions officielles réseau et un lien `Voir l'agenda réseau complet`;
- une entrée nav `Agenda réseau` est ajoutée sous `Mes affiliés`;
- la page `Agenda réseau` réutilise la vue agenda en agrégant les sessions officielles des affiliés, sans CTA de programmation;
- les cartes de cet agenda réseau restent elles aussi en consultation seule, sans accès au jeu ni fallback vers les offres;
- si aucune session officielle réseau à venir n'existe, le widget n'affiche ni `(0)` ni CTA, et l'entrée nav `Agenda réseau` est masquée;
- le widget home et la nav pointent directement vers `/extranet/start/games?network_agenda=1`, car le raccourci `/extranet/games` perdait ce contexte sur sa redirection.
- la navigation TdR inverse aussi `Désign des jeux` et `Jeux sélectionnés` pour reprendre ce même ordre.

## Etat 2026-03-18 — TdR: `Offres & factures` expose les offres portees par le reseau

Correctif fonctionnel cote PRO:
- pour une tete de reseau, le menu nav `Mon offre` devient `Offres & factures`;
- dans le sous-menu compte, l'onglet principal devient `Offres` avec `Factures` et `Equipe`;
- l'onglet `Offres` liste maintenant les offres portees par la TdR de facon unitaire:
  - abonnement reseau support;
  - offres deleguees `hors cadre` payees par le reseau pour les affilies;
- l'onglet `Factures` propose maintenant le meme filtre simple par affilie pour isoler les factures des offres deleguees concernees;
- les delegations incluses dans l'abonnement reseau (`cadre`) ne figurent plus en propre dans `Offres`;
- l'abonnement reseau est force en premiere position;
- les offres deleguees `hors cadre` ne sont plus resumees dans un bloc agrégé, et chaque ligne precise l'affilie concerne;
- si plusieurs affilies ont des offres `hors cadre`, un filtre simple par affilie apparait en haut de page;
- les offres deleguees `hors cadre` conservent un CTA `Gerer l'offre` en ouverture differee, sans preparer Stripe au chargement de page.
- leurs libelles de periode / cloture / resiliation sont maintenant alignes sur l'affichage classique;
- le libelle en doublon `Affilie concerne` est retire de ce rendu, la ligne `Delegation de l'offre a ...` portant deja la bonne cible;
- l'abonnement reseau et les offres deleguees actives affichent maintenant `Periode en cours : du ... au ...`;
- une offre deleguee active avec fin deja actee conserve en plus `Cet abonnement delegue se termine le ...`;
- une offre deleguee historisee affiche `Abonnement termine depuis le ...`;
- l'historique TdR n'est plus charge par defaut et s'ouvre explicitement avec pagination simple;
- le chargement de cet historique evite maintenant le comptage complet au premier affichage et ne charge que la page demandee plus un indicateur de page suivante.
- les branches generiques de periode d'abonnement sont desormais neutralisees pour les offres deleguees afin d'eviter tout doublon de libelle.

## Etat 2026-03-18 — TdR: la bibliothèque réseau devient l'unique entrée de partage

Correctif fonctionnel cote PRO:
- une tête de réseau n'a plus le menu nav `Les jeux` dans le shell `/pro`;
- le partage réseau passe désormais par `Jeux sélectionnés` puis `/extranet/games/library?network_manage=1`;
- sur cette page, les trois CTA d'ajout sont remplacés par un seul bouton `Ajouter des jeux` qui ouvre le portail standard `/extranet/games/library`;
- sur le portail standard `/extranet/games/library`, la carte `Les jeux {nom_TdR}` n'est plus affichée pour la TdR mais reste visible pour les affiliés.
- sur les fiches détail de la bibliothèque, une TdR conserve bien `Lancer une démo` et `Partager avec mon réseau` / `Retirer du réseau`; seul le CTA de programmation est retiré.

## Etat 2026-03-19 — PRO EC: création de session verrouillée et pagination bibliothèque rétablie

Correctifs fonctionnels cote PRO:
- tous les chemins de programmation encore actifs côté PRO/EC verrouillent désormais le premier submit côté front jusqu'au retour serveur;
- cela couvre le choix du jeu, la bascule de mode agenda (`rapide` / `bibliothèque`), l'étape de paramétrage, le programmateur calendrier legacy et la création depuis la bibliothèque;
- les doubles clics et doubles validations clavier (`Enter`) n'envoient plus plusieurs créations de session pendant l'état de chargement;
- l'état visuel existant `Préparation en cours ...` devient la source unique du mode busy, avec réactivation automatique si la page est réaffichée sans création aboutie;
- dans `Mes playlists/séries`, la grille repasse à `11 contenus + 1 carte Ajouter` quand la carte d'ajout est visible, et reste à `12 contenus` sinon;
- depuis une fiche session agenda ouverte pour remplacer une playlist/série, la pagination de la bibliothèque reste disponible et conserve le contexte de remplacement sur les pages suivantes.

## Etat 2026-03-18 — TdR: `Jeux sélectionnés` rejoint la navigation dédiée

Correctif fonctionnel cote PRO:
- la navigation TdR expose maintenant trois entrées dédiées dans le bloc réseau:
  - `Mes affiliés`
  - `Jeux sélectionnés`
  - `Désign des jeux`
- `Jeux sélectionnés` ouvre directement `/extranet/games/library?network_manage=1`;
- l'état actif du contexte `network_manage=1` ne surligne plus `Mes affiliés`.

## Etat 2026-03-18 — TdR: `Mes affiliés` et `Désign des jeux` structurent maintenant la nav

Correctif fonctionnel cote PRO:
- l'entrée nav `Mon réseau` est renommée `Mes affiliés`;
- une nouvelle entrée `Désign des jeux` est ajoutée juste en dessous;
- cette entrée ouvre directement `/extranet/account/branding/view`.

## Etat 2026-03-18 — TdR: le menu `Media Kit` disparait de la navigation

Correctif fonctionnel cote PRO:
- une tête de réseau ne voit plus le menu `Media Kit` dans la navigation gauche;
- ce point d'entree n'a pas d'utilite produit pour une TdR dans l'etat actuel;
- les autres profils conservent le comportement historique du menu.

## Etat 2026-03-18 — TdR: le menu `Mon agenda` disparait de la navigation

Correctif fonctionnel cote PRO:
- une tête de réseau ne voit plus le menu `Mon agenda` dans la navigation gauche;
- ce point d'entree n'a plus d'utilite produit pour une TdR depuis la fermeture des accès de programmation en propre;
- les autres profils conservent le comportement historique du menu.

## Etat 2026-03-18 — Mon reseau: hotfix perf sur les portails Stripe

Correctif fonctionnel cote PRO:
- la page `/extranet/account/network` ne prepare plus de session portail Stripe pendant son rendu initial;
- le cas le plus couteux, `Gérer l’offre` sur une offre affiliée `hors cadre`, passe maintenant par une redirection locale qui n'ouvre Stripe qu'au clic;
- la lecture de la page reste donc purement locale tant que l'utilisateur ne demande pas explicitement un portail;
- les messages d'erreur portail restent exposes via le mecanisme de flash existant.

## Etat 2026-03-18 — TdR: la commande en propre et la programmation hors démo sont coupees

Correctif fonctionnel cote PRO:
- une tête de réseau ne voit plus le CTA nav `Tarifs & commande` / `Je commande`;
- la home TdR reutilise maintenant les widgets reseau existants, avec `Mon réseau` et `Agenda de mon réseau`, a la place des widgets ecommerce standard;
- depuis une fiche détail bibliothèque, une TdR ne peut plus lancer de programmation hors démo;
- le garde-fou ne repose pas seulement sur l'UI: les POST bibliothèque de programmation hors démo sont aussi refusés serveur pour une TdR;
- le CTA `Lancer une démo` reste disponible.

## Etat 2026-03-17 — Mon offre: hypothese d'agregat `hors cadre` abandonnee (historique)

Historique explicitement depasse:
- ce lot avait ouvert l'hypothese d'un agregat `Offres affilies a la charge de votre reseau` directement dans `Mon offre`;
- cette hypothese n'est plus la reference finale V1.

Reference finale a retenir:
- la lecture produit canonique cote TdR passe par `Offres & factures`;
- l'offre support `Abonnement reseau` y reste visible avec ses etats `Active` / `En attente` / `Terminee`;
- les offres deleguees `hors_cadre` y sont listees unitairement si elles sont encore actives et facturees a la TdR;
- aucun agregat `hors cadre`, aucun remplacement et aucun parcours `Changer d'offre` ne font partie de la verite finale.

## Etat 2026-03-19 — TdR: micro-synthese abonnement reseau retablie dans `Mes affiliés`

Correctif fonctionnel cote PRO:
- `/extranet/account/network` reaffiche sous la phrase d'aide de `Mes affiliés` une ligne compacte rattachee au tableau;
- cette ligne montre le badge `Abonnement reseau actif` puis `Nombres d'affiliés activables via l'abonnement réseau : X/Y`;
- `X/Y` reutilise strictement la couverture canonique (`quota_remaining/quota_max`) de `app_ecommerce_reseau_contrat_couverture_get_detail(...)`;
- la ligne reste masquee si le support n'est pas actif/exploitable ou si le quota n'est pas definissable;
- un lien discret `Voir dans Offres` renvoie vers `/extranet/account/offers`, sans reintroduire de bloc `Facturation`.

## Etat 2026-03-17 — Mon reseau: hiérarchie finale V1 simplifiée

Correctif fonctionnel cote PRO:
- `/extranet/account/network` retire maintenant le bloc `Facturation` de sa hiérarchie visible;
- le haut de page affiche d'abord `Lien d'affiliation`, avec copie visible et message d'aide dynamique selon abonnement reseau actif ou non;
- le bloc `Personnalisation` expose immédiatement les CTA `Design reseau` et `Contenus reseau`, sans changer leurs routes canoniques deja retenues;
- la zone `Mes affiliés` arrive directement ensuite avec une synthese compacte (`Actifs / Inactifs`, badge `Abonnement reseau`, `Inclus dans votre abn reseau / Places restantes`) visuellement rattachee au tableau;
- la verite metier des statuts, badges, filtres et actions affilié reste inchangée.

## Etat 2026-03-17 — Mon reseau: le hors cadre delegue ne depend plus d'un contrat reseau automatique

Correctif fonctionnel cote PRO:
- depuis `/extranet/account/network`, une TdR peut lancer un write path explicite `hors_cadre` meme si aucune ligne `ecommerce_reseau_contrats` n'existe encore pour son compte;
- ce point ne couvre plus aucun remplacement d'une delegation `hors_cadre` active en V1;
- le tunnel delegue garde son contexte affilié explicite, mais `id_contrat_reseau` devient optionnel pour les flows purement `hors_cadre`;
- les activations `cadre` / `Activer` via abonnement reseau restent inchangées et continuent d'exiger un support reseau actif.

## Etat 2026-03-17 — Bibliothèque: contenu reseau V1 durci et navigation canonique réalignée

Correctif fonctionnel cote PRO:
- l'entree canonique TdR reste `/extranet/account/network`, puis `Jeux sélectionnés` ouvre `library?network_manage=1`;
- l'entree canonique affilié reste le portail bibliothèque via la carte `Jeux sélectionnés`, en lecture seule;
- il n'existe plus d'onglet `Playlists / Séries du réseau` dans les catalogues jeu, ni cote TdR ni cote affilié;
- les actions `Partager avec mon réseau` / `Retirer du réseau` restent reservees a la TdR proprietaire, avec refus serveur propre sur tentative directe hors périmètre;
- les lectures réseau n'affichent plus un partage dont la source est supprimée, inactive ou devenue non exploitable;
- la persistance reste `ecommerce_reseau_content_shares`, conservée en lazy-init via le helper `global`, avec unicité métier portée par `(id_client_siege, game, content_type, source_id)`.

## Etat 2026-03-17 — Bibliothèque: V1 contenu reseau livree avec arrivée TdR dédiée

Correctif fonctionnel cote PRO:
- `/extranet/account/network` garde son role de point d'entree unique et le CTA `Contenus réseau` ouvre maintenant le hub bibliothèque dedie;
- la TdR arrive d'abord sur une vraie page `Contenus réseau` de management, utile même quand aucun contenu n'est encore partagé;
- tant que la TdR reste sur ce parcours `network_manage=1`, la navigation gauche conserve le contexte `Mon réseau`;
- cette page centralise les contenus déjà partagés tous jeux confondus, avec un header allégé `Retour à Mon réseau` + `Jeux sélectionnés` + sous-titre explicite, puis un unique bloc d'information avec compteur dynamique;
- le sous-titre reprend le style visuel déjà utilisé sur `Mon réseau`, et le bloc haut affiche maintenant un titre juste `Aucun jeu partagé / 1 jeu partagé / x jeux partagés avec ton réseau`, un texte d'aide métier et un CTA `Ajouter des Jeux sélectionnés` toujours visible;
- la fiche contenu affiche maintenant l'etat reseau et les actions `Partager au réseau` / `Retirer du réseau`;
- sur la fiche détail, l'action réseau est remontée dans la rangée de CTA principaux, à côté de la programmation et de la démo, avec le wording `Partager avec mon réseau` / `Retirer du réseau`;
- quand un contenu est partagé au réseau courant, la fiche détail affiche aussi une mention de recommandation réseau adaptée au contexte, avec un lien `Voir les Jeux sélectionnés` juste au-dessus des CTA principaux ; pour une playlist vue côté TdR, le libellé affiché est `Cette playlist est recommandée à vos affiliés.`;
- la page TdR n'affiche plus les tags `Playlist / Série` et `Cotton / Communauté / Mine` sur les cartes, jugés trop chargés pour cette vue;
- l'affilié retrouve ce contenu via la carte portail `Jeux sélectionnés`, purement en lecture;
- depuis une fiche détail ouverte dans le contexte TdR réseau, le lien `Retour aux Jeux sélectionnés` revient maintenant directement vers `library?network_manage=1`, sans réinjecter le contexte catalogue filtré ni être réécrit plus bas dans la fiche.
- en revanche, si la TdR démarre un quiz depuis une série partagée réseau, le flux bascule maintenant vers la bibliothèque quiz standard (`game=quiz&builder=1`) pour permettre d'ajouter d'autres séries du catalogue complet.

## Etat 2026-03-17 — Bibliothèque: quitter `Les jeux` purge le builder quiz

Correctif fonctionnel cote PRO:
- le builder quiz de bibliothèque reste stocké en session serveur pendant le parcours `Les jeux`;
- dès que l'utilisateur quitte réellement ce contexte pour charger un autre menu, `ec.php` annule maintenant automatiquement le builder encore en mémoire;
- les flows `tunnel/start` explicitement ouverts depuis la bibliothèque conservent ce builder, afin de ne pas casser la continuité des parcours internes.

## Etat 2026-03-17 — Bibliothèque: la chip `Réseau` des cartes TdR ne concurrence plus les autres badges

Correctif fonctionnel cote PRO:
- dans les catalogues TdR, la chip `Réseau` quitte la zone haute du visuel, trop chargée par `Populaire` et `En ce moment`;
- elle est maintenant rendue en bas a gauche de l'image de carte, ce qui la separe nettement des autres badges existants;
- son style reutilise une couleur deja presente dans le repo (`#FFDB03` avec texte sombre `#240445`) pour rester coherent sans ajouter une nouvelle teinte metier.

## Etat 2026-03-17 — Bibliothèque: hub global reseau affilie puis portail final sans onglet reseau

Correctif fonctionnel cote PRO:
- un affilié qui dispose d'au moins un contenu reseau voit maintenant, depuis l'entree bibliothèque sans jeu, un bloc `Jeux sélectionnés` pleine largeur qui ouvre un hub global lecture seule tous jeux confondus;
- ce hub reutilise `library?network_manage=1`, mais avec un habillage affilié et sans write path, pour exposer simplement les contenus sélectionnés par la tete de reseau;
- cet etat intermediaire a ensuite ete remplacé le meme jour par la carte portail `Jeux sélectionnés`; aucun onglet réseau par catalogue n'est retenu comme état final;
- une fiche détail ouverte depuis ce hub global reseau revient vers `library?network_manage=1`, cote TdR comme cote affilié.

## Etat 2026-03-17 — Bibliothèque: le portail `Jeux sélectionnés` remplace l'onglet réseau par catalogue

Correctif fonctionnel cote PRO:
- le portail bibliothèque sans jeu affiche maintenant une carte cliquable `Jeux sélectionnés` pour l'affilié et pour la TdR;
- cette carte reprend le langage visuel des blocs de choix de jeu, sans CTA distinct, avec une largeur bornée a celle des cartes de jeux du portail;
- l'onglet `Playlists / Séries du réseau` est retire des catalogues jeu, cote affilié comme cote TdR, pour éviter une navigation doublon;
- la chip `Réseau` sur les cartes catalogue est maintenant visible aussi bien pour l'affilié que pour la TdR, dès qu'un contenu est effectivement partagé par la tete de réseau.

## Etat 2026-03-17 — Bibliothèque: la carte portail `Jeux sélectionnés` prend toute la largeur et finalise son wording

Correctif fonctionnel cote PRO:
- la carte `Jeux sélectionnés` occupe maintenant toute la largeur disponible sous les 3 blocs de jeux du portail bibliothèque;
- elle adopte un style plus arrondi pour mieux s'assumer comme point d'entree dédié;
- son titre affiche maintenant `Les jeux {nom_compte_TdR}`;
- le texte affilié devient `Accède rapidement aux jeux sélectionnés par ton réseau !`;
- le texte TdR devient `Accède directement à la gestion des jeux que tu partages avec ton réseau.`

## Etat 2026-03-17 — Bibliothèque: la carte portail `Jeux sélectionnés` se cale sur les 3 cartes jeu et reprend le visuel reseau

Correctif fonctionnel cote PRO:
- la carte portail ne duplique plus son titre;
- sa largeur est maintenant bornee pour s'aligner visuellement avec les 3 cartes jeu du dessus, au lieu d'occuper tout le container;
- si un visuel de design reseau existe pour la TdR concernee, il est affiche en tete de carte;
- sinon la carte utilise un fallback generique `cotton-media-kit-portail.jpg`.

## Etat 2026-03-17 — Bibliothèque: la carte portail `Jeux sélectionnés` passe en layout horizontal

Correctif fonctionnel cote PRO:
- le visuel reseau (ou son fallback) est maintenant affiche a gauche de la carte;
- le texte passe a droite, pour mieux respecter le format horizontal de ce bloc transversal.

## Etat 2026-03-17 — Bibliothèque reseau TdR: le CTA d'ajout est decoupe par jeu

Correctif fonctionnel cote PRO:
- sur `library?network_manage=1` cote TdR, le CTA unique `Ajouter des Jeux sélectionnés` est remplace par 3 CTA dédiés et colores;
- chaque bouton renvoie directement vers le catalogue standard du jeu concerne, hors contexte reseau, pour laisser la TdR naviguer et choisir ensuite ce qu'elle partage.
- dans la vue globale `Jeux sélectionnés`, une meme playlist partagee a la fois sur `Blind Test` et `Bingo Musical` n'est plus fusionnee: elle apparait maintenant une fois par jeu partage.
- ces cartes globales reseau reprennent aussi maintenant les informations des cartes standard de bibliothèque: niveau, auteur et nombre de fois ou le contenu a ete joue par le client connecte.

## Etat 2026-03-16 — Design reseau: la page branding TdR est maintenant une vraie experience dediee

Correctif fonctionnel cote PRO:
- la route branding historique est conservee, mais la surface TdR est refondue autour d'une page `Design reseau` reliee a `/extranet/account/network`;
- la page affiche maintenant un etat clair du branding reseau (`Aucun`, `Actif`, `Actif jusqu'au ...`, `Expire`);
- le formulaire reprend les champs utiles consommes cote games (couleurs, police, logo, visuel) dans une UI alignee sur la logique de personnalisation deja connue dans les jeux;
- un apercu visuel inspire de l'attente de session montre le rendu reseau final;
- une date de fin optionnelle `valable_jusqu_au` peut etre definie ou supprimee;
- l'action `Reinitialiser le design reseau` supprime la couche reseau personnalisee et laisse la resolution retomber sur l'heritage restant.
- correctif post-recette: l'enregistrement TdR choisit bien maintenant le type `3` reseau, au lieu de retomber par erreur sur un branding client type `4` quand le contexte PHP ne fournissait pas `$app_client_detail`.
- correctif media: le logo reseau uploadé depuis PRO n'impose plus de hauteur de crop; l'image conserve maintenant son ratio source, ce qui evite la coupe laterale dans le header des jeux tout en restant persistée au save.
- correctif upload final: le save branding PRO reprend maintenant la meme normalisation MIME/extension que le flux games pour les medias branding, tout en revenant a un comportement de remplacement proche du module historique pour eviter le retour automatique a un ancien logo.
- correctif de relecture: les URLs de logo/visuel branding sont maintenant versionnees par date de modification de fichier, ce qui evite de revoir un ancien media servi depuis le cache juste apres save.
- ajustement UI view: la page `Design reseau` simplifie maintenant aussi son header et son bloc d'etat, sans CTA haut de page ni mention technique de source effective.
- ajustement UI view complementaire: la date limite de validite et les actions `Creer / Modifier mon design reseau` sont maintenant integrees au bloc de parametres; sans date, la vue affiche simplement `Aucune`.
- ajustement UI final: le texte d'aperçu parle maintenant de l'interface principale et mobile des jeux, et l'action destructive s'affiche en bouton plein `Supprimer ce design`.
- ajustement UI CTA final: la `view` affiche maintenant les actions courtes `Modifier` / `Supprimer`, et la page de modification retire l'action de suppression.
- ajustement UI form final: la page de modification reprend les textes de la `view`, supprime le bloc `Etat actuel` et passe sur un picker de police proche de games, avec URL Google Fonts calculee automatiquement.
- ajustement UX police: le mode `Ajouter une police…` guide maintenant explicitement l'utilisateur sur le nom exact attendu et pointe vers Google Fonts.
- ajustement UX police final: le libelle d'aide est raccourci et le bouton `Ouvrir Google Fonts` utilise maintenant un style plein.
- ajustement structurel form: la page de modification est maintenant structuree en sections `Visuel personnalisé`, `Identité visuelle` et `Réseaux sociaux` (placeholder).
- ajustement structurel view: la page `Design reseau` reprend maintenant ces memes sections en mode ferme pour garder un affichage coherent entre lecture et edition.
- ajustement layout final: en `view` comme en `form`, la date de validite reste dans le contenu du bloc `Personnalisation`, tandis que le bandeau bas est reserve aux CTA, maintenant centres et plus aeres.
- ajustement UX date final: en modification, `Supprimer la date` n'apparait plus dans le bandeau bas et devient une action legere rattachee au champ de date.
- ajustement UI view final: les couleurs affichent maintenant aussi un mini swatch a cote des valeurs hex pour rendre la lecture plus immediate.

## Etat 2026-03-16 — Mon reseau: les actions d'activation passent par confirmation

Correctif fonctionnel cote PRO:
- le bouton `Activer via l'abonnement` est renomme `Activer`;
- une mention explicative est affichee sous `Activer` et `Désactiver`;
- les deux actions ouvrent maintenant une modale de confirmation avant soumission.
- la modale est maintenant rendue hors du tableau des affiliés, ce qui evite la page grisee avec CTA inaccessibles et restaure un bouton `Annuler` bien visible.
- le bouton `Annuler` utilise maintenant un style plein `btn-secondary`, plus robuste que la variante outline dans ce contexte.

## Etat 2026-03-16 — Factures PDF: le symbole euro du tableau est corrige

Correctif fonctionnel cote PRO:
- les montants du tableau facture n'affichent plus `â‚¬`;
- le rendu utilise maintenant une forme compatible avec l'encodage legacy FPDF de ces vues.

## Etat 2026-03-16 — Mon reseau: le bloc Facturation pointe aussi vers les factures affiliés

Correctif fonctionnel cote PRO:
- la page `Mon réseau` affiche maintenant un lien `Voir les factures affiliés` dans le bloc `Facturation`;
- ce lien apparait seulement quand la TdR porte au moins une offre deleguee hors cadre active.

## Etat 2026-03-16 — Factures PDF: le logo est aligne sur celui de l'EC pro

Correctif fonctionnel cote PRO:
- les factures PDF PRO et BO utilisent maintenant le meme logo que celui du header EC pro;
- l'ancien visuel `cotton-quiz-pdf.jpg` n'est plus utilise dans ces rendus facture.
- le chargement du logo reste base sur un chemin relatif compatible avec FPDF en runtime, ce qui evite l'ecran blanc observe avec un chemin absolu local.
- le logo est maintenant resolu via la racine `public` derivee cote PRO, ce qui stabilise aussi le rendu BO face aux chemins relatifs fragiles de FPDF.
- si le nouveau logo n'est pas accessible, le rendu retombe sur l'ancien JPG au lieu de planter.

## Etat 2026-03-16 — Factures TdR: les offres deleguees affichent maintenant l'affilie facture

Correctif fonctionnel cote PRO:
- dans `Mes factures`, une facture liee a une offre deleguee affiche maintenant aussi `Affilié : <nom>` pour aider la TdR a distinguer les abonnements `hors cadre` au meme montant;
- les nouvelles factures PDF reprennent aussi `Affilié : <nom>` sous le nom du produit;
- les vues PDF BO/PRO ajoutent egalement ce libelle a l'affichage pour les factures deja generees;
- le BO factures affiche le meme libelle sur la ligne d'offre correspondante.

## Etat 2026-03-16 — Mon reseau: l'activation d'un affilié sans offre active ne doit plus dependre de l'historique

Correctif fonctionnel cote PRO:
- si la TdR dispose d'un abonnement reseau actif, d'un quota disponible et que l'affilie cible n'a aucune offre active, l'activation via l'abonnement doit maintenant fonctionner quel que soit l'historique BO de cet affilié;
- le runtime global priorise desormais, pour un affilié donne, la delegation active rattachee au support reseau courant plutot qu'une ligne legacy plus recente mais hors cadre;
- cela evite qu'une creation valide `pro_included_activation_cadre` soit immediatement relue/re-sync en `hors_cadre`.

## Etat 2026-03-16 — Reseau: les activations incluses restent bien ecrites en `cadre`

Correctif fonctionnel cote PRO:
- le lien d'affiliation reseau et le CTA `Activer via l'abonnement` recreent de nouveau une offre incluse `cadre` quand le support reseau est actif et qu'une place reste disponible;
- sans support actif ou sans offre cible, l'affiliation n'ajoute toujours aucune offre;
- le calcul `cadre/hors_cadre` s'appuie maintenant sur l'etat runtime complet du contrat/support, ce qui evite qu'un contrat encore partiellement synchronise rabatte par erreur une activation incluse en `hors_cadre`;
- la couverture reseau relit aussi le rattachement `reseau_id_offre_client_support_source` pour reconnaitre une offre incluse deja accrochee au support courant, meme si `mode_facturation` est encore stale;
- le correctif ne reintroduit pas l'ancien auto-reclassement `hors cadre -> cadre`: il restaure seulement la bonne ecriture du mode `cadre` sur les activations explicitement incluses.

## Etat 2026-03-16 — Mon reseau: les offres deleguees hors cadre ne sont plus reclassifiees automatiquement

Correctif fonctionnel cote PRO:
- une offre deleguee `hors cadre` active reste maintenant hors abonnement tant que la TdR ne la resilie pas elle-meme;
- le quota de l'abonnement reseau ne sert plus a absorber automatiquement ces offres existantes;
- `Mon réseau` n'expose plus de menu d'actions pour ces offres: `Gérer l'offre` ouvre directement le portail Stripe dedie a la resiliation;
- si la fin de periode est deja programmee, la page affiche seulement `Cet abonnement sera résilié au ...`;
- la reintegration dans le cadre reseau devient donc manuelle: resilier d'abord l'offre `hors cadre`, puis activer ensuite l'affilié voulu via l'abonnement reseau s'il reste une place;
- aucune logique d'upsell/downsell, aucun remplacement manuel et aucun auto-reclassement `hors cadre -> cadre` ne restent retenus en V1.

## Etat 2026-03-16 — Portail Stripe reseau: resiliation support visible sans ecriture parasite

Correctif fonctionnel cote PRO:
- le portail support reseau reste borne a la lecture et a la resiliation de l'abonnement support existant;
- une fin de periode Stripe du support doit rester visible cote `Mon offre` / `Offres & factures`;
- cette visibilite n'autorise aucun changement de plan ni aucune recreation automatique d'un support `En attente`;
- cote delegations `hors_cadre`, V1 ne retient pas de variante portail `manage` comme verite finale: la seule action conservée est la resiliation.

## Etat 2026-03-15 — Signup affilié reseau: les affiliés supprimes ne saturent plus le quota TdR

Correctif fonctionnel cote PRO:
- la creation automatique d'une offre deleguee incluse ne doit plus etre bloquee par d'anciens affiliés supprimes du SI;
- la couverture reseau ne compte maintenant plus les delegations orphelines dont le client affilié n'existe plus.

## Etat 2026-03-15 — Signup affilié reseau: l'activation incluse reste seule pilote de la premiere offre

Correctif fonctionnel cote PRO:
- le parcours `signup_affiliation` n'appelle plus un reclassement global concurrent juste apres `client_affilier()`;
- l'orchestration dediee conserve donc seule la creation de l'offre incluse, le refresh reseau et la synchronisation du pipe affilié.

## Etat 2026-03-15 — Signup affilie reseau: l'offre incluse ne doit plus se terminer le jour meme

Correctif fonctionnel cote PRO:
- le symptome venait du write path global appele par le signup affilié sous abonnement reseau, pas du formulaire lui-meme;
- le reclassement auto `hors cadre -> cadre` exclut maintenant la ligne source quand il recree l'offre cible, ce qui evite une cloture immediate de l'offre fraichement creee;
- les hooks de refresh/reclassement immediats ont aussi ete retires du helper de creation sur ce parcours, pour eviter une cascade de creations/clotures dans la meme requete de signup;
- le reclassement global est en plus protege contre la reentrance pour une meme TdR dans une requete PHP, et le remplacement reseau ne relance plus deux refresh cibles imbriques.
- pour le cas `signup_affiliation`, le flux ne cree plus une delegation generique avant reclassement: il passe maintenant directement par l'activation explicite `included`, ce qui doit creer l'offre initiale directement en `cadre`.
- le helper d'activation explicite saute aussi son reclassement final pour ce seul parcours `signup_affiliation`, afin d'eviter la seconde ligne residuelle immediatement `Terminee`.
- l'activation explicite resynchronise aussi de nouveau le pipe affilié, ce qui restaure le passage en `ABN/PAK` pour l'affilié couvert par l'offre deleguee.
- le helper `included` n'exige plus non plus une jauge cible deja resolue pour ce parcours; il s'aligne a nouveau sur le fallback historique de creation de delegation.

## Etat 2026-03-15 — Signup pro: la page blanche sur `establishment/script` ne doit plus tomber sur le fatal AI Studio

Correctif fonctionnel cote PRO:
- le signup pro ne depend plus d'un chargement relatif fragile pour la fonction `ai_studio_email_transactional_send()`;
- le bruit `id_remise` absent a aussi ete retire de ce meme flux de creation.

## Etat 2026-03-15 — Signup affilie reseau: la sur-creation d'offres incluses est bloquee au write path

Correctif fonctionnel cote PRO:
- l'audit du signup affilié a confirme que le point d'entree PRO appelait une auto-attribution reseau non idempotente cote global;
- la creation en rafale de delegations identiques pour un meme affilie est maintenant bloquee au niveau du helper global appele par ce parcours.

## Etat 2026-03-15 — Pro dev: une session cliente orpheline est maintenant ejectee proprement vers `signin`

Correctif fonctionnel cote PRO:
- si la session reste auth mais que le client n'est plus resolu cote SI, `ec.php` stoppe le rendu, purge la session et renvoie vers `signin`;
- `signup` et `signin` ne lisent plus non plus `id_client_reseau` ou `CQ_admin` sans garde, ce qui stabilise les points d'entree apres un signup / parcours d'affiliation incomplet.

## Etat 2026-03-15 — Pro dev: une session signup partielle ne boucle plus entre `signin` et `dashboard`

Correctif fonctionnel cote PRO:
- si un signup interrompu laisse `id_client` sans `id_client_contact`, `signin` nettoie maintenant cette session incoherente au lieu de renvoyer vers `dashboard`;
- le point d'entree script ne lit plus `id_client_contact` et les cookies BO sans garde.

## Etat 2026-03-15 — Pro dev: acces `signin/dashboard` stabilise contre plusieurs notices bloquantes

Correctif fonctionnel cote PRO:
- `signin`, `dashboard` et l'authentification BO ne lisent plus plusieurs indexes session/cookies absents en dev;
- le branding reseau retombe maintenant proprement sur un rendu vide si aucun client branding n'est resolu;
- le bruit applicatif baisse sur les chemins d'acces de base, ce qui doit eviter des blocages de rendu en environnement dev plus strict.

## Etat 2026-03-15 — Signup pro dev: le fatal AI Studio transactionnel est supprime

Correctif fonctionnel cote PRO:
- la creation d'etablissement ne tombe plus sur `Call to undefined function ai_studio_email_transactional_send()`;
- le loader global recharge maintenant correctement la brique AI Studio transactionnelle apres renommage du dossier workflow;
- le webhook transactionnel vise aussi le bon chemin `1_emails_transactional`.

## Etat 2026-03-15 — `Mon offre` reseau ouvre desormais le portail Stripe sur la bonne souscription

Correctif fonctionnel cote PRO:
- le CTA `Gerer mon abonnement` d'une tete de reseau n'ouvre plus la home globale du customer Stripe;
- `Mon offre` prepare maintenant un deep-link Billing Portal cible sur la souscription support reseau;
- le headline du portail reseau est realigne sur `Cotton - Abonnement reseau`;
- ce deep-link reste borne a la souscription support existante et ne doit pas etre relu comme un parcours de modification de plan en V1.

## Etat 2026-03-13 — Activation support reseau: hypothese d'absorption/recreation abandonnee (historique)

Historique explicitement depasse:
- l'idee d'absorber une offre `hors_cadre` existante dans le quota reseau puis de la recreer proprement n'est plus retenue;
- la verite finale V1 est l'inverse: une offre deleguee `hors_cadre` active reste `hors_cadre` tant qu'elle n'est pas resiliee explicitement.

## Etat 2026-03-13 — Confirmation reseau: un seul acces `Mon reseau`

Correctif fonctionnel cote PRO:
- sur la confirmation d'achat reseau, le lien inline `Gerer mon reseau` dans le bloc detail est masque;
- le CTA principal `Acceder a Mon reseau` reste seul affiche sous le bloc resume.

## Etat 2026-03-13 — Confirmation d'abonnement reseau: le retour Stripe retrouve bien l'offre support

Correctif fonctionnel cote PRO:
- le flux `pay_network_support` memorise maintenant l'`id_securite` de l'offre support avant la sortie vers Stripe;
- la page `manage/s3` peut ainsi recharger correctement le bloc detail apres paiement reseau;
- en fallback, le step 3 sait aussi reprendre l'offre support reseau courante si l'URL arrive encore sans identifiant.

## Etat 2026-03-13 — Confirmation d'achat reseau: sortie Stripe recentree sur `Mon reseau`

Correctif fonctionnel cote PRO:
- la page de confirmation post-achat masque maintenant le widget agenda pour un abonnement reseau ou une offre deleguee `hors cadre`;
- un CTA direct `Acceder a Mon reseau` est ajoute sous le bloc resume;
- pour l'abonnement reseau, le titre du bloc detail ne reste plus vide et affiche `Abonnement reseau`.

## Etat 2026-03-13 — `Mon offre`: un abonnement en essai actif affiche la fin d'essai Stripe

Correctif fonctionnel cote PRO:
- pour une souscription Stripe encore `trialing`, la fiche `Mon offre` affiche maintenant `Offre d'essai en cours jusqu'au ...`;
- la ligne `Abonnement du ... au ...` est masquee uniquement pendant l'essai actif, puis redevient visible ensuite;
- la mention redondante `Offre d'essai en cours` sous le CTA `Gerer mon abonnement` est retiree.

## Etat 2026-03-13 — Checkout standard: autocreation du prix Stripe catalogue si l'environnement ne l'a pas

Correctif fonctionnel cote PRO:
- si le `lookup_key` catalogue standard reste introuvable dans l'environnement Stripe courant, le tunnel standard cree maintenant le `Price` manquant avant d'ouvrir Checkout;
- le prix cree reprend le `lookup_key`, le montant TTC de l'offre et la recurrence mensuelle/annuelle attendue, ce qui garde le webhook catalogue coherent;
- le chemin reseau delegue reste separe et inchangé.

## Etat 2026-03-13 — Checkout standard: les commandes catalogue propres resolvent mieux leur prix Stripe

Correctif fonctionnel cote PRO:
- le step 2 du tunnel de commande standard ne depend plus du seul `Price::search` pour retrouver le tarif Stripe du catalogue;
- la resolution du `price_id` passe maintenant d'abord par `lookup_keys`, ce qui revalide les commandes propres observees en echec sur `ABN100A` / `ABN100M`;
- la logique de checkout delegue reseau reste separee et ne doit plus contaminer ce chemin standard.

## Etat 2026-03-13 — `Mon reseau`: le detail `Tarif` ne duplique plus `€`

Correctif fonctionnel cote PRO:
- dans `Mes affilies`, le detail d'une offre deleguee `hors cadre` reutilise maintenant directement le helper `montant(..., '€', 'HT', 1)`;
- le rendu `Tarif` n'ajoute donc plus un `€` litteral supplementaire apres la valeur;
- l'affichage attendu redevient `Tarif : xx,xx € HT / mois` ou `Tarif : xx,xx € HT`.

## Etat 2026-03-13 — Portail Stripe affilié: variantes `manage` / remplacement abandonnees (historique)

Historique explicitement depasse:
- les variantes `network_affiliate_manage`, `cancel_immediate`, les usages de reactivation et les parcours de remplacement ne sont plus la reference finale;
- la verite finale V1 cote delegations `hors_cadre` est plus simple:
  - une offre active reste active jusqu'a resiliation explicite;
  - une offre resiliee fin de periode reste visible comme telle jusqu'a l'echeance;
  - aucun `Changer d'offre`, aucun upsell/downsell et aucune reactivation dediee ne restent retenus.

## Etat 2026-03-13 — Résiliation portail Stripe déléguée: la fin de période Stripe reste prioritaire

Correctif fonctionnel cote PRO:
- une résiliation unitaire d'offre déléguée `hors cadre` via le portail Stripe ne doit plus retomber au jour courant si Stripe remonte encore une `current_period_end` future;
- la synchronisation SI considère maintenant cette date Stripe future comme la source de vérité, y compris si l'événement reçu est déjà terminal;
- l'UI `Mon réseau` doit donc continuer d'afficher une résiliation planifiée jusqu'à l'échéance réelle;
- l'offre ne doit plus basculer immédiatement à l'état `Terminée` tant que cette échéance n'est pas atteinte;
- le bouton visible de la ligne affiche aussi maintenant `Réactiver mon offre` tant que cette résiliation reste seulement planifiée;
- dans cet état, le changement d'offre est masqué: seul le portail Stripe de réactivation reste accessible;
- cette réactivation passe par une session portail standard Stripe, et le pipe affilié reste réaligné sur l'offre encore active jusqu'à la résiliation effective.

## Etat 2026-03-13 — Délégations `hors cadre`: historique de remplacement abandonne

Historique explicitement depasse:
- les parcours `Changer d'offre`, `upsell`, `downsell`, remplacement immediat ou differe ne font plus partie de la verite finale V1;
- la seule partie encore valable ici est la resiliation Stripe fin de periode d'une delegation `hors_cadre`, qui doit rester visible jusqu'a l'echeance effective sans cloture immediate parasite.

## Etat 2026-03-13 — `Mon offre`: abonnements en essai et portail Stripe mieux distingués

Correctif fonctionnel cote PRO:
- une offre d'abonnement Stripe en `trialing` n'est plus traitée visuellement comme une résiliation programmée;
- le CTA de la page `Mon offre` reste maintenant `Gérer mon abonnement` pendant l'essai, et `Réactiver mon abonnement` est réservé aux vraies souscriptions actives avec `cancel_at_period_end`;
- la page affiche aussi `Offre d'essai en cours` quand Stripe confirme un essai actif, sans réafficher le texte détaillé `15 jours gratuits...`;
- cette mention disparaît automatiquement dès que Stripe ne remonte plus le statut `trialing`.

## Etat 2026-03-13 — TdR: une délégation hors cadre payée resynchronise aussi le statut affilié

Clarification documentaire cote PRO:
- une commande TdR d'offre déléguée `hors cadre` active désormais aussi la resynchronisation du pipeline affilié après paiement;
- le write path ajoute un fallback direct sur l'offre déléguée activée si la lecture canonique du contexte effectif est encore en retard au moment du webhook;
- l'affilié bascule donc sur le statut attendu à partir de son offre effective, comme pour les autres activations réseau.

## Etat 2026-03-13 — `Changer d'offre` delegue, upsell/downsell et remplacement canonique: abandonnes (historique)

Historique explicitement depasse:
- les parcours `Changer d'offre` cote `Mon reseau`, le wording `upsell/downsell`, la persistance de remplacements differes et le remplacement canonique d'une delegation active ne sont plus retenus comme reference V1;
- pour l'audit final, il faut au contraire partir de ces invariants:
  - une delegation `hors_cadre` active n'est jamais remplacee automatiquement;
  - aucune simple lecture front/runtime ne doit fabriquer un etat support `En attente`;
  - la fin BO ou Stripe du support n'a aucun impact automatique sur les offres `hors_cadre`.

## Etat 2026-03-13 — TdR: les offres déléguées hors cadre sont maintenant resynchronisées au cycle Stripe

Correctif fonctionnel cote PRO:
- les subscriptions Stripe des offres déléguées `hors cadre` commandées par une tête de réseau peuvent maintenant être resynchronisées juste avant facturation via le webhook;
- le mécanisme est limité à ce périmètre et ne touche pas les offres propres ni l'abonnement réseau support;
- pour rendre la pré-sync réellement systématique avant prélèvement, l'endpoint Stripe doit recevoir `invoice.upcoming` et `invoice.created`.

## Etat 2026-03-13 — `Mon réseau`: le bloc `Facturation` renvoie vers `Mon offre`

Correctif fonctionnel cote PRO:
- quand l'abonnement réseau est actif, le lien du bloc `Facturation` affiche maintenant `Voir mon abonnement`;
- il pointe désormais vers la page `Mon offre` au lieu d'ouvrir directement la gestion d'abonnement;
- le cas `Payer et activer l'abonnement` reste inchangé quand l'abonnement est en attente.

## Etat 2026-03-13 — `Mon réseau`: les colonnes `Affilié` et `Statut` sont mieux alignées

Correctif fonctionnel cote PRO:
- les colonnes `Affilié` et `Statut` du tableau sont maintenant centrées verticalement dans chaque ligne;
- cela améliore la lisibilité quand la colonne `Détail` prend plusieurs lignes;
- aucun tri, filtre ou comportement d'action n'est modifié.

## Etat 2026-03-13 — `Mon réseau`: ton éditorial harmonisé avec le reste du PRO

Correctif fonctionnel cote PRO:
- la page `Mon réseau` utilise maintenant le tutoiement sur ses textes visibles pour rester cohérente avec le reste de l'espace PRO;
- les libellés relus gardent aussi les accents français attendus;
- aucun comportement métier ni CTA n'est modifié par ce lot éditorial.

## Etat 2026-03-13 — `Mon réseau`: le CTA `Commander` rappelle aussi la remise projetée

Correctif fonctionnel cote PRO:
- pour un affilié sans offre active, le bloc d'action affiche maintenant `Profite de ta remise réseau de xx% !` au-dessus du bouton `Commander`;
- le pourcentage reprend le calcul déjà affiché dans la `Synthèse` de la page réseau;
- aucun calcul de tarification n'est modifié, seule l'incitation UI est enrichie.

## Etat 2026-03-13 — Step 1 délégué: reselection robuste après `back` navigateur

Correctif fonctionnel cote PRO:
- le step 1 sait maintenant retomber sur le contexte affilié même si un `back` navigateur a fait perdre `network_delegated_token` au POST;
- ce fallback n'est activé que s'il existe déjà une offre déléguée `pending` cohérente pour l'affilié en session;
- le rebond `step 1 -> step 2` reste ainsi dans le tunnel réseau au lieu de repartir vers `Mon réseau`.

## Etat 2026-03-13 — Confirmation déléguée: changer d'offre garde aussi le contexte affilié

Correctif fonctionnel cote PRO:
- les cartes `Choisir` du step 2 de confirmation republient maintenant `network_delegated_token` en contexte délégué;
- un changement d'offre depuis la confirmation reste donc dans le flux affilié au lieu de sortir vers une erreur générique;
- aucun calcul de prix ou de remise n'est modifié.

## Etat 2026-03-13 — Tunnel délégué: le contexte affilié survit mieux aux retours navigateur

Correctif fonctionnel cote PRO:
- le step 1 d'une commande déléguée ne détruit plus immédiatement le contexte affilié en session après création de l'offre pending;
- la redirection vers la page de confirmation `manage/s2` réembarque aussi `network_delegated_token` dans l'URL;
- les retours navigateur dans le tunnel conservent donc mieux le contexte affilié initial.

## Etat 2026-03-13 — Checkout Stripe délégué: l'affilié cible est aussi rappelé côté paiement

Correctif fonctionnel cote PRO:
- le checkout Stripe d'une commande déléguée affiche maintenant `Commande pour <affilié>` dans le texte additionnel géré par Stripe;
- l'information reprend le même affilié cible que le tunnel Cotton, avec fallback lisible si le nom n'est pas relu;
- la structure de page Stripe reste celle du checkout hébergé, seul le texte additionnel est injecté.

## Etat 2026-03-13 — Confirmation déléguée: l'affilié cible est rappelé avant la remise

Correctif fonctionnel cote PRO:
- la page de confirmation d'une commande déléguée affiche maintenant `Commande pour <affilié>` juste au-dessus de `Remise reseau`;
- le nom affiché vient de `id_client_delegation`, avec fallback lisible si la fiche client n'est pas relue;
- aucun calcul de remise ni comportement de paiement n'est modifié.

## Etat 2026-03-13 — Tunnel delegue: CTA `Commander` + remise detaillee en confirmation

Correctif fonctionnel cote PRO:
- la premiere page du tunnel de commande déléguée affiche maintenant `Commander` sur les CTA de choix d'offre;
- le bloc marketing CHR retire aussi la promesse `testez pendant 15 jours` en contexte affilié;
- la page suivante de confirmation affiche `Remise reseau` avec le pourcentage stocké quand il existe;
- le pourcentage est maintenant rendu sans espace HTML parasite avant `%`;
- aucun calcul de remise n'est modifié, seul le wording d'interface est complété.

## Etat 2026-03-13 — `Commander` en contexte affilié suit la typo de la TdR sans essai gratuit

Correctif fonctionnel cote PRO:
- le tunnel de commande déléguée ouvre désormais le segment catalogue cohérent avec la typologie de la tête de réseau qui commande;
- le contexte affilié n'affiche plus de bouton ni de message laissant croire à un essai gratuit;
- la commande déléguée conserve explicitement `trial_period_days = 0`, donc sans période d'essai activable pour cet usage.

## Etat 2026-03-13 — Reseau BO: navigation croisee mieux exposee cote support

Clarification documentaire cote produit:
- la fiche BO d'un `Abonnement reseau` affiche maintenant le client TdR directement dans le bloc haut;
- la page BO `reseau_contrats` permet aussi de rouvrir l'offre support active depuis son libelle `Abonnement reseau actif`;
- aucun flux PRO ni logique front reseau n'est modifie par ce lot.

## Etat 2026-03-13 — `Mon reseau`: la `Synthese` affiche aussi la remise reseau de prochaine commande

Correctif fonctionnel cote PRO:
- le bloc `Synthese` affiche maintenant `Remise reseau appliquee a votre prochaine commande`;
- le pourcentage reprend le meme calcul que le BO `reseau_contrats`, base sur le volume actif du reseau projete a `+1`;
- une note explicite rappelle que cette remise depend du nombre d'affilies actifs et s'applique sur les offres gerees par le reseau.

## Etat 2026-03-12 — `Mon reseau`: detail des offres simplifie avec jauge

Correctif fonctionnel cote PRO:
- la colonne `Detail` conserve les informations offre utiles et les CTA, sans les textes d'etat internes techniques;
- la jauge de l'offre est affichee au format `Jauge : X joueurs`;
- le bouton `Desactiver` garde un fond rouge, avec une variation plus terne au survol.

## Etat 2026-03-12 — `Mon reseau`: `Activer via l'abonnement` devient exclusif quand une place incluse existe

Correctif fonctionnel cote PRO:
- pour un affilie sans offre, `Commander` n'est plus affiche si l'abonnement reseau est actif avec une place incluse disponible;
- dans ce cas, seul `Activer via l'abonnement` est visible;
- la desactivation incluse ne valide plus un succes sans offre deleguee active resolue et la UI se requalifie immediatement apres write;
- le bouton `Desactiver` est colore par defaut puis transparent au survol, avec texte rouge lisible.

## Etat 2026-03-12 — `Mon reseau`: `Gerer l'offre` ouvre le portail Stripe de l'offre deleguee

Correctif fonctionnel cote PRO:
- le CTA `Gerer l'offre` d'une delegation Stripe sur `Mon reseau` ouvre maintenant directement le portail Stripe de l'offre concernee;
- l'URL est preparee via `app_ecommerce_stripe_billing_portal_session_prepare(...)` avec retour vers `/extranet/account/network`;
- en absence de session portail Stripe preparable, aucun bouton de gestion n'est affiche.

## Etat 2026-03-12 — `Mon reseau`: correction du lien `Gerer l'offre`

Correctif fonctionnel cote PRO:
- le CTA `Gerer l'offre` d'une delegation Stripe sur `Mon reseau` pointe maintenant vers la route historique valide `/extranet/ecommerce/offers/manage/s2/<id_securite>`;
- l'ancienne URL `/extranet/account/offers/manage/s2/<id_securite>` etait invalide et provoquait une 404;
- aucun changement metier sur le tunnel, seulement une correction de ciblage d'URL.

## Etat 2026-03-12 — `Mon reseau`: `Commander` reutilise maintenant le tunnel classique en contexte affilie

Correctif fonctionnel cote PRO:
- depuis `/account/network`, une TdR peut maintenant lancer `Commander` pour un affilie sans offre active via le catalogue historique;
- le flux reste strictement le tunnel classique de commande:
  - point d'entree `/extranet/account/network/script`;
  - catalogue historique en contexte affilie explicite;
  - creation d'une offre deleguee `pending`;
  - checkout Stripe sur cette ligne;
  - rattachement `hors abonnement reseau` seulement apres paiement confirme;
- la remise reseau est affichee sur tous les tarifs proposes, stockee sur l'offre creee puis facturée via un checkout Stripe aligne sur ce montant;
- aucun fallback silencieux vers une commande en propre n'est autorise si le contexte delegue devient invalide;
- le helper `app_ecommerce_reseau_offre_deleguee_create_for_affilie(...)` n'est pas utilise par ce flux.

## Etat 2026-03-12 — `Mon reseau`: suppression du CTA `Reactiver` et retour au parcours historique hors abonnement

Correctif fonctionnel cote PRO:
- le CTA `Reactiver l'offre` est retire de `Mon reseau`;
- aucun flux de reactivation directe d'une offre deleguee `hors abonnement reseau` n'est encore propose depuis cette page;
- pour une offre deleguee active `hors abonnement reseau`, la page ne propose `Gerer l'offre` que si cette offre porte une preuve Stripe (`asset_stripe_productId`) ;
- sans preuve Stripe sur l'offre deleguee, aucun CTA de gestion n'est affiche depuis `Mon reseau`;
- pour un affilie sans offre dans une TdR sans abonnement reseau actif, `Commander` ouvre maintenant le catalogue historique en portant un contexte affilié cible explicite depuis `/account/network`;
- `Activer via l'abonnement` et `Desactiver` restent les seuls CTA directs conserves sur le perimetre abonnement reseau.

## Etat 2026-03-12 — `Mon reseau`: le CTA `Desactiver` suit maintenant la meme source que le badge

Correctif fonctionnel cote PRO:
- la ligne affilie conserve son badge issu de la couverture courante;
- auparavant:
  - le badge `Actif abonnement reseau` pouvait venir du reclassement de couverture / quota;
  - le CTA `Desactiver` dependait de la persistance d'activation (`mode_facturation='cadre'`);
- resultat:
  - certains affilies etaient affiches comme `Inclus dans votre abonnement reseau` tout en restant non desactivables cote UI;
- desormais:
  - la UI affiche `Desactiver` pour un affilie actuellement classe `cadre` et encore actif;
  - le write path `deactivate_included` accepte aussi ce cas reel quand la couverture courante prouve l'inclusion, meme si `mode_facturation` historique n'etait pas encore `cadre`;
- aucun autre flux serveur n'a ete modifie dans ce correctif.

## Etat 2026-03-12 — Lot 3A UI `Mon reseau`: actionnabilite minimale des affilies

Clarification fonctionnelle cote PRO:
- la page `Mon reseau` expose maintenant des CTA affilie minimaux, strictement branches sur les endpoints PRO dedies deja prouvés;
- les actions visibles sont bornees a:
  - `Activer via l'abonnement` pour un affilie reellement eligible a une place incluse;
  - `Desactiver` pour un affilie actif via l'abonnement reseau;
  - `Gerer l'offre` pour une delegation active `hors abonnement reseau`, via le parcours historique de l'offre concernee;
- les cas suivants restent explicitement non actionnables:
  - `offre propre` affilie;
  - nouvelle commande `hors abonnement reseau` sans contexte affilié cible strictement prouve dans le tunnel historique depuis la page;
- dans ces cas, la page affiche un etat lecture seule ou un CTA preparatoire desactive plutot qu'un tunnel ambigu;
- les retours `network_affiliate_*` sont maintenant traduits en messages front explicites:
  - succes activation incluse;
  - succes desactivation;
  - succes hors abonnement sans promettre de reactivation directe depuis `Mon reseau`;
  - refus offre propre;
  - refus quota atteint;
  - refus cible invalide;
  - refus action non autorisee;
  - erreur generique.

## Etat 2026-03-12 — Lot 3B `actions affilies`: socle serveur PRO et ouverture UI deleguee

Clarification fonctionnelle cote PRO:
- `Mon reseau` reste une surface de lecture / pilotage partiel cote TdR;
- le CTA metier affilie `Commander` est maintenant expose pour le cas borne `affilie sans offre` via le tunnel historique delegue;
- le socle serveur PRO explicite couvre maintenant:
  - `/extranet/account/network/script`
  - `activate_included`
  - `deactivate_included`
  - `create_or_reactivate_hors_cadre_for_affiliate`
  - `start_delegated_hors_cadre_checkout`
- ces actions passent par des wrappers metier globaux explicites, pas par le CRUD generique delegation ni par une ecriture brute sur `id_client_delegation`;
- les gardes serveur imposent:
  - legitimite TdR;
  - appartenance de l'affilie au reseau;
  - refus sur offre propre affilie;
  - refus sur quota / cible hors abonnement incoherents;
  - desactivation canonique conservee (`id_etat=4` + `date_fin`).

## Etat 2026-03-12 — Lot 3 `actions affilies`: perimetre PRO volontairement borne

Clarification de cadrage cote PRO:
- `Mon reseau` reste une surface de lecture et de pilotage partiel cote TdR tant que les write paths PRO affilie dedies n'existent pas;
- les seuls flux metier encore autorises / prouves cote PRO sur le perimetre reseau sont:
  - paiement de l'offre support `Abonnement reseau`;
  - acces portail Stripe quand une vraie session portail est preparable;
  - lecture des statuts et de la couverture reseau;
- aucun CTA metier affilie ne doit etre expose cote PRO a ce stade pour:
  - activation incluse a l'abonnement reseau;
  - desactivation incluse a l'abonnement reseau;
  - creation / reactivation d'une offre `hors abonnement reseau` pour un affilie;
- une offre propre affilie reste hors pilotage TdR cote PRO;
- le CRUD generique de delegation et toute ecriture brute de `id_client_delegation` restent exclus du perimetre PRO.

## Etat 2026-03-12 — `Mes affilies` affine le wording et le filtre `Statut`

Correctif front livre sur `/extranet/account/network`:
- le badge de statut des delegations `hors abonnement reseau` n'affiche plus un libelle unique:
  - sans abonnement reseau actif: `Actif via le reseau`
  - avec abonnement reseau actif: `Actif en supplement`
- les autres badges restent inchanges:
  - `Actif abonnement reseau`
  - `Actif offre propre`
  - `Inactif`
- la chip `Filtrer` de la colonne `Statut` reste visible par defaut, avec un rendu discret mais perceptible;
- le panneau de filtres garde un dimensionnement simple:
  - fond adapte a la hauteur reelle de la liste
  - pas de scroll interne sur cette liste
  - superposition conservee au-dessus du tableau des affilies

## Etat 2026-03-12 — `Mon offre` et `Mon reseau` deviennent des lectures front pures

Correctif front livre cote PRO:
- le contexte TdR, la carte `Abonnement reseau` de `Mon offre` et la page `Mon reseau` ne relancent plus de recalcul reseau ecrivant pendant un simple chargement de page;
- les lectures reseau associees utilisent maintenant le mode sans sync legacy implicite;
- le refresh reseau canonique ne requalifie plus tout seul l'offre support vers `En attente` pendant un recalcul interne; ce statut reste reserve aux write paths explicites BO;
- la page `Mon reseau` aligne aussi son badge de statut sur la valeur canonique `active`, en plus de `actif`, pour afficher correctement un abonnement reseau actif;
- l'objectif est qu'une offre support `Terminee` reste une archive visible, y compris apres navigation entre `/extranet/account/offers` et `/extranet/account/network`.

## Etat 2026-03-12 — `Mon offre` reseau masque les diagnostics Stripe techniques

Correctif front livre sur `Mon offre`:
- le portail Stripe reseau n'est propose que si une URL de portail a effectivement ete preparee;
- une offre reseau geree manuellement cote BO, sans `customer` Stripe exploitable, ne remonte plus un message technique brut au client final;
- les causes techniques restent journalisees cote code (`blocked_reason`, `error_message`) sans etre exposees telles quelles dans l'interface.

## Etat 2026-03-12 — `/account/network` est simplifie pour la TdR

Le lot front courant ne reouvre pas `Mon offre`.

Effet fonctionnel confirme cote PRO:
- la page `Mon reseau` (`pro/web/ec/modules/compte/client/ec_client_list.php`) se recentre sur le pilotage operationnel cote TdR;
- le produit visible reste unique: `Abonnement reseau`;
- la lecture front reutilise les donnees globales deja stabilisees:
  - `app_ecommerce_reseau_facturation_get_detail(...)`
  - `app_ecommerce_reseau_contrat_couverture_get_detail(...)`
  - `app_ecommerce_reseau_offres_hors_cadre_pricing_get(...)`
  - `app_general_branding_get_detail(...)`
- la page expose maintenant une hierarchie plus legere:
  - ligne 1: `Synthese` + `Facturation`
  - ligne 2: `Lien d'affiliation` + `Personnalisation`
  - bloc pleine largeur `Mes affilies`
- le CTA d'acces a `Mon offre` est retire du header et reste uniquement dans `Facturation`
- la synthese ne detaille plus `inclus / hors abonnement` en tete de page:
  - elle affiche `Affilies`, `Actifs`, `Inactifs`
  - les trois cadres sont volontairement plus visibles cote UI (titres / bordures renforcees)
  - le detail de repartition active est retire
  - la synthese propose a la place un lien d'ancrage `Liste complete des affilies de mon reseau`
- le bloc `Facturation` porte maintenant:
  - le badge `Abonnement reseau actif` si le support est actif
  - une ligne compacte `HT [TTC]` pour le socle reseau
  - `Nb affilies limite` et `Nb de places restantes`
  - `Offre attribuee` quand l'offre cible de delegation est definie
  - le meme lien d'action que `Mon offre` pour embarquer directement vers Stripe quand il est disponible:
    - `Payer et activer l'abonnement`
    - `Gerer mon abonnement`
    - `Reactiver mon abonnement`
  - un resume base uniquement sur les offres deleguees actuellement `hors_cadre` encore facturees hors abonnement reseau
  - un libelle distinct selon presence ou non d'un abonnement reseau actif
  - le message vide ne repete plus la commande d'offres, devenue redondante avec l'aide sous le resume hors abonnement
- le bloc `Lien d'affiliation` adapte son texte d'aide selon:
  - abonnement reseau actif: rattachement + benefice direct de l'offre attribuee
  - sinon: rattachement au reseau avec design / contenus reseau
- le lien d'affiliation est affiche inline, avec clic de copie sur le lien lui-meme et sur une petite chip icone `copier`
- le bloc `Personnalisation` ne garde qu'un etat simple `aucun design partage` / `design partage`
- le bloc `Personnalisation` expose maintenant:
  - `Design reseau`
  - `Contenus reseau` (CTA reserve pour cablage ulterieur)
  - une ligne placeholder sur les contenus reseau partages, en attente de cablage donnees
- le tableau `Mes affilies` affiche des badges front explicites:
  - `Actif abonnement reseau`
  - `Actif hors abonnement reseau`
  - `Actif offre propre`
  - `Inactif`
- le tableau `Mes affilies` propose aussi un filtrage front simple par statut, sans recalcul metier:
  - acces via une petite chip `Filtrer` avec icone a cote du titre de colonne `Statut`
  - options limitees aux statuts reellement presents dans la liste affichee
  - menu compact avec retour a la ligne sur les libelles longs pour eviter les debordements visuels
- la colonne detail retire les formulations techniques / historiques et privilegie:
  - un detail metier court
  - la periode en cours quand elle est calculable canoniquement
  - le tarif hors abonnement quand il est disponible proprement
- aucune ecriture metier nouvelle n'est ajoutee cote PRO:
  - ni sur les activations / desactivations affilie;
  - ni sur les delegations `hors abonnement reseau`;
  - ni sur les offres propres affilie.

## Etat 2026-03-12 — Resolver reseau realigne sans nouveau chantier PRO

Le lot de stabilisation 1 / 2 / 2A / 2B ne rouvre pas d'UX PRO.

Effet fonctionnel confirme cote PRO:
- `ec.php`, le tunnel start et `Mon offre` continuent de lire le resolver canonique `app_ecommerce_offre_effective_get_context(...)`;
- les raisons d'inactivite exposees au front redeviennent coherentes avec les consommateurs encore actifs:
  - `network_contract_pending_payment`
  - `network_contract_inactive`
  - `network_contract_none`
  - `network_affiliate_not_activated`
  - `network_delegation_unavailable`
- aucune creation implicite d'offre support client n'est reintroduite cote PRO.

## Etat 2026-03-11 — `Mon offre` réseau: snapshot figé pour les offres historiques

Pour une offre `Abonnement reseau` qui n'est plus le support courant du client:
- `Mon offre` ne doit plus lire la facturation/couverture du support réseau actif du compte;
- la carte affiche un snapshot figé dérivé de la ligne d'offre elle-même;
- aucun CTA `Gerer mon reseau` n'est exposé sur cette archive.

## Etat 2026-03-11 — BO affiliés TdR stabilisé sans changement PRO direct

Le sous-lot courant ne modifie pas d'écran PRO.

Clarification de périmètre:
- la séparation `incluse à l'abonnement réseau` vs `hors abonnement réseau` est maintenant stabilisée côté BO sur `reseau_contrats`;
- `Mon offre` PRO n'a pas de nouveau bloc ni de nouveau CTA à intégrer dans ce lot;
- la cible reste inchangée:
  - `Mon offre` expose l'offre support `Abonnement reseau`
  - la gestion opérationnelle des affiliés reste sur la page réseau dédiée.

## Etat 2026-04-10 — TdR: CTA portail affilié aligné sur une souscription Stripe résolue

Correctif fonctionnel côté `pro`:
- une offre affiliée déléguée `hors cadre` n'expose plus le CTA `Gérer l'offre` sur le seul critère `asset_stripe_productId non vide`;
- la visibilité du CTA est désormais bornée à une vraie souscription Stripe résolue par le moteur global;
- au clic, le portail ouvert pour la TdR est le portail affilié standard, pas un deep-link immédiat vers la résiliation;
- effet attendu:
  - plus de CTA mort qui redirige ensuite vers `network_affiliate_subscription_snapshot_unavailable`;
  - pas d'impact sur les portails Stripe standard ni sur l'abonnement réseau support.

## Etat 2026-03-11 — Reseau et abonnements apres normalisation CTA

Le produit visible reste unique: `Abonnement reseau`.

PRO doit maintenant considerer que:
- le statut visible reseau vient de l'offre support `ecommerce_offres_to_clients`
- la gestion des affiliés et du hors cadre reste regroupee dans la page reseau, pas dans `Mon offre`
- les CTA Stripe sont determines par le statut reel de l'offre et non par des branches historiques concurrentes

Impacts visibles:
- `Mon offre` affiche pour l'`Abonnement reseau` un detail minimal meme en attente ou termine
- `Mon offre` ne liste plus ici le hors cadre rattache au reseau
- `Gerer mon reseau` n'est visible que pour une offre reseau en attente ou active
- pour les abonnements Stripe eligibles:
  - attente reseau: `Payer et activer mon abonnement`
  - actif sans date de resiliation: `Gerer mon abonnement`
  - actif avec date de resiliation: `Reactiver mon abonnement`
  - termine sans autre abonnement actif: `Commander a nouveau`
  - termine avec un autre abonnement actif: aucun CTA
- `Commander a nouveau` cree une nouvelle offre standard et ouvre directement le tunnel en etape `s2`

Limites:
- le reorder reprend les parametres stockes sur l'offre source, pas un recalcul catalogue frais
- une offre reseau terminee n'expose pas de reorder dans ce lot

## 2026-04-13 — Fiche session PRO: modale photo desktop

La modale desktop d'ajout photo sur la fiche detail d'une session archivee n'est plus forcee en `display:block` sur desktop au chargement: la classe responsive `d-none d-sm-block` a ete retiree du conteneur `.modal`, qui reste donc masque tant qu'il n'est pas ouvert par Bootstrap. Le CTA local d'upload conserve en plus un handler JS dedie qui rend d'abord le focus au bouton d'ouverture hors modale, ferme ensuite la modale Bootstrap, puis n'ouvre le picker fichier qu'apres `hidden.bs.modal`. Enfin, le polling deja present sur la fiche detail inclut maintenant la signature des photos podium (`photo_row_key` + `photo_src`) dans sa signature de synchronisation: si une photo est ajoutee depuis le mobile, la page desktop se recharge automatiquement.

## 2026-04-13 — Agenda historique PRO: CTA `Voir les résultats`

Dans la liste des sessions passees / terminees, la carte historique ne conserve plus qu'un seul CTA central `Voir les résultats`. Le lien secondaire `Gérer` est masque pour ces sessions archivees, et `Voir les résultats` mene desormais systematiquement a la fiche detail de session plutot qu'a l'interface de jeu.

## 2026-04-15 — `Mes joueurs`: lien archive sur `x sessions`

Dans le bloc `Classements par jeu` de `Mes joueurs`, la phrase de contexte ne rend plus un lien `(Détail)` annexe. Le lien archive filtré est maintenant porté directement par le texte `x session(s)` dans `Classement calculé sur x sessions jouées depuis le début de la saison`, sans modifier l'URL ni les bornes de période déjà utilisées.

## 2026-04-15 — `Mes joueurs`: filtre saison simplifié

Le filtre de période des classements `Mes joueurs` n'affiche plus deux selects `Année` + `Saison`. L'interface propose maintenant un unique select `Saison`, avec des libellés agrégés `Saison + année` sur le modèle du site public. La liste reste bornée aux périodes d'activité déjà remontées par le moteur, donc sans saisons vides.

## 2026-04-16 — `Gérer mon lieu`: visuel et description harmonisés

Le formulaire `extranet/account/establishment/manage` affiche maintenant un vrai bloc visuel:
- aperçu du visuel courant;
- upload enrichi avec consigne `laisser vide pour conserver`;
- accept des formats `jpg`, `jpeg`, `png`, `webp`, avant recadrage automatique par le pipeline existant.

Les descriptions lieu sont aussi réalignées avec un même traitement texte entre:
- le formulaire `manage`;
- la page `Ma communauté`;
- la page publique `place`.

Le descriptif long ne dépend plus d'un HTML saisi dans le back-office: les anciens `<br>` / balises sont nettoyés et les retours à la ligne utiles sont conservés.

Addendum:
- quand aucun visuel établissement n'est encore uploadé, `manage` et `Ma communauté` signalent explicitement que l'image affichée n'est qu'un exemple d'illustration;
- le texte d'aide du formulaire distingue désormais le cas `visuel réel conservé` du cas `visuel par défaut non publié`.
- le formulaire `manage` prévisualise aussi immédiatement le nouveau fichier choisi avant validation.
- le widget home `Ma communauté` suit désormais la même garde d'accès que la page elle-même, avec contenu distinct selon présence ou non du bloc d'infos générales.

## 2026-07-21 — Dashboard soirée/événement: fiche info et Programme

Le prototype dashboard jour (`/extranet/start/games/day/{date}/dashboard`) conserve les routes, données Hub et règles métier existantes, mais ajuste la composition UI:
- la colonne gauche commence par une fiche d'information unifiée: titre, métadonnée date/horaire/nombre de parties, visuel, logo éventuel, localisation et liens secondaires;
- le crayon flottant de personnalisation est supprimé; la modale existante s'ouvre depuis le lien compact `Personnaliser la soirée` / `Personnaliser l’événement`;
- `Voir la page publique` est affiché uniquement si `app_games_hub_public_resolve(...)` confirme une page Hub publicable;
- `Programme` peut afficher `Chaque partie peut accueillir jusqu’à N joueurs.` seulement quand toutes les sessions visibles exposent le même `championnats_sessions.nb_joueurs_max` positif;
- les CTA opérationnels `Télécommande` et `Diffuser aux joueurs` restent sous `Programme` sur desktop, alignés en bas de la colonne droite, puis passent juste après l'identité sur mobile;
- l'action unique `Modifier` des lots est dans l'en-tête du panneau `Lots`; la lecture reste une liste compacte de rangs.

Finition composition:
- la fiche d'information gauche est un seul conteneur `.event-dashboard__summary`; `event-dashboard__info-extra` est inclus dedans après le visuel, sans bordure/fond/rayon propre ni zone de grille séparée;
- les liens secondaires terminent la fiche après la localisation;
- l'ancien plafonnement desktop `--event-dashboard-program-scroll-height` / `max-height:calc(... 3 ...)` est supprimé;
- le dashboard utilise une grille desktop `header program / prizes program / . actions`;
- `Programme` est un bloc à hauteur naturelle avec `.event-dashboard__program-body` en grille visible et `.event-dashboard__session-list` sans scroll interne;
- la carte `Ajouter une partie` est rendue avant les parties existantes, sans indicateur de débordement ni calcul de hauteur JS.

Validation ciblée:
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`
- `php /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`

## 2026-04-17 — Widget home agenda: bascule archive alignee sur les fiches

L'agenda principal `pro` etait deja aligne sur la regle metier `archive si date passee ou session terminee`.

Le widget home `Mon agenda` / `Agenda du réseau` suit maintenant la meme logique. Il recharge toujours un jeu de sessions a venir par date, mais re-filtre ensuite via `app_sessions_filter_by_archive_state(...)` avant affichage et avant calcul des compteurs resumes.

Effet attendu: une session numerique terminee le jour meme disparait du widget home au meme moment que de la fiche detail historique, sans attendre le changement de date.

## 2026-04-17 — Agenda `pro`: label compact `quiz` mutualisé

L'agenda principal `pro` et le widget home n'affichent plus les noms complets de lots `Cotton Quiz` concaténés manuellement.

Ils utilisent maintenant le helper partagé `app_session_quiz_compact_label_get(...)`, ce qui donne:
- `1 serie`
- `2 series`
- `4 series`

avec fallback sur `theme` pour les anciens formats quand aucun libellé de séries n'est disponible.

## 2026-04-29 — Stripe abonnement: relance visible, coupure seulement a la cloture finale

Pour les abonnements Stripe illimites:
- `invoice.payment_failed` est seulement informatif cote Cotton: aucune coupure, aucune facture Cotton, aucune modification de `date_fin`;
- depuis la V1.1, `invoice.payment_failed` ajoute toutefois une trace append-only dans le `commentaire` de l'offre, dedupliquee par facture Stripe et tentative;
- pendant une subscription Stripe `past_due` ou `unpaid`, le compte PRO payeur voit un bandeau `Paiement de votre abonnement en attente` sur `Mon offre` et au-dessus des widgets de la home PRO;
- depuis la V1.1, le CTA principal pointe vers le portail Stripe client Cotton avec retour vers Cotton (`stripe_billing_return=1`), et non plus vers la facture Stripe hebergee;
- `hosted_invoice_url` n'est plus affiche dans le bandeau;
- au retour du portail, le message `Votre paiement a bien été régularisé.` n'est affiche que si le retour porte `stripe_billing_context=payment_failed`, que Stripe confirme la subscription `active` et que la derniere facture est `paid` ou soldee;
- les portails standards de `Mon offre` reviennent sans contexte impaye; seul le CTA du bandeau impaye porte `stripe_billing_context=payment_failed`;
- le bandeau n'affiche plus `next_payment_attempt` comme date limite de coupure, car cette date represente une tentative de relance Stripe;
- une offre deleguee payee par une TdR n'affiche pas le bandeau a l'affilie non payeur;
- quand Stripe termine vraiment la subscription (`status=canceled` ou `customer.subscription.deleted`), l'offre Cotton est synchronisee en `Terminee` (`id_etat=4`);
- si Stripe indique `cancellation_details.reason=payment_failed`, le champ `commentaire` de l'offre conserve une trace append-only de l'impaye.

Limite V1:
- pas de table d'incidents Stripe;
- pas de mail client automatique;
- pas de mapping vers `id_etat=1`, car cet etat reste un flux `Non payee -> Annulee` distinct de `Terminee`.
# Etat 2026-05-11 - LP reseau et parcours PRO inchanges

La personnalisation de LP reseau est portee par `www` + `global` sur l'abonnement reseau support. Cote `pro`, le parcours reste contractuellement le meme:
- `/utm/reseau/{slug}` conserve le contexte reseau dans `ec_sign.php`;
- signup et signin reutilisent l'affiliation existante;
- l'offre incluse n'est activee que si les conditions reseau existantes le permettent;
- aucune promesse affichee sur la LP ne doit contourner ces regles.

## Etat 2026-06-11 - Bibliotheque first_party: brouillon conserve

Le parcours bibliotheque -> `/extranet/onboarding/first-party` reutilise le brouillon `$_SESSION[first_party_onboarding_v1_{id_client}]` quand un compte `INS`, `ABN` ou `PAK` est en contexte first_party de pre-programmation et sans session officielle future.

Regles livrees:
- sans brouillon first_party, le comportement documente reste conserve: la selection bibliotheque initialise une preparation a une session et renvoie a l'etape 3;
- avec un brouillon d'une session, la selection remplace uniquement le theme/contenu de cette session et conserve le rythme;
- avec un brouillon de deux ou trois sessions, la selection devient un candidat temporaire: l'etape 3 affiche `Choisis la session dans laquelle utiliser ce thème.` et chaque bloc session propose `Remplacer par ce thème`;
- aucune quatrieme session n'est creee, aucun rythme n'est modifie, aucune session officielle n'est creee;
- le builder Cotton Quiz conserve la validation existante jusqu'a 4 series, puis applique les memes regles de remplacement/candidat sur la session brouillon ciblee.

L'astuce `Catalogue complet` de l'etape 3 n'est plus rendue dans chaque panneau de modification de session: elle est globale, sous les blocs de sessions, juste avant `Valider ces thèmes`.

## Etat 2026-07-01 - Home classique apres validation d'offre

La home reduite `first_party` est reservee aux comptes sans offre active. Des qu'une offre effective donne acces au service, y compris une periode d'essai active, la home PRO revient au rendu classique.

Regles livrees:
- `INS` sans offre active conserve la home reduite first_party quand le compte y est eligible;
- `ABN` / `PAK` avec offre active ou essai actif affichent la home classique, meme sans session officielle future;
- le widget onboarding first_party est rendu uniquement avec la home reduite; des que la home classique s'affiche, ce widget est masque;
- `ABN` / `PAK` actif sans session officielle future utilisent les etats vides et widgets existants de la home classique;
- l'etat vide du widget agenda Home suit l'usage: en gamification, titre `Ajoute ton prochain événement`, texte evenement et CTA ouvrant la modale date; en dynamisation, titre `Programmation`, texte soirées Cotton et CTA vers le programmateur de l'offre active;
- les logs dataLayer distinguent `Home réduite affichée [ INS sans offre active ]`, `Home classique affichée [ offre active ]` et `Home classique affichée [ offre active sans session ]`.

## Etat 2026-07-31 - Dashboard Hub: personnalisation reactive

Le dashboard Hub Pro resynchronise maintenant les actions structurelles de l'en-tete pendant ses refreshs HTML canoniques.

Effet attendu:
- quand le Hub repasse `en cours`, l'icone de personnalisation revient sans refresh complet;
- si la page avait ete chargee dans un etat termine, le modal historique de personnalisation est reintegre depuis le HTML serveur;
- l'ouverture `data-start-day-event-open` reste idempotente apres les remplacements DOM live.

Verification:
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`
- `php /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php`
- `php /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_session_theme_renewal_ajax_test.php`
## Update 2026-08-31 - Mode démo Hub au Dashboard

Agenda, programmation et Dashboard Hub sont accessibles aux comptes clients éligibles indépendamment de leur offre; la tête de réseau reste exclue. L'offre effective ne choisit plus l'accès au parcours mais le runtime: avant la fenêtre `Tester le jeu` ouvre une démo pour tous; pendant la fenêtre une offre active conserve `Lancer / Reprendre` officiel et une offre inactive conserve `Tester le jeu`; après la fenêtre seules les sessions terminées proposent `Résultats`.

Le bloc commercial `Mode démo` et son lien vers `/extranet/account/offers` sont rendus uniquement lorsque l'offre effective est inactive. Un client actif testant avant fenêtre ne voit aucun message commercial. Depuis Hub, chaque nouvelle intention `Tester le jeu` délègue au producteur Global par intention et crée un token démo neuf; les URLs démo historiques restent, elles, réutilisables.
