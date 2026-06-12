# Repo `www` — Tasks

## PATCH 2026-06-11 - BO Remises 2026: affichage public page tarifs
- [x] Audit avant patch:
  - documentation chargee: `START.md`, `SITEMAP.txt`, carte repo `www`, `DOCS_MANIFEST.md`;
  - journal AI Studio raw consulte: aucun conflit recent trouve sur `www/web/bo/www/modules/ecommerce/remises_2026` ni sur la page tarifs;
  - route FO tarifs identifiee: `/fr/tarifs` et `/fr/tarifs/offre/{abonnement|evenement|particulier}`;
  - rendu FO tarifaire identifie via `www/web/fo/modules/ecommerce/tarifs/fr/*` puis widgets globaux ecommerce.
- [x] Correctif livre:
  - ajout idempotent de `ecommerce_remises.flag_affichage_tarifs_site TINYINT(1) NOT NULL DEFAULT 0`;
  - helper BO central `bo_remises_2026_is_tarifs_site_display_eligible(...)`: remise automatique et pipeline `INS` uniquement;
  - le write BO force le flag a `0` si la remise n'est plus eligible;
  - formulaire BO: champ `Afficher sur les tarifs du site` visible uniquement pour une remise eligible, sinon aide explicite;
  - liste BO: badge discret `Tarifs site` si le flag est actif et eligible;
  - fiche BO: etat `Tarifs site` affiche si pertinent;
  - helper FO/global `app_ecommerce_public_tarifs_discounts_get(...)`: revalide flag, actif, pipeline `INS`, dates, typologie et lien offre avant rendu;
  - helper commun `app_ecommerce_tarifs_player_bo_discount_apply(...)`: applique la remise au tableau tarifaire et alimente le meme payload `bo_discount` que l'EC Pro;
  - widget tarifs ABN: le FO reutilise le rendu EC Pro existant (`badge bg-color-8`, prix standard barre `offer-bo-discount-original`, prix remisé), sans libelle public divergent ni donnee BO interne.
- [x] Suite parcours public:
  - confirmation site `/fr/signup/ecommerce/{id_securite_offre_panier}`: recalcul serveur de la remise publique eligible depuis le panier, sans faire confiance a un ID front;
  - affichage de rappel aligne avec le rendu tarifs: badge de remise, prix standard barre, prix remisé et duree si disponible;
  - aucune transmission critique ajoutee au formulaire d'inscription: le seul contexte transporte reste la cle opaque panier existante;
  - l'application reelle au paiement reste confiee au checkout EC Pro, qui revalide la remise apres creation/connexion du compte via les helpers existants.
- [x] Garde-fous:
  - aucune reutilisation des anciens modules legacy `remises` / `remises_offres`;
  - la page FO n'affiche pas de remise manuelle, inactive, hors dates, non `INS`, non liee a l'offre ou typologie incompatible;
  - si le contexte typologie FO est absent, le helper ne retient que les remises sans typologie specifique.
- [x] Verification locale:
  - `php -l` OK sur les 6 fichiers BO Remises 2026 modifies;
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK;
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` OK;
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/sign/fr/fo_sign_portail.php` OK.
- [ ] Verification recette serveur:
  - BO: remise automatique INS + typologie CHR + active + dates OK -> checkbox visible et enregistrable;
  - BO: remise automatique non-INS ou manuelle -> checkbox absente/desactivee et flag force a `0`;
  - BO: remise INS active modifiee en non-INS -> flag remis a `0`;
  - FO: flag actif + dates OK + typologie compatible + offre liee -> badge/prix remises identiques au rendu EC Pro;
  - FO confirmation: panier issu d'une offre remisée -> rappel de remise visible avant inscription, puis paiement possible;
  - FO confirmation: remise expiree ou typologie panier incompatible -> aucun rappel brutal, parcours inscription conserve;
  - FO: flag inactif, dates hors fenetre, typologie incompatible ou offre non liee -> aucun rendu de remise.

## PATCH 2026-06-09 - FO sessions publiques: lien fiche lieu borne aux lieux publics
- [x] Fiche session publique:
  - liens vers `/fr/place/{seo_slug}` conserves seulement si le compte n'est pas `id_solution_usage = 2` et si sa typologie est `1` ou `8`;
  - le bloc haut de page conserve son rendu initial et utilise seulement le meme garde de lien que le bloc lieu detaille;
  - comptes gamification / evenement: lieu/organisateur affiche en texte simple, sans lien vers la fiche compte/lieu;
  - libelle `Organisateur` pour les comptes porteurs gamification / evenement, et `Lieu de l'evenement` pour un lieu nomme propre a l'evenement;
  - session demo appelee directement par URL publique redirigee vers `/fr/agenda` avant rendu;
  - section `Autres sessions a venir dans cet etablissement` maintenue hors sessions demo, y compris pour les comptes `INS`;
  - page lieu `/fr/place/{seo_slug}`: sections `Agenda` et `Sessions passees` filtrees explicitement hors sessions demo, meme si un helper partage conserve une exception historique `INS`;
  - titre de la section adapte en `Autres sessions a venir avec cet organisateur` hors contexte lieu public/dynamisation;
  - aucune modification des routes ni des regles de publication.
- [x] Fiche lieu minimale:
  - audit statique de `/fr/place/{seo_slug}`;
  - etats vides deja presents pour sessions passees et classements sans donnees;
  - nom du lieu et informations disponibles conserves.
- [ ] TODO runtime:
  - verifier si les placeholders AJAX `Chargement des statistiques...` et `Chargement des classements...` peuvent rester visibles en echec reseau;
  - si oui, ajouter un fallback statique leger sans refonte de la fiche lieu.

## PATCH 2026-06-05 - FO agenda: visuels Cotton Quiz V2 via lot_ids
- [x] Diagnostic:
  - `app_jeu_get_detail(...)` accepte deja un troisieme parametre `lot_ids`;
  - sans ce parametre, les sessions Cotton Quiz V2 retombent sur le visuel par defaut;
  - les vues Pro passaient deja `lot_ids`, mais pas plusieurs vues FO.
- [x] Correctif livre:
  - passage de `lot_ids` dans `fo_sessions_list_bloc.php`;
  - passage de `lot_ids` dans `fo_sessions_view.php`;
  - passage de `lot_ids` dans `fo_sessions_seo.php`;
  - passage de `lot_ids` dans `fo_widget_cotton_agenda.php`;
  - passage de `lot_ids` dans `fo_clients_view_shared.php`.
- [x] Garde-fous:
  - la photo du gagnant apres session reste prioritaire quand elle existe;
  - aucune route modifiee;
  - aucune migration SQL;
  - aucune modification des resultats ou du podium.
- [x] Verifications locales:
  - `php -l` OK sur les 5 fichiers modifies.

## PATCH 2026-06-02 - BO finances: synthese bancaire reporting
- [x] Correctif livre:
  - ajout d'une synthese mensuelle bancaire sur `p=finances` avec `Cash in (EUR)`, `Cash out (EUR)` et `Charges ventilees (EUR)`;
  - calcul cash par mois de date bancaire, hors lignes exclues;
  - calcul charges uniquement depuis les transactions de charge au statut `valide`;
  - ajout, sur chaque transaction, d'un champ `Mois charge` et d'une ventilation `1..12 mois`;
  - ventilation lineaire des charges depuis le mois choisi, via `period_start`, `period_end` et `allocation_mode`;
  - extension de la synthese aux mois d'affectation comptable hors periode d'import, dont les mois suivants crees par ventilation;
  - conservation des `cash_in` / `cash_out` deja presents quand une reinjection met a jour un mois issu uniquement d'une ventilation de charge;
  - ajout d'une colonne `Source` dans la synthese mensuelle pour distinguer `Cash + charges` de `Charges ventilees`;
  - refus explicite des CSV bancaires sans transaction exploitable, afin de ne pas creer un faux dernier import `succes` a 0 ligne;
  - normalisation explicite des accents d'en-tetes CSV (`Débit`, `Crédit`, `Libellé`) pour ne plus dependre de la translitteration `iconv` disponible selon l'environnement;
  - ajout d'une date libre `Importer a partir du` sur l'upload CSV, pre-remplie au `2026-05-01` pour ignorer les lignes bancaires anterieures lors des reprises;
  - retrait du controle destructif de purge visible: la borne de reprise est geree au moment de l'import, sans bouton de suppression de donnees;
  - ligne traitee repliee apres validation (`OK`) avec bouton `Modif.` pour correction;
  - retour apres validation sur l'ancre de la ligne traitee, avec surbrillance legere;
  - retrait des colonnes transactions `Contrepartie`, `Sens` et `Categorie API`;
  - lignes d'encaissement affichees sans formulaire de qualification;
  - compteurs `A caracteriser` / `A verifier` limites aux sorties bancaires;
  - durcissement du routage des endpoints bancaires: les actions `bank_*` sont interceptees par `p` et forcent le chemin module `syntheses/facturation_pivot`, pour eviter un fallback `master/bo_master_bank_finance_apply.php`;
  - ajout de l'endpoint super-admin `p=bank_finance_apply` pour injecter explicitement la synthese dans `charges_facturation_pivot.php`;
  - conservation des actions libres et du solde initial deja stockes dans le fichier reporting;
  - migration idempotente des anciennes tables `bank_transactions` pour les champs de periode/ventilation.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/bo.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_finances.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_bank_functions.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/bo.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_finances.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_bank_functions.php` OK.
- [ ] Verification recette serveur:
  - importer un CSV couvrant plusieurs mois puis verifier les totaux mensuels `Cash in` / `Cash out`;
  - valider une charge payee en mai avec mois de reference avril et verifier que `Charges ventilees` remonte sur avril;
  - verifier que la page revient sur la meme ligne apres validation;
  - verifier que les encaissements n'affichent pas de formulaire de qualification;
  - verifier que `Injecter dans le reporting` ne tente pas de charger `master/bo_master_bank_finance_apply.php`;
  - valider une charge ventilee sur plusieurs mois et verifier la repartition lineaire;
  - verifier qu'une charge d'avril ventilee sur 12 mois cree/alimente les mois de mai a mars suivant;
  - refaire un import ulterieur et verifier que les mois crees par ventilation conservent leurs cash existants;
  - tenter un CSV contenant seulement l'en-tete et verifier qu'aucun import vide n'est enregistre;
  - verifier en prod que l'export CIC avec colonnes accentuees est reconnu comme en dev;
  - reimporter un CSV contenant avril/mai avec `Importer a partir du = 2026-05-01` et verifier que les lignes d'avril restent ignorees;
  - cliquer `Injecter dans le reporting`, puis verifier les valeurs dans le tableau manuel et dans `p=saas`;
  - verifier qu'une ligne `a_verifier` ou `auto_caracterise` n'alimente pas les charges tant qu'elle n'est pas validee.

## PATCH 2026-06-02 - BO home: derniers inscrits par compte
- [x] Correctif livre:
  - le bloc home BO `Derniers inscrits` lit maintenant directement `clients`, sans jointure multiplicatrice sur `clients_contacts_to_clients`;
  - le tri reste `clients.date_ajout DESC`, avec tie-breaker `clients.id DESC`;
  - la limite visible est alignee a 10 comptes;
  - l'indicateur `Joueur` reste disponible via un `EXISTS` sur les contacts rattaches, sans creer une ligne par contact.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/resumes/bo_resumes_list.php` OK.
- [ ] Verification recette serveur:
  - ouvrir la home BO;
  - verifier qu'un compte avec plusieurs contacts ne sort qu'une seule fois dans `Derniers inscrits`;
  - verifier que le lien du compte ouvre toujours la fiche client attendue.

## PATCH 2026-06-01 - BO finances: import bancaire CSV V1
- [x] Audit avant patch:
  - documentation Cotton consultee: `START.md`, `SITEMAP.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, carte repo `canon/repos/www/README.md`, `TASKS.md`, `HANDOFF.md`;
  - journal AI Studio consulte avant patch: aucun fichier BO syntheses/facturation_pivot/finances recent liste dans le journal;
  - route principale identifiee dans `www/web/bo/bo.php`;
  - rendu finances identifie dans `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_finances.php`;
  - endpoints AJAX/reporting existants identifies dans `bo.php` pour le pattern sans layout;
  - partage reporting existant identifie via `share_init` / `share_upload`, hors page finances.
- [x] Correctif livre:
  - realignement de la V1 sur import manuel CSV bancaire, pas sur connexion API Open Banking;
  - ajout de `bo_facturation_pivot_bank_functions.php` avec schema V1 bancaire, table `bank_imports`, champs transactions `import_id`, `transaction_hash`, `balance_after`, `raw_row_json`, parser CSV, import et update transaction;
  - ajout des endpoints POST super-admin `p=bank_import`, `p=bank_sync` dev/mock et `p=bank_transaction_update` dans `bo.php`;
  - ajout d'un jeton CSRF local a la page finances pour les actions bancaires;
  - ajout dans `p=finances` d'une section `Import bancaire` super-admin uniquement, optionnelle si schema absent;
  - upload CSV `.csv` taille max 2 Mo, traitement depuis le fichier temporaire PHP puis suppression;
  - parser CIC latin1/UTF-8 avec colonnes `Date`, `Date de valeur`, `Débit`, `Crédit`, `Libellé`, `Solde`, et fallback CSV bancaire generique;
  - hash deterministe anti-doublon par provider, compte, dates, montant, libelle normalise et solde si present;
  - regles ajoutees pour STRIPE, PREL FB CLIENTS, INTERETS/FRAIS, GOOGLE WORKSPACE, GANDI, ALLIANZ, FACT SGT, VIR LOYER, CABINET OZEO, VIR REMUNERATION MANDAT;
  - affichage du dernier import, solde final importe, flux periode, charges estimees, transactions a traiter et tableau d'actions;
  - par defaut, les KPI bancaires prennent la periode du dernier import quand aucun filtre `date_from` / `date_to` n'est force dans l'URL;
  - correction locale de l'ancienne variable `$row_actions` non initialisee dans la sauvegarde des donnees financieres manuelles.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/bo.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_finances.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_bank_functions.php` OK;
  - parser sur `/home/romain/Cotton/00020324502.csv`: 58 lignes, periode 2026-04-01 -> 2026-05-29, credits 9825.84, debits 18489.36, variation -8663.52, solde debut estime 9308.16, solde final 644.64, controle solde OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/bo.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_finances.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_bank_functions.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `/bo/?t=syntheses&m=facturation_pivot&p=finances` en super-admin sans donnees bancaires: la page reste fonctionnelle et affiche le bloc import;
  - importer `00020324502.csv` et verifier creation tables, import history, absence de doublons au reimport, solde final et resume;
  - verifier que les KPI bancaires affichent la periode importee 2026-04-01 -> 2026-05-29 sans filtre URL;
  - verifier que les transactions Stripe, PREL FB CLIENTS, INTERETS/FRAIS, Google Workspace, Gandi, Allianz, FACT SGT, loyer, Cabinet Ozeo et remuneration mandat sont pre-caracterisees;
  - modifier une categorie/statut, valider et exclure une transaction;
  - verifier qu'un utilisateur non super-admin ne voit pas la section bancaire et ne peut pas poster aux endpoints;
  - verifier que le partage reporting public ne contient aucune donnee bancaire.

## PATCH 2026-06-01 - BO reporting SaaS: mobile tableaux et charges
- [x] Correctif livre:
  - ajout d'une marge mobile entre `Ventes, résultat & revenu récurrent` et `Mouvements & variation MRR` quand les deux cartes passent l'une sous l'autre;
  - ajout de `min-width: 0` sur les colonnes/cartes/grilles de reporting pour contenir les tableaux dans la page mobile;
  - compactage des tableaux mini et jeux sous 576px;
  - premiere colonne des mini-tableaux autorisee a revenir a la ligne, les valeurs chiffrees restent non coupees;
  - ligne `Charges` marquee `lower_is_better` pour inverser la couleur de l'ecart.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `/bo/?t=syntheses&m=facturation_pivot&p=saas` sur mobile;
  - verifier l'espacement entre les deux tableaux finance/MRR;
  - verifier que les tableaux `Acquisition & conversion`, `Essais gratuits (CHR & autres lieux publics)`, `Usage jeux & joueurs` et `Formats & contenus joués` ne debordent plus la page;
  - verifier que `Charges` est rouge en surcharge et vert en sous-consommation.

## PATCH 2026-06-01 - LP offre essai: demos du moment
- [x] Correctif livre:
  - la LP `/lp/fr/offre-essai` reprend la selection automatique des demos du moment deja utilisee comme fallback sur les LP reseau;
  - Blind Test, Bingo Musical et Cotton Quiz sont choisis parmi les contenus Cotton disponibles selon fenetre `jour_associe_debut/fin`, puis popularite 365j ou recence;
  - la selection automatique limite les contenus `du moment` a 1 carte sur les 3 quand elle peut completer avec des contenus evergreen;
  - la selection evite de reutiliser une meme famille de theme sur plusieurs jeux, notamment `sport_foot`, `cinema_tv`, `annees_decennies`, `fete_soiree`, `saisonnier`, `musique_generaliste`, `culture_generale`;
  - les cartes demos utilisent en priorite le visuel upload du contenu choisi;
  - les visuels generiques des jeux restent en fallback si aucun visuel de thematique n'existe;
  - les IDs historiques restent en fallback si aucune selection dynamique fiable n'est trouvee;
  - le titre devient `Découvrez nos démos du moment en 2 étapes`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/lp/lp.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `/lp/fr/offre-essai`;
  - verifier le titre de la section demos;
  - verifier qu'en periode Coupe du Monde, les 3 cartes ne sont pas toutes dans la famille sport/foot si des alternatives existent;
  - verifier que les visuels de thematiques apparaissent quand les contenus choisis ont un upload image;
  - verifier que les 3 cartes demo affichent des contenus du moment et que les boutons lancent les bonnes demos.

## PATCH 2026-06-01 - LP carte de visite 1 jeu offert vers home
- [x] Correctif livre:
  - l'URL historique des cartes de visite `utm_term=1-jeu-offert`, `utm_code=GAME1ON`, `utm_medium=card` conserve le log UTM puis redirige en `302` vers la home `www`;
  - le ciblage exige aussi `utm_source=cotton` et `utm_campaign=remise` pour ne pas impacter les autres LP historiques;
  - aucune rewrite nginx et aucune autre campagne LP ne sont modifiees.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/lp/lp.php` OK.
- [ ] Verification recette serveur:
  - ouvrir l'URL QR historique et verifier la redirection vers la home;
  - verifier qu'une autre LP historique (`offre-essai`, `saison-hiver`, reseau) reste affichee.

## PATCH 2026-06-01 - BO reporting SaaS: formats numerique papier
- [x] Correctif livre:
  - tableau `Formats & contenus joués`: ajout de deux colonnes `Numériques` et `Papier`;
  - les colonnes exploitent `championnats_sessions.flag_controle_numerique`, y compris quand les donnees viennent de `reporting_games_sessions_detail` enrichi;
  - les sessions papier ne sont jamais filtrees sur la presence de joueurs;
  - les sessions Bingo papier ne sont pas filtrees sur `jeux_bingo_musical_playlists_clients.phase_courante >= 4`; ce filtre reste applique au Bingo numerique;
  - le cron d'agregats jeux inclut aussi les sessions papier sans joueurs dans `reporting_games_sessions_detail` et `reporting_games_sessions_monthly`;
  - le graphe `Évolution de l’usage réel` affiche `Sessions significatives` avec la même définition que le tableau `Usage jeux & joueurs` quand `reporting_games_sessions_detail` est disponible;
  - le graphe filtre aussi les lignes detail non enrichies (`session_pk=0`), comme le tableau `Usage jeux & joueurs`;
  - le graphe ne complete plus les mois absents avec `reporting_games_sessions_monthly` / `reporting_games_players_monthly` quand le détail enrichi est disponible sur la fenêtre;
  - les tableaux et graphes opérationnels incluent maintenant toute la derniere journee de la periode via une borne exclusive au lendemain sur les champs `DATETIME` (`championnats_sessions.date`, `reporting_games_sessions_detail.session_date`, `clients.date_ajout`);
  - le graphe `Évolution de l’usage réel` derive ses mois depuis `reporting_games_sessions_detail.session_date`, comme les tableaux, afin d'eviter un ecart si `month_key` est stale ou incoherent;
  - le graphe parcourt le detail enrichi ligne par ligne avec la meme logique que le tableau `Usage jeux & joueurs`, au lieu d'utiliser une aggregation SQL distincte;
  - pour les mois inclus dans `Usage jeux & joueurs`, le graphe regenere ses séries finales depuis les compteurs mensuels produits par ce tableau;
  - le rattrapage BO ignore les mois sans session source avant le cache courant et revient sur une mise a jour M-1/M quand l'historique est termine;
  - le rattrapage BO accepte `from` / `to` avec `month` pour reconstruire un mois par tranches sans purger tout le mois a chaque appel;
  - chaque compteur conserve un lien detail vers les sessions concernees;
  - la colonne `Sessions` reste le total et `Joueurs / session` reste base sur ce total.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php` OK.
- [ ] Verification recette serveur:
  - ouvrir le reporting SaaS sur un mois avec usage jeux;
  - verifier que `Sessions = Numériques + Papier` par format et sur la ligne `Total`;
  - verifier qu'une session papier terminee/configuree sans joueur est incluse dans `Papier`;
  - verifier qu'une session Bingo papier configuree, non-demo, dont la partie n'est pas terminee est incluse dans `Papier`;
  - verifier que le graphe `Évolution de l’usage réel` affiche le meme nombre de `Sessions significatives` que le tableau sur les mois couverts par `reporting_games_sessions_detail`;
  - verifier sur une periode multi-mois que le graphe reste strictement base sur `reporting_games_sessions_detail` des que le detail enrichi est disponible;
  - verifier que le mois affiche dans le graphe correspond a `session_date` et non a une valeur `month_key` stale;
  - verifier que la valeur du mois selectionne dans le graphe est identique a `Sessions significatives` du tableau `Usage jeux & joueurs`;
  - verifier que la somme des mois visibles du graphe sur la periode d'usage est identique au total `Sessions significatives` du tableau;
  - verifier qu'une session jouee le dernier jour de la periode apres 00:00 est incluse dans les tableaux et graphes jeux;
  - verifier qu'un compte cree le dernier jour de la periode apres 00:00 est inclus dans les tableaux et graphes acquisition/prospects;
  - lancer une tranche BO, par exemple `bo/cron_reporting_games_aggregates.php?month=2026-04&from=2026-04-01&to=2026-04-07`, et verifier que seules les lignes detail de la tranche sont remplacees;
  - lancer le cron BO quand le curseur historique pointe avant les donnees source et verifier qu'il annonce une mise a jour M-1/M;
  - cliquer `Numériques` et `Papier` pour verifier les listes de sessions filtrees.

## PATCH 2026-06-01 - BO reporting SaaS: carte parc facture alignee stock fin
- [x] Correctif livre:
  - la carte `Parc facturé` de `Synthèse opérationnelle de la période` affiche le meme volume que `Parc actif facturé fin`;
  - la ventilation `Dynam.` / `Gamif.` reprend les compteurs `end_active` du mini-tableau `Mouvements du parc facturé`;
  - `MRR HT` et `ARPA HT` conservent leur source financiere basee sur les lignes MRR du mois.
  - home BO: le premier KPI `Actifs` remplace son compteur `ABN` pipeline par les IDs `Parc actif facturé fin` du reporting SaaS, via le mode data-only, avec fallback SQL ABN actif facture;
  - home BO: le lien du KPI `Actifs` ouvre une liste filtree sur les IDs affiches, soit PAK courants + ABN du stock fin facture;
  - home BO: `Activation (30j)` et `Power Users (30j)` filtrent aussi leur numerateur sur des ABN actifs factures pour rester alignes avec ce denominateur.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/resumes/bo_resumes_list.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php web/bo/www/modules/syntheses/resumes/bo_resumes_list.php` OK.
- [ ] Verification recette serveur:
  - ouvrir juin 2026 sur `?t=syntheses&m=facturation_pivot&p=saas`;
  - verifier que la carte `Parc facturé` affiche le meme total et la meme ventilation que `Parc actif facturé fin`;
  - verifier que `ARPA HT` reste identique a la lecture financiere MRR.
  - verifier la home BO: le `ABN` du KPI `Actifs` doit etre coherent avec le parc ABN actif facture courant;
  - cliquer sur le KPI `Actifs` et verifier que la liste detaillee correspond au total affiche (`ABN` + `PAK`).

## PATCH 2026-05-31 - BO fiche client: remises applicables uniquement
- [x] Correctif livre:
  - section `Remises` de la fiche client limitee aux remises applicables au compte;
  - suppression de l'affichage des remises manuelles disponibles;
  - suppression du formulaire `Ajouter une remise manuelle`;
  - carte masquee quand aucune remise applicable n'existe.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_module_aside.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/entites/clients/bo_module_aside.php` OK.
- [ ] Verification recette serveur:
  - verifier une fiche client avec remise applicable: la section `Remises` apparait sans bloc d'ajout manuel;
  - verifier une fiche client sans remise applicable: la section `Remises` n'apparait pas;
  - verifier qu'une remise deja appliquee reste visible sur l'offre concernee.

## PATCH 2026-05-31 - BO suivi commercial: date d'entree automatique
- [x] Correctif livre:
  - date d'entree lue depuis `bo_activation_commerciale_suivi.date_creation`, deja alimentee par `NOW()` a l'ajout;
  - apercu fiche client: `Ajouté le` affiche la date d'entree;
  - date de rappel/echeance affichee separement quand elle existe.
- [ ] Verification recette serveur:
  - ajouter un suivi commercial et verifier que `Ajouté le` correspond a la date du jour;
  - ajouter un suivi avec date et verifier que `Échéance` reste distincte.

## PATCH 2026-05-31 - BO activation commerciale: suivi commercial simplifie
- [x] Audit avant patch:
  - fiche client: `web/bo/www/modules/entites/clients/bo_clients_view.php`;
  - POST BO: `web/bo/www/modules/entites/clients/bo_clients_script.php`;
  - home BO radar: `web/bo/www/modules/syntheses/resumes/bo_resumes_list.php`;
  - helper suivi: `web/bo/www/modules/entites/clients/bo_clients_activation_commerciale_functions.php`;
  - implementation precedente jugee trop proche mini-CRM: categorie, duree/date masquage, masquage, scope et rappel force visibles.
- [x] Correctif livre:
  - section renomme `Suivi commercial`, repliee par defaut;
  - apercu ferme limite aux 4 derniers suivis avec date, statut, commentaire tronque et auteur si disponible;
  - formulaire ouvert limite a `Statut`, `Date`, `Commentaire`, `Ajouter`;
  - statuts V1 limites a `note_commerciale`, `a_rappeler`, `non_interesse_pour_le_moment`, `ne_pas_relancer`;
  - champs avances conserves en backend mais deduits: `categorie=ALL`, `scope_masquage=global`, masquage/rappel force selon statut;
  - home BO basee sur le dernier suivi client: tout suivi date exclut des categories A/B/C/D/E, tout suivi date apparait dans `Rappels commerciaux` a partir de J-3, ne-pas-relancer sans date exclut.
- [x] Verification locale:
  - `php -l` OK sur `bo_clients_activation_commerciale_functions.php`, `bo_clients_script.php`, `bo_clients_view.php`, `bo_resumes_list.php`;
  - `git -C /home/romain/Cotton/www diff --check -- ...` OK.
- [ ] Verification recette serveur:
  - depuis une fiche client, verifier que `Suivi commercial` est replie par defaut et affiche au plus 4 suivis;
  - ouvrir `Voir / ajouter` et verifier que seuls `Statut`, `Date`, `Commentaire`, `Ajouter` sont visibles;
  - ajouter `Non interesse pour le moment` avec date future a plus de 3 jours et commentaire puis verifier disparition des categories A/B/C/D/E et absence temporaire de `Rappels commerciaux`;
  - ajouter un suivi avec date dans les 3 prochains jours et verifier la remontee dans `Rappels commerciaux`;
  - verifier que ce client n'apparait plus dans A/B/C/D/E meme s'il entre dans leurs criteres;
  - ajouter un suivi date sur un client hors filtres naturels Dynamisation puis verifier la remontee dans `Rappels commerciaux`.
- [ ] Limite documentee:
  - `ne_pas_relancer` sans date exclut sans reactivation automatique; date facultative utilisee comme reevaluation a J-3.
- [ ] TODO V2:
  - réactivation avant expiration sur nouveau signal fort postérieur au suivi: nouvelle offre ABN, essai, première facture, session future, soirée significative, démo jouée.

## PATCH 2026-05-29 - BO reporting SaaS: libelles usage abonnes actifs
- [x] Correctif livre:
  - dans `Usage jeux & joueurs`, `Clients utilisateurs` devient `Abonnés actifs utilisateurs`;
  - `Clients sans usage` devient `Abonnés actifs sans usage`;
  - le libellé du graphe `Évolution de l’usage réel` est harmonisé sur `Abonnés actifs utilisateurs`;
  - aucune logique de calcul ni de lien n'est modifiée.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] Verification recette serveur:
  - verifier les deux lignes renommees dans `Usage jeux & joueurs`.

## PATCH 2026-05-29 - BO reporting SaaS: essais actives dans la carte acquisition
- [x] Correctif livre:
  - la carte `Acquisition & essais` ajoute une ligne `essais activés`;
  - la valeur reprend le compteur Dynamisation existant de `trial_period_summary`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `?t=syntheses&m=facturation_pivot&p=saas`;
  - verifier la ligne `essais activés` dans la carte `Acquisition & essais`.

## PATCH 2026-05-29 - BO reporting SaaS: libelles cartes synthese operationnelle
- [x] Correctif livre:
  - la carte `Parc facturé` affiche MRR HT et ARPA HT sur deux lignes distinctes;
  - la carte `Acquisition & essais` met les comptes créés en valeur principale, avec segmentation Dynam./Gamif. des comptes puis essais dynam. lancés;
  - la carte `Mouvements du parc` affiche `abonnés net` et détaille nouveaux, réactivations et churn avec segmentation Dynam./Gamif.;
  - la carte `Usage réel` sépare sessions, clients utilisateurs, joueurs et `joueurs / session`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `?t=syntheses&m=facturation_pivot&p=saas`;
  - verifier les 4 cartes de `Synthèse opérationnelle de la période` sur une période représentative.

## PATCH 2026-05-29 - BO reporting SaaS: passe UI synthese et labels graphes
- [x] Correctif livre:
  - le bloc `Synthèse opérationnelle de la période` est affiche sous le bloc `Principales actions`;
  - les 4 graphes du bloc `Évolutions mensuelles` affichent a nouveau des valeurs de donnees;
  - les labels de graphe sont rendus plus discrets: petite typographie, halo clair et evitement simple des collisions proches.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `?t=syntheses&m=facturation_pivot&p=saas`;
  - verifier l'ordre `Principales actions` puis `Synthèse opérationnelle`;
  - verifier la lisibilite des valeurs dans les 4 graphes sur `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`.

## PATCH 2026-05-29 - BO reporting SaaS: bascule V2 en page principale
- [x] Correctif livre:
  - la V1 courante est conservee en `old_bo_facturation_pivot_saas.php`;
  - `bo_facturation_pivot_saas.php` contient desormais la V2;
  - le fichier temporaire `bo_facturation_pivot_saas_v2.php` est retire du workspace;
  - les actions de periode et de reinitialisation restent sur `p=saas`;
  - les pages detail ARPA, conversion et expansion continuent a charger `bo_facturation_pivot_saas.php` en mode data-only.
- [x] Verification locale:
  - `php -l` OK sur `bo_facturation_pivot_saas.php`, `old_bo_facturation_pivot_saas.php`, `bo_facturation_pivot_arpa.php`, `bo_facturation_pivot_conversion.php` et `bo_facturation_pivot_expansion.php`;
  - aucune reference PHP restante a `saas_v2`, `p=saas_v2` ou `bo_facturation_pivot_saas_v2`;
  - `git diff --check` OK sur les fichiers de bascule.
- [ ] Verification recette serveur:
  - ouvrir `?t=syntheses&m=facturation_pivot&p=saas`;
  - tester changement de periode, modes d'affichage et reinitialisation;
  - tester les liens vers factures, clients, ARPA, conversion, expansion et churn clients net.

## PATCH 2026-05-29 - BO reporting SaaS V2: liens churn clients net
- [x] Correctif livre:
  - dans `Mouvements du parc facturé`, les valeurs `Churn clients net` utilisent désormais les mêmes redirections listing clients que les autres lignes;
  - les liens ouvrent le listing BO `Entites > Clients` filtré sur les IDs concernés, au lieu d'une modale locale;
  - le même alignement est appliqué à la ligne `Churn clients net` du tableau `Mouvements & variation MRR`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier les clics `Total`, `Dynam.` et `Gamif.` de `Churn clients net` dans `Mouvements du parc facturé`;
  - vérifier que le listing clients s'ouvre dans un nouvel onglet avec les comptes filtrés.

## PATCH 2026-05-29 - BO reporting SaaS V2: segmentation parc et essais Dynamisation
- [x] Correctif livre:
  - la carte `Parc facturé` de la synthèse opérationnelle affiche désormais la ventilation `Dynam.` / `Gamif.` avant MRR et ARPA;
  - les essais gratuits Gamification sont exclus des compteurs essais V2;
  - le mini-tableau `Essais gratuits (CHR & autres lieux publics)` conserve une seule colonne de valeurs;
  - dans `Acquisition & conversion`, les lignes `Essais gratuits dynam.` et `Taux prospect dynam. -> essais gratuits` affichent leur valeur Dynamisation en colonne `Réalisé`;
  - pour ces deux lignes, les colonnes `Budget`, `Écart` et `Gamif.` affichent `n/a`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier la carte `Parc facturé` sur `?t=syntheses&m=facturation_pivot&p=saas_v2`;
  - vérifier que le tableau `Essais gratuits (CHR & autres lieux publics)` n'affiche plus de colonne `Gamif.`;
  - vérifier que les essais Gamification ne sont plus comptés dans les essais V2;
  - vérifier les deux lignes essais Dynamisation dans `Acquisition & conversion`.

