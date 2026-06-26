# Repo `pro` — Tasks
## PATCH 2026-06-26 - Formats courts Blind Test/Bingo
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - confirmer l'absence de specification existante "format court" dans la documentation publique locale;
  - confirmer que `championnats_sessions.id_format` est deja persiste par le tunnel et peut porter un format contextuel par jeu;
  - identifier `flag_controle_numerique` comme version papier/numerique, a conserver separee du format de session.
- [x] Correctif livre:
  - ajouter dans le setting PRO un choix separe `Format de la session`: Standard / Court pour Blind Test et Bingo Musical uniquement;
  - ajouter le meme choix au quick agenda pour Blind Test/Bingo, masque/desactive pour Cotton Quiz;
  - normaliser cote serveur les formats Blind Test/Bingo sur `2` standard ou `5` court, sans modifier Quiz;
  - afficher le format dans les resumes/listes de sessions;
  - remplacer les libelles publics `Format standard/court` par `40 titres` / `20 titres` dans l'agenda, les cartes et la fiche detail;
  - compacter le setting classique en regroupant visuellement `Format de la session` et `Version du jeu`, sans fusionner les champs POST;
  - reprendre le style chips radio du quick pour le setting unitaire;
  - utiliser le format produit Bingo dans l'agenda/detail quand il differe de `championnats_sessions.id_format`;
  - remplacer le markup actif du setting unitaire Blind Test/Bingo par les vraies chips radio `agenda-quick-choice-*` du quick, au lieu d'un simple compactage CSS des anciennes cartes;
  - forcer le listing agenda a recharger le detail complet des sessions musicales pour que Blind Test lise le `championnats_sessions.id_format` reel;
  - ouvrir le PDF Bingo papier depuis la fiche detail via l'URL Canvas `games` directe;
  - regenerer les ressources Bingo deja creees quand `Modifier` change le format, avec retour setting si la regeneration ne peut pas etre confirmee.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_script.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_view.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check` OK.
- [ ] Verification recette serveur:
  - creer une session Blind Test standard puis courte et verifier le nombre de titres preload;
  - creer une session Bingo courte numerique et verifier playlist client 20 titres + grille joueur 3x3;
  - creer une session Bingo courte papier et verifier generation PDF BDD 3x3;
  - verifier que le setting unitaire creation/modification Blind Test/Bingo affiche les chips `Format de la session` et `Version du jeu`;
  - verifier que le listing agenda affiche `20 titres` pour un Blind Test court;
  - verifier que Cotton Quiz ne recoit pas le selecteur court et conserve ses formats existants.

## PATCH 2026-06-26 - Agenda/widgets: dates deja programmees ouvrables
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, la carte repo `pro`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - identifier que `ec_start_agenda_mode.php` utilise flatpickr via la classe `flatpickerdatetime`;
  - identifier les widgets gamification qui permettent de choisir directement une date d'evenement: `ec_widget_jeux_sessions_cta.php`, `ec_widget_client_lieu_sessions_agenda.php` et la modale agenda de `ec_start_sessions_list.php`;
  - identifier que les dates deja programmees viennent de `ec_start_day_creation_occupied_dates_get(...)`, qui s'appuie sur les sessions officielles configurees et, en gamification, les pivots evenement managés avec sessions;
  - confirmer que le POST `sessions_day_create` bloque deja une date occupee avec `date_error=occupied`;
  - confirmer que la cible pivot existante est `/extranet/start/games/day/YYYY-MM-DD`.
- [x] Correctif livre:
  - ne plus passer les dates deja programmees dans `disable` sur le calendrier `Ajouter une soirée` / `Créer un événement` ni dans les widgets directs de creation d'evenement;
  - exposer ces dates au front comme dates occupees selectionnables;
  - ajouter un etat visuel flatpickr dedie avec fond et point;
  - au choix d'une date occupee, afficher le message `déjà programmé` adapte soirée/evenement et remplacer le CTA par `Ouvrir la soirée` / `Ouvrir l’événement`;
  - intercepter le submit pour rediriger vers le pivot date, sans creation;
  - conserver le POST de creation sur date libre et le garde serveur anti-doublon.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_agenda_mode.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_jeux_sessions_cta.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK.
- [ ] Verification recette serveur:
  - dynamisation: date libre -> `Créer la soirée`, date deja programmee marquee -> message + `Ouvrir la soirée` puis pivot;
  - gamification: date libre -> `Créer l’événement`, date deja programmee marquee -> message + `Ouvrir l’événement` puis pivot;
  - dates passees toujours bloquees par `minDate`;
  - programmation rapide multi-dates, pivot, bibliotheque classique et first_party inchanges.

## PATCH 2026-06-26 - Dynamisation agenda: suppression stepper quick
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, la carte repo `pro`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - identifier que `ec_start_include_header.php` rend le stepper central des pages `start_agenda_mode`, `start_step_2_setting` et `start_step_4_resume_batch`;
  - confirmer que le quick multi-dates arrive via `from=agenda&mode=quick` et que le resume batch lit `$_SESSION['start_agenda_quick_batches']` avant l'inclusion du header;
  - cibler uniquement les comptes dynamisation, en laissant la gamification hors périmètre.
- [x] Correctif livré:
  - masquer `Étape 1/3 — Programmation` sur `/start/agenda/mode/...` pour la dynamisation;
  - masquer `Étape 2/3 — Paramètres` sur `/start/game/setting/...&from=agenda&mode=quick` pour la dynamisation;
  - masquer `Étape 3/3 — C'est prêt !` sur `/start/game/resume-batch/...` pour le quick agenda dynamisation;
  - conserver les titres, les deux blocs agenda, le formulaire quick, l'aperçu et le récapitulatif batch;
  - ne pas modifier les routes ni la création métier.
- [x] Vérification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_include_header.php` OK.
- [ ] Vérification recette serveur:
  - agenda mode dynamisation: titre visible, stepper absent, deux blocs inchangés;
  - quick setting dynamisation: titre `Programmation rapide`, stepper absent, aperçu `Nouvelle soirée` / `Session ajoutée...` inchangé;
  - resume batch dynamisation: titre visible, stepper absent, badges `Ajoutée` et CTA inchangés;
  - first_party, bibliothèque classique, pivot unitaire et gamification non régressés.

## PATCH 2026-06-26 - Pivot date: ajout session unitaire sans resume
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, la carte repo `pro`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - identifier le stepper tunnel central dans `ec_start_include_header.php` et les steppers locaux bibliothèque dans `ec_bibliotheque_list.php` / `ec_bibliotheque_view.php`;
  - identifier que la validation setting applique le contenu bibliothèque via `session_theme` dans `ec_start_script.php`, puis redirige vers `/start/game/resume/`;
  - borner le changement au contexte pivot unitaire: `day_date` valide, `return_url`, hors `mode=quick`.
- [x] Correctif livré:
  - masquer les steppers sur `/start/game/choose/`, `/games/library`, fiche bibliothèque et `/start/game/setting/` uniquement pour l'ajout unitaire depuis pivot date;
  - afficher en haut du setting la mention `Cette session sera ajoutée à la soirée/l'événement programmé(e) le ...`, même pour une première session;
  - propager `day_date`, `day_context`, `return_url` et `event_pending=1` dans le POST setting;
  - après création/application du contenu, rediriger directement vers le `return_url` sûr ou vers `/extranet/start/games/day/YYYY-MM-DD`, avec `session_created=1`;
  - conserver `/start/game/resume/` pour les parcours hors pivot et `/start/game/resume-batch/` pour le quick multi-dates.
- [x] Vérification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_include_header.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_script.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK;
  - `php -l web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK;
  - `php -l web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK.
- [ ] Vérification recette serveur:
  - dynamisation pivot vide et composé: absence de stepper, mention `soirée programmée`, validation puis retour direct pivot;
  - gamification pivot vide et composé: absence de stepper, mention `événement programmé`, validation puis retour direct pivot;
  - quick multi-dates: steppers 1/3, 2/3, 3/3 et `/start/game/resume-batch/` inchangés;
  - bibliothèque classique hors pivot et first_party inchangés.

## PATCH 2026-06-26 - Home gamification: datepicker creation evenement
- [x] Audit:
  - comparer la modale `Créer un événement` de l'agenda et celle du widget Home;
  - identifier que la page Home désactive les scripts étendus dans `ec.php`, donc ne charge pas flatpickr, sa locale FR, son thème ni `ec.js`;
  - confirmer que l'input Home reste en valeur ISO `YYYY-MM-DD` et que le calendrier ne s'ouvre pas faute d'initialisation.
- [x] Correctif livré:
  - rendre la modale événement Home autonome quand elle est présente;
  - charger une seule fois les assets flatpickr nécessaires depuis le widget Home gamification;
  - initialiser le champ date Home avec les mêmes options que le tunnel: `altInput`, `altFormat: j F Y`, `dateFormat: Y-m-d`, locale FR, mobile désactivé;
  - conserver les routes, le POST `sessions_day_create`, les CTA et la modale agenda existante.
- [x] Vérification locale:
  - `php -l web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check` OK.
- [ ] Vérification recette serveur:
  - Home gamification agenda vide: clic `Je programme` ouvre la modale;
  - le champ affiche une date lisible, par exemple `26 juin 2026`;
  - clic dans le champ ouvre le calendrier;
  - soumission conserve `day_date` en `YYYY-MM-DD`;
  - agenda gamification: comportement inchangé.

## PATCH 2026-06-26 - Cartes jeux library/choose: largeur responsive
- [x] Audit:
  - confirmer le périmètre demandé: cartes de jeu de `/games/library` et `/start/game/choose/`;
  - comparer les wrappers, rows, colonnes Bootstrap et styles locaux de `/start/game/choose/` et du mode hub `/games/library`;
  - isoler les cartes principales de jeux sans modifier les cartes produits, CTA, routes ni création de session;
  - vérifier que le CSS de l'accueil bibliothèque doit vivre dans le bloc hub, avant le `return`;
  - identifier que la row bibliothèque ne doit pas être contrainte par un cadre parallèle si l'on veut le même rendu que le step1;
  - identifier la cause du correctif non visible: les règles `.clib-game-choice-*` étaient déclarées dans le seul bloc `network_manage === 1`, absent de `/games/library?clear_session_ctx=1`.
- [x] Correctif livré:
  - ajouter une classe responsive dédiée aux cartes jeu de la bibliothèque;
  - déplacer les règles de grille dans le style commun du hub, avant le branchement `network_manage`;
  - réutiliser côté bibliothèque la logique du step1: row fluide, centrage mobile, alignement standard dès tablette, colonnes plafonnées;
  - conserver les mêmes breakpoints et plafonds que `/start/game/choose/`;
  - aligner le bloc `Les jeux du réseau` sur le footprint des 3 colonnes principales sans réduire les cartes;
  - appliquer le même conteneur de bloc réseau sur `/start/game/choose/`.
- [x] Vérification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_step_1_game.php` OK;
  - `php -l web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check` OK.
- [ ] Vérification recette serveur:
  - `/games/library`: vérifier la largeur des cartes jeu sur mobile, tablette, desktop large et `1400px` à `1699.98px`;
  - `/start/game/choose/`: vérifier les mêmes breakpoints;
  - vérifier que le bloc `Les jeux du réseau` reste aligné avec les cartes jeu sur `/games/library` et `/start/game/choose/`;
  - vérifier que les cartes produits et les CTA existants ne changent pas.

## PATCH 2026-06-26 - Modele date: modification au niveau soiree/evenement
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, la carte repo `pro`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - identifier que la page gestion session exposait encore `session_date` dans `ec_start_step_2_setting.php`;
  - identifier que `session_setting` mettait encore a jour `championnats_sessions.date` pour une session deja creee;
  - identifier que le deplacement complet de pivot etait bloque le jour J par `ec_start_day_group_can_move(...)` avant meme de verifier l'etat runtime.
- [x] Correctif livre:
  - ne plus proposer de modification de date individuelle sur une session existante;
  - conserver la date en lecture seule dans le setting session et afficher `La date se modifie depuis la soirée ou l’événement complet.`;
  - conserver la modification de l'heure et les autres actions de gestion;
  - rendre le POST `session_setting` robuste: une session deja complete conserve sa date originale meme si un ancien POST envoie une autre date;
  - autoriser le deplacement complet d'une soiree/evenement du jour si toutes les sessions sont encore en attente;
  - conserver le blocage si une session est demarree, en cours, terminee ou si la date est passee;
  - adapter les wordings de confirmation/blocage jour J.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_script.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_view.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_include_header.php` OK.
- [ ] Verification recette serveur:
  - page detail/gestion session: date non modifiable, heure modifiable, suppression disponible;
  - ancien POST `session_setting` avec autre date: la date de la session ne change pas;
  - pivot futur: deplacement complet toujours OK;
  - pivot du jour sans session demarree: deplacement complet autorise;
  - pivot du jour avec session demarree/en cours/terminee: deplacement complet bloque avec wording adapte;
  - verifier dynamisation et gamification.

## PATCH 2026-06-26 - Programmation soiree/evenement: ajustements post-recette
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, la carte repo `pro`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - verifier les surfaces `/start/game/setting`, `/start/game/choose`, bibliotheque list/view et `/start/game/resume-batch`;
  - confirmer que le parcours gamification reste exclu du quick et passe par pivot puis library;
  - conserver les routes, la creation de sessions, le quick auto-genere et les pages publiques.
- [x] Correctif livre:
  - adapter le stepper du parcours agenda dynamisation en 3 etapes: `Programmation`, `Paramètres`, `C'est prêt !`;
  - afficher dans l'apercu quick dynamisation si chaque occurrence cree une `Nouvelle soirée` ou ajoute une `Session ajoutée à la soirée existante`;
  - completer les textes `Ajouter une soirée` et `Programmer plusieurs soirées` pour annoncer le choix de thematique apres creation ou l'auto-selection de contenus populaires;
  - afficher dans le setting library un message court seulement si la date cible contient deja des sessions: message court `ta soirée/ton événement` depuis une date liee, et message `soirée programmée` / `événement programmé à cette date` depuis le catalogue sans date liee;
  - hotfix post-recette: rendre ce message dynamique quand la date est choisie/modifiee dans le champ `session_date` du setting library classique;
  - conserver `day_date`, `day_context`, `return_url` et propager `event_pending=1` dans les liens/forms bibliotheque et setting;
  - renommer le choix jeu en `Je programme une session de jeu`, retirer l'astuce basse et rendre les cartes plus souples en responsive;
  - adapter le bandeau bibliotheque pivot en `première session` ou `nouvelle session` selon les sessions deja presentes sur la date;
  - dans le resume batch quick, regrouper par date toutes les sessions officielles de chaque date concernee, pas seulement les sessions creees, et marquer les nouvelles sessions.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_1_game.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php` OK;
  - `php -l web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK;
  - `php -l web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_script.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_include_header.php` OK;
  - correctif stepper/textes: `php -l web/ec/modules/tunnel/start/ec_start_include_header.php` OK;
  - correctif stepper/textes: `php -l web/ec/modules/tunnel/start/ec_start_agenda_mode.php` OK;
  - hotfix: `php -l web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check` OK.
- [ ] Verification recette serveur:
  - dynamisation quick: occurrences sur date vide -> `Nouvelle soirée`, date deja programmee -> `Session ajoutée à la soirée existante`;
  - dynamisation library depuis pivot vide puis pivot avec sessions: bandeau `première` puis `nouvelle`, message setting seulement quand la date contient deja une session;
  - gamification depuis pivot: bandeau `première/nouvelle session pour ton événement`, retour pivot conserve `event_pending=1` si present;
  - `/start/game/choose`: titre singulier, cartes responsive, astuce basse absente;
  - resume batch quick: date avec session preexistante affiche l'ensemble des sessions de la date et badge les nouvelles.

## PATCH 2026-06-26 - Gamification: ne pas bloquer une date avec pivot vide
- [x] Diagnostic:
  - constater que la modale `Créer un événement` des comptes gamification désactive les dates issues de `ec_start_day_creation_occupied_dates_get(..., true, ...)`;
  - identifier que les dates de pivots événements managés `cotton-event-{id_client}-{YYYYMMDD}` étaient ajoutées à `disable`, même sans session officielle visible;
  - expliquer l'écart avec la dynamisation: elle ne tient pas compte des pivots événements managés et ne bloque donc pas ce cas;
  - cas typique: un pivot vide existe déjà en base pour le 28/06, la date semble libre dans l'agenda car aucune carte session n'est affichée, mais flatpickr la grise.
- [x] Correctif livre:
  - considérer une date comme occupée uniquement si elle porte au moins une session officielle configurée;
  - ne plus bloquer un pivot événement gamification vide dans le calendrier de création;
  - conserver le comportement de réutilisation du pivot existant via `app_evenement_pivot_ensure_for_day(..., allow_empty=true)`;
  - conserver le blocage des dates qui ont déjà des sessions officielles.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check` OK.
- [ ] Verification recette serveur:
  - compte gamification avec pivot vide préexistant: date sélectionnable dans `Créer un événement`;
  - validation de cette date -> redirection vers le pivot vide existant;
  - compte gamification avec session officielle sur la date: date toujours désactivée;
  - compte dynamisation: comportement inchangé.

## PATCH 2026-06-26 - Pivot date: etat vide premiere session
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, la carte repo `pro`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - verifier que le rendu de la carte `Ajouter une session` est local a `ec_start_sessions_day.php`;
  - confirmer que les pivots futurs sans session restent accessibles et que le lien d'ajout conserve `day_date`, `day_context` et `return_url`;
  - isoler les modifications des cartes sessions existantes et des routes de creation.
- [x] Correctif livre:
  - afficher la chip `Aucune session` sur un pivot vide actionnable;
  - ajouter le texte de contexte header `Ta soirée est créée...` en dynamisation et `Ton événement est créé...` en gamification;
  - transformer la carte d'ajout en action principale `Ajouter une première session` quand aucune session n'existe;
  - conserver la carte complémentaire `Ajouter une session` avec wording `autre session` quand des sessions existent deja;
  - conserver `day_date`, `day_context`, `return_url` et propager `event_pending=1` dans le retour si present.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK.
- [ ] Verification recette serveur:
  - dynamisation: pivot vide -> chip `Aucune session`, texte `Ta soirée est créée...`, carte `Ajouter une première session`, ajout session puis retour pivot avec carte complémentaire;
  - gamification: pivot vide -> chip `Aucune session`, texte `Ton événement est créé...`, carte `Ajouter une première session`, ajout session puis retour pivot;
  - pivot existant avec sessions: cartes sessions inchangees, chips sessions/horaires correctes, carte complémentaire `Ajouter une session`.

## PATCH 2026-06-26 - Quick dynamisation V2.1: reglages globaux compacts
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, la carte repo `pro`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - confirmer que `/start/game/setting/` exige encore un brouillon session relisible, car les choix de version et la creation quick dependent de `championnats_sessions.id_type_produit`;
  - verifier que le mode quick agenda utilisait deja `session_setting_multi` et l'auto-generation de contenu dans `ec_start_script.php`;
  - verifier que le parcours gamification reste force vers library/pivot et ne doit pas recuperer le quick.
- [x] Correctif livre:
  - conserver la page unique `start/game/setting/{token}?from=agenda&mode=quick`;
  - faire arriver `Programmer plusieurs soirées` sur un brouillon quick par defaut, puis sur le formulaire de programmation rapide;
  - reordonner le quick en deux blocs visibles seulement: `Programmation`, puis `Sessions à créer`;
  - placer dans `Sessions à créer` le choix global `Jeu`, le choix global `Version`, l'`Aperçu`, le compteur de sessions et la confirmation;
  - remplacer les cartes jeu par des boutons/pills segmentes `Blind Test`, `Bingo Musical`, `Cotton Quiz`, sans descriptions marketing;
  - remplacer les grandes cartes version par des boutons/pills `Numérique` et `Classique`, avec etat selectionne discret;
  - changer le jeu du brouillon côté serveur au moment de la validation finale, avant la creation batch et l'auto-generation;
  - appliquer le jeu et la version selectionnes a toutes les sessions creees, sans choix par session ni multi-jeu dans cette passe;
  - conserver les validations existantes sur dates, horaires, limites, dates first_party et offre active;
  - conserver les anciennes URLs quick avec jeu deja present: elles preselectionnent le jeu correspondant.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_agenda_mode.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_include_header.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_script.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check` OK apres correction whitespace.
- [ ] Verification recette serveur:
  - `/start/agenda/mode/` -> `Programmer plusieurs soirées` -> arrivee sur `/start/game/setting/{token}?from=agenda&mode=quick`;
  - quick recurrence -> `Programmation` -> `Sessions à créer` avec boutons jeu/version globaux -> apercu final -> validation;
  - quick dates libres -> `Programmation` -> `Sessions à créer` avec boutons jeu/version globaux -> apercu final -> validation;
  - sessions creees avec contenu auto-genere et agenda groupe par date;
  - parcours simple `Ajouter une soirée` toujours OK;
  - parcours gamification `Créer un événement` toujours OK;
  - ancienne URL quick avec jeu deja present preselectionne ce jeu.

## PATCH 2026-06-25 - Programmation date/pivot d'abord
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - verifier que le pivot `/extranet/start/games/day/YYYY-MM-DD` existe deja mais affichait un avertissement quand aucune session n'etait rattachee;
  - verifier que `Ajouter une session` depuis pivot conserve deja `day_date`, `day_context` et `return_url`;
  - identifier les entrees Home/Agenda qui passaient par `$url_programmateur_onboarding` ou forçaient encore une route de choix du jeu;
  - confirmer que l'ecran `start/agenda/mode` peut etre reutilise comme choix initial date/pivot.
- [x] Correctif livre:
  - orienter les CTAs `Je programme` vers `start/agenda/mode/{offre}`;
  - ouvrir depuis le bouton `Ajouter` de l'agenda une modale légère `Créer un événement` pour les comptes gamification, sans afficher l'écran tunnel `Étape 2/4 - Programmation`;
  - ouvrir la même modale de création événement depuis le widget Home `Je programme` en gamification;
  - adapter le widget Home gamification en `Ajoute ton prochain événement` avec le texte `Programme dès maintenant ton prochain événement ! Choisis une date puis ajoute une ou plusieurs sessions de jeu.`;
  - renommer le CTA bas d'agenda gamification en `PROCHAIN ÉVÉNEMENT` avec le texte `Programme ton prochain événement puis ajoute tes sessions de jeu.`;
  - afficher en gamification un choix de date `Créer un événement`, puis assurer le pivot événement vide et rediriger vers `/extranet/start/games/day/YYYY-MM-DD`;
  - afficher en dynamisation un choix initial `Ajouter une soirée` ou `Programmer plusieurs soirées`;
  - supprimer le titre interne doublon `Programmer mes soirées` de l'écran dynamisation `/start/agenda/mode/`;
  - remettre les visuels sur les deux blocs d'intention dynamisation et harmoniser leurs CTA en bouton plein;
  - conserver le quick multi-dates dynamisation via `Programmer plusieurs soirées`, avec saut direct vers le paramétrage quick après choix du jeu;
  - rendre le pivot futur sans session actionnable avec le message `Ton événement/Ta soirée est créé(e). Ajoute maintenant une première session de jeu.`;
  - desactiver dans le calendrier de creation les dates futures deja occupees par une session officielle ou, en gamification, par un pivot evenement deja cree;
  - renvoyer un avertissement explicite `date_error=occupied` si une date occupee est postee manuellement;
  - ne plus bloquer la validation d'une date libre gamification si l'assurance du pivot vide retourne `no_sessions` ou `create_failed`; le pivot reste accessible avec un etat neutre `event_pending`;
  - permettre au helper événement pivot global de créer/trouver un pivot gamification sans session uniquement quand `allow_empty` est demandé.
- [x] Verification locale:
  - `php -l web/ec/ec.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_include_header.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_1_game.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_jeux_sessions_cta.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_ecommerce_offre_client_bloc.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_script.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_agenda_mode.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_event_helpers.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check` OK.
- [ ] Verification recette serveur:
  - compte gamification: Agenda -> `Ajouter` -> modale `Créer un événement`;
  - compte gamification: Home -> `Je programme` -> modale `Créer un événement`;
  - compte gamification: Home -> wording `Ajoute ton prochain événement`;
  - compte gamification: bas d'agenda -> `PROCHAIN ÉVÉNEMENT` -> modale `Créer un événement`;
  - compte gamification: Home/Agenda -> choix date -> pivot evenement vide;
  - compte gamification: date deja occupee desactivee dans le calendrier et POST manuel averti;
  - compte gamification: pivot vide -> Ajouter une session -> retour pivot;
  - compte gamification: ajout d'une deuxieme session depuis pivot;
  - compte dynamisation: Home/Agenda -> `Ajouter une soirée` -> choix date -> pivot vide -> ajout session;
  - compte dynamisation: date avec session officielle deja existante desactivee dans le calendrier et POST manuel averti;
  - compte dynamisation: `Programmer plusieurs soirées` -> quick multi-dates existant;
  - anciennes URLs `mode=quick` restent compatibles pour dynamisation.

## PATCH 2026-06-24 - Quiz quick numerique: lots `N` avec fallback thematique
- [x] Audit:
  - verifier que le quick agenda Quiz V2 numerique produit deja plusieurs lots thematiques `L`;
  - verifier que `session_theme` passe par `start_quiz_v2_apply_lots_to_session(...)` pour appliquer les `lot_ids`;
  - verifier que le resume batch peut afficher un message par session.
- [x] Correctif livre:
  - brancher le quick multi-series numerique sur `qz_build_numeric_auto_pack_result(...)`;
  - conserver les lots `N` crees avec succes;
  - remplacer uniquement les series `N` echouees par des lots `L` issus de l'ancien quick;
  - ordonner le payload final avec les `N` en premier puis les `L`;
  - ne pas transformer une selection bibliotheque mono-`L` en pack `N`;
  - afficher dans le resume batch un message indiquant les series non creees faute de contenu certifie suffisant.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_script.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php` OK.
- [ ] Verification recette serveur:
  - quick Quiz V2 numerique avec stock `questions_numeriques certified` complet;
  - quick avec stock insuffisant pour une seule famille, verification ordre `N...,L...`;
  - quick avec stock insuffisant pour toutes les familles, verification conservation ancien comportement thematique;
  - selection bibliotheque d'une seule serie `L`, verification absence de generation `N`.

## PATCH 2026-06-24 - Tunnel Quiz V2: tokens `N` acceptes dans `lot_ids`
- [x] Correctif livre:
  - autoriser `N{id}` dans les fallbacks de parsing de `start_quiz_v2_apply_lots_to_session(...)`;
  - conserver la convention chiffre nu -> `L{id}`;
  - autoriser `N` dans la suppression d'un slot Quiz pour ne pas perdre les listes mixtes;
  - ne pas modifier la programmation rapide ni la generation papier automatique.
- [ ] Verification locale:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`;
  - `git -C /home/romain/Cotton/pro diff --check`.
- [ ] Verification recette serveur:
  - session Quiz avec `lot_ids` mixte `L/T/N`;
  - suppression d'un slot sans alteration des autres prefixes;
  - programmation rapide Quiz toujours en comportement historique.

## PATCH 2026-06-23 - Tunnel programmation: wording sessions groupees par date
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - identifier les surfaces du tunnel de programmation EC Pro: `ec_start_step_1_game.php`, `ec_start_include_header.php`, `ec_start_agenda_mode.php`, `ec_start_step_2_setting.php`;
  - verifier que l'objectif porte uniquement sur des textes visibles et pas sur les routes, parametres, tokens, creation de sessions, selection automatique ou calcul d'apercu.
- [x] Correctif:
  - remplacer l'astuce de l'etape 1 par un texte generique centre sur les sessions et le complement de chaque date;
  - adapter le sous-titre de l'etape 2 pour expliquer le regroupement par date dans l'agenda;
  - adapter les blocs `Programmation rapide` et `Choisir une thematique`, avec CTA `Programmer rapidement`;
  - conserver une description conditionnelle en programmation rapide: playlists populaires pour Blind Test/Bingo Musical, 4 series de quiz populaires pour Cotton Quiz;
  - adapter l'aide du mode recurrence et du mode dates libres;
  - conserver le wording d'apercu `1 session sera créée` / `X sessions seront créées`;
  - ne pas modifier les flux `from=agenda`, `mode=quick`, `mode=library`, `tunnel=agenda`, ni les retours agenda/pivot.
- [x] Documentation:
  - `HANDOFF.md` mis a jour;
  - `CHANGELOG.md` mis a jour;
  - `canon/repos/pro/README.md` non modifie: wording visible sans changement de contrat fonctionnel.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php` OK;
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_include_header.php` OK;
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_agenda_mode.php` OK;
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check` OK.
- [ ] Verification recette serveur:
  - step 1 choix du jeu;
  - step 2 choix rapide / thematique pour Blind Test, Bingo Musical et Cotton Quiz;
  - step rapide en mode recurrence;
  - step rapide en mode dates libres;
  - apercu / confirmation;
  - parcours thematique standard;
  - parcours d'ajout a une date deja programmee si disponible.

## PATCH 2026-06-22 - Navigation: masquer Ma communaute en mode evenement
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - identifier le rendu du lien `Ma communauté` dans `pro/web/ec/ec.php`;
  - confirmer la condition existante `$client_is_gamification_usage = ((int) $app_client_detail['id_solution_usage']===2)`;
  - verifier que `Mes événements` utilise deja cette condition pour rester masque en gamification;
  - verifier les routes directes `/extranet/account/establishment/view/general` et `/extranet/players`;
  - verifier que `/extranet/account/establishment/manage` est reutilisee par les modales de fiche depuis les pivots et ne doit pas etre bloquee.
- [x] Correctif:
  - exclure `id_solution_usage=2` de `$show_client_community_menu`;
  - rediriger la vue directe `compte/client/view` des comptes evenement vers `/extranet/start/games`;
  - afficher un flash neutre indiquant que participants, classements et bilans sont disponibles depuis chaque evenement;
  - conserver la page, les stats et classements pour les contextes non gamification;
  - ne pas modifier les pages evenements, pivots, historiques, bilans, statistiques, participants, routes publiques ni autres repos.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check -- web/ec/ec.php` OK.
- [ ] Verification recette serveur:
  - compte evenement/gamification: le lien `Ma communauté` n'apparait plus dans la navigation;
  - compte evenement/gamification: `/extranet/account/establishment/view/general` redirige vers l'agenda avec flash neutre;
  - compte dynamisation/lieu public: le lien reste visible quand les gardes existantes sont satisfaites;
  - verifier que pages evenements, pivots, historiques, bilans et statistiques restent inchanges.

## PATCH 2026-06-22 - Pivot date: aide affichage et pilotage
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - identifier les conseils Avant/Jour J dans `ec_start_sessions_day.php`;
  - confirmer que l'etape Jour J `Avant le lancement` portait la note `Pour piloter la session sur mobile...` via `hint`;
  - confirmer que l'etape Avant `Test et personnalisation` isolait `Depuis le bouton Préparer...` dans `links`;
  - verifier les modales Bootstrap existantes et le schema first_party `Affichage aux joueurs`.
- [x] Correctif:
  - ajouter un lien discret commun `→ Comment afficher et piloter le jeu ?` dans les conseils Avant et Jour J;
  - integrer `depuis le bouton Préparer de chaque session` dans le texte principal de l'etape Avant;
  - remplacer la note Jour J sur le pilotage mobile par le lien commun;
  - ajouter une modale commune `Afficher et piloter le jeu`;
  - rendre une variante desktop/tablette large avec schema `Sessions de jeu -> TV / videoprojecteur -> Joueurs`, connecteurs `HDMI ou cast` et `QR code affiché`, mention pilotage mobile depuis les options et note TV connectee;
  - rendre une variante mobile avec schema `Mobile animateur -> Joueurs`, connecteur `QR code ou lien de jeu`, rappel animation sans ecran externe et note diffusion externe;
  - ne pas modifier les regles metier, CTA principaux, lancement sessions, QR/lien joueur ni logique mobile organizer.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check -- web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - verification statique OK: ancienne note Jour J absente du fichier, lien commun cible la meme modale.
- [ ] Verification recette serveur:
  - pivot Avant: lien discret present en bas de l'etape `Test et personnalisation`;
  - pivot Jour J: lien discret present dans `Avant le lancement`;
  - les deux liens ouvrent la meme modale `Afficher et piloter le jeu`;
  - desktop/tablette large: schema diffusion externe visible et lisible;
  - mobile: schema mobile visible, schema desktop masque;
  - confirmer l'absence de doublon de l'ancienne note Jour J hors modale.

## PATCH 2026-06-22 - First_party: schema modes d'usage Jour J
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - identifier la section `Le jour J, comment ça se passe ?` dans `ec_start_first_party_onboarding.php`;
  - verifier les classes locales `ec-first-party-day-flow__*` et les breakpoints existants (`max-width: 991.98px`).
- [x] Correctif:
  - ajouter une section dediee `Affichage aux joueurs` juste avant `Le jour J, comment ça se passe ?`;
  - y afficher un mini schema HTML/CSS sans image externe ni asset;
  - afficher sur desktop/tablette large le flux `Sessions de jeu -> TV / videoprojecteur -> Joueurs`, avec mention courte du Mobile organisateur depuis les options;
  - reprendre le rendu desktop/tablette large en flux horizontal avec icones plus grandes, connecteurs libelles et note conservee sous le schema;
  - afficher sur mobile le flux `Mobile organisateur -> Joueurs`, avec mention `Animation sans écran externe`;
  - afficher la section avant `Derniers conseils` le Jour J et avant `Le jour J, comment ça se passe ?` hors Jour J;
  - ajuster l'introduction responsive au-dessus du schema: diffusion depuis cette page vers un ou plusieurs ecrans sur desktop/tablette large, animation mobile sans ecran externe puis recommandation ordinateur/tablette paysage sur mobile;
  - ajouter des notes legeres: TV connectee moins fiable en desktop, diffusion externe non adaptee depuis mobile meme en castant l'ecran;
  - aligner le rappel Mobile organisateur dans la note du schema desktop et retirer les deux premieres lignes redondantes des astuces;
  - annuler l'adaptation des textes explicatifs desktop/mobile de l'etape 1 et restaurer son wording historique;
  - utiliser deux variantes HTML masquees/affichees par CSS au breakpoint existant;
  - ne pas modifier les CTA, regles de lancement, logique QR/lien joueur, logique mobile organizer ni conseils materiels hors perimetre.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check` OK;
  - `git -C /home/romain/Cotton/documentation diff --check` OK.
- [ ] Verification recette serveur:
  - first_party avant Jour J: section `Affichage aux joueurs` visible juste avant `Le jour J, comment ça se passe ?`;
  - first_party Jour J: section `Affichage aux joueurs` visible au-dessus de `Derniers conseils`;
  - first_party avant Jour J desktop/tablette large: schema diffusion visible en flux horizontal, compact et lisible;
  - first_party avant Jour J mobile: schema mobile visible, schema diffusion masque;
  - verifier que l'introduction et la note legere affichent le texte adapte au breakpoint;
  - verifier que les astuces ne repetent plus le lancement ordinateur ni le rappel Mobile organisateur;
  - verifier que l'etape `Avant la session` conserve son wording historique;
  - verifier que les CTA et conseils materiels hors perimetre restent inchanges.

## PATCH 2026-06-22 - Gamification: isolation pages evenement par date
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - verifier les scenarios creation standard, ajout depuis pivot existant et modification de date d'une session rattachee;
  - identifier que `session_init` peut transporter un `id_securite_operation_evenement` et que le mode multi-dates duplique temporairement l'`id_operation_evenement` source avant reassignment;
  - confirmer que le bloc et la modale `Page web de l'événement` relisent le pivot via `ec_start_day_event_pivot_context_get(...)` et `app_evenement_pivot_ensure_for_day(...)`.
- [x] Correctif:
  - durcir le helper global de pivot pour ne reutiliser un evenement deja rattache que si client, slug et dates correspondent strictement a la date cible;
  - conserver le cas de deplacement reel d'un groupe evenement: le record pivot peut encore etre deplace avec ses informations quand l'action `sessions_day_move` est utilisee;
  - empecher une creation ou un ajout sur nouvelle date d'heriter des champs publics d'un ancien evenement pivot.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/operations/evenements/app_evenements_functions.php` OK.
- [ ] Verification recette serveur:
  - creer un evenement A, completer sa page, puis creer un evenement B a une autre date et verifier que B reste vierge/par defaut;
  - ajouter une session a une autre date depuis le pivot A et verifier que la nouvelle date a son propre pivot;
  - modifier la date d'une session existante rattachee a A et verifier le detachement/rattachement;
  - deplacer un groupe evenement complet et verifier la conservation attendue des infos;
  - verifier qu'une soiree dynamisation continue d'utiliser la fiche lieu commune.

## PATCH 2026-06-22 - Agenda: modification date soiree/evenement
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - identifier la modification individuelle de date dans `ec_start_script.php` (`session_setting`) et son rattachement pivot gamification via `app_evenement_pivot_session_reassign_after_date_change(...)`;
  - identifier les surfaces groupe: listing agenda `ec_start_sessions_list.php`, pivot date `ec_start_sessions_day.php`, helper `ec_start_sessions_day_helpers.php`;
  - verifier l'impact attendu: Home et `www` reposent sur les dates `championnats_sessions`, donc le deplacement sans changement d'horaires se repercute aux prochains chargements.
- [x] Correctif:
  - ajouter une action `sessions_day_move` sur l'endpoint prive existant `/extranet/start/script`, sans nouvelle route publique;
  - deplacer toutes les sessions officielles futures d'une date vers une nouvelle date, sans modifier les horaires;
  - afficher une icone discrete de modification pres de la date dans l'agenda et le pivot;
  - masquer l'action si une session du groupe est passee, du jour, demarree, terminee ou verrouillee;
  - bloquer la date cible si elle contient deja des sessions officielles, afin d'eviter une fusion silencieuse;
  - apres succes, rediriger vers `/extranet/start/games/day/YYYY-MM-DD`;
  - conserver la modification individuelle et ajouter un avertissement quand une session appartient a un groupe multi-session;
  - conserver le rattachement evenement non pivot; pour les pivots gamification automatiques, deplacer le record `operations_evenements` du groupe complet quand le slug cible est libre, deplacer aussi son dossier de visuels, sinon reutiliser le detachement/rattachement existant vers la nouvelle date.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_script.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK;
  - `php -l /home/romain/Cotton/global/web/app/modules/operations/evenements/app_evenements_functions.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check -- web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php web/ec/modules/tunnel/start/ec_start_script.php web/ec/modules/tunnel/start/ec_start_sessions_day.php web/ec/modules/tunnel/start/ec_start_sessions_list.php web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK.
