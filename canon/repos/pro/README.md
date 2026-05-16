# Etat 2026-05-14 - BO contrats reseau hors cadre, flux PRO inchange

Le correctif BO `reseau_contrats` sur les offres deleguees hors cadre ne modifie pas le flux PRO TdR:
- `Mon reseau` conserve le demarrage de commande via `start_delegated_hors_cadre_checkout`;
- le tunnel ecommerce PRO continue de creer une offre pending puis de rattacher l'offre payee hors cadre;
- les garde-fous PRO existants restent inchanges: legitimite TdR, affilie rattache, refus offre propre, refus delegation deja active.

# Repo `pro`

## Etat 2026-05-15 - Preview et import DB minimal Markdown Cotton Quiz

Le PRO expose une surface admin reservee au compte Cotton `id_client=10` pour previsualiser puis importer en DB une serie Cotton Quiz depuis un fichier source Markdown valide.

Comportement contractuel:
- l'URL `/extranet/games/import/quiz` passe par le shell PRO connecte et refuse tout compte dont `$_SESSION['id_client'] !== 10`;
- le fichier `.md` ou le texte colle est parse et affiche d'abord en preview des champs detectes;
- si la preview ne contient aucune alerte bloquante, un CTA explicite `Importer la serie en DB` est affiche apres confirmation utilisateur;
- l'import DB minimal cree la serie, les questions, les mauvaises propositions et les liens supports tels qu'affiches dans la preview;
- l'illustration de thematique est telechargee au moment de l'import, verifiee, puis ecrite en `.jpg` dans le chemin attendu par la bibliotheque PRO: `cotton_quiz/images/jeux_cotton_quiz/questions_lots/{id_lot}.jpg`;
- si une serie existe deja avec le meme titre ou slug, le CTA peut reparer uniquement cette illustration locale, sans modifier les questions ni les propositions;
- aucun upload media automatique n'est porte pour les supports de questions dans cette page simplifiee;
- les supports ne sont plus editables dans l'importeur PHP: toute correction doit etre faite dans le Markdown source ou dans la previsualisation editoriale de l'agent IA, puis la preview est relancee;
- la rubrique catalogue est lue depuis le champ `Rubrique` du Markdown et la page affiche si elle correspond a une ligne active de `questions_lots_rubriques`;
- la page signale les alertes de structure utiles: titre/rubrique manquants, rubrique inconnue, nombre de questions different de 6, question/propositions/bonne reponse/explication manquantes, support invalide;
- les series Cotton certifiees importables doivent contenir exactement 6 questions et une explication par question;
- le Markdown peut declarer des supports types via `Support type`, `Support`, `Support start`, `Support end` et `Note support`;
- types reconnus en preview et import DB minimal: `image`, `audio`, `video`, `youtube`, `youtube_audio`, `youtube_video`;
- pour les supports audio/video/YouTube, `Support start` et `Support end` sont ajoutes en preview a l'URL finale via les parametres `start` et `end`;
- l'illustration de thematique est affichee comme URL source/import candidate, puis importee comme visuel bibliotheque lors du CTA DB;
- les titres, textes secondaires, alertes et CTA sont surcharges localement pour rester lisibles sur le fond sombre de cette page.

Fichiers de reference:
- route: `pro/web/.htaccess`;
- page preview: `pro/web/ec/modules/jeux/import/ec_import_quiz.php`.

Historique:
- le 14/05/2026, cette page portait aussi un import DB avec upload automatique des images et edition des supports en session;
- le 15/05/2026, le flux est simplifie: preview obligatoire, CTA DB restaure apres preview valide, illustration de serie importee en visuel bibliotheque, mais plus d'upload media des supports de questions ni d'edition des supports dans l'importeur.

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
