# Handoff

## WWW/Pro: LP reseau mention connexion compte existant - 2026-05-13

### Resume
- audit du CTA final LP reseau/operation: le CTA principal est construit dans `www/web/lp/lp.php` vers `/utm/reseau/{slug}`;
- ajout sous le CTA final d'une mention secondaire: `Deja inscrit sur Cotton ? Connecte-toi avec ton compte habituel pour acceder a ton espace ou rejoindre le reseau.`;
- le segment `Connecte-toi` pointe vers la nouvelle route PRO `/utm/reseau/{slug}/signin`;
- `pro/web/ec/ec_sign.php` pose le meme contexte d'affiliation reseau que le parcours signup puis redirige vers `signin` quand `sign_action=signin`;
- les pages `ec_signup.php` et `ec_signin.php` ne sont pas modifiees.

### Fichiers modifies
- `www/web/lp/lp.php`
- `www/web/lp/includes/css/lp_custom.css`
- `pro/web/.htaccess`
- `pro/web/ec/ec_sign.php`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/entrypoints.md`
- `documentation/canon/runbooks/dev.md`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`

### Verification
- docs publiques consultees: `START.md`, `SITEMAP.txt`, `SITEMAP.ndjson`, `DOCS_MANIFEST.md`, `canon/repos/www/README.md`;
- journal AI Studio raw consulte: `web/lp/lp.php` et `web/lp/includes/css/lp_custom.css` identifies comme sensibles; etat local confirme comme base de travail;
- `php -l www/web/lp/lp.php` OK;
- `php -l pro/web/ec/ec_sign.php` OK;
- `npm run docs:sitemap` bloque par la policy PowerShell locale (`npm.ps1`); `npm.cmd run docs:sitemap` execute dans `documentation`;
- TODO recette serveur: tester LP reseau avec/sans abonnement actif, LP operation, LP standard hors reseau, et mobile.

## WWW: LP reseau header preuve sociale centre - 2026-05-13

### Resume
- ajustement UI uniquement du header du bloc preuve sociale LP reseau;
- le sur-titre `{TdR} x Cotton depuis YYYY` et le titre `Le reseau s'anime deja avec Cotton` sont maintenant centres;
- l'espacement vertical entre ces deux lignes est reduit via CSS scope sur `.lp-operation-proof-header`;
- aucune modification des donnees, seuils, CTA, requetes ou logique d'affichage.

### Fichiers modifies
- `www/web/lp/includes/css/lp_custom.css`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/www/TASKS.md`

### Verification
- docs publiques consultees: `START.md`, `DOCS_MANIFEST.md`;
- journal AI Studio raw: non trouve dans la documentation a l'URL demandee, reponse 404;
- TODO recette serveur: verifier le centrage desktop/mobile du bloc preuve sociale.

## WWW BO: fiche TdR preview assets et Online - 2026-05-13

### Resume
- les apercus LP reseau existants (`Logo LP reseau`, `Visuel principal LP reseau`) changent maintenant immediatement dans l'UI quand un nouveau fichier est selectionne via clic sur le visuel;
- un message indique le fichier selectionne et rappelle d'enregistrer pour appliquer;
- le formulaire detecte si `online` ou `flag_une` sont deja rendus dans les champs principaux du module;
- le bloc complementaire `Caractéristiques` ne rend plus un deuxieme `On / Off` quand le champ `online` existe deja, afin d'eviter les ids/names dupliques et le POST ambigu.

### Fichiers modifies
- `www/web/bo/master/bo_master_form.php`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/www/TASKS.md`

### Verification
- docs publiques consultees: `START.md`, `DOCS_MANIFEST.md`;
- journal AI Studio raw: non trouve dans la documentation a l'URL demandee, reponse 404;
- `php -l www/web/bo/master/bo_master_form.php` OK;
- TODO recette serveur: verifier selection/remplacement logo et hero depuis l'apercu, puis sauvegarde coche/de-coche du champ `Online` unique.

## WWW BO: fiche TdR assets LP reseau - 2026-05-13

### Resume
- la fiche client/TdR masque les dropzones LP reseau quand un logo ou visuel principal prioritaire existe deja;
- les apercus existants deviennent cliquables pour ouvrir le remplacement par nouvel upload;
- ajout d'une recommandation editoriale pour le visuel principal: image horizontale type 16:9, idealement 1600 x 900 px, elements importants centres;
- aucun changement du traitement serveur des images, qui reste compatible avec les visuels reseau panoramiques;
- les checkbox complementaires `On / Off` et `A la une` portent explicitement `value="1"` et restent sauvegardees par `module_modifier()`.

### Fichiers modifies
- `www/web/bo/master/bo_master_form.php`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/www/TASKS.md`

### Verification
- docs publiques consultees: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`;
- journal AI Studio raw: non trouve dans la documentation a l'URL demandee, reponse 404;
- `php -l www/web/bo/master/bo_master_form.php` OK;
- TODO recette serveur: verifier remplacement logo/hero par clic sur apercu, suppression via checkbox, fiche sans asset, et sauvegarde coche/de-coche de `On / Off` et `A la une`.

## Pro/Global: Stripe webhooks emails supprimes en livemode=false - 2026-05-13

### Audit
- docs publiques consultees: `START.md`, `DOCS_MANIFEST.md`;
- journal AI Studio raw: URL demandee testee, reponse serveur 404;
- points Stripe audites: `pro/web/ec/ec_webhook_stripe_handler.php` lignes 22-29 (validation event), 193-320 (`payment_intent.succeeded`), 595-846 (`invoice.paid`), 888-934 (`invoice.payment_failed`), 982-1060 (email admin webhook);
- emails indirects audites: `global/web/app/modules/ecommerce/app_ecommerce_functions.php` lignes 13136-13374 (`app_ecommerce_commande_ajouter`, Brevo admin commande + AI Studio `INVOICE_MONTHLY`);
- emails hors flux webhook Stripe audites et non modifies: `app_ecommerce_offre_client_abonnement_sans_engagement_resilier/reactiver`.

### Resume
- source canonique unique: `event.livemode`;
- `livemode=false`: suppression des emails de notification declenches par le webhook, avec log `[Stripe Webhook][Email Suppressed] livemode=false`;
- `livemode=true`: envois inchanges;
- livemode absent/illisible: envois inchanges et log `[Stripe Webhook][Livemode] Ambiguous...`;
- aucune deduction via champs Cotton opportunistes ni via prefixe `[ TEST ]`;
- synchronisations Stripe, commandes, factures, paiements, statuts et guards d'idempotence inchanges.

### Fichiers modifies
- `pro/web/ec/ec_webhook_stripe_handler.php`
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`

### Verification
- `php -l pro/web/ec/ec_webhook_stripe_handler.php` OK;
- `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK, avec warnings PHP preexistants sur parametres optionnels avant obligatoires;
- `git diff --check` OK dans `pro` et `global`;
- TODO recette serveur: rejouer un webhook `livemode=false`, un webhook `livemode=true`, et un payload ambigu pour confirmer emails/logs.

## WWW: LP reseau preuve sociale date TdR et micro UI - 2026-05-13

### Resume
- ajout de l'annee de creation du compte TdR dans le sur-titre du bloc preuve sociale, via `clients.date_ajout` deja charge par `app_client_get_detail(...)`;
- affichage public conditionne a une date exploitable et non `0000-00-00`;
- libelle rendu: `{Nom_TdR} x Cotton depuis YYYY`;
- ajustement CSS des cartes stats: largeur homogène portee a 252px, pictogrammes recentres optiquement dans leur pastille et libelles courts en `nowrap`.

### Fichiers modifies
- `www/web/lp/lp.php`
- `www/web/lp/includes/css/lp_custom.css`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/www/TASKS.md`

### Verification
- docs publiques consultees: `START.md`, `DOCS_MANIFEST.md`;
- journal AI Studio raw: non trouve dans la documentation a l'URL demandee, reponse 404;
- schema relu: `clients.date_ajout` existe dans `documentation/canon/data/schema/DDL.sql`;
- `php -l www/web/lp/lp.php` OK.

## WWW: LP reseau bloc preuve sociale largeur adaptive - 2026-05-13

### Resume
- ajustement UI uniquement du bloc `operation-network-proof`;
- ajout d'une classe `lp-operation-proof-count-{n}` pour piloter largeur du panneau, nombre de colonnes et largeur homogene des cartes selon 1, 2 ou 3 indicateurs;
- le fond du bloc reutilise `--lp-operation-soft-bg`, deja applique aux fonds des cartes demos reseau via `.lp-operation-page #section-03 .bg-color-7`;
- les cartes stats restent blanches, avec bordure/ombre plus douces, pictogramme dans une pastille legere et accents reseau limites aux chiffres/pictos;
- padding haut reduit (`pt-1 pt-lg-2`) et padding bas resserre (`pb-4`), sans changer la position generale du bloc.

### Fichiers modifies
- `www/web/lp/lp.php`
- `www/web/lp/includes/css/lp_custom.css`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/www/TASKS.md`

### Verification
- docs publiques consultees: `START.md`, `DOCS_MANIFEST.md`;
- journal AI Studio raw: non trouve dans la documentation a l'URL demandee, reponse 404;
- `php -l www/web/lp/lp.php` OK;
- TODO recette serveur: verifier visuellement les variantes 3 indicateurs, 2 indicateurs, 1 indicateur fort, sans bloc stats, desktop large et mobile.

## Documentation: seuils preuve sociale LP reseau - 2026-05-12

### Resume
- clarification canon des seuils commerciaux V1 du bloc preuve sociale LP reseau;
- `global/README.md` documente maintenant les seuils affichables, les seuils signal fort et la regle d'affichage;
- `global/TASKS.md` et `www/TASKS.md` reprennent les valeurs exactes pour eviter que la regle ne vive seulement dans le handoff.

### Fichiers modifies
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/HANDOFF.md`

### Verification
- docs publiques consultees: `START.md`, `DOCS_MANIFEST.md`;
- journal AI Studio raw: non trouve dans la documentation a l'URL demandee, reponse 404;
- TODO: regenerer le sitemap documentaire.

## WWW: LP reseau bloc preuve sociale UI - 2026-05-12

### Resume
- amelioration visuelle uniquement du bloc `operation-network-proof` sous les demos;
- les indicateurs restent fournis par `app_client_network_lp_stats_get(...)` sans changement de requetes, seuils ou logique d'affichage;
- le rendu utilise maintenant des cartes statistiques avec pictogramme SVG, chiffre grand format et labels courts;
- les SVG des pictogrammes sont bornes a 24px en attributs HTML et CSS local pour eviter les styles globaux de la LP;
- le bloc est recentre en panneau compact et son padding haut est reduit pour rapprocher les stats des demos;
- la grille est pilotee par le nombre d'indicateurs affiches: 1 carte centree, 2 cartes centrees, 3 cartes en ligne desktop, puis pile mobile;
- les accents reutilisent les variables LP reseau via `--lp-operation-accent` / `--lp-network-primary`.

### Fichiers modifies
- `www/web/lp/lp.php`
- `www/web/lp/includes/css/lp_custom.css`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/www/TASKS.md`

### Verification
- docs publiques consultees: `START.md`, `DOCS_MANIFEST.md`;
- journal AI Studio raw: non trouve dans la documentation a l'URL demandee, reponse 404;
- `php -l www/web/lp/lp.php` OK;
- `git diff --check` execute dans `www` OK, avec warnings CRLF uniquement;
- TODO recette serveur: verifier visuellement LP avec 3 indicateurs, 2 indicateurs, 1 indicateur fort, et sans bloc stats, en desktop large et mobile.

## WWW/Global: LP reseau bloc preuve sociale - 2026-05-12

### Audit
- resolution TdR LP: `www/web/lp/lp.php` appelle `lp_operation_public_network_get($utm_term)`, resout `clients` via `module_get_id('clients', slug)` puis exige `flag_client_reseau_siege=1`;
- affilies: donnees simples via `clients.id_client_reseau`, deja utilisees dans l'espace reseau Pro et le widget resume reseau;
- sessions: donnees simples via `championnats_sessions` joint a `clients`, meme filtre public que l'espace reseau (`flag_session_demo=0`, `flag_configuration_complete=1`);
- joueurs: fiable seulement via les agregats `reporting_games_players_monthly` / cron `bo_facturation_pivot_games_aggregates_refresh(...)`; recalcul runtime direct exclu de la V1 car couteux et heterogene selon les jeux;
- journal AI Studio raw: non trouvé dans la documentation a l'URL demandee, reponse 404 ou serveur inaccessible selon tentative.

### Resume
- ajout de `app_client_network_lp_stats_get($id_client_reseau)`;
- application serveur des seuils V1: affilies >= 3, sessions >= 5, joueurs >= 100;
- exception signal fort: affilies >= 20, sessions >= 50 ou joueurs >= 1000;
- la LP affiche le bloc uniquement si au moins 2 indicateurs passent, ou un seul tres fort;
- le bloc public est rendu sous les demos, limite a 3 indicateurs, sans compteur a 0 ni fallback generique.

### Fichiers modifies
- `global/web/app/modules/entites/clients/app_clients_functions.php`
- `www/web/lp/lp.php`
- `www/web/lp/includes/css/lp_custom.css`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`

### Verification
- docs publiques consultees: `START.md`, `DOCS_MANIFEST.md`, `canon/repos/www/README.md`, schema `DDL.sql`;
- `php -l global/web/app/modules/entites/clients/app_clients_functions.php` OK;
- `php -l www/web/lp/lp.php` OK;
- `git diff --check` execute dans `global`, `www` et `documentation` OK, avec warnings CRLF uniquement;
- TODO recette serveur: TdR sous seuils, deux indicateurs OK, un indicateur tres fort, agregat joueurs absent/vide.

## WWW: LP reseau logos hero alignes - 2026-05-12

### Resume
- ajustement visuel limite a `www/web/lp/includes/css/lp_custom.css`;
- le bloc hero LP reseau/operation affiche maintenant les logos a gauche au-dessus du badge periode/statut;
- le badge periode/statut est place sur sa propre ligne sous les logos, avec une largeur adaptee a son contenu;
- le hero n'affiche plus le badge quand il ne porte qu'un statut generique sans dates;
- les pastilles logo partenaire et Cotton sont agrandies sur desktop et mobile;
- aucun changement de markup, route, CTA, formulaire demo, resolution TdR ou logique abonnement.

### Fichiers modifies
- `www/web/lp/includes/css/lp_custom.css`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/www/TASKS.md`

### Verification
- docs publiques consultees: `START.md`, `SITEMAP.txt`, `SITEMAP.ndjson`, `DOCS_MANIFEST.md`, `canon/repos/www/INDEX.md`;
- journal AI Studio raw: non trouvé dans la documentation a l'URL demandee et a la variante canonique START/manifest, les deux repondent 404;
- `php -l www/web/lp/lp.php` OK;
- `git diff --check` execute dans `www` et `documentation` OK.
- TODO recette serveur: verifier LP avec logo partenaire, fallback Cotton seul, badge dates, badge `Animation cle en main`, desktop/mobile.

## Pro/Global: signup/signin affilies habilles par assets LP TdR - 2026-05-12

### Resume
- audit confirme: `/utm/reseau/{slug}` est route vers `pro/web/ec/ec_sign.php`, qui resout le slug TdR, pose `$_SESSION['id_client_reseau']`, puis redirige vers `signup`;
- `signup` et `signin` lisaient deja ce contexte pour le branding reseau historique via `app_client_branding_get_detail(...)`;
- le nouveau helper `app_client_signup_network_theme_get(...)` priorise maintenant logo et visuel LP reseau du compte TdR, puis conserve les fallbacks historiques element par element;
- le rendu Pro applique le visuel LP en fond avec un filtre integre au `background-image`, sans pseudo-element d'overlay visible au scroll;
- le logo TdR au-dessus du formulaire reprend le style pastille blanc/bordure/ombre de la LP reseau;
- les couleurs LP reseau ne sont plus appliquees cote signup/signin, afin d'eviter un risque de lisibilite sans controle de teinte dedie;
- aucune logique de formulaire, de rattachement, d'activation ou de CTA n'est modifiee.

### Fichiers modifies
- `global/web/app/modules/entites/clients/app_clients_functions.php`
- `pro/web/ec/ec_signup.php`
- `pro/web/ec/ec_signin.php`
- `pro/web/ec/includes/css/ec_custom.css`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`

### Verification
- docs raw consultees: `START.md`, `SITEMAP.txt`, `SITEMAP.ndjson`, `DOCS_MANIFEST.md`, journal AI Studio raw;
- journal AI Studio: zones sensibles identifiees `web/lp/lp.php`, `web/lp/includes/css/lp_custom.css`, `pro/ec/modules/compte/authentification/ec_authentification_script.php`, `global/app/modules/ecommerce/app_ecommerce_functions.php`;
- `php -l pro/web/ec/ec_signup.php` OK;
- `php -l pro/web/ec/ec_signin.php` OK;
- `php -l global/web/app/modules/entites/clients/app_clients_functions.php` OK;
- TODO recette serveur: tester `/utm/reseau/{slug}`, lien direct deja resolu en session, signup/signin sans affiliation, et fallback branding historique sans assets LP dedies.

## WWW/Global: echeance automatique Abonnement reseau - 2026-05-11

### Resume
- le cron `www/web/bo/cron_routine_bdd_maj.php` traite maintenant explicitement les `Abonnement reseau` actifs dont `date_fin < CURDATE()`;
- le support reseau passe en `Terminee` (`id_etat=4`) en conservant sa `date_fin`, puis reutilise la finalisation reseau canonique pour archiver le runtime et fermer les incluses actives;
- les offres deleguees incluses liees par `reseau_id_offre_client_support_source` recoivent la meme `date_fin` que le support lors de leur creation et lors d'une sauvegarde BO du support;
- la synchronisation ne touche pas les offres propres, les offres hors cadre, ni les incluses deja terminees.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `www/web/bo/cron_routine_bdd_maj.php`
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`

### Verification
- docs publiques consultees: `START.md`, `DOCS_MANIFEST.md`, `canon/repos/www/README.md`, `notes/plan_migration_reseau_branding_contenu.md`, journal AI Studio raw;
- journal AI Studio: non trouve dans la documentation pour un patch recent sur `cron_routine_bdd_maj.php` ou `offres_clients` concernant cette echeance; seule une ancienne mention emails transactionnels concerne `global/app/modules/ecommerce/app_ecommerce_functions.php`;
- `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK, avec deux deprecations preexistantes sur parametres optionnels avant requis;
- `php -l www/web/bo/cron_routine_bdd_maj.php` OK;
- `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK;
- TODO recette serveur: cas A/B/C/D/E de cloture, propagation, hors cadre et idempotence sur donnees dev.

## WWW/Global: couleurs LP reseau dediees TdR - 2026-05-12
- contexte:
  - l'etat local `www`/`global` est la base de travail validee pour les amenagements LP reseau en cours;
  - audit Pro confirme que la page design reseau utilise un input couleur + preview, sans composant existant de prelevement couleur depuis image.
- actions realisees:
  - ajout des helpers globaux `app_client_lp_color_normalize`, `app_client_lp_colors_schema_ensure`, `app_client_lp_colors_get`, `app_client_lp_colors_save`;
  - ajout lazy-init des colonnes `clients.lp_reseau_couleur_principale` et `clients.lp_reseau_couleur_secondaire`;
  - ajout d'un script SQL manuel `documentation/lp_reseau_couleurs_clients_phpmyadmin.sql`;
  - ajout des champs BO au meme endroit que logo/visuel prioritaires LP, avec picker couleur, champ hex et apercu;
  - sauvegarde BO des couleurs au format strict `#RRGGBB`, valeurs invalides neutralisees;
  - lecture LP prioritaire des couleurs TdR dediees avant les couleurs du design reseau;
  - exposition CSS `--lp-network-primary` et `--lp-network-secondary`, avec fallbacks existants conserves.
- fichiers modifies:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `www/web/bo/master/bo_master_form.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
  - `documentation/lp_reseau_couleurs_clients_phpmyadmin.sql`
  - docs canon `www`/`global`, `CHANGELOG.md`, `HANDOFF.md`
- docs touchees:
  - `canon/repos/www/README.md`
  - `canon/repos/www/TASKS.md`
  - `canon/repos/global/README.md`
  - `canon/repos/global/TASKS.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- next steps:
  - recette serveur BO: verifier couleurs valides/vides/invalides sur une TdR reelle;
  - recette LP: verifier TdR avec couleurs LP, sans couleurs LP, avec/sans design reseau, avec/sans abonnement actif;
  - amelioration future eventuelle: prelevement couleur depuis logo/visuel LP si un composant image/pipette est cree ou importe plus tard.

## WWW/Global: demos LP reseau - A la une + rattachement TdR - 2026-05-11

### Resume
- la LP reseau/operation conserve la priorite stricte des contenus reseau definis par la TdR;
- si aucun contenu reseau n'est disponible, les trois demos fallback cherchent maintenant une entree `A la une` exploitable par jeu: 1 Blind Test, 1 Bingo Musical, 1 Cotton Quiz;
- la selection reprend les criteres de la bibliotheque PRO quand ils sont disponibles localement: contenus Cotton online, saison courante via `jour_associe_debut/fin`, puis popularite 365 jours, avec fallback stable existant par jeu;
- les formulaires demo LP transmettent seulement un contexte public (`reseau`/`operation`) et le slug public;
- les scripts demo resolvent cote serveur le compte TdR associe au slug et creent la session demo sur ce compte quand il est valide;
- hors LP reseau/operation, les demos gardent le compte historique `1557`;
- les garde-fous demo restent inchanges: session demo, privee, non officielle, non facturable, sans droit BO/pro pour le visiteur.

### Fichiers modifies
- `www/web/lp/lp.php`
- `www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_script.php`
- `www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_script.php`
- `www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_script.php`
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/global/TASKS.md`

### Verification
- docs publiques consultees: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, `canon/repos/www/README.md`, `canon/repos/pro/README.md`, journal AI Studio raw;
- fichiers potentiellement modifies hors workspace signales par le journal AI Studio: `web/lp/lp.php`, `web/lp/includes/css/lp_custom.css`, `web/fo/modules/communication/home/fr/fo_home_index.php`, `web/fo/modules/communication/statique/fr/fo_statique_features_presentation_generale.php`, `global/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`;
- `php -l www/web/lp/lp.php`;
- `php -l www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_script.php`;
- `php -l www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_script.php`;
- `php -l www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_script.php`;
- `php -l global/web/app/modules/jeux/sessions/app_sessions_functions.php`;
- TODO recette serveur: LP avec contenus reseau, LP sans contenus reseau avec `A la une`, LP sans selection exploitable, design reseau present/absent, demo standard hors LP.

## WWW: UI branding LP reseau / operation - 2026-05-11

### Resume
- ajustement additif: les logos hero passent en petites pastilles separees au lieu d'un grand cartouche commun, pour eviter que le co-branding domine le hero;
- ajustement additif: le bandeau 3 arguments n'utilise plus la couleur secondaire en aplat; il derive maintenant une teinte claire de la couleur de fond hero, avec fallback blanc sans design reseau;
- le hero LP reseau/operation affiche maintenant un co-branding discret `[logo partenaire] x [logo Cotton]` quand le logo TdR/reseau existe; sinon Cotton reste seul mais reduit;
- le bandeau 3 arguments utilise un fond plus doux, derive prudemment de la couleur secondaire reseau quand elle est exploitable, sinon fallback neutre; le premier argument passe au tutoiement;
- le bloc contexte n'est plus un fallback generique: il s'affiche seulement si la surcouche BO d'abonnement reseau est active et qu'un contenu exploitable existe (titre, accroche, description, logo ou visuel);
- le bloc contexte rendu adopte une carte blanche avec label `Invitation partenaire`, accent couleur reseau, logo ou visuel disponible, sans ajout de champ BO;
- les accents reseau alimentent les titres de section et les numeros du mode d'emploi, avec fallback Cotton/neutre;
- aucun changement de route, href CTA, formulaire demo, logique d'affiliation, champ BO ou schema DB.

### Fichiers modifies
- `www/web/lp/lp.php`
- `www/web/lp/includes/css/lp_custom.css`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`

### Verification
- docs publiques consultees: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, `canon/repos/www/README.md`, journal AI Studio raw;
- fichiers potentiellement modifies hors workspace signales par le journal AI Studio: `web/lp/lp.php`, `web/lp/includes/css/lp_custom.css`, `web/fo/modules/communication/home/fr/fo_home_index.php`, `web/fo/modules/communication/statique/fr/fo_statique_features_presentation_generale.php`, `global/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`;
- `php -l www/web/lp/lp.php`;
- grep local: les fallbacks generiques du bloc contexte ne sont plus presents dans le rendu reseau; les occurrences `Lancez votre jeu` restantes appartiennent a d'autres LP historiques du switch;
- TODO recette serveur: verifier LP sans surcouche BO (bloc contexte masque), LP avec surcouche active et contenu, co-branding avec/sans logo partenaire, actif avec dates, inactif, jeux reseau/fallback, desktop/mobile.

## WWW: passe editoriale LP reseau / operation - 2026-05-11

### Resume
- la LP reseau/operation remet le partenaire au premier plan: le hero dit maintenant `{TdR} t'invite a animer ton etablissement` avec abonnement actif, ou `{TdR} t'invite a rejoindre son espace d'animation` sans abonnement actif;
- les CTA publics gardent le meme href `/utm/reseau/{slug_tdr_canonique}` mais deviennent `Lancer une premiere animation` avec abonnement actif et `Participer avec mon etablissement` sans abonnement actif;
- les badges fallback deviennent `Animations incluses` et `Invitation partenaire`; les badges dates `Du ... au ...` / `Jusqu'au ...` restent inchanges;
- le bloc contexte conserve la priorite BO/TdR/fallback, avec un fallback generique centre sur le dispositif plutot que sur Cotton;
- la section demos parle d'animations proposees/pretes a lancer, le CTA devient `Voir une animation exemple`, la modale mobile passe au tutoiement et le HTML du mode d'emploi n'injecte plus de `<p>` dans un `<p>`;
- aucune route, affiliation, DB, champ BO, formulaire demo ou logique de selection d'abonnement n'a ete modifie.

### Fichiers modifies
- `www/web/lp/lp.php`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`

### Verification
- docs publiques consultees: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, `canon/repos/www/README.md`, journal AI Studio raw;
- fichiers potentiellement modifies hors workspace signales par le journal AI Studio: `web/lp/lp.php`, `web/lp/includes/css/lp_custom.css`, `web/fo/modules/communication/home/fr/fo_home_index.php`, `web/fo/modules/communication/statique/fr/fo_statique_features_presentation_generale.php`, `global/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`;
- `php -l www/web/lp/lp.php`;
- `rg -n "t'offre des jeux Cotton|Jeux Cotton offerts|Invitation Cotton|Profiter de mes jeux|Rejoindre Cotton|Teste les jeux selectionnes|Teste les jeux cle en main|Faites la demo|Ouvrir la demo du jeu" www/web/lp/lp.php www/web/lp/includes/css/lp_custom.css` OK pour les wordings cibles;
- TODO recette serveur: verifier une LP active avec date fin, active sans date fiable, inactive, avec/sans surcouche BO, avec jeux reseau et fallback 3 jeux, desktop/mobile.

## WWW: simplification marketing LP reseau / surcouche BO - 2026-05-11

### Resume
- hero LP reseau standardise: sans abonnement actif, badge `Invitation Cotton`, titre `{TdR} t'invite a rejoindre Cotton`, CTA `Rejoindre Cotton ->` et aucune promesse gratuite/offerte; avec abonnement actif, badge periode ou `Jeux Cotton offerts`, titre `{TdR} t'offre des jeux Cotton`, CTA `Profiter de mes jeux ->` et wording gratuit uniquement dans ce cas;
- CTA public force sur `/utm/reseau/{slug_tdr_canonique}` apres resolution de la TdR; le slug courant/public n'est pas reutilise comme cible;
- ordre public: hero, bandeau 3 arguments Cotton, bloc contexte reseau/operation, puis jeux reseau ou fallback 3 jeux historiques;
- les champs BO `Titre public LP`, `Accroche LP`, `Description courte LP` ne pilotent plus le hero: ils alimentent seulement le bloc de contexte sous le bandeau, si l'abonnement reseau est actif et la surcouche active;
- fallback design: le badge reprend la couleur secondaire du design reseau quand elle existe, avec couleur texte calculee par contraste; sinon fallback Cotton historique;
- BO: le bloc devient `Contexte affiche sur la LP reseau`, retire les champs CTA visibles et garde le slug public comme champ de compatibilite non exploite V1.

### Fichiers modifies
- `www/web/lp/lp.php`
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- `www/web/lp/includes/css/lp_custom.css`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`

### Verification
- docs publiques consultees: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, `HANDOFF.md`, `canon/repos/www/README.md`, `canon/repos/global/README.md`, journal AI Studio raw;
- `php -l www/web/lp/lp.php`;
- `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`;
- `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`;
- `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`;
- `rg -n "LE RÉSEAU|L’OPÉRATION|Le parcours suivant|Rejoignez Cotton avec votre réseau|abonnement inclus|Libellé CTA|RÃ|Ã©|Ã¨|Ãª" www/web/lp www/web/bo/www/modules/ecommerce/offres_clients` OK;
- `git diff --check` execute sur le depot `www` OK;
- note: `rg -n "operations_evenements|lp_operations"` remonte encore `bo_module_parametres.php` sur un champ BO generique preexistant non modifie par ce correctif.
- TODO recette serveur: inspecter le href CTA et cliquer le tunnel `/utm/reseau/{slug_tdr}` sur une TdR reelle avec/sans abonnement actif.

## WWW/Global: LP reseau enrichie par abonnement reseau — 2026-05-11

### Resume
- cadrage produit: un distributeur partenaire est une TdR; une operation commerciale est portee en V1 par l'abonnement reseau, pas par `operations_evenements`;
- DB: ajout runtime d'une table dediee `ecommerce_reseau_support_lp_settings`, rattachee a `ecommerce_offres_to_clients.id` pour stocker la personnalisation LP sans alourdir la ligne d'offre client;
- BO: la fiche custom `Abonnement reseau` dans `offres_clients` affiche un bloc `Page reseau / operation` uniquement pour les offres support reseau;
- LP: `/lp/reseau/{slug}` devient l'entree publique recommandee, `/lp/operation/{slug}` reste une compatibilite qui reutilise la meme source TdR/reseau;
- la landing continue d'exister sans abonnement actif: badge hero `Invitation Cotton`, CTA `Rejoindre Cotton`, aucune promesse d'acces inclus;
- avec abonnement reseau actif: la LP utilise l'abonnement actif le plus recent, applique les champs personnalises si `flag_active=1`, affiche les dates seulement si debut et fin sont fiables, et garde le CTA vers `/utm/reseau/{slug}`;
- l'affiliation et l'activation d'offre incluse restent portees par les helpers existants du parcours PRO; aucun tunnel parallele n'a ete cree.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
- `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- `www/web/lp/lp.php`
- `www/web/lp/includes/css/lp_custom.css`
- `www/web/.htaccess`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/entrypoints.md`
- `documentation/canon/runbooks/dev.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- journal AI Studio raw consulte avant patch; vigilance sur `web/lp/lp.php`, `web/lp/includes/css/lp_custom.css`, `web/.htaccess`, `web/fo/fo.php`, scripts PRO d'authentification et `global/web/app/modules/ecommerce/app_ecommerce_functions.php`;
- docs publiques lues: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`;
- PHP local non executable dans cet environnement Windows (`php.exe` access denied / indisponible selon tentative);
- `npm run docs:sitemap` non execute: `npm` absent du PATH local;
- `git diff --check`;
- TODO recette serveur: verifier `/lp/reseau/{slug}` et compat `/lp/operation/{slug}` sur TdR sans support actif, support actif sans personnalisation, support actif personnalise, support actif dates incompletes, plusieurs supports actifs, et offre non reseau.

> Note: les entrées plus bas restent un historique de livraison. Pour TdR/Affiliés, l'état courant de référence est celui décrit dans la première section ci-dessous.

## WWW: landings operations distributeurs / marques — 2026-05-07

### Resume
- demande: creer une V1 minimale maintenable pour des landings publiques d'operations distributeurs / marques dans `www/web/lp`;
- architecture retenue: `TdR = operation`, CTA vers `/utm/reseau/{slug_operation}`, puis parcours PRO existant d'affiliation/signup/signin;
- correction historique V1: ajout d'une configuration dediee `lp_operations.php`; depuis le patch 2026-05-11, cette configuration n'est plus la source de verite et la publication standard vient d'une operation BO rattachee a une TdR, ou de la TdR en fallback;
- rendu: nouvelle variante operation avec logos Cotton/reseau, periode, bloc offre commerciale, bloc animation Cotton, clarification obligatoire et CTA sur le lien reseau existant;
- branding: tentative de lecture publique du compte reseau et du branding reseau via les helpers existants, avec fallback Cotton si le reseau ou son branding n'est pas disponible;
- routing: ajout de `/lp/operation/{slug}` cote `www`, qui alimente la landing avec `utm_source=reseau`, `utm_campaign=affiliation` et `utm_medium=landing-operation`;
- garde-fou: une route operation sans configuration active renvoie une page 404 simple au lieu de retomber sur la landing `offre-essai`.
- addendum: la landing utilise maintenant le `visuel` du design reseau comme hero si `hero_image` est vide en configuration;
- addendum: les contenus reseau actifs et exploitables de la TdR operation sont lus via `app_ecommerce_reseau_content_share_ids_get(...)`; si au moins un contenu reseau existe, le bloc demo n'affiche que ces jeux, sinon il conserve les demos Cotton generiques;
- addendum: les vignettes catalogue sont reprises quand un asset public existe; sinon les images generiques par jeu restent affichees;
- addendum signup/signin: la landing affiche deux actions (`Activer mon acces Cotton`, `J'ai deja un compte Cotton`) mais les deux conservent le lien reseau `/utm/reseau/{slug}` pour laisser PRO gerer session, signup, signin, rattachement et activation incluse.

### Fichiers modifies
- `www/web/lp/lp.php`
- `www/web/lp/includes/config/lp_operations.php`
- `www/web/lp/includes/css/lp_custom.css`
- `www/web/.htaccess`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/entrypoints.md`
- `documentation/canon/runbooks/dev.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- journal AI Studio raw consulte avant patch; vigilance sur `web/lp/lp.php`, `web/lp/includes/css/lp_custom.css`, `web/.htaccess`, `web/fo/fo.php`, scripts PRO d'authentification et `global/web/app/modules/ecommerce/app_ecommerce_functions.php`;
- docs publiques lues: `START.md`, `SITEMAP.txt`, `SITEMAP.ndjson`, `DOCS_MANIFEST.md`;
- `php -l /home/romain/Cotton/www/web/lp/lp.php`;
- `php -l /home/romain/Cotton/www/web/lp/includes/config/lp_operations.php`;
- `git diff --check`;
- TODO recette serveur: verifier `/lp/operation/operation-test-distributeur`, priorite `hero_image` > visuel reseau > fallback Cotton, contenus reseau partages, lien `/utm/reseau/{slug}`, signup nouveau compte, signin compte existant et cas support reseau inactif/quota atteint.

## Pro: affiliation TdR via signin compte existant — 2026-05-06

### Resume
- demande: auditer puis corriger le parcours `lien affiliation TdR -> signup -> signin -> compte existant`;
- audit: le lien public `/utm/reseau/{seo_slug}` arrive par `www/web/.htaccess` puis `www/web/fo/fo.php`, avant redirection vers `pro/web/ec/ec_sign.php`;
- cause: le signup nouveau compte consommait deja `$_SESSION['id_client_reseau']`, mais le signin compte existant initialisait la session sans rattacher le client;
- correction: apres authentification reussie, `ec_authentification_script.php` consomme `$_SESSION['id_client_reseau']` et appelle le helper central `app_ecommerce_reseau_affilier_client(..., 'signup_affiliation')`;
- garde-fou: si le compte existant est deja rattache a une autre TdR, aucune reaffectation automatique n'est faite;
- addendum: ce garde-fou affiche maintenant un flash PRO explicite apres connexion, sans exposer le nom de l'autre reseau.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- journal AI Studio raw consulte avant patch; vigilance sur `global/web/app/modules/ecommerce/app_ecommerce_functions.php`, mais le patch n'a pas modifie ce fichier;
- docs publiques lues: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, `canon/repos/pro/README.md`, `notes/plan_migration_reseau_branding_contenu.md`;
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/authentification/ec_authentification_script.php`;
- `php -l /home/romain/Cotton/pro/web/ec/ec.php`;
- TODO recette serveur: rejouer les scenarios compte existant sans offre, sans quota/support, avec offre propre active, deja rattache meme reseau, deja rattache autre TdR.

## Global/Pro: Stripe ABN pipeline CSO apres cloture — 2026-05-06

### Resume
- demande: corriger le cas ou Stripe termine bien l'offre ABN Cotton, mais ou le client reste en pipeline `ABN` au lieu de repasser `CSO`;
- audit: le webhook central est `pro/web/ec/ec_webhook_stripe_handler.php`;
- correctif precedent identifie: `app_ecommerce_stripe_subscription_terminal_sync(...)` dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php` passe l'offre en `id_etat=4`;
- cause: cette cloture terminale ne recalculait pas le pipeline du client direct, contrairement a certains parcours internes;
- correction: ajout de `app_ecommerce_client_pipeline_sync_from_effective_offer(...)`, basee sur `app_ecommerce_offre_effective_get_context(...)`;
- appel: apres cloture Stripe effective dans `app_ecommerce_stripe_subscription_terminal_sync(...)`, uniquement pour les offres directes hors support reseau;
- comportement: conserve `ABN` si une autre offre abonnement active existe, bascule `PAK` si l'offre active restante est un pack, repasse `CSO` si aucun acces effectif ne reste, preserve `INS`;
- idempotence: un replay Stripe ne change rien si l'offre est deja terminee et si le pipeline cible est deja en place.

### Fichiers modifies
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`

### Verification
- journal AI Studio raw consulte avant patch; risque d'ecart identifie sur `global/web/app/modules/ecommerce/app_ecommerce_functions.php`, a recharger depuis serveur si la prod/dev distante fait foi;
- docs publiques lues: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, `canon/repos/www/README.md`;
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`;
- `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php`;
- TODO recette serveur: rejouer `customer.subscription.deleted` ou `customer.subscription.updated status=canceled` sur un client ABN mono-offre, multi-offres, et replay identique.

## WWW: parcours demos catalogue public — 2026-05-06

### Resume
- demande: rendre les demos plus directes depuis `/fr/jeux` et aligner les fiches detail Blind Test / Bingo Musical / Cotton Quiz sur un choix `Démo complète / Démo rapide`;
- audit: les catalogues publics existent deja (`/fr/jeux/cotton-blind-test/catalogue`, `/fr/jeux/bingo-musical/catalogue`, `/fr/jeux/cotton-quiz/catalogue`); les fiches detail sont rendues par les trois templates `*_catalogue_view.php`;
- correction `/fr/jeux`: CTA principal renomme `Démos du jeu`, image et CTA vers catalogue, lien secondaire discret `Découvrir le jeu` vers la presentation;
- correctif addendum: le partial commun `fo_demo_choice.php` a ete retire car il inversait la priorite visuelle et modifiait des labels/parcours non demandes;
- correction fiches detail: reprise de la structure prod rechargee via `fo_portail_jeux_demo_signup.php`, avec `Démo complète` prioritaire et badge `Recommandé`;
- wording conserve uniquement sur la presentation de la demo rapide: texte desktop et texte mobile conditionnels dans le partial commun;
- Cotton Quiz reutilise le partial commun comme Blind Test/Bingo Musical, sans ajouter de CTA `Je commande` actif dans ce bloc;
- modale mobile: retiree dans le partial commun car le nouveau wording mobile rend l'etape redondante; le CTA mobile lance directement la demo rapide.
- ajustement UX suivant: le lien secondaire `Découvrir le jeu` est rattache au bouton `Démos du jeu` dans les cartes `/fr/jeux`, replace a cote du bouton principal et colore/souligne au hover selon le jeu; la mention `NEW ! Testez la nouvelle version du Cotton Quiz !` est retiree de la fiche detail serie; le micro-texte mobile de demo rapide est raccourci et compacte.

### Fichiers modifies
- `www/web/fo/modules/widget/fr/fo_widget_cotton_jeux_blocs.php`
- `www/web/fo/modules/jeux/portail/fr/fo_portail_jeux_demo_signup.php`
- `www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_catalogue_view.php`
- `www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_catalogue_view.php`
- `www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_catalogue_view.php`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/repos/www/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/SITEMAP.md`, `SITEMAP.txt`, `SITEMAP.ndjson` et index generes par `npm run docs:sitemap`

### Verification
- journal AI Studio raw tente avant patch via URL prompt et URL START; les deux repondent 404, donc aucun fichier serveur hors workspace n'a pu etre identifie a recharger;
- docs publiques lues: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, `canon/repos/www/README.md`, `canon/repos/www/TASKS.md`, `HANDOFF.md`, `CHANGELOG.md`;
- `php -l` OK sur les 4 fichiers PHP modifies cote `www`;
- TODO navigateur: verifier `/fr/jeux`, une fiche detail par jeu, desktop/mobile responsive, clics image/CTA/lien secondaire, modale mobile et actions demo conservees.

## Games: Demo site mobile CTA lancement — 2026-05-06

### Resume
- demande: rendre explicite le bouton rond de lancement mobile organizer uniquement pour les demos publiques du site Cotton Online Demos;
- audit rendu: le bouton est `#play-pause-btn` dans la barre `.organisateur-menu`, mis a jour par `setMenuControls()` dans `canvas_display.js`;
- audit condition: les scripts publics `www` creent ces demos avec `id_client=1557` et `flag_session_demo=1`; `organizer_canvas.php` expose deja `AppConfig.idClient` et `AppConfig.isDemoSession`;
- correction: en mobile numerique, en attente, si le bouton de lancement est la seule action visible de la barre et que `isDemoSession && idClient === 1557`, le libelle devient `Lancer la démo`;
- style: le bouton conserve les classes existantes `btn btn-primary orga-btn px-4`; un selecteur attribut neutralise seulement la regle mobile qui force le rond et masque le `span`;
- hors scope conserve: demos clients, sessions officielles, sessions papier, serveurs WS, `bingo.game`, logique Quiz / Blind Test / Bingo.

### Fichiers modifies
- `games/web/includes/canvas/core/canvas_display.js`
- `games/web/includes/canvas/css/canvas_styles.css`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`
- `documentation/SITEMAP.md`
- `documentation/SITEMAP.txt`
- `documentation/SITEMAP.ndjson`
- `documentation/**/INDEX.md` generes par `npm run docs:sitemap`

### Verification
- journal AI Studio raw consulte avant patch; aucune entree `games` recente a recharger hors workspace local;
- docs publiques lues: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`;
- TODO technique: `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`, `git diff --check main...develop`, `git diff --check main`;
- TODO navigateur: demo publique site Cotton Online Demos mobile, demo client mobile, session officielle mobile, Bingo demo reset/relance.

## Games: Bingo reset demo termine — 2026-05-05

### Resume
- demande: corriger le reset demo Bingo apres fin de partie pour organizer, iframe `embed=gm` et joueur QR, sans traiter le bug comme un simple localStorage iframe;
- point d'audit: la prod fonctionne sans patch WS et `bingo.game/ws` ne diverge pas entre prod et develop sur ce flux, donc aucun changement WS n'est conserve;
- source DB verifiee cote code: `resetdemo` remet `phase_courante=0`, `morceau_courant=0`, supprime logs/winners/lots, remet les timestamps de grilles et vide `bingo_players.gain_phase`;
- correction front organizer: apres `resetdemo` OK, le store local Bingo repasse en `En attente`, les winners/medailles/podium sont vides, et le signal post-reset est conserve jusqu'a consommation par `canvas_display.js`;
- correction iframe GM: `canvas_display.js` consomme le signal pending apres attachement du listener et recharge/reconfigure l'iframe joueur;
- correction snapshots: un snapshot Bingo demo phase `0` purge les winners/medailles/podium front precedents;
- correction player: `demo_reset` annule aussi les flags locaux de fin statique/reconnexion supprimee avant reset UI/reload.
- addendum iframe GM: le reset demo ecrit `bingo_reset_epoch:{sessionId}`, purge les anciennes cles checked/locked scoppées a la session, transmet l'epoch dans l'URL iframe (`bingo_reset_epoch`) et l'inclut dans les nouvelles cles locales;
- addendum traces: `ui/bingo:grid_hydrate:trace` indique maintenant l'epoch, counts local/DB et la source appliquee (`local`, `db`, `empty`, `reset`).
- addendum relance iframe GM: `play-ws.js` consomme le runtime post-reset sur les signaux live Bingo demarres (`state`, `reset_game`, `passed_song`), remet `mainStarted=true` et trace `ui/bingo:postreset:consumed`, `ui/bingo:start_after_reset:received` et `ui/bingo:start_after_reset:applied`.

### Fichiers modifies
- `games/web/includes/canvas/core/boot_organizer.js`
- `games/web/includes/canvas/core/canvas_display.js`
- `games/web/includes/canvas/core/games/bingo_ui.js`
- `games/web/includes/canvas/play/play-ui.js`
- `games/web/includes/canvas/play/play-ws.js`
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/data/bingo-write-map.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- journal AI Studio raw consulte avant patch; aucune entree `games` / `bingo.game` recente a recharger hors workspace local;
- docs publiques lues: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, cartes `games` / `bingo.game`;
- TODO navigateur: refaire Bingo demo terminee -> reset demo avec organizer, iframe GM et joueur QR, puis reloads separes.

## Games: Bingo GM iframe grille cochee/verrouillee — 2026-05-05

### Resume
- demande: corriger Bingo mobile organizer, demo et officiel, ou la grille du joueur auto `embed=gm` apparaissait entierement cochee et verrouillee des l'inscription;
- cause identifiee: le front player Bingo pouvait reprendre `bingo_checked` et surtout `bingo_locked` depuis des cles localStorage globales, avant de prouver que l'etat appartenait a la session, au `player_id` canonique et a la grille courants;
- correction: `play-ui.js` scoppé maintenant `bingo_checked` et `bingo_locked` par `game + sessionId + player_id + gridId`, et ne migre l'ancien stockage global que si ce contexte correspond;
- correction addendum: les cles globales `bingo_checked` / `bingo_locked` ne sont plus relues ni reecrites; elles sont supprimees lors des sauvegardes, et `bingo_grid_id` legacy ne sert plus a construire le contexte de cases;
- correction: `grid_hydrate` choisit entre etat local prouve et timestamps DB apres resolution du `gridId`, plus avant;
- correction: `play-ws.js` ne pousse plus un checked-set depuis `localStorage.bingo_checked` global dans `emitGridIfAvailable()`;
- correction addendum: `demo_reset` et `reset_game` purgent maintenant aussi les cles scoppées de la session et l'etat runtime `AppConfig`, sinon le dernier patch pouvait rehydrater une grille demo depuis l'ancien etat local apres reset;
- instrumentation: traces Bus ajoutees pour `grid_hydrate`, `grid_cells_sync`, auth WS Bingo et premier snapshot player Bingo;
- invariant: pas de purge arbitraire d'une grille deja jouee, pas de changement session papier, pas de changement WS Bingo/PHP/DB;
- note regression: les derniers correctifs pre-merge ont probablement expose l'etat stale en rendant l'iframe GM plus deterministe, mais le stockage global etait la cause directe.

### Fichiers modifies
- `games/web/includes/canvas/play/play-ui.js`
- `games/web/includes/canvas/play/play-ws.js`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- journal AI Studio raw consulte avant patch; aucune entree `games` / `bingo.game` recente a recharger hors workspace local;
- docs publiques lues: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`;
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`

### TODO recette navigateur
- Bingo demo mobile: ouvrir `Jouer`, grille non cochee au depart, cocher une case, reload, reprise correcte;
- Bingo officielle mobile: meme scenario avec auto-register GM officiel;
- Bingo demo desktop: preview joueur non entierement cochee;
- Bingo joueur QR reel: pas d'impact;
- reprise apres reload d'un joueur ayant deja coche quelques cases: seules ces cases restent cochees.

## Games: securisation iframe organizer pre-merge — 2026-05-05

### Resume
- demande: traiter avant merge prod les risques `gm-player-ready` trop permissif et double iframe joueur demo/mobile, sans toucher aux regles metier des pseudos auto-GM;
- correction: `canvas_display.js` resout explicitement l'iframe active selon contexte (demo desktop, mobile numerique `Jouer`, papier mobile sans iframe);
- correction: quand une iframe organizer devient active, les autres iframes joueur organizer chargees sont dechargees pour eviter deux connexions WS concurrentes;
- correction: `gm-player-ready` est accepte seulement si l'origine est attendue, si `event.source` correspond a une iframe connue et si le payload matche session + jeu courant;
- invariant Bingo: le payload accepte conserve identite joueur + grille (`gridId` ou `gridNumber`);
- invariant pseudo: pas de reblocage `USERNAME_ALREADY_USED` pour `organizer_auto_player` / `gm_autoreg`.

### Fichiers modifies
- `games/web/includes/canvas/core/canvas_display.js`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/canon/interfaces/canvas-bridge.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- journal AI Studio raw consulte avant patch;
- docs publiques lues: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, `canon/repos/games/README.md`, `canon/repos/games/TASKS.md`, `HANDOFF.md`, `canon/interfaces/canvas-bridge.md`, `CHANGELOG.md`;
- `node --check --input-type=module < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `git -C /home/romain/Cotton/games diff --check main...develop`
- `git -C /home/romain/Cotton/games diff --stat main...develop`
- `git -C /home/romain/Cotton/documentation diff --check`
- `npm run docs:sitemap`

### TODO recette navigateur
- Quiz demo desktop: une seule iframe joueur, un seul joueur demo, score conserve apres reload;
- Quiz demo mobile: toggle `Vue joueur / Vue animateur`, pas de double connexion WS, score conserve;
- Blind Test demo desktop/mobile: meme controle;
- Bingo demo desktop/mobile: une seule grille assignee au joueur demo;
- session officielle mobile: `Jouer / Animer`, auto-register GM, reprise apres reload;
- pseudo GM identique a un joueur reel: pas de blocage, pas de corruption score;
- reload en cours de partie apres changement de score.

## Games: onboarding demo mobile sur l'experience joueur — 2026-05-05

### Resume
- demande: en demo mobile numerique, ouvrir d'abord l'onglet `Vue joueur`, inverser visuellement le toggle en `Vue joueur / Vue animateur`, afficher une mention de profil demo, sans modifier les sessions officielles, le desktop, les joueurs QR, le scoring ni les regles WS;
- correction: `organizer_canvas.php` rend le toggle mobile en ordre `Vue joueur / Vue animateur` uniquement pour les sessions demo, et conserve `Animer / Jouer` pour les sessions officielles;
- correction complementaire: la mention d'attente demo `Lance ta démo...` est sortie du bloc QR, affichee au-dessus du QR et alignee a gauche sur mobile;
- correction: `canvas_display.js` initialise `__mobilePlayerActive` a `true` uniquement au premier passage en session demo mobile numerique, ce qui charge l'iframe GM et declenche l'auto-inscription demo existante;
- respect choix utilisateur: les clics demo mobile sur `Jouer` / `Animer` sont conserves en `sessionStorage` scoppé par jeu + session, afin qu'un simple render ou reload dans le meme onglet ne force pas un retour sur `Jouer`;
- correction UX: la mention hors iframe affiche `Tu joues avec un profil d’Équipe démo.` en Quiz et `Tu joues avec un profil de Joueur démo.` en Blind Test / Bingo;
- invariants: sessions officielles mobiles ouvrent toujours sur `Animer`; desktop inchangé; vrais joueurs QR inchangés; labels et auto-inscription demo iframe conservés.

### Fichiers modifies
- `games/web/organizer_canvas.php`
- `games/web/includes/canvas/core/canvas_display.js`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- journal AI Studio raw consulte avant patch;
- docs publiques lues: `START.md`;
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `git -C /home/romain/Cotton/games diff --check`
- `git -C /home/romain/Cotton/documentation diff --check`
- `npm run docs:sitemap`

### TODO recette navigateur
- Quiz / Blind Test / Bingo demo mobile: premiere ouverture sur `Jouer`, mention demo correcte, auto-inscription demo, bascule `Animer` respectee;
- reload apres bascule `Animer` dans le meme onglet: rester sur `Animer`;
- session officielle mobile: ouverture `Animer`;
- joueur QR reel: aucun changement.

## Games: stabilisation auto-player organizer officiel mobile — 2026-05-05

### Resume
- cause racine identifiee: dans l'iframe `embed=gm`, une identite joueur locale deja presente pour la meme session faisait sortir `autoRegisterGameMasterIfNeeded()` avant inscription; la reprise standard lancait ensuite un probe `players_get`, mais en cas de miss transient elle conservait l'identite sans marquer l'UI comme inscrite, laissant le formulaire manuel visible;
- cause aggravante corrigee: si `canvas_display.js` recalculait une URL iframe differente apres lazy-load, `dataset.src` etait mis a jour mais le `src` deja charge pouvait rester sur l'ancienne URL sans `gm_display_name`;
- correction: chemin de reprise reserve a `embed=gm` qui ouvre directement la vue jeu avec l'identite locale meme-session, republie `player/ready` + `gm-player-ready`, relance le WS via le flux existant, et cache le formulaire;
- correction: sur miss/erreur de probe `players_get` en contexte GM iframe, l'identite locale valide reste active et l'UI reste inscrite au lieu de revenir au register manuel;
- addendum primo-boot: une iframe `embed=gm` sans identite locale est rendue des le HTML initial avec `data-gate-open="0"` et le message `Connexion de ton profil...`, puis `register.js` maintient un etat `GM_AUTOREGISTERING` pendant le probe WS / `player_register`; le formulaire manuel n'est donc plus affiche pendant la premiere auto-inscription;
- addendum logs 14:20: le cas Bingo officiel chargeait bien `/play/bingo/<sid>?embed=gm&gm_display_name=Romain`, puis `player_register` sortait en 500 avant le log metier `bingo_api_player_register][PLAYER_REGISTER_RX`; le blocage venait des gardes serveur `USERNAME_ALREADY_USED` / `USERNAME_REFERENCED`, adaptees aux joueurs QR manuels mais trop strictes pour le joueur auto organizer;
- correction addendum: l'auto-register `embed=gm` envoie maintenant `organizer_auto_player=1` / `gm_autoreg=1`; les handlers Quiz, Blind Test et Bingo bypassent uniquement pour ce flag les gardes d'unicite de nom destinees aux inscriptions manuelles, puis continuent l'upsert habituel par `player_id` canonique;
- correction UX addendum: le bloc `Compte joueur Cotton` n'est plus rendu dans l'iframe `embed=gm`, afin que l'attente interne de preparation du profil ne propose pas de parcours compte joueur;
- correction: l'iframe player recharge son `src` si l'URL effective calculee diverge de l'URL deja chargee;
- invariants: aucun changement pour les vrais joueurs QR, aucun changement scoring, aucun nouveau parcours d'auth, demos conservees (`Équipe démo` Quiz, `Joueur démo` Blind Test/Bingo), fallback officiel `Game Master` conserve.

### Fichiers modifies
- `games/web/includes/canvas/play/register.js`
- `games/web/includes/canvas/core/canvas_display.js`
- `games/web/player_canvas.php`
- `games/web/includes/canvas/php/quiz_adapter_glue.php`
- `games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `games/web/includes/canvas/php/bingo_adapter_glue.php`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- journal AI Studio raw consulte avant patch;
- docs publiques lues: `START.md`;
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `npm run docs:sitemap`

### TODO
- recette navigateur mobile officielle Quiz / Blind Test / Bingo avec storage vide: ouverture directe `Jouer`, auto-inscription, absence de formulaire manuel;
- recette reprise/reload: reload organizer, retour `Jouer`, absence de formulaire manuel;
- recette fallback sans prenom fiable: auto-inscription `Game Master`;
- recette QR joueur reel: formulaire manuel toujours disponible;
- recette demo mobile: labels demo inchanges.

## Games/global: save design organizer merge-safe — 2026-05-05

### Resume
- audit de la chaine organizer -> global branding -> player/remote/iframe demo;
- cause confirmee cote `global`: `app_branding_ajax.php?action=save` remplacait les metadonnees par les seules cles POST et interpretait `logo_mode=original` / `visuel_mode=original` sans media comme reset;
- correction serveur: couleurs, couleurs de texte et police fusionnent avec le branding existant si absentes du POST;
- correction medias: logo/visuel absents sont preserves; suppression volontaire seulement via `logo_clear=1` / `visuel_clear=1`;
- correction live: `branding_save` renvoie le branding effectif, et `session_modals.js` l'utilise pour emettre `update_branding` avec `logo`, `visuel`, `visuelMode`, couleurs et police;
- correction live police: `player_canvas.php` et `remote_canvas.php` utilisent maintenant `--branding-font` pour le `body`; le flux JS live existant peut donc changer la police sans refresh;
- garde-fou compat: si le serveur ne renvoie pas encore le branding effectif, le front reprend les URLs `b.logo` / `b.visuel` deja connues au lieu de vider les medias dans le WS;
- correction titre: `prizes_save` preserve `mainTitle` / `diffusion_message` si la cle est absente.
- cache-bust: `games/web/config.php` passe localement `CANVAS_ASSET_VER` a `v=2026-05-05_19`.

### Fichiers modifies
- `global/web/app/modules/general/branding/app_branding_ajax.php`
- `games/web/includes/canvas/core/session_modals.js`
- `games/web/includes/canvas/php/prizes_glue.php`
- `games/web/player_canvas.php`
- `games/web/remote_canvas.php`
- `games/web/config.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/canon/interfaces/canvas-bridge.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `canon/repos/global/TASKS.md`
- `canon/repos/global/README.md`
- `canon/repos/games/TASKS.md`
- `canon/repos/games/README.md`
- `canon/interfaces/canvas-bridge.md`
- `HANDOFF.md`
- `CHANGELOG.md`

### Verification
- journal AI Studio raw consulte avant patch;
- docs publiques lues: `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`;
- `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_ajax.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/prizes_glue.php`
- `php -l /home/romain/Cotton/games/web/config.php`
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `php -l /home/romain/Cotton/games/web/remote_canvas.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/session_modals.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js`

### TODO
- recette manuelle Quiz et Blind Test minimum: visuel+couleurs custom, modifier uniquement une couleur, verifier organizer/player/remote/iframe demo apres refresh;
- recette media-only: modifier logo/visuel et verifier conservation couleurs/police/titre;
- verifier suppression volontaire logo/visuel via UI.

## Games: nom visible du Game Master officiel mobile — 2026-05-05

### Resume
- en session officielle mobile, l'iframe organizer `Jouer` peut afficher le prénom du contact connecté au lieu de `Game Master`;
- source prioritaire: `$_SESSION['client_contact_prenom']`, déjà alimentée par l'authentification espace client PRO et utilisée sur la home EC (`Bonjour ...`);
- fallback serveur si la session PRO n'est pas disponible côté `games`: `clients_logs.id_client_contact` sur la trace `clients_logs.nom LIKE "%Session #... > ajout%"` écrite par `app_session_ajouter()`, filtrée par `id_client`, puis `client_contact_get_detail()` pour récupérer `prenom`;
- si ce prénom est absent, le fallback reste `Game Master`;
- l'onglet mobile `Jouer` affiche hors iframe une aide discrete `Tu joues avec le profil {displayName}.` en session officielle numerique uniquement;
- les sessions demo conservent les labels existants: `Équipe démo` pour Quiz, `Joueur démo` pour Blind Test / Bingo;
- l'identité technique stable (`player_id`) n'est pas modifiée: seul le `username` visible transmis à `player_register` change quand le prénom est disponible.

### Fichiers modifies
- `games/web/organizer_canvas.php`
- `games/web/includes/canvas/core/canvas_display.js`
- `games/web/includes/canvas/css/canvas_styles.css`
- `games/web/includes/canvas/play/register.js`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `canon/repos/games/TASKS.md`
- `canon/repos/games/README.md`
- `HANDOFF.md`
- `CHANGELOG.md`

### Verification
- journal AI Studio raw consulte avant patch;
- docs publiques lues: `START.md`;
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`

### TODO
- recette mobile officielle Quiz / Blind Test / Bingo avec un compte ayant `client_contact_prenom`;
- verifier le fallback `Game Master` avec une session sans prénom exposé.

## Games: passe UX organizer desktop/mobile — 2026-05-05

### Resume
- la diode du bouton `LANCER LE JEU` pulse pendant `data-prelaunch-status="running"`, puis retrouve la couleur finale verte/orange/rouge du diagnostic;
- les compteurs participants Quiz affichent maintenant `équipe connectée` / `équipes connectées`; Blind Test et Bingo restent en `joueur(s) connecté(s)`;
- la preview joueur demo desktop est posée sur un fond neutre pleine hauteur distinct de la scène organizer, avec une coque téléphone légèrement plus large quand la largeur desktop le permet;
- la coque téléphone n'est plus contrainte par la limite haute du canvas organizer; sa hauteur disponible est bornée en bas par la barre menu;
- en demo desktop avec preview joueur, la footerbar neutralise son `w-100`, reste limitée à la largeur organizer et ne passe plus sous le rail téléphone;
- le texte `Joueur démo / Scanne le QR code...` est retiré de la coque téléphone; un bloc discret est affiché au-dessus avec `Équipe démo` pour Quiz et `Joueur démo` pour Blind Test / Bingo;
- l'iframe joueur demo retire sa teinte embed interne pour revenir au fond `primary-bg` du jeu, et donne plus d'espace aux propositions Quiz / Blind Test et à la grille Bingo.

### Fichiers modifies
- `games/web/includes/canvas/core/canvas_display.js`
- `games/web/includes/canvas/css/canvas_styles.css`
- `games/web/includes/canvas/css/player_styles.css`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `canon/repos/games/TASKS.md`
- `HANDOFF.md`
- `CHANGELOG.md`

### Verification
- journal AI Studio consulte via `https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?...&mode=raw&token=...` avec `curl`;
- point d'entrée docs stable consulte: `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md`;
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`
- `git -C /home/romain/Cotton/games diff --check -- web/includes/canvas/core/canvas_display.js web/includes/canvas/css/canvas_styles.css web/includes/canvas/css/player_styles.css`
- `npm run docs:sitemap`

### TODO
- recette navigateur réelle sur Quiz desktop/mobile demo/officiel, Blind Test desktop demo et Bingo desktop demo;
- vérifier visuellement que l'élargissement progressif de la coque demo ne masque aucun contrôle organizer sur les postes desktop les plus étroits.

## Games: ajustements UX mobile organizer V1 — 2026-05-05

### Resume
- wording de l'aide demo mobile sous QR remplace pour expliciter les deux chemins de test: QR mobile ou demo puis onglet `Jouer`;
- countdown de lancement mobile agrandi en CSS uniquement; addendum: le SVG recoit une boite carree explicite en mobile, avec taille et epaisseurs ajustees pour eviter un rendu trop massif;
- bordures colorees des blocs organizer mobiles reduites a `2px` sur attente / Animer / papier mobile;
- toggle mobile `Animer / Jouer` legerement compacte, avec cible tactile minimale conservee.

### Fichiers modifies
- `games/web/organizer_canvas.php`
- `games/web/includes/canvas/css/canvas_styles.css`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `canon/repos/games/TASKS.md`
- `canon/repos/games/README.md`
- `HANDOFF.md`
- `CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `npm run docs:sitemap`

### TODO
- recette visuelle mobile Quiz / Blind Test / Bingo: attente demo, lancement, Animer numerique, Animer papier, toggle.

## Games: stabilisation V1 mobile organizer — 2026-05-05

### Resume
- correction d'une regression organizer desktop causee par les derniers ajustements mobile `Animer`;
- `canvas_display.js::getPauseRow()` ne prend plus le premier `.pause-row` global, qui pouvait etre la ligne mobile compacte `mobile-session-pause-row`;
- la ligne teleporteable en desktop pointe maintenant vers `#pause-container .pause-row:not(.mobile-session-pause-row)` ou le host desktop de teleport;
- `showAll()` ne retire plus `d-none` des blocs `mobile-session-*` / `#mobile-player-view` quand le layout courant est desktop;
- les selectors de pause inter-series ciblent le bloc status de pause desktop au lieu des premiers tags leaderboard globaux;
- les styles desktop de `.pause-row` sont scopes a `#pause-container` / `#pause-row-running-host` pour ne plus styliser la ligne mobile compacte;
- ajout d'un garde CSS desktop pour masquer explicitement les blocs de session mobile si une classe d'affichage est retiree par le JS.

### Fichiers modifies
- `games/web/includes/canvas/core/canvas_display.js`
- `games/web/includes/canvas/css/canvas_styles.css`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Docs touchees
- `canon/repos/games/TASKS.md`
- `canon/repos/games/README.md`
- `HANDOFF.md`
- `CHANGELOG.md`

### Verification
- `cp /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js /tmp/canvas_display_check.mjs && node --check /tmp/canvas_display_check.mjs`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `node --check /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js` non applicable directement: fichier ESM avec imports aliases hors contexte package, d'ou la copie `.mjs` ci-dessus.

### TODO
- valider visuellement Blind Test / Quiz / Bingo Musical en desktop demo et officiel;
- valider que mobile numerique `Animer` conserve la ligne compacte visuel + QR et que `Jouer` garde son iframe stable.

## Games: vue mobile organizer stable Animer / Jouer — 2026-05-04

### Resume
- V1 exploratoire consolidee: en session numerique mobile, la posture `Animer` est affichee par defaut en `En cours` comme en `Pause`;
- addendum demo: en demo mobile numerique avant lancement, une aide textuelle est affichee sous le compteur joueurs du QR pour inviter a lancer la demo puis passer sur `Jouer`;
- l'auto-register demo conserve le flux `embed=gm` mais harmonise son nom: `Équipe démo` pour Quiz, `Joueur démo` pour Blind Test et Bingo Musical;
- les sessions officielles numeriques gardent `Game Master`;
- aucun CTA d'inscription joueur, `organizer_signup=1`, ecoute `organizer-signup-complete` ou ouverture iframe player pre-lancement n'est ajoute;
- addendum UX lance: pour toutes les sessions mobiles numeriques lancees, demo comme officielles et tous jeux, la posture `Animer` protege mieux les blocs lots/QR de la barre d'actions fixe, et la posture `Jouer` n'affiche plus `VUE JOUEUR` ni cadre externe lourd autour de l'iframe;
- addendum UI Animer: numerique et papier mobiles partagent maintenant un bas de page compact avec visuel + QR, et la vague audio est recentree dans le bloc support mobile;
- addendum auto-register: l'iframe GM mobile demo utilise `gm_demo=1` pour nommer le joueur auto-inscrit comme la demo desktop, et le parent organizer consomme `gm-player-ready` pour afficher immediatement la ligne dans `Suivi des joueurs`;
- addendum reprise: apres reload ou continuation de demo, l'iframe GM reprend d'abord l'identite locale scoppée a la session, puis tente `players_get` si le stockage local manque, avant toute nouvelle inscription;
- addendum reprise demo mobile: la vue organizer `Animer` relit maintenant aussi `players_get` au bootstrap/reprise pour afficher le joueur/score auto-inscrit sans attendre l'ouverture de `Jouer`, et l'iframe republie `gm-player-ready` quand son score change;
- addendum WS reprise demo: Quiz et Blind Test hydratent maintenant `session.players` depuis `players_get` avant le bind `registerPlayer` uniquement pour les demos numeriques deja lancees, afin d'eviter qu'un cache WS vide renvoie `playerScore: 0` au passage sur `Jouer`;
- `#quiz-display` reste le centre de la vue mobile organizer, y compris en pause, au lieu de basculer vers `#pause-container`;
- addendum papier: en session papier mobile, `En cours` et `Pause` conservent la vue `#quiz-display`; le meme `#mobile-session-followup` que la posture numerique `Animer` est reutilise sous le jeu, sans afficher le toggle `Animer / Jouer` ni l'iframe joueur;
- un toggle mobile `Animer / Jouer` remplace les CTA ponctuels;
- les blocs sous `#quiz-display` reprennent le markup/classes de la vue pause mobile: leaderboard, `pause-row`, `lots-container`, QR;
- pendant le jingle d'intro, le toggle et les blocs complements sont masques temporairement pour laisser `#quiz-display` porter l'animation;
- la posture `Jouer` affiche l'iframe Game Master / participant existante sans modifier son fonctionnement;
- aucun changement desktop, avant session, fin de session, papier, URL iframe ou flux WS.

### Correctif livre
- `games/web/organizer_canvas.php`
  - ajoute le toggle mobile `Animer / Jouer` au-dessus de `#quiz-display`;
  - ajoute l'aide demo mobile numerique sous le compteur joueurs du QR en attente;
  - aligne les libelles visibles de la preview desktop demo sur `Équipe démo` en Quiz et `Joueur démo` sinon;
  - retire le tag mobile `VUE JOUEUR` et le cadre externe `container-rounded-colored` du wrapper iframe de la posture `Jouer`;
  - remplace dans `#mobile-session-followup` le QR seul par une ligne visuel de jeu + QR.
  - ajoute sous `#quiz-display` des blocs repris de la vue pause mobile: leaderboard, lots, QR de rejointure;
  - conserve `#player-iframe` comme vue `Jouer`.
- `games/web/includes/canvas/play/register.js`
  - calcule le nom de l'auto-register `embed=gm`: `Game Master` en officiel, `Équipe démo` en demo Quiz, `Joueur démo` en demo Blind Test/Bingo.
  - reconnait `gm_demo=1` pour les demos mobiles et poste `gm-player-ready` au parent avec l'identite complete apres auto-register.
  - reprend l'identite GM locale ou serveur avant auto-register, restaure `player_identity`, passe en stage `play`, et evite les doublons au reload.
  - accepte `Game Master` comme candidat legacy en demo pour recuperer les lignes creees avant correction, tout en restaurant le nom demo attendu.
- `games/web/includes/canvas/core/canvas_display.js`
  - ajoute un etat front local `Animer` / `Jouer` limite a `En cours|Pause` + mobile + numerique;
  - en pause mobile numerique, affiche les sections de jeu (`#quiz-display`, toggle, suivi) plutot que la vue pause separee;
  - en papier mobile, affiche `#quiz-display` et `#mobile-session-followup` en `En cours` comme en `Pause`, sans teleporter la vue pause complete sous le jeu;
  - masque temporairement toggle + suivi pendant `#intro-jingle-timer` / `status.loadingJingle`;
  - rafraichit aussi le compteur joueurs et le mini classement mobile.
  - ajoute `gm_demo=1` aux iframes GM demo, merge `gm-player-ready` dans `GameStore.players` et rerend compteur/listes de suivi.
  - relit `players_get` au bootstrap/reprise et sur transitions clefs pour hydrater le joueur/score auto-inscrit deja existant et restaurer son identite locale.
- `games/web/includes/canvas/play/play-ui.js`
  - republie `gm-player-ready` avec score/rang depuis l'iframe GM quand `answerResult`, `players:update` ou la fin de partie modifient le score player.
- `games/web/includes/canvas/core/score_store.js`
  - conserve le roster local quand `hydratePlayers()` recoit seulement un total sans lignes joueurs.
- `games/web/includes/canvas/core/ws_effects.js`
  - evite de purger les joueurs sur `updatePlayers` / `num_connected_players` avec liste vide et total positif.
- `quiz/web/server/actions/registration.js` et `blindtest/web/server/actions/registration.js`
  - avant le bind player d'une demo numerique deja lancee, relisent `players_get` pour recharger `session.players` si le cache WS n'a pas encore ete hydrate.
- `quiz/web/server/actions/wsHandler.js` et `blindtest/web/server/actions/wsHandler.js`
  - attendent `registerPlayer(...)` pour garantir l'ordre hydrate -> bind.
- `quiz/web/server/restart_serveur.txt` et `blindtest/web/server/restart_serveur.txt`
  - markers WS bumpes.
- `games/web/includes/canvas/core/boot_organizer.js`
  - rend le QR mobile de rejointure avec l'URL joueur existante.
- `games/web/includes/canvas/core/session_modals.js`
  - synchronise les lots du bloc mobile avec le design/session.
- `games/web/includes/canvas/css/canvas_styles.css`
  - styles minimaux du toggle, espacements verticaux de session mobile et masquage de la vue organizer quand `Jouer` ou le jingle mobile est actif.
  - styles de l'aide demo QR limites au mobile numerique, avec masquage du texte demo QR historique sur mobile.
  - renforce la reserve basse de la posture mobile numerique `Animer` uniquement hors papier et allege le wrapper iframe mobile `Jouer`.
  - ajoute le centrage mobile `Animer` de la vague audio et les styles de ligne compacte visuel + QR, applicables aussi au papier mobile.
  - correctif espacement: la marge mobile footerbar n'est plus appliquee a `.en-cours`, pour eviter le vide entre `#quiz-display` et les blocs organizer; elle reste ciblee sur les vues qui doivent proteger leur bas de page.
  - correctif papier mobile: le bloc lots du follow-up reste compact (`height:auto`, contenu en haut, lignes rapprochees du titre) et la marge basse reste sur le conteneur mobile commun.
- `games/web/config.php`
  - bump local `CANVAS_ASSET_VER`.

### Addendum espacement iframe — 2026-05-04
- la vue `Animer` s'appuie sur le `padding-bottom` de `#mobile-session-followup` pour proteger le dernier bloc de la footerbar, sans pousser `#quiz-display`;
- la vue `Jouer` recoit un `padding-bottom` mobile dedie sur `#mobile-player-view`;
- `#player-iframe` a maintenant une hauteur minimale mobile responsive et redemande le resize `gm-iframe-size-request` quand l'utilisateur bascule vers `Jouer`, en reutilisant le protocole iframe existant;
- addendum correctif: les marges entre toggle, `#quiz-display` et blocs organizer ont ete legerement reouvertes pour eviter que les tags absolus remontent visuellement dans le bloc precedent;
- le titre du bloc joueurs mobile reutilise le tag existant et devient dynamique: `Suivi des joueurs` en `En cours`, `Pause` en `Pause`;
- la mesure de hauteur `embed=gm` cote player ne prend plus le `clientHeight` viewport comme plancher, afin d'eviter une iframe artificiellement trop haute quand le contenu reel est plus court.
- addendum Quiz: dans la posture mobile `Animer`, `body.mobile-session-organizer-active[data-game="quiz"]` masque seulement l'overlay `#quiz-leaderboard-overlay` (`Point scores !`) afin d'eviter le doublon avec le bloc joueurs sous `#quiz-display`; `Jouer`, desktop, Blind Test et Bingo restent inchanges.
- addendum Quiz question: la branche mobile numerique de `core/player/strategies/quiz.js::tweakLayoutForQuestion()` ne masque plus `#quiz-question` en posture mobile `Animer`. La detection ne depend plus seulement de `body.mobile-session-organizer-active`; elle relit aussi `status.gameStatus`, l'existence du toggle et l'etat masque de `#mobile-player-view`, pour couvrir les rendus support qui passent avant la pose de classe body.
- addendum papier mobile: `canvas_display.js::setPhase()` ajoute un contexte `isPaperMobileSession`; en `En cours` et `Pause`, il affiche les sections de jeu et laisse `#mobile-session-followup` porter le suivi joueurs/etat, les lots et le QR. Le toggle/iframe restent masques par `paper-mode`, et `canvas_styles.css` met la reserve basse sur ce conteneur commun pour que le QR puisse scroller au-dessus de la footerbar.

### Vigilance produit
- la vue organizer mobile affiche le support courant, la question/etat courant, les compteurs, le classement et les lots;
- les options de reponse quiz restent masquees sur mobile via le responsive existant;
- la question/support courant restent visibles cote organizer: si l'organisateur joue depuis le meme telephone, il doit revenir a `Jouer` pour eviter de consulter la posture organizer;
- le bloc `PAUSE` n'est pas repris tel quel dans la vue mobile session: seul le rendu est conserve, avec le libelle neutre `Suivi des joueurs`;
- non corrige en V1 sans validation produit.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/config.php`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/ws_effects.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/score_store.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/session_modals.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --check /home/romain/Cotton/quiz/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/quiz/web/server/actions/wsHandler.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/wsHandler.js`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js /tmp/canvas_display_check.mjs && node --check /tmp/canvas_display_check.mjs`
- `git diff --check`

## Games: iframe GM mobile preservee en demo — 2026-05-04

### Resume
- correction d'un effet de bord des demos: l'iframe Game Master mobile recevait `demo_player=1` quand `configurePlayerIframe()` configurait toutes les iframes;
- ce parametre ajoutait la classe `demo-player-embed` dans le player et contraignait la hauteur du GM mobile;
- l'URL est maintenant construite par iframe: `#demo-player-iframe` conserve `demo_player=1`, `#player-iframe` mobile reste en `embed=gm` classique.

### Correctif livre
- `games/web/includes/canvas/core/canvas_display.js`
  - scope de `demo_player=1` limite a l'iframe desktop demo.
- `games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Verification
- `php -l /home/romain/Cotton/games/web/config.php`
- `git diff --check`

## Games: wording Vue joueur demo desktop — 2026-05-04

### Resume
- le tag haut de coque `Joueur démo` est remplace par un wording explicite:
  - `Vue joueur démo`
  - `Testez aussi sur votre mobile avec le QR code.`
- changement limite aux sessions demo desktop qui affichent la preview iframe.

### Correctif livre
- `games/web/organizer_canvas.php`
  - remplacement du markup du tag haut de coque.
- `games/web/includes/canvas/css/canvas_styles.css`
  - style compact titre/sous-titre.
- `games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/config.php`

## Games + WS: Joueur demo compte dans le quota demo — 2026-05-04

### Resume
- nouvelle regle produit: en session demo, `Joueur démo` compte dans `maxPlayers`;
- avec une demo a 2 joueurs max, le joueur automatique laisse 1 place mobile QR;
- la regle est alignee sur Quiz, Blind Test et Bingo.

### Correctif livre
- `quiz/web/server/actions/registration.js` et `blindtest/web/server/actions/registration.js`
  - `countQuotaPlayers(...)` compte tous les joueurs;
  - le blocage session pleine s'applique aussi aux participants demo.
- `quiz/web/server/actions/connection.js` et `blindtest/web/server/actions/connection.js`
  - le retour sous limite est recalcule sur tous les joueurs.
- `bingo.game/ws/lib/lib.js`
  - `PlayerConnectionsTracker` compte de nouveau tous les players dans `playlistCounts`, y compris `demoParticipant`.
- markers WS bumpes:
  - `quiz/web/server/restart_serveur.txt`
  - `blindtest/web/server/restart_serveur.txt`
  - `bingo.game/version.txt`

### Documentation
- `CHANGELOG.md`
- `canon/repos/games/README.md`
- `canon/repos/games/TASKS.md`
- `canon/repos/quiz/README.md`
- `canon/repos/quiz/TASKS.md`
- `canon/repos/blindtest/README.md`
- `canon/repos/blindtest/TASKS.md`
- `canon/repos/bingo.game/README.md`
- `canon/repos/bingo.game/TASKS.md`
- `canon/interfaces/actions.md`
- `canon/interfaces/canvas-bridge.md`
- `HANDOFF.md`

### Verification
- `node --check /home/romain/Cotton/quiz/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/quiz/web/server/actions/connection.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/registration.js`
- `node --check /home/romain/Cotton/blindtest/web/server/actions/connection.js`
- `node --check /home/romain/Cotton/bingo.game/ws/lib/lib.js`
- `node --check /home/romain/Cotton/bingo.game/ws/bingo_server.js`

## Games + WS Bingo: demo desktop avec Joueur demo hors quota — 2026-05-04

### Resume
- les demos desktop Bingo Musical affichent maintenant la `Vue joueur` integree comme Quiz/Blind Test;
- l'iframe reuse le player Bingo existant en `embed=gm&demo_player=1`, auto-inscrit `Joueur démo`, appelle `grid_assign` et s'authentifie au WS avec une vraie grille;
- `demoParticipant:true` est propage sur l'auth Bingo et le WS l'exclut du compteur de capacite, tout en conservant le joueur dans les connexions/snapshots.

### Correctif livre
- `games/web/organizer_canvas.php`
  - inclut `bingo` dans la condition du panneau desktop `Vue joueur`.
- `games/web/includes/canvas/play/play-ws.js`
  - ajoute `demoParticipant:true` sur `auth_player` Bingo seulement pour `embed=gm&demo_player=1`.
- `games/web/config.php`
  - bump `CANVAS_ASSET_VER`.
- `bingo.game/ws/bingo_server.js`
  - lit le flag `demoParticipant` sur `auth_player` et le logge.
- `bingo.game/ws/lib/lib.js`
  - garde le joueur demo dans `connections` mais ne l'ajoute pas a `playlistCounts`.
- `bingo.game/version.txt`
  - bump marker restart.

### Documentation
- `CHANGELOG.md`
- `canon/repos/games/README.md`
- `canon/repos/games/TASKS.md`
- `canon/repos/bingo.game/README.md`
- `canon/repos/bingo.game/TASKS.md`
- `canon/interfaces/actions.md`
- `canon/interfaces/canvas-bridge.md`
- `HANDOFF.md`

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/config.php`
- `node --check /home/romain/Cotton/bingo.game/ws/lib/lib.js`
- `node --check /home/romain/Cotton/bingo.game/ws/bingo_server.js`

### Limites
- pas de smoke navigateur/DB execute depuis ce workspace; validation integree attendue sur une session demo Bingo reelle pour confirmer affichage iframe, attribution de grille et QR joueur mobile simultane.

## Games + WS: demo desktop avec Joueur demo hors quota — 2026-04-30

### Resume
- les demos desktop Quiz et Blind Test affichent maintenant une `Vue joueur` integree;
- l'iframe utilise le flux player existant en mode `embed=gm&demo_player=1` et inscrit automatiquement `Joueur démo`;
- le WS Quiz/Blind Test marque ce participant `demoParticipant` et l'exclut du calcul de capacite, pour laisser les vraies places QR disponibles.
- addendum: l'iframe demo desktop est maintenant configuree apres attache UI organizer et chargee immediatement; auparavant elle restait `about:blank` tant que la partie n'etait pas demarree, et le premier essai `session/init` partait avant l'enregistrement du listener UI. Le chemin iframe mobile historique reste configure au demarrage du jeu.
- addendum UX: la `Vue joueur` desktop est affichee dans une coque telephone centree dans la hauteur utile; seul le player `embed=gm&demo_player=1` recoit la classe `demo-player-embed` et les styles compacts, afin de ne pas modifier l'iframe Game Master mobile. Le bloc explicatif parent est masque pour maximiser la hauteur utile, le fond utilise une teinte derivee de la couleur client, le contenu player scrolle dans l'iframe, la footerbar score/classement reste visible, les elements cliquables ont des interactions souris desktop, et le box model du contenu embarque est borne pour eviter le rognage lateral.
- addendum layout organizer: quand la preview desktop est visible, un `ResizeObserver` mesure le cockpit organizer reel (`.main-section .responsive-center`) et expose `--organizer-viewport-width` / `--organizer-qr-max-size`; le QR principal est ainsi plafonne selon la largeur utile hors panneau `Vue joueur`. La meme mesure cale aussi `--demo-player-scene-top` / `--demo-player-scene-height` sur l'union du header organizer et de la scene organizer visible (`waiting`, `en cours`, `pause`) pour eviter une safe area verticale propre a la preview.

### Correctif livre
- `games/web/organizer_canvas.php`
  - ajout du panneau desktop `Vue joueur` pour les demos Quiz/Blind Test;
  - wording QR ajoute: `Scannez le QR code pour tester aussi depuis votre téléphone.`
- `games/web/includes/canvas/play/register.js`
  - le mode iframe demo utilise `Joueur démo` au lieu de `Game Master`;
  - l'auto-register demo ne bloque pas sur une session deja full cote probe.
- `games/web/includes/canvas/play/play-ws.js`
  - ajoute `demoParticipant:true` au `registerPlayer` WS du player demo.
- `games/web/includes/canvas/core/canvas_display.js`
  - configure toutes les iframes player marquees `data-player-iframe`;
  - ajoute `demo_player=1` a l'URL iframe des sessions demo.
  - configure uniquement `#demo-player-iframe` des `session/init` et force son chargement; l'iframe mobile conserve son declenchement existant au `game/started`.
  - mesure aussi la scene organizer visible et expose `--demo-player-scene-top` / `--demo-player-scene-height` pour aligner verticalement la preview.
- `games/web/includes/canvas/core/boot_organizer.js`
  - appelle explicitement la configuration de l'iframe demo apres `attachOrganizerUI()` pour eviter la course d'initialisation;
  - initialise aussi les metriques de cockpit organizer pour les demos desktop.
- `games/web/includes/canvas/play/play-ui.js` + `games/web/includes/canvas/css/player_styles.css`
  - ajoutent le mode compact `demo-player-embed` uniquement pour la preview desktop `demo_player=1`;
  - gardent la footerbar player visible, rendent le contenu au-dessus scrollable et ajoutent cursor/hover sur les elements cliquables.
- `games/web/includes/canvas/css/canvas_styles.css`
  - affiche la preview dans une coque telephone, masque le bloc explicatif parent, garde un viewport iframe fixe et neutralise la bordure native iframe.
  - plafonne le QR principal avec `--organizer-qr-max-size` quand le layout demo player est actif.
  - positionne le panneau `Vue joueur` sur la bande verticale mesuree de la scene organizer, sans reserver de safe area au-dessus de la footerbar.
- `games/web/config.php`
  - bump `CANVAS_ASSET_VER`.
- `quiz/web/server/actions/registration.js` + `blindtest/web/server/actions/registration.js`
  - excluent les joueurs `isDemoParticipant` du quota `maxPlayers` et de `checkSessionStatus`;
  - conservent le joueur dans `session.players` pour l'affichage organizer, score et classement.
- `quiz/web/server/actions/connection.js` + `blindtest/web/server/actions/connection.js`
  - recalculent le retour sous limite hors participants demo.
- markers WS bumpes: `quiz/web/server/restart_serveur.txt`, `blindtest/web/server/restart_serveur.txt`.

### Limites
- Bingo Musical n'est pas inclus dans cette V1: son inscription player est liee a l'attribution de grille, donc un scope dedie est preferable.
- Le participant demo est cree dans les tables player des sessions demo, comme le flux existant; les aggregats business excluent deja les sessions demo.

### Verification
- `node --check` sur les handlers WS Quiz/Blind Test modifies.
- `node --input-type=module --check` sur les modules front ESM modifies.
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`.
- `php -l /home/romain/Cotton/games/web/config.php`.

### Documentation
- `CHANGELOG.md`
- `canon/repos/games/README.md`
- `canon/repos/games/TASKS.md`
- `canon/repos/quiz/README.md`
- `canon/repos/quiz/TASKS.md`
- `canon/repos/blindtest/README.md`
- `canon/repos/blindtest/TASKS.md`
- `HANDOFF.md`

## Games: prelaunch reseau mobile sans faux orange navigateur — 2026-04-30

### Resume
- le message orange `La connexion de cet appareil semble lente ou instable.` etait declenche par `network_profile WARN`;
- ce `WARN` venait des seuls signaux `navigator.connection` via `isSlowNetworkConnection(...)`;
- `network_profile` est maintenant vert tant que `navigator.onLine !== false`; ses donnees restent un profil indicatif, et l'orange vient des checks applicatifs reels.

### Correctif livre
- `games/web/includes/canvas/core/prelaunch_check.js`
  - suppression du passage `STATUS.WARN` dans `checkNetworkProfile()` pour `effectiveType`, `downlink`, `rtt` ou `saveData`;
  - conservation du rouge `network_offline` sur `navigator.onLine === false`;
  - detail utilisateur reformule en profil reseau indicatif, avec decision de stabilite portee par les tests reels.
- `games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- prelaunch reseau conserve;
- pas de critere bloquant ou orange base uniquement sur cellulaire/inconnu/profil navigateur prudent;
- `bridge`, `network_probe`, WS et offline conservent les decisions applicatives existantes;
- scan supports multimedia non reintegre cote organizer.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `php -l /home/romain/Cotton/games/web/config.php`
- `git -C /home/romain/Cotton/games diff --check`

### Documentation
- `CHANGELOG.md`
- `canon/repos/games/README.md`
- `canon/repos/games/TASKS.md`
- `HANDOFF.md`

## Games: prelaunch reseau mobile non bloquant — 2026-04-30

### Resume
- le diagnostic prelaunch ne considere plus une connexion cellulaire, l'absence de Wi-Fi ou un `downlink` navigateur nul comme une absence d'Internet;
- le type de transport remonte par `navigator.connection.type` est conserve comme contexte d'affichage;
- le rouge reste reserve a `navigator.onLine === false` et aux checks applicatifs bloquants deja presents (bridge/WS/endpoints).

### Correctif livre
- `games/web/includes/canvas/core/network_profile.js`
  - ajout de `type` dans le snapshot et dans `formatNetworkProfile(...)`;
  - `isOfflineNetworkConnection(...)` ne renvoie plus `true` sur `downlink <= 0`;
  - l'API `navigator.connection` reste optionnelle.
- `games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- prelaunch reseau conserve;
- pas de scan supports multimedia cote organizer;
- Wi-Fi existant inchange;
- connexions mobiles/inconnues non bloquantes si les checks applicatifs passent;
- offline navigateur et echecs bridge/WS restent bloquants.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/network_profile.js`
- `php -l /home/romain/Cotton/games/web/config.php`
- `git -C /home/romain/Cotton/games diff --check`

### Documentation
- `CHANGELOG.md`
- `canon/repos/games/README.md`
- `canon/repos/games/TASKS.md`
- `HANDOFF.md`

## Games: prelaunch organizer vert leger, orange/rouge explicites — 2026-04-30

### Resume
- le prelaunch organizer reste lance automatiquement au chargement;
- la modale prelaunch ne s'ouvre plus automatiquement en vert, mais s'ouvre automatiquement en orange/rouge pour les demos comme pour les sessions officielles;
- les garde-fous au clic `Lancer` restent actifs: rouge bloque et ouvre le diagnostic, orange reste non bloquant, vert reste leger;
- la confirmation officielle remplace `Annuler` par une croix, garde un lien discret `Diagnostic réseau et son` sous le CTA principal en vert et propose un CTA secondaire `Voir le diagnostic` en orange.

### Correctif livre
- `games/web/includes/canvas/core/prelaunch_check.js`
  - titre/sous-titre de modale remplaces par `Diagnostic avant lancement` et `Vérification de cet appareil, de la connexion et du son.`;
  - `showPrelaunchModal()` est declenche par l'auto-precheck uniquement quand le resultat final est `warning` ou `fail`;
  - le garde remote/modal-dismissed ne s'applique plus aux etats finaux vert/orange.
  - les bandeaux prelaunch auto orange/rouge sont fermes tant que la session est encore `En attente`; l'information passe par la pastille et le clic `Lancer`.
- `games/web/includes/canvas/core/boot_organizer.js`
  - confirmation officielle reordonnee: avertissement metier, puis lien discret en vert ou note orange;
  - wording officiel vert: `Diagnostic réseau et son`, place dans le footer SweetAlert sous le CTA principal;
  - wording officiel orange: `Point à vérifier avant ta session`, avec CTA secondaire `Voir le diagnostic`;
  - demo verte: lancement direct, sans confirmation ni proposition de test son;
  - demo orange: confirmation legere avec croix, `Lancer la démo` et `Voir le diagnostic`;
  - rouge conserve le blocage avant confirmation officielle/demo: clic `Lancer` -> modale diagnostic, pas de lancement.
- `games/web/includes/canvas/css/canvas_styles.css`
  - lien officiel vert rendu discret;
  - CTA secondaire orange rendu outline vigilance.
  - titre des confirmations de lancement protege du chevauchement avec la croix de fermeture.
- `games/web/includes/canvas/core/boot_organizer.js`
  - icone SweetAlert `question` restauree sur la confirmation officielle de lancement, comme en prod.
- `games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- prelaunch automatique, seuils et statut de bouton conserves;
- rouge toujours bloquant au clic `Lancer`;
- orange toujours non bloquant;
- modale prelaunch existante et coupure du jingle a la fermeture inchangees;
- scan supports multimedia non reintegre;
- pas de confirmation demo en vert.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `php -l /home/romain/Cotton/games/web/config.php`
- `git -C /home/romain/Cotton/games diff --check`

### Documentation
- `CHANGELOG.md`
- `canon/repos/games/README.md`
- `canon/repos/games/TASKS.md`
- `HANDOFF.md`

## Games: sessions demo prelaunch allegees — 2026-04-30

### Resume
- les demos organizer conservent le prelaunch automatique en arriere-plan;
- la modale prelaunch ne s'ouvre plus automatiquement au chargement des demos vertes;
- le clic `Lancer` porte maintenant le parcours demo: rouge bloque et ouvre le diagnostic, orange confirme avec acces diagnostic, vert lance directement la demo.

### Correctif livre
- `games/web/includes/canvas/core/prelaunch_check.js`
  - detection demo partagee `AppConfig` / `ServerSessionMeta` / `ClientSessionMeta`;
  - auto-check conserve, auto-ouverture de modale supprimee uniquement pour les demos;
  - garde remote/modal-dismissed levee pour demo verte/orange, conservee pour rouge/running/untested.
- `games/web/includes/canvas/core/boot_organizer.js`
  - confirmation demo dediee en orange avec les CTA `Lancer la démo` et `Voir le diagnostic`;
  - les CTA secondaires ouvrent la modale prelaunch existante, donc le controle jingle conserve sa coupure automatique a la fermeture.
  - si le prelaunch est vert, la demo se lance sans confirmation supplementaire.
- `games/web/includes/canvas/core/canvas_display.js`
  - `ClientSessionMeta.isDemo` participe a la detection du prelaunch requis.
- `games/web/includes/canvas/css/canvas_styles.css`
  - style compact de la confirmation demo;
  - les CTA secondaires demo utilisent un outline vert/orange selon le statut prelaunch, sans rouge hors erreur bloquante.
- `games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- seuils prelaunch inchanges;
- scan supports multimedia non reintegre cote organizer;
- bouton `Lancer` non desactive en rouge;
- aucune proposition de test son en demo verte.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js`
- `php -l /home/romain/Cotton/games/web/config.php`

### Documentation
- `CHANGELOG.md`
- `canon/repos/games/README.md`
- `canon/repos/games/TASKS.md`
- `HANDOFF.md`

## PRO/global: Quiz V1 agenda launcher et statut simplifie — 2026-04-29

### Resume
- restauration du CTA `Ouvrir le jeu` des cartes agenda pour les sessions `Cotton Quiz V1`;
- simplification du statut legacy V1: plus d'etat `running` simule depuis la date;
- les V1 restent en attente tant qu'elles ne sont pas archivees par date, puis terminees.

### Correctif livre
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - ajout d'une branche explicite `id_type_produit=1` vers `/extranet/start/game/play/{id_securite_session}`;
  - le parcours classique PRO conserve ensuite le launcher historique `quiz.game` / `quiz.display`.
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `app_session_edit_state_get(...)` traite `Cotton Quiz V1` comme `pending` avant archive par date et `terminated` apres;
  - aucun etat `running` n'est fabrique pour cette version legacy.

### Invariants
- aucun changement sur les produits runtime modernes `3/4/5/6`;
- aucun changement dans `games/master`;
- le garde-fou de lancement commercial reste applique.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `git -C /home/romain/Cotton/pro diff --check`
- `git -C /home/romain/Cotton/global diff --check`
- `npm run docs:sitemap`

### Documentation
- `CHANGELOG.md`
- `canon/repos/pro/README.md`
- `canon/repos/pro/TASKS.md`
- `canon/repos/global/README.md`
- `canon/repos/global/TASKS.md`
- `HANDOFF.md`

## PRO: micro-feedback labels stockes sans emoji — 2026-04-29

### Resume
- normalisation serveur des `rating_label` micro-feedback avant insertion;
- les emojis peuvent rester dans les CTA UI, mais ne sont plus stockes en base;
- les `rating_value` restent inchanges et continuent de distinguer `neutral` / `no`.

### Correctif livre
- `pro/web/ec/modules/general/feedback/ec_feedback_submit_ajax.php`
  - mapping canonique: `yes` -> `Oui`, `neutral` -> `Moyen`, `no` -> `Non`, `great` -> `Oui, très bien`, `improve` -> `Pas totalement`, `ignored` -> `Fermé`;
  - le `rating_label` poste par l'UI est ignore au profit du mapping serveur.

### Invariants
- UI inchangee;
- SQL inchange;
- logique metier inchangee;
- `rating_value` inchanges: `yes`, `neutral`, `no`, `great`, `improve`, `ignored`.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/general/feedback/ec_feedback_submit_ajax.php`
- `git -C /home/romain/Cotton/pro diff --check`

## PRO: micro-feedback durcissement serveur avant prod — 2026-04-29

### Resume
- durcissement serveur de l'endpoint micro-feedback PRO, sans changement UI, wording, contexte, surface ni SQL;
- verrouillage strict des couples `context_key` / `display_surface` acceptes;
- validation des `rating_value` autorisees par contexte;
- assainissement serveur des commentaires/tags selon la reponse;
- exclusion des sessions demo ajoutee cote endpoint pour le feedback apres programmation;
- anti-doublon relu juste avant insertion.

### Correctif livre
- `pro/web/ec/modules/general/feedback/ec_feedback_submit_ajax.php`
  - couples autorises: `session_programmed_summary` + `session_summary`, `session_finished_experience` + `pro_home`, `session_finished_experience` + `pro_session_detail`;
  - valeurs autorisees programmation: `yes`, `neutral`, `no`, `ignored`;
  - valeurs autorisees post-session: `great`, `improve`, `ignored`;
  - commentaires/tags supprimes cote serveur pour `yes`, `great` et `ignored`;
  - tags conserves uniquement pour `improve`;
  - les sessions demo sont refusees aussi pour `session_programmed_summary`.
- `pro/web/ec/modules/general/feedback/ec_feedback_lib.php`
  - controle anti-doublon final dans `ec_feedback_event_insert(...)` juste avant l'`INSERT`.

### Invariants
- UI inchangee;
- SQL inchange;
- aucune nouvelle table;
- aucun feedback cote `games`;
- context keys et surfaces inchanges;
- la table `user_feedback_events` reste a importer avant prod via `pro/sql/user_feedback_events_phpmyadmin.sql`.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/general/feedback/ec_feedback_submit_ajax.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/general/feedback/ec_feedback_lib.php`
- `git -C /home/romain/Cotton/pro diff --check`
- `npm run docs:sitemap`

### Documentation
- `CHANGELOG.md`
- `canon/repos/pro/README.md`
- `canon/repos/pro/TASKS.md`
- `HANDOFF.md`

## Games: prelaunch organizer plus friendly — 2026-04-29

### Resume
- correctif de priorite au lancement: une session future non ouverte affiche de nouveau l'alerte de session non ouverte au lieu de la modale prelaunch;
- passe visuelle/UX de la modale prelaunch organizer `games`;
- rendu plus proche d'une checklist de preparation: fond chaud, cartes moins diagnostic, icones de domaine, badges compacts et couleurs de statut adoucies;
- micro-passe de coherence: badges verts corriges, titres/sous-titres de panneaux simplifies, messages internes sans repetition de statut, bandeaux internes alleges, actions recommandees alignees a gauche;
- wording du header et des CTA de relance clarifie, sans jargon technique ajoute.

### Correctif livre
- `games/web/includes/canvas/core/boot_organizer.js`
  - le blocage prelaunch au clic `Lancer` est maintenant borne aux sessions `En attente` ouvertes ou demo;
  - les sessions futures non ouvertes passent vers `gateStartWithSessionMeta()`, qui conserve l'alerte existante de session non ouverte.
- `games/web/includes/canvas/core/prelaunch_check.js`
  - header `On verifie que tout est pret`;
  - sous-texte recentre sur appareil, connexion et son;
  - panneaux renommes `Session et connexion` / `Son et medias`, sans sous-titre de panneau;
  - messages internes simplifies: `La session est prete.`, `Le jingle a bien demarre sur cet appareil.`, et messages utiles directs pour les etats orange/rouge/non verifies;
  - libelles de statut visibles `Verifie`, `A surveiller`, `Action necessaire`;
  - correction du cas `ready`: le badge header vert n'affiche plus `A surveiller`;
  - CTA de relance explicites `Relancer le test`.
- `games/web/includes/canvas/css/canvas_styles.css`
  - modal plus chaleureuse, cartes checklist, badges status harmonises, bandeaux de resultat moins lourds;
  - fond des icones de domaine aligne sur le niveau courant vert/orange/rouge;
  - bandeau de statut interne plus leger pour reduire l'effet bloc imbrique;
  - actions recommandees alignees a gauche avec indentation moderee;
  - relance visuellement moins prioritaire quand le panneau est vert;
  - responsive mobile masque le sous-titre global et garde action + badge sous le titre du panneau.
- `games/web/config.php`
  - bump `CANVAS_ASSET_VER`.

### Invariants
- logique metier prelaunch inchangee;
- pas de changement SQL;
- pas de changement endpoint;
- pas de modification WebSocket;
- seuils reseau inchanges;
- scan supports multimedia non reintegre cote organizer;
- comportement rouge/orange/vert inchange;
- sessions ouvertes/demo: prelaunch rouge/running/untested garde la priorite;
- sessions futures non ouvertes: alerte session non ouverte prioritaire;
- fermeture de modale coupe toujours le jingle via le chemin existant `stopSoundControl('modal_closed')`.

### Verification
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js`
- `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
- `php -l /home/romain/Cotton/games/web/config.php`
- `git -C /home/romain/Cotton/games diff --check`

### Documentation
- `CHANGELOG.md`
- `canon/repos/games/README.md`
- `canon/repos/games/TASKS.md`
- `HANDOFF.md`

## PRO: micro-feedback compact harmonise — 2026-04-29

### Resume
- harmonisation UI des blocs micro-feedback PRO existants, sans nouvelle surface ni changement de logique metier;
- bloc initial plus compact avec icone en pastille, fond doux, fermeture discrete et remerciement inline;
- renforcement de la visibilite de l'icone via une pastille violet plein et une icone blanche legerement agrandie, sans augmenter le padding vertical;
- ajout d'emojis legers dans les CTA de reponse pour rendre le feedback plus visuel;
- home PRO et fiche detail post-session partagent maintenant les memes boutons et la meme logique d'expansion;
- tags post-session affiches en chips compactes au lieu de checkboxes visibles.

### Correctif livre
- `pro/web/ec/modules/general/feedback/ec_feedback_lib.php`
  - styles compacts du composant commun;
  - icone inline type message + coeur en pastille violette contrastee;
  - tags rendus comme chips tout en conservant les inputs collectes par le JS existant;
  - champ commentaire et bouton `Envoyer` rapproches en desktop;
  - remerciement par defaut: `Merci, ton retour est bien pris en compte 🙂`.
- `pro/web/ec/modules/communication/home/ec_home_index.php`
  - retrait du sous-texte par defaut pour reduire la hauteur;
  - remerciement harmonise.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - wording aligne avec la home: `Cette animation s'est-elle bien passée ?`;
  - boutons `Oui, très bien` / `Pas totalement`;
  - memes tags post-session que la home.
- `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume.php`
  - remerciement harmonise apres feedback de programmation.
- `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php`
  - remerciement harmonise apres feedback de programmation rapide.

### Invariants
- SQL inchange;
- context keys inchanges: `session_programmed_summary`, `session_finished_experience`;
- surfaces inchanges: `session_summary`, `pro_home`, `pro_session_detail`;
- exclusion des sessions demo inchangee;
- anti-doublon / feedback ferme / feedback deja donne inchanges;
- aucun feedback cote `games`, aucun email.
- valeurs feedback programmation conservees distinctes: `yes`/`Oui`, `neutral`/`Moyen`, `no`/`Non`.
- apres normalisation serveur, les valeurs techniques restent distinctes: `yes`, `neutral`, `no`; les labels stockes sont `Oui`, `Moyen`, `Non`.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/general/feedback/ec_feedback_lib.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_4_resume.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php`
- `git -C /home/romain/Cotton/pro diff --check`
- requete SQL demandee tentee en local sur `prod_cotton_global_0` puis `dev_cotton_global_0`: acces refuse pour les deux utilisateurs applicatifs locaux.

### Documentation
- `CHANGELOG.md`
- `canon/repos/pro/TASKS.md`
- `HANDOFF.md`

## PRO: micro-feedback utilisateur V1 — 2026-04-28

### Resume
- ajout d'un micro-feedback apres programmation sur l'ecran resume standard et le resume rapide multi-sessions;
- ajustement UI: les resumes de programmation affichent le bloc au-dessus des cartes et en version compacte sur une ligne desktop;
- ajout d'un cooldown client de 30 jours pour ne pas reproposer le feedback de programmation apres reponse ou fermeture;
- ajout d'un micro-feedback post-session sur home PRO pour une session reelle terminee recemment;
- ajustement home: si la derniere session terminee recente a deja un retour ou une fermeture, le bloc n'est plus remplace par une session plus ancienne;
- ajout du meme feedback post-session sur la fiche detail terminee, seulement si non donne/non ignore;
- commentaires demandes uniquement pour les retours moyens/negatifs;
- aucune surface ajoutee cote `games`.

### Correctif livre
- `pro/web/ec/modules/general/feedback/ec_feedback_lib.php`
  - helper generique de rendu, enregistrement, detection deja donne/ignore et session recente eligible;
  - rendu JS/CSS non bloquant via AJAX.
  - variante compacte en ligne pour les resumes de programmation;
  - selection home limitee a la derniere session terminee recente.
  - helper de cooldown client par contexte.
- `pro/web/ec/modules/general/feedback/ec_feedback_submit_ajax.php`
  - endpoint `ec_ajax.php?t=general&m=feedback&p=submit`;
  - garde compte courant, session rattachee au client, exclusion demos et anti-doublon.
- `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume.php`
  - feedback `session_programmed_summary` sur resume, hors demo.
- `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php`
  - feedback `session_programmed_summary` sur le resume de programmation rapide multi-sessions;
  - un seul bloc est affiche pour le lot, rattache au premier `id_session` cree afin de garder l'anti-doublon scoped session.
- `pro/web/ec/modules/communication/home/ec_home_index.php`
  - feedback prioritaire `session_finished_experience` sur home PRO;
  - reutilise les helpers historiques de sessions archivees utiles, donc sessions non demo / terminees / exploitables.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - feedback secondaire sur fiche detail terminee, hors demo et hors feedback deja donne/ignore.
- `pro/sql/user_feedback_events_phpmyadmin.sql`
  - creation idempotente de la table generique `user_feedback_events`.
- `pro/.gitignore`
  - exception explicite pour versionner ce script SQL phpMyAdmin malgre l'exclusion globale des dumps SQL.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/general/feedback/ec_feedback_lib.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/general/feedback/ec_feedback_submit_ajax.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_4_resume.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php`
- `git -C /home/romain/Cotton/pro diff --check`

### Documentation
- `CHANGELOG.md`
- `canon/repos/pro/README.md`
- `canon/repos/pro/TASKS.md`
- `HANDOFF.md`

## PRO: verification des supports depuis la fiche session — 2026-04-28

### Resume
- ajout d'une verification des supports dans la section `Tester` de la fiche detail session PRO non archivee/non verrouillee;
- le resultat reste non bloquant et centre utilisateur: `Aucun probleme detecte...`, `x morceaux douteux`, `x supports douteux`;
- les badges sont poses au niveau playlist pour Blind Test/Bingo et au niveau serie pour Quiz;
- les lots temporaires Quiz renvoient aussi le contexte question dans la reponse JSON.

### Correctif livre
- `pro/web/ec/modules/jeux/controle_liens/ec_controle_liens_lib.php`
  - collecte les supports reels de la session;
  - matche d'abord les diagnostics existants de `content_links_check_results` par URL ou `videoId`;
  - ne lance pas `ccl_scan_run()`;
  - scanne directement uniquement les supports de lots temporaires Quiz non couverts;
  - persiste ces diagnostics directs dans `content_links_check_results` sans supprimer les resultats globaux.
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - ajoute le handler JSON `session_supports_check`.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - ajoute le CTA `Verifier les supports de cette session`;
  - garde le formulaire demo existant separe;
  - ajoute badges et rendu de synthese/action.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/controle_liens/ec_controle_liens_lib.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `rg -n "ccl_scan_run\\(" /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php` ne retourne rien.

### Documentation
- `CHANGELOG.md`
- `canon/repos/pro/README.md`
- `canon/repos/pro/TASKS.md`
- `HANDOFF.md`

## Games organizer: modale prelaunch en 2 panneaux fixes — 2026-04-28

- Follow-up 2026-04-28:
  - passe wording sur les textes visibles du parcours prelaunch actuel: modale, panneaux connexion/direct et son/medias, statuts globaux, checks reseau, conseils, rappel de lancement, bandeaux et gate telecommande;
  - les messages utilisateur sont maintenant en tutoiement, sans jargon visible (`WebSocket`, `localStorage`, `sessionStorage`, `Profil reseau navigateur`, `API YouTube`, `preflight`, `RTT`);
  - aucune logique fonctionnelle n'a ete modifiee dans cette passe wording;
  - les wordings legacy du scan complet des supports multimedia et des remplacements temporaires n'ont pas ete reecrits;
  - le CTA jingle temoin est desactive tant que la verification configuration/connexion n'est pas terminee;
  - `runSoundControl()` verifie aussi ce pre-requis pour eviter un lancement force par clic/DOM pendant le test 1;
  - le panneau jingle temoin est recentre sur ce qui est mesurable par le navigateur: demarrage du player;
  - les statuts et raisons ne parlent plus de volume/son; seul le succes ajoute un conseil conditionnel: si le jingle n'est pas entendu, verifier les equipements/le volume puis relancer le test;
  - clarification du diagnostic player/volume: un echec de demarrage du jingle temoin est traite comme probleme de player/lecture, pas comme probleme de volume;
  - en cas d'echec du jingle YouTube, le panneau ne pousse plus de check `sound_user` additionnel afin d'eviter les conseils contradictoires;
  - rattachement du controle lien/QR joueur au panneau configuration/connexion plutot qu'au panneau player/volume;
  - remplacement des actions `rechargez cette page` par `relancez ce test`;
  - reformulation de l'action stockage navigateur autour de la navigation privee et du stockage local;
  - retrait du bouton `Stop` associe au jingle temoin;
  - la fermeture de la modale continue de couper le jingle/test en cours via `stopSoundControl('modal_closed')`;
  - le test YouTube attend maintenant l'etat `PLAYING` avant de conclure positivement le controle player/volume;
  - un test interrompu par fermeture avant resultat ne marque plus le panneau player/volume comme valide;
  - le bouton `Fermer` de la modale reprend le style du bouton principal de confirmation de lancement.
- Objectif UX:
  - distinguer clairement les problemes de configuration/connexion des problemes player/son;
  - conserver la modale ouverte au chargement, mais afficher d'emblee les deux zones visibles.
- `games/web/includes/canvas/core/prelaunch_check.js`
  - remplace le rendu par etapes masquees par deux panneaux fixes:
    - `Verification de votre connexion et de sa stabilite.` lance automatiquement les checks configuration/connexion;
    - `Verification du player et du volume.` lance le jingle temoin au clic utilisateur;
  - ajoute des syntheses separees avec raison principale et actions recommandees par domaine;
  - ajoute une relance ciblee du panneau connexion sans transformer le CTA global de modale;
  - le CTA global de la modale reste uniquement `Fermer`.
- `games/web/includes/canvas/css/canvas_styles.css`
  - ajoute le header de panneau avec action a droite et repli mobile.
- `games/web/config.php`
  - bump `CANVAS_ASSET_VER` pour forcer la recuperation des assets Canvas modifies.
- Verification:
  - `node --input-type=module --check < /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js`
  - `php -l /home/romain/Cotton/games/web/config.php`

## Games organizer: prelaunch recentre sur la configuration — 2026-04-27

### Resume
- l'organizer `games` ne porte plus le scan des supports multimedia;
- le prelaunch automatique ne verifie plus que la configuration du poste/client;
- la pastille de statut est portee par le bouton `Lancer`, sans bouton `Verif`;
- la confirmation de lancement affiche la mini synthese technique et le controle du son;
- le lancement est bloque dans la confirmation uniquement si la configuration est rouge.

### Correctif follow-up
- `games/web/includes/canvas/core/prelaunch_check.js`
  - la modale prelaunch s'ouvre maintenant au chargement d'une session ouvrable et affiche le test de configuration en cours;
  - la synthese devient l'etape active des qu'un statut final est obtenu, ce qui corrige l'ecran intermediaire `Test termine / Affichage de la synthese...` qui pouvait rester visible;
  - le corps de la modale finale est simplifie: seul le reminder reste apres l'etape automatique, puis le controle player/volume s'affiche dessous si necessaire avec le style issu de l'ancienne confirmation de lancement;
  - le reminder force les conseils sous l'intitule d'actions, le bouton `Recharger la page` est masque en statut vert, et le CTA audio devient `Jingle temoin`;
  - l'etape automatique reste centree sur la configuration du poste; `media_dependency` n'est plus lance sans interaction utilisateur;
  - l'etape `Player et volume` reste dans cette modale et se lance via le bouton `Tester le player et le volume`, afin de fournir le geste navigateur necessaire au jingle/YouTube;
  - si la configuration est rouge, l'etape player/volume est masquee et les actions correctives restent visibles.
- `games/web/includes/canvas/core/boot_organizer.js`
  - la confirmation de lancement redevient simple, sans rappel prelaunch ni controle audio;
  - les lancements UI/remote rouvrent la modale prelaunch et s'arretent si le prelaunch est rouge ou si le garde-fou remote est encore actif;
  - en statut orange, la confirmation de lancement affiche un rappel compact `Configuration a surveiller - voir le test`; ce lien ferme la confirmation et rouvre la modale prelaunch;
  - le helper du rappel orange est au scope module pour rester accessible depuis `gateStartWithSessionMeta()` et eviter une erreur runtime avant la SweetAlert;
  - la popup papier d'invitation a ouvrir la telecommande attend la fermeture de la modale prelaunch et ne s'affiche pas en statut rouge.
- `games/web/includes/canvas/core/session_modals.js`
  - l'auto-ouverture du QR remote papier est bloquee tant que le garde-fou prelaunch est actif.
- `games/web/includes/canvas/core/canvas_display.js`
  - `Lancer` reste cliquable si le prelaunch est rouge afin de rouvrir la modale prelaunch au clic, sans demarrer la session.
- `games/web/includes/canvas/core/prelaunch_check.js`
  - l'auto-check s'aligne maintenant sur `window.ClientSessionMeta.isOpen`, qui est deja la source utilisee par la logique de lancement;
  - evite le cas `Configuration non verifiee` permanent quand la date brute n'est pas exploitable par le prelaunch alors que la page organizer autorise bien le lancement.
- `games/web/includes/canvas/core/prelaunch_check.js`
  - la confirmation de lancement affiche maintenant une phrase sans prefixe sous le verdict `Configuration a surveiller` ou `Configuration a corriger`;
  - cette phrase est derivee du premier check bloquant ou en vigilance, avec un wording non technique inspire des messages utilisateur existants, pour expliquer pourquoi l'organisateur doit verifier ou corriger avant de demarrer.
- `games/web/includes/canvas/core/prelaunch_check.js`
  - le bloc audio est renomme `Controle du player et du volume`;
  - la note `Lance le jingle temoin...` est affichee au-dessus du bouton;
  - dans la confirmation de lancement, le bloc est replace sous le reminder prelaunch, juste avant les boutons SweetAlert.
- `games/web/includes/canvas/css/canvas_styles.css`
  - ajoute le style de cette raison principale et de la note du controle player/volume dans le rappel prelaunch de confirmation.
- `games/web/includes/canvas/core/prelaunch_check.js`
  - `cancelPrelaunchCheck('launch_requested')` preserve maintenant un test deja termine au lieu de remettre l'etat a `untested` juste avant la confirmation de lancement.
  - les messages orange et rouge de confirmation generent jusqu'a 3 conseils cibles a partir des checks en alerte ou bloquants.
  - wording de confirmation ajuste: vert plus direct, non-verifie invite a recharger, conseil QR et conseil WebSocket reformules sans jargon.
  - le check navigateur couvre `localStorage` et `sessionStorage` via ecriture/lecture/suppression d'une cle temoin; si le stockage est bloque, il remonte une erreur bloquante explicite et arrete le prelaunch avant les checks reseau pour eviter les faux diagnostics.
  - le message rouge additionnel devient generique (`Corrige les points signales...`) au lieu de citer la connexion par defaut.
  - les textes utilisateur n'invitent plus a `relancer le test`; ils demandent de corriger le point puis de recharger la page.
  - wording rouge finalise: `Actions a effectuer`, phrase d'ouverture `La partie ne peut pas etre lancee dans l'etat actuel...`, et conseils reseau/stockage/session/QR alignes sur les actions utilisateur simples.
  - wording orange finalise: `La partie peut etre lancee, mais l'experience risque d'etre moins fluide sur ce poste`, avec conseils cibles alignes sur les scenarios reseau/direct/YouTube/QR.
- `games/web/includes/canvas/core/network_profile.js`
  - nouvelle source partagee pour la detection de profil reseau lent, reprise par le prelaunch et le player;
  - seuils alignes sur le player: audio `< 1.2 Mb/s`, video `< 2.0 Mb/s`, RTT `> 250 ms`, types `slow-2g/2g/3g` et `saveData`.
- `games/web/includes/canvas/core/prelaunch_check.js`
  - le prelaunch ecoute maintenant les changements `navigator.connection` pendant une session en attente et re-evalue seulement le check `network_profile`;
  - apres le prelaunch initial, une relecture differee du meme check compense le cas Chrome/DevTools ou le profil `Slow 4G` est expose apres les premiers scripts de boot;
  - objectif: une bascule DevTools vers `Slow 4G` ou un changement reseau reel met a jour la pastille et la confirmation sans relancer tout le test.
- `games/web/includes/canvas/core/prelaunch_check.js`
  - ajoute un check `network_probe` qui telecharge un asset Cotton avec cache-bust pour mesurer une latence/debit reel cote navigateur, y compris quand `navigator.connection` est absent;
  - `media_dependency` est recentre sur le chargement de l'API iframe YouTube via `getYouTubeAPI()` pendant l'auto-check;
  - le test player/lecture YouTube complet reste porte par le jingle temoin au clic, pour eviter de monter un player invisible pendant le chargement initial;
  - si l'API YouTube est bloquee et que la session contient des supports YouTube, le prelaunch peut passer rouge; si seul le jingle temoin est concerne, le point reste une vigilance orange.
  - les conseils de confirmation distinguent `network_slow`, `network_probe_unstable`, `media_slow` et `media_blocked` avec les formulations validees cote utilisateur.
  - les mises a jour liees au controle son (`audioProbe`) rafraichissent la modale sans resynchroniser le bandeau global prelaunch, pour eviter qu'un ancien orange/rouge reapparaisse au lancement ou a l'arret du jingle temoin.
  - les bandeaux auto-precheck reprennent maintenant les phrases courtes de la modale: `Configuration a surveiller...` et `Configuration a corriger...`.
  - apres l'ouverture WebSocket, les checks independants (`ws_stability`, acces joueur, profil reseau, `network_probe`, `media_dependency`) sont lances en parallele pour eviter que les nouveaux probes allongent lineairement le prelaunch.
  - la confirmation de lancement place maintenant le controle son centre au-dessus de la synthese, masque ce bloc en cas de configuration rouge, et rerend le bouton apres `Stop` pour permettre une relance du jingle temoin.
  - les conseils de lancement sont dedupliques par intention (`internet_connection`, `stable_connection`, `youtube`, etc.) plutot que par texte exact, pour eviter les doublons reseau.
  - le test manuel du jingle temoin met maintenant a jour `media_dependency` et le reminder de confirmation; un echec YouTube devient donc visible dans la synthese et peut bloquer si la session depend de supports YouTube.
- `games/web/includes/canvas/css/canvas_styles.css`
  - les couches Bootstrap/SweetAlert sont remontees au-dessus du bouton quit mobile (`z-index: 1300`), afin que la confirmation de lancement reste visuellement et fonctionnellement prioritaire.
- `games/web/includes/canvas/core/player/index.js`
  - le warm-up player utilise maintenant la meme fonction reseau que le prelaunch;
  - le bandeau player `Connexion lente detectee` est supprime tant que la session est `En attente`, pour laisser le prelaunch porter seul l'alerte avant lancement.
- `games/web/includes/canvas/core/session_modals.js` et `games/web/includes/canvas/core/ws_effects.js`
  - les acces stockage du boot organizer sont proteges contre les `SecurityError`, afin qu'un stockage bloque ne casse pas les modales/options ni l'initialisation WebSocket.
- `games/web/includes/canvas/core/canvas_display.js`
  - le bouton `Lancer` reste desactive tant que l'auto-check d'une session ouverte n'a pas produit un statut final (`ready`, `warning` ou `fail`).

### Correctif livre
- `games/web/organizer_canvas.php`
  - suppression du bouton footerbar `prelaunch-check-btn`.
- `games/web/includes/canvas/core/prelaunch_check.js`
  - `initPrelaunchCheck()` ne depend plus du bouton `Verif`;
  - auto-check borne aux sessions dans une vraie fenetre de lancement;
  - `runPrelaunchCheck()` force le mode config-only cote organizer;
  - scan supports conserve dans le fichier mais non appele par l'UI organizer;
  - ouverture automatique de la modale prelaunch au chargement;
  - ajout d'une phrase explicative non technique sous le verdict de configuration;
  - controle player/volume affiche comme etape 2 de la modale prelaunch.
- `games/web/includes/canvas/core/canvas_display.js`
  - pastille prelaunch sur `#play-pause-btn`;
  - plus de blocage amont de `Lancer` sur statut prelaunch rouge.
- `games/web/includes/canvas/core/boot_organizer.js`
  - SweetAlert de lancement simplifiee;
  - garde-fou prelaunch applique aux lancements UI/remote et a la popup papier remote.
- `games/web/includes/canvas/css/canvas_styles.css`
  - styles de pastille sur `Lancer`, bloc player/volume de confirmation, raison principale et note explicative.

### Verification
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `git -C /home/romain/Cotton/games diff --check`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `git -C /home/romain/Cotton/games diff --check`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js /tmp/boot_organizer.mjs && node --check /tmp/boot_organizer.mjs`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js /tmp/canvas_display.mjs && node --check /tmp/canvas_display.mjs`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `git -C /home/romain/Cotton/games diff --check`

### Suite
- integrer le scan supports sur la fiche detail de session EC `pro`, section `Tester`, en reutilisant les actions de remplacement deja disponibles.

### Documentation
- `CHANGELOG.md`
- `canon/repos/games/README.md`
- `canon/repos/games/TASKS.md`
- `HANDOFF.md`

## Games organizer: stop du jingle temoin prelaunch — 2026-04-27

### Resume
- la synthese du test prelaunch propose toujours `Lancer le jingle temoin`;
- un bouton `Stop` apparait maintenant quand le test de son est actif;
- la fermeture de la modale coupe aussi le jingle temoin en cours.

### Correctif livre
- `games/web/includes/canvas/core/prelaunch_check.js`
  - suivi du media audio/YouTube actif via un stopper interne;
  - bouton `Stop` branche sur la meme coupure;
  - listeners `hide.bs.modal` / `hidden.bs.modal` pour couper le test sonore a la fermeture.

### Verification
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `git -C /home/romain/Cotton/games diff --check`

### Documentation
- `CHANGELOG.md`
- `canon/repos/games/README.md`
- `canon/repos/games/TASKS.md`
- `HANDOFF.md`

## Games organizer: injection JSON inline durcie — 2026-04-27

### Resume
- audit cible sur le chargement incomplet de `organizer_canvas.php` en session demo `quiz` avec le lot `L246`;
- cause probable isolee: donnees de preload/playlist injectees dans des `<script>` inline sans echappement HTML adapte;
- correctif livre pour neutraliser les sequences type `</script>` et les octets UTF-8 invalides avant injection JS.

### Correctif livre
- `games/web/organizer_canvas.php`
  - ajout de `canvas_inline_json(...)`;
  - remplacement des injections `json_encode(...)` inline pour `ServerSessionMeta`, `Preload`, `AppConfig`, `GameMeta`, branding, defaults design, titre et lots;
  - flags utilises: `JSON_HEX_TAG`, `JSON_HEX_AMP`, `JSON_HEX_APOS`, `JSON_HEX_QUOT`, `JSON_INVALID_UTF8_SUBSTITUTE`, avec conservation de l'Unicode et des slashs.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `git -C /home/romain/Cotton/games diff --check`

### Documentation
- `CHANGELOG.md`
- `canon/repos/games/README.md`
- `canon/repos/games/TASKS.md`
- `HANDOFF.md`

## Quiz V2 papier + agenda EC: anti-rejeu, format stable, visuels par lots — 2026-04-27

### Resume
- audit et correctifs livres sur le flux `Cotton Quiz V2` papier et l'agenda EC;
- le controle anti-rejeu ne depend plus seulement des tables quiz historiques;
- le choix `Numerique` / `Classique` reste stable pendant l'edition des dates;
- les cartes agenda resolvent les visuels `Quiz V2` depuis les vrais `lot_ids` de la session.

### Correctif livre
- `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `qz_temp_ctx_init(...)` accepte maintenant l'id session et une fenetre de jours;
  - exclusion symetrique des sessions passees/futures dans la fenetre courante;
  - ajout des exclusions V2 depuis `championnats_sessions.lot_ids` et `questions_lots_temp.question_ids`;
  - repli progressif des fenetres `350`, `300`, `240`, `180`, `120`, `60` jours si le vivier est trop contraint;
  - ajout de helpers de visuel par lot/session V2 bases sur les lots `L...` reels;
  - addendum prod: suppression du fallback visuel legacy quand les `lot_ids` sont absents;
  - ajustement final: selection du dernier lot `L...` de `lot_ids`, puis visuel custom de ce lot ou defaut;
  - instrumentation temporaire prod retiree apres confirmation des logs dev/prod.
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `app_jeu_get_detail(...)` accepte les `lot_ids` et les utilise pour les metadonnees/visuels `Quiz V2`.
- `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
  - le polling ne reecrit plus les radios de version/format apres interaction locale utilisateur.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - les cartes agenda passent les `lot_ids` au socle de detail jeu.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_play_classic.php`
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - les appels secondaires a `app_jeu_get_detail(...)` transmettent aussi les `lot_ids` deja charges.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_play_classic.php`
- `git diff --check`

### Documentation
- `CHANGELOG.md`
- `canon/repos/global/README.md`
- `canon/repos/global/TASKS.md`
- `canon/repos/pro/README.md`
- `canon/repos/pro/TASKS.md`
- `HANDOFF.md`

## Games organizer: pre-check auto et garde stricte avant lancement — 2026-04-24

### Resume
- la page organizer lance maintenant automatiquement l'etape 1 du test au chargement, sans attendre d'action utilisateur;
- ce pre-check auto reste volontairement borne aux verifications techniques minimales;
- le scan multimedia et le controle du son restent reserves au test complet ouvert via le bouton `Test`;
- l'etat visuel de l'UI organizer est synchronise des l'arrivee: pastille `Test`, bandeau orange/rouge, activation ou non du bouton `Lancer`.

### Correctif livre
- `games/web/includes/canvas/core/prelaunch_check.js`
  - introduit maintenant une machine d'etat simple du test:
    - `inactive`
    - `auto_running`
    - `manual_running`
    - `completed`
    - `cancelled`
  - distingue maintenant `auto_precheck` (etape 1 seule) et `full` (test complet);
  - le pre-check auto s'arrete apres les checks techniques et marque l'etat media comme `skipped_auto`, sans lancer le scan des supports ni le son;
  - le clic sur `Test` reroute vers un test complet si l'etat courant vient seulement du pre-check auto;
  - si le jeu n'est plus `En attente`, le module masque `Test`, ferme la modale de test et annule explicitement tout scan en cours;
  - un retour vers `En attente` reprepare un etat `untested` puis relance un pre-check auto court;
  - correctif complementaire du 2026-04-24:
    - cause racine de la forte lenteur post-lancement identifiee dans le watcher `GameStore.subscribe(...)` du prelaunch;
    - apres passage hors `En attente`, ce watcher rappelait `cancelPrelaunchCheck('game_not_pending')` sur chaque patch du store gameplay, ce qui regenérait en boucle l'etat `prelaunch` et ses rerenders;
    - le watcher ne reagit maintenant qu'aux vraies transitions de `status.gameStatus`, et l'init du module est verrouillee pour eviter un double abonnement accidentel;
  - le rouge est reserve aux incompatibilites de lancement strictes: `organizer_boot`, `session_context`, `bridge`, `ws_open`, `ws_stability`, `network_profile` offline, ou erreur runtime du test;
  - un echec non critique (ex. stockage local ou lien joueur/QR) remonte maintenant en vigilance orange au lieu de bloquer le lancement;
  - le pre-check auto reutilise maintenant le bandeau organizer partage `bannerWarn` / `bannerError` au lieu d'un conteneur dedie, afin de garder une alerte visible au-dessus de la footerbar fixe;
  - pas de bandeau si OK;
  - bandeau orange `Connexion a surveiller. La partie peut etre lancee, mais certains medias peuvent demarrer avec un leger delai.` si vigilance, avec disparition automatique comme le bandeau de jeu;
  - bandeau rouge `Connexion insuffisante pour lancer dans de bonnes conditions. Verifie la connexion puis relance le test.` si blocage, avec disparition automatique comme l'orange pour rendre la footerbar a nouveau accessible;
  - wording utilisateur simplifie sur la modale, la synthese, les diagnostics supports, le bouton `Test` et le rappel de lancement, sans changement de logique metier.
  - la synthese principale est maintenant contextuelle:
    - elle n'accuse plus la connexion si le seul probleme detecte concerne des liens/supports multimedia;
    - elle bascule sur une phrase supports-only quand la technique est OK mais que certains supports restent problematiques;
    - elle garde une phrase connexion quand le sujet est uniquement reseau/temps reel;
    - elle utilise une phrase generique seulement en cas mixte.
  - le cas support-only reprend le meme message que le bloc supports, pour eviter toute ambiguite sur la cause principale.
  - pendant le scan de l'etape 2, la ligne courante est volontairement minimaliste:
    - `Verification du support n° X`;
    - message `On verifie ce lien...`;
    - aucune exposition de titre/artiste/question/reponse tant que le support n'est pas encore passe dans la synthese.
  - le bouton footerbar est maintenant plus compact:
    - label `Verif`;
    - tooltip `Verifier la configuration avant lancement`.
- `games/web/includes/canvas/core/canvas_display.js`
  - le systeme de bandeaux partages calcule maintenant son offset bas a partir de la vraie hauteur de `.organisateur-menu`, pour remonter toutes les alertes organizer au-dessus de la footerbar fixe;
  - le bouton `Test` est maintenant visible uniquement quand le jeu est `En attente`;
  - en etat `En attente`, le bouton `Lancer` ne requiert plus `jingleReady` avant le premier clic: le jingle est prime pendant ce clic de lancement, ce qui supprime le deadlock observe quand la configuration etait OK mais que le CTA restait grise;
  - la footerbar se rerend maintenant explicitement sur les evenements `prelaunch/*` utiles (`init`, `start`, `check_result`, `complete`, `network_confirm_required`), afin que l'etat `running` du test auto ne laisse plus un bouton `Lancer` fige en desactive apres retour a `ready` / `warning`;
  - en etat `En attente`, le bouton `Lancer` reste bloque tant que le pre-check auto ou le test manuel tournent;
  - une fois le pre-check termine, `Lancer` n'est desactive que si le statut prelaunch est rouge.
- `games/web/includes/canvas/core/boot_organizer.js`
  - toute demande de lancement (`ui` ou `remote`) annule desormais explicitement le test en cours avant de poursuivre le flux de demarrage.
- `games/web/includes/canvas/css/canvas_styles.css`
  - retire le conteneur de bandeau inline dedie; le style modal prelaunch est conserve.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/canvas_display.js /tmp/canvas_display.mjs && node --check /tmp/canvas_display.mjs`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs` (apres correctif perf post-lancement)

## PRO controle des liens YouTube: diagnostic Data API aligne cron — 2026-04-23

### Resume
- adaptation du module `pro` de controle des liens pour remonter les liens YouTube reellement inutilisables avec les memes familles de causes que le cron BO Bingo Musical;
- objectif: preparer une exploitation ulterieure depuis `games`, sans lancer d'appel YouTube Data API depuis l'organizer.

### Correctif livre
- `pro/web/ec/modules/jeux/controle_liens/ec_controle_liens_lib.php`
  - extraction YouTube elargie a `/live/{id}`;
  - ajout d'un controle Data API par batch de 50 videos dedoublonnees;
  - mapping des diagnostics: `unavailable`, `not_public`, `embed_restricted`, `age_restricted`, `live_stream`, `region_blocked_fr`, `technical_error`, `ok`;
  - fallback `oEmbed` conserve si la cle Data API manque ou si l'API est indisponible.
- `pro/web/ec/modules/jeux/controle_liens/ec_controle_liens_list.php`
  - wording du module mis a jour pour ne plus annoncer un scan `V1` oEmbed-only.

### Points de vigilance
- le scan ecrit toujours uniquement dans `content_links_check_results`;
- aucun write durable n'est encore applique sur les contenus source;
- l'exploitation cote `games` reste a faire via une lecture DB des resultats de scan existants.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/controle_liens/ec_controle_liens_lib.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/controle_liens/ec_controle_liens_list.php`

## Games organizer: test pre-lancement auto + synthese — 2026-04-23

### Resume
- simplification du module de test organizer en un parcours automatique puis synthese:
  - verifications techniques;
  - verification des supports multimedia;
  - synthese avec recommandations, remplacements de liens et controle du son.
- les etapes 1 et 2 s'enchainent dans le meme bloc; la synthese devient l'affichage par defaut lors d'une reouverture apres test.
- la synthese est allegee: intro redondante retiree, ton moins technique, blocs affiches seulement quand ils aident vraiment.
- le bandeau global de statut est retire de la modale.

### Correctif livre
- `games/web/includes/canvas/core/prelaunch_check.js`
  - conservation d'un etat `activeStep` limite au bloc de test automatique puis a la synthese;
  - affichage du seul controle technique courant pendant l'analyse, puis synthese en fin d'etape;
  - lancement automatique du scan media apres les controles techniques, sans CTA intermediaire;
  - progression du scan media limitee au support courant pendant l'analyse, puis remplacements des supports problematiques dans la synthese;
  - exclusion du jingle commun `isJingle` du scan media;
  - controle du son integre a la synthese, avec lecture du jingle temoin si disponible puis fallback sonore;
  - remplacement du verdict technique par une phrase douce: aucun blocage, points a surveiller, ou risque de lancement perturbe;
  - bloc technique conditionnel: mention discrete si OK, recommandations si vigilance, explication simple si blocage;
  - arret avant le scan des supports si l'etape technique detecte une connexion Internet indisponible ou une WebSocket KO/instable; la synthese masque alors les supports multimedia et propose `Relancer le test`;
  - le cas offline cote navigateur (`navigator.onLine === false`) est desormais libelle comme connexion Internet indisponible avec recommandation de reconnexion; `downlink` reste un signal de qualite reseau, pas un critere offline;
  - le controle bridge est reformule cote utilisateur en `Communication avec l’application`, sans mention `Bridge` ni `connexion Cotton`;
  - profil reseau lent selon les seuils du player principal, ou latence applicative preflight > 2500 ms, traite comme vigilance forte: le scan media n'est pas lance dans cet environnement; l'organizer peut ameliorer le reseau puis relancer le test, ou accepter le risque au lancement;
  - une latence bridge/WS seule reste une vigilance si le service fonctionne encore, pour eviter un blocage abusif du scan media;
  - bloc supports reformule par jeu: questions perturbees en `Quiz`, morceaux perturbes en `Blind Test` / `Bingo Musical`; affichage en vigilance, sans rouge/croix de blocage;
  - timeout YouTube du scan prelaunch traite comme non conclusif (`A valider manuellement`) avec fenetre 15 s / 20 s en profil lent, pour eviter de marquer faux inactifs des liens corrects sous throttling 3G;
  - reouverture apres test sur la synthese pour continuer les corrections ou relancer un test;
  - espacement vertical renforce entre les blocs de synthese;
  - libelle des supports enrichi avec `titre — artiste` quand disponible;
  - liens d'aide `YT Music` pour les titres musicaux et `YouTube` pour les videos quiz, deplaces dans le formulaire de remplacement sous `Lien temporaire de remplacement`;
  - affichage de la bonne reponse sous la question des supports video quiz, y compris sur une synthese deja stockee, et recherche video quiz basee en priorite sur cette bonne reponse quand elle est disponible;
  - normalisation des liens temporaires YouTube/Music/shorts/embed en URL runtime `youtube.com/watch?v=...` avant application a `GameStore.playlist.songs`, avec conservation des parametres temporels utiles;
  - application/restauration d'un lien temporaire sans relancer le test complet: la synthese reste ouverte et la ligne support est mise a jour directement;
  - controle son sans confirmation utilisateur: bouton `Lancer le jingle temoin` + mention discrete si le signal est entendu; le jingle temoin est laisse en entier.
- `games/web/includes/canvas/css/canvas_styles.css`
  - styles pour CTA d'etape, ligne courante avec statut individuel, message son et liens de recherche.

### Verification
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`

## Games pre-lancement: lecture diagnostics catalogue YouTube — 2026-04-23

### Resume
- l'etape 2 du test pre-lancement `games` exploite maintenant les resultats du scan `pro` stockes dans `content_links_check_results`;
- objectif: avertir l'organisateur qu'un support YouTube est deja connu comme inutilisable, sans relancer YouTube Data API depuis l'organizer.

### Correctif livre
- `games/web/includes/canvas/php/boot_lib.php`
  - ajout du read bridge `youtube_catalog_diagnostics_get`;
  - extraction `videoId` compatible YouTube/Music/shorts/embed/live;
  - lecture read-only de `content_links_check_results`;
  - aucun write DB, aucun appel YouTube Data API.
- `games/web/includes/canvas/core/prelaunch_check.js`
  - l'etape media appelle `youtube_catalog_diagnostics_get` une fois par scan;
  - les statuts catalogue `unavailable`, `not_public`, `embed_restricted`, `age_restricted`, `live_stream`, `region_blocked_fr` sont remontes comme supports problematiques;
  - si aucun diagnostic catalogue n'existe, le test iframe/local existant reste le fallback.

### Points de vigilance
- aucun controle de fraicheur n'est applique pour l'instant;
- le cron journalier devra ensuite alimenter regulierement `content_links_check_results`;
- le lien temporaire reste session-only et ne corrige pas la source.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`

## Games organizer: test pre-lancement V1 — 2026-04-23

### Resume
- ajout d'un test pre-lancement V1 dans `games`, declenche manuellement depuis l'organizer;
- CTA ajoute dans la footerbar a cote du bouton `Lancer`, avec etat visuel neutre / OK / vigilance / probleme;
- la confirmation de lancement reste le flux principal, mais affiche le dernier etat du diagnostic.
- ajustement UX courant: la modale enchaine automatiquement les verifications techniques puis media, avant de basculer sur une synthese persistante.

### Correctif livre
- `games/web/organizer_canvas.php`
  - alias import map `@canvas/core/prelaunch_check`;
  - bouton `#prelaunch-check-btn` avec icone `bi-shield-check`.
- `games/web/includes/canvas/core/prelaunch_check.js`
  - nouveau module session-bound;
  - checks boot, storage, bridge Canvas, WebSocket, QR/lien joueur, contexte session;
  - etape technique compacte si OK, actionnable si KO, avec preflight de fluidite minimale base sur latence bridge, delai d'ouverture WS, stabilite courte, profil `navigator.connection` si disponible et disponibilite/latence YouTube si utile;
  - enchainement automatique des verifications techniques puis du scan media, sans CTA intermediaire;
  - scan prudent des supports reels via `GameStore.playlist.songs`, dont YouTube via API iframe, avec affichage du support courant pendant le traitement.
  - remediation immediate: saisie/test/application d'un lien temporaire pour les supports problematiques;
  - application runtime uniquement sur `GameStore.playlist.songs`, persistee en `sessionStorage` pour la session courante.
- `games/web/includes/canvas/core/boot_organizer.js`
  - initialisation du module;
  - rappel de statut dans la modale `Lancer la session maintenant ?`.
- `games/web/includes/canvas/css/canvas_styles.css`
  - styles CTA, modal, badges, rappel de lancement.
- `games/web/includes/canvas/core/logger.global.js`
  - logs `PRELAUNCH_START`, `PRELAUNCH_CHECK`, `PRELAUNCH_COMPLETE`;
  - logs `PRELAUNCH_MEDIA_SCAN_COMPLETE`;
  - logs `PRELAUNCH_REPLACEMENT_TEST`, `PRELAUNCH_REPLACEMENT_APPLY`, `PRELAUNCH_REPLACEMENT_RESET`.

### Points de vigilance
- le diagnostic media reste volontairement prudent: un support charge par YouTube/API iframe peut rester `A valider manuellement` tant que la lecture audible n'a pas ete verifiee par l'organisateur;
- le preflight technique remonte seulement des signaux observes dans l'environnement organizer; il ne promet ni debit minimal, ni fluidite garantie;
- la V1 scanne l'ensemble des supports audio/video detectes dans `GameStore.playlist.songs`;
- aucune version minimale navigateur, debit, port ou regle firewall n'a ete inventee.
- les remplacements temporaires ne modifient pas la source DB; une correction durable admin/base reste hors scope.

### TODO
- ajouter ulterieurement un flux admin pour marquer/corriger durablement les liens source problematiques.

### Verification
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/prelaunch_check.js /tmp/prelaunch_check.mjs && node --check /tmp/prelaunch_check.mjs`
- `cp /home/romain/Cotton/games/web/includes/canvas/core/boot_organizer.js /tmp/boot_organizer.mjs && node --check /tmp/boot_organizer.mjs`

## Global leaderboards quiz legacy: rang de session rederive des scores — 2026-04-17

### Resume
- audit mene sur un cas `Mes joueurs` quiz legacy ou la fiche session etait correcte, mais le leaderboard agrege donnait `#1 / 500 pts` a toutes les equipes;
- diagnostic confirme:
  - les fiches session legacy lisent correctement `championnats_resultats.equipe_session_points`;
  - l'agregat `Mes joueurs` lisait encore `championnats_resultats.position`;
  - pour certaines sessions legacy recentes, `position` est incoherent voire rempli a `1` partout.

### Correctif livre
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - pour le quiz legacy uniquement, le calcul agrege ne lit plus `position` pour attribuer les points saison;
  - il reconstruit d'abord le rang de session a partir de:
    - `equipe_session_points` DESC
    - puis `equipe_quiz_points` DESC
    - puis `label` ASC
  - il reapplique ensuite le bareme saison existant via le helper deja en place.

### Effet attendu
- les leaderboards agreges `Cotton Quiz` de `pro`, `play` et `www` redeviennent coherents avec les fiches session legacy;
- le correctif est borne aux quiz legacy et ne touche ni les jeux runtime modernes ni les autres jeux.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## WWW FO statique 2026: chargement global Bootstrap Icons restaure — 2026-04-17

### Resume
- audit declenche apres constat d'icones absentes sur les nouvelles pages FO `solutions/*` et `decouvrir*`;
- le journal AI Studio et le reload prod ont confirme que les templates/assets statiques 2026 existaient bien cote serveur, mais pas toujours dans le workspace local;
- cause racine retenue: les nouveaux templates utilisent `Bootstrap Icons` (`bi ...`), alors que le layout global `www/web/fo/fo.php` ne chargeait plus la feuille `bootstrap-icons.css`.

### Correctif livre
- `www/web/fo/fo.php`
  - ajout du chargement global `https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css` juste apres Bootstrap;
  - les icones `bi` des pages statiques FO 2026 ne dependent plus d'un widget local charge ailleurs.

### Effet attendu
- les icones des pages suivantes redeviennent visibles sans patch unitaire par template:
  - `/fr/solutions/bars-lieux-de-vie`
  - `/fr/decouvrir`
  - et, par extension, les autres nouvelles pages statiques `solutions/*` et `decouvrir/*` qui reutilisent `bi`.

### Verification
- `php -l /home/romain/Cotton/www/web/fo/fo.php`

## PRO fiche session terminee: upload podium local recentre sur la bibliotheque — 2026-04-17

### Resume
- la fiche detail `pro` d'une session archivee portait encore 2 evolutions devenues contradictoires avec le recentrage produit:
  - sur desktop, `Ajouter une photo` ouvrait une modale avec QR code pour basculer vers l'EC mobile;
  - sur mobile, le CTA local ouvrait encore un mini-menu `Caméra / Photos`.
- or la regle cible est maintenant:
  - prise de photo directe => remote uniquement;
  - fiche detail `pro` => choix d'une photo deja existante sur l'appareil courant.

### Correctif livre
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - suppression du helper local de generation de QR code d'acces mobile pour ce flux;
  - suppression de la modale desktop de bascule mobile par QR;
  - suppression du mini-menu mobile `Caméra / Photos`;
  - remplacement par un seul CTA local `Ajouter une photo` / `Modifier la photo` qui ouvre directement le picker fichier;
  - l'input retire explicitement `capture`, donc meme sur mobile la fiche detail ouvre la bibliotheque et non la camera.

### Effet attendu
- sur desktop:
  - plus de QR code ni de modale intermediaire;
  - le clic ouvre simplement le choix de fichier local.
- sur mobile:
  - plus de proposition camera;
  - le clic ouvre seulement la bibliotheque/photos du telephone.
- pour prendre une photo en direct depuis un smartphone:
  - l'organisateur doit passer par la remote, qui reste le parcours dedie.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## Games player podium photo: synchro remote -> player sur ecran de fin — 2026-04-17

### Resume
- cause racine identifiee: cote joueur, `player_podium_photo_access_get` etait relu au passage en `Partie terminee`, puis l'etat restait fige;
- si l'organisateur ajoutait ensuite une photo depuis la remote, la carte player continuait donc d'afficher son ancien etat local (`Ajouter une photo`) au lieu de la photo effective et du verrou organisateur.

### Correctif livre
- `games/web/includes/canvas/play/play-ui.js`
  - ajout d'un refresh leger `player_podium_photo_access_get` toutes les `10s`, borne au seul etat `Partie terminee`;
  - ajout d'un refresh immediat au retour de focus et quand l'onglet redevient visible;
  - le polling se coupe des qu'on quitte l'ecran de fin ou si l'identite joueur/session n'est plus exploitable;
  - garde-fou UX: si le joueur a deja selectionne une photo locale, le polling n'ecrase pas ce draft tant qu'aucun verrou organisateur n'arrive;
  - si la relecture remonte finalement une photo `managed by organizer`, le draft local est nettoye et la carte repasse sur la preview/photo verrouillee.
  - addendum UX:
    - le draft local du joueur affiche maintenant une vraie preview de l'image choisie avant upload, comme la remote;
    - quand une photo organisateur est deja prioritaire, la carte masque aussi le texte d'incitation `Partage une photo paysage...` et garde seulement la note passive;
- `games/web/includes/canvas/php/boot_lib.php`
  - `player_podium_photo_access_get` renvoie maintenant une `photo_signature` compacte;
  - le front player compare cette signature avant de rerendre la carte pendant le polling, comme le fait deja la remote sur `session_meta_get`.
- `games/web/includes/canvas/css/player_styles.css`
  - la ligne `Photo selectionnee : ...` casse maintenant proprement sur mobile pour eviter tout debordement horizontal avec un nom de fichier long.

### Effet attendu
- apres un upload remote organisateur, l'ecran de fin joueur finit par se resynchroniser sans reload manuel;
- le CTA `Ajouter une photo` disparait alors au profit de la photo visible et du message passif organisateur;
- un draft local joueur encore non envoye n'est pas ecrase par un simple refresh neutre.

### Verification
- verification manuelle du diff JS sur `games/web/includes/canvas/play/play-ui.js`
- non verifie ici dans un navigateur reel:
  - propagation visuelle exacte apres upload remote live;
  - latence percue entre upload remote et refresh player.

## Games Bingo demo reset: purge `bingo_phase_winners` + cleanup LS player — 2026-04-17

### Resume
- audit cible sur la rejouabilite d'une session demo `Bingo Musical`;
- cause racine double identifiee:
  - `resetdemo` remettait bien playlist/grilles/logs a zero, mais laissait survivre `bingo_phase_winners`;
  - le player rechargeait ensuite un etat local Bingo ancien (`bingo_checked`, `bingo_locked`, `bingo_best_phase`) au lieu de repartir d'un etat vierge.

### Correctif livre
- `games/web/includes/canvas/php/bingo_adapter_glue.php`
  - `_bingo_reset_demo_state(...)` supprime maintenant aussi `bingo_phase_winners` pour la session;
  - le contrat demo reste sinon identique: joueurs et assignations de grilles sont conserves.
- `games/web/includes/canvas/play/play-ws.js`
  - le handler `demo_reset` bascule maintenant d'abord l'UI player Bingo en `En attente`, remet `mainStarted` a `false`, reset la grille, puis purge les cles localStorage ci-dessous avant `window.location.reload()`:
    - `bingo_checked`
    - `bingo_locked`
    - `bingo_best_phase`

### Effet attendu
- apres `Restart` sur une demo Bingo:
  - aucun gagnant de phase precedent ne revient dans le preload organizer/remote;
  - le player ne rehydrate plus d'anciennes coches/locks/medailles locales;
  - la demo peut etre rejouee proprement sans toucher au flux `reset` de lancement.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `node --check /home/romain/Cotton/games/web/includes/canvas/play/play-ws.js`
  - non exploitable tel quel ici: fichier ESM navigateur avec imports `@canvas/*`.

## Games player: upload photo podium mobile + consentement trace — 2026-04-17

### Resume
- objectif retenu: permettre a un vainqueur d'ajouter sa photo depuis le player mobile a la fin de session, sans ouvrir ce flux a tous les joueurs et sans dupliquer le back remote deja en place;
- contrainte cle: le CTA ne doit pas etre une autorisation suffisante a lui seul. Le serveur doit revérifier:
  - session terminee/archivee;
  - joueur courant;
  - podium uniquement;
  - lien espace joueur present;
  - consentement coche.

### Correctif livre
- `games/web/player_canvas.php`
- `games/web/includes/canvas/css/player_styles.css`
- `games/web/includes/canvas/play/play-ui.js`
  - nouvelle carte de fin de session pour l'upload photo du joueur;
  - CTA visible seulement si `player_podium_photo_access_get` confirme l'eligibilite;
  - mini flux mobile `Camera / Photos`, case de consentement obligatoire, message d'etat;
  - addendum UX:
    - un draft photo local peut maintenant etre supprime avant envoi;
    - le reset reaffiche `Ajouter une photo` et vide le consentement courant.
- `games/web/includes/canvas/php/boot_lib.php`
  - nouvelles actions bridge:
    - `player_podium_photo_access_get`
    - `player_podium_photo_upload`
  - revalidation serveur de l'eligibilite avant write.
- `games/web/includes/canvas/remote/remote-ui.js`
- `games/web/includes/canvas/css/remote_styles.css`
  - la remote ajoute maintenant une etape draft + consentement organisateur avant l'upload photo;
  - le draft peut etre supprime avant envoi pour revenir au CTA precedent.
- `games/web/includes/canvas/php/ep_account_bridge.php`
- `games/web/includes/canvas/php/quiz_adapter_glue.php`
- `games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `games/web/includes/canvas/php/bingo_adapter_glue.php`
  - l'inscription runtime propage maintenant `ep_connect_token` au bridge, pour fiabiliser la presence d'une identite espace joueur exploitable lors de la verification d'eligibilite.
- `games/web/games_ajax.php`
- `games/web/includes/canvas/core/api/api_client.js`
  - declaration du nouveau write bridge player.
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - le helper upload podium partage accepte maintenant un bloc `consent`;
  - si la preuve de consentement ne peut pas etre persistee, le media uploadé est supprime.
- `games/web/includes/canvas/sql/2026-04-17_player_podium_photo_consent.sql`
  - nouvelle table `championnats_sessions_podium_photos_consents` pour tracer le consentement par upload.
- `games/web/includes/canvas/sql/2026-04-17_player_podium_photo_consent_runtime_snapshot.sql`
  - ajoute `runtime_username` / `runtime_label` pour retrouver plus facilement la photo et le joueur runtime lors d'une demande d'effacement.

### Choix de stockage consentement
- recommandation retenue: stockage sur l'upload, pas seulement sur le joueur;
- justification:
  - preuve plus forte et contextualisee;
  - lien direct avec le `media_image_id` cree;
  - pas de faux positif de type "le joueur a consenti une fois, donc toutes les photos futures sont couvertes".
- implementation:
  - la ligne de consentement duplique aussi les ids joueur/runtime/bridge utiles (`id_joueur`, `id_equipe`, `game_player_id`, `game_player_key`, `bridge_id`) pour faciliter l'audit.

### Risques / points a suivre
- addendum 2026-04-17:
  - le flux est maintenant ouvert aux podiums non relies EP;
  - la trace de consentement ne prouve donc plus un lien compte Cotton, mais reste suffisante pour retrouver photo + session + joueur runtime snapshotte.
- addendum remote 2026-04-17:
  - une photo organisateur visible verrouille maintenant le remplacement cote player;
  - limite restante:
    - les anciennes photos organisateur historiques sans trace de consentement/source explicite ne peuvent pas toujours etre reconnues comme telles a posteriori.
- la migration SQL doit etre appliquee avant mise en production pour activer la persistance du consentement.

### Verification
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/ep_account_bridge.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/games_ajax.php`
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- verification navigateur non executee ici:
  - pas de parcours mobile interactif ni d'upload reel depuis device dans cette sandbox;
  - `node --check` non fiable sur les modules ESM front sans import map navigateur.

## Games remote podium: upload distinct par gagnant ex aequo — 2026-04-17

### Resume
- la remote de fin de partie savait deja uploader des photos podium, mais restait encore indexee `par rang`;
- quand plusieurs gagnants partageaient la meme marche (`#1 / #1`, etc.), les deux tuiles remote reutilisaient le meme `photo_row_key` implicite ou la meme photo de rang;
- besoin retenu: realigner `games remote` sur la granularite deja utilisee cote `pro`, sans changer le helper backend partage.

### Correctif livre
- `games/web/includes/canvas/php/boot_lib.php`
  - `session_meta_get` expose maintenant toutes les rows podium `1..3`, meme sans photo, avec `photo_row_key`, `label`, `score`, `phase_label`, `photo_src`.
- `games/web/includes/canvas/php/quiz_adapter_glue.php`
- `games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `games/web/includes/canvas/php/bingo_adapter_glue.php`
  - le preload `serverSessionMeta.podium_photos` suit la meme regle pour donner a la remote les row keys des l'ouverture.
- `games/web/includes/canvas/remote/remote-ui.js`
  - le podium termine matche maintenant une row meta par ligne visible au lieu d'utiliser une simple resolution `par rang`;
  - les boutons photo transportent `rank + photo_row_key`, ce qui cible le bon gagnant sur un rang partage;
  - un refresh `session_meta_get` est relance a la reception de `remote/end` pour hydrater rapidement la remote deja ouverte.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `node --check /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js`
  - non exploitable tel quel ici: fichier ESM navigateur avec imports `@canvas/*`.

## `pro` / `play` / `www`: ordre des ex aequo aligne sur `games` — 2026-04-17

### Resume
- plusieurs vues de resultats re-triaient encore localement les podiums a egalite de rang;
- symptome visible:
  - le podium et le classement complet d'une meme session pouvaient afficher les memes ex aequo dans un ordre different;
  - les podiums agreges (`Mes joueurs`, `Mes classements`, `place`) pouvaient aussi rebrasser localement des lignes deja ordonnees par le backend.
- besoin retenu:
  - prendre `games` comme source de verite de l'ordre sur les sessions runtime;
  - faire en sorte que les autres surfaces preservent cet ordre au lieu de recalculer un autre tie-break local.

### Correctif livre
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - les resultats runtime `quiz` / `blindtest` relisent maintenant `player_id` quand il existe dans les tables runtime;
  - cette cle devient la cle d'ordre secondaire du classement complet pour coller au tri stable de `games`;
  - la normalisation des podiums preserve maintenant l'ordre source entre ex aequo.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - les podiums de fiche session passent a un tri stable `rang puis position source`.
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_shared.php`
- `play/web/ep/modules/communication/home/ep_home_leaderboards_shared.php`
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - meme correction pour les podiums agreges.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_shared.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_leaderboards_shared.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## `pro` / `play` / `www`: libelles joueur agreges uniformises en prenom only — 2026-04-17

### Resume
- les sessions affichaient deja les joueurs avec un libelle court, mais certains classements / podiums agreges retombaient encore sur `prenom + nom`;
- le point commun etait le helper partage de libelle joueur utilise par les dashboards agreges.

### Correctif livre
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `app_client_joueurs_dashboard_player_label_get(...)` renvoie maintenant:
    - `pseudo` si disponible;
    - sinon `prenom` seul;
    - sinon `Joueur`.
- effet:
  - les podiums / classements agreges de `pro`, `play` et `www` n'affichent plus le nom de famille des joueurs;
  - les equipes ne changent pas.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PRO `Ma communauté`: trigger QR realigne avec son texte — 2026-04-16

### Resume
- sur la page `Ma communauté`, le raccourci QR devait maintenant respecter deux placements differents selon le viewport;
- le besoin final est:
  - mobile: bloc sous la description du compte;
  - desktop: texte au-dessus de l'icone dans la colonne QR.

### Correctif livre
- `pro/web/ec/modules/compte/client/ec_client_view.php`
  - le trigger desktop reste dans la colonne QR avec un layout vertical `texte puis icone`;
  - un trigger mobile dedie est ajoute sous la description du compte;
  - ce trigger mobile utilise un layout horizontal pour garder l'icone et le texte sur le meme axe.
  - le wrapper mobile ajoute aussi un peu plus de marge haute et basse pour aérer ce bloc sur petit écran.
  - le groupe mobile est maintenant recentre sous la description pour un rendu moins desequilibre.
  - le bouton mobile reapplique aussi un padding explicite pour neutraliser l'effet de `p-0`.
  - le bouton mobile reserve maintenant une hauteur minimale et borne mieux le SVG dans le flux pour eviter tout debordement visuel.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_view.php`

## PRO bibliothèque: aperçus YouTube courts audio/vidéo — 2026-04-16

### Resume
- dans la bibliothèque `pro`, les aperçus inline ne tenaient pas compte de la duree reelle du support quand aucune borne `start/end` n'etait fournie;
- effet visible: un support court pouvait partir trop pres de la fin si on conservait `30s`, alors qu'un support long pouvait perdre l'effet voulu si on forcait `0s`.

### Correctif livre
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - le helper PHP ne fixe plus un depart arbitraire hors bornes explicites;
  - les URLs qui embarquent deja `start` / `end` gardent leur comportement actuel;
  - cote lecteur, les aperçus calculent maintenant leur depart sur la duree reelle du media:
    - `>= 40s` => `30s`
    - `< 40s` => `0s`
  - la logique est branchee sur:
    - l'aperçu YouTube audio inline via l'API iframe YouTube;
    - l'aperçu YouTube video inline via un player JS API sur l'iframe embarquee;
    - l'aperçu video HTML5 local via `loaded metadata`.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`

## Games player runtime quit: purge locale session-scope au retour de page — 2026-04-16

### Resume
- un joueur runtime qui quittait volontairement une session pouvait revenir sur la page et rester bloque hors du formulaire d'inscription;
- l'audit a montre que le quit numerique ne supprimait que des cles legacy, alors que l'identite runtime canonique continuait de vivre dans des cles LS scopees par session.

### Correctif livre
- `games/web/includes/canvas/play/play-ui.js`
  - le quit volontaire appelle maintenant `clearPlayerIdentityForSession({ game, sid })` avant redirection;
  - supprime aussi `player-registered_<sessionId>` et `${slug}:player_db_id`;
  - en `bingo`, supprime en plus les cles de grille scopees par session (`grid_id` / `grid_number`).

### Effet attendu
- apres `Quitter la partie`, un retour sur la page affiche de nouveau le formulaire d'inscription;
- la page ne doit plus se croire en mode "joueur deja inscrit" a cause d'un reliquat LS scope sur la session.

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/play/play-ui.js`

## Games remote fin de partie: upload podium direct + CTA `pro` supprime — 2026-04-16

### Resume
- la remote de fin de partie proposait deja un CTA vers `pro` pour ajouter les photos des gagnants;
- mais ce parcours restait fragile sur mobile: la remote ouverte via le QR `master` ne transporte pas de contexte `client_contact` suffisant pour garantir un bypass signin robuste;
- besoin retenu: prendre les photos directement depuis la remote `games`, tout en gardant `master` et la fiche detail `pro` synchronises sur la meme source de verite.

### Correctif livre
- `games/web/includes/canvas/php/boot_lib.php`
  - ajoute l'action bridge `session_podium_photo_upload`;
  - l'endpoint resolve `sessionId`, `rank`, `game`, `id_client`, `photo_row_key`, puis appelle directement `app_session_results_podium_photo_upload(...)`;
  - en succes, il renvoie aussi un `session_meta_get` frais pour que la remote puisse rerendre le podium sans reload.
- `games/web/includes/canvas/remote/remote-ui.js`
  - supprime la logique de redirection vers la fiche detail `pro` en fin de partie;
  - ajoute un upload photo direct depuis chaque ligne du podium termine, via `FormData` + action `session_podium_photo_upload`;
  - affiche maintenant une miniature photo par rang au-dessus du CTA quand `podium_photos` remonte deja un `photo_src`;
  - relit correctement le shape `session.podium_photos` renvoye par `session_meta_get` apres upload, au lieu d'attendre un tableau top-level absent sur cette reponse;
  - reproduit le comportement mobile de la fiche session `pro` en intercalant un mini-choix `Caméra / Photos` sur les CTA `Ajouter une photo` et `Modifier la photo`;
  - ajoute un refresh `session_meta_get` au boot puis un polling `5s` borne a l'etat `Partie terminee`, pour resynchroniser les `podium_photos` meme si la remote a ouvert avant ou sans upload local;
- `games/web/includes/canvas/php/quiz_adapter_glue.php`
- `games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `games/web/includes/canvas/php/bingo_adapter_glue.php`
  - enrichissent maintenant `serverSessionMeta` au boot avec les `podium_photos` deja presentes en base via `app_session_results_get_context(...)`;
  - effet: la remote hydrate tout de suite ses miniatures/CTA sans attendre un upload local ni un `session_meta_get` ulterieur.
- `games/web/includes/canvas/php/boot_lib.php`
  - charge maintenant `global_librairies.php` aussi dans les contextes de boot canvas (`remote_canvas`, `organizer_canvas`, `player_canvas`);
  - sans cela, les nouveaux appels preload a `app_session_get_id` / `app_session_get_detail` / `app_session_results_get_context` dans les `glue` pouvaient rester inactifs hors `games_ajax.php`, car ces helpers n'etaient pas encore charges.
  - rerend le podium remote apres succes avec les `podium_photos` retournes par le bridge;
  - fait evoluer l'UX du podium termine en `3` lignes, avec un CTA clair en bout de ligne:
    - icone appareil photo;
    - libelle `Ajouter une photo` / `Modifier la photo`.
- `games/web/remote_canvas.php`
  - retire l'ancien wiring `sessionDetailUrl` devenu inutile sur la remote.
- `games/web/includes/canvas/css/remote_styles.css`
  - remplace le podium termine en `3` colonnes par une pile de `3` lignes;
  - aligne chaque ligne sur le schema `contenu a gauche / CTA photo a droite`, avec fallback mobile en colonne.

## Games master quit + play quit: redirections contextualisees — 2026-04-16

### Resume
- le `master` renvoyait encore les demos selon une ancienne regle `id_client === 1557`, insuffisante pour les comptes EC standards qui ouvrent une demo depuis la bibliotheque ou une fiche session;
- `play` renvoyait encore vers un catalogue thematique par jeu via `urlPromo`, alors que la cible souhaitee est maintenant la home du site.

### Correctif livre
- `games/web/includes/canvas/core/end_game.js`
  - memorise maintenant une origine de retour de demo par session, via `return_url` explicite si fourni, sinon via un referrer `pro` valide;
  - n'utilise plus `id_client === 1557` pour detecter une demo;
  - si `AppConfig.isDemoSession === true`, la fermeture du `master` renvoie d'abord vers l'origine memorisee, puis vers les fallbacks existants (`targetPage`, `pro`, `www`).
- `games/web/organizer_canvas.php`
  - expose maintenant `AppConfig.isDemoSession` pour rendre cette decision explicite cote front.
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - ajoute `return_url` sur les redirections demo vers `games/master`, y compris pour le flux `temp_lot_demo`;
  - la cible de retour est la vue bibliotheque courante quand elle est connue.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - ajoute `return_url` sur le lien `games` d'une session demo depuis la fiche detail.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - ajoute aussi `return_url` sur le CTA `Ouvrir le jeu` pour les cartes demo.
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - propage un `return_url` issu du referrer `pro` valide sur le chemin de duplication qui ouvre directement `games/master`.
- `pro/web/ec/modules/compte/client/ec_client_script.php`
  - quand une demo est ouverte directement depuis un parcours compte, le retour par defaut vise maintenant `extranet/dashboard`.
- `games/web/modules/app_play_ajax.php`
  - `urlPromo` ne depend plus du jeu et pointe maintenant vers la home `www`.

### Effet attendu
- la remote reste autonome jusqu'au bout pour l'ajout des photos gagnants;
- l'upload met a jour la meme source de verite que `pro`, donc:
  - le podium remote se rafraichit immediatement;
  - le `master games` recupere ensuite la photo via son polling `session_meta_get`;
  - la fiche detail `pro` voit naturellement la nouvelle photo sans flux parallele.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/remote_canvas.php`

## PRO fiche session terminee: lien `games` dans le bloc `Parametres` — 2026-04-16

### Resume
- la fiche detail `pro` affichait deja un lien vers `l'interface de jeu` quand une session etait en cours;
- en revanche, pour une session terminee, le bloc `Parametres` restait limite au titre `Session terminee` sans CTA vers l'interface `games`.

### Correctif livre
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - reutilise le meme `url_session_game_interface` deja calcule pour le cas `session en cours`;
  - ajoute maintenant, pour le cas `session terminee`, le texte:
    - `Voir les resultats de cette session sur l'interface de jeu.`
  - le lien pointe donc vers la meme interface `games master/launcher` que celle deja exposee pour les sessions en cours, sans modifier les autres gardes.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## Games remote papier: garde `maxPlayers` avant `player_register` — 2026-04-16

### Resume
- sur la remote papier, un message de session pleine pouvait déjà remonter côté métier, mais l'UI fermait quand même la modale d'ajout avant la réponse async de `player_register`;
- effet visible: l'animateur voyait la modale se fermer puis seulement un toast d'erreur, ce qui donnait l'impression que la remote "plantait" après l'alerte.

### Correctif livre
- `games/web/includes/canvas/remote/remote-ui.js`
  - ajoute un helper local de capacité basé sur:
    - `SESSION_PAPER`;
    - `window.ServerSessionMeta.maxPlayers`;
    - le snapshot remote courant `playersLast` / `playersTotalLast`;
  - exécute ce contrôle directement dans `promptParticipantSelection().preConfirm`, afin de garder la modale SweetAlert ouverte avec un message de validation si la session papier est déjà pleine;
  - conserve une seconde garde juste avant l'appel `remoteApi('player_register', ...)` pour couvrir une course entre deux ajouts successifs;
  - ne bloque pas artificiellement un participant déjà actif dans la session quand il est re-sélectionné depuis la remote.

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/remote/remote-ui.js`

## PRO fiche session démo: le polling suit maintenant l'etat runtime reel — 2026-04-16

### Resume
- la fiche detail `pro` pollait deja l'etat de session, mais les demos court-circuitaient encore le calcul partage de statut;
- effet visible: une demo restait artificiellement editable cote `pro`, meme quand la session etait reellement en cours, et sa fiche ne revenait pas proprement a `En attente` apres une relance basee sur le runtime.

### Correctif livre
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - retire le retour anticipe sur `flag_session_demo = 1` dans `app_session_edit_state_get(...)`;
  - les demos reutilisent donc maintenant le meme calcul runtime que les sessions standard selon le type de jeu.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - retire l'exclusion locale qui ignorait encore `is_locked` sur les demos dans la fiche detail;
  - la vue `pro` suit donc a nouveau `is_pending` / `is_locked` / `is_terminated` pour une demo comme pour une session standard.
- invariant conserve:
  - aucun changement cote `games` sur le bypass demo;
  - la possibilite de relancer une session demo depuis `games` reste intacte;
  - si cette relance remet le runtime a l'etat initial, la fiche detail `pro` repasse naturellement en `En attente`.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`

## PRO `Mon agenda`: acces au QR code permanent dans le header — 2026-04-16

### Resume
- le QR code permanent du lieu etait deja accessible depuis `Ma communauté`;
- besoin retenu: proposer le meme acces aussi depuis `Mon agenda`, plus pres de l'usage quotidien de programmation.

### Correctif livre
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
  - ajoute un trigger `QR code permanent` + icone QR a droite du titre `Mon agenda`;
  - rebranche ce trigger sur une modale locale reprenant le meme flux que `Ma communauté`:
    - meme message;
    - meme apercu PNG;
    - meme CTA `Enregistrer`;
  - limite l'exposition au vrai agenda du lieu:
    - pas sur `Archives`;
    - pas sur `Agenda du réseau`.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`

## EP `Classements`: shell immediat puis hydratation AJAX — 2026-04-16

### Resume
- la page `Classements` de l'espace joueur chargeait encore son contexte complet dans `ep.php`, donc avant le rendu du shell;
- avec les enrichissements recents des leaderboards, ce bootstrap pouvait devenir sensiblement plus lent a froid.

### Correctif livre
- `play/web/ep/ep.php`
  - ne charge plus `app_joueur_leaderboards_get_context(...)` dans le bootstrap de la route `leaderboards`.
- `play/web/ep/modules/communication/home/ep_home_leaderboards.php`
  - rend maintenant un shell immediat avec un placeholder de chargement;
  - hydrate ensuite le contenu par fetch AJAX;
  - rebinde localement les toggles `Afficher/Replier le classement` apres injection.
- `play/web/ep/modules/communication/home/ep_home_leaderboards_shared.php`
  - nouveau fichier partageant les helpers et le rendu HTML leaderboard.
- `play/web/ep/modules/communication/home/ep_home_leaderboards_ajax.php`
  - nouvel endpoint JSON qui calcule le contexte joueur puis renvoie le fragment HTML complet.

### Verification
- `php -l /home/romain/Cotton/play/web/ep/ep.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_leaderboards.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_leaderboards_shared.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_leaderboards_ajax.php`

## FO fiche `place`: badges couleurs sur les titres de jeux des classements — 2026-04-16

### Resume
- l'onglet `Classements` de la fiche `place` gardait encore des titres de jeux en texte simple;
- le besoin est maintenant de les faire ressortir comme dans `Ma communauté` côté `pro` et `Classements` côté `play`.

### Correctif livre
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - ajoute des helpers locaux de badge par jeu;
  - remplace le simple titre texte de chaque bloc leaderboard par un badge colore;
  - conserve l'indication de saison a cote, en texte secondaire.

### Verification
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## QR code place: initialisation temp sans `chmod()` — 2026-04-16

### Resume
- le generateur partage de QR code `place` utilisait encore un `chmod()` de confort sur son dossier temporaire;
- sur certains serveurs `dev`, cette operation est interdite et le warning PHP pouvait remonter jusque dans un parcours `www -> fiche session -> Je participe`.

### Correctif livre
- `global/web/app/modules/qr_code/app_qr_code_place_generator.php`
  - ne tente plus de modifier les permissions du sous-dossier temp;
  - essaye d'utiliser `sys_get_temp_dir()/tmp_qr_codes` si ce dossier est exploitable;
  - retombe sinon directement sur `sys_get_temp_dir()`.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/qr_code/app_qr_code_place_generator.php`

## FO fiche `place`: retour du CTA agenda `Je participe` sur entrée QR — 2026-04-16

### Resume
- historiquement, une entrée via `QR code place` exposait sur les cartes agenda un accès direct aux interfaces joueurs des sessions;
- la refonte récente de la fiche `place` avait déplacé le rendu agenda vers un flux AJAX qui ne transportait plus le contexte `code_client`, donc ce CTA avait disparu.

### Correctif livre
- `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - propage maintenant `code_client` dans l'URL AJAX quand la fiche est ouverte depuis `/place/{code_client}`.
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - relit ce contexte et l'expose au rendu de l'onglet `Agenda`.
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - ajoute un helper local de résolution du lien joueur à partir de `app_session_games_play_get_link(...)`;
  - réaffiche le CTA `J'accède au jeu` sur les cartes de sessions à venir uniquement quand la fiche `place` est ouverte via QR code;
  - masque dans ce contexte QR le CTA standard vers la fiche détail publique de session, pour ne garder qu'un seul chemin direct vers le jeu.

### Verification
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`

## PRO `Ma fiche lieu`: synthèse + classements `Mes joueurs` déplacés et hydratés en AJAX — 2026-04-15

### Resume
- `Ma fiche lieu` doit maintenant devenir le point d’entrée unique pressenti pour les infos lieu + joueurs;
- besoin retenu:
  - garder un premier bloc lieu affiché immédiatement;
  - charger ensuite en différé la synthèse et les classements `Mes joueurs`;
  - ouvrir la page à tous les comptes non siège réseau.

### Correctif livre
- `pro/web/ec/modules/compte/client/ec_client_view.php`
  - ajoute une hydratation AJAX secondaire avec le même loader que `Mes joueurs`;
  - rend 3 cartes de synthèse (`Mes stats`, `Participants`, `Mes tops`) avant les classements;
  - recharge uniquement le fragment `leaderboards` au changement de saison;
  - retire l’ancien widget immédiat `ec_widget_client_lieu_stats.php` pour éviter le doublon;
  - supprime aussi la marge cumulée qui créait un double espacement entre le bloc principal et la zone hydratée;
  - renomme `Participants` en `Mes Participants`;
  - supprime le widget QR code de bas de page et intègre à la place un raccourci QR cliquable dans la colonne de droite du bloc principal des infos générales, avec icône recentrée et agrandie;
  - ce raccourci affiche maintenant le libellé compact `QR code permanent à imprimer.`, sans style atténué;
  - au clic, il ouvre une modale simple avec un texte d’usage centré sur les prochaines sessions, un aperçu image du QR et un CTA `Enregistrer` pointant directement vers le PNG;
  - le PNG du QR est maintenant généré en définition plus élevée pour une meilleure qualité d’impression.
  - la colonne QR du bloc principal est maintenant centrée verticalement dans la row;
  - l’image PNG enregistrable est désormais une composition prête à imprimer: nom du compte, `Agenda des jeux Cotton`, QR avec logo Cotton centré et lien public.
  - le logo central du QR est maintenant embarqué comme asset mutualisé dans `global/web/assets/branding/qr/cotton-logo-qr.png`, ce qui supprime la dépendance implicite au repo `games`.
  - la modale QR utilise maintenant une largeur `modal-lg` et un aperçu agrandi;
  - l’URL du QR suit désormais `www_url` de l’environnement courant tout en gardant le format historique `/place/{code_client}`.
  - le trigger QR du bloc principal aligne maintenant texte et icône sur le même axe;
  - l’image PNG générée a aussi été resserrée verticalement pour réduire les blancs visibles dans l’aperçu.
  - l’image générée reste maintenant sur fond transparent avec un léger contour arrondi;
  - le bloc QR lui-même est aussi rogné avec des coins arrondis.
  - la composition complète est maintenant recentrée verticalement dans le canvas du PNG.
  - le bloc principal des infos générales n’est désormais rendu que pour les comptes relevant de l’ancienne règle `Ma fiche lieu`;
  - quand cette règle garde le menu visible mais qu’aucune synthèse `Mes joueurs` n’est disponible, la page affiche un message dédié `Aucune info de communauté disponible pour le moment. Joue tes premières sessions pour découvrir tes stats organisateur.`
- `pro/web/ec/modules/compte/client/ec_client_qr_code_place.php`
  - la route historique continue de servir le PDF par défaut;
  - elle accepte désormais aussi `?format=png` pour sortir directement l’image PNG du QR code via le même générateur centralisé.
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_shared.php`
  - nouveau socle partagé pour le rendu des podiums, helper URLs/archive, sélecteur de saison et `Classements par jeu`;
  - le sélecteur `Saison` est maintenant intégré à l’en-tête du bloc classements, au lieu d’être rendu dans une card séparée;
  - `joueurs-dashboard-leaderboards-section` est maintenant la card externe unique, et les wrappers visuels internes par jeu ont finalement été retirés pour ne garder qu’un espacement vertical simple entre blocs;
  - les titres `Top 10 / Classement complet` des tableaux de classement utilisent maintenant la même couleur d’accent `#582AFF` que le lien toggle;
  - utilisé à la fois par `Mes joueurs` et `Ma fiche lieu`.
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - ne porte plus en local le rendu leaderboard partagé;
  - continue d’utiliser le même moteur, désormais via l’include mutualisé.
- `pro/web/ec/ec.php`
  - le lien `Ma communauté` ne suit plus une simple ouverture globale:
    - il reprend la garde `Mes joueurs` quand une vraie synthèse existe;
    - il reste aussi visible pour les comptes relevant de l’ancienne règle `Ma fiche lieu`, même sans données;
  - le lien est repositionné juste sous `Mon agenda`, ou sous `Les jeux` si l’agenda n’est pas affiché.
  - le lien de navigation `Mes joueurs` a été retiré du shell.
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - la page historique `Mes joueurs` n’est plus exposée;
  - l’URL redirige maintenant vers `Ma communauté`;
  - le fichier est conservé car il porte encore des styles/contrats de fallback utiles tant que le refactoring n’est pas entièrement purgé.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_shared.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_qr_code_place.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec.php`
- `npm run docs:sitemap`

## FO fiche `place`: perf lot 1 sur `Classements` / `Sessions passées` — 2026-04-15

### Resume
- le chargement AJAX `overview` calculait encore l'agenda complet et les `sessions passées` complètes avant de répondre avec les seuls leaderboards;
- le helper global archive rechargeait aussi les sessions a venir même quand seul l'historique etait utile.

### Correctif livre
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - la route `overview` ne charge plus les listes completes `agenda` / `archive`;
  - les flags `has_agenda` / `has_archive` passent par des helpers bornes a 1 resultat.
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `fo_clients_view_upcoming_sessions_get(...)` accepte une limite;
  - ajout de `fo_clients_view_has_upcoming_sessions(...)` et `fo_clients_view_has_archive_sessions(...)`;
  - `fo_clients_view_archive_sessions_get(...)` appelle maintenant l'archive globale en mode `historique seul`.
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `app_client_joueurs_dashboard_archive_sessions_get(...)` accepte un drapeau `include_upcoming_sessions`;
  - les chemins FO qui ne veulent que l'historique evitent donc de recharger les sessions a venir.

### Verification
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## FO fiche `place`: entrée QR code recentrée sur `Agenda` — 2026-04-15

### Resume
- la refonte récente des onglets `place` a laissé `Classements` comme vue active par défaut;
- pour une entrée via `QR code` (`/place/{code_client}`), l'onglet prioritaire attendu reste `Agenda`.

### Correctif livre
- `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - détecte maintenant explicitement l'entrée `QR code` via `code_client`;
  - force alors l'onglet actif initial sur `Agenda` si aucun `tab` n'est demandé;
  - laisse inchangé le défaut public standard de `/fr/place/{seo_slug}`, qui reste sur `Classements`.
  - le démarrage JS charge maintenant l'onglet actif initial à partir de l'état calculé côté serveur, ce qui corrige le cas QR où les boutons d'onglets sont absents du DOM.
- `www/web/fo/modules/entites/clients/fr/fo_clients_seo.php`
  - marque maintenant l'entrée QR `place/{code_client}` comme un contexte sans hero visuel.
- `www/web/fo/fo.php`
  - neutralise le preload image global quand ce contexte QR le demande, afin d'éviter le warning navigateur sur une image hero non utilisée.

### Verification
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_seo.php`
- `php -l /home/romain/Cotton/www/web/fo/fo.php`

## FO fiche `place`: retrait de la colonne `sessions récentes` — 2026-04-15

### Resume
- finalement, l'onglet `Classements` ne doit plus afficher la colonne desktop `sessions récentes`;
- l'objectif est double:
  - laisser le tableau de classement utiliser toute la largeur disponible;
  - supprimer aussi le coût de calcul des cartes sessions associées.

### Correctif livre
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - neutralisation du calcul `fo_clients_view_recent_ranked_sessions_get(...)` dans le contexte leaderboard;
  - la table passe en colonne pleine largeur (`col-12`);
  - l'ancien bloc HTML de droite est conservé en commentaire pour réutilisation éventuelle.
- `www/web/fo/includes/css/fo_custom.css`
  - les styles de l'ancienne colonne `sessions récentes` sont conservés en commentaire;
  - le wrapper responsive du tableau mobile reste actif tel quel.

### Verification
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## FO fiche `place`: archive enrichie avec photo #1 et pagination — 2026-04-15

### Resume
- l'onglet `Sessions passées` doit maintenant:
  - illustrer les cartes avec la photo du rang 1 si elle existe;
  - proposer un bouton `Afficher plus` ajoutant 12 cartes archive à chaque clic.

### Correctif livre
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `fo_clients_view_archive_session_card_html_get(...)` relit `app_session_results_get_context(...)` et privilégie la photo du rang 1 quand elle est exploitable;
  - ajout d'un bundle archive paginé (`fo_clients_view_archive_bundle_get(...)`) avec rendu des cartes seules et du bouton `Afficher plus`.
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - la route `section=archive` accepte `archive_offset` et renvoie le HTML initial, les cartes additionnelles et l'état du bouton.
- `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - le JS archive gère maintenant l'ajout incrémental des cartes sans recharger tout l'onglet.
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - le helper archive partagé accepte aussi un `offset` pour supporter cette pagination.

### Verification
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

### Addendum
- l'illustration photo du rang 1 conserve maintenant le même pattern d'URL que les photos podium / résultats déjà affichées ailleurs en FO, au lieu d'ajouter un suffixe de version systématique;
- le bouton `Afficher plus` reprend désormais la classe repo `btn btn-color-20 m-2` avec flèche à droite.
- correctif complémentaire: la photo du rang 1 sur les cartes archive AJAX est désormais rendue en `src` direct stabilisé avec fallback `onerror`, au lieu de dépendre du lazy-loader du bloc injecté.

## PRO `Mes joueurs`: lien archive déplacé sur `x sessions` — 2026-04-15

### Resume
- dans les tableaux de classement `Mes joueurs`, le lien archive ne doit plus apparaitre sous forme de libelle `(Détail)`;
- le clic doit porter directement sur `x sessions` dans la phrase de contexte du classement.

### Correctif livre
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - `ec_joueurs_leaderboard_scope_notice_with_link(...)` construit maintenant:
    - `Classement calculé sur <a ...>x sessions</a> jouées depuis le début de la saison`
  - aucune modification des paramètres d'URL archive ou des bornes de période.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`

## PRO `Mes joueurs`: filtre saison unique — 2026-04-15

### Resume
- la sélection de période des classements `Mes joueurs` ne doit plus exposer deux selects `Année` puis `Saison`;
- l'UI attendue est un unique select `Saison` avec libellé agrégé `Saison + année`, comme sur le site public;
- les saisons sans données ne doivent pas être proposées.

### Correctif livre
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - ajout d'un helper local qui aplatit `quarter_options_by_year` en une liste triée `Saison + année`;
  - remplacement du duo de champs visibles par:
    - un select visible `Saison`;
    - deux inputs cachés `filter_year` / `filter_quarter` pour préserver le contrat backend existant;
  - simplification du JS de rechargement AJAX: il lit maintenant l'option sélectionnée, synchronise les champs cachés, puis recharge le fragment leaderboard.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`

## GLOBAL `Mes joueurs`: contrat session dashboard durci sur `flag_session_demo` — 2026-04-15

### Resume
- l'audit logs sur `GET /extranet/players?async=1` montrait des notices repetitives `Undefined index: flag_session_demo` dans `app_session_edit_state_get(...)`;
- cause confirmee: le moteur dashboard `Mes joueurs` fournissait a ce helper des lignes `championnats_sessions` partielles ne chargeant pas ce champ, alors que le helper le lisait sans garde.

### Correctif livre
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - ajout de `flag_session_demo` dans les deux requetes source utilisees par le dashboard (`app_client_joueurs_dashboard_period_has_leaderboard_data()` et `app_client_joueurs_dashboard_context_compute()`).
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - durcissement de `app_session_edit_state_get(...)` avec fallback `0` si `flag_session_demo` manque dans un detail de session partiel.
- Documentation mise a jour:
  - `documentation/canon/repos/global/TASKS.md`
  - `documentation/canon/repos/global/README.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## GLOBAL `Mes joueurs`: garde Bingo sur playlist client absente — 2026-04-15

### Resume
- apres le premier durcissement, les logs montraient encore des `500` intermittents sur `GET /extranet/players?async=1`;
- cause racine confirmee: certaines sessions `Bingo Musical` appellent `app_jeu_get_detail(type 3/6, id_produit)` avec un `id_produit` dont la playlist client n'est plus resoluble;
- le chemin Bingo dereferencait cette playlist puis son catalogue sans garde, jusqu'au fatal `Call to a member function fetch_assoc() on bool` remonte depuis `module_get_detail()`.

### Correctif livre
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - le chemin `type 3/6` de `app_jeu_get_detail()` verifie maintenant qu'une playlist client existe avant de dereferencer ses champs;
  - la relecture du catalogue playlist et du format Bingo est aussi defensive, avec fallbacks neutres si la donnee manque.
- Documentation mise a jour:
  - `documentation/canon/repos/global/TASKS.md`
  - `documentation/canon/repos/global/README.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PRO `Mes joueurs`: ordre des blocs classement aligne sur `www` / `play` — 2026-04-15

### Resume
- la page `Mes joueurs` rendait ses blocs jeu dans l'ordre technique du contexte leaderboard;
- besoin retenu: harmoniser l'ordre de lecture avec les autres fronts Cotton en priorisant `Blind Test`, puis `Bingo Musical`, puis `Cotton Quiz`.

### Correctif livre
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - ajout d'un helper local qui reordonne les leaderboards avant rendu selon `blindtest`, `bingo`, `quiz`;
  - les jeux non presents restent simplement ignores et les autres blocs gardent leur logique de masquage actuelle.
- Documentation mise a jour:
  - `documentation/canon/repos/pro/TASKS.md`
  - `documentation/canon/repos/pro/README.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`

## WWW fiche `place`: spinner ajoute aussi sur l'onglet `Agenda` — 2026-04-15

### Resume
- la fiche `place` affichait deja un spinner sur `Classements` et `Sessions passées`, mais pas sur `Agenda`;
- besoin retenu: harmoniser le feedback visuel des trois onglets dynamiques.

### Correctif livre
- `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - le placeholder initial `Agenda` affiche maintenant le meme spinner inline Bootstrap que les autres onglets;
  - le chargement AJAX de `section=agenda` reutilise aussi ce meme loader.
- Documentation mise a jour:
  - `documentation/canon/repos/www/TASKS.md`
  - `documentation/canon/repos/www/README.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PRO `Mes joueurs`: recroisement photo podium saison sur participants renommes — 2026-04-15

### Resume
- le podium agrégé de saison remontait bien le top 3 et le libellé courant du participant, mais pouvait encore perdre la photo si le pseudo/nom affiché sur une ancienne session archivée différait du nom actuel;
- le premier correctif couvrait une partie des aliases, mais certains chemins legacy/runtime continuaient de court-circuiter l'enregistrement `ancien label session -> identity`.

### Correctif livre
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - les branches runtime `quiz`, `blindtest` et `bingo` enregistrent maintenant aussi l'alias brut `username` avant les `continue` liés aux bridges `games_connectees`;
  - le fallback `quiz legacy results` enregistre aussi explicitement l'alias sessionnel équipe avant l'attribution des points;
  - le helper `app_client_joueurs_dashboard_leaderboard_podium_rows_get(...)` purge désormais correctement les lignes déjà résolues par identité, pour ne pas laisser un état partiel pendant le scan des sessions archivées.
- Documentation mise a jour:
  - `documentation/canon/repos/global/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
- `npm run docs:sitemap`

## Photos podium `pro` / `play`: fallback URL `prod` en `dev` — 2026-04-15

### Resume
- en environnement `dev`, les fiches detail `pro` / `play` pouvaient encore construire une URL `www dev` pour une photo podium absente localement;
- pour les assets publies seulement en `prod`, cela empechait de verifier facilement l'affichage en dev.

### Correctif livre
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dans `app_session_results_podium_photo_src_from_media(...)`, quand une photo podium publique `www` est demandee depuis `dev` mais n'existe pas localement, le fallback choisit maintenant d'abord `www_url['prod']`;
  - si cette racine n'est pas configuree, le helper garde ses replis existants.
- Documentation mise a jour:
  - `documentation/canon/repos/global/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `npm run docs:sitemap`

## PRO `Mes joueurs`: mention sous le podium agrégé avec lien vers `place` — 2026-04-15

### Resume
- les podiums agrégés de `Mes joueurs` affichaient bien les visuels et scores, mais sans rappel explicite invitant à ajouter les photos podium ni passerelle directe vers la page publique `place`;
- la formulation attendue devait en plus varier selon qu'au moins une photo de podium est déjà présente ou non.

### Correctif livre
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - ajout d'un helper local qui construit l'URL publique `www/fr/place/{seo_slug_client}` pour le compte connecté;
  - ajout d'un helper qui détecte si le podium agrégé courant contient déjà au moins une photo;
  - ajout sous chaque podium agrégé d'une mention en italique précédée d'une icône `info`:
    - sans photo: `Ajoute les photos des gagnants ... sur ta page du site Cotton !`
    - avec photo: `Voir ma page sur le site Cotton`
  - le lien pointe dans les deux cas vers la fiche `place`.
  - l'icône `info` est finalement rendue en SVG inline pour éviter les cas où la balise `<i class="bi ...">` ne s'affichait pas sur la vue `pro`.
  - le conteneur de mention centre maintenant réellement l'icône et le texte par sous-blocs flex, ce qui corrige le texte encore visuellement calé en haut lors des retours à la ligne.
  - le rendu a ensuite ete volontairement simplifie: une seule `div` `inline-flex`, icone SVG + texte inline, centree sans offsets ni wrappers de compensation.
- Documentation mise a jour:
  - `documentation/canon/repos/pro/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- `npm run docs:sitemap`

## EP + FO detail session: etat `terminee` aligne sur `pro` — 2026-04-15

### Resume
- une session terminee basculait bien en archive dans l'espace `pro`, mais les fiches detail `play` et `www/fo` continuaient de se baser sur la seule date via `app_session_get_chronology(...)`;
- consequence: une session cloturee le jour meme pouvait apparaitre dans l'historique/liste des sessions passees, tout en restant affichee comme session non terminee sur sa fiche detail, sans podium ni classement.

### Correctif livre
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - remplace la chronologie brute par `app_session_display_chronology_get(...)`;
  - injecte `app_session_edit_state_get(...)` avec le detail jeu, comme cote `pro`.
- `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - aligne la fiche detail FO sur la meme logique `display_chronology + session_edit_state`;
  - la vue publique considere donc desormais une session cloturee comme `after` meme si sa date est encore `aujourd'hui`.
- Documentation mise a jour:
  - `documentation/canon/repos/play/TASKS.md`
  - `documentation/canon/repos/www/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
- `npm run docs:sitemap`

## EP fiche detail session: photos podium resolues sur le stockage public `www` — 2026-04-15

### Resume
- la fiche detail `play` pouvait perdre les photos de podium alors qu'elles existaient bien cote `pro`;
- cause racine: le helper global de resolution d'URL photo reutilisait `upload_path` / `upload_root` du front appelant;
- ce contrat tient cote `pro`, mais pas cote `play`, dont la configuration ne resolve pas nativement les medias publics podium sur la racine `www`.

### Correctif livre
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `app_session_results_podium_photo_src_from_media(...)` derive maintenant explicitement les photos podium publiques depuis `www_root` / `www_url` quand le media appartient a un stockage public `www` / `cotton-quiz` / `cotton_quiz`;
  - la verification `file_exists(...)`, l'URL retournee et le log fallback utilisent donc la bonne racine publique meme quand l'appel vient de `play`;
  - en environnement `dev`, le fallback respecte maintenant d'abord `www_url['dev']`, avec repli `prod` seulement si aucune racine publique n'est definie pour l'environnement courant.
- Documentation mise a jour:
  - `documentation/canon/repos/global/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `npm run docs:sitemap`

## FO fiche `place`: spinner sur le chargement des sessions passées — 2026-04-15

### Resume
- la fiche `place` affichait deja un spinner sur `Classements`, mais pas sur `Sessions passées`;
- le chargement AJAX des archives restait seulement textuel, ce qui creait un petit ecart de feedback visuel entre onglets dynamiques.

### Correctif livre
- `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - le loader `archive` reutilise maintenant le meme markup spinner que `leaderboards`;
  - le message reste `Chargement des sessions passées en cours...`.

### Verification
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
- `npm run docs:sitemap`

## PRO `Mes joueurs`: podium de saison au-dessus des classements agrégés — 2026-04-15

### Resume
- la page `Mes joueurs` affichait seulement les tableaux `Top 10` / `Classement complet` par jeu;
- besoin retenu: afficher au-dessus un vrai podium de saison, visuellement aligné sur la fiche detail de session terminée, puis reutilisable ensuite dans `play` et `www`.

### Correctif livre
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - le contexte leaderboard expose maintenant aussi `players_podium` / `teams_podium`;
  - ces lignes podium reprennent le top 3 agrégé de la saison et tentent de relire, pour chaque participant ou equipe, la derniere photo de podium disponible en scannant les sessions classées de la période;
  - le rapprochement photo priorise maintenant l'identite sessionnelle plutot que le seul libelle courant, ce qui couvre le cas d'un pseudo/nom modifié en cours de saison;
  - les branches runtime `quiz`, `blindtest`, `bingo` ainsi que la source `quiz teams` enregistrent maintenant aussi leurs alias de libelles de session, pour que les anciennes photos podium puissent etre recroisees meme si seul le label runtime historique les portait;
  - si aucune photo n'est retrouvee, la carte reste rendue sans image, comme sur la fiche archivee `pro`.
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - chaque bloc jeu affiche maintenant ce podium juste au-dessus du titre `Top 10` / `Classement complet`;
  - le markup reprend le style des cartes podium de la fiche session terminee;
  - aucun upload photo n'est expose sur `Mes joueurs`.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- `npm run docs:sitemap`

## EP sessions: contexte `Historique` conserve sur fiche detail — 2026-04-14

### Resume
- depuis `/extranet/dashboard/history`, l'ouverture d'une session terminee reutilisait la fiche detail EP des sessions mais retombait visuellement dans le contexte `Agenda`;
- besoin retenu:
  - garder `Historique` actif dans la navigation;
  - adapter le lien de retour;
  - afficher aussi les compteurs de participants sur cartes archivees et les compteurs de participations probables sur cartes agenda/detail.

### Correctif livre
- `play/web/ep/ep.php`
  - ajoute un vrai contexte `back_to=history`;
  - garde `Historique` surligne dans le menu lateral quand la fiche detail est ouverte depuis l'historique;
  - adapte le lien header en `← Retour à l'historique`;
  - preserve aussi `history_months` sur le retour si la fenetre historique a ete etendue.
- `play/web/ep/modules/communication/home/ep_home_history.php`
  - injecte `back_to=history&back_history_months=...` sur les liens de fiches detail;
  - affiche maintenant un chip participants (`people-fill`) avant les badges de resultat, avec le meme total que la fiche detail resultats quand il existe.
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - affiche maintenant le compteur de participations probables dans la meme zone de badges que l'historique sur les cartes agenda / home, en reutilisant le meme chip avec l'icone `people-fill`.
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - ajoute sous la thematique des sessions a venir le rappel `Participants annoncés : X`.
- `play/web/ep/includes/css/ep_custom.css`
  - ajoute les styles du chip participants archive et de l'indicateur agenda.
  - ajuste aussi l'espacement haut de l'indicateur agenda et le centrage vertical du chip participants archive.
- Documentation mise à jour:
  - `documentation/canon/repos/play/README.md`
  - `documentation/canon/repos/play/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/play/web/ep/ep.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_history.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

## FO fiche `place`: `Top 10` public uniquement — 2026-04-14

### Resume
- la fiche publique `place` rendait directement le classement complet pour chaque jeu disponible;
- besoin retenu: borner durablement la lecture publique au `Top 10`, sans exposer de classement complet côté `www/fo`.

### Correctif livre
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - fixe le sous-titre à `Top 10`;
  - rend uniquement les 10 premières lignes de chaque classement public;
  - priorise désormais l'affichage des blocs dans l'ordre `Blind Test`, `Bingo Musical`, `Cotton Quiz`.
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - ne gère plus aucun paramètre d'expansion de classement complet.
- `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - recharge seulement les `Top 10` au changement de saison, sans logique de toggle;
  - masque aussi toute la section onglets si `Classements`, `Agenda` et `Sessions passées` sont simultanément vides.
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - remonte maintenant aussi les indicateurs `has_agenda` / `has_archive` dans `overview`, afin que le front puisse décider de masquer la section vide ou de basculer vers le bon onglet restant.
- Documentation mise à jour:
  - `documentation/canon/repos/www/README.md`
  - `documentation/canon/repos/www/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## BO réseau: suppression d'affiliation depuis le pilotage TdR — 2026-04-14

### Resume
- le BO `reseau_contrats` savait déjà activer, désactiver et reclasser les affiliés d'une TdR, mais pas casser proprement l'affiliation quand un compte sort du réseau;
- besoin retenu: permettre au BO de remettre un affilié hors réseau, sans ouvrir cette action côté PRO, afin de pouvoir ensuite le réintégrer proprement dans les flux standards comme `Remises 2026`.

### Correctif livre
- `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - ajoute un CTA `Supprimer l'affiliation` dans la colonne `Action` du tableau `Affiliés du siège`;
  - ce CTA reste réservé au BO.
- `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - ajoute le mode `supprimer_affiliation`;
  - vérifie que l'affilié ciblé est bien rattaché au siège réseau courant;
  - appelle ensuite `client_affilier(0, $id_client_affilie, 1)` pour retirer le rattachement réseau et relancer la reclassification métier associée.
- Documentation mise à jour:
  - `documentation/canon/repos/www/README.md`
  - `documentation/canon/repos/www/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`

## FO fiche `place`: onglet `Classements` multi-jeux — 2026-04-14

### Resume
- la fiche publique `place` chargeait déjà le contexte global `Mes joueurs`, mais l'onglet restait sur un ancien rendu `Classement Quiz` local, figé sur plusieurs saisons;
- besoin retenu: réaligner cet onglet sur la saison courante réelle et sur les règles multi-jeux déjà en place côté `pro/play`, tout en gardant le style de tableau historique et une colonne droite courte avec quelques dernières sessions illustrées.

### Correctif livre
- `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - remplace l'onglet `Classement Quiz` par `Classements`;
  - exploite maintenant les leaderboards saison courante issus de `app_client_joueurs_dashboard_get_context(...)`;
  - rend un bloc distinct par jeu exploitable (`Cotton Quiz`, `Blind Test`, `Bingo Musical`) avec le style de tableau quiz historique;
  - simplifie l'affichage de période au format `Jeu · Avril-Juin 2026`;
  - rend les blocs sessions de droite cliquables vers la fiche détail publique;
  - remplace le plafond fixe du nombre de sessions de droite par une estimation basée sur la hauteur théorique du classement, avec photo gagnant ou fallback visuel play-like si besoin.
- Documentation mise à jour:
  - `documentation/canon/repos/www/README.md`
  - `documentation/canon/repos/www/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## BO `Remises 2026`: ajout en masse figé sur remise manuelle — 2026-04-14

### Resume
- la fiche détail d'une remise `2026` en mode manuel permettait seulement l'ajout compte par compte;
- besoin retenu: réutiliser les mêmes critères métier que le mode auto (`typologie` / `pipeline`) pour figer en une seule action la liste des comptes actuels, sans rendre la remise dynamique pour les futurs comptes.

### Correctif livre
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - ajoute les helpers de normalisation de filtres bulk, de sélection des candidats non encore liés, puis d'insertion en masse dans `ecommerce_remises_to_clients`.
  - relit maintenant tous les emails des contacts liés à chaque compte, puis prépare les lignes d'affichage `1 email = 1 ligne`.
  - l'ajout manuel unitaire ou en masse n'est plus bloqué par `online=0` ni par une fenêtre de commande future, pour permettre de préparer le ciblage avant activation.
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
  - ajoute le mode `target_add_bulk` et réinjecte les filtres choisis dans la redirection BO.
  - ajoute maintenant aussi le mode `target_clear` pour purger toute la liste manuelle d'une remise.
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
  - ajoute le bloc `Ajouter en masse (sélection figée)` sur les remises manuelles;
  - ce bloc reprend les axes `Typologie` et `Pipeline`, affiche le volume actuellement éligible, puis laisse le retrait unitaire inchangé après ajout.
  - les listes de comptes concernés passent maintenant sur une colonne `Email` dédiée;
  - si un compte porte plusieurs emails, la fiche crée plusieurs lignes secondaires `compte + email`, en laissant le CTA `Retirer` uniquement sur la première ligne.
  - le tableau des comptes manuels expose aussi `Vider tout` dans sa cellule d'entête à droite.
- `www/web/bo/www/modules/entites/clients/bo_module_aside.php`
  - le CTA d'ajout manuel d'une remise depuis la fiche client est renommé `Appliquer` et passe en `btn-info`.
  - le CTA `Retirer` des remises manuelles déjà liées passe lui aussi en bouton rouge plein lisible.
- ajustement UI complémentaire:
  - le CTA `Retirer` de la fiche détail `Remises 2026` passe lui aussi en bouton rouge plein pour rester lisible sur fond clair.
- Documentation mise à jour:
  - `documentation/canon/repos/www/README.md`
  - `documentation/canon/repos/www/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`

## EC Stripe webhook: garde-fou anti-facturation croisee — 2026-04-13

### Resume
- le webhook `invoice.paid` pouvait creer une commande de cycle ou de prorata en se fiant aux seules metadonnees Stripe `offre_client_id`, meme si la subscription Stripe de l'evenement ne correspondait pas a l'offre locale ciblee;
- incident observe en `dev`: une subscription Stripe `test` orpheline pouvait encore facturer une offre locale reliee a un autre `asset_stripe_productId`, avec risque de facturation croisee entre clients si les metadonnees Stripe etaient incoherentes.

### Correctif livre
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - ajoute `app_ecommerce_offre_client_stripe_subscription_guard(...)` pour verifier l'existence de l'offre locale et, si demande, la coherence stricte entre `asset_stripe_productId` et la subscription Stripe de l'evenement.
- `pro/web/ec/ec_webhook_stripe_handler.php`
  - applique ce garde-fou sur `invoice.paid` pour `subscription_cycle` et `subscription_update`;
  - conserve `subscription_create` permissif afin de ne pas casser le rattachement initial de la souscription au premier paiement;
  - journalise l'anomalie et ignore la facture locale au lieu de creer une commande incoherente.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php`

## FO agenda public: filtres alignés sur `play` — 2026-04-13

### Resume
- l'agenda public `www` restait sur un filtre unique `Département`, alors que la cible produit issue de `play` reposait déjà sur 3 filtres alignés avec un défaut `Tous`;
- besoin retenu: réaligner `/fr/agenda` sur la lecture `Département / pays` + `Organisateur` + `Jeu`, sans casser les routes SEO historiques existantes.

### Correctif livre
- `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list.php`
  - remplace le filtre département legacy par un formulaire GET à 3 filtres alignés;
  - conserve l'hydratation depuis les routes historiques `agenda/jeu/...`, `agenda/departement/...`, `agenda/ville/...`;
  - borne les options aux zones et organisateurs réellement représentés dans les sessions à venir;
  - regroupe les variantes techniques jeu sous `Cotton Quiz`, `Blind Test`, `Bingo Musical`;
  - n'impose plus `c.online=1` en `dev`, pour garder une recette agenda cohérente.
- Documentation mise à jour:
  - `documentation/canon/repos/www/README.md`
  - `documentation/canon/repos/www/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`

## Podium `Quiz V1`: priorité des photos historiques — 2026-04-13

### Resume
- les fiches résultats publiques pouvaient perdre l'affichage correct des anciennes photos podium `Quiz V1` après l'introduction des stockages modernes par rang / ligne;
- besoin retenu: préserver en priorité le comportement historique sur les sessions legacy déjà illustrées.

### Correctif livre
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - pour `quiz_legacy`, `app_session_results_podium_photo_get(...)` relit d'abord la photo historique attachée au résultat legacy (`cotton-quiz/championnats/resultats`);
  - les stockages modernes par rang / ligne ne servent plus que de fallback si aucune photo historique n'existe.
  - le fallback legacy tente aussi maintenant plusieurs conventions d'emplacement historiques et une recherche directe de fichier `id_resultat.(jpg|jpeg|png|webp)` dans `championnats/resultats`.
  - le helper d'URL podium retombe aussi sur l'ancien schema de repertoire `u/t` quand une photo historique est encore rangee sous `cotton-quiz/championnats/resultats/...`.
  - quand un `media_id` existe, la resolution relit aussi les vrais champs `a/u/t/m` du media et tente les variantes legacy `-/_` avant de conclure qu'aucun chemin public exploitable n'a ete retrouve.
  - en `dev`, si le fichier historique public n'est pas monte localement, l'URL retombe sur la racine publique `www` `prod` au lieu de reutiliser le domaine du contexte appelant (`pro`, `www.dev`, etc.).
- Documentation mise à jour:
  - `documentation/canon/repos/global/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## FO fiche détail `Cotton Quiz`: séries programmées visibles — 2026-04-13

### Resume
- la fiche détail publique `www` n'exposait pas le détail des séries programmées sur un `Cotton Quiz`, alors que cette lecture était déjà disponible côté `play`;
- besoin retenu: afficher ces séries dans le bloc gauche d'informations, entre `Date` et `Lieu`, sans ouvrir d'autre dépendance code hors vue FO.

### Correctif livre
- `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - relit `quiz_series_label` et `quiz_series_names` depuis la session, avec fallback sur le détail jeu;
  - ajoute une ligne `Séries programmées` dans `col-12 col-lg-5`, entre `Date` et `Lieu`;
  - garde un rendu simple, cohérent avec les autres métadonnées de la fiche;
  - met aussi à jour les textes d'accordéon `Concept` / `Comment participer` sur `Cotton Quiz`, `Blind Test` et `Bingo Musical`;
  - réactive le bloc `Comment participer à un Bingo Musical ?` avec le nouveau wording;
  - réaligne le CTA principal `Je participe` sur la même URL EP sessionnelle que les liens présents dans les blocs `Comment participer`;
  - sur une session terminée `Cotton Quiz`, `Blind Test` ou `Bingo Musical`, remplace le visuel central par un bloc `Podium` puis `Classement complet`;
  - masque aussi le bloc gauche d'informations générales de session pour ne garder que les résultats;
  - masque dans ce contexte les accroches marketing et les blocs `Concept / Comment participer`;
  - reprend dans le titre de la liste basse le nombre réel de participants remonté par le moteur global de résultats;
  - garde désormais ce total visible côté `www` dans le titre `Classement complet / Liste des joueurs`;
  - sur `Bingo Musical`, la liste basse masque le rang et les points pour rester alignée sur la fiche archive `pro`;
  - affiche une photo gagnant quand elle existe, avec fallback icône propre par place sinon.
  - côté `pro`, la ligne `Particip.` du bloc paramètres d'une session terminée se cale elle aussi sur le total recalculé du moteur résultats pour rester cohérente avec la liste affichée.
  - les cartes de l'agenda archive `pro` répercutent elles aussi désormais ce total recalculé au lieu du compteur legacy de session.
- Documentation mise à jour:
  - `documentation/canon/repos/www/README.md`
  - `documentation/canon/repos/www/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`

## FO fiche `place`: synthèse alignée sur `Mes joueurs` — 2026-04-13

### Resume
- la fiche établissement `www` s'appuyait encore sur des compteurs legacy `app_statistiques_client_*`, avec des seuils arbitraires qui masquaient certaines lignes même quand des données réelles existaient;
- besoin retenu: reprendre la même source de vérité que `pro/ec` pour `membre depuis`, sessions, joueurs et équipes.

### Correctif livre
- `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - utilise maintenant `app_client_joueurs_dashboard_get_context(...)` comme source principale de la synthèse haute;
  - aligne `Membre depuis ...` et `... sessions de jeux Cotton` sur le moteur global partagé;
  - regroupe maintenant joueurs et équipes dans une seule ligne `... participants`;
  - applique la convention marketing `1 équipe Cotton Quiz = 3 participants`;
  - supprime les anciens seuils fixes de visibilité;
  - réactive, dans l'onglet `Sessions passées`, le CTA vers la fiche détail des sessions archivées;
  - filtre maintenant les sessions passées via `app_client_joueurs_dashboard_session_is_history_useful(...)`, pour rester aligné sur la lecture archive `pro`;
  - renomme le CTA des cartes archivées en `Voir les résultats`.
- Documentation mise à jour:
  - `documentation/canon/repos/www/README.md`
  - `documentation/canon/repos/www/TASKS.md`
  - `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## Compatibilite `app_sessions_get_liste(...)` / helper archive — 2026-04-13

### Resume
- le filtre archive ajoute sur `www/place` reutilisait correctement `app_client_joueurs_dashboard_session_is_history_useful(...)`, mais la liste source `app_sessions_get_liste(...)` ne remontait pas la cle `id` attendue par ce helper;
- consequence immediate: toutes les sessions passaient a `session_id <= 0`, donc la liste `Sessions passées` devenait vide.

### Correctif livre
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `app_sessions_get_liste(...)` expose maintenant `cs.id AS id` en plus de `id_championnat_session`;
  - les consumers `www` ou autres qui reutilisent les helpers archive/metier sur cette liste recuperent donc un identifiant session compatible sans adaptation locale.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## Fiche session archivée: espacement sous `Version : Papier` — 2026-04-13

### Resume
- apres masquage du lien d'impression papier sur une session archivee, la ligne `Version : Papier` restait trop compacte;
- besoin retenu: restaurer un espacement bas normal quand aucun bloc d'impression ne suit.

### Correctif livre
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - le `pb-0` du bloc `Version` n'est plus applique a tous les cas papier;
  - il reste reserve au seul cas papier non archive ou le lien d'impression est effectivement affiche juste dessous.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## Fiche session: message de classement Bingo legacy `2/3` — 2026-04-13

### Resume
- certaines sessions Bingo legacy `2/3` etaient maintenant considerees historiques via fallback date, mais la fiche detail continuait d'afficher `Cette session n'a pas été jouée jusqu'au bout` faute de vraie terminaison runtime;
- ce message n'etait plus coherent avec la regle metier retenue pour l'historique utile.

### Correctif livre
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - le helper de message de classement manquant traite maintenant les Bingos legacy `2/3` passes en date comme des sessions terminees au sens du fallback;
  - dans ce cas, la fiche detail affiche un message d'absence de classement final exploitable au lieu du message `pas jouée jusqu'au bout`.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## `Mes joueurs` / `Archives`: reintegration du Bingo legacy type `2` — 2026-04-13

### Resume
- le type produit `2` correspond au Bingo legacy mais restait exclu du moteur `Mes joueurs` et du filtre `Archives` `bingo-musical`;
- besoin retenu: le reintegrer dans l'historique utile et autoriser un fallback par date passee pour les Bingos `2/3`, y compris en numerique.

### Correctif livre
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - le mapping jeu traite maintenant aussi `id_type_produit = 2` comme `Bingo Musical`;
  - les requetes source `Mes joueurs` / periodes de classement couvrent maintenant le type `2`;
  - la terminaison historique applique un fallback par date passee aux Bingos `2/3`, tandis que le type `6` reste borne au runtime.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
  - le filtre `seo_slug_jeu=bingo-musical` couvre maintenant `2/3/6`;
  - la detection locale archive recharge aussi le detail jeu pour le type `2`.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`

## `Mes joueurs` / `Archives`: fallback Bingo papier borne au type `3` — 2026-04-13

### Resume
- le fallback legacy par date utilise pour preserver certains vieux Bingos papier etait encore applique a tous les Bingos papier `id_type_produit IN (3,6)`;
- consequence: des sessions papier recentes de type `6`, pas encore reellement terminees, pouvaient apparaitre en historique utile.

### Correctif livre
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - le fallback papier par date n'est plus autorise que pour `id_type_produit = 3`;
  - les sessions Bingo papier type `6` doivent maintenant etre reellement terminees runtime pour remonter dans `Archives` et dans les agregats `Mes joueurs`.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## `Mes joueurs`: selecteur de periodes et `Quiz V1` legacy — 2026-04-13

### Resume
- symptome observe: la synthese `Mes joueurs` remontait correctement les volumes historiques, mais le selecteur de classements ne proposait pas certaines annees anciennes;
- cause confirmee: le helper `app_client_joueurs_dashboard_period_has_leaderboard_data()` appelait le helper de terminaison legacy sans lui fournir la colonne `date`, indispensable pour reconnaitre un `id_type_produit = 1` comme termine.

### Correctif livre
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - la requete source du helper de periodes charge maintenant `date` et `flag_controle_numerique`;
  - les periodes composees de `Cotton Quiz V1` legacy peuvent a nouveau etre reconnues comme eligibles par le selecteur d'annees / saisons.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## `Mes joueurs`: rollback de l'hypothese `id_type_produit = 2` cote Quiz — 2026-04-13

### Resume
- verification du socle sessions confirmee: `id_type_produit = 2` correspond au Bingo legacy, pas a `Cotton Quiz`;
- l'hypothese precedente d'elargir les classements Quiz a ce type etait donc incorrecte.

### Correctif livre
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - rollback des elargissements Quiz `id_type_produit = 2`;
  - le moteur `Mes joueurs` redevient coherent avec le mapping central des types produit;
  - la version de cache de synthese `Mes joueurs` a ete incrementee pour purger toute reconstruction issue de cette fausse piste.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## Direct access EC: token QR non single-use au premier scan — 2026-04-13

### Resume
- après ajout du QR code desktop vers l'EC mobile, certains scans remontaient `Le lien de connexion directe n'est plus valide.`;
- cause probable confirmée: des apps de scan QR prechargent l'URL une premiere fois, ce qui consommait le token avant l'ouverture navigateur effective.

### Correctif livre
- `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
  - `client_contact_direct_access_consume(...)` ne vide plus immediatement `pwd_token` et `pwd_token_date`;
  - le lien temporaire reste utilisable pendant sa fenetre de validite, meme si un premier hit technique a deja eu lieu.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`

## Fiche session archivee: impression papier masquée — 2026-04-13

### Resume
- la fiche détail d'une session terminée conservait encore le lien d'impression papier, alors que ce support n'est utile qu'avant la tenue de la session.

### Correctif livre
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - le lien `Imprimer les feuilles de réponses` / support papier n'est plus rendu quand la session est archivée;
  - le garde est appliqué aux 2 blocs d'affichage concernés dans la vue.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## `Mes joueurs`: liens `Détail` vers l'historique archive filtré — 2026-04-13

### Resume
- la page `Mes joueurs` exposait les volumes de sessions et les bases de classement sans point d'entree direct vers les sessions historiques concernées;
- besoin retenu: permettre de rejoindre l'onglet `Archives` avec le bon filtre jeu, et avec la bonne plage de dates pour les classements saisonniers.

### Correctif livre
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - ajoute des helpers de construction d'URL `Archives`;
  - laisse finalement uniquement `Détail` a cote des sous-totaux par jeu dans la synthese;
  - place `Détail` inline dans la phrase `Classement calculé sur X sessions...` dans les entetes de classement;
  - garde un rendu de texte neutre sur les lignes `Classement calculé...` et `Attribution des points...`, tout en laissant `Détail` en bleu pour ressortir.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
  - accepte maintenant `seo_slug_jeu`, `date_start` et `date_end` pour filtrer l'historique archive sans changer de point d'entree.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`

## Historique EC / `Mes joueurs`: Bingo privilégie la vraie fin runtime avec fallback legacy — 2026-04-13

### Resume
- le moteur partage `Mes joueurs` traitait encore `Bingo Musical` comme termine des que la date de session etait passee;
- l'onglet `Archives` EC re-utilisait ce meme helper, ce qui laissait remonter des sessions bingo passees mais non reellement terminees.

### Correctif livre
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `app_client_joueurs_dashboard_session_is_reliably_terminated(...)` lit maintenant d'abord la vraie fin runtime Bingo;
  - pour les sessions Bingo papier, le helper garde un fallback legacy par date meme si la ligne playlist existe encore mais n'a jamais remonte de fin runtime exploitable;
  - pour les sessions Bingo numeriques, le helper ne retombe sur la date que si la ligne `jeux_bingo_musical_playlists_clients` n'est plus exploitable;
  - le filtre des participants reels continue ensuite de ne s'appliquer qu'aux sessions numeriques, ce qui preserve les vieux Bingos papier.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## Fiche session archivee: retour header vers `Archives` — 2026-04-13

### Resume
- sur la fiche detail d'une session passee, le CTA header de retour pointait encore vers l'agenda standard des sessions a venir;
- besoin retenu: aligner la navigation historique avec le listing `Archives`.

### Correctif livre
- `pro/web/ec/modules/tunnel/start/ec_start_include_header.php`
  - quand la fiche session est archivee, le CTA de retour du header affiche maintenant `"Archives"` et cible `extranet/start/games/archives`;
  - les autres contextes conservent le retour existant `Mon agenda`.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_include_header.php`

## Fiche session archivee desktop: QR code vers l'EC mobile — 2026-04-13

### Resume
- sur desktop, l'upload photo restait local au poste courant;
- besoin retenu: permettre de reprendre la meme fiche session sur mobile pour prendre et uploader la photo, sans creer une page mobile dediee.

### Correctif livre
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - le clic desktop `Ajouter une photo` ouvre maintenant une modale standard;
  - la modale affiche le QR code mobile et un CTA local `Choisir une photo présente sur cet appareil.`.
- `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
  - accepte maintenant un retour `session_view` borne a `id_securite_session` apres authentification;
  - conserve ce retour aussi en cas d'echec du lien temporaire vers `signin`.
- `pro/web/ec/ec_signin.php`
  - propage `return_to` et `id_securite_session` lors d'une connexion manuelle.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec_signin.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## Fiche session archivee mobile: upload photo unifie et orientation JPEG corrigee — 2026-04-13

### Resume
- sur mobile, la fiche detail session proposait 2 actions distinctes `Prendre une photo` / `Choisir une photo`;
- le flux camera pouvait echouer car le formulaire envoyait plusieurs `files_img[]` et le back ne relisait que le premier index;
- une photo issue de la bibliotheque pouvait aussi rester couchee apres upload faute de normalisation EXIF avant le resize/crop.

### Correctif livre
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - remplace les 2 boutons mobiles par un bouton unique ouvrant un mini-menu `Caméra / Photos`;
  - ajoute un garde front simple sur les formats supportes.
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - isole maintenant le premier vrai fichier uploadé dans le payload podium.
- `global/web/lib/core/lib_core_upload_functions.php`
  - applique une normalisation EXIF JPEG avant resize/crop.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/global/web/lib/core/lib_core_upload_functions.php`

## Fiche session archivee: `Paramètres` redevient prioritaire — 2026-04-13

### Resume
- sur la fiche detail d'une session passee, l'ordre de lecture etait inverse par rapport au besoin courant:
  - `Résultats` arrivait avant `Paramètres`;
  - le bloc `Paramètres` ne rappelait pas explicitement que la session etait terminee;
  - le `Contenu` / les thematiques restaient visibles alors qu'ils n'etaient plus utiles dans ce bloc historique.

### Correctif livre
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - le bloc `Paramètres` remonte maintenant avant `Résultats` via l'ordre de rendu de la grille;
  - un bandeau `Session terminée` est ajoute en tete du bloc `Paramètres`;
  - le `Contenu` / les thematiques / la playlist et leur detail associe sont masques quand la session est archivee.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## Remote fin de partie: CTA session detail plus compact et responsive — 2026-04-11

### Resume
- le CTA remote `Ajouter les photos des gagnants !` restait un peu haut et pouvait devenir trop large visuellement sur petit ecran;
- en plus, son texte etait encore force en `#111` au lieu de reutiliser la couleur de texte branding de la remote.

### Correctif livre
- `games/web/includes/canvas/css/remote_styles.css`
  - bouton compacté (`min-height`, `padding`, `gap`, icone un peu reduite);
  - largeur bornee pour eviter qu'il force la page mobile;
  - wrapping texte autorise;
  - couleur texte alignee sur `--primary-font`.

## Games organizer podium: photos distinctes pour ex aequo — 2026-04-11

### Resume
- apres le correctif `pro/global`, la fiche detail session savait bien afficher une photo par gagnant ex aequo;
- l'UI `games` organizer continuait pourtant d'en ecraser une, car `canvas_display.js` ramenait encore `window.ServerSessionMeta.podium_photos` a une map `rank -> src`.

### Correctif livre
- `games/web/includes/canvas/php/boot_lib.php`
  - enrichit `podium_photos` avec `photo_row_key`, `label`, `score`, `phase_label`.
- `games/web/includes/canvas/core/canvas_display.js`
  - resout maintenant une photo par carte de podium au lieu d'une photo par rang;
  - essaie d'abord la cle de ligne, puis un matching par nom/phase ou nom/score, puis un fallback sur le premier media libre du rang.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- verification JS brute non exploitable dans la sandbox:
  - `canvas_display.js` est un module navigateur ESM avec imports `@canvas/*`.

## Podium session: photos distinctes pour gagnants ex aequo — 2026-04-11

### Resume
- sur la fiche detail d'une session terminee, `pro` affichait bien plusieurs gagnants pour un meme rang (`#1 / #1`, etc.), mais le module photo restait calibre `1 photo par rang`;
- cause racine confirmee:
  - front d'upload groupe par `rank`;
  - stockage media groupe par `credits='rank:X'`;
  - resolution helper cote `global` relue elle aussi par rang uniquement.

### Correctif livre
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - ajoute une cle stable `photo_row_key` sur chaque ligne de podium;
  - lit d'abord un media dedie `row:<photo_row_key>`, puis retombe sur le stockage historique `rank:X`;
  - accepte maintenant cette cle au write path d'upload;
  - enrichit aussi les lignes podium Bingo avec l'id joueur quand il est disponible.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - affiche la photo et le formulaire d'upload au niveau de chaque gagnant quand plusieurs lignes partagent la meme place;
  - ajoute un separateur visuel entre gagnants ex aequo dans une meme carte de rang.
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - transmet `podium_row_key` au helper global d'upload.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`

## `global_config.php`: détection `dev` élargie à `*.dev.cotton-quiz.com` — 2026-04-10

### Resume
- après bootstrap autonome du SDK Stripe, les logs ont montré:
  - `loaded=/var/www/global.dev.cotton-quiz.com/web/.../global_config.php`
  - puis `server=prod`
- cause: `global/web/global_config.php` ne reconnaissait `dev` que pour `global.dev.cotton-quiz.com`;
- un flow lancé depuis `pro.dev.cotton-quiz.com` chargeait donc bien la config `global`, mais en mode `prod`.

### Correctif livre
- `global/web/global_config.php` et `global/web/global_config.template.php` considèrent maintenant tout host `*.dev.cotton-quiz.com` comme `dev`.

### Lecture attendue
- après nouveau test Stripe sur `pro.dev`, les logs doivent montrer:
  - bootstrap `global_config.php`
  - puis `server=dev`
  - puis `source=global_config`

## SDK Stripe: bootstrap autonome de `global_config.php` — 2026-04-10

### Resume
- les logs ont confirmé que certains appels Stripe en `dev` voyaient:
  - `source=fallback`
  - `conf_has_bucket=0`
- cela prouve qu'au moment d'appeler `stripe_sdk_functions.php`, le tableau `$conf` n'était pas encore initialisé dans ce contexte.

### Correctif livre
- `global/web/assets/stripe/sdk/stripe_sdk_functions.php` tente maintenant de charger lui-même:
  - `global_config.php`
  - puis `global_config.local.php`
  si `$conf` n'est pas encore disponible;
- le bootstrap a ensuite été durci:
  - un simple `$conf` non vide ne suffit plus;
  - il faut désormais qu'au moins un bucket Stripe runtime soit présent, sinon le SDK recharge la configuration locale;
- un log de bootstrap est émis:
  - `[Stripe config bootstrap] loaded=/.../global_config.php`
  - ou `[Stripe config bootstrap] no_runtime_config_found`

### Lecture attendue
- après un nouveau test `dev`, les logs doivent montrer:
  - un bootstrap runtime réussi;
  - puis `source=global_config` pour les clés Stripe.

## Debug source config Stripe (`global_config` vs fallback) — 2026-04-10

### Resume
- `global_config.php` a été renseigné hors git avec les secrets Stripe;
- avant suppression définitive des fallbacks hardcodés, il faut confirmer côté runtime `dev` que les valeurs viennent bien de `global_config.php`.

### Correctif livre
- ajout d'un log temporaire dans `global/web/assets/stripe/sdk/stripe_sdk_functions.php`;
- le helper `lib_Stripe_getConfigValue(...)` émet maintenant:
  - `[Stripe config source] key=... ; server=... ; source=global_config|fallback`
- émission uniquement quand une valeur Stripe est effectivement résolue.

### Lecture attendue
- en `dev`, après un flow Stripe:
  - `source=global_config` pour:
    - `stripe_public_api_key`
    - `stripe_private_api_key`
    - éventuellement `stripe_webhook_secret` si un webhook est exercé;
- si `source=fallback` apparaît, la migration runtime n'est pas encore effective pour la clé concernée.

### Statut final
- instrumentation retirée après validation runtime.

## Secrets Stripe: priorité `global_config` sans fallback hardcodé — 2026-04-10

### Resume
- les clés Stripe (`pk_*`, `sk_*`, `whsec_*`) étaient stockées directement dans `global/web/assets/stripe/sdk/stripe_sdk_functions.php`, fichier versionné;
- objectif retenu:
  - basculer d'abord `dev` vers `global_config.php`;
  - régénérer ensuite au moins la clé test;
  - retirer les fallbacks hardcodés après validation runtime.

### Correctif livre
- `global/web/assets/stripe/sdk/stripe_sdk_functions.php` lit désormais en priorité:
  - `$conf['stripe_public_api_key'][$conf['server']]`
  - `$conf['stripe_private_api_key'][$conf['server']]`
  - `$conf['stripe_webhook_secret'][$conf['server']]`
- les anciennes valeurs hardcodées ont été retirées après validation runtime;
- `global/web/global_config.template.php` documente les trois nouveaux blocs de configuration.

### Limite
- aucun `global_config.php` runtime n'est présent dans ce workspace;
- la mise en place réelle des nouvelles valeurs hors git reste donc à faire sur les environnements `dev` / `prod`.

## Portail Stripe affilié TdR prod: mapping prod rétabli — 2026-04-10

### Resume
- `main` et `develop` sont alignées sur `global` et `pro`, mais le comportement diverge encore entre `dev` et `prod` pour `open_affiliate_offer_portal`;
- les logs `pro` prod montrent des redirections systématiques vers `network_affiliate_network_affiliate_portal_configuration_missing`;
- sans accès SSH, la preuve a été captée depuis le runtime web lui-même.

### Correctif livre
- le debug runtime a confirmé en prod:
  - `requested_variant=network_affiliate_cancel_end_of_period`
  - `env_id=`
  - `env_legacy=`
  - `server_id=`
  - `server_legacy=`
- Stripe prod expose maintenant trois configurations utiles:
  - `bpc_1RLnEWLP3aHcgkSEBUxGEXa0` pour le portail standard par défaut
  - `bpc_1TKulJLP3aHcgkSEn8CdQlt1` pour `network` et `network_affiliate_cancel_end_of_period`
  - `bpc_1TKh9GLP3aHcgkSEMUKlR85t` pour `network_affiliate` et `network_affiliate_cancel_immediate`
- une seconde configuration portail Stripe prod a été créée pour le variant affilié immédiat:
  - `bpc_1TKh9GLP3aHcgkSEMUKlR85t`
- `global/web/assets/stripe/sdk/stripe_sdk_functions.php` mappe maintenant en `prod`:
  - `network` => `bpc_1TKulJLP3aHcgkSEn8CdQlt1`
  - `network_affiliate_cancel_end_of_period` => `bpc_1TKulJLP3aHcgkSEn8CdQlt1`
  - `network_affiliate` => `bpc_1TKh9GLP3aHcgkSEMUKlR85t`
  - `network_affiliate_cancel_immediate` => `bpc_1TKh9GLP3aHcgkSEMUKlR85t`
- le log temporaire dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php` a été retiré.

### Lecture attendue
- le flow TdR `open_affiliate_offer_portal` doit maintenant pouvoir créer sa session portail en prod pour les ouvertures `cancel_end_of_period`;
- les flows affiliés immédiats doivent maintenant aussi viser une vraie configuration Stripe prod dédiée.

## Audit TdR délégué: piste `Remises 2026` écartée — 2026-04-10

### Resume
- audit cible sur le checkout TdR -> offre deleguee remisee;
- fichiers relus:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- conclusion retenue:
  - la piste `Remises 2026` n'est pas la bonne;
  - l'exclusion des TdR du moteur BO est volontaire et conforme au métier;
  - il ne faut donc pas corriger ce scope pour traiter le bug observé côté TdR.

### Correctif livre
- aucun correctif conservé sur cette piste;
- le code a été remis dans son état précédent pour garder l'exclusion TdR du moteur `Remises 2026`.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`

### Notes d'audit
- le calcul de remise reseau/delegation n'a pas ete modifie;
- le sujet restant a trancher est dans la logique TdR/reseau propre, pas dans `Remises 2026`.

## Games remote papier: reseed identite canonique apres ajout participant EP — 2026-04-10

### Resume
- audit local cible sur l'ajout remote d'un participant EP/existant:
  - le flux joueur classique `EP -> games` reste coherent;
  - l'ecart se concentre sur les participants ajoutes par l'admin depuis la remote papier.
- addendum Bingo `fix_joueursEP`:
  - la divergence `main` vs branche courante est confirmee dans `games/web/includes/canvas/php/bingo_adapter_glue.php`:
    - `main` n'appelle pas `canvas_api_ep_link_resolve(...)` dans `bingo_api_player_register()`;
    - `fix_joueursEP` ajoute cette re-resolution serveur avant le recalcul de `player_id`.
  - cause racine retenue:
    - l'objectif produit du patch est valide, mais la traduction generique `id_joueur/id_equipe -> participantType/sourceTable/sourceId` etait trop large pour `Bingo Musical`;
    - sur Bingo, seule une source joueur (`equipes_joueurs`) est compatible avec le runtime `bingo_players` et les grilles rattachees a `id_joueur`;
    - un resultat serveur `team/equipes` n'est pas une identite canonique exploitable pour Bingo et pouvait faire tomber le flux dans un chemin non robuste.
- hypothese retenue:
  - il existait une fenetre juste apres `player_register` ou la remote pouvait encore manipuler une representation partielle du joueur avant relecture complete du snapshot runtime.
- correctif livre cote `games`:
  - `games/web/includes/canvas/remote/remote-ui.js` reseede maintenant immediatement la liste locale avec l'identite runtime canonique quand l'ajout provient d'un lookup DB (`sourceTable/sourceId`);
  - le refresh `players_get` standard reste ensuite la confirmation autoritaire.
  - `games/web/includes/canvas/php/quiz_adapter_glue.php`, `blindtest_adapter_glue.php` et `bingo_adapter_glue.php` reutilisent maintenant explicitement la row runtime existante pour `session + player_id` au lieu de dependre d'un `ON DUPLICATE KEY` insuffisant sur des schemas historiques non garantis.
  - en plus, si `player_register` arrive depuis un retour `EP -> games` avec `ep_connect_token`, les adapters resolvent eux-memes l'identite EP via le bridge token avant de recalculer `player_id`; on ne depend donc plus d'un `sourceTable/sourceId` correctement remonte par le front pour retomber sur la meme row runtime.
  - ces adapters renvoient maintenant `registration_state = created|reactivated|already_active`, ce qui permet a la remote et au register player de traiter les reinscriptions idempotentes sans les afficher comme des erreurs techniques.
  - `games/web/includes/canvas/play/register.js` ne marque plus `already_active` comme une inscription fraiche;
  - `games/web/includes/canvas/remote/remote-ui.js` affiche un message deja-inscrit adapte et n'emet plus de faux `admin_player_register` quand la row etait deja active.
  - addendum apres lecture du log de session `ci65...c869c7ef`:
    - la DB runtime etait bien dedupee, mais le WS voyait encore plusieurs `player_id` canoniques pour le meme `player_db_id=4694`;
    - cause racine: `games/web/includes/canvas/play/player_identity.js` ne remplacait pas un `player_id` local deja canonique par celui renvoye par `player_register`;
    - correctif: le `player_id` serveur remplace maintenant toujours l'identite session locale, ce qui supprime le doublon purement memoire/UI cote remote et master.
  - addendum apres lecture du log `blindtest` `ci65...076cfb34`:
    - meme avec une identite stable, le front player papier reenregistrait encore le joueur en WS via `registerPlayer`;
    - sur `blindtest`, cela recreait temporairement une seconde presence memoire pour le meme `player_db_id` jusqu'au disconnect de l'ancienne identite;
    - correctif: `player/paper:listen` est maintenant passif pour `quiz` / `blindtest`, et `register.js` utilise ce chemin en papier au lieu de `player/ready`.
  - correctif de suivi Bingo-only:
    - `bingo_api_player_register()` entoure maintenant `canvas_api_ep_link_resolve(...)` d'un `try/catch(Throwable)` avec logs explicites `EP_RESOLVE`, `EP_RESOLVE_FAIL`, `EP_RESOLVE_UNUSABLE`;
    - la source canonique Bingo est maintenant volontairement bornee a `participantType=player` / `sourceTable=equipes_joueurs`;
    - si la re-resolution serveur n'est pas exploitable, le backend retombe proprement sur le payload front deja resolu, sans supprimer la logique de re-resolution serveur pour les cas valides;
    - si un mapping `team/equipes` arrive tout de meme sur Bingo, il est purge avant le bridge runtime pour eviter une canonicalisation erronee et une remontee en `500`.
  - addendum apres preuve front numerique Bingo:
    - les logs montrent desormais `ep_link_resolve_ok` puis `player_register_ok`;
    - le point de casse restant etait `ep_link_finalize` avec `TOKEN_INVALID` juste apres;
    - cause racine confirmee: `player_register` lie deja la participation EP au runtime via `canvas_ep_account_bridge_link_runtime_participant(...)`, puis `ep_link_finalize` repassait immediatement sur la meme row et interpretait un `UPDATE rowCount() = 0` comme un token invalide;
    - correctif: `canvas_api_ep_link_finalize()` relit d'abord la row bridge et traite ce cas comme un succes idempotent `already_linked`;
    - garde complementaire: le canvas bridge mappe maintenant `TOKEN_INVALID` et erreurs bridge voisines en `400`, plus en `500`.
  - addendum apres comparaison `main` vs `fix_joueursEP` sur le flux WS Bingo:
    - aucune divergence n'explique un rejet cote `play-ws.js` ou `bingo.game/ws`;
    - la divergence bloquante est en amont dans `games/web/includes/canvas/play/register.js`;
    - sur la branche courante, le payload `player/ready` Bingo numerique utilisait `gridId: paperMode ? null : ...` au lieu de `isPaperMode()`;
    - `paperMode` n'existant pas dans ce scope, le `ReferenceError` etait absorbe par le `try/catch`, donc `player/ready` n'etait jamais emis;
    - effet concret: aucun boot WS Bingo numerique apres `player_register_ok`, ce qui donnait l'impression que le joueur "n'atteignait jamais" le serveur WS.

### Verification
- revue diff locale `games/web/includes/canvas/remote/remote-ui.js`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- verification syntaxique Node non exploitable telle quelle sur ce fichier ESM navigateur (`import` front via import map)
- verification complementaire Bingo-only:
  - comparaison locale `main` vs `fix_joueursEP` sur `web/includes/canvas/php/bingo_adapter_glue.php`;
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php` apres ajout du fallback defensif.
- verification complementaire bridge EP:
  - `php -l /home/romain/Cotton/games/web/includes/canvas/php/ep_account_bridge.php`
  - `php -l /home/romain/Cotton/games/web/games_ajax.php`
- verification complementaire comparaison branche:
  - `git -C /home/romain/Cotton/games diff main...fix_joueursEP -- web/includes/canvas/play/register.js`
  - constat: aucune diff `main...fix_joueursEP` sur `play-ws.js`

## Games -> PRO session detail: sortie fin de partie + photos podium live — 2026-04-09

### Addendum
- la fiche detail session archivee affiche maintenant le bloc `Résultats` avant le bloc `Paramètres`, comme point d'entree principal de lecture post-session;
- le remplacement d'une photo podium ne reconsomme plus une URL brute stable potentiellement servie depuis le cache navigateur;
- `global` ajoute maintenant un suffixe `?v=...` derive du media (`date_maj` / `date_ajout` / `id`) sur les URLs de photos podium, ce qui force l'affichage de la nouvelle image apres remplacement sans changer le stockage dedie par session/rang;
- la vue `pro` aligne aussi l'`accept` front sur les formats images effectivement autorises par l'upload (`jpg`, `jpeg`, `png`, `webp`).

### Resume
- l'objectif etait de pousser l'organisateur vers l'upload des photos gagnants sans lui demander de retrouver manuellement la bonne fiche session `pro`;
- le flux `games` renvoie maintenant vers la fiche detail session a la fermeture volontaire des interfaces organizer (`master`) et remote quand la session est terminee;
- le lancement d'une session `games` depuis les cartes agenda `pro` ouvre maintenant l'interface de jeu dans une nouvelle fenetre et replace l'onglet `pro` sur la fiche detail session;
- le podium organizer peut maintenant afficher les photos gagnants ajoutees apres la fin via le polling `session_meta_get`, sans rouvrir la session.

### Correctifs livres
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - les CTA `Ouvrir le jeu` des sessions qui ouvrent vraiment `games` utilisent maintenant `window.open(...)` puis redirigent l'onglet `pro` courant vers `/extranet/start/game/view/<id_securite_session>`;
  - `Cotton Quiz` V1 historique est explicitement exclu de cette mecanique.
- `games/web/organizer_canvas.php`
  - ajout de `AppConfig.sessionDetailUrl`.
- `games/web/includes/canvas/php/ep_account_bridge.php`
  - les inserts `games_remote_lookup` generent maintenant un `return_token` technique unique au lieu de `''`;
  - objectif: rester compatibles avec l'index SQL global `uniq_return_token` sans modifier le flux EP joueur direct, qui continue d'utiliser ses propres tokens de retour.
- `games/web/games_ajax.php`
  - charge maintenant `global_librairies.php` avant le bridge canvas;
  - cause racine identifiee via debug `session_meta_get`: les endpoints canvas executes avec `exit` precoce ne voyaient pas les helpers globaux de session/resultats, donc `podium_photos` restait vide meme quand `medias_images` contenait bien les photos gagnants.
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - la lecture des photos podium ne depend plus strictement d'un `file_exists(...)` local sur le serveur qui sert `games`;
  - si le media existe en base mais que le mount upload n'est pas visible depuis `games`, l'URL canonique `www/upload/...` est quand meme renvoyee au polling organizer, avec log de fallback pour l'audit infra.
- `games/web/includes/canvas/core/end_game.js`
  - la sortie organizer privilegie maintenant `sessionDetailUrl` avant le dashboard `pro`.
- `games/web/remote_canvas.php`
  - ajout d'un CTA termine `Ajouter les photos des gagnants !`;
  - exposition de `AppConfig.sessionDetailUrl`;
  - correction de l'initialisation `CONF_SITE_ROOT` pour supprimer le warning PHP observe sur la remote.
- `games/web/includes/canvas/remote/remote-ui.js`
  - si l'utilisateur quitte volontairement la remote en `Partie terminee`, l'UI redirige vers la fiche detail session au lieu de tenter `window.close()/about:blank`.
- `games/web/includes/canvas/php/boot_lib.php`
  - `session_meta_get` renvoie maintenant aussi `podium_photos` et les integre a sa signature.
- `games/web/includes/canvas/core/boot_organizer.js`
  - le polling organizer stocke les `podium_photos` live et declenche un rerender du podium quand elles changent.
- `games/web/includes/canvas/core/canvas_display.js`
- `games/web/includes/canvas/css/canvas_styles.css`
  - le podium organizer sait maintenant afficher une photo gagnant par rang avec cadrage dedie.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`
- `php -l /home/romain/Cotton/games/web/remote_canvas.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`

### Limites / Notes
- verification JS statique non concluante via `node --check` dans cette sandbox, car les fichiers canvas sont des modules ESM relies a une import map navigateur (`@canvas/...`) et non a un environnement Node resoluble tel quel;
- aucun test navigateur live n'a ete execute dans ce tour;
- la mecanique ne couvre pas `Cotton Quiz` V1 historique, qui ne passe pas par le repo `games`.

## Archives agenda EC: alignement sur les filtres metier `Mes joueurs` — 2026-04-09

### Resume
- la page `Archives` de l'agenda EC ne se limite plus au statut technique `archivee`;
- elle reuse maintenant les memes filtres metier que `Mes joueurs` pour ne garder que les sessions passees utiles au client;
- effet attendu:
  - une session numerique non terminee ou sans participation reelle fiable disparait des archives;
  - une session papier reste visible meme sans participation remontee.

### Correctifs livres
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - ajout d'un helper de qualification `session history useful`;
  - reprise des memes sources de participation fiables que `Mes joueurs`:
    - `Cotton Quiz`: equipes / runtime / resultats legacy;
    - `Blind Test`: bridge consomme puis runtime;
    - `Bingo Musical`: runtime puis grilles EP legacy.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
  - l'onglet `Archives` filtre maintenant ses sessions avec ce helper global;
  - la liste relit aussi `flag_controle_numerique` pour conserver les sessions papier dans le perimetre historique utile.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`

## Fiche session EC historique: résultats finaux + photos gagnants sans recalcul PRO — 2026-04-09

### Resume
- l'audit a confirme que la fiche detail session EC est rendue par `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`;
- la vue historique affiche maintenant:
  - le `Podium`
  - puis le `Classement complet` quand une verite exploitable existe;
- le podium accepte maintenant aussi une photo par rang (`#1/#2/#3`) depuis la fiche archivee, avec affichage direct dans chaque case;
- le bloc `Ressources` n'est plus affiche sur une session archivee;
- la logique de lecture a ete centralisee dans `global`, sans recalcul concurrent dans le template `pro`.
- le rendu final conserve les vraies positions `games` en cas d'egalite (`#1 / #1 / #3`) pour `Cotton Quiz` et `Blind Test`, et les photos podium sont volontairement recadrees a hauteur fixe pour garder une fiche EC stable.

### Correctifs livres
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - ajout d'un helper de contexte resultats de session;
  - ajout d'un helper de compteur participants runtime pour les sessions archivees;
  - lecture centralisee des sources runtime / legacy selon le jeu;
  - alignement du rang competition `1,1,3...` pour `Cotton Quiz` runtime et `Blind Test`;
  - ajout d'helpers de lecture/ecriture des photos podium par session et par rang;
  - fallback de lecture conserve sur le stockage historique quiz `championnats/resultats`;
  - fallback explicite:
    - session non terminee;
    - session terminee sans joueur;
    - `Bingo Musical`: podium de phases + liste historisee des joueurs;
  - correctif bingo historique:
    - la liste de joueurs ne filtre plus `bingo_players.is_active=1`;
    - la fiche EC n'annonce donc plus a tort `Aucun joueur...` quand la session affiche deja des participants.
    - la relecture des joueurs bingo choisit maintenant `updated_at`, sinon `created_at`, sinon `id` pour rester compatible avec les schemas plus anciens.
  - correctif compteur `Particip.`:
    - avant session, l'EC garde sa logique predictive historique;
    - apres session, le compteur relit prioritairement les tables modernes `*_players`;
    - fallback legacy seulement pour les anciens `Bingo Musical` et `Cotton Quiz` sans runtime exploitable;
    - `Cotton Quiz` garde son libelle `equipes` meme quand la source runtime existe.
  - correctif `Cotton Quiz` legacy sans runtime:
    - le compteur post-session s'aligne d'abord sur `championnats_resultats`;
    - la fiche detail affiche le score quiz de session, pas les points du classement general.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - affichage du bloc `Résultats` sur session archivee;
  - ordre `Podium` puis `Classement complet`;
  - masquage du bloc `Ressources` sur historique;
  - ajout des emojis `🏆`, `🥈`, `🥉` sur le podium;
  - podium desktop en `3` colonnes puis mobile en colonne;
  - CTA `Ajouter une photo` / `Modifier la photo` dans chaque case sur desktop;
  - sur mobile, 2 actions explicites `Prendre une photo` / `Choisir une photo`;
  - image gagnant recadree/coupee avec hauteur fixe dans la carte podium.
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - ajout des routes POST dediees d'upload photo podium pour `quiz`, `blindtest` et `bingo`.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/global/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Limites / TODO
- le pre-requis `recharger depuis les serveurs` a ete tente via `git fetch`, mais la sandbox a refuse l'ecriture de `.git/FETCH_HEAD`; l'audit s'appuie donc sur les refs `origin/*` deja presentes localement;
- aucun test fonctionnel navigateur/base n'a ete execute dans ce tour; seule la validation syntaxique PHP est confirmee;
- si le produit demande plus tard un vrai classement complet `Bingo Musical`, il faudra d'abord etablir une source de verite ordonnee cote jeux, inexistante aujourd'hui dans le flux de fin de session relu.

## Remises ABN: baseline DB runtime + cause racine prod documentees — 2026-04-09

### Resume
- l'incident prod du lot `remises` est maintenant documente avec un constat stabilise:
  - le vieux script `www/web/bo/www/modules/ecommerce/remises/bdd_ecommerce_remises.sql` n'etait pas une migration complete du lot;
  - la prod a subi un schema runtime incomplet;
  - puis un second ecart de deploy a maintenu un ancien `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`, ce qui laissait PRO afficher la remise sans la snapshotter au checkout;
- la baseline DB et les liens fonctionnels reels du moteur `remises` sont maintenant poses dans la doc `develop`;
- la prod a ensuite ete revalidee:
  - dashboard OK
  - `Offres & factures` OK
  - facture PDF PRO OK
  - checkout remises PRO -> snapshot checkout OK apres redeploiement du bon script.

### Correctifs documentaires livres
- `documentation/canon/repos/global/TASKS.md`
  - baseline DB runtime retenue
  - chaine fonctionnelle BO -> preview -> checkout -> webhook -> facture
  - cause racine prod documentee
- `documentation/canon/repos/pro/README.md`
  - note de deploy `remises` cote PRO
  - rappel que preview PRO seule != preuve checkout Stripe
- `documentation/canon/repos/pro/TASKS.md`
  - point de panne prod
  - baseline de deploy cote PRO
- `documentation/HANDOFF.md`
  - synthese de l'incident et des docs alignees
  - rappel que la verite `remises` est portee par les docs `global` / `pro`, pas par la note historique TdR

### Verification
- comparaison dev/prod des tables runtime du lot:
  - `ecommerce_offres_to_clients`
  - `ecommerce_remises`
  - `ecommerce_remises_to_offres`
  - `ecommerce_remises_to_clients`
  - `ecommerce_commandes_lignes`
  - `ecommerce_stripe_write_guards`
- verification logs prod apres redeploiement correct:
  - `scope_ok = 1`
  - `resolution ok = 1`
  - `snapshot_saved`

### Next steps
- merger la documentation `develop` vers `main`
- conserver un script de migration unique aligne sur le schema runtime reel du lot `remises`
- ne plus traiter `bdd_ecommerce_remises.sql` comme migration prod exhaustive a lui seul

## E-commerce: la periode d'un ABN annuel ne glisse plus par mois dans `Offres & factures` — 2026-04-08

### Resume
- l'audit du read path `Offres & factures` a confirme que l'affichage PRO ne recalculait rien localement: il relisait une periode renvoyee par le helper global d'abonnement;
- la cause racine etait dans `app_ecommerce_offre_client_abonnement_periode_get_detail()`:
  - le helper historique `app_ecommerce_offre_client_abonnement_periode_en_cours_get_date_debut()` etait utilise pour toute frequence;
  - ce helper avance toujours l'ancre de periode par mois;
  - applique a un ABN annuel, il pouvait produire un debut glissant mensuel, puis une fin annuelle incoherente;
- le correctif borne maintenant ce recalcul aux seuls ABN mensuels.

### Correctifs livres
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - le recalcul via `app_ecommerce_offre_client_abonnement_periode_en_cours_get_date_debut()` reste applique uniquement quand `id_paiement_frequence = 1`;
  - pour un ABN annuel, l'ancre BDD (`date_facturation_debut` puis `date_debut`) reste la base de lecture si aucune periode Stripe live n'est exploitable.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

## Agenda PRO: la bibliothèque Quiz legacy V1 revient à un choix mono-série — 2026-04-08

### Resume
- l'audit de la bibliothèque Quiz a confirmé que les comptes legacy `Cotton Quiz V1` pouvaient encore entrer dans le builder multi-séries du Quiz V2;
- ce comportement était hors contrat métier pour le legacy: une seule série thématique doit être choisie, puis placée en dernière position du quiz, quel que soit le format `2` ou `4` séries;
- la bibliothèque neutralise maintenant ce builder pour les comptes V1, et le write path `start` borne aussi ce flux à un seul identifiant de série.

### Correctifs livres
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - détection client legacy V1;
  - builder multi-séries neutralisé;
  - bandeau de contexte réaligné sur le choix mono-série.
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - même détection et même neutralisation en fiche détail;
  - les CTA Quiz passent alors directement par le flux mono-série.
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - garde-fou serveur sur les modes builder pour les comptes legacy V1;
  - purge défensive d'une ancienne sélection builder si besoin.
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `quiz_lot_ids` est maintenant limité à `1` item pour les sessions `id_type_produit = 1`.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

## Agenda PRO: le tunnel legacy Quiz V1 ne reboucle plus vers `view` avant programmation — 2026-04-08

### Resume
- l'audit du tunnel agenda legacy `Cotton Quiz` V1 a confirme une sortie prematuree de `setting` vers `/extranet/start/game/view/...`;
- la cause racine n'etait pas le choix `2 series / 4 series` lui-meme, mais l'etat de session relu en polling:
  - une session legacy V1 encore incomplete avec date vide / `0000-00-00` etait consideree comme verrouillee;
  - le front la renvoyait alors vers `view` avant toute programmation de date.
- le resolver global traite maintenant ce cas comme `pending`, et le polling PRO ne redirige plus une session sans `id_produit`.

### Correctifs livres
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - une date legacy V1 vide / invalide / `0000-00-00` est maintenant marquee `legacy_date_missing` et reste `pending`.
- `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
  - la synchro front ne rebascule plus vers `view` tant que la session n'a pas encore de jeu genere.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

## E-commerce: facture PDF alignée sur les snapshots canoniques et remise explicitée — 2026-04-08

### Resume
- l'audit de `bo_factures_view_pdf.php` a confirme que la facture PDF continuait d'afficher la remise dans le libelle produit snapshotte;
- le bloc des totaux restait aussi expose a un ecart visible quand la TVA etait relue depuis un `HT` deja arrondi alors que le `TTC` canonique facture etait deja connu;
- la facture PDF se base maintenant sur les snapshots de ligne structures et affiche la remise explicitement dans le recap de totaux;
- le meme correctif est maintenant reporte aussi dans le template PDF du front PRO, qui etait distinct du template BO.

### Correctifs livres
- `www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`
  - retrait du libelle de remise de la description produit PDF;
  - affichage du `PU HT` et du `PRIX TOTAL HT` de reference avant remise quand une remise snapshottee existe;
  - ajout d'un bloc totaux explicite `TOTAL HT` / `REMISE ... HT` / `TOTAL REMISÉ HT` / `TVA (...)` / `TOTAL TTC`;
  - TVA visible derivee de `TTC canonique - HT net snapshotte` pour rester coherente avec le montant final facture;
  - bootstrap durci avec `__DIR__` pour ne plus dependre du repertoire courant du process PHP;
  - le chargement du logo BO lit maintenant un asset partage `global/web/assets/branding/pdf/cotton-facture-logo.jpg`, avec garde-fou si le fichier n'est pas lisible.
- `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
  - meme realignement de rendu pour l'ouverture des factures depuis l'espace PRO;
  - comme le PDF est regenere a l'ouverture, le nouveau rendu s'applique aussi aux factures deja existantes;
  - correction des derniers libelles accentues FPDF (`Tél.`, `REMISÉ`, `TVA (...)`) pour eviter le mojibake a l'affichage/copie;
  - le meme logo partage `global/web/assets/branding/pdf/cotton-facture-logo.jpg` est maintenant utilise;
  - la remise reste visible dans la designation produit pour rester alignee sur le BO.
- `global/web/assets/branding/pdf/cotton-facture-logo.jpg`
  - nouvel asset commun facture PDF pour BO + PRO.

### Verification
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
- cas reproduit:
  - `99,90 € HT -25 %`
  - `TOTAL HT 99,90 €`
  - `REMISE 25 % HT 24,97 €`
  - `TOTAL REMISÉ HT 74,93 €`
  - `TVA (20 %) 14,98 €`
  - `TOTAL TTC 89,91 €`

### Docs touchees
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

## E-commerce: TTC d'affichage aligne sur le montant canonique de facturation — 2026-04-08

### Resume
- l'audit a confirme un ecart de micro-arrondi entre Cotton et Stripe sur certains ABN remises, parce que Cotton recalculait encore parfois le TTC depuis un HT deja arrondi;
- le cas reproduit `99,90 € HT -25 %` donnait `74,93 € HT / 89,92 € TTC` cote Cotton, alors que Stripe facturait `89,91 € TTC`;
- le socle e-commerce utilise maintenant un resolver unique base sur un montant canonique en centimes;
- le HT affiche reste derive et informatif, mais le TTC final affiche reste aligne avec la verite facturee.

### Correctifs livres
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - ajout des helpers centraux montant/centimes et d'un resolver d'affichage e-commerce;
  - realignement du snapshot commande pour ne plus recalculer le TTC depuis un HT deja arrondi.
- `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - les previews ABN avec remise BO repartent maintenant du TTC canonique.
- `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - le `unit_amount` Stripe du checkout repart maintenant du resolver canonique.
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - le recap de commande et l'historique affichent maintenant le TTC canonique, plus un TTC recalcule depuis le HT affiche.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- reproduction executee:
  - avant `74,93 € HT / 89,92 € TTC`
  - apres `74,93 € HT / 89,91 € TTC`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

## E-commerce: l'onglet `Offre` borne maintenant l'affichage de remise a la periode courante — 2026-04-08

### Resume
- dans `Offres & factures`, l'onglet `Offre` n'affichait pas encore le recap de remise hors contexte checkout;
- l'affichage est maintenant present, mais seulement si la remise snapshottee couvre encore la periode de facturation en cours;
- le rendu reutilise le meme recap metier que celui affiche apres le paiement Stripe.

### Correctifs livres
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - ajout d'un helper de statut de remise sur periode courante;
  - `app_ecommerce_offre_client_get_detail()` relit maintenant aussi `id_remise` et `prix_reference_ht`.
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - l'onglet `Offre` affiche maintenant le bloc remise + recap metier si la remise couvre encore la periode en cours.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/notes/plan_migration_reseau_branding_contenu.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

## Documentation: recommandation backlog pour remises sur ABN deja actifs — 2026-04-08

### Resume
- la note [recommendations.md](/home/romain/Cotton/documentation/notes/recommendations.md) ne consignait pas encore l'idee d'une future remise applicable aux prochaines echeances d'abonnements deja actifs;
- une section backlog y rappelle maintenant le besoin, la limite de l'architecture actuelle et l'approche recommandee si ce chantier est ouvert plus tard.

### Docs touchees
- `documentation/notes/recommendations.md`

## BO `Remises 2026`: lien prospect via la route publique historique — 2026-04-08

### Resume
- le lien de la fiche detail n'etait pas réellement cliquable car l'ancre gardait `href="#"`;
- la fiche detail reutilise maintenant la route historique publique `/utm/cotton/<token_public>`;
- pour `Remises 2026`, ce token est desormais l'`id_securite` opaque de la remise, avec compatibilite conservee pour les anciens liens a base de `code`.
- les anciennes remises `2026` sans `id_securite` sont maintenant backfillées automatiquement au premier rendu du lien BO.
- si la fenetre de commande est expirée, le lien signup n'est plus expose et la remise n'est plus proposable en ajout manuel.

### Correctifs livres
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - ajout d'un resolver de token public `code` ou `id_securite`.
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - le helper genere a nouveau la route historique `https://pro.../utm/cotton/<token_public>`;
  - il genere aussi un `id_securite` si une ancienne remise n'en a pas encore.
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
  - le bloc `Lien d'inscription` affiche maintenant d'abord le CTA `Copier le lien`;
  - l'URL reste visible dessous, en petit et non cliquable.
- `pro/web/ec/ec_sign.php`
- `pro/web/ec/ec_signin.php`
- `pro/web/ec/ec_signup.php`
  - resolution compatible des tokens publics `code` ou `id_securite`.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec_sign.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec_signin.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec_signup.php`

## BO `Remises 2026`: premiere livraison du lien d'inscription copiable — 2026-04-08

### Resume
- la fiche detail d'une `Remise 2026` manuelle active expose maintenant un lien d'inscription directement copiable;
- la route publique `/utm/cotton/...` reste compatible avec les anciens codes `REM2026_...`, en plus du token opaque `id_securite`.

### Correctifs livres
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - ajout du helper de construction du lien signup.
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
  - premiere exposition du lien public et du bouton `Copier le lien` sur la fiche detail.
- `pro/web/.htaccess`
  - la rewrite `/utm/cotton/...` accepte maintenant `_`.

### Verification
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`

## Checkout ABN: recap de remise explicite avant Stripe — 2026-04-08

### Resume
- le step `Detail de ma commande` n'utilise plus seulement `Au lieu de ...` pour les remises BO;
- le tunnel affiche maintenant un recap metier explicite, y compris quand un essai gratuit precede la remise;
- le recap rappelle aussi desormais le montant TTC du tarif standard et sa frequence.

### Correctifs livres
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - ajout d'un helper de wording checkout pour les remises ABN.
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - remplacement du libelle fixe par le recap dynamique dans le step 2.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`

## BO clients: section `Remises` branchée sur `Remises 2026` — 2026-04-08

### Resume
- le menu `Commercial` n'expose plus les deux entrées legacy de remises;
- la fiche client BO réutilise sa section `Remises` pour lire les `Remises 2026` applicables et rattacher une regle manuelle a un compte.
- une regle manuelle encore sans comptes lies ne doit plus apparaitre comme deja attachee au client courant.

### Correctifs livres
- `www/web/bo/bo.php`
  - retrait des entrées de menu `Remises > catalogue Cotton` et `Remises > accordées aux clients`.
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - ajout de helpers de lecture des remises actives par compte et des règles manuelles ajoutables.
- `www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - ajout des write paths `remise_2026_target_add` et `remise_2026_target_remove`.
- `www/web/bo/www/modules/entites/clients/bo_module_aside.php`
  - remplacement de la section legacy `ecommerce_remises_clients` par une section `Remises 2026` active + ajout manuel.

### Verification
- `php -l /home/romain/Cotton/www/web/bo/bo.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_script.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_module_aside.php`

## BO `Remises 2026`: fiche detail simplifiee — 2026-04-08

### Resume
- la fiche detail ne duplique plus la duree de remise entre un champ legacy et un resume metier;
- l'information de fenetre de commande est repositionnee sous l'etat avec un libelle plus explicite.

### Correctifs livres
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
  - suppression du champ `Durée de remise`;
  - renommage de `Résumé métier` en `Durée de la remise`;
  - deplacement de `Période` sous `Etat`;
  - renommage en `Remise sur commande` avec rendu `du ... au ...` sur la fiche detail.

### Verification
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`

## Widget ABN: duree de remise masquee avant paiement — 2026-04-08

### Resume
- sur le widget `Tarifs & commande`, la mention de duree de remise n'est plus affichee sous le badge promo BO;
- Stripe reste charge d'afficher cette information au moment du paiement.

### Correctifs livres
- `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - retrait de la sous-ligne `duree_remise_label` dans le badge de remise.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`

## SQL BO remises: migration explicite Remises 2026 / schedule Stripe — 2026-04-08

### Resume
- le runtime portait deja les 2 colonnes en lazy-init;
- un bloc SQL explicite a maintenant ete ajoute pour preparer la migration prod sans dependre du premier passage applicatif.

### Correctifs livres
- `www/web/bo/www/modules/ecommerce/remises/bdd_ecommerce_remises.sql`
  - ajout de `ecommerce_remises.duree_remise_mois`;
  - ajout de `ecommerce_offres_to_clients.stripe_subscription_schedule_id`;
  - backfill defensif des valeurs `NULL`.

## Stripe customer stale en dev — 2026-04-08

### Resume
- certains clients de la base `dev` portent un `asset_stripe_customerId` qui n'appartient pas au compte Stripe test actuellement utilise;
- le checkout standard reutilisait cet id en confiance et echouait sur `No such customer`.

### Correctifs livres
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `app_ecommerce_stripe_customer_ensure_for_client(...)` tente maintenant de relire le customer stocke;
  - si Stripe repond `No such customer`, l'id est invalide localement puis un nouveau customer est recree dans l'environnement courant.
- `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - le checkout standard passe maintenant systematiquement par ce helper global.

### Impact fonctionnel
- en `dev/test`, un ancien `cus_...` live ou stale ne doit plus bloquer seul la preparation du checkout;
- le customer local peut etre regenere automatiquement au premier checkout suivant.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`

## Remises 2026 / ABN standard — 2026-04-08

### Resume
- le lot fait evoluer `Remises 2026` sans transformer le BO en panneau Stripe;
- la regle BO porte maintenant:
  - la remise
  - le ciblage existant
  - la duree d'application;
- la duree par defaut est `12 mois`, avec support `1..N mois` et `sans limite`;
- l'arbitrage technique est entierement deduit par le moteur global:
  - mensuel + duree limitee => `schedule`
  - `sans limite` => `coupon`
  - annuel + duree limitee => chemin simple `coupon`, sans phasage intra-annuel;
- cas annuel impose:
  - `< 12 mois` = remise sur la premiere facture annuelle uniquement;
  - `>= 12 mois` = implementation simple et stable a l'echeance annuelle;
- la subscription Stripe reste l'objet metier principal cote SI;
- les cas schedule partent de `checkout.session.completed`, puis stockent `stripe_subscription_schedule_id` pour audit/debug/idempotence.

### Correctifs livres
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - normalisation de `duree_remise_mois`;
  - resolver checkout/preview enrichi avec duree, moteur et eligibilite trial;
  - helpers coupon Stripe par duree;
  - helpers de persistance `stripe_subscription_schedule_id`;
  - helper de creation de schedule via `from_subscription`.
- `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - affichage de la duree de remise dans le badge de previsualisation.
- `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - trial CHR resolu par helper global;
  - metadata de souscription enrichies avec duree/moteur;
  - coupon injecte sur le flux simple, avec decision moteur centralisee.
- `pro/web/ec/ec_webhook_stripe_handler.php`
  - orchestration post-checkout des schedules mensuels limites;
  - garde d'idempotence par write guards + schedule deja stocke;
  - stockage de `stripe_subscription_schedule_id`.
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
  - ajout du champ BO `duree_remise_mois` et de ses libelles metier.
- `documentation/canon/data/schema/DDL.sql`
  - schema documentaire aligne sur les 2 colonnes ajoutees en lazy-init.

### Impact fonctionnel
- aucun choix technique `coupon/schedule` n'est expose au BO;
- l'essai CHR reste une decision par client reel, pas par regle BO;
- le checkout abonnement existant reste en place;
- aucun schedule n'est cree pour une remise annuelle courte;
- un meme `checkout.session.completed` ne doit pas creer deux schedules sur la meme subscription/offre.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`

## ABN standard / remises BO Stripe V1 — 2026-04-07

### Resume
- le lot ajoute une remise commerciale BO generique sur le checkout Stripe standard de l'abonnement, sans recalculer le prix catalogue cote Cotton et sans integrer le reseau;
- la remise reste bornee a une seule regle gagnante `% off`, appliquee via `discounts[coupon]` Stripe, avec snapshot local uniquement si le coupon Stripe est effectivement disponible.
- les ecrans PRO `Tarifs & commande` puis `Detail de ma commande` affichent maintenant aussi, avant paiement, une lecture previsionnelle de cette remise quand le meme scope checkout ABN 12 est eligible.
- la V1 est maintenant exposee via un nouveau chemin BO dedie `Commercial > Remises 2026`, pour ne plus dependre du CRUD legacy `remises_offres`;
- le formulaire `Remises 2026` inferre maintenant `mode=modifier` quand une fiche existante est ouverte via `id>0` sans `mode` explicite, afin d'eviter la creation d'un doublon actif lors d'une edition BO;
- la liste `Remises 2026` permet maintenant aussi une suppression directe, avec purge prealable des liaisons ABN 12 et des ciblages manuels avant suppression de la regle;
- la liste detaille maintenant le ciblage avec les valeurs reelles de `pipeline` / `typologie`, et la vue ajoute un recap numerique `Comptes concernes`;
- les nouveaux coupons Stripe V1 ne sont plus crees en `forever`: ils sont maintenant fixes a `12 mois`, avec metadata de souscription correspondante; les souscriptions plus anciennes deja parties avec un coupon permanent ne sont pas retro-modifiees par ce patch;
- les routes legacy `remises` / `remises_offres` ne sont plus le chemin cible de parametrage V1 et restent laissees dans leur logique historique;
- le scope runtime est explicitement borne a l'offre ABN Stripe `id_offre = 12`.

### Correctifs livres
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - ajout du resolver unique de remises BO;
  - ajout d'un helper de previsualisation de la remise gagnante sans `offre_client` persistée;
  - ajout des gardes reseau V2 prouves;
  - ajout du helper de coupon Stripe reutilisable par pourcentage;
  - ajout d'une revalidation du `Price` Stripe catalogue par `lookup_key` contre le TTC Cotton attendu, avec recreation + transfert de `lookup_key` si le prix Stripe actif est obsolete;
  - ajout du reset/apply snapshot sur `ecommerce_offres_to_clients`;
  - copie du snapshot vers `ecommerce_commandes_lignes`.
- `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - branchement de cette previsualisation sur les cartes `Tarifs & commande`;
  - affichage du badge remise et des prix barres/discountés sur le step 1;
  - transmission du `remise_nom` previsionnel dans le formulaire de selection d'offre.
- `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - branchement du resolver juste avant la creation de la `Checkout Session` Stripe standard;
  - appel systematique du helper de reconciliation du `Price` Stripe catalogue au lieu d'un simple lookup passif;
  - aucun `discounts` si coupon indisponible ou si le snapshot local echoue.
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - branchement d'une lecture previsionnelle du resolver dans le recap PRO du tunnel commande;
  - affichage du libelle remise et du tarif net attendu avant redirection Stripe, sans write path ni snapshot.
- `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
  - fallback `offre_client` borne au seul secours legacy si la ligne est vide.
- `www/web/bo/www/modules/ecommerce/remises_to_clients/bo_module_parametres.php`
  - exposition BO du ciblage explicite organisateurs et de la fenetre de commande.
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
- `www/web/bo/bo.php`
  - nouveau module BO dedie `Remises 2026` sous `Commercial`;
  - creation/edition d'une regle V1 avec:
    - `nom interne`
    - `descriptif interne`
    - `nom espace pro`
    - `typologie`
    - `pipeline`
    - `remise en %`
    - `date debut commande`
    - `date fin commande`
    - `active/inactive`
  - liaison automatique de la remise a `id_offre = 12`;
  - mode automatique si `typologie` et/ou `pipeline` sont renseignes;
  - mode manuel par comptes explicites sinon.
- SQL livre:
  - `documentation/specs/tests/abn_standard_remises_v1_phpmyadmin.sql`

### Impact fonctionnel
- Stripe reste la verite du prix de base via le `price` catalogue ABN, mais un `Price` catalogue obsolete ne doit plus survivre au simple fait qu'il porte encore la bonne `lookup_key`;
- le scope runtime V1 est borne a l'ABN periodique reel `id_offre = 12`, `id_offre_type = 2` et `id_paiement_type = 2`, pas a tout `id_offre_type = 2` pris isolement;
- Cotton ne resolve que l'eligibilite remise et ne gele localement que le snapshot final accepte par Stripe;
- cote PRO, le client peut maintenant voir avant paiement la remise 2026 attendue dans `Tarifs & commande` puis `Detail de ma commande`, sur le meme scope que celui utilise ensuite pour la `Checkout Session`;
- cote Stripe, la base de calcul doit maintenant repartir du TTC Cotton courant pour la `lookup_key` concernee avant application du coupon `% off`;
- la ligne de commande devient la source de verite facture pour la remise;
- la logique reseau reste hors scope V1 et n'est pas integree au nouveau resolver.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_to_clients/bo_module_parametres.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
- `php -l /home/romain/Cotton/www/web/bo/bo.php`

## GAMES player identity / bingo resume — 2026-04-07

### Resume
- apres l'introduction des refus metier de pseudo, un premier echec d'inscription pouvait laisser une identite locale provisoire, puis polluer une seconde tentative, surtout sur `Bingo Musical`;
- en parallele, certains chemins bingo relisaient encore un `playerDbId` global legacy, ce qui laissait theoretquement un id SQL d'une autre session se recoller sur la session courante.

### Correctifs livres
- `games/web/includes/canvas/play/register.js`
  - ajout d'un cleanup cible `clearRejectedRegistrationDraft(...)`;
  - purge executee uniquement sur `USERNAME_ALREADY_USED` / `USERNAME_REFERENCED`;
  - aucun cleanup automatique sur erreur technique, pour preserver une reprise legitime apres succes serveur;
  - pour `bingo`, purge aussi des artefacts locaux de grille.
- `games/web/includes/canvas/play/player_identity.js`
  - ajout de `getPlayerDbIdStrict({ game, sid })`, borne a la cle session-scopee `player_db_id:<session>`.
- `games/web/includes/canvas/play/play-ws.js`
- `games/web/includes/canvas/play/play-ui.js`
  - les lectures bingo critiques (`auth`, reprise, hydrate/sync grille) ne relisent plus le fallback global `player_db_id`.

### Impact fonctionnel
- un refus de pseudo ne doit plus laisser derriere lui une identite locale fantome susceptible de casser l'inscription suivante;
- bingo ne doit plus pouvoir reutiliser un `playerDbId` d'une autre session via le fallback global legacy.

### Docs touchees
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/play/player_identity.js`

## PRO `Mes joueurs` / GAMES bridge runtime-EP / doublons d'inscription — 2026-04-03

### Resume
- le fil a couvert a la fois des regressions de reporting `Mes joueurs` et plusieurs incoherences entre runtime `games` et rattachement EP;
- cote `pro`, les sessions `Bingo Musical` historiques pouvaient disparaitre de la synthese haute car le dashboard relisait un etat de playlist mutable au lieu d'une notion historique stable;
- cote `games`, les inscriptions runtime pures autorisaient encore des collisions de nom, les ajouts remote DB n'ecrivaient pas toujours la table bridge, et une reinscription EP pouvait recreer une nouvelle row runtime.

### Correctifs livres
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - suppression du filtre `is_active` dans les lectures runtime du moteur agregateur historique;
  - pour `Bingo Musical`, une session passee est maintenant consideree comme historique/terminee dans `Mes joueurs`;
  - cache journalier de synthese versionne pour forcer le recalcul apres ce correctif.
- `games/web/includes/canvas/php/boot_lib.php`
  - ajout d'un helper de detection de nom deja reference chez l'organisateur.
- `games/web/includes/canvas/php/ep_account_bridge.php`
  - ajout du helper de liaison runtime -> bridge EP pour les participants DB ajoutes depuis la remote.
- `games/web/includes/canvas/php/quiz_adapter_glue.php`
- `games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `games/web/includes/canvas/php/bingo_adapter_glue.php`
  - garde runtime pure:
    - refus si le nom existe deja dans la session;
    - refus si le nom est deja reference chez l'organisateur;
  - bypass conserve pour:
    - inscriptions via `ep_connect_token`;
    - ajouts remote issus d'un lookup DB;
  - harmonisation des messages utilisateur;
  - reutilisation d'une identite runtime stable pour les inscriptions EP;
  - ecriture / mise a jour de `championnats_sessions_participations_games_connectees` pour les ajouts remote DB.
- `games/web/includes/canvas/play/register.js`
  - envoi de `ep_connect_token` + payload source EP sur `player_register`;
  - derivation de `participantType/sourceTable/sourceId` depuis le contexte EP.
- `games/web/includes/canvas/remote/remote-ui.js`
  - transmission de `sessionId`, `participantType`, `sourceTable`, `sourceId` sur l'ajout remote live.
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `app_joueur_games_bridge_prepare_return(...)` reutilise maintenant un bridge existant pour la meme session, le meme jeu et la meme identite EP, au lieu d'empiler des lignes.

### Impact fonctionnel
- `Mes joueurs` doit de nouveau compter les sessions bingo historiques dans la synthese haute;
- les classements agreges historiques ne perdent plus une session terminee simplement parce que tous les participants runtime sont passes `is_active = 0`;
- un ajout remote d'un joueur/equipe deja connu en base rattache maintenant explicitement cette identite a la session via la table bridge;
- une reinscription EP dans la meme session doit reutiliser la meme row runtime;
- une inscription runtime pure ne peut plus prendre:
  - un nom deja utilise dans la session;
  - ni un nom deja reference chez l'organisateur.

### Point restant ouvert
- les classements finaux runtime de session peuvent encore refléter des doublons legacy deja presents dans les tables `*_players`;
- ce point n'a pas ete repatche ici, la prevention a ete deplacee a l'inscription.

### Docs touchees
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/notes/audit-pro-mes-joueurs-runtime-bridge-2026-04-03.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/ep_account_bridge.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`

## PRO signup — reutilisation du compte existant si `email + nom client` correspondent — 2026-04-03

### Resume
- le signup public pro recreait jusque-la un `client` avant de verifier seulement si le `contact` existait deja par email;
- un compte deja cree sous le meme nom d'etablissement et le meme email pouvait donc etre duplique.

### Correctifs livres
- `pro/web/ec/modules/compte/client/ec_client_script.php`
  - lookup prealable du couple `email contact + nom client`;
  - si match trouve, reutilisation de `id_client` et `id_client_contact` au lieu de recreer le compte;
  - les side effects de creation initiale sont sautes sur ce chemin de reutilisation.
- `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
  - ajout du helper `client_contact_client_find_by_email_and_client_name(...)`;
  - comparaison stricte normalisee sur `LOWER(TRIM(email))` et `LOWER(TRIM(c.nom))`.

### Impact fonctionnel
- si l'utilisateur resoumet exactement le meme `email` et le meme `nom de compte`, le flux l'ouvre maintenant directement sur son compte existant;
- si l'un des deux champs differe, le comportement historique reste en place et un nouveau compte peut etre cree;
- le patch ne tente pas de fusion heuristique sur email seul, ni de rapprochement flou sur le nom.

### Docs touchees
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_script.php`
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`

## WWW BO `facturation_pivot` — KPI `Clients actifs` aligné sur le mois de référence — 2026-04-03

### Resume
- le KPI haut `Clients actifs` utilisait jusqu'ici le dernier mois de la plage affichée;
- en `année fiscale` ou `année civile`, cela pouvait faire lire un mois futur théorique de la plage plutot que le mois de référence sélectionné par l'utilisateur.

### Correctifs livres
- `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - ajout de `clients_kpi_month_key`;
  - en `civil` et `fiscal`, ce KPI lit maintenant `ref_month->format('Y-m')`;
  - en `month` et `last3`, la logique conserve le dernier mois de la plage courante.

### Impact fonctionnel
- sur une vue `année fiscale` ou `année civile`, `Clients actifs` reflète désormais le mois réellement sélectionné dans le filtre;
- les autres indicateurs et tableaux de période ne changent pas de sémantique dans ce patch.

### Docs touchees
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`

## WWW BO `facturation_pivot` — démos SaaS agrégées dans les taux réels — 2026-04-03

### Resume
- le reporting SaaS `facturation_pivot` exposait déjà deux volumes distincts:
  - `Demos visiteurs`
  - `Démos nvx inscrits`
- les ratios réels de conversion continuaient pourtant d'utiliser uniquement `Demos visiteurs` dans la modale de conversion et ses calculs mensuels, alors que le bloc `Objectifs` agrégeait déjà les deux sources.

### Correctifs livres
- `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - ajout de `demo_sessions_total_by_month` pour centraliser l'agrégat mensuel `demo_sessions + demo_sessions_new_users`;
  - bascule des ratios réels mensuels fondés sur les démos sur cet agrégat:
    - `Tx visiteurs -> demos`
    - `Tx demos -> inscrits`
    - `Tx demos -> clients`
  - conservation des colonnes détaillées du tableau visiteurs pour distinguer l'origine des démos affichées.

### Impact fonctionnel
- la modale ouverte depuis le taux de conversion reflète maintenant la même définition métier des démos que le bloc `Objectifs`;
- les colonnes `Demos visiteurs` et `Démos nvx inscrits` restent séparées visuellement;
- le budget et les paramètres de taux budgétaires ne changent pas dans ce patch.

### Docs touchees
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`

## GLOBAL/PLAY historique joueur — sessions reellement terminees seulement — 2026-04-02

### Resume
- la page `Historique` de l'EP remontait jusqu'ici des participations reelles bornees surtout par `cs.date <= CURDATE()`, sans relire la notion runtime `terminee`;
- cela laissait apparaitre des sessions modernes non encore finies, alors que les classements avaient deja ete durcis sur ce point.

### Correctifs livres
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - ajout de `app_joueur_historique_session_is_eligible(...)`;
  - regle appliquee a l'historique reel:
    - `Cotton Quiz` legacy `id_type_produit = 1`: `date < aujourd'hui`;
    - jeux modernes: `date <= aujourd'hui` et `app_session_edit_state_get(...).is_terminated = 1`;
  - filtrage applique dans `app_joueur_participations_reelles_get_liste(...)` avant deduplication des sources;
  - `app_joueur_participations_reelles_latest_date_get(...)` reconsomme maintenant cette liste effective pour ancrer la fenetre glissante sur la derniere session reellement affichable.

### Impact fonctionnel
- `play` n'a pas change de vue, mais `/extranet/dashboard/history` n'affiche plus une session moderne du jour ou passee tant qu'elle n'est pas runtime-terminee;
- une session moderne terminee le jour meme peut en revanche apparaitre;
- le `Cotton Quiz` legacy reste sur une heuristique date stricte, sans faux alignement sur un statut runtime inexistant.

### Docs touchees
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## DOCS EP/games — garde temporelle et bypass papier explicités — 2026-04-02

### Resume
- la doc canon couvrait déjà le fallback `future -> manage/s1`, `expirée -> agenda`, mais sans expliciter la fenêtre exacte d'ouverture `jour J / lendemain avant midi`;
- la nuance technique du parcours papier au retour `EP -> games` était décrite côté UI, pas formulée explicitement comme bypass du gating WS.

### Correctifs livres
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`
  - ajout de la règle temporelle explicite:
    - `jour J` = ouvert;
    - `lendemain de session` = encore ouvert strictement avant `12:00`;
    - sinon = expiré;
  - explicitation du cas papier:
    - sur le retour `EP -> games` en session papier, le gating WS numérique n'est pas la garde finale;
    - le flux retombe volontairement sur le rendu papier historique de confirmation au lieu d'ouvrir le gameplay.

### Docs touchees
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/HANDOFF.md`

## PLAY `Mes classements` — rendu emoji stable dans le recap organisateur — 2026-04-02

### Resume
- le recap `Participations / podiums` sous chaque organisateur utilisait deja les emojis `🏆 / 🥈 / 🥉`, mais ils pouvaient disparaitre ou mal se rendre dans l'UI EP;
- l'encodage de la vue et l'echappement HTML etaient corrects; le point faible venait de la police principale `Poppins`, qui n'assure pas un rendu emoji fiable.

### Correctifs livres
- `play/web/ep/modules/communication/home/ep_home_leaderboards.php`
  - `ep_home_leaderboards_summary_bits()` retourne maintenant des elements structures `emoji + label`;
  - le rendu separe le pictogramme du texte, dans un span dedie.
  - chaque element de recap porte maintenant une variante visuelle (`participation` ou `podium`) pour permettre un rendu plus “jeu”.
- `play/web/ep/includes/css/ep_custom.css`
  - ajout d'une stack de polices de fallback ciblee pour les emojis de ce recap (`Apple Color Emoji`, `Segoe UI Emoji`, `Noto Color Emoji`, etc.).
  - ajout d'un layout `flex-wrap` et d'un style capsule avec deux ambiances de couleur:
    - `participation`: bleu clair / progression;
    - `podium`: dore chaud / recompense.

### Impact fonctionnel
- les labels restent echappes comme avant;
- seuls les pictogrammes de podium changent de mode de rendu, avec une police capable de les afficher.

### Docs touchees
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_leaderboards.php`

## GLOBAL classements saisonniers agreges — sessions runtime reellement terminees uniquement — 2026-04-02

### Resume
- les classements saisonniers agreges utilises dans `pro` et `play` pouvaient encore compter des sessions simplement configurees ou deja ouvertes, sans garantie que la partie soit reellement terminee;
- la regle demandee etait de se baser sur l'etat DB maintenu par les glue `games` des `3` jeux, pas sur la seule presence BO d'une session non demo et complete.

### Correctifs livres
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - ajout de `app_client_joueurs_dashboard_session_is_reliably_terminated(...)`;
  - le helper reutilise `app_session_edit_state_get(...)`, donc la meme lecture DB canonique que les flows session:
    - `Bingo Musical`: termine si `phase_courante >= 4`;
    - `Blind Test`: termine si `game_status / phase_courante >= 3`;
    - `Cotton Quiz` moderne: termine si `game_status / phase_courante >= 3`;
  - exception legacy ajoutee ensuite sur validation metier:
    - `Cotton Quiz` legacy `id_type_produit = 1` est retenu si sa `date` est strictement passee;
    - le jour courant reste exclu, meme pour une session deja jouee plus tot dans la journee;
  - application de ce filtre a `app_client_joueurs_dashboard_context_compute(...)` avant la consolidation des stats, tops et leaderboards;
  - application du meme filtre a `app_client_joueurs_dashboard_period_has_leaderboard_data(...)` pour que les trimestres proposes comme exploitables reposent eux aussi sur des sessions runtime reellement terminees.

### Impact fonctionnel
- `pro` et `play` restent alimentes par le meme moteur agregateur `global`, mais les sessions encore en cours, non demarrees ou simplement configurees ne comptent plus dans les classements saisonniers;
- `Cotton Quiz` legacy `id_type_produit = 1` reste present avec sa regle historique `date < aujourd'hui`, alors que les `3` jeux modernes restent strictement bornes a leur etat runtime DB termine.

### Docs touchees
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## GAMES `ep_connect_token` prioritaire sur une identite locale existante — 2026-04-02

### Resume
- l'onglet prive validait le flow `play -> games`, mais l'onglet normal pouvait encore decrocher sans log EP visible;
- cause probable confirmee a la lecture de `register.js`: si une identite joueur locale existait deja pour cette session, le portail player faisait un `resume` local puis `return`, avant meme d'atteindre `tryAutoRegisterFromEp()`.

### Correctifs livres
- `games/web/includes/canvas/play/register.js`
  - la reprise locale par identite deja stockee ne court-circuite plus le flow quand un `ep_connect_token` est present et non finalise;
  - les branches `bingo` et `quiz/blindtest` ne font plus `resume + return` si `hasPendingEpConnectFlow()` vaut `true`;
  - ajout d'une preuve debug `ep_autoreg_resume_bypass_local_identity` pour confirmer au prochain test qu'un reliquat local a bien ete ignore au profit du flux EP.

### Cause racine
- le flux de reprise locale et le flux `EP -> games` coexistaient, mais l'ordre de priorite etait mauvais;
- en navigation normale, un reliquat `localStorage` sur la meme session pouvait etre juge suffisant pour relancer le joueur local;
- ce `return` empechait ensuite `tryAutoRegisterFromEp()` de se lancer, d'ou l'absence des logs EP et l'ecart avec l'onglet prive.

### Docs touchees
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/HANDOFF.md`

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/play/register.js`
- `node --check /home/romain/Cotton/games/web/includes/canvas/core/logger.global.js`

## GAMES observabilite flux `EP -> games` — journalisation centralisee des etapes `ep_connect_token` — 2026-04-02

### Resume
- le bootstrap player `games` est redevenu sain, mais les journaux de session ne remontaient toujours pas le detail du sous-flux `ep_connect_token`;
- sans preuve `ep_link_resolve` / `player_register` / `ep_link_finalize`, il restait impossible de dire depuis le `.jsonl` si la boucle `games -> play/signin -> games` decrochait sur la resolution bridge, l'inscription joueur ou la finalisation.

### Correctifs livres
- `games/web/includes/canvas/core/logger.global.js`
  - ajout d'un listener central sur `register/debug` pour remonter en log WS les etapes:
    - `ep_link_resolve_tx/ok/fail`
    - `ep_link_finalize_tx/ok/fail`
    - `ep_autoreg_start/submit/abort`
    - `player_register_tx/ok/fail`
    - `gate_initial_status` / `gate_poll_status`
  - ajout de la journalisation centralisee pour:
    - `PLAYER_REGISTER_UPSERT_OK`
    - `PLAYER_REGISTER_UPSERT_ERR`
    - `MISSING_PLAYER_ID`
  - niveaux ajustes pour faciliter le tri:
    - en pratique, les preuves de flux `EP -> games` restent maintenant en `debug` pour ne pas surcharger la prod;
    - l'objectif est le diagnostic cible en dev/staging sans bruit supplementaire en exploitation.

### Effet attendu
- le prochain log de session `.jsonl` doit permettre de prouver directement si le flux `EP -> games` casse sur:
  - la resolution du token de retour;
  - l'upsert joueur `games`;
  - la finalisation bridge `games_connectees`;
  - ou un simple re-affichage d'etat UI/gate.

### Docs touchees
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/HANDOFF.md`

### Verification
- `node --check /home/romain/Cotton/games/web/includes/canvas/core/logger.global.js`

## GAMES player reload avec identite locale preexistante — bootstrap `GameMeta` restaure — 2026-04-02

### Resume
- le symptome reel n'etait pas le CTA `play`, mais le rechargement du portail session `games` cote joueur quand une identite locale existait deja;
- dans ce cas, `register.js` repart bien sur le chemin de reprise (`player/ready`), mais le bootstrap player ne publiait pas `window.GameMeta` alors que plusieurs modules du runtime player continuent de s'appuyer dessus;
- effet visible confirme par les logs: reprise avec `game: ''` cote player sur `games.dev`.

### Correctifs livres
- `games/web/player_canvas.php`
  - le bootstrap player publie maintenant aussi `window.GameMeta = { slug, title }`, aligne sur l'organizer canvas;
  - le contexte joueur recharge donc le meme metadata contractuel que le reste du runtime canvas.
- `games/web/includes/canvas/core/logger.global.js`
  - `resolveGameSlug()` sait maintenant aussi relire `window.AppConfig.gameSlug` si `window.GameMeta` est absent;
  - les preuves debug/info ne retombent donc plus a `game: ''` dans ce cas de bootstrap partiel.

### Cause racine
- le player canvas injectait `window.AppConfig.gameSlug`, mais pas `window.GameMeta`;
- en reprise locale, ce manque restait latent tant que le flux n'executait que des modules bases sur `AppConfig`;
- au rechargement avec identite deja stockee, une partie du runtime / logging lisait encore `window.GameMeta?.slug`, d'ou un bootstrap incoherent et des traces `game: ''`.

### Docs touchees
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/games/web/player_canvas.php`
- `node --check /home/romain/Cotton/games/web/includes/canvas/core/logger.global.js`

## PLAY `games -> signin/signup` sessionnel — branding absent non bloquant — 2026-04-02

### Resume
- regression locale identifiee sur le point d'entree `Compte joueur Cotton` depuis le portail session `games`;
- les URLs `play/signin/public/{token}` et `play/signup/public/{token}` pouvaient fatal avant rendu quand aucun branding n'etait trouve pour la session.

### Correctifs livres
- `play/web/ep/ep_signin.php`
  - normalisation immediate du retour `app_session_branding_get_detail(...)` en tableau vide quand aucun branding session/evenement/client n'est disponible;
  - le rendu sessionnel ne tente donc plus de lire `visuel` sur une chaine vide.
- `play/web/ep/ep_signup.php`
  - meme normalisation defensive du branding sessionnel;
  - garde alignee sur `parameters` pour eviter tout acces direct a une structure absente.

### Cause racine
- le patch de branding sessionnel du 2026-03-27 supposait implicitement que `app_session_branding_get_detail(...)` renvoyait toujours un tableau;
- en pratique, ce helper renvoie encore `''` quand aucun branding n'est disponible;
- sous PHP 8, la lecture de offsets type `['visuel']['img_src']` sur cette chaine provoquait un fatal `500` avant affichage de `signin/signup`.

### Docs touchees
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`

### Verification
- `php -l /home/romain/Cotton/play/web/ep/ep_signin.php`
- `php -l /home/romain/Cotton/play/web/ep/ep_signup.php`

## PLAY `Mes classements` joueur par organisateur — 2026-04-02

### Resume
- ajout d'une nouvelle page EP `Mes classements` pour reutiliser cote joueur les classements organisateur deja calcules pour `Mes joueurs`;
- la page est limitee aux organisateurs deja lies a l'historique reel du joueur, tries du plus frequente au moins frequente;
- pour chaque organisateur, l'affichage prend le trimestre courant si le joueur y a une participation reelle, sinon le trimestre precedent.

### Correctifs livres
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - ajout du helper `app_joueur_leaderboards_get_context(...)`;
  - le helper repart maintenant de `app_joueur_linked_clients_rows_get(...)`, une vue legere des organisateurs lies au joueur sur la periode, borne par defaut aux `12 derniers mois` ancres sur la derniere activite reelle du joueur/equipe, choisit le trimestre de reference de cette derniere activite ou le precedent selon ces liens joueur -> organisateur, puis reconsomme `app_client_joueurs_dashboard_get_context(...)` pour reutiliser les leaderboards organisateur canoniques;
  - compromis 2026-04-02: cette vue legere reste fondee sur les tables stables reliees au joueur pour identifier les organisateurs lies;
  - les tableaux de classement affiches dans chaque section continuent en revanche de reutiliser `app_client_joueurs_dashboard_get_context(...)`, donc la consolidation organisateur complete moderne / legacy / runtime.
  - seuls les jeux effectivement joues par le joueur sur le trimestre retenu restent affiches dans chaque section organisateur;
  - rollback 2026-04-02: les relectures runtime `cotton_quiz_players` et `bingo_players` ont ete retirees de l'historique reel joueur pour revenir a un socle stable base sur `games_connectees`, `equipes_to_championnats_sessions` et `jeux_bingo_musical_grids_clients`;
  - `app_joueur_participations_reelles_get_liste(...)` accepte maintenant un bornage temporel optionnel pour autoriser des chargements EP progressifs;
  - ajout de `app_joueur_participations_reelles_latest_date_get(...)` pour ancrer la fenetre de l'historique EP sur la derniere activite reelle du joueur/equipe;
  - ajout de `app_joueur_participations_reelles_activity_window_get(...)` pour factoriser cette fenetre glissante et la reutiliser aussi pour les KPI home;
  - optimisation perf: contexte identitaire et historique reel caches a l'echelle de la requete, et possibilité de lire l'historique sans recalculer les badges quand seule une synthese est necessaire.
- `play/web/ep/modules/communication/home/ep_home_history.php`
  - la page `Historique` charge maintenant par defaut les `12 derniers mois` d'activite reelle;
  - si des participations plus anciennes existent, un CTA `Charger plus` etend la fenetre de `12 mois` supplementaires a chaque clic;
  - la vue met maintenant en cache local les details `session / client / photo / jeu / equipe` au lieu de relancer ces lectures pour chaque carte.
- `play/web/ep/modules/communication/home/ep_home_index.php`
  - les KPI relisent maintenant la meme fenetre glissante `12 derniers mois d'activite reelle` que l'historique.
- `play/web/ep/modules/compte/authentification/ep_authentification_script.php`
  - garde ajoute sur le cookie `CQ_admin_gate_joueur_id`;
  - si `app_joueur_get_detail(...)` ne remonte rien a l'initialisation de session, l'EP ne fatal plus et renvoie proprement vers `signin`.
- `play/web/.htaccess`
  - ajout de la route `/extranet/dashboard/leaderboards`.
- `play/web/ep/ep.php`
  - ajout de l'entree de navigation `Mes classements` dans le menu lateral EP.
  - si la session joueur active ne resout plus de detail joueur, la session est purgee et l'utilisateur est renvoye vers `signin`.
  - le flux normal de log de consultation EP `log_ajouter(...)` a ete remis a niveau apres diagnostic.
- `play/web/ep/ep_signin.php`
  - le branding de session est maintenant garde lorsqu'aucun contexte branding n'est disponible.
- `play/web/ep/modules/communication/home/ep_home_leaderboards.php`
  - nouvelle vue EP avec une section par organisateur, badge jeu, tableaux `Top 10` et lien simple vers l'agenda filtre de l'organisateur.

### Docs touchees
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`
- `documentation/SITEMAP.md`
- `documentation/SITEMAP.txt`
- `documentation/SITEMAP.ndjson`
- indexes regeneres via `npm run docs:sitemap`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/ep.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_leaderboards.php`
- `php -l /home/romain/Cotton/play/web/.htaccess`
- `npm run docs:sitemap`

## PRO Bibliothèque Quiz — save global des séries avec images sans double upload — 2026-04-02

### Resume
- dans l'edition d'une série quiz existante, le save global des questions avec image ne relance plus un second upload redondant après le write path principal;
- le flux garde le même comportement métier, mais évite maintenant de doubler les uploads et les writes associés quand plusieurs questions image sont enregistrées d'un coup.

### Correctifs livres
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - suppression du second upload JS base64 dans `submitQuickEditForm()` pour les questions quiz avec `support_image_file`;
  - le save n'enchaine plus deux uploads pour la meme image.
- `pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_content_ajax.php`
  - le mode AJAX `update_item` applique maintenant lui aussi l'upload `support_image_file` côté serveur pour les questions quiz avec support image;
  - le flux garde ainsi un seul upload effectif par image, mais ne perd plus le remplacement de visuel.
- `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - après lecture des logs `pro`, le cas en échec a été identifié: la colonne SQL `questions.jour_associe` refusait `NULL`; le helper écrit maintenant `''` quand aucun jour associé n'est attendu.

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/pro/HANDOFF.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_content_ajax.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`

## Branding `games/global` — reset session avec suppression compte conditionnelle — 2026-04-01

### Resume
- depuis la modale organizer `games`, le CTA `Revenir au design d'origine du jeu` peut maintenant aussi supprimer le branding compte par defaut;
- cette suppression compte n'a lieu que s'il existe un branding compte et qu'il est identique au design effectif de la session;
- avant suppression, les futures sessions deja programmees qui heritaient encore de ce branding compte sont figees en branding session.
- le message `Les prochaines sessions...` n'est affiche dans la confirmation que si un preview backend confirme que le branding compte sera reellement supprime.

### Correctifs livres
- `games/web/includes/canvas/core/session_modals.js`
  - appel prealable a `delete_preview` pour connaitre l'impact reel du reset;
  - confirmation enrichie pour annoncer l'impact sur les prochaines sessions et la conservation sur les sessions deja programmees seulement quand la suppression compte est effective;
  - dans SweetAlert, la mention conditionnelle est rendue en petit, italique, avec un leger espacement au-dessus;
  - ajout du flag `cascade_client_branding_if_matching=1` sur le delete branding session.
- `global/web/app/modules/general/branding/app_branding_ajax.php`
  - ajout de `action=delete_preview`;
  - comparaison de signature branding `couleurs/police/logo/visuel`;
  - suppression compte conditionnelle;
  - duplication prealable du branding compte vers les futures sessions qui l'heritaient encore.

### Docs touchees
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_ajax.php`
- `node --experimental-default-type=module --check /home/romain/Cotton/games/web/includes/canvas/core/session_modals.js`

### Suite possible
- si un branding par type de jeu doit etre introduit plus tard pour toutes les portees (`session/evenement/reseau/client`), voir `documentation/notes/branding_par_type_de_jeu.md`;
- cette evolution demandera une dimension `id_type_produit` cote `global`, avec fallback vers les brandings globaux existants.

## Organizer `games` — QR remote papier hors session ferme dans la modale d'options — 2026-04-01

### Resume
- la modale `Options de jeu` de l'organizer `games` n'ouvre plus automatiquement le QR remote quand une session papier n'est pas encore ouverte;
- le correctif cible uniquement l'auto-ouverture UI: le garde de clic existant dans `boot_organizer.js` reste en place.

### Correctifs livres
- `games/web/includes/canvas/core/session_modals.js`
  - ajout d'une garde `canAutoExpandPilotQR()` basee sur `ClientSessionMeta.isOpen`;
  - `setPilotQRExpanded()` n'ouvre `#pilotQRWrap` que si la session est a la fois en papier et ouverte.

### Docs touchees
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/games/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `node --experimental-default-type=module --check /home/romain/Cotton/games/web/includes/canvas/core/session_modals.js`

## PRO `Mes joueurs` organisateur ABN/PAK/CSO non TdR — 2026-04-01

### Resume
- ajout d'une V1 de dashboard `Mes joueurs` cote PRO pour les comptes organisateurs `ABN` / `PAK` / `CSO` non TdR;
- la surface est disponible via `/extranet/players`, masquee de la navigation TdR et bloquee a l'acces direct pour les comptes reseau;
- la page affiche maintenant un titre de contenu `Joueurs et classements` dans un bandeau `.after-header` au-dessus des blocs.
- au clic sur `Mes joueurs`, la page s'affiche maintenant immediatement avec un spinner seul, puis charge uniquement le fragment dashboard de facon asynchrone avant de reveler les blocs.
- le chargement asynchrone de `Mes joueurs` repose maintenant sur `XMLHttpRequest` plutot que sur `fetch(...).finally(...)`, pour eviter un bloc spinner persistant sur des navigateurs / contextes JS moins permissifs.
- la sortie fragment cote serveur est maintenant declenchee a la fois par `async=1` et par l'en-tete `X-Requested-With: XMLHttpRequest`, pour rester robuste meme si la query n'est pas remontee proprement par le routing.
- le bloc de chargement `Mes joueurs` se masque maintenant via bascule de classes Bootstrap (`d-flex -> d-none`), afin d'eviter qu'une utilitaire `display:flex !important` le laisse visible apres l'injection des donnees.
- le chat Brevo est maintenant desactive sur `Mes joueurs`, en reutilisant la garde existante dans `ec.php` plutot qu'en ajoutant une logique parallele.
- si la requete async de `Mes joueurs` renvoie un fragment vide, la vue ne laisse plus un ecran blanc et bascule sur le message d'etat vide.
- le changement d'annee dans le filtre de classements rehydrate maintenant correctement la liste des trimestres meme quand les options d'une annee sont serialisees en objet JSON indexe, ce qui evite un retour force a la periode par defaut.
- le filtre `annee + trimestre` de `Classements par jeu` se met maintenant a jour automatiquement a chaque changement de selection, sans CTA ni lien de reinitialisation, via un rechargement XHR cible de la seule zone classements.
- le rechargement cible des classements annule maintenant proprement une requete trimestre precedente et remplace toujours l'instance courante du fragment, pour eviter les erreurs JS de type `outerHTML` sur un noeud deja detache.
- les listes `Annee` et `Trimestre` sont maintenant calculees a partir des periodes qui alimentent reellement les classements, ce qui evite qu'une selection valide retombe sur la periode par defaut.
- la detection des trimestres exploitables relit maintenant les memes sources que les classements reels eux-memes, y compris les runtimes recents non EP (`cotton_quiz_players`, `blindtest_players`, `bingo_players`) et le fallback legacy `championnats_resultats` pour `Cotton Quiz`.
- la mention Bingo sur donnees historiques incompatibles est maintenant rendue inline, en `text-muted` italique, plutot qu'en alerte encadree.
- les blocs KPI de la synthese `Mes joueurs` utilisent maintenant un fond bleu leger derive de `#43B6E5`, une bordure teintee et une ombre discrete pour mieux ressortir.
- le detail par jeu est maintenant integre directement dans les KPI `Sessions organisees` et `Participants inscrits`; le bloc parent de synthese est transparent et l'ancien tableau de detail a ete retire.
- en mode sombre, les KPI de synthese forcent maintenant des couleurs de texte claires et un contraste plus fort sur le fond des cartes pour garder le detail lisible.
- les titres des KPI de synthese (`Sessions organisees`, `Participants inscrits`, `Top joueur`, `Top equipe`, `Top jeu`) conservent maintenant explicitement le marquage visuel `color-4`.
- les classements affichent maintenant un rang de type `competition`: des lignes au meme score partagent la meme position.
- quand un bloc `Bingo Musical` est rendu sans aucune ligne de classement mais avec un avertissement d'historique incompatible, ce message inline est maintenant affiche aussi dans la carte.
- dans ce cas Bingo sans aucune ligne recuperable, le message affiche devient maintenant `Les donnees de cette periode ne permettent pas d'afficher le classement.`, tandis que le message historique incompatible reste reserve au cas d'un classement partiel.
- le compteur global `Sessions organisees` et son detail par jeu restent maintenant alignes sur le reporting BO: les sessions papier non demo et completes sont comptees meme sans participation remontee, tandis que les sessions numeriques sans participation fiable restent exclues.

## Sessions agenda `pro` — historisation des sessions terminées — 2026-04-01

### Resume
- l'agenda `pro` ne dépend plus uniquement de la date pour basculer une session en historique;
- pour les jeux runtime modernes, une session déjà `terminée` remonte maintenant dans `Archives` même si sa date n'est pas encore passée.

### Correctifs livres
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `app_session_edit_state_get()` expose désormais aussi `is_terminated` et `runtime_status`;
  - ajout de `app_session_is_archive()` et `app_session_display_chronology_get()` pour fusionner chrono date + état runtime;
  - seuils de fin alignés sur `games`: `quiz/blindtest >= 3`, `bingo >= 4`.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
  - la construction des listes `Mon agenda` / `Archives` filtre maintenant aussi les sessions sur leur état runtime, et plus seulement sur la date SQL;
  - le compteur d'archives inclut aussi les sessions terminées avant la date.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - la carte agenda réutilise la chrono d'affichage effective pour appliquer `card-archive`, les libellés participants et le CTA de bas de carte.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - la fiche détail réutilise la même logique d'historisation effective pour ses blocs de participants, de test et de suppression.

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

### Resume
- ajout d'une V1 de dashboard `Mes joueurs` cote PRO pour les comptes organisateurs `ABN` / `PAK` non TdR;
- la surface est disponible via `/extranet/players`, masquee de la navigation TdR et bloquee a l'acces direct pour les comptes reseau;
- la vue n'embarque pas de logique metier lourde: un helper `global` unique prepare toute l'agregation.

### Correctifs livres
- `pro/web/.htaccess`
  - ajout de la route `/extranet/players`.
- `pro/web/ec/ec.php`
  - nouvelle condition d'affichage `Mes joueurs` basee sur `flag_client_reseau_siege=0` + pipeline `ABN/PAK`, placee sous `Mon agenda`;
  - blocage de la surface pour les contacts animateurs.
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - nouvelle page PRO avec `Membre depuis` integre au bloc `Synthese`, tops affiches en bas de cette synthese, puis bloc `Classements par jeu` embarquant son propre filtre de periode et un lien simple `Réinitialiser` vers le defaut `1 an glissant -> aujourd'hui`;
  - chaque classement affiche maintenant, sous `Top 10 des joueurs / equipes sur la periode`, une mention `text-muted` rappelant la regle d'attribution des points selon le jeu;
  - le tableau de synthese par jeu est centre horizontalement dans le bloc `Synthese` et affiche aussi `Meilleure session`, soit le nb max de participants connectes observes sur une meme session pour chaque jeu;
  - les titres des blocs de classement sont maintenant surlignes avec les couleurs dediees a chaque jeu, en reutilisant les classes UI existantes de `pro` et la meme couleur de texte que les CTA du portail bibliotheque; le resultat `Top jeu` reprend aussi ce badge;
  - `Top equipe` est masque si le client n'a aucun quiz sur sa periode d'activite, `Top joueur` est masque s'il n'a aucun `Blind Test` / `Bingo Musical`, et les libelles passent au pluriel en cas d'ex aequo en tete;
  - le compteur principal porte maintenant une mention `text-muted` précisant que les joueurs papier non inscrits ne sont pas comptés, mais seulement si la periode contient au moins une session papier.
- `global/web/app/modules/entites/clients/app_clients_functions.php`
  - ajout de `app_client_joueurs_dashboard_get_context(...)`;
  - la synthese globale du dashboard est maintenant mise en cache en session par client/jour; quand le filtre change, seul le scope classements est recalcule;
  - le filtre des classements est maintenant pilote par `annee + trimestre civil`, avec options bornees par la date d'adhesion;
  - tops recalcules sur toute la periode d'activite, et classement seul borne par le filtre;
- les classements sont maintenant tries sur un score agrege:
  - `500 / 300 / 200` points au total pour les rangs `1 / 2 / 3` en quiz / blind test;
  - `500 / 300 / 200` points au total pour les gains de phase `Bingo / Double ligne / Ligne` en bingo;
  - `100` points seulement pour une participation sans podium ni gain de phase;
  - le nb de participations reste conserve en annexe;
  - le rattachement des gains de phase bingo privilegie maintenant `bingo_phase_winners.player_id_key` quand cette colonne existe, avec fallback sur les ids runtime historiques;
  - pour les sessions legacy sans bridge EP historique, les bonus de classement se recollent aussi par pseudo runtime normalise, sur la meme logique conservative que les participations;
  - quand une meme session legacy remonte a la fois une ligne EP et une ligne runtime au meme pseudo, ce fallback conserve desormais la premiere identite connue de la session pour que le bonus se rattache a la ligne leaderboard attendue.
  - la meme priorite s'applique aussi maintenant a l'ingestion des participations runtime legacy, pour eviter une seconde ligne de classement au meme pseudo quand une identite de session existe deja.
  - des qu'une session dispose deja de joueurs runtime sur un jeu, ce runtime devient aussi la source de verite pour compter les participations reelles; les lignes bridge/EP sans liaison runtime ne servent plus qu'au rattachement d'identite.
  - pour `Cotton Quiz` historique pre-runtime, les bonus podium sont maintenant aussi relus via `championnats_resultats.position`; aucun equivalent `Bingo` legacy aussi net n'a ete prouve dans le schema audite a ce stade.
  - en consequence, le classement `Bingo Musical` conserve maintenant les sessions runtime scorables de la periode et n'exclut que les sessions historiques sans gagnants de phase recuperables de facon fiable; la vue n'affiche un message explicite que dans ce cas partiel.

### Regles de donnees V1
- `Membre depuis`:
  - plus ancienne `ecommerce_offres_to_clients.date_debut` visible pour le client, avec fallback `clients.date_ajout` si aucune offre n'est historisee.
- Sessions incluses:
  - `championnats_sessions.id_client = client`;
  - regle alignee sur le reporting BO: `flag_session_demo = 0` et `flag_configuration_complete = 1`;
  - la synthese est bornee a toute la periode d'activite (`member_since -> today`);
  - les tops sont eux aussi bornes a toute la periode d'activite;
  - seuls les classements sont bornes par la periode filtree.
- Sources joueurs fiables:
  - joueurs connectes EP: `championnats_sessions_participations_games_connectees`;
  - bingo EP legacy: `jeux_bingo_musical_grids_clients`;
  - runtime non EP joueurs: `blindtest_players`, `bingo_players`;
  - runtime quiz: `cotton_quiz_players`, traite comme source equipe;
  - equipes quiz: `equipes_to_championnats_sessions`.
- Compteur principal:
  - `Participants connectes (joueurs & equipes)` = joueurs connectes fiables + equipes fiables sur la periode.
- Regle tops:
  - `Top joueur` / `Top equipe` ne remontent un resultat que s'il existe un vrai leader;
  - un ex aequo en tete peut afficher jusqu'a 3 noms s'ils restent devant les autres;
  - si tous les comptes de participations sont identiques, la valeur affichee est `-`.
- Etats vides:
  - si aucune donnee exploitable n'existe, la page affiche un message explicite;
  - si la synthese existe mais que la periode choisie ne permet aucun top ni classement, un message explicite est affiche sous le filtre.
- Exclusions:
  - aucune lecture de `championnats_sessions_participations_probables`;
  - aucun classement joueur force sur le quiz: la V1 ne sort qu'un classement equipes pour `Cotton Quiz`.

### Docs touchees
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/HANDOFF.md`
- `documentation/CHANGELOG.md`

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/ec.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

### TODO
- valider en environnement avec donnees reelles que les tables runtime `*_players` exposent bien la colonne optionnelle `player_id` la ou attendue;
- si une V2 perf est requise, prevoir une vraie materialisation journaliere dediee au dashboard plutot qu'un recyclage des helpers BO live.

## Sessions quiz organizer `games`: diagnostic persistance format + garde polling réelle — 2026-03-31

### Resume
- le bridge `games` recevait bien les `session_update` organizer, mais les logs disponibles ne permettaient pas de savoir si le switch quiz était refusé, ignoré ou effectivement écrit;
- en parallèle, le polling `session_meta_get` exposait encore `digitalSwitchAllowed=true` en dur, ce qui pouvait laisser l'UI organizer dans un faux état `compatible`.

### Correctifs livres
- `games/web/includes/canvas/php/quiz_adapter_glue.php`
  - instrumentation ciblée des writes de format quiz avec logs explicites sur:
  - le flag courant;
  - le flag cible;
  - la garde `papier -> numérique`;
  - le `rowCount()` de l'`UPDATE championnats_sessions.flag_controle_numerique`.
- `games/web/includes/canvas/php/boot_lib.php`
  - `session_meta_get` calcule maintenant la vraie compatibilité quiz en mode papier quand la session n'est pas verrouillée;
  - l'organizer reçoit donc des métadonnées de garde cohérentes avec le serveur quiz.
 - `games/web/games_ajax.php`
  - instrumentation bridge supplémentaire sur les handlers canvas en échec (`INVALID_HANDLER_RESPONSE`, `HANDLER_ERROR`);
  - permet de savoir si le `500` survient avant les logs quiz spécifiques.
 - `games/web/includes/canvas/php/boot_lib.php`
  - logs `game_api_dispatch` `CALL/FAIL` pour confirmer le handler effectivement invoqué sur le serveur.

### Verification
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/games_ajax.php`

## Sessions quiz: garde `papier -> numérique` alignée entre `pro` et `games` — 2026-03-31

### Resume
- la garde quiz côté `pro/global` n'appliquait pas exactement la même règle que `games` pour autoriser le passage `papier -> numérique`;
- `games` autorisait le switch dès qu'une question avait sa réponse et au moins une fausse proposition valide;
- `global` en exigeait encore `2`, ce qui pouvait refuser côté `pro` un quiz déjà jugé compatible dans `games`.

### Correctifs livres
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - réalignement de `app_session_quiz_digital_guard_get()` sur la règle `games`;
  - le helper commun ne demande plus qu'une seule fausse proposition valide distincte pour compter une question comme compatible numérique.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## Sessions pro/games: verrou format hors `En attente` + synchro organizer/detail — 2026-03-31

### Resume
- le format de jeu (`papier` / `numérique`) reposait bien sur un champ partagé, mais la sécurité métier n'était pas homogène entre `pro` et `games`;
- un changement depuis `pro` ne réalignait pas automatiquement un organizer `games` déjà ouvert;
- côté `pro`, la fiche détail restait éditable alors qu'une session officielle non démo n'était plus `En attente`.

### Correctifs livres
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - ajout d'un helper central d'état d'édition de session (`app_session_edit_state_get()`).
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - nouveau read path `session_sync_state`;
  - blocage serveur des writes `session_setting`, `session_theme` et `session_quiz_slot_delete` hors `En attente`.
- `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
  - redirection vers la fiche détail si la session est déjà verrouillée;
  - polling léger de resynchro si le format change depuis `games`.
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - fiche détail en consultation seule hors `En attente`, avec message explicite et suppression des CTA d'édition/test;
  - polling léger pour recharger la vue si `games` modifie l'état ou le format.
- `games/web/includes/canvas/php/boot_lib.php`
  - helper runtime `canvas_session_format_guard_get()` + action `session_meta_get`.
- `games/web/includes/canvas/php/quiz_adapter_glue.php`
- `games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `games/web/includes/canvas/php/bingo_adapter_glue.php`
  - write paths format désormais bloqués hors `En attente`.
- `games/web/includes/canvas/core/api_provider.js`
- `games/web/includes/canvas/core/boot_organizer.js`
  - organizer `games` resynchronisé par polling ciblé avec `pro`, sans reload complet de page.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - le 500 observé sur `dashboard` venait d'un second bloc dupliqué `app_session_participation_probable_*`, désormais supprimé

## New_EJ — Agenda/home EP: harmonisation des cartes session — 2026-03-30

### Resume
- les cartes session partagées entre la home joueur EP et l’agenda utilisaient encore des visuels de hauteurs variables, des espacements un peu irréguliers et un CTA `J'accède au jeu` visuellement plus lourd que `Je participe`;
- le composant est maintenant resserré et plus homogène, sans changer les write paths ni les règles de participation;
- les messages de confirmation sont reformulés dans un ton plus souple, côté joueur comme côté équipe.

### Correctifs livres
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - ajout d’un wrapper visuel dédié pour imposer un cadrage uniforme des images sur les cartes session;
  - rééquilibrage léger des blocs date / badge jeu / méta / lieu;
  - reformulation des messages de confirmation de participation en wording plus doux;
  - application d’un CTA `J'accède au jeu` plus compact sur les cartes signalées;
  - ajustement complémentaire du bloc d’actions en `mt-3 mb-2`;
  - les cartes de dashboard injectent maintenant `?back_to=home` dans l'URL de détail;
  - les cartes agenda injectent maintenant aussi les filtres actifs (`département/pays`, `organisateur`, `jeu`) pour reconstituer le retour.
  - les CTA `Je participe` / `Mon équipe participe` des cartes continuent d'ouvrir la fiche détail, en réembarquant le contexte de retour dans leur `return_url`.
- `play/web/ep/includes/css/ep_custom.css`
  - ajout du cadrage stable des visuels de carte avec `aspect-ratio` + `object-fit: cover`;
  - homogénéisation des espacements internes et du footer des cartes;
  - allègement du bouton secondaire `J'accède au jeu`, avec couleur dérivée des variables jeu déjà exposées;
  - ajout d’un léger état hover de carte pour renforcer la lisibilité sans casser le rendu existant;
  - texte du CTA `J'accède au jeu` légèrement renforcé pour gagner en lisibilité;
  - texte et flèche du CTA secondaire harmonisés en `#240445` sur cartes et détail;
  - ajout d'un style partagé pour les boutons d'inscription, réutilisé sur cartes et détail;
  - ajout du style léger du lien de retour de la fiche détail, avec rouge `play` au repos et bleu au hover;
  - masquage du lien de retour sur mobile.
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - les CTA `Mon équipe participe` / `Je participe` du détail basculent aussi sur ce style commun;
  - le mapping couleur local de la flèche vers le bas couvre maintenant aussi `Cotton Quiz` et `Bingo Musical`, en plus de `Blind Test`;
  - retrait du rendu local du lien de retour, désormais porté par le shell pour un placement plus juste;
  - tous les formulaires POST de la fiche détail réutilisent maintenant l'URL courante complète comme `return_url`, pour conserver le contexte `home` / `agenda filtré` après inscription, désinscription ou changement d'équipe.
- `play/web/ep/ep.php`
  - ajout du lien léger de retour directement dans la vraie ligne du header, à gauche sur la même rangée que l'avatar;
  - label adapté au référent interne (`Accueil` ou `Agenda`) avec fallback agenda;
  - prise en charge d'un contexte explicite `back_to=home` pour fiabiliser le retour depuis la home;
  - reconstruction de l'URL agenda avec ses filtres actifs quand le détail a été ouvert depuis une liste filtrée;
  - le lien de retour reste maintenant cohérent même après un rechargement post-action de la fiche détail, puisque le contexte `back_to` n'est plus perdu.

### Docs touchees
- `canon/repos/play/README.md`
- `canon/repos/play/TASKS.md`
- `CHANGELOG.md`
- `HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `php -l /home/romain/Cotton/play/web/ep/ep.php`

## New_EJ — EP session s2: partage simplifié et consolidé mobile — 2026-03-30

### Resume
- l'écran EP de confirmation de participation `.../games/session/inscription/manage/s2/...` n'affiche plus le bloc de partage à wrapper déroulant;
- le rendu garde désormais un seul point d'entrée centré sous le message `Merci, l'organisateur est prévenu ...`, sous forme d'un vrai bouton `Invite tes amis` avec icône intégrée;
- le comportement est unifié entre desktop et mobile:
  - si `navigator.share()` est disponible, le bouton ouvre le partage natif;
  - sur desktop, le clic ouvre à nouveau les options `Facebook`, `WhatsApp`, `Mail`, `Copier le lien`;
  - si le partage natif échoue, le fallback recopie automatiquement le lien.
- sur mobile, le bouton garde son libellé `Invite tes amis` avec un format un peu plus large et plus lisible.

### Correctifs livres
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - ajout d'un garde-fou de routing pour `games_account_join`:
    - session future non ouverte: retour EP vers `manage/s1/{token}` pour prévenir l'organisateur;
    - session expirée/non ouverte: retour EP vers l'agenda joueur au lieu d'un rebouclage vers `games`;
    - session ouverte: maintien du pont normal `EP -> games`.
- `games/web/player_canvas.php`
  - adaptation du texte du bloc `Compte joueur Cotton` selon l'état de la session:
    - future non ouverte: incitation à prévenir l'organisateur;
    - expirée/non ouverte: incitation à s'inscrire aux prochaines sessions;
    - session effectivement ouverte: maintien de la promesse standard orientée stats et historique.
  - ajout d'une zone de statut dédiée dans le bloc `Compte joueur Cotton` pour le retour `EP -> games` au jour J.
- `games/web/includes/canvas/play/register.js`
  - au jour J en `NO_MASTER`, la promesse du bloc `Compte joueur Cotton` devient maintenant `Inscris-toi dès maintenant ... sécuriser ta participation ...`;
  - hors `NO_MASTER`, cette promesse revient au texte serveur standard pour ne pas polluer le cas session réellement ouverte.
  - le message `Compte joueur connecté...` n'est plus injecté dans le bloc pseudo;
  - quand un `ep_connect_token` est présent, le bloc `Compte joueur Cotton` masque son texte/CTA et affiche un message dédié:
    - `Blindtest` / `Bingo`: confirmation de l'inscription du joueur;
    - `Quiz`: confirmation de l'inscription de l'équipe avec mention du joueur.
  - ce message dédié ne s'affiche que dans l'état `NO_MASTER` (jour J, partie pas encore ouverte) et reste masqué dès que la session est réellement ouverte.
  - au retour de `play` avec `ep_connect_token` sur une session encore fermée, le contexte EP est maintenant résolu aussi en `NO_MASTER`, ce qui garde le formulaire pseudo fermé et affiche bien le message de confirmation dans le bloc compte joueur.
  - correction d'une régression JS: `updateEpConnectNote('pending')` est désormais appelé après l'initialisation de `currentUiState`, ce qui évite la `ReferenceError` au chargement.
  - pour une session papier, l'auto-inscription issue d'EP réutilise maintenant le rendu historique papier:
    - formulaire pseudo masqué;
    - message de confirmation contextualisé joueur/équipe dans la zone papier;
    - bouton `Se désinscrire` conservé comme CTA principal.
    - le bloc `Compte joueur Cotton` est masqué sur ce seul parcours pour éviter de reproposer des CTA de connexion/création déjà sans objet.
    - ce rendu papier est désormais aussi appliqué dès le retour `EP -> games` en `NO_MASTER` le jour J, sans laisser visible le panneau d'attente fermé.
- `games/web/includes/canvas/php/ep_account_bridge.php`
  - le resolve bridge renvoie désormais aussi `player_name` et `team_name` pour permettre ce wording contextualisé.
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - remplacement du pattern `mention + bouton rond` par un vrai CTA `Invite tes amis` avec icône intégrée;
  - injection du slug jeu dans le bloc de partage pour piloter la teinte du CTA par jeu;
  - ajout d'un mapping explicite pour `blind-test`, utilisé par les flèches SVG et le partage sans toucher aux couleurs historiques `quiz/bingo`, avec base lime + dérivé visuel plus doux;
  - restauration du menu desktop `Facebook / WhatsApp / Mail / Copier le lien`;
  - ajout d'une mention légère `Rendez-vous sur place le {date} ...` juste sous le message de confirmation de participation;
  - remplacement du bouton `J'annule ...` par un lien texte qui soumet le même formulaire POST historique;
  - passage à une icône image dédiée, ouverture `Mail` dans un nouvel onglet, ajustement du JS mobile/desktop, et correction du chemin absolu de l'icône via capture explicite de `$conf` dans la closure.
- `play/web/ep/includes/css/ep_custom.css`
  - ajout des classes couleur explicites `color/bg-color` pour `blind-test` uniquement;
  - recentrage du bloc de partage et refonte visuelle du CTA en bouton horizontal texte + icône;
  - réduction légère de la taille du bouton et de l'icône;
  - teinte du contour et de la pastille alignée sur la couleur du jeu avec fallback par défaut, et variante dédiée `Blind Test`;
  - ajout du style discret du lien d'annulation;
  - ajout du style léger de la note de rendez-vous sous la confirmation;
  - adaptation responsive mobile pour garder un bouton compact et lisible;
  - ajout du style du panneau d'options desktop et agrandissement léger du bouton sur mobile;
  - suppression de l'espace réservé sous le bouton tant qu'aucun message de feedback n'est affiché.

### Docs touchees
- `canon/repos/play/README.md`
- `CHANGELOG.md`
- `HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

## New_EJ — Home EP: KPI cliquables style `ec` + badges d'historique session — 2026-03-30

### Resume
- la home joueur EP garde ses 4 KPI, mais leurs footers d'action sont maintenant rapprochés du rendu `ec`, avec accent rouge EP, fond légèrement grisé et séparation haute visible;
- chaque carte KPI home est désormais entièrement cliquable, sans dépendre uniquement du CTA du footer;
- la page `/extranet/dashboard/history` affiche maintenant des badges de résultat par session, limités au podium pour `Quiz` / `Blindtest` et aux phases gagnées pour `Bingo`;
- les messages de participation probable EP sont maintenant contextualisés:
  - `Blindtest` / `Bingo`: confirmation explicite de la participation du joueur;
  - `Quiz`: confirmation de la participation de l'équipe, avec le nom d'équipe quand il est connu, et libellé d'annulation dédié.
- l'écran `.../games/session/inscription/manage/s2/...` ouvre maintenant le partage natif sur mobile compatible, et propose sur desktop un menu simple `Facebook`, `WhatsApp`, `Mail`, `Copier le lien`; le repli minimal reste `Copier le lien` si le partage natif n'est pas disponible.
- le CTA de partage EP utilise maintenant l'icône Bootstrap `bi-share` avec accent rouge EP;
- sur mobile, seul le pictogramme rouge centré reste visible;
- sur desktop, le CTA affiche l'icône centrée avec le message `Partage l'info !`.

### Correctifs livres
- `play/web/ep/modules/communication/home/ep_home_index.php`
  - les cartes KPI home exposent un lien overlay pour rendre tout le bloc cliquable.
- `play/web/ep/includes/css/ep_custom.css`
  - restylage des footers KPI home dans un rendu plus proche des footers `ec`;
  - correction de la bordure haute malgré le `border-top:none !important` du socle commun;
  - ajout du style des badges d'historique session.
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - enrichissement de `app_joueur_participations_reelles_get_liste()` avec les identités bridge/runtime et un tableau `history_badges`;
  - calcul des badges:
    - `Quiz` / `Blindtest`: `🏆 Gagnant`, `🥈 2ème place`, `🥉 3ème place` uniquement;
    - `Bingo`: badges `🥉 Ligne`, `🥈 Double ligne`, `🏆 Bingo` selon les phases gagnées;
    - fallback `quiz_legacy` conservé via `championnats_resultats`.
- `play/web/ep/modules/communication/home/ep_home_history.php`
  - affichage des badges quand `history_badges` est non vide.
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - wording de confirmation/annulation ajusté dans les cartes session EP;
  - `Quiz`: résolution des équipes du joueur déjà signalées sur la session pour afficher le bon message.
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - wording de confirmation/annulation ajusté dans la vue de gestion de participation;
  - `Quiz`: usage du nom d'équipe courant dans le message de confirmation;
  - ajout du bloc de partage `s2` reposant sur l'URL publique `www` de la session et sur `navigator.share()` quand disponible.
- `play/web/ep/includes/css/ep_custom.css`
  - ajout du style du bloc de partage EP.

### Docs touchees
- `canon/repos/play/TASKS.md`
- `canon/repos/play/README.md`
- `canon/repos/global/TASKS.md`
- `CHANGELOG.md`
- `HANDOFF.md`

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_history.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `npm run docs:sitemap`

## New_EJ — Signup joueur: mail de bienvenue aligné sur `PLAYER_ALL_J0` — 2026-03-28

### Resume
- le signup joueur EP créait bien les comptes, mais le mail de bienvenue passait encore par les anciens templates Brevo `403/426`;
- le flux est maintenant aligné sur le template AI Studio joueur `PLAYER_ALL_J0`, sans modifier le code `ai_studio`.

### Correctifs livres
- `play/web/ep/modules/compte/joueur/ep_joueur_script.php`
  - les deux chemins d'envoi post-signup (`standard` et `session_join`) passent maintenant par `app_ai_studio_email_transactional_send_by_code('PLAYER_ALL_J0', ...)`;
  - un log `dev` `[ep_joueur_script][signup_email_fail]` trace le retour brut du webhook en cas d'échec.

### Verification
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/joueur/ep_joueur_script.php`

## New_EJ — Equipes EP: invitation joueur par email V1 — 2026-03-27

### Resume
- la vue dédiée équipe permet maintenant d'inviter un joueur par email;
- le flux réutilise le socle historique `equipes_joueurs` + token d'invitation, mais avec un template transactionnel AI Studio dédié;
- la V1 est suffisante pour tester le vrai circuit d'envoi sans attendre un template final.

### Correctifs livres
- `play/web/ep/modules/compte/equipe/ep_equipe_form.php`
  - le bloc `Inviter un joueur` est maintenant actif dans la vue dédiée équipe.
- `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - ajout du mode `equipe_inviter_joueur` et des flashes de retour.
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - ajout d'un helper de préparation/envoi d'invitation équipe;
  - validation email + garde `moins de 5 joueurs`;
  - création du joueur si besoin;
  - ajout de la liaison à l'équipe;
  - si joueur existant: email vers `signin`;
  - si nouveau joueur: génération d'un `pwd_token`, `flag_invitation=1`, puis email vers `signin/reset/{token}`.
- `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`
  - ajout du template provisoire `ALL_ALL_PLAYER_TEAM_INVITATION`.
- `play/web/ep/ep_signin.php`
  - le wording du parcours token invitation parle maintenant bien d'`espace joueur`.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_form.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`
- `php -l /home/romain/Cotton/play/web/ep/ep_signin.php`
- `php -l /home/romain/Cotton/global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`

## New_EJ — Equipes EP: vue dédiée de gestion + invitation préparée — 2026-03-27

### Resume
- la gestion des équipes joueur ne passe plus par des actions secondaires dans la liste `Pseudo / Equipes`;
- la page liste devient une entrée sobre vers une vue dédiée par équipe;
- le chantier invitation est préparé dans cette vue, mais non branché pour l'instant.

### Correctifs livres
- `play/web/ep/modules/compte/equipe/ep_equipe_view.php`
  - suppression de la modale listant les joueurs liés;
  - suppression de l'action de suppression inline dans les lignes d'équipe;
  - les noms d'équipe renvoient maintenant vers `/extranet/team/profile/manage?id_equipe=...`.
- `play/web/ep/modules/compte/equipe/ep_equipe_form.php`
  - la route `manage` sert maintenant aussi de vue dédiée de gestion quand `id_equipe` appartient au joueur;
  - affichage de la liste des joueurs liés à l'équipe;
  - affichage d'un bloc `Inviter un joueur` si le nombre de joueurs liés est strictement inférieur à `5`;
  - l'action bas de page porte maintenant `Quitter l'équipe` si d'autres joueurs restent liés, sinon `Supprimer l'équipe`.
- `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
  - après création d'équipe, redirection vers la vue dédiée de gestion de cette équipe au lieu du retour liste.

### Verification
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_view.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_form.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`

## New_EJ — Lot 1 espace joueur: historique réel en home + page détail — 2026-03-27

### Resume
- démarrage du lot 1 côté espace joueur avec un premier objectif limité:
  - reconstruire une lecture cohérente de l'historique réel;
  - afficher cet historique en home sous forme synthétique;
  - ouvrir une page détail dédiée.
- la règle produit retenue est stricte:
  - ne jamais utiliser `championnats_sessions_participations_probables` pour l'historique;
  - remonter les anciennes participations réelles Quiz et Bingo via compat legacy.

### Correctifs livres
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - ajout d'un contrat de lecture unifié `app_joueur_participations_reelles_get_liste()` + `app_joueur_participations_reelles_get_stats()`;
  - priorite donnée à `championnats_sessions_participations_games_connectees`;
  - compat legacy ajoutée pour:
    - `equipes_to_championnats_sessions` (Quiz);
    - `jeux_bingo_musical_grids_clients` (Bingo);
  - dédoublonnage par session et exclusion explicite des participations probables.
- `play/web/.htaccess`
  - ajout de la route `/extranet/dashboard/history`.
- `play/web/ep/modules/communication/home/ep_home_index.php`
  - le home joueur affiche un titre simple `Hello {prenom}` sans sous-titre;
  - ajout d'une ligne de KPIs:
    - `Prochaines sessions`;
    - `Sessions jouées`;
    - `Top organisateur`;
    - `Top jeu`;
  - chaque carte KPI est maintenant entièrement cliquable avec son footer d'action:
    - `Ajouter depuis l'agenda`;
    - `Voir l'historique`;
    - `Voir son agenda`;
    - `Voir l'agenda de ce jeu`;
  - le bloc des participations probables à venir reste affiché ensuite sous le titre `Tes prochaines sessions de jeu :`;
  - suppression du bloc distinct `Mon historique Cotton`.
- `play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
  - l'agenda expose maintenant sur une même ligne les filtres `Département / pays`, `Organisateur` et `Jeu`;
  - les renvois depuis les KPIs home s'appuient sur les filtres `id_client` / `id_type_produit`;
  - par défaut, les 3 filtres sont sur `Tous`;
  - l'agenda ne se restreint ensuite que sur les filtres choisis explicitement;
  - le filtre géographique est maintenant limité aux zones réellement représentées dans l'agenda:
    - départements français;
    - pays étrangers pour les organisateurs hors France;
  - le filtre `Jeu` est normalisé sur 3 familles lisibles (`Cotton Quiz`, `Blind Test`, `Bingo Musical`) au lieu d'exposer les variantes techniques;
  - l'UI des filtres revient à des labels classiques au-dessus des selects pour éviter le chevauchement du libellé avec la valeur;
  - en environnement `dev`, le chargement agenda n'ajoute plus `c.online=1`, afin que le filtre `Tous` corresponde bien à l'ensemble des sessions configurées disponibles pour la recette.
- `play/web/ep/modules/communication/home/ep_home_history.php`
  - nouvelle page détail de l'historique réel joueur.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_index.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_history.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list.php`

## New_EJ — Realignement `develop + EP only` sur `pro/play` — 2026-03-27

### Resume
- la cible retenue pour `new_ej` est maintenant explicite: conserver strictement les comportements et correctifs de `develop`, puis n'ajouter que le delta necessaire a l'inscription joueur via EP;
- une passe de realignement a donc ete faite directement dans le code `new_ej` pour supprimer les ecarts UI/agenda/wording introduits hors du perimetre `EP -> games`.

### Correctifs livres
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - retour au comportement `develop` pour les cartes agenda `pro`, y compris le bloc/modal des participations probables et le rendu historique des compteurs;
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - retour au detail session `develop`, avec restitution du bloc de participations probables;
- `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
  - retour au widget agenda `develop`;
- `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`
  - retour au widget CTA `develop`;
- `play/web/ep/modules/communication/home/ep_home_index.php`
  - retour au wording `develop` sur l'espace joueur;
- `play/web/ep/modules/compte/equipe/ep_equipe_view.php`
  - retour au wording `develop` sur la creation d'equipe / participations;
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - retour a l'ecran `develop` de participation / inscription selon les contrats historiques;
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
  - realignement sur `develop`, y compris le maintien des types `4` et `5` dans "Mes participations";
- `play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
  - maintien du wording agenda `develop`;
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - maintien des cartes / CTA `develop` de participation probable.

### Verification
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_index.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_view.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`

## New_EJ — Second passage: residuel reduit au strict EP / bridge — 2026-03-27

### Resume
- la passe 1 avait remis `pro` et une partie de `play` sur `develop`, mais il restait encore des ecarts melanges entre UI historique et noyau EP;
- cette seconde passe reduit le residuel a:
  - `play`: uniquement les fichiers strictement necessaires au parcours EP;
  - `games`: uniquement le noyau bridge;
  - `global`: bridge EP conserve, logique joueur/session historisee revenue a `develop`.

### Correctifs livres
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - retour a la semantique `develop` de participation probable;
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
  - restauration des types `4` et `5` comme dans `develop`;
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - retour exact au rendu `develop`;
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `app_joueur_sessions_inscriptions_get_liste()` et `app_joueur_session_inscription_get_detail()` reviennent au contrat `develop`;
  - les helpers `app_joueur_games_bridge_*` et l'extension `games_account_join` restent en place;
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - retour au code `develop` pour `app_session_games_play_get_link()` et `app_jeu_get_detail()`; le diff semantique local est nul;
- `games/web/games_ajax.php`
  - suppression du log `ACTION_RX` non essentiel.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- residuel `play` confirme limite a:
  - `.htaccess`
  - `ep_signin.php`
  - `ep_signup.php`
  - `ep_authentification_script.php`
  - `ep_joueur_script.php`
  - `ep_sessions_inscription_script.php`
  - `ep_sessions_player_connect.php`
- residuel `games` confirme limite a:
  - `config.template.php`
  - `boot_lib.php`
  - `ep_account_bridge.php`
  - `register.js`
  - `player_canvas.php`

## New_EJ — Compat `develop` restauree autour du parcours `EP -> games` — 2026-03-26

### Resume
- l'audit de `new_ej` contre `develop` a montre que le chantier `EP -> games` ne devait pas supprimer les comportements legacy encore attendus par les parcours `play/pro/global`;
- le risque principal venait de trois points:
  - suppression des helpers `participations_probables` cote `global`;
  - suppression des modes legacy `session_participation_probable_*` cote `play`;
  - priorite insuffisante du flux `ep_connect_token` cote `games`, face aux etats locaux `returning player`.

### Correctifs livres
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - restauration des helpers `app_session_participation_probable_*` et `app_session_participations_probables_*` pour maintenir le contrat legacy de `develop`;
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
  - restauration des modes `session_participation_probable_ajouter` et `session_participation_probable_supprimer`, en plus du nouveau mode `joueur_games_connect_finaliser`;
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `app_joueur_sessions_inscriptions_get_liste()` redevient compatible avec les participations probables historiques, y compris pour les types `4` et `5`, tout en conservant les inscriptions reelles supportees par `new_ej`;
  - `app_joueur_session_inscription_get_detail()` retombe aussi sur les participations probables si aucune inscription reelle n'est trouvee;
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
  - restauration des types `4` et `5` dans la liste "Mes participations" et retour des libelles legacy;
- `play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
  - retour du wording agenda legacy et du fallback dev qui elargit la recherche quand les filtres vident l'agenda;
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - retour des CTA / messages de participation probable a la place des promesses d'inscription ferme;
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - ajout d'un garde-fou sur l'insert bridge `championnats_sessions_participations_games_connectees` avec fallback silencieux vers le parcours historique si l'ecriture SQL echoue;
- `games/web/includes/canvas/play/register.js`
  - le flux `ep_connect_token` devient prioritaire sur l'heuristique locale `isReturningPlayer()` tant qu'une reprise EP est en attente;
  - le flux ne tente plus de se baser sur un etat `registered` hors scope et aligne la garde sur un etat local dedie.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
- `node --check /home/romain/Cotton/games/web/includes/canvas/play/register.js`
  - non exploitable en l'etat, le fichier etant un module front avec imports ESM aliases (`@canvas/*`) hors resolution Node CLI brute.

## Global / Pro — Agenda: garde-fous `app_jeu_get_detail()` + `cta_presentation` — 2026-03-26

### Resume
- l'audit croisé `pro/global` a montré que le blocage dev sur l'accès aux sessions programmées n'était pas causé par un diff direct dans `pro`, mais par deux lectures hors contrat exposées au runtime:
  - `app_jeu_get_detail()` lisait `quiz_detail` sans garde sur certaines sessions numériques;
  - le widget CTA agenda lisait `cta_presentation` sans valeur par défaut.

### Correctifs livres
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - initialisation défensive de `quiz_detail` et des champs communs `id_format`, `format`, `id_origine`, `id_securite_jeu`;
  - branche `id_type_produit = 5` rendue tolérante aux quiz absents/incomplets.
- `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`
  - ajout d'une valeur par défaut `bloc` pour `cta_presentation`.

### Verification
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`

## Play / Global / Games — Compte joueur: pont `EP -> games` + table `championnats_sessions_participations_games_connectees` — 2026-03-26

### Resume
- le besoin validé est d'aller plus loin que la participation probable: depuis `games`, un joueur doit pouvoir cliquer `S'inscrire avec mon compte joueur`, passer par `play`, puis revenir sur la session avec une identité EP déjà résolue;
- le gameplay doit continuer d'écrire dans `*_players`, mais il faut en plus un lien durable EP -> session -> joueur de jeu pour les futurs historiques/classements;
- le quiz numérique impose un cas particulier: si le joueur possède plusieurs équipes, le choix doit vivre côté EP avant le retour vers `games`.

### Correctifs livres
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - ajout des helpers `app_joueur_games_bridge_*`;
  - `app_joueur_session_inscription_get_link()` accepte maintenant le contexte `games_account_join=1`;
  - création des retours courts vers `games` via `championnats_sessions_participations_games_connectees`.
- `play/web/`
  - `signin/public/*` et `signup/public/*` transportent maintenant `games_account_join`;
  - ajout du point d'entrée connecté `/extranet/games/session/player-connect/{session}` pour le sélecteur d'équipe quiz;
  - les scripts d'auth/signup et le script session savent finaliser le retour moderne vers `games`.
- `games/web/`
  - la page player expose maintenant `S'inscrire avec mon compte joueur`;
  - `register.js` consomme `ep_connect_token`, déclenche l'auto-inscription et finalise ensuite la liaison EP;
  - ajout du bridge canvas `ep_link_resolve` / `ep_link_finalize`.
- `documentation`
  - ajout du SQL phpMyAdmin `documentation/championnats_sessions_participations_games_connectees_phpmyadmin.sql`;
  - mise à jour du schéma canon, des cartes repo `play` / `games`, des tasks et de ce handoff.

### Fichiers modifies
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `play/web/.htaccess`
- `play/web/ep/ep_signin.php`
- `play/web/ep/ep_signup.php`
- `play/web/ep/modules/compte/authentification/ep_authentification_script.php`
- `play/web/ep/modules/compte/joueur/ep_joueur_script.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_player_connect.php`
- `games/web/player_canvas.php`
- `games/web/includes/canvas/play/register.js`
- `games/web/includes/canvas/php/boot_lib.php`
- `games/web/includes/canvas/php/ep_account_bridge.php`
- `documentation/championnats_sessions_participations_games_connectees_phpmyadmin.sql`
- `documentation/canon/data/schema/DDL.sql`
- `documentation/canon/data/schema/MAP.md`
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/HANDOFF.md`

### Verification
- `php -l` à lancer sur les fichiers PHP `global`, `play` et `games` modifiés;
- import phpMyAdmin à faire avec `documentation/championnats_sessions_participations_games_connectees_phpmyadmin.sql`;
- contrôle manuel à prévoir sur 3 parcours:
  - Blindtest numérique avec joueur EP;
  - Bingo numérique avec joueur EP;
  - Quiz numérique avec plusieurs équipes EP.

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

## 2026-04-13 — Fiche session PRO: correction du warning focus dans la modale photo desktop

### Contexte
- sur desktop, le clic sur `Choisir une photo présente sur cet appareil.` depuis la modale photo de la fiche session declenchait une fermeture Bootstrap immediate de la modale;
- le navigateur signalait alors `Blocked aria-hidden on an element because its descendant retained focus`.

### Correctif
- suppression de `d-none d-sm-block` sur le conteneur `.modal` desktop dans `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`, qui forcait la modale en `display:block` sur desktop meme sans ouverture;
- remplacement du CTA local d'upload par un bouton JS dedie dans `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`;
- le handler rend maintenant d'abord le focus au bouton d'ouverture hors modale, puis ouvre le picker fichier natif seulement apres `hidden.bs.modal`;
- extension de la signature de sync dans `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php` et `pro/web/ec/modules/tunnel/start/ec_start_script.php` pour inclure l'etat des photos podium (`photo_row_key` + `photo_src`);
- cela evite a la fois le warning `aria-hidden` et le backdrop persistant qui desactivait ensuite les clics dans la page.

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`

## 2026-04-13 — Games: correction de la détection dev pour les endpoints WS

### Contexte
- `games` utilisait encore une détection d'environnement trop stricte dans `games/web/config.php`: seul `games.dev.cotton-quiz.com` était reconnu comme `dev`;
- sur un autre host dev `*.dev.cotton-quiz.com`, `games` passait donc en `prod` et injectait les URLs WebSocket de production dans `AppConfig.wsUrl`.

### Correctif
- alignement de `games/web/config.php` et `games/web/config.template.php` sur la même règle que `global`, via `preg_match('~(^|\\.)dev\\.cotton-quiz\\.com$~i', $server_name)`;
- la détection s'appuie maintenant sur `HTTP_HOST` en priorité, avec fallback `SERVER_NAME`, pour éviter les faux `prod` quand le vhost PHP expose un `SERVER_NAME` différent du host réellement servi;
- les configurations `bt_ws_url`, `qz_ws_url` et `bm_ws_url` reviennent ainsi automatiquement sur les endpoints dev dès que le host courant est un sous-domaine dev valide.

### Verification rapide
- `php -l /home/romain/Cotton/games/web/config.php`
- `php -l /home/romain/Cotton/games/web/config.template.php`

## 2026-04-13 — Games organizer: debug runtime de résolution WS

### Contexte
- malgré la correction de détection `dev`, certaines pages organizer continuaient à injecter une `AppConfig.wsUrl` de production;
- un doute restait sur la valeur réellement vue par PHP au runtime (`HTTP_HOST`, `SERVER_NAME`) ou sur un éventuel rendu stale/cache.

### Correctif
- ajout d'un debug `dev` dans `games/web/organizer_canvas.php` qui expose `window.__COTTON_WS_DEBUG__` et loggue `[games/ws-debug]` en console;
- le payload contient `HTTP_HOST`, `SERVER_NAME`, `REQUEST_URI`, `conf.server`, `AppConfig.env`, `AppConfig.wsUrl`, `game` et le suffixe du token session.

### Verification rapide
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`

## 2026-04-13 — Agenda historique PRO: CTA unique vers la fiche détail

### Contexte
- dans la liste des sessions archivées, la carte historique exposait encore un lien secondaire `Gérer` vers la fiche détail et un CTA central `Voir les résultats` qui pouvait encore pointer vers l'interface de jeu;
- le comportement attendu est plus simple: un seul CTA visible pour les sessions passées/terminées, menant à la fiche détail.

### Correctif
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php` masque maintenant le lien `Gérer` pour les sessions archivées;
- le CTA central `Voir les résultats` pointe systématiquement vers `extranet/start/game/view/{id_securite}` sur le cas `after`;
- la condition d'affichage du bloc CTA accepte désormais explicitement les sessions archivées, même sans launcher jeu utile.

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`

## 2026-04-13 — Games organizer: correction de la sélection WS en dev

### Contexte
- le debug `window.__COTTON_WS_DEBUG__` montrait un état incohérent: `conf.server === 'dev'`, `AppConfig.env === 'dev'`, matrice `bt_ws_url['dev']` correcte, mais `AppConfig.wsUrl` restait sur l'endpoint de production;
- cela excluait une mauvaise config brute et pointait vers la sélection de l'URL finale dans organizer.

### Correctif
- `games/web/modules/app_orga_ajax.php` recalcule maintenant explicitement `$env = (string)($conf['server'] ?? 'prod')`, comme `app_play_ajax.php` et `app_remote_ajax.php`;
- `games/web/games_ajax.php` n'utilise plus `$CONF_SERVER ?? 'prod'` pour son `$env` CORS et s'aligne lui aussi sur `$conf['server']`;
- on supprime ainsi l'effet de portée où organizer héritait d'un `$env` réécrit à `prod` dans le bootstrap appelant.

### Verification rapide
- `php -l /home/romain/Cotton/games/web/modules/app_orga_ajax.php`
- `php -l /home/romain/Cotton/games/web/games_ajax.php`

## 2026-04-13 — Games organizer: retrait du debug WS temporaire

### Contexte
- le debug `window.__COTTON_WS_DEBUG__` avait permis de confirmer que `conf.server === 'dev'` et que la matrice WS etait correcte, mais que `AppConfig.wsUrl` etait mal selectionnee dans organizer;
- une fois le correctif `$env` applique et valide, ce debug n'avait plus vocation a rester dans le rendu.

### Correctif
- suppression du bloc debug dev dans `games/web/organizer_canvas.php`.

### Verification rapide
- `php -l /home/romain/Cotton/games/web/organizer_canvas.php`

## PATCH 2026-04-04 - Play leaderboards: badges podium plus lisibles

### Contexte
- les badges de synthèse type `🥈 2 2eme place(s)` ou `🥉 2 3eme place(s)` étaient peu lisibles dans les cartes organisateur de `Classement(s)`.

### Fichiers modifies
- `play/web/ep/modules/communication/home/ep_home_leaderboards.php`
- `play/web/ep/includes/css/ep_custom.css`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/CHANGELOG.md`

### Effet livre
- chaque badge sépare maintenant clairement:
  - l'emoji podium
  - le volume `×n`
  - le libellé humain (`Victoire`, `Deuxième place`, `Troisièmes places`, etc.)
- le rendu est plus scannable sans changer la logique métier sous-jacente.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_leaderboards.php`

## PATCH 2026-04-04 - Play home: helper léger pour le KPI Top classement

### Contexte
- la home EP chargeait jusqu'ici tout le contexte détaillé de `Classement(s)` juste pour extraire le meilleur rang du joueur;
- ce coût était sensible sur le temps de chargement du dashboard.

### Fichiers modifies
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `play/web/ep/modules/communication/home/ep_home_index.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/CHANGELOG.md`

### Effet livre
- ajout de `app_joueur_leaderboards_best_rank_get(...)`, helper dédié au seul `Top classement`;
- le helper évite la construction du contexte complet de page, ne parcourt que les classements utiles, s'arrête dès qu'un `#1` est trouvé, et met en cache le résultat en session sur une courte durée;
- la home EP consomme désormais ce helper au lieu de `app_joueur_leaderboards_get_context(...)`.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-07 - Home EP: `Top classement` différé + cache court leaderboards

### Contexte
- le KPI `Top classement` ralentissait visiblement la home EP car son calcul serveur s'exécutait dans le rendu initial;
- la page `Classement(s)` restait elle aussi coûteuse à recalculer à chaque requête.

### Fichiers modifies
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `play/web/ep/modules/communication/home/ep_home_index.php`
- `play/web/ep/modules/communication/home/ep_home_index_ajax.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/CHANGELOG.md`

### Effet livre
- la home n'évalue plus `Top classement` pendant le rendu initial;
- un appel AJAX EP dédié charge ce KPI juste après affichage et met à jour le bloc sans bloquer le premier paint;
- `app_joueur_leaderboards_get_context(...)` profite désormais d'un cache de session court;
- `app_joueur_leaderboards_best_rank_get(...)` réutilise ce cache de contexte si disponible, au lieu de recalculer systématiquement.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_index.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_index_ajax.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_index.php`

## PATCH 2026-04-04 - Historique joueur: réalignement sur les sessions terminées des classements

### Contexte
- l'historique EP et les classements joueur n'utilisaient pas exactement la même définition d'une session terminée;
- l'historique était plus permissif, en laissant entrer des sessions simplement passées par date, alors que les classements exigent une session non démo, complète et réellement terminée.

### Fichiers modifies
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/CHANGELOG.md`

### Effet livre
- `app_joueur_historique_session_is_eligible(...)` réutilise maintenant la même notion de session fiable que `app_client_joueurs_dashboard_session_is_reliably_terminated(...)`;
- l'historique exclut désormais explicitement les sessions:
  - `flag_session_demo = 1`
  - `flag_configuration_complete != 1`
  - non réellement terminées selon le même moteur que les classements
- les requêtes d'historique remontent les drapeaux de session nécessaires à ce contrôle.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-04 - Play leaderboards: ordre des badges podium

### Contexte
- après le premier lissage visuel, la lecture restait moins naturelle quand le volume précédait le libellé.

### Fichiers modifies
- `play/web/ep/modules/communication/home/ep_home_leaderboards.php`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/CHANGELOG.md`

### Effet livre
- les badges sont maintenant lus dans l'ordre:
  - `Participations ×n`
  - `🏆 Victoire ×n`
  - `🥈 2ème place ×n`
  - `🥉 3ème place ×n`
- les libellés podium restent invariants, quel que soit le volume.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_leaderboards.php`

## PATCH 2026-04-04 - Classements agrégés: cohérence des compteurs podiums

### Contexte
- après le passage à une règle où le podium remplace la participation, les scores étaient bien calculés avec des bonus nets;
- en revanche, les compteurs `victoires / 2e / 3e places` continuaient d'interpréter les anciennes valeurs, ce qui pouvait rendre le résumé podium incohérent avec le total de points.

### Fichiers modifies
- `global/web/app/modules/entites/clients/app_clients_functions.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/CHANGELOG.md`

### Effet livre
- le mapping des podiums s'aligne maintenant sur les bonus nets réellement attribués:
  - `400` => victoire
  - `200` => 2e place
  - `100` => 3e place
- les résumés podiums et les scores agrégés redeviennent cohérents entre eux.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-04 - Play home: KPI Top classement + ordre de navigation EP

### Contexte
- sur la home EP, le 2e KPI affichait `Sessions jouées` et pointait vers l'historique;
- le besoin est maintenant de mettre en avant la meilleure position du joueur dans `Mes classements`, tout en gardant une navigation EP plus logique avec `Historique` en dernier.

### Fichiers modifies
- `play/web/ep/modules/communication/home/ep_home_index.php`
- `play/web/ep/ep.php`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/CHANGELOG.md`

### Effet livre
- le 2e KPI devient `Top classement`;
- sa valeur est calculée à partir du même contexte que la page `Mes classements`, en prenant le meilleur rang courant du joueur ou de ses équipes sur les classements effectivement affichés;
- le KPI renvoie maintenant vers `/extranet/dashboard/leaderboards`;
- dans la navigation EP, `Historique` est déplacé sous `Pseudo / Equipes`, en dernière position du menu principal.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_index.php`
- `php -l /home/romain/Cotton/play/web/ep/ep.php`

## PATCH 2026-04-04 - Play leaderboards: médaille KPI + libellé dynamique page

### Contexte
- le KPI `Top classement` devait valoriser visuellement les podiums;
- la page `Mes classements` devait être renommée selon le nombre réel de classements affichés.

### Fichiers modifies
- `play/web/ep/modules/communication/home/ep_home_index.php`
- `play/web/ep/modules/communication/home/ep_home_leaderboards.php`
- `play/web/ep/ep.php`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/CHANGELOG.md`

### Effet livre
- le KPI `Top classement` ajoute `🏆` pour `#1`, `🥈` pour `#2` et `🥉` pour `#3`;
- son CTA footer redevient `Détail`;
- la page leaderboard utilise désormais `Classement` si une seule section est affichée, sinon `Classements`;
- ce libellé pilote le `h1`, le titre navigateur et le texte de l'entrée de navigation.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_index.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_leaderboards.php`
- `php -l /home/romain/Cotton/play/web/ep/ep.php`
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

## PATCH 2026-03-27 - Play EP home: KPI cliquables et bloc prochaines sessions conditionnel

### Contexte
- la home joueur affichait toujours le bloc `Tes prochaines sessions de jeu :`, meme sans participation probable;
- les KPI du dashboard etaient cliquables mais restaient visuellement trop neutres par rapport aux blocs d'action du pro.

### Fichiers modifies
- `play/web/ep/modules/communication/home/ep_home_index.php`
- `play/web/ep/includes/css/ep_custom.css`

### Effet livre
- les 4 KPI home (`Prochaines sessions`, `Sessions jouees`, `Top organisateur`, `Top jeu`) utilisent maintenant une vraie carte d'action avec footer cliquable plein largeur;
- le style applique un accent joueur rouge sur les valeurs et sur le footer pour se rapprocher des blocs cliquables du pro tout en restant dans la charte EP;
- le bloc `Tes prochaines sessions de jeu :` n'est plus rendu quand la liste des participations probables est vide.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_index.php`

## PATCH 2026-03-27 - Signup joueur: tolérance sur département vide

### Contexte
- le signup public `play` propose un select département non obligatoire;
- quand la valeur restait vide, le POST pouvait échouer sur la création du joueur puis casser le rechargement du formulaire.

### Fichiers modifies
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `play/web/ep/ep_signup.php`

### Effet livre
- la création joueur normalise maintenant `id_zone_departement` à `NULL` quand aucun département n'est saisi;
- le rechargement du formulaire signup n'échoue plus si `id_zone_departement` manque dans `$_SESSION['signup_form_donnees']`.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/ep_signup.php`

## PATCH 2026-03-27 - Signup joueur: retrait du département sur le signup public

### Contexte
- les dernières évolutions du parcours joueur ne justifient plus de demander le département au signup public;
- le flux de join de session peut toutefois continuer à le porter en hidden quand l'information vient déjà du client/session.

### Fichier modifie
- `play/web/ep/ep_signup.php`

### Effet livre
- le signup public n'affiche plus le select département;
- seul le parcours avec `id_securite_championnat_session` conserve `id_zone_departement` en champ hidden quand il est connu.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/ep_signup.php`

## PATCH 2026-03-27 - Navigation EP: ajout de `Historique` et renommage de `Mon equipe`

### Contexte
- l'historique joueur a maintenant sa page propre;
- besoin de rendre cet accès direct dans la navigation latérale EP et de préparer l'évolution de l'entrée équipe.

### Fichier modifie
- `play/web/ep/ep.php`

### Effet livre
- le menu de gauche affiche maintenant `Historique` juste sous `Agenda`, avec une icône dédiée;
- l'entrée `Mon equipe` est renommée `Pseudo / Equipes`;
- l'URL existante de l'espace équipe est conservée.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/ep.php`

## PATCH 2026-03-27 - EP `Pseudo / Equipes`: bloc `Pseudo` + support DB prepare

### Contexte
- la page `Pseudo / Equipes` doit porter un premier bloc `Pseudo` pour les usages Blind Test / Bingo Musical;
- le pseudo doit rester optionnel avec fallback sur le prenom tant qu'il n'est pas renseigne;
- la contrainte fonctionnelle doit rester cohérente avec `games`.

### Fichiers modifies
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `play/web/ep/modules/compte/equipe/ep_equipe_view.php`
- `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
- `play/web/ep/includes/menus/ep_menus_compte_equipe.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_player_connect.php`
- `documentation/equipes_joueurs_pseudo_phpmyadmin.sql`

### Effet livre
- la page `Pseudo / Equipes` affiche maintenant un bloc `Pseudo` distinct du bloc equipes;
- le pseudo peut etre ajoute, modifie ou supprime depuis EP;
- validation alignee `games`: `1` a `20` caracteres;
- le nom d'affichage retombe sur `prenom` tant qu'aucun pseudo n'est disponible;
- le support DB attendu est documente dans `documentation/equipes_joueurs_pseudo_phpmyadmin.sql`.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_view.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_player_connect.php`

## PATCH 2026-03-27 - Games bridge EP: pseudo prioritaire sur Blind Test / Bingo

### Contexte
- apres ajout du champ `pseudo` cote joueur EP, le retour `EP -> games` continuait d'injecter `prenom` pour les sessions solo;
- la correction devait etre faite au point de resolution du `username` consomme par `games`.

### Fichier modifie
- `games/web/includes/canvas/php/ep_account_bridge.php`

### Effet livre
- le bridge `ep_connect_token` charge maintenant `equipes_joueurs.pseudo`;
- pour `blindtest` et `bingo`, le username fourni a `games` utilise `pseudo` en priorite, puis `prenom` en fallback;
- le comportement `quiz` reste base sur le nom d'equipe.

### Verification rapide
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/ep_account_bridge.php`

## PATCH 2026-03-27 - Games player canvas: bloc dedie `Compte joueur Cotton`

### Contexte
- le point d'entree `EP -> games` sur la page player etait encore un simple lien inline `S'inscrire avec mon compte joueur`;
- besoin d'un second bloc plus explicite, distinct du formulaire pseudo, avec une promesse minimale de valeur pour l'espace joueur.

### Fichiers modifies
- `games/web/player_canvas.php`
- `games/web/includes/canvas/css/player_styles.css`

### Effet livre
- l'ecran d'inscription joueur affiche maintenant un bloc `Compte joueur Cotton` sous le formulaire pseudo;
- ce bloc presente une promesse minimale:
  - retrouver son historique;
  - voir ses prochaines sessions;
  - rejouer chez les organisateurs deja frequentes;
- les CTAs `Me connecter avec mon compte joueur` et `Creer mon compte` restent alimentes par les URLs `play` avec contexte session.

### Verification rapide
- `php -l /home/romain/Cotton/games/web/player_canvas.php`

## PATCH 2026-03-27 - EP signin / signup session: visuel de tete aligne `games`

### Contexte
- depuis le player `games`, les ecrans EP `signin/signup` recuperaient deja un branding de session, mais restaient limites au champ legacy `place_bandeau_1`;
- l'appel `app_session_branding_get_detail(...)` n'etait pas fait avec l'id de session en premier parametre.

### Fichiers modifies
- `play/web/ep/ep_signin.php`
- `play/web/ep/ep_signup.php`

### Effet livre
- en contexte session uniquement (`id_securite_championnat_session` present), la tete de page EP utilise maintenant:
  - le visuel retourne par la meme API `global_ajax ... action=get&token=...` que `games`;
  - sinon `visuel.img_src` du branding session local si disponible;
  - sinon `place_bandeau_1`;
  - sinon le visuel par defaut du portail `games` selon le jeu;
- le bloc d'informations de session EP suit maintenant le modele `games`:
  - titre jeu stable;
  - ligne unique `theme • date • heure|Démo`;
- le visuel de tete EP reprend aussi le format `games` (`width:100%`, `max-height:240px`, `object-fit:contain`);
- le rendu `signin/signup` est ainsi plus proche du portail joueur `games`.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/ep_signin.php`
- `php -l /home/romain/Cotton/play/web/ep/ep_signup.php`

## PATCH 2026-03-27 - Signup EP: champ `Pseudo` des la creation de compte

### Contexte
- le pseudo joueur etait gerable apres coup dans `Pseudo / Equipes`, mais pas renseigneable au moment du signup EP;
- besoin de pouvoir l'utiliser des la premiere inscription a une session via l'espace joueur.

### Fichiers modifies
- `play/web/ep/ep_signup.php`
- `play/web/ep/modules/compte/joueur/ep_joueur_script.php`

### Effet livre
- le signup joueur EP affiche maintenant un champ `Pseudo` facultatif a droite de `Prenom`;
- si le compte est cree et que le pseudo est valide (`1` a `20` caracteres), il est ecrit immediatement dans `equipes_joueurs.pseudo`;
- la valeur est aussi conservee si le formulaire revient en erreur.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/ep_signup.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/joueur/ep_joueur_script.php`

## PATCH 2026-03-27 - EP `Pseudo / Equipes`: bloc `Equipes` réaligné et suppression par ligne

### Contexte
- besoin d'aligner le CTA `Ajouter` du bloc `Equipes` sur le pattern visuel du bloc `Pseudo`;
- besoin d'ajouter un sous-titre explicatif et une suppression par ligne pour les comptes qui gerent plusieurs equipes.

### Fichiers modifies
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
- `play/web/ep/modules/compte/equipe/ep_equipe_view.php`

### Effet livre
- le CTA `Ajouter` du bloc `Equipes` est maintenant dans le corps de carte, avec le meme style et le meme positionnement que dans `Pseudo`;
- le bloc affiche le sous-titre:
  - `Les noms d'équipe sont utilisés pour les sessions de Cotton Quiz. Tu peux en gérer plusieurs.`
- chaque ligne d'équipe expose un CTA de suppression avec croix rouge;
- la suppression retire la liaison joueur-equipe sans purge destructive des references historiques.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_view.php`

## PATCH 2026-03-27 - EP `Pseudo / Equipes`: modale joueurs lies + quitter/supprimer

### Contexte
- la suppression brute d'une equipe etait ambigue, car plusieurs joueurs peuvent etre lies a une meme equipe;
- il fallait rendre visible cette liaison depuis l'EP et adapter l'action de sortie selon qu'il reste ou non d'autres joueurs.

### Fichiers modifies
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
- `play/web/ep/modules/compte/equipe/ep_equipe_view.php`

### Effet livre
- le nom d'une equipe est maintenant cliquable et ouvre une modale listant les joueurs lies;
- le CTA croix rouge devient contextuel:
  - `Quitter l'equipe` si d'autres joueurs restent lies;
  - `Supprimer l'equipe` si le joueur courant est le dernier lie;
- cote back, le retrait du dernier joueur declenche la suppression de l'equipe vide.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_view.php`

## PATCH 2026-03-27 - EP menu compte: email + suppression compte joueur

### Contexte
- l'avatar compte de l'EP n'affichait que le prenom du joueur;
- il fallait enrichir le dropdown avec l'email et ajouter un chemin de suppression RGPD accessible depuis n'importe quelle page EP.

### Fichiers modifies
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
- `play/web/ep/ep.php`
- `play/web/ep/includes/css/ep_custom.css`

### Effet livre
- le dropdown compte affiche maintenant `prenom` + `email`;
- un CTA discret `Supprimer mon compte joueur` est disponible avec confirmation native;
- la suppression retire les liaisons directes du joueur (equipes, participations, logs, grilles bingo, lots joueur) puis supprime la ligne `equipes_joueurs`;
- les contenus legacy de contribution gardes en base voient leur `id_equipe_joueur` neutralise a `0` pour eviter une reference orpheline forte.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`
- `php -l /home/romain/Cotton/play/web/ep/ep.php`

## PATCH 2026-03-28 - EP invitation equipe: prenom invite + template AI Studio joueur

### Contexte
- le template invitation equipe a ete repris cote AI Studio avec un nouveau code `PLAYER_ALL_TEAM_INVITATION`;
- son contenu attend maintenant deux variables distinctes:
  - `CONTACT_PRENOM` pour l'invitant
  - `CONTACT_PRENOM_INVITE` pour le joueur invite.

### Fichiers modifies
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `play/web/ep/modules/compte/equipe/ep_equipe_script.php`
- `play/web/ep/modules/compte/equipe/ep_equipe_form.php`

### Effet livre
- le formulaire d'invitation equipe demande maintenant le prenom du joueur invite en plus de l'email;
- le flux d'envoi appelle desormais `ai_studio_email_transactional_send('PLAYER', 'ALL', 'TEAM_INVITATION', ...)`;
- le mapping des variables est aligne sur le nouveau template:
  - `CONTACT_PRENOM` = invitant
  - `CONTACT_PRENOM_INVITE` = invite
  - `EQUIPE_NOM`, `CONTACT_EMAIL`, `CTA_URL_SPECIFIQUE_1` conserves.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_script.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/compte/equipe/ep_equipe_form.php`

## PATCH 2026-03-30 - BO cron jeux: decouplage du cron commerce + helper deplace

### Contexte
- le cron historique `www/web/bo/cron_routine_bdd_maj.php` melangeait traitements commerce/reseau et agregats jeux;
- un cron dedie `www/web/bo/cron_reporting_games_aggregates.php` existait deja, mais sans mail de rapport;
- le helper etait range dans `www/web/bo/includes/`, alors que ses donnees sont consommees par `facturation_pivot`.

### Fichiers modifies
- `www/web/bo/cron_routine_bdd_maj.php`
- `www/web/bo/cron_reporting_games_aggregates.php`
- `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/data/games-reporting.md`

### Effet livre
- `cron_routine_bdd_maj.php` redevient un cron "commerce" et n'execute plus les agregats jeux;
- `cron_reporting_games_aggregates.php` devient le cron "jeux" avec envoi d'un mail de rapport via Brevo;
- la logique partagee d'agregats jeux est deplacee dans `facturation_pivot` sous un nom explicite `bo_facturation_pivot_games_aggregates_refresh()`;
- un wrapper legacy `bo_reporting_games_aggregates_refresh()` reste present dans le helper deplace pour eviter une casse silencieuse d'un appel residuel hors perimetre.

### Verification rapide
- `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php`
- `php -l /home/romain/Cotton/www/web/bo/cron_reporting_games_aggregates.php`
- `php -l /home/romain/Cotton/www/web/bo/cron_routine_bdd_maj.php`
- `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`

### Ajustement UI
- la page `bo/?t=syntheses&m=facturation_pivot&p=saas` expose maintenant un CTA super-admin `Cron jeux` en haut du reporting pour lancer `www/web/bo/cron_reporting_games_aggregates.php` depuis le contexte BO pertinent, sans repasser par le menu global historique.

## PATCH 2026-03-30 - Play agenda quiz: metadonnees V2 par series

### Contexte
- les cartes agenda et le detail d'inscription `play` affichaient encore le legacy quiz (`Cotton Quiz / Cotton Quiz`, puis `4 series [ ~ 2h ]`);
- ce rendu ne distinguait pas les quiz V2 a 1 a 4 series et ne remontait pas les thematiques portees par `quizs_series`.

### Fichiers modifies
- `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/canon/repos/global/TASKS.md`

### Effet livre
- ajout d'un helper `app_cotton_quiz_get_series_meta(...)` qui lit `quizs_series` pour un quiz client et remonte:
  - le nombre de series;
  - un libelle `1 serie` / `x series`;
  - la liste ordonnee des noms de series non vides;
- ajout d'un helper session `app_cotton_quiz_get_session_series_meta(...)` qui lit `championnats_sessions.lot_ids` (`L...` et `T...`) pour remonter les noms de lots classiques et temporaires dans l'ordre de la session;
- `app_jeu_get_detail()` pour `id_type_produit=5` injecte maintenant ces metadonnees dans `app_jeu_detail`;
- `app_session_get_detail()` remonte aussi ces metadonnees session pour prioriser le rendu exact des lots classiques `L...`;
- les cartes agenda `play` reutilisent automatiquement `theme_libelle/theme` pour afficher `Cotton Quiz` puis `1 serie` / `x series`;
- les cartes agenda `play` utilisent maintenant en priorite `app_session_detail['quiz_series_label']` pour rester coherentes avec le detail d'inscription;
- le detail d'inscription `play` remplace le bloc legacy par:
  - `Cotton Quiz : 1 serie` / `x series`;
  - puis chaque thematique sur sa propre ligne;
  - sans reafficher `4 series [ ~ 2h ]`.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

## PATCH 2026-03-30 - Play confirmation session: CTA jour J vers games

### Contexte
- sur la page de confirmation d'intention de participation `play`, le joueur pouvait inviter des amis mais pas relancer directement le bridge `EP -> games` le jour J;
- le wording de rendez-vous restait oriente "validation sur place", meme quand le bridge direct depuis cette page etait pertinent.

### Fichiers modifies
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `play/web/ep/includes/css/ep_custom.css`
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`

### Effet livre
- le jour J uniquement, la page de confirmation `play` ajoute un second CTA `Accede au jeu` a cote de `Invite tes amis !`;
- ce CTA reutilise `app_joueur_session_inscription_get_link(..., games_account_join=1)` pour suivre le bridge existant avec autoregister / selection equipe si necessaire;
- la mention devient uniforme:
  - `Rendez-vous sur place le {jour. jj mois aaaa} pour rejoindre la partie depuis cette page ou grace au QR code diffuse par l'organisateur !`
- le CTA `Accede au jeu` est maintenant un bouton plein rouge, texte blanc, avec fleche vers la droite; seule la fleche reprend la direction visuelle des CTA home, pas leur style de carte KPI.
- ajustement responsive:
  - sur mobile, les deux CTA se placent en colonne avec un espacement coherent;
  - sur desktop, les deux CTA partagent maintenant une hauteur harmonisee.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

## PATCH 2026-03-30 - Cartes agenda: suppression du CTA d'annulation

### Contexte
- les cartes agenda portaient encore un lien d'annulation directe, ce qui surchargeait le rendu alors que la fiche detail couvre deja cette action;
- le besoin final est de ne conserver que le CTA `J'accède au jeu` le jour J.

### Fichiers modifies
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`

### Effet livre
- les cartes agenda ne proposent plus `J'annule ma participation` / `J'annule la participation de mon equipe`;
- seul le CTA `J'accède au jeu` reste affiche le jour J pour les participations deja annoncees;
- ce CTA reutilise maintenant le meme style rouge plein avec fleche que sur la fiche detail.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`

## PATCH 2026-03-30 - Cartes agenda: correctif couleur CTA acces au jeu

### Contexte
- une regle generique `.card-footer a, .card-footer span` forcait le texte du CTA `J'accède au jeu` en bleu sur les cartes agenda.

### Fichiers modifies
- `play/web/ep/includes/css/ep_custom.css`

### Effet livre
- le CTA `J'accède au jeu` garde maintenant bien son texte blanc, y compris sur son `span` interne et sa fleche, sans impacter les autres liens du footer.

## PATCH 2026-03-30 - Agenda play: cartes cliquables + CTA directs de participation

### Contexte
- les cartes agenda `play` ouvraient deja le detail via certains liens internes, mais pas en clic plein sur la carte;
- en cas de participation deja signalee, l'action `J'annule...` passait encore par la fiche detail;
- le jour J, aucun CTA direct `J'accede au jeu` n'etait expose depuis les cartes agenda.

### Fichiers modifies
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
- `play/web/ep/includes/css/ep_custom.css`
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`

### Effet livre
- les cartes agenda deviennent entierement cliquables vers le detail `manage/s1/...` hors CTA;
- les CTA d'ajout existants conservent leur comportement:
  - `Je participe` / `Mon equipe participe` => action + redirection detail;
- le jour J, un CTA direct `J'accede au jeu` apparait aussi sur les cartes deja annoncees;
- l'annulation ne se fait plus depuis les cartes agenda; elle reste disponible depuis la fiche detail.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`

## PATCH 2026-03-30 - Agenda play quiz: equipe unique + annulation par lien

### Contexte
- l'affichage quiz etait incoherent entre home et agenda: le message pouvait retomber sur `ta participation` au lieu de nommer l'equipe;
- le CTA `J'annule la participation de mon equipe` n'etait pas toujours visible sur la carte agenda;
- la logique multi-equipes etait devenue trop ambigue pour le quiz.

### Fichiers modifies
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

### Effet livre
- les cartes agenda quiz utilisent maintenant `app_joueur_session_participations_probables_get_liste(...)` pour retrouver proprement l'equipe effectivement annoncee par le joueur;
- quand une equipe est annoncee, la carte agenda affiche le meme message que la home: `Merci, l'organisateur est prevenu de la participation de ton equipe : ...`;
- la logique est simplifiee: pour une session quiz, le joueur ne peut annoncer qu'une seule equipe a la fois; pour changer, il doit d'abord desinscrire l'equipe deja annoncee;
- la fiche detail reste le seul point d'annulation et de changement d'equipe pour le quiz.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

## PATCH 2026-03-30 - Detail quiz: ne montrer que l'equipe deja inscrite

### Contexte
- sur la fiche detail d'une session quiz, toutes les equipes du joueur restaient visibles meme quand une seule etait deja annoncee;
- cela ajoutait du bruit alors que la nouvelle regle n'autorise plus qu'une equipe annoncee a la fois.

### Fichiers modifies
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

### Effet livre
- si une equipe quiz est deja inscrite, la fiche detail ne montre plus qu'elle;
- les autres equipes ne sont visibles qu'au moment du choix initial, avant toute inscription;
- le separateur `<hr>` n'est plus rendu inutilement apres le dernier bloc visible.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

## PATCH 2026-03-30 - Source commune equipe quiz sur les inscriptions joueur

### Contexte
- la home et l'agenda ne partaient pas de la meme granularite: la home listait les sessions deja inscrites via `app_joueur_sessions_inscriptions_get_liste(...)`, tandis que l'agenda partait des sessions puis reconstruisait seulement un boolen d'inscription;
- pour le quiz, cela pouvait faire tomber l'agenda sur `ta participation` au lieu de remonter le nom de l'equipe.

### Fichiers modifies
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`

### Effet livre
- `app_joueur_sessions_inscriptions_get_liste(...)` remonte maintenant aussi:
  - `id_equipe_inscrite`
  - `equipe_nom_inscrite`
  - `nb_equipes_inscrites`
- le bloc agenda `play` consomme ces champs en priorite quand il est rendu depuis la liste des inscriptions joueur, ce qui aligne le message quiz avec la home;
- l'agenda general garde un fallback local pour les contextes qui ne viennent pas de cette liste.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`

## PATCH 2026-03-30 - Compatibilite play sans helper global quiz

### Contexte
- certains environnements `play` n'embarquent pas encore le helper global `app_joueur_session_participations_probables_get_liste(...)`;
- les nouveaux ecrans agenda/detail/script quiz fatalaient donc au chargement ou a l'action.

### Fichiers modifies
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

### Effet livre
- les trois points d'usage passent maintenant par un fallback local si le helper global est absent;
- le fallback reconstruit les participations quiz a partir des equipes du joueur et de `app_session_participations_probables_get_liste(...)`;
- le comportement fonctionnel reste identique, mais sans dependre du rythme de deploiement de `global`.

### Verification rapide
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

## PATCH 2026-03-31 - Garde compatibilite numerique quiz alignee dans pro

### Contexte
- `games` bloquait deja le passage papier -> numerique si des questions quiz n'avaient pas assez de propositions;
- `pro` n'appliquait pas encore cette garde metier, ce qui ouvrait un ecart de comportement entre les deux interfaces.

### Fichiers modifies
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`

### Effet livre
- un helper global reconstruit maintenant la compatibilite numerique d'une session `Cotton Quiz` a partir de `lot_ids`, `questions` et `questions_propositions`;
- `pro` bloque serveur le passage vers `numerique` si au moins une question n'a pas deux propositions distinctes de la bonne reponse;
- la fiche settings `pro` affiche le meme message metier que `games` et desactive l'option `numerique` quand la session papier courante n'est pas compatible.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`

## PATCH 2026-03-31 - Regressions sync pro-games sur le format

### Contexte
- la fiche detail `pro` appelait un helper de sync defini seulement dans `ec_start_script.php`, ce qui cassait la vue en fatal;
- cote organizer `games`, la synchro serveur mettait a jour le store et le DOM, mais pas le localStorage relu a l'ouverture de la modale Options.

### Fichiers modifies
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- `games/web/includes/canvas/core/boot_organizer.js`

### Effet livre
- la fiche detail `pro` calcule maintenant sa signature de sync localement et ne depend plus du helper du script;
- le polling organizer `games` persiste aussi `paperMode` dans le namespace d'options local, ce qui evite qu'une session papier resorte `numerique` a la reouverture de la modale.
- la modale Options `games` recale aussi son switch sur `ServerSessionMeta.flag_controle_numerique` a l'ouverture et persiste immediatement `paperMode` lors d'un changement de format.
- l'API `Blind Test` accepte maintenant aussi un `session_update` ne portant que le flag papier/numerique, sans exiger `currentSongIndex` ni `gameStatus`, ce qui remet la persistance `games -> pro` sur le format.

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## PATCH 2026-04-01 - Remote papier games: selection DB de joueurs / equipes existants

### Contexte
- la remote papier `games` n'ajoutait jusque-la des participants que par saisie libre, ce qui recreait une identite runtime a chaque ajout;
- le besoin valide est de pouvoir rechercher un joueur `blindtest` / `bingo` dans `equipes_joueurs` ou une equipe `quiz` dans `equipes`, puis de reutiliser cette identite a l'inscription remote.

### Fichiers modifies
- `games/web/includes/canvas/php/boot_lib.php`
- `games/web/includes/canvas/php/quiz_adapter_glue.php`
- `games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `games/web/includes/canvas/php/bingo_adapter_glue.php`
- `games/web/includes/canvas/remote/remote-ui.js`
- `games/web/includes/canvas/css/remote_styles.css`
- `documentation/canon/repos/games/README.md`
- `documentation/canon/repos/games/TASKS.md`
- `documentation/HANDOFF.md`

### Effet livre
- nouvelle action bridge `participant_lookup`:
  - `quiz` -> lookup `equipes.nom`;
  - `blindtest` / `bingo` -> lookup `equipes_joueurs.pseudo` puis `prenom`;
- la modale remote propose des suggestions DB a partir de 3 caracteres, avec fallback saisie libre si aucun resultat ne convient;
- pour `quiz`, les equipes homonymes sont desormais desambiguees par un contexte metier affiche dans la suggestion: jusqu'a 2 prenoms de joueurs associes a l'equipe;
- pour `blindtest` / `bingo`, les fiches `equipes_joueurs` portant un email technique `@cotton-quiz.com` sont exclues du lookup remote;
- les autres joueurs homonymes sont desambigues par un email masque dans la suggestion quand `equipes_joueurs` expose une colonne email standard (`email`, `mail` ou `adresse_mail`);
- si plusieurs lignes semblent correspondre au meme joueur (`libelle affiche + email normalise`), le lookup n'en renvoie plus qu'une seule et garde la plus recente (`updated_at`, sinon `created_at`, sinon `id` le plus grand);
- le lookup remote applique maintenant un filtre dur par organisateur a partir de la session courante (`championnats_sessions.id_client`):
  - `quiz` remonte uniquement les equipes deja vues pour ce client via `championnats_sessions_participations_probables`, `championnats_sessions_participations_games_connectees` et le legacy `equipes_to_championnats_sessions`;
  - `blindtest` / `bingo` remontent uniquement les joueurs deja lies a ce compte organisateur via `championnats_sessions_participations_probables`, `championnats_sessions_participations_games_connectees` et le legacy bingo `jeux_bingo_musical_grids_clients`;
- la remote envoie maintenant explicitement `sessionId` au lookup et annonce ce perimetre dans l'aide: `joueur/equipe deja lie(e) a ton compte organisateur`;
- quand l'animateur choisit une entree existante, la remote envoie un `player_id` canonique `p:uuid`, derive de facon deterministe de la source metier (`id_equipe` / `id_joueur`);
- effet attendu: re-ajouter un participant existant sur une session papier reactive/upsert la meme ligne runtime au lieu de creer un doublon logique.
- la validation backend `username` n'est plus bornee a `20` en dur et suit la longueur declaree de la colonne `username` de chaque table jeu, avec fallback `20` si `information_schema` n'est pas accessible.

### Verification rapide
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/blindtest_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/bingo_adapter_glue.php`
- `git -C /home/romain/Cotton/games diff --check`

## PATCH 2026-03-31 - Quiz organizer: rejet `BAD_GAME_STATUS` sur switch de format

### Contexte
- les logs `games.dev` recharges le 31/03/2026 a `14:36:26` montrent un `500` sur `quiz.session_update` avec `game_api_dispatch FAIL quiz.session_update error=BAD_GAME_STATUS`;
- ce rejet survenait pendant le switch organizer papier/numerique, avant toute garde metier de compatibilite quiz ou ecriture du flag de session.

### Fichiers modifies
- `games/web/includes/canvas/php/quiz_adapter_glue.php`

### Effet livre
- `quiz_api_session_update()` ne force plus `currentSongIndex` et `gameStatus` a `null` quand le payload ne contient qu'un changement de format;
- le chemin organizer `paperMode` / `flagControleNumerique` peut donc appeler `qz_session_update()` sans activer a tort la validation de l'etat de partie;
- le write du format quiz peut enfin atteindre la garde papier -> numerique puis la persistance SQL au lieu d'echouer immediatement sur `BAD_GAME_STATUS`.

### Verification rapide
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`

## PATCH 2026-03-31 - Quiz format UX unifiee games + pro

### Contexte
- apres correction du `BAD_GAME_STATUS`, il restait 2 residus de debug/UX:
- des logs de diagnostic temporaires etaient encore actifs cote `games`;
- le blocage `papier -> numerique` sur `Cotton Quiz` n'etait pas presente de la meme facon dans `games` et `pro`.

### Fichiers modifies
- `games/web/includes/canvas/core/session_modals.js`
- `games/web/includes/canvas/php/boot_lib.php`
- `games/web/includes/canvas/php/quiz_adapter_glue.php`
- `games/web/games_ajax.php`
- `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`

### Effet livre
- retrait des logs d'enquete temporaires ajoutes pour isoler le `500`;
- cote `games`, le switch format quiz est desactive en bloc quand le numerique est impossible, avec la note `Ce quiz n'est pas compatible avec la version numérique du jeu.`;
- cote `pro`, la fiche settings n'affiche plus de bandeau `format_error` pour ce cas: les CTAs de format quiz sont desactives et la meme note est affichee sous le switch.

### Verification rapide
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/boot_lib.php`
- `php -l /home/romain/Cotton/games/web/includes/canvas/php/quiz_adapter_glue.php`
- `php -l /home/romain/Cotton/games/web/games_ajax.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`

## PATCH 2026-03-31 - Organizer games: fermeture volontaire sur suppression pro

## PATCH 2026-04-01 - PRO `Mes joueurs`: nav masquee sans historique

### Contexte
- certains comptes eligibles a `Mes joueurs` arrivaient sur une page vide simplement parce qu'ils n'avaient encore aucune session historique a exploiter.

### Fichiers modifies
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `pro/web/ec/ec.php`

### Effet livre
- `global` expose maintenant `app_client_has_archived_sessions($id_client)` en reutilisant la notion existante de session archivee (`app_session_is_archive`, hors demo, complete);
- `pro` n'affiche plus l'entree de navigation `Mes joueurs` si le client n'a encore aucune session historique archivee exploitable.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec.php`

## PATCH 2026-04-02 - Play / Global: bridge EP -> games differe au clic

### Contexte
- `play` preparait jusqu'ici le CTA `J'accede au jeu` en appelant directement `app_joueur_games_bridge_prepare_return(...)` pendant le rendu des cartes et des fiches;
- ce simple rendu pouvait donc inserer des lignes `championnats_sessions_participations_games_connectees` avant toute entree reelle dans le jeu.

### Fichiers modifies
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`

### Effet livre
- `app_joueur_session_inscription_get_link(..., games_account_join=1)` renvoie maintenant un lien differe vers le script EP d'inscription/finalisation, au lieu de creer tout de suite la ligne bridge;
- `ep_sessions_inscription_script.php` accepte maintenant aussi ce parcours en `GET` pour `mode=joueur_games_connect_finaliser`, puis declenche seulement alors `app_joueur_games_bridge_prepare_return(...)`;
- les parcours `games` eux-memes ne sont pas modifies; seule la preparation passive du CTA cote `play` est deferree au clic.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`

## PATCH 2026-04-02 - Classements agreges: exclusion des bridges non consommes et runtimes inactifs

### Contexte
- une session future `Cotton Quiz` pouvait deja polluer `Mes joueurs` si une ligne bridge `EP -> games` avait ete creee avant ouverture reelle du jeu;
- plus largement, les lecteurs de classements agreges traitaient encore comme participants certains joueurs runtime quittes volontairement (`is_active = 0`).

### Fichiers modifies
- `global/web/app/modules/entites/clients/app_clients_functions.php`

### Effet livre
- `app_client_joueurs_dashboard_period_has_leaderboard_data(...)` et `app_client_joueurs_dashboard_get_context(...)` excluent maintenant:
  - les lignes `championnats_sessions_participations_games_connectees` non consommees (`date_consumed IS NOT NULL` requis);
  - les joueurs runtime inactifs sur `cotton_quiz_players`, `blindtest_players` et `bingo_players` (`is_active = 1` requis quand la colonne existe);
  - les podiums `bingo_phase_winners` dont le joueur runtime n'est plus actif via `bingo_players`.
- `pro` et `play` heritent automatiquement de ce durcissement, car ils reutilisent tous deux ce moteur organisateur canonique.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-02 - Play classements: recap podium realigne sur le moteur organisateur

### Contexte
- le recap `Participations / 🏆 / 🥈 / 🥉` de `Mes classements` n'etait plus reellement alimente depuis le refactor qui a decouple la page de l'historique detaille joueur;
- les lignes du leaderboard organisateur canoniques portaient bien `count` et `score`, mais pas encore les compteurs podium exploitables cote `play`.

### Fichiers modifies
- `global/web/app/modules/entites/clients/app_clients_functions.php`
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

### Effet livre
- le moteur organisateur `app_client_joueurs_dashboard_get_context(...)` ajoute maintenant `wins`, `second_places` et `third_places` sur chaque ligne de classement joueur/equipe, a partir des memes attributions de points canoniques que le score agrege;
- `Mes classements` somme ensuite ces compteurs sur la ligne joueur ou equipe surlignee pour alimenter son recap par organisateur, sans relancer de recalcul historique detaille;
- `Participations` reste derive des lignes surlignees, et `🏆 / 🥈 / 🥉` redeviennent disponibles quand la ligne concernee porte effectivement des podiums sur la saison affichee.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-01 - EC nav: CTA `Je commande` stabilise

### Contexte
- le CTA `Je commande / Tarifs & commande` changeait de taille visuelle au fil des navigations dans le shell EC.

### Fichiers modifies
- `pro/web/ec/ec.php`
- `pro/web/ec/includes/css/ec_custom.css`

### Effet livre
- le CTA de nav porte maintenant une classe locale `ec-nav-order-cta`;
- le lien embarque aussi maintenant son gabarit critique directement inline dans le HTML (`display`, largeur utile, marges, hauteur, padding horizontal et vertical forces avec `!important`), pour eviter qu'il s'affiche d'abord trop large avant chargement complet des CSS;
- cette classe fige largeur, hauteur, alignement texte/svg et neutralise les variations d'etat `hover / focus / active` qui pouvaient faire bouger le bouton;
- le conteneur scrollable `data-simplebar` du menu gauche reserve aussi maintenant un gutter de scrollbar stable, pour eviter qu'une apparition/disparition de scroll ne fasse varier la largeur utile du CTA.

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/ec.php`

### Contexte
- un organizer `games` pouvait rester ouvert sur une session supprimee cote `pro`;
- le polling `session_meta_get` detectait l'echec, mais ne provoquait pas de sortie propre de la session.

### Fichiers modifies
- `games/web/includes/canvas/core/boot_organizer.js`

### Effet livre
- si `session_meta_get` retourne `session_not_found`, l'organizer appelle `endSession()` avec `serverLogout=true` et le motif `Session supprimée`;
- l'interface repasse donc bien par le chemin `quitGame` deja en place cote `games` (notification WS remote/joueurs), puis nettoie son etat local et redirige vers `pro`.

### Verification rapide
- revue ciblée de `games/web/includes/canvas/core/boot_organizer.js`

## PATCH 2026-03-31 - Agenda pro historique: actions de gestion limitees

### Contexte
- dans la vue agenda `pro`, une session passee pouvait encore afficher le bouton `Supprimer` si son etat etait reste `En attente`;
- le message `Cette session est en cours...` remontait aussi sur l'historique alors qu'il doit rester reserve aux sessions encore actives hors historique.

### Fichiers modifies
- `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

### Effet livre
- l'historique (`app_session_chronology === 'after'`) masque maintenant le bouton de suppression;
- le message runtime `Cette session est en cours...` n'est plus affiche sur l'historique, seulement sur les sessions verrouillees encore visibles dans l'agenda courant.
- la carte Parametres conserve aussi ses coins bas arrondis quand la zone suppression n'est plus rendue.
- sur les sessions verrouillees encore actives, ce message runtime est maintenant presente dans un callout plus propre et plus coherent visuellement avec `pro`, sans icone, et avec un lien direct reprenant la meme cible que le CTA `Ouvrir le jeu`.

### Verification rapide
- `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## PATCH 2026-04-04 - Classements `Mes joueurs` / `Mes classements`: scope de sessions + classement complet

### Contexte
- les tableaux `Top 10` des ecrans `Mes joueurs` et `Mes classements` n'explicitaient pas encore combien de sessions entraient reellement dans le calcul du classement;
- aucune action n'exposait non plus la liste complete quand un leaderboard depassait `10` lignes.

### Fichiers modifies
- `global/web/app/modules/entites/clients/app_clients_functions.php`
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- `play/web/ep/modules/communication/home/ep_home_leaderboards.php`
- `play/web/ep/includes/css/ep_custom.css`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/CHANGELOG.md`

### Effet livre
- le moteur global de leaderboard remonte maintenant, par jeu:
  - le nb de sessions effectivement retenues dans le calcul;
  - le nb de sessions retrouvees sur la saison filtree;
  - la liste complete triee, en plus du `Top 10`;
- `Mes joueurs` et `Mes classements` affichent maintenant la mention `Classement calculé sur X session(s) jouée(s) depuis le début de la saison` juste avant la ligne d'attribution des points;
- si un leaderboard depasse `10` lignes, un simple lien souligné permet de dérouler toute la liste puis de la replier;
- le titre du tableau bascule alors de `Top 10 ...` vers `Classement complet sur la saison sélectionnée`;
- cote `play`, la ligne joueur/equipe courante reste aussi surlignee dans la vue complete.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_leaderboards.php`

## PATCH 2026-04-04 - Play `Mes classements`: saison réellement acceptée par l'organisateur

### Contexte
- `play` pouvait afficher une saison `courante` detectee via l'historique joueur alors que le moteur organisateur refusait en realite ce trimestre faute de donnees leaderboard exploitables;
- dans ce cas, le tableau et le compteur de sessions provenaient du trimestre precedent, mais le libelle de saison restait sur le trimestre courant.

### Fichiers modifies
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/play/TASKS.md`
- `documentation/canon/repos/play/README.md`
- `documentation/CHANGELOG.md`

### Effet livre
- `app_joueur_leaderboards_get_context(...)` ne valide plus un trimestre `courant / precedent` sur la seule base des participations joueur;
- chaque candidat est maintenant revalide via `app_client_joueurs_dashboard_get_context(...)`;
- si le moteur organisateur retombe sur un autre trimestre, le candidat est rejete et le helper tente la periode suivante;
- resultat: la saison affichee dans `play`, les tableaux visibles et le compteur `Classement calculé sur X sessions...` restent enfin alignes sur la meme periode effective.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-04 - Classements historiques: fusion des fallback runtime vers les identités DB

### Contexte
- certains leaderboards conservaient encore des doublons historiques entre une identité DB canonique (`team:*`, `ep:*`) et une identité runtime de secours (`runtime:*`) issue d'anciens libellés non fiabilisés a la source;
- le cas etait particulièrement visible sur les équipes quiz avec des variantes de casse, d'accents ou de ponctuation.

### Fichiers modifies
- `global/web/app/modules/entites/clients/app_clients_functions.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/CHANGELOG.md`

### Effet livre
- le moteur global recolle maintenant les fallback runtime historiques a une identité DB canonique si, et seulement si, le libellé normalisé correspond de façon unique a une identité non-runtime deja connue dans le contexte du client;
- la fusion couvre les fallback:
  - `runtime:quiz_team:*`
  - `runtime:blindtest:*`
  - `runtime:bingo:*`
- aucun merge n'est force si plusieurs identités DB partagent le meme libellé normalisé;
- résultat: les doublons historiques “mêmes noms, identité DB vs runtime” disparaissent, tout en gardant les cas réellement ambigus séparés.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-10 - TdR `open_affiliate_offer_portal`: resolver de souscription avant snapshot Stripe

### Contexte
- les logs `2026-04-10` montraient un échec amont:
  - redirection `account/network?msg=network_affiliate_subscription_snapshot_unavailable`
  - donc pas un `portal_session_error` primaire;
- le vrai blocage venait du `portal_subscription_snapshot` d'une offre affiliée déléguée TdR:
  - le CTA pouvait s'afficher avec un `asset_stripe_productId` non vide;
  - mais cette valeur n'était pas toujours une souscription Stripe relisible dans l'environnement courant.

### Fichiers modifiés
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/pro/TASKS.md`
- `documentation/canon/repos/pro/README.md`

### Effet livré
- ajout d'un resolver global `app_ecommerce_stripe_subscription_id_resolve_from_offer_client(...)`:
  - valide d'abord le `sub_...` stocké;
  - sinon recherche la souscription Stripe via:
    - `metadata['offre_client_id_securite']`
    - puis `metadata['offre_client_id']`;
  - choisit la meilleure candidate par état puis récence;
  - réécrit le `subscription_id` trouvé dans `ecommerce_offres_to_clients.asset_stripe_productId`;
- `app_ecommerce_stripe_customer_backfill_from_offer_subscription(...)` et `app_ecommerce_stripe_billing_portal_session_prepare(...)` utilisent ce resolver avant de conclure à `subscription_snapshot_unavailable`;
- ce fallback est maintenant limité aux offres affiliées déléguées pour ne pas altérer le comportement des CTA Stripe standard;
- pour les offres standard non affiliées, `app_ecommerce_stripe_billing_portal_session_prepare(...)` revalide désormais le `customer` Stripe via `app_ecommerce_stripe_customer_ensure_for_client(...)` avant de créer la session portail;
- côté `pro`, le CTA `Gérer l'offre` des offres affiliées déléguées n'est plus affiché si aucune souscription Stripe résolue n'existe réellement;
- le clic TdR rouvre le portail affilié standard `network_affiliate`, sans entrée directe sur le flow de résiliation.

### Vérification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php`

## PATCH 2026-04-04 - Classements agrégés: le podium remplace la participation

### Contexte
- le score agrégé des leaderboards ajoutait jusqu'ici les `100` points de participation, puis les gains de podium ou de phase;
- un gagnant de session pouvait donc monter a `600` points au lieu des `500` points attendus.

### Fichiers modifies
- `global/web/app/modules/entites/clients/app_clients_functions.php`
- `documentation/canon/repos/global/TASKS.md`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/pro/README.md`
- `documentation/CHANGELOG.md`

### Effet livre
- les gains de rang `1 / 2 / 3` en quiz / blind test valent maintenant `500 / 300 / 200` points au total;
- les gains de phase `Bingo / Double ligne / Ligne` valent maintenant eux aussi `500 / 300 / 200` points au total;
- les `100` points restent reserves a une participation sans podium ni gain de phase.

### Verification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-13 - Historique EP: accès aux résultats des sessions terminées

### Contexte
- l'historique `play` listait bien les sessions réellement terminées, mais sans accès direct à une fiche résultats dédiée;
- l'objectif est d'aligner l'expérience joueur sur le rendu `www` déjà livré pour les sessions passées.

### Fichiers modifiés
- `play/web/ep/modules/communication/home/ep_home_history.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`

### Effet livré
- chaque carte de l'historique joueur est maintenant cliquable vers la fiche détail de session `play`;
- un CTA explicite `Voir les résultats` est affiché en bas de carte;
- sur une session passée, la fiche détail `play` n'affiche plus le flux d'inscription mais un rendu résultats simple:
  - `Podium` avec photo quand disponible, sinon fallback coupe / médaille;
  - `Classement complet (xx)` pour `Cotton Quiz` et `Blind Test`;
  - `Liste des joueurs (xx)` pour `Bingo Musical`, sans colonnes rang / points;
- le tout réutilise `app_session_results_get_context(...)` pour rester aligné avec le moteur global déjà utilisé côté `www` et `pro`.
- côté `play`, les URLs des photos podium sont réécrites localement vers `www/upload` pour contourner le `upload_root` propre à l'EP et rétablir l'affichage des visuels gagnants.

### Vérification rapide
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_history.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`

## PATCH 2026-04-13 - Leaderboards EP: filtrage strict des jeux par participation réelle

### Contexte
- la page `Classements` EP repart bien des organisateurs liés à l'historique réel du joueur;
- mais l'affichage devait être durci pour éviter de conserver, chez un organisateur, des leaderboards de jeux où le joueur n'apparaît pas réellement.

### Fichiers modifiés
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/play/README.md`
- `documentation/canon/repos/play/TASKS.md`

### Effet livré
- ajout d'un helper `app_joueur_leaderboards_has_current_rows(...)`;
- après surlignage des lignes `is_current`, `Mes classements` ne garde plus un leaderboard jeu que si le joueur ou son équipe y sont effectivement repérés;
- un simple rattachement historique à l'organisateur ne suffit donc plus pour afficher les autres jeux de cet organisateur.
- les lignes de détail `Classement calculé sur ...` et `Attribution des points ...` sont rendues sans `text-muted` et avec une couleur neutre explicite pour ne pas hériter du rouge du titre de tableau.

### Vérification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
## PATCH 2026-04-13 - Fiche session Bingo: labels joueurs reconciliés avec les liaisons EP

### Contexte
- certaines fiches sessions Bingo terminees affichaient encore `Joueur inconnu` au podium et omettaient des joueurs pourtant relies a un compte EP;
- cause identifiee: la fiche relisait directement `bingo_players.username` et `bingo_phase_winners`, sans reappliquer le fallback identite deja utilise dans `Mes joueurs`.

### Fichiers modifiés
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `documentation/canon/repos/global/README.md`
- `documentation/canon/repos/global/TASKS.md`

### Effet livré
- ajout de helpers de normalisation / label joueur au niveau session;
- `app_session_results_get_context(...)` recolle maintenant les labels `Bingo Musical` via:
  - `championnats_sessions_participations_games_connectees` consommees;
  - puis le fallback legacy `jeux_bingo_musical_grids_clients`;
- priorite d'affichage: `pseudo`, sinon `prenom nom`;
- le podium de phases et la liste joueurs ne dependent donc plus uniquement de `bingo_players.username` quand celui-ci est vide;
- addendum: le switch de resultats session couvre aussi `id_type_produit = 2`, pour ne plus laisser les vieux Bingos hors rendu sur `play` / `www`.

### Vérification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-14 - FO fiche `place`: contexte leaderboard public allégé

### Contexte
- la fiche établissement publique `/fr/place/...` réutilisait jusque-là `app_client_joueurs_dashboard_get_context(...)`, donc le même point d'entrée que `Mes joueurs`;
- sur un cache de session froid, ce helper recalculait tout le contexte historique organisateur (`sessions_scope = all`), alors que la page publique n'affiche que les leaderboards de la saison courante.

### Fichiers modifiés
- `global/web/app/modules/entites/clients/app_clients_functions.php`
- `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`

### Effet livré
- ajout d'un helper dédié `app_client_joueurs_dashboard_get_context_fo_place(...)`;
- ce helper charge directement `app_client_joueurs_dashboard_context_compute(..., 'filter')` pour la saison courante, sans relancer le calcul historique complet au premier hit public;
- la synthèse historique haute n'est réinjectée que si le cache journalier de session existe déjà; sinon la fiche privilégie la vitesse et n'affiche que les leaderboards nécessaires;
- `fo_clients_view.php` utilise désormais ce helper léger.
- addendum:
  - le rendu FO `place` a été découpé en shell + hydratation AJAX via `fo_clients_view_ajax.php`;
  - un fichier partagé `fo_clients_view_shared.php` centralise maintenant le HTML de synthèse et de leaderboards pour éviter les divergences entre page initiale et fragment AJAX;
  - le bloc `Classements` réintroduit un sélecteur de saison directement dans le titre; ce sélecteur recharge uniquement les leaderboards demandés, sans recalculer la synthèse haute, et trie les saisons exploitables de la plus récente à la plus ancienne.

### Vérification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PATCH 2026-04-14 - FO liste `place`: départements présents + tri activité

### Contexte
- la liste publique des organisateurs `/fr/place` proposait encore tous les départements du référentiel, même sans lieu public associé;
- les cartes organisateurs restaient triées par `id`, ce qui ne faisait pas ressortir les lieux les plus actifs.

### Fichiers modifiés
- `www/web/fo/includes/css/fo_custom.css`
- `www/web/fo/includes/css/fo_custom_20251120.css`
- `www/web/fo/includes/header/fo_header_main.php`
- `www/web/fo/includes/footer/fo_footer_main.php`
- `www/web/fo/includes/js/fo.js`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/HANDOFF.md`

### Effet livré
- la branche `photos_ec` réutilise de nouveau les includes FO de `main` pour le shell/header/CSS/JS communs;
- les régressions visuelles introduites par des includes locaux obsolètes sont supprimées:
  - logos de références re-normalisés et repassés en noir et blanc avec hover couleur;
  - images catalogue/démo ré-harmonisées via `harmonized-img-wrapper`;
  - header FO et JS shell réalignés sur le comportement `main`;
- les évolutions métier propres à `photos_ec` restent dans les modules de branche (`place`, `agenda`, `session`) et ne sont pas écrasées.

### Vérification rapide
- `php -l /home/romain/Cotton/www/web/fo/includes/header/fo_header_main.php`
- `php -l /home/romain/Cotton/www/web/fo/includes/footer/fo_footer_main.php`

### Notes
- le réalignement a été fait par copie directe du contenu `main` dans les 5 includes ciblés, `git restore --source=main` étant bloqué ici par le sandbox sur `.git/index.lock`;
- les fichiers réalignés ne diffèrent plus de `main` après patch.

### Fichiers modifiés
- `www/web/fo/modules/entites/clients/fr/fo_clients_list.php`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`

### Effet livré
- le sélecteur `Département` ne garde plus que les départements réellement présents dans la liste publique des organisateurs;
- l'option `Tous` repointe correctement vers `/fr/place`;
- la liste organisateurs est maintenant triée par activité agrégée côté SQL:
  - `sessions_total` décroissant;
  - puis `latest_session_date` décroissante;
  - puis `nom` croissant;
- le contrat de perf reste léger: une seule agrégation SQL globale jointe à la liste publique, sans calcul par carte.

### Vérification rapide
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_list.php`

## PATCH 2026-04-14 - FO fiche `place`: lazy load de tous les onglets lourds

### Contexte
- malgré l'hydratation AJAX déjà en place pour la synthèse et les leaderboards, la fiche publique établissement continuait de rendre `Agenda` et `Sessions passées` côté serveur;
- le TTFB restait donc pénalisé, surtout sur les lieux avec beaucoup d'archives.

### Fichiers modifiés
- `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`

### Effet livré
- `Agenda` et `Sessions passées` ne sont plus calculés au rendu initial;
- l'endpoint AJAX FO accepte maintenant un paramètre `section`:
  - `overview` pour synthèse + classements;
  - `agenda` pour les sessions à venir;
  - `archive` pour les sessions passées utiles;
- le HTML des cartes sessions FO est mutualisé dans le shared pour garder le même rendu entre shell initial et fragments;
- si la réponse `overview` confirme qu'aucun classement n'est exploitable, la page bascule automatiquement vers l'onglet `Agenda` et déclenche son chargement à la demande.
- addendum perf:
  - `overview` est désormais réservé aux leaderboards;
  - la synthèse haute part sur une requête AJAX `summary` séparée;
  - l'objectif est de laisser les classements apparaître avant le calcul historique plus lourd.
  - un cache de session FO `place` a ensuite été ajouté sur les leaderboards eux-mêmes, avec une clé `id_client + jour + année + trimestre`, pour éviter les recalculs sur la même saison sans toucher aux chemins `pro` / `play`.
  - addendum métier: la sélection des archives FO `place` passe maintenant par un helper global dédié `app_client_joueurs_dashboard_archive_sessions_get(...)`, extrait de la logique d'archives pro.
  - la colonne `sessions récentes` à droite des leaderboards FO réutilise ce même helper partagé avec filtre jeu + fenêtre de saison, au lieu d'une logique locale basée sur `has_podium/has_ranking`.
  - addendum correctif: l'onglet `Agenda` AJAX ne réutilise plus `fo_sessions_list_bloc.php`, trop fragile dans ce contexte; il passe maintenant par une carte FO dédiée, à l'image de `Sessions passées`.
  - addendum correctif JS: le sélecteur de saison des leaderboards appelait `loadOverview(false, year, quarter)`, ce qui décalait les paramètres et rechargeait la saison courante; l'appel a été corrigé en `loadOverview(year, quarter)`.

### Vérification rapide
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PATCH 2026-04-14 - FO liste `place`: filtre géographique FR + étranger

### Contexte
- le filtre public de la liste organisateurs `/fr/place` restait limité aux départements français;
- le pattern plus robuste `Département / pays`, déjà utilisé côté agenda FO/play, couvrait pourtant déjà les pays étrangers.

### Fichiers modifiés
- `www/web/fo/modules/entites/clients/fr/fo_clients_list.php`
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`

### Effet livré
- la liste publique des organisateurs construit maintenant un seul select géographique mixte:
  - départements français réellement présents;
  - puis pays étrangers réellement présents;
- les départements conservent leur libellé référentiel complet côté FO (`n° + nom`);
- l'ancienne route SEO `/place/departement/...` reste acceptée comme fallback de sélection initiale, mais le select public repose désormais sur `id_zone_departement` comme l'agenda.
- addendum:
  - `France` est explicitement exclue de la section `pays` dans `agenda` et `place`;
  - le header FO a été durci avec `white-space: nowrap` sur les liens desktop et dropdown, puis le libellé `Agenda des soirées jeux dans les bars` a été raccourci en `Agenda des soirées jeux` sans réintroduire de retour à la ligne parasite.

## PATCH 2026-04-14 - Archive FO `place`: hardening helper quiz legacy

### Contexte
- l'onglet `Sessions passées` de certaines fiches établissement FO déclenchait un `500` sur l'endpoint AJAX `section=archive`;
- le chemin de rendu archive réutilise `fo_sessions_list_bloc.php`, qui appelle encore `cotton_quiz_get_classement_session(...)` pour les vieilles sessions quiz passées afin de tenter d'afficher la photo gagnante.

### Fichiers modifiés
- `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`

### Effet livré
- `cotton_quiz_get_classement_session(...)` caste maintenant l'id session en entier et retourne `[]` si:
  - l'id est invalide;
  - ou la requête SQL échoue;
- cela évite le fatal `fetch_assoc() on bool` sur les chemins archives FO / legacy quiz.

### Vérification rapide
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`

## PATCH 2026-04-14 - Archive FO `place`: carte dédiée AJAX

### Contexte
- malgré le hardening du helper quiz legacy, l'endpoint AJAX `section=archive` pouvait encore tomber sur d'autres branches historiques du bloc `fo_sessions_list_bloc.php`;
- pour l'onglet `Sessions passées` de la fiche établissement, on n'a pas besoin de toute cette logique legacy.

### Fichiers modifiés
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

### Effet livré
- le rendu archive AJAX `place` passe maintenant par une carte dédiée plus simple:
  - visuel jeu / lieu,
  - date,
  - événement éventuel,
  - lieu,
  - CTA `Voir les résultats`;
- l'agenda FO continue d'utiliser le bloc historique `fo_sessions_list_bloc.php`;
- l'archive FO `place`, elle, n'en dépend plus, ce qui réduit fortement le risque de `500` sur un cas legacy.

### Vérification rapide
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`

### Vérification rapide
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_list.php`
- `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list.php`

## PATCH 2026-04-15 - FO `place` / `Classements`: podium agrégé

### Contexte
- l'onglet `Classements` de la fiche `place` affichait uniquement le tableau `Top 10`;
- le besoin est d'ajouter un podium au-dessus du classement agrégé, construit comme côté `pro`, mais avec le style du podium déjà présent sur la page détail d'une session terminée du site.

### Fichiers modifiés
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

### Effet livré
- chaque bloc de classement (`Blind Test`, `Bingo Musical`, `Cotton Quiz`) affiche désormais un podium juste avant le titre `Top 10`;
- les données viennent du contexte global déjà calculé:
  - `players_podium` pour `Blind Test` et `Bingo Musical`;
  - `teams_podium` pour `Cotton Quiz`;
- le rendu réutilise les codes visuels du podium de session terminée:
  - header de rang or / argent / bronze;
  - photo si disponible;
  - fallback trophée / médaille sinon;
  - score et nombre de participations sous le libellé.
- addendum desktop:
  - le podium est désormais rendu sur toute la largeur au-dessus du duo `tableau + sessions récentes`;
  - la limite de la colonne droite `sessions récentes` revient à un calcul basé sur le seul tableau `Top 10`, pour réaligner visuellement la colonne droite sur la table desktop.
  - la ligne desktop `tableau + sessions récentes` applique aussi un espacement horizontal plus marqué pour mieux répartir les deux colonnes.
  - audit structurel:
    - l'alignement visuel desktop conserve `padding-top: 3rem` sur `.place-leaderboard-recent-sessions-col`;
    - la colonne `sessions récentes` repose maintenant sur un wrapper simple centré à largeur max, sans grille Bootstrap interne.
- addendum responsive:
  - le tableau `Top 10` utilise maintenant un wrapper explicite `place-leaderboard-table-responsive` pour fiabiliser le scroll horizontal sur mobile;
  - la colonne du tableau force aussi `min-width: 0`, afin de laisser l'overflow horizontal fonctionner dans la grille flex Bootstrap;
  - sur mobile, `.table-classement` a désormais une largeur minimale pour éviter le tassement des colonnes et réactiver le scroll horizontal attendu;
  - un `rem` orphelin a été retiré du CSS dans cette zone.

### Vérification rapide
- `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## PATCH 2026-04-15 - Play `Classements`: podium agrégé + photos stabilisées

### Contexte
- la page `Classements` de `play` n'affichait jusque-là que les tableaux agrégés saisonniers;
- le besoin est d'ajouter un podium agrégé au-dessus de ces classements, en reprenant le style déjà utilisé sur les pages de sessions historiques `play`;
- en parallèle, l'affichage des photos podium `play` redevenait instable selon le domaine servi.

### Fichiers modifiés
- `play/web/ep/modules/communication/home/ep_home_leaderboards.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

### Effet livré
- chaque bloc jeu de la page `Classements` `play` affiche désormais un podium agrégé avant le tableau saisonnier;
- le rendu réutilise les codes visuels du podium des fiches sessions historiques `play`;
- les photos podium sont normalisées vers `www/upload` côté `play`, avec fallback automatique final sur `www prod` si l'URL principale échoue;
- addendum:
  - si la source arrive déjà en `www prod`, le helper global remappe maintenant quand même vers `www` du serveur courant si le chemin relatif est reconstructible, au lieu de conserver `prod`;
- le contexte leaderboard `play` marque aussi les lignes podium courantes via `is_current`.

### Vérification rapide
- `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_leaderboards.php`
- `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-15 - Play config: détection `dev` via `HTTP_HOST`

### Contexte
- sur certains hôtes dev, `play` retombait en environnement `prod` car la détection ne regardait que `SERVER_NAME` et n'acceptait qu'un host exact;
- effet visible: certaines URLs publiques, dont les photos podium, pouvaient être construites directement vers `www prod` alors que l'asset existait bien en `dev`.

### Fichiers modifiés
- `play/web/config.php`

### Effet livré
- `play` lit maintenant `HTTP_HOST` en priorité, puis `SERVER_NAME` en fallback;
- tous les hosts `*.dev.cotton-quiz.com` sont reconnus comme `dev`;
- les résolutions d'URLs publiques réutilisent donc correctement les racines `dev` quand le site est servi depuis un hôte dev.

### Vérification rapide
- `php -l /home/romain/Cotton/play/web/config.php`

## 2026-04-16 — Formulaire lieu `pro` et descriptions harmonisées

- PRO `Gérer mon lieu`: le formulaire affiche maintenant un aperçu du visuel courant avec consigne de conservation, au lieu d'un simple input fichier brut.
- Descriptions lieu (`global` + `pro` + `www`): `descriptif_court` et `descriptif_long` passent désormais par une normalisation commune texte simple, avec nettoyage des anciens `<br>` / balises et conservation propre des retours à la ligne.
- `Ma communauté` et la page publique `place` réutilisent maintenant ce rendu harmonisé, ce qui supprime les écarts historiques entre le formulaire back-office et l'affichage final.
- Widget home `Ma communauté`: il suit maintenant la même règle d'accès que la page `Ma communauté` et adapte son texte selon que le bloc d'infos générales du lieu est visible ou non.

## 2026-04-16 — Ma communauté: fallback classements sur saison courante vide

- Correctif coté `global`: `app_client_joueurs_dashboard_context_compute(...)` ne sort plus d'un contexte filtré "vide" sans repasser par une finalisation commune des flags/messages.
- Effet visible: quand la synthèse existe mais qu'aucun classement exploitable n'est disponible pour la saison retenue par défaut, `Ma communauté` affiche maintenant correctement le message `Les données actuelles ne permettent pas d'afficher de classement sur la période choisie.` au lieu de rester bloquée silencieusement sur la saison courante.
- La même finalisation est réappliquée après fusion du cache synthèse dans `app_client_joueurs_dashboard_get_context(...)` et `app_client_joueurs_dashboard_get_context_fo_place(...)`.

## 2026-04-16 — FO `place`: fallback image des cartes archive

- Correctif coté `www`: les cartes `Sessions passées` injectées en AJAX ne rendent plus leur image principale en `src="#" + data-src`.
- Effet visible: quand aucune photo gagnant n'est disponible, le fallback visuel de jeu s'affiche de nouveau correctement dans la carte archive.
- La logique `onerror` de fallback secondaire reste active pour les cas où une vraie photo gagnant est fournie mais échoue au chargement.

## 2026-04-16 — Visuels sessions quiz: priorité aux séries illustrées

- Correctif coté `global`: `app_jeu_get_detail(...)` ne retombe plus automatiquement sur `default_cotton_quiz.jpg` pour les quizzes multi-séries.
- Un nouveau helper `app_cotton_quiz_get_series_visual_src(...)` prend la dernière série du quiz qui porte un vrai visuel custom.
- Les lots dont l'image est encore une simple copie du `default_cotton_quiz.jpg` sont ignorés dans cette sélection.
- Effet visible attendu sur tous les consumers qui réutilisent `app_jeu_get_detail(...)`: cartes de sessions à venir/passées, pages session, etc.

## 2026-04-16 — Branding Blind Test: traces diagnostic cote `global`

- Instrumentation ajoutee dans `global/web/app/modules/general/branding/app_branding_ajax.php`.
- Les logs `error_log` prefixees `[branding:trace]` couvrent maintenant:
  - `get:resolved`
  - `save:target_resolved`
  - `save:completed`
  - `delete_preview:evaluated`
- But: verifier en conditions reelles si la coche `Utiliser ce design pour mes prochaines sessions` ecrit bien un `branding_client` mais laisse la session `Blind Test` resolue en `branding_session`.
- Verification rapide:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_ajax.php`
- Correctif complementaire:
  - `app_branding_ajax.php` ne depend plus de `app_session_get_detail(...)` pour recuperer le contexte session minimal;
  - le module lit maintenant directement `championnats_sessions`, ce qui supprime le fatal `Call to undefined function app_blind_test_get_detail()` observe sur les requetes branding `Blind Test`.

## 2026-04-16 — Games branding: persistance du visuel recadre

- Audit cible dans `games/web/includes/canvas/core/session_modals.js`.
- Diagnostic confirme:
  - la modale organizer recadre bien le visuel en local via `fileToCoverDataURL(...)`;
  - la sauvegarde `branding_visuel` renvoyait encore prioritairement le fichier source `_visuelFile`, ce qui pouvait reintroduire un rendu trop haut apres reload.
- Correctif livre:
  - ajout du helper `getBrandingVisualPayload(...)`;
  - le save du visuel branding ne reutilise plus le fichier source brut quand le champ est en mode `custom`.
- Effet attendu:
  - le visuel relu cote organizer reste coherent avec l'apercu modale et n'heritera plus du cadrage du fichier source brut.

## 2026-04-16 — Games branding: apercu leger, upload HD

- Retour utilisateur apres le correctif precedent:
  - le cadrage etait redevenu correct, mais la qualite finale dans l'UI master etait trop basse.
- Cause:
  - la sauvegarde reutilisait alors le derive preview `600x240`, compresse pour la modale.
- Correctif livre:
  - `session_modals.js` genere maintenant deux derives distincts a partir du meme fichier source:
  - preview `600x240` en JPEG `0.8` pour la modale;
  - upload `1600x640` en JPEG `0.92` pour `branding_visuel`.
- Effet attendu:
  - meme cadrage cover qu'en modale;
  - meilleure nettete apres reload organizer / UI master.

## 2026-04-16 — Branding visuel: retour au fichier source brut cote `games`, ratio final force cote `global`

- Retour utilisateur:
  - la solution derivee cote `session_modals.js` ne convenait pas;
  - la demande est de traiter le probleme de taille/proportions directement dans `global`.
- Correctif livre:
  - `games/web/includes/canvas/core/session_modals.js`
    - retour au flux simple:
      - preview locale recadree pour la modale;
      - upload prioritaire du fichier source brut pour `branding_visuel`;
  - `global/web/app/modules/general/branding/app_branding_functions.php`
    - `app_general_branding_visuel_uploader(...)` ne rabaisse plus la cible `visuel` a la taille source;
    - la cible demandee par `app_branding_ajax.php` (`1600x640`) reste appliquee par le helper serveur, ce qui preserve le ratio final du branding.
- Effet attendu:
  - le visuel branding garde les proportions finales attendues cote serveur;
  - le front `games` ne transporte plus de derive HD intermediaire.

## 2026-04-16 — Branding visuel: crop cover explicite cote `global`

- Retour utilisateur:
  - le visuel uploadé ne respectait toujours pas strictement les proportions demandées;
  - attendu: couper et centrer si nécessaire, mais toujours tenir dans le gabarit impose.
- Correctif livre:
  - `global/web/app/modules/general/branding/app_branding_functions.php`
    - ajout de `app_general_branding_cover_fit(...)`;
    - apres upload, le visuel branding actif est maintenant recadre par le centre et re-genere exactement aux dimensions demandees;
    - le traitement couvre les formats `png`, `jpg`, `webp`, `gif` (avec fallback `jpg` si `webp` n'est pas dispo en sortie).
- Effet attendu:
  - le visuel branding final tient toujours dans le gabarit impose;
  - si l'image source est trop large ou trop haute, elle est coupee de facon centree plutot que laissee hors ratio.

## 2026-04-16 — Duplication branding client -> session: copie medias securisee

- Retour utilisateur:
  - lors de la suppression d'un branding client, les sessions programmees censees etre gelees en `branding_session` perdaient `logo` et `visuel`;
  - comme le `branding_session` restait prioritaire, aucun fallback ne s'appliquait ensuite.
- Correctif livre:
  - `global/web/app/modules/general/branding/app_branding_functions.php`
    - ajout de `app_general_branding_dir_delete(...)` et `app_general_branding_prepare_target_assets(...)`;
    - `app_general_branding_duplicate_to_target(...)` prepare maintenant un staging des assets, verifie la copie, puis remplace atomiquement le dossier cible;
    - si la copie medias echoue, la fonction retourne `0` avant creation/mise a jour de la ligne `general_branding` cible.
- Effet attendu:
  - une session programmee ne doit plus se retrouver avec un `branding_session` sans medias actifs;
  - si la duplication echoue, le branding session n'est pas ecrit et le fallback amont reste possible.

## 2026-04-17 — Sessions: bascule agenda / historique alignee multi-repos

- Retour utilisateur:
  - les fiches detail `pro` / `play` / `www` consideraient deja certaines sessions comme terminees et affichaient podium / classement;
  - plusieurs listes continuaient pourtant a les garder dans l'agenda tant que la date n'avait pas change;
  - suspicion initiale: `play`, `www` et le widget home agenda `pro`.
- Audit confirme:
  - `app_sessions_get_liste(...)` reste base sur `cs.date >= CURDATE()` / `< CURDATE()`;
  - l'agenda principal `pro` re-filtrait deja correctement via `app_session_is_archive(...)`;
  - `play` agenda, `www` agenda / fiche `place`, et le widget home agenda `pro` restaient dates-only.
- Correctif livre:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - ajout de `app_session_list_item_is_archive(...)`;
    - ajout de `app_sessions_filter_by_archive_state(...)`;
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
    - re-filtrage des sessions agenda via le helper partagé;
    - sélecteur organisateur reconstruit depuis cette liste nettoyée;
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
    - le bloc home `Tes prochaines sessions de jeu` retire maintenant aussi les sessions déjà terminées;
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
    - l'onglet `Agenda` d'une fiche `place` re-filtre désormais les sessions à venir;
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list.php`
    - la page publique `agenda` re-filtre les sessions et ses listes de filtres sur la même règle;
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
    - le badge `Jeu terminé` s'appuie sur le helper partagé;
  - `www/web/fo/modules/widget/fr/fo_widget_cotton_agenda.php`
    - le widget agenda retire aussi les sessions déjà terminées;
  - `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
    - les widgets home `Mon agenda` / `Agenda du réseau` re-filtrent les sessions, et leurs compteurs suivent ce volume nettoyé.
- Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_list.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/widget/fr/fo_widget_cotton_agenda.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`

## 2026-04-17 — Leaderboards agreges: prenom seul + uppercase harmonises

- Retour utilisateur:
  - sur les leaderboards agreges `www` `blindtest` / `bingo`, certains joueurs restaient affiches en `prenom + nom` ou avec des pseudos en casse libre;
  - attendu: `prenom` seul si pas de pseudo, et uppercase uniforme sur les labels de podium / classement.
- Diagnostic:
  - la source d'affichage agregée passe par `global/web/app/modules/entites/clients/app_clients_functions.php`;
  - le helper `app_client_joueurs_dashboard_player_label_get(...)` et la construction finale des lignes ne forçaient pas encore l'uppercase.
- Correctif livre:
  - `app_client_joueurs_dashboard_player_label_get(...)` renvoie maintenant `pseudo` ou `prenom` en uppercase;
  - ajout de `app_client_joueurs_dashboard_label_display_format(...)`;
  - `app_client_joueurs_dashboard_sorted_counts_get(...)` applique ce format a toutes les lignes finales des leaderboards agreges, y compris equipes.
- Effet attendu:
  - `pro`, `play` et `www` affichent maintenant des podiums/classements agreges en uppercase coherent;
  - les joueurs `blindtest` / `bingo` ne doivent plus retomber sur `prenom + nom`.
- Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## 2026-04-17 — Resultats de session: uppercase harmonise aussi sur `pro` / `play` / `www`

- Retour utilisateur:
  - test `pro` confirme que l'agrege `Blind Test` est bien corrige;
  - en revanche, la fiche resultat de session gardait encore un mix de casse (`Poulette`, `ROMAIN`, `Remo`).
- Diagnostic:
  - les fiches resultat s'appuient sur `global/web/app/modules/jeux/sessions/app_sessions_functions.php`, pas sur les seuls helpers leaderboard agreges;
  - les labels de session n'etaient pas encore reformates de maniere uniforme avant rendu.
- Correctif livre:
  - ajout de `app_session_results_label_display_format(...)`;
  - `app_session_results_competition_rows_rank(...)`, `app_session_results_podium_from_rankings(...)` et `app_session_results_podium_normalize(...)` appliquent maintenant l'uppercase sur les labels;
  - `app_session_results_player_label_get(...)` conserve `pseudo` ou `prenom` seul, avec retour en uppercase;
  - le cas `Bingo Musical` est aussi couvert explicitement sur le podium de phases et la liste joueurs.
- Effet attendu:
  - les fiches session `pro` / `play` / `www` affichent elles aussi des labels harmonises en uppercase;
  - plus de melange de casse entre podium et classement complet sur une meme session.
- Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## 2026-04-17 — WWW `Sessions passées`: session du jour terminee maintenant visible

- Retour utilisateur:
  - sur `www`, une session du jour deja terminee etait bien retiree de l'onglet `Agenda`;
  - mais elle n'apparaissait toujours pas dans `Sessions passées`;
  - `pro` et `play` etaient deja OK.
- Diagnostic:
  - `fo_clients_view_archive_sessions_get(...)` appelait l'archive globale avec `include_upcoming_sessions = 0`;
  - le helper ne rechargeait donc jamais les sessions du jour encore `date = today`, meme si elles etaient deja archivees par `app_session_is_archive(...)`.
- Correctif livre:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
    - passage de `include_upcoming_sessions` a `1` dans `fo_clients_view_archive_sessions_get(...)`.
- Effet attendu:
  - une session du jour deja terminee quitte l'onglet `Agenda` et apparait maintenant aussi dans `Sessions passées` sur la fiche `place`.
- Verification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## 2026-04-17 — WWW `place`: leaderboard `bingo` absent apres une session du jour, et ordre `play` incoherent

- Retour utilisateur:
  - un test `bingo` remontait bien dans `pro` (`Ma communauté`) et dans `play` (`Classements`);
  - mais il n'apparaissait pas sur `www` dans l'onglet `Classements` de la fiche `place`;
  - en plus, `play` pouvait afficher `bingo` avant `blindtest`, contrairement a `pro`.
- Diagnostic:
  - `app_client_joueurs_dashboard_get_context_fo_place(...)` relisait un cache de session journalier cote `global`, donc un navigateur ayant charge `www/place` avant la fin de session pouvait garder un contexte leaderboard stale jusqu'au lendemain;
  - `app_joueur_leaderboards_get_context(...)` laissait l'ordre des jeux dependre de l'ordre d'apparition des participations detectees, sans ordre prefere explicite.
- Correctif livre:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
    - le contexte leaderboard `fo_place` est maintenant recalcule au reload et annote `fo_place_leaderboards_source = direct_compute`;
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - les jeux `play` sont reordonnes en `blindtest`, `bingo`, `quiz`, puis jeux additionnels eventuels.
- Effet attendu:
  - `www/place` affiche le leaderboard agrege `bingo` des qu'une session terminee l'alimente, sans attendre une invalidation de session PHP;
  - `play` retrouve le meme ordre de jeux que `pro` et `www`.
- Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## 2026-04-17 — WWW `place`: podium agrégé `bingo` regroupé dans une seule colonne

- Retour utilisateur:
  - sur `www`, le podium agrégé `Bingo Musical` empilait plusieurs `#1` dans la meme carte;
  - le comportement attendu est celui des autres jeux: une carte par ligne de podium, meme si plusieurs participants partagent le meme rang.
- Diagnostic:
  - `fo_clients_view_leaderboard_podium_cards_get(...)` gardait une branche speciale `bingo` qui construisait toujours 3 cartes fixes (`#1`, `#2`, `#3`) en cumulant toutes les lignes d'un rang dans la meme carte.
- Correctif livre:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
    - suppression de la branche speciale `bingo`;
    - reutilisation de la logique standard: tri stable des lignes podium puis une carte par ligne jusqu'a 3 cartes.
- Effet attendu:
  - sur `www/place`, trois gagnants ex-aequo `#1` en `Bingo Musical` sont maintenant rendus sur trois cartes distinctes, comme sur les autres podiums agreges.
- Verification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## 2026-04-17 — WWW sessions `quiz`: theme parfois detaille, parfois absent ou duplique

- Retour utilisateur:
  - sur le site `www`, le theme `quiz` etait parfois bien affiche (`4 series`), parfois absent, et parfois reduit a un doublon `Cotton Quiz Cotton Quiz`;
  - la contrainte UX demandee est un libelle compact sur les cartes et le titre detail: `1 serie` / `x series`.
- Diagnostic:
  - les cartes session `www` lisaient seulement `app_jeu_get_detail(...)`, donc sans priorite explicite pour les metadonnees `lot_ids` de la session;
  - `app_sessions_get_liste(...)` n'exposait pas encore `lot_ids` ni `quiz_series_label`, ce qui empechait les listes de reutiliser la meme source fiable que la fiche detail;
  - la page detail `www` calculait deja `quiz_series_label`, mais le `h1` continuait d'afficher `app_jeu_detail['theme']`.
- Correctif livre:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - `app_sessions_get_liste(...)` remonte maintenant `lot_ids` et enrichit les lignes avec `quiz_series_count`, `quiz_series_label`, `quiz_series_names` pour `quiz`;
    - `app_session_get_detail(...)` applique cet enrichissement aux types `1` et `5`;
    - `app_jeu_get_detail(...)` expose aussi les metadonnees de series cote `quiz` legacy quand elles existent.
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
    - ajout d'un helper de libelle compact pour les badges de cartes `Agenda` / `Sessions passées`;
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
    - les cartes agenda du site reutilisent ce libelle compact;
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
    - le `h1` detail session affiche `quiz_series_label` en priorite.
- Effet attendu:
  - les cartes session `www` et le titre detail affichent des libelles courts `1 serie` / `x series` quand la session `quiz` le permet;
  - le doublon `Cotton Quiz Cotton Quiz` disparait.
- Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`

## 2026-04-17 — Agendas `pro` / `play` / `www`: mutualisation du label compact `quiz`

- Retour utilisateur:
  - verification demandee sur les labels `quiz` accoles aux sessions dans `pro` home / agenda principal et dans les cartes agenda `play`;
  - attente: mutualiser la regle tout en gardant un fallback pour les anciens formats de quiz.
- Diagnostic:
  - `play` utilisait deja partiellement `quiz_series_label`, mais seulement pour le type `5`;
  - `pro` agenda principal reconstruisait encore les noms de lots `Cotton Quiz` un par un puis les concaténait;
  - le widget home `pro` utilisait seulement `app_jeu_detail['theme']`;
  - `www` avait encore un helper local equivalent.
- Correctif livre:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - ajout de `app_session_quiz_compact_label_get(...)`;
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
    - remplacement de la concatenation manuelle des noms de lots par le helper partagé;
  - `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
    - raccord du widget home au helper partagé;
  - `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
    - raccord des cartes agenda au helper partagé;
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
    - raccord des écrans `www` au même helper.
- Effet attendu:
  - les agendas `pro`, `play` et `www` affichent maintenant la même forme courte `1 serie` / `x series` quand elle existe;
  - les anciens formats de quiz conservent un fallback vers `theme`;
  - le drift entre concaténation de noms de lots, `theme` brut et `quiz_series_label` disparaît.
- Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`

## 2026-04-17 — Fiches détail `play` / `www`: mention sous les thématiques

- Retour utilisateur:
  - demande d'ajouter une petite mention sous la présentation des thématiques (`playlist` ou `series`) dans les cartes détail de session `play` et `www`;
  - texte attendu: `(Sous réserve de modification par l'organisateur.)`.
- Diagnostic:
  - `play` affiche déjà le bloc thématique directement dans `ep_sessions_inscription_form.php`;
  - `www` expose visiblement le bloc `Séries programmées` pour `Cotton Quiz`, mais pas de bloc playlist générique actif dans la carte résumé actuelle.
- Correctif livre:
  - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
    - ajout de la mention sous le bloc thématique;
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
    - ajout de la mention sous `Séries programmées`.
- Effet attendu:
  - les fiches détail `play` et `www` rappellent discrètement que la programmation peut encore évoluer;
  - la mention n'apparaît pas sur les sessions déjà archivées.
- Verification:
  - `php -l /home/romain/Cotton/play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`

## 2026-04-17 — Fiche session `www`: bloc playlist manquant pour `blindtest` / `bingo`

- Retour utilisateur:
  - sur `www`, les fiches détail de sessions à venir `Blind Test` / `Bingo Musical` n'affichaient pas le bloc de présentation de la playlist entre la date et le lieu;
  - attendu: `Playlist : {nom_playlist}` puis la mention de réserve.
- Diagnostic:
  - le bloc visible ne couvrait que `Cotton Quiz` via `Séries programmées`;
  - le rendu générique `theme_libelle/theme` pour les jeux musicaux était présent seulement dans du code commenté.
- Correctif livre:
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
    - ajout d'un bloc visible `Playlist` pour les types `3`, `4`, `6` quand `theme` est renseigné;
    - ajout de la mention `(Sous réserve de modification par l'organisateur.)` sous ce bloc pour les sessions non archivées.
- Effet attendu:
  - les fiches détail `Blind Test` / `Bingo Musical` sur `www` affichent maintenant la playlist comme les fiches `quiz` affichent leurs séries;
  - la réserve de modification reste cohérente entre tous les types de jeux.
- Verification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`

## 2026-04-29 — Stripe ABN: relance visible sans coupure avant cloture finale

- Demande:
  - conserver la configuration Stripe de relance automatique;
  - ne pas couper une offre Cotton au premier `invoice.payment_failed`;
  - afficher un bandeau PRO au compte payeur pendant `past_due` / `unpaid`;
  - synchroniser l'offre en `Terminee` uniquement quand Stripe termine reellement la subscription;
  - tracer les clotures dues a impaye Stripe dans `ecommerce_offres_to_clients.commentaire`.
- Audit:
  - endpoint webhook unique: `pro/web/ec/ec_webhook_stripe_handler.php`;
  - rattachement subscription -> offre: `ecommerce_offres_to_clients.asset_stripe_productId`;
  - etat canonique `Terminee`: `id_etat=4`;
  - `id_etat=1` reste un flux `Non payee`, annule ensuite par cron en `id_etat=10`, donc non retenu pour V1;
  - portail Stripe existant: `app_ecommerce_stripe_billing_portal_session_prepare(...)`.
- Correctif livre:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - helpers de date terminale Stripe, append idempotent commentaire, sync terminale, lecture live bandeau paiement;
  - `pro/web/ec/ec_webhook_stripe_handler.php`
    - `invoice.payment_failed` enrichit le log/admin mais ne modifie pas l'offre;
    - `customer.subscription.updated` en `past_due` ne modifie pas l'offre;
    - `status=canceled` / `customer.subscription.deleted` passent l'offre en `id_etat=4`;
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
    - bandeau `Paiement de votre abonnement en attente` avec CTA facture Stripe ou portail;
  - `pro/web/ec/modules/communication/home/ec_home_index.php`
    - meme bandeau sur la home PRO, au-dessus de la grille widgets, pour ne pas dependre des variantes du widget `Mon offre`;
  - `pro/web/ec/modules/widget/ec_widget_ecommerce_offre_client_bloc.php`
    - confirme encore inclus par la home, mais sans porter le bandeau Stripe pour eviter les doublons.
- Documentation:
  - `CHANGELOG.md`
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/global/TASKS.md`
  - `canon/repos/pro/README.md`
  - `notes/plan_migration_reseau_branding_contenu.md`
- Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php`
- `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_ecommerce_offre_client_bloc.php`
- Recette Stripe a faire:
  - simuler une subscription test en `past_due`;
  - verifier absence de coupure Cotton et affichage du bandeau payeur;
  - regulariser puis verifier disparition du bandeau;
  - simuler la cloture finale et verifier `id_etat=4` + commentaire impaye si `payment_failed`;
  - rejouer le webhook pour confirmer l'idempotence du commentaire.

## Pro — Stripe ABN V1.1: portail Stripe comme CTA principal — 2026-04-29

- Demande:
  - remplacer le CTA principal vers `hosted_invoice_url` par le portail Stripe client Cotton;
  - ajouter un `return_url` Cotton explicite avec `stripe_billing_return=1`;
  - relire Stripe live au retour pour faire disparaitre immediatement le bandeau si la subscription repasse `active`;
  - ne plus afficher `next_payment_attempt` comme date limite.
- Correctif livre:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
    - le portail existant `app_ecommerce_stripe_billing_portal_session_prepare(...)` est prepare avec `/extranet/account/offers?stripe_billing_return=1`;
    - le CTA principal devient `Regulariser mon abonnement`;
    - `hosted_invoice_url` n'est plus affiche dans le bandeau;
    - le retour affiche `Votre paiement a bien été régularisé.` seulement si l'URL porte `stripe_billing_context=payment_failed`, si Stripe repond `active` et si la derniere facture est `paid` ou soldee;
    - un retour post-paiement initial classique avec seulement `stripe_billing_return=1` ne declenche pas ce message;
    - les portails standards de `Mon offre` reviennent sans contexte impaye; seul le CTA du bandeau impaye prepare une session portail avec `stripe_billing_context=payment_failed`;
  - `pro/web/ec/modules/communication/home/ec_home_index.php`
    - meme logique sur la home PRO avec retour `/extranet/dashboard?stripe_billing_return=1&stripe_billing_context=payment_failed`;
    - le bandeau reste au-dessus de la grille widgets.
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - le helper de notice remonte maintenant `amount_remaining` et `latest_invoice_paid`, y compris quand la subscription est redevenue `active`.
- Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_ecommerce_offre_client_bloc.php`
- Recette Stripe restante:
  - confirmer que le CTA ouvre le portail Stripe et revient vers Cotton;
  - regulariser puis verifier disparition du bandeau apres retour;
  - verifier que le bandeau reste si Stripe conserve `past_due`;
  - verifier que le lien facture Stripe n'est plus affiche dans le bandeau.

## Pro — Stripe ABN V1.1: trace commentaire des paiements echoues — 2026-04-29

- Demande:
  - rendre visible dans le commentaire de l'offre qu'un paiement Stripe est en echec avant meme la cloture effective.
- Correctif livre:
  - `pro/web/ec/ec_webhook_stripe_handler.php`
    - sur `invoice.payment_failed`, ajout d'une ligne append-only:
      `Paiement Stripe en échec (invoice in_xxx, tentative N) - relance automatique Stripe en cours (subscription sub_xxx).`;
    - deduplication par `invoice` + `attempt_count` via `app_ecommerce_offre_client_commentaire_append_once(...)`;
    - fallback de rattachement par `asset_stripe_productId` si l'id d'offre est absent des metadata;
    - aucun changement de statut d'offre, aucune date de fin, aucune commande/facture Cotton creee.
- Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php`

## Global / Pro — Config Stripe isolée du contexte applicatif — 2026-04-30

- Demande:
  - éviter que le bootstrap Stripe charge `global_config.php` dans un runtime `pro` et écrase `$conf['site_url']`, ce qui vidait le fallback visuel du widget home `Ma communauté`.
- Correctif livre:
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
    - le fallback de `lib_Stripe_bootstrapConfig()` charge maintenant `global_config_stripe.php` au lieu de `global_config.php`;
  - `global/web/global_config.php`
    - inclut `global_config_stripe.php` pour conserver les clés Stripe dans le contexte `global`;
  - `global/web/global_config_stripe.php`
    - nouveau fichier de configuration Stripe dédié, sans paramètres de contexte applicatif;
  - `pro/web/ec/modules/widget/ec_widget_client_lieu_resume.php`
    - retrait du commentaire HTML temporaire `debug-community-widget`.
- Points d'attention:
  - `global/web/global_config.php` et `global/web/global_config_stripe.php` sont ignorés par Git et doivent être gérés/déployés comme fichiers de configuration serveur;
  - `.gitignore` référence maintenant `web/global_config_stripe.php`.
- Docs touchees:
  - `canon/repos/global/TASKS.md`
  - `canon/repos/pro/TASKS.md`
  - `HANDOFF.md`
- Verification:
  - `php -l /home/romain/Cotton/global/web/global_config.php`
  - `php -l /home/romain/Cotton/global/web/global_config_stripe.php`
  - `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/stripe_sdk_functions.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_resume.php`
  - test runtime: `lib_Stripe_getPrivateApiKey()` conserve `$conf['site_url']['prod']='https://pro.cotton-quiz.com'`.

## Games Bingo organizer: badges de phase pendant session — 2026-05-05

- `games/web/includes/canvas/core/games/bingo_ui.js` déclenche maintenant `bingo/medals/updated` après `srv/phaseOver` quand un gagnant ajoute ou améliore une médaille.
- Les ids gagnants Bingo sont resolus vers la clé `playerId` utilisée par la liste organizer, avec fallback legacy, pour éviter de stocker la médaille sous une clé non rendue.
- `games/web/includes/canvas/core/canvas_display.js` rafraîchit aussi la liste organizer compacte sur `bingo/medals/updated`, y compris pendant `En cours`; auparavant ce chemin n'était couvert qu'en pause.
- Le rendu des badges Bingo teste aussi les ids legacy/DB et le mapping grille de la ligne joueur, ce qui couvre le cas du joueur GM en iframe dont l'update live peut remplacer temporairement l'id canonique par une autre forme.
- `games/web/includes/canvas/core/boot_organizer.js` réhydrate `Preload.phase_winners` aussi en session Bingo en cours, et reconstruit `medalsById`; garde explicite post-reset démo via `bingo_postreset=1`.
- Après reset d'une démo Bingo terminée, `boot_organizer.js` utilise `bingo_postreset=1` comme signal parent et émet `organizer/demoPostResetReady` seulement si le preload confirme `En attente`; `canvas_display.js` vide puis reconfigure l'iframe GM avec son URL normale.
- L'hydratation snapshot conserve les médailles déjà connues si le snapshot ne contient pas les notifications `PlayerWin`; pas de changement de contrat WS ni de logique grille/player.
## WWW: landings operations automatiques depuis TdR — 2026-05-11

### Resume
- demande: supprimer la dependance fonctionnelle a `www/web/lp/includes/config/lp_operations.php` et publier automatiquement les landings des TdR/operations actives;
- correction: `/lp/operation/{slug}` resout maintenant une operation BO par `operations_evenements.seo_slug`, retrouve sa TdR via le client rattache, puis utilise l'abonnement/support reseau actif uniquement pour piloter badge, CTA et wording; en fallback, le slug peut encore correspondre directement a `clients.seo_slug`;
- rendu: nom, accroche, descriptif, logo, visuel, couleurs et jeux reseau sont lus depuis la TdR/branding/contenus partages, avec fallbacks Cotton;
- periode: badge informatif calcule depuis l'offre support reseau (`date_debut`/`date_fin`, puis dates de facturation en fallback);
- CTA: lien unique vers `/utm/reseau/{slug}` avec phrase compte existant; aucune logique parallele d'affiliation, inscription ou activation;
- wording: clarification Cotton neutre, sans promesse commerciale distributeur ajoutee;
- compatibilite: anciennes LP historiques conservees; route operation inconnue/inactive => 404 simple.

### Fichiers modifies
- `www/web/lp/lp.php`
- `www/web/lp/includes/css/lp_custom.css`
- `www/web/.htaccess`
- `www/web/lp/includes/config/lp_operations.php` (supprime)
- `documentation/canon/repos/www/README.md`
- `documentation/canon/repos/www/TASKS.md`
- `documentation/canon/entrypoints.md`
- `documentation/canon/runbooks/dev.md`
- `documentation/CHANGELOG.md`
- `documentation/HANDOFF.md`

### Verification
- journal AI Studio raw consulte avant patch; fichiers hors workspace local a recharger/controler si besoin serveur: `web/lp/lp.php`, `web/lp/includes/css/lp_custom.css`, `web/.htaccess`, `web/fo/fo.php`, scripts PRO signup/signin/authentification et helpers ecommerce reseau;
- docs publiques lues: `START.md`, `SITEMAP.txt`, `SITEMAP.ndjson`, `DOCS_MANIFEST.md`;
- `git diff --check` OK cote `www`;
- `php -l www/web/lp/lp.php` non execute: executable `php` absent du PATH Windows local;
- TODO recette serveur: tester `/lp/operation/{slug}` avec une TdR reelle, puis slug inexistant, TdR inactive, TdR sans abonnement, abonnement sans dates, design/description/jeux absents, `/utm/reseau/{slug}`, signup et signin existants.
