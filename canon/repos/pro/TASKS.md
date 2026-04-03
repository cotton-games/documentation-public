# Repo `pro` — Tasks

## PATCH 2026-04-03 — Signup pro: ne pas recreer un compte si `email + nom client` correspondent deja
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/client/ec_client_script.php`
  - dependance relue:
    - `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
  - preuve contexte:
    - le journal AI Studio raw ne remonte pas de lot specifique sur ce flux de signup, hors chantier auth/mail du `2026-03-25`.
- [x] Cause confirmee:
  - le signup pro creait d'abord un nouveau `client`, puis ne verifiait l'existence que du `contact` par email;
  - un compte deja existant avec le meme `email` et le meme `nom client` pouvait donc etre recree inutilement.
- [x] Correctif livre:
  - ajout d'une recherche ciblee `email contact + nom client` avant `app_client_ajouter(...)`;
  - si le couple existe deja, le flux reutilise `id_client` et `id_client_contact`, puis ouvre directement la session sur ce compte;
  - les side effects de creation initiale sont sautes sur ce chemin de reutilisation:
    - creation nouveau client/contact;
    - mise a jour usage initiale;
    - affiliation reseau;
    - remise de bienvenue / session;
    - creation contact Brevo et envoi transactionnel J0.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_script.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php` OK

## PATCH 2026-04-02 — Bibliothèque Quiz: le save global n'upload plus deux fois les images des questions
- [x] Audit confirmé dans:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_content_ajax.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - `pro/web/ec/modules/jeux/catalogue_series/catalogue_series_form_manager/ec_catalogue_series_form_manager_questions_image_save.php`
- [x] Cause confirmée:
  - le flux d'édition rapide des questions quiz envoyait déjà `support_image_file` au write path principal `ec_bibliotheque_script.php`;
  - après succès, le JS relançait inutilement un second upload base64 vers `ec_catalogue_series_form_manager_questions_image_save.php` pour la même question;
  - avec plusieurs questions image dans `Enregistrer`, le save global cumulait donc deux uploads par image et finissait par échouer côté `fetch`.
- [x] Correctif livré:
  - suppression du second upload JS redondant sur le flux `js-theme-content-quick-edit` des séries quiz;
  - branchement du mode AJAX `content_library_theme_content_ajax / update_item` sur le même helper serveur d'upload image que les flux non AJAX;
  - conservation d'un seul write path effectif par image, sans second upload JS.
  - correctif SQL sur la création de question de remplacement en lot temporaire: quand aucun `jour_associe` n'est attendu, l'insert écrit maintenant `''` au lieu de `NULL`, ce qui respecte le schéma actuel de `questions.jour_associe`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_content_ajax.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`

## PATCH 2026-04-01 — Agenda `pro`: historiser aussi les sessions terminées
- [x] Audit confirmé dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `games/web/includes/canvas/php/bingo_adapter_glue.php`
- [x] Correctif livré:
  - l'agenda `pro` ne classe plus les sessions uniquement sur la date;
  - les listes `Mon agenda` / `Archives` recatégorisent maintenant aussi les sessions runtime déjà `terminées`, même si leur date n'est pas encore passée;
  - les cartes agenda et la fiche session utilisent désormais une chrono d'affichage unifiée pour rendre l'état `historique` cohérent avec ce runtime;
  - le compteur / CTA vers les archives inclut aussi ces sessions terminées.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## PATCH 2026-04-01 — PRO: nouvelle rubrique `Mes joueurs` pour organisateurs ABN/PAK/CSO non TdR
- [x] Audit confirmé dans:
  - `pro/web/ec/ec.php`
  - `pro/web/.htaccess`
  - `pro/web/ec/modules/communication/home/ec_home_index.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `documentation/canon/data/schema/DDL.sql`
- [x] Correctif livré:
  - ajout d'une route dédiée `/extranet/players`;
  - ajout d'une entrée de navigation `Mes joueurs` visible uniquement pour les comptes organisateurs non TdR avec pipeline `ABN`, `PAK` ou `CSO`, positionnée sous `Mon agenda`;
  - l'entree `Mes joueurs` est maintenant aussi masquee si le client n'a aucune session historique archivee non demo et complete;
  - le CTA nav `Je commande / Tarifs & commande` est maintenant stabilise visuellement via une classe dediee, un verrouillage inline de son gabarit au rendu HTML (dont padding horizontal et vertical forces), et un gutter de scrollbar reserve dans le menu EC, pour ne plus varier de taille selon la navigation;
  - blocage d'accès direct côté page pour les comptes TdR et masquage explicite pour les contacts animateurs;
  - ajout d'une page PRO dédiée qui délègue toute l'agrégation métier à un helper `global`, sans SQL métier dans la vue;
  - rendu V1:
    - titre de page `Joueurs et classements` dans un bandeau `.after-header` au-dessus des blocs contenus;
    - arrivee immediate sur la page avec ecran d'attente simple, puis chargement asynchrone du fragment dashboard derriere le spinner;
    - le widget chat Brevo est explicitement coupe sur `Mes joueurs`;
    - si le fragment async revient vide, la page bascule sur le message d'etat vide au lieu d'afficher un ecran blanc;
    - blocs KPI de synthese renforces visuellement avec fond bleu leger et relief discret;
    - `Membre depuis` integre au bloc `Synthese`;
    - synthèse globale + par jeu sur toute la période d'activité;
    - le total `Sessions organisees` et le detail par jeu restent alignes sur le reporting BO: les sessions papier non demo et completes restent comptees meme sans participation remontee, tandis que les sessions numeriques sans participation fiable restent exclues;
    - le detail par jeu est maintenant integre directement dans les 2 blocs KPI `Sessions organisees` et `Participants inscrits`;
    - le bloc parent de synthese est transparent et sans padding pour laisser ressortir les KPI;
    - le tableau de synthese par jeu a ete supprime;
    - tops `joueur` / `équipe` / `jeu` integres en bas du bloc `Synthese`;
    - bloc `Classements par jeu` avec filtre `annee + trimestre civil` integre, applique automatiquement a chaque changement de selection, sans bouton `Filtrer` ni lien `Réinitialiser`, par defaut sur le trimestre en cours;
    - le changement de filtre ne recharge que la zone `Classements par jeu`;
    - les listes `Annee` et `Trimestre` ne proposent que les periodes exploitables pour les classements;
    - la detection des periodes exploitables est maintenant alignee sur les sources effectivement utilisees pour les classements, y compris les runtimes recents non EP;
    - classements tries sur un score agrege, avec nb de participations conserve entre parentheses a cote du nom;
    - chaque classement affiche une mention `text-muted` rappelant la regle d'attribution des points selon le jeu;
    - le classement `Bingo Musical` reste affiche sur les sessions scorables de la periode; seules les sessions historiques sans gagnants de phase recuperables de facon fiable sont exclues, avec message explicite;
    - classements par jeu non vides uniquement;
    - message explicite quand les données actuelles ne permettent rien d'afficher;
    - badges jeu des classements alignés sur la couleur de texte des CTA du portail bibliothèque.
- [x] Règles métier retenues:
  - distinction TdR réutilisée depuis `flag_client_reseau_siege`;
  - source sessions alignée sur la règle BO de reporting: `championnats_sessions.flag_session_demo=0` et `flag_configuration_complete=1`, avec prise en compte des sessions numériques et papier;
  - le compteur principal signifie désormais `Participants connectés (joueurs & équipes)` en agrégeant les deux populations fiables;
  - `Top jeu` départagé par le nombre de sessions, puis par le nombre de participants connectés fiables, puis par ordre alphabétique;
  - aucun usage des participations probables `championnats_sessions_participations_probables`.
- [x] Limites V1 assumées:
  - le quiz ne présente qu'un classement `équipes`; les lignes runtime `cotton_quiz_players` sont traitées comme des équipes;
  - les pseudos runtime non EP sont consolidés strictement par nom normalisé et par jeu, sans fusion inter-jeux.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`

## PATCH 2026-03-31 — Sessions `pro`: fiche détail fermée hors `En attente` + synchro format avec `games`
- [x] Audit confirmé dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `games/web/includes/canvas/php/boot_lib.php`
  - `games/web/includes/canvas/php/quiz_adapter_glue.php`
  - `games/web/includes/canvas/php/blindtest_adapter_glue.php`
  - `games/web/includes/canvas/php/bingo_adapter_glue.php`
- [x] Correctif livré:
  - ajout d'un helper central `app_session_edit_state_get()` pour déterminer `en attente` / verrouillage d'édition selon le jeu;
  - côté `pro`, blocage serveur des writes `session_setting`, `session_theme` et `session_quiz_slot_delete` dès qu'une session officielle n'est plus `En attente`;
  - la fiche détail `pro` bascule alors en consultation seule, avec rendu `card-archive`, message explicite et masquage des CTA `Modifier` / `Remplacer` / `Tester`;
  - l'écran `setting` redirige vers la fiche détail si la session vient d'être verrouillée;
  - ajout d'un polling léger `pro -> start/script` pour recharger la fiche détail si `games` modifie le format, et pour resynchroniser l'écran `setting` ouvert.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
    - après correction du bloc commenté legacy de fin de fichier
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - le 500 observé en recette a été levé en supprimant le second bloc dupliqué `app_session_participation_probable_*`

## PATCH 2026-03-27 — New_EJ: retour a `develop` pour l'agenda et les vues session hors EP
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
  - `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`
- [x] Correctif livre:
  - retour au rendu `develop` des cartes agenda `pro`;
  - retour du bloc/modal historique des participations probables sur agenda et fiche session;
  - suppression des ecarts UI introduits hors perimetre `EP -> games`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`

## PATCH 2026-03-26 — Agenda: CTA et vues session tolèrent les contrats `global` incomplets
- [x] Audit confirmé dans:
  - `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `pro/logs/error_log`
- [x] Correctif livré:
  - `ec_widget_jeux_sessions_cta.php` donne désormais une valeur par défaut sûre à `cta_presentation`;
  - la correction `global` évite les notices `quiz_detail` qui perturbaient l'agenda et certaines vues session `pro`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-03-26 — Agenda / détail session: restitution des participations probables issues de `play`
- [x] Audit confirmé dans:
  - `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - affichage d'un compteur de participations probables sur les cartes agenda `pro`;
  - ajout d'une modale de détail sur les cartes agenda quand des signalements existent;
  - ajout d'un bloc `Signalements` dans la fiche session `pro` avec bouton `Voir le détail`;
  - restitution basée sur `championnats_sessions_participations_probables`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

> Référence courante TdR/Affiliés: la navigation affiche `Affiliés` / `Agenda réseau` / `Design réseau` / `Jeux réseau`; la home TdR démarre par une 1re ligne desktop `2/3 - 1/3` puis colonne en mobile: un hero reseau en split `visuel a gauche / contenu a droite` avec `nom du compte TdR` a gauche, titre `Ton lien d'affiliation`, checklist `Développe ton réseau / Diffuse tes couleurs / Choisis tes jeux`, lien d'affiliation puis CTA unique `Copier le lien`, et sans bouton secondaire inline; le bloc de synthèse réseau reste séparé à droite; la 2e ligne enchaîne `Mes affiliés`, `Design réseau`, `Jeux du réseau`, puis `Agenda de mon réseau`; `/extranet/account/network` est titrée `Mes affiliés` et affiche le lien d'affiliation puis le tableau `Affilié / Statut / Infos / Action`, avec une micro-synthese support/quota juste sous la phrase d'aide de `Mes affiliés`; `/extranet/account/branding/view` est titrée `Design du réseau`.
>
> Invariants V1 a retenir pour les offres reseau / deleguees: support `Abonnement reseau` visible en `Active` / `En attente` / `Terminee`; aucune auto-creation de support; aucune recreation automatique d'un support `En attente`; aucune propagation de fin support vers les offres `hors_cadre`; aucun parcours `Changer d'offre`, aucun upsell/downsell et aucune variante `network_affiliate_manage` comme verite finale.

## PATCH 2026-03-26 — E-commerce: la confirmation de commande client passe par AI Studio transactionnel
- [x] Audit cible prouve:
  - write path commande relu:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - socle transactionnel relu:
    - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_functions.php`
    - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`
    - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_webhook.php`
- [x] Constat confirme:
  - le mail client de confirmation de commande partait encore par `lib_Brevo_sendMailFromTemplate(...)` dans le write path `global`;
  - la garde metier existante borne deja cet envoi a la premiere facture de l'offre et a des cas produits/paiements explicitement listes;
  - AI Studio expose maintenant le template `ALL_ALL_INVOICE_MONTHLY`, aligne sur une confirmation de commande avec facture disponible;
  - le webhook AI Studio pilote le destinataire a partir de `CONTACT_EMAIL` et centralise ensuite l'envoi reel cote n8n/Brevo.
- [x] Correctif livre:
  - le bloc Brevo legacy est garde en commentaire pour validation courte;
  - l'envoi effectif commande/facture passe maintenant par `ai_studio_email_transactional_send('ALL', 'ALL', 'INVOICE_MONTHLY', ...)`;
  - le payload transmet les variables attendues par le template transactionnel (`CLIENT_NOM`, `CONTACT_*`, `CONTACT_EMAIL`, `COMMANDE_DATE`, `COMMANDE_OFFRE_NOM`, `COMMANDE_TOTAL_TTC`);
  - aucun elargissement de perimetre n'est ajoute: les gardes metier existantes restent intactes.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
- [ ] A valider hors IDE:
  - creation d'une premiere facture eligibile avec reception reelle du mail client via AI Studio/n8n/Brevo
  - verification du BCC de monitoring et du rendu template `ALL_ALL_INVOICE_MONTHLY`

## PATCH 2026-03-25 — EC desktop: la navigation gauche prend moins de largeur
- [x] Audit cible prouve:
  - shell EC relu:
    - `pro/web/ec/ec.php`
  - surcharge CSS EC relue:
    - `pro/web/ec/includes/css/ec_custom.css`
  - theme dashboard relu:
    - `global/web/includes/extranet/css/includes_main.css`
- [x] Constat confirme:
  - la largeur desktop du shell et le decalage du contenu etaient portes par le theme global, pas par le PHP des menus;
  - l'EC surcharge deja localement l'apparence de la nav dans `ec_custom.css`, ce qui permet un patch cible sans toucher au routing ni aux etats actifs;
  - une reduction moderee suffit pour liberer de l'espace contenu sans basculer en mode compact complet.
- [x] Correctif livre:
  - la nav desktop EC est ramenee a `13.75rem` au lieu du shell plus large herite;
  - la reduction est maintenant faite principalement a droite pour conserver le repere visuel historique a gauche;
  - le logo haut est centre explicitement dans le panneau;
  - les `nav-item` desktop utilisent maintenant une largeur utile unique alignee sur le menu;
  - le logo haut, les liens et le CTA se calent dans cette meme colonne au lieu d'utiliser des offsets distincts;
  - la liste desktop `navbar-nav` neutralise maintenant ses marges negatives heritees, ce qui supprime la largeur structurelle superieure du `ul[data-simplebar]`;
  - le `navbar-collapse` desktop est recale a `width: 100%` sans compensations laterales negatives, pour que le menu reste inscrit proprement dans son container;
  - le shell desktop retire maintenant son padding lateral propre, et la largeur utile de navigation passe a `100%` du panneau pour un calage plus franc dans le container;
  - le footer bas desktop gagne un peu plus d'air lateral, les liens d'icones sont rendus explicitement en flex, et leurs `svg` sont maintenant en bloc non compressible pour eviter la coupe du pictogramme `Contact`;
  - sur mobile, la largeur du menu est reduite a `min(82vw, 17rem)` y compris dans l'etat `sidebar-menu`, avec un override telephone sous `576px` a `min(74vw, 15rem)`; le drawer n'est plus force jusqu'en bas de page, mais borne a une `max-height` mobile avec scroll global du panneau, ce qui garde le footer d'icones dans le flux visible;
  - les 3 icones du footer bas sont maintenant reparties en `space-between`;
  - le `margin-left` de `.main-content` est aligne sur cette nouvelle largeur pour eviter tout chevauchement.
- [ ] Verification:
  - recette visuelle desktop sur `Dashboard`, `Mes affiliés`, `Offres & factures` et `Jeux réseau`

## PATCH 2026-03-25 — Tunnel commande EC: le step 2 n'annonce plus d'essai gratuit pour un ABN CSO
- [x] Audit cible prouve:
  - ecran recap step 2 relu:
    - `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_2.php`
  - write path checkout Stripe relu:
    - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- [x] Constat confirme:
  - le step 2 affichait `Essai gratuit, aucun prélèvement avant le ...` des qu'un `trial_period_days` etait stocke sur l'offre client;
  - le checkout Stripe standard, lui, n'applique cette periode d'essai que pour les comptes `INS`, avec exception explicite client `712`;
  - un compte `CSO` pouvait donc voir une promesse d'essai gratuit non tenue au moment du checkout.
- [x] Correctif livre:
  - le step 2 recalcule maintenant le `trial` effectif selon la meme regle que le write path Stripe;
  - en contexte standard, l'essai gratuit n'est affiche que pour `INS` avec `trial_period_days > 0`;
  - l'exception client `712` reste conservee, et le contexte delegue reseau reste force sans essai.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_2.php` OK

## PATCH 2026-03-25 — Stripe e-commerce: `customer.subscription.updated` ne fabrique plus de faux parcours reseau sur compte independant
- [x] Audit cible prouve:
  - webhook Stripe relu:
    - `pro/web/ec/ec_webhook_stripe_handler.php`
  - helper sync deleguee relu:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - le portail Stripe standard d'un compte independant etait correct;
  - le webhook `customer.subscription.updated` tentait pourtant la sync delegation reseau avant de verifier si l'offre etait reellement deleguee;
  - le helper `app_ecommerce_reseau_delegated_offer_sync_from_stripe_subscription_state(...)` renvoyait alors `delegated_context_missing`, ce qui alimentait un `stripe_action` a libelle reseau puis l'email admin webhook.
- [x] Correctif livre:
  - la lecture de l'offre par `asset_stripe_productId` reste faite en amont;
  - la sync delegation reseau n'est maintenant appelee que si `id_client_delegation > 0` sur l'offre retrouvee;
  - un compte independant reste donc sur le libelle standard/no-op de `customer.subscription.updated`, sans `blocked_reason` reseau parasite ni email admin trompeur;
  - la branche support reseau existante reste en place et n'a pas ete refondue dans ce lot;
  - ce lot ne cable aucun email transactionnel client `update / renewal / unsubscribe`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK
- [ ] A valider hors IDE:
  - update abonnement compte independant via portail Stripe
  - update abonnement reseau delegue reel

## PATCH 3 A FAIRE — Stripe e-commerce: emails transactionnels client `update / renewal / unsubscribe`
- [ ] Etat actuel a figer:
  - l'absence d'email client specialise sur update d'abonnement, renewal ou unsubscribe reste l'etat attendu du code apres patch 2;
  - le correctif patch 2 supprime seulement le faux theme reseau dans l'email admin sur compte independant;
  - un prochain audit ne doit pas qualifier cette absence d'emails client comme une regression patch 2.
- [ ] Lot futur dedie:
  - auditer les points d'entree Stripe et Cotton pour `customer.subscription.updated`, `invoice.paid` de renewal et fins de periode;
  - definir puis cabler explicitement les emails client `update`, `renewal`, `unsubscribe / resiliation`;
  - verifier separement AI Studio / Brevo / templates sans rouvrir la logique patch 2.

## PATCH 2026-03-25 — Stripe e-commerce: idempotence persistante avant creation de commande Cotton
- [x] Audit cible prouve:
  - webhook Stripe relu:
    - `pro/web/ec/ec_webhook_stripe_handler.php`
  - helpers commandes relus:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - `payment_intent.succeeded` recreait une commande PAK sans aucune garde persistante sur `payment_intent.id` ni sur `event.id`;
  - `invoice.paid` relisait bien un token `invoice.id`, mais seulement apres un rattachement tardif dans `commentaire_facture`, donc trop tard pour couvrir une double execution concurrente;
  - le lot ne doit pas toucher `customer.subscription.updated`, emails, ni les branches reseau hors strict write path facture/commande.
- [x] Correctif livre:
  - ajout d'une garde persistante `ecommerce_stripe_write_guards` pour `stripe_invoice_paid`, `stripe_payment_intent_succeeded` et `stripe_event`;
  - ajout d'un verrou applicatif `GET_LOCK` par objet Stripe avant write Cotton, puis sortie propre des retries une fois l'etat `completed` atteint;
  - les commandes creees par webhook portent maintenant le token Stripe utile des l'insert (`invoice.id` ou `payment_intent.id`) au lieu d'un rattachement seulement apres creation;
  - en cas de commande deja retrouvee par token existant, le webhook complete la garde puis ACK sans recreer de facture interne.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
- [ ] A valider hors IDE:
  - retry simple d'un meme `invoice.paid`
  - double execution concurrente d'un meme `invoice.paid`
  - retry simple d'un meme `payment_intent.succeeded`
  - double execution concurrente d'un meme `payment_intent.succeeded`

