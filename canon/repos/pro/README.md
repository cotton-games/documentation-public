# Repo `pro`

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

## Etat 2026-03-24 — Design réseau: la confirmation de sauvegarde cible le bon formulaire

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

## Etat 2026-03-24 — Design réseau: confirmation explicite avant sauvegarde

Correctif fonctionnel cote PRO:
- la page `Design réseau` demande maintenant une confirmation explicite avant d'enregistrer un design;
- le clic sur `Enregistrer` ouvre une modale de confirmation;
- la modale rappelle l'impact metier: `Ce design sera affiché par défaut sur les interfaces de jeu de l'ensemble de tes affiliés.`
- le footer des CTA est aussi reequilibre dans les vues `Design réseau` et `Modifier le design`, avec un espacement haut/bas symetrique;
- si un ajustement de hauteur est necessaire pour rester visuellement aligne avec la preview, il est absorbe dans l'espace bas du contenu, juste au-dessus du footer.

## Etat 2026-03-24 — Design réseau: apercu reel via session démo

Correctif fonctionnel cote PRO:
- quand un design reseau actif existe, la `view` affiche maintenant le lien `Voir sur une session démo` a cote du badge d'etat dans la carte, avec une icone d'ouverture externe visible;
- ce CTA ouvre une vraie session démo dans un nouvel onglet, pour voir le rendu final du branding dans le contexte jeu;
- la demo priorise un contenu deja partage avec le reseau, avec preference `blindtest`, puis `bingo`, puis `quiz`;
- si aucun contenu partage exploitable n'est disponible, le fallback ouvre une demo `blindtest` sur une playlist validee parmi les plus populaires;
- la creation de session ne se fait qu'au clic, jamais au simple chargement de la page `Design réseau`;
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
- les pages TdR `Mes affiliés`, `Design du réseau` et `Jeux du réseau` n'affichent plus leurs sous-titres descriptifs de header;
- les blocs internes `Mes affiliés` et `Design du réseau` retirent aussi les sous-titres purement explicatifs devenus redondants;
- quand ces pages sont ouvertes depuis la home reseau, un lien `← Retour à l'accueil` apparait au-dessus du titre;
- cote affilié, la page `Jeux du réseau` retire aussi son sous-titre de header;
- le lien `← Retour à la bibliothèque` sur cette page affilié reutilise maintenant le meme style que `← Retour au catalogue`.

## Etat 2026-03-20 — Jeux du réseau: blocs d'intro refondus sur le pattern hero

Correctif fonctionnel cote PRO:
- la page `Jeux du réseau` garde ses 2 blocs d'intro/outillage distincts, cote TdR et cote affilié;
- ces 2 blocs adoptent maintenant un layout `visuel a gauche / texte a droite`, aligne sur le hero home reseau;
- le visuel gauche reutilise l'image `catalogue_contenus.png` deja utilisee sur la home pour `Jeux réseau`;
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
- `Design réseau` et `Jeux réseau` reprennent maintenant le meme style de label que `Affiliés`, tout en restant presentes comme des etats/leviers (`À faire` / `Prêt`);
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
  - `Design réseau`
  - `Jeux réseau`
- home TdR:
  - duo de blocs reseau au-dessus des widgets
  - en desktop: layout `2/3 - 1/3`, en mobile: colonne
  - bloc `Réseau Cotton` avec image de fond reseau + mini-carte lien d'affiliation integree et maintenue a droite en desktop
  - bloc de synthese reseau simple et visuel a droite du hero
  - widgets `Mes affiliés`, `Design du réseau`, `Jeux du réseau` et `Agenda de mon réseau`
  - style home: header transparent, avec seule la ligne icône + titre surlignée en jaune `#FFDB03`
- page `/extranet/account/network`:
  - titre `Mes affiliés`
  - carte dédiée `Lien d'affiliation`
  - micro-synthese support active sous la phrase d'aide (`Abonnement reseau actif` + `Nombres d'affiliés activables via l'abonnement réseau : X/Y`)
  - tableau de pilotage simplifié `Affilié / Statut / Infos / Action`
  - pas de bloc `Personnalisation`, pas de bloc jeux réseau, pas de détail d'offre dans les lignes
- page `/extranet/account/branding/view`:
  - titre `Design du réseau`
  - plus de lien haut de page `Retour a Mon reseau`
- hub `Jeux réseau`:
  - si aucun jeu n'est partagé, affichage direct des 3 blocs jeux vers les catalogues standards
  - si au moins un jeu est partagé, affichage du CTA `Ajouter des jeux` avec le comportement actuel

