# Résultats PROD reçus — 8 septembre 2026

Les 16 tables demandées sont présentes, selon la grille transmise par l’utilisateur. Contrats réseau et affiliations : InnoDB/utf8_general_ci ; general_branding : InnoDB/latin1_swedish_ci ; les 13 autres : MyISAM/utf8_general_ci.

Structure championnats_sessions reçue via onglet Structure : 53 colonnes. Les 52 noms de colonnes du DDL main documentaire sont présents. Une colonne supplémentaire existe : community_item_id, int(10) UNSIGNED, nullable, défaut NULL, indexée. Elle doit être conservée dans la preuve de non-mutation PRE/POST ; son rôle et ses consommateurs restent à vérifier. Aucun usage trouvé dans le fichier de fonctions sessions Global main inspecté ; cela ne prouve pas son absence d’usage ailleurs.

id_offre_client, id_operation_evenement et date sont NOT NULL : les cas NULL correspondants ne sont pas attendus dans cette table. Les références zéro, négatives ou orphelines restent à mesurer. Les colonnes requises côté sessions par le pack sont présentes ; les jointures ne sont pas encore validées, faute des structures des autres tables.

Prochaine structure demandée : operations_evenements, par le même onglet Structure. Aucun SQL exécuté ni code applicatif modifié.

## Structures complémentaires reçues

operations_evenements : 38 colonnes transmises dans la conversation ; champs requis par 01 présents, dates début/fin DATETIME NOT NULL.

clients : 94 colonnes reçues via onglet Structure. Vérification automatique des références c.* du fichier 01 : id, id_solution_usage, id_typologie, id_client_reseau, flag_client_reseau_siege toutes présentes. Les trois structures nécessaires au fichier 01 sont désormais reçues ; aucune exécution PROD effectuée. Les structures commerciales et métier supplémentaires restent à recevoir pour les fichiers 02/03.

## Premier comptage exécuté en PROD par l’utilisateur

Périmètre : flag_session_demo = 0 et date >= 2026-09-08, sans filtre commercial ni publication. Résultat transmis : 68 sessions officielles futures ; 18 clients distincts ; 68 configurations complètes ; 0 incomplète ; 64 sessions avec opération zéro ; 4 sessions avec opération positive ; 2 opérations positives distinctes. Les catégories zéro/positive couvrent les 68 sessions de ce périmètre. Ces totaux ne déterminent pas encore le nombre de Hubs : regroupement client/date/opération et validation des contextes à poursuivre.

## Regroupement PROD transmis — 58 partitions

58 partitions client/date/opération, total 68 sessions : 56 partitions sans opération (64 sessions, 16 clients, tous usage 1 / typologie 1), et 2 partitions événement (4 sessions, 2 clients usage 2 / typologie 12). Les 18 clients sont retrouvés. Aucun couple client/date ne comporte plusieurs partitions dans le résultat transmis.

Événement 601 : client 2436, 2026-09-26, 2 sessions. Événement 618 : client 2459, 2026-09-12, 2 sessions. Les propriétés des opérations elles-mêmes restent à vérifier.

Soirées comportant plusieurs sessions : 824 / 2026-09-17 (2), 940 / 2026-09-08 (2), 1958 / 2026-09-24 (2), 1959 / 2026-09-25 (2), 2437 / 2026-09-10 (2), 2454 / 2026-09-09 (2), 2455 / 2026-09-09 (3). Cette multiplicité est cohérente avec le regroupement quotidien legacy, sans prouver à elle seule la compatibilité des contenus Hub-scoped.

58 est un nombre candidat pour les contextes ayant des sessions officielles futures, pas un total de migration validé. Restent notamment : événements futurs sans session, propriétés des événements 601/618, conflits de contenu/branding/publication, offre effective, sessions encore actives de la veille et contrôle des dates invalides. Aucun SQL exécuté par l’agent.

## Propriétés des événements 601 et 618 confirmées en PROD

601 : propriétaire 2436, début et fin 2026-09-26 00:00:00, slug cotton-event-2436-20260926. 618 : propriétaire 2459, début et fin 2026-09-12 00:00:00, slug cotton-event-2459-20260912. Tous deux : flag_evenement_demo=0, flag_evenement_prive=1, online=0.

