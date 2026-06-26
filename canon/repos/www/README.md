# Repo `www` — Carte IA d’intervention (canon)

## Update 2026-06-25 - BO Questions numériques: source `questions`
- ecran concerne: BO `Jeux > Questions numériques`, route `?t=jeux&m=questions_numeriques`.
- decision durable:
  - `questions_numeriques` n'est plus une table metier cible ni legacy durable;
  - `questions` reste la source unique des questions papier et porte la variante numerique via `question_numerique`, `reponse_numerique`, `commentaire_numerique`, `statut_numerique`;
  - `questions_propositions` reste commun papier/numerique, sans typage d'usage;
  - `questions_lots_num_temp.question_ids` pointe vers des IDs `questions`.
- resultat livre cote BO:
  - la liste lit `questions WHERE id_lot=0`, affiche la version papier en lecture et la variante numerique quand elle existe;
  - le formulaire charge une question source `questions`, affiche les champs papier en lecture seule et ne sauvegarde que les champs numeriques;
  - les propositions editees sont les distracteurs communs de `questions_propositions`;
  - le statut `certified` est refuse sans au moins un distracteur exploitable distinct; `question_numerique` et `reponse_numerique` restent optionnelles et retombent sur la question/reponse papier source;
  - l'action de lot de test cree un `N{id}` depuis des questions `statut_numerique='certified'` valides, avec `question_source='questions'` quand la colonne existe;
  - un export CSV read-only permet de sauvegarder les lignes affichees avant nettoyage ou controle.
- garde-fous:
  - aucune lecture/ecriture SQL BO vers la table `questions_numeriques`;
  - pas de `proposition_usage`;
  - pas de creation automatique de session, quick numerique, WS, scoring ou front joueur.

## Update 2026-06-24 - BO Questions numériques: commentaire et dates source
- ecran concerne: BO `Jeux > Questions numériques`, route `?t=jeux&m=questions_numeriques`.
- resultat livre:
  - tableau candidates: ajout du `commentaire` source, remplacement de `Utilisée dans T` par les valeurs brutes `jour_associe` et `jour_associe_v1`;
  - pour les candidates deja adaptees, les colonnes question/reponse/propositions/commentaire/dates affichent les valeurs de `questions_numeriques` afin d'etre coherentes avec le bouton `Éditer`;
  - le tableau candidates utilise une largeur fixe de page pour garder l'action visible sans deborder horizontalement;
  - formulaire numerique: `commentaire` et `jour_associe` deviennent modifiables quand les colonnes existent dans `questions_numeriques`; `jour_associe_v1` est conserve sans affichage dans les metadonnees;
  - sauvegarde compatible avec les bases non migrees: les champs additifs sont ecrits seulement si les colonnes existent;
  - adaptation depuis une question source pre-remplit `commentaire`, `jour_associe` et `jour_associe_v1`.
- format retenu:
  - `jour_associe` conserve le format DB historique `MM-DD`, affiche brut dans ce BO numerique;
  - `jour_associe_v1` est conserve brut (`char/varchar(5)`) via champ masque, sans conversion, car aucun usage PHP source certain n'a ete identifie hors compatibilite/import;
  - `commentaire` est le commentaire metier source; `commentaire_interne` reste separe.
- garde-fous:
  - aucune normalisation ou renommage des champs date;
  - aucune refonte UX, aucun import massif, aucun changement papier/quick/WS/scoring.

## Update 2026-06-24 - BO Jeux: Questions numériques
- ecran concerne: BO `Jeux > Questions numériques`, route `?t=jeux&m=questions_numeriques`.
- objectif:
  - afficher un audit lisible des questions historiques candidates issues de `questions.id_lot=0`;
  - exclure explicitement les lots catalogue `L` via `questions.id_lot=0`;
  - conserver l'usage dans les lots temporaires papier `T` comme simple indication secondaire;
  - permettre une creation/edition manuelle du stock `questions_numeriques`.
- resultat livre:
  - entree de menu ajoutee sous `Jeux`, a cote de `Playlists musicales` et `Series Cotton Quiz`;
  - module BO dedie `www/modules/jeux/questions_numeriques`;
  - source candidate principale: `questions WHERE id_lot=0`, sans priorite donnee aux lots `T`;
  - vue candidates paginee cote SQL, 50 lignes maximum par page;
  - filtres serveur: recherche question/reponse, statut calcule, presence ou non dans `questions_numeriques`;
  - compteurs globaux bornes aux requetes SQL simples, et compteurs avances explicites sur la page courante;
  - colonne `Utilisée dans T` calculee seulement pour les lignes affichees;
  - exemples representatifs bornes sur la page courante;
  - formulaire manuel avec statuts `draft`, `reviewed`, `certified`, `rejected`;
  - le statut `certified` exige au moins une mauvaise proposition distincte apres normalisation; la question/reponse papier source peuvent servir de fallback si la variante numerique est vide;
  - sauvegarde refusee si la table `questions_numeriques` n'existe pas.
- action de test interne:
  - la liste `Stock questions numériques` permet de cocher des questions `certified`;
  - l'action `create_test_lot` cree un lot dans `questions_lots_num_temp` avec les ids `questions_numeriques` selectionnes, en ordre stable;
  - le lot porte `source_generation=bo_test`, un statut compatible `draft`, et affiche le token `N{id}` apres creation;
  - aucune session n'est creee automatiquement: le token est uniquement destine a une session Cotton Quiz de test.
- garde-fous:
  - acces borne aux administrateurs BO deja autorises sur `t=jeux`;
  - pas de quick numerique `N`;
  - pas de generation automatique de lots `N`;
  - pas d'import massif dans `questions_numeriques`;
  - pas de modification WS, scoring, front joueur, generation rapide, generation papier ni parcours papier.
- prerequis serveur DB:
  - appliquer/revoir la migration candidate globale `global/web/app/modules/jeux/cotton_quiz/tools/2026-06-24_questions_numeriques_lots_num_temp.sql`;
  - ouvrir ensuite `?t=jeux&m=questions_numeriques&p=list` pour auditer et adapter manuellement.

## Update 2026-06-24 - BO activation commerciale / suivi temporaire
- ecrans concernes:
  - BO home `syntheses/resumes`, bloc `Commerce / Activation commerciale`;
  - BO fiche client `entites/clients`, bloc `Suivi commercial`.
- resultat livre:
  - le suivi commercial propose un statut `Traité pour le moment`;
  - quand un compte est ouvert depuis une ligne Activation commerciale, la categorie courante est transmise a la fiche client et stockee avec le suivi;
  - un compte traite est masque du bloc uniquement pour cette categorie tant qu'aucun nouveau signal metier posterieur au suivi n'est detecte;
  - les rappels commerciaux a date conservent leur retour dans la categorie `Rappels commerciaux`;
  - les commentaires longs du suivi commercial restent resumes mais disposent d'un lien `Lire la suite` pour afficher le texte complet avec retours a la ligne;
  - chaque ligne de suivi existante peut etre modifiee inline depuis la fiche compte (`Modifier` puis `Enregistrer`);
  - aucun changement de schema manuel requis: la table de suivi BO reste assuree par le helper existant.

## Update 2026-06-24 - BO offres clients / badges essai et offert
- ecrans concernes:
  - BO home `syntheses/resumes`, bloc `Dernieres offres clients`;
  - BO `ecommerce/offres_clients`, listing des offres souscrites;
  - BO fiche client `entites/clients`, section `Offres`.
- resultat livre:
  - le helper commun de rendu prix des offres clients affiche maintenant le badge `Offert` quand `flag_offert=1`;
  - la detection du badge `Essai` ne supprime plus les offres offertes, afin d'aligner le listing et la fiche client sur le bloc home;
  - la fiche client recupere le detail complet via le helper existant, donc le badge `Offert` s'affiche meme si sa requete locale ne selectionne pas directement `flag_offert`;
  - aucun changement de schema, routes, filtres de page ou ecritures ecommerce.

## Update 2026-06-22 - FO session: microcopy participation compte / QR
- ecran concerne: `/fr/agenda/{seo_slug_client}/{code_session}`.
- resultat livre:
  - la fiche session publique affiche maintenant, juste avant `Je participe`, une phrase explicite: inscription pour prevenir l'organisateur, retrouver la session le jour J depuis son compte et possibilite de rejoindre aussi via le QR code affiche sur place;
  - le CTA `Je participe` reste inchange;
  - les cartes session des pages place/evenement et les contextes QR/direct gardent leurs CTA et wordings existants, notamment `J'accède au jeu`.
- limites:
  - aucune modification de route;
  - aucune modification des compteurs ou ecritures de participations probables;
  - aucune modification des conditions d'affichage Jour J ni des CTA runtime.

## Update 2026-06-21 - FO place: Agenda AJAX decouple des classements
- ecran concerne: `/fr/place/{slug}`, onglet initial `Agenda` de `place-dynamic-tabs-section`.
- diagnostic:
  - l'endpoint `section=agenda` de `fo_clients_view_ajax.php` retourne avant les chemins stats, classements, archives, podiums et resultats;
  - l'Agenda ne chargeait donc pas directement l'historique dans sa reponse AJAX;
  - le rendu initial de la page lancait toutefois `overview` et `summary` en parallele, meme quand Agenda etait l'onglet actif;
  - `overview` calcule les classements et teste l'existence d'archives, ce qui pouvait concurrencer l'appel Agenda sur les lieux avec gros historique;
  - le chemin Agenda borne par dates utilisait encore `app_sessions_get_liste(...)`, qui calcule des enrichissements participants/resultats inutiles pour des cartes futures.
- resultat livre:
  - si l'onglet initial est `Agenda`, l'Agenda est charge en priorite au demarrage;
  - `summary` est lance apres le rendu Agenda pour conserver les stats visibles sur la page sans concurrencer l'appel Agenda;
  - `overview` est charge a la demande quand l'utilisateur ouvre `Classements`, avec garde anti-doublon sur le filtre courant;
  - les tranches Agenda par dates utilisent une requete legere sur sessions futures publiques, client, type produit et evenement;
  - le filtrage archive du jour, l'exclusion demo, les series Quiz, le regroupement evenement gamification, l'entree QR code et le CTA `J'accède au jeu` sont conserves.
- limites:
  - aucune modification de route;
  - aucune refonte visuelle;
  - les classements et archives gardent leurs chemins existants quand leurs onglets sont demandes.

## Update 2026-06-21 - FO place: agenda AJAX borne par dates
- ecran concerne: `/fr/place/{slug}`, section `place-dynamic-tabs-section`, onglet `Agenda`.
- diagnostic:
  - le chargement AJAX de l'onglet Agenda appelait `fo_clients_view_upcoming_sessions_get(...)` sans borne utile;
  - ce chemin pouvait charger toutes les sessions futures du lieu via `app_sessions_get_liste(...)`, puis appliquer le filtrage archive cote PHP;
  - un simple `LIMIT` session aurait pu couper une date au milieu.
- resultat livre:
  - l'onglet Agenda charge maintenant d'abord un nombre limite de dates distinctes a venir;
  - seules les sessions des dates retenues sont chargees pour le rendu initial;
  - une date supplementaire sert a detecter l'affichage du bouton `Afficher plus`;
  - `Afficher plus` ajoute la tranche suivante de dates sans recharger les autres onglets;
  - les comptes gamification conservent le regroupement des sessions rattachees a un evenement sous une carte evenement vers `/fr/evenements/{slug}`;
  - les sessions non rattachees conservent les cartes session existantes;
  - l'entree QR code `place/{code_client}` conserve son CTA direct `J'accède au jeu`.
- limites:
  - aucune refonte visuelle;
  - aucune modification de route publique;
  - les archives et classements restent charges par leurs chemins existants, hors AJAX agenda.

## Update 2026-06-19 - Gamification: page evenement prioritaire
- ecrans concernes:
  - `/fr/evenements/{slug}`;
  - `/fr/agenda/{seo_slug_client}/{code_session}` pour les sessions rattachees a un evenement gamification.
- resultat livre:
  - la page evenement n'expose plus de lien vers `/fr/place/{slug}` dans le breadcrumb ni dans `Organisé par`;
  - `operations_evenements.naming_nom`, si renseigne, remplace le nom du compte dans le breadcrumb et la ligne `Organisé par`;
  - le hero evenement affiche une ligne pratique lieu/adresse sous les metas, avec fallback nom `naming_lieu`, puis `naming_nom`, puis compte, et adresse evenement prioritaire puis fallback compte;
  - l'accroche courte est forcee dans une couleur lisible avec un espacement bas;
  - les cartes sessions d'une page evenement affichent le nom selon `lieu evenement > organisateur evenement > compte` et l'adresse evenement si elle existe, sinon l'adresse du compte, sans lien vers la page compte;
  - la fiche session rattachee a un evenement gamification affiche le bloc `Lieu`, avec nom `lieu evenement > organisateur evenement > compte` et adresse evenement prioritaire puis fallback compte;
  - ce bloc ne lie plus vers la page place en contexte evenement gamification;
  - le bloc `Autres sessions de cet événement` ne liste que les autres sessions du meme evenement;
  - les pages/session dynamisation classiques conservent leur logique de lien place.
- limites:
  - aucune suppression technique de la page compte/place;
  - aucun changement de route publique.

## Update 2026-06-19 - FO evenement: visuel bannière et meta hero
- ecran concerne: `/fr/evenements/{slug}`.
- resultat livre:
  - le visuel evenement du hero est affiche en ratio `5 / 2`, aligne avec le format editeur `1200 × 480`;
  - le visuel ne s'etire plus pour egaler la hauteur du texte et ne prend plus un rendu carre/portrait;
  - `object-fit: cover` reste utilise uniquement dans ce conteneur au bon ratio;
  - la ligne `Organisé par / date / lien externe` est placee au-dessus du titre et retiree de son ancien emplacement sous la description;
  - le compte organisateur reste lie vers `/fr/place/{slug}` quand le slug existe;
  - les cartes sessions de la page evenement gardent le visuel jeu/theme de chaque session.
- limites:
  - aucun changement de route;
  - aucun style global applique aux pages place/session classiques.

## Update 2026-06-19 - FO place/evenement/session gamification
- ecrans concernes:
  - `/fr/place/{slug}`;
  - `/fr/evenements/{slug}`;
  - `/fr/agenda/{slug}/{code_session}`.
- resultat livre:
  - dans `place-dynamic-tabs-section`, `Agenda` est rendu en premiere position et devient l'onglet actif initial uniquement si une date a venir existe;
  - l'ordre historique est conserve quand aucune date a venir n'est affichable;
  - pour les comptes `id_solution_usage = 2`, l'agenda de la page place regroupe les sessions rattachees a un evenement sous une carte evenement menant vers `/fr/evenements/{slug}`;
  - les sessions non rattachees a un evenement gardent le rendu de carte session existant;
  - la page evenement remplace le breadcrumb generique `Evenements` par le compte organisateur, lie vers `/fr/place/{slug}` quand un slug existe;
  - le hero evenement affiche le visuel a gauche et les informations principales a droite, sans refonte globale de la page;
  - les cartes session listees dans une page evenement utilisent le visuel jeu/theme de la session et ne repetent plus le badge `Evenement !`;
  - la fiche session en contexte evenement utilise aussi le visuel jeu/theme, pas le visuel evenement;
  - le bloc `Organisateur` d'une fiche session affiche le compte porteur avec lien `/fr/place/{slug}` quand disponible.
- limites:
  - aucune migration SQL;
  - aucune modification de route;
  - aucune nouvelle condition bloquante sur `clients.online`.

## Update 2026-06-11 - Pages lieux / archives utiles globales
- les blocs publics de fiche lieu qui affichent les sessions recentes classees et les archives s'appuient sur `app_client_joueurs_dashboard_archive_sessions_get(...)`;
- une session papier non demo demarree peut remonter dans les archives publiques meme si elle n'est pas explicitement terminee;
- une session numerique demarree ne remonte que si elle porte de vrais participants/resultats exploitables;
- les pages publiques restent donc alignees sur le signal global d'archive utile, partage avec la navigation et le parcours first_party PRO;
- fichier de reference: `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`.

## Update 2026-06-11 - BO facturation_pivot / sessions significatives demarrees
- le reporting BO `facturation_pivot` aligne sa reconstruction SQL des sessions significatives sur la regle globale d'archive utile;
- une session papier non demo complete est significative si elle est demarree: runtime `phase_courante > 0` quand disponible, ou fallback papier passe;
- une session numerique non demo complete est significative seulement si elle est demarree et porte de vrais joueurs/resultats;
- les agregats `reporting_games_sessions_detail`, `reporting_games_sessions_monthly`, les fallbacks SaaS et l'activation des essais gratuits utilisent cette meme logique;
- fichiers de reference: `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php`, `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`.

## Update 2026-06-11 - BO Remises 2026 / affichage FO tarifs
- ecrans concernes:
  - BO `Commercial > Remises 2026`;
  - FO `/fr/tarifs/offre/{abonnement|evenement|particulier}` via le widget tarifaire global.
- resultat livre:
  - une remise 2026 peut porter le flag `Afficher sur les tarifs du site`;
  - ce flag est propose uniquement pour les remises automatiques ciblant explicitement le pipeline `INS`;
  - l'enregistrement BO force le flag a `0` quand le ciblage devient manuel ou non-INS;
  - la liste BO affiche un badge `Tarifs site` quand le flag est actif et eligible;
  - la fiche detail BO affiche l'etat public si pertinent;
  - la page tarifs FO revalide cote affichage: remise active, flag actif, pipeline `INS`, fenetre de commande ouverte, lien `ecommerce_remises_to_offres`, typologie compatible ou non specifiee;
  - une fois eligible, le FO alimente le meme payload `bo_discount` que l'EC Pro et reutilise la meme branche de rendu: badge `nom -X%`, prix standard barre et prix remisé;
  - le libelle public divergent `Offre valable jusqu'au JJ/MM/AAAA...` n'est pas conserve;
  - l'etape publique de confirmation `/fr/signup/ecommerce/{id_securite_offre_panier}` recalcule aussi la remise depuis le panier cote serveur et affiche un rappel avant inscription: badge, prix standard barre, prix remisé, duree si disponible;
  - cette confirmation ne transmet pas d'ID remise au front: le contexte conserve reste la cle opaque panier existante, et l'application paiement reste revalidee par le checkout EC Pro apres creation/connexion du compte.
- schema:
  - migration idempotente: `ecommerce_remises.flag_affichage_tarifs_site TINYINT(1) NOT NULL DEFAULT 0`;
  - la colonne est creee par les helpers Remises 2026 / ecommerce si absente.
- limites:
  - pas de nouvelle source legacy `remises` / `remises_offres`;
  - le checkout/Pro reste la source de verite fonctionnelle; la page tarifs FO reprend uniquement l'information promotionnelle qui sera retrouvee dans le parcours de commande;
  - le helper FO reste prudent si aucune typologie n'est fournie et ne retient alors que les remises sans typologie specifique;
  - si la typologie finale saisie a l'inscription n'est plus compatible, le rappel de confirmation n'impose rien: la remise n'est pas appliquee au paiement.

## Update 2026-06-09 - FO sessions publiques: lien fiche lieu borne aux lieux publics
- ecrans concernes:
  - fiche session publique `/fr/agenda/{seo_slug_client}/{code_session}`;
  - audit leger fiche lieu `/fr/place/{seo_slug}`.
- resultat livre:
  - la fiche session publique n'affiche les liens vers `/fr/place/{seo_slug}` que pour les comptes compatibles lieu public / dynamisation, y compris dans le bloc haut de page sans changer son rendu;
  - les comptes explicitement `id_solution_usage = 2` (gamification / evenement) affichent le lieu en texte simple, sans lien vers une fiche compte/lieu;
  - le libelle du bloc lieu devient `Organisateur` pour les comptes gamification / evenement qui affichent le compte porteur, ou `Lieu de l'evenement` pour un lieu nomme propre a l'evenement;
  - les typologies de lieu public conservees pour le lien sont `1` et `8`, alignees avec le contexte `venue` first_party;
  - une session demo appelee directement par URL publique est redirigee vers `/fr/agenda` avant rendu;
  - la section `Autres sessions a venir dans cet etablissement` exclut aussi les sessions demo, y compris pour les comptes `INS`;
  - la page lieu `/fr/place/{seo_slug}` exclut explicitement les sessions demo de ses sections `Agenda` et `Sessions passees`, sans reutiliser l'exception historique `INS` des helpers de dashboard;
  - le titre de cette section devient `Autres sessions a venir avec cet organisateur` quand la session n'est pas rattachee a un lieu public/dynamisation;
  - les regles de publication `clients.online`, `/fr/place` et `/fr/agenda` ne changent pas.
- audit fiche lieu minimale:
  - la page publique lieu conserve le nom et les informations disponibles;
  - les blocs sessions archivees et classements ont deja des etats vides explicites;
  - TODO si constate en runtime: remplacer les placeholders async `Chargement des statistiques...` / `Chargement des classements...` par des fallbacks statiques quand l'appel AJAX ne repond pas, sans refonte de la fiche lieu.
- limites:
  - aucun changement de route;
  - aucune migration SQL;
  - aucune refonte de `/fr/place`.

## Update 2026-06-05 - FO agenda / visuels Cotton Quiz V2
- ecrans concernes:
  - pages publiques agenda et fiche session;
  - widget agenda Cotton;
  - page lieu, cartes sessions a venir et archivees.
- resultat livre:
  - les vues FO transmettent maintenant `lot_ids` a `app_jeu_get_detail(...)` pour les sessions Cotton Quiz V2;
  - le helper global peut donc utiliser `app_cotton_quiz_get_session_visual_src(...)` et afficher un visuel issu d'une serie/thematique plutot que le visuel par defaut;
  - le comportement est aligne avec Pro, qui transmettait deja `lot_ids`;
  - le fallback FO de photo du gagnant apres session, quand elle existe, reste prioritaire et inchange.
- limites:
  - aucun changement de route;
  - aucune migration SQL;
  - aucune modification de la logique resultats/podium.

## Update 2026-06-02 - BO finances / synthese bancaire reporting
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=finances`.
- resultat livre:
  - la page calcule une synthese mensuelle issue des transactions bancaires importees: `Cash in (EUR)`, `Cash out (EUR)` et `Charges ventilees (EUR)`;
  - `cash_in` et `cash_out` suivent le mois de la date bancaire, hors transactions exclues;
  - `charges` ne reprend que les transactions caracterisees comme charges et passees au statut `valide`;
  - chaque ligne bancaire propose un mois de reference et une ventilation de 1 a 12 mois; le montant de charge est reparti lineairement a partir du mois choisi;
  - une charge payee sur un mois mais affectee/ventilee sur un mois hors periode d'import cree aussi les mois comptables concernes dans la synthese;
  - une ventilation sur plusieurs mois alimente les mois suivants, jusqu'a 12 mois, meme si ces mois ne portent pas encore de flux cash importes;
  - lors d'une injection ulterieure, les mois crees uniquement par ventilation mettent a jour les charges sans remettre a zero les `cash_in` / `cash_out` deja presents;
  - le bouton `OK` valide/replie la ligne traitee; le bouton `Modif.` rouvre la ligne si correction necessaire;
  - apres validation d'une ligne, le BO revient sur l'ancre de la transaction concernee au lieu de remonter en haut de page;
  - le tableau transactions masque les colonnes secondaires `Contrepartie`, `Sens` et `Categorie API` pour conserver de la largeur;
  - les lignes d'encaissement alimentent `Cash in` mais ne proposent plus de formulaire de qualification;
  - l'import CSV dispose d'une date libre `Importer a partir du`, pre-remplie au `2026-05-01`, afin d'ignorer les lignes bancaires anterieures lors d'une reprise;
  - le controle destructif de purge n'est pas expose dans l'interface: la borne de reprise est appliquee uniquement au moment de l'import CSV;
  - le bouton `Injecter dans le reporting` ecrit explicitement la synthese mensuelle dans `charges_facturation_pivot.php`, source lue par le reporting SaaS;
  - les actions libres et le solde initial deja presents dans `charges_facturation_pivot.php` sont conserves lors de l'injection;
  - les anciennes tables bancaires sont completees idempotemment avec les champs de periode/ventilation si besoin.
- limites:
  - aucune injection automatique silencieuse: les donnees du reporting ne changent qu'apres action super-admin explicite;
  - les charges `auto_caracterise` ou `a_verifier` restent hors reporting tant qu'elles ne sont pas validees.

## Update 2026-06-02 - BO home / derniers inscrits comptes
- ecran concerne:
  - home BO `?t=syntheses&m=resumes`, bloc `Derniers inscrits`.
- resultat livre:
  - le bloc liste maintenant des comptes clients, pas des lignes de contacts;
  - la requete part de `clients` et ne joint plus directement `clients_contacts_to_clients`, afin d'eviter une double ligne quand un compte a plusieurs contacts;
  - l'indicateur `Joueur` reste calcule par existence d'un contact dont l'email existe dans `entites_utilisateurs`, sans multiplier le rendu;
  - le bloc reste trie par inscription recente et limite a 10 comptes.

## Update 2026-06-01 - BO finances / import bancaire CSV V1
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=finances`.
- resultat livre:
  - la V1 bancaire repose sur l'import manuel d'exports CSV bancaires, pas sur une connexion API Open Banking;
  - ajout d'une section super-admin `Import bancaire`, optionnelle et non bloquante si aucune donnee bancaire n'existe;
  - ajout d'un endpoint POST super-admin `p=bank_import`, avec jeton CSRF local, upload CSV limite et suppression du fichier temporaire apres traitement;
  - le premier import cree/complete les tables V1 `bank_connections`, `bank_accounts`, `bank_transactions`, `bank_transaction_rules`, `bank_imports` et `bank_sync_logs`;
  - parser CSV compatible CIC latin1 `Date;Date de valeur;Débit;Crédit;Libellé;Solde` et CSV generiques `Date/Libellé/Débit/Crédit` ou `Date/Libellé/Montant`;
  - chaque ligne importee recoit un hash deterministe anti-doublon, avec `balance_after`, `raw_row_json` et rattachement `import_id`;
  - pre-caracterisation par regles Stripe, prelevements clients, frais bancaires CIC, Google Workspace, Gandi, Allianz, loyer, honoraires comptables et remuneration mandat;
  - affichage du dernier import, solde final importe si fourni, flux entrants/sortants, variation nette, charges estimees, transactions a caracteriser/a verifier/exclues;
  - tableau des transactions avec action POST super-admin `p=bank_transaction_update` pour valider, corriger la categorie Cotton, marquer a verifier ou exclure;
  - le provider `mock` reste disponible uniquement si configuration explicite et son bouton est libelle `Synchroniser mock bancaire (dev)`;
  - les donnees bancaires restent absentes des exports/partages publics existants, car la V1 est rendue uniquement dans le BO authentifie `p=finances`.
- limites V1:
  - aucun provider Open Banking reel n'est branche et ce n'est pas le flux V1 cible;
  - aucune synchronisation automatique cron n'est ajoutee;
  - les charges estimees restent informatives et ne modifient pas les indicateurs SaaS existants.

## Update 2026-06-01 - BO reporting SaaS / mobile tableaux et charges
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - sur mobile, les cartes `Ventes, résultat & revenu récurrent` et `Mouvements & variation MRR` retrouvent un espacement quand elles sont empilees;
  - les grilles des tableaux compacts et jeux retrecissent correctement dans leur colonne, ce qui evite d'elargir toute la page mobile;
  - les tableaux `Acquisition & conversion`, `Essais gratuits (CHR & autres lieux publics)`, `Usage jeux & joueurs` et `Formats & contenus joués` gagnent un rendu compact sur tres petit ecran;
  - la ligne `Charges` traite l'ecart en sens inverse: depasser le budget est negatif, rester sous budget est positif.

## Update 2026-06-01 - LP offre essai / demos du moment
- surface concernee:
  - LP publique `/lp/fr/offre-essai`.