## Etat 2026-03-18 — TdR: finition UI sur home, affiliés, design et jeux réseau

Correctif fonctionnel cote PRO:
- la home TdR demarre maintenant par un hero visuel premium, avec promesse reseau et rappel d'usage du compte reseau;
- le lien d'affiliation y est integre directement dans le hero avec un bouton `Copier`;
- la home TdR expose les widgets `Mes affiliés`, `Design du réseau` et `Jeux du réseau`, plus `Agenda de mon réseau`;
- ces widgets home utilisent maintenant un header transparent, avec la seule ligne icone + titre surlignée en jaune `#FFDB03`;
- `/extranet/account/network` remplace son titre `Mon réseau` par `Mes affiliés`;
- `/extranet/account/network` ne garde plus que le lien d'affiliation puis un tableau de pilotage simplifié;
- la page retire les blocs `Personnalisation` / jeux réseau et le détail d'offre dans chaque ligne affilié;
- la colonne `Infos` remonte la métrique existante `sessions programmées`;
- la colonne `Action` garde `Activer` / `Désactiver` / `Commander` quand légitime, sinon renvoie vers `Offres` filtré sur l'affilié;
- l'accès `Design réseau` depuis la home et depuis `Mes affiliés` injecte maintenant `nav_ctx=network_design` pour stabiliser le menu gauche sur `Design réseau`;
- `Jeux réseau` retire les liens retour `Mon réseau`;
- si aucun jeu n'est partagé, le hub affiche directement les 3 blocs de jeux vers les catalogues standards;
- si au moins un jeu est partagé, ces 3 blocs sont masqués et le CTA `Ajouter des jeux` conserve le comportement actuel.

## Etat 2026-03-19 — TdR: hero home recentre sur la promesse reseau et l'acquisition affiliée

Correctif fonctionnel cote PRO:
- la home TdR ouvre maintenant sur une 1re ligne `2/3 - 1/3`, sans refonte du reste de la page;
- en desktop, le hero conserve une largeur `2/3` et s'accompagne d'une carte synthese `1/3`; en mobile, les deux blocs repassent en colonne;
- le bloc `Réseau Cotton` garde le visuel reseau local en image de fond avec overlay pour la lisibilite, reintegre le lien d'affiliation dans une mini-carte a droite maintenue en bord droit sur desktop, et retire le texte marketing central ainsi que la puce haute;
- le bloc de droite concentre maintenant les principales infos reseau: nombre d'affilies, repartition `Actifs / Inactifs`, sessions reseau a venir, statut design partage et volume de jeux partages;
- les pills de valeur ferment toujours ce hero et sont poussees au plus bas du bloc;
- la grille reseau sous le hero reaffiche `Mes affiliés`, puis `Design réseau`, puis `Jeux du réseau`;
- les trois cartes `Mes affiliés`, `Design du réseau` et `Jeux du réseau` utilisent maintenant le meme pattern visuel avec grand visuel en tete;
- `Mes affiliés` utilise le visuel statique `santeuil-cafe-nantes.jpg`;
- la carte `Design du réseau` reste refondue avec un grand visuel en tete;
- cette carte utilise par defaut `cotton-reseau-marque-blanche.jpg`, puis le remplace par le visuel branding reseau de l'utilisateur s'il est defini;
- `Jeux du réseau` utilise le visuel statique `jeu-qr-code-smartphone.jpg`;
- les visuels de ces trois cartes sont maintenant plus compacts, avec une hauteur reduite de moitie et un cadrage image centre;
- un leger filtre colore inspire du hero est applique sur ces visuels pour mieux les harmoniser avec le bloc 1;
- les recaps detailles de statut reseau ne sont plus repetes dans ces trois cartes et sont regroupes dans la carte synthese de 1re ligne;
- la carte `Design du réseau` garde le meme style de CTA footer `Personnaliser` que `Mes affiliés` et `Jeux du réseau`, et le visuel haut ne montre plus de liseré blanc parasite;
- le micro-texte du lien explique maintenant clairement le parcours: diffuser le lien, faire rejoindre de nouveaux etablissements, puis les retrouver dans `Mes affiliés` pour piloter activations, offres et activite;
- le mecanisme de copie et la source de l'URL d'affiliation restent ceux deja utilises sur la home TdR;
- aucun CTA commercial additionnel ni second gros bloc `lien d'affiliation` n'est introduit sous le hero.

## Etat 2026-03-18 — TdR: la home expose 3 raccourcis réseau

Correctif fonctionnel cote PRO:
- la home TdR remplace le bloc réseau précédent par 3 widgets raccourcis alignés avec la navigation:
  - `Mes affiliés`
  - `Design réseau`
  - `Jeux réseau`
