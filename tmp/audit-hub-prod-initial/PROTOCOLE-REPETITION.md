# Répétition de migration initiale Hub PROD

Statut : protocole préparé, pas un script exécutable ni une autorisation de déploiement. Aucun patch, DDL, backfill ou test sur copie PROD exécuté dans cette étape. La consigne utilisateur de ne pas modifier le code demeure respectée. Pas d'audit supplémentaire du contenu interne des jeux.

## Résultat recherché

Avec les mêmes données legacy, comparer les comportements des branches main à ceux de la livraison Hub, puis prouver que l'ajout des racines et memberships ne réécrit pas les sources. Le parc reçu donne une base de58 racines candidates et68 memberships ; ces nombres doivent être recalculés sur la capture de répétition puis sur celle du basculement.

## 1. Figer la livraison et préparer l'environnement

Conserver un manifeste des SHA exacts pour chaque repo modifié et de leurs références main. Ne pas livrer simplement « la branche hub_soiree » susceptible de changer entre essais. Identifier aussi les dépendances entre Global, Pro, Games, Play et les runtimes de jeux ; ne déployer que les versions effectivement validées ensemble. Les modifications main intervenues depuis la divergence doivent rester présentes dans la livraison.

Préparer un environnement isolé avec MariaDB10.3.39 et les versions/configurations PHP et services correspondant à PROD. Créer une capture cohérente de la base et des fichiers utiles au rendu, notamment branding/assets. Pour les tables MyISAM, un dump utilisant seulement --single-transaction ne suffit pas à garantir une capture cohérente : convenir d'une suspension des écritures ou d'une méthode de snapshot cohérent. Ne pas réutiliser une configuration pointant vers la base, les services WebSocket ou les tâches PROD. Neutraliser dans la copie les envois email/SMS, webhooks, paiements et tâches externes ; conserver les chemins locaux nécessaires à la validation.

Faire tourner main d'abord sur une copie de référence. Utiliser une seconde copie identique pour Hub, ou restaurer la capture avant chaque variante. Relever les URLs réellement générées par main pour les cas du tableau ci-dessous ; ne pas inventer de nouvelles URL pour représenter une ancienne entrée. La visite de main peut déjà modifier des pivots : enregistrer ces effets séparément, ne pas les confondre avec l'état capturé initialement.

Livrables : inventaire des environnements, manifeste de commits, capture restaurable, scénarios avec URL initiale et résultat main observé. Aucun besoin de certification de toutes les questions/playlists.

## 2. Corriger les chemins à risque avant de valider la livraison

Pour chaque comportement encore atteignable dans les commits retenus, reproduire un échec, apporter un correctif ciblé, puis montrer que le scénario passe. Cela reste du travail à réaliser, pas des corrections déjà faites.

| Risque | Contrat à démontrer |
|---|---|
| Entrée ancienne sans Hub | Après backfill, toutes les anciennes entrées retrouvent leur contexte. Si un contexte manque, résultat explicite et aucune mutation opportuniste du legacy ; comportement d'erreur à définir. |
| Membership partiel | La reprise écrit la totalité du manifeste, sans s'arrêter parce qu'une première session est déjà rattachée. La consultation ne masque pas les sessions attendues. |
| Choix par score | Une identité connue résout le Hub exact. Une ambiguïté est signalée ; aucune autre racine n'est sélectionnée silencieusement. |
| Bootstrap de pivot mutable | Consulter les parcours repris ne modifie aucun champ historique de session. Les actions explicites de gestion sont testées séparément et ne changent que ce qu'elles annoncent. |
| Valeurs session et Hub divergentes | Lots, branding et visibilité gardent leur sens selon leur niveau. Si le modèle livré ne permet pas de préserver un cas, c'est un blocage à résoudre, pas une valeur à choisir arbitrairement. |
| Accès commercial | La reprise est complète sans offre active ; les restrictions des actions commerciales sont conservées, sans octroi accidentel de droits. |

