# Modèle d’équipes Hub — chantier futur séparé

<!-- AUTO-UPDATE:BEGIN id="hub-team-model-future" owner="codex" -->

## Statut et périmètre

**Conception produit/architecture future, non implémentée et non déployée.** Les principes ci-dessous constituent le modèle cible envisagé ; ils ne décrivent pas le fonctionnement actuel et ne valent pas décision de migration.

Ce chantier est distinct des contrats runtime papier actuels et des PATCH1, PATCH1B, PATCH2 et PATCH3. Il ne modifie pas ces contrats. Le chantier équipes Blind Test reste désactivé : cette note ne change aucun feature flag et n’autorise aucune réactivation. Aucun schéma, endpoint ou protocole runtime nouveau n’est arrêté ici.

## 1. Identité et inscription individuelles

L’inscription au Hub reste individuelle. Chaque joueur conserve :

- sa propre inscription Hub ;
- sa propre K canonique ;
- son propre appareil ;
- sa propre présence runtime ;
- son propre résultat par question, morceau ou phase.

L’appartenance à une équipe ajoute un regroupement à ces identités ; elle ne remplace ni le joueur, ni sa K, ni sa présence. Une équipe ne doit pas servir de substitut technique à un joueur. Les résultats individuels restent identifiables même lorsqu’ils contribuent à un score d’équipe.

## 2. Parcours solo ou équipe

Le premier membre arrivé s’inscrit individuellement, puis peut jouer en solo ou inscrire une équipe existante de son EP Play. Une fois cette équipe inscrite dans le contexte Hub/session, les autres membres qui s’inscrivent individuellement choisissent de rejoindre cette équipe ou de jouer en solo.

Le choix solo/équipe est ensuite **verrouillé pour la session concernée**. Le moment exact du verrouillage reste à définir. La durée d’inscription de l’équipe et son éventuelle réutilisation d’une session à l’autre ne sont pas déduites de ce verrouillage : ce sont des questions distinctes, encore ouvertes.

## 3. Réutilisation des équipes de l’EP

Les comptes joueurs continuent à créer et gérer leurs équipes depuis leur espace joueur. Lors de son inscription Hub, un joueur appartenant à une équipe peut proposer cette équipe existante.

Le modèle cible doit réutiliser ce référentiel et éviter un second modèle concurrent d’équipes. La représentation de la participation d’une équipe à un Hub ou à une session reste à concevoir ; elle ne doit pas être confondue avec la définition durable de l’équipe dans l’EP. Les droits de proposition et de rattachement devront être vérifiés côté serveur selon des règles à préciser.

## 4. Score d’équipe par meilleur résultat sur chaque item

Le principe transverse envisagé est :

`score équipe par item = meilleur score d’un membre de l’équipe sur cet item`

Les résultats ainsi retenus sont ensuite agrégés selon les règles normales du jeu pour produire le score et le rang de l’équipe. Le meilleur membre peut être différent d’un item à l’autre. Il ne s’agit ni de cumuler mécaniquement tous les scores des membres, ni de retenir uniquement le meilleur score total individuel.

| Jeu | Item envisagé | Résultat retenu pour l’équipe |
| --- | --- | --- |
| Quiz | Question | Meilleur résultat d’un membre sur cette question |
| Blind Test | Morceau | Meilleur résultat d’un membre sur ce morceau |
| Bingo | Phase | Meilleur résultat ou progression pertinente d’un membre pour cette phase |

Exemple illustratif : sur deux questions, un membre obtient10 puis0, un autre0 puis10. Les meilleurs résultats par question donnent10 puis10 pour l’équipe, donc20 si le jeu additionne normalement ces items.

Pour Bingo, la progression comparable et sa conversion éventuelle en score doivent encore être définies. Cette note ne transforme pas ses règles actuelles de phase, de victoire ou d’attribution des gains. Les départages et corrections de résultats devront également être précisés lors de la conception détaillée.

## 5. Motivations produit

Ce modèle vise à :

- encourager chaque personne à s’inscrire individuellement, même lorsqu’elle joue en équipe ;
- encourager la création d’un compte joueur pour gérer et retrouver ses équipes, sans décider ici d’en faire une obligation générale ;
- conserver une identité individuelle stable dans le Hub ;
- proposer une expérience équipe cohérente entre Quiz, Blind Test et Bingo ;
- séparer clairement identité du joueur, appartenance à une équipe et calcul du score collectif.

## 6. Compatibilité papier et orientation de migration

L’ajout historique par l’organisateur depuis la Remote papier reste aujourd’hui un mécanisme de compatibilité. Cette réflexion ne le retire pas et ne réinterprète pas les participations historiques comme si elles étaient déjà constituées de membres individuels identifiés.

À terme, le parcours principal pourrait privilégier l’inscription individuelle au Hub via QR, y compris pour les joueurs papier, puis le choix solo/équipe depuis Hub Play. **Cette orientation n’est ni une migration décidée, ni une fonctionnalité déployée.** L’articulation avec les usages papier sans appareil actif et les anciennes équipes Quiz devra être instruite avant toute évolution.

## 7. Questions ouvertes — aucune décision d’implémentation

| Sujet | À trancher |
| --- | --- |
| Portée de l’équipe participante | Session, soirée/Hub ou autre contexte ? |
| Plusieurs sessions | Peut-on rejoindre la même équipe sur plusieurs sessions d’un Hub, et avec quelle continuité de composition ? |
| Appartenances persistantes | Comment représenter les memberships de participation et leurs liens avec les équipes EP, sans dupliquer leur référentiel ? |
| Inscriptions simultanées | Comment traiter deux membres proposant la même équipe au même instant ? |
| Plusieurs équipes EP | Quelle équipe proposer lorsqu’un joueur appartient à plusieurs équipes, et comment présenter ce choix ? |
| Classements | Comment représenter et articuler classement individuel, classement d’équipe et joueurs solos ? |
| Historique et statistiques | Comment conserver les résultats individuels et collectifs, et quelle attribution dans les statistiques joueurs/équipes ? |
| Équipes Quiz historiques | Comment assurer la compatibilité sans supposer des membres individuels que les données anciennes n’identifient pas ? |
| Verrouillage | À quel instant précis le choix solo/équipe devient-il définitif pour la session ? |

Les règles de composition pour les arrivées tardives ou départs, l’effet d’une modification d’équipe dans l’EP pendant une session, les corrections de résultats et la mesure pertinente par phase Bingo demandent aussi une conception détaillée. Aucune décision SQL, migration ou activation du mode équipe ne découle de cette note.

## 8. Suite documentaire

Cette note centralise la réflexion pour éviter des variantes dans les contrats des jeux. Une éventuelle phase suivante devra trancher les questions ouvertes, définir les scénarios de compatibilité et les critères de validation avant de proposer un patch applicatif. Les TASKS et HANDOFF référencent cette note sans présenter le modèle comme existant.

<!-- AUTO-UPDATE:END id="hub-team-model-future" -->