- le widget `Mes affiliés` affiche le nombre d'affiliés rattachés, puis le détail `Actifs / Inactifs` quand au moins un affilié existe;
- le widget `Design réseau` affiche un statut simple selon qu'un branding réseau actif est partagé ou non;
- le widget `Jeux réseau` affiche le nombre de jeux actuellement partagés avec les affiliés;
- l'agenda réseau existant reste affiché sous ces 3 raccourcis;
- son widget affiche maintenant le total de sessions officielles réseau et un lien `Voir l'agenda réseau complet`;
- une entrée nav `Agenda réseau` est ajoutée sous `Mes affiliés`;
- la page `Agenda réseau` réutilise la vue agenda en agrégant les sessions officielles des affiliés, sans CTA de programmation;
- les cartes de cet agenda réseau restent elles aussi en consultation seule, sans accès au jeu ni fallback vers les offres;
- si aucune session officielle réseau à venir n'existe, le widget n'affiche ni `(0)` ni CTA, et l'entrée nav `Agenda réseau` est masquée;
- le widget home et la nav pointent directement vers `/extranet/start/games?network_agenda=1`, car le raccourci `/extranet/games` perdait ce contexte sur sa redirection.
- la navigation TdR inverse aussi `Design réseau` et `Jeux réseau` pour reprendre ce même ordre.

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
- le partage réseau passe désormais par `Jeux réseau` puis `/extranet/games/library?network_manage=1`;
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

## Etat 2026-03-18 — TdR: `Jeux réseau` rejoint la navigation dédiée

Correctif fonctionnel cote PRO:
- la navigation TdR expose maintenant trois entrées dédiées dans le bloc réseau:
  - `Mes affiliés`
  - `Jeux réseau`
  - `Design réseau`
- `Jeux réseau` ouvre directement `/extranet/games/library?network_manage=1`;
- l'état actif du contexte `network_manage=1` ne surligne plus `Mes affiliés`.

## Etat 2026-03-18 — TdR: `Mes affiliés` et `Design réseau` structurent maintenant la nav

Correctif fonctionnel cote PRO:
- l'entrée nav `Mon réseau` est renommée `Mes affiliés`;
- une nouvelle entrée `Design réseau` est ajoutée juste en dessous;
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
- l'entree canonique TdR reste `/extranet/account/network`, puis `Jeux du réseau` ouvre `library?network_manage=1`;
- l'entree canonique affilié reste le portail bibliothèque via la carte `Jeux du réseau`, en lecture seule;
- il n'existe plus d'onglet `Playlists / Séries du réseau` dans les catalogues jeu, ni cote TdR ni cote affilié;
- les actions `Partager avec mon réseau` / `Retirer du réseau` restent reservees a la TdR proprietaire, avec refus serveur propre sur tentative directe hors périmètre;
- les lectures réseau n'affichent plus un partage dont la source est supprimée, inactive ou devenue non exploitable;
- la persistance reste `ecommerce_reseau_content_shares`, conservée en lazy-init via le helper `global`, avec unicité métier portée par `(id_client_siege, game, content_type, source_id)`.

## Etat 2026-03-17 — Bibliothèque: V1 contenu reseau livree avec arrivée TdR dédiée

