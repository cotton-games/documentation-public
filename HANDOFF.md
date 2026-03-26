# Handoff

> Note: les entrées plus bas restent un historique de livraison. Pour TdR/Affiliés, l'état courant de référence est celui décrit dans la première section ci-dessous.

## Play / Global — Sessions: CTA sécurisés + nouvelle table `championnats_sessions_participations_probables` — 2026-03-26

### Resume
- le premier lot `play` ne changeait encore que les libellés, alors que les CTA continuaient à appeler les write paths legacy d'inscription et d'accès jeu;
- le besoin produit validé est plus simple: `play` doit seulement permettre à un joueur ou à son équipe de prévenir l'organisateur, sans réservation et sans accès direct au runtime;
- ce lot introduit donc un support dédié de participation probable et recâble les écrans `play` dessus.

### Correctifs livres
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - ajout des helpers `app_session_participation_probable_get_detail/ajouter/supprimer` et des helpers count/list;
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `app_joueur_sessions_inscriptions_get_liste()` lit maintenant `championnats_sessions_participations_probables`;
  - `app_joueur_session_inscription_get_detail()` ne dépend plus des tables legacy Quiz/Bingo;
  - `app_joueur_session_inscription_get_link()` ne redirige plus vers un runtime de jeu;
- `play/web/ep/modules/jeux/sessions/*`
  - les modes POST passent à `session_participation_probable_ajouter/supprimer`;
  - suppression des reliquats d'accès jeu depuis `play` (`Ma grille de Bingo`, QR code grille, `Web Live`, `Indice web`);
  - l'agenda joueur et la fiche session restent maintenant cohérents avec la promesse `Je participe / Mon équipe participe`.
- `documentation`
  - ajout de `championnats_sessions_participations_probables_phpmyadmin.sql`;
  - mise à jour du schéma canon et de la carte repo `play`.

### Fichiers modifies
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
- `documentation/championnats_sessions_participations_probables_phpmyadmin.sql`
- `documentation/canon/data/schema/DDL.sql`
- `documentation/canon/data/schema/MAP.md`
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/HANDOFF.md`

### Verification
- `php -l` à lancer sur les fichiers `global` et `play` modifiés;
- import phpMyAdmin à faire avec `documentation/championnats_sessions_participations_probables_phpmyadmin.sql`.

## Pro — Agenda / détail session: restitution des participations probables — 2026-03-26

### Resume
- après sécurisation des CTA `play`, le lot suivant consistait à remonter l'information côté `pro`;
- le besoin prioritaire validé est simple: voir rapidement combien de joueurs/équipes ont signalé leur participation probable, puis ouvrir un détail à la demande;
- ce premier lot reste en lecture seule côté `pro`: aucune écriture métier supplémentaire n'est introduite.

### Correctifs livres
- `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
  - chaque carte de session programmée peut maintenant afficher un compteur de participations probables;
  - un bouton ouvre une modale listant les signalements reçus depuis `play`;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - ajout d'une ligne `Signalements` dans la fiche session;
  - ajout d'un bouton `Voir le détail` ouvrant une modale de liste nominative;
- la restitution s'appuie sur les helpers globaux déjà posés sur `championnats_sessions_participations_probables`.

### Fichiers modifies
- `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php` OK

## Play — Espace joueur: les CTA de session parlent maintenant de `Prévenir l'organisateur` — 2026-03-26

### Resume
- premier pas produit sur `play` pour sortir de la promesse d'inscription/réservation;
- le besoin métier validé est de permettre au joueur de signaler une participation probable, sans promettre de place ni d'accès au jeu;
- ce lot ne touche pas encore au backend legacy, seulement à la promesse portée par l'UI de l'espace joueur.

### Correctifs livres
- reformulation des écrans `home`, `equipe` et `sessions` pour remplacer `inscription` par une logique de signalement à l'organisateur;
- boutons principaux renommés en `Je participe` / `Mon équipe participe`;
- messages de confirmation et d'annulation reformulés pour parler de `signalement` et non d'inscription ferme;
- mentions de réservation clarifiées pour rappeler qu'aucune place n'est garantie.

### Fichiers modifies
- `play/web/ep/modules/communication/home/ep_home_index.php`
- `play/web/ep/modules/compte/equipe/ep_equipe_view.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/HANDOFF.md`

### Verification
- revue manuelle des libellés modifiés;
- `npm run docs:sitemap` à exécuter après mise à jour de la documentation.

## Documentation — Ajout du repo `play` au canon documentaire — 2026-03-26

### Resume
- le workspace Cotton contient maintenant un repo `play`, mais la documentation canon `canon/repos/*` ne le référençait pas encore;
- l'objectif était d'aligner `play` sur le modèle documentaire des autres repos sans inventer une structure parallèle;
- l'audit a confirmé un front PHP centré sur `play/web/ep/*`, avec dépendance forte vers `global` et une convention locale de sécurité où `web/config.php`, `web/info.php` et `logs/` restent hors git.

### Correctifs livres
- création de `documentation/canon/repos/play/README.md`
  - scope du repo;
  - entrypoints HTTP/PHP;
  - surfaces fonctionnelles principales;
  - dépendances inter-repos;
  - conventions locales/sécurité.
- création de `documentation/canon/repos/play/TASKS.md`
  - point d'entrée de suivi pour les prochains changements sur `play`.
- régénération des fichiers générés de navigation doc pour faire apparaître `play`.

### Fichiers modifies
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/HANDOFF.md`
- `documentation/SITEMAP.md`
- `documentation/SITEMAP.txt`
- `documentation/SITEMAP.ndjson`
- `documentation/canon/repos/INDEX.md`
- `documentation/canon/repos/play/INDEX.md`

### Verification
- `npm run docs:sitemap` à exécuter après ajout des pages canon `play`.

## Pro / Global — E-commerce: confirmation de commande branchée sur AI Studio transactionnel — 2026-03-26

### Resume
- le mail client de confirmation de commande etait encore envoye par l'ancien appel Brevo direct dans `app_ecommerce_commande_ajouter()`;
- le journal AI Studio du 25/03/2026 listait deja la professionnalisation des emails transactionnels et signalait que l'integration de ce mail dans `app_ecommerce_functions.php` restait a faire;
- le lot reste borne au remplacement du point d'envoi, sans changer les gardes metier existantes de premiere facture / type d'offre.

### Correctifs livres
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - conserve le bloc legacy Brevo en commentaire pour validation courte;
  - remplace l'envoi effectif par `ai_studio_email_transactional_send('ALL', 'ALL', 'INVOICE_MONTHLY', ...)`;
  - transmet maintenant au flux AI Studio les variables attendues par le template transactionnel (`CLIENT_NOM`, `CONTACT_*`, `CONTACT_EMAIL`, `COMMANDE_DATE`, `COMMANDE_OFFRE_NOM`, `COMMANDE_TOTAL_TTC`);
  - garde intactes les conditions d'emission actuelles: premiere facture seulement et perimetre offre/paiement deja en place.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
- recette reelle d'envoi AI Studio / n8n / Brevo non jouee dans ce tour.

## Pro — EC desktop: la navigation gauche prend moins de largeur — 2026-03-25

### Resume
- besoin UX limite au desktop: liberer de la place pour le contenu sans refaire la navigation EC;
- l'audit a confirme que la largeur du shell et le decalage du contenu venaient du theme dashboard global, tandis que l'EC possede deja sa propre couche de surcharge CSS;
- le lot est donc borne a une surcharge CSS locale et reversible.

### Correctifs livres
- `pro/web/ec/includes/css/ec_custom.css`
  - ajoute une surcharge desktop `min-width: 992px`;
  - ramene la largeur effective de la nav a `13.75rem`;
  - conserve le padding gauche historique du shell et reduit principalement l'emprise a droite;
  - unifie la largeur utile des `nav-item` desktop pour y caler logo, liens et CTA sans offsets contradictoires;
  - neutralise aussi les marges negatives heritees sur `ul.navbar-nav[data-simplebar]` pour eviter l'ascenseur horizontal du panneau;
  - recale aussi `navbar-collapse` a `width: 100%` sans compensations laterales negatives pour mieux inscrire la navigation dans son conteneur;
  - retire enfin le padding lateral propre du shell desktop, et porte la largeur utile de navigation a `100%` du panneau pour un calage plus net;
  - augmente legerement l'air lateral du footer bas, rend ses liens d'icones en flex et leurs `svg` non compressibles pour eviter la coupe visuelle du bouton `Contact`;
  - reduit aussi la largeur du menu mobile y compris en etat `sidebar-menu`, ajoute un override telephone plus agressif sous `576px`, et borne le drawer en hauteur avec scroll global pour garder le footer d'icones dans le flux visible;
  - repartit les 3 icones du footer bas en `space-between`;
  - recale le `margin-left` de `.main-content` sur cette nouvelle largeur.

### Fichiers modifies
- `pro/web/ec/includes/css/ec_custom.css`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- diff CSS relu;
- recette visuelle desktop a faire sur les ecrans EC principaux.

## Pro — Tunnel commande EC: le step 2 n'affiche plus un faux essai gratuit pour un ABN CSO — 2026-03-25

### Resume
- le bug etait purement UX sur le recap de commande avant bascule Stripe;
- le step 2 affichait un essai gratuit des qu'un `trial_period_days` etait stocke sur l'offre client;
- le checkout Stripe standard n'appliquait pourtant ce trial que pour `INS`, avec une exception specifique pour le client `712`.

### Correctifs livres
- `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_2.php`
  - recalcule maintenant le `trial` effectivement applicable au lieu de relire brut `trial_period_days`;
  - n'affiche plus la promesse `Essai gratuit...` pour un compte `CSO` standard;
  - conserve l'exception client `712` et l'absence de trial en contexte delegue reseau.

### Fichiers modifies
- `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_2.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/HANDOFF.md`

## Pro — Stripe e-commerce: `customer.subscription.updated` ne declenche plus de sync reseau sur compte independant — 2026-03-25

### Resume
- le bug du lot 2 etait localise dans `customer.subscription.updated`:
  - le portail Stripe standard etait correct pour un compte independant;
  - mais le webhook tentait quand meme une sync delegation reseau, puis fabriquait un `stripe_action` a thematique reseau quand le helper renvoyait `delegated_context_missing`;
- le correctif reste volontairement borne au garde-fou amont dans le webhook;
- aucun email client n'est ajoute dans ce lot;
- l'absence actuelle d'emails transactionnels client `update / renewal / unsubscribe` reste donc un etat connu du code et releve du patch 3, pas d'une regression patch 2.

### Correctifs livres
- `pro/web/ec/ec_webhook_stripe_handler.php`
  - lit toujours l'offre cible par `asset_stripe_productId`;
  - ne lance la sync delegation reseau que si l'offre retrouvee a effectivement `id_client_delegation > 0`;
  - conserve les vrais cas reseau support/delegue, mais laisse les comptes independants sur un parcours standard/no-op, sans libelle reseau parasite dans l'email admin webhook.

### Limites explicites
- l'email admin standard sur `customer.subscription.updated` peut toujours exister; ce lot supprime seulement le faux theme reseau sur compte independant;
- les emails client specialises `update / renewal / unsubscribe` restent hors lot et devront etre audites / implementes dans un patch 3 dedie.

### Fichiers modifies
- `pro/web/ec/ec_webhook_stripe_handler.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/HANDOFF.md`

## Pro / Global — Stripe e-commerce: idempotence persistante avant creation de commande Cotton — 2026-03-25

### Resume
- l'audit avait deja prouve deux trous restants:
  - `invoice.paid` pouvait encore dupliquer une facture Cotton sur concurrence, car le rattachement `invoice.id` arrivait apres creation;
  - `payment_intent.succeeded` recreait une commande PAK sans garde persistante.
- le lot livre ici reste volontairement borne a l'idempotence des writes Cotton:
  - pas de refonte webhook globale;
  - pas de correction du faux declenchement reseau sur `customer.subscription.updated`;
  - pas de changement email.

### Correctifs livres
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - ajoute une table de garde `ecommerce_stripe_write_guards` creee a la demande;
  - ajoute les helpers de lock/claim/complete pour `invoice.id`, `payment_intent.id` et `event.id`;
  - ajoute un token `stripe_payment_intent_id` et un parametre optionnel pour injecter `commentaire_facture` des l'insert de commande.
- `pro/web/ec/ec_webhook_stripe_handler.php`
  - verrouille maintenant `payment_intent.succeeded` et `invoice.paid` avant toute creation de commande;
  - sort proprement des retries deja completes;
  - reutilise une commande deja trouvee par token Stripe si un etat partiel ancien est detecte;
  - conserve `customer.subscription.updated` inchange dans ce lot.

### Fichiers modifies
- `pro/web/ec/ec_webhook_stripe_handler.php`
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/HANDOFF.md`

## Pro / Global — Stripe e-commerce: compatibilite restauree pour `app_client_contact_get_detail()` — 2026-03-25

### Resume
- les logs prod du 2026-03-24 ont ensuite confirme un fatal PHP dans le webhook Stripe:
  - `Call to undefined function app_client_contact_get_detail()`
  - stack via `app_ecommerce_commande_ajouter()`;
- l'erreur ne venait pas de Brevo lui-meme mais d'un read path contact incoherent avant l'envoi des mails;
- le correctif reste volontairement minimal et retrocompatible.

### Correctifs livres
- `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
  - ajoute un alias `app_client_contact_get_detail(...)` qui delegue au helper legacy `client_contact_get_detail(...)`.
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - harmonise le second call site e-commerce `global` sur le nommage `app_*`.

### Fichiers modifies
- `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/HANDOFF.md`

## Pro / Global — Stripe ABN: le webhook `invoice.paid` ne recree plus de factures Cotton sur retry — 2026-03-24

### Resume
- diagnostic confirme a partir de Stripe Workbench:
  - une seule facture Stripe reelle pour le client;
  - le meme `event.id` `invoice.paid` rejoue apres plusieurs reponses `500`;
  - erreurs secondaires Brevo sur move de liste `160 -> 161` (`already removed` / `already in list`) et sorties HTTP parasites dans le webhook.
- cote Cotton, la cause etait double:
  - absence de garde d'idempotence sur `invoice.paid`;
  - helpers Brevo `lib_*` non silencieux et non tolerants a certains no-op metier.

### Correctifs livres
- `pro/web/ec/ec_webhook_stripe_handler.php`
  - dedoublonne maintenant `invoice.paid` a partir de l'`invoice.id` Stripe deja rattache a une commande Cotton;
  - ignore un retry deja traite au lieu de recreer une facture interne;
  - journalise sans echec bloquant les incidents secondaires `Invoice::update` Stripe et mail admin webhook.
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - ajoute des helpers de rattachement/relecture `stripe_invoice_id` via `ecommerce_commandes.commentaire_facture`.
- `global/web/assets/sendinblue/api/sendinblue_api_functions.php`
  - supprime les `print_r/echo` dans les helpers `lib_*`;
  - traite `already removed from list` et `already in list` comme cas idempotents sur les moves de listes Brevo.

### Fichiers modifies
- `pro/web/ec/ec_webhook_stripe_handler.php`
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `global/web/assets/sendinblue/api/sendinblue_api_functions.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/HANDOFF.md`

## Games / Bingo / Blindtest / Quiz — logs prod cibles reprise joueur mobile — 2026-03-24

### Resume
- besoin de suivi court terme: verifier demain la stabilite reelle des sessions joueur apres les sessions du jour, sans remonter toute l'instrumentation debug lifecycle en prod;
- cote front commun `games`, une nouvelle preuve `info` `PLAYER_SESSION_RESUME_OK` est maintenant emise uniquement quand une vraie reprise joueur aboutit (`foreground:*` ou `ws_open_reconnect`);
- cote serveurs WS, les 3 jeux remontent maintenant une preuve `info` `PLAYER_WS_BOUND` a chaque rattachement player WS:
  - Bingo via `auth_player`,
  - Blindtest et Quiz via `registerPlayer`,
  avec `{ player_id, player_db_id, player_name, is_reconnect }` (et `is_admin_paper` si pertinent);
- objectif de lecture demain:
  - warnings transport (`WS_CLIENT_DISCONNECTED`, `WS_HEARTBEAT_TERMINATE`, `PLAYER_REREGISTER_FAIL`) d'un cote,
  - preuves positives de reprise/rattachement (`PLAYER_SESSION_RESUME_OK`, `PLAYER_WS_BOUND`) de l'autre.

### Fichiers modifies
- `games/web/includes/canvas/play/play-ws.js`
- `games/web/includes/canvas/core/logger.global.js`
- `bingo.game/ws/bingo_server.js`
- `bingo.game/version.txt`
- `blindtest/web/server/actions/registration.js`
- `blindtest/web/server/restart_serveur.txt`
- `quiz/web/server/actions/registration.js`
- `quiz/web/server/restart_serveur.txt`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/bingo.game/TASKS.md`
- `documentation/canon/repos/bingo.game/README.md`
- `documentation/canon/repos/blindtest/TASKS.md`
- `documentation/canon/repos/blindtest/README.md`
- `documentation/canon/repos/quiz/TASKS.md`
- `documentation/canon/repos/quiz/README.md`
- `documentation/HANDOFF.md`

## Branding jeux — qualite visuelle `games` + EC TdR alignes — 2026-03-24

### Resume
- le visuel branding charge dans `games` pouvait apparaitre net au premier paint puis devenir flou quelques secondes apres;
- cote `games`, une ancienne `dataURL` locale issue du preview pouvait reprendre la main sur l'URL serveur branding au boot;
- cote `global`, le recadrage final JPEG forcait encore une qualite `80`, ignorant la qualite demandee;
- cote `pro` EC TdR, le script d'upload reseau restait plafonne a une cible `600x240`, plus degradante que le flux `games`.

### Correctifs livres
- `games/web/includes/canvas/core/session_modals.js`
  - conserve le `File` original pour le save branding, tout en gardant un preview local leger;
  - ne persiste plus les objets `File` dans le localStorage;
  - fusionne le `ServerBranding` serveur avec le cache local au boot au lieu d'ecraser la version serveur;
  - remplace une ancienne `dataURL` locale par l'URL serveur branding si elle existe deja;
  - reecrit le branding local persistant avec l'URL serveur finale apres save reussi.
- `global/web/lib/core/lib_core_upload_functions.php`
  - `upload_image_recadrer()` respecte maintenant la qualite JPEG/PNG demandee.
- `global/web/app/modules/general/branding/app_branding_ajax.php`
  - le flux branding `games` demande maintenant `100` en qualite et une cible visuel max `1600x640`.
  - le flux branding remonte maintenant aussi des erreurs explicites `logo` / `visuel` pour upload trop lourd, partiel, bloque, ou POST depassant `post_max_size`.
  - la suppression branding est maintenant bornee a la portee demandee quand le front demande explicitement un reset session/client.
- `global/web/app/modules/general/branding/app_branding_functions.php`
  - le helper branding adapte la cible finale du `visuel` a la taille source pour eviter tout upscale artificiel.
- `pro/web/ec/modules/general/branding/ec_branding_script.php`
  - le flux EC TdR utilise maintenant lui aussi la cible visuel haute `1600x640`.
  - le flux EC TdR detecte aussi les erreurs d'upload et redirige avec un message clair.
- `games/web/includes/canvas/core/session_modals.js`
  - le reset branding organizer demande maintenant explicitement la suppression de la seule couche session, puis recharge le branding effectif restant au lieu de forcer le theme du jeu.
- `pro/web/ec/modules/general/branding/ec_branding_form.php`
  - l'ecran `form` affiche maintenant l'erreur branding retournee dans l'URL.
- `pro/web/ec/modules/general/branding/ec_branding_view.php`
  - l'ecran `view` affiche aussi cette erreur au retour.

### Fichiers modifies
- `games/web/includes/canvas/core/session_modals.js`
- `global/web/lib/core/lib_core_upload_functions.php`
- `global/web/app/modules/general/branding/app_branding_ajax.php`
- `global/web/app/modules/general/branding/app_branding_functions.php`
- `pro/web/ec/modules/general/branding/ec_branding_script.php`
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — Design réseau: la confirmation de sauvegarde cible le bon formulaire — 2026-03-24

### Resume
- au clic sur `Confirmer` dans la modale de sauvegarde du design reseau, l'utilisateur pouvait retomber sur la home EC sans enregistrement;
- cause confirmee: le formulaire branding reutilisait l'id generic `frm`, deja present ailleurs dans le shell EC pour le switch multi-compte;
- le JS de la modale soumet maintenant un id de formulaire dedie `network-branding-form`, ce qui retablit la sauvegarde.

### Fichiers modifies
- `pro/web/ec/modules/general/branding/ec_branding_form.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Www — BO clients: le lien EC temporaire se copie au lieu de s'ouvrir — 2026-03-24

### Resume
- apres generation du lien EC temporaire depuis la fiche client BO, l'URL etait affichee comme un lien cliquable et pouvait etre suivie par erreur;
- la fiche client BO affiche maintenant cette URL comme une action de copie interne, avec un bouton `Copier le lien` et un feedback simple `Lien copié`.

### Fichiers modifies
- `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — EC: les cookies BO de delegation sont expires des leur consommation — 2026-03-24

### Resume
- en navigation classique, le dernier compte BO visite pouvait se recoller sur de nouveaux passages par `authentication/script`;
- cause confirmee: `ec_authentification_script.php` lisait bien `CQ_admin_gate_*`, mais ne faisait qu'un `unset($_COOKIE)` local sans expirer les vrais cookies navigateur;
- le point d'entree expire maintenant explicitement ces cookies au format domaine `cotton-quiz.com` des leur consommation.

### Fichiers modifies
- `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — EC: la déconnexion nettoie complètement la session après un lien temporaire — 2026-03-24

### Resume
- `develop` et `main` n'ont pas d'ecart sur les fichiers du flux auth/deconnexion concernes;
- le script `ec_deconnexion_script.php` restait toutefois incomplet: seule une partie du scope de session EC etait purgee;
- la deconnexion nettoie maintenant tout le scope d'authentification EC, detruit aussi le cookie de session PHP et expire les cookies BO historiques s'ils existent encore.

### Fichiers modifies
- `pro/web/ec/modules/compte/deconnexion/ec_deconnexion_script.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — BO: l'accès direct admin vers l'EC ne retombe plus sur `signin` — 2026-03-24

### Resume
- l'acces historique BO vers l'EC via `gate.php` posait toujours bien les cookies admin de delegation;
- la regression venait du script `ec_authentification_script.php`, qui relisait ensuite `$_GET` et prenait les parametres de routing `t/m/p/l` pour une nouvelle requete d'authentification;
- ce second passage reinitialisait `$url_redir` et faisait retomber l'admin sur `signin`;
- le bloc `request` est maintenant ignore quand le flux BO a deja initialise `session_init = 1`, ce qui retablit l'acces direct admin sans casser le lien temporaire par token.