## PATCH 2026-03-25 — Stripe e-commerce: compatibilite `app_client_contact_get_detail(...)`
- [x] Audit cible prouve:
  - helper contacts relu:
    - `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
  - write path commande relu:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - `app_ecommerce_commande_ajouter()` appelait `app_client_contact_get_detail(...)` pendant la finalisation webhook Stripe;
  - seule la fonction legacy `client_contact_get_detail(...)` etait definie;
  - les call sites existants dans `pro` et `global` restent massivement en `client_contact_get_detail(...)`, donc la compatibilite ascendante est requise.
- [x] Correctif livre:
  - ajout d'un alias `app_client_contact_get_detail(...)` deleguant au helper legacy;
  - harmonisation du second call site e-commerce `global` sur le nommage `app_*`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-24 — Stripe ABN: un `invoice.paid` rejoue ne recree plus de facture interne
- [x] Audit cible prouve:
  - webhook Stripe relu:
    - `pro/web/ec/ec_webhook_stripe_handler.php`
  - helpers commandes relus:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - helpers Brevo relus:
    - `global/web/assets/sendinblue/api/sendinblue_api_functions.php`
- [x] Constat confirme:
  - le meme `event.id` Stripe `invoice.paid` etait rejoue apres des reponses `500`;
  - la creation de commande interne se faisait sans garde d'idempotence sur l'`invoice.id` Stripe;
  - le changement de pipeline ABN declenchait aussi un move Brevo `160 -> 161`, et les helpers Brevo ecrivaient encore des `print_r/echo` dans la reponse webhook.
- [x] Correctif livre:
  - le webhook cherche maintenant une commande deja liee au meme `invoice.id` Stripe avant toute recreation;
  - l'`invoice.id` Stripe est persiste dans `ecommerce_commandes.commentaire_facture` pour dedoublonner les rejoues suivants;
  - les erreurs secondaires `Invoice::update` Stripe et mail admin webhook sont journalisees sans faire tomber l'ACK webhook;
  - les helpers Brevo `lib_*` n'ecrivent plus de sortie HTTP parasite et tolerent les cas idempotents `already removed` / `already in list`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/assets/sendinblue/api/sendinblue_api_functions.php` OK

## PATCH 2026-03-24 — Design réseau: la modale de sauvegarde soumet le bon formulaire
- [x] Audit cible prouve:
  - formulaire branding relu:
    - `pro/web/ec/modules/general/branding/ec_branding_form.php`
  - shell EC relu:
    - `pro/web/ec/ec.php`
- [x] Constat confirme:
  - la modale de confirmation ciblait `document.getElementById('frm')`;
  - l'id `frm` etait aussi utilise par d'autres formulaires du shell EC, notamment le switch multi-compte;
  - selon le DOM courant, `Confirmer` pouvait donc soumettre un autre formulaire et renvoyer vers la home sans sauvegarde.
- [x] Correctif livre:
  - attribution d'un id dedie `network-branding-form` au formulaire de design reseau;
  - le JS de confirmation soumet maintenant explicitement ce formulaire.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_form.php` OK

## PATCH 2026-03-24 — EC TdR: l'upload du visuel perso branding s'aligne sur la qualite `games`
- [x] Audit cible prouve:
  - script branding EC relu:
    - `pro/web/ec/modules/general/branding/ec_branding_script.php`
  - helper branding global relu:
    - `global/web/app/modules/general/branding/app_branding_functions.php`
- [x] Constat confirme:
  - le flux EC TdR utilisait encore `600x240` pour le `visuel`;
  - ce plafond restait plus degradant que le flux `games`, meme apres correction du save branding organizer.
- [x] Correctif livre:
  - `branding_ajouter` et `branding_modifier` demandent maintenant `1600x640` qualite `100`;
  - le helper global adapte ensuite cette cible a la taille source pour conserver le ratio et eviter un upscale inutile.
- [x] Correctif UX complementaire:
  - les erreurs d'upload `branding_logo` / `branding_visuel` ne sont plus silencieuses;
  - `ec_branding_script.php` detecte maintenant les erreurs PHP (`UPLOAD_ERR_*`) et les POST trop lourds;
  - la redirection revient avec `?error=...` et les ecrans branding `view` / `form` affichent ce message dans une alerte explicite.
- [x] Effet attendu:
  - un branding reseau configure depuis `pro` alimente le meme pipeline haute qualite que le branding sauvegarde depuis `games`;
  - la qualite finale vue dans le jeu n'est plus bridee par le seul point d'entree EC.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_script.php` OK

## PATCH 2026-03-24 — Auth EC: expiration reelle des cookies BO de delegation
- [x] Audit cible prouve:
  - gate BO relu:
    - `www/web/bo/gate.php`
  - script d'authentification EC relu:
    - `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
- [x] Constat confirme:
  - les cookies `CQ_admin_gate_*` poses par le BO vivaient 1h au niveau navigateur;
  - `ec_authentification_script.php` ne faisait qu'un `unset($_COOKIE)` local, sans expiration reelle du cookie dans le browser;
  - en navigation classique, cela pouvait recoller le dernier compte BO visite sur les passages suivants par `authentication/script`.
- [x] Correctif livre:
  - expiration explicite des cookies `CQ_admin_gate_client_id` et `CQ_admin_gate_client_contact_id` des leur consommation.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/authentification/ec_authentification_script.php` OK

## PATCH 2026-03-24 — EC logout: nettoyage complet apres un acces par lien temporaire
- [x] Audit cible prouve:
  - comparaison `develop` vs `main`:
    - `pro/web/ec/modules/compte/deconnexion/ec_deconnexion_script.php`
    - `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
    - `pro/web/ec/do_script.php`
    - `pro/web/ec/ec.php`
  - script de deconnexion relu:
    - `pro/web/ec/modules/compte/deconnexion/ec_deconnexion_script.php`
- [x] Constat confirme:
  - aucun ecart de branche n'explique le bug entre `develop` et `main` sur ce flux;
  - la deconnexion revenait bien sur `signin`, mais ne purgeait qu'une partie du scope de session EC;
  - cet etat residuel pouvait perturber une nouvelle authentification manuelle juste apres un acces via lien temporaire.
- [x] Correctif livre:
  - nettoyage complet des cles de session d'authentification EC;
  - expiration explicite du cookie de session PHP;
  - expiration defensive des cookies BO historiques `CQ_admin_gate_*`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/deconnexion/ec_deconnexion_script.php` OK

## PATCH 2026-03-24 — Session test: la démo reprend le branding session de la session source
- [x] Audit cible prouve:
  - CTA `Tester` relu:
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - duplication session relue:
    - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - resolution branding runtime relue:
    - `global/web/app/modules/jeux/sessions_branding/app_sessions_branding_functions.php`
    - `global/web/app/modules/jeux/sessions/app_sessions_join.php`
  - helpers branding generaux relus:
    - `global/web/app/modules/general/branding/app_branding_functions.php`
- [x] Constat confirme:
  - le CTA `Tester` duplique bien la session via `session_duplicate`;
  - le runtime de jeu passait encore par l'ancien selecteur `app_session_branding_get_detail(...)`, limite a `evenement > reseau > client`;
  - la duplication de session ne recopiait pas le branding session `general_branding` de type `1`, donc une demo issue d'une session programmée pouvait retomber sur un autre habillage.
- [x] Correctif livre:
  - `app_session_branding_get_detail(...)` priorise maintenant le branding session `general_branding` avant les fallbacks historiques;
  - `app_sessions_join.php` lui passe explicitement l'id de la session courante;
  - `session_duplicate` duplique maintenant aussi le branding session source vers la session démo cible, assets inclus.
  - le CTA `Tester` ouvre maintenant directement la session démo sur `games/master/{id_securite_session}` dans un nouvel onglet, sans repasser par `/start/game/resume/...`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions_branding/app_sessions_branding_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_join.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php` OK

## PATCH 2026-03-23 — Mes affiliés: ajout du compteur de sessions a venir
- [x] Audit cible prouve:
  - tableau `Mes affiliés` relu:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - helper de comptage sessions relu:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livre:
  - la colonne `Infos` conserve le total de sessions programmées;
  - une ligne supplementaire `À venir : X session(s)` est ajoutee juste en dessous;
  - ce compteur reprend les sessions non demo completes dont la date est >= date du jour.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-24 — PRO auth: le lien EC temporaire passe aussi en navigation privee
- [x] Audit cible prouve:
  - point d'entree script relu:
    - `pro/web/ec/do_script.php`
  - constat confirme:
    - le garde d'entree n'autorisait pas le mode GET `client_contact_direct_access` sans session existante;
    - en navigation privee, la requete etait donc redirigee vers `signin` avant meme l'execution du script d'authentification.
- [x] Correctif livre:
  - ajout du mode `client_contact_direct_access` a la liste des entrees anonymes autorisees par `do_script.php`
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/do_script.php` OK

## PATCH 2026-03-24 — BO: l'accès direct admin vers l'EC ne retombe plus sur `signin`
- [x] Audit cible prouve:
  - gate BO relu:
    - `www/web/bo/gate.php`
  - script d'authentification EC relu:
    - `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
- [x] Constat confirme:
  - l'acces BO posait bien les cookies admin historiques;
  - mais `ec_authentification_script.php` re-entrait ensuite dans le bloc `request` a cause des parametres `GET` de routing (`t/m/p/l`), reinitialisait `$url_redir`, puis retombait sur `signin`;
  - le probleme etait donc un ecrasement du flux BO deja initialise, pas la generation du nouveau lien temporaire.
- [x] Correctif livre:
  - le bloc `formulaire / lien temporaire` ne s'execute plus quand le flux BO a deja positionne `session_init = 1`;
  - l'acces direct admin BO et le lien temporaire par token coexistent maintenant sans se perturber.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/authentification/ec_authentification_script.php` OK

## PATCH 2026-03-24 — Design réseau: confirmation avant enregistrement
- [x] Audit cible prouve:
  - formulaire reseau relu:
    - `pro/web/ec/modules/general/branding/ec_branding_form.php`
    - pattern modale existant relu:
      - `pro/web/ec/modules/general/branding/ec_branding_view.php`
- [x] Correctif livre:
  - le bouton `Enregistrer` ouvre maintenant une modale de confirmation avant soumission;
  - la modale affiche le texte: `Ce design sera affiché par défaut sur les interfaces de jeu de l'ensemble de tes affiliés.`
  - la soumission effective du formulaire ne part qu'au clic sur `Confirmer`.
  - le footer des CTA utilise maintenant un espacement haut/bas symetrique dans les etats `form` et `view`;
  - l'ajustement de hauteur residuel passe par un padding bas de la zone contenu, juste au-dessus du footer, pour mieux aligner la colonne formulaire avec la preview.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_form.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_view.php` OK

## PATCH 2026-03-24 — Design réseau: CTA `Voir le rendu réel` sur design actif
- [x] Audit cible prouve:
  - vue reseau relue:
    - `pro/web/ec/modules/general/branding/ec_branding_view.php`
  - script demo relu:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - helpers catalogue/session relus:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livre:
  - si un design reseau actif existe, la `view` affiche maintenant le lien `Voir sur une session démo` a cote du badge d'etat dans la carte, avec une icone d'ouverture externe visible;
  - la `form` d'edition n'affiche pas ce CTA;
  - le CTA ouvre une vraie session démo dans un nouvel onglet, sans precreer de session au chargement de la page;
  - la source de demo priorise un contenu partage avec le reseau, avec preference `blindtest`, puis `bingo`, puis `quiz`;
  - si aucun contenu partage exploitable n'est trouve, le fallback selectionne une playlist `blindtest` populaire et validee.
  - le module branding charge maintenant explicitement `ec_bibliotheque_lib.php`, sinon les helpers `clib_*` necessaires a cette resolution restent indisponibles sur cet ecran.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_view.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_form.php` OK

## PATCH 2026-03-23 — Navigation: retrait de l'exception reseau `1294` sur `Tarifs & commande`
- [x] Audit cible prouve:
  - shell EC relu:
    - `pro/web/ec/ec.php`
- [x] Constat confirme:
  - le CTA de nav `Je commande / Tarifs & commande` etait encore bloque par une exception hardcodee sur `id_client_reseau = 1294`;
  - cette exception masquait donc aussi le CTA pour des affiliés Beer's Corner n'ayant plus d'offre active et seulement de l'historique termine.
- [x] Correctif livre:
  - retrait de la condition `id_client_reseau != 1294` dans le calcul de `show_tarifs_commande_cta`;
  - retrait du commentaire legacy associe dans la nav;
  - le CTA redevient pilote uniquement par les regles metier generales de disponibilite commande.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK

## PATCH 2026-03-23 — Offres TdR: l'historique des delegations terminees garde la date de fin
- [x] Audit cible prouve:
  - vue `Offres` relue:
    - `pro/web/ec/modules/compte/offres/ec_offres_view.php`
  - composant detail relu:
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Constat confirme:
  - le composant detail savait deja afficher `Abonnement terminé depuis le ...` pour une delegation `hors cadre` terminee;
  - en revanche, la boucle d'historique TdR reconstruisait bien les offres deleguees terminees `hors cadre`, mais les passait ensuite au composant avec `offre_detail_is_network_hors_cadre = 0`;
  - la branche de rendu deleguee ne se declenchait donc pas sur ces lignes, meme avec une `date_fin` bien renseignee en BO.
- [x] Correctif livre:
  - les lignes d'historique TdR deleguees `hors cadre` portent maintenant explicitement `is_network_hors_cadre = 1`;
  - ce flag est reinjecte dans `ec_offres_include_detail.php` au moment du rendu historique;
  - la mention `Abonnement terminé depuis le ...` redevient donc visible sur les offres deleguees terminees cote TdR.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_view.php` OK

## PATCH 2026-03-23 — TdR: `Mes affiliés` clarifie la remise reseau et les factures affichent son pourcentage
- [x] Audit cible prouve:
  - page TdR relue:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - rendu facture PDF relu:
    - `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
  - helpers de lignes de commande relus:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - `Mes affiliés` montrait deja un pourcentage de remise reseau projete, mais pas encore une explication suffisamment lisible sur le cas `0%`, sur les paliers, ni sur le caractere dynamique de la remise;
  - le tableau `Mes affiliés` melangeait aussi plusieurs raffinements UI non documentes: ligne `À venir`, CTA `Commander` avec remise, centrage vertical des cellules et conservation de la largeur naturelle des boutons;
  - sur les factures PDF, la ligne produit pouvait encore n'afficher que `Remise réseau` sans son pourcentage, car le rendu lisait des lignes de commande ne remontant pas toujours `remise_nom` / `remise_pourcentage`.
- [x] Correctif livre:
  - le premier bloc de `Mes affiliés` expose maintenant un message marketing oriente conversion sur la remise reseau;
  - si la remise reseau est active, le bloc affiche le pourcentage courant et une ancre `Calculée sur X affilié(s) actif(s)*` vers une explication inline de bas de page rappelant le caractere dynamique de la remise et ses paliers;
  - si la remise reseau vaut `0%`, le bloc bascule sur un message d'activation `Profite d'une remise réseau de 5% ... dès ta 2e commande !`;
  - dans le tableau, `À venir : X session(s)` n'apparait que s'il existe au moins une session a venir, la mention `Remise réseau de x% !` reste conditionnelle sous `Commander`, et les cellules / CTA sont centres verticalement sans etirer les boutons;
  - les factures PDF affichent maintenant `Remise réseau : x,xx %`, en lisant d'abord la ligne de commande puis, en fallback, l'offre client source quand l'historique stocke une remise incomplete;
  - la generation des nouvelles lignes de commande embarque aussi le pourcentage dans le libelle de remise.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-23 — Mon offre affilié: historique delegue termine charge aussi en presence d'une offre propre
- [x] Audit cible prouve:
  - liste des offres affilié relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - rendu historique relu:
    - `pro/web/ec/modules/compte/offres/ec_offres_view.php`
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Constat confirme:
  - le rendu detail sait deja afficher `Abonnement terminé depuis le ...` pour une offre deleguee `id_etat = 4`;
  - le helper `app_ecommerce_offres_client_get_liste()` ne chargeait toutefois les offres deleguees qu'en fallback si aucune offre propre n'etait trouvee;
  - un affilié ayant deja une offre propre ne recevait donc plus ses offres deleguees terminees dans `Historique de mes commandes`.
- [x] Correctif livre:
  - les offres deleguees vues par un affilié affichent a nouveau `Offre pilotée par {nom_TdR}` sous la ligne `Référence`, dans la couleur du badge `Déléguée`;
  - cote TdR, `Délégation de l'offre à {nom_affilié}` est harmonisee sur cette meme couleur et ce meme niveau de mise en avant;
  - `app_ecommerce_offres_client_get_liste()` charge maintenant en une seule requete les offres ou l'affilié est soit proprietaire (`id_client`), soit delegataire (`id_client_delegation`);
  - l'historique affilié peut donc afficher en meme temps offres propres et offres deleguees terminees.
  - les boucles de rendu `Offres` et `Historique` reinitialisent aussi explicitement le contexte local du composant `ec_offres_include_detail.php` avant chaque inclusion.
  - dans la branche `ABN SANS engagement` de `ec_offres_include_detail.php`, le rendu delegue est maintenant sorti du `if (id_etat==3)` ; la branche `id_etat==4` n'est donc plus morte.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_view.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-23 — Diagnostic prod: log cible sur offre deleguee terminee cote affilie
- [x] Audit cible prouve:
  - rendu detail `Mon offre` relu:
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - source SQL verifiee sur le cas remonte:
    - `ecommerce_offres_to_clients.id = 2555`
- [x] Constat confirme:
  - la ligne brute SQL remonte bien une offre deleguee `id_etat = 4` avec `date_fin` renseignee;
  - le rendu prod cote affilie n'affiche pourtant pas `Abonnement terminé depuis le ...`.
- [x] Correctif livre:
  - ajout d'un `error_log` tres cible sur les offres deleguees terminees vues par un affilie;
  - le log remonte les variables exactes du rendu (`is_offre_deleguee_affilie`, `is_offre_deleguee_display`, `date_fin_raw`, dates de periode, `effective_end_date`, contexte route).
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-23 — Offre 12 sans engagement: affichage delegue termine stabilise cote affilie
- [x] Audit cible prouve:
  - rendu detail `Mon offre` relu:
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - write paths abonnement relus:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - cron de terminaison relu:
    - `www/web/bo/cron_routine_bdd_maj.php`
- [x] Constat confirme:
  - l'offre `12` est deja traitee dans le code comme l'ABN mensuel `sans engagement`;
  - la perte de `flag_engagement = 1` ne change donc pas le regime attendu des write paths ni du cron;
  - en revanche, le rendu `Mon offre` cote affilié faisait encore dependre a tort la mention `Abonnement terminé depuis le ...` de la branche `avec engagement`.
- [x] Correctif livre:
  - le rendu des offres deleguees cote affilié est maintenant sorti de la sous-branche `id_etat == 3` dans le cas `ABN SANS engagement`;
  - une offre deleguee `Terminée` continue donc d'afficher sa date de fin meme si l'offre catalogue ne porte plus `flag_engagement = 1`;
  - le log temporaire de diagnostic prod est retire.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-23 — Dev diagnostic: log cible sur branche `sans engagement` cote affilie
- [x] Audit cible prouve:
  - branche `ABN SANS engagement` relue:
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Constat confirme:
  - malgre le correctif de rendu, la mention `Abonnement terminé depuis le ...` disparait encore en dev apres retrait du flag `engagement` sur l'offre `12`;
  - il faut donc verifier en execution les variables exactes de la branche `sans engagement`.
- [x] Correctif livre:
  - ajout d'un `error_log` temporaire sur le cas `is_offre_deleguee_display===1` dans la branche `ABN SANS engagement`;
  - le log remonte `id_offre_client`, `id_offre`, `flag_engagement`, `id_etat`, `date_fin_raw`, les dates de periode, `effective_end_date` et le contexte de route.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-23 — Navigation EC: `Ma fiche lieu` masque pour une TdR meme en test
- [x] Audit cible prouve:
  - shell EC relu:
    - `pro/web/ec/ec.php`
- [x] Constat confirme:
  - la condition `Ma fiche lieu` autorisait encore tout compte `TEST`, y compris une tete de reseau;
  - cela contredisait la regle voulue `jamais de Ma fiche lieu pour une TdR`.
- [x] Correctif livre:
  - la condition est maintenant encapsulee par `flag_client_reseau_siege == 0`;
  - le fallback `TEST` reste donc limite aux seuls comptes non TdR.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK

## PATCH 2026-03-23 — Navigation EC: suppression du lien `Branding`
- [x] Audit cible prouve:
  - shell EC relu:
    - `pro/web/ec/ec.php`
- [x] Constat confirme:
  - le lien `Branding` etait encore pilote par un gate technique `CQ_admin_gate_client_id`;
  - cette regle ne dependait plus ni du pipeline client ni du statut TdR.
- [x] Correctif livre:
  - neutralisation explicite de la condition d'affichage dans `ec.php`;
  - ajout d'un commentaire date `23/03/2026` pour tracer la desactivation.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK

## PATCH 2026-03-23 — TdR/Affiliés: `Mes affiliés` affiche aussi le support `En attente`
- [x] Audit cible prouve:
  - page TdR relue:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - page `Offres` relue:
    - `pro/web/ec/modules/compte/offres/ec_offres_view.php`
  - point d'entree paiement relu:
    - `pro/web/ec/modules/compte/offres/ec_offres_script.php`
