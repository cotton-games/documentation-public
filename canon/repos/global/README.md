# Repo `global`

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
  - `100` points par participation reelle;
  - `500 / 300 / 200` points pour les rangs `1 / 2 / 3` de session sur `Cotton Quiz` / `Blind Test`, calcules a partir des scores runtime persistés;
  - `500 / 300 / 200` points pour les gains de phase `Bingo / Double ligne / Ligne` sur `Bingo Musical`, via `bingo_phase_winners`, avec rattachement prioritaire par `player_id_key` quand il existe;
  - quand le bridge EP historique n'existe pas encore pour une session legacy, ces bonus se recollent aussi par pseudo runtime normalise, sur la meme logique conservative que les participations;
- quand une meme session legacy remonte a la fois une participation EP et une ligne runtime au meme pseudo, le fallback conserve maintenant la premiere identite connue de la session pour eviter que le bonus soit attribue a une ligne runtime doublon plutot qu'a la ligne leaderboard deja visible;
- cette meme priorite s'applique aussi desormais a l'ingestion des participations runtime legacy elles-memes, afin d'eviter la creation d'une seconde ligne de classement au meme pseudo quand une identite de session existe deja;
- pour `Cotton Quiz` historique pre-runtime, les bonus podium peuvent aussi etre relus via `championnats_resultats.position`, sans dependre des tables runtime actuelles;
- pour `Bingo Musical`, le classement conserve maintenant les sessions runtime scorables de la periode, et n'exclut que les sessions historiques sans gagnants de phase recuperables de facon fiable; une mention inline discrète n'est affichee que dans ce cas partiel, pas pour les sessions sans joueur runtime a exclure logiquement;
- les tops de synthese restent eux calcules uniquement sur les participations, sans melanger ce nouveau score de classement;
- le nb de participations reste expose dans les lignes de classement comme information annexe.
