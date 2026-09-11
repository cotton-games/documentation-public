# Hub Play — audit de fin de passe UX/UI, inscription à fin de programme

Historique d’audit du 06/09, complété le 07/09/2026. **La passe validée est maintenant implémentée localement**, sans déploiement ; l’état de livraison en fin de note remplace les mentions prospectives de l’audit ci-dessous. L’utilisateur avait confirmé les correctifs photo/consolidation et la vitesse ; le rebond reste hors périmètre.

Compléments de recette du 07/09 : `Chargement en cours…`, Quitter contextualisé, **masquage des lots par défaut annulé au profit des fallbacks backend**. Ces consignes remplacent la proposition initiale ; [audit départ/réinscription et preuves 415→416](hub-play-quit-rejoin-audit-2026-09-07.md).

## Sources, versions et portée des preuves

Parcours raw rechargé : [START main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), sections « Parcours de lecture » et « Discipline de génération » → [SITEMAP.txt develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), SITEMAP.md → index Games/Global → [DOCS_MANIFEST develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Routing rules » → HANDOFF, README/TASKS Games/Global et contrat Canvas Bridge.

Références métier utilisées :

- **D1** [README Games raw develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Update 2026-09-04 - Hub Play: fondation UX/UI de l’entrée joueur » : hero, entrée, identité, carte de session présentée, breakpoint 992, photo Top 3 auprès de l’identité. L’ancienne chip d’état a été supprimée : ne pas reprendre comme actuel le texte historique du 31/07 qui la décrit.
- **D2** même raw, « Update 2026-08-27 - Fin Hub Play et acquittement du podium Hub Master » : session terminée encore présentée, suspension empêchant la fin Play, acquittement local de l’auto-podium et réouverture du programme.
- **D3** même raw, « Update 2026-08-25 - Hub focus runtime vs présentation séparés », « Update 2026-08-25 - Hub Master: reload et présentation canonique » : présentation distincte du lancement, conservation de la sélection et refresh partiel.
- **D4** même raw, « Update 2026-07-30 - Hub Play: UI fusion et classement Global » et « Update 2026-07-31 - Hub Play lots dynamiques » : classement canonique, Top 3/joueur/voisins, lots séparés du résultat et payload sur polls existants. L’ancien critère photo par podium de session, encore écrit dans la section historique du 30/07, est remplacé par D1.
- **D5** [README Global raw develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Etat 2026-07-11 - Games hubs destination de presentation », « Update 2026-07-30 - Contexte Global Hub léger pour `aggregate_ranking` », « Update 2026-07-31 - Photo podium active Hub » : destination, lecture agrégée et photo active.

Journal AI Studio demandé : réponse HTTP 200, contenu Markdown décodé depuis le lecteur public, strictement identique à celui de la passe précédente (dernière mise à jour 28/08). Aucun nouveau fichier Hub signalé. Fichiers à comparer côté serveur : Games `web/modules/app_hub_view_helpers.php`, `app_hub_play_ajax.php`, Global `web/app/modules/jeux/hubs/app_games_hubs_functions.php` ; éventuels assets branding/podium seulement pour recette visuelle. Aucune source PHP serveur récupérable avec les accès disponibles : pas d’accès SSH opérationnel ni de credentials FTP utilisables ; les pages HTTP ne livrent pas ces sources. Aucune version locale remplacée, comparaison serveur non garantie. Empreintes avant/après et copies raw dans `/tmp/hub-play-ux-audit`.

Pas de navigateur pilotable exposé, ni Chromium/Chrome ou Playwright installé lors du contrôle. **Capture utilisateur inspectée : 360×740**, fichier local `Screenshot 2026-09-06 23.09.43.png`, fournie pendant l’audit. Aucun navigateur interactif ni capture 768×1024 ou ≥992 inspectés. La capture ne remplace pas une recette dynamique. Les risques CSS sont séparés des constats DOM/code. Pas d’installation ni de nouvelle infrastructure pour cette passe.

## Autorités et ordre réel d’affichage

**C1 — entrée et transport.** `games/web/modules/app_hub_play_ajax.php` charge le helper, choisit contexte initial ou contexte d’action, appelle `games_hub_handle_play_action`, puis `games_hub_render_page(...,'play')`. Les actions restent celles existantes.

**C2 — présentation Master.** `games_hub_presentation_state_resolve` (922) donne priorité au focus non terminé, puis au podium explicitement demandé s’il existe, puis au mode idle, puis à l’auto-podium. `games_hub_aggregate_podium_auto_is_eligible` (885) exige au moins un résultat terminé avec podium utilisable, un programme non vide, aucun focus et chaque session terminée **ou runtime running sans focus**. Ce dernier cas est la suspension Master, pas la fin de cette session.

**C3 — destination Global exposée à Play.** `app_games_hub_presentation_resolve` (Global, vers 10130) relit le Hub : `hub_podium` retourne immédiatement `target=hub_podium, session_id=0`; sinon session présentée valide, sinon focus, sinon première candidate Programme, ordre pending → suspended → finished. Le mode stocké `hub_idle` n’a pas de retour anticipé spécifique. `app_games_hub_presentation_mode_set` (4683) change le mode et les dates, sans effacer l’ID présenté.

**C4 — état personnel.** `games_hub_play_personal_state_resolve` (2450) applique : fermeture temporelle sans partie commencée ouverte → URL active → accès left/reprise ou papier → session présentée validée (preparing ou completed avec résultat contextuel) → focus contextuel → résultat pending → fin canonique → dernier résultat disponible → waiting. Le sous-calcul `games_hub_play_canonical_completion_state` (2140) exige programme non vide entièrement terminé, podium agrégé existant et mode podium ou auto-éligibilité. La priorité d’une session encore présentée peut empêcher le retour de `finished`, même si ce sous-calcul le permet.

**C5 — premier rendu / polling.** HTML initial : panneau `resolving` visible, formulaire `before` et panneau `ready` masqués (8359). `refreshCurrent` (11827) appelle `current_player`. Celui-ci calcule `personal_state` avec un **active_payload vide** (2879), donc sans destination Global jointe. Après succès, `showReady` expose identité/cartes, puis le watcher démarre immédiatement. `active_launched_session` (branche vers 2900) enrichit `presentation`, `session/access/play_url`, `program`, `last_result`, `personal_state`, `general_ranking`, `identity_photo`, `hub_prizes`, `hub_branding`. Les polls suivants recomposent les cartes via les mêmes renderers. Le watcher attend 3500 ms après achèvement de requête ; cadence inchangée. L’auto-navigation utilise exclusivement l’URL serveur, la reprise volontaire demeure réservée au cas can_manual_join.

## Matrice Master → Play

Dans la colonne Play, « initial » désigne le premier `current_player` confirmé, après le panneau de revalidation ; « poll » désigne `active_launched_session`. Aucun délai DOM n’est mesuré.

| État et condition exacte | Autorité/payload | Master | Play initial → poll | Écart ou implication |
|---|---|---|---|---|
| Aucune identité locale ou serveur confirmée | C1/C5, player absent/inactif | Sans effet sur Master | Resolving → formulaire | Inscription inchangée ; ne pas présumer inscrit d’après localStorage |
| Identité locale connue, confirmation pendante | current_player, statut player actif requis | Sans effet | « Retrouvons ton profil… », « Vérification de ton inscription à la soirée. » ; before/ready hidden | Pas de flash formulaire dans le chemin nominal ; transition technique, pas nouvel état métier |
| Confirmation réussie | player.status=active | Sans effet | showReady, nom serveur, photo/classement ; watcher immédiat | Carte personnelle initiale peut différer du poll, C5 |
| Identité invalide/absente | player absent ou non active | Sans effet | showBefore | Comportement attendu, distinct de l’erreur réseau |
| Échec réseau de revalidation | catch refreshCurrent | Sans effet | showBefore sans message réseau dédié | **Divergence fonctionnelle/feedback** : erreur indistinguable d’absence d’identité ; watcher pas démarré ; pas de relance automatique de current_player trouvée |
| Podium agrégé manuel, parties encore disponibles, aucun focus | C2 mode hub_podium + podium ; C3 target hub_podium | Podium général au centre, Programme organisateur disponible | Initial/poll : dernier résultat/completed ou waiting, pas finished car toutes non terminées | État intermédiaire, pas fin ; aucune variante personnelle spécifique hub_podium |
| Idle explicite avec parties disponibles | C2 manual_hub_idle ; C3 session présentée/fallback Programme possible | Auto-overlay acquitté, mode idle ; sélection/actions Programme conservées | Initial waiting/dernier résultat ; poll peut preparing sur une session résolue | **Pas équivalent au podium**, ni à « aucune session » ; écart de projection vérifié, à clarifier séparément de l’habillage |
| Session prête présentée, sans focus | C3 target session ; C4 non terminée | Fiche Programme et action organisateur | Initial peut waiting/ancien résultat ; poll preparing + jeu/thème/visuel | Transition technique initial/poll, pas nouveau lancement |
| Partie active avec focus, aucune autre prête | C2 runtime_focus_priority ; accès serveur | Session active, pas auto-podium | Preparing contextuel initial possible → playing/URL de routage au poll ; papier confirmation sans URL | **Jamais déduire fin d’« aucune partie prête »** |
| Terminées + suspendue(s), aucun focus | C2 auto éligible si podium utilisable ; C4 toutes terminées=false | Auto-podium possible ; session running non focus propose Relancer | Pas finished ; poll peut preparing sur suspendue résolue ou rester completed/waiting en hub_podium | Master autorise un podium intermédiaire. La formule « aucune prête = fin » est fausse |
| Toutes terminées, podium présent, destination hub_podium | C2/C4 | Podium final | finished sauf résultat pending prioritaire | Copie soirée/événement existante ; fin réversible |
| Session terminée encore présentée | C3 target session validé ; C4 branche presentation_session_finished | Session sélectionnée ; le calcul d’auto-podium reste indépendant | Initial peut finished/dernier résultat ; poll completed, « Partie terminée », résultat personnel ou absence | D2 : le contexte de session prime ; ne pas forcer un écran final sur seule dernière partie terminée |
| Toutes terminées, aucun classement/podium exploitable | C2 pas auto ; C4 has_aggregate_podium=false | Aucun podium à construire ; détail Programme reste possible | Pas finished par ce calcul ; completed/pending/waiting selon données | Écart à une fin de programme universelle ; **ne pas inventer une nouvelle règle de fin** pour habiller ce cas |
| Ajout d’une partie prête après fin | C4 all_sessions_finished=false ; quick-add remet mode session | Programme actualisé et sélection selon contrat existant | Au poll, sort de finished ; preparing si nouvelle présentation résolue, sinon état d’attente existant | Réouverture sans reload ni nouvelle action joueur |
| Reprise/relance suspendue | Focus/exécution/mode session depuis contrat launch existant | Relancer côté organisateur | Poll → accès/routage canonique ou reprise volontaire si left ; papier reste Hub | Aucun contrôle Relancer transféré au joueur |
| Fenêtre temporelle fermée, aucune partie commencée ouverte | C4 temporal_state | Commandes organisateur selon temporalité | closed avant les autres branches | Distinct de fin de programme ; copie actuelle « soirée » même contexte événement à vérifier |

### Sondes exécutées et frontières fonctionnelles

Sonde PHP hors dépôt, fonctions Games réelles et fixtures explicites : terminé+prêt donne Master session / Play_final=false ; terminé+suspendu donne Master auto-podium / Play_final=false ; terminé+focus donne Master session pour les trois modes stockés / Play_final=false. Tout terminé avec podium donne sous-calcul Play_final=true même en idle si auto-éligible : l’état personnel complet dépend encore de la priorité de présentation.

Sonde du resolver Global avec lectures Hub/session simulées : hub_idle sans ID + partie prête → target=session, reason=program_pending_fallback ; hub_idle avec ID valide → target=session, reason=presentation_session_id ; hub_podium dans les deux cas → target=hub_podium. Résultats dans `/tmp/hub-play-ux-audit/probe.php` et `global-probe.php`. Ce sont des preuves du code local, pas une observation des surfaces déployées.

Ces différences ne prouvent aucun rebond et ne justifient aucun changement de routage. Pour une passe visuelle sûre, utiliser les états personnels existants ; toute harmonisation de l’autorité idle/présentation exige un périmètre fonctionnel distinct validé.

## Audit Classement général

**Structure et données.** HTML 8469 : carte `.hub-player-waiting-card.hub-player-general-ranking`, titre h3, liste de divs et message « Tu n’es pas encore classé. ». `games_hub_play_general_ranking_for_player` (2100) consomme uniquement `aggregate_context.aggregate_ranking`, conserve l’ordre/rang et sélectionne les **trois premières lignes** plus joueur courant et voisins immédiats, dédoublonnés par index. Sortie : rank, label, score, stat, is_current ; current_rank/not_ranked au niveau global. **Photos et identités de lignes ne sont pas transmises à ce payload Play**, même si elles existent en amont.

**Top 3, égalités et petits effectifs.** Ce n’est pas un composant podium : liste compacte de rangs. Quatre joueurs tous rang 1, joueur courant parmi les trois premiers : trois lignes seulement ; quatrième courant : son voisinage peut ajouter la quatrième. La sonde le confirme. Pas de recalcul d’égalité, mais « trois premières lignes » n’est pas « toutes les personnes de rang ≤3 ». Un ou deux classés : une/deux lignes, aucun socle vide ajouté. Le joueur non classé obtient le message sous le classement disponible ; classement totalement vide : available=false, carte entièrement masquée. Aucun embranchement une/multiples sessions dans cette projection : même bloc si classement disponible. Le sous-titre Master « après N parties » n’est pas exposé ici.

**Premier rendu et mise à jour.** Carte masquée dans le PHP, remplie après current_player ; `renderGeneralRanking` (11739) vide/recrée les lignes à chaque réponse applicable. Photos absentes : aucun `<img>` et aucun fallback avatar dans cette liste actuelle. Les initiales/trophées du podium Master ne sont pas un composant Play existant. L’action photo reste exclusivement dans « Tu participes avec » ; ne pas la déplacer.

**Styles et risques.** CSS 5884 : grille `2.4rem minmax(0,1fr) auto`, rang #N, pseudo avec ellipsis/nowrap, stat nowrap ; ligne personnelle fond inversé. Titre h3 1rem, carte transparente bordée, radius8, padding1rem. Pseudo long effectivement tronqué par règle CSS ; manque de largeur possible entre stat non cassable et colonne pseudo à 360px. Absence de titre/expansion fournissant le pseudo complet dans le renderer. Contraste du rang secondaire sur fond inversé à tester avec branding réel. Liste reconstruite sans animation de podium ni annonce accessible de changement ; pas de saut visuel mesuré.

**Écart UX/UI.** Le hero et la carte de session ont une hiérarchie riche ; le classement reste une liste utilitaire, sans mise en avant distincte du podium, avec peu de séparation entre Top 3 et position personnelle distante. Scores techniques transmis mais stat affichée ; ne pas réintroduire arbitrairement les scores dans le futur visuel.

## Audit Lots

**Source.** Global `app_games_hub_prizes_get` (3612), `prizes_format_rows` (3516) et `prizes_default_context` (3538). Un à trois lots réels : labels non vides seulement, rang métier préservé via rank_value. Aucun lot : contexte canonique fournit actuellement les libellés génériques « 1ᵉʳ prix », « 2ᵉ prix », « 3ᵉ prix », avec is_default=true et source=hub_prizes_default. Ce contenu provient du backend existant ; il ne prouve pas qu’un lot est renseigné. Enregistrement des labels borné à 120 caractères, champs vides supprimés.

**Structure.** HTML 8475 : carte `data-hub-player-prizes`, h3 « Lots de la soirée » ou « Lots de l’événement », liste `.hub-player-prize-list`, lignes flex avec #rang + label. Aucune action joueur. La carte est dans ready et reste visible même si une liste vide est fournie. PHP rend les lignes depuis `$prizes`; JS `renderHubPrizes` remplace uniquement ces lignes, pas le titre. Labels insérés avec échappement PHP ou textContent.

**Écart fonctionnel prouvé.** `games_hub_play_prizes_payload` (814) remplace le rang métier par index+1. Le PHP initial fait de même ; le JS consomme ce rang déjà perdu. Lot uniquement #3 → affichage **#1**. Le même risque existe avec #1+#3 → #1+#2. Sonde PHP exécutée : fixture rank_value=3 « Lot trois » renvoie rank=1. **À corriger dans une future passe distinctement des styles**, sans changer l’attribution ni le stockage.

**Disponibilité des informations.** Payload Play actuel : rank,label seulement ; is_default/source/rank_value/description ne sont pas conservés. Il est donc impossible de masquer sûrement les seuls faux lots renseignés côté front sans enrichir cette projection depuis les métadonnées existantes. Aucun contenu de remplacement ni règle d’attribution à inventer. Le label fallback JS « Lot à personnaliser » est orienté organisateur ; le contexte nominal par défaut utilise toutefois les trois libellés génériques ci-dessus.

**Styles et risques.** CSS 5926 : liste grid gap1rem ; chaque lot flex baseline, padding .5rem 1rem, radius1rem, fond clair contrasté, texte600. Le label revient naturellement à la ligne avec espaces ; pas de min-width:0/overflow-wrap explicite sur ce span, donc un mot/URL très long peut déborder. Les capsules pleines, gaps et padding peuvent donner plus de poids aux lots qu’au classement ; c’est un risque de hiérarchie, pas une mesure visuelle. Les deux sections restent empilées, y compris ≥992 ; leur layout ne dispose pas d’adaptation spécifique.

## Proposition UX/UI — non implémentée

### Composition commune

Préserver le visuel et le branding, déplacer les textes du hero sous l’image selon la proposition détaillée ci-dessous ; conserver métadonnées et inscription déjà validées. Dans ready : identité/photo → carte contextuelle ou message d’état → classement général → lots → sortie discrète/logo. Même vocabulaire de bordure, rayons, alignements et titres pour les blocs restants ; ne pas ajouter de gros aplat concurrent au hero ni de contrôles Master.

- **<992px** : colonne unique, cartes de largeur disponible, titres alignés, espaces réguliers ; classement lisible avant lots. Stat peut occuper une seconde ligne si nécessaire ; nom doit rester consultable sans nouvelle action métier.
- **≥992px** : conserver la largeur actuelle de 920px ; identité puis carte contextuelle pleine largeur, puis grille classement majoritaire / lots secondaire alignée en haut. Pas de nouvelle coupure de mise en page à 768px ; 768×1024 utilise la composition portrait.
- **Revalidation** : conserver le panneau technique dédié et ses annonces accessibles, avec dimensions cohérentes avec l’entrée ; ne pas afficher les boutons inscrits avant confirmation serveur. Distinguer l’échec réseau de l’absence d’identité dans une évolution fonctionnelle bornée, sans ajouter de règle d’inscription ni d’action joueur non autorisée. Copie proposée seulement : « Vérification de ton inscription… » pour neutraliser soirée/événement.
- **Intermédiaire podium/idle** : montrer les données disponibles dans les sections communes ; ne pas titrer « Terminé » parce qu’aucune session n’est exposée. Le message reste celui de personal_state tant que l’écart idle/présentation n’est pas arbitré. Aucun équivalent du bouton Master d’ouverture/fermeture du podium.
- **Session présentée prête/active/suspendue/terminée** : conserver carte jeu/thème/visuel et priorité des données existantes. Suspension ne crée pas de bouton joueur Relancer ; les seules actions restent celles déjà autorisées par access/can_manual_join. Une session terminée conserve son résultat contextuel, sans lot répété dans la carte.
- **Fin et réouverture** : quand personal_state=finished, conserver la copie soirée/événement existante et donner la priorité visuelle au classement. À la nouvelle présentation, la carte de partie reprend sa place naturellement, sans écran final verrouillé. Un programme terminé sans classement ne reçoit pas de nouveau statut dans cette proposition.

### Classement

Proposition préférée : titre h3 conservé, groupe Top 3 compact puis position personnelle si elle n’y figure pas déjà, en gardant exactement les rangs et lignes autorisés par le payload. Une variante illustrée avec photos nécessiterait d’exposer les champs photo existants depuis les lignes canoniques ; ce n’est pas un changement de scoring, mais ce n’est pas réalisable par CSS seul. Ne pas réserver trois énormes emplacements si seulement un/deux joueurs ; pas d’avatar inventé ni de bouton photo sur le classement. Fallback proposé : initiale ou pictogramme neutre cohérent avec Master, à valider graphiquement. Égalités : conserver le même rang imprimé, ne pas attribuer artificiellement trois places distinctes. Le complément du 07/09 établit la sélection Master à reprendre : tous les rangs 1 à 3, sans limite de trois personnes.

Vide complet : ne pas fabriquer de podium. Proposition minimale : conserver le masquage actuel ; variante à valider si une continuité visuelle est voulue, titre + copie purement informative, sans score ni règle nouvelle. Non-classé dans un classement existant : proposition initiale remplacée le 07/09 par une ligne personnelle UI, voir le complément implémenté ci-dessous.

### Lots

Rangs métier exacts, labels réellement fournis, lignes plus sobres et capables de se déployer sur plusieurs lignes. Un seul lot → une ligne à son rang réel ; aucun emplacement vide artificiel. **Consigne finale du 07/09 : afficher les fallbacks canoniques fournis par le backend lorsqu’aucun lot n’est défini, comme Master. La proposition de masquage est annulée.** Conserver les métadonnées source/is_default sans les utiliser pour masquer ces valeurs, et ne recréer aucun libellé côté Play. Aucun texte d’attribution ni bouton de personnalisation côté joueur. Garder le titre contextualisé. Ne pas recopier les lots dans les lignes de classement ou le résultat personnel.

## Complément hero — constat visuel et proposition intégrée

### Observation sur la capture fournie

La capture montre Chrome DevTools réglé sur 360×740 (zoom de prévisualisation 80 %). Le visuel « WINTER ALE » contient déjà du texte (titre, « À la pression », description). « Bienvenue » et « Événement Cotton », produits par l’interface, sont superposés dans la même zone : **concurrence et recouvrement visibles**, particulièrement au bas du titre et de la description intégrés. Le dégradé sombre diminue aussi la lisibilité du bas de l’image. Le visuel paraît cadré intégralement, mais ses textes ne sont donc pas intégralement lisibles.

Les métadonnées sont déjà sous l’image, puis l’identité/photo et la carte « Prochaine partie / Blind Test ». Le classement visible contient une ligne personnelle (rang1) ; **aucune photo n’y est affichée**, cohérent avec le payload audité. Les Lots ne sont pas dans la portion capturée : leur absence de données ne peut pas en être déduite. Aucun débordement horizontal manifeste sur cette capture pour ces libellés courts ; titres longs, autres ratios et grandes tailles restent à tester.

### Cause de composition vérifiée dans le code

Games helper CSS 5141–5230 : `.hub-play-hero` porte ratio intrinsèque avec plafond `min(420px,52svh)`, image `.header-banner` en `object-fit:contain`, pseudo-éléments de dégradé et `.hub-play-hero__content` positionné en absolu, z-index3/bottom. Le titre blanc avec ombre mesure `clamp(1.75rem,8vw,3.7rem)`, line-height .96, overflow-wrap:anywhere. HTML 8035 : image puis contenu superposé avec unique `h1#mainTitle`, puis bloc `.hub-play-meta` extérieur.

`syncHubPlayVisualRatio` (11239) lit naturalWidth/naturalHeight et met à jour `--hub-play-visual-ratio` sur le hero, immédiatement si chargé puis sur load. `syncHubBranding` (11264) applique variables CSS, police, URL/révision visuel, logo, titre/document.title et métadonnées à partir des réponses existantes. La future séparation doit préserver ces hooks et le rafraîchissement déjà validé.

### Composition proposée — non implémentée

Ordre pour tous les états, y compris inscription/revalidation :

**Image intégrale sans texte d’interface → Bienvenue + h1 → date/heure → parties/joueurs → inscription ou identité/carte contextuelle → classement → lots.**

- Le wrapper de visuel seul conserve son ratio, `contain`, limite de hauteur raisonnable et fond branding pour les éventuels espaces résiduels. Aucun recadrage cover, aucune détection du texte de l’image, aucun nouveau contenu intégré au bitmap.
- Le bloc « Bienvenue » + titre passe dans le flux **entre l’image et les métadonnées**, avec les mêmes marges latérales que celles-ci. Il reste un bloc typographique, sans carte supplémentaire ni grand espace vide. Le h1 unique et son ID restent stables ; ajuster l’association aria-labelledby si le wrapper HTML change.
- Retirer de la zone image le dégradé de contraste servant aux textes superposés et les ombres associées. Conserver couleurs/police/visuel/logo du branding et l’éventuel fond du wrapper ; ne pas assombrir le contenu du visuel pour faire lire un texte qui n’y est plus.
- Le titre n’est pas limité artificiellement à une ligne ou tronqué. Retours sur espaces puis overflow-wrap pour mot exceptionnellement long, hauteur naturelle. Une réserve de hauteur du titre ne doit pas être prise dans le plafond du visuel : séparer les deux conteneurs évite son clipping.

### Compacité et variantes

| Taille | Proposition | Vérification / compromis |
|---|---|---|
| 360×740 | Image pleine largeur, bloc titre compact, marges ≈16px alignées aux métadonnées ; Bienvenue discret ; titre cible ≈24–28px, interligne ≈1,1–1,2 à valider avec police branding | Pour un ratio 5/2, image ≈144px, inchangée. Le titre séparé ajoute environ 60–90px avec titre court/deux lignes : estimation de composition, pas mesure navigateur. Compacter les espacements titre/métadonnées, jamais recadrer le visuel. Le classement pourra passer sous la ligne de flottaison : ne pas promettre de tout faire tenir en 740px |
| 768×1024 (<992) | Même colonne portrait, image contain ; bloc titre et métadonnées alignés dans la largeur existante | Titres deux/trois lignes sans overlap ; pas de bascule prématurée en deux colonnes |
| ≥992 | Visuel centré borné à la largeur de contenu proposée 920px, image puis titre toujours dessous ; titre/métadonnées alignés à cette largeur | À 920px et ratio5/2 : image≈368px avant autres plafonds. Éviter un visuel plein écran très large au-dessus d’une colonne texte étroite ; une grille plus basse peut porter classement/lots. Pas de retour à une superposition ni titre latéral |
| Visuel portrait ou texte intégré dense | Image entièrement contenue dans la hauteur bornée, éventuels espaces sur fond branding | Intégralité géométrique garantie par contain, lisibilité des très petits caractères de l’image non garantie ; ne pas inventer de zoom/action joueur |
| Titre long / nouvelle police / titre modifié au poll | Bloc texte en flux, sans hauteur fixe ; source serveur inchangée | Reflow attendu, pas d’ellipsis du h1, image indépendante ; tester 80–120 caractères et mot sans espace |

Les tailles/paddings ci-dessus sont **des cibles à valider**, pas une nouvelle règle UI implémentée. Wordings « Bienvenue » et titre serveur inchangés : aucune nouvelle copie proposée pour le hero.

### Impact futur et recette branding

Même fichier applicatif Games que le reste de la passe : HTML du header, CSS Play et références de `syncHubPlayVisualRatio` si le wrapper devient spécifique au visuel. Conserver `data-hub-play-branding-visual`, `mainTitle`, `data-hub-play-branding-meta`, logo, variables CSS, police et mécanisme de révision/cache-busting existants ; pas de nouveau fetch ou timer. Ne jamais reconstruire l’identité/photo à l’occasion d’un changement de hero.

Recette supplémentaire : 360/768/992+, visuel avec texte comme la capture puis sans texte, paysage/portrait, titre court/long, changement simultané titre/image/police/couleurs au polling, image lente ou en erreur. Vérifier contenu intégral, aucun texte d’interface superposé, ordre h1 puis métadonnées, pas de chevauchement ni défilement horizontal, pas de réinitialisation de la sélection photo/inscription.

## Périmètre minimal futur et arbitrages

**Socle visuel principal :** Games `web/modules/app_hub_view_helpers.php` (HTML/CSS Play, renderPersonalState/renderGeneralRanking/renderHubPrizes). Tests existants `hub_session_settings_test.php` et `hub_session_settings_dom_test.mjs` à adapter au futur DOM. `app_hub_play_ajax.php` n’a pas besoin de changer pour les seules projections, puisque les handlers sont dans le helper partagé.

**Projections bornées à prévoir si validées :** même helper Games pour rank_value des lots, conservation source/is_default, champs photo du classement et éventuelle convergence de la donnée personnelle initiale. Aucun changement du resolver Global, de la consolidation, du writer photo, du classement ni du routage pour réaliser la composition. L’écart hub_idle/Global et l’erreur réseau d’identité doivent être traités comme sous-tâches fonctionnelles explicites, pas cachés dans une refonte CSS.

Les choix hero, liste illustrée, lots backend/rangs exacts (fallbacks inclus), erreur réseau distincte et présentation initiale alignée sont **validés**. Le complément du 07/09 ci-dessous remplace les arbitrages visuels précédents et la proposition provisoire de conserver seulement trois premières lignes. Aucun nouvel accord sur ces choix n’est demandé.

## Recette d’acceptation proposée

À 360×740, 768×1024 et 992px minimum (puis écran large) : pas de scroll horizontal ; labels longs et mot sans espace ; photos absentes/présentes ; focus clavier, annonces resolving, contraste avec branding réel. Vérifier avant/après chaque réponse, pas seulement après stabilisation.

- Inscription neuve, identité locale valide avec réseau lent, cookie seul, identité invalidée, échec current_player : ni succès présumé, ni flash formulaire nominal ; erreur distincte si correction validée.
- Podium manuel avec partie prête ; idle après fermeture ; absence d’ID avec Programme présent : conserver la distinction de target/mode/reason.
- Tout terminé ; terminé+suspendu ; active sans autre prête ; session terminée encore présentée ; classement complètement vide : vérifier les conditions de la matrice et les actions inchangées.
- Ajout d’une partie après fin, reprise suspendue, joueur left, papier : convergence via polls existants, pas de reload manuel, pas de nouvelle action joueur ni d’auto-routing sur seule présentation.
- Classement : 0/1/2/3/4 joueurs, quatre ex æquo, joueur courant Top 3/hors Top 3/non classé, une/multiples sessions, photos A→B→C ; aucun changement des rangs/points/contributions, photo toujours auprès de l’identité.
- Lots : aucun réel, rang1 seul, rang3 seul, rang1+3, trois lots, suppression/réédition, libellé120 caractères, long mot ; rangs exacts et mises à jour par payload existant, aucune attribution inventée.

## Validation exécutée et documentation

`php web/tests/hub_session_settings_test.php` et `node web/tests/hub_session_settings_dom_test.mjs` passent dans Games. Sondes PHP locales de matrice, sélection ex æquo sans photo, rang de lot partiel et resolver idle exécutées hors dépôt. Aucun nouveau test applicatif écrit et aucun patch applicatif dans cet audit. Capture utilisateur 360×740 inspectée ; pas de mesure de performance ni de recette navigateur interactive revendiquée.

HANDOFF et TASKS Games/Global actualisés dans les entrées existantes, confirmation de recette photo/vitesse consignée. README Games clarifié seulement pour les écarts de payload vérifiés ; aucune proposition inscrite comme implémentée. Sitemap/index générés puis relus, lien de cette note vérifié. Empreintes des trois sources applicatives inchangées.

## Complément du 07/09 — décision réellement affichée et ex æquo

### Preuves et limites actualisées

START raw main, sitemap TXT/MD, index Games/Global, manifeste, HANDOFF et README/TASKS raw develop rechargés. Contrats : **D2** (fin, session terminée présentée, acquittement local), **D3** (focus distinct de présentation et restauration Master), **D4** (Top 3/joueur/voisins). Les URL et sections exactes figurent dans les sources ci-dessus. Journal AI Studio raw HTTP 200 relu : dernière mise à jour indiquée 28/08 ; aucune entrée récente Hub trouvée. Copies de cette passe : `/tmp/hub-play-ux-audit-0709`. Comparaison des sources PHP serveur **non disponible** avec les accès présents ; aucun écrasement local. Les conclusions portent sur le code local et les fixtures, pas sur le DOM déployé.

### Chaîne exacte : aucune autorité unique ne suffit aujourd’hui

1. **Stockage** : `presentation_mode` et `presentation_session_id` sont indépendants. Fermer le podium écrit `hub_idle` sans effacer la session (`app_games_hub_presentation_mode_set`, Global 4683).
2. **Destination Global** : `app_games_hub_presentation_resolve` (10131) traite d’abord le mode podium, puis l’ID présenté valide, puis le focus, puis le Programme pending/suspended/finished. Il ne connaît ni l’éligibilité de l’auto-overlay Master ni son acquittement local. Ses consommateurs directs sont le view model Games (4284), l’action Play (2903), `app_hub_remote_ajax.php` (287) et le resolver Global d’accès joueur (10235). Le modifier pour l’habillage impacterait donc aussi Remote et les accès.
3. **Affichage PHP Master**, dans `app_hub_view_helpers.php` : `games_hub_presentation_state_resolve` (922) choisit l’overlay selon focus non terminé → podium manuel exploitable → idle manuel → auto-podium → session. Séparément, `games_hub_master_presentation_selection_resolve` (4066 environ) choisit la carte : destination Global valide → focus → retour de complétion naturel si contexte correspondant → prête → suspendue → dernière complétion → première session métier. Ces fonctions sont déjà partagées dans le helper Games ; le renderer programme leur fournit aussi les événements de complétion et le contexte de retour Canvas.
4. **DOM Master** : `renderCentralForSelectedSession` affiche l’overlay seulement en mode podium avec son nœud disponible ; sinon le podium de la session sélectionnée s’il existe, sinon le branding. `closeHubPodium` conserve cette sélection sans second POST de session. `hubMasterPresentationModeAfterRefresh` neutralise l’auto-overlay déjà acquitté pour la même clé ; `applySelectionIntent` conserve une intention locale de sélection. Ainsi **idle peut montrer un podium de session**. Le mode stocké ne prouve pas le contenu central. Le focus neutralise l’overlay, mais une destination de présentation valide est prioritaire dans la sélection de carte : ne pas confondre ces deux priorités.
5. **Play** : `games_hub_play_personal_state_resolve` (2450) consomme la destination Global au poll, sans la composition d’affichage Master ; `current_player` lui passe un payload actif vide (2879). Les branches runtime/access précèdent la carte présentée ; la fin canonique exige toutes les sessions terminées et un podium agrégé, jamais la seule absence de partie prête.

**Source réutilisable proposée** : composer les deux helpers Master existants dans un unique helper pur Games de décision d’affichage, puis le faire consommer par le renderer Master et les deux projections Play. Sortie distincte `display_presentation` : mode effectif, raison, session sélectionnée, disponibilité du podium et clé d’auto-ouverture ; garder `presentation` et tous les champs d’accès/runtime inchangés. Réutiliser les règles existantes, sans nouvelle politique parallèle Play. Le contexte de retour naturel reste une entrée explicite Master ; ne pas inventer un retour Canvas pour une requête Play.

Une limite subsiste : le serveur ne connaît pas une intention DOM locale ou un acquittement avant son POST confirmé. L’alignement proposé porte sur la décision persistée/résolue, avec convergence aux polls existants. Garantir à Play chaque état transitoire local Master demanderait de publier cet état : **extension de contrat à arbitrer si cette synchronisation exacte est exigée**, hors proposition minimale. Ne pas modifier la mémoire d’acquittement actuelle pour contourner ce point.

### Matrice complémentaire : affichage, divergence, réutilisation

Initial = réponse `current_player`, poll = réponse `active_launched_session`. États indiqués sous réserve des priorités personnelles closed, accès/runtime et résultat pending ; aucun routage ne découle de cette matrice.

| Situation | Master réellement rendu | Play initial → poll aujourd’hui | Résolution minimale proposée |
|---|---|---|---|
| Podium manuel exploitable + partie prête, sans focus | Overlay agrégé ; carte sélectionnée masquée | Dernier résultat/attente → idem si Global target podium ; pas de fin tant que programme incomplet | Reprendre l’overlay effectif ; interdire le fallback personnel vers une autre session pour la présentation ; conserver l’état intermédiaire existant |
| Terminée + suspendue, aucun focus, résultats exploitables, mode session | Auto-overlay : chaque session terminée ou running sans focus | Initial non final → preparing si Global choisit la suspendue | Consommer la décision Master et son caractère intermédiaire ; aucune nouvelle fin, aucun bouton Relancer joueur |
| Fermeture podium → idle | Overlay fermé ; podium de la session sélectionnée s’il existe, sinon branding ; Programme disponible | Initial sans destination → carte de la session Global, éventuellement différente | Réutiliser aussi la sélection Master, pas traduire idle en attente universelle ; préserver l’acquittement JS |
| Session terminée explicitement présentée | Son podium si overlay inactif ; si auto-overlay éligible, l’overlay masque cette sélection | Initial peut final/dernier résultat → completed de la session Global | Conserver completed lorsque cette session reste effectivement présentée ; ne pas prendre son seul ID pour preuve qu’elle est visible |
| Toutes terminées + classement exploitable | Auto-overlay sauf idle/acquittement ; podium manuel possible | Initial peut finished → completed si Global expose une session ; pending peut primer | Utiliser la décision commune pour savoir si une session porte encore le contexte ; conserver les conditions actuelles de fin |
| Toutes terminées sans classement exploitable | Pas d’overlay agrégé ; session/branding selon sélection et disponibilité du podium de session | Pas de fin canonique ; completed/pending/attente | Aucun nouvel état final ; conserver les fallbacks légitimes de contenu personnel |
| Ajout d’une partie après fin | Quick-add remet session ; programme/sélection actualisés | Sort de finished au poll ; preparing selon destination | Même décision dès current_player, puis polls inchangés ; nouvelle fin réarme la clé existante |
| Reprise/relance, ou partie active prioritaire | Focus non terminé interdit l’overlay ; carte selon sélection existante | Initial sans accès résolu → URL runtime/playing, reprise volontaire ou papier au poll | Priorité absolue aux accès pour la navigation ; ne pas utiliser la session d’affichage comme destination runtime |

Le fallback personnel ne doit plus choisir une session concurrente quand la décision commune indique l’overlay agrégé. Cela ne signifie pas supprimer les résultats personnels, ni forcer `finished` : la condition « toutes terminées », les résultats pending et les accès restent ceux du contrat actuel. Une décision indiquant une session visible conserve sa carte de résultat, même terminée.

### Premier rendu et récupération réseau bornée

`games_hub_light_context_options_for_action` (174) charge déjà, pour les deux actions, sessions, résultats, événements de complétion et agrégat. La composition pure réutilise ces données ; elle ne rappelle ni consolidation ni renderer complet. Fournir la même décision d’affichage aux deux appels du resolver personnel et la tester à contexte identique. La lecture légère Global de présentation peut être commune, sans changer sa politique.

**Ne pas appeler** `app_games_hub_get_active_launched_session_for_player` dans current_player pour obtenir cette seule décision : il appelle `app_hub_player_resolve_session_access(... join_source=auto)` et peut créer/réactiver une participation. Aucun resolver pur complet équivalent de cet accès **trouvé**. L’égalité de présentation est réalisable sans cela ; l’égalité de tous les états d’accès avant le premier poll ne l’est pas forcément. Si l’accès est encore inconnu, conserver une transition technique de vérification de la carte jusqu’au premier poll immédiat, plutôt qu’une fausse carte d’attente. L’identité confirmée peut déjà être affichée ; aucune nouvelle règle métier ou action joueur.

`refreshCurrent` doit distinguer absence/inactivité **confirmée par réponse serveur** de transport, timeout, HTTP d’erreur et JSON illisible. Proposition bornée : réutiliser cette fonction, une seule requête en vol, deux reprises automatiques au maximum après l’essai initial, délai local de 3500 ms et timeout par requête à définir dans le patch (cible 8 s). Ce délai ne change pas le watcher global. Pendant l’échec, garder l’identité non confirmée, panneau de vérification avec erreur accessible ; après épuisement, message d’indisponibilité et arrêt des tentatives. Ne pas vider l’identité mémorisée, confirmer ready ou montrer l’inscription sur cette seule erreur. Aucun nouveau bouton proposé ; le chargement normal suivant relance le mécanisme. Tester annulation des timers et réponses tardives pour éviter deux transitions concurrentes.

### Sélection canonique des ex æquo et photos

**Master réel** : `games_hub_aggregate_podium_rows` (728) accepte chaque ligne `rank > 0 && rank <= 3 && label !== ''`, groupe par rang, conserve toutes les `entries` et leur ordre source, puis trie les groupes par rang. Le HTML des slots (vers 8157) émet toutes les entrées ; `startHubPodiumRotations` (9615) les fait défiler par rang toutes les 5 s. Ce défilement ne limite pas l’éligibilité à trois personnes. Petit effectif : seulement les personnes réelles dans les groupes ; le renderer Master peut conserver des slots vides, la liste compacte Play n’a pas à les reproduire.

**À ne pas confondre** : Global `app_games_hub_aggregate_podium_from_ranking` (8008) filtre les rangs éligibles puis applique `array_slice(..., 0, 3)` par défaut ; `aggregate_top3` et les trois premières lignes Play ne sont donc pas la sélection complète du podium Master. `games_hub_play_identity_photo_access` (2369) vérifie le rang personnel dans tout le classement canonique, puis `1 <= current_rank <= 3`, identité Hub active requise : un quatrième joueur rang 1 reste éligible. Aucune modification d’éligibilité proposée. D4 documente Top 3/joueur/voisins ; une règle documentaire limitant le **Master** à trois personnes malgré les égalités : **non trouvé**. Le comportement exhaustif est établi par le code et la sonde.

Sonde du 07/09, fonctions réelles, fixture de rangs `[1,1,1,1,2,3,4]` : Master groupes **4/1/1**, soit six personnes ; helper Global **3** ; Play avec joueur absent **3** ; quatrième rang 1 éligible photo **1** ; sa photo `/photo/4.jpg` est conservée par Master. Sonde temporaire `ties.php`, sans base ni réseau. Le chemin photo absent utilise l’absence de resolver actif dans la sonde ; celle-ci vérifie la sélection et la projection, pas l’upload ni la disponibilité HTTP d’une image.

**Réutilisation** : extraire la sélection pure des lignes éligibles depuis le helper Master, consommée par celui-ci et Play, ou conserver leurs identités dans ses entrées avant réutilisation. Aujourd’hui ce helper omet `identity_key` : ne pas rapprocher par pseudo. Conserver l’identité exacte et l’index canonique, réunir ce groupe de tête avec le joueur et ses voisins immédiats déjà définis, dédoublonner par index/identité, afficher dans l’ordre source. Aucun tri de score ou recalcul de rang ; tous les ex æquo éligibles restent présents. La liste statique n’a pas besoin du timer de rotation Master.

Les lignes agrégées portent déjà `photo_src`, `photo_source`, et la référence `hub_photo_media_id` lorsque disponible. Transmettre au minimum les deux premiers champs dans la projection Play ; ne demander le media_id que si un usage UI le justifie. Les voies consolidée et de secours sont déjà enrichies. **Zéro nouvelle lecture média par ligne, zéro nouveau calcul agrégé** attendu ; vérifier les compteurs de requêtes sur la future projection. Le contrôle et la photo propre de l’identité conservent leur chemin existant. Aucun score, rang, égalité, contribution ni contrat photo modifié.

### Périmètre futur, arbitrage résiduel et tests

- **Games `web/modules/app_hub_view_helpers.php`** : composition pure des décisions existantes consommée par Master/current_player/poll ; projection de sélection et photos ; HTML/CSS hero, classement/lots ; rendus JS, revalidation bornée. Préserver les hooks branding, la garde du formulaire photo et ses générations de réponse. Aucun besoin établi de modifier `app_hub_play_ajax.php`.
- **Global et Remote** : aucune modification proposée ; leurs consommateurs du resolver demeurent inchangés. Toute migration de la politique Master dans Global serait une extension distincte, inutile au périmètre minimal Games partagé.
- **Tests futurs Games** : adapter `hub_session_settings_test.php` et `hub_session_settings_dom_test.mjs`, ajouter des assertions de décision commune et de sélection pure. Tester chaque ligne de matrice au premier rendu et au poll ; idle avec/sans podium de session ; auto-overlay acquitté même clé puis nouvelle clé ; session terminée visible contre masquée ; absence de participation créée par current_player ; URL runtime inchangée malgré autre session d’affichage.
- **Ex æquo** : 0/1/2 personnes, quatre rang 1, égalités rang 2/3, joueur éloigné/voisin/absent, identités homonymes ; union sans doublon, ordre/rangs identiques à l’entrée, photos présentes/absentes, aucun appel média par ligne. Vérifier que le quatrième rang 1 garde son droit photo.
- **Réseau** : erreur puis succès, échecs jusqu’à la borne, timeout et réponse tardive, absence serveur confirmée, identité inactive ; jamais de formulaire ou ready sur simple erreur. Hero 360/768/992+, titres longs, lots #3 seul/#1+#3/aucun, photos A→B→C et branding au poll restent dans la recette future validée.

Arbitrage résiduel uniquement : une éventuelle exigence de refléter aussi les intentions Master non encore persistées demanderait un contrat supplémentaire ; la proposition minimale conserve leur caractère local. Les choix visuels ne sont pas remis en validation.

**Exécuté dans ce complément** : sonde ex æquo ci-dessus, tests PHP et DOM Games existants **OK** (avertissement d’environnement bus sans échec de test). Lecture des fonctions PHP/JS de présentation et de leurs consommateurs. Aucun nouveau test applicatif écrit, aucun patch applicatif, aucune mesure navigateur ou performance nouvelle ; recette réelle et nouvelles assertions du futur patch restent à réaliser. Documentation seule actualisée ; sitemap/index régénérés et relus.

## Livraison locale du 07/09 — passe validée implémentée

### Sources et périmètre effectif

Avant patch : START main, sitemap TXT/MD, index Games/Global, README général, manifeste, HANDOFF, README/TASKS Games et README Global raw develop rechargés. Contrats utilisés : **D1**, section « Update 2026-09-04 - Hub Play: fondation UX/UI de l’entrée joueur » ; **D2**, « Update 2026-08-27 - Fin Hub Play et acquittement du podium Hub Master » ; **D3**, séparation focus/présentation ; URL raw exactes en tête de cette note. Journal AI Studio raw HTTP 200 : dernière mise à jour 28/08, aucun fichier Hub récent trouvé. Copies raw et sauvegarde pré-patch du helper dans `/tmp/hub-play-implementation`. Sources serveur Games/Global non récupérables avec les accès disponibles : aucun accès SSH/FTP utilisable, aucune prétention d’égalité serveur/local. Games était propre avant modification ; les travaux déjà présents dans les autres dépôts sont préservés.

Application : **Games uniquement**, `web/modules/app_hub_view_helpers.php`. Tests adaptés : `web/tests/hub_session_settings_test.php` et `web/tests/hub_session_settings_dom_test.mjs`. Aucun fichier Global/Remote, aucune migration, aucun déploiement.

### Correctifs fonctionnels et composition

- `games_hub_display_presentation_resolve` compose les deux helpers Master existants, sans I/O propre. Renderer Master et projections Play le consomment ; le contexte de retour naturel reste fourni uniquement par Master. La projection `display_presentation` est distincte des contrats `presentation`, accès et URL runtime. Les groupes de podium sont retirés de cette seule projection Play pour ne pas doubler les listes à chaque poll.
- Le resolver personnel conserve temporalité, accès et résultat pending ; une session terminée effectivement sélectionnée garde sa carte. L’overlay intermédiaire écarte le fallback de session et utilise l’attente existante. La fin exige toujours les conditions canoniques ; suspension, ajout et reprise ne deviennent pas une fin artificielle. Le JS d’acquittement Master et ses clés ne changent pas.
- `current_player` fournit la même décision de présentation, sans appeler le resolver d’accès créant une participation. `personal_context_pending=true` indique que l’accès personnel est encore inconnu : après identité confirmée, la carte reste techniquement en chargement jusqu’au premier poll immédiat. L’identité/photo est sortie du conteneur masqué de contexte ; elle reste donc visible. Les sections déjà valides ne sont pas masquées à chaque poll.
- Hero : image seule dans son wrapper contain/ratio/plafond, h1 unique et Bienvenue en flux dessous, métadonnées ensuite. Dégradé de superposition et ombres supprimés. Hooks branding, police, logo et rafraîchissement conservés ; la mise à jour ne remonte pas l’éditeur photo. Liste sur une colonne sous 992 ; grille classement/lots à partir de 992 dans la largeur existante 920, pleine largeur lorsqu’une seule section est visible.
- `games_hub_aggregate_podium_selection` est maintenant la sélection commune Master/Play : tous les rangs 1–3, puis union avec joueur/voisins par index canonique et identité exacte. Rangs, ordre, égalités inchangés ; séparation visuelle si des lignes intermédiaires sont omises. Photos déjà enrichies transmises, sans SELECT média par ligne ; erreur image masque la vignette et conserve rang/pseudo. Aucun emplacement vide pour compléter trois personnes, aucune rotation Play. Signature stable : pas de reconstruction DOM ou de rechargement d’image au poll identique.
- `games_hub_play_prizes_payload` conserve le rang métier et toutes les valeurs canoniques, défauts inclus, avec source/is_default. La consigne antérieure de filtrage des défauts est annulée ; une suppression totale restaure les mêmes fallbacks backend que Master. Le HTML initial utilise ce même helper ; #3 seul reste #3, #1+#3 reste #1+#3. Renderer JS gère suppression/ajout, retour des fallbacks et grille ; seule une réponse réellement vide/non disponible reste masquée sans libellé inventé. Libellés multilignes et mots longs ; aucun lot ajouté au résultat personnel.

### Copies exactes des transitions

| Situation | Texte | Comportement |
|---|---|---|
| Arrivée, identité non confirmée | `Vérification de ton inscription…` | Panneau compact, indicateur discret, inscription/ready masqués |
| Identité confirmée, contexte d’accès inconnu | `Chargement en cours…` | Identité/photo visibles ; carte précédente masquée, aucun faux état métier |
| Revalidation technique en échec, reprise prévue | `Connexion interrompue. Nouvelle vérification…` | Identité mémorisée conservée non validée ; pas de formulaire |
| Trois essais épuisés | `Vérification indisponible pour le moment.` | Plus de spinner ni timer de reprise ; aucun bouton ajouté |
| Poll en erreur ou premier contexte toujours inconnu après 8s | `Connexion interrompue. Nouvelle vérification en cours.` | Spinner arrêté, sections valides conservées, watcher existant inchangé |
| Podium intermédiaire | `En attente de la prochaine partie.` | Attente métier existante, sans session concurrente et sans copie de fin |

Revalidation : un essai + deux reprises au maximum, 3500ms entre essais, timeout 8000ms couvrant transport et JSON ; AbortController et génération ignorent les réponses obsolètes. HTTP non réussi, JSON illisible et succès malformé restent techniques. L’absence/inactivité doit être confirmée dans une réponse valide. À pagehide, requêtes obsolètes annulées ; pageshow bfcache revalide. Le watcher conserve son intervalle historique ; sa requête annulée ne peut plus rendre/naviguer lors d’un nouveau cycle. Messages identiques non réinjectés, `role=status`/`aria-live`, `aria-busy` et réduction des animations ; aucune animation d’entrée rejouée sur poll identique.

### Vérifications exécutées

- `php web/tests/hub_session_settings_test.php` : **OK**, matrice partagée (intermédiaire, final, suspendue, idle, session terminée visible/masquée), rangs/ex æquo/homonymes/voisins/petits effectifs et lots partiels/defaults. Le vrai handler `current_player` tourne en sous-processus avec des resolvers d’accès qui lèveraient une exception s’ils étaient appelés : réponse correcte, aucune participation créée par cette projection. Vingt projections display/classement ajoutent **0 lecture média** dans le double de test.
- `node web/tests/hub_session_settings_dom_test.mjs` : **OK**, tests existants d’acquittement même clé/nouvelle clé, transport HTTP/JSON, horloge simulée (succès, reprise, épuisement, timeout, réponse tardive, annulation), contexte inconnu sans spinner infini, DOM classement stable et images A→B→C/cassées, lots supprimés/réajoutés, requête de watcher obsolète sans rendu ni navigation. Syntaxe du module Play complet vérifiée.
- Games : `hub_photo_replace_test.mjs`, `hub_presentation_runtime_separation_test.php`, `hub_context_fast_path_test.php`, `hub_remote_contract_test.php` **OK**. Sélection/consentement maintenus pendant les polls, annulation et ancienne référence conservée sur erreur, remplacement A→B→C et lectures tardives couverts.
- Global inchangé : `hub_photo_replace_test.php`, `hub_aggregate_photo_fallback_test.php`, `hub_stats_pending_session_test.php` **OK** : premier ajout, remplacements, refus hors Top 3, photos entre chemins, invalidation/rebuild réel simulé puis **20 lectures Master/Remote sans fallback**. Aucune nouvelle mesure de latence HTTP ou DB déployée revendiquée.
- PHP lint et `git diff --check` : **OK**. Avertissement système de bus et avertissement Node expérimental File sans échec de test. Aucun nouveau test réseau vers les serveurs métier.

### Recette réelle restante et retour arrière

Pas de navigateur pilotable/Chromium/Chrome disponible ; **aucune nouvelle capture ni validation visuelle interactive** revendiquée. À réaliser après livraison DEV séparée :

1. À 360×740, 768×1024, 992 et large, arrivée réseau lent puis identité confirmée ; contrôler absence de flash formulaire/ancienne carte, titre long, visuel contenant du texte et métadonnées sans overlap.
2. Depuis Master, parcourir podium manuel avec partie disponible, fermeture idle, session terminée présentée, terminé+suspendu, fin avec/sans classement, ajout et reprise. Play suit la décision confirmée au poll ; URL d’accès runtime inchangée.
3. Simuler réseau coupé à l’arrivée jusqu’à épuisement, puis pendant les polls : identité non présumée, spinner arrêté, sections valides maintenues ; reload normal pour une nouvelle revalidation. Tester retour navigateur et réponse tardive.
4. Ex æquo au-delà de trois personnes, homonymes, joueur éloigné ; photos A→B→C et formulaire ouvert pendant plusieurs polls ; image cassée/lente, reload et propagation aux podiums. Lots #3, #1+#3, aucun, suppression/ajout ; modification du branding et labels longs.

Retour arrière : retirer uniquement le diff de cette passe sur le helper Games et ses tests, en préservant les correctifs photo/consolidation préexistants. Aucune donnée à migrer ou restaurer. HANDOFF/TASKS mis à jour dans les entrées existantes, README canon et CHANGELOG actualisés ; sitemap/index générés puis relus.


## Complément du 07/09 — attente générique et ligne personnelle implémentées

Recette quitter/réinscrire validée par l’utilisateur le 07/09 : le pseudo utilisé avant départ est bien refusé. Correctif conservé ; cette validation ne vaut pas recette des nouveaux ajustements de classement.

Sans carte de session visible et avec classement disponible, le conteneur d’attente générique est masqué entièrement : identité → classement → lots. Carte présentée, chargement/erreur, préparation de résultat, fin et absence de classement restent inchangés. Le joueur absent du classement dispose d’une `personal_row` UI distincte des lignes canoniques : rang « — », pseudo exact et repère « Toi », style personnel existant. « 0 part. » exige `stats_parties_count=0`, `stats_computed_at` valide, champs dirty/erreur présents et vides, et dernier résultat confirmé indisponible ; pending affiche « Résultat en préparation », sinon « Non classé ». Aucun score/photo/droit ajouté, aucune association par pseudo ; la première ligne canonique remplace la ligne personnelle. Classement global vide toujours masqué, aucune lecture supplémentaire ni changement de polling.

**Preuves et données.** START main (« Discipline de génération »), sitemap TXT/MD, README, manifeste, HANDOFF et index/contrats Games/Global rechargés avant patch. Sources D1 et D4 ci-dessus pour les surfaces ; [README Global raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Update 2026-07-30 - Contexte Global Hub léger pour `aggregate_ranking` » et « Update 2026-07-30 - Fallback participants runtime pour Hubs historiques » : identité Hub-locale, projection `stats_*`, exclusion des joueurs sans contribution comptabilisée. Règle exacte de la nouvelle ligne personnelle : décision utilisateur de cette passe, non trouvée dans le contrat raw antérieur.

Global `app_games_hub_player_get_current` / `app_games_hub_player_get_by_identity` lisent déjà `SELECT * FROM games_hubs_players` avec l’identité exacte ; `app_games_hub_player_row_normalize` conserve les champs stats. Games `games_hub_play_general_ranking_for_player` réutilise cette ligne et le `last_result` déjà calculé dans `current_player` et `active_launched_session`. Aucun nouveau resolver de résultat, accès SQL ou média n’est ajouté. Les champs absents, non calculés, dirty/en erreur ou une contribution non nulle ne prouvent pas zéro. Un résultat disponible encore absent du classement est traité prudemment comme « Non classé », jamais zéro ; le résultat personnel `pending` conserve sa préparation. La ligne UI exige aussi une identité active du Hub courant. Elle ne comporte ni score ni photo ; les lignes canoniques, leur ordre et leur rang sont conservés dans `rows`, séparément de `personal_row`.

Games JS `renderGeneralRanking` ajoute uniquement cette ligne de présentation, puis lui préfère toute ligne canonique courante. `renderPersonalState` identifie les attentes génériques sans carte (`aggregate_presentation`, `hub_player_ready`, `last_result_available`) ; `syncPersonalStateVisibility` combine cet état avec la disponibilité du classement, y compris sur les polls identiques et à la sortie du chargement. Le `[hidden]` existant de `.hub-shell--play` applique `display:none !important` : aucun conteneur vide ne conserve son espacement. Le panneau d’erreur/chargement reste indépendant. Aucun changement du resolver PHP de présentation, des cadences ou du routage.

**Vérifications exécutées.** `php web/tests/hub_session_settings_test.php`, `node web/tests/hub_session_settings_dom_test.mjs`, lint du helper et `git diff --check` : OK. Tests nouveaux : zéro prouvé/inconnu/dirty/erreur, résultat pending/disponible, premier classement sans doublon, homonymes d’identités différentes sans photo héritée, autre Hub, classement vide ; DOM attente absente puis retour sans classement, polls identiques, carte présentée, préparation/fin/erreur/chargement conservés. Les tests de lots réels/fallbacks et projections sans lecture média restent verts. `node web/tests/hub_photo_replace_test.mjs` et Global `php web/tests/hub_guest_rejoin_test.php` : OK.

**Limites et livraison.** Recette navigateur réelle des deux ajustements à effectuer, notamment à 360 px et après plusieurs polls ; pas de mesure HTTP/DOM nouvelle. Journal AI Studio raw relu avant patch (dernière entrée 28/08, aucun chemin Hub récent), sources serveur PHP toujours inaccessibles avec les accès disponibles : aucun rechargement/comparaison serveur prétendu, fichiers locaux préservés. Cette passe ne change que le helper Games et ses deux tests PHP/DOM, plus les documents ; le garde Global de réservation déjà validé est conservé. Livraison conjointe des helpers Games/Global requise, aucun déploiement par cet agent. Retour arrière éventuel : retirer uniquement le diff attente/ligne personnelle de cette passe, conserver réservation du pseudo, lots, UX, photo et consolidation. HANDOFF/TASKS mis à jour dans leurs entrées existantes, README et CHANGELOG actualisés, sitemap/index régénérés puis relus.
