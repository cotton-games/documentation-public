> **Maintenance pact**
> - Codex: keep this runbook operational and evidence-based.
> - Direct DB imports must be validated editorially before execution.

# Import direct de contenus Cotton certifies

## Objectif

Cette note decrit le process de creation editoriale puis d'import direct ou semi-assiste de contenus **Cotton certifies** :

- playlists Blind Test / Bingo Musical ;
- series Cotton Quiz.

Pour Cotton Quiz, cette page sert aussi de contrat de preparation d'un fichier Markdown `.md` compatible avec l'import PRO Quiz `/extranet/games/import/quiz`.

## Principe general

Le contenu est d'abord concu et valide editorialement, puis importe par le flux adapte :

- pour les imports directs historiques : SQL transactionnel controle ;
- pour Quiz PRO V1 : fichier Markdown unique importe depuis `/extranet/games/import/quiz`.

Le process se deroule en 5 etapes :

1. Definir le theme et les contraintes editoriales.
2. Produire une premiere version editoriale complete dans l'UI de l'agent IA, avec questions, reponses, explications et supports previsualisables lorsque l'interface le permet.
3. Faire valider le contenu par Cotton ou par l'utilisateur.
4. Generer le fichier `.md` d'importation conforme au format PRO Quiz.
5. Importer via l'outil ou le script controle.

Aucun import ne doit etre execute sans validation editoriale prealable.

Aucun fichier `.md` d'importation ne doit etre presente comme final tant que la previsualisation editoriale n'a pas ete validee explicitement.

## Sources de verite

Pour les imports directs, la priorite des sources est la suivante :

1. Base live / exports reels.
2. Code applicatif courant.
3. Documentation schema `documentation/canon/data/schema/DDL.sql`.

Le fichier `DDL.sql` reste utile pour les tables historiques, mais il peut etre en retard sur certaines evolutions recentes. Exemple connu : `community_items` peut ne pas etre present dans le DDL local, alors que la table est creee ou attendue cote code bibliotheque.

## Convention Cotton certifie

Pour maximiser la compatibilite avec les flux legacy et modernes, un contenu Cotton certifie importe directement doit respecter les conventions suivantes.

### Convention legacy

Les contenus Cotton historiques sont identifies par :

```sql
id_client_auteur = 0
```

Cette convention doit etre conservee pour les imports directs. Elle reste la convention fiable pour que les contenus soient reconnus comme Cotton certifies dans les flux legacy.

### Convention moderne optionnelle

Lorsque la table `community_items` existe et que le flux moderne l'exploite, une entree peut etre ajoutee avec :

```sql
origin = 'cotton'
status = 'published'
source_type = 'catalogue'
```

Cette entree est une compatibilite moderne complementaire. Des contenus Cotton certifies existants peuvent ne pas avoir d'entree `community_items`; l'absence de cette entree ne doit donc pas empecher un contenu legacy `id_client_auteur=0` d'etre considere comme Cotton certifie.

## Playlists Blind Test / Bingo Musical

### Tables concernees

- `jeux_bingo_musical_playlists`
- `jeux_bingo_musical_artistes`
- `jeux_bingo_musical_morceaux`
- `jeux_bingo_musical_morceaux_to_playlists`
- `community_items`, si utilise par le flux moderne

### Regles minimales

Une playlist Cotton certifiee doit etre creee avec :

```sql
id_client_auteur = 0
nom_auteur = ''
online = 1
flag_validated = 1
```

Le champ `flag_share_community` peut rester aligne avec les contenus Cotton existants. Un exemple live de playlist Cotton certifiee utilise :

```sql
flag_share_community = 1
```

### Contenu attendu

Une playlist certifiee doit contenir :

- 40 morceaux ;
- un ordre de lecture via `position` ;
- un artiste renseigne pour chaque morceau ;
- un titre renseigne pour chaque morceau ;
- une URL YouTube ou media exploitable lorsque necessaire ;
- aucune entree manifestement douteuse ou inexploitable.

### Usage transverse Blind Test / Bingo Musical

Les playlists musicales certifiees Cotton doivent etre pensees comme des contenus musicaux transverses. Une meme playlist peut servir de base a un Blind Test, a un Bingo Musical, ou aux deux.

La documentation et les imports doivent donc eviter de presenter ces playlists comme exclusivement rattachees a l'un ou l'autre jeu, sauf contrainte technique ou editoriale explicitement documentee avec preuve code ou DB.

## Series Cotton Quiz

### Tables concernees

- `questions_lots`
- `questions`
- `questions_propositions`
- `community_items`, si utilise par le flux moderne

### Regles minimales

Une serie Cotton certifiee doit etre creee avec :

```sql
id_client_auteur = 0
nom_auteur = ''
id_etat = 2
flag_validated = 1
```

Le champ `flag_share_community` n'est pas le critere principal pour un contenu Cotton legacy. Un exemple live de serie Cotton certifiee utilise :

```sql
flag_share_community = 0
```

### Role de cette page pour l'import PRO Quiz

Cette page a deux usages distincts et complementaires :

1. cadrer la creation de contenus Cotton Quiz certifies ;
2. fournir a un agent IA une procedure suffisamment precise pour generer un fichier Markdown `.md` compatible avec l'import PRO Quiz `/extranet/games/import/quiz`.

Cette page doit permettre a un agent IA de produire un fichier Markdown d'import PRO Quiz aussi complet que possible, sans laisser a l'utilisateur des choix qui peuvent etre deduits de la serie. L'utilisateur doit idealement n'avoir qu'a relire, corriger et valider.

L'agent IA doit :

- pre-remplir tous les champs qu'il peut deduire ;
- ne pas laisser `Rubrique : A choisir...` si le referentiel permet de choisir ;
- proposer une illustration generale ;
- proposer les supports des questions ;
- signaler uniquement les vrais points de blocage.

### Regles editoriales Cotton Quiz certifie

Ces regles decrivent le modele editorial Cotton. Elles sont distinctes des contraintes techniques du `.md` import PRO Quiz V1.

#### Taille canonique

- Une serie Cotton Quiz certifiee contient exactement 6 questions.
- Ce format est le standard certifie Cotton.
- Une serie de plus ou moins 6 questions necessite une validation specifique et ne doit pas etre generee par defaut.

#### Perennite

Les series certifiees doivent etre reutilisables dans le temps. Un evenement peut servir de pretexte editorial, mais le titre, l'angle et les questions ne doivent pas dependre d'une actualite trop datee.

Exemple non acceptable :

```text
Pays hotes 2026 - USA, Canada, Mexique
```

Exemples acceptables :

- `Histoire de la Coupe du monde`
- `Culture foot`
- `Legendes du football`
- `Ambiance stade`

#### Garde-fou sur les formulations temporaires