## PATCH 2026-05-29 - BO reporting SaaS V2: correctif 504 cron jeux
- [x] Correctif livre:
  - le cron jeux ne lance plus de backfill historique complet depuis le raccourci BO quand seules les colonnes enrichies viennent d'être ajoutées;
  - la mise à jour BO reste limitée à M-1 / M si la table détail existe déjà;
  - si `reporting_games_sessions_detail` est vide, le backfill détail est reconstruit par mois successifs depuis le BO;
  - si la table détail est partielle, le cron cherche le plus ancien mois source absent et le reconstruit par séquence;
  - la recherche du mois source absent reprend les mêmes filtres que l'insertion détail pour éviter les mois anciens sans session éligible;
  - les lignes détail invalides `0000-00` sont nettoyées au démarrage du cron;
  - les sous-requêtes joueurs du backfill détail sont bornées à la fenêtre en cours;
  - la V2 vérifie qu'il existe des lignes enrichies `session_pk > 0` pour la période avant d'utiliser le chemin rapide;
  - si les lignes enrichies sont absentes à cause d'un cron interrompu, la V2 retombe sur le calcul historique et n'affiche plus des zéros artificiels.
  - les `Sessions significatives` de la V2 sont recalculées depuis les mêmes lignes que `Sessions jouées`, pour éviter un zéro quand le détail enrichi est partiel.
  - dans `Usage jeux & joueurs`, la ligne redondante `Sessions jouées` est retirée et le ratio devient `Joueurs / session`.
  - dans `Évolutions mensuelles`, les titres des 4 graphiques sont centrés et n'utilisent plus le bleu du thème; le titre du bloc reste bleu.
  - le lancement manuel BO `web/bo/cron_reporting_games_aggregates.php` affiche le rapport navigateur sans envoyer d'email;
  - le lancement BO passe en mode court limité à `reporting_games_sessions_detail` pour éviter les 504;
  - le mode BO ne scanne plus globalement les mois manquants: il part du plus ancien mois présent, traite le mois précédent, puis avance via `reporting_games_backfill_state`;
  - un mois précis peut être forcé avec `?month=YYYY-MM`;
  - le cron daily `cron/daily/cron_reporting_games_aggregates.php` conserve l'envoi email.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- ...` OK.
- [ ] Verification recette serveur:
  - déployer le fichier inclus et la page V2;
  - recharger la V2 avant cron pour vérifier le fallback sur les anciennes données;
  - relancer le cron jeux BO plusieurs fois si `reporting_games_sessions_detail` est vide ou partielle, jusqu'à disparition des messages de rattrapage;
  - contrôler `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`.

## PATCH 2026-05-29 - BO reporting SaaS V2: optimisation usage jeux
- [x] Correctif livre:
  - enrichissement de `reporting_games_sessions_detail` via le cron jeux;
  - ajout des métadonnées nécessaires à la V2: session interne, produit, lots, type, contenu Bingo;
  - lecture V2 des détails enrichis pour éviter les gros `JOIN` joueurs au chargement;
  - fallback conservé si le cron enrichi n'a pas encore tourné.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- ...` OK.
- [ ] Verification recette serveur:
  - lancer `bo/cron_reporting_games_aggregates.php` pour créer/remplir les colonnes enrichies;
  - vérifier la V2 sur `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - comparer les chiffres `Usage jeux & joueurs` / `Formats & contenus joués` avant/après;
  - mesurer le temps de chargement serveur avant/après.

## PATCH 2026-05-29 - BO reporting SaaS V2: regroupement des graphiques
- [x] Correctif livre:
  - regroupement des 4 graphiques sous `Principales actions`;
  - ajout du bloc `Évolutions mensuelles` avec sous-titre selon la vue;
  - affichage des graphiques en grille 2 colonnes x 2 lignes;
  - titre `Principales actions` intégré au bloc blanc.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - contrôle local: 4 canvases conservés.
- [ ] Verification recette serveur:
  - tester les vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - vérifier les sous-titres et le responsive;
  - vérifier l'export / image partagée.

## PATCH 2026-05-29 - BO reporting SaaS V2: lisibilité acquisition et parc
- [x] Correctif livre:
  - graphe acquisition rendu en mini-funnel temporel: essais et nouveaux abonnés en barres principales, comptes créés en courbe secondaire discrète;
  - graphe parc rendu en lecture entrées / sorties / net: `Entrées parc`, `Sorties parc`, `Variation nette`;
  - aucune modification des tableaux ni des agrégats PHP sources.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - tester les vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - vérifier que les essais/nouveaux abonnés ne sont plus écrasés par les comptes créés;
  - vérifier que le graphe parc distingue clairement entrées, sorties et net;
  - vérifier l'export / image partagée.

## PATCH 2026-05-29 - BO reporting SaaS V2: lisibilité graphiques
- [x] Correctif livre:
  - hauteur utile des 4 graphiques augmentée et uniformisée;
  - légendes rendues compactes;
  - axe X forcé horizontal;
  - labels de valeurs automatiques désactivés sur les 4 graphiques;
  - graphe mouvements simplifié en barres groupées positives/négatives;
  - graphe usage réel limité à sessions jouées et clients utilisateurs.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - contrôle du nombre de `<canvas>` rendus: 4.
- [ ] Verification recette serveur:
  - tester les vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - vérifier la lisibilité des 4 graphiques et l'export / image partagée;
  - confirmer que les valeurs restent inchangées.

## PATCH 2026-05-29 - BO reporting SaaS V2: 4 graphiques d'évolution
- [x] Correctif livre:
  - ajout de 4 graphiques pleine largeur dans `p=saas_v2`;
  - placement sous les lignes finance/MRR, acquisition/essais, parc/maturité et jeux/joueurs;
  - réutilisation des séries mensuelles, helpers de période et initialisation Chart.js existants;
  - aucun graphique ajouté dans `Synthèse opérationnelle`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - contrôle du nombre de `<canvas>` rendus: 4.
- [ ] Verification recette serveur:
  - tester les vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - vérifier que la vue `Mois` affiche au moins 3 mois;
  - vérifier la cohérence des séries avec les tableaux agrégés;
  - vérifier le responsive et le partage/export visuel.

## PATCH 2026-05-29 - BO reporting SaaS V2: note synthèse opérationnelle
- [x] Correctif livre:
  - ajout d'une note sous `Synthèse opérationnelle` pour expliciter `Dynam.` et `Gamif.`;
  - aucun calcul ni tableau modifié.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier l'affichage de la note sous le titre de la synthèse opérationnelle.

## PATCH 2026-05-29 - BO reporting SaaS V2: filtres période
- [x] Correctif livre:
  - le formulaire des vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile` conserve `p=saas_v2`;
  - le lien `Réinitialiser` reste sur la V2;
  - `Période de référence :` est affiché juste au-dessus de la ligne `Ventes, résultat & revenu récurrent` / `Mouvements & variation MRR`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - changer chaque vue depuis la V2 et vérifier que l'URL conserve `p=saas_v2`;
  - vérifier que la période s'affiche juste au-dessus de la première ligne de tableaux.

## PATCH 2026-05-29 - BO reporting SaaS V2: ordre synthèse et mouvements du parc
- [x] Correctif livre:
  - période de référence conservée au-dessus de `Synthèse opérationnelle`;
  - `Synthèse opérationnelle` déplacée au-dessus de `Principales actions`;
  - carte `Mouvements MRR` remplacée par `Mouvements du parc`;
  - carte alimentée par les mêmes agrégats que le tableau `Mouvements du parc facturé`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - tester les vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - vérifier que les valeurs `Mouvements du parc` correspondent exactement au tableau `Mouvements du parc facturé`.

## PATCH 2026-05-29 - BO reporting SaaS V2: carte acquisition simplifiée
- [x] Correctif livre:
  - carte `Acquisition & essais` sans taux;
  - affichage des nouveaux abonnés, de la répartition Dynam./Gamif., des comptes créés et des essais lancés.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier l'affichage attendu: `15 Nouveaux abonnés`, `9 Dynam. / 6 Gamif.`, `109 comptes créés`, `15 essais gamif. lancés`.

## PATCH 2026-05-29 - BO reporting SaaS V2: carte acquisition
- [x] Correctif livre:
  - valeur principale de `Acquisition & essais` remplacée par `Nouveaux abonnés`;
  - sous-indicateurs: comptes créés total, essais lancés Dynamisation, taux essais Dynamisation;
  - taux essais aligné sur `Taux prospect dynam. -> essais gratuits`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier l'exemple attendu: `15 Nouveaux abonnés` puis `109 comptes créés · 15 essais lancés · 52 % taux essais`.

## PATCH 2026-05-29 - BO reporting SaaS V2: cohérence synthèse opérationnelle
- [x] Correctif livre:
  - carte `Acquisition & essais` alignée sur le total `Comptes créés / prospects`;
  - taux essais calculé sur `essais lancés / comptes créés total`;
  - carte `Mouvements MRR` enrichie avec `MRR réactivations` pour réconcilier le net.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier que l'exemple 3 derniers mois mai 2026 affiche `109 comptes créés`, `16 essais lancés · 15 % taux essais`;
  - vérifier que `Mouvements MRR` affiche les réactivations et que `1 037 + 533 - 1 578 - 114 = -122`.

## PATCH 2026-05-29 - BO reporting SaaS V2: synthèse opérationnelle
- [x] Correctif livre:
  - bloc `Synthèse opérationnelle` ajouté au-dessus des tableaux;
  - 4 cartes KPI compactes: parc facturé, acquisition & essais, mouvements MRR, usage réel;
  - cartes alimentées depuis les agrégats existants des tableaux V2;
  - aucun graphique, score, badge métier ou texte de lecture ajouté.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - tester les vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - vérifier que les cartes correspondent aux tableaux existants;
  - vérifier le responsive 4/2/1 colonnes.

## PATCH 2026-05-29 - BO reporting SaaS V2: réalisé essais masqué
- [x] Correctif livre:
  - colonne `Réalisé` affichée en `n/a` sur les deux lignes essais Dynamisation;
  - écart conservé sur le réalisé Dynamisation;
  - colonne `Dynam.` conservée comme valeur de référence.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier que `Réalisé` affiche `-` pour les deux lignes essais Dynamisation.

## PATCH 2026-05-29 - BO reporting SaaS V2: affichage essais Dynamisation
- [x] Correctif livre:
  - lignes renommées `Essais gratuits dynam.` et `Taux prospect dynam. -> essais gratuits`;
  - colonne `Gamif.` affichée en `n/a` sur ces deux lignes;
  - calculs réalisé/écart maintenus sur Dynamisation.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier que la colonne `Gamif.` affiche `n/a` pour les deux lignes d'essais.

## PATCH 2026-05-29 - BO reporting SaaS V2: pondération prospects 35/65
- [x] Correctif livre:
  - répartition cible du budget prospects actée à 35% Dynamisation / 65% Gamification;
  - budget essais gratuits calculé sur la part Dynamisation: `budget prospects * 35% * 25%`;
  - budget taux prospect -> essais gratuits maintenu à 25%.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier que le budget essais vaut environ 8,75% du budget prospects global;
  - vérifier les vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`.

## PATCH 2026-05-29 - BO reporting SaaS V2: correction budget essais
- [x] Correctif livre:
  - budget `Essais gratuits` recalé sur `budget prospects * 25%`;
  - réalisé/écart des lignes essais gratuits et taux prospect -> essais gratuits comparés au réalisé Dynamisation;
  - Gamification conservée en colonne informative, hors périmètre objectif.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier que le budget essais n'est plus calculé depuis le réalisé Dynamisation;
  - vérifier que l'écart des essais gratuits se lit bien sur le périmètre Dynamisation cible.

## PATCH 2026-05-29 - BO reporting SaaS V2: budget essais gratuits Dynamisation
- [x] Correctif livre:
  - budget `Essais gratuits` alimenté par un objectif ciblé de 25% des comptes/prospects Dynamisation créés;
  - budget `Taux prospect -> essais gratuits` fixé à 25%;
  - pas de budget Gamification dédié pour les essais.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier le budget affiché dans `Acquisition & conversion` sur les vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - confirmer que le budget essais correspond à 25% des comptes Dynamisation créés sur la période.

## PATCH 2026-05-29 - BO reporting SaaS V2: retrait contenus formats
- [x] Correctif livre:
  - retrait du second tableau `Contenus joués` / `Top contenu` dans `Formats & contenus joués`;
  - conservation du tableau principal avec liens sessions et clients.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier que la card `Formats & contenus joués` n'affiche plus qu'un tableau.

## PATCH 2026-05-29 - BO reporting SaaS V2: liens listings jeux
- [x] Correctif livre:
  - collecte des IDs sessions derrière les agrégats `Usage jeux & joueurs` et `Formats & contenus joués`;
  - liens sessions vers `championnats/sessions` filtré par `bo_session_ids`;
  - liens clients vers `entites/clients` filtré par `bo_client_ids`;
  - les formats ouvrent les clients distincts du format depuis leur libellé.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - tester les liens sessions et clients sur les vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - vérifier que les liens absents restent en texte simple quand aucun ID fiable n'est disponible.

## PATCH 2026-05-29 - BO reporting SaaS V2: variation parc et contenus formats
- [x] Correctif livre:
  - `Mouvements du parc facturé` ajoute `Variation nette du parc actif`;
  - la variation est calculée `Parc actif facturé fin - Parc actif facturé début`, avec signe;
  - `Formats & contenus joués` retire les colonnes `Clients`, `Contenus joués`, `Top contenu` du tableau principal;
  - les contenus joués et top contenus restent visibles sous le tableau principal, dans la même card.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier le rendu desktop/mobile du bloc `Formats & contenus joués`;
  - confirmer que la variation nette du parc actif correspond bien au stock fin moins stock début sur les vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`.

## PATCH 2026-05-29 - BO reporting SaaS V2: churn signe et taux essais
- [x] Correctif livre:
  - `Churn valeur` s'affiche en négatif dans `Mouvements & variation MRR`, sans modifier la formule interne de variation nette;
  - `Essais gratuits` ajoute `Taux essais terminés -> essais convertis`;
  - le taux est calculé par segment depuis `essais convertis facturés / essais terminés`;
  - les mini-tableaux avec budget affichent `Réalisé` au lieu de `Total`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier les vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - confirmer que `Churn valeur` apparaît signé négativement et que le nouveau taux essais ne produit pas de warning quand le dénominateur est nul.

## PATCH 2026-05-29 - BO reporting SaaS V2: lignes fortes et MRR HT
- [x] Correctif livre:
  - `Mouvements & variation MRR` ajoute `MRR HT` en première ligne;
  - cette ligne reprend les agrégats déjà utilisés par `Ventes, résultat & revenu récurrent`;
  - le renderer commun des mini-tableaux supporte les lignes `strong`;
  - les lignes structurantes demandées sont affichées en gras dans finance, acquisition, essais, mouvements parc, maturité et usage jeux.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - vérifier le rendu en vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - confirmer que `MRR HT` correspond visuellement au tableau finance et que les lignes fortes restent lisibles en responsive.

## PATCH 2026-05-29 - BO reporting SaaS V2: budget acquisition
- [x] Correctif livre:
  - ajout des colonnes `Budget` et `Écart` dans `Acquisition & conversion`;
  - le renderer commun des mini-tableaux active ces colonnes seulement quand les lignes fournissent un budget;
  - budgets de période agrégés depuis `budget_facturation_pivot.php`: visites, inscrits/prospects, nouveaux abonnés facturés;
  - taux budgétés dérivés des volumes de période pour `Taux visiteur -> prospect` et `Taux prospect -> abonné`;
  - essais gratuits laissés sans budget (`—`) faute d'objectif explicite distinct.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - verifier `Acquisition & conversion` en vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - confirmer que les colonnes restent lisibles en desktop et que le tableau reste responsive sur écran étroit.

## PATCH 2026-05-29 - BO reporting SaaS V2: tableaux jeux et joueurs
- [x] Correctif livre:
  - ajout d'une ligne sous les tableaux V2 existants;
  - tableau `Usage jeux & joueurs` avec `Total`, `Dynam.` et `Gamif.`;
  - tableau `Formats & contenus joués` avec Blind Test, Cotton Quiz, Bingo Musical et Total;
  - sessions jouées lues depuis `championnats_sessions`, hors démo identifiable et sessions non terminées;
  - chaque session est bornée au parc facturé du mois de jeu, avec abonnés annuels portés par le calcul MRR actif;
  - sessions significatives lues depuis `reporting_games_sessions_detail` quand disponible et filtrées sur le parc facturé du mois de jeu, sinon repli sur les sessions jouées avec joueurs;
  - joueurs cumulés calculés comme somme des participations équipes, Bingo, Blind Test et Cotton Quiz;
  - clients sans usage calculés depuis le parc facturé retenu moins les clients avec session jouée identifiable;
  - contenus joués et top contenu affichés depuis les référentiels fiables BO: playlists pour Blind/Bingo, séries `questions_lots` / `questions_lots_temp` pour Cotton Quiz;
  - contenu affiché en `n.d.` / `—` quand la table de libellé est indisponible;
  - total clients formats dédupliqué tous formats;
  - note déplacée sous `Usage jeux & joueurs`: `Sessions démo exclues ; Session significative = complète, terminée et avec des joueurs si numérique`;
  - aucune modification des calculs commerciaux existants, aucun graphe ni bouton détail ajouté.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/documentation diff --check` OK;
  - `npm run docs:sitemap` OK.
- [ ] Verification recette serveur:
  - ouvrir `?t=syntheses&m=facturation_pivot&p=saas_v2`;
  - verifier les vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - verifier que les deux tableaux restent côte à côte en desktop et passent en une colonne sur écran étroit;
  - comparer les volumes entre périodes et contrôler l'absence de warning de division par zéro.

## PATCH 2026-05-29 - BO reporting SaaS: V2 simplifiée séparée
- [x] Correctif livre:
  - `bo_facturation_pivot_saas.php` conservé;
  - ajout de `bo_facturation_pivot_saas_v2.php`;
  - header et `Principales actions` conservés;
  - rendu simplifié en trois lignes de deux tableaux;
  - ajout de `MRR réactivations` dans `Mouvements & variation MRR`;
  - recalcul de `Expansion net` hors MRR de réactivation, sans modifier la variation nette;
  - `Principales actions` en pleine largeur;
  - alignement de hauteur des deux tableaux de première ligne;
  - espacement harmonisé entre les lignes de tableaux;
  - retrait des notes sous `Acquisition & conversion`, `Mouvements du parc facturé` et `Maturité du parc facturé`;
  - style homogénéisé entre les six tableaux;
  - titre intermédiaire `Acquisition & cycle d'abonnement` retiré;
  - graphes et section jeux retirés du rendu V2.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas_v2.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `?t=syntheses&m=facturation_pivot&p=saas_v2`;
  - vérifier le rendu desktop/PDF des trois lignes de tableaux;
  - confirmer que le routeur BO charge bien la page par convention `p=saas_v2`.

## PATCH 2026-05-29 - BO reporting SaaS: graphes acquisition et mouvements
- [x] Correctif livre:
  - graphe 3 remplacé par `Tunnel acquisition & conversion`;
  - séries tunnel: visiteurs uniques, comptes créés, essais gratuits lancés, nouveaux abonnés facturés;
  - les séries tunnel sont alimentées sur la fenêtre graphique M-2/M-1/M en vue `Mois`;
  - graphe 4 remplacé par `Entrées / sorties du parc facturé`;
  - séries parc: nouveaux abonnés, réactivations, churn clients net, variation nette;
  - les séries parc réutilisent la même réconciliation stock/flux client que le mini-tableau `Mouvements du parc facturé`;
  - les valeurs non nulles sont affichées discrètement sur les graphes.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] Verification recette serveur:
  - contrôler le rendu desktop et PDF des deux nouveaux graphes;
  - comparer les valeurs mensuelles aux 4 mini-tableaux et au tableau `Parc abonnés, mouvements & variation MRR`.

## PATCH 2026-05-28 - BO reporting SaaS: ajustement graphes cockpit
- [x] Correctif livre:
  - section `Acquisition & cycle d'abonnement` revenue aux 4 mini-tableaux sur 2 lignes;
  - graphe 1 passe sur MRR HT + objectif MRR HT + parc actif facturé;
  - graphe 3 masqué pour retirer le doublon du parc actif;
  - graphe 4 remplacé par l'ancienneté du parc facturé;
  - graphes 5 et 6 acquisition/conversion masqués.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] Verification recette serveur:
  - contrôler la position des graphes en desktop et PDF;
  - verifier que les 4 mini-tableaux restent sur 2 colonnes desktop.

## PATCH 2026-05-28 - BO reporting SaaS: synthese business cockpit
- [x] Correctif livre:
  - retrait du bloc haut `Objectifs (budget)` de la lecture principale;
  - ajout de `Synthèse business` avec widgets `Performance financière`, `Tunnel acquisition` et `Parc facturé`;
  - suppression de la duplication basse des widgets tunnel/parc;
  - repositionnement des graphiques sous les tableaux financiers, parc, puis acquisition/cycle;
  - réactivation des tableaux détaillés acquisition/cycle comme preuves des widgets.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/documentation diff --check` OK;
  - `npm run docs:sitemap` OK.
- [ ] Verification recette serveur:
  - verifier les vues `Mois`, `3 derniers mois`, `Année fiscale`, `Année civile`;
  - verifier l'export PDF sur une vue autre que `Mois`;
  - comparer les widgets `Synthèse business` aux lignes de total des tableaux détaillés.

## PATCH 2026-05-28 - BO reporting SaaS: delta stock flux mouvements
- [x] Correctif livre:
  - retour de la ligne `Delta stock / flux` dans le mini-tableau `Mouvements du parc facturé`;
  - calcul affiché aligné sur l'équation du tableau: `stock fin - stock début - nouveaux - réactivations + churn`;
  - valeur signée et lien vers les comptes concernés, par `Total`, `Dynam.` et `Gamif.`;
  - aucun réaffichage des anciens tableaux redondants.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/documentation diff --check` OK;
  - `npm run docs:sitemap` OK.
- [ ] Verification recette serveur:
  - vérifier la période signalée: le delta doit expliquer l'écart entre `55 + 74 + 34 - 70` et `78`;
  - cliquer le delta pour contrôler les comptes concernés.

## PATCH 2026-05-28 - BO reporting SaaS: V3 UI acquisition et cycle
- [x] Correctif livre:
  - masquage standard des anciens tableaux `Visiteurs / prospects / clients` et `Rétention & cycle d'abonnement` via flag interne désactivé;
  - conservation visible des 4 mini-tableaux en grille compacte 2 colonnes desktop / 1 colonne mobile;
  - harmonisation visuelle des mini-tableaux: en-tête discret, bordures, espacements, notes en pied et valeurs numériques à droite;
  - remplacement du bar chart `Tunnel acquisition & conversion` par un funnel HTML compact avec volumes et taux de passage;
  - remplacement du bar chart `Mouvements du parc facturé` par une lecture HTML stock/flux sans valeur financière;
  - conservation de la segmentation usage `Total` / `Dynam.` / `Gamif.` dans les mini-tableaux.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/documentation diff --check` OK;
  - `npm run docs:sitemap` OK.
- [ ] Verification recette serveur:
  - ouvrir `/bo/?t=syntheses&m=facturation_pivot&p=saas` en vue mensuelle et multi-mois;
  - vérifier que les deux anciens tableaux ne s'affichent plus;
  - vérifier desktop/mobile et partage public.

## PATCH 2026-05-28 - BO reporting SaaS: essais actives
- [x] Correctif livre:
  - le mini-tableau `Essais gratuits` remplace `Sans session signif.` par `Essais activés`;
  - la ligne `Essais activés` est remontée immédiatement sous `Essais lancés`;
  - la grille des 4 mini-tableaux est déplacée entre la ligne des graphiques 1/2 et celle des graphiques 3/4;
  - la note du tableau devient `Essai activé = au moins 1 session significative pendant l'essai.`;
  - la ligne reste cliquable vers les clients concernés, par `Total`, `Dynam.` et `Gamif.`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/documentation diff --check` OK;
  - `npm run docs:sitemap` OK.
- [ ] Verification recette serveur:
  - vérifier que `Essais activés` apparait sous `Essais lancés`;
  - vérifier que les 4 mini-tableaux sont placés entre les deux lignes de graphiques;
  - vérifier que les clics ouvrent les clients responsables.

## PATCH 2026-05-28 - BO reporting SaaS: maturite alignee sur parc actif
- [x] Correctif livre:
  - retrait de la ligne temporaire `Autres entrées` du mini-tableau `Mouvements du parc facturé`;
  - les tranches `Actifs < 1 mois`, `1-3 mois`, `3-6 mois`, `> 6 mois` sont maintenant calculées sur les mêmes clients dédupliqués que `Parc actif facturé fin`;
  - si un client a plusieurs offres actives, il est classé une seule fois dans la tranche de sa plus ancienne facture ABN active.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/documentation diff --check` OK.
- [ ] Verification recette serveur:
  - vérifier que la somme des tranches de maturité égale `Parc actif facturé fin` par colonne.

## PATCH 2026-05-28 - BO reporting SaaS: reactivations et offres en attente
- [x] Correctif livre:
  - une offre `En attente` avant le début de période ne bloque plus la détection de réactivation;
  - le blocage de réactivation se limite aux offres réellement actives (`id_etat=3`) ou aux offres couvrant encore le début de période via `date_fin`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/documentation diff --check` OK.
- [ ] Verification recette serveur:
  - vérifier Mai 2026: `TY BREIZH` doit passer de `Autres entrées` à `Réactivations`.

## PATCH 2026-05-28 - BO reporting SaaS: exclusion offres annuelles terminees du parc actif
- [x] Correctif livre:
  - les factures annuelles historiques ne peuvent plus garder une offre terminée dans le parc actif du mois si `date_fin` est antérieure à la fin du mois affiché;
  - corrige le cas d'un client avec facture annuelle passée mais offre ABN terminée, qui pouvait rester dans `Abonnés actifs` / `Parc actif facturé fin`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/documentation diff --check` OK.
- [ ] Verification recette serveur:
  - vérifier Mai 2026 et le client `#927`: il ne doit plus figurer dans le parc actif fin si aucune offre ABN facturée n'est active à fin mai.

## PATCH 2026-05-28 - BO reporting SaaS: acquisition inscrits et essais gratuits
- [x] Correctif livre:
  - dans `Acquisition & conversion`, `Comptes créés / prospects` devient `Comptes créés / inscrits`;
  - `Taux visiteur -> prospect` devient `Taux visiteur -> inscrits`;
  - ajout des lignes `Essais gratuits` et `Taux inscrits -> essais gratuits`, basées sur les essais lancés sur la période.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/documentation diff --check` OK.

## PATCH 2026-05-28 - BO reporting SaaS: alignement stock mini-tableau mouvements
- [x] Correctif livre:
  - `Mouvements du parc facturé` aligne `Parc actif facturé début` et `Parc actif facturé fin` sur les mêmes lignes MRR normalisées que la synthèse `Parc abonnés, mouvements & variation MRR`;
  - les sources utilisées sont `mrr`, `mrr_dynamisation` et `mrr_gamification` depuis `kpi_factures_by_month`, avec fallback vers l'ancien stock seulement si ces lignes ne sont pas disponibles.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] Verification recette serveur:
  - vérifier Mai 2026: `Parc actif facturé fin` doit reprendre le même périmètre que `Abonnés actifs`;
  - vérifier que la ventilation reste `Dynamisation` / `Gamification`.

## PATCH 2026-05-28 - BO reporting SaaS: mini-tableaux V2 definitions et segmentation usage
- [x] Correctif livre:
  - `Acquisition & conversion` lit maintenant visiteurs -> prospects -> nouveaux abonnés facturés, avec taux visiteur -> prospect et taux prospect -> abonné facturé;
	  - `Nouveaux abonnés facturés` réutilise les agrégats abonnements existants (`new_clients`) au lieu d'une liste construite plus bas dans la page;
	  - `Essais gratuits` distingue essais lancés, actifs fin période, terminés, convertis facturés, expirés sans facture et essais activés quand la source sessions est disponible;
	  - correction de périmètre: `Essais terminés`, `Essais convertis facturés` et `Expirés sans facture` sont calculés depuis la même liste dédupliquée que `Essais lancés`, puis ventilés selon présence de facture ou essai expiré;
	  - les valeurs des 4 mini-tableaux sont rendues cliquables quand une cible fiable existe: détail conversion pour les visiteurs/taux globaux, listings clients filtrés pour prospects, essais, mouvements de parc et maturité;
  - `Mouvements du parc facturé` est uniquement volumétrique: stock début, nouveaux facturés, réactivations, churn abonnés, stock fin;
  - `Maturité du parc facturé` privilégie les médianes et ajoute `Durée de vie médiane ABN terminés`, calculée depuis la première facture ABN;
  - les colonnes compactes restent alignées sur la segmentation usage `Total` / `Dynam.` / `Gamif.`, sans retour à une typologie `CHR` / `Autres`;
  - le graph tunnel affiche les étapes facturées principales et le graph mouvements reste volumétrique.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `/bo/?t=syntheses&m=facturation_pivot&p=saas`;
  - vérifier une vue mensuelle et une vue multi-mois;
  - vérifier que `Nouveaux abonnés facturés` suit la ligne `Nouveaux` du tableau abonnements;
  - vérifier que les essais actifs non facturés restent exclus du parc facturé et des nouveaux abonnés facturés;
  - vérifier responsive desktop/mobile.

## PATCH 2026-05-28 - BO reporting SaaS: mini-tableaux tunnel, essais et parc facture
- [x] Correctif livre:
  - ajout sous les graphs `Tunnel acquisition & conversion` et `Mouvements du parc facturé` de 4 mini-tableaux compacts en grille 2 colonnes desktop / 1 colonne mobile;
  - mini-tableaux ajoutes: `Acquisition & conversion`, `Essais gratuits`, `Mouvements du parc facturé`, `Maturité & durée de vie`;
  - conservation des tableaux existants `Visiteurs / prospects / clients` et `Rétention & cycle d'abonnement`;
  - adaptation du graph conversion en tunnel Total période: visiteurs uniques, comptes créés/prospects, essais gratuits lancés, nouveaux abonnés facturés;
  - adaptation du graph stabilité en mouvements du parc facturé: stock début, nouveaux facturés, réactivations, churn, stock fin;
  - ajout d'une marge haute automatique sur les nouveaux graphs via `chartAxisBounds(..., padding: 0.15)`;
  - les essais actifs fin période sont calculés comme stock actif non facturé, séparés des essais lancés sur la période;
  - les métriques non fiables dans cette vue compacte restent en `n/a` (`Taux essai -> facturé`, durée de vie des churnés).
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `/bo/?t=syntheses&m=facturation_pivot&p=saas`;
  - verifier une vue mensuelle et une vue multi-mois;
  - verifier que les anciens tableaux restent visibles sous les mini-tableaux;
  - verifier que les essais actifs fin période ne sont pas inclus dans les nouveaux abonnés facturés ni dans le parc actif facturé;
  - verifier la grille 2 colonnes desktop et 1 colonne mobile.

## PATCH 2026-05-27 - BO reporting SaaS: retention et cycle d'abonnement
- [x] Correctif livre:
  - remplacement du tableau `Cycle d'abonnement CHR & revenu espere` par `Rétention & cycle d'abonnement` sous `Visiteurs / prospects / clients`;
  - le tableau affiche maintenant l'évolution sur la période choisie: une ligne par mois, des sous-lignes `Dynamisation` / `Gamification`, puis une ligne `Total`;
  - comparaison `Dynamisation` / `Gamification` sur `Churn moyen`, durée de vie estimée, ancienneté abonnements actifs, maturité du parc actif et taux de réactivation;
  - `Churn moyen` base sur les agregats `En pause` deja calcules par le tableau `Abonnements`, avec duree de vie estimee derivee du churn mensuel moyen observe;
  - anciennete des abonnements actifs corrigee sur les offres actives facturees du dernier mois de periode, par usage, depuis la premiere facture positive liee a l'offre active;
  - remplacement de la retention M+1/M+3/M+6/M+9 par `Actifs >= 3 mois` et `Actifs >= 6 mois`, calcules sur le meme perimetre que l'anciennete moyenne;
  - le tableau `Repartition par typologie` est masque par defaut via flag local reversible, sans supprimer la logique ni les donnees de detail;
  - les reactivations sont affichees en pourcentage des acquisitions abonnes: `Reactivations / (Nouveaux abonnes + Reactivations)`;
  - dans `Abonnements`, `ARR net` est masque et remplace par `Reactivations`, cliquable vers les factures concernees avec contexte dedie;
  - dans `Abonnements`, la colonne `Factures` est masquée dans le rendu pour ne pas confondre lignes MRR/factures sources et nombre d'abonnés;
  - le graphique typologie est remplace par `Stabilité du parc actif`, base uniquement sur des pourcentages, avec minimum 3 mois comme le graphique MRR: `Churn moyen` global en courbe, `Churn moyen N-1` en courbe pointillée, et `Actifs >= 3 mois`, `Actifs >= 6 mois`, `Réactivations` en colonnes globales;
  - le graphique `Évolution MRR / New MRR / Churn / Expansion` ajoute la série `Expansion net`;
  - en vue `Mois`, les deux graphiques minimum 3 mois calculent les séries sur M-2, M-1 et M, et chargent aussi le contexte M-3 pour le churn et l'expansion du premier mois affiché;
  - les cartes `Objectifs (budget)` affichent une ligne `Écart` calculée en absolu et en relatif, avec statut vert/orange/rouge configurable dans le helper de rendu;
  - `Ventes et résultat` devient `Ventes, résultat & revenu récurrent` avec lignes financières Budget/Réalisé/Écart/Lecture; `MRR HT` et `ARR HT` sont retirés du tableau `Abonnements` pour recentrer ce dernier sur le parc et les mouvements;
  - `Ventes, résultat & revenu récurrent` affiche aussi les colonnes `Dynamisation` et `Gamification`, et sa colonne `Écart` conserve uniquement le pourcentage d'écart vs budget;
  - `Abonnements` devient `Parc abonnés, mouvements & variation MRR`, sans lignes mensuelles visibles ni ligne ambiguë `Abonnés facturés`, avec stock de fin de période et flux agrégés sur la période;
  - les tableaux de synthèse de période sont affichés avant les graphiques, avec sous-titre de période; les graphiques fiscale/civile sont limités au mois sélectionné au lieu d'afficher les mois futurs de l'exercice;
  - les graphiques principaux sont simplifiés: CA HT facture / objectif CA HT / abonnés actifs pour la facturation, puis MRR HT / variation nette mensuelle / New MRR / churn valeur / expansion net pour le MRR;
  - le graphique MRR est resserré à deux séries visibles, `MRR HT` et `Variation nette MRR`, pour distinguer le stock récurrent et le flux net mensuel;
  - les deux graphiques principaux appliquent une marge d'axe automatique de 12% avec `suggestedMax`/`suggestedMin`, afin d'éviter les barres ou courbes collées en haut du canvas;
  - les axes des deux graphiques principaux sont libellés, et la ligne zéro de l'axe `Variation nette MRR` est accentuée;
  - `Parc abonnés, mouvements & variation MRR` affiche maintenant `Total`, `Dynamisation` et `Gamification` pour lire le parc, les mouvements et la variation MRR par usage;
  - les libellés visibles du reporting SaaS ont été relus pour restaurer les accents français;
  - `Visiteurs / prospects / clients` est refondu avec colonnes globales `Visiteurs uniques` / `Démos site` et sous-lignes par usage: `Inscrits`, `Avec démo`, `Essais gratuits`, `Clients`, les trois dernières colonnes affichant le volume avec le taux par rapport aux inscrits entre parenthèses;
  - les mois futurs des tableaux mensuels `Ventes et resultat`, `Abonnements`, `Visiteurs / prospects / clients` et `Jeux et joueurs` en vues `Annee fiscale` et `Annee civile` affichent des tirets au lieu de valeurs nulles, sans cumul dans les totaux.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_conversion.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_conversion.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `/bo/?t=syntheses&m=facturation_pivot&p=saas`;
  - verifier les vues mois, 3 mois, annee fiscale et annee civile;
  - controler une vue mois et une vue annuelle avec les valeurs `En pause` du tableau `Abonnements`, l'acces DB local etant refuse dans la sandbox;
  - controler que l'anciennete ne retombe pas sur les seules factures recentes du mois;
  - controler que `Actifs >= 3 mois` et `Actifs >= 6 mois` ne valent `0 %` que lorsqu'un parc actif facture existe vraiment;
  - verifier que le partage public par captures reste lisible apres regeneration d'un partage;
  - controler quelques comptes repris apres interruption pour confirmer les reactivations.

