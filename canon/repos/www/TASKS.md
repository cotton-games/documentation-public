# Repo `www` — Tasks

## PATCH 2026-05-13 - LP reseau mention connexion compte existant
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
  - `pro/web/.htaccess`
  - `pro/web/ec/ec_sign.php`
- [x] Correctif livre:
  - le CTA principal final des LP reseau/operation reste pointe vers `/utm/reseau/{slug}`;
  - une mention secondaire est ajoutee sous le CTA final uniquement en contexte LP reseau/operation;
  - le lien `Connecte-toi` pointe vers `/utm/reseau/{slug}/signin`, qui pose le meme contexte d'affiliation puis redirige vers `signin`;
  - aucun changement des pages `ec_signup.php` / `ec_signin.php`, des wordings LP principaux, des badges, stats ou demos.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`
  - `php -l pro/web/ec/ec_sign.php`
- [ ] Verification recette serveur:
  - LP reseau sans abonnement actif: CTA signup inchange et lien signin contextualise;
  - LP reseau avec abonnement actif: CTA signup inchange et lien signin contextualise;
  - LP operation/slug specifique: slug TdR conserve;
  - LP standard hors reseau: mention absente;
  - mobile: mention lisible et lien facilement cliquable.

## PATCH 2026-05-13 - LP reseau header preuve sociale centre
- [x] Audit cible:
  - `www/web/lp/includes/css/lp_custom.css`
  - `www/web/lp/lp.php`
- [x] Correctif livre:
  - le header du bloc preuve sociale LP reseau est centre;
  - l'espace entre le sur-titre `{TdR} x Cotton depuis YYYY` et le titre principal est reduit;
  - changement limite au CSS scope `.lp-operation-proof-header`, sans toucher aux donnees ni a la logique d'affichage.
- [ ] Verification recette serveur:
  - verifier LP reseau avec bloc preuve sociale sur desktop et mobile.

## PATCH 2026-05-13 - BO TdR preview assets et Online
- [x] Audit cible:
  - `www/web/bo/master/bo_master_form.php`
  - `www/web/bo/www/modules/entites/clients/bo_module_parametres.php`
  - `global/web/lib/core/lib_core_module_functions.php`
- [x] Correctif livre:
  - les inputs masques `files_lp_logo` et `files_lp_hero` mettent a jour l'apercu existant des qu'un nouveau fichier image est selectionne;
  - le statut sous l'apercu indique le nom du fichier selectionne et le besoin d'enregistrer;
  - le formulaire detecte les champs principaux deja rendus par le module (`online`, `flag_une`);
  - le bloc complementaire `Caractéristiques` ne rend plus `On / Off` si le champ `online` existe deja dans `Informations`, ce qui supprime les doublons d'id/name.
- [x] Verification locale:
  - `php -l www/web/bo/master/bo_master_form.php`.
- [ ] Verification recette serveur:
  - verifier remplacement logo/hero depuis clic sur apercu;
  - verifier que le nouveau preview s'affiche avant sauvegarde;
  - verifier sauvegarde `Online` coche/de-coche avec un seul champ visible;
  - verifier que `A la une` reste disponible si non rendu par le module principal.

## PATCH 2026-05-13 - BO TdR assets LP reseau edition
- [x] Audit cible:
  - `www/web/bo/master/bo_master_form.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `global/web/lib/core/lib_core_module_functions.php`
- [x] Correctif livre:
  - le BO fiche client/TdR masque les dropzones `Logo LP reseau` et `Visuel principal LP reseau` quand un asset prioritaire existe deja;
  - les apercus existants deviennent cliquables pour remplacer le fichier par un nouvel upload;
  - le visuel principal affiche une recommandation editoriale 16:9 / 1600 x 900 px, sans changer le traitement serveur 1200 x 480 compatible avec le visuel de design reseau;
  - les checkbox complementaires `On / Off` et `A la une` portent maintenant explicitement `value="1"` tout en conservant le save canonique `module_modifier()`.
- [x] Verification locale:
  - `php -l www/web/bo/master/bo_master_form.php`.
- [ ] Verification recette serveur:
  - fiche TdR sans assets: verifier dropzones visibles;
  - fiche TdR avec logo/hero: verifier apercus cliquables et remplacement;
  - verifier suppression asset via checkbox;
  - verifier sauvegarde `On / Off` et `A la une` coche/de-coche.

## PATCH 2026-05-13 - LP reseau preuve sociale date TdR et micro UI
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
  - `documentation/canon/data/schema/DDL.sql`
- [x] Correctif livre:
  - le sur-titre du bloc preuve sociale affiche maintenant `{Nom_TdR} x Cotton depuis YYYY` quand `clients.date_ajout` est exploitable;
  - aucune requete supplementaire: la date vient du detail TdR deja charge via `app_client_get_detail(...)`;
  - les pictogrammes sont recentres optiquement dans leur pastille;
  - les cartes passent a une largeur homogene de 252px et les libelles courts ne passent plus a la ligne.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`.
- [ ] Verification recette serveur:
  - verifier TdR avec date creation valide, TdR avec date absente/invalide, desktop et mobile.

## PATCH 2026-05-13 - LP reseau bloc preuve sociale largeur adaptive
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
- [x] Correctif livre:
  - ajout d'une classe `lp-operation-proof-count-{n}` sur le bloc stats;
  - largeur du panneau, nombre de colonnes et largeur des cartes pilotes selon 1, 2 ou 3 indicateurs;
  - reutilisation du fond `--lp-operation-soft-bg`, deja utilise par les cartes demos reseau;
  - cartes blanches plus sobres avec bordure/ombre adoucies et pictogrammes en pastille legere;
  - espacement haut/bas resserre sans modifier les donnees, seuils, libelles, CTA ou logique d'affichage.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`.
- [ ] Verification recette serveur:
  - verifier 3 indicateurs, 2 indicateurs, 1 indicateur fort, et aucun bloc stats;
  - verifier desktop large et mobile.

## PATCH 2026-05-12 - LP reseau bloc preuve sociale UI
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
- [x] Correctif livre:
  - presentation du bloc preuve sociale sous forme de cartes statistiques;
  - ajout de pictogrammes SVG par type d'indicateur, bornes a 24px pour eviter les styles globaux;
  - panneau central plus compact et padding haut reduit pour rapprocher le bloc des demos;
  - labels courts: `Etablissements affilies`, `Sessions programmees`, `Joueurs accueillis`;
  - grille desktop adaptee a 1, 2 ou 3 indicateurs et pile mobile lisible;
  - aucune modification des donnees, seuils, requetes, CTA, dates ou position du bloc.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - `git diff --check` dans `www`.
- [ ] Verification recette serveur:
  - verifier 3 indicateurs, 2 indicateurs, 1 indicateur fort, et aucun bloc stats;
  - verifier desktop large et mobile.

## PATCH 2026-05-12 - LP reseau bloc preuve sociale
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livre:
  - ajout d'un bloc de reassurance sous les demos de la LP reseau/operation;
  - le bloc affiche `{Nom_TdR} x Cotton`, `Le reseau s'anime deja avec Cotton` et jusqu'a 3 indicateurs;
  - affichage conditionne aux seuils serveur: au moins 2 indicateurs valorisants, ou 1 indicateur tres fort;
  - seuils affichables documentes cote `global`: affilies >= 3, sessions >= 5, joueurs >= 100;
  - signaux forts documentes cote `global`: affilies >= 20, sessions >= 50, joueurs >= 1000;
  - aucun compteur a 0 ni bloc generique vide n'est rendu.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - `php -l global/web/app/modules/entites/clients/app_clients_functions.php`.
- [ ] Verification recette serveur:
  - tester TdR sous seuils, deux indicateurs OK, un indicateur tres fort, agregat joueurs absent/vide.

## PATCH 2026-05-12 - LP reseau logos hero alignes
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
- [x] Correctif livre:
  - les logos hero LP reseau/operation sont alignes a gauche au-dessus du badge periode/statut;
  - les pastilles logo partenaire et Cotton sont agrandies sur desktop et mobile;
  - le badge periode/statut demarre sur sa propre ligne sous les logos en conservant une largeur adaptee au texte;
  - le badge hero n'est plus affiche pour les statuts generiques sans dates;
  - les routes, CTA et calculs d'abonnement restent inchanges.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - `git diff --check` dans `www` et `documentation`.
- [ ] Verification recette serveur:
  - verifier LP avec logo partenaire et LP fallback Cotton seul;
  - verifier badge dates et badge `Animation cle en main`;
  - verifier desktop/mobile.

## PATCH 2026-05-12 - LP reseau couleurs dediees TdR
- [x] Audit confirme dans:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
  - `www/web/bo/master/bo_master_form.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - page Pro design reseau `pro/web/ec/modules/general/branding/*`
- [x] Correctif livre:
  - ajout de deux champs BO dedies: couleur principale LP reseau et couleur secondaire LP reseau;
  - UX coherente avec Pro: input couleur, champ hex et apercu synchronise;
  - sauvegarde via helpers globaux avec normalisation `#RRGGBB`;
  - lecture LP prioritaire avant design reseau et exposition CSS `--lp-network-primary` / `--lp-network-secondary`;
  - aucune modification des routes, CTA, badges ni logique de dates.
- [ ] Verification recette serveur:
  - TdR avec couleurs LP: verifier le hero, le CTA visuel, les accents et le footer;
  - TdR sans couleurs LP: verifier le fallback design reseau ou Cotton;
  - couleur invalide postee: verifier non persistance / neutralisation.
- [ ] Amelioration future:
  - prelevement couleur depuis logo/visuel LP si un composant image/pipette est cree ou importe plus tard.

## PATCH 2026-05-11 - LP reseau fallback demos a la une
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - logique bibliotheque PRO `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - listes FO historiques `pro/web/fo/modules/jeux/*/*_list.php` et catalogues publics des jeux
- [x] Correctif livre:
  - priorite des contenus reseau conservee via `lp_operation_network_demo_catalogue_get()`;
  - si aucun contenu reseau actif n'est partage, la LP choisit 1 demo Blind Test, 1 demo Bingo Musical et 1 demo Cotton Quiz depuis les contenus Cotton `A la une`;
  - ordre de choix: thematique saisonniere/date du jour (`flag_begin` + `jour_associe_debut/fin`), puis contenu `flag_une`, puis tri popularite 365 jours si la table reporting existe, sinon tri stable par date/id;
  - fallback robuste sur les IDs historiques existants `29 / 106 / 175` si table, colonne, helper ou requete indisponible;
  - aucune dependance directe au module PRO de bibliotheque.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`.
- [ ] Verification recette serveur:
  - LP reseau avec contenus partages: verifier que seuls les contenus reseau restent visibles;
  - LP reseau sans contenus partages: verifier les 3 demos choisies et les noms/images affichees;
  - verifier une periode saisonniere et une periode sans thematique saisonniere exploitable.

## PATCH 2026-05-11 - LP reseau rattachement demos TdR
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - scripts demo FO Blind Test, Bingo Musical, Cotton Quiz
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - resolution branding Canvas via session `id_client`
- [x] Correctif livre:
  - les formulaires demo de LP reseau/operation ajoutent uniquement un contexte public: type LP + slug canonique TdR;
  - les scripts demo resolvent ce slug cote serveur vers un compte TdR valide avant creation;
  - hors contexte LP reseau/operation, les demos gardent le compte standard `1557`;
  - les sessions creees restent des sessions demo privees/non officielles/non facturables;
  - le rattachement au compte TdR laisse la resolution branding existante appliquer le branding reseau quand il existe.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - `php -l www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_script.php`;
  - `php -l www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_script.php`;
  - `php -l www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_script.php`;
  - `php -l global/web/app/modules/jeux/sessions/app_sessions_functions.php`.
- [ ] Verification recette serveur:
  - LP avec jeux reseau, fallback `A la une`, fallback stable: session `championnats_sessions.id_client` = id TdR;
  - LP avec design reseau: organizer reprend le branding reseau;
  - page demo/catalogue hors LP: session demo conserve `id_client=1557`.

## PATCH 2026-05-11 - UI branding LP reseau / operation
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
- [x] Correctif livre:
  - co-branding hero `[logo partenaire] x [logo Cotton]` en petites pastilles separees quand un logo reseau existe, fallback Cotton seul reduit;
  - bandeau 3 arguments sur teinte claire derivee de la couleur hero, fallback blanc sans design reseau, avec tutoiement du premier argument;
  - bloc contexte masque si la surcouche BO active n'apporte aucun contenu/logo/visuel exploitable;
  - retrait du fallback public automatique sur description TdR/generique pour le bloc contexte;
  - carte contexte plus lisible avec label `Invitation partenaire`, accent couleur reseau, logo ou visuel existant;
  - accents couleur reseau appliques aux titres de section et numeros du mode d'emploi;
  - CTA final conserve, avec bouton toujours calcule selon contexte.
- [x] Contraintes respectees:
  - aucun nouveau champ BO;
  - aucune migration DB;
  - aucun changement de route, CTA href, formulaire demo ou logique d'affiliation;
  - patch CSS limite, sans refonte lourde.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - grep des fallbacks generiques du bloc contexte et des textes cibles sur `www/web/lp/lp.php` / CSS.
- [ ] Verification recette serveur:
  - LP sans surcouche BO active: bloc contexte masque;
  - LP avec surcouche active et contenus: bloc contexte affiche et lisible;
  - LP avec/sans logo partenaire;
  - actif avec dates, inactif, jeux reseau et fallback 3 jeux;
  - desktop/mobile.

## PATCH 2026-05-11 - Passe editoriale LP reseau / operation
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
- [x] Correctif livre:
  - hero actif recentre sur l'invitation a animer l'etablissement, CTA `Lancer une premiere animation`;
  - hero inactif recentre sur l'espace d'animation partenaire, CTA `Participer avec mon etablissement`;
  - badges fallback ajustes en `Animations incluses` et `Invitation partenaire`, sans changer les badges dates;
  - fallback du bloc contexte reformule autour du dispositif plutot que de Cotton comme sujet principal;
  - section demos reformulee autour des animations proposees/pretes a lancer, CTA `Voir une animation exemple`;
  - modale mobile passee au tutoiement et HTML du mode d'emploi corrige pour eviter un paragraphe imbrique;
  - CTA final remplace par `Pret a participer ?` avec phrase courte dediee sur les LP reseau/operation.
- [x] Contraintes respectees:
  - aucun nouveau champ BO;
  - aucune migration DB;
  - aucun changement de route, de formulaire demo, de lien CTA ou de logique d'affiliation;
  - pas de refonte CSS necessaire.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - recherche des anciens wordings publics cibles dans `www/web/lp/lp.php` et `www/web/lp/includes/css/lp_custom.css`.