Une question Cotton certifiee ne doit pas etre formulee avec un repere temporel qui la rendra invalide, ambigue ou datee apres un evenement deja programme.

A eviter :

- `Depuis 1998, combien d'equipes participent a la phase finale de la Coupe du monde masculine ?`
- `Depuis l'edition 1998, combien d'equipes participaient a la phase finale de la Coupe du monde masculine avant l'extension prevue a 48 equipes ?`

Meme si ces formulations peuvent etre exactes avant l'edition 2026, elles deviennent fragiles ou datees apres cette edition. Un contenu certifie doit rester jouable plusieurs annees sans reecriture.

Formulation acceptable si le changement est explicitement date et integre a un repere historique clair :

```text
Depuis l'edition 1998, combien d'equipes participaient a la phase finale de la Coupe du monde masculine avant l'extension a 48 equipes de 2026 ?
```

Formulation preferee, car historiquement bornee :

```text
De 1998 a 2022, combien d'equipes participaient a la phase finale de la Coupe du monde masculine ?
```

Ou formulation portant sur une edition precise :

```text
Combien d'equipes participaient a la phase finale de la Coupe du monde masculine 1998 ?
```

Regle pratique :

- eviter `depuis`, `actuellement`, `aujourd'hui`, `avant la prochaine edition`, `a partir de l'an prochain`, sauf si la question est explicitement bornee par des dates, editions ou periodes historiques ;
- preferer `de [annee] a [annee]`, `lors de l'edition [annee]`, `jusqu'a l'edition [annee] incluse`, ou une formulation historique stable ;
- lorsqu'un changement futur est deja connu, ne pas construire la question autour d'un futur flou ;
- une formulation avec `avant` peut etre acceptee si le changement est date explicitement et que la periode visee reste claire apres l'evenement ;
- pour un contenu certifie durable, privilegier malgre tout les bornes historiques fermees.

#### Niveau et progression

- Le niveau global doit etre coherent.
- Lorsque le theme le permet, faire progresser legerement la difficulte au fil de la serie.
- Commencer par des questions tres accessibles.
- Terminer idealement par la question la plus interessante, la plus originale ou la plus difficile, tout en respectant le niveau global.
- Une serie `Facile` peut finir par une question un peu plus exigeante, mais toujours accessible au public vise.

#### Difficulte par les distracteurs

La difficulte d'une question ne depend pas seulement de son enonce, mais aussi des mauvaises reponses proposees.

- Les distracteurs peuvent niveler la difficulte.
- Pour une question facile, les mauvaises reponses peuvent etre assez evidentes.
- Pour une derniere question ou une question un peu plus difficile, utiliser des fausses pistes plus plausibles.
- Garder des propositions courtes pour le mobile.
- Ne jamais utiliser une fausse reponse qui pourrait etre consideree correcte dans un autre contexte.
- Eviter les distracteurs absurdes si l'objectif est d'augmenter legerement la difficulte.

La difficulte peut aussi etre ajustee par les mauvaises reponses. Des distracteurs plausibles permettent de rendre une question finale plus interessante sans allonger les propositions ni degrader l'affichage mobile.

#### Contextualisation des questions

Eviter le style `quiz rapide` trop sec. Chaque question doit donner un minimum de contexte.

Exemple faible :

```text
Dans quel pays a eu lieu la premiere Coupe du monde de football ?
```

Exemple recommande :

```text
Dans quel pays a eu lieu la premiere Coupe du monde de football, jouee en 1930 ?
```

#### Mauvaises reponses non contestables

Les fausses propositions doivent etre plausibles, mais ne doivent pas preter a reclamation.

A verifier systematiquement :

- surnoms, termes partages, formulations ambigues ;
- records, dates, pays, clubs, personnes ;
- bonne reponse incontestable avec le contexte donne.

Exemple : `Selecao` seul est ambigu car le terme peut etre associe a plusieurs selections lusophones. Contextualiser avec `Selecao Canarinho`.

#### Lisibilite mobile des propositions

- Les propositions doivent etre courtes et lisibles sur mobile.
- Eviter les reponses en phrases completes.
- Eviter les propositions trop longues ou desequilibrees.
- Garder des reponses compactes.
- Ne pas appauvrir la question : si des reponses courtes rendent la question trop facile, deplacer la complexite dans le contexte, l'angle historique ou les mauvaises reponses.

Exemple recommande :

```md
Question : Avant l'arrivee des tirs au but en Coupe du monde masculine en 1982, comment certains matchs a elimination directe pouvaient-ils etre departages s'ils restaient a egalite apres prolongation ?

Propositions :
A. Match rejoue
B. Classement FIFA
C. But en or
D. Corners obtenus

Bonne reponse : Match rejoue
```

Interet :

- propositions courtes ;
- bonne lisibilite mobile ;
- vraie dimension historique ;
- difficulte finale plus interessante sans sortir du niveau global facile ;
- distracteurs plausibles mais non equivalents.

#### Explication / commentaire animateur

Chaque question certifiee doit prevoir une explication courte.

L'explication doit :

- apporter une precision factuelle utile ;
- lever les ambiguites eventuelles ;
- aider l'animateur a commenter la reponse ;
- etre particulierement importante lorsque la question repose sur une nuance historique, reglementaire ou culturelle ;
- rester concise et exploitable en animation.

Exemple recommande :

```md
Explication : Avant l'usage des tirs au but en Coupe du monde masculine, certains matchs a elimination directe pouvaient etre rejoues lorsqu'ils restaient indecis apres prolongation. Selon les reglements et les editions, d'autres solutions exceptionnelles ont aussi existe, comme le tirage au sort, ce qui explique l'importance de parler ici de "certains matchs".
```

### Mapping technique de `Explication`

Verification code locale, importeur PRO Quiz `/extranet/games/import/quiz` :

- `pro/web/ec/modules/jeux/import/ec_import_quiz.php` parse les cles Markdown `Explication`, `Commentaire` ou `Explanation` dans la valeur interne `explanation`.
- Lors de l'import definitif, cette valeur est inseree dans le champ DB `questions.commentaire`.
- Le meme fichier insere la bonne reponse dans `questions.reponse` et les mauvaises propositions dans `questions_propositions`.
- Le helper `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php::app_cotton_quiz_client_questions_lot_get_liste()` lit `SELECT * FROM questions`, donc `commentaire` est relu avec la question.
- Les ecrans PRO d'edition de series utilisent ce champ sous le libelle `Commentaire` ou `Commentaire pour le Quiz Master`.
- Le front animateur Canvas mappe `raw.commentaire` vers `commentaire` dans `games/web/includes/canvas/core/boot_organizer.js`.

Non trouve dans le code local audite : affichage explicite de ce `commentaire` aux joueurs.