Concordance exacte propriétaire/date/slug avec les deux partitions de sessions reçues : aucune ambiguïté de ces dimensions pour ces deux racines candidates. Préserver le caractère privé et l'état non publié ; ne pas utiliser online=0 comme exclusion structurelle. Cette concordance ne valide pas encore les contenus, flags de session, accès ou routes. Le total reste 56 soirées + 2 événements pour les contextes avec sessions officielles futures ; recherche des événements sans session officielle future à poursuivre.

## Recherche d’événements futurs sans session officielle future

Résultat PROD transmis : zéro ligne pour les opérations demo=0 dont date_debut ou date_fin >= 2026-09-08 et sans session demo=0 à compter de cette date. Aucun contexte supplémentaire identifié par ce contrôle ; total candidat inchangé : 58 contextes / 68 sessions.

Limite : ce contrôle repose sur les périodes enregistrées ; il ne couvre pas les pivots vides à dates nulles/zéro/invalides dont seul le slug indiquerait une programmation future. Le statut de migration reste provisoire, avant validation des données métier et des autres exceptions.

## Répartition jeux / flags / références d’offre — résultat PROD

9 lignes agrégées, total 68 : type 4 (Blind Test) 32 ; type 5 (Quiz) 19 ; type 6 (Bingo) 17. Contrôle numérique flag=1 : 50 ; flag=0 : 18 (14 Quiz et 4 Bingo). Il s’agit des flags session, pas encore de la certification du support effectif dérivé par chaque runtime.

58 sessions ont une référence d’offre positive, 10 une référence zéro, aucune négative. Cela ne mesure ni les droits effectifs ni le nombre de comptes sans offre active.

Toutes les 68 sessions ont flag_session_privee=0 et online=1. Par conséquent les quatre sessions des événements 601/618 ont aussi ces valeurs, alors que les opérations parentes ont flag_evenement_prive=1 et online=0. Différence entre scopes démontrée ; aucune conclusion automatique de corruption ou de visibilité effective. Vérifier la priorité des flags dans les routes actives main puis DEV, et préserver les valeurs source ; aucune uniformisation autorisée.

## Structure ecommerce_offres_to_clients reçue

43 colonnes transmises via Structure. Champs nécessaires au contrôle des références présents : id (clé primaire), id_client, id_client_delegation, id_offre, id_etat, id_operation_evenement, date_debut/date_fin, online et références réseau. Deux colonnes supplémentaires par rapport au DDL main consulté : id_remise SMALLINT UNSIGNED nullable défaut NULL ; prix_reference_ht DECIMAL(8,2) NOT NULL défaut 0.00. Aucun contenu commercial encore reçu ; le statut des 58 références positives reste à déterminer. Le contrôle suivant porte sur l’offre référencée par la session, pas sur les droits effectifs du compte.

## État des offres référencées — résultat PROD

58 sessions / 13 clients : offre référencée trouvée, id_etat=3. 10 sessions / 5 clients : référence zéro, aucune ligne offre jointe. Aucune référence positive introuvable, aucune référence négative, aucune référence positive dans un autre état observée dans ce périmètre. Les 13+5 clients couvrent les 18 clients du total : les groupes sont disjoints dans les résultats transmis, sous réserve de stabilité du parc entre requêtes.

Aucune session future liée à une ancienne offre positive non active n’est observée ici ; cela ne constitue pas un test de compatibilité de ce scénario. Une référence zéro ne signifie pas absence de droits effectifs. Prochain contrôle : offres propres/déléguées et contexte réseau des cinq comptes concernés, sans choisir arbitrairement une offre ni filtrer les sessions de la reprise.

## Cinq comptes avec sessions à référence offre zéro — offres liées reçues

780 : réseau 92, non siège ; offres propres 870/catalogue10, 1059/catalogue2, 1492/catalogue2, toutes état4 ; aucune délégation ni référence support source. Dernière fin affichée 2026-02-06. Accès réseau non encore déterminé.
2436 : réseau0, non siège, aucune offre propre/déléguée retournée.
2454 : réseau0, non siège ; deux offres propres 2690 et 2691, catalogue12, état2, début2026-09-04, fin0000-00-00. Aucune sélection arbitraire, aucun doublon métier déclaré sur ces seuls champs ; dates zéro à conserver et interpréter selon le runtime.
2455 et 2459 : réseau0, non siège, aucune offre propre/déléguée retournée.