### Fichiers modifies
- `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — Session test: la démo reprend maintenant le branding session de la session programmée — 2026-03-24

### Resume
- depuis la fiche detail d'une session programmée, le CTA `Tester` cree toujours une session démo, mais cette démo reprend maintenant aussi le branding session de la session source quand il existe;
- le CTA ouvre maintenant directement cette session démo sur `games/master/{id_securite_session}` dans un nouvel onglet, sans passer par l'etape `resume`;
- la resolution runtime du branding priorise desormais explicitement le branding `general_branding` de type `session`, avant les fallbacks historiques `evenement`, `reseau`, puis `client`;
- le write path `session_duplicate` recopie aussi le branding session et ses assets vers la session démo cible, ce qui evite qu'une démo issue d'une session personnalisée retombe sur un autre habillage.

### Fichiers modifies
- `global/web/app/modules/general/branding/app_branding_functions.php`
- `global/web/app/modules/jeux/sessions_branding/app_sessions_branding_functions.php`
- `global/web/app/modules/jeux/sessions/app_sessions_join.php`
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — Design réseau: CTA `Voir le rendu réel` sur design actif — 2026-03-24

### Resume
- la `view` du design reseau affiche maintenant le lien `Voir sur une session démo` a cote du badge d'etat de la carte quand un design actif existe, avec une icone de nouvel onglet visible;
- ce CTA ouvre une vraie session démo dans un nouvel onglet, pour visualiser le branding tel qu'il sera vu en jeu;
- le contenu source est choisi cote serveur avec cette priorite: contenu partage reseau exploitable (`blindtest`, puis `bingo`, puis `quiz`), sinon playlist `blindtest` populaire et validee;
- la session n'est jamais creee au simple affichage de la page: elle est instanciee uniquement au clic via le flux demo existant de la bibliotheque;
- la `form` d'edition n'affiche pas ce CTA;
- le module branding charge maintenant explicitement `ec_bibliotheque_lib.php`, sans quoi les helpers `clib_*` utilises pour choisir la demo restaient indisponibles.

### Fichiers modifies
- `pro/web/ec/modules/general/branding/ec_branding_view.php`
- `pro/web/ec/modules/general/branding/ec_branding_form.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — Navigation: le CTA `Tarifs & commande` redevient disponible pour les affiliés Beer's Corner sans offre active — 2026-03-23

### Resume
- le shell EC portait encore une exception hardcodee `id_client_reseau = 1294` qui masquait `Je commande / Tarifs & commande` pour tous les affiliés Beer's Corner;
- cette exception s'appliquait meme a des affiliés n'ayant plus d'offre active et seulement un historique termine;
- la condition a ete retiree: le CTA redevient pilote par la logique generale `pas d'offre active effective / pas de restriction self-service TdR / pending payment autorise`.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — Offres TdR: l'historique des delegations terminees re-affiche la date de fin — 2026-03-23

### Resume
- dans `Offres` cote TdR, une offre deleguee `hors cadre` terminee pouvait encore perdre la mention `Abonnement terminé depuis le ...` alors que `date_fin` etait bien visible en BO;
- le composant `ec_offres_include_detail.php` savait deja afficher cette ligne, mais la boucle d'historique de `ec_offres_view.php` lui passait ces lignes avec `offre_detail_is_network_hors_cadre = 0`;
- les lignes d'historique TdR deleguees terminees transportent maintenant explicitement ce flag `hors cadre`, ce qui reactive le rendu de la date de fin.

### Fichiers modifies
- `pro/web/ec/modules/compte/offres/ec_offres_view.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — TdR: `Mes affiliés` clarifie la remise reseau + facture PDF affiche le pourcentage — 2026-03-23

### Resume
- `Mes affiliés` affiche maintenant un vrai bloc haut dedie a la remise reseau, juste sous le lien d'affiliation;
- ce bloc adopte un angle marketing simple (`Une remise qui évolue avec ton réseau !`) puis affiche soit le pourcentage de remise actuellement applique, soit un message d'amorcage `5% dès ta 2e commande` quand la remise courante vaut encore `0%`;
- la phrase courte `Calculée sur X affilié(s) actif(s)*` renvoie vers une explication inline de bas de page rappelant le caractere dynamique de la remise et les paliers reseau;
- dans le tableau, `À venir : X session(s)` n'apparait que si des sessions futures existent reellement, la mention `Remise réseau de x% !` sous `Commander` reste conditionnelle, et les cellules / CTA sont centres verticalement sans etirer les boutons;
- les factures PDF affichent maintenant `Remise réseau : x,xx %` sur la ligne produit quand une remise s'applique, y compris pour des factures historiques dont la ligne stockee etait incomplete grace a un fallback sur l'offre client liee.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — Mon offre affilié: historique delegue termine recharge aussi si une offre propre existe — 2026-03-23

### Resume
- le rendu `Mon offre` cote affilié savait deja afficher `Abonnement terminé depuis le ...` pour une offre deleguee terminee;
- les offres deleguees vues par un affilié re-affichent aussi maintenant `Offre pilotée par {nom_TdR}` juste sous la ligne `Référence`, dans la couleur du badge `Déléguée`;
- cote TdR, la mention `Délégation de l'offre à {nom_affilié}` est harmonisee sur cette meme couleur et le meme niveau de mise en avant;
- le vrai blocage venait du helper global `app_ecommerce_offres_client_get_liste()`;
- ce helper ne chargeait les offres deleguees (`id_client_delegation = affilié`) qu'en fallback si aucune offre propre (`id_client = affilié`) n'etait trouvee;
- des qu'un affilié avait a la fois une offre propre et une offre deleguee terminee, l'offre deleguee disparaissait donc de l'historique avant meme le rendu;
- le helper recharge maintenant les deux sources en une seule requete (`id_client = affilié OR id_client_delegation = affilié`), ce qui retablit l'affichage cote affilié.
- un second durcissement reinitialise aussi explicitement le contexte du composant `ec_offres_include_detail.php` dans les boucles `Offres` et `Historique`, pour eviter toute fuite d'etat entre deux cartes successives.
- la derniere cause residuelle etait ensuite purement structurelle dans `ec_offres_include_detail.php`: dans la branche `ABN SANS engagement`, le rendu delegue etait reste imbrique sous `if (id_etat==3)`, ce qui rendait morte la sous-branche `id_etat==4`;
- l'accolade a ete remise au bon niveau, ce qui retablit enfin l'affichage de `Abonnement terminé depuis le ...` pour une offre deleguee terminee `sans engagement`.

## Pro — Mes affiliés: ajout du compteur de sessions a venir — 2026-03-23

### Resume
- dans la colonne `Infos` de `Mes affiliés`, chaque ligne affichait deja le nombre total de sessions de jeu programmées;
- un second compteur est maintenant affiche juste en dessous, avec le libelle colore `À venir :`;
- ce compteur reprend la convention deja utilisee dans le shell EC: sessions non demo, configuration complete, date de session >= date du jour.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_list.php`
- `pro/web/ec/modules/compte/offres/ec_offres_view.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — Diagnostic prod: log cible sur offre deleguee terminee cote affilie — 2026-03-23

### Resume
- ajout d'un log temporaire tres cible dans le rendu `Mon offre` cote affilie;
- il ne se declenche que pour une offre deleguee terminee;
- il remonte l'etat, la date brute, la date effective calculee et les booleens exacts utilises pour afficher `Abonnement terminé depuis le ...`.

### Fichiers modifies
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/HANDOFF.md`

## Pro — Offre 12 sans engagement: affichage delegue termine securise cote affilie — 2026-03-23

### Resume
- l'audit confirme que l'offre `12` est deja traitee comme un ABN mensuel `sans engagement` dans les write paths et le cron;
- le seul trou fonctionnel bloqueur pour realigner dev sur prod et merger vers `main` etait le rendu `Mon offre` cote affilié;
- ce rendu n'affiche plus la mention `Abonnement terminé depuis le ...` uniquement dans la branche `avec engagement`: le cas `sans engagement` est maintenant couvert aussi;
- le log temporaire de diagnostic a ete retire apres confirmation de la cause.

### Fichiers modifies
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — Dev diagnostic: log cible sur branche `sans engagement` cote affilie — 2026-03-23

### Resume
- ajout d'un log temporaire sur la branche `ABN SANS engagement` pour les offres deleguees cote affilié;
- le but est de verifier, en dev, les variables exactes lues juste avant le rendu de `Abonnement terminé depuis le ...` apres retrait du flag `engagement` sur l'offre `12`.

### Fichiers modifies
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/HANDOFF.md`

## Pro — Navigation EC: `Ma fiche lieu` masque pour une TdR meme en test — 2026-03-23

### Resume
- le lien `Ma fiche lieu` n'est plus propose a une tete de reseau, y compris si le compte est en etat `TEST`;
- la derogation `TEST` est conservee uniquement pour les comptes non TdR.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — Navigation EC: lien `Branding` retire du menu — 2026-03-23

### Resume
- le lien de navigation `Branding` n'est plus affiche dans le shell EC;
- la condition legacy basee sur le cookie `CQ_admin_gate_client_id` est maintenant desactivee explicitement, avec commentaire date dans `ec.php`.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Pro — TdR/Affiliés: `Mes affiliés` expose aussi le support en attente — 2026-03-23

### Resume
- la micro-synthese au-dessus de la liste des affiliés ne se limite plus au seul support reseau actif;
- un `Abonnement reseau` `En attente de paiement` y est maintenant aussi signale explicitement;
- cette information reste masquee si l'offre support est a `0 EUR`, en alignement avec le comportement de `Offres`;
- le lien associe renvoie vers `Offres`, sous le libelle `Gérer l'offre`, afin que le CTA `Payer et activer l'abonnement` reste porte par cette page et non par un depart direct vers Stripe.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

## Www — BO reporting jeux: portage patch sur main sans merge develop — 2026-03-20

### Resume
- le correctif `cron dedie + lecture sur agregats existants` valide sur `develop` a ete reconstruit directement sur `main`;
- aucun merge `develop -> main` n'a ete utilise, pour eviter d'embarquer des changements non destines a la prod;
- `main` porte maintenant le meme point d'entree cron dedie et le meme branchement preferentiel sur `reporting_games_*`.

### Fichiers modifies
- `www/web/bo/includes/bo_reporting_games_aggregates.php`
- `www/web/bo/cron_reporting_games_aggregates.php`
- `www/web/bo/cron_routine_bdd_maj.php`
- `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/HANDOFF.md`

## Www — BO facturation pivot: agrégation sessions allégée — 2026-03-20

### Resume
- la page `bo/?t=syntheses&m=facturation_pivot&p=saas` recalculait deux fois les sessions jeux sur `championnats_sessions`;
- le second passage ne servait qu'à reconstituer les seules sessions numériques pour les ratios;
- le reporting garde maintenant ses sessions totales et ses sessions numériques utiles dans une seule agrégation SQL;
- le second scan dédié est retiré, sans changer les KPI exposés dans la page.

### Fichiers modifies
- `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/HANDOFF.md`

## Pro — TdR/Affiliés: headers simplifies + retours home — 2026-03-20

### Resume
- `Mes affiliés`, `Design du réseau` et `Jeux du réseau` retirent leurs sous-titres de header redondants;
- depuis la home reseau, ces pages affichent maintenant `← Retour à l'accueil`;
- cote affilié, `← Retour à la bibliothèque` reprend le style de `← Retour au catalogue`.

### Fichiers modifies
- `pro/web/ec/modules/communication/home/ec_home_index.php`
- `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `pro/web/ec/modules/general/branding/ec_branding_view.php`
- `pro/web/ec/modules/general/branding/ec_branding_form.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/HANDOFF.md`

## Pro — Jeux du réseau: blocs d'intro passes au split media/text — 2026-03-20

### Resume
- les 2 blocs d'intro/outillage de la page `Jeux du réseau` passent maintenant sur une carte `visuel a gauche / contenu a droite`;
- le visuel reutilise `catalogue_contenus.png`, deja employe sur la home pour `Jeux réseau`;
- les CTA existants restent en bas de bloc quand ils sont presents, et les chips de scope TdR restent sous le second bloc.

### Fichiers modifies
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/HANDOFF.md`

## Pro — Home TdR: hero affiliation passe au split media/text — 2026-03-20

### Resume
- la home TdR garde sa 1re ligne `2/3 - 1/3`, avec la carte de synthese reseau toujours separee a droite;
- le hero gauche abandonne le rendu `image pleine largeur + mini-carte inline` et reprend le pattern home INS `visuel a gauche / contenu a droite`;
- la partie gauche affiche maintenant le nom du compte TdR et retire les anciennes pills basses;
- la partie droite passe sur un titre `Ton lien d'affiliation`, une checklist a trois lignes avec icones `check`, puis la phrase d'aide, le lien et le feedback de copie;
- le bouton secondaire inline reste retire, et le CTA principal devient l'action unique `Copier le lien`;
- la logique metier ne change pas: meme source pour le slug reseau, meme copie clipboard, aucune nouvelle source de verite.

### Fichiers modifies
- `pro/web/ec/modules/communication/home/ec_home_index.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/HANDOFF.md`

## Games — remote flush meta: hydrate `ws_ready_state` from connector runtime snapshot — 2026-03-20

### Resume
- audit ciblé après validation terrain du flush `remote`:
  - le flush viewer -> `remote` fonctionnait bien sur Bingo et Blindtest (`PLAYER_FRONT_LOG_FLUSH_TRY|OK` + `LOG_BATCH_RX` côté serveur);
  - mais la méta des preuves remontait encore `ws_ready_state=unknown` sur `remote`, alors que les batchs partaient bien sur WS.
- cause exacte confirmée:
  - `logger.global.js` ne s’accroche au `Bus` que lorsque `window.Bus` existe, avec retry par polling;
  - `remote-ws.js` / `ws_connector.js` peuvent donc émettre le premier `ws/status=open` avant l’accroche effective du logger;
  - le transport reste fonctionnel, mais le logger garde `wsStatus/wsReadyState` à `null`, d’où `unknown` au flush.
- correctif minimal partagé livré:
  - `ws_connector.js` publie un snapshot runtime `window.__CANVAS_WS_RUNTIME__` sur les transitions `connecting`, `opening-auth`, `open`, `closed`, `error`;
  - `logger.global.js` relit ce snapshot avant `buildFlushMeta()`, `isProofTransportReady()` et à l’accroche tardive `tryHookBus()`;
  - effet attendu: sur `remote`, un flush sur socket déjà ouverte remonte maintenant `ws_ready_state:"open"` au lieu de `unknown`, sans changer la stratégie de flush ni le protocole WS.
  - `games/web/config.php` rebouge aussi `CANVAS_ASSET_VER` vers `v=2026-03-20_05` pour purger les clients restés sur un `logger.global.js` intermédiaire du même jour, ce qui expliquait encore des preuves `PLAYER_FRONT_LOG_FLUSH_TRY|OK` vues en `info` malgré le code courant en `debug`.

### Fichiers modifies
- `games/web/config.php`
- `games/web/includes/canvas/core/ws_connector.js`
- `games/web/includes/canvas/core/logger.global.js`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- valider en recette distante:
  - Bingo remote: `PLAYER_FRONT_LOG_FLUSH_TRY|OK` avec `role:"remote"` et `ws_ready_state:"open"` après `force_flush`;
  - Blindtest remote: même preuve;
  - vérifier qu’un vrai `closed/error` reste bien reflété dans la méta si le flush survient après déconnexion.

## Games / Bingo — logs front player+remote: boot proof replay + force_flush distant Bingo — 2026-03-20

### Resume
- audit ciblé confirme la cause exacte de la perte de `PLAYER_FRONT_BOOT`:
  - `player_canvas.php` charge bien `logger.global.js` avant `play-ws.js`;
  - `logger.global.js` émettait `PLAYER_FRONT_BOOT` dès l’accroche du Bus;
  - mais `play-ws.js` ne bootait `ws_connector.js` qu’au `player/ready`, donc le listener `game:ws:send` pouvait encore être absent quand la preuve partait;
  - résultat: le `log_event` de boot pouvait être perdu avant tout attachement réel du transport.
- correctif front minimal livré:
  - `PLAYER_FRONT_BOOT` est maintenant gardé pending puis rejoué exactement une fois au premier `ws/open` si le transport n’était pas prêt;
  - les preuves `PLAYER_FRONT_LOG_FLUSH_TRY|OK|FAIL` restent en envoi direct WS et couvrent maintenant aussi le rôle `remote`.
  - les marqueurs techniques de diagnostic front/reprise sont reclassés en `debug`; seuls les échecs restent en `warn`/`error`.
- audit Bingo confirmé:
  - ingestion `log_event/log_batch` déjà présente;
  - mais aucune route HTTP `/force_flush`, donc pas de flush distant équivalent à blindtest/quiz depuis le viewer/proxy actuel.
- correctif Bingo/viewer minimal livré:
  - `bingo.game/ws/server.js` expose maintenant `GET|POST /force_flush?sid=<sid>`;
  - `bingo.game/ws/bingo_server.js` broadcast la frame `force_flush` aux sockets organizer/remote/player de la session;
  - `games/web/includes/canvas/php/logs_proxy.php` relaie `action=force_flush` vers quiz/blindtest/bingo;
  - `games/web/logs_session.html` garde le trigger local `LOG_FLUSH_REQUEST` et appelle aussi le proxy distant.

### Fichiers modifies
- `games/web/includes/canvas/core/logger.global.js`
- `games/web/includes/canvas/php/logs_proxy.php`
- `games/web/logs_session.html`
- `bingo.game/ws/bingo_server.js`
- `bingo.game/ws/server.js`
- `bingo.game/version.txt`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/bingo.game/TASKS.md`
- `documentation/canon/repos/bingo.game/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/bingo.game/TASKS.md`
- `documentation/canon/repos/bingo.game/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- valider en recette réelle:
  - blindtest player mobile/distinct: `PLAYER_FRONT_BOOT` unique, puis `PLAYER_FRONT_LOG_FLUSH_TRY` -> `OK|FAIL` après `force_flush`;
  - bingo player mobile/distinct: même preuve via `/force_flush`;
  - remote distante: `PLAYER_FRONT_LOG_FLUSH_TRY` -> `OK|FAIL` avec `role:"remote"`;
  - absence de double `PLAYER_FRONT_BOOT` sur un boot nominal.
- déployer ensuite les assets front/serveur concernés sur l’environnement cible avant de reprendre le debug reconnect/mobile.

## Games — reprise player mobile après arrière-plan: re-baseline stratégie unique — 2026-03-20

### Resume
- audit code-first confirme qu'un rollback d'urgence était partiel:
  - `play-ws.js` n'exposait plus `window.reRegisterPlayer`;
  - `ws_connector.js` gardait encore une fermeture forcée d'une socket `CONNECTING` au retour visible (`focus_force_close_connecting`);
  - `register.js` conservait déjà l'identité locale sur probe miss transitoire, mais sans log métier V1 explicite.
- correctif livre:
  - suppression de la fermeture forcée sur `CONNECTING` dans `ws_connector.js`;
  - stratégie unique de reprise:
    - transport = connector,
    - reprise applicative = `window.reRegisterPlayer(reason)` seulement après socket `OPEN`,
    - retour foreground avec WS non prête = délégation au connector, sans machine parallèle;
  - listeners lifecycle player réintroduits dans `play-ws.js` avec garde-fous `readyState` et anti-concurrence;
  - logs V1 ajoutés pour tracer la décision exacte (`PLAYER_WS_LIFECYCLE_DECISION`, `WS_CONNECTOR_LIFECYCLE_DECISION`) et la conservation explicite d'identité locale (`REGISTER_KEEP_LOCAL_IDENTITY_DESPITE_PROBE_MISS`).

### Fichiers modifies
- `games/web/includes/canvas/core/ws_connector.js`
- `games/web/includes/canvas/play/play-ws.js`
- `games/web/includes/canvas/play/register.js`
- `games/web/includes/canvas/core/logger.global.js`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette mobile reelle les 6 parcours cibles sur Bingo / Blindtest / Quiz:
  - retour court arriere-plan;
  - retour long arriere-plan;
  - foreground pendant `CONNECTING`;
  - foreground avec socket deja `OPEN`;
  - probe temporairement negatif;
  - absence de boucle WS et conservation du meme `player_id`.

## TdR home reseau — bloc droit hero recentre en vue rapide reseau — 2026-03-19

### Resume
- retouche cible uniquement sur le panneau droit de la home TdR, sans refonte du hero gauche ni des trois cartes reseau de la 2e ligne;
- correctif livre:
  - le bloc droit adopte un titre conditionnel `Par où commencer ?` / `Vue rapide du réseau`;
  - la donnee `Affiliés` passe en premier avec le total mis en avant et une pill secondaire `X actifs · Y inactifs`;
  - `Design réseau` et `Jeux réseau` reprennent le meme style de label que `Affiliés`, avec pills `À faire` / `Prêt`;
  - les sessions reseau a venir restent visibles dans un footer compact, meme quand le compteur vaut `0`, mais le lien agenda est coupe sans session programmee;
  - la carte `Agenda du réseau` aligne maintenant son titre sur la meme hierarchie que les autres cartes reseau;
  - le nom des affiliés affiche dans cette carte reutilise le violet d'accent de la page au lieu du rose historique;
  - les lignes restent discretement cliquables vers `Mes affiliés`, `Design réseau`, `Jeux du réseau` et `Agenda réseau`, sans reintroduire de gros CTA.

### Fichiers modifies
- `pro/web/ec/modules/communication/home/ec_home_index.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette visuelle desktop/mobile la compaction verticale du bloc droit, le basculement `Par où commencer ?` sur un compte vide, et le rendu discret des liens/chevrons.

## TdR home reseau — carte synthese `1/3` et recaps retires des cartes ligne 2 — 2026-03-19

### Resume
- nouvel ajustement de hierarchie sur la home TdR pour concentrer les indicateurs reseau dans un seul bloc court;
- correctif livre:
  - la 1re ligne redevient un duo `2/3 - 1/3` avec hero a gauche et carte synthese reseau a droite;
  - cette carte synthese affiche le volume d'affilies, la repartition `Actifs / Inactifs`, les sessions reseau a venir si presentes, le statut design reseau et le volume de jeux partages;
  - les cartes `Mes affiliés`, `Design réseau` et `Jeux du réseau` gardent leur traitement visuel mais ne repetent plus leurs recaps metier en bas de carte.

### Fichiers modifies
- `pro/web/ec/modules/communication/home/ec_home_index.php`
- `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette visuelle desktop/mobile la hierarchie du duo hero + synthese, le wording conditionnel des compteurs, et l'absence de recaps residuels dans les cartes de la 2e ligne.

## TdR home reseau — mini-carte hero ancree a droite et cartes reseau harmonisees — 2026-03-19