Non trouve dans le code local audite : affichage certain du `commentaire` dans l'interface animateur Canvas au moment de la correction. Le champ est bien transmis au modele front, mais l'affichage runtime n'a pas ete identifie dans cette verification.

### Supports multimedia et illustrations

#### Supports par question

- Chaque question peut avoir un support multimedia si pertinent.
- Une serie certifiee doit viser un support sur chaque question lorsque le theme s'y prete.
- Minimum attendu : au moins 3 questions avec support.
- Les supports ne doivent pas etre ajoutes seulement pour remplir une contrainte : ils doivent apporter du contexte, de l'ambiance ou une meilleure experience de jeu.

#### Ne pas se limiter aux images dans le modele editorial

Les supports editoriaux peuvent etre :

- image ;
- audio ;
- video ;
- extrait YouTube avec start/end ;
- autre media compatible avec les capacites produit.

Si un support audio ou video est pertinent, l'agent doit le proposer dans la fiche editoriale. Ne pas ecarter audio/video au seul motif que l'import PRO V1 peut etre limite.

#### Question finale

Lorsque le theme s'y prete, finir une serie par une question avec support audio ou video est particulierement pertinent : final plus vivant, effet animation, montee en intensite. Ce n'est pas obligatoire si aucun support pertinent n'existe, mais l'agent doit l'envisager.

#### Supports non revelateurs

Les supports sont affiches ou joues en meme temps que la question. Dans le flux import PRO Quiz documente ici, l'agent ne doit donc pas proposer un support a lancer avant la question, apres la question ou seulement apres validation de la reponse : ce comportement n'est pas disponible dans ce format.

Puisque le support est visible ou audible pendant la question, il ne doit jamais reveler la bonne reponse.

Eviter :

- titre revelateur ;
- miniature revelatrice ;
- legende, incrustation, watermark, panneau, sous-titre ou mention visible qui revele la reponse ;
- nom de fichier revelateur s'il est affiche ;
- drapeau, maillot, logo ou personne identifiable si c'est la reponse ;
- audio/video qui cite la reponse avant que le joueur reponde.

Pour les images, l'agent IA doit choisir une image sans texte, legende, cartel, credit visible, titre incruste ou element graphique qui donne la reponse. Il ne suffit pas de signaler le risque : si l'image contient une mention revelatrice, elle doit etre remplacee par une image non revelatrice ou le support doit etre marque `rejete car revelateur`.

Si un support est interessant mais revelateur, ne pas l'associer a la question. Exception seulement si un mecanisme produit documente permet explicitement un affichage apres reponse ; non trouve dans le flux import PRO Quiz documente ici.

#### Qualite visuelle et narrative des supports

Un support ne doit pas seulement etre techniquement valide et non revelateur. Il doit apporter une vraie valeur d'animation.

Eviter les visuels fades, trop generiques, peu lisibles ou sans ambiance. Privilegier une image claire, un cadrage fort, une tension narrative, un contexte utile et un media lisible sur mobile et ecran d'animation.

#### Illustration generale de la serie

L'illustration generale doit porter clairement le theme. Elle doit etre plus specifique qu'une image generique de categorie, durable, attractive et compatible avec un usage catalogue.

Pour une serie Coupe du monde, eviter un simple ballon sur une pelouse ; preferer une ambiance de stade, competition internationale, foule, trophee ou symbole fort non revelateur.

Pour l'illustration generale, privilegier une image libre de droits sans condition particuliere, reutilisable commercialement, par exemple via Unsplash. L'image doit etre au format paysage, attractive en catalogue et suffisamment large pour supporter les recadrages applicatifs. L'URL d'import de cette illustration doit etre une URL image directe, convertie si necessaire vers une forme portant une extension image claire, par exemple `.jpg`, `.jpeg` ou `.png`, afin de rendre le telechargement et la validation par l'importeur non ambigus.

Pour les supports image de question, la contrainte de droits est beaucoup moins forte que pour l'illustration generale, car ces images sont affichees en contexte de session privee et servent d'aide d'animation ponctuelle. L'agent IA doit donc privilegier la pertinence editoriale, la stabilite d'affichage, l'upload possible par l'importeur et l'absence de revelation. Il peut proposer des images trouvees via Google ou via une source web si l'URL finale placee dans le `.md` n'est pas une URL Google, mais une URL directe stable ou une URL source exploitable par l'importeur.

### Previsualisation editoriale obligatoire avant generation du `.md`

Avant de produire le fichier Markdown `.md` compatible avec l'import PRO Quiz, l'agent IA doit produire une premiere version editoriale de la serie pour validation par Cotton ou par l'utilisateur.

Cette premiere version ne doit pas etre presentee comme un fichier d'import. Elle doit etre affichee simplement dans l'UI de l'agent IA, dans un format lisible et facile a commenter.

La previsualisation doit contenir :

- les metadonnees editoriales proposees : titre, slug pressenti, niveau, rubrique, categorie, sous-categorie, public et description courte ;
- les 6 questions de la serie ;
- pour chaque question : l'enonce, les 4 propositions, la bonne reponse, l'explication destinee au commentaire animateur, une note editoriale si utile et le ou les supports candidats ;
- une synthese des supports proposes pour la serie.

Les supports doivent etre affiches de facon directement lisible par l'utilisateur dans l'UI de l'agent IA :

- pour une image : lien source et apercu visuel assez large lorsque l'interface le permet ;
- pour un audio : lien source et lecteur, apercu ou extrait cliquable lorsque l'interface le permet ;
- pour une video : lien source et miniature, integration ou extrait cliquable lorsque l'interface le permet ;
- pour un extrait YouTube : lien source avec `start` / `end` si pertinent et apercu cliquable lorsque l'interface le permet.

Cette previsualisation peut aider a valider les medias, mais elle ne change pas le comportement de l'import : un support retenu pour le `.md` sera joue ou affiche pendant la question.

#### Definition d'une previsualisation validable

Une previsualisation editoriale n'est validable que si l'utilisateur peut verifier concretement chaque media propose avant generation du `.md`.

Pour chaque illustration generale et chaque support de question, l'agent IA doit fournir un bloc de validation media contenant :

- le type de support ;
- l'URL source ou page d'origine, si differente de l'URL technique ;
- l'URL technique destinee au `.md` ;
- une previsualisation directement visible ou cliquable dans l'UI de l'agent ;
- une note sur la raison du choix editorial ;
- une verification du risque de revelation ;
- une verification de compatibilite technique avec l'import ;
- un statut clair : `retenu pour le .md`, `a remplacer`, `rejete car revelateur`, `bloquant`.

Un media ne peut pas etre marque `retenu pour le .md` si l'utilisateur ne peut pas le voir, l'ouvrir, l'ecouter ou le tester facilement depuis la previsualisation.

