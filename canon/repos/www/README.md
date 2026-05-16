# Repo `www` — Carte IA d’intervention (canon)

## Update 2026-05-14 - BO contrats reseau / offres hors cadre
- ecran concerne:
  - BO `ecommerce/reseau_contrats`
- resultat livre:
  - l'attribution BO d'une offre deleguee hors cadre peut reussir meme sans activation cadre, si le helper global retourne `ok=1` et une `id_offre_client_deleguee`;
  - les lignes `offre_deleguee_hors_cadre` exposent une action dediee `Terminer l'offre hors cadre`;
  - cette action cible explicitement une offre client et ne supprime pas l'affiliation reseau;
  - le bouton `Desactiver` reste reserve aux offres incluses/cadre;
  - `Supprimer l'affiliation` reste une action de rattachement reseau, distincte de la terminaison d'offre.

## Update 2026-05-13 - LP reseau / mention connexion compte existant
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - le CTA principal final reste inchange et pointe toujours vers le parcours signup affilie `/utm/reseau/{slug}`;
  - une mention secondaire sous le CTA final rassure les utilisateurs deja inscrits;
  - seul le texte `Connecte-toi` est cliquable;
  - le lien utilise `/utm/reseau/{slug}/signin`, afin de conserver le contexte TdR avant affichage de `signin`;
  - aucune modification des wordings principaux, badges, stats reseau, demos ou logique d'abonnement.

## Update 2026-05-12 - LP reseau / bloc preuve sociale
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - un bloc de preuve sociale peut s'afficher sous les demos, uniquement si les stats reseau passent les seuils commerciaux serveur;
  - indicateurs V1: etablissements affilies inscrits, sessions de jeu programmees, joueurs deja accueillis;
  - le bloc est masque entierement si moins de deux indicateurs passent les seuils, sauf indicateur unique tres fort;
  - le compteur joueurs depend uniquement de l'agregat `reporting_games_players_monthly`; s'il est absent ou vide, il est ignore sans erreur.

## Update 2026-05-12 - LP reseau / couleurs dediees TdR
- ecrans concernes:
  - BO fiche client TdR `www/web/bo/www/modules/entites/clients`
  - LP publique `/lp/reseau/{slug}` et compat `/lp/operation/{slug}`
- resultat livre:
  - la fiche client TdR expose deux couleurs dediees a la LP reseau, au meme endroit que le logo et le visuel prioritaires LP;
  - ces couleurs sont stockees sur le compte TdR, separent la personnalisation LP du design reseau complet et acceptent uniquement des valeurs `#RRGGBB`;
  - la LP les lit en priorite et, si elles sont vides, revient directement aux fallbacks Cotton sans reprendre les couleurs du design reseau;
  - le rendu public expose aussi les variables CSS locales `--lp-network-primary` et `--lp-network-secondary`, sans changer les routes, CTA, badges ni logique de dates.

## Update 2026-05-11 - Abonnement reseau / echeance date_fin
- ecrans/traitements concernes:
  - cron `www/web/bo/cron_routine_bdd_maj.php`
  - BO `ecommerce/offres_clients` pour les abonnements reseau
- resultat livre:
  - un `Abonnement reseau` actif avec `date_fin` strictement passee est maintenant termine automatiquement par la routine BDD;
  - la cloture conserve la `date_fin` du support et appelle la finalisation reseau canonique pour archiver le runtime;
  - les offres incluses actives rattachees par `reseau_id_offre_client_support_source` sont fermees dans le meme flux;
  - a la creation ou sauvegarde BO d'un support avec `date_fin`, les incluses actives liees recuperent la meme date;
  - les offres propres des affilies et les offres deleguees hors cadre ne sont pas modifiees par ce traitement.

## Update 2026-05-11 - LP reseau / fallback demos `A la une`
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - les contenus reseau partages restent prioritaires et continuent de piloter les cartes de demos quand au moins un contenu actif est defini;
  - en absence de contenu reseau partage, la LP construit maintenant le fallback 3 jeux depuis les contenus Cotton `A la une`: saison/date du jour en priorite, puis contenu marque `flag_une`, puis popularite 365 jours si disponible;
  - les 3 demos historiques restent les garde-fous stables: Blind Test `29`, Bingo Musical `106`, Cotton Quiz `175`;
  - la logique reste locale a la LP et ne charge pas le module bibliotheque PRO.

## Update 2026-05-11 - LP reseau / rattachement des sessions demo
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - toute demo lancee depuis une LP reseau/operation valide transmet le slug canonique public de la TdR, pas son id client;
  - les scripts publics des trois jeux resolvent ce slug cote serveur et creent la session demo sur le compte TdR si le slug pointe bien vers une tete de reseau;
  - le choix du contenu affiche reste independant du compte porteur: contenus reseau, fallback `A la une` et fallback stable suivent la meme regle de rattachement;
  - les demos hors LP reseau/operation gardent le compte demo standard `1557`.

## Update 2026-05-11 - UI branding LP reseau / operation
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - le hero affiche un co-branding discret `[logo partenaire] x [logo Cotton]` en petites pastilles separees quand un logo LP dedie est defini; sans logo partenaire, Cotton reste affiche seul mais dans un format reduit;
  - le bandeau 3 arguments utilise un fond plus doux, derive en teinte claire des couleurs LP dediees quand elles existent, sinon blanc/neutre;
  - le bloc contexte reseau/operation n'est plus un fallback automatique: il est rendu seulement si la surcouche BO de l'abonnement reseau est active et qu'un contenu exploitable existe;
  - le bloc contexte rendu sert d'explication d'operation/invitation partenaire, avec label `Invitation partenaire`, carte claire, accent couleur LP, logo ou visuel LP disponible;
  - les accents LP alimentent les titres et numeros du mode d'emploi avec fallbacks lisibles;
  - aucun changement de route, CTA href, formulaire demo, logique d'affiliation, champ BO ou schema DB.

## Update 2026-05-11 - Passe editoriale LP reseau / operation
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - la LP reseau/operation conserve la structure et les parcours existants, mais ses wordings publics sont recentres sur le reseau, distributeur ou partenaire qui porte l'invitation;
  - avec abonnement reseau actif, le hero affiche `{TdR} t'invite a animer ton etablissement`, un CTA `Lancer une premiere animation`, et une accroche d'acces a des animations pretes a lancer jusqu'a la date de fin si elle est fiable;
  - sans abonnement reseau actif, le hero affiche `{TdR} t'invite a rejoindre son espace d'animation`, un CTA `Participer avec mon etablissement`, et aucune promesse d'acces gratuit/offert;
  - les badges dates restent `Du ... au ...` ou `Jusqu'au ...`; les fallbacks deviennent `Animations incluses` et `Invitation partenaire`;
  - etat courant apres passe UI branding: le bloc contexte n'est plus rendu comme fallback generique; il est reserve a la surcouche BO active et utile;
  - la section demos parle d'animations proposees/pretes a lancer, avec CTA `Voir une animation exemple`, sans modifier les formulaires ni les endpoints de demo;
  - aucun champ BO, schema DB, route, tunnel signup/signin ou logique d'affiliation n'est modifie.

## Update 2026-05-11 - Correctif LP reseau / abonnement reseau
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
  - BO `ecommerce/offres_clients` pour les abonnements reseau
- resultat livre:
  - le CTA public de la LP reseau est toujours reconstruit avec le slug canonique de la TdR resolue et pointe vers le tunnel PRO `/utm/reseau/{slug_tdr}`;
  - la disponibilite V1 de la LP reseau ne depend plus de `clients.online`: un compte TdR existant avec slug canonique valide est publiable, meme sans abonnement reseau actif;
  - le slug public sauvegarde en BO et le slug courant de l'URL ne deviennent pas la cible du CTA;
  - les textes par defaut suivent le marketing Cotton: sans abonnement actif, invitation a rejoindre Cotton sans promesse gratuite/offerte; avec abonnement actif, mention claire des jeux Cotton offerts/gratuits et badge `Du ... au ...`, `Jusqu'au ...` ou `Jeux Cotton offerts` selon les dates disponibles;
  - la structure publique est: hero, bandeau 3 arguments Cotton, bloc contexte reseau/operation si surcouche BO active utile, puis section jeux;
  - le bloc contexte reprend le logo ou visuel disponible et les champs BO actifs (`Titre`, `Accroche`, `Description`) uniquement comme surcouche sous le bandeau; le hero reste genere automatiquement selon l'etat actif/inactif;
  - la section jeux affiche les contenus reseau selectionnes quand ils existent, sinon les 3 jeux fallback historiques; le mode d'emploi est harmonise en tutoiement;
  - le bloc public technique `Le parcours suivant conserve...` est supprime du rendu;
  - sans couleurs/visuel LP dedies, la LP reprend les fallbacks visuels historiques: hero `bg-color-3`, CTA `btn-color-5`, sections 2/8 violettes et image generique `offre-essai/section-01.jpg`;
  - le badge hero utilise la couleur secondaire LP avec contraste automatique quand elle existe;
  - le BO affiche `Contexte affiche sur la LP reseau`, retire les champs CTA visibles, et conserve le slug public comme compatibilite non exploitee en V1.

## Update 2026-05-07 — LP operations distributeurs / marques V1
- ecran concerne:
  - `/lp/operation/{slug}`
  - fallback direct possible via `/lp/lp.php?utm_source=reseau&utm_campaign=affiliation&utm_term={slug}&utm_medium=landing-operation`
- resultat livre:
  - historique V1: `www/web/lp/lp.php` chargeait une configuration dediee `www/web/lp/includes/config/lp_operations.php`; depuis le patch 2026-05-11, la publication standard recommandee est la LP reseau `/lp/reseau/{slug}` alimentee par la TdR et l'abonnement reseau actif le plus recent;
  - une nouvelle operation commerciale se contextualise via le bloc `Page reseau / operation` de la fiche BO `Abonnement reseau`, sans ajouter de nouveau cas dans le `switch` historique;
  - la landing lit le compte TdR, les assets/couleurs LP dedies et les contenus reseau en lecture seule, sans session PRO et sans ecriture;
  - la priorite de hero est maintenant: visuel principal LP dedie, puis fallback Cotton;
  - les demos utilisent les contenus reseau partages actifs/exploitables de la TdR quand ils existent; si aucun contenu reseau n'est disponible, les demos Cotton generiques restent le fallback;
  - les actions signup/signin restent de simples liens contextualises vers `/utm/reseau/{network_slug}`, sans formulaire PRO embarque dans `www/lp`;
  - le CTA principal reste le parcours existant `/utm/reseau/{slug}` afin de reutiliser signup/signin, rattachement affilié et activation incluse si les conditions reseau existantes sont reunies;
  - le rendu distingue abonnement reseau actif et simple affiliation afin de ne pas promettre d'acces inclus sans support actif;
  - une route reseau inconnue renvoie une page 404 simple plutot que la landing commerciale par defaut.
- limites V1:
  - aucune logique ecommerce operation dediee n'est creee;
  - aucune promesse d'extinction automatique des acces a date de fin n'est ajoutee cote landing;
  - les demos reseau restent limitees aux contenus partages deja exploitables par les endpoints publics existants.

## Update 2026-05-06 — FO parcours demos catalogue
- ecrans concernes:
  - `/fr/jeux`
  - `/fr/jeux/cotton-blind-test/catalogue/playlist/{slug}`
  - `/fr/jeux/bingo-musical/catalogue/playlist/{slug}`
  - `/fr/jeux/cotton-quiz/catalogue/serie/{slug}`
- resultat livre:
  - les cartes jeux de `/fr/jeux` orientent image et CTA principal vers les catalogues existants;
  - le CTA principal est `Démos du jeu`;
  - un lien secondaire `Découvrir le jeu` conserve l'acces a la presentation du jeu;
  - addendum correctif: la structure prod rechargée depuis serveur sert de base, via le partial commun `fo_portail_jeux_demo_signup.php`;
  - `Démo complète` reste l'onglet prioritaire avec le badge `Recommandé`;
  - Cotton Quiz utilise le meme partial que Blind Test et Bingo Musical, sans CTA `Je commande` actif dans ce bloc;
  - seul le texte de presentation de la demo rapide est ajuste en desktop/mobile;
  - le parcours mobile de la demo rapide lance maintenant directement la demo depuis ce bloc, la modale redondante du partial commun est retiree.