### Resume
- ajustement UI cible sur la home TdR sans changer les routes ni les donnees reseau;
- correctif livre:
  - la mini-carte du lien d'affiliation dans le hero est maintenue alignee a droite sur desktop;
  - les cartes `Mes affiliés` et `Jeux du réseau` reprennent le meme pattern visuel que `Design réseau`, avec grand visuel en tete, titre editorial, micro-copy et footer CTA identique;
  - les visuels statiques utilises sont `santeuil-cafe-nantes.jpg` pour `Mes affiliés` et `jeu-qr-code-smartphone.jpg` pour `Jeux du réseau`;
  - les visuels des trois cartes reseau de la 2e ligne sont rendus plus compacts, avec images centrees dans leur cadrage;
  - un filtre colore leger, dans l'esprit du hero, est ajoute sur ces visuels;
  - la carte `Design réseau` conserve son fallback `cotton-reseau-marque-blanche.jpg` puis le visuel branding reseau utilisateur si disponible.

### Fichiers modifies
- `pro/web/ec/modules/communication/home/ec_home_index.php`
- `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette visuelle desktop/mobile l'ancrage a droite de la mini-carte hero, l'homogeneite des trois cartes reseau avec leurs visuels statiques, la nouvelle hauteur reduite des medias, et l'intensite du filtre colore.

## TdR home reseau — carte `Design du réseau` sans liseré image et CTA harmonise — 2026-03-19

### Resume
- ajustement cible sur le widget home `Design du réseau` apres la refonte hero/shortcuts;
- correctif livre:
  - suppression du liseré blanc perceptible autour du visuel haut de la carte;
  - conservation du grand visuel avec fallback `cotton-reseau-marque-blanche.jpg` puis surcharge par le visuel branding reseau utilisateur quand il existe;
  - remplacement du bouton plein `Modifier` par le meme pattern de CTA footer lien+fleche `Personnaliser` que `Mes affiliés` et `Jeux du réseau`.

### Fichiers modifies
- `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette visuelle desktop/mobile que le media haut de `Design du réseau` est bien flush sans liseré et que le footer CTA reste identique aux autres cartes reseau.

## TdR home reseau — hero seul sur sa ligne et grille raccourcis reordonnee — 2026-03-19

### Resume
- nouvel arbitrage de composition sur la home TdR, sans changer la logique d'affiliation du hero;
- correctif livre:
  - suppression de la puce haute `Réseau Cotton` dans le hero;
  - conservation de la mini-carte lien d'affiliation a droite dans le bloc hero;
  - hero laisse seul sur sa ligne desktop, avec largeur conservee a `2/3`;
  - la grille sous le hero repasse ensuite dans l'ordre `Mes affiliés`, `Design réseau`, `Jeux du réseau`.

### Fichiers modifies
- `pro/web/ec/modules/communication/home/ec_home_index.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette visuelle desktop que le hero reste bien sur une emprise `2/3` seul sur sa ligne, sans badge haut, et que l'ordre des trois cartes reseau sous-jacentes est bien `Mes affiliés`, `Design réseau`, `Jeux du réseau`.

## TdR `Mes affiliés` — micro-synthese support reseau retablie — 2026-03-19

### Resume
- audit cible confirme que la page `/extranet/account/network` preparait toujours deja les donnees canoniques du support reseau actif (`id_offre_client_support`, `contract_state`, `quota_max`, `quota_remaining`, `quota_exploitable`) via les helpers globaux existants;
- une trace historique de rendu a ete retrouvee dans `pro` au commit `696841d`, avec la ligne `Abonnement reseau` + `Places restantes`, mais cette synthese n'etait plus affichee dans la version simplifiee actuelle;
- correctif livre:
  - reintroduction d'une seule ligne compacte sous la phrase d'aide de `Mes affiliés`;
  - affichage conditionnel uniquement si le support `Abonnement reseau` est actif, exploitable et avec quota fiable;
  - reutilisation stricte des valeurs canoniques `quota_remaining/quota_max` de `app_ecommerce_reseau_contrat_couverture_get_detail(...)`;
  - ajout d'un lien discret `Voir dans Offres` vers `/extranet/account/offers`.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette TdR qu'un support actif avec quota epuise affiche bien `0/Y`, et qu'aucune ligne n'apparait si le support est inactif ou sans quota exploitable.

## Audit final BO — cloture support `Abonnement reseau` et nettoyage lectures PRO/TdR — 2026-03-19

### Resume
- audit cible confirme que le write path BO `offres_clients -> modifier -> id_etat=4` passait bien par `app_ecommerce_reseau_support_offer_force_close_from_bo()`;
- le helper ne cloturait toutefois que les incluses encore presentes comme activations `cadre` actives, pas toutes les lignes encore liees au support par `reseau_id_offre_client_support_source`;
- ces reliquats pouvaient laisser une delegation `cadre` active cote SI, maintenir des incoherences de statut/CTA dans `Mes affiliés`, et faire remonter des lignes `cadre` dans l'historique `Offres` TdR.
- correctif livre:
  - fermeture BO elargie aux incluses actives encore liees au support par leur champ source;
  - resynchronisation pipeline affilié apres fermeture effective;
  - reconstruction de l'historique `Offres` TdR sur le meme perimetre que la liste active: base support/offres propres, puis seule reinjection explicite des lignes deleguees `hors_cadre`;
  - harmonisation du rendu d'un support reseau `Terminee`: la carte affiche maintenant `Abonnement termine depuis le ...` et ne garde plus la mention `Affiliés actuellement inclus`;
  - harmonisation du rendu S3 des abonnements en propre avec essai gratuit: le calcul de rendu et la lecture du snapshot Stripe `trialing` ne sont plus limites au contexte compte et la confirmation affiche maintenant `Essai gratuit, aucun prélèvement avant le ...`;
  - suppression du CTA PRO vide quand aucune offre TdR visible n'existe.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `pro/web/ec/modules/compte/offres/ec_offres_view.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette qu'une incluse `cadre` terminee ne remonte plus dans l'historique `Offres` TdR quand `app_ecommerce_offre_client_get_detail()` ne porte pas `reseau_id_offre_client_support_source`, la selection historique reposant maintenant sur une source deleguee explicite au lieu d'un fallback tardif.

## BO support reseau — rendre `date_fin` editable depuis la fiche offre — 2026-03-19

### Resume
- le formulaire BO custom de l'`Abonnement reseau` masquait `date_fin` dans un champ cache, ce qui empechait d'ajuster ou de backdater proprement la fin locale depuis l'interface BO;
- la vue BO du support n'affichait pas non plus cette valeur, alors que la colonne `Fin` est determinante pour les tests de bascule cron;
- correctif livre:
  - ajout d'un champ `Fin` editable dans le formulaire custom BO;
  - affichage de `Fin` dans la vue BO du support.

### Fichiers modifies
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette BO qu'une date de fin saisie manuellement sur l'`Abonnement reseau` persiste bien a l'enregistrement en statut `Active` et reste visible en vue.

## BO support reseau — exposer `Offert` et aligner le rendu front — 2026-03-19

### Resume
- le formulaire BO custom de l'`Abonnement reseau` masquait `flag_offert`, et le create support BO l'ecrasait encore a `0`;
- cote front, le detail d'offre excluait explicitement l'`Abonnement reseau` de la mention `OFFERT !`, meme si `flag_offert = 1`;
- correctif livre:
  - ajout de la case `Offert` dans le formulaire BO custom support reseau;
  - affichage de l'etat `Offert` dans la vue BO;
  - respect de la valeur `flag_offert` postee a la creation BO;
  - affichage front `OFFERT !` pour le support reseau quand `flag_offert = 1`;
  - simplification du markup BO du controle `Offert` pour supprimer le decalage a gauche et rendre la case franchement cliquable;
  - suppression du champ cache concurrent `flag_offert` dans le form, avec reapplication defensive de `date_fin` / `flag_offert` apres le sync support BO pour eviter une perte au save.

### Fichiers modifies
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette qu'un `Abonnement reseau` marque `Offert` affiche bien `OFFERT !` sur la page `Offres & factures` TdR dans les etats attendus.

## BO support reseau — `date_fin`/`Offert` perdaient leur valeur au save — 2026-03-19

### Resume
- audit cible confirme que le formulaire BO support postait bien `date_fin` et `flag_offert`, mais que le recalcul immediat via `app_ecommerce_reseau_abonnement_bo_sync_offer_client()` ne republiat ensuite ni l'un ni l'autre;
- consequence: une date de fin backdatee pour tester le cron pouvait disparaitre apres save, et le statut `Offert` pouvait sembler incoherent entre la vue et la modification;
- correctif livre:
  - le script BO normalise maintenant `date_fin`/`flag_offert` avant `module_modifier`;
  - le helper de sync support re-ecrit maintenant aussi `date_fin` et `flag_offert`.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette qu'une `date_fin` backdatee sur un support encore `Active` reste bien persistante apres save et rend l'offre eligible au cron local des que `CURDATE()` la depasse.

## Cron support reseau — la fin effective laissait encore des incluses `cadre` actives — 2026-03-19

### Resume
- audit cible confirme que le cron `ABN SANS engagement` passait bien le support reseau en `Terminee`, puis appelait `app_ecommerce_reseau_support_offer_transition_finalize()`;
- contrairement au write path BO manuel, cette transition finale n'eteignait toutefois pas encore les delegations incluses `cadre` liees au support courant;
- consequence: un test de fin effective par cron pouvait laisser des incluses `cadre` actives alors que le support etait deja termine;
- correctif livre:
  - la transition finale support ferme maintenant aussi les incluses `cadre` encore actives et liees au support courant;
  - la fermeture preserve une `date_fin` deja planifiee si elle existe;
  - chaque affilié impacte est resynchronise apres fermeture effective.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette qu'une fin effective support par cron clot bien les seules incluses `cadre` liees, sans toucher aux delegations `hors_cadre`.

## BO support reseau — activation forcee devait garder une fin planifiee — 2026-03-19

### Resume
- audit cible confirme que le premier save BO `En attente -> Active` declenchait une reactivation support qui revidait `date_fin`;
- ce comportement etait coherent pour une reactivation technique standard, mais bloquait le besoin BO de forcer un support actif sans paiement avec une fin locale deja planifiee;
- correctif livre:
  - apres la reactivation support depuis le BO, le script reapplique explicitement `id_etat = 3`, `date_fin` et `flag_offert`;
  - le premier save `Active` peut donc maintenant conserver la fin planifiee voulue.

### Fichiers modifies
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette qu'un support force en `Active` avec `date_fin` passee devient bien eligible au cron local sans second save.

## BO support reseau — la creation forcait encore `En attente` — 2026-03-19

### Resume
- audit cible confirme qu'en mode `ajouter`, le write path support forcait encore `id_etat = 2`, puis reappliquait `En attente` apres insertion;
- consequence: meme avec un choix BO `Active`, la fiche affichait ensuite `pending_payment`;
- correctif livre:
  - la creation support respecte maintenant `Active` quand cet etat est choisi explicitement;
  - apres insertion, le flux active le support puis reapplique `id_etat = 3`, `date_fin` et `flag_offert`.

### Fichiers modifies
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette qu'une creation BO support en `Active` reste bien `Active` des le premier save, avec `date_fin` et `flag_offert` conserves.

## Front support reseau — un support offert affiche maintenant `Offert` — 2026-03-19

### Resume
- le rendu front de la carte `Abonnement reseau` affichait encore `Montant négocié : 0,00 € HT / mois` meme quand le support etait marque `Offert`;
- correctif livre:
  - pour le seul support reseau avec `flag_offert = 1`, la ligne de montant reutilise le libelle source `OFFERT !` a cet emplacement;
  - les autres cas gardent l'affichage de montant existant.

### Fichiers modifies
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette qu'un support reseau offert affiche bien `Offert` dans `Offres & factures`, sans impacter les autres lignes de montant.

## Stripe support reseau — `customer.subscription.updated` ecrivait plus `date_fin` — 2026-03-19

### Resume
- audit cible confirme que la fin de periode Stripe du support devait ecrire `date_fin = current_period_end` sur l'offre locale retrouvee par `asset_stripe_productId`;
- mais `pro/web/ec/ec_webhook_stripe_handler.php` contenait deux traitements du meme evenement `customer.subscription.updated`:
  - le premier ne faisait que la sync delegation reseau puis `break`;
  - le second, plus bas, portait la logique support mais etait unreachable;
- consequence: une resiliation Stripe support a fin de periode restait visible cote Stripe, mais la colonne `Fin` locale pouvait rester vide.
- correctif livre:
  - le premier traitement prend maintenant aussi en charge le support reseau;
  - il ecrit `date_fin`, relance `app_ecommerce_reseau_facturation_refresh_from_stripe_product_id(...)` et planifie la fin de periode des incluses;
  - le doublon mort du webhook est retire pour ne garder qu'un seul chemin deterministe.

### Fichiers modifies
- `pro/web/ec/ec_webhook_stripe_handler.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette qu'une resiliation Stripe fin de periode du support renseigne bien `date_fin` locale des reception du webhook, avant tout passage cron.

## Alignement DB reseau develop/prod — retrait de `ecommerce_reseau_delegated_replacements` — 2026-03-23

### Resume
- verification finale du code livre:
  - les write paths de remplacement d'offre déléguée sont neutralisés en V1 (`replacement_disabled_v1`);
  - le cron BO sait encore lire la table legacy, mais ne la rejoue plus et ne fait que la marquer en erreur legacy neutralisée;
- decision retenue pour aligner `develop` et `prod`:
  - retirer `ecommerce_reseau_delegated_replacements` du script phpMyAdmin de reference;
  - supprimer explicitement cette table legacy si elle existe déjà;
  - ajouter un SQL one-shot d'alignement pour les bases `develop` déjà dérivées de l'ancien script.

### Fichiers modifies
- `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- `www/web/bo/www/modules/ecommerce/reseau_contrats/2026-03-23_align_dev_prod_remove_delegated_replacements.sql`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/www/README.md`

### TODO
- appliquer en `develop` le SQL `www/web/bo/www/modules/ecommerce/reseau_contrats/2026-03-23_align_dev_prod_remove_delegated_replacements.sql`;
- verifier ensuite que `SHOW TABLES LIKE 'ecommerce_reseau_delegated_replacements';` ne remonte plus de ligne en `develop` comme en `prod`.

## Audit final BO — suppression du reclassement implicite en lecture `reseau_contrats` — 2026-03-19

### Resume
- audit cible confirme que `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` appelait encore `app_ecommerce_reseau_contrat_reclassify_delegations()` a l'ouverture;
- cette simple lecture pouvait ecrire via les helpers globaux dans les activations reseau, certaines offres clients, le pipeline siege et les logs;
- aucune preuve documentaire ouverte ne justifie ce side effect BO en lecture, alors qu'un bouton `sync_legacy` explicite existe deja pour les raccords volontaires.
- correctif livre:
  - suppression de l'appel automatique au chargement de la page BO;
  - conservation des seuls write paths BO explicites existants.

### Fichiers modifies
- `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette si des TdR tres anciennes dependent encore du bouton `sync_legacy` pour remonter des activations historiques absentes, maintenant que la page n'auto-corrige plus cet etat a l'ouverture.

## Audit reseau V1 — fermeture du remplacement delegue `hors_cadre` — 2026-03-19

### Resume
- audit cible confirme:
  - l'UI PRO principale n'exposait plus `Changer d'offre` pour une delegation `hors_cadre`;
  - en revanche, le backend gardait encore la route directe `start_replace_delegated_hors_cadre_checkout` et toute la mecanique legacy de remplacement immediat / differe;
  - ce reliquat contredisait la baseline V1 deja documentee (`hors_cadre` active = gestion/résiliation explicite uniquement).
- correctif livre:
  - blocage serveur du point d'entree PRO de remplacement avec message `replacement_disabled_v1`;
  - neutralisation dans `global` des helpers de remplacement immediat, differe et de l'execution cron associee;
  - retrait des marqueurs/messages UI de remplacement encore visibles dans `Offres` / `Mes affiliés`.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/client/ec_client_network_script.php`
- `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### TODO
- si des lignes historiques `ecommerce_reseau_delegated_replacements` existent encore en base, verifier en recette qu'elles apparaissent bien comme erreurs legacy neutralisees et non comme actions rejouables.

## Documentation reseau — realignement V1 final offres support / deleguees — 2026-03-19

### Resume
- besoin metier: supprimer des docs de reference les restes de verite intermediaire devenus faux ou ambigus sur les offres reseau / deleguees;
- reference V1 figee:
  - support `Abonnement reseau` visible en `Active` / `En attente` / `Terminee`;
  - aucune auto-creation de support, aucune recreation automatique d'un support `En attente`;
  - un support `Active` autorise seulement les activations incluses `cadre` explicites d'affilies inactifs, dans le quota;
  - une delegation `hors_cadre` active reste `hors_cadre`, ne se remplace plus en V1 et peut seulement etre resiliee;
  - la fin BO ou Stripe du support n'a aucun impact automatique sur les offres deleguees `hors_cadre`;
  - les libelles affilies a conserver restent `Actif via le reseau` sans support actif et `Actif en supplement` avec support actif.
- realignement documentaire livre:
  - `canon/repos/pro/README.md` porte maintenant la reference finale et relègue explicitement comme historiques abandonnes les parcours `Changer d'offre`, upsell/downsell, `network_affiliate_manage` et l'absorption/recreation `hors_cadre -> cadre`;
  - `canon/repos/pro/TASKS.md` et `canon/repos/global/TASKS.md` figent les invariants V1 pour les audits futurs de `app_ecommerce_functions.php`;
  - `notes/plan_migration_reseau_branding_contenu.md` conserve l'historique utile mais marque explicitement les hypotheses non retenues en V1 finale;
  - les anciennes entrees `HANDOFF.md` sur ces hypotheses doivent desormais etre lues comme historique depasse, pas comme verite finale;
  - en particulier, les entrees 2026-03-13 sur `Changer d'offre`, `downsell`, `remplacement canonique` et `network_affiliate_manage` sont maintenant a lire comme archives de trajectoire, pas comme etat actif.

### Fichiers modifies
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`

### Docs touchees
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`

### TODO
- si un futur audit relit des entrees HANDOFF/CHANGELOG du 2026-03-13 autour des remplacements delegues, les traiter comme historique abandonne et non comme reference produit.

## TdR PRO — harmonisation UI finale home / affiliés / design / jeux réseau — 2026-03-18

### Resume
- besoin metier: finaliser la couche UI TdR avec la nouvelle charte jaune/noir, le wording `Mes affiliés`, et un hub `Jeux réseau` cohérent selon qu'il existe deja ou non des contenus partagés;
- audit confirme:
  - la home TdR gardait des titres de widgets sans header jaune dédié;
  - la home TdR n'exposait pas encore de texte d'introduction usage-reseau ni de lien d'affiliation directement copiable au-dessus des widgets;
  - `/account/network` affichait encore `Mon réseau` et plusieurs CTA violets;
  - les pages `Design réseau` utilisaient encore leurs CTA pleins historiques;
  - `Jeux réseau` gardait des liens retour `Mon réseau` et ne proposait pas de vrai empty-state catalogue.
- correctif livre:
  - la home TdR affiche maintenant un texte d'introduction au-dessus des widgets, avec les consignes d'usage réseau attendues;
  - le lien d'affiliation y est affiché inline, hors carte, avec une action icône `copier`;
  - la navigation réseau expose maintenant `Affiliés`, `Agenda réseau`, `Design réseau` et `Jeux réseau`;
  - la home TdR expose les widgets `Mes affiliés`, `Design du réseau`, `Jeux du réseau` et `Agenda de mon réseau`;
  - ces widgets home utilisent maintenant un header transparent avec seule la ligne icône + titre surlignée en jaune `#FFDB03`;
  - `/account/network` devient une page de pilotage affiliés recentrée, avec titre `Mes affiliés`, lien d'affiliation en haut puis tableau simplifié `Affilié / Statut / Infos / Action`;
  - les blocs `Personnalisation`, jeux réseau et le détail des offres affiliées sont retirés de cette page;
  - la colonne `Infos` remonte la métrique existante `sessions programmées`;
  - la colonne `Action` garde `Activer` / `Désactiver` / `Commander` quand applicable, sinon renvoie vers `Offres` filtré sur l'affilié;
  - les headers jaunes sont retirés de la page `Affiliés`, les titres reviennent sur le style sobre du shell;
  - l'accès `Design réseau` injecte `nav_ctx=network_design` pour fiabiliser le surlignage du menu dédié;
  - `Jeux réseau` retire les liens retour `Mon réseau`;
  - si aucun jeu n'est partagé, le hub affiche directement les 3 blocs Blind Test / Bingo Musical / Cotton Quiz vers les catalogues standards;
  - si au moins un jeu est partagé, le hub garde `Ajouter des jeux` et masque ces 3 blocs.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `pro/web/ec/modules/communication/home/ec_home_index.php`
- `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
- `pro/web/ec/modules/widget/ec_widget_client_reseau_resume.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `pro/web/ec/modules/compte/NA_client_branding/ec_client_branding_view.php`
- `pro/web/ec/modules/compte/NA_client_branding/ec_client_branding_form.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_reseau_resume.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/NA_client_branding/ec_client_branding_view.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/NA_client_branding/ec_client_branding_form.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## TdR PRO — fin BO abonnement réseau sans clôture parasite des hors cadre — 2026-03-18

### Resume
- besoin metier: éviter qu'un passage BO manuel d'un abonnement réseau en `Terminée` ferme aussi les offres déléguées `hors_cadre`, qui ne dépendent pas du support réseau;
- audit confirme:
  - le write path manuel passait bien par `bo_offres_clients_script.php`;
  - `app_ecommerce_reseau_support_offer_force_close_from_bo()` désactivait toutes les activations du contrat puis clôturait toute offre déléguée active, sans filtrer `mode_facturation`;
  - les offres `hors_cadre` pouvaient donc basculer à tort en `Terminée` lors de cette clôture BO.
- correctif livre:
  - le write path BO continue de sortir les affiliés du cadre support en réécrivant leurs activations en `inactive`;
  - seule une délégation `cadre` ferme maintenant son offre déléguée lors de la fin BO de l'abonnement réseau;
  - une délégation `hors_cadre` reste active et n'est plus clôturée par ce flux.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
- `npm run docs:sitemap` OK

## TdR PRO — agenda réseau complet en lecture seule — 2026-03-18

### Resume
- besoin metier: exposer un vrai agenda réseau depuis la home et la nav TdR, tout en restant en lecture seule;
- audit confirme:
  - le widget agenda réseau agrégait déjà les sessions affiliés, mais sans total ni lien dédié;
  - la vue agenda standard pouvait être réutilisée à condition d'en retirer les CTA de programmation en contexte réseau.
- correctif livre:
  - le widget home affiche maintenant `Agenda de mon réseau (N)` puis un lien `Voir l'agenda réseau complet`;
  - la nav TdR expose `Agenda réseau` sous `Mes affiliés`;
  - `extranet/games?network_agenda=1` agrège les sessions officielles des affiliés;
  - le mode réseau retire les CTA `Ajouter`, `Nouvelle session` et `Gérer`, pour rester en lecture seule.
  - les cartes session n'exposent plus non plus de CTA `Ouvrir le jeu` / `Voir les offres` dans ce contexte.
  - les accès ont été corrigés vers `/extranet/start/games?network_agenda=1`, la redirection historique de `/extranet/games` perdant ce contexte.
  - quand le réseau n'a aucune session officielle à venir, le widget masque `(0)` et son CTA, et la nav masque l'entrée `Agenda réseau`.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php` OK

## TdR PRO — home réseau à 3 raccourcis — 2026-03-18

### Resume
- besoin metier: faire de la home TdR une surface d'accès rapide aux 3 parcours réseau désormais structurants;
- audit confirme:
  - la nav TdR listait `Mes affiliés`, `Jeux réseau`, `Design réseau`;
  - la home TdR réutilisait encore l'ancien couple `Mon réseau / Agenda de mon réseau`.
- correctif livre:
  - la home TdR affiche maintenant 3 widgets raccourcis `Mes affiliés`, `Design réseau` et `Jeux réseau`;
  - `Mes affiliés` remonte le total puis `Actifs / Inactifs`;
  - `Design réseau` remonte un statut simple de partage branding;
  - `Jeux réseau` remonte le nombre de jeux actuellement partagés;
  - l'agenda réseau historique reste affiché sous ces 3 raccourcis;
  - la nav TdR inverse aussi `Design réseau` et `Jeux réseau` pour reprendre cet ordre.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `pro/web/ec/modules/communication/home/ec_home_index.php`
- `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK

## TdR PRO — `Offres & factures` et offres portees unitarisees — 2026-03-18

### Resume
- besoin metier: faire evoluer `Mon offre` pour une tete de reseau vers une vue compte plus orientee reseau, avec listage unitaire des offres portees;
- audit confirme:
  - le libelle nav est centralise dans `pro/web/ec/ec.php`;
  - les tabs compte sont centralises dans `pro/web/ec/includes/menus/ec_menus_compte.php`;
  - la page `pro/web/ec/modules/compte/offres/ec_offres_view.php` et son include list excluaient encore les offres deleguees payees par la TdR et affichaient un bloc agrégé.
- correctif livre:
  - `Mon offre` devient `Offres & factures` pour une TdR dans la nav;
  - les tabs compte affichent `Offres / Factures / Equipe` pour une TdR;
  - l'onglet `Offres` remonte maintenant l'abonnement reseau puis les seules offres deleguees `hors cadre` portees par le reseau, sans les agréger;
  - l'onglet `Factures` propose aussi un filtre simple par affilie pour isoler les factures deleguees;
  - les delegations `cadre` incluses dans l'abonnement reseau ne figurent plus comme offres propres;
  - chaque offre deleguee mentionne explicitement l'affilie concerne;
  - un filtre simple par affilie apparait en haut de page quand plusieurs affilies `hors cadre` sont concernes;
  - les offres deleguees `hors cadre` gardent un CTA `Gerer l'offre` via l'endpoint differe deja utilise dans `Mes affilies`;
  - la page evite maintenant de preparer des sessions portail Stripe pour chaque offre deleguee au rendu.
  - le libelle redondant `Affilie concerne` est retire sur ce rendu, la ligne `Delegation de l'offre a ...` portant deja la bonne cible;
  - l'abonnement reseau support et les offres deleguees actives affichent maintenant `Periode en cours : du ... au ...`;
  - une offre deleguee active avec fin deja actee ajoute `Cet abonnement delegue se termine le ...`;
  - une offre deleguee terminee affiche `Abonnement termine depuis le ...`;
  - l'historique TdR n'est plus affiche par defaut et s'ouvre explicitement avec pagination simple.
  - ce meme historique n'effectue plus de comptage complet au chargement et ne charge maintenant que la page courante avec detection `page suivante`.
  - les branches generiques de periode sont exclues pour les offres deleguees, ce qui supprime le doublon `Periode en cours` + `Abonnement du`.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `pro/web/ec/includes/menus/ec_menus_compte.php`
- `pro/web/ec/modules/compte/offres/ec_offres_view.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_list.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `pro/web/ec/modules/compte/factures/ec_factures_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/includes/menus/ec_menus_compte.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_view.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_list.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_list.php` OK

## TdR PRO — bibliothèque réseau unique pour le partage — 2026-03-18

### Resume
- besoin metier: forcer une tête de réseau à passer uniquement par `library?network_manage=1` pour partager des contenus avec ses affiliés;
- audit confirme:
  - le shell `/pro` expose encore `Les jeux` dans `pro/web/ec/ec.php`;
  - la page `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` expose encore 3 CTA d'ajout en contexte `network_manage=1`;
  - le portail standard affiche encore la carte `Les jeux {nom_TdR}` aussi pour la TdR.
- correctif livre:
  - le menu `Les jeux` est masqué pour une TdR;
  - `Jeux réseau` devient le seul point d'entrée nav visible vers le partage réseau;
  - `library?network_manage=1` remplace les 3 CTA par `Ajouter des jeux` vers `/extranet/games/library`;
  - le bloc `Les jeux {nom_TdR}` est retiré du portail standard pour la TdR et conservé pour les affiliés.
  - sur les fiches détail, une TdR garde `Lancer une démo` et `Partager avec mon réseau` / `Retirer du réseau`; seul le CTA de programmation est supprimé.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## TdR PRO — nav `Jeux réseau` dédiée — 2026-03-18

### Resume
- besoin metier: ajouter un accès direct à la bibliothèque réseau dans la nav TdR, sous `Mes affiliés`;
- audit confirme: le shell lit déjà le contexte `network_manage=1` dans `pro/web/ec/ec.php`;
- correctif livre:
  - ajout de `Jeux réseau` vers `/extranet/games/library?network_manage=1`;
  - séparation de l'état actif entre `Mes affiliés` et `Jeux réseau`.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK

## TdR PRO — nav `Mes affiliés` + entrée `Design réseau` — 2026-03-18

### Resume
- besoin metier: clarifier la navigation TdR en remplaçant `Mon réseau` par `Mes affiliés` et en ajoutant un accès direct au design réseau;
- audit confirme: la navigation est centralisée dans `pro/web/ec/ec.php`;
- correctif livre:
  - `Mon réseau` devient `Mes affiliés`;
  - `Design réseau` est ajouté juste en dessous;
  - l'entrée ouvre directement `/account/branding/view`.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK

## TdR PRO — retrait du menu `Media Kit` — 2026-03-18

### Resume
- besoin metier: supprimer le point d'entree nav `Media Kit` encore visible pour une tête de réseau alors qu'il n'a pas d'intérêt produit dans ce parcours;
- audit confirme: la condition d'affichage du menu est centralisée dans `pro/web/ec/ec.php`;
- correctif livre:
  - le shell `/pro` n'affiche plus `Media Kit` pour une TdR;
  - la logique historique est conservée pour les autres profils.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK

## TdR PRO — retrait du menu `Mon agenda` — 2026-03-18

### Resume
- besoin metier: supprimer le point d'entree nav `Mon agenda` encore visible pour une tête de réseau alors qu'il n'a plus d'intérêt produit et renvoie encore vers des surfaces de programmation;
- audit confirme: la condition d'affichage du menu est centralisée dans `pro/web/ec/ec.php`;
- correctif livre:
  - le shell `/pro` n'affiche plus `Mon agenda` pour une TdR;
  - la logique historique est conservée pour les autres profils.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK

## Mon reseau — hotfix perf portail Stripe au clic — 2026-03-18

### Resume
- besoin metier: enlever le coût Stripe du rendu initial de `/account/network` sans attendre la future extraction complète de la logique de facturation;
- audit confirme:
  - `ec_client_list.php` préparait un portail Stripe pour le support réseau au chargement;
  - le rendu préparait aussi un portail Stripe par affilié `hors cadre` dans la boucle;
  - la lenteur venait donc en partie d'appels Stripe faits avant tout clic utilisateur;
- correctif livre:
  - suppression de la préparation portail Stripe au rendu de `Mon reseau`;
  - `Gérer l’offre` passe maintenant par `network/script?mode=open_affiliate_offer_portal&id_offre_client=...`;
  - la session portail Stripe n'est préparée qu'au clic;
  - les erreurs portail continuent d'être renvoyées vers le flash réseau.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `pro/web/ec/modules/compte/client/ec_client_network_script.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php` OK

## TdR PRO — commande en propre masquee + programmation hors démo bloquee — 2026-03-18

### Resume
- besoin metier: une tête de réseau ne doit plus commander pour elle-meme dans `/pro` ni programmer de sessions hors démo depuis la bibliothèque;
- audit confirme:
  - le CTA nav `Tarifs & commande` et la logique shell sont pilotés dans `pro/web/ec/ec.php`;
  - la home peut deja réutiliser les widgets reseau existants `ec_widget_client_reseau_resume.php` et `ec_widget_client_lieu_sessions_agenda.php`;
  - la fiche détail bibliothèque rendait encore le CTA de programmation hors démo et son POST restait exploitable sans refus serveur spécifique;
- correctif livre:
  - masquage du CTA nav de commande pour une TdR;
  - bascule de la home TdR sur les widgets reseau existants;
  - retrait du CTA de programmation hors démo sur les fiches détail bibliothèque pour une TdR;
  - refus serveur des modes bibliothèque de programmation hors démo pour une TdR;
  - conservation du CTA `Lancer une démo`.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `pro/web/ec/modules/communication/home/ec_home_index.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK

## Mon offre — rebaseline produit pour les offres affiliées hors cadre TdR — 2026-03-17

### Resume
- besoin metier: `Mon offre` devait rester lisible cote TdR tout en reflettant aussi les delegations `hors_cadre` reellement facturees a ce compte, en plus de la carte support `Abonnement reseau`;
- audit confirme:
  - rendu reel dans `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`;
  - carte support branchee sur `app_ecommerce_reseau_facturation_get_detail(...)`;
  - lecture canonique des `hors_cadre` deja disponible via `app_ecommerce_reseau_offres_hors_cadre_pricing_get(...)`, sans nouveau helper ni write path;
- correctif livre:
  - ajout d'un bloc conditionnel `Offres affiliés à la charge de votre réseau`;
  - affichage lecture seule: état `Active`, nb d'offres, montant agrégé HT/TTC, lien `Voir le détail` vers `Mon reseau`;
  - aucune action affilié n'est ajoutée dans `Mon offre`;
  - les CTA Stripe existants de la carte support restent inchangés.

### Fichiers modifies
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK
- `npm run docs:sitemap` OK

## Mon reseau — hiérarchie finale V1 simplifiée — 2026-03-17

### Resume
- besoin metier: finaliser la V1 UX de `/account/network` avec une lecture plus directe, sans rouvrir de logique metier cachee ni de bloc intermediaire inutile;
- audit confirme: la vue unique reste `pro/web/ec/modules/compte/client/ec_client_list.php`, les compteurs/quota viennent toujours des helpers `app_ecommerce_reseau_*` deja lus, et les CTA hauts restent branches sur `branding/view` et `library?network_manage=1`;
- correctif livre:
  - retrait du bloc `Facturation` sur `Mon reseau`;
  - bloc `Lien d'affiliation` remonte en premier avec copie visible et message d'aide dynamique;
  - bloc `Personnalisation` recentre l'entree sur `Design reseau` et `Contenus reseau`;
  - `Mes affiliés` arrive directement ensuite avec synthese compacte au-dessus du tableau;
  - aucune action affilié, aucun endpoint POST et aucune verite metier reseau n'ont ete modifies.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
- `npm run docs:sitemap` OK

## Reseau TdR — hors cadre delegue sans contrat reseau obligatoire — 2026-03-17

### Resume
- besoin metier: depuis la disparition du contrat reseau obligatoire au profit d'une unique offre abonnement reseau facultative, une TdR doit pouvoir commander et remplacer une offre deleguee `hors cadre` meme sans ligne `ecommerce_reseau_contrats`;
- cause confirmee: les flows `Commander` / changement d'offre / rattachement post-paiement continuaient de bloquer sur `network_contract_missing`, puis tentaient encore d'ecrire une activation reseau obligatoire pour des cas purement `hors cadre`;
- correctif livre:
  - le contexte d'action affilié accepte maintenant l'absence de contrat quand le flux est explicitement `hors cadre`;
  - le checkout delegue `hors cadre` et le changement d'offre delegue peuvent donc demarrer avec `id_contrat_reseau = 0`;
  - l'attachement post-paiement, le remplacement immediat, le remplacement differe et l'activation explicite `hors cadre` n'essaient plus d'ecrire dans `ecommerce_reseau_contrats_affilies` quand aucun contrat n'existe;
  - les flux `cadre` / `included` gardent en revanche leur exigence de support reseau actif et de contrat resolu.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php` OK
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## Contenus reseau V1 — durcissement logique + doc canonique réalignée — 2026-03-17

### Resume
- besoin metier: finaliser le socle V1 sans refonte produit, en verrouillant permissions, idempotence pratique, unicité métier et robustesse de lecture quand une source n'est plus exploitable;
- cote serveur, `Partager avec mon réseau` / `Retirer du réseau` refusent maintenant explicitement toute tentative hors TdR proprietaire, y compris via POST manuel;
- le partage d'une source devenue inactive, supprimée ou non exploitable est refuse;
- les lectures reseau, compteurs et chips ignorent maintenant les partages dont la source n'est plus exploitable, ce qui évite les remontees cassées cote TdR et affilié;
- decision de lot retenue: on garde le lazy-init `ecommerce_reseau_content_shares` pour cette iteration, avec assurance de schema existante et unicité métier toujours portée par `ux_reseau_content_share (id_client_siege, game, content_type, source_id)`;
- état canonique retenu pour la navigation:
  - TdR: `/account/network` puis `Jeux du réseau` vers `library?network_manage=1`
  - affilié: carte portail bibliothèque `Jeux du réseau` en lecture seule
  - aucun onglet réseau par catalogue n'est retenu comme état final.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette applicative les 4 cas: partage déjà actif, partage neuf, retrait déjà fait, tentative affilié par POST direct;
- si une industrialisation SQL hors runtime est décidée plus tard, extraire uniquement `ecommerce_reseau_content_shares` dans une migration dédiée.

## Bibliothèque reseau — une playlist partagee sur 2 jeux remonte maintenant 2 fois — 2026-03-17

### Resume
- besoin metier: si une TdR partage la meme playlist sur `Blind Test` et `Bingo Musical`, la vue globale `Jeux du réseau` doit montrer les deux usages au lieu d'en fusionner un seul;
- l'agregation de `library?network_manage=1` est maintenant distincte par jeu partage;
- une playlist partagee sur deux jeux remonte donc en deux cartes, une par jeu.
- les cartes de cette vue globale affichent maintenant aussi les memes informations utiles que les cartes standard de la bibliothèque: difficulte, auteur et historique d'usage du client connecte.
- sur la fiche détail d'un contenu partagé au réseau courant, une mention de recommandation réseau adaptée au contexte apparait aussi juste au-dessus des CTA principaux, avec un lien `Voir les jeux réseau` ; pour une playlist vue côté TdR, le libellé affiché est maintenant `Cette playlist est recommandée à vos affiliés.`

### Fichiers modifies
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette qu'une meme playlist partagee sur `Blind Test` et `Bingo Musical` apparait bien deux fois dans `Jeux du réseau`.

## Bibliothèque reseau TdR — 3 CTA jeu colores pour ajouter du contenu partage — 2026-03-17

### Resume
- besoin metier: depuis `library?network_manage=1`, la TdR doit acceder plus vite au bon catalogue jeu pour partager du contenu reseau;
- le CTA unique `Ajouter des jeux réseau` est remplace par 3 CTA jeu colores;
- chaque CTA ouvre le catalogue cible hors contexte `network_manage=1`, pour laisser la TdR se balader, creer ses contenus et choisir ensuite ce qu'elle partage au réseau.

### Fichiers modifies
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette que chaque CTA ouvre bien le catalogue standard du bon jeu, hors contexte reseau.

## Bibliothèque — carte portail `Jeux du réseau` en layout horizontal — 2026-03-17

### Resume
- besoin metier: le bloc transversal `Jeux du réseau` devait mieux respecter un format horizontal;
- le visuel reseau (ou son fallback) passe maintenant a gauche;
- le texte est affiche a droite, avec alignement responsive.

### Fichiers modifies
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette visuelle le rendu desktop et mobile de la carte horizontale.

## Bibliothèque — carte portail `Jeux du réseau` alignee sur les 3 cartes + visuel branding reseau — 2026-03-17

### Resume
- besoin metier: la carte portail `Jeux du réseau` restait trop large, repetait son titre, et n'exploitait pas encore le visuel reseau deja disponible via le design reseau;
- le doublon de titre est retire;
- la carte est maintenant centree sur une largeur visuelle calée sur l'emprise des 3 cartes jeu du dessus;
- si un visuel de design reseau existe pour la TdR concernee, il est reutilise sur la carte;
- sinon un fallback generique `cotton-media-kit-portail.jpg` est affiche.

### Fichiers modifies
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette visuelle l'usage du visuel reseau quand il existe;
- verifier le fallback generique quand aucun design reseau n'est defini.

## Bibliothèque — carte portail `Jeux du réseau` en pleine largeur + wording final — 2026-03-17

### Resume
- besoin metier: la carte `Jeux du réseau` du portail bibliothèque doit s'affirmer comme un vrai bloc d'entree transversal, au meme niveau visuel que l'ensemble des 3 cartes jeux reunies;
- la carte est maintenant affichee en pleine largeur sous les 3 jeux, avec coins plus arrondis;
- son titre devient `Les jeux {nom_compte_TdR}` aussi bien cote affilié que cote TdR;
- le texte affilié devient `Accède rapidement aux jeux sélectionnés par ton réseau !`;
- le texte TdR devient `Accède directement à la gestion des jeux que tu partages avec ton réseau.`

### Fichiers modifies
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette visuelle le rendu pleine largeur de la carte sous les 3 jeux;
- verifier l'injection du nom de compte cote TdR et cote affilié.

## Bibliothèque — le portail `Jeux du réseau` remplace l'onglet réseau par catalogue — 2026-03-17

### Resume
- besoin metier: l'acces global `Jeux du réseau` depuis le portail bibliothèque est plus naturel que des onglets réseau dans chaque catalogue jeu;
- le bloc d'acces `Jeux du réseau` est maintenant visible aussi pour la TdR depuis le portail bibliothèque, en plus de l'affilié si du contenu existe;
- ce bloc devient une vraie carte cliquable alignée sur les blocs de choix de jeu, sans CTA séparé et avec une largeur bornée a celle des cartes du portail;
- l'onglet `Playlists / Séries du réseau` est retire des catalogues, cote affilié comme cote TdR;
- la chip `Réseau` sur les cartes catalogue est maintenant aussi visible pour l'affilié, pas seulement pour la TdR.

### Fichiers modifies
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette visuelle la carte `Jeux du réseau` sur le portail bibliothèque cote TdR et cote affilié;
- verifier en recette qu'aucun onglet réseau residuel n'apparait encore dans les catalogues jeu.

## Bibliothèque — hub global reseau affilie + onglet reseau aussi cote TdR — 2026-03-17

### Resume
- besoin metier: l'affilié voyait bien les contenus reseau dans chaque catalogue jeu, mais sans acces global tous jeux confondus; inversement, la TdR ne retrouvait ce contenu que via `Mon réseau`, pas depuis les catalogues jeu eux-memes;
- le hub global `library?network_manage=1` est maintenant reutilise aussi pour l'affilié quand au moins un contenu reseau existe;
- depuis l'entree bibliothèque sans jeu, un affilié voit alors un bloc pleine largeur `Jeux du réseau` avec CTA vers ce hub global lecture seule;
- etat intermediaire ensuite supersede le meme jour par la carte portail `Jeux du réseau`; il n'y a plus d'onglet réseau par catalogue dans l'etat retenu;
- une fiche détail ouverte depuis ce hub global reseau revient maintenant correctement vers `library?network_manage=1`, cote TdR comme cote affilié;
- aucun changement de persistance V1 ni aucun write path affilié nouveau n'ont ete ajoutés.

### Fichiers modifies
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette visuelle l'entree affilié `Bibliothèque -> Jeux du réseau` avec et sans contenu reseau;
- verifier en recette que l'onglet reseau TdR par jeu n'introduit aucun write path supplementaire cote affilié.

## Bibliothèque — la chip `Réseau` des cartes TdR est maintenant isolee en bas du visuel — 2026-03-17

### Resume
- besoin metier: la chip `Réseau` restait utile dans les catalogues TdR, mais son placement dans la zone haute du visuel entrait en collision avec les badges existants;
- le rendu carte a ete simplifie: `Réseau` descend maintenant en bas a gauche du visuel, loin de `Populaire` et `En ce moment`;
- la chip reutilise une couleur deja presente dans le repo (`#FFDB03` avec texte `#240445`) pour rester coherente avec l'UI existante sans introduire une nouvelle couleur.

### Fichiers modifies
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette visuelle le rendu sur cartes avec badge `Populaire`, avec badge `En ce moment`, et avec les deux simultanement.

## Bibliothèque — quitter `Les jeux` annule maintenant le builder quiz — 2026-03-17

### Resume
- besoin metier: si un builder quiz reste en memoire puis que l'utilisateur quitte la bibliothèque pour un autre menu, ce contexte ne doit pas survivre en session;
- le builder quiz etait bien stocke cote serveur dans `$_SESSION['library_quiz_builder']`, mais seuls les flows internes de bibliothèque savaient l'annuler;
- `pro/web/ec/ec.php` purge maintenant automatiquement ce builder des qu'on sort du contexte `Les jeux`, y compris via la navigation gauche;
- les parcours `tunnel/start` explicitement ouverts depuis la bibliothèque restent preservés pour ne pas casser les flows internes encore relies au builder.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette manuelle qu'un builder quiz en cours disparait bien apres navigation vers un menu hors `Les jeux`;
- verifier qu'un parcours `programmation` ou `demo` lance depuis la bibliothèque ne perd pas le builder tant qu'il reste dans le tunnel issu de la bibliothèque.

## Contenus reseau V1.1 — arrivée TdR dédiée + état intermediaire avant portail final — 2026-03-17