Aucune offre liée état3 pour ces cinq comptes. Les deux événements 601/618 appartiennent à des comptes sans offre liée retournée (2436/2459). Le cas 780 exige encore la lecture du contrat réseau92. Le backfill doit conserver les dix sessions concernées indépendamment des droits d’accès ; aucune offre ou référence de session à réécrire. Structures contrats réseau/affiliations demandées pour poursuivre le calcul sans supposer les colonnes PROD.

## Structures réseau reçues

Les deux tables réseau comptent chacune 12 colonnes dans les structures transmises. Champs contrat (id_client_siege, id_offre_client_contrat, online) et affiliation (id_contrat_reseau, id_client_affilie, activation_state, mode_facturation, id_offre_client_deleguee) confirmés. Fichier 04-reseau-780.sql préparé uniquement en SELECT, sur ces colonnes ; aucune exécution par l’agent. Le contrôle conserve tous les contrats du siège92 et toutes les affiliations de780, même vers un autre siège ou une référence manquante. Ne constitue pas encore le calcul complet du resolver effectif main (fallback/catalogue à confronter selon résultats).

## Retour réseau780 : aucun contrat ni affiliation

Les deux SELECT ont retourné zéro ligne : aucun contrat dont id_client_siege=92 et aucune affiliation dont id_client_affilie=780. Relecture du resolver Global main app_ecommerce_offre_effective_get_context (13798 et suivantes) : fallback legacy présent si contrat absent, mais il requiert une offre déléguée du siège vers le client pour accorder l’accès réseau. Le précédent inventaire exhaustif des offres propres OU déléguées vers780 n’en a retourné aucune, et aucune offre propre état3. Donc access_state=inactive pour780 d’après ce code et les données reçues, même si le siège a des délégations actives vers d’autres clients. Aucune fonction PHP exécutée.

Les cinq clients à référence zéro (780,2436,2454,2455,2459) sont donc classés sans accès commercial effectif par ce resolver, sous réserve de stabilité des données entre requêtes. Cela n’est pas une affirmation d’interdiction de toute route legacy (droits de route distincts). Leurs dix sessions doivent rester dans le backfill. Les treize autres comptes ont des références état3 ; leur classification effective complète exige encore propriétaire/délégation et exclusion catalogue support, pas uniquement l’état de la référence.

## Structure catalogue ecommerce_offres reçue

29 colonnes transmises. Champs id, nom, seo_slug, id_offre_type confirmés, ce dernier nullable. Les champs nécessaires à 02-offres.sql sont présents. Contrôle complémentaire 05 préparé : toutes les offres liées état3 pour les18 clients (clients sans offre conservés), propriétaire/délégation, existence catalogue, et toutes les correspondances catalogue support réseau. Aucune offre choisie par ID, aucun helper PHP appelé, aucun SQL exécuté par l’agent.

## Classification commerciale consolidée — résultats PROD

18 lignes, une par client : 13 clients avec exactement une offre liée état3, tous propriétaires de cette offre avec id_client_delegation=0 et catalogue existant. Catalogue12 pour12 clients ; catalogue9 pour1909. Les deux sont des abonnements type2. Recherche de tous les candidats support réseau : seule ligne17 / Abonnement réseau / abonnement-reseau / type2 ; aucune correspondance contrat-cadre-reseau ni autre correspondance par nom retournée. Les catalogues9/12 ne sont donc pas exclus comme support par le resolver main.

Clients avec offre propre active : 3,154,567,571,802,824,940,947,1909,1958,1959,2170,2437. Les affiliations réseau92 de certains de ces comptes ne suppriment pas la priorité de leur offre propre.

Clients sans accès commercial effectif selon main et les données reçues : 780,2436,2454,2455,2459. Croisement avec le regroupement reçu : 53 contextes / 58 sessions sur les13 comptes avec offre propre active ; 5 contextes / 10 sessions sur les5 autres (3 soirées /6 sessions, 2 événements /4 sessions). Total58 contextes /68 sessions à préserver. Ce constat commercial n’est pas une validation des routes ni de la fidélité de projection des contenus.

