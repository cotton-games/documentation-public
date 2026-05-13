# Etat 2026-05-13 - Stripe webhooks: emails supprimes en livemode=false

Correctif fonctionnel cote `global`:
- `app_ecommerce_commande_ajouter(...)` accepte une option email interne permettant aux webhooks Stripe de supprimer les emails metier sans interrompre la creation de commande/facture;
- cette option est exclusivement pilotee par `pro/web/ec/ec_webhook_stripe_handler.php` apres lecture de `event.livemode`;
- les emails concernes cote commande sont l'alerte admin commande Brevo et le transactionnel AI Studio `INVOICE_MONTHLY`.

Invariants:
- aucune deduction via champs Cotton (`flag_test`, `mode_test`, etc.);
- aucun changement de montants, lignes, factures, paiements, etats ou synchronisations;
- chaque email ignore logge `[Stripe Webhook][Email Suppressed] livemode=false`.

# Etat 2026-05-12 - Stats preuve sociale LP reseau

Correctif fonctionnel cote `global`:
- `app_client_network_lp_stats_get($id_client_reseau)` expose les indicateurs LP reseau affichables;
- les affilies sont comptes depuis `clients.id_client_reseau`;
- les sessions sont comptees depuis `championnats_sessions` joint a `clients`, hors demos et avec configuration complete;
- les joueurs sont lus uniquement depuis l'agregat `reporting_games_players_monthly` si disponible.

Effet attendu:
- `www` peut afficher un bloc de preuve sociale sur `/lp/reseau/{slug}` uniquement lorsque les seuils commerciaux sont atteints;
- aucun recalcul runtime joueur n'est fait cote LP publique;
- en absence d'agregat joueurs, le compteur joueurs est simplement ignore.

Seuils commerciaux V1:
- etablissements affilies inscrits: indicateur affichable a partir de `3`, signal fort a partir de `20`;
- sessions de jeu programmees: indicateur affichable a partir de `5`, signal fort a partir de `50`;
- joueurs deja accueillis: indicateur affichable a partir de `100`, signal fort a partir de `1000`.

Regle d'affichage LP:
- afficher le bloc si au moins `2` indicateurs passent leur seuil affichable;
- afficher aussi le bloc si `1` seul indicateur passe son seuil de signal fort;
- limiter le rendu public a `3` indicateurs maximum, dans l'ordre affilies, sessions, joueurs;
- ne jamais afficher un compteur a `0`, un indicateur absent, ni un bloc generique vide.

# Etat 2026-05-12 - Couleurs LP reseau dediees au compte TdR

Correctif fonctionnel cote `global`:
- `app_client_lp_colors_*` ajoute deux parametres optionnels sur `clients`: `lp_reseau_couleur_principale` et `lp_reseau_couleur_secondaire`;
- les valeurs sont normalisees au format strict `#RRGGBB`; une valeur vide ou invalide est ignoree proprement;
- ces couleurs sont dediees a la LP reseau et ne modifient pas le design reseau complet;
- `app_client_signup_network_theme_get(...)` compose le theme signup/signin affilie en priorisant logo/visuel LP TdR puis branding signup reseau historique; il n'expose pas les couleurs LP au formulaire PRO.

Effet attendu:
- `www` peut prioriser les couleurs LP du compte TdR avant les couleurs du design reseau;
- `pro` peut appliquer le logo et le visuel LP sur `signup` / `signin` des qu'une affiliation reseau est resolue;
- en absence de couleurs LP valides, les fallbacks design reseau puis Cotton restent inchanges.

# Etat 2026-05-11 - Parametrage LP sur abonnement reseau

Correctif fonctionnel cote `global`:
- `app_ecommerce_reseau_support_lp_settings_*` cree, lit et sauvegarde une table dediee `ecommerce_reseau_support_lp_settings` rattachee a `ecommerce_offres_to_clients.id`;
- les champs couverts sont: activation de personnalisation, titre public, accroche, description courte, CTA actif, CTA inactif et slug public optionnel;
- `app_ecommerce_reseau_support_offer_active_latest_get(...)` expose l'abonnement reseau actif le plus recent pour une TdR (`date_debut DESC`, puis `id DESC`).

Effet attendu:
- `www` peut enrichir la LP reseau depuis l'abonnement support actif sans dupliquer l'affiliation ni l'activation d'offre incluse;
- une TdR sans abonnement actif conserve une LP d'affiliation reseau sobre, sans promesse d'acces inclus.

# Etat 2026-05-11 - Demos LP reseau portees par la TdR

Correctif fonctionnel cote `global`:
- les scripts demo publics peuvent maintenant resoudre cote serveur le compte TdR associe a une LP reseau/operation via son slug public;
- le contexte accepte est limite a `reseau` ou `operation`, et le compte resolu doit etre un client `flag_client_reseau_siege=1`;
- en cas de contexte absent, invalide ou non resolu, les demos standards restent portees par le compte demo historique `1557`;
- `app_session_demo_ajouter(...)` garde les attributs demo prives/non officiels existants et ne cree aucune offre, commande ou droit BO/pro.

Effet attendu:
- une demo lancee depuis une LP reseau/operation valide herite du compte TdR porteur, quel que soit le contenu affiche par la LP;
- le design reseau reste applique par la resolution branding existante, avec fallback design courant si aucun design reseau n'existe;
- les demos lancees hors LP reseau/operation conservent leur comportement historique.

# Repo `global`

## Update 2026-05-11 - Abonnement reseau / echeance date_fin
- `app_ecommerce_reseau_support_offers_expired_process(...)` cloture les supports reseau actifs dont `date_fin < CURDATE()` et reutilise `app_ecommerce_reseau_support_offer_transition_finalize(...)`;
- `app_ecommerce_reseau_support_offer_included_date_fin_sync(...)` propage la date de fin du support aux offres incluses actives liees par `reseau_id_offre_client_support_source`;
- la creation d'une offre deleguee incluse reprend la `date_fin` du support source si elle existe;
- les offres propres, hors cadre et deja terminees restent hors perimetre de cette synchronisation.

## Etat 2026-05-06 — Stripe ABN: le pipeline client suit la cloture effective

Correctif fonctionnel cote `global`:
- `app_ecommerce_stripe_subscription_terminal_sync(...)` continue de porter la transition terminale Stripe vers Cotton: l'offre liee a la subscription passe en `ecommerce_offres_to_clients.id_etat=4`;
- apres cette transition, les offres directes hors support reseau recalculent maintenant le pipeline du client via `app_ecommerce_client_pipeline_sync_from_effective_offer(...)`;
- la source de verite du recalcul est l'acces effectif relu par `app_ecommerce_offre_effective_get_context(...)`, donc le client ne repasse pas `CSO` s'il conserve une autre offre active;
- si l'offre effective restante est un abonnement, le pipeline reste ou redevient `ABN`; si c'est un pack, il devient `PAK`; sans acces effectif et hors `INS`, il repasse `CSO`.

Invariants:
- `cancel_at_period_end` ne declenche pas ce recalcul tant que Stripe n'envoie pas une souscription effectivement terminee;
- les offres deleguees et supports reseau restent traitees par les synchronisations reseau existantes;
- aucun secret Stripe ni donnee sensible n'est journalise.

## Etat 2026-05-05 — Branding Canvas: saves partiels merge-safe

Correctif fonctionnel cote `global`:
- l'endpoint `general/branding?action=save` relit maintenant le branding existant avant d'appeler `app_general_branding_modifier(...)`;
- les champs couleurs et police absents du POST conservent leur valeur existante au lieu d'etre remplaces par une chaine vide;
- l'absence de `branding_logo` ou `branding_visuel` n'est plus interpretee comme une suppression;
- la suppression volontaire d'un media doit passer par `logo_clear=1` ou `visuel_clear=1`;
- la reponse de save renvoie le branding effectif apres sauvegarde pour permettre une rediffusion live complete cote `games`.

Effet attendu:
- une modification de couleur dans l'organizer ne supprime plus le logo ou le visuel personnalise visible cote player/remote;
- une modification de media ne remet plus les couleurs ou la police a blanc;
- les payloads complets historiques restent compatibles.

## Etat 2026-04-29 — Quiz V1: statut runtime volontairement simplifie

Correctif fonctionnel cote `global`:
- `app_session_edit_state_get(...)` ne simule plus un etat `running` pour les sessions `Cotton Quiz V1` (`id_type_produit=1`) a partir de la seule date;
- faute de runtime fiable sur cette version legacy, une session V1 non archivee par date reste traitee comme `pending`;
- une session V1 archivee par date devient `terminated`;
- les produits runtime modernes (`3/4/5/6`) conservent leur lecture de phase existante.

