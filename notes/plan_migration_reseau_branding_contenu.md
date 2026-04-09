# Plan migration reseau / branding / contenu

> Statut 2026-03-18: document de travail historique, non canonique.
> Il n'est plus le bon niveau de rebaseline produit pour TdR/Affiliés.
> Pour l'etat courant de reference, lire d'abord:
> - `canon/repos/pro/README.md`
> - `canon/repos/pro/TASKS.md`
> - `HANDOFF.md`
> - `CHANGELOG.md`
>
> Rebaseline 2026-03-19:
> - hypotheses abandonnees / non retenues en V1 finale:
>   - upsell/downsell delegue;
>   - changement d'offre `hors cadre`;
>   - auto-reclassement `hors cadre -> cadre`;
>   - remplacement manuel `hors cadre`;
>   - recreation automatique d'un support `En attente`.
>
> Perimetre:
> - cette note reste reservee aux sujets `TdR / Affilies / branding / contenu`;
> - les evolutions `remises` ABN hors reseau sont documentees dans:
>   - `canon/repos/global/README.md`
>   - `canon/repos/global/TASKS.md`
>   - `canon/repos/pro/README.md`
>   - `canon/repos/pro/TASKS.md`
>   - `HANDOFF.md`

## Role du document

Ce plan sert de document de pilotage historique.

Il doit permettre:
- de suivre ce qui etait prevu;
- de voir ce qui a effectivement ete livre;
- de tracer les arbitrages pris en cours de route;
- de conserver visibles les etapes restantes.

Il ne doit plus etre lu comme baseline produit active ni comme source de verite UI/metier.

Point de methode:
- la version historique exacte ecrasee n'a pas pu etre relue depuis un historique local Git: non trouve;
- cette version est une reconstruction alignee sur l'existant, a partir:
  - du plan partage en piece jointe;
  - des audits et notes d'implementation produits pendant le lot reseau;
  - de l'etat reel du code et de la documentation a date.

## Vision cible historique

La cible produit de travail etait:
- une TdR qui pilote explicitement son reseau;
- une offre support visible `Abonnement reseau`;
- une distinction nette entre affiliation, acces effectif et offre propre;
- un branding reseau comprehensible;
- une visibilite contenu reseau simple;
- une remise reseau reservee aux delegations hors abonnement, mais calculee sur le volume actif pertinent du reseau.

## Rebaseline 2026-03-12

> Cette rebaseline n'est plus le referentiel produit courant.
> Elle reste utile pour comprendre la trajectoire de lot, mais l'etat final livre a depuis evolue.

### Update 2026-03-16 — Etape 6 contenu reseau v1 livree
- le point d'entree unique reste `/account/network`;
- le CTA `Contenus réseau` ouvre maintenant un hub bibliothèque dedie cote TdR;
- la persistance retenue ajoute un etat transverse `partagé au réseau` via une table globale dediee:
  - pas de nouvelle nature source;
  - origine `Cotton / Communauté / Mine` conservee;
  - write path cote `pro/global`;
- la TdR peut:
  - voir les contenus deja partages;
  - parcourir la bibliothèque existante pour partager / retirer;
  - lancer les flows de creation depuis la bibliothèque, puis partager le contenu une fois exploitable;
- l'affilié n'a pas de page réseau de management:
  - la bibliothèque expose seulement `Playlists du réseau` / `Séries du réseau`;
  - ce raccourci est exclusif des autres filtres, mais non exclusif de visibilité metier.

### Update 2026-03-17 — Etape 6 contenu reseau v1.1: arrivée TdR dédiée + onglet affilié
- le principe metier de la V1 est conserve:
  - pas de nouvelle nature source `Réseau`;
  - persistance transverse conservee;
  - write path TdR inchangé;
- ajustement UX TdR:
  - `Contenus réseau` n'ouvre plus d'abord un choix de jeu;
  - la TdR arrive sur une page dédiée de management, avec explication, CTA vers la bibliothèque et liste agrégée des contenus déjà partagés tous jeux confondus;
  - tant que ce parcours est actif, la navigation gauche conserve le contexte `Mon réseau`;
  - le header de cette page est simplifie autour de `Retour à Mon réseau`, du titre et d'un sous-titre, sans bloc introductif redondant;
- ajustement UX affilié:
  - l'entree bibliothèque sans jeu peut maintenant afficher un bloc `Jeux du réseau` qui ouvre un hub global lecture seule tous jeux confondus quand du contenu existe;
- ajustement UX complementaire TdR:
  - la TdR voit elle aussi ce bloc `Jeux du réseau` depuis le portail bibliothèque, pour accéder directement a la page de gestion reseau;
  - le filtre réseau par catalogue jeu a finalement ete retire pour eviter une navigation doublon avec ce portail global;
- la vérité de source reste visible sur les cartes:
  - `Cotton`
  - `Communauté`
  - `Mine`
  - la chip `Réseau` peut s'ajouter comme marqueur de diffusion, cote TdR comme cote affilié.

### Update 2026-03-17 — Etape 6 contenu reseau v1.2: durcissement logique retenu
- l'etat canonique final du lot est maintenant clarifié:
  - entrée TdR via `/account/network`, puis `Jeux du réseau` vers `library?network_manage=1`;
  - entrée affilié via la carte portail bibliothèque `Jeux du réseau`, en lecture seule;
  - aucun onglet réseau par catalogue n'est retenu comme état final;
- la persistance `ecommerce_reseau_content_shares` reste en lazy-init pour ce lot:
  - pas de migration SQL dédiée extraite maintenant;
  - l'unicité métier reste portée par l'assurance de schéma runtime sur `(id_client_siege, game, content_type, source_id)`;
- les write paths sont durcis:
  - seule la TdR proprietaire peut partager / retirer;
  - un affilié ne peut pas écrire, même par POST manuel;
  - une source inactive, supprimée ou non exploitable ne peut plus être partagée;
- les lectures réseau excluent maintenant silencieusement ces sources non exploitables, pour éviter les remontées cassées cote TdR et affilié.

### Update 2026-03-17 — Mon reseau V1 finale: hiérarchie simplifiée
- `/account/network` finalise maintenant sa hierarchie visible cote TdR:
  - `Lien d'affiliation` en premier;
  - `Personnalisation` juste apres avec CTA `Design reseau` et `Contenus reseau`;
  - `Mes affiliés` directement ensuite, sans bloc `Facturation` intermediaire;
- la synthese utile est raccrochee au tableau `Mes affiliés`:
  - `Actifs / Inactifs`;
  - badge `Abonnement reseau` si support actif;
  - `Inclus dans votre abn reseau / Places restantes` quand le support est actif;
- cette finition ne change ni la verite metier reseau, ni les endpoints PRO deja retenus pour les actions affiliés;
- le CTA `Contenus reseau` de `Mon reseau` continue d'ouvrir le hub canonique `library?network_manage=1`.

### Update 2026-03-19 — Mon reseau: micro-synthese support retablie sans revenir au bloc facturation
- la zone `Mes affiliés` reaffiche une micro-synthese directement sous sa phrase d'aide;
- le rendu retenu se limite au badge support actif puis a `Nombres d'affiliés activables via l'abonnement réseau : restantes/quota`;
- la source de verite reste la couverture canonique du support (`quota_remaining` / `quota_max`) et non un recomptage UI;
- le lien de sortie reste `Offres`, sans reintroduire les anciens blocs de facturation/detail support dans la page reseau.