- [x] Constat confirme:
  - la micro-synthese de `Mes affiliés` etait bornee au seul support reseau `actif` avec quota exploitable;
  - un support `pending_payment` etait bien qualifie cote page, mais restait invisible dans cette zone;
  - le lien disponible sur cette page poussait encore vers le script de paiement direct au lieu de renvoyer vers `Offres`.
- [x] Correctif livre:
  - la synthese en tete de `Mes affiliés` reste affichee pour le support actif avec quota `X / Y`;
  - elle apparait maintenant aussi pour un support `En attente de paiement` avec un message de guidance explicite;
  - cette synthese `En attente de paiement` reste masquee si l'offre support est a `0 EUR`, comme sur `Offres`;
  - le lien associe renvoie dans ce cas vers `/extranet/account/offers`, pour laisser la page `Offres` porter le CTA `Payer et activer l'abonnement`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-20 — TdR/Affiliés: sous-titres de header retires + retours home ajoutes
- [x] Audit cible prouve:
  - page affiliés relue:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - pages design relues:
    - `pro/web/ec/modules/general/branding/ec_branding_view.php`
    - `pro/web/ec/modules/general/branding/ec_branding_form.php`
  - page jeux réseau relue:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - liens home relus:
    - `pro/web/ec/modules/communication/home/ec_home_index.php`
    - `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
- [x] Correctif livre:
  - suppression des sous-titres de header redondants sur `Mes affiliés`, `Design du réseau` et `Jeux du réseau`;
  - suppression du sous-titre explicatif interne dans `Mes affiliés`;
  - ajout d'un contexte `return_to=home` depuis les liens home reseau vers `Affiliés`, `Design réseau` et `Jeux réseau`;
  - affichage conditionnel d'un lien `← Retour à l'accueil` au-dessus des titres quand ce contexte est present;
  - cote affilié, alignement du lien `← Retour à la bibliothèque` sur le style `← Retour au catalogue`.
- [x] Verification:
  - `php -l` OK sur `ec_home_index.php`, `ec_widget_client_reseau_shortcuts.php`, `ec_client_list.php`, `ec_branding_view.php`, `ec_branding_form.php`, `ec_bibliotheque_list.php`

## PATCH 2026-03-20 — Jeux du réseau: blocs d'intro aligns sur le pattern hero home
- [x] Audit cible prouve:
  - page bibliotheque relue:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - visuel home de reference relu:
    - `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
- [x] Constat confirme:
  - la page `Jeux du réseau` exposait encore deux blocs d'intro/outillage en cartes textuelles simples;
  - ces 2 blocs existaient bien separement pour les TdR et pour les affiliés, avec contenus et CTA differents;
  - le visuel `catalogue_contenus.png` existait deja et servait deja de reference sur la home reseau.
- [x] Correctif livre:
  - les 2 blocs d'intro passent maintenant sur une carte `visuel a gauche / texte a droite`;
  - le visuel reutilise `catalogue_contenus.png`, comme la carte home `Jeux réseau`;
  - les textes adoptent la meme hierarchie que les autres blocs reseau, avec CTA en bas quand deja present;
  - les chips de scope TdR restent visibles sous le second bloc hero.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## PATCH 2026-03-19 — Home TdR: bloc droit hero converti en vue rapide reseau
- [x] Audit cible prouve:
  - rendu home relu:
    - `pro/web/ec/modules/communication/home/ec_home_index.php`
  - conventions UI relues:
    - `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
    - `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
  - source du lien/copy relue:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Constat confirme:
  - le hero gauche et les trois cartes reseau de la 2e ligne etaient deja en place et hors perimetre de refonte;
  - le bloc droit de la 1re ligne exposait deja les bonnes donnees metier, mais se lisait encore comme trois raccourcis empiles dans une grande boite;
  - les donnees requises etaient deja disponibles sans nouvelle source de verite: affilies `total/actifs/inactifs`, sessions reseau a venir, statut design partage et volume de jeux partages;
  - les conventions reutilisables existaient deja cote EC PRO: carte `card-widget`, pills arrondies, lignes et chevrons discrets, et statuts `Prêt` / `À faire`.
- [x] Correctif livre:
  - le bloc droit garde son role de complement du hero gauche, sans nouveau gros CTA ni duplication de `Voir mes affiliés`;
  - la carte adopte un vrai header conditionnel `Par où commencer ?` / `Vue rapide du réseau`, avec une condition simple basee sur les donnees deja chargees (`pas de design`, `pas de jeux partages`, `0 affilié actif`);
  - la 1re ligne devient une stat reseau prioritaire sur les affilies, avec nombre total mis en avant et pill secondaire `X actifs · Y inactifs`;
  - `Design du réseau` et `Jeux du réseau` deviennent des lignes d'etat lisibles avec labels stables, wording metier (`Aucun design personnalisé`, `Design prêt à être diffusé`, `Aucun jeu partagé`, `X jeux partagés`) et pills `À faire` / `Prêt`;
  - les lignes restent discretement cliquables vers leurs destinations naturelles avec un chevron leger;
  - les sessions reseau a venir descendent en footer compact et restent visibles meme a `0`, pour eviter l'effet de boite vide;
  - la passe de finition aligne maintenant le titre `Vue rapide du réseau` sur la hierarchie des titres de cartes reseau, renomme les lignes `Design réseau` et `Jeux réseau`, et neutralise le lien `Agenda réseau` quand aucune session n'est programmee;
  - le widget `Agenda du réseau` harmonise a son tour son titre avec les autres cartes reseau et remplace l'accent rose du nom d'affilié par le violet deja utilise ailleurs sur la page;
  - le patch reste local a `ec_home_index.php`: aucune nouvelle lib, aucun nouveau composant complexe, aucune nouvelle source metier.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php` OK
  - verification de structure du markup/CSS dans le bloc droit: header, stat affilies, lignes design/jeux et footer sessions tous portes par les variables deja calculees localement
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK

## PATCH 2026-03-20 — Home TdR: hero affiliation passe au pattern media/text des INS
- [x] Audit cible prouve:
  - rendu home TdR relu:
    - `pro/web/ec/modules/communication/home/ec_home_index.php`
  - widget home INS/CSO de reference relu:
    - `pro/web/ec/modules/widget/ec_widget_ecommerce_abonnement_cso.php`
  - reference doc home INS/CSO relue:
    - `documentation/canon/repos/pro/home_widgets_ins_cso.md`
- [x] Constat confirme:
  - le hero TdR gardait encore un rendu `image pleine largeur + mini-carte inline`, alors que la demande produit visait le pattern plus direct `visuel gauche / contenu droit` deja utilise sur la home INS pour l'acces commande;
  - le contenu metier du lien d'affiliation existait deja localement dans `ec_home_index.php`, avec copie clipboard et feedback utilisateur;
  - le bloc de synthese reseau a droite etait deja hors perimetre et ne devait pas etre remplace.
- [x] Correctif livre:
  - le bloc hero TdR gauche adopte maintenant une structure `row g-0` avec visuel reseau a gauche et contenu a droite;
  - la partie gauche affiche maintenant le `nom du compte TdR` et retire les anciennes pills basses;
  - la partie droite prend un titre `Ton lien d'affiliation` traite comme les autres titres reseau;
  - trois lignes a icone `check` structurent maintenant le message: `Développe ton réseau`, `Diffuse tes couleurs`, `Choisis tes jeux`;
  - la phrase d'aide reste au-dessus du lien, lui-meme place juste avant le CTA;
  - le lien reste copiable avec feedback;
  - le bouton secondaire `Copier` dans la ligne du lien est retire;
  - le CTA principal en pied de hero devient l'unique action de copie `Copier le lien`;
  - la partie visuelle conserve l'univers reseau sans les pills de promesse precedentes;
  - le patch reste local a `ec_home_index.php`, sans nouvelle source metier ni nouveau composant partage.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php` OK

## PATCH 2026-03-19 — TdR: micro-synthese support reseau retablie dans `Mes affiliés`
- [x] Audit cible prouve:
  - rendu PRO relu:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - source metier relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - trace historique relue:
    - `web/ec/modules/compte/client/ec_client_list.php` au commit `696841d`
- [x] Constat confirme:
  - la page `/extranet/account/network` n'affichait plus la micro-synthese abonnement/quota pourtant retenue dans la baseline TdR;
  - les variables de verite metier existaient encore deja cote page (`contract_state`, `id_offre_client_support`, `quota_max`, `quota_remaining`, `quota_exploitable`);
  - une ancienne version du rendu affichait bien `Abonnement reseau` et `Places restantes`, mais dans une hierarchie plus lourde aujourd'hui abandonnee.
- [x] Correctif livre:
  - reintroduction sous la phrase d'aide `Mes affiliés` d'une ligne compacte liee au tableau;
  - affichage uniquement si un support `Abonnement reseau` actif et exploitable existe avec quota defini;
  - la ligne reutilise le badge reseau deja calcule et les valeurs canoniques `quota_remaining/quota_max` fournies par `app_ecommerce_reseau_contrat_couverture_get_detail(...)`;
  - ajout d'un lien discret `Voir dans Offres` vers `/extranet/account/offers`, sans reintroduire le bloc `Facturation`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-19 — TdR: la fin effective cron du support clot aussi les incluses `cadre`
- [x] Audit cible prouve:
  - cron relu:
    - `www/web/bo/cron_routine_bdd_maj.php`
  - helper global relu:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - la fin effective du support via cron passait bien le support en `Terminee`;
  - mais, contrairement au write path BO manuel, ce chemin n'eteignait pas encore les delegations incluses `cadre` liees, qui pouvaient donc rester actives cote SI et en lecture PRO.
- [x] Correctif livre:
  - la transition finale support ferme maintenant aussi les incluses `cadre` encore actives et liees au support courant avant l'archivage runtime;
  - les `hors_cadre` restent hors perimetre de cette fermeture;
  - la resynchronisation pipeline affilié suit la fermeture effective.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-19 — TdR: le BO peut forcer `Active` avec une fin planifiee
- [x] Audit cible prouve:
  - write path BO relu:
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - helper global relu:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - le premier save BO `En attente -> Active` relancait une reactivation support qui revidait `date_fin`;
  - ce comportement etait coherent pour une reactivation technique, mais pas pour un forçage BO explicite destine a planifier une terminaison locale.
- [x] Correctif livre:
  - apres la reactivation support BO, le script reapplique explicitement `id_etat = 3`, `date_fin` et `flag_offert`;
  - le BO peut donc maintenant activer un support sans paiement et lui laisser une date de fin planifiee.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-19 — TdR: la creation BO du support peut aussi partir en `Active`
- [x] Audit cible prouve:
  - write path BO relu:
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Constat confirme:
  - en creation, le support reseau etait encore force en `En attente`, meme si le formulaire BO demandait `Active`;
  - l'UI BO affichait donc `pending_payment` avec une fin planifiee, ce qui etait incoherent avec l'intention de forçage manuel.
- [x] Correctif livre:
  - la creation BO respecte maintenant `Active` quand cet etat est choisi explicitement;
  - le flux reapplique ensuite `id_etat = 3`, `date_fin` et `flag_offert` apres l'activation support.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-19 — TdR: un support reseau offert remplace son montant par `Offert`
- [x] Audit cible prouve:
  - rendu PRO relu:
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Constat confirme:
  - la carte support affichait toujours `Montant négocié : 0,00 € HT / mois` meme quand l'`Abonnement reseau` etait marque `Offert`.
- [x] Correctif livre:
  - pour le seul support reseau avec `flag_offert = 1`, la ligne de montant reutilise maintenant le libelle source `OFFERT !` a cet emplacement;
  - les autres offres et les supports non offerts gardent leur affichage de montant actuel.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-19 — TdR: fermeture BO support et nettoyage immediat des lectures PRO
- [x] Audit cible prouve:
  - write path BO relu:
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - listes PRO relues:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
    - `pro/web/ec/modules/compte/offres/ec_offres_view.php`
  - helper global relu:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - des incluses `cadre` pouvaient rester actives si la table d'activations n'etait plus parfaitement alignee avec `reseau_id_offre_client_support_source`;
  - la liste affiliés PRO gardait alors des statuts/CTA incoherents;
  - l'historique `Offres` TdR pouvait encore remonter ces incluses cloturees alors qu'elles ne portent aucune facturation propre.
- [x] Correctif livre:
  - la fermeture BO du support clot maintenant aussi les incluses encore liees au support par leur champ source;
  - la liste `Mes affiliés` n'affiche plus de CTA `Voir l'offre` quand aucun objet TdR visible n'existe encore;
  - `Offres` / historique TdR repart maintenant du meme perimetre que la liste active: base support/offres propres sans delegations, puis reinjection explicite des seules lignes deleguees `hors_cadre`;
  - les delegations incluses `cadre` ne peuvent donc plus fuiter dans l'historique via une source trop large ou un fallback d'activation tardif.
  - une offre support `Abonnement reseau` terminee affiche maintenant `Abonnement termine depuis le ...` au lieu d'une periode, et masque la mention `Affiliés actuellement inclus`.
  - la confirmation de commande S3 d'un abonnement en propre avec essai gratuit charge maintenant aussi le snapshot Stripe `trialing` en contexte checkout, active bien le branchement `trial_summary`, et affiche `Essai gratuit, aucun prélèvement avant le ...` a la place d'une periode d'abonnement.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_view.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-19 — Stripe support reseau: `customer.subscription.updated` renseigne enfin `date_fin`
- [x] Audit cible prouve:
  - webhook Stripe relu:
    - `pro/web/ec/ec_webhook_stripe_handler.php`
  - refresh reseau relu:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - point d'entree paiement support relu:
    - `pro/web/ec/modules/compte/offres/ec_offres_script.php`
- [x] Constat confirme:
  - le webhook support etait bien cense ecrire `date_fin = current_period_end` sur l'offre locale retrouvee par `asset_stripe_productId`;
  - mais un premier `case customer.subscription.updated` cassait l'execution apres la sync deleguee, avant le bloc support plus bas;
  - la date de fin du support ne pouvait donc jamais etre ecrite sur ce chemin, meme quand Stripe remontait correctement la fin de periode.
- [x] Correctif livre:
  - le premier traitement `customer.subscription.updated` gere maintenant aussi le support reseau retrouve via `asset_stripe_productId`;
  - une fin de periode Stripe support ecrit desormais `date_fin = current_period_end`, relance le refresh reseau local et planifie la fin de periode des incluses;
  - le doublon mort plus bas dans le webhook est retire pour figer un seul chemin deterministe.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK

## PATCH 2026-03-19 — TdR: ecran BO `reseau_contrats` sans reclassement cache a l'ouverture
- [x] Audit cible prouve:
  - lecture BO relue:
    - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - helpers globaux relus:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - la simple ouverture de la page BO `Voir / gérer les affiliés` relancait encore un reclassement technique;
  - cette lecture pouvait donc muter l'etat reseau sans action utilisateur explicite.
- [x] Correctif livre:
  - le chargement de l'ecran BO ne declenche plus ce write implicite;
  - les actions BO explicites restent seules autorisees pour resynchroniser l'etat.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-19 — TdR: fermeture serveur du remplacement delegue `hors_cadre`
- [x] Audit cible prouve:
  - point d'entree reseau relu:
    - `pro/web/ec/modules/compte/client/ec_client_network_script.php`
  - tunnel checkout relu:
    - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - rendu `Offres` relu:
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - rendu `Mes affiliés` relu:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Constat confirme:
  - l'UI n'exposait plus de bouton `Changer d'offre`, mais la route directe `start_replace_delegated_hors_cadre_checkout` existait encore;
  - le tunnel checkout conservait aussi la pose de marqueurs de remplacement legacy;
  - `Mon offre` et `Mes affiliés` gardaient encore des messages de remplacement planifie / immediate issus de ce flux abandonne.
- [x] Correctif livre:
  - la route PRO de remplacement direct renvoie maintenant explicitement `replacement_disabled_v1`;
  - le tunnel checkout delegue ne pose plus de marqueur de remplacement legacy;
  - les rendus PRO n'annoncent plus de remplacement `hors_cadre` comme action ou comme etat metier courant.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-18 — TdR: harmonisation UI finale home / affiliés / design / jeux réseau
- [x] Audit cible prouve:
  - shell nav relu:
    - `pro/web/ec/ec.php`
  - home widgets relus:
    - `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
    - `pro/web/ec/modules/widget/ec_widget_client_reseau_resume.php`
  - page affiliés relue:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - pages design réseau relues:
    - `pro/web/ec/modules/compte/NA_client_branding/ec_client_branding_view.php`
    - `pro/web/ec/modules/compte/NA_client_branding/ec_client_branding_form.php`
  - page jeux réseau relue:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- [x] Constats confirmes:
  - la home TdR gardait des titres de widgets en texte colore sans header jaune dedie;
  - la home TdR ne donnait pas encore de mode d'emploi reseau ni d'acces direct au lien d'affiliation au-dessus des widgets;
  - la page `/account/network` gardait le titre `Mon réseau` et des cartes/CTA encore colores en violet;
  - les pages `Design réseau` utilisaient encore des CTA pleins historiques;
  - `Jeux réseau` gardait des liens retour `Mon réseau` et n'adaptait pas son empty-state au nombre de jeux partagés.
- [x] Correctif livre:
  - la home TdR affiche maintenant un texte d'introduction d'usage reseau au-dessus des widgets;
  - le lien d'affiliation y est affiche inline avec une icone de copie, sans bloc carte dedie;
  - la home TdR expose les widgets `Mes affiliés`, `Design du réseau`, `Jeux du réseau` et `Agenda de mon réseau`;
  - ces widgets utilisent maintenant un header transparent avec la seule ligne icone + titre surlignee en jaune `#FFDB03`;
  - les headers home reprennent maintenant les icônes du menu gauche de navigation;
  - le widget `Agenda de mon réseau` reprend le même surlignage, sans texte forcé en uppercase;
  - `/account/network` affiche maintenant `Mes affiliés` comme surface de pilotage affiliés;
  - la page ne garde plus que le lien d'affiliation puis un tableau simplifie `Affilié / Statut / Infos / Action`;
  - les blocs `Personnalisation`, jeux réseau et le détail des offres affiliées sont retires de cette page;
  - la colonne `Infos` remonte la metrique existante `sessions programmées`;
  - la colonne `Action` garde `Activer` / `Désactiver` / `Commander` quand ces actions sont légitimes, sinon renvoie vers `Offres` filtre sur l'affilié;
  - les headers jaunes sont retires de la page `Affiliés`, les titres reviennent en couleur par defaut;
  - l'accès `Design réseau` injecte `nav_ctx=network_design` pour stabiliser le surlignage du menu dédié;
  - `Jeux réseau` retire les liens retour vers `Mon réseau`;
  - si aucun jeu n'est partagé, le hub affiche directement les 3 blocs de jeux vers les catalogues standards et masque `Ajouter des jeux`;
  - si au moins 1 jeu est partagé, le hub conserve le CTA `Ajouter des jeux` et n'affiche pas ces 3 blocs.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_reseau_resume.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/NA_client_branding/ec_client_branding_view.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/NA_client_branding/ec_client_branding_form.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## PATCH 2026-03-18 — TdR: fin BO abonnement réseau sans clôture parasite des hors cadre
- [x] Audit cible prouve:
  - write path BO manuel relu:
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - helper de clôture support relu:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - lors d'un passage BO manuel d'un abonnement réseau en `Terminée`, le helper de clôture support désactivait bien toutes les activations du contrat, mais clôturait aussi les offres déléguées `hors_cadre`;
  - cette clôture parasite venait de `app_ecommerce_reseau_support_offer_force_close_from_bo()`, qui ne filtrait pas `mode_facturation` avant de passer l'offre déléguée en `id_etat = 4`.
- [x] Correctif livre:
  - le write path BO manuel continue de réécrire les activations réseau en `inactive` pour sortir du cadre support;
  - seules les délégations `cadre` ferment maintenant leur offre déléguée en même temps que l'abonnement réseau;
  - les délégations `hors_cadre` restent actives et ne basculent plus à tort en `Terminée`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `npm run docs:sitemap` OK

## PATCH 2026-03-18 — TdR: agenda réseau complet et lecture seule
- [x] Audit cible prouve:
  - widget agenda relu:
    - `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
  - page agenda relue:
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - shell nav relu:
    - `pro/web/ec/ec.php`
- [x] Constats confirmes:
  - le widget agenda réseau n'affichait pas le total ni de lien vers une vue complète;
  - la nav TdR n'exposait pas encore d'entrée agenda réseau dédiée;
  - la variante réseau devait rester en lecture seule, sans aucun CTA de programmation.
- [x] Correctif livre:
  - le widget agenda réseau affiche maintenant `Agenda de mon réseau (N)`;
  - son footer pointe vers `Voir l'agenda réseau complet`;
  - la nav TdR expose `Agenda réseau` sous `Mes affiliés`;
  - `extranet/games?network_agenda=1` réutilise la vue agenda en agrégeant les sessions officielles des affiliés;
  - ce mode réseau retire les CTA de programmation (`Ajouter`, `Nouvelle session`, `Gérer`).
  - ce mode retire aussi les CTA de lancement du jeu / d'accès aux offres sur les cartes session.
  - les accès home/nav visent finalement `/extranet/start/games?network_agenda=1`, car la redirection `/extranet/games` faisait perdre le query string.
  - si aucune session officielle réseau à venir n'existe, le widget masque `(0)` et son CTA, et la nav masque aussi `Agenda réseau`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php` OK