Effet attendu:
- la fiche detail PRO ne signale plus `Session en cours` pour une V1 simplement parce que la date du jour est atteinte;
- le statut visible V1 reste limite a un maintien legacy simple: en attente ou terminee selon la date.

## Etat 2026-04-27 — Cotton Quiz V2: exclusions papier et visuels par lots reels

Correctifs fonctionnels cote `global`:
- la generation automatique des lots temporaires papier ne regarde plus seulement les tables historiques `quizs`, `quizs_series` et `quizs_series_to_questions`;
- elle ajoute maintenant les sessions `Cotton Quiz V2` deja programmees via `championnats_sessions.lot_ids` et les questions des lots `T...` relues dans `questions_lots_temp.question_ids`;
- la fenetre d'exclusion est symetrique autour de la session cible: sessions passees et futures dans la fenetre courante, avec exclusion de la session en cours quand son id est connu;
- si le vivier devient insuffisant, le builder tente progressivement des fenetres plus courtes (`350`, `300`, `240`, `180`, `120`, `60` jours) et n'accepte une generation que si les trois familles attendues sont completes;
- la resolution des visuels `Cotton Quiz V2` peut maintenant partir des `lot_ids` reels d'une session:
  - seuls les tokens `L...` sont candidats au visuel;
  - si plusieurs lots `L...` sont presents, le dernier lot `L...` de la sequence est la source de verite visuelle;
  - les copies identiques du visuel par defaut sont ignorees;
  - les tokens `T...` restent hors selection visuelle;
  - le fallback reste `default_cotton_quiz.jpg` si aucun lot `L...` ne porte de visuel custom.
- addendum prod: pour un visuel `Quiz V2`, l'absence de `lot_ids` ne déclenche plus de fallback sur les series legacy; le socle renvoie le visuel par defaut pour eviter d'afficher un lot historique sans rapport.

Effet attendu:
- une question deja utilisee dans un lot temporaire V2 recent ou prochain ne retombe plus par defaut dans une nouvelle session papier;
- les cartes agenda et les vues qui passent les `lot_ids` n'heritent plus d'un visuel issu d'un ancien quiz legacy sans rapport.

## Etat 2026-04-17 — Leaderboards quiz legacy: le rang est rederive des scores de session

Correctif fonctionnel cote `global`:
- le dashboard partage `Mes joueurs` n'utilise plus `championnats_resultats.position` comme source de verite pour attribuer les points saison du `Cotton Quiz` legacy;
- pour le quiz legacy uniquement, le socle recalcule maintenant le rang de chaque session a partir de:
  - `equipe_session_points` DESC;
  - puis `equipe_quiz_points` DESC;
  - puis `label` ASC;
- le bareme saison existant reste inchange (`1er 500 / 2e 300 / 3e 200 / participation 100`), mais il est reapplique sur un rang rederive des scores et non plus sur une colonne `position` legacy devenue non fiable;
- effet attendu:
  - `pro`, `play` et `www` retrouvent des classements agreges quiz coherents avec les fiches session legacy;
  - aucun changement n'est apporte ici aux jeux runtime modernes.

## Etat 2026-04-17 — Photos podium player: le socle partage trace maintenant un consentement par upload

Correctif fonctionnel cote `global`:
- le helper partage `app_session_results_podium_photo_upload(...)` continue de porter le write path podium commun utilise par `pro`, `games remote` et maintenant `games player`;
- il accepte en plus un bloc `consent` facultatif:
  - texte de consentement affiche;
  - version/contexte/source;
  - horodatage;
  - identites runtime et bridge du joueur.
- le stockage retenu est une preuve par upload dans `championnats_sessions_podium_photos_consents`, reliee au `media_image_id` cree;
- addendum 2026-04-17:
  - le socle snapshotte maintenant aussi `runtime_username` / `runtime_label` au moment de l'upload player;
  - l'objectif est de pouvoir retrouver rapidement la photo, la session et le joueur runtime visible lors d'une demande d'effacement, meme sans lien EP;
  - la meme table de consentement sert aussi aux uploads organisateur (`games_remote_organizer`);
  - la provenance de la photo visible est maintenant relue depuis cette trace pour distinguer une photo `player` d'une photo `organizer`.
- effet attendu:
  - chaque photo podium envoyee depuis le player peut etre justifiee par une preuve autonome;
  - on evite un faux positif de type "le compte a deja consenti une fois" alors que la photo de session est nouvelle;
  - si la preuve consentement ne peut pas etre ecrite, la photo n'est pas conservee.

## Etat 2026-04-17 — Libelles joueur: plus de nom de famille dans les classements partages

Correctif fonctionnel cote `global`:
- le helper partage de libelle joueur des dashboards / leaderboards ne retombe plus sur `prenom + nom`;
- la regle est maintenant:
  - `pseudo` si present;
  - sinon `prenom` seul;
  - sinon `Joueur`;
- effet attendu:
  - les podiums et classements agreges de `pro`, `play` et `www` affichent les joueurs avec le meme niveau de libelle court que les sessions;
  - les equipes ne sont pas impactees par ce changement.

## Etat 2026-04-17 — Resultats de session: ordre des ex aequo aligne sur `games`

Correctif fonctionnel cote `global`:
- pour les sessions runtime `Cotton Quiz` / `Blind Test`, le socle relit maintenant la cle joueur canonique `player_id` quand elle existe dans les tables runtime;
- cette cle est reutilisee comme cle d'ordre secondaire du classement complet quand plusieurs participants partagent le meme score, afin de coller a l'ordre stable deja applique par `games`;
- la normalisation des podiums de session preserve maintenant aussi l'ordre source entre ex aequo, au lieu de re-trier localement par libelle;
- effet attendu:
  - `pro`, `play` et `www` peuvent afficher le meme ordre d'ex aequo qu'une interface `games` pour une session donnee;
  - les vues qui reconstruisent seulement l'affichage ne doivent plus inventer un autre ordre entre lignes de meme rang.

## Etat 2026-04-16 — Sessions demo: `app_session_edit_state_get(...)` suit de nouveau le runtime reel

Correctif fonctionnel cote `global`:
- `app_session_edit_state_get(...)` ne court-circuite plus les demos avant le calcul de statut;
- une session demo reutilise maintenant le meme calcul de statut que les autres sessions selon son type de jeu et son runtime;
- effet attendu cote `pro`: la fiche detail peut afficher correctement `En attente`, `En cours` ou `Session terminee` pour une demo, puis revenir a `En attente` apres une relance qui remet vraiment le runtime a zero;
- aucun changement n'est apporte ici au bypass de relance cote `games`.

## Etat 2026-04-16 — QR code place: initialisation temp robuste sans `chmod()`

Correctif fonctionnel cote `global`:
- le generateur partage `AppQrCodePlaceGenerator` tentait encore un `chmod()` sur son sous-repertoire temporaire `/tmp/tmp_qr_codes`;
- sur certains serveurs `dev`, ce changement de permissions est interdit meme quand `/tmp` reste exploitable, ce qui faisait fuiter un warning PHP jusque dans le parcours `www -> fiche session -> Je participe`;
- l'initialisation choisit maintenant `tmp_qr_codes` si le dossier est effectivement disponible et writable, sinon retombe simplement sur `sys_get_temp_dir()` sans essayer de modifier les droits;
- effet attendu: plus de warning `chmod(): Operation not permitted`, sans changer le contrat de generation des PNG/PDF QR.

## Etat 2026-04-15 — `Mes joueurs`: sessions dashboard rendues compatibles avec `app_session_edit_state_get`

Correctif fonctionnel cote `global`:
- le dashboard `Mes joueurs` relisait des sessions via des `SELECT` partiels ne chargeant pas `flag_session_demo`;
- ces lignes etaient ensuite passees a `app_session_edit_state_get(...)`, qui lisait encore cet index sans garde et spamait la reponse PHP de notices sur `GET /extranet/players?async=1`;
- les requetes source du dashboard injectent maintenant explicitement `flag_session_demo`;
- le helper global de statut session retombe aussi proprement sur `0` si ce champ est absent d'un detail partiel;
- effet attendu: plus de notices `Undefined index: flag_session_demo` sur le chargement async de `Mes joueurs`, avec un contrat de donnees plus robuste entre le dashboard client et le socle sessions.

## Etat 2026-04-15 — `Mes joueurs`: une playlist Bingo manquante ne casse plus le chargement async