- [ ] Verification recette serveur:
  - deplacer une soiree future avec une seule session;
  - deplacer une soiree future avec plusieurs sessions;
  - deplacer un evenement gamification futur avec plusieurs sessions;
  - verifier que le visuel personnalise de la page evenement suit le nouveau slug/date;
  - tentative sur date passee / session demarree / session terminee;
  - tentative vers une date contenant deja des sessions;
  - modification individuelle d'une session appartenant a un groupe multi-session;
  - verification redirection vers le nouveau pivot;
  - verification agenda pro, Home et agenda public www apres deplacement.

## PATCH 2026-06-21 - Pivot date performance
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - auditer `ec_start_sessions_day.php` et `ec_start_sessions_day_helpers.php`;
  - identifier les calculs couteux declenches avant affichage effectif des blocs: dashboard bilan, resume page lieu, detail/branding evenement et Media Kit.
- [x] Correctif:
  - ne pas appeler `app_client_joueurs_dashboard_get_context_for_period(...)` sur Jour J tant qu'aucune session n'est terminee;
  - charger le resume `Ton agenda public` uniquement si la section dynamisation est visible;
  - charger le detail/branding evenement uniquement si le bloc page evenement gamification est visible;
  - rendre la modale Media Kit seulement quand les conseils sont affiches;
  - limiter les modales/scripts lieu/evenement aux cas ou un CTA visible peut les ouvrir;
  - conserver les regles de rattachement evenement, routes, CTA, first_party, reseau et offres.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check` OK.
- [ ] Verification recette serveur:
  - pivot date future dynamisation;
  - pivot Jour J dynamisation sans session terminee;
  - pivot date future gamification avec evenement;
  - pivot date passee avec bilan.

## PATCH 2026-06-21 - Pivot Jour J note pilotage mobile desktop
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - identifier `ec_start_sessions_day.php` comme page pivot `/extranet/start/games/day/YYYY-MM-DD`;
  - localiser la note de l'etape Jour J `Avant le lancement` dans `day_guidance_steps`.
- [x] Correctif:
  - marquer la note de pilotage mobile par QR code comme `desktop_only`;
  - ajouter une classe locale au rendu du hint quand ce marqueur est present;
  - masquer cette note sous le breakpoint desktop (`max-width: 991.98px`);
  - ne pas modifier les autres conseils, cartes sessions, routes ou actions.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK.
- [ ] Verification recette serveur:
  - pivot Jour J desktop: note visible dans `Avant le lancement`;
  - pivot Jour J mobile: note masquee;
  - pivot avant Jour J et apres date inchanges.

## PATCH 2026-06-20 - Tunnel programmation aide multi-jeux
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - identifier `ec_start_step_1_game.php` comme étape 1 de choix du jeu;
  - identifier `ec_start_sessions_day.php` comme page pivot date et emplacement de la carte `Ajouter une session`;
  - vérifier que le CTA `Créer mes jeux` est local à cette étape de choix du jeu.
- [x] Correctif:
  - ajouter sous les cartes de choix du jeu une astuce visible seulement en programmation officielle, pas en démo;
  - adapter l'astuce selon le contexte compte: soirée en dynamisation, événement en gamification;
  - remplacer le libellé du CTA des cartes par `Choisir ce jeu` sans changer le formulaire ni l'action;
  - adapter le texte de la carte pivot `Ajouter une session` pour expliquer l'ajout d'un autre jeu ou d'un autre thème à la même date;
  - ne pas modifier les règles de création, rattachement pivot, mode multi-dates, routes ou CTA principaux.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_step_1_game.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `git -C /home/romain/Cotton/pro diff --check` OK.
- [ ] Verification recette serveur:
  - tunnel programmation étape 1 dynamisation;
  - tunnel programmation étape 1 gamification;
  - démo jeu sans astuce de programmation officielle;
  - pivot dynamisation avec carte `Ajouter une session`;
  - pivot gamification avec carte `Ajouter une session`.

## PATCH 2026-06-20 - Home EC pro et pivot agenda public
- [x] Correctif:
  - masquer le widget Home `Ma communauté` pour tous les contextes Home audités, sans supprimer la page ni les accès de navigation existants;
  - garder le widget Home agenda comme entrée principale vers la prochaine date courante/future;
  - si aucune date future/courante n'existe, chercher une dernière date passée utile dans un lot borné de sessions candidates, en réutilisant `app_client_joueurs_dashboard_session_is_history_useful(...)`, puis ouvrir son bilan pivot;
  - ajouter le widget secondaire de programmation uniquement quand le widget pivot/bilan existe déjà;
  - placer ce widget secondaire en première position uniquement quand le widget agenda affiche un bilan historique, en gardant la préparation et le Jour J en première position agenda;
  - transformer le widget secondaire en accès `Mon agenda` quand plusieurs dates futures distinctes existent, avec texte dynamique soirées/événements, mini liste de 3 dates max et CTA vers l'agenda;
  - conserver l'état agenda vide existant sans doublon de programmation;
  - ajouter sur le pivot dynamisation un bloc `Ton agenda public`, avant les conseils en préparation et après les conseils le Jour J;
  - alimenter ce bloc avec un résumé profil lieu normalisé: détail client rechargé, photo/branding, descriptions normalisées, adresse, taux de complétion et URL publique;
  - masquer les blocs page publique après la date et conserver le bloc événement gamification existant;
  - remplacer l'étape dynamisation `Outils de communication` par un lien Media Kit, la modification fiche lieu étant portée par le nouveau bloc.
  - conserver 3 colonnes de cartes sessions sur le pivot date entre `1400px` et `1699.98px`, sans toucher aux variantes Home.
  - appliquer le même confort de largeur aux widgets Home en état standard entre `1400px` et `1699.98px`, y compris la ligne compacte `Nouveautés`, sans modifier les layouts Home spéciaux.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_home_latest_game_news.php` OK;
  - `php -l web/ec/modules/communication/home/ec_home_index.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK.
- [ ] Verification recette serveur:
  - Home dynamisation/gamification sans agenda ni historique;
  - Home dynamisation/gamification sans agenda futur mais avec historique;
  - Home dynamisation/gamification avec prochaine date;
  - pivot dynamisation avant Jour J, Jour J et après date;
  - pivot gamification avant Jour J, Jour J et après date.

## PATCH 2026-06-19 - Pivot événement: organisateur public
- [x] Correctif:
  - ajouter dans la modale événement du pivot le champ optionnel `Organisateur de l'événement`;
  - poster la valeur sous `naming_nom`;
  - renvoyer la valeur sauvegardee dans la reponse JSON pour les rafraichissements front;
  - conserver le nom du compte comme fallback si le champ est vide;
  - ne pas modifier l'agenda dynamisation ni les cartes sessions PRO.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php` OK.
- [ ] Verification recette serveur:
  - sauvegarde modale avec organisateur personnalise;
  - sauvegarde modale avec champ vide.

## PATCH 2026-06-19 - Home gamification: retrait widget Ma communauté
- [x] Correctif:
  - masquer le widget Home `Ma communauté` pour les comptes gamification (`id_solution_usage = 2`);
  - ne pas supprimer les accès pro existants à la page `Ma communauté`;
  - conserver le comportement actuel pour les comptes dynamisation;
  - ne pas modifier les autres widgets Home.
- [x] Verification locale:
  - `php -l web/ec/modules/widget/ec_widget_client_lieu_resume.php` OK.
- [ ] Verification recette serveur:
  - Home compte gamification;
  - Home compte dynamisation.

## PATCH 2026-06-19 - Agenda gamification: nom événement dans le groupe
- [x] Correctif:
  - remonter `id_operation_evenement` dans la requête agenda;
  - afficher le nom de l'événement dans le header de groupe uniquement en contexte gamification;
  - masquer les noms automatiques par défaut pour conserver le rendu actuel quand l'utilisateur n'a pas nommé l'événement;
  - garder la date en première ligne et `X sessions` / plage horaire dans la ligne méta sous la date;
  - conserver le CTA `Préparer l'événement`;
  - ne pas modifier les cartes sessions ni l'agenda dynamisation.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK.
- [ ] Verification recette serveur:
  - agenda gamification avec événement nommé;
  - agenda gamification avec nom par défaut;
  - agenda dynamisation.

## PATCH 2026-06-19 - Upload visuel événement: audit formats
- [x] Audit:
  - identifier les trois entrées d'upload visuel événement: modale pivot, formulaire événement historique, widget résumé;
  - confirmer que ces entrées acceptaient seulement `.jpg,.jpeg`;
  - comparer avec les uploads compte/branding récents, qui acceptent aussi `png` et `webp`;
  - vérifier que le visuel événement attendu reste `1200 × 480 px`;
  - vérifier que la preview de la modale pivot est déjà au ratio `5 / 2`.
- [x] Correctif:
  - accepter `.jpg,.jpeg,.png,.webp` sur les trois entrées événement;
  - aligner le wording d'aide sur `JPG, PNG ou WebP` et `format final 1200 × 480 px`;
  - s'appuyer sur le helper global pour normaliser le fichier public final en `.jpg`;
  - ne pas modifier les uploads fiche lieu / compte.
- [x] Verification locale:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php` OK;
  - `php -l web/ec/modules/operations/evenements/ec_evenements_form.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_operation_evenement_resume_upload.php` OK.
- [ ] Verification recette serveur:
  - upload JPG, PNG et WebP depuis la modale pivot;
  - verifier preview pro, fichier final `place-bandeau-1.jpg` et affichage public.

## PATCH 2026-06-19 - Pivot UX: cohérence sections et page événement incomplète
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - auditer le pivot `/extranet/start/games/day/YYYY-MM-DD` dans `ec_start_sessions_day.php` pour les états dynamisation/gamification avant Jour J, Jour J et après Jour J;
  - identifier que les titres `Page web de l’événement` et `Conseils` avaient un style équivalent mais dupliqué;
  - identifier que la page événement peu renseignée rendait une grande carte d'aperçu alors qu'elle ne portait pas assez d'informations utiles;
  - identifier que l'étape gamification `Outils de communication` devait rester complémentaire du bloc événement et renvoyer vers le Media Kit.
- [x] Correctif:
  - factoriser localement le style des titres/aides de section du pivot sans refondre les cartes sessions;
  - détecter une page événement peu renseignée via le nombre de signaux utiles: visuel personnalisé, titre non généré, description, lieu/adresse, lien utilisateur;
  - afficher dans ce cas la meme structure que l'aperçu complet, avec visuel evenement s'il existe, titre par defaut `Événement du ...`, texte d'incitation, CTA principal `Compléter la page` et CTA secondaire `Voir la page` si l'URL Cotton existe;
  - conserver l'aperçu complet quand la page contient assez d'informations utiles: visuel, titre, accroche courte, description longue si renseignee, lieu/adresse, lien externe, `Voir la page`, `Modifier`;
  - afficher la description longue sous l'accroche courte et la clamper avec ellipsis pour que la colonne desktop ne depasse pas la hauteur du visuel;
  - pre-remplir la modale evenement avec le titre `Événement du ...` quand le nom courant est vide ou encore genere automatiquement en `Événement Cotton du ...`;
  - ajouter un titre visible `Session de jeu` / `Sessions de jeu` au-dessus des cartes sessions avec l'icone `bi-controller` deja utilisee dans le repo;
  - rafraichir le bloc `Page web de l’événement` apres sauvegarde de la modale: visuel avec cache-buster, titre, accroche, description, lieu/adresse, lien externe et CTA `Modifier`;
  - garder le bloc événement uniquement en gamification avant Jour J et Jour J;
  - aligner le wording gamification de l'étape `Outils de communication` sur la page de ton événement et le CTA `Voir le Media Kit`;
  - ne pas modifier les cartes sessions, la programmation, les offres, les routes publiques ni le slug.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - verification raisonnee des états gamification avant/Jour J, page renseignée/peu renseignée, dynamisation avant/Jour J et après Jour J;
  - `git diff --check -- web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `git diff --check` global sur `pro` non OK a cause d'espaces finaux preexistants dans `web/ec/modules/widget/ec_widget_client_lieu_resume.php`, non modifie dans cette passe;
  - `git diff --check` OK sur `documentation`;
  - `npm run docs:sitemap` OK.

## HOTFIX 2026-06-19 - Step 2 programmation ABN: rendu et garde first_party
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - comparer le diff recent de `ec_start_step_2_setting.php`, `ec_first_party_helpers.php` et `ec_start_script.php`;
  - verifier les logs PHP locaux: pas de fatale explicite recente sur `step_2_setting`, mais des requetes `start/game/setting` servies avec un HTML court, coherent avec un shell EC sans formulaire;
  - identifier un premier point fragile: `ec_start_step_2_setting.php` appelait la garde front via `ec_first_party_date_guard_applies_for_current_client(...)`, qui relancait la detection d'offre effective au lieu de reutiliser le contexte deja calcule par `ec.php`;
  - identifier le cas COTTON TEST: le mode agenda quick pouvait rediriger vers `step_2_setting` avec un `id_securite_session` non relisible, car la creation de session n'etait pas verifiee par relecture avant redirection;
  - confirmer via access logs que le token d'offre `pkk8...` passait par `session_init -> agenda/mode -> setting` avec des reponses `setting` courtes, alors que d'autres tokens d'offre affichaient le formulaire complet.
- [x] Correctif:
  - faire reutiliser a `ec_first_party_has_active_offer(...)` les variables globales `offre_effective_has_access` / `app_offre_effective_context` deja calculees pour le client courant;
  - dans `ec_start_step_2_setting.php`, ne jamais appliquer la garde date front si l'acces effectif courant est deja connu actif;
  - conserver le fallback helper pour les comptes sans acces actif, afin que INS/CSO sans offre restent bloques par la garde;
  - dans `ec_start_script.php`, verifier par `app_session_get_id(...)` chaque session creee par `start_agenda_quick_session_init(...)` avant de renvoyer son token;
  - journaliser les echecs de creation/relecture agenda quick avec client, contact, offre, type produit, insert id et erreur mysqli;
  - ne jamais retenter une session officielle avec `id_offre_client=0` quand une offre active existe: le rattachement a l'offre reste imperatif;
  - appliquer la meme verification des le `session_init` qui alimente l'ecran intermediaire `agenda/mode` et les programmations issues de la bibliotheque;
  - vider le token genere quand `session_init` echoue en relecture, afin qu'un appel inclus par la bibliotheque ne redirige pas vers `setting/{token}` avec un brouillon non relisible;
  - dans `step_2_setting`, verifier aussi que le detail session est exploitable, appartient au client courant et porte un type de jeu valide avant de rendre le formulaire;
  - corriger la regex de detection de retour pivot qui utilisait `#` comme delimiteur et dans une classe de caracteres;
  - proteger le header du tunnel contre la lecture de `$app_session_detail` sur les etapes qui ne chargent pas de session;
  - dans `ec_start_step_2_setting.php`, afficher un message de relance au lieu d'un shell vide quand un ancien token `setting` est invalide;
  - ne pas modifier les cartes sessions, le pivot gamification, le bloc page evenement, ni les regles de programmation hors garde first_party.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_first_party_helpers.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_script.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_include_header.php` OK;
  - `git diff --check` OK sur `pro`;
  - `git diff --check` OK sur `documentation`;
  - `npm run docs:sitemap` OK.

## PATCH 2026-06-19 - Pivot gamification: bloc page web événement
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - inspecter `ec_start_sessions_day.php` pour l'URL Cotton `/fr/evenements/{slug}`, la modale evenement et l'ordre des sections;
  - inspecter le bloc historique `ec_evenements_view.php` pour les infos evenement, visuel, CTA `Modifier` et le lien externe utilisateur;
  - identifier que le lien externe utilisateur historique utilisait la valeur brute en `href`, donc `www.example.com` devenait relatif;
  - identifier que le menu `Mes événements` dans `ec.php` se reactive des qu'un evenement existe;
  - identifier que le titre du bloc evenement etait dans l'en-tete de la carte blanche au lieu de suivre le style de titre de section des conseils.
- [x] Correctif:
  - ajouter sous les cartes sessions du pivot gamification un bloc `Page web de l’événement` avant Jour J et Jour J;
  - afficher visuel, titre, lieu/adresse, lien externe utilisateur normalise, extrait de description et actions `Voir la page` / `Modifier`;
  - ne pas afficher statut prive/public ni date dans ce bloc;
  - conserver `Voir la page` sur l'URL Cotton `/fr/evenements/{slug}` et `Modifier` sur la modale existante;
  - normaliser les liens externes utilisateur sans schema en `https://...` dans le pivot et la vue historique;
  - remplacer le CTA conseil gamification de l'etape 2 par `Voir le Media Kit`;
  - masquer l'entree de navigation `Mes événements` pour les comptes gamification sans supprimer les routes historiques;
  - deplacer le titre `🌐 Page web de l’événement` hors de la carte, en style aligne sur `Conseils pour préparer ton événement`;
  - ordonner les informations de la carte: titre, accroche courte, lieu/adresse, lien externe;
  - aligner les CTA `Voir la page` et `Modifier` en bas de la colonne d'informations.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `php -l web/ec/ec.php` OK;
  - `php -l web/ec/modules/operations/evenements/ec_evenements_view.php` OK;
  - `git diff --check` OK sur `pro` et `documentation`;
  - `npm run docs:sitemap` OK.

## PATCH 2026-06-19 - First_party: contexte événement et visuels post-modale
- [x] Audit:
  - identifier que le rendu post-creation rechargeait les sessions futures mais pas les variables derivees de premiere date;
  - constater que le bloc `Page de ton événement` depend de `first_party_event_modal_url`, lui-meme dependant de la premiere date future;
  - constater que les modales evenement et fiche lieu renvoyaient un succes JSON sans URL de visuel exploitable;
  - constater que l'image de la carte participants n'etait pas mise a jour cote client apres fermeture de modale.
- [x] Correctif:
  - recalculer la premiere date future et les compteurs derivees juste apres creation first_party;
  - renvoyer `visual_url` apres sauvegarde de la page evenement et de la fiche lieu;
  - cibler l'image du bloc participants avec `data-first-party-links-visual`;
  - mettre a jour immediatement cette image apres succes AJAX, avec cache-buster;
  - couvrir gamification `Page de ton événement` et dynamisation `Agenda public`.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php` OK;
  - `php -l web/ec/modules/compte/client/ec_client_script.php` OK;
  - `git diff --check` OK sur `pro`.

## PATCH 2026-06-19 - Pivot gamification: accès header page événement
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - identifier que l'URL publique evenement est construite dans `ec_start_sessions_day.php` depuis `app_evenement_pivot_ensure_for_day(...)` ou le fallback `app_evenement_get_detail(...)`;
  - identifier que l'ancien lien Jour J `Voir la page web de l’événement` etait injecte dans le sous-titre du header;
  - identifier que le CTA `Personnaliser la page de l’événement` utilise la modale existante `/extranet/start/games/day/event/modal/YYYY-MM-DD`;
  - constater que le helper de modale refusait le Jour J et n'acceptait que `upcoming`.
- [x] Correctif:
  - ajouter dans le header gamification `Page web de l’événement : Voir la page · Modifier` avant Jour J et Jour J;
  - construire chaque lien seulement si son URL est disponible pour eviter les liens casses;
  - ouvrir `Voir la page` vers `/fr/evenements/{slug}` dans un nouvel onglet;
  - reutiliser la modale existante pour `Modifier`, sans nouvelle route;
  - autoriser la modale evenement existante sur `today` en plus de `upcoming`;
  - ne pas changer les cartes sessions, les CTA principaux, la dynamisation, la programmation ou le slug.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_event_helpers.php` OK;
  - `git diff --check` OK sur `pro` et `documentation`;
  - `npm run docs:sitemap` OK.

## PATCH 2026-06-19 - First_party: garde date limitée aux comptes sans offre active
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - identifier que la garde bloquante de creation hors pivot passe par `ec_first_party_programming_blocked_for_current_client()`;
  - identifier que la borne date `<= premiere date officielle future` est appliquee par `ec_first_party_date_blocked_by_first_future_official()` dans `ec_start_script.php`;
  - identifier que le datepicker front applique aussi une `minDate` via `ec_start_step_2_setting.php`;
  - confirmer que `ec_first_party_has_active_offer()` utilise le contexte d'offre effective comme source d'acces actif.
- [x] Correctif:
  - faire retourner `false` a `ec_first_party_requires_offer_activation_before_next_programming()` des qu'une offre effective active existe;
  - centraliser l'application de la garde date dans `ec_first_party_date_guard_applies_for_current_client()`;
  - utiliser ce helper dans `ec_first_party_date_blocked_by_first_future_official()`;
  - utiliser ce helper pour le garde front du choix de date;
  - conserver le blocage des comptes `INS` / `CSO` sans offre active et sans toucher au pivot, aux widgets ou aux regles d'offre/paiement.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_first_party_helpers.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK;
  - `git diff --check` OK sur `pro` et `documentation`;
  - `npm run docs:sitemap` OK.

## PATCH 2026-06-18 - Pivot date: déplacement/suppression sessions liées
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - confirmer que le CTA `Modifier` de la fiche session pointe vers `ec_start_step_2_setting.php`;
  - identifier que les sessions liées à un événement appliquent `operations_evenements.date_debut/date_fin` comme bornes de date;
  - confirmer que les événements pivot gamification sont créés mono-date, ce qui grisait toutes les autres dates;
  - inspecter le flux `session_delete` et le `return_url` vers `/extranet/start/games/day/YYYY-MM-DD`.
- [x] Correctif:
  - ignorer les bornes événement dans `ec_start_step_2_setting.php` uniquement pour les événements pivot automatiques managés;
  - stabiliser la détection côté formulaire pour les slugs pivot suffixés et supprimer une borne `maxDate` mono-date héritée quand elle correspond au jour du pivot;
  - conserver les bornes pour les vrais événements/opérations historiques;
  - après sauvegarde de date, appeler le helper global de réaffectation pour détacher/rattacher la session au pivot de sa nouvelle date;
  - couvrir aussi le mode multi-dates issu du paramétrage;
  - après suppression d'une session depuis sa fiche détail, détecter un `return_url` de page pivot et compter les sessions officielles restantes de cette date;
  - si la date pivot n'a plus aucune session, rediriger vers `/extranet/start/games` au lieu de la page pivot vide.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_script.php` OK;
  - `php -l ../global/web/app/modules/operations/evenements/app_evenements_functions.php` OK;
  - `git diff --check` OK sur `pro` et `global`.

## PATCH 2026-06-18 - Pivot date: communication avant Jour J
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - inspecter `pro/web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
  - confirmer que les recommandations avant Jour J ajoutaient une etape page lieu/evenement puis une etape communication separee;
  - identifier les liens existants vers page place `www`, page evenement `www`, modale Media Kit, modale fiche lieu et modale evenement.
- [x] Correctif:
  - supprimer l'ajout de l'etape separee page lieu/evenement avant Jour J;
  - conserver l'etape 1 `Test et personnalisation`;
  - transformer l'etape 2 `Outils de communication` pour porter la page publique, le Media Kit et le CTA de personnalisation;
  - en dynamisation, lier `la page de ton lieu` vers `/fr/place/{seo_slug}` et `Personnaliser la page de mon lieu` vers la modale fiche lieu;
  - en gamification, lier `la page de ton événement` vers `/fr/evenements/{seo_slug}` et `Personnaliser la page de l’événement` vers la modale evenement;
  - sur le Jour J gamification, alimenter `Voir la page web de l’événement` en assurant/rattachant aussi le pivot sur `today`, avec fallback depuis l'événement déjà attaché aux sessions, et reprendre le style du lien de retour header;
  - conserver la modale Media Kit existante via le lien `Media Kit`.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `git diff --check -- web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK.

## PATCH 2026-06-18 - Pivot gamification: modale page evenement
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - inspecter le pivot `/extranet/start/games/day/YYYY-MM-DD`, ses helpers, les helpers evenement/branding, le formulaire/script historique evenement, le formulaire modale fiche et les routes;
  - confirmer que le formulaire historique evenement reste trop large pour le pivot: pleine page, dates, publication, suppression et propagation via `app_evenement_modifier()`;
  - confirmer que le visuel evenement historique est stocke sous `operations/evenements_branding/{seo_slug}` via `app_evenement_branding_visuel_uploader(...)`.
- [x] Correctif:
  - remplacer l'etape 2 gamification future par `Page de ton événement` uniquement quand l'evenement pivot est disponible avec statut `created`, `found` ou `attached`;
  - ajouter une route fragment de chargement modale et une route JSON de sauvegarde dediees au pivot;
  - creer une modale legere avec visuel JPG/JPEG, nom, accroche courte, description, lieu, adresse, lien externe et libelle;
  - afficher la date en lecture seule et ne pas exposer public/prive, `online`, dates, horaires, SEO slug, code evenement, suppression, equipe, rubrique ou programmation;
  - ajouter `app_evenement_pivot_update_infos(...)`, qui ne met a jour que les champs V1 autorises et n'appelle pas `app_evenement_modifier()`;
  - reutiliser l'uploader branding historique pour le visuel, sans propager le visuel aux sessions.
- [x] Verification:
  - `php -l ../global/web/app/modules/operations/evenements/app_evenements_functions.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_event_helpers.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_event_script.php` OK;
  - `git diff --check` OK sur `pro`, `global`, `documentation`.

## PATCH 2026-06-18 - Pivot gamification: assurance evenement par date
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - confirmer que `/extranet/start/games/day/YYYY-MM-DD` charge l'agregat des sessions officielles d'une date client;
  - confirmer que `id_solution_usage=2` est le signal gamification deja utilise par le pivot;
  - confirmer que `operations_evenements.seo_slug` sert au branding historique et doit rester stable pour la future fiche/modale;
  - confirmer que `app_evenement_modifier()` propage `flag_session_privee` et ne doit pas etre utilise pour rattacher les sessions.
- [x] Correctif:
  - ajouter `id_operation_evenement` au chargement des sessions de la page pivot sans changer les criteres metier existants;
  - ajouter un helper global `app_evenement_pivot_ensure_for_day(...)` pour retrouver/creer l'evenement pivot et rattacher strictement les sessions eligibles;
  - utiliser le slug deterministe `cotton-event-{id_client}-{YYYYMMDD}`;
  - limiter l'appel runtime au pivot standard gamification en mode futur (`upcoming`), hors reseau, hors `first_party`, hors dynamisation;
  - creer l'evenement prive/non publie via les conventions historiques, sans notification, modale, upload visuel ni changement UI;
  - rattacher uniquement les sessions du client courant, de la date pivot, non demo, completes, parmi les IDs deja retenus par le pivot, et encore sans evenement.
- [x] Verification:
  - `php -l ../global/web/app/modules/operations/evenements/app_evenements_functions.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK.

## PATCH 2026-06-18 - EC Agenda courant borne par dates
- [x] Audit:
  - confirmer la route agenda standard `/extranet/start/games` et la route reseau `extranet/start/games?network_agenda=1`;
  - consulter `START.md`, `SITEMAP.txt`, la carte repo `pro`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - confirmer que le rendu reseau reutilise `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php` avec la branche `network_agenda_mode`;
  - identifier la requete principale reseau: `championnats_sessions cs, clients c` avec `c.id_client_reseau = id_client_TdR`;
  - constater que l'agenda standard chargeait toutes les sessions futures du compte avant regroupement par date;
  - constater que la page chargeait toutes les sessions futures des affilies avant regroupement par date;
  - constater que le lien archives reseau etait calcule en rechargeant toutes les sessions passees des affilies puis en filtrant en PHP.
- [x] Correctif:
  - limiter l'agenda standard courant a 10 groupes de dates au premier affichage, puis +10 par `Voir plus` via `days_limit`;
  - limiter l'agenda reseau courant a 10 groupes de dates au premier affichage, puis +10 par `Voir plus` via `network_days_limit`;
  - recuperer d'abord `limit + 1` dates distinctes en SQL, puis charger uniquement les sessions des dates affichees;
  - conserver les sessions d'une meme date ensemble, sans couper un groupe de date au milieu;
  - conserver les filtres date/type de jeu existants en SQL;
  - remplacer le scan complet des archives reseau par des tests `LIMIT 1` cibles, equivalents au helper d'archives utiles de l'agenda standard;
  - ne pas modifier la Home, les routes, droits, CTA ou libelles.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK;
  - `git diff --check` OK.

## PATCH 2026-06-18 - EC historiques sessions/offres bornes
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, la carte repo `pro`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - confirmer la route archives sessions: `/extranet/start/games/archives` via `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
  - confirmer la route offres: `/extranet/account/offers` via `pro/web/ec/modules/compte/offres/ec_offres_view.php` et `ec_offres_include_list.php`;
  - identifier que les archives sessions chargeaient toutes les sessions passees candidates avant filtrage archive utile, regroupement et rendu;
  - identifier que chaque session archivee affichee peut encore appeler des details jeu/session et `app_session_results_get_context(...)`;
  - identifier que l'historique offres non-reseau chargeait toutes les offres terminees avant rendu;
  - identifier que l'historique offres reseau avait une pagination visible mais construisait les lignes detaillees avant decoupe.
- [x] Correctif:
  - limiter les archives agenda a 20 entrees utiles au premier affichage, puis +20 par clic `Voir plus`;
  - charger les archives agenda par requetes SQL bornees et detecter `limit + 1` sans charger tout l'historique en memoire;
  - pousser les filtres date/type de jeu dans le SQL quand ils sont presents;
  - limiter l'historique offres a 10 entrees au premier affichage, puis +10 par clic `Voir plus`;
  - appliquer `LIMIT limit + 1` aux historiques offres standards et des batches SQL bornes pour l'historique reseau;
  - conserver les offres actives, abonnements actifs, CTA et regles d'acces existants;
  - remplacer l'ancienne pagination `Precedent/Suivant` reseau par le lien progressif `Voir plus`.
- [x] Correctif post-recette:
  - retirer le plafond UX `200` de la generation des liens `Voir plus`;
  - garder une borne haute uniquement pour normaliser un acces direct abusif (`limit=10000`), sans bloquer la progression normale 140 -> 160 -> 180 -> 200 -> 220;
  - appliquer le meme ajustement a `history_limit` sur `/extranet/account/offers`.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK;
  - `php -l web/ec/modules/compte/offres/ec_offres_view.php` OK.

## PATCH 2026-06-18 - Ma communaute: wording fiche contextualise
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, la carte repo `pro`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - confirmer les routes EC visees: `/extranet/account/establishment/view/general` et `/extranet/account/establishment/manage`;
  - retrouver la logique signup de libelle du nom dans `pro/web/ec/ec_signup.php`: lieu pour typologies `1/8`, societe pour `2/3`, `Nom` sinon;
  - confirmer qu'aucun libelle signup specifique `organisation` n'existe pour le nom de compte;
  - confirmer que `id_solution_usage=2` est le signal gamification deja utilise dans l'EC.
- [x] Correctif:
  - ajouter `ec_client_profile_wording.php` pour centraliser les copies de fiche compte selon contexte;
  - conserver les wordings `lieu` en dynamisation;
  - en gamification, adapter les libelles fiche/description/lien selon entreprise, organisation/generique ou particulier, sans presenter la fiche comme un evenement precis;
  - remplacer le lien prive par `Voir ma page privée sur le site` sans modifier l'URL ni les regles d'acces.
  - adapter les visuels par defaut du widget Home `Ma communaute`, de la vue fiche et du formulaire: `branding-client-default-gm.jpg` pour la gamification generique/organisation/entreprise, `branding-client-default-pt.jpg` pour les particuliers et `branding-client-default.jpg` pour la dynamisation;
  - forcer ces assets locaux quand l'ancien fallback `app_client_get_photo_src()` pointe vers une URL prod `branding-client-default`;
  - afficher le bandeau `Exemple d'illustration.` sur le widget Home quand il affiche un visuel fallback;
  - conserver les visuels custom existants sans bandeau et ne pas ajouter de requete au widget Home.
- [x] Verification:
  - `php -l web/ec/modules/compte/client/ec_client_profile_wording.php` OK;
  - `php -l web/ec/modules/compte/client/ec_client_form.php` OK;
  - `php -l web/ec/modules/compte/client/ec_client_view.php` OK.
  - `php -l web/ec/modules/widget/ec_widget_client_lieu_resume.php` OK.

## PATCH 2026-06-18 - First party: wording fiche privee
- [x] Correctif:
  - distinguer les pages lieu publiques des pages privees dans `ec_start_first_party_onboarding.php`;
  - utiliser `fiche` et `ta page privee du site` pour les comptes non publies/gamification;
  - conserver l'astuce visible pour les pages privees en contexte evenement/gamification;
  - conserver le wording public existant pour les lieux publies;
  - aligner la mise a jour JS apres sauvegarde de la fiche dans la modale.
- [x] Pivot date:
  - ouvrir l'etape 2 avant Jour J de `/extranet/start/games/day/YYYY-MM-DD` aux contextes lieu public et evenement/gamification;
  - afficher `Page privee sur le site`, `ta page privee`, `participants` et `Modifier ma fiche` quand la page lieu n'est pas publiee;
  - conserver `Page publique sur le site`, `la page de ton lieu`, `joueurs` et `Modifier ma fiche lieu` pour les lieux reellement publies;
  - pour l'etape 3, reutiliser le wording prive existant de la gamification quand un compte dynamisation n'est pas reellement publie.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK.
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK.
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK.

## PATCH 2026-06-18 - Ma communaute: fiche lieu et wording page privee
- [x] Audit:
  - identifier le widget Home `modules/widget/ec_widget_client_lieu_resume.php` comme CTA `Ma communaute`;
  - confirmer que le bloc 1 fiche lieu de `modules/compte/client/ec_client_view.php` modifie les informations affichees sur la page lieu;
  - confirmer que la page `www` liste les lieux publics avec `clients.online=1`, tandis que l'URL directe `/fr/place/{slug}` peut rester accessible techniquement;
  - distinguer l'acces menu/stats joueurs de l'affichage fiche lieu.
- [x] Correctif:
  - supprimer la restriction specifique gamification qui imposait une archive utile pour afficher le signal fiche lieu;
  - centraliser `show_client_place_profile_card` pour que le widget Home et le bloc 1 fiche lieu utilisent la meme eligibilite;
  - centraliser `client_has_published_public_place_page` pour distinguer wording public et wording page privee;
  - afficher `Personnalise ta page privee...` dans le widget quand la page lieu n'est pas publiee sur `www`;
  - afficher `Voir ma page privee sur le site` dans le bloc fiche lieu quand la page lieu n'est pas publiee sur `www`.
- [x] Verification:
  - `php -l web/ec/ec.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_client_lieu_resume.php` OK;
  - `php -l web/ec/modules/compte/client/ec_client_view.php` OK.

## PATCH 2026-06-18 - Home: differé de rendu mesure puis optimisation
- [x] Diagnostic:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - annuler le skeleton plein ecran ajoute dans `web/ec/ec.php` car il ne corrigeait que l'ancien document pendant la navigation sortante;
  - confirmer que `/extranet/dashboard` reste une navigation pleine page sans PJAX/AJAX global;
  - confirmer que `ec_home_index.php` rend les widgets Home cote serveur et non par injection JS principale;
  - identifier que le delai percu peut venir du pipeline global `ec.php`, de la nav/includes avant module, de l'include Home, du transfert ou du rendu navigateur;
  - ecart de direction: ne pas ajouter de nouveau skeleton/shell pour masquer le symptome avant mesure.
- [x] Correctif:
  - rollback complet du skeleton de navigation dans `web/ec/ec.php`;
  - restaurer `web/ec/modules/communication/home/ec_home_index.php` sans shell/skeleton Home ajoute;
  - mesurer temporairement le pipeline serveur et navigateur pendant l'audit;
  - retirer l'instrumentation temporaire apres validation des mesures;
  - identifier que la reponse HTML Home arrive rapidement mais que le premier paint et `domInteractive` sont retardes par la pile JS/CSS footer;
  - appliquer `defer` aux scripts footer uniquement sur la Home `/extranet/dashboard`, en conservant leur ordre;
  - ne plus charger sur la Home les CSS/JS vendors etendus inutiles au premier rendu: jQuery UI, Swiper, Flatpickr et Sortable;
  - identifier ensuite que `loadEventEnd` reste tire par les images de cartes Home non critiques;
  - de-prioriser les visuels `Nouveautés`, `Les jeux Cotton`, `Ma communaute` et agenda Home via `loading="lazy"`, `decoding="async"` et `fetchpriority="low"`;
  - preconnecter et charger explicitement Google Fonts/Poppins dans le `<head>` pour eviter la decouverte tardive via le `@import` de `includes_main.css`;
  - ne pas ajouter de timer, cache, PJAX, SQL, loader global ou changement de widget.
- [x] Verification:
  - `php -l web/ec/ec.php` OK;
  - `php -l web/ec/modules/communication/home/ec_home_index.php` OK;
  - `git diff --check -- web/ec/ec.php web/ec/modules/communication/home/ec_home_index.php` OK.

