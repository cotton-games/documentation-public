# Audit initial PROD legacy → Hub — cadrage corrigé

Date : 8 septembre 2026. Cette note remplace le cadrage et les PRE Hub du précédent pack. Les défauts du runtime DEV restent des constats séparés. Aucun SQL de ce pack n'a été exécuté en PROD ; aucun DDL, patch, commit ou déploiement n'a été effectué pour cette révision.

## 1. Faits et références

Faits communiqués par l'exploitant : PROD est entièrement legacy ; aucune table, racine, membership ou donnée du nouveau parcours Hub n'existe. Le serveur est `10.3.39-MariaDB-log`. phpMyAdmin peut sélectionner `information_schema` par défaut. Toutes les tables métier sont donc explicitement qualifiées par `prod_cotton_global_0` ; les filtres de métadonnées utilisent ce même nom littéral.

Conformément au complément utilisateur, les branches **main des repos du workspace sont la référence du code déployé en PROD**. Elles ont été lues par `git show main:...`, sans checkout. L'analyse des clés s'appuie notamment sur :

- Global main `5ec94b28a99830e4ccfb7e85b9e0d27234d6a344` : sessions, événements et offres.
- Pro main `f5af07280eed17210353956060b52f11c9b68dd8` : programmation par date et pivots.
- Le code Hub DEV est identifié séparément par les HEAD dans [references-git.json](references-git.json). Les références main de tous les repos y figurent aussi ; cela ne signifie pas qu'un audit exhaustif de chaque ligne de chaque repo a été refait.

Les extraits déterminants, avec lignes et commits, sont dans [PREUVES-MAIN.md](PREUVES-MAIN.md). Le schéma documentaire reste une hypothèse à confronter aux SHOW CREATE PROD, pas une preuve du schéma réel.

Références documentaires corroborantes : [Global main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/global/README.md), sections « Etat 2026-06-22 - Evenements pivot: isolation par date cible » et « Etat 2026-06-18 - Evenements pivot gamification managés » ; [Pro main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/repos/pro/README.md), sections « Etat 2026-06-25 - Programmation agenda: date/pivot d'abord » et « Etat 2026-06-26 - Agenda/widgets: dates deja programmees ouvrables » ; [DDL main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/canon/data/schema/DDL.sql), définitions des tables legacy. Le code main prime sur ces documents.

## 1 bis. Code présent, chemin actif, héritage : distinction vérifiée

La lecture ne s’arrête pas aux noms de fonctions. Sur **Pro main** :

- `web/.htaccess:209–213` contient les routes non commentées `/extranet/start/games/day/...` vers `ec.php?t=tunnel&m=start&p=sessions_day`, ainsi que le script événement.
- `web/ec/ec.php:15` charge les bibliothèques Global ; `:443`, `:579`, `:1236` incluent le module selon la branche d’affichage et les contrôles d’accès. Global main `web/global_librairies.php:19,30,32` charge offres, sessions et événements.
- Le module `ec_start_sessions_day.php:50–112` lit les sessions par client/date puis, sous conditions date présente/future et usage 2, appelle effectivement le pivot. Ce n’est pas une fonction isolée sans appelant.
- `web/.htaccess:173–174` route le script start ; `web/ec/do_script.php` distribue au module après contrôle de session. Le cas `sessions_day_create` (`ec_start_script.php:1471–1535`) vérifie la date occupée puis peut créer un pivot vide. Ces comportements sont encore atteignables dans main.
- `web/ec/ec.php:85–101` appelle le resolver d’offre effective et dérive les variables d’accès legacy de son résultat : les anciens compteurs seuls ne décrivent pas le contrat commercial actuel.
- En revanche, l’appel `app_evenement_client_affiliation_ajouter` trouvé dans `ec_client_script.php:722` est **dans un commentaire**. Il ne prouve pas qu’une nouvelle affiliation événement est encore créée par l’inscription courante. Les anciennes données restent dans le périmètre à inventorier.

Voir les extraits ajoutés à PREUVES-MAIN. « Atteignable sur main » est une preuve statique de routage et d’appel, sous les conditions du code. Cela ne mesure pas la fréquentation réelle, les configurations serveur externes ni les branches effectivement traversées par chaque compte. Aucun accès utilisateur PROD n’a été simulé : ouvrir certaines pages pourrait déclencher les mutations que cet audit évite. Les parcours legacy conservés ne sont pas tous obsolètes ; les blocs commentés ne sont pas utilisés comme preuve du fonctionnement courant.

## 2. Verdict séparé