Suite : lots intégrés et normalisés, branding/héritage/flags public-privé, participations probables et détails de jeux. Aucune migration exécutée.

## Structures lots, branding et participations reçues

championnats_sessions_lots :22 colonnes, référence session et phase_numero présentes. general_branding :25 colonnes ; valable_jusqu_au, online et date_ajout présents, textes latin1_swedish_ci. participations_probables :10 colonnes, références session/joueur/équipe et source présentes. Les champs requis sont disponibles.

Le contrôle06 est préparé : lots intégrés et comptages normalisés/participations par session sans jointure multiplicative ; toutes les lignes de branding des scopes session/événement/réseau/client, sans exclusion des lignes expirées/inactives. Main Global general/branding/app_branding_functions.php relu : mapping1/2/3/4 et cas siège réseau confirmés ; validité et priorité devront être interprétées dans les lecteurs actifs, pas déduites du seul inventaire. Les comptes du parc sont tous non-sièges selon le résultat commercial reçu. Aucune exécution SQL par l’agent.

## Lots et participations — 68 lignes PROD reçues

13 sessions avec 3 lots normalisés chacune : 29668,29669,29670,29706,29976,29978,29979,29913,29914,29915,29916,29632,29756. Total39 lignes, contenu détaillé encore à recevoir. Ces13 sessions portent aussi les libellés intégrés Lot #1 / Lot #2 / Gros lot ; ne pas compter deux ensembles indépendants ni conclure à une identité des deux représentations avant contrôle.

4 autres sessions ont des lots intégrés sans ligne normalisée :30071 (GOODIES trois fois),30121 (1ᵉʳ prix / 2ᵉ prix / Rien),29643 et29644 (consommations/saucisson, libellés distincts). Total17 sessions avec lot_1/2/3 renseignés,51 toutes NULL. Ne pas traiter « Rien » comme absence de donnée.

Différences dans une même soirée : client940 /2026-09-08 :30121 renseignée,30122 NULL ; client1958 /2026-09-24 :29643/29644 libellés proches mais non identiques ; client1959 /2026-09-25 :29631 NULL,29632 renseignée et3 lots normalisés. Pas de sélection par première session, normalisation textuelle ni écrasement autorisé. Clé quotidienne distincte du contrat de projection des lots au niveau Hub.

Participations probables :29828=1,29706=1,30071=4 ; total6 lignes sur3 sessions/contextes. 30071 appartient au client780 sans accès commercial effectif. Ces6 lignes ne prouvent pas6 personnes distinctes : source et références joueur/équipe à contrôler, sans exposer leurs identifiants dans le premier diagnostic. Aucune écriture.

## Détail des39 lots normalisés reçu

Les13 sessions ont chacune trois lignes distinctes : phase1 « Lot #1 », phase2 « Lot #2 », phase5 « Gros lot ». Les intitulés correspondent aux trois champs intégrés des sessions précédemment reçues, mais la troisième valeur est rattachée à la phase5, pas3. Aucune renumérotation autorisée.

Pour toutes les lignes affichées : descriptif_court/descriptif_long/lien_url/lien_libelle/video_code apparaissent vides ; lien_target=0, online=0, position=0. Ce résultat ne prouve pas la visibilité effective ni une équivalence complète entre stockages (identifiants, phases, champs non sélectionnés conservés). Ne pas supprimer les lignes online0 ni dédupliquer les39 lots entre sessions. Les divergences des soirées940/1958/1959 et les4 sessions avec lots intégrés seuls demeurent à traiter dans le contrat de projection. Suite : inventaire branding des scopes legacy applicables.

## Branding réseau/clients/événements — résultat ciblé

La requête corrélée de branding a été signalée très lente par l’utilisateur ; son remplacement par des identifiants connus a répondu en0,0012s. Utiliser les requêtes ciblées pour cet inventaire figé, pas relancer le bloc branding corrélé de06/03. Nouveau fichier07 pour les68 IDs de sessions transmis (68 identifiants uniques vérifiés).