## PATCH 2026-06-18 - Stabilisation regression globale apres signal Home
- [x] Diagnostic:
  - comparer les deux fichiers du dernier patch: `global/web/app/modules/entites/clients/app_clients_functions.php` et `pro/web/ec/modules/general/feedback/ec_feedback_lib.php`;
  - confirmer que `app_client_has_visible_official_session_signal(...)` est appele deux fois dans `web/ec/ec.php`, donc en entree globale de l'extranet EC;
  - confirmer que le feedback recent est appele explicitement par la Home via `ec_home_index.php` et reste local aux surfaces qui incluent la librairie feedback;
  - identifier le changement global comme suspect prioritaire: requete archive multi-`EXISTS` sans index/`EXPLAIN` confirme, declenchee avant les modules.
- [x] Stabilisation:
  - rollbacker `app_client_has_visible_official_session_signal(...)` cote `global` a son implementation precedente;
  - conserver le changement `ec_feedback_recent_finished_session_get(...)` car il est borne a 14 jours / `LIMIT 10` avant les controles existants;
  - ne pas ajouter d'index, cache persistant, nouvelle regle Home, wording ou CTA.
- [x] Verification:
  - `php -l ../global/web/app/modules/entites/clients/app_clients_functions.php` OK;
  - `php -l web/ec/modules/general/feedback/ec_feedback_lib.php` OK.

## PATCH 2026-06-18 - Home sans prochaine date: fallback programmation borne
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - confirmer que `ec_home_next_sessions_day_summary_get()` sort deja vite quand aucune prochaine date officielle n'existe;
  - suivre le point d'entree `web/ec/ec.php` avant `ec_home_index.php` et identifier les signaux globaux encore calcules pour la Home;
  - identifier que `app_client_has_visible_official_session_signal(...)`, cote `global`, pouvait encore scanner l'historique complet;
  - identifier que `ec_feedback_recent_finished_session_get(...)` chargeait les archives larges via `app_client_joueurs_dashboard_archive_sessions_get(...)` avant de filtrer sur 14 jours.
- [x] Correctif:
  - conserver l'orchestration Home et les branches `first_party`, `INS`, `CSO`, `ABN`, `PAK`, TdR/reseau, dynamisation/gamification;
  - borner le feedback Home recent a une requete directe sur les sessions officielles completes des 14 derniers jours avec `LIMIT 10`;
  - conserver les controles existants d'archive utile et d'existence feedback sur ces seules candidates;
  - annuler ensuite le correctif global du signal officiel visible, trop risque pour l'entree EC globale sans mesure DB.
- [x] Verification:
  - `php -l web/ec/modules/general/feedback/ec_feedback_lib.php` OK;
  - `EXPLAIN` non execute faute de connexion DB CLI disponible dans la sandbox.

## PATCH 2026-06-18 - Home agenda sessions bornees
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - confirmer le point d'entree Home `web/ec/modules/communication/home/ec_home_index.php`;
  - lister le chemin widget: Home -> `web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` -> helpers `web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
  - identifier que le chemin Home standard parcourait jusqu'a 30 dates candidates puis chargeait des listes par date;
  - identifier les appels lourds restants: `app_sessions_filter_by_archive_state()` sur futures, `app_session_edit_state_get()` hors strict Jour J utile, `app_session_get_detail()` alors que les champs Home etaient deja selectionnes;
  - confirmer que les fallbacks `first_party` / programmation restent a evaluer seulement sans session utile;
  - isoler le widget `Agenda du reseau` siege comme chemin distinct conserve.
- [x] Correctif:
  - ajouter `ec_home_next_sessions_day_summary_get()` dans `ec_start_sessions_day_helpers.php`;
  - chercher la prochaine date utile par une requete directe `date >= CURDATE()` / client courant / officielle / complete / `LIMIT 1`;
  - charger uniquement les sessions de cette date avec les champs necessaires au widget Home;
  - supprimer du chemin Home standard la boucle sur dates candidates et le filtrage archives des futures;
  - limiter le calcul runtime aux sessions de la date affichee quand cette date est aujourd'hui;
  - conserver les details jeu uniquement pour les sessions de cette date, via cache request-scope;
  - conserver les fallbacks et les branches Home `INS` / `CSO` / `ABN` / `PAK` / TdR / reseau / dynamisation / gamification;
  - aligner les CTA Home du widget sur `Préparer`, `Ouvrir`, `Reprendre`, `Voir le bilan`.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK;
  - `EXPLAIN` non execute faute de connexion DB CLI disponible dans la sandbox;
  - index a valider avant migration: `championnats_sessions(id_client, date, flag_session_demo, flag_configuration_complete, heure_debut, id)`.

## PATCH 2026-06-17 - Home render initial stable
> Statut 2026-06-18: obsolete / annule. Le shell/squelette Home introduit par ce bloc a ete retire par la passe du 18/06; l'etat final restaure une Home sans shell/skeleton ajoute et traite le differe de rendu par mesure puis optimisation des ressources bloquantes.

- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - identifier que `ec_home_index.php` calcule plusieurs etats serveur avant le premier bloc Home visible;
  - confirmer que les widgets finaux sont rendus dans le HTML serveur et non injectes par un fetch JS principal;
  - rechercher les masques globaux Home (`home-ready`, opacity, display none, loading) sans trouver de cause directe du blanc initial;
  - identifier le JS local de synchronisation de largeurs comme source possible de recomposition mineure, pas comme cause du blanc;
  - conserver l'agenda comme contributeur possible au temps serveur sans modifier sa logique dans ce patch.
- [x] Correctif:
  - emettre un shell Home avant les calculs lourds de widgets;
  - reprendre l'en-tete `Bonjour ...` dans ce shell;
  - ajouter un squelette visuel reserve en hauteur sans texte metier ni CTA;
  - masquer le squelette et eviter le doublon d'en-tete quand les vrais widgets commencent;
  - conserver les wordings, CTA et regles `first_party` / `INS` / `CSO` / `ABN` / `PAK` / TdR / agenda.
- [x] Verification:
  - `php -l web/ec/modules/communication/home/ec_home_index.php` OK;
  - `git diff --check -- web/ec/modules/communication/home/ec_home_index.php` OK.

## PATCH 2026-06-17 - Home/Agenda sessions groupees: deuxieme passe performance
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - tenter une mesure DB locale/dev depuis CLI, bloquee par `Access denied` sur l'utilisateur dev;
  - profiler par comptage des chemins de requetes appeles par les widgets Home/Agenda;
  - identifier que la Home appelait les helpers first_party avant de savoir si le widget affichait une prochaine date ou un CTA `Je programme`;
  - identifier que le listing Agenda courant rechargeait toutes les archives passees et appelait les helpers d'historique par session uniquement pour savoir si le lien archives devait etre affiche;
  - identifier que les resumes de sessions futures continuaient de charger des details complets et des etats runtime alors que la date suffit pour le mode `before`;
  - identifier que `app_jeu_get_detail()` etait appele plusieurs fois pour les memes couples jeu/produit/lot_ids dans un meme rendu.
- [x] Correctif:
  - differer les helpers first_party du widget Home agenda aux seuls cas sans session affichee;
  - enrichir les SELECT Home/Agenda/Pivot avec `lot_ids` et `nb_joueurs_max` pour eviter un detail session complet dans les resumes;
  - ajouter un cache request-scope `ec_start_day_game_detail_get()`;
  - faire eviter a `ec_start_agenda_session_summary_get()` l'etat runtime pour les dates futures;
  - court-circuiter `ec_start_agenda_session_can_delete()` pour les sessions futures du client deja presentes en liste;
  - remplacer, sur l'Agenda courant hors reseau, le scan complet des archives utiles par des tests SQL `EXISTS`/`LIMIT 1` cibles;
  - conserver le fallback historique pour l'agenda reseau.
- [x] Verification:
  - `php -l web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `git diff --check -- web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php web/ec/modules/tunnel/start/ec_start_sessions_list.php web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK.

## PATCH 2026-06-17 - Home/Agenda sessions groupees: optimisation performance
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - identifier le widget Home `web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`;
  - identifier le listing Agenda `web/ec/modules/tunnel/start/ec_start_sessions_list.php`;
  - identifier la page pivot date `web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
  - identifier le helper partage `web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php`;
  - constater que la Home chargeait toutes les sessions futures officielles puis ne rendait que la prochaine date;
  - constater que le listing Agenda appelait `app_session_participations_probables_get_count()` dans la boucle des lignes compactes via `ec_start_agenda_session_summary_get()`;
  - constater que plusieurs blocs d'un meme rendu redemandaient `app_session_get_detail()` pour les memes IDs de session.
- [x] Correctif:
  - limiter la Home a quelques dates futures/courantes candidates puis charger seulement les sessions de la premiere date encore utile;
  - ajouter un cache local requete-scope `ec_start_day_session_detail_get()` pour mutualiser les details session pendant un rendu;
  - utiliser ce cache dans le helper de resume Agenda, le bilan pivot, la page pivot, le widget Home et les cartes pivot;
  - ajouter `ec_start_agenda_participations_probables_counts_get()` pour compter les participations probables de plusieurs sessions en une requete `GROUP BY`;
  - precharger ces compteurs dans le listing Agenda et les passer au helper de resume;
  - conserver les wordings, CTA et regles UX existantes.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK;
  - `git diff --check -- web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php web/ec/modules/tunnel/start/ec_start_sessions_day.php web/ec/modules/tunnel/start/ec_start_sessions_list.php web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK.

## PATCH 2026-06-17 - Agenda programmation: wordings soirees/evenements
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md` et le journal AI Studio raw avant patch;
  - identifier le widget partage `web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`;
  - lister ses appels actifs: agenda general `ec_start_sessions_list.php`, confirmations `ec_start_step_4_resume.php` / `ec_start_step_4_resume_batch.php`, Home `ec_home_index.php`, fiche client `ec_client_view.php`, fiche operation evenement `ec_evenements_view.php`, offre ecommerce `ec_offres_form_step_3.php`;
  - identifier les widgets agenda vide Home: `ec_widget_client_lieu_sessions_agenda.php` pour dynamisation/lieu et `ec_widget_operation_evenement_agenda.php` pour gamification/evenements;
  - confirmer que la page pivot date n'utilise pas le widget partage pour l'ajout, mais une carte locale dans `ec_start_sessions_day.php`;
  - confirmer que l'ajout depuis pivot conserve `day_date`, `day_context` et `return_url` vers `/extranet/start/games/day/YYYY-MM-DD`;
  - verifier que la bibliotheque et le tunnel propagent deja `day_date` / `day_context` jusqu'au parametrage de session;
  - exclure du patch la section recommandations de la page pivot, conservee dans son etat preexistant.
- [x] Correctif:
  - remplacer le wording generique du widget partage hors pivot par `TES PROCHAINES SOIRÉES` ou `TES PROCHAINS ÉVÉNEMENTS` selon `id_solution_usage`;
  - indiquer dans ce widget que l'utilisateur programme une ou plusieurs sessions aux dates de son choix et qu'elles seront regroupees par soiree/evenement dans l'agenda;
  - conserver le CTA general `Je programme`;
  - aligner le header du listing agenda sur la largeur des groupes de soiree/evenement sur desktop large;
  - placer le lien QR code permanent sur la limite droite de ce header contraint;
  - placer en archives le CTA retour `Mon agenda` / `Agenda du réseau` a cote du titre;
  - ajouter dans le listing agenda a venir hors reseau une croix rouge legere en fin de ligne des sessions supprimables;
  - confirmer cette suppression par modale et reutiliser le flux existant `session_delete` avec retour vers l'agenda courant;
  - laisser le rechargement de l'agenda masquer les blocs de soiree/evenement devenus vides apres suppression de leur derniere session;
  - harmoniser les lignes compactes du listing agenda avec les cartes session du pivot pour afficher, a cote de l'horaire de session, les inscrits d'archive ou `Participations : X`;
  - ajouter a cote du CTA principal des blocs agenda a venir un CTA secondaire `Ajouter 1 session`;
  - faire pointer ce CTA secondaire vers le meme flux d'ajout date que le widget `+` de la page pivot;
  - appliquer au CTA secondaire un style inverse: fond transparent par defaut, couleur pleine au survol;
  - dans le listing agenda general, afficher cette carte dans un wrapper de meme largeur que les groupes de soiree/evenement;
  - dans cette variante agenda, rendre le contenu sur deux colonnes sous le titre: texte a gauche et icone `+` a droite, avec empilement mobile;
  - conserver la largeur historique du widget sur ses autres inclusions;
  - adapter les agendas vides Home dynamisation en `Programme dès maintenant tes prochaines soirées Cotton ! Choisis tes dates puis ajoute tes sessions de jeu.`;
  - adapter les agendas vides Home gamification en `Programme dès maintenant ton prochain événement ! Choisis une date puis ajoute une ou plusieurs sessions de jeu.`;
  - limiter le wording pivot a la carte locale de `/extranet/start/games/day/YYYY-MM-DD`: titre `AJOUTER UNE SESSION`, texte `Complète cette soirée/cet événement...`, CTA `Ajouter à cette soirée` / `Ajouter à cet événement`;
  - masquer dans la bibliotheque agenda le bandeau `Choisis une nouvelle session pour ta soiree/ton evenement` quand aucune `day_date` valide n'est transmise;
  - conserver ce bandeau uniquement pour l'ajout depuis pivot date avec `day_date` valide;
  - retirer la carte de programmation generale des confirmations `resume` et `resume_batch`, tout en conservant leurs bandeaux de date et liens pivot;
  - ne pas specialiser l'ancienne fiche `operations/events` en ajout rattache, afin de ne pas modifier sa logique de rattachement evenement;
  - ne pas modifier les CTA metier des cartes sessions (`Préparer`, `Ouvrir le jeu`, `Reprendre`, `Voir les résultats`).
- [x] Verification:
  - `php -l web/ec/modules/widget/ec_widget_jeux_sessions_cta.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_operation_evenement_agenda.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK;
  - `git diff --check -- web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK;
  - `php -l web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK;
  - `php -l web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_4_resume.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php` OK.

## PATCH 2026-06-16 - Agenda day: header compact, étapes et bilan allégé
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, la carte repo `pro` et le journal AI Studio raw avant patch;
  - confirmer que la page pivot `/extranet/start/games/day/YYYY-MM-DD` est rendue par `web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
  - confirmer que les modales locales Media Kit et fiche lieu existent deja sur la page et peuvent etre reutilisees;
  - confirmer que le listing agenda utilise deja les libelles date `Aujourd'hui` / `Demain` et le format uppercase;
  - confirmer que le podium du bilan passe par le helper partage `Ma communaute` et doit rester scope localement;
  - confirmer que les cartes sessions restent rendues par `ec_start_sessions_list_bloc.php` sans refonte.
- [x] Correctif:
  - remplacer le bandeau hero degrade par un header compact integre au flux de page;
  - reprendre le libelle date compact de l'agenda (`AUJOURD'HUI`, `DEMAIN`, puis date uppercase sinon);
  - conserver les pills sessions et plage horaire dans le header;
  - rapprocher les cartes sessions du header en reduisant les espacements verticaux;
  - remplacer le bloc `Recommandations et astuces` par une section légère d'étapes numerotees sans panneau blanc englobant;
  - transformer les étapes en cartes visuelles translucides sur fond violet, avec bordure claire, numéro centre en haut, texte clair et hauteur homogène;
  - renforcer le fond et la bordure des cartes d'etapes, avec pictos lumineux plus visibles en haut a droite;
  - aligner l'espacement de la grille d'etapes sur les gutters des cartes sessions;
  - faire occuper toute la largeur disponible aux variantes a 2 etapes, avec 2 colonnes maintenues tablette et empilement seulement sur mobile etroit;
  - placer le titre puis le picto sous le numero d'etape, centres, avec un picto plus visible;
  - ajouter dans le header un sous-titre contextuel avant/Jour J/apres, adapte au contexte dynamisation/gamification et au nombre de sessions;
  - reduire les titres de section d'etapes a `À faire avant le jour J` / `À faire avant l'événement` pour eviter la redondance avec le header;
  - afficher les étapes de preparation dynamisation avec liens inline Media Kit, lieu public si disponible et fiche lieu si pertinente;
  - afficher les étapes de preparation gamification/evenement sans troisieme étape artificielle;
  - adapter les titres, textes, mentions et liens de session au singulier/pluriel (`ma session`, `ta session`, `le lien de ta session`, `tes sessions`, `tes liens de sessions`);
  - remplacer les liens de preparation par une mention non cliquable vers le bouton `Préparer` de la ou des cartes session;
  - ouvrir les liens horaires d'annonce vers les URLs publiques www de session, en nouvel onglet;
  - remplacer le déroulé Jour J par `Ouvrir le jeu`, `Accueillir les joueurs/participants`, puis `Suivre la soiree/evenement`, sans orienter vers une session test;
  - integrer l'information de pilotage animateur mobile par QR code dedie dans l'etape 1 Jour J;
  - afficher cette information comme astuce secondaire dans l'etape 1, avec icone mobile et texte plus discret;
  - afficher les étapes Jour J operationnelles sans CTA et sans note separee sous les cartes;
  - supprimer les boutons CTA en bas de carte au profit de liens integres dans le texte;
  - masquer sous-titre et accompagnement quand le bilan est prioritaire ou quand la date est passee;
  - alleger le bloc `Bilan` avec statistiques en chips, podium compacte par CSS local et tableau Top 10 plus dense;
  - conserver les photos de podium suffisamment visibles dans le bilan compact, sans les ecraser a une hauteur trop basse;
  - adapter les microcopies de bilan au singulier/pluriel, dont `Session jouée`, `le résultat de la session jouée` et `les résultats des sessions jouées`;
  - raccourcir le rappel de bareme dans le Top 10;
  - ajouter le titre `Sessions jouées` au-dessus des cartes sessions quand le bilan est affiche en premier;
  - depuis les archives agenda, faire pointer `Voir le bilan` vers la page pivot avec `from=archives` et afficher `Retour aux archives` dans le header pivot;
  - propager le retour pivot archive aux cartes sessions, afin que la fiche session passee affiche encore `Ma soiree` / `Mon evenement` / `Mon animation` comme retour vers la page pivot;
  - conserver les CTA et actions des cartes sessions.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `git diff --check -- web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK.

## PATCH 2026-06-16 - Agenda pivot: quiz builder conserve date et retour
- [x] Audit:
  - confirmer que le builder multi-series Cotton Quiz de la bibliotheque liste ne transmettait pas `day_date` / `day_context` au POST `content_library_quiz_builder_continue`;
  - confirmer que `ec_bibliotheque_script.php` redirigeait vers `/extranet/start/game/setting/...` sans `return_url` pivot;
  - confirmer que `ec_start_step_2_setting.php` ne peut conserver le retour pivot que si `return_url` est present dans l'URL GET;
  - confirmer que le sous-appel `session_theme` depuis `session_setting` ne recevait pas le contexte `from` / `tunnel` / `return_url`.
- [x] Correctif:
  - transmettre `day_date` et `day_context` depuis le builder multi-series de la liste bibliotheque en contexte agenda;
  - reconstruire un `return_url` pivot `/extranet/start/games/day/YYYY-MM-DD` dans `ec_bibliotheque_script.php` pour les redirections `setting` issues du tunnel agenda;
  - ajouter ce retour pivot aux redirections `setting` quiz builder, quiz simple et autres contenus depuis la bibliotheque agenda;
  - propager `from`, `tunnel`, `quiz_lot_ids` et `return_url` au sous-appel `session_theme` lance apres validation de l'etape `setting`.
- [x] Verification:
  - `php -l web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK;
  - `php -l web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_script.php` OK;
  - `git diff --check -- web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php web/ec/modules/tunnel/start/ec_start_script.php` OK.

## PATCH 2026-06-16 - Session detail: retour pivot persistant
- [x] Audit:
  - confirmer que le libelle retour `Ma soiree` / `Mon evenement` / `Mon animation` est decide dans `web/ec/modules/tunnel/start/ec_start_include_header.php`;
  - confirmer que la page detail session lit et propage `return_url` dans `web/ec/modules/tunnel/start/ec_start_sessions_view.php`;
  - confirmer que les cartes de la page pivot fournissent deja `start_session_card_return_url` a `ec_start_sessions_list_bloc.php`;
  - confirmer via le journal AI Studio raw qu'aucun fichier `pro/web/ec/...` recent hors workspace n'est signale.
- [x] Correctif:
  - faire deduire par defaut a la page detail session officielle non archivee son pivot `/extranet/start/games/day/YYYY-MM-DD` quand aucun `return_url` explicite n'est fourni;
  - conserver la priorite aux `return_url` explicites deja transmis par la page pivot ou les actions internes;
  - faire lire au header le contexte de retour calcule par la page detail, pas seulement `$_GET['return_url']`;
  - transmettre ce meme retour pivot aux actions de changement de thematique depuis les cartes session.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_view.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_include_header.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php` OK.

## PATCH 2026-06-15 - Home / Agenda / confirmation: pivot soiree-evenement
- [x] Audit:
  - confirmer que le widget Home `Mon agenda` est rendu par `web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`;
  - confirmer que le listing `/extranet/start/games` groupe deja les sessions par date dans `ec_start_sessions_list.php`;
  - confirmer que la confirmation batch `/extranet/start/game/resume-batch/...` rendait une grille de cartes sans regroupement dans `ec_start_step_4_resume_batch.php`;
  - confirmer que les cartes sessions partagent `ec_start_sessions_list_bloc.php`;
  - confirmer que l'interface games accepte deja un `return_url` interne valide et le sanitise cote `games/web/organizer_canvas.php`.
- [x] Correctif:
  - faire pointer le CTA principal du widget Home vers la prochaine page pivot `/extranet/start/games/day/YYYY-MM-DD`;
  - utiliser `Reprendre` sur la Home si une session de la prochaine date est en cours;
  - masquer sur la Home la liste des sessions individuelles et le compteur global du widget pour ne garder que le resume de la prochaine soiree/evenement;
  - renommer le widget en `Prochaine soiree`, `Prochain evenement` ou `Prochaine animation` quand il presente une date pivot;
  - enrichir le rendu Home avec visuel de la premiere session, badge contexte, titre engageant, texte court, pills date/horaire/sessions, CTA principal et lien secondaire agenda;
  - reduire les doublons badge/titre du widget Home et distinguer explicitement jour J non demarre, soiree/evenement lance, session runtime en cours et toutes sessions du jour terminees;
  - appliquer les wordings finaux du widget: futur `PROCHAINE SOIRÉE` / `PROCHAIN ÉVÉNEMENT`, titres `est programme(e)`, textes de preparation complets, lien secondaire `Agenda complet`, bilan du jour badge `BILAN`;
  - aligner l'architecture du widget sur les autres widgets Home: CTA principal en lien global de carte, suppression du detail des jeux, lien secondaire `Agenda complet` place dans le contenu avec priorite de clic;
  - placer la date en haut du widget, a droite du badge d'etat, plutot que dans la ligne de metadonnees;
  - neutraliser le widget Home `first_party` quand le widget agenda standard est affiche avec au moins une session liee;
  - aligner le visuel du widget Home sur les cartes Agenda en chargeant le detail jeu avec les `lot_ids` de session, notamment pour les sessions Quiz;
  - contextualiser le retour du pivot ouvert depuis la Home vers `Retour à l'accueil`;
  - autoriser uniquement pour la date du jour l'etat Home `BILAN` avec CTA `Voir le bilan` vers la page pivot;
  - conserver les sessions terminees du jour dans la selection Home et Agenda courant jusqu'a la fin de la journee;
  - borner l'historique Agenda aux dates strictement passees pour ne pas pousser le bilan d'une soiree du jour;
  - rapprocher dans les bandeaux Agenda et confirmation batch le compteur de sessions et le CTA pivot de la date, avec wrap responsive;
  - harmoniser les informations des bandeaux Agenda sur la confirmation batch: compteur + plage horaire et CTA conditionnel `Préparer...` / `Voir...` / `Voir le bilan`;
  - ne pas afficher de lien bilan ni de session passee depuis la Home;
  - conserver l'acces programmation existant si aucune session future/courante n'existe;
  - afficher `Voir le bilan` dans les bandeaux de date des archives Agenda;
  - regrouper la confirmation batch par date avec un CTA pivot par date;
  - ajouter sur la confirmation unitaire `ec_start_step_4_resume.php` un bandeau date recapitulant toutes les sessions de la date et le CTA pivot, tout en conservant l'affichage de la seule session creee;
  - conserver les cartes sessions et l'action `Ajouter une session`;
  - transmettre la page pivot comme `return_url` seulement quand une carte est ouverte depuis la page pivot;
  - adapter le libelle retour des fiches sessions ouvertes depuis le pivot en `Ma soirée`, `Mon événement` ou `Mon animation`.
- [x] Verification:
  - `php -l web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php` OK.

## PATCH 2026-06-15 - Agenda day: bilan agrege de soiree/evenement
- [x] Audit:
  - identifier la page `/extranet/start/games/day/YYYY-MM-DD` dans `web/ec/modules/tunnel/start/ec_start_sessions_day.php`;
  - confirmer que les cartes sessions et CTA `Voir les resultats` restent rendus par `ec_start_sessions_list_bloc.php`;
  - identifier l'agregateur `Ma communaute` dans `global/web/app/modules/entites/clients/app_clients_functions.php`;
  - confirmer que `app_session_results_get_context(...)` reste la source resultats par session.
- [x] Correctif:
  - remplacer le bloc Bilan session-par-session par une synthese globale;
  - afficher sessions prises en compte, participants fiables, podium global et classement global quand l'agregat est consolidable;
  - afficher les podiums et classements par jeu quand plusieurs jeux sont presents sur la meme date;
  - reutiliser les helpers UI de `Ma communaute` pour badges jeu, podium 3 cartes et tableaux Top 10;
  - conserver l'ordre `Sessions`, `Recommandations`, `Bilan provisoire` quand la date est aujourd'hui et qu'il reste des sessions a jouer;
  - conserver dans la section `Sessions` du jour les sessions terminees aujourd'hui, meme si elles sont deja passees en archive;
  - afficher le bilan en premier quand toutes les sessions sont consolidees ou quand la date est passee;
  - supprimer les formulations provisoires pour les dates passees;
  - remplacer la metrique principale `x / y sessions prises en compte` par des statistiques sobres `sessions jouees`, `participants`, `jeux joues`;
  - afficher un etat doux sans faux podium quand aucune session terminee ou aucun agregat fiable n'existe;
  - conserver les cartes sessions existantes en dessous avec leurs CTA.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK.

## PATCH 2026-06-15 - Agenda: vue operationnelle par date
- [x] Route:
  - ajouter `/extranet/start/games/day/YYYY-MM-DD` dans le namespace agenda `start/games`;
  - ajouter un fallback vers la meme page pour afficher un message propre sur date invalide;
  - ne pas creer de route `event` / `evenement`.
- [x] Page day:
  - creer `ec_start_sessions_day.php`;
  - reconstruire les sessions depuis `id_client`, date URL et sessions officielles completes non-demo;
  - ajouter un mode temporel `upcoming` / `today` / `past`;
  - reutiliser `app_sessions_filter_by_archive_state(...)` pour les vues a venir et passees;
  - exclure le mode reseau de cette V1 avec message de retour agenda.
- [x] Sections:
  - structurer la page en `Sessions`, `Recommandations et astuces`, `Bilan`;
  - retirer la section `Communication` separee;
  - afficher `Sessions` puis recommandations de preparation/communication avant le jour J;
  - prioriser `Sessions` puis recommandations d'animation le jour J;
  - prioriser `Bilan` puis `Sessions` pour une date passee.
- [x] Wording:
  - creer un helper local `ec_start_sessions_day_helpers.php`;
  - recharger localement le detail client si `id_solution_usage` ou `id_typologie` manque afin d'eviter un fallback `Animation` non justifie;
  - appliquer `soiree` pour CHR / lieu public, `evenement` en UI pour `id_solution_usage=2`, sinon `animation`;
  - conserver `day` dans les noms techniques et la route.
- [x] Communication / bilan:
  - retirer le QR agenda permanent de la page day V1;
  - retirer la liste complete de liens publics copiables;
  - conserver l'acces Media Kit via une modale locale alimentee par les jeux programmes sur la date;
  - afficher le lien fiche lieu seulement dans les recommandations et seulement pour les contextes lieu public / dynamisation pertinents;
  - ne pas afficher de podium global multi-sessions non consolide;
  - afficher les resultats par session et le compteur participants uniquement quand fiable.
- [x] Agenda:
  - ajouter le CTA de groupe date dans `/extranet/start/games`;
  - ne pas modifier les cartes session ni les filtres agenda.
- [x] Hors perimetre:
  - ne pas modifier le widget Home `Mon agenda`;
  - ne pas modifier `first_party`, `operations/events`, les regles de programmation ou les archives.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_day.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK;
  - `git diff --check -- web/.htaccess web/ec/modules/tunnel/start/ec_start_sessions_list.php web/ec/modules/tunnel/start/ec_start_sessions_day.php web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php` OK.

## PATCH 2026-06-12 - First_party ABN/PAK: historique utile bloque le widget Jour J
- [x] Audit:
  - identifier `ec_first_party_can_access_today_preparation(...)` comme condition qui reconstruisait un contexte `first_party` pour les `ABN` / `PAK` actifs avec session officielle du jour;
  - confirmer que la Home et le widget ne requalifient pas le contexte: ils rendent l'etat retourne par `ec_first_party_home_widget_state_get(...)`;
  - isoler la regression au helper, qui ne recontrolait pas l'historique officiel utile dans la branche Jour J.
- [x] Correctif:
  - refuser l'acces preparation Jour J `ABN` / `PAK` quand `ec_first_party_has_useful_past_official_sessions(...)` est vrai;
  - ne pas modifier les regles `INS` ni les CTA, URLs, textes, tunnel, SQL ou styles;
  - conserver le cas `ABN` / `PAK` actif sans archive utile et avec session du jour, qui reste traite comme premiere programmation potentielle.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_first_party_helpers.php` OK.

## PATCH 2026-06-12 - First_party mobile: ancrage et ajustements locaux
- [x] Home simplifiee:
  - identifier `home-first-party-simplified-grid` comme wrapper;
  - limiter les ajustements au variant `.ec-first-party-offer-card`;
  - ne pas toucher au widget `Les jeux` ni aux classes globales.
- [x] Tunnel first_party:
  - ajouter un marqueur local sur la section active;
  - declencher le scroll uniquement apres POST de validation;
  - conserver l'arrivee GET sans scroll intrusif.
- [x] Etape 3 / pivot mobile:
  - alleger `.ec-first-party-network-help`;
  - aerer `.ec-first-party-session-card`, `.ec-first-party-mini-card`, `.ec-first-party-selected-grid`, `.ec-first-party-content-card`;
  - rendre le CTA Jour J du hero pivot lisible sur deux lignes sans changer son texte ni son URL.
- [x] Verification:
  - `php -l web/ec/modules/widget/ec_widget_home_first_party_onboarding.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK;
  - `npm run docs:sitemap` OK.
- [x] Correctif Home ABN/PAK:
  - rendre `Mon agenda`, `Les jeux` et `Ma communaute` apres le widget `first_party` quand une preparation first_party est active;
  - garder le correctif dans `ec_home_index.php`, sans modifier les widgets partages.

## PATCH 2026-06-11 - Home: neutralisation widget ABN generique premiere animation
- [x] Home EC:
  - neutraliser `abn_generic_onboarding` apres calcul du widget reseau Home;
  - conserver les bandeaux reseau contextuels utiles;
  - ne pas modifier le widget `first_party` ni ses regles d'eligibilite.
- [x] Verification:
  - `php -l web/ec/modules/communication/home/ec_home_index.php` OK;
  - `git diff --check -- web/ec/modules/communication/home/ec_home_index.php` OK.

## PATCH 2026-06-11 - First_party pivot: cartes sessions alignees agenda
- [x] Audit agenda:
  - identifier `ec_start_sessions_list.php` + `ec_start_sessions_list_bloc.php` comme listing et template de carte;
  - confirmer `app_session_edit_state_get(...)` + `app_session_display_chronology_get(...)` comme source de statut;
  - confirmer `app_session_participations_probables_get_count(...)` pour les participations probables;
  - confirmer `app_session_results_get_context(...)[players_count]` pour les joueurs runtime archives.
- [x] Pivot first_party:
  - remplacer le compteur melange `probable + nb_participants` par un compteur dependant de l'etat;
  - afficher les participations probables avant / pendant;
  - afficher les joueurs runtime apres terminaison;
  - masquer le compteur runtime si aucun joueur n'est disponible;
  - aligner les icones sur l'agenda.
- [x] CTA:
  - conserver les liens existants;
  - afficher `Préparer`, `Ouvrir le jeu`, `Reprendre`, `Voir les résultats` selon l'etat session;
  - ajouter `Reprendre` cote agenda pour les sessions en cours.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_first_party_helpers.php` OK;
  - `git diff --check` OK.

## PATCH 2026-06-11 - First_party ABN/PAK: pivot conserve tout le jour J
- [x] Helper first_party:
  - ajouter une condition dediee `ec_first_party_can_access_today_preparation(...)`;
  - limiter cette condition aux comptes actifs `ABN` / `PAK`, non siege reseau, avec offre effective active;
  - qualifier le jour J par l'existence d'une session officielle complete non-demo online avec `DATE(date)=CURDATE()`;
  - conserver `ec_first_party_is_eligible_account(...)` comme condition de creation / reproposition du tunnel initial;
  - exposer dans l'etat Home la difference entre `can_create_preparation` et `can_access_today_preparation`.
- [x] Widget / pivot:
  - maintenir le widget Home en mode `preparation` pendant tout le jour J pour `ABN` / `PAK`, meme si l'historique utile rend l'eligibilite initiale fausse;
  - maintenir l'acces direct `/extranet/onboarding/first-party` pendant le jour J dans le meme cas;
  - ne pas maintenir le pivot apres le jour J;
  - ne pas modifier les cas `INS` / `CSO`.
- [x] Rattrapage documentaire:
  - documenter la separation activation formule vs active first programming;
  - documenter la distinction `INS` / `CSO` / `ABN` / `PAK` pour les blocages;
  - documenter l'exclusion des `ABN` / `PAK` actifs du blocage global formule;
  - documenter la conservation des acces agenda, communaute, Media Kit, widget agenda Home, CTA bibliotheque et lien secondaire CSO.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_first_party_helpers.php` OK.

## PATCH 2026-06-11 - Widget Home first_party: lien reactivation CSO et eligibilite INS
- [x] Widget Home first_party:
  - ajouter un lien secondaire discret `Reactiver directement un abonnement` sous le CTA principal du variant `offer_card`;
  - limiter ce lien aux comptes `CSO` sans offre active, eligibles au widget `first_party`, avec URL ecommerce disponible;
  - ne pas afficher ce lien quand la first_party est deja programmee (`preparation`) ni dans le cas Jour J formule/pivot;
  - ne pas l'afficher pour `INS`, `ABN` ou `PAK`;
  - conserver le CTA principal et le clic global de carte vers `/extranet/onboarding/first-party`;
  - aligner la destination du lien sur l'URL commande deja calculee pour le menu `Je commande`;
  - reutiliser le rendu `ec-first-party-offer-card-secondary-cta` du CTA secondaire Jour J;
  - stopper la propagation du clic secondaire pour ne pas activer la redirection globale.
- [x] Eligibilite:
  - laisser les `INS` eligibles acceder au tunnel meme avec anciennes sessions officielles passees;
  - conserver l'historique officiel utile comme protection pour `ABN` / `PAK`;
  - ne pas considerer les sessions officielles passees comme bloquantes pour `CSO`.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_first_party_helpers.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_home_first_party_onboarding.php` OK;
  - `php -l web/ec/modules/communication/home/ec_home_index.php` OK;
  - `git diff --check` OK.

## PATCH 2026-06-11 - Navigation first_party: commande discrete en derniere position
- [x] Navigation EC:
  - remplacer l'ancien bouton commande dominant par un lien `nav-link` discret;
  - afficher ce lien pour les comptes sans offre active dans le parcours accompagne `first_party` / `next_party`;
  - conserver le libelle dynamique existant `Essai gratuit` / `Je m'abonne` / `Je commande`;
  - conserver l'URL ecommerce existante;
  - placer le lien commande apres `Offre & Factures` quand ce lien est affiche, donc en derniere entree visible de la liste principale;
  - ne pas reafficher `Mon agenda`, `Ma communaute` ou `Media Kit`.
- [x] Verification:
  - `php -l web/ec/ec.php` OK;
  - `git diff --check -- web/ec/ec.php` OK.

## PATCH 2026-06-11 - First_party etendu aux CSO sans offre active
- [x] Eligibilite:
  - ajouter le cas `CSO` dans le helper central `first_party` uniquement quand l'offre effective est inactive;
  - conserver `app_ecommerce_offre_effective_get_context(...)` comme source d'acces commercial effectif, y compris pour les offres deleguees actives;
  - ne pas creer de route ni de tunnel `next_party`;
  - conserver les exclusions existantes: compte restreint, siege reseau, contexte non resolu.
- [x] Home et navigation:
  - afficher la Home simplifiee `first_party` + `Les jeux` pour un `CSO` eligible sans offre active;
  - afficher le widget en mode preparation/pivot si une session officielle future existe;
  - masquer `Mon agenda`, `Ma communaute`, `Media Kit` et le CTA commande dominant pour tout compte dans le parcours accompagne.
- [x] Wording:
  - conserver `premiere soiree` / `premier evenement` pour `INS`;
  - utiliser `prochaine soiree` / `prochain evenement` pour `CSO`;
  - adapter les CTA Home, pivot, bibliotheque et modales de blocage.
