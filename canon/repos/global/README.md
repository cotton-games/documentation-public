# Repo `global`

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

## Etat 2026-04-04 — Historique joueur: sessions terminées réalignées sur les classements

Correctif fonctionnel cote `global`:
- l'historique réel joueur n'utilise plus une simple règle `session passée par date`;
- `app_joueur_historique_session_is_eligible(...)` s'aligne maintenant sur la logique des classements via `app_client_joueurs_dashboard_session_is_reliably_terminated(...)`;
- conséquence:
  - une session doit être `non demo`;
  - `flag_configuration_complete = 1`;
  - et réellement terminée selon le même moteur que les leaderboards, pas seulement passée dans le calendrier.