## PATCH 2026-05-27 - BO reporting SaaS: segmentation usage ventes et abonnements
- [x] Correctif livre:
  - `Ventes et resultat` segmente maintenant ses sous-lignes mensuelles et de total par `Dynamisation (CHR & lieux publics)` / `Gamification (Autres)`;
  - `Abonnements` utilise la meme segmentation usage dans ses sous-lignes a la place de `Mensuels` / `Annuels`;
  - les sous-lignes de total multi-mois restent ouvertes par defaut et en gras;
  - les flux abonnes sont cumules sur la periode par usage, tandis que les stocks MRR/ARR/ARPA restent alignes sur le dernier mois de la periode;
  - les totaux segmentes MRR/ARR/ARPA du tableau `Abonnements` sont derives des memes lignes MRR normalisees que les vues detaillees;
  - les liens MRR/ARR reviennent vers la vue liste dediee avec `view=mrr|arr|arr_net`, pas vers la modale locale;
  - les liens ARPA utilisent la page dediee `p=arpa`, y compris avec filtre usage sur les sous-lignes;
  - les liens Expansion net reviennent vers la page dediee `p=expansion`, avec filtre usage quand la sous-ligne le fournit;
  - les liens de total du CA par usage ouvrent le listing factures avec les factures du segment.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_arpa.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_list.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_expansion.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/facturation_pivot_factures.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_arpa.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_list.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_expansion.php web/bo/www/modules/syntheses/facturation_pivot/facturation_pivot_factures.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `/bo/?t=syntheses&m=facturation_pivot&p=saas`;
  - verifier `Ventes et resultat` et `Abonnements` en vue multi-mois;
  - verifier que les sous-lignes de total sont visibles, en gras, et que les clics ouvrent le detail attendu.

## PATCH 2026-05-27 - BO reporting SaaS: page detail Expansion net
- [x] Correctif livre:
  - les clics `Expansion net` du tableau `Abonnements` ouvrent maintenant une page externe dediee `?t=syntheses&m=facturation_pivot&p=expansion`;
  - les sous-lignes `Mensuels` et `Annuels` transmettent un filtre `scope=monthly|annual`;
  - la page dediee reutilise les calculs existants du reporting SaaS en mode data-only et affiche client, offre, scope, `MRR M-1`, `MRR M`, `Delta` et `ARR delta`;
  - le detail expansion separe maintenant les deltas mensuels et annuels pour un meme client, afin qu'une baisse mensuelle ne soit plus classee `Annuel` si le compte porte aussi un abonnement annuel actif;
  - les factures annuelles ne sont plus reprises dans la composante mensuelle du mois de facture; l'annuel actif porte le MRR annualise aussi pendant ce mois;
  - les offres des deltas negatifs peuvent etre reprises depuis la facture du mois precedent quand aucune facture courante n'existe;
  - les deltas nuls restent masques, comme dans la modale historique.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_expansion.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `/bo/?t=syntheses&m=facturation_pivot&p=saas`;
  - cliquer une valeur `Expansion net`, puis verifier la page `p=expansion`;
  - verifier les filtres periode et scope `Tous` / `Mensuels` / `Annuels`;
  - verifier qu'un lien client ouvre bien la fiche client BO.

## PATCH 2026-05-27 - BO offres clients: badge Essai dans Prix
- [x] Correctif livre:
  - le helper commun de rendu prix des offres client affiche maintenant le badge `Essai` dans la colonne `Prix` quand l'offre abonnement active est encore dans sa periode `trial_period_days` et sans facture liee;
  - le listing `Ecommerce > Offres clients` reprend ce badge via sa cellule custom `prix_ht`;
  - le bloc `Offres` de la fiche client BO reprend le meme badge car il utilise deja le helper prix/remise commun;
  - les badges de remise existants restent affiches dans la meme colonne.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_functions.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `/bo/?t=ecommerce&m=offres_clients` et verifier une offre d'essai active: badge `Essai` dans la colonne `Prix`;
  - ouvrir `/bo/?a=www&t=entites&m=clients&p=view&id={id}` pour le meme client et verifier le badge `Essai` dans le bloc `Offres`;
  - verifier une offre avec remise pour confirmer que le badge remise reste visible.

## PATCH 2026-05-27 - FO place: images des cartes etablissements
- [x] Correctif livre:
  - sur `/fr/place`, les cartes etablissements placent maintenant l'URL photo dans `src` directement;
  - le fallback JavaScript `src="#"` + `data-src` est retire sur ces cartes pour eviter une carte sans image si le lazy-load JS ne s'initialise pas;
  - le chargement differe est conserve via `loading="lazy"` natif.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_list_bloc.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/fo/modules/entites/clients/fr/fo_clients_list_bloc.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `/fr/place`;
  - verifier que les images des cartes etablissements s'affichent au chargement et au scroll;
  - verifier une carte connue, par exemple Santeuil Cafe, puis sa fiche detail `/fr/place/santeuil-cafe`.

## PATCH 2026-05-26 - BO home: activation commerciale Dynamisation
- [x] Correctif livre:
  - ajout sur la home BO active `Syntheses > Resumes` d'un bloc `Activation commerciale`;
  - affichage home limite aux KPI au chargement, avec tableau ferme puis filtre au clic sur le KPI choisi et refermeture au reclic sur le KPI actif;
  - listes filtrees alignees sur les compteurs, sans troncature par top global toutes categories confondues;
  - categorie `A` limitee aux inscrits Dynamisation des 3 derniers mois;
  - categorie `E` bornee sur l'absence d'usage recent: `0 soiree a 60j`;
  - badge `Offre ABN en attente` visible uniquement sur les lignes non abonnees concernees;
  - statut tunnel `ABN actif` affiche des que l'abonnement depasse 90 jours;
  - comptes TdR exclus du calcul via `flag_client_reseau_siege=0`; les affiliés réseau restent inclus;
  - separation visuelle des listings de prochaines sessions par jeu dans une section dediee;
  - listings de prochaines sessions par jeu repositionnes au-dessus de la section `Clients`;
  - espacement entre KPI haut et bloc `Activation commerciale` harmonise avec les autres sections;
  - KPI haut `Actifs`, `Inactifs` et `CA {mois}` rendus cliquables vers les listings cibles;
  - listing clients compatible avec le filtre groupe pipeline `bo_clients_pipeline_group=active|inactive`;
  - le bloc calcule 5 categories dedoublonnees et priorisees: `B` essais gratuits Dynamisation a risque, `D` nouveaux ABN Dynamisation a risque, `C` essais Dynamisation actives a securiser, `E` ABN Dynamisation inactifs ou peu actifs, `A` inscrits Dynamisation actifs a convertir;
  - ciblage commercial aligne sur l'usage client `Dynamisation` (`id_solution_usage=1`) au lieu de la seule typologie CHR;
  - sessions significatives lues depuis `reporting_games_sessions_detail` avec joueurs et completees par les sessions papier passees non-demo completes; soirees significatives comptees par dates distinctes;
  - alias SQL d'agregat d'usage nomme `act_usage` pour compatibilite MariaDB;
  - detection de `reporting_games_sessions_detail` par lecture directe `SELECT 1 FROM ... LIMIT 1`, afin d'eviter un faux message d'indisponibilite quand la table est bien accessible;
  - distinction affichee entre source reporting inaccessible et erreur SQL de calcul, avec log `[bo_resumes_activation][sql_error]`;
  - essais gratuits e-commerce lus sur offres abonnement actives payantes avec `trial_period_days>0`, dates `date_debut` / `DATE_ADD(date_debut, INTERVAL trial_period_days DAY)` et absence de premiere facture reelle;
  - sessions programmees a venir non-demo completes excluent les risques `B/C/D/E` et servent de signal fort pour `A`;
  - affichage filtre par KPI avec compteurs, contact, tunnel, dates d'essai, jours restants, usage, prochaine session et action recommandee;
  - aucune modification Stripe, webhook, facturation ou reporting officiel.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/resumes/bo_resumes_list.php` OK;
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/resumes/bo_resumes_list.php web/bo/www/modules/syntheses/resumes/bo_resumes_list_V1.php` OK;
  - `bo_resumes_list_V1.php` sans diff.
- [ ] Verification recette serveur:
  - ouvrir `?t=syntheses&m=resumes`;
  - verifier que le bloc `Activation commerciale` apparait sous les KPI haut avec uniquement ses compteurs visibles;
  - cliquer chaque KPI et verifier que le tableau se deroule filtre sur la categorie choisie;
  - recliquer le KPI actif et verifier que le tableau se referme;
  - verifier que l'espace entre les KPI haut et `Activation commerciale` est coherent avec les autres separations de section;
  - cliquer `Actifs` et verifier le listing clients filtre ABN+PAK trie par inscription recente;
  - cliquer `Inactifs` et verifier le listing clients filtre INS+CSO trie par inscription recente;
  - cliquer `CA {mois}` et verifier le listing facturation filtre sur le mois courant;
  - verifier au moins un client des categories `A`, `B/C`, `D/E` via fiche client, offres client et sessions;
  - verifier qu'un client avec session future non-demo complete n'apparait pas en risque `B/C/D/E`;
  - verifier qu'une tete de reseau n'apparait dans aucun compteur/liste du bloc et qu'un affilie reseau eligible reste affichable;
  - verifier les dates debut/fin d'essai, jours restants et action recommandee sur un essai en cours;
  - verifier que les blocs `Blind Test`, `Bingo Musical` et `Cotton Quiz` restent au-dessus de `Dernieres connexions clients` / `Derniers inscrits`.

## PATCH 2026-05-26 - FO catalogue: demo rapide par defaut
- [x] Correctif livre:
  - sur les pages catalogue publiques qui incluent le composant `fo_portail_jeux_demo_signup.php`, l'onglet `Démo rapide` est affiche en premiere position et actif par defaut;
  - l'onglet `Démo complète` passe en seconde position et reste disponible au clic;
  - la pastille `Recommandé` de l'onglet `Démo complète` reste en couleur pleine meme quand l'onglet est inactif.
- [x] Verification locale:
  - `php -l www/web/fo/modules/jeux/portail/fr/fo_portail_jeux_demo_signup.php` OK.
- [ ] Verification recette serveur:
  - ouvrir une page catalogue playlist, par exemple `/fr/jeux/cotton-blind-test/catalogue/playlist/{slug}`;
  - verifier que `Démo rapide` est le premier onglet et que son contenu est visible au chargement;
  - cliquer `Démo complète` et verifier que le formulaire complet s'affiche;
  - verifier que la pastille `Recommandé` reste visible et coloree sur l'onglet complet inactif.

## PATCH 2026-05-26 - BO SaaS: factures MRR potentielles dans le detail
- [x] Correctif livre:
  - dans `Syntheses > Reporting facturation > SaaS`, le modal ouvert depuis `MRR HT` ou `ARR HT` du mois courant ajoute les clients MRR du mois precedent absents du mois courant;
  - ces lignes sont marquees `A emettre`, sans numero ni lien de facture, afin d'identifier les factures potentielles en attente;
  - les offres deja identifiees en pause/resiliation sont exclues du report MRR/ARR courant et des lignes `A emettre`.
  - les valeurs du tableau `Abonnements` ouvrent le listing `Reporting facturation > Factures` filtre par IDs de factures ou par clients `A emettre`;
  - les sous-lignes `Mensuels` / `Annuels` sont cliquables avec un filtre de selection par frequence;
  - le listing affiche un bandeau de contexte pour rappeler la vue filtree;
  - `Expansion net` ouvre la modale historique `MRR M-1 / MRR M / Delta`;
  - la modale `Expansion net` reprend la logique historique: absence de facture M = MRR M repris depuis M-1, pas une perte;
  - les lignes `A emettre` conservent le mode de paiement quand il est connu depuis la facture precedente.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK;
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_list.php` OK;
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/facturation_pivot_factures.php` OK;
  - `git -C www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] Verification recette serveur:
  - ouvrir le reporting SaaS sur le mois courant;
  - cliquer `MRR HT` puis `ARR HT`;
  - verifier que les clients MRR presents en M-1 mais non factures sur le mois courant apparaissent en lignes `A emettre`, sans numero de facture;
  - verifier qu'un client en pause/resiliation n'apparait pas dans les lignes `A emettre` et n'alimente pas le MRR/ARR courant;
  - verifier que les lignes facturees gardent leur numero et leur lien facture;
  - cliquer les valeurs `Mensuels` / `Annuels` et verifier que le listing facture est filtre;
  - cliquer `Expansion net` et verifier que la modale affiche la vue comparative `MRR M-1 / MRR M / Delta`;
  - verifier qu'une facture M non emise ne ressort pas comme perte dans `Expansion net`;
  - verifier que le bandeau de contexte resume la vue ouverte;
  - verifier que les lignes `A emettre` affichent le mode de paiement connu.

## PATCH 2026-05-22 - BO offres clients: remises commerciales visibles
- [x] Correctif livre:
  - ajout d'une colonne `Remise` dans le listing `Ecommerce > Offres clients`, avec nom de remise et pourcentage;
  - prise en compte des remises reseau dynamiques des offres deleguees hors abonnement reseau, meme quand `remise_nom` / `remise_pourcentage` ne sont pas stockes sur `ecommerce_offres_to_clients`;
  - enrichissement de la colonne `Prix HT` du listing: prix signe, prix de base et chip bleue de remise quand une remise existe, sans detail d'economie HT;
  - ajout d'un filtre custom `Remise` (`Oui` / `Non`) combinable avec les filtres existants `Trial` et `Résiliation`, incluant aussi les remises reseau deleguees detectables en SQL;
  - masquage du filtre `Vendeur` dans la barre de filtres du listing offres clients;
  - ajout d'un bloc `Remise commerciale` sur la fiche detail d'une offre client remisee, avec chip, nom de remise, prix de base et prix remise;
  - alignement du bloc `Offres` de la fiche client BO sur le meme affichage prix/remise dans la colonne prix, sans colonnes `Remise` ni `Prod. add.` separees;
  - traitement des offres deleguees incluses dans l'abonnement reseau comme prises en charge reseau (`Inclus abn reseau`) avec prix effectif `Inclus`;
  - simplification du bloc home `Dernieres offres clients`: chip `Essai` conservee, chip `Payante` supprimee, chips bleues `Remise -x %`, `Offert` ou `Inclus abn reseau` conservees, et nom de delegation affiche sous le client quand disponible, sans filtrer les offres actives sur `flag_offert` ni `prix_ht`.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_functions.php` OK;
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php` OK;
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php` OK;
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK;
  - `php -l www/web/bo/www/modules/syntheses/resumes/bo_resumes_list.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `Ecommerce > Offres clients` et verifier une offre avec remise: colonne `Remise`, prix de base, chip bleue de remise et absence du filtre `Vendeur`;
  - tester le filtre `Remise=Oui` et `Remise=Non` combine avec `Etat`, `Trial` et `Résiliation`;
  - ouvrir la fiche detail d'une offre remisee et verifier le bloc `Remise commerciale`;
  - ouvrir la fiche d'un client avec une offre remisee et verifier le bloc `Offres`;
  - verifier une offre deleguee hors abonnement reseau avec remise volume reseau (ex. `Remise reseau : 25 %`): le prix affiche doit reprendre le net calcule, pas uniquement `ecommerce_offres_to_clients.prix_ht`;
  - verifier une offre deleguee incluse dans un abonnement reseau: affichage `Inclus abn reseau`, prix effectif `Inclus`, prix de base conserve;
  - verifier la pastille bleue remise dans `Syntheses > Resumes > Dernieres offres clients` avec pourcentage, sans detail de prix de base ni nom de remise.

## PATCH 2026-05-22 - BO Stripe: libelles suivi resiliation
- [x] Correctif livre:
  - les lignes Stripe issues de `user_feedback_events` sont libellees `Stripe + suivi` dans la home BO;
  - le listing `Ecommerce > Offres clients` affiche aussi `Source : Stripe + suivi`;
  - la date affichee dans ce listing devient `Résiliation demandée le ...` pour refleter `subscription.canceled_at`.
  - la page `Tracking > Feedbacks EP/Stripe` limite ses filtres d'entete a `Client` et `Type d'evenement` (`Tous`, `Résiliations Stripe`, `Commentaires EC`) via le hook standard du BO;
  - le filtre `Type d'evenement` utilise un champ POST direct `bo_feedback_event_type`, comme les filtres custom du listing sessions, avec fallback de lecture pour l'ancien POST imbrique;
  - le tableau `Feedbacks EP/Stripe` ajoute la colonne triable `Résiliation effective`, lue depuis `tags_json.cancellation_effective_at` pour les lignes Stripe;
  - le bloc super-admin `Backfill Stripe` est masque de la page, le backfill restant disponible cote global/CLI.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/syntheses/resumes/bo_resumes_list.php` OK;
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_functions.php` OK;
  - `php -l www/web/bo/www/modules/tracking/clients_feedback_events/bo_module_parametres.php` OK;
  - `php -l www/web/bo/www/modules/tracking/clients_feedback_events/bo_clients_feedback_events_list.php` OK;
  - `php -l www/web/bo/www/modules/tracking/clients_feedback_events/bo_clients_feedback_events_functions.php` OK.
  - `git -C www diff --check -- web/bo/www/modules/tracking/clients_feedback_events/bo_module_parametres.php web/bo/www/modules/tracking/clients_feedback_events/bo_clients_feedback_events_functions.php web/bo/www/modules/tracking/clients_feedback_events/bo_clients_feedback_events_list.php` OK.
- [ ] Verification recette serveur:
  - verifier une resiliation Stripe sans feedback dans `Tracking > Feedbacks EP/Stripe`;
  - verifier les libelles `Stripe + suivi` sur la home BO et dans `Ecommerce > Offres clients`.
  - verifier que les filtres d'entete affichent seulement `Client` et `Type d'evenement`;
  - verifier le filtre `Type d'evenement`;
  - verifier la colonne `Résiliation effective` et son tri sur les lignes de resiliation Stripe;
  - verifier que le bloc backfill n'est plus visible sur la page BO.

## PATCH 2026-05-22 - BO home: responsive mobile
- [x] Correctif livre:
  - ajout de regles CSS locales a `#resumes-list` pour eviter les debordements lateraux mobiles;
  - tableaux simples de la home initialises en mobile avec `dt-responsive nowrap` sur `.bo-resumes-datatable`, avec colonnes secondaires marquees `none`, afin de proposer le lien `+` de depliage par ligne;
  - blocs sessions alignes sur une limite commune: calcul du nombre de sessions de la prochaine journee disponible pour chaque jeu, puis affichage des prochaines sessions de chaque jeu jusqu'au plus grand de ces nombres;
  - suppression des lignes intercalaires `Semaine xx` dans les blocs sessions, avec report de leur couleur rouge/rose sur les dates de session;
  - liens explicites conserves dans les cellules sessions pour garder le `Ctrl+clic` / nouvel onglet natif, icone detail agrandie et icone logs retiree des blocs sessions de la home;
  - pastilles d'etat des sessions du jour adaptees sur mobile via `bo-resumes-session-state-badge`, dans le detail de ligne responsive, avec rendu serveur initial avant rafraichissement AJAX;
  - ciblage des trois cartes sessions par `bo-resumes-sessions-card`; tableaux convertis en une ligne HTML par session avec colonne `Action` depliable via le lien `+` mobile, sans scroll lateral;
  - ajout d'un espacement vertical entre colonnes empilees sous tablette, y compris entre `Bingo Musical` et `Cotton Quiz` malgre l'ordre visuel `order-*`;
  - entetes clients, commerce et feedback uniformises en layout `badge + titre + lien optionnel` via `bo-resumes-card-heading`;
  - lien `Voir tous les logs` ajoute dans l'entete de `Dernieres connexions clients`, vers `Tracking > Clients logs`;
  - liens home `Voir toutes les resiliations` et `Voir tous les feedbacks` branches vers `Tracking > Feedbacks EP/Stripe`, respectivement filtres sur `Résiliations Stripe` et `Commentaires EC`;
  - badge source du bloc `Resiliations abonnes` simplifie en `Portail Stripe` ou `BO / legacy`, sans libelle `Stripe + suivi`;
  - blocs commerce alignes sur la meme grille que les blocs clients: `Dernieres offres clients` a gauche, `Resiliations abonnes` a droite, sans wrappers internes supplementaires;
  - remplacement du bloc `Dernieres factures` par `Dernieres offres clients`, lu depuis `ecommerce_offres_to_clients` actives non offertes, triees par `date_debut DESC`, avec badges `Essai` / `Payante`.
  - affichage des mentions `Essai en cours` et `Resiliation le ...` a cote du montant dans `Dernieres offres clients`, separees par `|`, sans augmenter la hauteur de ligne.
  - graisse typographique uniformisee dans les blocs `Clients`, `Commerce` et `Feedback Utilisateurs`: le gras explicite est reserve aux noms clients des lignes du jour.
  - statuts du bloc `Resiliations abonnes` colores: `Planifiee` en orange, `Terminee` en rouge.
  - suppression du fallback `date_maj` pour la ligne `Enregistree le ...` du bloc `Resiliations abonnes`; la date n'est affichee que si elle vient d'un suivi Stripe date.
  - motif de resiliation Stripe affiche a cote du montant dans `Resiliations abonnes`, separe par `|`, pour limiter la cellule client a trois lignes.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/syntheses/resumes/bo_resumes_list.php` OK.
  - `git -C www diff --check -- web/bo/www/modules/syntheses/resumes/bo_resumes_list.php` OK.
- [ ] Verification recette serveur:
  - verifier la home BO en viewport mobile et confirmer l'absence de debordement lateral global;
  - verifier que les blocs sessions empiles gardent une separation verticale lisible;
  - verifier que les tableaux simples affichent un bouton `+` de depliage par ligne et placent les colonnes secondaires dans le detail;
  - verifier que les tableaux sessions affichent le lien `+` de depliage mobile, sans scroll horizontal;
  - verifier qu'un jeu avec moins de sessions sur sa prochaine journee complete avec les sessions suivantes pour atteindre le nombre du bloc le plus fourni;
  - verifier que les blocs sessions n'affichent plus de ligne `Semaine xx` et que les dates ressortent en rouge/rose;
  - verifier que les liens explicites des cellules sessions gardent le `Ctrl+clic` / nouvel onglet natif, que l'icone detail est agrandie et que l'icone logs n'est plus presente;
  - verifier que les pastilles d'etat des sessions du jour apparaissent dans le detail depliable sur mobile et ne debordent plus;
  - verifier que les entetes clients, commerce et feedback suivent le meme schema visuel;
  - verifier que `Voir tous les logs` ouvre `?t=tracking&m=clients_logs`;
  - verifier que `Voir toutes les resiliations` ouvre `Tracking > Feedbacks EP/Stripe` filtre sur `Résiliations Stripe`;
  - verifier que `Voir tous les feedbacks` ouvre `Tracking > Feedbacks EP/Stripe` filtre sur `Commentaires EC`;
  - verifier que `Dernieres offres clients` et `Resiliations abonnes` reprennent la meme largeur et le meme espacement que les blocs clients au-dessus;
  - verifier que `Dernieres offres clients` affiche des offres actives conclues et distingue correctement `Essai` / `Payante`;
  - verifier que les offres actives avec `date_fin` affichent bien `Resiliation le ...` sur la ligne du montant;
  - verifier que dans les blocs `Clients`, `Commerce` et `Feedback Utilisateurs`, seuls les noms clients des lignes du jour sont en gras;
  - verifier que les statuts `Planifiee` et `Terminee` de `Resiliations abonnes` sont visuellement differencies;
  - verifier que `Enregistree le ...` n'apparait plus sur les resiliations sans suivi Stripe date;
  - verifier que le motif de resiliation Stripe apparait sur la ligne du montant dans `Resiliations abonnes`;
  - verifier que les liens `Voir toutes...` ne forcent plus la largeur des cartes.

## PATCH 2026-05-21 - BO Tracking: Feedbacks EP/Stripe
- [x] Correctif livre:
  - ajout du lien `Feedbacks EP/Stripe` dans le menu BO `Tracking`, sous `Clients [ nav. espace pro ]`;
  - creation du module lecture seule `tracking/clients_feedback_events`;
  - affichage des entrees `user_feedback_events` EP et Stripe avec date, client, contexte, surface, note, commentaire, tags et session;
  - retrait des colonnes `Page` et `Statut` du tableau BO afin de laisser plus de largeur a `Commentaire`;
  - libelles de feedback et tags affiches sans emoji ni suffixe degrade `????` pour rester compatibles avec le rendu BO;
  - affichage Stripe allege: libelles BO courts pour le contexte/surface, tags techniques Stripe masques et note interne de dedoublonnage non affichee pour les lignes `stripe_subscription_cancellation`;
  - retrait du formulaire super-admin `Backfill Stripe` apres execution du rattrapage ponctuel;
  - tableau compacte sur desktop avec colonnes proportionnees et wrapping controle pour afficher date, client, contexte, feedback, commentaire et session sans colonnes masquees; repli `dt-responsive nowrap` conserve uniquement sur mobile;
  - filtres BO disponibles sur client, contexte, note technique et statut interne;
  - liens directs vers la fiche client BO, la fiche session BO et l'URL source quand disponible.
- [x] Verification locale:
  - `php -l www/web/bo/bo.php` OK;
  - `php -l www/web/bo/www/modules/tracking/clients_feedback_events/bo_module_parametres.php` OK;
  - `php -l www/web/bo/www/modules/tracking/clients_feedback_events/bo_clients_feedback_events_list.php` OK;
  - `git -C www diff --check -- web/bo/bo.php web/bo/www/modules/tracking/clients_feedback_events/bo_module_parametres.php web/bo/www/modules/tracking/clients_feedback_events/bo_clients_feedback_events_list.php` OK.
- [ ] Verification recette serveur:
  - ouvrir `?t=tracking&m=clients_feedback_events` et verifier le titre `Feedbacks EP/Stripe`;
  - verifier que le bloc `Backfill Stripe` n'est plus affiche;
  - verifier que toutes les colonnes du tableau restent visibles sur desktop;
  - verifier le compteur, la pagination et les filtres sur des feedbacks reels;
  - verifier les liens client/session/page source.

## PATCH 2026-05-21 - BO home: blocs sessions du moment
- [x] Correctif livre:
  - blocs `Blind Test`, `Cotton Quiz` et `Bingo Musical` de la home BO harmonises sur les conventions sessions recentes;
  - blocs sessions alignes en premiere ligne, un jeu par colonne; le wrapper du bloc `Cotton Quiz` reprend la meme structure que les blocs `Blind Test` et `Bingo Musical` pour conserver la meme largeur de colonne;
  - blocs `Dernieres connexions clients` et `30 derniers inscrits` deplaces sous les sessions, cote a cote sur desktop;
  - chaque bloc jeu home limite son affichage a la prochaine journee contenant au moins une session a venir pour ce jeu;
  - lien de bloc renomme `Voir toutes les prochaines sessions` et branche vers le listing filtre sur jeu + sessions completes non-demo + periode `A venir`;
  - affichage session reorganise en 3 lignes: client/date, thematique/horaire, format/participants;
  - format affiche en `[Numerique]` ou `[Papier]` depuis `championnats_sessions.flag_controle_numerique`;
  - suppression des libelles techniques visibles dans les blocs (`QZ`, `NEW ! V2/V3`, stocks grilles papier/numerique);
  - espacement vertical des trois lignes uniformise;
  - colonne d'actions separee a droite avec icone `ti-arrow-circle-right` vers la fiche detail session au-dessus de l'icone historique `ti-pulse` vers les logs, via `championnats_sessions.id_securite`;
  - suppression de l'etoile de statut dans les blocs home;
  - compteur participants aligne sur une regle BO explicite sur la home, le listing BO sessions et la fiche detail session: inscrits/participations probables toujours affiches, puis participants reels ajoutes des que la session est en cours ou terminee pour permettre le comparatif; la jauge `nb_joueurs_max` reste affichee;
  - libelles fiche detail: `Inscrits` / `Participants`;
  - libelles home et liste en compact: `Ins. : n / Part. : n / max`;
  - correctif retour recette 2026-05-21 16:11: fallback home aligne sur le compact quand le helper BO sessions n'est pas charge, et ajout de `nb_joueurs_max` dans la selection du listing sessions;
  - correctif retour recette 2026-05-21 16:15: jauge `/ max` preservee avant enrichissement runtime avec fallback jauge offre client; pastille etat deplacee dans la colonne actions home; liens home vers liste sessions sans tri/page/date force.
  - correctif retour recette 2026-05-21 16:23: fallback detail session pour recuperer `nb_joueurs_max` quand la jauge reste absente; libelles `Ins. / Part.` home non cliquables.
  - correctif UI view session 2026-05-21: espacement sous `Format`, espacement au-dessus du fallback resultats et wording adapte pour session en attente.
  - addendum view session 2026-05-21: details des inscrits probables affiches uniquement en fallback, si aucun participant reel, podium ou classement n'est disponible.
  - pastille etat ajoutee sur la home uniquement pour les sessions du jour (`En attente`, `En cours`, `Termine`) en reutilisant l'etat calcule par le helper participants;
  - affichage des sessions limite a la prochaine journee disponible pour chaque jeu;
  - filtre `Periode` ajoute au listing sessions (`A venir` / `Passees`) sur `championnats_sessions.date`;
  - ordre par defaut du listing inverse quand `Periode = A venir`: sessions les plus proches en premier;
  - tri des trois blocs par date puis heure de debut croissante, avec client / format uniquement en criteres secondaires;
  - masquage des sessions sans offre client active (`ecommerce_offres_to_clients.id_etat=3`), donc non jouables;
  - optimisation charge: interrogation des tables runtime participants limitee aux sessions en cours ou terminees; les sessions en attente lisent seulement le compteur de participations;
  - optimisation charge home: calcul leger local des compteurs sans helper complet du listing/detail sessions, et sans relecture `app_session_get_detail()` pour la jauge;
  - optimisation charge home 2026-05-21: compteurs `Ins. / Part.` et pastille d'etat charges en differe par un endpoint JSON batch `sessions_metrics_ajax`;
  - optimisation charge home 2026-05-21 bis: bloc `Suivi mensuel` charge en differe par `monthly_metrics_ajax` pour eviter les nombreuses requetes mensuelles dans le rendu initial;
  - bloc `Suivi mensuel` ensuite masque et plus appele par le front de la home;
  - liens vers la liste complete branches sur le filtre `Jeu` du listing sessions (`bo_session_game=blindtest|quiz|bingo`) avec demo=0 et complete=1;
  - ordre visuel des blocs sessions ajuste en `Blind Test`, `Bingo Musical`, `Cotton Quiz`;
  - bloc `30 derniers inscrits` renomme `Derniers inscrits`;
  - liste des inscrits limitee a 10 lignes et triee par `clients.date_ajout DESC`, `Dernieres connexions clients` conservant ses 30 lignes;
  - lien secondaire remplace par `Voir tous les inscrits` vers le listing clients filtre sur `Etat = Prospects` et trie par `date_ajout DESC`;
  - bloc `Abonnement arrivant à échéance` remplace par `Dernieres resiliations abonnes`;
  - source principale des resiliations: offres abonnement payantes avec `date_fin` renseignee dans `ecommerce_offres_to_clients`;
  - enrichissement optionnel par `user_feedback_events` uniquement quand un feedback Stripe de resiliation existe; le libelle feedback de la home ouvre `Tracking > Feedbacks EP/Stripe` pour consulter le commentaire lie; cette table n'est pas consideree exhaustive pour les resiliations legacy/BO ou Stripe sans feedback.
  - bloc `50 dernieres commandes` renomme `Dernieres commandes`;
  - liste des commandes reduite a 30 lignes et branchee sur les factures editees (`ecommerce_commandes.numero_facture<>''`) avec la date facture normalisee utilisee par le pivot SaaS;
  - bloc `Dernieres resiliations abonnes` limite a 10 lignes et `Dernieres commandes` a 15 lignes pour eviter de surcharger la home;
  - lien `Voir toutes les resiliations` ajoute vers `Ecommerce > Offres clients` filtre par `Résiliation=Oui`;
  - tri du bloc `Dernieres resiliations abonnes` aligne sur le listing complet: `date_fin DESC`, puis `id DESC`;
  - separateurs visuels de section ajoutes pour restaurer un filet et de l'espace vertical entre les grands blocs de la home, y compris entre les blocs sessions et les blocs `Dernieres connexions clients` / `Derniers inscrits`; le `margin-bottom` global des `.card-box` est neutralise dans `#resumes-list` pour eviter un cumul avec ces separateurs;
  - puces factures: `New` seulement sur premiere facture d'une offre sans offre terminee anterieure, `Renew` seulement sur premiere facture d'une offre quand le client a deja une offre terminee;
  - lien secondaire ajoute: `Voir toutes les factures` vers `?t=ecommerce&m=factures`.
  - KPIs du haut remplaces par les indicateurs `Inscrits`, `Clients payants`, `Essais en cours`, `Clients CSO`, `CA HT mensuel`;
  - compteur `Clients payants` base sur les offres client actives non offertes, aligne sur le listing cible;
  - compteur essais en cours corrige: calcul depuis les offres abonnement actives encore dans leur fenetre d'essai ecommerce (`trial_period_days` + `date_debut`) et sans facture editee liee a la meme offre (`id_offre_client` + `id_client`), plus depuis l'ancien module technique des formules;
  - listing `Ecommerce > Offres clients`: filtre custom `Trial` (`Oui` / `Non`) ajoute via `bo_offres_clients_filter_extend`, sans faux champ `$module_champs`;
  - listing `Ecommerce > Offres clients`: filtre custom `Résiliation` (`Oui` / `Non`) ajoute sur le meme modele pour retrouver les offres abonnement payantes avec `date_fin` renseignee;
  - filtre `Trial` aligne sur le modele audite de `bo_sessions_filter_extend`: HTML custom + SQL custom injecte dans `$sql_bdd_filtre`, pour conserver le meme SQL master entre compteur, liste, tris et pagination;
  - listing `Ecommerce > Offres clients`: colonne `Commentaire` enrichie avec `Source : Stripe + suivi`, libelle et eventuel commentaire client quand un suivi de resiliation Stripe existe pour la souscription;
  - lien du KPI `Essais en cours` branche sur le listing des offres client actives (`id_etat=3`, `flag_offert=0`) avec `Trial=Oui`;
  - liens KPI `Inscrits` et `Clients CSO` branches vers le listing clients trie par `date_ajout DESC`;
  - compteur `Clients payants` aligne sur le compteur du listing `Offres clients` ouvert au clic (`Etat=Active`, `Offert=Non`).
  - KPI `CA HT mensuel` branche sur les factures editees du mois courant avec date facture normalisee comme dans `facturation_pivot`, et lien direct vers `?t=syntheses&m=facturation_pivot&p=saas`;
  - retour home 2026-05-26: KPI haut remplaces par le perimetre V1 `Actifs`, `Inactifs`, `Activation (30j)`, `Power Users (30j)`, `Conversion (Globale)`, `CA {mois courant}`;
  - bloc super-admin `Feedback questions` renomme `Feedback Utilisateurs` et branche sur les 15 derniers feedbacks espace pro de `user_feedback_events`, hors Stripe;
  - lien `Voir tous les feedbacks` ajoute vers `Tracking > Feedbacks EP/Stripe`;
  - sections `Opérations`, `Bingo` et `App.` masquees du menu BO, sans suppression des routes accessibles en direct;
  - retour home 2026-05-26: bloc `Suivi mensuel` reintegre en bas de page via `monthly_metrics_ajax` sans layout, charge apres le rendu initial, avec comparaison dynamique N / N-1;
  - retour home 2026-05-26: bloc `Surveillance des donnees` reintegre sous le `Suivi mensuel`, avec separateur visuel dedie.
  - fiche detail session: sous l'etat `En cours`, ajout de `Morceau courant` ou `Question courante` avec les helpers du listing sessions.