Si l'interface de l'agent IA n'affiche pas correctement un media, l'agent doit fournir au minimum :

- un lien direct ouvrable ;
- une miniature ou image alternative si disponible ;
- une phrase explicite indiquant que l'apercu inline n'a pas pu etre verifie ;
- une recommandation de remplacement si la validation visuelle reste incertaine.

Si l'utilisateur signale qu'une image, une miniature, un audio ou une video ne s'affiche pas, l'agent doit considerer le support comme non valide pour le `.md` jusqu'a remplacement ou validation explicite.

Pour chaque support candidat, l'agent doit indiquer :

- le type de support pressenti : `image`, `audio`, `video`, `youtube`, `youtube_audio`, `youtube_video`, ou autre valeur uniquement si elle est explicitement supportee par l'importeur ;
- l'URL ;
- les eventuels parametres de debut et de fin : `start`, `end` ;
- le role editorial du support ;
- s'il est destine a l'illustration generale ou a une question ;
- le risque de revelation de la reponse ;
- le statut de validation : `a valider`, `acceptable sous reserve`, `rejete car revelateur`, `retenu pour le .md` ;
- les contraintes techniques connues pour l'import.

#### Format obligatoire d'un bloc media en previsualisation

Pour faciliter la validation par l'utilisateur, chaque media doit etre presente avec le meme format.

Exemple image :

```text
Media Q2
Type : image
Statut : retenu pour le .md
URL source : https://...
URL preview : https://...
URL import : https://...
Apercu : image affichee en grand dans l'UI agent, ou balise HTML <img> si necessaire
Role editorial : ...
Verification non-revelation : ...
Verification technique : image directe HTTP(S), format compatible, ouverture testee
Point a valider par l'utilisateur : ...
```

Exemple YouTube :

```text
Media Q6
Type : youtube_video
Statut : retenu pour le .md
URL source : https://www.youtube.com/watch?v=...
URL preview : https://img.youtube.com/vi/.../hqdefault.jpg
URL import : https://www.youtube.com/watch?v=...
Support start : 12
Support end : 28
Apercu : miniature cliquable + lien de test
Role editorial : ...
Verification non-revelation : titre, miniature et extrait controles
Verification technique : URL YouTube compatible avec l'importeur et lecture embed testee sans blocage
Point a valider par l'utilisateur : confirmer que l'extrait ne revele pas la reponse dans Cotton et reste lisible en embed
```

L'agent ne doit pas melanger dans une meme ligne le lien source, le lien de preview et le lien d'import lorsque ces URLs different.

L'agent IA ne doit produire le `.md` d'importation qu'apres validation explicite de cette previsualisation editoriale.

Phrase type a placer en fin de previsualisation :

```text
Cette proposition est une version editoriale a valider. Je ne produis pas encore le fichier .md d'importation. Apres validation ou corrections, je pourrai generer le .md conforme au format PRO Quiz.
```

### Validation et remplacement des supports dans l'importeur PRO

La gestion des supports multimedia est le point le plus sensible du dispositif. La page PRO Quiz `/extranet/games/import/quiz` sert desormais d'abord de preview technique simplifiee : elle parse le Markdown et affiche les champs qui seront importes. Si la preview ne contient pas d'erreur bloquante, un CTA explicite permet ensuite d'importer la serie en DB.

Cette preview PRO ne remplace pas la previsualisation editoriale dans l'UI de l'agent IA. Elle sert a relire le resultat structure du `.md` avant toute procedure d'import ou de reprise technique separee.

La preview de `/extranet/games/import/quiz` doit afficher pour chaque question :

- l'enonce ;
- les propositions ;
- la bonne reponse ;
- l'explication ;
- le `Support type` ;
- l'URL finale de support calculee pour l'import, avec `Support start` et `Support end` si applicables ;
- la `Note support`.

Elle doit aussi afficher les metadonnees de serie : titre, slug, description, niveau, rubrique, categorie, sous-categorie, public, format et illustration.

La preview peut remonter des avertissements ou erreurs de structure. Tant que ces erreurs existent, le CTA d'import DB ne doit pas etre propose.

L'import DB porte uniquement les champs detectes et valides : serie, questions, propositions, bonne reponse, explication et liens supports. Cette page simplifiee ne telecharge pas les supports de questions et ne remplace pas la validation editoriale des URLs. Exception volontaire : l'illustration generale de la serie est telechargee et ecrite en `.jpg` dans le stockage applicatif attendu par la bibliotheque PRO, afin que la thematique affiche son visuel apres import.

Historique : une version anterieure de cette page permettait de remplacer les supports dans la preview avant import. Ce comportement d'edition dans l'importeur PHP n'est plus le comportement cible de la page simplifiee.

#### Ancien comportement remplace

Dans l'ancienne preview de `/extranet/games/import/quiz`, l'utilisateur pouvait corriger pour chaque question :

- le `Support type` ;
- l'URL `Support` ;
- `Support start` ;
- `Support end` ;
- `Note support`.

Ce workflow d'edition dans l'importeur PHP est retire pour simplifier la page. Les corrections doivent etre faites dans le Markdown source ou dans la previsualisation editoriale de l'agent IA avant de relancer la preview technique.

Regle d'usage :

- l'agent IA propose les meilleurs supports possibles dans le `.md` ;
- l'utilisateur valide les medias en conversation avant generation du `.md` ;
- si la preview PHP revele un support douteux, revelateur, non affichable ou incompatible, l'utilisateur corrige le Markdown source puis relance la preview ;
- l'import DB ne doit etre declenche depuis cette page que si la preview est valide et confirmee explicitement.

### Format Markdown pour import PRO

Pour un import via l'outil PRO `/extranet/games/import/quiz`, un agent IA doit produire **un fichier Markdown unique**. Il ne doit pas produire de SQL pour ce flux.

Le fichier doit contenir les metadonnees avant la premiere question, puis une section par question. Il ne doit pas contenir de frontmatter YAML.

Champs de metadonnees reconnus :

```md
# Titre de la serie
Titre : Titre de la serie
Slug : slug-seo-stable
Description : Description courte de la serie.
Niveau : Facile
Rubrique : Sport
Categorie : Sport
Sous-categorie : Football
Illustration : https://exemple.test/illustration-directe.jpg
Type : Cotton Quiz
Public : Grand public / CHR / soirees quiz
Format : QCM 4 reponses
```

Regles metadonnees :