Correctif fonctionnel cote `global`:
- certaines sessions `Bingo Musical` historiques pointent encore vers un `id_produit` dont la playlist client n'est plus resoluble;
- le helper `app_jeu_get_detail()` dereferencait pourtant cette playlist et son catalogue sans garde sur le chemin `type 3/6`, ce qui pouvait provoquer un fatal pendant `GET /extranet/players?async=1`;
- le helper verifie maintenant d'abord la presence de la playlist client puis relit le catalogue / format Bingo de facon defensive;
- effet attendu: la session concernee degrade son detail jeu sans faire tomber tout `Mes joueurs`.

## Etat 2026-04-13 — Fiche session: message de classement Bingo legacy aligne sur le fallback historique

Correctif fonctionnel cote `global`:
- la fiche detail de session utilisait uniquement le flag runtime `is_terminated` pour afficher le message de classement manquant;
- pour certaines sessions Bingo legacy `2/3` considerees historiques via fallback date, cela affichait encore a tort `Cette session n'a pas été jouée jusqu'au bout`;
- le helper de message aligne maintenant la fiche session sur la meme logique fallback `2/3`;
- effet attendu: ces sessions affichent desormais un message d'absence de classement exploitable, et non plus un faux message de session interrompue.

## Etat 2026-04-13 — Fiche session Bingo: labels joueurs reconciliés avec les liaisons EP

Correctif fonctionnel cote `global`:
- la fiche detail de session `Bingo Musical` relisait jusqu'ici directement `bingo_players.username` et `bingo_phase_winners -> bingo_players.username`;
- quand le runtime ne portait pas de `username`, le podium tombait en `Joueur inconnu` et la liste pouvait masquer l'identite pourtant connue cote `games_connectees` ou `grids_clients`;
- le helper de resultats de session recolle maintenant les labels Bingo via les liaisons joueur consommees (`championnats_sessions_participations_games_connectees`) puis le fallback legacy `jeux_bingo_musical_grids_clients`;
- priorite d'affichage: `pseudo`, sinon `prenom nom`, avec reappariement par `game_player_id`, `game_player_key` puis libelle normalise.
- addendum: le switch de `app_session_results_get_context(...)` traite maintenant aussi `id_type_produit = 2` comme `Bingo Musical`, pour rester coherent avec `Mes joueurs`, `Historique` et les autres mappings Bingo du socle.
- addendum: la liste basse Bingo fusionne maintenant les joueurs runtime et les participants legacy prouves, tandis que l'absence de podium exploitable remonte une mention dediee `Les données de cette session ne permettent pas d'afficher le podium.`

## Etat 2026-04-13 — `Mes joueurs`: le Bingo legacy type `2` est reintegre, avec fallback date sur `2/3`

Correctif fonctionnel cote `global`:
- le type produit `2` correspond au Bingo legacy et etait encore exclu du moteur `Mes joueurs`;
- le moteur rattache maintenant `id_type_produit = 2` a `Bingo Musical` dans ses sources et son mapping jeu;
- la terminaison historique Bingo applique maintenant un fallback par date passee pour les types `2/3`, y compris en numerique;
- le type `6` reste volontairement exclu de ce fallback et doit etre reellement termine runtime.

## Etat 2026-04-13 — `Mes joueurs` / `Archives`: le fallback Bingo papier est borne au type `3`

Correctif fonctionnel cote `global`:
- le fallback legacy par date pour les Bingos papier etait encore trop large;
- il s'appliquait aux types `3` et `6`, ce qui pouvait laisser remonter des sessions papier recentes de type `6` simplement parce que leur date etait passee;
- le fallback papier est maintenant reserve au seul Bingo legacy `id_type_produit = 3`;
- effet attendu: un Bingo papier type `6` n'entre plus dans `Archives` ni dans les agregats `Mes joueurs` sans vraie fin runtime.

## Etat 2026-04-13 — `Mes joueurs`: les periodes de classement revoient les Quiz V1 legacy

Correctif fonctionnel cote `global`:
- la synthese `Mes joueurs` comptait correctement les vieilles sessions `Cotton Quiz V1`, mais le selecteur de periodes pouvait les ignorer;
- cause confirmee: le helper `app_client_joueurs_dashboard_period_has_leaderboard_data()` n'injectait pas la colonne `date` dans sa requete source, alors que le helper de terminaison legacy en a besoin pour reconnaitre un `id_type_produit = 1` comme session terminee;
- la requete du helper de periodes charge maintenant `date` et `flag_controle_numerique`, comme le moteur principal du dashboard;
- effet attendu: les annees / saisons contenant uniquement du `Quiz V1` legacy peuvent de nouveau apparaitre dans le selecteur de classements.

## Etat 2026-04-13 — `Mes joueurs`: rollback de l'hypothese `id_type_produit = 2` cote Quiz

Correctif fonctionnel cote `global`:
- verification faite dans le socle sessions: `id_type_produit = 2` correspond au Bingo legacy, pas a `Cotton Quiz`;
- l'extension precedente du moteur `Mes joueurs` vers `id_type_produit = 2` pour Quiz a donc ete retiree;
- le cache `Mes joueurs` est invalide pour eviter de conserver des contextes reconstruits sur cette mauvaise hypothese;
- l'investigation de la borne historique des classements doit donc se poursuivre sur une autre source de donnees, pas sur ce mapping de type produit.

## Etat 2026-04-13 — Historique EC / `Mes joueurs`: Bingo privilégie la vraie fin runtime avec fallback legacy

Correctif fonctionnel cote `global`:
- `Bingo Musical` n'est plus considere termine dans les moteurs historiques uniquement parce que sa date est passee;
- `app_client_joueurs_dashboard_session_is_reliably_terminated()` relit maintenant d'abord le statut runtime bingo via `app_session_edit_state_get()`;
- les sessions Bingo papier gardent un fallback legacy par date, ce qui couvre les vieux historiques dont `phase_courante` n'a jamais ete alimentee;
- les sessions Bingo numeriques ne retombent sur la date que si le runtime n'est plus exploitable;
- effet attendu: `Mes joueurs` et l'onglet `Archives` EC privilégient une vraie fin runtime sans faire disparaitre les vieux Bingos papier legitimes.

## Etat 2026-04-13 — Direct access EC: le token survit aux pre-ouvertures de scanners QR

Correctif fonctionnel cote `global`:
- le mecanisme `client_contact_direct_access` ne vide plus son token au premier hit;
- objectif: eviter qu'un scanner QR mobile ou une previsualisation d'URL consomme le lien avant la vraie ouverture navigateur;
- le lien temporaire reste donc exploitable pendant sa duree de validite normale.

## Etat 2026-04-13 — Upload podium mobile: lecture robuste du fichier et correction orientation JPEG

Correctif fonctionnel cote `global`:
- le write path des photos podium ne suppose plus que le bon fichier se trouve en position `0` du tableau `files_img`;
- il isole maintenant le premier vrai fichier présent, ce qui securise les formulaires mobiles et les payloads multi-inputs;
- le pipeline upload image applique en plus une normalisation EXIF sur les JPEG avant resize/crop;
- objectif: eviter a la fois les faux echecs d'upload mobile et les photos importees de bibliotheque affichees a l'envers.

## Etat 2026-04-11 — Photos podium session: resolution prioritaire par gagnant, fallback par rang

Correctif fonctionnel cote `global`:
- le helper de resultats de session ne limite plus la lecture d'une photo podium a la seule place `#1/#2/#3`;
- chaque ligne de podium recoit maintenant une cle stable de gagnant (`photo_row_key`) derivee du rang et de l'identite de la ligne quand elle existe;
- la lecture des photos tente d'abord un media dedie a cette ligne de podium, puis conserve le fallback historique par rang pour les uploads deja en place;
- le write path d'upload accepte lui aussi cette cle cible, ce qui permet a deux gagnants ex aequo au meme rang de porter des photos differentes sans migration de schema.

## Etat 2026-04-10 — Détection `dev` élargie dans `global_config`

Correctif fonctionnel cote `global`:
- `global/web/global_config.php` et `global/web/global_config.template.php` ne réservent plus le mode `dev` au seul host `global.dev.cotton-quiz.com`;
- tout host `*.dev.cotton-quiz.com` est désormais reconnu comme `dev`;
- objectif: garantir que les flows Stripe déclenchés depuis `pro.dev` puis bootstrapés via `global_config.php` continuent d'utiliser les clés et URLs `dev`, sans basculer par erreur en `prod`.

## Etat 2026-04-10 — SDK Stripe: bootstrap autonome du runtime config

Correctif fonctionnel cote `global`:
- `global/web/assets/stripe/sdk/stripe_sdk_functions.php` ne depend plus strictement d'un bootstrap amont pour disposer de `$conf`;
- si le SDK est appelé dans un contexte historique incomplet, il tente désormais de charger:
  - `global_config.php`
  - puis `global_config.local.php`