- [x] Verification locale:
  - `php -l www/web/bo/bo.php` OK;
  - `php -l www/web/bo/master/bo_master_list.php` OK;
  - `php -l www/web/bo/www/modules/syntheses/resumes/bo_resumes_list.php` OK;
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php` OK;
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_functions.php` OK;
  - `git -C www diff --check -- web/bo/master/bo_master_list.php web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_functions.php` OK;
  - `git -C www diff --check -- web/bo/bo.php web/bo/master/bo_master_list.php web/bo/www/modules/syntheses/resumes/bo_resumes_list.php web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_functions.php` non bloquant: espaces fin de ligne preexistants nombreux dans `bo_resumes_list.php`.
  - `npm run docs:sitemap` OK;
  - `git -C documentation diff --check` OK.
- [ ] Verification recette serveur:
  - verifier un bloc Quiz V2 multi-series avec date, horaire, format, libelle series, jauge max, icone detail et icone logs;
  - verifier un bloc Blind Test avec date, horaire, format, thematique, jauge max, icone detail et icone logs;
  - verifier un bloc Bingo V3 avec date, horaire, format, thematique, jauge max, icone detail et icone logs;
  - comparer les compteurs participants entre le pro, la home BO, la liste BO sessions et la fiche detail session;
  - verifier que la home affiche uniquement la prochaine journee disponible pour chaque jeu;
  - verifier qu'une session rattachee a une offre terminee/expiree ne remonte plus sur la home;
  - verifier qu'une session en attente n'entraine pas de lecture runtime participants et affiche `Inscrits` / `Ins.`;
  - verifier qu'une session en cours affiche `Inscrits` + `Participants` et la version compacte `Ins. / Part.`;
  - verifier qu'une session terminee conserve `Inscrits` et affiche aussi `Participants`;
  - verifier que seules les sessions du jour affichent la pastille d'etat sur la home;
  - verifier que chaque icone de liste ouvre `Animations > Sessions` avec le bon filtre `Jeu`.
  - verifier que `Suivi mensuel` s'affiche apres chargement AJAX en bas de page;
  - verifier le separateur visuel entre `Suivi mensuel` et `Surveillance des donnees`;
  - verifier que les blocs sessions apparaissent dans l'ordre `Blind Test`, `Bingo Musical`, `Cotton Quiz`;
  - verifier que `Derniers inscrits` reste plus compact que `Dernieres connexions clients` et que son lien ouvre les prospects les plus recents;
  - verifier que `Dernieres resiliations abonnes` liste les resiliations Stripe et legacy/BO attendues, avec `Stripe + suivi` quand la ligne `user_feedback_events` existe.
  - verifier que `Dernieres commandes` liste uniquement des lignes avec numero de facture, dans le meme ordre recent que le pivot facturation SaaS, et que `Voir toutes les factures` ouvre le listing factures.
  - verifier les KPI haut V1 `Actifs`, `Inactifs`, `Activation (30j)`, `Power Users (30j)`, `Conversion (Globale)` et `CA {mois courant}`;
  - verifier que `Essais en cours` correspond aux offres abonnement actives sans facture editee liee a l'offre;
  - verifier que le clic sur le KPI `Essais en cours` ouvre le listing `Ecommerce > Offres clients` avec `Trial=Oui`;
  - verifier que `Trial=Oui` / `Trial=Non` se combine correctement avec les autres filtres, le compteur, les tris et la pagination;
  - verifier que les clics KPI `Inscrits` et `Clients CSO` ouvrent les clients les plus recents en haut;
  - verifier que `Feedback Utilisateurs` remonte uniquement des feedbacks espace pro, hors `stripe_subscription_cancellation`;
  - verifier que `Surveillance des donnees` s'affiche sous le `Suivi mensuel`.

## PATCH 2026-05-20 - BO listing sessions: filtres et infos jeux
- [x] Correctif livre:
  - filtres legacy `Ope evenement`, `Privee` et `Session speciale` masques;
  - filtre `Jeu` ajoute avec regroupement `Blind Test`, `Bingo Musical`, `Cotton Quiz`;
  - filtre `Format` ajoute sur `flag_controle_numerique` (`Numerique` / `Papier`);
  - colonne `Date & heure` sans saison;
  - colonne `Jeu` sans chip nouveau type ni listing inline des joueurs;
  - etat courant harmonise en `Phase courante : ... | Morceau courant / Question courante : ...`;
  - series Quiz affichees au-dessus du format;
  - identifiants harmonises: `id_lots`, `id_playlist`, `id_playlist_client`.
  - affichage tableau ajuste: reduction responsive conservee sur mobile, colonnes desktop proportionnees et wrapping force sans `dt-responsive nowrap` pour limiter les colonnes masquees.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/championnats/sessions/bo_sessions_functions.php` OK;
  - `php -l www/web/bo/www/modules/championnats/sessions/bo_sessions_list.php` OK;
  - `php -l www/web/bo/www/modules/championnats/sessions/bo_module_parametres.php` OK.
- [ ] Verification recette serveur:
  - tester les filtres `Jeu` et `Format`;
  - verifier une session Quiz multi-series;
  - verifier les libelles runtime sur sessions en attente, en cours et terminees.

## PATCH 2026-05-20 - BO fiche detail client: stats et sessions
- [x] Correctif livre:
  - stats jeux du bloc principal branchees sur le contexte EC `Ma communaute` deja calcule par `app_client_joueurs_dashboard_get_context`;
  - detail sessions/participants par jeu affiche dans le premier bloc;
  - note de perimetre ajoutee sous les stats: sessions non-demo, completes, avec participants inscrits ou papier;
  - bloc `Sessions` ouvert a toutes les sessions liees au client, sans filtre demo ni complete;
  - colonne `# Produit` remplacee par `Thematique` dans le bloc `Sessions`;
  - colonne `Privee` remplacee par `Participants`;
  - colonnes `Demo` et `Complete` ajoutees avec coche si le flag vaut `1`;
  - bloc principal revenu en demi-page avec `Contacts` a cote;
  - ajout en haut du bloc principal d'une vue publication en ligne empilee: statut `online`, premiere photo, accroche, descriptif et liens publics;
  - `id_client` repositionne dans la zone technique historique avec Stripe et les liens `Voir la page sur le site` vers `/fr/place/{slug}` / `Voir la page agenda (QR code)` vers `/place/{code}`;
  - affichage des sources prioritaires LP reseau sous le bouton `Voir / gérer les affiliés` des comptes TdR: logo LP, visuel principal LP et couleurs LP dediees quand elles sont renseignees;
  - masquage des blocs generiques `Informations` et `Photo`;
  - confirmation que le bloc `Emails transactionnels` de la fiche client est legacy (`id_email_transactionnel` / `referentiels_emails_transactionnels`, alors que le flux courant documente cote AI Studio journalise par `code_email_transactionnel`);
  - positionnement du bloc `Remises` sous `Offres`;
  - masquage des blocs bas dupliques: `Offres`, `Sessions`, `Factures`, `Logs`, `Emails transactionnels`, `Contacts`;
  - masquage des blocs bas `Equipes`, `Evenements` et `Reseau`.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK;
  - `php -l www/web/bo/www/modules/entites/clients/bo_module_aside.php` OK;
  - `git -C www -c core.whitespace=blank-at-eol,blank-at-eof,space-before-tab,cr-at-eol diff --check -- web/bo/www/modules/entites/clients/bo_clients_view.php web/bo/www/modules/entites/clients/bo_module_aside.php` OK.
- [ ] Verification recette serveur:
  - verifier une fiche client avec sessions Quiz, Blind Test et Bingo terminees;
  - verifier une fiche client avec session demo et session incomplete;
  - comparer les stats avec l'EC `Ma communaute` sur le meme client;
  - verifier le rendu demi-page du bloc principal avec `Contacts` a cote sur desktop;
  - verifier la coherence des infos publiees en haut de bloc: `online`, photo, accroche, descriptif et liens en lignes separees;
  - verifier que `id_client`, Stripe, lien FO et lien QR agenda sont regroupes dans la zone technique;
  - verifier sur un compte TdR que les sources prioritaires LP reseau s'affichent sous le bouton affilies;
  - verifier que les blocs generiques `Informations` et `Photo` ne sont plus rendus;
  - verifier que `Remises` s'affiche sous `Offres`;
  - verifier que `Emails transactionnels`, `Equipes`, `Evenements` et `Reseau` ne sont plus rendus.

## PATCH 2026-05-20 - BO session detail: libelles id produit par jeu
- [x] Correctif livre:
  - masquage de `Id. produit` pour Quiz;
  - conservation de `Id. lots (Quiz)` quand `lot_ids` est renseigne;
  - renommage en `id.playlist` pour Blind Test;
  - renommage en `id.playlist_client` pour Bingo Musical;
  - fallback `Id. produit` conserve pour les types historiques non couverts.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/championnats/sessions/bo_module_view_top.php` OK;
  - `git -C www diff --check` OK.
- [ ] Verification recette serveur:
  - session Quiz avec `lot_ids`: absence de `Id. produit`, presence de `Id. lots (Quiz)`;
  - session Blind Test: libelle `id.playlist`;
  - session Bingo: libelle `id.playlist_client`.

## PATCH 2026-05-20 - BO session detail: participants consolides dans Resultats
- [x] Correctif livre:
  - suppression du bloc separe `Equipes participantes` / `Joueurs participants`;
  - ajout du total de participants dans le titre `Resultats`;
  - libelle du total adapte au jeu: `equipes` pour Quiz, `joueurs` pour Blind Test/Bingo.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/championnats/sessions/bo_module_aside.php` OK;
  - `git -C www diff --check` OK.
- [ ] Verification recette serveur:
  - session Quiz: verifier le total equipes dans `Resultats`;
  - session Blind Test/Bingo: verifier le total joueurs dans `Resultats`;
  - verifier que le classement complet reste present.

## PATCH 2026-05-20 - BO session detail: liens internes et logs
- [x] Correctif livre:
  - ajout d'une ligne `Logs` sous `Token`, vers `games/logs_session.html?sessionId={id_securite}`;
  - lien interne BO sur `Client` vers `entites/clients`;
  - lien interne BO sur `Offre client` vers `ecommerce/offres_clients`;
  - liens internes BO sur les noms de series Quiz du bloc `Thematique`;
  - lien interne BO sur la playlist affichee pour Blind Test/Bingo.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/championnats/sessions/bo_module_view_top.php` OK;
  - `php -l www/web/bo/www/modules/championnats/sessions/bo_module_aside.php` OK;
  - `git -C www diff --check` OK.
- [ ] Verification recette serveur:
  - session Quiz V2 multi-series: verifier chaque lien serie;
  - session Blind Test: verifier le lien playlist;
  - session Bingo: verifier le lien playlist client;
  - verifier que le lien `Logs` ouvre la page logs games avec le bon token.

## PATCH 2026-05-20 - BO session detail: photos de podium sous Informations
- [x] Correctif livre:
  - masquage du bloc `Photo` generique du master sur la fiche detail session;
  - ajout d'un bloc `Photos` dedie sous `Informations`;
  - affichage conditionnel des photos de podium remontees par `app_session_results_get_context`, avec rang, libelle et score/phase;
  - rendu des images en cartes responsives cliquables, avec hauteur stable et recadrage propre.
- [x] Verification locale:
  - `php -l www/web/bo/master/bo_master_view.php` OK;
  - `php -l www/web/bo/www/modules/championnats/sessions/bo_module_view_flags.php` OK;
  - `php -l www/web/bo/www/modules/championnats/sessions/bo_module_view_top.php` OK.
- [ ] Verification recette serveur:
  - session terminee avec photos podium dediees;
  - session terminee sans photo podium;
  - session non terminee sans podium.

## PATCH 2026-05-20 - BO session detail: bloc Informations cible
- [x] Correctif livre:
  - remplacement du bloc generique `Informations` par un bloc specifique a la fiche session;
  - masquage de `Saison`, `Ope evenement`, `Privee`, `Weblive`, `Finale`, `Session speciale`, anciens champs `App > ...` et `Info. supp.`;
  - conservation de `Id. produit`;
  - affichage de `Id. lots (Quiz)` quand `championnats_sessions.lot_ids` est renseigne;
  - renommage de `Code` en `Code session public`.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/championnats/sessions/bo_module_view_flags.php` OK;
  - `php -l www/web/bo/www/modules/championnats/sessions/bo_module_view_top.php` OK.
- [ ] Verification recette serveur:
  - session Quiz V2 avec `lot_ids`;
  - session Bingo/Blind Test sans `lot_ids`;
  - verifier que le formulaire BO reste intact.

## PATCH 2026-05-20 - BO session detail: thematique, lots, participants, podium
- [x] Correctif livre:
  - ajout du bloc `Thematique` au-dessus du bloc `Lots`;
  - affichage de chaque nom de serie Cotton Quiz quand la session contient plusieurs series;
  - bloc `Lots` aligne sur les colonnes `championnats_sessions.lot_1`, `lot_2`, `lot_3`;
  - bloc participants renomme selon le jeu: `Equipes participantes` pour Quiz, `Joueurs participants` pour Blind Test/Bingo;
  - suppression du formulaire d'ajout manuel d'equipe;
  - bloc resultats base sur `app_session_results_get_context` pour afficher podium et classement.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/championnats/sessions/bo_module_aside.php` OK.
- [ ] Verification recette serveur:
  - session Cotton Quiz V2 multi-series: verifier chaque nom de serie dans `Thematique`;
  - session Bingo/Blind Test terminee: verifier joueurs participants et podium;
  - session Quiz legacy: verifier equipes participantes et podium/classement;
  - comparer le bloc `Lots` aux colonnes `championnats_sessions.lot_1/2/3`.

## PATCH 2026-05-20 - BO Jeux: liens sessions et concordance session
- [x] Correctif livre:
  - liens `Session BO` des blocs `Sessions liees` rendus visibles sur fond clair;
  - liste BO des sessions alignee sur les donnees de session pour la resolution du jeu, en passant `lot_ids` a `app_jeu_get_detail`;
  - audit statique des ecarts fiche client / fiche session sur les informations jeux et joueurs.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/jeux/playlists/bo_playlists_view.php` OK;
  - `php -l www/web/bo/www/modules/jeux/series/bo_series_view.php` OK;
  - `php -l www/web/bo/www/modules/championnats/sessions/bo_sessions_list.php` OK.
- [ ] Verification recette serveur:
  - verifier la lisibilite des liens `Session BO` sur fiche playlist et fiche serie;
  - verifier une session Cotton Quiz V2 avec `lot_ids` contenant une serie `T`;
  - arbitrer si les compteurs fiche client doivent exclure aussi les brouillons et devenir multi-jeux pour `joueurs`.

## PATCH 2026-05-20 - BO Jeux: exclusion demos et sessions series T
- [x] Correctif livre:
  - exclusion des sessions demo (`flag_session_demo=1`) des compteurs `Passees`, `A venir`, `En cours`;
  - exclusion des sessions demo dans les blocs `Sessions liees` des fiches playlists et series;
  - compteur dashboard `sessions recentes` aligne sur les sessions non-demo;
  - rattachement des series temporaires `T` aux sessions Cotton Quiz qui les referencent dans `championnats_sessions.lot_ids`;
  - lecture des sessions `T` bornee aux series chargees pour eviter de reintroduire les sous-requetes lourdes par ligne.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/jeux/_lib/bo_jeux_readonly_lib.php` OK;
  - `php -l www/web/bo/www/modules/jeux/playlists/bo_playlists_list.php` OK;
  - `php -l www/web/bo/www/modules/jeux/playlists/bo_playlists_view.php` OK;
  - `php -l www/web/bo/www/modules/jeux/series/bo_series_list.php` OK;
  - `php -l www/web/bo/www/modules/jeux/series/bo_series_view.php` OK.
- [ ] Verification recette serveur:
  - comparer une playlist avec sessions demo connues avant/apres filtre;
  - comparer une serie classique `L` avec sessions demo connues;
  - verifier une serie temporaire `T` utilisee par une session officielle via `lot_ids`;
  - verifier que les fiches detail ne listent plus les sessions demo.

## PATCH 2026-05-19 - BO Jeux: liste playlists ergonomie
- [x] Correctif livre:
  - filtre origine par defaut sur `Cotton`;
  - compteur BO et pagination historique bases sur le filtre actif;
  - tri par en-tetes de colonnes;
  - retrait de la colonne `Usage detecte` de la liste;
  - espacement sous la barre de filtres;
  - lien liste/fiche vers la fiche PRO admin `extranet/games/library/bingo-musical/{id}`;
  - sessions de la fiche: usage lisible au lieu du type produit numerique.
- [x] Verification locale:
  - `php -l www/web/bo/www/modules/jeux/_lib/bo_jeux_readonly_lib.php` OK;
  - `php -l www/web/bo/www/modules/jeux/playlists/bo_playlists_functions.php` OK;
  - `php -l www/web/bo/www/modules/jeux/playlists/bo_playlists_list.php` OK;
  - `php -l www/web/bo/www/modules/jeux/playlists/bo_playlists_view.php` OK.
- [ ] Verification recette serveur:
  - verifier compteur `379` avec filtre Cotton par defaut;
  - tester pagination historique et tri `Publication` / `En cours`;
  - ouvrir le lien fiche PRO admin depuis liste et fiche.

## PATCH 2026-05-19 - BO Jeux: listes DB allegees
- [x] Cause identifiee:
  - les listes initiales utilisaient des sous-requetes correlees par contenu sur `championnats_sessions`;
  - sur DEV, la reponse pouvait etre interrompue pendant le rendu (`ERR_INCOMPLETE_CHUNKED_ENCODING 200`).
- [x] Correctif livre:
  - listes limitees a 50 contenus;
  - requete de base simple sur playlists / lots;
  - compteurs morceaux, questions, communaute et sessions calcules ensuite uniquement sur les IDs affiches;
  - suppression des `FIND_IN_SET` / `lot_ids` lourds dans les listes; lecture detail ciblee conservee.
- [x] Verification locale:
  - `php -l www/web/bo/bo.php` OK;
  - `php -l` sur tous les fichiers PHP `www/web/bo/www/modules/jeux` OK.
- [ ] Verification recette serveur:
  - recharger `?t=jeux&m=playlists&p=list`;
  - recharger `?t=jeux&m=series&p=list`;
  - verifier l'absence de `ERR_INCOMPLETE_CHUNKED_ENCODING`.

## PATCH 2026-05-19 - BO Jeux: correction chargement JS
- [x] Cause identifiee:
  - `bo.php` charge globalement `form-advanced.init.js`;
  - ce script appelle `$.mockjax`;
  - `jquery.mockjax.min.js` est commente dans `bo.php`, donc les pages `Jeux` levaient `$.mockjax is not a function`.
- [x] Correctif livre:
  - ne pas charger `form-advanced.init.js` quand `t=jeux`;
  - ne pas reactiver `jquery.mockjax.min.js` globalement;
  - ne pas modifier les donnees ni les modules historiques.
- [x] Verification locale:
  - `php -l www/web/bo/bo.php` OK.
- [ ] Verification recette serveur:
  - recharger `?t=jeux&m=playlists`;
  - recharger `?t=jeux&m=series`;
  - verifier que l'erreur console `$.mockjax is not a function` a disparu.

## PATCH 2026-05-19 - BO Jeux V1 lecture seule
- [x] Correctif livre:
  - ajout de l'entree BO `Jeux` reservee aux super-admins;
  - conservation des menus historiques `Bingo` et `App.`;
  - dashboard avec acces Playlists musicales / Series Cotton Quiz;
  - listes et fiches detail en lecture seule pour playlists musicales et series Quiz `L`/`T` quand disponibles;
  - affichage des sessions liees avec separation passee / a venir / en cours detectee par date;
  - liens vers sessions BO et ecran playlist historique quand disponible.
- [x] Garde-fous V1:
  - aucune suppression;
  - aucune activation/desactivation;
  - aucune edition profonde;
  - aucun import;
  - aucune action groupee.
- [x] Verification locale:
  - `php -l www/web/bo/bo.php` OK;
  - `php -l` sur tous les fichiers PHP `www/web/bo/www/modules/jeux` OK;
  - controle statique des menus `Bingo`, `App.` et `Jeux` OK;
  - controle statique absence d'action sensible exposee OK.
- [ ] Verification recette serveur:
  - charger `?t=jeux&m=dashboard`;
  - charger les listes playlists et series;
  - ouvrir au moins une fiche playlist;
  - ouvrir au moins une fiche serie Quiz;
  - comparer les compteurs sessions avec quelques contenus connus;
  - verifier qu'aucun bouton de modification n'apparait dans la V1.

## PATCH 2026-05-18 - Catalogue Quiz: difficulte 3 niveaux harmonisee Pro
- [x] Cause identifiee:
  - le catalogue public Cotton Quiz doit rester aligne avec la convention Pro 3 niveaux;
  - les series creees depuis le select Pro recent utilisent deja `1`, `2`, `3`.
- [x] Correctif livre:
  - ajout d'une normalisation FO commune dans `www/web/fo/modules/jeux/fo_catalogue_featured_lib.php`;
  - la carte catalogue Quiz et la fiche serie Quiz utilisent `1=Facile`, `2=Moyen`, `3=Difficile`;
  - les anciennes valeurs `4` ou `5` sont temporairement affichees `Difficile` avant migration legacy;
  - Blind Test et Bingo Musical conservent leur cotation directe `1..3` avec fallback defensif sur `Facile`.
- [x] Verification locale:
  - `php -l www/web/fo/modules/jeux/fo_catalogue_featured_lib.php` OK;
  - `php -l www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_catalogue_list_bloc.php` OK;
  - `php -l www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_catalogue_view.php` OK.
- [ ] Verification recette serveur:
  - verifier une serie Quiz stockee `difficulte=2`: affichage public `Moyen`;
  - verifier une serie Quiz stockee `difficulte=3`: affichage public `Difficile`;
  - verifier une ancienne serie Quiz `difficulte=4` ou `5`: fallback public `Difficile`;
  - comparer avec la fiche et l'editeur EC Pro.

## PATCH 2026-05-18 - Catalogues publics alignes sur `A la une` EC Pro
- [x] Audit cible:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - `www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_catalogue_list.php`
  - `www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_catalogue_list.php`
  - `www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_catalogue_list.php`
- [x] Correctif livre:
  - ajout du helper public commun `www/web/fo/modules/jeux/fo_catalogue_featured_lib.php`;
  - les pages catalogue publiques affichent 12 contenus `A la une` par jeu;
  - la priorite est: contenu du moment via `jour_associe_debut/fin`, creation recente dans ce groupe, popularite 365 jours par jeu si disponible, puis `id DESC`;
  - la popularite reste differenciee par `game` (`cotton-quiz`, `blind-test`, `bingo-musical`) et `content_type`;
  - les listes par rubrique conservent leur filtre historique.
- [x] Verification locale:
  - `php -l www/web/fo/modules/jeux/fo_catalogue_featured_lib.php`
  - `php -l www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_catalogue_list.php`
  - `php -l www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_catalogue_list.php`
  - `php -l www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_catalogue_list.php`
- [ ] Verification recette serveur:
  - verifier les 12 cartes sur chaque catalogue public;
  - verifier que Blind Test et Bingo Musical peuvent diverger selon la popularite par jeu;
  - verifier une periode avec contenus `jour_associe_debut/fin` actifs.

## PATCH 2026-05-18 - Demos LP reseau avec `return_url`
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_script.php`
  - `www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_script.php`
  - `www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_script.php`
- [x] Correctif livre:
  - les trois scripts demo ajoutent `?return_url=...` au lien `/master/{token}` quand le helper global fournit une LP de retour;
  - les formulaires LP existants continuent de porter `lp_demo_context` et `lp_network_slug`;
  - aucune modification du JS de soumission des formulaires demo.
- [x] Verification locale:
  - `php -l www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_script.php`
  - `php -l www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_script.php`
  - `php -l www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_script.php`
- [ ] Verification recette serveur:
  - demo Quiz / Blind Test / Bingo depuis LP reseau;
  - fermeture organizer par `Quitter le jeu`;
  - retour attendu sur la LP source.

## PATCH 2026-05-18 - Rendu hero LP reseau non recadrant
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livre:
  - ajout de la classe `lp-operation-hero-visual` sur l'image hero LP reseau/operation;
  - la classe conserve le ratio source avec `object-fit: contain`, `height:auto`, `max-width:100%`;
  - la hauteur est bornee via `max-height: min(46vh, 420px)` pour eviter qu'un visuel atypique casse le hero.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`
- [ ] Verification recette serveur:
  - LP reseau avec visuel `1600 x 900` re-uploade;
  - LP reseau avec ancien visuel WebP;
  - desktop large et mobile.

## PATCH 2026-05-14 - BO contrats reseau offres hors cadre
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - l'action BO `activer_affilie` lit maintenant le retour structure global;
  - en attribution forcee hors cadre, le succes repose sur `ok=1` et `id_offre_client_deleguee > 0`, afin de ne plus transformer une creation reussie en `action_error`;
  - ajout de l'action dediee `terminer_offre_hors_cadre`, separee de `desactiver_affilie` et de `supprimer_affiliation`;
  - la liste affiche `Terminer l'offre hors cadre` uniquement pour `offre_deleguee_hors_cadre`;
  - `Desactiver` reste reserve aux offres incluses/cadre;
  - `Supprimer l'affiliation` conserve son role de detachement reseau.
- [x] Garde-fous:
  - l'offre cible doit etre active, appartenir au siege, cibler l'affilie, etre un catalogue hors cadre autorise et ne pas etre liee a un support reseau;
  - refus si l'offre est deja terminee, cadre/incluse, non courante, non rattachee au bon affilie ou risque d'offre propre.
- [x] Verification locale:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [ ] Verification recette serveur:
  - reseau sans abonnement actif: attribution hors cadre sans `action_error`;
  - terminaison hors cadre sans supprimer l'affiliation;
  - offre propre non terminable par l'action hors cadre;
  - incluse/cadre encore desactivable par le flux cadre;
  - comparaison avec commande hors cadre PRO TdR.

## PATCH 2026-05-13 - LP reseau mention connexion compte existant
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
  - `pro/web/.htaccess`
  - `pro/web/ec/ec_sign.php`
- [x] Correctif livre:
  - le CTA principal final des LP reseau/operation reste pointe vers `/utm/reseau/{slug}`;
  - une mention secondaire est ajoutee sous le CTA final uniquement en contexte LP reseau/operation;
  - le lien `Connecte-toi` pointe vers `/utm/reseau/{slug}/signin`, qui pose le meme contexte d'affiliation puis redirige vers `signin`;
  - aucun changement des pages `ec_signup.php` / `ec_signin.php`, des wordings LP principaux, des badges, stats ou demos.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`
  - `php -l pro/web/ec/ec_sign.php`
- [ ] Verification recette serveur:
  - LP reseau sans abonnement actif: CTA signup inchange et lien signin contextualise;
  - LP reseau avec abonnement actif: CTA signup inchange et lien signin contextualise;
  - LP operation/slug specifique: slug TdR conserve;
  - LP standard hors reseau: mention absente;
  - mobile: mention lisible et lien facilement cliquable.

## PATCH 2026-05-13 - LP reseau header preuve sociale centre
- [x] Audit cible:
  - `www/web/lp/includes/css/lp_custom.css`
  - `www/web/lp/lp.php`
- [x] Correctif livre:
  - le header du bloc preuve sociale LP reseau est centre;
  - l'espace entre le sur-titre `{TdR} x Cotton depuis YYYY` et le titre principal est reduit;
  - changement limite au CSS scope `.lp-operation-proof-header`, sans toucher aux donnees ni a la logique d'affichage.
- [ ] Verification recette serveur:
  - verifier LP reseau avec bloc preuve sociale sur desktop et mobile.

## PATCH 2026-05-13 - BO TdR preview assets et Online
- [x] Audit cible:
  - `www/web/bo/master/bo_master_form.php`
  - `www/web/bo/www/modules/entites/clients/bo_module_parametres.php`
  - `global/web/lib/core/lib_core_module_functions.php`
- [x] Correctif livre:
  - les inputs masques `files_lp_logo` et `files_lp_hero` mettent a jour l'apercu existant des qu'un nouveau fichier image est selectionne;
  - le statut sous l'apercu indique le nom du fichier selectionne et le besoin d'enregistrer;
  - le formulaire detecte les champs principaux deja rendus par le module (`online`, `flag_une`);
  - le bloc complementaire `Caractéristiques` ne rend plus `On / Off` si le champ `online` existe deja dans `Informations`, ce qui supprime les doublons d'id/name.
- [x] Verification locale:
  - `php -l www/web/bo/master/bo_master_form.php`.
- [ ] Verification recette serveur:
  - verifier remplacement logo/hero depuis clic sur apercu;
  - verifier que le nouveau preview s'affiche avant sauvegarde;
  - verifier sauvegarde `Online` coche/de-coche avec un seul champ visible;
  - verifier que `A la une` reste disponible si non rendu par le module principal.

## PATCH 2026-05-13 - BO TdR assets LP reseau edition
- [x] Audit cible:
  - `www/web/bo/master/bo_master_form.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `global/web/lib/core/lib_core_module_functions.php`
- [x] Correctif livre:
  - le BO fiche client/TdR masque les dropzones `Logo LP reseau` et `Visuel principal LP reseau` quand un asset prioritaire existe deja;
  - les apercus existants deviennent cliquables pour remplacer le fichier par un nouvel upload;
  - le visuel principal affiche une recommandation editoriale 16:9 / 1600 x 900 px, sans changer le traitement serveur 1200 x 480 compatible avec le visuel de design reseau;
  - les checkbox complementaires `On / Off` et `A la une` portent maintenant explicitement `value="1"` tout en conservant le save canonique `module_modifier()`.