## PATCH 2026-03-18 — TdR: 3 widgets raccourcis réseau sur la home
- [x] Audit cible prouve:
  - shell nav relu:
    - `pro/web/ec/ec.php`
  - home relue:
    - `pro/web/ec/modules/communication/home/ec_home_index.php`
  - widget reseau existant relu:
    - `pro/web/ec/modules/widget/ec_widget_client_reseau_resume.php`
  - sourcing reseau relu:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constats confirmes:
  - la home TdR affichait encore le couple `Mon réseau / Agenda de mon réseau`;
  - les accès `Design réseau` et `Jeux réseau` n'étaient pas remontés sur la home;
  - l'ordre nav TdR ne suivait pas encore `Mes affiliés` puis `Design réseau` puis `Jeux réseau`.
- [x] Correctif livre:
  - la home TdR expose maintenant 3 widgets raccourcis `Mes affiliés`, `Design réseau` et `Jeux réseau`;
  - le widget affiliés remonte le total puis `Actifs / Inactifs`;
  - le widget design remonte un statut simple `actif / absent`;
  - le widget jeux remonte le nombre de jeux réseau partagés;
  - l'agenda réseau reste affiché sous ces 3 raccourcis;
  - la nav TdR inverse `Design réseau` et `Jeux réseau` pour reprendre cet ordre.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK

## PATCH 2026-03-18 — TdR: historique `Offres` allégé pour gros volumes
- [x] Audit cible prouve:
  - vue offres relue:
    - `pro/web/ec/modules/compte/offres/ec_offres_view.php`
- [x] Constats confirmes:
  - meme replié, l'historique TdR continuait a calculer son volume complet;
  - une fois ouvert, la pagination reposait encore sur un comptage total alors qu'un simple `prev/next` suffisait.
- [x] Correctif livre:
  - l'historique TdR ne fait plus de `count` complet au chargement;
  - a froid, la page ne verifie plus que la presence d'au moins une ligne historique;
  - a chaud, seule la page demandee est chargee, avec une ligne suplementaire pour detecter `Suivant`;
  - la navigation historique passe en `Page N` avec `Precedent / Suivant`, sans calcul de total.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_view.php` OK

## PATCH 2026-03-18 — TdR: filtre par affilié ajouté dans `Factures`
- [x] Audit cible prouve:
  - vue factures relue:
    - `pro/web/ec/modules/compte/factures/ec_factures_list.php`
  - helper commandes relu:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
      - `app_ecommerce_commande_get_liste`
      - `app_ecommerce_commande_delegated_affiliate_label_get`
- [x] Constats confirmes:
  - la page `Factures` TdR listait bien les factures portees par le reseau, mais sans possibilite de les isoler par affilie;
  - le besoin de filtrage existait deja dans `Offres` avec un parcours similaire.
- [x] Correctif livre:
  - la page `Factures` expose maintenant un filtre simple `Tous les affilies / <affilie>`;
  - le filtre est alimente a partir des offres deleguees presentes dans la liste de factures;
  - en contexte filtre, seules les factures rattachees a l'affilie choisi restent affichees;
  - les factures support reseau restent visibles uniquement en vue globale.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_list.php` OK

## PATCH 2026-03-18 — TdR: harmonisation finale des libelles de periode dans `Offres`
- [x] Audit cible prouve:
  - rendu detail offre relu:
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Constats confirmes:
  - certaines offres TdR `hors cadre` retombaient encore dans des branches de rendu “offre directe”;
  - la page pouvait donc afficher un doublon `Periode en cours` / `Abonnement du`;
  - le support reseau gardait aussi un libelle `Periode du ... au ...` au lieu du wording attendu.
- [x] Correctif livre:
  - un indicateur commun couvre maintenant toutes les offres deleguees affichees cote TdR;
  - les branches generiques de periode / cloture / fin programmee sont exclues pour ces offres;
  - le libelle redondant `Affilie concerne` est retire quand la delegation affiche deja l'affilie cible;
  - les offres deleguees actives affichent `Periode en cours : du ... au ...`;
  - une resiliation programmee conserve `Cet abonnement delegue se termine le ...`;
  - les offres deleguees terminees affichent `Abonnement termine depuis le ...`;
  - l'abonnement reseau support utilise aussi `Periode en cours : du ... au ...`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-18 — TdR: `Mon réseau` devient `Mes affiliés` et `Design réseau` entre dans la nav
- [x] Audit cible prouve:
  - navigation shell relue:
    - `pro/web/ec/ec.php`
- [x] Constats confirmes:
  - l'entrée nav réseau restait libellée `Mon réseau`;
  - l'accès direct à `/account/branding/view` n'existait pas dans la nav TdR alors que ce parcours est maintenant structurant.
- [x] Correctif livre:
  - l'entrée nav `Mon réseau` est renommée `Mes affiliés`;
  - une entrée directe `Design réseau` est ajoutée juste sous `Mes affiliés`;
  - cette entrée pointe vers `/account/branding/view`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK

## PATCH 2026-03-18 — TdR: le menu `Media Kit` est retire du shell
- [x] Audit cible prouve:
  - navigation shell relue:
    - `pro/web/ec/ec.php`
- [x] Constats confirmes:
  - apres fermeture des accès utiles a la programmation et au media kit standard, le menu `Media Kit` restait visible pour une tête de réseau;
  - ce point d'entree n'a pas d'intérêt produit pour une TdR dans l'etat actuel du parcours.
- [x] Correctif livre:
  - le menu `Media Kit` n'est plus affiche pour une tête de réseau;
  - les autres profils conservent la logique d'affichage existante.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK

## PATCH 2026-03-18 — TdR: le menu `Mon agenda` est retire du shell
- [x] Audit cible prouve:
  - navigation shell relue:
    - `pro/web/ec/ec.php`
- [x] Constats confirmes:
  - apres masquage des CTA de programmation TdR, le menu `Mon agenda` restait encore visible dans la nav gauche;
  - ce menu gardait donc un point d'entree inutile vers des surfaces encore liees a la programmation.
- [x] Correctif livre:
  - le menu `Mon agenda` n'est plus affiche pour une tête de réseau;
  - les autres profils gardent la logique d'affichage existante.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK

## PATCH 2026-03-18 — Mon reseau: hotfix perf sur l'ouverture des portails Stripe
- [x] Audit cible prouve:
  - rendu `Mon reseau` relu:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - script reseau relu:
    - `pro/web/ec/modules/compte/client/ec_client_network_script.php`
  - helper Stripe/portail relu:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
      - `app_ecommerce_stripe_billing_portal_session_prepare`
- [x] Constats confirmes:
  - la page préparait des sessions portail Stripe pendant le rendu;
  - ce coût existait une fois pour le support réseau et surtout dans la boucle des affiliés `hors cadre`;
  - la page faisait donc des appels Stripe inutiles avant même tout clic utilisateur.
- [x] Correctif livre:
  - `Mon reseau` ne prépare plus de session portail Stripe au chargement;
  - le bouton `Gérer l’offre` d’un affilié `hors cadre` pointe maintenant vers un endpoint local qui prépare Stripe seulement au clic;
  - les write paths POST existants restent inchangés;
  - les erreurs portail éventuelles sont toujours remontées via le flash réseau.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php` OK

## PATCH 2026-03-18 — TdR: plus de commande en propre ni de programmation hors démo
- [x] Audit cible prouve:
  - navigation shell relue:
    - `pro/web/ec/ec.php`
  - home relue:
    - `pro/web/ec/modules/communication/home/ec_home_index.php`
    - `pro/web/ec/modules/widget/ec_widget_client_reseau_resume.php`
    - `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
  - fiche détail bibliothèque et write path relus:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- [x] Constats confirmes:
  - la TdR voyait encore le CTA nav `Tarifs & commande` / `Je commande`;
  - la home TdR pouvait encore exposer des widgets ecommerce standard au lieu de réutiliser les widgets reseau deja disponibles;
  - la fiche détail bibliothèque affichait encore les CTA de programmation hors démo, sans refus serveur dédié en cas de POST direct.
- [x] Correctif livre:
  - le CTA nav `Tarifs & commande` est maintenant masque pour une TdR;
  - la home TdR bascule maintenant sur les widgets reseau existants (`Mon réseau` + `Agenda de mon réseau`) au lieu des widgets ecommerce standard;
  - la fiche détail bibliothèque ne propose plus de CTA de programmation hors démo pour une TdR;
  - le write path bibliothèque refuse maintenant aussi les modes serveur de programmation hors démo pour une TdR, avec message de refus explicite;
  - le CTA `Lancer une démo` reste disponible.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK

## PATCH 2026-03-17 — Mon offre: bloc agrégé des offres affiliées hors cadre à charge TdR
- [x] Audit cible prouve:
  - rendu réel relu:
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - source de vérité de la carte support relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
      - `app_ecommerce_reseau_facturation_get_detail`
  - source de vérité des délégations hors cadre relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
      - `app_ecommerce_reseau_offres_hors_cadre_pricing_get`
      - `app_ecommerce_reseau_contrat_couverture_get_detail`
- [x] Constats confirmes:
  - `Mon offre` exposait deja la carte support `Abonnement reseau` cote TdR;
  - la doc canonique du lot ne reouvrait pas encore de bloc `hors cadre` dans `Mon offre`;
  - le helper `app_ecommerce_reseau_offres_hors_cadre_pricing_get(...)` fournit deja une lecture canonique des offres deleguees `hors_cadre` actives, payees par la TdR et recoupees avec la couverture reseau.
- [x] Correctif livre:
  - `Mon offre` affiche maintenant, en plus de la carte support existante, un bloc lecture seule `Offres affiliés à la charge de votre réseau` quand au moins une delegation `hors_cadre` active facturee a la TdR est remontee par le helper canonique;
  - le bloc affiche l'etat `Active`, le nombre d'offres, le montant agrégé HT/TTC et un lien `Voir le détail` vers `/account/network`;
  - aucun nouveau write path n'est ajoute;
  - aucune action affilié n'est deplacee vers `Mon offre`;
  - les CTA Stripe existants de la carte `Abonnement reseau` restent inchangés.
- [x] Rebaseline documentaire assumee:
  - il ne s'agit pas d'un correctif cache;
  - `Mon offre` est maintenant explicitement rouvert cote produit pour exposer cet agrégat `hors cadre`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-17 — Mon reseau: hiérarchie finale V1 UX simplifiée
- [x] Audit cible prouve:
  - point d'entree user-facing relu:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - helpers de lecture relus:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
      - `app_ecommerce_reseau_facturation_get_detail`
      - `app_ecommerce_reseau_contrat_couverture_get_detail`
      - `app_ecommerce_reseau_offres_hors_cadre_pricing_get`
      - `app_ecommerce_reseau_content_share_counts_get`
      - `app_ecommerce_reseau_pro_action_token_ensure`
  - cablage CTA relu:
    - `pro/web/ec/modules/general/branding/ec_branding_view.php`
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - base CSS / responsive relue:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
    - `pro/web/ec/includes/css/ec_custom.css`
    - `pro/web/ec/includes/css/ec_custom_20260131.css`
- [x] Constats confirmes:
  - `/account/network` affichait encore un couple `Synthese` + `Facturation` avant d'exposer le `Lien d'affiliation` et la personnalisation;
  - le tableau `Mes affiliés` restait visuellement plus bas que nécessaire et sa synthese utile etait dispersée;
  - les CTA metier affilies legitimes etaient deja branches sur les endpoints PRO prouvés et n'avaient pas a etre modifies.
- [x] Correctif livre:
  - le bloc `Facturation` est retire de `Mon reseau`;
  - le haut de page affiche maintenant d'abord `Lien d'affiliation`, avec bouton `Copier` visible et message d'aide dynamique selon abonnement reseau actif ou non;
  - le bloc `Personnalisation` expose immédiatement les CTA `Design reseau` et `Contenus reseau`, en conservant les routes deja retenues (`branding/view` et `library?network_manage=1`);
  - `Mes affiliés` devient le bloc central directement visible, avec titre `Mes affiliés (x)`, synthese compacte (`Actifs / Inactifs`, badge `Abonnement reseau`, `Inclus dans votre abn reseau / Places restantes`) et aide rattachee au tableau;
  - la logique metier des statuts, badges, filtres et actions (`Activer`, `Désactiver`, `Gerer l'offre`, `Commander`) reste inchangée;
  - la responsivite du tableau est durcie sans nouveau panneau fonctionnel: adaptation des largeurs, wrapping des contenus et scroll horizontal propre seulement en dernier recours sur petit mobile.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-17 — Mon reseau: la commande deleguee hors cadre reste disponible sans contrat reseau
- [x] Audit cible prouve:
  - point d'entree user-facing relu:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
    - `pro/web/ec/modules/compte/client/ec_client_network_script.php`
  - write/runtime global relu:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constats confirmes:
  - `Mon reseau` proposait deja `Commander` pour une TdR sans offre active sur l'affilie;
  - le POST tombait ensuite sur `Action refusée : contrat réseau introuvable.` car le runtime global imposait encore un contrat reseau resolu pour un flow purement `hors cadre`.
- [x] Correctif livre:
  - la commande deleguee `hors cadre` et le changement d'offre delegue ne dependent plus d'un contrat reseau automatique;
  - une TdR sans `ecommerce_reseau_contrats` peut maintenant lancer et finaliser un flux `hors cadre` depuis `Mon reseau`;
  - le comportement `cadre` / `Activer` via abonnement reseau reste inchangé et continue d'exiger un support reseau actif.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-17 — Contenu reseau V1: durcissement logique + réalignement canonique
- [x] Audit cible prouve:
  - write path de partage/retrait relu:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - lectures reseau relues:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - point d'entree user-facing relu:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Constats confirmes:
  - l'écriture serveur refusait deja un affilié via le helper `global`, mais le refus de `Retirer du réseau` restait generique cote `pro`;
  - les lectures réseau continuaient de s'appuyer sur des IDs de partage actifs sans revalider partout que la source restait exploitable;
  - la doc canonique gardait encore des formulations contradictoires sur un onglet réseau par catalogue pourtant abandonné ensuite le meme jour.
- [x] Correctif livre:
  - les POST `Partager avec mon réseau` / `Retirer du réseau` refusent maintenant explicitement toute tentative hors TdR proprietaire, y compris par URL directe / POST manuel;
  - les messages d'erreur distinguent maintenant `action reservee a la tete de reseau proprietaire` et `contenu n'est plus exploitable pour le reseau`;
  - la lecture réseau cote TdR, affilié, compteurs et chips ignore maintenant les contenus supprimés, inactifs ou non exploitables;
  - l'etat canonique retenu est clarifié dans la doc: entrée TdR via `/account/network` puis `library?network_manage=1`, entrée affilié via la carte portail `Jeux du réseau`, sans onglet réseau par catalogue.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK

## PATCH 2026-03-16 / 2026-03-17 — Contenu reseau V1: entrée TdR dédiée
- [x] Audit cible prouve:
  - point d'entree `/account/network` et bloc `Personnalisation` relus:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
    - `pro/web/ec/ec.php`
  - bibliothèque relue:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - write paths create/edit relus:
    - `pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_create.php`
    - `pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_edit.php`
    - `pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_save.php`
    - `pro/web/ec/modules/jeux/bibliotheque/sources/playlists.php`
    - `pro/web/ec/modules/jeux/bibliotheque/sources/quiz_series.php`
- [x] Constats confirmes:
  - le CTA `Contenus réseau` de `/account/network` est encore un placeholder desactive;
  - aucun scope source `network` n'existe aujourd'hui dans la bibliothèque;
  - les natures source restent `Cotton / Communauté / Mine`;
  - l'affiliation reseau et le client courant sont deja resolus via `clients.id_client_reseau` et le contexte offre effective `global`;
  - aucun besoin runtime `games` specifique n'est prouve pour cette V1.
- [x] Correctif livre:
  - le CTA `Contenus réseau` de `/account/network` ouvre maintenant une vraie page dédiée de management réseau, utile même à vide, sans imposer un choix de jeu en premier écran;
  - tant que la TdR reste sur ce parcours `network_manage=1`, la navigation gauche conserve l'état actif `Mon réseau` au lieu de basculer sur `Les jeux`;
  - cette page TdR regroupe les contenus déjà partagés tous jeux confondus, avec cartes réutilisant le style bibliothèque, type métier `Série / Playlist`, vérité de source `Cotton / Communauté / Mine`, et lien vers la fiche détail;
  - le header de cette page est allégé: lien `Retour à Mon réseau` au-dessus du titre, titre `Jeux du réseau`, puis sous-titre explicite;
  - le sous-titre reprend maintenant le style visuel utilisé sur `Mon réseau`;
  - un seul bloc haut de page reste affiché avec titre dynamique `Aucun jeu partagé / 1 jeu partagé / x jeux partagés avec ton réseau`, explication d'usage métier, CTA `Ajouter des jeux réseau` toujours visible et espacement renforcé sous le bloc;
  - la fiche contenu permet maintenant `Partager au réseau` / `Retirer du réseau`;
  - sur la fiche détail, l'action réseau quitte le bloc meta secondaire et rejoint les CTA principaux à côté de programmation / démo, avec wording `Partager avec mon réseau` / `Retirer du réseau`;
  - quand un contenu est partagé au réseau courant, la fiche détail affiche aussi au-dessus des CTA de programmation / démo une mention de recommandation réseau adaptée au contexte, avec un lien `Voir les jeux réseau` ; pour une playlist vue côté TdR, le libellé affiché est `Cette playlist est recommandée à vos affiliés.`;
  - les tags dédiés `Playlist / Série` et `Cotton / Communauté / Mine` sont retirés des cartes de la page TdR;
  - depuis une fiche détail ouverte dans ce contexte TdR, le lien de retour devient `Retour aux jeux du réseau` et revient directement vers `library?network_manage=1`, sans être réécrasé ensuite par le recalcul interne de `back_url`;
  - si la TdR démarre un quiz depuis une série partagée réseau, le flow sort volontairement du contexte `network_manage=1 + network_scope=shared` et ouvre la bibliothèque quiz standard (`game=quiz&builder=1`) pour permettre d'ajouter d'autres séries du catalogue complet;
  - l'affilié dispose maintenant d'une entrée lecture seule via la carte portail `Jeux du réseau`;
  - aucun nouveau scope source n'est introduit: l'origine du contenu reste portée par les modèles existants.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK
  - verification attendue en recette:
    - clic TdR `/account/network` -> `Contenus réseau` sans hub par jeu intermediaire;
    - TdR avec et sans contenus partages;
    - affilié avec carte portail `Jeux du réseau` visible;
    - affilié sans carte portail `Jeux du réseau`;
    - aucun write path réseau affiché côté affilié.

## PATCH 2026-03-17 — Bibliothèque: quitter `Les jeux` annule maintenant le builder quiz en memoire
- [x] Audit cible prouve:
  - stockage builder relu:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - contexte navigation relu:
    - `pro/web/ec/ec.php`
- [x] Constats confirmes:
  - le builder quiz est memorise en session serveur via `$_SESSION['library_quiz_builder']`;
  - les flux internes de bibliothèque savent deja l'annuler, mais un changement de menu hors `Les jeux` pouvait laisser ce builder actif en memoire.
- [x] Correctif livre:
  - `ec.php` purge maintenant automatiquement `library_quiz_builder` quand l'utilisateur charge un autre menu que le contexte bibliothèque conserve;
  - le builder reste en revanche intact pour les parcours `tunnel/start` explicitement ouverts depuis la bibliothèque, afin de ne pas casser les flows internes.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK

## PATCH 2026-03-17 — Bibliothèque: la chip `Reseau` des cartes TdR est isolee des autres badges
- [x] Audit cible prouve:
  - rendu des cartes catalogue relu:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - palette visuelle repo relue:
    - `pro/web/ec/includes/css/ec_custom.css`
- [x] Constats confirmes:
  - la chip `Réseau` etait empilee en haut du visuel au meme endroit que `Populaire` / `En ce moment`;
  - ce placement provoquait des confrontations visuelles et des bugs d'empilement sur certaines cartes TdR.
- [x] Correctif livre:
  - la chip `Réseau` est maintenant rendue en bas a gauche du visuel pour la separer des autres badges deja presents en haut;
  - elle reutilise une couleur deja presente dans le repo (`#FFDB03` avec texte `#240445`) pour rester coherente avec l'existant tout en etant bien distincte.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## PATCH 2026-03-17 — Bibliothèque: hub global reseau affilie puis portail final sans onglet reseau
- [x] Audit cible prouve:
  - hub bibliothèque et scopes relus:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - helper d'agregation relu:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
