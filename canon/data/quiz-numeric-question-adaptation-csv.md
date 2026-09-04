# Discipline d'adaptation des questions papier vers le numerique

## Objectif

Cette discipline sert a enrichir les questions historiques Cotton Quiz pour les rendre jouables en quiz numerique, sans dupliquer la source metier.

Le travail part en general d'un export CSV du BO `Questions numeriques`, complete par un agent IA, relu par un humain puis reimporte dans le BO.

## Modele de donnees

- `questions.question` = question papier/source.
- `questions.reponse` = reponse papier/source.
- `questions.commentaire` = commentaire papier/source.
- `questions.question_numerique` = adaptation numerique optionnelle.
- `questions.reponse_numerique` = reponse numerique optionnelle.
- `questions.commentaire_numerique` = commentaire numerique affichable optionnel.
- `questions.statut_numerique` = statut de traitement numerique.
- `questions_propositions` = distracteurs/propositions communs papier et numerique.
- `questions_numeriques` n'est pas un modele durable.
- Les lots temporaires numeriques `N{id}` utilisent des IDs `questions`.

Regles effectives en jeu numerique :

- question effective = `question_numerique` si renseignee, sinon `question`;
- reponse effective = `reponse_numerique` si renseignee, sinon `reponse`;
- commentaire effectif = `commentaire_numerique` si renseigne, sinon `commentaire`;
- les propositions sont les lignes communes de `questions_propositions`.

Les supports visuels, audio ou video restent visibles ou joues en numerique. Une adaptation numerique peut donc y faire reference si la question papier l'utilise deja.

## Regles d'adaptation de la question

- Ne renseigner `question_numerique` que si la question source doit etre adaptee.
- La question numerique doit poser une seule question claire.
- Elle ne doit pas contenir plusieurs questions.
- Elle ne doit pas inclure les propositions dans son libelle.
- Ne jamais enrichir un titre, une oeuvre, un indice ou une formulation avec un element contenant la reponse. Si la reponse est `Lauryn Hill`, ne pas ecrire `The Miseducation of Lauryn Hill` dans la question, meme si c'est le titre complet officiel. Preferer une forme raccourcie ou reformuler autrement.
- Elle peut faire reference au support visuel, audio ou video si ce support est visible ou joue en numerique.
- Si `jour_associe` est renseigne, conserver le repere jour/mois dans `question_numerique`. Il ne doit pas forcement etre place en tete : l'integrer naturellement dans la phrase. Utiliser "Le [jour mois], ..." seulement si la formulation reste fluide. Pour une naissance, preferer "ne(e) le [jour mois annee]" ; pour un deces, preferer "mort(e) le [jour mois annee]" ; pour un evenement, une publication, une sortie ou une creation, integrer la date au syntagme concerne. Ce repere prime sur le raccourcissement, car la question peut etre jouee dans une serie "Cette semaine dans l'histoire".
- Ne pas laisser `question_numerique` vide des qu'une question papier est longue, contextuelle ou peu adaptee a un affichage numerique. Reformuler en une question autonome, plus courte, tout en conservant l'intention exacte.
- Une question papier longue mais correcte doit quand meme etre raccourcie si elle contient plusieurs complements explicatifs non indispensables. Conserver uniquement les indices necessaires pour identifier la reponse, et supprimer les phrases de valorisation du type "revolutionnant notre comprehension..." sauf si elles sont indispensables.
- Si la question papier est deja compatible numerique, laisser `question_numerique` vide pour utiliser le fallback.

## Regles d'adaptation de la reponse

- Ne renseigner `reponse_numerique` que si la reponse source doit etre adaptee.
- La reponse effective doit etre courte, claire et directement comparable aux propositions.
- Elle doit etre du meme format que les distracteurs.
- Quand la reponse papier est une phrase explicative, produire une `reponse_numerique` courte, lisible comme une option de QCM.
- Si la reponse papier est deja adaptee, laisser `reponse_numerique` vide.

## Questions pieges et jeux de logique

Ne pas normaliser une question piege si le piege est precisement l'interet de la question.