- resultat livre:
  - la section demos affiche le titre `Découvrez nos démos du moment en 2 étapes`;
  - les 3 demos ne sont plus fixees uniquement par IDs statiques;
  - la LP reutilise la selection dynamique des contenus du moment employee comme fallback sur les LP reseau: contenus Cotton publies/valides, fenetre saisonniere si disponible, puis popularite 365j ou recence;
  - le fallback automatique limite les contenus `du moment` a 1 carte si des alternatives populaires existent;
  - il evite aussi de repeter une meme famille de theme sur plusieurs jeux, avec une premiere taxonomie texte: sport/foot, cinema/TV, annees/decennies, fete/soiree, saisonnier, musique generaliste, culture generale;
  - les cartes demos affichent en priorite le visuel upload du contenu choisi;
  - les visuels generiques de jeux restent les fallbacks si aucun visuel de thematique n'est disponible;
  - les anciens IDs de l'offre essai restent les fallbacks si la selection dynamique ne retourne rien.

## Update 2026-06-01 - LP carte de visite / redirection home
- surface concernee:
  - URL historique des cartes de visite: `/lp/lp.php?utm_source=cotton&utm_campaign=remise&utm_term=1-jeu-offert&utm_code=GAME1ON&utm_medium=card`.
- resultat livre:
  - la LP conserve le log UTM acquisition externe;
  - cette combinaison exacte redirige ensuite en `302` vers la home du site `www`;
  - les autres campagnes LP historiques restent gerees par le switch `utm_term`.

## Update 2026-06-01 - BO reporting SaaS / formats numerique papier
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`, tableau `Formats & contenus joués`.
  - cron BO manuel `bo/cron_reporting_games_aggregates.php`.
- resultat livre:
  - le tableau conserve la colonne `Sessions` comme total par format;
  - deux colonnes de detail `Numériques` et `Papier` distinguent les sessions selon `championnats_sessions.flag_controle_numerique`;
  - les sessions papier demarrees sont comptees sans condition de presence de joueurs; la presence de joueurs reste uniquement requise pour qualifier les sessions numériques significatives;
  - les sessions Bingo papier sont aussi comptees sans condition de partie terminee (`phase_courante >= 4`), mais exigent un signal de demarrage;
  - les compteurs `Numériques`, `Papier`, `Sessions` et `Joueurs ou équipes` conservent les liens vers les listes de sessions filtrees par IDs;
  - le ratio `Joueurs / session` reste calcule sur le total des sessions du format.
  - le graphe `Évolution de l’usage réel` affiche `Sessions significatives` avec la même définition que le tableau `Usage jeux & joueurs` quand le détail cron `reporting_games_sessions_detail` est disponible, sans changer la fenêtre `$graph_months`.
  - le graphe ignore les anciennes lignes detail non enrichies (`session_pk=0`) comme le tableau.
  - si le détail enrichi est disponible pour la fenêtre du graphe, le graphe utilise `reporting_games_sessions_detail` comme source unique et ne complète plus les mois absents via les agrégats mensuels historiques.
  - les tableaux et graphes opérationnels bornent la fin de période en exclusif au lendemain (`< J+1`) pour inclure tous les événements du dernier jour quand les champs sont des `DATETIME` (`championnats_sessions.date`, `reporting_games_sessions_detail.session_date`, `clients.date_ajout`).
  - le graphe `Évolution de l’usage réel` agrège le détail enrichi par `DATE_FORMAT(reporting_games_sessions_detail.session_date, '%Y-%m')`, comme les tableaux, et n'utilise plus `reporting_games_sessions_detail.month_key` comme source de mois.
  - le graphe `Évolution de l’usage réel` ne fait plus une aggregation SQL separee sur le detail enrichi: il parcourt les lignes de `reporting_games_sessions_detail` avec la meme logique que `Usage jeux & joueurs` (session papier demarree significative, session numerique demarree significative si joueurs, dedoublonnage par session).
  - pour les mois couverts par `Usage jeux & joueurs`, les séries JSON du graphe sont regenerees apres le calcul du tableau depuis les memes compteurs mensuels (`sessions significatives`, `joueurs`, `clients utilisateurs`), afin d'eviter tout ecart de reconstruction.
  - le rattrapage BO ne decremente plus le curseur vers des mois sans session source; quand aucun mois historique utile ne reste, il bascule sur une mise a jour M-1/M incluant les agregats mensuels.
  - le rattrapage BO accepte `month=YYYY-MM&from=YYYY-MM-DD&to=YYYY-MM-DD` pour reconstruire un mois par tranches et limiter les timeouts web; seules les lignes detail de la tranche sont remplacees.

## Update 2026-06-01 - BO reporting SaaS / parc facture synthese
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
  - home BO `?t=syntheses&m=resumes`, premier KPI `Actifs`.
- resultat livre:
  - la carte `Parc facturé` de `Synthèse opérationnelle de la période` reprend le stock `Parc actif facturé fin` du tableau `Mouvements du parc facturé`;
  - la ventilation `Dynam.` / `Gamif.` reprend le meme stock fin par usage;
  - `MRR HT` et `ARPA HT` restent des metriques financieres issues des lignes MRR du mois, comme dans `Mouvements & variation MRR`.
  - le compteur `ABN` du KPI home `Actifs` reprend les IDs `Parc actif facturé fin` exposes par le reporting SaaS en mode data-only, avec fallback SQL ABN actif/payant/facture si la source n'est pas disponible;
  - le lien du KPI home `Actifs` filtre la liste clients sur les IDs affiches: PAK courants + ABN issus du stock fin facture;
  - les taux `Activation (30j)` et `Power Users (30j)` filtrent aussi leur numerateur sur des ABN actifs factures pour rester alignes avec ce denominateur.

## Update 2026-05-31 - BO fiche client / remises applicables
- ecran concerne:
  - fiche client BO `?t=entites&m=clients&p=view&id={id}`, section `Remises`.
- resultat livre:
  - la section affiche uniquement les remises applicables au compte;
  - les remises deja appliquees/utilisees restent visibles sur les offres concernees, pas dans cette section;
  - le bloc `Ajouter une remise manuelle` n'est plus affiche;
  - si aucune remise applicable n'existe, la section `Remises` n'apparait pas.

## Update 2026-05-31 - BO suivi commercial / date d'entree
- ecran concerne:
  - fiche client BO `?t=entites&m=clients&p=view&id={id}`, section `Suivi commercial`.
- resultat livre:
  - chaque ligne affiche une date d'entree automatique `Ajouté le`, issue de `bo_activation_commerciale_suivi.date_creation`;
  - la date metier eventuelle reste distincte et s'affiche en `Échéance`.

## Update 2026-05-31 - BO Activation commerciale / suivi commercial simplifie
- ecrans concernes:
  - home BO `?t=syntheses&m=resumes`, bloc `Activation commerciale`;
  - fiche client BO `?t=entites&m=clients&p=view&id={id}`.
- resultat livre:
  - la fiche client expose un bloc compact `Suivi commercial`, replie par defaut, avec les 4 derniers suivis visibles et un bouton `Voir / ajouter`;
  - le formulaire ouvert ne montre que `Statut`, `Date`, `Commentaire` et `Ajouter`;
  - les champs avances categorie A/B/C/D/E, masquage, scope et rappel force ne sont plus exposes en V1;
  - les statuts V1 sont `note_commerciale`, `a_rappeler`, `non_interesse_pour_le_moment`, `ne_pas_relancer`;
  - le bloc home reste un radar automatique: il lit le dernier suivi client, exclut des categories A/B/C/D/E tout client dont le dernier suivi porte une date, et ajoute une sous-liste `Rappels commerciaux` a partir de J-3 avant cette date;
  - les compteurs A/B/C/D/E tiennent compte des exclusions, et `Rappels commerciaux` dispose de son propre compteur.
- schema:
  - table dédiée `bo_activation_commerciale_suivi`, créée idempotemment par le helper BO;
  - champs principaux: `id_client`, `categorie`, `statut_suivi`, `commentaire`, `masquer_activation`, `scope_masquage`, `date_masque_jusquau`, `date_rappel`, `forcer_rappel_activation`, `id_user_bo`, dates de création/update;
  - en V1, `categorie` est deduite a `ALL`, `scope_masquage` a `global`, `masquer_activation` et `forcer_rappel_activation` sont deduits du statut.
- limites V1:
  - `ne_pas_relancer` sans date exclut le client sans reactivation automatique; une date renseignee declenche une reevaluation dans `Rappels commerciaux` a J-3.

## Update 2026-05-29 - BO SaaS / libelles usage abonnes actifs
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - dans `Usage jeux & joueurs`, les lignes de clients sont renommees `Abonnés actifs utilisateurs` et `Abonnés actifs sans usage` pour clarifier le perimetre periode.
  - le graphe `Évolution de l’usage réel` reprend aussi le libelle `Abonnés actifs utilisateurs`.

## Update 2026-05-29 - BO SaaS / essais actives carte acquisition
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - la carte `Acquisition & essais` affiche une ligne supplementaire `essais activés`;
  - cette ligne utilise le compteur d'essais activés Dynamisation deja calcule pour le tableau `Essais gratuits`.

## Update 2026-05-29 - BO SaaS / libelles cartes synthese
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - la carte `Parc facturé` separe MRR HT et ARPA HT;
  - `Acquisition & essais` met les comptes créés en KPI principal avec segmentation Dynam./Gamif. et essais Dynamisation;
  - `Mouvements du parc` detaille nouveaux, réactivations et churn avec segmentation Dynam./Gamif.;
  - `Usage réel` affiche sessions, clients, joueurs et ratio `joueurs / session` sur des lignes distinctes.

## Update 2026-05-29 - BO SaaS / UI synthese et labels graphes
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - `Synthèse opérationnelle de la période` est placee sous `Principales actions`;
  - les 4 graphes `Évolutions mensuelles` affichent des valeurs directement sur les donnees;
  - le rendu des valeurs reste leger avec labels petits, halo clair et masquage des collisions proches.

## Update 2026-05-29 - BO SaaS / V2 bascule en page principale
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - la V2 du reporting SaaS remplace la page principale `bo_facturation_pivot_saas.php`;
  - l'ancienne V1 reste disponible dans le code sous `old_bo_facturation_pivot_saas.php`;
  - les liens et formulaires internes de la page principale restent sur `p=saas`;
  - les pages detail ARPA, conversion et expansion continuent a reutiliser le fichier principal en mode data-only.

## Update 2026-05-29 - BO SaaS / V2 liens churn clients net
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - la ligne `Churn clients net` du tableau `Mouvements du parc facturé` n'ouvre plus une modale locale;
  - ses valeurs `Total`, `Dynam.` et `Gamif.` redirigent vers le listing BO des clients filtrés, comme les autres lignes de mouvements;
  - le même comportement est appliqué à `Churn clients net` dans le tableau `Mouvements & variation MRR`.

## Update 2026-05-29 - BO SaaS / V2 segmentation parc et essais Dynamisation
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - la carte `Parc facturé` affiche la segmentation du stock facturé en `Dynam.` / `Gamif.` avant le MRR et l'ARPA;
  - les essais gratuits Gamification ne sont plus comptés dans les indicateurs essais de la V2;
  - le mini-tableau `Essais gratuits (CHR & autres lieux publics)` est réduit à une seule colonne de valeurs;
  - dans `Acquisition & conversion`, les lignes essais Dynamisation affichent leur valeur en `Réalisé`, avec `Budget`, `Écart` et `Gamif.` à `n/a`.

## Update 2026-05-29 - BO SaaS / V2 correctif 504 cron jeux
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - le raccourci BO du cron jeux ne déclenche plus un backfill historique complet quand les colonnes enrichies viennent d'être ajoutées;
  - si `reporting_games_sessions_detail` est vide, le backfill détail avance par mois successifs depuis le BO;
  - si la table détail est partielle, le cron reconstruit le plus ancien mois source absent;
  - le mois source absent est déterminé avec les mêmes filtres que l'insertion détail, afin d'ignorer les mois sans session éligible;
  - les lignes détail invalides `0000-00` sont supprimées au démarrage du cron;
  - les agrégations joueurs du backfill détail sont bornées au mois reconstruit;
  - si un cron interrompu laisse la table détail sans lignes enrichies pour la période, la V2 revient au calcul historique au lieu d'afficher `0` dans les tableaux jeux;
  - les `Sessions significatives` sont calculées depuis la même source que `Sessions jouées`, y compris pendant un rattrapage partiel;
  - le tableau `Usage jeux & joueurs` ne répète plus `Sessions jouées`; le ratio est libellé `Joueurs / session`;
  - les titres des 4 graphiques du bloc `Évolutions mensuelles` sont centrés et affichés en gris neutre, tandis que le titre du bloc reste bleu;
  - le cron jeux déclenché manuellement depuis le BO affiche son rapport dans le navigateur sans email et se limite au détail sessions;
  - le mode BO traite un seul mois par appel, en partant du mois précédent le plus ancien mois déjà présent dans `reporting_games_sessions_detail`, puis avance via `reporting_games_backfill_state`;
  - le cron daily conserve l'email technique et les agrégats complets;
  - le chemin rapide n'est activé que quand des lignes enrichies existent réellement pour la période et les clients actifs.
- point d'exploitation:
  - après déploiement, un simple rechargement V2 doit restaurer les chiffres via fallback si le cron précédent a expiré;
  - le cron BO peut ensuite être relancé plusieurs fois pour reconstruire le détail vidé ou partiel, puis mettre à jour M-1 / M sans backfill historique complet.

## Update 2026-05-29 - BO SaaS / V2 optimisation usage jeux
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - le cron jeux enrichit `reporting_games_sessions_detail` avec les métadonnées nécessaires aux tableaux V2 `Usage jeux & joueurs` et `Formats & contenus joués`;
  - la V2 lit ces détails enrichis quand ils sont disponibles, au lieu de recalculer les joueurs et contenus depuis les tables source à chaque chargement;
  - un fallback conserve le calcul historique tant que le cron enrichi n'a pas tourné.
- point d'exploitation:
  - lancer `bo/cron_reporting_games_aggregates.php` sur l'environnement cible pour backfiller les colonnes enrichies et activer le chemin rapide.

## Update 2026-05-29 - BO SaaS / V2 regroupement graphiques
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - les 4 graphiques d'évolution sont regroupés sous `Principales actions` dans un bloc `Évolutions mensuelles`;
  - le bloc affiche une grille 2x2: parc/MRR, acquisition, entrées/sorties parc, usage réel;
  - le sous-titre indique `Historique mensuel sur les 3 derniers mois` en vue `Mois`, sinon `Historique mensuel sur la période sélectionnée`;
  - le titre `Principales actions` est inclus dans son bloc blanc.

## Update 2026-05-29 - BO SaaS / V2 lisibilité acquisition et parc
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - `Évolution acquisition, essais & nouveaux abonnés` conserve ses 3 séries mais rend les comptes créés secondaires, en courbe discrète, pour mieux lire essais et nouveaux abonnés;
  - `Évolution des mouvements du parc facturé` devient `Évolution des entrées / sorties du parc facturé`;
  - le graphe parc affiche `Entrées parc`, `Sorties parc` et `Variation nette`, sans réafficher nouveaux/réactivations/churn comme 4 séries équivalentes.

## Update 2026-05-29 - BO SaaS / V2 lisibilité graphiques
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - les 4 graphiques d'évolution V2 conservent leurs données mais gagnent une hauteur utile uniforme;
  - les légendes sont compactes, les mois restent horizontaux et les labels de valeurs automatiques sont désactivés sur ces graphiques;
  - `Évolution des mouvements du parc facturé` passe en barres groupées positives/négatives;
  - `Évolution de l’usage réel` est simplifié aux séries `Sessions jouées` et `Clients utilisateurs`, la métrique joueurs/session significative restant dans le tableau.

## Update 2026-05-29 - BO SaaS / V2 4 graphiques d'évolution
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - la V2 affiche 4 graphiques Chart.js pleine largeur, et pas davantage;
  - `Évolution du parc facturé & MRR` est placé sous `Ventes, résultat & revenu récurrent` / `Mouvements & variation MRR`;
  - `Évolution acquisition, essais & nouveaux abonnés` est placé sous `Acquisition & conversion` / `Essais gratuits`;
  - `Évolution des mouvements du parc facturé` est placé sous `Mouvements du parc facturé` / `Maturité du parc facturé`;
  - `Évolution de l’usage réel` est placé sous `Usage jeux & joueurs` / `Formats & contenus joués`;
  - les séries réutilisent les agrégats mensuels existants et la fenêtre `$graph_months`, avec minimum 3 mois en vue `Mois`.

## Update 2026-05-29 - BO SaaS / V2 note synthèse opérationnelle
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - ajout sous `Synthèse opérationnelle` d'une note courte explicitant `Dynam.` et `Gamif.`;
  - les cartes et les calculs restent inchangés.

## Update 2026-05-29 - BO SaaS / V2 filtres période
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - les changements d'affichage `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile` conservent la page V2 via `p=saas_v2`;
  - le lien `Réinitialiser` conserve aussi la V2;
  - `Période de référence :` est déplacé juste avant la première ligne de tableaux détaillés.

## Update 2026-05-29 - BO SaaS / V2 ordre synthèse opérationnelle
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - la période de référence reste affichée au-dessus de `Synthèse opérationnelle`;
  - `Synthèse opérationnelle` est placée avant `Principales actions`;
  - la carte `Mouvements MRR` devient `Mouvements du parc`;
  - cette carte reprend les mêmes volumes que le tableau `Mouvements du parc facturé`: variation nette du parc actif, nouveaux abonnés facturés, réactivations nettes et churn clients net.

## Update 2026-05-29 - BO SaaS / V2 carte acquisition simplifiée
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - la carte `Acquisition & essais` n'affiche plus de taux;
  - elle affiche les nouveaux abonnés, leur répartition Dynam./Gamif., les comptes créés et les essais lancés.

## Update 2026-05-29 - BO SaaS / V2 carte acquisition synthèse
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - la carte `Acquisition & essais` met `Nouveaux abonnés` en valeur principale;
  - les comptes créés restent affichés en sous-indicateur sur le total prospects;
  - les essais lancés et le taux essais réutilisent le périmètre Dynamisation du tableau `Acquisition & conversion`.

## Update 2026-05-29 - BO SaaS / V2 cohérence synthèse opérationnelle
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - la carte `Acquisition & essais` utilise le même périmètre que la ligne `Comptes créés / prospects` du tableau `Acquisition & conversion`;
  - le taux essais est donc calculé `essais lancés / comptes créés total`;
  - la carte `Mouvements MRR` affiche désormais `MRR réactivations` en plus de `New MRR`, `churn` et `expansion`, pour que les sous-indicateurs expliquent la variation nette.

## Update 2026-05-29 - BO SaaS / V2 synthèse opérationnelle
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - ajout d'un bloc `Synthèse opérationnelle` au-dessus des tableaux;
  - le bloc affiche 4 cartes compactes: `Parc facturé`, `Acquisition & essais`, `Mouvements MRR`, `Usage réel`;
  - les cartes réutilisent les agrégats existants des tableaux: MRR/ARPA, comptes/essais, variation nette MRR, New MRR, churn valeur, expansion nette, sessions, clients utilisateurs, joueurs cumulés et joueurs/session significative;
  - le bloc reste neutre: pas de phrase de lecture, pas de graphique, pas de badge couleur métier et pas de score global.

## Update 2026-05-29 - BO SaaS / V2 réalisé essais masqué
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - la colonne `Réalisé` affiche `n/a` sur `Essais gratuits dynam.` et `Taux prospect dynam. -> essais gratuits`;
  - les écarts restent calculés sur la valeur Dynamisation;
  - la colonne `Dynam.` reste la valeur de référence affichée.

## Update 2026-05-29 - BO SaaS / V2 essais Dynamisation
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - les lignes d'essais du tableau `Acquisition & conversion` sont libellées explicitement Dynamisation;
  - `Gamif.` affiche `n/a` pour `Essais gratuits dynam.` et `Taux prospect dynam. -> essais gratuits`;
  - les valeurs `Réalisé`, `Écart` et `Dynam.` restent calculées sur le périmètre Dynamisation.

## Update 2026-05-29 - BO SaaS / V2 pondération prospects
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - le budget `Comptes créés / prospects` reste global;
  - pour calculer l'objectif essais, ce budget est réparti 35% Dynamisation / 65% Gamification;
  - le budget `Essais gratuits` correspond à `budget prospects * 35% * 25%`;
  - le budget `Taux prospect -> essais gratuits` reste `25%`.

## Update 2026-05-29 - BO SaaS / V2 correction budget essais
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - le budget `Essais gratuits` est maintenant calculé depuis le budget prospects global de période, multiplié par 25%;
  - les colonnes `Réalisé` et `Écart` des lignes essais utilisent le réalisé Dynamisation, périmètre cible de l'objectif;
  - la colonne Gamification reste visible mais hors calcul d'écart pour cet objectif.

## Update 2026-05-29 - BO SaaS / V2 budget essais gratuits
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - le budget `Essais gratuits` dans `Acquisition & conversion` est dérivé à 25% des comptes/prospects Dynamisation créés;
  - le budget `Taux prospect -> essais gratuits` est fixé à 25%;
  - la Gamification ne porte pas cet objectif d'essais.

## Update 2026-05-29 - BO SaaS / V2 retrait contenus formats
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - le second tableau `Contenus joués` / `Top contenu` est retiré du bloc `Formats & contenus joués`;
  - la card conserve uniquement le tableau principal `Format`, `Sessions`, `Joueurs`, `Joueurs / session`.

## Update 2026-05-29 - BO SaaS / V2 liens listings jeux
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - les volumes sessions/joueurs des tableaux jeux ouvrent le listing BO `championnats/sessions` filtré par IDs de sessions;
  - les volumes clients ouvrent le listing BO `entites/clients` filtré par IDs de clients;
  - dans `Formats & contenus joués`, le libellé du format ouvre les clients distincts du format, les colonnes `Sessions` et `Joueurs` ouvrent les sessions du format;
  - les sessions significatives ne deviennent cliquables que quand un ID de session BO fiable est retrouvé.

## Update 2026-05-29 - BO SaaS / V2 variation parc et contenus formats
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - `Mouvements du parc facturé` ajoute `Variation nette du parc actif`, signée depuis le différentiel stock fin moins stock début;
  - `Formats & contenus joués` concentre son tableau principal sur les volumes de sessions et joueurs;
  - les contenus joués et top contenus sont déplacés dans un tableau secondaire du même bloc;
  - la colonne `Clients` n'est plus affichée dans ce tableau formats.

## Update 2026-05-29 - BO SaaS / V2 churn et essais
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - `Churn valeur` est affiché comme un mouvement négatif dans `Mouvements & variation MRR`;
  - ce signe est uniquement une lecture d'affichage, la variation nette continue de soustraire le churn positif interne;
  - `Essais gratuits` ajoute le taux `essais terminés -> essais convertis`, par segment `Total`, `Dynam.` et `Gamif.`;
  - les mini-tableaux qui portent un budget affichent la colonne `Réalisé` au lieu de `Total`.

## Update 2026-05-29 - BO SaaS / V2 lignes fortes et MRR HT
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - `Mouvements & variation MRR` affiche `MRR HT` en première ligne;
  - la valeur reprend la même source et le même lien de détail que `MRR HT` dans `Ventes, résultat & revenu récurrent`;
  - les lignes clés sont affichées en gras pour faciliter la lecture: résultat, nouveaux abonnés facturés, essais convertis facturés, parc actif facturé fin, durée de vie médiane ABN terminés, sessions significatives et joueurs cumulés.

## Update 2026-05-29 - BO SaaS / V2 jeux et joueurs
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2` si le routeur applique la convention fichier `bo_facturation_pivot_{p}.php`.
- resultat livre:
  - la V2 simplifiée réintroduit une ligne compacte sous les tableaux existants, sans graphe ni synthèse éditoriale;
  - `Usage jeux & joueurs` affiche sessions jouées, sessions significatives, clients utilisateurs, clients sans usage, joueurs cumulés et joueurs par session significative;
  - les colonnes compactes restent `Total`, `Dynam.` et `Gamif.`, alignées sur la segmentation usage déjà utilisée par les tableaux commerciaux;
  - `Formats & contenus joués` ventile Blind Test, Cotton Quiz, Bingo Musical et Total avec sessions, joueurs, joueurs/session, clients, contenus joués et top contenu;
  - les sessions démo sont exclues quand `flag_session_demo` est disponible;
  - chaque session est retenue seulement si le client appartient au parc facturé du mois de jeu;
  - les abonnés annuels restent inclus dans ce parc actif via le portage MRR annuel mois par mois;
  - les contenus musicaux s'appuient sur `Jeux > Playlists`, les contenus Cotton Quiz sur `Jeux > Séries` (`questions_lots` / `questions_lots_temp`);
  - les contenus non résolus proprement restent affichés en `n.d.` ou `—`;
  - la ligne Total déduplique les clients tous formats au lieu d'additionner les lignes formats;
  - la note basse du tableau `Usage jeux & joueurs` précise: `Sessions démo exclues ; Session significative = complète, démarrée, papier ou numérique avec joueurs`.

## Update 2026-05-29 - BO SaaS / V2 budget acquisition
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2`.
- resultat livre:
  - le mini-tableau `Acquisition & conversion` affiche les colonnes `Budget`, `Total`, `Écart`, `Dynam.` et `Gamif.`;
  - les budgets réutilisent `budget_facturation_pivot.php` pour `visites_uniques`, `inscrits` et `nouveaux_clients`;
  - les taux budgétés sont dérivés des volumes budgétés de la période quand les dénominateurs existent;
  - les essais gratuits restent en budget `—` tant qu'aucun objectif explicite d'essais n'est disponible.

## Update 2026-05-29 - BO SaaS / V2 simplifiée séparée
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas_v2` si le routeur applique la convention fichier `bo_facturation_pivot_{p}.php`.
- resultat livre:
  - création de `bo_facturation_pivot_saas_v2.php` sans modifier ni remplacer `bo_facturation_pivot_saas.php`;
  - header et section `Principales actions` conservés;
  - `Principales actions` occupe toute la largeur disponible;
  - la première ligne de tableaux a des cartes alignées en hauteur;
  - l'espacement entre lignes de tableaux est harmonisé;
  - les notes de lecture sous `Acquisition & conversion`, `Mouvements du parc facturé` et `Maturité du parc facturé` sont retirées;
  - rendu visible limité aux tableaux demandés;
  - première ligne: finance et mouvements/variation MRR;
  - le tableau `Mouvements & variation MRR` distingue `MRR réactivations` après `New MRR`;
  - `Expansion net` y est affiché hors MRR de réactivation, avec `Variation nette MRR` inchangée via `New MRR + MRR réactivations + expansion net - churn valeur`;
  - deuxième ligne: `Acquisition & conversion` et `Essais gratuits`;
  - troisième ligne: `Mouvements du parc facturé` et `Maturité du parc facturé`;
  - les quatre derniers tableaux utilisent le même style que les deux premiers, sans titre intermédiaire `Acquisition & cycle d'abonnement`;
  - les graphes et la section jeux sont retirés du rendu V2.

## Update 2026-05-29 - BO SaaS / graphes acquisition et mouvements
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - le graphe 3 n'est plus un espace vide: il affiche `Tunnel acquisition & conversion`;
  - les séries du tunnel sont `Visiteurs uniques`, `Comptes créés`, `Essais gratuits lancés` et `Nouveaux abonnés facturés`;
  - en vue `Mois`, les séries `Comptes créés` et `Essais gratuits lancés` sont alimentées sur la fenêtre graphique M-2/M-1/M par des agrégats dédiés, sans modifier les mini-tableaux de la période;
  - le graphe 4 est remplacé par `Entrées / sorties du parc facturé`;
  - les séries parc sont `Nouveaux abonnés`, `Réactivations`, `Churn clients net` et `Variation nette`;
  - les séries parc sont calculées par la même réconciliation stock/flux que le mini-tableau `Mouvements du parc facturé`, mois par mois sur la fenêtre graphique;
  - les graphes affichent des valeurs discrètes sur les points/barres non nuls.