- ajustement UX cible:
  - sur `/fr/jeux`, le lien secondaire `Découvrir le jeu` est rattache visuellement au CTA `Démos du jeu` dans la meme rangee d'action, replace a cote du bouton principal et souligne/colorise au hover selon le jeu;
  - sur les fiches detail Cotton Quiz utilisant ce partial commun, la mention `NEW ! Testez la nouvelle version du Cotton Quiz !` est masquee;
  - le micro-texte mobile de la demo rapide est raccourci et compacte via utilitaires responsive existants.

## Update 2026-04-17 — FO statique 2026: dependance `Bootstrap Icons` rechargee globalement
- ecrans concernes:
  - `/fr/solutions/bars-lieux-de-vie`
  - `/fr/decouvrir`
  - plus largement les nouvelles pages statiques `solutions/*` et `decouvrir/*` 2026
- audit court:
  - les assets et templates FO 2026 etaient bien presents cote prod apres reload, mais certaines icones restaient absentes;
  - les nouveaux templates utilisaient des classes `bi ...`, alors que le layout global `fo.php` ne chargeait plus `bootstrap-icons.css`;
  - la dependance ne subsistait localement que dans un widget specifique, insuffisant pour couvrir les nouvelles pages.
- resultat livre:
  - `www/web/fo/fo.php` recharge maintenant `Bootstrap Icons` dans le head global;
  - les icones des nouvelles pages statiques redeviennent visibles sans duplication de lien CSS dans chaque template.

## Update 2026-04-17 — FO sessions / `place`: ordre des ex aequo stabilise
- ecrans concernes:
  - `/fr/session/...`
  - `/fr/place/{organisateur}`
- resultat livre:
  - les podiums publics ne re-trient plus les lignes ex aequo par libelle ou via un `usort` instable;
  - ils preservent maintenant l'ordre source fourni par le socle partage;
  - pour les sessions runtime modernes, cet ordre source est lui-meme recale sur `games`.
- effet:
  - le podium public et le classement complet d'une meme session ne doivent plus se contredire sur l'ordre de deux lignes a rang egal;
  - les classements agreges `place` restent coherents entre podium et tableau.

## Update 2026-04-16 — FO fiche `place`: titres de jeux mis en badge dans `Classements`
- ecran concerne:
  - `/fr/place/{organisateur}`
- audit court:
  - dans l'onglet `Classements`, chaque bloc jeu (`Blind Test`, `Bingo Musical`, `Cotton Quiz`) etait encore affiche comme un simple titre texte;
  - le besoin retenu est d'aligner cette hierarchie visuelle sur les badges de jeu deja utilises dans `pro` (`Ma communauté`) et `play` (`Classements`).
- resultat livre:
  - les titres de jeux de l'onglet `Classements` passent maintenant dans un badge colore par jeu;
  - les couleurs reutilisent les classes existantes `bg-color-cotton-blind-test`, `bg-color-bingo-musical` et `bg-color-cotton-quiz`;
  - la periode de saison reste affichee a cote, en texte secondaire.

## Update 2026-04-16 — FO fiche `place`: retour du CTA d'accès direct au jeu sur entrée QR code
- ecran concerne:
  - `/place/{code_client}`
  - `/fr/place/{organisateur}`
- audit court:
  - historiquement, une entrée via le QR code `place` exposait depuis chaque carte d'agenda un CTA direct vers l'interface joueur de la session;
  - après refonte de la fiche `place` et de son hydratation AJAX, ce CTA n'était plus rendu car le nouveau renderer agenda n'héritait plus du contexte `code_client`.
- resultat livre:
  - l'URL AJAX de la fiche `place` propage maintenant explicitement `code_client` quand l'entrée vient d'un QR code lieu;
  - le renderer agenda réactive alors le bouton `J'accède au jeu` sur les cartes de sessions à venir, en réutilisant le même helper métier `app_session_games_play_get_link(...)` que le bloc historique des sessions;
  - dans ce contexte QR uniquement, le CTA public secondaire `En savoir plus` n'est plus affiché sur ces cartes;
  - le CTA reste strictement limité à l'entrée QR `place/{code_client}` et n'est pas affiché sur la fiche publique standard `/fr/place/{seo_slug}`.

## Update 2026-04-15 — FO fiche `place`: spinner aussi sur l'onglet `Agenda`
- ecran concerne:
  - `/fr/place/{organisateur}`
- audit court:
  - la fiche `place` affichait deja un spinner sur `Classements` et `Sessions passées`;
  - l'onglet `Agenda` restait sur un simple texte de chargement, alors qu'il est lui aussi hydrate en AJAX.
- resultat livre:
  - `Agenda` reutilise maintenant le meme loader spinner inline que les deux autres onglets dynamiques;
  - le spinner est visible a la fois dans le placeholder initial et lors du chargement AJAX de l'onglet.

## Update 2026-04-15 — FO fiche `place`: entrée QR code recentrée sur l'onglet `Agenda`
- ecran concerne:
  - `/place/{code_client}`
  - `/fr/place/{organisateur}`
- audit court:
  - la fiche `place` active maintenant `Classements` par défaut depuis la refonte récente des onglets;
  - en conséquence, un utilisateur qui scanne le QR code `place/{code_client}` n'atterrissait plus sur l'information prioritaire attendue, à savoir l'agenda des prochaines sessions.
- resultat livre:
  - une entrée `QR code` via `code_client` force désormais l'onglet actif initial sur `Agenda`;
  - la fiche publique SEO standard `/fr/place/{seo_slug}` conserve en revanche son comportement par défaut actuel sur `Classements`;
  - aucun changement d'URL n'est requis côté QR: la vue FO détecte déjà `code_client` et adapte seulement l'onglet actif initial.
  - addendum perf:
    - cette même entrée QR neutralise aussi le preload image hero global FO, puisque la galerie visuelle est masquée sur cette vue et que le preload produisait un warning navigateur inutile sur `branding-client-default.jpg`.
  - addendum JS:
    - sur entrée QR, les boutons d'onglets sont absents du DOM; le démarrage JS charge donc désormais `Agenda` à partir de l'onglet actif calculé côté serveur, au lieu de dépendre de la présence du bouton `tab-1`.

## Update 2026-04-14 — FO fiche `place`: classements agrégés limités au `Top 10`
- ecran concerne:
  - `/fr/place/{organisateur}`
- audit court:
  - l'onglet public `Classements` rendait immédiatement tous les rangs disponibles pour chaque jeu;
  - sur des établissements très chargés, ce volume gonflait inutilement le HTML renvoyé et la hauteur du DOM, alors que la lecture utile publique porte d'abord sur les premiers rangs.
- resultat livre:
  - chaque classement `www/place` est maintenant limité au `Top 10`;
  - le sous-titre public est fixé à `Top 10`;
  - aucun toggle `classement complet` n'est exposé côté FO;
  - quand plusieurs jeux sont présents, l'ordre de lecture publique devient `Blind Test`, puis `Bingo Musical`, puis `Cotton Quiz`;
  - le changement de saison conserve la même lecture AJAX, sans impacter les onglets `Agenda` et `Sessions passées`;
  - si aucun contenu exploitable n'existe dans `Classements`, `Agenda` et `Sessions passées`, toute la section d'onglets est masquée pour éviter un bloc vide.

## Update 2026-04-14 — FO liste `place`: filtre département restreint + tri par activité
- ecran concerne:
  - `/fr/place`
  - `/fr/place/departement/{slug}`
- audit court:
  - le filtre `Département` proposait tout le référentiel, y compris des zones sans organisateur public;
  - la liste organisateurs restait triée par `id`, sans prioriser les lieux les plus actifs.
- resultat livre:
  - le sélecteur `Département` ne propose plus que les départements réellement présents dans la liste publique des organisateurs;
  - l'option `Tous` repointe correctement vers `/fr/place`;
  - les cartes organisateurs sont maintenant triées par activité agrégée côté SQL:
    - d'abord `nb de sessions utiles` décroissant;
    - puis `date de dernière session` décroissante;
    - puis `nom` croissant;
  - le tri ne relance aucun calcul lourd par carte: une seule agrégation SQL globale est jointe à la liste publique.

## Update 2026-04-14 — BO réseau: désaffiliation directe d'un affilié depuis `reseau_contrats`
- ecran concerne:
  - `?a=www&t=ecommerce&m=reseau_contrats&p=list&id_client_siege={id}`
- audit court:
  - le BO de pilotage réseau savait déjà activer, désactiver et reclasser les affiliés, mais ne proposait aucun CTA pour sortir proprement un compte du réseau quand il n'est plus affilié à la TdR;
  - en pratique, un compte laissé avec `clients.id_client_reseau > 0` restait aussi exclu du périmètre `Remises 2026`.
- resultat livre:
  - le tableau `Affiliés du siège` expose maintenant une action BO `Supprimer l'affiliation`;
  - cette action n'existe pas côté PRO;
  - le write path réutilise `client_affilier(0, ...)` pour casser l'affiliation en remettant `id_client_reseau` à `0`;
  - la sortie du réseau relance aussi la reclassification métier existante des délégations pour le siège quitté, afin de rester cohérente avec les autres changements d'affiliation pilotés depuis le BO.

## Update 2026-04-14 — FO fiche `place`: chargement allégé des classements publics
- ecran concerne:
  - `/fr/place/{organisateur}`
- audit court:
  - la fiche publique réutilisait `app_client_joueurs_dashboard_get_context(...)`, donc sur un cache froid elle pouvait déclencher le calcul historique complet de `Mes joueurs`;
  - pour `www/place`, ce coût était disproportionné: la page n'a besoin que des leaderboards de saison courante et peut tolérer l'absence temporaire de synthèse historique si aucun cache n'est déjà disponible.
- resultat livre:
  - la fiche `place` utilise maintenant `app_client_joueurs_dashboard_get_context_fo_place(...)`;
  - ce chemin FO ne recalcule plus l'historique complet au premier hit: il charge directement le contexte filtré saison courante pour les classements;
  - les stats historiques hautes ne sont réinjectées que si le cache journalier de synthèse existe déjà dans la session courante;
  - en l'absence de cache, la page privilégie donc la vitesse d'affichage des classements plutôt que le recalcul complet de la synthèse organisateur;
  - addendum: la fiche `place` rend maintenant son shell HTML immédiatement, puis hydrate en AJAX:
    - la synthèse haute;
    - le bloc `Classements`;
  - le bloc `Classements` expose aussi un sélecteur de saison directement dans son titre, sans section séparée; ce sélecteur recharge en AJAX uniquement les leaderboards demandés, et trie les saisons exploitables récentes en premier.

## Update 2026-04-14 — FO fiche `place`: onglet `Classements` aligné sur le moteur multi-jeux
- ecran concerne:
  - `/fr/place/{organisateur}`
- audit court:
  - la fiche `place` chargeait déjà le contexte global `Mes joueurs`, mais l'onglet public restait branché sur un ancien rendu `Classement Quiz` local, figé sur plusieurs saisons legacy;
  - les règles métier récentes côté `pro/play` portent désormais des classements par jeu sur la seule saison courante exploitable, avec masquage naturel des jeux sans sessions classables.