- Conserver la formulation source si elle est claire et que le piege fonctionne en numerique.
- Ne pas reformuler pour rendre la question plus classique si cela detruit l'effet attendu.
- La reponse peut rester surprenante si elle est correcte.
- Le commentaire numerique peut expliquer le piege apres coup.
- Les distracteurs doivent rester plausibles dans une lecture naive de la question, sans reveler immediatement le piege.
- Pour les questions pieges, verifier que les distracteurs ne sont pas compatibles avec la bonne reponse. Ils doivent representer les mauvaises interpretations probables du piege.
- Pour les enigmes logiques, conserver non seulement les faits, mais aussi les relations de dialogue ou d'observation qui permettent la deduction. Une reformulation trop resumee peut supprimer une contrainte implicite essentielle.

La reponse doit etre claire une fois le piege compris ; elle n'a pas besoin d'etre la reponse attendue intuitivement.

## Regles du commentaire numerique

`commentaire_numerique` est affichable cote remote utilisateur et animateur.

Il peut donner :

- un contexte utile ;
- une precision culturelle ;
- une justification courte ;
- une aide d'animation.

Il ne doit jamais contenir :

- commentaire interne ;
- note de production ;
- doute editorial ;
- TODO ;
- instruction technique ;
- remarque destinee a l'admin ;
- contenu non affichable a un animateur.

Ne jamais recopier automatiquement un commentaire papier s'il est interne ou ambigu. Si la question ou la reponse a ete adaptee, ajuster le commentaire seulement s'il reste utile et affichable.

Ne pas renseigner `commentaire_numerique` si le commentaire repete simplement la reponse ou la paraphrase sans apporter de contexte utile.

## Regles des propositions et distracteurs

- Ajouter au moins une proposition exploitable.
- Pour une question ouverte, viser 3 distracteurs en plus de la bonne reponse.
- Pour une question fermee de type Vrai/Faux, Info/Intox ou Oui/Non, une seule proposition peut suffire.
- Les propositions doivent etre de meme nature et de meme format que la reponse effective.
- Les distracteurs doivent etre du meme niveau de formulation que la bonne reponse : meme nature grammaticale, meme longueur approximative, meme registre, sans indice evident.
- Les distracteurs doivent etre plausibles et coherents avec la question.
- Quand un support visuel est present, les distracteurs ne doivent jamais etre contredits par une caracteristique immediatement visible du support : couleur, forme, nombre d'elements, texte affiche, personne representee, animal, objet, pays, marque, etc. Un distracteur peut etre faux, mais il doit rester visuellement plausible.
- Pour les rebus et questions visuelles, eviter les distracteurs qui decrivent directement le mecanisme visible dans l'image. Un distracteur doit etre plausible comme reponse finale, pas comme commentaire de l'image.
- Pour les dingbats (enigmes visuelles avec support image), construire les distracteurs depuis des elements visibles ou inferables du support : mot affiche, disposition, taille, couleur, repetition, absence, cassure, inversion, position, etc.
- Ces distracteurs doivent rester visuellement plausibles afin que la bonne reponse ne soit pas evidente par elimination, sans pouvoir etre defendus comme une autre interpretation correcte du dingbat.
- Eviter les distracteurs trop eloignes de l'image, mais aussi ceux qui partagent seulement le meme theme lexical sans rapport direct avec le mecanisme visuel.
- La bonne reponse ne doit pas etre evidente a la simple lecture des propositions.
- Aucune proposition ne doit etre identique a la reponse effective.
- Eviter les distracteurs absurdes, trop larges, d'une autre categorie ou grammaticalement incoherents.
- Quand une correction utilisateur transforme une proposition "techniquement possible" en proposition vraiment fausse, reprendre cette logique sur les questions similaires.
- Avant validation d'une ligne, relire les propositions comme un joueur : une seule doit etre defendable, et aucune fausse proposition ne doit reveler la logique de la bonne reponse.
- Ne pas ajouter de typage papier/numerique dans `questions_propositions`.

## Statuts numeriques

Statuts metier :