## Update 2026-05-28 - BO SaaS / ajustement graphes cockpit
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - la section `Acquisition & cycle d'abonnement` affiche les 4 mini-tableaux attendus sur 2 colonnes desktop / 1 colonne mobile;
  - le graphe 1 cumule l'évolution du MRR HT, l'objectif MRR HT et les barres du parc actif facturé;
  - le doublon de graphe parc actif en position 3 est masqué;
  - le graphe en position 4 affiche l'ancienneté du parc facturé (`Actifs >= 3 mois`, `Actifs >= 6 mois`);
  - les deux graphes acquisition/conversion qui occupaient les positions 5 et 6 sont masqués.

## Update 2026-05-28 - BO SaaS / synthèse business cockpit
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - la lecture haute `Objectifs (budget)` est retiree du premier niveau de lecture;
  - une section `Synthèse business` affiche trois widgets compacts: `Performance financière`, `Tunnel acquisition`, `Parc facturé`;
  - les widgets reutilisent les agrégats déjà calculés pour les tableaux `Ventes, résultat & revenu récurrent`, `Acquisition & cycle d'abonnement` et `Parc abonnés, mouvements & variation MRR`;
  - les anciens widgets bas `Tunnel acquisition & conversion` et `Mouvements du parc facturé` ne sont plus dupliqués sous la même forme;
  - les graphiques financiers sont placés sous le tableau financier, les graphiques parc sous le tableau parc, et les graphiques acquisition sous les tableaux acquisition/cycle;
  - les tableaux détaillés `Visiteurs / prospects / clients` et `Rétention & cycle d'abonnement` sont réactivés comme preuves des widgets hauts.

## Update 2026-05-28 - BO SaaS / delta stock flux mouvements
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - le mini-tableau `Mouvements du parc facturé` réaffiche une ligne `Delta stock / flux`;
  - le delta signé suit l'équation affichée du tableau: `stock fin - stock début - nouveaux - réactivations + churn`;
  - le lien ouvre les comptes concernés par l'écart ou présents dans plusieurs flux, en `Total`, `Dynam.` et `Gamif.`;
  - les anciens tableaux redondants restent masqués du rendu standard.

## Update 2026-05-28 - BO SaaS / V3 UI acquisition et cycle
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - les anciens tableaux `Visiteurs / prospects / clients` et `Rétention & cycle d'abonnement` sont masqués du rendu standard par flag interne désactivé;
  - les 4 mini-tableaux `Acquisition & conversion`, `Essais gratuits`, `Mouvements du parc facturé`, `Maturité du parc facturé` restent visibles dans une grille compacte 2 colonnes desktop / 1 colonne mobile;
  - les colonnes compactes restent `Total`, `Dynam.` et `Gamif.`, alignées sur la segmentation usage `Dynamisation` / `Gamification`;
  - le graph `Tunnel acquisition & conversion` est remplacé par un funnel HTML Total période avec volumes et taux visiteurs -> prospects puis prospects -> abonnés facturés;
  - le graph `Mouvements du parc facturé` est remplacé par une lecture HTML stock/flux: parc début, nouveaux, réactivations, churn, parc fin;
  - aucun bouton d'ancien détail ni section repliable n'est ajouté.

## Update 2026-05-28 - BO SaaS / essais actives
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - le mini-tableau `Essais gratuits` remplace `Sans session signif.` par `Essais activés`;
  - un essai est compté comme activé s'il a au moins 1 session significative pendant l'essai;
  - la ligne est affichée immédiatement sous `Essais lancés`;
  - la grille des 4 mini-tableaux est affichée entre les graphiques 1/2 et les graphiques 3/4;
  - la ligne conserve les liens clients filtrés par usage `Total` / `Dynam.` / `Gamif.`.

## Update 2026-05-28 - BO SaaS / maturite alignee sur parc actif
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - la ligne temporaire `Autres entrées` est retirée du mini-tableau `Mouvements du parc facturé`;
  - les tranches du mini-tableau `Maturité du parc facturé` comptent désormais les mêmes clients dédupliqués que `Parc actif facturé fin`;
  - un client avec plusieurs offres actives n'est classé qu'une seule fois, selon sa plus ancienne facture ABN active.

## Update 2026-05-28 - BO SaaS / reactivations et offres en attente
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - la détection `Réactivations` ignore les offres `En attente` qui existaient avant la période mais n'étaient pas actives;
  - un client déjà facturé, sorti du parc, puis refacturé sur la période est classé en réactivation même s'il conserve une ancienne offre en attente non terminée.

## Update 2026-05-28 - BO SaaS / offres annuelles terminees et parc actif
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - le calcul MRR/parc actif ne prolonge plus une facture annuelle passée jusqu'à sa prochaine facture théorique si l'offre ABN associée est terminée avant la fin du mois affiché;
  - le stock `Abonnés actifs` et le mini-tableau `Mouvements du parc facturé` excluent donc les offres annuelles terminées du parc actif fin de période.

## Update 2026-05-28 - BO SaaS / acquisition inscrits et essais gratuits
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - le mini-tableau `Acquisition & conversion` parle désormais de `Comptes créés / inscrits` et de `Taux visiteur -> inscrits`;
  - il affiche aussi `Essais gratuits`, repris du flux d'essais lancés sur la période, puis `Taux inscrits -> essais gratuits`;
  - les valeurs d'essais gratuits réutilisent les liens de détail clients existants.

## Update 2026-05-28 - BO SaaS / alignement stock mini-tableau mouvements
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - le mini-tableau `Mouvements du parc facturé` utilise désormais les mêmes lignes MRR normalisées que la synthèse `Parc abonnés, mouvements & variation MRR` pour compter `Parc actif facturé début` et `Parc actif facturé fin`;
  - la ventilation compacte reste alignée sur la segmentation usage `Dynamisation` / `Gamification` via les sources `mrr_dynamisation` et `mrr_gamification`;
  - l'ancien comptage `active_mrr_by_month` reste disponible uniquement comme fallback quand les lignes KPI normalisées ne sont pas présentes.

## Update 2026-05-28 - BO SaaS / mini-tableaux V2 definitions et segmentation usage
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - les 4 mini-tableaux sous les graphs conservent la grille compacte 2 colonnes desktop / 1 colonne mobile;
  - les colonnes compactes sont `Total`, `Dynam.` et `Gamif.`, alignées sur la segmentation usage existante `Dynamisation` / `Gamification`;
  - `Acquisition & conversion` retire les essais du tunnel facturé, ajoute `Taux prospect -> abonné` et réutilise les agrégats `new_clients` déjà utilisés par le tableau abonnements pour `Nouveaux abonnés facturés`;
  - `Essais gratuits` sépare le flux d'essais lancés, le stock actif fin période, les essais terminés, convertis facturés, expirés sans facture et les essais activés quand `reporting_games_sessions_detail` est disponible;
  - les essais terminés / convertis / expirés sont désormais calculés depuis la même liste dédupliquée que `Essais lancés`, puis ventilés selon présence de facture ou essai expiré, afin de ne pas mélanger les essais historiques arrivant à échéance avec le flux affiché;
  - `Mouvements du parc facturé` ne contient plus de valeurs financières (`Churn valeur`, `Expansion nette`) et reste limité aux volumes début / nouveaux / réactivations / churn / fin;
  - `Maturité du parc facturé` privilégie les médianes, remplace la durée de vie des churnés par `Durée de vie médiane ABN terminés` et calcule cette durée depuis la première facture ABN liée à l'offre terminée;
  - les valeurs des mini-tableaux ouvrent les détails existants quand le périmètre est fiable: page conversion pour visiteurs/taux globaux, listing clients filtré pour prospects, essais, stocks/flux du parc et maturité;
  - le graph `Tunnel acquisition & conversion` affiche les étapes principales visiteurs, prospects et nouveaux abonnés facturés; le graph `Mouvements du parc facturé` reste volumétrique.

## Update 2026-05-28 - BO SaaS / mini-tableaux acquisition, essais, mouvements et maturite
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - sous les deux graphs de lecture commerciale, ajout d'une grille compacte de 4 mini-tableaux: `Acquisition & conversion`, `Essais gratuits`, `Mouvements du parc facturé`, `Maturité & durée de vie`;
  - les anciens tableaux `Visiteurs / prospects / clients` et `Rétention & cycle d'abonnement` restent visibles sous ces nouveaux tableaux;
  - `Acquisition & conversion` separe le flux de période: visiteurs uniques, comptes créés/prospects, taux visiteur -> prospect, essais gratuits lancés et nouveaux abonnés facturés;
  - `Essais gratuits` lit le stock fin période des essais actifs non encore facturés, leur âge moyen, les essais finissant sous 3 jours et, si la source sessions est disponible, les essais sans session significative;
  - `Mouvements du parc facturé` explique les variations du parc facturé hors essais: stock début, nouveaux facturés, réactivations, churn abonnés, churn valeur, expansion nette, stock fin;
  - `Maturité & durée de vie` affiche l'ancienneté moyenne et médiane des actifs facturés, puis la répartition des actifs par ancienneté (`< 1 mois`, `1-3 mois`, `3-6 mois`, `> 6 mois`);
  - le graph conversion devient un funnel Total période; la segmentation reste dans les mini-tableaux;
  - le graph stabilité devient `Mouvements du parc facturé`, avec marge d'axe automatique et churn affiché négativement;
  - les métriques non disponibles de façon fiable dans les requêtes actuelles restent `n/a`, notamment le taux essai -> facturé et la durée de vie observée des churnés.

## Update 2026-05-27 - BO SaaS / retention et cycle d'abonnement
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - le reporting ajoute sous `Visiteurs / prospects / clients` un tableau `Rétention & cycle d'abonnement`, orienté lecture investisseur;
  - le tableau présente l'évolution mensuelle de la période choisie, avec une ligne par mois, des sous-lignes `Dynamisation` / `Gamification` et une ligne `Total`;
  - le tableau compare `Dynamisation` et `Gamification` sur le `Churn moyen`, la durée de vie estimée, l'ancienneté moyenne des abonnements actifs, la maturité du parc actif (`Actifs >= 3 mois`, `Actifs >= 6 mois`) et les réactivations en pourcentage des acquisitions abonnés (`Réactivations / (Nouveaux abonnés + Réactivations)`);
  - le `Churn moyen` reutilise la convention `En pause` du tableau `Abonnements`, deja segmentee par usage et filtree pour eviter de compter les simples fins d'offres de comptes encore actifs;
  - la duree de vie estimee est derivee du churn mensuel moyen observe sur la periode, avec `n/a` ou `> période observée` quand la mesure n'est pas exploitable;
  - l'anciennete moyenne est calculee sur les offres abonnement actives facturees du dernier mois de periode, par usage, depuis la premiere facture positive liee a l'offre active;
  - les colonnes `Actifs >= 3 mois` et `Actifs >= 6 mois` remplacent la retention de cohorte et mesurent la part des offres actives facturees dont la premiere facture liee a l'offre active est anterieure d'au moins 3 ou 6 mois calendaires a la fin de periode;
  - les reactivations sont isolees par usage comme factures abonnement reprises apres interruption, distinctes des nouveaux abonnes, puis rapportees au total `Nouveaux abonnes + Reactivations`;
  - le tableau `Abonnements` masque `Factures` et `ARR net`, puis affiche une colonne `Reactivations` avant `Expansion net`; les valeurs ouvrent le listing des factures concernees avec le contexte `Reactivations`;
  - le tableau `Repartition par typologie` est masque par defaut par un flag local reversible, sans supprimer la logique historique;
  - le graphique `Segmentation par typologie (CA HT)` est remplace par `Stabilité du parc actif`, aligné sur la fenêtre minimale de 3 mois du graphique MRR: `Churn moyen` global en courbe, `Churn moyen N-1` en courbe pointillée, et `Actifs >= 3 mois`, `Actifs >= 6 mois`, `Réactivations` en colonnes globales;
  - le graphique `Évolution MRR / New MRR / Churn / Expansion` ajoute la série `Expansion net`;
  - en vue `Mois`, les graphiques minimum 3 mois affichent M-2, M-1 et M, et recalculent les métriques de ces trois mois avec le contexte M-3 nécessaire au churn et à l'expansion;
  - les cartes `Objectifs (budget)` affichent l'écart entre réalisé et budget en valeur absolue et en pourcentage, avec couleur vert/orange/rouge selon les seuils d'atteinte;
  - le tableau financier devient `Ventes, résultat & revenu récurrent`: il regroupe `CA HT facturé`, `MRR HT`, `ARR HT`, `ARR net` et `Résultat`, tandis que le tableau `Abonnements` ne montre plus les colonnes financières `MRR HT` et `ARR HT`;
  - ce tableau financier affiche aussi la segmentation `Dynamisation` / `Gamification`; la colonne `Écart` y est limitée au pourcentage d'écart vs budget;
  - `Abonnements` devient `Parc abonnés, mouvements & variation MRR`, synthèse compacte de période centrée sur le parc, les flux clients, les essais actifs, les mouvements MRR et la variation nette MRR, sans ligne visible `Abonnés facturés`;
  - les tableaux de synthèse apparaissent avant les graphiques, avec rappel de période; les graphiques montrent l'évolution utile jusqu'au mois sélectionné, sans mois futurs sur les vues fiscale et civile;
  - les deux graphiques principaux évitent les séries ambiguës: le graphe facturation compare CA HT facturé, objectif CA HT disponible et abonnés actifs; le graphe MRR montre le niveau MRR et la variation nette mensuelle;
  - le graphe MRR visible est limité à `MRR HT` et `Variation nette MRR`, les composantes `New MRR`, `churn valeur` et `expansion net` restant détaillées dans le tableau de synthèse;
  - les axes des deux graphiques principaux conservent une marge visuelle automatique de 12%, y compris une marge basse quand la variation nette MRR est négative;
  - les axes sont explicitement nommés (`CA HT facturé`, `Abonnés actifs`, `MRR HT`, `Variation nette MRR`) et la ligne zéro du graphique MRR est renforcée;
  - le tableau `Parc abonnés, mouvements & variation MRR` décline la synthèse en `Total`, `Dynamisation` et `Gamification`, avec ARPA calculé comme ratio propre à chaque segment;
  - les libellés visibles de la page ont été relus pour restaurer les accents français;
  - le tableau `Visiteurs / prospects / clients` sépare les métriques globales (`Visiteurs uniques`, `Démos site`) des sous-lignes par usage; celles-ci affichent `Inscrits`, puis `Avec démo`, `Essais gratuits` et `Clients` en volumes avec leur taux par rapport aux inscrits entre parenthèses;
  - les mois futurs des tableaux mensuels `Ventes et resultat`, `Abonnements`, `Visiteurs / prospects / clients` et `Jeux et joueurs` en vues `Annee fiscale` et `Annee civile` affichent des tirets, sans sous-lignes de detail ni cumul dans les totaux.

## Update 2026-05-27 - BO SaaS / page detail Expansion net
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`;
  - BO `?t=syntheses&m=facturation_pivot&p=expansion`.
- resultat livre:
  - les valeurs `Expansion net` du tableau `Abonnements` ouvrent maintenant une page externe dediee au lieu de la modale historique;
  - les sous-lignes `Mensuels` et `Annuels` ouvrent cette meme page avec un filtre `scope`;
  - la page dediee reutilise les donnees `kpiExpansionClients` calculees par le reporting SaaS, via un mode data-only du fichier SaaS, afin d'eviter une divergence de calcul;
  - le calcul detaille separe les composantes mensuelle et annuelle d'un meme client avant de produire les lignes, pour eviter qu'une variation mensuelle soit affichee dans le scope annuel lorsque le compte a aussi un annuel actif;
  - les factures annuelles du mois precedent ne generent plus une fausse baisse mensuelle compensee par une hausse annuelle: l'annuel actif porte le MRR annualise aussi pendant le mois de facture;
  - pour les baisses sans facture courante, l'offre affichee peut etre reprise depuis la facture du mois precedent;
  - le tableau externe affiche les clients a delta non nul avec lien fiche client BO, offre, scope, `MRR M-1`, `MRR M`, `Delta` et `ARR delta`;
  - le tableau de facturation `p=list` reste reserve aux factures filtrees et aux lignes `A emettre`.

## Update 2026-05-27 - BO SaaS / segmentation usage des tableaux
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`.
- resultat livre:
  - le tableau `Ventes et resultat` remplace les sous-lignes `Abonnements` / `Autres ventes` par `Dynamisation (CHR & lieux publics)` / `Gamification (Autres)`;
  - le tableau `Abonnements` remplace les sous-lignes `Mensuels` / `Annuels` par cette meme segmentation usage;
  - les sous-lignes de total multi-mois restent ouvertes par defaut et en gras;
  - les flux de periode (`Factures`, `Nouveaux`, `New MRR`, `En pause`, `Churn valeur`, `Expansion net`) sont cumules par usage, tandis que les stocks (`Abonnes`, `MRR`, `ARR`, `ARR net`, `ARPA`) restent bases sur le dernier mois de la periode, comme la ligne Total principale;
  - les valeurs MRR/ARR/ARPA affichees par segment sont derivees des memes lignes MRR normalisees que les vues detaillees, afin d'eviter un ecart entre tableau et detail;
  - les liens `MRR` / `ARR` / `ARR net` ouvrent `facturation_pivot&p=list` avec `view=mrr|arr|arr_net`, pour conserver la lecture normalisee deja dediee a ces KPI;
  - les liens `Expansion net` ouvrent `facturation_pivot&p=expansion`, y compris avec filtre `usage` sur les sous-lignes;
  - les liens `ARPA` ouvrent `facturation_pivot&p=arpa`, y compris avec filtre `usage` sur les sous-lignes;
  - les liens de stock des sous-lignes de total `Abonnements` utilisent les sources du dernier mois de periode, pour rester coherents avec les valeurs affichees;
  - les liens de total du CA par usage ouvrent le listing factures filtre sur les factures du segment.

## Update 2026-05-27 - BO offres clients / badge Essai dans Prix
- ecrans concernes:
  - BO `?t=ecommerce&m=offres_clients`;
  - BO fiche client `?t=entites&m=clients&p=view&id={id}`.
- resultat livre:
  - le rendu commun de prix des offres client affiche maintenant le badge `Essai` dans la colonne `Prix` lorsqu'une offre abonnement active est dans sa fenetre `trial_period_days` et qu'aucune facture n'est liee a cette offre;
  - le listing `Ecommerce > Offres clients` et le bloc `Offres` de la fiche client utilisent le meme helper, ce qui aligne le badge `Essai` avec les badges de remise deja visibles dans la colonne prix;
  - la regle d'essai reutilise le filtre existant des offres clients, sans modifier la facturation ni la logique Stripe.

## Update 2026-05-27 - FO place / images listing etablissements
- ecran concerne:
  - page publique `/fr/place`.
- resultat livre:
  - les cartes etablissements de `www/web/fo/modules/entites/clients/fr/fo_clients_list_bloc.php` utilisent maintenant l'URL photo directement dans `src`;
  - le rendu ne depend plus exclusivement de `vanilla-lazyload` et de `data-src` pour afficher les images du listing;
  - le chargement differe reste assure par l'attribut natif `loading="lazy"`.

## Update 2026-05-26 - BO home / activation commerciale Dynamisation
- ecran concerne:
  - BO home `?t=syntheses&m=resumes`.
- resultat livre:
  - ajout d'un bloc `Activation commerciale` sur la home BO active `bo_resumes_list.php`;
  - le bloc affiche les compteurs au chargement, puis deroule au clic un tableau filtre par categorie de comptes Dynamisation actionnables avec contact, tunnel, dates d'essai, usage, prochaine session et action recommandee; un reclic sur le compteur actif referme le tableau;
  - les lignes affichees au clic sont alignees avec les compteurs, sans troncature par top global;
  - la categorie `Inscrits Dynamisation a convertir` est limitee aux inscrits des 3 derniers mois et signale les offres ABN en attente;
  - la categorie `ABN CHR inactif ou peu actif` retient uniquement les comptes sans soiree significative sur 60 jours et n'affiche pas les offres en attente des comptes deja abonnes;
  - le statut tunnel affiche `ABN actif` des que l'abonnement depasse 90 jours;
  - les comptes TdR sont exclus du calcul, car ils suivent un fonctionnement commercial distinct; les affiliés réseau restent inclus;
  - les listings de prochaines sessions par jeu sont separes dans une section dediee avec le separateur standard de la home BO et restent au-dessus de la section `Clients`;
  - l'espacement entre les KPI haut et le bloc `Activation commerciale` est harmonise avec les autres separations de section;
  - les KPI haut `Actifs`, `Inactifs` et `CA {mois}` ouvrent les listings cibles: clients ABN/PAK, clients INS/CSO et facturation du mois courant;
  - le listing clients accepte le filtre groupe `bo_clients_pipeline_group=active|inactive` pour ces liens home;
  - les categories sont dedoublonnees et priorisees: essais gratuits Dynamisation a risque, nouveaux ABN Dynamisation a risque, essais Dynamisation actives a securiser, ABN Dynamisation inactifs/peu actifs, inscrits Dynamisation actifs a convertir;
  - le ciblage commercial s'appuie sur l'usage client `Dynamisation` (`id_solution_usage=1`) au lieu de la seule typologie CHR;
  - les essais sont evalues par dates d'essai e-commerce (`trial_period_days`) et premiere facture reelle (`numero_facture<>''`, `total_ht>0`);
  - les sessions significatives s'appuient sur `reporting_games_sessions_detail` avec joueurs et incluent aussi les sessions papier passees non-demo completes demarrees; les sessions futures non-demo completes excluent les risques inactifs critiques;
  - l'agregat SQL d'usage utilise l'alias `act_usage`, compatible avec MariaDB;
  - la disponibilite de `reporting_games_sessions_detail` est verifiee par lecture directe pour eviter un faux message d'indisponibilite sur la home BO;
  - les erreurs de calcul SQL sont affichees/loggees separement des sources indisponibles;
  - le fichier legacy `bo_resumes_list_V1.php` n'est pas modifie.

## Update 2026-05-26 - FO catalogue / demos rapides par defaut
- ecrans concernes:
  - pages publiques de detail catalogue qui incluent `web/fo/modules/jeux/portail/fr/fo_portail_jeux_demo_signup.php`, dont `/fr/jeux/cotton-blind-test/catalogue/playlist/{slug}`, `/fr/jeux/bingo-musical/catalogue/playlist/{slug}` et `/fr/jeux/cotton-quiz/catalogue/serie/{slug}`;
- resultat livre:
  - l'onglet `Démo rapide` est rendu en premiere position et actif au chargement;
  - l'onglet `Démo complète` est rendu en seconde position, reste accessible au clic et conserve la pastille `Recommandé`;
  - le style du selecteur applique l'opacite aux textes des onglets inactifs, pas au bouton complet, afin de garder la pastille `Recommandé` en couleur pleine.

## Update 2026-05-22 - BO offres clients / remises commerciales
- ecrans concernes:
  - BO `?t=ecommerce&m=offres_clients`;
  - BO fiche offre client `?t=ecommerce&m=offres_clients&p=view&id={id}`;
  - BO fiche client `?t=entites&m=clients&p=view&id={id}`;
  - BO home `?t=syntheses&m=resumes`.
- resultat livre:
  - le listing `Ecommerce > Offres clients` expose une colonne `Remise` lisible, basee sur le snapshot stocke dans `ecommerce_offres_to_clients` (`remise_nom`, `remise_pourcentage`, `prix_reference_ht`, `prix_ht`) et, pour les offres deleguees hors abonnement reseau, sur le pricing reseau dynamique `app_ecommerce_reseau_offres_hors_cadre_pricing_get`;
  - le filtre custom `Remise` (`Oui` / `Non`) permet d'isoler les offres signees avec remise commerciale ou remise reseau deleguee detectee; le filtre `Vendeur` est masque dans la barre haute;
  - la colonne `Prix HT` affiche le prix signe, le prix de base et une chip bleue de remise, sans afficher l'economie HT dans le listing;
  - la fiche detail d'une offre client affiche un bloc `Remise commerciale` avec chip, nom de remise, prix de base et prix remise quand une remise est detectee;
  - les listes externalisees d'offres, notamment le bloc `Offres` de la fiche client BO, reprennent la meme lecture de prix/remise dans la colonne prix, sans colonne `Remise` ni colonne `Prod. add.` separee;
  - les offres deleguees incluses dans l'abonnement reseau sont affichees comme prises en charge reseau (`Inclus abn reseau`) avec prix effectif `Inclus` et prix de base conserve en reference;
  - le bloc home `Dernieres offres clients` conserve seulement une chip bleue `Essai`, `Remise -x %`, `Offert` ou `Inclus abn reseau`, sans chip `Payante`; il affiche le compte delegue sous la forme `pour {nom}` quand une delegation est rattachee, et liste les offres actives datees sans filtrer sur `flag_offert` ni `prix_ht`.

## Update 2026-05-26 - BO SaaS / detail MRR attendu
- ecran concerne:
  - BO `?t=syntheses&m=facturation_pivot&p=saas`;
- resultat livre:
  - le detail au clic des KPI `MRR HT` et `ARR HT` du mois courant ajoute les clients MRR du mois precedent qui ne sont pas encore presents dans le mois courant;
  - ces lignes sont marquees `A emettre`, sans numero ni lien de facture, avec la date attendue et le montant MRR/ARR repris de la facture precedente;
  - les offres deja identifiees en pause/resiliation sont exclues du report MRR/ARR courant et des lignes `A emettre`.
  - les valeurs du tableau `Abonnements` ouvrent maintenant `?t=syntheses&m=facturation_pivot&p=list` avec une selection de factures ciblee et un bandeau de contexte;
  - les sous-lignes `Mensuels` / `Annuels` sont aussi cliquables avec une selection filtree par frequence;
  - `Expansion net` reste ouvert dans la modale historique, qui porte la comparaison `MRR M-1`, `MRR M`, `Delta`;
  - cette modale conserve la logique historique: une facture M non emise ne cree pas une perte MRR/ARR, le MRR M retombe sur M-1 et les deltas nuls sont masques;
  - les lignes `A emettre` conservent le mode de paiement quand il est connu depuis la facture precedente.

## Update 2026-05-22 - BO Stripe / suivi resiliations
- ecrans concernes:
  - BO home `?t=syntheses&m=resumes`;
  - BO `?t=ecommerce&m=offres_clients`;