- [ ] Verification recette serveur:
  - tester une LP active avec date fin, active sans date fiable, inactive, avec/sans surcouche BO, avec jeux reseau et fallback 3 jeux;
  - verifier desktop/mobile, notamment H1, badge, CTA, section demos et CTA final.

## PATCH 2026-05-11 - LP reseau / abonnement reseau
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
- [x] Correctif livre:
  - retrait du verrou `clients.online` dans la resolution LP reseau; la V1 publie toute TdR existante avec slug canonique valide;
  - CTA LP reconstruit depuis le slug canonique TdR resolu vers `/utm/reseau/{slug}`;
  - textes par defaut LP reseau realignes marketing Cotton: `Invitation Cotton` / `Rejoindre Cotton ->` sans abonnement actif ni promesse gratuite/offerte, et `Jeux Cotton offerts` / `Profiter de mes jeux ->` uniquement quand un abonnement reseau actif existe;
  - hero non personnalisable par les champs BO: les champs abonnement reseau actifs alimentent seulement le bloc contexte sous le bandeau 3 arguments;
  - structure publique forcee: hero, bandeau 3 arguments, bloc contexte, puis jeux reseau ou fallback 3 jeux historiques;
  - badge hero branche sur la couleur secondaire reseau avec contraste texte automatique si design reseau disponible;
  - suppression du bloc explicatif technique public `Le parcours suivant conserve...`;
  - fallback couleurs/visuel aligne sur les LP historiques quand aucun design reseau n'existe;
  - titre BO du bloc LP corrige en `Contexte affiche sur la LP reseau`, champs CTA personnalises retires de l'edition/lecture, slug public conserve comme non exploite V1.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`;
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`;
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`;
  - `rg -n "LE RÉSEAU|L’OPÉRATION|Le parcours suivant|Rejoignez Cotton avec votre réseau|abonnement inclus|Libellé CTA|RÃ|Ã©|Ã¨|Ãª" www/web/lp www/web/bo/www/modules/ecommerce/offres_clients` OK;
  - `git diff --check` sur `www` et `documentation`.
- [ ] Verification recette serveur:
  - inspecter le href CTA sur `/lp/reseau/{slug_tdr}` et `/lp/operation/{slug}`;
  - cliquer le CTA et confirmer le parcours PRO signup/signin sans retour home pour slug TdR valide.

## PATCH 2026-05-06 — FO parcours demos catalogue
- [x] Audit cible:
  - `www/web/fo/modules/widget/fr/fo_widget_cotton_jeux_blocs.php`
  - `www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_catalogue_view.php`
  - `www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_catalogue_view.php`
  - `www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_catalogue_view.php`
  - `www/web/fo/modules/jeux/portail/fr/fo_portail_jeux_demo_signup.php`
- [x] Correctif livre:
  - sur `/fr/jeux`, les CTA principaux des trois cartes sont libelles `Démos du jeu` et pointent vers les catalogues existants;
  - un lien secondaire discret `Découvrir le jeu` conserve l'acces aux pages de presentation;
  - correctif addendum: le partial `fo_demo_choice.php` a ete retire au profit du partial prod recharge `fo_portail_jeux_demo_signup.php`;
  - `Démo complète` reste prioritaire avec le badge `Recommandé`;
  - Cotton Quiz reutilise le partial commun, sans ajouter de CTA `Je commande` actif la ou Blind Test et Bingo Musical n'en affichent pas;
  - seul le wording de presentation de la demo rapide est ajuste en desktop/mobile;
  - la modale mobile redondante du partial commun est retiree: le CTA mobile de demo rapide lance directement la demo.
- [x] Ajustements UX cibles:
  - le lien secondaire `Découvrir le jeu` des cartes `/fr/jeux` est replace a cote du CTA `Démos du jeu`, avec hover souligne et colore par jeu;
  - la mention `NEW ! Testez la nouvelle version du Cotton Quiz !` est retiree de la fiche detail Cotton Quiz alignee sur le widget demo;
  - le micro-texte mobile de demo rapide devient `Pour plus de confort, teste aussi depuis un ordinateur.` avec interligne compact.
- [x] Verification:
  - `php -l web/fo/modules/jeux/portail/fr/fo_portail_jeux_demo_signup.php`
  - `php -l web/fo/modules/jeux/blind_test/fr/fo_blind_test_catalogue_view.php`
  - `php -l web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_catalogue_view.php`
  - `php -l web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_catalogue_view.php`
  - `php -l web/fo/modules/widget/fr/fo_widget_cotton_jeux_blocs.php`

## PATCH 2026-04-17 — FO pages statiques 2026: icones Bootstrap restaurees
- [x] Audit cible:
  - `www/web/fo/fo.php`
  - references relues:
    - `www/web/fo/modules/communication/statique/fr/fo_statique_cible_bars.php`
    - `www/web/fo/modules/communication/statique/fr/fo_statique_features_presentation_generale.php`
    - journal AI Studio `www/web/fo/*` + reload prod des templates/assets statiques 2026
- [x] Cause confirmee:
  - les nouvelles pages statiques `solutions/*` et `decouvrir*` utilisent des classes `Bootstrap Icons` (`bi ...`);
  - leurs assets etaient bien presents, mais le layout global FO ne chargeait plus la feuille `bootstrap-icons.css`;
  - dans ce repo, la dependance ne restait chargee que localement par `fo_widget_cotton_arguments.php`, ce qui ne couvrait pas les nouveaux templates statiques.
- [x] Correctif livre:
  - ajout du chargement global `bootstrap-icons.css` dans `www/web/fo/fo.php`;
  - les icones `bi` des nouvelles pages statiques repartent donc sans patch page par page.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/fo/fo.php`

## PATCH 2026-04-17 — FO sessions / fiche `place`: ex aequo affiches dans un ordre stable
- [x] Audit cible:
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - dependance relue:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - les podiums FO re-triaient encore certaines lignes ex aequo par `rang` seul;
  - cet ordre n'etait pas stable et pouvait diverger du tableau de classement complet ou du socle partage.
- [x] Correctif livre:
  - la fiche session FO et les podiums de la fiche `place` utilisent maintenant un tri stable `rang puis position source`;
  - elles preservent donc le meme ordre entre ex aequo que celui fourni par le backend partage.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## PATCH 2026-04-16 — FO fiche `place`: badges couleurs sur les titres de jeux des classements
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - référence relue:
    - `pro/web/ec/modules/compte/joueurs/ec_joueurs_shared.php`
- [x] Cause confirmée:
  - l'onglet `Classements` de la fiche `place` gardait des titres de jeux en texte simple;
  - l'interface n'etait plus cohérente avec les badges de jeu déjà utilisés dans `pro` et `play`.
- [x] Correctif livré:
  - ajout de helpers locaux `badge class/style` côté `www`;
  - chaque bloc leaderboard affiche maintenant son jeu dans un badge colore, avec periode conservee a cote.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## PATCH 2026-04-16 — FO fiche `place`: CTA agenda d'accès direct restauré sur entrée QR
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - référence relue:
    - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
- [x] Cause confirmée:
  - la logique historique du CTA `Je participe` dépendait de la présence de `code_client`;
  - la nouvelle fiche `place` hydrate l'agenda via un endpoint AJAX qui ne transmettait plus ce contexte, donc le renderer agenda ne pouvait plus savoir qu'il devait afficher l'accès direct joueur.
- [x] Correctif livré:
  - l'URL AJAX de la fiche `place` retransmet maintenant `code_client` quand l'entrée vient d'un QR code lieu;
  - l'endpoint AJAX expose ce contexte au renderer agenda;
  - les cartes de sessions à venir réaffichent `J'accède au jeu` uniquement dans ce cas;
  - dans ce même contexte QR, le CTA public secondaire vers la fiche détail de session n'est plus rendu.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`

## PATCH 2026-04-15 — FO fiche `place`: spinner aussi sur l'onglet `Agenda`
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
- [x] Cause confirmee:
  - la fiche `place` affichait deja un spinner sur `Classements` et `Sessions passées`, mais `Agenda` restait sur un simple texte de chargement;
  - le besoin retenu est d'harmoniser les trois onglets dynamiques avec le meme retour visuel.
- [x] Correctif livre:
  - l'onglet `Agenda` reutilise maintenant le meme loader spinner que `Classements` et `Sessions passées`;
  - le spinner est present dans le placeholder initial et lors du chargement AJAX de l'onglet.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PATCH 2026-04-15 — FO fiche `place`: entrée QR code force `Agenda`
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_seo.php`
  - `www/web/fo/fo.php`
- [x] Cause confirmee:
  - la refonte récente des onglets `place` a laissé `Classements` comme onglet actif par défaut;
  - lors d'une entrée via `QR code` (`/place/{code_client}`), ce choix n'est pas cohérent avec l'intention produit, qui est d'amener d'abord l'utilisateur vers les prochaines sessions.
- [x] Correctif livre:
  - la vue `place` détecte désormais l'entrée QR via `code_client`;
  - sans onglet explicitement demandé en querystring, elle force alors l'onglet actif initial sur `agenda`;
  - la vue publique SEO `/fr/place/{seo_slug}` garde son défaut actuel sur `classements`.
  - addendum perf:
    - l'entrée `QR code` positionne aussi un garde pour désactiver le preload image global FO;
    - cela supprime le warning navigateur sur `branding-client-default.jpg`, image non utilisée quand la galerie hero est masquée sur la vue QR.
  - addendum JS:
    - le boot de la page ne dépend plus de la présence des boutons d'onglets pour charger `Agenda`;
    - sur entrée QR, il relit maintenant directement l'onglet actif initial calculé côté PHP, ce qui évite un spinner d'agenda bloqué quand la nav d'onglets est volontairement masquée.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_seo.php`
  - `php -l /home/romain/Cotton/www/web/fo/fo.php`

## PATCH 2026-04-15 — FO fiche `place`: spinner aussi sur le chargement des sessions passées
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
- [x] Cause confirmee:
  - l'onglet `Classements` affichait deja un petit spinner pendant le chargement AJAX;
  - l'onglet `Sessions passées` utilisait seulement un texte de chargement, sans retour visuel coherent avec le reste de la fiche `place`.
- [x] Correctif livre:
  - le loader AJAX de `Sessions passées` reutilise maintenant le meme pattern `spinner-border spinner-border-sm color-4` que `Classements`;
  - le message reste `Chargement des sessions passées en cours...`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PATCH 2026-04-15 — FO fiche detail session: etat `terminee` aligne sur `pro`
- [x] Audit cible:
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - dependances relues:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Cause confirmee:
  - la fiche detail FO decidait encore son etat uniquement via `app_session_get_chronology($date)`;
  - une session cloturee le jour meme pouvait donc rester rendue comme session en cours/carte descriptive, alors que `pro` l'affichait deja comme archivee avec resultats.
- [x] Correctif livre:
  - la fiche detail FO s'aligne maintenant sur `app_session_display_chronology_get(..., app_session_edit_state_get(...))`;
  - podium et classement deviennent visibles des la cloture metier de la session, avec le meme contrat d'etat que `pro`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`

## PATCH 2026-04-14 — FO fiche `place`: `Top 10` public uniquement
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- [x] Cause confirmée:
  - l'onglet public `Classements` rendait directement tous les rangs calculés pour chaque jeu;
  - le besoin produit retenu pour `www/place` n'est finalement pas un toggle public vers le complet, mais une lecture simple strictement bornée au `Top 10`.
- [x] Correctif livré:
  - la fiche `place` affiche maintenant seulement le `Top 10` par jeu;
  - le sous-titre public est fixé à `Top 10`;
  - aucun CTA `Afficher le classement complet` / `Replier le classement` n'est conservé côté FO;
  - l'ordre d'affichage public des blocs est maintenant `Blind Test`, puis `Bingo Musical`, puis `Cotton Quiz`;
  - le sélecteur de saison continue de recharger ces `Top 10` en AJAX;
  - si les 3 onglets `Classements`, `Agenda` et `Sessions passées` sont tous vides, la section complète est masquée côté FO.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PATCH 2026-04-14 — FO liste `place`: départements réellement présents + tri par activité
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_list.php`
- [x] Cause confirmée:
  - le filtre département listait tout le référentiel, y compris des zones sans organisateur public;
  - les cartes organisateurs étaient encore triées par `id`, sans faire ressortir les lieux les plus actifs.
- [x] Correctif livré:
  - le sélecteur `Département` ne garde plus que les départements réellement présents dans la liste publique;
  - l'option `Tous` renvoie maintenant vers `/fr/place` et non vers `/fr/agenda`;
  - la liste organisateurs est maintenant triée par activité agrégée côté SQL:
    - `sessions_total` décroissant
    - `latest_session_date` décroissante
    - `nom` croissant
  - ce tri repose sur une seule agrégation SQL globale jointe à la liste publique, sans calcul lourd par carte.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_list.php`

## PATCH 2026-04-14 — BO réseau: suppression d'affiliation TdR depuis le pilotage affiliés
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - dépendance relue:
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause confirmée:
  - le BO réseau permettait déjà d'activer, désactiver et reclasser un affilié, mais pas de casser proprement son rattachement à la TdR quand le compte sort du réseau;
  - sans cette action BO, un compte restait avec `clients.id_client_reseau > 0`, donc continuait d'être exclu du scope `Remises 2026`.
- [x] Correctif livré:
  - le tableau `Affiliés du siège` expose maintenant un CTA `Supprimer l'affiliation` dans la colonne `Action`;
  - l'action est livrée uniquement côté BO `reseau_contrats`, sans exposition côté PRO;
  - le write path appelle le helper métier `client_affilier(0, ...)` pour remettre `id_client_reseau` à `0`;
  - la sortie du réseau déclenche aussi la reclassification des délégations du siège concerné via le helper existant, pour rester cohérent avec les autres chemins BO de changement d'affiliation.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`

## PATCH 2026-04-14 — FO fiche `place`: suppression du calcul historique complet au premier hit
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Extension livrée:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
- [x] Cause confirmée:
  - la fiche publique `place` appelait le même helper que `Mes joueurs` (`app_client_joueurs_dashboard_get_context(...)`);
  - sans cache de session déjà chaud, ce helper recalculait tout l'historique organisateur (`sessions_scope = all`) alors que la page n'affiche que les leaderboards de la saison courante.