- le bootstrap ne se contente plus d'un `$conf` non vide; il vérifie maintenant la présence effective des buckets Stripe runtime avant de considérer la configuration comme disponible;
- objectif: permettre l'usage des clés Stripe déclarées hors git dans le runtime, même lorsque le point d'entrée n'a pas initialisé la config globale avant d'inclure le SDK.

## Etat 2026-04-10 — Secrets Stripe: lecture via `global_config` sans fallback hardcodé

Correctif fonctionnel cote `global`:
- les helpers Stripe ne prennent plus uniquement leurs secrets depuis le code versionné;
- ils lisent désormais en priorité les valeurs runtime de `global_config.php` via:
  - `stripe_public_api_key`
  - `stripe_private_api_key`
  - `stripe_webhook_secret`
- les anciennes valeurs hardcodées ont été retirées après validation runtime en `dev`;
- `global/web/global_config.template.php` documente maintenant explicitement ces trois blocs de configuration.

## Etat 2026-04-10 — Portail Stripe affilié TdR prod: mapping prod rétabli

Correctif fonctionnel cote `global`:
- le portail Stripe utilise maintenant en `prod`:
  - `bpc_1TKulJLP3aHcgkSEn8CdQlt1` pour `network` et `network_affiliate_cancel_end_of_period`
  - `bpc_1TKh9GLP3aHcgkSEMUKlR85t` pour `network_affiliate` et `network_affiliate_cancel_immediate`
- objectif: rétablir les ouvertures de portail Stripe des offres affiliées TdR sans dépendre d'une variable runtime absente, avec une séparation `prod` cohérente entre portail standard, portail `at_period_end` et portail `immediate`.

## Etat 2026-04-10 — Audit TdR délégué: la piste `Remises 2026` est écartée

Etat fonctionnel cote `global`:
- les TdR restent volontairement exclus du moteur `Remises 2026`;
- cette exclusion est cohérente avec le contrat métier actuel, les remises réseau TdR étant gérées séparément;
- aucune ouverture du scope `Remises 2026` n'est conservée dans le code.

## Etat 2026-04-09 — Photos podium session: URL versionnee apres remplacement

Correctif fonctionnel cote `global`:
- les photos podium dediees par session/rang gardent leur stockage existant, mais leur URL resolue porte maintenant un suffixe `?v=...`;
- la version vient de `date_maj`, sinon `date_ajout`, sinon `id` media;
- objectif: forcer le navigateur a recharger la nouvelle image quand une photo podium est remplacee sans changer le nom de fichier.

## Etat 2026-04-09 — Historique agenda: helper global de qualification metier

Correctif fonctionnel cote `global`:
- `global` expose maintenant un helper de qualification de session passee reutilisable par l'agenda EC;
- ce helper reprend le meme contrat que `Mes joueurs`:
  - session non demo et complete;
  - session reellement terminee selon le jeu;
  - conservation des sessions papier meme sans participants;
  - exclusion des sessions numeriques sans participation reelle fiable;
- les sources de participation reprises sont les memes que celles deja utilisees par `Mes joueurs`, avec priorite aux tables runtime modernes et fallbacks legacy bornees par jeu.

## Etat 2026-04-09 — Résultats de session EC: helper centralise de lecture et photos podium

Correctif fonctionnel cote `global`:
- `global` expose maintenant un helper de lecture des resultats finaux de session pour la fiche EC historique;
- ce helper centralise la consommation des sources deja persistées par les jeux:
  - `championnats_resultats` pour `Cotton Quiz` legacy;
  - `cotton_quiz_sessions` + `cotton_quiz_players`;
  - `blindtest_sessions` + `blindtest_players`;
  - `bingo_phase_winners` (+ labels `bingo_players`);
- pour `Cotton Quiz` runtime et `Blind Test`, le helper reapplique le meme contrat de rang competition que les WS games (`score desc`, tie-break stable par id, rangs `1,1,3...`);
- pour `Bingo Musical`, il n'invente pas de classement complet et expose:
  - le podium de phases reellement disponible;
  - puis la liste historisee des joueurs de session;
- le helper retourne aussi des messages metier explicites quand une session n'est pas terminee ou quand aucun joueur n'a ete retrouve.
- pour Bingo historique, la relecture des joueurs ne depend plus du seul filtre live `is_active=1`, afin d'eviter les faux negatifs sur session deja terminee.
- la compatibilite schema bingo est aussi durcie: la liste joueurs n'exige plus `updated_at` et retombe sur `created_at` puis `id` selon les colonnes reellement presentes.
- `global` expose aussi un stockage dedie de photos gagnants par session archivee et rang de podium pour `Cotton Quiz`, `Blind Test` et `Bingo Musical`.
- pour `Cotton Quiz` legacy, la lecture des photos conserve un fallback sur le stockage historique `championnats/resultats`, afin de rester compatible avec les anciens uploads vainqueur deja presents.
- le compteur `Particip.` de l'EC est maintenant aligne sur ce contrat: predictive avant session, puis lecture prioritaire des tables modernes `*_players` sur session passee, avec fallback legacy seulement pour les anciens `Bingo Musical` et `Cotton Quiz` sans runtime exploitable.
- `Cotton Quiz` garde un libelle `equipes` meme si le runtime moderne fournit la source.
- pour `Cotton Quiz` legacy sans runtime, le compteur post-session relit d'abord les lignes reelles de `championnats_resultats`, et la colonne de score de la fiche historique expose le score quiz de session au lieu des points agreges du classement saisonnier.

## Etat 2026-04-08 — Factures PDF: le logo partage vit maintenant dans `global`

Correctif fonctionnel cote `global`:
- un asset commun `global/web/assets/branding/pdf/cotton-facture-logo.jpg` sert maintenant de source unique pour le logo facture;
- les PDF BO et PRO ne dependent plus d'un fichier logo stocke dans `pro`;
- cela stabilise le rendu BO sur les environnements ou les permissions inter-vhost ne permettent pas de lire directement les assets `pro`.

## Etat 2026-04-08 — E-commerce: le TTC d'affichage part maintenant d'un montant canonique unique

Correctif fonctionnel cote `global`:
- `global` expose maintenant un resolver centralise d'affichage e-commerce base sur des montants canoniques en centimes;
- le TTC affiche n'est plus reconstruit depuis un HT deja arrondi quand une remise existe;
- si un montant facture/snapshotte existe deja, c'est lui qui doit rester la reference finale d'affichage;
- pour les previews avant paiement, le TTC est maintenant resolu depuis le tarif de reference exact et la remise, puis le HT affiche est laisse comme vue informative derivee;
- le snapshot commande copie maintenant ce meme contrat, ce qui supprime les micro-ecarts visibles entre Cotton et Stripe sur une meme commande.

## Etat 2026-04-08 — E-commerce: l'etat de remise d'une offre est maintenant borne a sa periode courante

Correctif fonctionnel cote `global`:
- `global` expose maintenant un helper qui determine si une remise snapshottee sur l'offre couvre encore la periode de facturation en cours;
- ce helper relit la duree metier de la regle, l'ancre de facturation et la periode courante de l'abonnement;
- les vues `pro` peuvent donc afficher une remise active sur l'offre sans la laisser visible apres expiration metier de cette remise.

## Etat 2026-04-08 — Checkout ABN: recap de remise explicite avant Stripe

Correctif fonctionnel cote `global`:
- `global` expose maintenant un helper de formulation du recap de remise pour le checkout ABN;
- ce recap ne depend plus du wording natif Stripe quand un `trial` est combine a un coupon;
- les cas couverts sont:
  - remise limitee standard
  - remise limitee apres essai gratuit
  - remise sans limite
  - annuel `< 12 mois` relu comme remise sur la premiere echeance annuelle.

## Etat 2026-04-08 — Remises 2026: duree parametree, moteur compose par client reel

Correctif fonctionnel cote `global`:
- la remise BO `Remises 2026` ne repose plus sur une duree fixe implicite `12 mois`;
- `global` normalise maintenant une duree d'application metier:
  - `12 mois` par defaut;
  - `1..N mois`;
  - `sans limite`;
- le moteur de resolution compose maintenant le scenario final avec:
  - la duree de la regle;
  - la frequence reelle de l'offre;
  - l'eligibilite effective au trial CHR cote client;
- arbitrage retenu:
  - mensuel + duree limitee => `schedule`
  - toute duree `sans limite` => `coupon`
  - annuel + duree limitee => chemin simple `coupon`, sans phasage intra-annuel;