- resultat livre:
  - les evenements Stripe de resiliation issus de `user_feedback_events` sont affiches comme `Stripe + suivi`;
  - le listing offres client affiche `Résiliation demandée le ...` pour la date issue de `user_feedback_events.created_at`;
  - ce wording couvre les resiliations avec feedback client et les resiliations Stripe sans raison/commentaire.
  - la page `Feedbacks EP/Stripe` limite ses filtres d'entete a `Client` et `Type d'evenement`, pour afficher uniquement `Résiliations Stripe` ou `Commentaires EC`;
  - le filtre type utilise un champ POST direct `bo_feedback_event_type`, comme les filtres custom du listing sessions, afin que la selection reste appliquee au clic dans le header BO;
  - le tableau `Feedbacks EP/Stripe` affiche une colonne triable `Résiliation effective` pour les lignes Stripe, basee sur `tags_json.cancellation_effective_at`;
  - le bloc super-admin `Backfill Stripe` n'est pas affiche dans la page; le backfill reste disponible cote global/CLI.

## Update 2026-05-22 - BO home / responsive mobile
- ecran concerne:
  - BO home `?t=syntheses&m=resumes`
- resultat livre:
  - les tableaux simples de la home utilisent en mobile `dt-responsive nowrap`, avec initialisation locale sur `.bo-resumes-datatable` et colonnes secondaires marquees `none`, pour afficher le lien `+` de depliage par ligne au lieu d'un scroll horizontal;
  - les blocs sessions calculent le nombre de sessions de la prochaine journee disponible pour chaque jeu, prennent le maximum entre jeux, puis affichent les prochaines sessions de chaque jeu jusqu'a cette limite commune pour aligner les hauteurs;
  - les blocs sessions n'affichent plus les lignes `Semaine xx`; les dates de session reprennent la couleur rouge/rose de ces anciennes lignes;
  - les liens explicites des cellules sessions sont conserves pour garder le `Ctrl+clic` / nouvel onglet natif, l'icone detail est agrandie et l'icone logs est retiree de la home;
  - sur mobile, les pastilles d'etat des sessions du jour sont placees dans le detail responsive avec l'icone session pour eviter le debordement, et sont rendues avant l'AJAX pour rester visibles dans le contenu depliable;
  - les trois cartes sessions utilisent une ligne HTML par session et `dt-responsive` sur mobile pour deplier la colonne `Action` via le lien `+`, sans scroll lateral;
  - les colonnes empilees sous tablette retrouvent un espacement vertical entre cartes, notamment entre `Bingo Musical` et `Cotton Quiz` dont l'ordre mobile est pilote par `order-*`;
  - les entetes clients, commerce et feedback suivent le meme schema visuel `badge + titre + lien optionnel`;
  - le bloc `Dernieres connexions clients` ajoute `Voir tous les logs` vers `Tracking > Clients logs`;
  - les liens home `Voir toutes les resiliations` et `Voir tous les feedbacks` ouvrent `Tracking > Feedbacks EP/Stripe` avec le filtre `Type d'evenement` preselectionne sur `Résiliations Stripe` ou `Commentaires EC`;
  - dans `Resiliations abonnes`, le badge source distingue `Portail Stripe` et `BO / legacy` au lieu d'afficher `Stripe + suivi`;
  - les blocs commerce reprennent la meme grille que les blocs clients: `Dernieres offres clients` a gauche et `Resiliations abonnes` a droite;
  - `Dernieres offres clients` remplace l'ancien bloc factures et lit les offres client actives non offertes depuis `ecommerce_offres_to_clients`, avec badges `Essai` pour les essais abonnement en cours sans facture liee et `Payante` sinon.
  - `Dernieres offres clients` affiche `Essai en cours` et `Resiliation le ...` a cote du montant, separes par `|`, pour eviter d'augmenter la hauteur de ligne.
  - dans les blocs `Clients`, `Commerce` et `Feedback Utilisateurs`, le gras explicite est reserve aux noms de clients des lignes du jour; les titres, offres, dates et valeurs de feedback restent en graisse normale.
  - dans `Resiliations abonnes`, `Planifiee` est colore en orange et `Terminee` en rouge; la date `Enregistree le ...` ne retombe plus sur `date_maj` et n'est affichee que lorsqu'un feedback Stripe fournit une date; le motif Stripe est affiche a cote du montant pour limiter la cellule client a trois lignes.

## Update 2026-05-21 - BO Tracking / Feedbacks EP/Stripe
- ecran concerne:
  - BO `?t=tracking&m=clients_feedback_events`
- resultat livre:
  - le menu `Tracking` ajoute `Feedbacks EP/Stripe` sous `Clients [ nav. espace pro ]`;
  - la page liste les feedbacks EP et Stripe stockes dans `user_feedback_events`;
  - la liste affiche date, client, contexte, surface, note, commentaire, tags et session; les colonnes `Page` et `Statut` ne sont plus rendues dans le tableau pour laisser plus de place au commentaire;
  - les libelles de feedback et tags sont nettoyes des emoji et des suffixes encodes en `????` a l'affichage pour rester lisibles dans le BO;
  - les feedbacks Stripe affichent des libelles BO courts (`Résiliation Stripe`, `Portail Stripe`) et masquent les tags techniques (`stripe_subscription_id`, `stripe_event_id`, `id_offre_client`, etc.) ainsi que la note interne de dedoublonnage pour eviter les debordements visuels;
  - apres backfill ponctuel, le formulaire super-admin `Backfill Stripe` a ete retire de la page;
  - le tableau BO est compacte pour desktop: colonnes proportionnees, suppression du `nowrap` DataTables et retour a la ligne controle afin de garder les colonnes visibles; le repli `dt-responsive nowrap` est conserve uniquement sur mobile;
  - la page est en lecture seule et expose des filtres sur client, contexte, note technique et statut.

## Update 2026-05-21 - BO home / sessions du moment
- ecran concerne:
  - BO home `?t=syntheses&m=resumes`
- resultat livre:
  - les blocs `Blind Test`, `Cotton Quiz` et `Bingo Musical` affichent maintenant les sessions sur 3 lignes: client/date, thematique/horaire, format/participants;
  - les trois blocs sessions sont alignes sur la premiere ligne de la home, dans trois colonnes distinctes; le wrapper du bloc `Cotton Quiz` reprend la meme structure que `Blind Test` et `Bingo Musical` pour conserver la meme largeur de colonne;
  - les blocs `Dernieres connexions clients` et `30 derniers inscrits` sont repositionnes sous les sessions, cote a cote sur desktop;
  - chaque bloc jeu home affiche uniquement la prochaine journee contenant au moins une session a venir pour ce jeu;
  - le lien de chaque bloc jeu devient `Voir toutes les prochaines sessions` et pointe vers le listing sessions filtre sur le jeu, `Session complete = Oui`, `Demo = Non` et `Periode = A venir`;
  - chaque bloc affiche le format de session depuis `championnats_sessions.flag_controle_numerique` sous la forme `[Numerique]` ou `[Papier]`;
  - le bloc Quiz n'affiche plus les prefixes techniques `QZ {id}` ni le chip `NEW ! V2`; le libelle jeu reprend le libelle compact des series quand disponible;
  - le bloc Bingo n'affiche plus le chip `NEW ! V3` ni les stocks de grilles `Papier` / `Numerique`;
  - l'espacement des trois lignes est uniformise;
  - la colonne d'actions a droite affiche l'icone `ti-arrow-circle-right` vers la fiche detail session au-dessus de l'icone historique `ti-pulse` vers les logs, via `championnats_sessions.id_securite`;
  - l'etoile de statut n'est plus affichee dans ces blocs home;
  - les compteurs participants suivent une regle BO explicite sur la home, le listing BO sessions et la fiche detail session: les inscrits/participations probables restent affiches, puis les participants reels sont ajoutes des que la session est en cours ou terminee pour permettre le comparatif;
  - libelles: fiche detail `Inscrits` / `Participants`; home et listing en compact `Ins. : n / Part. : n / max`;
  - correctif retour recette 2026-05-21 16:11: la home applique le compact via son fallback local si le helper BO sessions n'est pas charge, et la liste sessions selectionne `nb_joueurs_max` pour afficher `/ max`;
  - correctif retour recette 2026-05-21 16:15: la jauge `/ max` est preservee avant enrichissement runtime et retombe sur la jauge d'offre client si la colonne session est vide; la pastille d'etat home est deplacee dans la colonne actions au-dessus des icones;
  - correctif lien home 2026-05-21 16:15: les liens vers `Animations > Sessions` ne forcent plus tri/page/date et gardent seulement `bo_session_game`, `bo_session_demo=0`, `bo_session_complete=1`;
  - correctif retour recette 2026-05-21 16:23: si la jauge reste absente, le helper relit le detail session comme la view pour recuperer `nb_joueurs_max`; les libelles `Ins. / Part.` de la home ne sont plus cliquables;
  - correctif UI view session 2026-05-21: marge sous `Format` dans `Thematique`, marge au-dessus du fallback resultats, et message `pas encore ete jouee` pour les sessions en attente;
  - addendum view session 2026-05-21: les details des inscrits probables ne s'affichent que comme fallback, quand il n'y a ni participants reels, ni podium, ni classement;
  - sur la home, les sessions du jour affichent une pastille d'etat `En attente`, `En cours` ou `Termine` sans relire l'etat au-dela du helper participants deja appele;
  - les listes home sont bornees aux sessions non-demo completes de la prochaine journee disponible par jeu et liees a une offre client active (`ecommerce_offres_to_clients.id_etat=3`);
  - les listes home sont triees par date puis heure de debut croissante, avec client / format uniquement en criteres secondaires;
  - le listing `Animations > Sessions` propose un filtre `Periode` (`A venir` / `Passees`) applique sur `championnats_sessions.date`;
  - quand `Periode = A venir` est actif et qu'aucun tri manuel n'est applique, le listing affiche les sessions les plus proches en haut;
  - optimisation charge: les tables runtime participants ne sont lues que pour les sessions terminees; les sessions non terminees lisent seulement le compteur de participations probables, puis affichent aussi `nb_joueurs_max`;
  - optimisation charge home: le calcul leger des compteurs ne reutilise plus le helper complet du listing/detail sessions et ne relit plus `app_session_get_detail()` seulement pour recuperer la jauge;
  - optimisation charge home 2026-05-21: les compteurs `Ins. / Part.` et la pastille d'etat sont maintenant charges apres rendu initial via un endpoint JSON batch `sessions_metrics_ajax`;
  - optimisation charge home 2026-05-21 bis: le bloc `Suivi mensuel`, identifie comme le cout serveur restant le plus lourd, est charge apres rendu initial via `monthly_metrics_ajax`;
  - nettoyage home 2026-05-21: le bloc `Suivi mensuel` n'est plus rendu sur la home et n'est plus appele par le front;
  - les liens de liste complete pointent vers `Animations > Sessions` avec le filtre `Jeu` (`bo_session_game=blindtest|quiz|bingo`) au lieu de l'ancien filtre technique `id_type_produit`;
  - les blocs sessions de la home sont ordonnes `Blind Test`, `Bingo Musical`, puis `Cotton Quiz`;
  - le bloc `30 derniers inscrits` est renomme `Derniers inscrits`, limite a 10 lignes triees par `clients.date_ajout DESC`, et son lien secondaire pointe vers le listing clients filtre sur `Etat = Prospects` avec tri `date_ajout DESC`.
  - le bloc commerce `Abonnement arrivant à échéance` est remplace par `Dernieres resiliations abonnes`;
  - cette liste s'appuie sur les offres abonnement payantes (`ecommerce_offres_to_clients` + `ecommerce_offres.id_offre_type=2`) avec `date_fin` renseignee, afin de couvrir Stripe et la voie legacy/BO;
  - `user_feedback_events` enrichit les lignes Stripe quand un suivi de resiliation existe (`context_key=stripe_subscription_cancellation`), avec ou sans feedback/commentaire client; la voie legacy/BO reste couverte par les offres client avec `date_fin`.
  - le bloc commerce `50 dernieres commandes` est renomme `Dernieres commandes`, limite a 30 lignes et ajoute le lien `Voir toutes les factures` vers `?t=ecommerce&m=factures`;
  - cette liste ne lit plus les offres client: elle s'appuie sur les factures reellement editees dans `ecommerce_commandes` avec `numero_facture<>''`, en reprenant la date facture normalisee du pivot SaaS;
  - `Dernieres resiliations abonnes` est limite a 10 lignes et `Dernieres commandes` a 15 lignes pour eviter de surcharger la home;
  - `Dernieres resiliations abonnes` ajoute un lien vers le listing `Ecommerce > Offres clients` filtre par le nouveau filtre custom `Résiliation=Oui`;
  - `Dernieres resiliations abonnes` est trie par `date_fin DESC` pour rester dans le meme ordre que le listing complet;
  - des separateurs visuels de section restaurent un filet et de l'espace vertical entre les grands blocs de la home, y compris entre les blocs sessions et les blocs `Dernieres connexions clients` / `Derniers inscrits`; le `margin-bottom` global des `.card-box` est neutralise dans `#resumes-list` pour eviter un cumul avec ces separateurs;
  - `Dernieres commandes` affiche une puce seulement sur la premiere facture d'une offre client: `New` sans offre terminee anterieure, `Renew` si une offre client terminee existe deja pour ce client avant la facture.
  - les KPIs du haut sont recentres sur 5 indicateurs: inscrits, abonnes payants, essais en cours, clients CSO et CA HT mensuel;
  - le KPI `Clients payants` compte les offres client actives non offertes, sur le meme perimetre que le listing ouvert au clic (`ecommerce_offres_to_clients.id_etat=3`, `flag_offert=0`);
  - correctif KPI essais 2026-05-21: `Essais en cours` ne s'appuie plus sur l'ancien module BO `ecommerce_formules_declinaisons_to_clients`; il compte les clients distincts avec offre abonnement payante active dont la periode d'essai ecommerce est en cours (`trial_period_days>0`, `date_debut<=CURDATE()<date_debut+trial_period_days`) et sans facture editee liee a cette offre (`id_offre_client` + `id_client` + `numero_facture<>''`);
  - le listing `Ecommerce > Offres clients` expose un filtre custom `Trial` (`Oui` / `Non`) ajoute via `bo_offres_clients_filter_extend`, sans faux champ `$module_champs`;
  - le listing `Ecommerce > Offres clients` expose aussi un filtre custom `Résiliation` (`Oui` / `Non`) pour retrouver les offres abonnement payantes avec `date_fin` renseignee;
  - ce filtre suit le modele audite de `bo_sessions_filter_extend`: HTML custom + SQL custom injecte dans `$sql_bdd_filtre`, afin que compteur, liste, tri et pagination restent sur le meme SQL master;
  - le listing `Ecommerce > Offres clients` enrichit la colonne `Commentaire`, si un suivi Stripe de resiliation existe pour la souscription, avec la source `Stripe + suivi`, le libelle et l'eventuel commentaire client;
  - le lien du KPI `Essais en cours` pointe vers `Ecommerce > Offres clients` avec `id_etat=3`, `flag_offert=0` et `Trial=Oui`;
  - les liens KPI `Inscrits` et `Clients CSO` ouvrent le listing clients trie par `date_ajout DESC`;
  - le KPI `Clients payants` est aligne sur le compteur du listing `Offres clients` cible (`Etat=Active`, `Offert=Non`).
  - le KPI `CA HT mensuel` remplace `Sessions a venir`, somme les factures editees du mois courant avec la date facture normalisee du reporting `facturation_pivot`, et pointe vers `Syntheses > facturation_pivot > SaaS`;
  - correctif home 2026-05-26: les KPI haut reviennent au perimetre V1 `Actifs`, `Inactifs`, `Activation (30j)`, `Power Users (30j)`, `Conversion (Globale)` et `CA {mois courant}`;
  - la fiche detail session affiche sous la puce `En cours` le `Morceau courant` ou la `Question courante` via les helpers du listing sessions;
  - le bloc super-admin `Feedback questions` devient `Feedback Utilisateurs` et affiche les 15 derniers feedbacks espace pro issus de `user_feedback_events`, hors resiliations Stripe deja remontees dans le bloc resiliations;
  - `Feedback Utilisateurs` ajoute un lien vers `Tracking > Feedbacks EP/Stripe`;
  - les sections `Opérations`, `Bingo` et `App.` sont masquees du menu BO, sans supprimer les routes accessibles directement;
  - correctif home 2026-05-26: le bloc `Suivi mensuel` est reintegre en bas de page via l'endpoint sans layout `monthly_metrics_ajax`, afin de ne pas bloquer le rendu initial, avec comparaison dynamique N / N-1;
  - correctif home 2026-05-26: le bloc `Surveillance des donnees` est de nouveau affiche sous le `Suivi mensuel`, avec separateur visuel dedie.

## Update 2026-05-20 - BO listing sessions / harmonisation jeux
- ecran concerne:
  - BO `?t=championnats&m=sessions&p=list`
- resultat livre:
  - les filtres legacy `Ope evenement`, `Privee` et `Session speciale` sont masques;
  - le filtre technique `Type` est remplace par un filtre `Jeu` qui regroupe les types par jeu: `Blind Test`, `Bingo Musical`, `Cotton Quiz`;
  - un filtre `Format` filtre les sessions sur `flag_controle_numerique` (`Numerique` / `Papier`);
  - la colonne `Date` devient `Date & heure` et n'affiche plus la saison;
  - la colonne `Jeu` retire les chips des nouveaux types et le listing inline des joueurs, affiche les series Quiz au-dessus du format et harmonise l'etat courant;
  - la colonne `id` affiche `id_lots` pour Quiz, `id_playlist` pour Blind Test et `id_playlist_client` pour Bingo.
  - le tableau conserve la reduction responsive sur mobile, mais force sur desktop des colonnes proportionnees et du wrapping sans `dt-responsive nowrap` afin de garder toutes les colonnes visibles.

## Update 2026-05-20 - BO fiche detail client / stats et sessions
- ecran concerne:
  - BO `?t=entites&m=clients&p=view&id={id}`
- resultat livre:
  - les stats jeux du bloc principal reprennent le contexte deja calcule pour l'EC `Ma communaute` via `app_client_joueurs_dashboard_get_context`;
  - le bloc principal affiche le total des sessions organisees et des participants inscrits, puis le detail par jeu comme dans l'EC;
  - une note sous les stats precise que leur perimetre est limite aux sessions non-demo, completes, avec participants inscrits ou sessions papier;
  - le bloc `Sessions` liste toutes les sessions liees au client, y compris demos et sessions incompletes;
  - le bloc `Sessions` affiche maintenant `Thematique` au lieu de `# Produit`, avec libelle compact des series Quiz ou nom de playlist;
  - le bloc `Sessions` affiche maintenant `Participants` au lieu de `Privee`, avec `joueurs` ou `equipes` selon le jeu;
  - les colonnes `Demo` et `Complete` indiquent visuellement les flags `flag_session_demo` et `flag_configuration_complete`;
  - le bloc principal revient en demi-page avec le bloc `Contacts` a cote;
  - le bloc principal affiche en haut les informations publiables/pilotables par le client: statut `online`, premiere photo, accroche, descriptif et liens publics, avec un rendu empile;
  - `id_client` revient dans la zone technique historique avec l'identifiant Stripe et les liens `Voir la page sur le site` vers `/fr/place/{slug}` / `Voir la page agenda (QR code)` vers `/place/{code}`;
  - les comptes TdR affichent les sources prioritaires LP reseau sous le bouton `Voir / gérer les affiliés`: logo LP, visuel principal LP et couleurs LP dediees quand elles sont renseignees;
  - le bloc `Emails transactionnels` est traite comme legacy: l'ancien affichage BO lit `id_email_transactionnel`, tandis que le flux courant documente cote AI Studio journalise par `code_email_transactionnel`;
  - `Remises` est place sous `Offres`;
  - les blocs generiques `Informations` et `Photo` sont masques;
  - les doublons de bas de page deja presents en haut (`Offres`, `Sessions`, `Factures`, `Logs`, `Emails transactionnels`, `Contacts`) sont masques;
  - les blocs bas `Equipes`, `Evenements` et `Reseau` sont masques.

## Update 2026-05-20 - BO fiche detail session / id produit
- ecran concerne:
  - BO `?t=championnats&m=sessions&p=view&id={id}`
- resultat livre:
  - le bloc `Informations` n'affiche plus `Id. produit` pour Quiz, car `Id. lots (Quiz)` porte le rattachement utile;
  - le champ est renomme `id.playlist` pour Blind Test;
  - le champ est renomme `id.playlist_client` pour Bingo Musical;
  - le libelle legacy `Id. produit` reste en fallback pour les types historiques non couverts.

## Update 2026-05-20 - BO fiche detail session / resultats
- ecran concerne:
  - BO `?t=championnats&m=sessions&p=view&id={id}`
- resultat livre:
  - le bloc separe `Equipes participantes` / `Joueurs participants` est retire;
  - le titre du bloc `Resultats` affiche le total de participants sous la forme `[x equipes]` pour Quiz ou `[x joueurs]` pour Blind Test/Bingo;
  - le tableau `Classement complet` reste la source de detail des participants.

## Update 2026-05-20 - BO fiche detail session / liens internes
- ecran concerne:
  - BO `?t=championnats&m=sessions&p=view&id={id}`
- resultat livre:
  - le bloc `Informations` ajoute une ligne `Logs` sous `Token`, pointant vers `games/logs_session.html?sessionId={id_securite}`;
  - les champs `Client` et `Offre client` pointent vers leurs fiches BO respectives;
  - les noms de series Cotton Quiz du bloc `Thematique` pointent vers `Jeux > Series Cotton Quiz`;
  - les thematiques Blind Test et Bingo pointent vers la fiche BO de playlist correspondante.

## Update 2026-05-20 - BO fiche detail session / photos podium
- ecran concerne:
  - BO `?t=championnats&m=sessions&p=view&id={id}`
- resultat livre:
  - le bloc `Photo` generique du master est masque pour la fiche detail session;
  - un bloc `Photos` dedie est affiche sous le bloc `Informations`;
  - ce bloc liste les photos de podium disponibles dans `app_session_results_get_context`, avec rang, libelle participant/equipe et score ou libelle de phase;
  - les images sont rendues en cartes responsives avec hauteur stable, recadrage propre et lien vers l'image originale.

## Update 2026-05-20 - BO fiche detail session / informations
- ecran concerne:
  - BO `?t=championnats&m=sessions&p=view&id={id}`
- resultat livre:
  - la fiche detail session n'utilise plus le bloc `Informations` generique du master;
  - le bloc cible masque `Saison` et les champs legacy application/evenement/diffusion;
  - `Id. produit` reste visible;
  - `Id. lots (Quiz)` affiche `championnats_sessions.lot_ids` quand il est renseigne;
  - `Code` devient `Code session public`, car il porte encore l'URL agenda publique `/fr/agenda/{slug_client}/{code_session}`.

## Update 2026-05-20 - BO fiche detail session
- ecran concerne:
  - BO `?t=championnats&m=sessions&p=view&id={id}`
- resultat livre:
  - la fiche detail session affiche une thematique avant les lots;
  - les sessions Cotton Quiz composees de plusieurs series affichent chaque nom de serie;
  - les lots affiches viennent des colonnes `championnats_sessions.lot_1`, `lot_2`, `lot_3`;
  - le bloc participants utilise le libelle adapte au jeu (`Equipes participantes` pour Quiz, `Joueurs participants` pour Blind Test/Bingo) et ne propose plus l'ajout manuel d'equipe;
  - les resultats reprennent le contexte podium/classement commun `app_session_results_get_context`.

## Update 2026-05-20 - BO Jeux / concordance sessions
- ecrans concernes:
  - BO `?t=jeux&m=playlists&p=view`
  - BO `?t=jeux&m=series&p=view`
  - BO `?t=championnats&m=sessions&p=list`
- resultat livre:
  - les liens `Session BO` du bloc `Sessions liees` utilisent un style visible sur fond clair;
  - la liste BO des sessions passe `lot_ids` a `app_jeu_get_detail`, afin que les informations de jeu Cotton Quiz V2 soient resolues a partir des lots réellement associes a la session;
  - l'audit de concordance releve que les compteurs client haut de page, le bloc sessions client et la fiche detail session n'ont pas encore tous le meme perimetre fonctionnel.

## Update 2026-05-20 - BO Jeux / sessions non-demo
- ecran concerne:
  - BO `?t=jeux&m=dashboard`
  - BO `?t=jeux&m=playlists`
  - BO `?t=jeux&m=series`
- resultat livre:
  - les compteurs `Passees`, `A venir`, `En cours` de la section BO `Jeux` excluent les sessions demo quand `championnats_sessions.flag_session_demo` existe;
  - les blocs `Sessions liees` des fiches playlists et series appliquent la meme exclusion;
  - les series temporaires `T` sont reliees aux sessions Cotton Quiz via les tokens `T{id}` presents dans `championnats_sessions.lot_ids`;
  - l'agregat des series `T` reste limite aux lignes chargees pour conserver le correctif de performance des listes.

## Update 2026-05-19 - BO Jeux V1 lecture seule
- ecran concerne:
  - BO `?t=jeux&m=dashboard`
  - BO `?t=jeux&m=playlists`
  - BO `?t=jeux&m=series`
- resultat livre:
  - une nouvelle section BO `Jeux` est ajoutee pour les super-admins, sans remplacer les menus historiques `Bingo` et `App.`;
  - le dashboard donne acces aux playlists musicales et aux series Cotton Quiz;
  - les playlists affichent origine estimee, statut, auteur/client, rubrique, difficulte, nombre de morceaux, usage detecte Blind Test/Bingo Musical, compteurs sessions et derniere utilisation;
  - les series Quiz affichent le type reel `L` ou `T` quand disponible, origine estimee, statut, auteur/client, rubrique, difficulte, nombre de questions, compteurs sessions et derniere utilisation;
  - les fiches detail restent en lecture seule avec alertes qualite simples, contenus associes et sessions liees;
  - les actions sensibles restent hors V1: activation/desactivation, visibilite catalogue, validation communaute, edition, suppression, actions groupees et logs admin.

## Update 2026-05-18 - Catalogue Cotton Quiz / difficulte 3 niveaux
- ecrans concernes:
  - `/fr/jeux/cotton-quiz/catalogue`
  - `/fr/jeux/cotton-quiz/catalogue/serie/{seo_slug}`
- resultat livre:
  - le catalogue public Cotton Quiz utilise la meme convention que la bibliotheque EC Pro;
  - `1` s'affiche `Facile`, `2` s'affiche `Moyen`, et `3` s'affiche `Difficile`;
  - les anciennes valeurs `4` ou `5` sont temporairement affichees `Difficile` avant migration legacy;
  - les cartes catalogue et les fiches serie partagent cette normalisation;
  - Blind Test et Bingo Musical restent sur leur cotation directe `1..3`.

## Update 2026-05-18 - Catalogues publics / `A la une`
- ecrans concernes:
  - `/fr/jeux/cotton-quiz/catalogue`
  - `/fr/jeux/cotton-blind-test/catalogue`
  - `/fr/jeux/bingo-musical/catalogue`
- resultat livre:
  - les trois catalogues publics utilisent maintenant un helper FO commun pour l'onglet `A la une`;
  - la selection publique est limitee a 12 contenus Cotton par jeu;
  - la regle est alignee sur le `preset=now` de la bibliotheque EC Pro: contenus du moment via `jour_associe_debut/fin` en priorite, puis creation recente dans ce groupe, puis popularite 365 jours par jeu si l'agregat existe, sinon `id DESC`;
  - Cotton Quiz conserve le filtre qualite catalogue: au moins une question, reponse non vide et au moins une proposition non vide par question;
  - les filtres par rubrique restent inchanges.

## Update 2026-05-18 - LP reseau / retour apres demo
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - les formulaires de demos LP transmettent deja le contexte reseau au script de creation;
  - les scripts publics Quiz, Blind Test et Bingo Musical ajoutent maintenant `return_url` au lien organizer `/master/{token}` quand la demo vient d'une LP reseau/operation;
  - l'URL de retour est reconstruite cote serveur depuis `lp_demo_context` et `lp_network_slug`, sans accepter de destination libre postee.

## Update 2026-05-18 - LP reseau / visuel principal non recadre
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - le visuel principal LP reseau est rendu avec une classe dediee `lp-operation-hero-visual`;
  - la LP conserve le ratio reel du fichier servi et borne seulement sa hauteur visuelle pour eviter les images trop hautes;
  - le recadrage serveur n'est plus la strategie du hero LP: le helper global redimensionne le media en largeur, sans hauteur imposee.

## Update 2026-05-14 - BO contrats reseau / offres hors cadre
- ecran concerne:
  - BO `ecommerce/reseau_contrats`
- resultat livre:
  - l'attribution BO d'une offre deleguee hors cadre peut reussir meme sans activation cadre, si le helper global retourne `ok=1` et une `id_offre_client_deleguee`;
  - les lignes `offre_deleguee_hors_cadre` exposent une action dediee `Terminer l'offre hors cadre`;
  - cette action cible explicitement une offre client et ne supprime pas l'affiliation reseau;
  - le bouton `Desactiver` reste reserve aux offres incluses/cadre;
  - `Supprimer l'affiliation` reste une action de rattachement reseau, distincte de la terminaison d'offre.

## Update 2026-05-13 - LP reseau / mention connexion compte existant
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - le CTA principal final reste inchange et pointe toujours vers le parcours signup affilie `/utm/reseau/{slug}`;
  - une mention secondaire sous le CTA final rassure les utilisateurs deja inscrits;
  - seul le texte `Connecte-toi` est cliquable;
  - le lien utilise `/utm/reseau/{slug}/signin`, afin de conserver le contexte TdR avant affichage de `signin`;
  - aucune modification des wordings principaux, badges, stats reseau, demos ou logique d'abonnement.

## Update 2026-05-12 - LP reseau / bloc preuve sociale
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - un bloc de preuve sociale peut s'afficher sous les demos, uniquement si les stats reseau passent les seuils commerciaux serveur;
  - indicateurs V1: etablissements affilies inscrits, sessions de jeu programmees, joueurs deja accueillis;
  - le bloc est masque entierement si moins de deux indicateurs passent les seuils, sauf indicateur unique tres fort;
  - le compteur joueurs depend uniquement de l'agregat `reporting_games_players_monthly`; s'il est absent ou vide, il est ignore sans erreur.

