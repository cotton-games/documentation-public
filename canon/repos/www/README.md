# Repo `www` — Carte IA d’intervention (canon)

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