Tests existants localisés : Global web/tests/hub_identity_stability_contract_test.php, hub_publication_prizes_contract_test.php, hub_operation_branding_cascade_test.php, hub_probable_participations_contract_test.php ; Pro web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php. Ils peuvent servir de socle après inspection de leurs assertions, mais leurs noms ou leur succès ne prouvent pas la compatibilité sur une vraie base. Ajouter des tests de régression pour les défauts reproduits et des tests d'intégration sur la copie MariaDB10.3. Ne pas appeler arbitrairement les scripts de tests avant vérification de leurs dépendances et effets.

## 3. Préparer un paquet de migration dédié

Séparer trois éléments : DDL complet du schéma requis par les commits figés ; projection initiale ; contrôles. Ne pas importer les données Hub de DEV en PROD. Les Hubs cibles sont dérivés de la copie des données PROD.

Constat sur les scripts du workspace : games_hubs_phpmyadmin.sql crée games_hubs et games_hubs_sessions ; games_hubs_sessions_phpmyadmin.sql ajoute des memberships à des racines existantes via INSERT IGNORE et une règle de candidats. Aucun ne constitue, à lui seul, le paquet complet d'une migration initiale conforme. Comparer toutes les exigences de schéma des lecteurs/écrivains livrés (colonnes/index/tables), sans compter sur schema_ensure à la première requête. Ne pas exécuter ces fichiers en l'état comme migration initiale.

Le manifeste readonly énumère chaque session, sa clé métier proposée, sa racine cible et le motif d'éligibilité. Vérifier que les context_type exacts correspondent aux constantes/normalisations du code livré. Ne pas déduire les valeurs à insérer du seul nom métier « soirée ».

Le backfill crée exactement une racine par clé validée puis tous ses memberships. Il ne réutilise pas les helpers audités qui choisissent par score ou modifient les pivots. Il conserve l'identité des racines et tokens en cas de relance ; les tokens peuvent être générés une fois, le caractère déterministe porte sur l'affectation et la stabilité à la relance. Les écritures autorisées sont limitées aux tables Hub ; utiliser si possible un compte de migration avec lecture seule sur les tables legacy et droits d'écriture ciblés sur les tables Hub, distinct du compte DDL.

Définir les règles des données Hub-scoped : conserver les références/session-specificités lorsqu'elles portent une information ; initialiser les données communes seulement si le contrat est démontré. Ne pas convertir arbitrairement les6 participations legacy, ni les transformer en activité Remote/Play fictive. Les droits sans offre ne filtrent jamais la création des memberships.

Prévoir un journal de migration avec run_id, clés créées, IDs et progression. Tester interruption et reprise : les tables MyISAM ne permettent pas de compter sur un rollback transactionnel global. INSERT IGNORE ou IF NOT EXISTS seuls ne prouvent pas la conformité ni l'idempotence.

## 4. Contrôles avant et après

Pour un état figé correspondant aux résultats reçus :58 racines candidates,68 memberships actifs,68 sessions reprises,0 session éligible oubliée,0 session dans plusieurs Hubs,0 doublon de clé,0 référence Hub/session orpheline. Comparer aussi l'ensemble exact des tuples session->clé, pas seulement des nombres. En cas de différence de parc, recalculer le manifeste et les valeurs attendues avant de poursuivre.

Comparer l'ensemble des IDs et toutes les colonnes des68 sessions, y compris community_item_id, id_produit, lot_ids, id_format, code_session et id_securite ; préserver NULL versus chaîne vide et encodages. Comparer les lignes sources de lots, branding et participations ainsi que les opérations concernées. Les lots normalisés conservent leurs IDs et phases1/2/5. Les URL tronquées des copies phpMyAdmin ne suffisent pas pour cette comparaison : travailler sur les valeurs complètes de la copie restaurée.

Trois points de comparaison : capture avant migration ; après DDL/backfill ; après parcours de consultation. Les éventuelles écritures de logs/états Hub sont distinguées des sources métier. L'utilisateur peut effectuer des actions explicites de modification dans une série de tests séparée, à partir d'une restauration ou d'un état identifié.