### Resume
- besoin metier: conserver le socle V1 `contenu reseau`, mais rendre son usage plus naturel sans refonte de persistance;
- cote TdR, le CTA `Contenus réseau` depuis `/account/network` n'ouvre plus un hub par jeu: il arrive sur une vraie page dédiée de management, utile meme si aucun contenu n'est encore partagé;
- tant que la TdR reste sur cette page `network_manage=1`, la navigation gauche garde l'etat actif `Mon réseau` au lieu de basculer sur `Les jeux`;
- cette page explique le role du contenu reseau, indique comment en ajouter, renvoie vers la bibliothèque pour partager ou créer, et liste directement les contenus déjà partagés tous jeux confondus;
- ajustement UX complementaire: le premier bloc d'introduction et ses deux CTA sont supprimes; le header garde maintenant seulement `Retour à Mon réseau`, le titre `Jeux du réseau` et un sous-titre court;
- ajustement UX complementaire 2: le sous-titre reprend maintenant le style de `Mon réseau`, l'etat vide utilise un wording plus pedagogique avec CTA `Ajouter des jeux réseau`, et le CTA du bloc `Personnalisation` est renomme `Jeux du réseau` avec un style plein;
- ajustement UX complementaire 3: la page TdR garde maintenant un unique bloc d'information avec titre dynamique `Aucun jeu partagé / 1 jeu partagé / x jeux partagés avec ton réseau`, texte d'aide métier, CTA `Ajouter des jeux réseau` toujours visible, et un peu plus d'espace avant la liste;
- ajustement detail view: l'action reseau quitte le bloc meta secondaire et rejoint la rangee de CTA principaux, a cote de la programmation et de la demo, avec `Partager avec mon réseau` / `Retirer du réseau`;
- simplification visuelle supplementaire: les tags `Playlist / Série` et `Cotton / Communauté / Mine` sont retires des cartes de cette page, et le bloc explicatif affilié est supprime;
- clarification navigation detail: depuis une fiche ouverte dans le contexte TdR réseau, le lien de retour devient `Retour aux jeux du réseau` et revient directement vers `library?network_manage=1`; le recalcul secondaire de `back_url` dans la fiche détail n'ecrase plus ce comportement.
- clarification quiz builder: si la TdR lance la creation d'un quiz depuis une série partagée réseau, le retour du builder bascule maintenant vers la bibliothèque quiz standard (`game=quiz&builder=1`) afin de retrouver le catalogue complet et composer le quiz sans rester enfermé dans `network_scope=shared`.
- cote affilié, cet etat intermediaire a precede la carte portail `Jeux du réseau`; l'onglet réseau par catalogue n'est plus l'etat retenu;
- aucun write path affilié n'est ajouté, et le socle V1 de partage transverse `ecommerce_reseau_content_shares` est conservé sans changement.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### TODO
- verifier en recette visuelle la navigation `Mon réseau -> Contenus réseau -> fiche bibliothèque -> retour`;
- verifier sur un affilié reel que l'onglet réseau disparait bien quand aucun contenu n'est partagé sur le jeu courant.

## Contenus reseau V1 — point d'entree unique TdR + raccourci bibliotheque affilie — 2026-03-16

### Resume
- besoin metier: livrer l'etape 6 `Contenu reseau` sans creer une nouvelle nature source, en gardant `/account/network` comme point d'entree unique TdR et en reutilisant le modele de contenu bibliotheque existant;
- le CTA `Contenus reseau` du bloc `Personnalisation` sur `Mon reseau` ouvre maintenant une vue bibliotheque dediee `Contenus reseau`, avec hub par jeu puis pilotage simple des contenus deja partages ou partageables;
- cote TdR, la bibliotheque permet desormais de partager ou retirer du reseau une serie/playlist existante, de voir l'etat `Reseau` sur les cartes et de lancer les flows de creation existants depuis ce contexte;
- cote affilie, la bibliotheque ajoute un raccourci non combinable `Series du reseau` / `Playlists du reseau` qui expose uniquement les contenus flagues reseau par la TdR de rattachement;
- l'origine source reste intacte (`Cotton`, `Communaute`, `Mine`) et le partage reseau est porte comme un etat transverse persiste dans `global`, sans modification runtime `games`;
- le socle de persistance V1 repose sur `ecommerce_reseau_content_shares`, creee a la demande par le helper global, avec cle metier `id_client_siege + game + content_type + source_id` et statut `active/inactive`.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### TODO
- valider en recette applicative la V1 sur un cas TdR reel avec au moins un affilie rattache et un contenu `Mine` deja valide;
- si le schema doit etre industrialise hors creation lazy runtime, extraire `ecommerce_reseau_content_shares` vers une migration SQL dediee.

## Design reseau TdR — refonte UX branding PRO + validite reseau — 2026-03-16

### Resume
- besoin metier: transformer la route branding PRO historique en vraie page `Design reseau` pour la TdR, en reprenant les repères UX connus cote games plutot qu'un simple nettoyage du module legacy;
- le socle technique branding PRO est conserve, mais les vues reseau sont refondues autour d'un header dedie, d'un etat clair, d'un formulaire plus metier, d'un apercu inspire de l'attente de session et d'actions explicites;
- la page `/extranet/account/network` affiche maintenant aussi l'etat de ce design reseau (`Actif`, `Actif jusqu'au ...`, `Expire`, `Aucun`);
- une nouvelle regle metier est prise en charge: `valable_jusqu_au` sur `general_branding`, active jusqu'a la fin du jour choisi puis ignoree automatiquement dans la resolution type `3`;
- l'action `Reinitialiser le design reseau` supprime la couche reseau personnalisee et laisse le fallback reprendre sans copie cachee.
- correctif post-recette logs: le POST `/extranet/account/branding/script` utilisait une variable hors contexte (`$app_client_detail`) pour choisir le type de branding; la TdR pouvait donc enregistrer en type `4` client au lieu du type `3` reseau, ce qui expliquait l'absence de resultat sur `/account/branding/view`.
- correctif media complementaire: le logo uploadé depuis cette page ne passe plus par un crop hauteur forcé; le write path conserve maintenant son ratio source, ce qui restaure aussi sa persistance au save.
- correctif upload final aligne games: le save branding reseau normalise maintenant les fichiers branding comme le flux games/ajax (MIME/extension), le core upload accepte `jpg|jpeg|png|webp`, et le helper est revenu a un comportement de remplacement proche du module historique pour ne plus faire reapparaitre un ancien logo au save.
- instrumentation temporaire: des logs `[branding:save]` et `[branding:upload]` ont ete ajoutes sur le save branding reseau pour tracer le fichier recu, sa normalisation, le chemin cible et les fichiers reels avant/apres upload.
- diagnostic final: les logs montrent que le nouveau logo est bien reecrit au save; la correction restante porte donc sur la relecture cachee, desormais contournee par des URLs versionnees (`?v=filemtime`) pour `logo` et `visuel`.
- ajustement UI final view: le header `Design reseau` n'affiche plus de CTA, et le bloc d'etat supprime les mentions techniques redondantes pour ne garder que la chip d'etat, le message utile et les libelles `Personnalisé / Par defaut`.
- ajustement UI final view complementaire: la date limite de validite et les actions principales sont maintenant dans le bloc de parametres; si aucune date n'est definie, la vue affiche simplement `Aucune`.
- ajustement UI final bis: le texte sous l'aperçu decrit maintenant le rendu sur l'interface principale et mobile des jeux, et le bouton destructif passe en `Supprimer ce design` avec un style plein plus lisible.
- ajustement UI CTA final: la `view` garde maintenant deux CTA courts `Modifier` / `Supprimer` sur la meme ligne, et la `form` ne montre plus de bouton de suppression.
- ajustement UI form final: la `form` reseau reprend maintenant les textes corriges de la `view`, retire le bloc `Etat actuel` et les aides textuelles grises, et utilise un picker de police aligne sur games (`liste + Ajouter une police…`).
- ajustement UX police: le mode `Ajouter une police…` affiche maintenant une consigne explicite, des exemples de noms et un lien direct vers Google Fonts.
- ajustement UX police final: la consigne est raccourcie et le bouton `Ouvrir Google Fonts` passe en style plein pour eviter le rendu transparent.
- correctif preview police: la police choisie s'applique maintenant aussi aux titres `Cotton Games` et `Lots a gagner !` dans l'aperçu.
- ajustement structurel form: la `form` reseau est maintenant decoupee en sections `Visuel personnalisé`, `Identité visuelle` et `Réseaux sociaux` (placeholder), dans l'esprit de l'UI games.
- ajustement de layout final: le champ `Police` est maintenant isole sur sa propre ligne entre les couleurs et le logo dans la section `Identité visuelle`.
- ajustement UX media: les champs logo/visuel indiquent maintenant `Laisser vide pour conserver ... actuel` quand un media existe deja.
- ajustement UX validite: le champ `Valable jusqu’au` rappelle maintenant qu'en l'absence de date le design reste actif jusqu'a sa suppression.
- ajustement layout final: en `view` comme en `form`, les CTA sont maintenant places dans un bandeau bas du bloc principal.
- ajustement structurel final view: la `view` reprend maintenant les memes sections que la `form` (`Visuel personnalisé`, `Identité visuelle`, `Réseaux sociaux`) avec un affichage ferme plus coherent.
- ajustement layout final commun: la date de validite reste dans le contenu du bloc `Personnalisation`; le bandeau bas est maintenant reserve aux CTA, centres et plus espaces, en `view` comme en `form`.
- ajustement UX date final: en `form`, `Supprimer la date` sort du bandeau bas et devient une action legere rattachee directement au champ de validite.
- ajustement UI final lecture: la `view` affiche maintenant aussi un mini swatch a cote des hex de `Couleur principale` et `Couleur secondaire`.

### Fichiers modifies
- `global/web/app/modules/general/branding/app_branding_functions.php`
- `global/web/app/modules/general/branding/migrations/2026-03-16_add_valable_jusqu_au_to_general_branding.sql`
- `pro/web/ec/modules/general/branding/ec_branding_script.php`
- `pro/web/ec/modules/general/branding/ec_branding_view.php`
- `pro/web/ec/modules/general/branding/ec_branding_form.php`
- `pro/web/ec/modules/general/branding/ec_branding_preview.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_form.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_preview.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`

## Documentation mirror — rappeler ou definir `DOCS_PUBLIC_PUSH_TOKEN` — 2026-03-16

### Resume
- ajout d'une precision legere dans le runbook de mirroring: le secret `DOCS_PUBLIC_PUSH_TOKEN` doit etre defini cote repo source `documentation`, car le workflow de publication s'execute depuis ce depot prive;
- regeneration du sitemap public pour declencher une nouvelle tentative de mirroring avec le token renouvele.

### Fichiers modifies
- `documentation/canon/runbooks/mirroring.md`
- `documentation/HANDOFF.md`
- `documentation/SITEMAP.md`
- `documentation/SITEMAP.txt`
- `documentation/SITEMAP.ndjson`

### Verification rapide
- `npm run docs:sitemap`

## Mon reseau — confirmer les actions Activer / Desactiver d'un affilié — 2026-03-16

### Resume
- besoin metier: clarifier les deux actions d'inclusion reseau dans `Mon réseau` et demander une confirmation explicite avant execution;
- le CTA `Activer via l'abonnement` devient `Activer`, avec la mention `Intégrer cet affilié à votre abonnement réseau`;
- le CTA `Désactiver` conserve son libelle, avec la mention `Sortir cet affilié de votre abonnement réseau`;
- les deux actions passent maintenant par une modale de confirmation au style Bootstrap deja utilise dans le repo, avec boutons `Confirmer` et `Annuler`.
- correctif de rendu complementaire: les modales sont maintenant portees hors du tableau des affiliés, avec remplissage dynamique des IDs, ce qui restaure l'accessibilite des CTA et un fond blanc visible sur `Annuler`.
- ajustement visuel complementaire: le bouton `Annuler` utilise maintenant `btn-secondary`, plus fiable ici que `btn-outline-secondary` face au theme local des modales.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`

## Factures PDF — corriger l'affichage du symbole euro dans le tableau — 2026-03-16

### Resume
- besoin metier: le symbole euro etait affiche en mojibake (`â‚¬`) dans les colonnes du tableau facture;
- la cause venait d'un caractere UTF-8 injecte dans des vues PDF legacy;
- les cellules du tableau utilisent maintenant `chr(128)`, compatible avec le rendu FPDF/encodage historique de ces fichiers.

### Fichiers modifies
- `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
- `www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`

## Mon reseau — ajouter un lien vers les factures affiliés dans le bloc Facturation — 2026-03-16

### Resume
- besoin metier: comme `Mon offre` ne liste pas les offres deleguees, la page `Mon réseau` doit offrir un acces direct aux factures liees aux offres affiliées hors cadre actives;
- le bloc `Facturation` affiche maintenant un lien `Voir les factures affiliés` sous la ligne du montant agrege;
- ce lien n'apparait que s'il existe au moins une offre deleguee hors cadre active a la charge de la TdR.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`

## Factures PDF — aligner le logo facture sur le nouveau logo EC pro — 2026-03-16

### Resume
- besoin metier: remplacer sur les factures l'ancien logo PDF par le nouveau logo utilise en haut a gauche de l'EC pro;
- les vues PDF PRO et BO pointent maintenant toutes les deux vers `pro/web/ec/images/general/logo/cotton-pro-logo-lg.png`;
- le rendu FPDF utilise maintenant ce logo en `24x24`, adapte a son format carre.
- correctif runtime complementaire: le chemin image doit rester relatif au script PDF; un chemin absolu local `/home/romain/...` cassait le rendu sous `/var/www/...` avec `FPDF error: Can't open image file`.
- correctif runtime final: les vues PDF resolvent maintenant la racine PRO a partir de `$conf['public'][$conf['server']]` avec substitution `/www.` -> `/pro.`, puis chargent `ec/images/general/logo/cotton-pro-logo-lg.png`;
- fallback de securite: si le nouveau logo n'est pas trouve, le rendu retombe sur `cotton-quiz-pdf.jpg` au lieu d'un fatal FPDF.

### Fichiers modifies
- `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
- `www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`

## Facturation reseau — afficher l'affilie sur les factures TdR d'offres deleguees — 2026-03-16

### Resume
- besoin metier: une TdR qui porte plusieurs offres deleguees `hors cadre` au meme tarif ne distingue pas facilement les factures en BO/PRO lorsqu'elles ne diffèrent que par le numero de facture;
- le rendu BO et PRO des listes de factures affiche maintenant aussi le nom de l'affilie quand la commande pointe vers une offre deleguee (`id_client_delegation > 0`), sous la forme `Affilié : <nom>`;
- le meme libelle est maintenant aussi injecte dans le texte de ligne produit lors de la creation de commande, ce qui le fait apparaitre dans le PDF des nouvelles factures deleguees;
- complement ensuite: les vues PDF BO/PRO enrichissent maintenant aussi le rendu a l'affichage a partir de `id_offre_client`, ce qui fait apparaitre `Affilié : <nom>` meme sur une facture deja generee dont la ligne stockee ne contenait pas encore ce texte.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/factures/ec_factures_list.php`
- `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
- `www/web/bo/www/modules/ecommerce/factures/bo_factures_list.php`
- `www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_list.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_list.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`

## Reseau TdR — priorite au support courant pour activer un affilie sans offre active — 2026-03-16

### Resume
- objectif metier confirme: si l'abonnement reseau est actif, que le quota n'est pas atteint et que l'affilie n'a aucune offre active, la TdR doit pouvoir activer l'affilie de son choix quel que soit son historique;
- le diagnostic SQL montrait que des activations `pro_included_activation_cadre` etaient bien creees avec `reseau_id_offre_client_support_source`, puis qu'un passage de sync legacy pouvait rebasculer l'activation vers une delegation `hors_cadre` plus recente dans l'historique;
- la cause etait dans les resolutions d'offres deleguees actives: elles privilegiaient essentiellement la ligne la plus recente, sans prioriser la delegation rattachee au support reseau courant;
- le runtime reseau privilegie maintenant explicitement, pour un affilié donne, la delegation active liee au support courant avant toute autre ligne active legacy;
- ce choix est applique a la resolution canonique, a la sync legacy des activations et au helper qui recherche l'offre deleguee active d'un affilié.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## Reseau TdR — ecriture `cadre` restauree pour les activations incluses — 2026-03-16

### Resume
- le symptome corrige concerne deux chemins: `signup_affiliation` via lien reseau et le CTA `Activer via l'abonnement` depuis `Mon réseau`;
- dans les deux cas, une offre incluse devait etre creee en `cadre` quand le support reseau etait actif et qu'une place restait disponible, mais l'activation etait finalement persistee en `hors_cadre`;
- la cause etait dans `app_ecommerce_reseau_activation_write()`: le calcul `mode_facturation_effective()` se basait sur un detail contrat incomplet, ce qui rabaissait a tort une demande `cadre` vers `hors_cadre`;
- le helper recharge maintenant le contrat runtime complet par `id_client_siege` avant de calculer le mode effectif;
- durcissement complementaire: `app_ecommerce_reseau_activation_mode_facturation_effective()` passe maintenant aussi `id_client_siege` a `app_ecommerce_reseau_contrat_get_state()`, afin de retomber sur l'offre support runtime meme si `id_offre_client_contrat` est stale dans la ligne contrat;
- durcissement complementaire cote lecture: la couverture reseau et la sync legacy reconnaissent maintenant aussi une offre incluse via `reseau_id_offre_client_support_source` quand elle est rattachee au support courant, meme si `mode_facturation` est absent ou stale;
- effet attendu: les activations incluses retrouvent bien une ecriture `mode_facturation='cadre'`, sans dependre d'un auto-reclassement ulterieur.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `npm run docs:sitemap`

## Reseau TdR — simplification transitoire des offres deleguees hors cadre — 2026-03-16

### Resume
- la regle metier est simplifiee: l'activation d'un abonnement reseau ne reclassifie plus automatiquement les offres deleguees actives `hors cadre` vers `cadre`;
- la couverture reseau ne considere maintenant `cadre` que les affiliés explicitement actives dans ce mode; les offres deleguees `hors cadre` actives restent donc facturees a part et ne consomment plus automatiquement une place du quota reseau;
- l'utilisateur doit desormais gerer manuellement la transition: resilier l'offre deleguee `hors cadre`, puis activer ensuite l'affilié via l'abonnement reseau s'il reste une place disponible;
- cote PRO `Mon réseau`, une offre deleguee `hors cadre` ne propose plus qu'un lien direct vers le portail Stripe dedie pour resilier l'offre;
- si la resiliation fin de periode est deja programmee, le CTA disparait et seule la mention `Cet abonnement sera résilié au ...` reste affichee;
- les CTA `Réactiver mon offre` et `Changer d'offre` sont retires pour ces offres tant que le parcours futur via `Stripe subscription_update` n'est pas mis en place.

### Relecture V1 finale
- cette ancienne mention de dette vers `subscription_update` est desormais abandonnee comme trajectoire V1;
- la verite finale a retenir reste: resiliation explicite uniquement pour une delegation `hors_cadre`, puis activation `cadre` distincte si le quota support le permet.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## Stripe portail reseau — hardening technique historique autour de `subscription_update` — 2026-03-16

### Resume
- les logs applicatifs confirmaient encore un blocage Stripe sur la configuration Billing Portal reseau `bpc_...`: `Missing required param: features[subscription_update][products]`;
- la sync reseau ne faisait jusque-la qu'un `enabled=true` sur `features.subscription_update`, sans pousser le catalogue autorise par Stripe pour le deep-link `subscription_update`;
- un helper derive maintenant le produit et les prix recurrents autorises a partir de la souscription reseau cible, puis fusionne ce catalogue avec la configuration Stripe existante au lieu de l'ecraser;
- la sync reseau complete aussi `default_allowed_updates=['price']`, de sorte que le portail reseau soit effectivement exploitable pour la souscription support ciblee.
- second diagnostic ensuite sur logs recharges du 16/03: Stripe rejetait encore un ancien prix de la configuration avec `Only active, per unit licensed prices are supported`;
- la sync reseau filtre maintenant explicitement les prix Billing Portal compatibles (`active + recurring + per_unit + licensed`) et remplace integralement la liste du produit reseau cible pour purger les anciens prix invalides.
- clarification metier ensuite: le CTA portail d'un abonnement reseau sert uniquement a resilier l'abonnement, pas a le modifier;
- le rendu PRO demande donc maintenant `subscription_cancel` tant qu'aucune fin programmee n'existe, et retombe sur le portail reseau standard quand une resiliation est deja planifiee;
- cote global, la sync lourde `subscription_update` n'est plus appelee sur le portail reseau hors besoin explicite de modification, ce qui evite de reintroduire des erreurs Stripe sans valeur metier.
- ajustement UX ensuite pour les offres deleguees hors cadre: les variantes de portail affilié reseau resynchronisent maintenant leur `headline` Stripe vers `Cotton - Abonnement illimité délégué`, afin de ne plus reutiliser le titre reserve au support reseau.

### Relecture V1 finale
- ce lot ne doit plus etre lu comme l'ouverture d'un parcours de modification de plan V1;
- cote support, la verite finale conserve seulement un portail cible sur la souscription support existante;
- cote `hors_cadre`, les variantes `manage` / reactivation / remplacement ne sont pas la reference finale.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `npm run docs:sitemap`

## Reseau dev — quota reseau: ne plus compter les affiliés supprimes du SI dans la couverture active — 2026-03-15

### Resume
- la cause racine restante a ete identifiee metierement: une TdR pouvait garder des places consommees par des affiliés deja supprimes du SI via le BO;
- le calcul de couverture reseau lisait encore `ecommerce_offres_to_clients` sans verifier que `id_client_delegation` existait toujours dans `clients`, ce qui laissait des delegations orphelines saturer `quota_consumed` et bloquer `signup_affiliation` sur `quota_reached`;
- la correction joint maintenant explicitement `clients` dans la resolution des delegations actives et dans la sync legacy des activations reseau;
- effet attendu: un affilié supprime du SI ne consomme plus de place reseau disponible et ne bloque plus la creation d'une nouvelle offre incluse.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `npm run docs:sitemap`

## Reseau dev — signup affilie: `client_affilier()` ne doit plus lancer un reclassement global avant l'activation incluse — 2026-03-15

### Resume
- apres la specialisation `signup_affiliation -> activation explicite included`, il restait encore un point d'entree concurrent: `client_affilier()` relancait immediatement `app_ecommerce_reseau_contrat_reclassify_delegations()` juste apres avoir pose `id_client_reseau`;
- ce recalcul global "precoce" n'avait plus de valeur metier sur une premiere affiliation sous abonnement reseau, puisque ce flux possede deja son orchestration dediee pour creer l'offre incluse puis synchroniser facturation et pipeline;
- le correctif rend `client_affilier()` paramétrable et desactive ce reclassement seulement quand l'appel vient de `app_ecommerce_reseau_affilier_client(..., source='signup_affiliation')`;
- les autres chemins d'affiliation conservent le comportement historique avec reclassement global automatique.

