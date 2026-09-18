## Update 2026-07-31 — EP auth: intention probable Hub

Le parcours Hub Play avant J réutilise maintenant le flux EP historique de connexion/création de compte, sans nouveau mécanisme d'authentification. Les liens compte joueur depuis Hub Play transportent `hub_account_join=1`, `id_securite_games_hub` et l'intention explicite `hub_account_action=probable`.

`ep_signin.php` et `ep_signup.php` conservent cette intention dans les liens croisés et les formulaires POST. Les scripts historiques `ep_authentification_script.php` et `ep_joueur_script.php` la laissent ensuite transiter vers `app_joueur_session_inscription_get_link(...)`, comme pour les retours session existants.

Global reste l'autorité de décision: avant J, l'intention probable revient sur la page EP Hub `/extranet/games/hub/{hub_token}` sans créer `games_hubs_players`; cette page permet ensuite de valider ou retirer la participation probable Hub. Pendant la fenêtre ouverte, l'intention de rejoindre le Hub crée/réactive `games_hubs_players` puis redirige vers Hub Play. Les sessions autonomes continuent d'utiliser le parcours historique de participation probable de partie.

Fichiers de référence:
- `play/web/ep/ep_signin.php`;
- `play/web/ep/ep_signup.php`;
- `play/web/ep/modules/compte/authentification/ep_authentification_script.php`;
- `play/web/ep/modules/compte/joueur/ep_joueur_script.php`;
- `play/web/ep/modules/jeux/hubs/ep_hubs_detail.php`;
- `play/web/.htaccess`;
- `play/web/tests/ep_hub_detail_contract_test.php`;
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`.

## Update 2026-07-28 — EP classements: agrégat saisonnier Global

`/extranet/dashboard/leaderboards` conserve son hydratation AJAX et ses sections par organisateur, mais chaque section affiche désormais le classement saisonnier agrégé Global (`aggregate_ranking`) plutôt que les tableaux séparés par jeu.

Le joueur voit `X victoire(s) · Y podium(s) · Z partie(s)` sur chaque ligne. La ligne courante reste surlignée, le Top 10 et le classement complet restent disponibles. Les identités suivent le contrat Global: fusion seulement sur joueur Play/Global fiable, jamais sur pseudo. Les fiches de résultats de session et les classements live restent hors scope et continuent d'afficher les scores propres au jeu.

Addendum 2026-07-29: le rendu agrégé conserve le podium Play au-dessus du tableau en projetant les rangs 1 à 3 du `aggregate_ranking` dans le renderer podium EP existant. Le podium ne recalcule pas les scores, rangs ou compteurs; il réutilise strictement les lignes agrégées Global.

Fichiers de référence:
- `play/web/ep/modules/communication/home/ep_home_leaderboards_shared.php`;
- `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`;
- `global/web/app/modules/entites/clients/app_clients_functions.php`.

# Repo `play` — Carte IA d’intervention (canon)

## Update 2026-07-23 — EP fallback visuel Cotton Hub
- Les pages EP sessionnelles `signin`, `signup` et `signup_private` utilisent le visuel Cotton Hub canonique Global comme fallback lorsqu'aucun branding explicite n'est résolu.
- Les anciens visuels Canvas par type de jeu restent seulement un repli technique si l'asset Global est indisponible.
- Fichiers de référence: `play/web/ep/ep_signin.php`, `play/web/ep/ep_signup.php`, `play/web/ep/ep_signup_private.php`.

## Update 2026-07-06 — EP classements: participants mixtes Blind Test
- Sur `/extranet/dashboard/leaderboards`, Blind Test consomme le classement mixte `participants` quand il est fourni par le moteur global.
- Le tableau et le podium saison restent uniques: joueurs solos + equipes runtime dans le meme Top 10.
- Le titre utilise `participants`, pas `equipes`, pour eviter de presenter les equipes runtime Blind Test comme une categorie de classement separee.
- Les lignes equipe affichent le badge compact `ÉQUIPE`.
- Depuis le 2026-07-07, une ligne portant des metadonnees equipe mais moins de 2 membres runtime est affichée comme joueur solo.

## Update 2026-07-06 — EP fiche session: equipes runtime Blind Test
- La fiche resultats `/extranet/games/session/inscription/manage/...` affiche les lignes equipe Blind Test avec nom brut et badge compact `ÉQUIPE`.
- La source reste le contexte global `app_session_results_get_context(...)`; `play` ne reconstruit pas d'equipe localement.
- Les classements saison `Mes classements` restent pilotes par le moteur organisateur partage.

## Update 2026-07-03 — EP classements AJAX: scope organisateur limite
- retour recette:
  - le shell classements reste rapide, mais l'AJAX peut monter a plusieurs secondes quand `play` appelle plusieurs contextes organisateurs lourds;
  - les sections `play` ne necessitent souvent qu'un sous-ensemble des jeux, alors que le moteur retournait les trois leaderboards.
- optimisation livree:
  - le contexte joueur transmet maintenant au moteur global les jeux réellement utiles par organisateur/periode;
  - l'appel organisateur est force en scope periode filtree pour `play`, afin d'eviter le calcul summary complet organisateur quand il n'est pas utile au premier affichage joueur;
  - les mesures indiquent les jeux demandes et retournes.
- invariants:
  - les classements affiches restent ceux du moteur organisateur partage;
  - pas de changement de periode, ex aequo, podiums, Top 10, classement complet, rang joueur/equipe ou visibilite jeu.

## Update 2026-07-03 — EP performance home stats
- retour recette:
  - les cartes agenda sont revenues a un cout acceptable;
  - le principal cout home etait le bloc synchrone `home - stats historique`;
  - le libelle classements `cache session hit` incluait encore le calcul amont de fenetre d'activite.
- optimisation livree:
  - les KPI home `Sessions jouees`, `Top etablissement` et `Top jeu` reposent maintenant sur une synthese globale legere de l'historique reel;
  - cette synthese conserve les memes sources, le dedoublonnage par session et les filtres d'eligibilite historique, mais evite le chargement detaille de l'historique complet;
  - les classements AJAX exposent un jalon separe `leaderboards context - fenetre activite` pour diagnostiquer le vrai cout du cache session.
- invariants:
  - pas de modification des regles d'historique, de classement, de participation probable ou de runtime;
  - pas de refonte UX ni de rendu partiel nouveau.

## Update 2026-07-03 — EP performance second passage agenda / home / classements AJAX
- point produit:
  - `/extranet/dashboard/leaderboards` ne doit pas etre considere rapide uniquement parce que le shell se rend vite;
  - le temps utile joueur depend de l'AJAX `ep_home_leaderboards_ajax.php`, dont le bloc contexte est maintenant mesure plus finement.
- convention de mesure completee:
  - `perf_play=1` et `perf_play_leaderboards=1` affichent aussi les jalons emis depuis les helpers globaux de contexte classements;
  - les cartes agenda/home remontent des accumulateurs par sous-bloc pour separer cout SQL/cache et rendu HTML;
  - la home expose les requetes par famille de jeu et les enrichissements de prochaines sessions.
- optimisation sure ajoutee:
  - l'agenda precharge en une passe les compteurs de participations probables, les flags d'inscription du joueur/equipe et les participations quiz associees;
  - les cartes reutilisent ces donnees sans recalcul par session quand elles sont disponibles.
- invariants:
  - aucun changement de regle classement: periodes, ex aequo, podiums, Top 10 / classement complet, visibilite jeux et alignement organisateur restent pilotes par le moteur partage;
  - aucun changement runtime ni participation probable.

## Update 2026-07-03 — EP performance agenda / classements
- ecrans concernes:
  - `/extranet/games`;
  - `/extranet/dashboard/leaderboards`;
  - verification legere `/extranet/dashboard`.
- convention de perf temporaire:
  - `perf_play=1` active les mesures EP generales;
  - `perf_play_agenda=1` cible l'agenda joueur;
  - `perf_play_leaderboards=1` cible les classements joueur;
  - les mesures sont invisibles sans flag et affichees sous forme de tableau discret dans le shell, avec detail AJAX sur les classements.
- optimisation livree:
  - les cartes agenda/home reutilisent maintenant des caches request-scope pour les details organisateur, photos, details jeu, compteurs de participations probables et equipes joueur;
  - le filtre pays agenda reutilise le cache organisateur deja constitue pendant la construction des filtres;
  - le shell classements conserve l'hydratation AJAX existante et expose le temps du calcul `app_joueur_leaderboards_get_context(...)` sans recalcul synchrone dans `ep.php`;
  - le KPI home `Top classement` reste charge en differe et peut aussi retourner les mesures quand le flag est present.
- invariants conserves:
  - aucun changement sur les write paths de participation probable;
  - aucun CTA `play` ne cree d'inscription runtime ou ne promet de reservation;
  - ordre des ex aequo, moteur organisateur `global`, periodes, podiums agreges et toggles `Top 10 / Classement complet` inchanges;
  - pas de pagination agenda forcee dans cette passe, en attente de mesures prod avec flag.

## Update 2026-06-22 — EP sessions: microcopy participation compte / QR
- ecrans concernes:
  - `/signup/public/{id_securite_session}`;
  - `/signin/public/{id_securite_session}`;
  - `/extranet/games/session/inscription/manage/...`.
- correction produit:
  - les pages signup/signin ouvertes depuis une session publique expliquent maintenant que le compte sert a prevenir l'organisateur et/ou retrouver la session le jour J;
  - elles rappellent aussi que le joueur pourra rejoindre le jeu avec le QR code affiche sur place;
  - la fiche session EP future aligne son texte sur la venue annoncee, l'acces le jour J et le QR code.
- effet:
  - le parcours distingue mieux participation annoncee et acces runtime;
  - les flux direct `session_join`, les redirections vers les jeux et les ecritures `participations_probables` ne changent pas.

## Update 2026-04-17 — EP sessions / `Classements`: ex aequo ordonnes comme dans `games`
- ecrans concernes:
  - `/extranet/games/session/inscription/manage/...`
  - `/extranet/dashboard/leaderboards`
- correction produit:
  - les podiums `play` ne re-trient plus les ex aequo par libelle;
  - ils preservent maintenant l'ordre source fourni par le socle partage;
  - pour les sessions runtime `quiz` / `blindtest`, cet ordre source est aligne sur l'ordre stable de `games` entre joueurs a score egal.
- effet:
  - le podium et le classement complet d'une meme session ne doivent plus inverser deux lignes a rang egal;
  - le joueur retrouve sur `play` le meme ordre d'ex aequo que sur l'interface de jeu.

## Update 2026-04-16 — EP `Classements`: shell immediat puis hydratation AJAX
- ecran concerne:
  - `/extranet/dashboard/leaderboards`
- correction produit:
  - la page `Classements` ne calcule plus son contexte complet dans le bootstrap global `ep.php`;
  - elle rend maintenant son shell immediatement avec un petit message de chargement, puis hydrate le contenu via un endpoint AJAX dedie;
  - le contenu metier affiche reste identique, y compris badges jeu, podiums et toggles `Top 10 / Classement complet`.
- effet:
  - le shell EP et le menu lateral s'affichent beaucoup plus vite, meme si le calcul leaderboard complet reste couteux a froid;
  - le cout principal est deplace hors bootstrap, ce qui aligne `play` sur les autres ecrans deja passes en hydratation differée.

## Update 2026-04-14 — EP sessions: contexte `Historique` conservé et compteurs participants visibles
- ecrans concernes:
  - `/extranet/dashboard/history`
  - `/extranet/games`
  - `/extranet/games/session/inscription/manage/...`
- correction produit:
  - une session archivee ouverte depuis `Historique` conserve maintenant ce contexte dans le shell EP:
    - menu lateral `Historique` reste surligne;
    - lien header devient `← Retour à l'historique`;
    - retour preserve aussi `history_months` quand la fenetre historique a ete etendue.
  - les cartes de l'historique affichent maintenant en premier le nombre de participants reels, en reprenant le meme total que la fiche detail resultats (`players_count` si disponible, sinon fallback session) avec l'icone `people-fill` du rendu `pro`.
  - les cartes agenda / home EP affichent maintenant sous la thematique du jeu le nombre de participations probables, avec la meme lecture que `pro` (`app_session_participations_probables_get_count(...)`) et l'icone `bell-fill`.
  - la fiche detail d'une session a venir rappelle aussi sous la thematique: `Participants annoncés : X`.
  - ajustement UI 2026-04-14:
    - les libelles passent maintenant au singulier si le compteur vaut `1` (`Participation`, `Participant annoncé`);
    - les cartes a venir reutilisent maintenant exactement le meme chip visuel que l'historique pour afficher le compteur de participations probables, avec l'icone `bell-fill`, place sous `ep-session-card-game-meta`;
    - le chip participants de l'historique est recentre verticalement pour aligner proprement icone et compteur.