**A — Runtime DEV : NON COMPATIBLE AVANT CORRECTIF reste applicable.** Les anciennes entrées ne garantissent pas toutes la création d'une racine ; la réconciliation peut être partielle ; le choix pondéré entre racines d'une date n'est pas une clé métier ; certains chemins de bootstrap peuvent muter les sessions. Le backfill initial ne prouve pas, à lui seul, la compatibilité de toutes les routes après activation.

**B — Migration initiale : aucun ancien conflit Hub à résoudre.** Il faut calculer une projection complète des sources legacy, puis créer explicitement les racines et memberships. Des conflits pourraient être *produits* par un mauvais backfill ou par le runtime après activation ; ils ne préexistent pas en PROD.

Le backfill déterministe avant activation devient la stratégie de référence. Aucune raison technique démontrée de préférer le lazy bootstrap n'a été trouvée. Le lazy ne garantit ni la couverture avant le premier accès ni une décision métier stable en présence d'ambiguïtés. Une offre expirée, une offre référencée à zéro ou l'absence d'accès récent ne doivent pas exclure une programmation de l'inventaire ou de sa conservation.

## 3. Unité legacy et clé cible

| Source | Preuve main | Clé candidate dans le modèle Hub DEV | Condition / limite |
|---|---|---|---|
| Soirée standard sans opération (`id_operation_evenement = 0`) | Pro `ec_start_sessions_day.php:50–63` sélectionne toutes les sessions officielles complètes du client à la date. Les helpers de création considèrent une date déjà programmée comme occupée. | `(id_client, date, 'soiree', 0)` | Prouvé pour l'unité de navigation legacy ; vérifier qu'il s'agit effectivement d'une soirée et qu'aucun contexte distinct non marqué n'est mélangé. |
| Événement positif | Global `app_evenement_sessions_get_count:810` agrège par opération, sans restriction de client/date. La création `:642` accepte une période. | `(session.id_client, session.date, 'event', id_operation_evenement)` | Partition compatible avec les dimensions d'une racine quotidienne DEV ; validation métier et des routes nécessaire si opération multi-jours ou multi-clients. |
| Pivot événement quotidien géré | Global `app_evenement_pivot_slug_get:156` et validations `:167–219` : slug client/date et période quotidienne. | Même clé événement, après concordance propriétaire/date/slug/références | Ne pas convertir arbitrairement un pivot en soirée ni le recréer via un helper mutable. |
| Opération NULL/négative, client absent, date invalide, événement introuvable, contexte non identifié | Aucun contrat de regroupement certain trouvé | Aucune attribution automatique | Mettre en rapport d'exception, conserver la source intacte. |

### Soirées distinctes le même jour

Plusieurs sessions pour un client et une date sont normales : ce n'est pas un doublon en soi. Aucun identifiant de soirée indépendante n'a été trouvé dans les champs documentés de session. Si plusieurs vraies soirées sans opération sont historiquement distinguées autrement, le regroupement client/date seul ne sait pas le restituer : il faudra identifier leur marqueur métier. Ni l'heure, ni le nom, ni l'offre, ni le premier ID ne constituent une preuve de séparation.

Le wording legacy (`ec_start_sessions_day_helpers.php:106`) traite l'usage 2 comme événement, les typologies 1/4/5/6/8 comme lieu public, et les autres comme animation. Les caractéristiques *actuelles* du client sont des indices, pas une preuve historique. Une session sans opération sur un compte événement, ou une date mélangeant opération zéro et opérations positives, doit donc être examinée. NULL n'est pas normalisé silencieusement en zéro.

### Événements : l'identifiant seul ne suffit pas pour la racine DEV

Une opération legacy peut couvrir plusieurs dates. Elle peut aussi appartenir à un autre client que la session : **`app_evenement_client_affiliation_ajouter:775–804` crée une offre pour un client affilié en conservant l'identifiant de l'opération**. Le helper existe, mais son appel trouvé dans l’inscription Pro est commenté depuis le 30/09/2025 (`ec_client_script.php:718–735`). Il constitue une piste historique, PAS une preuve d’un parcours d’affiliation actuellement actif. Des données héritées peuvent subsister : une différence de client ne doit pas être étiquetée automatiquement comme corruption, et doit être étayée par les données. L'offre et la délégation donnent des éléments de preuve d'affiliation, même si elles sont aujourd'hui inactives.

Le modèle DEV utilise une racine client/date/contexte/opération et une fenêtre temporelle quotidienne. Une seule racine par opération n'est donc pas un contrat universel compatible. À l'inverse, produire plusieurs racines quotidiennes pour une même opération ne garantit pas les anciennes routes : `app_games_hubs_get_for_event:5179` attend une seule racine active pour l'opération, et les vues Pro naviguent principalement par client/date. Il faut vérifier ces surfaces avant de valider les cas multi-jours, multi-clients ou plusieurs opérations le même jour.

