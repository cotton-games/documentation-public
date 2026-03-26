# Repo `global` — Tasks

> Invariants V1 a proteger dans `app_ecommerce_functions.php`: aucune auto-creation d'offre support `Abonnement reseau`; aucun write path runtime ne doit fabriquer `En attente` sur simple lecture; aucune propagation de fin support vers les delegations `hors_cadre`; aucun auto-reclassement `hors_cadre -> cadre`; aucune logique de remplacement manuel / upsell / downsell comme verite finale des delegations `hors_cadre`.

## PATCH 2026-03-26 — Sessions: nouveau support dédié de participations probables pour `play`
- [x] Audit confirmé dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `documentation/canon/data/schema/DDL.sql`
  - `documentation/canon/data/schema/MAP.md`
- [x] Correctif livré:
  - ajout d'helpers `app_session_participation_probable_*` sur le domaine sessions;
  - les reads joueur `app_joueur_session_inscription_get_detail()` et `app_joueur_sessions_inscriptions_get_liste()` s'appuient maintenant sur `championnats_sessions_participations_probables`;
  - `app_joueur_session_inscription_get_link()` ne redirige plus vers un runtime de jeu depuis `play`;
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