- resultat livre:
  - l'onglet devient `Classements` et s'aligne sur la saison courante portée par `app_client_joueurs_dashboard_get_context(...)`;
  - la fiche affiche maintenant un bloc distinct par jeu réellement exploitable:
    - `Cotton Quiz`
    - `Blind Test`
    - `Bingo Musical`;
  - chaque bloc réutilise le style du tableau quiz historique (`rang / entité / points / participations`);
  - le libellé de période est simplifié au format `Jeu · Avril-Juin 2026`;
  - `Cotton Quiz` continue d'afficher des équipes, tandis que `Blind Test` et `Bingo Musical` affichent des joueurs;
  - la colonne droite ne liste plus tout l'historique: elle montre seulement un nombre ajusté des dernières sessions classées, avec bloc cliquable vers la fiche détail de session;
  - ce volume est maintenant estimé à partir de la hauteur théorique du tableau de classement plutôt qu'avec un plafond fixe, afin d'exploiter davantage l'espace quand le classement le permet;
  - si aucun jeu n'a de session classable sur la saison courante, l'onglet affiche un message vide explicite.

## Update 2026-04-14 — BO `Remises 2026`: sélection en masse figée sur une remise manuelle
- ecran concerne:
  - `?a=www&t=ecommerce&m=remises_2026&p=view&id={id}`
- audit court:
  - la fiche détail d'une remise manuelle permettait déjà d'ajouter ou retirer des comptes unitairement;
  - il manquait un moyen de figer en une fois un lot de comptes actuels répondant à des critères de `typologie` et/ou `pipeline`, sans transformer la remise en ciblage automatique.
- resultat livre:
  - la fiche détail expose maintenant un bloc `Ajouter en masse (sélection figée)` réservé au mode manuel;
  - ce bloc reprend les mêmes critères métier que le ciblage automatique:
    - `Typologie`
    - `Pipeline`;
  - le snapshot ajoute uniquement les comptes actuellement trouvés dans `ecommerce_remises_to_clients`;
  - les futurs comptes qui matcheront plus tard ces mêmes critères ne seront pas ajoutés automatiquement;
  - les comptes déjà liés sont exclus du lot;
  - dans les listes de comptes concernés de la fiche détail, l'email du contact administrateur principal s'affiche maintenant en petit sous le nom du compte;
  - cette lecture passe maintenant sur une colonne `Email` dédiée;
  - elle remonte tous les emails contacts associés à chaque compte, pas seulement l'administrateur principal;
  - si un compte a plusieurs emails, la fiche détail crée plusieurs lignes `compte + email`, tout en gardant le CTA `Retirer` uniquement sur la première ligne de ce compte;
  - le CTA `Retirer` utilise désormais un style plein lisible, autant sur la fiche détail que depuis la fiche client; le CTA d'ajout manuel depuis la fiche client est renommé `Appliquer` avec un style `btn-info`;
  - ces ajouts manuels peuvent maintenant être préparés avant activation de la remise, y compris si la fenêtre de commande n'est pas encore ouverte;
  - la fiche détail expose aussi un CTA `Vider tout` dans l'entête du tableau pour purger d'un coup les comptes manuellement liés à la remise;
  - le retrait fin reste possible ensuite, compte par compte, depuis la liste des cibles manuelles.

## Update 2026-04-13 — FO agenda public: filtres alignés sur l’agenda joueur
- ecran concerne:
  - `/fr/agenda`
- audit court:
  - l'agenda public `www` restait sur un filtre unique `Département`, avec un affichage par défaut hérité des routes SEO historiques;
  - `play` exposait déjà une lecture plus cohérente pour les joueurs: 3 filtres alignés (`Département / pays`, `Organisateur`, `Jeu`), tous par défaut sur `Tous`, avec une liste géo limitée aux zones réellement représentées.
- resultat livre:
  - l'agenda FO reprend maintenant la même logique de filtres que `play`, tout en conservant la compatibilité des routes SEO historiques `jeu / departement / ville`;
  - le filtre géographique mélange désormais départements français et pays étrangers réellement présents dans les sessions affichables;
  - le filtre `Organisateur` est borné aux lieux réellement représentés dans l'agenda courant;
  - le filtre `Jeu` normalise la lecture publique sur `Cotton Quiz`, `Blind Test`, `Bingo Musical`, avec regroupement des variantes techniques Quiz/Bingo;
  - en environnement `dev`, l'agenda public n'impose plus `c.online=1`, afin de garder une recette cohérente sur `Tous`.

## Update 2026-04-13 — FO session view: détail des séries programmées sur `Cotton Quiz`
- ecran concerne:
  - `/fr/agenda/{organisateur}/{session}`
- audit court:
  - la fiche détail `www` affichait déjà date, lieu et visuel, mais pas le détail des séries pourtant déjà exposé côté `play`;
  - les métadonnées nécessaires (`quiz_series_label`, `quiz_series_names`) étaient déjà disponibles via le socle `global`.
- resultat livre:
  - sur une fiche détail `Cotton Quiz`, le bloc gauche affiche maintenant `Séries programmées` entre `Date` et `Lieu`;
  - la lecture réutilise d'abord les données portées par la session, puis tombe en fallback sur le détail jeu;
  - le rendu reste volontairement sobre et cohérent avec les autres lignes d'information de la page;
  - les textes d'accordéon `Concept` / `Comment participer` sont aussi harmonisés:
    - wording `Quiz` simplifié;
    - `Blind Test` bascule sur un vrai CTA `Je participe`;
    - `Bingo Musical` réactive un bloc `Comment participer`;
  - le CTA principal `Je participe` de la fiche détail pointe maintenant, lui aussi, vers l'entrée EP liée à la session courante;
  - sur une session terminée `Cotton Quiz`, `Blind Test` ou `Bingo Musical`, la colonne centrale remplace désormais le visuel par un bloc `Podium` puis `Classement complet`, alimenté par le même moteur global que la fiche archive `pro`;
  - le bloc gauche d'informations générales de session est lui aussi masqué dans ce contexte, pour ne garder que les résultats;
  - les accroches marketing et blocs `Concept / Comment participer` sont masqués sur ces sessions terminées;
  - le titre de la liste basse affiche maintenant le nombre réel de participants remonté par le moteur de résultats;
  - sur `Bingo Musical`, la liste basse reste une simple liste de joueurs, sans rang ni points, comme côté `pro`;
  - le podium affiche une photo gagnant si elle existe, sinon un fallback visuel propre par place.

## Update 2026-04-13 — FO fiche `place`: synthèse stats alignée sur `Mes joueurs`
- ecran concerne:
  - `/fr/place/{organisateur}`
- audit court:
  - la fiche établissement `www` reposait encore sur des stats legacy `app_statistiques_client_*` avec seuils d'affichage fixes (`>10`, `>50`) et une lecture limitée `Bingo Musical`;
  - le BO/EC utilisait déjà le moteur global `Mes joueurs`, plus fiable sur `membre depuis`, sessions utiles, joueurs `Blind Test/Bingo Musical` et équipes `Cotton Quiz`.
- resultat livre:
  - la fiche `place` réutilise maintenant `app_client_joueurs_dashboard_get_context(...)` comme source principale;
  - `Membre depuis` et `sessions de jeux Cotton` suivent désormais la même source que `pro/ec`;
  - la synthèse publique regroupe désormais joueurs `Blind Test/Bingo Musical` et équipes `Cotton Quiz` dans une seule ligne `participants`;
  - convention marketing retenue côté `www/place`: `1 équipe Cotton Quiz = 3 participants`;
  - la ligne `participants` disparait si le total est nul;
  - les anciens seuils arbitraires de visibilité ne pilotent plus l'affichage;
  - dans l'onglet `Sessions passées`, les cartes réexposent maintenant un CTA vers la fiche détail de la session archivée;
  - cette liste archive réutilise désormais le même filtre métier que `pro` pour ne garder que les sessions historiquement utiles;
  - dans ce contexte, le CTA carte est renommé `Voir les résultats`.

## Update 2026-04-08 — BO factures PDF: la remise sort du libellé produit et suit les snapshots canoniques
- audit court:
  - la facture PDF affichait encore la remise dans la description de ligne, alors que les snapshots de commande portaient déjà distinctement le prix de référence, le HT remisé et le TTC facturé;
  - le bloc `TVA` pouvait rester arithmétiquement incohérent avec le `TOTAL TTC` quand le net HT provenait d'un arrondi intermédiaire.
- resultat livre:
  - le descriptif produit n'embarque plus la remise en ligne;
  - le `PU HT` et le `PRIX TOTAL HT` repassent sur le montant de référence avant remise quand une remise snapshotée existe;
  - les totaux PDF affichent maintenant explicitement `TOTAL HT`, `REMISE ... HT`, `TOTAL REMISÉ HT`, puis `TVA (...)` et `TOTAL TTC`;
  - la TVA visible est relue comme difference entre `TTC` canonique facture et `HT` net snapshoté, ce qui garantit un PDF coherent avec le montant final réellement payé;
  - le logo PDF BO lit maintenant aussi un asset partage sous `global`, ce qui evite de dependre d'un fichier `pro` non lisible.

## Update 2026-04-08 — BO `Remises 2026`: le lien copiable est maintenant un vrai lien prospect PRO
- audit court:
  - la fiche detail affichait bien une URL de portage de remise, mais l'ancre gardait `href="#"`, donc un clic restait dans le BO;
  - le besoin metier reste un lien prospect partageable qui porte la remise jusqu'au signup/signin.
- resultat livre:
  - il reutilise la route historique `https://pro.../utm/cotton/<token_public>`;
  - pour `Remises 2026`, le token public emis est maintenant l'`id_securite` opaque de la remise;
  - la fiche detail met maintenant le CTA `Copier le lien` en avant et laisse l'URL visible dessous en petit, sans en faire un lien cliquable;
  - le lien reste reserve aux remises manuelles actives;
  - si la fenetre de commande est expirée, le lien n'est plus expose;
  - il devient directement exploitable dans un CTA emailing ou en partage commercial.

## Update 2026-04-08 — BO clients: `Remises` bascule sur `Remises 2026`
- audit court:
  - la navigation `Commercial` exposait encore deux entrées legacy de remises, alors que le point d'entree courant est `Remises 2026`;
  - la fiche client BO gardait une section `Remises` branchée sur `ecommerce_remises_clients`, en doublon avec le nouveau ciblage `Remises 2026`.
- resultat livre:
  - le menu `Commercial` ne montre plus `Remises > catalogue Cotton` ni `Remises > accordées aux clients`;
  - la fiche client réutilise sa section `Remises` pour lister les `Remises 2026` actuellement applicables au compte;
  - cette section permet aussi d'ajouter une regle `Remises 2026` manuelle a un compte eligible, puis de retirer seulement ce rattachement manuel;
  - les regles automatiques restent en lecture seule depuis la fiche client.

## Update 2026-04-08 — BO `Remises 2026`: duree d'application metier
- audit court:
  - le BO `Remises 2026` etait deja le bon point d'entree pour la regle commerciale;
  - il lui manquait seulement une notion de duree d'application explicite, sans ouvrir des choix techniques Stripe.
- resultat livre:
  - le module ajoute `duree_remise_mois` avec defaut `12`;
  - l'editeur autorise maintenant `1..N mois` et `Sans limite`;
  - la liste et la vue detail affichent une lecture metier compacte de la remise;
  - aucune exposition BO d'un moteur `coupon / schedule`;
  - la regle annuelle particuliere est rappelee dans l'aide:
    - une duree `< 12 mois` sur une offre annuelle signifie `premiere facture annuelle uniquement`.

## Update 2026-04-07 — BO `Remises 2026`: nouveau chemin dedie sous `Commercial`
- audit court:
  - les modules legacy `remises` et `remises_offres` restaient fragiles pour la V1, car ils melangeaient trop de champs historiques et plusieurs write paths incompatibles avec le besoin courant;
  - le besoin reel porte uniquement sur le checkout Stripe de l'abonnement illimite `ABN 12`.