- pas de frontmatter YAML ;
- un seul titre `#` en tete du document ;
- les metadonnees doivent etre placees avant la premiere question ;
- `Titre` est obligatoire. Un `# H1` peut aussi servir de titre si `Titre :` est absent ;
- `Slug` est obligatoire pour eviter toute generation ambigue. Il doit utiliser uniquement minuscules, chiffres et tirets ;
- `Description` est obligatoire pour une serie certifiee ;
- `Niveau` doit etre `Facile`, `Moyen` ou `Difficile`. Sans valeur reconnue, l'importeur retombe sur `Facile` ;
- `Rubrique` doit reprendre exactement une valeur du referentiel canon liste ci-dessous ;
- `Categorie` et `Sous-categorie` peuvent rester dans le Markdown comme contexte editorial, mais ne remplacent pas la `Rubrique` exacte ;
- `Rubrique : A choisir dans la preview PRO` n'est plus importable automatiquement ;
- `Illustration` vaut une URL image directe ou `aucun`, mais l'agent doit proposer une illustration plutot que `aucun` sauf vrai blocage ;
- `Type`, `Public` et `Format` sont utiles pour la relecture editoriale ; l'importeur Quiz V1 ne les ecrit pas directement en DB.

### Referentiel des rubriques Quiz

- La source de verite des rubriques disponibles est la liste PRO d'ajout manuel d'une serie Quiz.
- Pour qu'un import DB puisse etre lance sans choix manuel dans l'importeur, l'agent IA doit renseigner `Rubrique` avec l'une des valeurs exactes ci-dessous.
- Ne pas ecrire le libelle compose affiche dans certains ecrans (`Culture G - Sport`, `Cinema - Affiches & images`, etc.) dans le champ `Rubrique` : le champ attend uniquement la valeur de rubrique.
- Techniquement, cette liste correspond aux lignes actives de `questions_lots_rubriques`.
- Cote code, cette meme liste est exposee par `clib_rubriques_get('cotton-quiz')` via `questions_lots_rubriques`.
- Le fichier `.md` doit contenir le libelle exact dans `Rubrique : ...`, pas l'ID numerique.
- Si l'agent IA n'a pas acces a ce referentiel au moment de produire le `.md`, il doit refuser de produire un fichier pret a importer plutot que deviner une valeur.
- Lors de la preview, l'importeur PRO resout automatiquement la rubrique si le libelle exact du `.md` correspond a une ligne active.
- Si `Rubrique` est absente, vaut `A choisir dans la preview PRO`, ou ne correspond a aucune ligne active, l'importeur bloque avant import DB.
- `Categorie` et `Sous-categorie` ne sont que des informations editoriales de contexte et ne doivent pas etre utilisees comme referentiel DB.
- L'agent ne doit jamais inventer une rubrique plus precise comme `Football` si elle n'est pas listee.
- `Football` peut apparaitre en `Sous-categorie`, mais pas en `Rubrique` sauf s'il est present dans le referentiel.
- Pour une serie football / Coupe du monde, utiliser `Rubrique : Sport`.

Rubriques utilisables dans le `.md` :

| Univers PRO | Valeur exacte a ecrire dans `Rubrique` | Libelle ecran historique |
| --- | --- | --- |
| Culture G | `Sport` | Culture G - Sport |
| Culture G | `Géographie` | Culture G - Géographie |
| Culture G | `Pays & villes` | Culture G - Pays & villes |
| Culture G | `Arts & loisirs` | Culture G - Arts & loisirs |
| Culture G | `Evénements` | Culture G - Evénements |
| Culture G | `Personnalités` | Culture G - Personnalités |
| Culture G | `Divers` | Culture G - Divers |
| Cinéma | `Affiches & images` | Cinéma - Affiches & images |
| Cinéma | `Répliques & extraits` | Cinéma - Répliques & extraits |
| Cinéma | `Acteurs & Personnages` | Cinéma - Acteurs & Personnages |
| Musique | `Artistes & morceaux` | Musique - Artistes & morceaux |
| Musique | `Reprises` | Musique - Reprises |

Exemple correct :

```md
Rubrique : Sport
Categorie : Sport
Sous-categorie : Football
```

Exemple incorrect :

```md
Rubrique : Football
```

`Football` n'est pas une rubrique valide si elle n'est pas dans le referentiel ; c'est une sous-categorie editoriale.

#### URLs source, preview et import

L'agent IA doit distinguer trois notions :

- `URL source` : page d'origine permettant de verifier le contexte, la provenance, les droits ou la pertinence du media ;
- `URL preview` : URL utilisee dans l'UI de l'agent pour afficher une image, une miniature, un lecteur ou un lien cliquable ;
- `URL import` : URL finale placee dans le fichier `.md`.

L'URL placee dans le `.md` doit etre compatible avec l'importeur.

Pour l'illustration generale :

- l'URL import doit etre une URL image directe HTTP(S), en JPEG ou PNG ;
- l'URL import doit porter une extension image claire, par exemple `.jpg`, `.jpeg` ou `.png` ;
- si la source est Unsplash, l'agent doit fournir une URL directe convertie pour l'import avec une extension claire, pas seulement une page photo ou une URL sans extension lisible ;
- elle ne doit pas etre une page HTML ;
- elle ne doit pas etre une URL de resultat Google, de redirection Google Images ou de page intermediaire ;
- elle doit etre librement reutilisable pour un usage commercial Cotton.

Pour les supports de question de type `image` :

- l'URL import doit etre une URL image directe HTTP(S) ;
- l'agent doit verifier que l'image s'affiche dans la previsualisation ;
- l'exigence de licence libre est moins forte que pour l'illustration generale ; l'agent peut privilegier une image Google ou source web pertinente, stable et techniquement importable, si elle reste validable et non revelatrice ;
- l'agent doit verifier que l'image ne contient pas de texte, legende, panneau, watermark, nom ou indice revelateur visible ;
- si l'image ne s'affiche pas dans l'UI agent ou dans un navigateur, elle ne doit pas etre retenue pour le `.md`.

Pour les supports YouTube :

- l'URL import peut etre l'URL YouTube ;
- l'agent doit fournir une miniature cliquable ou un lien de test dans la previsualisation ;
- l'agent doit verifier le titre, la miniature et les premieres secondes de l'extrait propose ;
- l'agent doit verifier que la video est compatible avec une lecture embed dans Cotton ou dans une page/app tierce ;
- si YouTube affiche un blocage embed du type `Cette video inclut du contenu de ... qui a bloque sa diffusion sur ce site Web ou dans cette application` ou force `Regarder sur YouTube`, le support ne doit pas etre retenu pour le `.md` ;
- si le titre ou la miniature revele la reponse et risque d'etre affiche dans Cotton, le support doit etre remplace ou marque `bloquant`.

Pour les supports audio/video directs :

- l'URL import doit pointer vers un fichier media direct compatible avec les extensions documentees ;
- l'agent doit fournir un lien cliquable ou lecteur de test lorsque l'interface le permet ;
- l'agent doit verifier que `Support start` et `Support end`, s'ils sont fournis, correspondent a un extrait non revelateur.

Ne jamais utiliser dans le `.md` :