- [x] Verification locale:
  - `php -l www/web/bo/master/bo_master_form.php`.
- [ ] Verification recette serveur:
  - fiche TdR sans assets: verifier dropzones visibles;
  - fiche TdR avec logo/hero: verifier apercus cliquables et remplacement;
  - verifier suppression asset via checkbox;
  - verifier sauvegarde `On / Off` et `A la une` coche/de-coche.

## PATCH 2026-05-13 - LP reseau preuve sociale date TdR et micro UI
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
  - `documentation/canon/data/schema/DDL.sql`
- [x] Correctif livre:
  - le sur-titre du bloc preuve sociale affiche maintenant `{Nom_TdR} x Cotton depuis YYYY` quand `clients.date_ajout` est exploitable;
  - aucune requete supplementaire: la date vient du detail TdR deja charge via `app_client_get_detail(...)`;
  - les pictogrammes sont recentres optiquement dans leur pastille;
  - les cartes passent a une largeur homogene de 252px et les libelles courts ne passent plus a la ligne.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`.
- [ ] Verification recette serveur:
  - verifier TdR avec date creation valide, TdR avec date absente/invalide, desktop et mobile.

## PATCH 2026-05-13 - LP reseau bloc preuve sociale largeur adaptive
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
- [x] Correctif livre:
  - ajout d'une classe `lp-operation-proof-count-{n}` sur le bloc stats;
  - largeur du panneau, nombre de colonnes et largeur des cartes pilotes selon 1, 2 ou 3 indicateurs;
  - reutilisation du fond `--lp-operation-soft-bg`, deja utilise par les cartes demos reseau;
  - cartes blanches plus sobres avec bordure/ombre adoucies et pictogrammes en pastille legere;
  - espacement haut/bas resserre sans modifier les donnees, seuils, libelles, CTA ou logique d'affichage.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`.
- [ ] Verification recette serveur:
  - verifier 3 indicateurs, 2 indicateurs, 1 indicateur fort, et aucun bloc stats;
  - verifier desktop large et mobile.

## PATCH 2026-05-12 - LP reseau bloc preuve sociale UI
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
- [x] Correctif livre:
  - presentation du bloc preuve sociale sous forme de cartes statistiques;
  - ajout de pictogrammes SVG par type d'indicateur, bornes a 24px pour eviter les styles globaux;
  - panneau central plus compact et padding haut reduit pour rapprocher le bloc des demos;
  - labels courts: `Etablissements affilies`, `Sessions programmees`, `Joueurs accueillis`;
  - grille desktop adaptee a 1, 2 ou 3 indicateurs et pile mobile lisible;
  - aucune modification des donnees, seuils, requetes, CTA, dates ou position du bloc.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - `git diff --check` dans `www`.
- [ ] Verification recette serveur:
  - verifier 3 indicateurs, 2 indicateurs, 1 indicateur fort, et aucun bloc stats;
  - verifier desktop large et mobile.

## PATCH 2026-05-12 - LP reseau bloc preuve sociale
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livre:
  - ajout d'un bloc de reassurance sous les demos de la LP reseau/operation;
  - le bloc affiche `{Nom_TdR} x Cotton`, `Le reseau s'anime deja avec Cotton` et jusqu'a 3 indicateurs;
  - affichage conditionne aux seuils serveur: au moins 2 indicateurs valorisants, ou 1 indicateur tres fort;
  - seuils affichables documentes cote `global`: affilies >= 3, sessions >= 5, joueurs >= 100;
  - signaux forts documentes cote `global`: affilies >= 20, sessions >= 50, joueurs >= 1000;
  - aucun compteur a 0 ni bloc generique vide n'est rendu.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - `php -l global/web/app/modules/entites/clients/app_clients_functions.php`.
- [ ] Verification recette serveur:
  - tester TdR sous seuils, deux indicateurs OK, un indicateur tres fort, agregat joueurs absent/vide.

## PATCH 2026-05-12 - LP reseau logos hero alignes
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
- [x] Correctif livre:
  - les logos hero LP reseau/operation sont alignes a gauche au-dessus du badge periode/statut;
  - les pastilles logo partenaire et Cotton sont agrandies sur desktop et mobile;
  - le badge periode/statut demarre sur sa propre ligne sous les logos en conservant une largeur adaptee au texte;
  - le badge hero n'est plus affiche pour les statuts generiques sans dates;
  - les routes, CTA et calculs d'abonnement restent inchanges.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - `git diff --check` dans `www` et `documentation`.
- [ ] Verification recette serveur:
  - verifier LP avec logo partenaire et LP fallback Cotton seul;
  - verifier badge dates et badge `Animation cle en main`;
  - verifier desktop/mobile.

## PATCH 2026-05-12 - LP reseau couleurs dediees TdR
- [x] Audit confirme dans:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
  - `www/web/bo/master/bo_master_form.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - page Pro design reseau `pro/web/ec/modules/general/branding/*`
- [x] Correctif livre:
  - ajout de deux champs BO dedies: couleur principale LP reseau et couleur secondaire LP reseau;
  - UX coherente avec Pro: input couleur, champ hex et apercu synchronise;
  - sauvegarde via helpers globaux avec normalisation `#RRGGBB`;
  - lecture LP prioritaire et exposition CSS `--lp-network-primary` / `--lp-network-secondary`;
  - si les assets/couleurs LP dedies sont absents, la LP retombe sur les fallbacks Cotton sans reprendre le logo, le visuel ou les couleurs du design reseau;
  - aucune modification des routes, CTA, badges ni logique de dates.
- [ ] Verification recette serveur:
  - TdR avec couleurs LP: verifier le hero, le CTA visuel, les accents et le footer;
  - TdR sans couleurs LP: verifier le fallback Cotton;
  - couleur invalide postee: verifier non persistance / neutralisation.
- [ ] Amelioration future:
  - prelevement couleur depuis logo/visuel LP si un composant image/pipette est cree ou importe plus tard.

## PATCH 2026-05-11 - LP reseau fallback demos a la une
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - logique bibliotheque PRO `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - listes FO historiques `pro/web/fo/modules/jeux/*/*_list.php` et catalogues publics des jeux
- [x] Correctif livre:
  - priorite des contenus reseau conservee via `lp_operation_network_demo_catalogue_get()`;
  - si aucun contenu reseau actif n'est partage, la LP choisit 1 demo Blind Test, 1 demo Bingo Musical et 1 demo Cotton Quiz depuis les contenus Cotton `A la une`;
  - ordre de choix aligne avec la bibliotheque EC: fenetre `jour_associe_debut/fin` en priorite, sans dependance a `flag_begin` ni `flag_une`; entre contenus simultanement du moment, departage par creation recente; hors periode, tri popularite 365 jours si la table reporting existe, sinon tri stable par date/id;
  - fallback robuste sur les IDs historiques existants `29 / 106 / 175` si table, colonne, helper ou requete indisponible;
  - aucune dependance directe au module PRO de bibliotheque.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`.
- [ ] Verification recette serveur:
  - LP reseau avec contenus partages: verifier que seuls les contenus reseau restent visibles;
  - LP reseau sans contenus partages: verifier les 3 demos choisies et les noms/images affichees;
  - verifier qu'une serie datee `jour_associe_debut/fin` mais sans `flag_begin` ni `flag_une` peut etre choisie;
  - verifier une periode sans thematique datee exploitable.

## PATCH 2026-05-11 - LP reseau rattachement demos TdR
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - scripts demo FO Blind Test, Bingo Musical, Cotton Quiz
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - resolution branding Canvas via session `id_client`
- [x] Correctif livre:
  - les formulaires demo de LP reseau/operation ajoutent uniquement un contexte public: type LP + slug canonique TdR;
  - les scripts demo resolvent ce slug cote serveur vers un compte TdR valide avant creation;
  - hors contexte LP reseau/operation, les demos gardent le compte standard `1557`;
  - les sessions creees restent des sessions demo privees/non officielles/non facturables;
  - le rattachement au compte TdR laisse la resolution branding existante appliquer le branding reseau quand il existe.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - `php -l www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_script.php`;
  - `php -l www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_script.php`;
  - `php -l www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_script.php`;
  - `php -l global/web/app/modules/jeux/sessions/app_sessions_functions.php`.
- [ ] Verification recette serveur:
  - LP avec jeux reseau, fallback `A la une`, fallback stable: session `championnats_sessions.id_client` = id TdR;
  - LP avec design reseau: organizer reprend le branding reseau;
  - page demo/catalogue hors LP: session demo conserve `id_client=1557`.

## PATCH 2026-05-11 - UI branding LP reseau / operation
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
- [x] Correctif livre:
  - co-branding hero `[logo partenaire] x [logo Cotton]` en petites pastilles separees quand un logo LP dedie existe, fallback Cotton seul reduit;
  - bandeau 3 arguments sur teinte claire derivee des couleurs LP dediees, fallback blanc sans couleurs LP, avec tutoiement du premier argument;
  - bloc contexte masque si la surcouche BO active n'apporte aucun contenu/logo LP/visuel LP exploitable;
  - retrait du fallback public automatique sur description TdR/generique pour le bloc contexte;
  - carte contexte plus lisible avec label `Invitation partenaire`, accent couleur LP, logo LP ou visuel LP existant;
  - accents couleur LP appliques aux titres de section et numeros du mode d'emploi;
  - CTA final conserve, avec bouton toujours calcule selon contexte.
- [x] Contraintes respectees:
  - aucun nouveau champ BO;
  - aucune migration DB;
  - aucun changement de route, CTA href, formulaire demo ou logique d'affiliation;
  - patch CSS limite, sans refonte lourde.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - grep des fallbacks generiques du bloc contexte et des textes cibles sur `www/web/lp/lp.php` / CSS.
- [ ] Verification recette serveur:
  - LP sans surcouche BO active: bloc contexte masque;
  - LP avec surcouche active et contenus: bloc contexte affiche et lisible;
  - LP avec/sans logo partenaire;
  - actif avec dates, inactif, jeux reseau et fallback 3 jeux;
  - desktop/mobile.

## PATCH 2026-05-11 - Passe editoriale LP reseau / operation
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/lp/includes/css/lp_custom.css`
- [x] Correctif livre:
  - hero actif recentre sur l'invitation a animer l'etablissement, CTA `Lancer une premiere animation`;
  - hero inactif recentre sur l'espace d'animation partenaire, CTA `Participer avec mon etablissement`;
  - badges fallback ajustes en `Animations incluses` et `Invitation partenaire`, sans changer les badges dates;
  - fallback du bloc contexte reformule autour du dispositif plutot que de Cotton comme sujet principal;
  - section demos reformulee autour des animations proposees/pretes a lancer, CTA `Voir une animation exemple`;
  - modale mobile passee au tutoiement et HTML du mode d'emploi corrige pour eviter un paragraphe imbrique;
  - CTA final remplace par `Pret a participer ?` avec phrase courte dediee sur les LP reseau/operation.
- [x] Contraintes respectees:
  - aucun nouveau champ BO;
  - aucune migration DB;
  - aucun changement de route, de formulaire demo, de lien CTA ou de logique d'affiliation;
  - pas de refonte CSS necessaire.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - recherche des anciens wordings publics cibles dans `www/web/lp/lp.php` et `www/web/lp/includes/css/lp_custom.css`.
- [ ] Verification recette serveur:
  - tester une LP active avec date fin, active sans date fiable, inactive, avec/sans surcouche BO, avec jeux reseau et fallback 3 jeux;
  - verifier desktop/mobile, notamment H1, badge, CTA, section demos et CTA final.

## PATCH 2026-05-11 - LP reseau / abonnement reseau
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
- [x] Correctif livre:
  - retrait du verrou `clients.online` dans la resolution LP reseau; la V1 publie toute TdR existante avec slug canonique valide;
  - CTA LP reconstruit depuis le slug canonique TdR resolu vers `/utm/reseau/{slug}`;
  - textes par defaut LP reseau realignes marketing Cotton: `Invitation Cotton` / `Rejoindre Cotton ->` sans abonnement actif ni promesse gratuite/offerte, et `Jeux Cotton offerts` / `Profiter de mes jeux ->` uniquement quand un abonnement reseau actif existe;
  - hero non personnalisable par les champs BO: les champs abonnement reseau actifs alimentent seulement le bloc contexte sous le bandeau 3 arguments;
  - structure publique forcee: hero, bandeau 3 arguments, bloc contexte, puis jeux reseau ou fallback 3 jeux historiques;
  - badge hero branche sur la couleur secondaire reseau avec contraste texte automatique si design reseau disponible;
  - suppression du bloc explicatif technique public `Le parcours suivant conserve...`;
  - fallback couleurs/visuel aligne sur les LP historiques quand aucun design reseau n'existe;
  - titre BO du bloc LP corrige en `Contexte affiche sur la LP reseau`, champs CTA personnalises retires de l'edition/lecture, slug public conserve comme non exploite V1.
- [x] Verification locale:
  - `php -l www/web/lp/lp.php`;
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`;
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`;
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`;
  - `rg -n "LE RÉSEAU|L’OPÉRATION|Le parcours suivant|Rejoignez Cotton avec votre réseau|abonnement inclus|Libellé CTA|RÃ|Ã©|Ã¨|Ãª" www/web/lp www/web/bo/www/modules/ecommerce/offres_clients` OK;
  - `git diff --check` sur `www` et `documentation`.
- [ ] Verification recette serveur:
  - inspecter le href CTA sur `/lp/reseau/{slug_tdr}` et `/lp/operation/{slug}`;
  - cliquer le CTA et confirmer le parcours PRO signup/signin sans retour home pour slug TdR valide.

## PATCH 2026-05-06 — FO parcours demos catalogue
- [x] Audit cible:
  - `www/web/fo/modules/widget/fr/fo_widget_cotton_jeux_blocs.php`
  - `www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_catalogue_view.php`
  - `www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_catalogue_view.php`
  - `www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_catalogue_view.php`
  - `www/web/fo/modules/jeux/portail/fr/fo_portail_jeux_demo_signup.php`
- [x] Correctif livre:
  - sur `/fr/jeux`, les CTA principaux des trois cartes sont libelles `Démos du jeu` et pointent vers les catalogues existants;
  - un lien secondaire discret `Découvrir le jeu` conserve l'acces aux pages de presentation;
  - correctif addendum: le partial `fo_demo_choice.php` a ete retire au profit du partial prod recharge `fo_portail_jeux_demo_signup.php`;
  - `Démo complète` reste prioritaire avec le badge `Recommandé`;
  - Cotton Quiz reutilise le partial commun, sans ajouter de CTA `Je commande` actif la ou Blind Test et Bingo Musical n'en affichent pas;
  - seul le wording de presentation de la demo rapide est ajuste en desktop/mobile;
  - la modale mobile redondante du partial commun est retiree: le CTA mobile de demo rapide lance directement la demo.
- [x] Ajustements UX cibles:
  - le lien secondaire `Découvrir le jeu` des cartes `/fr/jeux` est replace a cote du CTA `Démos du jeu`, avec hover souligne et colore par jeu;
  - la mention `NEW ! Testez la nouvelle version du Cotton Quiz !` est retiree de la fiche detail Cotton Quiz alignee sur le widget demo;
  - le micro-texte mobile de demo rapide devient `Pour plus de confort, teste aussi depuis un ordinateur.` avec interligne compact.
- [x] Verification:
  - `php -l web/fo/modules/jeux/portail/fr/fo_portail_jeux_demo_signup.php`
  - `php -l web/fo/modules/jeux/blind_test/fr/fo_blind_test_catalogue_view.php`
  - `php -l web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_catalogue_view.php`
  - `php -l web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_catalogue_view.php`
  - `php -l web/fo/modules/widget/fr/fo_widget_cotton_jeux_blocs.php`

## PATCH 2026-04-17 — FO pages statiques 2026: icones Bootstrap restaurees
- [x] Audit cible:
  - `www/web/fo/fo.php`
  - references relues:
    - `www/web/fo/modules/communication/statique/fr/fo_statique_cible_bars.php`
    - `www/web/fo/modules/communication/statique/fr/fo_statique_features_presentation_generale.php`
    - journal AI Studio `www/web/fo/*` + reload prod des templates/assets statiques 2026
- [x] Cause confirmee:
  - les nouvelles pages statiques `solutions/*` et `decouvrir*` utilisent des classes `Bootstrap Icons` (`bi ...`);
  - leurs assets etaient bien presents, mais le layout global FO ne chargeait plus la feuille `bootstrap-icons.css`;
  - dans ce repo, la dependance ne restait chargee que localement par `fo_widget_cotton_arguments.php`, ce qui ne couvrait pas les nouveaux templates statiques.
- [x] Correctif livre:
  - ajout du chargement global `bootstrap-icons.css` dans `www/web/fo/fo.php`;
  - les icones `bi` des nouvelles pages statiques repartent donc sans patch page par page.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/fo/fo.php`

## PATCH 2026-04-17 — FO sessions / fiche `place`: ex aequo affiches dans un ordre stable
- [x] Audit cible:
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - dependance relue:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - les podiums FO re-triaient encore certaines lignes ex aequo par `rang` seul;
  - cet ordre n'etait pas stable et pouvait diverger du tableau de classement complet ou du socle partage.
- [x] Correctif livre:
  - la fiche session FO et les podiums de la fiche `place` utilisent maintenant un tri stable `rang puis position source`;
  - elles preservent donc le meme ordre entre ex aequo que celui fourni par le backend partage.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## PATCH 2026-04-16 — FO fiche `place`: badges couleurs sur les titres de jeux des classements
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - référence relue:
    - `pro/web/ec/modules/compte/joueurs/ec_joueurs_shared.php`
- [x] Cause confirmée:
  - l'onglet `Classements` de la fiche `place` gardait des titres de jeux en texte simple;
  - l'interface n'etait plus cohérente avec les badges de jeu déjà utilisés dans `pro` et `play`.
- [x] Correctif livré:
  - ajout de helpers locaux `badge class/style` côté `www`;
  - chaque bloc leaderboard affiche maintenant son jeu dans un badge colore, avec periode conservee a cote.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## PATCH 2026-04-16 — FO fiche `place`: CTA agenda d'accès direct restauré sur entrée QR
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - référence relue:
    - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
- [x] Cause confirmée:
  - la logique historique du CTA `Je participe` dépendait de la présence de `code_client`;
  - la nouvelle fiche `place` hydrate l'agenda via un endpoint AJAX qui ne transmettait plus ce contexte, donc le renderer agenda ne pouvait plus savoir qu'il devait afficher l'accès direct joueur.
- [x] Correctif livré:
  - l'URL AJAX de la fiche `place` retransmet maintenant `code_client` quand l'entrée vient d'un QR code lieu;
  - l'endpoint AJAX expose ce contexte au renderer agenda;
  - les cartes de sessions à venir réaffichent `J'accède au jeu` uniquement dans ce cas;
  - dans ce même contexte QR, le CTA public secondaire vers la fiche détail de session n'est plus rendu.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`

## PATCH 2026-04-15 — FO fiche `place`: spinner aussi sur l'onglet `Agenda`
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
- [x] Cause confirmee:
  - la fiche `place` affichait deja un spinner sur `Classements` et `Sessions passées`, mais `Agenda` restait sur un simple texte de chargement;
  - le besoin retenu est d'harmoniser les trois onglets dynamiques avec le meme retour visuel.
- [x] Correctif livre:
  - l'onglet `Agenda` reutilise maintenant le meme loader spinner que `Classements` et `Sessions passées`;
  - le spinner est present dans le placeholder initial et lors du chargement AJAX de l'onglet.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PATCH 2026-04-15 — FO fiche `place`: entrée QR code force `Agenda`
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_seo.php`
  - `www/web/fo/fo.php`
- [x] Cause confirmee:
  - la refonte récente des onglets `place` a laissé `Classements` comme onglet actif par défaut;
  - lors d'une entrée via `QR code` (`/place/{code_client}`), ce choix n'est pas cohérent avec l'intention produit, qui est d'amener d'abord l'utilisateur vers les prochaines sessions.
- [x] Correctif livre:
  - la vue `place` détecte désormais l'entrée QR via `code_client`;
  - sans onglet explicitement demandé en querystring, elle force alors l'onglet actif initial sur `agenda`;
  - la vue publique SEO `/fr/place/{seo_slug}` garde son défaut actuel sur `classements`.
  - addendum perf:
    - l'entrée `QR code` positionne aussi un garde pour désactiver le preload image global FO;
    - cela supprime le warning navigateur sur `branding-client-default.jpg`, image non utilisée quand la galerie hero est masquée sur la vue QR.
  - addendum JS:
    - le boot de la page ne dépend plus de la présence des boutons d'onglets pour charger `Agenda`;
    - sur entrée QR, il relit maintenant directement l'onglet actif initial calculé côté PHP, ce qui évite un spinner d'agenda bloqué quand la nav d'onglets est volontairement masquée.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_seo.php`
  - `php -l /home/romain/Cotton/www/web/fo/fo.php`

## PATCH 2026-04-15 — FO fiche `place`: spinner aussi sur le chargement des sessions passées
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
- [x] Cause confirmee:
  - l'onglet `Classements` affichait deja un petit spinner pendant le chargement AJAX;
  - l'onglet `Sessions passées` utilisait seulement un texte de chargement, sans retour visuel coherent avec le reste de la fiche `place`.
- [x] Correctif livre:
  - le loader AJAX de `Sessions passées` reutilise maintenant le meme pattern `spinner-border spinner-border-sm color-4` que `Classements`;
  - le message reste `Chargement des sessions passées en cours...`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PATCH 2026-04-15 — FO fiche detail session: etat `terminee` aligne sur `pro`
- [x] Audit cible:
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - dependances relues:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Cause confirmee:
  - la fiche detail FO decidait encore son etat uniquement via `app_session_get_chronology($date)`;
  - une session cloturee le jour meme pouvait donc rester rendue comme session en cours/carte descriptive, alors que `pro` l'affichait deja comme archivee avec resultats.
- [x] Correctif livre:
  - la fiche detail FO s'aligne maintenant sur `app_session_display_chronology_get(..., app_session_edit_state_get(...))`;
  - podium et classement deviennent visibles des la cloture metier de la session, avec le meme contrat d'etat que `pro`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`

## PATCH 2026-04-14 — FO fiche `place`: `Top 10` public uniquement
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- [x] Cause confirmée:
  - l'onglet public `Classements` rendait directement tous les rangs calculés pour chaque jeu;
  - le besoin produit retenu pour `www/place` n'est finalement pas un toggle public vers le complet, mais une lecture simple strictement bornée au `Top 10`.
- [x] Correctif livré:
  - la fiche `place` affiche maintenant seulement le `Top 10` par jeu;
  - le sous-titre public est fixé à `Top 10`;
  - aucun CTA `Afficher le classement complet` / `Replier le classement` n'est conservé côté FO;
  - l'ordre d'affichage public des blocs est maintenant `Blind Test`, puis `Bingo Musical`, puis `Cotton Quiz`;
  - le sélecteur de saison continue de recharger ces `Top 10` en AJAX;
  - si les 3 onglets `Classements`, `Agenda` et `Sessions passées` sont tous vides, la section complète est masquée côté FO.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PATCH 2026-04-14 — FO liste `place`: départements réellement présents + tri par activité
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_list.php`
- [x] Cause confirmée:
  - le filtre département listait tout le référentiel, y compris des zones sans organisateur public;
  - les cartes organisateurs étaient encore triées par `id`, sans faire ressortir les lieux les plus actifs.
- [x] Correctif livré:
  - le sélecteur `Département` ne garde plus que les départements réellement présents dans la liste publique;
  - l'option `Tous` renvoie maintenant vers `/fr/place` et non vers `/fr/agenda`;
  - la liste organisateurs est maintenant triée par activité agrégée côté SQL:
    - `sessions_total` décroissant
    - `latest_session_date` décroissante
    - `nom` croissant
  - ce tri repose sur une seule agrégation SQL globale jointe à la liste publique, sans calcul lourd par carte.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_list.php`

## PATCH 2026-04-14 — BO réseau: suppression d'affiliation TdR depuis le pilotage affiliés
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - dépendance relue:
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause confirmée:
  - le BO réseau permettait déjà d'activer, désactiver et reclasser un affilié, mais pas de casser proprement son rattachement à la TdR quand le compte sort du réseau;
  - sans cette action BO, un compte restait avec `clients.id_client_reseau > 0`, donc continuait d'être exclu du scope `Remises 2026`.
- [x] Correctif livré:
  - le tableau `Affiliés du siège` expose maintenant un CTA `Supprimer l'affiliation` dans la colonne `Action`;
  - l'action est livrée uniquement côté BO `reseau_contrats`, sans exposition côté PRO;
  - le write path appelle le helper métier `client_affilier(0, ...)` pour remettre `id_client_reseau` à `0`;
  - la sortie du réseau déclenche aussi la reclassification des délégations du siège concerné via le helper existant, pour rester cohérent avec les autres chemins BO de changement d'affiliation.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`

## PATCH 2026-04-14 — FO fiche `place`: suppression du calcul historique complet au premier hit
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Extension livrée:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
- [x] Cause confirmée:
  - la fiche publique `place` appelait le même helper que `Mes joueurs` (`app_client_joueurs_dashboard_get_context(...)`);
  - sans cache de session déjà chaud, ce helper recalculait tout l'historique organisateur (`sessions_scope = all`) alors que la page n'affiche que les leaderboards de la saison courante.
- [x] Correctif livré:
  - ajout d'un helper dédié `app_client_joueurs_dashboard_get_context_fo_place(...)`;
  - ce helper charge directement le contexte filtré saison courante pour les leaderboards publics;
  - la synthèse historique haute n'est plus recalculée sur la fiche publique: elle n'est réinjectée que si le cache journalier de session existe déjà;
  - `fo_clients_view.php` est branché sur ce nouveau helper léger;
  - la page publique rend désormais un shell rapide puis hydrate en AJAX:
    - la synthèse haute;
    - le bloc `Classements`;
  - le bloc `Classements` réintroduit un sélecteur de saison directement dans son titre;
  - ce sélecteur recharge uniquement les leaderboards demandés, avec saisons exploitables récentes triées du plus récent au plus ancien.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PATCH 2026-04-14 — FO fiche `place`: onglet `Classements` multi-jeux sur saison courante
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - dépendances relues:
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- [x] Cause confirmée:
  - la fiche `place` utilisait déjà le moteur global `Mes joueurs`, mais son onglet public continuait d'afficher un ancien `Classement Quiz` local, multi-saisons et non aligné sur les nouvelles règles de saison courante;
  - `pro/play` exposaient déjà la vérité métier attendue: un classement distinct par jeu seulement si des sessions réellement exploitables existent sur la période.
- [x] Correctif livré:
  - l'onglet public devient `Classements`;
  - `fo_clients_view.php` affiche maintenant un bloc par jeu disponible sur la saison courante (`Cotton Quiz`, `Blind Test`, `Bingo Musical`);
  - le tableau conserve le style historique du classement quiz pour chaque jeu, avec colonnes `rang / entité / points / participations`;
  - le libellé de période affiché dans chaque bloc est simplifié au format `Jeu · Avril-Juin 2026`;
  - la colonne droite réutilise le moteur global de résultats de session pour afficher les dernières sessions classées, avec photo gagnant quand elle existe;
  - chaque bloc session de droite renvoie maintenant vers la fiche détail publique de la session;
  - le nombre de cartes affichées à droite n'est plus borné par un plafond fixe; il est maintenant calculé selon la hauteur théorique du classement pour mieux utiliser l'espace disponible;
  - un jeu sans sessions classables sur la saison courante n'est plus affiché.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`

## PATCH 2026-04-14 — BO `Remises 2026`: ajout en masse figé depuis la fiche détail
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- [x] Cause confirmée:
  - la fiche détail d'une remise manuelle permettait seulement l'ajout unitaire de comptes;
  - le besoin métier est de figer rapidement un lot de comptes actuels selon les mêmes critères que le mode auto, sans rendre la remise dynamique pour les futurs comptes.
- [x] Correctif livré:
  - la fiche détail d'une remise manuelle expose maintenant un bloc `Ajouter en masse (sélection figée)`;
  - ce bloc réutilise les mêmes axes métier que le mode auto:
    - `Typologie`
    - `Pipeline`;
  - ces filtres ne sont pas persistés sur la remise et ne changent donc pas son mode de ciblage;
  - l'action insère seulement les comptes présents au moment du clic dans `ecommerce_remises_to_clients`;
  - les comptes déjà liés sont exclus du lot;
  - après un ajout en masse, le BO garde la possibilité de retirer des comptes unitairement depuis la liste des cibles manuelles.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
  - la fiche détail affiche aussi maintenant l'email du contact administrateur principal du compte sous le nom, en petit, dans les listes auto et manuelles.
  - le CTA `Retirer` utilise maintenant un vrai bouton rouge plein, autant sur la fiche détail de la remise que depuis la fiche client; le CTA d'ajout manuel de la fiche client devient `Appliquer` en `btn-info`.
  - le ciblage manuel peut maintenant être préparé avant activation: l'ajout unitaire ou en masse de comptes n'est plus bloqué par l'état `Inactive` ni par une fenêtre de commande pas encore ouverte.
  - la fiche détail d'une remise manuelle permet maintenant aussi de purger toute la liste via un CTA `Vider tout` placé dans l'entête de droite du tableau des comptes.
  - la liste des comptes concernés expose désormais une vraie colonne `Email` dédiée;
  - tous les emails liés à chaque compte sont affichés, y compris les emails des contacts associés au compte;
  - quand un compte porte plusieurs emails, la fiche détail génère plusieurs lignes secondaires `compte + email`, en ne gardant le CTA `Retirer` que sur la première ligne du compte.

## PATCH 2026-04-13 — FO agenda public: filtres `Département / pays` + `Organisateur` + `Jeu`
- [x] Audit cible:
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
  - dépendance relue:
    - `play/web/ep/modules/jeux/sessions/ep_sessions_list.php`
- [x] Cause confirmée:
  - la page publique `/fr/agenda` restait sur un filtre unique `Département`, avec une navigation legacy par slug;
  - l'agenda joueur `play` portait déjà la logique produit attendue:
    - `Département / pays`
    - `Organisateur`
    - `Jeu`
    - valeurs par défaut sur `Tous`
    - options limitées aux zones et organisateurs réellement présents.
- [x] Correctif livré:
  - `fo_sessions_list.php` reprend maintenant une lecture agenda alignée sur `play`, avec formulaire GET et 3 filtres sur la même ligne;
  - les routes SEO historiques `agenda/jeu/...`, `agenda/departement/...`, `agenda/ville/...` restent compatibles et hydratent les nouveaux filtres quand elles sont utilisées;
  - le filtre géographique mélange départements FR et pays étrangers réellement représentés dans les sessions;
  - le filtre `Jeu` regroupe les variantes techniques sous les 3 familles visibles `Cotton Quiz`, `Blind Test`, `Bingo Musical`;
  - en `dev`, la lecture agenda n'ajoute plus `c.online=1`, pour que `Tous` reste cohérent en recette.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`

## PATCH 2026-04-13 — FO fiche détail `Cotton Quiz`: séries programmées visibles
- [x] Audit cible:
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - dépendance relue:
    - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmée:
  - la fiche détail publique `www` n'exposait pas le détail des séries programmées sur `Cotton Quiz`;
  - `play` utilisait déjà cette information, et les helpers `global` la fournissaient déjà via `quiz_series_label` / `quiz_series_names`.
- [x] Correctif livré:
  - `fo_sessions_view.php` relit maintenant les séries `Cotton Quiz` depuis la session, avec fallback sur le détail jeu;
  - le bloc gauche `col-12 col-lg-5` affiche désormais une ligne `Séries programmées` entre `Date` et `Lieu`;
  - le rendu reste aligné sur les autres méta-informations de la fiche, avec une icône dédiée et une liste simple des séries;
  - les textes `Concept` / `Comment participer` sont mis à jour sur les fiches `Cotton Quiz`, `Blind Test` et `Bingo Musical`;
  - le bloc `Comment participer à un Bingo Musical ?` est réactivé avec le nouveau wording;
  - le CTA principal `Je participe` de la fiche détail réutilise maintenant la même URL EP sessionnelle que les liens présents dans les blocs `Comment participer`;
  - sur une session terminée des 3 jeux, la colonne centrale affiche maintenant `Podium` puis `Classement complet` à la place du visuel standard;
  - le bloc gauche d'informations générales est masqué sur ces sessions terminées, afin de ne conserver que les résultats;
  - ces résultats s'appuient sur `app_session_results_get_context(...)`, comme la fiche archive `pro`, avec fallback visuel propre quand aucune photo gagnant n'est disponible;
  - le titre de la liste basse réutilise maintenant le nombre réel de participants (`players_count`) remonté par ce moteur;
  - pour `Bingo Musical`, la liste basse masque aussi rang et points, afin de rester alignée sur le rendu `pro`;
  - les accroches marketing et blocs `Concept / Comment participer` sont masqués dans ce contexte terminé.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`

## PATCH 2026-04-13 — FO fiche `place`: synthèse alignée sur le moteur global `Mes joueurs`
- [x] Audit cible:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - dépendance relue:
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
    - `pro/web/ec/modules/compte/joueurs/ec_joueurs_view.php`
- [x] Cause confirmée:
  - la fiche établissement `www` lisait encore des stats legacy `app_statistiques_client_*`;
  - ces compteurs appliquaient des seuils d'affichage fixes et ne reflétaient pas la même vérité métier que la synthèse `Mes joueurs` côté `pro/ec`.
- [x] Correctif livré:
  - `fo_clients_view.php` s'appuie maintenant sur `app_client_joueurs_dashboard_get_context(...)`;
  - la ligne `Membre depuis ...` reprend la date consolidée du moteur global;
  - la ligne sessions affiche le total canonique `... sessions de jeux Cotton`;
  - la synthèse publique regroupe maintenant joueurs et équipes dans une seule ligne `... participants`;
  - convention marketing retenue: `1 équipe Cotton Quiz = 3 participants`;
  - la ligne `participants` disparait si le total est nul;
  - les anciens seuils `>10` / `>50` sont supprimés;
  - l'onglet `Sessions passées` de la fiche `place` réactive un CTA vers la fiche détail des sessions archivées;
  - cette liste archive filtre maintenant les sessions avec `app_client_joueurs_dashboard_session_is_history_useful(...)`, comme dans l'agenda `pro`;
  - le CTA de ces cartes archivées devient `Voir les résultats`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`