- [x] Bibliotheque et controles:
  - autoriser la preselection bibliotheque vers `/extranet/onboarding/first-party` pour `CSO` eligible sans session officielle future;
  - bloquer la programmation hors pivot pour un `CSO` eligible qui a deja une session officielle future tant qu'aucune offre effective active n'existe.
- [x] Verification:
  - `php -l` OK sur les 9 fichiers PHP touches;
  - `git diff --check` OK.

## PATCH 2026-06-11 - Home first_party: horaires aux couleurs gamification
- [x] Widget Home first_party:
  - ajouter une classe de couleur typologie sur la carte `offer_card`;
  - remplacer la couleur fixe des horaires de sessions par une variable d'accent locale;
  - mapper `21` sur l'orange Cotton et `22` sur le rose pour les horaires de la carte;
  - ne pas modifier le variant standard du widget ni les donnees affichees.
- [x] Verification:
  - `php -l web/ec/modules/widget/ec_widget_home_first_party_onboarding.php` OK;
  - `git diff --check` OK.

## PATCH 2026-06-11 - Home first_party: widget reseau affilie conserve en bas
- [x] Home:
  - supprimer la neutralisation `replaced_by_first_party` du widget reseau affilie;
  - conserver le rendu bas de page existant via `home_network_affiliate_widget_render_at_bottom`;
  - autoriser ce rendu bas meme quand la Home est en mode `first_party` simplifie;
  - ne pas modifier les conditions serveur du helper `app_client_home_onboarding_widget_get(...)`.
- [x] Verification:
  - `php -l web/ec/modules/communication/home/ec_home_index.php` OK;
  - `git diff --check` OK.

## PATCH 2026-06-10 - Restore INS Home first_party avec sessions futures
- [x] Home:
  - restaurer la Home simplifiee `first_party` + `Les jeux` pour les comptes `INS` avec ou sans session officielle future;
  - forcer un contexte d'affichage `venue` / `event` depuis la typologie si le contexte first_party standard est vide;
  - en cas de session officielle future, garder le widget `first_party` en mode preparation et conserver la Home simplifiee;
  - conserver l'exclusion Home simplifiee des `ABN` / `PAK` ayant une session officielle future.
- [x] Bibliotheque:
  - restaurer les CTA `Lancer une démo` + `Utiliser pour ma première soirée` / `Utiliser pour mon premier événement` pour les `INS` sans session officielle future;
  - appliquer le fallback contexte sur fiche detail et liste;
  - garantir cote script que le submit bibliotheque seed le tunnel `first_party` au lieu de creer une session classique.
- [x] Verification:
  - `php -l` OK sur Home, fiche detail, liste et script bibliotheque;
  - `git diff --check` OK.

## PATCH 2026-06-10 - Pivot first_party astuce fiche lieu verifiee
- [x] Pivot:
  - afficher l'astuce fiche lieu pour tout contexte first_party `venue`, meme quand les infos minimales existent deja;
  - conserver `Complète ta fiche lieu` quand il manque des champs obligatoires;
  - afficher `Vérifie ta fiche lieu` et le texte `pour adapter les infos...` quand la fiche est deja complete;
  - apres sauvegarde modale, conserver l'astuce et la basculer en mode verification au lieu de la supprimer.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK;
  - `git diff --check` OK.

## PATCH 2026-06-10 - Widget Home first_party pictos commande
- [x] Widget Home first_party:
  - reprendre l'icone de titre des widgets commande selon la typologie: `✨` lieu/abonnement, `🎯` evenement, `⚡` particulier;
  - ajouter `🚀` avant le texte du CTA principal;
  - supprimer les fleches `→` des libelles CTA du variant `offer_card`;
  - conserver les destinations et la logique `stretched-link` existantes.
- [x] Verification:
  - `php -l web/ec/modules/widget/ec_widget_home_first_party_onboarding.php` OK;
  - `git diff --check` OK.

## PATCH 2026-06-10 - First_party ABN/PAK avant session officielle future
- [x] Home:
  - etendre la Home simplifiee `first_party` + `Les jeux` aux comptes `ABN` / `PAK` actifs eligibles first_party uniquement quand `ec_first_party_home_widget_state_get(...)` est en `onboarding`;
  - masquer dans ce cas le widget Home `Mon agenda` et les autres widgets de la grille standard;
  - conserver le comportement existant des `ABN` / `PAK` ayant deja une session officielle future.
- [x] Bibliotheque:
  - etendre les CTA de fiche thematique `Lancer une démo` + `Utiliser pour ma première soirée` / `Utiliser pour mon premier événement` aux `ABN` / `PAK` first_party sans session officielle future;
  - appliquer le meme pre-remplissage first_party depuis la fiche detail et le builder liste;
  - ne pas modifier les remplacements de themes, les contextes agenda ni les comptes avec session officielle future.
- [x] Widget `Les jeux`:
  - reutiliser la variante `Explore les thèmes` dans la Home simplifiee first_party, y compris pour `ABN` / `PAK`;
  - conserver les libelles standards hors contexte first_party simplifie.
- [x] Verification:
  - `php -l` OK sur les 4 fichiers PHP modifies;
  - `git diff --check` OK.

## PATCH 2026-06-10 - Correctif INS Quiz bibliotheque + widget Jour J
- [x] Bibliotheque Cotton Quiz:
  - conserver `content_library_quiz_builder_add` pour un `INS` pre-programmation sans session officielle future;
  - permettre l'ajout jusqu'a 4 series avant entree dans le tunnel;
  - ajouter `first_party_library_confirm=1` sur `content_library_quiz_builder_continue` pour basculer vers `first_party` apres validation du builder;
  - appliquer le comportement depuis la fiche detail et depuis la liste;
  - ne pas changer Blind Test / Bingo Musical ni les comptes `INS` deja programmes.
- [x] Widget Home first_party:
  - supprimer les chips post-programmation;
  - afficher les CTA Jour J formule + pivot en deux colonnes desktop;
  - rendre le CTA pivot lisible;
  - rapprocher le CTA du contenu;
  - rendre la carte entierement cliquable vers le CTA principal;
  - appliquer l'effet hover au widget et au CTA principal via `stretched-link`, comme le widget `Les jeux`, sans positionnement propre sur le bouton principal;
  - utiliser le visuel `cotton-club.jpg` pour la typologie Particulier.
- [x] Verification:
  - `php -l` OK sur les 4 fichiers PHP touches;
  - `git diff --check` OK.

## PATCH 2026-06-10 - Home INS first_party recap dynamique
- [x] Audit:
  - Home EC: `web/ec/modules/communication/home/ec_home_index.php`;
  - widget first_party Home: `web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`;
  - widget `Les jeux`: `web/ec/modules/widget/ec_widget_jeux_discover_library.php`;
  - helper first_party: `web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
  - logique dynamique existante: fonctions `ec_first_party_home_widget_*` et `$first_party_widget_summary`.
- [x] Rendu post-programmation:
  - conserver le layout Home `INS` 2/3 + 1/3;
  - integrer le resume date / nombre de sessions / jeux / horaires / titres-themes dans le variant `offer_card`;
  - remplacer les etapes generiques par les actions restantes;
  - garder le CTA pivot seul avant Jour J.
- [x] Jour J:
  - reutiliser `ec_first_party_typology_offer_url_get(...)`;
  - afficher CTA formule + CTA pivot seulement si la formule est proposable et l'URL disponible;
  - conserver le pivot seul si l'URL est absente.
- [x] UI:
  - carte `Les jeux` en hauteur complete;
  - CTA des deux widgets alignes via `mt-auto` / `h-100`;
  - repli mobile en pleine largeur conserve.
- [x] Garde-fous:
  - aucune modification de programmation, pivot, tunnel, SQL ou routes;
  - aucun changement voulu `ABN` / `PAK` / `CSO`.
- [x] Verification:
  - `php -l` OK sur les 3 fichiers PHP touches;
  - `git diff --check` OK.

## PATCH 2026-06-10 - Bibliotheque INS avant programmation first_party
- [x] Audit:
  - fiche detail bibliotheque: `web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`;
  - seed et redirection first_party depuis bibliotheque: `web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`;
  - liste bibliotheque: `web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`;
  - helper first_party: `web/ec/modules/tunnel/start/ec_first_party_helpers.php`;
  - widget Home `Les jeux`: `web/ec/modules/widget/ec_widget_jeux_discover_library.php`.
- [x] Fiche thematique:
  - detecter uniquement un compte `INS` en contexte first_party sans session officielle future;
  - afficher `Lancer une démo` en CTA principal;
  - afficher `Utiliser pour ma première soirée` ou `Utiliser pour mon premier événement` en CTA secondaire;
  - ne plus afficher `Créer un Blind Test` / `Créer un Bingo Musical` / `Créer un Cotton Quiz` dans ce cas;
  - reutiliser le seed first_party existant avec confirmation pour rediriger vers le tunnel;
  - ne pas afficher de modale intermediaire pour ce cas;
  - conserver le blocage/modale existant pour un `INS` avec session officielle future.
- [x] Widget Home:
  - pour `INS`, remplacer `Programme tes sessions` par `Explore les thèmes`;
  - conserver les libelles existants pour `ABN`, `PAK` et `CSO`.
- [x] Tracking:
  - pousser `first_party_library_theme_demo_click` sur le submit demo;
  - pousser `first_party_library_theme_use_click` sur le submit d'utilisation first_party.
- [x] Verification:
  - `php -l` OK sur les fichiers PHP modifies/non commits du repo `pro`;
  - `git diff --check` OK.

## PATCH 2026-06-10 - Home INS simplifiee first_party + jeux
- [x] Audit:
  - Home EC identifiee: `web/ec/modules/communication/home/ec_home_index.php`;
  - widget first_party: `web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`;
  - widget commande/offre: `web/ec/modules/widget/ec_widget_ecommerce_abonnement.php`, `ec_widget_ecommerce_evenement.php`, variantes particulier/CSO;
  - widget `Les jeux`: `web/ec/modules/widget/ec_widget_jeux_discover_library.php`;
  - detection future first_party: `ec_first_party_has_future_official_sessions(...)`;
  - CTA commande menu: `web/ec/ec.php`.
- [x] Home INS:
  - afficher `first_party` avant `Les jeux`;
  - appliquer `col-xl-8` au widget first_party et `col-xl-4` au widget `Les jeux`;
  - masquer les widgets offre/commande et les autres widgets Home pour `INS`;
  - garder le repli mobile en pleine largeur.
- [x] Widget first_party:
  - ajouter une variante visuelle reprenant le gabarit du widget commande actuel;
  - appliquer les textes onboarding soiree/evenement demandes;
  - conserver l'etat pret et le CTA pivot quand une session officielle future existe.
- [x] Navigation:
  - masquer le CTA commande menu uniquement pour `INS` avec session officielle future first_party.
- [x] Verification:
  - `php -l` OK sur les 4 fichiers PHP modifies;
  - `git diff --check` OK.

## PATCH 2026-06-10 - First_party INS programme: blocage hors pivot
- [x] Garde centrale:
  - bloquer uniquement les comptes `INS` eligibles avec session officielle future;
  - conserver le comportement existant apres passage de la premiere date;
  - ne pas modifier checkout, offres, pivot ou creation first_party normale.
- [x] Programmation hors pivot:
  - couvrir `session_init` officielle, `session_setting_multi` et `agenda_mode_select`;
  - bloquer les actions de creation depuis la bibliotheque sans seed d'un nouveau parcours;
  - conserver les demos et la consultation/personnalisation existantes.
- [x] Modales:
  - afficher le texte `Ta première soirée est prête` en contexte soiree;
  - afficher le texte `Ton premier événement est prêt` en contexte evenement;
  - proposer le CTA formule via route existante quand disponible;
  - conserver le CTA pivot et ne pas inventer de route si le CTA formule n'est pas disponible.
- [x] Navigation:
  - masquer `Mon agenda`, `Ma communaute` et `Media Kit` pour tous les comptes `INS`.
- [x] Verification:
  - `php -l` OK sur les 8 fichiers PHP modifies;
  - `git diff --check` OK.

## PATCH 2026-06-10 - Navigation EC: liens masques sans session visible
- [x] Menu gauche:
  - le lien `Mon agenda` reste masque pour les comptes siege reseau;
  - le lien `Mon agenda` est masque pour tout compte sans session officielle visible: future/en cours non archivee, ou archive utile;
  - le lien `Media Kit` suit la meme regle;
  - le lien `Ma communaute` suit la meme regle, avec exigence directe d'une archive utile pour les comptes gamification;
  - le CTA ecommerce du menu gauche suit la meme regle;
  - le libelle du CTA ecommerce devient `Essai gratuit` pour un compte `INS` dynamisation eligible, `Je commande` pour un compte gamification, sinon `Je m'abonne`;
  - les archives non utiles, par exemple sessions numeriques sans vrais joueurs/resultats, ne qualifient pas l'affichage;
  - la regle ne depend plus du pipeline, de la typologie ni de l'offre active/effective;
  - les sessions demo et les sessions incompletes ne qualifient pas l'affichage.
- [x] Agenda:
  - le CTA `Voir mes sessions passees` utilise le meme filtre utile que la liste `Archives`;
  - une archive non utile ne suffit plus a afficher le CTA.
- [x] Garde-fous:
  - aucun changement sur `Agenda reseau`;
  - aucun changement sur les routes agenda, la programmation ou les sessions;
  - aucun changement sur la logique des pages Home, first_party, offre ou checkout.
- [x] Verification:
  - `php -l web/ec/ec.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK.

## PATCH 2026-06-10 - Home first_party: neutralisation du mode reprise
- [x] Home widget:
  - suppression du mode `resume` pour les comptes sans session officielle future;
  - le widget reste visible via le mode onboarding classique quand le compte n'a pas d'archive officielle utile;
  - les titres redeviennent `Prépare ta première soirée Cotton` ou `Prépare ton premier événement Cotton` selon le contexte;
  - les titres `Reprogramme ta première soirée Cotton` / `Reprogramme ton premier événement Cotton` ne sont plus atteignables depuis le widget.
- [x] Conservation tunnel:
  - l'historique bloquant est maintenant l'archive officielle utile via `app_client_has_visible_official_session_signal($id_client, 1)`;
  - les `ABN` / `PAK` actifs sans archive officielle utile deviennent eligibles au parcours premiere programmation;
  - les sessions officielles passees non utiles ne bloquent plus les `INS`, `ABN` ou `PAK`;
  - le CTA Home conserve l'URL standard du tunnel, sans `reset=1`;
  - l'etat `$_SESSION[first_party_onboarding_v1_<id_client>]` reste conserve si l'utilisateur quitte puis revient dans le tunnel.
- [x] Garde-fous:
  - aucun changement de detection des sessions futures ni du pivot;
  - aucun changement offre / checkout / creation de sessions.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_first_party_helpers.php` OK;
  - `php -l web/ec/modules/communication/home/ec_home_index.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_home_first_party_onboarding.php` OK.

## PATCH 2026-06-10 - First_party pivot: mention essai gratuit sous CTA
- [x] Pivot:
  - remplacement de l'ancien message conditionne uniquement par J+15 par une mention placee sous le CTA `Choisir ma formule d'essai gratuit`;
  - affichage limite aux comptes dynamisation `INS` eligibles, sans offre active;
  - exclusion des contextes gamification / event et des comptes `ABN` / `PAK`;
  - texte par defaut: `15 jours gratuit, sans engagement.`;
  - si la premiere date officielle future est strictement apres J+15, ajout de `Attends le bon moment pour l’activer ;).`.
- [x] Garde-fous:
  - aucun changement Stripe, offre, checkout, eligibility first_party ou creation de sessions.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK.

## PATCH 2026-06-10 - First_party tunnel: acces catalogue unique dans l'astuce
- [x] UI tunnel:
  - suppression du lien isole `Catalogue complet de playlists` / `Catalogue complet de séries thématiques` sous la grille;
  - conservation d'un seul acces externe dans l'astuce `ec-first-party-session-edit__tip`, affichee sous le mini catalogue;
  - lien simple `Catalogue complet` vers le catalogue filtre sur le jeu choisi (`/extranet/games/library?game=<jeu>`), sans `type`, `preset`, `from`, `session_index`, `slot_index` ni hook JS de remplacement;
  - wording adapte `toutes les playlists` pour Blind Test / Bingo Musical et `toutes les séries thématiques` pour Quiz.
- [x] Garde-fous:
  - aucune modification de la selection `A la une`;
  - aucune modification de limite d'affichage, route ou regle first_party.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK.

## PATCH 2026-06-10 - First_party pivot: alignement astuce session edition
- [x] UI pivot:
  - `ec-first-party-session-edit__tip` partage les memes regles CSS que `ec-first-party-place-share-notice`;
  - alignement du conteneur, de l'icone lightbulb, du paragraphe et du lien;
  - ajout du prefixe `<strong>Astuce —</strong>` pour aligner aussi le libelle visible;
  - aucun changement metier, tunnel, session, offre ou sauvegarde.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK.

## PATCH 2026-06-09 - First_party pivot: verification fiche lieu avant partage
- [x] Pivot:
  - remplacement du bloc distinct par une astuce inline dans la section `Les participants` avant les cartes Media Kit / liens / QR code;
  - message limite au contexte `venue` first_party, donc absent pour `event` / gamification;
  - affichage disponible avant jour J et jour J tant que la section participants est rendue;
  - masquage si la fiche lieu a deja les champs obligatoires (`nom`, `adresse`, `code postal`, `ville`, `pays`) ou apres sauvegarde modale reussie.
- [x] CTA:
  - `Completer ma fiche lieu` ouvre une grande modale d'edition;
  - la modale charge l'ecran existant `/extranet/account/establishment/manage` en mode fragment `async=1&modal=1`;
  - la sauvegarde reutilise `ec_client_script.php` et repond en JSON uniquement pour `first_party_modal=1`;
  - un fallback lien direct reste disponible si la modale ne peut pas charger ou enregistrer;
  - aucun formulaire de fiche lieu concurrent n'est cree dans le pivot.
- [x] Formulaire lieu:
  - `Adresse` devient obligatoire, en plus de `nom`, `code postal`, `ville` et `pays`.
- [x] Garde-fous:
  - aucune modification des regles `clients.online`;
  - aucune modification des regles de publication `/fr/place` ou `/fr/agenda`;
  - aucun changement Stripe/offres.

## PATCH 2026-06-09 - First_party pivot: message essai gratuit si premiere date apres J+15
- [x] Audit Stripe / offre:
  - le checkout abonnement utilise `subscription_data.trial_period_days` pour l'essai gratuit, sans `trial_end` ni date de demarrage differee active;
  - l'ancien bloc `billing_cycle_anchor` / `proration_behavior` pour un demarrage decale est commente et ne couvre pas le parcours first_party actuel;
  - le webhook `invoice.paid` valide l'offre Cotton des la creation de la souscription, y compris quand la premiere facture Stripe vaut `0` pour essai gratuit;
  - les offres Cotton en attente sont creees avec `date_debut` au jour courant et ne portent pas de date first_party a activer plus tard;
  - un helper de subscription schedule existe cote global, mais il n'est pas branche sur la creation Checkout first_party et demanderait une conception dediee.
- [x] Decision:
  - activation Stripe differee non patchee dans ce lot;
  - aucun changement de Checkout, webhook, session Stripe, regles d'offre ou ouverture `CSO`.
- [x] Pivot:
  - ajout d'un message non bloquant dans le footer d'activation quand le compte est `INS`, eligible first_party, sans offre active, avec premiere session officielle future strictement apres J+15;
  - message affiche: `Ton essai gratuit dure 15 jours. Attends le bon moment pour l’activer : ta préparation restera disponible.`;
  - le CTA de choix de formule reste visible et inchange.
- [ ] Futur patch si besoin:
  - concevoir une activation differee bout-en-bout avec date cible, etat Cotton, creation Stripe, webhooks, echecs de paiement, synchronisation offre effective et recette first_party venue/event.

## PATCH 2026-06-09 - Home EC: widget affiliation reseau en bas de page
- [x] Test de placement:
  - le widget d'affiliation a une TdR reste rendu par `ec_widget_client_network_affiliate_home.php`;
  - ses classes, variantes (`primary`, banner, card) et styles existants sont conserves;
  - les appels historiques en haut de page sont neutralises via un rendu differe;
  - le widget est rendu une seule fois apres la grille principale de la Home.
- [x] Ajustement de cadrage bas:
  - la row basse est bornee a la largeur utile de la derniere row de contenu visible en desktop;
  - les rows principales de la Home partagent la classe `home-content-row` pour harmoniser l'espacement entre lignes selon les contextes;
  - les marges basses de colonnes sont neutralisees dans ces rows pour eviter les additions de `mb-*`;
  - la row reseau conserve une marge basse courte pour eviter un vide excessif avant le bas de page.
- [x] Widget `Nouveautes`:
  - conserve une marge haute dediee quand il est rendu dans la meme row que les widgets centraux.
- [x] Verification:
  - `php -l web/ec/modules/communication/home/ec_home_index.php` OK.

## CADRAGE 2026-06-09 - First_party V1 et extensions futures
- [x] V1:
  - parcours limite aux `INS` eligibles et aux nouveaux comptes actifs `ABN` / `PAK` sans session officielle passee;
  - cible produit: preparation accompagnee d'une premiere soiree ou d'un premier evenement;
  - pas d'ouverture runtime supplementaire dans ce cadrage.
- [ ] Extensions futures:
  - `CSO` autonomes sans offre active: concevoir un parcours de reactivation distinct;
  - affilies reseau: definir une regle dediee, separee de la V1 first_party.

## AUDIT 2026-06-09 - First_party Home: extension CSO
- [x] Definition technique CSO:
  - pipeline lu depuis `clients.id_pipeline_etat` puis `referentiels_clients_pipeline_etats.nom`;
  - les syncs d'offre effective basculent vers `CSO` seulement si l'acces effectif disparait et que le compte n'est ni `INS` ni deja `CSO`;
  - un `CSO` peut donc representer un ancien client sans acces effectif, mais le pipeline seul n'est pas une preuve suffisante: la source fiable reste `app_ecommerce_offre_effective_get_context(...)`;
  - un `CSO` peut etre affilie reseau (`id_client_reseau`) et peut avoir des sessions officielles futures, la Home historique le gere deja via agenda/offre/decouverte.
- [x] Offre active:
  - `app_ecommerce_offre_effective_get_context(...)` resout `own_offer`, `network` ou `inactive`;
  - une offre propre active est `ecommerce_offres_to_clients.id_etat=3` hors offres support reseau, avec delegation propre possible;
  - une delegation reseau active compte aussi comme acces effectif si support actif, affilie active et offre deleguee `id_etat=3`;
  - `id_etat=2/4`, ancienne offre, commande en attente ou contrat reseau inactif ne doivent pas ouvrir first_party CSO.
- [x] Impact tunnel:
  - `ec_first_party_is_eligible_account(...)` rejette actuellement `CSO`;
  - le tunnel utilise le meme helper, affiche une notice ineligible et bloque creation/annulation si le compte n'est pas eligible;
  - la creation first_party appelle `app_session_ajouter(..., id_offre_client=0, flag_session_demo=0, online=1)` puis complete les contenus, donc elle peut techniquement creer des sessions sans offre;
  - la page pivot sans offre active renvoie vers l'URL d'offre typologique; c'est coherent pour un CSO sans acces;
  - l'annulation first_party supprime toutes les sessions officielles futures de la premiere date affichee, ce qui impose d'exclure tout CSO avec session officielle future.
- [ ] Decision:
  - extension CSO non patchee;
  - raison: l'ouverture touche l'eligibilite commune Home/tunnel/guards et doit arbitrer explicitement les CSO affilies reseau inactifs, les comptes avec historique officiel ancien, et la place de first_party face aux widgets Home CSO existants;
  - regle proposee pour futur patch: `pipeline === CSO`, `ec_first_party_has_active_offer(...) === false`, aucune session officielle future exploitable, pas siege reseau/TdR restreint, pas de delegation reseau active ou pending, contexte `venue/event` determine par typologie, destination tunnel `/extranet/onboarding/first-party` validee en recette.

## PATCH 2026-06-09 - Home first_party: retour wording historique et modale agenda Home
- [x] Audit:
  - affichage centralise par `ec_first_party_home_widget_state_get(...)`;
  - eligibilite actuelle: `INS` hors siege reseau/restreint, plus comptes actifs `ABN` / `PAK` sans historique officiel passe;
  - mode `resume` uniquement pour `INS` eligible, sans session officielle future, avec au moins une session officielle passee;
  - sessions officielles futures/passees filtrees sur `championnats_sessions`: non demo, configuration complete, online, date valide;
  - contexte `venue` pour typologies `1/8`, `event` pour les autres typologies eligibles.
- [x] Widget Home:
  - suppression de la branche de wording generique `Prepare une soiree Cotton` / `Prepare un evenement Cotton`;
  - restauration des copies historiques `premiere soiree` / `premier evenement` pour les etats entree et reprise;
  - mode `resume` INS conserve avec `A REPROGRAMMER`, `Reprogramme ta premiere soiree Cotton` / `Reprogramme ton premier evenement Cotton` et CTA `Reprendre ma preparation`;
  - mode entree conserve avec `Prepare ta premiere soiree Cotton` / `Prepare ton premier evenement Cotton` et les CTA historiques;
  - logique metier inchangee pour les comptes deja eligibles.
- [x] Widget agenda Home:
  - ajout d'une modale douce sur le raccourci `Je programme` uniquement pour `ABN` / `PAK` actifs eligibles first_party, sans session officielle passee ni session officielle future;
  - reprise de la copie agenda first_party existante via `ec_first_party_preparation_control_copy_get(..., 'agenda')`;
  - CTA principal vers `/extranet/onboarding/first-party`, CTA secondaire de fermeture;
  - aucun changement de creation de session ni d'ouverture `CSO`.
- [ ] CSO:
  - extension non patchee dans ce lot;
  - verifier avant ouverture si `CSO` doit signifier ancien client sans offre active dans ce contexte;
  - confirmer que l'absence d'offre active via `app_ecommerce_offre_effective_get_context(...)`, l'absence de session officielle future, l'absence de restriction reseau/TdR et l'acces tunnel creent une route coherente sans conflit historique.
- [x] Verification:
  - `php -l web/ec/modules/widget/ec_widget_home_first_party_onboarding.php` OK.
  - `php -l web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php` OK.

## PATCH 2026-06-09 - Home EC: stabilisation Nouveautes sans widget prioritaire
- [x] Diagnostic:
  - le widget `Nouveautes` compact est rendu dans la meme grille que les cartes Home;
  - quand les widgets `first_party`, reseau ou feedback ne sont pas affiches, il peut se placer a droite des deux premieres cartes au lieu de demarrer une ligne propre;
  - le script de synchronisation calcule bien une largeur de reference, mais il ne force pas de rupture de ligne flex.
- [x] Correction:
  - insertion d'un break flex desktop avant `Nouveautes` uniquement pour la variante compacte;
  - conservation de la grille commune, mais largeur du bloc `Nouveautes` calculee depuis la largeur reelle de la carte widget de la ligne precedente multipliee par le nombre de cartes jeu;
  - neutralisation de la marge du break flex et reduction de l'espace au-dessus du widget;
  - grille interne compacte avec nombre de colonnes explicite egal au nombre de cartes jeu, pour garder les cartes en ligne sur desktop et eviter toute recomposition automatique en 2 colonnes;
  - suppression du breakpoint intermediaire qui forcait encore 2 colonnes sous `1199.98px`;
  - alignement du `column-gap` interne sur la gouttiere horizontale desktop `gx-sm-4` de la ligne de widgets precedente;
  - aucun changement de recuperation des nouveautes ni des conditions d'affichage.
- [x] Verification:
  - `php -l web/ec/modules/communication/home/ec_home_index.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_home_latest_game_news.php` OK.

## PATCH 2026-06-08 - First_party Home jour J
- [x] Widget Home:
  - detection jour J limitee a la premiere date officielle future first_party;
  - badge `C’EST LE JOUR J` uniquement le jour de cette premiere date;
  - compte avec offre active: CTA `Ouvrir mes sessions` / `Ouvrir ma session` vers le pivot first_party;
  - compte sans offre active: CTA `Voir mes sessions` / `Voir ma session` vers le pivot, avec rappel formule contextualise dans la copie;
  - recap conservé avec label `AUJOURD’HUI`, date et sessions de la premiere date officielle.
- [x] Home:
  - recuperation jusqu'a 50 sessions de la premiere date officielle pour fiabiliser singulier/pluriel et recap;
  - aucune modification du pivot jour J ni du checkout.
- [x] Verification:
  - `php -l` OK sur Home et widget Home first_party.

## PATCH 2026-06-08 - First_party pivot pre-jour J: offre active
- [x] Pivot pre-jour J:
  - compte sans offre active: conserve le rappel formule et le CTA `Choisir ma formule`;
  - compte avec offre active: supprime le rappel formule dans le hero;
  - compte avec offre active: remplace le footer formule par un bloc neutre `Tes sessions sont prêtes`;
  - compte avec offre active: aucun CTA de choix d'offre avant le jour J.
- [x] Garde-fous:
  - textes et logique jour J conserves;
  - pas de changement de lancement des sessions;
  - pas de migration SQL.
- [x] Verification:
  - `php -l` OK sur le pivot first_party;
  - `git diff --check` OK sur `pro`.

## PATCH 2026-06-08 - First_party checkout success: logique durable Home
- [x] Audit cible:
  - `ec_widget_jeux_sessions_cta.php` est aussi appele depuis la Home, l'agenda et le tunnel start;
  - la decision implicite par `first_party_checkout_context_{id_client}` etait fragile;
  - la Home decide deja le widget first_party via les helpers durables d'eligibilite et de sessions officielles futures.
- [x] Correction:
  - suppression du marquage checkout `from=first_party` dans `ec_offres_form_step_1.php`;
  - ajout de `ec_first_party_home_widget_state_get(...)` pour mutualiser la logique Home;
  - confirmation commande alignee sur ce helper durable;
  - widget CTA limite au rendu d'une carte explicite fournie par l'appelant.
- [x] Garde-fous:
  - pas de changement des textes jour J du pivot;
  - pas de lecture de session checkout first_party;
  - hors eligibilite durable first_party, carte `Nouvelle session` conservee.
- [x] Verification:
  - `php -l` OK sur les fichiers PHP touches;
  - `git diff --check` OK sur `pro`.

## PATCH 2026-06-08 - First_party reprise INS post-date
- [x] Eligibilite:
  - `INS` eligible meme avec session officielle passee;
  - `ABN` / `PAK` actifs toujours bloques par historique officiel passe;
  - sessions futures / jour J inchanges via premiere date officielle future.
- [x] Home:
  - detection `INS` avec historique passe et aucune session future;
  - mode widget `resume`;
  - CTA `Reprendre ma préparation`;
  - destination tunnel first_party.
- [x] Garde-fous:
  - aucune migration SQL;
  - pas de retour a `created_session_ids` comme source durable;
  - pas de suppression automatique des sessions passees;
  - anciennes sessions passees non melangees a la reprise.
- [x] Verification:
  - `php -l` OK sur helpers, Home et widget Home;
  - `git diff --check` OK.

## PATCH 2026-06-08 - First_party jour J et confirmation activation
- [x] Pivot avant jour J:
  - copies `venue` enrichies avec personnalisation, test, communication et lien vers la formule d'essai gratuit;
  - copies `event` alignees sur `Les participants`, lien vers la formule et invitation sans mention superflue du premier evenement;
  - bloc `Après la session` harmonise avec classement/podium/photo mobile et annonce de la session suivante.
- [x] Pivot jour J:
  - detection du jour J sur la premiere date officielle future first_party;
  - hero `C’est le jour J !` avec CTA d'offre uniquement sans offre active;
  - wording offre contextualise `venue` / `event`, avec essai gratuit seulement pour `venue`;
  - cartes sessions conservees avec CTA `Ouvrir le jeu` si offre active, sinon `Personnaliser et tester`;
  - section `Derniers conseils` placee avant la communication;
  - section communication complete conservee apres les conseils, Media Kit inclus;
  - QR permanent presente comme acces a l'agenda Cotton, distinct du QR de session affiche dans l'interface de jeu.
- [x] Confirmation offre:
  - page success remplace `Nouvelle session` par retour pivot si la logique durable Home first_party trouve des sessions futures;
  - page success renvoie vers le tunnel first_party si cette meme logique rend le compte eligible sans session future;
  - widget generique conserve hors eligibilite durable first_party.
- [x] Verification:
  - `php -l` OK sur les fichiers PHP modifies;
  - `git diff --check` OK.

## PATCH 2026-06-08 - First_party par historique officiel et premiere date future
- [x] Eligibilite:
  - comptes `INS` eligibles conserves tant qu'ils n'ont aucune session officielle passee;
  - comptes `ABN` / `PAK` avec acces effectif actif couverts tant qu'ils n'ont aucune session officielle passee;
  - mode preparation si aucune session officielle future n'existe encore;
  - mode pret si des sessions officielles futures existent, meme creees hors tunnel;
  - fermeture du parcours des qu'une session officielle prise en compte est strictement passee.
- [x] Helpers:
  - detection offre active via `app_ecommerce_offre_effective_get_context(...)`;
  - fallback legacy sur offres `id_etat=3`;
  - predicate officiel commun: `flag_session_demo=0`, `flag_configuration_complete=1`, `online=1`, date exploitable;
  - detection d'historique officiel passe via `DATE(date) < CURDATE()`;
  - abandon de `created_session_ids` comme source de verite durable;
  - sessions futures first_party limitees a la premiere date future;
  - helper d'etat commercial `prospect` / `active` pour isoler les CTA commerciaux.
- [x] Home et guards:
  - remplacement du widget historique `Lance ta première animation` par le widget first_party quand celui-ci est visible;
  - guards agenda/bibliotheque et garde date branches sur l'eligibilite first_party commune;
  - contexte `venue` / `event` deduit de la typologie du compte eligible.
- [x] Pivot:
  - affichage limite aux sessions officielles de la premiere date future;
  - comptes actifs sans CTA `Choisir ma formule`, essai gratuit ou commande;
  - bloc final neutre `Tes sessions sont prêtes` conserve avec les actions utiles de preparation et d'annulation.
- [x] Verification:
  - `php -l` OK sur helpers, Home, tunnel first_party et choix de date;
  - `git diff --check` OK.

## PATCH 2026-06-08 - First_party bibliotheque: theme choisi vers etape 3
- [x] Modales de redirection:
  - textes differencies entre agenda generique et bibliotheque avec contenu choisi;
  - variantes `venue` / `event` et `playlist` / `quiz` couvertes;
  - wording limite a l'entree dans le tunnel, sans laisser croire a une creation de session;
  - CTA principal stabilise pour les libelles longs.
- [x] Flux bibliotheque -> first_party:
  - selection d'une playlist ou d'un quiz conservee dans `$_SESSION[first_party_onboarding_v1_{id_client}]`;
  - redirection directe vers l'etape 3 du tunnel first_party;
  - contenu choisi visible en premiere session et conserve meme s'il ne fait pas partie du mini-catalogue auto;
  - validation serveur alignee sur la map enrichie avec IDs preselectionnes;
  - creation officielle toujours reportee a la validation finale du tunnel.
- [x] Quiz bibliotheque:
  - clic `Créer un Cotton Quiz` conserve le flux builder et l'ajout de series dans l'UI bibliotheque;
  - modale first_party affichee seulement a la validation `clib-builder-banner`;
  - ordre des series du builder preserve via `ordered_ids` avant seed du tunnel.
- [x] Etape 3:
  - intro specifique quand une selection bibliotheque existe, avec lien direct vers l'etape 2 pour adapter le rythme;
  - CTA `Valider ce thème` pour Blind Test/Bingo en une session, sinon `Valider ces thèmes`;
  - message reseau masque pour une selection bibliotheque seule, mais disponible si le rythme repasse a 2/3 sessions;
  - modification depuis la bibliotheque en contexte first_party masque la carte d'ajout de contenu perso dans le filtre `mine`.
- [x] Verification:
  - `php -l` OK sur les fichiers PHP touches du tunnel et de la bibliotheque;
  - `git diff --check` OK;
  - pas de recette navigateur finale apres le correctif CSS du CTA.

## PATCH 2026-06-08 - First_party Quiz: presentation par serie
- [x] Etape 3 Quiz:
  - auto-selection existante conservee;
  - suppression du CTA global `Modifier` sur la carte session Quiz;
  - rendu d'une seule miniature d'illustration par session;
  - miniature calculee avec le helper applicatif `app_jeu_get_detail(5, ..., $lot_ids)` pour reutiliser le choix de visuel multi-series;
  - liste des series thematiques avec titre, descriptif, badges et CTA `Modifier` par serie.
- [x] Remplacement:
  - le clic `Modifier` ouvre le mini-catalogue integre du tunnel;
  - le remplacement cible uniquement le slot de la serie cliquee;
  - le lien `Voir plus de séries thématiques` conserve `session_index` et `slot_index` pour choisir dans le catalogue complet.
- [x] Recapitulatif:
  - presentation Quiz alignee sur image unique + liste;
  - aucun CTA de modification inactif dans le recapitulatif.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK;
  - `git diff --check -- web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK.

## PATCH 2026-06-05 - First_party: astuce contenus personnels et priorite edition
- [x] Etape 3:
  - ajout d'une astuce contextuelle sous le hint de modification de session;
  - wording venue: utilisation lors de `ta première soirée`;
  - wording event: utilisation lors de `ton événement`;
  - distinction jeu: `tes playlists` pour Blind Test/Bingo, `tes séries thématiques` pour Quiz.
- [x] Lien `Les jeux`:
  - URL retenue: `clib_theme_mine_list_url_get($selected_game)`;
  - fallback defensif: `/extranet/games/library`;
  - pas de parametre sensible expose.