## Update 2026-05-12 - LP reseau / couleurs dediees TdR
- ecrans concernes:
  - BO fiche client TdR `www/web/bo/www/modules/entites/clients`
  - LP publique `/lp/reseau/{slug}` et compat `/lp/operation/{slug}`
- resultat livre:
  - la fiche client TdR expose deux couleurs dediees a la LP reseau, au meme endroit que le logo et le visuel prioritaires LP;
  - ces couleurs sont stockees sur le compte TdR, separent la personnalisation LP du design reseau complet et acceptent uniquement des valeurs `#RRGGBB`;
  - la LP les lit en priorite et, si elles sont vides, revient directement aux fallbacks Cotton sans reprendre les couleurs du design reseau;
  - le rendu public expose aussi les variables CSS locales `--lp-network-primary` et `--lp-network-secondary`, sans changer les routes, CTA, badges ni logique de dates.

## Update 2026-05-11 - Abonnement reseau / echeance date_fin
- ecrans/traitements concernes:
  - cron `www/web/bo/cron_routine_bdd_maj.php`
  - BO `ecommerce/offres_clients` pour les abonnements reseau
- resultat livre:
  - un `Abonnement reseau` actif avec `date_fin` strictement passee est maintenant termine automatiquement par la routine BDD;
  - la cloture conserve la `date_fin` du support et appelle la finalisation reseau canonique pour archiver le runtime;
  - les offres incluses actives rattachees par `reseau_id_offre_client_support_source` sont fermees dans le meme flux;
  - a la creation ou sauvegarde BO d'un support avec `date_fin`, les incluses actives liees recuperent la meme date;
  - les offres propres des affilies et les offres deleguees hors cadre ne sont pas modifiees par ce traitement.

## Update 2026-05-11 - LP reseau / fallback demos `A la une`
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - les contenus reseau partages restent prioritaires et continuent de piloter les cartes de demos quand au moins un contenu actif est defini;
  - en absence de contenu reseau partage, la LP construit maintenant le fallback 3 jeux depuis les contenus Cotton `A la une`: fenetre `jour_associe_debut/fin` en priorite, sans dependance a `flag_begin` ni `flag_une`, puis creation recente dans ce groupe, puis popularite 365 jours si disponible;
  - les 3 demos historiques restent les garde-fous stables: Blind Test `29`, Bingo Musical `106`, Cotton Quiz `175`;
  - la logique reste locale a la LP et ne charge pas le module bibliotheque PRO.

## Update 2026-05-11 - LP reseau / rattachement des sessions demo
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - toute demo lancee depuis une LP reseau/operation valide transmet le slug canonique public de la TdR, pas son id client;
  - les scripts publics des trois jeux resolvent ce slug cote serveur et creent la session demo sur le compte TdR si le slug pointe bien vers une tete de reseau;
  - le choix du contenu affiche reste independant du compte porteur: contenus reseau, fallback `A la une` et fallback stable suivent la meme regle de rattachement;
  - les demos hors LP reseau/operation gardent le compte demo standard `1557`.

## Update 2026-05-11 - UI branding LP reseau / operation
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - le hero affiche un co-branding discret `[logo partenaire] x [logo Cotton]` en petites pastilles separees quand un logo LP dedie est defini; sans logo partenaire, Cotton reste affiche seul mais dans un format reduit;
  - le bandeau 3 arguments utilise un fond plus doux, derive en teinte claire des couleurs LP dediees quand elles existent, sinon blanc/neutre;
  - le bloc contexte reseau/operation n'est plus un fallback automatique: il est rendu seulement si la surcouche BO de l'abonnement reseau est active et qu'un contenu exploitable existe;
  - le bloc contexte rendu sert d'explication d'operation/invitation partenaire, avec label `Invitation partenaire`, carte claire, accent couleur LP, logo ou visuel LP disponible;
  - les accents LP alimentent les titres et numeros du mode d'emploi avec fallbacks lisibles;
  - aucun changement de route, CTA href, formulaire demo, logique d'affiliation, champ BO ou schema DB.

## Update 2026-05-11 - Passe editoriale LP reseau / operation
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
- resultat livre:
  - la LP reseau/operation conserve la structure et les parcours existants, mais ses wordings publics sont recentres sur le reseau, distributeur ou partenaire qui porte l'invitation;
  - avec abonnement reseau actif, le hero affiche `{TdR} t'invite a animer ton etablissement`, un CTA `Lancer une premiere animation`, et une accroche d'acces a des animations pretes a lancer jusqu'a la date de fin si elle est fiable;
  - sans abonnement reseau actif, le hero affiche `{TdR} t'invite a rejoindre son espace d'animation`, un CTA `Participer avec mon etablissement`, et aucune promesse d'acces gratuit/offert;
  - les badges dates restent `Du ... au ...` ou `Jusqu'au ...`; les fallbacks deviennent `Animations incluses` et `Invitation partenaire`;
  - etat courant apres passe UI branding: le bloc contexte n'est plus rendu comme fallback generique; il est reserve a la surcouche BO active et utile;
  - la section demos parle d'animations proposees/pretes a lancer, avec CTA `Voir une animation exemple`, sans modifier les formulaires ni les endpoints de demo;
  - aucun champ BO, schema DB, route, tunnel signup/signin ou logique d'affiliation n'est modifie.

## Update 2026-05-11 - Correctif LP reseau / abonnement reseau
- ecrans concernes:
  - `/lp/reseau/{slug}`
  - `/lp/operation/{slug}`
  - BO `ecommerce/offres_clients` pour les abonnements reseau
- resultat livre:
  - le CTA public de la LP reseau est toujours reconstruit avec le slug canonique de la TdR resolue et pointe vers le tunnel PRO `/utm/reseau/{slug_tdr}`;
  - la disponibilite V1 de la LP reseau ne depend plus de `clients.online`: un compte TdR existant avec slug canonique valide est publiable, meme sans abonnement reseau actif;
  - le slug public sauvegarde en BO et le slug courant de l'URL ne deviennent pas la cible du CTA;
  - les textes par defaut suivent le marketing Cotton: sans abonnement actif, invitation a rejoindre Cotton sans promesse gratuite/offerte; avec abonnement actif, mention claire des jeux Cotton offerts/gratuits et badge `Du ... au ...`, `Jusqu'au ...` ou `Jeux Cotton offerts` selon les dates disponibles;
  - la structure publique est: hero, bandeau 3 arguments Cotton, bloc contexte reseau/operation si surcouche BO active utile, puis section jeux;
  - le bloc contexte reprend le logo ou visuel disponible et les champs BO actifs (`Titre`, `Accroche`, `Description`) uniquement comme surcouche sous le bandeau; le hero reste genere automatiquement selon l'etat actif/inactif;
  - la section jeux affiche les contenus reseau selectionnes quand ils existent, sinon les 3 jeux fallback historiques; le mode d'emploi est harmonise en tutoiement;
  - le bloc public technique `Le parcours suivant conserve...` est supprime du rendu;
  - sans couleurs/visuel LP dedies, la LP reprend les fallbacks visuels historiques: hero `bg-color-3`, CTA `btn-color-5`, sections 2/8 violettes et image generique `offre-essai/section-01.jpg`;
  - le badge hero utilise la couleur secondaire LP avec contraste automatique quand elle existe;
  - le BO affiche `Contexte affiche sur la LP reseau`, retire les champs CTA visibles, et conserve le slug public comme compatibilite non exploitee en V1.

## Update 2026-05-07 — LP operations distributeurs / marques V1
- ecran concerne:
  - `/lp/operation/{slug}`
  - fallback direct possible via `/lp/lp.php?utm_source=reseau&utm_campaign=affiliation&utm_term={slug}&utm_medium=landing-operation`
- resultat livre:
  - historique V1: `www/web/lp/lp.php` chargeait une configuration dediee `www/web/lp/includes/config/lp_operations.php`; depuis le patch 2026-05-11, la publication standard recommandee est la LP reseau `/lp/reseau/{slug}` alimentee par la TdR et l'abonnement reseau actif le plus recent;
  - une nouvelle operation commerciale se contextualise via le bloc `Page reseau / operation` de la fiche BO `Abonnement reseau`, sans ajouter de nouveau cas dans le `switch` historique;
  - la landing lit le compte TdR, les assets/couleurs LP dedies et les contenus reseau en lecture seule, sans session PRO et sans ecriture;
  - la priorite de hero est maintenant: visuel principal LP dedie, puis fallback Cotton;
  - les demos utilisent les contenus reseau partages actifs/exploitables de la TdR quand ils existent; si aucun contenu reseau n'est disponible, les demos Cotton generiques restent le fallback;
  - les actions signup/signin restent de simples liens contextualises vers `/utm/reseau/{network_slug}`, sans formulaire PRO embarque dans `www/lp`;
  - le CTA principal reste le parcours existant `/utm/reseau/{slug}` afin de reutiliser signup/signin, rattachement affilié et activation incluse si les conditions reseau existantes sont reunies;
  - le rendu distingue abonnement reseau actif et simple affiliation afin de ne pas promettre d'acces inclus sans support actif;
  - une route reseau inconnue renvoie une page 404 simple plutot que la landing commerciale par defaut.
- limites V1:
  - aucune logique ecommerce operation dediee n'est creee;
  - aucune promesse d'extinction automatique des acces a date de fin n'est ajoutee cote landing;
  - les demos reseau restent limitees aux contenus partages deja exploitables par les endpoints publics existants.

## Update 2026-05-06 — FO parcours demos catalogue
- ecrans concernes:
  - `/fr/jeux`
  - `/fr/jeux/cotton-blind-test/catalogue/playlist/{slug}`
  - `/fr/jeux/bingo-musical/catalogue/playlist/{slug}`
  - `/fr/jeux/cotton-quiz/catalogue/serie/{slug}`
- resultat livre:
  - les cartes jeux de `/fr/jeux` orientent image et CTA principal vers les catalogues existants;
  - le CTA principal est `Démos du jeu`;
  - un lien secondaire `Découvrir le jeu` conserve l'acces a la presentation du jeu;
  - addendum correctif: la structure prod rechargée depuis serveur sert de base, via le partial commun `fo_portail_jeux_demo_signup.php`;
  - `Démo complète` reste l'onglet prioritaire avec le badge `Recommandé`;
  - Cotton Quiz utilise le meme partial que Blind Test et Bingo Musical, sans CTA `Je commande` actif dans ce bloc;
  - seul le texte de presentation de la demo rapide est ajuste en desktop/mobile;
  - le parcours mobile de la demo rapide lance maintenant directement la demo depuis ce bloc, la modale redondante du partial commun est retiree.
- ajustement UX cible:
  - sur `/fr/jeux`, le lien secondaire `Découvrir le jeu` est rattache visuellement au CTA `Démos du jeu` dans la meme rangee d'action, replace a cote du bouton principal et souligne/colorise au hover selon le jeu;
  - sur les fiches detail Cotton Quiz utilisant ce partial commun, la mention `NEW ! Testez la nouvelle version du Cotton Quiz !` est masquee;
  - le micro-texte mobile de la demo rapide est raccourci et compacte via utilitaires responsive existants.

## Update 2026-04-17 — FO statique 2026: dependance `Bootstrap Icons` rechargee globalement
- ecrans concernes:
  - `/fr/solutions/bars-lieux-de-vie`
  - `/fr/decouvrir`
  - plus largement les nouvelles pages statiques `solutions/*` et `decouvrir/*` 2026
- audit court:
  - les assets et templates FO 2026 etaient bien presents cote prod apres reload, mais certaines icones restaient absentes;
  - les nouveaux templates utilisaient des classes `bi ...`, alors que le layout global `fo.php` ne chargeait plus `bootstrap-icons.css`;
  - la dependance ne subsistait localement que dans un widget specifique, insuffisant pour couvrir les nouvelles pages.
- resultat livre:
  - `www/web/fo/fo.php` recharge maintenant `Bootstrap Icons` dans le head global;
  - les icones des nouvelles pages statiques redeviennent visibles sans duplication de lien CSS dans chaque template.

## Update 2026-04-17 — FO sessions / `place`: ordre des ex aequo stabilise
- ecrans concernes:
  - `/fr/session/...`
  - `/fr/place/{organisateur}`
- resultat livre:
  - les podiums publics ne re-trient plus les lignes ex aequo par libelle ou via un `usort` instable;
  - ils preservent maintenant l'ordre source fourni par le socle partage;
  - pour les sessions runtime modernes, cet ordre source est lui-meme recale sur `games`.
- effet:
  - le podium public et le classement complet d'une meme session ne doivent plus se contredire sur l'ordre de deux lignes a rang egal;
  - les classements agreges `place` restent coherents entre podium et tableau.

## Update 2026-04-16 — FO fiche `place`: titres de jeux mis en badge dans `Classements`
- ecran concerne:
  - `/fr/place/{organisateur}`
- audit court:
  - dans l'onglet `Classements`, chaque bloc jeu (`Blind Test`, `Bingo Musical`, `Cotton Quiz`) etait encore affiche comme un simple titre texte;
  - le besoin retenu est d'aligner cette hierarchie visuelle sur les badges de jeu deja utilises dans `pro` (`Ma communauté`) et `play` (`Classements`).
- resultat livre:
  - les titres de jeux de l'onglet `Classements` passent maintenant dans un badge colore par jeu;
  - les couleurs reutilisent les classes existantes `bg-color-cotton-blind-test`, `bg-color-bingo-musical` et `bg-color-cotton-quiz`;
  - la periode de saison reste affichee a cote, en texte secondaire.

## Update 2026-04-16 — FO fiche `place`: retour du CTA d'accès direct au jeu sur entrée QR code
- ecran concerne:
  - `/place/{code_client}`
  - `/fr/place/{organisateur}`
- audit court:
  - historiquement, une entrée via le QR code `place` exposait depuis chaque carte d'agenda un CTA direct vers l'interface joueur de la session;
  - après refonte de la fiche `place` et de son hydratation AJAX, ce CTA n'était plus rendu car le nouveau renderer agenda n'héritait plus du contexte `code_client`.
- resultat livre:
  - l'URL AJAX de la fiche `place` propage maintenant explicitement `code_client` quand l'entrée vient d'un QR code lieu;
  - le renderer agenda réactive alors le bouton `J'accède au jeu` sur les cartes de sessions à venir, en réutilisant le même helper métier `app_session_games_play_get_link(...)` que le bloc historique des sessions;
  - dans ce contexte QR uniquement, le CTA public secondaire `En savoir plus` n'est plus affiché sur ces cartes;
  - le CTA reste strictement limité à l'entrée QR `place/{code_client}` et n'est pas affiché sur la fiche publique standard `/fr/place/{seo_slug}`.

## Update 2026-04-15 — FO fiche `place`: spinner aussi sur l'onglet `Agenda`
- ecran concerne:
  - `/fr/place/{organisateur}`
- audit court:
  - la fiche `place` affichait deja un spinner sur `Classements` et `Sessions passées`;
  - l'onglet `Agenda` restait sur un simple texte de chargement, alors qu'il est lui aussi hydrate en AJAX.
- resultat livre:
  - `Agenda` reutilise maintenant le meme loader spinner inline que les deux autres onglets dynamiques;
  - le spinner est visible a la fois dans le placeholder initial et lors du chargement AJAX de l'onglet.

## Update 2026-04-15 — FO fiche `place`: entrée QR code recentrée sur l'onglet `Agenda`
- ecran concerne:
  - `/place/{code_client}`
  - `/fr/place/{organisateur}`
- audit court:
  - la fiche `place` active maintenant `Classements` par défaut depuis la refonte récente des onglets;
  - en conséquence, un utilisateur qui scanne le QR code `place/{code_client}` n'atterrissait plus sur l'information prioritaire attendue, à savoir l'agenda des prochaines sessions.
- resultat livre:
  - une entrée `QR code` via `code_client` force désormais l'onglet actif initial sur `Agenda`;
  - la fiche publique SEO standard `/fr/place/{seo_slug}` conserve en revanche son comportement par défaut actuel sur `Classements`;
  - aucun changement d'URL n'est requis côté QR: la vue FO détecte déjà `code_client` et adapte seulement l'onglet actif initial.
  - addendum perf:
    - cette même entrée QR neutralise aussi le preload image hero global FO, puisque la galerie visuelle est masquée sur cette vue et que le preload produisait un warning navigateur inutile sur `branding-client-default.jpg`.
  - addendum JS:
    - sur entrée QR, les boutons d'onglets sont absents du DOM; le démarrage JS charge donc désormais `Agenda` à partir de l'onglet actif calculé côté serveur, au lieu de dépendre de la présence du bouton `tab-1`.

## Update 2026-04-14 — FO fiche `place`: classements agrégés limités au `Top 10`
- ecran concerne:
  - `/fr/place/{organisateur}`
- audit court:
  - l'onglet public `Classements` rendait immédiatement tous les rangs disponibles pour chaque jeu;
  - sur des établissements très chargés, ce volume gonflait inutilement le HTML renvoyé et la hauteur du DOM, alors que la lecture utile publique porte d'abord sur les premiers rangs.
- resultat livre:
  - chaque classement `www/place` est maintenant limité au `Top 10`;
  - le sous-titre public est fixé à `Top 10`;
  - aucun toggle `classement complet` n'est exposé côté FO;
  - quand plusieurs jeux sont présents, l'ordre de lecture publique devient `Blind Test`, puis `Bingo Musical`, puis `Cotton Quiz`;
  - le changement de saison conserve la même lecture AJAX, sans impacter les onglets `Agenda` et `Sessions passées`;
  - si aucun contenu exploitable n'existe dans `Classements`, `Agenda` et `Sessions passées`, toute la section d'onglets est masquée pour éviter un bloc vide.

## Update 2026-04-14 — FO liste `place`: filtre département restreint + tri par activité
- ecran concerne:
  - `/fr/place`
  - `/fr/place/departement/{slug}`
- audit court:
  - le filtre `Département` proposait tout le référentiel, y compris des zones sans organisateur public;
  - la liste organisateurs restait triée par `id`, sans prioriser les lieux les plus actifs.
- resultat livre:
  - le sélecteur `Département` ne propose plus que les départements réellement présents dans la liste publique des organisateurs;
  - l'option `Tous` repointe correctement vers `/fr/place`;
  - les cartes organisateurs sont maintenant triées par activité agrégée côté SQL:
    - d'abord `nb de sessions utiles` décroissant;
    - puis `date de dernière session` décroissante;
    - puis `nom` croissant;
  - le tri ne relance aucun calcul lourd par carte: une seule agrégation SQL globale est jointe à la liste publique.

## Update 2026-04-14 — BO réseau: désaffiliation directe d'un affilié depuis `reseau_contrats`
- ecran concerne:
  - `?a=www&t=ecommerce&m=reseau_contrats&p=list&id_client_siege={id}`
- audit court:
  - le BO de pilotage réseau savait déjà activer, désactiver et reclasser les affiliés, mais ne proposait aucun CTA pour sortir proprement un compte du réseau quand il n'est plus affilié à la TdR;
  - en pratique, un compte laissé avec `clients.id_client_reseau > 0` restait aussi exclu du périmètre `Remises 2026`.
- resultat livre:
  - le tableau `Affiliés du siège` expose maintenant une action BO `Supprimer l'affiliation`;
  - cette action n'existe pas côté PRO;
  - le write path réutilise `client_affilier(0, ...)` pour casser l'affiliation en remettant `id_client_reseau` à `0`;
  - la sortie du réseau relance aussi la reclassification métier existante des délégations pour le siège quitté, afin de rester cohérente avec les autres changements d'affiliation pilotés depuis le BO.

## Update 2026-04-14 — FO fiche `place`: chargement allégé des classements publics
- ecran concerne:
  - `/fr/place/{organisateur}`
- audit court:
  - la fiche publique réutilisait `app_client_joueurs_dashboard_get_context(...)`, donc sur un cache froid elle pouvait déclencher le calcul historique complet de `Mes joueurs`;
  - pour `www/place`, ce coût était disproportionné: la page n'a besoin que des leaderboards de saison courante et peut tolérer l'absence temporaire de synthèse historique si aucun cache n'est déjà disponible.
- resultat livre:
  - la fiche `place` utilise maintenant `app_client_joueurs_dashboard_get_context_fo_place(...)`;
  - ce chemin FO ne recalcule plus l'historique complet au premier hit: il charge directement le contexte filtré saison courante pour les classements;
  - les stats historiques hautes ne sont réinjectées que si le cache journalier de synthèse existe déjà dans la session courante;
  - en l'absence de cache, la page privilégie donc la vitesse d'affichage des classements plutôt que le recalcul complet de la synthèse organisateur;
  - addendum: la fiche `place` rend maintenant son shell HTML immédiatement, puis hydrate en AJAX:
    - la synthèse haute;
    - le bloc `Classements`;
  - le bloc `Classements` expose aussi un sélecteur de saison directement dans son titre, sans section séparée; ce sélecteur recharge en AJAX uniquement les leaderboards demandés, et trie les saisons exploitables récentes en premier.

## Update 2026-04-14 — FO fiche `place`: onglet `Classements` aligné sur le moteur multi-jeux
- ecran concerne:
  - `/fr/place/{organisateur}`
- audit court:
  - la fiche `place` chargeait déjà le contexte global `Mes joueurs`, mais l'onglet public restait branché sur un ancien rendu `Classement Quiz` local, figé sur plusieurs saisons legacy;
  - les règles métier récentes côté `pro/play` portent désormais des classements par jeu sur la seule saison courante exploitable, avec masquage naturel des jeux sans sessions classables.
- resultat livre:
  - l'onglet devient `Classements` et s'aligne sur la saison courante portée par `app_client_joueurs_dashboard_get_context(...)`;
  - la fiche affiche maintenant un bloc distinct par jeu réellement exploitable:
    - `Cotton Quiz`
    - `Blind Test`
    - `Bingo Musical`;
  - chaque bloc réutilise le style du tableau quiz historique (`rang / entité / points / participations`);
  - le libellé de période est simplifié au format `Jeu · Avril-Juin 2026`;
  - `Cotton Quiz` continue d'afficher des équipes, tandis que `Blind Test` et `Bingo Musical` affichent des joueurs;
  - la colonne droite ne liste plus tout l'historique: elle montre seulement un nombre ajusté des dernières sessions classées, avec bloc cliquable vers la fiche détail de session;
  - ce volume est maintenant estimé à partir de la hauteur théorique du tableau de classement plutôt qu'avec un plafond fixe, afin d'exploiter davantage l'espace quand le classement le permet;
  - si aucun jeu n'a de session classable sur la saison courante, l'onglet affiche un message vide explicite.

## Update 2026-04-14 — BO `Remises 2026`: sélection en masse figée sur une remise manuelle
- ecran concerne:
  - `?a=www&t=ecommerce&m=remises_2026&p=view&id={id}`
- audit court:
  - la fiche détail d'une remise manuelle permettait déjà d'ajouter ou retirer des comptes unitairement;
  - il manquait un moyen de figer en une fois un lot de comptes actuels répondant à des critères de `typologie` et/ou `pipeline`, sans transformer la remise en ciblage automatique.
- resultat livre:
  - la fiche détail expose maintenant un bloc `Ajouter en masse (sélection figée)` réservé au mode manuel;
  - ce bloc reprend les mêmes critères métier que le ciblage automatique:
    - `Typologie`
    - `Pipeline`;
  - le snapshot ajoute uniquement les comptes actuellement trouvés dans `ecommerce_remises_to_clients`;
  - les futurs comptes qui matcheront plus tard ces mêmes critères ne seront pas ajoutés automatiquement;
  - les comptes déjà liés sont exclus du lot;
  - dans les listes de comptes concernés de la fiche détail, l'email du contact administrateur principal s'affiche maintenant en petit sous le nom du compte;
  - cette lecture passe maintenant sur une colonne `Email` dédiée;
  - elle remonte tous les emails contacts associés à chaque compte, pas seulement l'administrateur principal;
  - si un compte a plusieurs emails, la fiche détail crée plusieurs lignes `compte + email`, tout en gardant le CTA `Retirer` uniquement sur la première ligne de ce compte;
  - le CTA `Retirer` utilise désormais un style plein lisible, autant sur la fiche détail que depuis la fiche client; le CTA d'ajout manuel depuis la fiche client est renommé `Appliquer` avec un style `btn-info`;
  - ces ajouts manuels peuvent maintenant être préparés avant activation de la remise, y compris si la fenêtre de commande n'est pas encore ouverte;
  - la fiche détail expose aussi un CTA `Vider tout` dans l'entête du tableau pour purger d'un coup les comptes manuellement liés à la remise;
  - le retrait fin reste possible ensuite, compte par compte, depuis la liste des cibles manuelles.

## Update 2026-04-13 — FO agenda public: filtres alignés sur l’agenda joueur
- ecran concerne:
  - `/fr/agenda`
- audit court:
  - l'agenda public `www` restait sur un filtre unique `Département`, avec un affichage par défaut hérité des routes SEO historiques;
  - `play` exposait déjà une lecture plus cohérente pour les joueurs: 3 filtres alignés (`Département / pays`, `Organisateur`, `Jeu`), tous par défaut sur `Tous`, avec une liste géo limitée aux zones réellement représentées.
- resultat livre:
  - l'agenda FO reprend maintenant la même logique de filtres que `play`, tout en conservant la compatibilité des routes SEO historiques `jeu / departement / ville`;
  - le filtre géographique mélange désormais départements français et pays étrangers réellement présents dans les sessions affichables;
  - le filtre `Organisateur` est borné aux lieux réellement représentés dans l'agenda courant;
  - le filtre `Jeu` normalise la lecture publique sur `Cotton Quiz`, `Blind Test`, `Bingo Musical`, avec regroupement des variantes techniques Quiz/Bingo;
  - en environnement `dev`, l'agenda public n'impose plus `c.online=1`, afin de garder une recette cohérente sur `Tous`.

## Update 2026-04-13 — FO session view: détail des séries programmées sur `Cotton Quiz`
- ecran concerne:
  - `/fr/agenda/{organisateur}/{session}`
- audit court:
  - la fiche détail `www` affichait déjà date, lieu et visuel, mais pas le détail des séries pourtant déjà exposé côté `play`;
  - les métadonnées nécessaires (`quiz_series_label`, `quiz_series_names`) étaient déjà disponibles via le socle `global`.
- resultat livre:
  - sur une fiche détail `Cotton Quiz`, le bloc gauche affiche maintenant `Séries programmées` entre `Date` et `Lieu`;
  - la lecture réutilise d'abord les données portées par la session, puis tombe en fallback sur le détail jeu;
  - le rendu reste volontairement sobre et cohérent avec les autres lignes d'information de la page;
  - les textes d'accordéon `Concept` / `Comment participer` sont aussi harmonisés:
    - wording `Quiz` simplifié;
    - `Blind Test` bascule sur un vrai CTA `Je participe`;
    - `Bingo Musical` réactive un bloc `Comment participer`;
  - le CTA principal `Je participe` de la fiche détail pointe maintenant, lui aussi, vers l'entrée EP liée à la session courante;
  - sur une session terminée `Cotton Quiz`, `Blind Test` ou `Bingo Musical`, la colonne centrale remplace désormais le visuel par un bloc `Podium` puis `Classement complet`, alimenté par le même moteur global que la fiche archive `pro`;
  - le bloc gauche d'informations générales de session est lui aussi masqué dans ce contexte, pour ne garder que les résultats;
  - les accroches marketing et blocs `Concept / Comment participer` sont masqués sur ces sessions terminées;
  - le titre de la liste basse affiche maintenant le nombre réel de participants remonté par le moteur de résultats;
  - sur `Bingo Musical`, la liste basse reste une simple liste de joueurs, sans rang ni points, comme côté `pro`;
  - le podium affiche une photo gagnant si elle existe, sinon un fallback visuel propre par place.

## Update 2026-04-13 — FO fiche `place`: synthèse stats alignée sur `Mes joueurs`
- ecran concerne:
  - `/fr/place/{organisateur}`