- resultat livre:
  - un nouveau module `ecommerce/remises_2026` est ajoute dans la navigation `Commercial`;
  - il porte un form dedie V1, sans dependance inutile aux formulaires legacy;
  - ce form bascule aussi automatiquement en `modifier` si une fiche existante est ouverte avec `id>0` sans `mode` explicite, pour eviter les duplications involontaires a l'edition;
  - il cree / met a jour la regle dans `ecommerce_remises` et la liaison front + pourcentage dans `ecommerce_remises_to_offres` pour l'offre `ABN 12`;
  - la liste permet aussi de supprimer une remise V1, avec purge des liaisons offre et comptes avant effacement de la regle;
  - la liste detaille aussi desormais le ciblage avec les noms reels de `pipeline` / `typologie`, et la vue affiche un recap numerique des comptes concernes;
  - la fiche rappelle aussi que la remise V1 Stripe s'applique par defaut sur `12 mois`;
  - il bascule automatiquement entre deux modes:
    - ciblage automatique par `typologie` et/ou `pipeline`
    - ciblage manuel par comptes explicites si ces deux champs sont vides;
  - la fiche fermee liste ensuite les comptes propres concernes, en excluant explicitement les TdR et les comptes rattaches a un reseau;
  - les anciens modules `remises` / `remises_offres` restent volontairement en logique legacy et ne sont plus le chemin cible de parametrage V1.

## Update 2026-04-03 — BO `facturation_pivot`: `Clients actifs` suit le mois de référence en `civil/fiscal`
- audit court:
  - le KPI haut `Clients actifs` était calculé sur le dernier mois de la plage affichée;
  - en `année civile` ou `année fiscale`, cela faisait lire respectivement `decembre` ou `aout`, meme quand l'utilisateur pilotait la vue depuis un mois de référence antérieur.
- resultat livre:
  - en `civil` et `fiscal`, `Clients actifs` est désormais relu sur le `mois de reference` sélectionné;
  - en `mois` et `3 derniers mois`, la logique reste inchangée;
  - ce réalignement porte sur le KPI haut, sans changer les autres tableaux de période.

## Update 2026-04-03 — BO `facturation_pivot`: conversions SaaS alignées sur les deux sources de démos
- audit court:
  - le tableau `Visiteurs / prospects / clients` exposait déjà séparément `Demos visiteurs` et `Démos nvx inscrits`;
  - la modale de conversion et certains ratios “réalisés” continuaient pourtant de raisonner sur la seule première source.
- resultat livre:
  - les calculs réels `visiteurs -> demos`, `demos -> inscrits` et `demos -> clients` utilisent maintenant l'agrégat `Demos visiteurs + Démos nvx inscrits`;
  - la présentation détaillée conserve les deux colonnes distinctes pour ne pas perdre l'origine des volumes affichés;
  - le budget n'est pas redéfini ici: seule la lecture des réalisations SaaS est réalignée.

## Update 2026-03-24 — BO clients: le lien EC temporaire se copie au lieu de s'ouvrir
- audit court:
  - la fiche client BO affichait bien l'URL du lien EC temporaire apres generation;
  - cette URL etait toutefois cliquable, ce qui favorisait une ouverture directe plutot qu'un partage interne.
- resultat livre:
  - l'URL generee est maintenant exposee comme une action de copie;
  - un bouton `Copier le lien` est ajoute avec feedback `Lien copié`;
  - le lien temporaire reste visible pour controle interne, sans navigation directe par defaut.

## Update 2026-03-23 — BO clients: génération d'un lien EC temporaire par contact
- audit court:
  - la fiche client BO listait deja les contacts et exposait un `gate.php` interne pour ouvrir l'EC en contexte admin;
  - aucun mecanisme BO ne permettait toutefois de generer un lien simple a transmettre a un contact pour ouvrir directement l'EC sans passer par le login.
- resultat livre:
  - la fiche client BO propose maintenant, pour chaque contact, une action interne `Generer un lien EC temporaire`;
  - l'action renvoie sur la meme fiche avec l'URL complete prete a copier;
  - ce lien repose sur le point d'entree PRO temporaire et n'est pas expose dans le front EC public.

## Update 2026-03-23 — BO reseau: alignement DB develop/prod sans `ecommerce_reseau_delegated_replacements`
- audit court:
  - la table dédiée `ecommerce_reseau_delegated_replacements` venait d'un état intermédiaire où les remplacements délégués différés devaient être rejoués par le cron BO;
  - l'état V1 final livré neutralise désormais ces remplacements (`replacement_disabled_v1`) et ne retient plus cette persistance comme schéma de référence.
- résultat livré:
  - le script phpMyAdmin `bdd_ecommerce_reseau_contrats.sql` ne crée plus cette table historique;
  - le même script la supprime explicitement si elle existe encore;
  - un SQL one-shot d'alignement `develop/prod` est ajouté à côté du module BO pour converger les bases déjà initialisées avec l'ancien schéma.

## Update 2026-03-20 — BO `facturation_pivot`: sessions SaaS allégées sans changer les KPI
- audit court:
  - le reporting SaaS relançait deux agrégations proches sur `championnats_sessions`:
    - une pour les sessions finies affichées dans le reporting
    - une seconde pour les seules sessions numériques utilisées dans les ratios;
  - la page BO devenait sensiblement plus lente au chargement sur les plages longues.
- résultat livré:
  - la première agrégation remonte désormais aussi `sessions_numeric`;
  - le second scan dédié est retiré;
  - les KPI restent inchangés:
    - volumes de sessions
    - ventilation par jeu
    - ratios fondés sur les seules sessions numériques.

## Update 2026-03-13 — BO réseau: remplacements délégués différés persistés en base dédiée
- audit court:
  - le cron BO des remplacements différés relisait encore les marqueurs `[reseau_replace:*]` et `[reseau_replace_timing:*]` dans `ecommerce_offres_to_clients.commentaire`;
  - le schéma importé via phpMyAdmin ne portait pas encore de table dédiée pour cette planification.
- résultat livré:
  - la base BO expose maintenant `ecommerce_reseau_delegated_replacements` pour les remplacements délégués planifiés;
  - le cron consomme d'abord cette table dédiée, puis garde un fallback legacy sur les anciens marqueurs pour les lignes déjà créées avant migration;
  - le comportement fonctionnel reste inchangé: seul le support de persistance du différé est remplacé.

## Update 2026-03-13 — BO réseau: navigation croisée TdR / offre support
- audit court:
  - la vue BO d'un `Abonnement réseau` n'exposait pas le client TdR dans son bloc haut;
  - la page `reseau_contrats` ne proposait pas non plus de lien direct depuis `Abonnement réseau actif` vers la fiche de l'offre support.
- résultat livré:
  - la fiche `offres_clients` d'un `Abonnement réseau` affiche maintenant `CLIENT` avec lien vers la fiche client de la TdR;
  - le libellé `Abonnement réseau actif` devient cliquable dans `Affiliés du réseau` quand l'offre support est résolue;
  - aucune logique métier réseau n'est modifiée, uniquement la navigation BO.

## Update 2026-03-13 — BO `reseau_contrats`: `Offre incluse cible` visible dans `Affiliés du réseau`
- audit court:
  - la synthèse haute affichait déjà l'état de l'abonnement réseau et les quotas;
  - l'offre de délégation incluse ciblée n'était toutefois pas visible dans ce bloc BO.
- résultat livré:
  - quand l'abonnement réseau est actif, le bloc `Affiliés du réseau` affiche aussi `Offre incluse cible`;
  - le libellé vient de l'offre canonique `id_offre_delegation_cible` déjà portée par la couverture réseau;
  - aucun write path ni recalcul de couverture n'est modifié.

## Update 2026-03-12 — BO `offres_clients`: clôture explicite de l'`Abonnement réseau` sans réactivation par fallback
- audit court:
  - le write path BO `offres_clients` fermait bien l'offre support reseau a la fin du flux;
  - mais une transition runtime intermediaire pouvait encore relancer un recalcul reseau avant la cloture effective de la ligne support;
  - apres archivage runtime, le resolver support reseau pouvait encore repartir en fallback sur une autre offre support `En attente` ou `Active` du meme siege.
  - la fiche client TdR relisait aussi la synthese reseau via un helper qui pouvait encore declencher une sync legacy pendant un simple chargement de page.
- resultat livre:
  - la cloture BO explicite d'une offre `Abonnement reseau` ne repasse plus par cette transition intermediaire;
  - un garde-fou final reverrouille aussi la ligne support en `Terminee` apres la rotation runtime;
  - un runtime reseau archive expose maintenant l'etat canonique `cloture` et interdit tout fallback automatique vers une autre offre support;
  - une reactivation redevient donc exclusivement un write path explicite BO/Stripe, pas un effet secondaire de lecture;
  - le refresh reseau canonique ne requalifie plus non plus tout seul l'offre support vers `En attente` ou `Active`; hors cloture runtime, il conserve l'etat deja ecrit par un write path explicite;
  - la fiche client TdR utilise maintenant une lecture BO pure de la synthese reseau, sans relance de sync legacy a l'affichage;
  - le flux conserve la fermeture explicite de l'offre support, la cloture des delegations actives et l'archivage runtime du contrat reseau;
  - aucune recreation implicite d'offre support n'est reintroduite.

## Update 2026-03-11 — Réseau: délégations incluses rattachées à l'abonnement source
- audit court:
  - aucune offre déléguée incluse ne portait l'id de l'`Abonnement réseau` source;
  - la restitution d'un abonnement réseau terminé dépendait donc encore d'indices secondaires.
- résultat livré:
  - les offres déléguées incluses portent désormais le champ facultatif `reseau_id_offre_client_support_source`;
  - ce champ reste vide (`0`) pour les offres déléguées hors abonnement réseau;
  - la lecture des `Offres incluses` peut désormais se brancher en priorité sur ce rattachement explicite.

## Update 2026-03-11 — BO `offres_clients`: `Offres incluses` relues depuis l’offre support affichée
- audit court:
  - l’aside `Offres incluses` et la synthèse de la fiche `Abonnement réseau` relisaient le contrat/support réseau courant du client;
  - la jointure persistait encore sur `id_offre_client_deleguee` courant de la table d’activation réseau, qui n’est pas un historique fiable par offre support;
  - une offre support terminée pouvait donc afficher les délégations du support actif, ou aucune ligne pertinente.
- résultat livré:
  - la fiche `Abonnement réseau` relit désormais l’offre support active via la couverture canonique runtime;
  - une offre support historique relit les offres déléguées incluses à partir des offres affiliées du siège, filtrées sur la période de l’offre support affichée;
  - les offres support `Terminées` continuent d’exposer leurs offres déléguées reliées, avec leurs statuts terminés si c’est le cas;
  - la synthèse BO n’emploie plus un compteur biaisé par un autre abonnement réseau actif.

## Update 2026-03-11 — BO `offres_clients`: garde-fou sur les abonnements réseau terminés
- audit court:
  - une édition BO d'une offre support réseau terminée pouvait encore repasser par la synchro runtime canonique;
  - ce flux risquait de la rerattacher comme support courant.
- résultat livré:
  - une offre `Abonnement réseau` déjà `Terminée` peut être modifiée sans redevenir support canonique;
  - la synchro BO réseau est sautée tant que l'offre reste `Terminée`;
  - un garde-fou force la persistance de l'état `Terminée` sur ce cas;
  - ce même garde-fou conserve explicitement `date_debut` et `date_facturation_debut`.

## Update 2026-03-12 — BO `reseau_contrats`: remise synthèse projetée sur la prochaine commande TdR
- audit court:
  - la synthèse `Remise réseau courante` relisait jusqu’ici le palier appliqué aux seules délégations `hors abonnement réseau` déjà actives;
  - le besoin d’exposition côté PRO porte en fait sur la remise qui sera appliquée à la prochaine commande passée par la TdR.
- résultat livré:
  - la synthèse haute du bloc `Affiliés du réseau` affiche désormais la remise calculée sur `volume actif courant + 1`;
  - le libellé visuel rappelle explicitement qu’il s’agit de la `prochaine commande TdR`;
  - la colonne `Tarif` des lignes déjà actives ne change pas de sémantique et continue d’afficher la remise réellement appliquée à ces lignes.