## PATCH 2026-04-08 — BO factures PDF: remise ABN explicitée hors libellé produit
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - `global/web/assets/branding/pdf/cotton-facture-logo.jpg`
- [x] Cause confirmée:
  - la facture PDF affichait encore la remise dans la description produit snapshotée, ce qui masquait la lecture du prix de référence HT;
  - le bloc des totaux recalculait encore visuellement la TVA depuis le `HT` arrondi, ce qui pouvait laisser un total incohérent face au `TTC` canonique déjà facturé.
- [x] Correctif livré:
  - la ligne produit PDF retire maintenant le libellé de remise du descriptif et réaffiche le `PU HT` de référence ainsi que le `PRIX TOTAL HT` avant remise;
  - le bloc des totaux expose désormais:
    - `TOTAL HT`
    - `REMISE xx% HT`
    - `TOTAL REMISÉ HT`
    - `TVA (20%)`
    - `TOTAL TTC`;
  - les montants du PDF sont maintenant relus depuis les snapshots structurés `prix_reference_ht`, `remise_ht`, `total_ht`, `total_ttc`;
  - la TVA visible est dérivée du `TTC` canonique moins le `HT` net snapshoté, pour rester strictement cohérente avec le montant final facturé.
  - le logo facture est maintenant relu depuis un asset partage `global`, plus depuis `pro`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`
  - cas de contrôle métier:
    - `99,90 € HT -25 %` => `24,97 €` de remise HT, `74,93 € HT` net, `14,98 € TVA`, `89,91 € TTC`

## PATCH 2026-04-08 — BO `Remises 2026`: le lien copiable reutilise la route publique historique
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- [x] Correctif livre:
  - le faux lien BO affichait bien l'URL, mais gardait `href="#"`, donc un clic ne quittait pas la fiche detail;
  - il reutilise la route historique stable `https://pro.../utm/cotton/<token_public>`, deja portee vers le signup/signin par `ec_sign.php`;
  - pour `Remises 2026`, le token emis est maintenant l'`id_securite` de la remise, avec fallback sur `code`.
  - si une ancienne remise `2026` n'avait pas encore d'`id_securite`, la fiche detail le backfill maintenant automatiquement au premier affichage du lien.
  - la fiche detail affiche maintenant d'abord le CTA `Copier le lien`, puis l'URL en petit et non cliquable sous le bouton.
  - une remise hors fenetre de commande n'expose plus ce lien et n'est plus proposable en ajout manuel depuis la fiche client.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`

## PATCH 2026-04-08 — BO `Remises 2026`: lien d'inscription copiable depuis la fiche detail
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- [x] Correctif livre:
  - la fiche detail expose maintenant un `Lien d'inscription` copiable pour les remises actives en ciblage manuel;
  - le lien pointe vers la route publique historique `/utm/cotton/...`, charge ensuite la remise en session puis bascule vers le signup/signin PRO;
  - les remises automatiques ou inactives n'exposent pas ce lien.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`

## PATCH 2026-04-08 — BO clients: section `Remises` recentree sur `Remises 2026`
- [x] Audit cible:
  - `www/web/bo/bo.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `www/web/bo/www/modules/entites/clients/bo_module_aside.php`
- [x] Correctif livre:
  - la navigation `Commercial` ne propose plus les entrées legacy `Remises > catalogue Cotton` et `Remises > accordées aux clients`;
  - la fiche client BO réutilise maintenant la section `Remises` pour afficher les `Remises 2026` actives applicables au compte;
  - la meme section permet aussi d'ajouter une `Remise 2026` manuelle au compte quand la regle est en ciblage manuel;
  - une regle manuelle sans aucun compte lie ne remonte plus a tort comme deja applicable sur la fiche client;
  - le retrait depuis la fiche client ne s'applique qu'aux rattachements manuels explicites, sans casser les règles automatiques.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/bo.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_module_aside.php`

## PATCH 2026-04-08 — BO `Remises 2026`: simplification de la fiche detail
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- [x] Correctif livre:
  - la fiche detail ne cumule plus `Durée de remise` et `Résumé métier`;
  - seul le resume metier est conserve, renomme en `Durée de la remise`;
  - le bloc `Période` est deplace sous `Etat`;
  - ce bloc est renomme en `Remise sur commande` avec un rendu lisible `du ... au ...` sur la fiche detail.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`

## PATCH 2026-04-08 — SQL BO `remises`: migration explicite des colonnes Remises 2026 / schedule Stripe
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/remises/bdd_ecommerce_remises.sql`
- [x] Correctif livre:
  - ajout d'un bloc de migration SQL explicite pour converger la prod avec le lazy-init runtime;
  - ajout de `ecommerce_remises.duree_remise_mois` en `SMALLINT(5) UNSIGNED NULL DEFAULT 12`, puis backfill `12` des lignes `NULL`;
  - ajout de `ecommerce_offres_to_clients.stripe_subscription_schedule_id` en `VARCHAR(255) NOT NULL DEFAULT ''`, puis backfill des `NULL` en chaine vide;
  - aucun index additionnel n'a ete ajoute dans cette passe, pour rester strictement aligne sur le runtime livre.

## PATCH 2026-04-08 — BO `Remises 2026`: duree d'application metier
- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
- [x] Correctif livre:
  - le BO garde sa structure metier actuelle et ajoute seulement `duree_remise_mois`;
  - la valeur par defaut est `12 mois`;
  - le form autorise une duree numerique bornee et le cas `Sans limite`;
  - la liste et la fiche detail affichent maintenant une lecture metier explicite:
    - `25 % pendant 12 mois`
    - `25 % pendant 3 mois`
    - `25 % sans limite`;
  - le BO n'expose toujours aucun choix technique `coupon` / `schedule`;
  - la regle annuelle exceptionnelle est documentee dans l'aide du formulaire:
    - en annuel, une duree `< 12 mois` signifie seulement `premiere facture annuelle`.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`

## PATCH 2026-04-07 — BO `Remises 2026`: nouveau chemin dedie sous `Commercial`
- [x] Audit cible:
  - `www/web/bo/bo.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
  - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
- [x] Correctif livre:
  - un nouveau chemin BO `Commercial > Remises 2026` remplace le besoin de tordre les formulaires legacy `remises` / `remises_offres`;
  - le formulaire dedie inferre maintenant `mode=modifier` quand une fiche existante est ouverte avec `id>0` mais sans parametre `mode`, ce qui evite de dupliquer la remise au lieu de mettre a jour l'originale;
  - la liste BO propose maintenant aussi une suppression directe, qui purge les liaisons `ecommerce_remises_to_offres` (ABN 12) et `ecommerce_remises_to_clients` avant de supprimer la regle;
  - la colonne `Ciblage` de la liste affiche maintenant le detail reel `Pipeline: ...` et/ou `Typologie: ...` au lieu d'un libelle generique;
  - la vue detail affiche maintenant un recap `Comptes concernes : x`, calcule sur le volume reel de comptes cibles en mode automatique ou manuel;
  - la vue detail rappelle maintenant aussi la duree Stripe fixe de la remise V1: `12 mois`;
  - le form dedie porte exactement les champs V1 utiles:
    - `Nom (interne)`
    - `Descriptif (interne)`
    - `Nom (espace pro)`
    - `Client > typologie`
    - `Client > pipeline`
    - `Remise en %`
    - `Date debut commande`
    - `Date fin commande`
    - `Active / Inactive`
  - le write path dedie cree / met a jour la regle dans `ecommerce_remises` et la liaison ABN `12` dans `ecommerce_remises_to_offres`;
  - si `typologie` et/ou `pipeline` sont renseignes, le module passe en ciblage automatique et purge les ciblages explicites pour eviter les modes mixtes;
  - si les deux sont vides, la fiche passe en ciblage manuel et permet d'ajouter / retirer des comptes organisateurs via `ecommerce_remises_to_clients`;
  - la vue fermee affiche la liste des comptes propres concernes et exclut les TdR (`flag_client_reseau_siege=0`) ainsi que les comptes reseau relies (`id_client_reseau=0`);
  - les modules legacy `remises` / `remises_offres` ne sont plus cibles par la V1 et restent laisses dans leur etat legacy.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
  - `php -l /home/romain/Cotton/www/web/bo/bo.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_form.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_module_parametres.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_script.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_list.php`

## PATCH 2026-04-03 — BO `facturation_pivot`: KPI `Clients actifs` aligné sur le mois de référence en `civil/fiscal`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
- [x] Cause confirmée:
  - en `année civile` et `année fiscale`, le KPI haut `Clients actifs` prenait le dernier mois théorique de la plage (`decembre` ou `aout`);
  - ce comportement divergeait de l'intuition produit, qui attend le mois de référence sélectionné.
- [x] Correctif livré:
  - ajout d'une clé dédiée `clients_kpi_month_key`;
  - en `civil` et `fiscal`, le KPI `Clients actifs` lit désormais le mois `ref_month`;
  - en `month` et `last3`, le comportement reste inchangé.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK

## PATCH 2026-04-03 — BO `facturation_pivot`: taux SaaS réalignés sur les démos agrégées
- [x] Audit ciblé:
  - `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
- [x] Cause confirmée:
  - le reporting SaaS charge séparément `Demos visiteurs` et `Démos nvx inscrits`;
  - plusieurs taux “réalisés” utilisaient encore uniquement `Demos visiteurs`, alors que le bloc `Objectifs` agrège déjà les deux sources.
- [x] Correctif livré:
  - ajout d'un agrégat mensuel `demo_sessions_total_by_month`;
  - les ratios réels `Tx visiteurs -> demos`, `Tx demos -> inscrits` et `Tx demos -> clients` de la modale de conversion utilisent désormais la somme `demo_sessions + demo_sessions_new_users`;
  - les deux colonnes de détail du tableau restent séparées pour conserver la lecture métier d'origine.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK

## PATCH 2026-03-24 — BO clients: copie du lien EC temporaire au lieu de l'ouverture
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- [x] Cause confirmée:
  - apres generation, l'URL du lien EC temporaire etait affichee comme une ancre cliquable;
  - l'usage BO attendu est plutot de partager l'URL, pas de la suivre depuis la fiche client.
- [x] Correctif livré:
  - l'URL est maintenant associee a une action de copie presse-papiers;
  - un bouton `Copier le lien` et un feedback `Lien copié.` sont ajoutes;
  - un fallback `execCommand('copy')` couvre les navigateurs BO sans `navigator.clipboard`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK

## PATCH 2026-03-20 — BO `facturation_pivot`: allègement du reporting SaaS sans perte des KPI sessions
- [x] Audit ciblé:
  - `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
- [x] Cause confirmée:
  - la page `?t=syntheses&m=facturation_pivot&p=saas` recalculait les sessions jeux via un premier scan lourd sur `championnats_sessions`;
  - un second scan quasi identique recalculait ensuite les seules sessions numériques pour les ratios joueurs/session et joueurs/client;
  - ce double passage SQL a été introduit dans le correctif `fix calcul sessions reporting`.
- [x] Correctif livré:
  - l’agrégation principale des sessions remonte maintenant aussi `sessions_numeric` dans la même requête SQL;
  - le second balayage `sql_sessions_numeric` est supprimé;
  - les métriques métiers conservées:
    - sessions finies par mois / client / jeu
    - ventilation par type de jeu
    - comptage séparé des sessions numériques pour les ratios.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK

## PATCH 2026-03-13 — BO réseau: remplacements délégués différés persistés en base dédiée
- [x] Audit ciblé:
  - `www/web/bo/cron_routine_bdd_maj.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le cron BO des remplacements différés relisait encore directement les marqueurs `[reseau_replace:*]` et `[reseau_replace_timing:*]` dans `ecommerce_offres_to_clients.commentaire`;
  - la base importée via phpMyAdmin ne portait pas encore de table métier dédiée pour cet ordonnancement.
- [x] Correctif livré:
  - ajout de la table `ecommerce_reseau_delegated_replacements` dans `bdd_ecommerce_reseau_contrats.sql`;
  - ajout d’un backfill best-effort depuis les anciens marqueurs pour rapatrier les remplacements déjà planifiés lors de l’import SQL;
  - le cron BO s’appuie désormais d’abord sur cette table dédiée, puis conserve un fallback legacy sur les anciens marqueurs tant que des lignes historiques peuvent subsister.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/bo/cron_routine_bdd_maj.php` OK

## PATCH 2026-03-13 — BO réseau: liens croisés vers la TdR et l'offre support
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Cause confirmée:
  - la fiche BO d'un `Abonnement réseau` n'affichait pas explicitement le compte TdR dans le bloc haut;
  - la synthèse `Affiliés du réseau` indiquait `Abonnement réseau actif : oui` sans lien rapide vers la fiche de l'offre support.
- [x] Correctif livré:
  - la vue haute `offres_clients` affiche maintenant une ligne `CLIENT` au-dessus de `Objet`, avec lien vers la fiche client de la TdR;
  - dans `reseau_contrats`, le libellé `Abonnement réseau actif` devient cliquable quand l'offre support est résolue;
  - aucun write path ni recalcul réseau n'est modifié.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-13 — BO `reseau_contrats`: affichage de l'`Offre incluse cible`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Cause confirmée:
  - le bloc `Affiliés du réseau` exposait déjà `Abonnement réseau actif`, `Nb affiliés limite` et `Nb de places dispo`;
  - l'offre déléguée incluse cible restait pourtant absente de cette synthèse BO, alors que l'identifiant canonique `id_offre_delegation_cible` est déjà disponible dans la couverture réseau.
- [x] Correctif livré:
  - la synthèse affiche maintenant `Offre incluse cible` sous la ligne d'état/quota quand l'abonnement réseau est actif;
  - le libellé est résolu en priorité depuis le catalogue déjà chargé par la vue, avec fallback sur `module_get_detail('ecommerce_offres', ...)`;
  - aucun recalcul métier ni write path réseau n'est ajouté.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `offres_clients`: respect du passage explicite à `Terminée` pour l'`Abonnement réseau`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - dépendances relues:
    - `global/web/lib/core/lib_core_module_functions.php`
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le flux BO de clôture passait encore par une transition runtime intermédiaire avant la fermeture effective de la ligne support;
  - surtout, une fois le runtime archivé, le resolver support réseau continuait d'autoriser un fallback automatique vers une autre offre support `id_etat IN (2,3)` du même siège;
  - ce fallback pouvait réouvrir la lecture réseau en `En attente` après une clôture BO pourtant explicite.
  - la fiche client TdR appelait aussi `app_ecommerce_reseau_facturation_get_detail(...)` en mode par défaut;
  - ce helper de lecture relançait encore `app_ecommerce_reseau_contrat_sync_legacy_delegations(...)`, puis `app_ecommerce_reseau_facturation_refresh(...)`, donc une réécriture possible du statut support au simple rechargement BO.
- [x] Correctif livré:
  - la clôture BO immédiate s'appuie désormais directement sur la fermeture explicite de l'offre support et l'archivage runtime final;
  - un garde-fou final réapplique aussi `id_etat=4` sur la ligne support après la rotation runtime pour empêcher tout retour parasite en `En attente`;
  - un contrat runtime archivé retourne désormais `cloture` comme état canonique;
  - tant que ce runtime archivé n'est pas explicitement rerattaché par une réactivation BO/Stripe, aucun fallback automatique ne peut réélire une offre support `En attente` ou `Active`;
  - le recalcul réseau canonique ne fabrique plus non plus lui-même un passage de l'offre support vers `En attente` ou `Active`; ces transitions restent réservées aux write paths explicites BO / Stripe, tandis que le refresh conserve l'état courant sauf clôture runtime;
  - la fiche client TdR lit désormais la synthèse réseau en mode `skip_legacy_sync=1`, donc sans sync legacy implicite au chargement de la vue;
  - le correctif ne rouvre ni auto-création, ni suppression brute, ni write path concurrent.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: remise synthèse alignée sur la prochaine commande TdR
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - la synthèse `Remise réseau courante` affichait le palier des offres `hors abonnement réseau` déjà actives;
  - pour le front PRO, le besoin utile est la remise qui s’appliquerait à la prochaine offre commandée par la TdR.
- [x] Correctif livré:
  - la synthèse calcule désormais la remise sur `volume actif courant + 1`;
  - l’affichage rappelle explicitement qu’il s’agit de la `prochaine commande TdR`;
  - aucune modification du calcul tarifaire réellement appliqué aux lignes déjà actives.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: historique terminé et couverture stabilisés
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le tableau du bas de page exposait un titre devenu faux après ouverture de l’historique `incluse`;
  - la qualification de couverture pouvait encore reclasser des lignes historiques via un fallback legacy trop agressif;
  - le libellé `Incluse à l'abonnement réseau` suggérait à tort l’offre support courante.
- [x] Correctif livré:
  - renommage du tableau en `Offres déléguées terminées`;
  - affichage de tout l’historique des offres déléguées terminées rattachées à la TdR;
  - priorité au rattachement explicite `reseau_id_offre_client_support_source` pour qualifier l’historique;
  - libellé ajusté en `Incluse à un abonnement réseau`.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: remise réseau réintroduite dans `Tarif`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livré:
  - la colonne `Tarif` des affiliés réaffiche la remise réseau appliquée sur les délégations `hors abonnement réseau`;
  - le rendu détaille désormais brut HT, pourcentage de remise et net appliqué;
  - aucune tarification n’est ajoutée aux offres incluses à l’abonnement réseau.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: synthèse affiliés reformulée
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livré:
  - la synthèse du bloc `Affiliés du réseau` est réécrite en structure métier plus lisible;
  - affichage distinct de:
    - `Abonnement réseau actif`
    - `Tarif négocié` si actif
    - `Affiliés actifs`
    - `Offres propres`
    - `Offres déléguées`
    - `Offres incluses abn` si actif
    - `Affiliés inactifs`
    - `Remise réseau courante`
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-12 — BO `reseau_contrats`: filtre rapide par type de couverture
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livré:
  - le tableau `Affiliés du réseau` est maintenant regroupé par type de couverture;
  - des filtres rapides permettent de n’afficher que:
    - `Tous`
    - `Incluses abn`
    - `Déléguées`
    - `Offres propres`
    - `Inactifs`
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-11 — Réseau: rattachement explicite des offres incluses à l'abonnement source
- [x] Audit ciblé:
  - `documentation/canon/data/schema/DDL.sql`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - aucune offre déléguée incluse ne portait l'id de l'offre support `Abonnement réseau` source;
  - l'historique devait donc être reconstruit par heuristique.
- [x] Correctif livré:
  - ajout du champ facultatif `reseau_id_offre_client_support_source` au schéma canonique `ecommerce_offres_to_clients`;
  - alimentation de ce champ sur les write-paths `cadre`;
  - remise à `0` sur les flux `hors abonnement réseau`.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-11 — BO `offres_clients`: `Offres incluses` figées par offre support
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_aside.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - la fiche `Abonnement réseau` lisait encore le contrat/support réseau courant du client pour le bloc `Offres incluses`;
  - la jointure sur `ecommerce_reseau_contrats_affilies.id_offre_client_deleguee` relisait un pointeur courant par affilié, pas un historique par offre support;
  - une offre support terminée pouvait donc ne pas afficher ses propres offres déléguées incluses.
- [x] Correctif livré:
  - ajout d’un helper global dédié pour relire les offres incluses rattachées à une offre support donnée;
  - le support actif repart désormais de la couverture canonique runtime;
  - une archive repart des offres déléguées du siège sur la période de l’offre support affichée;
  - aside, vue haute et formulaire BO utilisent désormais cette lecture figée par offre support;
  - les offres `Terminées` continuent d’exposer leurs délégations reliées dans cette section.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_aside.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php` OK

## PATCH 2026-03-11 — BO `offres_clients`: abonnement réseau terminé non réactivable par édition
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - la synchro BO `Abonnement réseau` restait exécutée même pour une offre support déjà `Terminée`;
  - ce passage pouvait rerattacher l'offre historique au runtime canonique.
- [x] Correctif livré:
  - skip de la synchro runtime tant que l'offre reste `Terminée`;
  - garde-fou de persistance sur `id_etat=4` pour une simple modification d'archive;
  - restauration explicite de `date_debut` / `date_facturation_debut` si ces champs reviennent vides dans ce flux.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-11 — BO `reseau_contrats`: séparation stable abonnement réseau / hors abonnement
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - dépendance relue:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - la vue classait encore une ligne en `hors cadre` dès qu'un pricing hors cadre existait, même si `mode_facturation='cadre'`;
  - un affilié sans offre pouvait exposer à la fois l'action `Activer` via abonnement réseau et la commande hors abonnement.
- [x] Correctif livré:
  - priorité à `mode_facturation` pour empêcher le double comptage `cadre` vs `hors abonnement`;
  - synthèse métier remontée dans `Affiliés du réseau`;
  - action BO exclusive:
    - quota disponible => activation via abonnement réseau
    - sinon => attribution d'une offre déléguée hors abonnement réseau;
  - suppression des blocs redondants:
    - `Synthèse hors cadre`
    - `Commander une offre hors cadre`
    - `Offres affiliées hors cadre`
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - contrôle texte: plus de libellés/blocs BO redondants OK

## PATCH 2026-03-11 — BO `reseau_contrats`: offres terminées réseau explicites
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Cause confirmée:
  - le sous-compteur `dont offres terminées (CSO)` lisait encore le pipeline affilié au lieu des offres déléguées réellement terminées;
  - le formulaire d'attribution hors abonnement étendait trop la colonne `Actions`.
- [x] Correctif livré:
  - le sous-compteur est maintenant branché sur les offres déléguées réseau terminées;
  - ajout d'une table en bas de page listant ces offres terminées;
  - suppression du paragraphe `Activation`;
  - formulaire d'attribution hors abonnement passé en champs verticaux.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-11 — BO `reseau_contrats`: `Offre` + `Tarif` réalignés
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livré:
  - la colonne `Offre` réaffiche la jauge de l'offre active;
  - la colonne `Offre` affiche aussi la période en cours de l'offre active;
  - la colonne `Tarif` est ajoutée sur la liste `Affiliés du réseau`;
  - exception métier:
    - aucune tarification affichée pour les offres incluses à l'abonnement réseau;
  - la synthèse remonte aussi le tarif négocié du socle `Abonnement réseau` quand l'abonnement est actif.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-11 — Convergence d'activation `Abonnement réseau` entre BO et Stripe
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - dépendances relues:
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
    - `pro/web/ec/ec_webhook_stripe_handler.php`
- [x] Correctif livré:
  - le BO réutilise maintenant le helper partagé d'activation support réseau déjà employé par le write path Stripe;
  - les deux chemins convergent vers le même ordre métier sans double logique divergente.
- [x] Effet attendu:
  - `Etat offre=active` puis `Etat contractuel=actif`
  - lecture cohérente dans `reseau_contrats` après activation BO ou paiement Stripe.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `npm run docs:sitemap` OK

## PATCH 2026-03-11 — BO `offres_clients`: override admin réel `pending_payment -> active`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `global/web/lib/core/lib_core_module_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le form BO postait déjà `id_etat=3`;
  - le rollback venait du refresh réseau générique déclenché par `module_modifier(...)` avant la synchro du contrat vers `actif`.
- [x] Correctif livré:
  - bypass du refresh prématuré étendu au cas admin `2 -> 3` sur l'offre support réseau canonique;
  - ordre retenu:
    - écriture BO de l'offre
    - sync des paramètres réseau de l'offre canonique
    - synchro contrat vers `actif`
    - refresh réseau explicite après mise à jour du contrat;
  - flow spécial `id_etat=4` conservé.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `npm run docs:sitemap` OK
- [ ] Hors périmètre:
  - aucun changement Stripe
  - aucune réintroduction de `save_contrat`, `activate_contract`, `close_contract`

## PATCH 2026-03-11 — BO réseau durable: CTA visible + pilotage affiliés
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constats confirmés:
  - le CTA méta TdR existait mais comme lien discret;
  - `save_contrat`, `activate_contract`, `close_contract` restent neutralisées dans le script BO;
  - l'activation BO réutilise déjà les write paths existants d'offre déléguée.
- [x] Correctif livré:
  - `Voir / gérer les affiliés` devient un vrai bouton visible sous `Tête de réseau`;
  - `reseau_contrats` expose la liste des affiliés avec actions d'activation, désactivation et attribution hors cadre;
  - la règle métier est conservée:
    - abonnement réseau actif + quota disponible => activation via l'offre cible du contrat
    - sinon => choix d'une offre du SI en hors cadre;
  - aucune action contrat neutralisée n'est réintroduite.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `npm run docs:sitemap` OK
- [ ] Hors périmètre:
  - aucune réactivation du pilotage BO du contrat négocié
  - aucun changement PRO requis dans ce lot

## PATCH 2026-03-11 — Régression UI du `+` TdR sur fiche client
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le gating backend continuait à reposer sur `clients.flag_client_reseau_siege = 1`;
  - le lien ciblé `offres_clients` vers `Abonnement réseau` restait valide;
  - la régression était strictement UI:
    - le `+` documenté avait été remplacé par des boutons fixes;
    - puis un correctif intermédiaire laissait le clic sur `+` partir vers le flux standard, le menu restant sur le chevron split.
- [x] Correctif livré:
  - la fiche client TdR réaffiche un `+` avec dropdown Bootstrap 5 porté par le bouton `+` lui-même;
  - le menu rapide propose `Offre propre` / `Offre réseau`;
  - `Offre réseau` ouvre toujours `offres_clients` prérempli sur `Abonnement réseau`;
  - `Affiliés / hors cadre` reste exposé séparément.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
- [ ] Hors périmètre:
  - aucun changement moteur global
  - aucune refonte de `reseau_contrats`

## PATCH 2026-03-11 — CTA standard `Ajouter` sur `offres_clients` filtré TdR
- [x] Audit ciblé:
  - `www/web/bo/master/bo_master_header.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le CTA `Ajouter` venait du core et ne proposait qu’un lien standard vers le formulaire;
  - le contexte `id_client` filtré existait déjà, mais aucun CTA ne préremplissait `id_offre=Abonnement réseau`.
- [x] Correctif livré:
  - sur la liste `offres_clients` filtrée par une TdR, `Ajouter` devient un dropdown Bootstrap 5;
  - le menu propose `Offre propre` / `Offre réseau`;
  - `Offre réseau` pointe vers `offres_clients` avec `id_client` et `id_offre=<catalogue Abonnement réseau>`.
- [x] Vérification:
  - `php -l www/web/bo/master/bo_master_header.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-11 — Résolution helper `Abonnement réseau` vs catalogue BO
- [x] Audit ciblé:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/lib/core/lib_core_module_functions.php`
  - `www/web/bo/master/bo_master_header.php`
- [x] Cause confirmée:
  - le helper `app_ecommerce_reseau_abonnement_get_catalog_id()` ne lisait que `seo_slug='abonnement-reseau'`;
  - le filtre/select BO `Offre` lisait toute la table `ecommerce_offres` par `nom`, donc l’offre restait visible même si le `seo_slug` était absent.
- [x] Correctif livré:
  - fallback helper par `nom='Abonnement réseau'`;
  - mise à niveau opportuniste du `seo_slug` canonique sur la ligne existante;
  - CTA dropdown BO conservé avec attribut Bootstrap 4 `data-toggle="dropdown"`.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l www/web/bo/master/bo_master_header.php` OK

## PATCH 2026-03-11 — Fiche client TdR `+` sur section `Offres`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le `+` était déjà un vrai bouton dropdown unique;
  - le runtime BO est Bootstrap 4 alors que le bouton portait encore `data-bs-toggle="dropdown"`.
- [x] Correctif livré:
  - passage du bouton `+` en `data-toggle="dropdown"`;
  - conservation des URLs `Offre propre` / `Offre réseau`;
  - `Offre réseau` continue d’utiliser la résolution catalogue fiabilisée `Abonnement réseau`.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK

## PATCH 2026-03-11 — Fiche client TdR: déplacement du CTA réseau dans le bloc meta
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- [x] Correctif livré:
  - hoist de l’URL `reseau_contrats` pour réutilisation dans le bloc meta;
  - ajout du CTA `Voir / gérer les affiliés` juste sous `Tête de réseau`;
  - suppression du bouton `Affiliés / hors cadre` dans la section `Offres`;
  - aucun changement sur le dropdown `Offre propre` / `Offre réseau`.
- [x] Réalignement doc livré:
  - `reseau_contrats` est désormais décrit comme vue BO transverse interne durable de pilotage réseau;
  - l’ancien wording transitoire est corrigé dans les sections de synthèse courantes.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - `npm run docs:sitemap` OK

## PATCH 2026-03-11 — Dépendance moteur global stabilisée
- [x] Dépendance relue:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Effet de dépendance intégré:
  - le moteur ne crée plus de nouveau support legacy `contrat-cadre-reseau`
  - un éventuel post legacy depuis le BO standard est remappé vers `Abonnement réseau`.
- [ ] Suites ouvertes côté `www`:
  - poursuivre le nettoyage des wording historiques autour de la vue BO `reseau_contrats`
  - conserver les neutralisations de write paths contrat sur la vue BO réseau durable.

## PATCH 2026-03-11 — Stabilisation BO minimale des points d’entrée réseau
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Clarification de la fiche client TdR:
  - le libellé BO `Offre réseau` n’est plus utilisé pour ouvrir `Abonnement réseau`;
  - la fiche client distingue maintenant:
    - `Abonnement réseau`
    - `Voir / gérer les affiliés`.
- [x] Requalification de `reseau_contrats`:
  - titre, texte d’aide et wording recentrés sur la vue BO transverse interne durable de pilotage réseau;
  - l’écran ne se présente plus comme le lieu canonique du cadre négocié.
- [x] Neutralisation défensive des write paths contrat:
  - `save_contrat`
  - `activate_contract`
  - `close_contract`
  - ces actions renvoient désormais un message explicite de désactivation.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK
- [ ] Suites ouvertes:
  - lot moteur global pour supprimer le bi-catalogue support et l’auto-création legacy
  - lot BO transverse pour préparer `Gestion des affiliés`
  - lot PRO pour réaligner `Mon offre` et la page réseau TdR.

## RE-BASELINE 2026-03-11 — Cible canonique réseau
- [x] Audit relu sur:
  - `www/web/bo/master/bo_master_form.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Vérité canonique retenue:
  - une seule offre métier TdR cible: `Abonnement réseau`
  - `reseau_contrats` ne doit plus être lu comme second objet métier stable
  - la cible BO est la vue transverse `Gestion des affiliés`, portée à ce stade par `reseau_contrats`.
- [ ] Suites ouvertes:
  - supprimer les write paths contrat encore présents dans `reseau_contrats`
  - poursuivre le nettoyage des wording historiques autour de `reseau_contrats`
  - préparer une éventuelle extraction future si la vue BO réseau change de route, sans changer sa fonction durable.

## PATCH 2026-03-10 — Hotfix Étape 2: entrée TdR `+` vers `Abonnement réseau`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php`
  - audit logique relu:
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
    - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif BO livré:
  - le `+` de la fiche client TdR propose désormais `Offre propre` / `Offre réseau`;
  - `Offre propre` conserve le comportement historique inchangé;
  - `Offre réseau` ouvre directement le formulaire `offres_clients` prérempli sur `Abonnement réseau`;
  - le bloc de paramétrage interne `Abonnement réseau` est désormais visible dès l’ajout ciblé, pas seulement en édition.
  - ajustement de robustesse:
    - la fiche client assure le catalogue `Abonnement réseau` avant gating de l’UI;
    - le dropdown est migré vers `data-bs-toggle="dropdown"` pour correspondre au BO Bootstrap 5.
- [x] Garde-fou conservé:
  - pour un client non TdR, le `+` conserve le flux historique standard.
- [x] Tests / recette:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php` OK
  - test manuel ajouté: `documentation/specs/tests/reseau-abonnement-reseau-hotfix-tdr-plus-pending-payment.md`

## PATCH 2026-03-10 — Étape 2 BO `Abonnement réseau`: offre distincte via `Ajouter une offre`
- [x] Audit ciblé:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_aside.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Création nouvelle offre:
  - nouvelle entrée catalogue `Abonnement réseau` assurée par helper global;
  - reconnaissance support réseau élargie au nouveau catalogue avec fallback legacy.
- [x] Intégration au parcours `Ajouter une offre`:
  - le formulaire standard `offres_clients` reste inchangé à l’ajout;
  - l’option `Abonnement réseau` n’est visible que pour une TdR sélectionnée dans le champ `Client`;
  - choisir `Abonnement réseau` crée la ligne en `En attente`, la rattache au contrat réseau existant et renvoie ensuite vers l’édition dédiée pour le paramétrage.
- [x] Reprise du paramétrage négocié:
  - sync BO du montant négocié, de la périodicité, du quota inclus, de l’offre cible et de la jauge cible;
  - passage `En attente -> Active -> Terminée` via l’édition standard de l’offre.
- [x] Affichage des offres incluses:
  - la vue détail `offres_clients` de l’abonnement affiche uniquement les lignes incluses `cadre`, avec statut, période, périodicité et prix.
- [x] Tests / recette:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l www/web/bo/master/bo_master_form.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_extra.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_module_aside.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - test manuel ajouté: `documentation/specs/tests/reseau-abonnement-reseau-etape2.md`

## PATCH 2026-03-10 — Étape 1 BO `Offre réseau`: recentrage hors cadre
- [x] Audit ciblé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Retrait du contrat cadre de la page actuelle:
  - suppression des blocs, CTA et formulaires BO liés au contrat cadre / négocié dans `reseau_contrats`.
- [x] Recentrage hors cadre:
  - la vue BO n'affiche plus que les offres affiliées hors cadre, avec statut, période, périodicité, remise et tarif.
  - la création directe hors cadre reste possible depuis un bloc dédié pour les affiliés sans offre active.
- [x] Renommage fonctionnel:
  - titre BO `Gestion de l'offre réseau`;
  - CTA fiche client `Gérer l'offre réseau`.