- [x] Liste de modification manuelle:
  - recuperation des contenus personnels `mine` compatibles via `clib_list_get(...)`;
  - filtrage par proprietaire courant et garde d'usage personnel existant;
  - affichage dans une liste unique sans section personnelle dediee;
  - liste visible bornee a 12 contenus maximum par panneau de modification;
  - contenus personnels affiches bornes aux 2 plus recemment crees pour ne pas ecraser les contenus reseau/recommandes;
  - contenus reseau/recommandes conserves apres les contenus personnels;
  - auto-selection initiale inchangee: elle continue d'utiliser `ec_first_party_featured_contents_get(...)`.
- [x] Garde-fous:
  - pas de retour automatique depuis la bibliotheque;
  - pas d'ouverture du catalogue complet dans le tunnel;
  - pas de changement de creation des sessions;
  - pas de migration SQL.
- [x] Lien catalogue complet:
  - pas de route interne `/extranet/onboarding/first-party?catalog=1`;
  - lien bas de mini-catalogue `Voir plus de playlists` pour Blind Test/Bingo;
  - lien bas de mini-catalogue `Voir plus de séries thématiques` pour Quiz;
  - URL bibliotheque du jeu avec `from=first_party`, `session_index` et `slot_index` Quiz;
  - propagation explicite de ce contexte sur les liens de fiche detail pour conserver le CTA `Choisir`;
  - fiche detail bibliotheque avec CTA `Choisir`, via POST `content_library_first_party_choose`;
  - remplacement uniquement de l'etat temporaire `$_SESSION[first_party_onboarding_v1_{id_client}]`;
  - chaque serie Quiz auto affiche un CTA `Modifier` qui ouvre le mini-catalogue integre du tunnel et cible le slot de la serie;
  - aucune creation/modification de session officielle avant validation finale.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK;
  - `git diff --check` OK.

## PATCH 2026-06-05 - First_party: annulation reset et redirection Home
- [x] Annulation pivot:
  - apres annulation confirmee, reset explicite de `$_SESSION[first_party_onboarding_v1_{id_client}]`;
  - redirection Home via `redir('/extranet/dashboard')` pour couvrir le cas ou le layout a deja envoye du HTML;
  - fallback `header()` puis meta refresh conserve si `redir()` n'est pas disponible.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK;
  - `git diff --check` OK.

## PATCH 2026-06-05 - First_party: finitions premier evenement
- [x] Wording:
  - variante `event` harmonisee en `premier événement` sur le widget Home, les copies du tunnel/pivot et les controles de programmation;
  - phrase de modale d'annulation contextualisee: `première soirée` pour `venue`, `premier événement` pour `event`.
- [x] Pivot:
  - les intitules cliquables de sessions dans `Partage les liens des sessions` forcent la couleur de typologie first_party, y compris `visited` et `hover`;
  - apres annulation confirmee, redirection vers `/extranet/dashboard` au lieu de rester dans le tunnel first_party.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_home_first_party_onboarding.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_first_party_helpers.php` OK;
  - `git diff --check` OK.

## PATCH 2026-06-05 - First_party: couleurs, offres et gardes INS
- [x] Typologie:
  - ajout de helpers `ec_first_party_typology_color_id_get(...)`, `ec_first_party_typology_button_class_get(...)` et `ec_first_party_typology_offer_url_get(...)`;
  - mapping aligne sur les widgets ecommerce Home: CHR/lieux publics `btn-color-20`, evenement `btn-color-22`, particulier `btn-color-21`;
  - CTA final `Choisir ma formule` du pivot route vers abonnement/evenement/particulier selon `id_typologie`.
- [x] UI first_party:
  - widget Home et tunnel utilisent une classe couleur typologie;
  - styles first_party convertis en variables CSS pour eviter le violet abonnement sur les variantes evenement/particulier;
  - CTA principaux du tunnel et du widget reprennent la classe bouton typologie.
- [x] Gardes de programmation:
  - blocage de creation officielle avant parcours first_party et garde date `<=` premiere session officielle future etendus a tous les comptes `INS` eligibles hors siege reseau/restreint;
  - messages de blocage branches via `ec_first_party_preparation_control_copy_get(...)` pour conserver le wording premiere soiree en CHR et afficher evenement pour les autres INS;
  - CTA Nouvelle session, bibliotheque, script de sauvegarde et formulaire de programmation utilisent ces copies communes.
- [x] Verification:
  - `php -l` OK sur helpers, Home, widget first_party, tunnel first_party, setting session, CTA session, bibliotheque et start script;
  - `git diff --check` OK.

## PATCH 2026-06-05 - First_party: extension event pour INS non CHR
- [x] Helpers first_party:
  - ajout de `ec_first_party_is_ins_eligible_account(...)` pour couvrir tous les comptes `INS` hors siege reseau/restreint;
  - ajout de `ec_first_party_context_get(...)` avec contexte `venue` pour les typologies CHR/lieux publics existantes et `event` pour les autres `INS`;
  - conservation de `ec_first_party_is_ins_chr_account(...)` pour les gardes CHR existants, notamment programmation hors tunnel.
- [x] Home EC:
  - orchestration basee sur le contexte first_party plutot que sur le seul `INS` CHR;
  - widget initial event: `Prépare ton événement Cotton`, reassurance et CTA `Préparer mon événement`;
  - widget pret event: `Ton événement Cotton est prêt !`, CTA `Voir mon événement`;
  - wording venue conserve via la branche `venue`.
- [x] Tunnel `/extranet/onboarding/first-party`:
  - parcours commun conserve: jeu, rythme, themes, date/horaires, recapitulatif, creation finale;
  - labels/textes centralises par contexte `venue` / `event`;
  - variante event sans essai gratuit, rentabilite, clients, etablissement, consommation ou QR permanent;
  - priorite des contenus reseau conservee dans les deux contextes avec message adapte;
  - tracking existant conserve avec payload `first_party_context`.
- [x] Pivot:
  - variante event `Ton événement Cotton est prêt !`;
  - bloc formule generique `Ta formule Cotton`;
  - liens de sessions conserves comme pages dediees/liens utiles;
  - Media Kit conserve;
  - bloc QR permanent masque en contexte event;
  - annulation adaptee en `Annuler cet événement`.
- [x] Garde-fous:
  - aucune migration SQL;
  - aucune route nouvelle;
  - creation de sessions officielles inchangee;
  - blocage de programmation hors tunnel CHR conserve sans extension implicite aux autres INS.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_first_party_helpers.php` OK;
  - `php -l web/ec/modules/communication/home/ec_home_index.php` OK;
  - `php -l web/ec/modules/widget/ec_widget_home_first_party_onboarding.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK;
  - `git diff --check -- web/ec/modules/tunnel/start/ec_first_party_helpers.php web/ec/modules/communication/home/ec_home_index.php web/ec/modules/widget/ec_widget_home_first_party_onboarding.php web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK.

## PATCH 2026-06-05 - First_party: priorite contenus reseau etape 3
- [x] Audit reseau:
  - affiliation affiliee lue via `id_client_reseau > 0` et different du client courant;
  - siege reseau distingue via `flag_client_reseau_siege=1`;
  - contenus reseau compatibles recuperes via `clib_network_share_ids_for_scope_get('affiliate', $game, $client_detail)`;
  - objets catalogue relus par jeu avec `clib_item_get(...)`, sans mapping fragile.
- [x] Tunnel `/extranet/onboarding/first-party`:
  - ajout d'un getter first_party des contenus reseau compatibles;
  - priorisation reseau avant `A la une` Cotton/Communaute;
  - deduplication par ID en conservant le badge reseau;
  - validation serveur POST alignee sur la map enrichie;
  - auto-selection remplie d'abord par les contenus reseau, puis par le fallback existant.
- [x] UI etape 3:
  - badge `Sélection de ton réseau` sur les contenus reseau;
  - texte d'aide affiche seulement si des contenus reseau existent;
  - aucun message d'absence si le reseau n'a pas de contenu compatible.
- [x] Garde-fous:
  - aucune migration SQL;
  - aucun changement de droits reseau;
  - aucun changement widgets Home, programmation hors tunnel, essai gratuit, creation de sessions, eligibilite, facturation ou dates;
  - fallback inchange pour sans reseau ou sans contenu reseau compatible.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK;
  - `git diff --check -- web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK.

## PATCH 2026-06-05 - First_party: programmation standard apres premiere soiree
- [x] Helpers first_party:
  - separation de l'eligibilite `INS` CHR et du blocage avant premiere soiree;
  - ajout d'un helper premiere session/date officielle future;
  - `ec_first_party_programming_blocked_for_current_client(...)` borne au cas `INS` CHR sans session officielle future complete et en ligne.
- [x] Bibliotheque / fiche:
  - CTA naturel de programmation conserve;
  - interception serveur des modes officiels seulement avant premiere soiree;
  - notice douce avec lien vers `/extranet/onboarding/first-party`;
  - demos conservees.
- [x] Programmation:
  - `session_setting` refuse une date officielle `<=` premiere soiree future;
  - `session_setting_multi` refuse toute la soumission si une occurrence est interdite;
  - aucune creation partielle dans le multi-date avant validation;
  - garde front leger `minDate = J+1` et message pres du choix de date.
- [x] Garde-fous:
  - pas de migration SQL;
  - pas de marqueur DB `first_party`;
  - pas de changement offres / essai gratuit / facturation;
  - aucun effet attendu pour ABN/PAK/CSO ou non-CHR.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_first_party_helpers.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_script.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK;
  - `php -l web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK;
  - `php -l web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK.

## PATCH 2026-06-05 - Pivot first_party: confirmation modale annulation
- [x] Annulation de soiree:
  - le clic `Annuler cette soirée` ouvre toujours une modale Bootstrap de confirmation;
  - la confirmation est demandee meme sans participation liee aux sessions;
  - si des participations existent, la modale affiche un avertissement dedie;
  - le POST serveur refuse une annulation sans confirmation explicite;
  - l'ancien `window.confirm(...)` conditionnel est retire.
- [x] Garde-fous:
  - aucune modification d'eligibilite;
  - aucune modification de creation ou edition de sessions;
  - aucune modification offres / essai gratuit.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK.

## PATCH 2026-06-05 - Home first_party: widget plus visible et rassurant
- [x] Audit prealable:
  - affichage borne aux comptes `INS` CHR via `ec_first_party_is_ins_chr_account(...)`;
  - etat onboarding si aucune session officielle future/non passee;
  - etat preparation si au moins une session officielle future/non passee;
  - CTA conserve vers `/extranet/onboarding/first-party`.
- [x] Widget `ec_widget_home_first_party_onboarding.php`:
  - textes remplaces pour les deux etats Home demandes;
  - texte et CTA de l'etat soiree programmee ajustes en `Faire venir mes joueurs →`;
  - micro-rassurance ajoutee;
  - carte entiere rendue cliquable vers `/extranet/onboarding/first-party` avec un seul lien HTML et CTA visuel interne;
  - mini-visuel sans session officielle conserve en trois intentions, sans libelle `En 3 étapes` ni numerotation;
  - numerotation remplacee par pictos SVG doux;
  - etat soiree programmee remplace par un resume concret date/sessions/horaires/themes quand les donnees sont disponibles;
  - resume enrichi avec titre `Ta soirée programmée`, sans lien secondaire;
  - pour les sessions Cotton Quiz, le resume prefixe les libelles compacts en `Cotton Quiz N série(s)`;
  - resume borne aux 3 premieres sessions avec ligne `+ x autre(s) session(s)`;
  - carte pleine largeur rendue plus visible avec fond discret, bordure, halo/ombre et CTA contraste;
  - rendu mobile adapte en colonne.
- [x] Garde-fous:
  - aucune modification d'eligibilite INS CHR;
  - aucune ouverture aux INS non CHR, ABN ou PAK;
  - aucune modification du tunnel, des offres, de l'essai gratuit ou de la creation de sessions.
- [x] Verification:
  - `php -l web/ec/modules/widget/ec_widget_home_first_party_onboarding.php` OK;
  - `php -l web/ec/modules/communication/home/ec_home_index.php` OK.

## PATCH 2026-06-05 - Programmation: datepicker Cotton first_party et agenda quick
- [x] Tunnel first_party:
  - date etape 4 en `flatpickerdatetime`;
  - date initiale a J+5;
  - horaires en selects harmonises au quart d'heure;
  - horaires par defaut `19:00`, `19:45`, `20:30`.
- [x] Agenda quick:
  - dates libres en `flatpickerdatetime`;
  - date de fin de recurrence en `flatpickerdatetime`;
  - initialisation des datepickers pour les lignes ajoutees dynamiquement.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK;
  - `php -l web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK.

## PATCH 2026-06-05 - Home Nouveautes: pastilles jeu mobiles
- [x] Widget `ec_widget_home_latest_game_news.php`:
  - pastilles jeu bornees dans leur image;
  - libelles longs tronques proprement;
  - taille/padding/position ajustes sous `575.98px`.
- [x] Verification:
  - `php -l web/ec/modules/widget/ec_widget_home_latest_game_news.php` OK.

## PATCH 2026-06-05 - Home: masquer Nouveautes si first_party visible
- [x] Home EC:
  - ajout de `$home_first_party_widget_visible`;
  - rendu du widget first_party pilote par ce booleen;
  - widget `Nouveautés Cotton` desactive quand ce booleen est vrai;
  - exclusion independante de la regle metier actuelle pour suivre les futurs elargissements.
- [x] Verification:
  - `php -l web/ec/modules/communication/home/ec_home_index.php` OK.

## PATCH 2026-06-05 - Agenda sessions: CTA `Préparer` avant fenetre active
- [x] Cartes agenda EC Pro:
  - `Préparer` affiche avant la fenetre active pour les sessions officielles non archivees `4/5/6`;
  - aucune contrainte sur la presence d'une offre effective active pour ce libelle;
  - `Ouvrir le jeu` conserve quand la fenetre est ouverte;
  - icone launcher existante conservee;
  - comportement apres fenetre conserve.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php` OK.

## PATCH 2026-06-05 - First_party: thematiques choisies allegees
- [x] Etape 3:
  - mini-cartes de thematiques sans fond gris, bordure ni padding dedies;
  - grille en pleine largeur quand une seule thematique est choisie pour une session.
- [x] Etape 5:
  - meme rendu allege pour les thematiques recapitulatives;
  - mention `Tu pourras encore personnaliser...` rendue en texte simple sans encadrement.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK.

## PATCH 2026-06-05 - Pivot first_party: CTA formule responsive mobile
- [x] Footer `Ta formule d'essai gratuit`:
  - CTA desktop `Choisir ma formule d'essai gratuit` conserve;
  - libelle mobile raccourci en `Choisir ma formule`;
  - largeur bornee a la carte sur mobile;
  - padding et taille reduits sous `575.98px`;
  - action et URL existantes conservees.
- [x] Verification:
  - `php -l web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` OK.

## PATCH 2026-06-05 - Pivot first_party: series Quiz et Media Kit cible
- [x] Cartes sessions programmees:
  - extraction des titres de series Quiz via `app_cotton_quiz_get_session_series_meta(...)`;
  - affichage succinct en liste `Série N : titre` quand les noms existent;
  - Blind Test et Bingo conservent leur affichage existant;
  - fallback conserve vers le libelle compact existant.
- [x] Liens d'inscription:
  - titre public separe de l'affichage carte;
  - libelle Quiz prefixe en `Cotton Quiz N séries`;
  - copie de lien existante conservee.
- [x] Media Kit:
  - visuel de la carte adapte au jeu programme;
  - carte convertie en bouton accessible clavier;
  - ouverture d'une modale ciblee sur le widget Media Kit du jeu concerne uniquement.
- [x] Garde-fous:
  - aucune route ajoutee;
  - aucune migration SQL;
  - aucune modification de la creation des sessions;
  - liens personnalisation/test, QR code, copie et annulation conserves.

## PATCH 2026-06-04 - First_party: recapitulatif integre en etape 5
- [x] Tunnel:
  - recapitulatif transforme en `Étape 5`;
  - etape 5 integree au flux visuel commun des etapes 1 a 4;
  - etape 5 affichee fermee des le debut du parcours;
  - titre visible `Récapitulatif`;
  - texte d'introduction oriente verification avant programmation officielle.
- [x] Resume:
  - date de la soiree affichee;
  - nombre de sessions affiche;
  - jeu choisi affiche;
  - synthese du rythme ajoutee;
  - horaire et type de jeu rappeles par session;
  - contenus/themes et visuels disponibles conserves via les mini-cartes existantes.
- [x] Validation finale:
  - CTA principal renomme `Programmer ma soirée`;
  - CTAs separes de modification de l'etape 5 remplaces par un unique `Recommencer`;
  - POST final conserve sur l'action existante `create_sessions`;
  - creation officielle uniquement apres validation de l'etape 5.
- [x] Navigation:
  - etapes 1 a 4 visibles fermees et modifiables quand l'etape 5 est atteinte;
  - CTA `Retour au tableau de bord` supprime du tunnel de preparation;
  - session PHP temporaire `first_party_onboarding_v1_{id_client}` conservee;
  - aucune migration SQL.
- [x] Garde-fous:
  - page pivot post-creation non modifiee;
  - rappel formule d'essai gratuit retire de l'etape 5;
  - tracking `first_party_summary_view` conserve;
  - aucune route ni dependance front ajoutee.

## PATCH 2026-06-04 - Pivot first_party: hierarchie d'actions et allegement UI
- [x] Hero:
  - titre stabilise `Ta soirée Cotton est prête !`;
  - texte oriente preparation, personnalisation, communication et suivi avant le jour J;
  - rappel sans bouton indiquant que les sessions seront lancables une fois la formule d'essai gratuit choisie.
- [x] Cartes sessions:
  - cartes entieres cliquables vers la preparation/test, accessibles clavier;
  - CTA transforme en lien discret de bas de carte `Personnaliser et tester →`;
  - libelle de comptage harmonise en `participation(s)` et etat vide rendu secondaire.
- [x] Section participants:
  - titre `Les participants`;
  - cartes `Prépare tes supports`, `Partage les liens d'inscription`, `Affiche ton QR code` conservees;
  - Media Kit et QR code restent des cartes entierement cliquables avec lien discret de bas de carte;
  - la carte liens n'est pas cliquable globalement et garde une copie par session via icone;
  - les trois cartes partagent une zone visuelle commune pour aligner les titres.
- [x] Memo jour J:
  - section legere `Le jour J, comment ça se passe ?`;
  - trois etapes compactes `Avant la session`, `Pendant le jeu`, `Après la session`;
  - visuel unique a droite depuis `/fo/images/solutions/features/feature-experience-joueur-smartphone-1.jpg`;
  - astuces discretes sous les etapes, titre violet.
- [x] Footer formule:
  - remplacement des anciens blocs bas de page par un footer CTA `Ta formule d'essai gratuit`;
  - CTA principal violet `Choisir ma formule d'essai gratuit`;
  - action destructive `Annuler cette soirée` maintenue secondaire;
  - confirmation conservee uniquement si des participations existent.
- [x] Allegement visuel:
  - sections internes moins encadrees pour eviter l'effet bloc dans bloc;
  - gaps verticaux/horizontaux augmentes;
  - cartes moins ombrees;
  - conteneur `.ec-first-party-page` ouvert en pleine largeur disponible.
- [x] Garde-fous:
  - aucune route modifiee;
  - aucune migration SQL;
  - aucune logique metier modifiee;
  - liens Media Kit, QR code, copie, preparation/demo, formule et annulation conserves.

## PATCH 2026-06-04 - Games/Pro: preparation officielle sans offre active
- [x] Games `/master/{token}`:
  - entree autorisee pour session officielle future/non passee sans offre active;
  - `AppConfig` expose `isOfficialSession`, `sessionChronology`, `hasActiveOffer`, `canLaunchOfficial`, `isPreparationMode`, URLs offre/demo;
  - sessions passees sans offre non rouvertes en preparation.
- [x] CTA organisateur:
  - hors fenetre active: `Tester en démo` + modale de confirmation;
  - fenetre active + offre active: lancement normal;
  - fenetre active + sans offre active: bouton `Lancer le jeu` + modale `Choisir une offre`;
  - demos non bloquees par l'offre.
- [x] Verrous serveur:
  - remote officielle bloquee si session officielle non lancable;
  - actions AJAX runtime sensibles bloquees hors offre/fenetre active;
  - sauvegardes de preparation conservees.
- [x] Pro/pivot:
  - cartes sessions modernes non passees vers `Préparer la session`;
  - pivot `first_party` simplifiee avec CTA `Préparer la session`;
  - bloc communication et activation remis en avant;
  - contexte `nav_ctx=first_party` propage vers Games pour retour quit officiel/demo sur la pivot;
  - annulation de soiree via suppression des sessions officielles futures/non passees affichees.
- [x] Duplication demo:
  - demo dupliquee depuis une officielle avec retour pivot si contexte `first_party`;
  - clone demo force en non publie/prive (`flag_session_demo=1`, `flag_session_privee=1`, `online=0`).
- [ ] Hors V1:
  - synchronisation demo -> officielle;
  - refonte WebSocket complete.

## PATCH 2026-06-03 - First_party INS CHR: sessions futures et blocage hors parcours
- [x] Source de verite:
  - helper partage `ec_first_party_helpers.php`;
  - requete uniquement sur `championnats_sessions`;
  - sessions qualifiantes limitees a `flag_session_demo=0`, `flag_configuration_complete=1`, `online=1`, `DATE(date) >= CURDATE()`;
  - aucune dependance a `clients_logs`, logs `first_party` ou migration SQL.
- [x] Etats Home/pivot:
  - `INS` CHR + session officielle future/non passee: widget `Ta soirée Cotton est prête !` et page pivot en preparation;
  - `INS` CHR + sessions officielles seulement passees: retour au widget initial;
  - `INS` CHR + aucune session officielle: widget initial.
- [x] Blocages:
  - creations officielles libres bloquees via `session_init` officiel, `session_setting_multi`, `content_library_program` et continuation builder Quiz;
  - demos, `session_duplicate`, application de theme sur session existante, consultation, reglages et design restent autorises.
- [x] Regle demo:
  - la demo est generee depuis l'officielle;
  - aucune synchronisation inverse demo -> officielle n'est attendue.

## PATCH 2026-06-03 - Onboarding premiere soiree: Lot 3B creation officielle et pivot essai
- [x] Correctif livre:
  - le CTA final `Créer mes sessions` cree 1, 2 ou 3 sessions officielles depuis l'etat temporaire;
  - validation finale serveur de `game`, `session_count`, `party_date`, horaires croissants et contenus;
  - Blind Test: session `id_type_produit=4`, playlist catalogue en `id_produit`, `id_format=2`;
  - Bingo Musical: session `id_type_produit=6`, playlist client creee depuis le contenu catalogue, `id_format=2`;
  - Quiz: session `id_type_produit=5`, `id_produit` premier lot, `lot_ids=L...`, session complete;
  - page post-creation `Ta soirée est prête !` avec rappel synthetique et blocs activation/outils, personnalisation, frais/realisme, premiers signaux.
- [x] Idempotence:
  - token final `creation_token`;
  - stockage `created_session_ids`;
  - refresh/double-clic/retour POST affichent la page post-creation si les IDs existent deja.
- [x] Strategie echec partiel:
  - validation complete avant toute ecriture;
  - tentative de transaction mysqli quand disponible;
  - nettoyage manuel des sessions creees via `app_session_supprimer(...)`;
  - nettoyage manuel des playlists client Bingo via `app_bingo_musical_playlist_client_supprimer(...)`.
- [x] CTA et limites:
  - CTA essai gratuit vers `/extranet/ecommerce/offers/abonnement/s1/1`;
  - pas d'activation maison;
  - pas de modification checkout;
  - pas de QR code session joueur, lien public reel ou Media Kit telechargeable debloque.
- [ ] Recette DEV:
  - verifier creation 1/2/3 sessions;
  - verifier Blind Test, Bingo Musical, Quiz 1 a 4 themes;
  - verifier double clic et refresh;
  - verifier page pivot et CTA essai.

## PATCH 2026-06-03 - Onboarding premiere soiree: Lot 3A date et horaires
- [x] Correctif livre:
  - ajout de l'etape 4 `Date et horaires` apres validation des themes;
  - collecte temporaire de `party_date` et `scheduled_time` par session;
  - horaires suggeres `20:30`, `21:15`, `22:00`, espacements indicatifs d'environ 45 minutes;
  - recapitulatif de confirmation avec date au format francais et CTA global `Modifier ma soirée`.
- [x] Regle produit documentee:
  - les horaires sont indicatifs et servent surtout a informer les joueurs;
  - le lancement reel pourra rester possible avant ou apres l'horaire annonce;
  - l'avertissement communication s'affiche uniquement si la date choisie laisse moins de 5 jours complets pour communiquer;
  - a 5 jours ou plus, aucun message d'avertissement ou de reassurance n'est affiche;
  - l'avertissement est non bloquant.
- [x] Garde-fous:
  - aucun appel a `app_session_ajouter()`;
  - aucun write dans `championnats_sessions`;
  - CTA `Créer mes sessions` non destructif en attente du Lot 3B.

## PATCH 2026-06-03 - Onboarding premiere soiree: auto-pick moment/populaire
- [x] Correctif livre:
  - separation des listes catalogue `now` et `themes/popular`;
  - auto-pick limite a un premier contenu `du moment`;
  - contenus suivants proposes depuis les plus populaires;
  - pool de modification/validation elargi aux contenus `du moment` + populaires;
  - fallback sans doublon si le catalogue populaire est trop court.
- [x] Garde-fous:
  - aucune creation de session officielle;
  - aucun write dans `championnats_sessions`;
  - validations serveur existantes conservees.

## PATCH 2026-06-03 - Onboarding premiere soiree: Lot 2 ter UX
- [x] Correctif livre:
  - en-tete tunnel reformule autour de la premiere soiree, sans label technique;
  - affichage progressif des etapes avec resumes replies;
  - apres validation des themes, affichage du seul recapitulatif final;
  - wording etapes 1, 2 et 3 ajuste;
  - titre de l'etape 3 adapte selon jeu et nombre de sessions;
  - miniatures de jeux ajoutees depuis les visuels deja utilises par la home bibliotheque;
  - themes selectionnes affiches en mini-cartes image + titre + description courte;
  - modification d'une session avec mise a jour front immediate de la zone compacte;
  - recapitulatif final enrichi avec intentions et mini-cartes.
- [x] Garde-fous:
  - validations serveur Lot 2 bis conservees;
  - aucun appel a `app_session_ajouter()`;
  - aucun write dans `championnats_sessions`;
  - aucun checkout, essai gratuit, QR code ou lien public reel.
- [ ] Recette DEV:
  - verifier le parcours progressif initial, apres jeu, apres rythme et apres validation themes;
  - verifier les miniatures des trois jeux contre `/extranet/games/library`;
  - verifier la mise a jour immediate radio Blind/Bingo et checkbox Quiz;
  - verifier les boutons `Modifier` / `Modifier mes choix`.

## PATCH 2026-06-03 - Onboarding premiere soiree: Lot 2 bis correctif
- [x] Correctif livre:
  - l'etape 2 accepte maintenant `1`, `2` ou `3` sessions, avec `2` conserve en choix recommande par defaut;
  - la validation de l'etape 2 genere automatiquement une proposition de themes `A la une`;
  - l'etape 3 affiche des cartes compactes par session et n'ouvre la liste de contenus qu'apres clic sur `Modifier`;
  - le CTA devient `Valider ces thèmes`;
  - le Quiz accepte 1 a 4 themes par session, Blind Test et Bingo Musical gardent un seul contenu par session.
- [x] Etat temporaire:
  - migration de l'ancien `content_ids` vers `sessions`;
  - nouvelle forme: `game`, `session_count`, `sessions[index, content_ids[]]`, `themes_validated`;
  - reset propre de la selection quand le jeu ou le rythme change.
- [x] Audit selection automatique:
  - `ec_start_script.php` contient des helpers de ranking/auto-pick, mais le handler cree ensuite des sessions officielles;
  - le correctif onboarding reprend le principe de proposition automatique sans inclure ce handler et sans lire/ecrire `championnats_sessions`;
  - source catalogue bornee a `clib_list_get(..., 'now')`.
- [x] Invariants:
  - aucun appel a `app_session_ajouter()`;
  - aucun write dans `championnats_sessions`;
  - aucun checkout ni essai gratuit modifie;
  - aucun QR code session joueur ni lien public reel.
- [ ] Recette DEV:
  - verifier les parcours `1`, `2`, `3` sessions pour Blind Test, Bingo et Quiz;
  - verifier que le panneau `Modifier` reste ferme par defaut;
  - verifier les limites Quiz 1 a 4 themes et le rejet des doublons inter-sessions;
  - verifier le fallback si trop peu de contenus `A la une` existent.

## PATCH 2026-06-03 - Onboarding premiere soiree: Lot 2 V1 parcours guide
- [x] Correctif livre:
  - transformation de `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php` en parcours guide;
  - etape 1: choix d'un jeu principal parmi Blind Test, Bingo Musical, Quiz;
  - etape 2: choix du rythme 2 ou 3 sessions;
  - etape 3: choix des themes de sessions depuis les contenus `A la une` du jeu selectionne;
  - recapitulatif final avec CTA Lot 3 desactive `Programmer mes horaires`.
- [x] Strategie etat temporaire:
  - stockage PHP session par compte: `first_party_onboarding_v1_{id_client}`;
  - donnees conservees: jeu, nombre de sessions, IDs contenus choisis;
  - aucun schema ou objet metier lourd ajoute.
- [x] Catalogue:
  - utilisation de `clib_list_get(..., 'now')` via `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`;
  - recuperation bornee `cotton` + `community`, dedupliquee par ID de contenu;
  - validation serveur des IDs contre la selection `A la une` recalculee.
- [x] Invariants:
  - aucun appel a `app_session_ajouter()`;
  - aucun write dans `championnats_sessions`;
  - aucun checkout ni essai gratuit modifie;
  - aucun QR code session joueur ni lien de partage reel.
- [ ] Recette DEV:
  - verifier le tunnel pour un compte eligible;
  - verifier filtrage des contenus par jeu;
  - verifier exigences 2 contenus pour 2 sessions et 3 contenus pour 3 sessions;
  - verifier rejet serveur des doublons, jeux invalides, nombres invalides et contenus hors selection;
  - verifier l'etat vide si aucun contenu `A la une` n'est disponible.

## PATCH 2026-06-03 - Home EC: Lot 1 V1 onboarding premiere soiree
- [x] Correctif livre:
  - ajout du widget `pro/web/ec/modules/widget/ec_widget_home_first_party_onboarding.php`;
  - integration prioritaire dans `pro/web/ec/modules/communication/home/ec_home_index.php`, avant la grille principale et avant `Nouveautés Cotton`;
  - ajout de la route `/extranet/onboarding/first-party` dans `pro/web/.htaccess`;
  - ajout de la page minimale `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`.
- [x] Regle d'eligibilite V1:
  - pipeline client `INS`;
  - typologie client dans `[1, 8]`;
  - `client_session_official_programmed_count == 0`;
  - client non siege reseau.
- [x] Invariants V1:
  - aucune creation de session;
  - aucun write sur `championnats_sessions`;
  - aucune activation d'essai gratuit;
  - aucune modification checkout;
  - aucune promesse de QR code session joueur ni de lien reel avant activation.
- [x] Tracking:
  - push front `first_party_onboarding_view` au rendu du bloc;
  - push front `first_party_onboarding_start` au clic CTA.
- [ ] Recette DEV:
  - verifier affichage pour un compte INS typologie 1 ou 8 sans session officielle;
  - verifier non-affichage pour non INS, typologie hors `[1,8]`, compte avec session officielle complete, et siege reseau;
  - verifier l'ouverture de `/extranet/onboarding/first-party`.

## PATCH 2026-06-02 - Home EC: widget Nouveautes Cotton
- [x] Correctif livre:
  - ajout de `pro/web/ec/modules/widget/ec_widget_home_latest_game_news.php`;
  - ajout du rendu dans `pro/web/ec/modules/communication/home/ec_home_index.php`;
  - affichage limite aux pipes `INS`, `ABN`, `PAK`, `CSO`;
  - variante `wide` pour `INS`/`CSO`, variante compacte pour `ABN`/`PAK`;
  - recuperation des derniers contenus publies/visibles Cotton + Communaute;
  - selection de la derniere playlist Blind Test, puis de la derniere playlist Bingo Musical en excluant l'ID deja retenu;
  - selection de la derniere serie Quiz publiee et exploitable;
  - liens vers les fiches detail bibliotheque, sans demarrer de programmation.
- [x] Correctif UI/performance:
  - suppression du CTA global `Découvrir les nouveautés`;
  - chips jeu alignes sur les classes existantes `bg-color-cotton-blind-test`, `bg-color-bingo-musical`, `bg-color-cotton-quiz`;
  - chip catalogue conserve en style neutre;
  - variante compacte ABN/PAK synchronisee sur la largeur de la premiere ligne de cartes Home;
  - espacement avant widget reduit via le wrapper `.home-latest-game-news-col`;
  - section visuelle allegee sur fond Home, sans wrapper blanc global;
  - grille des cartes en pleine largeur disponible, responsive `3 / 2 / 1`;
  - cartes entieres cliquables vers la fiche detail, avec `Découvrir →` conserve comme texte d'appel;
  - suppression du lien secondaire catalogue sous le CTA fiche detail;
  - recuperation Blind/Bingo mutualisee en une seule requete limitee, puis deduplication par playlist cote PHP;
  - absence de N+1 SQL dans le rendu: les visuels et URLs sont construits par helpers/fichiers.
- [x] Verification locale:
  - `php -l pro/web/ec/modules/widget/ec_widget_home_latest_game_news.php` OK;
  - `php -l pro/web/ec/modules/communication/home/ec_home_index.php` OK.
  - `git -C pro diff --check -- web/ec/modules/communication/home/ec_home_index.php web/ec/modules/widget/ec_widget_home_latest_game_news.php` OK.
- [ ] Recette DEV:
  - verifier la Home en `INS`, `CSO`, `ABN`, `PAK`;
  - verifier que deux cartes Blind/Bingo ne reprennent jamais la meme playlist;
  - verifier que les CTA ouvrent la fiche detail bibliotheque et non le tunnel de programmation.

## PATCH 2026-05-22 - Webhook Stripe: date demande resiliation
- [x] Correctif livre:
  - le webhook Stripe transmet au helper global `subscription.canceled_at` pour dater `user_feedback_events.created_at`;
  - fallback sur `event.created` quand `canceled_at` est absent;
  - l'appel reste non bloquant pour la synchronisation abonnement.
- [x] Verification locale:
  - `php -l pro/web/ec/ec_webhook_stripe_handler.php` OK.
- [ ] Verification recette serveur:
  - declencher une resiliation Stripe depuis le portail;
  - verifier que la ligne `user_feedback_events.created_at` correspond a la date de demande Stripe, pas a l'heure de traitement Cotton.

## PATCH 2026-05-21 - Webhook Stripe: feedback annulation abonnement
- [x] Correctif livre:
  - le handler Stripe `customer.subscription.updated` / `customer.subscription.deleted` appelle la capture feedback annulation;
  - les raisons/commentaires saisis dans le portail Stripe sont transmis a `user_feedback_events`;
  - l'appel est non bloquant pour conserver le flux de synchronisation abonnement existant.
- [x] Verification locale:
  - `php -l pro/web/ec/ec_webhook_stripe_handler.php` OK;
  - `git -C pro diff --check -- web/ec/ec_webhook_stripe_handler.php` OK.
- [ ] Verification recette serveur:
  - simuler ou declencher une resiliation Stripe avec commentaire depuis le portail;
  - verifier que le webhook conserve la sync d'offre existante;
  - verifier l'arrivee du feedback dans le BO `Feedbacks EP/Stripe`.