- exception annuelle explicite:
  - si la duree est `< 12 mois`, l'effet metier est `remise sur la premiere facture annuelle uniquement`;
  - si la duree est `>= 12 mois`, le chemin reste simple et stable, sans schedule annuel;
- `global` prepare aussi la persistance d'audit `stripe_subscription_schedule_id` sur l'offre client pour les seuls cas schedules;
- le helper de creation de schedule part d'une subscription Stripe creee par Checkout via `from_subscription`, puis reconstruit les phases utiles pour les seuls cas mensuels limites.

## Etat 2026-04-07 — Remises BO V1 sur ABN standard: resolver unique + snapshot de ligne

Correctif fonctionnel cote `global`:
- `global/web/app/modules/ecommerce/app_ecommerce_functions.php` expose maintenant un resolver unique de remises BO pour le checkout ABN standard;
- `global` expose aussi un helper de previsualisation du meme resolver pour les cartes `Tarifs & commande`, avant meme qu'une ligne `offre_client` existe;
- le helper Stripe de resolution des `Price` catalogue revalide maintenant le `lookup_key` trouve contre le tarif Cotton attendu:
  - meme `unit_amount`,
  - meme devise,
  - meme periodicite recurrente;
- si un ancien `Price` Stripe conserve la bonne `lookup_key` mais un montant obsolete, `global` recree maintenant un `Price` conforme et transfere la `lookup_key` dessus pour que le checkout reparte de la bonne base TTC;
- le guard runtime V1 ne se contente plus de `id_offre_type = 2`:
  - il borne explicitement le lot a `id_offre = 12`,
  - il borne explicitement le lot a l'ABN periodique `id_paiement_type = 2`,
  - afin de ne pas embarquer les anciens chemins ABN one-shot/commentes encore visibles dans le code historique;
- le moteur lit les regles generiques existantes et leur rattachement offre, puis ajoute un ciblage explicite comptes organisateurs via `ecommerce_remises_to_clients`;
- le scope V1 reste strict:
  - remise en pourcentage uniquement;
  - une seule remise gagnante;
  - non cumulable;
  - coupon Stripe borne par defaut a `12 mois` pour les nouvelles souscriptions V1;
  - fenetre de date de commande;
  - reseau explicitement exclu via les gardes runtime prouves;
- le snapshot commercial est maintenant porte par l'offre client puis recopie dans la ligne de commande avec:
  - `id_remise`
  - `prix_reference_ht`
  - `prix_ht` final
  - `remise_nom`
  - `remise_pourcentage`;
- la ligne de commande devient ainsi la verite de facturation sans recalcul webhook.

## Etat 2026-04-03 — `Mes joueurs`: sessions bingo historiques reintegrees dans la synthese

Correctif fonctionnel cote `global`:
- la synthese haute `Mes joueurs` ne depend plus, pour `Bingo Musical`, d'un etat de playlist client potentiellement reinitialise ou reutilise apres coup;
- une session bingo passee est maintenant consideree comme historique/terminee pour les compteurs de synthese organisateur;
- le cache journalier de synthese est aussi versionne pour forcer un recompute apres ce changement de logique;
- effet:
  - les sessions bingo historiques reapparaissent dans `Sessions organisees`, `Participants inscrits` et `Top jeu`;
  - la correction reste bornee a la synthese organisateur et ne modifie pas le live.

## Etat 2026-04-04 — Classements agrégés: le podium ne se cumule plus avec la participation

Correctif fonctionnel cote `global`:
- le score agrégé ne cumule plus `100` points de participation avec les gains de podium ou de phase;
- un rang `1 / 2 / 3` vaut maintenant `500 / 300 / 200` points au total sur `Cotton Quiz` / `Blind Test`;
- un gain `Bingo / Double ligne / Ligne` vaut maintenant `500 / 300 / 200` points au total sur `Bingo Musical`;
- une participation simple sans podium ni gain de phase reste seule a `100` points.

## Etat 2026-04-04 — Classements historiques: fallback runtime recollés aux identités DB

Correctif fonctionnel cote `global`:
- le moteur de leaderboard essaie maintenant de rattacher les anciennes identites runtime de secours (`runtime:quiz_team:*`, `runtime:blindtest:*`, `runtime:bingo:*`) a une identite DB canonique deja connue dans le contexte du client;
- la fusion repose sur un libelle normalise, mais reste volontairement prudente:
  - seulement si une seule identite non-runtime correspond;
  - aucune fusion si le meme libelle normalise pointe vers plusieurs identites DB differentes;
- effet:
  - les anciens doublons purement historiques de casse, accents ou ponctuation entre runtime et DB sont absorbes;
  - les vrais cas ambigus restent separes plutot que fusionnes de force.

## Etat 2026-04-04 — `Mes classements`: période joueur recadrée sur la vraie saison organisateur

Correctif fonctionnel cote `global`:
- `app_joueur_leaderboards_get_context(...)` ne considere plus qu'une participation joueur dans le trimestre courant suffit, a elle seule, a imposer ce trimestre a l'affichage;
- le helper demande maintenant explicitement au moteur organisateur `app_client_joueurs_dashboard_get_context(...)` si le trimestre candidat est bien accepte tel quel;
- si le moteur organisateur retombe sur un autre trimestre faute de donnees leaderboard exploitables, le candidat est rejete et le helper tente le trimestre precedent;
- effet: la saison affichee cote `play`, les tableaux et les compteurs de sessions restent alignes sur la vraie saison organiseur effectivement servie par le moteur `Mes joueurs`.

## Etat 2026-04-04 — Dashboard classements: session scope + liste complete

Correctif fonctionnel cote `global`:
- le moteur organisateur `app_client_joueurs_dashboard_get_context(...)` remonte maintenant, pour chaque leaderboard de jeu, deux compteurs distincts:
  - le nb de sessions effectivement retenues dans le calcul du classement;
  - le nb de sessions retrouvees sur la saison filtree pour ce jeu;
- ces compteurs servent a afficher un rappel explicite du scope du classement dans `Mes joueurs` et `Mes classements`;
- le helper expose aussi des listes completes triees (`players_full` / `teams_full`) en plus des listes tronquees `top 10`, afin que `pro` et `play` puissent derouler tout le classement sans recalcul front ou variation metier;
- cote joueur, `app_joueur_leaderboards_highlight_leaderboard_rows(...)` marque maintenant aussi la ligne courante dans ces listes completes, pas seulement dans le `top 10`.

## Etat 2026-04-03 — Signup pro: helper de resolution par `email + nom client`

Correctif fonctionnel cote `global`:
- `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php` expose maintenant `client_contact_client_find_by_email_and_client_name(...)`;
- ce helper relit `clients_contacts -> clients_contacts_to_clients -> clients` pour retrouver un compte existant quand:
  - l'email du contact correspond;
  - le nom du client correspond aussi;
- la comparaison est normalisee avec `trim + lower` sur les deux champs, puis reste stricte en egalite exacte;
- le helper renvoie `id_client` et `id_client_contact` pour permettre au signup `pro` de reutiliser un compte deja existant au lieu d'en recreer un.

## Etat 2026-04-02 — Historique joueur EP: sessions reellement terminees seulement

Correctif fonctionnel cote `global`:
- `app_joueur_participations_reelles_get_liste(...)` ne remonte plus toute participation reelle datee `<= aujourd'hui` indistinctement;
- l'historique joueur applique maintenant la meme notion de fin reelle que les classements, avec une nuance legacy explicite:
  - `Cotton Quiz` legacy `id_type_produit = 1`: session retenue si `date < aujourd'hui`;
  - jeux modernes (`Cotton Quiz` runtime, `Blind Test`, `Bingo Musical`): session retenue si `date <= aujourd'hui` et `app_session_edit_state_get(...).is_terminated = 1`.
- cette garde s'applique au helper de liste lui-meme, avant deduplication des sources `games_connectees / quiz_legacy / bingo_legacy`;
- `app_joueur_participations_reelles_latest_date_get(...)` est maintenant recale sur cette meme lecture effective de l'historique, afin que la fenetre glissante `12 derniers mois` ne s'ancre plus sur une session du jour ou non terminee qui serait de toute facon exclue de l'affichage.

## Etat 2026-04-02 — Classements saisonniers agreges: sessions runtime reellement terminees uniquement

Correctif fonctionnel cote `global`:
- le moteur organisateur `app_client_joueurs_dashboard_get_context(...)` ne retient plus, pour les classements saisonniers agreges utilises dans `pro` et `play`, que les sessions dont l'etat runtime DB est explicitement `termine`;
- la regle se base sur la meme lecture centralisee que le garde d'edition session:
  - `Bingo Musical`: `phase_courante >= 4`;
  - `Blind Test`: `game_status / phase_courante >= 3`;
  - `Cotton Quiz` moderne: `game_status / phase_courante >= 3`;