### Update 2026-03-17 — Mon offre TdR: hypothese d'agregat `hors cadre` abandonnee
- hypothese historique conservee pour memoire:
  - ce lot ouvrait un agregat `Offres affiliés à la charge de votre réseau` dans `Mon offre`;
- non retenu en V1 finale:
  - la reference produit finale ne passe pas par cet agregat;
  - les offres `hors_cadre` restent listees unitairement dans `Offres & factures` quand elles sont encore actives et facturees a la TdR.

### Update 2026-03-16 — Etape 5 branding reseau v1 livree
- le socle technique retenu reste la route branding PRO historique:
  - `view`
  - `form`
  - `script`
- en revanche, la cible UX n'est plus le module branding PRO legacy:
  - la page TdR `Design reseau` est maintenant refondue autour d'un point d'entree dedie depuis `/account/network`;
  - l'experience reprend explicitement les repères utiles de personnalisation cote games:
    - couleurs;
    - police;
    - logo;
    - visuel;
    - apercu de rendu proche de l'attente de session.
- le bloc `Personnalisation` de `/account/network` expose aussi l'etat du design reseau:
  - `Aucun design reseau personnalise`;
  - `Actif`;
  - `Actif jusqu'au ...`;
  - `Expire`.
- la regle metier de validite est maintenant introduite proprement:
  - nouveau champ `valable_jusqu_au`;
  - actif jusqu'a la fin du jour selectionne;
  - au-dela, la couche type `3` reseau est ignoree dans la resolution effective;
  - les couches session/evenement et les personnalisations plus specifiques gardent leur priorite.
- la reinitialisation reseau est definie comme une suppression de la couche personnalisee:
  - pas de copie cachee restauree;
  - retour simple a l'heritage restant.
- une migration SQL dediee porte la colonne `general_branding.valable_jusqu_au`.
- ajustement post-recette upload:
  - en cas de doute, le flux branding reseau PRO s'aligne desormais sur la logique d'upload games pour les medias branding;
  - la normalisation MIME/extension est faite avant upload;
  - le core accepte `jpg|jpeg|png|webp`;
  - le save reste volontairement proche du comportement historique du module branding PRO: remplacement direct, sans restauration automatique d'un ancien media pendant l'enregistrement.
  - la relecture des medias branding versionne maintenant aussi `logo` et `visuel` avec `filemtime`, pour eviter qu'un ancien asset mis en cache masque le save reussi.

### Update 2026-03-13 — Remplacement délégué différé: hypothese abandonnee
- historique utile:
  - ce lot avait ouvert des hypotheses de remplacement manuel / differe pour les delegations `hors_cadre`;
- non retenu en V1 finale:
  - pas d'upsell/downsell delegue;
  - pas de changement d'offre `hors cadre`;
  - pas d'auto-reclassement `hors cadre -> cadre`;
  - toute persistance de remplacement doit donc etre lue ici comme historique de travail, pas comme reference finale.

### Update 2026-03-13 — Navigation BO support reseau
- la fiche `Abonnement reseau` expose maintenant explicitement la TdR concernee dans son bloc haut;
- la vue BO `reseau_contrats` permet aussi de revenir directement a la fiche de l'offre support active via `Abonnement reseau actif`;
- ce lot reste un ajustement de navigation BO, sans changement de write path ni de verite metier reseau.

### Update 2026-03-13 — Commande deleguee PRO: tunnel sur la typo TdR, sans essai gratuit
- la commande deleguee `Commander` ouvre maintenant le segment catalogue conforme a la typologie de la TdR qui paie;
- le contexte affilié ne promet plus d'essai gratuit dans le tunnel, pour rester aligne avec la persistance `trial_period_days = 0` des offres deleguees `pending`;
- ce lot ne change pas le principe metier: une commande deleguee reste une offre payee par la TdR, sans essai gratuit.

### Update 2026-03-13 — Commande deleguee PRO: wording CTA et confirmation remise alignes
- la premiere etape du tunnel affiche maintenant `Commander` en contexte affilié, sans wording ambigu d'essai;
- le texte marketing CHR du tunnel retire aussi la mention `testez pendant 15 jours` dans ce contexte;
- la page de confirmation expose aussi le pourcentage sur `Remise reseau` quand il est stocke sur l'offre;
- aucun calcul de remise ni comportement de paiement n'est modifie.

### Statut de pilotage compact

> Statut historique a conserver pour lecture de trajectoire uniquement.
- relecture V1 finale:
  - les explorations `Changer d'offre`, upsell/downsell delegue, remplacement manuel et auto-reclassement `hors_cadre -> cadre` ne sont pas retenues comme etat final;
  - ce qui suit reste donc de l'historique de pilotage, pas une cible produit encore active.
- etapes `1 / 2 / 2A / 2B`: closes fonctionnellement;
- etape `3`: close cote code livre, avec reserve de recette Stripe reelle de bout en bout;
- lot `3 actions affilies`:
  - `3A` = UI PRO minimale branchee sur les endpoints dedies, sans reactivation directe depuis `Mon reseau`; les cas hors abonnement passent par le parcours historique de l'offre ou restent preparatoires;
  - `3B` = write paths metier PRO explicites pour les actions affilies: livre;
- priorite immediate avant future prod:
  - hardening final des etapes `1 / 2`;
  - validation Stripe reelle finale de l'etape `3`;
  - cadrage puis implementation separee du lot `3 actions affilies` sans melanger lecture PRO et writes BO;
- etapes `4 / 5 / 6`: volontairement non ouvertes a ce stade.

### Statut par etape
- `Etape 1`: close fonctionnellement.
- `Etape 2`: close fonctionnellement.
- `Etape 2A`: close fonctionnellement.
- `Etape 2B`: close fonctionnellement.
- `Etape 3`: close cote implementation, avec reserve Stripe.
- `Lot 3 actions affilies / 3A / 3B`: socle serveur + UI minimale livres, avec reserve sur la commande hors abonnement neuve encore non ouverte depuis la page.
- `Etapes 4 / 5 / 6`: hors lot.

### Restant avant future prod
- purge complete des fallbacks legacy encore actifs ou encore appelables;
- audit final colonne par colonne de `ecommerce_reseau_contrats`;
- migration SQL de nettoyage des colonnes mortes prouvees;
- mise a jour du script d'import phpMyAdmin:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`;
- normalisation documentaire canonique du schema `ecommerce_reseau_contrats*` autant que possible avec sources prouvees;
- recette Stripe reelle finale pour transformer l'etape `3` en fermeture pleinement exploitable.

### Hors lot explicite

> Cette section n'est plus a interpreter comme un perimetre produit actuel.
- etape `4` - UX PRO reseau;
- etape `5` - branding reseau;
- etape `6` - contenu reseau;
- refontes de confort / refacto cosmetique;
- elargissements fonctionnels non necessaires a la pre-prod.

## Update 2026-03-12 — Rebaseline lot 3 `actions affilies`

### Clarification de nomenclature
- l'`Etape 3` documentee plus bas conserve son sens historique:
  - remise reseau dynamique;
  - repricing local / Stripe des delegations `hors abonnement reseau`;
- le present rebaseline ouvre un chantier distinct:
  - lot `3 actions affilies`;
  - decoupe en `3A` puis `3B`;
- objectif:
  - eviter toute confusion entre le lot deja livre sur la remise reseau et le pilotage PRO affilie encore a creer.