- audit court:
  - la fiche établissement `www` reposait encore sur des stats legacy `app_statistiques_client_*` avec seuils d'affichage fixes (`>10`, `>50`) et une lecture limitée `Bingo Musical`;
  - le BO/EC utilisait déjà le moteur global `Mes joueurs`, plus fiable sur `membre depuis`, sessions utiles, joueurs `Blind Test/Bingo Musical` et équipes `Cotton Quiz`.
- resultat livre:
  - la fiche `place` réutilise maintenant `app_client_joueurs_dashboard_get_context(...)` comme source principale;
  - `Membre depuis` et `sessions de jeux Cotton` suivent désormais la même source que `pro/ec`;
  - la synthèse publique regroupe désormais joueurs `Blind Test/Bingo Musical` et équipes `Cotton Quiz` dans une seule ligne `participants`;
  - convention marketing retenue côté `www/place`: `1 équipe Cotton Quiz = 3 participants`;
  - la ligne `participants` disparait si le total est nul;
  - les anciens seuils arbitraires de visibilité ne pilotent plus l'affichage;
  - dans l'onglet `Sessions passées`, les cartes réexposent maintenant un CTA vers la fiche détail de la session archivée;
  - cette liste archive réutilise désormais le même filtre métier que `pro` pour ne garder que les sessions historiquement utiles;
  - dans ce contexte, le CTA carte est renommé `Voir les résultats`.

## Update 2026-04-08 — BO factures PDF: la remise sort du libellé produit et suit les snapshots canoniques
- audit court:
  - la facture PDF affichait encore la remise dans la description de ligne, alors que les snapshots de commande portaient déjà distinctement le prix de référence, le HT remisé et le TTC facturé;
  - le bloc `TVA` pouvait rester arithmétiquement incohérent avec le `TOTAL TTC` quand le net HT provenait d'un arrondi intermédiaire.
- resultat livre:
  - le descriptif produit n'embarque plus la remise en ligne;
  - le `PU HT` et le `PRIX TOTAL HT` repassent sur le montant de référence avant remise quand une remise snapshotée existe;
  - les totaux PDF affichent maintenant explicitement `TOTAL HT`, `REMISE ... HT`, `TOTAL REMISÉ HT`, puis `TVA (...)` et `TOTAL TTC`;
  - la TVA visible est relue comme difference entre `TTC` canonique facture et `HT` net snapshoté, ce qui garantit un PDF coherent avec le montant final réellement payé;
  - le logo PDF BO lit maintenant aussi un asset partage sous `global`, ce qui evite de dependre d'un fichier `pro` non lisible.

## Update 2026-04-08 — BO `Remises 2026`: le lien copiable est maintenant un vrai lien prospect PRO
- audit court:
  - la fiche detail affichait bien une URL de portage de remise, mais l'ancre gardait `href="#"`, donc un clic restait dans le BO;
  - le besoin metier reste un lien prospect partageable qui porte la remise jusqu'au signup/signin.
- resultat livre:
  - il reutilise la route historique `https://pro.../utm/cotton/<token_public>`;
  - pour `Remises 2026`, le token public emis est maintenant l'`id_securite` opaque de la remise;
  - la fiche detail met maintenant le CTA `Copier le lien` en avant et laisse l'URL visible dessous en petit, sans en faire un lien cliquable;
  - le lien reste reserve aux remises manuelles actives;
  - si la fenetre de commande est expirée, le lien n'est plus expose;
  - il devient directement exploitable dans un CTA emailing ou en partage commercial.

## Update 2026-04-08 — BO clients: `Remises` bascule sur `Remises 2026`
- audit court:
  - la navigation `Commercial` exposait encore deux entrées legacy de remises, alors que le point d'entree courant est `Remises 2026`;
  - la fiche client BO gardait une section `Remises` branchée sur `ecommerce_remises_clients`, en doublon avec le nouveau ciblage `Remises 2026`.
- resultat livre:
  - le menu `Commercial` ne montre plus `Remises > catalogue Cotton` ni `Remises > accordées aux clients`;
  - la fiche client réutilise sa section `Remises` pour lister les `Remises 2026` actuellement applicables au compte;
  - cette section permet aussi d'ajouter une regle `Remises 2026` manuelle a un compte eligible, puis de retirer seulement ce rattachement manuel;
  - les regles automatiques restent en lecture seule depuis la fiche client.

## Update 2026-04-08 — BO `Remises 2026`: duree d'application metier
- audit court:
  - le BO `Remises 2026` etait deja le bon point d'entree pour la regle commerciale;
  - il lui manquait seulement une notion de duree d'application explicite, sans ouvrir des choix techniques Stripe.
- resultat livre:
  - le module ajoute `duree_remise_mois` avec defaut `12`;
  - l'editeur autorise maintenant `1..N mois` et `Sans limite`;
  - la liste et la vue detail affichent une lecture metier compacte de la remise;
  - aucune exposition BO d'un moteur `coupon / schedule`;
  - la regle annuelle particuliere est rappelee dans l'aide:
    - une duree `< 12 mois` sur une offre annuelle signifie `premiere facture annuelle uniquement`.

## Update 2026-04-07 — BO `Remises 2026`: nouveau chemin dedie sous `Commercial`
- audit court:
  - les modules legacy `remises` et `remises_offres` restaient fragiles pour la V1, car ils melangeaient trop de champs historiques et plusieurs write paths incompatibles avec le besoin courant;
  - le besoin reel porte uniquement sur le checkout Stripe de l'abonnement illimite `ABN 12`.
- resultat livre:
  - un nouveau module `ecommerce/remises_2026` est ajoute dans la navigation `Commercial`;
  - il porte un form dedie V1, sans dependance inutile aux formulaires legacy;
  - ce form bascule aussi automatiquement en `modifier` si une fiche existante est ouverte avec `id>0` sans `mode` explicite, pour eviter les duplications involontaires a l'edition;
  - il cree / met a jour la regle dans `ecommerce_remises` et la liaison front + pourcentage dans `ecommerce_remises_to_offres` pour l'offre `ABN 12`;
  - la liste permet aussi de supprimer une remise V1, avec purge des liaisons offre et comptes avant effacement de la regle;
  - la liste detaille aussi desormais le ciblage avec les noms reels de `pipeline` / `typologie`, et la vue affiche un recap numerique des comptes concernes;
  - la fiche rappelle aussi que la remise V1 Stripe s'applique par defaut sur `12 mois`;
  - il bascule automatiquement entre deux modes:
    - ciblage automatique par `typologie` et/ou `pipeline`
    - ciblage manuel par comptes explicites si ces deux champs sont vides;
  - la fiche fermee liste ensuite les comptes propres concernes, en excluant explicitement les TdR et les comptes rattaches a un reseau;
  - les anciens modules `remises` / `remises_offres` restent volontairement en logique legacy et ne sont plus le chemin cible de parametrage V1.

## Update 2026-04-03 — BO `facturation_pivot`: `Clients actifs` suit le mois de référence en `civil/fiscal`
- audit court:
  - le KPI haut `Clients actifs` était calculé sur le dernier mois de la plage affichée;
  - en `année civile` ou `année fiscale`, cela faisait lire respectivement `decembre` ou `aout`, meme quand l'utilisateur pilotait la vue depuis un mois de référence antérieur.
- resultat livre:
  - en `civil` et `fiscal`, `Clients actifs` est désormais relu sur le `mois de reference` sélectionné;
  - en `mois` et `3 derniers mois`, la logique reste inchangée;
  - ce réalignement porte sur le KPI haut, sans changer les autres tableaux de période.

## Update 2026-04-03 — BO `facturation_pivot`: conversions SaaS alignées sur les deux sources de démos
- audit court:
  - le tableau `Visiteurs / prospects / clients` exposait déjà séparément `Demos visiteurs` et `Démos nvx inscrits`;
  - la modale de conversion et certains ratios “réalisés” continuaient pourtant de raisonner sur la seule première source.
- resultat livre:
  - les calculs réels `visiteurs -> demos`, `demos -> inscrits` et `demos -> clients` utilisent maintenant l'agrégat `Demos visiteurs + Démos nvx inscrits`;
  - la présentation détaillée conserve les deux colonnes distinctes pour ne pas perdre l'origine des volumes affichés;
  - le budget n'est pas redéfini ici: seule la lecture des réalisations SaaS est réalignée.

## Update 2026-03-24 — BO clients: le lien EC temporaire se copie au lieu de s'ouvrir
- audit court:
  - la fiche client BO affichait bien l'URL du lien EC temporaire apres generation;
  - cette URL etait toutefois cliquable, ce qui favorisait une ouverture directe plutot qu'un partage interne.
- resultat livre:
  - l'URL generee est maintenant exposee comme une action de copie;
  - un bouton `Copier le lien` est ajoute avec feedback `Lien copié`;
  - le lien temporaire reste visible pour controle interne, sans navigation directe par defaut.

## Update 2026-03-23 — BO clients: génération d'un lien EC temporaire par contact
- audit court:
  - la fiche client BO listait deja les contacts et exposait un `gate.php` interne pour ouvrir l'EC en contexte admin;
  - aucun mecanisme BO ne permettait toutefois de generer un lien simple a transmettre a un contact pour ouvrir directement l'EC sans passer par le login.
- resultat livre:
  - la fiche client BO propose maintenant, pour chaque contact, une action interne `Generer un lien EC temporaire`;
  - l'action renvoie sur la meme fiche avec l'URL complete prete a copier;
  - ce lien repose sur le point d'entree PRO temporaire et n'est pas expose dans le front EC public.

## Update 2026-03-23 — BO reseau: alignement DB develop/prod sans `ecommerce_reseau_delegated_replacements`
- audit court:
  - la table dédiée `ecommerce_reseau_delegated_replacements` venait d'un état intermédiaire où les remplacements délégués différés devaient être rejoués par le cron BO;
  - l'état V1 final livré neutralise désormais ces remplacements (`replacement_disabled_v1`) et ne retient plus cette persistance comme schéma de référence.
- résultat livré:
  - le script phpMyAdmin `bdd_ecommerce_reseau_contrats.sql` ne crée plus cette table historique;
  - le même script la supprime explicitement si elle existe encore;
  - un SQL one-shot d'alignement `develop/prod` est ajouté à côté du module BO pour converger les bases déjà initialisées avec l'ancien schéma.

## Update 2026-03-20 — BO `facturation_pivot`: sessions SaaS allégées sans changer les KPI
- audit court:
  - le reporting SaaS relançait deux agrégations proches sur `championnats_sessions`:
    - une pour les sessions finies affichées dans le reporting
    - une seconde pour les seules sessions numériques utilisées dans les ratios;
  - la page BO devenait sensiblement plus lente au chargement sur les plages longues.
- résultat livré:
  - la première agrégation remonte désormais aussi `sessions_numeric`;
  - le second scan dédié est retiré;
  - les KPI restent inchangés:
    - volumes de sessions
    - ventilation par jeu
    - ratios fondés sur les seules sessions numériques.

## Update 2026-03-13 — BO réseau: remplacements délégués différés persistés en base dédiée
- audit court:
  - le cron BO des remplacements différés relisait encore les marqueurs `[reseau_replace:*]` et `[reseau_replace_timing:*]` dans `ecommerce_offres_to_clients.commentaire`;
  - le schéma importé via phpMyAdmin ne portait pas encore de table dédiée pour cette planification.
- résultat livré:
  - la base BO expose maintenant `ecommerce_reseau_delegated_replacements` pour les remplacements délégués planifiés;
  - le cron consomme d'abord cette table dédiée, puis garde un fallback legacy sur les anciens marqueurs pour les lignes déjà créées avant migration;
  - le comportement fonctionnel reste inchangé: seul le support de persistance du différé est remplacé.

## Update 2026-03-13 — BO réseau: navigation croisée TdR / offre support
- audit court:
  - la vue BO d'un `Abonnement réseau` n'exposait pas le client TdR dans son bloc haut;
  - la page `reseau_contrats` ne proposait pas non plus de lien direct depuis `Abonnement réseau actif` vers la fiche de l'offre support.
- résultat livré:
  - la fiche `offres_clients` d'un `Abonnement réseau` affiche maintenant `CLIENT` avec lien vers la fiche client de la TdR;
  - le libellé `Abonnement réseau actif` devient cliquable dans `Affiliés du réseau` quand l'offre support est résolue;
  - aucune logique métier réseau n'est modifiée, uniquement la navigation BO.

## Update 2026-03-13 — BO `reseau_contrats`: `Offre incluse cible` visible dans `Affiliés du réseau`
- audit court:
  - la synthèse haute affichait déjà l'état de l'abonnement réseau et les quotas;
  - l'offre de délégation incluse ciblée n'était toutefois pas visible dans ce bloc BO.
- résultat livré:
  - quand l'abonnement réseau est actif, le bloc `Affiliés du réseau` affiche aussi `Offre incluse cible`;
  - le libellé vient de l'offre canonique `id_offre_delegation_cible` déjà portée par la couverture réseau;
  - aucun write path ni recalcul de couverture n'est modifié.

## Update 2026-03-12 — BO `offres_clients`: clôture explicite de l'`Abonnement réseau` sans réactivation par fallback
- audit court:
  - le write path BO `offres_clients` fermait bien l'offre support reseau a la fin du flux;
  - mais une transition runtime intermediaire pouvait encore relancer un recalcul reseau avant la cloture effective de la ligne support;
  - apres archivage runtime, le resolver support reseau pouvait encore repartir en fallback sur une autre offre support `En attente` ou `Active` du meme siege.
  - la fiche client TdR relisait aussi la synthese reseau via un helper qui pouvait encore declencher une sync legacy pendant un simple chargement de page.
- resultat livre:
  - la cloture BO explicite d'une offre `Abonnement reseau` ne repasse plus par cette transition intermediaire;
  - un garde-fou final reverrouille aussi la ligne support en `Terminee` apres la rotation runtime;
  - un runtime reseau archive expose maintenant l'etat canonique `cloture` et interdit tout fallback automatique vers une autre offre support;
  - une reactivation redevient donc exclusivement un write path explicite BO/Stripe, pas un effet secondaire de lecture;
  - le refresh reseau canonique ne requalifie plus non plus tout seul l'offre support vers `En attente` ou `Active`; hors cloture runtime, il conserve l'etat deja ecrit par un write path explicite;
  - la fiche client TdR utilise maintenant une lecture BO pure de la synthese reseau, sans relance de sync legacy a l'affichage;
  - le flux conserve la fermeture explicite de l'offre support, la cloture des delegations actives et l'archivage runtime du contrat reseau;
  - aucune recreation implicite d'offre support n'est reintroduite.

## Update 2026-03-11 — Réseau: délégations incluses rattachées à l'abonnement source
- audit court:
  - aucune offre déléguée incluse ne portait l'id de l'`Abonnement réseau` source;
  - la restitution d'un abonnement réseau terminé dépendait donc encore d'indices secondaires.
- résultat livré:
  - les offres déléguées incluses portent désormais le champ facultatif `reseau_id_offre_client_support_source`;
  - ce champ reste vide (`0`) pour les offres déléguées hors abonnement réseau;
  - la lecture des `Offres incluses` peut désormais se brancher en priorité sur ce rattachement explicite.

## Update 2026-03-11 — BO `offres_clients`: `Offres incluses` relues depuis l’offre support affichée
- audit court:
  - l’aside `Offres incluses` et la synthèse de la fiche `Abonnement réseau` relisaient le contrat/support réseau courant du client;
  - la jointure persistait encore sur `id_offre_client_deleguee` courant de la table d’activation réseau, qui n’est pas un historique fiable par offre support;
  - une offre support terminée pouvait donc afficher les délégations du support actif, ou aucune ligne pertinente.
- résultat livré:
  - la fiche `Abonnement réseau` relit désormais l’offre support active via la couverture canonique runtime;
  - une offre support historique relit les offres déléguées incluses à partir des offres affiliées du siège, filtrées sur la période de l’offre support affichée;
  - les offres support `Terminées` continuent d’exposer leurs offres déléguées reliées, avec leurs statuts terminés si c’est le cas;
  - la synthèse BO n’emploie plus un compteur biaisé par un autre abonnement réseau actif.

## Update 2026-03-11 — BO `offres_clients`: garde-fou sur les abonnements réseau terminés
- audit court:
  - une édition BO d'une offre support réseau terminée pouvait encore repasser par la synchro runtime canonique;
  - ce flux risquait de la rerattacher comme support courant.
- résultat livré:
  - une offre `Abonnement réseau` déjà `Terminée` peut être modifiée sans redevenir support canonique;
  - la synchro BO réseau est sautée tant que l'offre reste `Terminée`;
  - un garde-fou force la persistance de l'état `Terminée` sur ce cas;
  - ce même garde-fou conserve explicitement `date_debut` et `date_facturation_debut`.

## Update 2026-03-12 — BO `reseau_contrats`: remise synthèse projetée sur la prochaine commande TdR
- audit court:
  - la synthèse `Remise réseau courante` relisait jusqu’ici le palier appliqué aux seules délégations `hors abonnement réseau` déjà actives;
  - le besoin d’exposition côté PRO porte en fait sur la remise qui sera appliquée à la prochaine commande passée par la TdR.
- résultat livré:
  - la synthèse haute du bloc `Affiliés du réseau` affiche désormais la remise calculée sur `volume actif courant + 1`;
  - le libellé visuel rappelle explicitement qu’il s’agit de la `prochaine commande TdR`;
  - la colonne `Tarif` des lignes déjà actives ne change pas de sémantique et continue d’afficher la remise réellement appliquée à ces lignes.

## Update 2026-03-11 — BO `reseau_contrats`: stabilisation de la gestion des affiliés
- audit court:
  - la vue mélangeait encore des signaux `cadre` et `hors abonnement` dans sa lecture secondaire;
  - un affilié sans offre pouvait exposer simultanément l'activation via abonnement réseau et la commande hors abonnement.
- résultat livré:
  - la lecture `hors abonnement réseau` ne retient plus une délégation déjà classée `cadre` quand `mode_facturation` est persisté;
  - le bloc `Affiliés du réseau` expose en tête la synthèse métier utile:
    - abonnement actif
    - quota limite / places disponibles
    - nb affiliés
    - nb offres actives incluses à l'abonnement réseau
    - nb offres actives hors abonnement réseau
    - remise réseau courante
    - nb affiliés sans offre active dont `CSO`;
  - l'action devient exclusive:
    - quota disponible => `Activer`
    - sinon => attribution d'une offre déléguée hors abonnement réseau;
  - les blocs séparés `Synthèse hors cadre`, `Commander une offre hors cadre` et `Offres affiliées hors cadre` sont retirés.
- garde-fous:
  - aucun cumul `cadre + hors abonnement` pour un même affilié;
  - `Abonnement réseau` reste le seul support canonique côté TdR;
  - les libellés métier sont réalignés sur `offre déléguée incluse à l'abonnement réseau` / `offre déléguée hors abonnement réseau`.

## Update 2026-03-11 — BO `reseau_contrats`: détail des offres terminées + compactage UI
- résultat livré:
  - la mention d'aide `Activation` est retirée du haut du bloc;
  - `dont offres terminées (CSO)` pointe maintenant vers le nombre réel d'offres déléguées réseau terminées;
  - une table récapitulative des offres déléguées hors abonnement réseau terminées est ajoutée en bas de page;
  - le formulaire d'attribution hors abonnement empile désormais ses trois champs pour limiter la largeur de la colonne `Actions`.

## Update 2026-03-11 — BO `reseau_contrats`: colonne `Tarif` relue avec exception cadre
- résultat livré:
  - la colonne `Offre` réaffiche la jauge de l'offre active quand elle existe;
  - la colonne `Offre` affiche aussi la période en cours de l'offre active quand elle est calculable;
  - une colonne `Tarif` est ajoutée dans la liste `Affiliés du réseau`;
  - lecture tarifaire appliquée:
    - `offre déléguée incluse à l'abonnement réseau` => pas de tarif affiché;
    - `offre déléguée hors abonnement réseau` => tarif HT selon la périodicité de la ligne;
    - `offre propre` => tarif HT de l'offre active;
    - `aucune offre` => `—`;
  - la synthèse haute affiche aussi le tarif négocié de l'abonnement réseau quand il est actif.

## Update 2026-03-11 — BO/Stripe alignés sur l'activation `Abonnement réseau`
- résultat visé:
  - l'activation admin BO et le paiement Stripe confirmé convergent désormais vers le même état final pour l'offre canonique `Abonnement réseau`;
  - `Etat offre=active` et `Etat contractuel=actif` sont synchronisés avant usage opérationnel du réseau.
- règle métier explicitée:
  - l'offre canonique reste la source de vérité;
  - l'état contractuel exposé par le runtime est dérivé de l'offre support, sans dépendre d'une colonne persistée `ecommerce_reseau_contrats.contract_state`.
- garde-fou:
  - aucune ancienne action contrat n'est réintroduite comme source principale;
  - le retour navigateur Stripe ne redevient pas un write path métier.

## Update 2026-03-11 — BO `offres_clients`: activation admin de `Abonnement réseau`
- audit court:
  - le form BO `Abonnement réseau` exposait déjà `id_etat`;
  - le rollback venait du refresh réseau générique déclenché trop tôt après `module_modifier(...)`.
- résultat livré:
  - le BO peut désormais forcer administrativement l'activation de l'offre canonique `Abonnement réseau`;
  - sur un passage `pending_payment -> active`, le script BO bypass le refresh prématuré, laisse l'offre persister à `3`, synchronise ensuite le contrat à `actif`, puis relance le refresh réseau;
  - le flow spécial de fin d'offre (`id_etat=4`) reste inchangé.
- garde-fous:
  - l'override admin porte bien sur l'offre canonique, pas sur un retour des anciennes actions contrat;
  - Stripe reste le flux standard côté PRO, mais pas une dépendance obligatoire pour ce changement d'état BO;
  - les actions contrat neutralisées `save_contrat`, `activate_contract`, `close_contract` ne sont pas réintroduites.

## Update 2026-03-11 — BO réseau durable: bouton TdR visible et pilotage affiliés
- audit court:
  - la fiche client TdR rendait déjà l'accès `reseau_contrats` au bon endroit, mais comme lien discret;
  - la vue `reseau_contrats` restait centrée sur le hors cadre et se décrivait encore comme écran transitoire.
- résultat livré:
  - le CTA méta devient un vrai bouton BO visible `Voir / gérer les affiliés`, rendu uniquement pour une TdR et placé juste sous `Tête de réseau`;
  - `reseau_contrats` devient explicitement la vue BO transverse durable de pilotage réseau;
  - la page liste désormais les affiliés du réseau avec lecture de couverture, activation via `Abonnement réseau` si quota disponible, attribution d'offre déléguée hors cadre, et désactivation des couvertures déléguées;
  - les actions contrat neutralisées `save_contrat`, `activate_contract`, `close_contract` ne sont pas réintroduites.
- garde-fous:
  - `Abonnement réseau` reste l'unique offre métier TdR canonique;
  - le dropdown historique `Offre propre` / `Offre réseau` n'est pas modifié;
  - le hors cadre reste branché sur les write paths existants d'offre déléguée.

## Update 2026-03-11 — Vue détail réseau et dates client TdR
- audit court:
  - la vue BO `offres_clients` rendait encore le bloc historique `Informations` par défaut, même pour `Abonnement réseau`;
  - la fiche client TdR lisait déjà correctement `date_debut` et `date_facturation_debut`, mais le write path réseau BO ne les persistait pas explicitement.
- résultat livré:
  - ajout d’un flag de vue module pour masquer `Informations` uniquement sur le support canonique `Abonnement réseau`;
  - complétion du sync BO réseau pour écrire `date_debut` et `date_facturation_debut`;
  - `Début` et `Début fact.` remontent désormais sur la fiche client TdR.

## Update 2026-03-11 — Vue `Abonnement réseau`: bloc dédié remonté
- audit court:
  - le bloc `Abonnement réseau` restait affiché en aside, donc après `Caractéristiques`;
  - les dates de début n’étaient pas visibles dans cette vue dédiée.
- résultat livré:
  - ajout d’un hook de vue haute pour rendre le bloc `Abonnement réseau` avant `Caractéristiques`;
  - ajout des lignes `Début` et `Début fact.` dans cette carte;
  - `Offres incluses` reste dans l’aside.


## Update 2026-03-11 — Correctif ciblé du point d’entrée `+` TdR
- audit court:
  - le flux `offres_clients` prérempli sur `Abonnement réseau` restait fonctionnel;
  - la détection TdR restait bien fondée sur `flag_client_reseau_siege=1`;
  - l’écart venait de `bo_clients_view.php`:
    - le `+` attendu avait disparu au profit de boutons directs;
    - puis le menu a été remis sur un bouton split, pas sur le `+` lui-même.
- résultat livré:
  - la fiche client TdR revient à un `+` avec choix rapide:
    - `Offre propre`
    - `Offre réseau`;
  - `Offre réseau` continue d’ouvrir `offres_clients` sur `Abonnement réseau`;
  - le clic sur `+` ouvre désormais directement le menu;
  - `Affiliés / hors cadre` reste un lien séparé transitoire.

## Update 2026-03-11 — Validation du point d’entrée standard `offres_clients`
- audit court:
  - la liste `offres_clients` n’a pas de header module dédié; le CTA `Ajouter` vient du core `bo_master_header.php`;
  - le contexte `id_client` filtré était déjà transmis au formulaire standard;
  - le support canonique `Abonnement réseau` restait déjà reconnu par le script et par `bo_module_form_extra.php`.
- résultat livré:
  - pour une liste `offres_clients` filtrée sur une TdR, `Ajouter` propose désormais:
    - `Offre propre`
    - `Offre réseau`;
  - `Offre réseau` ouvre `offres_clients` prérempli sur `Abonnement réseau`;
  - hors contexte TdR filtré, le CTA reste inchangé.

## Update 2026-03-11 — Correctif de résolution catalogue pour `Abonnement réseau`
- audit court:
  - le helper BO résolvait `Abonnement réseau` uniquement via `seo_slug`;
  - en dev, l’offre existait dans le catalogue BO et dans le filtre `Offre`, mais sans `seo_slug` canonique exploitable;
  - le select BO restait alimenté par `ecommerce_offres` trié par `nom`, d’où l’écart entre UI visible et helper à `0`.
- résultat livré:
  - fallback helper par `nom='Abonnement réseau'`;
  - synchronisation du `seo_slug` canonique si la ligne existe déjà;
  - dropdown BO `Ajouter` aligné sur Bootstrap 4 via `data-toggle="dropdown"`.

## Update 2026-03-11 — Fiche client TdR: réactivation du `+`
- audit court:
  - la fiche client TdR utilisait déjà le bon bouton dropdown unique et la bonne résolution catalogue;
  - l’attribut resté en Bootstrap 5 (`data-bs-toggle`) bloquait l’ouverture dans le runtime BO Bootstrap 4.
- résultat livré:
  - le `+` de la section `Offres` repasse en `data-toggle="dropdown"`;
  - `Offre propre` conserve le flux historique;
  - `Offre réseau` ouvre `offres_clients` prérempli sur `Abonnement réseau`.

## Update 2026-03-11 — Fiche client TdR: CTA meta vers la vue réseau durable
- audit court:
  - la fiche client TdR portait encore l’accès BO réseau dans la section `Offres`;
  - l’URL cible existait déjà et le guard TdR restait `flag_client_reseau_siege=1`.
- résultat livré:
  - l’URL `reseau_contrats` est hoistée pour être disponible dans le bloc meta;
  - le CTA apparaît désormais sous `Tête de réseau`;
  - le libellé visible devient `Voir / gérer les affiliés`;
  - l’ancien bouton de section `Offres` est retiré;
  - aucun autre flux BO n’est modifié.

## Update 2026-03-11 — Stabilisation BO minimale des points d’entrée réseau
- surfaces BO stabilisées:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- résultat canonique visé:
  - la fiche client TdR ouvre explicitement `Abonnement réseau` pour l’offre métier canonique;
  - l’accès à la vue BO réseau durable est porté dans le bloc meta sous `Tête de réseau`, avec le CTA `Voir / gérer les affiliés`;
  - `reseau_contrats` ne doit plus apparaître comme l’écran canonique du cadre négocié.