- exception legacy explicite:
  - `Cotton Quiz` legacy `id_type_produit = 1` est reintegre avec une regle historique simple `date < aujourd'hui`;
  - le jour courant reste donc exclu, meme si la session legacy a deja eu lieu plus tot dans la journee.
- cette lecture s'appuie sur les tables runtime mises a jour par les glue `games`, via `app_session_edit_state_get()`;
- effet de bord volontaire:
  - une session non demarree ou encore en cours n'alimente plus les tops / stats / classements agreges du dashboard organisateur;
  - `Cotton Quiz` legacy ne repose pas sur un statut runtime DB “termine”, mais sur cette borne date stricte pour rester compatible avec son historique.
- la detection des trimestres exploitables (`period_has_leaderboard_data`) applique la meme garde, ce qui evite de proposer un trimestre dont les donnees de classement ne sont pas encore juridiquement stabilisees.

## Etat 2026-04-02 — Helper joueur `app_joueur_leaderboards_get_context(...)`

Correctif fonctionnel cote `global`:
- `global` expose maintenant un helper joueur dedie pour alimenter une page EP `Mes classements`;
- ce helper ne recalcule pas un nouveau moteur de classement:
  - il part maintenant d'une liste legere d'organisateurs lies au joueur (`app_joueur_linked_clients_rows_get(...)`), bornee aux seules sources EP/bridge et legacy stables;
  - il isole les organisateurs deja lies au joueur sans relire le detail complet de l'historique;
  - il choisit, organisateur par organisateur, le trimestre courant si le joueur y a une participation reelle, sinon le trimestre precedent;
  - il reconsomme ensuite `app_client_joueurs_dashboard_get_context(...)` pour reutiliser les classements organisateur deja stabilises dans `Mes joueurs`.
- contrat fonctionnel:
- sections triees par frequence de participation du joueur;
- uniquement les organisateurs lies au joueur;
- uniquement les jeux effectivement joues par le joueur sur le trimestre retenu pour l'organisateur;
- durcissement 2026-04-13: un leaderboard jeu n'est plus conserve si le joueur ou son equipe n'y sont pas effectivement reperes dans les lignes consolidees; un simple lien historique a l'organisateur ne suffit donc plus;
- `Cotton Quiz` reste expose comme classement equipes, `Blind Test` et `Bingo Musical` comme classements joueurs;
  - pour `Cotton Quiz`, si une equipe est reliee a une session, tous les joueurs actuellement lies a cette equipe peuvent maintenant etre consideres comme participants cote historique joueur, y compris dans la branche moderne `championnats_sessions_participations_games_connectees`.
  - rollback 2026-04-02: l'historique reel joueur ne relit plus directement les sessions runtime `cotton_quiz_players` et `bingo_players`; il revient a un socle stable base sur les sources EP/bridge et legacy deja reliees au joueur.
  - `Mes classements` est maintenant decouple de l'historique detaille joueur: la page n'utilise plus `app_joueur_participations_reelles_get_liste(...)` pour selectionner ses organisateurs, mais une vue legere des liens joueur -> organisateurs sur la periode;
  - compromis 2026-04-02: la liste legere des organisateurs lies reste fondee sur les seules tables stables EP/bridge et legacy;
  - les classements affiches dans chaque section restent en revanche ceux du moteur organisateur `Mes joueurs`, qui conserve sa consolidation complete moderne / legacy / runtime.
  - update 2026-04-02: le moteur organisateur remonte maintenant aussi les compteurs podium par ligne de classement (`wins`, `second_places`, `third_places`) a partir des memes attributions de points canoniques, ce qui permet a `Mes classements` de recalculer le recap joueur/equipe directement depuis la ligne surlignee.
  - durcissement 2026-04-02: les classements agreges organisateur excluent maintenant les bridges `championnats_sessions_participations_games_connectees` non consommes (`date_consumed IS NOT NULL` requis) et les joueurs runtime inactifs (`is_active = 1`) sur `cotton_quiz_players`, `blindtest_players` et `bingo_players`, y compris pour les podiums bingo;
  - le helper `app_joueur_participations_reelles_get_liste(...)` accepte maintenant aussi un bornage optionnel `date_start / date_end`, `app_joueur_participations_reelles_latest_date_get(...)` expose la derniere date d'activite reelle, et `app_joueur_participations_reelles_activity_window_get(...)` centralise la fenetre glissante par defaut:
    - `Historique` charge les `12 derniers mois` d'activite reelle, avec extension par paliers de `12 mois`;
    - les KPI home et `Mes classements` relisent eux aussi par defaut les `12 derniers mois` ancres sur la derniere activite reelle du joueur/equipe, pour eviter les recalculs complets sur tout l'historique.

## Etat 2026-04-01 — Branding: reset `games` avec cascade conditionnelle sur le branding compte

Correctif fonctionnel cote `global`:
- l'endpoint `global_ajax.php?t=general&m=branding&action=delete_preview` permet maintenant a `games` de savoir si un branding compte sera effectivement supprime avec le reset session courant;
- l'endpoint `global_ajax.php?t=general&m=branding&action=delete` accepte maintenant le signal `cascade_client_branding_if_matching=1` pour le flux organizer `games`;
- en reset de session (`id_type_branding = 1`), `global` peut maintenant:
  - detecter un branding compte `type 4`;
  - verifier qu'il correspond bien au design effectif de la session:
    - soit parce que la session herite directement du branding compte;
    - soit parce que le branding session present a la meme signature visible (`couleurs`, `police`, `logo`, `visuel`) que le branding compte;
  - figer d'abord les sessions futures du meme client qui heritent encore de ce branding compte, via duplication en branding session;
  - supprimer ensuite le branding compte;
  - puis supprimer le branding session courant si present.
- perimetre du gel:
  - sessions du client `date >= CURDATE()`;
  - hors demo;
  - hors session courante;
  - uniquement quand leur branding effectif courant est exactement `branding_client`.

## Note d'evolution — Branding par type de jeu

Etat actuel:
- le branding `global` est resolu par portee seulement: `session > evenement > reseau > client`;
- la table `general_branding` ne porte pas de `type de jeu`.

Implication:
- un branding compte est aujourd'hui global a tous les jeux du client;
- un support `par type de jeu` applicable a toutes les portees (`session/evenement/reseau/client`) demande une evolution de schema et de resolution, pas seulement un patch front.

Reference de conception:
- `documentation/notes/branding_par_type_de_jeu.md`

## Etat 2026-03-31 — Helper metier `app_client_joueurs_dashboard_get_context(...)`

Correctif fonctionnel cote `global`:
- `global` expose maintenant un helper unique pour preparer le dashboard PRO `Mes joueurs`;
- `global` expose aussi `app_client_has_archived_sessions($id_client)` pour permettre a `pro` de reutiliser la meme notion de session archivee avant d'exposer ou non la nav `Mes joueurs`;
- le contrat retourne `Membre depuis`, `Aujourd'hui`, une synthese globale sur toute la periode d'activite, des tops calcules sur cette meme periode, puis une periode de filtre dediee aux seuls classements;
- les sessions comptabilisees s'alignent sur la meme regle que le reporting BO: `championnats_sessions.flag_session_demo=0` et `flag_configuration_complete=1`;
- dans la synthese, le comptage des sessions reste aligne sur le reporting BO:
  - une session papier non demo et complete est comptee meme sans participation remontee;
  - une session numerique doit en revanche avoir produit au moins une participation fiable (`joueur` ou `equipe`) pour etre comptabilisee;
  - les sessions demo restent toujours exclues;
