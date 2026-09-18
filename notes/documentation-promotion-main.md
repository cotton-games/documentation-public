# Promotion documentaire develop → main

Contrat confirmé par l’opérateur : lors de la promotion après déploiement PROD, les sources documentaires doivent être identiques à `develop`. Les différences propres à `main` portent sur les liens générés. Une source ou un fichier présent seulement sur main est donc remplacé/supprimé, pas conservé par une fusion textuelle.

## Installation initiale

Intégrer `scripts/promote-docs.mjs`, son test et cette procédure dans **develop** avant la première promotion. Ne pas démarrer une promotion avec des travaux locaux non enregistrés. Le script ne télécharge aucune branche : mettre à jour la branche locale develop avant utilisation.

Cette passe a préparé les fichiers pendant qu’un merge était déjà ouvert sur main. Elle n’a ni résolu l’index Git ni effectué de commit : `.git` est en lecture seule pour l’agent. Conserver ces nouveaux fichiers et les modifications de documentation avant toute annulation du merge ; leur installation dans develop reste à effectuer par l’opérateur.

## Utilisation après chaque déploiement

Depuis la racine du dépôt documentation, avec un checkout propre :

```sh
git switch main
node scripts/promote-docs.mjs
git diff --cached --stat
git commit -m "Promeut la documentation develop vers main"
```

Le script ouvre un merge sans commit automatique, remplace l’ensemble des fichiers suivis par l’arbre develop (y compris les suppressions), puis régénère `SITEMAP.*` et les `INDEX.md` avec `DOCS_BRANCH=main`. Il vérifie que seules les sorties générées diffèrent de develop. Le SHA de develop est utilisé pour la génération locale ; le workflow de publication régénère déjà avec le SHA du commit main et la branche main avant publication.

Un vrai commit de merge conserve les deux parents lorsque les branches doivent être réunies. Si develop est déjà ancêtre de main, Git ne crée pas de nouveau merge : une éventuelle resynchronisation de contenu se termine alors par un commit ordinaire. Aucun reset de branche ni force-push.

Les liens explicitement écrits dans les sources restent ceux de develop. Les références interbranches intentionnelles du générateur restent présentes ; toutes les URL ne sont donc pas transformées aveuglément en liens main.

## Reprise d’un merge déjà en conflit

Après installation de l’outil dans develop, sans autres modifications locales :

```sh
node scripts/promote-docs.mjs --resume
git diff --cached --stat
git commit -m "Promeut la documentation develop vers main"
```

Le merge doit viser exactement le HEAD actuel de develop. La reprise remplace aussi les résolutions de conflits par la source develop, conformément au contrat. Les modifications non indexées hors conflits et les fichiers non suivis provoquent un refus avant remplacement.

En cas d’échec de génération, aucun commit/push n’est effectué : corriger puis reprendre la préparation explicitement, ou utiliser `git merge --abort` tant que le merge est ouvert. Le script ne lance jamais `git add -A` sans restriction sur les fichiers locaux : seuls l’arbre source et les sorties générées sont indexés.

## Validation et suivi

```sh
node --test scripts/promote-docs.test.mjs
```

Les tests utilisent des dépôts temporaires isolés : conflits sources/index, reprise de merge, suppressions, liens main, conservation des deux parents, refus des modifications locales et mauvaise branche. Aucun accès réseau ou dépôt serveur.

- [x] Automatisation ajoutée localement ; cinq tests Node réussis (merge neuf, reprise, travail local, branche incorrecte, modifications après merge). Syntaxe Node et diff des sources contrôlés.
- [ ] Installer les fichiers dans develop et terminer/relancer le merge courant depuis le terminal opérateur.
- [ ] Effectuer le commit puis le push habituel après vérification.