### Conclusion d'audit retenue
- cote PRO, seuls les flux support reseau / Stripe sont aujourd'hui prouves comme canoniques:
  - paiement de l'offre support reseau existante;
  - acces portail Stripe quand il est reellement preparable;
  - lecture des statuts / couverture / hors abonnement depuis les helpers canoniques;
- les actions metier affilie restent `BO-only` a ce stade:
  - activation incluse a l'abonnement reseau;
  - desactivation incluse a l'abonnement reseau;
  - creation / reactivation d'une delegation `hors abonnement reseau`;
- aucun write path metier PRO explicite n'est encore prouve pour ces actions;
- l'ecriture brute de delegation via `id_client_delegation` reste interdite cote PRO.

### Lot 3A — UI / cadrage PRO sans write path affilie
- perimetre autorise:
  - lecture claire des statuts et de l'actionnabilite;
  - conservation des seuls flux PRO deja prouves:
    - support reseau;
    - portail Stripe;
  - explicitation front de ce qui est:
    - pilotable cote PRO;
    - reserve au BO;
    - non pilotable pour une offre propre affilie;
- perimetre interdit:
  - aucun CTA metier affilie tant qu'un endpoint PRO dedie n'existe pas;
  - aucune creation / reactivation / desactivation affilie depuis un chargement ou un simple affichage;
  - aucune reinterpretation de `Mon reseau` en write path cache.

### Lot 3B — write paths metier PRO explicites
- objectifs minimums:
  - `activate_included`;
  - `deactivate_included`;
  - `create_or_reactivate_hors_cadre_for_affiliate`;
- principe de mise en oeuvre:
  - wrappers metier PRO explicites autour des helpers globaux deja existants;
  - controles serveur explicites sur:
    - legitimite TdR;
    - offre propre affilie hors pilotage;
    - respect quota / distinction `cadre` vs `hors_cadre`;
  - aucune reutilisation du CRUD generique de delegation;
  - aucune ecriture SQL brute directe sur `id_client_delegation`.

### Matrice de perimetre retenue
- `PRO OK`:
  - paiement / activation de l'offre support reseau existante via Stripe;
  - acces portail Stripe support reseau quand la session portail est reellement preparable;
  - lecture des statuts `offre propre` / `deleguee hors abonnement` / `incluse abonnement reseau` / `inactive`;
- `BO-only`:
  - activation incluse abonnement reseau;
  - desactivation incluse abonnement reseau;
  - creation / reactivation d'offre affiliee `hors abonnement reseau`;
  - changement explicite de `mode_facturation`;
- `interdit cote PRO`:
  - ecriture brute de delegation via `id_client_delegation`;
  - action sur une offre propre affilie;
  - creation implicite d'une offre support reseau;
  - ecriture au chargement.

### Garde-fous obligatoires pour 3A et 3B
- aucune ecriture au chargement;
- aucune auto-creation d'offre support;
- aucune action sur les offres propres affilie;
- historique BO conserve;
- contrat Stripe intact:
  - portail uniquement quand disponible;
  - pas de regression sur support reseau ni abonnements delegues;
- distinction preservee:
  - offre propre;
  - offre deleguee hors abonnement;
  - offre incluse abonnement reseau;
  - affilie inactif;
- remise reseau reservee aux delegations `hors abonnement reseau`.

## Update 2026-03-12 — Lot 3B serveur: socle PRO explicite minimal

### Cadrage retenu pour ce patch
- le lot `3B` n'ouvre toujours pas de CTA front definitif;
- il livre uniquement le socle serveur PRO minimal necessaire pour exposer plus tard des actions affilie sans repasser par du BO HTML ni par le CRUD generique;
- `Mon reseau` reste donc une surface de lecture / pilotage partiel cote TdR tant qu'aucun cablage UI explicite n'est pose sur ces nouveaux endpoints.

### Ce qui est maintenant cree cote serveur PRO
- nouvelle route dediee:
  - `/extranet/account/network/script`;
- nouveau script PRO dedie aux actions affilie:
  - `activate_included`;
  - `deactivate_included`;
  - `create_or_reactivate_hors_cadre_for_affiliate`;
- nouveau token de session dedie aux actions reseau affilie cote PRO:
  - scope `network_affiliate_actions`;
  - validation serveur explicite avant tout write.

### Principe technique retenu
- les nouveaux endpoints PRO n'appellent pas directement les fonctions nommees `..._from_bo(...)`;
- des wrappers globaux neutres et explicites portent maintenant la logique metier:
  - `app_ecommerce_reseau_activation_activate_included_for_affiliate(...)`;
  - `app_ecommerce_reseau_activation_deactivate_included_for_affiliate(...)`;
  - `app_ecommerce_reseau_activation_create_or_reactivate_hors_cadre_for_affiliate(...)`;
- les anciens write paths BO historiques restent branches sur la meme logique metier via:
  - `app_ecommerce_reseau_activation_activate_affiliate_explicit(...)`;
  - `app_ecommerce_reseau_activation_deactivate_affiliate_explicit(...)`.

### Garde-fous effectivement appliques dans le socle 3B
- legitimite TdR verifiee serveur:
  - client siege present;
  - `flag_client_reseau_siege = 1`;
- ownership affilie verifie serveur:
  - `clients.id_client_reseau = id_client_siege`;
- refus explicite si:
  - offre propre affilie active;
  - affilie hors perimetre de la TdR;
  - offre cible hors abonnement absente / invalide;
  - jauge cible absente;
  - quota inclus indisponible;
  - support reseau inactif pour `activate_included`;
  - mode d'activation incoherent pour `deactivate_included`;
- aucune ecriture directe sur `id_client_delegation`;
- desactivation canonique preservee:
  - `id_etat = 4`
  - `date_fin` renseignee si absente.

### Ce qui reste volontairement hors patch
- aucun CTA front definitif sur `/account/network`;
- aucune redirection implicite vers le tunnel EC standard pour "commander pour un affilie";
- aucun refactor BO d'interface;
- aucun write au chargement de page;
- aucune ouverture du CRUD generique delegation cote PRO.

### Update 2026-03-12 — Evolution `3B` livree: commande deleguee hors abonnement via le tunnel classique
- objectif livre:
  - reutiliser la page de selection d'offre existante et le tunnel de commande classique;
  - permettre a une TdR de payer une offre `hors abonnement reseau` pour un affilie depuis `/account/network`;
  - creer une offre deleguee `pending` avant paiement, puis seulement l'attacher au reseau apres validation.
- principe effectivement retenu:
  - pas de nouveau tunnel;
  - pas de mini formulaire catalogue parallele sur `Mon reseau`;
  - ajout d'un mode `commande deleguee` dans le tunnel existant.

### Etape 3B.1 — contexte de commande deleguee
- point d'entree PRO livre via `/account/network/script`:
  - initialise un contexte serveur `commande deleguee hors abonnement`;
  - verifie:
    - legitimite TdR;
    - ownership de l'affilie;
    - absence d'offre propre active;
    - absence de delegation active existante.
- contexte minimal effectivement porte:
  - `id_client_siege`;
  - `id_client_affilie`;
  - `id_contrat_reseau` si un contrat reseau existe encore pour cette TdR;
  - `mode = delegated_hors_cadre`;
  - token de session court.

### Update 2026-03-17 — Realignement `3B` avec abonnement reseau facultatif
- la disparition du contrat reseau automatique est maintenant actee runtime pour les flows `hors cadre`;
- consequence:
  - `commande deleguee hors abonnement` et changement d'offre `hors cadre` ne doivent plus bloquer sur `network_contract_missing`;
  - l'activation reseau persistée dans `ecommerce_reseau_contrats_affilies` devient opportuniste pour le `hors_cadre`:
    - ecriture si un contrat existe;
    - aucune ecriture requise sinon;