5 lignes : réseau92 ->1370 ; client3 ->815 ; client567 ->1376 ; client1958 ->884 ; client1959 ->644. Toutes online1 et valable_jusqu_au=NULL ; aucun doublon de scope/référence dans ce résultat. Aucun branding type2 pour601/618, ce qui ne prouve pas l’absence d’assets événement externes ni d’ancien clients_branding. Coexistence réseau92/client567, avec couleur de police client renseignée et réseau vide : hiérarchie/complétion à vérifier dans les lecteurs actifs avant projection.

Polices Open Sans pour3, Poppins pour les autres. Les font_family_url affichées sont tronquées avec points de suspension ; elles ne constituent pas une copie complète suffisante pour une preuve de conservation. Données complètes nécessaires lors de la capture PRE. Prochain résultat : branding propre aux68 sessions.

## Branding sessions — résultat PROD ciblé

4 lignes type1 :1683->29643,1684->29644,1720->30071,1732->30121. Toutes online1, valable_jusqu_au=NULL. Couleurs affichées identiques : fond1#ede0c4, police1#000000, fond2#307672, police2 vide ; Poppins. Aucun doublon par session. URL de police tronquées : égalité complète non prouvée.

Total general_branding applicable inventorié :9 lignes (4 session,4 client,1 réseau,0 événement). Client1958 : ses2 sessions ont un branding propre dont les couleurs diffèrent du branding client884. Client940 :30121 a un branding propre,30122 n’en a pas ; réseau92 également présent. Client780 :30071 porte un branding propre malgré absence d’accès commercial effectif. La projection doit conserver les surcharges et l’héritage, pas remplacer les9 lignes par une valeur de soirée arbitraire. Ancien clients_branding et assets externes restent hors de cette preuve.

Suite immédiate : qualifier les6 lignes de participations probables par session/source et forme joueur/équipe, sans identifiants personnels. Les compteurs ne prouvent pas une identité PRE/POST complète.

## Qualification des6 participations probables reçue

29706 : source play,1 ligne,1 joueur distinct,0 équipe. 29828 : source play,1 ligne,0 joueur,1 équipe distincte. 30071 : source play,4 lignes,4 joueurs distincts,0 équipe. Aucun enregistrement avec les deux références zéro ou les deux positives dans ces résultats. Les lignes individuelles totalisent5 ; ne pas annoncer5 personnes uniques globalement, l’identité entre sessions n’a pas été comparée. Une ligne équipe à conserver explicitement ; les4 lignes de30071 concernent le compte780 sans accès commercial effectif.

Les compteurs ne prouvent pas l’existence des entités référencées ni l’identité complète PRE/POST. Préserver source, type de référence et rattachement session ; aucune conversion équipe->joueur, déduplication inter-session ou exclusion commerciale. Contrôle suivant : présence de données dans l’ancien stockage clients_branding ; sa structure n’a pas encore été reçue.

## Ancien stockage clients_branding

Comptage global transmis :9 lignes. Structure reçue :24 colonnes, id_client indexé NOT NULL, id_operation_evenement indexé nullable, textes utf8_general_ci, online et date_ajout présents. Requête08 ciblée préparée, sans jointure, incluant les18 clients, le siège92 et les opérations601/618 ; conserve les lignes offline et les valeurs NULL. Les correspondances éventuelles ne prouvent pas leur utilisation active : les consommateurs main restent à confronter. Aucun SQL exécuté par l’agent.

## Ancien branding ciblé : zéro correspondance

Résultat PROD transmis :0 ligne dans clients_branding pour les18 clients, siège92 ou opérations601/618. Les9 lignes globales de cet ancien stockage n’apportent donc aucune correspondance à ces références. Ne pas supprimer ces données hors périmètre. L’inventaire general_branding reste9 lignes applicables ; assets externes et URL complètes restent à vérifier.

Suite : références produit/format/support et lot_ids des68 sessions, afin de cibler les contrôles de contenu sans scan corrélé. lot_ids désigne les références de contenus Quiz selon le lecteur main, pas les lots gagnants lot_1/2/3.

## Références de contenus reçues —59 combinaisons /68 sessions