- effet:
  - la navigation archivee n'a plus de rebascule visuelle parasite vers `Agenda`;
  - les cartes EP exposent mieux la traction reelle d'une session passee ou a venir, sans changer les write paths de participation probable.

## Update 2026-04-04 — `Mes classements`: saison affichée réellement acceptée par le moteur organisateur
- ecran concerne:
  - `/extranet/dashboard/leaderboards`
- correction produit:
  - `play` ne se contente plus de choisir `trimestre courant sinon precedent` d'apres l'historique joueur;
  - la saison n'est maintenant retenue que si le moteur organisateur `Mes joueurs` confirme exactement ce meme `annee + trimestre` comme periode leaderboard exploitable;
  - sinon `play` tente le trimestre precedent, puis masque la section si aucune des deux periodes n'est reellement disponible.
- effet:
  - la saison affichee, les tableaux et le nb de sessions utilisees restent alignes sur la vraie periode organisateur;
  - on evite ainsi un ecran `play` etiquete `avril-juin` alors que les donnees affichees et les compteurs provenaient encore de `janvier-mars`.

## Update 2026-04-04 — `Mes classements`: perimetre de sessions et classement complet
- ecran concerne:
  - `/extranet/dashboard/leaderboards`
- correction produit:
  - chaque tableau rappelle maintenant explicitement le nb de sessions retenues pour calculer le classement, via la formule `Classement calculé sur X session(s) jouée(s) depuis le début de la saison`;
  - si un tableau depasse `10` lignes, le joueur peut maintenant derouler toute la liste puis la replier via un simple lien souligne, sans changer d'organisateur ni de saison;
  - la ligne courante du joueur ou de son equipe reste surlignee aussi dans cette vue complete.