Correctif fonctionnel cote PRO:
- `/extranet/account/network` garde son role de point d'entree unique et le CTA `Contenus réseau` ouvre maintenant le hub bibliothèque dedie;
- la TdR arrive d'abord sur une vraie page `Contenus réseau` de management, utile même quand aucun contenu n'est encore partagé;
- tant que la TdR reste sur ce parcours `network_manage=1`, la navigation gauche conserve le contexte `Mon réseau`;
- cette page centralise les contenus déjà partagés tous jeux confondus, avec un header allégé `Retour à Mon réseau` + `Jeux du réseau` + sous-titre explicite, puis un unique bloc d'information avec compteur dynamique;
- le sous-titre reprend le style visuel déjà utilisé sur `Mon réseau`, et le bloc haut affiche maintenant un titre juste `Aucun jeu partagé / 1 jeu partagé / x jeux partagés avec ton réseau`, un texte d'aide métier et un CTA `Ajouter des jeux réseau` toujours visible;
- la fiche contenu affiche maintenant l'etat reseau et les actions `Partager au réseau` / `Retirer du réseau`;
- sur la fiche détail, l'action réseau est remontée dans la rangée de CTA principaux, à côté de la programmation et de la démo, avec le wording `Partager avec mon réseau` / `Retirer du réseau`;
- quand un contenu est partagé au réseau courant, la fiche détail affiche aussi une mention de recommandation réseau adaptée au contexte, avec un lien `Voir les jeux réseau` juste au-dessus des CTA principaux ; pour une playlist vue côté TdR, le libellé affiché est `Cette playlist est recommandée à vos affiliés.`;
- la page TdR n'affiche plus les tags `Playlist / Série` et `Cotton / Communauté / Mine` sur les cartes, jugés trop chargés pour cette vue;
- l'affilié retrouve ce contenu via la carte portail `Jeux du réseau`, purement en lecture;
- depuis une fiche détail ouverte dans le contexte TdR réseau, le lien `Retour aux jeux du réseau` revient maintenant directement vers `library?network_manage=1`, sans réinjecter le contexte catalogue filtré ni être réécrit plus bas dans la fiche.
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
- un affilié qui dispose d'au moins un contenu reseau voit maintenant, depuis l'entree bibliothèque sans jeu, un bloc `Jeux du réseau` pleine largeur qui ouvre un hub global lecture seule tous jeux confondus;
- ce hub reutilise `library?network_manage=1`, mais avec un habillage affilié et sans write path, pour exposer simplement les contenus sélectionnés par la tete de reseau;
- cet etat intermediaire a ensuite ete remplacé le meme jour par la carte portail `Jeux du réseau`; aucun onglet réseau par catalogue n'est retenu comme état final;
- une fiche détail ouverte depuis ce hub global reseau revient vers `library?network_manage=1`, cote TdR comme cote affilié.

## Etat 2026-03-17 — Bibliothèque: le portail `Jeux du réseau` remplace l'onglet réseau par catalogue

Correctif fonctionnel cote PRO:
- le portail bibliothèque sans jeu affiche maintenant une carte cliquable `Jeux du réseau` pour l'affilié et pour la TdR;
- cette carte reprend le langage visuel des blocs de choix de jeu, sans CTA distinct, avec une largeur bornée a celle des cartes de jeux du portail;
- l'onglet `Playlists / Séries du réseau` est retire des catalogues jeu, cote affilié comme cote TdR, pour éviter une navigation doublon;
- la chip `Réseau` sur les cartes catalogue est maintenant visible aussi bien pour l'affilié que pour la TdR, dès qu'un contenu est effectivement partagé par la tete de réseau.

## Etat 2026-03-17 — Bibliothèque: la carte portail `Jeux du réseau` prend toute la largeur et finalise son wording

Correctif fonctionnel cote PRO:
- la carte `Jeux du réseau` occupe maintenant toute la largeur disponible sous les 3 blocs de jeux du portail bibliothèque;
- elle adopte un style plus arrondi pour mieux s'assumer comme point d'entree dédié;
- son titre affiche maintenant `Les jeux {nom_compte_TdR}`;
- le texte affilié devient `Accède rapidement aux jeux sélectionnés par ton réseau !`;
- le texte TdR devient `Accède directement à la gestion des jeux que tu partages avec ton réseau.`

## Etat 2026-03-17 — Bibliothèque: la carte portail `Jeux du réseau` se cale sur les 3 cartes jeu et reprend le visuel reseau

Correctif fonctionnel cote PRO:
- la carte portail ne duplique plus son titre;
- sa largeur est maintenant bornee pour s'aligner visuellement avec les 3 cartes jeu du dessus, au lieu d'occuper tout le container;
- si un visuel de design reseau existe pour la TdR concernee, il est affiche en tete de carte;
- sinon la carte utilise un fallback generique `cotton-media-kit-portail.jpg`.

## Etat 2026-03-17 — Bibliothèque: la carte portail `Jeux du réseau` passe en layout horizontal

Correctif fonctionnel cote PRO:
- le visuel reseau (ou son fallback) est maintenant affiche a gauche de la carte;
- le texte passe a droite, pour mieux respecter le format horizontal de ce bloc transversal.

## Etat 2026-03-17 — Bibliothèque reseau TdR: le CTA d'ajout est decoupe par jeu

Correctif fonctionnel cote PRO:
- sur `library?network_manage=1` cote TdR, le CTA unique `Ajouter des jeux réseau` est remplace par 3 CTA dédiés et colores;
- chaque bouton renvoie directement vers le catalogue standard du jeu concerne, hors contexte reseau, pour laisser la TdR naviguer et choisir ensuite ce qu'elle partage.
- dans la vue globale `Jeux du réseau`, une meme playlist partagee a la fois sur `Blind Test` et `Bingo Musical` n'est plus fusionnee: elle apparait maintenant une fois par jeu partage.
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