- [x] Tests / recette:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php` OK
  - test manuel ajouté: `documentation/specs/tests/reseau-offre-reseau-etape1.md`

## PATCH 2026-03-10 — BO `offres_clients`: `Terminer` une offre réseau = clôture réelle
- [x] Surface BO ajustée:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Règle appliquée:
  - sur une offre réseau support, un passage BO à `id_etat=4` déclenche la clôture réelle du réseau;
  - la ligne support passe en historique immédiatement;
  - les offres déléguées actives liées sont terminées et les activations affiliés désactivées;
  - une nouvelle offre support `En attente` est recréée pour la suite.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-09 — BO contrat cadre: formulaire masqué hors activation/édition
- [x] Surfaces BO ajustées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Flux livré:
  - `inactif` / `cloture`:
    - champs masqués par défaut;
    - `Activer un contrat cadre` ouvre le formulaire;
    - validation unique des paramètres puis activation.
  - `actif`:
    - champs visibles en lecture seule par défaut;
    - CTA `Modifier` pour réouvrir l'édition;
    - CTA `Clôturer ce contrat cadre` masqué pendant l'édition;
    - sauvegarde puis retour à la vue lecture seule.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK

## PATCH 2026-03-09 — migration SQL canonique `contract_state` du module BO réseau
- [x] Surface BO / schéma ajustée:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Migration idempotente ajoutée:
  - ajout de la colonne `contract_state enum('inactif','actif','cloture') not null default 'inactif'`;
  - normalisation d’anciennes valeurs texte éventuelles:
    - `active`
    - `inactive`
    - `closed`
- [x] Backfill prudent:
  - état par défaut `inactif`;
  - promotion en `actif` uniquement si `id_offre_client_contrat` pointe une offre support active `id_etat=3`;
  - pas d’inférence automatique vers `cloture`.
- [x] Risque documenté:
  - exécution automatique de ce SQL depuis `cron_routine_bdd_maj.php`: non trouvé dans le code audité.

## PATCH Étape 2A — lisibilité BO de la part variable affiliés après remise réseau (2026-03-09)
- [x] Surface BO ajustée:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Lecture BO ajoutée:
  - la synthèse `Part variable affilies` rappelle le taux de remise réseau appliqué au calcul courant;
  - l’assiette de remise affichée est le nombre d’affiliés détenant une délégation active, `cadre` ou `hors_cadre`;
  - la colonne `Offre` affiche désormais aussi la jauge de l’offre active;
  - nouvelle colonne `Tarif`:
    - `offre déléguée incluse contrat cadre` -> `montant cadre négocié`, `nb d’offres incluses actives`, puis `HT / mois`;
    - `offre déléguée hors cadre` -> `HT`, `remise réseau`, puis `HT appliqué / mois`;
    - `offre propre` -> `HT / mois`;
    - `aucune offre` -> `-`.
- [x] Garde-fou de lisibilité:
  - la colonne `Offre` reste focalisée sur le lien et le libellé BO;
  - les montants sont isolés dans `Tarif`.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH Étape 2A — vitrine tarifaire alignée sur le référentiel tarifaire global (2026-03-09)
- [x] Surfaces WWW concernées:
  - `www/web/fo/modules/ecommerce/tarifs/fr/fo_tarifs_offre_detail.php`
  - `www/web/fo/modules/ecommerce/offres_paniers/fr/fo_offres_paniers_form_script.php`
- [x] Effet fonctionnel:
  - la vitrine continue d’utiliser le widget partagé abonnement;
  - le write path panier se recale désormais côté `global` sur le référentiel unique pour les cas couverts.
- [x] Audit parallèle BO réseau:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - création hors cadre confirmée via le helper global de prix, sans refonte de l’écran BO.
- [x] Vérification:
  - `php -l global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` OK

## PATCH Étape 2A — CTA BO `Activer` hors cadre unifié (2026-03-09)
- [x] Surfaces BO ajustées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Correction d’affichage:
  - ancienne condition erronée:
    - CTA affiché seulement si quota cadre dispo
    - ou offre cible présente
    - ou délégation legacy déjà réactivable
  - nouvelle condition:
    - CTA affiché pour tout affilié sans offre active, sauf `Offre propre`.
- [x] Flux BO livrés:
  - cas cadre exploitable:
    - activation auto avec l’offre cible du cadre
  - cas hors cadre unifiés:
    - pas de contrat exploitable
    - pas d’offre cible cadre
    - quota cadre atteint
  - dans ces cas:
    - choix BO de l’offre
    - choix BO de la jauge / capacité
    - création d’une nouvelle délégation hors cadre.
- [x] Simplification UI:
  - le select de réactivation d’une délégation existante est retiré de la colonne `Action`;
  - le formulaire poste désormais systématiquement `id_offre_client_deleguee=0`.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK

## PATCH Étape 2A — fermeture BO contrat cadre réseau (2026-03-09)
- [x] Surfaces BO finalisées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Évolutions livrées:
  - rechargement du reclassement quota/historique à l’ouverture de la page;
  - affichage explicite des champs métier:
    - `Montant cadre négocié (HT)`
    - `Nombre max d'affiliés inclus dans le cadre`
    - `Offre SI dédiée cible pour les affiliés couverts`
  - synthèse BO alignée sur le moteur global:
    - délégations actives résolues
    - quota absorbé
    - places incluses restantes
    - offre cible auto
  - table affiliés branchée sur le statut commercial effectif:
    - `offre propre`
    - `offre déléguée incluse contrat cadre`
    - `offre déléguée hors cadre`
    - `aucune offre`
- [x] Décision UX:
  - retrait du pilotage manuel `cadre / hors_cadre` dans cette vue pour éviter une contradiction avec le reclassement automatique.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH Étape 2A — refonte du tableau BO “Affiliés du siège” (2026-03-09)
- [x] Surface BO ajustée:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Recomposition du rendu:
  - suppression des colonnes:
    - `Activation réseau`
    - `Offre déléguée résolue`
  - nouvelles colonnes:
    - `Statut commercial`
    - `Offre`
  - libellés harmonisés:
    - `Offre propre`
    - `Déléguée incluse contrat cadre`
    - `Déléguée hors cadre`
    - `Aucune offre`
  - offre active désormais affichée comme objet BO manipulable avec lien direct `offres_clients`.
- [x] Colonne action clarifiée:
  - `Non pilotable ici`
  - `Désactiver`
  - `Activer`
- [x] CTA désormais câblés de bout en bout:
  - `Activer`:
    - write path BO dédié
    - création de l’offre cible si nécessaire
    - ou activation d’une offre déléguée existante
    - puis reclassement cadre/hors cadre
  - `Désactiver`:
    - termine la ligne `ecommerce_offres_to_clients` déléguée active
    - puis refresh facturation + reclassement
- [x] Vérification:
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php` OK

## PATCH Étape 2A — triggers BO de désaffiliation / suppression affilié (2026-03-09)
- [x] Surfaces BO complétées:
  - `www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `www/web/bo/www/modules/entites/clients/bo_clients_functions.php`
- [x] Correction appliquée:
  - toute modification BO de `clients.id_client_reseau` rejoue désormais le reclassement sur l’ancien et le nouveau siège;
  - la suppression BO d’un affilié rattaché rejoue le reclassement du siège d’origine.
- [x] Vérification:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_script.php` OK
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_functions.php` OK

## AUDIT Étape 2A — lien réseau historique et remise associée (2026-03-09)
- [x] Audit ciblé du routing public/proxy:
  - `pro/web/.htaccess`
- [x] Constat:
  - le lien réseau historique existe toujours sous deux formes:
    - `/utm/reseau/{slug}`
    - `/utm/reseau/{slug}/{CODE}`
  - la variante avec `CODE` ne pilote pas un contrat cadre;
  - elle ne fait que transporter un code remise en plus du rattachement réseau.
- [x] Conséquence:
  - côté routing, il n’existe pas d’ancienne route dédiée “activation contrat cadre” à réutiliser;
  - le futur flux automatique devra rester branché sur cette entrée UTM réseau existante, mais avec une décision métier portée par un helper global.

## AUDIT Étape 2A — contrat cadre automatique (2026-03-09)
- [x] Audit ciblé de la surface BO `reseau_contrats`:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Constat BO:
  - la page sait déjà persister:
    - `montant_socle_ht`
    - `max_affilies_activables`
    - `id_offre_delegation_cible`
  - mais elle pilote encore explicitement les affiliés un par un via:
    - activation manuelle
    - `mode_facturation` manuel.
- [x] Décision d’audit:
  - pas de patch BO sûr tant que le moteur automatique global n’existe pas;
  - supprimer maintenant le pilotage manuel du BO sans nouveau moteur créerait une incohérence immédiate entre UI, agrégateur et flux d’affiliation.
- [x] Cible documentée:
  - recentrer le premier écran sur:
    - montant cadre négocié
    - affiliés inclus / activables
    - offre incluse par affilié
  - puis faire dériver automatiquement la synthèse affilié/cadre/hors cadre depuis le moteur global.

## PATCH Étape 2A — simplification finale BO `mode_facturation` (2026-03-09)
- [x] Surfaces BO + migration:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Donnée ajoutée:
  - `ecommerce_reseau_contrats_affilies.mode_facturation`
  - valeurs:
    - `cadre`
    - `hors_cadre`
- [x] UI minimale ajoutée:
  - nouvelle colonne `Facturation` dans la liste des affiliés du siège;
  - select léger pilotable par affilié:
    - `Inclus dans le cadre`
    - `Facturé en plus`
  - rappel visuel de l’effet facture courant.
- [x] Migration de simplification:
  - les anciennes délégations actives issues TdR sont converties en `hors_cadre`;
  - le BO permet ensuite de reclasser explicitement un affilié en `cadre` quand il est absorbé par la négociation.
- [x] Vérification:
  - `php -l` OK sur `bo_reseau_contrats_list.php`, `bo_reseau_contrats_script.php`.

## PATCH 2026-03-09 — BO contrat cadre: CTA état explicite + synthèse agrégat
- [x] Surfaces BO ajustées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] CTA métier ajoutés:
  - `Activer un contrat cadre`
  - `Modifier le contrat cadre`
  - `Clôturer ce contrat cadre`
- [x] Effet attendu:
  - `Activer` -> `contract_state=actif`
  - `Clôturer` -> `contract_state=cloture`
  - refresh immédiat de l’agrégat réseau et du reclassement cadre / hors cadre
- [x] Synthèse BO ajustée:
  - affiche l’état explicite du contrat cadre;
  - sépare `Cadre négocié` et `Socle appliqué à l’agrégat`;
  - n’autorise l’activation dans le cadre que si le contrat est `actif`.
- [ ] Migration requise:
  - ajouter la colonne SQL `ecommerce_reseau_contrats.contract_state`;
  - sans cette colonne, la page n’a qu’un fallback legacy de lecture et affiche un warning opérateur.

## PATCH Étape 2A — simplification BO contrat cadre réseau TdR (2026-03-09)
- [x] Surfaces BO ajustées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] UI simplifiée:
  - suppression des CTA de maintenance `Créer / rattraper offre réseau dédiée` et `Raccrocher offres déléguées legacy` de la page courante;
  - affichage en lecture seule de la ligne support du contrat réseau, avec lien discret vers la ligne `offres_clients`;
  - renommage métier:
    - `Montant socle réseau HT / mois` -> `Montant cadre négocié (HT)`;
    - `Socle réseau` -> `Cadre négocié`;
  - masquage du premier écran pour les champs legacy / techniques:
    - `Jauge cible (référentiel)`
    - `Offre cible de délégation (catalogue)`
  - conservation des paramètres encore utilisés par l’activation réseau:
    - `max_affilies_activables`
    - `max_joueurs_par_affilie`
- [x] Garde-fou script:
  - `save_contrat` réutilise désormais les valeurs déjà persistées si certains champs ne sont plus postés par l’écran simplifié.
- [x] Audit métier associé:
  - la formule actuelle reste:
    - `montant facturable TdR = montant_socle_ht + somme des offres déléguées legacy actives`;
  - aucune donnée existante ne distingue en code / DB:
    - affilié déjà couvert par le cadre négocié;
    - affilié réellement hors cadre.
- [ ] TODO:
  - introduire une donnée explicite de couverture cadre avant toute correction sûre de double comptabilisation.

## PATCH Étape 2B — filtre BO TdR sur les offres déléguées legacy (2026-03-09)
- [x] Surface BO corrigée:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
- [x] Règle retenue:
  - sur une fiche client TdR (`flag_client_reseau_siege=1`), une ligne legacy déléguée est identifiée par:
    - `ecommerce_offres_to_clients.id_client = siège`
    - `ecommerce_offres_to_clients.id_client_delegation > 0`
- [x] Correction appliquée:
  - exclusion de ces lignes de la section `Offres` de la fiche client TdR;
  - conservation des offres propres TdR et de la ligne support `Contrat cadre réseau`;
  - correction complémentaire fiche client affilié:
    - inclusion des lignes legacy où `id_client_delegation = affilié` et `id_client <> affilié`;
    - affichage simple du nom du compte TdR dans la colonne `Délégation`;
  - aucun ajout de section dédiée “Offres déléguées”.
- [x] Vérification attendue:
  - la synthèse métier reste portée par `reseau_contrats`;
  - aucun impact sur la persistance, la facturation réseau ou le resolver d’accès jeu.

## AUDIT Étape 2B — portage des offres déléguées réseau sur l’affilié (2026-03-09)
- [x] Audit ciblé surfaces BO / write path:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`
- [x] Constat vérifié:
  - la fiche client BO du siège liste encore brut `ecommerce_offres_to_clients.id_client = siège`, donc inclut les lignes déléguées legacy;
  - le module BO `reseau_contrats` n’engendre pas encore une ligne d’offre portée par l’affilié: il sélectionne / active une ligne legacy existante du siège via `id_offre_client_deleguee`;
  - le seul write path générique exposant `id_client_delegation` reste le CRUD table-driven `offres_clients`, explicitement étiqueté legacy.
- [x] Conséquence:
  - le BO n’a pas encore de chemin métier complet “créer une offre affiliée portée par l’affilié avec origine TdR”.
- [x] Décision:
  - pas de patch UI-only sur la fiche client TdR;
  - la correction sûre passe par un write path métier dédié + migration de lecture BO pour séparer offres propres TdR et offres issues TdR portées par affilié.

## PATCH Étape 2A — facturation persistée de l’offre réseau TdR (2026-03-09)
- [x] Surfaces BO alignées:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
  - `www/web/bo/cron_routine_bdd_maj.php`
- [x] Correction appliquée:
  - le BO `reseau_contrats` édite désormais le `montant_socle_ht` et affiche le montant facturable total de la TdR;
  - le prix persistant de la ligne support suit le recalcul métier centralisé;
  - les écrans BO lisant `ecommerce_offres_to_clients.prix_ht` restent cohérents sans patch UI dispersé.
- [x] Migration SQL:
  - ajout du champ `ecommerce_reseau_contrats.montant_socle_ht`;
  - script rendu idempotent par garde `INFORMATION_SCHEMA`.
- [x] Vérification:
  - `php -l` OK sur `bo_reseau_contrats_list.php`, `bo_reseau_contrats_script.php`, `cron_routine_bdd_maj.php`.
- [x] Ajustement BO complémentaire:
  - suppression des warnings d’affichage dus à un appel invalide de `montant(...)` dans la synthèse BO;
  - répercussion du montant facturable TdR dans la section `Offres` de la fiche client siège, sur la ligne `Contrat cadre réseau`.

## AUDIT Étape 2A — affichage BO offres TdR + montant contrat réseau legacy (2026-03-09)
- [x] Audit ciblé BO fiche client siège:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Constat vérifié:
  - la section `Offres` de la fiche client TdR liste brut les lignes `ecommerce_offres_to_clients` du siège, sans filtre excluant `id_client_delegation>0`;
  - le prix affiché dans cette section lit `eotc.prix_ht` brut, pas le montant réseau agrégé;
  - la vue BO `reseau_contrats` synchronise bien les délégations legacy dans le contrat dédié, mais n’affiche pas le montant agrégé.
- [ ] TODO hors périmètre:
  - décider si la fiche client BO legacy `Offres` doit masquer ou distinguer les lignes déléguées.

## PATCH Étape 2A — BO backfill offre réseau dédiée (2026-03-08)
- [x] Module BO réseau renforcé:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
- [x] Actions ajoutées:
  - auto-ensure de l’offre réseau dédiée à l’ouverture de la page contrat réseau siège.
  - bouton BO `Créer / rattraper offre réseau dédiée`.
  - action script `mode=backfill_siege` avec retour `backfill_ok`.
- [x] Vérification:
  - `php -l` OK sur les fichiers BO `reseau_contrats`.

## PATCH Étape 2 — Contrat cadre réseau BO (2026-03-06)
- [x] Nouveau module BO dédié (pilotage siège):
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_module_parametres.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - migration: `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Entrée fiche client siège:
  - `www/web/bo/www/modules/entites/clients/bo_clients_view.php` (CTA `Gestion contrat réseau / délégation`).
- [x] UX de transition clarifiée:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`
  - champ délégation étiqueté legacy pour orienter vers le module métier dédié.
- [ ] TODO post-lot (`www`):
  - compléter la visibilité BO du journal d’actions réseau (liste/filtre dédié).
  - intégrer un contrôle explicite sur la résolution d’offre déléguée au moment de l’activation (si aucune ligne n’existe).

## AUDIT #4 — Delegation write path (id_client_delegation) (2026-03-06)
- [x] Write path confirmé côté BO:
  - le module `offres_clients` expose `id_client_delegation`:
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:39`
  - ajout/modification activés sur ce module:
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:299`
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:300`
    - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:301`
  - exécution via script master générique:
    - `www/web/bo/master/bo_master_script.php:15`
    - `www/web/bo/master/bo_master_script.php:20`
    - `global/web/lib/core/lib_core_module_functions.php:736`
- [x] Résultat audit:
  - pas de chemin métier dédié "déléguer offre" dans `www`; write possible via CRUD table-driven.
  - note détaillée: `notes/delegation-write-path-2026-03-06.md`
- [x] Next steps Lot 2 (`www`) réalisés:
  - ajout d’un entrypoint BO explicite via module `ecommerce/reseau_contrats`.
  - restriction du pilotage réseau par CRUD brut (module dédié + verrouillage générique côté socle).
- [ ] Next step restant:
  - afficher un audit trail métier BO plus complet (vue dédiée des actions historiques).

## AUDIT #2 — Offer lifecycle hooks (OFF/ON) (2026-03-06)
- [x] Hooks OFF confirmés (scope `www`):
  - cron principal d’inactivation:
    - impayé > 30 jours: `www/web/bo/cron_routine_bdd_maj.php:47` (`id_etat=10`)
    - expiration PAK: `www/web/bo/cron_routine_bdd_maj.php:73` (`id_etat=4`)
    - expiration ABN one-shot: `www/web/bo/cron_routine_bdd_maj.php:100` (`id_etat=4`)
    - expiration ABN sans engagement: `www/web/bo/cron_routine_bdd_maj.php:140` (`id_etat=4`)
  - BO manuel:
    - module `offres_clients` expose `id_etat` et autorise `modifier/supprimer`:
      - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:15`
      - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:299`
    - update SQL générique:
      - `global/web/lib/core/lib_core_module_functions.php:736`
    - delete SQL générique:
      - `global/web/lib/core/lib_core_module_functions.php:833`
- [x] Cartographie consolidée:
  - voir note: `notes/offer-lifecycle-hooks-2026-03-06.md`
- [ ] TODO Lot 3B (`www`):
  - ajouter un point de hook post-update/post-delete dans le cron `cron_routine_bdd_maj.php` pour déclencher la cascade délégation après chaque OFF.
  - cadrer le mode manuel BO: forcer une route dédiée (ou hook table-aware) pour ne pas rater la cascade quand `id_etat` est changé depuis le CRUD générique.
  - distinguer les causes OFF dans le cron (`UNPAID_TIMEOUT`, `EXPIRED_PAK`, `EXPIRED_ABN_ONESHOT`, `EXPIRED_ABN_NO_COMMITMENT`) pour propagation et audit.

## AUDIT #1 — Offer resolution (source of truth) (2026-03-06)
- [x] Constat scope `www`:
  - aucun resolver principal "offre active" défini dans ce repo.
  - usages observés: reporting/BO via `app_ecommerce_offres_client_get_liste(...)` (`www/web/bo/www/modules/entites/clients/bo_clients_list.php:61`, `www/web/bo/www/modules/syntheses/resumes/bo_resumes_list.php:1315`).
  - gestion des dates portée surtout par cron de transition d’état (`www/web/bo/cron_routine_bdd_maj.php:62`, `:73`, `:89`, `:100`).
- [ ] TODO Lot 1 (`www`):
  - éviter d’ajouter de nouvelles règles de résolution locale côté BO.
  - documenter explicitement que la source de vérité runtime réside dans `global`.

## AUDIT Réseau / Affiliation / Branding / Contenus partagés (2026-03-06)
- [x] Patch V1 landings operations distributeurs / marques (2026-05-07):
  - ajout de `www/web/lp/includes/config/lp_operations.php` comme configuration dediee des operations;
  - ajout de la route publique `/lp/operation/{slug}` dans `www/web/.htaccess`;
  - `www/web/lp/lp.php` charge les operations actives depuis la config et conserve le parcours d'activation via `/utm/reseau/{network_slug}`;
  - lecture publique, sans session PRO, du compte reseau et du branding reseau quand les helpers existants sont disponibles;
  - lecture du `visuel` branding reseau pour le hero quand `hero_image` n'est pas force en configuration;
  - lecture des contenus reseau partages via `app_ecommerce_reseau_content_share_ids_get(...)`, en affichant uniquement les jeux reseau exploitables quand ils existent;
  - affichage de deux actions signup/signin dans la landing, mais toutes deux conservent le parcours PRO reseau existant via `/utm/reseau/{slug}`;
  - fallback Cotton si le reseau ou son branding n'est pas disponible;
  - separation UI explicite entre offre commerciale produit et animation Cotton;
  - clarification obligatoire affichee pres des CTA: l'acces Cotton concerne uniquement l'animation de l'etablissement, l'offre commerciale produit reste geree par le distributeur;
  - une route operation non configuree ou desactivee renvoie une page 404 simple au lieu de retomber sur `offre-essai`.
- [ ] Recette V1 landings operations distributeurs / marques:
  - activer une entree config avec une vraie TdR operation;
  - verifier rendu desktop/mobile, logo reseau/fallback, couleurs et image hero;
  - verifier que le visuel reseau remonte quand `hero_image` est vide;
  - verifier que les contenus reseau partages remplacent les demos generiques, et que le fallback generique reste actif sans contenu reseau;
  - verifier le CTA `/utm/reseau/{slug}` vers PRO signup/signin;
  - verifier creation nouveau compte, connexion compte existant, quota atteint, support reseau inactif et compte deja rattache;
  - verifier que la landing ne promet pas l'activation automatique de l'offre commerciale produit.
- [x] Cartographie confirmée (preuves code):
  - Réécriture publique lien affiliation réseau:
    - `www/web/.htaccess:118` (`/utm/reseau/{seo_slug}` -> `/fo/fo.php?utm_source=reseau&utm_campaign=affiliation&utm_term=...`)
    - `www/web/.htaccess:121` (variante avec code remise)
  - Passage vers `pro`:
    - `www/web/fo/fo.php:64`
    - `www/web/fo/fo.php:67`
    - `www/web/fo/fo.php:71`
  - Flag réseau dans BO:
    - `www/web/bo/www/modules/entites/clients/bo_module_parametres.php:96` (`flag_client_reseau_siege`)
    - `www/web/bo/www/modules/entites/clients/bo_module_parametres.php:107` (`id_client_reseau`)
  - Lien d’affiliation affiché en BO:
    - `www/web/bo/www/modules/entites/clients/bo_clients_list.php:144`
- [x] Existant confirmé:
  - Le BO permet de marquer un client “tête de réseau” et de renseigner l’appartenance réseau (champs `clients.flag_client_reseau_siege` / `clients.id_client_reseau`).
  - Le lien d’affiliation affiché est de type slug (`/utm/reseau/{seo_slug}`), sans token dédié.
  - La landing publique `www` consomme les paramètres UTM puis redirige vers `pro` avec ces mêmes paramètres.
- [ ] Manques identifiés (scope `www`):
  - Pas de génération/rotation/révocation de token d’affiliation réseau dans BO.
  - Pas de TTL/signature/HMAC spécifique au lien d’affiliation réseau.
  - Pas de journal d’audit dédié “création/rotation/révocation lien affiliation réseau”.
- [ ] Risques:
  - Lien basé sur slug prédictible.
  - Paramètres UTM manipulables côté URL.
  - Absence de mécanisme d’expiration pour le lien d’affiliation réseau.

## PATCH BO Reporting — Sessions papier dans `Jeux et joueurs` (2026-02-28)
- [x] Audit ciblé:
  - entrée: `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - constats:
    - le total `Sessions` excluait des sessions papier via un filtre “has players” sur certains chemins.
    - les ratios `joueurs/client` et `joueurs/session` utilisaient les mêmes agrégats de sessions.
- [x] Correctifs appliqués:
  - `Sessions` (table + totals + série N-1): comptage des sessions terminées et configurées, papier + numérique (toujours hors démo).
  - ajout d’un agrégat dédié `sessions numériques` (sessions avec joueurs) utilisé uniquement pour les ratios joueurs:
    - `Moy. joueurs / client`
    - `Moy. joueurs / session` (global + par jeu).
  - note UI explicite mise à jour dans le bloc `Jeux et joueurs`.
- [x] Vérification technique:
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] QA manuelle BO:
  - une session papier terminée sans joueurs doit incrémenter `Sessions` (mois + total).
  - cette session ne doit pas augmenter les ratios `joueurs/client` et `joueurs/session`.
  - une session numérique avec joueurs doit continuer d’alimenter `Joueurs` + ratios.

## PATCH BO Reporting — Démos période de référence (2026-02-28)
- [x] Audit ciblé:
  - Entrée reporting: `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - Zones impactées:
    - endpoint AJAX détail démos (`bo_facturation_pivot_saas_handle_games_demo_detail_ajax`)
    - agrégations mensuelles (`$demo_sessions`, métrique démos nouveaux inscrits)
    - section `Objectifs`
    - tableau `Visiteurs / prospects / clients`
    - libellés modal JS
- [x] Correctifs appliqués:
  - `Objectifs > Demos`: ajout des démos des nouveaux inscrits de la période de référence.
## Done (2026-03-23)
- [x] BO clients: ajout d'une action `Generer un lien EC temporaire` par contact sur la fiche client `www/web/bo/www/modules/entites/clients/bo_clients_view.php`.
- [x] BO clients: ajout du mode `generer_lien_ec_temporaire` dans `www/web/bo/www/modules/entites/clients/bo_clients_script.php`, avec verification que le contact est bien rattache au client avant generation.
- [x] BO clients: retour sur la meme fiche avec l'URL complete prete a copier, sans exposition cote front EC standard.
- [x] Verification technique:
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_script.php`
  - `php -l www/web/bo/www/modules/entites/clients/bo_clients_view.php`

  - Tableau: renommage `Demos inscrits` -> `Démos nvx inscrits`.
  - Recalcul colonne: client inscrit dans la période ET session démo dans la période.
  - Détail modal `scope=users`: aligné sur le même filtre de période (pour cohérence clic/agrégat).
- [x] Sémantique vérifiée:
  - colonne historique conservée en volume de **sessions démo** (pas distinct inscrits).
- [x] Vérification technique:
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php` OK.
- [ ] QA manuelle BO:
  - ancien inscrit + démo période => non compté dans `Démos nvx inscrits`.
  - nouvel inscrit sans démo => non compté.
  - nouvel inscrit + démo période => compté.

## Done (2026-03-08)
- [x] Étape 2A fix ciblé: branchement du vrai point d’entrée BO de création/rattrapage offre réseau dédiée dans `bo_clients_script.php` au moment des modifications client avec `flag_client_reseau_siege=1`.
- [x] Étape 2A fix ciblé: module BO `reseau_contrats` enrichi d’une action explicite de sync legacy des offres déléguées et auto-sync au chargement de la fiche contrat.
- [x] 2026-03-08 — UX BO fiche client TdR: suppression du CTA d’intro `Gestion contrat réseau / délégation`; ajout du CTA `Gérer le contrat` uniquement sur la ligne d’offre `Contrat cadre réseau` (slug `contrat-cadre-reseau`) vers la même vue `?a=www&t=ecommerce&m=reseau_contrats&p=list&id_client_siege=<id>`.
- [x] 2026-03-10 — Audit runtime BO `offres_clients`: le vrai write path du passage manuel à `Terminée` reste `do_script.php -> bo_offres_clients_script.php -> mode=modifier`; fix appliqué sur la garde métier pour reconnaître aussi les lignes support legacy déjà liées au contrat réseau (`id_offre_client_contrat`).
- [x] 2026-03-10 — Audit runtime BO `offres_clients`: le `id_etat=4` du save était réécrit par le refresh générique post-`module_modifier(...)`; bypass ciblé ajouté uniquement pour le cas explicite `offre support réseau -> Terminée`, afin de laisser le hook de clôture réelle s’exécuter.
- [x] 2026-03-11 — BO `offres_clients`: abandon du patch opportuniste dans le form générique; ajout d’un renderer dédié `Abonnement réseau` via hook minimal dans `bo_master_form.php`, et retour du form classique `offres_clients` au comportement historique hors contexte réseau.
- [x] 2026-03-11 — BO `offres_clients` view: ajout d’un hook minimal `bo_module_view_flags.php` pour masquer le bloc historique `Informations` uniquement sur le support canonique `Abonnement réseau`.
- [x] 2026-03-11 — BO réseau: `date_debut` et `date_facturation_debut` sont désormais transmises par `bo_offres_clients_script.php` et persistées explicitement par `app_ecommerce_reseau_abonnement_bo_sync_offer_client(...)`, ce qui réaligne l’affichage `Début` / `Début fact.` sur la fiche client TdR.
- [x] 2026-03-11 — BO `offres_clients` view: ajout d’un hook minimal `bo_module_view_top.php` pour rendre le bloc `Abonnement réseau` en haut de la colonne de gauche avant `Caractéristiques`, avec affichage lecture seule de `date_debut` et `date_facturation_debut`.
- 2026-03-09: bo/reseau_contrats
  - faire retourner `activate_contract` sur un état `en attente de paiement` au lieu d'une activation commerciale immédiate;
  - exposer le lien Stripe de l'offre réseau support dans l'écran BO quand l'offre reste `pending_payment`.

## Done (2026-03-13)
- [x] Routine BO `cron_routine_bdd_maj.php`: ajout de l'execution des remplacements differes d'offres deleguees hors cadre. La routine scanne les cibles planifiees (`id_etat=2` + marqueur de remplacement differe), puis active la cible apres terminaison effective de la source.

## Done (2026-03-20)
- [x] BO reporting jeux: extraction initiale du bloc `Reporting jeux (agregats)` hors de `www/web/bo/cron_routine_bdd_maj.php` vers un helper reutilisable.
- [x] BO reporting jeux: ajout du cron dedie `www/web/bo/cron_reporting_games_aggregates.php` pour permettre un lancement isole des agregats jeux sans executer toute la routine BDD.
- [x] BO `facturation_pivot`: branchement preferentiel des sessions mensuelles sur `reporting_games_sessions_monthly` et des sessions numeriques sur `reporting_games_sessions_detail`.
- [x] BO `facturation_pivot`: branchement preferentiel de la serie N-1 jeux sur `reporting_games_sessions_monthly` quand le cache cron est disponible.
- [x] Portage separe sur `main` du meme correctif BO reporting jeux, sans merge `develop` vers `main`, pour un test/prod isole.
- [x] Verification technique:
  - `php -l www/web/bo/cron_reporting_games_aggregates.php`
  - `php -l www/web/bo/cron_routine_bdd_maj.php`
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`

## Done (2026-03-30)
- [x] BO reporting jeux: retrait definitif de l'appel aux agrégats jeux dans `www/web/bo/cron_routine_bdd_maj.php` pour laisser ce cron au perimetre "commerce".
- [x] BO reporting jeux: deplacement du helper vers `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php` avec point d'entree explicite `bo_facturation_pivot_games_aggregates_refresh()`.
- [x] BO reporting jeux: evolution de `www/web/bo/cron_reporting_games_aggregates.php` en vrai cron "jeux" avec envoi de mail de rapport via Brevo.
- [x] Verification technique:
  - `php -l www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php`
  - `php -l www/web/bo/cron_reporting_games_aggregates.php`
  - `php -l www/web/bo/cron_routine_bdd_maj.php`

## Done (2026-04-14)
- [x] FO includes `photos_ec`: réalignement des includes FO (`fo_custom.css`, `fo_custom_20251120.css`, `fo_header_main.php`, `fo_footer_main.php`, `fo.js`) sur `main` après resynchronisation locale depuis prod.
- [x] FO includes `photos_ec`: restauration des styles perdus sur les logos de références et les images harmonisées catalogue, sans toucher aux évolutions métier de branche sur `place` et `agenda/session`.
- [x] Vérification technique:
  - `php -l www/web/fo/includes/header/fo_header_main.php`
  - `php -l www/web/fo/includes/footer/fo_footer_main.php`