- la metrique principale du dashboard signifie `participants connectes (joueurs & equipes)` en agrégeant les deux sources fiables;
- la consolidation des participations privilegie d'abord les rattachements EP reels (`championnats_sessions_participations_games_connectees`, `jeux_bingo_musical_grids_clients`), puis complete avec les tables runtime de jeu quand elles existent;
- quand une session dispose deja de joueurs runtime sur le jeu concerne, ce runtime devient la source de verite pour le nb de participations reelles; le bridge/EP ne sert alors plus qu'au rattachement d'identite, sans ouvrir de participation supplementaire;
- pour `Cotton Quiz`, les lignes `cotton_quiz_players` sont interpretees comme des equipes et non comme des joueurs;
- les participations probables ne sont jamais utilisees;
- le helper porte aussi les messages d'etat vide quand aucune donnee exploitable n'est disponible, globalement ou sur la periode filtree;
- la periode de filtre des classements est maintenant pilotee par une annee d'activite puis un trimestre civil, avec defaut sur le trimestre en cours s'il contient au moins une session qui alimente reellement un classement, sinon sur le dernier trimestre qui contient effectivement des donnees de classement, et options bornees par `Membre depuis`;
- la liste `annees + trimestres` est maintenant construite directement a partir des periodes qui alimentent reellement les classements; une selection utilisateur valide n'est plus ecrasee par la logique de defaut;
- cette detection de periodes exploitables relit maintenant les memes sources que les vrais leaderboards:
  - `Cotton Quiz`: `equipes_to_championnats_sessions`, runtime `cotton_quiz_players`, puis fallback legacy `championnats_resultats`;
  - `Blind Test`: bridge `championnats_sessions_participations_games_connectees` et runtime `blindtest_players`;
  - `Bingo Musical`: runtime `bingo_players`;
- techniquement, la synthese globale est maintenant mise en cache en session par client/jour, tandis que les classements sont recalcules sur le seul scope de la periode filtree;
- la deduplication reste conservative:
  - une identite EP prime toujours sur un doublon runtime de la meme session;
  - les fallbacks non EP utilisent un nom/pseudo normalise borne au jeu, sans fusion heuristique entre jeux.
## Etat 2026-03-31 — Helper `Mes joueurs`: meilleure session dans la synthese

Correctif fonctionnel cote `global`:
- `app_client_joueurs_dashboard_get_context(...)` expose maintenant, pour chaque jeu de la synthese, `Meilleure session`, soit le nb max de participants connectes observes sur une meme session;
- cette valeur s'appuie sur les participations deja dedupliquees par session, en restant bornee aux memes sources fiables que le reste du dashboard;
- la regle reste bornee aux memes donnees fiables que la synthese V1 (`sessions` BO non demo/completes, joueurs connectes et equipes runtime/EP selon les sources deja retenues).

## Etat 2026-03-31 — Helper `Mes joueurs`: classements tries par score agrege

Correctif fonctionnel cote `global`:
- les classements du dashboard `Mes joueurs` restent fondes sur les memes participants fiables, mais sont maintenant tries par un score agrege plutot que par le seul nb de participations;
- regle retenue:
  - `500 / 300 / 200` points au total pour les rangs `1 / 2 / 3` de session sur `Cotton Quiz` / `Blind Test`, calcules a partir des scores runtime persistés;
  - `500 / 300 / 200` points au total pour les gains de phase `Bingo / Double ligne / Ligne` sur `Bingo Musical`, via `bingo_phase_winners`, avec rattachement prioritaire par `player_id_key` quand il existe;
  - `100` points seulement pour une participation reelle sans podium ni gain de phase;
  - quand le bridge EP historique n'existe pas encore pour une session legacy, ces bonus se recollent aussi par pseudo runtime normalise, sur la meme logique conservative que les participations;
- quand une meme session legacy remonte a la fois une participation EP et une ligne runtime au meme pseudo, le fallback conserve maintenant la premiere identite connue de la session pour eviter que le bonus soit attribue a une ligne runtime doublon plutot qu'a la ligne leaderboard deja visible;
- cette meme priorite s'applique aussi desormais a l'ingestion des participations runtime legacy elles-memes, afin d'eviter la creation d'une seconde ligne de classement au meme pseudo quand une identite de session existe deja;
- pour `Cotton Quiz` historique pre-runtime, les bonus podium peuvent aussi etre relus via `championnats_resultats.position`, sans dependre des tables runtime actuelles;
- pour `Bingo Musical`, le classement conserve maintenant les sessions runtime scorables de la periode, et n'exclut que les sessions historiques sans gagnants de phase recuperables de facon fiable; une mention inline discrète n'est affichee que dans ce cas partiel, pas pour les sessions sans joueur runtime a exclure logiquement;
- les tops de synthese restent eux calcules uniquement sur les participations, sans melanger ce nouveau score de classement;
- le nb de participations reste expose dans les lignes de classement comme information annexe.
- les compteurs `victoires / 2e / 3e places` doivent etre derives des bonus nets reellement ajoutes au score (`400 / 200 / 100`) afin de rester coherents avec le total affiche.

## Etat 2026-04-04 — Helper joueur `Top classement` pour la home EP

Correctif fonctionnel cote `global`:
- ajout de `app_joueur_leaderboards_best_rank_get($id_joueur, $cache_ttl_seconds=300)`;
- ce helper est dédié au KPI home `Top classement` et ne doit pas construire tout le contexte détaillé de la page `Classement(s)`;
- il réutilise la même logique métier de sélection de période et de détection d'identité joueur / équipe, mais:
  - ne cherche que le meilleur rang;
  - s'arrête dès qu'un `#1` est trouvé;
  - met en cache le résultat en session sur une courte durée pour éviter de recalculer la même information à chaque retour home;
- le contexte complet `app_joueur_leaderboards_get_context(...)` met lui aussi en cache sa réponse en session sur une courte durée, et le helper `Top classement` peut s'appuyer sur ce cache s'il existe déjà.

## Etat 2026-04-10 — Portail Stripe TdR: résolution robuste des souscriptions affiliées déléguées

Correctif fonctionnel côté `global`:
- le portail Stripe d'une offre affiliée déléguée ne dépend plus uniquement du `asset_stripe_productId` stocké sur l'offre;
- si cet identifiant n'est pas un `sub_...` valide ou ne permet plus de relire la souscription, le SI tente maintenant de retrouver la souscription via les métadonnées Stripe:
  - `metadata['offre_client_id_securite']`
  - puis `metadata['offre_client_id']`;
- la meilleure souscription retrouvée est choisie par priorité d'état (`active`, `trialing`, etc.) puis par récence;
- le `subscription_id` retrouvé est réécrit dans `ecommerce_offres_to_clients.asset_stripe_productId` pour stabiliser les appels suivants;
- les flows portail deep-linkés (`subscription_cancel`, `subscription_update`) réessaient maintenant avec cette souscription résolue avant de conclure à `subscription_snapshot_unavailable`.
- le fallback est volontairement limité aux offres déléguées affiliées; les offres standard en propre conservent leur comportement `main`.
- en complément, les portails Stripe standards revalident maintenant le `customer` stocké avant création de session; un `asset_stripe_customerId` périmé n'empêche plus silencieusement l'affichage du CTA `Gérer mon abonnement`.

## Etat 2026-04-13 — Compatibilite liste sessions / helper archive

Correctif fonctionnel cote `global`:
- `app_sessions_get_liste(...)` expose maintenant aussi la cle canonique `id` en plus de `id_championnat_session`;
- cela permet de reutiliser directement les helpers archive/metier comme `app_client_joueurs_dashboard_session_is_history_useful(...)` sur cette liste, sans remapping local;
- effet visible: les consumers `www` qui filtrent les sessions passees avec ce helper ne vident plus la liste faute d'identifiant session compatible.

## Etat 2026-04-04 — Historique joueur: sessions terminées réalignées sur les classements

Correctif fonctionnel cote `global`:
- l'historique réel joueur n'utilise plus une simple règle `session passée par date`;
- `app_joueur_historique_session_is_eligible(...)` s'aligne maintenant sur la logique des classements via `app_client_joueurs_dashboard_session_is_reliably_terminated(...)`;
- conséquence:
  - une session doit être `non demo`;
  - `flag_configuration_complete = 1`;
  - et réellement terminée selon le même moteur que les leaderboards, pas seulement passée dans le calendrier.

## Etat 2026-04-15 — Helpers podium `play`

Correctif fonctionnel cote `global`:
- `app_session_results_photo_src_stabilize_for_play(...)` fournit désormais une URL photo podium stable pour les écrans `play`:
  - priorité au domaine public `www/upload` du serveur courant;
  - fallback final sur `www prod`;
  - si une URL `www prod` arrive déjà en entrée, le helper la remappe malgré tout vers `www` du serveur courant dès qu'il peut reconstruire le chemin relatif;
- `app_joueur_leaderboards_highlight_leaderboard_rows(...)` marque maintenant aussi `players_podium` et `teams_podium` avec `is_current`, en plus des lignes de classement classiques.

## Etat 2026-04-15 — Archive dashboard: mode `historique seul`