- les flows `cadre` / `included` restent, eux, conditionnes a l'existence d'un support reseau actif et d'un contrat resolu.

### Etape 3B.2 — catalogue existant reutilise avec contexte affilie
- la page de selection d'offre existante est conservee cote UX;
- en mode delegue:
  - un bandeau `Commande pour [affilie]` / `Payee par votre reseau` est affiche;
  - les boutons catalogue injectent le token de contexte explicite;
  - un contexte invalide bloque les CTA de selection et n'ouvre jamais une commande `en propre`.

### Etape 3B.3 — remise reseau integree au catalogue
- la remise reseau s'applique des la selection d'offre si elle est > 0 pour la TdR;
- source canonique retenue:
  - `app_ecommerce_reseau_volume_actif_get_count(...)`;
  - `app_ecommerce_remise_volume_reseau_get_pourcentage(...)`;
- regle retenue et implantee:
  - calculer la remise sur le volume actif `apres commande`;
  - donc `volume_after = volume_before + 1` pour une nouvelle delegation `hors abonnement reseau`.
- effet livre dans le tunnel:
  - tous les tarifs affiches au catalogue sont presentes en net remisé;
  - l'ancien prix reste visible barre;
  - un libelle `Remise reseau X%` est affiche.

### Etape 3B.4 — creation d'une offre deleguee `pending`
- un helper dedie cree l'offre deleguee en attente de paiement;
- difference avec une commande classique:
  - `id_client = TdR`;
  - `id_client_delegation = affilie`;
  - `id_etat = 2`;
  - `prix_ht = prix net remisé`;
  - `remise_nom = 'Remise reseau'` si applicable;
  - `remise_pourcentage = X` si applicable.
- garde-fou majeur conserve:
  - `Commander` ne reutilise jamais `app_ecommerce_reseau_offre_deleguee_create_for_affilie(...)`;
  - cette fonction reste reservee aux creations actives sans paiement.

### Etape 3B.5 — branchement du `step=1` du tunnel classique
- au `step=1`, si un contexte `delegated_hors_cadre` est present:
  - l'offre choisie est reverifiee;
  - une offre deleguee `pending` est creee a la place d'une offre `en propre`;
  - la redirection reste le meme `manage/s2/<id_securite>` que le tunnel standard.
- hors contexte delegue:
  - comportement strictement inchange.

### Etape 3B.6 — paiement Stripe coherent avec la remise reseau
- contrainte livree:
  - montant affiche au catalogue = montant stocke en base = montant effectivement paye.
- implementation retenue:
  - le checkout delegue ne s'appuie plus sur le `lookup_key` catalogue standard;
  - le checkout Stripe delegue utilise un `price_data` dynamique base sur le `prix_ht` stocke de l'offre `pending`;
  - aucun fallback silencieux vers le checkout standard n'est autorise si le contexte delegue est incoherent.

### Etape 3B.7 — validation et attachement reseau post-paiement
- la validation d'offre existante reste reutilisee:
  - une offre avec `id_client_delegation > 0` pilote deja le pipe de l'affilie;
- ajout livre apres validation:
  - rattachement de l'offre payee a la persistance d'activation reseau `hors_cadre`;
  - sans recreer d'offre;
  - sans activation avant paiement;
  - avec garde idempotent si l'attachement existe deja.

### Garde-fous specifiques verifies sur cette evolution `3B`
- aucune activation avant paiement;
- aucun fallback silencieux vers une commande `en propre`;
- aucune action si l'affilie dispose d'une offre propre active;
- aucune action si une delegation active existe deja pour cet affilie;
- aucune divergence entre:
  - prix affiche;
  - prix stocke;
  - prix facture par Stripe.

## Update 2026-03-12 — Lot 3A UI: cablage minimal des actions affilie sur `Mon reseau`

### Perimetre effectivement livre
- la page `Mon reseau` branche maintenant les endpoints PRO dedies deja exposes par `3B`;
- l'injection UI est volontairement minimale:
  - bloc d'actions inline dans la colonne `Detail` de chaque ligne affilie;
  - aucun changement de structure lourde du tableau;
  - aucun write au chargement.

### Matrice de visibilite retenue
- `Activer via l'abonnement`:
  - seulement si l'affilie n'a aucune offre active;
  - pas d'offre propre;
  - abonnement reseau actif;
  - cible incluse et jauge cible definies;
  - quota exploitable avec place restante.
- `Desactiver`:
  - seulement si l'affilie est actif via l'abonnement reseau;
  - activation explicite courante en mode `cadre`.
- `Gerer l'offre`:
  - seulement si une offre deleguee active `hors abonnement reseau` est resolue;
  - seulement si cette offre deleguee porte une preuve Stripe (`asset_stripe_productId`);
  - ouvre le parcours historique de l'offre concernee, celui qui permet ensuite l'acces au portail Stripe.
- `Commander`:
  - ouvre maintenant le catalogue historique dans un contexte affilie explicite;
  - ne laisse aucun fallback vers une commande en propre si ce contexte est invalide;
  - ne propose toujours aucune reactivation directe depuis la page.
- `Offre propre`:
  - lecture seule explicite;
  - aucun CTA metier.

### Messages utilisateur ajoutes
- succes:
  - `network_affiliate_activate_included_ok`;
  - `network_affiliate_deactivate_included_ok`;
  - `network_affiliate_hors_cadre_ok`.
- refus / erreurs metier:
  - offre propre active;
  - quota inclus atteint;
  - cible offre / jauge / frequence manquante ou incoherente;
  - affilie invalide / hors reseau;
  - contrat reseau manquant;
  - action non autorisee / token invalide;
  - fallback erreur generique.

### Reserve conservee
- le lot ne livre toujours pas de reactivation directe `hors abonnement reseau` depuis la page;
- le seul flux neuf autorise est `Commander` via le tunnel classique avec contexte affilie explicite, remise reseau portee jusqu'au checkout, puis rattachement post-paiement.

## Update 2026-03-12 — Desactivation incluse: couverture courante prioritaire sur l'historique `mode_facturation`

### Cause precise
- un affilie pouvait etre affiche `Inclus dans votre abonnement reseau` parce que la couverture courante le reclassait `cadre`;
- dans le meme temps, la desactivation `deactivate_included` pouvait rester bloquee si la ligne d'activation courante conservait encore `mode_facturation='hors_cadre'`;
- il y avait donc incoherence entre:
  - lecture front / couverture courante;
  - precondition serveur de desactivation incluse.

### Correctif retenu
- la UI ne requalifie plus les badges a partir de `mode_facturation`;
- le bouton `Desactiver` suit le statut `cadre` effectivement affiche, sous reserve d'une activation active;
- le write path `deactivate_included` accepte aussi le cas ou la couverture courante prouve que l'affilie est actuellement `cadre`, meme si l'historique d'activation n'a pas encore suivi.

## Update 2026-03-12 — Premier lot UX PRO `Mon reseau`

### Cible retenue
- `Mon reseau` devient la page de gestion operationnelle cote TdR;
- `Mon offre` reste un point d'entree synthetique et ne porte pas la gestion detaillee des affilies;
- le produit visible cote front reste unique: `Abonnement reseau`.