### Fichiers modifies
- `global/web/app/modules/entites/clients/app_clients_functions.php`
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `npm run docs:sitemap`

## Reseau dev — signup affilie: le reclassement auto ne doit plus cloturer l'offre source le jour de creation — 2026-03-15

### Resume
- le symptome remonte cote SI etait coherent: une offre deleguee creee via signup affilié sous abonnement reseau apparaissait immediatement `Terminee`, avec `date_debut = date_fin = date_facturation_debut`;
- le write path de reclassement `hors_cadre -> cadre` recreait une cible via le helper global de delegation, mais ce helper pouvait re-selectionner la ligne source elle-meme comme "offre identique" deja active;
- le remplacement reseau cloturait alors cette meme ligne source, ce qui produisait exactement une offre nee puis terminee le meme jour;
- la creation deleguee accepte maintenant un `exclude_id` optionnel utilise par le reclassement, et le remplacement porte aussi un garde defensif pour bloquer explicitement un `target_offer_same_as_source`;
- seconde cause confirmee ensuite: la creation deleguee declenchait immediatement `facturation_refresh_from_offer_client()`, qui relancait `reclassify_delegations()` en plein write path et pouvait recreer/cloturer en cascade dans la meme requete;
- les chemins de creation/replacement/activation reseau appellent maintenant le helper sans hooks post-create immediats, puis laissent le reclassement externe s'executer une seule fois en fin de flux.
- troisieme garde ajoute ensuite apres reproduction `1 active + N terminees`: `app_ecommerce_reseau_contrat_reclassify_delegations()` est maintenant non reentrant par TdR dans une meme requete PHP, et le remplacement reseau ne fait plus deux `refresh_from_offer_client()` cibles mais un seul `facturation_refresh()` global.
- correction d'orchestration ensuite: pour le cas `signup_affiliation`, le code ne passe plus par `create + reclassify` puis eventuel write path de remplacement; il appelle directement l'activation explicite `included`, ce qui cree l'offre deleguee directement en `cadre` quand l'abonnement reseau est actif.
- ajustement final ensuite apres reproduction `1 active + 1 terminee`: l'activation explicite supporte maintenant `skip_post_activation_reclassify`; le flux `signup_affiliation` l'utilise pour eviter un dernier reclassement de fin de helper, non necessaire sur une premiere creation et susceptible de recloturer une ligne selon les colonnes dispo en base.
- effet de bord corrige ensuite: en sortant du write path de reclassement, le flux avait perdu la sync pipeline affilié; `app_ecommerce_reseau_activation_activate_affiliate_explicit()` resynchronise maintenant explicitement le pipe apres activation, ce qui restaure `ABN/PAK` selon l'offre effective.
- dernier ajustement: l'activation explicite `included` etait devenue plus stricte que l'ancien helper sur `id_erp_jauge_cible`; le blocage a ete retire pour laisser `app_ecommerce_reseau_offre_deleguee_create_for_affilie()` retrouver sa resolution/fallback de jauge, comme avant.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `npm run docs:sitemap`

## Pro dev — signup: fatal AI Studio confirme, loader rendu robuste a `__DIR__` — 2026-03-15

### Resume
- les logs recharges sur `POST /extranet/account/establishment/script` montrent encore un fatal net: `Call to undefined function ai_studio_email_transactional_send()` depuis `ec_client_script.php:227`;
- la fonction existe bien dans le repo, mais le loader global utilisait encore un chemin relatif dependant du `cwd` PHP, donc non fiable depuis `pro`;
- `global_librairies.php` charge maintenant la brique transactionnelle via un chemin absolu base sur `__DIR__`, ce qui elimine ce faux negatif de chargement;
- deux gardes secondaires ont aussi ete ajoutes sur `$_SESSION['id_remise']` dans le signup pro et sur la resolution du departement client lors de la creation.

### Fichiers modifies
- `global/web/global_librairies.php`
- `pro/web/ec/modules/compte/client/ec_client_script.php`
- `global/web/app/modules/entites/clients/app_clients_functions.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/global_librairies.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_script.php`
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
- `npm run docs:sitemap`

## Reseau dev — signup affilie: auto-attribution rendue idempotente apres creation massive de delegations — 2026-03-15

### Resume
- les logs recharges ont revele un symptome bien plus grave que la simple boucle UI: le nouvel affilie `id_client=2054` avait recu une rafale d'offres deleguees actives (`id_offre_client` de `7426` a `8123` sur la trace lue), ce qui surchargeait ensuite `Mon offre` et l'extranet;
- le write path d'auto-attribution reseau n'etait pas idempotent: aucun verrou autour du couple `TdR + affilie`, et aucune reverification SQL juste avant l'`INSERT` de delegation;
- le helper global de creation deleguee pose maintenant un verrou MySQL par couple `siege/affilie` et retourne l'offre active equivalente si elle existe deja pour la meme combinaison `offre + jauge + frequence + support_source`;
- le helper d'affiliation reseau pose aussi un verrou metier sur l'auto-attribution afin d'eviter les recréations en rafale lors d'un signup ou retry concurrent.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `npm run docs:sitemap`

## Pro dev — session auth orpheline: purge si `client_detail` introuvable + gardes signup/admin — 2026-03-15

### Resume
- les derniers logs exploitables sur `dashboard` montraient encore un rendu avec `client_detail` nul, ce qui cassait ensuite plusieurs widgets et la navigation de base;
- `ec.php` invalide maintenant toute session authentifiee dont le client n'est plus resolu, puis renvoie proprement vers `signin` au lieu de continuer avec un contexte vide;
- `ec_signup.php` et `ec_signin.php` ne lisent plus `id_client_reseau` ni `CQ_admin` sans garde;
- l'objectif est de supprimer un second type de boucle silencieuse apres signup / affiliation, meme quand la session n'est plus simplement "partielle" mais orpheline cote client.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `pro/web/ec/ec_signup.php`
- `pro/web/ec/ec_signin.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/ec.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec_signup.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec_signin.php`
- `npm run docs:sitemap`

## Pro dev — boucle `signin` / `dashboard`: purge des sessions partielles — 2026-03-15

### Resume
- le symptome `chargement qui tourne en boucle` apres un signup affilie interrompu est coherent avec une session partielle: `id_client` present, mais `id_client_contact` absent;
- dans ce cas, `/signin` renvoyait vers `/extranet/dashboard`, puis `dashboard` renvoyait vers `/signin`, ce qui boucle sans rendu exploitable;
- `ec_signin.php` purge maintenant ces sessions incoherentes avant tout rendu;
- `do_script.php` ne lit plus non plus `id_client_contact` ni les cookies BO sans garde explicite.

### Fichiers modifies
- `pro/web/ec/ec_signin.php`
- `pro/web/ec/do_script.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/ec_signin.php`
- `php -l /home/romain/Cotton/pro/web/ec/do_script.php`
- `npm run docs:sitemap`

## Pro dev — acces `signin/dashboard`: gardes notices session/cookies/branding ajoutes — 2026-03-15

### Resume
- apres le correctif AI Studio, les logs `pro.dev` ne montraient plus de nouveau fatal recent, mais restaient pollues par plusieurs lectures non gardees sur `$_SESSION`, `$_COOKIE` et sur un `app_client_detail` nul;
- ces notices touchaient directement `/signin`, `/extranet/authentication/script`, `/extranet/dashboard` et le rendu branding;
- des gardes defensifs ont ete ajoutes pour les cookies `CQ_admin_gate_*`, la session `id_client_reseau`, le detail branding vide, et un log de session demo qui lisait des variables parfois absentes;
- l'objectif est de retablir un acces dev stable sans changer la logique metier.

### Fichiers modifies
- `pro/web/ec/ec_signin.php`
- `global/web/app/modules/entites/clients_branding/app_clients_branding_functions.php`
- `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
- `pro/web/ec/ec.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/ec_signin.php`
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_branding/app_clients_branding_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec.php`
- `npm run docs:sitemap`

## Pro dev — fatal signup: chargement AI Studio transactionnel retabli — 2026-03-15

### Resume
- le fatal observe en dev sur `POST /extranet/account/establishment/script` venait d'un appel a `ai_studio_email_transactional_send()` alors que cette fonction n'etait jamais chargee;
- la cause racine etait un chemin legacy encore reference dans le loader global (`emails_transactional`) alors que le dossier reel a ete renomme `1_emails_transactional`;
- le chargement global tente maintenant d'abord le chemin reel puis garde l'ancien en fallback;
- l'URL webhook de `ai_studio_email_transactional_send()` est aussi realignee sur le dossier `1_emails_transactional`, ce qui evite un prochain echec silencieux apres disparition du fatal.

### Fichiers modifies
- `global/web/global_librairies.php`
- `global/web/ai_studio/workflows/crm/1_emails_transactional/ai_studio_emails_transactional_functions.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/global_librairies.php`
- `php -l /home/romain/Cotton/global/web/ai_studio/workflows/crm/1_emails_transactional/ai_studio_emails_transactional_functions.php`
- `npm run docs:sitemap`

## Stripe portail reseau — `Mon offre` cible maintenant la souscription support — 2026-03-15

### Resume
- depuis `Mon offre`, le CTA Stripe d'un `Abonnement reseau` ouvrait jusqu'ici la home globale du customer TdR, sans ciblage de la souscription support;
- le portail reseau affichait en plus un headline Stripe herite d'un ancien libelle `Offre reseau support`;
- le runtime prepare maintenant une session Billing Portal deep-linkee sur la souscription support reseau via `subscription_update`;
- la configuration portail reseau est aussi resynchronisee cote Stripe sur `Cotton - Abonnement reseau` et active explicitement `features.subscription_update` pour eviter l'erreur `This subscription cannot be updated...`.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `npm run docs:sitemap`

## Réseau — activation support: les hors cadre absorbées sont désormais clôturées puis recréées en `cadre` — 2026-03-13

### Resume
- lors de l'activation d'un abonnement reseau, des offres deleguees `hors cadre` preexistantes pouvaient encore etre gardees comme meme ligne SI, puis simplement basculer en `cadre` dans le runtime;
- ce comportement etait acceptable metierement mais laissait un historique moins propre et ouvrait la porte a des effets de bord sur la meme offre deleguee;
- le reclassement vers `cadre` force maintenant un vrai remplacement des qu'une offre active n'est pas deja rattachee au support reseau courant via `reseau_id_offre_client_support_source`;
- on obtient ainsi une cloture immediate de l'ancienne `hors cadre` puis une nouvelle offre incluse rattachee au support actif, meme si la table d'activation etait deja passee en `cadre`.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## Confirmation reseau — lien inline `Gerer mon reseau` masque en sortie commande — 2026-03-13

### Resume
- la confirmation d'achat reseau affichait encore un lien inline `Gerer mon reseau` dans le bloc detail, alors qu'un CTA principal `Acceder a Mon reseau` etait deja ajoute sous ce bloc;
- le lien inline est maintenant masque uniquement dans le contexte confirmation commande, pour eviter le doublon tout en le conservant sur `Mon offre`.

### Fichiers modifies
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`

## Stripe retour reseau — `manage/s3` sans id: memorisation session corrigee + fallback support — 2026-03-13

### Resume
- le rendu vide observe apres paiement d'un abonnement reseau ne venait pas seulement du template: le flux `pay_network_support` n'enregistrait jamais `id_securite_offre_client_paiement_cb`;
- la page de retour `/extranet/ecommerce/offers/script/cb` construisait donc un redirect vers `manage/s3/` sans identifiant, ce qui laissait le bloc detail sans donnees;
- le checkout reseau memorise maintenant l'`id_securite` de l'offre support avant de sortir vers Stripe;
- en defense supplementaire, le step 3 sait aussi retomber sur l'offre support reseau courante si l'URL arrive encore sans identifiant;
- le correctif precedent (CTA `Mon reseau` + agenda masque) reste applicable par-dessus ce fix de routage.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/offres/ec_offres_script.php`
- `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php`

## Stripe portail retour — confirmation reseau: detail visible, CTA `Mon reseau`, agenda masque — 2026-03-13

### Resume
- sur la page de confirmation post-achat cote pro (`manage/s3`), un achat d'abonnement reseau laissait le bloc offre quasi vide et affichait encore le widget agenda a droite;
- pour une offre deleguee `hors cadre`, les informations restaient coherentes mais le widget agenda etait aussi hors sujet;
- le step 3 detecte maintenant explicitement les confirmations reseau (support reseau ou commande deleguee pour affilie);
- dans ces cas, le widget agenda est masque et un CTA direct `Acceder a Mon reseau` est ajoute sous le bloc resume;
- pour l'abonnement reseau, le bloc detail reuse aussi un entete de type `Mon offre` afin d'eviter le titre vide du contexte tunnel.

### Fichiers modifies
- `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`

## Stripe essai actif — `Mon offre` aligne sa copie sur la date de fin d'essai Stripe — 2026-03-13

### Resume
- pour un abonnement CHR avec `trialing`, le portail Stripe affichait correctement `Fin de la periode d'essai le 28 mars`, alors que `Mon offre` affichait encore `Abonnement du 13 mars 2026 au 12 avril 2026` puis une mention separee `Offre d'essai en cours`;
- l'ecart venait du fait que la vue `Mon offre` ne distinguait pas la fenetre d'essai active de la periode d'abonnement theorique;
- le snapshot Stripe remonte maintenant aussi `trial_start` / `trial_end`;
- quand la souscription est encore `trialing`, `Mon offre` remplace la ligne d'abonnement par `Offre d'essai en cours jusqu'au ...`;
- la mention redondante sous le CTA portail Stripe est retiree, et l'affichage standard des dates d'abonnement revient automatiquement une fois l'essai termine.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`

## Stripe standard — autocreation ciblee du prix catalogue absent et garde SQL pre-checkout — 2026-03-13

### Resume
- un nouveau replay de commande propre sur `ABN100M` echouait toujours au clic `Payer par CB`, avec la meme preuve log `reason=stripe_price_not_found ; detail=ABN100M`;
- cela montrait que le premier durcissement `lookup_keys -> search` restait insuffisant quand l'environnement Stripe courant ne contenait tout simplement pas encore le prix catalogue attendu;
- le checkout standard tente maintenant, uniquement sur ce cas `price_not_found`, de creer le `Price` Stripe catalogue manquant a partir du montant TTC et de la periodicite deja portes par l'offre client;
- le `lookup_key` reste conserve sur le prix cree, ce qui garde le webhook standard coherent;
- en parallele, le pre-checkout SQL sur `ecommerce_offres_to_clients` ne fait plus de `fetch_assoc()` sur un resultat SQL invalide, ce qui supprime le bruit vu juste avant les echecs Stripe.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`

## Réseau TdR — downsell délégué différé: la cible payée ne doit plus être réactivée immédiatement — 2026-03-13 (historique dépassé)

### Resume
- un test de changement d'offre déléguée `hors cadre` en cas de downsell montrait deux offres `Actives` simultanément côté SI, sans `date_fin` sur la source;
- la cause probable était le write path post-paiement: la cible payée repassait à `id_etat=3` via `app_ecommerce_offre_client_valider(...)`, alors qu'un remplacement différé devait la laisser en attente jusqu'à la fin effective de la source;
- `app_ecommerce_offre_client_valider(...)` détecte maintenant ce cas précis de remplacement manuel `deferred_end_of_period` et n'active plus immédiatement la cible;
- le scheduler différé accepte en complément une cible déjà payée mais encore en `id_etat=2`, ce qui évite qu'un second passage webhook remette la nouvelle offre active trop tôt.
- le calcul de fin planifiée source se rabat maintenant aussi sur `current_period_end` renvoyé par Stripe lors de `cancel_at_period_end`, afin de poser `date_fin` même si la lecture locale de période courante est incomplète au moment du webhook.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## Réseau TdR — mention UI de résiliation planifiée au-dessus du CTA de réactivation — 2026-03-13

### Resume
- sur `Mon réseau`, une offre déléguée `hors cadre` résiliée mais encore active affiche maintenant une mention explicite juste au-dessus du CTA de réactivation:
  - `Cet abonnement sera résilié au {jj mois aaaa}`;
- cette mention n'apparaît que dans l'état `Réactiver mon offre`, afin de clarifier que l'offre reste active jusqu'à la fin de période malgré la résiliation planifiée.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`

## Stripe — helper local de lecture des Billing Portal configurations — 2026-03-13

### Resume
- ajout d'un helper CLI local `global/web/assets/stripe/sdk/tools/list_billing_portal_configurations.php` pour lister les configurations Billing Portal Stripe à partir de la clé déjà disponible dans le code, sans avoir à ressaisir la clé API;
- le script accepte `dev` ou `prod`, puis affiche pour chaque config `bpc_...` les champs utiles au choix des variantes: `subscription_cancel_mode`, `proration_behavior`, `subscription_update_enabled`, `default_return_url`;
- exécution validée en `dev`: la config `bpc_1TAU7iLP3aHcgkSElGilMv0U` remonte bien `subscription_cancel_mode=immediately`, ce qui confirme la mauvaise voie Stripe utilisée jusqu'ici pour la résiliation unitaire `hors cadre`.

### Fichiers modifies
- `global/web/assets/stripe/sdk/tools/list_billing_portal_configurations.php`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/tools/list_billing_portal_configurations.php`
- `php /home/romain/Cotton/global/web/assets/stripe/sdk/tools/list_billing_portal_configurations.php dev`

## Réseau TdR — variantes portail Stripe simplifiées aux deux vraies voies métier — 2026-03-13 (historique dépassé)

### Resume
- décision métier confirmée: pas de variante `network_affiliate_manage`; les changements d'offre déléguée `hors cadre` passent par le tunnel Cotton, puis par les write paths Stripe/SI déjà gérés côté app;
- le code est maintenant réaligné sur seulement deux variantes portail Stripe affiliées utiles:
  - `network_affiliate_cancel_end_of_period`
  - `network_affiliate_cancel_immediate`
- en `dev`, ces variantes sont préremplies sur les IDs déjà présents dans Stripe:
  - `network_affiliate_cancel_end_of_period` -> `bpc_1T9LACLP3aHcgkSEh2y79vUB`
  - `network_affiliate_cancel_immediate` -> `bpc_1TAU7iLP3aHcgkSElGilMv0U`
- la résiliation unitaire `hors cadre` route donc désormais vers la config `at_period_end`;
- le CTA `Réactiver mon offre` ouvre une session portail standard sur la config `immediate`, qui n'autorise pas les updates de plan (`subscription_update_enabled=0`) mais laisse Stripe proposer la reprise de la souscription si elle est seulement résiliée en fin de période.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`

## Réseau TdR — variantes portail Stripe dédiées par usage affilié hors cadre — 2026-03-13 (historique dépassé)

### Resume
- l'audit logs a confirmé qu'une résiliation unitaire d'offre déléguée `hors cadre` utilisait la mauvaise voie Stripe: la souscription passait de `active` à `canceled` au lieu de poser `cancel_at_period_end`;
- le helper `app_ecommerce_stripe_billing_portal_session_prepare(...)` accepte maintenant une `configuration_variant` explicite pour les offres affiliées réseau;
- trois variantes affiliées sont désormais supportées dans la résolution de configuration Stripe:
  - `network_affiliate_manage`
  - `network_affiliate_cancel_end_of_period`
  - `network_affiliate_cancel_immediate`
- côté `Mon réseau`, la résiliation unitaire d'une offre déléguée `hors cadre` prépare maintenant le portail Stripe avec `network_affiliate_cancel_end_of_period` + `flow_type=subscription_cancel`;
- le CTA `Réactiver mon offre`/consultation passe lui par `network_affiliate_manage`;
- les IDs restent à fournir côté configuration API / variables d'environnement Stripe pour activer réellement ces nouvelles variantes.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`

## Réseau TdR — audit write portail Stripe: corrélation customer/subscription ajoutée — 2026-03-13

### Resume
- l'audit du flux de résiliation portail Stripe a confirmé qu'au clic Cotton ne fait pas de write `cancel_at_period_end`; l'app prépare seulement une session Billing Portal Stripe;
- pour diagnostiquer les cas où Stripe affiche encore `Annuler l’abonnement`, le helper `app_ecommerce_stripe_billing_portal_session_prepare(...)` embarque maintenant un snapshot Stripe de la souscription ciblée avant création de session;
- les logs `Stripe Billing Portal` exposent désormais aussi `configuration_id`, `flow_type`, `subscription_customer_id`, `customer_subscription_match`, `subscription_status`, `subscription_cancel_at_period_end` et `subscription_current_period_end`;
- cela permet de trancher rapidement entre:
  - mauvais `customer` local vs souscription ciblée;
  - mauvaise configuration portail Stripe utilisée;
  - souscription Stripe non réellement résiliée (`cancel_at_period_end=0`) malgré le passage portail.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## Réseau TdR — résiliation portail Stripe: une fin future ne doit plus être rabattue au jour courant — 2026-03-13

### Resume
- lors d'un test de résiliation unitaire d'offre déléguée `hors cadre` via le portail Stripe, la date visible pouvait retomber au jour courant alors que Stripe conservait encore une fin de période future;
- la cause probable était le chemin de réconciliation terminale: si Stripe exposait déjà un statut terminal avant que la fin planifiée n'ait été persistée localement, la désactivation explicite réseau clôturait l'offre avec fallback `CURDATE()`;
- le helper `app_ecommerce_reseau_delegated_offer_sync_from_stripe_subscription_state(...)` traite maintenant toute `current_period_end` future comme une fin planifiée prioritaire, même si le statut Stripe est déjà terminal;
- tant que cette fin Stripe reste future, l'offre ne doit plus passer immédiatement à l'état `Terminée`; la désactivation/clôture terminale est désormais court-circuitée jusqu'à l'échéance effective;
- côté `Mon réseau`, une délégation résiliée mais encore active n'expose plus le panneau `Gérer l'offre`: la ligne affiche uniquement un CTA direct `Réactiver mon offre` vers le portail Stripe, sans possibilité de `Changer d'offre` tant que la résiliation n'est pas annulée;
- le CTA de réactivation prépare maintenant une session portail Stripe standard au lieu d'un flow `subscription_cancel`, afin de laisser Stripe proposer la reprise de la souscription encore active;
- le pipe affilié est aussi resynchronisé explicitement sur l'offre encore active (`ABN`/`PAK`) tant que la résiliation reste seulement planifiée;
- on évite ainsi qu'une résiliation portail “fin de période” d'une délégation `hors cadre` soit clôturée immédiatement côté SI.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`

## Réseau TdR — délégations hors cadre: résiliation Stripe et remplacement immédiat stabilisés — 2026-03-13 (historique dépassé)

### Resume
- les trois chemins `hors cadre` sont maintenant distingués explicitement:
  - résiliation unitaire via portail Stripe => fin effective en fin de période, avec CTA réseau `Réactiver mon offre` tant que l'offre source reste active;
  - changement d'offre avec upsell => clôture Stripe immédiate au prorata + activation immédiate de la nouvelle offre, avec UI réseau standard `Gérer l'offre`;
  - changement d'offre avec downsell => fin effective en fin de période + activation différée par cron, avec message réseau `Nouvelle offre commandée effective le ...` jusqu'à bascule;