- [x] Constats confirmes:
  - le hub global `library?network_manage=1` existait deja, mais etait reserve a la TdR;
  - l'affilié ne disposait que d'un onglet reseau par jeu, sans acces global tous jeux confondus;
  - la TdR n'avait pas encore de portail global suffisamment explicite depuis la bibliothèque.
- [x] Correctif livre:
  - un affilié avec au moins un contenu reseau peut maintenant ouvrir aussi `library?network_manage=1` comme hub global lecture seule;
  - l'entree bibliothèque sans jeu affiche dans ce cas un bloc pleine largeur `Jeux du réseau` avec CTA vers ce hub global;
  - ce hub affilié reutilise l'agregation transverse existante, sans changer la persistance V1;
  - cet etat intermediaire a ensuite ete remplace par la carte portail `Jeux du réseau`; aucun onglet réseau par catalogue n'est retenu comme état final;
  - une fiche détail ouverte depuis le hub global reseau, cote TdR comme cote affilié, revient maintenant vers `library?network_manage=1`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## PATCH 2026-03-17 — Bibliothèque: bloc portail `Jeux du réseau` pour TdR + affilié, sans onglet par catalogue
- [x] Audit cible prouve:
  - portail bibliothèque et cartes catalogue relus:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- [x] Constats confirmes:
  - le bloc `Jeux du réseau` du portail bibliothèque n'etait visible que pour l'affilié;
  - l'onglet `Playlists / Séries du réseau` par catalogue ajoutait une navigation secondaire devenue redondante avec ce portail global;
  - la chip `Réseau` sur carte n'etait calculee que pour la TdR, pas pour l'affilié.
- [x] Correctif livre:
  - le portail bibliothèque affiche maintenant aussi une carte cliquable `Jeux du réseau` pour la TdR, ouvrant directement la page de gestion réseau;
  - cette carte reutilise le pattern des blocs de choix de jeu, sans CTA séparé, et reste bornée a la meme largeur de colonne que les cartes jeu;
  - l'onglet `Playlists / Séries du réseau` est retire des catalogues jeu, cote affilié comme cote TdR;
  - la chip `Réseau` sur les cartes catalogue est maintenant visible a partir du proprietaire reseau effectif, donc cote affilié comme cote TdR.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## PATCH 2026-03-17 — Bibliothèque: carte portail `Jeux du réseau` en pleine largeur + wording final
- [x] Audit cible prouve:
  - rendu du portail bibliothèque relu:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- [x] Correctif livre:
  - la carte portail `Jeux du réseau` passe maintenant sur toute la largeur disponible sous les 3 blocs jeu;
  - son rendu utilise des coins plus arrondis;
  - le titre reprend maintenant `Les jeux {nom_compte_TdR}` avec le nom du compte injecté;
  - le texte affilié est `Accède rapidement aux jeux sélectionnés par ton réseau !`;
  - le texte TdR est `Accède directement à la gestion des jeux que tu partages avec ton réseau.`
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## PATCH 2026-03-17 — Bibliothèque: carte portail `Jeux du réseau` alignee visuellement + visuel branding reseau
- [x] Audit cible prouve:
  - portail bibliothèque relu:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - lecture branding reseau relue:
    - `global/web/app/modules/general/branding/app_branding_functions.php`
    - `pro/web/ec/modules/general/branding/ec_branding_view.php`
- [x] Correctif livre:
  - le doublon de titre de la carte portail est retire;
  - la carte est maintenant centree sur une largeur visuelle alignee avec les 3 cartes jeu du dessus, au lieu de prendre tout le container;
  - si un visuel de design reseau existe, il est reutilise sur cette carte;
  - sinon la carte retombe sur un visuel generique `cotton-media-kit-portail.jpg`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## PATCH 2026-03-17 — Bibliothèque: carte portail `Jeux du réseau` avec visuel a gauche et texte a droite
- [x] Audit cible prouve:
  - layout de la carte portail relu:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- [x] Correctif livre:
  - le visuel reseau (ou son fallback) passe maintenant a gauche de la carte;
  - le texte est affiche a droite, avec alignement responsive centre sur mobile puis gauche sur desktop.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## PATCH 2026-03-17 — Bibliothèque reseau TdR: 3 CTA jeu colores remplacent `Ajouter des jeux reseau`
- [x] Audit cible prouve:
  - bloc d'action TdR relu:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - helper d'agregation de la vue globale reseau relu:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
- [x] Correctif livre:
  - le CTA unique `Ajouter des jeux réseau` est remplace par 3 CTA dedies:
    - `Ajouter un Blind Test partagé`
    - `Ajouter un Bingo Musical partagé`
    - `Ajouter un Cotton Quiz partagé`
  - chaque CTA reprend la couleur du jeu et ouvre le catalogue cible hors contexte `network_manage=1`, pour laisser la TdR parcourir, creer et choisir librement ce qu'elle partage ensuite au réseau.
  - dans la vue globale `Jeux du réseau`, une meme playlist partagee a la fois sur `Blind Test` et `Bingo Musical` remonte maintenant deux fois, une carte par jeu partage, au lieu d'etre fusionnee.
  - les cartes de cette vue globale reseau affichent maintenant les memes metadonnees utiles que les cartes catalogue standard: difficulte, auteur et historique d'usage du client connecte.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## PATCH 2026-03-16 — Design reseau TdR: refonte de la page branding PRO
- [x] Audit cible prouve:
  - route / write path existants relus:
    - `pro/web/ec/modules/general/branding/ec_branding_view.php`
    - `pro/web/ec/modules/general/branding/ec_branding_form.php`
    - `pro/web/ec/modules/general/branding/ec_branding_script.php`
  - point d'entree relu:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - reference UX/runtime games relue:
    - `games/web/includes/canvas/core/session_modals.js`
    - `games/web/organizer_canvas.php`
    - `games/web/player_canvas.php`
    - `games/web/includes/canvas/play/play-ui.js`
- [x] Structure confirmee:
  - la TdR cree deja un branding type `3` via la route branding PRO historique;
  - la resolution canonique reste `session > evenement > reseau > client`;
  - les champs effectivement consommes cote games restent `background_1`, `background_2`, `font family/url`, `logo`, `visuel`.
- [x] Correctif livre:
  - la route branding PRO existante est conservee comme socle technique;
  - la page `Design reseau` cote TdR est refondue en experience dediee, avec retour `Mon reseau`, etat actuel, formulaire repense, apercu inspire de l'attente de session et actions explicites;
  - le preview applique maintenant aussi la police choisie aux titres `Cotton Games` et `Lots a gagner !`.
  - ajustement de layout: dans `Identité visuelle`, le champ `Police` passe maintenant sur sa propre ligne entre les couleurs et le logo.
  - le bloc `Personnalisation` de `/account/network` expose maintenant aussi l'etat `Actif / Actif jusqu'au ... / Expire / Aucun design reseau personnalise`;
  - la date optionnelle `valable_jusqu_au` est prise en charge dans le formulaire et dans les textes d'etat;
  - l'action `Reinitialiser le design reseau` supprime proprement la couche reseau personnalisee.
  - la vue `Design reseau` est aussi simplifiee cote microcopy: suppression du CTA header, suppression des aides redondantes `Etat actuel` / `Source effective`, et alignement des libelles `Personnalisé / Par defaut`.
  - la `view` integre maintenant aussi la `Date limite de validite` et les CTA `Creer / Modifier mon design reseau` directement dans le bloc de parametres; sans date, la vue affiche simplement `Aucune`.
  - l'encart d'aperçu explicite maintenant l'usage du design sur l'interface principale et mobile des jeux, et l'action destructive est renommee `Supprimer ce design` avec un bouton plein plus lisible en `view` comme en `form`.
  - ajustement final des CTA: la `view` affiche maintenant `Modifier` et `Supprimer` cote a cote, tandis que la page de modification ne propose plus de CTA `Supprimer`.
  - la page de modification reprend maintenant la microcopy corrigee de la `view`, retire le bloc `Etat actuel` et les aides grises redondantes, et remplace le couple `Police + URL Google Fonts` par un picker inspire de games (`liste de base + Ajouter une police…`).
  - le flux `Ajouter une police…` donne maintenant une consigne claire a l'utilisateur (nom exact Google Fonts, exemples) et propose un lien direct vers Google Fonts.
  - micro-ajustement final: la consigne police est raccourcie et le bouton `Ouvrir Google Fonts` passe en style plein pour rester lisible sur ce theme.
  - le formulaire de modification est maintenant recompose en sections proches de l'UI games: `🖼️ Visuel personnalisé`, `🎨 Identité visuelle`, puis `Réseaux sociaux` en placeholder pour la suite.
  - les champs `Visuel du réseau` et `Logo reseau` affichent maintenant une aide conditionnelle pour conserver le media actuel quand aucun nouveau fichier n'est envoyé.
  - le champ `Valable jusqu’au` reste dans le contenu du bloc de parametrage et affiche une aide courte: sans date, le design reste actif jusqu'a sa suppression.
  - en `view` comme en `form`, les actions principales passent maintenant dans un bandeau bas du bloc, sur un pattern proche des cartes d'entree de la bibliotheque; la date de validite reste dans le contenu, et le footer est dedie a des CTA centres et plus espaces.
  - cote `form`, l'action `Supprimer la date` quitte le bandeau bas pour devenir une action legere rattachee directement au champ de date.
  - la `view` reprend maintenant la meme structure de sections que la `form` (`Visuel personnalisé`, `Identité visuelle`, `Réseaux sociaux`) avec un rendu ferme et coherent.
  - la `view` affiche maintenant aussi un mini bloc couleur a cote des valeurs hex de `Couleur principale` et `Couleur secondaire`.
- [x] Garde-fous:
  - pas de nouveau point d'entree concurrent;
  - pas de changement de priorite de resolution;
  - pas de duplication vers les affiliés;
  - pas de rupture du branding client hors scope.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_view.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_form.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_preview.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
- [x] Correctif post-recette logs:
  - les logs `pro/error_log` ont confirme que `ec_branding_script.php` lisait a tort `$app_client_detail['flag_client_reseau_siege']` hors contexte, ce qui faisait retomber une TdR sur `id_type_branding = 4` au lieu de `3`;
  - le script resolve maintenant de maniere defensive le client courant (`$app_client_detail`, sinon `$client_detail`, sinon `app_client_get_detail($_SESSION['id_client'])`) avant de choisir le type reseau;
  - la previsualisation utilise aussi un fallback image PRO existant pour supprimer le 404 sur `branding-evenement-default.jpg`.
- [x] Correctif logo runtime:
  - le logo reseau uploadé depuis PRO etait recadré par le write path image, alors que le header games l'affiche en `object-fit: contain`;
  - le write path logo reseau n'impose plus de hauteur de crop: il redimensionne maintenant seulement en largeur, sans recadrage lateral.
- [x] Correctif save logo final:
  - en cas d'upload invalide ou mal normalise, le flux PRO pouvait purger l'ancien logo avant d'avoir confirme le nouveau fichier;
  - le write path branding reseau s'aligne maintenant sur la logique games/ajax pour normaliser le media par MIME/extension avant upload;
  - le core upload PRO accepte desormais `jpg|jpeg|png|webp`;
  - la restauration automatique d'un ancien logo pendant le save a finalement ete retiree, car elle faisait reapparaitre un media precedent au lieu de coller au comportement historique du module.
- [x] Instrumentation post-recette:
  - ajout de logs cibles `[branding:save]` dans `ec_branding_script.php` pour tracer le contexte du POST et les metadonnees du fichier envoye;
  - ajout de logs cibles `[branding:upload]` dans le helper global pour tracer normalisation, chemin cible, etat des fichiers avant/apres unlink puis apres upload.
- [x] Diagnostic final:
  - les logs prouvent que le save PRO reecrit bien le nouveau fichier branding;
  - le retour visuel vers l'ancien logo provenait d'une URL de logo stable relue via cache;
  - la lecture branding versionne maintenant `logo` et `visuel` avec `filemtime` pour afficher immediatement le media fraichement ecrit.

## PATCH 2026-03-16 — Mon reseau: confirmer les actions Activer / Désactiver d'un affilié
- [x] Audit cible prouve:
  - symptome fonctionnel:
    - les actions `Activer via l'abonnement` et `Désactiver` partaient directement sans rappel explicite de leur effet sur l'abonnement reseau
  - dependance:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Correctif livre:
  - `Activer via l'abonnement` devient `Activer`;
  - chaque CTA affiche une mention explicative sous le bouton;
  - les deux actions ouvrent maintenant une modale de confirmation avec `Confirmer` et `Annuler`.
  - les modales sont partagees hors du tableau et hydratees en JS a l'ouverture, ce qui corrige le rendu bloque observe avec des modales injectees dans les lignes du tableau.
  - le bouton `Annuler` utilise `btn-secondary` pour eviter le rendu transparent sur ce theme.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-16 — Factures PDF: corriger le symbole euro dans le tableau
- [x] Audit cible prouve:
  - symptome fonctionnel:
    - le tableau PDF affichait `â‚¬` au lieu de `€` dans les colonnes `PU HT` et `PRIX TOTAL HT`
  - dependances:
    - `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
    - `www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`
- [x] Correctif livre:
  - les vues PDF utilisent maintenant `chr(128)` pour le symbole euro dans ces cellules, compatible avec l'encodage FPDF de ces fichiers legacy.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php` OK

## PATCH 2026-03-16 — Mon reseau: ajouter un acces aux factures affiliés depuis le bloc Facturation
- [x] Audit cible prouve:
  - symptome fonctionnel:
    - `Mon offre` ne liste pas les offres deleguees, ce qui laisse peu de points d'entree vers les factures liees aux offres affiliées hors cadre
  - dependance:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Correctif livre:
  - le bloc `Facturation` de `Mon réseau` affiche maintenant `Voir les factures affiliés` sous le montant agrege;
  - le lien est visible uniquement s'il existe au moins une offre deleguee hors cadre active.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-16 — Factures PDF: utiliser le nouveau logo EC pro
- [x] Audit cible prouve:
  - symptome fonctionnel:
    - les factures PDF utilisaient encore l'ancien visuel `cotton-quiz-pdf.jpg` au lieu du logo du header EC pro
  - dependances:
    - `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
    - `www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`
- [x] Correctif livre:
  - les vues PDF PRO et BO chargent maintenant `cotton-pro-logo-lg.png`;
  - le rendu utilise un format `24x24` adapte au nouveau logo carre.
- [x] Correctif runtime complementaire:
  - le chemin image utilise par FPDF reste relatif au script, pour rester compatible avec l'arborescence serveur `/var/www/...` et eviter l'erreur `Can't open image file`.
- [x] Correctif runtime final:
  - les deux vues PDF derivent maintenant la racine PRO a partir de `public`, ce qui evite la cle absente `pro_root` et supprime aussi la resolution fragile des chemins relatifs cote BO.
  - un fallback sur `cotton-quiz-pdf.jpg` evite un fatal FPDF si le nouveau logo n'est pas trouve.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php` OK

## PATCH 2026-03-16 — Factures TdR: afficher l'affilie facture pour les offres deleguees
- [x] Audit cible prouve:
  - symptome fonctionnel:
    - dans `Mes factures`, plusieurs factures TdR d'offres deleguees `hors cadre` pouvaient etre difficiles a distinguer quand elles partageaient le meme montant
  - dependances:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - `pro/web/ec/modules/compte/factures/ec_factures_list.php`
    - `www/web/bo/www/modules/ecommerce/factures/bo_factures_list.php`
- [x] Correctif livre:
  - la liste affiche maintenant aussi `Affilié : <nom>` pour les commandes portant une offre deleguee;
  - les nouvelles factures PDF reprennent aussi ce libelle sous la ligne produit;
  - les vues PDF enrichissent aussi le rendu des factures deja generees.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_list.php` OK

## PATCH 2026-03-16 — Mon reseau: l'activation d'un affilié sans offre active doit ignorer l'historique legacy
- [x] Audit cible prouve:
  - symptome fonctionnel:
    - une TdR avec abonnement reseau actif et quota disponible pouvait encore voir une activation manuelle retomber en `hors_cadre` sur un affilié pourtant sans offre active, a cause de son historique BO
  - dependance:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - les resolutions runtime et la sync legacy privilegiaient une delegation active legacy plus recente au lieu de prioriser la ligne deja rattachee au support reseau courant.
- [x] Correctif livre:
  - la resolution des delegations actives d'un affilié donne maintenant la priorite a la ligne active liee au support courant.
- [x] Effet attendu:
  - la TdR peut activer via l'abonnement reseau l'affilie sans offre active de son choix, quel que soit son historique.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-16 — Mon reseau / signup affilié: les activations incluses doivent rester en `cadre`
- [x] Audit cible prouve:
  - symptome fonctionnel:
    - `Activer via l'abonnement` et le lien d'affiliation reseau pouvaient recreer une offre deleguee `hors cadre` alors qu'une place incluse etait disponible
  - dependance:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - l'ecriture de l'activation reseau degradiait parfois une demande `cadre` en `hors_cadre` a cause d'un contexte contrat incomplet.
- [x] Correctif livre:
  - l'ecriture recharge maintenant le contrat runtime complet avant de calculer le `mode_facturation` effectif.
- [x] Durcissement complementaire:
  - le calcul du mode effectif repasse aussi par l'etat contrat runtime resolu avec `id_client_siege`, ce qui evite un rabattement parasite en `hors_cadre` quand le lien contrat/support est stale.
- [x] Durcissement lecture/runtime:
  - la couverture reseau et la sync legacy reclassent maintenant aussi une offre en `cadre` via son rattachement explicite au support reseau courant (`reseau_id_offre_client_support_source`), ce qui stabilise le rendu BO/PRO meme si `mode_facturation` n'est pas encore fiable.
- [x] Effet attendu:
  - une affiliation via lien reseau avec support actif cree de nouveau une offre incluse `cadre`;
  - sans support actif, l'affiliation ne cree toujours aucune offre.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-16 — Mon reseau: simplifier la gestion des offres deleguees hors cadre
- [x] Audit cible prouve:
  - symptome fonctionnel:
    - la page `Mon réseau` proposait encore un menu d'actions `Gérer l'offre` avec des chemins `Changer d'offre` / `Réactiver mon offre` pour les offres deleguees `hors cadre`
  - dependances:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Realignement metier livre:
  - une offre deleguee `hors cadre` active ne peut plus etre modifiee ni reactivee depuis `Mon réseau`;
  - le CTA `Gérer l'offre` ouvre directement le portail Stripe dedie a la resiliation quand aucune fin de periode n'est deja programmee;
  - si la resiliation est deja planifiee, seule la mention `Cet abonnement sera résilié au ...` reste affichee.
- [x] Correctif SI complementaire:
  - la couverture reseau ne reclasse plus automatiquement une offre `hors cadre` active en `cadre`;
  - seules les activations manuelles d'affiliés sans offre utilisent maintenant le quota reseau disponible.
- [x] Invariant V1 fige:
  - aucune evolution documentaire future ne doit reintroduire `Changer d'offre`, upsell/downsell ou `subscription_update` comme parcours final cote `hors_cadre`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-16 — Portail Stripe reseau: resiliation support visible sans ecriture parasite
- [x] Audit cible prouve:
  - symptome:
    - le portail reseau ouvrait encore avec erreur Stripe indiquant que `subscription update` etait desactive
  - dependance write path:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - le portail support reseau devait afficher proprement la souscription support existante sans provoquer de lecture metier fausse sur les offres deleguees.
- [x] Correctif livre:
  - le portail support reseau reste borne a la souscription support ciblee;
  - une fin de periode du support reste visible cote `Mon offre` / `Offres & factures`;
  - cette visibilite ne cree pas de support `En attente` et ne modifie aucune delegation `hors_cadre`.
- [x] Realignement metier:
  - pour un abonnement reseau actif, le CTA `Gerer mon abonnement` ouvre maintenant un flux Stripe de resiliation (`subscription_cancel`), pas de modification;
  - cote offres deleguees `hors_cadre`, aucun portail `manage`, aucune reactivation dediee et aucun changement d'offre ne sont retenus en V1.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — Signup affilié reseau: ignorer les delegations orphelines d'affiliés supprimes
- [x] Audit cible prouve:
  - symptome fonctionnel:
    - le signup affilié restait bloque alors que les places reelles disponibles cote TdR semblaient libres
  - dependance write path:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - le quota reseau comptait encore des offres deleguees rattachees a des affiliés supprimes du SI via le BO;
  - la creation de l'offre incluse echouait donc a tort sur `quota_reached`.
- [x] Correctif livre:
  - la couverture reseau et la sync legacy n'integrent plus les delegations dont `id_client_delegation` n'existe plus dans `clients`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — Signup affilié reseau: ne plus lancer de reclassement global avant l'activation incluse
- [x] Audit cible prouve:
  - point d'entree PRO:
    - `pro/web/ec/modules/compte/client/ec_client_script.php`
  - dependances write path:
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - juste apres l'affiliation reseau, `client_affilier()` relancait encore un reclassement global;
  - ce recalcul arrivait trop tot pour le parcours `signup_affiliation`, qui a deja son activation incluse dediee.
- [x] Correctif livre:
  - l'affiliation signup n'execute plus ce reclassement preliminaire;
  - l'activation explicite incluse garde la main sur la creation d'offre, le refresh reseau et la sync pipe.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — Signup affilié reseau: l'offre incluse ne doit plus sortir immediatement `Terminee`
