# Hub Master — podium complet et scrollbar programme — 22/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-master-podium-scrollbar-20260922" owner="codex" -->

## État et sources consultées avant patch (A–B)

Patch local strictement CSS, non déployé. Aucun SSH, accès DB, DEV/PROD, navigateur intégré ou restart. Dépôts Games/documentation propres avant le premier patch ; révision immersive appliquée sur ce diff local, autres changements conservés. Rapport précédent relu intégralement. START, navigation RAW, manifest et journal AI Studio reconsultés avant cette révision : aucun fichier ciblé signalé hors workspace.

Sources effectivement ouvertes en RAW :
- [START main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), sections « Statut actuel », « Règle preuve d’abord », « Discipline de génération ».
- [SITEMAP.txt develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), Repos/Project status ; [SITEMAP.ndjson develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.ndjson), navigation machine. La réponse web NDJSON était ancienne ; les lectures HTTP directes des pages ciblées ont été utilisées ensuite.
- [SITEMAP.md develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md), How to use / Editing rules ; [README général](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md), Doc discipline et Automatisation des index docs.
- [DOCS_MANIFEST develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), Routing rules R11 et procédure anti-rescan.
- [README Games](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Hub Master mobile canonique — 18/09/2026, patch local non déployé » et « Podium session mobile — 20/09/2026 » ; [TASKS Games](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/TASKS.md), suivi Hub.
- [HANDOFF](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md), actions Master mobile des 18–20/09 et correctifs podium papier du21/09 ; [CHANGELOG](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/CHANGELOG.md), journal des correctifs UI.
- Routage R11 : [README Global](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), [TASKS Global](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/TASKS.md), entrées Hub du22/09 ; [Canvas bridge](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/canvas-bridge.md), contrats Hub. Aucun changement de ces contrats : pages laissées intactes.
- [Journal AI Studio fourni](https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb), EN COURS, TODO, Fait livré en PROD : réponse HTML du lecteur contenant le Markdown intégral dans `const raw`, extrait et recherché en entier. Les variantes `raw=1`/`format=raw` renvoient également cette enveloppe HTML. Aucun chemin `app_hub_view_helpers.php`, `hub_master_mobile.css`, asset podium ni dossier Games ciblé signalé. Changements externes recensés surtout WWW/backoffice/marketing/AI Studio, hors patch ; aucun rechargement ciblé requis. Cela ne certifie pas une parité des serveurs.

Versions minimales des navigateurs supportés et identité du Hub client16 : **non trouvé dans la documentation**. Le code local et les logs archivés sont distingués d’une validation PROD.

## Traces terrain locales

Photo utilisateur `PXL_20260917_201050864.jpg` : titre soirée17/09, rang1 visible à gauche du morceau affiché, rang3 à droite, base du décor coupée, scrollbar programme visible.

Hub candidat fortement recoupé : **185**, session présentée **30455**. `games/logs/error_log-20260918.gz:31008` : le17/09 à22:07:26, agrégat Hub185 chargé avec6 lignes et focus présentation30455. `games/logs/access_log-20260918.gz:84018` et84020 : requêtes22:10:04+0200, référent Master du même Hub, Safari17.4/macOS. La même URL apparaît dans `error_log-20260915.gz:35`, le14/09, avec un lookup session30456/client16. Cette dernière association est indirecte (référent HTTP), pas une lecture de la ligne Hub en DB. Les logs ne contiennent pas le DOM, la résolution ni les styles calculés du projecteur. Archives Global également consultées, sans preuve supplémentaire correspondante. Aucun token, IP ou nom de joueur recopié dans la documentation.

## Audit DOM/CSS et causes (C–H)

Fichier applicatif : `games/web/modules/app_hub_view_helpers.php` (styles embarqués et renderer Master). Lecture complémentaire : `games/web/includes/canvas/css/hub_master_mobile.css`, laissé intact.

DOM réel : `.hub-master-center > .hub-master-hero > .hub-master-feature > section.hub-master-podium--hub > .hub-master-podium-overlay__panel--evening > .hub-evening-podium-scene`. La scène contient un `picture` décoratif et un overlay HTML : titre, bouton Fermer, trois portraits/médailles, statistiques et rotation des ex æquo.

Asset actif : `games/web/includes/canvas/images/hub/podium-evening-3w.webp`, **1664×936, 16:9**, inspecté visuellement complet. Les PNG source/normalisé présents ne sont pas référencés par le renderer. Aucun SVG de podium actif : le SVG couronne appartient au fallback HTML si le WebP manque. Aucun remplacement d’asset nécessaire.

Avant correction :
- centre en grid `auto minmax(0,1fr) clamp(286px,43vh,325px)`, overflow hidden ; hero en grid, `container-type:size` ; feature largeur `min(100%,980px,100cqh*5/2)`, ratio5:2, hauteur auto/max100%, overflow hidden, container-type size ;
- section podium en `position:fixed; inset:0`, padding18px minimum, héritant de deux lignes grid et d’un gap du podium de session ; panneau evening largeur auto, overflow hidden, transform identité ;
- scène : largeur `min(100vw - 44px,1600px,(100vh - 44px)*16/9)`, max1664px, ratio16:9, overflow hidden, container-type size ; image et overlay absolus couvrant100% ; image déjà `object-fit:contain; object-position:center` ;
- portraits en positions relatives à la scène : rang1 x50%, rang2 x25.6911%, rang3 x74.3990%, translations−50% ; aucune taille/position JS du podium ;
- adaptations basse hauteur720px et largeurs860/560px dans le renderer ; CSS mobile `<992px` remplace déjà le décor par une liste verticale scrollable et conserve les données. Ces règles restent intactes.

**Pourquoi le rang2 disparaît-il ?** Le rang2 est en réalité à gauche de la composition2–1–3. Dans les moteurs où les query containers établissent le bloc contenant du fixed, le panneau est contraint au cadre central mais sa scène reste calculée au viewport : son débordement horizontal/vertical est masqué. La portion restante montre le rang1 puis le rang3, comme la photo. Ce n’est ni un rang absent de l’image ni un `cover`. Le traitement de `container-type` a changé entre générations de moteurs : [MDN, signalement43405, Description et résolution CSSWG liée](https://github.com/mdn/content/issues/43405). Le code démontre le mélange de référentiels ; la reconstitution exacte du rendu Safari terrain reste à valider sans son DOM calculé.

Carrousel : `.hub-master-program-footer .hub-program`, flex horizontal, `overflow-x:auto`, `overflow-y:hidden`, `scroll-snap-type:x mandatory` ; cartes sessions et Quick Add non rétrécissables avec snap centré. La sélection par clic, Entrée/Espace et flèches de contrôle appelle `scrollIntoView({inline:'center',block:'nearest'})`. Aucun accès `scrollLeft`, handler wheel ni drag/swipe personnalisé trouvé dans ce contrôleur : gestes/trackpad assurés nativement ; aucune nouvelle prise en charge de molette verticale n’est revendiquée.

**Pourquoi la scrollbar varie-t-elle ?** `scrollbar-width:thin` demande une barre fine et ne la masque pas ; aucune règle `::-webkit-scrollbar` dédiée au programme. Le navigateur/OS choisit sa présence persistante ou temporaire. [MDN scrollbar-width, Values](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/scrollbar-width).

## Révision immersive — audit préalable A–H et correctif retenu

**A–B — Erreur introduite par le premier correctif.** Le bloc desktop liait la feature active au ratio16:9 et à `min(100%,980px,100cqh*16/9)`, puis positionnait la section agrégée dans cette feature avec un panneau100%. Cela supprimait le crop mais transformait la présentation immersive en petite fenêtre centrale. Ce choix est remplacé, pas conservé comme contrat. Le correctif scrollbar reste inchangé.

**C–D — Parent et surface.** Candidats inspectés dans le DOM/CSS réel :

| Candidat | Observation | Décision |
|---|---|---|
| `.hub-master-feature` | Ratio5:2, plafond980px, overflow hidden et query container | Trop petit ; ne porte plus l’overlay |
| `.hub-master-hero` | Ligne centrale flexible, hauteur du programme déjà réservée | Ne couvre pas le footer |
| `.hub-master-center` | Colonne entre les deux panneaux, grid header/hero/footer, overflow hidden | Couvre le programme mais restreint l’immersion à une colonne |
| `.hub-master-screen` | Grid des trois colonnes,100vw×100vh desktop, sous `.hub-main` de mêmes dimensions | **Surface immersive retenue**, stable et indépendante du hero/footer |

À `>=992px`, `.hub-master-screen` reçoit `position:relative`. La section agrégée reste dans son DOM/refresh existant, mais passe en `position:absolute; inset:0` relatif à cet écran. Tant que le podium est visible, ses trois ancêtres intermédiaires centre/hero/feature ont `position:static; container-type:normal; overflow:visible`, via `:has([data-hub-central-hub-podium]:not([hidden]))`. Ils ne peuvent donc ni capturer l’absolute ni rogner la scène dans les anciennes implémentations des query containers. Aucun transform/filter/contain supplémentaire trouvé sur cette chaîne. La scène conserve son propre query container pour les éléments superposés.

Cette neutralisation CSS temporaire suffit : aucun déplacement HTML, aucun portail JS, aucun changement du refresh ni des sélecteurs du contrôleur. Elle disparaît à la fermeture. Le ratio5:2 et les styles ordinaires de la feature restent définis ; le programme conserve ses colonnes, cartes et dimensions. Les cqh de la feature masquée ne sont plus ceux du hero pendant l’ouverture ; ils ne dimensionnent plus le podium, et leur contexte ordinaire revient à la fermeture.

**E — Couches concurrentes.** Aucun nouveau z-index ajouté :

| Couche | Niveau existant / politique retenue |
|---|---|
| Hero, titre Master, podium de session, programme/Quick Add | Sous l’overlay ; médailles session3, contrôles carrousel6 |
| Grand QR / message QR |60/61 ; le contrôleur `hub_player_qr.js` masque le grand QR dès qu’un podium prioritaire visible existe (`!priority`). Cette exclusion existante est conservée, pas une coexistence promise |
| Podium agrégé, backdrop et bouton Fermer |70, conservé ; bouton Fermer dans la scène, focus/Escape/backdrop existants |
| Alerte diagnostic/preflight |82, au-dessus du podium |
| Confirmation SweetAlert |1400, au-dessus du podium |
| Dialogues réglages/Quick Add/diagnostic |`showModal()`, couche native supérieure aux z-index ordinaires |
| Master remplacé / statut de contrôle du poste |Overlay existant2147483647, ajouté au body, au-dessus ; logique Remote inchangée |

Pas d’isolation ajoutée à l’écran qui enfermerait ses couches. Les commandes ordinaires sous le podium redeviennent accessibles à sa fermeture ; les contrôles de fermeture du podium et des alertes restent dans leurs couches respectives. Les mécanismes existants de focus/tabindex et de restitution du focus sont conservés.

**F — Dimensionnement.** La section overlay est un query container `size` dont le content box correspond à l’écran moins le padding existant `max(18px, safe-area)` sur chaque côté. Une seule cellule grid `minmax(0,1fr)`, gap0. Le panneau evening utilise :

`W = min(100cqw,1664px,100cqh*16/9)` ; la scène fait100% de ce panneau, ratio16:9 ; `H = W*9/16`.

Les unités du panneau lisent l’overlay, jamais la feature. `min-width:0`, `max-height:none` avec spécificité supérieure à l’ancienne règle basse hauteur ; pas de crop ajouté pour compenser un dépassement. Décor et overlay HTML gardent leurs dimensions communes et leurs coordonnées en pourcentages.

Plafond1664px : largeur native de l’asset1664×936, acceptable dans le contrat demandé. Ancien renderer limité à1600px et max1664px : aucun upscale au-delà de la résolution native pratiqué par cette règle. Le plafond980px du premier patch est supprimé. La scène peut recouvrir les trois colonnes et toute la hauteur, **programme compris**, sous réserve des marges et du ratio.

**G–H — Interactions et portée du patch.** Hero/podium session/programme restent dans leur DOM et sous la couche agrégée. Pas de déplacement de carte ni de changement du scroll, du focus métier ou des données. Fermeture et resize reposent sur le CSS et le contrôleur existants, sans état de layout ajouté. Sous992px, aucune règle desktop de ce bloc n’est active : présentation mobile verticale/fixed et scroll du panneau conservés.

Programme : `scrollbar-width:none` et `::-webkit-scrollbar { display:none }` **conservés à l’identique**, de même que overflow auto, snap et scrollIntoView.

Fichier applicatif unique : `games/web/modules/app_hub_view_helpers.php`, CSS embarqué seulement. Aucun HTML/JS, asset, rang, sélection, score, résultat, ex æquo, moteur, WS, API, Play, Remote ou Quick Add métier modifié.

**Contrat corrigé : Le podium agrégé du Hub Master est une couche de présentation immersive. Sur desktop, il peut recouvrir le visuel principal, le podium de session et le carrousel programme afin d’utiliser au maximum l’espace disponible. Sa composition16:9 reste intégralement visible et n’est jamais rognée.** Plafond limité à la résolution native, présentation verticale mobile conservée. **Le carrousel programme reste scrollable horizontalement mais sa scrollbar native est masquée sur les navigateurs supportés.** Certification visuelle sur matériel réel encore à faire.

## Vérifications exécutées et résultats

Depuis Games :
```sh
php -l web/modules/app_hub_view_helpers.php
node web/tests/hub_mobile_ui_test.mjs
node web/tests/hub_mobile_session_podium_test.mjs
node web/tests/paper_podium_render_test.mjs
php web/tests/paper_podium_hub_test.php
php web/tests/hub_compact_aggregate_test.php
node web/tests/hub_player_qr_test.mjs
git diff --check
```

Relancés après révision : syntaxe, UI mobile,5 cas DOM de podium mobile/resize (dont991→992→991), vrai renderer podium papier,12 contrôles présentation/25 projections, agrégat compact et priorité grand QR : **OK**. Les fixtures couvrent données dynamiques, sélection, agrégats/ex æquo ; elles ne mesurent pas les boîtes CSS.

Suite `php web/tests/hub_session_settings_test.php`, exécutée au premier patch : **échec préexistant**, `Auto overlay masks the selected finished session and permits canonical final state`. Même assertion reproduite avec le helper de HEAD avant patch dans une copie temporaire, chemins de dépendances préservés. Aucun changement métier effectué pour la faire passer.

Contrôle de révision : comparaison du fichier avant/après en retirant son bloc `<style id="hub-master-inline-style">` : **identique**, donc aucun changement HTML/JS. Le premier essai du contrôle cherchait `<style>` sans attribut et a échoué à isoler le CSS ; extraction corrigée, contrôle réussi. Aucun échec applicatif associé.

Géométrie **conceptuelle, sans moteur de layout**, basée sur les coordonnées des portraits/médailles lues dans le CSS, marges18px et safe-area0 :

| Cas | Écran | Scène calculée | Résultat arithmétique |
|---|---|---|---|
| G1 |1920×1080|1664×936|Image,3 rangs/médailles, bouton Fermer dans les limites |
| G2 |1366×768|1301,33×732|Idem |
| G3 projecteur |1440×900|1404×789,75|Idem ; proportions choisies, viewport terrain exact inconnu |
| G4 faible hauteur |1920×540|896×504|Réduction par hauteur, aucun crop géométrique |
| G5 trois colonnes |992×768|956×537,75|Surface écran, pas colonne centrale |
| G9 resize |2560×1440→1024×600→2560×1440|1664×936→988×555,75→1664×936|Retour aux dimensions initiales, aucune position persistée |

G6/G7 : contrôle de structure CSS, cadre écran couvrant le footer et niveau70 supérieur aux couches session/programme ; DOM/JS inchangés et tests de présentation passants. G8 : les exceptions aux styles des ancêtres sont conditionnées au podium visible, retour au layout normal à la fermeture ; test de fermeture/sélection existant passant, aucun changement à scrollIntoView. À991px le bloc desktop est inactif, à992px actif. Les tests DOM couvrent également cette frontière. Ces preuves ne certifient **ni le rendu pixel, ni le wrapping des noms, ni le scroll réel, ni le stacking calculé du navigateur**. Script de calcul temporaire : `/tmp/hub-ui-revision/geometry.py` (hors versionnement).

Depuis documentation : `npm run docs:sitemap`, puis `git diff --check`. INDEX/sitemaps régénérés par le mécanisme prévu, jamais édités à la main.

## Recette restante et rollback

Recette courte à exécuter sur Chrome desktop, Safari du projecteur et Firefox :
1. Ouvrir le podium agrégé en16:9 classique, puis faible hauteur : grande composition complète2–1–3, décor/portraits alignés, Fermer accessible.
2. L’ouvrir avec un podium de session déjà présent et le carrousel visible : overlay devant, programme structurellement intact dessous ; fermeture puis retour des interactions, du scroll antérieur et des dimensions normales.
3. Redimensionner grand→petit→grand, puis991→992→991 : aucun crop/scroll global ajouté, liste mobile conservée.
4. Vérifier noms longs/photos/ex æquo, Escape, fermeture par bouton/backdrop et restitution du focus.
5. Grand QR ouvert puis podium : QR réduit par la priorité existante ; vérifier ensuite sa réouverture selon l’état autorisé. Diagnostic/confirmation/dialogues et signal Master remplacé au-dessus lorsqu’ils sont possibles.
6. Après fermeture, vérifier scrollbar invisible même avec le réglage OS « toujours afficher », snap/trackpad/clavier/tactile et Quick Add accessible.

**Aucune validation visuelle sur navigateur/DEV/PROD n’a été exécutée.** Aucun déploiement, SSH, DB ou restart. Les noms/statistiques sur scènes très basses et les marges safe-area réelles restent à contrôler sur les appareils. Versions minimales des navigateurs : non trouvé dans la documentation.

Rollback de cette révision : restauration du bloc CSS sauvegardé dans `/tmp/hub-ui-revision/before.php` uniquement, sans écraser le reste du fichier ; cela réintroduirait le petit podium central, donc ce n’est pas le contrat cible. Conserver dans tous les cas le masquage scrollbar. Mettre à jour les entrées documentaires et régénérer les index. Aucune donnée/migration ni service à restaurer.

<!-- AUTO-UPDATE:END id="hub-master-podium-scrollbar-20260922" -->