- effet:
  - le `top 10` reste le rendu par defaut;
  - le titre bascule vers `Classement complet sur la saison selectionnee` quand la liste entiere est ouverte;
  - `play` conserve une lecture strictement alignee sur le moteur organisateur partage avec `Mes joueurs`.

## Update 2026-04-02 — `Historique`: sessions reellement terminees seulement
- ecran concerne:
  - `/extranet/dashboard/history`
- correction metier:
  - la page `Historique` n'affiche plus simplement des participations reelles datees, mais seulement les sessions qui restent eligibles une fois la notion de fin reelle appliquee cote `global`;
  - regle retenue:
    - `Cotton Quiz` legacy: `date < aujourd'hui`;
    - jeux modernes: `date <= aujourd'hui` et `runtime_status = terminated` via `app_session_edit_state_get(...)`.
- effet:
  - une session moderne du jour peut apparaitre si elle est reellement terminee;
  - une session moderne encore en cours ou simplement ouverte ne remonte plus;
  - le legacy reste borne a une logique de date stricte, sans statut runtime dedie.

## Update 2026-04-02 — `Mes classements`: rendu emoji fiable dans le recap
- ecran concerne:
  - `/extranet/dashboard/leaderboards`
- regression corrigee:
  - le recap organisateur sous `Saison` prevoyait deja `🏆 / 🥈 / 🥉`, mais ces emojis pouvaient ne pas s'afficher dans l'UI EP;
  - la cause ne venait pas de `htmlspecialchars(...)` ni de l'encodage UTF-8, mais du rendu dans la police UI principale `Poppins`, peu fiable pour les glyphes emoji.
- effet:
  - le recap `Participations / podiums` se rend maintenant avec un span emoji dedie et une stack de polices de fallback (`Apple Color Emoji`, `Segoe UI Emoji`, `Noto Color Emoji`, etc.);
  - les pictos restent separes du texte, ce qui stabilise leur affichage sans relacher l'echappement HTML sur les labels.
  - update UI 2026-04-02:
    - ces lignes de recap sont maintenant rendues comme des capsules plus ludiques, avec une variante `participation` froide et une variante `podium` plus chaude, pour donner un ton plus “jeu” a la carte organisateur.