- vide ou `NULL` = non traite ;
- `draft` = brouillon ;
- `review` dans un CSV = a relire par un humain ;
- `reviewed` en base = valeur canonique stockee pour "a relire" ;
- `certified` = utilisable par le builder numerique ;
- `rejected` = non retenu pour le numerique.

Les productions IA ou tableur doivent rester en `review` dans le CSV par defaut. L'import BO normalise `review` vers `reviewed`. Ne jamais mettre `certified` sauf validation humaine explicite.

## Regles pour agent IA travaillant sur un CSV exporte

Quand un agent IA recoit un export CSV de questions numeriques :

- preserver `id_question` ;
- ne jamais modifier les champs papier/source ;
- completer uniquement les colonnes numeriques et propositions ;
- laisser vide ce qui n'a pas besoin d'adaptation ;
- ne pas inventer de support absent ;
- tenir compte des supports existants s'ils sont indiques dans l'export, notamment `lien_support` ;
- produire des distracteurs plausibles ;
- mettre `statut_numerique=review` par defaut ;
- ne jamais mettre `certified` sauf demande explicite ;
- ne jamais mettre de commentaire interne en `commentaire_numerique` ;
- conserver le format CSV attendu pour reimport.

Colonnes editables attendues a l'import :

- `id_question`
- `question_numerique`
- `reponse_numerique`
- `commentaire_numerique`
- `statut_numerique`
- `proposition_1`
- `proposition_2`
- `proposition_3`
- `proposition_4`

Les colonnes de suivi exportees sont read-only et peuvent etre ignorees a l'import :

- `question_papier`
- `reponse_papier`
- `commentaire_papier`
- `lien_support`
- `jour_associe`
- `propositions_count`
- `etat_traitement`
- `nb_propositions`
- `is_certifiable`
- `has_question_numerique`
- `has_reponse_numerique`
- `has_commentaire_numerique`
- `validation_errors`

## Suivi du traitement

Process recommande :

1. Travailler par lots limites au debut, par exemple 50 questions.
2. Importer d'abord via le BO sur un lot pilote.
3. Relire dans le BO `Questions numeriques`.
4. Certifier seulement apres controle humain.
5. Reexporter depuis la DB apres chaque import significatif pour reprendre depuis l'etat reel.
6. Utiliser `statut_numerique` comme source principale de suivi.
7. Utiliser les indicateurs d'export `nb_propositions`, `is_certifiable`, `has_question_numerique`, `has_reponse_numerique`, `has_commentaire_numerique` et `validation_errors` quand ils sont disponibles.

## Exemples minimaux

### Question papier deja compatible

CSV :

```csv
id_question,question_numerique,reponse_numerique,commentaire_numerique,statut_numerique,proposition_1,proposition_2,proposition_3
4460,,,,review,Le kangourou,La puce,Le puma
```

Effet : le numerique utilise `questions.question` et `questions.reponse`, puis ajoute les distracteurs communs.

### Question papier a reformuler

CSV :

```csv
id_question,question_numerique,reponse_numerique,commentaire_numerique,statut_numerique,proposition_1,proposition_2,proposition_3
4457,"Quel telescope spatial lance en 1990 a revolutionne l'observation de l'univers ?",Hubble,"Hubble est un telescope spatial opere avec la NASA et l'ESA.",review,James-Webb,Spitzer,Kepler
```

Effet : la question et la reponse numeriques remplacent les champs papier seulement pour le jeu numerique.

### Question fermee Info/Intox

CSV :

```csv
id_question,question_numerique,reponse_numerique,commentaire_numerique,statut_numerique,proposition_1
4501,"Info ou intox : la Tour Eiffel peut sauter.",Intox,"La Tour Eiffel est une structure fixe.",review,Info
```

Effet : une seule proposition suffit car le format ferme oppose deux choix.

### Repere calendaire naturel

Mauvais :

```csv
question_numerique
"Le 22 fevrier, sous quel nom d'actrice Sylvette Herry, nee en 1950, est-elle connue ?"
```

Bon :

```csv
question_numerique
"Sous quel nom d'actrice Sylvette Herry, nee le 22 fevrier 1950, est-elle connue ?"
```

Effet : le repere calendaire reste visible sans deplacer artificiellement la date en tete de question.