- [x] FO fiche `place`: suppression du rendu serveur initial pour les onglets `Agenda` et `Sessions passées` dans `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`.
- [x] FO fiche `place`: ajout du chargement AJAX par section via `www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php` (`overview`, `agenda`, `archive`).
- [x] FO fiche `place`: mutualisation du rendu sessions FO dans `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`.
- [x] FO fiche `place`: bascule automatique de l'onglet initial vers `Agenda` si la réponse AJAX `overview` confirme l'absence de classements exploitables.
- [x] FO fiche `place`: séparation des requêtes AJAX `overview` (classements) et `summary` (synthèse) pour laisser les leaderboards s'afficher avant le calcul historique plus lourd.
- [x] FO fiche `place`: ajout d'un cache de session dédié aux leaderboards par `id_client + jour + année + trimestre`, sans impact sur `pro` / `play`.
- [x] FO liste `place`: alignement du filtre géographique sur le pattern `agenda/play` avec support des pays étrangers en plus des départements FR réellement présents.
- [x] FO liste `place`: conservation des libellés départements référentiels complets (`n° + nom`) dans le select public.
- [x] FO listes `agenda` / `place`: exclusion explicite de `France` de la section `pays`, les départements FR restant l'unique point d'entrée côté France.
- [x] Header FO: raccourci du libellé dropdown joueur vers `Agenda des soirées jeux` avec protection CSS `white-space: nowrap` sur la navigation desktop.
- [x] Archive FO `place`: hardening du helper global `cotton_quiz_get_classement_session(...)` pour éviter un fatal legacy sur certaines sessions quiz passées.
- [x] Archive FO `place`: remplacement du rendu AJAX des sessions passées par une carte dédiée dans `fo_clients_view_shared.php`, sans réutiliser le bloc legacy complet `fo_sessions_list_bloc.php`.
- [x] FO fiche `place` / archives: ajout d'un helper global `app_client_joueurs_dashboard_archive_sessions_get(...)` reprenant la logique de sélection des archives pro pour les sessions passées utiles du lieu.
- [x] FO fiche `place` / leaderboards: la colonne `sessions récentes` réutilise désormais ce helper global partagé avec filtre jeu/date, au lieu d'une logique locale.
- [x] FO fiche `place` / agenda AJAX: remplacement du rendu legacy `fo_sessions_list_bloc.php` par une carte FO dédiée dans le contexte asynchrone.
- [x] FO fiche `place` / filtre saison: correctif JS sur l'appel `loadOverview(...)` pour transmettre correctement `filter_year` et `filter_quarter`.
- [x] Vérification technique:
  - `php -l www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## Done (2026-04-16)
- [x] FO fiche `place`: harmonisation du rendu `descriptif_court` / `descriptif_long` avec le back-office `pro`.
- [x] FO fiche `place`: nettoyage des anciens `<br>` / balises legacy avant rendu public.
- [x] FO fiche `place` / onglet `Sessions passées`: les visuels des cartes injectées en AJAX ne passent plus par `js-lazy`, ce qui réactive l'affichage du fallback image de jeu quand aucune photo gagnant n'existe.
- [x] Vérification technique:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `php -l www/web/fo/modules/entites/clients/fr/fo_clients_view_ajax.php`
  - `php -l www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## PATCH 2026-04-17 — Agenda / sessions passées: bascule FO alignée sur la terminaison réelle
- [x] Audit ciblé:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
  - `www/web/fo/modules/widget/fr/fo_widget_cotton_agenda.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - l'onglet `Agenda` des fiches `place`, la liste publique `agenda` et le widget agenda n'utilisent plus seulement le critère calendrier;
  - les listes sont maintenant re-filtrées via la règle partagée `archive` vs `upcoming`, cohérente avec les fiches détail;
  - le bloc carte FO calcule aussi `Jeu terminé` via le helper partagé au lieu du simple `app_session_get_chronology(...)`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/widget/fr/fo_widget_cotton_agenda.php`

## PATCH 2026-04-17 — FO `Sessions passées`: inclusion des sessions du jour déjà terminées
- [x] Audit ciblé:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livré:
  - le helper `fo_clients_view_archive_sessions_get(...)` rappelle maintenant l'archive globale avec `include_upcoming_sessions = 1`;
  - effet attendu: une session du jour déjà terminée, masquée de l'onglet `Agenda`, devient aussi visible dans `Sessions passées` sans attendre le lendemain.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## PATCH 2026-04-17 — FO `place`: podium agrégé `Bingo Musical` éclaté par ligne comme les autres jeux
- [x] Audit ciblé:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- [x] Correctif livré:
  - suppression de la branche spéciale `bingo` dans `fo_clients_view_leaderboard_podium_cards_get(...)`;
  - le podium agrégé `www` utilise maintenant la même règle que les autres jeux: une carte par ligne de podium, même en cas d'ex-aequo sur un rang.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`

## PATCH 2026-04-17 — WWW sessions: libellé `quiz` compact sur cartes et titre détail
- [x] Audit ciblé:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
- [x] Correctif livré:
  - les cartes `Agenda` / `Sessions passées` de la fiche `place` affichent maintenant `quiz_series_label` en priorité pour `Cotton Quiz`;
  - les cartes génériques `agenda` du site utilisent la même priorité;
  - le `h1` de la page détail session `www` utilise lui aussi ce libellé court;
  - si aucun libellé de séries n'est disponible, le fallback garde `theme`, sauf s'il duplique déjà `nom_court`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`

## PATCH 2026-04-17 — WWW sessions: raccord au helper partagé de libellé compact `quiz`
- [x] Audit ciblé:
  - `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - les écrans `www` reposent désormais sur `app_session_quiz_compact_label_get(...)` au lieu d'une logique locale dupliquée;
  - le fallback conserve `theme` hors libellé compact, sans réintroduire le doublon `Cotton Quiz Cotton Quiz`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`

## PATCH 2026-04-17 — Fiche session `www`: mention de réserve sous les séries programmées
- [x] Audit ciblé:
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
- [x] Correctif livré:
  - ajout de la mention `(Sous réserve de modification par l'organisateur.)` sous le bloc `Séries programmées`;
  - la mention n'est affichée que pour les sessions non archivées.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`

## PATCH 2026-04-17 — Fiche session `www`: bloc `Playlist` visible aussi pour `blindtest` / `bingo`
- [x] Audit ciblé:
  - `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
- [x] Correctif livré:
  - ajout d'un bloc `Playlist : {nom_playlist}` entre `Date` et `Lieu` pour les sessions `blindtest` / `bingo` quand une playlist est disponible;
  - ajout de la même mention de réserve sous ce bloc, tant que la session n'est pas archivée.
- [x] Vérification:
  - `php -l /home/romain/Cotton/www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`

## Done (2026-04-15)
- [x] FO fiche `place` / perf lot 1: la route AJAX `overview` ne recharge plus la liste complète des `sessions passées` ni l'agenda complet pour calculer les flags d'onglets.
- [x] FO fiche `place` / perf lot 1: ajout de helpers FO légers `has_agenda` / `has_archive` limités à 1 résultat.
- [x] FO fiche `place` / perf lot 1: le helper partagé des archives ne recharge plus les sessions à venir quand l'usage ne concerne que l'historique.
- [x] FO fiche `place` / onglet `Sessions passées`: illustration des cartes par la photo du rang 1 quand elle existe, sinon fallback sur le visuel actuel.
- [x] FO fiche `place` / onglet `Sessions passées`: ajout d'un bouton `Afficher plus` chargeant 12 cartes supplémentaires par lot en AJAX.
- [x] FO fiche `place` / onglet `Classements`: retrait de la colonne desktop `sessions récentes`, avec conservation du bloc en commentaire pour réutilisation future sans coût de calcul.
- [x] FO fiche `place` / onglet `Classements`: ajout d'un podium agrégé au-dessus du tableau `Top 10`.
- [x] FO fiche `place` / onglet `Classements`: réutilisation des données globales `players_podium` / `teams_podium`, comme côté `pro`.
- [x] FO fiche `place` / onglet `Classements`: reprise du style visuel du podium affiché sur la page détail d'une session terminée du site.
- [x] FO fiche `place` / onglet `Classements`: retour de la limite desktop `sessions récentes` sur la seule hauteur du tableau, avec podium étendu au-dessus sur toute la largeur.
- [x] FO fiche `place` / onglet `Classements`: ajout d'un espacement desktop `justify-content-between` / gutters renforcés sur la ligne `classement + sessions récentes`.
- [x] FO fiche `place` / onglet `Classements`: audit structurel puis refactor de la colonne `sessions récentes` avec suppression du `padding-top` desktop et wrapper centré à largeur max.
- [x] FO fiche `place` / onglet `Classements`: hardening responsive mobile du tableau via wrapper explicite `place-leaderboard-table-responsive` + nettoyage du `rem` CSS parasite.
- [x] FO fiche `place` / onglet `Classements`: ajout d'une largeur minimale mobile sur `.table-classement` pour forcer le scroll horizontal au lieu du tassement/coupage des colonnes.
- [x] Vérification technique:
  - `php -l www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
## PATCH 2026-05-11 — LP operations reseau automatiques depuis TdR
- [x] Audit cible:
  - `www/web/lp/lp.php`
  - `www/web/.htaccess`
  - `www/web/lp/includes/css/lp_custom.css`
  - `www/web/lp/includes/config/lp_operations.php`
  - helpers reseau/TdR: `global/web/app/modules/ecommerce/app_ecommerce_functions.php`, `global/web/app/modules/entites/clients/app_clients_functions.php`, `global/web/app/modules/general/branding/app_branding_functions.php`
- [x] Correctif livre:
  - suppression de la dependance de publication a `lp_operations.php`;
  - resolution automatique de `/lp/operation/{slug}` depuis une operation BO (`operations_evenements.seo_slug`) rattachee a une TdR, ou depuis la TdR (`clients.seo_slug`) en fallback;
  - affichage du nom, accroche, descriptif, logo, visuel, couleurs, periode et jeux reseau quand disponibles;
  - CTA unique vers `/utm/reseau/{slug}` et phrase compte existant sans second CTA equivalent;
  - badge/CTA/wording conditionnes par la presence d'un abonnement reseau actif exploitable, sans conditionner l'existence de la LP a cet abonnement;
  - wording Cotton neutralise, sans promesse commerciale distributeur ajoutee.
- [x] Garde-fous:
  - slug invalide/inconnu, operation privee, operation sans TdR exploitable, compte non TdR ou compte offline => 404 simple;
  - anciennes LP historiques conservees hors route `landing-operation`.
- [ ] Verification serveur a completer avec une TdR reelle:
  - landing publiee sans config manuelle;
  - cas slug inexistant, TdR inactive, TdR sans abonnement, abonnement sans dates, donnees/design/jeux absents.

## PATCH 2026-05-19 — BO Jeux: statuts playlists separes
- [x] Audit cible:
  - `www/web/bo/www/modules/jeux/_lib/bo_jeux_readonly_lib.php`
  - `www/web/bo/www/modules/jeux/playlists/bo_playlists_list.php`
  - `www/web/bo/www/modules/jeux/playlists/bo_playlists_view.php`
- [x] Correctif livre:
  - separation de la colonne playlist `Statut` en `Publication`, `Validation`, `Communaute`;
  - origine `Communaute` basee aussi sur `flag_share_community=1`, pas seulement sur `community_items`;
  - suppression du filtre `Usage` dans la liste playlists;
  - libelles d'origine et de statut alignes: `Communauté`, `Privées`, `Publiée`, `Non publiée`, `Validée`, `Non validée`, `Partagée`, `Non partagée`;
  - colonne `Communauté` masquee quand le filtre actif est `Cotton` ou `Privées`;
  - colonne `Auteur / client` masquee quand le filtre actif est `Cotton`;
  - liens de tri/pagination conservant explicitement `origin=` quand le filtre `Origine` affiche tous les contenus;
  - boutons `Fiche PRO` rendus visibles et bloc `Alertes qualite` retire de la fiche playlist;
  - liens `Fiche PRO` contextualises avec `game`, `type` et `community_state` selon l'origine/statut du contenu;
  - tableau playlists rendu responsive par conteneur scrollable et largeur minimale stable;
  - pagination locale retiree au profit du bloc BO historique, avec conservation des filtres/tri via `$bo_pagination_extra_query`;
  - tri lecture seule disponible sur les trois colonnes;
  - fiche playlist alignee sur les memes trois libelles.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/_lib/bo_jeux_readonly_lib.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/playlists/bo_playlists_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/playlists/bo_playlists_view.php`
  - `php -l /home/romain/Cotton/www/web/bo/master/bo_master_pagination_design.php`

## PATCH 2026-05-19 — BO Jeux: series alignees sur playlists
- [x] Correctif livre:
  - suppression de l'entree menu `Vue d'ensemble` et des fichiers dashboard `Jeux`;
  - liste `Series Cotton Quiz` alignee sur playlists: filtres, tri, pagination historique, table responsive;
  - libelles separes `Publication`, `Validation`, `Communauté`;
  - origine `Communauté` basee aussi sur `flag_share_community=1`;
  - colonnes `Communauté` / `Auteur client` masquees quand elles n'apportent rien au filtre actif;
  - liens `Fiche PRO` contextualises (`game`, `type`, `community_state`);
  - fiche serie simplifiee: lien PRO, retrait du bloc `Alertes qualite`, tables responsive.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/bo.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/_lib/bo_jeux_readonly_lib.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/series/bo_series_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/series/bo_series_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/series/bo_series_view.php`

## PATCH 2026-05-19 — BO Jeux: lots T visibles dans Cotton
- [x] Correctif livre:
  - les `questions_lots_temp` (`serie_type=T`) sont classes `Cotton` dans la liste BO `Jeux > Series Cotton Quiz`;
  - le filtre `Cotton` inclut les lots `T`;
  - les filtres `Communauté` et `Privées` continuent d'exclure ces lots temporaires Cotton.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/_lib/bo_jeux_readonly_lib.php`

## PATCH 2026-05-19 — BO Jeux: CTA listes
- [x] Correctif livre:
  - remplacement du CTA `Fiche` par `Détail` dans les listes playlists et series;
  - separation visuelle du lien local BO et du lien `Fiche PRO` dans la colonne `Liens`.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/playlists/bo_playlists_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/series/bo_series_list.php`

## PATCH 2026-05-19 — BO Jeux: retour fiches visible
- [x] Correctif livre:
  - boutons `Retour aux playlists` et `Retour aux series` rendus visibles dans les fiches detail BO.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/playlists/bo_playlists_view.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/series/bo_series_view.php`

## PATCH 2026-05-19 — BO Jeux: publication A completer series
- [x] Correctif livre:
  - affichage `À compléter` dans la colonne `Publication` pour les series Cotton `questions_lots.id_etat=1`;
  - affichage `En attente` pour les series Communauté `questions_lots.id_etat=1`;
  - affichage `Publiée` pour `id_etat=2` et `Archivée` pour `id_etat=3`;
  - masquage de `Publication` sur le filtre `Privées`;
  - ajout du compteur de questions a completer dans la fiche serie.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/_lib/bo_jeux_readonly_lib.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/series/bo_series_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/series/bo_series_view.php`

## PATCH 2026-05-19 — BO Jeux: origine communaute series
- [x] Correctif livre:
  - les series `Non partagées` ne sont plus classees `Communauté` sur la seule base d'une trace `community_items`;
  - l'origine `Communauté` des series repose sur `flag_share_community=1`.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/_lib/bo_jeux_readonly_lib.php`

## PATCH 2026-05-19 — BO Jeux: colonne communaute retiree
- [x] Correctif livre:
  - retrait de la colonne `Communauté` des listes playlists et series;
  - conservation du partage/origine sur les filtres et fiches detail.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/playlists/bo_playlists_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/series/bo_series_list.php`

## PATCH 2026-05-19 — BO Jeux: publication playlists privees masquee
- [x] Correctif livre:
  - masquage de la colonne `Publication` de la liste playlists quand le filtre actif est `Privées`.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/playlists/bo_playlists_list.php`

## PATCH 2026-05-19 — BO Jeux: publication series Cotton incompletes
- [x] Correctif livre:
  - affichage `À compléter` dans `Publication` pour les series Cotton incompletes selon les criteres PRO admin, y compris si `questions_lots.id_etat=2`;
  - aucun changement DB et aucune action de modification exposee.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/_lib/bo_jeux_readonly_lib.php`

## PATCH 2026-05-19 — BO Jeux: filtre publication listes
- [x] Correctif livre:
  - ajout d'un filtre `Publication` sur les listes playlists et series;
  - filtre masque et ignore sur les vues `Privées`;
  - colonne `Origine` masquee hors vue globale toutes origines;
  - colonne `Publication` visible sur `Cotton`/`Communauté` si aucun filtre publication n'est actif, puis masquee quand `Origine` + `Publication` sont definis;
  - filtre series `Type` renomme `Classiques` / `Temporaires`, place avant `Publication`, masque sur `Communauté`/`Privées`, avec `Classiques` par defaut;
  - filtre `Publication` masque sur les series `Temporaires`.
  - auto-application des filtres select sans clic sur `Filtrer`.
  - options par defaut `Origine`/`Publication` renommees `Toutes`;
  - champ recherche place juste avant `Rechercher`; suppression du CTA `Réinitialiser`;
  - retrait de `Sans objet` pour les series `Cotton` + `Classiques`.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/_lib/bo_jeux_readonly_lib.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/playlists/bo_playlists_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/jeux/series/bo_series_list.php`

## PATCH 2026-05-20 — BO Sessions: filtres natifs jeu / format
- [x] Correctif livre:
  - suppression de la carte locale `Jeu` / `Format`;
  - enrichissement du formulaire natif via `bo_sessions_filter_extend(...)`;
  - ordre des filtres: `Client`, `Jeu`, `Format`, `Démo`, `Session complète`;
  - maintien des filtres additionnels dans `f_rechercher` pour pagination, tri et retour liste;
  - exports BO alignés via chargement des fonctions module et `bo_sessions_sql_filter_append(...)`;
  - tableau sessions rendu dans `.table-responsive`, sans masquage de colonnes desktop.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/master/bo_master_header.php`
  - `php -l /home/romain/Cotton/www/web/bo/master/bo_master_export.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_sessions_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_sessions_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_module_parametres.php`

## PATCH 2026-05-20 — BO Sessions: colonne jeu et logs
- [x] Correctif livre:
  - badge `[ NUMERIQUE ]` / `[ PAPIER ]` basé sur `championnats_sessions.flag_controle_numerique`;
  - suppression des liens `Accès Player` dans la colonne `id`;
  - ajout du lien `Voir les logs` pour tous les jeux;
  - cellule `Jeu` entière cliquable vers la fiche session via un vrai lien HTML compatible Ctrl+clic / nouvel onglet.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_sessions_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_sessions_list.php`

## PATCH 2026-05-20 — BO Sessions: participants et jauge
- [x] Correctif livre:
  - helper commun `bo_sessions_participants_label_get(...)`;
  - source liste + fiche: détail session enrichi `app_session_get_detail(...)`;
  - affichage harmonisé `x joueur(s) / y max` ou `x équipe(s) / y max`;
  - bloc `Résultats` de la fiche session aligné avec la liste.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_sessions_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_sessions_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_module_aside.php`

## PATCH 2026-05-20 — BO Sessions: filtre date et simplification liste
- [x] Correctif livre:
  - ajout d'un filtre `Date` en datepicker dans le bloc natif sessions;
  - filtre SQL sur `championnats_sessions.date`;
  - retrait du bloc Bingo `Papier / Numérique / phases` de la colonne `Jeu`;
  - `id_playlist` et `id_playlist_client` affichés sans lien dans la colonne `id`.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_sessions_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_sessions_list.php`

## PATCH 2026-05-20 — BO Sessions: format et CTA interfaces
- [x] Correctif livre:
  - ajout du `Format` sous `Type` sur la fiche session;
  - ajout d'une chip `État` dans le bloc `Informations`, basée sur `app_session_edit_state_get(...)`;
  - ligne `Interfaces` alignée dans le bloc `Informations`;
  - CTA `Organisateur` vers `/master/{token}`;
  - CTA `Joueur` vers `/play/{blindtest|bingo|quiz}/{token}`;
  - CTA `Remote` vers `/remote/{blindtest|bingo|quiz}/{token}`.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_sessions_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_module_view_top.php`

## PATCH 2026-05-20 — BO Sessions: lien playlist Bingo en fiche
- [x] Correctif livre:
  - lien de thématique Bingo aligné sur `Jeux > Playlists` via l'`id_playlist` catalogue;
  - retrait de la durée dans le libellé de format du bloc `Thématique`.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_module_aside.php`

## PATCH 2026-05-20 — BO Clients: format dans le bloc sessions
- [x] Correctif livre:
  - ajout d'une colonne `Format` dans le bloc `Sessions` de la fiche client;
  - source `app_session_get_detail(...)` / `flag_controle_numerique`;
  - rendu `Numérique` ou `Papier`.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_view.php`

## PATCH 2026-05-22 — BO remises classiques: offres réellement remisées
- [x] Correctif livre:
  - ajout d'un bloc `Offres utilisant la remise` sur la fiche `Commercial > Remise client`;
  - source réelle: `ecommerce_offres_to_clients.id_remise`;
  - affichage des offres, comptes, délégations éventuelles, états et prix HT/base;
  - séparation claire avec `Comptes concernés`, qui reste la liste des comptes éligibles ou ciblés.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_view.php`

## PATCH 2026-05-22 — BO offres clients: listing responsive desktop/mobile
- [x] Correctif livre:
  - adaptation ciblée du master list pour `ecommerce/offres_clients`;
  - desktop: tableau compact en `.table-responsive`, sans classe DataTables responsive afin de conserver un maximum de colonnes visibles;
  - mobile: activation conditionnelle de `dt-responsive nowrap`, comme sur le listing sessions, pour dérouler les colonnes masquées ligne par ligne.
- [x] Ajustement colonnes:
  - masquage liste de `Date début fact.`, `Fact. début période`, `Stripe > idProduct`, `Commentaire`, `Vendeur` et `Remise`;
  - conservation des champs en fiche détail/formulaire/export.
- [x] Ajustement lisibilité:
  - police du tableau offres clients remontée à 13px;
  - largeur minimale desktop réduite;
  - colonnes `Client`, `Délégation client` et `Offre` explicitement autorisées à revenir à la ligne.
- [x] Ajustement mobile:
  - colonnes visibles réduites à `#`, `Client`, `Offre` et actions;
  - les autres colonnes passent dans le détail responsive déroulable de DataTables.
- [x] Correctif base remise classique:
  - quand une offre porte un pourcentage de remise mais que `prix_reference_ht` est absent ou non supérieur au prix signé, la base HT est reconstruite depuis `prix_ht` et `remise_pourcentage`;
  - la colonne `Prix HT` peut ainsi afficher la base et la chip de remise pour les offres propres remisées par coupon/snapshot, sans dépendre de la logique de remise réseau déléguée.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/master/bo_master_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php`

## PATCH 2026-05-22 — BO clients: stats AJAX et bloc remises conditionnel
- [x] Correctif livré:
  - extraction du rendu stats dans `bo_clients_stats_card_html_get(...)`;
  - ajout d'un endpoint JSON sans layout `client_stats_ajax=1`;
  - chargement AJAX des stats après le chargement de la fiche client;
  - placement du bloc stats sous le bloc `Contacts`;
  - masquage du bloc `Remises` quand aucune remise active ne s'applique au compte et qu'aucune remise manuelle supplémentaire n'est disponible.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/bo.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_stats_ajax.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_module_aside.php`

## PATCH 2026-05-22 — BO navigation: reporting facturation sous Commercial
- [x] Correctif livré:
  - ajout d'un état de navigation dédié `syntheses/facturation_pivot`;
  - exclusion de ces pages de la surbrillance `Home`;
  - inclusion de ces pages dans la surbrillance principale `Commercial`.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/bo.php`

## PATCH 2026-05-22 — BO reporting SaaS: colonne essais gratuits
- [x] Correctif livré:
  - ajout de la colonne `Essais gratuits` dans `Visiteurs / prospects / clients`, entre `Démos nvx inscrits` et `Nvx clients`;
  - comptage historique des comptes dont une offre abonnement active ou terminee, payante/non offerte, a un debut d'essai ecommerce dans le mois;
  - date de reference fixee a `date_debut`, avec fin d'essai affichee a 15 jours;
  - inclusion des essais termines ou factures apres le debut d'essai, mais exclusion des offres encore `En attente`;
  - exclusion des offres dont une facture editee liee porte la meme date que `date_debut`;
  - detail mensuel cliquable vers la liste des comptes, avec liens fiches clients, offre, debut et fin d'essai.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - `git diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`

## PATCH 2026-05-22 — BO tracking: actions lisibles dans les logs clients
- [x] Correctif livré:
  - ajout d'un rendu dedie de la cellule `Action` du listing `Tracking > Logs clients`;
  - extraction du rendu dans `bo_clients_logs_functions.php` pour reutilisation;
  - application du meme rendu aux blocs `Logs` externalises des fiches client/contact;
  - conservation des valeurs brutes `clients_logs.nom` en base;
  - classification des navigations `Page : t > m > p` en zones `Authentification`, `Compte`, `Offres`, `Agenda`, `Jeux`, `Réseau`;
  - affichage de la route brute en detail discret;
  - fallback `Système` pour les actions non reconnues.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/tracking/clients_logs/bo_clients_logs_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/tracking/clients_logs/bo_module_parametres.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_view.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_module_aside.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients_contacts/bo_module_aside.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients_branding/NA_bo_module_aside.php`
  - `git -C /home/romain/Cotton/www diff --check`
- [ ] Verification recette serveur:
  - verifier `Tracking > Logs clients`;
  - verifier le bloc `Logs` sur une fiche client;
  - verifier le bloc `Logs` sur une fiche contact/client branding si disponible.

# PATCH 2026-05-11 - LP reseau enrichie par abonnement reseau

- [x] Audit cible:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `www/web/lp/lp.php`
  - `www/web/.htaccess`
- [x] Correctif livre:
  - ajout du bloc BO `Page reseau / operation` uniquement sur la fiche custom `Abonnement reseau`;
  - sauvegarde des champs LP dans la table dediee globale `ecommerce_reseau_support_lp_settings`;
  - ajout de `/lp/reseau/{slug}` et maintien de `/lp/operation/{slug}` comme compatibilite;
  - LP reseau sans abonnement actif: badge hero `Invitation Cotton`, CTA `Rejoindre Cotton`, aucune promesse d'acces inclus;
  - LP reseau avec abonnement actif: personnalisation lue depuis l'abonnement actif le plus recent, dates affichees seulement si debut + fin sont renseignees.
- [ ] Recette serveur:
  - TdR sans support actif;
  - support actif sans personnalisation;
  - support actif personnalise;
  - plusieurs supports actifs;
  - offre non reseau.
## PATCH 2026-05-11 - Abonnement reseau: cron date_fin
- [x] Audit confirme dans:
  - `www/web/bo/cron_routine_bdd_maj.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - appel de la cloture automatique des supports reseau expires depuis la routine BDD;
  - synchronisation de la `date_fin` support vers les incluses actives lors des sauvegardes BO;
  - conservation des offres propres et hors cadre hors du flux.
- [x] Verification:
  - `php -l www/web/bo/cron_routine_bdd_maj.php`
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
## PATCH 2026-05-26 — Export cohortes: rapprochement essais gratuits BO
- [x] Audit regle BO:
  - source: `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`, bloc `$sql_trial_clients`;
  - colonne officielle `Essais gratuits` du tableau `Visiteurs / prospects / clients`;
  - inclusion par offres abonnement `id_offre_type=2`, `trial_period_days>0`, `flag_offert=0`, `prix_ht>0`, `id_etat IN (3,4)`, date de debut dans le mois, client non archive, sans facture le meme jour.
- [x] Livrables doc/export:
  - adaptation de `docs/cotton_cohortes_reporting_2025_09_2026_05_READONLY.sql` sur les blocs `J` et `J2`;
  - ajout du bloc `J3 rapprochement essais gratuits BO vs audit large`;
  - conservation des flags CHR/reseau sans filtre dur, afin de reproduire le volume BO officiel complet;
  - mise a jour de `docs/README_export_cohortes.md`.
- [x] Verification:
  - controle lecture seule SQL;
  - `npm run docs:sitemap`.

## PATCH 2026-05-26 — BO reporting SaaS: retour expansion nette en modale
- [x] Correctif livré:
  - retrait du contexte `view=expansion` de `facturation_pivot&p=list`;
  - retour des liens `Expansion net` du tableau `Abonnements` vers la modale historique;
  - filtrage de la modale par scope pour les sous-lignes `Mensuels` / `Annuels`;
  - conservation du listing facture pour les autres valeurs cliquables.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_list.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/facturation_pivot_factures.php`
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_list.php web/bo/www/modules/syntheses/facturation_pivot/facturation_pivot_factures.php`

## PATCH 2026-05-27 — BO reporting SaaS: page detail ARPA
- [x] Correctif livre:
  - ajout de `facturation_pivot&p=arpa` pour expliquer le calcul `ARPA HT attendu = MRR HT attendu / abonnes actifs retenus`;
  - redirection des clics `ARPA HT` du tableau `Abonnements` vers la page dediee;
  - ajout des filtres periode/scope et du detail client par MRR attendu;
  - conservation d'un lien secondaire vers les factures sources;
  - alignement du detail ARPA sur le MRR actif net par client, afin de couvrir les lignes courantes a emettre.
  - reprise du libelle d'offre M-1 sur les abonnements a emettre afin d'eviter les cellules `Offre` vides.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_arpa.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_expansion.php`
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_arpa.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_expansion.php`
- [ ] Recette serveur:
  - verifier un clic ARPA total sur `/bo/?t=syntheses&m=facturation_pivot&p=saas`;
  - verifier les sous-lignes ARPA `Mensuels` et `Annuels`;
  - comparer le lien `Voir les factures sources` avec le listing facture historique.

## PATCH 2026-05-27 — BO reporting SaaS: liens visiteurs et conversion
- [x] Correctif livre:
  - `Demos visiteurs` redirige vers le listing BO `Championnats > Sessions` filtre par IDs de sessions demo site;
  - `Nvx inscrits` redirige vers le listing BO `Entites > Clients` filtre par IDs clients;
  - `Démos nvx inscrits` redirige vers le listing BO `Championnats > Sessions` filtre par IDs de sessions demo rattachees aux nouveaux inscrits;
  - `Essais gratuits` redirige vers le listing BO `Entites > Clients` filtre par IDs clients;
  - `Nvx clients` redirige vers le listing BO `Entites > Clients` filtre par IDs clients;
  - `Tx visiteurs → clients` redirige vers `facturation_pivot&p=conversion`, avec etapes de conversion et volumes cliquables;
  - ajout des filtres techniques `bo_session_ids` et `bo_client_ids` aux listings existants.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_conversion.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/championnats/sessions/bo_sessions_functions.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_header.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/entites/clients/bo_clients_list.php`
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_conversion.php web/bo/www/modules/championnats/sessions/bo_sessions_functions.php web/bo/www/modules/entites/clients/bo_clients_header.php web/bo/www/modules/entites/clients/bo_clients_list.php`
- [ ] Recette serveur:
  - verifier chaque clic du tableau `Visiteurs / prospects / clients`;
  - verifier que la pagination des listings conserve `bo_session_ids` / `bo_client_ids`;
  - verifier la page `facturation_pivot&p=conversion` sur un mois avec donnees.

## PATCH 2026-05-27 — BO reporting SaaS: redirections nouvel onglet et totaux
- [x] Correctif livre:
  - tous les liens de redirection du reporting SaaS ouvrent un nouvel onglet;
  - ajout de liens sur les totaux `Ventes et résultat`, `Abonnements`, `Visiteurs / prospects / clients` et `Répartition par typologie`;
  - `facturation_pivot&p=conversion&period_total=1` agrege les etapes de conversion sur la periode selectionnee;
  - `facturation_pivot&p=expansion&period_total=1` agrege l'expansion nette sur la periode selectionnee.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_conversion.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_expansion.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_arpa.php`
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_conversion.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_expansion.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_arpa.php`
- [ ] Recette serveur:
  - verifier que les liens ouvrent un nouvel onglet depuis `/bo/?t=syntheses&m=facturation_pivot&p=saas`;
  - verifier les totaux du tableau `Abonnements` sur une periode multi-mois;
  - verifier les totaux du tableau `Visiteurs / prospects / clients` sur une periode multi-mois.

## PATCH 2026-05-27 — BO reporting SaaS: conversion par usage
- [x] Correctif livre:
  - ajout de la collecte des nouveaux inscrits, essais gratuits et nouveaux clients par usage `Dynamisation` (`id_solution_usage=1`) et `Gamification` (`id_solution_usage=2`);
  - limitation de la `Conversion globale` aux etapes communes `Visiteurs uniques`, `Demos site`, `Inscrits`, avec ajout de la ligne `Clients`;
  - ligne globale `Clients` alignee sur le compteur existant des nouveaux clients de la periode;
  - ajout d'un tableau `Conversion par usage` avec les lignes `Dynamisation`, `Gamification` et `Total`;
  - calcul de la colonne `Avec demo` par clients distincts ayant au moins une demo, dedoublonnes sur toute la periode, et non par nombre de sessions;
  - calcul des taux `demo / inscrits`, `essai / inscrits` et `client / inscrits` sur la base des inscrits de chaque usage.
  - ajout du `+` mensuel dans le tableau principal `Visiteurs / prospects / clients` pour afficher les sous-lignes `Dynamisation` et `Gamification`;
  - ajout de la collecte des demos de nouveaux inscrits `Gamification` pour conserver des liens vers le listing sessions filtre.
  - stabilisation des requetes `Demos nvx inscrits` par mois: le mois d'inscription client doit etre identique au mois de la session demo.
  - ajout des sous-lignes de segmentation sur les lignes `Total` en vue multi-mois pour `Ventes et resultat`, `Abonnements` et `Visiteurs / prospects / clients`, ouvertes par defaut et en gras.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_conversion.php`
  - `git -C /home/romain/Cotton/www diff --check -- web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_saas.php web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_conversion.php`
- [ ] Recette serveur:
  - verifier un mois avec inscrits sans usage renseigne, qui doivent rester dans `Total` sans apparaitre dans `Dynamisation` ou `Gamification`;
  - verifier les libelles metier si d'autres valeurs de `clients.id_solution_usage` doivent etre distinguees.
  - verifier un mois ou les sous-lignes visiteurs ont des volumes Dynamisation et Gamification non nuls.
  - verifier une vue multi-mois et une vue mono-mois pour confirmer que le `+` de total ne s'affiche que sur les vues multi-mois.