### Ce qui est utilise sans nouveau chantier back
- facturation / statut support via `app_ecommerce_reseau_facturation_get_detail(...)`;
- couverture et statuts affilies via `app_ecommerce_reseau_contrat_couverture_get_detail(...)`;
- branding reseau via `app_general_branding_get_detail(...)`;
- lien d'affiliation via le `seo_slug` client deja expose cote PRO.

### Premier lot livre
- reorganisation de `/account/network` autour de blocs simples:
  - synthese reseau
  - couverture / activation
  - mes affilies
  - hors abonnement reseau
  - personnalisation du reseau
  - lien d'affiliation
- suppression de la reconstruction locale principale des statuts affilies au profit des labels deja prepares par la couche globale;
- wording front simplifie pour faire comprendre rapidement:
  - combien d'affilies existent
  - qui est couvert via l'abonnement reseau
  - qui reste hors abonnement reseau
  - qui a une offre propre
  - qui n'a pas de couverture active

### Limites assumees du lot
- aucun nouveau write path PRO;
- aucune action d'activation / desactivation directe depuis cette page;
- pas de reouverture de `Mon offre`;
- pas de nouveau second objet metier visible cote TdR.

## Update 2026-03-12 — Simplification UX cible `/account/network`

### Cible UX retenue apres revue
- la page ne doit plus chercher a tout expliquer en tete;
- la hierarchie cible devient:
  - ligne 1: `Synthese de mon reseau` + `Facturation`
  - ligne 2: `Lien d'affiliation` + `Personnalisation`
  - puis `Mes affilies` pleine largeur;
- les blocs `Couverture et activation`, `Hors abonnement reseau` et `Prochaines actions` sortent du scope.

### Lecture donnee retenue
- les compteurs de tete deviennent:
  - `Affilies`
  - `Actifs`
  - `Inactifs`;
- la synthese ne remonte plus le detail `inclus / hors abonnement` en phrase dediee;
- la synthese renforce visuellement les 3 cadres de compteurs;
- la synthese remplace finalement ce detail actif par un simple lien `Liste complete des affilies de mon reseau` pointant vers le tableau;
- ce detail reste reserve a la liste `Mes affilies`.

### Facturation retenue
- le bloc `Facturation` doit fusionner:
  - le socle `Abonnement reseau` si le support est actif;
  - les offres affiliees `hors abonnement reseau` prises en charge par la TdR;
- les montants et periodes doivent reutiliser les helpers canoniques existants;
- le rappel d'acces a `Mon offre` sort du header et reste dans le bloc `Facturation` sous forme de lien simple;
- ce lien doit reutiliser la meme logique de destination et le meme libelle que `Mon offre` quand Stripe est disponible:
  - paiement si offre support en attente
  - portail si abonnement actif
  - reactivation si resiliation programmee
- les resumes de montant doivent rester explicitement bornes aux offres deleguees effectivement classees `hors abonnement reseau` par la couverture canonique;
- le socle actif doit etre affiche en lecture compacte `HT [TTC]` avec `Nb affilies limite` et `Nb de places restantes`;
- si l'offre cible de delegation est connue canoniquement, elle doit etre visible sous la forme `Offre attribuee : {nom}`;
- si aucune charge reseau n'existe, le bloc doit afficher un message vide simple plutot qu'un diagnostic technique.

### Lien d'affiliation retenu
- le lien doit etre affiche inline;
- la copie doit se faire au clic sur le lien lui-meme ou via une petite chip icone, pas via un bouton CTA.
- la phrase d'aide se fond dans le sous-titre du bloc, avec wording different selon abonnement reseau actif ou non.

### Personnalisation retenue
- le CTA principal devient `Design reseau`;
- un second CTA `Contenus reseau` est visible mais laisse a cabler ulterieurement.
- une ligne placeholder sur les contenus reseau partages reste visible en attendant le cablage donnees.

### Tableau `Mes affilies`
- un filtrage front simple par statut doit rester possible sans nouveau resolver:
  - acces compact depuis le titre de colonne `Statut` via une petite chip `Filtrer` avec icone
  - le declencheur reste visible par defaut, sans dependre d'un hover
  - options bornees aux statuts reellement presents dans la liste;
  - menu compact, lisible et sans debordement quand les libelles de statuts sont longs;
  - le fond du panneau suit la hauteur reelle de la liste et reste superpose proprement au-dessus du tableau;
- les badges front cibles deviennent:
  - `Actif abonnement reseau`
  - `Actif via le reseau` si la TdR n'a aucun abonnement reseau actif
  - `Actif en supplement` si la TdR a un abonnement reseau actif
  - `Actif offre propre`
  - `Inactif`;
- la colonne detail doit privilegier:
  - une formulation metier courte
  - la periode en cours quand elle est canoniquement calculable
  - le tarif hors abonnement quand il est disponible proprement;
- les formulations historiques ou trop techniques ne sont plus souhaitees cote client final.

## Update 2026-03-12 — Correctif regression cloture BO + portail Stripe PRO

### Regression BO corrigee
- le passage BO explicite d'un `Abonnement reseau` vers `Terminee` doit rester prioritaire sur les normalisations runtime automatiques;
- le flux de cloture BO est corrige pour fermer l'offre support et archiver le runtime sans etape intermediaire de recalcul reseau parasite;
- un garde-fou final reverrouille aussi la ligne support en `Terminee` apres la rotation runtime.
- un contrat runtime archive ne doit plus fallbacker automatiquement vers une autre offre support `En attente` ou `Active` du meme siege;
- la reprise d'un reseau archive redevient donc une action explicite de reactivation, pas un effet secondaire d'une lecture canonique.
- la fiche client TdR ne doit pas non plus relancer de sync legacy reseau en simple lecture BO; la synthese y est maintenant lue sans write path implicite.
- plus largement, le recalcul reseau canonique ne doit plus fabriquer lui-meme les transitions support vers `En attente` ou `Active`: ces etats doivent venir d'un write path explicite, BO pour `En attente`, BO ou Stripe pour `Active`.

### Regression PRO corrigee
- `Mon offre` ne doit pas exposer au client final les diagnostics techniques Stripe du type `customer Stripe absent`;
- pour une offre support reseau geree manuellement cote BO, l'absence de portail Stripe exploitable devient un non-message front;
- les traces techniques restent journalisees cote code.
- `Mon offre` comme `Mon reseau` doivent aussi rester des lectures front pures: aucune navigation PRO entre ces deux pages ne doit relancer de sync legacy reseau ni requalifier une offre support `Terminee` en `En attente`.
- `Mon reseau` doit afficher correctement le statut actif de l'abonnement reseau meme quand la valeur canonique remonte en anglais (`active`) et non en francise (`actif`).

## Invariants metier a conserver

### Acces
- affiliation != acces actif;
- une offre propre active de l'affilie reste prioritaire;
- l'acces reseau n'est effectif que si la delegation est active et resolue;
- une TdR sans offre support active ne doit pas ouvrir d'acces reseau effectif.

### Offre support reseau
- l'offre commerciale visible cote TdR est `Abonnement reseau`;
- sa creation doit rester une action BO explicite;
- aucune lecture de contexte, aucun flag TdR, aucune simple affiliation ne doit auto-creer cette offre.

### Remise reseau
- la remise reseau ne s'applique en prix qu'aux offres deleguees `hors abonnement reseau` portees par la TdR;
- les offres propres commandees par un affilie ne doivent jamais etre reprices par ce mecanisme;
- le volume actif servant au palier doit compter:
  - les affilies avec offre deleguee active;
  - les affilies rattaches au reseau avec offre propre active.