## Update 2026-03-11 — BO `reseau_contrats`: stabilisation de la gestion des affiliés
- audit court:
  - la vue mélangeait encore des signaux `cadre` et `hors abonnement` dans sa lecture secondaire;
  - un affilié sans offre pouvait exposer simultanément l'activation via abonnement réseau et la commande hors abonnement.
- résultat livré:
  - la lecture `hors abonnement réseau` ne retient plus une délégation déjà classée `cadre` quand `mode_facturation` est persisté;
  - le bloc `Affiliés du réseau` expose en tête la synthèse métier utile:
    - abonnement actif
    - quota limite / places disponibles
    - nb affiliés
    - nb offres actives incluses à l'abonnement réseau
    - nb offres actives hors abonnement réseau
    - remise réseau courante
    - nb affiliés sans offre active dont `CSO`;
  - l'action devient exclusive:
    - quota disponible => `Activer`
    - sinon => attribution d'une offre déléguée hors abonnement réseau;
  - les blocs séparés `Synthèse hors cadre`, `Commander une offre hors cadre` et `Offres affiliées hors cadre` sont retirés.
- garde-fous:
  - aucun cumul `cadre + hors abonnement` pour un même affilié;
  - `Abonnement réseau` reste le seul support canonique côté TdR;
  - les libellés métier sont réalignés sur `offre déléguée incluse à l'abonnement réseau` / `offre déléguée hors abonnement réseau`.

## Update 2026-03-11 — BO `reseau_contrats`: détail des offres terminées + compactage UI
- résultat livré:
  - la mention d'aide `Activation` est retirée du haut du bloc;
  - `dont offres terminées (CSO)` pointe maintenant vers le nombre réel d'offres déléguées réseau terminées;
  - une table récapitulative des offres déléguées hors abonnement réseau terminées est ajoutée en bas de page;
  - le formulaire d'attribution hors abonnement empile désormais ses trois champs pour limiter la largeur de la colonne `Actions`.

## Update 2026-03-11 — BO `reseau_contrats`: colonne `Tarif` relue avec exception cadre
- résultat livré:
  - la colonne `Offre` réaffiche la jauge de l'offre active quand elle existe;
  - la colonne `Offre` affiche aussi la période en cours de l'offre active quand elle est calculable;
  - une colonne `Tarif` est ajoutée dans la liste `Affiliés du réseau`;
  - lecture tarifaire appliquée:
    - `offre déléguée incluse à l'abonnement réseau` => pas de tarif affiché;
    - `offre déléguée hors abonnement réseau` => tarif HT selon la périodicité de la ligne;
    - `offre propre` => tarif HT de l'offre active;
    - `aucune offre` => `—`;
  - la synthèse haute affiche aussi le tarif négocié de l'abonnement réseau quand il est actif.

## Update 2026-03-11 — BO/Stripe alignés sur l'activation `Abonnement réseau`
- résultat visé:
  - l'activation admin BO et le paiement Stripe confirmé convergent désormais vers le même état final pour l'offre canonique `Abonnement réseau`;
  - `Etat offre=active` et `Etat contractuel=actif` sont synchronisés avant usage opérationnel du réseau.
- règle métier explicitée:
  - l'offre canonique reste la source de vérité;
  - l'état contractuel exposé par le runtime est dérivé de l'offre support, sans dépendre d'une colonne persistée `ecommerce_reseau_contrats.contract_state`.
- garde-fou:
  - aucune ancienne action contrat n'est réintroduite comme source principale;
  - le retour navigateur Stripe ne redevient pas un write path métier.

## Update 2026-03-11 — BO `offres_clients`: activation admin de `Abonnement réseau`
- audit court:
  - le form BO `Abonnement réseau` exposait déjà `id_etat`;
  - le rollback venait du refresh réseau générique déclenché trop tôt après `module_modifier(...)`.
- résultat livré:
  - le BO peut désormais forcer administrativement l'activation de l'offre canonique `Abonnement réseau`;
  - sur un passage `pending_payment -> active`, le script BO bypass le refresh prématuré, laisse l'offre persister à `3`, synchronise ensuite le contrat à `actif`, puis relance le refresh réseau;
  - le flow spécial de fin d'offre (`id_etat=4`) reste inchangé.
- garde-fous:
  - l'override admin porte bien sur l'offre canonique, pas sur un retour des anciennes actions contrat;
  - Stripe reste le flux standard côté PRO, mais pas une dépendance obligatoire pour ce changement d'état BO;
  - les actions contrat neutralisées `save_contrat`, `activate_contract`, `close_contract` ne sont pas réintroduites.

## Update 2026-03-11 — BO réseau durable: bouton TdR visible et pilotage affiliés
- audit court:
  - la fiche client TdR rendait déjà l'accès `reseau_contrats` au bon endroit, mais comme lien discret;
  - la vue `reseau_contrats` restait centrée sur le hors cadre et se décrivait encore comme écran transitoire.
- résultat livré:
  - le CTA méta devient un vrai bouton BO visible `Voir / gérer les affiliés`, rendu uniquement pour une TdR et placé juste sous `Tête de réseau`;
  - `reseau_contrats` devient explicitement la vue BO transverse durable de pilotage réseau;
  - la page liste désormais les affiliés du réseau avec lecture de couverture, activation via `Abonnement réseau` si quota disponible, attribution d'offre déléguée hors cadre, et désactivation des couvertures déléguées;
  - les actions contrat neutralisées `save_contrat`, `activate_contract`, `close_contract` ne sont pas réintroduites.
- garde-fous:
  - `Abonnement réseau` reste l'unique offre métier TdR canonique;
  - le dropdown historique `Offre propre` / `Offre réseau` n'est pas modifié;
  - le hors cadre reste branché sur les write paths existants d'offre déléguée.

## Update 2026-03-11 — Vue détail réseau et dates client TdR
- audit court:
  - la vue BO `offres_clients` rendait encore le bloc historique `Informations` par défaut, même pour `Abonnement réseau`;
  - la fiche client TdR lisait déjà correctement `date_debut` et `date_facturation_debut`, mais le write path réseau BO ne les persistait pas explicitement.
- résultat livré:
  - ajout d’un flag de vue module pour masquer `Informations` uniquement sur le support canonique `Abonnement réseau`;
  - complétion du sync BO réseau pour écrire `date_debut` et `date_facturation_debut`;
  - `Début` et `Début fact.` remontent désormais sur la fiche client TdR.

## Update 2026-03-11 — Vue `Abonnement réseau`: bloc dédié remonté
- audit court:
  - le bloc `Abonnement réseau` restait affiché en aside, donc après `Caractéristiques`;
  - les dates de début n’étaient pas visibles dans cette vue dédiée.
- résultat livré:
  - ajout d’un hook de vue haute pour rendre le bloc `Abonnement réseau` avant `Caractéristiques`;
  - ajout des lignes `Début` et `Début fact.` dans cette carte;
  - `Offres incluses` reste dans l’aside.


## Update 2026-03-11 — Correctif ciblé du point d’entrée `+` TdR
- audit court:
  - le flux `offres_clients` prérempli sur `Abonnement réseau` restait fonctionnel;
  - la détection TdR restait bien fondée sur `flag_client_reseau_siege=1`;
  - l’écart venait de `bo_clients_view.php`:
    - le `+` attendu avait disparu au profit de boutons directs;
    - puis le menu a été remis sur un bouton split, pas sur le `+` lui-même.
- résultat livré:
  - la fiche client TdR revient à un `+` avec choix rapide:
    - `Offre propre`
    - `Offre réseau`;
  - `Offre réseau` continue d’ouvrir `offres_clients` sur `Abonnement réseau`;
  - le clic sur `+` ouvre désormais directement le menu;
  - `Affiliés / hors cadre` reste un lien séparé transitoire.

## Update 2026-03-11 — Validation du point d’entrée standard `offres_clients`
- audit court:
  - la liste `offres_clients` n’a pas de header module dédié; le CTA `Ajouter` vient du core `bo_master_header.php`;
  - le contexte `id_client` filtré était déjà transmis au formulaire standard;
  - le support canonique `Abonnement réseau` restait déjà reconnu par le script et par `bo_module_form_extra.php`.
- résultat livré:
  - pour une liste `offres_clients` filtrée sur une TdR, `Ajouter` propose désormais:
    - `Offre propre`
    - `Offre réseau`;
  - `Offre réseau` ouvre `offres_clients` prérempli sur `Abonnement réseau`;
  - hors contexte TdR filtré, le CTA reste inchangé.

## Update 2026-03-11 — Correctif de résolution catalogue pour `Abonnement réseau`
- audit court:
  - le helper BO résolvait `Abonnement réseau` uniquement via `seo_slug`;
  - en dev, l’offre existait dans le catalogue BO et dans le filtre `Offre`, mais sans `seo_slug` canonique exploitable;
  - le select BO restait alimenté par `ecommerce_offres` trié par `nom`, d’où l’écart entre UI visible et helper à `0`.
- résultat livré:
  - fallback helper par `nom='Abonnement réseau'`;
  - synchronisation du `seo_slug` canonique si la ligne existe déjà;
  - dropdown BO `Ajouter` aligné sur Bootstrap 4 via `data-toggle="dropdown"`.

## Update 2026-03-11 — Fiche client TdR: réactivation du `+`
- audit court:
  - la fiche client TdR utilisait déjà le bon bouton dropdown unique et la bonne résolution catalogue;
  - l’attribut resté en Bootstrap 5 (`data-bs-toggle`) bloquait l’ouverture dans le runtime BO Bootstrap 4.
- résultat livré:
  - le `+` de la section `Offres` repasse en `data-toggle="dropdown"`;
  - `Offre propre` conserve le flux historique;
  - `Offre réseau` ouvre `offres_clients` prérempli sur `Abonnement réseau`.

## Update 2026-03-11 — Fiche client TdR: CTA meta vers la vue réseau durable
- audit court:
  - la fiche client TdR portait encore l’accès BO réseau dans la section `Offres`;
  - l’URL cible existait déjà et le guard TdR restait `flag_client_reseau_siege=1`.
- résultat livré:
  - l’URL `reseau_contrats` est hoistée pour être disponible dans le bloc meta;
  - le CTA apparaît désormais sous `Tête de réseau`;
  - le libellé visible devient `Voir / gérer les affiliés`;
  - l’ancien bouton de section `Offres` est retiré;
  - aucun autre flux BO n’est modifié.

## Update 2026-03-11 — Stabilisation BO minimale des points d’entrée réseau
- surfaces BO stabilisées:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- résultat canonique visé:
  - la fiche client TdR ouvre explicitement `Abonnement réseau` pour l’offre métier canonique;
  - l’accès à la vue BO réseau durable est porté dans le bloc meta sous `Tête de réseau`, avec le CTA `Voir / gérer les affiliés`;
  - `reseau_contrats` ne doit plus apparaître comme l’écran canonique du cadre négocié.
- état transitoire observé après patch:
  - `reseau_contrats` reste la vue BO de pilotage réseau utilisée en production pour les opérations affiliés / hors cadre;
  - ses write paths de contrat (`save_contrat`, `activate_contract`, `close_contract`) sont neutralisés côté script et requalifiés côté UI;
  - le moteur global support legacy n’est pas traité dans ce lot.

## Update 2026-03-11 — Re-baseline canonique réseau
- cible canonique:
  - une seule offre métier TdR: `Abonnement réseau`;
  - `Abonnement réseau` porte le cadre négocié et les offres incluses;
  - le hors cadre doit être géré depuis la page réseau par commande unitaire d’offres pour les affiliés choisis;
  - la destination BO cible devient une vue transverse `Gestion des affiliés`.
- état transitoire observé:
  - le BO reste encore partagé entre:
    - `offres_clients` pour la ligne `Abonnement réseau`
    - `reseau_contrats` pour la gestion/commande hors cadre;
  - `reseau_contrats` reste une vue BO réseau durable et héritée, pas un second objet métier canonique.
- règle de lecture:
  - toute mention de `Offre réseau` dans ce repo doit être comprise comme:
    - un héritage technique
    - ou un point d’entrée UI historique vers la vue réseau durable
    - jamais comme un second objet canonique concurrent.