Blind Test type4 :32 sessions,23 id_produit distincts, format2/contrôle numérique1, lot_ids NULL. Bingo type6 :17 sessions,17 id_produit distincts, format2,13 contrôle1/4 contrôle0, lot_ids NULL. Quiz type5 :19 sessions,19 combinaisons, lot_ids toujours renseigné ;14 contrôle0 avec3 tokensT suivis d’unL,5 contrôle1 avec tokensL seuls. Deux variantes du produit246 (L246 et L246,L87,L9,L175) : id_produit seul ne suffit pas à préserver la composition. Ne pas interpréter format0 comme anomalie sans contrat.

Les tokensT transmis couvrent les42 identifiants209 à250, chacun une fois. Relecture Global main app_cotton_quiz_functions.php:2793+ : T via qz_temp_lot_get_detail, L via app_cotton_quiz_serie_lot_get_detail (questions_lots). app_sessions_functions.php:363–435 résout T via questions_lots_temp.question_ids JSON, L via questions.id_lot. Cette table temporaire au sens métier est une dépendance persistée de sessions futures : ne pas purger sur la base du nom. Les contrôles de lecture complets du runtime jeu et l’existence des références restent à terminer ; pas de preuve que la table PROD questions_lots_temp existe à ce stade. Ajout requis au préflight initial, qui n’inventoriait pas cette table dans les16 premières.

Structures questions_lots_temp et questions_lots demandées pour poursuivre les contrôles ciblés. Préserver intégralement l’ordre des tokens et leurs préfixes, ainsi que id_produit et id_format ; aucune reconstruction depuis id_produit seul.

## Structures séries Quiz reçues

questions_lots_temp :5 colonnes, id primaire, question_ids LONGTEXT utf8mb4_bin NOT NULL défaut [] ; présence PROD confirmée. questions_lots :35 colonnes, id primaire et champs nom/id_etat/online présents ; champs communauté/validation également présents, à conserver sans mutation. Requête10 préparée en SELECT :42 références T209–T250 et 26 références L distinctes (3, 5, 8, 9, 17, 20, 22, 25, 32, 42, 43, 45, 48, 49, 50, 54, 55, 58, 59, 87, 175, 212, 244, 245, 246, 450). JSON_VALID contrôle la syntaxe uniquement, pas la forme tableau ni l’existence des questions ; le contenu brut converti en texte est demandé pour examiner les références dans leur ordre. Le nombre de lignes attendu vérifie l’existence des références ; aucune exécution par l’agent.

## Résultats des séries Quiz T et L

42 lignes T209–T250 présentes, JSON_VALID=1 pour chacune. Toutes les valeurs transmises sont des tableaux de6 entiers positifs :252 occurrences de références de questions, ordre à préserver. L’existence des questions cibles n’est pas encore vérifiée ; JSON valide ne prouve ni leur existence ni leur jouabilité.

26 références L présentes :3,5,8,9,17,20,22,25,32,42,43,45,48,49,50,54,55,58,59,87,175,212,244,245,246,450. Toutes online0 ;25 id_etat2 et L450 id_etat1. Aucune exclusion de contenu programmé sur online ou id_etat autorisée. Le lecteur main déjà inspecté charge le détail questions_lots par id sans filtre online ; l’inventaire ne certifie pas encore toutes les routes de jeu ni assets.

Ainsi aucune référence de série manquante parmi les68 IDs de séries distincts (42T+26L). Cela ne confond pas cet ensemble avec les68 sessions du parc. Prochain contrôle : structure minimale questions (id, id_lot, position), puis existence des questions T et volumes des séries L. Aucun SQL exécuté par l’agent.

## Colonnes questions confirmées

Métadonnées PROD : id MEDIUMINT UNSIGNED clé primaire, id_lot MEDIUMINT UNSIGNED index MUL, position TINYINT(1). Requêtes11 préparées : expansion des6 positions JSON de chacune des42 sériesT reçues et jointure par clé primaire (252 occurrences attendues, dénombrement des références absentes et des questions trouvées distinctes) ; jointure indexée pour compter les questions de chacune des26 sériesL en conservant les séries vides. Pas de JSON_TABLE, pas de filtre online/état, pas de comparaison de position à une valeur supposée. Contrôle de références uniquement : pas une certification des réponses/médias/compatibilité runtime. Aucune exécution par l’agent.