## PATCH 2026-05-18 - Bibliotheque Quiz: difficulte 3 niveaux et legacy
- [x] Cause identifiee:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` avait commence a normaliser le Quiz en `1=Facile`, `2=Moyen`, `3+=Difficile`;
  - des series Quiz ont deja ete creees depuis le select Pro 3 niveaux, donc changer l'ecriture vers `1/3/5` aurait decale ces contenus;
  - `pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_edit.php` relisait la valeur brute et pouvait faire retomber une valeur historique hors `1..3` sur `Facile`.
- [x] Correctif livre:
  - la convention Pro Quiz reste `1=Facile`, `2=Moyen`, `3=Difficile`;
  - l'editeur de thematique reutilise une normalisation pour preselectionner le bon choix;
  - les anciennes valeurs `4` ou `5` sont affichees temporairement comme `Difficile`;
  - a l'enregistrement Quiz, les 3 choix UI sont conserves en `1`, `2`, `3`;
  - l'adapter Quiz continue de refuser les valeurs hors `1..3` pour les nouvelles sauvegardes.
- [x] Verification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK;
  - `php -l pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_edit.php` OK;
  - `php -l pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_save.php` OK;
  - `php -l pro/web/ec/modules/jeux/bibliotheque/sources/quiz_series.php` OK.
- [ ] Recette DEV:
  - verifier une serie Quiz stockee `difficulte=2`: fiche + editeur `Moyen`;
  - verifier une serie Quiz stockee `difficulte=3`: fiche + editeur `Difficile`;
  - ouvrir une ancienne serie Quiz `difficulte=4` ou `5` et verifier le fallback `Difficile`;
  - preparer un patch donnees dedie pour normaliser le perimetre legacy: ancien `3 -> 2`, anciens `4/5 -> 3`.

## PATCH 2026-05-18 - Home EC TdR: recommandations formats image de marque
- [x] UI ajustee:
  - `pro/web/ec/modules/communication/home/ec_home_index.php`;
  - ajout d'une aide sous `Logo`: format carre recommande, idealement `512 x 512 px`;
  - ajout d'une aide sous `Visuel principal`: image horizontale recommandee, idealement `1600 x 900 px`;
  - conservation de la ligne globale extensions acceptees / poids max serveur.
- [x] Verification:
  - `php -l pro/web/ec/modules/communication/home/ec_home_index.php` OK.
- [ ] Recette DEV:
  - ouvrir la Home EC d'une TdR;
  - ouvrir la modale `Mettre à jour mon image de marque`;
  - verifier que les recommandations sont lisibles sur desktop et mobile.

## PATCH 2026-05-18 - Import Quiz Markdown: ne plus piloter flag_begin/flag_une
- [x] Importeur PRO ajuste:
  - `pro/web/ec/modules/jeux/import/ec_import_quiz.php`;
  - retrait de `flag_begin`, `flag_une` et `online` de l'INSERT `questions_lots`;
  - les valeurs par defaut DB ou reglages editoriaux existants restent responsables de ces champs.
- [x] Invariants:
  - l'import continue de creer la serie en `id_etat=2`, auteur Cotton `id_client_auteur=0`;
  - le statut d'affichage Quiz reste porte par `id_etat=2`, pas par `questions_lots.online`;
  - le `A la une` bibliotheque EC et fallback LP se basent maintenant sur `jour_associe_debut/fin`, pas sur `flag_begin` ni `flag_une`;
  - aucun changement sur l'import des questions, propositions, illustration de serie ou supports image.
- [x] Verification:
  - `php -l pro/web/ec/modules/jeux/import/ec_import_quiz.php` OK.
- [ ] Recette DEV:
  - importer une serie test;
  - verifier que `questions_lots.flag_begin`, `questions_lots.flag_une` et `questions_lots.online` ne sont pas forces par l'importeur;
  - verifier que la serie reste visible selon les regles existantes de bibliotheque/import.

## PATCH 2026-05-18 - Bibliotheque Cotton: tri recent des thematiques du moment
- [x] Cause identifiee:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`;
  - le premier ajustement remplacait trop largement le departage historique par la creation recente;
  - des contenus recents hors periode pouvaient donc remonter dans `A la une` sans etre "En ce moment" ni populaires.
- [x] Correctif livre:
  - conservation du perimetre initial du preset Cotton `A la une`;
  - priorite aux contenus dans la fenetre `jour_associe_debut/fin`;
  - departage par creation recente uniquement entre contenus simultanement du moment: `date_ajout DESC`, puis `id DESC`;
  - retour au departage historique par popularite pour les contenus hors periode;
  - aucun changement du tri Communaute `A la une`.
- [x] Verification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK.
- [ ] Recette DEV:
  - creer ou identifier deux contenus Cotton certifies dont la date du jour est dans `jour_associe_debut/fin`;
  - verifier que le plus recent par `date_ajout` apparait en position 1 dans `A la une`;
  - verifier qu'un contenu hors periode recent ne remonte pas devant un contenu populaire hors periode.

## PATCH 2026-05-18 - Playlist perso: artistes courts acceptes
- [x] Cause identifiee:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`;
  - `pro/web/ec/modules/jeux/bibliotheque/sources/playlists_content.php`;
  - `pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlist_analyze.php`;
  - les garde-fous marquaient un artiste comme incomplet lorsque son nom faisait moins de 3 caracteres.
- [x] Correctif livre:
  - suppression du critere de longueur minimale sur les noms d'artistes;
  - `Nom d’artiste incomplet` reste declenche uniquement si le champ artiste est vide;
  - les signaux existants restent conserves: lien media manquant, titre manquant, termes ambigus, separateurs/parentheses a nettoyer, incoherence avec la source YouTube.
- [x] Verification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK;
  - `php -l pro/web/ec/modules/jeux/bibliotheque/sources/playlists_content.php` OK;
  - `php -l pro/web/ec/modules/jeux/catalogue_playlists/ec_catalogue_playlist_analyze.php` OK.
- [ ] Recette DEV:
  - ajouter une playlist perso contenant au moins un artiste court comme `U2`;
  - verifier que la ligne n'affiche plus `Nom d’artiste incomplet`;
  - verifier qu'un artiste vide reste signale.

## PATCH 2026-05-18 - Import Quiz Markdown images de question localisees
- [x] Importeur PRO ajuste:
  - `pro/web/ec/modules/jeux/import/ec_import_quiz.php`;
  - telechargement serveur des supports `Support type : image` au moment de l'import DB;
  - validation du fichier recu via `getimagesizefromstring`;
  - ecriture dans `/upload/quiz/images/questions/question/` avec nom `q{id_question}---hash.ext`;
  - remplacement de `questions.lien_support` par l'URL Cotton locale;
  - synchronisation best effort de `medias_images`;
  - nettoyage des fichiers supports crees si la transaction d'import echoue.
- [x] Invariants:
  - la preview reste sans ecriture DB;
  - les supports audio, video et YouTube restent stockes comme liens externes;
  - l'illustration generale de serie conserve son import dedie dans `questions_lots/{id_lot}.jpg`;
  - les corrections de support restent a faire dans le Markdown source ou la previsualisation editoriale, pas dans l'importeur.
- [ ] Recette DEV:
  - importer une serie de test avec au moins un support image;
  - verifier que `questions.lien_support` pointe vers `/upload/quiz/images/questions/question/q{id}---...`;
  - verifier que les supports audio/video/YouTube restent des liens externes;
  - verifier l'affichage du support image en bibliotheque et en jeu.

## PATCH 2026-05-15 - Import Quiz Markdown preview et import DB minimal
- [x] Importeur PRO simplifie:
  - `pro/web/ec/modules/jeux/import/ec_import_quiz.php`;
  - suppression de l'upload media automatique et de l'edition des supports en session;
  - restauration d'un CTA DB visible apres preview valide et confirmation explicite.
- [x] Nouveau comportement:
  - upload/collage Markdown;
  - parsing et preview des champs detectes avant toute ecriture;
  - affichage des champs serie detectes: titre, slug, description, niveau, rubrique, categorie, sous-categorie, type, public, format, illustration;
  - affichage des champs question detectes: enonce, propositions, bonne reponse, explication, support type, URL support finale, start/end et note support;
  - import DB minimal des series, questions, propositions et liens supports tels que valides en preview;
  - import de l'illustration de serie en visuel bibliotheque local `cotton_quiz/images/jeux_cotton_quiz/questions_lots/{id_lot}.jpg`;
  - si la serie existe deja, mise a jour bornee du seul visuel bibliotheque local, sans toucher aux questions/propositions;
  - contraste renforce sur titres `h1`-`h6`, liens, textes secondaires, alertes, cases de confirmation et CTA d'import.
- [x] Alertes conservees:
  - titre/rubrique manquants;
  - rubrique non resolue dans `questions_lots_rubriques`;
  - nombre de questions different de 6;
  - propositions, bonne reponse, explication ou support invalides.
- [x] Verification:
  - `php -l pro/web/ec/modules/jeux/import/ec_import_quiz.php` OK.

## PATCH 2026-05-14 - Import Quiz Markdown supports types
- [x] Importeur PRO ajuste:
  - `pro/web/ec/modules/jeux/import/ec_import_quiz.php`;
  - parsing de `Support type`, `Support start`, `Support end`;
  - validation stricte de 6 questions et d'une explication par question.
- [x] Preview supports renforcée:
  - l'utilisateur peut remplacer dans l'importeur le type, l'URL, les timecodes et la note support de chaque question;
  - un bouton de mise a jour reapplique les corrections a la preview sans ecriture DB;
  - l'import definitif utilise la preview corrigee en session;
  - contraste et lisibilite de la page d'import ameliores.
- [x] Types de supports importables:
  - `image` -> `questions.id_type_support=1`, image telechargee et synchronisee dans `medias_images`;
  - `audio` et `youtube_audio` -> `questions.id_type_support=2`;
  - `video`, `youtube` et `youtube_video` -> `questions.id_type_support=3`;
  - `Support` conserve dans `questions.lien_support`.
- [x] Bornes audio/video:
  - `Support start` et `Support end` valides comme secondes entieres;
  - `Support end` doit etre superieur a `Support start`;
  - aucune colonne DB dediee trouvee: les bornes sont preservees dans l'URL stockee via les parametres `start` et `end`.
- [x] Documentation canon mise a jour:
  - previsualisation editoriale obligatoire avant generation du `.md`;
  - garde-fou sur les formulations temporairement vraies;
  - remplacement de la limite "images uniquement V1" par le contrat reel de l'importeur audite.
- [ ] Recette DEV:
  - importer une serie de test avec au moins un support image, un support audio/video direct et un support YouTube;
  - verifier dans le PRO que les liens et types sont relus;
  - verifier en jeu que les supports deja lus par l'app s'affichent sans patch cote `games`.

## DOC 2026-05-14 - Format Markdown agent IA pour import Quiz
- [x] Page canon completee:
  - `documentation/canon/data/cotton-certified-direct-import.md`;
  - ajout d'une section `Format Markdown pour import PRO`.
- [x] Contrat `.md` documente:
  - metadonnees attendues avant la premiere question;
  - format `## Q1`, `Question`, `Propositions`, `Bonne reponse`, `Explication`, `Support`, `Note support`;
  - contraintes exactes pour QCM 4 reponses;
  - regles pour URLs image directes importees automatiquement.
- [x] Garde-fous pour agents IA:
  - ne pas produire de SQL pour le flux PRO Markdown;
  - ne pas utiliser de supports YouTube/audio/video dans la V1;
  - verifier au moins 6 questions et au moins 3 supports image candidats lorsque le theme s'y prete.
- [x] Referentiel rubriques precise:
  - source de verite: liste PRO d'ajout manuel, table `questions_lots_rubriques` active;
  - le `.md` doit contenir le libelle exact dans `Rubrique`;
  - `A choisir dans la preview PRO` est refuse pour un import automatique;
  - la page canon liste maintenant les valeurs utilisables par l'agent IA (`Sport`, `Géographie`, `Affiches & images`, etc.) pour permettre la resolution sans choix manuel.

## PATCH 2026-05-14 - Import admin serie Cotton Quiz depuis Markdown
- [x] Surface PRO ajoutee:
  - route `/extranet/games/import/quiz`;
  - page `pro/web/ec/modules/jeux/import/ec_import_quiz.php`;
  - acces limite au PRO connecte avec `$_SESSION['id_client'] === 10`.
- [x] Workflow V1:
  - upload/collage d'un fichier source Markdown;
  - preview obligatoire sans ecriture DB;
  - confirmation explicite avant import definitif;
  - resolution automatique de la rubrique depuis le Markdown, sans select manuel;
  - blocage si titre ou slug deja existant pour eviter tout ecrasement.
- [x] Import Quiz:
  - creation `questions_lots` Cotton certifie legacy (`id_client_auteur=0`, `id_etat=2`, `flag_validated=1` si disponible);
  - creation des questions dans `questions`;
  - bonne reponse conservee dans `questions.reponse`;
  - trois mauvaises propositions par question dans `questions_propositions`;
  - entree `community_items` ajoutee seulement si la table existe.
- [x] Supports image:
  - les URLs image HTTP(S) du Markdown sont telechargees automatiquement au moment de l'import;
  - validation image avant creation DB;
  - ecriture dans `/upload/quiz/images/questions/question/`;
  - synchronisation `questions.lien_support`, `id_type_support=1` et `medias_images`.
- [x] Illustration thematique:
  - champ Markdown `Illustration` documente et importe;
  - stockage dans le repertoire applicatif des visuels `questions_lots`;
  - ecriture forcee en `.jpg` sous `cotton_quiz/images/jeux_cotton_quiz/questions_lots/{id_lot}.jpg`, compatible bibliotheque PRO et catalogue historique;
  - mode correctif volontaire: si la serie Cotton existe deja, possibilite de mettre a jour uniquement son illustration sans toucher au contenu DB;
  - confirmation explicite des droits: image libre de droits, gratuite, sans condition particuliere et compatible usage commercial Cotton.
- [x] Robustesse telechargement image:
  - telechargement serveur via cURL prioritaire puis fallback stream;
  - headers HTTP plus explicites;
  - message d'erreur detaille avec statut HTTP ou erreur cURL lorsque le serveur ne peut pas telecharger l'image.
- [ ] Recette DEV:
  - tester avec la serie `Histoire de la Coupe du monde`;
  - verifier le blocage d'un slug deja existant;
  - verifier que les 3 images sont visibles dans la bibliotheque et en jeu;
  - verifier le comportement si une URL image est invalide.

## DEV SQL 2026-05-14 - Import serie Cotton Quiz Coupe du monde
- [x] Audit documentaire effectue avant generation:
  - `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`;
  - `canon/data/cotton-certified-direct-import.md`;
  - journal AI Studio raw obligatoire.
- [x] Audit local effectue:
  - DDL local et export/schema: `documentation/canon/data/schema/DDL.sql`, `documentation/dev_cotton_global_0.sql`, `documentation/canon/data/schema/_sources/dev_cotton_global_0.sql`;
  - usages Quiz et bibliotheque: `questions_lots`, `questions`, `questions_propositions`, `community_items`;
  - confirmation code: `questions.reponse` = bonne reponse, `questions_propositions` = mauvaises propositions.
- [x] Script genere:
  - `documentation/tmp/dev_import_quiz_histoire_coupe_du_monde.sql`;
  - import manuel DEV phpMyAdmin uniquement;
  - aucune execution SQL faite par Codex.
- [x] Garde-fous du SQL:
  - reutilisation du slug si relance;
  - blocage si slug existant non Cotton ou lot existant non conforme;
  - resolution DB de la taxonomie Sport/Football;
  - `community_items` insere seulement si la table existe, sans update d'une entree existante.
- [ ] Recette manuelle DEV:
  - importer le SQL dans phpMyAdmin DEV;
  - verifier les SELECT finaux: 6 questions, 18 mauvaises propositions, 24 choix QCM runtime, 3 supports, entree `community_items` si table presente;
  - verifier visuellement que les supports Q1/Q2/Q6 ne revelent pas la reponse.

## DOC 2026-05-14 - Import direct contenus Cotton certifies
- [x] Documentation operationnelle ajoutee:
  - `documentation/canon/data/cotton-certified-direct-import.md`;
  - perimetre: creation editoriale puis import DB direct de playlists Blind Test / Bingo Musical et series Cotton Quiz certifiees.
- [x] Regles documentees:
  - convention legacy fiable `id_client_auteur=0` pour Cotton certifie;
  - `community_items.origin='cotton'` comme compatibilite moderne optionnelle lorsque la table existe et que le flux l'exploite;
  - `DDL.sql` peut etre en retard sur la DB live et le code courant, notamment pour `community_items`;
  - imports transactionnels avec controles pre/post import.
- [x] Indexation agent-first corrigee:
  - ajout de `canon/data/cotton-certified-direct-import.md` dans les liens curates du generateur `SITEMAP.txt`.
- [x] Complements editoriaux 2026-05-14:
  - ajout d'une regle de perennite pour les series Cotton Quiz certifiees;
  - ajout d'une regle d'usage transverse des playlists musicales certifiees Cotton entre Blind Test et Bingo Musical;
  - ajout d'exemples acceptables/non acceptables pour les thematiques evenementielles, notamment football / Coupe du monde.
- [x] Complements qualite Quiz 2026-05-14:
  - ajout d'une regle de contextualisation des questions pour eviter un style trop sec;
  - ajout d'une regle de qualite des mauvaises reponses afin qu'elles restent plausibles mais non contestables;
  - ajout d'une regle de supports multimedia sur au moins 3 questions lorsque le theme s'y prete;
  - ajout d'une regle de proposition de supports multimedia candidats pour validation editoriale avant import;
  - correction de la regle support multimedia: tout support associe a une question Cotton Quiz doit etre compatible avec un affichage pendant la question, sans reveler la bonne reponse;
  - ajout des controles correspondants dans la checklist de validation des series Quiz.
- [ ] Recette documentaire:
  - faire relire la page par Cotton avant premier import production;
  - valider un exemple SQL complet sur environnement non critique.

## NOTE 2026-05-14 - BO contrats reseau hors cadre
- [x] Impact PRO audite:
  - aucun fichier `pro` modifie;
  - le flux `start_delegated_hors_cadre_checkout` et le tunnel `ec_offres_script.php` restent la reference de comparaison;
  - recette attendue: verifier qu'une commande hors cadre depuis l'espace Pro TdR fonctionne toujours apres le correctif BO.

## PATCH 2026-05-13 - Home EC onboarding premiere animation ABN
- [x] Audit confirme dans:
  - `pro/web/ec/ec.php`
  - `pro/web/ec/modules/communication/home/ec_home_index.php`
  - `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
  - `pro/web/ec/modules/widget/ec_widget_client_reseau_resume.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - ajout de l'appel Home a `app_client_home_onboarding_widget_get(...)`, wrapper plus generique du helper historique reseau;
  - simplification du rendu `ec_widget_client_network_affiliate_home.php`;
  - branchement Home EC via le helper central `app_client_network_home_widget_get(...)`;
  - variante `ABN` prioritaire etendue a tout `ABN` sans session officielle deja programmee, pas seulement aucune session a venir;
  - contexte exploitable prioritaire si offre deleguee, jeux reseau selectionnes, design reseau ou operation future cablee;
  - jeux reseau selectionnes suffisants pour contextualiser le widget et pousser le CTA reseau, meme sans offre TdR active;
  - fallback generique Cotton ajoute quand aucun contexte exploitable n'existe;
  - texte CAS 1 adapte selon presence de jeux selectionnes, avec wording neutre hors vocabulaire reseau;
  - CTA CAS 1 remplace par `Je me lance`;
  - chips / benefices CAS 1 retires du payload onboarding et non rendus;
  - stats et lignes ressources du contexte affilie masquees explicitement en mode `onboarding_widget`;
  - largeur du widget onboarding et des bandeaux affilies recalee dynamiquement sur la largeur cumulee de la premiere ligne de widgets situee en dessous;
  - feedback post-animation Home EC recale sur cette meme largeur dynamique et affiche au-dessus du bandeau affilie quand les deux existent;
  - feedback post-animation du detail session archivee passe en pleine largeur pour s'aligner sur les cartes detail/resultats;
  - destination CAS 1 avec jeux reseau vers `library?network_manage=1&from=agenda&mode=library`;
  - destination CAS 1 sans jeux reseau vers `extranet/games/library?from=agenda&mode=library`, pour choisir directement une thematique;
  - conservation de `from=agenda&mode=library` depuis le hub bibliotheque quand l'utilisateur choisit un jeu;
  - variantes `ABN` deja actif / `INS` / `CSO` remplacees par un bandeau commun sans CTA;
  - bandeau commun affiche seulement le titre factuel, les ressources utiles (`Des jeux sont sélectionnés pour toi`, `Un habillage personnalisé s'applique à tes jeux`) et/ou les stats LP significatives;
  - quand stats LP et ressources utiles sont presentes ensemble, le bandeau affiche les stats avant les ressources;
  - rendu mobile du bandeau affilie allege: logo conserve et stats reseau masquees;
  - micro-ajustement du bandeau affilie commun: marge basse legere sous le titre pour separer les lignes de contexte;
  - Home TdR: le premier widget `Ton lien d'affiliation` expose maintenant la LP reseau sur le domaine `www` (`/lp/reseau/{slug}`) et priorise le visuel principal LP reseau en fond, avec fallback sur le visuel statique historique;
  - Home TdR: le lien affiche dans ce widget ouvre maintenant la LP, la copie reste sur le CTA bas, et l'action de gestion assets/couleurs LP est placee au-dessus du lien;
  - Home TdR: ajout d'une entree discrete sur le visuel du premier widget pour ouvrir une modale d'upload `Logo LP reseau` / `Visuel principal LP reseau` et de gestion des deux couleurs LP reseau, avec rappel de diffusion aux affilies;
  - modale Home TdR assets LP: wording allege, libelles `Logo` / `Visuel principal`, largeur desktop augmentee, previews image avant save et champs couleur/reinitialisation rendus lisibles;
  - bloc Home TdR `Animation reseau`: affichage conditionnel des stats reseau issues de `app_client_network_lp_stats_get(...)`, avec les seuils LP existants, et masquage du sous-titre generique si les stats sont presentes;
  - script PRO `client_lp_assets_upload`: reutilisation de `app_client_lp_asset_uploader(...)` et `app_client_lp_colors_save(...)`, garde limitee aux comptes TdR siege;
  - BO client/TdR: ajout d'une action `Reinitialiser` sur chaque couleur LP reseau pour vider explicitement la valeur et restaurer les fallbacks LP;
  - LP publique reseau/operation: suppression des fallbacks logo, visuel et couleurs issus du design reseau; seuls les assets/couleurs LP dedies sont repris avant les fallbacks Cotton;
  - Home TdR: insertion du logo LP TdR en pastille en haut a droite du bloc `Animation reseau` quand l'asset existe;
  - aucun bandeau n'est affiche sur simple rattachement historique ou support seul sans ligne ressource/stat;
  - bandeaux rendus sous le titre Home, avant la grille de widgets;
  - largeur du widget prioritaire et du bandeau ABN actif bornee au rythme de la grille Home (`col-12 col-xxl-9`);
  - largeur du bandeau reassurance `INS`/`CSO` pleine ligne (`col-12`) pour suivre l'emprise complete de la grille no-offer;
  - reprise dans `ec_start_step_1_game.php` de la meme implantation que la Home bibliotheque EC pour l'acces aux jeux reseau pendant le choix du jeu;
  - affichage de cette carte de choix du jeu decouple du helper Home et d'une offre active: compte affilie non siege + contenus reseau partages suffit;
  - carte d'acces aux jeux reseau: priorite au visuel branding reseau, puis au logo LP TdR en pastille centree, puis au fallback `catalogue_contenus.png`, avec hauteur media bornee et fallback catalogue fixe a `220px` desktop / `180px` mobile;
  - hub `Jeux selectionnes` / contenus reseau: priorite au visuel branding reseau dans le bloc haut, puis logo LP TdR en pastille adaptee a la hauteur reelle du bloc et reduite en contexte affilie, fallback conserve sur `catalogue_contenus.png`;
  - depuis le tunnel agenda, lien jeux reseau enrichi en `from=agenda&mode=library` pour conserver la programmation apres choix d'un contenu reseau;
  - depuis la Home bibliotheque EC, conservation de ce contexte uniquement s'il est deja present, sinon maintien du mode consultation;
  - affichage de l'indicateur `Etape 1/4 - Jeu` uniquement sur le hub `Jeux du reseau` quand il est ouvert depuis l'agenda;
  - conservation de `from=agenda&mode=library` sur les retours fiche reseau vers le hub, y compris recommandation reseau et retour builder Quiz;
  - aucun affichage si rattachement reseau seul sans avantage actif.
- [x] Invariants:
  - les widgets TdR siege existants restent inchanges;
  - les regles pipeline, catalogue, design reseau et programmation ne sont pas modifiees;
  - pas de CTA reseau dans les bandeaux `INS`/`CSO` ni `ABN` deja actif;
  - wording commun des bandeaux: `Ton espace Cotton est affilié à : {Nom_contexte}`;
  - rattachement reseau seul sans avantage actif ou signal valorisant retombe sur le fallback generique uniquement pour `ABN` sans session officielle.
- [x] Verification:
  - `php -l pro/web/ec/modules/communication/home/ec_home_index.php`
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `php -l pro/web/ec/modules/widget/ec_widget_client_network_affiliate_home.php`
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php`
  - `php -l global/web/app/modules/entites/clients/app_clients_functions.php`
- [ ] Recette serveur/mobile:
  - verifier les 12 cas produit demandes avec donnees reelles ou fixtures serveur.
- [ ] Limite V1:
  - operation reseau active non cablee: non trouve dans la documentation et pas de source runtime canonique locale identifiee.

## PATCH 2026-05-13 - UTM reseau vers signin contextualise
- [x] Audit confirme dans:
  - `pro/web/.htaccess`
  - `pro/web/ec/ec_sign.php`
  - `pro/web/ec/ec_signin.php`
- [x] Correctif livre:
  - ajout de routes `/utm/reseau/{slug}/signin` et `/utm/reseau/{slug}/{code}/signin`;
  - `ec_sign.php` continue de poser `$_SESSION['id_client_reseau']` et `$_SESSION['id_remise']` si applicables;
  - `sign_action=signin` redirige vers `signin`, sinon le comportement historique redirige vers `signup`;
  - les pages `ec_signup.php` et `ec_signin.php` ne sont pas modifiees.
- [x] Verification:
  - `php -l pro/web/ec/ec_sign.php`
- [ ] Recette navigateur serveur:
  - `/utm/reseau/{slug}` -> signup comme avant;
  - `/utm/reseau/{slug}/signin` -> signin avec habillage et contexte reseau;
  - `/utm/reseau/{slug}/{code}/signin` -> signin avec contexte reseau et remise si code valide.

## PATCH 2026-05-13 - Stripe webhooks: suppression emails livemode=false
- [x] Audit confirme dans:
  - `pro/web/ec/ec_webhook_stripe_handler.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - lecture de `event.livemode` juste apres validation de signature Stripe;
  - `livemode=false` prepare une option de suppression email transmise aux creations de commande/facture;
  - `livemode=true` garde les emails existants;
  - livemode absent/illisible garde les emails existants et logge l'ambiguite;
  - l'email admin final `Stripe > Webhook` est supprime uniquement en `livemode=false`.
- [x] Invariants:
  - webhooks et synchros Stripe inchanges;
  - guards d'idempotence inchanges;
  - pas de deduction via champs Cotton ni via prefixe `[ TEST ]`.
- [x] Verification:
  - `php -l pro/web/ec/ec_webhook_stripe_handler.php`
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-05-12 - Signup/signin affilies: habillage reseau via assets LP TdR
- [x] Audit confirme dans:
  - `pro/web/.htaccess`
  - `pro/web/ec/ec_sign.php`
  - `pro/web/ec/ec_signup.php`
  - `pro/web/ec/ec_signin.php`
  - `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livre:
  - l'habillage se declenche sur `$_SESSION['id_client_reseau']`, quelle que soit l'origine du lien;
  - `signup` et `signin` priorisent logo et visuel LP reseau du compte TdR;
  - le logo TdR est affiche dans une pastille blanche coherente avec la LP reseau;
  - le visuel LP reseau est applique en fond avec filtre integre au `background-image`;
  - le branding signup reseau historique reste fallback element par element;
  - les couleurs LP reseau ne sont pas appliquees au formulaire signup/signin afin d'eviter un risque de lisibilite sans controle de teinte dedie;
  - aucun changement de logique formulaire, CTA, rattachement ou activation incluse.
- [x] Verification:
  - `php -l pro/web/ec/ec_signup.php`
  - `php -l pro/web/ec/ec_signin.php`
  - `php -l global/web/app/modules/entites/clients/app_clients_functions.php`
- [ ] Recette navigateur serveur:
  - `/utm/reseau/{slug}` puis signup avec assets LP complets;
  - lien direct d'affiliation deja resolu en session puis signin;
  - signup/signin standards sans `id_client_reseau`;
  - contexte historique sans assets LP dedies.

## PATCH 2026-05-06 — Affiliation TdR: compte existant via signin
- [x] Audit confirme dans:
  - `www/web/.htaccess`
  - `www/web/fo/fo.php`
  - `pro/web/ec/ec_sign.php`
  - `pro/web/ec/ec_signup.php`
  - `pro/web/ec/ec_signin.php`
  - `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
  - `pro/web/ec/modules/compte/client/ec_client_script.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livre:
  - apres login reussi d'un compte existant, le contexte `id_client_reseau` issu du lien d'affiliation est consomme;
  - le rattachement passe par `app_ecommerce_reseau_affilier_client(..., 'signup_affiliation')`, comme le signup;
  - un compte deja rattache a une autre TdR n'est pas reaffecte automatiquement depuis signin;
  - addendum: ce blocage pose un flash PRO explicite, affiche une seule fois par `ec.php`, sans exposer le nom de l'autre reseau.
- [x] Invariants:
  - affiliation != acces actif;
  - offre propre active prioritaire;
  - aucune creation `hors_cadre` automatique;
  - aucune remise/repricing reseau sur une offre propre;
  - sans support actif, offre cible ou quota, rattachement seul.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php`
  - scenarios A-E verifies statiquement sur le helper central et le post-login.
  - recette manuelle a jouer: compte deja rattache a une autre TdR -> login depuis nouveau lien affiliation -> flash visible, rattachement/offres inchanges.

## PATCH 2026-05-06 — Stripe ABN: recalcul pipeline client apres cloture terminale
- [x] Audit confirme dans:
  - `pro/web/ec/ec_webhook_stripe_handler.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Comportement conserve cote webhook:
  - `checkout.session.completed` et `invoice.paid` ne sont pas modifies;
  - `invoice.payment_failed` reste une relance Stripe sans coupure offre;
  - `customer.subscription.updated` en `past_due` ne modifie pas l'offre Cotton;
  - `cancel_at_period_end=1` ne fait que programmer `date_fin`;
  - seule une souscription Stripe effectivement `canceled` ou `deleted` appelle la cloture terminale.
- [x] Correctif porte par `global`:
  - apres cloture effective de l'offre, le pipeline du client payeur direct est recalcule depuis les offres/acces encore actifs;
  - un client ABN sans autre offre active repasse `CSO`;
  - un client avec une autre offre ABN active reste `ABN`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-29 — Stripe ABN V1.1: CTA portail et retour Cotton
- [x] Correctif livre:
  - le CTA principal des bandeaux `Mon offre` et home PRO pointe maintenant vers le portail Stripe client Cotton, avec `return_url` contenant `stripe_billing_return=1`;
  - `hosted_invoice_url` n'est plus affiche dans le bandeau;
  - le wording du bandeau ne presente plus `next_payment_attempt` comme date limite de coupure;
  - au retour du portail, les pages relisent Stripe live via le helper existant et affichent le message `Votre paiement a bien été régularisé.` seulement si le retour porte `stripe_billing_context=payment_failed`, que la subscription est `active` et que la derniere facture est payee ou soldee;
  - un retour post-paiement initial classique avec seulement `stripe_billing_return=1` ne declenche pas ce message;
  - sur `Mon offre`, les portails standards reviennent sans contexte impaye; seul le CTA du bandeau impaye cree un portail avec `stripe_billing_context=payment_failed`.
- [x] Invariants:
  - aucun changement webhook;
  - aucune table incident Stripe;
  - aucun usage de `id_etat=1`;
  - le payeur reel reste le seul destinataire du bandeau.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_ecommerce_offre_client_bloc.php`

## PATCH 2026-04-29 — Stripe ABN V1.1: trace commentaire sur paiement echoue
- [x] Correctif livre:
  - `invoice.payment_failed` ajoute une ligne append-only dans `ecommerce_offres_to_clients.commentaire` pour signaler le paiement Stripe en echec avant cloture finale;
  - la trace est dedupliquee par couple `invoice` + `attempt_count`, afin de rester idempotente en cas de replay webhook;
  - aucune modification de `id_etat`, `date_fin`, commande ou facture Cotton n'est faite a ce stade.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php`

## PATCH 2026-04-29 — Stripe ABN: relance visible sans coupure avant cloture finale
- [x] Audit confirme dans:
  - `pro/web/ec/ec_webhook_stripe_handler.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `pro/web/ec/modules/communication/home/ec_home_index.php`
  - `pro/web/ec/modules/widget/ec_widget_ecommerce_offre_client_bloc.php` (confirmation: encore inclus par la home, mais plus porteur du bandeau Stripe)
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - `invoice.payment_failed` ne coupe pas l'offre: pas de `id_etat`, pas de `date_fin`, pas de commande/facture creee; depuis la V1.1, il trace aussi le paiement echoue dans `commentaire`;
  - `customer.subscription.updated` en `past_due` journalise la relance Stripe en cours sans toucher a l'offre Cotton;
  - `customer.subscription.updated status=canceled` et `customer.subscription.deleted` synchronisent l'offre en `id_etat=4` (`Terminee`);
  - si Stripe remonte `cancellation_details.reason=payment_failed`, le commentaire de l'offre recoit une ligne idempotente `Offre terminee suite a impaye Stripe (subscription sub_xxx)`;
  - `Mon offre` et la home PRO affichent un bandeau au compte payeur reel quand la subscription Stripe live est `past_due` ou `unpaid`;
  - sur la home, le bandeau est place au-dessus de la grille widgets au lieu d'etre porte par le widget `Mon offre`.
- [x] Invariants:
  - Stripe reste source de verite des retries/dunning;
  - aucune table incident Stripe n'est creee;
  - `id_etat=1` n'est pas utilise en V1;
  - les affilies non payeurs ne voient pas le bandeau d'une offre payee par une TdR;
  - le write path `invoice.paid` reste inchange.
- [x] Audit `id_etat=1`:
  - le cron BO traite `id_etat=1` comme `Non payee` puis bascule en `id_etat=10` apres 30 jours;
  - `id_etat=1` n'est donc pas strictement equivalent a `Terminee` (`id_etat=4`) et reste hors V1 Stripe.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_ecommerce_offre_client_bloc.php`

## PATCH 2026-04-29 — Agenda Quiz V1: CTA launcher historique
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_play_classic.php`
- [x] Correctif livre:
  - les cartes agenda `Cotton Quiz V1` (`id_type_produit=1`) reconstruisent maintenant `Ouvrir le jeu` vers le parcours classique PRO `/extranet/start/game/play/{id_securite_session}`;
  - ce parcours conserve le launcher historique `quiz.game` / `quiz.display` deja utilise par la fiche detail session;
  - la branche `games/master` reste reservee aux produits modernes `4/5/6`.
- [x] Invariants:
  - pas de changement sur `Bingo Musical`, `Blind Test` ni `Cotton Quiz V2`;
  - le garde-fou commercial `app_session_launch_guard_get(...)` reste applique;
  - pas de changement des routes publiques ni des fichiers `games`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - `git -C /home/romain/Cotton/pro diff --check`

## PATCH 2026-04-29 — Micro-feedback PRO: labels stockes sans emoji
- [x] Audit confirme dans:
  - `pro/web/ec/modules/general/feedback/ec_feedback_submit_ajax.php`
- [x] Correctif livre:
  - le serveur ignore le `rating_label` poste par l'UI et applique un mapping canonique par `rating_value`;
  - labels stockes: `Oui`, `Moyen`, `Non`, `Oui, très bien`, `Pas totalement`, `Fermé`;
  - les emojis peuvent rester visibles dans les CTA, sans etre enregistres en base.
- [x] Invariants:
  - UI inchangee;
  - SQL inchange;
  - logique metier inchangee;
  - `rating_value` inchanges: `yes`, `neutral`, `no`, `great`, `improve`, `ignored`;
  - `neutral` et `no` restent distingues en base.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/feedback/ec_feedback_submit_ajax.php`
  - `git -C /home/romain/Cotton/pro diff --check`

## PATCH 2026-04-29 — Micro-feedback PRO: durcissement serveur avant prod
- [x] Audit confirme dans:
  - `pro/web/ec/modules/general/feedback/ec_feedback_submit_ajax.php`
  - `pro/web/ec/modules/general/feedback/ec_feedback_lib.php`
- [x] Correctif livre:
  - couples contexte/surface verrouilles cote endpoint:
    `session_programmed_summary` + `session_summary`,
    `session_finished_experience` + `pro_home`,
    `session_finished_experience` + `pro_session_detail`;
  - valeurs autorisees par contexte:
    programmation `yes` / `neutral` / `no` / `ignored`,
    post-session `great` / `improve` / `ignored`;
  - commentaires et tags ignores cote serveur pour `yes`, `great` et `ignored`;
  - tags conserves uniquement pour `improve`;
  - sessions demo refusees cote endpoint pour le feedback apres programmation;
  - anti-doublon relu juste avant insertion dans `ec_feedback_event_insert(...)`.
- [x] Invariants:
  - UI inchangee;
  - SQL inchange;
  - aucune nouvelle table;
  - contextes et surfaces conserves;
  - aucun feedback ajoute cote `games`;
  - table a importer avant prod via `pro/sql/user_feedback_events_phpmyadmin.sql`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/feedback/ec_feedback_submit_ajax.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/feedback/ec_feedback_lib.php`
  - `git -C /home/romain/Cotton/pro diff --check`
  - `npm run docs:sitemap`

## PATCH 2026-04-29 — Micro-feedback PRO: UI compacte harmonisee
- [x] Audit confirme dans:
  - `pro/web/ec/modules/general/feedback/ec_feedback_lib.php`
  - `pro/web/ec/modules/communication/home/ec_home_index.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php`
  - `pro/web/ec/modules/general/feedback/ec_feedback_submit_ajax.php`
- [x] Correctif livre:
  - harmonisation du composant visuel commun `ec_feedback_widget_render(...)`;
  - bloc initial plus compact, sans sous-texte sur la home;
  - icone de feedback plus chaleureuse en pastille violette pleine, contraste renforce sans hauteur supplementaire;
  - fiche detail post-session alignee avec la home: question proche, boutons `Oui, très bien` / `Pas totalement`;
  - emojis legers ajoutes dans les CTA de reponse sans changer les valeurs techniques;
  - tags post-session affiches en chips selectionnables;
  - champ commentaire conserve en expansion seulement apres retour moyen/negatif;
  - message de remerciement compact harmonise.
- [x] Invariants:
  - aucun SQL modifie;
  - contextes conserves: `session_programmed_summary`, `session_finished_experience`;
  - surfaces conservees: `session_summary`, `pro_home`, `pro_session_detail`;
  - exclusion des sessions demo et anti-doublon inchanges;
  - aucun feedback ajoute cote `games`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/feedback/ec_feedback_lib.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_4_resume.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php`
  - `git -C /home/romain/Cotton/pro diff --check`
  - controle code: `session_programmed_summary` distingue `yes`/`Oui`, `neutral`/`Moyen`, `no`/`Non` sans fusion de `rating_value`.