- une URL Google Images ;
- une URL de page web qui n'est pas le fichier media ;
- une URL d'image qui expire rapidement ;
- une URL inaccessible sans session, cookie, compte ou autorisation ;
- une URL qui fonctionne seulement dans l'interface de recherche de l'agent.

### Contraintes techniques du `.md` importable

Format obligatoire pour chaque question :

```md
## Q1
Question : Texte contextualise de la question ?

Propositions :
A. Proposition 1
B. Proposition 2
C. Proposition 3
D. Proposition 4

Bonne reponse : Proposition exacte attendue

Explication : Explication courte utile a l'animateur.

Support type : image
Support : https://exemple.test/image-directe.jpg
Support start :
Support end :

Note support : Pourquoi ce support est acceptable, et pourquoi il ne revele pas la reponse.
```

Regles questions :

- sections `## Q1` a `## Q6` ;
- exactement 6 questions pour une serie certifiee ;
- `Question` est obligatoire ;
- `Propositions` doit contenir exactement 4 lignes `A.`, `B.`, `C.`, `D.` ;
- `Bonne reponse` doit reprendre exactement le texte d'une des 4 propositions, avec ou sans prefixe `A.` ;
- `Explication` est obligatoire pour les contenus certifies et alimente `questions.commentaire` ;
- `Support type` est obligatoire des qu'un support est fourni ;
- `Support` vaut une URL HTTP(S) compatible avec le `Support type`, ou `aucun` ;
- `Support start` et `Support end` sont optionnels et attendus en secondes entieres pour les supports audio/video/YouTube ;
- `Support start` et `Support end` ne s'appliquent pas aux images ;
- `Note support` est obligatoire lorsqu'un support est fourni ;
- le support est affiche ou joue pendant la question ; ne pas utiliser ce champ pour un media qui devrait etre lance avant, apres ou seulement a la correction.
- apres parsing du `.md`, la preview PRO affiche les supports qui seront importes ; toute correction doit etre faite dans le Markdown source ou dans la previsualisation editoriale de l'agent IA, puis la preview doit etre relancee avant import DB.

Regles pour l'illustration de thematique :

- `Illustration` vaut une URL image directe HTTP(S), ou `aucun` si l'illustration sera ajoutee plus tard ;
- formats acceptes par l'importeur PRO V1 : JPEG ou PNG ;
- l'URL doit porter une extension image claire, par exemple `.jpg`, `.jpeg` ou `.png` ;
- l'image doit etre au format paysage ;
- l'URL doit pointer vers un fichier image, pas vers une page HTML ;
- l'image doit etre libre de droits, gratuite, reutilisable sans condition particuliere, et compatible avec un usage commercial Cotton ;
- Unsplash est une source recommandee si l'agent fournit une URL directe exploitable et convertie avec une extension claire pour l'import ;
- l'agent IA doit indiquer dans sa note ou son commentaire de livraison pourquoi l'image est consideree comme librement reutilisable ;
- ne pas utiliser d'image soumise a attribution obligatoire, accord specifique, restriction commerciale, compte payant, filigrane, banque d'images sous licence ou conditions particulieres ;
- l'image ne doit pas etre un support de question et ne doit pas reveler une reponse precise ;
- l'importeur telecharge l'illustration au moment de l'import definitif, la verifie, puis l'ecrit en `.jpg` dans le stockage applicatif des visuels de series Quiz (`cotton_quiz/images/jeux_cotton_quiz/questions_lots/{id_lot}.jpg`) ;
- si une serie Cotton existe deja avec le meme titre ou slug, le PRO peut mettre a jour uniquement cette illustration via une action explicite, sans modifier les questions ni les propositions ;
- si l'illustration est invalide, inaccessible ou dans un format non accepte, l'import est bloque avant creation DB.

Regles supports pour l'importeur PRO Quiz :

- `Support type` doit etre une valeur supportee par l'importeur : `image`, `audio`, `video`, `youtube`, `youtube_audio`, `youtube_video` ;
- si `Support type` est absent mais que `Support` contient une URL image directe legacy avec extension `jpg`, `jpeg`, `png`, `gif` ou `webp`, l'importeur peut l'interpreter comme `image` ;
- si `Support type` vaut `aucun` ou si `Support : aucun`, aucun support n'est importe ;
- si `Support type` est inconnu, l'importeur bloque avant creation DB avec une erreur claire ;
- si l'URL ou les parametres `Support start` / `Support end` sont invalides, l'importeur bloque avant creation DB ;
- `Support end` doit etre strictement superieur a `Support start` lorsque les deux sont fournis ;
- `Note support` reste obligatoire des qu'un support est fourni ;
- `image` attend une URL image HTTP(S) stable et directement affichable ; dans l'importeur simplifie actuel, le lien support est importe en DB tel que valide en preview, sans telechargement automatique du fichier ;
- pour une image de question, la licence n'a pas le meme niveau d'exigence que l'illustration de serie : choisir d'abord une image pertinente, stable, affichable et importable, sans URL Google intermediaire ni indice revelateur ;
- `audio` attend une URL directe audio avec extension `mp3`, `m4a`, `aac`, `ogg`, `oga`, `wav` ou `flac` ;
- `video` attend une URL directe video avec extension `mp4`, `webm`, `mov` ou `m4v` ;
- `youtube`, `youtube_audio` et `youtube_video` attendent une URL YouTube ;
- les supports non image ne sont pas telecharges par l'importeur : l'URL est enregistree comme lien support ;
- l'importeur enregistre le support de question, mais ne porte pas de timing editorial `avant question` / `apres reponse` : le support est destine a etre utilise pendant la question.

Mapping DB confirme pour les supports de question :

- `Support type : image` -> `questions.id_type_support = 1` ;
- `Support type : audio` ou `youtube_audio` -> `questions.id_type_support = 2` ;
- `Support type : video`, `youtube` ou `youtube_video` -> `questions.id_type_support = 3` ;
- `Support` -> `questions.lien_support` ;
- `Support start` / `Support end` -> pas de colonnes DB dediees trouvees dans `questions`; l'importeur les preserve dans l'URL stockee en ajoutant les parametres `start` et `end` a `questions.lien_support`.

Exemples de syntaxe support typé :

```md
Support type : image
Support : https://exemple.test/image-directe.jpg
Note support : Image non revelatrice, utilisable comme contexte visuel.
```

```md
Support type : youtube_video
Support : https://www.youtube.com/watch?v=XXXXXXXXXXX
Support start : 12
Support end : 28
Note support : Extrait video utilise comme ambiance, sans reveler la reponse avant validation.
```

```md
Support type : youtube_audio
Support : https://www.youtube.com/watch?v=XXXXXXXXXXX
Support start : 45
Support end : 60
Note support : Extrait audio court, reconnaissable mais non revelateur de la bonne reponse.
```