## Update 2026-04-02 — `games -> play` sessionnel: branding absent non bloquant
- point d'entree concerne:
  - CTA `Compte joueur Cotton` du portail session `games`, vers `play/signin|signup/public/{token}`.
- regression corrigee:
  - les pages `signin/signup` sessionnelles ne supposent plus qu'un branding session/evenement/client existe forcement;
  - le retour de `app_session_branding_get_detail(...)` est maintenant normalise en tableau vide avant toute lecture de `visuel` ou `parameters`.
- effet:
  - l'absence de branding ne provoque plus de `500` avant rendu;
  - le flux `games -> play -> auth` peut donc de nouveau s'ouvrir meme quand seule l'imagerie par defaut doit etre utilisee.

## Update 2026-04-02 — Espace joueur: `Mes classements`
- nouvel ecran joueur:
  - `/extranet/dashboard/leaderboards`
- navigation laterale:
  - ajout d'une entree `Mes classements` entre `Historique` et `Pseudo / Equipes`.
- principe produit:
  - l'espace joueur reutilise maintenant les classements organisateur deja calcules via `global`, mais limite l'affichage aux seuls organisateurs deja lies au joueur sur la periode, via une liste legere de liens joueur -> organisateurs;
  - compromis retenu: cette liste d'organisateurs lies reste fondee sur les sources stables reliees au joueur;
  - les tableaux de classement affiches dans chaque section restent en revanche ceux du moteur organisateur stable `Mes joueurs`, donc avec leur consolidation complete moderne / legacy / runtime;
  - corollaire 2026-04-02: `play` herite aussi maintenant de l'exclusion des bridges non consommes et des joueurs runtime inactifs dans ces classements agreges;
  - l'ordre des sections est trie par frequence de participation du joueur chez chaque organisateur.
- regle de periode:
  - la page relit par defaut les `12 derniers mois` ancres sur la derniere activite reelle du joueur/equipe;
  - pour chaque organisateur, la page affiche le trimestre de cette derniere activite si le joueur y a deja une participation reelle;
  - sinon elle bascule sur le trimestre precedent;
  - si le joueur n'a pas de participation sur ces 2 trimestres pour cet organisateur, la section n'est pas affichee.
- restitution:
  - une section par organisateur;
  - a l'interieur, uniquement les jeux sur lesquels le joueur a reelement joue pendant le trimestre retenu;
  - sous `Saison affichee`, un petit recap separe affiche `Participations`, puis les compteurs podium (`victoires`, `2eme place`, `3eme place`) quand ils existent;
  - ces compteurs podium sont maintenant derives de la meme ligne surlignee dans les leaderboards organisateur canoniques, et non d'un recalcul historique joueur separe;
  - `Cotton Quiz` reste restitue au format classement equipes;
  - `Blind Test` et `Bingo Musical` restent restitues au format classement joueurs.
- historique joueur:
  - sur les cartes `Cotton Quiz`, quand une participation est rattachee a une equipe, la carte precise maintenant explicitement le nom de l'equipe concernee.
  - la page `/extranet/dashboard/history` charge maintenant par defaut les `12 derniers mois` d'activite reelle du joueur/equipe, ancrés sur la derniere participation retrouvee;
  - si des participations plus anciennes existent, un CTA `Charger plus` etend la fenetre de `12 mois` supplementaires a chaque clic, au lieu de charger d'un coup tout l'historique.
- home joueur:
  - les KPI de synthese sont maintenant eux aussi bornes aux `12 derniers mois` ancres sur la derniere activite reelle du joueur/equipe, pour eviter les recalculs complets de tout l'historique a chaque ouverture du dashboard.
- dependance inter-repos:
  - la page `play` depend d'un helper joueur cote `global` qui isole d'abord les organisateurs lies au joueur sur la periode, puis reutilise les contextes de classement organisateur existants.
  - durcissement 2026-04-02: le CTA `J'accede au jeu` cote `play` ne cree plus de ligne bridge `games_connectees` au simple rendu; la creation du bridge EP -> games est desormais differee au clic reel sur l'action, tandis que les parcours `games` conservent leur propre logique de finalisation.

## Update 2026-03-30 — Agenda/home EP: cartes session harmonisées
- cartes session (`/extranet/dashboard` et `/extranet/games`):
  - le composant partagé de carte session EP utilise maintenant un cadrage visuel uniforme pour toutes les sessions;
  - les photos de lieu/session sont affichées dans un ratio stable avec `object-fit: cover`, ce qui évite les hauteurs hétérogènes entre cartes;
  - les espacements internes des cartes sont resserrés et stabilisés entre visuel, méta jeu, lieu et footer d’action;
  - le footer garde un alignement plus régulier entre états `participation non signalée` et `participation signalée`.
- wording de confirmation:
  - `Blindtest` / `Bingo`: le message devient plus souple et parle maintenant de participation transmise à l’organisateur;
  - `Quiz`: le message devient plus souple aussi, avec variante équipe unique / équipe nommée / plusieurs équipes déjà signalées.
- CTA jour J:
  - sur les cartes agenda/home, `J'accède au jeu` reprend maintenant un rendu secondaire plus léger;
  - ce CTA est réduit pour se rapprocher du gabarit visuel de `Je participe` / `Mon équipe participe`;
  - la teinte suit le jeu courant via les variables de couleur déjà utilisées par le bloc de partage détaillé.