### BO / historique
- le BO doit distinguer lisiblement:
  - offres propres
  - offres deleguees hors abonnement
  - offres incluses a un abonnement reseau
  - affilies inactifs
- l'historique doit afficher toutes les offres deleguees terminees rattachees a la TdR.

## Etape 0 - Contrats produit et messages d'onboarding

### Intention initiale
- poser les definitions produit de base;
- rendre les etats reseau lisibles cote PRO;
- expliquer affiliation, acces, branding et contenu reseau.

### Ce qui a ete fait
- les contrats metier structurants ont ete clarifies dans les notes de cadrage et les audits:
  - offre effective;
  - branding effectif;
  - contenu reseau;
  - separation affiliation / acces.

### Choix / ecarts par rapport au plan initial
- l'effort s'est d'abord deplace sur le socle ecommerce/BO pour fiabiliser le modele avant de pousser l'onboarding PRO;
- les messages d'aide et l'habillage UX reseau cote PRO n'ont pas ete livres comme lot autonome.

### Reste a faire
- formaliser un wording produit canonique cote PRO;
- ajouter les textes d'aide et CTA reseau la ou ils restent necessaires;
- verifier la coherence des libelles entre BO, PRO et front jeu.

## Etape 1 - Resolver centralise "offre effective"

### Intention initiale
- avoir une seule verite metier pour determiner:
  - offre propre active;
  - acces via reseau;
  - absence d'acces.

### Ce qui a ete fait
- le resolver central a ete etendu cote `global`;
- les regles de priorite ont ete posees:
  - offre propre active
  - acces reseau actif et resolu
  - aucun acces
- `pending_payment` reste bloquant;
- le fallback legacy a ete conserve pendant la transition.

### Choix / ecarts par rapport au plan initial
- la bascule n'a pas supprime immediatement tout le legacy;
- un mode de compatibilite a ete conserve pour eviter une rupture brutale des flux existants;
- l'offre support `Abonnement reseau` a ete explicitement exclue du calcul d'acces jeu siege.

### Statut lot stabilisation 2026-03-12
- stabilise dans ce lot:
  - `app_ecommerce_offre_effective_get_context(...)` reste le point de resolution canonique consomme par PRO et runtime jeu;
  - les raisons d'inactivite exposees par le resolver sont realignees avec les consommateurs encore actifs (`pending_payment`, contrat inactif / absent, affilie non active, delegation indisponible);
  - aucun resolver local divergent significatif n'a ete prouve comme encore prioritaire face a ce point central.
- legacy encore actif mais borne:
  - fallback de lecture sur `ecommerce_offres_to_clients` si `ecommerce_reseau_contrats*` n'est pas disponible ou non renseigne;
  - fallback de delegation legacy dans le contexte affilie quand l'activation explicite n'est pas encore hydratee.
- conclusion de rebaseline:
  - l'etape `1` est consideree comme close fonctionnellement;
  - la fermeture pre-prod complete reste conditionnee a la purge finale des fallbacks legacy encore actifs.
- hors lot volontaire:
  - suppression complete du dernier fallback resolver tant qu'un audit de deploiement ne prouve pas que `ecommerce_reseau_contrats*` est integralement disponible et hydrate partout.

## Etape 2 - BO contrat cadre reseau

### Intention initiale
- donner un pilotage BO explicite du contrat reseau;
- tracer les activations affilie par affilie;
- sortir de la simple lecture legacy de `id_client_delegation`.

### Ce qui etait prevu
- tables techniques dediees;
- page BO reseau;
- helpers globaux lecture / ecriture / trace;
- entree depuis la fiche client TdR;
- garde-fous d'ecriture.

### Ce qui a ete fait
- creation de la couche technique:
  - `ecommerce_reseau_contrats`
  - `ecommerce_reseau_contrats_affilies`
- ajout des helpers metier de lecture / ecriture / trace;
- mise en place de la page BO `reseau_contrats`;
- activation / desactivation d'affilies via un write path dedie;
- ajout de l'entree depuis la fiche client siege;
- blocage des ecritures brutes non contextualisees sur `id_client_delegation`.

### Choix / ecarts par rapport au plan initial
- `ecommerce_offres_to_clients` est reste le support commercial et Stripe du contrat, au lieu d'un modele commercial totalement separe;
- la couche `ecommerce_reseau_contrats*` a ete gardee comme ancre technique et de tracabilite, pas comme produit visible principal.

### Statut lot stabilisation 2026-03-12
- stabilise dans ce lot:
  - le role restant de `ecommerce_reseau_contrats` est confirme: ancre technique du siege, capacites, offre cible, jauge cible, montant/periode de socle si colonnes disponibles;
  - le role restant de `ecommerce_reseau_contrats_affilies` est confirme: etat explicite par affilie, offre deleguee courante, mode de facturation, trace BO/runtime;
  - les write paths reels restent concentres sur `app_ecommerce_reseau_contrat_upsert(...)`, `app_ecommerce_reseau_contrat_support_offer_link_save(...)` et `app_ecommerce_reseau_activation_write(...)`.
- conclusion de rebaseline:
  - l'etape `2` est consideree comme close fonctionnellement;
  - `ecommerce_offres_to_clients` reste le support commercial / Stripe principal;
  - `ecommerce_reseau_contrats*` reste une surcouche technique de capacite, rattachement, mode de facturation et trace.
- ambigu / non prouve:
  - le schema canon `documentation/canon/data/schema/DDL.sql` ne documente pas encore `ecommerce_reseau_contrats*`;
  - aucune source SQL canonique complete n'a ete retrouvee dans ce lot pour reconstruire ces tables sans supposition.
- hors lot volontaire:
  - audit final colonne par colonne de `ecommerce_reseau_contrats`;
  - migration SQL de nettoyage des colonnes mortes prouvees;
  - mise a jour du script phpMyAdmin de reference et normalisation documentaire canonique du schema tant qu'une source SQL fiable complete manque.

## Etape 2A - Offre reseau dediee et support commercial unique

### Intention initiale
- garantir une offre support reseau stable et lisible par TdR;
- rendre `Abonnement reseau` visible comme objet commercial de reference.

### Ce qui etait prevu
- helper `ensure` pour garantir l'offre;
- creation / rattrapage progressif;
- adaptation PRO `Mon offre`;
- levier BO de backfill.

### Ce qui a ete fait
- mise en place des helpers `app_ecommerce_reseau_offre_dediee_*`;
- support `Abonnement reseau` consolide comme source de verite commerciale visible;
- adaptation de `Mon offre` pour la lecture reseau;
- exclusion de l'offre support des usages ou elle ne doit pas donner acces jeu;
- sync des delegations legacy vers la couche contrat reseau;
- recap dedie cote BO reseau.

### Choix / ecarts par rapport au plan initial
- le point d'entree reel s'est revele etre le BO et non un flux autonome PRO;
- une phase de backfill/sync legacy a ete necessaire pour raccrocher l'historique existant;
- l'auto-creation initialement tolerable en phase transitoire a finalement ete abandonnee.

### Mises a jour / arbitrages ulterieurs
- creation de l'offre support neutralisee partout sauf depuis l'action BO explicite d'ajout d'une offre reseau pour une TdR;
- suppression des auto-creations depuis:
  - flag TdR;
  - lectures BO/PRO;
  - chargement de contexte;
  - flux d'affiliation;
  - backfills opportunistes.

