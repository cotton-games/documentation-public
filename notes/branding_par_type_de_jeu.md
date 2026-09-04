# Branding par type de jeu

## Contexte

Etat actuel observe au 2026-04-01:
- le branding est stocke dans `general_branding` via le couple `id_type_branding` + `id_related`;
- les portees gerees sont `session`, `evenement`, `reseau`, `client`;
- aucune dimension `type de jeu` n'existe dans la table ni dans les resolvers metier;
- le front `games` enregistre aujourd'hui soit un branding session (`1`), soit un branding compte global (`4`).

Conséquence:
- un branding compte s'applique a tous les jeux d'un client;
- un reset session ne peut supprimer qu'un branding compte global, pas un branding compte borne a `quiz`, `blindtest` ou `bingo`.

## Objectif cible

Permettre un branding par type de jeu applicable a toutes les portees de branding:
- branding session par type de jeu;
- branding evenement par type de jeu;
- branding reseau par type de jeu;
- branding client par type de jeu.

Exemple attendu:
- un organisateur personnalise le design d'une session `Blind Test`;
- s'il coche `Utiliser ce design pour mes prochaines sessions`, le design devient le defaut compte pour `Blind Test` uniquement;
- un reset sur une session `Blind Test` ne supprime que le branding compte `Blind Test` correspondant, sans toucher aux defaults `Quiz` ou `Bingo`.

## Limite structurelle actuelle

Le modele actuel ne sait pas porter ce besoin sans evolution backend:
- `general_branding` ne contient pas de colonne `id_type_produit`;
- `app_general_branding_find_id(...)` ne peut retrouver qu'un branding par portee + id relie;
- `app_general_branding_get_detail(...)` resolve seulement `session > evenement > reseau > client`;
- `app_session_branding_get_detail(...)` ne transporte pas non plus de dimension jeu;
- les endpoints save/delete/preview branding n'acceptent pas aujourd'hui un ciblage par type de jeu.

## Recommandation d'architecture

Evolution recommandee, retrocompatible:

1. Ajouter une colonne nullable `id_type_produit` a `general_branding`.
2. Ajouter un index composite sur la resolution metier:
   - `(id_type_branding, id_related, id_type_produit)`.
3. Conserver les lignes existantes avec `id_type_produit IS NULL` comme fallback global.
4. Faire evoluer la resolution runtime vers:
   - branding scope specifique au type de jeu courant;
   - sinon fallback au branding scope global du meme niveau;
   - puis niveau inferieur suivant.

Ordre cible:
- `session[type_jeu]`
- `session[global]`
- `evenement[type_jeu]`
- `evenement[global]`
- `reseau[type_jeu]`
- `reseau[global]`
- `client[type_jeu]`
- `client[global]`

Alternative acceptable si l'on veut limiter le premier lot:
- n'introduire la dimension `type de jeu` que pour le branding compte dans un premier temps;
- mais cela cree un contrat asymetrique et risque de devoir etre refondu ensuite pour `session/evenement/reseau`.

## Impacts applicatifs

### `global`
- faire evoluer les helpers `app_general_branding_*` pour accepter `id_type_produit`;
- faire evoluer les write paths `save`, `delete`, `delete_preview`, duplication et reset;
- faire evoluer les chemins de resolution d'assets si l'on souhaite des dossiers differencies par type de jeu;
- faire evoluer les snapshots de sessions futures pour ne figer que les sessions du type de jeu concerne qui heritent encore du branding scope courant.

### `games`
- transmettre le type de jeu courant lors des saves `apply to all`, des previews de delete et des deletes;
- afficher un wording borne au type courant:
  - `Utiliser ce design pour mes prochaines sessions de ce jeu`;
  - `Les prochaines sessions programmees de ce jeu n'utiliseront plus ce design`.

### `pro` / autres consommateurs
- relire tous les appels aux helpers branding pour fournir le type de jeu quand il est connu;
- verifier les ecrans de branding reseau / compte qui affichent ou edittent aujourd'hui un seul branding global.

## Regle de migration recommandee

Pour eviter toute regression:
- conserver les brandings existants sans `id_type_produit` comme defaults globaux;
- ne creer des lignes `id_type_produit` que lors d'un save explicite sur un type de jeu;
- au runtime, prioriser le branding `scope + type de jeu`, puis fallback sur `scope global`.

Ainsi:
- aucun client existant ne perd son branding actuel;
- les jeux non encore specialises continuent d'heritier du branding global.

## Cas particulier du reset

Si un reset de branding supprime un branding scope + type de jeu:
- ne supprimer que le branding de la portee courante pour le type de jeu courant;
- si ce branding est aussi utilise comme default pour des sessions futures deja programmees de ce meme type de jeu, figer uniquement ces sessions-la avant suppression.

## Statut

Note d'architecture uniquement.
Non implemente au 2026-04-01.