- [x] Audit cible prouve:
  - symptome constate depuis le parcours `signup` affilié sous abonnement reseau
  - dependance write path:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - le point d'entree PRO appelait un write path global qui pouvait reclasser `hors_cadre -> cadre` en reutilisant la ligne source comme cible equivalente;
  - la source etait ensuite cloturee par son propre remplacement.
- [x] Correctif livre:
  - pas de changement de flux PRO;
  - le helper global exclut maintenant explicitement la source pendant la creation cible de reclassement et bloque toute cible identique a la source;
  - les hooks post-create immediats ont aussi ete coupes sur ce parcours reseau pour eviter une recursion `create -> refresh -> reclassify` dans la meme requete.
- [x] Correctif complementaire livre:
  - le reclassement global est maintenant non reentrant pour la meme TdR dans une requete;
  - le remplacement reseau ne relance plus deux refresh cibles qui rouvraient du reclassement imbrique.
- [x] Correctif d'orchestration livre:
  - pour `signup_affiliation`, le write path global cree maintenant directement l'offre incluse en `cadre` via l'activation explicite `included`;
  - ce parcours ne repasse plus par `create + reclassify + replace`.
- [x] Ajustement final livre:
  - `signup_affiliation` saute aussi le reclassement final interne du helper d'activation explicite;
  - l'objectif est de supprimer la seconde ligne residuelle immediatement `Terminee`.
- [x] Effet de bord corrige:
  - le pipe affilié est de nouveau resynchronise apres activation explicite;
  - le parcours de signup affilié retrouve donc la bascule `ABN/PAK` selon l'offre deleguee active.
- [x] Ajustement final:
  - le parcours `signup_affiliation` ne bloque plus sur une jauge cible reseau non encore resolue dans la couverture;
  - l'offre deleguee peut a nouveau etre creee avec le fallback de jauge du helper global.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — Signup pro: page blanche sur `establishment/script`
- [x] Audit cible prouve:
  - `pro/web/ec/modules/compte/client/ec_client_script.php`
  - dependances relues:
    - `global/web/global_librairies.php`
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - preuve log:
    - `pro/logs/error_log` a `2026-03-15 17:27:02` et `17:27:18` avec fatal `ai_studio_email_transactional_send()`
- [x] Cause confirmee:
  - le flux de creation arrivait bien jusqu'a l'envoi transactionnel;
  - la fonction n'etait pas chargee de facon fiable depuis `pro` a cause d'un `require` relatif fragile.
- [x] Correctif livre:
  - fiabilisation du loader global via `__DIR__`;
  - garde sur `id_remise` pour supprimer le bruit restant dans ce flux.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_script.php` OK
  - `php -l /home/romain/Cotton/global/web/global_librairies.php` OK

## PATCH 2026-03-15 — Signup affilié reseau: audit de sur-creation des offres incluses
- [x] Audit cible prouve:
  - `pro/web/ec/modules/compte/client/ec_client_script.php`
  - dependance write path:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - preuve log:
    - `pro/logs/error_log` sur `id_client=2054` avec une rafale d'offres deleguees `7426` -> `8123`
- [x] Cause confirmee:
  - le signup affilié appelait bien le write path d'affiliation reseau;
  - l'idempotence manquait ensuite cote global sur l'auto-attribution et la creation de delegation.
- [x] Correctif livre:
  - pas de changement de flux PRO, mais le point d'entree a ete revalide;
  - la duplication est maintenant bloquee dans le write path global appele par ce signup.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — Pro dev: invalider les sessions auth dont le client n'est plus resolu
- [x] Audit cible prouve:
  - `pro/web/ec/ec.php`
  - `pro/web/ec/ec_signup.php`
  - `pro/web/ec/ec_signin.php`
  - preuve log exploitable:
    - `pro/logs/error_log` sur `/extranet/dashboard` (`Trying to access array offset on value of type null` dans `ec.php`, widgets home et helpers client)
- [x] Cause confirmee:
  - une session pouvait rester authentifiee avec `id_client_contact`, mais sans detail client exploitable;
  - `ec.php` continuait alors le rendu avec `client_detail` nul, ce qui degradant plusieurs widgets pouvait produire un chargement sans issue visible.
- [x] Correctif livre:
  - purge de la session et redirection `signin` si `app_client_get_detail()` ne renvoie plus de client exploitable;
  - gardes sur `id_client_reseau` et `CQ_admin` dans `signup`/`signin`;
  - uniformisation locale du flag admin pour eviter les lectures brutes de session.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/ec_signup.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/ec_signin.php` OK

## PATCH 2026-03-15 — Boucle dev `signin/dashboard`: nettoyer les sessions partielles
- [x] Audit cible prouve:
  - `pro/web/ec/ec_signin.php`
  - `pro/web/ec/do_script.php`
  - preuve logique:
    - `ec_signin.php` redirige vers `dashboard` des qu'un `id_client` existe;
    - `ec.php` n'autorise l'entree extranet que si `id_client_contact` existe;
    - un signup interrompu pouvait donc laisser une session partielle et creer une boucle `signin -> dashboard -> signin`.
- [x] Correctif livre:
  - purge defensive des sessions `id_client`/`id_client_contact` incoherentes dans `ec_signin.php`;
  - gardes `isset` sur `id_client_contact` et les cookies BO dans `do_script.php`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_signin.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/do_script.php` OK

## PATCH 2026-03-15 — Acces pro dev: gardes notices sur signin/auth/dashboard
- [x] Audit cible prouve:
  - `pro/web/ec/ec_signin.php`
  - `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
  - `pro/web/ec/ec.php`
  - dependance relue:
    - `global/web/app/modules/entites/clients_branding/app_clients_branding_functions.php`
  - preuve log:
    - `pro/logs/error_log` (`id_client_reseau`, `CQ_admin_gate_client_id`, `app_jeu_detail`, `app_session_detail`)
- [x] Causes confirmees:
  - plusieurs chemins dev lisaient des indexes session/cookies non garantis;
  - un log de session demo supposait deux variables toujours renseignees;
  - le menu branding relisait directement un cookie absent.
- [x] Correctif livre:
  - `signin` garde maintenant `id_client_reseau` et `CQ_admin`;
  - l'authentification BO ne lit plus `CQ_admin_gate_*` sans `isset`;
  - le log de session demo ne s'exécute plus sans contexte complet;
  - le menu branding n'affiche sa condition cookie que si l'index existe.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_signin.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/authentification/ec_authentification_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_branding/app_clients_branding_functions.php` OK

## PATCH 2026-03-15 — Signup pro dev: suppression du fatal `ai_studio_email_transactional_send()`
- [x] Audit cible prouve:
  - `pro/web/ec/modules/compte/client/ec_client_script.php`
  - dependance relue:
    - `global/web/global_librairies.php`
    - `global/web/ai_studio/workflows/crm/1_emails_transactional/ai_studio_emails_transactional_functions.php`
- [x] Cause confirmee:
  - le script de creation d'etablissement appelle la fonction transactionnelle AI Studio, mais celle-ci n'etait pas chargee en dev a cause d'un chemin de loader obsolete;
  - l'appel faisait donc tomber tout le flux sur un fatal au moment du signup.
- [x] Correctif livre:
  - le chargement global recolle au vrai dossier `1_emails_transactional`;
  - l'URL webhook transactionnelle est alignee sur ce meme dossier.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/global_librairies.php` OK
  - `php -l /home/romain/Cotton/global/web/ai_studio/workflows/crm/1_emails_transactional/ai_studio_emails_transactional_functions.php` OK

## PATCH 2026-03-15 — `Mon offre` reseau: le CTA Stripe cible la souscription support
- [x] Audit cible prouve:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - dependance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Causes confirmees:
  - le CTA `Gerer mon abonnement` d'une tete de reseau ouvrait le portail Stripe global du client, pas un deep-link sur la souscription support;
  - le titre visible cote Stripe restait sur un ancien libelle `Offre reseau support`.
- [x] Correctif livre:
  - `Mon offre` demande maintenant explicitement une session portail ciblee sur l'offre support reseau courante;
  - l'entree reste limitee a l'offre d'abonnement reseau courante;
  - le headline portail reseau est aligne cote Stripe sur `Cotton - Abonnement reseau`;
  - ce lot ne doit plus etre relu comme l'ouverture d'un parcours de modification de plan en V1.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — SI reseau: une hors cadre absorbee par le support ne doit plus survivre comme meme offre
- [x] Audit cible prouve:
  - dependance metier relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - preuve terrain:
    - demande metier explicite apres observation d'offres deleguees `hors cadre` reclassifiees dans le support reseau sans vraie cloture SI
- [x] Correctif livre:
  - le passage `hors cadre -> cadre` recree maintenant une nouvelle offre incluse des que l'offre active n'est pas deja rattachee au support reseau courant;
  - l'ancienne offre est cloturee via le write path de remplacement existant, ce qui nettoie l'historique et limite les effets de bord.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Confirmation reseau: retirer le lien inline `Gerer mon reseau`
- [x] Audit cible prouve:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Cause confirmee:
  - la confirmation commande reseau affichait a la fois un lien inline `Gerer mon reseau` dans le bloc detail et un CTA principal `Acceder a Mon reseau`.
- [x] Correctif livre:
  - le lien inline reste disponible hors tunnel, mais est masque en contexte confirmation commande;
  - le CTA principal bas de bloc reste la seule sortie `Mon reseau` sur `manage/s3`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-13 — Confirmation reseau `manage/s3`: id offre restaure au retour Stripe
- [x] Audit cible prouve:
  - `pro/web/ec/modules/compte/offres/ec_offres_script.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php`
  - dependance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - le flux de paiement d'abonnement reseau n'alimentait pas `id_securite_offre_client_paiement_cb`;
  - la page de retour ouvrait donc `manage/s3/` sans identifiant, laissant le bloc resume vide.
- [x] Correctif livre:
  - `pay_network_support` memorise maintenant l'`id_securite` de l'offre support avant depart vers Stripe;
  - le step 3 sait aussi retrouver l'offre support reseau courante si le retour arrive encore sans identifiant;
  - le correctif UX reseau du step 3 reste applique (CTA `Mon reseau`, agenda masque).
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Confirmation Stripe reseau: masquer agenda et pousser vers `Mon reseau`
- [x] Audit cible prouve:
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php`
  - dependance relue:
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
    - `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`
- [x] Causes confirmees:
  - le step 3 de confirmation reutilisait le bloc detail en contexte tunnel, ce qui laissait un titre peu exploitable pour un abonnement reseau;
  - le widget agenda restait affiche pour des confirmations reseau ou deleguees qui doivent plutot renvoyer vers `Mon reseau`.
- [x] Correctif livre:
  - le step 3 detecte maintenant les confirmations d'abonnement reseau et d'offre deleguee `hors cadre`;
  - dans ces cas, le widget agenda est masque et un CTA `Acceder a Mon reseau` est ajoute;
  - pour l'abonnement reseau, l'entete du bloc detail reprend le libelle utile `Abonnement reseau`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-13 — `Mon offre`: essai Stripe actif affiche la fin d'essai, pas la periode abonnement
- [x] Audit cible prouve:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - dependance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - en statut Stripe `trialing`, la fiche `Mon offre` affichait encore `Abonnement du ... au ...` puis une mention separee `Offre d'essai en cours`;
  - cette copie n'etait pas coherente avec le portail Stripe qui affiche la fin d'essai effective.
- [x] Correctif livre:
  - pour un abonnement avec periode d'essai active, la ligne metier devient `Offre d'essai en cours jusqu'au ...`;
  - la mention redondante sous le CTA portail Stripe est supprimee;
  - apres la fin de l'essai, la ligne standard `Abonnement du ... au ...` redevient visible sans autre condition.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Checkout standard: creation du prix Stripe catalogue si absent
- [x] Audit cible prouve:
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - dependance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - preuve log complementaire:
    - `pro/logs/error_log` avec `reason=stripe_price_not_found ; detail=ABN100M` encore present apres le premier patch
- [x] Cause confirmee:
  - la resolution standard ne pouvait toujours rien renvoyer si le `Price` catalogue n'existait pas du tout dans l'environnement Stripe courant;
  - un pre-checkout SQL generait aussi un bruit `fetch_assoc()` juste avant la preparation de commande.
- [x] Correctif livre:
  - en fallback strict sur `price_not_found`, le tunnel standard cree maintenant le `Price` Stripe catalogue manquant avec le meme `lookup_key`, le TTC courant et la bonne recurrence;
  - le log d'echec remonte des raisons plus precises si cette creation echoue encore;
  - le write path amont ne fait plus de `fetch_assoc()` sur une requete SQL invalide.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Checkout standard: lookup Stripe robuste hors reseau
- [x] Audit cible prouve:
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - dependance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - preuves log:
    - `pro/logs/error_log` avec `reason=stripe_price_not_found ; detail=ABN100A`
    - `pro/logs/error_log` avec `reason=stripe_price_not_found ; detail=ABN100M`
- [x] Cause confirmee:
  - le checkout standard retrouvait le `price_id` Stripe via `Price::search` uniquement;
  - sur plusieurs commandes catalogue standard, cette recherche ne remontait plus les tarifs attendus alors que les cles catalogue restaient connues.
- [x] Correctif livre:
  - le checkout standard reutilise maintenant un helper global qui resolve d'abord les prix Stripe via `lookup_keys`, puis via un fallback `search`;
  - les echecs lies a `ABN100A` / `ABN100M` ne doivent plus rebondir sur `stripe_standard_checkout_error` tant que le tarif Stripe existe bien dans l'environnement courant.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — `Mon reseau`: doublon `€` retire dans `Mes affilies`
- [x] Audit cible prouve:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - dependance relue:
    - `global/web/lib/core/lib_core_use_functions.php`
- [x] Cause confirmee:
  - le rendu `Tarif` concatenait ` € HT` apres `montant(...)`;
  - `montant(...)` renvoie deja la devise, ce qui produisait `84,92 € € HT / mois`.
- [x] Correctif livre:
  - le detail `Tarif` reutilise maintenant `montant(..., '€', 'HT', 1)` pour afficher `HT` sans ajouter un second symbole devise;
  - le fallback sans suffixe est aligne sur le meme rendu.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-13 — Mon réseau: mention explicite de résiliation planifiée
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Correctif livré:
  - ajout d'une mention UI `Cet abonnement sera résilié au ...` juste au-dessus du CTA `Réactiver mon offre` pour une offre déléguée `hors cadre` résiliée mais encore active.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-13 — Mon réseau: hypothese multi-voies portail affiliées abandonnee (historique)
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - dépendances relues:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- [x] Decision historique desormais depassee:
  - ce lot explorait encore plusieurs voies portail / reactivation cote affiliation.
- [x] Correctif livré:
  - seule la resiliation explicite d'une delegation `hors_cadre` reste a conserver comme verite finale;
  - toute logique de reactivation dediee doit etre lue comme abandonnee pour V1.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-13 — Mon réseau: variantes portail Stripe dediees pour les offres affiliees `hors cadre` (historique abandonne)
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - dépendances relues:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- [x] Constat confirmé:
  - la résiliation unitaire d'une offre déléguée `hors cadre` ne devait plus partager la même configuration portail Stripe que les autres usages affiliés.
- [x] Realignement documentaire:
  - `network_affiliate_manage` et `network_affiliate_cancel_immediate` ne sont plus des references V1;
  - la seule action a conserver pour une delegation `hors_cadre` active est la resiliation.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Résiliation portail Stripe déléguée: ne pas rabattre la fin au jour courant
- [x] Audit ciblé prouvé:
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - une résiliation `hors cadre` via portail Stripe pouvait encore clôturer trop tôt côté SI si l'événement reçu était terminal alors que `current_period_end` restait future;
  - le statut pouvait alors passer trop tôt à `Terminée` malgré une fin de période encore à venir.
- [x] Correctif livré:
  - la réconciliation déléguée conserve maintenant la date de fin Stripe future comme vérité prioritaire avant toute désactivation terminale;
  - une résiliation “fin de période” doit donc continuer d'apparaître comme planifiée dans `Mon réseau`;
  - l'offre reste active jusqu'à l'échéance effective et ne doit plus être clôturée immédiatement;
  - le bouton visible de la ligne reprend aussi le libellé `Réactiver mon offre` tant que cette résiliation n'est pas encore effective;
  - dans cet état, la ligne n'autorise plus `Changer d'offre` et n'affiche plus qu'un lien direct de réactivation Stripe;
  - la réactivation utilise une session portail standard et la sync pipeline garde l'affilié en `ABN/PAK` tant que l'offre reste active.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-13 — Delegations `hors cadre`: seul l'axe resiliation Stripe reste valable
- [x] Audit ciblé prouvé:
  - `pro/web/ec/ec_webhook_stripe_handler.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Causes confirmees:
  - le portail Stripe pouvait annuler une delegation `hors cadre` sans write path de reconciliation SI;
  - les hypotheses de remplacement immediat associees a ce lot sont desormais abandonnees.
- [x] Correctif livré:
  - le webhook Stripe traite maintenant `customer.subscription.updated` / `customer.subscription.deleted` pour répercuter fin programmée et fin effective des délégations `hors cadre`;
  - une delegation `hors_cadre` resiliee fin de periode reste visible comme telle jusqu'a l'echeance effective;
  - aucun remplacement, upsell ou downsell ne doivent plus etre lus ici comme trajectoire V1 finale.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-13 — `Mon offre`: CTA portail cohérent pendant l'essai Stripe
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Causes confirmées:
  - la page assimilait toute `date_fin` d'un abonnement Stripe à une fin programmée, y compris pendant une période d'essai;
  - cela faisait remonter `Réactiver mon abonnement` alors que Stripe remontait encore une souscription `trialing`.
- [x] Correctif livré:
  - la page relit désormais le snapshot Stripe de la souscription pour distinguer `trialing` et `cancel_at_period_end`;
  - le CTA reste `Gérer mon abonnement` pendant l'essai et la page ajoute `Offre d'essai en cours`;
  - le texte détaillé `15 jours gratuits...` est retiré de `Mon offre`; la mention disparaît d'elle-même à la fin de l'essai car elle dépend du statut Stripe `trialing`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-13 — TdR: commande déléguée hors cadre et statut affilié
- [x] Audit ciblé prouvé:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - après paiement d'une offre déléguée `hors cadre`, l'activation réseau était bien écrite mais le pipeline affilié n'était pas resynchronisé.
- [x] Correctif livré:
  - la finalisation hors cadre resynchronise maintenant explicitement le pipeline affilié sur la base de l'offre effective activée;
  - un fallback direct sur l'offre déléguée activée complète la lecture canonique pour éviter un no-op transitoire pendant le webhook Stripe.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Step 2 delegue: wording downsell (historique abandonne)
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le step 2 affichait encore le message immédiat en se basant seulement sur une comparaison locale des montants mensuels;
  - le runtime métier, lui, traite aussi `passage à une période plus courte` comme un downsell différé, notamment `annuel -> mensuel`.
- [x] Realignement documentaire:
  - cette logique de `downsell` ne fait plus partie de la trajectoire V1 finale;
  - elle est conservee uniquement comme historique depasse.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-13 — Reseau TdR: persistance de downsell differe (historique abandonne)
- [x] Audit croisé:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/cron_routine_bdd_maj.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Realignement documentaire:
  - le comportement `Changer d'offre` / `downsell differe` n'est plus a retenir pour V1;
  - cette persistance est conservee dans l'historique technique, pas comme verite produit active.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/cron_routine_bdd_maj.php` OK

## PATCH 2026-03-13 — `Mon réseau`: panneau flottant et `Offre actuelle` en changement d’offre (historique abandonné)
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - dépendance widget `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- [x] Cause confirmée:
  - le choix `Voir / résilier` / `Changer d’offre` était rendu inline dans la ligne du tableau, ce qui tassait l’UI;
  - le tunnel de remplacement manuel n’exposait pas clairement l’offre source déjà active.
- [x] Realignement documentaire:
  - ce panneau de changement d'offre ne fait plus partie de la reference V1;
  - il reste seulement dans l'historique de lot.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK

## PATCH 2026-03-13 — `Mon réseau`: logs temporaires portail affilié retirés
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Correctif livré:
  - retrait des logs temporaires `Network Affiliate Portal` après diagnostic confirmé;
  - la résolution de config portail est désormais centralisée côté Stripe global.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-13 — `Mon réseau`: `Voir / résilier` cible la bonne offre Stripe
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - dépendance `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livré:
  - `Voir / résilier cette offre` ouvre maintenant Stripe sur la souscription de la ligne sélectionnée, sans repasser par la liste globale des offres du client;
  - le panneau `Gérer l'offre` a été simplifié avec CTA pleine largeur et textes d'aide séparés.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-13 — `Mon réseau` / step 2: wording upsell/downsell (historique abandonné)
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Realignement documentaire:
  - le wording `upsell/downsell` ne doit plus etre repris comme verite V1.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-13 — `Mon réseau`: `Gérer l’offre` avec `Changer d’offre` (historique abandonné)
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - `pro/web/ec/modules/compte/client/ec_client_network_script.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Realignement documentaire:
  - la presence de `Changer d'offre` dans `Mon réseau` est explicitement non retenue en V1 finale;
  - la seule action encore valable pour une delegation `hors_cadre` active est sa resiliation explicite.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Webhook Stripe: pré-sync des remises dynamiques pour délégations TdR hors cadre