- [x] Correctif livré:
  - ajout d'un helper dédié `app_client_joueurs_dashboard_get_context_fo_place(...)`;
  - ce helper charge directement le contexte filtré saison courante pour les leaderboards publics;
  - la synthèse historique haute n'est plus recalculée sur la fiche publique: elle n'est réinjectée que si le cache journalier de session existe déjà;
  - `fo_clients_view.php` est branché sur ce nouveau helper léger;
  - la page publique rend désormais un shell rapide puis hydrate en AJAX:
    - la synthèse haute;
    - le bloc `Classements`;
  - le bloc `Classements` réintroduit un sélecteur de saison directement dans son titre;
  - ce sélecteur recharge uniquement les leaderboards demandés, avec saisons exploitables récentes triées du plus récent au plus ancien.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PATCH 2026-04-14 — FO fiche `place`: onglet `Classements` multi-jeux sur saison courante
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - dépendances relues:
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- [x] Cause confirmée:
  - la fiche `place` utilisait déjà le moteur global `Mes joueurs`, mais son onglet public continuait d'afficher un ancien `Classement Quiz` local, multi-saisons et non aligné sur les nouvelles règles de saison courante;
  - `pro/play` exposaient déjà la vérité métier attendue: un classement distinct par jeu seulement si des sessions réellement exploitables existent sur la période.
- [x] Correctif livré:
  - l'onglet public devient `Classements`;
  - `fo_clients_view.php` affiche maintenant un bloc par jeu disponible sur la saison courante (`Cotton Quiz`, `Blind Test`, `Bingo Musical`);
  - le tableau conserve le style historique du classement quiz pour chaque jeu, avec colonnes `rang / entité / points / participations`;
  - le libellé de période affiché dans chaque bloc est simplifié au format `Jeu · Avril-Juin 2026`;
  - la colonne droite réutilise le moteur global de résultats de session pour afficher les dernières sessions classées, avec photo gagnant quand elle existe;
  - chaque bloc session de droite renvoie maintenant vers la fiche détail publique de la session;
  - le nombre de cartes affichées à droite n'est plus borné par un plafond fixe; il est maintenant calculé selon la hauteur théorique du classement pour mieux utiliser l'espace disponible;
  - un jeu sans sessions classables sur la saison courante n'est plus affiché.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PATCH 2026-04-14 — BO `Remises 2026`: ajout en masse figé depuis la fiche détail
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- [x] Cause confirmée:
  - la fiche détail d'une remise manuelle permettait seulement l'ajout unitaire de comptes;
  - le besoin métier est de figer rapidement un lot de comptes actuels selon les mêmes critères que le mode auto, sans rendre la remise dynamique pour les futurs comptes.
- [x] Correctif livré:
  - la fiche détail d'une remise manuelle expose maintenant un bloc `Ajouter en masse (sélection figée)`;
  - ce bloc réutilise les mêmes axes métier que le mode auto:
    - `Typologie`
    - `Pipeline`;
  - ces filtres ne sont pas persistés sur la remise et ne changent donc pas son mode de ciblage;
  - l'action insère seulement les comptes présents au moment du clic dans `ecommerce_remises_to_clients`;
  - les comptes déjà liés sont exclus du lot;
  - après un ajout en masse, le BO garde la possibilité de retirer des comptes unitairement depuis la liste des cibles manuelles.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
  - la fiche détail affiche aussi maintenant l'email du contact administrateur principal du compte sous le nom, en petit, dans les listes auto et manuelles.
  - le CTA `Retirer` utilise maintenant un vrai bouton rouge plein, autant sur la fiche détail de la remise que depuis la fiche client; le CTA d'ajout manuel de la fiche client devient `Appliquer` en `btn-info`.
  - le ciblage manuel peut maintenant être préparé avant activation: l'ajout unitaire ou en masse de comptes n'est plus bloqué par l'état `Inactive` ni par une fenêtre de commande pas encore ouverte.
  - la fiche détail d'une remise manuelle permet maintenant aussi de purger toute la liste via un CTA `Vider tout` placé dans l'entête de droite du tableau des comptes.
  - la liste des comptes concernés expose désormais une vraie colonne `Email` dédiée;
  - tous les emails liés à chaque compte sont affichés, y compris les emails des contacts associés au compte;
  - quand un compte porte plusieurs emails, la fiche détail génère plusieurs lignes secondaires `compte + email`, en ne gardant le CTA `Retirer` que sur la première ligne du compte.

## PATCH 2026-04-13 — FO agenda public: filtres `Département / pays` + `Organisateur` + `Jeu`
- [x] Audit cible:
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
  - dépendance relue:
    - `play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
- [x] Cause confirmée:
  - la page publique `/fr/agenda` restait sur un filtre unique `Département`, avec une navigation legacy par slug;
  - l'agenda joueur `play` portait déjà la logique produit attendue:
    - `Département / pays`
    - `Organisateur`
    - `Jeu`
    - valeurs par défaut sur `Tous`
    - options limitées aux zones et organisateurs réellement présents.
- [x] Correctif livré:
  - `fo_sessions_list.php` reprend maintenant une lecture agenda alignée sur `play`, avec formulaire GET et 3 filtres sur la même ligne;
  - les routes SEO historiques `agenda/jeu/...`, `agenda/departement/...`, `agenda/ville/...` restent compatibles et hydratent les nouveaux filtres quand elles sont utilisées;
  - le filtre géographique mélange départements FR et pays étrangers réellement représentés dans les sessions;
  - le filtre `Jeu` regroupe les variantes techniques sous les 3 familles visibles `Cotton Quiz`, `Blind Test`, `Bingo Musical`;
  - en `dev`, la lecture agenda n'ajoute plus `c.online=1`, pour que `Tous` reste cohérent en recette.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`

## PATCH 2026-04-13 — FO fiche détail `Cotton Quiz`: séries programmées visibles
- [x] Audit cible:
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - dépendance relue:
    - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmée:
  - la fiche détail publique `www` n'exposait pas le détail des séries programmées sur `Cotton Quiz`;
  - `play` utilisait déjà cette information, et les helpers `global` la fournissaient déjà via `quiz_series_label` / `quiz_series_names`.
- [x] Correctif livré:
  - `fo_sessions_view.php` relit maintenant les séries `Cotton Quiz` depuis la session, avec fallback sur le détail jeu;
  - le bloc gauche `col-12 col-lg-5` affiche désormais une ligne `Séries programmées` entre `Date` et `Lieu`;
  - le rendu reste aligné sur les autres méta-informations de la fiche, avec une icône dédiée et une liste simple des séries;
  - les textes `Concept` / `Comment participer` sont mis à jour sur les fiches `Cotton Quiz`, `Blind Test` et `Bingo Musical`;
  - le bloc `Comment participer à un Bingo Musical ?` est réactivé avec le nouveau wording;
  - le CTA principal `Je participe` de la fiche détail réutilise maintenant la même URL EP sessionnelle que les liens présents dans les blocs `Comment participer`;
  - sur une session terminée des 3 jeux, la colonne centrale affiche maintenant `Podium` puis `Classement complet` à la place du visuel standard;
  - le bloc gauche d'informations générales est masqué sur ces sessions terminées, afin de ne conserver que les résultats;
  - ces résultats s'appuient sur `app_session_results_get_context(...)`, comme la fiche archive `pro`, avec fallback visuel propre quand aucune photo gagnant n'est disponible;
  - le titre de la liste basse réutilise maintenant le nombre réel de participants (`players_count`) remonté par ce moteur;
  - pour `Bingo Musical`, la liste basse masque aussi rang et points, afin de rester alignée sur le rendu `pro`;
  - les accroches marketing et blocs `Concept / Comment participer` sont masqués dans ce contexte terminé.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`

## PATCH 2026-04-13 — FO fiche `place`: synthèse alignée sur le moteur global `Mes joueurs`
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - dépendance relue:
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
    - `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- [x] Cause confirmée:
  - la fiche établissement `www` lisait encore des stats legacy `app_statistiques_client_*`;
  - ces compteurs appliquaient des seuils d'affichage fixes et ne reflétaient pas la même vérité métier que la synthèse `Mes joueurs` côté `pro/ec`.
- [x] Correctif livré:
  - `fo_clients_view.php` s'appuie maintenant sur `app_client_joueurs_dashboard_get_context(...)`;
  - la ligne `Membre depuis ...` reprend la date consolidée du moteur global;
  - la ligne sessions affiche le total canonique `... sessions de jeux Cotton`;
  - la synthèse publique regroupe maintenant joueurs et équipes dans une seule ligne `... participants`;
  - convention marketing retenue: `1 équipe Cotton Quiz = 3 participants`;
  - la ligne `participants` disparait si le total est nul;
  - les anciens seuils `>10` / `>50` sont supprimés;
  - l'onglet `Sessions passées` de la fiche `place` réactive un CTA vers la fiche détail des sessions archivées;
  - cette liste archive filtre maintenant les sessions avec `app_client_joueurs_dashboard_session_is_history_useful(...)`, comme dans l'agenda `pro`;
  - le CTA de ces cartes archivées devient `Voir les résultats`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`

## PATCH 2026-04-08 — BO factures PDF: remise ABN explicitée hors libellé produit
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - `global/web/assets/branding/pdf/cotton-facture-logo.jpg`
- [x] Cause confirmée:
  - la facture PDF affichait encore la remise dans la description produit snapshotée, ce qui masquait la lecture du prix de référence HT;
  - le bloc des totaux recalculait encore visuellement la TVA depuis le `HT` arrondi, ce qui pouvait laisser un total incohérent face au `TTC` canonique déjà facturé.
- [x] Correctif livré:
  - la ligne produit PDF retire maintenant le libellé de remise du descriptif et réaffiche le `PU HT` de référence ainsi que le `PRIX TOTAL HT` avant remise;
  - le bloc des totaux expose désormais:
    - `TOTAL HT`
    - `REMISE xx% HT`
    - `TOTAL REMISÉ HT`
    - `TVA (20%)`
    - `TOTAL TTC`;
  - les montants du PDF sont maintenant relus depuis les snapshots structurés `prix_reference_ht`, `remise_ht`, `total_ht`, `total_ttc`;
  - la TVA visible est dérivée du `TTC` canonique moins le `HT` net snapshoté, pour rester strictement cohérente avec le montant final facturé.
  - le logo facture est maintenant relu depuis un asset partage `global`, plus depuis `pro`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`
  - cas de contrôle métier:
    - `99,90 € HT -25 %` => `24,97 €` de remise HT, `74,93 € HT` net, `14,98 € TVA`, `89,91 € TTC`

## PATCH 2026-04-08 — BO `Remises 2026`: le lien copiable reutilise la route publique historique
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- [x] Correctif livre:
  - le faux lien BO affichait bien l'URL, mais gardait `href="#"`, donc un clic ne quittait pas la fiche detail;
  - il reutilise la route historique stable `https://pro.../utm/cotton/<token_public>`, deja portee vers le signup/signin par `ec_sign.php`;
  - pour `Remises 2026`, le token emis est maintenant l'`id_securite` de la remise, avec fallback sur `code`.
  - si une ancienne remise `2026` n'avait pas encore d'`id_securite`, la fiche detail le backfill maintenant automatiquement au premier affichage du lien.
  - la fiche detail affiche maintenant d'abord le CTA `Copier le lien`, puis l'URL en petit et non cliquable sous le bouton.
  - une remise hors fenetre de commande n'expose plus ce lien et n'est plus proposable en ajout manuel depuis la fiche client.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`

## PATCH 2026-04-08 — BO `Remises 2026`: lien d'inscription copiable depuis la fiche detail
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- [x] Correctif livre:
  - la fiche detail expose maintenant un `Lien d'inscription` copiable pour les remises actives en ciblage manuel;
  - le lien pointe vers la route publique historique `/utm/cotton/...`, charge ensuite la remise en session puis bascule vers le signup/signin PRO;
  - les remises automatiques ou inactives n'exposent pas ce lien.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`

## PATCH 2026-04-08 — BO clients: section `Remises` recentree sur `Remises 2026`
- [x] Audit cible:
  - `www/web/bo/bo.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `www/web/bo/www/modules/entites/clients/bo_module_aside.php`
- [x] Correctif livre:
  - la navigation `Commercial` ne propose plus les entrées legacy `Remises > catalogue Cotton` et `Remises > accordées aux clients`;
  - la fiche client BO réutilise maintenant la section `Remises` pour afficher les `Remises 2026` actives applicables au compte;
  - la meme section permet aussi d'ajouter une `Remise 2026` manuelle au compte quand la regle est en ciblage manuel;
  - une regle manuelle sans aucun compte lie ne remonte plus a tort comme deja applicable sur la fiche client;
  - le retrait depuis la fiche client ne s'applique qu'aux rattachements manuels explicites, sans casser les règles automatiques.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/bo.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_module_aside.php`

## PATCH 2026-04-08 — BO `Remises 2026`: simplification de la fiche detail
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- [x] Correctif livre:
  - la fiche detail ne cumule plus `Durée de remise` et `Résumé métier`;
  - seul le resume metier est conserve, renomme en `Durée de la remise`;
  - le bloc `Période` est deplace sous `Etat`;
  - ce bloc est renomme en `Remise sur commande` avec un rendu lisible `du ... au ...` sur la fiche detail.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`

## PATCH 2026-04-08 — SQL BO `remises`: migration explicite des colonnes Remises 2026 / schedule Stripe
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/remises/bdd_ecommerce_remises.sql`
- [x] Correctif livre:
  - ajout d'un bloc de migration SQL explicite pour converger la prod avec le lazy-init runtime;
  - ajout de `ecommerce_remises.duree_remise_mois` en `SMALLINT(5) UNSIGNED NULL DEFAULT 12`, puis backfill `12` des lignes `NULL`;
  - ajout de `ecommerce_offres_to_clients.stripe_subscription_schedule_id` en `VARCHAR(255) NOT NULL DEFAULT ''`, puis backfill des `NULL` en chaine vide;
  - aucun index additionnel n'a ete ajoute dans cette passe, pour rester strictement aligne sur le runtime livre.

## PATCH 2026-04-08 — BO `Remises 2026`: duree d'application metier
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- [x] Correctif livre:
  - le BO garde sa structure metier actuelle et ajoute seulement `duree_remise_mois`;
  - la valeur par defaut est `12 mois`;
  - le form autorise une duree numerique bornee et le cas `Sans limite`;
  - la liste et la fiche detail affichent maintenant une lecture metier explicite:
    - `25 % pendant 12 mois`
    - `25 % pendant 3 mois`
    - `25 % sans limite`;
  - le BO n'expose toujours aucun choix technique `coupon` / `schedule`;
  - la regle annuelle exceptionnelle est documentee dans l'aide du formulaire:
    - en annuel, une duree `< 12 mois` signifie seulement `premiere facture annuelle`.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`

## PATCH 2026-04-07 — BO `Remises 2026`: nouveau chemin dedie sous `Commercial`
- [x] Audit cible:
  - `www/web/bo/bo.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