Relancer le backfill : aucun nouvel ID/token/membership, aucune source modifiée. Simuler un arrêt partiel et reprendre : mêmes invariants. Conserver les preuves de la reprise, pas seulement un code retour0.

## 5. Matrice minimale des parcours

| Cas réel ou fixture dédiée | Vérification |
|---|---|
| Les58 contextes reçus | Liste complète et rattachement exact des68 sessions après reprise. |
| 824 /17-09 ;2455 /09-09 | Deux/trois sessions visibles, contexte correct, aucune oubliée. |
| 940 /08-09, sessions30121/30122 | Une session avec lots/branding propre, une sans : aucune propagation involontaire. |
| 1958 /24-09,29643/29644 | Lots proches mais différents, priorité branding session/client préservée. |
| 1959 /25-09,29631/29632 | Lots seulement sur une session, phases normalisées préservées. |
| 780 /09-09,30071 | Sans accès commercial : reprise, branding et4 participations conservés ; restrictions de gestion conformes. |
| 2436 /26-09, événement601 ;2459 /12-09,618 | Événements privés/non publiés avec sessions aux flags différents ; tester utilisateur autorisé et accès public/anonyme, sans déduire la visibilité d'un seul flag. |
| 29828 et29706 | Participation équipe et participation joueur conservées ; pas de double comptage ni conversion. |
| Jeu papier et jeu numérique | Même session et mêmes références transmises au runtime, retour et lancement corrects ; test de fumée, pas audit des contenus. |
| Deux opérations même client/date (fixture hors copie de référence) | Aucune sélection par score, comportement explicite en cas d'ambiguïté. |
| Membership absent/partiel (fixture dédiée) | Échec contrôlé ou réparation autorisée, jamais mutation silencieuse du legacy. |
| Création/ajout/déplacement après déploiement | Maintien des invariants Hub/session sur les actions futures ; ne pas limiter la validation au parc initial. |

Tester les entrées réellement exposées par main et la livraison (Pro, ancienne URL de session/événement, Games et Play, QR/Remote si concernés), les retours et rechargements. Contrôler les dates passée/jour/future et la transition de fenêtre avec une horloge de test isolée ou des fixtures : ne pas modifier les dates des68 sources pour faciliter les essais.

## 6. Basculement et retour arrière

Avant l'intervention, restituer une répétition réussie et sa durée, les SHAs livrés, la liste précise des migrations, les contrôles bloquants et les commandes opérateur adaptées à l'hébergement. Ces commandes ne sont pas encore préparées faute de configuration de l'environnement de répétition et du déploiement.

Au basculement : suspension bornée des écritures concurrentes pertinentes (programmation, participations et parcours susceptibles de muter le legacy), capture cohérente restaurable, actualisation du manifeste incluant les sessions encore en cours, DDL puis backfill puis contrôle, activation coordonnée des services/version du code, tests de fumée puis réouverture. Si les contrôles échouent, ne pas activer le nouveau parcours. Ne pas supposer qu'un flag de déploiement existe : choisir et préparer le mécanisme effectif (maintenance/routage) selon l'hébergement.

Retour arrière avant réouverture : revenir au code/configuration précédente ; les sources doivent être intactes. Les nouvelles tables peuvent rester inertes si main les ignore effectivement ; aucune suppression improvisée requise. Retour arrière après réouverture : traiter les nouvelles écritures utilisateur ; ne pas restaurer aveuglément une ancienne sauvegarde qui les perdrait. Fixer le point de décision et la stratégie de conservation avant le déploiement.

## Décision GO / NO-GO

GO seulement si le schéma complet, le backfill relançable et les parcours de la livraison exacte sont validés sur copie, sans mutation non autorisée du legacy et sans ambiguïté métier non résolue. Les défauts DEV restant atteignables sur ces chemins sont bloquants. Le protocole ne prouve pas encore ces résultats : c'est la prochaine phase à réaliser.