- [x] Audit ciblé prouvé:
  - `pro/web/ec/ec_webhook_stripe_handler.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le renouvellement automatique Stripe créait bien la facture interne, mais ne garantissait pas à lui seul un recalcul du montant remisé juste avant prélèvement;
  - seules les délégations `hors cadre` commandées par une TdR doivent être sécurisées sur ce point.
- [x] Correctif livré:
  - le webhook Stripe déclenche maintenant une pré-sync tarifaire sur `invoice.upcoming` et `invoice.created` pour les subscriptions déléguées `hors cadre`;
  - un contrôle de resync est aussi exécuté sur `invoice.paid` en cycle de facturation, sans toucher aux autres abonnements.
- [x] Point d'exploitation:
  - la configuration Stripe doit inclure `invoice.upcoming` et `invoice.created` sur cet endpoint pour rendre la pré-sync réellement systématique.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — `Mon réseau`: le lien `Facturation` actif renvoie vers `Mon offre`
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Cause confirmée:
  - dans le bloc `Facturation`, le CTA actif pointait encore vers le portail de gestion avec le libellé `Gérer mon abonnement`;
  - la cible attendue est maintenant la page `Mon offre`.
- [x] Correctif livré:
  - en abonnement réseau actif, le lien affiche désormais `Voir mon abonnement`;
  - il renvoie maintenant vers `extranet/account/offers`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-13 — `Mon réseau`: colonnes `Affilié` et `Statut` centrées verticalement
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Cause confirmée:
  - les colonnes `Affilié` et `Statut` du tableau n'étaient pas centrées verticalement dans les lignes;
  - le rendu paraissait désaligné dès que la colonne `Détail` prenait plus de hauteur.
- [x] Correctif livré:
  - ajout de `align-middle` sur les cellules `Affilié` et `Statut`;
  - la colonne `Détail` reste inchangée.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-13 — `Mon réseau`: tutoiement harmonisé et accents visibles vérifiés
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Cause confirmée:
  - la page mélangeait encore plusieurs formulations en vouvoiement avec le reste de l'espace PRO;
  - quelques libellés visibles devaient aussi être revérifiés côté accents et microcopies françaises.
- [x] Correctif livré:
  - les textes visibles de `Mon réseau` passent au tutoiement de façon cohérente;
  - les libellés relus conservent les accents français attendus sur la page.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-13 — `Mon réseau`: reminder de remise au-dessus du CTA `Commander`
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Cause confirmée:
  - la page réseau calculait déjà la remise projetée de prochaine commande;
  - mais le CTA `Commander` d'un affilié sans offre active n'exposait pas cette remise au moment de l'action.
- [x] Correctif livré:
  - ajout d'une mention `Profite de ta remise réseau de xx% !` juste au-dessus du CTA `Commander`;
  - le pourcentage réutilise le calcul déjà présent sur la page, sans nouveau calcul métier.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-13 — Step 1 délégué: fallback serveur si le `back` navigateur perd le token
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - après un retour navigateur step 2 -> step 1, certains POST `Commander` revenaient sans `network_delegated_token`;
  - le step 1 ne reconnaissait alors plus la commande affiliée et renvoyait vers `Mon réseau` avec une erreur générique.
- [x] Correctif livré:
  - le step 1 réutilise désormais le contexte délégué de session quand une offre `pending` cohérente existe déjà pour l'affilié;
  - le changement d'offre ou la reselection après `back` reste donc dans le tunnel délégué même si le token n'est plus reposté.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Confirmation déléguée: les formulaires de changement d'offre gardent le token affilié
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_2.php`
- [x] Cause confirmée:
  - les cartes de changement d'offre du step 2 repostaient en `step=1` sans `network_delegated_token`;
  - le flux quittait alors le contexte affilié et retombait sur une erreur générique côté `Mon réseau`.
- [x] Correctif livré:
  - les formulaires `Choisir` du step 2 réembarquent maintenant `network_delegated_token` quand la confirmation appartient à une commande déléguée;
  - le changement d'offre conserve donc le contexte affilié sur ce rebond.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_2.php` OK

## PATCH 2026-03-13 — Tunnel délégué: le back navigateur conserve le contexte affilié
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- [x] Cause confirmée:
  - le step 1 délégué effaçait le contexte affilié en session juste après la création de l'offre pending;
  - l'URL de redirection vers `manage/s2` ne réembarqait pas non plus le `network_delegated_token`.
- [x] Correctif livré:
  - le contexte délégué reste vivant pendant le tunnel au lieu d'être supprimé dès la fin du step 1;
  - la redirection vers `manage/s2/<id_securite>` propage aussi `?network_delegated_token=...` pour améliorer les retours navigateur.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK

## PATCH 2026-03-13 — Checkout Stripe délégué: rappel visible de l'affilié cible
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- [x] Cause confirmée:
  - le checkout Stripe délégué ne recevait que des métadonnées techniques sur l'affilié cible;
  - aucune mention visible n'était injectée dans l'interface Stripe hébergée.
- [x] Correctif livré:
  - la session Stripe déléguée renseigne maintenant `custom_text.submit` avec `Commande pour <affilié>`;
  - le texte n'est ajouté qu'en contexte affilié, avec fallback `Affilié #id` si le nom n'est pas disponible.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK

## PATCH 2026-03-13 — Confirmation déléguée: nom de l'affilié affiché au-dessus de `Remise réseau`
- [x] Audit ciblé prouvé:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Cause confirmée:
  - la confirmation de commande déléguée affichait bien `Remise réseau (x%)`;
  - en revanche, l'affilié cible de la commande n'était pas rappelé à cet endroit du tunnel.
- [x] Correctif livré:
  - la confirmation affiche maintenant `Commande pour <nom affilié>` au-dessus de `Remise réseau (x%)` quand l'offre porte une délégation vers un affilié;
  - le nom est résolu depuis `id_client_delegation`, avec fallback `Affilié #id`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-13 — Tunnel délégué: CTA `Commander` et `%` de `Remise réseau` visible en confirmation
- [x] Audit ciblé prouvé:
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Cause confirmée:
  - la première étape du tunnel délégué pouvait encore afficher un wording hérité non cohérent avec une commande affiliée payante;
  - la confirmation affichait `Remise réseau` sans rappeler le pourcentage appliqué.
- [x] Correctif livré:
  - le CTA de choix d'offre affiche maintenant `Commander` en contexte affilié;
  - le texte marketing CHR retire aussi la promesse `testez pendant 15 jours` en contexte affilié;
  - la confirmation affiche `Remise réseau (x%)` quand la ligne d'offre porte un pourcentage de remise;
  - le formatage du `%` est rendu manuellement pour éviter l'injection d'espace insécable HTML (`&nbsp;`) par le helper monétaire;
  - aucun calcul ni write path de remise n'est modifié.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-13 — `Commander` en contexte affilié: typologie TdR respectée, essai gratuit masqué
- [x] Audit ciblé prouvé:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- [x] Cause confirmée:
  - le point d'entrée délégué ouvrait toujours le tunnel `abonnement`, sans reprendre la typologie de la TdR qui paie;
  - l'UI catalogue pouvait encore afficher `Essayer gratuitement` et le bandeau d'essai alors qu'une commande affiliée déléguée ne porte jamais d'essai gratuit.
- [x] Correctif livré:
  - la redirection du checkout délégué choisit maintenant le segment catalogue PRO selon la typologie de la TdR;
  - en contexte affilié, le widget cache les marqueurs UI d'essai gratuit et force aussi `trial_period_days = 0` côté formulaire;
  - la cohérence UX est donc alignée avec le write path existant des offres déléguées `pending`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` OK

## DOC 2026-03-13 — Réseau BO: navigation croisée TdR / offre support documentée
- [x] Mise à jour transversale livrée:
  - la fiche BO `Abonnement réseau` affiche maintenant le compte TdR avec lien direct;
  - la synthèse BO `Affiliés du réseau` ouvre désormais la fiche de l'offre support depuis `Abonnement réseau actif`.
- [x] Portée rappelée:
  - aucun flux PRO ni helper métier côté extranet n'est modifié;
  - l'impact est limité à la navigation BO autour du support réseau.

## PATCH 2026-03-13 — `Mon reseau`: remise reseau projetée visible dans `Synthese`
- [x] Audit cible prouve:
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - dependance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - la page PRO `Mon reseau` exposait deja la `Facturation` et les compteurs de `Synthese`;
  - la remise reseau projetee sur la prochaine commande, deja visible en BO `reseau_contrats`, n'etait pas remontee dans le bloc `Synthese`.
- [x] Correctif livre:
  - la vue calcule maintenant la remise de `prochaine commande` sur `nb_affilies_actifs_remise + 1`, comme dans la synthese BO;
  - le bloc `Synthese` affiche `Remise reseau appliquee a votre prochaine commande : xx%`;
  - une mention `text-muted` explicite que cette remise depend du nombre d'affilies actifs et s'applique sur toutes les offres gerees par le reseau.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-12 — `Mon reseau`: detail simplifie et jauge affichee
- [x] Correctif UI livre:
  - la colonne `Detail` n'affiche plus les textes d'etat internes de type `Activation incluse disponible`, `Lecture seule`, `Portail Stripe disponible`, etc.;
  - elle conserve uniquement les informations offre utiles et les CTA effectivement actionnables.
- [x] Information supplementaire livree:
  - la jauge de l'offre est maintenant affichee au format `Jauge : X joueurs`.
- [x] Correctif visuel livre:
  - le hover du bouton `Desactiver` utilise maintenant un fond rouge plus terne, aligne sur le comportement des autres boutons pleins.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-12 — `Mon reseau`: priorite a `Activer via l'abonnement` et fiabilisation de `Desactiver`
- [x] Correctif UI livre:
  - pour un affilie sans offre, `Commander` n'est plus affiche si une place incluse est disponible sur un abonnement reseau actif;
  - dans ce cas, seul `Activer via l'abonnement` reste visible.
- [x] Correctif metier livre:
  - `deactivate_included` ne renvoie plus un succes si aucune offre deleguee active coherente n'est resolue;
  - la desactivation reforce aussi la reclassification reseau apres ecriture pour eviter un rechargement avec etat stale.
- [x] Correctif visuel livre:
  - le bouton `Desactiver` est colore par defaut;
  - au survol, il devient transparent avec texte et bordure rouges.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-12 — `Mon reseau`: `Gerer l'offre` ouvre le portail Stripe de l'offre deleguee
- [x] Cause prouvee:
  - le CTA `Gerer l'offre` pointait encore vers le tunnel historique `manage/s2`;
  - l'attendu fonctionnel est une ouverture directe du portail Stripe de l'offre deleguee quand la session portail est preparable.
- [x] Correctif livre:
  - le lien est maintenant prepare via `app_ecommerce_stripe_billing_portal_session_prepare(...)` sur l'offre deleguee concernee;
  - l'URL cible devient l'URL de portail Stripe retour `/extranet/account/network`;
  - le bouton n'est affiche que si une vraie session portail est obtenue.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-12 — `Mon reseau`: correction du lien `Gerer l'offre` pour une delegation Stripe
- [x] Cause prouvee:
  - le CTA `Gerer l'offre` de `Mon reseau` pointait vers `/extranet/account/offers/manage/s2/<id_securite>`;
  - cette route n'existe pas dans `pro/web/.htaccess`;
  - le tunnel historique expose bien `/extranet/ecommerce/offers/manage/s2/<id_securite>`.
- [x] Correctif livre:
  - generation du lien corrigee vers `/extranet/ecommerce/offers/manage/s2/<id_securite>`;
  - aucun changement de tunnel ni de comportement metier.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-12 — Lot 3B `Commander`: ouverture du tunnel delegue hors abonnement via le catalogue historique
- [x] Audit strict prouve:
  - point d'entree UI confirme dans `pro/web/ec/modules/compte/client/ec_client_list.php` via le CTA `Commander` de `/account/network`;
  - tunnel classique confirme:
    - catalogue `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`;
    - selection / creation `step=1` dans `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`;
    - checkout `step=2` dans `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`;
    - retour offre `manage/s2/<id_securite>` et detail `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`;
    - validation finale `global/web/app/modules/ecommerce/app_ecommerce_functions.php`.
- [x] Cablage livre:
  - nouveau `mode=start_delegated_hors_cadre_checkout` sur `/extranet/account/network/script`;
  - contexte affilie explicite porte par token de session court jusqu'au catalogue historique;
  - creation au `step=1` d'une offre deleguee `pending` avec `id_client = TdR` et `id_client_delegation = affilie`;
  - ouverture du `step=2` standard sur la ligne deja creee, sans tunnel parallele.
- [x] Remise reseau livree de bout en bout:
  - calcul de remise base sur le volume actif `apres commande`;
  - affichage catalogue en net remisé avec ancien prix barre;
  - persistance `prix_ht`, `remise_nom`, `remise_pourcentage` sur l'offre creee;
  - checkout Stripe delegue aligne sur le montant stocke via `price_data` dynamique.
- [x] Garde-fous livres:
  - aucun usage de `app_ecommerce_reseau_offre_deleguee_create_for_affilie(...)` dans le flux `Commander`;
  - aucun fallback silencieux vers une commande `en propre`;
  - aucun paiement delegue si le contexte affilie / contrat / offre est incoherent;
  - aucun passage `active` avant paiement;
  - aucun doublon d'offre au retour paiement: l'attachement `hors_cadre` reutilise la ligne deja payee.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_2.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-12 — Lot 3A UI `Mon reseau`: suppression complete du CTA `Reactiver`
- [x] Audit cible prouve:
  - `ec_client_list.php` relu sur:
    - mapping `network_affiliate_hors_cadre_ok`;
    - calcul `can_reactivate_hors_cadre`;
    - formulaire inline `create_or_reactivate_hors_cadre_for_affiliate`;
    - fallback `Commander une offre`;
    - zone actions des delegations `hors abonnement reseau`.
  - branchement historique prouve pour les offres deleguees actives:
    - page offre historique `extranet/account/offers/manage/s2/<id_securite>`;
    - portail Stripe prepare sur cette page via `app_ecommerce_stripe_billing_portal_session_prepare(...)`.
  - preuve Stripe retenue pour une offre deleguee active:
    - `asset_stripe_productId` present sur l'offre effective;
    - sans cette preuve, aucun CTA de gestion n'est expose depuis `Mon reseau`.
  - contexte affilié cible dans le tunnel classique de commande depuis `/account/network`: non trouve dans la documentation.
  - contexte affilié cible dans le tunnel classique de commande depuis `/account/network`: non prouve dans le code.
- [x] Correctif minimal livre:
  - suppression totale du CTA `Reactiver l'offre`;
  - suppression de sa logique front associee;
  - suppression de tout formulaire direct vers `create_or_reactivate_hors_cadre_for_affiliate` depuis `Mon reseau`;
  - ajout d'un CTA historique `Gerer l'offre` pour une delegation active `hors abonnement reseau`, vers la page offre historique de l'offre concernee;
  - le cas `Commander` reste explicitement preparatoire / desactive tant que le tunnel historique ne porte pas proprement un affilié cible depuis cette page.
- [x] Regles CTA finales:
  - `Activer via l'abonnement`:
    - uniquement si abonnement reseau actif;
    - affilie sans offre active;
    - pas d'offre propre;
    - place incluse encore disponible.
  - `Desactiver`:
    - uniquement pour un affilie actif via l'abonnement reseau.
  - `Gerer l'offre`:
    - uniquement pour une offre deleguee active `hors abonnement reseau`;
    - uniquement si une souscription Stripe est prouvee sur cette offre (`asset_stripe_productId`);
    - jamais pour une offre propre.
  - `Commander`:
    - aucun write ni tunnel ambigu;
    - bouton laisse desactive tant que le contexte affilié cible n'est pas prouve cote tunnel historique.
- [x] Verification:
  - `php -l pro/web/ec/modules/compte/client/ec_client_list.php` OK

## DOC 2026-03-12 — Lot 3B: evolution planifiee pour `Commander` une offre deleguee hors abonnement
- [x] Le plan de migration reseau documente maintenant une evolution dediee du lot `3B` pour:
  - reutiliser le tunnel classique de selection d'offre dans un contexte affilie;
  - integrer la remise reseau au catalogue et au paiement;
  - creer une offre deleguee `pending` avant paiement;
  - rattacher ensuite l'offre payee a l'activation reseau `hors_cadre`.
- [x] Garde-fou documentaire explicite:
  - ouverture autorisee seulement apres preuve complete du checkout Stripe remisé et de l'attachement post-paiement.

## PATCH 2026-03-12 — Lot 3A UI `Mon reseau`: cohérence `Désactiver` sur affilié inclus
- [x] Audit ciblé prouvé:
  - `ec_client_list.php` relu sur 3 blocs:
    - statut `Actif abonnement réseau` / `Inclus dans votre abonnement réseau`;
    - calcul `can_deactivate_included`;
    - fallback `Aucune action disponible`.
  - cause confirmée:
    - le statut front était repris depuis `app_ecommerce_reseau_contrat_couverture_get_detail(...)`, donc depuis le reclassement de couverture;
    - `can_deactivate_included` utilisait au contraire la persistance d'activation courante (`activation_state` + `mode_facturation`);
    - un affilié pouvait donc être affiché `cadre` par reclassement visuel alors que la désactivation serveur restait bloquée par un `mode_facturation` historique encore `hors_cadre`.
- [x] Correctif minimal livré:
  - la vue conserve le badge/statut issu de la couverture courante;
  - le bouton `Désactiver` redevient visible pour un affilié affiché `offre_deleguee_cadre` avec activation active;
  - le write path serveur `deactivate_included` accepte aussi le cas où la couverture courante classe réellement l'affilié en `cadre`, même si `mode_facturation` historique n'avait pas encore suivi;
  - aucun autre flux serveur modifié.
- [x] Vérifications de garde-fou:
  - affilié `cadre` réellement actif => `Désactiver` visible;
  - affilié `hors_cadre` actif => pas de bouton `Désactiver` inclus;
  - affilié `offre propre` => aucun CTA métier;
  - affilié sans offre => pas de faux bouton de désactivation;
  - soumission inchangée vers `/extranet/account/network/script` + `mode=deactivate_included`.
- [x] Verification:
  - `php -l pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-12 — Lot 3A UI `Mon reseau`: CTA affilies minimaux branches sur les endpoints PRO dedies
- [x] Audit UI cible:
  - vue relue: `pro/web/ec/modules/compte/client/ec_client_list.php`;
  - insertion retenue sans casser le tableau:
    - bloc d'actions inline ajoute en bas de la colonne `Detail`;
    - aucune nouvelle ecriture au chargement.
- [x] Regles UI effectivement branchees:
  - `Activer via l'abonnement` uniquement pour un affilie sans offre active, sans offre propre, avec abonnement reseau actif, cible incluse definie et place restante;
  - `Desactiver` uniquement pour une delegation actuellement classee `offre_deleguee_cadre` avec activation reseau explicite `cadre`;
  - `Gerer l'offre` uniquement pour une delegation active `hors abonnement reseau`, via le parcours historique de l'offre concernee;
  - `Commander` ouvre maintenant le tunnel historique avec contexte affilie explicite et blocage dur si ce contexte n'est plus valide;
  - une `offre propre` affilie reste lecture seule explicite, sans CTA metier.
- [x] Messages front ajoutes:
  - mapping success:
    - `network_affiliate_activate_included_ok`
    - `network_affiliate_deactivate_included_ok`
    - `network_affiliate_hors_cadre_ok`
  - mapping refus / garde-fous:
    - offre propre active;
    - quota inclus atteint;
    - cible offre / jauge / frequence invalide ou incoherente;
    - affilié invalide / hors reseau / contrat manquant;
    - action non autorisee / CSRF invalide;
    - fallback erreur generique.
- [x] Garde-fous verifies cote UI:
  - aucun write path legacy brut;
  - aucun CRUD generique delegation;
  - aucun CTA metier sur offre propre;
  - aucune reactivation directe depuis `Mon reseau`;
  - aucun tunnel ambigu pour une nouvelle commande hors abonnement.