- état transitoire observé après patch:
  - `reseau_contrats` reste la vue BO de pilotage réseau utilisée en production pour les opérations affiliés / hors cadre;
  - ses write paths de contrat (`save_contrat`, `activate_contract`, `close_contract`) sont neutralisés côté script et requalifiés côté UI;
  - le moteur global support legacy n’est pas traité dans ce lot.

## Update 2026-03-11 — Re-baseline canonique réseau
- cible canonique:
  - une seule offre métier TdR: `Abonnement réseau`;
  - `Abonnement réseau` porte le cadre négocié et les offres incluses;
  - le hors cadre doit être géré depuis la page réseau par commande unitaire d’offres pour les affiliés choisis;
  - la destination BO cible devient une vue transverse `Gestion des affiliés`.
- état transitoire observé:
  - le BO reste encore partagé entre:
    - `offres_clients` pour la ligne `Abonnement réseau`
    - `reseau_contrats` pour la gestion/commande hors cadre;
  - `reseau_contrats` reste une vue BO réseau durable et héritée, pas un second objet métier canonique.
- règle de lecture:
  - toute mention de `Offre réseau` dans ce repo doit être comprise comme:
    - un héritage technique
    - ou un point d’entrée UI historique vers la vue réseau durable
    - jamais comme un second objet canonique concurrent.

## Update 2026-03-10 — Séparation BO canonisée: `Offre réseau` vs `Abonnement réseau`
- statut après re-baseline 2026-03-11:
  - ce bloc décrit l’état transitoire du lot BO du 2026-03-10;
  - il ne constitue plus la vérité canonique cible.
- `Offre réseau`:
  - reste la page BO `reseau_contrats`;
  - ne sert qu’au hors cadre:
    - lecture des offres affiliées hors cadre
    - création directe hors cadre
    - jamais de négocié sur cette page.
- `Abonnement réseau`:
  - devient une offre distincte créée via le flux standard `offres_clients`;
  - porte uniquement le négocié / cadre:
    - montant négocié
    - périodicité
    - nb d’affiliés inclus
    - offre incluse cible
    - jauge cible cadre;
  - sa vue BO détail affiche les offres incluses `cadre`, pas les lignes hors cadre.
- garde-fou métier:
  - l’objet `Abonnement réseau` est non effectif tant que son offre client reste `En attente`;
  - le hors cadre actif continue à vivre sur `Offre réseau` sans être relu comme une ligne incluse dans l’abonnement.

## Update 2026-03-10 — Étape 1 BO `reseau_contrats`: `Offre réseau` = hors cadre uniquement
- statut après re-baseline 2026-03-11:
  - `reseau_contrats` est documenté ici comme point d’entrée BO transitoire;
  - la cible n’est plus de stabiliser durablement un objet `Offre réseau` autonome.
- module `reseau_contrats`:
  - la page est renommée fonctionnellement `Gestion de l'offre réseau`;
  - elle ne pilote plus le contrat cadre, le montant négocié ni les paramètres du négocié;
  - elle sert désormais de lecture/gestion BO des seules offres affiliées hors cadre portées par la TdR.
- tableau BO:
  - n'affiche plus les affiliés `offre propre` ni `incluse contrat cadre`;
  - liste chaque ligne hors cadre avec:
    - affilié
    - offre
    - périodicité
    - statut
    - période
    - remise éventuelle
    - tarif;
  - conserve uniquement l'action `Désactiver` pour une ligne encore active.
- commande BO:
  - un bloc `Commander une offre hors cadre` reste disponible pour les affiliés sans offre active;
  - il force explicitement une création hors cadre directe et ne réactive jamais le cadre par effet de bord.