```md
Support type : audio
Support : https://exemple.test/extrait.mp3
Support start : 0
Support end : 15
Note support : Extrait audio direct, verifiable et non revelateur.
```

```md
Support type : video
Support : https://exemple.test/extrait.mp4
Support start : 3
Support end : 18
Note support : Extrait video direct, verifiable et non revelateur.
```

### Distinction entre fiche editoriale et `.md` import PRO Quiz V1

- Le modele editorial Cotton peut proposer image, audio et video.
- Le `.md` importable doit respecter strictement les capacites courantes de `/extranet/games/import/quiz`.
- A date, l'importeur PRO Quiz audite supporte `image`, `audio`, `video`, `youtube`, `youtube_audio` et `youtube_video` si le `.md` declare explicitement `Support type`.
- Les types non documentes ci-dessus doivent etre consideres non supportes a date.
- La documentation doit toujours refleter les capacites reelles de l'importeur audite.
- Tant qu'un type donne n'est pas prouve dans l'importeur, indiquer `non supporte a date` plutot que laisser croire que l'import est possible.
- L'agent doit produire le `.md` le plus complet possible dans les limites du format cible.

### Exemple complet corrige

Cet exemple illustre la structure attendue pour une serie certifiee `Facile` avec progression legere. Il ne doit pas etre recopie comme `.md` final sans validation reelle des medias. Un exemple definitif doit contenir uniquement des URLs import testees, affichees ou ouvertes dans la previsualisation, puis validees explicitement par l'utilisateur.

Si un exemple contient une URL non affichee, non testee ou marquee `a valider`, cet exemple ne doit pas etre utilise comme `.md` final.

```md
# Histoire de la Coupe du monde
Titre : Histoire de la Coupe du monde
Slug : histoire-coupe-du-monde
Description : Une serie accessible pour tester ses connaissances sur les grands reperes de la Coupe du monde de football.
Niveau : Facile
Rubrique : Sport
Categorie : Sport
Sous-categorie : Football
Illustration : https://images.unsplash.com/photo-1522778119026-d647f0596c20?auto=format&fit=crop&w=1600&q=85
Type : Cotton Quiz
Public : Grand public / CHR / soirees quiz
Format : QCM 4 reponses

## Q1
Question : Dans quel pays a eu lieu la premiere Coupe du monde de football, jouee en 1930 ?

Propositions :
A. Uruguay
B. Bresil
C. Italie
D. France

Bonne reponse : Uruguay

Explication : La premiere Coupe du monde s'est jouee en Uruguay en 1930. Le pays hote a egalement remporte cette premiere edition.

Support type : image
Support : https://upload.wikimedia.org/wikipedia/commons/4/43/Estadio_Centenario_1930.jpg
Support start :
Support end :

Note support : Image historique non revelatrice a valider visuellement avant import. Le visuel doit donner un contexte d'epoque sans afficher de legende, cartel ou texte incruste revelant explicitement la reponse.

## Q2
Question : Quel trophee historique a donne son nom a la Coupe du monde remise aux vainqueurs jusqu'en 1970 ?

Propositions :
A. Jules Rimet
B. Henri Delaunay
C. Ballon d'or
D. Coupe Stanley

Bonne reponse : Jules Rimet

Explication : Le trophee Jules Rimet a ete remis aux champions du monde jusqu'a la victoire definitive du Bresil en 1970.

Support type : image
Support : https://commons.wikimedia.org/wiki/Special:Redirect/file/Jules_Rimet_Cup.jpg
Support start :
Support end :

Note support : Image du trophee a utiliser seulement si la previsualisation confirme l'absence de legende ou mention revelatrice. Sinon, remplacer par une image d'ambiance non revelatrice.

## Q3
Question : Quelle selection a remporte trois Coupes du monde masculines entre 1958 et 1970, avec une generation devenue legendaire ?

Propositions :
A. Bresil
B. Allemagne
C. Argentine
D. Angleterre

Bonne reponse : Bresil

Explication : Le Bresil a gagne les editions 1958, 1962 et 1970, une periode associee notamment a Pele et au football offensif bresilien.

Support : aucun

## Q4
Question : De 1998 a 2022, combien d'equipes participaient a la phase finale de la Coupe du monde masculine ?

Propositions :
A. 32
B. 24
C. 40
D. 48

Bonne reponse : 32

Explication : Le format a 32 equipes a ete utilise de l'edition 1998 jusqu'a l'edition 2022 incluse, avant l'extension a 48 equipes de 2026.

Support : aucun

## Q5
Question : Quel pays a accueilli la Coupe du monde masculine 1998, edition marquee par une finale remportee a Saint-Denis ?

Propositions :
A. France
B. Italie
C. Espagne
D. Allemagne

Bonne reponse : France

Explication : La Coupe du monde 1998 s'est jouee en France, avec une finale France-Bresil au Stade de France.

Support type : image
Support : https://upload.wikimedia.org/wikipedia/commons/c/c9/Stade_de_France_2016.JPG
Support start :
Support end :

Note support : Image de stade utile pour l'ambiance et le contexte, sans legende, panneau ou mention visible qui revele la reponse.

## Q6
Question : Avant l'arrivee des tirs au but en Coupe du monde masculine en 1982, comment certains matchs a elimination directe pouvaient-ils etre departages s'ils restaient a egalite apres prolongation ?

Propositions :
A. Match rejoue
B. Classement FIFA
C. But en or
D. Corners obtenus

Bonne reponse : Match rejoue

Explication : Avant l'usage des tirs au but en Coupe du monde masculine, certains matchs a elimination directe pouvaient etre rejoues lorsqu'ils restaient indecis apres prolongation. Selon les reglements et les editions, d'autres solutions exceptionnelles ont aussi existe, comme le tirage au sort, ce qui explique l'importance de parler ici de "certains matchs".

Support : aucun
```

### Checklist agent avant generation du `.md`

Avant de livrer un `.md`, verifier :