## Update 2026-03-10 — Séparation BO canonisée: `Offre réseau` vs `Abonnement réseau`
- statut après re-baseline 2026-03-11:
  - ce bloc décrit l’état transitoire du lot BO du 2026-03-10;
  - il ne constitue plus la vérité canonique cible.
- `Offre réseau`:
  - reste la page BO `reseau_contrats`;
  - ne sert qu’au hors cadre:
    - lecture des offres affiliées hors cadre
    - création directe hors cadre
    - jamais de négocié sur cette page.
- `Abonnement réseau`:
  - devient une offre distincte créée via le flux standard `offres_clients`;
  - porte uniquement le négocié / cadre:
    - montant négocié
    - périodicité
    - nb d’affiliés inclus
    - offre incluse cible
    - jauge cible cadre;
  - sa vue BO détail affiche les offres incluses `cadre`, pas les lignes hors cadre.
- garde-fou métier:
  - l’objet `Abonnement réseau` est non effectif tant que son offre client reste `En attente`;
  - le hors cadre actif continue à vivre sur `Offre réseau` sans être relu comme une ligne incluse dans l’abonnement.

## Update 2026-03-10 — Étape 1 BO `reseau_contrats`: `Offre réseau` = hors cadre uniquement
- statut après re-baseline 2026-03-11:
  - `reseau_contrats` est documenté ici comme point d’entrée BO transitoire;
  - la cible n’est plus de stabiliser durablement un objet `Offre réseau` autonome.
- module `reseau_contrats`:
  - la page est renommée fonctionnellement `Gestion de l'offre réseau`;
  - elle ne pilote plus le contrat cadre, le montant négocié ni les paramètres du négocié;
  - elle sert désormais de lecture/gestion BO des seules offres affiliées hors cadre portées par la TdR.
- tableau BO:
  - n'affiche plus les affiliés `offre propre` ni `incluse contrat cadre`;
  - liste chaque ligne hors cadre avec:
    - affilié
    - offre
    - périodicité
    - statut
    - période
    - remise éventuelle
    - tarif;
  - conserve uniquement l'action `Désactiver` pour une ligne encore active.
- commande BO:
  - un bloc `Commander une offre hors cadre` reste disponible pour les affiliés sans offre active;
  - il force explicitement une création hors cadre directe et ne réactive jamais le cadre par effet de bord.