### Statut lot stabilisation 2026-03-12
- stabilise dans ce lot:
  - aucun point d'entree encore branche n'appelle `app_ecommerce_reseau_offre_dediee_ensure_for_client(...)` ou `app_ecommerce_reseau_offre_dediee_backfill_all_sieges(...)`;
  - la creation d'une offre support client reste bornee au BO `offres_clients` via ajout explicite d'une offre `Abonnement reseau`;
  - PRO ne prepare qu'un paiement Stripe sur une offre support existante, sans auto-creation.
- encore present mais non branche:
  - les helpers `ensure/backfill` existent encore dans `global` comme code transitoire non appele.
- conclusion de rebaseline:
  - l'etape `2A` est consideree comme close fonctionnellement;
  - les helpers legacy peuvent encore exister, mais restent dormants tant qu'aucun appel actif n'est prouve.
- hors lot volontaire:
  - suppression physique de ces helpers tant qu'aucun runbook de reprise historique n'est ferme.

## Etape 2B - Stabilisation BO des activations et de la lecture par couverture

### Intention initiale
- rendre le BO reseau lisible et pilotable sans ambiguite;
- preparer un pilotage affilie par affilie reellement exploitable.

### Ce qui etait prevu
- pilotage par affilie;
- synthese claire;
- distinction des types de couverture;
- historique fiable.

### Ce qui a ete fait
- stabilisation du tableau principal `Affilies du reseau`;
- synthese clarifiee avec:
  - abonnement reseau actif ou non;
  - nb affilies limite;
  - nb de places disponibles;
  - tarif negocie si abonnement actif;
  - affilies actifs;
  - detail offres propres / offres deleguees / offres incluses abonnement;
  - affilies inactifs;
  - remise reseau courante;
- ajout d'une organisation / d'un filtrage par type de couverture;
- tableau d'historique BO ajuste pour afficher toutes les offres deleguees terminees rattachees a la TdR;
- correction du libelle historique:
  - `Incluse a un abonnement reseau`
  - et non rattachement force a l'abonnement actif courant;
- reintroduction de la remise reseau dans la colonne `Tarif` pour les delegations hors abonnement.

### Choix / ecarts par rapport au plan initial
- le besoin reel s'est concentre d'abord sur la lisibilite BO, avant une eventuelle UX PRO plus riche;
- l'historique a ete preserve comme lecture metier, y compris pour d'anciennes offres cadre ou anciens rattachements, au lieu d'une lecture purement "etat courant".

### Statut lot stabilisation 2026-03-12
- stabilise dans ce lot:
  - la lecture BO `reseau_contrats` continue de partir de `app_ecommerce_reseau_contrat_couverture_get_detail(...)`;
  - la distinction `Incluse a un abonnement reseau` vs `Hors abonnement reseau` reste calculee a partir du mode de facturation / rattachement support source;
  - le pilotage BO par affilie reste exclusif via les actions dediees `activate/set_mode/desactivate`.
- conclusion de rebaseline:
  - l'etape `2B` est consideree comme close fonctionnellement;
  - un fallback BO historique eventuel reste seulement tolere comme legacy borne.
- hors lot volontaire:
  - nouvelle vue groupee BO ou extension de cette lecture a d'autres surfaces PRO/BO.

## Etape 3 - Remise reseau dynamique

### Intention initiale
- faire evoluer la remise reseau selon le volume actif du reseau;
- faire en sorte que cette remise se repercute sur la facturation reelle.

### Ce qui etait prevu
- helper de calcul de remise;
- calcul du montant reseau agrege;
- preparation d'une logique de volume.

### Ce qui a ete fait
- les paliers de remise reseau ont ete formalises;
- le calcul du volume actif a ete corrige pour compter:
  - les affilies avec offre deleguee active;
  - les affilies rattaches au reseau avec offre propre active;
- la remise continue de ne s'appliquer qu'aux offres deleguees `hors abonnement reseau`;
- le prix net des delegations actives hors abonnement est recalculable a partir du tarif catalogue de reference;
- la persistance du `prix_ht` sur ces offres et la synchronisation Stripe associee ont ete prevues pour aligner la facturation.

### Choix / ecarts par rapport au plan initial
- le plan initial ne tranchait pas completement la question des offres propres dans le compteur de volume;
- la regle retenue est:
  - les offres propres comptent dans le volume actif pour le palier;
  - elles ne sont jamais impactees en prix.

### Statut lot fermeture 2026-03-12
- stabilise dans ce lot:
  - le calcul du volume actif reste porte par `app_ecommerce_reseau_volume_actif_get_count(...)`;
  - ce volume compte bien:
    - les affilies avec offre deleguee active;
    - les affilies rattaches au reseau avec offre propre active;
  - les offres support `Abonnement reseau` sont exclues du compteur de volume;
  - le palier applique reste calcule par `app_ecommerce_remise_volume_reseau_get_pourcentage(...)`;
  - le repricing runtime ne cible que les delegations `hors abonnement reseau` via le filtre `mode_facturation = 'hors_cadre'` lorsqu'il est disponible;
  - le prix cible repart du tarif catalogue de reference, puis applique la remise reseau courante avant persistance dans `ecommerce_offres_to_clients.prix_ht`;
  - la synchro Stripe utile reste concentree sur `app_ecommerce_reseau_stripe_subscription_price_sync(...)`, appelee depuis `app_ecommerce_reseau_offres_hors_cadre_dynamic_pricing_sync(...)`.
- prouve en code:
  - une offre propre affilie compte bien dans le volume sans etre repriced;
  - une delegation `cadre` incluse a l'abonnement reseau n'est pas repriced par la remise dynamique;
  - une delegation `hors abonnement reseau` active est reprixee localement et cote Stripe si une souscription Stripe est rattachee;
  - les refresh utiles sont encore declenches sur:
    - creation / reactivation de delegation;
    - changement d'etat d'une offre;
    - reclassement de couverture / quota;
    - webhook Stripe sur souscription;
    - cron de fin de periode.
- ambigu / non prouve:
  - aucune recette temps reel Stripe n'a ete executee dans ce lot sur un compte test vivant;
  - la garantie "prochain cycle facture au nouveau montant" repose donc sur:
    - le write path local prouve;
    - l'appel Stripe avec `proration_behavior=none`;
    - la documentation Stripe, pas sur une capture de facture issue d'un test local de ce lot.
- conclusion de rebaseline:
  - l'etape `3` est consideree comme fermee sur le code livre;
  - elle reste `close avec reserve` tant qu'une recette Stripe reelle de bout en bout n'a pas ete archivee.
- hors lot volontaire:
  - reprise des etapes `1 / 2 / 2A / 2B`;
  - ouverture UX PRO;
  - nettoyage des fallbacks legacy non necessaires a la fermeture de l'etape 3.

### Recette technique et metier
- affilie avec offre deleguee active
  - preconditions:
    - une TdR avec offre support active;
    - un affilie rattache sans offre propre active;
    - une delegation active classee `hors abonnement reseau`;
  - verifications:
    - `app_ecommerce_reseau_offres_hors_cadre_pricing_get(...)` remonte la ligne dans `rows`;
    - `prix_brut_ht` repart du tarif catalogue de reference;
    - `prix_net_ht` applique le palier courant;
    - `app_ecommerce_reseau_offres_hors_cadre_dynamic_pricing_sync(...)` persiste `prix_ht`, `remise_nom`, `remise_pourcentage`;
    - si `asset_stripe_productId` est renseigne, la synchro Stripe est tentee.