- [x] Correctif livre:
  - un nouveau chemin BO `Commercial > Remises 2026` remplace le besoin de tordre les formulaires legacy `remises` / `remises_offres`;
  - le formulaire dedie inferre maintenant `mode=modifier` quand une fiche existante est ouverte avec `id>0` mais sans parametre `mode`, ce qui evite de dupliquer la remise au lieu de mettre a jour l'originale;
  - la liste BO propose maintenant aussi une suppression directe, qui purge les liaisons `ecommerce_remises_to_offres` (ABN 12) et `ecommerce_remises_to_clients` avant de supprimer la regle;
  - la colonne `Ciblage` de la liste affiche maintenant le detail reel `Pipeline: ...` et/ou `Typologie: ...` au lieu d'un libelle generique;
  - la vue detail affiche maintenant un recap `Comptes concernes : x`, calcule sur le volume reel de comptes cibles en mode automatique ou manuel;
  - la vue detail rappelle maintenant aussi la duree Stripe fixe de la remise V1: `12 mois`;
  - le form dedie porte exactement les champs V1 utiles:
    - `Nom (interne)`
    - `Descriptif (interne)`
    - `Nom (espace pro)`
    - `Client > typologie`
    - `Client > pipeline`
    - `Remise en %`
    - `Date debut commande`
    - `Date fin commande`
    - `Active / Inactive`
  - le write path dedie cree / met a jour la regle dans `ecommerce_remises` et la liaison ABN `12` dans `ecommerce_remises_to_offres`;
  - si `typologie` et/ou `pipeline` sont renseignes, le module passe en ciblage automatique et purge les ciblages explicites pour eviter les modes mixtes;
  - si les deux sont vides, la fiche passe en ciblage manuel et permet d'ajouter / retirer des comptes organisateurs via `ecommerce_remises_to_clients`;
  - la vue fermee affiche la liste des comptes propres concernes et exclut les TdR (`flag_client_reseau_siege=0`) ainsi que les comptes reseau relies (`id_client_reseau=0`);
  - les modules legacy `remises` / `remises_offres` ne sont plus cibles par la V1 et restent laisses dans leur etat legacy.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
  - `php -l /home/romain/Cotton/www/web/bo/bo.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`

## PATCH 2026-04-03 — BO `facturation_pivot`: KPI `Clients actifs` aligné sur le mois de référence en `civil/fiscal`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
- [x] Cause confirmée:
  - en `année civile` et `année fiscale`, le KPI haut `Clients actifs` prenait le dernier mois théorique de la plage (`decembre` ou `aout`);
  - ce comportement divergeait de l'intuition produit, qui attend le mois de référence sélectionné.
- [x] Correctif livré:
  - ajout d'une clé dédiée `clients_kpi_month_key`;
  - en `civil` et `fiscal`, le KPI `Clients actifs` lit désormais le mois `ref_month`;
  - en `month` et `last3`, le comportement reste inchangé.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK

## PATCH 2026-04-03 — BO `facturation_pivot`: taux SaaS réalignés sur les démos agrégées
- [x] Audit ciblé:
  - `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
- [x] Cause confirmée:
  - le reporting SaaS charge séparément `Demos visiteurs` et `Démos nvx inscrits`;
  - plusieurs taux “réalisés” utilisaient encore uniquement `Demos visiteurs`, alors que le bloc `Objectifs` agrège déjà les deux sources.
- [x] Correctif livré:
  - ajout d'un agrégat mensuel `demo_sessions_total_by_month`;
  - les ratios réels `Tx visiteurs -> demos`, `Tx demos -> inscrits` et `Tx demos -> clients` de la modale de conversion utilisent désormais la somme `demo_sessions + demo_sessions_new_users`;
  - les deux colonnes de détail du tableau restent séparées pour conserver la lecture métier d'origine.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK

## PATCH 2026-03-24 — BO clients: copie du lien EC temporaire au lieu de l'ouverture
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- [x] Cause confirmée:
  - apres generation, l'URL du lien EC temporaire etait affichee comme une ancre cliquable;
  - l'usage BO attendu est plutot de partager l'URL, pas de la suivre depuis la fiche client.
- [x] Correctif livré:
  - l'URL est maintenant associee a une action de copie presse-papiers;
  - un bouton `Copier le lien` et un feedback `Lien copié.` sont ajoutes;
  - un fallback `execCommand('copy')` couvre les navigateurs BO sans `navigator.clipboard`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK

## PATCH 2026-03-20 — BO `facturation_pivot`: allègement du reporting SaaS sans perte des KPI sessions
- [x] Audit ciblé:
  - `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
- [x] Cause confirmée:
  - la page `?t=syntheses&m=facturation_pivot&p=saas` recalculait les sessions jeux via un premier scan lourd sur `championnats_sessions`;
  - un second scan quasi identique recalculait ensuite les seules sessions numériques pour les ratios joueurs/session et joueurs/client;
  - ce double passage SQL a été introduit dans le correctif `fix calcul sessions reporting`.
- [x] Correctif livré:
  - l’agrégation principale des sessions remonte maintenant aussi `sessions_numeric` dans la même requête SQL;
  - le second balayage `sql_sessions_numeric` est supprimé;
  - les métriques métiers conservées:
    - sessions finies par mois / client / jeu
    - ventilation par type de jeu
    - comptage séparé des sessions numériques pour les ratios.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK

## PATCH 2026-03-13 — BO réseau: remplacements délégués différés persistés en base dédiée
- [x] Audit ciblé:
  - `www/web/bo/cron_routine_bdd_maj.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le cron BO des remplacements différés relisait encore directement les marqueurs `[reseau_replace:*]` et `[reseau_replace_timing:*]` dans `ecommerce_offres_to_clients.commentaire`;
  - la base importée via phpMyAdmin ne portait pas encore de table métier dédiée pour cet ordonnancement.
- [x] Correctif livré:
  - ajout de la table `ecommerce_reseau_delegated_replacements` dans `bdd_ecommerce_reseau_contrats.sql`;
  - ajout d’un backfill best-effort depuis les anciens marqueurs pour rapatrier les remplacements déjà planifiés lors de l’import SQL;
  - le cron BO s’appuie désormais d’abord sur cette table dédiée, puis conserve un fallback legacy sur les anciens marqueurs tant que des lignes historiques peuvent subsister.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/cron_routine_bdd_maj.php` OK

## PATCH 2026-03-13 — BO réseau: liens croisés vers la TdR et l'offre support
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Cause confirmée:
  - la fiche BO d'un `Abonnement réseau` n'affichait pas explicitement le compte TdR dans le bloc haut;
  - la synthèse `Affiliés du réseau` indiquait `Abonnement réseau actif : oui` sans lien rapide vers la fiche de l'offre support.
- [x] Correctif livré:
  - la vue haute `offres_clients` affiche maintenant une ligne `CLIENT` au-dessus de `Objet`, avec lien vers la fiche client de la TdR;
  - dans `reseau_contrats`, le libellé `Abonnement réseau actif` devient cliquable quand l'offre support est résolue;
  - aucun write path ni recalcul réseau n'est modifié.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-13 — BO `reseau_contrats`: affichage de l'`Offre incluse cible`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Cause confirmée:
  - le bloc `Affiliés du réseau` exposait déjà `Abonnement réseau actif`, `Nb affiliés limite` et `Nb de places dispo`;
  - l'offre déléguée incluse cible restait pourtant absente de cette synthèse BO, alors que l'identifiant canonique `id_offre_delegation_cible` est déjà disponible dans la couverture réseau.
- [x] Correctif livré:
  - la synthèse affiche maintenant `Offre incluse cible` sous la ligne d'état/quota quand l'abonnement réseau est actif;
  - le libellé est résolu en priorité depuis le catalogue déjà chargé par la vue, avec fallback sur `module_get_detail('ecommerce_offres', ...)`;
  - aucun recalcul métier ni write path réseau n'est ajouté.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `offres_clients`: respect du passage explicite à `Terminée` pour l'`Abonnement réseau`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - dépendances relues:
    - `global/web/lib/core/lib_core_module_functions.php`
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le flux BO de clôture passait encore par une transition runtime intermédiaire avant la fermeture effective de la ligne support;
  - surtout, une fois le runtime archivé, le resolver support réseau continuait d'autoriser un fallback automatique vers une autre offre support `id_etat IN (2,3)` du même siège;
  - ce fallback pouvait réouvrir la lecture réseau en `En attente` après une clôture BO pourtant explicite.
  - la fiche client TdR appelait aussi `app_ecommerce_reseau_facturation_get_detail(...)` en mode par défaut;
  - ce helper de lecture relançait encore `app_ecommerce_reseau_contrat_sync_legacy_delegations(...)`, puis `app_ecommerce_reseau_facturation_refresh(...)`, donc une réécriture possible du statut support au simple rechargement BO.
- [x] Correctif livré:
  - la clôture BO immédiate s'appuie désormais directement sur la fermeture explicite de l'offre support et l'archivage runtime final;
  - un garde-fou final réapplique aussi `id_etat=4` sur la ligne support après la rotation runtime pour empêcher tout retour parasite en `En attente`;
  - un contrat runtime archivé retourne désormais `cloture` comme état canonique;
  - tant que ce runtime archivé n'est pas explicitement rerattaché par une réactivation BO/Stripe, aucun fallback automatique ne peut réélire une offre support `En attente` ou `Active`;
  - le recalcul réseau canonique ne fabrique plus non plus lui-même un passage de l'offre support vers `En attente` ou `Active`; ces transitions restent réservées aux write paths explicites BO / Stripe, tandis que le refresh conserve l'état courant sauf clôture runtime;
  - la fiche client TdR lit désormais la synthèse réseau en mode `skip_legacy_sync=1`, donc sans sync legacy implicite au chargement de la vue;
  - le correctif ne rouvre ni auto-création, ni suppression brute, ni write path concurrent.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: remise synthèse alignée sur la prochaine commande TdR
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - la synthèse `Remise réseau courante` affichait le palier des offres `hors abonnement réseau` déjà actives;
  - pour le front PRO, le besoin utile est la remise qui s’appliquerait à la prochaine offre commandée par la TdR.
- [x] Correctif livré:
  - la synthèse calcule désormais la remise sur `volume actif courant + 1`;
  - l’affichage rappelle explicitement qu’il s’agit de la `prochaine commande TdR`;
  - aucune modification du calcul tarifaire réellement appliqué aux lignes déjà actives.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: historique terminé et couverture stabilisés
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le tableau du bas de page exposait un titre devenu faux après ouverture de l’historique `incluse`;
  - la qualification de couverture pouvait encore reclasser des lignes historiques via un fallback legacy trop agressif;
  - le libellé `Incluse à l'abonnement réseau` suggérait à tort l’offre support courante.
- [x] Correctif livré:
  - renommage du tableau en `Offres déléguées terminées`;
  - affichage de tout l’historique des offres déléguées terminées rattachées à la TdR;
  - priorité au rattachement explicite `reseau_id_offre_client_support_source` pour qualifier l’historique;
  - libellé ajusté en `Incluse à un abonnement réseau`.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: remise réseau réintroduite dans `Tarif`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livré:
  - la colonne `Tarif` des affiliés réaffiche la remise réseau appliquée sur les délégations `hors abonnement réseau`;
  - le rendu détaille désormais brut HT, pourcentage de remise et net appliqué;
  - aucune tarification n’est ajoutée aux offres incluses à l’abonnement réseau.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: synthèse affiliés reformulée
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livré:
  - la synthèse du bloc `Affiliés du réseau` est réécrite en structure métier plus lisible;
  - affichage distinct de:
    - `Abonnement réseau actif`
    - `Tarif négocié` si actif
    - `Affiliés actifs`
    - `Offres propres`
    - `Offres déléguées`
    - `Offres incluses abn` si actif
    - `Affiliés inactifs`
    - `Remise réseau courante`
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: filtre rapide par type de couverture
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livré:
  - le tableau `Affiliés du réseau` est maintenant regroupé par type de couverture;
  - des filtres rapides permettent de n’afficher que:
    - `Tous`
    - `Incluses abn`
    - `Déléguées`
    - `Offres propres`
    - `Inactifs`
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-11 — Réseau: rattachement explicite des offres incluses à l'abonnement source
- [x] Audit ciblé:
  - `documentation/canon/data/schema/DDL.sql`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - aucune offre déléguée incluse ne portait l'id de l'offre support `Abonnement réseau` source;
  - l'historique devait donc être reconstruit par heuristique.
- [x] Correctif livré:
  - ajout du champ facultatif `reseau_id_offre_client_support_source` au schéma canonique `ecommerce_offres_to_clients`;
  - alimentation de ce champ sur les write-paths `cadre`;
  - remise à `0` sur les flux `hors abonnement réseau`.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-11 — BO `offres_clients`: `Offres incluses` figées par offre support
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_aside.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - la fiche `Abonnement réseau` lisait encore le contrat/support réseau courant du client pour le bloc `Offres incluses`;
  - la jointure sur `ecommerce_reseau_contrats_affilies.id_offre_client_deleguee` relisait un pointeur courant par affilié, pas un historique par offre support;
  - une offre support terminée pouvait donc ne pas afficher ses propres offres déléguées incluses.