- cohérence de navigation home / agenda / détail:
  - la fiche détail expose maintenant un lien léger `Retour à l'accueil` ou `Retour à l'agenda` dans la ligne de header, à gauche de la zone compte;
  - ce lien reste masqué sur mobile;
  - les cartes ouvertes depuis la home injectent explicitement un contexte `back_to=home`;
  - les cartes ouvertes depuis l’agenda injectent `back_to=agenda` ainsi que les filtres actifs (`département/pays`, `organisateur`, `jeu`);
  - les CTA de participation des cartes continuent d’ouvrir la fiche détail, mais conservent ce contexte de retour;
  - sur la fiche détail, toutes les actions POST locales (participer, signaler une équipe, se désinscrire) rechargent maintenant l’URL courante complète, ce qui évite toute perte de contexte quand on enchaîne plusieurs actions depuis la home ou un agenda filtré.

## Update 2026-03-30 — KPI home EP et badges d'historique session
- home joueur (`/extranet/dashboard`):
  - les footers des 4 KPI (`Prochaines sessions`, `Sessions jouées`, `Top organisateur`, `Top jeu`) utilisent maintenant un style d'action plus proche des footers `ec`, avec accent rouge EP;
  - chaque bloc KPI est entièrement cliquable, pas seulement le CTA du footer.
- signalement de participation (`/extranet/games` et `/extranet/games/session/inscription/manage/...`):
  - `Blindtest` / `Bingo`: le message de confirmation parle maintenant explicitement de la participation du joueur;
  - `Quiz`: le message parle de la participation de l'équipe, avec le nom d'équipe quand il est connu dans le contexte de rendu;
  - `Quiz`: le libellé d'annulation devient `J'annule la participation de mon équipe`, rendu comme un simple lien texte plutôt qu'un bouton.
  - quand un parcours `games -> play` arrive avec `games_account_join=1` mais que la session n'est pas ouverte:
    - future non ouverte: après authentification / création de compte, `play` renvoie vers `manage/s1/{token}` pour prévenir l'organisateur;
    - expirée/non ouverte: après authentification / création de compte, `play` renvoie vers l'agenda joueur plutôt que de reboucler vers `games`.
  - règle temporelle de ce fallback:
    - `jour J` = parcours direct encore autorisé;
    - `lendemain de session` = encore autorisé strictement avant `12:00`;
    - au-delà = fallback agenda.
  - l'étape de confirmation `s2` affiche maintenant un bloc `Partager l'info` sous le message de confirmation:
    - une note légère `Rendez-vous sur place le {date} ...` est ajoutée sous ce message pour rappeler que l'inscription se valide sur place le jour J;
    - le bloc expose maintenant un vrai bouton `Invite tes amis` avec icône intégrée;
    - le bouton est un peu plus compact;
    - `Blind Test` dispose maintenant d'une couleur locale dédiée pour sa flèche de signalement et son icône de partage, sans modifier les couleurs historiques `Quiz/Bingo`;
    - sur mobile compatible, le clic ouvre directement le partage natif du téléphone;
    - sur mobile, le bouton est légèrement élargi pour garder un libellé lisible;
    - sur desktop, le clic ouvre de nouveau les options `Facebook`, `WhatsApp`, `Mail`, `Copier le lien`;
    - si le partage natif échoue, le fallback recopie automatiquement le lien;
    - le CTA repose maintenant sur une image d'icône EP dédiée, plus nette que le rendu précédent;
    - l'action `Mail` s'ouvre dans un nouvel onglet;
    - le lien partagé cible la page publique agenda/session côté `www`.
  - l'action `J'annule ...` reste sur le flux POST historique, mais son rendu visuel est maintenant celui d'un lien discret.
- historique joueur (`/extranet/dashboard/history`):
  - les cartes de session peuvent maintenant afficher des badges de résultat;
  - `Quiz` / `Blindtest`:
    - affichage limité à `🏆 Gagnant`, `🥈 2ème place`, `🥉 3ème place`;
    - aucun badge au-delà de la 3e place;
  - `Bingo`:
    - affichage d'un ou plusieurs badges de phases gagnées:
      - `🥉 Ligne`;
      - `🥈 Double ligne`;
      - `🏆 Bingo`;
    - aucun badge si aucune phase gagnée n'est retrouvée.
- source de vérité:
  - l'historique réel EP continue de partir de `championnats_sessions_participations_games_connectees` quand le bridge moderne est disponible;
  - les badges complètent cette lecture via les tables runtime des jeux:
    - `cotton_quiz_players` / `cotton_quiz_sessions`;
    - `blindtest_players` / `blindtest_sessions`;
    - `bingo_phase_winners` (+ `bingo_players` pour la résolution de clé canon si besoin);
  - fallback `quiz_legacy` conservé via `championnats_resultats` quand la participation moderne n'expose pas encore d'identité joueur runtime.

## Update 2026-03-27 — Espace joueur: home recentré sur l'historique réel
- le dashboard joueur (`/extranet/dashboard`) affiche maintenant:
  - un simple titre `Hello {prenom}` sans sous-titre;
  - une ligne de KPIs mixant:
    - `Prochaines sessions`;
    - `Sessions jouées`;
    - `Top organisateur`;
    - `Top jeu`;
  - chaque KPI est cliquable via son footer:
    - `Ajouter depuis l'agenda`;
    - `Voir l'historique`;
    - `Voir son agenda`;
    - `Voir l'agenda de ce jeu`;
  - le bloc visuel des cartes de participations probables à venir sous le titre `Tes prochaines sessions de jeu :`.
- un nouvel écran de détail est disponible:
  - `/extranet/dashboard/history`
- l'agenda joueur (`/extranet/games`) expose maintenant 3 filtres alignés sur la même ligne:
  - `Département / pays`;
  - `Organisateur`;
  - `Jeu`.