- affilie avec offre propre active
  - preconditions:
    - un affilie rattache au reseau;
    - une offre propre active hors offre support;
    - aucune delegation active portee par la TdR pour cet affilie;
  - verifications:
    - `app_ecommerce_reseau_volume_actif_get_count(...)` compte cet affilie dans le volume via l'existence d'une offre propre active;
    - aucune ligne `hors_cadre` correspondante n'apparait dans `app_ecommerce_reseau_offres_hors_cadre_pricing_get(...)`;
    - aucun `UPDATE ecommerce_offres_to_clients SET prix_ht=...` n'est declenche sur son offre propre par la remise reseau.
- cas mixte
  - preconditions:
    - au moins un affilie en delegation `hors abonnement reseau`;
    - au moins un autre affilie avec offre propre active;
  - verifications:
    - le volume actif augmente avec les deux profils;
    - seul l'affilie porte par delegation `hors abonnement reseau` apparait dans les lignes reprixables.
- changement de volume sans changement de palier
  - action:
    - ajouter ou retirer un affilie actif tout en restant dans le meme seuil de `app_ecommerce_remise_volume_reseau_get_pourcentage(...)`;
  - verifications:
    - `nb_affilies_actifs_remise` varie;
    - `remise_reseau_pourcentage` reste identique;
    - aucun changement de `prix_ht` cible n'est attendu sur les delegations deja en phase avec ce palier.
- changement de volume avec changement de palier
  - action:
    - franchir un seuil `2 / 5 / 10 / 20 / 30 / 50 / 100` via activation ou fin d'une offre utile;
  - verifications:
    - le nouveau `remise_reseau_pourcentage` est visible dans `app_ecommerce_reseau_offres_hors_cadre_pricing_get(...)`;
    - `app_ecommerce_reseau_offres_hors_cadre_dynamic_pricing_sync(...)` met a jour les `prix_ht` stockes des seules delegations `hors abonnement reseau`;
    - BO `reseau_contrats` relit le nouveau tarif net et le nouveau pourcentage.
- verification de reprise du nouveau montant cote Stripe
  - preconditions:
    - une delegation `hors abonnement reseau` active avec `asset_stripe_productId` renseigne;
  - action:
    - declencher un refresh reseau utile ou appeler le webhook/cron qui y mene;
  - verifications:
    - `app_ecommerce_reseau_stripe_subscription_price_sync(...)` est appelee avec le `prix_ht_cible`;
    - aucun prorata immediat n'est demande (`proration_behavior=none`);
    - le prochain cycle utile doit reprendre le nouveau montant selon la doc Stripe;
    - si l'on veut une preuve complete de recette, il manque encore dans ce lot une facture Stripe test creee apres le changement de palier.

## Etape 4 - UX PRO reseau et lisibilite "Affilie" / "Actif via reseau"

### Intention initiale
- rendre la lecture PRO beaucoup plus claire cote siege et cote affilie.

### Etat reel
- cette etape n'a ete que partiellement couverte indirectement par les travaux sur le resolver et `Mon offre`;
- l'UX PRO complete de pilotage et de lisibilite reseau n'a pas ete livree comme lot structure.

### Choix / ecarts par rapport au plan initial
- priorite donnee au socle BO, au contrat commercial et a la fiabilite de la facturation avant d'enrichir l'UX PRO.

### Statut de rebaseline
- etape `4` explicitement hors lot a ce stade.

### Reste a faire
- reprendre les ecrans PRO listes / fiches / CTA avec les statuts metier stabilises;
- afficher explicitement:
  - affilie ou non;
  - actif via reseau ou non;
  - offre propre ou non;
  - source effective du branding.

## Etape 5 - Branding reseau

### Intention initiale
- fournir un vrai point d'entree metier pour personnaliser le design reseau;
- conserver une priorite claire entre branding session, affilie, reseau et defaut.

### Etat reel
- la regle cible de priorite branding a ete posee;
- l'etape 5 v1 est maintenant livree cote TdR:
  - page dediee `Design reseau` sur la route branding PRO existante;
  - etat actuel lisible;
  - apercu inspire de l'attente de session;
  - date de fin optionnelle `valable_jusqu_au`;
  - reinitialisation explicite du design reseau.

### Choix / ecarts par rapport au plan initial
- pas de nouveau point d'entree concurrent;
- le backend / routing branding PRO existants sont conserves comme socle;
- la refonte porte surtout sur l'experience TdR reseau, sans generaliser a tout le module branding legacy;
- l'apercu reste volontairement leger: il ne remonte pas tout le runtime games mais se cale sur les champs effectivement consommes.

### Statut de rebaseline
- etape `5` ouverte et livree en v1.

### Reste a faire
- recette manuelle de bout en bout sur l'environnement cible:
  - ouverture depuis `/account/network`;
  - creation / modification;
  - affichage `Actif` / `Actif jusqu'au` / `Expire`;
  - reinitialisation;
- appliquer la migration SQL en base;
- durcir ulterieurement l'unicite DB `(id_type_branding, id_related)` si le schema doit etre nettoye.

## Etape 6 - Contenu reseau

### Intention initiale
- permettre un partage reseau des contenus sans casser les natures sources.

### Etat reel
- le contrat produit cible reste valide;
- cette etape n'a pas ete traitee en implementation detaillee dans le lot actuel.

### Statut de rebaseline
- etape `6` explicitement hors lot a ce stade.

### Reste a faire
- definir le flag reseau cote contenu;
- definir la vue / le filtre reseau;
- garantir l'absence de doublons dans une meme liste;
- verifier l'articulation avec les contenus Cotton, Communaute et Mine.

## Restant avant future prod

### Objectif
- achever le nettoyage une fois le runtime reseau stabilise.

### Reste a faire
- purge complete des fallbacks legacy encore actifs ou encore appelables;
- audit final colonne par colonne de `ecommerce_reseau_contrats`;
- migration SQL de nettoyage des colonnes mortes prouvees;
- mise a jour du script d'import phpMyAdmin:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`;
- normalisation documentaire canonique du schema `ecommerce_reseau_contrats*` autant que possible avec sources prouvees;
- recette Stripe reelle finale pour transformer l'etape `3` en fermeture pleinement exploitable.

## References de reconstruction

- ancienne base de plan fournie manuellement: `/home/romain/Cotton/plan_migration_reseau_branding_contenu.md`
- audit modele: [audit-contrat-offre-reseau-2026-03-06.md](/home/romain/Cotton/documentation/notes/audit-contrat-offre-reseau-2026-03-06.md)
- implementation etape 2: [implementation-etape2-bo-contrat-cadre-reseau-2026-03-06.md](/home/romain/Cotton/documentation/notes/implementation-etape2-bo-contrat-cadre-reseau-2026-03-06.md)
- audit et patch etape 2A: [audit-etape2a-offre-reseau-dediee-2026-03-08.md](/home/romain/Cotton/documentation/notes/audit-etape2a-offre-reseau-dediee-2026-03-08.md)

## Resume executif

Le plan mis a jour acte la rebaseline suivante:
- etapes `1 / 2 / 2A / 2B` closes fonctionnellement;
- etape `3` close cote implementation, avec reserve de recette Stripe reelle;
- priorite immediate avant future prod:
  - hardening final des etapes `1 / 2`;
  - validation Stripe reelle finale;
- etapes `4 / 5 / 6` volontairement non ouvertes a ce stade.