- la résiliation d'une offre déléguée `hors cadre` depuis `Voir / résilier l'offre` n'était pas répercutée côté SI, car le webhook Stripe ne traitait ni `customer.subscription.updated` ni `customer.subscription.deleted` pour ce périmètre;
- le webhook réconcilie maintenant l'état Stripe des souscriptions déléguées `hors cadre`: fin programmée => `date_fin` SI, fin effective => désactivation réseau + clôture SI;
- le remplacement immédiat via `Changer d'offre` pouvait aussi laisser deux offres actives dans le SI: au moment du webhook, la cible venait déjà d'être validée en `id_etat=3`, ce qui faisait considérer à tort la source comme “plus courante” et bloquait sa clôture;
- le helper de remplacement accepte désormais explicitement ce cas de réconciliation post-paiement où la cible est déjà l'offre active retournée par la lecture canonique, puis clôture correctement la source;
- la page `Mon réseau` lit maintenant la persistance dédiée des remplacements différés pour distinguer un downsell planifié d'une simple résiliation portail.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/ec_webhook_stripe_handler.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## Réseau / Stripe / essais — sync pipeline hors cadre + CTA portail abonnements en essai — 2026-03-13

### Resume
- une offre affiliée déléguée `hors cadre` payée par la TdR activait bien l'affiliation réseau, mais ne relançait pas la resynchronisation du pipeline affilié; le client pouvait donc garder un statut non `ABN` malgré une offre effective active;
- le helper d'activation post-paiement hors cadre resynchronise maintenant explicitement le pipeline affilié après `app_ecommerce_reseau_activation_write(...)`, avec un fallback direct basé sur l'offre déléguée activée si la lecture canonique de l'offre effective retourne encore `0` au moment du webhook;
- côté `Mon offre`, un abonnement Stripe `trialing` était assimilé à tort à un abonnement résilié dès qu'une `date_fin` existait, ce qui affichait `Réactiver mon abonnement`;
- l'UI se base maintenant sur le snapshot Stripe (`status`, `cancel_at_period_end`) pour distinguer `trialing` d'une vraie résiliation programmée, affiche `Gérer mon abonnement` pendant l'essai et ajoute la mention `Offre d'essai en cours`;
- la page `Mon offre` n'affiche plus le texte détaillé `15 jours gratuits...`; la seule mention visible pendant l'essai est désormais `Offre d'essai en cours`, qui disparaît automatiquement dès que Stripe ne remonte plus `trialing`;
- un durcissement complémentaire de `app_ecommerce_stripe_customer_ensure_for_client(...)` conserve aussi un `asset_stripe_customerId` existant même si le contact principal est incomplet, afin de limiter les blocages Stripe standard/portail liés aux données client.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `npm run docs:sitemap`

## PRO reseau — step 2: message de downsell réaligné sur la vraie règle runtime — 2026-03-13 (historique dépassé)

### Resume
- le step 2 de `Changer d'offre` affichait encore le message immédiat en se basant sur une comparaison locale incomplète des montants mensuels;
- le runtime métier traite pourtant aussi tout passage vers une période plus courte comme un remplacement différé, y compris `annuel -> mensuel`;
- le message du step 2 réutilise maintenant `app_ecommerce_reseau_delegated_offer_replace_timing_resolve(...)`, ce qui réaligne l'UI avec la décision réellement exécutée.

### Fichiers modifies
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `npm run docs:sitemap`

## Réseau TdR — persistance dédiée des remplacements délégués différés — 2026-03-13 (historique dépassé)

### Resume
- le comportement runtime validé reste inchangé:
  - upsell manuel = remplacement immédiat avec prorata;
  - downsell manuel = remplacement différé en fin de période;
  - auto-reclassement `hors cadre -> cadre` = remplacement immédiat;
- la planification différée n’est plus portée en priorité par les marqueurs `[reseau_replace:*]` / `[reseau_replace_timing:*]` dans `ecommerce_offres_to_clients.commentaire`;
- une nouvelle table `ecommerce_reseau_delegated_replacements` persiste désormais les remplacements planifiés et le cron BO l’exécute en priorité;
- la reprise des remplacements déjà planifiés avant migration reste couverte par deux garde-fous:
  - backfill best-effort depuis les marqueurs legacy à l’import SQL phpMyAdmin;
  - fallback runtime/cron sur les anciens marqueurs tant que des lignes historiques subsistent.

### Mini plan de migration
- importer `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql` pour créer la table dédiée;
- laisser le backfill SQL rapatrier les downsells déjà planifiés quand les marqueurs legacy sont encore présents;
- déployer le runtime/cron mis à jour: nouvelles planifications écrites en table dédiée, exécution prioritaire depuis cette table, fallback legacy conservé temporairement;
- une fois les anciennes lignes consommées et le parc assaini, supprimer définitivement la lecture legacy des marqueurs si souhaité.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `www/web/bo/cron_routine_bdd_maj.php`
- `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/www/web/bo/cron_routine_bdd_maj.php`
- `npm run docs:sitemap`

## Réseau TdR — remplacement canonique d’une offre déléguée active (`manual_offer_change` + `auto_reclassify_to_cadre`) — 2026-03-13 (historique dépassé)

### Resume
- un helper global unique `app_ecommerce_reseau_delegated_offer_replace(...)` pilote maintenant le remplacement d’une délégation active `hors cadre`, avec garde-fous, verrou par offre source et sortie structurée;
- après succès de la cible, le helper annule immédiatement la subscription Stripe source avec prorata, clôture l’ancienne offre dans le SI, bascule l’activation réseau sur la nouvelle cible et rafraîchit la facturation / couverture / pipeline affilié;
- la page PRO `Mon réseau` expose maintenant `Gérer l’offre` avec `Voir / résilier` et `Changer d’offre`, et l’auto-reclassement `hors cadre -> cadre` réutilise le même write path au lieu d’un simple switch de mode.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `pro/web/ec/modules/compte/client/ec_client_network_script.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `npm run docs:sitemap`

## Réseau TdR — sécurisation du recalcul dynamique des offres déléguées hors cadre au cycle Stripe — 2026-03-13

### Resume
- un helper global cible maintenant uniquement les subscriptions Stripe rattachées à des offres déléguées `hors cadre` commandées par une tête de réseau;
- le webhook Stripe lance désormais une pré-sync de pricing sur `invoice.upcoming` et `invoice.created`, puis un contrôle de resync sur `invoice.paid` en cycle de facturation;
- cette sécurisation n'impacte ni les offres propres, ni l'abonnement réseau support, ni les autres abonnements hors contexte TdR.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/ec_webhook_stripe_handler.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php`
- `npm run docs:sitemap`

## PRO reseau — bloc `Facturation`: lien actif vers `Mon offre` — 2026-03-13

### Resume
- le lien du bloc `Facturation` affiche maintenant `Voir mon abonnement` quand l'abonnement réseau est actif;
- il renvoie désormais vers la page `Mon offre`;
- le cas `Payer et activer l'abonnement` reste inchangé.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## PRO reseau — tableau `Mes affiliés`: centrage vertical sur `Affilié` et `Statut` — 2026-03-13

### Resume
- les colonnes `Affilié` et `Statut` sont maintenant centrées verticalement dans chaque ligne du tableau;
- la colonne `Détail` garde son comportement actuel;
- aucun comportement métier ni action de la page n'est modifié.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## PRO reseau — page `Mon réseau`: tutoiement harmonisé et accents relus — 2026-03-13

### Resume
- les textes visibles de la page `Mon réseau` sont maintenant alignés sur le tutoiement utilisé dans le reste de l'espace PRO;
- la relecture a aussi permis de vérifier les accents français sur les libellés visibles ajustés;
- aucun comportement métier, calcul de remise ou logique d'action n'est modifié.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## PRO reseau — CTA `Commander`: remise projetée rappelée au-dessus du bouton — 2026-03-13

### Resume
- la page `Mon réseau` affiche maintenant `Profite de ta remise réseau de xx% !` juste au-dessus du bouton `Commander` pour un affilié sans offre active;
- le pourcentage réutilise le calcul de remise projetée déjà disponible sur la page;
- aucune logique de pricing ou de checkout n'est modifiée.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## PRO reseau — step 1 délégué: fallback si le back navigateur perd le token — 2026-03-13

### Resume
- le step 1 réutilise maintenant le contexte affilié de session quand le POST revient sans `network_delegated_token` mais qu'une offre déléguée `pending` existe déjà pour cet affilié;
- cela couvre le cas de certains retours navigateur step 2 -> step 1 suivis d'un nouveau clic `Commander`;
- le fallback reste borné au contexte délégué déjà ouvert, sans changer le calcul métier du checkout.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `npm run docs:sitemap`

## PRO reseau — confirmation déléguée: changement d'offre avec token affilié conservé — 2026-03-13

### Resume
- les formulaires `Choisir` du step 2 de confirmation republient maintenant `network_delegated_token` en contexte délégué;
- un changement d'offre depuis la confirmation reste donc dans le tunnel affilié au lieu de sortir sur une erreur générique;
- aucun calcul de prix, remise ou session Stripe n'est modifié.

### Fichiers modifies
- `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_2.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_2.php`
- `npm run docs:sitemap`

## PRO reseau — tunnel délégué: back navigateur avec contexte affilié conservé — 2026-03-13

### Resume
- le step 1 délégué ne vide plus le contexte affilié en session dès que l'offre pending est créée;
- la redirection vers `manage/s2` garde aussi `network_delegated_token` dans l'URL;
- les retours arrière navigateur dans le tunnel restent donc alignés avec le contexte affilié initial.

### Fichiers modifies
- `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `npm run docs:sitemap`

## PRO reseau — checkout Stripe délégué: affilié cible rappelé côté Stripe — 2026-03-13

### Resume
- le checkout Stripe d'une commande déléguée affiche maintenant `Commande pour <affilié>` dans le texte additionnel du checkout hébergé;
- le texte est injecté via `custom_text.submit`, sans changer la structure native de Stripe;
- aucun calcul de remise ni logique de session n'est modifié.

### Fichiers modifies
- `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `npm run docs:sitemap`

## PRO reseau — confirmation déléguée: affilié cible rappelé avant la remise — 2026-03-13

### Resume
- la confirmation du tunnel de commande déléguée affiche maintenant `Commande pour <affilié>` juste au-dessus de `Remise reseau (x%)`;
- le nom vient de `id_client_delegation`, avec fallback lisible si besoin;
- aucun calcul ni write path n'est modifié.

### Fichiers modifies
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `npm run docs:sitemap`

## PRO reseau — CTA `Commander` et remise detaillee en confirmation — 2026-03-13

### Resume
- la premiere page du tunnel de commande d'une offre deleguee affiche maintenant `Commander` sur les CTA;
- le texte marketing CHR retire aussi la mention `testez pendant 15 jours` en contexte affilié;
- la page suivante de confirmation affiche `Remise reseau` avec son pourcentage quand il est stocke sur l'offre;
- le format `%` ne passe plus par le helper monetaire et n'injecte donc plus `&nbsp;`;
- aucun calcul de remise ni write path de commande n'est modifie.

### Fichiers modifies
- `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `npm run docs:sitemap`

## PRO reseau — tunnel delegue aligne sur la typo TdR sans essai gratuit — 2026-03-13

### Resume
- le point d'entree `Commander` d'une offre deleguee choisit maintenant le segment catalogue selon la typologie de la TdR qui commande;
- le widget du tunnel masque toute promesse d'essai gratuit en contexte affilié et poste `trial_period_days = 0`;
- le lot aligne donc l'UX avec le comportement metier deja en place sur les offres deleguees `pending`.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- `npm run docs:sitemap`

## WWW BO reseau — liens directs TdR / offre support dans les vues support — 2026-03-13

### Resume
- la fiche BO d'un `Abonnement reseau` affiche maintenant une ligne `CLIENT` avec lien vers la fiche de la TdR au-dessus de `Objet`;
- la page `reseau_contrats` rend maintenant `Abonnement reseau actif` cliquable pour rouvrir la fiche de l'offre support active;
- le lot ne modifie ni calcul reseau ni write path, seulement la navigation BO.

### Fichiers modifies
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
- `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- `npm run docs:sitemap`

## PRO reseau — remise de prochaine commande visible dans `Synthese` — 2026-03-13

### Resume
- le bloc `Synthese` de `Mon reseau` affiche maintenant la `Remise reseau appliquee a votre prochaine commande`;
- le calcul reprend la meme projection que le BO `reseau_contrats`, a partir du volume actif reseau `+1`;
- une note `text-muted` precise que cette remise depend du nombre d'affilies actifs et s'applique sur les offres gerees par le reseau.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## WWW BO reseau_contrats — `Offre incluse cible` visible dans la synthese TdR — 2026-03-13

### Resume
- le bloc `Affiliés du réseau` affiche maintenant `Offre incluse cible` quand l'abonnement réseau est actif;
- le libellé est relu depuis `id_offre_delegation_cible` déjà présent dans la couverture réseau, sans recalcul métier supplémentaire;
- l'information est rendue juste sous la ligne `Abonnement réseau actif / Nb affiliés limite / Nb de places dispo`.

### Fichiers modifies
- `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/repos/www/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- `npm run docs:sitemap`

## PRO reseau — detail simplifie et jauge visible sur `Mon reseau` — 2026-03-12

### Resume
- la colonne `Detail` n'affiche plus les textes d'etat internes et conserve uniquement les informations offre utiles plus les CTA;
- la jauge de l'offre est maintenant visible au format `Jauge : X joueurs`;
- le hover du bouton `Desactiver` utilise un rouge plus terne, comme les autres boutons pleins.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## PRO reseau — priorite a `Activer via l'abonnement` et stabilisation de `Desactiver` — 2026-03-12

### Resume
- sur `Mon reseau`, un affilie sans offre n'affiche plus `Commander` quand une place incluse reste disponible sur un abonnement reseau actif;
- dans ce cas, seul `Activer via l'abonnement` est propose;
- `Desactiver` ne remonte plus un faux succes si aucune offre deleguee active coherente n'est resolue;
- le bouton `Desactiver` est maintenant plein par defaut puis transparent au survol, avec texte rouge conserve.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## PATCH 2026-03-13 - Reseau PRO: notes popover retirees et wording upsell/downsell au step 2 (historique dépassé)

### Contexte
- les sous-textes du panneau `Gerer l'offre` etaient juges trop verbeux dans `Mon reseau`;
- le message de remplacement du step 2 devait distinguer upsell et downsell, avec maintien du message immediat pour l'auto-reclassement `hors cadre -> cadre`.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/HANDOFF.md`

### Effet livre
- suppression des deux phrases d'aide sous les CTA du panneau `Gerer l'offre`;
- le CTA `Voir / resilier cette offre` passe sur la couleur metier;
- au step 2, le message de remplacement manuel est maintenant calcule en `upsell` / `downsell` selon le montant recurrent net de l'offre source vs cible;
- en `downsell`, le message annonce un remplacement a la fin de la periode en cours avec date explicite;
- en `upsell` et en auto-reclassement `cadre`, le message immediat avec prorata est conserve.

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `npm run docs:sitemap`

## PRO reseau — `Gerer l'offre` ouvre maintenant le portail Stripe — 2026-03-12

### Resume
- sur `Mon reseau`, le CTA `Gerer l'offre` d'une delegation Stripe n'envoie plus vers le tunnel de commande;
- le lien est maintenant une vraie session de portail Stripe preparee pour l'offre deleguee concernee;
- si aucune session portail n'est preparable, le bouton n'est plus affiche.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## PRO reseau — correction du CTA `Gerer l'offre` vers le tunnel historique — 2026-03-12

### Resume
- le bouton `Gerer l'offre` d'une delegation Stripe sur `Mon reseau` pointait vers une URL inexistante `/extranet/account/offers/manage/s2/...`;
- le lien renvoie maintenant vers la bonne route historique `/extranet/ecommerce/offers/manage/s2/...`;
- aucun autre comportement metier n'est modifie.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## PRO reseau — `Commander` ouvre maintenant le tunnel delegue hors abonnement — 2026-03-12

### Resume
- depuis `Mon reseau`, une TdR peut maintenant lancer `Commander` pour un affilie sans offre, via le catalogue historique;
- le flux reutilise strictement le tunnel classique:
  - contexte affilie explicite initialise sur `/extranet/account/network/script`;
  - catalogue historique en mode delegue;
  - creation `pending` au `step=1`;
  - checkout Stripe au `step=2`;
  - validation puis rattachement `hors_cadre` sur la meme offre apres paiement;
- la remise reseau est visible sur le catalogue, stockee sur l'offre creee et payee via un checkout Stripe aligne sur ce montant;
- aucun fallback silencieux vers une commande `en propre` n'est autorise;
- le helper interdit `app_ecommerce_reseau_offre_deleguee_create_for_affilie(...)` n'est pas utilise dans ce flux.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- `pro/web/ec/modules/compte/client/ec_client_network_script.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_2.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_2.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `npm run docs:sitemap`

## PRO reseau — suppression du CTA `Reactiver` sur `Mon reseau` — 2026-03-12

### Resume
- `Reactiver l'offre` et toute sa logique front ont ete retires de `Mon reseau`;
- la page ne propose plus aucun flux direct de reactivation `hors abonnement reseau`;
- pour une delegation active `hors abonnement reseau`, le CTA `Gerer l'offre` n'apparait que si l'offre porte une preuve Stripe (`asset_stripe_productId`) et renvoie alors vers le parcours historique de l'offre concernee;
- sans preuve Stripe sur l'offre deleguee, aucun CTA de gestion n'est affiche;
- pour un affilie sans offre dans une TdR sans abonnement reseau actif, `Commander` ouvre maintenant le tunnel historique avec contexte affilié cible explicite;
- aucun write path serveur n'a ete retouche dans ce correctif.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

### Suite de cadrage documentee
- le plan de migration reseau documente maintenant l'evolution `3B` effectivement livree pour `Commander` via le tunnel classique;
- cette evolution couvre explicitement:
  - contexte affilie dans le tunnel;
  - remise reseau appliquee au catalogue et au paiement;
  - creation d'une offre deleguee `pending`;
  - attachement reseau `hors_cadre` seulement apres validation.

## PRO reseau — coherence UI `Desactiver` sur affilié inclus — 2026-03-12

### Resume
- audit cible sur `Mon reseau` pour un cas reel `Actif abonnement reseau` sans bouton `Desactiver`;
- cause confirmee:
  - le badge/detail utilisait le reclassement de couverture;
  - le CTA `Desactiver` utilisait `activation_state` + `mode_facturation`;
  - ces deux sources pouvaient diverger;
- correctif minimal livre:
  - la vue ne requalifie plus le badge `cadre` en `hors_cadre`;
  - le bouton `Desactiver` suit le statut `cadre` effectivement affiche;
  - le write path `deactivate_included` accepte aussi le cas ou la couverture courante prouve l'inclusion, meme si `mode_facturation` historique n'avait pas encore suivi.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `npm run docs:sitemap`

## PRO reseau — lot 3A UI: CTA affilies minimaux sur `Mon reseau` — 2026-03-12

### Resume
- la page `Mon reseau` branche maintenant une UI minimale sur `/extranet/account/network/script`;
- les actions visibles sont strictement bornees aux endpoints PRO dedies deja livres:
  - `Activer via l'abonnement`
  - `Desactiver`
  - `Gerer l'offre` pour une delegation active `hors abonnement reseau`, via le parcours historique de l'offre concernee;
- l'injection se fait inline dans la colonne `Detail` du tableau `Mes affilies`;
- garde-fous conserves:
  - aucune ecriture au chargement;
  - aucun write path legacy brut;
  - aucun CTA metier sur `offre propre`;
  - aucune reactivation directe depuis `Mon reseau`;
  - aucune commande hors abonnement neuve tant que le contexte affilié cible n'est pas prouve dans le tunnel historique;
- les retours `network_affiliate_*` sont maintenant traduits en messages front lisibles, avec mise en evidence de la ligne affilie concernee quand `id_client_affilie` revient dans l'URL.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

### TODO
- si `Commander` doit devenir cliquable depuis `Mon reseau`, prouver d'abord cote tunnel historique:
  - le portage de l'affilie cible;
  - l'offre deleguee cible;
  - les parametres jauge / frequence / tarification attendus;
- n'ajouter ensuite qu'un branchement strictement borne et sans write ambigu.

## PRO reseau — lot 3B serveur: endpoints PRO explicites minimaux — 2026-03-12

### Resume
- le socle serveur PRO minimal du lot `3B` est maintenant pose;
- nouvelle route:
  - `/extranet/account/network/script`;
- nouvelles actions serveur explicites:
  - `activate_included`
  - `deactivate_included`
  - `create_or_reactivate_hors_cadre_for_affiliate`;
- la logique metier n'est pas appelee directement via les fonctions nommees `..._from_bo(...)` depuis PRO:
  - des wrappers globaux neutres ont ete ajoutes;
  - les anciens write paths BO historiques s'alignent maintenant sur la meme logique;
- garde-fous actifs:
  - token de session dedie `network_affiliate_actions`;
  - verifications TdR / ownership affilie;
  - refus sur offre propre affilie;
  - refus sur quota inclus indisponible;
  - refus sur cible hors abonnement incoherente;
  - aucune ecriture directe sur `id_client_delegation`;
  - desactivation canonique preservee (`id_etat=4`, `date_fin`).

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/.htaccess`
- `pro/web/ec/modules/compte/client/ec_client_network_script.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

### TODO
- cabler ensuite les CTA / formulaires front explicites sur `/account/network` sans write au chargement;
- definir le mapping message front des codes `network_affiliate_*`;
- verifier en recette:
  - activation incluse avec quota disponible;
  - refus quota plein;
  - refus sur offre propre affilie;
  - creation / reactivation hors abonnement avec offre cible attendue;
  - desactivation canonique d'une delegation incluse.

## PRO reseau — cadrage lot 3 `actions affilies` — 2026-03-12

### Resume
- rebaseline documentaire du lot 3 `actions affilies` avant tout patch code;
- decision confirmee:
  - cote PRO, seuls les flux support reseau / Stripe restent aujourd'hui canoniques et autorises;
  - les actions metier affilie (`activation incluse`, `desactivation incluse`, `creation / reactivation hors abonnement`) restent `BO-only` tant qu'aucun endpoint PRO metier explicite n'existe;
- `Mon reseau` reste donc borne a une lecture / actionnabilite partielle:
  - statuts lisibles;
  - paiement support reseau;
  - portail Stripe quand disponible;
  - aucun CTA metier affilie ajoute a ce stade;