## PATCH 2026-04-28 — Micro-feedback utilisateur V1
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php`
  - `pro/web/ec/modules/communication/home/ec_home_index.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `pro/web/ec/ec_ajax.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livre:
  - table generique `user_feedback_events` fournie via `pro/sql/user_feedback_events_phpmyadmin.sql`;
  - helper reutilisable `ec_feedback_*` pour rendu, insertion, detection feedback deja donne/ignore et session recente eligible;
  - endpoint AJAX `ec_ajax.php?t=general&m=feedback&p=submit`;
  - feedback apres programmation sur le resume standard et le resume rapide multi-sessions, hors session demo;
  - rendu compact au-dessus des cartes de session pour les resumes de programmation;
  - cooldown client de 30 jours sur le feedback de programmation apres reponse ou fermeture;
  - feedback post-session prioritaire sur home PRO pour une session reelle terminee recemment;
  - la home ne remonte plus de session plus ancienne si la derniere session recente a deja un feedback ou une fermeture;
  - feedback post-session secondaire sur fiche detail terminee si aucun retour/fermeture n'existe deja;
  - commentaire affiche seulement pour les retours moyens/negatifs;
  - fermeture enregistree avec `internal_status=ignored`.
- [x] Invariants:
  - aucun feedback ajoute cote `games`;
  - les sessions demo restent exclues du post-session via `flag_session_demo=0` et les helpers historiques existants;
  - l'UI ne s'affiche pas tant que la table SQL n'est pas importee.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/feedback/ec_feedback_lib.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/feedback/ec_feedback_submit_ajax.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_4_resume.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_4_resume_batch.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/communication/home/ec_home_index.php`
  - `git -C /home/romain/Cotton/pro diff --check`

## PATCH 2026-04-28 — Fiche session PRO: verification des supports depuis `Tester`
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `pro/web/ec/modules/jeux/controle_liens/ec_controle_liens_lib.php`
- [x] Correctif livre:
  - ajout du CTA `Verifier les supports de cette session` dans la section `Tester` des sessions PRO non archivees/non verrouillees;
  - lecture prioritaire des diagnostics existants de `content_links_check_results` par URL/videoId;
  - aucun appel a `ccl_scan_run()` depuis la fiche session;
  - scan direct limite aux supports de lots temporaires Quiz non couverts par les resultats admin;
  - persistance des diagnostics directs dans `content_links_check_results` sans effacer le scan global;
  - badges au niveau playlist ou serie: `x morceaux douteux` / `x supports douteux`;
  - contexte question renvoye pour les lots temporaires.
- [x] Hors scope conserve:
  - aucun retour du scan supports dans `games organizer`;
  - aucune modification de la logique de lancement des jeux;
  - aucune modification des regles de session demo.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/controle_liens/ec_controle_liens_lib.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## PATCH 2026-04-27 — Programmation EC: format stable et visuels agenda Quiz V2
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - dependances relues:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
- [x] Causes confirmees:
  - le polling de synchronisation de la page de parametrage reappliquait les radios `session_flag_controle_numerique` / `session_id_format` depuis l'etat persiste, meme apres un choix local non encore sauvegarde;
  - les cartes agenda appelaient `app_jeu_get_detail(...)` sans `lot_ids`, ce qui forcait le `Quiz V2` a retomber sur les anciennes series legacy pour son visuel.
- [x] Correctif livre:
  - ajout de drapeaux locaux `versionTouched` et `formatTouched` pour ne plus ecraser les radios deja modifiees par l'utilisateur pendant le polling;
  - maintien du polling pour les autres etats utiles, notamment la redirection si la session devient verrouillee;
  - passage de `lot_ids` depuis les cartes agenda vers `app_jeu_get_detail(...)`;
  - le socle choisit alors le visuel depuis les lots `L...` reels de la session V2 et ignore les lots `T...`.
- [x] Addendum prod:
  - passage de `lot_ids` aussi depuis la fiche detail session et le parcours classique quand le detail session est deja charge;
  - le fallback legacy cote socle est supprime pour les visuels `Quiz V2` sans `lot_ids`.
- [x] Nettoyage post-validation:
  - retrait du contexte de trace temporaire passe par les cartes agenda apres confirmation dev/prod.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - `git diff --check`

## PATCH 2026-04-23 — Controle des liens YouTube: retour du diagnostic Data API en batch
- [x] Audit confirme dans:
  - `pro/web/ec/modules/jeux/controle_liens/ec_controle_liens_lib.php`
  - `pro/web/ec/modules/jeux/controle_liens/ec_controle_liens_list.php`
  - reference croisee: `www/web/bo/cron_routine_youtube_bingo_musical.php`
- [x] Cause confirmee:
  - le module admin `pro` etait revenu a un controle `oEmbed-only`, ce qui detectait mal plusieurs liens reellement inutilisables;
  - le cron BO Bingo Musical detecte mieux les causes metier via YouTube Data API: non public, embed desactive, age gate, live/direct, blocage FR, video indisponible.
- [x] Correctif livre:
  - extraction YouTube elargie au chemin `/live/{id}`;
  - scan Data API par lots de 50 `videoId` dedoublonnes;
  - mapping des causes vers `status_key` / `diagnostic` persistés dans `content_links_check_results`;
  - fallback `oEmbed` conserve si la cle Data API manque ou si le controle Data API est indisponible.
- [x] Hors scope:
  - pas encore de lien runtime avec `games`;
  - pas de write metier durable sur les contenus source au moment du scan;
  - pas de remplacement automatique.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/controle_liens/ec_controle_liens_lib.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/controle_liens/ec_controle_liens_list.php`

## PATCH 2026-04-17 — Fiche session terminee: upload podium local uniquement, sans QR ni caméra
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Cause confirmee:
  - la fiche detail session archivee proposait encore un parcours desktop de bascule mobile via QR code;
  - sur mobile, le CTA local ouvrait un mini-menu `Caméra / Photos`, alors que le flux organisateur mobile doit maintenant passer par la remote pour toute prise de photo.
- [x] Correctif livre:
  - la fiche detail `pro` ne montre plus de modale QR code sur `Ajouter une photo` / `Modifier la photo`;
  - desktop et mobile utilisent maintenant le meme CTA local direct, qui ouvre seulement la bibliotheque du device courant;
  - l'input fichier retire explicitement `capture`, donc la fiche detail `pro` ne pousse plus vers la camera meme sur mobile.
- [x] Invariant voulu:
  - pour prendre une nouvelle photo depuis un smartphone, l'organisateur doit passer par la remote;
  - la fiche detail `pro` ne sert plus qu'a reutiliser une photo deja presente sur l'appareil courant.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## PATCH 2026-04-17 — Fiche session + `Mes joueurs`: podiums ex aequo gardes dans l'ordre `games`
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `pro/web/ec/modules/compte/joueurs/ec_joueurs_shared.php`
  - dependance relue:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - la fiche session et le dashboard `Mes joueurs` re-triaient encore localement certains podiums par `rang` puis `label`;
  - en cas d'ex aequo, cet ordre pouvait diverger du classement complet et de l'ordre stable deja utilise dans `games`.
- [x] Correctif livre:
  - les podiums `pro` utilisent maintenant un tri stable `rang puis position source`, au lieu d'un re-tri par libelle;
  - la fiche session et `Mes joueurs` reutilisent donc l'ordre deja produit par le socle partage.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_shared.php`

## PATCH 2026-04-16 — `Ma communauté`: trigger QR aligné en ligne
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/client/ec_client_view.php`
- [x] Cause confirmee:
  - le bloc QR devait maintenant suivre deux comportements differents selon le breakpoint;
  - sur mobile, le raccourci avait besoin d'etre descendu sous la description du compte;
  - sur desktop, le rendu cible restait un empilement `texte puis icone` dans la colonne dediee.
- [x] Correctif livre:
  - le trigger desktop reste dans la colonne QR dediee et conserve un layout vertical `texte au-dessus de l'icone`;
  - un trigger mobile dedie est rendu sous la description du compte;
  - sur mobile, ce trigger utilise un layout horizontal `icone + texte`.
  - un espacement vertical complementaire est ajoute autour du bloc mobile pour mieux l'isoler de la description et du lien suivant.
  - le groupe mobile est recentre visuellement sous la description, au lieu de rester plaque a gauche.
  - le trigger mobile reapplique aussi un padding explicite pour compenser la classe Bootstrap `p-0`.
  - le trigger mobile reserve maintenant aussi une hauteur minimale coherente avec l'icone, pour eviter que l'icone et le texte debordent hors du conteneur.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_view.php`

## PATCH 2026-04-16 — Bibliothèque: aperçus YouTube courts audio/vidéo
- [x] Audit confirme dans:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- [x] Cause confirmee:
  - l'aperçu inline reutilisait une logique de depart fixe qui ne tenait pas compte de la duree reelle du support;
  - sur un support court, surtout inferieur a `40s`, un demarrage a `30s` pouvait envoyer l'aperçu trop pres de la fin ou hors fenetre utile;
  - sur un support plus long, repartir systematiquement de `0s` ne conservait pas l'intention initiale d'eviter certaines intros longues.
- [x] Correctif livre:
  - les URLs support avec bornes explicites `start/end` conservent leur priorite;
  - sans bornes explicites, les aperçus YouTube audio/video et les aperçus video HTML5 determinent maintenant leur point de depart a partir de la duree reelle du media;
  - regle metier appliquee:
    - duree `>= 40s` => depart a `30s`
    - duree `< 40s` => depart a `0s`
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`

## PATCH 2026-04-16 — Demos `master`: propagation d'un `return_url` EC
- [x] Audit confirme dans:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `pro/web/ec/modules/compte/client/ec_client_script.php`
- [x] Cause confirmee:
  - `games/master` ne pouvait pas retrouver correctement la page d'origine d'une demo pour un client EC standard;
  - les ouvertures demo depuis `pro` ne transportaient aucun contexte de retour stable.
- [x] Correctif livre:
  - ajout d'un `return_url` explicite sur les ouvertures demo connues;
  - fallback `dashboard` sur le parcours compte;
  - duplication de session couverte via un referrer `pro` valide.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_script.php`

## PATCH 2026-04-16 — Fiche session terminee: lien `games` aussi dans `Parametres`
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Cause confirmee:
  - la fiche detail exposait deja un lien `l'interface de jeu` pour une session en cours;
  - le cas `session terminee` se limitait encore a un simple titre de statut, sans CTA equivalent vers `games`.
- [x] Correctif livre:
  - reutilisation du meme `url_session_game_interface` deja prepare en amont;
  - ajout, pour le statut `Session terminee`, du message:
    - `Voir les resultats de cette session sur l'interface de jeu.`
  - aucun autre changement de logique sur la fiche detail.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## PATCH 2026-04-16 — Fiche session PRO: les demos suivent a nouveau leur etat runtime reel
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - le polling de la fiche detail etait bien actif sur les demos, mais la vue `pro` ignorait encore `is_locked` pour `flag_session_demo = 1`;
  - en amont, le helper partage `app_session_edit_state_get(...)` sortait trop tot pour toute demo, ce qui empechait de relire l'etat runtime reel et donc tout retour propre a `En attente` apres relance.
- [x] Correctif livre:
  - suppression du court-circuit demo dans le helper global de statut session;
  - la fiche detail `pro` n'exclut plus les demos de la garde `is_locked`;
  - resultat: une demo suit maintenant `En attente` / `En cours` / `Session terminee` selon son runtime reel, puis repasse editable si une relance remet effectivement son runtime a zero.
- [x] Invariant conserve:
  - aucune modification cote `games` sur le contournement de relance demo.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`

## PATCH 2026-04-16 — `Mon agenda`: acces direct au QR code permanent
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
  - reference relue:
    - `pro/web/ec/modules/compte/client/ec_client_view.php`
- [x] Correctif livre:
  - ajout dans le header `Mon agenda` d'un trigger `QR code permanent` avec icone QR;
  - ouverture de la meme modale QR que sur `Ma communauté`, avec apercu PNG et CTA `Enregistrer`;
  - le trigger reste limite au vrai agenda du lieu:
    - masque sur `Archives`;
    - masque sur `Agenda du réseau`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`

## PATCH 2026-04-15 — `Ma fiche lieu`: synthèse + classements `Mes joueurs` hydratés en AJAX
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/client/ec_client_view.php`
  - `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - `pro/web/ec/ec.php`
- [x] Correctif livre:
  - la page `Ma fiche lieu` charge immédiatement le bloc principal du lieu, puis hydrate un bloc secondaire en AJAX avec le loader déjà utilisé par `Mes joueurs`;
  - ce bloc secondaire regroupe maintenant:
    - `Mes stats`
    - `Participants`
    - `Mes tops`
    - `Classements par jeu`
  - le sélecteur de saison de `Ma fiche lieu` recharge uniquement le fragment leaderboard;
  - le widget historique `Mes stats` chargé immédiatement sur `Ma fiche lieu` a été retiré pour éviter le doublon;
  - le rendu leaderboard/podium/sélecteur de saison est mutualisé dans `pro/web/ec/modules/compte/joueurs/ec_joueurs_shared.php`.
  - addendum UI:
    - suppression du double espacement entre le bloc principal lieu et la zone hydratée;
    - intégration du sélecteur `Saison` directement dans l’en-tête du bloc `Classements par jeu`.
    - refonte du wrapper `joueurs-dashboard-leaderboards-section` en card unique, avec sous-blocs internes allégés pour ne plus cumuler les paddings.
    - retrait final des wrappers visuels internes par jeu, remplacés par un simple espacement vertical entre blocs.
    - renommage du bloc `Participants` en `Mes Participants`;
    - harmonisation de la couleur d’accent des compteurs du bloc `Mes tops`, des titres `Top 10 / Classement complet` et des liens de session de classement sur la teinte finale `#582AFF`, identique au lien toggle de dépliage;
    - suppression du widget QR code dédié en bas de page;
    - ajout d’un raccourci QR cliquable dans le bloc principal des infos générales, avec une troisième colonne sur la première row, icône recentrée et agrandie.
    - le menu `Ma communauté` suit maintenant la garde `Mes joueurs`, sauf pour les comptes relevant de l’ancienne règle `Ma fiche lieu`, qui gardent le menu même sans données;
    - le bloc principal des infos générales n’est rendu que pour ces comptes `ancienne règle`;
    - sans données mais avec menu forcé par cette règle, la page affiche un message dédié `Aucune info de communauté disponible pour le moment...`;
    - le lien de nav `Ma communauté` est déplacé juste sous `Mon agenda`, ou sous `Les jeux` quand `Mon agenda` n’est pas affiché.
    - le lien de nav `Mes joueurs` est retiré;
    - l’URL historique `extranet/players` redirige désormais vers `extranet/account/establishment/view/general`.
    - le raccourci QR intégré au bloc principal expose maintenant une explication d’usage puis ouvre une modale avec aperçu image;
    - la route `qr-code-place` accepte aussi `?format=png` pour fournir un PNG simple à enregistrer et réutiliser dans des supports imprimés.
    - ajustement final QR:
      - le libellé visible devient `QR code permanent à imprimer.`;
      - la modale remplace le texte d’usage par une explication courte orientée supports imprimés et prochaines sessions;
      - le CTA secondaire devient `Enregistrer` et pointe directement vers l’image PNG;
      - le PNG QR est maintenant généré en définition plus élevée pour une meilleure qualité d’impression.
      - la colonne QR du bloc principal est centrée verticalement pour ne plus laisser l’icône flotter visuellement au-dessus du texte;
      - l’image PNG enregistrable est maintenant composée comme un support prêt à imprimer: nom du compte, `Agenda des jeux Cotton`, QR avec logo Cotton centré, puis lien public.
      - le logo centré du QR est maintenant servi depuis un asset mutualisé `global/web/assets/branding/qr/cotton-logo-qr.png`, sans dépendance au checkout `games`.
      - la modale QR passe en `modal-lg` avec un aperçu plus large pour occuper l’espace disponible;
      - l’URL encodée par le QR suit désormais `www_url` de l’environnement actif au lieu d’un domaine `prod` codé en dur, en conservant le format public `/place/{code_client}`.
      - le trigger QR du bloc principal aligne maintenant le texte et l’icône sur le même axe;
      - la composition PNG du QR est resserrée verticalement pour limiter les blancs visibles dans la modale.
      - le PNG généré reste maintenant sur fond transparent avec un léger contour arrondi;
      - le bloc QR lui-même est aussi rogné avec des coins arrondis.
      - la composition est maintenant recentrée verticalement dans le canvas du PNG.
- [x] Correctif d’accès livre:
  - le menu `Ma fiche lieu` est maintenant visible pour tous les comptes `non siège réseau`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_shared.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/ec.php`

## PATCH 2026-04-15 — `Mes joueurs`: ordre des classements aligne sur `www` / `play`
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- [x] Correctif livre:
  - le rendu des blocs `Classements par jeu` de `Mes joueurs` suit maintenant l'ordre preferentiel `Blind Test`, `Bingo Musical`, `Cotton Quiz`;
  - l'ordre ne force pas l'affichage de blocs vides: il ne fait que reordonner les jeux effectivement disponibles, pour rester aligne avec les priorites deja retenues sur `www/fo` et `play`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`

## PATCH 2026-04-16 — Widget home `Ma communauté`: règle d'accès et wording alignés
- [x] Audit cible:
  - `pro/web/ec/modules/widget/ec_widget_client_lieu_resume.php`
- [x] Correctif livre:
  - le widget home ne s'affiche plus que si `Ma communauté` est réellement accessible, en reprenant la même garde centralisée;
  - les comptes `ABN` / `PAK` avec accès `stats/classements` retrouvent donc aussi le widget;
  - si le bloc d'infos générales est visible, le widget affiche le message de visibilité site + progression de complétion;
  - sinon, il affiche seulement le message orienté `stats organisateur` sans barre de progression.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_resume.php`

## PATCH 2026-04-16 — `Gérer mon lieu`: aperçu live du nouveau visuel
- [x] Audit cible:
  - `pro/web/ec/modules/compte/client/ec_client_form.php`
- [x] Correctif livre:
  - l'aperçu image du formulaire `manage` se met maintenant à jour dès qu'un nouveau fichier est choisi;
  - le changement est purement client-side et n'altère pas le flux de validation existant;
  - le badge `Exemple d'illustration.` disparaît dès qu'un vrai fichier est sélectionné en preview.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_form.php`

## PATCH 2026-04-16 — `Gérer mon lieu`: état explicite du visuel par défaut
- [x] Audit cible:
  - `pro/web/ec/modules/compte/client/ec_client_form.php`
  - `pro/web/ec/modules/compte/client/ec_client_view.php`
- [x] Correctif livre:
  - le wording d'aide du formulaire parle maintenant de la page du site Cotton;
  - si aucun vrai visuel n'est uploadé, le texte d'aide indique que l'image affichée est un exemple non publié;
  - le formulaire `manage` et `Ma communauté` affichent un bandeau léger `Exemple d'illustration.` sur le visuel par défaut.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_form.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_view.php`

## PATCH 2026-04-16 — `Gérer mon lieu`: visuel et descriptions harmonisés
- [x] Audit cible:
  - `pro/web/ec/modules/compte/client/ec_client_form.php`
  - `pro/web/ec/modules/compte/client/ec_client_view.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
- [x] Correctif livre:
  - le formulaire `establishment/manage` remplace le simple input fichier par un bloc visuel avec aperçu du visuel courant;
  - le champ upload précise qu'un champ vide conserve l'image actuelle;
  - le pipeline existant de recadrage est conservé, avec accept étendu à `jpg/jpeg/png/webp`;
  - `descriptif_court` et `descriptif_long` passent désormais par une normalisation commune;
  - `Ma communauté` et `place` réutilisent ce rendu texte harmonisé.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_form.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PATCH 2026-04-15 — `Mes joueurs`: mention podium + lien vers la page publique `place`
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- [x] Correctif livre:
  - ajout d'un helper local de resolution de l'URL publique `www/fr/place/{seo_slug_client}` pour le compte connecte;
  - ajout d'un helper de detection `au moins une photo sur le podium agrege`;
  - ajout sous chaque podium agrege d'une mention italique precedee d'une icone `info`;
  - sans photo, le message invite a ajouter les photos des gagnants avec lien `ta page du site Cotton`;
  - avec photo, le message se reduit a `Voir ma page sur le site Cotton`;
  - le lien pointe dans les deux cas vers la fiche `place`.
  - addendum rendu:
    - l'icone `info` est maintenant rendue en SVG inline Bootstrap Icons plutot qu'en balise `<i>`, pour garantir son affichage sur la vue `pro`.
    - le bloc message utilise maintenant un vrai centrage flex par colonne (`icone` et `texte` dans deux sous-conteneurs), ce qui evite que la mention reste visuellement collee en haut de l'icone quand le texte passe sur plusieurs lignes.
    - addendum 2:
      - le style de cette mention a finalement ete simplifie: une seule `div` inline-flex, icone SVG + texte inline, tous centres verticalement, sans wrappers de compensation ni offset CSS.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`

## PATCH 2026-04-15 — `Mes joueurs`: podium de saison au-dessus des classements agrégés
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - dependances relues:
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Correctif livre:
  - chaque bloc classement par jeu de `Mes joueurs` affiche maintenant un podium de saison juste au-dessus du titre `Top 10` / `Classement complet`;
  - le rendu reprend le style des cartes podium de la fiche detail de session terminee;
  - aucun upload n'est expose ici;
  - si une photo recente de podium est retrouvee pour le participant ou l'equipe, elle est affichee; sinon la carte garde le fallback visuel sobre de la fiche archivee `pro`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`

## PATCH 2026-04-13 — Fiche session archivée: espacement rétabli sous `Version : Papier`
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Correctif livre:
  - quand le lien d'impression papier est masqué sur une session archivée, la ligne `Version : Papier` retrouve maintenant un `padding-bottom` standard;
  - l'espacement compact `pb-0` reste réservé au seul cas où le lien d'impression papier est effectivement affiché juste dessous.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## PATCH 2026-04-13 — `Archives`: le filtre Bingo couvre aussi le legacy type `2`
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
  - dependance relue:
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livre:
  - le filtre `seo_slug_jeu=bingo-musical` couvre maintenant `id_type_produit IN (2,3,6)`;
  - la detection locale `ec_start_agenda_session_is_archive()` recharge aussi le detail jeu pour le type `2`, comme pour `3/6`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`

## PATCH 2026-04-13 — Fiche session archivée: plus de lien d'impression papier en historique
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Correctif livre:
  - le lien d'impression des feuilles de jeu / feuilles de réponses reste disponible pour les sessions papier non jouées;
  - ce lien est maintenant masqué sur la fiche détail d'une session archivée / terminée;
  - le garde est appliqué aux 2 rendus du lien dans la vue.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## PATCH 2026-04-13 — `Mes joueurs`: liens `Détail` vers l'historique agenda filtré
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
- [x] Correctif livre:
  - le lien `Détail` global de la synthese `Sessions organisées` a finalement ete retire;
  - chaque total par jeu (`Cotton Quiz`, `Bingo Musical`, `Blind Test`) expose aussi un lien `Détail` vers l'historique archive filtré sur le jeu correspondant;
  - dans la section `Classements par jeu`, le rappel `Classement calculé sur X sessions...` expose maintenant un lien `Détail` inline dans le texte, vers l'historique archive filtré sur le jeu et sur la plage de dates de la saison sélectionnée;
  - les 2 lignes d'entete de classement (`Classement calculé...` et `Attribution des points...`) gardent une couleur de texte neutre, mais le lien `Détail` reste bleu pour ressortir visuellement;
  - l'onglet `Archives` accepte désormais `seo_slug_jeu`, `date_start` et `date_end` pour relire le meme point d'entree historique avec filtre.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`

## PATCH 2026-04-13 — Fiche session archivée: retour header vers `Archives`
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_include_header.php`
- [x] Correctif livre:
  - sur la fiche detail d'une session archivee, le CTA de retour du header ne pointe plus vers l'agenda des sessions a venir;
  - le lien retourne maintenant vers `extranet/start/games/archives`;
  - le libelle affiche est maintenant exactement `"Archives"`;
  - les sessions non archivees conservent le retour existant `Mon agenda`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_include_header.php`

## PATCH 2026-04-13 — Fiche session archivée: `Paramètres` remonte avant `Résultats`, statut visible, contenu masqué
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Correctif livre:
  - la fiche detail d'une session archivee repasse visuellement le bloc `Paramètres` avant `Résultats`;
  - le bloc `Paramètres` affiche maintenant explicitement le statut `Session terminée`, sur le meme principe que le bandeau deja present pour `Session en cours`;
  - le bloc `Paramètres` masque maintenant le `Contenu` / les thematiques / la playlist quand la session est historique;
  - le recap utile conserve dans `Paramètres` reste limite aux informations de contexte de session (jeu, date, version, participation, impression papier si applicable).
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## PATCH 2026-04-13 — Fiche session archivée mobile: upload photo unifié caméra/photos
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - dependances relues:
    - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - `global/web/lib/core/lib_core_upload_functions.php`
- [x] Cause confirmee:
  - la vue mobile exposait 2 inputs `files_img[]` distincts (`camera` + `bibliotheque`);
  - le write path podium ne relisait que le premier fichier non structurel, ce qui faisait echouer le cas ou la photo provenait du second input `capture`;
  - le pipeline image commun ne normalisait pas l'orientation EXIF des JPEG avant resize/crop, d'ou les photos importees de bibliotheque parfois couchees.
- [x] Correctif livre:
  - l'UI mobile/desktop de la fiche session utilise maintenant un bouton unique `Ajouter/Modifier la photo`;
  - sur mobile, ce bouton ouvre un mini-menu `Caméra / Photos` avant d'ouvrir le picker natif adequat;
  - un garde front refuse les formats hors `JPG/PNG/WEBP` avant soumission;
  - le write path global podium isole maintenant le premier vrai fichier uploadé au lieu de supposer `files_img[0]`;
  - le helper upload global normalise maintenant l'orientation EXIF JPEG avant redimensionnement et recadrage.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/global/web/lib/core/lib_core_upload_functions.php`

## PATCH 2026-04-13 — Fiche session archivée desktop: QR code vers l'EC mobile sur la même session
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
  - `pro/web/ec/ec_signin.php`
  - dependances relues:
    - `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
    - `global/web/assets/phpqrcode/qrlib.php`
- [x] Correctif livre:
  - le clic desktop sur `Ajouter une photo` ouvre maintenant une modale au style standard PRO;
  - cette modale affiche un QR code avec le message invitant a ouvrir la meme page sur mobile;
  - la modale conserve aussi un CTA local `Choisir une photo présente sur cet appareil.`;
  - le QR repose sur le mecanisme existant `client_contact_direct_access`, sans page mobile dediee;
  - apres auth via ce lien temporaire, l'EC redirige maintenant vers la fiche session ciblee si le couple `return_to=session_view + id_securite_session` est valide pour le client connecte;
  - la page `signin` propage aussi ces parametres de retour lors d'une connexion manuelle si le lien temporaire a expire.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/ec_signin.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## PATCH 2026-04-11 — Fiche session archivée: les ex aequo du podium peuvent avoir des photos différentes
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - dependance relue:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause racine confirmee:
  - la vue EC groupait le podium par `rank` et n'exposait qu'un seul formulaire d'upload par place;
  - le write path et la lecture des medias utilisaient seulement `credits='rank:X'`;
  - deux gagnants ex aequo au meme rang retombaient donc forcement sur la meme photo.
- [x] Correctif livre:
  - chaque ligne de podium expose maintenant une cle stable `photo_row_key` en plus du rang;
  - l'upload PRO transmet cette cle pour stocker une photo dediee au gagnant cible;
  - l'affichage EC montre desormais la photo et le formulaire au niveau de chaque gagnant quand plusieurs lignes partagent la meme place;
  - le fallback historique par rang est conserve pour les anciennes photos ou les podiums sans photo dediee par gagnant.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`

## PATCH 2026-04-10 — TdR: ouverture du portail Stripe d'une offre affiliée de nouveau fonctionnelle
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/client/ec_client_network_script.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - dependances relues:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- [x] Handler exact confirme:
  - l'URL `extranet/account/network/script?mode=open_affiliate_offer_portal&id_offre_client=...` est traitee par `pro/web/ec/modules/compte/client/ec_client_network_script.php`;
  - la route valide une offre deleguee possedee par le siege (`id_client = TdR`, `id_client_delegation > 0`) puis appelle `app_ecommerce_stripe_billing_portal_session_prepare(...)` avec un flow `subscription_cancel`.
- [x] Cause racine confirmee:
  - l'offre cible et la permission TdR etaient correctes;
  - l'echec se produisait au moment de preparer la session Stripe de portail, car le flow de resiliation profonde utilisait un customer siege potentiellement different de celui de la souscription deleguee;
  - la route PRO remontait ensuite `network_affiliate_portal_session_error`.
- [x] Correctif livre:
  - correction centralisee cote `global` pour realigner le customer de portail sur le customer de la souscription Stripe quand un deep link cible explicitement une subscription;
  - aucun changement de selection d'offre ni de garde TdR dans `pro`.
- [x] Difference de contexte maintenant explicite:
  - offre propre: portail standard du client;
  - offre reseau support: portail `network`;
  - offre affiliée deleguee TdR: portail deep-linke sur la souscription deleguee, avec customer aligne sur la subscription cible.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-09 — Fiche session archivée: `Résultats` remonte avant `Paramètres` + upload photo cohérent
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - dependance relue:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livre:
  - le bloc `Résultats` d'une session archivee est maintenant rendu avant le bloc `Paramètres`;
  - le front d'upload photo podium n'annonce plus `gif`, pour rester aligne sur les formats reellement acceptes par l'upload commun.
- [x] Cause racine photo confirmee:
  - le remplacement ecrivait bien le nouveau media, mais la fiche relisait la meme URL de fichier;
  - selon le navigateur, la photo precedente pouvait donc rester affichee via cache.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## PATCH 2026-04-09 — Archives agenda: l'historique ne montre plus les sessions numeriques sans valeur metier
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
  - dependance relue:
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause confirmee:
  - la page `Archives` de l'agenda EC reutilisait surtout la notion technique `archivee`;
  - elle pouvait donc encore afficher des sessions passees mais non utiles cote client:
    - session numerique non terminee metierement;
    - session numerique terminee sans participation reelle exploitable;
    - divergence de perimetre avec la synthese `Mes joueurs`.
- [x] Correctif livre:
  - l'historique agenda est maintenant filtre avec les memes gardes metier que `Mes joueurs`;
  - une session archivee n'est conservee que si elle est:
    - non demo;
    - complete;
    - reellement terminee selon le jeu;
    - et, pour le numerique, porte au moins une participation reelle fiable;
  - les sessions papier restent visibles meme sans participation remontee;
  - `ec_start_sessions_list.php` relit maintenant `flag_controle_numerique` pour appliquer cette regle a l'affichage des archives.
- [x] Sources reprises:
  - `Cotton Quiz`: `equipes_to_championnats_sessions`, puis runtime `cotton_quiz_players`, puis fallback legacy `championnats_resultats`;
  - `Blind Test`: bridge `championnats_sessions_participations_games_connectees` consomme (`date_consumed IS NOT NULL`) puis runtime `blindtest_players`;
  - `Bingo Musical`: runtime `bingo_players`, puis fallback legacy `jeux_bingo_musical_grids_clients` non demo avec joueur rattache.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`

## PATCH 2026-04-09 — Fiche session archivée: résultats finaux + photos gagnants dans l'EC
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - dependance relue:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Point d'entrée PRO confirme:
  - la fiche detail session EC est servie par `extranet/start/game/view/<id_securite_session>`;
  - son rendu est porte par `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`.
- [x] Correctif livre:
  - une session archivee affiche maintenant un bloc `Résultats`;
  - l'ordre de lecture est `Podium` puis `Classement complet` si une verite exploitable existe;
  - le bloc `Ressources` est masque sur l'historique;
  - aucun classement artificiel n'est invente quand la donnee fiable n'existe pas;
  - le podium est maintenant rendu en `3` cases pleine largeur sur desktop et en colonne sur mobile;
  - chaque case de podium expose un CTA `Ajouter une photo` / `Modifier la photo` avec upload direct;
  - la photo podium est recadree/coupee avec une hauteur fixe pour garder une mise en page homogene sur la fiche EC.
- [x] Specificites conservees:
  - `Cotton Quiz` legacy reste branche sur son classement session historique;
  - `Cotton Quiz` runtime / `Blind Test` relisent la verite scores + podium persisted;
  - `Bingo Musical` affiche le podium de phases puis la liste historisee des joueurs de session a la place d'un classement complet.
- [x] Alignements metier:
  - pour `Cotton Quiz` legacy sans runtime `players`, le compteur post-session suit d'abord le nombre de lignes reelles dans `championnats_resultats`, puis seulement en fallback les equipes rattachees a la session;
  - pour `Cotton Quiz` legacy, la colonne de score de la fiche detail affiche le score quiz de session, pas les points de classement agreges;
  - pour `Cotton Quiz` et `Blind Test`, le podium EC reprend maintenant les vraies positions `games` en cas d'egalite (`#1 / #1 / #3`, etc.) au lieu de forcer un faux `#1 / #2 / #3`.
- [x] Fallbacks utilisateur:
  - session non terminee: `Cette session n'a pas été jouée jusqu'au bout, pas de classement disponible.`
  - session terminee sans joueur: `Aucun joueur connecté à cette session, pas de classement disponible.`
- [x] Correctif bingo historique:
  - la vue n'utilise plus uniquement le filtre live `is_active=1` pour relire `bingo_players`;
  - cela evite le faux message `Aucun joueur...` sur une session archivee qui affiche deja des participants.
- [x] UX:
  - le podium affiche maintenant les reperes `🏆`, `🥈`, `🥉`.
  - si une photo gagnant existe deja, elle est affichee au-dessus de la place concernee.
- [x] Upload photo podium:
  - routes dediees `start/script` ajoutees pour `quiz`, `blindtest`, `bingo`;
  - les nouvelles photos sont attachees a la session archivee par rang de podium (`#1/#2/#3`);
  - pour `Cotton Quiz` legacy, la lecture conserve un fallback sur le stockage historique des photos gagnants `championnats/resultats`.
- [x] UX mobile / desktop:
  - desktop conserve un CTA unique de type `Ajouter une photo` / `Modifier la photo`;
  - mobile expose 2 actions distinctes `Prendre une photo` et `Choisir une photo` pour contourner les variations des navigateurs mobiles sur le comportement du file picker.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`

## PATCH 2026-04-09 — Remises ABN: le point de panne prod et la baseline de deploy sont maintenant documentes
- [x] Audit confirme dans:
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
  - dependances relues:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
    - `www/web/bo/www/modules/ecommerce/remises/bdd_ecommerce_remises.sql`
- [x] Cause racine prod confirmee:
  - le merge `remises` etait correctement valide en dev mais la prod a subi un double ecart:
    - migration SQL incomplete par rapport a la baseline runtime;
    - oubli de mise a jour de `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`;
  - resultat observe:
    - affichage remise OK dans PRO
    - mais pas de snapshot checkout sur `ecommerce_offres_to_clients`
    - donc pas de remise visible/effective dans Stripe.
- [x] Baseline de deploy cote PRO:
  - ne pas deployer `Remises 2026` sans verifier simultanement:
    - schema DB runtime attendu
    - `ec_offres_script.php`
    - `ec_offres_include_detail.php`
    - `ec_webhook_stripe_handler.php`
    - `ec_factures_view_pdf.php`
  - la presence de la remise en preview ne prouve pas a elle seule que le checkout Stripe est correctement cable.
- [x] Verification prod relevee:
  - avant correction:
    - offre client pending non snapshottee (`id_remise = NULL`, `prix_reference_ht = 0`, `prix_ht` catalogue)
  - apres correction de deploy:
    - logs checkout confirment `scope_ok = 1`
    - `resolution ok = 1`
    - `snapshot_saved`
    - offre client pending mise a jour avec `id_remise`, `prix_reference_ht`, `prix_ht` remises.

## PATCH 2026-04-08 — `Offres & factures`: la periode d'un ABN annuel direct ne glisse plus par mois
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - dependance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - l'affichage PRO reutilisait le detail de periode renvoye par le helper global;
  - pour un ABN annuel direct, ce helper faisait encore avancer le debut par pas mensuels avant de recalculer une fin annuelle.
- [x] Correctif livre:
  - aucun changement de template PRO;
  - la correction est centralisee dans le helper global, ce qui realigne automatiquement la ligne `Periode en cours` de `Offres & factures`;
  - le cas annualise `20/10/2025 -> 19/10/2026` reste donc stable tant que l'ancre BDD est la source de verite disponible.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-08 — Bibliothèque agenda Quiz legacy V1: retour au choix mono-série
- [x] Audit confirme dans:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- [x] Cause confirmee:
  - la bibliothèque Quiz branchait le builder multi-séries sans distinguer les comptes legacy `Cotton Quiz V1`;
  - ces comptes pouvaient donc préparer plusieurs séries alors que, métier V1, une seule série thématique doit être injectée en dernière position du quiz;
  - le write path `start` acceptait lui aussi jusqu'à `4` ids via `quiz_lot_ids`, même pour `id_type_produit = 1`.
- [x] Correctif livre:
  - détection explicite des clients legacy V1 dans la liste, la fiche détail et le script bibliothèque;
  - le builder multi-séries est neutralisé pour ces comptes, avec purge défensive d'une éventuelle ancienne sélection stockée en session;
  - les CTA bibliothèque reviennent à un flux direct mono-série;
  - le bandeau de contexte précise maintenant qu'une seule série sera placée en dernière position du quiz;
  - le write path `session_setting` borne désormais `quiz_lot_ids` à `1` item pour `id_type_produit = 1`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`