- comportement agenda attendu:
  - par défaut, les 3 filtres sont sur `Tous`;
  - l'utilisateur peut ensuite restreindre l'agenda par département, organisateur ou jeu;
  - la liste `Département / pays` est limitée aux zones réellement représentées par des organisateurs ayant des sessions dans l'agenda:
    - départements français si le client est en `FR`;
    - pays étrangers (`Suisse`, `Espagne`, etc.) si des organisateurs hors France sont réellement présents;
  - le filtre `Jeu` est normalisé sur les 3 familles visibles côté joueur: `Cotton Quiz`, `Blind Test`, `Bingo Musical`;
  - l'UI des filtres utilise des labels au-dessus des selects, sans mode `floating`, pour éviter tout chevauchement label/valeur;
  - en environnement `dev`, la lecture agenda ne re-filtre plus sur `c.online=1`, afin que `Tous` corresponde bien à l'ensemble des sessions configurées disponibles pour la recette.
- l'objectif produit est d'enrichir l'espace joueur par la mémoire des participations réelles, sans confondre cet historique avec les simples signalisations à l'organisateur.
- sur `signin/public/{token}/session_join` et `signup/public/{token}/session_join`, le visuel de tête est maintenant aligné sur la cascade `games` en contexte session:
  - branding récupéré via la même API `global_ajax ... action=get&token=...` que `games`;
  - puis branding session local `visuel.img_src`;
  - puis `place_bandeau_1`;
  - puis le visuel par défaut du portail `games` selon le jeu (`branding-qz`, `branding-bm`, `branding-bt`).
- la présentation des informations de session sur ces écrans EP suit maintenant le modèle `games`:
  - titre jeu stable (`COTTON QUIZ`, `COTTON BINGO`, `COTTON BLINDTEST`);
  - sous-titre unique `thème • date • heure|Démo`;
  - suppression du découpage ancien `date/lieu` puis `jeu/format/thème`.
- le visuel de tête reprend aussi le format `games`:
  - pleine largeur;
  - hauteur plafonnée à `240px`;
  - `object-fit: contain`.
- le signup joueur EP expose maintenant un champ `Pseudo` facultatif, positionné à droite de `Prénom`;
  - s'il est renseigné à la création de compte et valide (`1` à `20` caractères), il est écrit immédiatement sur `equipes_joueurs.pseudo`;
  - cela permet au premier flux de session `EP -> games` d'utiliser le pseudo sans attendre une édition ultérieure dans `Pseudo / Equipes`.
- le mail de bienvenue du signup joueur EP est maintenant envoyé via le template AI Studio `PLAYER_ALL_J0`, au lieu des anciens templates Brevo `403/426`.

## Update 2026-03-26 — Espace joueur: les CTA de session écrivent maintenant une participation probable dédiée
- repositionnement produit consolidé côté `play`:
  - les CTA et messages de session parlent de participation probable côté joueur (`Je participe`, `Mon équipe participe`) plutôt que d'inscription ferme;
  - les write paths `play` n'affectent plus de grille Bingo et ne créent plus d'accès jeu depuis l'espace joueur;
  - le support de persistance passe désormais par `championnats_sessions_participations_probables`.
- objectif produit:
  - permettre au joueur ou à son équipe de prévenir l'organisateur;
  - préparer la restitution côté `pro`;
  - ne plus promettre ni réservation ni accès garanti au jeu.

## Update 2026-03-26 — Compte joueur: retour moderne vers `games` pour auto-inscription
- les pages `signin/public/{session}` et `signup/public/{session}` acceptent maintenant un contexte `games_account_join=1`.
- après login/signup:
  - Blindtest / Bingo numérique: `play` prépare directement un retour vers `games`;
  - Quiz numérique: si le joueur a plusieurs équipes, `play` affiche un sélecteur dédié avant le retour.
- `play` ne crée toujours pas l'inscription runtime du jeu lui-même; il prépare un jeton de retour court consommé ensuite par `games`.
- nouveau point d'entrée connecté:
  - `/extranet/games/session/player-connect/{id_securite_championnat_session}`
- la persistance transversale du lien EP -> games repose sur `championnats_sessions_participations_games_connectees`.

## Doc discipline
- `canon/repos/play/TASKS.md` à mettre à jour à chaque action significative sur le repo.
- Mettre à jour ce `README.md` dès qu'un changement impacte le fonctionnel, les entrypoints, les dépendances inter-repos, la sécurité locale ou les conventions d'environnement.
- En cas de divergence, le code fait foi ; corriger la doc immédiatement.

## Etat 2026-03-26 — Initialisation du repo `play`
- repo local dédié désormais présent dans le workspace Cotton, avec remote GitHub `cotton-games/play`.
- code importé depuis la prod et nettoyé côté git pour ne plus suivre:
  - `web/config.php`
  - `web/info.php`
  - `logs/`
- les secrets déjà présents dans un historique antérieur doivent être considérés comme exposés si cet historique a été poussé avant nettoyage.

## Scope & entrypoints (confirmés)
- application PHP front unique servie depuis `play/web/`.
- rewrite principal: `play/web/.htaccess`
  - `/` et `/fr/` redirigent vers `ep/ep.php`;
  - `signup`, `signin`, `signin/reset`, `extranet/...` sont tous routés vers les entrypoints `ep`.
- entrypoints applicatifs:
  - `play/web/ep/ep.php`: shell principal de l'espace joueur connecté;
  - `play/web/ep/do_script.php`: write path PHP des formulaires/action handlers;
  - `play/web/ep/ep_ajax.php`: entrypoint AJAX modulaire;
  - `play/web/ep/do_script_specifique.php`: point d'entrée spécifique, branché directement sur certaines libs `global`.