- [x] Correctif livré:
  - ajout d’un helper global dédié pour relire les offres incluses rattachées à une offre support donnée;
  - le support actif repart désormais de la couverture canonique runtime;
  - une archive repart des offres déléguées du siège sur la période de l’offre support affichée;
  - aside, vue haute et formulaire BO utilisent désormais cette lecture figée par offre support;
  - les offres `Terminées` continuent d’exposer leurs délégations reliées dans cette section.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_aside.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php` OK

## PATCH 2026-03-11 — BO `offres_clients`: abonnement réseau terminé non réactivable par édition
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - la synchro BO `Abonnement réseau` restait exécutée même pour une offre support déjà `Terminée`;
  - ce passage pouvait rerattacher l'offre historique au runtime canonique.
- [x] Correctif livré:
  - skip de la synchro runtime tant que l'offre reste `Terminée`;
  - garde-fou de persistance sur `id_etat=4` pour une simple modification d'archive;
  - restauration explicite de `date_debut` / `date_facturation_debut` si ces champs reviennent vides dans ce flux.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-11 — BO `reseau_contrats`: séparation stable abonnement réseau / hors abonnement
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - la vue classait encore une ligne en `hors cadre` dès qu'un pricing hors cadre existait, même si `mode_facturation='cadre'`;
  - un affilié sans offre pouvait exposer à la fois l'action `Activer` via abonnement réseau et la commande hors abonnement.
- [x] Correctif livré:
  - priorité à `mode_facturation` pour empêcher le double comptage `cadre` vs `hors abonnement`;
  - synthèse métier remontée dans `Affiliés du réseau`;
  - action BO exclusive:
    - quota disponible => activation via abonnement réseau
    - sinon => attribution d'une offre déléguée hors abonnement réseau;
  - suppression des blocs redondants:
    - `Synthèse hors cadre`
    - `Commander une offre hors cadre`
    - `Offres affiliées hors cadre`
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - contrôle texte: plus de libellés/blocs BO redondants OK

## PATCH 2026-03-11 — BO `reseau_contrats`: offres terminées réseau explicites
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Cause confirmée:
  - le sous-compteur `dont offres terminées (CSO)` lisait encore le pipeline affilié au lieu des offres déléguées réellement terminées;
  - le formulaire d'attribution hors abonnement étendait trop la colonne `Actions`.
- [x] Correctif livré:
  - le sous-compteur est maintenant branché sur les offres déléguées réseau terminées;
  - ajout d'une table en bas de page listant ces offres terminées;
  - suppression du paragraphe `Activation`;
  - formulaire d'attribution hors abonnement passé en champs verticaux.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-11 — BO `reseau_contrats`: `Offre` + `Tarif` réalignés
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livré:
  - la colonne `Offre` réaffiche la jauge de l'offre active;
  - la colonne `Offre` affiche aussi la période en cours de l'offre active;
  - la colonne `Tarif` est ajoutée sur la liste `Affiliés du réseau`;
  - exception métier:
    - aucune tarification affichée pour les offres incluses à l'abonnement réseau;
  - la synthèse remonte aussi le tarif négocié du socle `Abonnement réseau` quand l'abonnement est actif.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-11 — Convergence d'activation `Abonnement réseau` entre BO et Stripe
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - dépendances relues:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - `pro/web/ec/ec_webhook_stripe_handler.php`
- [x] Correctif livré:
  - le BO réutilise maintenant le helper partagé d'activation support réseau déjà employé par le write path Stripe;
  - les deux chemins convergent vers le même ordre métier sans double logique divergente.
- [x] Effet attendu:
  - `Etat offre=active` puis `Etat contractuel=actif`
  - lecture cohérente dans `reseau_contrats` après activation BO ou paiement Stripe.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `npm run docs:sitemap` OK

## PATCH 2026-03-11 — BO `offres_clients`: override admin réel `pending_payment -> active`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `global/web/lib/core/lib_core_module_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le form BO postait déjà `id_etat=3`;
  - le rollback venait du refresh réseau générique déclenché par `module_modifier(...)` avant la synchro du contrat vers `actif`.
- [x] Correctif livré:
  - bypass du refresh prématuré étendu au cas admin `2 -> 3` sur l'offre support réseau canonique;
  - ordre retenu:
    - écriture BO de l'offre
    - sync des paramètres réseau de l'offre canonique
    - synchro contrat vers `actif`
    - refresh réseau explicite après mise à jour du contrat;
  - flow spécial `id_etat=4` conservé.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `npm run docs:sitemap` OK
- [ ] Hors périmètre:
  - aucun changement Stripe
  - aucune réintroduction de `save_contrat`, `activate_contract`, `close_contract`

## PATCH 2026-03-11 — BO réseau durable: CTA visible + pilotage affiliés
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constats confirmés:
  - le CTA méta TdR existait mais comme lien discret;
  - `save_contrat`, `activate_contract`, `close_contract` restent neutralisées dans le script BO;
  - l'activation BO réutilise déjà les write paths existants d'offre déléguée.
- [x] Correctif livré:
  - `Voir / gérer les affiliés` devient un vrai bouton visible sous `Tête de réseau`;
  - `reseau_contrats` expose la liste des affiliés avec actions d'activation, désactivation et attribution hors cadre;
  - la règle métier est conservée:
    - abonnement réseau actif + quota disponible => activation via l'offre cible du contrat
    - sinon => choix d'une offre du SI en hors cadre;
  - aucune action contrat neutralisée n'est réintroduite.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `npm run docs:sitemap` OK
- [ ] Hors périmètre:
  - aucune réactivation du pilotage BO du contrat négocié
  - aucun changement PRO requis dans ce lot

## PATCH 2026-03-11 — Régression UI du `+` TdR sur fiche client
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le gating backend continuait à reposer sur `clients.flag_client_reseau_siege = 1`;
  - le lien ciblé `offres_clients` vers `Abonnement réseau` restait valide;
  - la régression était strictement UI:
    - le `+` documenté avait été remplacé par des boutons fixes;
    - puis un correctif intermédiaire laissait le clic sur `+` partir vers le flux standard, le menu restant sur le chevron split.
- [x] Correctif livré:
  - la fiche client TdR réaffiche un `+` avec dropdown Bootstrap 5 porté par le bouton `+` lui-même;
  - le menu rapide propose `Offre propre` / `Offre réseau`;
  - `Offre réseau` ouvre toujours `offres_clients` prérempli sur `Abonnement réseau`;
  - `Affiliés / hors cadre` reste exposé séparément.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
- [ ] Hors périmètre:
  - aucun changement moteur global
  - aucune refonte de `reseau_contrats`

## PATCH 2026-03-11 — CTA standard `Ajouter` sur `offres_clients` filtré TdR
- [x] Audit ciblé:
  - `www/web/bo/master/bo_master_header.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le CTA `Ajouter` venait du core et ne proposait qu’un lien standard vers le formulaire;
  - le contexte `id_client` filtré existait déjà, mais aucun CTA ne préremplissait `id_offre=Abonnement réseau`.
- [x] Correctif livré:
  - sur la liste `offres_clients` filtrée par une TdR, `Ajouter` devient un dropdown Bootstrap 5;
  - le menu propose `Offre propre` / `Offre réseau`;
  - `Offre réseau` pointe vers `offres_clients` avec `id_client` et `id_offre=<catalogue Abonnement réseau>`.
- [x] Vérification:
  - `php -l www/web/bo/master/bo_master_header.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-11 — Résolution helper `Abonnement réseau` vs catalogue BO
- [x] Audit ciblé:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/lib/core/lib_core_module_functions.php`
  - `www/web/bo/master/bo_master_header.php`
- [x] Cause confirmée:
  - le helper `app_ecommerce_reseau_abonnement_get_catalog_id()` ne lisait que `seo_slug='abonnement-reseau'`;
  - le filtre/select BO `Offre` lisait toute la table `ecommerce_offres` par `nom`, donc l’offre restait visible même si le `seo_slug` était absent.
- [x] Correctif livré:
  - fallback helper par `nom='Abonnement réseau'`;
  - mise à niveau opportuniste du `seo_slug` canonique sur la ligne existante;
  - CTA dropdown BO conservé avec attribut Bootstrap 4 `data-toggle="dropdown"`.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l www/web/bo/master/bo_master_header.php` OK

## PATCH 2026-03-11 — Fiche client TdR `+` sur section `Offres`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le `+` était déjà un vrai bouton dropdown unique;
  - le runtime BO est Bootstrap 4 alors que le bouton portait encore `data-bs-toggle="dropdown"`.
- [x] Correctif livré:
  - passage du bouton `+` en `data-toggle="dropdown"`;
  - conservation des URLs `Offre propre` / `Offre réseau`;
  - `Offre réseau` continue d’utiliser la résolution catalogue fiabilisée `Abonnement réseau`.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK

## PATCH 2026-03-11 — Fiche client TdR: déplacement du CTA réseau dans le bloc meta
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- [x] Correctif livré:
  - hoist de l’URL `reseau_contrats` pour réutilisation dans le bloc meta;
  - ajout du CTA `Voir / gérer les affiliés` juste sous `Tête de réseau`;
  - suppression du bouton `Affiliés / hors cadre` dans la section `Offres`;
  - aucun changement sur le dropdown `Offre propre` / `Offre réseau`.
- [x] Réalignement doc livré:
  - `reseau_contrats` est désormais décrit comme vue BO transverse interne durable de pilotage réseau;
  - l’ancien wording transitoire est corrigé dans les sections de synthèse courantes.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - `npm run docs:sitemap` OK

## PATCH 2026-03-11 — Dépendance moteur global stabilisée
- [x] Dépendance relue:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Effet de dépendance intégré:
  - le moteur ne crée plus de nouveau support legacy `contrat-cadre-reseau`
  - un éventuel post legacy depuis le BO standard est remappé vers `Abonnement réseau`.
- [ ] Suites ouvertes côté `www`:
  - poursuivre le nettoyage des wording historiques autour de la vue BO `reseau_contrats`
  - conserver les neutralisations de write paths contrat sur la vue BO réseau durable.

## PATCH 2026-03-11 — Stabilisation BO minimale des points d’entrée réseau
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Clarification de la fiche client TdR:
  - le libellé BO `Offre réseau` n’est plus utilisé pour ouvrir `Abonnement réseau`;
  - la fiche client distingue maintenant:
    - `Abonnement réseau`
    - `Voir / gérer les affiliés`.
- [x] Requalification de `reseau_contrats`:
  - titre, texte d’aide et wording recentrés sur la vue BO transverse interne durable de pilotage réseau;
  - l’écran ne se présente plus comme le lieu canonique du cadre négocié.
- [x] Neutralisation défensive des write paths contrat:
  - `save_contrat`
  - `activate_contract`
  - `close_contract`
  - ces actions renvoient désormais un message explicite de désactivation.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK
- [ ] Suites ouvertes:
  - lot moteur global pour supprimer le bi-catalogue support et l’auto-création legacy
  - lot BO transverse pour préparer `Gestion des affiliés`
  - lot PRO pour réaligner `Mon offre` et la page réseau TdR.

## RE-BASELINE 2026-03-11 — Cible canonique réseau
- [x] Audit relu sur:
  - `www/web/bo/master/bo_master_form.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Vérité canonique retenue:
  - une seule offre métier TdR cible: `Abonnement réseau`
  - `reseau_contrats` ne doit plus être lu comme second objet métier stable
  - la cible BO est la vue transverse `Gestion des affiliés`, portée à ce stade par `reseau_contrats`.
- [ ] Suites ouvertes:
  - supprimer les write paths contrat encore présents dans `reseau_contrats`
  - poursuivre le nettoyage des wording historiques autour de `reseau_contrats`
  - préparer une éventuelle extraction future si la vue BO réseau change de route, sans changer sa fonction durable.

## PATCH 2026-03-10 — Hotfix Étape 2: entrée TdR `+` vers `Abonnement réseau`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - audit logique relu:
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif BO livré:
  - le `+` de la fiche client TdR propose désormais `Offre propre` / `Offre réseau`;
  - `Offre propre` conserve le comportement historique inchangé;
  - `Offre réseau` ouvre directement le formulaire `offres_clients` prérempli sur `Abonnement réseau`;
  - le bloc de paramétrage interne `Abonnement réseau` est désormais visible dès l’ajout ciblé, pas seulement en édition.
  - ajustement de robustesse:
    - la fiche client assure le catalogue `Abonnement réseau` avant gating de l’UI;
    - le dropdown est migré vers `data-bs-toggle="dropdown"` pour correspondre au BO Bootstrap 5.
- [x] Garde-fou conservé:
  - pour un client non TdR, le `+` conserve le flux historique standard.
- [x] Tests / recette:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php` OK
  - test manuel ajouté: `documentation/specs/tests/reseau-abonnement-reseau-hotfix-tdr-plus-pending-payment.md`

## PATCH 2026-03-10 — Étape 2 BO `Abonnement réseau`: offre distincte via `Ajouter une offre`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_aside.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Création nouvelle offre:
  - nouvelle entrée catalogue `Abonnement réseau` assurée par helper global;
  - reconnaissance support réseau élargie au nouveau catalogue avec fallback legacy.
- [x] Intégration au parcours `Ajouter une offre`:
  - le formulaire standard `offres_clients` reste inchangé à l’ajout;
  - l’option `Abonnement réseau` n’est visible que pour une TdR sélectionnée dans le champ `Client`;
  - choisir `Abonnement réseau` crée la ligne en `En attente`, la rattache au contrat réseau existant et renvoie ensuite vers l’édition dédiée pour le paramétrage.
- [x] Reprise du paramétrage négocié:
  - sync BO du montant négocié, de la périodicité, du quota inclus, de l’offre cible et de la jauge cible;
  - passage `En attente -> Active -> Terminée` via l’édition standard de l’offre.
- [x] Affichage des offres incluses:
  - la vue détail `offres_clients` de l’abonnement affiche uniquement les lignes incluses `cadre`, avec statut, période, périodicité et prix.
- [x] Tests / recette:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l www/web/bo/master/bo_master_form.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_aside.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - test manuel ajouté: `documentation/specs/tests/reseau-abonnement-reseau-etape2.md`

## PATCH 2026-03-10 — Étape 1 BO `Offre réseau`: recentrage hors cadre
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Retrait du contrat cadre de la page actuelle:
  - suppression des blocs, CTA et formulaires BO liés au contrat cadre / négocié dans `reseau_contrats`.
- [x] Recentrage hors cadre:
  - la vue BO n'affiche plus que les offres affiliées hors cadre, avec statut, période, périodicité, remise et tarif.
  - la création directe hors cadre reste possible depuis un bloc dédié pour les affiliés sans offre active.
- [x] Renommage fonctionnel:
  - titre BO `Gestion de l'offre réseau`;
  - CTA fiche client `Gérer l'offre réseau`.
- [x] Tests / recette:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - test manuel ajouté: `documentation/specs/tests/reseau-offre-reseau-etape1.md`

## PATCH 2026-03-10 — BO `offres_clients`: `Terminer` une offre réseau = clôture réelle
- [x] Surface BO ajustée:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Règle appliquée:
  - sur une offre réseau support, un passage BO à `id_etat=4` déclenche la clôture réelle du réseau;
  - la ligne support passe en historique immédiatement;
  - les offres déléguées actives liées sont terminées et les activations affiliés désactivées;
  - une nouvelle offre support `En attente` est recréée pour la suite.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-09 — BO contrat cadre: formulaire masqué hors activation/édition
- [x] Surfaces BO ajustées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Flux livré:
  - `inactif` / `cloture`:
    - champs masqués par défaut;
    - `Activer un contrat cadre` ouvre le formulaire;
    - validation unique des paramètres puis activation.
  - `actif`:
    - champs visibles en lecture seule par défaut;
    - CTA `Modifier` pour réouvrir l'édition;
    - CTA `Clôturer ce contrat cadre` masqué pendant l'édition;
    - sauvegarde puis retour à la vue lecture seule.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK

## PATCH 2026-03-09 — migration SQL canonique `contract_state` du module BO réseau
- [x] Surface BO / schéma ajustée:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Migration idempotente ajoutée:
  - ajout de la colonne `contract_state enum('inactif','actif','cloture') not null default 'inactif'`;
  - normalisation d’anciennes valeurs texte éventuelles:
    - `active`
    - `inactive`
    - `closed`
- [x] Backfill prudent:
  - état par défaut `inactif`;
  - promotion en `actif` uniquement si `id_offre_client_contrat` pointe une offre support active `id_etat=3`;
  - pas d’inférence automatique vers `cloture`.
- [x] Risque documenté:
  - exécution automatique de ce SQL depuis `cron_routine_bdd_maj.php`: non trouvé dans le code audité.

## PATCH Étape 2A — lisibilité BO de la part variable affiliés après remise réseau (2026-03-09)
- [x] Surface BO ajustée:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Lecture BO ajoutée:
  - la synthèse `Part variable affilies` rappelle le taux de remise réseau appliqué au calcul courant;
  - l’assiette de remise affichée est le nombre d’affiliés détenant une délégation active, `cadre` ou `hors_cadre`;
  - la colonne `Offre` affiche désormais aussi la jauge de l’offre active;
  - nouvelle colonne `Tarif`:
    - `offre déléguée incluse contrat cadre` -> `montant cadre négocié`, `nb d’offres incluses actives`, puis `HT / mois`;
    - `offre déléguée hors cadre` -> `HT`, `remise réseau`, puis `HT appliqué / mois`;
    - `offre propre` -> `HT / mois`;
    - `aucune offre` -> `-`.
- [x] Garde-fou de lisibilité:
  - la colonne `Offre` reste focalisée sur le lien et le libellé BO;
  - les montants sont isolés dans `Tarif`.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH Étape 2A — vitrine tarifaire alignée sur le référentiel tarifaire global (2026-03-09)
- [x] Surfaces WWW concernées:
  - `www/web/fo/modules/ecommerce/tarifs/fr/fo_tarifs_offre_detail.php`
  - `www/web/fo/modules/ecommerce/offres_paniers/fr/fo_offres_paniers_form_script.php`
- [x] Effet fonctionnel:
  - la vitrine continue d’utiliser le widget partagé abonnement;
  - le write path panier se recale désormais côté `global` sur le référentiel unique pour les cas couverts.
- [x] Audit parallèle BO réseau:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - création hors cadre confirmée via le helper global de prix, sans refonte de l’écran BO.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` OK

## PATCH Étape 2A — CTA BO `Activer` hors cadre unifié (2026-03-09)
- [x] Surfaces BO ajustées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Correction d’affichage:
  - ancienne condition erronée:
    - CTA affiché seulement si quota cadre dispo
    - ou offre cible présente
    - ou délégation legacy déjà réactivable
  - nouvelle condition:
    - CTA affiché pour tout affilié sans offre active, sauf `Offre propre`.
- [x] Flux BO livrés:
  - cas cadre exploitable:
    - activation auto avec l’offre cible du cadre
  - cas hors cadre unifiés:
    - pas de contrat exploitable
    - pas d’offre cible cadre
    - quota cadre atteint
  - dans ces cas:
    - choix BO de l’offre
    - choix BO de la jauge / capacité
    - création d’une nouvelle délégation hors cadre.
- [x] Simplification UI:
  - le select de réactivation d’une délégation existante est retiré de la colonne `Action`;
  - le formulaire poste désormais systématiquement `id_offre_client_deleguee=0`.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK

## PATCH Étape 2A — fermeture BO contrat cadre réseau (2026-03-09)
- [x] Surfaces BO finalisées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Évolutions livrées:
  - rechargement du reclassement quota/historique à l’ouverture de la page;
  - affichage explicite des champs métier:
    - `Montant cadre négocié (HT)`
    - `Nombre max d'affiliés inclus dans le cadre`
    - `Offre SI dédiée cible pour les affiliés couverts`
  - synthèse BO alignée sur le moteur global:
    - délégations actives résolues
    - quota absorbé
    - places incluses restantes
    - offre cible auto
  - table affiliés branchée sur le statut commercial effectif:
    - `offre propre`
    - `offre déléguée incluse contrat cadre`
    - `offre déléguée hors cadre`
    - `aucune offre`
- [x] Décision UX:
  - retrait du pilotage manuel `cadre / hors_cadre` dans cette vue pour éviter une contradiction avec le reclassement automatique.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH Étape 2A — refonte du tableau BO “Affiliés du siège” (2026-03-09)
- [x] Surface BO ajustée:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Recomposition du rendu:
  - suppression des colonnes:
    - `Activation réseau`
    - `Offre déléguée résolue`
  - nouvelles colonnes:
    - `Statut commercial`
    - `Offre`
  - libellés harmonisés:
    - `Offre propre`
    - `Déléguée incluse contrat cadre`
    - `Déléguée hors cadre`
    - `Aucune offre`
  - offre active désormais affichée comme objet BO manipulable avec lien direct `offres_clients`.
- [x] Colonne action clarifiée:
  - `Non pilotable ici`
  - `Désactiver`
  - `Activer`
- [x] CTA désormais câblés de bout en bout:
  - `Activer`:
    - write path BO dédié
    - création de l’offre cible si nécessaire
    - ou activation d’une offre déléguée existante
    - puis reclassement cadre/hors cadre
  - `Désactiver`:
    - termine la ligne `ecommerce_offres_to_clients` déléguée active
    - puis refresh facturation + reclassement
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK

## PATCH Étape 2A — triggers BO de désaffiliation / suppression affilié (2026-03-09)
- [x] Surfaces BO complétées:
  - `www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_functions.php`
- [x] Correction appliquée:
  - toute modification BO de `clients.id_client_reseau` rejoue désormais le reclassement sur l’ancien et le nouveau siège;
  - la suppression BO d’un affilié rattaché rejoue le reclassement du siège d’origine.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_script.php` OK
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_functions.php` OK

## AUDIT Étape 2A — lien réseau historique et remise associée (2026-03-09)
- [x] Audit ciblé du routing public/proxy:
  - `pro/web/.htaccess`
- [x] Constat:
  - le lien réseau historique existe toujours sous deux formes:
    - `/utm/reseau/{slug}`
    - `/utm/reseau/{slug}/{CODE}`
  - la variante avec `CODE` ne pilote pas un contrat cadre;
  - elle ne fait que transporter un code remise en plus du rattachement réseau.
- [x] Conséquence:
  - côté routing, il n’existe pas d’ancienne route dédiée “activation contrat cadre” à réutiliser;
  - le futur flux automatique devra rester branché sur cette entrée UTM réseau existante, mais avec une décision métier portée par un helper global.

## AUDIT Étape 2A — contrat cadre automatique (2026-03-09)
- [x] Audit ciblé de la surface BO `reseau_contrats`:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Constat BO:
  - la page sait déjà persister:
    - `montant_socle_ht`
    - `max_affilies_activables`
    - `id_offre_delegation_cible`
  - mais elle pilote encore explicitement les affiliés un par un via:
    - activation manuelle
    - `mode_facturation` manuel.
- [x] Décision d’audit:
  - pas de patch BO sûr tant que le moteur automatique global n’existe pas;
  - supprimer maintenant le pilotage manuel du BO sans nouveau moteur créerait une incohérence immédiate entre UI, agrégateur et flux d’affiliation.
- [x] Cible documentée:
  - recentrer le premier écran sur:
    - montant cadre négocié
    - affiliés inclus / activables
    - offre incluse par affilié
  - puis faire dériver automatiquement la synthèse affilié/cadre/hors cadre depuis le moteur global.

## PATCH Étape 2A — simplification finale BO `mode_facturation` (2026-03-09)
- [x] Surfaces BO + migration:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Donnée ajoutée:
  - `ecommerce_reseau_contrats_affilies.mode_facturation`
  - valeurs:
    - `cadre`
    - `hors_cadre`
- [x] UI minimale ajoutée:
  - nouvelle colonne `Facturation` dans la liste des affiliés du siège;
  - select léger pilotable par affilié:
    - `Inclus dans le cadre`
    - `Facturé en plus`
  - rappel visuel de l’effet facture courant.
- [x] Migration de simplification:
  - les anciennes délégations actives issues TdR sont converties en `hors_cadre`;
  - le BO permet ensuite de reclasser explicitement un affilié en `cadre` quand il est absorbé par la négociation.
- [x] Vérification:
  - `php -l` OK sur `bo_reseau_contrats_list.php`, `bo_reseau_contrats_script.php`.

## PATCH 2026-03-09 — BO contrat cadre: CTA état explicite + synthèse agrégat
- [x] Surfaces BO ajustées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] CTA métier ajoutés:
  - `Activer un contrat cadre`
  - `Modifier le contrat cadre`
  - `Clôturer ce contrat cadre`
- [x] Effet attendu:
  - `Activer` -> `contract_state=actif`
  - `Clôturer` -> `contract_state=cloture`
  - refresh immédiat de l’agrégat réseau et du reclassement cadre / hors cadre
- [x] Synthèse BO ajustée:
  - affiche l’état explicite du contrat cadre;
  - sépare `Cadre négocié` et `Socle appliqué à l’agrégat`;
  - n’autorise l’activation dans le cadre que si le contrat est `actif`.
- [ ] Migration requise:
  - ajouter la colonne SQL `ecommerce_reseau_contrats.contract_state`;
  - sans cette colonne, la page n’a qu’un fallback legacy de lecture et affiche un warning opérateur.

## PATCH Étape 2A — simplification BO contrat cadre réseau TdR (2026-03-09)
- [x] Surfaces BO ajustées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] UI simplifiée:
  - suppression des CTA de maintenance `Créer / rattraper offre réseau dédiée` et `Raccrocher offres déléguées legacy` de la page courante;
  - affichage en lecture seule de la ligne support du contrat réseau, avec lien discret vers la ligne `offres_clients`;
  - renommage métier:
    - `Montant socle réseau HT / mois` -> `Montant cadre négocié (HT)`;
    - `Socle réseau` -> `Cadre négocié`;
  - masquage du premier écran pour les champs legacy / techniques:
    - `Jauge cible (référentiel)`
    - `Offre cible de délégation (catalogue)`
  - conservation des paramètres encore utilisés par l’activation réseau:
    - `max_affilies_activables`
    - `max_joueurs_par_affilie`
- [x] Garde-fou script:
  - `save_contrat` réutilise désormais les valeurs déjà persistées si certains champs ne sont plus postés par l’écran simplifié.
- [x] Audit métier associé:
  - la formule actuelle reste:
    - `montant facturable TdR = montant_socle_ht + somme des offres déléguées legacy actives`;
  - aucune donnée existante ne distingue en code / DB:
    - affilié déjà couvert par le cadre négocié;
    - affilié réellement hors cadre.
- [ ] TODO:
  - introduire une donnée explicite de couverture cadre avant toute correction sûre de double comptabilisation.

## PATCH Étape 2B — filtre BO TdR sur les offres déléguées legacy (2026-03-09)
- [x] Surface BO corrigée:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- [x] Règle retenue:
  - sur une fiche client TdR (`flag_client_reseau_siege=1`), une ligne legacy déléguée est identifiée par:
    - `ecommerce_offres_to_clients.id_client = siège`
    - `ecommerce_offres_to_clients.id_client_delegation > 0`
- [x] Correction appliquée:
  - exclusion de ces lignes de la section `Offres` de la fiche client TdR;
  - conservation des offres propres TdR et de la ligne support `Contrat cadre réseau`;
  - correction complémentaire fiche client affilié:
    - inclusion des lignes legacy où `id_client_delegation = affilié` et `id_client <> affilié`;
    - affichage simple du nom du compte TdR dans la colonne `Délégation`;
  - aucun ajout de section dédiée “Offres déléguées”.
- [x] Vérification attendue:
  - la synthèse métier reste portée par `reseau_contrats`;
  - aucun impact sur la persistance, la facturation réseau ou le resolver d’accès jeu.

## AUDIT Étape 2B — portage des offres déléguées réseau sur l’affilié (2026-03-09)
- [x] Audit ciblé surfaces BO / write path:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`
- [x] Constat vérifié:
  - la fiche client BO du siège liste encore brut `ecommerce_offres_to_clients.id_client = siège`, donc inclut les lignes déléguées legacy;
  - le module BO `reseau_contrats` n’engendre pas encore une ligne d’offre portée par l’affilié: il sélectionne / active une ligne legacy existante du siège via `id_offre_client_deleguee`;
  - le seul write path générique exposant `id_client_delegation` reste le CRUD table-driven `offres_clients`, explicitement étiqueté legacy.
- [x] Conséquence:
  - le BO n’a pas encore de chemin métier complet “créer une offre affiliée portée par l’affilié avec origine TdR”.
- [x] Décision:
  - pas de patch UI-only sur la fiche client TdR;
  - la correction sûre passe par un write path métier dédié + migration de lecture BO pour séparer offres propres TdR et offres issues TdR portées par affilié.

## PATCH Étape 2A — facturation persistée de l’offre réseau TdR (2026-03-09)
- [x] Surfaces BO alignées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
  - `www/web/bo/cron_routine_bdd_maj.php`
- [x] Correction appliquée:
  - le BO `reseau_contrats` édite désormais le `montant_socle_ht` et affiche le montant facturable total de la TdR;
  - le prix persistant de la ligne support suit le recalcul métier centralisé;
  - les écrans BO lisant `ecommerce_offres_to_clients.prix_ht` restent cohérents sans patch UI dispersé.
- [x] Migration SQL:
  - ajout du champ `ecommerce_reseau_contrats.montant_socle_ht`;
  - script rendu idempotent par garde `INFORMATION_SCHEMA`.
- [x] Vérification:
  - `php -l` OK sur `bo_reseau_contrats_list.php`, `bo_reseau_contrats_script.php`, `cron_routine_bdd_maj.php`.
- [x] Ajustement BO complémentaire:
  - suppression des warnings d’affichage dus à un appel invalide de `montant(...)` dans la synthèse BO;
  - répercussion du montant facturable TdR dans la section `Offres` de la fiche client siège, sur la ligne `Contrat cadre réseau`.

## AUDIT Étape 2A — affichage BO offres TdR + montant contrat réseau legacy (2026-03-09)
- [x] Audit ciblé BO fiche client siège:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Constat vérifié:
  - la section `Offres` de la fiche client TdR liste brut les lignes `ecommerce_offres_to_clients` du siège, sans filtre excluant `id_client_delegation>0`;
  - le prix affiché dans cette section lit `eotc.prix_ht` brut, pas le montant réseau agrégé;
  - la vue BO `reseau_contrats` synchronise bien les délégations legacy dans le contrat dédié, mais n’affiche pas le montant agrégé.
- [ ] TODO hors périmètre:
  - décider si la fiche client BO legacy `Offres` doit masquer ou distinguer les lignes déléguées.

## PATCH Étape 2A — BO backfill offre réseau dédiée (2026-03-08)
- [x] Module BO réseau renforcé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Actions ajoutées:
  - auto-ensure de l’offre réseau dédiée à l’ouverture de la page contrat réseau siège.
  - bouton BO `Créer / rattraper offre réseau dédiée`.
  - action script `mode=backfill_siege` avec retour `backfill_ok`.
- [x] Vérification:
  - `php -l` OK sur les fichiers BO `reseau_contrats`.

## PATCH Étape 2 — Contrat cadre réseau BO (2026-03-06)
- [x] Nouveau module BO dédié (pilotage siège):
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_module_parametres.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - migration: `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Entrée fiche client siège:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php` (CTA `Gestion contrat réseau / délégation`).
- [x] UX de transition clarifiée:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`
  - champ délégation étiqueté legacy pour orienter vers le module métier dédié.