## PATCH 2026-04-08 — Tunnel agenda legacy Quiz V1: la page `setting` ne reboucle plus trop tôt vers `view`
- [x] Audit confirme dans:
  - `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
  - dependance relue:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - le polling `session_sync_state` de la page `setting` redirigeait vers `view` dès que `session.is_locked=1`;
  - pour `Cotton Quiz` legacy V1 (`id_type_produit = 1`), une session encore incomplète avec date vide / `0000-00-00` etait a tort consideree comme non `pending`, donc verrouillee;
  - le tunnel agenda quick et le tunnel bibliotheque agenda etaient tous les 2 exposes a cette sortie prematuree avant la programmation des dates.
- [x] Correctif livre:
  - le calcul d'etat legacy V1 traite maintenant une date vide / invalide comme `pending`;
  - le polling front de `step_2_setting` ne force plus la redirection vers `view` tant que la session n'a pas encore de `id_produit`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-08 — Factures PRO: le logo PDF n'utilise plus l'asset legacy `pro`
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
  - dependance relue:
    - `global/web/assets/branding/pdf/cotton-facture-logo.jpg`
- [x] Correctif livre:
  - le PDF PRO lit maintenant le logo facture depuis `global`;
  - l'ancien `cotton-quiz-pdf.jpg` de `pro/web/ec/images/general/logo/` n'est plus utilise par la facture.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`

## PATCH 2026-04-08 — Factures PRO: le PDF front regenere aussi la remise explicite
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
  - dependance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - l'ouverture d'une facture depuis le front PRO ne passait pas par le template PDF BO deja corrige;
  - le template PRO conservait donc encore l'ancien rendu:
    - remise dans le libelle produit
    - `PU HT` net remisé
    - `TVA` recalculee depuis un `HT` arrondi.
- [x] Correctif livre:
  - le PDF PRO relit maintenant les snapshots structures `prix_reference_ht`, `remise_ht`, `total_ht`, `total_ttc`;
  - la remise reste visible dans le descriptif produit, pour rester alignee sur le BO;
  - elle apparait aussi dans le recap des totaux;
  - le PDF affiche maintenant `TOTAL HT`, `REMISE ... HT`, `TOTAL REMISÉ HT`, `TVA (...)`, `TOTAL TTC`;
  - comme le PDF est regenere a l'ouverture, le nouveau rendu s'applique aussi aux factures deja existantes.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
  - cas de controle metier:
    - `99,90 € HT -25 %` => `24,97 €` de remise HT, `74,93 € HT` net, `14,98 € TVA`, `89,91 € TTC`

## PATCH 2026-04-08 — E-commerce: affichages TTC realignes sur le montant canonique Stripe/Cotton
- [x] Audit confirme dans:
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - dependances relues:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- [x] Correctif livre:
  - le checkout Stripe ne derive plus son montant TTC depuis un `prix_ht` deja arrondi;
  - `Detail de ma commande`, l'historique `Offres & factures` et les cartes `Tarifs & commande` reutilisent maintenant le meme resolver de montant canonique;
  - quand une remise s'applique, le TTC final affiche reste aligne sur la verite de facturation; le HT affiche reste uniquement informatif;
  - le cas type `100 joueurs` avec remise `25 %` n'affiche plus `89,92 € TTC` cote Cotton pour un paiement que Stripe facture `89,91 € TTC`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - reproduction executee:
    - avant `74,93 € HT / 89,92 € TTC`
    - apres `74,93 € HT / 89,91 € TTC`

## PATCH 2026-04-08 — `Offres & factures`: l'onglet `Offre` affiche la remise seulement sur la periode encore couverte
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - dependance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - hors contexte checkout, l'onglet `Offre` relit maintenant la remise snapshottee de l'offre active;
  - si cette remise couvre encore la periode de facturation en cours, le bloc affiche:
    - le libelle de remise;
    - le meme recap metier que le post-checkout Stripe;
  - si la remise snapshottee ne couvre plus la periode en cours, rien n'est affiche.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-08 — Signup remise: la route historique `/utm/cotton/...` accepte aussi les tokens opaques
- [x] Audit confirme dans:
  - `pro/web/.htaccess`
  - `pro/web/ec/ec_sign.php`
  - `pro/web/ec/ec_signin.php`
  - `pro/web/ec/ec_signup.php`
- [x] Correctif livre:
  - le portage historique de remise reste branche sur `/utm/cotton/...`;
  - la route accepte maintenant aussi des tokens minuscules, compatibles avec `id_securite`;
  - `ec_sign.php`, `ec_signin.php` et `ec_signup.php` resolvent tous un token public soit par `code`, soit par `id_securite`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_sign.php`
  - `php -l /home/romain/Cotton/pro/web/ec/ec_signin.php`
  - `php -l /home/romain/Cotton/pro/web/ec/ec_signup.php`

## PATCH 2026-04-08 — Signup remise: `signin` et `signup` savent aussi relire un token public
- [x] Audit confirme dans:
  - `pro/web/ec/ec_signin.php`
  - `pro/web/ec/ec_signup.php`
- [x] Correctif livre:
  - le point d'entree public principal reste la route historique `/utm/cotton/...`;
  - `ec_signin.php` sait aussi resoudre `utm_source=cotton`, `utm_campaign=remise` et `utm_code` quand un token public est present en querystring;
  - `ec_signup.php` applique la meme resolution, pour conserver le portage de la remise si un lien direct vers `signin` ou `signup` est utilise plus tard.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_signin.php`
  - `php -l /home/romain/Cotton/pro/web/ec/ec_signup.php`

## PATCH 2026-04-08 — Signup remise: la route `/utm/cotton/...` accepte les codes `REM2026_...`
- [x] Audit confirme dans:
  - `pro/web/.htaccess`
- [x] Correctif livre:
  - la rewrite generique `/utm/cotton/...` accepte maintenant aussi l'underscore;
  - les codes `REM2026_...` exposes depuis le BO peuvent donc utiliser une URL signup propre et stable.
- [x] Verification:
  - verification statique de la rewrite dans `/home/romain/Cotton/pro/web/.htaccess`

## PATCH 2026-04-08 — Checkout ABN: recap detail commande explicite pour les remises
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - dependance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - le step `Detail de ma commande` ne se contente plus du libelle fixe `Au lieu de ...`;
  - quand une remise BO est resolue avant checkout, le tunnel affiche maintenant un recap metier dynamique:
    - `x % de reduction pendant x mois, puis retour au tarif standard.`
    - `Apres l'essai gratuit: x % de reduction pendant x mois, puis retour au tarif standard.`
    - fallback `sans limite` et cas annuel court explicites.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-08 — Checkout ABN standard: customer Stripe stale neutralise en dev
- [x] Audit confirme dans:
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - dependance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - avant creation de session Stripe, le checkout standard revalide maintenant le `customer` persisté via le helper global;
  - un `customer` absent du compte Stripe courant est invalide localement puis recréé automatiquement dans l'environnement actif;
  - le flux n'echoue donc plus uniquement parce qu'un `asset_stripe_customerId` live a ete copie dans la base `dev`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-08 — Checkout ABN standard: orchestration schedule mensuelle + exception annuelle simple
- [x] Audit confirme dans:
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
- [x] Correctif livre:
  - le checkout ABN standard continue de passer par Stripe Checkout Subscription;
  - la logique d'essai gratuit CHR est maintenant resolue par helper global unique, au niveau du client reel;
  - le checkout n'expose toujours aucun choix technique BO `coupon/schedule`;
  - les metadata de souscription portent maintenant la decision moteur attendue et la duree de remise resolue;
  - le webhook `checkout.session.completed` devient le point d'entree d'orchestration des schedules pour les seuls cas mensuels limites;
  - le webhook:
    - relit `session.subscription`
    - rattache prudemment la subscription Stripe sur `ecommerce_offres_to_clients`
    - cree un schedule uniquement si `execution_engine = schedule`
    - stocke `stripe_subscription_schedule_id`
    - evite tout double schedule via write guards + lecture du schedule deja stocke;
  - l'annuel reste volontairement sur un flux simple:
    - duree `< 12 mois` => coupon interprete comme remise sur la premiere facture annuelle
    - duree `>= 12 mois` => coupon simple stable
    - aucun schedule annuel complexe n'est cree;
  - les cas `sans remise` et `sans limite` restent sur le chemin simple existant.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php`

## PATCH 2026-04-07 — Checkout ABN standard: remises BO Stripe hors réseau
- [x] Audit confirme dans:
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
- [x] Correctif livre:
  - le checkout Stripe standard de l'ABN periodique (`id_offre_type = 2` et `id_paiement_type = 2`) tente maintenant, hors reseau, une resolution unique de remise BO avant creation de la `Checkout Session`;
  - le parcours PRO affiche maintenant cette meme remise V1 aux memes points de lecture que les remises legacy:
    - sur `Tarifs & commande` (step 1) directement dans les cartes ABN eligibles;
    - sur `Detail de ma commande` (step 2) avant redirection Stripe;
  - ces deux affichages branchent une lecture previsionnelle du meme resolver V1 avant paiement:
    - sans snapshot;
    - sans write SQL;
    - sans creation anticipee de coupon Stripe;
  - si une remise gagnante existe:
    - Cotton garantit d'abord le coupon Stripe `% off` reutilisable par pourcentage;
    - Cotton ne gele le snapshot local que si ce coupon est disponible;
    - la session Stripe recoit ensuite `discounts[coupon]`;
    - la souscription embarque aussi en metadata la duree fixe `12 mois` de la remise V1;
  - la creation de `Checkout Session` ne reutilise plus aveuglement un `Price` Stripe catalogue retrouve par `lookupKey`;
  - avant session, le checkout force maintenant une reconciliation du `Price` catalogue avec le TTC Cotton courant, afin d'eviter qu'un ancien tarif Stripe actif ne continue d'afficher une base obsolete avant remise;
  - si le coupon Stripe est indisponible ou si le snapshot local echoue:
    - aucun `discounts` n'est injecte;
    - aucun snapshot remisé n'est conserve;
    - le checkout continue au prix catalogue Stripe de base;
  - la logique reseau legacy reste hors scope V1 et n'est pas integree au nouveau resolver;
  - la facture PDF privilegie strictement la ligne de commande pour la remise, avec fallback `offre_client` seulement en secours legacy si la ligne est vide.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`

## PATCH 2026-04-04 — `Mes joueurs`: scope de sessions + toggle classement complet
- [x] Audit confirme dans:
  - `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
  - dependance relue:
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livre:
  - chaque tableau de classement affiche maintenant, au-dessus de la regle d'attribution des points, le rappel `Classement calculé sur X session(s) jouée(s) depuis le début de la saison`;
  - si le leaderboard depasse `10` lignes, un simple lien souligne permet maintenant de derouler ou replier la liste complete sans changer de filtre;
  - le titre du tableau bascule alors de `Top 10 ...` vers `Classement complet sur la saison selectionnee`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`

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

> Référence courante TdR/Affiliés: la navigation affiche `Affiliés` / `Agenda réseau` / `Désign des jeux` / `Jeux sélectionnés`; la home TdR démarre par une 1re ligne desktop `2/3 - 1/3` puis colonne en mobile: un hero reseau en split `visuel a gauche / contenu a droite` avec `nom du compte TdR` a gauche, titre `Ton lien d'affiliation`, checklist `Développe ton réseau / Diffuse tes couleurs / Choisis tes jeux`, lien d'affiliation puis CTA unique `Copier le lien`, et sans bouton secondaire inline; le bloc de synthèse réseau reste séparé à droite; la 2e ligne enchaîne `Mes affiliés`, `Désign des jeux`, `Jeux sélectionnés`, puis `Agenda de mon réseau`; `/extranet/account/network` est titrée `Mes affiliés` et affiche le lien d'affiliation puis le tableau `Affilié / Statut / Infos / Action`, avec une micro-synthese support/quota juste sous la phrase d'aide de `Mes affiliés`; `/extranet/account/branding/view` est titrée `Design du réseau`.
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
  - recette visuelle desktop sur `Dashboard`, `Mes affiliés`, `Offres & factures` et `Jeux sélectionnés`

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

## PATCH 2026-03-24 — Désign des jeux: la modale de sauvegarde soumet le bon formulaire
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

## PATCH 2026-03-24 — Désign des jeux: confirmation avant enregistrement
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

## PATCH 2026-03-24 — Désign des jeux: CTA `Voir le rendu réel` sur design actif
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
  - page Jeux sélectionnés relue:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - liens home relus:
    - `pro/web/ec/modules/communication/home/ec_home_index.php`
    - `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
- [x] Correctif livre:
  - suppression des sous-titres de header redondants sur `Mes affiliés`, `Design du réseau` et `Jeux sélectionnés`;
  - suppression du sous-titre explicatif interne dans `Mes affiliés`;
  - ajout d'un contexte `return_to=home` depuis les liens home reseau vers `Affiliés`, `Désign des jeux` et `Jeux sélectionnés`;
  - affichage conditionnel d'un lien `← Retour à l'accueil` au-dessus des titres quand ce contexte est present;
  - cote affilié, alignement du lien `← Retour à la bibliothèque` sur le style `← Retour au catalogue`.
- [x] Verification:
  - `php -l` OK sur `ec_home_index.php`, `ec_widget_client_reseau_shortcuts.php`, `ec_client_list.php`, `ec_branding_view.php`, `ec_branding_form.php`, `ec_bibliotheque_list.php`

## PATCH 2026-03-20 — Jeux sélectionnés: blocs d'intro aligns sur le pattern hero home
- [x] Audit cible prouve:
  - page bibliotheque relue:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - visuel home de reference relu:
    - `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
- [x] Constat confirme:
  - la page `Jeux sélectionnés` exposait encore deux blocs d'intro/outillage en cartes textuelles simples;
  - ces 2 blocs existaient bien separement pour les TdR et pour les affiliés, avec contenus et CTA differents;
  - le visuel `catalogue_contenus.png` existait deja et servait deja de reference sur la home reseau.
- [x] Correctif livre:
  - les 2 blocs d'intro passent maintenant sur une carte `visuel a gauche / texte a droite`;
  - le visuel reutilise `catalogue_contenus.png`, comme la carte home `Jeux sélectionnés`;
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
  - `Design du réseau` et `Jeux sélectionnés` deviennent des lignes d'etat lisibles avec labels stables, wording metier (`Aucun design personnalisé`, `Design prêt à être diffusé`, `Aucun jeu partagé`, `X jeux partagés`) et pills `À faire` / `Prêt`;
  - les lignes restent discretement cliquables vers leurs destinations naturelles avec un chevron leger;
  - les sessions reseau a venir descendent en footer compact et restent visibles meme a `0`, pour eviter l'effet de boite vide;
  - la passe de finition aligne maintenant le titre `Vue rapide du réseau` sur la hierarchie des titres de cartes reseau, renomme les lignes `Désign des jeux` et `Jeux sélectionnés`, et neutralise le lien `Agenda réseau` quand aucune session n'est programmee;
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

## PATCH 2026-03-18 — TdR: harmonisation UI finale home / affiliés / design / Jeux sélectionnés
- [x] Audit cible prouve:
  - shell nav relu:
    - `pro/web/ec/ec.php`
  - home widgets relus:
    - `pro/web/ec/modules/widget/ec_widget_client_reseau_shortcuts.php`
    - `pro/web/ec/modules/widget/ec_widget_client_reseau_resume.php`
  - page affiliés relue:
    - `pro/web/ec/modules/compte/client/ec_client_list.php`
  - pages Désign des jeux relues:
    - `pro/web/ec/modules/compte/NA_client_branding/ec_client_branding_view.php`
    - `pro/web/ec/modules/compte/NA_client_branding/ec_client_branding_form.php`
  - page Jeux sélectionnés relue:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- [x] Constats confirmes:
  - la home TdR gardait des titres de widgets en texte colore sans header jaune dedie;
  - la home TdR ne donnait pas encore de mode d'emploi reseau ni d'acces direct au lien d'affiliation au-dessus des widgets;
  - la page `/account/network` gardait le titre `Mon réseau` et des cartes/CTA encore colores en violet;
  - les pages `Désign des jeux` utilisaient encore des CTA pleins historiques;
  - `Jeux sélectionnés` gardait des liens retour `Mon réseau` et n'adaptait pas son empty-state au nombre de jeux partagés.
- [x] Correctif livre:
  - la home TdR affiche maintenant un texte d'introduction d'usage reseau au-dessus des widgets;
  - le lien d'affiliation y est affiche inline avec une icone de copie, sans bloc carte dedie;
  - la home TdR expose les widgets `Mes affiliés`, `Design du réseau`, `Jeux sélectionnés` et `Agenda de mon réseau`;
  - ces widgets utilisent maintenant un header transparent avec la seule ligne icone + titre surlignee en jaune `#FFDB03`;
  - les headers home reprennent maintenant les icônes du menu gauche de navigation;
  - le widget `Agenda de mon réseau` reprend le même surlignage, sans texte forcé en uppercase;
  - `/account/network` affiche maintenant `Mes affiliés` comme surface de pilotage affiliés;
  - la page ne garde plus que le lien d'affiliation puis un tableau simplifie `Affilié / Statut / Infos / Action`;
  - les blocs `Personnalisation`, Jeux sélectionnés et le détail des offres affiliées sont retires de cette page;
  - la colonne `Infos` remonte la metrique existante `sessions programmées`;
  - la colonne `Action` garde `Activer` / `Désactiver` / `Commander` quand ces actions sont légitimes, sinon renvoie vers `Offres` filtre sur l'affilié;
  - les headers jaunes sont retires de la page `Affiliés`, les titres reviennent en couleur par defaut;
  - l'accès `Désign des jeux` injecte `nav_ctx=network_design` pour stabiliser le surlignage du menu dédié;
  - `Jeux sélectionnés` retire les liens retour vers `Mon réseau`;
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
  - les accès `Désign des jeux` et `Jeux sélectionnés` n'étaient pas remontés sur la home;
  - l'ordre nav TdR ne suivait pas encore `Mes affiliés` puis `Désign des jeux` puis `Jeux sélectionnés`.
- [x] Correctif livre:
  - la home TdR expose maintenant 3 widgets raccourcis `Mes affiliés`, `Désign des jeux` et `Jeux sélectionnés`;
  - le widget affiliés remonte le total puis `Actifs / Inactifs`;
  - le widget design remonte un statut simple `actif / absent`;
  - le widget jeux remonte le nombre de Jeux sélectionnés partagés;
  - l'agenda réseau reste affiché sous ces 3 raccourcis;
  - la nav TdR inverse `Désign des jeux` et `Jeux sélectionnés` pour reprendre cet ordre.
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

## PATCH 2026-03-18 — TdR: `Mon réseau` devient `Mes affiliés` et `Désign des jeux` entre dans la nav
- [x] Audit cible prouve:
  - navigation shell relue:
    - `pro/web/ec/ec.php`
- [x] Constats confirmes:
  - l'entrée nav réseau restait libellée `Mon réseau`;
  - l'accès direct à `/account/branding/view` n'existait pas dans la nav TdR alors que ce parcours est maintenant structurant.
- [x] Correctif livre:
  - l'entrée nav `Mon réseau` est renommée `Mes affiliés`;
  - une entrée directe `Désign des jeux` est ajoutée juste sous `Mes affiliés`;
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
  - l'etat canonique retenu est clarifié dans la doc: entrée TdR via `/account/network` puis `library?network_manage=1`, entrée affilié via la carte portail `Jeux sélectionnés`, sans onglet réseau par catalogue.
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
  - le header de cette page est allégé: lien `Retour à Mon réseau` au-dessus du titre, titre `Jeux sélectionnés`, puis sous-titre explicite;
  - le sous-titre reprend maintenant le style visuel utilisé sur `Mon réseau`;
  - un seul bloc haut de page reste affiché avec titre dynamique `Aucun jeu partagé / 1 jeu partagé / x jeux partagés avec ton réseau`, explication d'usage métier, CTA `Ajouter des Jeux sélectionnés` toujours visible et espacement renforcé sous le bloc;
  - la fiche contenu permet maintenant `Partager au réseau` / `Retirer du réseau`;
  - sur la fiche détail, l'action réseau quitte le bloc meta secondaire et rejoint les CTA principaux à côté de programmation / démo, avec wording `Partager avec mon réseau` / `Retirer du réseau`;
  - quand un contenu est partagé au réseau courant, la fiche détail affiche aussi au-dessus des CTA de programmation / démo une mention de recommandation réseau adaptée au contexte, avec un lien `Voir les Jeux sélectionnés` ; pour une playlist vue côté TdR, le libellé affiché est `Cette playlist est recommandée à vos affiliés.`;
  - les tags dédiés `Playlist / Série` et `Cotton / Communauté / Mine` sont retirés des cartes de la page TdR;
  - depuis une fiche détail ouverte dans ce contexte TdR, le lien de retour devient `Retour aux Jeux sélectionnés` et revient directement vers `library?network_manage=1`, sans être réécrasé ensuite par le recalcul interne de `back_url`;
  - si la TdR démarre un quiz depuis une série partagée réseau, le flow sort volontairement du contexte `network_manage=1 + network_scope=shared` et ouvre la bibliothèque quiz standard (`game=quiz&builder=1`) pour permettre d'ajouter d'autres séries du catalogue complet;
  - l'affilié dispose maintenant d'une entrée lecture seule via la carte portail `Jeux sélectionnés`;
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
    - affilié avec carte portail `Jeux sélectionnés` visible;
    - affilié sans carte portail `Jeux sélectionnés`;
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
  - l'entree bibliothèque sans jeu affiche dans ce cas un bloc pleine largeur `Jeux sélectionnés` avec CTA vers ce hub global;
  - ce hub affilié reutilise l'agregation transverse existante, sans changer la persistance V1;
  - cet etat intermediaire a ensuite ete remplace par la carte portail `Jeux sélectionnés`; aucun onglet réseau par catalogue n'est retenu comme état final;
  - une fiche détail ouverte depuis le hub global reseau, cote TdR comme cote affilié, revient maintenant vers `library?network_manage=1`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## PATCH 2026-03-17 — Bibliothèque: bloc portail `Jeux sélectionnés` pour TdR + affilié, sans onglet par catalogue
- [x] Audit cible prouve:
  - portail bibliothèque et cartes catalogue relus:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- [x] Constats confirmes:
  - le bloc `Jeux sélectionnés` du portail bibliothèque n'etait visible que pour l'affilié;
  - l'onglet `Playlists / Séries du réseau` par catalogue ajoutait une navigation secondaire devenue redondante avec ce portail global;
  - la chip `Réseau` sur carte n'etait calculee que pour la TdR, pas pour l'affilié.
- [x] Correctif livre:
  - le portail bibliothèque affiche maintenant aussi une carte cliquable `Jeux sélectionnés` pour la TdR, ouvrant directement la page de gestion réseau;
  - cette carte reutilise le pattern des blocs de choix de jeu, sans CTA séparé, et reste bornée a la meme largeur de colonne que les cartes jeu;
  - l'onglet `Playlists / Séries du réseau` est retire des catalogues jeu, cote affilié comme cote TdR;
  - la chip `Réseau` sur les cartes catalogue est maintenant visible a partir du proprietaire reseau effectif, donc cote affilié comme cote TdR.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## PATCH 2026-03-17 — Bibliothèque: carte portail `Jeux sélectionnés` en pleine largeur + wording final
- [x] Audit cible prouve:
  - rendu du portail bibliothèque relu:
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- [x] Correctif livre:
  - la carte portail `Jeux sélectionnés` passe maintenant sur toute la largeur disponible sous les 3 blocs jeu;
  - son rendu utilise des coins plus arrondis;
  - le titre reprend maintenant `Les jeux {nom_compte_TdR}` avec le nom du compte injecté;
  - le texte affilié est `Accède rapidement aux jeux sélectionnés par ton réseau !`;
  - le texte TdR est `Accède directement à la gestion des jeux que tu partages avec ton réseau.`
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## PATCH 2026-03-17 — Bibliothèque: carte portail `Jeux sélectionnés` alignee visuellement + visuel branding reseau
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

## PATCH 2026-03-17 — Bibliothèque: carte portail `Jeux sélectionnés` avec visuel a gauche et texte a droite
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
  - le CTA unique `Ajouter des Jeux sélectionnés` est remplace par 3 CTA dedies:
    - `Ajouter un Blind Test partagé`
    - `Ajouter un Bingo Musical partagé`
    - `Ajouter un Cotton Quiz partagé`
  - chaque CTA reprend la couleur du jeu et ouvre le catalogue cible hors contexte `network_manage=1`, pour laisser la TdR parcourir, creer et choisir librement ce qu'elle partage ensuite au réseau.
  - dans la vue globale `Jeux sélectionnés`, une meme playlist partagee a la fois sur `Blind Test` et `Bingo Musical` remonte maintenant deux fois, une carte par jeu partage, au lieu d'etre fusionnee.
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

## PATCH 2026-04-10 — Mon offre TdR: CTA portail affilié borné à une vraie souscription Stripe
- [x] Audit ciblé:
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `pro/web/ec/modules/compte/client/ec_client_network_script.php`
- [x] Cause exacte:
  - le CTA `Gérer l'offre` pouvait s'afficher pour une offre affiliée déléguée dès que `asset_stripe_productId` était non vide;
  - au clic, le script `mode=open_affiliate_offer_portal` échouait ensuite sur `network_affiliate_subscription_snapshot_unavailable` si cette valeur ne pointait pas vers une souscription Stripe relisible.
- [x] Correctif livré:
  - le CTA affilié TdR s'affiche maintenant seulement si la souscription Stripe est réellement résolue via le resolver global;
  - le handler `open_affiliate_offer_portal` bénéficie du fallback global sans changement de route ni de permission;
  - le portail affilié TdR ouvre maintenant la configuration `network_affiliate` standard, sans deep-link direct vers la résiliation.
- [x] Vérification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php`

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

## PATCH 2026-04-13 — Fiche session PRO: modale photo desktop et focus a11y
- [x] Audit cible:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Correctif livre:
  - cause racine identifiee: la modale photo desktop portait `d-none d-sm-block`, ce qui la forcait en `display:block` sur desktop dès le chargement;
  - suppression de cette classe responsive sur le conteneur `.modal`, qui redevient masque par defaut tant qu'il n'est pas ouvert par Bootstrap;
  - le CTA desktop `Choisir une photo présente sur cet appareil.` ne s'appuie plus sur un `label` + `data-bs-dismiss` fragile;
  - un handler JS rend d'abord le focus au bouton d'ouverture hors modale, attend `hidden.bs.modal`, puis ouvre le picker natif;
  - le polling deja present sur la fiche session recharge maintenant aussi la page quand une photo podium change cote serveur, y compris apres un upload realise depuis le mobile;
  - cela evite a la fois le warning `Blocked aria-hidden on an element because its descendant retained focus` et le backdrop restant qui bloquait ensuite tous les clics sur la page.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_script.php`

## PATCH 2026-04-13 — Agenda historique PRO: CTA résultats recentré sur la fiche détail
- [x] Audit cible:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
- [x] Correctif livre:
  - une session archivee / terminee ne rend plus le lien secondaire `Gérer` dans la carte liste;
  - le CTA central `Voir les résultats` reste seul et pointe maintenant vers la fiche détail `extranet/start/game/view/{id_securite}` au lieu de l'interface de jeu;
  - ce CTA historique est maintenant rendu meme quand aucun launcher jeu n'est pertinent, afin de conserver un accès cohérent à la fiche détail.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`

## PATCH 2026-04-15 — `Mes joueurs`: lien archive déplacé sur `x sessions`
- [x] Audit cible:
  - `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- [x] Correctif livre:
  - dans la phrase `Classement calculé sur x sessions jouées depuis le début de la saison`, le lien archive ne porte plus sur `(Détail)` ;
  - le texte cliquable est maintenant directement `x session(s)`, sans changement d'URL ni de filtre de période.
  - le sélecteur de période `Mes joueurs` ne présente plus `Année` + `Saison` séparément ;
  - un seul select `Saison` agrège désormais libellé de saison + année, uniquement pour les périodes disposant déjà de données.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`

## PATCH 2026-04-17 — Widget home agenda: exclusion des sessions deja terminees
- [x] Audit cible:
  - `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livre:
  - le widget home `Mon agenda` / `Agenda du réseau` ne repose plus uniquement sur `date > DATE_SUB(NOW(), INTERVAL 1 DAY)`;
  - les listes sont maintenant re-filtrees via la regle partagee `archive` vs `upcoming`;
  - les compteurs et le `+ x autres sessions` suivent aussi ce volume nettoye.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`

## PATCH 2026-04-17 — Agenda `pro`: label compact `quiz` mutualisé
- [x] Audit cible:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livre:
  - l'agenda principal `pro` et le widget home `Mon agenda` / `Agenda du reseau` utilisent maintenant `app_session_quiz_compact_label_get(...)`;
  - les concatenations manuelles de noms de lots sont remplacees par un libelle compact `1 serie` / `x series` quand il existe;
  - fallback conserve sur `theme` pour les anciens formats de quiz.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php`

## PATCH 2026-04-30 — Home `Ma communauté`: debug retiré après isolation config Stripe
- [x] Audit cible:
  - `pro/web/ec/modules/widget/ec_widget_client_lieu_resume.php`
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- [x] Correctif livre:
  - le commentaire HTML temporaire `debug-community-widget` a été retiré du widget home;
  - la cause racine est traitée côté `global`: le bootstrap Stripe ne recharge plus `global_config.php` dans un contexte `pro`, ce qui évite l'écrasement de `$conf['site_url']` et le fallback visuel vide.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/widget/ec_widget_client_lieu_resume.php`
  - test runtime global: `site_url` PRO conservé après appel Stripe.
# PATCH 2026-05-11 - LP reseau: verifier invariants PRO

- [x] Audit cible:
  - `pro/web/ec/ec_sign.php`
  - `pro/web/ec/ec_signup.php`
  - `pro/web/ec/modules/compte/client/ec_client_script.php`
  - `pro/web/ec/modules/compte/authentification/ec_authentification_script.php`
- [x] Conclusion:
  - aucun patch PRO requis;
  - `/utm/reseau/{slug}` reste le tunnel technique;
  - affiliation et activation d'offre incluse restent gerees par les helpers existants.
- [ ] Recette serveur:
  - signup via `/lp/reseau/{slug}` puis `/utm/reseau/{slug}`;
  - signin compte existant via le meme parcours;
  - support actif avec quota et support absent.
## DOC 2026-05-14 - Agent IA import PRO Quiz Markdown
- [x] Page canon mise a jour:
  - `documentation/canon/data/cotton-certified-direct-import.md`;
  - objectif agent-first explicite: produire un `.md` import PRO Quiz aussi complet que possible, avec champs deduits et vrais blocages seulement.
- [x] Regles editoriales Cotton Quiz certifie consolidees:
  - exactement 6 questions;
  - perennite, progression de difficulte, contextualisation;
  - distracteurs comme levier de difficulte;
  - mauvaises reponses plausibles mais non contestables;
  - lisibilite mobile;
  - explication courte utile a l'animateur.
- [x] Mapping `Explication` verifie:
  - importeur `pro/web/ec/modules/jeux/import/ec_import_quiz.php`;
  - `Explication` alimente `questions.commentaire`;
  - champ relu par les helpers Quiz et edite cote PRO comme `Commentaire`;
  - affichage aux joueurs non trouve;
  - affichage certain en correction animateur Canvas non trouve.
- [x] Format `.md` import PRO V1 clarifie:
  - pas de frontmatter YAML;
  - un seul `#`;
  - metadonnees avant `## Q1`;
  - `## Q1` a `## Q6`;
  - QCM 4 propositions;
  - `Support` limite aux images directes dans le `.md` importable V1.
- [x] Rubriques renforcees:
  - valeur exacte obligatoire dans `Rubrique`;
  - `Football` documente comme sous-categorie, pas rubrique valide;
  - exemple football/Coupe du monde: `Rubrique : Sport`.
- [x] Reste a valider:
  - syntaxe audio/video/start/end dans le `.md` PRO non trouvee dans la documentation ni l'importeur local audite;
  - recette produit future si l'importeur evolue pour supporter audio/video.

## PATCH 2026-06-10 - Tunnel first_party: astuce horaires et wording session unique
- [x] Audit cible:
  - `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - journal AI Studio raw consulte avant patch: `documentation/client/0_ROADMAP_journal_travaux.md`.
- [x] Correctif livre:
  - l'aide de l'etape 4 est presentee comme une astuce avec le style et l'icone partages;
  - les textes venue/event restent communs sur le fond et adaptent les variantes une session vs plusieurs sessions;
  - le CTA et le recap de l'etape 5 utilisent le singulier quand une seule session est choisie.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - `git -C /home/romain/Cotton/pro diff --check`

## PATCH 2026-06-10 - Tunnel first_party: wording post-programmation session unique
- [x] Audit cible:
  - `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - journal AI Studio raw consulte avant patch: `documentation/client/0_ROADMAP_journal_travaux.md`.
- [x] Correctif livre:
  - le bloc post-programmation `Tes jeux programmés` devient `Ton jeu programmé` quand une seule session officielle est programmee;
  - le texte de personnalisation/test passe de `Chaque session...` a `Ta session...`, y compris le jour J;
  - la carte participants utilise `Lien d'inscription` et une copie au singulier pour une soiree single, avec adaptation event equivalente.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - `git -C /home/romain/Cotton/pro diff --check`

## PATCH 2026-06-10 - Pivot first_party: rappel animateur limite desktop
- [x] Audit cible:
  - `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - journal AI Studio raw consulte avant patch: `documentation/client/0_ROADMAP_journal_travaux.md`.
- [x] Correctif livre:
  - le rappel `Un animateur peut piloter le jeu avec son mobile depuis les options de jeu de chaque session.` porte une classe dediee dans les deux blocs de conseils;
  - la classe est masquee sous `991.98px`, pour conserver l'affichage uniquement sur desktop `>= 992px`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - `git -C /home/romain/Cotton/pro diff --check`

## PATCH 2026-06-10 - Tunnel first_party: recap etape 5 en chips
- [x] Audit cible:
  - `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - journal AI Studio raw consulte avant patch: `documentation/client/0_ROADMAP_journal_travaux.md`.
- [x] Correctif livre:
  - suppression des cartes detaillees par session dans l'etape 5 avant creation officielle;
  - conservation des metadonnees principales: jeu, nombre de sessions, date et rythme;
  - affichage compact des themes/playlists/series selectionnes sous forme de chips dedupliquees.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - `git -C /home/romain/Cotton/pro diff --check`

## PATCH 2026-06-10 - Pivot first_party: cartes agenda et communication sans QR lieu
- [x] Audit cible:
  - `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - journal AI Studio raw consulte avant patch: `documentation/client/0_ROADMAP_journal_travaux.md`.
- [x] Correctif livre:
  - les sessions programmees du pivot utilisent une structure de carte proche de l'agenda EC Pro (`card-game`, image, badge jeu, date, libelle jeu/theme);
  - la pastille du visuel utilise la couleur du jeu;
  - remplacement du volume joueurs max par `Participations : n`, avec `Participation : aucune pour le moment` quand le compteur est nul;
  - aucun lien `Gérer` n'est rendu dans ces cartes first_party;
  - conservation du CTA `Préparer` / `Ouvrir le jeu` sous forme de bouton centre dans le footer blanc de la carte, avec icone cast;
  - le fond blanc du footer est force via le selecteur specifique `.card.card-game.ec-first-party-agenda-session-card .card-footer`.
  - suppression du bloc et du modal `QR code imprimable` pour les comptes dynamisation/venue;
  - l'astuce de verification fiche lieu est affichee sous les blocs `Supports de communication` et `Liens d'inscription`.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - `git -C /home/romain/Cotton/pro diff --check`

## PATCH 2026-06-11 - Bibliotheque first_party: brouillon conserve
- [x] Audit cible:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - journal AI Studio raw consulte avant patch: `documentation/client/0_ROADMAP_journal_travaux.md`.
- [x] Correctif livre:
  - les comptes `INS`, `ABN` et `PAK` en contexte first_party sans session officielle future reutilisent le brouillon existant depuis la bibliotheque;
  - brouillon 1 session: remplacement direct du contenu de l'unique session, retour etape 3 avec confirmation;
  - brouillon 2/3 sessions: stockage d'un candidat temporaire, retour etape 3 avec choix explicite de la session a remplacer;
  - aucune session officielle, quatrieme session, modification de rythme ou reset brouillon n'est declenche;
  - l'astuce `Catalogue complet` de l'etape 3 devient globale sous les blocs de sessions;
  - le builder Cotton Quiz garde sa validation existante et transmet jusqu'a 4 series dans le candidat/remplacement.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - `git -C /home/romain/Cotton/pro diff --check`

## PATCH 2026-06-11 - Tunnel first_party: actions themes etape 3
- [x] Audit cible:
  - `pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - journal AI Studio raw consulte avant patch: `documentation/client/0_ROADMAP_journal_travaux.md`.
- [x] Correctif livre:
  - le bouton `Modifier` n'est plus rendu dans l'en-tete des blocs session;
  - l'action `Modifier` est placee dans la mini-carte du theme, sous le titre/description, alignee avec le texte et forcee sur sa propre ligne;
  - en presence d'un candidat bibliotheque, l'action d'edition est masquee et remplacee par `Remplacer cette session`;
  - la miniature Quiz de l'etape 3 privilegie le visuel de la premiere thematique selectionnee et ignore le visuel par defaut `default_cotton_quiz` tant qu'un visuel thematique existe;
  - aucune logique de remplacement, de stockage session, de pivot, Home ou regle `INS` / `ABN` / `PAK` n'est modifiee.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_first_party_onboarding.php`
  - `git -C /home/romain/Cotton/pro diff --check`