- garde-fous rappeles explicitement dans la doc:
  - aucune ecriture au chargement;
  - aucune action sur offre propre affilie;
  - historique conserve;
  - Stripe intact;
  - aucune reutilisation du CRUD generique delegation ni d'ecriture brute `id_client_delegation`.

### Fichiers modifies
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `npm run docs:sitemap`

### TODO
- prochaine etape technique reelle:
  - creer des endpoints PRO metier explicites pour `3B`
  - wrappers autorises:
    - `activate_included`
    - `deactivate_included`
    - `create_or_reactivate_hors_cadre_for_affiliate`
- ne pas rouvrir le CRUD generique delegation cote PRO.

## PRO reseau — micro-correctifs `Mes affilies` — 2026-03-12

### Resume
- correction UI/wording limitee a la liste `Mes affilies` sur `/extranet/account/network`;
- le badge `Actif hors abonnement reseau` devient dynamique pour les delegations `hors abonnement reseau`:
  - `Actif via le reseau` sans abonnement reseau actif;
  - `Actif en supplement` avec abonnement reseau actif;
- la chip `Filtrer` de la colonne `Statut` reste visible par defaut, sans attendre le hover;
- le panneau de filtres repose maintenant sur un conteneur plus simple, sans scroll interne, avec fond plein et superposition renforcee au-dessus du tableau.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

### TODO
- verifier en recette visuelle les deux cas de wording sur une TdR:
  - sans abonnement reseau actif
  - avec abonnement reseau actif
- verifier que le menu de filtre reste propre si de nouveaux statuts apparaissent

## PRO reseau — simplification UX `Mon reseau` — 2026-03-12

### Resume
- simplification cible de `/extranet/account/network` cote TdR sans nouveau write path;
- la page est recomposee autour de:
  - `Synthese`
  - `Facturation`
  - `Lien d'affiliation`
  - `Personnalisation`
  - `Mes affilies`
- les blocs `Couverture et activation`, `Hors abonnement reseau` et `Prochaines actions` sont retires;
- le CTA d'acces a l'offre est retire du header et reste seulement dans `Facturation`;
- le bloc `Facturation` reutilise le socle reseau canonique et les agregats `hors abonnement reseau`, avec format `HT [TTC]`, quota / places restantes, `Offre attribuee` quand elle est connue, et le meme CTA Stripe que `Mon offre` selon l'etat du support;
- le calcul `offres affilies non incluses` est maintenant recroise avec la couverture canonique pour exclure les offres incluses a l'abonnement reseau;
- la synthese renforce visuellement ses 3 cadres et remplace le detail actif par un lien d'ancrage vers la liste complete des affilies;
- la liste `Mes affilies` affiche maintenant les badges front attendus et une periode en cours quand elle est calculable proprement;
- la liste `Mes affilies` propose aussi un filtrage front simple par statut, base sur les statuts deja calcules dans la vue, accessible depuis une petite chip `Filtrer` sur `Statut`, borne aux valeurs presentes et avec un menu compact qui garde les libelles longs lisibles;
- le lien d'affiliation est maintenant affiche inline et copie au clic sur le lien ou sur une petite chip icone, avec sous-titre dynamique selon abonnement reseau actif ou non;
- le bloc `Personnalisation` expose `Design reseau`, `Contenus reseau` (non cable) et une ligne placeholder sur les contenus reseau partages;
- les accents front ont ete reintroduits sur l'ensemble de la page.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- verification source des libelles accentues dans `pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

### TODO
- verifier visuellement en recette les cas:
  - abonnement reseau actif avec quota disponible
  - sans abonnement reseau actif
  - offres `hors abonnement reseau` avec montants mensuels et annuels
  - affilies `actif abonnement reseau` / `actif offre propre` / `actif hors abonnement reseau` / `inactif`

## BO + PRO reseau — cloture `Abonnement reseau` et portail Stripe front — 2026-03-12

### Resume
- correctif minimal sur deux regressions reseau
- BO:
  - le passage explicite d'un `Abonnement reseau` a `Terminee` ne repasse plus par une transition runtime intermediaire susceptible de perturber l'etat vise
  - un garde-fou final reverrouille aussi la ligne support en `Terminee` apres la rotation runtime
  - un runtime reseau archive ne peut plus rebasculer automatiquement vers une autre offre support `En attente`
  - le recalcul reseau canonique ne peut plus non plus ecrire de lui-meme `En attente` ou `Active` sur l'offre support; ces transitions restent reservees aux write paths explicites
  - la fiche client TdR ne relance plus une sync legacy reseau au chargement, donc ne requalifie plus le statut support par simple relecture BO
- PRO:
  - `Mon offre` ne relance plus non plus de recalcul reseau implicite sur les read-paths TdR principaux
  - `Mon reseau` lit maintenant lui aussi la facturation reseau en mode sans sync legacy implicite
  - `Mon reseau` reconnait aussi la valeur canonique `active` pour afficher correctement le badge `Abonnement reseau actif`
  - `Mon offre` ne remonte plus de message technique Stripe brut pour les offres support reseau gerees hors Stripe
- les traces techniques et garde-fous utiles restent en place cote code

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `pro/web/ec/modules/compte/offres/ec_offres_view.php`
 - `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/repos/www/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/repos/www/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- `npm run docs:sitemap`

### TODO
- verifier en recette BO un passage `active -> Terminee` sur une offre support reseau avec reaffichage sur la meme fiche
- verifier en recette BO qu'une offre support reseau `Active` ne redevient plus `En attente` apres tout recalcul interne reseau
- verifier en recette PRO:
  - offre reseau manuelle BO sans customer Stripe
  - offre reseau Stripe complete avec portail disponible
  - offre reseau terminee archivee
  - navigation TdR entre `Mon offre` et `Mon reseau` sans retour implicite a `En attente`

## PATCH 2026-03-13 - TdR delegations: popover de gestion et offre actuelle visible

### Contexte
- le choix `Voir / resilier` / `Changer d'offre` de `Mon reseau` etait encore affiche dans la ligne du tableau;
- le tunnel de remplacement manuel devait conserver l'offre active visible, mais non selectionnable;
- le wording `Commande pour ...` devait devenir `Changement d'offre pour ...` pendant ce flux.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Effet livre
- `Gerer l'offre` ouvre maintenant un panneau flottant unique ancre au bouton clique de la ligne;
- le tunnel delegue affiche `Changement d'offre pour ...` en confirmation et dans Stripe Checkout;
- l'offre source reste visible dans le catalogue avec un CTA `Offre actuelle` desactive sur la periodicite en cours.

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `npm run docs:sitemap`

## PATCH 2026-03-13 - Diagnostic portail Stripe affilié

### Contexte
- le portail reseau global `network` est trace en logs, mais la variante `network_affiliate` n'apparait pas encore;
- il faut verifier si l'echec vient de la preparation Stripe ou d'un filtrage front avant affichage du CTA `Voir / resilier`.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/HANDOFF.md`

### Effet livre
- ajout de logs temporaires `[Network Affiliate Portal] prepare` et `[Network Affiliate Portal] visibility` dans la boucle `Mon reseau`;
- chaque ligne trace maintenant la variante portail, `blocked_reason`, presence d'URL portail et decision finale `can_view`.

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## PATCH 2026-03-13 - Stripe portail reseau: centralisation des IDs test

### Contexte
- les logs temporaires ont confirme que la variante `network_affiliate` echouait faute de configuration Billing Portal dediee;
- le portail reseau utilisait encore un ID injecte dans `pro/web/config.php`.

### Fichiers modifies
- `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `pro/web/config.php`
- `documentation/HANDOFF.md`

### Effet livre
- suppression des logs temporaires `Network Affiliate Portal`;
- ajout d'un point central `lib_Stripe_getBillingPortalConfigurationId(...)` dans `global/web/assets/stripe/sdk/stripe_sdk_functions.php`;
- `app_ecommerce_stripe_billing_portal_configuration_get(...)` lit d'abord cette source centrale, puis garde le fallback env si besoin;
- l'ID test du portail reseau est sorti de `pro/web/config.php`;
- ajout de la configuration test `network_affiliate` dediee, sans `Modifier`, pour les offres affiliees.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `php -l /home/romain/Cotton/pro/web/config.php`
- `npm run docs:sitemap`

## PATCH 2026-03-13 - Portail Stripe affilié ciblé par souscription

### Contexte
- le portail affilié ouvrait bien Stripe, mais affichait toutes les souscriptions du client au lieu de se concentrer sur l'offre choisie depuis `Mon reseau`;
- le panneau `Gerer l'offre` restait visuellement trop compact et ambigu.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/HANDOFF.md`

### Effet livre
- `Voir / resilier` cree maintenant une session Billing Portal ciblee sur la subscription de la ligne via `flow_data.subscription_cancel`;
- Stripe n'arrive plus sur la liste globale des offres, mais directement sur le flux de resiliation de l'offre choisie;
- le panneau `Gerer l'offre` affiche des CTA pleine largeur avec un texte d'aide distinct pour Stripe et pour le remplacement d'offre.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## PATCH 2026-03-13 - Downsell delegue planifie en fin de periode

### Contexte
- le remplacement manuel d'une offre deleguee hors cadre etait immediate dans tous les cas, alors que le downsell devait conserver le comportement historique de bascule en fin de periode;
- Stripe ne peut pas porter seule cette bascule dans le contexte delegue, car la cible depend encore du calcul de remise reseau et de l'orchestration SI Cotton.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `www/web/bo/cron_routine_bdd_maj.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/HANDOFF.md`

### Effet livre
- ajout d'une resolution serveur `upsell/downsell` pour les remplacements manuels d'offres deleguees hors cadre;
- un downsell manuel ne passe plus par le write path immediat: la source est programmee en `cancel_at_period_end` Stripe, la cible payee repasse en `id_etat=2`, et l'intention de remplacement est stockee dans les commentaires de l'offre cible;
- le cron BO active ensuite la cible le lendemain de la fin de periode, apres terminaison effective de la source;
- les chemins immediats restent inchanges pour les upsells et pour l'auto-reclassement `hors cadre -> cadre`.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/www/web/bo/cron_routine_bdd_maj.php`
- `npm run docs:sitemap`

### Correctif de stabilisation
- `app_ecommerce_offre_client_get_detail(...)` remonte maintenant `eotc.commentaire`; sans ce champ, le step 2 et la preparation Stripe ne voyaient pas les marqueurs `[reseau_replace:*]`, ce qui supprimait le message de remplacement et faisait tomber le checkout delegue sur `affiliate_already_active`.

## PATCH 2026-03-13 - PRO reseau `Mes affilies`: doublon `€` retire dans `Detail`

### Contexte
- sur la page `Mon reseau`, la ligne de detail d'une offre deleguee `hors cadre` affichait `Tarif : 84,92 € € HT / mois`;
- la vue concatenait un `€ HT` litteral alors que le helper `montant(...)` injecte deja la devise.

### Fichiers modifies
- `pro/web/ec/modules/compte/client/ec_client_list.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Effet livre
- le detail `Tarif` dans `Mes affilies` reutilise maintenant `montant(..., '€', 'HT', 1)` au lieu d'ajouter un second symbole `€`;
- l'affichage redevient `Tarif : 84,92 € HT / mois` pour les offres `hors cadre`, y compris sur le fallback sans suffixe.

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## PATCH 2026-03-13 - Stripe standard hors reseau: checkout catalogue et portail resilient

### Contexte
- plusieurs commandes standard `en propre` retombaient au step 2 avec `Le checkout Stripe standard n'a pas pu etre prepare...`;
- le log applicatif prouvait des echecs `stripe_price_not_found` sur des cles catalogue attendues (`ABN100A`, `ABN100M`);
- en parallele, certains acces `subscription_cancel` du portail standard tentaient de relire des souscriptions Stripe d'un autre environnement (`No such subscription ... a similar object exists in live mode, but a test mode key was used`).

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Effet livre
- depuis `Mon offre`, le CTA Stripe d'un `Abonnement reseau` n'ouvre plus la home globale du customer TdR: il cree maintenant une session Billing Portal deep-linkee sur la souscription support via `subscription_update`;
- la configuration portail reseau Stripe voit aussi son `business_profile.headline` resynchronise vers `Cotton - Abonnement reseau`, ce qui retire l'ancien libelle `Offre reseau support` si present sur la configuration cible;
- les parcours portail standard et affilie delegue restent inchanges.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `npm run docs:sitemap`

## PATCH 2026-03-15 - Portail Stripe reseau: deep-link sur la souscription support + headline aligne

### Contexte
- une tete de reseau qui ouvre `Mon offre` sur son abonnement reseau arrivait dans le portail Stripe global du client, pas sur l'offre support reseau elle-meme;
- le libelle visible cote Stripe restait en plus sur un ancien texte `Offre reseau support`.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Effet livre
- le checkout Stripe standard ne depend plus uniquement de `Price::search`; il resolve maintenant d'abord le tarif Stripe par `lookup_keys`, avec fallback `search`, ce qui retablit les commandes catalogue standard comme `ABN100A`;
- les chemins `subscription_cancel` du portail Stripe ne tentent plus de creer une session d'annulation quand la souscription cible n'est pas lisible dans l'environnement Stripe courant;
- l'audit confirme donc:
  - blocage checkout standard prouve et corrige;
  - pas de contamination du tunnel standard par la logique de checkout delegue reseau;
  - residu connu cote historique: une offre standard pointee vers une ancienne souscription d'un autre environnement n'expose plus de deep link d'annulation tant que cette incoherence n'est pas assainie.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `npm run docs:sitemap`

## PATCH 2026-03-13 - Instrumentation downsell differe delegue (historique dépassé)

### Contexte
- le cas `downsell` delegue hors cadre garde maintenant la cible en attente, mais la source active ne recoit toujours pas systematiquement sa `date_fin`;
- le diagnostic doit distinguer un blocage avant l'appel Stripe, un retour Stripe incomplet, ou un `UPDATE` SQL source qui ne s'applique pas.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/HANDOFF.md`

### Effet livre
- ajout de logs applicatifs sur `app_ecommerce_reseau_delegated_checkout_offer_attach_after_payment(...)` et `app_ecommerce_reseau_delegated_offer_replace_schedule_deferred(...)`;
- les logs exposent maintenant: contexte de depart, resultat du precheck, resultat `cancel_at_period_end` Stripe, calcul `period_end/effective_date`, et `affected_rows` des updates source/cible.
- le diagnostic `pro/logs/error_log` a ensuite isole un fatal bloquant avant l'appel Stripe: appel a une fonction inexistante `app_ecommerce_offre_client_abonnement_periode_en_cours_get_detail()` dans `app_ecommerce_reseau_delegated_offer_replace_effective_date_get(...)`.

### Correctif complementaire
- remplacement de cet appel fantome par le helper existant `app_ecommerce_offre_client_abonnement_periode_get_detail(...)` avec `allow_future_anchor=1`, pour restaurer la resolution de fin de periode sur le downsell differe.
- sur la page PRO `Mon reseau`, un downsell delegue hors cadre deja planifie ne propose plus le CTA `Gerer l'offre`; la ligne affiche uniquement la mention `Nouvelle offre commandee. Elle sera effective le {jj mois aaaa}.`
- le diagnostic `upsell` a ensuite montre un blocage distinct: au moment du retour webhook, la cible immediate devenait deja l'offre active courante, ce qui faisait tomber `app_ecommerce_reseau_delegated_checkout_offer_context_get(...)` sur `source_offer_not_current` avant la cloture de l'ancienne offre.
- ce garde-fou autorise maintenant explicitement le cas ou l'offre active courante est deja la cible marquee par le remplacement.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php`
- `npm run docs:sitemap`

## PATCH 2026-03-19 - Home TdR: hero reseau premium et lien d'affiliation integre

### Contexte
- la home TdR affichait deja un texte d'introduction et un lien d'affiliation copiable, mais pas de vrai hero visuel ni de mise en avant marketing de la valeur reseau;
- le lot demande impose un scope strict sur le seul haut de page, sans refonte des cartes reseau plus bas ni ajout de nouveau CTA commercial.

### Fichiers modifies
- `pro/web/ec/modules/communication/home/ec_home_index.php`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Effet livre
- le haut de page TdR devient un duo de blocs:
  - `Réseau Cotton` avec image de fond plein cadre, overlay violet, mini-carte lien d'affiliation a droite et pills de valeur;
  - la carte `Design du réseau` remontee a droite en position 2;
- en desktop, ces deux blocs restent sur une meme ligne en `2/3 - 1/3`; en mobile, ils repassent en colonne;
- la hauteur du bloc `Réseau Cotton` suit maintenant le contenu, sans contrainte minimale calée sur l'image;
- le lien d'affiliation reste visible sans scroll dans le hero, avec le meme mecanisme de copie et les memes IDs JS qu'avant;
- la mini-carte lien n'embarque plus de CTA `Voir mes affiliés`;
- la carte `Design du réseau` est refondue avec un grand visuel haut:
  - fallback local `cotton-reseau-marque-blanche.jpg`
  - surcharge par le visuel branding réseau utilisateur si disponible
- `Mes affiliés` repasse ensuite en 3e position dans les raccourcis reseau;
- le texte marketing central du hero est retire pour laisser respirer au maximum la puce haute et les pills basses;
- le bloc hero reutilise le visuel local deja present dans le repo (`communication-statique-cible-reseaux-franchises.jpg`) comme background, avec fallback visuel via gradients CSS;
- les widgets `Mes affiliés`, `Design du réseau`, `Jeux du réseau` et `Agenda de mon réseau` restent inchanges sous ce hero;
- aucun second gros bloc `lien d'affiliation` n'est ajoute plus bas.

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php`
- `npm run docs:sitemap`

## PATCH 2026-03-20 - BO reporting jeux: cron dedie + lecture sur agrégats existants

### Contexte
- le reporting facturation BO recalculait encore a chaud une partie des sessions jeux alors que les tables `reporting_games_*` existaient deja;
- le bloc `Reporting jeux (agregats)` etait noye dans `www/web/bo/cron_routine_bdd_maj.php`, ce qui compliquait le lancement isole et augmentait le risque de timeout sur la routine BO globale.

### Fichiers modifies
- `www/web/bo/includes/bo_reporting_games_aggregates.php`
- `www/web/bo/cron_reporting_games_aggregates.php`
- `www/web/bo/cron_routine_bdd_maj.php`
- `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/repos/www/README.md`
- `documentation/HANDOFF.md`

### Effet livre
- les agrégats jeux BO sont factorises dans un helper reutilisable;
- un cron dedie `cron_reporting_games_aggregates.php` permet de recalculer uniquement les caches jeux sans lancer toute la routine BO;
- la routine historique `cron_routine_bdd_maj.php` continue de fonctionner en appelant ce helper;
- `facturation_pivot` lit maintenant:
  - `reporting_games_sessions_monthly` pour les sessions mensuelles;
  - `reporting_games_sessions_detail` pour les sessions numeriques;
  - `reporting_games_players_monthly` et `reporting_games_players_by_type_monthly` pour les joueurs;
  - `reporting_games_sessions_monthly` aussi pour la serie N-1 quand le cache est disponible;
- le fallback sur requetes brutes est conserve si les tables d'agrégats ne sont pas presentes.

### Verification rapide
- `php -l /home/romain/Cotton/www/web/bo/includes/bo_reporting_games_aggregates.php`
- `php -l /home/romain/Cotton/www/web/bo/cron_reporting_games_aggregates.php`
- `php -l /home/romain/Cotton/www/web/bo/cron_routine_bdd_maj.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
- `npm run docs:sitemap`

## PATCH 2026-03-23 - Lien EC temporaire genere uniquement depuis le BO

### Contexte
- besoin d'un lien simple a transmettre a un contact client pour ouvrir directement l'EC sans passer par l'ecran de login;
- la fonctionnalite doit rester invisible cote front EC standard et reservee a un usage interne BO;
- le lien doit etre temporaire et a usage court.

### Fichiers modifies
- `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
- `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
- `pro/web/ec/ec_signin.php`
- `www/web/bo/www/modules/entites/clients/bo_clients_script.php`
- `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/runbooks/security.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Effet livre
- le BO fiche client expose maintenant une action par contact pour generer un lien EC temporaire;
- ce lien pointe vers `extranet/authentication/script?mode=client_contact_direct_access&token=...`;
- le token est valide 48h, consomme une seule fois, puis efface immediatement apres connexion reussie;
- la connexion redirige directement vers `dashboard`, ou vers `onboarding/use` si le compte est encore en phase `INS`;
- si le lien est invalide ou expire, retour propre vers `signin` avec un message simple;
- aucun bouton ni affichage permanent n'est ajoute dans le front EC.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec_signin.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_script.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- `npm run docs:sitemap`

## PATCH 2026-03-24 - Hotfix lien EC temporaire en navigation privee

### Contexte
- le lien temporaire BO etait bien genere, mais pouvait retomber sur `signin` en navigation privee;
- l'utilisateur n'avait alors aucune session EC preexistante.

### Cause racine
- le rewrite `/extranet/authentication/script` arrive sur `pro/web/ec/do_script.php`;
- ce point d'entree n'autorisait pas le mode GET `client_contact_direct_access` parmi les acces anonymes permis;
- la requete etait donc rejetee avant l'execution de `ec_authentification_script.php`.

### Fichier modifie
- `pro/web/ec/do_script.php`

### Effet livre
- `do_script.php` accepte maintenant explicitement `mode=client_contact_direct_access` sans session existante;
- le lien temporaire peut donc initialiser sa premiere session aussi en navigation privee.

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/do_script.php`
- `node scripts/gen-sitemap.mjs`

## PATCH 2026-03-24 - Design réseau: modale de confirmation avant sauvegarde

### Contexte
- la page `Design réseau` enregistrait directement le formulaire au clic sur `Enregistrer`;
- besoin de faire confirmer explicitement l'impact reseau du design avant sauvegarde.

### Fichier modifie
- `pro/web/ec/modules/general/branding/ec_branding_form.php`

### Effet livre
- `Enregistrer` ouvre maintenant une modale Bootstrap de confirmation;
- la modale affiche le texte:
  - `Ce design sera affiché par défaut sur les interfaces de jeu de l'ensemble de tes affiliés.`
- le submit reel du formulaire n'est declenche qu'au clic sur `Confirmer`.
- le footer des CTA est maintenant harmonise dans les deux ecrans du module `general/branding`:
  - `ec_branding_form.php`
  - `ec_branding_view.php`
- l'espacement au-dessus et en dessous du footer est symetrique;
- l'eventuel ajustement de hauteur entre colonne formulaire et preview est absorbe dans le bas de la zone contenu, juste au-dessus du footer.

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/NA_client_branding/ec_client_branding_form.php`
- `node scripts/gen-sitemap.mjs`