## Surfaces fonctionnelles visibles
- authentification / réinitialisation mot de passe:
  - `play/web/ep/ep_signin.php`
  - `play/web/ep/modules/compte/authentification/**`
- inscription joueur:
  - `play/web/ep/ep_signup.php`
  - `play/web/ep/ep_signup_private.php`
  - le signup public ne demande plus le département; seul le flux de join de session conserve un `id_zone_departement` prérempli en hidden quand il est connu côté session/client.
- espace joueur connecté:
  - dashboard `communication/home`
  - historique joueur `communication/home/history`
  - compte joueur / équipe
    - page `Pseudo / Equipes` avec bloc `Pseudo` distinct du bloc équipes
  - agenda et inscription aux sessions de jeux
  - contributions `cotton_quiz`:
    - questions
    - lots
    - bonus
    - gains
- navigation latérale:
  - `Accueil`
  - `Agenda`
  - `Historique`
  - `Pseudo / Equipes`
- pseudo joueur:
  - destiné aux usages `Blind Test` / `Bingo Musical`;
  - validation alignée `games`: `1` à `20` caractères;
  - fallback sur `prenom` tant que le pseudo n'est pas renseigné;
  - support DB attendu via `documentation/equipes_joueurs_pseudo_phpmyadmin.sql`.
- equipes joueur:
  - les noms d'équipe sont utilisés pour les sessions `Cotton Quiz`;
  - la page `Pseudo / Equipes` liste les équipes du joueur et renvoie vers une vue dédiée de gestion par équipe;
  - après création, l'utilisateur est redirigé vers cette vue dédiée (`/extranet/team/profile/manage?id_equipe=...`);
  - cette vue dédiée affiche les joueurs liés, porte l'action `Quitter l'équipe` / `Supprimer l'équipe` selon le contexte, et expose un bloc d'invitation par email si l'équipe compte moins de `5` joueurs;
  - l'invitation équipe envoie maintenant un email transactionnel dédié; pour un joueur déjà existant, le CTA mail renvoie vers `signin`, et pour un nouveau joueur vers `signin/reset/{token}` afin de créer son mot de passe.

## Dépendances inter-repos
- dépendance runtime forte vers `global`:
  - `play/web/config.php` résout `global_root` et `global_url`;
  - `play/web/ep/ep.php`, `do_script.php`, `ep_ajax.php` et `do_script_specifique.php` chargent des librairies et helpers depuis `global`.
- dépendance fonctionnelle vers les briques jeux Cotton:
  - `cotton_quiz`
  - sessions publiques / privées
  - bingo musical, mais sans accès direct à la grille depuis `play`

## Sessions / participations probables
- les CTA `play` doivent rester bornés à un signalement de participation probable.
- support courant:
  - table `championnats_sessions_participations_probables`
  - table `championnats_sessions_participations_games_connectees` pour le pont compte joueur -> games
  - compat legacy historique via `equipes_to_championnats_sessions` (Quiz) et `jeux_bingo_musical_grids_clients` (Bingo)
  - lecture/écriture via `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - lecture côté joueur et préparation du retour `games` via `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- invariants:
  - aucun CTA `play` ne doit affecter une ressource de jeu runtime;
  - aucun CTA `play` ne doit promettre une réservation;
  - les seuls retours directs vers `games` doivent être explicitement demandés par le flux `compte joueur` moderne (`games_account_join=1`) et bornés par un jeton court.
  - sur la page de confirmation d'intention de participation, un CTA jour J vers `games` est autorisé s'il réutilise strictement `app_joueur_session_inscription_get_link(..., games_account_join=1)` ;
  - sur les cartes agenda, le clic carte hors CTA ouvre le détail;
  - sur les cartes agenda, les CTA d'ajout de participation rebouclent vers la fiche détail, pas vers un flux direct;
  - sur les cartes agenda, les sessions déjà annoncées n'exposent plus d'annulation; seul le CTA jour J `J'accède au jeu` reste autorisé;
  - le lien de retour de la fiche détail doit toujours refléter le vrai point d’entrée (`home`, agenda filtré, agenda non filtré);
  - les formulaires POST de la fiche détail doivent réembarquer l’URL courante complète comme `return_url` pour ne pas perdre ce contexte au rechargement;
  - l'historique visible dans l'espace joueur ne doit jamais réutiliser `championnats_sessions_participations_probables` comme source de vérité.
  - pour `Cotton Quiz` V2 (`id_type_produit=5`), les cartes agenda et le détail d'inscription doivent privilégier les métadonnées de séries remontées par `global` (`quiz_series_label`, `quiz_series_names`) plutôt que le legacy `theme/format/duree`.
  - pour `Cotton Quiz`, un joueur ne peut annoncer qu'une seule équipe par session; s'il veut changer, il doit d'abord désinscrire l'équipe déjà annoncée.
  - sur le détail d'une session quiz, dès qu'une équipe est déjà annoncée, seules les informations de cette équipe restent visibles; les autres équipes ne sont montrées qu'au moment du choix initial.
- home joueur:
  - les KPI de synthèse du dashboard sont des blocs cliquables complets avec footer d'action;
  - le 2e KPI de la home doit afficher le meilleur rang courant issu de `Mes classements`, pas un compteur de sessions jouées;
  - si ce meilleur rang vaut `1`, `2` ou `3`, le KPI doit ajouter respectivement `🏆`, `🥈` ou `🥉` devant le rang;
  - ce `Top classement` doit rester aligné avec la logique de `Mes classements`, mais ne doit pas bloquer le rendu initial de la home;
  - il doit être chargé en différé via un endpoint EP dédié;
  - le bloc `Tes prochaines sessions de jeu :` ne doit être affiché que si au moins une participation probable existe.