Les pivots acceptent certaines variantes de slug à suffixes dans `detail_is_managed`, alors que `detail_matches_day` exige un slug exact : les divergences sont à rapporter, sans réécriture automatique. Les événements futurs sans session sont inventoriés, car le legacy peut créer un pivot vide ; leur éligibilité et leur date cible ne se déduisent pas d'une session inexistante. Un événement vide sur plusieurs jours ne doit pas engendrer automatiquement une racine par jour sans contrat confirmé.

Le champ `id_evenement` est inventorié séparément : aucune preuve n'autorise à l'utiliser comme substitut de `id_operation_evenement`. Dans `app_session_ajouter:2720`, l'affectation historique opération depuis offre est commentée : ne pas la réintroduire comme fallback du backfill.

## 4. Helpers à ne pas utiliser pour effectuer cette projection

Constats dans Global DEV `web/app/modules/jeux/hubs/app_games_hubs_functions.php` :

- `canonical_existing_for_context:2318` et `get_or_create_for_context:2403` peuvent privilégier une racine existante de la date par score. Même en partant de zéro, le traitement de la deuxième partition d'une date peut donc réutiliser la première.
- `reconcile:2654` s'arrête lorsqu'un membership actif existe déjà ; sinon son rattachement historique par client/date peut englober plusieurs opérations. Il ne constitue pas un backfill exhaustif par clé explicite.
- `session_membership_ensure:2764` contrôle client/date/opération et configuration, mais l'unicité du couple Hub/session ne prouve pas l'unicité globale d'affectation d'une session.
- `sessions_get:2914` lit les memberships explicites : ils doivent être complets avant activation.

Dans Global **main**, les helpers de pivot `sessions_attach_for_day:248`, `sessions_detach_for_day:271` et `pivot_ensure_for_day:431` peuvent modifier `championnats_sessions`. Ils ne conviennent pas à une migration dont le legacy est exclusivement une source de lecture. Même appeler certains helpers commerciaux n'est pas un diagnostic strictement readonly : la résolution de l'offre réseau peut compléter un slug catalogue.

Ces observations fondent des contraintes de migration ; aucun patch ou script d'écriture n'est proposé ici.

## 5. Pack SQL et ordre d'exécution

1. **Exécuter maintenant [00-schema-legacy.sql](00-schema-legacy.sql)**. Il lit version, fuseaux, mode SQL, tables/colonnes/index legacy et les SHOW CREATE des cinq tables centrales. La dernière grille fournit du texte SHOW CREATE pour les seules tables présentes. Il ne cherche aucune table Hub. Une table optionnelle absente est un résultat exploitable.
2. Après vérification des noms et colonnes PROD, exécuter [01-inventaire-contextes.sql](01-inventaire-contextes.sql) et [02-offres.sql](02-offres.sql), puis les blocs applicables de [03-donnees-metier-optionnel.sql](03-donnees-metier-optionnel.sql). Ces fichiers sont préparés sur le schéma documenté ; ne pas interpréter une erreur de colonne comme un zéro.
3. Exporter **toutes les lignes de chaque résultat**, et conserver les identifiants I01…M05 dans les noms d'export. Pas uniquement la première page phpMyAdmin. En cas d'erreur, transmettre son texte et le bloc concerné ; ne pas substituer une autre colonne au hasard.

La date `2026-09-08` est une référence figée, inclusive, sans borne future supérieure. Si le basculement est ultérieur, remplacer toutes ses occurrences ensemble et garder cette même référence pour les comparaisons. I08 isole la veille : la fenêtre DEV peut aller jusqu'à midi J+1, donc les sessions encore actives devront être intégrées au périmètre réel. I07 conserve le diagnostic des dates invalides et des statuts exclus.

I01 compte les sessions officielles futures **avec configurations incomplètes incluses**, puis distingue les complètes, actuellement admissibles au membership DEV. I02 compte des partitions candidates ; I03 et I05 permettent une affectation explicite ultérieure. I09 inclut les événements futurs sans session. On ne peut pas encore annoncer un nombre final de Hubs avant les résultats et les arbitrages.