- wording BO:
  - la fiche client renomme l'entrée vers cette page en `Gérer l'offre réseau`.
- hors périmètre volontaire:
  - la future page BO du négocié / `Abonnement réseau`;
  - le renommage complet des wording PRO/public encore branchés sur l'offre réseau support existante.

## Update 2026-03-10 — BO `offres_clients`: `Terminer` une offre réseau clôt le réseau
- points d’entrée concernés:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- règle BO ajoutée:
  - si un opérateur BO passe l’offre réseau support à `Terminée` depuis `offres_clients`, le write path ne se contente plus d’écrire `id_etat=4`;
  - l’action déclenche une vraie clôture réseau cohérente:
    - contrat cadre clôturé
    - offres déléguées actives terminées immédiatement
    - activations affiliés marquées inactives
    - nouvelle offre réseau support `En attente` recréée/raccrochée au contrat pour un futur redémarrage.
- audit runtime 2026-03-10:
  - le write path réellement exécuté depuis l’édition BO `offres_clients` reste `do_script.php?...&p=script&mode=modifier`;
  - la reconnaissance de l’offre support ne dépend plus uniquement du catalogue `contrat-cadre-reseau`, mais aussi du rattachement canonique `ecommerce_reseau_contrats.id_offre_client_contrat`, ce qui couvre les lignes support legacy / migrées.
  - le `id_etat=4` posté par le BO était ensuite écrasé par le refresh générique `module_modifier(...) -> app_ecommerce_reseau_facturation_refresh_from_offer_client(...)`; ce refresh est désormais bypassé uniquement pour le cas explicite `offre support réseau -> Terminée`, afin de laisser le hook métier exécuter la clôture réelle.

## Update 2026-03-09 — BO `reseau_contrats`: ouverture contrôlée du formulaire contrat cadre
- module `reseau_contrats`:
  - si le contrat est `inactif` ou `cloture`, les champs de paramétrage sont masqués par défaut;
  - `Activer un contrat cadre` ouvre un formulaire complet de paramétrage;
  - la validation de ce formulaire persiste les paramètres puis active le contrat.
- contrat `actif`:
  - les champs restent visibles en lecture seule par défaut;
  - CTA `Modifier` pour passer en édition;
  - le CTA `Clôturer ce contrat cadre` reste visible seulement hors mode édition;
  - après sauvegarde, le formulaire se referme et revient en lecture seule.

## Update 2026-03-12 — Schéma pré-prod `reseau_contrats` réaligné sur l'existant utile
- module `reseau_contrats`:
  - le schéma cible du script phpMyAdmin ne porte plus `ecommerce_reseau_contrats.contract_state`;
  - l'état contractuel reste calculé à la lecture depuis la ligne support `ecommerce_offres_to_clients`;
  - le schéma cible ne porte plus non plus `max_joueurs_par_affilie`, désormais dérivé de `id_erp_jauge_cible`.
- colonnes explicitement conservées dans `ecommerce_reseau_contrats`:
  - `id`
  - `id_offre_client_contrat`
  - `id_client_siege`
  - `max_affilies_activables`
  - `id_offre_delegation_cible`
  - `id_erp_jauge_cible`
  - `montant_socle_ht`
  - `id_paiement_frequence`
  - `online`
  - `id_entite_utilisateur`
  - `date_ajout`
  - `date_maj`
- garde-fou:
  - aucune mise à jour de `documentation/canon/data/schema/DDL.sql` n'est faite tant qu'une source SQL canonique complète de `ecommerce_reseau_contrats*` n'est pas prouvée.

## Update 2026-03-09 — BO contrat cadre: montant hors cadre affiché après remise réseau
- module `reseau_contrats`:
  - la synthèse `Part variable affilies` reflète désormais le montant net après remise réseau volume;
  - le taux de remise appliqué est rappelé dans la synthèse, avec son assiette:
    - affiliés détenant une délégation active
    - `cadre` ou `hors_cadre`.
- tableau affiliés:
  - la colonne `Offre` affiche aussi la jauge de l’offre active;
  - ajoute une colonne `Tarif` dédiée;
  - `Déléguée incluse contrat cadre`:
    - montant négocié du cadre / nombre d’offres déléguées incluses;
    - format `HT / mois` par offre incluse active;
  - `Déléguée hors cadre`:
    - `HT` brut
    - `Remise réseau`
    - `HT appliqué / mois`;
  - `Offre propre`:
    - `HT / mois`;
  - `Pas d’offre`:
    - `-`.
- garde-fou:
  - la colonne `Offre` reste dédiée à l’identification de l’objet BO;
  - les montants sont isolés dans `Tarif`.

## Update 2026-03-09 — Vitrine pricing: référentiel unique minimal
- la vitrine tarifaire abonnement ne doit plus porter sa propre grille métier:
  - la source de référence est désormais le helper global `app_ecommerce_tarifs_reference_*`.
- portée:
  - `fo_tarifs_offre_detail.php` continue d’afficher le widget partagé;
  - le panier vitrine (`fo_offres_paniers_form_script.php` -> `app_ecommerce_offre_panier_gerer(...)`) recalcule désormais le `prix_ht` côté serveur quand le cas est couvert.
- garde-fou:
  - si une fréquence / offre n’est pas couverte par le référentiel minimal, le fallback legacy reste autorisé.

## Update 2026-03-09 — CTA BO `Activer` unifié + flux hors cadre complet
- module `reseau_contrats`:
  - `Activer` reste visible pour tout affilié sans offre active, hors cas `Offre propre`;
  - l’ancienne condition d’affichage ne montrait le CTA que si:
    - quota cadre disponible
    - ou offre cible déjà définie
    - ou délégation legacy déjà sélectionnable;
  - la nouvelle condition est métier:
    - pas d’offre active
    - pas d’offre propre active
    - donc CTA `Activer` affiché.
- comportement BO:
  - si le contrat cadre est exploitable:
    - création auto de l’offre cible cadre
    - activation dans le cadre;
  - sinon, même flux hors cadre pour:
    - pas de contrat exploitable
    - pas d’offre cible cadre
    - quota cadre atteint
  - ce flux hors cadre expose:
    - choix de l’offre
    - choix de la jauge / capacité
    - puis création d’une nouvelle délégation hors cadre.
- tableau affiliés:
  - ajoute les sélecteurs BO nécessaires au hors cadre directement dans la colonne `Action`.
  - le choix de réactivation d’une ancienne délégation n’est plus exposé dans la vue.

## Update 2026-03-09 — Fermeture 2A contrat cadre réseau
- module `reseau_contrats`:
  - recharge désormais le reclassement métier au chargement de la page;
  - affiche explicitement les 3 paramètres du contrat cadre:
    - montant négocié
    - quota max d’affiliés inclus
    - offre SI dédiée cible
  - expose une synthèse quota:
    - délégations actives résolues
    - quota absorbé
    - quota restant
- liste affiliés:
  - la source d’affiliation reste strictement `clients.id_client_reseau`;
  - la colonne métier devient une lecture de couverture commerciale calculée:
    - `offre propre`
    - `offre déléguée incluse contrat cadre`
    - `offre déléguée hors cadre`
    - `aucune offre`
- règle BO:
  - le reclassement `cadre / hors_cadre` n’est plus un pilotage manuel principal;
  - il dérive du quota négocié, de l’ancienneté des délégations legacy actives et du fait que le cadre soit réellement exploitable (`offre cible + quota`).

## Update 2026-03-09 — Tableau BO affiliés refondu
- page concernée:
  - `reseau_contrats` -> tableau `Affiliés du siège`
- rendu simplifié:
  - colonnes:
    - `Affilié`
    - `Statut commercial`
    - `Offre`
    - `Action`
- lecture métier:
  - suppression des anciennes lectures techniques `Activation réseau` et `Offre déléguée résolue`;
  - affichage direct de l’offre active réellement concernée avec lien BO;
  - action clarifiée:
    - `Non pilotable ici` pour une offre propre
    - `Désactiver` pour une délégation active
    - `Activer` sinon.
- câblage CTA:
  - `Activer` n’est plus un simple marquage d’activation:
    - crée l’offre cible si nécessaire
    - ou réactive une offre déléguée existante
    - puis rejoue le reclassement cadre/hors cadre;
  - `Désactiver` termine la ligne d’offre déléguée active concernée, puis relance refresh + reclassement.

## Update 2026-03-09 — BO contrat cadre réseau: couverture affilié explicite pour éviter la double comptabilisation
- module `reseau_contrats`:
  - expose désormais un pilotage affilié de `mode_facturation` au niveau du contrat réseau;
  - valeurs BO:
    - `Inclus dans le cadre`
    - `Facturé en plus`
- stratégie finale:
  - toute ancienne délégation active issue TdR est initialisée en `Facturé en plus` (`hors_cadre`);
  - le BO permet ensuite de reclasser explicitement l’affilié en `Inclus dans le cadre` (`cadre`) lorsqu’il est absorbé par la négociation.
- objectif:
  - ne plus conserver d’état transitoire `legacy`;
  - laisser au BO réseau le réglage explicite entre part fixe cadre et part variable affiliés.

## Update 2026-03-09 — BO contrat cadre: état explicite et CTA métier
- module `reseau_contrats`:
  - expose un état contractuel lisible, mais désormais dérivé de l’offre support réseau;
  - n’utilise plus `ecommerce_reseau_contrats.contract_state` comme colonne runtime;
  - conserve les anciennes actions contrat BO neutralisées, sans les réintroduire comme write path métier.
- effet métier:
  - chaque changement d’état réel de l’offre support relance:
    - le recalcul de l’agrégat de l’offre réseau support;
    - le reclassement cadre / hors cadre;
    - le recalcul du quota exploitable.
- synthèse BO:
  - distingue désormais:
    - `Cadre négocié`
    - `Socle appliqué à l’agrégat`
    - `Part variable affiliés`
- garde-fou:
  - le schéma pré-prod de référence retire `contract_state`; aucun fallback SQL de lecture de cette colonne n’est encore requis.

## Update 2026-03-09 — BO contrat cadre réseau TdR: écran simplifié
- module `reseau_contrats`:
  - supprime de l’écran courant les CTA de maintenance legacy déjà couverts automatiquement au chargement;
  - ferme le choix de l’offre support:
    - affichage en lecture seule `Offre support`
    - lien discret vers la ligne `offres_clients` existante;
  - recentre le formulaire sur la lecture métier:
    - `Montant cadre négocié (HT)`
    - capacité d’activation affiliés
    - joueurs max par affilié.
- champs retirés du premier écran:
  - `Jauge cible (référentiel)`
  - `Offre cible de délégation (catalogue)`
- point métier:
  - l’écran simplifié reste aligné avec l’agrégateur réseau;
  - la distinction `cadre / hors_cadre` est désormais pilotée dans la liste des affiliés.

## Update 2026-03-09 — Fiche client BO TdR: exclusion des offres déléguées legacy
- la section `Offres` de la fiche client siège réseau n’affiche plus les lignes legacy déléguées vers affiliés.
- règle de filtrage:
  - sur un client `flag_client_reseau_siege=1`, exclure les lignes `ecommerce_offres_to_clients` avec `id_client_delegation>0`.
- la fiche client BO affilié remonte désormais aussi les offres legacy déléguées:
  - inclusion des lignes `ecommerce_offres_to_clients` où `id_client_delegation = affilié` et `id_client <> affilié`;
  - rendu léger: nom du compte TdR dans la colonne `Délégation`.
- restent visibles:
  - offres propres TdR
  - offre support `Contrat cadre réseau`
- aucune nouvelle section dédiée n’est ajoutée:
  - la synthèse des délégations reste portée par la vue `reseau_contrats`.

## Doc discipline
- `canon/repos/www/TASKS.md` à mettre à jour à chaque action significative (update-not-append si une tâche existe déjà).
- `canon/repos/www/README.md` à mettre à jour dès qu’un changement impacte le fonctionnel côté BO/FO.
- En cas de divergence, le code fait foi ; corriger la doc immédiatement.

## Scope principal
- Back-office `www`: `www/web/bo/www/modules/**`.
- Reporting SaaS pivot: `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`.

## Update 2026-03-08 — BO réseau (backfill offre dédiée)
- module `reseau_contrats`:
  - auto-vérifie la présence de l’offre réseau dédiée du siège à l’ouverture de la page.
  - expose un bouton opérateur: `Créer / rattraper offre réseau dédiée`.
  - script associé: `mode=backfill_siege` (retour UI `backfill_ok`).
- objectif:
  - sécuriser le rattrapage des sièges legacy sans attendre une migration manuelle globale.

## Update 2026-03-09 — BO réseau (facturation persistée TdR)
- module `reseau_contrats`:
  - le BO édite désormais un `montant socle réseau HT / mois` distinct du montant agrégé des offres affiliées.
  - la synthèse affiche le montant facturable total de la TdR:
    - socle réseau
    - plus offres affiliées actives financées par la TdR.
- persistance:
  - le socle reste stocké dans `ecommerce_reseau_contrats.montant_socle_ht`.
  - le `prix_ht` de la ligne support `ecommerce_offres_to_clients` reflète le montant facturable courant recalculé.
- effet BO:
  - le contrat cadre réseau et l’offre réseau support restent cohérents sans écriture opportuniste dispersée dans les vues BO.
  - la fiche client siège répercute aussi ce montant facturable sur la ligne d’offre `Contrat cadre réseau` dans la section `Offres`.

## Reporting BO — métriques démos (référence)
- Section `Objectifs`:
  - `Demos` = démos visiteurs (`id_client=1557`) + démos des nouveaux inscrits sur la période de référence.
  - Sémantique conservée: comptage en **nombre de sessions démo** (`COUNT(cs.id)`), pas en distinct utilisateurs.
- Tableau `Visiteurs / prospects / clients`:
  - Colonne `Démos nvx inscrits`.
  - Définition: session démo dans la période ET client inscrit (`clients.date_ajout`) dans la même période.
  - Exclusions: client démo technique `id_client=1557`, clients test `id_etat=4`.
- Détail modal (clic sur la colonne): même filtre que la métrique agrégée (mois + période de référence + exclusions).

## Reporting BO — `Jeux et joueurs` (sessions/joueurs)
- `Sessions`: inclut les sessions papier et numériques, dès lors qu’elles sont terminées et configuration complète (hors démos).
- `Joueurs`: inchangé, basé sur les joueurs numériques.
- Ratios:
  - `Moy. joueurs / client`
  - `Moy. joueurs / session`
 sont calculés uniquement sur les sessions numériques (papier exclu du dénominateur de ces ratios).

## BO Réseau — Contrat cadre (Étape 2)
- Entrée métier depuis la fiche client siège:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - CTA: `Gestion contrat réseau / délégation`.
- Module BO dédié:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- Contrat commercial conservé dans `ecommerce_offres_to_clients` (support Stripe/statut/validité).
- Capacités + activation affilié tracée via persistance dédiée (`ecommerce_reseau_contrats`, `ecommerce_reseau_contrats_affilies`).
- Garde-fou:
  - écriture brute de `id_client_delegation` verrouillée par défaut dans le CRUD générique (`allow_delegation_raw_write=1` requis pour bypass legacy explicite).

## BO `offres_clients` — Support canonique `Abonnement réseau`
- Le formulaire BO de `ecommerce/offres_clients` reste rendu par le moteur générique, avec un hook minimal vers un renderer dédié de module si nécessaire.
- Pour l’offre canonique `Abonnement réseau` sur une tête de réseau:
  - un renderer BO dédié est utilisé;
  - les champs éditables exposés restent ceux du cadre négocié:
    - `Etat offre`
    - `Montant négocié HT`
    - `Périodicité négociée`
    - `Nb affiliés inclus`
    - `Jauge cible cadre`
    - `Offre incluse cible`
- Hors contexte support canonique, le form standard `offres_clients` reste sur son comportement historique.

## BO Reporting jeux — Cron dédié et lecture sur agrégats
- Le bloc d'agrégats jeux du BO est maintenant factorisé dans `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php`.
- Deux points d'entrée coexistent:
  - `www/web/bo/cron_routine_bdd_maj.php` reste la routine historique "commerce" et n'execute plus les agrégats jeux;
  - `www/web/bo/cron_reporting_games_aggregates.php` porte le cron dedie "jeux", execute le helper partage et envoie son propre mail de rapport.
- Les tables actuelles re-utilisees par le reporting sont:
  - `reporting_games_sessions_monthly`
  - `reporting_games_players_monthly`
  - `reporting_games_players_by_type_monthly`
  - `reporting_games_sessions_detail`
  - `reporting_games_demos_detail`
  - `reporting_games_content_popularity_365d`
- `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` privilegie desormais ces agrégats pour les sessions mensuelles et la serie N-1 quand ils sont disponibles; le brut reste en fallback.

## Update 2026-04-14 — FO fiche `place` (lazy loading onglets)
- la fiche établissement publique ne rend plus `Agenda` ni `Sessions passées` côté serveur au premier hit;
- les deux onglets sont chargés à la demande via `fo_clients_view_ajax.php`:
  - `section=agenda`
  - `section=archive`
- le rendu session FO est mutualisé dans `fo_clients_view_shared.php` pour éviter les écarts entre page principale et fragments AJAX;
- l'onglet `Classements` reste affiché par défaut au chargement, mais si la réponse AJAX indique qu'aucun leaderboard exploitable n'existe sur la période, la page bascule automatiquement vers `Agenda`.
- addendum perf:
  - les `Classements` et la synthèse haute ne partagent plus la même requête AJAX;
  - `section=overview` charge d'abord les leaderboards;
  - `section=summary` charge ensuite la synthèse historique, ce qui permet d'afficher plus vite le bloc métier le moins coûteux.
  - les leaderboards FO `place` disposent maintenant aussi d'un cache de session court par `client + jour + année + trimestre`, pour éviter le recalcul de la même saison lors des retours sur la fiche ou des changements aller/retour de sélecteur.
  - addendum archives FO: la fiche `place` s'appuie maintenant sur un helper global dédié `app_client_joueurs_dashboard_archive_sessions_get(...)`, extrait de la logique d'archives pro, pour sélectionner les sessions passées utiles du lieu.
  - addendum leaderboard FO: la colonne droite `sessions récentes` réutilise ce même helper global avec filtre jeu/date, au lieu d'une reconstruction locale.
  - addendum correctif AJAX FO: l'onglet `Agenda` n'utilise plus `fo_sessions_list_bloc.php` dans ce contexte asynchrone; il rend maintenant une carte FO dédiée, comme `Sessions passées`, pour éviter les fatals legacy.
  - addendum correctif JS: le sélecteur de saison des classements recharge désormais bien la saison demandée; l'appel `loadOverview(...)` passait auparavant les paramètres dans le mauvais ordre et retombait sur la saison courante.

## Update 2026-04-14 — FO listes `agenda` / `place` (géographie FR + étranger)
- le pattern `Département / pays` déjà posé côté agenda FO/play est désormais aussi appliqué à la liste publique des organisateurs `place`;
- le select `www/fo/place` ne se limite plus aux départements français:
  - départements réellement présents dans la liste publique;
  - puis pays étrangers réellement présents;
- côté FO, les départements conservent leur libellé référentiel complet (`n° + nom`) au lieu d'un simple numéro.
- addendum:
  - l'option `France` n'est pas proposée dans la section `pays`, les départements FR couvrant déjà ce cas;
  - le libellé du menu joueur passe à `Agenda des soirées jeux`, avec hardening CSS `white-space: nowrap` sur la navigation desktop et les liens de dropdown pour éviter les retours à la ligne parasites.
  - le rendu archive FO `place` reste appuyé sur les cartes sessions legacy; le helper global `cotton_quiz_get_classement_session(...)` est maintenant sécurisé pour ne plus faire tomber l'endpoint archive si une requête résultat quiz échoue sur un cas ancien.
  - addendum correctif: l'onglet `Sessions passées` de `place` n'embarque plus le bloc FO legacy complet; il passe désormais par une carte dédiée rendue dans `fo_clients_view_shared.php`, plus sûre pour l'AJAX et sans dépendance à la branche legacy `photo gagnant quiz`.
  - addendum leaderboard FO: la colonne droite `sessions récentes` des classements s'appuie maintenant sur les `ranked_session_ids` renvoyés par le moteur global, ce qui réaligne strictement les sessions affichées sur celles réellement comptées dans le classement agrégé.

## Update 2026-04-15 — FO includes `photos_ec` réalignés sur `main`
- les includes FO locaux de `photos_ec` avaient été rechargés depuis prod et divergeaient désormais nettement de `main` sur:
  - `www/web/fo/includes/css/fo_custom.css`
  - `www/web/fo/includes/css/fo_custom_20251120.css`
  - `www/web/fo/includes/header/fo_header_main.php`
  - `www/web/fo/includes/footer/fo_footer_main.php`
  - `www/web/fo/includes/js/fo.js`
- ces 5 fichiers ont été réalignés sur le contenu de `main` pour corriger une régression visuelle constatée sur `photos_ec`, sans modifier les évolutions métier spécifiques de branche sur `place` et `agenda/session`.
- effets restaurés:
  - styles homogénéisés des logos de références FO;
  - filtres noir/blanc et hover des logos;
  - wrapper d'harmonisation des images catalogue/démo;
  - header et JS FO cohérents avec `main`.

## Update 2026-04-15 — FO fiche `place`: podium agrégé dans `Classements`
- l'onglet `Classements` de la fiche `place` affiche désormais un podium au-dessus du tableau `Top 10`;
- le podium reprend les données déjà calculées par le moteur global:
  - `teams_podium` pour `Cotton Quiz`;
  - `players_podium` pour `Blind Test` et `Bingo Musical`;
- le rendu visuel réemploie le style du podium de la page détail d'une session terminée du site:
  - bandeau de rang `#1/#2/#3`;
  - accent or / argent / bronze;
  - visuel joueur/équipe si disponible, sinon placeholder trophée/médaille;
  - score et participations sous le libellé;
- l'intégration reste localisée à `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`, juste avant le titre `Top 10` de chaque classement agrégé;
- addendum desktop:
  - le podium est maintenant affiché pleine largeur au-dessus de la ligne `classement + sessions récentes`;
  - la colonne droite `sessions récentes` revient à une limite basée sur la seule hauteur du tableau de classement, ce qui réaligne son départ visuel sur la table desktop.
  - la ligne desktop `classement + sessions récentes` utilise maintenant un espacement horizontal plus explicite (`justify-content-between` + gutters renforcés) pour mieux occuper la largeur disponible.
  - audit structurel complémentaire:
    - l'alignement visuel desktop conserve un `padding-top: 3rem` sur `.place-leaderboard-recent-sessions-col`;
    - la colonne `sessions récentes` s'appuie maintenant sur un wrapper simple centré à largeur max, sans grille Bootstrap interne `row > col-12`.
- addendum responsive:
  - le tableau `Top 10` passe maintenant par un wrapper explicite `place-leaderboard-table-responsive` pour réaffirmer le scroll horizontal mobile;
  - la colonne flex du tableau force désormais `min-width: 0`, pour que le scroll horizontal puisse jouer au lieu de faire déborder la page;
  - sur petits écrans, `.table-classement` reçoit aussi une largeur minimale, afin de forcer le scroll horizontal plutôt qu'un tassement des colonnes avec coupe du contenu;
  - un `rem` parasite a aussi été retiré de `fo_custom.css` dans cette zone.

## Update 2026-04-15 — FO fiche `place`: perf lot 1 sur `Classements` / `Sessions passées`
- la route AJAX `overview` de `fo_clients_view_ajax.php` ne charge plus l'agenda complet ni les 12 `sessions passées` juste pour renvoyer les leaderboards;
- les flags `has_agenda` et `has_archive` sont maintenant calculés via des helpers FO bornés à un seul résultat;
- `fo_clients_view_archive_sessions_get(...)` et la colonne `sessions récentes` appellent désormais le helper global archive en mode `historique seul`, sans relire les sessions à venir;
- effet attendu:
  - premier chargement `Classements` plus léger;
  - moins de travail serveur inutile avant ouverture effective de `Sessions passées`.

## Update 2026-04-15 — FO fiche `place`: tableau plein large, colonne `sessions récentes` masquée
- la colonne desktop `sessions récentes` a finalement été retirée de l'onglet `Classements`;
- le tableau `Top 10` reprend maintenant toute la largeur disponible du bloc sous le podium;
- le code HTML/CSS de l'ancienne colonne reste conservé en commentaire pour réutilisation ultérieure;
- le calcul serveur correspondant reste neutralisé:
  - `fo_clients_view_leaderboard_sections_get(...)` ne déclenche plus `fo_clients_view_recent_ranked_sessions_get(...)`;
  - le format mobile du tableau n'est pas modifié et conserve son wrapper responsive dédié.

## Update 2026-04-15 — FO fiche `place`: enrichissement de `Sessions passées`
- les cartes de l'onglet `Sessions passées` essaient désormais d'afficher en illustration la photo du participant ou de l'équipe classé(e) rang 1 sur la session;
- si aucune photo exploitable n'est remontée par `app_session_results_get_context(...)`, la carte conserve le visuel de jeu ou du lieu déjà en place;
- l'onglet archive est maintenant paginé par lots de 12 cartes:
  - premier chargement inchangé à 12;
  - bouton `Afficher plus` en bas de bloc;
  - ajout incrémental de 12 cartes supplémentaires via AJAX sans recharger tout l'onglet.
- addendum:
  - quand la photo du rang 1 est utilisée, son `src` reprend maintenant le même pattern que les photos podium/résultats déjà en place, sans suffixe de version artificiel;
  - le CTA `Afficher plus` reprend le style repo `btn btn-color-20 m-2` avec flèche à droite.
  - correctif complémentaire: sur les cartes archive injectées en AJAX, la photo du rang 1 n'est plus laissée en lazy-load `src="#"`; elle est servie directement avec fallback `onerror`, ce qui réactive son affichage effectif.

## Update 2026-04-16 — FO fiche `place`: descriptions lieu normalisées
- la baseline courte et le descriptif long d'un lieu passent maintenant par la même normalisation texte que l'espace `pro`;
- les anciens `<br>` / balises résiduelles sont nettoyés avant affichage;
- le rendu public conserve les retours à la ligne utiles sans dépendre d'un HTML saisi dans le back-office.

## Update 2026-04-16 — FO fiche `place`: fallback image `Sessions passées`
- les cartes de `Sessions passées` ne lazy-loadent plus leur visuel principal une fois injectées en AJAX;
- effet visible: quand aucune photo gagnant n'est disponible, le fallback sur le visuel de jeu s'affiche bien dans la carte au lieu de rester sur `src="#"`;
- le fallback `onerror` des photos gagnant reste inchangé pour les cas où une photo principale existe mais échoue au chargement.

## Update 2026-04-17 — FO agenda: retrait des sessions deja terminees

Les listes `www` qui alimentent:
- l'onglet `Agenda` des fiches `place`;
- la page publique `agenda`;
- le widget agenda;

ne s'appuient plus uniquement sur `app_sessions_get_liste(... a_venir=1 ...)`.

Apres chargement, elles repassent maintenant par le helper partage `app_sessions_filter_by_archive_state(...)`. Une session numerique deja terminee le jour meme quitte donc bien l'agenda public et devient eligible a `Sessions passées` sur la fiche lieu, sans attendre le lendemain.

Le bloc `fo_sessions_list_bloc.php` utilise aussi cette meme regle pour son etat `Jeu termine`.

## Update 2026-04-17 — FO `Sessions passées`: prise en compte des sessions du jour terminées

Le helper `fo_clients_view_archive_sessions_get(...)` appelait encore l'archive globale avec `include_upcoming_sessions = 0`.

Effet de bord: une session du jour deja terminee pouvait etre retiree de l'onglet `Agenda`, mais ne pas remonter dans `Sessions passées` tant que sa date n'etait pas passee.

Le branchement utilise maintenant `include_upcoming_sessions = 1`, ce qui permet a l'onglet `Sessions passées` de recuperer aussi ces sessions du jour deja archivees par la regle metier.

## Update 2026-04-17 — FO `place`: podium agrégé `Bingo Musical` aligné sur les autres jeux

Le builder `fo_clients_view_leaderboard_podium_cards_get(...)` gardait une branche speciale pour `bingo` qui regroupait tous les ex-aequo d'un meme rang dans une seule carte.

Cette exception a ete retiree. Le podium agrégé `www` construit maintenant ses cartes comme pour `blindtest` et `quiz`: tri stable par rang puis par ordre source, puis une carte par ligne de podium.

Effet attendu: sur la fiche `place`, trois joueurs `#1` en `Bingo Musical` occupent trois cartes distinctes sur la ligne podium, au lieu d'etre empiles dans la seule colonne `#1`.

## Update 2026-04-17 — WWW sessions `quiz`: libellé compact `1 serie` / `x series`

Les cartes session et le `h1` de la page detail `www` ne se contentent plus du `theme` brut renvoye par `app_jeu_get_detail(...)` pour `Cotton Quiz`.

Elles utilisent maintenant en priorite `quiz_series_label` quand il est disponible sur la ligne session, ce qui permet d'afficher un libelle court adapte aux contraintes d'espace:
- `1 serie`
- `2 series`
- `4 series`

Si ce libelle n'est pas disponible, le fallback conserve `theme`, mais ne l'affiche plus lorsqu'il duplique simplement `nom_court` (`Cotton Quiz Cotton Quiz`).

## Update 2026-04-17 — WWW sessions `quiz`: raccord au helper partagé

La logique locale `www` a ete remplacée par un appel direct au helper `global` `app_session_quiz_compact_label_get(...)`.

Effet attendu: `www`, `play` et `pro` reposent maintenant sur la même règle de libellé compact pour `Cotton Quiz`, avec le même fallback vers les anciens formats.

## Update 2026-04-17 — Fiche session `www`: mention de réserve sous les séries programmées

La fiche détail session `www` affiche maintenant une petite mention italique sous le bloc `Séries programmées`:

`(Sous réserve de modification par l'organisateur.)`

La mention n'apparaît que tant que la session n'est pas archivée.

## Update 2026-04-17 — Fiche session `www`: bloc playlist visible pour `blindtest` / `bingo`

La carte détail session `www` expose maintenant aussi un bloc visible entre `Date` et `Lieu` pour les jeux musicaux:

- `Playlist : {nom_playlist}`
- puis la mention `(Sous réserve de modification par l'organisateur.)` tant que la session n'est pas archivée.

Effet attendu: `Blind Test` et `Bingo Musical` disposent du même niveau d'information contextuelle que `Cotton Quiz` sur la fiche session publique.
## Update 2026-05-11 — LP operations reseau automatiques depuis TdR
- ecran concerne:
  - `/lp/operation/{slug}`
  - fallback direct possible via `/lp/lp.php?utm_source=reseau&utm_campaign=affiliation&utm_term={slug}&utm_medium=landing-operation`
- resultat livre:
  - la landing reseau n'est plus alimentee par `www/web/lp/includes/config/lp_operations.php`, supprime du fonctionnement standard;
  - `/lp/operation/{slug}` est conserve comme compatibilite legacy: il reutilise la resolution TdR/reseau de `/lp/reseau/{slug}` et ne depend plus de `operations_evenements`;
  - critere public minimal: compte marque `flag_client_reseau_siege=1`, slug exact, compte non `online=0` si le champ existe;
  - les donnees affichees viennent de la TdR, du branding reseau et de l'abonnement reseau actif le plus recent si sa personnalisation LP est active;
  - le badge periode n'affiche des dates que si un abonnement reseau actif est detecte et si debut + fin fiables existent cote support reseau;
  - le CTA principal reste le lien technique `/utm/reseau/{slug}` pour laisser le parcours PRO existant gerer signup/signin, affiliation et activation incluse;
  - la landing conserve les anciennes LP historiques (`offre-essai`, `1-jeu-offert`, `brasserie-trompe-souris`, `saison-hiver`) hors routes reseau dediees.
- limite documentee:
  - aucune notion explicite de champ `publiable` n'a ete trouvee dans le modele local; le garde-fou choisi refuse les comptes non TdR, mais ne conditionne plus l'existence de la LP a un abonnement reseau actif.

## Update 2026-05-19 — BO `Jeux`: lecture des statuts playlists

La section BO `Jeux > Playlists musicales` affiche maintenant separement:

- `Publication`: champ `jeux_bingo_musical_playlists.online`, affiche `Publiée` ou `Non publiée`;
- `Validation`: champ `jeux_bingo_musical_playlists.flag_validated`, affiche `Validée` ou `Non validée`;
- `Communauté`: champ `jeux_bingo_musical_playlists.flag_share_community`, affiche `Partagée`, `Non partagée` ou `Sans objet` pour les contenus Cotton.

Pour les playlists, l'origine `Communaute` est detectee si le contenu client est partage via `flag_share_community=1`, avec `community_items` comme signal complementaire quand il existe.

Le filtre `Usage` a ete retire de la liste playlists; l'usage reste visible sur la fiche detail et dans les sessions liees.

La colonne `Communauté` est masquee lorsque le filtre actif est `Cotton` ou `Privées`. La liste utilise le bloc de pagination BO historique; les parametres custom `q`, `origin`, `sort` et `dir` sont conserves dans ce pager via l'extension optionnelle `$bo_pagination_extra_query`.

La colonne `Auteur / client` est aussi masquee sur le filtre `Cotton`. Quand le filtre d'origine est vide (`Origine`), les liens de tri conservent explicitement `origin=` pour rester sur tous les contenus au lieu de retomber sur le defaut `Cotton`.

Les liens `Fiche PRO` ajoutent maintenant le contexte attendu par la bibliotheque PRO (`game`, `type`, et `community_state` pour les contenus communaute non publies ou prives). Le tableau playlists est rendu dans un conteneur responsive afin de conserver une lecture horizontale propre sur les ecrans etroits.

La V1 reste en lecture seule: ces statuts clarifient la supervision mais ne publient, depublient ni ne valident de contenu depuis le BO.

## Update 2026-05-19 — BO `Jeux`: séries Cotton Quiz

La page `Vue d'ensemble` a ete retiree de la section BO `Jeux`: le menu donne directement acces aux `Playlists musicales` ou aux `Series Cotton Quiz`.

La liste `Jeux > Series Cotton Quiz` reprend les conventions de la liste playlists:

- filtre origine par defaut `Cotton`, avec option vide `Origine` pour afficher tous les contenus;
- filtre `Type` (`L`, `T`);
- colonnes `Publication`, `Validation`, `Communauté` separees;
- colonnes `Communauté` et `Auteur / client` masquees quand le filtre actif les rend inutiles;
- tri par colonnes, pagination BO historique et tableau responsive;
- liens `Fiche PRO` avec contexte `game`, `type` et `community_state` quand necessaire.

La fiche série affiche les mêmes statuts séparés, retire le bloc `Alertes qualite`, ajoute un lien PRO contextualise et rend les tableaux `Questions` / `Sessions liees` responsive.

Les séries temporaires `T` (`questions_lots_temp`) sont considérées comme des contenus Cotton dans cette supervision BO: elles apparaissent avec le filtre `Origine=Cotton` et avec l'option globale `Origine`, mais pas dans les filtres `Communauté` ou `Privées`.

Dans les listes `Playlists musicales` et `Series Cotton Quiz`, la colonne `Liens` distingue maintenant le lien local BO `Détail` du lien externe `Fiche PRO`.

Dans les fiches detail BO `Jeux`, les boutons de retour vers les listes utilisent une variante visible du theme BO.

La colonne `Publication` des `Series Cotton Quiz` traduit `questions_lots.id_etat` selon l'origine: `Communauté + id_etat=1` devient `En attente`, `Cotton + id_etat=1` devient `À compléter`, `id_etat=2` devient `Publiée`, et `id_etat=3` devient `Archivée`. Sur le filtre `Privées`, la colonne `Publication` est masquée car ces thématiques n'ont pas vocation à être publiées dans le catalogue.

Pour les series Quiz, l'origine `Communauté` suit le partage explicite `flag_share_community=1`. Une serie non partagee reste donc `Privées`, meme si une ancienne projection `community_items` existe encore.

La colonne `Communauté` n'est plus affichee dans les listes `Playlists musicales` et `Series Cotton Quiz`; ce statut est pilote par le filtre d'origine et reste visible dans les fiches detail. Sur le filtre `Privées`, la colonne `Publication` est masquée pour les playlists comme pour les séries.

## Update 2026-05-20 — BO `Animations`: filtres natifs sessions

La liste `Animations > Sessions` utilise maintenant un seul bloc de filtres, celui du header BO historique. L'ordre affiché est:

- `Client`
- `Date`
- `Jeu`
- `Format`
- `Démo`
- `Session complète`

Les filtres `Date`, `Jeu` (`Blind Test`, `Bingo Musical`, `Cotton Quiz`) et `Format` (`Numérique`, `Papier`) sont injectés par un hook module `bo_sessions_filter_extend(...)`, ce qui évite la carte de filtres locale ajoutée précédemment. `Démo` et `Session complète` sont aussi gérés dans ce hook pour conserver l'ordre demandé. `Date` utilise le datepicker BO natif et filtre `championnats_sessions.date`.

Le hook générique du header BO est optionnel (`bo_{module}_filter_extend(...)`) et ne change pas les autres modules. Les exports BO chargent aussi les fonctions module afin qu'un filtre additionnel de liste puisse être repris par `bo_{module}_sql_filter_append(...)`.

Le tableau sessions reste en pleine largeur dans une zone `.table-responsive`, sans classe DataTables responsive qui masque des colonnes sur desktop.

Dans la colonne `Jeu`, la mention `[ NUMERIQUE ]` / `[ PAPIER ]` est calculée depuis `championnats_sessions.flag_controle_numerique`, donc depuis le format réel de la session affichée. La cellule `Jeu` entière ouvre la fiche session via un vrai lien HTML, sans `onclick`, afin de conserver Ctrl+clic / ouverture nouvel onglet. La colonne `id` n'expose plus les liens `Accès Player`; elle affiche `Voir les logs`, construit avec la même URL `games/logs_session.html?sessionId={token}` que la fiche session.

Le nombre de participants affiché en liste et dans le bloc `Résultats` de la fiche session passe par le même helper BO. La source est le détail session enrichi par `app_session_get_detail(...)` (`nb_participants` + `nb_joueurs_max`). Le rendu est harmonisé avec la jauge: `x joueur(s) / y max` pour Blind Test et Bingo Musical, `x équipe(s) / y max` pour Cotton Quiz.

La colonne `Jeu` ne rend plus le bloc technique Bingo `Papier / Numérique / phases`; ces données restent hors liste. Dans la colonne `id`, `id_playlist` et `id_playlist_client` sont affichés en texte/code simple, sans lien.

La fiche détail session affiche aussi le `Format` juste sous `Type`, à partir de `championnats_sessions.flag_controle_numerique`, puis une chip `État` calculée avec le même helper que la liste sessions (`app_session_edit_state_get(...)`): `En attente`, `En cours` ou `Terminé`. Dans le bloc `Informations`, une ligne `Interfaces` regroupe trois CTA légers pointant vers les interfaces de jeu construites depuis `conf['games_url'][conf['server']]`: `/master/{token}`, `/play/{blindtest|bingo|quiz}/{token}` et `/remote/{blindtest|bingo|quiz}/{token}`. Dans le bloc `Thématique`, les sessions Bingo lient la playlist client à sa playlist catalogue via `jeux_bingo_musical_playlists_clients.id_playlist`, vers `Jeux > Playlists`; le format est rendu sans durée (`Format : 40 titres`).

Sur la fiche client BO, le bloc `Sessions` affiche une colonne `Format` entre `Jeu` et `Thématique`. La valeur est calculée depuis le détail session enrichi (`app_session_get_detail(...)`) et `championnats_sessions.flag_controle_numerique`: `Numérique` si actif, sinon `Papier`.

## WWW BO Remises: offres réellement remisées — 2026-05-22

La fiche BO `Commercial > Remise client` distingue maintenant les comptes concernés par le ciblage de la remise et les offres clients qui l'utilisent réellement.

Le bloc `Offres utilisant la remise`, placé sous `Informations`, lit `ecommerce_offres_to_clients.id_remise` et affiche les offres signées avec cette remise: compte payeur, délégation éventuelle, offre, état, prix HT et prix de base quand il est disponible.

## WWW BO Offres clients: listing responsive — 2026-05-22

La liste BO `Commercial > Offres souscrites par les clients` reprend le principe responsive de la liste `Animations > Sessions`.

Sur desktop, le tableau est rendu compact dans un conteneur `.table-responsive` sans classe DataTables responsive, afin d'éviter le masquage automatique de colonnes et de garder un maximum d'informations visibles. Sur mobile, `dt-responsive nowrap` est ajouté uniquement avant l'initialisation DataTables pour permettre le détail ligne par ligne des colonnes masquées.

Les colonnes secondaires `Date début fact.`, `Fact. début période`, `Stripe > idProduct`, `Commentaire`, `Vendeur` et `Remise` sont masquées du tableau. Ces informations restent disponibles sur la fiche détail de l'offre, dans le formulaire et dans les exports selon le paramétrage historique.

Après réduction du nombre de colonnes, la police du tableau est revenue à 13px. Les colonnes `Client`, `Délégation client` et `Offre` acceptent explicitement le retour à la ligne pour conserver la densité sans trop compacter la typographie.

Sur mobile, le tableau garde seulement `#`, `Client`, `Offre` et les actions visibles. Les autres colonnes sont marquées en détail responsive DataTables afin d'être consultables ligne par ligne.

Quand une offre porte un pourcentage de remise mais que `prix_reference_ht` est absent ou non supérieur au prix signé, le BO reconstruit la base HT depuis `prix_ht` et `remise_pourcentage`. La colonne `Prix HT` peut ainsi afficher la base et la chip de remise pour les offres propres remisées par coupon/snapshot, sans dépendre de la logique de remise réseau déléguée.

## WWW BO Clients: stats AJAX et remises conditionnelles — 2026-05-22

Sur la fiche détail d'un compte client, les stats du compte ne sont plus calculées dans le rendu initial du bloc principal. Elles sont rendues par `bo_clients_stats_card_html_get(...)` et chargées après le chargement de page via l'endpoint JSON `client_stats_ajax=1`.

Le bloc stats est injecté sous le bloc `Contacts`, plus stable que le placement dynamique par hauteur.

Le bloc `Remises` de la fiche client est maintenant conditionnel: il s'affiche seulement si une remise active s'applique au compte ou si une remise manuelle supplémentaire est disponible.

## WWW BO Navigation: reporting facturation sous Commercial — 2026-05-22

Le menu principal du BO traite maintenant `syntheses/facturation_pivot` comme une page commerciale pour la surbrillance de navigation: `Home` n'est plus actif sur ces pages, et `Commercial` l'est avec le sous-menu `Reporting facturation`.

## WWW BO Reporting SaaS: essais gratuits dans le tableau visiteurs — 2026-05-22

Le reporting SaaS `Syntheses > Reporting facturation` ajoute une colonne `Essais gratuits` au tableau `Visiteurs / prospects / clients`, entre `Démos nvx inscrits` et `Nvx clients`.

Le compteur s'appuie sur les offres abonnement actives ou terminees, payantes et non offertes, avec `trial_period_days>0`. La date de reference est le debut d'essai, porte par `ecommerce_offres_to_clients.date_debut`; la fin d'essai affichee reste calculee a 15 jours.

Le calcul est historique: les essais termines et les offres facturees apres le debut d'essai restent comptabilises dans leur mois de debut. Les offres encore `En attente` et les offres facturees le jour exact de `date_debut` sont exclues. Un compte est comptabilise une seule fois par mois de debut d'essai. Le clic sur le volume mensuel ouvre la liste des comptes concernes avec lien vers la fiche client BO, nom de l'offre, debut et fin d'essai.

## WWW BO Tracking: actions lisibles dans les logs clients — 2026-05-22

Le listing `Tracking > Logs clients` garde les logs bruts en base, mais transforme l'affichage de la colonne `Action` via le hook de cellule de liste du master BO.

Le rendu est centralise dans `www/web/bo/www/modules/tracking/clients_logs/bo_clients_logs_functions.php`. Les blocs `Logs` externalises des fiches client/contact chargent ce helper avant `module_aside_get_html(...)`, afin d'afficher les memes libelles que la page dediee.

Les actions de navigation `Page : t > m > p` sont presentees avec une zone metier (`Authentification`, `Compte`, `Offres`, `Agenda`, `Jeux`, `Réseau`) et un libelle court (`Accueil`, `Mon offre`, `Souscription`, `Paiement`, `Programmer une session`, `Bibliothèque`). La route brute reste visible en petit gris pour conserver le diagnostic technique.

Les actions metier les plus frequentes (`Connexion`, `Déconnexion`, mot de passe, creation/modification de session, mise a jour de session demo) sont aussi normalisees. Les actions non reconnues restent affichees avec leur libelle brut et la zone fallback `Système`.

## WWW BO Reporting SaaS: expansion nette en modale — 2026-05-26

Dans `Syntheses > Reporting facturation`, les valeurs `Expansion net` du tableau `Abonnements` ouvrent la modale historique, pas le listing facture.

La page `facturation_pivot&p=list` reste dédiée aux listes de factures filtrées (`MRR`, `ARR`, `New MRR`, churn, lignes `A emettre`) et ne porte plus de contexte `view=expansion`.

Le détail expansion repose sur `kpiExpansionClients`, déjà calculé par le reporting SaaS, avec filtrage possible `Mensuels` / `Annuels` via le scope des lignes.

## WWW BO Reporting SaaS: detail ARPA — 2026-05-27

Dans `Syntheses > Reporting facturation`, les valeurs `ARPA HT` du tableau `Abonnements` ouvrent maintenant `facturation_pivot&p=arpa`, presente comme `ARPA HT attendu`.

Cette page affiche la formule `ARPA HT attendu = MRR HT attendu / abonnes actifs retenus`, les trois valeurs du calcul, un filtre de periode et un filtre de scope (`Tous`, `Mensuels`, `Annuels`). Le calcul reste aligne sur le MRR attendu du tableau `Abonnements`, donc il inclut les abonnements actifs a emettre quand ils sont retenus dans le mois courant. Le detail client liste le MRR attendu par scope; les offres annuelles sont ramenees en MRR par douzieme. Le lien `Voir les factures sources` reste disponible comme justification documentaire, sans remplacer l'explication du calcul.

## WWW BO Reporting SaaS: liens visiteurs et page conversion — 2026-05-27

Dans le tableau `Visiteurs / prospects / clients`, les volumes cliquables reutilisent maintenant les listings BO existants:

- `Demos visiteurs` et `Démos nvx inscrits` ouvrent `Championnats > Sessions`, filtre par selection d'IDs de sessions de demo;
- `Nvx inscrits`, `Essais gratuits` et `Nvx clients` ouvrent `Entites > Clients`, filtre par selection d'IDs clients.

Le taux `Tx visiteurs → clients` ouvre `facturation_pivot&p=conversion`, page dediee au mois qui presente les etapes `Visiteurs uniques`, `Demos site`, `Inscrits`, `Demos inscrits`, `Essais gratuits`, `Clients`, avec taux vs etape precedente et taux vs visiteurs. Les volumes de cette page restent cliquables vers les memes listings BO.

Les listings `Sessions` et `Clients` acceptent des filtres techniques d'IDs (`bo_session_ids`, `bo_client_ids`) afin de porter ces selections sans dupliquer les vues metier.

## WWW BO Reporting SaaS: redirections nouvel onglet et totaux cliquables — 2026-05-27

Les redirections du reporting SaaS ouvrent un nouvel onglet afin de conserver la vue `/bo/?t=syntheses&m=facturation_pivot&p=saas` comme point de pilotage.

Les lignes `Total` sont branchees sur les vues adaptees quand elles existent:
- `Ventes et résultat`: total `Factures` et `CA HT` vers le listing facture de la periode;
- `Abonnements`: totaux factures, MRR/ARR dernier mois, New MRR, churn, expansion nette et ARPA;
- `Visiteurs / prospects / clients`: totaux sessions/clients vers les listings BO existants et taux global vers `facturation_pivot&p=conversion&period_total=1`;
- `Répartition par typologie`: totaux factures et CA HT vers le listing facture de la periode.

Les pages `facturation_pivot&p=conversion` et `facturation_pivot&p=expansion` supportent `period_total=1` pour agreger les mois de la periode selectionnee, tout en respectant le cutoff des modes annuel civil/exercice.

## WWW BO Reporting SaaS: conversion par usage — 2026-05-27

La page `facturation_pivot&p=conversion` se lit en deux niveaux:
- `Conversion globale`: visiteurs uniques, demos site, inscrits, clients;
- `Conversion par usage`: lignes `Dynamisation`, `Gamification` et `Total`, basees sur `clients.id_solution_usage`.

Dans `Conversion globale`, la ligne `Clients` reprend le compteur existant des nouveaux clients de la periode afin de rester alignee avec le total du tableau `Conversion par usage`.

Le tableau par usage n'impose pas un tunnel lineaire: un inscrit peut devenir client sans demo ou sans essai. Les colonnes `Avec demo`, `Essais gratuits` et `Clients` comptent donc des clients distincts dedoublonnes sur toute la periode, puis affichent des taux rapportes aux inscrits du meme usage. Les volumes restent cliquables vers les listings BO filtres par IDs.

Le tableau principal `Visiteurs / prospects / clients` reprend cette segmentation par mois via le meme pattern que `Abonnements`: un `+` ouvre deux sous-lignes `Dynamisation` et `Gamification`. Les visiteurs uniques et demos visiteurs restent non segmentes (`—`) car ils ne sont pas rattaches a un usage client; les colonnes `Nvx inscrits`, `Demos nvx inscrits`, `Essais gratuits`, `Nvx clients` et le taux visiteurs -> clients sont detaillees par usage.

Pour garder une ligne mensuelle stable quelle que soit la vue selectionnee, les requetes `Demos nvx inscrits` globales et par usage contraignent le mois d'inscription client au mois de la session demo.

En vue multi-mois, les lignes `Total` reprennent aussi le pattern `+`; leurs sous-lignes sont ouvertes par defaut et en gras:
- `Ventes et resultat`: sous-lignes `Dynamisation (CHR & lieux publics)` et `Gamification (Autres)`;
- `Abonnements`: sous-lignes `Dynamisation (CHR & lieux publics)` et `Gamification (Autres)`, avec les flux cumules sur la periode et les stocks/MRR/ARR/ARPA bases sur le dernier mois comme la ligne Total principale;
- `Visiteurs / prospects / clients`: sous-lignes `Dynamisation (CHR & lieux publics)` et `Gamification (Autres)`.

# Repo `www` - update LP reseau 2026-05-11

La LP publique reseau est maintenant l'entree recommandee pour les partenaires distributeurs: `/lp/reseau/{slug}`. `/lp/operation/{slug}` reste une compatibilite qui reutilise la meme source TdR/reseau.

Le BO `ecommerce/offres_clients` affiche un bloc `Page reseau / operation` sur les offres client de type `Abonnement reseau`. Ces champs personnalisent titre, accroche, description et CTA lorsque l'abonnement reseau actif le plus recent est actif et que la personnalisation LP est active.

Sans abonnement reseau actif, la LP reste accessible pour rejoindre Cotton avec le badge hero `Invitation Cotton` et le CTA `Rejoindre Cotton`, sans promesse d'acces inclus. Les dates ne sont affichees que si debut et fin sont fiables; si un abonnement actif existe sans dates completes, le badge hero devient `Abonnement Cotton inclus`. Le slug public optionnel est sauvegarde mais la route standard V1 reste le slug TdR. `operations_evenements` n'est pas la source produit centrale de cette LP.
## Etat 2026-06-18 - Sessions: liens place gamification

Les pages publiques de sessions conservent le lien vers la page place du compte, y compris pour les comptes gamification.

Comportement technique:
- `fo_sessions_view.php` active le lien place des qu'un `seo_slug` client existe;
- la restriction historique par usage/typologie est retiree;
- les comptes gamification conservent le libelle `Organisateur`;
- le titre des autres sessions devient `Autres sessions à venir chez cet organisateur` pour les comptes gamification;
- les fiches session des comptes gamification n'affichent pas le fil d'Ariane.
- les fiches session des comptes gamification n'affichent pas la note indiquant que la participation n'est pas une reservation d'etablissement.
- sur la page place d'un compte gamification, le breadcrumb retire le lien parent `Établissements` et n'affiche que le nom du compte.

Fichier de reference:
- `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`.
- `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`.