- [ ] La serie contient exactement 6 questions.
- [ ] Une previsualisation editoriale a ete produite et validee explicitement avant le `.md`.
- [ ] Le niveau global est coherent.
- [ ] La difficulte progresse si possible.
- [ ] La question finale est interessante et, si pertinent, associee a un support audio/video dans la fiche editoriale.
- [ ] Les formulations temporelles sont historiquement bornees et ne deviendront pas fausses apres un evenement deja programme.
- [ ] Les questions sont contextualisees.
- [ ] Les propositions sont lisibles sur mobile.
- [ ] Les distracteurs nivellent correctement la difficulte.
- [ ] Les mauvaises reponses sont plausibles mais non contestables.
- [ ] Chaque question contient une explication utile.
- [ ] `Explication` est compatible avec le mapping import documente.
- [ ] `Rubrique` est une valeur exacte du referentiel documente.
- [ ] La categorie et la sous-categorie sont coherentes.
- [ ] Une illustration generale specifique et qualitative est proposee.
- [ ] Au moins 3 supports sont proposes si le theme s'y prete.
- [ ] Chaque support retenu est compatible avec un affichage ou une lecture pendant la question.
- [ ] Les supports ne revelent pas les reponses.
- [ ] Les images retenues ne contiennent pas de legende, texte incruste, panneau, watermark ou mention visible qui donne la reponse.
- [ ] Les supports sont techniquement compatibles avec le format import cible.
- [ ] Chaque support fourni declare un `Support type` compatible avec l'importeur.
- [ ] Chaque support YouTube retenu a ete teste en lecture embed et ne renvoie pas de blocage imposant `Regarder sur YouTube`.
- [ ] Les parametres `Support start` et `Support end`, s'ils sont fournis, sont entiers, coherents et preserves dans l'URL support.
- [ ] Chaque illustration ou support retenu pour le `.md` possede une URL import distincte et testee.
- [ ] Chaque media retenu a ete affiche, ouvert, ecoute ou teste dans la previsualisation editoriale.
- [ ] Aucun support n'est seulement decrit comme `a chercher`, `a valider plus tard` ou `a remplacer` dans la version finale du `.md`.
- [ ] Aucun lien casse ou non affiche dans l'UI agent n'est conserve dans le `.md`.
- [ ] Les liens Google Images, pages HTML non media et redirections incertaines ont ete remplaces par des URLs compatibles import.
- [ ] Pour Unsplash, l'agent fournit l'URL directe exploitable de l'image, convertie avec une extension claire pour l'import, et indique que l'image est consideree comme librement reutilisable selon les conditions Unsplash.
- [ ] Pour un media trouve via Google, l'agent n'utilise pas l'URL Google mais retrouve et valide l'URL source ou l'URL directe du media.
- [ ] Si un support ne peut pas etre valide dans la conversation, il est remplace ou le `.md` n'est pas genere.
- [ ] Le `.md` ne contient pas de champ laisse a choisir si l'agent peut trancher.
- [ ] Les URLs placees dans les champs techniques sont des URLs directes si exige.

## community_items

### Statut

La table `community_items` peut etre utilisee par la bibliotheque moderne pour distinguer les contenus Cotton, Communaute et autres origines.

Pour un contenu Cotton certifie moderne :

```sql
origin = 'cotton'
status = 'published'
source_type = 'catalogue'
```

### Playlist

Exemple de valeurs attendues :

```sql
game = 'blindtest'
content_type = 'playlist'
source_type = 'catalogue'
source_id = @new_playlist_id
source_item_id = @new_playlist_id
source_client_id = 0
item_id = @new_playlist_id
origin = 'cotton'
status = 'published'
```

### Serie Quiz

Exemple de valeurs attendues :

```sql
game = 'quiz'
content_type = 'series'
source_type = 'catalogue'
source_id = @new_lot_id
source_item_id = @new_lot_id
source_client_id = 0
item_id = @new_lot_id
origin = 'cotton'
status = 'published'
```

### Prudence

Comme certains contenus Cotton existants n'ont pas d'entree `community_items`, l'absence de cette entree ne doit pas empecher un contenu legacy `id_client_auteur=0` d'etre considere comme Cotton certifie.

## Format de travail editorial

Pour creer un nouveau contenu, partir du gabarit suivant :

```text
Type :
Theme :
Public :
Niveau :
Ton :
Contraintes :
A eviter :
Objectif :
```

## Validation avant SQL ou import

### Playlist

- 40 morceaux presents.
- Pas de doublon involontaire.
- Artiste et titre renseignes.
- URL media presente ou a completer.
- Niveau et rubrique definis.
- Titre catalogue valide.
- Description courte validee.
- Slug valide.

### Serie Quiz

- Exactement 6 questions pour une serie certifiee.
- Reponse correcte non ambigue.
- 3 mauvaises propositions par question.
- Pas de proposition trop proche de la bonne reponse.
- Questions suffisamment contextualisees pour etre agreables et non ambigues.
- Mauvaises reponses plausibles mais non contestables dans le contexte donne.
- Supports multimedia prevus sur au moins 3 questions lorsque le theme s'y prete.
- Au moins 3 supports multimedia candidats proposes avec type, URL, timecodes eventuels, question associee, role editorial, risque de revelation et statut de validation.
- Supports multimedia non revelateurs de la reponse attendue.
- Niveau homogene.
- Titre catalogue valide.
- Description courte validee.
- Slug valide.

## Structure recommandee d'un SQL d'import

Cette section concerne les imports directs SQL historiques. Elle ne doit pas etre utilisee pour le flux PRO Markdown `/extranet/games/import/quiz`, qui attend un fichier `.md`.

Chaque import SQL direct doit etre transactionnel :

```sql
START TRANSACTION;

-- Creation du contenu principal
-- Creation ou reutilisation des dependances
-- Association des elements
-- Entree community_items si retenue

COMMIT;
```

Ajouter ensuite des requetes de controle.

### Controles playlist

```sql
SELECT *
FROM jeux_bingo_musical_playlists
WHERE id = @new_playlist_id;

SELECT COUNT(*) AS nb_morceaux
FROM jeux_bingo_musical_morceaux_to_playlists
WHERE id_playlist = @new_playlist_id;

SELECT *
FROM community_items
WHERE game = 'blindtest'
  AND content_type = 'playlist'
  AND source_type = 'catalogue'
  AND source_id = @new_playlist_id;
```

### Controles serie Quiz

```sql
SELECT *
FROM questions_lots
WHERE id = @new_lot_id;

SELECT COUNT(*) AS nb_questions
FROM questions
WHERE id_lot = @new_lot_id;

SELECT COUNT(*) AS nb_propositions
FROM questions_propositions qp
JOIN questions q ON q.id = qp.question_id
WHERE q.id_lot = @new_lot_id;

SELECT *
FROM community_items
WHERE game = 'quiz'
  AND content_type = 'series'
  AND source_type = 'catalogue'
  AND source_id = @new_lot_id;
```

## Requete de presence community_items

Avant d'inserer une entree moderne, verifier que la table existe sur l'environnement cible :

```sql
SHOW TABLES LIKE 'community_items';
```

Si la table n'existe pas, conserver uniquement la compatibilite legacy `id_client_auteur=0`.

## Regle de prudence

Ne jamais executer un import directement en production sans :

- validation editoriale ;
- relecture SQL ou preview PRO selon le flux ;
- test sur environnement non critique si possible ;
- controle post-import ;
- verification visuelle dans la bibliotheque/catalogue Cotton.