- [ ] TODO post-lot (`www`):
  - compléter la visibilité BO du journal d’actions réseau (liste/filtre dédié).
  - intégrer un contrôle explicite sur la résolution d’offre déléguée au moment de l’activation (si aucune ligne n’existe).

## AUDIT #4 — Delegation write path (id_client_delegation) (2026-03-06)
- [x] Write path confirmé côté BO:
  - le module `offres_clients` expose `id_client_delegation`:
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:39`
  - ajout/modification activés sur ce module:
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:299`
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:300`
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:301`
  - exécution via script master générique:
    - `www/web/bo/master/bo_master_script.php:15`
    - `www/web/bo/master/bo_master_script.php:20`
    - `global/web/lib/core/lib_core_module_functions.php:736`
- [x] Résultat audit:
  - pas de chemin métier dédié "déléguer offre" dans `www`; write possible via CRUD table-driven.
  - note détaillée: `notes/delegation-write-path-2026-03-06.md`
- [x] Next steps Lot 2 (`www`) réalisés:
  - ajout d’un entrypoint BO explicite via module `ecommerce/reseau_contrats`.
  - restriction du pilotage réseau par CRUD brut (module dédié + verrouillage générique côté socle).
- [ ] Next step restant:
  - afficher un audit trail métier BO plus complet (vue dédiée des actions historiques).

## AUDIT #2 — Offer lifecycle hooks (OFF/ON) (2026-03-06)
- [x] Hooks OFF confirmés (scope `www`):
  - cron principal d’inactivation:
    - impayé > 30 jours: `www/web/bo/cron_routine_bdd_maj.php:47` (`id_etat=10`)
    - expiration PAK: `www/web/bo/cron_routine_bdd_maj.php:73` (`id_etat=4`)
    - expiration ABN one-shot: `www/web/bo/cron_routine_bdd_maj.php:100` (`id_etat=4`)
    - expiration ABN sans engagement: `www/web/bo/cron_routine_bdd_maj.php:140` (`id_etat=4`)
  - BO manuel:
    - module `offres_clients` expose `id_etat` et autorise `modifier/supprimer`:
      - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:15`
      - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:299`
    - update SQL générique:
      - `global/web/lib/core/lib_core_module_functions.php:736`
    - delete SQL générique:
      - `global/web/lib/core/lib_core_module_functions.php:833`
- [x] Cartographie consolidée:
  - voir note: `notes/offer-lifecycle-hooks-2026-03-06.md`
- [ ] TODO Lot 3B (`www`):
  - ajouter un point de hook post-update/post-delete dans le cron `cron_routine_bdd_maj.php` pour déclencher la cascade délégation après chaque OFF.
  - cadrer le mode manuel BO: forcer une route dédiée (ou hook table-aware) pour ne pas rater la cascade quand `id_etat` est changé depuis le CRUD générique.
  - distinguer les causes OFF dans le cron (`UNPAID_TIMEOUT`, `EXPIRED_PAK`, `EXPIRED_ABN_ONESHOT`, `EXPIRED_ABN_NO_COMMITMENT`) pour propagation et audit.

## AUDIT #1 — Offer resolution (source of truth) (2026-03-06)
- [x] Constat scope `www`:
  - aucun resolver principal "offre active" défini dans ce repo.
  - usages observés: reporting/BO via `app_ecommerce_offres_client_get_liste(...)` (`www/web/bo/www/modules/entites/clients/bo_clients_list.php:61`, `www/web/bo/www/modules/syntheses/resumes/bo_resumes_list.php:1315`).
  - gestion des dates portée surtout par cron de transition d’état (`www/web/bo/cron_routine_bdd_maj.php:62`, `:73`, `:89`, `:100`).
- [ ] TODO Lot 1 (`www`):
  - éviter d’ajouter de nouvelles règles de résolution locale côté BO.
  - documenter explicitement que la source de vérité runtime réside dans `global`.

## AUDIT Réseau / Affiliation / Branding / Contenus partagés (2026-03-06)
- [x] Patch V1 landings operations distributeurs / marques (2026-05-07):
  - ajout de `www/web/lp/includes/config/lp_operations.php` comme configuration dediee des operations;
  - ajout de la route publique `/lp/operation/{slug}` dans `www/web/.htaccess`;
  - `www/web/lp/lp.php` charge les operations actives depuis la config et conserve le parcours d'activation via `/utm/reseau/{network_slug}`;
  - lecture publique, sans session PRO, du compte reseau et du branding reseau quand les helpers existants sont disponibles;
  - lecture du `visuel` branding reseau pour le hero quand `hero_image` n'est pas force en configuration;
  - lecture des contenus reseau partages via `app_ecommerce_reseau_content_share_ids_get(...)`, en affichant uniquement les jeux reseau exploitables quand ils existent;
  - affichage de deux actions signup/signin dans la landing, mais toutes deux conservent le parcours PRO reseau existant via `/utm/reseau/{slug}`;
  - fallback Cotton si le reseau ou son branding n'est pas disponible;
  - separation UI explicite entre offre commerciale produit et animation Cotton;
  - clarification obligatoire affichee pres des CTA: l'acces Cotton concerne uniquement l'animation de l'etablissement, l'offre commerciale produit reste geree par le distributeur;
  - une route operation non configuree ou desactivee renvoie une page 404 simple au lieu de retomber sur `offre-essai`.
- [ ] Recette V1 landings operations distributeurs / marques:
  - activer une entree config avec une vraie TdR operation;
  - verifier rendu desktop/mobile, logo reseau/fallback, couleurs et image hero;
  - verifier que le visuel reseau remonte quand `hero_image` est vide;
  - verifier que les contenus reseau partages remplacent les demos generiques, et que le fallback generique reste actif sans contenu reseau;
  - verifier le CTA `/utm/reseau/{slug}` vers PRO signup/signin;
  - verifier creation nouveau compte, connexion compte existant, quota atteint, support reseau inactif et compte deja rattache;
  - verifier que la landing ne promet pas l'activation automatique de l'offre commerciale produit.
- [x] Cartographie confirmée (preuves code):
  - Réécriture publique lien affiliation réseau:
    - `www/web/.htaccess:118` (`/utm/reseau/{seo_slug}` -> `/fo/fo.php?utm_source=reseau&utm_campaign=affiliation&utm_term=...`)
    - `www/web/.htaccess:121` (variante avec code remise)
  - Passage vers `pro`:
    - `www/web/fo/fo.php:64`
    - `www/web/fo/fo.php:67`
    - `www/web/fo/fo.php:71`
  - Flag réseau dans BO:
    - `www/web/bo/www/modules/entites/clients/bo_module_parametres.php:96` (`flag_client_reseau_siege`)
    - `www/web/bo/www/modules/entites/clients/bo_module_parametres.php:107` (`id_client_reseau`)
  - Lien d’affiliation affiché en BO:
    - `www/web/bo/www/modules/entites/clients/bo_clients_list.php:144`
- [x] Existant confirmé:
  - Le BO permet de marquer un client “tête de réseau” et de renseigner l’appartenance réseau (champs `clients.flag_client_reseau_siege` / `clients.id_client_reseau`).
  - Le lien d’affiliation affiché est de type slug (`/utm/reseau/{seo_slug}`), sans token dédié.
  - La landing publique `www` consomme les paramètres UTM puis redirige vers `pro` avec ces mêmes paramètres.
- [ ] Manques identifiés (scope `www`):
  - Pas de génération/rotation/révocation de token d’affiliation réseau dans BO.
  - Pas de TTL/signature/HMAC spécifique au lien d’affiliation réseau.
  - Pas de journal d’audit dédié “création/rotation/révocation lien affiliation réseau”.
- [ ] Risques:
  - Lien basé sur slug prédictible.
  - Paramètres UTM manipulables côté URL.
  - Absence de mécanisme d’expiration pour le lien d’affiliation réseau.

## PATCH BO Reporting — Sessions papier dans `Jeux et joueurs` (2026-02-28)
- [x] Audit ciblé:
  - entrée: `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - constats:
    - le total `Sessions` excluait des sessions papier via un filtre “has players” sur certains chemins.
    - les ratios `joueurs/client` et `joueurs/session` utilisaient les mêmes agrégats de sessions.
- [x] Correctifs appliqués:
  - `Sessions` (table + totals + série N-1): comptage des sessions terminées et configurées, papier + numérique (toujours hors démo).
  - ajout d’un agrégat dédié `sessions numériques` (sessions avec joueurs) utilisé uniquement pour les ratios joueurs:
    - `Moy. joueurs / client`
    - `Moy. joueurs / session` (global + par jeu).
  - note UI explicite mise à jour dans le bloc `Jeux et joueurs`.
- [x] Vérification technique:
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] QA manuelle BO:
  - une session papier terminée sans joueurs doit incrémenter `Sessions` (mois + total).
  - cette session ne doit pas augmenter les ratios `joueurs/client` et `joueurs/session`.
  - une session numérique avec joueurs doit continuer d’alimenter `Joueurs` + ratios.

## PATCH BO Reporting — Démos période de référence (2026-02-28)
- [x] Audit ciblé:
  - Entrée reporting: `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - Zones impactées:
    - endpoint AJAX détail démos (`bo_facturation_pivot_saas_handle_games_demo_detail_ajax`)
    - agrégations mensuelles (`$demo_sessions`, métrique démos nouveaux inscrits)
    - section `Objectifs`
    - tableau `Visiteurs / prospects / clients`
    - libellés modal JS
- [x] Correctifs appliqués:
  - `Objectifs > Demos`: ajout des démos des nouveaux inscrits de la période de référence.
## Done (2026-03-23)
- [x] BO clients: ajout d'une action `Generer un lien EC temporaire` par contact sur la fiche client `www/web/bo/www/modules/entites/clients/bo_clients_view.php`.
- [x] BO clients: ajout du mode `generer_lien_ec_temporaire` dans `www/web/bo/www/modules/entites/clients/bo_clients_script.php`, avec verification que le contact est bien rattache au client avant generation.
- [x] BO clients: retour sur la meme fiche avec l'URL complete prete a copier, sans exposition cote front EC standard.
- [x] Verification technique:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php`

  - Tableau: renommage `Demos inscrits` -> `Démos nvx inscrits`.
  - Recalcul colonne: client inscrit dans la période ET session démo dans la période.
  - Détail modal `scope=users`: aligné sur le même filtre de période (pour cohérence clic/agrégat).
- [x] Sémantique vérifiée:
  - colonne historique conservée en volume de **sessions démo** (pas distinct inscrits).
- [x] Vérification technique:
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] QA manuelle BO:
  - ancien inscrit + démo période => non compté dans `Démos nvx inscrits`.
  - nouvel inscrit sans démo => non compté.
  - nouvel inscrit + démo période => compté.

## Done (2026-03-08)
- [x] Étape 2A fix ciblé: branchement du vrai point d’entrée BO de création/rattrapage offre réseau dédiée dans `bo_clients_script.php` au moment des modifications client avec `flag_client_reseau_siege=1`.
- [x] Étape 2A fix ciblé: module BO `reseau_contrats` enrichi d’une action explicite de sync legacy des offres déléguées et auto-sync au chargement de la fiche contrat.
- [x] 2026-03-08 — UX BO fiche client TdR: suppression du CTA d’intro `Gestion contrat réseau / délégation`; ajout du CTA `Gérer le contrat` uniquement sur la ligne d’offre `Contrat cadre réseau` (slug `contrat-cadre-reseau`) vers la même vue `?a=www&t=ecommerce&m=reseau_contrats&p=list&id_client_siege=<id>`.
- [x] 2026-03-10 — Audit runtime BO `offres_clients`: le vrai write path du passage manuel à `Terminée` reste `do_script.php -> bo_offres_clients_script.php -> mode=modifier`; fix appliqué sur la garde métier pour reconnaître aussi les lignes support legacy déjà liées au contrat réseau (`id_offre_client_contrat`).
- [x] 2026-03-10 — Audit runtime BO `offres_clients`: le `id_etat=4` du save était réécrit par le refresh générique post-`module_modifier(...)`; bypass ciblé ajouté uniquement pour le cas explicite `offre support réseau -> Terminée`, afin de laisser le hook de clôture réelle s’exécuter.
- [x] 2026-03-11 — BO `offres_clients`: abandon du patch opportuniste dans le form générique; ajout d’un renderer dédié `Abonnement réseau` via hook minimal dans `bo_master_form.php`, et retour du form classique `offres_clients` au comportement historique hors contexte réseau.
- [x] 2026-03-11 — BO `offres_clients` view: ajout d’un hook minimal `bo_module_view_flags.php` pour masquer le bloc historique `Informations` uniquement sur le support canonique `Abonnement réseau`.
- [x] 2026-03-11 — BO réseau: `date_debut` et `date_facturation_debut` sont désormais transmises par `bo_offres_clients_script.php` et persistées explicitement par `app_ecommerce_reseau_abonnement_bo_sync_offer_client(...)`, ce qui réaligne l’affichage `Début` / `Début fact.` sur la fiche client TdR.
- [x] 2026-03-11 — BO `offres_clients` view: ajout d’un hook minimal `bo_module_view_top.php` pour rendre le bloc `Abonnement réseau` en haut de la colonne de gauche avant `Caractéristiques`, avec affichage lecture seule de `date_debut` et `date_facturation_debut`.
- 2026-03-09: bo/reseau_contrats
  - faire retourner `activate_contract` sur un état `en attente de paiement` au lieu d'une activation commerciale immédiate;
  - exposer le lien Stripe de l'offre réseau support dans l'écran BO quand l'offre reste `pending_payment`.

## Done (2026-03-13)
- [x] Routine BO `cron_routine_bdd_maj.php`: ajout de l'execution des remplacements differes d'offres deleguees hors cadre. La routine scanne les cibles planifiees (`id_etat=2` + marqueur de remplacement differe), puis active la cible apres terminaison effective de la source.

## Done (2026-03-20)
- [x] BO reporting jeux: extraction initiale du bloc `Reporting jeux (agregats)` hors de `www/web/bo/cron_routine_bdd_maj.php` vers un helper reutilisable.
- [x] BO reporting jeux: ajout du cron dedie `www/web/bo/cron_reporting_games_aggregates.php` pour permettre un lancement isole des agregats jeux sans executer toute la routine BDD.
- [x] BO `facturation_pivot`: branchement preferentiel des sessions mensuelles sur `reporting_games_sessions_monthly` et des sessions numeriques sur `reporting_games_sessions_detail`.
- [x] BO `facturation_pivot`: branchement preferentiel de la serie N-1 jeux sur `reporting_games_sessions_monthly` quand le cache cron est disponible.
- [x] Portage separe sur `main` du meme correctif BO reporting jeux, sans merge `develop` vers `main`, pour un test/prod isole.
- [x] Verification technique:
  - `php -l www/web/bo/cron_reporting_games_aggregates.php`
  - `php -l www/web/bo/cron_routine_bdd_maj.php`
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`