- [x] Verification:
  - `php -l pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-12 — Lot 3B `actions affilies`: socle serveur PRO explicite minimal
- [x] Audit technique prouve:
  - point de branchement PRO confirme via `/extranet/account/network/script`;
  - dispatch confirme via `pro/web/ec/do_script.php`;
  - helpers globaux metier relus:
    - `app_ecommerce_reseau_offre_deleguee_create_for_affilie(...)`
    - `app_ecommerce_reseau_offre_deleguee_reactivate(...)`
    - `app_ecommerce_reseau_activation_write(...)`
    - `app_ecommerce_reseau_contrat_couverture_get_detail(...)`
  - absence de couche CSRF PRO generique confirmee: token dedie a creer pour ce lot.
- [x] Socle serveur livre:
  - route PRO dediee `/extranet/account/network/script`;
  - script PRO dedie `ec_client_network_script.php`;
  - actions serveur explicites:
    - `activate_included`
    - `deactivate_included`
    - `create_or_reactivate_hors_cadre_for_affiliate`
  - wrappers globaux neutres ajoutes pour sortir la logique metier du nommage `..._from_bo(...)`.
- [x] Garde-fous serveur livres:
  - verification session TdR / ownership affilie;
  - token de session dedie `network_affiliate_actions`;
  - refus explicite sur:
    - offre propre affilie active;
    - quota inclus indisponible;
    - support reseau inactif pour l'inclus;
    - offre cible hors abonnement incoherente;
    - reutilisation d'une delegation qui ne correspond pas a la cible;
  - aucune ecriture directe sur `id_client_delegation`.
- [x] UI PRO minimale branchee ensuite via le lot `3A`:
  - formulaires inline bornes sur `/extranet/account/network/script`;
  - mapping front des retours `network_affiliate_*` ajoute;
  - flux hors abonnement neuf laisse en CTA preparatoire si le catalogue n'est pas prouve sur la page.

## PATCH 2026-03-12 — Lot 3 `actions affilies`: rebaseline documentaire avant patch
- [x] Audit strict consolide:
  - `/extranet/account/network` et `Mon offre` relus cote PRO;
  - notes de cadrage reseau relues:
    - `notes/delegation-write-path-2026-03-06.md`
    - `notes/deactivation-contract-2026-03-06.md`
    - `notes/offer-lifecycle-hooks-2026-03-06.md`
    - `notes/audit-contrat-offre-reseau-2026-03-06.md`
- [x] Conclusion verrouillee:
  - seuls les flux support reseau / Stripe sont aujourd'hui prouves comme canoniques cote PRO;
  - les actions metier affilie restent `BO-only` tant qu'aucun endpoint PRO dedie n'existe;
  - aucun write path metier PRO explicite n'est encore prouve pour:
    - activation incluse;
    - desactivation incluse;
    - creation / reactivation `hors abonnement reseau`;
  - l'ecriture brute de delegation via `id_client_delegation` ne doit pas etre reouverte cote PRO.
- [ ] Lot 3A a preparer:
  - conserver `Mon reseau` comme surface de lecture / cadrage tant que les writes affilie ne sont pas exposes cote PRO;
  - n'afficher cote TdR que les actions PRO deja prouvees:
    - paiement support reseau;
    - portail Stripe support reseau;
  - expliciter proprement les cas `pilotable ici`, `BO-only`, `offre propre non pilotable`.
- [ ] Lot 3B a concevoir puis implementer:
  - creer des write paths PRO explicites pour:
    - `activate_included`
    - `deactivate_included`
    - `create_or_reactivate_hors_cadre_for_affiliate`
  - brancher ces endpoints sur des wrappers metier autour des helpers globaux existants;
  - interdire toute reutilisation du CRUD generique delegation.
- [x] Statut courant:
  - audit termine;
  - implementation PRO affilies non commencee.

## PATCH 2026-03-12 — `Mon reseau`: micro-correctifs UI sur `Mes affilies`
- [x] Audit cible:
  - vue relue: `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Cause confirmee:
  - le badge `Actif hors abonnement reseau` etait encore statique pour les delegations `offre_deleguee_hors_cadre`, alors que le wording attendu depend de l'etat reel de l'abonnement reseau support;
  - la chip `Filtrer` de la colonne `Statut` restait trop effacee hors hover;
  - le panneau des filtres n'avait pas encore de garde-fou de hauteur interne si la liste d'options grandit.
- [x] Correctif livre:
  - le badge `offre_deleguee_hors_cadre` devient `Actif via le reseau` sans abonnement reseau actif, et `Actif en supplement` avec abonnement reseau actif;
  - la chip `Filtrer` est visible par defaut avec contraste leger, sans changer la logique de filtre;
  - le panneau de filtres utilise maintenant un conteneur simple a largeur fixe avec fond porte par le bloc interne, sans scroll interne, et reste superpose au-dessus du tableau.
- [x] Verification:
  - `php -l pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-12 — `Mon offre` + `Mon reseau`: lecture front sans recalcul reseau implicite
- [x] Audit cible:
  - point d'entree relu dans `pro/web/ec/ec.php`
  - rendu relu dans `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - messages globaux relus dans `pro/web/ec/modules/compte/offres/ec_offres_view.php`
  - helper portail relu dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - le chargement global PRO relisait `app_ecommerce_offre_effective_get_context(...)`, qui appelait encore `app_ecommerce_reseau_facturation_refresh(...)` pour une TdR;
  - la carte `Mon offre` relisait aussi les helpers reseau en mode par defaut, donc avec sync legacy encore possible pendant un simple chargement front;
  - la page `Mon reseau` relisait encore `app_ecommerce_reseau_facturation_get_detail(...)` en mode par defaut, donc avec sync legacy encore possible pendant la navigation entre `/account/network` et `Mon offre`;
  - le bandeau reseau affichait tel quel des causes techniques de portail Stripe (`stripe_customer_missing`, config manquante) alors que ces cas peuvent etre legitimes pour une offre support geree manuellement cote BO.
- [x] Correctif livre:
  - le contexte front TdR utilise maintenant une lecture reseau pure, sans `refresh` ecrivant sur l'offre support pendant un simple affichage;
  - la carte `Mon offre` lit maintenant les agregats reseau avec `skip_legacy_sync=1`;
  - la page `Mon reseau` lit maintenant aussi la facturation reseau avec `skip_legacy_sync=1`, pour que la navigation PRO reste sans write path implicite;
  - le refresh reseau canonique ne peut plus non plus remettre tout seul l'offre support en `En attente` pendant un recalcul interne; cette transition reste reservee aux write paths explicites BO;
  - le badge de statut de `Mon reseau` reconnait aussi la valeur canonique `active`, pour ne plus afficher a tort `Abonnement reseau inactif` quand l'offre support est bien active;
  - les cas reseau sans portail Stripe exploitable ne remontent plus de message technique brut au client final;
  - seul un incident reel de creation de session portail garde un message front neutre.
- [x] Verification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK
  - `php -l pro/web/ec/modules/compte/offres/ec_offres_view.php` OK
  - `php -l pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-12 — PRO reseau: page `Mon reseau` reoriente pilotage TdR
- [x] Audit cible:
  - point d'entree confirme via `pro/web/ec/ec.php`
  - vue relue: `pro/web/ec/modules/compte/client/ec_client_list.php`
  - dependances relues:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - `global/web/app/modules/general/branding/app_branding_functions.php`
- [x] Constats:
  - la page etait encore trop chargee pour une TdR:
    - blocs `Couverture et activation`, `Hors abonnement reseau` et `Prochaines actions` redondants
    - wording encore trop technique / historique
  - les donnees utiles existaient deja via les helpers canoniques:
    - compteurs / statuts affilies via `app_ecommerce_reseau_contrat_couverture_get_detail(...)`
    - socle HT/TTC via `app_ecommerce_reseau_facturation_get_detail(...)`
    - agrégats et periodes `hors abonnement reseau` via `app_ecommerce_reseau_offres_hors_cadre_pricing_get(...)`
  - la colonne detail affichait encore `Depuis le ...` au lieu d'une periode en cours canonique quand elle etait disponible.
- [x] Correctif livre:
  - la grille est maintenant:
    - ligne 1 `Synthese` + `Facturation`
    - ligne 2 `Lien d'affiliation` + `Personnalisation`
    - puis `Mes affilies` pleine largeur
  - les blocs `Couverture et activation`, `Hors abonnement reseau` et `Prochaines actions` sont retires
  - le CTA header vers `Mon abonnement reseau` est retire
  - la synthese affiche `Affilies`, `Actifs`, `Inactifs`, puis un lien `Liste complete des affilies de mon reseau`
  - les cadres `Affilies / Actifs / Inactifs` sont visuellement renforces
  - le detail de repartition active est retire
  - le bloc `Facturation` expose:
    - le badge `Abonnement reseau actif` si applicable
    - une ligne compacte `HT [TTC]` pour le socle reseau
    - `Nb affilies limite` et `Nb de places restantes`
    - `Offre attribuee` si l'offre cible canonique est disponible
    - le meme lien d'action que `Mon offre` pour ouvrir Stripe selon l'etat reel de l'offre support
    - le resume des offres affiliees `hors abonnement reseau` prises en charge, uniquement sur les offres deleguees actuellement classees `hors abonnement reseau` par la couverture canonique
    - le message vide `aucune offre reseau a votre charge` si rien n'est facture
    - la phrase `Vous pouvez commander...` est retiree car redondante
  - le bloc `Lien d'affiliation` ne garde plus une phrase d'avertissement separee:
    - le sous-titre lui-meme devient dynamique selon abonnement reseau actif ou non
  - le lien d'affiliation est maintenant rendu inline, et la copie est declenchee au clic sur le lien ou sur la petite chip icone
  - le bloc `Personnalisation` expose `Design reseau`, un second CTA `Contenus reseau` laisse non cable, et une ligne placeholder sur les contenus partages
  - le tableau s'appuie sur la couverture canonique et affiche les badges / details front attendus, avec tarifs et periode en cours quand ils sont disponibles proprement
  - un filtrage front simple par statut est ajoute sur `Mes affilies`, en reutilisant les statuts deja calcules dans la vue
  - l'acces au filtre se fait via une petite chip `Filtrer` avec icone a cote de `Statut`, et seules les valeurs presentes dans la liste sont proposees
  - le menu de filtre reste compact et accepte les libelles longs sur plusieurs lignes pour eviter les debordements
  - aucune action metier affilie nouvelle n'est introduite cote PRO dans ce lot:
    - pas d'activation incluse;
    - pas de desactivation incluse;
    - pas de creation / reactivation `hors abonnement reseau`;
    - pas d'action sur une offre propre affilie.
- [x] Verification:
  - `php -l pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` relu comme reference CTA
  - `php -l pro/web/ec/modules/compte/client/ec_client_list.php` OK
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-19 — PRO EC: submit session verrouillé + pagination bibliothèque corrigée
- [x] Audit confirmé sur:
  - `pro/web/ec/modules/tunnel/start/ec_start_include_header.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_agenda_mode.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
  - `pro/web/ec/modules/widget/ec_widget_jeux_sessions_form_mode_calendrier_V3.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
- [x] Causes confirmées:
  - le tunnel calendrier postait vers `extranet/games/session/generate/script` avec un simple `loading()` visuel, sans verrou de soumission front;
  - les flux `start` modernes (`session_init`, `agenda_mode_select`, `session_setting[_multi]`) n'avaient pas non plus de garde anti-réentrance homogène;
  - la création depuis la bibliothèque pouvait encore relancer `session_init` via `ec_bibliotheque_script.php`;
  - la bibliothèque gardait `12` items paginés même quand la carte `Ajouter une playlist/série` occupait un slot;
  - le contexte remplacement depuis une session forçait ensuite `total/page/last_page` à `1` après filtrage local, ce qui supprimait la pagination.
- [x] Correctif livré:
  - le submit calendrier est désormais mono-exécution côté front (`data-is-submitting`, bouton désactivé, loader unique, blocage des resoumissions clic/clavier);
  - les formulaires `start` sensibles réutilisent maintenant un garde commun de soumission busy/disabled avec reset propre si la page est réaffichée;
  - les CTA bibliothèque qui déclenchent une création de session ou un passage builder `Continuer` sont eux aussi verrouillés sur le premier submit;
  - la grille `Mes` passe à `11` contenus quand la carte d'ajout est affichée, sinon reste à `12`;
  - le filtrage des contenus remplaçables depuis l'agenda est déplacé dans la requête source pour préserver `total` et `last_page`, avec conservation des query params de contexte.
- [x] Vérification:
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_include_header.php` OK
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php` OK
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_agenda_mode.php` OK
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK
  - `php -l pro/web/ec/modules/widget/ec_widget_jeux_sessions_form_mode_calendrier_V3.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK

## PATCH 2026-03-12 — Réseau / Stripe: remise dynamique propagée aux souscriptions déléguées
- [x] Audit de dépendance:
  - changement relu dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - changement relu dans `pro/web/ec/ec_webhook_stripe_handler.php`
- [x] Correctif documenté:
  - les délégations `hors abonnement réseau` payées via Stripe sont désormais resynchronisées sur le tarif net issu de la remise réseau courante;
  - la mise à jour Stripe se fait sans prorata immédiat pour viser le prochain cycle de prélèvement auto.
- [x] Durcissement webhook:
  - `customer.subscription.updated` distingue maintenant un vrai changement de catalogue d’un simple changement de tarif;
  - un changement de prix réseau n’écrase plus à tort une délégation avec un mapping catalogue standard.
- [x] Périmètre:
  - aucune offre propre affilié n’est concernée en prix;
  - le mécanisme vise uniquement les offres déléguées commandées/portées par la tête de réseau;
  - les affiliés avec offre propre active comptent toutefois dans le palier réseau qui détermine la remise appliquée aux délégations hors abonnement.

## PATCH 2026-03-11 — `Mon offre` réseau: lecture figée des archives
- [x] Audit ciblé:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - dépendances relues:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - la carte `Mon offre` réseau lisait les agrégats réseau via `id_client` seul, donc le support courant contaminait une offre historique affichée.
- [x] Correctif livré:
  - si l'offre `Abonnement réseau` affichée n'est pas le support courant, la carte utilise un snapshot figé dérivé de cette ligne;
  - aucun détail opérationnel ni CTA actif n'est relu depuis le support courant sur cette archive.
- [x] Vérification:
  - `php -l pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-11 — Réseau BO affiliés: aucun impact PRO direct
- [x] Audit de dépendance:
  - changement relu dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - changement relu dans `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Conclusion:
  - aucun écran PRO modifié dans ce sous-lot
  - aucune adaptation immédiate de `Mon offre` ou de la page réseau PRO requise
- [x] Alignement documentaire:
  - la séparation `incluse à l'abonnement réseau` / `hors abonnement réseau` est désormais considérée stable côté BO avant l'étape 2B

## PATCH 2026-03-23 — PRO auth: lien EC temporaire a usage unique
- [x] Audit confirme sur:
  - `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
  - `pro/web/ec/ec_signin.php`
  - dependance `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
- [x] Correctif livre
  - ajout d'un mode `client_contact_direct_access` sur `extranet/authentication/script`
  - consommation one-shot du jeton avec effacement immediat apres connexion
  - redirection directe vers `dashboard` ou `onboarding/use` selon l'etat du compte
  - fallback propre vers `signin` si le lien est invalide ou expire
- [x] Verification
  - `php -l pro/web/ec/modules/compte/authentification/ec_authentification_script.php` OK
  - `php -l pro/web/ec/ec_signin.php` OK

## PATCH 2026-03-11 — PRO reseau / Stripe: affichage et CTA unifies
- [x] Audit confirme sur:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - dependances `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctifs visibles appliques:
  - `Mon offre` affiche un socle minimal pour l'`Abonnement reseau` quel que soit son statut
  - `Gerer mon reseau` n'apparait plus que pour une offre reseau en attente ou active, en bas du bloc dedie
  - les CTA Stripe des abonnements sont maintenant alignes par statut
  - `Commander a nouveau` cree une nouvelle offre standard avec un nouvel `id_securite` puis renvoie en `s2`
- [x] Hypothese metier preservee:
  - l'offre support `Abonnement reseau` reste la seule source visible canonique
  - une offre reseau terminee n'expose aucun CTA `Commander a nouveau`

## PATCH 2026-03-13 — PRO reseau: downsell delegue planifie en lecture seule
- [x] Audit confirme sur `pro/web/ec/modules/compte/client/ec_client_list.php`
  - l'etat de remplacement differe etait deja detecte via `app_ecommerce_reseau_delegated_replacement_plan_get_by_source(...)`
  - l'UI laissait encore passer le CTA `Gerer l'offre`
- [x] Correctif livre
  - un `downsell` delegue hors cadre deja planifie n'affiche plus aucun CTA de gestion Stripe/remplacement
  - la ligne affiche uniquement la mention `Nouvelle offre commandee. Elle sera effective le {jj mois aaaa}.`
- [x] Verification
  - `php -l pro/web/ec/modules/compte/client/ec_client_list.php` OK

## PATCH 2026-03-18 — PRO TdR: navigation reseau enrichie
- [x] Audit confirme sur `pro/web/ec/ec.php`
  - le bloc reseau est deja reserve aux tetes de reseau
  - la bibliotheque reseau repose deja sur le contexte `network_manage=1`
- [x] Correctif livre
  - `Mon reseau` devient `Mes affilies`
  - `Jeux reseau` ouvre `/extranet/games/library?network_manage=1`
  - `Design reseau` ouvre `/extranet/account/branding/view`
  - l'etat actif est separe entre `Mes affilies` et `Jeux reseau`
- [x] Verification
  - `php -l pro/web/ec/ec.php` OK

## PATCH 2026-03-18 — PRO TdR: partage reseau recentre sur `network_manage=1`
- [x] Audit confirme sur:
  - `pro/web/ec/ec.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - la TdR gardait encore le menu `Les jeux` visible
  - le hub `network_manage=1` exposait encore 3 CTA separes
  - le portail standard affichait encore la carte `Les jeux {nom_TdR}` pour la TdR
- [x] Correctif livre
  - `Les jeux` est masque dans la navigation pour une TdR
  - `Jeux reseau` devient l'entree visible vers le partage de contenus reseau
  - `library?network_manage=1` expose un seul CTA `Ajouter des jeux` vers `/extranet/games/library`
  - la carte `Les jeux {nom_TdR}` du portail standard reste visible pour les affilies mais disparait pour la TdR
- [x] Verification
  - `php -l pro/web/ec/ec.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK
  - les fiches détail conservent bien `Lancer une demo` et `Partager avec mon reseau` / `Retirer du reseau` pour une TdR

## PATCH 2026-03-18 — PRO TdR: `Offres & factures` et offres portees par affilie
- [x] Audit confirme sur:
  - `pro/web/ec/ec.php`
  - `pro/web/ec/includes/menus/ec_menus_compte.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_view.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_list.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - la vue `Mon offre` excluait encore les offres deleguees payees par la TdR et les resumait via un bloc agrégé
- [x] Correctif livre
  - la nav TdR affiche `Offres & factures`
  - les tabs internes affichent `Offres / Factures / Equipe`
  - l'onglet `Offres` liste l'abonnement reseau puis les seules offres deleguees `hors cadre` portees par la TdR de facon unitaire
  - les delegations `cadre` incluses dans l'abonnement reseau n'apparaissent plus en propre
  - chaque offre deleguee `hors cadre` affiche l'affilie concerne
  - un filtre simple par affilie apparait si plusieurs affilies `hors cadre` ont des offres portees
  - les offres deleguees `hors cadre` gardent un CTA `Gerer l'offre` differe
  - le chargement est allégé en evitant la preparation portail Stripe sur chaque offre deleguee au rendu
  - les libelles de periode / cloture / resiliation des offres deleguees `hors cadre` sont alignes sur l'affichage attendu
  - l'historique TdR n'est plus rendu par defaut et s'affiche a la demande avec pagination simple
  - les branches generiques de periode sont exclues pour les offres deleguees afin d'eliminer les doublons de libelles
- [x] Verification
  - `php -l pro/web/ec/ec.php` OK
  - `php -l pro/web/ec/includes/menus/ec_menus_compte.php` OK
  - `php -l pro/web/ec/modules/compte/offres/ec_offres_view.php` OK
  - `php -l pro/web/ec/modules/compte/offres/ec_offres_include_list.php` OK
  - `php -l pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-31 — Start sessions: garde numerique quiz alignee avec games
- [x] Audit cible:
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
- [x] Correctif livre:
  - le passage `papier -> numerique` sur une session `Cotton Quiz` existante est maintenant bloque cote serveur si des questions n'ont pas assez de propositions;
  - la fiche settings `pro` desactive le bouton `numerique` pour une session papier incompatible et affiche le meme message metier que `games`;
  - le retour `numerique -> papier` reste possible.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`

## PATCH 2026-03-31 — Start sessions quiz: CTAs format desactives si numerique impossible
- [x] Audit cible:
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
- [x] Correctif livre:
  - suppression du bandeau `format_error` sur le formulaire settings;
  - pour `Cotton Quiz`, si le passage `papier -> numerique` est interdit, les 2 CTAs de format sont desactives;
  - la fiche affiche sous le switch la meme mention que `games`: `Ce quiz n'est pas compatible avec la version numérique du jeu.`
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`

## PATCH 2026-03-31 — Agenda historique pro: suppression et message runtime masques
- [x] Audit cible:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Correctif livre:
  - une session affichee en historique (`app_session_chronology === 'after'`) ne propose plus le bouton de suppression, meme si son etat metier reste `En attente`;
  - le message `Cette session est en cours...` est maintenant reserve aux sessions verrouillees encore hors historique.
  - le conteneur `card-body` de la carte Parametres referme maintenant correctement ses coins bas quand le bloc de suppression est absent.
  - le message runtime n'est plus rendu dans un bandeau gris brut: il utilise maintenant un callout plus propre, coherent avec les conventions visuelles `pro`, sans icone, et avec un lien direct reprenant la meme cible que le CTA `Ouvrir le jeu`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