- historique joueur:
  - les sessions affichées doivent suivre la même notion de session réellement terminée que `Classement(s)`;
  - une session simplement passée dans le calendrier ne suffit plus si elle est démo, incomplète ou non terminée côté moteur.
  - chaque carte d'historique doit ouvrir la fiche détail de session `play`;
  - si la session est terminée, cette fiche ne doit plus afficher le flux d'inscription mais un rendu résultats simple basé sur `app_session_results_get_context(...)`;
  - pour `Bingo Musical`, la liste détaillée masque rang et points et devient `Liste des joueurs (xx)`;
  - pour `Bingo Musical`, ce total suit strictement la liste fournie par `app_session_results_get_context(...)`: si `bingo_players.session_id` existe, les anciens labels de playlist ne doivent pas ajouter de participants;
  - pour `Cotton Quiz` et `Blind Test`, le bloc détaillé devient `Classement complet (xx)` avec le nombre réel de participants.
  - si le podium Bingo n'est pas récupérable mais que des participants connus existent, la fiche conserve la liste et affiche une mention simple d'absence de podium.
- navigation EP:
  - l'ordre attendu du menu principal est `Accueil`, `Agenda`, `Mes classements`, `Pseudo / Equipes`, puis `Historique` en dernier.
- page leaderboards:
  - le libellé de page attendu est `Classement` s'il n'y a qu'une seule section, sinon `Classements`;
  - ce libellé doit être cohérent entre le `h1`, le titre navigateur et l'entrée de navigation.
  - les badges de synthèse organisateur doivent séparer visuellement l'emoji podium, le libellé et le volume (`×n`) pour rester lisibles;
  - l'ordre attendu est `libellé + volume`, avec libellés invariants: `Participations ×n`, `🏆 Victoire ×n`, `🥈 2ème place ×n`, `🥉 3ème place ×n`.
  - pour un organisateur donné, n'afficher que les jeux dont le joueur ou son équipe apparaissent réellement dans le leaderboard concerné; un simple lien historique à l'organisateur ne suffit pas.
  - la page `Classements` affiche maintenant aussi un podium agrégé par jeu, au-dessus du tableau saisonnier;
  - ce podium réutilise le style des podiums des pages de sessions historiques `play`;
  - les photos podium doivent être résolues via une URL publique stable `www/upload`, avec fallback automatique final sur `www prod` si le premier lien ne répond pas.
- page `Pseudo / Equipes`:
  - la liste principale ne montre plus ni modale joueurs ni suppression inline;
  - les noms d'équipe ouvrent maintenant une vue dédiée de gestion;
  - depuis cette vue, l'action devient un `quitter` si d'autres joueurs restent liés, et une suppression réelle de l'équipe si elle devient vide.
- menu compte avatar:
  - le dropdown affiche le `prenom` et l'adresse email du joueur;
  - il expose un CTA discret `Supprimer mon compte joueur` avec confirmation;
  - l'action de suppression doit rester irréversible côté expérience utilisateur.

## Conventions locales / sécurité
- `play/.gitignore` ignore actuellement:
  - `logs/`
  - `web/config.php`
  - `web/info.php`
- `web/config.php` est requis au runtime mais ne doit pas être versionné si il contient les accès d'environnement.
- la détection d'environnement `play` doit utiliser `HTTP_HOST` en priorité, avec fallback `SERVER_NAME`, et reconnaître les hosts `*.dev.cotton-quiz.com` comme `dev`;
- `web/info.php` ne doit pas être remis dans git ni exposé en prod.
- les logs serveur restent hors git.

## Points d’attention connus
- plusieurs requêtes SQL d'authentification et de reset sont encore construites par concaténation dans `play/web/ep/modules/compte/authentification/ep_authentification_functions.php`.
- un fichier historique `ep_authentification_script__20240229.php` est encore présent dans le tree applicatif.
- `ep.php` active `display_errors=1`; vérifier que ce réglage est bien maîtrisé selon l'environnement servi.

## Etat 2026-04-17 — Agenda / home: retrait des sessions deja terminees

L'agenda `play` et le bloc home `Tes prochaines sessions de jeu` ne reposent plus uniquement sur le critere SQL `date >= CURDATE()`.

Apres chargement, les listes repassent maintenant par le helper partage `app_sessions_filter_by_archive_state(...)` issu de `global`. Une session numerique terminee le jour meme sort donc de l'agenda et du resume home, meme si sa date n'a pas encore bascule au lendemain.

L'historique `play` restait deja aligne sur la terminaison reelle; ce lot vise a supprimer le drift entre cette page et les listes `a venir`.

## Etat 2026-04-17 — Cartes agenda `play`: label compact `quiz` mutualisé

Les cartes agenda `play` utilisent maintenant elles aussi `app_session_quiz_compact_label_get(...)`.

Effet attendu:
- les sessions `Cotton Quiz` V2 affichent un libellé court `1 serie` / `x series`;
- les anciens formats gardent un fallback sur `theme` si aucune métadonnée de séries n'est disponible.

## Etat 2026-04-17 — Fiche session `play`: mention de réserve sous les thématiques

La carte détail de session joueur affiche maintenant, sous la présentation des thématiques / playlists / séries:

`(Sous réserve de modification par l'organisateur.)`

La mention est réservée aux sessions encore à venir ou en cours, afin de ne pas polluer les fiches déjà archivées.