## Done (2026-03-30)
- [x] BO reporting jeux: retrait definitif de l'appel aux agrégats jeux dans `www/web/bo/cron_routine_bdd_maj.php` pour laisser ce cron au perimetre "commerce".
- [x] BO reporting jeux: deplacement du helper vers `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php` avec point d'entree explicite `bo_facturation_pivot_games_aggregates_refresh()`.
- [x] BO reporting jeux: evolution de `www/web/bo/cron_reporting_games_aggregates.php` en vrai cron "jeux" avec envoi de mail de rapport via Brevo.
- [x] Verification technique:
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php`
  - `php -l www/web/bo/cron_reporting_games_aggregates.php`
  - `php -l www/web/bo/cron_routine_bdd_maj.php`

## Done (2026-04-14)
- [x] FO includes `photos_ec`: réalignement des includes FO (`fo_custom.css`, `fo_custom_20251120.css`, `fo_header_main.php`, `fo_footer_main.php`, `fo.js`) sur `main` après resynchronisation locale depuis prod.
- [x] FO includes `photos_ec`: restauration des styles perdus sur les logos de références et les images harmonisées catalogue, sans toucher aux évolutions métier de branche sur `place` et `agenda/session`.
- [x] Vérification technique:
  - `php -l www/web/fo/includes/header/fo_header_main.php`
  - `php -l www/web/fo/includes/footer/fo_footer_main.php`
- [x] FO fiche `place`: suppression du rendu serveur initial pour les onglets `Agenda` et `Sessions passées` dans `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`.
- [x] FO fiche `place`: ajout du chargement AJAX par section via `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php` (`overview`, `agenda`, `archive`).
- [x] FO fiche `place`: mutualisation du rendu sessions FO dans `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`.
- [x] FO fiche `place`: bascule automatique de l'onglet initial vers `Agenda` si la réponse AJAX `overview` confirme l'absence de classements exploitables.
- [x] FO fiche `place`: séparation des requêtes AJAX `overview` (classements) et `summary` (synthèse) pour laisser les leaderboards s'afficher avant le calcul historique plus lourd.
- [x] FO fiche `place`: ajout d'un cache de session dédié aux leaderboards par `id_client + jour + année + trimestre`, sans impact sur `pro` / `play`.
- [x] FO liste `place`: alignement du filtre géographique sur le pattern `agenda/play` avec support des pays étrangers en plus des départements FR réellement présents.
- [x] FO liste `place`: conservation des libellés départements référentiels complets (`n° + nom`) dans le select public.
- [x] FO listes `agenda` / `place`: exclusion explicite de `France` de la section `pays`, les départements FR restant l'unique point d'entrée côté France.
- [x] Header FO: raccourci du libellé dropdown joueur vers `Agenda des soirées jeux` avec protection CSS `white-space: nowrap` sur la navigation desktop.
- [x] Archive FO `place`: hardening du helper global `cotton_quiz_get_classement_session(...)` pour éviter un fatal legacy sur certaines sessions quiz passées.
- [x] Archive FO `place`: remplacement du rendu AJAX des sessions passées par une carte dédiée dans `fo_clients_view_shared.php`, sans réutiliser le bloc legacy complet `fo_sessions_list_bloc.php`.
- [x] FO fiche `place` / archives: ajout d'un helper global `app_client_joueurs_dashboard_archive_sessions_get(...)` reprenant la logique de sélection des archives pro pour les sessions passées utiles du lieu.
- [x] FO fiche `place` / leaderboards: la colonne `sessions récentes` réutilise désormais ce helper global partagé avec filtre jeu/date, au lieu d'une logique locale.
- [x] FO fiche `place` / agenda AJAX: remplacement du rendu legacy `fo_sessions_list_bloc.php` par une carte FO dédiée dans le contexte asynchrone.
- [x] FO fiche `place` / filtre saison: correctif JS sur l'appel `loadOverview(...)` pour transmettre correctement `filter_year` et `filter_quarter`.
- [x] Vérification technique:
  - `php -l www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## Done (2026-04-16)
- [x] FO fiche `place`: harmonisation du rendu `descriptif_court` / `descriptif_long` avec le back-office `pro`.
- [x] FO fiche `place`: nettoyage des anciens `<br>` / balises legacy avant rendu public.
- [x] FO fiche `place` / onglet `Sessions passées`: les visuels des cartes injectées en AJAX ne passent plus par `js-lazy`, ce qui réactive l'affichage du fallback image de jeu quand aucune photo gagnant n'existe.
- [x] Vérification technique:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `php -l www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - `php -l www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## PATCH 2026-04-17 — Agenda / sessions passées: bascule FO alignée sur la terminaison réelle
- [x] Audit ciblé:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
  - `www/web/fo/modules/widget/fr/fo_widget_cotton_agenda.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - l'onglet `Agenda` des fiches `place`, la liste publique `agenda` et le widget agenda n'utilisent plus seulement le critère calendrier;
  - les listes sont maintenant re-filtrées via la règle partagée `archive` vs `upcoming`, cohérente avec les fiches détail;
  - le bloc carte FO calcule aussi `Jeu terminé` via le helper partagé au lieu du simple `app_session_get_chronology(...)`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/widget/fr/fo_widget_cotton_agenda.php`

## PATCH 2026-04-17 — FO `Sessions passées`: inclusion des sessions du jour déjà terminées
- [x] Audit ciblé:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livré:
  - le helper `fo_clients_view_archive_sessions_get(...)` rappelle maintenant l'archive globale avec `include_upcoming_sessions = 1`;
  - effet attendu: une session du jour déjà terminée, masquée de l'onglet `Agenda`, devient aussi visible dans `Sessions passées` sans attendre le lendemain.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## PATCH 2026-04-17 — FO `place`: podium agrégé `Bingo Musical` éclaté par ligne comme les autres jeux
- [x] Audit ciblé:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- [x] Correctif livré:
  - suppression de la branche spéciale `bingo` dans `fo_clients_view_leaderboard_podium_cards_get(...)`;
  - le podium agrégé `www` utilise maintenant la même règle que les autres jeux: une carte par ligne de podium, même en cas d'ex-aequo sur un rang.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## PATCH 2026-04-17 — WWW sessions: libellé `quiz` compact sur cartes et titre détail
- [x] Audit ciblé:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
- [x] Correctif livré:
  - les cartes `Agenda` / `Sessions passées` de la fiche `place` affichent maintenant `quiz_series_label` en priorité pour `Cotton Quiz`;
  - les cartes génériques `agenda` du site utilisent la même priorité;
  - le `h1` de la page détail session `www` utilise lui aussi ce libellé court;
  - si aucun libellé de séries n'est disponible, le fallback garde `theme`, sauf s'il duplique déjà `nom_court`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`

## PATCH 2026-04-17 — WWW sessions: raccord au helper partagé de libellé compact `quiz`
- [x] Audit ciblé:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - les écrans `www` reposent désormais sur `app_session_quiz_compact_label_get(...)` au lieu d'une logique locale dupliquée;
  - le fallback conserve `theme` hors libellé compact, sans réintroduire le doublon `Cotton Quiz Cotton Quiz`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`

## PATCH 2026-04-17 — Fiche session `www`: mention de réserve sous les séries programmées
- [x] Audit ciblé:
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
- [x] Correctif livré:
  - ajout de la mention `(Sous réserve de modification par l'organisateur.)` sous le bloc `Séries programmées`;
  - la mention n'est affichée que pour les sessions non archivées.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`

## PATCH 2026-04-17 — Fiche session `www`: bloc `Playlist` visible aussi pour `blindtest` / `bingo`
- [x] Audit ciblé:
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
- [x] Correctif livré:
  - ajout d'un bloc `Playlist : {nom_playlist}` entre `Date` et `Lieu` pour les sessions `blindtest` / `bingo` quand une playlist est disponible;
  - ajout de la même mention de réserve sous ce bloc, tant que la session n'est pas archivée.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`

## Done (2026-04-15)
- [x] FO fiche `place` / perf lot 1: la route AJAX `overview` ne recharge plus la liste complète des `sessions passées` ni l'agenda complet pour calculer les flags d'onglets.
- [x] FO fiche `place` / perf lot 1: ajout de helpers FO légers `has_agenda` / `has_archive` limités à 1 résultat.
- [x] FO fiche `place` / perf lot 1: le helper partagé des archives ne recharge plus les sessions à venir quand l'usage ne concerne que l'historique.
- [x] FO fiche `place` / onglet `Sessions passées`: illustration des cartes par la photo du rang 1 quand elle existe, sinon fallback sur le visuel actuel.
- [x] FO fiche `place` / onglet `Sessions passées`: ajout d'un bouton `Afficher plus` chargeant 12 cartes supplémentaires par lot en AJAX.
- [x] FO fiche `place` / onglet `Classements`: retrait de la colonne desktop `sessions récentes`, avec conservation du bloc en commentaire pour réutilisation future sans coût de calcul.
- [x] FO fiche `place` / onglet `Classements`: ajout d'un podium agrégé au-dessus du tableau `Top 10`.
- [x] FO fiche `place` / onglet `Classements`: réutilisation des données globales `players_podium` / `teams_podium`, comme côté `pro`.
- [x] FO fiche `place` / onglet `Classements`: reprise du style visuel du podium affiché sur la page détail d'une session terminée du site.
- [x] FO fiche `place` / onglet `Classements`: retour de la limite desktop `sessions récentes` sur la seule hauteur du tableau, avec podium étendu au-dessus sur toute la largeur.
- [x] FO fiche `place` / onglet `Classements`: ajout d'un espacement desktop `justify-content-between` / gutters renforcés sur la ligne `classement + sessions récentes`.
- [x] FO fiche `place` / onglet `Classements`: audit structurel puis refactor de la colonne `sessions récentes` avec suppression du `padding-top` desktop et wrapper centré à largeur max.
- [x] FO fiche `place` / onglet `Classements`: hardening responsive mobile du tableau via wrapper explicite `place-leaderboard-table-responsive` + nettoyage du `rem` CSS parasite.
- [x] FO fiche `place` / onglet `Classements`: ajout d'une largeur minimale mobile sur `.table-classement` pour forcer le scroll horizontal au lieu du tassement/coupage des colonnes.
- [x] Vérification technique:
  - `php -l www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
## PATCH 2026-05-11 — LP operations reseau automatiques depuis TdR
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/.htaccess`
  - `www/web/lp/includes/css/lp_custom.css`
  - `www/web/lp/includes/config/lp_operations.php`
  - helpers reseau/TdR: `global/web/app/modules/ecommerce/app_ecommerce_functions.php`, `global/web/app/modules/entites/clients/app_clients_functions.php`, `global/web/app/modules/general/branding/app_branding_functions.php`
- [x] Correctif livre:
  - suppression de la dependance de publication a `lp_operations.php`;
  - resolution automatique de `/lp/operation/{slug}` depuis une operation BO (`operations_evenements.seo_slug`) rattachee a une TdR, ou depuis la TdR (`clients.seo_slug`) en fallback;
  - affichage du nom, accroche, descriptif, logo, visuel, couleurs, periode et jeux reseau quand disponibles;
  - CTA unique vers `/utm/reseau/{slug}` et phrase compte existant sans second CTA equivalent;
  - badge/CTA/wording conditionnes par la presence d'un abonnement reseau actif exploitable, sans conditionner l'existence de la LP a cet abonnement;
  - wording Cotton neutralise, sans promesse commerciale distributeur ajoutee.
- [x] Garde-fous:
  - slug invalide/inconnu, operation privee, operation sans TdR exploitable, compte non TdR ou compte offline => 404 simple;
  - anciennes LP historiques conservees hors route `landing-operation`.
- [ ] Verification serveur a completer avec une TdR reelle:
  - landing publiee sans config manuelle;
  - cas slug inexistant, TdR inactive, TdR sans abonnement, abonnement sans dates, donnees/design/jeux absents.
# PATCH 2026-05-11 - LP reseau enrichie par abonnement reseau

- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/lp/lp.php`
  - `www/web/.htaccess`
- [x] Correctif livre:
  - ajout du bloc BO `Page reseau / operation` uniquement sur la fiche custom `Abonnement reseau`;
  - sauvegarde des champs LP dans la table dediee globale `ecommerce_reseau_support_lp_settings`;
  - ajout de `/lp/reseau/{slug}` et maintien de `/lp/operation/{slug}` comme compatibilite;
  - LP reseau sans abonnement actif: badge hero `Invitation Cotton`, CTA `Rejoindre Cotton`, aucune promesse d'acces inclus;
  - LP reseau avec abonnement actif: personnalisation lue depuis l'abonnement actif le plus recent, dates affichees seulement si debut + fin sont renseignees.
- [ ] Recette serveur:
  - TdR sans support actif;
  - support actif sans personnalisation;
  - support actif personnalise;
  - plusieurs supports actifs;
  - offre non reseau.
## PATCH 2026-05-11 - Abonnement reseau: cron date_fin
- [x] Audit confirme dans:
  - `www/web/bo/cron_routine_bdd_maj.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - appel de la cloture automatique des supports reseau expires depuis la routine BDD;
  - synchronisation de la `date_fin` support vers les incluses actives lors des sauvegardes BO;
  - conservation des offres propres et hors cadre hors du flux.
- [x] Verification:
  - `php -l www/web/bo/cron_routine_bdd_maj.php`
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