- wording BO:
  - la fiche client renomme l'entrée vers cette page en `Gérer l'offre réseau`.
- hors périmètre volontaire:
  - la future page BO du négocié / `Abonnement réseau`;
  - le renommage complet des wording PRO/public encore branchés sur l'offre réseau support existante.

## Update 2026-03-10 — BO `offres_clients`: `Terminer` une offre réseau clôt le réseau
- points d’entrée concernés:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- règle BO ajoutée:
  - si un opérateur BO passe l’offre réseau support à `Terminée` depuis `offres_clients`, le write path ne se contente plus d’écrire `id_etat=4`;
  - l’action déclenche une vraie clôture réseau cohérente:
    - contrat cadre clôturé
    - offres déléguées actives terminées immédiatement
    - activations affiliés marquées inactives
    - nouvelle offre réseau support `En attente` recréée/raccrochée au contrat pour un futur redémarrage.
- audit runtime 2026-03-10:
  - le write path réellement exécuté depuis l’édition BO `offres_clients` reste `do_script.php?...&p=script&mode=modifier`;
  - la reconnaissance de l’offre support ne dépend plus uniquement du catalogue `contrat-cadre-reseau`, mais aussi du rattachement canonique `ecommerce_reseau_contrats.id_offre_client_contrat`, ce qui couvre les lignes support legacy / migrées.
  - le `id_etat=4` posté par le BO était ensuite écrasé par le refresh générique `module_modifier(...) -> app_ecommerce_reseau_facturation_refresh_from_offer_client(...)`; ce refresh est désormais bypassé uniquement pour le cas explicite `offre support réseau -> Terminée`, afin de laisser le hook métier exécuter la clôture réelle.

## Update 2026-03-09 — BO `reseau_contrats`: ouverture contrôlée du formulaire contrat cadre
- module `reseau_contrats`:
  - si le contrat est `inactif` ou `cloture`, les champs de paramétrage sont masqués par défaut;
  - `Activer un contrat cadre` ouvre un formulaire complet de paramétrage;
  - la validation de ce formulaire persiste les paramètres puis active le contrat.
- contrat `actif`:
  - les champs restent visibles en lecture seule par défaut;
  - CTA `Modifier` pour passer en édition;
  - le CTA `Clôturer ce contrat cadre` reste visible seulement hors mode édition;
  - après sauvegarde, le formulaire se referme et revient en lecture seule.

## Update 2026-03-12 — Schéma pré-prod `reseau_contrats` réaligné sur l'existant utile
- module `reseau_contrats`:
  - le schéma cible du script phpMyAdmin ne porte plus `ecommerce_reseau_contrats.contract_state`;
  - l'état contractuel reste calculé à la lecture depuis la ligne support `ecommerce_offres_to_clients`;
  - le schéma cible ne porte plus non plus `max_joueurs_par_affilie`, désormais dérivé de `id_erp_jauge_cible`.
- colonnes explicitement conservées dans `ecommerce_reseau_contrats`:
  - `id`
  - `id_offre_client_contrat`
  - `id_client_siege`
  - `max_affilies_activables`
  - `id_offre_delegation_cible`
  - `id_erp_jauge_cible`
  - `montant_socle_ht`
  - `id_paiement_frequence`
  - `online`
  - `id_entite_utilisateur`
  - `date_ajout`
  - `date_maj`
- garde-fou:
  - aucune mise à jour de `documentation/canon/data/schema/DDL.sql` n'est faite tant qu'une source SQL canonique complète de `ecommerce_reseau_contrats*` n'est pas prouvée.

## Update 2026-03-09 — BO contrat cadre: montant hors cadre affiché après remise réseau
- module `reseau_contrats`:
  - la synthèse `Part variable affilies` reflète désormais le montant net après remise réseau volume;
  - le taux de remise appliqué est rappelé dans la synthèse, avec son assiette:
    - affiliés détenant une délégation active
    - `cadre` ou `hors_cadre`.
- tableau affiliés:
  - la colonne `Offre` affiche aussi la jauge de l’offre active;
  - ajoute une colonne `Tarif` dédiée;
  - `Déléguée incluse contrat cadre`:
    - montant négocié du cadre / nombre d’offres déléguées incluses;
    - format `HT / mois` par offre incluse active;
  - `Déléguée hors cadre`:
    - `HT` brut
    - `Remise réseau`
    - `HT appliqué / mois`;
  - `Offre propre`:
    - `HT / mois`;
  - `Pas d’offre`:
    - `-`.
- garde-fou:
  - la colonne `Offre` reste dédiée à l’identification de l’objet BO;
  - les montants sont isolés dans `Tarif`.

## Update 2026-03-09 — Vitrine pricing: référentiel unique minimal
- la vitrine tarifaire abonnement ne doit plus porter sa propre grille métier:
  - la source de référence est désormais le helper global `app_ecommerce_tarifs_reference_*`.
- portée:
  - `fo_tarifs_offre_detail.php` continue d’afficher le widget partagé;
  - le panier vitrine (`fo_offres_paniers_form_script.php` -> `app_ecommerce_offre_panier_gerer(...)`) recalcule désormais le `prix_ht` côté serveur quand le cas est couvert.
- garde-fou:
  - si une fréquence / offre n’est pas couverte par le référentiel minimal, le fallback legacy reste autorisé.

## Update 2026-03-09 — CTA BO `Activer` unifié + flux hors cadre complet
- module `reseau_contrats`:
  - `Activer` reste visible pour tout affilié sans offre active, hors cas `Offre propre`;
  - l’ancienne condition d’affichage ne montrait le CTA que si:
    - quota cadre disponible
    - ou offre cible déjà définie
    - ou délégation legacy déjà sélectionnable;
  - la nouvelle condition est métier:
    - pas d’offre active
    - pas d’offre propre active
    - donc CTA `Activer` affiché.
- comportement BO:
  - si le contrat cadre est exploitable:
    - création auto de l’offre cible cadre
    - activation dans le cadre;
  - sinon, même flux hors cadre pour:
    - pas de contrat exploitable
    - pas d’offre cible cadre
    - quota cadre atteint
  - ce flux hors cadre expose:
    - choix de l’offre
    - choix de la jauge / capacité
    - puis création d’une nouvelle délégation hors cadre.
- tableau affiliés:
  - ajoute les sélecteurs BO nécessaires au hors cadre directement dans la colonne `Action`.
  - le choix de réactivation d’une ancienne délégation n’est plus exposé dans la vue.

## Update 2026-03-09 — Fermeture 2A contrat cadre réseau
- module `reseau_contrats`:
  - recharge désormais le reclassement métier au chargement de la page;
  - affiche explicitement les 3 paramètres du contrat cadre:
    - montant négocié
    - quota max d’affiliés inclus
    - offre SI dédiée cible
  - expose une synthèse quota:
    - délégations actives résolues
    - quota absorbé
    - quota restant
- liste affiliés:
  - la source d’affiliation reste strictement `clients.id_client_reseau`;
  - la colonne métier devient une lecture de couverture commerciale calculée:
    - `offre propre`
    - `offre déléguée incluse contrat cadre`
    - `offre déléguée hors cadre`
    - `aucune offre`
- règle BO:
  - le reclassement `cadre / hors_cadre` n’est plus un pilotage manuel principal;
  - il dérive du quota négocié, de l’ancienneté des délégations legacy actives et du fait que le cadre soit réellement exploitable (`offre cible + quota`).

## Update 2026-03-09 — Tableau BO affiliés refondu
- page concernée:
  - `reseau_contrats` -> tableau `Affiliés du siège`
- rendu simplifié:
  - colonnes:
    - `Affilié`
    - `Statut commercial`
    - `Offre`
    - `Action`
- lecture métier:
  - suppression des anciennes lectures techniques `Activation réseau` et `Offre déléguée résolue`;
  - affichage direct de l’offre active réellement concernée avec lien BO;
  - action clarifiée:
    - `Non pilotable ici` pour une offre propre
    - `Désactiver` pour une délégation active
    - `Activer` sinon.
- câblage CTA:
  - `Activer` n’est plus un simple marquage d’activation:
    - crée l’offre cible si nécessaire
    - ou réactive une offre déléguée existante
    - puis rejoue le reclassement cadre/hors cadre;
  - `Désactiver` termine la ligne d’offre déléguée active concernée, puis relance refresh + reclassement.

## Update 2026-03-09 — BO contrat cadre réseau: couverture affilié explicite pour éviter la double comptabilisation
- module `reseau_contrats`:
  - expose désormais un pilotage affilié de `mode_facturation` au niveau du contrat réseau;
  - valeurs BO:
    - `Inclus dans le cadre`
    - `Facturé en plus`
- stratégie finale:
  - toute ancienne délégation active issue TdR est initialisée en `Facturé en plus` (`hors_cadre`);
  - le BO permet ensuite de reclasser explicitement l’affilié en `Inclus dans le cadre` (`cadre`) lorsqu’il est absorbé par la négociation.
- objectif:
  - ne plus conserver d’état transitoire `legacy`;
  - laisser au BO réseau le réglage explicite entre part fixe cadre et part variable affiliés.

## Update 2026-03-09 — BO contrat cadre: état explicite et CTA métier
- module `reseau_contrats`:
  - expose un état contractuel lisible, mais désormais dérivé de l’offre support réseau;
  - n’utilise plus `ecommerce_reseau_contrats.contract_state` comme colonne runtime;
  - conserve les anciennes actions contrat BO neutralisées, sans les réintroduire comme write path métier.
- effet métier:
  - chaque changement d’état réel de l’offre support relance:
    - le recalcul de l’agrégat de l’offre réseau support;
    - le reclassement cadre / hors cadre;
    - le recalcul du quota exploitable.
- synthèse BO:
  - distingue désormais:
    - `Cadre négocié`
    - `Socle appliqué à l’agrégat`
    - `Part variable affiliés`
- garde-fou:
  - le schéma pré-prod de référence retire `contract_state`; aucun fallback SQL de lecture de cette colonne n’est encore requis.

## Update 2026-03-09 — BO contrat cadre réseau TdR: écran simplifié
- module `reseau_contrats`:
  - supprime de l’écran courant les CTA de maintenance legacy déjà couverts automatiquement au chargement;
  - ferme le choix de l’offre support:
    - affichage en lecture seule `Offre support`
    - lien discret vers la ligne `offres_clients` existante;
  - recentre le formulaire sur la lecture métier:
    - `Montant cadre négocié (HT)`
    - capacité d’activation affiliés
    - joueurs max par affilié.
- champs retirés du premier écran:
  - `Jauge cible (référentiel)`
  - `Offre cible de délégation (catalogue)`
- point métier:
  - l’écran simplifié reste aligné avec l’agrégateur réseau;
  - la distinction `cadre / hors_cadre` est désormais pilotée dans la liste des affiliés.

## Update 2026-03-09 — Fiche client BO TdR: exclusion des offres déléguées legacy
- la section `Offres` de la fiche client siège réseau n’affiche plus les lignes legacy déléguées vers affiliés.
- règle de filtrage:
  - sur un client `flag_client_reseau_siege=1`, exclure les lignes `ecommerce_offres_to_clients` avec `id_client_delegation>0`.
- la fiche client BO affilié remonte désormais aussi les offres legacy déléguées:
  - inclusion des lignes `ecommerce_offres_to_clients` où `id_client_delegation = affilié` et `id_client <> affilié`;
  - rendu léger: nom du compte TdR dans la colonne `Délégation`.
- restent visibles:
  - offres propres TdR
  - offre support `Contrat cadre réseau`
- aucune nouvelle section dédiée n’est ajoutée:
  - la synthèse des délégations reste portée par la vue `reseau_contrats`.

## Doc discipline
- `canon/repos/www/TASKS.md` à mettre à jour à chaque action significative (update-not-append si une tâche existe déjà).
- `canon/repos/www/README.md` à mettre à jour dès qu’un changement impacte le fonctionnel côté BO/FO.
- En cas de divergence, le code fait foi ; corriger la doc immédiatement.

## Scope principal
- Back-office `www`: `www/web/bo/www/modules/**`.
- Reporting SaaS pivot: `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`.

## Update 2026-03-08 — BO réseau (backfill offre dédiée)
- module `reseau_contrats`:
  - auto-vérifie la présence de l’offre réseau dédiée du siège à l’ouverture de la page.
  - expose un bouton opérateur: `Créer / rattraper offre réseau dédiée`.
  - script associé: `mode=backfill_siege` (retour UI `backfill_ok`).
- objectif:
  - sécuriser le rattrapage des sièges legacy sans attendre une migration manuelle globale.

## Update 2026-03-09 — BO réseau (facturation persistée TdR)
- module `reseau_contrats`:
  - le BO édite désormais un `montant socle réseau HT / mois` distinct du montant agrégé des offres affiliées.
  - la synthèse affiche le montant facturable total de la TdR:
    - socle réseau
    - plus offres affiliées actives financées par la TdR.
- persistance:
  - le socle reste stocké dans `ecommerce_reseau_contrats.montant_socle_ht`.
  - le `prix_ht` de la ligne support `ecommerce_offres_to_clients` reflète le montant facturable courant recalculé.
- effet BO:
  - le contrat cadre réseau et l’offre réseau support restent cohérents sans écriture opportuniste dispersée dans les vues BO.
  - la fiche client siège répercute aussi ce montant facturable sur la ligne d’offre `Contrat cadre réseau` dans la section `Offres`.

## Reporting BO — métriques démos (référence)
- Section `Objectifs`:
  - `Demos` = démos visiteurs (`id_client=1557`) + démos des nouveaux inscrits sur la période de référence.
  - Sémantique conservée: comptage en **nombre de sessions démo** (`COUNT(cs.id)`), pas en distinct utilisateurs.
- Tableau `Visiteurs / prospects / clients`:
  - Colonne `Démos nvx inscrits`.
  - Définition: session démo dans la période ET client inscrit (`clients.date_ajout`) dans la même période.
  - Exclusions: client démo technique `id_client=1557`, clients test `id_etat=4`.
- Détail modal (clic sur la colonne): même filtre que la métrique agrégée (mois + période de référence + exclusions).

## Reporting BO — `Jeux et joueurs` (sessions/joueurs)
- `Sessions`: inclut les sessions papier et numériques, dès lors qu’elles sont terminées et configuration complète (hors démos).
- `Joueurs`: inchangé, basé sur les joueurs numériques.
- Ratios:
  - `Moy. joueurs / client`
  - `Moy. joueurs / session`
 sont calculés uniquement sur les sessions numériques (papier exclu du dénominateur de ces ratios).

## BO Réseau — Contrat cadre (Étape 2)
- Entrée métier depuis la fiche client siège:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - CTA: `Gestion contrat réseau / délégation`.
- Module BO dédié:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- Contrat commercial conservé dans `ecommerce_offres_to_clients` (support Stripe/statut/validité).
- Capacités + activation affilié tracée via persistance dédiée (`ecommerce_reseau_contrats`, `ecommerce_reseau_contrats_affilies`).
- Garde-fou:
  - écriture brute de `id_client_delegation` verrouillée par défaut dans le CRUD générique (`allow_delegation_raw_write=1` requis pour bypass legacy explicite).

## BO `offres_clients` — Support canonique `Abonnement réseau`
- Le formulaire BO de `ecommerce/offres_clients` reste rendu par le moteur générique, avec un hook minimal vers un renderer dédié de module si nécessaire.
- Pour l’offre canonique `Abonnement réseau` sur une tête de réseau:
  - un renderer BO dédié est utilisé;
  - les champs éditables exposés restent ceux du cadre négocié:
    - `Etat offre`
    - `Montant négocié HT`
    - `Périodicité négociée`
    - `Nb affiliés inclus`
    - `Jauge cible cadre`
    - `Offre incluse cible`
- Hors contexte support canonique, le form standard `offres_clients` reste sur son comportement historique.

## BO Reporting jeux — Cron dédié et lecture sur agrégats
- Le bloc d'agrégats jeux du BO est maintenant factorisé dans `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php`.
- Deux points d'entrée coexistent:
  - `www/web/bo/cron_routine_bdd_maj.php` reste la routine historique "commerce" et n'execute plus les agrégats jeux;
  - `www/web/bo/cron_reporting_games_aggregates.php` porte le cron dedie "jeux", execute le helper partage et envoie son propre mail de rapport.
- Les tables actuelles re-utilisees par le reporting sont:
  - `reporting_games_sessions_monthly`
  - `reporting_games_players_monthly`
  - `reporting_games_players_by_type_monthly`
  - `reporting_games_sessions_detail`
  - `reporting_games_demos_detail`
  - `reporting_games_content_popularity_365d`
- `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` privilegie desormais ces agrégats pour les sessions mensuelles et la serie N-1 quand ils sont disponibles; le brut reste en fallback.

## Update 2026-04-14 — FO fiche `place` (lazy loading onglets)
- la fiche établissement publique ne rend plus `Agenda` ni `Sessions passées` côté serveur au premier hit;
- les deux onglets sont chargés à la demande via `fo_clients_view_ajax.php`:
  - `section=agenda`
  - `section=archive`
- le rendu session FO est mutualisé dans `fo_clients_view_shared.php` pour éviter les écarts entre page principale et fragments AJAX;
- l'onglet `Classements` reste affiché par défaut au chargement, mais si la réponse AJAX indique qu'aucun leaderboard exploitable n'existe sur la période, la page bascule automatiquement vers `Agenda`.
- addendum perf:
  - les `Classements` et la synthèse haute ne partagent plus la même requête AJAX;
  - `section=overview` charge d'abord les leaderboards;
  - `section=summary` charge ensuite la synthèse historique, ce qui permet d'afficher plus vite le bloc métier le moins coûteux.
  - les leaderboards FO `place` disposent maintenant aussi d'un cache de session court par `client + jour + année + trimestre`, pour éviter le recalcul de la même saison lors des retours sur la fiche ou des changements aller/retour de sélecteur.
  - addendum archives FO: la fiche `place` s'appuie maintenant sur un helper global dédié `app_client_joueurs_dashboard_archive_sessions_get(...)`, extrait de la logique d'archives pro, pour sélectionner les sessions passées utiles du lieu.
  - addendum leaderboard FO: la colonne droite `sessions récentes` réutilise ce même helper global avec filtre jeu/date, au lieu d'une reconstruction locale.
  - addendum correctif AJAX FO: l'onglet `Agenda` n'utilise plus `fo_sessions_list_bloc.php` dans ce contexte asynchrone; il rend maintenant une carte FO dédiée, comme `Sessions passées`, pour éviter les fatals legacy.
  - addendum correctif JS: le sélecteur de saison des classements recharge désormais bien la saison demandée; l'appel `loadOverview(...)` passait auparavant les paramètres dans le mauvais ordre et retombait sur la saison courante.

## Update 2026-04-14 — FO listes `agenda` / `place` (géographie FR + étranger)
- le pattern `Département / pays` déjà posé côté agenda FO/play est désormais aussi appliqué à la liste publique des organisateurs `place`;
- le select `www/fo/place` ne se limite plus aux départements français:
  - départements réellement présents dans la liste publique;
  - puis pays étrangers réellement présents;
- côté FO, les départements conservent leur libellé référentiel complet (`n° + nom`) au lieu d'un simple numéro.
- addendum:
  - l'option `France` n'est pas proposée dans la section `pays`, les départements FR couvrant déjà ce cas;
  - le libellé du menu joueur passe à `Agenda des soirées jeux`, avec hardening CSS `white-space: nowrap` sur la navigation desktop et les liens de dropdown pour éviter les retours à la ligne parasites.
  - le rendu archive FO `place` reste appuyé sur les cartes sessions legacy; le helper global `cotton_quiz_get_classement_session(...)` est maintenant sécurisé pour ne plus faire tomber l'endpoint archive si une requête résultat quiz échoue sur un cas ancien.
  - addendum correctif: l'onglet `Sessions passées` de `place` n'embarque plus le bloc FO legacy complet; il passe désormais par une carte dédiée rendue dans `fo_clients_view_shared.php`, plus sûre pour l'AJAX et sans dépendance à la branche legacy `photo gagnant quiz`.
  - addendum leaderboard FO: la colonne droite `sessions récentes` des classements s'appuie maintenant sur les `ranked_session_ids` renvoyés par le moteur global, ce qui réaligne strictement les sessions affichées sur celles réellement comptées dans le classement agrégé.

## Update 2026-04-15 — FO includes `photos_ec` réalignés sur `main`
- les includes FO locaux de `photos_ec` avaient été rechargés depuis prod et divergeaient désormais nettement de `main` sur:
  - `www/web/fo/includes/css/fo_custom.css`
  - `www/web/fo/includes/css/fo_custom_20251120.css`
  - `www/web/fo/includes/header/fo_header_main.php`
  - `www/web/fo/includes/footer/fo_footer_main.php`
  - `www/web/fo/includes/js/fo.js`
- ces 5 fichiers ont été réalignés sur le contenu de `main` pour corriger une régression visuelle constatée sur `photos_ec`, sans modifier les évolutions métier spécifiques de branche sur `place` et `agenda/session`.
- effets restaurés:
  - styles homogénéisés des logos de références FO;
  - filtres noir/blanc et hover des logos;
  - wrapper d'harmonisation des images catalogue/démo;
  - header et JS FO cohérents avec `main`.

## Update 2026-04-15 — FO fiche `place`: podium agrégé dans `Classements`
- l'onglet `Classements` de la fiche `place` affiche désormais un podium au-dessus du tableau `Top 10`;
- le podium reprend les données déjà calculées par le moteur global:
  - `teams_podium` pour `Cotton Quiz`;
  - `players_podium` pour `Blind Test` et `Bingo Musical`;
- le rendu visuel réemploie le style du podium de la page détail d'une session terminée du site:
  - bandeau de rang `#1/#2/#3`;
  - accent or / argent / bronze;
  - visuel joueur/équipe si disponible, sinon placeholder trophée/médaille;
  - score et participations sous le libellé;
- l'intégration reste localisée à `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`, juste avant le titre `Top 10` de chaque classement agrégé;
- addendum desktop:
  - le podium est maintenant affiché pleine largeur au-dessus de la ligne `classement + sessions récentes`;
  - la colonne droite `sessions récentes` revient à une limite basée sur la seule hauteur du tableau de classement, ce qui réaligne son départ visuel sur la table desktop.
  - la ligne desktop `classement + sessions récentes` utilise maintenant un espacement horizontal plus explicite (`justify-content-between` + gutters renforcés) pour mieux occuper la largeur disponible.
  - audit structurel complémentaire:
    - l'alignement visuel desktop conserve un `padding-top: 3rem` sur `.place-leaderboard-recent-sessions-col`;
    - la colonne `sessions récentes` s'appuie maintenant sur un wrapper simple centré à largeur max, sans grille Bootstrap interne `row > col-12`.
- addendum responsive:
  - le tableau `Top 10` passe maintenant par un wrapper explicite `place-leaderboard-table-responsive` pour réaffirmer le scroll horizontal mobile;
  - la colonne flex du tableau force désormais `min-width: 0`, pour que le scroll horizontal puisse jouer au lieu de faire déborder la page;
  - sur petits écrans, `.table-classement` reçoit aussi une largeur minimale, afin de forcer le scroll horizontal plutôt qu'un tassement des colonnes avec coupe du contenu;
  - un `rem` parasite a aussi été retiré de `fo_custom.css` dans cette zone.

## Update 2026-04-15 — FO fiche `place`: perf lot 1 sur `Classements` / `Sessions passées`
- la route AJAX `overview` de `fo_clients_view_ajax.php` ne charge plus l'agenda complet ni les 12 `sessions passées` juste pour renvoyer les leaderboards;
- les flags `has_agenda` et `has_archive` sont maintenant calculés via des helpers FO bornés à un seul résultat;
- `fo_clients_view_archive_sessions_get(...)` et la colonne `sessions récentes` appellent désormais le helper global archive en mode `historique seul`, sans relire les sessions à venir;
- effet attendu:
  - premier chargement `Classements` plus léger;
  - moins de travail serveur inutile avant ouverture effective de `Sessions passées`.

## Update 2026-04-15 — FO fiche `place`: tableau plein large, colonne `sessions récentes` masquée
- la colonne desktop `sessions récentes` a finalement été retirée de l'onglet `Classements`;
- le tableau `Top 10` reprend maintenant toute la largeur disponible du bloc sous le podium;
- le code HTML/CSS de l'ancienne colonne reste conservé en commentaire pour réutilisation ultérieure;
- le calcul serveur correspondant reste neutralisé:
  - `fo_clients_view_leaderboard_sections_get(...)` ne déclenche plus `fo_clients_view_recent_ranked_sessions_get(...)`;
  - le format mobile du tableau n'est pas modifié et conserve son wrapper responsive dédié.

## Update 2026-04-15 — FO fiche `place`: enrichissement de `Sessions passées`
- les cartes de l'onglet `Sessions passées` essaient désormais d'afficher en illustration la photo du participant ou de l'équipe classé(e) rang 1 sur la session;
- si aucune photo exploitable n'est remontée par `app_session_results_get_context(...)`, la carte conserve le visuel de jeu ou du lieu déjà en place;
- l'onglet archive est maintenant paginé par lots de 12 cartes:
  - premier chargement inchangé à 12;
  - bouton `Afficher plus` en bas de bloc;
  - ajout incrémental de 12 cartes supplémentaires via AJAX sans recharger tout l'onglet.
- addendum:
  - quand la photo du rang 1 est utilisée, son `src` reprend maintenant le même pattern que les photos podium/résultats déjà en place, sans suffixe de version artificiel;
  - le CTA `Afficher plus` reprend le style repo `btn btn-color-20 m-2` avec flèche à droite.
  - correctif complémentaire: sur les cartes archive injectées en AJAX, la photo du rang 1 n'est plus laissée en lazy-load `src="#"`; elle est servie directement avec fallback `onerror`, ce qui réactive son affichage effectif.

## Update 2026-04-16 — FO fiche `place`: descriptions lieu normalisées
- la baseline courte et le descriptif long d'un lieu passent maintenant par la même normalisation texte que l'espace `pro`;
- les anciens `<br>` / balises résiduelles sont nettoyés avant affichage;
- le rendu public conserve les retours à la ligne utiles sans dépendre d'un HTML saisi dans le back-office.

## Update 2026-04-16 — FO fiche `place`: fallback image `Sessions passées`
- les cartes de `Sessions passées` ne lazy-loadent plus leur visuel principal une fois injectées en AJAX;
- effet visible: quand aucune photo gagnant n'est disponible, le fallback sur le visuel de jeu s'affiche bien dans la carte au lieu de rester sur `src="#"`;
- le fallback `onerror` des photos gagnant reste inchangé pour les cas où une photo principale existe mais échoue au chargement.

## Update 2026-04-17 — FO agenda: retrait des sessions deja terminees

Les listes `www` qui alimentent:
- l'onglet `Agenda` des fiches `place`;
- la page publique `agenda`;
- le widget agenda;

ne s'appuient plus uniquement sur `app_sessions_get_liste(... a_venir=1 ...)`.

Apres chargement, elles repassent maintenant par le helper partage `app_sessions_filter_by_archive_state(...)`. Une session numerique deja terminee le jour meme quitte donc bien l'agenda public et devient eligible a `Sessions passées` sur la fiche lieu, sans attendre le lendemain.

Le bloc `fo_sessions_list_bloc.php` utilise aussi cette meme regle pour son etat `Jeu termine`.

## Update 2026-04-17 — FO `Sessions passées`: prise en compte des sessions du jour terminées

Le helper `fo_clients_view_archive_sessions_get(...)` appelait encore l'archive globale avec `include_upcoming_sessions = 0`.

Effet de bord: une session du jour deja terminee pouvait etre retiree de l'onglet `Agenda`, mais ne pas remonter dans `Sessions passées` tant que sa date n'etait pas passee.

Le branchement utilise maintenant `include_upcoming_sessions = 1`, ce qui permet a l'onglet `Sessions passées` de recuperer aussi ces sessions du jour deja archivees par la regle metier.

## Update 2026-04-17 — FO `place`: podium agrégé `Bingo Musical` aligné sur les autres jeux

Le builder `fo_clients_view_leaderboard_podium_cards_get(...)` gardait une branche speciale pour `bingo` qui regroupait tous les ex-aequo d'un meme rang dans une seule carte.

Cette exception a ete retiree. Le podium agrégé `www` construit maintenant ses cartes comme pour `blindtest` et `quiz`: tri stable par rang puis par ordre source, puis une carte par ligne de podium.

Effet attendu: sur la fiche `place`, trois joueurs `#1` en `Bingo Musical` occupent trois cartes distinctes sur la ligne podium, au lieu d'etre empiles dans la seule colonne `#1`.

## Update 2026-04-17 — WWW sessions `quiz`: libellé compact `1 serie` / `x series`

Les cartes session et le `h1` de la page detail `www` ne se contentent plus du `theme` brut renvoye par `app_jeu_get_detail(...)` pour `Cotton Quiz`.

Elles utilisent maintenant en priorite `quiz_series_label` quand il est disponible sur la ligne session, ce qui permet d'afficher un libelle court adapte aux contraintes d'espace:
- `1 serie`
- `2 series`
- `4 series`

Si ce libelle n'est pas disponible, le fallback conserve `theme`, mais ne l'affiche plus lorsqu'il duplique simplement `nom_court` (`Cotton Quiz Cotton Quiz`).

## Update 2026-04-17 — WWW sessions `quiz`: raccord au helper partagé

La logique locale `www` a ete remplacée par un appel direct au helper `global` `app_session_quiz_compact_label_get(...)`.

Effet attendu: `www`, `play` et `pro` reposent maintenant sur la même règle de libellé compact pour `Cotton Quiz`, avec le même fallback vers les anciens formats.

## Update 2026-04-17 — Fiche session `www`: mention de réserve sous les séries programmées

La fiche détail session `www` affiche maintenant une petite mention italique sous le bloc `Séries programmées`:

`(Sous réserve de modification par l'organisateur.)`

La mention n'apparaît que tant que la session n'est pas archivée.

## Update 2026-04-17 — Fiche session `www`: bloc playlist visible pour `blindtest` / `bingo`

La carte détail session `www` expose maintenant aussi un bloc visible entre `Date` et `Lieu` pour les jeux musicaux:

- `Playlist : {nom_playlist}`
- puis la mention `(Sous réserve de modification par l'organisateur.)` tant que la session n'est pas archivée.

Effet attendu: `Blind Test` et `Bingo Musical` disposent du même niveau d'information contextuelle que `Cotton Quiz` sur la fiche session publique.
## Update 2026-05-11 — LP operations reseau automatiques depuis TdR
- ecran concerne:
  - `/lp/operation/{slug}`
  - fallback direct possible via `/lp/lp.php?utm_source=reseau&utm_campaign=affiliation&utm_term={slug}&utm_medium=landing-operation`
- resultat livre:
  - la landing reseau n'est plus alimentee par `www/web/lp/includes/config/lp_operations.php`, supprime du fonctionnement standard;
  - `/lp/operation/{slug}` est conserve comme compatibilite legacy: il reutilise la resolution TdR/reseau de `/lp/reseau/{slug}` et ne depend plus de `operations_evenements`;
  - critere public minimal: compte marque `flag_client_reseau_siege=1`, slug exact, compte non `online=0` si le champ existe;
  - les donnees affichees viennent de la TdR, du branding reseau et de l'abonnement reseau actif le plus recent si sa personnalisation LP est active;
  - le badge periode n'affiche des dates que si un abonnement reseau actif est detecte et si debut + fin fiables existent cote support reseau;
  - le CTA principal reste le lien technique `/utm/reseau/{slug}` pour laisser le parcours PRO existant gerer signup/signin, affiliation et activation incluse;
  - la landing conserve les anciennes LP historiques (`offre-essai`, `1-jeu-offert`, `brasserie-trompe-souris`, `saison-hiver`) hors routes reseau dediees.
- limite documentee:
  - aucune notion explicite de champ `publiable` n'a ete trouvee dans le modele local; le garde-fou choisi refuse les comptes non TdR, mais ne conditionne plus l'existence de la LP a un abonnement reseau actif.
# Repo `www` - update LP reseau 2026-05-11

La LP publique reseau est maintenant l'entree recommandee pour les partenaires distributeurs: `/lp/reseau/{slug}`. `/lp/operation/{slug}` reste une compatibilite qui reutilise la meme source TdR/reseau.

Le BO `ecommerce/offres_clients` affiche un bloc `Page reseau / operation` sur les offres client de type `Abonnement reseau`. Ces champs personnalisent titre, accroche, description et CTA lorsque l'abonnement reseau actif le plus recent est actif et que la personnalisation LP est active.

Sans abonnement reseau actif, la LP reste accessible pour rejoindre Cotton avec le badge hero `Invitation Cotton` et le CTA `Rejoindre Cotton`, sans promesse d'acces inclus. Les dates ne sont affichees que si debut et fin sont fiables; si un abonnement actif existe sans dates completes, le badge hero devient `Abonnement Cotton inclus`. Le slug public optionnel est sauvegarde mais la route standard V1 reste le slug TdR. `operations_evenements` n'est pas la source produit centrale de cette LP.