O01 distingue référence zéro, NULL, positive absente, positive état 3, positive autre état. Les comptes peuvent figurer dans plusieurs classes de sessions : leurs comptes ne s'additionnent pas. O03 fournit un décompte commercial **brut** des comptes avec/sans offre liée état 3. Ce n'est pas un calcul complet des droits effectifs : offres propres, support réseau, contrats, affiliations et délégations doivent être confrontés au resolver main (`app_ecommerce_offre_effective_get_context:13798`). Les métadonnées réseau demandées permettront de préparer ce complément sans supposer des colonnes. Aucune sélection commerciale ne filtre les sessions à reprendre.

I06 conserve les codes produit/support/format bruts. Le code main distingue Quiz (1/5), Bingo (2/3/6), Blind Test (4) ; les autres codes restent à classifier. Le flag de contrôle numérique est un indice explicite, mais certaines vues dérivent le support du produit ou de la playlist client (`app_sessions_functions.php:4426–4591`). Il faut donc confronter les playlists pour certifier le support effectif ; `id_format` n'est pas un flag papier.

M01–M05 recensent publication, contenus, lots, branding et participations sans choisir une valeur parmi plusieurs. Différences entre sessions d'un même contexte ne justifient ni écrasement ni choix par ID. Le premier pack compte les participations par session/source et joueurs/équipes ; une preuve d'identité intégrale PRE/POST demandera ensuite un export contrôlé complet des données source.

Le branding d'événement comprend aussi des fichiers sous `/upload/www/images/operations/evenements_branding/{seo_slug}/`, notamment `file_parameters.txt` et des images (Global `app_evenements_branding_functions.php:58–134`). Le SQL ne peut pas prouver leur présence ni leur conservation. Leurs slugs issus d'I09 serviront à un inventaire des fichiers. Le schéma des catalogues/playlist est demandé dès 00 ; les requêtes de contenu exactes suivront une fois vérifié.

## 6. Séquence de référence et conditions d'intégrité

Inventaire complet → schéma Hub complet correspondant au code à livrer → backfill explicite → contrôles → activation. Le schéma cible et le SQL POST sont une phase ultérieure ; l'ancien PRE qui attendait des Hubs existants ne doit pas être exécuté comme prérequis de cette phase.

Le manifeste à construire à partir des résultats devra affecter chaque session éligible à exactement une clé validée, sans LIMIT, score ou choix arbitraire. Les cas retenus hors reprise automatique restent identifiés individuellement avec raison et décision à obtenir ; ils ne disparaissent pas du total. Le nombre de Hubs validé sera le nombre de clés approuvées, augmenté seulement des contextes vides explicitement admis.

Les contrôles ultérieurs devront prouver : couverture exacte du manifeste ; une seule appartenance active par session reprise ; une racine par clé ; absence d'orphelins ; conservation de l'ensemble des sessions et de tous leurs champs historiques, lots, participations et références ; conservation des contenus et assets ; restitution par les anciennes routes et par le nouveau parcours, y compris comptes sans offre active et contextes jamais ouverts avant migration. Les ensembles d'identifiants et valeurs complètes doivent être comparés : un simple COUNT ne suffit pas.

Le schéma documentaire est en partie MyISAM : plusieurs SELECT successifs ne donnent pas nécessairement un instantané atomique si PROD continue à écrire. L'inventaire peut être exploratoire ; la preuve finale nécessitera une capture cohérente et une gestion explicite des écritures intervenues avant activation. Le pack ne verrouille rien et n'effectue aucune transaction d'écriture.

## 7. Résultats nécessaires et limites de validation

À transmettre d'abord : toutes les grilles de 00 et les SHOW CREATE des tables présentes. Ensuite : I01–I10, O01–O04 et les blocs M disponibles. Les données permettront de chiffrer soirées candidates, partitions événement, contextes sans session et exceptions. Si des soirées distinctes sans opération coexistent un même jour, leur marqueur métier devra être fourni ; il n'est pas démontré dans le modèle lu.

À compléter après ce premier retour : droits effectifs réseau ; détails des produits/playlists ; événements sans période valide et pivots vides dont seul le slug indiquerait une date ; inventaire des assets ; règle des contextes ambigus et des sessions incomplètes ; date/heure précise du basculement.

Validation de cette révision : lecture du code main/DEV et du DDL documentaire ; contrôle statique des instructions SQL en lecture seule et de la qualification des tables. Syntaxe limitée à SELECT/SHOW, sous-requêtes, agrégats et fonctions disponibles dans MariaDB 10.3. **Pas de test d'exécution sur MariaDB 10.3 ni de connexion PROD pour ce pack.** Le test local 10.11 du précédent audit ne valide pas ces nouveaux fichiers. Aucune modification du code applicatif ; seuls les livrables de ce dossier sont créés. Leur suppression suffit à retirer ces nouveaux artefacts.