Correctif fonctionnel cote `global`:
- `app_client_joueurs_dashboard_archive_sessions_get(...)` accepte maintenant un indicateur explicite pour ne charger que les sessions passees utiles;
- le helper accepte aussi un `offset`, pour que les consumers puissent paginer l'historique sans recharger un second chemin metier;
- quand ce mode est actif, le helper n'appelle plus `app_sessions_get_liste(...)` sur les sessions a venir avant de filtrer l'historique;
- les consumers FO `place` s'en servent pour:
  - l'onglet `Sessions passees`;
  - la colonne `sessions recentes` des classements agreges.

## Etat 2026-04-16 — Descriptions lieu: normalisation commune

Le module `clients` expose maintenant des helpers communs de normalisation pour les descriptions lieu:
- version courte sur une seule ligne;
- version longue avec retours à la ligne conservés;
- nettoyage des anciens `<br>` et balises héritées avant affichage.

Le back-office `pro` stocke ainsi désormais un texte simple normalisé, puis `pro` et `www` réutilisent le même rendu.

## Etat 2026-04-16 — Dashboard joueurs: fallback classements sans saison exploitable

Correctif fonctionnel cote `global`:
- la finalisation du contexte `app_client_joueurs_dashboard_*` est maintenant centralisée;
- quand le contexte filtré ne remonte aucun classement exploitable mais que la synthèse historique existe via cache, le message fallback `classements` est désormais correctement réappliqué;
- cela couvre aussi le cas où la saison par défaut n'a aucune session filtrée, au lieu de laisser silencieusement la vue bloquée sur la saison courante.

## Etat 2026-04-16 — Cotton Quiz: visuel session dérivé des séries illustrées

Correctif fonctionnel cote `global`:
- les détails jeu `Cotton Quiz` ne retombent plus systématiquement sur `default_cotton_quiz.jpg`;
- si le quiz contient au moins une série avec un vrai visuel custom, le moteur utilise désormais l'image de la dernière série illustrée;
- une simple copie inchangée du fichier `default_cotton_quiz.jpg` sur un lot n'est pas considérée comme un visuel custom;
- sinon le fallback historique `default_cotton_quiz.jpg` reste utilisé.

## Etat 2026-04-16 — Branding Blind Test: instrumentation du flux `general/branding`

Instrumentation diagnostique cote `global`:
- ajout de traces `error_log` dans `app_branding_ajax.php` pour les actions `get`, `save` et `delete_preview`;
- les traces exposent la portee demandee (`session` ou `client`), l'id branding resolu, puis le branding effectif apres sauvegarde;
- objectif: confirmer en conditions reelles si une session `Blind Test` reste resolue en `branding_session` meme apres une sauvegarde `client` via la coche `Utiliser ce design pour mes prochaines sessions`.

Correctif de robustesse associe:
- `app_branding_ajax.php` ne passe plus par `app_session_get_detail(...)` pour resoudre le contexte minimal d'une session;
- le module lit maintenant directement `championnats_sessions` pour recuperer `id_client` et `id_operation_evenement`, ce qui evite le fatal `app_blind_test_get_detail()` observe sur les flux branding `Blind Test` dans `global`.

## Etat 2026-04-16 — Branding visuel: ratio final impose par `global`

Le flux `games` est revenu a un envoi prioritaire du fichier source brut pour `branding_visuel`. L'apercu local de la modale reste recadre pour l'utilisateur, mais il n'est plus utilise comme derive HD de sauvegarde.

Le cadrage final du visuel branding est desormais porte par `app_general_branding_visuel_uploader(...)`: le backend ne rabaisse plus la cible `visuel` a la taille source avant appel au helper `upload(...)`.

En plus, un post-traitement `app_general_branding_cover_fit(...)` recadre explicitement l'image par le centre et force le media actif exactement aux dimensions demandees. La cible `1600x640` definie par `app_branding_ajax.php` est donc bien respectee cote serveur, avec le meme ratio que `600x240`.

## Etat 2026-04-16 — Duplication branding session: pas d'ecriture si la copie medias echoue

Le gel des sessions programmees avant suppression d'un `branding_client` repose sur `app_general_branding_duplicate_to_target(...)`.

La duplication ne copie plus les assets directement dans le dossier session cible. Elle prepare d'abord les medias dans un dossier de staging, verifie la presence des fichiers actifs (`logo.*`, `visuel.*` quand ils existent cote source), puis remplace le dossier cible par swap atomique.

Si la copie des medias echoue, la fonction retourne `0` avant toute creation ou mise a jour de ligne `general_branding` cote session. On evite ainsi le cas ou un `branding_session` prioritaire existe sans ses fichiers et bloque tous les fallbacks.

## Etat 2026-04-17 — Sessions: helper partage agenda / archive

Le module `global` expose maintenant deux helpers de bascule reutilisables par les listes:
- `app_session_list_item_is_archive(...)`
- `app_sessions_filter_by_archive_state(...)`

Ils appliquent la meme regle de classement qu'en fiche detail:
- archive si la date est passee;
- archive aussi si la session est deja `terminated` cote moteur, meme le jour J.

Objectif: eviter les divergences entre details, agendas et historiques quand une session numerique se termine avant changement de date.

## Etat 2026-04-17 — Leaderboards agreges: labels uniformises en uppercase

Les leaderboards agreges portes par `app_client_joueurs_dashboard_*` normalisent maintenant aussi leurs libelles d'affichage:
- `pseudo` si present, sinon `prenom`, deja ramene a un usage `prenom seul`;
- passage en uppercase pour les joueurs;
- passage en uppercase egalement pour toutes les lignes/podiums de leaderboard au moment de la construction finale.

Effet attendu: sur `pro`, `play` et `www`, les podiums et classements agreges affichent des labels visuellement harmonises, y compris pour les pseudos qui restaient jusque-la dans leur casse source.

## Etat 2026-04-17 — Resultats de session: labels uniformises en uppercase

Les fiches resultat de session (`pro` / `play` / `www`) utilisent maintenant aussi une normalisation uppercase partagee dans `app_session_results_*`.

Le formatage est applique:
- aux lignes de classement competitif (`quiz`, `blindtest`);
- aux podiums derives;
- au cas `Bingo Musical`, y compris la liste joueurs et le podium de phases.

Effet attendu: plus de melange `Poulette` / `REMO` / `ROMAIN` sur une meme fiche resultat; les labels session suivent maintenant la meme logique visuelle que les leaderboards agreges.

## Etat 2026-04-17 — FO place: plus de cache journalier stale sur les leaderboards

Le contexte `fo_place` des leaderboards publics n'est plus relu depuis un cache de session journalier cote `global`.

Le calcul est maintenant refait au rechargement pour la partie leaderboard, tout en conservant la reutilisation du `summary_cache` pour les blocs de synthese. Objectif: eviter qu'une session du jour nouvellement terminee reste invisible sur `www/place` parce que le navigateur avait deja charge la page plus tot dans la journee.

Effet attendu: si un `Bingo Musical` ou un `Blind Test` vient juste de se terminer et alimente un classement agrege, l'onglet `Classements` de la fiche `place` doit le montrer des le reload.

## Etat 2026-04-17 — Play: ordre des jeux aligne sur `pro` / `www`

Le builder `app_joueur_leaderboards_get_context(...)` force maintenant l'ordre de rendu `blindtest`, `bingo`, `quiz` avant d'ajouter d'eventuels jeux supplementaires.

Objectif: eviter les inversions de sections visibles sur `play`, par exemple un bloc `Bingo Musical` rendu avant `Blind Test` simplement a cause de l'ordre d'apparition des participations dans l'historique joueur.

## Etat 2026-04-17 — Sessions `quiz`: metadonnees de series accessibles aussi en liste

Les sorties de `app_sessions_get_liste(...)` embarquent maintenant `lot_ids` ainsi que trois champs derives:
- `quiz_series_count`
- `quiz_series_label`
- `quiz_series_names`

Pour les types `Cotton Quiz` `1` et `5`, ces metadonnees sont calculees via `app_cotton_quiz_get_session_series_meta(...)`, donc a partir des `lot_ids` quand ils existent, puis avec fallback `id_produit` si necessaire.

Objectif: permettre aux cartes liste et aux vues publiques compactes d'afficher un libelle court `1 serie` / `x series` sans devoir reconstituer la session complete.

## Etat 2026-04-17 — Sessions `quiz`: helper partage de libelle compact

Le module `global` expose maintenant `app_session_quiz_compact_label_get(...)`.

Regle:
- priorite au `quiz_series_label` calcule sur la session;
- fallback au `quiz_series_label` du helper jeu si disponible;
- fallback final a `theme` pour les anciens formats de quiz;
- retour vide si le fallback duplique simplement `nom_court`.

Objectif: donner une seule source de verite aux agendas `pro`, `play` et `www` pour les labels `1 serie` / `x series` sans casser les formats historiques.
